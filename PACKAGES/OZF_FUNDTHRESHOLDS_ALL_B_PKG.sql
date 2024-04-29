--------------------------------------------------------
--  DDL for Package OZF_FUNDTHRESHOLDS_ALL_B_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_FUNDTHRESHOLDS_ALL_B_PKG" AUTHID CURRENT_USER AS
/* $Header: ozftthrs.pls 115.1 2003/11/28 12:25:27 pkarthik noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_FUNDTHRESHOLDS_ALL_B_PKG
-- Purpose
--
-- History
--       03/05/2002  mpande UPdated Added Addlanguage and TransaletROw procedure
-- NOTE
--
-- End of Comments
-- ===============================================================

PROCEDURE Insert_Row(
          px_threshold_id   IN OUT NOCOPY NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_created_from    VARCHAR2,
          p_request_id    NUMBER,
          p_program_application_id    NUMBER,
          p_program_id    NUMBER,
          p_program_update_date    DATE,
          p_threshold_calendar   VARCHAR2,
          p_start_period_name    VARCHAR2,
          p_end_period_name    VARCHAR2,
          p_start_date_active    DATE,
          p_end_date_active    DATE,
          p_owner    NUMBER,
          p_enable_flag    VARCHAR2,
          p_attribute_category    VARCHAR2,
          p_attribute1    VARCHAR2,
          p_attribute2    VARCHAR2,
          p_attribute3    VARCHAR2,
          p_attribute4    VARCHAR2,
          p_attribute5    VARCHAR2,
          p_attribute6    VARCHAR2,
          p_attribute7    VARCHAR2,
          p_attribute8    VARCHAR2,
          p_attribute9    VARCHAR2,
          p_attribute10    VARCHAR2,
          p_attribute11    VARCHAR2,
          p_attribute12    VARCHAR2,
          p_attribute13    VARCHAR2,
          p_attribute14    VARCHAR2,
          p_attribute15    VARCHAR2,
          p_org_id        NUMBER,
          p_security_group_id    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_name    VARCHAR2,
          p_description    VARCHAR2,
          p_language    VARCHAR2,
          p_source_lang    VARCHAR2,
          p_threshold_type VARCHAR2);

PROCEDURE Update_Row(
          p_threshold_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          --p_creation_date    DATE,
          --p_created_by    NUMBER,
          p_created_from    VARCHAR2,
          p_request_id    NUMBER,
          p_program_application_id    NUMBER,
          p_program_id    NUMBER,
          p_program_update_date    DATE,
          p_threshold_calendar   VARCHAR2,
          p_start_period_name    VARCHAR2,
          p_end_period_name    VARCHAR2,
          p_start_date_active    DATE,
          p_end_date_active    DATE,
          p_owner    NUMBER,
          p_enable_flag    VARCHAR2,
          p_attribute_category    VARCHAR2,
          p_attribute1    VARCHAR2,
          p_attribute2    VARCHAR2,
          p_attribute3    VARCHAR2,
          p_attribute4    VARCHAR2,
          p_attribute5    VARCHAR2,
          p_attribute6    VARCHAR2,
          p_attribute7    VARCHAR2,
          p_attribute8    VARCHAR2,
          p_attribute9    VARCHAR2,
          p_attribute10    VARCHAR2,
          p_attribute11    VARCHAR2,
          p_attribute12    VARCHAR2,
          p_attribute13    VARCHAR2,
          p_attribute14    VARCHAR2,
          p_attribute15    VARCHAR2,
          p_org_id    NUMBER,
          p_security_group_id    NUMBER,
          px_object_version_number    IN OUT NOCOPY NUMBER,
          p_name    VARCHAR2,
          p_description    VARCHAR2,
          p_language    VARCHAR2,
          p_source_lang    VARCHAR2,
          p_threshold_type VARCHAR2);

PROCEDURE Delete_Row(
    p_THRESHOLD_ID  NUMBER);


PROCEDURE Lock_Row(
          p_threshold_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_created_from    VARCHAR2,
          p_request_id    NUMBER,
          p_program_application_id    NUMBER,
          p_program_id    NUMBER,
          p_program_update_date    DATE,
          p_threshold_calendar   VARCHAR2,
          p_start_period_name    VARCHAR2,
          p_end_period_name    VARCHAR2,
          p_start_date_active    DATE,
          p_end_date_active    DATE,
          p_owner    NUMBER,
          p_enable_flag    VARCHAR2,
          p_attribute_category    VARCHAR2,
          p_attribute1    VARCHAR2,
          p_attribute2    VARCHAR2,
          p_attribute3    VARCHAR2,
          p_attribute4    VARCHAR2,
          p_attribute5    VARCHAR2,
          p_attribute6    VARCHAR2,
          p_attribute7    VARCHAR2,
          p_attribute8    VARCHAR2,
          p_attribute9    VARCHAR2,
          p_attribute10    VARCHAR2,
          p_attribute11    VARCHAR2,
          p_attribute12    VARCHAR2,
          p_attribute13    VARCHAR2,
          p_attribute14    VARCHAR2,
          p_attribute15    VARCHAR2,
          p_org_id    NUMBER,
          p_security_group_id    NUMBER,
          p_object_version_number    NUMBER);

procedure ADD_LANGUAGE;

procedure TRANSLATE_ROW(
  X_THRESHOLD_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNERS in VARCHAR2
);


END OZF_FUNDTHRESHOLDS_ALL_B_PKG;

 

/
