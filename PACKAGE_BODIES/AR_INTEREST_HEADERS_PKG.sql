--------------------------------------------------------
--  DDL for Package Body AR_INTEREST_HEADERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_INTEREST_HEADERS_PKG" AS
/*$Header: ARIIINVB.pls 120.3 2006/03/28 06:10:23 hyu noship $*/

g_current_version   NUMBER;
g_not     VARCHAR2(30):=  ARPT_SQL_FUNC_UTIL.get_lookup_meaning ('AR_PROCESS_STATUS','N');
g_error   VARCHAR2(30):=  ARPT_SQL_FUNC_UTIL.get_lookup_meaning ('AR_PROCESS_STATUS','E');
g_success VARCHAR2(30):=  ARPT_SQL_FUNC_UTIL.get_lookup_meaning ('AR_PROCESS_STATUS','S');
g_draft   VARCHAR2(30):=  ARPT_SQL_FUNC_UTIL.get_lookup_meaning ('AR_RUN_TYPE','D');
g_final   VARCHAR2(30):=  ARPT_SQL_FUNC_UTIL.get_lookup_meaning ('AR_RUN_TYPE','F');

FUNCTION get_header_amount
(p_interest_header_id IN NUMBER)
RETURN NUMBER
IS
 CURSOR c IS
 SELECT SUM(NVL(iil.INTEREST_CHARGED,0))
   FROM ar_interest_lines   iil,
        ar_interest_headers ii
  WHERE ii.interest_header_id = iil.interest_header_id
    AND ii.interest_header_id = p_interest_header_id;
 l_header_amount number;
BEGIN
 arp_util.debug('get_header_amount +');
 arp_util.debug('   p_interest_header_id :'||p_interest_header_id);
 OPEN c;
  FETCH c INTO l_header_amount;
 CLOSE c;
 arp_util.debug('   result :'||l_header_amount);
 arp_util.debug('get_header_amount -');
 RETURN l_header_amount;
END;

PROCEDURE Lock_header
(P_INTEREST_HEADER_ID               IN  NUMBER,
 P_INTEREST_BATCH_ID                IN  NUMBER,
 P_CUSTOMER_ID                      IN  NUMBER,
 P_CUSTOMER_SITE_USE_ID             IN  NUMBER,
 P_HEADER_TYPE                      IN  VARCHAR2,
 P_CURRENCY_CODE                    IN  VARCHAR2,
 P_LATE_CHARGE_CALCULATION_TRX      IN  VARCHAR2,
 P_CREDIT_ITEMS_FLAG                IN  VARCHAR2,
 P_DISPUTED_TRANSACTIONS_FLAG       IN  VARCHAR2,
 P_PAYMENT_GRACE_DAYS               IN  NUMBER,
 P_LATE_CHARGE_TERM_ID              IN  NUMBER,
 P_INTEREST_PERIOD_DAYS             IN  NUMBER,
 P_INTEREST_CALCULATION_PERIOD      IN  VARCHAR2,
 P_CHARGE_ON_FINANCE_CHARGE_FLG     IN  VARCHAR2,
 P_HOLD_CHARGED_INVOICES_FLAG       IN  VARCHAR2,
 P_MESSAGE_TEXT_ID                  IN  NUMBER,
 P_MULTIPLE_INTEREST_RATES_FLAG     IN  VARCHAR2,
 P_CHARGE_BEGIN_DATE                IN  DATE,
 P_CUST_ACCT_PROFILE_AMT_ID         IN  NUMBER,
 P_EXCHANGE_RATE                    IN  NUMBER,
 P_EXCHANGE_RATE_TYPE               IN  VARCHAR2,
 P_MIN_FC_INVOICE_OVERDUE_TYPE      IN  VARCHAR2,
 P_MIN_FC_INVOICE_AMOUNT            IN  NUMBER,
 P_MIN_FC_INVOICE_PERCENT           IN  NUMBER,
 P_MIN_FC_BALANCE_OVERDUE_TYPE     IN  VARCHAR2,
 P_MIN_FC_BALANCE_AMOUNT            IN  NUMBER,
 P_MIN_FC_BALANCE_PERCENT           IN  NUMBER,
 P_MIN_INTEREST_CHARGE              IN  NUMBER,
 P_MAX_INTEREST_CHARGE              IN  NUMBER,
 P_INTEREST_TYPE                    IN  VARCHAR2,
 P_INTEREST_RATE                    IN  NUMBER,
 P_INTEREST_FIXED_AMOUNT            IN  NUMBER,
 P_INTEREST_SCHEDULE_ID             IN  NUMBER,
 P_PENALTY_TYPE                     IN  VARCHAR2,
 P_PENALTY_RATE                     IN  NUMBER,
 P_PENALTY_FIXED_AMOUNT             IN  NUMBER,
 P_PENALTY_SCHEDULE_ID              IN  NUMBER,
 P_LAST_ACCRUE_CHARGE_DATE          IN  DATE,
 P_CUSTOMER_PROFILE_ID              IN  NUMBER,
 P_COLLECTOR_ID                     IN  NUMBER,
 P_LEGAL_ENTITY_ID                  IN  NUMBER,
 P_LAST_UPDATE_DATE                 IN  DATE,
 P_LAST_UPDATED_BY                  IN  NUMBER,
 P_LAST_UPDATE_LOGIN                IN  NUMBER,
 P_CREATED_BY                       IN  NUMBER,
 P_CREATION_DATE                    IN  DATE,
 P_ORG_ID                           IN  NUMBER,
 P_PROCESS_MESSAGE                  IN  VARCHAR2,
 P_PROCESS_STATUS                   IN  VARCHAR2,
 P_CUST_TRX_TYPE_ID                 IN  NUMBER,
 P_OBJECT_VERSION_NUMBER            IN  NUMBER,
 x_return_status        OUT NOCOPY  VARCHAR2,
 x_msg_count            OUT NOCOPY  NUMBER,
 x_msg_data             OUT NOCOPY  VARCHAR2)
