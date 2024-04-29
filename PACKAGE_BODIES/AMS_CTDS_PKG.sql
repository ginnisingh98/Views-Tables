--------------------------------------------------------
--  DDL for Package Body AMS_CTDS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_CTDS_PKG" as
/* $Header: amstctdb.pls 120.1 2005/06/03 12:41:22 appldev  $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_CTDS_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_CTDS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amstctdb.pls';


----------------------------------------------------------
----          MEDIA           ----
----------------------------------------------------------

--  ========================================================
--
--  NAME
--  createInsertBody
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Insert_Row(
          px_ctd_id   IN OUT NOCOPY NUMBER,
	  p_action_id    NUMBER,
          p_forward_url    VARCHAR2,
          p_track_url    VARCHAR2,
          p_activity_product_id    NUMBER,
          p_activity_offer_id    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_security_group_id    NUMBER)

 IS
   x_rowid    VARCHAR2(30);


BEGIN


   px_object_version_number := 1;


   INSERT INTO AMS_CTDS(
           ctd_id,
           action_id,
           forward_url,
           track_url,
           activity_product_id,
           activity_offer_id,
           object_version_number,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           last_update_login,
           security_group_id
   ) VALUES (
           DECODE( px_ctd_id, FND_API.g_miss_num, NULL, px_ctd_id),
	   DECODE( p_action_id, FND_API.g_miss_num, NULL, p_action_id),
           DECODE( p_forward_url, FND_API.g_miss_char, NULL, p_forward_url),
           DECODE( p_track_url, FND_API.g_miss_char, NULL, p_track_url),
           DECODE( p_activity_product_id, FND_API.g_miss_num, NULL, p_activity_product_id),
           DECODE( p_activity_offer_id, FND_API.g_miss_num, NULL, p_activity_offer_id),
           DECODE( px_object_version_number, FND_API.g_miss_num, NULL, px_object_version_number),
           DECODE( p_last_update_date, FND_API.g_miss_date, NULL, p_last_update_date),
           DECODE( p_last_updated_by, FND_API.g_miss_num, NULL, p_last_updated_by),
           DECODE( p_creation_date, FND_API.g_miss_date, NULL, p_creation_date),
           DECODE( p_created_by, FND_API.g_miss_num, NULL, p_created_by),
           DECODE( p_last_update_login, FND_API.g_miss_num, NULL, p_last_update_login),
           DECODE( p_security_group_id, FND_API.g_miss_num, NULL, p_security_group_id));
END Insert_Row;


----------------------------------------------------------
----          MEDIA           ----
----------------------------------------------------------

--  ========================================================
--
--  NAME
--  createUpdateBody
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Update_Row(
          p_ctd_id    NUMBER,
          p_action_id    NUMBER,
          p_forward_url    VARCHAR2,
          p_track_url    VARCHAR2,
          p_activity_product_id    NUMBER,
          p_activity_offer_id    NUMBER,
          p_object_version_number    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_security_group_id    NUMBER)

 IS
 BEGIN
    Update AMS_CTDS
    SET
              ctd_id = DECODE( p_ctd_id, FND_API.g_miss_num, ctd_id, p_ctd_id),
              action_id = DECODE( p_action_id, FND_API.g_miss_num, action_id, p_action_id),
              forward_url = DECODE( p_forward_url, FND_API.g_miss_char, forward_url, p_forward_url),
              track_url = DECODE( p_track_url, FND_API.g_miss_char, track_url, p_track_url),
              activity_product_id = DECODE( p_activity_product_id, FND_API.g_miss_num, activity_product_id, p_activity_product_id),
              activity_offer_id = DECODE( p_activity_offer_id, FND_API.g_miss_num, activity_offer_id, p_activity_offer_id),
              object_version_number = DECODE( p_object_version_number, FND_API.g_miss_num, object_version_number, p_object_version_number+1),
              last_update_date = DECODE( p_last_update_date, FND_API.g_miss_date, last_update_date, p_last_update_date),
              last_updated_by = DECODE( p_last_updated_by, FND_API.g_miss_num, last_updated_by, p_last_updated_by),
              creation_date = DECODE( p_creation_date, FND_API.g_miss_date, creation_date, p_creation_date),
              created_by = DECODE( p_created_by, FND_API.g_miss_num, created_by, p_created_by),
              last_update_login = DECODE( p_last_update_login, FND_API.g_miss_num, last_update_login, p_last_update_login),
              security_group_id = DECODE( p_security_group_id, FND_API.g_miss_num, security_group_id, p_security_group_id)
   WHERE CTD_ID = p_CTD_ID
   AND   object_version_number = p_object_version_number;

   IF (SQL%NOTFOUND) THEN
	RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
END Update_Row;


----------------------------------------------------------
----          MEDIA           ----
----------------------------------------------------------

--  ========================================================
--
--  NAME
--  createDeleteBody
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Delete_Row(
    p_CTD_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM AMS_CTDS
    WHERE CTD_ID = p_CTD_ID;
   If (SQL%NOTFOUND) then
RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   End If;
 END Delete_Row ;



----------------------------------------------------------
----          MEDIA           ----
----------------------------------------------------------

--  ========================================================
--
--  NAME
--  createLockBody
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Lock_Row(
          p_ctd_id    NUMBER,
          p_action_id    NUMBER,
          p_forward_url    VARCHAR2,
          p_track_url    VARCHAR2,
          p_activity_product_id    NUMBER,
          p_activity_offer_id    NUMBER,
          p_object_version_number    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_security_group_id    NUMBER)

 IS
   CURSOR C IS
        SELECT *
         FROM AMS_CTDS
        WHERE CTD_ID =  p_CTD_ID
        FOR UPDATE of CTD_ID NOWAIT;
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
           (      Recinfo.ctd_id = p_ctd_id)
       AND (    ( Recinfo.action_id = p_action_id)
            OR (    ( Recinfo.action_id IS NULL )
                AND (  p_action_id IS NULL )))
       AND (    ( Recinfo.forward_url = p_forward_url)
            OR (    ( Recinfo.forward_url IS NULL )
                AND (  p_forward_url IS NULL )))
       AND (    ( Recinfo.track_url = p_track_url)
            OR (    ( Recinfo.track_url IS NULL )
                AND (  p_track_url IS NULL )))
       AND (    ( Recinfo.activity_product_id = p_activity_product_id)
            OR (    ( Recinfo.activity_product_id IS NULL )
                AND (  p_activity_product_id IS NULL )))
       AND (    ( Recinfo.activity_offer_id = p_activity_offer_id)
            OR (    ( Recinfo.activity_offer_id IS NULL )
                AND (  p_activity_offer_id IS NULL )))
       AND (    ( Recinfo.object_version_number = p_object_version_number)
            OR (    ( Recinfo.object_version_number IS NULL )
                AND (  p_object_version_number IS NULL )))
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
       AND (    ( Recinfo.security_group_id = p_security_group_id)
            OR (    ( Recinfo.security_group_id IS NULL )
                AND (  p_security_group_id IS NULL )))
       ) THEN
       RETURN;
   ELSE
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   END IF;
END Lock_Row;

--  ========================================================
--
--  NAME
--  LOAD_ROW
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
procedure  LOAD_ROW(
	X_CTD_ID IN NUMBER,
	X_ACTION_ID IN NUMBER,
	X_FORWARD_URL IN VARCHAR2,
	X_TRACK_URL IN VARCHAR2,
	X_ACTIVITY_PRODUCT_ID IN NUMBER,
	X_ACTIVITY_OFFER_ID IN NUMBER,
	X_OWNER in  VARCHAR2,
	X_CUSTOM_MODE in VARCHAR2
) is

l_user_id   number := 0;
l_last_updated_by number;
l_obj_verno  number;
l_ctd_id number := 1;
l_row_id    varchar2(100);
l_dummy_char   varchar2(1);

cursor c_obj_verno is
  select OBJECT_VERSION_NUMBER,
	 last_updated_by
  from   AMS_CTDS
  where  CTD_ID = X_CTD_ID;

cursor c_chk_ctd_exists is
  select 'X'
  from AMS_CTDS
  where CTD_ID = X_CTD_ID;

cursor c_get_ctd_id is
      select ams_ctds_s.nextval
      from dual;

BEGIN

 if X_OWNER = 'SEED' then
     l_user_id := 1;
 elsif X_OWNER = 'ORACLE' then
     l_user_id := 2;
 elsif X_OWNER = 'SYSADMIN' THEN
    l_user_id := 0;
 end if;

 open c_chk_ctd_exists;
 fetch c_chk_ctd_exists into l_dummy_char;
 if c_chk_ctd_exists%notfound
 then
    if x_ctd_id is null then
	open c_get_ctd_id;
	fetch c_get_ctd_id into l_ctd_id;
	close c_get_ctd_id;
    else
         l_ctd_id := x_ctd_id;
    end if;

    close c_chk_ctd_exists;
    l_obj_verno := 1;
    AMS_CTDS_PKG.INSERT_ROW (
	  px_ctd_id => l_ctd_id,
          p_action_id  =>   X_ACTION_ID,
          p_forward_url =>   x_forward_url,
          p_track_url   => x_track_url,
          p_activity_product_id => X_ACTIVITY_PRODUCT_ID,
          p_activity_offer_id => X_ACTIVITY_offer_ID,
          px_object_version_number => l_obj_verno,
          p_last_update_date => sysdate,
          p_last_updated_by => l_user_id,
          p_creation_date => sysdate,
          p_created_by  =>l_user_id,
          p_last_update_login => 0,
          p_security_group_id => 0);

  else
    close c_chk_ctd_exists;

    open c_obj_verno;
    fetch c_obj_verno into l_obj_verno,l_last_updated_by;
    /*if (c_obj_verno%notfound) then
	--dbms_output.put_line('Excpetion :: rec not found with the obj version num');
    end if;*/
    close c_obj_verno;

    if (l_last_updated_by in (1,2,0) OR
       NVL(x_custom_mode,'PRESERVE')='FORCE') THEN

       AMS_CTDS_PKG.UPDATE_ROW(
	  p_ctd_id => X_CTD_ID,
          p_action_id => X_ACTION_ID,
          p_forward_url => X_FORWARD_URL,
          p_track_url => X_TRACK_URL,
          p_activity_product_id => X_ACTIVITY_PRODUCT_ID,
          p_activity_offer_id => X_ACTIVITY_OFFER_ID,
	  p_object_version_number => l_obj_verno,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => l_last_updated_by,
          p_creation_date => SYSDATE,
          p_created_by => l_user_id,
          p_last_update_login  => 0,
          p_security_group_id  =>0
         );
    end if;
  end if;

  EXCEPTION  -- exception handlers begin
   WHEN OTHERS THEN  -- handles all other errors
      ROLLBACK;

END LOAD_ROW;

--  ========================================================
--
--  NAME
--  TRANSLATE_ROW
--
--  PURPOSE
--
--  NOTES
--     This table doen't have any translatable entry.
--  HISTORY
--
--  ========================================================

PROCEDURE TRANSLATE_ROW (
	X_CTD_ID IN NUMBER,
	X_OWNER IN VARCHAR2,
	X_CUSTOM_MODE IN VARCHAR2
)
is
l_date DATE;
BEGIN
	select sysdate into l_date from dual;
END TRANSLATE_ROW;


END AMS_CTDS_PKG;

/
