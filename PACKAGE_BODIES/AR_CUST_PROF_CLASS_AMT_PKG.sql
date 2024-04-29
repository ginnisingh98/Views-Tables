--------------------------------------------------------
--  DDL for Package Body AR_CUST_PROF_CLASS_AMT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_CUST_PROF_CLASS_AMT_PKG" AS
/* $Header: ARCPCMTB.pls 120.0 2006/03/02 23:42:23 hyu noship $ */

FUNCTION validate_lookup
(p_type   IN VARCHAR2,
 p_code   IN VARCHAR2)
RETURN BOOLEAN
IS
  CURSOR c_lookup(p_type IN VARCHAR, p_code IN VARCHAR2)
  IS
  SELECT NULL
    FROM ar_lookups
   WHERE lookup_type = p_type
     AND lookup_code = p_code
     AND    ( ENABLED_FLAG = 'Y' AND
             TRUNC( SYSDATE ) BETWEEN
              TRUNC(NVL( START_DATE_ACTIVE,SYSDATE ) ) AND
              TRUNC(NVL( END_DATE_ACTIVE,SYSDATE ) ) );
  l_c       VARCHAR2(30);
  l_result  BOOLEAN;
BEGIN
  OPEN c_lookup(p_type,p_code);
  FETCH c_lookup INTO l_c;
  IF  c_lookup%NOTFOUND THEN
    l_result  := FALSE;
  ELSE
    l_result  := TRUE;
  END IF;
  CLOSE c_lookup;
  RETURN l_result;
END;


FUNCTION elementequal(n1  IN NUMBER, n2 IN NUMBER) RETURN BOOLEAN
IS
BEGIN
  IF (n1 = n2) OR (n1 IS NULL AND n2 IS NULL) THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;
END;

FUNCTION elementequal(c1  IN VARCHAR2, c2 IN VARCHAR2) RETURN BOOLEAN
IS
BEGIN
  IF (c1 = c2) OR (c1 IS NULL AND c2 IS NULL) THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;
END;

FUNCTION elementequal(d1  IN DATE, d2 IN DATE) RETURN BOOLEAN
IS
BEGIN
  IF (d1 = d2) OR (d1 IS NULL AND d2 IS NULL) THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;
END;


PROCEDURE int_chrg_validation
(p_int_pen       IN VARCHAR2,
 p_type          IN VARCHAR2,
 p_amount        IN NUMBER,
 p_rate          IN NUMBER,
 p_schedule_id   IN NUMBER,
 x_return_status IN OUT NOCOPY VARCHAR2)
IS
BEGIN
  arp_standard.debug('int_chrg_validation +');
  arp_standard.debug('  p_int_pen     : '|| p_int_pen);
  arp_standard.debug('  p_type        : '|| p_type);
  arp_standard.debug('  p_amount      : '|| p_amount);
  arp_standard.debug('  p_rate        : '|| p_rate);
  arp_standard.debug('  p_schedule_id : '|| p_schedule_id);
  IF P_TYPE  IS NOT NULL THEN
     IF validate_lookup('AR_INTEREST_PENALTY_TYPE' ,P_TYPE) = FALSE THEN
       arp_standard.debug(P_TYPE||' should be a code in the lookup type AR_INTEREST_PENALTY_TYPE');
       FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_INVALID_LOOKUP' );
       FND_MESSAGE.SET_TOKEN( 'COLUMN', p_int_pen||'_TYPE' );
       FND_MESSAGE.SET_TOKEN( 'LOOKUP_TYPE', 'AR_INTEREST_PENALTY_TYPE' );
       FND_MSG_PUB.ADD;
       x_return_status := FND_API.G_RET_STS_ERROR;
     ELSE
       IF    P_TYPE = 'FIXED_AMOUNT' THEN
          IF P_AMOUNT IS NULL THEN
            arp_standard.debug(p_int_pen||'_FIXED_AMOUNT is mandatory for '||p_int_pen||'_TYPE ='||P_TYPE);
            FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
            FND_MESSAGE.SET_TOKEN( 'COLUMN', p_int_pen||'_FIXED_AMOUNT' );
            FND_MSG_PUB.ADD;
            x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
       ELSIF P_TYPE = 'FIXED_RATE' THEN
          IF P_RATE IS NULL THEN
            arp_standard.debug(p_int_pen||'_RATE is mandatory for '||p_int_pen||'_TYPE ='||P_TYPE);
            FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
            FND_MESSAGE.SET_TOKEN( 'COLUMN', p_int_pen||'_RATE' );
            FND_MSG_PUB.ADD;
            x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
       ELSIF P_TYPE = 'CHARGES_SCHEDULE' THEN
          IF P_SCHEDULE_ID IS NULL THEN
            arp_standard.debug(p_int_pen||'_SCHEDULE_ID is mandatory for '||p_int_pen||'_TYPE ='||P_TYPE);
            FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
            FND_MESSAGE.SET_TOKEN( 'COLUMN', p_int_pen||'_RATE' );
            FND_MSG_PUB.ADD;
            x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
       END IF;
     END IF;
  END IF;
  arp_standard.debug('int_chrg_validation -');
END;



PROCEDURE amt_pct_validation
(p_inv_bal       IN VARCHAR2,
 p_type          IN VARCHAR2,
 p_amount        IN NUMBER,
 p_percent       IN NUMBER,
 x_return_status IN OUT NOCOPY VARCHAR2)
IS
BEGIN
  arp_standard.debug('amt_pct_validation +');
  arp_standard.debug('  p_inv_bal     : '||p_inv_bal);
  arp_standard.debug('  p_type        : '||p_type);
  arp_standard.debug('  p_amount      : '||p_amount);
  arp_standard.debug('  p_percent     : '||p_percent);
  IF p_type IS NOT NULL THEN
    IF validate_lookup('AR_AMOUNT_PERCENT',p_type) = FALSE THEN
     arp_standard.debug(p_type||' should be a code in the lookup type AR_AMOUNT_PERCENT');
     FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_INVALID_LOOKUP' );
     FND_MESSAGE.SET_TOKEN( 'COLUMN', 'MIN_FC_'|| p_inv_bal ||'_OVERDUE_TYPE' );
     FND_MESSAGE.SET_TOKEN( 'LOOKUP_TYPE', 'AR_AMOUNT_PERCENT' );
     FND_MSG_PUB.ADD;
     x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
    IF   P_TYPE = 'AMOUNT' THEN
      IF P_AMOUNT IS NULL THEN
         arp_standard.debug('MIN_FC_'|| p_inv_bal ||'_AMOUNT is Mandatory for this MIN_FC_'|| p_inv_bal ||'_OVERDUE_TYPE '||
                             P_TYPE);
         FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
         FND_MESSAGE.SET_TOKEN( 'COLUMN', 'MIN_FC_INVOICE_AMOUNT' );
         FND_MSG_PUB.ADD;
         x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
    ELSIF P_TYPE = 'PERCENT' THEN
      IF P_PERCENT IS NULL THEN
         arp_standard.debug('MIN_FC_'|| p_inv_bal ||'_PERCENT is Mandatory for this MIN_FC_'|| p_inv_bal ||'_OVERDUE_TYPE '||
                             P_TYPE);
         FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
         FND_MESSAGE.SET_TOKEN( 'COLUMN', 'MIN_FC_'|| p_inv_bal ||'_PERCENT' );
         FND_MSG_PUB.ADD;
         x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
    END IF;
  END IF;
  arp_standard.debug('amt_pct_validation -');
END;

PROCEDURE validate_exchange_type
(p_exchange_rate_type IN VARCHAR2,
 x_return_status      IN OUT NOCOPY VARCHAR2)
IS
  CURSOR c IS
  SELECT NULL
    FROM gl_daily_conversion_types
   WHERE conversion_type <> 'EMU FIXED'
     AND conversion_type = p_exchange_rate_type;
  l   VARCHAR2(1);
BEGIN
  arp_standard.debug('validate_exchange_type  +');
  arp_standard.debug('  p_exchange_rate_type   : '||p_exchange_rate_type);
  IF p_exchange_rate_type IS NOT NULL THEN
    OPEN c;
    FETCH c INTO l;
    IF c%NOTFOUND THEN
         arp_standard.debug(' The value p_exchange_rate_type :'||p_exchange_rate_type||' is invalid');
         FND_MESSAGE.SET_NAME( 'AR', 'AR_EXC_TYPE_WRONG_VALUE' );
         FND_MSG_PUB.ADD;
         x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
    CLOSE c;
  END IF;
  arp_standard.debug('validate_exchange_type  -');
END;


PROCEDURE validate_prof_class_amt
(P_CURRENCY_CODE                IN VARCHAR2,
 P_TRX_CREDIT_LIMIT             IN NUMBER,
 P_OVERALL_CREDIT_LIMIT         IN NUMBER,
 P_MIN_DUNNING_AMOUNT           IN NUMBER,
 P_MAX_INTEREST_CHARGE          IN NUMBER,
 P_MIN_INTEREST_CHARGE          IN NUMBER,
 P_MIN_STATEMENT_AMOUNT         IN NUMBER,
 P_AUTO_REC_MIN_RECEIPT_AMOUNT  IN NUMBER,
 P_MIN_DUNNING_INVOICE_AMOUNT   IN NUMBER,
 P_INTEREST_RATE                IN NUMBER,
 P_EXPIRATION_DATE              IN DATE,
 P_EXCHANGE_RATE_TYPE           IN VARCHAR2,
 P_MIN_FC_INVOICE_OVERDUE_TYPE  IN VARCHAR2,
 P_MIN_FC_INVOICE_PERCENT       IN NUMBER,
 P_MIN_FC_INVOICE_AMOUNT        IN NUMBER,
 P_MIN_FC_BALANCE_OVERDUE_TYPE  IN VARCHAR2,
 P_MIN_FC_BALANCE_PERCENT       IN NUMBER,
 P_MIN_FC_BALANCE_AMOUNT        IN NUMBER,
 P_INTEREST_TYPE                IN VARCHAR2,
 P_INTEREST_FIXED_AMOUNT        IN NUMBER,
 P_INTEREST_SCHEDULE_ID         IN NUMBER,
 P_PENALTY_TYPE                 IN VARCHAR2,
 P_PENALTY_RATE                 IN NUMBER,
 P_PENALTY_FIXED_AMOUNT         IN NUMBER,
 P_PENALTY_SCHEDULE_ID          IN NUMBER,
 x_return_status                IN OUT NOCOPY VARCHAR2)
IS
  CURSOR curr IS
  SELECT NULL
    FROM fnd_currencies
   WHERE currency_code = p_currency_code;
  l_code VARCHAR2(30);
