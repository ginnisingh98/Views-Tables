--------------------------------------------------------
--  DDL for Package AMS_IBA_PL_PG_PARAMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_IBA_PL_PG_PARAMS_PKG" AUTHID CURRENT_USER AS
/* $Header: amstpgps.pls 120.0 2005/05/31 16:27:40 appldev noship $ */
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
          px_object_version_number   IN OUT NOCOPY NUMBER);

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
          p_object_version_number    NUMBER);

PROCEDURE Delete_Row(
    p_PAGE_PARAMETER_ID  NUMBER);
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
          p_object_version_number    NUMBER);


PROCEDURE load_row (
   x_page_parameter_id  IN NUMBER,
   x_page_id            IN NUMBER,
   x_site_ref_code      IN VARCHAR2,
   x_page_ref_code      IN VARCHAR2,
   x_parameter_id       IN NUMBER,
   x_parameter_ref_code IN VARCHAR2,
   x_execution_order    IN NUMBER,
   x_owner              IN VARCHAR2,
   X_CUSTOM_MODE		IN VARCHAR2
  );

END AMS_IBA_PL_PG_PARAMS_PKG;

 

/
