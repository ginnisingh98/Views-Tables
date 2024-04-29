--------------------------------------------------------
--  DDL for Package Body AMS_DM_SCORES_B_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_DM_SCORES_B_PKG" as
/* $Header: amstdmsb.pls 120.1 2005/06/15 23:58:01 appldev  $ */
-- Start of Comments
-- Package name     : AMS_DM_scoreS_B_PKG
-- Purpose          :
-- History          :
-- 23-Jan-2001 choang   Added org_id.
-- 26-Jan-2001 choang   Removed increment of object ver num from update
--                      and removed object ver num from update criteria.
-- 12-Feb-2001 choang   1) Changed model_score to score. 2) added new columns.
-- 19-Feb-2001 choang   Replaced top_down_flag with row_selection_type.
-- 26-Feb-2001 choang   Added custom_setup_id and country_id.
-- 18-Mar-2001 choang   Added add_language, load_row, translate_row; changed
--                      obj ver logic in update.
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_DM_scoreS_B_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amstdmsb.pls';

AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Insert_Row(
   p_score_id              IN NUMBER,
   p_last_update_date      DATE,
   p_last_updated_by       NUMBER,
   p_creation_date         DATE,
   p_created_by            NUMBER,
   p_last_update_login     NUMBER,
   p_object_version_number IN NUMBER,
   p_model_id              NUMBER,
   p_user_status_id        NUMBER,
   p_status_code           VARCHAR2,
   p_status_date           DATE,
   p_owner_user_id         NUMBER,
   p_results_flag          VARCHAR2,
   p_logs_flag             VARCHAR2,
   p_scheduled_date        DATE,
   p_scheduled_timezone_id NUMBER,
   p_score_date            DATE,
   p_expiration_date       DATE,
   p_total_records         NUMBER,
   p_total_positives       NUMBER,
   p_min_records           NUMBER,
   p_max_records           NUMBER,
   p_row_selection_type    VARCHAR2,
   p_every_nth_row         NUMBER,
   p_pct_random            NUMBER,
   p_custom_setup_id       NUMBER,
   p_country_id            NUMBER,
   p_wf_itemkey            VARCHAR2,
   p_score_name            VARCHAR2,
   p_description           VARCHAR2,
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

   INSERT INTO AMS_DM_scoreS_ALL_B(
      score_id,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login,
      object_version_number,
      org_id,
      model_id,
      user_status_id,
      status_code,
      status_date,
      owner_user_id,
      results_flag,
      logs_flag,
      scheduled_date,
      scheduled_timezone_id,
      score_date,
      expiration_date,
      total_records,
      total_positives,
      min_records,
      max_records,
      row_selection_type,
      every_nth_row,
      pct_random,
      custom_setup_id,
      country_id,
      wf_itemkey,
      attribute_category,
      attribute1,
      attribute2,
      attribute3,
      attribute4,
      attribute5,
      attribute6,
      attribute7,
      attribute8,
      attribute9,
      attribute10,
      attribute11,
      attribute12,
      attribute13,
      attribute14,
      attribute15
   ) VALUES (
      DECODE( p_score_id, FND_API.g_miss_num, NULL, p_score_id),
      DECODE( p_last_update_date, FND_API.g_miss_date, NULL, p_last_update_date),
      DECODE( p_last_updated_by, FND_API.g_miss_num, NULL, p_last_updated_by),
      DECODE( p_creation_date, FND_API.g_miss_date, NULL, p_creation_date),
      DECODE( p_created_by, FND_API.g_miss_num, NULL, p_created_by),
      DECODE( p_last_update_login, FND_API.g_miss_num, NULL, p_last_update_login),
      decode( p_OBJECT_VERSION_NUMBER, FND_API.g_miss_num, 1, p_OBJECT_VERSION_NUMBER),
      TO_NUMBER (SUBSTRB (USERENV ('CLIENT_INFO'), 1, 10)),  -- org_id
      DECODE( p_model_id, FND_API.g_miss_num, NULL, p_model_id),
      DECODE( p_user_status_id, FND_API.g_miss_num, NULL, p_user_status_id),
      DECODE( p_status_code, FND_API.g_miss_char, NULL, p_status_code),
      DECODE( p_status_date, FND_API.g_miss_date, NULL, p_status_date),
      DECODE( p_owner_user_id, FND_API.g_miss_num, NULL, p_owner_user_id),
      decode( p_RESULTS_FLAG, FND_API.g_miss_char, 'N', p_RESULTS_FLAG),
      DECODE( p_logs_flag, FND_API.g_miss_char, 'N', p_logs_flag),
      DECODE( p_scheduled_date, FND_API.g_miss_date, NULL, p_scheduled_date),
      DECODE( p_scheduled_timezone_id, FND_API.g_miss_num, NULL, p_scheduled_timezone_id),
      DECODE( p_score_date, FND_API.g_miss_date, NULL, p_score_date),
      DECODE( p_expiration_date, FND_API.g_miss_date, NULL, p_expiration_date),
      DECODE( p_total_records, FND_API.g_miss_num, NULL, p_total_records),
      DECODE( p_total_positives, FND_API.g_miss_num, NULL, p_total_positives),
      DECODE( p_min_records, FND_API.g_miss_num, NULL, p_min_records),
      DECODE( p_max_records, FND_API.g_miss_num, NULL, p_max_records),
      DECODE( p_row_selection_type, FND_API.g_miss_char, 'N', p_row_selection_type),
      DECODE( p_every_nth_row, FND_API.g_miss_num, NULL, p_every_nth_row),
      DECODE( p_pct_random, FND_API.g_miss_num, NULL, p_pct_random),
      DECODE( p_custom_setup_id, FND_API.g_miss_num, NULL, p_custom_setup_id),
      DECODE( p_country_id, FND_API.g_miss_num, NULL, p_country_id),
      DECODE( p_wf_itemkey, FND_API.g_miss_char, NULL, p_wf_itemkey),
      decode( p_attribute_category, FND_API.g_miss_char, NULL, p_attribute_category),
      decode( p_attribute1, FND_API.g_miss_char, NULL, p_attribute1),
      decode( p_attribute2, FND_API.g_miss_char, NULL, p_attribute2),
      decode( p_attribute3, FND_API.g_miss_char, NULL, p_attribute3),
      decode( p_attribute4, FND_API.g_miss_char, NULL, p_attribute4),
      decode( p_attribute5, FND_API.g_miss_char, NULL, p_attribute5),
      decode( p_attribute6, FND_API.g_miss_char, NULL, p_attribute6),
      decode( p_attribute7, FND_API.g_miss_char, NULL, p_attribute7),
      decode( p_attribute8, FND_API.g_miss_char, NULL, p_attribute8),
      decode( p_attribute9, FND_API.g_miss_char, NULL, p_attribute9),
      decode( p_attribute10, FND_API.g_miss_char, NULL, p_attribute10),
      decode( p_attribute11, FND_API.g_miss_char, NULL, p_attribute11),
      decode( p_attribute12, FND_API.g_miss_char, NULL, p_attribute12),
      decode( p_attribute13, FND_API.g_miss_char, NULL, p_attribute13),
      decode( p_attribute14, FND_API.g_miss_char, NULL, p_attribute14),
      decode( p_attribute15, FND_API.g_miss_char, NULL, p_attribute15));

   INSERT INTO ams_dm_scores_all_tl(
      score_id,
      language,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login,
      source_lang,
      score_name,
      description
   )
   SELECT
      decode( p_score_ID, FND_API.G_MISS_NUM, NULL, p_score_ID),
      l.language_code,
      SYSDATE,
      FND_GLOBAL.user_id,
      SYSDATE,
      FND_GLOBAL.user_id,
      FND_GLOBAL.conc_login_id,
      USERENV('LANG'),
      decode( p_score_name, FND_API.G_MISS_CHAR, NULL, p_score_name),
      decode( p_description, FND_API.G_MISS_CHAR, NULL, p_description)
   FROM fnd_languages l
   WHERE l.installed_flag in ('I', 'B')
   AND NOT EXISTS(
         SELECT NULL
         FROM ams_dm_scores_all_tl t
         WHERE t.score_id = decode( p_score_ID, FND_API.G_MISS_NUM, NULL, p_score_ID)
         AND t.language = l.language_code );

End Insert_Row;

PROCEDURE Update_Row(
   p_score_id              IN NUMBER,
   p_last_update_date      DATE,
   p_last_updated_by       NUMBER,
   p_last_update_login     NUMBER,
   p_object_version_number IN NUMBER,
   p_model_id              NUMBER,
   p_user_status_id        NUMBER,
   p_status_code           VARCHAR2,
   p_status_date           DATE,
   p_owner_user_id         NUMBER,
   p_results_flag          VARCHAR2,
   p_logs_flag             VARCHAR2,
   p_scheduled_date        DATE,
   p_scheduled_timezone_id NUMBER,
   p_score_date            DATE,
   p_expiration_date       DATE,
   p_total_records         NUMBER,
   p_total_positives       NUMBER,
   p_min_records           NUMBER,
   p_max_records           NUMBER,
   p_row_selection_type    VARCHAR2,
   p_every_nth_row         NUMBER,
   p_pct_random            NUMBER,
   p_custom_setup_id       NUMBER,
   p_country_id            NUMBER,
   p_wf_itemkey            VARCHAR2,
   p_score_name            VARCHAR2,
   p_description           VARCHAR2,
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
   Update AMS_DM_scoreS_ALL_B
   SET
      score_ID = decode( p_score_ID, FND_API.g_miss_num, score_ID, p_score_ID),
      LAST_UPDATE_DATE = decode( p_LAST_UPDATE_DATE, FND_API.g_miss_date, LAST_UPDATE_DATE, p_LAST_UPDATE_DATE),
      LAST_UPDATED_BY = decode( p_LAST_UPDATED_BY, FND_API.g_miss_num, LAST_UPDATED_BY, p_LAST_UPDATED_BY),
      LAST_UPDATE_LOGIN = decode( p_LAST_UPDATE_LOGIN, FND_API.g_miss_num, LAST_UPDATE_LOGIN, p_LAST_UPDATE_LOGIN),
      OBJECT_VERSION_NUMBER = object_version_number + 1,
      MODEL_ID = decode( p_MODEL_ID, FND_API.g_miss_num, MODEL_ID, p_MODEL_ID),
      USER_STATUS_ID = decode( p_USER_STATUS_ID, FND_API.g_miss_num, USER_STATUS_ID, p_USER_STATUS_ID),
      STATUS_CODE = decode( p_STATUS_CODE, FND_API.g_miss_char, STATUS_CODE, p_STATUS_CODE),
      STATUS_DATE = decode( p_STATUS_DATE, FND_API.g_miss_date, STATUS_DATE, p_STATUS_DATE),
      OWNER_USER_ID = decode( p_OWNER_USER_ID, FND_API.g_miss_num, OWNER_USER_ID, p_OWNER_USER_ID),
      RESULTS_FLAG = decode( p_RESULTS_FLAG, FND_API.g_miss_char, RESULTS_FLAG, p_RESULTS_FLAG),
      logs_flag = DECODE( p_logs_flag, FND_API.g_miss_char, logs_flag, p_logs_flag),
      scheduled_date = DECODE( p_scheduled_date, FND_API.g_miss_date, scheduled_date, p_scheduled_date),
      scheduled_timezone_id = DECODE( p_scheduled_timezone_id, FND_API.g_miss_num, scheduled_timezone_id, p_scheduled_timezone_id),
      score_date = DECODE( p_score_date, FND_API.g_miss_date, score_date, p_score_date),
      expiration_date = DECODE( p_expiration_date, FND_API.g_miss_date, expiration_date, p_expiration_date),
      total_records = DECODE( p_total_records, FND_API.g_miss_num, total_records, p_total_records),
      total_positives = DECODE( p_total_positives, FND_API.g_miss_num, total_positives, p_total_positives),
      min_records = DECODE( p_min_records, FND_API.g_miss_num, min_records, p_min_records),
      max_records = DECODE( p_max_records, FND_API.g_miss_num, max_records, p_max_records),
      row_selection_type = DECODE( p_row_selection_type, FND_API.g_miss_char, row_selection_type, p_row_selection_type),
      every_nth_row = DECODE( p_every_nth_row, FND_API.g_miss_num, every_nth_row, p_every_nth_row),
      pct_random = DECODE( p_pct_random, FND_API.g_miss_num, pct_random, p_pct_random),
      custom_setup_id = DECODE( p_custom_setup_id, FND_API.g_miss_num, custom_setup_id, p_custom_setup_id),
      country_id = DECODE( p_country_id, FND_API.g_miss_num, country_id, p_country_id),
      wf_itemkey = decode( p_wf_itemkey, FND_API.g_miss_char, wf_itemkey, p_wf_itemkey),
      attribute_category = decode( p_attribute_category, FND_API.g_miss_char, attribute_category, p_attribute_category),
      attribute1 = decode( p_attribute1, FND_API.g_miss_char, attribute1, p_attribute1),
      attribute2 = decode( p_attribute2, FND_API.g_miss_char, attribute2, p_attribute2),
      attribute3 = decode( p_attribute3, FND_API.g_miss_char, attribute3, p_attribute3),
      attribute4 = decode( p_attribute4, FND_API.g_miss_char, attribute4, p_attribute4),
      attribute5 = decode( p_attribute5, FND_API.g_miss_char, attribute5, p_attribute5),
      attribute6 = decode( p_attribute6, FND_API.g_miss_char, attribute6, p_attribute6),
      attribute7 = decode( p_attribute7, FND_API.g_miss_char, attribute7, p_attribute7),
      attribute8 = decode( p_attribute8, FND_API.g_miss_char, attribute8, p_attribute8),
      attribute9 = decode( p_attribute9, FND_API.g_miss_char, attribute9, p_attribute9),
      attribute10 = decode( p_attribute10, FND_API.g_miss_char, attribute10, p_attribute10),
      attribute11 = decode( p_attribute11, FND_API.g_miss_char, attribute11, p_attribute11),
      attribute12 = decode( p_attribute12, FND_API.g_miss_char, attribute12, p_attribute12),
      attribute13 = decode( p_attribute13, FND_API.g_miss_char, attribute13, p_attribute13),
      attribute14 = decode( p_attribute14, FND_API.g_miss_char, attribute14, p_attribute14),
      attribute15 = decode( p_attribute15, FND_API.g_miss_char, attribute15, p_attribute15)
   WHERE score_id = p_score_id
   AND   object_version_number = p_object_version_number;
   IF SQL%NOTFOUND THEN
      -- the calling program should catch no_data_found
      -- and treat it as a mismatch in object version
      -- number.
      RAISE NO_DATA_FOUND;
   END IF;

   update ams_dm_scores_all_tl set
      score_name = decode( p_score_NAME, FND_API.G_MISS_CHAR, score_NAME, p_score_NAME),
      description = decode( p_DESCRIPTION, FND_API.G_MISS_CHAR, DESCRIPTION, p_DESCRIPTION),
      last_update_date = SYSDATE,
      last_updated_by = FND_GLOBAL.user_id,
      last_update_login = FND_GLOBAL.conc_login_id,
      source_lang = USERENV('LANG')
   WHERE score_id = p_score_ID
   AND USERENV('LANG') IN (language, source_lang);

END Update_Row;

PROCEDURE Delete_Row(
    p_score_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM AMS_DM_scoreS_ALL_B
    WHERE score_ID = p_score_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;

   DELETE FROM ams_dm_scores_all_tl
    WHERE score_ID = p_score_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;

 END Delete_Row;

PROCEDURE Lock_Row(
          p_score_ID    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_OBJECT_VERSION_NUMBER    NUMBER,
          p_MODEL_ID    NUMBER,
          p_USER_STATUS_ID    NUMBER,
          p_STATUS_CODE    VARCHAR2,
          p_STATUS_DATE    DATE,
          p_OWNER_USER_ID    NUMBER,
          p_RESULTS_FLAG    VARCHAR2,
          p_SCHEDULED_DATE    DATE,
          p_SCHEDULED_TIMEZONE_ID    NUMBER,
          p_SCORE_DATE    DATE,
          p_NUM_RECORDS    NUMBER,
          p_EXPIRATION_DATE    DATE,
          p_ATTRIBUTE_CATEGORY    VARCHAR2,
          p_ATTRIBUTE1    VARCHAR2,
          p_ATTRIBUTE2    VARCHAR2,
          p_ATTRIBUTE3    VARCHAR2,
          p_ATTRIBUTE4    VARCHAR2,
          p_ATTRIBUTE5    VARCHAR2,
          p_ATTRIBUTE6    VARCHAR2,
          p_ATTRIBUTE7    VARCHAR2,
          p_ATTRIBUTE8    VARCHAR2,
          p_ATTRIBUTE9    VARCHAR2,
          p_ATTRIBUTE10    VARCHAR2,
          p_ATTRIBUTE11    VARCHAR2,
          p_ATTRIBUTE12    VARCHAR2,
          p_ATTRIBUTE13    VARCHAR2,
          p_ATTRIBUTE14    VARCHAR2,
          p_ATTRIBUTE15    VARCHAR2)

 IS
   CURSOR C IS
        SELECT *
         FROM AMS_DM_scoreS_ALL_B
        WHERE score_ID =  p_score_ID
        FOR UPDATE of score_ID NOWAIT;
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
           (      Recinfo.score_ID = p_score_ID)
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
       AND (    ( Recinfo.MODEL_ID = p_MODEL_ID)
            OR (    ( Recinfo.MODEL_ID IS NULL )
                AND (  p_MODEL_ID IS NULL )))
       AND (    ( Recinfo.USER_STATUS_ID = p_USER_STATUS_ID)
            OR (    ( Recinfo.USER_STATUS_ID IS NULL )
                AND (  p_USER_STATUS_ID IS NULL )))
       AND (    ( Recinfo.STATUS_CODE = p_STATUS_CODE)
            OR (    ( Recinfo.STATUS_CODE IS NULL )
                AND (  p_STATUS_CODE IS NULL )))
       AND (    ( Recinfo.STATUS_DATE = p_STATUS_DATE)
            OR (    ( Recinfo.STATUS_DATE IS NULL )
                AND (  p_STATUS_DATE IS NULL )))
       AND (    ( Recinfo.OWNER_USER_ID = p_OWNER_USER_ID)
            OR (    ( Recinfo.OWNER_USER_ID IS NULL )
                AND (  p_OWNER_USER_ID IS NULL )))
       AND (    ( Recinfo.RESULTS_FLAG = p_RESULTS_FLAG)
            OR (    ( Recinfo.RESULTS_FLAG IS NULL )
                AND (  p_RESULTS_FLAG IS NULL )))
       AND (    ( Recinfo.SCHEDULED_DATE = p_SCHEDULED_DATE)
            OR (    ( Recinfo.SCHEDULED_DATE IS NULL )
                AND (  p_SCHEDULED_DATE IS NULL )))
       AND (    ( Recinfo.SCHEDULED_TIMEZONE_ID = p_SCHEDULED_TIMEZONE_ID)
            OR (    ( Recinfo.SCHEDULED_TIMEZONE_ID IS NULL )
                AND (  p_SCHEDULED_TIMEZONE_ID IS NULL )))
       AND (    ( Recinfo.SCORE_DATE = p_SCORE_DATE)
            OR (    ( Recinfo.SCORE_DATE IS NULL )
                AND (  p_SCORE_DATE IS NULL )))
       AND (    ( Recinfo.EXPIRATION_DATE = p_EXPIRATION_DATE)
            OR (    ( Recinfo.EXPIRATION_DATE IS NULL )
                AND (  p_EXPIRATION_DATE IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE_CATEGORY = p_ATTRIBUTE_CATEGORY)
            OR (    ( Recinfo.ATTRIBUTE_CATEGORY IS NULL )
                AND (  p_ATTRIBUTE_CATEGORY IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE1 = p_ATTRIBUTE1)
            OR (    ( Recinfo.ATTRIBUTE1 IS NULL )
                AND (  p_ATTRIBUTE1 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE2 = p_ATTRIBUTE2)
            OR (    ( Recinfo.ATTRIBUTE2 IS NULL )
                AND (  p_ATTRIBUTE2 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE3 = p_ATTRIBUTE3)
            OR (    ( Recinfo.ATTRIBUTE3 IS NULL )
                AND (  p_ATTRIBUTE3 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE4 = p_ATTRIBUTE4)
            OR (    ( Recinfo.ATTRIBUTE4 IS NULL )
                AND (  p_ATTRIBUTE4 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE5 = p_ATTRIBUTE5)
            OR (    ( Recinfo.ATTRIBUTE5 IS NULL )
                AND (  p_ATTRIBUTE5 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE6 = p_ATTRIBUTE6)
            OR (    ( Recinfo.ATTRIBUTE6 IS NULL )
                AND (  p_ATTRIBUTE6 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE7 = p_ATTRIBUTE7)
            OR (    ( Recinfo.ATTRIBUTE7 IS NULL )
                AND (  p_ATTRIBUTE7 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE8 = p_ATTRIBUTE8)
            OR (    ( Recinfo.ATTRIBUTE8 IS NULL )
                AND (  p_ATTRIBUTE8 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE9 = p_ATTRIBUTE9)
            OR (    ( Recinfo.ATTRIBUTE9 IS NULL )
                AND (  p_ATTRIBUTE9 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE10 = p_ATTRIBUTE10)
            OR (    ( Recinfo.ATTRIBUTE10 IS NULL )
                AND (  p_ATTRIBUTE10 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE11 = p_ATTRIBUTE11)
            OR (    ( Recinfo.ATTRIBUTE11 IS NULL )
                AND (  p_ATTRIBUTE11 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE12 = p_ATTRIBUTE12)
            OR (    ( Recinfo.ATTRIBUTE12 IS NULL )
                AND (  p_ATTRIBUTE12 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE13 = p_ATTRIBUTE13)
            OR (    ( Recinfo.ATTRIBUTE13 IS NULL )
                AND (  p_ATTRIBUTE13 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE14 = p_ATTRIBUTE14)
            OR (    ( Recinfo.ATTRIBUTE14 IS NULL )
                AND (  p_ATTRIBUTE14 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE15 = p_ATTRIBUTE15)
            OR (    ( Recinfo.ATTRIBUTE15 IS NULL )
                AND (  p_ATTRIBUTE15 IS NULL )))
       ) then
       return;
   else
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   End If;
END Lock_Row;


procedure ADD_LANGUAGE
is
begin
  delete from AMS_DM_SCORES_ALL_TL T
  where not exists
    (select NULL
    from AMS_DM_SCORES_ALL_B B
    where B.SCORE_ID = T.SCORE_ID
    );

  update AMS_DM_SCORES_ALL_TL T set (
      SCORE_NAME,
      DESCRIPTION
    ) = (select
      B.SCORE_NAME,
      B.DESCRIPTION
    from AMS_DM_SCORES_ALL_TL B
    where B.SCORE_ID = T.SCORE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.SCORE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.SCORE_ID,
      SUBT.LANGUAGE
    from AMS_DM_SCORES_ALL_TL SUBB, AMS_DM_SCORES_ALL_TL SUBT
    where SUBB.SCORE_ID = SUBT.SCORE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.SCORE_NAME <> SUBT.SCORE_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into AMS_DM_SCORES_ALL_TL (
    SCORE_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    SCORE_NAME,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.SCORE_ID,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.SCORE_NAME,
    B.DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from AMS_DM_SCORES_ALL_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AMS_DM_SCORES_ALL_TL T
    where T.SCORE_ID = B.SCORE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;


PROCEDURE translate_row (
   x_score_id IN NUMBER,
   x_score_name IN VARCHAR2,
   x_description IN VARCHAR2,
   x_owner IN VARCHAR2
)
IS
BEGIN
    update ams_dm_scores_all_tl set
       score_name = nvl(x_score_name, score_name),
       description = nvl(x_description, description),
       source_lang = userenv('LANG'),
       last_update_date = sysdate,
       last_updated_by = decode(x_owner, 'SEED', 1, 0),
       last_update_login = 0
    where  score_id = x_score_id
    and      userenv('LANG') in (language, source_lang);
end TRANSLATE_ROW;


PROCEDURE load_row (
   x_score_id           IN NUMBER,
   x_model_id              NUMBER,
   x_user_status_id        NUMBER,
   x_status_code           VARCHAR2,
   x_status_date           DATE,
   x_owner_user_id         NUMBER,
   x_results_flag          VARCHAR2,
   x_logs_flag             VARCHAR2,
   x_scheduled_date        DATE,
   x_scheduled_timezone_id NUMBER,
   x_score_date            DATE,
   x_expiration_date       DATE,
   x_total_records         NUMBER,
   x_total_positives       NUMBER,
   x_min_records           NUMBER,
   x_max_records           NUMBER,
   x_row_selection_type    VARCHAR2,
   x_every_nth_row         NUMBER,
   x_pct_random            NUMBER,
   x_custom_setup_id       NUMBER,
   x_country_id            NUMBER,
   x_wf_itemkey            VARCHAR2,
   x_score_name            VARCHAR2,
   x_description           VARCHAR2,
   x_attribute_category    VARCHAR2,
   x_attribute1            VARCHAR2,
   x_attribute2            VARCHAR2,
   x_attribute3            VARCHAR2,
   x_attribute4            VARCHAR2,
   x_attribute5            VARCHAR2,
   x_attribute6            VARCHAR2,
   x_attribute7            VARCHAR2,
   x_attribute8            VARCHAR2,
   x_attribute9            VARCHAR2,
   x_attribute10           VARCHAR2,
   x_attribute11           VARCHAR2,
   x_attribute12           VARCHAR2,
   x_attribute13           VARCHAR2,
   x_attribute14           VARCHAR2,
   x_attribute15           VARCHAR2,
   x_owner                 VARCHAR2
)
IS
   l_user_id      number := 0;
   l_obj_verno    number;
   l_dummy_char   varchar2(1);
   l_row_id       varchar2(100);
   l_score_id     number;

   cursor  c_obj_verno is
     select object_version_number
     from    ams_dm_scores_all_b
     where  score_id =  x_score_id;

   cursor c_chk_score_exists is
     select 'x'
     from   ams_dm_scores_all_b
     where  score_id = x_score_id;

   cursor c_get_score_id is
      select ams_dm_scores_all_b_s.nextval
      from dual;
BEGIN
   if X_OWNER = 'SEED' then
      l_user_id := 1;
   end if;

   open c_chk_score_exists;
   fetch c_chk_score_exists into l_dummy_char;
   if c_chk_score_exists%notfound THEN
      if x_score_id is null then
         open c_get_score_id;
         fetch c_get_score_id into l_score_id;
         close c_get_score_id;
      else
         l_score_id := x_score_id;
      end if;
      l_obj_verno := 1;
      ams_dm_scores_b_pkg.INSERT_ROW (
         p_score_id => x_score_id,
         p_last_update_date => SYSDATE,
         p_last_updated_by => l_user_id,
         p_creation_date => SYSDATE,
         p_created_by => l_user_id,
         p_last_update_login => 0,
         p_object_version_number => l_obj_verno,
         p_model_id => x_model_id,
         p_user_status_id => x_user_status_id,
         p_status_code => x_status_code,
         p_status_date => x_status_date,
         p_owner_user_id => x_owner_user_id,
         p_custom_setup_id => x_custom_setup_id,
         p_country_id => x_country_id,
         p_results_flag => x_results_flag,
         p_logs_flag => x_logs_flag,
         p_scheduled_date => x_scheduled_date,
         p_scheduled_timezone_id => x_scheduled_timezone_id,
         p_score_date => x_score_date,
         p_total_records => x_total_records,
         p_total_positives => x_total_positives,
         p_expiration_date => x_expiration_date,
         p_min_records => x_min_records,
         p_max_records => x_max_records,
         p_row_selection_type => x_row_selection_type,
         p_every_nth_row => x_every_nth_row,
         p_pct_random => x_pct_random,
         p_wf_itemkey => x_wf_itemkey,
         p_attribute_category => x_attribute_category,
         p_attribute1 => x_attribute1,
         p_attribute2 => x_attribute2,
         p_attribute3 => x_attribute3,
         p_attribute4 => x_attribute4,
         p_attribute5 => x_attribute5,
         p_attribute6 => x_attribute6,
         p_attribute7 => x_attribute7,
         p_attribute8 => x_attribute8,
         p_attribute9 => x_attribute9,
         p_attribute10 => x_attribute10,
         p_attribute11 => x_attribute11,
         p_attribute12 => x_attribute12,
         p_attribute13 => x_attribute13,
         p_attribute14 => x_attribute14,
         p_attribute15 => x_attribute15,
         p_score_name => x_score_name,
         p_description => x_description
      );
   else
      open c_obj_verno;
      fetch c_obj_verno into l_obj_verno;
      close c_obj_verno;
      ams_dm_scores_b_pkg.UPDATE_ROW (
         p_score_id => x_score_id,
         p_last_update_date => SYSDATE,
         p_last_updated_by => l_user_id,
         p_last_update_login => 0,
         p_object_version_number => l_obj_verno,
         p_model_id => x_model_id,
         p_user_status_id => x_user_status_id,
         p_status_code => x_status_code,
         p_status_date => x_status_date,
         p_owner_user_id => x_owner_user_id,
         p_custom_setup_id => x_custom_setup_id,
         p_country_id => x_country_id,
         p_results_flag => x_results_flag,
         p_logs_flag => x_logs_flag,
         p_scheduled_date => x_scheduled_date,
         p_scheduled_timezone_id => x_scheduled_timezone_id,
         p_score_date => x_score_date,
         p_total_records => x_total_records,
         p_total_positives => x_total_positives,
         p_expiration_date => x_expiration_date,
         p_min_records => x_min_records,
         p_max_records => x_max_records,
         p_row_selection_type => x_row_selection_type,
         p_every_nth_row => x_every_nth_row,
         p_pct_random => x_pct_random,
         p_wf_itemkey => x_wf_itemkey,
         p_attribute_category => x_attribute_category,
         p_attribute1 => x_attribute1,
         p_attribute2 => x_attribute2,
         p_attribute3 => x_attribute3,
         p_attribute4 => x_attribute4,
         p_attribute5 => x_attribute5,
         p_attribute6 => x_attribute6,
         p_attribute7 => x_attribute7,
         p_attribute8 => x_attribute8,
         p_attribute9 => x_attribute9,
         p_attribute10 => x_attribute10,
         p_attribute11 => x_attribute11,
         p_attribute12 => x_attribute12,
         p_attribute13 => x_attribute13,
         p_attribute14 => x_attribute14,
         p_attribute15 => x_attribute15,
         p_score_name => x_score_name,
         p_description => x_description
      );
   end if;
   close c_chk_score_exists;
END load_row;


End AMS_DM_scoreS_B_PKG;

/
