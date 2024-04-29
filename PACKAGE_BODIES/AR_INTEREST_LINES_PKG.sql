--------------------------------------------------------
--  DDL for Package Body AR_INTEREST_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_INTEREST_LINES_PKG" AS
/*$Header: ARIILINEB.pls 120.1.12010000.3 2009/04/08 11:02:34 pbapna ship $*/

PROCEDURE Lock_line
(P_INTEREST_LINE_ID        IN  NUMBER,
 P_INTEREST_HEADER_ID      IN  NUMBER,
 P_PAYMENT_SCHEDULE_ID     IN  NUMBER,
 P_TYPE                    IN  VARCHAR2,
 P_ORIGINAL_TRX_CLASS      IN  VARCHAR2,
 P_DAILY_INTEREST_CHARGE   IN  NUMBER,
 P_OUTSTANDING_AMOUNT      IN  NUMBER,
 P_DAYS_OVERDUE_LATE       IN  NUMBER,
 P_DAYS_OF_INTEREST        IN  NUMBER,
 P_INTEREST_CHARGED        IN  NUMBER,
 P_PAYMENT_DATE            IN  DATE,
 P_FINANCE_CHARGE_CHARGED  IN  NUMBER,
 P_AMOUNT_DUE_ORIGINAL     IN  NUMBER,
 P_AMOUNT_DUE_REMAINING    IN  NUMBER,
 P_ORIGINAL_TRX_ID         IN  NUMBER,
 P_RECEIVABLES_TRX_ID      IN  NUMBER,
 P_LAST_CHARGE_DATE        IN  DATE,
 P_DUE_DATE                IN  DATE,
 P_ACTUAL_DATE_CLOSED      IN  DATE,
 P_INTEREST_RATE           IN  NUMBER,
 P_RATE_START_DATE         IN  DATE,
 P_RATE_END_DATE           IN  DATE,
 P_SCHEDULE_DAYS_FROM      IN  NUMBER,
 P_SCHEDULE_DAYS_TO        IN  NUMBER,
 P_LAST_UPDATE_DATE        IN  DATE,
 P_LAST_UPDATED_BY         IN  NUMBER,
 P_LAST_UPDATE_LOGIN       IN  NUMBER,
 P_PROCESS_STATUS          IN  VARCHAR2,
 P_PROCESS_MESSAGE         IN  VARCHAR2,
 P_ORG_ID                  IN  NUMBER,
 P_OBJECT_VERSION_NUMBER   IN  NUMBER,
 x_return_status        OUT NOCOPY  VARCHAR2,
 x_msg_count            OUT NOCOPY  NUMBER,
 x_msg_data             OUT NOCOPY  VARCHAR2)
IS
  CURSOR C IS
  SELECT *
    FROM AR_INTEREST_LINES
   WHERE interest_line_id = p_interest_line_id
     FOR UPDATE of Interest_Line_Id NOWAIT;
  Recinfo C%ROWTYPE;