IS
  CURSOR C IS
  SELECT *
    FROM AR_INTEREST_HEADERS
   WHERE interest_header_id = p_interest_header_id
     FOR UPDATE OF interest_header_Id NOWAIT;
  Recinfo C%ROWTYPE;
  l_continue     VARCHAR2(1) := 'Y';
BEGIN
arp_util.debug('lock_header +');

OPEN C;
FETCH C INTO Recinfo;
IF (C%NOTFOUND) THEN
   x_return_status := fnd_api.g_ret_sts_error;
   FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
   fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
   l_continue  := 'N';
END IF;
CLOSE C;

IF l_continue = 'Y' THEN
 IF  (P_INTEREST_HEADER_ID        = Recinfo.INTEREST_HEADER_ID)
 AND (P_INTEREST_BATCH_ID         = Recinfo.INTEREST_BATCH_ID)
 AND (NVL(P_CUSTOMER_ID,fnd_api.g_miss_num)                = NVL(Recinfo.CUSTOMER_ID,fnd_api.g_miss_num))
 AND (NVL(P_CUSTOMER_SITE_USE_ID,fnd_api.g_miss_num)       = NVL(Recinfo.CUSTOMER_SITE_USE_ID,fnd_api.g_miss_num))
 AND (NVL(P_HEADER_TYPE,fnd_api.g_miss_char)               = NVL(Recinfo.HEADER_TYPE,fnd_api.g_miss_char))
 AND (NVL(P_CURRENCY_CODE,fnd_api.g_miss_char)             = NVL(Recinfo.CURRENCY_CODE,fnd_api.g_miss_char))
 AND (NVL(P_LATE_CHARGE_CALCULATION_TRX,fnd_api.g_miss_char) = NVL(Recinfo.LATE_CHARGE_CALCULATION_TRX,fnd_api.g_miss_char))
 AND (NVL(P_CREDIT_ITEMS_FLAG,fnd_api.g_miss_char)         = NVL(Recinfo.CREDIT_ITEMS_FLAG,fnd_api.g_miss_char))
 AND (NVL(P_DISPUTED_TRANSACTIONS_FLAG,fnd_api.g_miss_char)= NVL(Recinfo.DISPUTED_TRANSACTIONS_FLAG,fnd_api.g_miss_char))
 AND (NVL(P_PAYMENT_GRACE_DAYS,fnd_api.g_miss_num)         = NVL(Recinfo.PAYMENT_GRACE_DAYS,fnd_api.g_miss_num))
 AND (NVL(P_LATE_CHARGE_TERM_ID,fnd_api.g_miss_num)        = NVL(Recinfo.LATE_CHARGE_TERM_ID,fnd_api.g_miss_num))
 AND (NVL(P_INTEREST_PERIOD_DAYS,fnd_api.g_miss_num)       = NVL(Recinfo.INTEREST_PERIOD_DAYS,fnd_api.g_miss_num))
 AND (NVL(P_INTEREST_CALCULATION_PERIOD,fnd_api.g_miss_char)=
                 NVL(Recinfo.INTEREST_CALCULATION_PERIOD,fnd_api.g_miss_char))
 AND (NVL(P_CHARGE_ON_FINANCE_CHARGE_FLG,fnd_api.g_miss_char)=
                 NVL(Recinfo.CHARGE_ON_FINANCE_CHARGE_FLAG,fnd_api.g_miss_char))
 AND (NVL(P_HOLD_CHARGED_INVOICES_FLAG,fnd_api.g_miss_char)= NVL(Recinfo.HOLD_CHARGED_INVOICES_FLAG,fnd_api.g_miss_char))
 AND (NVL(P_MESSAGE_TEXT_ID,fnd_api.g_miss_num)          = NVL(Recinfo.MESSAGE_TEXT_ID,fnd_api.g_miss_num))
 AND (NVL(P_MULTIPLE_INTEREST_RATES_FLAG,fnd_api.g_miss_char)= NVL(Recinfo.MULTIPLE_INTEREST_RATES_FLAG,fnd_api.g_miss_char))
 AND (NVL(P_CHARGE_BEGIN_DATE,fnd_api.g_miss_date)       = NVL(Recinfo.CHARGE_BEGIN_DATE,fnd_api.g_miss_date))
 AND (NVL(P_CUST_ACCT_PROFILE_AMT_ID,fnd_api.g_miss_num) = NVL(Recinfo.CUST_ACCT_PROFILE_AMT_ID,fnd_api.g_miss_num))
 AND (NVL(P_EXCHANGE_RATE,fnd_api.g_miss_num)            = NVL(Recinfo.EXCHANGE_RATE,fnd_api.g_miss_num))
 AND (NVL(P_EXCHANGE_RATE_TYPE,fnd_api.g_miss_char)      = NVL(Recinfo.EXCHANGE_RATE_TYPE,fnd_api.g_miss_char))
 AND (NVL(P_MIN_FC_INVOICE_OVERDUE_TYPE,fnd_api.g_miss_char)= NVL(Recinfo.MIN_FC_INVOICE_OVERDUE_TYPE,fnd_api.g_miss_char))
 AND (NVL(P_MIN_FC_INVOICE_AMOUNT,fnd_api.g_miss_num)    = NVL(Recinfo.MIN_FC_INVOICE_AMOUNT,fnd_api.g_miss_num))
 AND (NVL(P_MIN_FC_INVOICE_PERCENT,fnd_api.g_miss_num)   = NVL(Recinfo.MIN_FC_INVOICE_PERCENT,fnd_api.g_miss_num))
 AND (NVL(P_MIN_FC_BALANCE_OVERDUE_TYPE,fnd_api.g_miss_char)= NVL(Recinfo.MIN_FC_BALANCE_OVERDUE_TYPE,fnd_api.g_miss_char))
 AND (NVL(P_MIN_FC_BALANCE_AMOUNT,fnd_api.g_miss_num)   = NVL(Recinfo.MIN_FC_BALANCE_AMOUNT,fnd_api.g_miss_num))
 AND (NVL(P_MIN_FC_BALANCE_PERCENT,fnd_api.g_miss_num)  = NVL(Recinfo.MIN_FC_BALANCE_PERCENT,fnd_api.g_miss_num))
 AND (NVL(P_MIN_INTEREST_CHARGE,fnd_api.g_miss_num)     = NVL(Recinfo.MIN_INTEREST_CHARGE,fnd_api.g_miss_num))
 AND (NVL(P_MAX_INTEREST_CHARGE,fnd_api.g_miss_num)     = NVL(Recinfo.MAX_INTEREST_CHARGE,fnd_api.g_miss_num))
 AND (NVL(P_INTEREST_TYPE,fnd_api.g_miss_char)          = NVL(Recinfo.interest_type,fnd_api.g_miss_char))
 AND (NVL(P_INTEREST_RATE,fnd_api.g_miss_num)           = NVL(Recinfo.interest_rate,fnd_api.g_miss_num))
 AND (NVL(P_INTEREST_FIXED_AMOUNT,fnd_api.g_miss_num)   = NVL(Recinfo.INTEREST_FIXED_AMOUNT,fnd_api.g_miss_num))
 AND (NVL(P_INTEREST_SCHEDULE_ID,fnd_api.g_miss_num)    = NVL(Recinfo.INTEREST_SCHEDULE_ID,fnd_api.g_miss_num))
 AND (NVL(P_PENALTY_TYPE,fnd_api.g_miss_char)           = NVL(Recinfo.PENALTY_TYPE,fnd_api.g_miss_char))
 AND (NVL(P_PENALTY_RATE,fnd_api.g_miss_num)            = NVL(Recinfo.PENALTY_RATE,fnd_api.g_miss_num))
 AND (NVL(P_PENALTY_FIXED_AMOUNT,fnd_api.g_miss_num)    = NVL(Recinfo.PENALTY_FIXED_AMOUNT,fnd_api.g_miss_num))
 AND (NVL(P_PENALTY_SCHEDULE_ID,fnd_api.g_miss_num)     = NVL(Recinfo.PENALTY_SCHEDULE_ID,fnd_api.g_miss_num))
 AND (NVL(P_LAST_ACCRUE_CHARGE_DATE,fnd_api.g_miss_date)= NVL(Recinfo.LAST_ACCRUE_CHARGE_DATE,fnd_api.g_miss_date))
 AND (NVL(P_CUSTOMER_PROFILE_ID,fnd_api.g_miss_num)     = NVL(Recinfo.CUSTOMER_PROFILE_ID,fnd_api.g_miss_num))
 AND (NVL(P_COLLECTOR_ID,fnd_api.g_miss_num)            = NVL(Recinfo.COLLECTOR_ID,fnd_api.g_miss_num))
 AND (NVL(P_LEGAL_ENTITY_ID,fnd_api.g_miss_num)         = NVL(Recinfo.LEGAL_ENTITY_ID,fnd_api.g_miss_num))
 AND (NVL(P_LAST_UPDATE_DATE,fnd_api.g_miss_date)       = NVL(Recinfo.LAST_UPDATE_DATE,fnd_api.g_miss_date))
 AND (NVL(P_LAST_UPDATED_BY,fnd_api.g_miss_num)         = NVL(Recinfo.LAST_UPDATED_BY,fnd_api.g_miss_num))
 AND (NVL(P_LAST_UPDATE_LOGIN,fnd_api.g_miss_num)       = NVL(Recinfo.LAST_UPDATE_LOGIN,fnd_api.g_miss_num))
 AND (NVL(P_CREATED_BY,fnd_api.g_miss_num)              = NVL(Recinfo.CREATED_BY,fnd_api.g_miss_num))
 AND (NVL(P_CREATION_DATE,fnd_api.g_miss_date)          = NVL(Recinfo.CREATION_DATE,fnd_api.g_miss_date))
 AND (NVL(P_ORG_ID,fnd_api.g_miss_num)                  = NVL(Recinfo.ORG_ID,fnd_api.g_miss_num))
 AND (NVL(P_PROCESS_MESSAGE,fnd_api.g_miss_char)        = NVL(Recinfo.PROCESS_MESSAGE,fnd_api.g_miss_char))
 AND (NVL(P_PROCESS_STATUS,fnd_api.g_miss_char)         = NVL(Recinfo.PROCESS_STATUS,fnd_api.g_miss_char))
 AND (NVL(P_CUST_TRX_TYPE_ID,fnd_api.g_miss_num)        = NVL(Recinfo.CUST_TRX_TYPE_ID,fnd_api.g_miss_num))
 AND (NVL(P_OBJECT_VERSION_NUMBER,1)        = NVL(Recinfo.OBJECT_VERSION_NUMBER,1))
 THEN
   RETURN;
 ELSE
   arp_util.debug('   Header Record Changed');
   x_return_status := fnd_api.g_ret_sts_error;
   FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
   fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
 END IF;
