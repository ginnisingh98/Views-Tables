--------------------------------------------------------
--  DDL for Package Body OZF_TIME_ALLOCATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_TIME_ALLOCATIONS_PKG" AS
/* $Header: ozfttalb.pls 120.2 2005/08/04 04:49:55 appldev ship $  */

---g_version	CONSTANT CHAR(80)    := '$Header: ozfttalb.pls 120.2 2005/08/04 04:49:55 appldev ship $';
   G_PKG_NAME   CONSTANT VARCHAR2(30):='OZF_TIME_ALLOCATIONS_PKG';
   G_FILE_NAME CONSTANT VARCHAR2(12) := 'ozfttalb.pls';

   OZF_DEBUG_HIGH_ON CONSTANT BOOLEAN   := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);
   OZF_DEBUG_MEDIUM_ON CONSTANT BOOLEAN := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);
   OZF_DEBUG_LOW_ON CONSTANT BOOLEAN    := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low);


--  ========================================================
--
--  NAME
--  Insert_Row
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Insert_Row(
          px_time_allocation_id    IN OUT NOCOPY NUMBER,
          p_allocation_for                       VARCHAR2,
          p_allocation_for_id                    NUMBER,
          p_time_id                              NUMBER,
          p_period_type_id                       NUMBER,
          p_target                               NUMBER,
          p_lysp_sales                           NUMBER,
          px_object_version_number IN OUT NOCOPY NUMBER,
          p_creation_date                        DATE,
          p_created_by                           NUMBER,
          p_last_update_date                     DATE,
          p_last_updated_by                      NUMBER,
          p_last_update_login                    NUMBER,
          p_attribute_category                   VARCHAR2,
          p_attribute1                           VARCHAR2,
          p_attribute2                           VARCHAR2,
          p_attribute3                           VARCHAR2,
          p_attribute4                           VARCHAR2,
          p_attribute5                           VARCHAR2,
          p_attribute6                           VARCHAR2,
          p_attribute7                           VARCHAR2,
          p_attribute8                           VARCHAR2,
          p_attribute9                           VARCHAR2,
          p_attribute10                          VARCHAR2,
          p_attribute11                          VARCHAR2,
          p_attribute12                          VARCHAR2,
          p_attribute13                          VARCHAR2,
          p_attribute14                          VARCHAR2,
          p_attribute15                          VARCHAR2,
          px_org_id                IN OUT NOCOPY NUMBER
          )
 IS
   x_rowid    VARCHAR2(30);


