--------------------------------------------------------
--  DDL for Package Body AMS_IBA_PL_PG_PARAMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_IBA_PL_PG_PARAMS_PKG" as
/* $Header: amstpgpb.pls 120.0 2005/06/01 01:36:26 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_IBA_PL_PG_PARAMS_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_IBA_PL_PG_PARAMS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amstpgpb.pls';


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
          px_page_parameter_id   IN OUT NOCOPY NUMBER,
          p_page_id    NUMBER,
          p_site_ref_code    VARCHAR2,
          p_page_ref_code    VARCHAR2,
          p_parameter_id    NUMBER,
          p_parameter_ref_code    VARCHAR2,
          p_execution_order    NUMBER,
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER)

 IS
   x_rowid    VARCHAR2(30);


BEGIN


   px_object_version_number := 1;


   INSERT INTO AMS_IBA_PL_PG_PARAMS(
           page_parameter_id,
           page_id,
           site_ref_code,
           page_ref_code,
           parameter_id,
           parameter_ref_code,
           execution_order,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login,
           object_version_number
   ) VALUES (
           DECODE( px_page_parameter_id, FND_API.g_miss_num, NULL, px_page_parameter_id),
           DECODE( p_page_id, FND_API.g_miss_num, NULL, p_page_id),
           DECODE( p_site_ref_code, FND_API.g_miss_char, NULL, p_site_ref_code),
           DECODE( p_page_ref_code, FND_API.g_miss_char, NULL, p_page_ref_code),
           DECODE( p_parameter_id, FND_API.g_miss_num, NULL, p_parameter_id),
           DECODE( p_parameter_ref_code, FND_API.g_miss_char, NULL, p_parameter_ref_code),
           DECODE( p_execution_order, FND_API.g_miss_num, NULL, p_execution_order),
           DECODE( p_created_by, FND_API.g_miss_num, NULL, p_created_by),
           DECODE( p_creation_date, FND_API.g_miss_date, NULL, p_creation_date),
           DECODE( p_last_updated_by, FND_API.g_miss_num, NULL, p_last_updated_by),
           DECODE( p_last_update_date, FND_API.g_miss_date, NULL, p_last_update_date),
           DECODE( p_last_update_login, FND_API.g_miss_num, NULL, p_last_update_login),
           DECODE( px_object_version_number, FND_API.g_miss_num, NULL, px_object_version_number));
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
          p_page_parameter_id    NUMBER,
          p_page_id    NUMBER,
          p_site_ref_code    VARCHAR2,
          p_page_ref_code    VARCHAR2,
          p_parameter_id    NUMBER,
          p_parameter_ref_code    VARCHAR2,
          p_execution_order    NUMBER,
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER)

 IS
 BEGIN
    Update AMS_IBA_PL_PG_PARAMS
    SET
              page_id = DECODE( p_page_id, FND_API.g_miss_num, page_id, p_page_id),
              site_ref_code = DECODE( p_site_ref_code, FND_API.g_miss_char, site_ref_code, p_site_ref_code),
              page_ref_code = DECODE( p_page_ref_code, FND_API.g_miss_char, page_ref_code, p_page_ref_code),
              parameter_id = DECODE( p_parameter_id, FND_API.g_miss_num, parameter_id, p_parameter_id),
              parameter_ref_code = DECODE( p_parameter_ref_code, FND_API.g_miss_char, parameter_ref_code, p_parameter_ref_code),
              execution_order = DECODE( p_execution_order, FND_API.g_miss_num, execution_order, p_execution_order),
              last_updated_by = DECODE( p_last_updated_by, FND_API.g_miss_num, last_updated_by, p_last_updated_by),
              last_update_date = DECODE( p_last_update_date, FND_API.g_miss_date, last_update_date, p_last_update_date),
              last_update_login = DECODE( p_last_update_login, FND_API.g_miss_num, last_update_login, p_last_update_login),
              object_version_number = DECODE( p_object_version_number, FND_API.g_miss_num, object_version_number, p_object_version_number)
   WHERE PAGE_PARAMETER_ID = p_PAGE_PARAMETER_ID
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
    p_PAGE_PARAMETER_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM AMS_IBA_PL_PG_PARAMS
    WHERE PAGE_PARAMETER_ID = p_PAGE_PARAMETER_ID;
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
          p_page_parameter_id    NUMBER,
          p_page_id    NUMBER,
          p_site_ref_code    VARCHAR2,
          p_page_ref_code    VARCHAR2,
          p_parameter_id    NUMBER,
          p_parameter_ref_code    VARCHAR2,
          p_execution_order    NUMBER,
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER)

 IS
   CURSOR C IS
        SELECT *
         FROM AMS_IBA_PL_PG_PARAMS
        WHERE PAGE_PARAMETER_ID =  p_PAGE_PARAMETER_ID
        FOR UPDATE of PAGE_PARAMETER_ID NOWAIT;
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
           (      Recinfo.page_parameter_id = p_page_parameter_id)
       AND (    ( Recinfo.page_id = p_page_id)
            OR (    ( Recinfo.page_id IS NULL )
                AND (  p_page_id IS NULL )))
       AND (    ( Recinfo.site_ref_code = p_site_ref_code)
            OR (    ( Recinfo.site_ref_code IS NULL )
                AND (  p_site_ref_code IS NULL )))
       AND (    ( Recinfo.page_ref_code = p_page_ref_code)
            OR (    ( Recinfo.page_ref_code IS NULL )
                AND (  p_page_ref_code IS NULL )))
       AND (    ( Recinfo.parameter_id = p_parameter_id)
            OR (    ( Recinfo.parameter_id IS NULL )
                AND (  p_parameter_id IS NULL )))
       AND (    ( Recinfo.parameter_ref_code = p_parameter_ref_code)
            OR (    ( Recinfo.parameter_ref_code IS NULL )
                AND (  p_parameter_ref_code IS NULL )))
       AND (    ( Recinfo.execution_order = p_execution_order)
            OR (    ( Recinfo.execution_order IS NULL )
                AND (  p_execution_order IS NULL )))
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
   x_page_parameter_id       IN NUMBER,
   x_page_id            IN NUMBER,
   x_site_ref_code      IN VARCHAR2,
   x_page_ref_code      IN VARCHAR2,
   x_parameter_id            IN NUMBER,
   x_parameter_ref_code IN VARCHAR2,
   x_execution_order    IN NUMBER,
   x_owner              IN VARCHAR2,
   x_custom_mode  IN VARCHAR2
  )
IS
   l_user_id      number := 1;
   l_obj_verno    number;
   l_dummy_char   varchar2(1);
   l_row_id       varchar2(100);
   l_page_parameter_id     number;
   l_db_luby_id   number;

 /*  cursor  c_obj_verno is
     select object_version_number
     from    ams_iba_pl_pg_params
     where  page_parameter_id =  x_page_parameter_id;*/

 cursor c_db_data_details is
     select last_updated_by, nvl(object_version_number,1)
     from ams_iba_pl_pg_params
     where page_parameter_id =  x_page_parameter_id;

   cursor c_chk_page_parameter_exists is
     select 'x'
     from   ams_iba_pl_pg_params
     where  page_parameter_id = x_page_parameter_id;

   cursor c_get_page_parameter_id is
      select ams_iba_pl_params_b_s.nextval
      from dual;
