--------------------------------------------------------
--  DDL for Package Body AR_CHARGE_SCHEDULE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_CHARGE_SCHEDULE_PKG" AS
/* $Header: ARSCAMTB.pls 120.3 2006/03/31 02:32:00 hyu noship $ */

----------------------------------
-- Table Handler for tier set row
----------------------------------
PROCEDURE Insert_schedule_Row
(P_SCHEDULE_ID            IN  NUMBER,
 P_SCHEDULE_NAME          IN  VARCHAR2,
 P_SCHEDULE_DESCRIPTION   IN  VARCHAR2,
 P_ATTRIBUTE_CATEGORY     IN  VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE1             IN  VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE2             IN  VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE3             IN  VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE4             IN  VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE5             IN  VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE6             IN  VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE7             IN  VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE8             IN  VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE9             IN  VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE10            IN  VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE11            IN  VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE12            IN  VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE13            IN  VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE14            IN  VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE15            IN  VARCHAR2 DEFAULT NULL,
 P_OBJECT_VERSION_NUMBER  IN  NUMBER,
 x_return_status          IN  OUT NOCOPY VARCHAR2)
IS
BEGIN
 arp_standard.debug('Insert_schedule_Row +');
  INSERT INTO AR_CHARGE_SCHEDULES
  (SCHEDULE_ID       ,
   SCHEDULE_NAME     ,
   SCHEDULE_DESCRIPTION,
   ATTRIBUTE_CATEGORY,
   ATTRIBUTE1        ,
   ATTRIBUTE2        ,
   ATTRIBUTE3        ,
   ATTRIBUTE4        ,
   ATTRIBUTE5        ,
   ATTRIBUTE6        ,
   ATTRIBUTE7        ,
   ATTRIBUTE8        ,
   ATTRIBUTE9        ,
   ATTRIBUTE10       ,
   ATTRIBUTE11       ,
   ATTRIBUTE12       ,
   ATTRIBUTE13       ,
   ATTRIBUTE14       ,
   ATTRIBUTE15       ,
   OBJECT_VERSION_NUMBER,
   CREATED_BY        ,
   CREATION_DATE     ,
   LAST_UPDATED_BY   ,
   LAST_UPDATE_DATE  ,
   LAST_UPDATE_LOGIN)
  VALUES
  (P_SCHEDULE_ID       ,
   P_SCHEDULE_NAME     ,
   DECODE(P_SCHEDULE_DESCRIPTION,FND_API.G_MISS_CHAR,NULL,P_SCHEDULE_DESCRIPTION),
   DECODE(P_ATTRIBUTE_CATEGORY,FND_API.G_MISS_CHAR,NULL,P_ATTRIBUTE_CATEGORY),
   DECODE(P_ATTRIBUTE1        ,FND_API.G_MISS_CHAR,NULL,P_ATTRIBUTE1),
   DECODE(P_ATTRIBUTE2        ,FND_API.G_MISS_CHAR,NULL,P_ATTRIBUTE2),
   DECODE(P_ATTRIBUTE3        ,FND_API.G_MISS_CHAR,NULL,P_ATTRIBUTE3),
   DECODE(P_ATTRIBUTE4        ,FND_API.G_MISS_CHAR,NULL,P_ATTRIBUTE4),
   DECODE(P_ATTRIBUTE5        ,FND_API.G_MISS_CHAR,NULL,P_ATTRIBUTE5),
   DECODE(P_ATTRIBUTE6        ,FND_API.G_MISS_CHAR,NULL,P_ATTRIBUTE6),
   DECODE(P_ATTRIBUTE7        ,FND_API.G_MISS_CHAR,NULL,P_ATTRIBUTE7),
   DECODE(P_ATTRIBUTE8        ,FND_API.G_MISS_CHAR,NULL,P_ATTRIBUTE8),
   DECODE(P_ATTRIBUTE9        ,FND_API.G_MISS_CHAR,NULL,P_ATTRIBUTE9),
   DECODE(P_ATTRIBUTE10       ,FND_API.G_MISS_CHAR,NULL,P_ATTRIBUTE10),
   DECODE(P_ATTRIBUTE11       ,FND_API.G_MISS_CHAR,NULL,P_ATTRIBUTE11),
   DECODE(P_ATTRIBUTE12       ,FND_API.G_MISS_CHAR,NULL,P_ATTRIBUTE12),
   DECODE(P_ATTRIBUTE13       ,FND_API.G_MISS_CHAR,NULL,P_ATTRIBUTE13),
   DECODE(P_ATTRIBUTE14       ,FND_API.G_MISS_CHAR,NULL,P_ATTRIBUTE14),
   DECODE(P_ATTRIBUTE15       ,FND_API.G_MISS_CHAR,NULL,P_ATTRIBUTE15),
   p_object_version_number,
   NVL(FND_GLOBAL.user_id,-1),
   TRUNC(SYSDATE),
   NVL(FND_GLOBAL.user_id,-1),
   TRUNC(SYSDATE),
   NVL(FND_GLOBAL.login_id,-1));

 arp_standard.debug('Insert_schedule_Row -');
EXCEPTION
  WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR' ,'Insert_schedule_Row:'||SQLERRM);
     FND_MSG_PUB.ADD;
END Insert_schedule_Row;



PROCEDURE Update_schedule_Row
(P_SCHEDULE_ID            IN  NUMBER,
 P_SCHEDULE_DESCRIPTION   IN  VARCHAR2,
 P_ATTRIBUTE_CATEGORY     IN  VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE1             IN  VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE2             IN  VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE3             IN  VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE4             IN  VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE5             IN  VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE6             IN  VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE7             IN  VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE8             IN  VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE9             IN  VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE10            IN  VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE11            IN  VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE12            IN  VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE13            IN  VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE14            IN  VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE15            IN  VARCHAR2 DEFAULT NULL,
 X_OBJECT_VERSION_NUMBER  IN  OUT NOCOPY NUMBER,
 x_return_status          IN  OUT NOCOPY VARCHAR2)
IS
BEGIN
 arp_standard.debug('Insert_schedule_Row +');
  UPDATE AR_CHARGE_SCHEDULES SET
    SCHEDULE_DESCRIPTION = DECODE(P_SCHEDULE_DESCRIPTION,
                                     FND_API.G_MISS_CHAR, NULL,
                                     NULL               , SCHEDULE_DESCRIPTION, P_SCHEDULE_DESCRIPTION  ),
    ATTRIBUTE_CATEGORY    = DECODE(P_ATTRIBUTE_CATEGORY,
                                     FND_API.G_MISS_CHAR, NULL,
                                     NULL               , ATTRIBUTE_CATEGORY, P_ATTRIBUTE_CATEGORY),
    ATTRIBUTE1            = DECODE(P_ATTRIBUTE1,
                                     FND_API.G_MISS_CHAR, NULL,
                                     NULL               , ATTRIBUTE1, P_ATTRIBUTE1),
    ATTRIBUTE2            = DECODE(P_ATTRIBUTE2,
                                     FND_API.G_MISS_CHAR, NULL,
                                     NULL               , ATTRIBUTE2, P_ATTRIBUTE2),
    ATTRIBUTE3            = DECODE(P_ATTRIBUTE3,
                                     FND_API.G_MISS_CHAR, NULL,
                                     NULL               , ATTRIBUTE3, P_ATTRIBUTE3),
    ATTRIBUTE4            = DECODE(P_ATTRIBUTE4,
                                     FND_API.G_MISS_CHAR, NULL,
                                     NULL               , ATTRIBUTE4, P_ATTRIBUTE4),
    ATTRIBUTE5            = DECODE(P_ATTRIBUTE5,
                                     FND_API.G_MISS_CHAR, NULL,
                                     NULL               , ATTRIBUTE5, P_ATTRIBUTE5),
    ATTRIBUTE6            = DECODE(P_ATTRIBUTE6,
                                     FND_API.G_MISS_CHAR, NULL,
                                     NULL               , ATTRIBUTE6, P_ATTRIBUTE6),
    ATTRIBUTE7            = DECODE(P_ATTRIBUTE7,
                                     FND_API.G_MISS_CHAR, NULL,
                                     NULL               , ATTRIBUTE7, P_ATTRIBUTE7),
    ATTRIBUTE8            = DECODE(P_ATTRIBUTE8,
                                     FND_API.G_MISS_CHAR, NULL,
                                     NULL               , ATTRIBUTE8, P_ATTRIBUTE8),
    ATTRIBUTE9            = DECODE(P_ATTRIBUTE9,
                                     FND_API.G_MISS_CHAR, NULL,
                                     NULL               , ATTRIBUTE9, P_ATTRIBUTE9),
    ATTRIBUTE10           = DECODE(P_ATTRIBUTE10,
                                     FND_API.G_MISS_CHAR, NULL,
                                     NULL               , ATTRIBUTE10, P_ATTRIBUTE10),
    ATTRIBUTE11           = DECODE(P_ATTRIBUTE11,
                                     FND_API.G_MISS_CHAR, NULL,
                                     NULL               , ATTRIBUTE11, P_ATTRIBUTE11),
    ATTRIBUTE12           = DECODE(P_ATTRIBUTE12,
                                     FND_API.G_MISS_CHAR, NULL,
                                     NULL               , ATTRIBUTE12, P_ATTRIBUTE12),
    ATTRIBUTE13           = DECODE(P_ATTRIBUTE13,
                                     FND_API.G_MISS_CHAR, NULL,
                                     NULL               , ATTRIBUTE13, P_ATTRIBUTE13),
    ATTRIBUTE14           = DECODE(P_ATTRIBUTE14,
                                     FND_API.G_MISS_CHAR, NULL,
                                     NULL               , ATTRIBUTE14, P_ATTRIBUTE14),
    ATTRIBUTE15           = DECODE(P_ATTRIBUTE15,
                                     FND_API.G_MISS_CHAR, NULL,
                                     NULL               , ATTRIBUTE15, P_ATTRIBUTE15),
    OBJECT_VERSION_NUMBER   = OBJECT_VERSION_NUMBER + 1,
    LAST_UPDATE_DATE        = TRUNC(SYSDATE),
    LAST_UPDATED_BY         = NVL(FND_GLOBAL.user_id,-1),
    LAST_UPDATE_LOGIN       = NVL(FND_GLOBAL.login_id,-1)
 WHERE SCHEDULE_ID = P_SCHEDULE_ID
 RETURNING OBJECT_VERSION_NUMBER INTO x_OBJECT_VERSION_NUMBER;
 arp_standard.debug('Insert_schedule_Row -');
EXCEPTION
  WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR' ,'Insert_schedule_Row:'||SQLERRM);
     FND_MSG_PUB.ADD;
END Update_schedule_Row;



-------------------------------------------
-- Table Handler insert schedule header row
-------------------------------------------
PROCEDURE Insert_Head_Row
(P_SCHEDULE_HEADER_ID     IN NUMBER,
 P_SCHEDULE_ID            IN NUMBER,
 P_SCHEDULE_HEADER_TYPE   IN VARCHAR2,
 P_AGING_BUCKET_ID        IN NUMBER,
 P_START_DATE             IN DATE,
 P_END_DATE               IN DATE,
 P_STATUS                 IN VARCHAR2,
 P_ATTRIBUTE_CATEGORY     IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE1             IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE2             IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE3             IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE4             IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE5             IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE6             IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE7             IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE8             IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE9             IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE10            IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE11            IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE12            IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE13            IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE14            IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE15            IN VARCHAR2 DEFAULT NULL,
 P_OBJECT_VERSION_NUMBER  IN NUMBER,
 x_return_status          IN OUT NOCOPY VARCHAR2)
