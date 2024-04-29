--------------------------------------------------------
--  DDL for Package OZF_RESALE_BATCH_LINE_MAPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_RESALE_BATCH_LINE_MAPS_PKG" AUTHID CURRENT_USER AS
/* $Header: ozftrbls.pls 120.1 2005/08/19 14:01:17 appldev ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_RESALE_BATCH_LINE_MAPS_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================

PROCEDURE Insert_Row(
          px_resale_batch_line_map_id   IN OUT  NOCOPY NUMBER,
          p_resale_batch_id    NUMBER,
          p_resale_line_id    NUMBER,
          px_object_version_number   IN OUT NOCOPY  NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_request_id    NUMBER,
          p_created_by    NUMBER,
          p_created_from    VARCHAR2,
          p_last_update_login    NUMBER,
          p_program_application_id    NUMBER,
          p_program_update_date    DATE,
          p_program_id    NUMBER,
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
          px_org_id   IN OUT NOCOPY NUMBER);

PROCEDURE Update_Row(
          p_resale_batch_line_map_id    NUMBER,
          p_resale_batch_id    NUMBER,
          p_resale_line_id    NUMBER,
          p_object_version_number    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_request_id    NUMBER,
          p_created_from    VARCHAR2,
          p_last_update_login    NUMBER,
          p_program_application_id    NUMBER,
          p_program_update_date    DATE,
          p_program_id    NUMBER,
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
          p_org_id    NUMBER);

PROCEDURE Delete_Row(
    p_RESALE_BATCH_LINE_MAP_ID  NUMBER);
PROCEDURE Lock_Row(
          p_resale_batch_line_map_id    NUMBER,
          p_resale_batch_id    NUMBER,
          p_resale_line_id    NUMBER,
          p_object_version_number    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_request_id    NUMBER,
          p_created_by    NUMBER,
          p_created_from    VARCHAR2,
          p_last_update_login    NUMBER,
          p_program_application_id    NUMBER,
          p_program_update_date    DATE,
          p_program_id    NUMBER,
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
          p_org_id    NUMBER);

END OZF_RESALE_BATCH_LINE_MAPS_PKG;

 

/
