--------------------------------------------------------
--  DDL for Package Body AMS_DM_PERFORMANCE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_DM_PERFORMANCE_PKG" as
/* $Header: amstdpfb.pls 120.1 2005/06/15 23:58:08 appldev  $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_DM_PERFORMANCE_PKG
-- Purpose
--
-- History
-- 26-Jan-2001 choang   Removed object ver num from update criteria.
-- 07-Jan-2002 choang   Removed security group id
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_DM_PERFORMANCE_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amstdpfb.pls';

AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Insert_Row(
          px_performance_id   IN OUT NOCOPY NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_predicted_value    VARCHAR2,
          p_actual_value    VARCHAR2,
          p_evaluated_records    NUMBER,
          p_total_records_predicted    NUMBER,
          p_model_id    NUMBER)
IS
   x_rowid    VARCHAR2(30);
BEGIN
   px_object_version_number := 1;


   INSERT INTO AMS_DM_PERFORMANCE(
           performance_id,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           last_update_login,
           object_version_number,
           predicted_value,
           actual_value,
           evaluated_records,
           total_records_predicted,
           model_id
   ) VALUES (
           DECODE( px_performance_id, FND_API.g_miss_num, NULL, px_performance_id),
           DECODE( p_last_update_date, FND_API.g_miss_date, SYSDATE, p_last_update_date),
           DECODE( p_last_updated_by, FND_API.g_miss_num, FND_GLOBAL.user_id, p_last_updated_by),
           DECODE( p_creation_date, FND_API.g_miss_date, SYSDATE, p_creation_date),
           DECODE( p_created_by, FND_API.g_miss_num, FND_GLOBAL.user_id, p_created_by),
           DECODE( p_last_update_login, FND_API.g_miss_num, FND_GLOBAL.conc_login_id, p_last_update_login),
           DECODE( px_object_version_number, FND_API.g_miss_num, 1, px_object_version_number),
           DECODE( p_predicted_value, FND_API.g_miss_char, NULL, p_predicted_value),
           DECODE( p_actual_value, FND_API.g_miss_char, NULL, p_actual_value),
           DECODE( p_evaluated_records, FND_API.g_miss_num, NULL, p_evaluated_records),
           DECODE( p_total_records_predicted, FND_API.g_miss_num, NULL, p_total_records_predicted),
           DECODE( p_model_id, FND_API.g_miss_num, NULL, p_model_id));
END Insert_Row;

PROCEDURE Update_Row(
          p_performance_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_predicted_value    VARCHAR2,
          p_actual_value    VARCHAR2,
          p_evaluated_records    NUMBER,
          p_total_records_predicted    NUMBER,
          p_model_id    NUMBER)

 IS
BEGIN
    Update AMS_DM_PERFORMANCE
    SET
              performance_id = DECODE( p_performance_id, FND_API.g_miss_num, performance_id, p_performance_id),
              last_update_date = DECODE( p_last_update_date, FND_API.g_miss_date, last_update_date, p_last_update_date),
              last_updated_by = DECODE( p_last_updated_by, FND_API.g_miss_num, last_updated_by, p_last_updated_by),
              last_update_login = DECODE( p_last_update_login, FND_API.g_miss_num, last_update_login, p_last_update_login),
              object_version_number = DECODE( p_object_version_number, FND_API.g_miss_num, object_version_number, p_object_version_number),
              predicted_value = DECODE( p_predicted_value, FND_API.g_miss_char, predicted_value, p_predicted_value),
              actual_value = DECODE( p_actual_value, FND_API.g_miss_char, actual_value, p_actual_value),
              evaluated_records = DECODE( p_evaluated_records, FND_API.g_miss_num, evaluated_records, p_evaluated_records),
              total_records_predicted = DECODE( p_total_records_predicted, FND_API.g_miss_num, total_records_predicted, p_total_records_predicted),
              model_id = DECODE( p_model_id, FND_API.g_miss_num, model_id, p_model_id)
   WHERE PERFORMANCE_ID = p_PERFORMANCE_ID;

   IF (SQL%NOTFOUND) THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
END Update_Row;

PROCEDURE Delete_Row(
    p_PERFORMANCE_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM AMS_DM_PERFORMANCE
    WHERE PERFORMANCE_ID = p_PERFORMANCE_ID;
   If (SQL%NOTFOUND) then
RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   End If;
 END Delete_Row ;


PROCEDURE Lock_Row(
          p_performance_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_predicted_value    VARCHAR2,
          p_actual_value    VARCHAR2,
          p_evaluated_records    NUMBER,
          p_total_records_predicted    NUMBER,
          p_model_id    NUMBER)

 IS
   CURSOR C IS
        SELECT *
         FROM AMS_DM_PERFORMANCE
        WHERE PERFORMANCE_ID =  p_PERFORMANCE_ID
        FOR UPDATE of PERFORMANCE_ID NOWAIT;
   Recinfo C%ROWTYPE;
 BEGIN
    OPEN c;
    FETCH c INTO Recinfo;
    If (c%NOTFOUND) then
        CLOSE c;
        FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
        APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
    CLOSE C;
    IF (
           (      Recinfo.performance_id = p_performance_id)
       AND (    ( Recinfo.last_update_date = p_last_update_date)
            OR (    ( Recinfo.last_update_date IS NULL )
                AND (  p_last_update_date IS NULL )))
       AND (    ( Recinfo.last_updated_by = p_last_updated_by)
            OR (    ( Recinfo.last_updated_by IS NULL )
                AND (  p_last_updated_by IS NULL )))
       AND (    ( Recinfo.creation_date = p_creation_date)
            OR (    ( Recinfo.creation_date IS NULL )
                AND (  p_creation_date IS NULL )))
       AND (    ( Recinfo.created_by = p_created_by)
            OR (    ( Recinfo.created_by IS NULL )
                AND (  p_created_by IS NULL )))
       AND (    ( Recinfo.last_update_login = p_last_update_login)
            OR (    ( Recinfo.last_update_login IS NULL )
                AND (  p_last_update_login IS NULL )))
       AND (    ( Recinfo.object_version_number = p_object_version_number)
            OR (    ( Recinfo.object_version_number IS NULL )
                AND (  p_object_version_number IS NULL )))
       AND (    ( Recinfo.predicted_value = p_predicted_value)
            OR (    ( Recinfo.predicted_value IS NULL )
                AND (  p_predicted_value IS NULL )))
       AND (    ( Recinfo.actual_value = p_actual_value)
            OR (    ( Recinfo.actual_value IS NULL )
                AND (  p_actual_value IS NULL )))
       AND (    ( Recinfo.evaluated_records = p_evaluated_records)
            OR (    ( Recinfo.evaluated_records IS NULL )
                AND (  p_evaluated_records IS NULL )))
       AND (    ( Recinfo.total_records_predicted = p_total_records_predicted)
            OR (    ( Recinfo.total_records_predicted IS NULL )
                AND (  p_total_records_predicted IS NULL )))
       AND (    ( Recinfo.model_id = p_model_id)
            OR (    ( Recinfo.model_id IS NULL )
                AND (  p_model_id IS NULL )))
       ) THEN
       RETURN;
   ELSE
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   END IF;
END Lock_Row;

END AMS_DM_PERFORMANCE_PKG;

/
