--------------------------------------------------------
--  DDL for Package Body HZ_CUSTOMER_PROFILE_V2PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_CUSTOMER_PROFILE_V2PUB" AS
/*$Header: ARH2CFSB.pls 120.30.12010000.6 2009/12/28 10:17:32 rgokavar ship $ */

--------------------------------------
-- declaration of private global varibles
--------------------------------------

G_DEBUG_COUNT             NUMBER := 0;
--G_DEBUG                   BOOLEAN := FALSE;

--------------------------------------
-- declaration of private procedures and functions
--------------------------------------

/*PROCEDURE enable_debug;

PROCEDURE disable_debug;
*/


PROCEDURE do_create_customer_profile (
    p_customer_profile_rec                  IN OUT NOCOPY CUSTOMER_PROFILE_REC_TYPE,
    p_create_profile_amt                    IN     VARCHAR2,
    x_cust_account_profile_id               OUT NOCOPY    NUMBER,
    x_return_status                         IN OUT NOCOPY VARCHAR2
);

PROCEDURE do_update_customer_profile (
    p_customer_profile_rec                  IN OUT NOCOPY CUSTOMER_PROFILE_REC_TYPE,
    p_object_version_number                 IN OUT NOCOPY NUMBER,
    x_return_status                         IN OUT NOCOPY VARCHAR2
);

PROCEDURE do_create_cust_profile_amt (
    p_check_foreign_key                     IN     VARCHAR2,
    p_cust_profile_amt_rec                  IN OUT NOCOPY CUST_PROFILE_AMT_REC_TYPE,
    x_cust_acct_profile_amt_id              OUT NOCOPY    NUMBER,
    x_return_status                         IN OUT NOCOPY VARCHAR2
);

PROCEDURE do_update_cust_profile_amt (
    p_cust_profile_amt_rec                  IN OUT NOCOPY CUST_PROFILE_AMT_REC_TYPE,
    p_object_version_number                 IN OUT NOCOPY NUMBER,
    x_return_status                         IN OUT NOCOPY VARCHAR2
);

FUNCTION compute_next_date
( p_date    IN DATE,
  p_period  IN VARCHAR2)
RETURN DATE;

FUNCTION party_id_value
( p_cust_account_id  IN NUMBER,
  p_active           IN VARCHAR2 )
RETURN NUMBER;

FUNCTION party_exist
( p_party_id   IN NUMBER,
  p_active     IN VARCHAR2)
RETURN VARCHAR2;

--------------------------------------
-- private procedures and functions
--------------------------------------
--2310474{
/**
 * Private Function compute_next_date
 *
 * Description
 * Compute the next review date
 *
 * MODIFICATION HISTORY
 * 04-19-2002  Herve Yu    o Created
 *
 */
FUNCTION compute_next_date
( p_date    IN DATE,
  p_period  IN VARCHAR2)
RETURN DATE
IS
  l_date  DATE;
BEGIN
    IF     p_period  = 'WEEKLY' THEN
       l_date  := p_date + 7;
    ELSIF  p_period  = 'MONTHLY' THEN
       l_date  := add_months(p_date,1);
    ELSIF  p_period  = 'QUARTERLY' THEN
       l_date  := add_months(p_date,3);
    ELSIF  p_period  = 'HALF_YEARLY' THEN
       l_date  := add_months(p_date,6);
    ELSIF  p_period  = 'YEARLY' THEN
       l_date  := add_months(p_date,12);
    ELSE
       l_date  := p_date;
    END IF;
    RETURN l_date;
END;

/**
 * Private Function Party_id_value
 *
 * Description
 * Provide the party_id for a cust_account_id
 *
 * MODIFICATION HISTORY
 * 04-19-2002  Herve Yu    o Created
 *
 */
FUNCTION party_id_value
( p_cust_account_id  IN NUMBER,
  p_active           IN VARCHAR2 )
RETURN NUMBER
IS
 CURSOR c1 IS
 SELECT a.party_id
   FROM hz_cust_accounts a,
        hz_parties       b
  WHERE a.cust_account_id = p_cust_account_id
    AND a.party_id        = b.party_id
    AND b.status          = DECODE(p_active,'ALL',b.status,p_active);
 l_party_id  NUMBER;
BEGIN
 OPEN c1;
 FETCH c1 INTO l_party_id;
 IF c1%NOTFOUND OR l_party_id IS NULL THEN
   l_party_id := -99999;
 END IF;
 CLOSE c1;
 RETURN l_party_id;
END;

FUNCTION party_exist
( p_party_id   IN NUMBER,
  p_active     IN VARCHAR2)
RETURN VARCHAR2
IS
  CURSOR c1 IS
  SELECT 'Y'
    FROM hz_parties
   WHERE party_id = p_party_id
     AND status   = DECODE(p_active,'ALL',status,p_active);
  lact VARCHAR2(1);
  ret  VARCHAR2(1);
BEGIN
  OPEN c1;
  FETCH c1 INTO lact;
  IF c1%NOTFOUND THEN
    ret := 'N';
  ELSE
    ret := 'Y';
  END IF;
  CLOSE c1;
  RETURN ret;
END;

/**
 * Private Function class_review_cycle
 *
 * Description
 * RETURN the Reveiew_Cycle of a Profile Class
 *
 * MODIFICATION HISTORY
 * 04-19-2002  Herve Yu    o Created
 *
 */
FUNCTION  class_review_cycle
  ( p_cust_prof_class_id   IN NUMBER)
RETURN VARCHAR2
IS
    CURSOR c1 IS
    SELECT review_cycle
      FROM hz_cust_profile_classes
     WHERE profile_class_id = p_cust_prof_class_id;
    l_review_cycle   VARCHAR2(30);
BEGIN
    OPEN c1;
    FETCH c1 INTO l_review_cycle;
    IF c1%NOTFOUND THEN
      l_review_cycle := 'NO_DATA_FOUND';
    END IF;
    CLOSE c1;
    RETURN l_review_cycle;
END;


--}

/**
 * PRIVATE PROCEDURE enable_debug
 *
 * DESCRIPTION
 *     Turn on debug mode.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_UTILITY_V2PUB.enable_debug
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Jianying Huang      o Created.
 *
 */

/*PROCEDURE enable_debug IS

BEGIN

    G_DEBUG_COUNT := G_DEBUG_COUNT + 1;

    IF G_DEBUG_COUNT = 1 THEN
        IF FND_PROFILE.value( 'HZ_API_FILE_DEBUG_ON' ) = 'Y' OR
           FND_PROFILE.value( 'HZ_API_DBMS_DEBUG_ON' ) = 'Y'
        THEN
           HZ_UTILITY_V2PUB.enable_debug;
           G_DEBUG := TRUE;
        END IF;
    END IF;

END enable_debug;
*/


/**
 * PRIVATE PROCEDURE disable_debug
 *
 * DESCRIPTION
 *     Turn off debug mode.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_UTILITY_V2PUB.disable_debug
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Jianying Huang      o Created.
 *
 */

/*PROCEDURE disable_debug IS

BEGIN

    IF G_DEBUG THEN
        G_DEBUG_COUNT := G_DEBUG_COUNT - 1;

        IF G_DEBUG_COUNT = 0 THEN
            HZ_UTILITY_V2PUB.disable_debug;
            G_DEBUG := FALSE;
        END IF;
    END IF;

END disable_debug;
*/

/**
 * PRIVATE PROCEDURE do_create_customer_profile
 *
 * DESCRIPTION
 *     Private procedure to create customer profile.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_ACCOUNT_VALIDATE_V2PUB.validate_customer_profile
 *     HZ_CUSTOMER_PROFILES_PKG.Insert_Row
 *     HZ_CUST_PROF_CLASS_AMTS_PKG.Select_Row
 *
 * ARGUMENTS
 *   IN:
 *     p_create_profile_amt           If it is set to FND_API.G_TRUE, API create customer
 *                                    profile amounts by copying corresponding data
 *                                    from customer profile class amounts.
 *   IN/OUT:
 *     p_customer_profile_rec         Customer profile record. One customer account
 *                                    must have a customer profile. One account site
 *                                    use can optionally have one customer profile.
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *   OUT:
 *     x_cust_account_profile_id      Customer account profile ID.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Jianying Huang      o Created.
 *   07-15-2004    Rajib Ranjan Borah  o Bug 3767719. Used variable l_default_profile_class_id
 *                                       instead of using the hard-coded value 0 to improve
 *                                       performance. This query and the one in package
 *                                       HZ_ACCOUNT_VALIDATE_V2PUB.validate_customer_profile
 *                                       will be parsed only once.
 */

PROCEDURE do_create_customer_profile (
    p_customer_profile_rec                  IN OUT NOCOPY CUSTOMER_PROFILE_REC_TYPE,
    p_create_profile_amt                    IN     VARCHAR2,
    x_cust_account_profile_id               OUT NOCOPY    NUMBER,
    x_return_status                         IN OUT NOCOPY VARCHAR2
) IS

    l_debug_prefix                          VARCHAR2(30) := ''; --'do_create_customer_profile';

    l_is_first                              BOOLEAN := TRUE;
    l_return_status                         VARCHAR2(1);
    l_msg_count                             NUMBER;
    l_msg_data                              VARCHAR2(2000);

    l_cust_profile_amt_rec                  CUST_PROFILE_AMT_REC_TYPE;
    l_status                                HZ_CUST_PROFILE_CLASSES.status%TYPE;
    l_profile_class_name                    HZ_CUST_PROFILE_CLASSES.name%TYPE;
    l_profile_class_amount_id               NUMBER;
    l_profile_class_id                      NUMBER;

    -- 2310474 {
    l_party_id                              NUMBER;
    l_review_cycle                          VARCHAR2(30);
    l_last_credit_review_date               DATE;
    -- }

    -- Bug 3767719
    l_default_profile_class_id              NUMBER :=0;

    CURSOR c_profile_class_amts IS
        SELECT PROFILE_CLASS_AMOUNT_ID
        FROM HZ_CUST_PROF_CLASS_AMTS
        WHERE PROFILE_CLASS_ID = p_customer_profile_rec.profile_class_id;

    cursor c_acct_use_profile_dtls IS
    select cons_bill_level, cons_inv_type
    from   hz_customer_profiles
    where  cust_account_id = p_customer_profile_rec.cust_account_id
    and    site_use_id is NULL
    and    cons_inv_flag = 'Y';

    l_cons_bill_level  varchar2(30);
    l_cons_inv_type    varchar2(30);
    v_action                                VARCHAR2(10);
    v_entity_code                           VARCHAR2(1);
    v_entity_id                             NUMBER(15);
    l_profile_class_rec                     HZ_CUST_PROFILE_CLASSES%ROWTYPE;

BEGIN

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_create_customer_profile (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Default profile_class_id.
    IF p_customer_profile_rec.profile_class_id IS NULL OR
       p_customer_profile_rec.profile_class_id = FND_API.G_MISS_NUM
    THEN
       BEGIN
           SELECT STATUS, NAME INTO l_status, l_profile_class_name
           FROM HZ_CUST_PROFILE_CLASSES
           WHERE PROFILE_CLASS_ID = l_default_profile_class_id; -- Bug 3767719.

           IF l_status = 'I' THEN
               FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_INACTIVE_PROFILE_CLASS' );
               FND_MESSAGE.SET_TOKEN( 'NAME', l_profile_class_name );
               FND_MSG_PUB.ADD;
               RAISE FND_API.G_EXC_ERROR;
           END IF;

           -- Setup profile_class_id.
           p_customer_profile_rec.profile_class_id := 0;

       EXCEPTION
           WHEN NO_DATA_FOUND THEN
               FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_NO_DEFAULT_PROF_CLASS' );
               FND_MSG_PUB.ADD;
               RAISE FND_API.G_EXC_ERROR;
       END;
    END IF;

    -- Debug info.
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'get default active profile class (id = 0)',
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;


    --{
    -- 2310474 a value for party_id associated with the customer account
    -- Algorithm :
    -- A) Creation mode
    --   If party_id is null     and    cust_account_id is null then
    --      error
    --   If party_id is not null and    cust_account_id is null then
    --      party_id must be active
    --      cust_account_id = -1
    --   If party_id is null     and    cust_account_id is not null then
    --      cust_account_id must be associated with an active party_id
    --      party_id = this active party_id
    --   If party_id is not null and    cust_account_id is not null then
    --      party_id must be active
    --      cust_account_id and party_id must be associated in hz_cust_accounts.
    --
    IF ( p_customer_profile_rec.party_id IS NULL OR
         p_customer_profile_rec.party_id = FND_API.G_MISS_NUM )
    THEN

       IF ( p_customer_profile_rec.cust_account_id IS NULL OR
            p_customer_profile_rec.cust_account_id = FND_API.G_MISS_NUM )
       THEN
          FND_MESSAGE.SET_NAME('AR','HZ_API_CF_ASS_PTY_OR_ACCT');
          FND_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
       ELSE
          l_party_id := party_id_value(p_customer_profile_rec.cust_account_id, 'A');
          IF l_party_id = -99999 THEN
             FND_MESSAGE.SET_NAME('AR','HZ_API_NO_A_PTY_ASS_ACCT');
             FND_MESSAGE.SET_TOKEN('ACCT_ID',p_customer_profile_rec.cust_account_id);
             FND_MSG_PUB.ADD;
             x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
          p_customer_profile_rec.party_id := l_party_id;
       END IF;

    ELSE

       IF party_exist( p_customer_profile_rec.party_id, 'A' ) <> 'Y' THEN
          FND_MESSAGE.SET_NAME('AR','HZ_API_NO_A_PTY');
          FND_MESSAGE.SET_TOKEN( 'PARTY_ID', p_customer_profile_rec.party_id);
          FND_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
       END IF;

       IF ( p_customer_profile_rec.cust_account_id IS NULL OR
            p_customer_profile_rec.cust_account_id = FND_API.G_MISS_NUM )
       THEN
          p_customer_profile_rec.cust_account_id := -1;
       ELSE
          IF    party_id_value(p_customer_profile_rec.cust_account_id, 'A')
             <> p_customer_profile_rec.party_id
          THEN
               FND_MESSAGE.SET_NAME('AR','HZ_API_ACCT_NOT_ASS_PTY');
               FND_MESSAGE.SET_TOKEN( 'ACCT_ID',  p_customer_profile_rec.cust_account_id );
               FND_MESSAGE.SET_TOKEN( 'PARTY_ID', p_customer_profile_rec.party_id);
               FND_MSG_PUB.ADD;
               x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
        END IF;

    END IF;
    -- }
--------------
  -- Bug 9188425 -Exception block is added to handle invalid Profile Class Id.
  BEGIN
   -- to get the default values from profile class
   SELECT * INTO l_profile_class_rec
   FROM HZ_CUST_PROFILE_CLASSES
   WHERE PROFILE_CLASS_ID = p_customer_profile_rec.profile_class_id;

  EXCEPTION
      WHEN NO_DATA_FOUND THEN
            FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_NO_RECORD' );
            FND_MESSAGE.SET_TOKEN( 'RECORD', 'Customer Profile Class' );
            FND_MESSAGE.SET_TOKEN( 'VALUE',
                NVL( TO_CHAR( p_customer_profile_rec.profile_class_id ), 'null' ) );
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
  END;
   -- if cons_inv_flag is NULL, get it defaulted from profile class
   -- if it is still NULL, assign it as 'N'
   if p_customer_profile_rec.cons_inv_flag is NULl then
      if l_profile_class_rec.cons_inv_flag is NOT NULL then
         p_customer_profile_rec.cons_inv_flag := l_profile_class_rec.cons_inv_flag;
      else
         p_customer_profile_rec.cons_inv_flag := 'N';
      end if;
   end if;

   -- if cons_inv_flag is 'N', make cons_bill_level and cons_inv_type to NULL
   if p_customer_profile_rec.cons_inv_flag = 'N' then
      p_customer_profile_rec.cons_inv_type := NULL;
      p_customer_profile_rec.cons_bill_level := NULL;
   elsif p_customer_profile_rec.cons_inv_flag = 'Y' then
      -- If site_use_id is NOT NULL, then it is for Site use profile
      -- For site use profile, passed value for bill level should be NULL
      -- and it should get defaulted from account use profile. Also,
      -- if cons_inv_type is NULL , it should get defaulted from account use profile.
      if p_customer_profile_rec.site_use_id is NOT NULL then
/*
         if p_customer_profile_rec.cons_bill_level is NOT NULL then
            FND_MESSAGE.SET_NAME('AR', 'HZ_API_SITE_BILL_LVL_NULL');
            FND_MSG_PUB.ADD;
            x_return_status := FND_API.G_RET_STS_ERROR;
         end if;
*/
         OPEN  c_acct_use_profile_dtls;
         FETCH c_acct_use_profile_dtls INTO l_cons_bill_level, l_cons_inv_type;
         IF c_acct_use_profile_dtls%NOTFOUND THEN
            FND_MESSAGE.SET_NAME('AR', 'HZ_API_ENABLE_ACC_BAL_FWD_BILL');
            FND_MSG_PUB.ADD;
            x_return_status := FND_API.G_RET_STS_ERROR;
         END IF;
         p_customer_profile_rec.cons_bill_level := l_cons_bill_level;
         if p_customer_profile_rec.cons_inv_type is NULL then
            p_customer_profile_rec.cons_inv_type := l_cons_inv_type;
         end if;
         CLOSE c_acct_use_profile_dtls;
      -- Else for account use profile, getbthe value from profile class
      -- if cons_bill_level or cons_inv_type is passed as NULL.
      else
         if p_customer_profile_rec.cons_bill_level is NULL then
            p_customer_profile_rec.cons_bill_level := l_profile_class_rec.cons_bill_level;
         end if;
         if p_customer_profile_rec.cons_inv_type is NULL then
            p_customer_profile_rec.cons_inv_type := l_profile_class_rec.cons_inv_type;
         end if;
      end if;
   end if;

   -- if standard terms is NULL, get it defaulted from profile class
   if p_customer_profile_rec.standard_terms is NULL then
      p_customer_profile_rec.standard_terms := l_profile_class_rec.standard_terms;
   end if;

   -- if late charge payment term or late charge type or message_text_id is NULL, get it defaulted from profile class
   if p_customer_profile_rec.late_charge_term_id is NULL then
      p_customer_profile_rec.late_charge_term_id := l_profile_class_rec.late_charge_term_id;
   end if;
   if p_customer_profile_rec.late_charge_type is NULL then
      p_customer_profile_rec.late_charge_type := l_profile_class_rec.late_charge_type;
   end if;

   if p_customer_profile_rec.message_text_id is NULL then
      p_customer_profile_rec.message_text_id := l_profile_class_rec.message_text_id;
   end if;

   if p_customer_profile_rec.automatch_set_id is NULL then
      p_customer_profile_rec.automatch_set_id := l_profile_class_rec.automatch_set_id;
   end if;