BEGIN
  arp_standard.debug('validate_prof_class_amt +');

  IF p_currency_code IS NULL THEN
     arp_standard.debug('Currency_code is Mandatory');
     FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
     FND_MESSAGE.SET_TOKEN( 'COLUMN', 'CURRENCY_CODE' );
     FND_MSG_PUB.ADD;
     x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  OPEN curr;
  FETCH curr INTO l_code;
  IF curr%NOTFOUND THEN
     arp_standard.debug(p_currency_code||' should be a in fnd_currencies');
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_INVALID_FK');
     FND_MESSAGE.SET_TOKEN('FK', 'hz_cust_prof_class_amts');
     FND_MESSAGE.SET_TOKEN('COLUMN', 'CURRENCY_CODE');
     FND_MESSAGE.SET_TOKEN('TABLE', 'fnd_currencies');
     FND_MSG_PUB.ADD;
     x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;
  CLOSE curr;


  IF P_MIN_FC_INVOICE_OVERDUE_TYPE IS NOT NULL THEN
    IF validate_lookup('AR_AMOUNT_PERCENT',P_MIN_FC_INVOICE_OVERDUE_TYPE) = FALSE THEN
     arp_standard.debug(P_MIN_FC_INVOICE_OVERDUE_TYPE||' should be a code in the lookup type AR_AMOUNT_PERCENT');
     FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_INVALID_LOOKUP' );
     FND_MESSAGE.SET_TOKEN( 'COLUMN', 'MIN_FC_INVOICE_OVERDUE_TYPE' );
     FND_MESSAGE.SET_TOKEN( 'LOOKUP_TYPE', 'AR_AMOUNT_PERCENT' );
     FND_MSG_PUB.ADD;
     x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
    IF   P_MIN_FC_INVOICE_OVERDUE_TYPE = 'AMOUNT' THEN
      IF P_MIN_FC_INVOICE_AMOUNT IS NULL THEN
         arp_standard.debug('MIN_FC_INVOICE_AMOUNT is Mandatory for this MIN_FC_INVOICE_OVERDUE_TYPE '||
                             P_MIN_FC_INVOICE_OVERDUE_TYPE);
         FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
         FND_MESSAGE.SET_TOKEN( 'COLUMN', 'MIN_FC_INVOICE_AMOUNT' );
         FND_MSG_PUB.ADD;
         x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
    ELSIF P_MIN_FC_INVOICE_OVERDUE_TYPE = 'PERCENT' THEN
      IF P_MIN_FC_INVOICE_PERCENT IS NULL THEN
         arp_standard.debug('MIN_FC_INVOICE_PERCENT is Mandatory for this MIN_FC_INVOICE_OVERDUE_TYPE '||
                             P_MIN_FC_INVOICE_OVERDUE_TYPE);
         FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
         FND_MESSAGE.SET_TOKEN( 'COLUMN', 'MIN_FC_INVOICE_PERCENT' );
         FND_MSG_PUB.ADD;
         x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
    END IF;
  END IF;

  validate_exchange_type
  (p_exchange_rate_type => p_exchange_rate_type,
   x_return_status      => x_return_status);

  amt_pct_validation
  (p_inv_bal       => 'INVOICE',
   p_type          => P_MIN_FC_INVOICE_OVERDUE_TYPE,
   p_amount        => P_MIN_FC_INVOICE_AMOUNT,
   p_percent       => P_MIN_FC_INVOICE_PERCENT,
   x_return_status => x_return_status);

  amt_pct_validation
  (p_inv_bal       => 'BALANCE',
   p_type          => P_MIN_FC_BALANCE_OVERDUE_TYPE,
   p_amount        => P_MIN_FC_BALANCE_AMOUNT,
   p_percent       => P_MIN_FC_BALANCE_PERCENT,
   x_return_status => x_return_status);


  int_chrg_validation
  (p_int_pen       => 'INTEREST',
   p_type          => P_INTEREST_TYPE,
   p_amount        => P_INTEREST_FIXED_AMOUNT,
   p_rate          => P_INTEREST_RATE,
   p_schedule_id   => P_INTEREST_SCHEDULE_ID,
   x_return_status => x_return_status);


  int_chrg_validation
  (p_int_pen       => 'PENALTY',
   p_type          => P_PENALTY_TYPE,
   p_amount        => P_PENALTY_FIXED_AMOUNT,
   p_rate          => P_PENALTY_RATE,
   p_schedule_id   => P_PENALTY_SCHEDULE_ID,
   x_return_status => x_return_status);

  arp_standard.debug('validate_prof_class_amt -');
END;





PROCEDURE insert_row
(P_PROFILE_CLASS_AMOUNT_ID      IN NUMBER,
 P_PROFILE_CLASS_ID             IN NUMBER,
 P_CURRENCY_CODE                IN VARCHAR2,
 P_TRX_CREDIT_LIMIT             IN NUMBER,
 P_OVERALL_CREDIT_LIMIT         IN NUMBER,
 P_MIN_DUNNING_AMOUNT           IN NUMBER,
 P_MAX_INTEREST_CHARGE          IN NUMBER,
 P_MIN_INTEREST_CHARGE          IN NUMBER,
 P_MIN_STATEMENT_AMOUNT         IN NUMBER,
 P_AUTO_REC_MIN_RECEIPT_AMOUNT  IN NUMBER,
 P_MIN_DUNNING_INVOICE_AMOUNT   IN NUMBER,
 P_INTEREST_RATE                IN NUMBER,
 P_EXPIRATION_DATE              IN DATE,
 P_EXCHANGE_RATE_TYPE           IN VARCHAR2,
 P_MIN_FC_INVOICE_OVERDUE_TYPE  IN VARCHAR2,
 P_MIN_FC_INVOICE_PERCENT       IN NUMBER,
 P_MIN_FC_INVOICE_AMOUNT        IN NUMBER,
 P_MIN_FC_BALANCE_OVERDUE_TYPE  IN VARCHAR2,
 P_MIN_FC_BALANCE_PERCENT       IN NUMBER,
 P_MIN_FC_BALANCE_AMOUNT        IN NUMBER,
 P_INTEREST_TYPE                IN VARCHAR2,
 P_INTEREST_FIXED_AMOUNT        IN NUMBER,
 P_INTEREST_SCHEDULE_ID         IN NUMBER,
 P_PENALTY_TYPE                 IN VARCHAR2,
 P_PENALTY_RATE                 IN NUMBER,
 P_PENALTY_FIXED_AMOUNT         IN NUMBER,
 P_PENALTY_SCHEDULE_ID          IN NUMBER,
 P_ATTRIBUTE_CATEGORY           IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE1                   IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE2                   IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE3                   IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE4                   IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE5                   IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE6                   IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE7                   IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE8                   IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE9                   IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE10                  IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE11                  IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE12                  IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE13                  IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE14                  IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE15                  IN VARCHAR2 DEFAULT NULL,
 P_JGZZ_ATTRIBUTE_CATEGORY      IN VARCHAR2 DEFAULT NULL,
 P_JGZZ_ATTRIBUTE1              IN VARCHAR2 DEFAULT NULL,
 P_JGZZ_ATTRIBUTE2              IN VARCHAR2 DEFAULT NULL,
 P_JGZZ_ATTRIBUTE3              IN VARCHAR2 DEFAULT NULL,
 P_JGZZ_ATTRIBUTE4              IN VARCHAR2 DEFAULT NULL,
 P_JGZZ_ATTRIBUTE5              IN VARCHAR2 DEFAULT NULL,
 P_JGZZ_ATTRIBUTE6              IN VARCHAR2 DEFAULT NULL,
 P_JGZZ_ATTRIBUTE7              IN VARCHAR2 DEFAULT NULL,
 P_JGZZ_ATTRIBUTE8              IN VARCHAR2 DEFAULT NULL,
 P_JGZZ_ATTRIBUTE9              IN VARCHAR2 DEFAULT NULL,
 P_JGZZ_ATTRIBUTE10             IN VARCHAR2 DEFAULT NULL,
 P_JGZZ_ATTRIBUTE11             IN VARCHAR2 DEFAULT NULL,
 P_JGZZ_ATTRIBUTE12             IN VARCHAR2 DEFAULT NULL,
 P_JGZZ_ATTRIBUTE13             IN VARCHAR2 DEFAULT NULL,
 P_JGZZ_ATTRIBUTE14             IN VARCHAR2 DEFAULT NULL,
 P_JGZZ_ATTRIBUTE15             IN VARCHAR2 DEFAULT NULL,
 P_GLOBAL_ATTRIBUTE1            IN VARCHAR2 DEFAULT NULL,
 P_GLOBAL_ATTRIBUTE2            IN VARCHAR2 DEFAULT NULL,
 P_GLOBAL_ATTRIBUTE3            IN VARCHAR2 DEFAULT NULL,
 P_GLOBAL_ATTRIBUTE4            IN VARCHAR2 DEFAULT NULL,
 P_GLOBAL_ATTRIBUTE5            IN VARCHAR2 DEFAULT NULL,
 P_GLOBAL_ATTRIBUTE6            IN VARCHAR2 DEFAULT NULL,
 P_GLOBAL_ATTRIBUTE7            IN VARCHAR2 DEFAULT NULL,
 P_GLOBAL_ATTRIBUTE8            IN VARCHAR2 DEFAULT NULL,
 P_GLOBAL_ATTRIBUTE9            IN VARCHAR2 DEFAULT NULL,
 P_GLOBAL_ATTRIBUTE10           IN VARCHAR2 DEFAULT NULL,
 P_GLOBAL_ATTRIBUTE11           IN VARCHAR2 DEFAULT NULL,
 P_GLOBAL_ATTRIBUTE12           IN VARCHAR2 DEFAULT NULL,
 P_GLOBAL_ATTRIBUTE13           IN VARCHAR2 DEFAULT NULL,
 P_GLOBAL_ATTRIBUTE14           IN VARCHAR2 DEFAULT NULL,
 P_GLOBAL_ATTRIBUTE15           IN VARCHAR2 DEFAULT NULL,
 P_GLOBAL_ATTRIBUTE16           IN VARCHAR2 DEFAULT NULL,
 P_GLOBAL_ATTRIBUTE17           IN VARCHAR2 DEFAULT NULL,
 P_GLOBAL_ATTRIBUTE18           IN VARCHAR2 DEFAULT NULL,
 P_GLOBAL_ATTRIBUTE19           IN VARCHAR2 DEFAULT NULL,
 P_GLOBAL_ATTRIBUTE20           IN VARCHAR2 DEFAULT NULL,
 P_GLOBAL_ATTRIBUTE_CATEGORY    IN VARCHAR2 DEFAULT NULL,
 P_LAST_UPDATED_BY              IN NUMBER   DEFAULT -1,
 P_CREATED_BY                   IN NUMBER   DEFAULT -1,
 P_CREATION_DATE                IN DATE     DEFAULT SYSDATE,
 P_LAST_UPDATE_LOGIN            IN NUMBER   DEFAULT -1,
 x_return_status                OUT NOCOPY  VARCHAR2,
 x_msg_count                    OUT NOCOPY  NUMBER,
 x_msg_data                     OUT NOCOPY  VARCHAR2)
IS
  CURSOR cseq IS
  SELECT hz_cust_prof_class_amts_s.nextval
  from   dual;
  l_cust_prof_class_amt_id  NUMBER;