IS
BEGIN
 arp_standard.debug('Insert_Head_Row +');
  INSERT INTO AR_charge_SCHEDULE_HDRS
  (SCHEDULE_HEADER_ID,
   SCHEDULE_ID       ,
   SCHEDULE_HEADER_TYPE,
   AGING_BUCKET_ID   ,
   START_DATE        ,
   END_DATE          ,
   STATUS            ,
   ATTRIBUTE_CATEGORY,
   ATTRIBUTE1        ,
   ATTRIBUTE2        ,
   ATTRIBUTE3        ,
   ATTRIBUTE4        ,
   ATTRIBUTE5        ,
   ATTRIBUTE6        ,
   ATTRIBUTE7        ,
   ATTRIBUTE8        ,
   ATTRIBUTE9        ,
   ATTRIBUTE10       ,
   ATTRIBUTE11       ,
   ATTRIBUTE12       ,
   ATTRIBUTE13       ,
   ATTRIBUTE14       ,
   ATTRIBUTE15       ,
   OBJECT_VERSION_NUMBER,
   CREATED_BY        ,
   CREATION_DATE     ,
   LAST_UPDATED_BY   ,
   LAST_UPDATE_DATE  ,
   LAST_UPDATE_LOGIN)
  VALUES
  (P_SCHEDULE_HEADER_ID  ,
   P_SCHEDULE_ID         ,
   P_SCHEDULE_HEADER_TYPE,
   P_AGING_BUCKET_ID     ,
   P_START_DATE          ,
   DECODE(P_END_DATE   ,FND_API.G_MISS_DATE,NULL,P_END_DATE),
   P_STATUS              ,
   DECODE(P_ATTRIBUTE_CATEGORY,FND_API.G_MISS_CHAR,NULL,P_ATTRIBUTE_CATEGORY),
   DECODE(P_ATTRIBUTE1        ,FND_API.G_MISS_CHAR,NULL,P_ATTRIBUTE1),
   DECODE(P_ATTRIBUTE2        ,FND_API.G_MISS_CHAR,NULL,P_ATTRIBUTE2),
   DECODE(P_ATTRIBUTE3        ,FND_API.G_MISS_CHAR,NULL,P_ATTRIBUTE3),
   DECODE(P_ATTRIBUTE4        ,FND_API.G_MISS_CHAR,NULL,P_ATTRIBUTE4),
   DECODE(P_ATTRIBUTE5        ,FND_API.G_MISS_CHAR,NULL,P_ATTRIBUTE5),
   DECODE(P_ATTRIBUTE6        ,FND_API.G_MISS_CHAR,NULL,P_ATTRIBUTE6),
   DECODE(P_ATTRIBUTE7        ,FND_API.G_MISS_CHAR,NULL,P_ATTRIBUTE7),
   DECODE(P_ATTRIBUTE8        ,FND_API.G_MISS_CHAR,NULL,P_ATTRIBUTE8),
   DECODE(P_ATTRIBUTE9        ,FND_API.G_MISS_CHAR,NULL,P_ATTRIBUTE9),
   DECODE(P_ATTRIBUTE10       ,FND_API.G_MISS_CHAR,NULL,P_ATTRIBUTE10),
   DECODE(P_ATTRIBUTE11       ,FND_API.G_MISS_CHAR,NULL,P_ATTRIBUTE11),
   DECODE(P_ATTRIBUTE12       ,FND_API.G_MISS_CHAR,NULL,P_ATTRIBUTE12),
   DECODE(P_ATTRIBUTE13       ,FND_API.G_MISS_CHAR,NULL,P_ATTRIBUTE13),
   DECODE(P_ATTRIBUTE14       ,FND_API.G_MISS_CHAR,NULL,P_ATTRIBUTE14),
   DECODE(P_ATTRIBUTE15       ,FND_API.G_MISS_CHAR,NULL,P_ATTRIBUTE15),
   P_OBJECT_VERSION_NUMBER,
   NVL(FND_GLOBAL.user_id,-1),
   TRUNC(SYSDATE),
   NVL(FND_GLOBAL.user_id,-1),
   TRUNC(SYSDATE),
   NVL(FND_GLOBAL.login_id,-1));

 arp_standard.debug('Insert_Head_Row -');
EXCEPTION
  WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR' ,'Insert_Head_Row:'||SQLERRM);
     FND_MSG_PUB.ADD;
END Insert_Head_Row;







----------------------------------
-- Table Handler Update header row
----------------------------------
PROCEDURE Update_Head_Row
(P_SCHEDULE_HEADER_ID     IN NUMBER,
 P_END_DATE               IN DATE,
 P_STATUS                 IN VARCHAR2,
 P_ATTRIBUTE_CATEGORY     IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE1             IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE2             IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE3             IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE4             IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE5             IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE6             IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE7             IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE8             IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE9             IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE10            IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE11            IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE12            IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE13            IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE14            IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE15            IN VARCHAR2 DEFAULT NULL,
 x_OBJECT_VERSION_NUMBER  OUT NOCOPY NUMBER,
 x_return_status          IN OUT NOCOPY VARCHAR2)
IS
BEGIN
 arp_standard.debug('Update_Head_Row +');

 UPDATE ar_charge_schedule_hdrs SET
    END_DATE              = DECODE(P_END_DATE,
                                     FND_API.G_MISS_DATE, NULL,
                                     NULL               , END_DATE, P_END_DATE    ),
    STATUS                = DECODE(P_STATUS,
                                     FND_API.G_MISS_CHAR, NULL,
                                     NULL               , STATUS, P_STATUS    ),
    ATTRIBUTE_CATEGORY    = DECODE(P_ATTRIBUTE_CATEGORY,
                                     FND_API.G_MISS_CHAR, NULL,
                                     NULL               , ATTRIBUTE_CATEGORY, P_ATTRIBUTE_CATEGORY),
    ATTRIBUTE1            = DECODE(P_ATTRIBUTE1,
                                     FND_API.G_MISS_CHAR, NULL,
                                     NULL               , ATTRIBUTE1, P_ATTRIBUTE1),
    ATTRIBUTE2            = DECODE(P_ATTRIBUTE2,
                                     FND_API.G_MISS_CHAR, NULL,
                                     NULL               , ATTRIBUTE2, P_ATTRIBUTE2),
    ATTRIBUTE3            = DECODE(P_ATTRIBUTE3,
                                     FND_API.G_MISS_CHAR, NULL,
                                     NULL               , ATTRIBUTE3, P_ATTRIBUTE3),
    ATTRIBUTE4            = DECODE(P_ATTRIBUTE4,
                                     FND_API.G_MISS_CHAR, NULL,
                                     NULL               , ATTRIBUTE4, P_ATTRIBUTE4),
    ATTRIBUTE5            = DECODE(P_ATTRIBUTE5,
                                     FND_API.G_MISS_CHAR, NULL,
                                     NULL               , ATTRIBUTE5, P_ATTRIBUTE5),
    ATTRIBUTE6            = DECODE(P_ATTRIBUTE6,
                                     FND_API.G_MISS_CHAR, NULL,
                                     NULL               , ATTRIBUTE6, P_ATTRIBUTE6),
    ATTRIBUTE7            = DECODE(P_ATTRIBUTE7,
                                     FND_API.G_MISS_CHAR, NULL,
                                     NULL               , ATTRIBUTE7, P_ATTRIBUTE7),
    ATTRIBUTE8            = DECODE(P_ATTRIBUTE8,
                                     FND_API.G_MISS_CHAR, NULL,
                                     NULL               , ATTRIBUTE8, P_ATTRIBUTE8),
    ATTRIBUTE9            = DECODE(P_ATTRIBUTE9,
                                     FND_API.G_MISS_CHAR, NULL,
                                     NULL               , ATTRIBUTE9, P_ATTRIBUTE9),
    ATTRIBUTE10           = DECODE(P_ATTRIBUTE10,
                                     FND_API.G_MISS_CHAR, NULL,
                                     NULL               , ATTRIBUTE10, P_ATTRIBUTE10),
    ATTRIBUTE11           = DECODE(P_ATTRIBUTE11,
                                     FND_API.G_MISS_CHAR, NULL,
                                     NULL               , ATTRIBUTE11, P_ATTRIBUTE11),
    ATTRIBUTE12           = DECODE(P_ATTRIBUTE12,
                                     FND_API.G_MISS_CHAR, NULL,
                                     NULL               , ATTRIBUTE12, P_ATTRIBUTE12),
    ATTRIBUTE13           = DECODE(P_ATTRIBUTE13,
                                     FND_API.G_MISS_CHAR, NULL,
                                     NULL               , ATTRIBUTE13, P_ATTRIBUTE13),
    ATTRIBUTE14           = DECODE(P_ATTRIBUTE14,
                                     FND_API.G_MISS_CHAR, NULL,
                                     NULL               , ATTRIBUTE14, P_ATTRIBUTE14),
    ATTRIBUTE15           = DECODE(P_ATTRIBUTE15,
                                     FND_API.G_MISS_CHAR, NULL,
                                     NULL               , ATTRIBUTE15, P_ATTRIBUTE15),
    OBJECT_VERSION_NUMBER   = OBJECT_VERSION_NUMBER + 1,
    LAST_UPDATE_DATE        = TRUNC(SYSDATE),
    LAST_UPDATED_BY         = NVL(FND_GLOBAL.user_id,-1),
    LAST_UPDATE_LOGIN       = NVL(FND_GLOBAL.login_id,-1)
 WHERE SCHEDULE_HEADER_ID = P_SCHEDULE_HEADER_ID
 RETURNING OBJECT_VERSION_NUMBER INTO x_OBJECT_VERSION_NUMBER;

 arp_standard.debug('Update_Head_Row -');
EXCEPTION
  WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR' ,'Update_Head_Row:'||SQLERRM);
     FND_MSG_PUB.ADD;
END Update_Head_Row;



----------------------------------
-- Table Handler insert line row
----------------------------------
PROCEDURE Insert_Line_Row
(P_SCHEDULE_LINE_ID       IN NUMBER,
 P_SCHEDULE_HEADER_ID     IN NUMBER,
 P_SCHEDULE_ID            IN NUMBER,
 P_AGING_BUCKET_ID        IN NUMBER,
 P_AGING_BUCKET_LINE_ID   IN NUMBER,
 P_AMOUNT                 IN NUMBER,
 P_RATE                   IN NUMBER,
 P_ATTRIBUTE_CATEGORY     IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE1             IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE2             IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE3             IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE4             IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE5             IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE6             IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE7             IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE8             IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE9             IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE10            IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE11            IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE12            IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE13            IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE14            IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE15            IN VARCHAR2 DEFAULT NULL,
 P_OBJECT_VERSION_NUMBER  IN NUMBER,
 x_return_status          IN OUT NOCOPY VARCHAR2)
