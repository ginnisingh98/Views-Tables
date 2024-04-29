--------------------------------------------------------
--  DDL for Package AMS_IBA_PS_POSTINGS_B_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_IBA_PS_POSTINGS_B_PKG" AUTHID CURRENT_USER AS
/* $Header: amstpsts.pls 115.7 2002/12/19 04:17:02 ryedator ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_IBA_PS_POSTINGS_B_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================

PROCEDURE Insert_Row(
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          px_posting_id   IN OUT NOCOPY NUMBER,
          p_max_no_contents    NUMBER,
          p_posting_type    VARCHAR2,
          p_content_type    VARCHAR2,
          p_default_content_id    NUMBER,
          p_status_code    VARCHAR2,
	  p_posting_name   IN VARCHAR2,
	  p_display_name   IN VARCHAR2,
	  p_posting_description IN VARCHAR2,
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
          p_attribute15    VARCHAR2);

PROCEDURE Update_Row(
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_posting_id    NUMBER,
          p_max_no_contents    NUMBER,
          p_posting_type    VARCHAR2,
          p_content_type    VARCHAR2,
          p_default_content_id    NUMBER,
          p_status_code    VARCHAR2,
          p_posting_name   IN VARCHAR2,
          p_display_name   IN VARCHAR2,
          p_posting_description IN VARCHAR2,
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
          p_attribute15    VARCHAR2);


PROCEDURE Delete_Row(
    p_POSTING_ID  NUMBER);

PROCEDURE Lock_Row(
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_posting_id    NUMBER,
          p_max_no_contents    NUMBER,
          p_posting_type    VARCHAR2,
          p_content_type    VARCHAR2,
          p_default_content_id    NUMBER,
          p_status_code    VARCHAR2,
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
          p_attribute15    VARCHAR2);

PROCEDURE ADD_LANGUAGE;

END AMS_IBA_PS_POSTINGS_B_PKG;

 

/
