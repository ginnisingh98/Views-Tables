--------------------------------------------------------
--  DDL for Package Body AR_INTEREST_BATCHES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_INTEREST_BATCHES_PKG" AS
/*$Header: ARIIBATB.pls 120.5 2006/04/07 21:47:35 hyu noship $*/

g_not     VARCHAR2(30):=  ARPT_SQL_FUNC_UTIL.get_lookup_meaning ('AR_PROCESS_STATUS','N');
g_error   VARCHAR2(30):=  ARPT_SQL_FUNC_UTIL.get_lookup_meaning ('AR_PROCESS_STATUS','E');
g_success VARCHAR2(30):=  ARPT_SQL_FUNC_UTIL.get_lookup_meaning ('AR_PROCESS_STATUS','S');
g_draft   VARCHAR2(30):=  ARPT_SQL_FUNC_UTIL.get_lookup_meaning ('AR_RUN_TYPE','D');
g_final   VARCHAR2(30):=  ARPT_SQL_FUNC_UTIL.get_lookup_meaning ('AR_RUN_TYPE','F');

FUNCTION get_batch_amount
(p_interest_batch_id   IN NUMBER)
RETURN NUMBER
IS
  CURSOR c IS
  SELECT SUM(NVL(iil.INTEREST_CHARGED,0))
    FROM ar_interest_lines   iil,
         ar_interest_headers ii,
         ar_interest_batches ib
   WHERE iil.interest_header_id = ii.interest_header_id
     AND ib.interest_batch_id   = ii.interest_batch_id
     AND ib.interest_batch_id   = p_interest_batch_id;
  l_batch_amount NUMBER := 0;
BEGIN
  arp_util.debug('AR_INTEREST_BATCHES_PKG.get_batch_amount+');
  arp_util.debug('   p_interest_batch_id  :'||p_interest_batch_id);
  OPEN c;
  FETCH c INTO l_batch_amount;
  IF c%NOTFOUND THEN
    l_batch_amount := 0;
  END IF;
  CLOSE c;
  arp_util.debug('    resultat :'||l_batch_amount);
  arp_util.debug('AR_INTEREST_BATCHES_PKG.get_batch_amount-');
  RETURN l_batch_amount;
END;

PROCEDURE Lock_batch
( p_Interest_Batch_Id            IN  NUMBER,
  p_Batch_Name                   IN  VARCHAR2,
  p_Calculate_Interest_To_Date   IN  DATE,
  p_Gl_Date                      IN  DATE,
  p_Transferred_status           IN  VARCHAR2,
  p_batch_status                 IN  VARCHAR2,
  p_Org_Id                       IN  NUMBER,
  p_object_version_number        IN  NUMBER,
  x_return_status        OUT NOCOPY  VARCHAR2,
  x_msg_count            OUT NOCOPY  NUMBER,
  x_msg_data             OUT NOCOPY  VARCHAR2)
IS
  CURSOR C IS
  SELECT *
    FROM AR_INTEREST_BATCHES
   WHERE Interest_Batch_Id = p_Interest_Batch_Id
   FOR UPDATE OF Interest_Batch_Id NOWAIT;
  Recinfo C%ROWTYPE;
  l_continue    VARCHAR2(1) := 'Y';
BEGIN
  arp_util.debug('AR_INTEREST_BATCHES_PKG.Lock_batch+');
  arp_util.debug('   p_Interest_Batch_Id :'||p_Interest_Batch_Id);
  x_return_status   := fnd_api.g_ret_sts_success;
  OPEN C;
  FETCH C INTO Recinfo;
  IF (C%NOTFOUND) THEN
    CLOSE C;
   l_continue := 'N';
   x_return_status := fnd_api.g_ret_sts_error;
   FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
   fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
  END IF;
  CLOSE C;

  IF l_continue = 'Y' THEN
   IF     (Recinfo.interest_batch_id          = p_Interest_Batch_Id )
      AND (Recinfo.batch_name                 = p_Batch_Name)
      AND (Recinfo.calculate_interest_to_date = p_Calculate_Interest_To_Date)
      AND (Recinfo.gl_date                    = p_Gl_Date)
      AND (NVL(Recinfo.transferred_status,'X')  = NVL(p_Transferred_status,'X'))
      AND (NVL(Recinfo.batch_status,'X')      = NVL(p_batch_status,'X'))
      AND (NVL(Recinfo.org_id,-99)            = NVL(p_Org_Id,-99))
    THEN
      RETURN;
    ELSE
      x_return_status := fnd_api.g_ret_sts_error;
      FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
    END IF;
  END IF;
arp_util.debug('AR_INTEREST_BATCHES_PKG.Lock_batch-');
END Lock_batch;



