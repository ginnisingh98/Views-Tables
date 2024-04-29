--------------------------------------------------------
--  DDL for Package Body AMS_MET_TPL_ASSOCS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_MET_TPL_ASSOCS_PKG" AS
/* $Header: amslmtab.pls 115.10 2003/03/07 22:45:44 dmvincen ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_MET_TPL_ASSOCS_PKG
-- Purpose
--
-- History
--   03/05/2002  dmvincen  Created.
--   03/07/2002  dmvincen  Added LOAD_ROW.
--   03/06/2003  dmvincen  BUG2819067: Do not update if customized.
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_MET_TPL_ASSOCS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amslmtab.pls';


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
AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Insert_Row(
          p_metric_tpl_assoc_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          px_object_version_number   NUMBER,
          p_metric_tpl_header_id    NUMBER,
          p_association_type    VARCHAR2,
          p_used_by_id    NUMBER,
          p_used_by_code    VARCHAR2,
          p_enabled_flag    VARCHAR2)

 IS
   x_rowid    VARCHAR2(30);

BEGIN

--   px_object_version_number := 1;

   INSERT INTO AMS_MET_TPL_ASSOCS(
      metric_tpl_assoc_id,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login,
      object_version_number,
      metric_tpl_header_id,
      association_type,
      used_by_id,
      used_by_code,
      enabled_flag
   ) VALUES (
      DECODE( p_metric_tpl_assoc_id, FND_API.g_miss_num, NULL, p_metric_tpl_assoc_id),
      DECODE( p_last_update_date, FND_API.g_miss_date, NULL, p_last_update_date),
      DECODE( p_last_updated_by, FND_API.g_miss_num, NULL, p_last_updated_by),
      DECODE( p_creation_date, FND_API.g_miss_date, NULL, p_creation_date),
      DECODE( p_created_by, FND_API.g_miss_num, NULL, p_created_by),
      DECODE( p_last_update_login, FND_API.g_miss_num, NULL, p_last_update_login),
      1, -- DECODE( px_object_version_number, FND_API.g_miss_num, NULL, px_object_version_number),
      DECODE( p_metric_tpl_header_id, FND_API.g_miss_num, NULL, p_metric_tpl_header_id),
      DECODE( p_association_type, FND_API.g_miss_char, NULL, p_association_type),
      DECODE( p_used_by_id, FND_API.g_miss_num, NULL, p_used_by_id),
      DECODE( p_used_by_code, FND_API.g_miss_char, NULL, p_used_by_code),
      DECODE( p_enabled_flag, FND_API.g_miss_char, NULL, p_enabled_flag));
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
          p_metric_tpl_assoc_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number   NUMBER,
          p_metric_tpl_header_id    NUMBER,
          p_association_type    VARCHAR2,
          p_used_by_id    NUMBER,
          p_used_by_code    VARCHAR2,
          p_enabled_flag    VARCHAR2)

 IS
 BEGIN
    UPDATE AMS_MET_TPL_ASSOCS
    SET
       metric_tpl_assoc_id = DECODE( p_metric_tpl_assoc_id, FND_API.g_miss_num, metric_tpl_assoc_id, p_metric_tpl_assoc_id),
       last_update_date = DECODE( p_last_update_date, FND_API.g_miss_date, last_update_date, p_last_update_date),
       last_updated_by = DECODE( p_last_updated_by, FND_API.g_miss_num, last_updated_by, p_last_updated_by),
       last_update_login = DECODE( p_last_update_login, FND_API.g_miss_num, last_update_login, p_last_update_login),
       object_version_number = DECODE( p_object_version_number, FND_API.g_miss_num, object_version_number, p_object_version_number),
       metric_tpl_header_id = DECODE( p_metric_tpl_header_id, FND_API.g_miss_num, metric_tpl_header_id, p_metric_tpl_header_id),
       association_type = DECODE( p_association_type, FND_API.g_miss_char, association_type, p_association_type),
       used_by_id = DECODE( p_used_by_id, FND_API.g_miss_num, used_by_id, p_used_by_id),
       used_by_code = DECODE( p_used_by_code, FND_API.g_miss_char, used_by_code, p_used_by_code),
       enabled_flag = DECODE( p_enabled_flag, FND_API.g_miss_char, enabled_flag, p_enabled_flag)
   WHERE METRIC_TPL_ASSOC_ID = p_METRIC_TPL_ASSOC_ID;
   --AND   object_version_number = p_object_version_number;

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
    p_METRIC_TPL_ASSOC_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM AMS_MET_TPL_ASSOCS
    WHERE METRIC_TPL_ASSOC_ID = p_METRIC_TPL_ASSOC_ID;
   IF (SQL%NOTFOUND) THEN
RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
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
          p_metric_tpl_assoc_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_metric_tpl_header_id    NUMBER,
          p_association_type    VARCHAR2,
          p_used_by_id    NUMBER,
          p_used_by_code    VARCHAR2,
          p_enabled_flag    VARCHAR2)

IS
   CURSOR C IS
        SELECT *
         FROM AMS_MET_TPL_ASSOCS
        WHERE METRIC_TPL_ASSOC_ID =  p_METRIC_TPL_ASSOC_ID
        FOR UPDATE OF METRIC_TPL_ASSOC_ID NOWAIT;
   Recinfo C%ROWTYPE;
BEGIN
    OPEN c;
    FETCH c INTO Recinfo;
    IF (c%NOTFOUND) THEN
        CLOSE c;
        FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
        APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
    CLOSE C;
    IF (
           (      Recinfo.metric_tpl_assoc_id = p_metric_tpl_assoc_id)
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
       AND (    ( Recinfo.metric_tpl_header_id = p_metric_tpl_header_id)
            OR (    ( Recinfo.metric_tpl_header_id IS NULL )
                AND (  p_metric_tpl_header_id IS NULL )))
       AND (    ( Recinfo.association_type = p_association_type)
            OR (    ( Recinfo.association_type IS NULL )
                AND (  p_association_type IS NULL )))
       AND (    ( Recinfo.used_by_id = p_used_by_id)
            OR (    ( Recinfo.used_by_id IS NULL )
                AND (  p_used_by_id IS NULL )))
       AND (    ( Recinfo.used_by_code = p_used_by_code)
            OR (    ( Recinfo.used_by_code IS NULL )
                AND (  p_used_by_code IS NULL )))
       AND (    ( Recinfo.enabled_flag = p_enabled_flag)
            OR (    ( Recinfo.enabled_flag IS NULL )
                AND (  p_enabled_flag IS NULL )))
       ) THEN
       RETURN;
   ELSE
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   END IF;
END Lock_Row;

PROCEDURE LOAD_ROW (
        X_METRIC_TPL_ASSOC_ID NUMBER,
        X_OBJECT_VERSION_NUMBER NUMBER,
        X_METRIC_TPL_HEADER_ID NUMBER,
        X_ASSOCIATION_TYPE VARCHAR2,
        X_USED_BY_ID NUMBER,
        X_USED_BY_CODE VARCHAR2,
        X_ENABLED_FLAG VARCHAR2,
        X_Owner   VARCHAR2,
        X_CUSTOM_MODE VARCHAR2
        )
IS
l_user_id   NUMBER := 0;
l_obj_verno  NUMBER;
l_row_id    VARCHAR2(100);
l_metric_tpl_assoc_id   NUMBER;
l_db_luby_id NUMBER;

CURSOR  c_db_data_details IS
  SELECT last_updated_by, object_version_number
  FROM    AMS_MET_TPL_ASSOCS
  WHERE  METRIC_TPL_ASSOC_ID =  X_METRIC_TPL_ASSOC_ID;

CURSOR c_get_mtaid IS
   SELECT AMS_MET_TPL_ASSOCS_S.NEXTVAL
   FROM dual;

BEGIN
  if X_OWNER = 'SEED' then
    l_user_id := 1;
  elsif X_OWNER = 'ORACLE' THEN
    l_user_id := 2;
  elsif X_OWNER = 'SYSADMIN' THEN
    l_user_id := 0;
  end if ;

   OPEN c_db_data_details;
   FETCH c_db_data_details INTO l_db_luby_id, l_obj_verno;
 IF c_db_data_details%NOTFOUND
 THEN
   CLOSE c_db_data_details;

    IF X_METRIC_TPL_ASSOC_ID IS NULL THEN
        OPEN c_get_mtaid;
        FETCH c_get_mtaid INTO L_METRIC_TPL_ASSOC_ID;
        CLOSE c_get_mtaid;
    ELSE
        L_METRIC_TPL_ASSOC_ID := X_METRIC_TPL_ASSOC_ID;
    END IF ;

    l_obj_verno := 1;

  Insert_Row(
          p_metric_tpl_assoc_id    => l_metric_tpl_assoc_id,
          p_last_update_date    => sysdate,
          p_last_updated_by    => l_user_id,
          p_creation_date    => sysdate,
          p_created_by    => l_user_id,
          p_last_update_login    => 0,
          px_object_version_number   => l_obj_verno,
          p_metric_tpl_header_id    => x_metric_tpl_header_id,
          p_association_type    => x_association_type,
          p_used_by_id    => x_used_by_id,
          p_used_by_code    => x_used_by_code,
          p_enabled_flag    => x_enabled_flag);

ELSE
   CLOSE c_db_data_details;
    if ( l_db_luby_id IN (1, 2, 0)
      OR NVL(x_custom_mode,'PRESERVE') = 'FORCE') THEN
   Update_Row(
          p_metric_tpl_assoc_id    => x_metric_tpl_assoc_id,
          p_last_update_date    => sysdate,
          p_last_updated_by    => l_user_id,
          p_last_update_login    => 0,
          p_object_version_number    => l_obj_verno + 1,
          p_metric_tpl_header_id    => x_metric_tpl_header_id,
          p_association_type    => x_association_type,
          p_used_by_id    => x_used_by_id,
          p_used_by_code    => x_used_by_code,
          p_enabled_flag    => x_enabled_flag);
   END IF;
END IF;
END LOAD_ROW;

END AMS_MET_TPL_ASSOCS_PKG;

/