BEGIN
  arp_util.debug('AR_INTEREST_BATCHES_PKG.Lock_line+');
  x_return_status     := fnd_api.g_ret_sts_success;

  OPEN C;
  FETCH C INTO Recinfo;
  IF (C%NOTFOUND) THEN
    CLOSE C;
    x_return_status := fnd_api.g_ret_sts_error;
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
    fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
  END IF;
  CLOSE C;

  IF       (Recinfo.INTEREST_LINE_ID        = p_interest_line_id)
      AND  (Recinfo.INTEREST_HEADER_ID      = p_interest_header_id)
      AND  (Recinfo.PAYMENT_SCHEDULE_ID     = P_PAYMENT_SCHEDULE_ID)
      AND  (NVL(Recinfo.TYPE,'X')           = NVL(P_TYPE,'X'))
      AND  (NVL(Recinfo.original_trx_class,'X') = NVL(P_ORIGINAL_TRX_CLASS,'X'))
      AND  (NVL(Recinfo.daily_interest_charge,fnd_api.g_miss_num) = NVL(P_DAILY_INTEREST_CHARGE,fnd_api.g_miss_num))
      AND  (NVL(Recinfo.outstanding_amount,fnd_api.g_miss_num) = NVL(P_OUTSTANDING_AMOUNT,fnd_api.g_miss_num))
      AND  (NVL(Recinfo.days_overdue_late,fnd_api.g_miss_num) = NVL(P_DAYS_OVERDUE_LATE,fnd_api.g_miss_num))
      AND  (NVL(Recinfo.days_of_interest,fnd_api.g_miss_num) = NVL(P_DAYS_OF_INTEREST,fnd_api.g_miss_num))
      AND  (NVL(Recinfo.interest_charged,fnd_api.g_miss_num) = NVL(P_INTEREST_CHARGED,fnd_api.g_miss_num))
      AND  (NVL(Recinfo.payment_date,fnd_api.g_miss_date) = NVL(P_PAYMENT_DATE,fnd_api.g_miss_Date))
      AND  (NVL(Recinfo.finance_charge_charged,fnd_api.g_miss_num) = NVL(P_FINANCE_CHARGE_CHARGED,fnd_api.g_miss_num))
      AND  (NVL(Recinfo.amount_due_original,fnd_api.g_miss_num) = NVL(P_AMOUNT_DUE_ORIGINAL,fnd_api.g_miss_num))
      AND  (NVL(Recinfo.amount_due_remaining,fnd_api.g_miss_num) = NVL(P_AMOUNT_DUE_REMAINING,fnd_api.g_miss_num))
      AND  (NVL(Recinfo.original_trx_id,fnd_api.g_miss_num) = NVL(P_ORIGINAL_TRX_ID,fnd_api.g_miss_num))
      AND  (NVL(Recinfo.receivables_trx_id,fnd_api.g_miss_num) = NVL(P_RECEIVABLES_TRX_ID,fnd_api.g_miss_num))
      AND  (NVL(Recinfo.last_charge_date,fnd_api.g_miss_date) = NVL(P_LAST_CHARGE_DATE,fnd_api.g_miss_date))
      AND  (NVL(Recinfo.due_date,fnd_api.g_miss_date) = NVL(P_DUE_DATE,fnd_api.g_miss_date))
      AND  (NVL(Recinfo.actual_date_closed,fnd_api.g_miss_date) = NVL(P_ACTUAL_DATE_CLOSED,fnd_api.g_miss_date))
      AND  (NVL(Recinfo.interest_rate,fnd_api.g_miss_num) = NVL(P_INTEREST_RATE,fnd_api.g_miss_num))
      AND  (NVL(Recinfo.rate_start_date,fnd_api.g_miss_date) = NVL(P_RATE_START_DATE,fnd_api.g_miss_date))
      AND  (NVL(Recinfo.rate_end_date,fnd_api.g_miss_date) = NVL(P_RATE_END_DATE,fnd_api.g_miss_date))
      AND  (NVL(Recinfo.schedule_days_from,fnd_api.g_miss_num) = NVL(P_SCHEDULE_DAYS_FROM,fnd_api.g_miss_num))
      AND  (NVL(Recinfo.schedule_days_to,fnd_api.g_miss_num) = NVL(P_SCHEDULE_DAYS_TO,fnd_api.g_miss_num))
      AND  (NVL(Recinfo.last_update_date,fnd_api.g_miss_date) = NVL(P_LAST_UPDATE_DATE,fnd_api.g_miss_date))
      AND  (NVL(Recinfo.last_updated_by,fnd_api.g_miss_num) = NVL(P_LAST_UPDATED_BY,fnd_api.g_miss_num))
      AND  (NVL(Recinfo.last_update_login,fnd_api.g_miss_num) = NVL(P_LAST_UPDATE_LOGIN,fnd_api.g_miss_num))
      AND  (NVL(Recinfo.process_status,'X') = NVL(P_PROCESS_STATUS,'X'))
      AND  (NVL(Recinfo.process_message,'X') = NVL(P_PROCESS_MESSAGE,'X'))
      AND  (NVL(Recinfo.org_id,fnd_api.g_miss_num) = NVL(P_ORG_ID,fnd_api.g_miss_num))
      AND  (NVL(Recinfo.object_version_number,1) = NVL(P_object_version_number,1))
   THEN
      RETURN;
   ELSE
     arp_util.debug('   Line Record Changed');
      x_return_status := fnd_api.g_ret_sts_error;
      FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
   END IF;
arp_util.debug('AR_INTEREST_BATCHES_PKG.Lock_line-');
END Lock_line;

