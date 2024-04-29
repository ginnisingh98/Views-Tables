--------------------------------------------------------
--  DDL for Package PV_GE_TEMP_APPROVERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_GE_TEMP_APPROVERS_PKG" AUTHID CURRENT_USER AS
/* $Header: pvxtptas.pls 115.1 2002/12/10 20:59:14 pukken ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          Pv_Ge_Temp_Approvers_PKG
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
          px_entity_approver_id   IN OUT NOCOPY NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_arc_appr_for_entity_code    VARCHAR2,
          p_appr_for_entity_id    NUMBER,
          p_approver_id    NUMBER,
          p_approver_type_code    VARCHAR2,
          p_approval_status_code    VARCHAR2,
          p_workflow_item_key    VARCHAR2,
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER);





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
          p_entity_approver_id    NUMBER,
          p_object_version_number   IN NUMBER,
          p_arc_appr_for_entity_code    VARCHAR2,
          p_appr_for_entity_id    NUMBER,
          p_approver_id    NUMBER,
          p_approver_type_code    VARCHAR2,
          p_approval_status_code    VARCHAR2,
          p_workflow_item_key    VARCHAR2,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER);





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
    p_entity_approver_id  NUMBER,
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
    p_entity_approver_id  NUMBER,
    p_object_version_number  NUMBER);


END Pv_Ge_Temp_Approvers_PKG;

 

/
