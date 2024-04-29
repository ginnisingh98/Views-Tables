--------------------------------------------------------
--  DDL for Package PV_GE_HL_PARAM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_GE_HL_PARAM_PKG" AUTHID CURRENT_USER AS
/* $Header: pvxtghps.pls 120.1 2005/07/19 09:38:20 appldev ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          PV_Ge_Hl_Param_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- This Api is generated with Latest version of
-- Rosetta, where g_miss indicates NULL and
-- NULL indicates missing value. Rosetta Version 1.55
-- End of Comments
-- ===============================================================




--  ========================================================
--
--  NAME
--  Insert_Row
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Insert_Row(
          px_history_log_param_id   IN OUT NOCOPY NUMBER,
          p_entity_history_log_id    NUMBER,
          p_param_name    VARCHAR2,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_param_value    VARCHAR2,
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER,
          p_param_type        VARCHAR2,
          p_lookup_type       VARCHAR2
          );





--  ========================================================
--
--  NAME
--  Update_Row
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Update_Row(
          p_history_log_param_id    NUMBER,
          p_entity_history_log_id    NUMBER,
          p_param_name    VARCHAR2,
          p_object_version_number   IN NUMBER,
          p_param_value    VARCHAR2,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER,
          p_param_type        VARCHAR2,
          p_lookup_type       VARCHAR2);





--  ========================================================
--
--  NAME
--  Delete_Row
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Delete_Row(
    p_history_log_param_id  NUMBER,
    p_object_version_number  NUMBER);




--  ========================================================
--
--  NAME
--  Lock_Row
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Lock_Row(
    p_history_log_param_id  NUMBER,
    p_object_version_number  NUMBER);


END PV_Ge_Hl_Param_PKG;

 

/