BEGIN
 arp_standard.debug('ar_cust_prof_class_amt_pkg.insert_row +');

 x_return_status  := fnd_api.g_ret_Sts_success;

 fnd_msg_pub.initialize;

 validate_prof_class_amt
 (P_CURRENCY_CODE                => p_currency_code,
  P_TRX_CREDIT_LIMIT             => P_TRX_CREDIT_LIMIT,
  P_OVERALL_CREDIT_LIMIT         => P_OVERALL_CREDIT_LIMIT,
  P_MIN_DUNNING_AMOUNT           => P_MIN_DUNNING_AMOUNT,
  P_MAX_INTEREST_CHARGE          => P_MAX_INTEREST_CHARGE,
  P_MIN_INTEREST_CHARGE          => P_MIN_INTEREST_CHARGE,
  P_MIN_STATEMENT_AMOUNT         => P_MIN_STATEMENT_AMOUNT,
  P_AUTO_REC_MIN_RECEIPT_AMOUNT  => P_AUTO_REC_MIN_RECEIPT_AMOUNT,
  P_MIN_DUNNING_INVOICE_AMOUNT   => P_MIN_DUNNING_INVOICE_AMOUNT,
  P_INTEREST_RATE                => P_INTEREST_RATE,
  P_EXPIRATION_DATE              => P_EXPIRATION_DATE,
  P_EXCHANGE_RATE_TYPE           => P_EXCHANGE_RATE_TYPE,
  P_MIN_FC_INVOICE_OVERDUE_TYPE  => P_MIN_FC_INVOICE_OVERDUE_TYPE,
  P_MIN_FC_INVOICE_PERCENT       => P_MIN_FC_INVOICE_PERCENT,
  P_MIN_FC_INVOICE_AMOUNT        => P_MIN_FC_INVOICE_AMOUNT,
  P_MIN_FC_BALANCE_OVERDUE_TYPE  => P_MIN_FC_BALANCE_OVERDUE_TYPE,
  P_MIN_FC_BALANCE_PERCENT       => P_MIN_FC_BALANCE_PERCENT,
  P_MIN_FC_BALANCE_AMOUNT        => P_MIN_FC_BALANCE_AMOUNT,
  P_INTEREST_TYPE                => P_INTEREST_TYPE,
  P_INTEREST_FIXED_AMOUNT        => P_INTEREST_FIXED_AMOUNT,
  P_INTEREST_SCHEDULE_ID         => P_INTEREST_SCHEDULE_ID,
  P_PENALTY_TYPE                 => P_PENALTY_TYPE,
  P_PENALTY_RATE                 => P_PENALTY_RATE,
  P_PENALTY_FIXED_AMOUNT         => P_PENALTY_FIXED_AMOUNT,
  P_PENALTY_SCHEDULE_ID          => P_PENALTY_SCHEDULE_ID,
  x_return_status                => x_return_status);

 IF  x_return_status <> fnd_api.g_ret_Sts_success THEN
   RAISE fnd_api.G_EXC_ERROR;
 END IF;

 arp_standard.debug(' Inserting into hz_cust_prof_class_amts+');

 IF P_PROFILE_CLASS_AMOUNT_ID IS NULL THEN
  OPEN cseq;
   FETCH cseq INTO l_cust_prof_class_amt_id;
  CLOSE cseq;
 ELSE
  l_cust_prof_class_amt_id := P_PROFILE_CLASS_AMOUNT_ID;
 END IF;

arp_standard.debug('P_TRX_CREDIT_LIMIT :'||P_TRX_CREDIT_LIMIT );

 INSERT INTO hz_cust_prof_class_Amts
 (PROFILE_CLASS_AMOUNT_ID      ,
  PROFILE_CLASS_ID             ,
  CURRENCY_CODE                ,
  TRX_CREDIT_LIMIT             ,
  OVERALL_CREDIT_LIMIT         ,
  MIN_DUNNING_AMOUNT           ,
  MAX_INTEREST_CHARGE          ,
  MIN_INTEREST_CHARGE          ,
  MIN_STATEMENT_AMOUNT         ,
  AUTO_REC_MIN_RECEIPT_AMOUNT  ,
  MIN_DUNNING_INVOICE_AMOUNT   ,
  INTEREST_RATE                ,
  EXPIRATION_DATE              ,
  EXCHANGE_RATE_TYPE           ,
  MIN_FC_INVOICE_OVERDUE_TYPE  ,
  MIN_FC_INVOICE_PERCENT       ,
  MIN_FC_INVOICE_AMOUNT        ,
  MIN_FC_BALANCE_OVERDUE_TYPE  ,
  MIN_FC_BALANCE_PERCENT       ,
  MIN_FC_BALANCE_AMOUNT        ,
  INTEREST_TYPE                ,
  INTEREST_FIXED_AMOUNT        ,
  INTEREST_SCHEDULE_ID         ,
  PENALTY_TYPE                 ,
  PENALTY_RATE                 ,
  PENALTY_FIXED_AMOUNT         ,
  PENALTY_SCHEDULE_ID          ,
  ATTRIBUTE_CATEGORY           ,
  ATTRIBUTE1                   ,
  ATTRIBUTE2                   ,
  ATTRIBUTE3                   ,
  ATTRIBUTE4                   ,
  ATTRIBUTE5                   ,
  ATTRIBUTE6                   ,
  ATTRIBUTE7                   ,
  ATTRIBUTE8                   ,
  ATTRIBUTE9                   ,
  ATTRIBUTE10                  ,
  ATTRIBUTE11                  ,
  ATTRIBUTE12                  ,
  ATTRIBUTE13                  ,
  ATTRIBUTE14                  ,
  ATTRIBUTE15                  ,
  JGZZ_ATTRIBUTE_CATEGORY      ,
  JGZZ_ATTRIBUTE1              ,
  JGZZ_ATTRIBUTE2              ,
  JGZZ_ATTRIBUTE3              ,
  JGZZ_ATTRIBUTE4              ,
  JGZZ_ATTRIBUTE5              ,
  JGZZ_ATTRIBUTE6              ,
  JGZZ_ATTRIBUTE7              ,
  JGZZ_ATTRIBUTE8              ,
  JGZZ_ATTRIBUTE9              ,
  JGZZ_ATTRIBUTE10             ,
  JGZZ_ATTRIBUTE11             ,
  JGZZ_ATTRIBUTE12             ,
  JGZZ_ATTRIBUTE13             ,
  JGZZ_ATTRIBUTE14             ,
  JGZZ_ATTRIBUTE15             ,
  GLOBAL_ATTRIBUTE1            ,
  GLOBAL_ATTRIBUTE2            ,
  GLOBAL_ATTRIBUTE3            ,
  GLOBAL_ATTRIBUTE4            ,
  GLOBAL_ATTRIBUTE5            ,
  GLOBAL_ATTRIBUTE6            ,
  GLOBAL_ATTRIBUTE7            ,
  GLOBAL_ATTRIBUTE8            ,
  GLOBAL_ATTRIBUTE9            ,
  GLOBAL_ATTRIBUTE10           ,
  GLOBAL_ATTRIBUTE11           ,
  GLOBAL_ATTRIBUTE12           ,
  GLOBAL_ATTRIBUTE13           ,
  GLOBAL_ATTRIBUTE14           ,
  GLOBAL_ATTRIBUTE15           ,
  GLOBAL_ATTRIBUTE16           ,
  GLOBAL_ATTRIBUTE17           ,
  GLOBAL_ATTRIBUTE18           ,
  GLOBAL_ATTRIBUTE19           ,
  GLOBAL_ATTRIBUTE20           ,
  GLOBAL_ATTRIBUTE_CATEGORY    ,
  LAST_UPDATED_BY              ,
  LAST_UPDATE_DATE             ,
  CREATED_BY                   ,
  CREATION_DATE                ,
  LAST_UPDATE_LOGIN
  ) VALUES (
  l_cust_prof_class_amt_id       ,
  P_PROFILE_CLASS_ID             ,
  P_CURRENCY_CODE                ,
  P_TRX_CREDIT_LIMIT             ,
  P_OVERALL_CREDIT_LIMIT         ,
  P_MIN_DUNNING_AMOUNT           ,
  P_MAX_INTEREST_CHARGE          ,
  P_MIN_INTEREST_CHARGE          ,
  P_MIN_STATEMENT_AMOUNT         ,
  P_AUTO_REC_MIN_RECEIPT_AMOUNT  ,
  P_MIN_DUNNING_INVOICE_AMOUNT   ,
  P_INTEREST_RATE                ,
  P_EXPIRATION_DATE              ,
  P_EXCHANGE_RATE_TYPE           ,
  P_MIN_FC_INVOICE_OVERDUE_TYPE  ,
  P_MIN_FC_INVOICE_PERCENT       ,
  P_MIN_FC_INVOICE_AMOUNT        ,
  P_MIN_FC_BALANCE_OVERDUE_TYPE  ,
  P_MIN_FC_BALANCE_PERCENT       ,
  P_MIN_FC_BALANCE_AMOUNT        ,
  P_INTEREST_TYPE                ,
  P_INTEREST_FIXED_AMOUNT        ,
  P_INTEREST_SCHEDULE_ID         ,
  P_PENALTY_TYPE                 ,
  P_PENALTY_RATE                 ,
  P_PENALTY_FIXED_AMOUNT         ,
  P_PENALTY_SCHEDULE_ID          ,
  P_ATTRIBUTE_CATEGORY           ,
  P_ATTRIBUTE1                   ,
  P_ATTRIBUTE2                   ,
  P_ATTRIBUTE3                   ,
  P_ATTRIBUTE4                   ,
  P_ATTRIBUTE5                   ,
  P_ATTRIBUTE6                   ,
  P_ATTRIBUTE7                   ,
  P_ATTRIBUTE8                   ,
  P_ATTRIBUTE9                   ,
  P_ATTRIBUTE10                  ,
  P_ATTRIBUTE11                  ,
  P_ATTRIBUTE12                  ,
  P_ATTRIBUTE13                  ,
  P_ATTRIBUTE14                  ,
  P_ATTRIBUTE15                  ,
  P_JGZZ_ATTRIBUTE_CATEGORY      ,
  P_JGZZ_ATTRIBUTE1              ,
  P_JGZZ_ATTRIBUTE2              ,
  P_JGZZ_ATTRIBUTE3              ,
  P_JGZZ_ATTRIBUTE4              ,
  P_JGZZ_ATTRIBUTE5              ,
  P_JGZZ_ATTRIBUTE6              ,
  P_JGZZ_ATTRIBUTE7              ,
  P_JGZZ_ATTRIBUTE8              ,
  P_JGZZ_ATTRIBUTE9              ,
  P_JGZZ_ATTRIBUTE10             ,
  P_JGZZ_ATTRIBUTE11             ,
  P_JGZZ_ATTRIBUTE12             ,
  P_JGZZ_ATTRIBUTE13             ,
  P_JGZZ_ATTRIBUTE14             ,
  P_JGZZ_ATTRIBUTE15             ,
  P_GLOBAL_ATTRIBUTE1            ,
  P_GLOBAL_ATTRIBUTE2            ,
  P_GLOBAL_ATTRIBUTE3            ,
  P_GLOBAL_ATTRIBUTE4            ,
  P_GLOBAL_ATTRIBUTE5            ,
  P_GLOBAL_ATTRIBUTE6            ,
  P_GLOBAL_ATTRIBUTE7            ,
  P_GLOBAL_ATTRIBUTE8            ,
  P_GLOBAL_ATTRIBUTE9            ,
  P_GLOBAL_ATTRIBUTE10           ,
  P_GLOBAL_ATTRIBUTE11           ,
  P_GLOBAL_ATTRIBUTE12           ,
  P_GLOBAL_ATTRIBUTE13           ,
  P_GLOBAL_ATTRIBUTE14           ,
  P_GLOBAL_ATTRIBUTE15           ,
  P_GLOBAL_ATTRIBUTE16           ,
  P_GLOBAL_ATTRIBUTE17           ,
  P_GLOBAL_ATTRIBUTE18           ,
  P_GLOBAL_ATTRIBUTE19           ,
  P_GLOBAL_ATTRIBUTE20           ,
  P_GLOBAL_ATTRIBUTE_CATEGORY    ,
  P_LAST_UPDATED_BY              ,
  SYSDATE                        ,
  P_CREATED_BY                   ,
  P_CREATION_DATE                ,
  P_LAST_UPDATE_LOGIN);

  arp_standard.debug(' Inserting into hz_cust_prof_class_amts-');

arp_standard.debug('ar_cust_prof_class_amt_pkg.insert_row -');
EXCEPTION
  WHEN fnd_api.G_EXC_ERROR THEN
    fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                              p_count => x_msg_count,
                              p_data  => x_msg_data);
    arp_standard.debug('EXCEPTION  IN ar_cust_prof_class_amt_pkg.insert_row:'||x_msg_data);

  WHEN OTHERS THEN
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
    fnd_message.set_token('ERROR' ,SQLERRM);
    fnd_msg_pub.add;
    fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                              p_count => x_msg_count,
                              p_data  => x_msg_data);
    arp_standard.debug('EXCEPTION OTHERS IN ar_cust_prof_class_amt_pkg.insert_row:'||SQLERRM);
