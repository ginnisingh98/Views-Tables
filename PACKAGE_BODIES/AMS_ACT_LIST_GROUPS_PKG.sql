--------------------------------------------------------
--  DDL for Package Body AMS_ACT_LIST_GROUPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_ACT_LIST_GROUPS_PKG" as
/* $Header: amstlgpb.pls 115.4 2002/11/22 08:54:30 jieli ship $ */
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


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_ACT_LIST_GROUPS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amstlgpb.pls';


----------------------------------------------------------
----          MEDIA           ----
----------------------------------------------------------

--  ========================================================
--
--  NAME
--  createInsertBody
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

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
          p_quota_reset    NUMBER)

 IS
   x_rowid    VARCHAR2(30);


BEGIN


   px_object_version_number := 1;


   INSERT INTO AMS_ACT_LIST_GROUPS(
           act_list_group_id,
           act_list_used_by_id,
           arc_act_list_used_by,
           group_code,
           group_priority,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           last_update_login,
           object_version_number,
           status_code,
           user_status_id,
           calling_calendar_id,
           release_control_alg_id,
           release_strategy,
           recycling_alg_id,
           callback_priority_flag,
           call_center_ready_flag,
           dialing_method,
           quantum,
           quota,
           quota_reset
   ) VALUES (
           DECODE( px_act_list_group_id, FND_API.g_miss_num, NULL, px_act_list_group_id),
           DECODE( p_act_list_used_by_id, FND_API.g_miss_num, NULL, p_act_list_used_by_id),
           DECODE( p_arc_act_list_used_by, FND_API.g_miss_char, NULL, p_arc_act_list_used_by),
           DECODE( p_group_code, FND_API.g_miss_char, NULL, p_group_code),
           DECODE( p_group_priority, FND_API.g_miss_num, NULL, p_group_priority),
           DECODE( p_last_update_date, FND_API.g_miss_date, NULL, p_last_update_date),
           DECODE( p_last_updated_by, FND_API.g_miss_num, NULL, p_last_updated_by),
           DECODE( p_creation_date, FND_API.g_miss_date, NULL, p_creation_date),
           DECODE( p_created_by, FND_API.g_miss_num, NULL, p_created_by),
           DECODE( p_last_update_login, FND_API.g_miss_num, NULL, p_last_update_login),
           DECODE( px_object_version_number, FND_API.g_miss_num, NULL, px_object_version_number),
           DECODE( p_status_code, FND_API.g_miss_char, NULL, p_status_code),
           DECODE( p_user_status_id, FND_API.g_miss_num, NULL, p_user_status_id),
           DECODE( p_calling_calendar_id, FND_API.g_miss_num, NULL, p_calling_calendar_id),
           DECODE( p_release_control_alg_id, FND_API.g_miss_num, NULL, p_release_control_alg_id),
           DECODE( p_release_strategy, FND_API.g_miss_char, NULL, p_release_strategy),
           DECODE( p_recycling_alg_id, FND_API.g_miss_num, NULL, p_recycling_alg_id),
           DECODE( p_callback_priority_flag, FND_API.g_miss_char, NULL, p_callback_priority_flag),
           DECODE( p_call_center_ready_flag, FND_API.g_miss_char, NULL, p_call_center_ready_flag),
           DECODE( p_dialing_method, FND_API.g_miss_char, NULL, p_dialing_method),
           DECODE( p_quantum, FND_API.g_miss_num, NULL, p_quantum),
           DECODE( p_quota, FND_API.g_miss_num, NULL, p_quota),
           DECODE( p_quota_reset, FND_API.g_miss_num, NULL, p_quota_reset));
END Insert_Row;


----------------------------------------------------------
----          MEDIA           ----
----------------------------------------------------------

