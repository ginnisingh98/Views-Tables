--------------------------------------------------------
--  DDL for Package Body HZ_PAYMENT_METHOD_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_PAYMENT_METHOD_PUB" AS
/*$Header: ARHPYMPB.pls 120.5 2005/12/07 19:33:12 acng noship $*/

PROCEDURE log(
   message      IN      VARCHAR2,
   newline      IN      BOOLEAN DEFAULT TRUE);

FUNCTION logerror(SQLERRM VARCHAR2 DEFAULT NULL)
         RETURN VARCHAR2;

  -- PROCEDURE create_payment_method
  --
  -- DESCRIPTION
  --     Create payment method.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_payment_method_rec Payment method record.
  --   OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --     x_cust_receipt_method_id      Payment method Id.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.
  --

PROCEDURE create_payment_method (
  p_init_msg_list             IN            VARCHAR2 := FND_API.G_FALSE,
  p_payment_method_rec        IN payment_method_rec_type,
  x_cust_receipt_method_id    OUT NOCOPY    NUMBER,
  x_return_status             OUT NOCOPY    VARCHAR2,
  x_msg_count                 OUT NOCOPY    NUMBER,
  x_msg_data                  OUT NOCOPY    VARCHAR2
) IS
  l_rowid                      VARCHAR2(64);
  l_pm_rec                     payment_method_rec_type;
  l_debug_prefix               VARCHAR2(30);
BEGIN
  SAVEPOINT create_pm_pub;

  -- Debug info.
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
    hz_utility_v2pub.debug(p_message=>'create_payment_method(+)',
                           p_prefix=>l_debug_prefix,
                           p_msg_level=>fnd_log.level_procedure);
  END IF;

  -- initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
  END IF;

  l_pm_rec := p_payment_method_rec;

  --Initialize API return status to success.
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  validate_payment_method(
     p_create_update_flag        => 'C'
    ,p_payment_method_rec        => l_pm_rec
    ,x_return_status             => x_return_status );

  IF(x_return_status = FND_API.G_RET_STS_ERROR) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF(x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  HZ_PAYMENT_METHOD_PKG.Insert_Row (
     x_cust_receipt_method_id    => l_pm_rec.cust_receipt_method_id,
     x_customer_id               => l_pm_rec.cust_account_id,
     x_receipt_method_id         => l_pm_rec.receipt_method_id,
     x_primary_flag              => l_pm_rec.primary_flag,
     x_site_use_id               => l_pm_rec.site_use_id,
     x_start_date                => l_pm_rec.start_date,
     x_end_date                  => l_pm_rec.end_date,
     x_attribute_category        => l_pm_rec.attribute_category,
     x_attribute1                => l_pm_rec.attribute1,
     x_attribute2                => l_pm_rec.attribute2,
     x_attribute3                => l_pm_rec.attribute3,
     x_attribute4                => l_pm_rec.attribute4,
     x_attribute5                => l_pm_rec.attribute5,
     x_attribute6                => l_pm_rec.attribute6,
     x_attribute7                => l_pm_rec.attribute7,
     x_attribute8                => l_pm_rec.attribute8,
     x_attribute9                => l_pm_rec.attribute9,
     x_attribute10               => l_pm_rec.attribute10,
     x_attribute11               => l_pm_rec.attribute11,
     x_attribute12               => l_pm_rec.attribute12,
     x_attribute13               => l_pm_rec.attribute13,
     x_attribute14               => l_pm_rec.attribute14,
     x_attribute15               => l_pm_rec.attribute15
  );

  x_cust_receipt_method_id := l_pm_rec.cust_receipt_method_id;

  IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('EVENTS_ENABLED', 'BO_EVENTS_ENABLED')) THEN
    -- populate function for integration service
    HZ_POPULATE_BOT_PKG.pop_ra_cust_receipt_methods(
      p_operation => 'I',
      p_cust_receipt_method_id => x_cust_receipt_method_id);
  END IF;

  -- standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                            p_count => x_msg_count,
                            p_data  => x_msg_data);

  -- Debug info.
  IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
    hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                                           p_msg_data=>x_msg_data,
                                           p_msg_type=>'WARNING',
                                           p_msg_level=>fnd_log.level_exception);
  END IF;

  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
    hz_utility_v2pub.debug(p_message=>'create_payment_method(-)',
                           p_prefix=>l_debug_prefix,
                           p_msg_level=>fnd_log.level_procedure);
  END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO create_pm_pub;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO create_pm_pub;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

   WHEN OTHERS THEN
     ROLLBACK TO create_pm_pub;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);
