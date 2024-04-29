--------------------------------------------------------
--  DDL for Package AMS_DM_SCORES_B_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_DM_SCORES_B_PKG" AUTHID CURRENT_USER as
/* $Header: amstdmss.pls 120.1 2005/06/15 23:58:05 appldev  $ */
-- Start of Comments
-- Package name     : AMS_DM_scoreS_B_PKG
-- Purpose          :
-- History          :
-- 23-Jan-2001 choang   Added org_id.
-- 12-Feb-2001 choang   1) Changed model_score to score. 2) added new columns.
-- 19-Feb-2001 choang   Replaced top_down_flag with row_selection_type.
-- 26-Feb-2001 choang   Added custom_setup_id and country_id.
-- 10-Mar-2001 choang   Added wf_itemkey.
-- 18-Mar-2001 choang   Added add_language, load_row, translate_row
-- NOTE             :
-- End of Comments

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
);

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
);

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
          p_ATTRIBUTE15    VARCHAR2);

PROCEDURE Delete_Row(
    p_score_ID  NUMBER);


PROCEDURE add_language;

PROCEDURE translate_row (
   x_score_id IN NUMBER,
   x_score_name IN VARCHAR2,
   x_description IN VARCHAR2,
   x_owner IN VARCHAR2
);

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
);


End AMS_DM_scoreS_B_PKG;

 

/