BEGIN

  -- R12 Enhancements
  -- Fix for bug 4534945
  /* IF (px_org_id IS NULL OR px_org_id = FND_API.G_MISS_NUM) THEN
       SELECT NVL(TO_NUMBER(SUBSTRB(USERENV('CLIENT_INFO'),1,10)),-99)
       INTO px_org_id
       FROM DUAL;
   END IF;
   */
   px_object_version_number := nvl(px_object_version_number, 1);


   INSERT INTO ozf_time_allocations(
           time_allocation_id,
           allocation_for,
           allocation_for_id,
           time_id,
           period_type_id,
           target,
           lysp_sales,
           object_version_number,
           creation_date,
           created_by,
           last_update_date,
           last_updated_by,
           last_update_login,
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
           org_id)
    VALUES
         (
           DECODE( px_time_allocation_id, FND_API.G_MISS_NUM, NULL, px_time_allocation_id),
           DECODE( p_allocation_for, FND_API.g_miss_char, NULL, p_allocation_for),
           DECODE( p_allocation_for_id, FND_API.G_MISS_NUM, NULL, p_allocation_for_id),
           DECODE( p_time_id, FND_API.G_MISS_NUM, NULL, p_time_id),
           DECODE( p_period_type_id, FND_API.G_MISS_NUM, NULL, p_period_type_id),
           DECODE( p_target, FND_API.G_MISS_NUM, NULL, p_target),
           DECODE( p_lysp_sales, FND_API.G_MISS_NUM, NULL, p_lysp_sales),
           px_object_version_number,
           DECODE( p_creation_date, to_date(NULL), SYSDATE, p_creation_date),
           DECODE( p_created_by, null, FND_GLOBAL.USER_ID, p_created_by),
           DECODE( p_last_update_date, to_date(NULL), SYSDATE, p_last_update_date),
           DECODE( p_last_updated_by, null, FND_GLOBAL.USER_ID, p_last_updated_by),
           DECODE( p_last_update_login, null, FND_GLOBAL.CONC_LOGIN_ID, p_last_update_login),
           DECODE( p_attribute_category, FND_API.g_miss_char, NULL, p_attribute_category),
           DECODE( p_attribute1, FND_API.g_miss_char, NULL, p_attribute1),
           DECODE( p_attribute2, FND_API.g_miss_char, NULL, p_attribute2),
           DECODE( p_attribute3, FND_API.g_miss_char, NULL, p_attribute3),
           DECODE( p_attribute4, FND_API.g_miss_char, NULL, p_attribute4),
           DECODE( p_attribute5, FND_API.g_miss_char, NULL, p_attribute5),
           DECODE( p_attribute6, FND_API.g_miss_char, NULL, p_attribute6),
           DECODE( p_attribute7, FND_API.g_miss_char, NULL, p_attribute7),
           DECODE( p_attribute8, FND_API.g_miss_char, NULL, p_attribute8),
           DECODE( p_attribute9, FND_API.g_miss_char, NULL, p_attribute9),
           DECODE( p_attribute10, FND_API.g_miss_char, NULL, p_attribute10),
           DECODE( p_attribute11, FND_API.g_miss_char, NULL, p_attribute11),
           DECODE( p_attribute12, FND_API.g_miss_char, NULL, p_attribute12),
           DECODE( p_attribute13, FND_API.g_miss_char, NULL, p_attribute13),
           DECODE( p_attribute14, FND_API.g_miss_char, NULL, p_attribute14),
           DECODE( p_attribute15, FND_API.g_miss_char, NULL, p_attribute15),
           px_org_id
         );

END Insert_Row;




