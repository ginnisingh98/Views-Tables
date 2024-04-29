--------------------------------------------------------
--  DDL for Package Body AMS_DM_MODELS_B_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_DM_MODELS_B_PKG" as
/* $Header: amstdmmb.pls 115.18 2002/12/09 11:07:06 choang noship $ */
-- Start of Comments
-- Package name     : ams_dm_models_b_PKG
-- Purpose          : PACKAGE BODY FOR TABLE HANDLER
-- History          : 11/10/00  JIE LI  CREATED
-- 26-Jan-2001 choang   Removed increment of object ver num in update.
-- 02-Feb-2001 choang   Update was not taking object ver num from param.
-- 08-Feb-2001 choang   Changed all IN/OUT params to IN.
-- 16-Feb-2001 choang   Replaced top_down_flag with row_selection_type.
-- 23-Feb-2001 choang   Defaulted row_selection_type to STANDARD.
-- 26-Feb-2001 choang   Added custom_setup_id, country_id, best_subtree
-- 08-Mar-2001 choang   Added wf_itemkey
-- 18-Mar-2001 choang   Added add_language, load_row, translate_row; changed
--                      obj ver logic in update.
-- 01-Feb-2002 choang   Removed created by in update api
-- 18-Mar-2002 choang   Added checkfile to dbdrv
-- 23-Apr-2002 choang   Added target_id
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'ams_dm_models_b_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amstmmsb.pls';

AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Insert_Row(
   p_model_id           IN NUMBER,
   p_last_update_date   DATE,
   p_last_updated_by    NUMBER,
   p_creation_date      DATE,
   p_created_by         NUMBER,
   p_last_update_login  NUMBER,
   p_object_version_number IN NUMBER,
   p_model_type         VARCHAR2,
   p_user_status_id     NUMBER,
   p_status_code        IN VARCHAR2,
   p_status_date        DATE,
   p_last_build_date    DATE,
   p_owner_user_id      NUMBER,
   p_performance        NUMBER,
   p_target_group_type  VARCHAR2,
   p_darwin_model_ref   VARCHAR2,
   p_model_name         VARCHAR2,
   p_description        VARCHAR2,
   p_scheduled_date     DATE,
   p_scheduled_timezone_id NUMBER,
   p_expiration_date    DATE,
   p_results_flag       VARCHAR2,
   p_logs_flag          VARCHAR2,
   p_target_field       VARCHAR2,
   p_target_type        VARCHAR2,
   p_target_positive_value VARCHAR2,
   p_total_records      NUMBER,
   p_total_positives    NUMBER,
   p_min_records        NUMBER,
   p_max_records        NUMBER,
   p_row_selection_type VARCHAR2,
   p_every_nth_row      NUMBER,
   p_pct_random         NUMBER,
   p_best_subtree       NUMBER,
   p_custom_setup_id    NUMBER,
   p_country_id         NUMBER,
   p_wf_itemkey         VARCHAR2,
   p_target_id          NUMBER,
   p_attribute_category VARCHAR2,
   p_attribute1         VARCHAR2,
   p_attribute2         VARCHAR2,
   p_attribute3         VARCHAR2,
   p_attribute4         VARCHAR2,
   p_attribute5         VARCHAR2,
   p_attribute6         VARCHAR2,
   p_attribute7         VARCHAR2,
   p_attribute8         VARCHAR2,
   p_attribute9         VARCHAR2,
   p_attribute10        VARCHAR2,
   p_attribute11        VARCHAR2,
   p_attribute12        VARCHAR2,
   p_attribute13        VARCHAR2,
   p_attribute14        VARCHAR2,
   p_attribute15        VARCHAR2
)
IS
   L_DEFAULT_SELECTION_TYPE   CONSTANT VARCHAR2(30) := 'STANDARD';