IS
BEGIN
 arp_standard.debug('Insert_Line_Row +');
  INSERT INTO AR_charge_SCHEDULE_LINES
  (SCHEDULE_LINE_ID   ,
   SCHEDULE_HEADER_ID ,
   SCHEDULE_ID        ,
   AGING_BUCKET_ID    ,
   AGING_BUCKET_LINE_ID,
   AMOUNT             ,
   RATE               ,
   ATTRIBUTE_CATEGORY ,
   ATTRIBUTE1         ,
   ATTRIBUTE2         ,
   ATTRIBUTE3         ,
   ATTRIBUTE4         ,
   ATTRIBUTE5         ,
   ATTRIBUTE6         ,
   ATTRIBUTE7         ,
   ATTRIBUTE8         ,
   ATTRIBUTE9         ,
   ATTRIBUTE10        ,
   ATTRIBUTE11        ,
   ATTRIBUTE12        ,
   ATTRIBUTE13        ,
   ATTRIBUTE14        ,
   ATTRIBUTE15        ,
   OBJECT_VERSION_NUMBER,
   CREATED_BY         ,
   CREATION_DATE      ,
   LAST_UPDATED_BY    ,
   LAST_UPDATE_DATE   ,
   LAST_UPDATE_LOGIN)
  VALUES
  (P_SCHEDULE_LINE_ID   ,
   P_SCHEDULE_HEADER_ID ,
   P_SCHEDULE_ID        ,
   P_AGING_BUCKET_ID    ,
   P_AGING_BUCKET_LINE_ID,
   DECODE(P_AMOUNT, FND_API.G_MISS_NUM, NULL, P_AMOUNT),
   DECODE(P_RATE  , FND_API.G_MISS_NUM, NULL, P_RATE  ),
   DECODE(P_ATTRIBUTE_CATEGORY,FND_API.G_MISS_CHAR,NULL,P_ATTRIBUTE_CATEGORY),
   DECODE(P_ATTRIBUTE1        ,FND_API.G_MISS_CHAR,NULL,P_ATTRIBUTE1),
   DECODE(P_ATTRIBUTE2        ,FND_API.G_MISS_CHAR,NULL,P_ATTRIBUTE2),
   DECODE(P_ATTRIBUTE3        ,FND_API.G_MISS_CHAR,NULL,P_ATTRIBUTE3),
   DECODE(P_ATTRIBUTE4        ,FND_API.G_MISS_CHAR,NULL,P_ATTRIBUTE4),
   DECODE(P_ATTRIBUTE5        ,FND_API.G_MISS_CHAR,NULL,P_ATTRIBUTE5),
   DECODE(P_ATTRIBUTE6        ,FND_API.G_MISS_CHAR,NULL,P_ATTRIBUTE6),
   DECODE(P_ATTRIBUTE7        ,FND_API.G_MISS_CHAR,NULL,P_ATTRIBUTE7),
   DECODE(P_ATTRIBUTE8        ,FND_API.G_MISS_CHAR,NULL,P_ATTRIBUTE8),
   DECODE(P_ATTRIBUTE9        ,FND_API.G_MISS_CHAR,NULL,P_ATTRIBUTE9),
   DECODE(P_ATTRIBUTE10       ,FND_API.G_MISS_CHAR,NULL,P_ATTRIBUTE10),
   DECODE(P_ATTRIBUTE11       ,FND_API.G_MISS_CHAR,NULL,P_ATTRIBUTE11),
   DECODE(P_ATTRIBUTE12       ,FND_API.G_MISS_CHAR,NULL,P_ATTRIBUTE12),
   DECODE(P_ATTRIBUTE13       ,FND_API.G_MISS_CHAR,NULL,P_ATTRIBUTE13),
   DECODE(P_ATTRIBUTE14       ,FND_API.G_MISS_CHAR,NULL,P_ATTRIBUTE14),
   DECODE(P_ATTRIBUTE15       ,FND_API.G_MISS_CHAR,NULL,P_ATTRIBUTE15),
   P_OBJECT_VERSION_NUMBER,
   NVL(FND_GLOBAL.user_id,-1),
   TRUNC(SYSDATE),
   NVL(FND_GLOBAL.user_id,-1),
   TRUNC(SYSDATE),
   NVL(FND_GLOBAL.login_id,-1));

 arp_standard.debug('Insert_Line_Row -');
EXCEPTION
  WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
     FND_MSG_PUB.ADD;
END Insert_Line_Row;


PROCEDURE update_Line_Row
(P_SCHEDULE_LINE_ID       IN NUMBER,
 P_AMOUNT                 IN NUMBER,
 P_RATE                   IN NUMBER,
 P_ATTRIBUTE_CATEGORY     IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE1             IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE2             IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE3             IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE4             IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE5             IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE6             IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE7             IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE8             IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE9             IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE10            IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE11            IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE12            IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE13            IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE14            IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE15            IN VARCHAR2 DEFAULT NULL,
 X_OBJECT_VERSION_NUMBER  IN OUT NOCOPY NUMBER,
 x_return_status          IN OUT NOCOPY VARCHAR2)
IS
BEGIN
 arp_standard.debug('Update_Line_Row +');
  X_OBJECT_VERSION_NUMBER  := X_OBJECT_VERSION_NUMBER + 1;
  UPDATE AR_charge_SCHEDULE_LINES SET
   AMOUNT             = DECODE(p_amount,
                                 fnd_api.g_miss_num, NULL,
                                 NULL              ,AMOUNT,p_amount),
   RATE               = DECODE(p_rate,
                                 fnd_api.g_miss_num, NULL,
                                 NULL              ,RATE,p_rate),
    ATTRIBUTE_CATEGORY    = DECODE(P_ATTRIBUTE_CATEGORY,
                                     FND_API.G_MISS_CHAR, NULL,
                                     NULL               , ATTRIBUTE_CATEGORY, P_ATTRIBUTE_CATEGORY),
    ATTRIBUTE1            = DECODE(P_ATTRIBUTE1,
                                     FND_API.G_MISS_CHAR, NULL,
                                     NULL               , ATTRIBUTE1, P_ATTRIBUTE1),
    ATTRIBUTE2            = DECODE(P_ATTRIBUTE2,
                                     FND_API.G_MISS_CHAR, NULL,
                                     NULL               , ATTRIBUTE2, P_ATTRIBUTE2),
    ATTRIBUTE3            = DECODE(P_ATTRIBUTE3,
                                     FND_API.G_MISS_CHAR, NULL,
                                     NULL               , ATTRIBUTE3, P_ATTRIBUTE3),
    ATTRIBUTE4            = DECODE(P_ATTRIBUTE4,
                                     FND_API.G_MISS_CHAR, NULL,
                                     NULL               , ATTRIBUTE4, P_ATTRIBUTE4),
    ATTRIBUTE5            = DECODE(P_ATTRIBUTE5,
                                     FND_API.G_MISS_CHAR, NULL,
                                     NULL               , ATTRIBUTE5, P_ATTRIBUTE5),
    ATTRIBUTE6            = DECODE(P_ATTRIBUTE6,
                                     FND_API.G_MISS_CHAR, NULL,
                                     NULL               , ATTRIBUTE6, P_ATTRIBUTE6),
    ATTRIBUTE7            = DECODE(P_ATTRIBUTE7,
                                     FND_API.G_MISS_CHAR, NULL,
                                     NULL               , ATTRIBUTE7, P_ATTRIBUTE7),
    ATTRIBUTE8            = DECODE(P_ATTRIBUTE8,
                                     FND_API.G_MISS_CHAR, NULL,
                                     NULL               , ATTRIBUTE8, P_ATTRIBUTE8),
    ATTRIBUTE9            = DECODE(P_ATTRIBUTE9,
                                     FND_API.G_MISS_CHAR, NULL,
                                     NULL               , ATTRIBUTE9, P_ATTRIBUTE9),
    ATTRIBUTE10           = DECODE(P_ATTRIBUTE10,
                                     FND_API.G_MISS_CHAR, NULL,
                                     NULL               , ATTRIBUTE10, P_ATTRIBUTE10),
    ATTRIBUTE11           = DECODE(P_ATTRIBUTE11,
                                     FND_API.G_MISS_CHAR, NULL,
                                     NULL               , ATTRIBUTE11, P_ATTRIBUTE11),
    ATTRIBUTE12           = DECODE(P_ATTRIBUTE12,
                                     FND_API.G_MISS_CHAR, NULL,
                                     NULL               , ATTRIBUTE12, P_ATTRIBUTE12),
    ATTRIBUTE13           = DECODE(P_ATTRIBUTE13,
                                     FND_API.G_MISS_CHAR, NULL,
                                     NULL               , ATTRIBUTE13, P_ATTRIBUTE13),
    ATTRIBUTE14           = DECODE(P_ATTRIBUTE14,
                                     FND_API.G_MISS_CHAR, NULL,
                                     NULL               , ATTRIBUTE14, P_ATTRIBUTE14),
    ATTRIBUTE15           = DECODE(P_ATTRIBUTE15,
                                     FND_API.G_MISS_CHAR, NULL,
                                     NULL               , ATTRIBUTE15, P_ATTRIBUTE15),
    OBJECT_VERSION_NUMBER   = X_OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE        = TRUNC(SYSDATE),
    LAST_UPDATED_BY         = NVL(FND_GLOBAL.user_id,-1),
    LAST_UPDATE_LOGIN       = NVL(FND_GLOBAL.login_id,-1)
  WHERE SCHEDULE_LINE_ID = P_SCHEDULE_LINE_ID;


 arp_standard.debug('Update_Line_Row -');
EXCEPTION
  WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
     FND_MSG_PUB.ADD;
END Update_Line_Row;




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



FUNCTION compare
 (date1 DATE,
  date2 DATE)
RETURN NUMBER
IS
  ldate1 date;
  ldate2 date;
BEGIN
  ldate1 := date1;
  ldate2 := date2;
  IF ((ldate1 IS NULL OR ldate1 = FND_API.G_MISS_DATE) AND (ldate2 IS NULL OR ldate2 = FND_API.G_MISS_DATE)) THEN
      RETURN 0;
  ELSIF (ldate2 IS NULL OR ldate2 = FND_API.G_MISS_DATE) THEN
      RETURN -1;
  ELSIF (ldate1 IS NULL OR ldate1 = FND_API.G_MISS_DATE) THEN
      RETURN 1;
  ELSIF ( ldate1 = ldate2 ) THEN
      RETURN 0;
  ELSIF ( ldate1 > ldate2 ) THEN
      RETURN 1;
  ELSE
      RETURN -1;
  END IF;
END compare;



PROCEDURE validate_schedule
(P_SCHEDULE_NAME          IN VARCHAR2,
 P_SCHEDULE_DESCRIPTION   IN VARCHAR2,
 P_MODE                   IN VARCHAR2,
 x_return_status          IN OUT NOCOPY VARCHAR2)
IS
BEGIN
  -------------------------
  -- Validate schedule_name
  -------------------------
  arp_standard.debug('  Validate schedule_name +');
  IF p_mode = 'INSERT' THEN
    IF p_schedule_name IS NULL OR p_schedule_name = FND_API.G_MISS_CHAR THEN
       FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
       FND_MESSAGE.SET_TOKEN( 'COLUMN', 'schedule_name' );
       FND_MSG_PUB.ADD;
       x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
  END IF;
  arp_standard.debug('  Validate schedule_name -');
END;