END;



PROCEDURE lock_row
(p_info_rec        IN  hz_cust_prof_class_Amts%ROWTYPE,
 x_return_status   OUT NOCOPY  VARCHAR2,
 x_msg_count       OUT NOCOPY  NUMBER,
 x_msg_data        OUT NOCOPY  VARCHAR2)
IS
  CURSOR c IS
  SELECT PROFILE_CLASS_AMOUNT_ID      ,
         PROFILE_CLASS_ID             ,
         CURRENCY_CODE                ,
         TRX_CREDIT_LIMIT             ,
         OVERALL_CREDIT_LIMIT         ,
         MIN_DUNNING_AMOUNT           ,
         MAX_INTEREST_CHARGE          ,
         MIN_INTEREST_CHARGE          ,
         MIN_STATEMENT_AMOUNT         ,
         AUTO_REC_MIN_RECEIPT_AMOUNT  ,
         MIN_DUNNING_INVOICE_AMOUNT   ,
         INTEREST_RATE                ,
         EXPIRATION_DATE              ,
         EXCHANGE_RATE_TYPE           ,
         MIN_FC_INVOICE_OVERDUE_TYPE  ,
         MIN_FC_INVOICE_PERCENT       ,
         MIN_FC_INVOICE_AMOUNT        ,
         MIN_FC_BALANCE_OVERDUE_TYPE  ,
         MIN_FC_BALANCE_PERCENT       ,
         MIN_FC_BALANCE_AMOUNT        ,
         INTEREST_TYPE                ,
         INTEREST_FIXED_AMOUNT        ,
         INTEREST_SCHEDULE_ID         ,
         PENALTY_TYPE                 ,
         PENALTY_RATE                 ,
         PENALTY_FIXED_AMOUNT         ,
         PENALTY_SCHEDULE_ID          ,
         ATTRIBUTE_CATEGORY           ,
         ATTRIBUTE1                   ,
         ATTRIBUTE2                   ,
         ATTRIBUTE3                   ,
         ATTRIBUTE4                   ,
         ATTRIBUTE5                   ,
         ATTRIBUTE6                   ,
         ATTRIBUTE7                   ,
         ATTRIBUTE8                   ,
         ATTRIBUTE9                   ,
         ATTRIBUTE10                  ,
         ATTRIBUTE11                  ,
         ATTRIBUTE12                  ,
         ATTRIBUTE13                  ,
         ATTRIBUTE14                  ,
         ATTRIBUTE15                  ,
         JGZZ_ATTRIBUTE_CATEGORY      ,
         JGZZ_ATTRIBUTE1              ,
         JGZZ_ATTRIBUTE2              ,
         JGZZ_ATTRIBUTE3              ,
         JGZZ_ATTRIBUTE4              ,
         JGZZ_ATTRIBUTE5              ,
         JGZZ_ATTRIBUTE6              ,
         JGZZ_ATTRIBUTE7              ,
         JGZZ_ATTRIBUTE8              ,
         JGZZ_ATTRIBUTE9              ,
         JGZZ_ATTRIBUTE10             ,
         JGZZ_ATTRIBUTE11             ,
         JGZZ_ATTRIBUTE12             ,
         JGZZ_ATTRIBUTE13             ,
         JGZZ_ATTRIBUTE14             ,
         JGZZ_ATTRIBUTE15             ,
         GLOBAL_ATTRIBUTE1            ,
         GLOBAL_ATTRIBUTE2            ,
         GLOBAL_ATTRIBUTE3            ,
         GLOBAL_ATTRIBUTE4            ,
         GLOBAL_ATTRIBUTE5            ,
         GLOBAL_ATTRIBUTE6            ,
         GLOBAL_ATTRIBUTE7            ,
         GLOBAL_ATTRIBUTE8            ,
         GLOBAL_ATTRIBUTE9            ,
         GLOBAL_ATTRIBUTE10           ,
         GLOBAL_ATTRIBUTE11           ,
         GLOBAL_ATTRIBUTE12           ,
         GLOBAL_ATTRIBUTE13           ,
         GLOBAL_ATTRIBUTE14           ,
         GLOBAL_ATTRIBUTE15           ,
         GLOBAL_ATTRIBUTE16           ,
         GLOBAL_ATTRIBUTE17           ,
         GLOBAL_ATTRIBUTE18           ,
         GLOBAL_ATTRIBUTE19           ,
         GLOBAL_ATTRIBUTE20           ,
         GLOBAL_ATTRIBUTE_CATEGORY    ,
         LAST_UPDATED_BY              ,
         LAST_UPDATE_DATE             ,
         CREATED_BY                   ,
         CREATION_DATE                ,
         LAST_UPDATE_LOGIN
    FROM hz_cust_prof_class_amts
   WHERE PROFILE_CLASS_AMOUNT_ID = p_info_rec.PROFILE_CLASS_AMOUNT_ID
   FOR UPDATE OF hz_cust_prof_class_amts.PROFILE_CLASS_AMOUNT_ID NOWAIT;

   l_info_rec   hz_cust_prof_class_amts%ROWTYPE;
