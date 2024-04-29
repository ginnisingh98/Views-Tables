--------------------------------------------------------
--  DDL for Package AMS_MET_TPL_HEADERS_B_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_MET_TPL_HEADERS_B_PKG" AUTHID CURRENT_USER AS
/* $Header: amslmths.pls 115.12 2003/10/16 11:26:17 sunkumar ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_MET_TPL_HEADERS_B_PKG
-- Purpose
--
-- History
--   03/05/2002  dmvincen  Created.
--   03/07/2002  dmvincen  Added LOAD_ROW.
--   08/19/2002  dmvincen  Added add_language for MLS compliance. BUG2501425.
--   08-Sep-2003 Sunkumar  Bug#3130095 Metric Template UI Enh. 11510
--
-- NOTE
--
-- End of Comments
-- ===============================================================

PROCEDURE Insert_Row(
          px_metric_tpl_header_id   NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          px_object_version_number   NUMBER,
          p_enabled_flag    VARCHAR2,
          p_application_id    NUMBER,
          p_metric_tpl_header_name VARCHAR2,
          p_description VARCHAR2,
          p_object_type VARCHAR2,
          p_association_type VARCHAR2,
          p_used_by_id NUMBER,
          p_used_by_code VARCHAR2);

PROCEDURE Update_Row(
          p_metric_tpl_header_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_enabled_flag    VARCHAR2,
          p_application_id    NUMBER,
          p_metric_tpl_header_name VARCHAR2,
          p_description VARCHAR2,
	  p_object_type VARCHAR2,
          p_association_type VARCHAR2,
          p_used_by_id NUMBER,
          p_used_by_code VARCHAR2);

PROCEDURE Delete_Row(
    p_METRIC_TPL_HEADER_ID  NUMBER);
PROCEDURE Lock_Row(
          p_metric_tpl_header_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_enabled_flag    VARCHAR2,
          p_application_id    NUMBER);

PROCEDURE LOAD_ROW (
        X_METRIC_TPL_HEADER_ID NUMBER,
        X_OBJECT_VERSION_NUMBER NUMBER,
        X_METRIC_TPL_HEADER_NAME VARCHAR2,
        X_DESCRIPTION VARCHAR2,
        X_ENABLED_FLAG VARCHAR2,
	X_APPLICATION_ID NUMBER,
        X_Owner   VARCHAR2,
        X_CUSTOM_MODE VARCHAR2,
	X_OBJECT_TYPE IN VARCHAR2,
	X_ASSOCIATION_TYPE IN VARCHAR2,
	X_USED_BY_ID IN NUMBER,
	X_USED_BY_CODE IN VARCHAR2
);


PROCEDURE ADD_LANGUAGE;

procedure TRANSLATE_ROW(
       X_METRIC_TPL_HEADER_ID    in NUMBER
     , X_METRIC_TPL_HEADER_NAME  in VARCHAR2
     , X_DESCRIPTION    in VARCHAR2
     , x_owner   in VARCHAR2
 );

END AMS_MET_TPL_HEADERS_B_PKG;

 

/