END create_payment_method;

  -- PROCEDURE update_payment_method
  --
  -- DESCRIPTION
  --     Update payment method.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_payment_method_rec Payment method record.
  --   IN/OUT:
  --     px_last_update_date  Last update date of payment method record.
  --   OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.

PROCEDURE update_payment_method (
  p_init_msg_list             IN            VARCHAR2 :=  FND_API.G_FALSE,
  p_payment_method_rec        IN payment_method_rec_type,
  px_last_update_date         IN OUT NOCOPY DATE,
  x_return_status             OUT NOCOPY    VARCHAR2,
  x_msg_count                 OUT NOCOPY    NUMBER,
  x_msg_data                  OUT NOCOPY    VARCHAR2
) IS
  l_last_update_date          DATE;
  l_rowid                     ROWID := NULL;
  l_pm_id                     NUMBER;
  l_debug_prefix              VARCHAR2(30);
BEGIN
  SAVEPOINT update_pm_pub;

  -- Debug info.
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
    hz_utility_v2pub.debug(p_message=>'update_payment_method(+)',
                           p_prefix=>l_debug_prefix,
                           p_msg_level=>fnd_log.level_procedure);
  END IF;

  -- initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  --Initialize API return status to success.
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Lock record.
  BEGIN
    l_pm_id := p_payment_method_rec.cust_receipt_method_id;

    SELECT ROWID, LAST_UPDATE_DATE
    INTO l_rowid, l_last_update_date
    FROM RA_CUST_RECEIPT_METHODS
    WHERE cust_receipt_method_id = l_pm_id
    FOR UPDATE NOWAIT;

    IF NOT (
      ( px_last_update_date IS NULL AND l_last_update_date IS NULL ) OR
      ( px_last_update_date IS NOT NULL AND
        l_last_update_date IS NOT NULL AND
        px_last_update_date = l_last_update_date ) )
    THEN
      FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_RECORD_CHANGED' );
      FND_MESSAGE.SET_TOKEN( 'TABLE', 'RA_CUST_RECEIPT_METHODS' );
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_NO_RECORD' );
      FND_MESSAGE.SET_TOKEN( 'RECORD', 'RA_CUST_RECEIPT_METHODS' );
      FND_MESSAGE.SET_TOKEN( 'VALUE', l_pm_id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
  END;

  validate_payment_method(
     p_create_update_flag        => 'U'
    ,p_payment_method_rec        => p_payment_method_rec
    ,x_return_status             => x_return_status );

  IF(x_return_status = FND_API.G_RET_STS_ERROR) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF(x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  HZ_PAYMENT_METHOD_PKG.Update_Row(
    x_rowid                  => l_rowid,
    x_cust_receipt_method_id => p_payment_method_rec.cust_receipt_method_id,
    x_customer_id            => p_payment_method_rec.cust_account_id,
    x_receipt_method_id      => p_payment_method_rec.receipt_method_id,
    x_primary_flag           => p_payment_method_rec.primary_flag,
    x_site_use_id            => p_payment_method_rec.site_use_id,
    x_start_date             => p_payment_method_rec.start_date,
    x_end_date               => p_payment_method_rec.end_date,
    x_attribute_category     => p_payment_method_rec.attribute_category,
    x_attribute1             => p_payment_method_rec.attribute1,
    x_attribute2             => p_payment_method_rec.attribute2,
    x_attribute3             => p_payment_method_rec.attribute3,
    x_attribute4             => p_payment_method_rec.attribute4,
    x_attribute5             => p_payment_method_rec.attribute5,
    x_attribute6             => p_payment_method_rec.attribute6,
    x_attribute7             => p_payment_method_rec.attribute7,
    x_attribute8             => p_payment_method_rec.attribute8,
    x_attribute9             => p_payment_method_rec.attribute9,
    x_attribute10            => p_payment_method_rec.attribute10,
    x_attribute11            => p_payment_method_rec.attribute11,
    x_attribute12            => p_payment_method_rec.attribute12,
    x_attribute13            => p_payment_method_rec.attribute13,
    x_attribute14            => p_payment_method_rec.attribute14,
    x_attribute15            => p_payment_method_rec.attribute15
  );

  px_last_update_date := l_last_update_date;

  IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('EVENTS_ENABLED', 'BO_EVENTS_ENABLED')) THEN
    -- populate function for integration service
    HZ_POPULATE_BOT_PKG.pop_ra_cust_receipt_methods(
      p_operation => 'U',
      p_cust_receipt_method_id => p_payment_method_rec.cust_receipt_method_id);
  END IF;

  -- standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                            p_count => x_msg_count,
                            p_data  => x_msg_data);

  -- Debug info.
  IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
    hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                                           p_msg_data=>x_msg_data,
                                           p_msg_type=>'WARNING',
                                           p_msg_level=>fnd_log.level_exception);
  END IF;

  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
    hz_utility_v2pub.debug(p_message=>'update_payment_method(-)',
                           p_prefix=>l_debug_prefix,
                           p_msg_level=>fnd_log.level_procedure);
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO update_pm_pub;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO update_pm_pub;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data);

  WHEN OTHERS THEN
    ROLLBACK TO update_pm_pub;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    FND_MSG_PUB.Count_And_Get(
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data);
END update_payment_method;