--  ========================================================
--
--  NAME
--  createUpdateBody
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
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
          p_quota_reset    NUMBER)

 IS
 BEGIN
    Update AMS_ACT_LIST_GROUPS
    SET
              act_list_group_id = DECODE( p_act_list_group_id, FND_API.g_miss_num, act_list_group_id, p_act_list_group_id),
              act_list_used_by_id = DECODE( p_act_list_used_by_id, FND_API.g_miss_num, act_list_used_by_id, p_act_list_used_by_id),
              arc_act_list_used_by = DECODE( p_arc_act_list_used_by, FND_API.g_miss_char, arc_act_list_used_by, p_arc_act_list_used_by),
              group_code = DECODE( p_group_code, FND_API.g_miss_char, group_code, p_group_code),
              group_priority = DECODE( p_group_priority, FND_API.g_miss_num, group_priority, p_group_priority),
              last_update_date = DECODE( p_last_update_date, FND_API.g_miss_date, last_update_date, p_last_update_date),
              last_updated_by = DECODE( p_last_updated_by, FND_API.g_miss_num, last_updated_by, p_last_updated_by),
              creation_date = DECODE( p_creation_date, FND_API.g_miss_date, creation_date, p_creation_date),
              created_by = DECODE( p_created_by, FND_API.g_miss_num, created_by, p_created_by),
              last_update_login = DECODE( p_last_update_login, FND_API.g_miss_num, last_update_login, p_last_update_login),
              object_version_number = DECODE( p_object_version_number, FND_API.g_miss_num, object_version_number, p_object_version_number),
              status_code = DECODE( p_status_code, FND_API.g_miss_char, status_code, p_status_code),
              user_status_id = DECODE( p_user_status_id, FND_API.g_miss_num, user_status_id, p_user_status_id),
              calling_calendar_id = DECODE( p_calling_calendar_id, FND_API.g_miss_num, calling_calendar_id, p_calling_calendar_id),
              release_control_alg_id = DECODE( p_release_control_alg_id, FND_API.g_miss_num, release_control_alg_id, p_release_control_alg_id),
              release_strategy = DECODE( p_release_strategy, FND_API.g_miss_char, release_strategy, p_release_strategy),
              recycling_alg_id = DECODE( p_recycling_alg_id, FND_API.g_miss_num, recycling_alg_id, p_recycling_alg_id),
              callback_priority_flag = DECODE( p_callback_priority_flag, FND_API.g_miss_char, callback_priority_flag, p_callback_priority_flag),
              call_center_ready_flag = DECODE( p_call_center_ready_flag, FND_API.g_miss_char, call_center_ready_flag, p_call_center_ready_flag),
              dialing_method = DECODE( p_dialing_method, FND_API.g_miss_char, dialing_method, p_dialing_method),
              quantum = DECODE( p_quantum, FND_API.g_miss_num, quantum, p_quantum),
              quota = DECODE( p_quota, FND_API.g_miss_num, quota, p_quota),
              quota_reset = DECODE( p_quota_reset, FND_API.g_miss_num, quota_reset, p_quota_reset)
   WHERE ACT_LIST_GROUP_ID = p_ACT_LIST_GROUP_ID
   AND   object_version_number = p_object_version_number;

   IF (SQL%NOTFOUND) THEN
RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
END Update_Row;


----------------------------------------------------------
----          MEDIA           ----
----------------------------------------------------------