--   if p_customer_profile_rec.late_charge_type = 'ADJ' then
--      p_customer_profile_rec.late_charge_term_id := NULL;
--      p_customer_profile_rec.message_text_id     := NULL;
--   end if;
-----------
    -- Validate customer profile record
    HZ_ACCOUNT_VALIDATE_V2PUB.validate_customer_profile (
        p_create_update_flag                    => 'C',
        p_customer_profile_rec                  => p_customer_profile_rec,
        p_rowid                                 => NULL,
        x_return_status                         => x_return_status );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Added rounding of payment_grace_days to integer for Late charge project.
    IF p_customer_profile_rec.payment_grace_days is NOT NULL then
       p_customer_profile_rec.payment_grace_days := ROUND(p_customer_profile_rec.payment_grace_days,0);
    END IF;

    -- Added rounding of interest_period_days to integer for Late charge project.
    IF p_customer_profile_rec.interest_period_days is NOT NULL then
       p_customer_profile_rec.interest_period_days := ROUND(p_customer_profile_rec.interest_period_days,0);
    END IF;

    -- Add logic for global holds

    IF p_customer_profile_rec.credit_hold = 'Y' THEN
      v_action := 'APPLY';
      IF p_customer_profile_rec.site_use_id IS NULL THEN
        v_entity_code := 'C';
        v_entity_id := p_customer_profile_rec.cust_account_id;
      ELSE
        v_entity_code := 'S';
        v_entity_id := p_customer_profile_rec.site_use_id;
      END IF;

      -- Debug info.
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
          hz_utility_v2pub.debug(p_message=>'Before call OE_HOLDS... '||
                                            'v_action = '||v_action||' '||
                                            'v_entity_code = '||v_entity_code||' '||
                                            'v_entity_id = '||v_entity_id,
                                 p_prefix=>l_debug_prefix,
                                 p_msg_level=>fnd_log.level_statement);
      END IF;

      BEGIN
        OE_Holds_PUB.Process_Holds (
          p_api_version         => 1.0,
          p_init_msg_list       => FND_API.G_FALSE,
          p_hold_entity_code    => v_entity_code,
          p_hold_entity_id      => v_entity_id,
          p_hold_id             => 1,
          p_release_reason_code => 'AR_AUTOMATIC',
          p_action              => v_action,
          x_return_status       => l_return_status,
          x_msg_count           => l_msg_count,
          x_msg_data            => l_msg_data);

          -- Debug info.
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'After call OE_HOLDS... '||
                                              'l_return_status = '||l_return_status||' '||
                                              'l_msg_count = '||l_msg_count||' '||
                                              'l_msg_data = '||l_msg_data,
                                   p_prefix=>l_debug_prefix,
                                   p_msg_level=>fnd_log.level_statement);
          END IF;
      EXCEPTION
        WHEN OTHERS THEN
          -- Debug info.
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'Exception raised from OE_HOLDS... '||SQLERRM,
                                   p_prefix=>l_debug_prefix,
                                   p_msg_level=>fnd_log.level_statement);
          END IF;

          l_return_status := 'S';
      END;

      --
      -- only raise unexpected error
      --
      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;

    -- Call table-handler.
    -- Table_handler is taking care of default customer profile to profile class.

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'HZ_CUSTOMER_PROFILES_PKG.Insert_Row (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    HZ_CUSTOMER_PROFILES_PKG.Insert_Row (
        X_CUST_ACCOUNT_PROFILE_ID               => p_customer_profile_rec.cust_account_profile_id,
        X_CUST_ACCOUNT_ID                       => p_customer_profile_rec.cust_account_id,
        X_STATUS                                => p_customer_profile_rec.status,
        X_COLLECTOR_ID                          => p_customer_profile_rec.collector_id,
        X_CREDIT_ANALYST_ID                     => p_customer_profile_rec.credit_analyst_id,
        X_CREDIT_CHECKING                       => p_customer_profile_rec.credit_checking,
        X_NEXT_CREDIT_REVIEW_DATE               => p_customer_profile_rec.next_credit_review_date,
        X_TOLERANCE                             => p_customer_profile_rec.tolerance,
        X_DISCOUNT_TERMS                        => p_customer_profile_rec.discount_terms,
        X_DUNNING_LETTERS                       => p_customer_profile_rec.dunning_letters,
        X_INTEREST_CHARGES                      => p_customer_profile_rec.interest_charges,
        X_SEND_STATEMENTS                       => p_customer_profile_rec.send_statements,
        X_CREDIT_BALANCE_STATEMENTS             => p_customer_profile_rec.credit_balance_statements,
        X_CREDIT_HOLD                           => p_customer_profile_rec.credit_hold,
        X_PROFILE_CLASS_ID                      => p_customer_profile_rec.profile_class_id,
        X_SITE_USE_ID                           => p_customer_profile_rec.site_use_id,
        X_CREDIT_RATING                         => p_customer_profile_rec.credit_rating,
        X_RISK_CODE                             => p_customer_profile_rec.risk_code,
        X_STANDARD_TERMS                        => p_customer_profile_rec.standard_terms,
        X_OVERRIDE_TERMS                        => p_customer_profile_rec.override_terms,
        X_DUNNING_LETTER_SET_ID                 => p_customer_profile_rec.dunning_letter_set_id,
        X_INTEREST_PERIOD_DAYS                  => p_customer_profile_rec.interest_period_days,
        X_PAYMENT_GRACE_DAYS                    => p_customer_profile_rec.payment_grace_days,
        X_DISCOUNT_GRACE_DAYS                   => p_customer_profile_rec.discount_grace_days,
        X_STATEMENT_CYCLE_ID                    => p_customer_profile_rec.statement_cycle_id,
        X_ACCOUNT_STATUS                        => p_customer_profile_rec.account_status,
        X_PERCENT_COLLECTABLE                   => p_customer_profile_rec.percent_collectable,
        X_AUTOCASH_HIERARCHY_ID                 => p_customer_profile_rec.autocash_hierarchy_id,
        X_ATTRIBUTE_CATEGORY                    => p_customer_profile_rec.attribute_category,
        X_ATTRIBUTE1                            => p_customer_profile_rec.attribute1,
        X_ATTRIBUTE2                            => p_customer_profile_rec.attribute2,
        X_ATTRIBUTE3                            => p_customer_profile_rec.attribute3,
        X_ATTRIBUTE4                            => p_customer_profile_rec.attribute4,
        X_ATTRIBUTE5                            => p_customer_profile_rec.attribute5,
        X_ATTRIBUTE6                            => p_customer_profile_rec.attribute6,
        X_ATTRIBUTE7                            => p_customer_profile_rec.attribute7,
        X_ATTRIBUTE8                            => p_customer_profile_rec.attribute8,
        X_ATTRIBUTE9                            => p_customer_profile_rec.attribute9,
        X_ATTRIBUTE10                           => p_customer_profile_rec.attribute10,
        X_ATTRIBUTE11                           => p_customer_profile_rec.attribute11,
        X_ATTRIBUTE12                           => p_customer_profile_rec.attribute12,
        X_ATTRIBUTE13                           => p_customer_profile_rec.attribute13,
        X_ATTRIBUTE14                           => p_customer_profile_rec.attribute14,
        X_ATTRIBUTE15                           => p_customer_profile_rec.attribute15,
        X_AUTO_REC_INCL_DISPUTED_FLAG           => p_customer_profile_rec.auto_rec_incl_disputed_flag,
        X_TAX_PRINTING_OPTION                   => p_customer_profile_rec.tax_printing_option,
        X_CHARGE_ON_FINANCE_CHARGE_FG           => p_customer_profile_rec.charge_on_finance_charge_flag,
        X_GROUPING_RULE_ID                      => p_customer_profile_rec.grouping_rule_id,
        X_CLEARING_DAYS                         => p_customer_profile_rec.clearing_days,
        X_JGZZ_ATTRIBUTE_CATEGORY               => p_customer_profile_rec.jgzz_attribute_category,
        X_JGZZ_ATTRIBUTE1                       => p_customer_profile_rec.jgzz_attribute1,
        X_JGZZ_ATTRIBUTE2                       => p_customer_profile_rec.jgzz_attribute2,
        X_JGZZ_ATTRIBUTE3                       => p_customer_profile_rec.jgzz_attribute3,
        X_JGZZ_ATTRIBUTE4                       => p_customer_profile_rec.jgzz_attribute4,
        X_JGZZ_ATTRIBUTE5                       => p_customer_profile_rec.jgzz_attribute5,
        X_JGZZ_ATTRIBUTE6                       => p_customer_profile_rec.jgzz_attribute6,
        X_JGZZ_ATTRIBUTE7                       => p_customer_profile_rec.jgzz_attribute7,
        X_JGZZ_ATTRIBUTE8                       => p_customer_profile_rec.jgzz_attribute8,
        X_JGZZ_ATTRIBUTE9                       => p_customer_profile_rec.jgzz_attribute9,
        X_JGZZ_ATTRIBUTE10                      => p_customer_profile_rec.jgzz_attribute10,
        X_JGZZ_ATTRIBUTE11                      => p_customer_profile_rec.jgzz_attribute11,
        X_JGZZ_ATTRIBUTE12                      => p_customer_profile_rec.jgzz_attribute12,
        X_JGZZ_ATTRIBUTE13                      => p_customer_profile_rec.jgzz_attribute13,
        X_JGZZ_ATTRIBUTE14                      => p_customer_profile_rec.jgzz_attribute14,
        X_JGZZ_ATTRIBUTE15                      => p_customer_profile_rec.jgzz_attribute15,
        X_GLOBAL_ATTRIBUTE1                     => p_customer_profile_rec.global_attribute1,
        X_GLOBAL_ATTRIBUTE2                     => p_customer_profile_rec.global_attribute2,
        X_GLOBAL_ATTRIBUTE3                     => p_customer_profile_rec.global_attribute3,
        X_GLOBAL_ATTRIBUTE4                     => p_customer_profile_rec.global_attribute4,
        X_GLOBAL_ATTRIBUTE5                     => p_customer_profile_rec.global_attribute5,
        X_GLOBAL_ATTRIBUTE6                     => p_customer_profile_rec.global_attribute6,
        X_GLOBAL_ATTRIBUTE7                     => p_customer_profile_rec.global_attribute7,
        X_GLOBAL_ATTRIBUTE8                     => p_customer_profile_rec.global_attribute8,
        X_GLOBAL_ATTRIBUTE9                     => p_customer_profile_rec.global_attribute9,
        X_GLOBAL_ATTRIBUTE10                    => p_customer_profile_rec.global_attribute10,
        X_GLOBAL_ATTRIBUTE11                    => p_customer_profile_rec.global_attribute11,
        X_GLOBAL_ATTRIBUTE12                    => p_customer_profile_rec.global_attribute12,
        X_GLOBAL_ATTRIBUTE13                    => p_customer_profile_rec.global_attribute13,
        X_GLOBAL_ATTRIBUTE14                    => p_customer_profile_rec.global_attribute14,
        X_GLOBAL_ATTRIBUTE15                    => p_customer_profile_rec.global_attribute15,
        X_GLOBAL_ATTRIBUTE16                    => p_customer_profile_rec.global_attribute16,
        X_GLOBAL_ATTRIBUTE17                    => p_customer_profile_rec.global_attribute17,
        X_GLOBAL_ATTRIBUTE18                    => p_customer_profile_rec.global_attribute18,
        X_GLOBAL_ATTRIBUTE19                    => p_customer_profile_rec.global_attribute19,
        X_GLOBAL_ATTRIBUTE20                    => p_customer_profile_rec.global_attribute20,
        X_GLOBAL_ATTRIBUTE_CATEGORY             => p_customer_profile_rec.global_attribute_category,
        X_CONS_INV_FLAG                         => p_customer_profile_rec.cons_inv_flag,
        X_CONS_INV_TYPE                         => p_customer_profile_rec.cons_inv_type,
        X_AUTOCASH_HIERARCHY_ID_ADR             => p_customer_profile_rec.autocash_hierarchy_id_for_adr,
        X_LOCKBOX_MATCHING_OPTION               => p_customer_profile_rec.lockbox_matching_option,
        X_OBJECT_VERSION_NUMBER                 => 1,
        X_CREATED_BY_MODULE                     => p_customer_profile_rec.created_by_module,
        X_APPLICATION_ID                        => p_customer_profile_rec.application_id,
        X_REVIEW_CYCLE                          => p_customer_profile_rec.review_cycle,
        X_last_credit_review_date               => p_customer_profile_rec.last_credit_review_date,
        X_party_id                              => p_customer_profile_rec.party_id,
        X_CREDIT_CLASSIFICATION                 => p_customer_profile_rec.credit_classification,
        X_CONS_BILL_LEVEL                       => p_customer_profile_rec.cons_bill_level,
        X_LATE_CHARGE_CALCULATION_TRX           => p_customer_profile_rec.late_charge_calculation_trx,
        X_CREDIT_ITEMS_FLAG                     => p_customer_profile_rec.credit_items_flag,
        X_DISPUTED_TRANSACTIONS_FLAG            => p_customer_profile_rec.disputed_transactions_flag,
        X_LATE_CHARGE_TYPE                      => p_customer_profile_rec.late_charge_type,
        X_LATE_CHARGE_TERM_ID                   => p_customer_profile_rec.late_charge_term_id,
        X_INTEREST_CALCULATION_PERIOD           => p_customer_profile_rec.interest_calculation_period,
        X_HOLD_CHARGED_INVOICES_FLAG            => p_customer_profile_rec.hold_charged_invoices_flag,
        X_MESSAGE_TEXT_ID                       => p_customer_profile_rec.message_text_id,
        X_MULTIPLE_INTEREST_RATES_FLAG          => p_customer_profile_rec.multiple_interest_rates_flag,
        X_CHARGE_BEGIN_DATE                     => p_customer_profile_rec.charge_begin_date,
        X_AUTOMATCH_SET_ID                      => p_customer_profile_rec.automatch_set_id
    );