BEGIN
  arp_standard.debug('lock_row +');
  arp_standard.debug('   PROFILE_CLASS_AMOUNT_ID:'||p_info_rec.PROFILE_CLASS_AMOUNT_ID);

  x_return_status := fnd_api.g_ret_sts_success;

  fnd_msg_pub.initialize;

  OPEN c;
  FETCH c INTO
         l_info_rec.PROFILE_CLASS_AMOUNT_ID      ,
         l_info_rec.PROFILE_CLASS_ID             ,
         l_info_rec.CURRENCY_CODE                ,
         l_info_rec.TRX_CREDIT_LIMIT             ,
         l_info_rec.OVERALL_CREDIT_LIMIT         ,
         l_info_rec.MIN_DUNNING_AMOUNT           ,
         l_info_rec.MAX_INTEREST_CHARGE          ,
         l_info_rec.MIN_INTEREST_CHARGE          ,
         l_info_rec.MIN_STATEMENT_AMOUNT         ,
         l_info_rec.AUTO_REC_MIN_RECEIPT_AMOUNT  ,
         l_info_rec.MIN_DUNNING_INVOICE_AMOUNT   ,
         l_info_rec.INTEREST_RATE                ,
         l_info_rec.EXPIRATION_DATE              ,
         l_info_rec.EXCHANGE_RATE_TYPE           ,
         l_info_rec.MIN_FC_INVOICE_OVERDUE_TYPE  ,
         l_info_rec.MIN_FC_INVOICE_PERCENT       ,
         l_info_rec.MIN_FC_INVOICE_AMOUNT        ,
         l_info_rec.MIN_FC_BALANCE_OVERDUE_TYPE  ,
         l_info_rec.MIN_FC_BALANCE_PERCENT       ,
         l_info_rec.MIN_FC_BALANCE_AMOUNT        ,
         l_info_rec.INTEREST_TYPE                ,
         l_info_rec.INTEREST_FIXED_AMOUNT        ,
         l_info_rec.INTEREST_SCHEDULE_ID         ,
         l_info_rec.PENALTY_TYPE                 ,
         l_info_rec.PENALTY_RATE                 ,
         l_info_rec.PENALTY_FIXED_AMOUNT         ,
         l_info_rec.PENALTY_SCHEDULE_ID          ,
         l_info_rec.ATTRIBUTE_CATEGORY           ,
         l_info_rec.ATTRIBUTE1                   ,
         l_info_rec.ATTRIBUTE2                   ,
         l_info_rec.ATTRIBUTE3                   ,
         l_info_rec.ATTRIBUTE4                   ,
         l_info_rec.ATTRIBUTE5                   ,
         l_info_rec.ATTRIBUTE6                   ,
         l_info_rec.ATTRIBUTE7                   ,
         l_info_rec.ATTRIBUTE8                   ,
         l_info_rec.ATTRIBUTE9                   ,
         l_info_rec.ATTRIBUTE10                  ,
         l_info_rec.ATTRIBUTE11                  ,
         l_info_rec.ATTRIBUTE12                  ,
         l_info_rec.ATTRIBUTE13                  ,
         l_info_rec.ATTRIBUTE14                  ,
         l_info_rec.ATTRIBUTE15                  ,
         l_info_rec.JGZZ_ATTRIBUTE_CATEGORY      ,
         l_info_rec.JGZZ_ATTRIBUTE1              ,
         l_info_rec.JGZZ_ATTRIBUTE2              ,
         l_info_rec.JGZZ_ATTRIBUTE3              ,
         l_info_rec.JGZZ_ATTRIBUTE4              ,
         l_info_rec.JGZZ_ATTRIBUTE5              ,
         l_info_rec.JGZZ_ATTRIBUTE6              ,
         l_info_rec.JGZZ_ATTRIBUTE7              ,
         l_info_rec.JGZZ_ATTRIBUTE8              ,
         l_info_rec.JGZZ_ATTRIBUTE9              ,
         l_info_rec.JGZZ_ATTRIBUTE10             ,
         l_info_rec.JGZZ_ATTRIBUTE11             ,
         l_info_rec.JGZZ_ATTRIBUTE12             ,
         l_info_rec.JGZZ_ATTRIBUTE13             ,
         l_info_rec.JGZZ_ATTRIBUTE14             ,
         l_info_rec.JGZZ_ATTRIBUTE15             ,
         l_info_rec.GLOBAL_ATTRIBUTE1            ,
         l_info_rec.GLOBAL_ATTRIBUTE2            ,
         l_info_rec.GLOBAL_ATTRIBUTE3            ,
         l_info_rec.GLOBAL_ATTRIBUTE4            ,
         l_info_rec.GLOBAL_ATTRIBUTE5            ,
         l_info_rec.GLOBAL_ATTRIBUTE6            ,
         l_info_rec.GLOBAL_ATTRIBUTE7            ,
         l_info_rec.GLOBAL_ATTRIBUTE8            ,
         l_info_rec.GLOBAL_ATTRIBUTE9            ,
         l_info_rec.GLOBAL_ATTRIBUTE10           ,
         l_info_rec.GLOBAL_ATTRIBUTE11           ,
         l_info_rec.GLOBAL_ATTRIBUTE12           ,
         l_info_rec.GLOBAL_ATTRIBUTE13           ,
         l_info_rec.GLOBAL_ATTRIBUTE14           ,
         l_info_rec.GLOBAL_ATTRIBUTE15           ,
         l_info_rec.GLOBAL_ATTRIBUTE16           ,
         l_info_rec.GLOBAL_ATTRIBUTE17           ,
         l_info_rec.GLOBAL_ATTRIBUTE18           ,
         l_info_rec.GLOBAL_ATTRIBUTE19           ,
         l_info_rec.GLOBAL_ATTRIBUTE20           ,
         l_info_rec.GLOBAL_ATTRIBUTE_CATEGORY    ,
         l_info_rec.LAST_UPDATED_BY              ,
         l_info_rec.LAST_UPDATE_DATE             ,
         l_info_rec.CREATED_BY                   ,
         l_info_rec.CREATION_DATE                ,
         l_info_rec.LAST_UPDATE_LOGIN;
     IF c%NOTFOUND THEN
       RAISE NO_DATA_FOUND;
     END IF;
   CLOSE c;

   IF (     l_info_rec.PROFILE_CLASS_AMOUNT_ID = p_info_rec.PROFILE_CLASS_AMOUNT_ID
        AND l_info_rec.PROFILE_CLASS_ID        = p_info_rec.PROFILE_CLASS_ID
        AND l_info_rec.CURRENCY_CODE           = p_info_rec.CURRENCY_CODE
        AND elementequal(l_info_rec.TRX_CREDIT_LIMIT    , p_info_rec.TRX_CREDIT_LIMIT)
        AND elementequal(l_info_rec.OVERALL_CREDIT_LIMIT, p_info_rec.OVERALL_CREDIT_LIMIT)
        AND elementequal(l_info_rec.MIN_DUNNING_AMOUNT  , p_info_rec.MIN_DUNNING_AMOUNT)
        AND elementequal(l_info_rec.MAX_INTEREST_CHARGE , p_info_rec.MAX_INTEREST_CHARGE)
        AND elementequal(l_info_rec.MIN_INTEREST_CHARGE , p_info_rec.MIN_INTEREST_CHARGE)
        AND elementequal(l_info_rec.MIN_STATEMENT_AMOUNT, p_info_rec.MIN_STATEMENT_AMOUNT)
        AND elementequal(l_info_rec.AUTO_REC_MIN_RECEIPT_AMOUNT, p_info_rec.AUTO_REC_MIN_RECEIPT_AMOUNT)
        AND elementequal(l_info_rec.MIN_DUNNING_INVOICE_AMOUNT, p_info_rec.MIN_DUNNING_INVOICE_AMOUNT)
        AND elementequal(l_info_rec.INTEREST_RATE       , p_info_rec.INTEREST_RATE)
        AND elementequal(l_info_rec.EXPIRATION_DATE     , p_info_rec.EXPIRATION_DATE)
        AND elementequal(l_info_rec.EXCHANGE_RATE_TYPE  , p_info_rec.EXCHANGE_RATE_TYPE)
        AND elementequal(l_info_rec.MIN_FC_INVOICE_OVERDUE_TYPE, p_info_rec.MIN_FC_INVOICE_OVERDUE_TYPE)
        AND elementequal(l_info_rec.MIN_FC_INVOICE_PERCENT     , p_info_rec.MIN_FC_INVOICE_PERCENT)
        AND elementequal(l_info_rec.MIN_FC_INVOICE_AMOUNT      , p_info_rec.MIN_FC_INVOICE_AMOUNT)
        AND elementequal(l_info_rec.MIN_FC_BALANCE_OVERDUE_TYPE, p_info_rec.MIN_FC_BALANCE_OVERDUE_TYPE)
        AND elementequal(l_info_rec.MIN_FC_BALANCE_PERCENT ,  p_info_rec.MIN_FC_BALANCE_PERCENT )
        AND elementequal(l_info_rec.MIN_FC_BALANCE_AMOUNT  ,  p_info_rec.MIN_FC_BALANCE_AMOUNT)
        AND elementequal(l_info_rec.INTEREST_TYPE          ,  p_info_rec.INTEREST_TYPE)
        AND elementequal(l_info_rec.INTEREST_FIXED_AMOUNT  ,  p_info_rec.INTEREST_FIXED_AMOUNT)
        AND elementequal(l_info_rec.INTEREST_SCHEDULE_ID   ,  p_info_rec.INTEREST_SCHEDULE_ID)
        AND elementequal(l_info_rec.PENALTY_TYPE   ,  p_info_rec.PENALTY_TYPE)
        AND elementequal(l_info_rec.PENALTY_RATE   ,  p_info_rec.PENALTY_RATE)
        AND elementequal(l_info_rec.PENALTY_FIXED_AMOUNT   ,  p_info_rec.PENALTY_FIXED_AMOUNT)
        AND elementequal(l_info_rec.PENALTY_SCHEDULE_ID    ,  p_info_rec.PENALTY_SCHEDULE_ID)
        AND elementequal(l_info_rec.ATTRIBUTE_CATEGORY     ,  p_info_rec.ATTRIBUTE_CATEGORY)
        AND elementequal(l_info_rec.ATTRIBUTE1      ,  p_info_rec.ATTRIBUTE1)
        AND elementequal(l_info_rec.ATTRIBUTE2      ,  p_info_rec.ATTRIBUTE2)
        AND elementequal(l_info_rec.ATTRIBUTE3      ,  p_info_rec.ATTRIBUTE3)
        AND elementequal(l_info_rec.ATTRIBUTE4      ,  p_info_rec.ATTRIBUTE4)
        AND elementequal(l_info_rec.ATTRIBUTE5      ,  p_info_rec.ATTRIBUTE5)
        AND elementequal(l_info_rec.ATTRIBUTE6      ,  p_info_rec.ATTRIBUTE6)
        AND elementequal(l_info_rec.ATTRIBUTE7      ,  p_info_rec.ATTRIBUTE7)
        AND elementequal(l_info_rec.ATTRIBUTE8      ,  p_info_rec.ATTRIBUTE8)
        AND elementequal(l_info_rec.ATTRIBUTE9      ,  p_info_rec.ATTRIBUTE9)
        AND elementequal(l_info_rec.ATTRIBUTE10     ,  p_info_rec.ATTRIBUTE10)
        AND elementequal(l_info_rec.ATTRIBUTE11     ,  p_info_rec.ATTRIBUTE11)
        AND elementequal(l_info_rec.ATTRIBUTE12     ,  p_info_rec.ATTRIBUTE12)
        AND elementequal(l_info_rec.ATTRIBUTE13     ,  p_info_rec.ATTRIBUTE13)
        AND elementequal(l_info_rec.ATTRIBUTE14     ,  p_info_rec.ATTRIBUTE14)
        AND elementequal(l_info_rec.ATTRIBUTE15     ,  p_info_rec.ATTRIBUTE15)
        AND elementequal(l_info_rec.JGZZ_ATTRIBUTE_CATEGORY,  p_info_rec.JGZZ_ATTRIBUTE_CATEGORY)
        AND elementequal(l_info_rec.JGZZ_ATTRIBUTE1      ,  p_info_rec.JGZZ_ATTRIBUTE1)
        AND elementequal(l_info_rec.JGZZ_ATTRIBUTE2      ,  p_info_rec.JGZZ_ATTRIBUTE2)
        AND elementequal(l_info_rec.JGZZ_ATTRIBUTE3      ,  p_info_rec.JGZZ_ATTRIBUTE3)
        AND elementequal(l_info_rec.JGZZ_ATTRIBUTE4      ,  p_info_rec.JGZZ_ATTRIBUTE4)
        AND elementequal(l_info_rec.JGZZ_ATTRIBUTE5      ,  p_info_rec.JGZZ_ATTRIBUTE5)
        AND elementequal(l_info_rec.JGZZ_ATTRIBUTE6      ,  p_info_rec.JGZZ_ATTRIBUTE6)
        AND elementequal(l_info_rec.JGZZ_ATTRIBUTE7      ,  p_info_rec.JGZZ_ATTRIBUTE7)
        AND elementequal(l_info_rec.JGZZ_ATTRIBUTE8      ,  p_info_rec.JGZZ_ATTRIBUTE8)
        AND elementequal(l_info_rec.JGZZ_ATTRIBUTE9      ,  p_info_rec.JGZZ_ATTRIBUTE9)
        AND elementequal(l_info_rec.JGZZ_ATTRIBUTE10     ,  p_info_rec.JGZZ_ATTRIBUTE10)
        AND elementequal(l_info_rec.JGZZ_ATTRIBUTE11     ,  p_info_rec.JGZZ_ATTRIBUTE11)
        AND elementequal(l_info_rec.JGZZ_ATTRIBUTE12     ,  p_info_rec.JGZZ_ATTRIBUTE12)
        AND elementequal(l_info_rec.JGZZ_ATTRIBUTE13     ,  p_info_rec.JGZZ_ATTRIBUTE13)
        AND elementequal(l_info_rec.JGZZ_ATTRIBUTE14     ,  p_info_rec.JGZZ_ATTRIBUTE14)
        AND elementequal(l_info_rec.JGZZ_ATTRIBUTE15     ,  p_info_rec.JGZZ_ATTRIBUTE15)
        AND elementequal(l_info_rec.GLOBAL_ATTRIBUTE_CATEGORY,  p_info_rec.GLOBAL_ATTRIBUTE_CATEGORY)
        AND elementequal(l_info_rec.GLOBAL_ATTRIBUTE1      ,  p_info_rec.GLOBAL_ATTRIBUTE1)
        AND elementequal(l_info_rec.GLOBAL_ATTRIBUTE2      ,  p_info_rec.GLOBAL_ATTRIBUTE2)
        AND elementequal(l_info_rec.GLOBAL_ATTRIBUTE3      ,  p_info_rec.GLOBAL_ATTRIBUTE3)
        AND elementequal(l_info_rec.GLOBAL_ATTRIBUTE4      ,  p_info_rec.GLOBAL_ATTRIBUTE4)
        AND elementequal(l_info_rec.GLOBAL_ATTRIBUTE5      ,  p_info_rec.GLOBAL_ATTRIBUTE5)
        AND elementequal(l_info_rec.GLOBAL_ATTRIBUTE6      ,  p_info_rec.GLOBAL_ATTRIBUTE6)
        AND elementequal(l_info_rec.GLOBAL_ATTRIBUTE7      ,  p_info_rec.GLOBAL_ATTRIBUTE7)
        AND elementequal(l_info_rec.GLOBAL_ATTRIBUTE8      ,  p_info_rec.GLOBAL_ATTRIBUTE8)
        AND elementequal(l_info_rec.GLOBAL_ATTRIBUTE9      ,  p_info_rec.GLOBAL_ATTRIBUTE9)
        AND elementequal(l_info_rec.GLOBAL_ATTRIBUTE10     ,  p_info_rec.GLOBAL_ATTRIBUTE10)
        AND elementequal(l_info_rec.GLOBAL_ATTRIBUTE11     ,  p_info_rec.GLOBAL_ATTRIBUTE11)
        AND elementequal(l_info_rec.GLOBAL_ATTRIBUTE12     ,  p_info_rec.GLOBAL_ATTRIBUTE12)
        AND elementequal(l_info_rec.GLOBAL_ATTRIBUTE13     ,  p_info_rec.GLOBAL_ATTRIBUTE13)
        AND elementequal(l_info_rec.GLOBAL_ATTRIBUTE14     ,  p_info_rec.GLOBAL_ATTRIBUTE14)
        AND elementequal(l_info_rec.GLOBAL_ATTRIBUTE15     ,  p_info_rec.GLOBAL_ATTRIBUTE15)
        AND elementequal(l_info_rec.GLOBAL_ATTRIBUTE16     ,  p_info_rec.GLOBAL_ATTRIBUTE16)
        AND elementequal(l_info_rec.GLOBAL_ATTRIBUTE17     ,  p_info_rec.GLOBAL_ATTRIBUTE17)
        AND elementequal(l_info_rec.GLOBAL_ATTRIBUTE18     ,  p_info_rec.GLOBAL_ATTRIBUTE18)
        AND elementequal(l_info_rec.GLOBAL_ATTRIBUTE19     ,  p_info_rec.GLOBAL_ATTRIBUTE19)
        AND elementequal(l_info_rec.GLOBAL_ATTRIBUTE20     ,  p_info_rec.GLOBAL_ATTRIBUTE20)
        AND elementequal(l_info_rec.GLOBAL_ATTRIBUTE15     ,  p_info_rec.GLOBAL_ATTRIBUTE15)
        AND elementequal(l_info_rec.LAST_UPDATE_DATE       ,  p_info_rec.LAST_UPDATE_DATE)   )
   THEN
      RETURN;
   ELSE
      fnd_message.set_name('AR', 'HZ_API_RECORD_CHANGED');
      fnd_message.set_token('TABLE', 'hz_cust_prof_class_amts');
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_error;
   END IF;

  arp_standard.debug('lock_row -');
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);
     arp_standard.debug('EXCEPTION ar_cust_prof_class_amt_pkg.lock_row:'||x_msg_data);

   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);
     arp_standard.debug('EXCEPTION OTHERS ar_cust_prof_class_amt_pkg.lock_row:'||x_msg_data);
END;




