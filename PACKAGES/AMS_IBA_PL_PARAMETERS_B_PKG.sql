--------------------------------------------------------
--  DDL for Package AMS_IBA_PL_PARAMETERS_B_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_IBA_PL_PARAMETERS_B_PKG" AUTHID CURRENT_USER AS
/* $Header: amstpars.pls 120.0 2005/05/31 14:52:36 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_IBA_PL_PARAMETERS_B_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================

PROCEDURE Insert_Row(
          px_parameter_id   IN OUT NOCOPY NUMBER,
          p_site_id    NUMBER,
          p_site_ref_code    VARCHAR2,
          p_parameter_ref_code    VARCHAR2,
          p_execution_order    NUMBER,
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
	  p_name in VARCHAR2,
	  p_description in VARCHAR2);


PROCEDURE Update_Row(
          p_parameter_id    NUMBER,
          p_site_id    NUMBER,
          p_site_ref_code    VARCHAR2,
          p_parameter_ref_code    VARCHAR2,
          p_execution_order    NUMBER,
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
	  p_name in VARCHAR2,
	  p_description in VARCHAR2);


PROCEDURE Delete_Row(
    p_PARAMETER_ID  NUMBER);

procedure ADD_LANGUAGE;

PROCEDURE Lock_Row(
          p_parameter_id    NUMBER,
          p_site_id    NUMBER,
          p_site_ref_code    VARCHAR2,
          p_parameter_ref_code    VARCHAR2,
          p_execution_order    NUMBER,
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
	  p_name in VARCHAR2,
	  p_description in VARCHAR2);

PROCEDURE translate_row (
   x_parameter_id 	IN NUMBER,
   x_name 		IN VARCHAR2,
   x_description 	IN VARCHAR2,
   x_owner 		IN VARCHAR2,
   x_custom_mode IN VARCHAR2
  );

PROCEDURE load_row (
   x_parameter_id      	IN NUMBER,
   x_site_id           	IN NUMBER,
   x_site_ref_code     	IN VARCHAR2,
   x_parameter_ref_code IN VARCHAR2,
   x_execution_order   	IN NUMBER,
   x_name              	IN VARCHAR2,
   x_description       	IN VARCHAR2,
   x_owner              IN VARCHAR2,
   x_custom_mode IN VARCHAR2
  );


END AMS_IBA_PL_PARAMETERS_B_PKG;

 

/