BEGIN
   if X_OWNER = 'SEED' then
      l_user_id := 1;
   elsif X_OWNER = 'ORACLE' then
      l_user_id := 2;
   elsif X_OWNER = 'SYSADMIN' then
      l_user_id := 0;
   end if;

   open c_chk_page_parameter_exists;
   fetch c_chk_page_parameter_exists into l_dummy_char;
   if c_chk_page_parameter_exists%notfound THEN
      if x_page_parameter_id is null then
         open c_get_page_parameter_id;
         fetch c_get_page_parameter_id into l_page_parameter_id;
         close c_get_page_parameter_id;
      else
         l_page_parameter_id := x_page_parameter_id;
      end if;
      l_obj_verno := 1;

      AMS_IBA_PL_PG_PARAMS_PKG.Insert_Row (
         px_page_parameter_id => l_page_parameter_id,
         p_page_id => x_page_id,
         p_site_ref_code => x_site_ref_code,
         p_page_ref_code => x_page_ref_code,
         p_parameter_id => x_parameter_id,
         p_parameter_ref_code => x_parameter_ref_code,
         p_execution_order => x_execution_order,
         p_created_by => l_user_id,
         p_creation_date => SYSDATE,
         p_last_updated_by => l_user_id,
         p_last_update_date => SYSDATE,
         p_last_update_login => 1,
         px_object_version_number => l_obj_verno
      );
   else
     open c_db_data_details;
      fetch c_db_data_details into l_db_luby_id, l_obj_verno;
      close c_db_data_details;

   if (l_db_luby_id IN (0, 1, 2) or NVL(x_custom_mode, 'PRESERVE')='FORCE')
      then

      AMS_IBA_PL_PG_PARAMS_PKG.UPDATE_ROW (
         p_page_parameter_id => x_page_parameter_id,
         p_page_id => x_page_id,
         p_site_ref_code => x_site_ref_code,
         p_page_ref_code => x_page_ref_code,
         p_parameter_id => x_parameter_id,
         p_parameter_ref_code => x_parameter_ref_code,
         p_execution_order => x_execution_order,
         p_created_by => l_user_id,
         p_creation_date => SYSDATE,
         p_last_updated_by => l_user_id,
         p_last_update_date => SYSDATE,
         p_last_update_login => 1,
         p_object_version_number => l_obj_verno
      );
   end if;
   end if;
   close c_chk_page_parameter_exists;
END load_row;

END AMS_IBA_PL_PG_PARAMS_PKG;

/