PROCEDURE validate_schedule_header
(P_SCHEDULE_HEADER_ID     IN NUMBER,
 P_SCHEDULE_ID            IN NUMBER,
 P_SCHEDULE_HEADER_TYPE   IN VARCHAR2,
 P_AGING_BUCKET_ID        IN NUMBER,
 P_START_DATE             IN DATE,
 P_END_DATE               IN DATE,
 P_STATUS                 IN VARCHAR2,
 P_OLD_STATUS             IN VARCHAR2,
 p_mode                   IN VARCHAR2,
 x_return_status          IN OUT NOCOPY VARCHAR2)
IS
  CURSOR c_schedule_id IS
  SELECT NULL
    FROM ar_charge_schedules
   WHERE schedule_id = p_schedule_id;

  CURSOR c_aging_bucket IS
  SELECT NULL
    FROM ar_aging_buckets
   WHERE aging_bucket_id = P_AGING_BUCKET_ID;

  CURSOR c_overlapp IS
  SELECT start_date,
         end_date
    FROM ar_charge_schedule_hdrs
   WHERE schedule_id = p_schedule_id
     AND status      = 'A';

  CURSOR c_overlapp_upd IS
  SELECT start_date,
         end_date
    FROM ar_charge_schedule_hdrs
   WHERE schedule_id = p_schedule_id
     AND schedule_header_id <> P_SCHEDULE_HEADER_ID
     AND status      = 'A';

  l_start_date   DATE;
  l_end_date     DATE;
  l_val          NUMBER;
  l_cpt          NUMBER := 0;
  l_c            VARCHAR2(1);
BEGIN

  arp_standard.debug('validate_schedule_header +');


  IF p_mode IN ('INSERT') THEN
    -------------------------------------
    -- Validate schedule_id
    -------------------------------------
    arp_standard.debug('  Validate schedule_id +');
    IF P_SCHEDULE_ID IS NULL OR P_SCHEDULE_ID = fnd_api.g_miss_num THEN
       FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
       FND_MESSAGE.SET_TOKEN( 'COLUMN', 'SCHEDULE_ID' );
       FND_MSG_PUB.ADD;
       x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
    OPEN c_schedule_id;
    FETCH c_schedule_id INTO l_c;
    IF c_schedule_id%NOTFOUND THEN
       FND_MESSAGE.SET_NAME('AR', 'HZ_API_INVALID_FK');
       FND_MESSAGE.SET_TOKEN('FK', 'ar charge schedules');
       FND_MESSAGE.SET_TOKEN('COLUMN', 'schedule_id');
       FND_MESSAGE.SET_TOKEN('TABLE', 'ar_charge_schedules');
       FND_MSG_PUB.ADD;
       x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
    CLOSE c_schedule_id;
    arp_standard.debug('  Validate schedule_id -');

    --------------------------------------------------------------------------
    -- Validate SCHEDULE_HEADER_TYPE lookup code in lookup type SCHEDULE_HEADER_TYPE
    --------------------------------------------------------------------------
    arp_standard.debug('  Validate schedule_header_type +');
    IF p_schedule_header_type IS NULL OR p_schedule_header_type = fnd_api.g_miss_char THEN
       FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
       FND_MESSAGE.SET_TOKEN( 'COLUMN', 'schedule_header_type' );
       FND_MSG_PUB.ADD;
       x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    IF validate_lookup('SCHEDULE_HEADER_TYPE',p_schedule_header_type) = FALSE THEN
       arp_standard.debug('   schedule type should be lookup code for the lookup type SCHEDULE_HEADER_TYPE');
       FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_INVALID_LOOKUP' );
       FND_MESSAGE.SET_TOKEN( 'COLUMN', 'schedule header type' );
       FND_MESSAGE.SET_TOKEN( 'LOOKUP_TYPE', 'SCHEDULE_HEADER_TYPE' );
       FND_MSG_PUB.ADD;
       x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
    arp_standard.debug('  Validate schedule_header_type -');


    -------------------------------------------------------------
    -- Validate STATUS lookup code in lookup type REGISTRY_STATUS
    -------------------------------------------------------------
    arp_standard.debug('  Validate status +');
    IF p_status IS NULL OR p_status = fnd_api.g_miss_char THEN
       FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
       FND_MESSAGE.SET_TOKEN( 'COLUMN', 'status' );
       FND_MSG_PUB.ADD;
       x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    IF validate_lookup('REGISTRY_STATUS',p_status) = FALSE THEN
       arp_standard.debug('   status should be lookup code for the lookup type REGISTRY_STATUS');
       FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_INVALID_LOOKUP' );
       FND_MESSAGE.SET_TOKEN( 'COLUMN', 'status' );
       FND_MESSAGE.SET_TOKEN( 'LOOKUP_TYPE', 'REGISTRY_STATUS' );
       FND_MSG_PUB.ADD;
       x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
    arp_standard.debug('  Validate status -');


    -----------------------------
    -- Validate P_AGING_BUCKET_ID
    -----------------------------
    arp_standard.debug('  validate aging_bucket +');
    IF P_AGING_BUCKET_ID IS NULL OR P_AGING_BUCKET_ID = FND_API.G_MISS_NUM THEN
      NULL;
    ELSE
      OPEN c_aging_bucket;
      FETCH c_aging_bucket INTO l_c;
      IF c_aging_bucket%NOTFOUND THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_INVALID_FK');
        FND_MESSAGE.SET_TOKEN('FK', 'ar aging bucket id');
        FND_MESSAGE.SET_TOKEN('COLUMN', 'aging_bucket_id');
        FND_MESSAGE.SET_TOKEN('TABLE', 'ar_aging_bucket');
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
      CLOSE c_aging_bucket;
    END IF;
    arp_standard.debug('  validate aging_bucket -');


    ----------------------------------------------------
    -- Validate start_date and end_date
    ----------------------------------------------------
    arp_standard.debug('  validate start and end dates +');

    IF p_start_date IS NULL OR p_start_date = fnd_api.g_miss_date THEN
       arp_standard.debug('  validate start date is mandatory');
       FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
       FND_MESSAGE.SET_TOKEN( 'COLUMN', 'p_start_date' );
       FND_MSG_PUB.ADD;
       x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    l_val := compare(date1 => p_start_date,
                     date2 => p_end_date  );

    IF l_val = 1 THEN
       arp_standard.debug('  end date should be greater than the start date');
       fnd_message.set_name('AR', 'HZ_API_DATE_GREATER');
       fnd_message.set_token('DATE2', 'end_date');
       fnd_message.set_token('DATE1', 'start_date');
       fnd_msg_pub.add;
       x_return_status := fnd_api.g_ret_sts_error;
    END IF;


    IF x_return_status = fnd_api.g_ret_sts_success THEN
       arp_standard.debug('   Check overlappings of periods');
       OPEN c_overlapp;
       LOOP
         FETCH c_overlapp INTO l_start_date, l_end_date;
         EXIT WHEN c_overlapp%NOTFOUND;
         l_cpt  := l_cpt + 1;
         l_val := compare(p_start_date,l_end_date);
         IF l_val = 1 THEN
            arp_standard.debug('Entered start date :'|| p_start_date ||' greater than  existing end date :'||l_end_date);
         ELSE
            l_val := compare(l_start_date,p_end_date);
            IF l_val = 1 THEN
              arp_standard.debug('Existing start date :'|| l_start_date ||' greater than  existing entered end date :'||p_end_date);
            ELSE
               arp_standard.debug('    overlapping issue :');
               arp_standard.debug('      existing start :'||l_start_date|| ' end :'||l_end_date);
               arp_standard.debug('      entered  start :'||p_start_date|| ' end :'||p_end_date);
               fnd_message.set_name('AR', 'AR_DATE_OVERLAPP');
               fnd_message.set_token('START_DATE_PER_1', l_start_date);
               fnd_message.set_token('END_DATE_PER_1'  , l_end_date);
               fnd_message.set_token('START_DATE_PER_2', p_start_date);
               fnd_message.set_token('END_DATE_PER_2'  , p_end_date);
               fnd_msg_pub.add;
               x_return_status := fnd_api.g_ret_sts_error;
            END IF;
         END IF;
         IF x_return_status <> fnd_api.g_ret_sts_success THEN
            EXIT;
         END IF;
       END LOOP;
       CLOSE c_overlapp;
    END IF;
    arp_standard.debug('  validate start and end dates -');

  END IF;


  IF p_mode IN ('UPDATE') THEN
    -------------------------------------------------------------
    -- Validate STATUS lookup code in lookup type REGISTRY_STATUS
    -------------------------------------------------------------
    arp_standard.debug('  Validate status +');
    IF p_status = fnd_api.g_miss_char THEN
       FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
       FND_MESSAGE.SET_TOKEN( 'COLUMN', 'status' );
       FND_MSG_PUB.ADD;
       x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    IF p_status IS NOT NULL THEN
       IF validate_lookup('REGISTRY_STATUS',p_status) = FALSE THEN
         arp_standard.debug('   status should be lookup code for the lookup type REGISTRY_STATUS');
         FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_INVALID_LOOKUP' );
         FND_MESSAGE.SET_TOKEN( 'COLUMN', 'status' );
         FND_MESSAGE.SET_TOKEN( 'LOOKUP_TYPE', 'REGISTRY_STATUS' );
         FND_MSG_PUB.ADD;
         x_return_status := FND_API.G_RET_STS_ERROR;
       END IF;
    END IF;

    IF p_old_status = 'I' AND p_status = 'A' THEN
       arp_standard.debug('   Schedule Header can not be reactivated');
       FND_MESSAGE.SET_NAME( 'AR', 'AR_NO_REACTIVATE_ALLOW' );
       FND_MSG_PUB.ADD;
       x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    arp_standard.debug('  Validate status -');

    -----------------------------------
    -- Validate start_date and end_date
    -----------------------------------
    arp_standard.debug('  validate start and end dates +');
    IF p_end_date IS NOT NULL AND p_end_date <> FND_API.G_MISS_DATE THEN
     l_val := compare(date1 => p_start_date,
                      date2 => p_end_date  );
     IF l_val = 1 THEN
       arp_standard.debug('  end date should be greater than the start date');
       fnd_message.set_name('AR', 'HZ_API_DATE_GREATER');
       fnd_message.set_token('DATE2', 'end_date');
       fnd_message.set_token('DATE1', 'start_date');
       fnd_msg_pub.add;
       x_return_status := fnd_api.g_ret_sts_error;
     END IF;
     IF x_return_status = fnd_api.g_ret_sts_success THEN
       arp_standard.debug('   Check overlappings of periods');
       OPEN c_overlapp_upd;
       LOOP
         FETCH c_overlapp_upd INTO l_start_date, l_end_date;
         EXIT WHEN c_overlapp_upd%NOTFOUND;
         l_cpt := l_cpt + 1;
         l_val := compare(p_start_date,l_end_date);
         IF    l_val = 1 THEN
            NULL;  -- OK the existing period start after the entered period
         ELSE
            l_val := compare(l_start_date,p_end_date);
            IF l_val = 1 THEN
               NULL;  -- Ok the existing period ends before the entered period start
            ELSE
               arp_standard.debug('    overlapping issue :');
               arp_standard.debug('      existing start :'||l_start_date|| ' end :'||l_end_date);
               arp_standard.debug('      entered  start :'||p_start_date|| ' end :'||p_end_date);
               fnd_message.set_name('AR', 'AR_DATE_OVERLAPP');
               fnd_message.set_token('START_DATE_PER_1', l_start_date);
               fnd_message.set_token('END_DATE_PER_1'  , l_end_date);
               fnd_message.set_token('START_DATE_PER_2', p_start_date);
               fnd_message.set_token('END_DATE_PER_2'  , p_end_date);
               fnd_msg_pub.add;
               x_return_status := fnd_api.g_ret_sts_error;
            END IF;
         END IF;
         IF x_return_status <> fnd_api.g_ret_sts_success THEN
            EXIT;
         END IF;
       END LOOP;
       CLOSE c_overlapp_upd;
      END IF;
      arp_standard.debug('  validate start and end dates -');
    END IF;
  END IF;
  arp_standard.debug('validate_schedule_header -');