PROCEDURE log(
   message      IN      VARCHAR2,
   newline      IN      BOOLEAN DEFAULT TRUE
) IS
BEGIN
  IF message = 'NEWLINE' THEN
   FND_FILE.NEW_LINE(FND_FILE.LOG, 1);
  ELSIF (newline) THEN
    FND_FILE.put_line(fnd_file.log,message);
  ELSE
    FND_FILE.put(fnd_file.log,message);
  END IF;
END log;

/*-----------------------------------------------------------------------
 | Function to fetch messages of the stack and log the error
 | Also returns the error
 |-----------------------------------------------------------------------*/
FUNCTION logerror(SQLERRM VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2 IS
  l_msg_data VARCHAR2(2000);
BEGIN
  FND_MSG_PUB.Reset;

  FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
    l_msg_data := l_msg_data || FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE );
  END LOOP;
  IF (SQLERRM IS NOT NULL) THEN
    l_msg_data := l_msg_data || SQLERRM;
  END IF;
  log(l_msg_data);
  RETURN l_msg_data;
END logerror;

  -- PROCEDURE validate_payment_method
  --
  -- DESCRIPTION
  --     Validate payment method.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_create_update_flag Create or update flag.
  --     p_payment_method_rec Payment method record.
  --   OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.

PROCEDURE validate_payment_method (
   p_create_update_flag        IN VARCHAR2,
   p_payment_method_rec        IN payment_method_rec_type,
   x_return_status             IN OUT NOCOPY VARCHAR2
) IS
   l_dummy                     VARCHAR2(1);

   CURSOR check_cust_acct_id(l_ca_id NUMBER) IS
   select 'X'
   from HZ_CUST_ACCOUNTS
   where cust_account_id = l_ca_id;

   CURSOR check_site_use_id(l_ca_id NUMBER, l_casu_id NUMBER) IS
   SELECT 'X'
   FROM HZ_CUST_SITE_USES_ALL casu, HZ_CUST_ACCT_SITES cas
   WHERE casu.cust_acct_site_id = cas.cust_acct_site_id
   AND cas.cust_account_id = l_ca_id
   AND casu.site_use_id = l_casu_id;

   CURSOR check_receipt_method_id(l_rm_id NUMBER) IS
   SELECT 'X'
   FROM AR_RECEIPT_METHODS
   WHERE receipt_method_id = l_rm_id
   AND sysdate between start_date and nvl(end_date, sysdate);
