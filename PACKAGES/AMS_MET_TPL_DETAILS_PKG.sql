--------------------------------------------------------
--  DDL for Package AMS_MET_TPL_DETAILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_MET_TPL_DETAILS_PKG" AUTHID CURRENT_USER AS
/* $Header: amslmtds.pls 115.9 2003/03/07 22:46:00 dmvincen ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_MET_TPL_DETAILS_PKG
-- Purpose
--
-- History
--   03/05/2002  dmvincen  Created.
--   03/07/2002  dmvincen  Added LOAD_ROW.
--
-- NOTE
--
-- End of Comments
-- ===============================================================

PROCEDURE Insert_Row(
          px_metric_template_detail_id   NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          px_object_version_number   NUMBER,
          p_metric_tpl_header_id    NUMBER,
          p_metric_id    NUMBER,
          p_enabled_flag    VARCHAR2);

PROCEDURE Update_Row(
          p_metric_template_detail_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_metric_tpl_header_id    NUMBER,
          p_metric_id    NUMBER,
          p_enabled_flag    VARCHAR2);

PROCEDURE Delete_Row(
    p_METRIC_TEMPLATE_DETAIL_ID  NUMBER);
PROCEDURE Lock_Row(
          p_metric_template_detail_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_metric_tpl_header_id    NUMBER,
          p_metric_id    NUMBER,
          p_enabled_flag    VARCHAR2);

PROCEDURE LOAD_ROW (
        X_METRIC_TEMPLATE_DETAIL_ID NUMBER,
        X_OBJECT_VERSION_NUMBER NUMBER,
        X_METRIC_TPL_HEADER_ID NUMBER,
        X_METRIC_ID NUMBER,
        X_ENABLED_FLAG VARCHAR2,
        X_Owner   VARCHAR2,
        X_CUSTOM_MODE VARCHAR2
        );
END Ams_Met_Tpl_Details_Pkg;

 

/