PROCEDURE validate_line
(p_action                 IN VARCHAR2,
 p_old_rec                IN ar_interest_lines%ROWTYPE,
 p_new_rec                IN ar_interest_lines%ROWTYPE,
 x_return_status      IN OUT NOCOPY VARCHAR2)
IS
  CURSOR c IS
  SELECT process_status
    FROM ar_interest_headers
   WHERE interest_header_id = p_old_rec.interest_header_id;
  l_header_status     VARCHAR2(1);
BEGIN
arp_util.debug('validate_line +');
arp_util.debug('  p_action :'||p_action);
  OPEN c;
  FETCH c INTO l_header_status;
  IF c%NOTFOUND THEN
       FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_INVALID_FK' );
       FND_MESSAGE.SET_TOKEN( 'FK', 'interest_header_id' );
       FND_MESSAGE.SET_TOKEN( 'COLUMN',  p_old_rec.interest_header_id);
       FND_MESSAGE.SET_TOKEN( 'TABLE', 'ar_interest_headers' );
       FND_MSG_PUB.ADD;
       x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;
  CLOSE c;

IF p_action = 'UPDATE' THEN
  IF l_header_status = 'S' THEN
    IF p_old_rec.process_status <> p_new_rec.process_status THEN
      arp_util.debug('Column process_status not updatable');
      FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_NONUPDATEABLE_COLUMN' );
      FND_MESSAGE.SET_TOKEN( 'COLUMN', 'batch_status');
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
  END IF;
END IF;


IF p_action = 'DELETE' THEN
  IF l_header_status = 'S' THEN
    IF p_old_rec.process_status <> p_new_rec.process_status THEN
      arp_util.debug('Column process_status not updatable');
      FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_NONUPDATEABLE_COLUMN' );
      FND_MESSAGE.SET_TOKEN( 'COLUMN', 'batch_status');
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
  END IF;
END IF;
arp_util.debug('validate_line -');
END;


PROCEDURE Update_line
(p_init_msg_list          IN  VARCHAR2 := fnd_api.g_false,
 P_INTEREST_LINE_ID       IN NUMBER,
 P_PROCESS_STATUS         IN VARCHAR2,
 P_PROCESS_MESSAGE        IN VARCHAR2,
 x_object_version_number  IN OUT NOCOPY NUMBER,
 x_return_status          OUT NOCOPY    VARCHAR2,
 x_msg_count              OUT NOCOPY    NUMBER,
 x_msg_data               OUT NOCOPY    VARCHAR2,
 P_DAYS_INTEREST          IN NUMBER DEFAULT NULL,
 P_INTEREST_CHARGED       IN NUMBER DEFAULT NULL )
IS
  CURSOR c IS
  SELECT   *
  FROM ar_interest_lines
  WHERE interest_line_id = P_INTEREST_line_ID
  FOR UPDATE OF INTEREST_line_ID;
  l_rec       ar_interest_lines%ROWTYPE;
  l_new_rec   ar_interest_lines%ROWTYPE;
BEGIN
  arp_util.debug('AR_INTEREST_BATCHES_PKG.update_line +');
  arp_util.debug('  p_interest_line_id :' ||P_INTEREST_LINE_ID);
  SAVEPOINT Update_line;
  x_return_status  := fnd_api.g_ret_sts_success;

  IF fnd_api.to_boolean(p_init_msg_list) THEN
    fnd_msg_pub.initialize;
  END IF;

  x_return_status          := fnd_api.G_RET_STS_SUCCESS;

  OPEN c;
  FETCH c INTO l_rec;
  CLOSE c;

   IF l_rec.INTEREST_line_ID IS NULL THEN
        fnd_message.set_name('AR', 'HZ_API_NO_RECORD');
        fnd_message.set_token('RECORD', 'ar_interest_lines');
        fnd_message.set_token('VALUE',
          NVL(TO_CHAR(P_INTEREST_line_ID), 'null'));
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
      fnd_message.set_token('TABLE', 'ar_interest_lines');
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_error;
   END IF;

   l_new_rec.process_status  := p_process_status;
   l_new_rec.process_message  := p_process_message;

   validate_line
   (p_action    => 'UPDATE',
    p_old_rec   => l_rec,
    p_new_rec   => l_new_rec,
    x_return_status      => x_return_status);

  IF x_return_status <> fnd_api.g_ret_sts_success THEN
    RAISE fnd_api.g_exc_error;
  END IF;

  x_object_version_number := NVL(x_object_version_number,1) + 1;

   arp_util.debug('  updating ar_interest_lines');
   UPDATE AR_INTEREST_LINES
   SET
     LAST_UPDATE_DATE         = SYSDATE,
     LAST_UPDATED_BY          = NVL(arp_global.last_updated_by,-1),
     LAST_UPDATE_LOGIN      = NVL(arp_global.LAST_UPDATE_LOGIN,-1),
     PROCESS_STATUS         = P_PROCESS_STATUS,
     PROCESS_MESSAGE        = P_PROCESS_MESSAGE,
     object_version_number  = x_object_version_number,
     DAYS_OF_INTEREST         = P_DAYS_INTEREST,
     INTEREST_CHARGED         = P_INTEREST_CHARGED
    WHERE interest_line_id   = P_INTEREST_LINE_ID;

