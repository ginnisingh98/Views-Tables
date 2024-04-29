--------------------------------------------------------
--  DDL for Package AMS_IBA_PL_STYLESHTS_B_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_IBA_PL_STYLESHTS_B_PKG" AUTHID CURRENT_USER AS
/* $Header: amststys.pls 120.0 2005/06/01 02:45:30 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_IBA_PL_STYLESHTS_B_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================

PROCEDURE Insert_Row(
          px_stylesheet_id   IN OUT NOCOPY NUMBER,
          p_content_type    VARCHAR2,
          p_stylesheet_filename    VARCHAR2,
          p_status_code    VARCHAR2,
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
                p_name in VARCHAR2,
                p_description in VARCHAR2);


PROCEDURE Update_Row(
          p_stylesheet_id    NUMBER,
          p_content_type    VARCHAR2,
          p_stylesheet_filename    VARCHAR2,
          p_status_code    VARCHAR2,
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
                p_name in VARCHAR2,
                p_description in VARCHAR2);


PROCEDURE Delete_Row(
    p_STYLESHEET_ID  NUMBER);

procedure ADD_LANGUAGE;

PROCEDURE Lock_Row(
          p_stylesheet_id    NUMBER,
          p_content_type    VARCHAR2,
          p_stylesheet_filename    VARCHAR2,
          p_status_code    VARCHAR2,
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER);

PROCEDURE translate_row (
   x_stylesheet_id IN NUMBER,
   x_name IN VARCHAR2,
   x_description IN VARCHAR2,
   x_owner IN VARCHAR2,
   x_custom_mode IN VARCHAR2
  );

PROCEDURE load_row (
   x_stylesheet_id           IN NUMBER,
   x_content_type            IN VARCHAR2,
   x_stylesheet_filename     IN VARCHAR2,
   x_status_code       IN VARCHAR2,
   x_name         IN VARCHAR2,
   x_description  IN VARCHAR2,
   x_owner               IN VARCHAR2,
   x_custom_mode IN VARCHAR2
  );

END AMS_IBA_PL_STYLESHTS_B_PKG;

 

/
