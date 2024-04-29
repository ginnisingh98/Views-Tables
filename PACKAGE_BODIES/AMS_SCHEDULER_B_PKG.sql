--------------------------------------------------------
--  DDL for Package Body AMS_SCHEDULER_B_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_SCHEDULER_B_PKG" as
/* $Header: amstrptb.pls 120.0 2005/07/01 03:51:43 appldev noship $ */

-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_SCHEDULER_B_PKG
--
-- Purpose
--          Private api created to Update/insert/Delete the repeating schedule details.
--
-- History
--    05-may-2005    anchaudh    Created.
--
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_SCHEDULER_B_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amstrptb.pls';



--  ========================================================
--
--  NAME
--     Insert_Row
--
--  HISTORY
--     05-may-2005    anchaudh    Created.
--  ========================================================
PROCEDURE Insert_Row(
          px_scheduler_id   IN OUT NOCOPY NUMBER,
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_object_type    VARCHAR2,
          p_object_id    NUMBER,
          p_frequency    NUMBER,
          p_frequency_type    VARCHAR2)

 IS

   l_last_update_date DATE;


BEGIN


   px_object_version_number := 1;
   AMS_UTILITY_PVT.debug_message('ANIRBAN table handler '||p_last_update_date);

   l_last_update_date := p_last_update_date;
   IF p_last_update_date IS NULL
   THEN l_last_update_date := sysdate;
   END IF;

   AMS_UTILITY_PVT.debug_message('ANIRBAN table handler '||l_last_update_date);

   INSERT INTO AMS_SCHEDULER(
           scheduler_id,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login,
           object_version_number,
           object_type,
           object_id,
           frequency,
           frequency_type
           ) VALUES (
           DECODE( px_scheduler_id, FND_API.g_miss_num, NULL, px_scheduler_id)
           , DECODE( p_created_by, FND_API.g_miss_num, 1, p_created_by)
           , DECODE( p_creation_date, FND_API.g_miss_date, sysdate, p_creation_date)
           , DECODE( p_last_updated_by, FND_API.g_miss_num, 1, p_last_updated_by)
           , DECODE( p_last_update_date, FND_API.g_miss_date, sysdate, l_last_update_date)
           , DECODE( p_last_update_login, FND_API.g_miss_num, 1, p_last_update_login)
           , DECODE( px_object_version_number, FND_API.g_miss_num, NULL, px_object_version_number)
           , DECODE( p_object_type, FND_API.g_miss_char, NULL, p_object_type)
           , DECODE( p_object_id, FND_API.g_miss_num, NULL, p_object_id)
           , DECODE( p_frequency, FND_API.g_miss_num, NULL, p_frequency)
           , DECODE( p_frequency_type, FND_API.g_miss_char, NULL, p_frequency_type)
           );



END Insert_Row;


--  ========================================================
--
--  NAME
--     Update_Row
--
--  HISTORY
--    05-may-2005    anchaudh    Created.
--  ========================================================


PROCEDURE Update_Row(
          p_scheduler_id  NUMBER,
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER,
          p_object_version_number  NUMBER,
          p_object_type    VARCHAR2,
          p_object_id    NUMBER,
          p_frequency    NUMBER,
          p_frequency_type    VARCHAR2)
 IS
 BEGIN
    Update AMS_SCHEDULER
    SET
              scheduler_id = DECODE( p_scheduler_id, FND_API.g_miss_num, scheduler_id, p_scheduler_id),
              created_by = DECODE( p_created_by, FND_API.g_miss_num, created_by, p_created_by),
              creation_date = DECODE( p_creation_date, FND_API.g_miss_date, creation_date, p_creation_date),
              last_updated_by = DECODE( p_last_updated_by, FND_API.g_miss_num, last_updated_by, p_last_updated_by),
              last_update_date = DECODE( p_last_update_date, FND_API.g_miss_date, last_update_date, p_last_update_date),
              last_update_login = DECODE( p_last_update_login, FND_API.g_miss_num, last_update_login, p_last_update_login),
              object_version_number = DECODE( p_object_version_number, FND_API.g_miss_num, object_version_number, p_object_version_number),
              object_type = DECODE( p_object_type, FND_API.g_miss_char, object_type, p_object_type),
              object_id = DECODE( p_object_id, FND_API.g_miss_num, object_id, p_object_id),
              frequency = DECODE( p_frequency, FND_API.g_miss_num, frequency, p_frequency),
              frequency_type = DECODE( p_frequency_type, FND_API.g_miss_char, frequency_type, p_frequency_type)
   WHERE scheduler_id = p_scheduler_id
   AND   object_version_number = p_object_version_number;



END Update_Row;


--  ========================================================
--
--  NAME
--     Delete_Row
--
--  HISTORY
--    05-may-2005    anchaudh    Created.
--  ========================================================


PROCEDURE Delete_Row(
    p_scheduler_id  NUMBER)

 IS
 BEGIN
   DELETE FROM AMS_SCHEDULER
    WHERE SCHEDULER_ID = p_scheduler_id;
   If (SQL%NOTFOUND) then
 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

 END Delete_Row ;



--  ========================================================
--
--  NAME
--     Lock_Row
--
--  HISTORY
--     05-may-2005    anchaudh    Created.
--  ========================================================


PROCEDURE Lock_Row(
          p_scheduler_id  NUMBER)

 IS
   CURSOR C IS
        SELECT *
         FROM AMS_SCHEDULER
        WHERE SCHEDULER_ID =  p_scheduler_id
        FOR UPDATE of SCHEDULER_ID NOWAIT;
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

END Lock_Row;


END AMS_SCHEDULER_B_PKG;

/
