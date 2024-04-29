--------------------------------------------------------
--  DDL for Package AMS_MET_TPL_ASSOCS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_MET_TPL_ASSOCS_PKG" AUTHID CURRENT_USER AS
/* $Header: amslmtas.pls 115.7 2003/03/07 22:45:56 dmvincen ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_MET_TPL_ASSOCS_PKG
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
          p_metric_tpl_assoc_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          px_object_version_number   IN NUMBER,
          p_metric_tpl_header_id    NUMBER,
          p_association_type    VARCHAR2,
          p_used_by_id    NUMBER,
          p_used_by_code    VARCHAR2,
          p_enabled_flag    VARCHAR2);

PROCEDURE Update_Row(
          p_metric_tpl_assoc_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_metric_tpl_header_id    NUMBER,
          p_association_type    VARCHAR2,
          p_used_by_id    NUMBER,
          p_used_by_code    VARCHAR2,
          p_enabled_flag    VARCHAR2);

PROCEDURE Delete_Row(
    p_METRIC_TPL_ASSOC_ID  NUMBER);
PROCEDURE Lock_Row(
          p_metric_tpl_assoc_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_metric_tpl_header_id    NUMBER,
          p_association_type    VARCHAR2,
          p_used_by_id    NUMBER,
          p_used_by_code    VARCHAR2,
          p_enabled_flag    VARCHAR2);

PROCEDURE LOAD_ROW (
        X_METRIC_TPL_ASSOC_ID NUMBER,
        X_OBJECT_VERSION_NUMBER NUMBER,
        X_METRIC_TPL_HEADER_ID NUMBER,
        X_ASSOCIATION_TYPE VARCHAR2,
        X_USED_BY_ID NUMBER,
        X_USED_BY_CODE VARCHAR2,
        X_ENABLED_FLAG VARCHAR2,
        X_Owner   VARCHAR2,
        X_CUSTOM_MODE VARCHAR2
        );

END AMS_MET_TPL_ASSOCS_PKG;

 

/
