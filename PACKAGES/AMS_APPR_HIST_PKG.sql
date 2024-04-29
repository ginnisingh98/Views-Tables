--------------------------------------------------------
--  DDL for Package AMS_APPR_HIST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_APPR_HIST_PKG" AUTHID CURRENT_USER AS
/* $Header: amstaphs.pls 115.0 2002/12/01 12:10:51 vmodur noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_Appr_Hist_PKG
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
          p_object_id   IN OUT NOCOPY NUMBER,
          p_object_type_code    VARCHAR2,
          p_sequence_num    NUMBER,
          p_object_version_num    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_action_code    VARCHAR2,
          p_action_date    DATE,
          p_approver_id    NUMBER,
          p_approval_detail_id    NUMBER,
          p_note    VARCHAR2,
          p_last_update_login    NUMBER,
          p_approval_type    VARCHAR2,
          p_approver_type    VARCHAR2,
          p_custom_setup_id    NUMBER,
	  p_log_message  VARCHAR2);





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
          p_object_id    NUMBER,
          p_object_type_code    VARCHAR2,
          p_sequence_num    NUMBER,
          p_object_version_num    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_action_code    VARCHAR2,
          p_action_date    DATE,
          p_approver_id    NUMBER,
          p_approval_detail_id    NUMBER,
          p_note    VARCHAR2,
          p_last_update_login    NUMBER,
          p_approval_type    VARCHAR2,
          p_approver_type    VARCHAR2,
          p_custom_setup_id    NUMBER,
	  p_log_message VARCHAR2);





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
    p_object_id  NUMBER,
    p_object_type_code    VARCHAR2,
    p_sequence_num    NUMBER,
    p_action_code     VARCHAR2,
    p_object_version_num    NUMBER,
    p_approval_type VARCHAR2);


END AMS_Appr_Hist_PKG;

 

/