PROCEDURE update_row
(P_PROFILE_CLASS_AMOUNT_ID      IN NUMBER,
 P_CURRENCY_CODE                IN VARCHAR2,
 P_TRX_CREDIT_LIMIT             IN NUMBER,
 P_OVERALL_CREDIT_LIMIT         IN NUMBER,
 P_MIN_DUNNING_AMOUNT           IN NUMBER,
 P_MAX_INTEREST_CHARGE          IN NUMBER,
 P_MIN_INTEREST_CHARGE          IN NUMBER,
 P_MIN_STATEMENT_AMOUNT         IN NUMBER,
 P_AUTO_REC_MIN_RECEIPT_AMOUNT  IN NUMBER,
 P_MIN_DUNNING_INVOICE_AMOUNT   IN NUMBER,
 P_INTEREST_RATE                IN NUMBER,
 P_EXPIRATION_DATE              IN DATE,
 P_EXCHANGE_RATE_TYPE           IN VARCHAR2,
 P_MIN_FC_INVOICE_OVERDUE_TYPE  IN VARCHAR2,
 P_MIN_FC_INVOICE_PERCENT       IN NUMBER,
 P_MIN_FC_INVOICE_AMOUNT        IN NUMBER,
 P_MIN_FC_BALANCE_OVERDUE_TYPE  IN VARCHAR2,
 P_MIN_FC_BALANCE_PERCENT       IN NUMBER,
 P_MIN_FC_BALANCE_AMOUNT        IN NUMBER,
 P_INTEREST_TYPE                IN VARCHAR2,
 P_INTEREST_FIXED_AMOUNT        IN NUMBER,
 P_INTEREST_SCHEDULE_ID         IN NUMBER,
 P_PENALTY_TYPE                 IN VARCHAR2,
 P_PENALTY_RATE                 IN NUMBER,
 P_PENALTY_FIXED_AMOUNT         IN NUMBER,
 P_PENALTY_SCHEDULE_ID          IN NUMBER,
 P_ATTRIBUTE_CATEGORY           IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE1                   IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE2                   IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE3                   IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE4                   IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE5                   IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE6                   IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE7                   IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE8                   IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE9                   IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE10                  IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE11                  IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE12                  IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE13                  IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE14                  IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE15                  IN VARCHAR2 DEFAULT NULL,
 P_JGZZ_ATTRIBUTE_CATEGORY      IN VARCHAR2 DEFAULT NULL,
 P_JGZZ_ATTRIBUTE1              IN VARCHAR2 DEFAULT NULL,
 P_JGZZ_ATTRIBUTE2              IN VARCHAR2 DEFAULT NULL,
 P_JGZZ_ATTRIBUTE3              IN VARCHAR2 DEFAULT NULL,
 P_JGZZ_ATTRIBUTE4              IN VARCHAR2 DEFAULT NULL,
 P_JGZZ_ATTRIBUTE5              IN VARCHAR2 DEFAULT NULL,
 P_JGZZ_ATTRIBUTE6              IN VARCHAR2 DEFAULT NULL,
 P_JGZZ_ATTRIBUTE7              IN VARCHAR2 DEFAULT NULL,
 P_JGZZ_ATTRIBUTE8              IN VARCHAR2 DEFAULT NULL,
 P_JGZZ_ATTRIBUTE9              IN VARCHAR2 DEFAULT NULL,
 P_JGZZ_ATTRIBUTE10             IN VARCHAR2 DEFAULT NULL,
 P_JGZZ_ATTRIBUTE11             IN VARCHAR2 DEFAULT NULL,
 P_JGZZ_ATTRIBUTE12             IN VARCHAR2 DEFAULT NULL,
 P_JGZZ_ATTRIBUTE13             IN VARCHAR2 DEFAULT NULL,
 P_JGZZ_ATTRIBUTE14             IN VARCHAR2 DEFAULT NULL,
 P_JGZZ_ATTRIBUTE15             IN VARCHAR2 DEFAULT NULL,
 P_GLOBAL_ATTRIBUTE1            IN VARCHAR2 DEFAULT NULL,
 P_GLOBAL_ATTRIBUTE2            IN VARCHAR2 DEFAULT NULL,
 P_GLOBAL_ATTRIBUTE3            IN VARCHAR2 DEFAULT NULL,
 P_GLOBAL_ATTRIBUTE4            IN VARCHAR2 DEFAULT NULL,
 P_GLOBAL_ATTRIBUTE5            IN VARCHAR2 DEFAULT NULL,
 P_GLOBAL_ATTRIBUTE6            IN VARCHAR2 DEFAULT NULL,
 P_GLOBAL_ATTRIBUTE7            IN VARCHAR2 DEFAULT NULL,
 P_GLOBAL_ATTRIBUTE8            IN VARCHAR2 DEFAULT NULL,
 P_GLOBAL_ATTRIBUTE9            IN VARCHAR2 DEFAULT NULL,
 P_GLOBAL_ATTRIBUTE10           IN VARCHAR2 DEFAULT NULL,
 P_GLOBAL_ATTRIBUTE11           IN VARCHAR2 DEFAULT NULL,
 P_GLOBAL_ATTRIBUTE12           IN VARCHAR2 DEFAULT NULL,
 P_GLOBAL_ATTRIBUTE13           IN VARCHAR2 DEFAULT NULL,
 P_GLOBAL_ATTRIBUTE14           IN VARCHAR2 DEFAULT NULL,
 P_GLOBAL_ATTRIBUTE15           IN VARCHAR2 DEFAULT NULL,
 P_GLOBAL_ATTRIBUTE16           IN VARCHAR2 DEFAULT NULL,
 P_GLOBAL_ATTRIBUTE17           IN VARCHAR2 DEFAULT NULL,
 P_GLOBAL_ATTRIBUTE18           IN VARCHAR2 DEFAULT NULL,
 P_GLOBAL_ATTRIBUTE19           IN VARCHAR2 DEFAULT NULL,
 P_GLOBAL_ATTRIBUTE20           IN VARCHAR2 DEFAULT NULL,
 P_GLOBAL_ATTRIBUTE_CATEGORY    IN VARCHAR2 DEFAULT NULL,
 P_LAST_UPDATED_BY              IN NUMBER   DEFAULT -1,
 P_LAST_UPDATE_LOGIN            IN NUMBER   DEFAULT -1,
 x_return_status                OUT NOCOPY  VARCHAR2,
 x_msg_count                    OUT NOCOPY  NUMBER,
 x_msg_data                     OUT NOCOPY  VARCHAR2)