--raji

    x_cust_account_profile_id := p_customer_profile_rec.cust_account_profile_id;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'HZ_CUSTOMER_PROFILES_PKG.Insert_Row (-) ' ||
            'x_cust_account_profile_id = ' || x_cust_account_profile_id,
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Now default in the profile amounts only if
    -- p_create_profile_amt is TRUE. Otherwise, simply return.

    IF p_create_profile_amt = FND_API.G_FALSE THEN
        RETURN;
    END IF;

    BEGIN

    -- could have several records in profile_class_amts for a given
    -- profile_class_id.

    OPEN c_profile_class_amts;
    LOOP
        FETCH c_profile_class_amts INTO l_profile_class_amount_id;
        EXIT WHEN c_profile_class_amts%NOTFOUND;

        -- Setup profile amount record if it is the first run.
        IF l_is_first THEN
            l_cust_profile_amt_rec.cust_account_profile_id := p_customer_profile_rec.cust_account_profile_id;
            l_cust_profile_amt_rec.cust_account_id := p_customer_profile_rec.cust_account_id;
            l_cust_profile_amt_rec.site_use_id := p_customer_profile_rec.site_use_id;
            l_cust_profile_amt_rec.created_by_module := p_customer_profile_rec.created_by_module;
            l_cust_profile_amt_rec.application_id := p_customer_profile_rec.application_id;

            l_is_first := FALSE;
        END IF;

        -- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(p_message=>'HZ_CUST_PROF_CLASS_AMTS_PKG.Select_Row (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Call table-handler.
        HZ_CUST_PROF_CLASS_AMTS_PKG.Select_Row (
            X_PROFILE_CLASS_AMOUNT_ID               => l_profile_class_amount_id,
            X_PROFILE_CLASS_ID                      => l_profile_class_id,
            X_CURRENCY_CODE                         => l_cust_profile_amt_rec.currency_code,
            X_TRX_CREDIT_LIMIT                      => l_cust_profile_amt_rec.trx_credit_limit,
            X_OVERALL_CREDIT_LIMIT                  => l_cust_profile_amt_rec.overall_credit_limit,
            X_MIN_DUNNING_AMOUNT                    => l_cust_profile_amt_rec.min_dunning_amount,
            X_MAX_INTEREST_CHARGE                   => l_cust_profile_amt_rec.max_interest_charge,
            X_MIN_STATEMENT_AMOUNT                  => l_cust_profile_amt_rec.min_statement_amount,
            X_AUTO_REC_MIN_RECEIPT_AMOUNT           => l_cust_profile_amt_rec.auto_rec_min_receipt_amount,
            X_ATTRIBUTE_CATEGORY                    => l_cust_profile_amt_rec.attribute_category,
            X_ATTRIBUTE1                            => l_cust_profile_amt_rec.attribute1,
            X_ATTRIBUTE2                            => l_cust_profile_amt_rec.attribute2,
            X_ATTRIBUTE3                            => l_cust_profile_amt_rec.attribute3,
            X_ATTRIBUTE4                            => l_cust_profile_amt_rec.attribute4,
            X_ATTRIBUTE5                            => l_cust_profile_amt_rec.attribute5,
            X_ATTRIBUTE6                            => l_cust_profile_amt_rec.attribute6,
            X_ATTRIBUTE7                            => l_cust_profile_amt_rec.attribute7,
            X_ATTRIBUTE8                            => l_cust_profile_amt_rec.attribute8,
            X_ATTRIBUTE9                            => l_cust_profile_amt_rec.attribute9,
            X_ATTRIBUTE10                           => l_cust_profile_amt_rec.attribute10,
            X_ATTRIBUTE11                           => l_cust_profile_amt_rec.attribute11,
            X_ATTRIBUTE12                           => l_cust_profile_amt_rec.attribute12,
            X_ATTRIBUTE13                           => l_cust_profile_amt_rec.attribute13,
            X_ATTRIBUTE14                           => l_cust_profile_amt_rec.attribute14,
            X_ATTRIBUTE15                           => l_cust_profile_amt_rec.attribute15,
            X_INTEREST_RATE                         => l_cust_profile_amt_rec.interest_rate,
            X_MIN_FC_BALANCE_AMOUNT                 => l_cust_profile_amt_rec.min_fc_balance_amount,
            X_MIN_FC_INVOICE_AMOUNT                 => l_cust_profile_amt_rec.min_fc_invoice_amount,
            X_MIN_DUNNING_INVOICE_AMOUNT            => l_cust_profile_amt_rec.min_dunning_invoice_amount,
            X_EXPIRATION_DATE                       => l_cust_profile_amt_rec.expiration_date,
            X_JGZZ_ATTRIBUTE_CATEGORY               => l_cust_profile_amt_rec.jgzz_attribute_category,
            X_JGZZ_ATTRIBUTE1                       => l_cust_profile_amt_rec.jgzz_attribute1,
            X_JGZZ_ATTRIBUTE2                       => l_cust_profile_amt_rec.jgzz_attribute2,
            X_JGZZ_ATTRIBUTE3                       => l_cust_profile_amt_rec.jgzz_attribute3,
            X_JGZZ_ATTRIBUTE4                       => l_cust_profile_amt_rec.jgzz_attribute4,
            X_JGZZ_ATTRIBUTE5                       => l_cust_profile_amt_rec.jgzz_attribute5,
            X_JGZZ_ATTRIBUTE6                       => l_cust_profile_amt_rec.jgzz_attribute6,
            X_JGZZ_ATTRIBUTE7                       => l_cust_profile_amt_rec.jgzz_attribute7,
            X_JGZZ_ATTRIBUTE8                       => l_cust_profile_amt_rec.jgzz_attribute8,
            X_JGZZ_ATTRIBUTE9                       => l_cust_profile_amt_rec.jgzz_attribute9,
            X_JGZZ_ATTRIBUTE10                      => l_cust_profile_amt_rec.jgzz_attribute10,
            X_JGZZ_ATTRIBUTE11                      => l_cust_profile_amt_rec.jgzz_attribute11,
            X_JGZZ_ATTRIBUTE12                      => l_cust_profile_amt_rec.jgzz_attribute12,
            X_JGZZ_ATTRIBUTE13                      => l_cust_profile_amt_rec.jgzz_attribute13,
            X_JGZZ_ATTRIBUTE14                      => l_cust_profile_amt_rec.jgzz_attribute14,
            X_JGZZ_ATTRIBUTE15                      => l_cust_profile_amt_rec.jgzz_attribute15,
            X_GLOBAL_ATTRIBUTE1                     => l_cust_profile_amt_rec.global_attribute1,
            X_GLOBAL_ATTRIBUTE2                     => l_cust_profile_amt_rec.global_attribute2,
            X_GLOBAL_ATTRIBUTE3                     => l_cust_profile_amt_rec.global_attribute3,
            X_GLOBAL_ATTRIBUTE4                     => l_cust_profile_amt_rec.global_attribute4,
            X_GLOBAL_ATTRIBUTE5                     => l_cust_profile_amt_rec.global_attribute5,
            X_GLOBAL_ATTRIBUTE6                     => l_cust_profile_amt_rec.global_attribute6,
            X_GLOBAL_ATTRIBUTE7                     => l_cust_profile_amt_rec.global_attribute7,
            X_GLOBAL_ATTRIBUTE8                     => l_cust_profile_amt_rec.global_attribute8,
            X_GLOBAL_ATTRIBUTE9                     => l_cust_profile_amt_rec.global_attribute9,
            X_GLOBAL_ATTRIBUTE10                    => l_cust_profile_amt_rec.global_attribute10,
            X_GLOBAL_ATTRIBUTE11                    => l_cust_profile_amt_rec.global_attribute11,
            X_GLOBAL_ATTRIBUTE12                    => l_cust_profile_amt_rec.global_attribute12,
            X_GLOBAL_ATTRIBUTE13                    => l_cust_profile_amt_rec.global_attribute13,
            X_GLOBAL_ATTRIBUTE14                    => l_cust_profile_amt_rec.global_attribute14,
            X_GLOBAL_ATTRIBUTE15                    => l_cust_profile_amt_rec.global_attribute15,
            X_GLOBAL_ATTRIBUTE16                    => l_cust_profile_amt_rec.global_attribute16,
            X_GLOBAL_ATTRIBUTE17                    => l_cust_profile_amt_rec.global_attribute17,
            X_GLOBAL_ATTRIBUTE18                    => l_cust_profile_amt_rec.global_attribute18,
            X_GLOBAL_ATTRIBUTE19                    => l_cust_profile_amt_rec.global_attribute19,
            X_GLOBAL_ATTRIBUTE20                    => l_cust_profile_amt_rec.global_attribute20,
            X_GLOBAL_ATTRIBUTE_CATEGORY             => l_cust_profile_amt_rec.global_attribute_category,
            X_EXCHANGE_RATE_TYPE                    => l_cust_profile_amt_rec.exchange_rate_type,
            X_MIN_FC_INVOICE_OVERDUE_TYPE           => l_cust_profile_amt_rec.min_fc_invoice_overdue_type,
            X_MIN_FC_INVOICE_PERCENT                => l_cust_profile_amt_rec.min_fc_invoice_percent,
            X_MIN_FC_BALANCE_OVERDUE_TYPE           => l_cust_profile_amt_rec.min_fc_balance_overdue_type,
            X_MIN_FC_BALANCE_PERCENT                => l_cust_profile_amt_rec.min_fc_balance_percent,
            X_INTEREST_TYPE                         => l_cust_profile_amt_rec.interest_type,
            X_INTEREST_FIXED_AMOUNT                 => l_cust_profile_amt_rec.interest_fixed_amount,
            X_INTEREST_SCHEDULE_ID                  => l_cust_profile_amt_rec.interest_schedule_id,
            X_PENALTY_TYPE                          => l_cust_profile_amt_rec.penalty_type,
            X_PENALTY_RATE                          => l_cust_profile_amt_rec.penalty_rate,
            X_MIN_INTEREST_CHARGE                   => l_cust_profile_amt_rec.min_interest_charge,
            X_PENALTY_FIXED_AMOUNT                  => l_cust_profile_amt_rec.penalty_fixed_amount,
            X_PENALTY_SCHEDULE_ID                   => l_cust_profile_amt_rec.penalty_schedule_id
        );

        -- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(p_message=>'HZ_CUST_PROF_CLASS_AMTS_PKG.Select_Row (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        l_cust_profile_amt_rec.cust_acct_profile_amt_id := NULL;

        -- Call public API to create cust profile amount.
        create_cust_profile_amt (
            p_cust_profile_amt_rec       => l_cust_profile_amt_rec,
            x_cust_acct_profile_amt_id   => l_cust_profile_amt_rec.cust_acct_profile_amt_id,
            x_return_status              => x_return_status,
            x_msg_count                  => l_msg_count,
            x_msg_data                   => l_msg_data );

-- Bug#2219199 Procedure call added to cascade profile class amount -- multi currency

        IF x_return_status = 'S' THEN
             HZ_CREDIT_USAGES_CASCADE_PKG.cascade_credit_usage_rules (
                 l_cust_profile_amt_rec.cust_acct_profile_amt_id,
                 l_cust_profile_amt_rec.cust_account_profile_id,
                 l_profile_class_amount_id,
                 l_profile_class_id,
                 x_return_status,
                 l_msg_count,
                 l_msg_data );
        END IF;

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            ELSE
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;

    END LOOP;
    CLOSE c_profile_class_amts;

    EXCEPTION
        WHEN OTHERS THEN
            IF c_profile_class_amts%ISOPEN THEN
                CLOSE c_profile_class_amts;
            END IF;

            RAISE;
    END;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_create_customer_profile (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

END do_create_customer_profile;


/**
 * PRIVATE PROCEDURE do_update_customer_profile
 *
 * DESCRIPTION
 *     Private procedure to update customer profile.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_ACCOUNT_VALIDATE_V2PUB.validate_customer_profile
 *     HZ_CUSTOMER_PROFILES_PKG.Update_Row
 *     HZ_CUST_PROF_CLASS_AMTS_PKG.Select_Row
 *
 * ARGUMENTS
 *   IN/OUT:
 *     p_customer_profile_rec         Customer profile record. One customer account
 *                                    must have a customer profile. One account site
 *                                    use can optionally have one customer profile.
 *     p_object_version_number        Used for locking the being updated record.
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Jianying Huang      o Created.
 *
 */

PROCEDURE do_update_customer_profile (
    p_customer_profile_rec                  IN OUT NOCOPY CUSTOMER_PROFILE_REC_TYPE,
    p_object_version_number                 IN OUT NOCOPY NUMBER,
    x_return_status                         IN OUT NOCOPY VARCHAR2
) IS

    l_debug_prefix                          VARCHAR2(30) := ''; --'do_update_customer_profile'

    l_rowid                                 ROWID := NULL;
    l_is_first                              BOOLEAN := TRUE;
    l_return_status                         VARCHAR2(1);
    l_msg_count                             NUMBER;
    l_msg_data                              VARCHAR2(2000);

    l_cust_profile_amt_rec                  CUST_PROFILE_AMT_REC_TYPE;
    l_cust_account_id                       NUMBER;
    l_site_use_id                           NUMBER;
    l_profile_class_amount_id               NUMBER;
    l_profile_class_id                      NUMBER;
    l_cust_acct_profile_amt_id              NUMBER;
    l_object_version_number                 NUMBER;
    l_amt_object_version_number             NUMBER;
    l_created_by_module                     HZ_CUSTOMER_PROFILES.created_by_module%TYPE;
    l_application_id                        NUMBER;

    l_party_id                              NUMBER;
    l_last_credit_review_date               DATE;

    l_credit_hold                           VARCHAR2(30);  -- Bug 4115750

    CURSOR c_profile_class_amts IS
        SELECT PROFILE_CLASS_AMOUNT_ID
        FROM HZ_CUST_PROF_CLASS_AMTS
        WHERE PROFILE_CLASS_ID = p_customer_profile_rec.profile_class_id;

    v_action                                VARCHAR2(10);
    v_entity_code                           VARCHAR2(1);
    v_entity_id                             NUMBER(15);
    l_cons_inv_flag                         VARCHAR2(1);
    l_cons_inv_type                         VARCHAR2(30);
    l_cons_bill_level                       VARCHAR2(30);
    l_late_charge_type	                    HZ_CUSTOMER_PROFILES.LATE_CHARGE_TYPE%TYPE;
    l_late_charge_term_id           	    HZ_CUSTOMER_PROFILES.LATE_CHARGE_TERM_ID%TYPE;
    l_message_text_id           	    HZ_CUSTOMER_PROFILES.MESSAGE_TEXT_ID%TYPE;
    l_profile_class_rec                     HZ_CUST_PROFILE_CLASSES%ROWTYPE;
    l_standard_terms                        NUMBER;
    l_automatch_set_id                      NUMBER;
    l_profile_class_changed                 VARCHAR2(10);

    cursor c_acct_use_profile_dtls IS
    select cons_bill_level, cons_inv_type
    from   hz_customer_profiles
    where  cust_account_id = l_cust_account_id
    and    site_use_id is NULL
    and    cons_inv_flag = 'Y';

    ll_cons_bill_level  varchar2(30);
    ll_cons_inv_type    varchar2(30);

BEGIN

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_update_customer_profile (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Lock record.
    BEGIN
        SELECT ROWID, OBJECT_VERSION_NUMBER, CUST_ACCOUNT_ID, SITE_USE_ID,
               CREATED_BY_MODULE, APPLICATION_ID,PROFILE_CLASS_ID, PARTY_ID,
               CREDIT_HOLD , CONS_INV_FLAG, CONS_INV_TYPE, CONS_BILL_LEVEL,
               LATE_CHARGE_TYPE, LATE_CHARGE_TERM_ID, MESSAGE_TEXT_ID, STANDARD_TERMS,
               AUTOMATCH_SET_ID
        INTO l_rowid, l_object_version_number, l_cust_account_id, l_site_use_id,
             l_created_by_module, l_application_id,l_profile_class_id, l_party_id,
             l_credit_hold, l_cons_inv_flag, l_cons_inv_type, l_cons_bill_level,
             l_late_charge_type, l_late_charge_term_id, l_message_text_id, l_standard_terms,
             l_automatch_set_id
        FROM HZ_CUSTOMER_PROFILES
        WHERE CUST_ACCOUNT_PROFILE_ID = p_customer_profile_rec.cust_account_profile_id
        FOR UPDATE NOWAIT;

        IF NOT (
            ( p_object_version_number IS NULL AND l_object_version_number IS NULL ) OR
            ( p_object_version_number IS NOT NULL AND
              l_object_version_number IS NOT NULL AND
              p_object_version_number = l_object_version_number ) )
        THEN
            FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_RECORD_CHANGED' );
            FND_MESSAGE.SET_TOKEN( 'TABLE', 'hz_customer_profiles' );
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        p_object_version_number := NVL( l_object_version_number, 1 ) + 1;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_NO_RECORD' );
            FND_MESSAGE.SET_TOKEN( 'RECORD', 'customer profile' );
            FND_MESSAGE.SET_TOKEN( 'VALUE',
                NVL( TO_CHAR( p_customer_profile_rec.cust_account_profile_id ), 'null' ) );
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
    END;

    l_profile_class_changed := 'N';
   -- Bug 9188425 -Exception block is added to handle invalid Profile Class Id.
   BEGIN
    -- If the profile_class_id is changed get profile class rec into l_profile_class_rec
    IF  (p_customer_profile_rec.profile_class_id IS NOT NULL AND
         p_customer_profile_rec.profile_class_id <> FND_API.G_MISS_NUM AND
         p_customer_profile_rec.profile_class_id <> NVL(l_profile_class_id, FND_API.G_MISS_NUM)) then

        l_profile_class_changed := 'Y';

        SELECT * INTO l_profile_class_rec
        FROM     HZ_CUST_PROFILE_CLASSES
        WHERE    PROFILE_CLASS_ID = p_customer_profile_rec.profile_class_id;

        -- While changing the profile class for an existing cusromer profile record
        -- it should do the validations based on the new input parameters.
        -- If the input parameters are passed NULL or G_MISS, get the value from profile class.
        if ( p_customer_profile_rec.cons_inv_flag is NULL OR
             p_customer_profile_rec.cons_inv_flag = FND_API.G_MISS_CHAR) then
           p_customer_profile_rec.cons_inv_flag := l_profile_class_rec.cons_inv_flag;
        end if;
        if ( p_customer_profile_rec.cons_bill_level is NULL OR
             p_customer_profile_rec.cons_bill_level = FND_API.G_MISS_CHAR) then
           p_customer_profile_rec.cons_bill_level := l_profile_class_rec.cons_bill_level;
        end if;
        if ( p_customer_profile_rec.cons_inv_type is NULL OR
             p_customer_profile_rec.cons_inv_type = FND_API.G_MISS_CHAR) then
           p_customer_profile_rec.cons_inv_type := l_profile_class_rec.cons_inv_type;
        end if;
        if ( p_customer_profile_rec.standard_terms is NULL OR
             p_customer_profile_rec.standard_terms = FND_API.G_MISS_NUM) then
           p_customer_profile_rec.standard_terms := l_profile_class_rec.standard_terms;
        end if;
        --Bug9151634,9197547
        --Assigning Profile Class's value.
        if ( p_customer_profile_rec.review_cycle is NULL OR
             p_customer_profile_rec.review_cycle = FND_API.G_MISS_CHAR) then
           p_customer_profile_rec.review_cycle := l_profile_class_rec.review_cycle;
        end if;
    END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
            FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_NO_RECORD' );
            FND_MESSAGE.SET_TOKEN( 'RECORD', 'Customer Profile Class' );
            FND_MESSAGE.SET_TOKEN( 'VALUE',
                NVL( TO_CHAR( p_customer_profile_rec.profile_class_id ), 'null' ) );
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
  END;
  -- Value for cons_inv_flag should be Y or N
  if p_customer_profile_rec.cons_inv_flag is NULL then
     p_customer_profile_rec.cons_inv_flag := l_cons_inv_flag;
  elsif  p_customer_profile_rec.cons_inv_flag = FND_API.G_MISS_CHAR then
     p_customer_profile_rec.cons_inv_flag := 'N';
  end if;

  -- If user passes NULL in update set value as in database
  if p_customer_profile_rec.cons_bill_level is NULL then
     p_customer_profile_rec.cons_bill_level := l_cons_bill_level;
  end if;

  -- if cons_inv_flag is 'N', make cons_bill_level and cons_inv_type to NULL
  if p_customer_profile_rec.cons_inv_flag = 'N' then
     p_customer_profile_rec.cons_bill_level := FND_API.G_MISS_CHAR;
      p_customer_profile_rec.cons_inv_type := FND_API.G_MISS_CHAR;
  end if;

  -- Bill level is non updatable at site level
/*
  if l_site_use_id is NOT NULL AND
    p_customer_profile_rec.cons_bill_level <> FND_API.G_MISS_CHAR AND
    p_customer_profile_rec.cons_bill_level <> NVL(l_cons_bill_level, FND_API.G_MISS_CHAR) then
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_SITE_BILL_LVL_NULL');
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_ERROR;
  end if;
*/

  -- if cons_inv_flag is changed from N to Y for a site level,
  -- get the bill level from account level
  if (p_customer_profile_rec.cons_inv_flag = 'Y' and
      l_cons_inv_flag = 'N' and
      l_site_use_id is NOT NULL) then
     -- For site use profile, passed value for bill level should be NULL
     -- and it should get defaulted from account use profile.
     OPEN  c_acct_use_profile_dtls;
     FETCH c_acct_use_profile_dtls INTO ll_cons_bill_level, ll_cons_inv_type;
     IF c_acct_use_profile_dtls%NOTFOUND THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_ENABLE_ACC_BAL_FWD_BILL');
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
     END IF;
     p_customer_profile_rec.cons_bill_level := ll_cons_bill_level;
     if ( p_customer_profile_rec.cons_inv_type is NULL OR
          p_customer_profile_rec.cons_inv_type = FND_API.G_MISS_CHAR) then
        p_customer_profile_rec.cons_inv_type := ll_cons_inv_type;
     end if;
     CLOSE c_acct_use_profile_dtls;
  end if;

  -- If user passes NULL in update set value as in database
  if p_customer_profile_rec.cons_inv_type is NULL then
     p_customer_profile_rec.cons_inv_type := l_cons_inv_type;
  end if;

 -- Added the below IF condition for Balance Forwarded Billing
 -- When cons_inv_flag is changed from 'N' to 'Y' or 'Y' to 'N'
 -- and profile class is not changed
 -- update the standard_terms of the profile to null
 -- Bug 8349169 -In NVL function G_MISS_CHAR changed to 'N', null will consider as 'N'
 if p_customer_profile_rec.cons_inv_flag IS NOT NULL AND
    p_customer_profile_rec.cons_inv_flag <> FND_API.G_MISS_CHAR AND
    p_customer_profile_rec.cons_inv_flag <> NVL(l_cons_inv_flag, 'N') AND
    l_profile_class_changed = 'N' then
       if (p_customer_profile_rec.standard_terms is NULL OR
           p_customer_profile_rec.standard_terms = nvl(l_standard_terms,-999111))
       then
       --l_standard_terms
       p_customer_profile_rec.standard_terms := FND_API.G_MISS_NUM;
       end if;
 end if;

   -- if late charge payment term or late charge type or message_text_id is NULL, get value from database.
   if p_customer_profile_rec.late_charge_term_id is NULL then
      p_customer_profile_rec.late_charge_term_id := l_late_charge_term_id;
   elsif p_customer_profile_rec.late_charge_term_id = FND_API.G_MISS_NUM then
      p_customer_profile_rec.late_charge_term_id := l_profile_class_rec.late_charge_term_id;
   end if;
   if p_customer_profile_rec.late_charge_type is NULL then
      p_customer_profile_rec.late_charge_type := l_late_charge_type;
   elsif p_customer_profile_rec.late_charge_type = FND_API.G_MISS_CHAR then
      p_customer_profile_rec.late_charge_type := l_profile_class_rec.late_charge_type;
   end if;
   if p_customer_profile_rec.message_text_id is NULL then
      p_customer_profile_rec.message_text_id := l_message_text_id;
   elsif p_customer_profile_rec.message_text_id = FND_API.G_MISS_NUM then
      p_customer_profile_rec.message_text_id := l_profile_class_rec.message_text_id;
   end if;

   if p_customer_profile_rec.late_charge_type = 'ADJ' then
      p_customer_profile_rec.late_charge_term_id := FND_API.G_MISS_NUM;
      p_customer_profile_rec.message_text_id     := FND_API.G_MISS_NUM;
   end if;

    -- Validate customer profile record
    HZ_ACCOUNT_VALIDATE_V2PUB.validate_customer_profile (
        p_create_update_flag                    => 'U',
        p_customer_profile_rec                  => p_customer_profile_rec,
        p_rowid                                 => l_rowid,
        x_return_status                         => x_return_status );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Added rounding of payment_grace_days to integer for Late charge project.
    IF (p_customer_profile_rec.payment_grace_days is NOT NULL AND
        p_customer_profile_rec.payment_grace_days <> FND_API.G_MISS_NUM) then
           p_customer_profile_rec.payment_grace_days := ROUND(p_customer_profile_rec.payment_grace_days,0);
    END IF;

    -- Added rounding of interest_period_days to integer for Late charge project.
    IF (p_customer_profile_rec.interest_period_days is NOT NULL AND
        p_customer_profile_rec.interest_period_days <> FND_API.G_MISS_NUM) then
           p_customer_profile_rec.interest_period_days := ROUND(p_customer_profile_rec.interest_period_days,0);
    END IF;

    -- Add logic for global holds
    IF p_customer_profile_rec.credit_hold is not null THEN   --Bug5606895
    IF nvl(l_credit_hold,'N') <> nvl(p_customer_profile_rec.credit_hold,'N') THEN
      if p_customer_profile_rec.credit_hold = 'Y' THEN
        v_action := 'APPLY';
      ELSE
        v_action := 'RELEASE';
      END IF;
      IF l_site_use_id IS NULL THEN
        v_entity_code := 'C';
        v_entity_id := l_cust_account_id;
      ELSE
        v_entity_code := 'S';
        v_entity_id := l_site_use_id;
      END IF;

      -- Debug info.
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
          hz_utility_v2pub.debug(p_message=>'Before call OE_HOLDS... '||
                                            'v_action = '||v_action||' '||
                                            'v_entity_code = '||v_entity_code||' '||
                                            'v_entity_id = '||v_entity_id,
                                 p_prefix=>l_debug_prefix,
                                 p_msg_level=>fnd_log.level_statement);
      END IF;

      BEGIN
        OE_Holds_PUB.Process_Holds (
          p_api_version         => 1.0,
          p_init_msg_list       => FND_API.G_FALSE,
          p_hold_entity_code    => v_entity_code,
          p_hold_entity_id      => v_entity_id,
          p_hold_id             => 1,
          p_release_reason_code => 'AR_AUTOMATIC',
          p_action              => v_action,
          x_return_status       => l_return_status,
          x_msg_count           => l_msg_count,
          x_msg_data            => l_msg_data);

          -- Debug info.
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'After call OE_HOLDS... '||
                                              'l_return_status = '||l_return_status||' '||
                                              'l_msg_count = '||l_msg_count||' '||
                                              'l_msg_data = '||l_msg_data,
                                   p_prefix=>l_debug_prefix,
                                   p_msg_level=>fnd_log.level_statement);
          END IF;
      EXCEPTION
        WHEN OTHERS THEN
          -- Debug info.
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'Exception raised from OE_HOLDS... '||SQLERRM,
                                   p_prefix=>l_debug_prefix,
                                   p_msg_level=>fnd_log.level_statement);
          END IF;

          l_return_status := 'S';
      END;

      --
      -- only raise unexpected error
      --
      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;
    END IF; -- Bug 5606895
    -- Call table-handler.
    -- Table_handler is taking care of default customer profile to profile class.

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'HZ_CUSTOMER_PROFILES_PKG.Update_Row (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    HZ_CUSTOMER_PROFILES_PKG.Update_Row (
        X_Rowid                                 => l_rowid,
        X_CUST_ACCOUNT_PROFILE_ID               => p_customer_profile_rec.cust_account_profile_id,
        X_CUST_ACCOUNT_ID                       => p_customer_profile_rec.cust_account_id,
        X_STATUS                                => p_customer_profile_rec.status,
        X_COLLECTOR_ID                          => p_customer_profile_rec.collector_id,
        X_CREDIT_ANALYST_ID                     => p_customer_profile_rec.credit_analyst_id,
        X_CREDIT_CHECKING                       => p_customer_profile_rec.credit_checking,
        X_NEXT_CREDIT_REVIEW_DATE               => p_customer_profile_rec.next_credit_review_date,
        X_TOLERANCE                             => p_customer_profile_rec.tolerance,
        X_DISCOUNT_TERMS                        => p_customer_profile_rec.discount_terms,
        X_DUNNING_LETTERS                       => p_customer_profile_rec.dunning_letters,
        X_INTEREST_CHARGES                      => p_customer_profile_rec.interest_charges,
        X_SEND_STATEMENTS                       => p_customer_profile_rec.send_statements,
        X_CREDIT_BALANCE_STATEMENTS             => p_customer_profile_rec.credit_balance_statements,
        X_CREDIT_HOLD                           => p_customer_profile_rec.credit_hold,
        X_PROFILE_CLASS_ID                      => p_customer_profile_rec.profile_class_id,
        X_SITE_USE_ID                           => p_customer_profile_rec.site_use_id,
        X_CREDIT_RATING                         => p_customer_profile_rec.credit_rating,
        X_RISK_CODE                             => p_customer_profile_rec.risk_code,
        X_STANDARD_TERMS                        => p_customer_profile_rec.standard_terms,
        X_OVERRIDE_TERMS                        => p_customer_profile_rec.override_terms,
        X_DUNNING_LETTER_SET_ID                 => p_customer_profile_rec.dunning_letter_set_id,
        X_INTEREST_PERIOD_DAYS                  => p_customer_profile_rec.interest_period_days,
        X_PAYMENT_GRACE_DAYS                    => p_customer_profile_rec.payment_grace_days,
        X_DISCOUNT_GRACE_DAYS                   => p_customer_profile_rec.discount_grace_days,
        X_STATEMENT_CYCLE_ID                    => p_customer_profile_rec.statement_cycle_id,
        X_ACCOUNT_STATUS                        => p_customer_profile_rec.account_status,
        X_PERCENT_COLLECTABLE                   => p_customer_profile_rec.percent_collectable,
        X_AUTOCASH_HIERARCHY_ID                 => p_customer_profile_rec.autocash_hierarchy_id,
        X_ATTRIBUTE_CATEGORY                    => p_customer_profile_rec.attribute_category,
        X_ATTRIBUTE1                            => p_customer_profile_rec.attribute1,
        X_ATTRIBUTE2                            => p_customer_profile_rec.attribute2,
        X_ATTRIBUTE3                            => p_customer_profile_rec.attribute3,
        X_ATTRIBUTE4                            => p_customer_profile_rec.attribute4,
        X_ATTRIBUTE5                            => p_customer_profile_rec.attribute5,
        X_ATTRIBUTE6                            => p_customer_profile_rec.attribute6,
        X_ATTRIBUTE7                            => p_customer_profile_rec.attribute7,
        X_ATTRIBUTE8                            => p_customer_profile_rec.attribute8,
        X_ATTRIBUTE9                            => p_customer_profile_rec.attribute9,
        X_ATTRIBUTE10                           => p_customer_profile_rec.attribute10,
        X_ATTRIBUTE11                           => p_customer_profile_rec.attribute11,
        X_ATTRIBUTE12                           => p_customer_profile_rec.attribute12,
        X_ATTRIBUTE13                           => p_customer_profile_rec.attribute13,
        X_ATTRIBUTE14                           => p_customer_profile_rec.attribute14,
        X_ATTRIBUTE15                           => p_customer_profile_rec.attribute15,
        X_AUTO_REC_INCL_DISPUTED_FLAG           => p_customer_profile_rec.auto_rec_incl_disputed_flag,
        X_TAX_PRINTING_OPTION                   => p_customer_profile_rec.tax_printing_option,
        X_CHARGE_ON_FINANCE_CHARGE_FG           => p_customer_profile_rec.charge_on_finance_charge_flag,
        X_GROUPING_RULE_ID                      => p_customer_profile_rec.grouping_rule_id,
        X_CLEARING_DAYS                         => p_customer_profile_rec.clearing_days,
        X_JGZZ_ATTRIBUTE_CATEGORY               => p_customer_profile_rec.jgzz_attribute_category,
        X_JGZZ_ATTRIBUTE1                       => p_customer_profile_rec.jgzz_attribute1,
        X_JGZZ_ATTRIBUTE2                       => p_customer_profile_rec.jgzz_attribute2,
        X_JGZZ_ATTRIBUTE3                       => p_customer_profile_rec.jgzz_attribute3,
        X_JGZZ_ATTRIBUTE4                       => p_customer_profile_rec.jgzz_attribute4,
        X_JGZZ_ATTRIBUTE5                       => p_customer_profile_rec.jgzz_attribute5,
        X_JGZZ_ATTRIBUTE6                       => p_customer_profile_rec.jgzz_attribute6,
        X_JGZZ_ATTRIBUTE7                       => p_customer_profile_rec.jgzz_attribute7,
        X_JGZZ_ATTRIBUTE8                       => p_customer_profile_rec.jgzz_attribute8,
        X_JGZZ_ATTRIBUTE9                       => p_customer_profile_rec.jgzz_attribute9,
        X_JGZZ_ATTRIBUTE10                      => p_customer_profile_rec.jgzz_attribute10,
        X_JGZZ_ATTRIBUTE11                      => p_customer_profile_rec.jgzz_attribute11,
        X_JGZZ_ATTRIBUTE12                      => p_customer_profile_rec.jgzz_attribute12,
        X_JGZZ_ATTRIBUTE13                      => p_customer_profile_rec.jgzz_attribute13,
        X_JGZZ_ATTRIBUTE14                      => p_customer_profile_rec.jgzz_attribute14,
        X_JGZZ_ATTRIBUTE15                      => p_customer_profile_rec.jgzz_attribute15,
        X_GLOBAL_ATTRIBUTE1                     => p_customer_profile_rec.global_attribute1,
        X_GLOBAL_ATTRIBUTE2                     => p_customer_profile_rec.global_attribute2,
        X_GLOBAL_ATTRIBUTE3                     => p_customer_profile_rec.global_attribute3,
        X_GLOBAL_ATTRIBUTE4                     => p_customer_profile_rec.global_attribute4,
        X_GLOBAL_ATTRIBUTE5                     => p_customer_profile_rec.global_attribute5,
        X_GLOBAL_ATTRIBUTE6                     => p_customer_profile_rec.global_attribute6,
        X_GLOBAL_ATTRIBUTE7                     => p_customer_profile_rec.global_attribute7,
        X_GLOBAL_ATTRIBUTE8                     => p_customer_profile_rec.global_attribute8,
        X_GLOBAL_ATTRIBUTE9                     => p_customer_profile_rec.global_attribute9,
        X_GLOBAL_ATTRIBUTE10                    => p_customer_profile_rec.global_attribute10,
        X_GLOBAL_ATTRIBUTE11                    => p_customer_profile_rec.global_attribute11,
        X_GLOBAL_ATTRIBUTE12                    => p_customer_profile_rec.global_attribute12,
        X_GLOBAL_ATTRIBUTE13                    => p_customer_profile_rec.global_attribute13,
        X_GLOBAL_ATTRIBUTE14                    => p_customer_profile_rec.global_attribute14,
        X_GLOBAL_ATTRIBUTE15                    => p_customer_profile_rec.global_attribute15,
        X_GLOBAL_ATTRIBUTE16                    => p_customer_profile_rec.global_attribute16,
        X_GLOBAL_ATTRIBUTE17                    => p_customer_profile_rec.global_attribute17,
        X_GLOBAL_ATTRIBUTE18                    => p_customer_profile_rec.global_attribute18,
        X_GLOBAL_ATTRIBUTE19                    => p_customer_profile_rec.global_attribute19,
        X_GLOBAL_ATTRIBUTE20                    => p_customer_profile_rec.global_attribute20,
        X_GLOBAL_ATTRIBUTE_CATEGORY             => p_customer_profile_rec.global_attribute_category,
        X_CONS_INV_FLAG                         => p_customer_profile_rec.cons_inv_flag,
        X_CONS_INV_TYPE                         => p_customer_profile_rec.cons_inv_type,
        X_AUTOCASH_HIERARCHY_ID_ADR             => p_customer_profile_rec.autocash_hierarchy_id_for_adr,
        X_LOCKBOX_MATCHING_OPTION               => p_customer_profile_rec.lockbox_matching_option,
        X_OBJECT_VERSION_NUMBER                 => p_object_version_number,
        X_CREATED_BY_MODULE                     => p_customer_profile_rec.created_by_module,
        X_APPLICATION_ID                        => p_customer_profile_rec.application_id,
        X_review_cycle                          => p_customer_profile_rec.review_cycle,
        X_last_credit_review_date               => p_customer_profile_rec.last_credit_review_date,
        X_party_id                              => p_customer_profile_rec.party_id,
        X_CREDIT_CLASSIFICATION                 => p_customer_profile_rec.credit_classification,
        X_CONS_BILL_LEVEL                       => p_customer_profile_rec.cons_bill_level,
        X_LATE_CHARGE_CALCULATION_TRX           => p_customer_profile_rec.late_charge_calculation_trx,
        X_CREDIT_ITEMS_FLAG                     => p_customer_profile_rec.credit_items_flag,
        X_DISPUTED_TRANSACTIONS_FLAG            => p_customer_profile_rec.disputed_transactions_flag,
        X_LATE_CHARGE_TYPE                      => p_customer_profile_rec.late_charge_type,
        X_LATE_CHARGE_TERM_ID                   => p_customer_profile_rec.late_charge_term_id,
        X_INTEREST_CALCULATION_PERIOD           => p_customer_profile_rec.interest_calculation_period,
        X_HOLD_CHARGED_INVOICES_FLAG            => p_customer_profile_rec.hold_charged_invoices_flag,
        X_MESSAGE_TEXT_ID                       => p_customer_profile_rec.message_text_id,
        X_MULTIPLE_INTEREST_RATES_FLAG          => p_customer_profile_rec.multiple_interest_rates_flag,
        X_CHARGE_BEGIN_DATE                     => p_customer_profile_rec.charge_begin_date,
        X_AUTOMATCH_SET_ID                      => p_customer_profile_rec.automatch_set_id
    );

--raji

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'HZ_CUSTOMER_PROFILES_PKG.Update_Row (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- When the bill_level at the account profile is changed from 'ACCOUNT' to 'SITE',
    -- the bill_level for all the associated  BFB enabled site uses should be
    -- updated to 'SITE' and the rest of the BFB attributes can be updated
    -- while updating the individual site use records.
    if (l_site_use_id is NULL and
        p_customer_profile_rec.cons_bill_level = 'SITE' and
        l_cons_bill_level = 'ACCOUNT') then
        begin
           update HZ_CUSTOMER_PROFILES
           set    cons_bill_level = 'SITE'
           where  site_use_id is NOT NULL
           and    cons_inv_flag = 'Y'
           and    cust_account_id = l_cust_account_id;
        exception when NO_DATA_FOUND then
           null;
        end;
    end if;

    -- Update profile amt.

    -- If profile_class_id has been changed, we have to update/copy the profile
    -- amount under new profile class. Please note, profile_class_id cannot be
    -- updated to null.

    IF (p_customer_profile_rec.profile_class_id IS NOT NULL
        AND p_customer_profile_rec.profile_class_id <> l_profile_class_id )
    THEN
    BEGIN

        -- could have several records in profile_class_amts for a given
        -- profile_class_id.

        OPEN c_profile_class_amts;
        LOOP
            FETCH c_profile_class_amts INTO l_profile_class_amount_id;
            EXIT WHEN c_profile_class_amts%NOTFOUND;

            -- Setup profile amount record if it is the first run.
            IF l_is_first THEN
                -- cust_account_id, site_use_id are non-updateable.
                -- Setup profile amount record
                l_cust_profile_amt_rec.cust_account_profile_id := p_customer_profile_rec.cust_account_profile_id;
                l_cust_profile_amt_rec.cust_account_id := l_cust_account_id;
                l_cust_profile_amt_rec.site_use_id := l_site_use_id;

                l_is_first := FALSE;
            END IF;

            -- Debug info.
            IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(p_message=>'HZ_CUST_PROF_CLASS_AMTS_PKG.Select_Row (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
            END IF;

            -- Call table-handler
            HZ_CUST_PROF_CLASS_AMTS_PKG.Select_Row (
                X_PROFILE_CLASS_AMOUNT_ID               => l_profile_class_amount_id,
                X_PROFILE_CLASS_ID                      => l_profile_class_id,
                X_CURRENCY_CODE                         => l_cust_profile_amt_rec.currency_code,
                X_TRX_CREDIT_LIMIT                      => l_cust_profile_amt_rec.trx_credit_limit,
                X_OVERALL_CREDIT_LIMIT                  => l_cust_profile_amt_rec.overall_credit_limit,
                X_MIN_DUNNING_AMOUNT                    => l_cust_profile_amt_rec.min_dunning_amount,
                X_MAX_INTEREST_CHARGE                   => l_cust_profile_amt_rec.max_interest_charge,
                X_MIN_STATEMENT_AMOUNT                  => l_cust_profile_amt_rec.min_statement_amount,
                X_AUTO_REC_MIN_RECEIPT_AMOUNT           => l_cust_profile_amt_rec.auto_rec_min_receipt_amount,
                X_ATTRIBUTE_CATEGORY                    => l_cust_profile_amt_rec.attribute_category,
                X_ATTRIBUTE1                            => l_cust_profile_amt_rec.attribute1,
                X_ATTRIBUTE2                            => l_cust_profile_amt_rec.attribute2,
                X_ATTRIBUTE3                            => l_cust_profile_amt_rec.attribute3,
                X_ATTRIBUTE4                            => l_cust_profile_amt_rec.attribute4,
                X_ATTRIBUTE5                            => l_cust_profile_amt_rec.attribute5,
                X_ATTRIBUTE6                            => l_cust_profile_amt_rec.attribute6,
                X_ATTRIBUTE7                            => l_cust_profile_amt_rec.attribute7,
                X_ATTRIBUTE8                            => l_cust_profile_amt_rec.attribute8,
                X_ATTRIBUTE9                            => l_cust_profile_amt_rec.attribute9,
                X_ATTRIBUTE10                           => l_cust_profile_amt_rec.attribute10,
                X_ATTRIBUTE11                           => l_cust_profile_amt_rec.attribute11,
                X_ATTRIBUTE12                           => l_cust_profile_amt_rec.attribute12,
                X_ATTRIBUTE13                           => l_cust_profile_amt_rec.attribute13,
                X_ATTRIBUTE14                           => l_cust_profile_amt_rec.attribute14,
                X_ATTRIBUTE15                           => l_cust_profile_amt_rec.attribute15,
                X_INTEREST_RATE                         => l_cust_profile_amt_rec.interest_rate,
                X_MIN_FC_BALANCE_AMOUNT                 => l_cust_profile_amt_rec.min_fc_balance_amount,
                X_MIN_FC_INVOICE_AMOUNT                 => l_cust_profile_amt_rec.min_fc_invoice_amount,
                X_MIN_DUNNING_INVOICE_AMOUNT            => l_cust_profile_amt_rec.min_dunning_invoice_amount,
                X_EXPIRATION_DATE                       => l_cust_profile_amt_rec.expiration_date,
                X_JGZZ_ATTRIBUTE_CATEGORY               => l_cust_profile_amt_rec.jgzz_attribute_category,
                X_JGZZ_ATTRIBUTE1                       => l_cust_profile_amt_rec.jgzz_attribute1,
                X_JGZZ_ATTRIBUTE2                       => l_cust_profile_amt_rec.jgzz_attribute2,
                X_JGZZ_ATTRIBUTE3                       => l_cust_profile_amt_rec.jgzz_attribute3,
                X_JGZZ_ATTRIBUTE4                       => l_cust_profile_amt_rec.jgzz_attribute4,
                X_JGZZ_ATTRIBUTE5                       => l_cust_profile_amt_rec.jgzz_attribute5,
                X_JGZZ_ATTRIBUTE6                       => l_cust_profile_amt_rec.jgzz_attribute6,
                X_JGZZ_ATTRIBUTE7                       => l_cust_profile_amt_rec.jgzz_attribute7,
                X_JGZZ_ATTRIBUTE8                       => l_cust_profile_amt_rec.jgzz_attribute8,
                X_JGZZ_ATTRIBUTE9                       => l_cust_profile_amt_rec.jgzz_attribute9,
                X_JGZZ_ATTRIBUTE10                      => l_cust_profile_amt_rec.jgzz_attribute10,
                X_JGZZ_ATTRIBUTE11                      => l_cust_profile_amt_rec.jgzz_attribute11,
                X_JGZZ_ATTRIBUTE12                      => l_cust_profile_amt_rec.jgzz_attribute12,
                X_JGZZ_ATTRIBUTE13                      => l_cust_profile_amt_rec.jgzz_attribute13,
                X_JGZZ_ATTRIBUTE14                      => l_cust_profile_amt_rec.jgzz_attribute14,
                X_JGZZ_ATTRIBUTE15                      => l_cust_profile_amt_rec.jgzz_attribute15,
                X_GLOBAL_ATTRIBUTE1                     => l_cust_profile_amt_rec.global_attribute1,
                X_GLOBAL_ATTRIBUTE2                     => l_cust_profile_amt_rec.global_attribute2,
                X_GLOBAL_ATTRIBUTE3                     => l_cust_profile_amt_rec.global_attribute3,
                X_GLOBAL_ATTRIBUTE4                     => l_cust_profile_amt_rec.global_attribute4,
                X_GLOBAL_ATTRIBUTE5                     => l_cust_profile_amt_rec.global_attribute5,
                X_GLOBAL_ATTRIBUTE6                     => l_cust_profile_amt_rec.global_attribute6,
                X_GLOBAL_ATTRIBUTE7                     => l_cust_profile_amt_rec.global_attribute7,
                X_GLOBAL_ATTRIBUTE8                     => l_cust_profile_amt_rec.global_attribute8,
                X_GLOBAL_ATTRIBUTE9                     => l_cust_profile_amt_rec.global_attribute9,
                X_GLOBAL_ATTRIBUTE10                    => l_cust_profile_amt_rec.global_attribute10,
                X_GLOBAL_ATTRIBUTE11                    => l_cust_profile_amt_rec.global_attribute11,
                X_GLOBAL_ATTRIBUTE12                    => l_cust_profile_amt_rec.global_attribute12,
                X_GLOBAL_ATTRIBUTE13                    => l_cust_profile_amt_rec.global_attribute13,
                X_GLOBAL_ATTRIBUTE14                    => l_cust_profile_amt_rec.global_attribute14,
                X_GLOBAL_ATTRIBUTE15                    => l_cust_profile_amt_rec.global_attribute15,
                X_GLOBAL_ATTRIBUTE16                    => l_cust_profile_amt_rec.global_attribute16,
                X_GLOBAL_ATTRIBUTE17                    => l_cust_profile_amt_rec.global_attribute17,
                X_GLOBAL_ATTRIBUTE18                    => l_cust_profile_amt_rec.global_attribute18,
                X_GLOBAL_ATTRIBUTE19                    => l_cust_profile_amt_rec.global_attribute19,
                X_GLOBAL_ATTRIBUTE20                    => l_cust_profile_amt_rec.global_attribute20,
                X_GLOBAL_ATTRIBUTE_CATEGORY             => l_cust_profile_amt_rec.global_attribute_category,
                X_EXCHANGE_RATE_TYPE                    => l_cust_profile_amt_rec.exchange_rate_type,
                X_MIN_FC_INVOICE_OVERDUE_TYPE           => l_cust_profile_amt_rec.min_fc_invoice_overdue_type,
                X_MIN_FC_INVOICE_PERCENT                => l_cust_profile_amt_rec.min_fc_invoice_percent,
                X_MIN_FC_BALANCE_OVERDUE_TYPE           => l_cust_profile_amt_rec.min_fc_balance_overdue_type,
                X_MIN_FC_BALANCE_PERCENT                => l_cust_profile_amt_rec.min_fc_balance_percent,
                X_INTEREST_TYPE                         => l_cust_profile_amt_rec.interest_type,
                X_INTEREST_FIXED_AMOUNT                 => l_cust_profile_amt_rec.interest_fixed_amount,
                X_INTEREST_SCHEDULE_ID                  => l_cust_profile_amt_rec.interest_schedule_id,
                X_PENALTY_TYPE                          => l_cust_profile_amt_rec.penalty_type,
                X_PENALTY_RATE                          => l_cust_profile_amt_rec.penalty_rate,
                X_MIN_INTEREST_CHARGE                   => l_cust_profile_amt_rec.min_interest_charge,
                X_PENALTY_FIXED_AMOUNT                  => l_cust_profile_amt_rec.penalty_fixed_amount,
                X_PENALTY_SCHEDULE_ID                   => l_cust_profile_amt_rec.penalty_schedule_id
            );

            -- Debug info.
            IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(p_message=>'HZ_CUST_PROF_CLASS_AMTS_PKG.Select_Row (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
            END IF;

            -- Check if a currency code already exist for this profile.
            -- If yes, update that amount. If not, create a new amount.

            BEGIN
                SELECT CUST_ACCT_PROFILE_AMT_ID, OBJECT_VERSION_NUMBER
                INTO l_cust_acct_profile_amt_id, l_amt_object_version_number
                FROM HZ_CUST_PROFILE_AMTS
                WHERE CUST_ACCOUNT_PROFILE_ID = p_customer_profile_rec.cust_account_profile_id
                AND CURRENCY_CODE = l_cust_profile_amt_rec.currency_code;

                -- The currency exist for the customer profile. Update it.
                l_cust_profile_amt_rec.cust_acct_profile_amt_id := l_cust_acct_profile_amt_id;

                -- Call public API to update cust profile amount.
                update_cust_profile_amt (
                    p_cust_profile_amt_rec       => l_cust_profile_amt_rec,
                    p_object_version_number      => l_amt_object_version_number,
                    x_return_status              => x_return_status,
                    x_msg_count                  => l_msg_count,
                    x_msg_data                   => l_msg_data );

                hz_credit_usages_cascade_pkg.delete_credit_usages(
                    l_cust_profile_amt_rec.cust_acct_profile_amt_id
                    , x_return_status
                    , l_msg_count
                    , l_msg_data);

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    -- The currency does not exist, create new amount
                    l_cust_profile_amt_rec.cust_acct_profile_amt_id := NULL;

                    IF p_customer_profile_rec.created_by_module IS NOT NULL
                       and p_customer_profile_rec.created_by_module <> fnd_api.g_miss_char THEN
                        l_cust_profile_amt_rec.created_by_module := p_customer_profile_rec.created_by_module;
                    ELSE
                        --  if l_created_by_module is null, default to TCA_V2_API
                        l_cust_profile_amt_rec.created_by_module := nvl(l_created_by_module, 'TCA_V2_API');
                    END IF;

                    IF p_customer_profile_rec.application_id IS NOT NULL THEN
                        l_cust_profile_amt_rec.application_id := p_customer_profile_rec.application_id;
                    ELSE
                        l_cust_profile_amt_rec.application_id := l_application_id;
                    END IF;

                    -- Call public API to create cust profile amount.
                    create_cust_profile_amt (
                        p_cust_profile_amt_rec       => l_cust_profile_amt_rec,
                        x_cust_acct_profile_amt_id   => l_cust_profile_amt_rec.cust_acct_profile_amt_id,
                        x_return_status              => x_return_status,
                        x_msg_count                  => l_msg_count,
                        x_msg_data                   => l_msg_data );
            END;

            IF x_return_status = 'S' THEN
                 HZ_CREDIT_USAGES_CASCADE_PKG.cascade_credit_usage_rules (
                     l_cust_profile_amt_rec.cust_acct_profile_amt_id,
                     l_cust_profile_amt_rec.cust_account_profile_id,
                     l_profile_class_amount_id,
                     l_profile_class_id,
                     x_return_status,
                     l_msg_count,
                     l_msg_data );
            END IF;


            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                    RAISE FND_API.G_EXC_ERROR;
                ELSE
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
            END IF;

        END LOOP;
        CLOSE c_profile_class_amts;

    EXCEPTION
        WHEN OTHERS THEN
            IF c_profile_class_amts%ISOPEN THEN
                CLOSE c_profile_class_amts;
            END IF;

            RAISE;
    END;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_update_customer_profile (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

END do_update_customer_profile;

/**
 * PRIVATE PROCEDURE do_create_cust_profile_amt
 *
 * DESCRIPTION
 *     Private procedure to create customer profile amount.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_ACCOUNT_VALIDATE_V2PUB.validate_cust_profile_amt
 *     HZ_CUST_PROFILE_AMTS_PKG.Insert_Row
 *
 * ARGUMENTS
 *   IN:
 *     p_check_foreign_key            If do foreign key checking on cust_account_id
 *                                    and cust_account_profile_id or not. Defaut value
 *                                    is FND_API.G_TRUE, which means API will do foreign
 *                                    key checking on these 2 columns.
 *   IN/OUT:
 *     p_cust_profile_amt_rec         Customer profile amount record.
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *   OUT:
 *     x_cust_acct_profile_amt_id     Customer account profile amount ID.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Jianying Huang      o Created.
 *
 */

PROCEDURE do_create_cust_profile_amt (
    p_check_foreign_key                     IN     VARCHAR2,
    p_cust_profile_amt_rec                  IN OUT NOCOPY CUST_PROFILE_AMT_REC_TYPE,
    x_cust_acct_profile_amt_id              OUT NOCOPY    NUMBER,
    x_return_status                         IN OUT NOCOPY VARCHAR2
) IS

    l_debug_prefix                          VARCHAR2(30) := ''; --'do_create_cust_profile_amt'
    l_site_use_id                           HZ_CUST_PROFILE_AMTS.SITE_USE_ID%TYPE;
BEGIN

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_create_cust_profile_amt (+)' ,
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Validate cust profile amt record
    HZ_ACCOUNT_VALIDATE_V2PUB.validate_cust_profile_amt (
        p_create_update_flag                    => 'C',
        p_check_foreign_key                     => p_check_foreign_key,
        p_cust_profile_amt_rec                  => p_cust_profile_amt_rec,
        p_rowid                                 => NULL,
        x_return_status                         => x_return_status );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Added rounding of min_fc_invoice_amount, min_fc_balance_amount, min_interest_charge,
    -- min_interest_charge, interest_fixed_amount and penalty_fixed_amount to 2 decimal places for Late charge project.
    IF p_cust_profile_amt_rec.min_fc_invoice_amount is NOT NULL then
       p_cust_profile_amt_rec.min_fc_invoice_amount := ROUND(p_cust_profile_amt_rec.min_fc_invoice_amount,2);
    END IF;
    IF p_cust_profile_amt_rec.min_fc_balance_amount is NOT NULL then
       p_cust_profile_amt_rec.min_fc_balance_amount := ROUND(p_cust_profile_amt_rec.min_fc_balance_amount,2);
    END IF;
    IF p_cust_profile_amt_rec.max_interest_charge is NOT NULL then
       p_cust_profile_amt_rec.max_interest_charge := ROUND(p_cust_profile_amt_rec.max_interest_charge,2);
    END IF;
    IF p_cust_profile_amt_rec.min_interest_charge is NOT NULL then
       p_cust_profile_amt_rec.min_interest_charge := ROUND(p_cust_profile_amt_rec.min_interest_charge,2);
    END IF;
    IF p_cust_profile_amt_rec.interest_fixed_amount is NOT NULL then
       p_cust_profile_amt_rec.interest_fixed_amount := ROUND(p_cust_profile_amt_rec.interest_fixed_amount,2);
    END IF;
    IF p_cust_profile_amt_rec.penalty_fixed_amount is NOT NULL then
       p_cust_profile_amt_rec.penalty_fixed_amount := ROUND(p_cust_profile_amt_rec.penalty_fixed_amount,2);
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'HZ_CUST_PROFILE_AMTS_PKG.Insert_Row (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Bug 6472676
    -- Changed do_create_cust_profile_amt Procudure to get SITE_USE_ID value from Customer Profiles if
    -- Parameter CUST_PROFILE_AMT_REC containing null value in SITE_USE_ID.

       IF p_cust_profile_amt_rec.site_use_id IS NULL OR p_CUST_PROFILE_AMT_REC.site_use_id = FND_API.G_MISS_NUM THEN
   	   BEGIN
	     SELECT site_use_id
	       INTO l_site_use_id
           FROM   hz_customer_profiles
           WHERE  cust_account_id         = p_cust_profile_amt_rec.cust_account_id
           AND    cust_account_profile_id = p_cust_profile_amt_rec.cust_account_profile_id ;

           p_cust_profile_amt_rec.site_use_id := l_site_use_id ;

         EXCEPTION
         WHEN OTHERS THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END;
	 END IF;

    -- Call table-handler.
    HZ_CUST_PROFILE_AMTS_PKG.Insert_Row (
        X_CUST_ACCT_PROFILE_AMT_ID              => p_cust_profile_amt_rec.cust_acct_profile_amt_id,
        X_CUST_ACCOUNT_PROFILE_ID               => p_cust_profile_amt_rec.cust_account_profile_id,
        X_CURRENCY_CODE                         => p_cust_profile_amt_rec.currency_code,
        X_TRX_CREDIT_LIMIT                      => p_cust_profile_amt_rec.trx_credit_limit,
        X_OVERALL_CREDIT_LIMIT                  => p_cust_profile_amt_rec.overall_credit_limit,
        X_MIN_DUNNING_AMOUNT                    => p_cust_profile_amt_rec.min_dunning_amount,
        X_MIN_DUNNING_INVOICE_AMOUNT            => p_cust_profile_amt_rec.min_dunning_invoice_amount,
        X_MAX_INTEREST_CHARGE                   => p_cust_profile_amt_rec.max_interest_charge,
        X_MIN_STATEMENT_AMOUNT                  => p_cust_profile_amt_rec.min_statement_amount,
        X_AUTO_REC_MIN_RECEIPT_AMOUNT           => p_cust_profile_amt_rec.auto_rec_min_receipt_amount,
        X_INTEREST_RATE                         => p_cust_profile_amt_rec.interest_rate,
        X_ATTRIBUTE_CATEGORY                    => p_cust_profile_amt_rec.attribute_category,
        X_ATTRIBUTE1                            => p_cust_profile_amt_rec.attribute1,
        X_ATTRIBUTE2                            => p_cust_profile_amt_rec.attribute2,
        X_ATTRIBUTE3                            => p_cust_profile_amt_rec.attribute3,
        X_ATTRIBUTE4                            => p_cust_profile_amt_rec.attribute4,
        X_ATTRIBUTE5                            => p_cust_profile_amt_rec.attribute5,
        X_ATTRIBUTE6                            => p_cust_profile_amt_rec.attribute6,
        X_ATTRIBUTE7                            => p_cust_profile_amt_rec.attribute7,
        X_ATTRIBUTE8                            => p_cust_profile_amt_rec.attribute8,
        X_ATTRIBUTE9                            => p_cust_profile_amt_rec.attribute9,
        X_ATTRIBUTE10                           => p_cust_profile_amt_rec.attribute10,
        X_ATTRIBUTE11                           => p_cust_profile_amt_rec.attribute11,
        X_ATTRIBUTE12                           => p_cust_profile_amt_rec.attribute12,
        X_ATTRIBUTE13                           => p_cust_profile_amt_rec.attribute13,
        X_ATTRIBUTE14                           => p_cust_profile_amt_rec.attribute14,
        X_ATTRIBUTE15                           => p_cust_profile_amt_rec.attribute15,
        X_MIN_FC_BALANCE_AMOUNT                 => p_cust_profile_amt_rec.min_fc_balance_amount,
        X_MIN_FC_INVOICE_AMOUNT                 => p_cust_profile_amt_rec.min_fc_invoice_amount,
        X_CUST_ACCOUNT_ID                       => p_cust_profile_amt_rec.cust_account_id,
        X_SITE_USE_ID                           => p_cust_profile_amt_rec.site_use_id,
        X_EXPIRATION_DATE                       => p_cust_profile_amt_rec.expiration_date,
        X_JGZZ_ATTRIBUTE_CATEGORY               => p_cust_profile_amt_rec.jgzz_attribute_category,
        X_JGZZ_ATTRIBUTE1                       => p_cust_profile_amt_rec.jgzz_attribute1,
        X_JGZZ_ATTRIBUTE2                       => p_cust_profile_amt_rec.jgzz_attribute2,
        X_JGZZ_ATTRIBUTE3                       => p_cust_profile_amt_rec.jgzz_attribute3,
        X_JGZZ_ATTRIBUTE4                       => p_cust_profile_amt_rec.jgzz_attribute4,
        X_JGZZ_ATTRIBUTE5                       => p_cust_profile_amt_rec.jgzz_attribute5,
        X_JGZZ_ATTRIBUTE6                       => p_cust_profile_amt_rec.jgzz_attribute6,
        X_JGZZ_ATTRIBUTE7                       => p_cust_profile_amt_rec.jgzz_attribute7,
        X_JGZZ_ATTRIBUTE8                       => p_cust_profile_amt_rec.jgzz_attribute8,
        X_JGZZ_ATTRIBUTE9                       => p_cust_profile_amt_rec.jgzz_attribute9,
        X_JGZZ_ATTRIBUTE10                      => p_cust_profile_amt_rec.jgzz_attribute10,
        X_JGZZ_ATTRIBUTE11                      => p_cust_profile_amt_rec.jgzz_attribute11,
        X_JGZZ_ATTRIBUTE12                      => p_cust_profile_amt_rec.jgzz_attribute12,
        X_JGZZ_ATTRIBUTE13                      => p_cust_profile_amt_rec.jgzz_attribute13,
        X_JGZZ_ATTRIBUTE14                      => p_cust_profile_amt_rec.jgzz_attribute14,
        X_JGZZ_ATTRIBUTE15                      => p_cust_profile_amt_rec.jgzz_attribute15,
        X_GLOBAL_ATTRIBUTE1                     => p_cust_profile_amt_rec.global_attribute1,
        X_GLOBAL_ATTRIBUTE2                     => p_cust_profile_amt_rec.global_attribute2,
        X_GLOBAL_ATTRIBUTE3                     => p_cust_profile_amt_rec.global_attribute3,
        X_GLOBAL_ATTRIBUTE4                     => p_cust_profile_amt_rec.global_attribute4,
        X_GLOBAL_ATTRIBUTE5                     => p_cust_profile_amt_rec.global_attribute5,
        X_GLOBAL_ATTRIBUTE6                     => p_cust_profile_amt_rec.global_attribute6,
        X_GLOBAL_ATTRIBUTE7                     => p_cust_profile_amt_rec.global_attribute7,
        X_GLOBAL_ATTRIBUTE8                     => p_cust_profile_amt_rec.global_attribute8,
        X_GLOBAL_ATTRIBUTE9                     => p_cust_profile_amt_rec.global_attribute9,
        X_GLOBAL_ATTRIBUTE10                    => p_cust_profile_amt_rec.global_attribute10,
        X_GLOBAL_ATTRIBUTE11                    => p_cust_profile_amt_rec.global_attribute11,
        X_GLOBAL_ATTRIBUTE12                    => p_cust_profile_amt_rec.global_attribute12,
        X_GLOBAL_ATTRIBUTE13                    => p_cust_profile_amt_rec.global_attribute13,
        X_GLOBAL_ATTRIBUTE14                    => p_cust_profile_amt_rec.global_attribute14,
        X_GLOBAL_ATTRIBUTE15                    => p_cust_profile_amt_rec.global_attribute15,
        X_GLOBAL_ATTRIBUTE16                    => p_cust_profile_amt_rec.global_attribute16,
        X_GLOBAL_ATTRIBUTE17                    => p_cust_profile_amt_rec.global_attribute17,
        X_GLOBAL_ATTRIBUTE18                    => p_cust_profile_amt_rec.global_attribute18,
        X_GLOBAL_ATTRIBUTE19                    => p_cust_profile_amt_rec.global_attribute19,
        X_GLOBAL_ATTRIBUTE20                    => p_cust_profile_amt_rec.global_attribute20,
        X_GLOBAL_ATTRIBUTE_CATEGORY             => p_cust_profile_amt_rec.global_attribute_category,
        X_OBJECT_VERSION_NUMBER                 => 1,
        X_CREATED_BY_MODULE                     => p_cust_profile_amt_rec.created_by_module,
        X_APPLICATION_ID                        => p_cust_profile_amt_rec.application_id,
        X_EXCHANGE_RATE_TYPE                    => p_cust_profile_amt_rec.exchange_rate_type,
        X_MIN_FC_INVOICE_OVERDUE_TYPE           => p_cust_profile_amt_rec.min_fc_invoice_overdue_type,
        X_MIN_FC_INVOICE_PERCENT                => p_cust_profile_amt_rec.min_fc_invoice_percent,
        X_MIN_FC_BALANCE_OVERDUE_TYPE           => p_cust_profile_amt_rec.min_fc_balance_overdue_type,
        X_MIN_FC_BALANCE_PERCENT                => p_cust_profile_amt_rec.min_fc_balance_percent,
        X_INTEREST_TYPE                         => p_cust_profile_amt_rec.interest_type,
        X_INTEREST_FIXED_AMOUNT                 => p_cust_profile_amt_rec.interest_fixed_amount,
        X_INTEREST_SCHEDULE_ID                  => p_cust_profile_amt_rec.interest_schedule_id,
        X_PENALTY_TYPE                          => p_cust_profile_amt_rec.penalty_type,
        X_PENALTY_RATE                          => p_cust_profile_amt_rec.penalty_rate,
        X_MIN_INTEREST_CHARGE                   => p_cust_profile_amt_rec.min_interest_charge,
        X_PENALTY_FIXED_AMOUNT                  => p_cust_profile_amt_rec.penalty_fixed_amount,
        X_PENALTY_SCHEDULE_ID                   => p_cust_profile_amt_rec.penalty_schedule_id
    );

    x_cust_acct_profile_amt_id := p_cust_profile_amt_rec.cust_acct_profile_amt_id;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'HZ_CUST_PROFILE_AMTS_PKG.Insert_Row (-) ' ||
                                'x_cust_acct_profile_amt_id = ' || x_cust_acct_profile_amt_id,
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_create_cust_profile_amt (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

END do_create_cust_profile_amt;

/**
 * PRIVATE PROCEDURE do_update_cust_profile_amt
 *
 * DESCRIPTION
 *     Private procedure to update customer profile amount.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_ACCOUNT_VALIDATE_V2PUB.validate_cust_profile_amt
 *     HZ_CUST_PROFILE_AMTS_PKG.Update_Row
 *
 * ARGUMENTS
 *   IN/OUT:
 *     p_cust_profile_amt_rec         Customer profile amount record.
 *     p_object_version_number        Used for locking the being updated record.
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Jianying Huang      o Created.
 *
 */

PROCEDURE do_update_cust_profile_amt (
    p_cust_profile_amt_rec                  IN OUT NOCOPY CUST_PROFILE_AMT_REC_TYPE,
    p_object_version_number                 IN OUT NOCOPY NUMBER,
    x_return_status                         IN OUT NOCOPY VARCHAR2
) IS

    l_debug_prefix                          VARCHAR2(30) := ''; --'do_update_cust_profile_amt';

    l_rowid                                 ROWID := NULL;
    l_object_version_number                 NUMBER;

BEGIN

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_update_cust_profile_amt (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Lock record.
    BEGIN
        SELECT ROWID, OBJECT_VERSION_NUMBER
        INTO l_rowid, l_object_version_number
        FROM HZ_CUST_PROFILE_AMTS
        WHERE CUST_ACCT_PROFILE_AMT_ID  = p_cust_profile_amt_rec.cust_acct_profile_amt_id
        FOR UPDATE NOWAIT;

        IF NOT (
            ( p_object_version_number IS NULL AND l_object_version_number IS NULL ) OR
            ( p_object_version_number IS NOT NULL AND
              l_object_version_number IS NOT NULL AND
              p_object_version_number = l_object_version_number ) )
        THEN
            FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_RECORD_CHANGED' );
            FND_MESSAGE.SET_TOKEN( 'TABLE', 'hz_cust_profile_amts' );
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        p_object_version_number := NVL( l_object_version_number, 1 ) + 1;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_NO_RECORD' );
            FND_MESSAGE.SET_TOKEN( 'RECORD', 'customer account profile amount' );
            FND_MESSAGE.SET_TOKEN( 'VALUE',
                NVL( TO_CHAR( p_cust_profile_amt_rec.cust_acct_profile_amt_id ), 'null' ) );
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
    END;

    -- Validate cust profile amt record
    HZ_ACCOUNT_VALIDATE_V2PUB.validate_cust_profile_amt (
        p_create_update_flag                    => 'U',
        p_check_foreign_key                     => NULL,
        p_cust_profile_amt_rec                  => p_cust_profile_amt_rec,
        p_rowid                                 => l_rowid,
        x_return_status                         => x_return_status );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Added rounding of min_fc_invoice_amount, min_fc_balance_amount, min_interest_charge,
    -- min_interest_charge, interest_fixed_amount and penalty_fixed_amount to 2 decimal places for Late charge project.
    IF p_cust_profile_amt_rec.min_fc_invoice_amount is NOT NULL then
       p_cust_profile_amt_rec.min_fc_invoice_amount := ROUND(p_cust_profile_amt_rec.min_fc_invoice_amount,2);
    END IF;
    IF p_cust_profile_amt_rec.min_fc_balance_amount is NOT NULL then
       p_cust_profile_amt_rec.min_fc_balance_amount := ROUND(p_cust_profile_amt_rec.min_fc_balance_amount,2);
    END IF;
    IF p_cust_profile_amt_rec.max_interest_charge is NOT NULL then
       p_cust_profile_amt_rec.max_interest_charge := ROUND(p_cust_profile_amt_rec.max_interest_charge,2);
    END IF;
    IF p_cust_profile_amt_rec.min_interest_charge is NOT NULL then
       p_cust_profile_amt_rec.min_interest_charge := ROUND(p_cust_profile_amt_rec.min_interest_charge,2);
    END IF;
    IF p_cust_profile_amt_rec.interest_fixed_amount is NOT NULL then
       p_cust_profile_amt_rec.interest_fixed_amount := ROUND(p_cust_profile_amt_rec.interest_fixed_amount,2);
    END IF;
    IF p_cust_profile_amt_rec.penalty_fixed_amount is NOT NULL then
       p_cust_profile_amt_rec.penalty_fixed_amount := ROUND(p_cust_profile_amt_rec.penalty_fixed_amount,2);
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'HZ_CUST_PROFILE_AMTS_PKG.Update_Row (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Call table-handler.
    HZ_CUST_PROFILE_AMTS_PKG.Update_Row (
        X_Rowid                                 => l_rowid,
        X_CUST_ACCT_PROFILE_AMT_ID              => p_cust_profile_amt_rec.cust_acct_profile_amt_id,
        X_CUST_ACCOUNT_PROFILE_ID               => p_cust_profile_amt_rec.cust_account_profile_id,
        X_CURRENCY_CODE                         => p_cust_profile_amt_rec.currency_code,
        X_TRX_CREDIT_LIMIT                      => p_cust_profile_amt_rec.trx_credit_limit,
        X_OVERALL_CREDIT_LIMIT                  => p_cust_profile_amt_rec.overall_credit_limit,
        X_MIN_DUNNING_AMOUNT                    => p_cust_profile_amt_rec.min_dunning_amount,
        X_MIN_DUNNING_INVOICE_AMOUNT            => p_cust_profile_amt_rec.min_dunning_invoice_amount,
        X_MAX_INTEREST_CHARGE                   => p_cust_profile_amt_rec.max_interest_charge,
        X_MIN_STATEMENT_AMOUNT                  => p_cust_profile_amt_rec.min_statement_amount,
        X_AUTO_REC_MIN_RECEIPT_AMOUNT           => p_cust_profile_amt_rec.auto_rec_min_receipt_amount,
        X_INTEREST_RATE                         => p_cust_profile_amt_rec.interest_rate,
        X_ATTRIBUTE_CATEGORY                    => p_cust_profile_amt_rec.attribute_category,
        X_ATTRIBUTE1                            => p_cust_profile_amt_rec.attribute1,
        X_ATTRIBUTE2                            => p_cust_profile_amt_rec.attribute2,
        X_ATTRIBUTE3                            => p_cust_profile_amt_rec.attribute3,
        X_ATTRIBUTE4                            => p_cust_profile_amt_rec.attribute4,
        X_ATTRIBUTE5                            => p_cust_profile_amt_rec.attribute5,
        X_ATTRIBUTE6                            => p_cust_profile_amt_rec.attribute6,
        X_ATTRIBUTE7                            => p_cust_profile_amt_rec.attribute7,
        X_ATTRIBUTE8                            => p_cust_profile_amt_rec.attribute8,
        X_ATTRIBUTE9                            => p_cust_profile_amt_rec.attribute9,
        X_ATTRIBUTE10                           => p_cust_profile_amt_rec.attribute10,
        X_ATTRIBUTE11                           => p_cust_profile_amt_rec.attribute11,
        X_ATTRIBUTE12                           => p_cust_profile_amt_rec.attribute12,
        X_ATTRIBUTE13                           => p_cust_profile_amt_rec.attribute13,
        X_ATTRIBUTE14                           => p_cust_profile_amt_rec.attribute14,
        X_ATTRIBUTE15                           => p_cust_profile_amt_rec.attribute15,
        X_MIN_FC_BALANCE_AMOUNT                 => p_cust_profile_amt_rec.min_fc_balance_amount,
        X_MIN_FC_INVOICE_AMOUNT                 => p_cust_profile_amt_rec.min_fc_invoice_amount,
        X_CUST_ACCOUNT_ID                       => p_cust_profile_amt_rec.cust_account_id,
        X_SITE_USE_ID                           => p_cust_profile_amt_rec.site_use_id,
        X_EXPIRATION_DATE                       => p_cust_profile_amt_rec.expiration_date,
        X_JGZZ_ATTRIBUTE_CATEGORY               => p_cust_profile_amt_rec.jgzz_attribute_category,
        X_JGZZ_ATTRIBUTE1                       => p_cust_profile_amt_rec.jgzz_attribute1,
        X_JGZZ_ATTRIBUTE2                       => p_cust_profile_amt_rec.jgzz_attribute2,
        X_JGZZ_ATTRIBUTE3                       => p_cust_profile_amt_rec.jgzz_attribute3,
        X_JGZZ_ATTRIBUTE4                       => p_cust_profile_amt_rec.jgzz_attribute4,
        X_JGZZ_ATTRIBUTE5                       => p_cust_profile_amt_rec.jgzz_attribute5,
        X_JGZZ_ATTRIBUTE6                       => p_cust_profile_amt_rec.jgzz_attribute6,
        X_JGZZ_ATTRIBUTE7                       => p_cust_profile_amt_rec.jgzz_attribute7,
        X_JGZZ_ATTRIBUTE8                       => p_cust_profile_amt_rec.jgzz_attribute8,
        X_JGZZ_ATTRIBUTE9                       => p_cust_profile_amt_rec.jgzz_attribute9,
        X_JGZZ_ATTRIBUTE10                      => p_cust_profile_amt_rec.jgzz_attribute10,
        X_JGZZ_ATTRIBUTE11                      => p_cust_profile_amt_rec.jgzz_attribute11,
        X_JGZZ_ATTRIBUTE12                      => p_cust_profile_amt_rec.jgzz_attribute12,
        X_JGZZ_ATTRIBUTE13                      => p_cust_profile_amt_rec.jgzz_attribute13,
        X_JGZZ_ATTRIBUTE14                      => p_cust_profile_amt_rec.jgzz_attribute14,
        X_JGZZ_ATTRIBUTE15                      => p_cust_profile_amt_rec.jgzz_attribute15,
        X_GLOBAL_ATTRIBUTE1                     => p_cust_profile_amt_rec.global_attribute1,
        X_GLOBAL_ATTRIBUTE2                     => p_cust_profile_amt_rec.global_attribute2,
        X_GLOBAL_ATTRIBUTE3                     => p_cust_profile_amt_rec.global_attribute3,
        X_GLOBAL_ATTRIBUTE4                     => p_cust_profile_amt_rec.global_attribute4,
        X_GLOBAL_ATTRIBUTE5                     => p_cust_profile_amt_rec.global_attribute5,
        X_GLOBAL_ATTRIBUTE6                     => p_cust_profile_amt_rec.global_attribute6,
        X_GLOBAL_ATTRIBUTE7                     => p_cust_profile_amt_rec.global_attribute7,
        X_GLOBAL_ATTRIBUTE8                     => p_cust_profile_amt_rec.global_attribute8,
        X_GLOBAL_ATTRIBUTE9                     => p_cust_profile_amt_rec.global_attribute9,
        X_GLOBAL_ATTRIBUTE10                    => p_cust_profile_amt_rec.global_attribute10,
        X_GLOBAL_ATTRIBUTE11                    => p_cust_profile_amt_rec.global_attribute11,
        X_GLOBAL_ATTRIBUTE12                    => p_cust_profile_amt_rec.global_attribute12,
        X_GLOBAL_ATTRIBUTE13                    => p_cust_profile_amt_rec.global_attribute13,
        X_GLOBAL_ATTRIBUTE14                    => p_cust_profile_amt_rec.global_attribute14,
        X_GLOBAL_ATTRIBUTE15                    => p_cust_profile_amt_rec.global_attribute15,
        X_GLOBAL_ATTRIBUTE16                    => p_cust_profile_amt_rec.global_attribute16,
        X_GLOBAL_ATTRIBUTE17                    => p_cust_profile_amt_rec.global_attribute17,
        X_GLOBAL_ATTRIBUTE18                    => p_cust_profile_amt_rec.global_attribute18,
        X_GLOBAL_ATTRIBUTE19                    => p_cust_profile_amt_rec.global_attribute19,
        X_GLOBAL_ATTRIBUTE20                    => p_cust_profile_amt_rec.global_attribute20,
        X_GLOBAL_ATTRIBUTE_CATEGORY             => p_cust_profile_amt_rec.global_attribute_category,
        X_OBJECT_VERSION_NUMBER                 => p_object_version_number,
        X_CREATED_BY_MODULE                     => p_cust_profile_amt_rec.created_by_module,
        X_APPLICATION_ID                        => p_cust_profile_amt_rec.application_id,
        X_EXCHANGE_RATE_TYPE                    => p_cust_profile_amt_rec.exchange_rate_type,
        X_MIN_FC_INVOICE_OVERDUE_TYPE           => p_cust_profile_amt_rec.min_fc_invoice_overdue_type,
        X_MIN_FC_INVOICE_PERCENT                => p_cust_profile_amt_rec.min_fc_invoice_percent,
        X_MIN_FC_BALANCE_OVERDUE_TYPE           => p_cust_profile_amt_rec.min_fc_balance_overdue_type,
        X_MIN_FC_BALANCE_PERCENT                => p_cust_profile_amt_rec.min_fc_balance_percent,
        X_INTEREST_TYPE                         => p_cust_profile_amt_rec.interest_type,
        X_INTEREST_FIXED_AMOUNT                 => p_cust_profile_amt_rec.interest_fixed_amount,
        X_INTEREST_SCHEDULE_ID                  => p_cust_profile_amt_rec.interest_schedule_id,
        X_PENALTY_TYPE                          => p_cust_profile_amt_rec.penalty_type,
        X_PENALTY_RATE                          => p_cust_profile_amt_rec.penalty_rate,
        X_MIN_INTEREST_CHARGE                   => p_cust_profile_amt_rec.min_interest_charge,
        X_PENALTY_FIXED_AMOUNT                  => p_cust_profile_amt_rec.penalty_fixed_amount,
        X_PENALTY_SCHEDULE_ID                   => p_cust_profile_amt_rec.penalty_schedule_id
    );

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'HZ_CUST_PROFILE_AMTS_PKG.Update_Row (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_update_cust_profile_amt (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

END do_update_cust_profile_amt;

--------------------------------------
-- public procedures and functions
--------------------------------------
--2310474{
/**
 * Function next_review_date_compute
 *
 * Description
 * Return the next_review_date
 *
 * MODIFICATION HISTORY
 * 04-19-2002  Herve Yu    o Created
 *
 * Parameters : Review_Cycle
 *              Last_review_date
 *              Next_Review_Date
 */
FUNCTION next_review_date_compute
 ( p_review_cycle     IN VARCHAR2  ,
   p_last_review_date IN DATE      ,
   p_next_review_date IN DATE      )
RETURN DATE
IS
  l_last_date   DATE;
  l_date        DATE := NULL;
BEGIN

  -- Last review date is null next review date is null too
  IF p_last_review_date IS NULL THEN
    RETURN l_date;
  END IF;

  -- review period is CUSTOM, API does not change next_review_date
  IF p_review_cycle = 'CUSTOM' THEN
     l_date   :=  p_next_review_date;
     RETURN l_date;
  END IF;

  -- if none review period provide the next review must be null
  IF p_review_cycle IS NULL THEN
     RETURN l_date;
  END IF;

  l_last_date := p_last_review_date;

  -- Compute next review date based on the period code
  IF l_last_date IS NOT NULL THEN
     l_date := compute_next_date( p_date    => p_last_review_date,
                                  p_period  => p_review_cycle);
     -- Next Review must be higher then sysdate
     IF l_date < SYSDATE THEN
        l_date := compute_next_date( p_date    => sysdate,
                                     p_period  => p_review_cycle);
     END IF;
  END IF;

  RETURN l_date;

END;

/**
 * Function last_review_date_default
 *
 * Description
 * Return the last_review_date
 *
 * MODIFICATION HISTORY
 * 04-19-2002  Herve Yu    o Created
 *
 * In parameter : Review_Cycle
 *                Last_review_Date
 *                p_create_update_flag
 */
FUNCTION last_review_date_default
 ( p_review_cycle          IN VARCHAR2 ,
   p_last_review_date      IN DATE     ,
   p_create_update_flag    IN VARCHAR2)
RETURN DATE
IS
  l_last_review_date DATE;
BEGIN
  IF p_create_update_flag = 'C' THEN
    l_last_review_date := SYSDATE;
  ELSIF p_create_update_flag = 'U' THEN
    l_last_review_date := SYSDATE;
  END IF;
  RETURN l_last_review_date;
END;
--}

/**
 * PROCEDURE create_customer_profile
 *
 * DESCRIPTION
 *     Creates customer profile.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_BUSINESS_EVENT_V2PVT.create_customer_profile_event
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_customer_profile_rec         Customer profile record. One customer account
 *                                    must have a customer profile. One account site
 *                                    use can optionally have one customer profile.
 *     p_create_profile_amt           If it is set to FND_API.G_TRUE, API create customer
 *                                    profile amounts by copying corresponding data
 *                                    from customer profile class amounts.
 *   IN/OUT:
 *   OUT:
 *     x_cust_account_profile_id      Customer account profile ID.
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Jianying Huang      o Created.
 *
 */

PROCEDURE create_customer_profile (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_customer_profile_rec                  IN     CUSTOMER_PROFILE_REC_TYPE,
    p_create_profile_amt                    IN     VARCHAR2 := FND_API.G_TRUE,
    x_cust_account_profile_id               OUT NOCOPY    NUMBER,
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
) IS

    l_customer_profile_rec                  CUSTOMER_PROFILE_REC_TYPE := p_customer_profile_rec;
    l_debug_prefix                     VARCHAR2(30) := '';

BEGIN

    -- Standard start of API savepoint
    SAVEPOINT create_customer_profile;

    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_customer_profile (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Call to business logic.
    do_create_customer_profile (
        l_customer_profile_rec,
        p_create_profile_amt,
        x_cust_account_profile_id,
        x_return_status );

   IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('Y', 'EVENTS_ENABLED')) THEN
       -- Invoke business event system.
       HZ_BUSINESS_EVENT_V2PVT.create_customer_profile_event (
         l_customer_profile_rec,
         p_create_profile_amt );
     END IF;

     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('EVENTS_ENABLED', 'BO_EVENTS_ENABLED')) THEN
       HZ_POPULATE_BOT_PKG.pop_hz_customer_profiles(
         p_operation               => 'I',
         p_cust_account_profile_id => x_cust_account_profile_id);
     END IF;
   END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data );

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_customer_profile (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Check if API is called in debug mode. If yes, disable debug.
    --disable_debug;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_customer_profile;
        x_return_status := FND_API.G_RET_STS_ERROR;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

        IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
                 hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'create_customer_profile (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_customer_profile;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

        IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'create_customer_profile (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN OTHERS THEN
        ROLLBACK TO create_customer_profile;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_OTHERS_EXCEP' );
        FND_MESSAGE.SET_TOKEN( 'ERROR' ,SQLERRM );
        FND_MSG_PUB.ADD;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

        IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
             hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'create_customer_profile (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

END create_customer_profile;

/**
 * PROCEDURE update_customer_profile
 *
 * DESCRIPTION
 *     Updates customer profile.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_BUSINESS_EVENT_V2PVT.update_customer_profile_event
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_customer_profile_rec         Customer profile record. One customer account
 *                                    must have a customer profile. One account site
 *                                    use can optionally have one customer profile.
 *   IN/OUT:
 *     p_object_version_number        Used for locking the being updated record.
 *   OUT:
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Jianying Huang      o Created.
 *
 */

PROCEDURE update_customer_profile (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_customer_profile_rec                  IN     CUSTOMER_PROFILE_REC_TYPE,
    p_object_version_number                 IN OUT NOCOPY NUMBER,
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
) IS

    l_customer_profile_rec                  CUSTOMER_PROFILE_REC_TYPE := p_customer_profile_rec;
    l_old_customer_profile_rec              CUSTOMER_PROFILE_REC_TYPE ;
    l_debug_prefix                          VARCHAR2(30) := '';

BEGIN

    -- Standard start of API savepoint
    SAVEPOINT update_customer_profile;

    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'update_customer_profile (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --2290537
    get_customer_profile_rec (
      p_cust_account_profile_id              => p_customer_profile_rec.cust_account_profile_id,
      x_customer_profile_rec                 => l_old_customer_profile_rec,
      x_return_status                        => x_return_status,
      x_msg_count                            => x_msg_count,
      x_msg_data                             => x_msg_data);

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Call to business logic.
    do_update_customer_profile (
        l_customer_profile_rec,
        p_object_version_number,
        x_return_status );

   IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('Y', 'EVENTS_ENABLED')) THEN
       -- Invoke business event system.
       HZ_BUSINESS_EVENT_V2PVT.update_customer_profile_event (
         l_customer_profile_rec , l_old_customer_profile_rec);
     END IF;

     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('EVENTS_ENABLED', 'BO_EVENTS_ENABLED')) THEN
       HZ_POPULATE_BOT_PKG.pop_hz_customer_profiles(
         p_operation               => 'U',
         p_cust_account_profile_id => l_customer_profile_rec.cust_account_profile_id);
     END IF;
   END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data );

    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'update_customer_profile (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Check if API is called in debug mode. If yes, disable debug.
    --disable_debug;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO update_customer_profile;
        x_return_status := FND_API.G_RET_STS_ERROR;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

        IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
                 hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'update_customer_profile (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO update_customer_profile;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

        IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'update_customer_profile (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN OTHERS THEN
        ROLLBACK TO update_customer_profile;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_OTHERS_EXCEP' );
        FND_MESSAGE.SET_TOKEN( 'ERROR' ,SQLERRM );
        FND_MSG_PUB.ADD;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

        IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
             hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'update_customer_profile (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

END update_customer_profile;

/**
 * PROCEDURE get_customer_profile_rec
 *
 * DESCRIPTION
 *      Gets customer profile record
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_CUSTOMER_PROFILES_PKG.Select_Row
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_cust_account_profile_id      Customer account profile id.
 *   IN/OUT:
 *   OUT:
 *     x_customer_profile_rec         Returned customer profile record.
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Jianying Huang      o Created.
 *
 */

PROCEDURE get_customer_profile_rec (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_cust_account_profile_id               IN     NUMBER,
    x_customer_profile_rec                  OUT    NOCOPY CUSTOMER_PROFILE_REC_TYPE,
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
) IS
l_debug_prefix                 VARCHAR2(30) := '';
BEGIN

    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'get_customer_profile_rec (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Check whether primary key has been passed in.
    IF p_cust_account_profile_id IS NULL OR
       p_cust_account_profile_id = FND_API.G_MISS_NUM THEN
        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
        FND_MESSAGE.SET_TOKEN( 'COLUMN', 'cust_account_profile_id' );
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    x_customer_profile_rec.cust_account_profile_id := p_cust_account_profile_id;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'HZ_CUSTOMER_PROFILES_PKG.Select_Row (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Call table-handler.
    HZ_CUSTOMER_PROFILES_PKG.Select_Row (
        X_CUST_ACCOUNT_PROFILE_ID               => x_customer_profile_rec.cust_account_profile_id,
        X_CUST_ACCOUNT_ID                       => x_customer_profile_rec.cust_account_id,
        X_STATUS                                => x_customer_profile_rec.status,
        X_COLLECTOR_ID                          => x_customer_profile_rec.collector_id,
        X_CREDIT_ANALYST_ID                     => x_customer_profile_rec.credit_analyst_id,
        X_CREDIT_CHECKING                       => x_customer_profile_rec.credit_checking,
        X_NEXT_CREDIT_REVIEW_DATE               => x_customer_profile_rec.next_credit_review_date,
        X_TOLERANCE                             => x_customer_profile_rec.tolerance,
        X_DISCOUNT_TERMS                        => x_customer_profile_rec.discount_terms,
        X_DUNNING_LETTERS                       => x_customer_profile_rec.dunning_letters,
        X_INTEREST_CHARGES                      => x_customer_profile_rec.interest_charges,
        X_SEND_STATEMENTS                       => x_customer_profile_rec.send_statements,
        X_CREDIT_BALANCE_STATEMENTS             => x_customer_profile_rec.credit_balance_statements,
        X_CREDIT_HOLD                           => x_customer_profile_rec.credit_hold,
        X_PROFILE_CLASS_ID                      => x_customer_profile_rec.profile_class_id,
        X_SITE_USE_ID                           => x_customer_profile_rec.site_use_id,
        X_CREDIT_RATING                         => x_customer_profile_rec.credit_rating,
        X_RISK_CODE                             => x_customer_profile_rec.risk_code,
        X_STANDARD_TERMS                        => x_customer_profile_rec.standard_terms,
        X_OVERRIDE_TERMS                        => x_customer_profile_rec.override_terms,
        X_DUNNING_LETTER_SET_ID                 => x_customer_profile_rec.dunning_letter_set_id,
        X_INTEREST_PERIOD_DAYS                  => x_customer_profile_rec.interest_period_days,
        X_PAYMENT_GRACE_DAYS                    => x_customer_profile_rec.payment_grace_days,
        X_DISCOUNT_GRACE_DAYS                   => x_customer_profile_rec.discount_grace_days,
        X_STATEMENT_CYCLE_ID                    => x_customer_profile_rec.statement_cycle_id,
        X_ACCOUNT_STATUS                        => x_customer_profile_rec.account_status,
        X_PERCENT_COLLECTABLE                   => x_customer_profile_rec.percent_collectable,
        X_AUTOCASH_HIERARCHY_ID                 => x_customer_profile_rec.autocash_hierarchy_id,
        X_ATTRIBUTE_CATEGORY                    => x_customer_profile_rec.attribute_category,
        X_ATTRIBUTE1                            => x_customer_profile_rec.attribute1,
        X_ATTRIBUTE2                            => x_customer_profile_rec.attribute2,
        X_ATTRIBUTE3                            => x_customer_profile_rec.attribute3,
        X_ATTRIBUTE4                            => x_customer_profile_rec.attribute4,
        X_ATTRIBUTE5                            => x_customer_profile_rec.attribute5,
        X_ATTRIBUTE6                            => x_customer_profile_rec.attribute6,
        X_ATTRIBUTE7                            => x_customer_profile_rec.attribute7,
        X_ATTRIBUTE8                            => x_customer_profile_rec.attribute8,
        X_ATTRIBUTE9                            => x_customer_profile_rec.attribute9,
        X_ATTRIBUTE10                           => x_customer_profile_rec.attribute10,
        X_ATTRIBUTE11                           => x_customer_profile_rec.attribute11,
        X_ATTRIBUTE12                           => x_customer_profile_rec.attribute12,
        X_ATTRIBUTE13                           => x_customer_profile_rec.attribute13,
        X_ATTRIBUTE14                           => x_customer_profile_rec.attribute14,
        X_ATTRIBUTE15                           => x_customer_profile_rec.attribute15,
        X_AUTO_REC_INCL_DISPUTED_FLAG           => x_customer_profile_rec.auto_rec_incl_disputed_flag,
        X_TAX_PRINTING_OPTION                   => x_customer_profile_rec.tax_printing_option,
        X_CHARGE_ON_FINANCE_CHARGE_FG           => x_customer_profile_rec.charge_on_finance_charge_flag,
        X_GROUPING_RULE_ID                      => x_customer_profile_rec.grouping_rule_id,
        X_CLEARING_DAYS                         => x_customer_profile_rec.clearing_days,
        X_JGZZ_ATTRIBUTE_CATEGORY               => x_customer_profile_rec.jgzz_attribute_category,
        X_JGZZ_ATTRIBUTE1                       => x_customer_profile_rec.jgzz_attribute1,
        X_JGZZ_ATTRIBUTE2                       => x_customer_profile_rec.jgzz_attribute2,
        X_JGZZ_ATTRIBUTE3                       => x_customer_profile_rec.jgzz_attribute3,
        X_JGZZ_ATTRIBUTE4                       => x_customer_profile_rec.jgzz_attribute4,
        X_JGZZ_ATTRIBUTE5                       => x_customer_profile_rec.jgzz_attribute5,
        X_JGZZ_ATTRIBUTE6                       => x_customer_profile_rec.jgzz_attribute6,
        X_JGZZ_ATTRIBUTE7                       => x_customer_profile_rec.jgzz_attribute7,
        X_JGZZ_ATTRIBUTE8                       => x_customer_profile_rec.jgzz_attribute8,
        X_JGZZ_ATTRIBUTE9                       => x_customer_profile_rec.jgzz_attribute9,
        X_JGZZ_ATTRIBUTE10                      => x_customer_profile_rec.jgzz_attribute10,
        X_JGZZ_ATTRIBUTE11                      => x_customer_profile_rec.jgzz_attribute11,
        X_JGZZ_ATTRIBUTE12                      => x_customer_profile_rec.jgzz_attribute12,
        X_JGZZ_ATTRIBUTE13                      => x_customer_profile_rec.jgzz_attribute13,
        X_JGZZ_ATTRIBUTE14                      => x_customer_profile_rec.jgzz_attribute14,
        X_JGZZ_ATTRIBUTE15                      => x_customer_profile_rec.jgzz_attribute15,
        X_GLOBAL_ATTRIBUTE1                     => x_customer_profile_rec.global_attribute1,
        X_GLOBAL_ATTRIBUTE2                     => x_customer_profile_rec.global_attribute2,
        X_GLOBAL_ATTRIBUTE3                     => x_customer_profile_rec.global_attribute3,
        X_GLOBAL_ATTRIBUTE4                     => x_customer_profile_rec.global_attribute4,
        X_GLOBAL_ATTRIBUTE5                     => x_customer_profile_rec.global_attribute5,
        X_GLOBAL_ATTRIBUTE6                     => x_customer_profile_rec.global_attribute6,
        X_GLOBAL_ATTRIBUTE7                     => x_customer_profile_rec.global_attribute7,
        X_GLOBAL_ATTRIBUTE8                     => x_customer_profile_rec.global_attribute8,
        X_GLOBAL_ATTRIBUTE9                     => x_customer_profile_rec.global_attribute9,
        X_GLOBAL_ATTRIBUTE10                    => x_customer_profile_rec.global_attribute10,
        X_GLOBAL_ATTRIBUTE11                    => x_customer_profile_rec.global_attribute11,
        X_GLOBAL_ATTRIBUTE12                    => x_customer_profile_rec.global_attribute12,
        X_GLOBAL_ATTRIBUTE13                    => x_customer_profile_rec.global_attribute13,
        X_GLOBAL_ATTRIBUTE14                    => x_customer_profile_rec.global_attribute14,
        X_GLOBAL_ATTRIBUTE15                    => x_customer_profile_rec.global_attribute15,
        X_GLOBAL_ATTRIBUTE16                    => x_customer_profile_rec.global_attribute16,
        X_GLOBAL_ATTRIBUTE17                    => x_customer_profile_rec.global_attribute17,
        X_GLOBAL_ATTRIBUTE18                    => x_customer_profile_rec.global_attribute18,
        X_GLOBAL_ATTRIBUTE19                    => x_customer_profile_rec.global_attribute19,
        X_GLOBAL_ATTRIBUTE20                    => x_customer_profile_rec.global_attribute20,
        X_GLOBAL_ATTRIBUTE_CATEGORY             => x_customer_profile_rec.global_attribute_category,
        X_CONS_INV_FLAG                         => x_customer_profile_rec.cons_inv_flag,
        X_CONS_INV_TYPE                         => x_customer_profile_rec.cons_inv_type,
        X_AUTOCASH_HIERARCHY_ID_ADR             => x_customer_profile_rec.autocash_hierarchy_id_for_adr,
        X_LOCKBOX_MATCHING_OPTION               => x_customer_profile_rec.lockbox_matching_option,
        X_CREATED_BY_MODULE                     => x_customer_profile_rec.created_by_module,
        X_APPLICATION_ID                        => x_customer_profile_rec.application_id,
        X_review_cycle                          => x_customer_profile_rec.review_cycle,
        X_last_credit_review_date               => x_customer_profile_rec.last_credit_review_date,
        X_party_id                              => x_customer_profile_rec.party_id,
        X_CREDIT_CLASSIFICATION                 => x_customer_profile_rec.credit_classification,
        X_CONS_BILL_LEVEL                       => x_customer_profile_rec.cons_bill_level,
        X_LATE_CHARGE_CALCULATION_TRX           => x_customer_profile_rec.late_charge_calculation_trx,
        X_CREDIT_ITEMS_FLAG                     => x_customer_profile_rec.credit_items_flag,
        X_DISPUTED_TRANSACTIONS_FLAG            => x_customer_profile_rec.disputed_transactions_flag,
        X_LATE_CHARGE_TYPE                      => x_customer_profile_rec.late_charge_type,
        X_LATE_CHARGE_TERM_ID                   => x_customer_profile_rec.late_charge_term_id,
        X_INTEREST_CALCULATION_PERIOD           => x_customer_profile_rec.interest_calculation_period,
        X_HOLD_CHARGED_INVOICES_FLAG            => x_customer_profile_rec.hold_charged_invoices_flag,
        X_MESSAGE_TEXT_ID                       => x_customer_profile_rec.message_text_id,
        X_MULTIPLE_INTEREST_RATES_FLAG          => x_customer_profile_rec.multiple_interest_rates_flag,
        X_CHARGE_BEGIN_DATE                     => x_customer_profile_rec.charge_begin_date,
        X_AUTOMATCH_SET_ID                      => x_customer_profile_rec.automatch_set_id
    );

--raji

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'HZ_CUSTOMER_PROFILES_PKG.Select_Row (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data );

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'get_customer_profile_rec (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Check if API is called in debug mode. If yes, disable debug.
    --disable_debug;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

        -- Debug info.
        IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
                 hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'get_customer_profile_rec (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

        -- Debug info.
        IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'get_customer_profile_rec (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_OTHERS_EXCEP' );
        FND_MESSAGE.SET_TOKEN( 'ERROR' ,SQLERRM );
        FND_MSG_PUB.ADD;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

        -- Debug info.
        IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
             hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'get_customer_profile_rec (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

END get_customer_profile_rec;

/**
 * PROCEDURE create_cust_profile_amt
 *
 * DESCRIPTION
 *     Creates customer profile amounts.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_BUSINESS_EVENT_V2PVT.create_cust_profile_amt_event
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_check_foreign_key            If do foreign key checking on cust_account_id
 *                                    and cust_account_profile_id or not. Defaut value
 *                                    is FND_API.G_TRUE, which means API will do foreign
 *                                    key checking on these 2 columns.
 *     p_cust_profile_amt_rec         Customer profile amount record.
 *   IN/OUT:
 *   OUT:
 *     x_cust_acct_profile_amt_id     Customer account profile amount ID.
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Jianying Huang      o Created.
 *
 */


PROCEDURE create_cust_profile_amt (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_check_foreign_key                     IN     VARCHAR2 := FND_API.G_TRUE,
    p_cust_profile_amt_rec                  IN     CUST_PROFILE_AMT_REC_TYPE,
    x_cust_acct_profile_amt_id              OUT NOCOPY    NUMBER,
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
) IS

    l_cust_profile_amt_rec                  CUST_PROFILE_AMT_REC_TYPE := p_cust_profile_amt_rec;
    l_debug_prefix                          VARCHAR2(30) := '';

BEGIN

    -- Standard start of API savepoint
    SAVEPOINT create_cust_profile_amt;

    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_cust_profile_amt (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Call to business logic.
    do_create_cust_profile_amt (
        p_check_foreign_key,
        l_cust_profile_amt_rec,
        x_cust_acct_profile_amt_id,
        x_return_status );

   IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('Y', 'EVENTS_ENABLED')) THEN
       -- Invoke business event system.
       HZ_BUSINESS_EVENT_V2PVT.create_cust_profile_amt_event (
         l_cust_profile_amt_rec );
     END IF;

     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('EVENTS_ENABLED', 'BO_EVENTS_ENABLED')) THEN
       HZ_POPULATE_BOT_PKG.pop_hz_cust_profile_amts(
         p_operation                => 'I',
         p_cust_acct_profile_amt_id => x_cust_acct_profile_amt_id);
     END IF;
   END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data );

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_cust_profile_amt (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Check if API is called in debug mode. If yes, disable debug.
    --disable_debug;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_cust_profile_amt;
        x_return_status := FND_API.G_RET_STS_ERROR;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

        -- Debug info.
        IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
                 hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'create_cust_profile_amt (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_cust_profile_amt;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

        -- Debug info.
        IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'create_cust_profile_amt (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN OTHERS THEN
        ROLLBACK TO create_cust_profile_amt;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_OTHERS_EXCEP' );
        FND_MESSAGE.SET_TOKEN( 'ERROR' ,SQLERRM );
        FND_MSG_PUB.ADD;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

        -- Debug info.
        IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
             hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'create_cust_profile_amt (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

END create_cust_profile_amt;


/**
 * PROCEDURE update_cust_profile_amt
 *
 * DESCRIPTION
 *     Updates customer profile amounts.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_BUSINESS_EVENT_V2PVT.update_cust_profile_amt_event
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_cust_profile_amt_rec         Customer profile amount record.
 *   IN/OUT:
 *     p_object_version_number        Used for locking the being updated record.
 *   OUT:
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Jianying Huang      o Created.
 *
 */

PROCEDURE update_cust_profile_amt (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_cust_profile_amt_rec                  IN     CUST_PROFILE_AMT_REC_TYPE,
    p_object_version_number                 IN OUT NOCOPY NUMBER,
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
) IS

    l_cust_profile_amt_rec                  CUST_PROFILE_AMT_REC_TYPE := p_cust_profile_amt_rec;
    l_old_cust_profile_amt_rec              CUST_PROFILE_AMT_REC_TYPE;
    l_debug_prefix                          VARCHAR2(30) := '';

BEGIN

    -- Standard start of API savepoint
    SAVEPOINT update_cust_profile_amt;

    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'update_cust_profile_amt (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --2290537
    get_cust_profile_amt_rec (
      p_cust_acct_profile_amt_id  => p_cust_profile_amt_rec.cust_acct_profile_amt_id,
      x_cust_profile_amt_rec      => l_old_cust_profile_amt_rec,
      x_return_status             => x_return_status,
      x_msg_count                 => x_msg_count,
      x_msg_data                  => x_msg_data);

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Call to business logic.
    do_update_cust_profile_amt (
        l_cust_profile_amt_rec,
        p_object_version_number,
        x_return_status );

   IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('Y', 'EVENTS_ENABLED')) THEN
       -- Invoke business event system.
       HZ_BUSINESS_EVENT_V2PVT.update_cust_profile_amt_event (
         l_cust_profile_amt_rec , l_old_cust_profile_amt_rec );
     END IF;

     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('EVENTS_ENABLED', 'BO_EVENTS_ENABLED')) THEN
       HZ_POPULATE_BOT_PKG.pop_hz_cust_profile_amts(
         p_operation                => 'U',
         p_cust_acct_profile_amt_id => l_cust_profile_amt_rec.cust_acct_profile_amt_id);
     END IF;
   END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data );

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'update_cust_profile_amt (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;


    -- Check if API is called in debug mode. If yes, disable debug.
    --disable_debug;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO update_cust_profile_amt;
        x_return_status := FND_API.G_RET_STS_ERROR;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

        -- Debug info.
        IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
                 hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'update_cust_profile_amt (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO update_cust_profile_amt;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

        -- Debug info.
        IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'update_cust_profile_amt (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN OTHERS THEN
        ROLLBACK TO update_cust_profile_amt;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_OTHERS_EXCEP' );
        FND_MESSAGE.SET_TOKEN( 'ERROR' ,SQLERRM );
        FND_MSG_PUB.ADD;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

        -- Debug info.
        IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
             hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'update_cust_profile_amt (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