--  ========================================================
--
--  NAME
--  Update_Row
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Update_Row(
          p_time_allocation_id         NUMBER,
          p_allocation_for             VARCHAR2,
          p_allocation_for_id          NUMBER,
          p_time_id                    NUMBER,
          p_period_type_id             NUMBER,
          p_target                     NUMBER,
          p_lysp_sales                 NUMBER,
          p_object_version_number   IN NUMBER,
          p_last_update_date           DATE,
          p_last_updated_by            NUMBER,
          p_last_update_login          NUMBER,
          p_attribute_category         VARCHAR2,
          p_attribute1                 VARCHAR2,
          p_attribute2                 VARCHAR2,
          p_attribute3                 VARCHAR2,
          p_attribute4                 VARCHAR2,
          p_attribute5                 VARCHAR2,
          p_attribute6                 VARCHAR2,
          p_attribute7                 VARCHAR2,
          p_attribute8                 VARCHAR2,
          p_attribute9                 VARCHAR2,
          p_attribute10                VARCHAR2,
          p_attribute11                VARCHAR2,
          p_attribute12                VARCHAR2,
          p_attribute13                VARCHAR2,
          p_attribute14                VARCHAR2,
          p_attribute15                VARCHAR2
          )
 IS
 BEGIN
    Update ozf_time_allocations
    SET
              allocation_for = DECODE( p_allocation_for, null, allocation_for, FND_API.g_miss_char, null, p_allocation_for),
              allocation_for_id = DECODE( p_allocation_for_id, null, allocation_for_id, FND_API.G_MISS_NUM, null, p_allocation_for_id),
              time_id = DECODE( p_time_id, null, time_id, FND_API.G_MISS_NUM, null, p_time_id),
              period_type_id = DECODE( p_period_type_id, null, period_type_id, FND_API.G_MISS_NUM, null, p_period_type_id),
              target = DECODE( p_target, null, target, FND_API.G_MISS_NUM, null, p_target),
              lysp_sales = DECODE( p_lysp_sales, null, lysp_sales, FND_API.G_MISS_NUM, null, p_lysp_sales),
              object_version_number = nvl(p_object_version_number, object_version_number) + 1 ,
              last_update_date = DECODE( p_last_update_date, to_date(NULL), SYSDATE, p_last_update_date),
              last_updated_by = DECODE( p_last_updated_by, null, FND_GLOBAL.USER_ID, p_last_updated_by),
              last_update_login = DECODE( p_last_update_login, null, FND_GLOBAL.CONC_LOGIN_ID, p_last_update_login),
              attribute_category = DECODE( p_attribute_category, null, attribute_category, FND_API.g_miss_char, null, p_attribute_category),
              attribute1 = DECODE( p_attribute1, null, attribute1, FND_API.g_miss_char, null, p_attribute1),
              attribute2 = DECODE( p_attribute2, null, attribute2, FND_API.g_miss_char, null, p_attribute2),
              attribute3 = DECODE( p_attribute3, null, attribute3, FND_API.g_miss_char, null, p_attribute3),
              attribute4 = DECODE( p_attribute4, null, attribute4, FND_API.g_miss_char, null, p_attribute4),
              attribute5 = DECODE( p_attribute5, null, attribute5, FND_API.g_miss_char, null, p_attribute5),
              attribute6 = DECODE( p_attribute6, null, attribute6, FND_API.g_miss_char, null, p_attribute6),
              attribute7 = DECODE( p_attribute7, null, attribute7, FND_API.g_miss_char, null, p_attribute7),
              attribute8 = DECODE( p_attribute8, null, attribute8, FND_API.g_miss_char, null, p_attribute8),
              attribute9 = DECODE( p_attribute9, null, attribute9, FND_API.g_miss_char, null, p_attribute9),
              attribute10 = DECODE( p_attribute10, null, attribute10, FND_API.g_miss_char, null, p_attribute10),
              attribute11 = DECODE( p_attribute11, null, attribute11, FND_API.g_miss_char, null, p_attribute11),
              attribute12 = DECODE( p_attribute12, null, attribute12, FND_API.g_miss_char, null, p_attribute12),
              attribute13 = DECODE( p_attribute13, null, attribute13, FND_API.g_miss_char, null, p_attribute13),
              attribute14 = DECODE( p_attribute14, null, attribute14, FND_API.g_miss_char, null, p_attribute14),
              attribute15 = DECODE( p_attribute15, null, attribute15, FND_API.g_miss_char, null, p_attribute15)
   WHERE time_allocation_id = p_time_allocation_id;
   -- AND   object_version_number = p_object_version_number;


   IF (SQL%NOTFOUND) THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;


END Update_Row;




--  ========================================================
--
--  NAME
--  Delete_Row
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Delete_Row(
    p_time_allocation_id  NUMBER,
    p_object_version_number  NUMBER)
 IS
 BEGIN
   DELETE FROM ozf_time_allocations
    WHERE time_allocation_id = p_time_allocation_id
    AND object_version_number = p_object_version_number;
   If (SQL%NOTFOUND) then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   End If;
 END Delete_Row ;





--  ========================================================
--
--  NAME
--  Lock_Row
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Lock_Row(
    p_time_allocation_id  NUMBER,
    p_object_version_number  NUMBER)
 IS
   CURSOR C IS
        SELECT *
         FROM ozf_time_allocations
        WHERE time_allocation_id =  p_time_allocation_id
        AND object_version_number = p_object_version_number
        FOR UPDATE OF time_allocation_id NOWAIT;
   Recinfo C%ROWTYPE;
 BEGIN

   OPEN c;
   FETCH c INTO Recinfo;
   IF (c%NOTFOUND) THEN
      CLOSE c;
      AMS_Utility_PVT.error_message ('AMS_API_RECORD_NOT_FOUND');
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c;
END Lock_Row;



END OZF_Time_Allocations_PKG;

/