PROCEDURE  Validate_batch
( p_action                IN VARCHAR2,
  p_updated_by_program    IN VARCHAR2  DEFAULT 'ARIINR',
  p_old_batch_rec         IN ar_interest_batches%ROWTYPE,
  p_new_batch_rec         IN ar_interest_batches%ROWTYPE,
  x_cascade_update        OUT NOCOPY VARCHAR2,
  x_return_status         IN OUT NOCOPY  VARCHAR2)
IS
  --Batch should exists
BEGIN

arp_util.debug(' Validate_batch +');

x_cascade_update  := 'N';

IF p_action = 'UPDATE' THEN

  IF p_old_batch_rec.batch_status IS NULL OR p_new_batch_rec.batch_status IS NULL
  THEN
      FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
      FND_MESSAGE.SET_TOKEN( 'COLUMN', 'BATCH_STATUS' );
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  IF  p_old_batch_rec.transferred_status IS NULL OR p_new_batch_rec.transferred_status IS NULL
  THEN
      FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
      FND_MESSAGE.SET_TOKEN( 'COLUMN', 'TRANSFERRED_STATUS' );
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  IF p_new_batch_rec.batch_status NOT IN ('D','F') OR
     p_old_batch_rec.batch_status NOT IN ('D','F')
  THEN
       arp_util.debug('Value value possible for batch_status is F or D');
       FND_MESSAGE.SET_NAME( 'AR', 'AR_ONLY_VALUE_ALLOWED' );
       FND_MESSAGE.SET_TOKEN( 'COLUMN', 'BATCH_STATUS' );
       FND_MESSAGE.SET_TOKEN( 'VALUES', g_draft||','||g_final);
       FND_MSG_PUB.ADD;
       x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  IF p_new_batch_rec.transferred_status NOT IN ('N','E','S','P') OR
     p_old_batch_rec.transferred_status NOT IN ('N','E','S','P')
  THEN
       arp_util.debug('Value value possible for transferred_status are N, E , S , P');
       FND_MESSAGE.SET_NAME( 'AR', 'AR_ONLY_VALUE_ALLOWED' );
       FND_MESSAGE.SET_TOKEN( 'COLUMN', 'TRANSFERRED_STATUS' );
       FND_MESSAGE.SET_TOKEN( 'VALUES', g_not||','||g_error||','||g_success);
       FND_MSG_PUB.ADD;
       x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;


  IF p_old_batch_rec.batch_status = 'F' AND  p_new_batch_rec.batch_status <> 'F'
  THEN
       arp_util.debug('Can not update the batch status as it is F');
       FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_NONUPDATEABLE_COLUMN' );
       FND_MESSAGE.SET_TOKEN( 'COLUMN', 'batch_status');
       FND_MSG_PUB.ADD;
       x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;


  IF p_updated_by_program = 'ARIINR' THEN
     IF      p_new_batch_rec.transferred_status NOT IN ('N')
        AND  p_new_batch_rec.transferred_status <> p_old_batch_rec.transferred_status
	 THEN
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_message.set_name('AR', 'AR_STATUS_RESERVE_FOR_SRS');
         fnd_msg_pub.add;
     END IF;
  END IF;


  IF p_new_batch_rec.batch_status = 'D' AND p_new_batch_rec.transferred_status <> 'N'  THEN
      arp_util.debug('Draft batch only accepts transferred status N');
      FND_MESSAGE.SET_NAME( 'AR', 'AR_ONLY_VALUE_ALLOWED' );
      FND_MESSAGE.SET_TOKEN( 'COLUMN', 'TRANSFERRED_STATUS' );
      FND_MESSAGE.SET_TOKEN( 'VALUES', g_not);
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;


  IF p_old_batch_rec.transferred_status = 'S' AND p_new_batch_rec.transferred_status <> 'S' THEN
      arp_util.debug('Can not update a successfull batch transferred status');
      FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_NONUPDATEABLE_COLUMN' );
      FND_MESSAGE.SET_TOKEN( 'COLUMN', 'transferred_status' );
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  IF p_old_batch_rec.transferred_status <> 'N' AND p_new_batch_rec.transferred_status ='N' THEN
     x_cascade_update  := 'Y';
  END IF;

  IF p_new_batch_rec.gl_date = fnd_api.g_miss_date THEN
      arp_util.debug('Gl Date can not be null');
      FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
      FND_MESSAGE.SET_TOKEN( 'COLUMN', 'gl_date' );
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  IF  (p_new_batch_rec.gl_date <> fnd_api.g_miss_date) AND
      (p_old_batch_rec.gl_date <> p_new_batch_rec.gl_date)
  THEN
    IF p_new_batch_rec.transferred_status <> 'N' THEN
      FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_NONUPDATEABLE_COLUMN' );
      FND_MESSAGE.SET_TOKEN( 'COLUMN', 'GL_DATE' );
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
  END IF;