BEGIN
   INSERT INTO ams_dm_models_all_b(
      model_id,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login,
      object_version_number,
      model_type,
      user_status_id,
      status_code,
      status_date,
      last_build_date,
      owner_user_id,
      performance,
      target_group_type,
      darwin_model_ref,
      scheduled_date,
      scheduled_timezone_id,
      expiration_date,
      results_flag,
      logs_flag,
      target_field,
      target_type,
      target_positive_value,
      total_records,
      total_positives,
      min_records,
      max_records,
      row_selection_type,
      every_nth_row,
      pct_random,
      best_subtree,
      custom_setup_id,
      country_id,
      wf_itemkey,
      target_id,
      attribute_category,
      attribute1 ,
      attribute2 ,
      attribute3 ,
      attribute4 ,
      attribute5 ,
      attribute6 ,
      attribute7 ,
      attribute8 ,
      attribute9 ,
      attribute10,
      attribute11,
      attribute12,
      attribute13 ,
      attribute14 ,
      attribute15
   ) VALUES (
      DECODE( p_MODEL_ID, FND_API.G_MISS_NUM, NULL, p_MODEL_ID),
      DECODE( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, NULL, p_LAST_UPDATE_DATE),
      DECODE( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATED_BY),
      DECODE( p_CREATION_DATE, FND_API.G_MISS_DATE, NULL, p_CREATION_DATE),
      DECODE( p_CREATED_BY, FND_API.G_MISS_NUM, NULL, p_CREATED_BY),
      DECODE( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATE_LOGIN),
      DECODE( p_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, 1, p_OBJECT_VERSION_NUMBER),
      DECODE( p_MODEL_TYPE, FND_API.G_MISS_CHAR, NULL, p_MODEL_TYPE),
      DECODE( p_USER_STATUS_ID, FND_API.G_MISS_NUM, NULL, p_USER_STATUS_ID),
      DECODE( p_STATUS_CODE, FND_API.G_MISS_CHAR, NULL, p_STATUS_CODE),
      DECODE( p_STATUS_DATE, FND_API.G_MISS_CHAR, NULL, p_STATUS_DATE),
      DECODE( p_LAST_BUILD_DATE, FND_API.G_MISS_DATE, NULL, p_LAST_BUILD_DATE),
      DECODE( p_OWNER_USER_ID, FND_API.G_MISS_NUM, NULL, p_OWNER_USER_ID),
      DECODE( p_PERFORMANCE, FND_API.G_MISS_NUM, NULL, p_PERFORMANCE),
      DECODE( p_TARGET_GROUP_TYPE, FND_API.G_MISS_CHAR, NULL, p_TARGET_GROUP_TYPE),
      DECODE( p_DARWIN_MODEL_REF, FND_API.G_MISS_CHAR, NULL, p_DARWIN_MODEL_REF),
      DECODE( p_SCHEDULED_DATE, FND_API.G_MISS_DATE,NULL, p_SCHEDULED_DATE),
      DECODE( p_SCHEDULED_TIMEZONE_ID, FND_API.G_MISS_NUM, NULL, p_SCHEDULED_TIMEZONE_ID),
      DECODE( p_EXPIRATION_DATE, FND_API.G_MISS_DATE,NULL, p_EXPIRATION_DATE),
      DECODE( p_RESULTS_FLAG, FND_API.G_MISS_CHAR, 'N', p_RESULTS_FLAG),
      DECODE( p_LOGS_FLAG, FND_API.g_miss_char, 'N', p_LOGS_FLAG),
      DECODE( p_TARGET_FIELD, FND_API.g_miss_char, NULL, p_TARGET_FIELD),
      DECODE( p_TARGET_TYPE, FND_API.g_miss_char, NULL, p_TARGET_TYPE),
      DECODE( p_TARGET_POSITIVE_VALUE, FND_API.g_miss_char, NULL, p_TARGET_POSITIVE_VALUE),
      DECODE( p_TOTAL_RECORDS, FND_API.g_miss_num, NULL, p_TOTAL_RECORDS),
      DECODE( p_TOTAL_POSITIVES, FND_API.g_miss_num, NULL, p_TOTAL_POSITIVES),
      DECODE( p_MIN_RECORDS, FND_API.g_miss_num, NULL, p_MIN_RECORDS),
      DECODE( p_MAX_RECORDS, FND_API.g_miss_num, NULL, p_MAX_RECORDS),
      DECODE( p_row_selection_type, FND_API.g_miss_char, L_DEFAULT_SELECTION_TYPE, p_row_selection_type),
      DECODE( p_EVERY_NTH_ROW, FND_API.g_miss_num, NULL, p_EVERY_NTH_ROW),
      DECODE( p_PCT_RANDOM, FND_API.g_miss_num, NULL, p_PCT_RANDOM),
      DECODE( p_best_subtree, FND_API.g_miss_num, NULL, p_best_subtree),
      DECODE( p_custom_setup_id, FND_API.g_miss_num, NULL, p_custom_setup_id),
      DECODE( p_country_id, FND_API.g_miss_num, NULL, p_country_id),
      DECODE( p_wf_itemkey, FND_API.G_MISS_CHAR, NULL, p_wf_itemkey),
      DECODE( p_target_id, FND_API.G_MISS_CHAR, NULL, p_target_id),
      DECODE( p_ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE_CATEGORY),
      DECODE( p_ATTRIBUTE1, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE1),
      DECODE( p_ATTRIBUTE2, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE2),
      DECODE( p_ATTRIBUTE2, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE3),
      DECODE( p_ATTRIBUTE2, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE4),
      DECODE( p_ATTRIBUTE2, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE5),
      DECODE( p_ATTRIBUTE2, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE6),
      DECODE( p_ATTRIBUTE2, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE7),
      DECODE( p_ATTRIBUTE2, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE8),
      DECODE( p_ATTRIBUTE2, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE9),
      DECODE( p_ATTRIBUTE2, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE10),
      DECODE( p_ATTRIBUTE2, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE11),
      DECODE( p_ATTRIBUTE2, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE12),
      DECODE( p_ATTRIBUTE2, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE13),
      DECODE( p_ATTRIBUTE2, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE14),
      DECODE( p_ATTRIBUTE2, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE15)
   );

   INSERT INTO ams_dm_models_all_tl(
      model_id,
      language,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login,
      source_lang,
      model_name,
      description
   )
   SELECT
      decode( p_MODEL_ID, FND_API.G_MISS_NUM, NULL, p_MODEL_ID),
      l.language_code,
      SYSDATE,
      FND_GLOBAL.user_id,
      SYSDATE,
      FND_GLOBAL.user_id,
      FND_GLOBAL.conc_login_id,
      USERENV('LANG'),
      decode( p_MODEL_NAME, FND_API.G_MISS_CHAR, NULL, p_MODEL_NAME),
      decode( p_DESCRIPTION, FND_API.G_MISS_CHAR, NULL, p_DESCRIPTION)
   FROM fnd_languages l
   WHERE l.installed_flag in ('I', 'B')
   AND NOT EXISTS(
         SELECT NULL
         FROM ams_dm_models_all_tl t
         WHERE t.model_id = decode( p_MODEL_ID, FND_API.G_MISS_NUM, NULL, p_MODEL_ID)
         AND t.language = l.language_code );