arp_util.debug('AR_INTEREST_BATCHES_PKG.update_line -');
EXCEPTION
  WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO SAVEPOINT Update_line;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
      arp_util.debug('EXCEPTION AR_INTEREST_BATCHES_PKG.update_line :'||x_msg_data);
  WHEN OTHERS THEN
      ROLLBACK TO SAVEPOINT Update_line;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
      arp_util.debug('EXCEPTION OTHERS AR_INTEREST_BATCHES_PKG.update_line :'||SQLERRM);
END Update_Line;



PROCEDURE Delete_line
(p_init_msg_list          IN  VARCHAR2 := fnd_api.g_false,
 p_interest_line_id       IN NUMBER,
 x_object_version_number  IN NUMBER,
 x_return_status          OUT NOCOPY    VARCHAR2,
 x_msg_count              OUT NOCOPY    NUMBER,
 x_msg_data               OUT NOCOPY    VARCHAR2)
IS
  CURSOR c IS
  SELECT   *
  FROM ar_interest_lines
  WHERE interest_line_id = P_INTEREST_line_ID
  FOR UPDATE OF INTEREST_line_ID;
  l_rec       ar_interest_lines%ROWTYPE;
  l_new_rec   ar_interest_lines%ROWTYPE;
BEGIN
arp_util.debug('AR_INTEREST_BATCHES_PKG.delete_line +');
  SAVEPOINT Delete_line;
  x_return_status  := fnd_api.g_ret_sts_success;

  IF fnd_api.to_boolean(p_init_msg_list) THEN
    fnd_msg_pub.initialize;
  END IF;

  x_return_status          := fnd_api.G_RET_STS_SUCCESS;

  OPEN c;
  FETCH c INTO l_rec;
  CLOSE c;

   IF l_rec.INTEREST_line_ID IS NULL THEN
        fnd_message.set_name('AR', 'HZ_API_NO_RECORD');
        fnd_message.set_token('RECORD', 'ar_interest_lines');
        fnd_message.set_token('VALUE',
          NVL(TO_CHAR(P_INTEREST_line_ID), 'null'));
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
      fnd_message.set_token('TABLE', 'ar_interest_lines');
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_error;
   END IF;

   validate_line
   (p_action    => 'DELETE',
    p_old_rec   => l_rec,
    p_new_rec   => l_new_rec,
    x_return_status      => x_return_status);

  IF x_return_status <> fnd_api.g_ret_sts_success THEN
    RAISE fnd_api.g_exc_error;
  END IF;

  DELETE FROM AR_INTEREST_LINES
  WHERE interest_line_id = p_interest_line_id;

arp_util.debug('AR_INTEREST_BATCHES_PKG.delete_line -');
EXCEPTION
  WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO SAVEPOINT Delete_line;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
      arp_util.debug('EXCEPTION AR_INTEREST_BATCHES_PKG.delete_line :'||x_msg_data);
  WHEN OTHERS THEN
      ROLLBACK TO SAVEPOINT Delete_line;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
      arp_util.debug('EXCEPTION OTHERS AR_INTEREST_BATCHES_PKG.delete_line :'||SQLERRM);

END Delete_line;


END AR_INTEREST_LINES_PKG;

/