END IF;
arp_util.debug('lock_header -');
END Lock_Header;


PROCEDURE validate_header
  (p_action              IN VARCHAR2,
   p_old_rec             IN ar_interest_headers%ROWTYPE,
   p_new_rec             IN ar_interest_headers%ROWTYPE,
   p_updated_by_program  IN VARCHAR2 DEFAULT 'ARIINR',
   x_return_status   IN OUT NOCOPY VARCHAR2)
IS
  CURSOR c IS
  SELECT transferred_status
    FROM ar_interest_batches
   WHERE interest_batch_id = p_old_rec.interest_batch_id;
  l_flag    VARCHAR2(1);
BEGIN
arp_util.debug('validate_header +');
arp_util.debug('  p_action :'||p_action);
IF p_action = 'UPDATE' THEN

  IF p_new_rec.process_status NOT IN ('E','S','N') THEN
     arp_util.debug('Column process_status can take values from E S or N only');
     FND_MESSAGE.SET_NAME( 'AR', 'AR_ONLY_VALUE_ALLOWED' );
     FND_MESSAGE.SET_NAME( 'COLUMN', 'PROCESS_STATUS' );
     FND_MESSAGE.SET_TOKEN( 'VALUES', g_error||','||g_success||','||g_not);
     FND_MSG_PUB.ADD;
     x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  IF p_old_rec.process_status = 'S' AND p_new_rec.process_status = 'S' THEN
     arp_util.debug('Column process_status not updatable');
     FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_NONUPDATEABLE_COLUMN' );
     FND_MESSAGE.SET_TOKEN( 'COLUMN', 'batch_status');
     FND_MSG_PUB.ADD;
     x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  IF      (p_old_rec.process_status <> 'S')
      AND (p_new_rec.process_status = 'S' OR p_new_rec.process_status = 'E')
  THEN
     IF p_updated_by_program  = 'ARIINR' THEN
       arp_util.debug('Only creation of late charge document set the status to S');
       fnd_message.set_name('AR', 'AR_STATUS_RESERVE_FOR_SRS');
       fnd_msg_pub.add;
       x_return_status := FND_API.G_RET_STS_ERROR;
     END IF;
  END IF;