END;


PROCEDURE validate_schedule_line
(P_SCHEDULE_LINE_ID       IN NUMBER,
 P_SCHEDULE_HEADER_ID     IN NUMBER,
 P_SCHEDULE_ID            IN NUMBER,
 P_AGING_BUCKET_ID        IN NUMBER,
 P_AGING_BUCKET_LINE_ID   IN NUMBER,
 P_AMOUNT                 IN NUMBER,
 P_RATE                   IN NUMBER,
 P_MODE                   IN VARCHAR2,
 x_return_status          IN OUT NOCOPY VARCHAR2)
IS
 CURSOR c_header IS
 SELECT aging_bucket_id,
        schedule_id,
        schedule_header_id
   FROM ar_charge_schedule_hdrs
  WHERE schedule_header_id = p_schedule_header_id;

 l_rec                   c_header%ROWTYPE;

 CURSOR c_aging_bucket_id(p_aging_bucket_id      IN NUMBER,
                          p_aging_bucket_line_id IN NUMBER) IS
 SELECT NULL
   FROM ar_aging_buckets        a,
        ar_aging_bucket_lines_b b
  WHERE a.aging_bucket_id = p_aging_bucket_id
    AND a.status          = 'A'
    AND a.aging_bucket_id = b.aging_bucket_id
    AND b.aging_bucket_line_id = p_aging_bucket_line_id;

 CURSOR ar_schedule_line_u2(
  p_SCHEDULE_HEADER_ID      IN NUMBER,
  p_aging_bucket_id         IN NUMBER,
  p_aging_bucket_line_id    IN NUMBER)
 IS
 SELECT NULL
   FROM ar_charge_schedule_lines
  WHERE schedule_header_id      = p_SCHEDULE_HEADER_ID
    AND aging_bucket_id         = p_aging_bucket_id
    AND aging_bucket_line_id    = p_aging_bucket_line_id;

 CURSOR cl IS
 SELECT lookup_code
   FROM ar_charge_schedule_hdrs a,
        ar_lookups                  b
  WHERE a.schedule_header_id  = P_SCHEDULE_HEADER_ID
    AND b.lookup_type         = 'SCHEDULE_HEADER_TYPE'
    AND b.lookup_code         = a.schedule_header_type;

 l_c                     VARCHAR2(30);
BEGIN
  -------------------------------------
  -- Validate schedule_header_id
  -------------------------------------
  arp_standard.debug('  Validate schedule_header_id +');

  IF p_schedule_header_id IS NULL OR p_schedule_header_id = fnd_api.g_miss_num THEN
     FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
     FND_MESSAGE.SET_TOKEN( 'COLUMN', 'schedule_header_id' );
     FND_MSG_PUB.ADD;
     x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  OPEN c_header;
  FETCH c_header INTO l_rec;
  IF c_header%NOTFOUND THEN
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_INVALID_FK');
     FND_MESSAGE.SET_TOKEN('FK', 'schedule header');
     FND_MESSAGE.SET_TOKEN('COLUMN', 'schedule_header_id');
     FND_MESSAGE.SET_TOKEN('TABLE', 'ar_charge_schedule_hdrs');
     FND_MSG_PUB.ADD;
     x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;
  CLOSE c_header;
  arp_standard.debug('  Validate schedule_header_id -');


  ------------------------
  -- Validate schedule_id
  ------------------------
  arp_standard.debug('  Validate schedule_id +');
  IF p_schedule_id IS NULL OR p_schedule_id = fnd_api.g_miss_num THEN
     FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
     FND_MESSAGE.SET_TOKEN( 'COLUMN', 'schedule_id' );
     FND_MSG_PUB.ADD;
     x_return_status := FND_API.G_RET_STS_ERROR;
  ELSE
     IF p_schedule_id <> l_rec.schedule_id THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_INVALID_FK');
        FND_MESSAGE.SET_TOKEN('FK', 'schedule header');
        FND_MESSAGE.SET_TOKEN('COLUMN', 'schedule_id');
        FND_MESSAGE.SET_TOKEN('TABLE', 'ar_charge_schedule_hdrs');
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
     END IF;
  END IF;
  arp_standard.debug('  Validate schedule_id -');


  ---------------------------
  -- Validate aging_bucket_id
  ---------------------------
  arp_standard.debug('  Validate aging_bucket_id +');
  IF P_AGING_BUCKET_ID IS NULL OR P_AGING_BUCKET_ID = fnd_api.g_miss_num THEN
     FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
     FND_MESSAGE.SET_TOKEN( 'COLUMN', 'P_AGING_BUCKET_ID' );
     FND_MSG_PUB.ADD;
     x_return_status := FND_API.G_RET_STS_ERROR;
  ELSE
     IF P_AGING_BUCKET_ID <> l_rec.aging_bucket_id THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_INVALID_FK');
        FND_MESSAGE.SET_TOKEN('FK', 'schedule header');
        FND_MESSAGE.SET_TOKEN('COLUMN', 'aging_bucket_id');
        FND_MESSAGE.SET_TOKEN('TABLE', 'ar_charge_schedule_hdrs');
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
     END IF;
  END IF;
  arp_standard.debug('  Validate aging_bucket_id -');


  ----------------------------------------------------
  -- Unidicity of the combination schedule_header_id, aging_bucket, aging_bucket_line
  ----------------------------------------------------
  arp_standard.debug('  unidicity of ar_schedule_line_u2 +');
  OPEN ar_schedule_line_u2(
     p_SCHEDULE_HEADER_ID  ,
     p_aging_bucket_id     ,
     p_aging_bucket_line_id);
  FETCH ar_schedule_line_u2 INTO l_c;
  IF ar_schedule_line_u2%FOUND THEN
     arp_standard.debug('  A Record in ar_charge_schedule_lines exists with '||
       ' schedule_header_id - aging_bucket_id - aging_bucket_line_id');
     fnd_message.set_name('AR', 'AR_API_REC_COMB_EXISTS');
     fnd_message.set_token('COLUMN1', 'schedule_header_id');
     fnd_message.set_token('COLUMN2', 'aging_bucket_id');
     fnd_message.set_token('COLUMN3', 'aging_bucket_line_id');
     fnd_msg_pub.add;
     x_return_status := fnd_api.g_ret_sts_error;
  END IF;
  CLOSE ar_schedule_line_u2;
  arp_standard.debug('  unidicity of ar_schedule_line_u2 -');


  ---------------------------------
  -- Validate aging_bucket_line_id
  ---------------------------------
  arp_standard.debug('  Validate aging_bucket_id and aging_bucket_line_id +');
  IF p_aging_bucket_line_id IS NULL OR p_aging_bucket_line_id = fnd_api.g_miss_num
  THEN
    IF p_aging_bucket_line_id IS NULL or p_aging_bucket_line_id = fnd_api.g_miss_num THEN
       arp_standard.debug('   AGING_BUCKET_LINE_ID missing');
       FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
       FND_MESSAGE.SET_TOKEN( 'COLUMN', 'AGING_BUCKET_LINE_ID' );
       FND_MSG_PUB.ADD;
       x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
  ELSE
    IF p_aging_bucket_id IS NOT NULL AND p_aging_bucket_id <> FND_API.G_MISS_NUM THEN
      OPEN c_aging_bucket_id(p_aging_bucket_id, p_aging_bucket_line_id);
      FETCH c_aging_bucket_id INTO l_c;
      IF c_aging_bucket_id%NOTFOUND THEN
         arp_standard.debug('   AGING_BUCKET_ID/AGING_BUCKET_LINE_ID are not valid');
         FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_INVALID_FK' );
         FND_MESSAGE.SET_TOKEN( 'FK', 'aging_bucket_id' );
         FND_MESSAGE.SET_TOKEN( 'COLUMN', 'aging_bucket_id' );
         FND_MESSAGE.SET_TOKEN( 'TABLE', 'ar_aging_buckets');
         FND_MSG_PUB.ADD;
         FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_INVALID_FK' );
         FND_MESSAGE.SET_TOKEN( 'FK', 'aging_bucket_line_id' );
         FND_MESSAGE.SET_TOKEN( 'COLUMN', 'aging_bucket_line_id' );
         FND_MESSAGE.SET_TOKEN( 'TABLE', 'ar_aging_bucket_lines_b');
         FND_MSG_PUB.ADD;
         x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
      CLOSE c_aging_bucket_id;
    END IF;
  END IF;
  arp_standard.debug('  Validate aging_bucket_line_id -');



  --------------------------
  -- Validate amount or rate
  --------------------------
  arp_standard.debug('  validate amount or rate +');

  OPEN cl;
  FETCH cl INTO l_c;
  CLOSE cl;

  IF (p_amount IS NULL OR p_amount = FND_API.G_MISS_NUM) AND
     (l_c = 'AMOUNT')
  THEN
     arp_standard.debug('   The amount column is mandatory for SCHEDULE_HEADER_TYPE :'||l_c);
     fnd_message.set_name('AR', 'HZ_API_MISSING_COLUMN');
     fnd_message.set_token('COLUMN', 'AMOUNT');
     FND_MSG_PUB.ADD;
     x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  IF (p_rate  IS NULL OR p_rate = FND_API.G_MISS_NUM) AND
     (l_c = 'PERCENTAGE')
  THEN
     arp_standard.debug('   The rate column is mandatory for SCHEDULE_HEADER_TYPE:'||l_c);
     fnd_message.set_name('AR', 'HZ_API_MISSING_COLUMN');
     fnd_message.set_token('COLUMN', 'RATE');
     fnd_msg_pub.add;
     FND_MSG_PUB.ADD;
     x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;
  arp_standard.debug('  validate amount or rate -');
END;





PROCEDURE create_schedule
(p_init_msg_list         IN  VARCHAR2 := fnd_api.g_false,
 P_SCHEDULE_NAME         IN  VARCHAR2,
 P_SCHEDULE_DESCRIPTION  IN  VARCHAR2,
 P_ATTRIBUTE_CATEGORY    IN  VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE1            IN  VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE2            IN  VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE3            IN  VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE4            IN  VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE5            IN  VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE6            IN  VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE7            IN  VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE8            IN  VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE9            IN  VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE10           IN  VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE11           IN  VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE12           IN  VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE13           IN  VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE14           IN  VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE15           IN  VARCHAR2 DEFAULT NULL,
 P_OBJECT_VERSION_NUMBER IN  NUMBER   DEFAULT 1,
 x_schedule_id           OUT NOCOPY NUMBER,
 x_return_status         OUT NOCOPY VARCHAR2,
 x_msg_count             OUT NOCOPY NUMBER,
 x_msg_data              OUT NOCOPY VARCHAR2)
IS
  CURSOR cu_schedule_id IS
  SELECT ar_charge_schedules_s.nextval
    FROM DUAL;
  l_schedule_id           NUMBER;
  l_n                     VARCHAR2(10);