IS
BEGIN
arp_standard.debug('ar_cust_prof_class_amt_pkg.update_row +');
arp_standard.debug('   P_PROFILE_CLASS_AMOUNT_ID :'||P_PROFILE_CLASS_AMOUNT_ID);

 x_return_status  := fnd_api.g_ret_Sts_success;

 fnd_msg_pub.initialize;

 validate_prof_class_amt
 (P_CURRENCY_CODE                => p_currency_code,
  P_TRX_CREDIT_LIMIT             => P_TRX_CREDIT_LIMIT,
  P_OVERALL_CREDIT_LIMIT         => P_OVERALL_CREDIT_LIMIT,
  P_MIN_DUNNING_AMOUNT           => P_MIN_DUNNING_AMOUNT,
  P_MAX_INTEREST_CHARGE          => P_MAX_INTEREST_CHARGE,
  P_MIN_INTEREST_CHARGE          => P_MIN_INTEREST_CHARGE,
  P_MIN_STATEMENT_AMOUNT         => P_MIN_STATEMENT_AMOUNT,
  P_AUTO_REC_MIN_RECEIPT_AMOUNT  => P_AUTO_REC_MIN_RECEIPT_AMOUNT,
  P_MIN_DUNNING_INVOICE_AMOUNT   => P_MIN_DUNNING_INVOICE_AMOUNT,
  P_INTEREST_RATE                => P_INTEREST_RATE,
  P_EXPIRATION_DATE              => P_EXPIRATION_DATE,
  P_EXCHANGE_RATE_TYPE           => P_EXCHANGE_RATE_TYPE,
  P_MIN_FC_INVOICE_OVERDUE_TYPE  => P_MIN_FC_INVOICE_OVERDUE_TYPE,
  P_MIN_FC_INVOICE_PERCENT       => P_MIN_FC_INVOICE_PERCENT,
  P_MIN_FC_INVOICE_AMOUNT        => P_MIN_FC_INVOICE_AMOUNT,
  P_MIN_FC_BALANCE_OVERDUE_TYPE  => P_MIN_FC_BALANCE_OVERDUE_TYPE,
  P_MIN_FC_BALANCE_PERCENT       => P_MIN_FC_BALANCE_PERCENT,
  P_MIN_FC_BALANCE_AMOUNT        => P_MIN_FC_BALANCE_AMOUNT,
  P_INTEREST_TYPE                => P_INTEREST_TYPE,
  P_INTEREST_FIXED_AMOUNT        => P_INTEREST_FIXED_AMOUNT,
  P_INTEREST_SCHEDULE_ID         => P_INTEREST_SCHEDULE_ID,
  P_PENALTY_TYPE                 => P_PENALTY_TYPE,
  P_PENALTY_RATE                 => P_PENALTY_RATE,
  P_PENALTY_FIXED_AMOUNT         => P_PENALTY_FIXED_AMOUNT,
  P_PENALTY_SCHEDULE_ID          => P_PENALTY_SCHEDULE_ID,
  x_return_status                => x_return_status);

 IF  x_return_status <> fnd_api.g_ret_Sts_success THEN
   RAISE fnd_api.G_EXC_ERROR;
 END IF;

 arp_standard.debug(' Updating into hz_cust_prof_class_amts+');
 arp_standard.debug(' P_TRX_CREDIT_LIMIT:'||P_TRX_CREDIT_LIMIT);

 UPDATE hz_cust_prof_class_Amts
 SET
  CURRENCY_CODE               = P_CURRENCY_CODE,
  TRX_CREDIT_LIMIT            = P_TRX_CREDIT_LIMIT,
  OVERALL_CREDIT_LIMIT        = P_OVERALL_CREDIT_LIMIT,
  MIN_DUNNING_AMOUNT          = P_MIN_DUNNING_AMOUNT,
  MAX_INTEREST_CHARGE         = P_MAX_INTEREST_CHARGE,
  MIN_INTEREST_CHARGE         = P_MIN_INTEREST_CHARGE,
  MIN_STATEMENT_AMOUNT        = P_MIN_STATEMENT_AMOUNT,
  AUTO_REC_MIN_RECEIPT_AMOUNT = P_AUTO_REC_MIN_RECEIPT_AMOUNT,
  MIN_DUNNING_INVOICE_AMOUNT  = P_MIN_DUNNING_INVOICE_AMOUNT,
  INTEREST_RATE               = P_INTEREST_RATE,
  EXPIRATION_DATE             = P_EXPIRATION_DATE,
  EXCHANGE_RATE_TYPE          = P_EXCHANGE_RATE_TYPE,
  MIN_FC_INVOICE_OVERDUE_TYPE = P_MIN_FC_INVOICE_OVERDUE_TYPE,
  MIN_FC_INVOICE_PERCENT      = P_MIN_FC_INVOICE_PERCENT,
  MIN_FC_INVOICE_AMOUNT       = P_MIN_FC_INVOICE_AMOUNT,
  MIN_FC_BALANCE_OVERDUE_TYPE = P_MIN_FC_BALANCE_OVERDUE_TYPE,
  MIN_FC_BALANCE_PERCENT      = P_MIN_FC_BALANCE_PERCENT,
  MIN_FC_BALANCE_AMOUNT       = P_MIN_FC_BALANCE_AMOUNT,
  INTEREST_TYPE               = P_INTEREST_TYPE,
  INTEREST_FIXED_AMOUNT       = P_INTEREST_FIXED_AMOUNT,
  INTEREST_SCHEDULE_ID        = P_INTEREST_SCHEDULE_ID,
  PENALTY_TYPE                = P_PENALTY_TYPE,
  PENALTY_RATE                = P_PENALTY_RATE,
  PENALTY_FIXED_AMOUNT        = P_PENALTY_FIXED_AMOUNT,
  PENALTY_SCHEDULE_ID         = P_PENALTY_SCHEDULE_ID,
  ATTRIBUTE_CATEGORY          = P_ATTRIBUTE_CATEGORY,
  ATTRIBUTE1                  = P_ATTRIBUTE1,
  ATTRIBUTE2                  = P_ATTRIBUTE2,
  ATTRIBUTE3                  = P_ATTRIBUTE3,
  ATTRIBUTE4                  = P_ATTRIBUTE4,
  ATTRIBUTE5                  = P_ATTRIBUTE5,
  ATTRIBUTE6                  = P_ATTRIBUTE6,
  ATTRIBUTE7                  = P_ATTRIBUTE7,
  ATTRIBUTE8                  = P_ATTRIBUTE8,
  ATTRIBUTE9                  = P_ATTRIBUTE9,
  ATTRIBUTE10                 = P_ATTRIBUTE10,
  ATTRIBUTE11                 = P_ATTRIBUTE11,
  ATTRIBUTE12                 = P_ATTRIBUTE12,
  ATTRIBUTE13                 = P_ATTRIBUTE13,
  ATTRIBUTE14                 = P_ATTRIBUTE14,
  ATTRIBUTE15                 = P_ATTRIBUTE15,
  JGZZ_ATTRIBUTE_CATEGORY     = P_JGZZ_ATTRIBUTE_CATEGORY,
  JGZZ_ATTRIBUTE1             = P_JGZZ_ATTRIBUTE1,
  JGZZ_ATTRIBUTE2             = P_JGZZ_ATTRIBUTE2,
  JGZZ_ATTRIBUTE3             = P_JGZZ_ATTRIBUTE3,
  JGZZ_ATTRIBUTE4             = P_JGZZ_ATTRIBUTE4,
  JGZZ_ATTRIBUTE5             = P_JGZZ_ATTRIBUTE5,
  JGZZ_ATTRIBUTE6             = P_JGZZ_ATTRIBUTE6,
  JGZZ_ATTRIBUTE7             = P_JGZZ_ATTRIBUTE7,
  JGZZ_ATTRIBUTE8             = P_JGZZ_ATTRIBUTE8,
  JGZZ_ATTRIBUTE9             = P_JGZZ_ATTRIBUTE9,
  JGZZ_ATTRIBUTE10            = P_JGZZ_ATTRIBUTE10,
  JGZZ_ATTRIBUTE11            = P_JGZZ_ATTRIBUTE11,
  JGZZ_ATTRIBUTE12            = P_JGZZ_ATTRIBUTE12,
  JGZZ_ATTRIBUTE13            = P_JGZZ_ATTRIBUTE13,
  JGZZ_ATTRIBUTE14            = P_JGZZ_ATTRIBUTE14,
  JGZZ_ATTRIBUTE15            = P_JGZZ_ATTRIBUTE15,
  GLOBAL_ATTRIBUTE1           = P_GLOBAL_ATTRIBUTE1,
  GLOBAL_ATTRIBUTE2           = P_GLOBAL_ATTRIBUTE2,
  GLOBAL_ATTRIBUTE3           = P_GLOBAL_ATTRIBUTE3,
  GLOBAL_ATTRIBUTE4           = P_GLOBAL_ATTRIBUTE4,
  GLOBAL_ATTRIBUTE5           = P_GLOBAL_ATTRIBUTE5,
  GLOBAL_ATTRIBUTE6           = P_GLOBAL_ATTRIBUTE6,
  GLOBAL_ATTRIBUTE7           = P_GLOBAL_ATTRIBUTE7,
  GLOBAL_ATTRIBUTE8           = P_GLOBAL_ATTRIBUTE8,
  GLOBAL_ATTRIBUTE9           = P_GLOBAL_ATTRIBUTE9,
  GLOBAL_ATTRIBUTE10          = P_GLOBAL_ATTRIBUTE10,
  GLOBAL_ATTRIBUTE11          = P_GLOBAL_ATTRIBUTE11,
  GLOBAL_ATTRIBUTE12          = P_GLOBAL_ATTRIBUTE12,
  GLOBAL_ATTRIBUTE13          = P_GLOBAL_ATTRIBUTE13,
  GLOBAL_ATTRIBUTE14          = P_GLOBAL_ATTRIBUTE14,
  GLOBAL_ATTRIBUTE15          = P_GLOBAL_ATTRIBUTE15,
  GLOBAL_ATTRIBUTE16          = P_GLOBAL_ATTRIBUTE16,
  GLOBAL_ATTRIBUTE17          = P_GLOBAL_ATTRIBUTE17,
  GLOBAL_ATTRIBUTE18          = P_GLOBAL_ATTRIBUTE18,
  GLOBAL_ATTRIBUTE19          = P_GLOBAL_ATTRIBUTE19,
  GLOBAL_ATTRIBUTE20          = P_GLOBAL_ATTRIBUTE20,
  GLOBAL_ATTRIBUTE_CATEGORY   = P_GLOBAL_ATTRIBUTE_CATEGORY,
  LAST_UPDATED_BY             = P_LAST_UPDATED_BY,
  LAST_UPDATE_DATE            = SYSDATE,
  LAST_UPDATE_LOGIN           = P_LAST_UPDATE_LOGIN
 WHERE PROFILE_CLASS_AMOUNT_ID = P_PROFILE_CLASS_AMOUNT_ID;

arp_standard.debug('  updating hz_cust_prof_class_amts -');

arp_standard.debug('ar_cust_prof_class_amt_pkg.update_row -');
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);
     arp_standard.debug('EXCEPTION ar_cust_prof_class_amt_pkg.update_row:'||x_msg_data);

  WHEN OTHERS THEN
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
    fnd_message.set_token('ERROR' ,SQLERRM);
    fnd_msg_pub.add;
    fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                              p_count => x_msg_count,
                              p_data  => x_msg_data);
    arp_standard.debug('EXCEPTION OTHERS IN ar_cust_prof_class_amt_pkg.update_row:'||SQLERRM);
END;





PROCEDURE Insert_Negative_Class_Amt
(         X_Customer_Profile_Class_Id      NUMBER,
          X_Created_By                     NUMBER,
          X_Creation_Date                  DATE,
          X_Currency_Code                  VARCHAR2,
          X_Cust_Prof_Class_Amount_Id      NUMBER,
          X_Last_Updated_By                NUMBER,
          X_Last_Update_Date               DATE,
          X_Auto_Rec_Min_Receipt_Amount    NUMBER,
          X_Last_Update_Login              NUMBER,
          X_Max_Interest_Charge            NUMBER,
          X_Min_Dunning_Amount             NUMBER,
          X_Min_Statement_Amount           NUMBER,
          X_Overall_Credit_Limit           NUMBER,
          X_Trx_Credit_Limit               NUMBER,
          X_Attribute_Category             VARCHAR2,
          X_Attribute1                     VARCHAR2,
          X_Attribute2                     VARCHAR2,
          X_Attribute3                     VARCHAR2,
          X_Attribute4                     VARCHAR2,
          X_Attribute5                     VARCHAR2,
          X_Attribute6                     VARCHAR2,
          X_Attribute7                     VARCHAR2,
          X_Attribute8                     VARCHAR2,
          X_Attribute9                     VARCHAR2,
          X_Attribute10                    VARCHAR2,
          X_Attribute11                    VARCHAR2,
          X_Attribute12                    VARCHAR2,
          X_Attribute13                    VARCHAR2,
          X_Attribute14                    VARCHAR2,
          X_Attribute15                    VARCHAR2,
          X_Interest_Rate                  NUMBER,
          X_Min_Fc_Balance_Amount          NUMBER,
          X_Min_Fc_Invoice_Amount          NUMBER,
          X_Min_Dunning_Invoice_Amount     NUMBER,
          X_Jgzz_attribute_Category             VARCHAR2,
          X_Jgzz_attribute1                     VARCHAR2,
          X_Jgzz_attribute2                     VARCHAR2,
          X_Jgzz_attribute3                     VARCHAR2,
          X_Jgzz_attribute4                     VARCHAR2,
          X_Jgzz_attribute5                     VARCHAR2,
          X_Jgzz_attribute6                     VARCHAR2,
          X_Jgzz_attribute7                     VARCHAR2,
          X_Jgzz_attribute8                     VARCHAR2,
          X_Jgzz_attribute9                     VARCHAR2,
          X_Jgzz_attribute10                    VARCHAR2,
          X_Jgzz_attribute11                    VARCHAR2,
          X_Jgzz_attribute12                    VARCHAR2,
          X_Jgzz_attribute13                    VARCHAR2,
          X_Jgzz_attribute14                    VARCHAR2,
          X_Jgzz_attribute15                    VARCHAR2,
          --Late Charges
          X_EXCHANGE_RATE_TYPE                  VARCHAR2,
          X_MIN_FC_INVOICE_OVERDUE_TYPE         VARCHAR2,
          X_MIN_FC_INVOICE_PERCENT              NUMBER,
          X_MIN_FC_BALANCE_OVERDUE_TYPE         VARCHAR2,
          X_MIN_FC_BALANCE_PERCENT              NUMBER,
          X_INTEREST_TYPE                       VARCHAR2,
          X_INTEREST_FIXED_AMOUNT               NUMBER,
          X_INTEREST_SCHEDULE_ID                NUMBER,
          X_PENALTY_TYPE                        VARCHAR2,
          X_PENALTY_RATE                        NUMBER,
          X_PENALTY_FIXED_AMOUNT                NUMBER,
          X_PENALTY_SCHEDULE_ID                 NUMBER,
          X_MIN_INTEREST_CHARGE                 NUMBER
) IS

