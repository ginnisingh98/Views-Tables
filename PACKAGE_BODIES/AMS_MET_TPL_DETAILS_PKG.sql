--------------------------------------------------------
--  DDL for Package Body AMS_MET_TPL_DETAILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_MET_TPL_DETAILS_PKG" AS
/* $Header: amslmtdb.pls 115.12 2003/03/07 22:45:50 dmvincen ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_MET_TPL_DETAILS_PKG
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


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_MET_TPL_DETAILS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amslmtdb.pls';


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
          px_metric_template_detail_id   NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          px_object_version_number   NUMBER,
          p_metric_tpl_header_id    NUMBER,
          p_metric_id    NUMBER,
          p_enabled_flag    VARCHAR2)

 IS
   x_rowid    VARCHAR2(30);


BEGIN


--   px_object_version_number := 1;


   INSERT INTO AMS_MET_TPL_DETAILS(
           metric_template_detail_id,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           last_update_login,
           object_version_number,
           metric_tpl_header_id,
           metric_id,
           enabled_flag
   ) VALUES (
           DECODE( px_metric_template_detail_id, FND_API.g_miss_num, NULL, px_metric_template_detail_id),
           DECODE( p_last_update_date, FND_API.g_miss_date, NULL, p_last_update_date),
           DECODE( p_last_updated_by, FND_API.g_miss_num, NULL, p_last_updated_by),
           DECODE( p_creation_date, FND_API.g_miss_date, NULL, p_creation_date),
           DECODE( p_created_by, FND_API.g_miss_num, NULL, p_created_by),
           DECODE( p_last_update_login, FND_API.g_miss_num, NULL, p_last_update_login),
           1, --DECODE( px_object_version_number, FND_API.g_miss_num, NULL, px_object_version_number),
           DECODE( p_metric_tpl_header_id, FND_API.g_miss_num, NULL, p_metric_tpl_header_id),
           DECODE( p_metric_id, FND_API.g_miss_num, NULL, p_metric_id),
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
          p_metric_template_detail_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_metric_tpl_header_id    NUMBER,
          p_metric_id    NUMBER,
          p_enabled_flag    VARCHAR2)

 IS
 BEGIN
    UPDATE AMS_MET_TPL_DETAILS
    SET
       metric_template_detail_id = DECODE( p_metric_template_detail_id, FND_API.g_miss_num, metric_template_detail_id, p_metric_template_detail_id),
       last_update_date = DECODE( p_last_update_date, FND_API.g_miss_date, last_update_date, p_last_update_date),
       last_updated_by = DECODE( p_last_updated_by, FND_API.g_miss_num, last_updated_by, p_last_updated_by),
       last_update_login = DECODE( p_last_update_login, FND_API.g_miss_num, last_update_login, p_last_update_login),
       object_version_number = DECODE( p_object_version_number, FND_API.g_miss_num, object_version_number, p_object_version_number),
       metric_tpl_header_id = DECODE( p_metric_tpl_header_id, FND_API.g_miss_num, metric_tpl_header_id, p_metric_tpl_header_id),
       metric_id = DECODE( p_metric_id, FND_API.g_miss_num, metric_id, p_metric_id),
       enabled_flag = DECODE( p_enabled_flag, FND_API.g_miss_char, enabled_flag, p_enabled_flag)
   WHERE METRIC_TEMPLATE_DETAIL_ID = p_METRIC_TEMPLATE_DETAIL_ID;
--   AND   object_version_number = p_object_version_number;

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
    p_METRIC_TEMPLATE_DETAIL_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM AMS_MET_TPL_DETAILS
    WHERE METRIC_TEMPLATE_DETAIL_ID = p_METRIC_TEMPLATE_DETAIL_ID;
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
          p_metric_template_detail_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_metric_tpl_header_id    NUMBER,
          p_metric_id    NUMBER,
          p_enabled_flag    VARCHAR2)

 IS
   CURSOR C IS
        SELECT *
         FROM AMS_MET_TPL_DETAILS
        WHERE METRIC_TEMPLATE_DETAIL_ID =  p_METRIC_TEMPLATE_DETAIL_ID
        FOR UPDATE OF METRIC_TEMPLATE_DETAIL_ID NOWAIT;
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
           (      Recinfo.metric_template_detail_id = p_metric_template_detail_id)
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
       AND (    ( Recinfo.metric_id = p_metric_id)
            OR (    ( Recinfo.metric_id IS NULL )
                AND (  p_metric_id IS NULL )))
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
        X_METRIC_TEMPLATE_DETAIL_ID IN NUMBER,
        X_OBJECT_VERSION_NUMBER IN NUMBER,
        X_METRIC_TPL_HEADER_ID IN NUMBER,
        X_METRIC_ID IN NUMBER,
        X_ENABLED_FLAG IN VARCHAR2,
        X_Owner   IN VARCHAR2,
        X_CUSTOM_MODE IN VARCHAR2
        )
IS
l_user_id   NUMBER := 0;
l_obj_verno  NUMBER;
l_row_id    VARCHAR2(100);
l_metric_template_detail_id   NUMBER;
l_db_luby_id NUMBER;

CURSOR  c_db_data_details IS
  SELECT last_updated_by, object_version_number
  FROM    AMS_MET_TPL_DETAILS
  WHERE  METRIC_TEMPLATE_DETAIL_ID =  X_METRIC_TEMPLATE_DETAIL_ID;

CURSOR c_get_mtdid IS
   SELECT AMS_MET_TPL_DETAILS_S.NEXTVAL
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

    IF x_metric_template_detail_id IS NULL THEN
        OPEN c_get_mtdid;
        FETCH c_get_mtdid INTO l_metric_template_detail_id;
        CLOSE c_get_mtdid;
    ELSE
        l_metric_template_detail_id := x_metric_template_detail_id;
    END IF ;

    l_obj_verno := 1;

  Insert_Row(
          px_metric_template_detail_id   => l_metric_template_detail_id,
          p_last_update_date    => sysdate,
          p_last_updated_by    => l_user_id,
          p_creation_date    => sysdate,
          p_created_by    => l_user_id,
          p_last_update_login    => 0,
          px_object_version_number   => l_obj_verno,
          p_metric_tpl_header_id    => x_METRIC_TPL_HEADER_ID,
          p_metric_id    => X_METRIC_ID,
          p_enabled_flag    => X_ENABLED_FLAG);

ELSE
   CLOSE c_db_data_details;
    if ( l_db_luby_id IN (1, 2, 0)
      OR NVL(x_custom_mode,'PRESERVE') = 'FORCE') THEN
   Update_Row(
          p_metric_template_detail_id    => x_metric_template_detail_id,
          p_last_update_date    => sysdate,
          p_last_updated_by    => l_user_id,
          p_last_update_login    => 0,
          p_object_version_number    => l_obj_verno + 1,
          p_metric_tpl_header_id    => x_metric_tpl_header_id,
          p_metric_id    => x_metric_id,
          p_enabled_flag    => x_enabled_flag);
   END IF;
END IF;
END LOAD_ROW;

END Ams_Met_Tpl_Details_Pkg;

/