--  ========================================================
--
--  NAME
--  createDeleteBody
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Delete_Row(
    p_ACT_LIST_GROUP_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM AMS_ACT_LIST_GROUPS
    WHERE ACT_LIST_GROUP_ID = p_ACT_LIST_GROUP_ID;
   If (SQL%NOTFOUND) then
RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   End If;
 END Delete_Row ;



----------------------------------------------------------
----          MEDIA           ----
----------------------------------------------------------

--  ========================================================
--
--  NAME
--  createLockBody
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
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
          p_quota_reset    NUMBER)

 IS
   CURSOR C IS
        SELECT *
         FROM AMS_ACT_LIST_GROUPS
        WHERE ACT_LIST_GROUP_ID =  p_ACT_LIST_GROUP_ID
        FOR UPDATE of ACT_LIST_GROUP_ID NOWAIT;
   Recinfo C%ROWTYPE;
 BEGIN
    OPEN c;
    FETCH c INTO Recinfo;
    If (c%NOTFOUND) then
        CLOSE c;
        FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
        APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
    CLOSE C;
    IF (
           (      Recinfo.act_list_group_id = p_act_list_group_id)
       AND (    ( Recinfo.act_list_used_by_id = p_act_list_used_by_id)
            OR (    ( Recinfo.act_list_used_by_id IS NULL )
                AND (  p_act_list_used_by_id IS NULL )))
       AND (    ( Recinfo.arc_act_list_used_by = p_arc_act_list_used_by)
            OR (    ( Recinfo.arc_act_list_used_by IS NULL )
                AND (  p_arc_act_list_used_by IS NULL )))
       AND (    ( Recinfo.group_code = p_group_code)
            OR (    ( Recinfo.group_code IS NULL )
                AND (  p_group_code IS NULL )))
       AND (    ( Recinfo.group_priority = p_group_priority)
            OR (    ( Recinfo.group_priority IS NULL )
                AND (  p_group_priority IS NULL )))
       AND (    ( Recinfo.last_update_date = p_last_update_date)
            OR (    ( Recinfo.last_update_date IS NULL )
                AND (  p_last_update_date IS NULL )))
       AND (    ( Recinfo.last_updated_by = p_last_updated_by)
            OR (    ( Recinfo.last_updated_by IS NULL )
                AND (  p_last_updated_by IS NULL )))
       AND (    ( Recinfo.creation_date = p_creation_date)
            OR (    ( Recinfo.creation_date IS NULL )
                AND (  p_creation_date IS NULL )))
       AND (    ( Recinfo.created_by = p_created_by)
            OR (    ( Recinfo.created_by IS NULL )
                AND (  p_created_by IS NULL )))
       AND (    ( Recinfo.last_update_login = p_last_update_login)
            OR (    ( Recinfo.last_update_login IS NULL )
                AND (  p_last_update_login IS NULL )))
       AND (    ( Recinfo.object_version_number = p_object_version_number)
            OR (    ( Recinfo.object_version_number IS NULL )
                AND (  p_object_version_number IS NULL )))
       AND (    ( Recinfo.status_code = p_status_code)
            OR (    ( Recinfo.status_code IS NULL )
                AND (  p_status_code IS NULL )))
       AND (    ( Recinfo.user_status_id = p_user_status_id)
            OR (    ( Recinfo.user_status_id IS NULL )
                AND (  p_user_status_id IS NULL )))
       AND (    ( Recinfo.calling_calendar_id = p_calling_calendar_id)
            OR (    ( Recinfo.calling_calendar_id IS NULL )
                AND (  p_calling_calendar_id IS NULL )))
       AND (    ( Recinfo.release_control_alg_id = p_release_control_alg_id)
            OR (    ( Recinfo.release_control_alg_id IS NULL )
                AND (  p_release_control_alg_id IS NULL )))
       AND (    ( Recinfo.release_strategy = p_release_strategy)
            OR (    ( Recinfo.release_strategy IS NULL )
                AND (  p_release_strategy IS NULL )))
       AND (    ( Recinfo.recycling_alg_id = p_recycling_alg_id)
            OR (    ( Recinfo.recycling_alg_id IS NULL )
                AND (  p_recycling_alg_id IS NULL )))
       AND (    ( Recinfo.callback_priority_flag = p_callback_priority_flag)
            OR (    ( Recinfo.callback_priority_flag IS NULL )
                AND (  p_callback_priority_flag IS NULL )))
       AND (    ( Recinfo.call_center_ready_flag = p_call_center_ready_flag)
            OR (    ( Recinfo.call_center_ready_flag IS NULL )
                AND (  p_call_center_ready_flag IS NULL )))
       AND (    ( Recinfo.dialing_method = p_dialing_method)
            OR (    ( Recinfo.dialing_method IS NULL )
                AND (  p_dialing_method IS NULL )))
       AND (    ( Recinfo.quantum = p_quantum)
            OR (    ( Recinfo.quantum IS NULL )
                AND (  p_quantum IS NULL )))
       AND (    ( Recinfo.quota = p_quota)
            OR (    ( Recinfo.quota IS NULL )
                AND (  p_quota IS NULL )))
       AND (    ( Recinfo.quota_reset = p_quota_reset)
            OR (    ( Recinfo.quota_reset IS NULL )
                AND (  p_quota_reset IS NULL )))
       ) THEN
       RETURN;
   ELSE
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   END IF;
END Lock_Row;

END AMS_ACT_LIST_GROUPS_PKG;

/