END IF;

IF p_action = 'DELETE' THEN
  IF p_old_batch_rec.batch_status <> 'D' THEN
      arp_util.debug('Only Draft batches are delateable');
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME( 'AR', 'AR_DRAFT_BATCH_DELETABLE' );
      FND_MSG_PUB.ADD;
  END IF;
END IF;

arp_util.debug(' Validate_batch -');
END;

PROCEDURE Delete_batch
( p_init_msg_list         IN VARCHAR2 := fnd_api.g_false,
  p_interest_batch_id     IN NUMBER,
  x_object_version_number IN NUMBER,
  x_return_status         OUT NOCOPY  VARCHAR2,
  x_msg_count             OUT NOCOPY  NUMBER,
  x_msg_data              OUT NOCOPY  VARCHAR2)
IS
  CURSOR c IS
  SELECT
     INTEREST_BATCH_ID          ,
     BATCH_NAME                 ,
     CALCULATE_INTEREST_TO_DATE ,
     BATCH_STATUS               ,
     GL_DATE                    ,
     CREATED_BY                 ,
     CREATION_DATE              ,
     TRANSFERRED_status           ,
     ORG_ID                     ,
     OBJECT_VERSION_NUMBER
  FROM ar_interest_batches
  WHERE interest_batch_id = P_INTEREST_BATCH_ID
  FOR UPDATE OF INTEREST_BATCH_ID;
  l_rec        ar_interest_batches%ROWTYPE;
  l_new_rec    ar_interest_batches%ROWTYPE;
  x_cascade_update   VARCHAR2(1);
BEGIN
  arp_util.debug('Delete_Batch +');
  arp_util.debug('  p_interest_batch_id  : '||p_interest_batch_id);

  IF fnd_api.to_boolean(p_init_msg_list) THEN
    fnd_msg_pub.initialize;
  END IF;

  x_return_status          := fnd_api.G_RET_STS_SUCCESS;

  OPEN c;
  FETCH c INTO
     l_rec.INTEREST_BATCH_ID          ,
     l_rec.BATCH_NAME                 ,
     l_rec.CALCULATE_INTEREST_TO_DATE ,
     l_rec.BATCH_STATUS               ,
     l_rec.GL_DATE                    ,
     l_rec.CREATED_BY                 ,
     l_rec.CREATION_DATE              ,
     l_rec.TRANSFERRED_status           ,
     l_rec.ORG_ID                     ,
     l_rec.OBJECT_VERSION_NUMBER;
   CLOSE c;

   IF l_rec.INTEREST_BATCH_ID IS NULL THEN
        fnd_message.set_name('AR', 'HZ_API_NO_RECORD');
        fnd_message.set_token('RECORD', 'ar_interest_batches');
        fnd_message.set_token('VALUE',
          NVL(TO_CHAR(P_INTEREST_BATCH_ID), 'null'));
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

  Validate_batch
  ( p_action                => 'DELETE',
    p_old_batch_rec         => l_rec,
    p_new_batch_rec         => l_new_rec,
    x_cascade_update        => x_cascade_update,
    x_return_status         => x_return_status);

  IF x_return_status <> fnd_api.g_ret_sts_success THEN
    RAISE fnd_api.g_exc_error;
  END IF;

   DELETE FROM ar_interest_lines iil
   WHERE EXISTS
       (SELECT interest_header_id
          FROM ar_interest_headers ii
         WHERE iil.interest_header_id = ii.interest_header_id
           AND ii.interest_batch_id = p_interest_batch_id);

  DELETE FROM ar_interest_headers
  WHERE interest_batch_id = p_interest_batch_id;

  DELETE FROM AR_INTEREST_BATCHES
  WHERE interest_batch_id = p_interest_batch_id ;

  arp_util.debug('Delete_Batch -');
EXCEPTION
  WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

     IF x_msg_count > 1 THEN
      x_msg_data := FND_MSG_PUB.Get(FND_MSG_PUB.G_LAST,FND_API.G_FALSE );
     END IF;
  WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

END Delete_batch;


PROCEDURE update_batch
(p_init_msg_list              IN VARCHAR2 := fnd_api.g_false,
 P_INTEREST_BATCH_ID          IN NUMBER,
 P_BATCH_STATUS               IN VARCHAR2,
 P_TRANSFERRED_status         IN VARCHAR2,
 p_gl_date                    IN DATE     DEFAULT NULL,
 p_updated_by_program         IN VARCHAR2 DEFAULT 'ARIINR',
 x_OBJECT_VERSION_NUMBER      IN OUT NOCOPY NUMBER,
 x_return_status              OUT NOCOPY  VARCHAR2,
 x_msg_count                  OUT NOCOPY  NUMBER,
 x_msg_data                   OUT NOCOPY  VARCHAR2)