BEGIN
   -- check not null first
   IF(p_payment_method_rec.receipt_method_id IS NULL OR p_payment_method_rec.receipt_method_id = FND_API.G_MISS_NUM) THEN
     FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
     FND_MESSAGE.SET_TOKEN('COLUMN' ,'RECEIPT_METHOD_ID');
     FND_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF(p_payment_method_rec.primary_flag IS NULL OR p_payment_method_rec.primary_flag = FND_API.G_MISS_CHAR) THEN
     FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
     FND_MESSAGE.SET_TOKEN('COLUMN' ,'PRIMARY_FLAG');
     FND_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF(p_payment_method_rec.cust_account_id IS NULL OR p_payment_method_rec.cust_account_id = FND_API.G_MISS_NUM) THEN
     FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
     FND_MESSAGE.SET_TOKEN('COLUMN' ,'CUSTOMER_ID');
     FND_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF(p_payment_method_rec.start_date IS NULL or p_payment_method_rec.start_date = FND_API.G_MISS_DATE) THEN
     FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
     FND_MESSAGE.SET_TOKEN('COLUMN' ,'START_DATE');
     FND_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- check cust_account_id
   OPEN check_cust_acct_id(p_payment_method_rec.cust_account_id);
   FETCH check_cust_acct_id INTO l_dummy;
   -- if found, then raise error saying already exist
   IF(check_cust_acct_id%NOTFOUND) THEN
     CLOSE check_cust_acct_id;
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_INVALID_FK');
     FND_MESSAGE.SET_TOKEN('FK','CUSTOMER_ID');
     FND_MESSAGE.SET_TOKEN('COLUMN','CUST_ACCOUNT_ID');
     FND_MESSAGE.SET_TOKEN('TABLE','HZ_CUST_ACCOUNTS');
     FND_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_ERROR;
   END IF;
   CLOSE check_cust_acct_id;

   -- check site_use_id and customer_id
   IF NOT(p_payment_method_rec.site_use_id IS NULL or p_payment_method_rec.site_use_id = FND_API.G_MISS_NUM) THEN
     OPEN check_site_use_id(p_payment_method_rec.cust_account_id, p_payment_method_rec.site_use_id);
     FETCH check_site_use_id INTO l_dummy;
     IF(check_site_use_id%NOTFOUND) THEN
       CLOSE check_site_use_id;
       FND_MESSAGE.SET_NAME('AR', 'HZ_API_INVALID_FK');
       FND_MESSAGE.SET_TOKEN('FK','SITE_USE_ID');
       FND_MESSAGE.SET_TOKEN('COLUMN','SITE_USE_ID');
       FND_MESSAGE.SET_TOKEN('TABLE','HZ_CUST_SITE_USES_ALL');
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
     END IF;
     CLOSE check_site_use_id;
   END IF;

   -- check receipt_method_id
   OPEN check_receipt_method_id(p_payment_method_rec.receipt_method_id);
   FETCH check_receipt_method_id INTO l_dummy;
   IF(check_receipt_method_id%NOTFOUND) THEN
     CLOSE check_receipt_method_id;
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_INVALID_FK');
     FND_MESSAGE.SET_TOKEN('FK','RECEIPT_METHOD_ID');
     FND_MESSAGE.SET_TOKEN('COLUMN','RECEIPT_METHOD_ID');
     FND_MESSAGE.SET_TOKEN('TABLE','AR_RECEIPT_METHODS');
     FND_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_ERROR;
   END IF;
   CLOSE check_receipt_method_id;

   -- check primary_flag
   IF NOT(p_payment_method_rec.primary_flag in ('Y','N')) THEN
     fnd_message.set_name('AR', 'HZ_API_INVALID_LOOKUP');
     fnd_message.set_token('COLUMN', 'PRIMARY_FLAG');
     fnd_message.set_token('LOOKUP_TYPE', 'YES/NO');
     fnd_msg_pub.add;
     raise fnd_api.g_exc_error;
   END IF;

   -- check start_date and end_date
   IF NOT(p_payment_method_rec.end_date IS NULL or p_payment_method_rec.end_date = FND_API.G_MISS_DATE) THEN
     IF(p_payment_method_rec.start_date > p_payment_method_rec.end_date) THEN
       fnd_message.set_name('AR', 'HZ_API_DATE_GREATER');
       fnd_message.set_token('DATE2', 'END_DATE');
       fnd_message.set_token('DATE1', 'START_DATE');
       fnd_msg_pub.add;
       raise fnd_api.g_exc_error;
     END IF;
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
     FND_MSG_PUB.ADD;
END validate_payment_method;

END HZ_PAYMENT_METHOD_PUB;

/