END IF;

IF p_action = 'DELETE' THEN
  IF p_old_rec.process_status = 'S' THEN
     arp_util.debug('Column process_status not updatable');
     FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_NONUPDATEABLE_COLUMN' );
     FND_MESSAGE.SET_TOKEN( 'COLUMN', 'batch_status');
     FND_MSG_PUB.ADD;
     x_return_status := FND_API.G_RET_STS_ERROR;
  ELSE
    OPEN c;
    FETCH c INTO l_flag;
    IF c%FOUND THEN
      IF l_flag = 'S' THEN
        arp_util.debug('Column process_status not updatable');
        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_NONUPDATEABLE_COLUMN' );
        FND_MESSAGE.SET_TOKEN( 'COLUMN', 'batch_status');
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
    END IF;
    CLOSE c;
  END IF;
END IF;
arp_util.debug('validate_header -');
END;




PROCEDURE update_header
(p_init_msg_list              IN  VARCHAR2 := fnd_api.g_false,
 P_INTEREST_HEADER_ID         IN  NUMBER,
 P_PROCESS_MESSAGE            IN  VARCHAR2,
 P_PROCESS_STATUS             IN  VARCHAR2,
 p_updated_by_program         IN  VARCHAR2 DEFAULT 'ARIINR',
 x_object_version_number  IN OUT NOCOPY NUMBER,
 x_return_status         OUT NOCOPY  VARCHAR2,
 x_msg_count             OUT NOCOPY  NUMBER,
 x_msg_data              OUT NOCOPY  VARCHAR2)
