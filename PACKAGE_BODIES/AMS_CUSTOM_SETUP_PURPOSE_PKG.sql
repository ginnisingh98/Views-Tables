--------------------------------------------------------
--  DDL for Package Body AMS_CUSTOM_SETUP_PURPOSE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_CUSTOM_SETUP_PURPOSE_PKG" as
 /* $Header: amslcspb.pls 115.3 2004/04/08 22:51:45 asaha noship $ */
 -- ===============================================================
 -- Start of Comments
 -- Package name
 --          AMS_Custom_Setup_Purpose_PKG
 -- Purpose
 --
 -- History
 --
 -- NOTE

 G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_Custom_Setup_Purpose_PKG';
 G_FILE_NAME CONSTANT VARCHAR2(12) := 'amslcspb.pls';

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
           px_setup_purpose_id      IN OUT NOCOPY NUMBER,
           p_custom_setup_id        NUMBER,
           p_last_update_date       DATE,
           p_last_updated_by        NUMBER,
           p_creation_date          DATE,
           p_created_by             NUMBER,
           p_last_update_login      NUMBER,
           p_activity_purpose_code  VARCHAR2,
           p_enabled_flag           VARCHAR2,
           p_def_list_template_id   NUMBER,
           px_object_version_number IN OUT NOCOPY NUMBER)

  IS
    x_rowid    VARCHAR2(30);

 BEGIN
    px_object_version_number := nvl(px_object_version_number, 1);

    INSERT INTO ams_custom_setup_purpose(
            setup_purpose_id,
            custom_setup_id,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            last_update_login,
            activity_purpose_code,
            enabled_flag,
            def_list_template_id,
            object_version_number
    ) VALUES (
            DECODE( px_setup_purpose_id, FND_API.G_MISS_NUM, NULL, px_setup_purpose_id),
            DECODE( p_custom_setup_id, FND_API.G_MISS_NUM, NULL, p_custom_setup_id),
            DECODE( p_last_update_date, FND_API.G_MISS_DATE, SYSDATE, p_last_update_date),
            DECODE( p_last_updated_by, FND_API.G_MISS_NUM, FND_GLOBAL.USER_ID, p_last_updated_by),
            DECODE( p_creation_date, FND_API.G_MISS_DATE, SYSDATE, p_creation_date),
            DECODE( p_created_by, FND_API.G_MISS_NUM, FND_GLOBAL.USER_ID, p_created_by),
            DECODE( p_last_update_login, FND_API.G_MISS_NUM, FND_GLOBAL.CONC_LOGIN_ID, p_last_update_login),
            DECODE( p_activity_purpose_code, FND_API.g_miss_char, NULL, p_activity_purpose_code),
            DECODE( p_enabled_flag, FND_API.g_miss_char, NULL, p_enabled_flag),
            DECODE( p_def_list_template_id, FND_API.G_MISS_NUM, NULL, p_def_list_template_id),
            DECODE( px_object_version_number, FND_API.G_MISS_NUM, 1, px_object_version_number));

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
           p_setup_purpose_id      NUMBER,
           p_custom_setup_id       NUMBER,
           p_last_update_date      DATE,
           p_last_updated_by       NUMBER,
           p_last_update_login     NUMBER,
           p_activity_purpose_code VARCHAR2,
           p_enabled_flag          VARCHAR2,
           p_def_list_template_id  NUMBER,
           p_object_version_number IN NUMBER)

  IS
  BEGIN
     Update ams_custom_setup_purpose
     SET
               setup_purpose_id = DECODE( p_setup_purpose_id, null, setup_purpose_id, FND_API.G_MISS_NUM, null, p_setup_purpose_id),
               custom_setup_id = DECODE( p_custom_setup_id, null, custom_setup_id, FND_API.G_MISS_NUM, null, p_custom_setup_id),
               last_update_date = DECODE( p_last_update_date, null, last_update_date, FND_API.G_MISS_DATE, null, p_last_update_date),
               last_updated_by = DECODE( p_last_updated_by, null, last_updated_by, FND_API.G_MISS_NUM, null, p_last_updated_by),
               last_update_login = DECODE( p_last_update_login, null, last_update_login, FND_API.G_MISS_NUM, null, p_last_update_login),
               activity_purpose_code = DECODE( p_activity_purpose_code, null, activity_purpose_code, FND_API.g_miss_char, null, p_activity_purpose_code),
               enabled_flag = DECODE( p_enabled_flag, null, enabled_flag, FND_API.g_miss_char, null, p_enabled_flag),
               def_list_template_id = DECODE( p_def_list_template_id, null, def_list_template_id, FND_API.G_MISS_NUM, null, p_def_list_template_id),
               object_version_number = nvl(p_object_version_number,0) + 1
    WHERE setup_purpose_id = p_setup_purpose_id
    AND   object_version_number = p_object_version_number;


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
     p_setup_purpose_id  NUMBER,
     p_object_version_number  NUMBER)
  IS
  BEGIN
    DELETE FROM ams_custom_setup_purpose
     WHERE setup_purpose_id = p_setup_purpose_id
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
     p_setup_purpose_id  NUMBER,
     p_object_version_number  NUMBER)
  IS
    CURSOR C IS
         SELECT *
         FROM ams_custom_setup_purpose
         WHERE setup_purpose_id =  p_setup_purpose_id
         AND object_version_number = p_object_version_number
         FOR UPDATE OF setup_purpose_id NOWAIT;
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
--  ========================================================
/* This procedure is used to load the data from flat file to customer's database.
  If there is no row existing for the data from flat file then create the data.
  else
    1) modify the whole data when data in db is not modified by customer which
       can be found by comparing last updated by value to be
          SEED/DATAMERGE(1), or
          INITIAL SETUP/ORACLE (2), or
          SYSTEM ADMINISTRATOR (0).or
    2) modify the whole data when custom_mode is 'FORCE'
    3) if the data in db is modified by customer, which can be found by
      by comparing last updated by value to be not of 0,1,2, then
      in that case modify only the user unexposed data with last updated by as
      3 to distinguish that data is updated by patch.
*/
PROCEDURE Load_Row(
  p_setup_purpose_id        NUMBER,
  p_custom_setup_id          NUMBER,
  p_activity_purpose_code    VARCHAR2,
  p_enabled_flag             VARCHAR2,
  p_def_list_template_id     NUMBER,
  p_owner                    VARCHAR2,
  p_custom_mode              VARCHAR2,
  X_LAST_UPDATE_DATE   in DATE)