BEGIN
  INSERT INTO HZ_CUST_PROF_CLASS_AMTS
  (
         profile_class_id,
         created_by,
         creation_date,
         currency_code,
         profile_class_amount_id,
         last_updated_by,
         last_update_date,
         auto_rec_min_receipt_amount,
         last_update_login,
         max_interest_charge,
         MIN_INTEREST_CHARGE,
         min_dunning_amount,
         min_statement_amount,
         overall_credit_limit,
         trx_credit_limit,
         attribute_category,
         attribute1,
         attribute2,
         attribute3,
         attribute4,
         attribute5,
         attribute6,
         attribute7,
         attribute8,
         attribute9,
         attribute10,
         attribute11,
         attribute12,
         attribute13,
         attribute14,
         attribute15,
         interest_rate,
         min_fc_balance_amount,
         min_fc_invoice_amount,
         min_dunning_invoice_amount,
         Jgzz_attribute_Category,
         Jgzz_attribute1,
         Jgzz_attribute2,
         Jgzz_attribute3,
         Jgzz_attribute4,
         Jgzz_attribute5,
         Jgzz_attribute6,
         Jgzz_attribute7,
         Jgzz_attribute8,
         Jgzz_attribute9,
         Jgzz_attribute10,
         Jgzz_attribute11,
         Jgzz_attribute12,
         Jgzz_attribute13,
         Jgzz_attribute14,
         Jgzz_attribute15,
         --{Late Charges
         EXCHANGE_RATE_TYPE,
         MIN_FC_INVOICE_OVERDUE_TYPE,
         MIN_FC_INVOICE_PERCENT,
         MIN_FC_BALANCE_OVERDUE_TYPE,
         MIN_FC_BALANCE_PERCENT,
         INTEREST_TYPE       ,
         INTEREST_FIXED_AMOUNT,
         INTEREST_SCHEDULE_ID,
         PENALTY_TYPE        ,
         PENALTY_RATE        ,
         PENALTY_FIXED_AMOUNT,
         PENALTY_SCHEDULE_ID
  )
  VALUES
  (
         X_Customer_Profile_Class_Id,
         X_Created_By,
         X_Creation_Date,
         X_Currency_Code,
         X_Cust_Prof_Class_Amount_Id,
         X_Last_Updated_By,
         X_Last_Update_Date,
         X_Auto_Rec_Min_Receipt_Amount,
         X_Last_Update_Login,
         X_Max_Interest_Charge,
         X_MIN_INTEREST_CHARGE,
         X_Min_Dunning_Amount,
         X_Min_Statement_Amount,
         X_Overall_Credit_Limit,
         X_Trx_Credit_Limit,
         X_Attribute_Category,
         X_Attribute1,
         X_Attribute2,
         X_Attribute3,
         X_Attribute4,
         X_Attribute5,
         X_Attribute6,
         X_Attribute7,
         X_Attribute8,
         X_Attribute9,
         X_Attribute10,
         X_Attribute11,
         X_Attribute12,
         X_Attribute13,
         X_Attribute14,
         X_Attribute15,
         X_Interest_Rate,
         X_Min_Fc_Balance_Amount,
         X_Min_Fc_Invoice_Amount,
         X_Min_Dunning_Invoice_Amount,
         X_Jgzz_attribute_Category,
         X_Jgzz_attribute1,
         X_Jgzz_attribute2,
         X_Jgzz_attribute3,
         X_Jgzz_attribute4,
         X_Jgzz_attribute5,
         X_Jgzz_attribute6,
         X_Jgzz_attribute7,
         X_Jgzz_attribute8,
         X_Jgzz_attribute9,
         X_Jgzz_attribute10,
         X_Jgzz_attribute11,
         X_Jgzz_attribute12,
         X_Jgzz_attribute13,
         X_Jgzz_attribute14,
         X_Jgzz_attribute15,
         --{Late Charges
         X_EXCHANGE_RATE_TYPE,
         X_MIN_FC_INVOICE_OVERDUE_TYPE,
         X_MIN_FC_INVOICE_PERCENT,
         X_MIN_FC_BALANCE_OVERDUE_TYPE,
         X_MIN_FC_BALANCE_PERCENT,
         X_INTEREST_TYPE       ,
         X_INTEREST_FIXED_AMOUNT,
         X_INTEREST_SCHEDULE_ID,
         X_PENALTY_TYPE        ,
         X_PENALTY_RATE        ,
         X_PENALTY_FIXED_AMOUNT,
         X_PENALTY_SCHEDULE_ID
  );

/*
  INSERT INTO hyu_prof_class_amts
  (
         profile_class_id,
         created_by,
         creation_date,
         currency_code,
         profile_class_amount_id,
         last_updated_by,
         last_update_date,
         auto_rec_min_receipt_amount,
         last_update_login,
         max_interest_charge,
         min_dunning_amount,
         min_statement_amount,
         overall_credit_limit,
         trx_credit_limit,
         attribute_category,
         attribute1,
         attribute2,
         attribute3,
         attribute4,
         attribute5,
         attribute6,
         attribute7,
         attribute8,
         attribute9,
         attribute10,
         attribute11,
         attribute12,
         attribute13,
         attribute14,
         attribute15,
         interest_rate,
         min_fc_balance_amount,
         min_fc_invoice_amount,
         min_dunning_invoice_amount,
         Jgzz_attribute_Category,
         Jgzz_attribute1,
         Jgzz_attribute2,
         Jgzz_attribute3,
         Jgzz_attribute4,
         Jgzz_attribute5,
         Jgzz_attribute6,
         Jgzz_attribute7,
         Jgzz_attribute8,
         Jgzz_attribute9,
         Jgzz_attribute10,
         Jgzz_attribute11,
         Jgzz_attribute12,
         Jgzz_attribute13,
         Jgzz_attribute14,
         Jgzz_attribute15,
         --{Late Charges
         EXCHANGE_RATE_TYPE,
         MIN_FC_INVOICE_OVERDUE_TYPE,
         MIN_FC_INVOICE_PERCENT,
         MIN_FC_BALANCE_OVERDUE_TYPE,
         MIN_FC_BALANCE_PERCENT,
         INTEREST_TYPE       ,
         INTEREST_FIXED_AMOUNT,
         INTEREST_SCHEDULE_ID,
         PENALTY_TYPE        ,
         PENALTY_RATE        ,
         PENALTY_FIXED_AMOUNT,
         PENALTY_SCHEDULE_ID
  )
  VALUES
  (
         X_Customer_Profile_Class_Id,
         X_Created_By,
         X_Creation_Date,
         X_Currency_Code,
         X_Cust_Prof_Class_Amount_Id,
         X_Last_Updated_By,
         X_Last_Update_Date,
         X_Auto_Rec_Min_Receipt_Amount,
         X_Last_Update_Login,
         X_Max_Interest_Charge,
         X_Min_Dunning_Amount,
         X_Min_Statement_Amount,
         X_Overall_Credit_Limit,
         X_Trx_Credit_Limit,
         X_Attribute_Category,
         X_Attribute1,
         X_Attribute2,
         X_Attribute3,
         X_Attribute4,
         X_Attribute5,
         X_Attribute6,
         X_Attribute7,
         X_Attribute8,
         X_Attribute9,
         X_Attribute10,
         X_Attribute11,
         X_Attribute12,
         X_Attribute13,
         X_Attribute14,
         X_Attribute15,
         X_Interest_Rate,
         X_Min_Fc_Balance_Amount,
         X_Min_Fc_Invoice_Amount,
         X_Min_Dunning_Invoice_Amount,
         X_Jgzz_attribute_Category,
         X_Jgzz_attribute1,
         X_Jgzz_attribute2,
         X_Jgzz_attribute3,
         X_Jgzz_attribute4,
         X_Jgzz_attribute5,
         X_Jgzz_attribute6,
         X_Jgzz_attribute7,
         X_Jgzz_attribute8,
         X_Jgzz_attribute9,
         X_Jgzz_attribute10,
         X_Jgzz_attribute11,
         X_Jgzz_attribute12,
         X_Jgzz_attribute13,
         X_Jgzz_attribute14,
         X_Jgzz_attribute15,
         --{Late Charges
         X_EXCHANGE_RATE_TYPE,
         X_MIN_FC_INVOICE_OVERDUE_TYPE,
         X_MIN_FC_INVOICE_PERCENT,
         X_MIN_FC_BALANCE_OVERDUE_TYPE,
         X_MIN_FC_BALANCE_PERCENT,
         X_INTEREST_TYPE       ,
         X_INTEREST_FIXED_AMOUNT,
         X_INTEREST_SCHEDULE_ID,
         X_PENALTY_TYPE        ,
         X_PENALTY_RATE        ,
         X_PENALTY_FIXED_AMOUNT,
         X_PENALTY_SCHEDULE_ID
  );
*/
END Insert_Negative_Class_Amt;



PROCEDURE compute_negative_id
(         X_Cust_Prof_Class_Amount_Id NUMBER,
          X_Negative_Id               IN OUT NOCOPY NUMBER,
          X_Notify_Flag               IN OUT NOCOPY VARCHAR2
) IS

  number_in_update number;

BEGIN

--IDENTIFY EXISTING ROW WITH NEGATIVE ID IN HZ_CUST_PROF_CLASS_AMTS
--RETRIEVE THE MIN id WHERE id BETWEEN -100*ID-99 AND -100*ID-2

  SELECT count(*), min(profile_class_amount_id) - 1
  INTO   number_in_update, X_Negative_Id
  FROM   HZ_CUST_PROF_CLASS_AMTS
  WHERE  profile_class_amount_id BETWEEN
         (X_Cust_Prof_Class_Amount_Id) * (-100) - 99 AND
         (X_Cust_Prof_Class_Amount_Id) * (-100) - 2;

 if number_in_update > 0 then
   X_Notify_Flag := 'W';
 end if;

END compute_negative_id;
--
--
PROCEDURE old_amount_insert
(         X_Cust_Prof_Class_Amount_Id      NUMBER,
          X_Negative_Id                    NUMBER,
          X_Customer_Profile_Class_Id      NUMBER
) IS

  CURSOR C is
  select *
  from   hz_cust_prof_class_amts
  where  profile_class_amount_id = X_Cust_Prof_Class_Amount_Id
  FOR UPDATE of profile_class_amount_id NOWAIT;
  Amountinfo C%ROWTYPE;

BEGIN
  OPEN C;
    FETCH C INTO Amountinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    end if;
  CLOSE C;

  Insert_Negative_Class_Amt
  (
         X_Customer_Profile_Class_Id,
         Amountinfo.created_by,
         Amountinfo.creation_date,
         Amountinfo.currency_code,
         X_Negative_Id,
         Amountinfo.last_updated_by,
         Amountinfo.last_update_date,
         Amountinfo.auto_rec_min_receipt_amount,
         Amountinfo.last_update_login,
         Amountinfo.max_interest_charge,
         Amountinfo.min_dunning_amount,
         Amountinfo.min_statement_amount,
         Amountinfo.overall_credit_limit,
         Amountinfo.trx_credit_limit,
         Amountinfo.attribute_category,
         Amountinfo.attribute1,
         Amountinfo.attribute2,
         Amountinfo.attribute3,
         Amountinfo.attribute4,
         Amountinfo.attribute5,
         Amountinfo.attribute6,
         Amountinfo.attribute7,
         Amountinfo.attribute8,
         Amountinfo.attribute9,
         Amountinfo.attribute10,
         Amountinfo.attribute11,
         Amountinfo.attribute12,
         Amountinfo.attribute13,
         Amountinfo.attribute14,
         Amountinfo.attribute15,
         Amountinfo.interest_rate,
         Amountinfo.min_fc_balance_amount,
         Amountinfo.min_fc_invoice_amount,
         Amountinfo.min_dunning_invoice_amount,
         Amountinfo.jgzz_attribute_category,
         Amountinfo.jgzz_attribute1,
         Amountinfo.jgzz_attribute2,
         Amountinfo.jgzz_attribute3,
         Amountinfo.jgzz_attribute4,
         Amountinfo.jgzz_attribute5,
         Amountinfo.jgzz_attribute6,
         Amountinfo.jgzz_attribute7,
         Amountinfo.jgzz_attribute8,
         Amountinfo.jgzz_attribute9,
         Amountinfo.jgzz_attribute10,
         Amountinfo.jgzz_attribute11,
         Amountinfo.jgzz_attribute12,
         Amountinfo.jgzz_attribute13,
         Amountinfo.jgzz_attribute14,
         Amountinfo.jgzz_attribute15,
         --{Late Charges
         Amountinfo.EXCHANGE_RATE_TYPE,
         Amountinfo.MIN_FC_INVOICE_OVERDUE_TYPE,
         Amountinfo.MIN_FC_INVOICE_PERCENT,
         Amountinfo.MIN_FC_BALANCE_OVERDUE_TYPE,
         Amountinfo.MIN_FC_BALANCE_PERCENT,
         Amountinfo.INTEREST_TYPE       ,
         Amountinfo.INTEREST_FIXED_AMOUNT,
         Amountinfo.INTEREST_SCHEDULE_ID,
         Amountinfo.PENALTY_TYPE        ,
         Amountinfo.PENALTY_RATE        ,
         Amountinfo.PENALTY_FIXED_AMOUNT,
         Amountinfo.PENALTY_SCHEDULE_ID,
         Amountinfo.MIN_INTEREST_CHARGE
    );

END old_amount_insert;


END;

/
