--------------------------------------------------------
--  DDL for Package Body AMS_DM_TARGET_SOURCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_DM_TARGET_SOURCES_PKG" as
/* $Header: amstdtsb.pls 115.6 2003/12/24 22:51:00 choang noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_Dm_Target_Sources_PKG
-- Purpose
--
-- History
-- 17-Dec-2003 choang   bug 3316903: fixed load_row logic
-- 24-Dec-2003 choang   bug 3338413: fixed load_row logic for call to insert_row
--
-- NOTE
--
-- This Api is generated with Latest version of
-- Rosetta, where g_miss indicates NULL and
-- NULL indicates missing value. Rosetta Version 1.55
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_Dm_Target_Sources_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amstdtsb.pls';




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
          px_target_source_id   IN OUT NOCOPY NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_target_id    NUMBER,
          p_data_source_id    NUMBER)

 IS
   x_rowid    VARCHAR2(30);


BEGIN


   px_object_version_number := nvl(px_object_version_number, 1);


   INSERT INTO ams_dm_target_sources(
           target_source_id,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           last_update_login,
           object_version_number,
           target_id,
           data_source_id
   ) VALUES (
           DECODE( px_target_source_id, FND_API.G_MISS_NUM, NULL, px_target_source_id),
           DECODE( p_last_update_date, FND_API.G_MISS_DATE, SYSDATE, p_last_update_date),
           DECODE( p_last_updated_by, FND_API.G_MISS_NUM, FND_GLOBAL.USER_ID, p_last_updated_by),
           DECODE( p_creation_date, FND_API.G_MISS_DATE, SYSDATE, p_creation_date),
           DECODE( p_created_by, FND_API.G_MISS_NUM, FND_GLOBAL.USER_ID, p_created_by),
           DECODE( p_last_update_login, FND_API.G_MISS_NUM, FND_GLOBAL.CONC_LOGIN_ID, p_last_update_login),
           DECODE( px_object_version_number, FND_API.G_MISS_NUM, 1, px_object_version_number),
           DECODE( p_target_id, FND_API.G_MISS_NUM, NULL, p_target_id),
           DECODE( p_data_source_id, FND_API.G_MISS_NUM, NULL, p_data_source_id));

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
--  15-Dec-2003  choang   changed obj version num to update without increment
--
--  ========================================================
PROCEDURE Update_Row(
          p_target_source_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number   IN NUMBER,
          p_target_id    NUMBER,
          p_data_source_id    NUMBER)

 IS
 BEGIN
    Update ams_dm_target_sources
    SET
              target_source_id = DECODE( p_target_source_id, null, target_source_id, FND_API.G_MISS_NUM, null, p_target_source_id),
              last_update_date = DECODE( p_last_update_date, null, last_update_date, FND_API.G_MISS_DATE, null, p_last_update_date),
              last_updated_by = DECODE( p_last_updated_by, null, last_updated_by, FND_API.G_MISS_NUM, null, p_last_updated_by),
              last_update_login = DECODE( p_last_update_login, null, last_update_login, FND_API.G_MISS_NUM, null, p_last_update_login),
            object_version_number = p_object_version_number,
              target_id = DECODE( p_target_id, null, target_id, FND_API.G_MISS_NUM, null, p_target_id),
              data_source_id = DECODE( p_data_source_id, null, data_source_id, FND_API.G_MISS_NUM, null, p_data_source_id)
   WHERE target_source_id = p_target_source_id;


   IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
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
    p_target_source_id  NUMBER,
    p_object_version_number  NUMBER)
 IS
 BEGIN
   DELETE FROM ams_dm_target_sources
    WHERE target_source_id = p_target_source_id
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
    p_target_source_id  NUMBER,
    p_object_version_number  NUMBER)
 IS
   CURSOR C IS
        SELECT *
         FROM ams_dm_target_sources
        WHERE target_source_id =  p_target_source_id
        AND object_version_number = p_object_version_number
        FOR UPDATE OF target_source_id NOWAIT;
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


PROCEDURE load_row(
   x_target_source_id   IN NUMBER,
   x_target_id          IN NUMBER,
   x_data_source_id     IN NUMBER,
   x_owner              IN VARCHAR2,
   x_custom_mode        IN VARCHAR2
)
IS
   l_user_id         number := 0;
   l_db_luby_id      number;
   l_obj_verno       number;
   l_target_source_id number := x_target_source_id;

   cursor c_chk_target_source_exists is
     select last_updated_by, nvl(object_version_number, 1)
     from   ams_dm_target_sources
     where  target_source_id = x_target_source_id;

   cursor c_get_target_source_id is
      select ams_dm_target_sources_s.nextval
      from dual;

BEGIN

  -- set the last_updated_by to be used while updating the data in customer data.
   if X_OWNER = 'SEED' then
      l_user_id := 1;
   elsif X_OWNER = 'ORACLE' THEN
      l_user_id := 2;
   elsif X_OWNER = 'SYSADMIN' THEN
      l_user_id := 0;
   end if ;

   -- choang - 17-Dec-2003 - Fixed bug 3316903: added close to "found"
   --          condition and modified if/else logic
   open c_chk_target_source_exists;
   fetch c_chk_target_source_exists into l_db_luby_id, l_obj_verno;
   if c_chk_target_source_exists%notfound THEN
      if x_target_source_id is null then
         open c_get_target_source_id;
         fetch c_get_target_source_id into l_target_source_id;
         close c_get_target_source_id;
      end if;

      l_obj_verno := 1;

      -- choang - 24-Dec-2003 - fixed 3338413: changed parameter for
      --          target_source_id
      AMS_Dm_Target_Sources_PKG.Insert_Row(
          px_target_source_id        => l_target_source_id,
          p_last_update_date         => SYSDATE,
          p_last_updated_by          => l_user_id,
          p_creation_date            => SYSDATE,
          p_created_by               => l_user_id,
          p_last_update_login        => 0,
          px_object_version_number   => l_obj_verno,
          p_target_id      =>  x_target_id,
          p_data_source_id  =>  x_data_source_id
      );

   else
      l_target_source_id := x_target_source_id;

      if ( l_db_luby_id IN (1, 2, 0) OR NVL(x_custom_mode,'PRESERVE') = 'FORCE') THEN
         AMS_Dm_Target_Sources_PKG.Update_Row(
            p_target_source_id         => l_target_source_id,
            p_last_update_date         => SYSDATE,
            p_last_updated_by          => l_user_id,
            p_last_update_login        => 0,
            p_object_version_number   => l_obj_verno,
            p_target_id      =>  x_target_id,
            p_data_source_id  =>  x_data_source_id
	 );
      end if;
   end if;
   close c_chk_target_source_exists;
END load_row;

END AMS_Dm_Target_Sources_PKG;

/