IS
l_user_id   number := 1;
-- user id to be used in case of exceptions to update the customer
-- modified unexposed data.
l_excp_user_id number := 3 ;

l_obj_verno  number;
l_dummy_number  number;
l_row_id    varchar2(100);
l_setup_purpose_id   number;
l_db_luby_id NUMBER;

cursor  c_db_data_details is
  select last_updated_by, nvl(object_version_number,1)
  from   ams_custom_setup_purpose
  where  setup_purpose_id =  p_setup_purpose_id;

cursor c_chk_csp_exists is
  select 1
  from   ams_custom_setup_purpose
  where  setup_purpose_id =  p_setup_purpose_id;

cursor c_get_cspid is
   select ams_custom_setup_purpose_s.nextval
   from dual;

BEGIN

-- set the last_updated_by to be used while updating the data in customer data.

  if p_OWNER = 'SEED' then
    l_user_id := 1;
  elsif p_OWNER = 'ORACLE' THEN
    l_user_id := 2;
  elsif p_OWNER = 'SYSADMIN' THEN
    l_user_id := 0;
  end if ;

  open c_chk_csp_exists;
  fetch c_chk_csp_exists into l_dummy_number;
  if c_chk_csp_exists%notfound
  then
    -- data does not exist in customer, and hence create the data.
    close c_chk_csp_exists;
    if p_setup_purpose_id is null
    then
      open c_get_cspid;
      fetch c_get_cspid into l_setup_purpose_id;
      close c_get_cspid;
    else
       l_setup_purpose_id := p_setup_purpose_id;
    end if;

    l_obj_verno := 1;

    Insert_Row(px_setup_purpose_id  => l_setup_purpose_id,
           p_custom_setup_id        => p_custom_setup_id,
           p_last_update_date       => X_LAST_UPDATE_DATE,
           p_last_updated_by        => l_user_id,
           p_creation_date          => X_LAST_UPDATE_DATE,
           p_created_by             => l_user_id,
           p_last_update_login      => 0,
           p_activity_purpose_code  => p_activity_purpose_code,
           p_enabled_flag           => p_enabled_flag,
           p_def_list_template_id   => p_def_list_template_id,
           px_object_version_number => l_obj_verno);

   else
    -- Update the data as per above rules.
    close c_chk_csp_exists;
    open c_db_data_details;
    fetch c_db_data_details into l_db_luby_id, l_obj_verno;
    close c_db_data_details;
    if ( l_db_luby_id IN (1, 2, 0)
      OR NVL(p_custom_mode,'PRESERVE') = 'FORCE') THEN

      Update_Row(
           p_setup_purpose_id       => p_setup_purpose_id,
           p_custom_setup_id        => p_custom_setup_id,
           p_last_update_date       => X_LAST_UPDATE_DATE,
           p_last_updated_by        => l_user_id,
           p_last_update_login      => 0,
           p_activity_purpose_code  => p_activity_purpose_code,
           p_enabled_flag           => p_enabled_flag,
           p_def_list_template_id   => p_def_list_template_id,
           p_object_version_number  => l_obj_verno);

    end if;
   end if;
 end LOAD_ROW;


 END AMS_Custom_Setup_Purpose_PKG;

/