IS
  CURSOR c IS
  SELECT
     INTEREST_BATCH_ID          ,
     BATCH_NAME                 ,
     CALCULATE_INTEREST_TO_DATE ,
     BATCH_STATUS               ,
     GL_DATE                    ,
     CREATED_BY                 ,
     CREATION_DATE              ,
     TRANSFERRED_status         ,
     ORG_ID                     ,
     OBJECT_VERSION_NUMBER
  FROM ar_interest_batches
  WHERE interest_batch_id = P_INTEREST_BATCH_ID
  FOR UPDATE OF INTEREST_BATCH_ID;
  l_rec       ar_interest_batches%ROWTYPE;
  l_new_rec   ar_interest_batches%ROWTYPE;
  x_cascade_update        VARCHAR2(1);

BEGIN
  arp_util.debug('update_batch +');
  arp_util.debug('  p_interest_batch_id  : '||p_interest_batch_id);

  savepoint update_batch;

  IF fnd_api.to_boolean(p_init_msg_list) THEN
    fnd_msg_pub.initialize;
  END IF;

  x_return_status          := fnd_api.G_RET_STS_SUCCESS;

  OPEN c;
  FETCH c INTO
     l_rec.INTEREST_BATCH_ID          ,
     l_rec.BATCH_NAME                 ,
     l_rec.CALCULATE_INTEREST_TO_DATE ,
     l_rec.BATCH_STATUS               ,
     l_rec.GL_DATE                    ,
     l_rec.CREATED_BY                 ,
     l_rec.CREATION_DATE              ,
     l_rec.TRANSFERRED_status         ,
     l_rec.ORG_ID                     ,
     l_rec.OBJECT_VERSION_NUMBER;
   CLOSE c;

   IF l_rec.INTEREST_BATCH_ID IS NULL THEN
        fnd_message.set_name('AR', 'HZ_API_NO_RECORD');
        fnd_message.set_token('RECORD', 'ar_interest_batches');
        fnd_message.set_token('VALUE',
          NVL(TO_CHAR(P_INTEREST_BATCH_ID), 'null'));
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

   l_new_rec.INTEREST_BATCH_ID          := P_INTEREST_BATCH_ID;
   l_new_rec.BATCH_STATUS               := P_BATCH_STATUS;
   l_new_rec.TRANSFERRED_status         := P_TRANSFERRED_status;
   l_new_rec.gl_date                    := p_gl_date;

  Validate_batch
  ( p_action                => 'UPDATE',
    p_updated_by_program    => p_updated_by_program,
    p_old_batch_rec         => l_rec,
    p_new_batch_rec         => l_new_rec,
    x_cascade_update        => x_cascade_update,
    x_return_status         => x_return_status);

  IF x_return_status <> fnd_api.g_ret_sts_success THEN
    RAISE fnd_api.g_exc_error;
  END IF;

  x_OBJECT_VERSION_NUMBER   := NVL(x_OBJECT_VERSION_NUMBER,1) + 1;

  IF x_cascade_update = 'Y' THEN

   UPDATE ar_interest_lines iil
   SET process_status = 'N',
       object_version_number = NVL(object_version_number,1) + 1
   WHERE EXISTS
       (SELECT interest_header_id
          FROM ar_interest_headers ii
         WHERE iil.interest_header_id = ii.interest_header_id
           AND ii.interest_batch_id = p_interest_batch_id)
	 AND iil.process_status <> 'S';

  UPDATE ar_interest_headers
     SET process_status = 'N',
         object_version_number = NVL(object_version_number,1) + 1
   WHERE interest_batch_id = p_interest_batch_id
     AND process_status <> 'S';

  END IF;


  UPDATE ar_interest_batches SET
   BATCH_STATUS               = P_BATCH_STATUS,
   transferred_status         = p_transferred_status,
   gl_date                    = DECODE(p_gl_date,NULL,gl_date,p_gl_date),
   LAST_UPDATE_DATE           = SYSDATE,
   LAST_UPDATED_BY            = NVL(arp_global.last_updated_by,-1),
   LAST_UPDATE_LOGIN          = NVL(arp_global.LAST_UPDATE_LOGIN,-1),
   object_version_number      = x_OBJECT_VERSION_NUMBER
  WHERE interest_batch_id     = P_INTEREST_BATCH_ID;

  arp_util.debug('update_batch -');
EXCEPTION
  WHEN fnd_api.g_exc_error THEN
      rollback to update_batch;
      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
     IF x_msg_count > 1 THEN
      x_msg_data := FND_MSG_PUB.Get(FND_MSG_PUB.G_LAST,FND_API.G_FALSE );
     END IF;

  WHEN OTHERS THEN
      rollback to update_batch;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
END;

END AR_INTEREST_BATCHES_PKG;

/
