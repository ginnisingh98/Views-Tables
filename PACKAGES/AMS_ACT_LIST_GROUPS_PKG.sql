--------------------------------------------------------
--  DDL for Package AMS_ACT_LIST_GROUPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_ACT_LIST_GROUPS_PKG" AUTHID CURRENT_USER AS
/* $Header: amstlgps.pls 115.3 2002/11/22 08:54:32 jieli ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_ACT_LIST_GROUPS_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================

PROCEDURE Insert_Row(
          px_act_list_group_id   IN OUT NOCOPY NUMBER,
          p_act_list_used_by_id    NUMBER,
          p_arc_act_list_used_by    VARCHAR2,
          p_group_code    VARCHAR2,
          p_group_priority    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_status_code    VARCHAR2,
          p_user_status_id    NUMBER,
          p_calling_calendar_id    NUMBER,
          p_release_control_alg_id    NUMBER,
          p_release_strategy    VARCHAR2,
          p_recycling_alg_id    NUMBER,
          p_callback_priority_flag    VARCHAR2,
          p_call_center_ready_flag    VARCHAR2,
          p_dialing_method    VARCHAR2,
          p_quantum    NUMBER,
          p_quota    NUMBER,
          p_quota_reset    NUMBER);

PROCEDURE Update_Row(
          p_act_list_group_id    NUMBER,
          p_act_list_used_by_id    NUMBER,
          p_arc_act_list_used_by    VARCHAR2,
          p_group_code    VARCHAR2,
          p_group_priority    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_status_code    VARCHAR2,
          p_user_status_id    NUMBER,
          p_calling_calendar_id    NUMBER,
          p_release_control_alg_id    NUMBER,
          p_release_strategy    VARCHAR2,
          p_recycling_alg_id    NUMBER,
          p_callback_priority_flag    VARCHAR2,
          p_call_center_ready_flag    VARCHAR2,
          p_dialing_method    VARCHAR2,
          p_quantum    NUMBER,
          p_quota    NUMBER,
          p_quota_reset    NUMBER);

PROCEDURE Delete_Row(
    p_ACT_LIST_GROUP_ID  NUMBER);
PROCEDURE Lock_Row(
          p_act_list_group_id    NUMBER,
          p_act_list_used_by_id    NUMBER,
          p_arc_act_list_used_by    VARCHAR2,
          p_group_code    VARCHAR2,
          p_group_priority    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_status_code    VARCHAR2,
          p_user_status_id    NUMBER,
          p_calling_calendar_id    NUMBER,
          p_release_control_alg_id    NUMBER,
          p_release_strategy    VARCHAR2,
          p_recycling_alg_id    NUMBER,
          p_callback_priority_flag    VARCHAR2,
          p_call_center_ready_flag    VARCHAR2,
          p_dialing_method    VARCHAR2,
          p_quantum    NUMBER,
          p_quota    NUMBER,
          p_quota_reset    NUMBER);

END AMS_ACT_LIST_GROUPS_PKG;

 

/