BEGIN
  l_n         := 0;
  arp_standard.debug('create_schedule +');
  arp_standard.debug('   P_SCHEDULE_NAME           :'||P_SCHEDULE_NAME);
  arp_standard.debug('   P_SCHEDULE_DESCRIPTION    :'||P_SCHEDULE_DESCRIPTION);

  SAVEPOINT  create_schedule;

  x_return_status := fnd_api.G_RET_STS_SUCCESS;

  IF fnd_api.to_boolean(p_init_msg_list) THEN
    fnd_msg_pub.initialize;
  END IF;

  l_n := 1;

  validate_schedule
  (P_SCHEDULE_NAME         => p_schedule_name,
   p_schedule_description  => P_SCHEDULE_DESCRIPTION,
   p_mode                  => 'INSERT',
   x_return_status         => x_return_status);


  IF x_return_status <> fnd_api.G_RET_STS_SUCCESS THEN
    RAISE fnd_api.G_EXC_ERROR;
  END IF;

  l_n := 2;
  OPEN cu_schedule_id;
  FETCH cu_schedule_id INTO l_schedule_id;
  CLOSE cu_schedule_id;

  l_n := 3;
  Insert_schedule_Row
  (P_SCHEDULE_ID         => l_schedule_id,
   P_SCHEDULE_NAME       => P_SCHEDULE_NAME,
   P_SCHEDULE_DESCRIPTION=> P_SCHEDULE_DESCRIPTION,
   P_ATTRIBUTE_CATEGORY  => P_ATTRIBUTE_CATEGORY,
   P_ATTRIBUTE1          => P_ATTRIBUTE1,
   P_ATTRIBUTE2          => P_ATTRIBUTE2,
   P_ATTRIBUTE3          => P_ATTRIBUTE3,
   P_ATTRIBUTE4          => P_ATTRIBUTE4,
   P_ATTRIBUTE5          => P_ATTRIBUTE5,
   P_ATTRIBUTE6          => P_ATTRIBUTE6,
   P_ATTRIBUTE7          => P_ATTRIBUTE7,
   P_ATTRIBUTE8          => P_ATTRIBUTE8,
   P_ATTRIBUTE9          => P_ATTRIBUTE9,
   P_ATTRIBUTE10         => P_ATTRIBUTE10,
   P_ATTRIBUTE11         => P_ATTRIBUTE11,
   P_ATTRIBUTE12         => P_ATTRIBUTE12,
   P_ATTRIBUTE13         => P_ATTRIBUTE13,
   P_ATTRIBUTE14         => P_ATTRIBUTE14,
   P_ATTRIBUTE15         => P_ATTRIBUTE15,
   P_OBJECT_VERSION_NUMBER => P_OBJECT_VERSION_NUMBER,
   x_return_status       => x_return_status);

  l_n := 4;
  IF x_return_status <> fnd_api.G_RET_STS_SUCCESS THEN
    RAISE fnd_api.G_EXC_ERROR;
  END IF;

  x_schedule_id             := l_schedule_id;

  arp_standard.debug('create_schedule -');

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO create_schedule;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);
     arp_standard.debug('EXCEPTION create_schedule:'||x_msg_data);

   WHEN OTHERS THEN
     ROLLBACK TO create_schedule;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR' ,l_n||' '||SQLERRM);
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);
     arp_standard.debug('EXCEPTION create_schedule:'||x_msg_data);
END;


PROCEDURE update_schedule
(p_init_msg_list         IN  VARCHAR2 := fnd_api.g_false,
 P_SCHEDULE_ID           IN  NUMBER,
 P_SCHEDULE_DESCRIPTION  IN  VARCHAR2,
 P_ATTRIBUTE_CATEGORY    IN  VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE1            IN  VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE2            IN  VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE3            IN  VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE4            IN  VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE5            IN  VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE6            IN  VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE7            IN  VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE8            IN  VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE9            IN  VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE10           IN  VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE11           IN  VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE12           IN  VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE13           IN  VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE14           IN  VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE15           IN  VARCHAR2 DEFAULT NULL,
 X_OBJECT_VERSION_NUMBER IN  OUT NOCOPY NUMBER,
 x_return_status         OUT NOCOPY VARCHAR2,
 x_msg_count             OUT NOCOPY NUMBER,
 x_msg_data              OUT NOCOPY VARCHAR2)
IS
  CURSOR c IS
  SELECT SCHEDULE_ID        ,
         SCHEDULE_NAME      ,
         SCHEDULE_DESCRIPTION,
         ATTRIBUTE_CATEGORY ,
         ATTRIBUTE1         ,
         ATTRIBUTE2         ,
         ATTRIBUTE3         ,
         ATTRIBUTE4         ,
         ATTRIBUTE5         ,
         ATTRIBUTE6         ,
         ATTRIBUTE7         ,
         ATTRIBUTE8         ,
         ATTRIBUTE9         ,
         ATTRIBUTE10        ,
         ATTRIBUTE11        ,
         ATTRIBUTE12        ,
         ATTRIBUTE13        ,
         ATTRIBUTE14        ,
         ATTRIBUTE15        ,
         OBJECT_VERSION_NUMBER
    FROM ar_charge_schedules
   WHERE schedule_id = P_SCHEDULE_ID
   FOR UPDATE NOWAIT;
   l_rec  c%ROWTYPE;
BEGIN
  arp_standard.debug('update_schedule +');
  arp_standard.debug('   P_SCHEDULE_ID             :'||P_SCHEDULE_ID);
  arp_standard.debug('   P_SCHEDULE_DESCRIPTION    :'||P_SCHEDULE_DESCRIPTION);

  SAVEPOINT  update_schedule;

  IF fnd_api.to_boolean(p_init_msg_list) THEN
    fnd_msg_pub.initialize;
  END IF;

  x_return_status          := fnd_api.G_RET_STS_SUCCESS;

  OPEN c;
  FETCH c INTO
         l_rec.SCHEDULE_ID        ,
         l_rec.SCHEDULE_NAME      ,
         l_rec.SCHEDULE_DESCRIPTION,
         l_rec.ATTRIBUTE_CATEGORY ,
         l_rec.ATTRIBUTE1         ,
         l_rec.ATTRIBUTE2         ,
         l_rec.ATTRIBUTE3         ,
         l_rec.ATTRIBUTE4         ,
         l_rec.ATTRIBUTE5         ,
         l_rec.ATTRIBUTE6         ,
         l_rec.ATTRIBUTE7         ,
         l_rec.ATTRIBUTE8         ,
         l_rec.ATTRIBUTE9         ,
         l_rec.ATTRIBUTE10        ,
         l_rec.ATTRIBUTE11        ,
         l_rec.ATTRIBUTE12        ,
         l_rec.ATTRIBUTE13        ,
         l_rec.ATTRIBUTE14        ,
         l_rec.ATTRIBUTE15        ,
         l_rec.OBJECT_VERSION_NUMBER;
   CLOSE c;

   IF l_rec.SCHEDULE_ID IS NULL THEN
        fnd_message.set_name('AR', 'HZ_API_NO_RECORD');
        fnd_message.set_token('RECORD', 'ar_charge_schedules');
        fnd_message.set_token('VALUE',
          NVL(TO_CHAR(P_SCHEDULE_ID), 'null'));
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
      fnd_message.set_token('TABLE', 'ar_charge_schedules');
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_error;
   END IF;


  validate_schedule
  (P_SCHEDULE_NAME         => l_rec.SCHEDULE_NAME,
   p_schedule_description  => P_SCHEDULE_DESCRIPTION,
   p_mode                  => 'UPDATE',
   x_return_status         => x_return_status);

  IF x_return_status <> fnd_api.G_RET_STS_SUCCESS THEN
    RAISE fnd_api.G_EXC_ERROR;
  END IF;

  Update_schedule_row
    (P_SCHEDULE_ID          => P_SCHEDULE_ID,
     P_SCHEDULE_DESCRIPTION => P_SCHEDULE_DESCRIPTION,
     P_ATTRIBUTE_CATEGORY   => P_ATTRIBUTE_CATEGORY,
     P_ATTRIBUTE1           => P_ATTRIBUTE1,
     P_ATTRIBUTE2           => P_ATTRIBUTE2,
     P_ATTRIBUTE3           => p_attribute3,
     P_ATTRIBUTE4           => p_attribute4,
     P_ATTRIBUTE5           => p_attribute5,
     P_ATTRIBUTE6           => p_attribute6,
     P_ATTRIBUTE7           => p_attribute7,
     P_ATTRIBUTE8           => p_attribute8,
     P_ATTRIBUTE9           => p_attribute9,
     P_ATTRIBUTE10          => p_attribute10,
     P_ATTRIBUTE11          => p_attribute11,
     P_ATTRIBUTE12          => p_attribute12,
     P_ATTRIBUTE13          => p_attribute13,
     P_ATTRIBUTE14          => p_attribute14,
     P_ATTRIBUTE15          => p_attribute15,
     X_OBJECT_VERSION_NUMBER=> X_OBJECT_VERSION_NUMBER,
     x_return_status        => x_return_status);

   IF x_return_status <> fnd_api.G_RET_STS_SUCCESS THEN
        RAISE fnd_api.g_exc_error;
   END IF;

  arp_standard.debug('Update_schedule -');

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Update_schedule;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);
     arp_standard.debug('EXCEPTION Update_schedule:'||x_msg_data);

   WHEN OTHERS THEN
     ROLLBACK TO Update_schedule;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);
     arp_standard.debug('EXCEPTION Update_schedule:'||x_msg_data);
END;





PROCEDURE create_schedule_header
(p_init_msg_list         IN  VARCHAR2 := fnd_api.g_false,
 P_SCHEDULE_ID           IN  NUMBER,
 P_SCHEDULE_HEADER_TYPE  IN  VARCHAR2,
 P_AGING_BUCKET_ID       IN  NUMBER,
 P_START_DATE            IN  DATE,
 P_END_DATE              IN  DATE,
 P_STATUS                IN  VARCHAR2,
 P_ATTRIBUTE_CATEGORY    IN  VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE1            IN  VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE2            IN  VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE3            IN  VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE4            IN  VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE5            IN  VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE6            IN  VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE7            IN  VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE8            IN  VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE9            IN  VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE10           IN  VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE11           IN  VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE12           IN  VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE13           IN  VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE14           IN  VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE15           IN  VARCHAR2 DEFAULT NULL,
 P_OBJECT_VERSION_NUMBER IN  NUMBER   DEFAULT 1,
 x_schedule_header_id    OUT NOCOPY NUMBER,
 x_return_status         OUT NOCOPY VARCHAR2,
 x_msg_count             OUT NOCOPY NUMBER,
 x_msg_data              OUT NOCOPY VARCHAR2)
IS
  CURSOR cu_header_id IS
  SELECT ar_charge_schedule_hdrs_s.nextval
    FROM DUAL;
  l_header_id           NUMBER;