End Insert_Row;

PROCEDURE Update_Row(
   p_model_id              NUMBER,
   p_last_update_date      DATE,
   p_last_updated_by       NUMBER,
   p_last_update_login     NUMBER,
   p_object_version_number NUMBER,
   p_model_type            VARCHAR2,
   p_user_status_id        NUMBER,
   p_status_code           VARCHAR2,
   p_status_date           DATE,
   p_last_build_date       DATE,
   p_owner_user_id         NUMBER,
   p_performance           NUMBER,
   p_target_group_type     VARCHAR2,
   p_darwin_model_ref      VARCHAR2,
   p_model_name            VARCHAR2,
   p_description           VARCHAR2,
   p_scheduled_date        DATE,
   p_scheduled_timezone_id NUMBER,
   p_expiration_date       DATE,
   p_results_flag          VARCHAR2,
   p_logs_flag             VARCHAR2,
   p_target_field          VARCHAR2,
   p_target_type           VARCHAR2,
   p_target_positive_value VARCHAR2,
   p_total_records         NUMBER,
   p_total_positives       NUMBER,
   p_min_records           NUMBER,
   p_max_records           NUMBER,
   p_row_selection_type    VARCHAR2,
   p_every_nth_row         NUMBER,
   p_pct_random            NUMBER,
   p_best_subtree          NUMBER,
   p_custom_setup_id       NUMBER,
   p_country_id            NUMBER,
   p_wf_itemkey            VARCHAR2,
   p_target_id             NUMBER,
   p_attribute_category    VARCHAR2,
   p_attribute1            VARCHAR2,
   p_attribute2            VARCHAR2,
   p_attribute3            VARCHAR2,
   p_attribute4            VARCHAR2,
   p_attribute5            VARCHAR2,
   p_attribute6            VARCHAR2,
   p_attribute7            VARCHAR2,
   p_attribute8            VARCHAR2,
   p_attribute9            VARCHAR2,
   p_attribute10           VARCHAR2,
   p_attribute11           VARCHAR2,
   p_attribute12           VARCHAR2,
   p_attribute13           VARCHAR2,
   p_attribute14           VARCHAR2,
   p_attribute15           VARCHAR2
)
IS
BEGIN
   Update ams_dm_models_all_b
   SET
      MODEL_ID = decode( p_MODEL_ID, FND_API.G_MISS_NUM, MODEL_ID, p_MODEL_ID),
      LAST_UPDATE_DATE = decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, LAST_UPDATE_DATE, p_LAST_UPDATE_DATE),
      LAST_UPDATED_BY = decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, LAST_UPDATED_BY, p_LAST_UPDATED_BY),
      LAST_UPDATE_LOGIN = decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, LAST_UPDATE_LOGIN, p_LAST_UPDATE_LOGIN),
      object_version_number = object_version_number + 1,
      MODEL_TYPE = decode( p_MODEL_TYPE, FND_API.G_MISS_CHAR, MODEL_TYPE, p_MODEL_TYPE),
      USER_STATUS_ID = decode( p_USER_STATUS_ID, FND_API.G_MISS_NUM, USER_STATUS_ID, p_USER_STATUS_ID),
      STATUS_CODE = decode( p_STATUS_CODE, FND_API.G_MISS_CHAR, STATUS_CODE, p_STATUS_CODE),
      STATUS_DATE = decode( p_STATUS_DATE, FND_API.G_MISS_CHAR, STATUS_DATE, p_STATUS_DATE),
      LAST_BUILD_DATE = decode( p_LAST_BUILD_DATE, FND_API.G_MISS_DATE, LAST_BUILD_DATE, p_LAST_BUILD_DATE),
      OWNER_USER_ID = decode( p_OWNER_USER_ID, FND_API.G_MISS_NUM, OWNER_USER_ID, p_OWNER_USER_ID),
      PERFORMANCE = decode( p_PERFORMANCE, FND_API.G_MISS_NUM, PERFORMANCE, p_PERFORMANCE),
      TARGET_GROUP_TYPE = decode( p_TARGET_GROUP_TYPE, FND_API.G_MISS_CHAR, TARGET_GROUP_TYPE, p_TARGET_GROUP_TYPE),
      DARWIN_MODEL_REF = decode( p_DARWIN_MODEL_REF, FND_API.G_MISS_CHAR, DARWIN_MODEL_REF, p_DARWIN_MODEL_REF),
      SCHEDULED_DATE = decode( p_SCHEDULED_DATE, FND_API.G_MISS_DATE,SCHEDULED_DATE, p_SCHEDULED_DATE),
      SCHEDULED_TIMEZONE_ID = decode( p_SCHEDULED_TIMEZONE_ID, FND_API.G_MISS_NUM, SCHEDULED_TIMEZONE_ID, p_SCHEDULED_TIMEZONE_ID),
      EXPIRATION_DATE = decode( p_EXPIRATION_DATE, FND_API.G_MISS_DATE,EXPIRATION_DATE, p_EXPIRATION_DATE),
      RESULTS_FLAG = decode( p_RESULTS_FLAG, FND_API.G_MISS_CHAR,RESULTS_FLAG, p_RESULTS_FLAG),
      LOGS_FLAG = decode( p_LOGS_FLAG, FND_API.g_miss_char, LOGS_FLAG, p_LOGS_FLAG),
      TARGET_FIELD = decode( p_TARGET_FIELD, FND_API.g_miss_char, TARGET_FIELD, p_TARGET_FIELD),
      TARGET_TYPE = decode( p_TARGET_TYPE, FND_API.g_miss_char, TARGET_TYPE, p_TARGET_TYPE),
      TARGET_POSITIVE_VALUE = decode( p_TARGET_POSITIVE_VALUE, FND_API.g_miss_char, TARGET_POSITIVE_VALUE, p_TARGET_POSITIVE_VALUE),
      TOTAL_RECORDS = decode( p_TOTAL_RECORDS, FND_API.g_miss_num, TOTAL_RECORDS, p_TOTAL_RECORDS),
      TOTAL_POSITIVES = decode( p_TOTAL_POSITIVES, FND_API.g_miss_num, TOTAL_POSITIVES, p_TOTAL_POSITIVES),
      MIN_RECORDS = decode( p_MIN_RECORDS, FND_API.g_miss_num, MIN_RECORDS, p_MIN_RECORDS),
      MAX_RECORDS = decode( p_MAX_RECORDS, FND_API.g_miss_num, MAX_RECORDS, p_MAX_RECORDS),
      row_selection_type = decode( p_row_selection_type, FND_API.g_miss_char, row_selection_type, p_row_selection_type),
      EVERY_NTH_ROW = decode( p_EVERY_NTH_ROW, FND_API.g_miss_num, EVERY_NTH_ROW, p_EVERY_NTH_ROW),
      PCT_RANDOM = decode( p_PCT_RANDOM, FND_API.g_miss_num, PCT_RANDOM, p_PCT_RANDOM),
      best_subtree = DECODE( p_best_subtree, FND_API.g_miss_num, best_subtree, p_best_subtree),
      custom_setup_id = DECODE( p_custom_setup_id, FND_API.g_miss_num, custom_setup_id, p_custom_setup_id),
      country_id = DECODE( p_country_id, FND_API.g_miss_num, country_id, p_country_id),
      wf_itemkey = decode( p_wf_itemkey, FND_API.g_miss_char, wf_itemkey, p_wf_itemkey),
      target_id = decode( p_target_id, FND_API.g_miss_char, target_id, p_target_id),
      ATTRIBUTE_CATEGORY = decode( p_ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR,ATTRIBUTE_CATEGORY, p_ATTRIBUTE_CATEGORY),
      ATTRIBUTE1 = decode( p_ATTRIBUTE1, FND_API.G_MISS_CHAR,ATTRIBUTE1, p_ATTRIBUTE1),
      ATTRIBUTE2 = decode( p_ATTRIBUTE1, FND_API.G_MISS_CHAR,ATTRIBUTE2, p_ATTRIBUTE2),
      ATTRIBUTE3 = decode( p_ATTRIBUTE1, FND_API.G_MISS_CHAR,ATTRIBUTE3, p_ATTRIBUTE3),
      ATTRIBUTE4 = decode( p_ATTRIBUTE1, FND_API.G_MISS_CHAR,ATTRIBUTE4, p_ATTRIBUTE4),
      ATTRIBUTE5 = decode( p_ATTRIBUTE1, FND_API.G_MISS_CHAR,ATTRIBUTE5, p_ATTRIBUTE5),
      ATTRIBUTE6 = decode( p_ATTRIBUTE1, FND_API.G_MISS_CHAR,ATTRIBUTE6, p_ATTRIBUTE6),
      ATTRIBUTE7 = decode( p_ATTRIBUTE1, FND_API.G_MISS_CHAR,ATTRIBUTE7, p_ATTRIBUTE7),
      ATTRIBUTE8 = decode( p_ATTRIBUTE1, FND_API.G_MISS_CHAR,ATTRIBUTE8, p_ATTRIBUTE8),
      ATTRIBUTE9 = decode( p_ATTRIBUTE1, FND_API.G_MISS_CHAR,ATTRIBUTE9, p_ATTRIBUTE9),
      ATTRIBUTE10 = decode( p_ATTRIBUTE1, FND_API.G_MISS_CHAR,ATTRIBUTE10, p_ATTRIBUTE10),
      ATTRIBUTE11 = decode( p_ATTRIBUTE1, FND_API.G_MISS_CHAR,ATTRIBUTE11, p_ATTRIBUTE11),
      ATTRIBUTE12 = decode( p_ATTRIBUTE1, FND_API.G_MISS_CHAR,ATTRIBUTE12, p_ATTRIBUTE12),
      ATTRIBUTE13 = decode( p_ATTRIBUTE1, FND_API.G_MISS_CHAR,ATTRIBUTE13, p_ATTRIBUTE13),
      ATTRIBUTE14 = decode( p_ATTRIBUTE1, FND_API.G_MISS_CHAR,ATTRIBUTE14, p_ATTRIBUTE14),
      ATTRIBUTE15 = decode( p_ATTRIBUTE1, FND_API.G_MISS_CHAR,ATTRIBUTE15, p_ATTRIBUTE15)
   WHERE MODEL_ID = p_MODEL_ID
   AND object_version_number = p_object_version_number;
   IF SQL%NOTFOUND THEN
      -- the calling program should catch no_data_found
      -- and treat it as a mismatch in object version
      -- number.
      RAISE NO_DATA_FOUND;
   END IF;

   update ams_dm_models_all_tl set
      model_name = decode( p_MODEL_NAME, FND_API.G_MISS_CHAR, MODEL_NAME, p_MODEL_NAME),
      description = decode( p_DESCRIPTION, FND_API.G_MISS_CHAR, DESCRIPTION, p_DESCRIPTION),
      last_update_date = SYSDATE,
      last_updated_by = FND_GLOBAL.user_id,
      last_update_login = FND_GLOBAL.conc_login_id,
      source_lang = USERENV('LANG')
   WHERE model_id = p_MODEL_ID
   AND USERENV('LANG') IN (language, source_lang);

