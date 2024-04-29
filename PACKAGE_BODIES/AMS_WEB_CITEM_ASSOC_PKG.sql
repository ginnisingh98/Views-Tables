--------------------------------------------------------
--  DDL for Package Body AMS_WEB_CITEM_ASSOC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_WEB_CITEM_ASSOC_PKG" as
/* $Header: amstwmpb.pls 120.0 2005/07/01 03:56:14 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--        AMS_WEB_CITEM_ASSOC_PKG
-- Purpose
--		Table api to insert/update/delete WebPlanner Citems Associations..
-- History
--      10-May-2005    sikalyan     Created.
-- NOTE
--
-- End of Comments
-- ===============================================================

G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_WEB_CITEM_ASSOC_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amstwmpb.pls';

--  ========================================================
--
--  NAME
--  		createInsertBody
--  PURPOSE
--		 Table Api to insert WebPlanner Citems Associations
--  NOTES
--
--  HISTORY
--
--  ========================================================
AMS_DEBUG_HIGH_ON constant boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON constant boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON constant boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Insert_Row(
          px_placement_citem_id   IN OUT NOCOPY NUMBER,
          p_placement_mp_id    NUMBER,
          p_content_item_id    NUMBER,
          p_citem_version_id    NUMBER,
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_return_status          OUT NOCOPY VARCHAR2,
          p_msg_count             OUT  NOCOPY  NUMBER,
          p_msg_data                OUT  NOCOPY  VARCHAR2
          )

IS
   x_rowid    VARCHAR2(30);

BEGIN


   px_object_version_number := 1;


   INSERT INTO ams_web_plce_citem_assoc(
          placement_citem_id,
          placement_mp_id,
          content_item_id,
          citem_version_id,
          created_by,
          creation_date,
          last_updated_by,
          last_update_date,
          last_update_login,
          object_version_number
   ) VALUES (
           DECODE( px_placement_citem_id, FND_API.g_miss_num, NULL, px_placement_citem_id),
           DECODE( p_placement_mp_id, FND_API.g_miss_num, NULL, p_placement_mp_id),
           DECODE( p_content_item_id, FND_API.g_miss_num, NULL, p_content_item_id),
           DECODE( p_citem_version_id, FND_API.g_miss_num, NULL, p_citem_version_id),
           DECODE( p_created_by, FND_API.g_miss_num, NULL, p_created_by),
           DECODE( p_creation_date, FND_API.g_miss_date, NULL, p_creation_date),
           DECODE( p_last_updated_by, FND_API.g_miss_num, NULL, p_last_updated_by),
           DECODE( p_last_update_date, FND_API.g_miss_date, NULL, p_last_update_date),
           DECODE( p_last_update_login, FND_API.g_miss_num, NULL, p_last_update_login),
           DECODE( px_object_version_number, FND_API.g_miss_num, NULL, px_object_version_number));


END Insert_Row;


--  ========================================================
--
--  NAME
--  		createUpdateBody
--  PURPOSE
--		Table api to WebPlanner Citems Associations.
--  NOTES
--
--  HISTORY
--
--  ========================================================

PROCEDURE  Update_Row(
          p_placement_citem_id  NUMBER,
          p_placement_mp_id    NUMBER,
          p_content_item_id    NUMBER,
          p_citem_version_id    NUMBER,
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by   NUMBER,
          p_last_update_date  DATE,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER
	  )
	IS
	BEGIN

	   IF (AMS_DEBUG_HIGH_ON) THEN
	      AMS_UTILITY_PVT.debug_message('table handler : before update p_placement_citem_id =' || p_placement_citem_id );
	   END IF;


	    UPDATE ams_web_plce_citem_assoc
	    SET
              last_update_date = DECODE( p_last_update_date, FND_API.g_miss_date, last_update_date, p_last_update_date),
              last_updated_by = DECODE( p_last_updated_by, FND_API.g_miss_num, last_updated_by, p_last_updated_by),
              last_update_login = DECODE( p_last_update_login, FND_API.g_miss_num, last_update_login, p_last_update_login),
	      placement_mp_id = DECODE( p_placement_mp_id, FND_API.g_miss_num, NULL, p_placement_mp_id),
	      content_item_id = DECODE( p_content_item_id, FND_API.g_miss_num, NULL, p_content_item_id),
              citem_version_id = DECODE( p_citem_version_id, FND_API.g_miss_num, NULL, p_citem_version_id)
	   WHERE placement_citem_id = p_placement_citem_id;

	   IF (SQL%NOTFOUND) THEN
		RAISE no_data_found;
	   END IF;


END Update_Row;


--  ========================================================
--
--  NAME
--  		createDeleteBody
--  PURPOSE
--		Table api to delete WebPlanner Citems Associations.
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Delete_Row(
    p_placement_citem_id  NUMBER,
    p_object_version_number NUMBER)
 IS
BEGIN
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('table handler : before delete of b; placement_citem_id = ' || p_placement_citem_id || ' object_version_num = ' || p_object_version_number);
   END IF;
   DELETE FROM ams_web_plce_citem_assoc
   WHERE placement_citem_id = p_placement_citem_id
   AND   object_version_number = p_object_version_number;

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_UTILITY_PVT.debug_message('table handler : After delete of b; placement_citem_id = ' || p_placement_citem_id || ' object_version_num = ' || p_object_version_number);

   END IF;

   If (SQL%NOTFOUND) then
		RAISE no_data_found;
   End If;


END Delete_Row ;

--  ========================================================
--
--  NAME
--  	createLockBody
--
--  PURPOSE
--	Table api to lock  WebPlanner Citems Associations.  .
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Lock_Row(
          p_placement_citem_id    NUMBER,
          p_placement_mp_id    NUMBER,
          p_content_item_id    NUMBER,
          p_citem_version_id    NUMBER,
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER
)

 IS
   CURSOR C IS
        SELECT *
         FROM ams_web_plce_citem_assoc
        WHERE PLACEMENT_CITEM_ID =  p_placement_citem_id
        FOR UPDATE of PLACEMENT_CITEM_ID NOWAIT;
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
          ( Recinfo.placement_citem_id = p_placement_citem_id)

       AND  ( (  Recinfo.placement_mp_id = p_placement_mp_id )
           OR ( (  Recinfo.placement_mp_id IS NULL )
       AND (  p_placement_mp_id IS NULL )))

         AND (    ( Recinfo.content_item_id = p_content_item_id)
            OR (    ( Recinfo.content_item_id IS NULL )
       AND (  p_content_item_id IS NULL )))

       AND (    ( Recinfo.citem_version_id = p_citem_version_id)
            OR (    ( Recinfo.citem_version_id IS NULL )
       AND (  p_citem_version_id IS NULL )))

        AND (    ( Recinfo.created_by = p_created_by)
            OR (    ( Recinfo.created_by IS NULL )
                AND (  p_created_by IS NULL )))
       AND (    ( Recinfo.creation_date = p_creation_date)
            OR (    ( Recinfo.creation_date IS NULL )
                AND (  p_creation_date IS NULL )))
       AND (    ( Recinfo.last_updated_by = p_last_updated_by)
            OR (    ( Recinfo.last_updated_by IS NULL )
                AND (  p_last_updated_by IS NULL )))
       AND (    ( Recinfo.last_update_date = p_last_update_date)
            OR (    ( Recinfo.last_update_date IS NULL )
                AND (  p_last_update_date IS NULL )))
       AND (    ( Recinfo.last_update_login = p_last_update_login)
            OR (    ( Recinfo.last_update_login IS NULL )
                AND (  p_last_update_login IS NULL )))
       AND (    ( Recinfo.object_version_number = p_object_version_number)
            OR (    ( Recinfo.object_version_number IS NULL )
                AND (  p_object_version_number IS NULL )))
       ) THEN
       RETURN;
   ELSE
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   END IF;
END Lock_Row;


PROCEDURE load_row (
     x_placement_citem_id   IN NUMBER,
         x_placement_mp_id  IN  NUMBER,
         x_content_item_id  IN  NUMBER,
         x_citem_version_id  IN  NUMBER,
         x_p_created_by   IN NUMBER,
         x_p_creation_date  IN  DATE,
         x_p_last_updated_by  IN  NUMBER,
         x_p_last_update_date  IN  DATE,
         x_p_last_update_login  IN  NUMBER,
         x_p_object_version_number   IN NUMBER,
	  x_owner               IN VARCHAR2,
	 x_custom_mode IN VARCHAR2
)
IS
   l_user_id      number :=1;
   l_obj_verno    number;
   l_dummy_char   varchar2(1);
   l_row_id       varchar2(100);
   l_placement_citem_id     number;
   l_db_luby_id   number;
    l_return_status    varchar2(100);
    l_msg_count        number;
    l_msg_data   varchar2(100);

     cursor c_db_data_details is
     select last_updated_by, nvl(object_version_number,1)
     from ams_web_plce_citem_assoc
     where placement_citem_id =  x_placement_citem_id;

   cursor c_chk_plce_citem_id_exists is
     select 'x'
     from   ams_web_plce_citem_assoc
     where placement_citem_id =  x_placement_citem_id;

   cursor c_get_placement_citem_id is
      select ams_web_plce_citem_assoc_s.nextval
      from dual;
BEGIN
   if X_OWNER = 'SEED' then
      l_user_id := 1;
elsif X_OWNER = 'ORACLE' then
      l_user_id := 2;
   elsif X_OWNER = 'SYSADMIN' then
      l_user_id := 0;
   end if;

   open c_chk_plce_citem_id_exists;
   fetch c_chk_plce_citem_id_exists into l_dummy_char;
   if c_chk_plce_citem_id_exists%notfound THEN
      if x_placement_citem_id is null then
         open c_get_placement_citem_id;
         fetch c_get_placement_citem_id into l_placement_citem_id;
         close c_get_placement_citem_id;
      else
         l_placement_citem_id := x_placement_citem_id;
      end if;
      l_obj_verno := 1;

      AMS_WEB_CITEM_ASSOC_PKG.Insert_Row (
         px_placement_citem_id => l_placement_citem_id,
	 p_placement_mp_id   => x_placement_mp_id,
         p_content_item_id  => x_content_item_id,
         p_citem_version_id =>   x_citem_version_id,
         p_created_by => l_user_id,
         p_creation_date => SYSDATE,
         p_last_updated_by => l_user_id,
         p_last_update_date => SYSDATE,
         p_last_update_login => 1,
         px_object_version_number => l_obj_verno,
	 p_return_status       => l_return_status,
	 p_msg_count         => l_msg_count,
	 p_msg_data            => l_msg_data
          );
   else
      open c_db_data_details;
      fetch c_db_data_details into l_db_luby_id, l_obj_verno;
      close c_db_data_details;

     if (l_db_luby_id IN (0, 1, 2) or NVL(x_custom_mode, 'PRESERVE')='FORCE')
      then
      AMS_WEB_CITEM_ASSOC_PKG.Update_Row (
         p_placement_citem_id => l_placement_citem_id,
	 p_placement_mp_id   => x_placement_mp_id ,
         p_content_item_id  => x_content_item_id,
         p_citem_version_id =>   x_citem_version_id,
         p_created_by => l_user_id,
         p_creation_date => SYSDATE,
         p_last_updated_by => l_user_id,
         p_last_update_date => SYSDATE,
         p_last_update_login => 1,
         p_object_version_number => l_obj_verno
      );
      end if;
   end if;
   close c_chk_plce_citem_id_exists;
END load_row;

END  AMS_WEB_CITEM_ASSOC_PKG;

/