IS
  CURSOR c IS
  SELECT   *
  FROM ar_interest_headers
  WHERE interest_header_id = P_INTEREST_header_ID
  FOR UPDATE OF INTEREST_header_ID;
  l_rec       ar_interest_headers%ROWTYPE;
  l_new_rec   ar_interest_headers%ROWTYPE;
BEGIN
arp_util.debug('update_header +');
  SAVEPOINT  update_header;

  IF fnd_api.to_boolean(p_init_msg_list) THEN
    fnd_msg_pub.initialize;
  END IF;

  x_return_status          := fnd_api.G_RET_STS_SUCCESS;

  OPEN c;
  FETCH c INTO l_rec;
  CLOSE c;

   IF l_rec.INTEREST_header_ID IS NULL THEN
        fnd_message.set_name('AR', 'HZ_API_NO_RECORD');
        fnd_message.set_token('RECORD', 'ar_interest_headers');
        fnd_message.set_token('VALUE',
          NVL(TO_CHAR(P_INTEREST_header_ID), 'null'));
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
   END IF;

   IF NOT ((x_object_version_number IS NULL AND
                l_rec.OBJECT_VERSION_NUMBER IS NULL) OR
              (x_object_version_number IS NOT NULL      AND
                l_rec.OBJECT_VERSION_NUMBER IS NOT NULL AND
                x_object_version_number = l_rec.OBJECT_VERSION_NUMBER))
   THEN
      fnd_message.set_name('AR', 'HZ_API_RECORD_CHANGED');
      fnd_message.set_token('TABLE', 'ar_interest_batches');
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_error;
   END IF;

  l_new_rec.process_status    := P_PROCESS_STATUS;
  l_new_rec.process_message   := P_PROCESS_MESSAGE;

  validate_header
  (p_action              => 'UPDATE',
   p_old_rec             => l_rec,
   p_new_rec             => l_new_rec,
   p_updated_by_program  => p_updated_by_program,
   x_return_status       => x_return_status);

  IF x_return_status <> fnd_api.g_ret_sts_success THEN
    RAISE fnd_api.g_exc_error;
  END IF;

  x_object_version_number  := NVL(x_object_version_number,1) + 1;

  UPDATE AR_INTEREST_HEADERS
  SET
     PROCESS_MESSAGE         = P_PROCESS_MESSAGE          ,
     PROCESS_STATUS          = P_PROCESS_STATUS            ,
     LAST_UPDATE_DATE        = SYSDATE,
     LAST_UPDATED_BY         = NVL(arp_global.last_updated_by,-1),
     LAST_UPDATE_LOGIN       = NVL(arp_global.LAST_UPDATE_LOGIN,-1),
     object_version_number   = x_object_version_number
  WHERE  INTEREST_HEADER_ID  = p_INTEREST_HEADER_ID;