END Update_Row;

PROCEDURE Delete_Row(
    p_MODEL_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM ams_dm_models_all_b
    WHERE MODEL_ID = p_MODEL_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;

   DELETE FROM ams_dm_models_all_tl
    WHERE MODEL_ID = p_MODEL_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;

 END Delete_Row;

PROCEDURE Lock_Row(
   p_MODEL_ID    NUMBER,
   p_LAST_UPDATE_DATE    DATE,
   p_LAST_UPDATED_BY    NUMBER,
   p_CREATION_DATE    DATE,
   p_CREATED_BY    NUMBER,
   p_LAST_UPDATE_LOGIN    NUMBER,
   p_OBJECT_VERSION_NUMBER    NUMBER,
   p_MODEL_TYPE    VARCHAR2,
   p_USER_STATUS_ID    NUMBER,
   p_STATUS_CODE    VARCHAR2,
   p_STATUS_DATE    DATE,
   p_LAST_BUILD_DATE    DATE,
   p_OWNER_USER_ID    NUMBER,
   p_PERFORMANCE    NUMBER,
   p_TARGET_GROUP_TYPE    VARCHAR2,
   p_DARWIN_MODEL_REF    VARCHAR2,
   p_SCHEDULED_DATE   DATE,
   p_SCHEDULED_TIMEZONE_ID   NUMBER,
   p_EXPIRATION_DATE  DATE,
   p_RESULTS_FLAG        VARCHAR2,
   p_ATTRIBUTE_CATEGORY  VARCHAR2,
   p_ATTRIBUTE1          VARCHAR2,
   p_ATTRIBUTE2          VARCHAR2,
   p_ATTRIBUTE3          VARCHAR2,
   p_ATTRIBUTE4          VARCHAR2,
   p_ATTRIBUTE5          VARCHAR2,
   p_ATTRIBUTE6          VARCHAR2,
   p_ATTRIBUTE7          VARCHAR2,
   p_ATTRIBUTE8          VARCHAR2,
   p_ATTRIBUTE9          VARCHAR2,
   p_ATTRIBUTE10         VARCHAR2,
   p_ATTRIBUTE11         VARCHAR2,
   p_ATTRIBUTE12         VARCHAR2,
   p_ATTRIBUTE13         VARCHAR2,
   p_ATTRIBUTE14         VARCHAR2,
   p_ATTRIBUTE15         VARCHAR2
)

 IS
   CURSOR C IS
        SELECT *
         FROM ams_dm_models_all_b
        WHERE MODEL_ID =  p_MODEL_ID
        FOR UPDATE of MODEL_ID NOWAIT;
   Recinfo C%ROWTYPE;
 BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    If (C%NOTFOUND) then
        CLOSE C;
        FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
        APP_EXCEPTION.RAISE_EXCEPTION;
    End If;
    CLOSE C;
    if (
           (      Recinfo.MODEL_ID = p_MODEL_ID)
       AND (    ( Recinfo.LAST_UPDATE_DATE = p_LAST_UPDATE_DATE)
            OR (    ( Recinfo.LAST_UPDATE_DATE IS NULL )
                AND (  p_LAST_UPDATE_DATE IS NULL )))
       AND (    ( Recinfo.LAST_UPDATED_BY = p_LAST_UPDATED_BY)
            OR (    ( Recinfo.LAST_UPDATED_BY IS NULL )
                AND (  p_LAST_UPDATED_BY IS NULL )))
       AND (    ( Recinfo.CREATION_DATE = p_CREATION_DATE)
            OR (    ( Recinfo.CREATION_DATE IS NULL )
                AND (  p_CREATION_DATE IS NULL )))
       AND (    ( Recinfo.CREATED_BY = p_CREATED_BY)
            OR (    ( Recinfo.CREATED_BY IS NULL )
                AND (  p_CREATED_BY IS NULL )))
       AND (    ( Recinfo.LAST_UPDATE_LOGIN = p_LAST_UPDATE_LOGIN)
            OR (    ( Recinfo.LAST_UPDATE_LOGIN IS NULL )
                AND (  p_LAST_UPDATE_LOGIN IS NULL )))
       AND (    ( Recinfo.OBJECT_VERSION_NUMBER = p_OBJECT_VERSION_NUMBER)
            OR (    ( Recinfo.OBJECT_VERSION_NUMBER IS NULL )
                AND (  p_OBJECT_VERSION_NUMBER IS NULL )))
       AND (    ( Recinfo.MODEL_TYPE = p_MODEL_TYPE)
            OR (    ( Recinfo.MODEL_TYPE IS NULL )
                AND (  p_MODEL_TYPE IS NULL )))
       AND (    ( Recinfo.USER_STATUS_ID = p_USER_STATUS_ID)
            OR (    ( Recinfo.USER_STATUS_ID IS NULL )
                AND (  p_USER_STATUS_ID IS NULL )))
       AND (    ( Recinfo.STATUS_CODE = p_STATUS_CODE)
            OR (    ( Recinfo.STATUS_CODE IS NULL )
                AND (  p_STATUS_CODE IS NULL )))
       AND (    ( Recinfo.STATUS_DATE = p_STATUS_DATE)
            OR (    ( Recinfo.STATUS_DATE IS NULL )
                AND (  p_STATUS_DATE IS NULL )))
       AND (    ( Recinfo.LAST_BUILD_DATE = p_LAST_BUILD_DATE)
            OR (    ( Recinfo.LAST_BUILD_DATE IS NULL )
                AND (  p_LAST_BUILD_DATE IS NULL )))
       AND (    ( Recinfo.OWNER_USER_ID = p_OWNER_USER_ID)
            OR (    ( Recinfo.OWNER_USER_ID IS NULL )
                AND (  p_OWNER_USER_ID IS NULL )))
       AND (    ( Recinfo.PERFORMANCE = p_PERFORMANCE)
            OR (    ( Recinfo.PERFORMANCE IS NULL )
                AND (  p_PERFORMANCE IS NULL )))
       AND (    ( Recinfo.TARGET_GROUP_TYPE = p_TARGET_GROUP_TYPE)
            OR (    ( Recinfo.TARGET_GROUP_TYPE IS NULL )
                AND (  p_TARGET_GROUP_TYPE IS NULL )))
       AND (    ( Recinfo.DARWIN_MODEL_REF = p_DARWIN_MODEL_REF)
            OR (    ( Recinfo.DARWIN_MODEL_REF IS NULL )
                AND (  p_DARWIN_MODEL_REF IS NULL )))
       ) then
       return;
   else
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   End If;
END Lock_Row;


PROCEDURE add_language
IS
BEGIN
  delete from AMS_DM_MODELS_ALL_TL T
  where not exists
    (select NULL
    from AMS_DM_MODELS_ALL_B B
    where B.MODEL_ID = T.MODEL_ID
    );

  update AMS_DM_MODELS_ALL_TL T set (
      MODEL_NAME,
      DESCRIPTION
    ) = (select
      B.MODEL_NAME,
      B.DESCRIPTION
    from AMS_DM_MODELS_ALL_TL B
    where B.MODEL_ID = T.MODEL_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.MODEL_ID,
      T.LANGUAGE
  ) in (select
      SUBT.MODEL_ID,
      SUBT.LANGUAGE
    from AMS_DM_MODELS_ALL_TL SUBB, AMS_DM_MODELS_ALL_TL SUBT
    where SUBB.MODEL_ID = SUBT.MODEL_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.MODEL_NAME <> SUBT.MODEL_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into AMS_DM_MODELS_ALL_TL (
    MODEL_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    MODEL_NAME,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.MODEL_ID,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.MODEL_NAME,
    B.DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from AMS_DM_MODELS_ALL_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AMS_DM_MODELS_ALL_TL T
    where T.MODEL_ID = B.MODEL_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
END add_language;

PROCEDURE translate_row (
   x_model_id IN NUMBER,
   x_model_name IN VARCHAR2,
   x_description IN VARCHAR2,
   x_owner IN VARCHAR2
)
IS
BEGIN
    update ams_dm_models_all_tl set
       model_name = nvl(x_model_name, model_name),
       description = nvl(x_description, description),
       source_lang = userenv('LANG'),
       last_update_date = sysdate,
       last_updated_by = decode(x_owner, 'SEED', 1, 0),
       last_update_login = 0
    where  model_id = x_model_id
    and      userenv('LANG') in (language, source_lang);
end TRANSLATE_ROW;


PROCEDURE load_row (
   x_model_id           IN NUMBER,
   x_model_type         VARCHAR2,
   x_user_status_id     NUMBER,
   x_status_code        IN VARCHAR2,
   x_status_date        DATE,
   x_last_build_date    DATE,
   x_owner_user_id      NUMBER,
   x_performance        NUMBER,
   x_target_group_type  VARCHAR2,
   x_darwin_model_ref   VARCHAR2,
   x_model_name         VARCHAR2,
   x_description        VARCHAR2,
   x_scheduled_date     DATE,
   x_scheduled_timezone_id NUMBER,
   x_expiration_date    DATE,
   x_results_flag       VARCHAR2,
   x_logs_flag          VARCHAR2,
   x_target_field       VARCHAR2,
   x_target_type        VARCHAR2,
   x_target_positive_value VARCHAR2,
   x_total_records      NUMBER,
   x_total_positives    NUMBER,
   x_min_records        NUMBER,
   x_max_records        NUMBER,
   x_row_selection_type VARCHAR2,
   x_every_nth_row      NUMBER,
   x_pct_random         NUMBER,
   x_best_subtree       NUMBER,
   x_custom_setup_id    NUMBER,
   x_country_id         NUMBER,
   x_wf_itemkey         VARCHAR2,
   x_target_id          NUMBER,
   x_attribute_category VARCHAR2,
   x_attribute1         VARCHAR2,
   x_attribute2         VARCHAR2,
   x_attribute3         VARCHAR2,
   x_attribute4         VARCHAR2,
   x_attribute5         VARCHAR2,
   x_attribute6         VARCHAR2,
   x_attribute7         VARCHAR2,
   x_attribute8         VARCHAR2,
   x_attribute9         VARCHAR2,
   x_attribute10        VARCHAR2,
   x_attribute11        VARCHAR2,
   x_attribute12        VARCHAR2,
   x_attribute13        VARCHAR2,
   x_attribute14        VARCHAR2,
   x_attribute15        VARCHAR2,
   x_owner              VARCHAR2
)
IS
   l_user_id      number := 0;
   l_obj_verno    number;
   l_dummy_char   varchar2(1);
   l_row_id       varchar2(100);
   l_model_id     number;

   cursor  c_obj_verno is
     select object_version_number
     from    ams_dm_models_all_b
     where  model_id =  x_model_id;

   cursor c_chk_model_exists is
     select 'x'
     from   ams_dm_models_all_b
     where  model_id = x_model_id;

   cursor c_get_model_id is
      select ams_dm_models_all_b_s.nextval
      from dual;
BEGIN
   if X_OWNER = 'SEED' then
      l_user_id := 1;
   end if;

   open c_chk_model_exists;
   fetch c_chk_model_exists into l_dummy_char;
   if c_chk_model_exists%notfound THEN
      if x_model_id is null then
         open c_get_model_id;
         fetch c_get_model_id into l_model_id;
         close c_get_model_id;
      else
         l_model_id := x_model_id;
      end if;
      l_obj_verno := 1;
      ams_dm_models_b_pkg.INSERT_ROW (
         p_model_id        => l_model_id,
         p_last_update_date   => SYSDATE,
         p_last_updated_by => l_user_id,
         p_creation_date   => SYSDATE,
         p_created_by      => l_user_id,
         p_last_update_login  => 0,
         p_object_version_number => l_obj_verno,
         p_model_type      => x_model_type,
         p_user_status_id  => x_user_status_id,
         p_status_code     => x_status_code,
         p_status_date     => x_status_date,
         p_last_build_date => x_last_build_date,
         p_owner_user_id   => x_owner_user_id,
         p_scheduled_date  => x_scheduled_date,
         p_scheduled_timezone_id => x_scheduled_timezone_id,
         p_expiration_date => x_expiration_date,
         p_custom_setup_id => x_custom_setup_id,
         p_country_id      => x_country_id,
         p_results_flag    => x_results_flag,
         p_logs_flag       => x_logs_flag,
         p_total_records   => x_total_records,
         p_total_positives => x_total_positives,
         p_target_field    => x_target_field,
         p_target_type     => x_target_type,
         p_target_positive_value => x_target_positive_value,
         p_min_records     => x_min_records,
         p_max_records     => x_max_records,
         p_row_selection_type => x_row_selection_type,
         p_every_nth_row   => x_every_nth_row,
         p_pct_random      => x_pct_random,
         p_performance     => x_performance,
         p_target_group_type  => x_target_group_type,
         p_best_subtree    => x_best_subtree,
         p_wf_itemkey      => x_wf_itemkey,
         p_target_id       => x_target_id,
         p_darwin_model_ref   => x_darwin_model_ref,
         p_attribute_category => x_attribute_category,
         p_attribute1      => x_attribute1,
         p_attribute2      => x_attribute2,
         p_attribute3      => x_attribute3,
         p_attribute4      => x_attribute4,
         p_attribute5      => x_attribute5,
         p_attribute6      => x_attribute6,
         p_attribute7      => x_attribute7,
         p_attribute8      => x_attribute8,
         p_attribute9      => x_attribute9,
         p_attribute10     => x_attribute10,
         p_attribute11     => x_attribute11,
         p_attribute12     => x_attribute12,
         p_attribute13     => x_attribute13,
         p_attribute14     => x_attribute14,
         p_attribute15     => x_attribute15,
         p_model_name      => x_model_name,
         p_description     => x_description
      );
   else
      open c_obj_verno;
      fetch c_obj_verno into l_obj_verno;
      close c_obj_verno;
      ams_dm_models_b_pkg.UPDATE_ROW (
         p_model_id           => x_model_id,
         p_last_update_date   => SYSDATE,
         p_last_updated_by    => l_user_id,
         p_last_update_login  => 0,
         p_object_version_number => l_obj_verno,
         p_model_type         => x_model_type,
         p_user_status_id     => x_user_status_id,
         p_status_code        => x_status_code,
         p_status_date        => x_status_date,
         p_last_build_date    => x_last_build_date,
         p_owner_user_id      => x_owner_user_id,
         p_scheduled_date     => x_scheduled_date,
         p_scheduled_timezone_id => x_scheduled_timezone_id,
         p_expiration_date    => x_expiration_date,
         p_custom_setup_id    => x_custom_setup_id,
         p_country_id         => x_country_id,
         p_results_flag       => x_results_flag,
         p_logs_flag          => x_logs_flag,
         p_total_records      => x_total_records,
         p_total_positives    => x_total_positives,
         p_target_field       => x_target_field,
         p_target_type        => x_target_type,
         p_target_positive_value => x_target_positive_value,
         p_min_records        => x_min_records,
         p_max_records        => x_max_records,
         p_row_selection_type => x_row_selection_type,
         p_every_nth_row      => x_every_nth_row,
         p_pct_random         => x_pct_random,
         p_performance        => x_performance,
         p_target_group_type  => x_target_group_type,
         p_best_subtree       => x_best_subtree,
         p_wf_itemkey         => x_wf_itemkey,
         p_target_id          => x_target_id,
         p_darwin_model_ref   => x_darwin_model_ref,
         p_attribute_category => x_attribute_category,
         p_attribute1         => x_attribute1,
         p_attribute2         => x_attribute2,
         p_attribute3         => x_attribute3,
         p_attribute4         => x_attribute4,
         p_attribute5         => x_attribute5,
         p_attribute6         => x_attribute6,
         p_attribute7         => x_attribute7,
         p_attribute8         => x_attribute8,
         p_attribute9         => x_attribute9,
         p_attribute10        => x_attribute10,
         p_attribute11        => x_attribute11,
         p_attribute12        => x_attribute12,
         p_attribute13        => x_attribute13,
         p_attribute14        => x_attribute14,
         p_attribute15        => x_attribute15,
         p_model_name         => x_model_name,
         p_description        => x_description
      );
   end if;
   close c_chk_model_exists;
END load_row;


End ams_dm_models_b_pkg;

/