END update_cust_profile_amt;

/**
 * PROCEDURE get_cust_profile_amt_rec
 *
 * DESCRIPTION
 *      Gets customer profile amount record
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_CUST_PROFILE_AMTS_PKG.Select_Row
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_cust_acct_profile_amt_id     Customer account profile amount id.
 *   IN/OUT:
 *   OUT:
 *     x_cust_profile_amt_rec         Returned customer profile amount record.
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Jianying Huang      o Created.
 *
 */

PROCEDURE get_cust_profile_amt_rec (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_cust_acct_profile_amt_id              IN     NUMBER,
    x_cust_profile_amt_rec                  OUT    NOCOPY CUST_PROFILE_AMT_REC_TYPE,
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
) IS
l_debug_prefix                      VARCHAR2(30) := '';
BEGIN

    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'get_cust_profile_amt_rec (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Check whether primary key has been passed in.
    IF p_cust_acct_profile_amt_id IS NULL OR
       p_cust_acct_profile_amt_id = FND_API.G_MISS_NUM THEN
        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
        FND_MESSAGE.SET_TOKEN( 'COLUMN', 'cust_acct_profile_amt_id' );
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    x_cust_profile_amt_rec.cust_acct_profile_amt_id := p_cust_acct_profile_amt_id;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'HZ_CUST_PROFILE_AMTS_PKG.Select_Row (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Call table-handler.
    HZ_CUST_PROFILE_AMTS_PKG.Select_Row (
        X_CUST_ACCT_PROFILE_AMT_ID              => x_cust_profile_amt_rec.cust_acct_profile_amt_id,
        X_CUST_ACCOUNT_PROFILE_ID               => x_cust_profile_amt_rec.cust_account_profile_id,
        X_CURRENCY_CODE                         => x_cust_profile_amt_rec.currency_code,
        X_TRX_CREDIT_LIMIT                      => x_cust_profile_amt_rec.trx_credit_limit,
        X_OVERALL_CREDIT_LIMIT                  => x_cust_profile_amt_rec.overall_credit_limit,
        X_MIN_DUNNING_AMOUNT                    => x_cust_profile_amt_rec.min_dunning_amount,
        X_MIN_DUNNING_INVOICE_AMOUNT            => x_cust_profile_amt_rec.min_dunning_invoice_amount,
        X_MAX_INTEREST_CHARGE                   => x_cust_profile_amt_rec.max_interest_charge,
        X_MIN_STATEMENT_AMOUNT                  => x_cust_profile_amt_rec.min_statement_amount,
        X_AUTO_REC_MIN_RECEIPT_AMOUNT           => x_cust_profile_amt_rec.auto_rec_min_receipt_amount,
        X_INTEREST_RATE                         => x_cust_profile_amt_rec.interest_rate,
        X_ATTRIBUTE_CATEGORY                    => x_cust_profile_amt_rec.attribute_category,
        X_ATTRIBUTE1                            => x_cust_profile_amt_rec.attribute1,
        X_ATTRIBUTE2                            => x_cust_profile_amt_rec.attribute2,
        X_ATTRIBUTE3                            => x_cust_profile_amt_rec.attribute3,
        X_ATTRIBUTE4                            => x_cust_profile_amt_rec.attribute4,
        X_ATTRIBUTE5                            => x_cust_profile_amt_rec.attribute5,
        X_ATTRIBUTE6                            => x_cust_profile_amt_rec.attribute6,
        X_ATTRIBUTE7                            => x_cust_profile_amt_rec.attribute7,
        X_ATTRIBUTE8                            => x_cust_profile_amt_rec.attribute8,
        X_ATTRIBUTE9                            => x_cust_profile_amt_rec.attribute9,
        X_ATTRIBUTE10                           => x_cust_profile_amt_rec.attribute10,
        X_ATTRIBUTE11                           => x_cust_profile_amt_rec.attribute11,
        X_ATTRIBUTE12                           => x_cust_profile_amt_rec.attribute12,
        X_ATTRIBUTE13                           => x_cust_profile_amt_rec.attribute13,
        X_ATTRIBUTE14                           => x_cust_profile_amt_rec.attribute14,
        X_ATTRIBUTE15                           => x_cust_profile_amt_rec.attribute15,
        X_MIN_FC_BALANCE_AMOUNT                 => x_cust_profile_amt_rec.min_fc_balance_amount,
        X_MIN_FC_INVOICE_AMOUNT                 => x_cust_profile_amt_rec.min_fc_invoice_amount,
        X_CUST_ACCOUNT_ID                       => x_cust_profile_amt_rec.cust_account_id,
        X_SITE_USE_ID                           => x_cust_profile_amt_rec.site_use_id,
        X_EXPIRATION_DATE                       => x_cust_profile_amt_rec.expiration_date,
        X_JGZZ_ATTRIBUTE_CATEGORY               => x_cust_profile_amt_rec.jgzz_attribute_category,
        X_JGZZ_ATTRIBUTE1                       => x_cust_profile_amt_rec.jgzz_attribute1,
        X_JGZZ_ATTRIBUTE2                       => x_cust_profile_amt_rec.jgzz_attribute2,
        X_JGZZ_ATTRIBUTE3                       => x_cust_profile_amt_rec.jgzz_attribute3,
        X_JGZZ_ATTRIBUTE4                       => x_cust_profile_amt_rec.jgzz_attribute4,
        X_JGZZ_ATTRIBUTE5                       => x_cust_profile_amt_rec.jgzz_attribute5,
        X_JGZZ_ATTRIBUTE6                       => x_cust_profile_amt_rec.jgzz_attribute6,
        X_JGZZ_ATTRIBUTE7                       => x_cust_profile_amt_rec.jgzz_attribute7,
        X_JGZZ_ATTRIBUTE8                       => x_cust_profile_amt_rec.jgzz_attribute8,
        X_JGZZ_ATTRIBUTE9                       => x_cust_profile_amt_rec.jgzz_attribute9,
        X_JGZZ_ATTRIBUTE10                      => x_cust_profile_amt_rec.jgzz_attribute10,
        X_JGZZ_ATTRIBUTE11                      => x_cust_profile_amt_rec.jgzz_attribute11,
        X_JGZZ_ATTRIBUTE12                      => x_cust_profile_amt_rec.jgzz_attribute12,
        X_JGZZ_ATTRIBUTE13                      => x_cust_profile_amt_rec.jgzz_attribute13,
        X_JGZZ_ATTRIBUTE14                      => x_cust_profile_amt_rec.jgzz_attribute14,
        X_JGZZ_ATTRIBUTE15                      => x_cust_profile_amt_rec.jgzz_attribute15,
        X_GLOBAL_ATTRIBUTE1                     => x_cust_profile_amt_rec.global_attribute1,
        X_GLOBAL_ATTRIBUTE2                     => x_cust_profile_amt_rec.global_attribute2,
        X_GLOBAL_ATTRIBUTE3                     => x_cust_profile_amt_rec.global_attribute3,
        X_GLOBAL_ATTRIBUTE4                     => x_cust_profile_amt_rec.global_attribute4,
        X_GLOBAL_ATTRIBUTE5                     => x_cust_profile_amt_rec.global_attribute5,
        X_GLOBAL_ATTRIBUTE6                     => x_cust_profile_amt_rec.global_attribute6,
        X_GLOBAL_ATTRIBUTE7                     => x_cust_profile_amt_rec.global_attribute7,
        X_GLOBAL_ATTRIBUTE8                     => x_cust_profile_amt_rec.global_attribute8,
        X_GLOBAL_ATTRIBUTE9                     => x_cust_profile_amt_rec.global_attribute9,
        X_GLOBAL_ATTRIBUTE10                    => x_cust_profile_amt_rec.global_attribute10,
        X_GLOBAL_ATTRIBUTE11                    => x_cust_profile_amt_rec.global_attribute11,
        X_GLOBAL_ATTRIBUTE12                    => x_cust_profile_amt_rec.global_attribute12,
        X_GLOBAL_ATTRIBUTE13                    => x_cust_profile_amt_rec.global_attribute13,
        X_GLOBAL_ATTRIBUTE14                    => x_cust_profile_amt_rec.global_attribute14,
        X_GLOBAL_ATTRIBUTE15                    => x_cust_profile_amt_rec.global_attribute15,
        X_GLOBAL_ATTRIBUTE16                    => x_cust_profile_amt_rec.global_attribute16,
        X_GLOBAL_ATTRIBUTE17                    => x_cust_profile_amt_rec.global_attribute17,
        X_GLOBAL_ATTRIBUTE18                    => x_cust_profile_amt_rec.global_attribute18,
        X_GLOBAL_ATTRIBUTE19                    => x_cust_profile_amt_rec.global_attribute19,
        X_GLOBAL_ATTRIBUTE20                    => x_cust_profile_amt_rec.global_attribute20,
        X_GLOBAL_ATTRIBUTE_CATEGORY             => x_cust_profile_amt_rec.global_attribute_category,
        X_CREATED_BY_MODULE                     => x_cust_profile_amt_rec.created_by_module,
        X_APPLICATION_ID                        => x_cust_profile_amt_rec.application_id,
        X_EXCHANGE_RATE_TYPE                    => x_cust_profile_amt_rec.exchange_rate_type,
        X_MIN_FC_INVOICE_OVERDUE_TYPE           => x_cust_profile_amt_rec.min_fc_invoice_overdue_type,
        X_MIN_FC_INVOICE_PERCENT                => x_cust_profile_amt_rec.min_fc_invoice_percent,
        X_MIN_FC_BALANCE_OVERDUE_TYPE           => x_cust_profile_amt_rec.min_fc_balance_overdue_type,
        X_MIN_FC_BALANCE_PERCENT                => x_cust_profile_amt_rec.min_fc_balance_percent,
        X_INTEREST_TYPE                         => x_cust_profile_amt_rec.interest_type,
        X_INTEREST_FIXED_AMOUNT                 => x_cust_profile_amt_rec.interest_fixed_amount,
        X_INTEREST_SCHEDULE_ID                  => x_cust_profile_amt_rec.interest_schedule_id,
        X_PENALTY_TYPE                          => x_cust_profile_amt_rec.penalty_type,
        X_PENALTY_RATE                          => x_cust_profile_amt_rec.penalty_rate,
        X_MIN_INTEREST_CHARGE                   => x_cust_profile_amt_rec.min_interest_charge,
        X_PENALTY_FIXED_AMOUNT                  => x_cust_profile_amt_rec.penalty_fixed_amount,
        X_PENALTY_SCHEDULE_ID                   => x_cust_profile_amt_rec.penalty_schedule_id
    );

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'HZ_CUST_PROFILE_AMTS_PKG.Select_Row (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data );

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'get_cust_profile_amt_rec (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Check if API is called in debug mode. If yes, disable debug.
    --disable_debug;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

        -- Debug info.
        IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
                 hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'get_cust_profile_amt_rec (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

        -- Debug info.
        IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'get_cust_profile_amt_rec (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_OTHERS_EXCEP' );
        FND_MESSAGE.SET_TOKEN( 'ERROR' ,SQLERRM );
        FND_MSG_PUB.ADD;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

        -- Debug info.
        IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
             hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'get_cust_profile_amt_rec (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

END get_cust_profile_amt_rec;

END HZ_CUSTOMER_PROFILE_V2PUB;

/