arp_util.debug('lock_header -');
EXCEPTION
  WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO SAVEPOINT Update_header;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
     IF x_msg_count > 1 THEN
      x_msg_data := FND_MSG_PUB.Get(FND_MSG_PUB.G_LAST,FND_API.G_FALSE );
     END IF;
      arp_util.debug('EXCEPTION AR_INTEREST_HEADERS_PKG.update_header :'||x_msg_data);
  WHEN OTHERS THEN
      ROLLBACK TO SAVEPOINT Update_header;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
      arp_util.debug('EXCEPTION OTHERS AR_INTEREST_HEADERS_PKG.update_header :'||SQLERRM);
END Update_header;

PROCEDURE Delete_header
(p_init_msg_list         IN VARCHAR2 := fnd_api.g_false,
 p_interest_header_id    IN NUMBER,
 x_object_version_number IN NUMBER,
 x_return_status         OUT NOCOPY  VARCHAR2,
 x_msg_count             OUT NOCOPY  NUMBER,
 x_msg_data              OUT NOCOPY  VARCHAR2)
IS
  CURSOR c IS
  SELECT   *
  FROM ar_interest_headers
  WHERE interest_header_id = P_INTEREST_header_ID
  FOR UPDATE OF INTEREST_header_ID;
  l_rec       ar_interest_headers%ROWTYPE;
  l_new_rec   ar_interest_headers%ROWTYPE;
BEGIN
  SAVEPOINT  delete_header;

  IF fnd_api.to_boolean(p_init_msg_list) THEN
    fnd_msg_pub.initialize;
  END IF;

  x_return_status          := fnd_api.G_RET_STS_SUCCESS;

  OPEN c;
  FETCH c INTO l_rec;
  CLOSE c;

   IF l_rec.INTEREST_header_ID IS NULL THEN
        fnd_message.set_name('AR', 'HZ_API_NO_RECORD');
        fnd_message.set_token('RECORD', 'ar_interest_headers');
        fnd_message.set_token('VALUE',
          NVL(TO_CHAR(P_INTEREST_header_ID), 'null'));
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
   END IF;

  validate_header
  (p_action              => 'DELETE',
   p_old_rec             => l_rec,
   p_new_rec             => l_new_rec,
   x_return_status       => x_return_status);

  IF x_return_status <> fnd_api.g_ret_sts_success THEN
    RAISE fnd_api.g_exc_error;
  END IF;

  DELETE FROM ar_interest_lines
  WHERE interest_header_id = p_interest_header_id;

  DELETE FROM AR_INTEREST_HEADERS
  WHERE interest_header_id = p_interest_header_id;

EXCEPTION
  WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO SAVEPOINT delete_header;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
     IF x_msg_count > 1 THEN
      x_msg_data := FND_MSG_PUB.Get(FND_MSG_PUB.G_LAST,FND_API.G_FALSE );
     END IF;
      arp_util.debug('EXCEPTION AR_INTEREST_HEADERS_PKG.delete_header :'||x_msg_data);
  WHEN OTHERS THEN
      ROLLBACK TO SAVEPOINT Update_header;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
      arp_util.debug('EXCEPTION OTHERS AR_INTEREST_HEADERS_PKG.delete_header :'||SQLERRM);
END Delete_header;


END AR_INTEREST_HEADERS_PKG;

/