BEGIN
  arp_standard.debug('create_schedule_header +');
  arp_standard.debug('   P_SCHEDULE_HEADER_TYPE    :'||P_SCHEDULE_HEADER_TYPE);
  arp_standard.debug('   P_AGING_BUCKET_ID         :'||P_AGING_BUCKET_ID);
  arp_standard.debug('   p_start_date              :'||p_start_date);
  arp_standard.debug('   p_end_date                :'||p_end_date);

  savepoint create_schedule_header;

  x_return_status := fnd_api.G_RET_STS_SUCCESS;

  IF fnd_api.to_boolean(p_init_msg_list) THEN
    fnd_msg_pub.initialize;
  END IF;


  validate_schedule_header
  (P_SCHEDULE_HEADER_ID     => l_header_id,
   P_SCHEDULE_ID            => p_schedule_id,
   P_SCHEDULE_HEADER_TYPE   => P_SCHEDULE_HEADER_TYPE,
   P_AGING_BUCKET_ID        => P_AGING_BUCKET_ID,
   P_START_DATE             => p_start_date,
   P_END_DATE               => p_end_date,
   p_status                 => p_status,
   p_old_status             => NULL,
   p_mode                   => 'INSERT',
   x_return_status          => x_return_status);


  IF x_return_status <> fnd_api.G_RET_STS_SUCCESS THEN
    RAISE fnd_api.G_EXC_ERROR;
  END IF;

  OPEN cu_header_id;
  FETCH cu_header_id INTO l_header_id;
  CLOSE cu_header_id;

  Insert_Head_Row
  (P_SCHEDULE_HEADER_ID  => l_header_id,
   P_SCHEDULE_ID         => p_schedule_id,
   P_SCHEDULE_HEADER_TYPE => P_SCHEDULE_HEADER_TYPE,
   P_AGING_BUCKET_ID     => P_AGING_BUCKET_ID,
   P_START_DATE          => p_start_date,
   P_END_DATE            => p_end_date,
   P_STATUS              => P_STATUS,
   P_ATTRIBUTE_CATEGORY  => P_ATTRIBUTE_CATEGORY,
   P_ATTRIBUTE1          => P_ATTRIBUTE1,
   P_ATTRIBUTE2          => P_ATTRIBUTE2,
   P_ATTRIBUTE3          => P_ATTRIBUTE3,
   P_ATTRIBUTE4          => P_ATTRIBUTE4,
   P_ATTRIBUTE5          => P_ATTRIBUTE5,
   P_ATTRIBUTE6          => P_ATTRIBUTE6,
   P_ATTRIBUTE7          => P_ATTRIBUTE7,
   P_ATTRIBUTE8          => P_ATTRIBUTE8,
   P_ATTRIBUTE9          => P_ATTRIBUTE9,
   P_ATTRIBUTE10         => P_ATTRIBUTE10,
   P_ATTRIBUTE11         => P_ATTRIBUTE11,
   P_ATTRIBUTE12         => P_ATTRIBUTE12,
   P_ATTRIBUTE13         => P_ATTRIBUTE13,
   P_ATTRIBUTE14         => P_ATTRIBUTE14,
   P_ATTRIBUTE15         => P_ATTRIBUTE15,
   P_OBJECT_VERSION_NUMBER => P_OBJECT_VERSION_NUMBER,
   x_return_status       => x_return_status);


  IF x_return_status <> fnd_api.G_RET_STS_SUCCESS THEN
    RAISE fnd_api.G_EXC_ERROR;
  END IF;

  x_SCHEDULE_HEADER_ID       := l_header_id;

  arp_standard.debug('create_schedule_header -');

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO create_schedule_header;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);
     arp_standard.debug('EXCEPTION create_schedule_header:'||x_msg_data);

   WHEN OTHERS THEN
     ROLLBACK TO create_schedule_header;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);
     arp_standard.debug('EXCEPTION create_schedule_header:'||x_msg_data);
END;


PROCEDURE Update_schedule_header
(p_init_msg_list          IN VARCHAR2 := fnd_api.g_false,
 P_SCHEDULE_HEADER_ID     IN NUMBER,
 P_END_DATE               IN DATE,
 P_STATUS                 IN VARCHAR2,
 P_ATTRIBUTE_CATEGORY     IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE1             IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE2             IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE3             IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE4             IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE5             IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE6             IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE7             IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE8             IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE9             IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE10            IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE11            IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE12            IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE13            IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE14            IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE15            IN VARCHAR2 DEFAULT NULL,
 X_OBJECT_VERSION_NUMBER  IN OUT NOCOPY NUMBER,
 x_return_status          OUT NOCOPY VARCHAR2,
 x_msg_count              OUT NOCOPY NUMBER,
 x_msg_data               OUT NOCOPY VARCHAR2)
IS
  CURSOR c IS
  SELECT SCHEDULE_ID        ,
         SCHEDULE_HEADER_ID ,
         SCHEDULE_HEADER_TYPE,
         AGING_BUCKET_ID    ,
         START_DATE         ,
         END_DATE           ,
         ATTRIBUTE_CATEGORY ,
         ATTRIBUTE1         ,
         ATTRIBUTE2         ,
         ATTRIBUTE3         ,
         ATTRIBUTE4         ,
         ATTRIBUTE5         ,
         ATTRIBUTE6         ,
         ATTRIBUTE7         ,
         ATTRIBUTE8         ,
         ATTRIBUTE9         ,
         ATTRIBUTE10        ,
         ATTRIBUTE11        ,
         ATTRIBUTE12        ,
         ATTRIBUTE13        ,
         ATTRIBUTE14        ,
         ATTRIBUTE15        ,
         OBJECT_VERSION_NUMBER,
         STATUS
    FROM ar_charge_schedule_hdrs
   WHERE schedule_header_id = P_SCHEDULE_HEADER_ID
   FOR UPDATE NOWAIT;

  l_rec             c%ROWTYPE;
BEGIN
  arp_standard.debug('Update_schedule_header +');
  arp_standard.debug('   P_SCHEDULE_HEADER_ID      :'||P_SCHEDULE_HEADER_ID);
  arp_standard.debug('   p_end_date                :'||p_end_date);
  arp_standard.debug('   X_OBJECT_VERSION_NUMBER   :'||X_OBJECT_VERSION_NUMBER);

  savepoint Update_schedule_header;

  IF fnd_api.to_boolean(p_init_msg_list) THEN
    fnd_msg_pub.initialize;
  END IF;

  x_return_status          := fnd_api.G_RET_STS_SUCCESS;

  OPEN c;
  FETCH c INTO
         l_rec.SCHEDULE_ID        ,
         l_rec.SCHEDULE_HEADER_ID ,
         l_rec.SCHEDULE_HEADER_TYPE,
         l_rec.AGING_BUCKET_ID    ,
         l_rec.START_DATE         ,
         l_rec.END_DATE           ,
         l_rec.ATTRIBUTE_CATEGORY ,
         l_rec.ATTRIBUTE1         ,
         l_rec.ATTRIBUTE2         ,
         l_rec.ATTRIBUTE3         ,
         l_rec.ATTRIBUTE4         ,
         l_rec.ATTRIBUTE5         ,
         l_rec.ATTRIBUTE6         ,
         l_rec.ATTRIBUTE7         ,
         l_rec.ATTRIBUTE8         ,
         l_rec.ATTRIBUTE9         ,
         l_rec.ATTRIBUTE10        ,
         l_rec.ATTRIBUTE11        ,
         l_rec.ATTRIBUTE12        ,
         l_rec.ATTRIBUTE13        ,
         l_rec.ATTRIBUTE14        ,
         l_rec.ATTRIBUTE15        ,
         l_rec.OBJECT_VERSION_NUMBER,
         l_rec.status;
   CLOSE c;

   IF l_rec.SCHEDULE_HEADER_ID IS NULL THEN
        fnd_message.set_name('AR', 'HZ_API_NO_RECORD');
        fnd_message.set_token('RECORD', 'ar_charge_schedule_hdrs');
        fnd_message.set_token('VALUE',
          NVL(TO_CHAR(P_SCHEDULE_HEADER_ID), 'null'));
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
      fnd_message.set_token('TABLE', 'ar_charge_schedule_hdrs');
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_error;
   END IF;


   validate_schedule_header
   (P_SCHEDULE_HEADER_ID     => l_rec.SCHEDULE_HEADER_ID,
    P_SCHEDULE_ID            => l_rec.SCHEDULE_ID,
    P_SCHEDULE_HEADER_TYPE   => l_rec.SCHEDULE_HEADER_TYPE,
    P_AGING_BUCKET_ID        => l_rec.AGING_BUCKET_ID,
    P_START_DATE             => l_rec.START_DATE,
    P_END_DATE               => P_END_DATE,
    P_STATUS                 => p_status,
    P_OLD_STATUS             => l_rec.status,
    p_mode                   => 'UPDATE',
    x_return_status          => x_return_status);


   IF x_return_status <> fnd_api.G_RET_STS_SUCCESS THEN
        RAISE fnd_api.g_exc_error;
   END IF;

   Update_Head_Row
    (P_SCHEDULE_HEADER_ID   => l_rec.SCHEDULE_HEADER_ID,
     P_END_DATE             => p_end_date,
     P_STATUS               => P_STATUS,
     P_ATTRIBUTE_CATEGORY   => P_ATTRIBUTE_CATEGORY,
     P_ATTRIBUTE1           => P_ATTRIBUTE1,
     P_ATTRIBUTE2           => P_ATTRIBUTE2,
     P_ATTRIBUTE3           => p_attribute3,
     P_ATTRIBUTE4           => p_attribute4,
     P_ATTRIBUTE5           => p_attribute5,
     P_ATTRIBUTE6           => p_attribute6,
     P_ATTRIBUTE7           => p_attribute7,
     P_ATTRIBUTE8           => p_attribute8,
     P_ATTRIBUTE9           => p_attribute9,
     P_ATTRIBUTE10          => p_attribute10,
     P_ATTRIBUTE11          => p_attribute11,
     P_ATTRIBUTE12          => p_attribute12,
     P_ATTRIBUTE13          => p_attribute13,
     P_ATTRIBUTE14          => p_attribute14,
     P_ATTRIBUTE15          => p_attribute15,
     X_OBJECT_VERSION_NUMBER=> X_OBJECT_VERSION_NUMBER,
     x_return_status        => x_return_status);

   IF x_return_status <> fnd_api.G_RET_STS_SUCCESS THEN
        RAISE fnd_api.g_exc_error;
   END IF;

  arp_standard.debug('Update_schedule_header -');

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Update_schedule_header;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);
     arp_standard.debug('EXCEPTION Update_schedule_header:'||x_msg_data);

   WHEN OTHERS THEN
     ROLLBACK TO Update_schedule_header;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);
     arp_standard.debug('EXCEPTION Update_schedule_header:'||x_msg_data);
END;



PROCEDURE create_schedule_line
(p_init_msg_list          IN VARCHAR2 := fnd_api.g_false,
 P_SCHEDULE_HEADER_ID     IN NUMBER,
 P_SCHEDULE_ID            IN NUMBER,
 P_AGING_BUCKET_ID        IN NUMBER,
 P_AGING_BUCKET_LINE_ID   IN NUMBER,
 P_AMOUNT                 IN NUMBER,
 P_RATE                   IN NUMBER,
 P_ATTRIBUTE_CATEGORY     IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE1             IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE2             IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE3             IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE4             IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE5             IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE6             IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE7             IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE8             IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE9             IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE10            IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE11            IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE12            IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE13            IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE14            IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE15            IN VARCHAR2 DEFAULT NULL,
 P_OBJECT_VERSION_NUMBER  IN  NUMBER   DEFAULT 1,
 X_SCHEDULE_LINE_ID       OUT NOCOPY NUMBER,
 x_return_status          OUT NOCOPY VARCHAR2,
 x_msg_count              OUT NOCOPY NUMBER,
 x_msg_data               OUT NOCOPY VARCHAR2)
