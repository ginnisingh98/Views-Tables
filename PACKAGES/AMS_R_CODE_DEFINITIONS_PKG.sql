--------------------------------------------------------
--  DDL for Package AMS_R_CODE_DEFINITIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_R_CODE_DEFINITIONS_PKG" AUTHID CURRENT_USER AS
/* $Header: amstcdns.pls 120.1 2005/06/27 05:39:48 appldev ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_R_CODE_DEFINITIONS_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================

PROCEDURE Insert_Row(
          p_creation_date    DATE,
          p_last_update_date    DATE,
          p_created_by    NUMBER,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_type    VARCHAR2,
          p_column_name    VARCHAR2,
          p_object_def    VARCHAR2,
          px_code_definition_id   IN OUT NOCOPY NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER);

PROCEDURE Update_Row(
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_type    VARCHAR2,
          p_column_name    VARCHAR2,
          p_object_def    VARCHAR2,
          p_code_definition_id    NUMBER,
          p_object_version_number    NUMBER);

PROCEDURE Delete_Row(
    p_CODE_DEFINITION_ID  NUMBER);
PROCEDURE Lock_Row(
          p_creation_date    DATE,
          p_last_update_date    DATE,
          p_created_by    NUMBER,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_type    VARCHAR2,
          p_column_name    VARCHAR2,
          p_object_def    VARCHAR2,
          p_code_definition_id    NUMBER,
          p_object_version_number    NUMBER);

END AMS_R_CODE_DEFINITIONS_PKG;

 

/