IS
  CURSOR cu_line_id IS
  SELECT ar_charge_schedule_lines_s.NEXTVAL
    FROM dual;
  l_line_id                NUMBER;
BEGIN
  arp_standard.debug('create_schedule_line +');
  arp_standard.debug('   P_SCHEDULE_HEADER_ID     :'||P_SCHEDULE_HEADER_ID);
  arp_standard.debug('   P_SCHEDULE_ID            :'||P_SCHEDULE_ID);
  arp_standard.debug('   P_AGING_BUCKET_ID        :'||P_AGING_BUCKET_ID);
  arp_standard.debug('   P_AGING_BUCKET_LINE_ID   :'||P_AGING_BUCKET_LINE_ID);
  arp_standard.debug('   P_AMOUNT                 :'||P_amount);
  arp_standard.debug('   P_RATE                   :'||P_RATE);

  SAVEPOINT create_schedule_line;

  x_return_status := fnd_api.G_RET_STS_SUCCESS;

  IF fnd_api.to_boolean(p_init_msg_list) THEN
    fnd_msg_pub.initialize;
  END IF;

  validate_schedule_line
  (P_SCHEDULE_LINE_ID       => l_line_id,
   P_SCHEDULE_HEADER_ID     => P_SCHEDULE_HEADER_ID,
   P_SCHEDULE_ID            => P_SCHEDULE_ID,
   P_AGING_BUCKET_ID        => P_AGING_BUCKET_ID,
   P_AGING_BUCKET_LINE_ID   => P_AGING_BUCKET_LINE_ID,
   P_AMOUNT                 => p_amount,
   P_RATE                   => p_rate,
   P_MODE                   => 'INSERT',
   x_return_status          => x_return_status);


  IF x_return_status <> fnd_api.G_RET_STS_SUCCESS THEN
    RAISE fnd_api.G_EXC_ERROR;
  END IF;

  OPEN cu_line_id;
  FETCH cu_line_id INTO l_line_id;
  CLOSE cu_line_id;


  Insert_Line_Row
   (P_SCHEDULE_LINE_ID       => l_line_id,
    P_SCHEDULE_HEADER_ID     => P_SCHEDULE_HEADER_ID,
    P_SCHEDULE_ID            => P_SCHEDULE_ID,
    P_AGING_BUCKET_ID        => P_AGING_BUCKET_ID,
    P_AGING_BUCKET_LINE_ID   => P_AGING_BUCKET_LINE_ID,
    P_AMOUNT                 => P_AMOUNT,
    P_RATE                   => P_RATE,
    P_ATTRIBUTE_CATEGORY     => P_ATTRIBUTE_CATEGORY,
    P_ATTRIBUTE1             => P_ATTRIBUTE1,
    P_ATTRIBUTE2             => P_ATTRIBUTE2,
    P_ATTRIBUTE3             => P_ATTRIBUTE3,
    P_ATTRIBUTE4             => P_ATTRIBUTE4,
    P_ATTRIBUTE5             => P_ATTRIBUTE5,
    P_ATTRIBUTE6             => P_ATTRIBUTE6,
    P_ATTRIBUTE7             => P_ATTRIBUTE7,
    P_ATTRIBUTE8             => P_ATTRIBUTE8,
    P_ATTRIBUTE9             => P_ATTRIBUTE9,
    P_ATTRIBUTE10            => P_ATTRIBUTE10,
    P_ATTRIBUTE11            => P_ATTRIBUTE11,
    P_ATTRIBUTE12            => P_ATTRIBUTE12,
    P_ATTRIBUTE13            => P_ATTRIBUTE13,
    P_ATTRIBUTE14            => P_ATTRIBUTE14,
    P_ATTRIBUTE15            => P_ATTRIBUTE15,
    P_OBJECT_VERSION_NUMBER  => P_OBJECT_VERSION_NUMBER,
    x_return_status          => x_return_status);

   IF x_return_status <> fnd_api.G_RET_STS_SUCCESS THEN
        RAISE fnd_api.g_exc_error;
   END IF;

   X_SCHEDULE_LINE_ID  := l_line_id;

  arp_standard.debug('create_schedule_line -');

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO create_schedule_line;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);
     arp_standard.debug('EXCEPTION create_schedule_line :'||x_msg_data);

   WHEN OTHERS THEN
     ROLLBACK TO create_schedule_line;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);
     arp_standard.debug('EXCEPTION create_schedule_line :'||x_msg_data);
END;

PROCEDURE Update_schedule_line
(p_init_msg_list          IN VARCHAR2 := fnd_api.g_false,
 P_SCHEDULE_line_ID       IN NUMBER,
 P_amount                 IN NUMBER,
 P_rate                   IN NUMBER,
 P_ATTRIBUTE_CATEGORY     IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE1             IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE2             IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE3             IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE4             IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE5             IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE6             IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE7             IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE8             IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE9             IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE10            IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE11            IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE12            IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE13            IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE14            IN VARCHAR2 DEFAULT NULL,
 P_ATTRIBUTE15            IN VARCHAR2 DEFAULT NULL,
 X_OBJECT_VERSION_NUMBER  IN OUT NOCOPY NUMBER,
 x_return_status          OUT NOCOPY VARCHAR2,
 x_msg_count              OUT NOCOPY NUMBER,
 x_msg_data               OUT NOCOPY VARCHAR2)
IS
  CURSOR c IS
  SELECT SCHEDULE_ID        ,
         SCHEDULE_HEADER_ID ,
         schedule_line_id   ,
         amount       ,
         rate         ,
         ATTRIBUTE_CATEGORY ,
         ATTRIBUTE1         ,
         ATTRIBUTE2         ,
         ATTRIBUTE3         ,
         ATTRIBUTE4         ,
         ATTRIBUTE5         ,
         ATTRIBUTE6         ,
         ATTRIBUTE7         ,
         ATTRIBUTE8         ,
         ATTRIBUTE9         ,
         ATTRIBUTE10        ,
         ATTRIBUTE11        ,
         ATTRIBUTE12        ,
         ATTRIBUTE13        ,
         ATTRIBUTE14        ,
         ATTRIBUTE15        ,
         OBJECT_VERSION_NUMBER
    FROM ar_charge_schedule_lines
   WHERE schedule_line_id = P_SCHEDULE_LINE_ID
   FOR UPDATE NOWAIT;

  l_rec             c%ROWTYPE;
BEGIN
  arp_standard.debug('Update_schedule_line +');
  arp_standard.debug('   P_SCHEDULE_line_ID      :'||P_SCHEDULE_line_ID);
  arp_standard.debug('   p_amount                :'||p_amount);
  arp_standard.debug('   p_rate                  :'||p_rate);
  arp_standard.debug('   X_OBJECT_VERSION_NUMBER :'||X_OBJECT_VERSION_NUMBER);

  savepoint Update_schedule_line;

  IF fnd_api.to_boolean(p_init_msg_list) THEN
    fnd_msg_pub.initialize;
  END IF;

  x_return_status          := fnd_api.G_RET_STS_SUCCESS;

  OPEN c;
  FETCH c INTO
         l_rec.SCHEDULE_ID        ,
         l_rec.SCHEDULE_HEADER_ID ,
         l_rec.schedule_line_id   ,
         l_rec.amount       ,
         l_rec.rate         ,
         l_rec.ATTRIBUTE_CATEGORY ,
         l_rec.ATTRIBUTE1         ,
         l_rec.ATTRIBUTE2         ,
         l_rec.ATTRIBUTE3         ,
         l_rec.ATTRIBUTE4         ,
         l_rec.ATTRIBUTE5         ,
         l_rec.ATTRIBUTE6         ,
         l_rec.ATTRIBUTE7         ,
         l_rec.ATTRIBUTE8         ,
         l_rec.ATTRIBUTE9         ,
         l_rec.ATTRIBUTE10        ,
         l_rec.ATTRIBUTE11        ,
         l_rec.ATTRIBUTE12        ,
         l_rec.ATTRIBUTE13        ,
         l_rec.ATTRIBUTE14        ,
         l_rec.ATTRIBUTE15        ,
         l_rec.OBJECT_VERSION_NUMBER;
   CLOSE c;

   IF l_rec.SCHEDULE_line_ID IS NULL THEN
        fnd_message.set_name('AR', 'HZ_API_NO_RECORD');
        fnd_message.set_token('RECORD', 'ar_charge_schedule_lines');
        fnd_message.set_token('VALUE',
          NVL(TO_CHAR(P_SCHEDULE_line_ID), 'null'));
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
      fnd_message.set_token('TABLE', 'ar_charge_schedule_lines');
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_error;
   END IF;

/* This would be the place to call validate_line
 validate_schedule_line
  (P_SCHEDULE_LINE_ID       => l_line_id,
   P_SCHEDULE_HEADER_ID     => P_SCHEDULE_HEADER_ID,
   P_SCHEDULE_ID            => P_SCHEDULE_ID,
   P_AGING_BUCKET_ID        => P_AGING_BUCKET_ID,
   P_AGING_BUCKET_LINE_ID   => P_AGING_BUCKET_LINE_ID,
   P_AMOUNT                 => p_amount,
   P_RATE                   => p_rate,
   P_MODE                   => 'UPDATE',
   x_return_status          => x_return_status);

   IF x_return_status <> fnd_api.G_RET_STS_SUCCESS THEN
        RAISE fnd_api.g_exc_error;
   END IF;
*/

   Update_line_Row
    (P_SCHEDULE_line_ID   => l_rec.SCHEDULE_line_ID,
     P_amount             => p_amount,
     P_rate               => P_rate,
     P_ATTRIBUTE_CATEGORY   => P_ATTRIBUTE_CATEGORY,
     P_ATTRIBUTE1           => P_ATTRIBUTE1,
     P_ATTRIBUTE2           => P_ATTRIBUTE2,
     P_ATTRIBUTE3           => p_attribute3,
     P_ATTRIBUTE4           => p_attribute4,
     P_ATTRIBUTE5           => p_attribute5,
     P_ATTRIBUTE6           => p_attribute6,
     P_ATTRIBUTE7           => p_attribute7,
     P_ATTRIBUTE8           => p_attribute8,
     P_ATTRIBUTE9           => p_attribute9,
     P_ATTRIBUTE10          => p_attribute10,
     P_ATTRIBUTE11          => p_attribute11,
     P_ATTRIBUTE12          => p_attribute12,
     P_ATTRIBUTE13          => p_attribute13,
     P_ATTRIBUTE14          => p_attribute14,
     P_ATTRIBUTE15          => p_attribute15,
     X_OBJECT_VERSION_NUMBER=> X_OBJECT_VERSION_NUMBER,
     x_return_status        => x_return_status);

   IF x_return_status <> fnd_api.G_RET_STS_SUCCESS THEN
        RAISE fnd_api.g_exc_error;
   END IF;

  arp_standard.debug('Update_schedule_line -');

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Update_schedule_line;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);
     arp_standard.debug('EXCEPTION Update_schedule_line:'||x_msg_data);

   WHEN OTHERS THEN
     ROLLBACK TO Update_schedule_header;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);
     arp_standard.debug('EXCEPTION Update_schedule_line:'||x_msg_data);
END;


END;

/
