--------------------------------------------------------
--  DDL for Package Body AMS_LIST_SELECT_ACTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_LIST_SELECT_ACTIONS_PKG" as
/* $Header: amstlsab.pls 120.0 2005/05/31 23:05:25 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_LIST_SELECT_ACTIONS_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_LIST_SELECT_ACTIONS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amstlsab.pls';


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
          px_list_select_action_id   IN OUT NOCOPY NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_list_header_id    NUMBER,
          p_order_number    NUMBER,
          p_list_action_type    VARCHAR2,
          p_incl_object_name    VARCHAR2,
          p_arc_incl_object_from    VARCHAR2,
          p_incl_object_id    NUMBER,
          p_incl_object_wb_sheet    VARCHAR2,
          p_incl_object_wb_owner    NUMBER,
          p_incl_object_cell_code    VARCHAR2,
          p_rank    NUMBER,
          p_no_of_rows_available    NUMBER,
          p_no_of_rows_requested    NUMBER,
          p_no_of_rows_used    NUMBER,
          p_distribution_pct    NUMBER,
          p_result_text    VARCHAR2,
          p_description    VARCHAR2,
          p_arc_action_used_by    VARCHAR2,
          p_action_used_by_id    NUMBER,
          p_incl_control_group    VARCHAR2,
          p_no_of_rows_targeted    NUMBER)

 IS
   x_rowid    VARCHAR2(30);


BEGIN


   px_object_version_number := 1;


   INSERT INTO AMS_LIST_SELECT_ACTIONS(
           list_select_action_id,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           last_update_login,
           object_version_number,
           list_header_id,
           order_number,
           list_action_type,
           incl_object_name,
           arc_incl_object_from,
           incl_object_id,
           incl_object_wb_sheet,
           incl_object_wb_owner,
           incl_object_cell_code,
           rank,
           no_of_rows_available,
           no_of_rows_requested,
           no_of_rows_used,
           distribution_pct,
           result_text,
           description,
           arc_action_used_by,
           action_used_by_id,
           incl_control_group,
           no_of_rows_targeted
   ) VALUES (
           DECODE( px_list_select_action_id, FND_API.g_miss_num, NULL, px_list_select_action_id),
           DECODE( p_last_update_date, FND_API.g_miss_date, NULL, p_last_update_date),
           DECODE( p_last_updated_by, FND_API.g_miss_num, NULL, p_last_updated_by),
           DECODE( p_creation_date, FND_API.g_miss_date, NULL, p_creation_date),
           DECODE( p_created_by, FND_API.g_miss_num, NULL, p_created_by),
           DECODE( p_last_update_login, FND_API.g_miss_num, NULL, p_last_update_login),
           DECODE( px_object_version_number, FND_API.g_miss_num, NULL, px_object_version_number),
           DECODE( p_list_header_id, FND_API.g_miss_num, NULL, p_list_header_id),
           DECODE( p_order_number, FND_API.g_miss_num, NULL, p_order_number),
           DECODE( p_list_action_type, FND_API.g_miss_char, NULL, p_list_action_type),
           DECODE( p_incl_object_name, FND_API.g_miss_char, NULL, p_incl_object_name),
           DECODE( p_arc_incl_object_from, FND_API.g_miss_char, NULL, p_arc_incl_object_from),
           DECODE( p_incl_object_id, FND_API.g_miss_num, NULL, p_incl_object_id),
           DECODE( p_incl_object_wb_sheet, FND_API.g_miss_char, NULL, p_incl_object_wb_sheet),
           DECODE( p_incl_object_wb_owner, FND_API.g_miss_num, NULL, p_incl_object_wb_owner),
           DECODE( p_incl_object_cell_code, FND_API.g_miss_char, NULL, p_incl_object_cell_code),
           DECODE( p_rank, FND_API.g_miss_num, NULL, p_rank),
           DECODE( p_no_of_rows_available, FND_API.g_miss_num, NULL, p_no_of_rows_available),
           DECODE( p_no_of_rows_requested, FND_API.g_miss_num, NULL, p_no_of_rows_requested),
           DECODE( p_no_of_rows_used, FND_API.g_miss_num, NULL, p_no_of_rows_used),
           DECODE( p_distribution_pct, FND_API.g_miss_num, NULL, p_distribution_pct),
           DECODE( p_result_text, FND_API.g_miss_char, NULL, p_result_text),
           DECODE( p_description, FND_API.g_miss_char, NULL, p_description),
           DECODE( p_arc_action_used_by, FND_API.g_miss_char, NULL, p_arc_action_used_by),
           DECODE( p_action_used_by_id, FND_API.g_miss_num, NULL, p_action_used_by_id),
           DECODE( p_incl_control_group, FND_API.g_miss_char, NULL, p_incl_control_group),
           DECODE( p_no_of_rows_targeted, FND_API.g_miss_num, NULL, p_no_of_rows_targeted));
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
          p_list_select_action_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_list_header_id    NUMBER,
          p_order_number    NUMBER,
          p_list_action_type    VARCHAR2,
          p_incl_object_name    VARCHAR2,
          p_arc_incl_object_from    VARCHAR2,
          p_incl_object_id    NUMBER,
          p_incl_object_wb_sheet    VARCHAR2,
          p_incl_object_wb_owner    NUMBER,
          p_incl_object_cell_code    VARCHAR2,
          p_rank    NUMBER,
          p_no_of_rows_available    NUMBER,
          p_no_of_rows_requested    NUMBER,
          p_no_of_rows_used    NUMBER,
          p_distribution_pct    NUMBER,
          p_result_text    VARCHAR2,
          p_description    VARCHAR2,
          p_arc_action_used_by    VARCHAR2,
          p_action_used_by_id    NUMBER,
          p_incl_control_group    VARCHAR2,
          p_no_of_rows_targeted    NUMBER)

 IS
 BEGIN
    Update AMS_LIST_SELECT_ACTIONS
    SET
              list_select_action_id = DECODE( p_list_select_action_id, FND_API.g_miss_num, list_select_action_id, p_list_select_action_id),
              last_update_date = DECODE( p_last_update_date, FND_API.g_miss_date, last_update_date, p_last_update_date),
              last_updated_by = DECODE( p_last_updated_by, FND_API.g_miss_num, last_updated_by, p_last_updated_by),
              creation_date = DECODE( p_creation_date, FND_API.g_miss_date, creation_date, p_creation_date),
              created_by = DECODE( p_created_by, FND_API.g_miss_num, created_by, p_created_by),
              last_update_login = DECODE( p_last_update_login, FND_API.g_miss_num, last_update_login, p_last_update_login),
              object_version_number = DECODE( p_object_version_number, FND_API.g_miss_num, object_version_number, p_object_version_number),
              list_header_id = DECODE( p_list_header_id, FND_API.g_miss_num, list_header_id, p_list_header_id),
              order_number = DECODE( p_order_number, FND_API.g_miss_num, order_number, p_order_number),
              list_action_type = DECODE( p_list_action_type, FND_API.g_miss_char, list_action_type, p_list_action_type),
              incl_object_name = DECODE( p_incl_object_name, FND_API.g_miss_char, incl_object_name, p_incl_object_name),
              arc_incl_object_from = DECODE( p_arc_incl_object_from, FND_API.g_miss_char, arc_incl_object_from, p_arc_incl_object_from),
              incl_object_id = DECODE( p_incl_object_id, FND_API.g_miss_num, incl_object_id, p_incl_object_id),
              incl_object_wb_sheet = DECODE( p_incl_object_wb_sheet, FND_API.g_miss_char, incl_object_wb_sheet, p_incl_object_wb_sheet),
              incl_object_wb_owner = DECODE( p_incl_object_wb_owner, FND_API.g_miss_num, incl_object_wb_owner, p_incl_object_wb_owner),
              incl_object_cell_code = DECODE( p_incl_object_cell_code, FND_API.g_miss_char, incl_object_cell_code, p_incl_object_cell_code),
              rank = DECODE( p_rank, FND_API.g_miss_num, rank, p_rank),
              no_of_rows_available = DECODE( p_no_of_rows_available, FND_API.g_miss_num, no_of_rows_available, p_no_of_rows_available),
              no_of_rows_requested = DECODE( p_no_of_rows_requested, FND_API.g_miss_num, no_of_rows_requested, p_no_of_rows_requested),
              no_of_rows_used = DECODE( p_no_of_rows_used, FND_API.g_miss_num, no_of_rows_used, p_no_of_rows_used),
              distribution_pct = DECODE( p_distribution_pct, FND_API.g_miss_num, distribution_pct, p_distribution_pct),
              result_text = DECODE( p_result_text, FND_API.g_miss_char, result_text, p_result_text),
              description = DECODE( p_description, FND_API.g_miss_char, description, p_description),
              arc_action_used_by = DECODE( p_arc_action_used_by, FND_API.g_miss_char, arc_action_used_by, p_arc_action_used_by),
              action_used_by_id = DECODE( p_action_used_by_id, FND_API.g_miss_num, action_used_by_id, p_action_used_by_id),
              incl_control_group = DECODE( p_incl_control_group, FND_API.g_miss_char, incl_control_group, p_incl_control_group),
              no_of_rows_targeted = DECODE( p_no_of_rows_targeted, FND_API.g_miss_num, no_of_rows_targeted, p_no_of_rows_targeted)
   WHERE LIST_SELECT_ACTION_ID = p_LIST_SELECT_ACTION_ID;
  -- AND   object_version_number = p_object_version_number;

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
    p_LIST_SELECT_ACTION_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM AMS_LIST_SELECT_ACTIONS
    WHERE LIST_SELECT_ACTION_ID = p_LIST_SELECT_ACTION_ID;
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
          p_list_select_action_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_list_header_id    NUMBER,
          p_order_number    NUMBER,
          p_list_action_type    VARCHAR2,
          p_incl_object_name    VARCHAR2,
          p_arc_incl_object_from    VARCHAR2,
          p_incl_object_id    NUMBER,
          p_incl_object_wb_sheet    VARCHAR2,
          p_incl_object_wb_owner    NUMBER,
          p_incl_object_cell_code    VARCHAR2,
          p_rank    NUMBER,
          p_no_of_rows_available    NUMBER,
          p_no_of_rows_requested    NUMBER,
          p_no_of_rows_used    NUMBER,
          p_distribution_pct    NUMBER,
          p_result_text    VARCHAR2,
          p_description    VARCHAR2,
          p_arc_action_used_by    VARCHAR2,
          p_action_used_by_id    NUMBER,
          p_incl_control_group    VARCHAR2,
          p_no_of_rows_targeted    NUMBER)

 IS
   CURSOR C IS
        SELECT *
         FROM AMS_LIST_SELECT_ACTIONS
        WHERE LIST_SELECT_ACTION_ID =  p_LIST_SELECT_ACTION_ID
        FOR UPDATE of LIST_SELECT_ACTION_ID NOWAIT;
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
           (      Recinfo.list_select_action_id = p_list_select_action_id)
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
       AND (    ( Recinfo.list_header_id = p_list_header_id)
            OR (    ( Recinfo.list_header_id IS NULL )
                AND (  p_list_header_id IS NULL )))
       AND (    ( Recinfo.order_number = p_order_number)
            OR (    ( Recinfo.order_number IS NULL )
                AND (  p_order_number IS NULL )))
       AND (    ( Recinfo.list_action_type = p_list_action_type)
            OR (    ( Recinfo.list_action_type IS NULL )
                AND (  p_list_action_type IS NULL )))
       AND (    ( Recinfo.incl_object_name = p_incl_object_name)
            OR (    ( Recinfo.incl_object_name IS NULL )
                AND (  p_incl_object_name IS NULL )))
       AND (    ( Recinfo.arc_incl_object_from = p_arc_incl_object_from)
            OR (    ( Recinfo.arc_incl_object_from IS NULL )
                AND (  p_arc_incl_object_from IS NULL )))
       AND (    ( Recinfo.incl_object_id = p_incl_object_id)
            OR (    ( Recinfo.incl_object_id IS NULL )
                AND (  p_incl_object_id IS NULL )))
       AND (    ( Recinfo.incl_object_wb_sheet = p_incl_object_wb_sheet)
            OR (    ( Recinfo.incl_object_wb_sheet IS NULL )
                AND (  p_incl_object_wb_sheet IS NULL )))
       AND (    ( Recinfo.incl_object_wb_owner = p_incl_object_wb_owner)
            OR (    ( Recinfo.incl_object_wb_owner IS NULL )
                AND (  p_incl_object_wb_owner IS NULL )))
       AND (    ( Recinfo.incl_object_cell_code = p_incl_object_cell_code)
            OR (    ( Recinfo.incl_object_cell_code IS NULL )
                AND (  p_incl_object_cell_code IS NULL )))
       AND (    ( Recinfo.rank = p_rank)
            OR (    ( Recinfo.rank IS NULL )
                AND (  p_rank IS NULL )))
       AND (    ( Recinfo.no_of_rows_available = p_no_of_rows_available)
            OR (    ( Recinfo.no_of_rows_available IS NULL )
                AND (  p_no_of_rows_available IS NULL )))
       AND (    ( Recinfo.no_of_rows_requested = p_no_of_rows_requested)
            OR (    ( Recinfo.no_of_rows_requested IS NULL )
                AND (  p_no_of_rows_requested IS NULL )))
       AND (    ( Recinfo.no_of_rows_used = p_no_of_rows_used)
            OR (    ( Recinfo.no_of_rows_used IS NULL )
                AND (  p_no_of_rows_used IS NULL )))
       AND (    ( Recinfo.distribution_pct = p_distribution_pct)
            OR (    ( Recinfo.distribution_pct IS NULL )
                AND (  p_distribution_pct IS NULL )))
       AND (    ( Recinfo.result_text = p_result_text)
            OR (    ( Recinfo.result_text IS NULL )
                AND (  p_result_text IS NULL )))
       AND (    ( Recinfo.description = p_description)
            OR (    ( Recinfo.description IS NULL )
                AND (  p_description IS NULL )))
       AND (    ( Recinfo.arc_action_used_by = p_arc_action_used_by)
            OR (    ( Recinfo.arc_action_used_by IS NULL )
                AND (  p_arc_action_used_by IS NULL )))
       AND (    ( Recinfo.action_used_by_id = p_action_used_by_id)
            OR (    ( Recinfo.action_used_by_id IS NULL )
                AND (  p_action_used_by_id IS NULL )))
       AND (    ( Recinfo.incl_control_group = p_incl_control_group)
            OR (    ( Recinfo.incl_control_group IS NULL )
                AND (  p_incl_control_group IS NULL )))
       AND (    ( Recinfo.no_of_rows_targeted = p_no_of_rows_targeted)
            OR (    ( Recinfo.no_of_rows_targeted IS NULL )
                AND (  p_no_of_rows_targeted IS NULL )))
       ) THEN
       RETURN;
   ELSE
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   END IF;
END Lock_Row;

PROCEDURE LOAD_ROW(
          p_owner                    varchar2,
          p_list_select_action_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_list_header_id    NUMBER,
          p_order_number    NUMBER,
          p_list_action_type    VARCHAR2,
          p_incl_object_name    VARCHAR2,
          p_arc_incl_object_from    VARCHAR2,
          p_incl_object_id    NUMBER,
          p_incl_object_wb_sheet    VARCHAR2,
          p_incl_object_wb_owner    NUMBER,
          p_incl_object_cell_code    VARCHAR2,
          p_rank    NUMBER,
          p_no_of_rows_available    NUMBER,
          p_no_of_rows_requested    NUMBER,
          p_no_of_rows_used    NUMBER,
          p_distribution_pct    NUMBER,
          p_result_text    VARCHAR2,
          p_description    VARCHAR2,
          p_arc_action_used_by    VARCHAR2,
          p_action_used_by_id    NUMBER,
          p_incl_control_group    VARCHAR2,
          p_no_of_rows_targeted    NUMBER,
          p_custom_mode    VARCHAR2

          ) is
l_dummy_char  varchar2(1);
x_return_status    varchar2(1);
l_row_id    varchar2(100);
l_user_id    number;

l_last_updated_by number;

l_object_version_number    NUMBER := p_object_version_number   ;
l_list_select_action_id    NUMBER := p_list_select_action_id   ;
cursor c_chk_col_exists is
select 'x'
from   ams_list_select_actions
where  list_select_action_id = p_list_select_action_id;

CURSOR  c_obj_verno IS
      SELECT object_version_number, last_updated_by
      FROM   ams_list_select_actions
      WHERE  list_select_action_id =  p_list_select_action_id;

begin
  if p_OWNER = 'SEED' then
    l_user_id := 1;
  elsif p_OWNER = 'ORACLE' then
    l_user_id := 2;
  elsif p_OWNER = 'SYSADMIN' THEN
    l_user_id := 0;

  end if;
  open c_chk_col_exists;
  fetch c_chk_col_exists into l_dummy_char;
  if c_chk_col_exists%notfound then
     close c_chk_col_exists;

      AMS_LIST_SELECT_ACTIONS_PKG.Insert_Row(
          px_list_select_action_id  => l_list_select_action_id,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => nvl(l_user_id,p_last_updated_by),
          p_creation_date  => SYSDATE,
          p_created_by  => nvl(l_user_id,p_created_by),
          p_last_update_login  => nvl(l_user_id,p_last_update_login),
          px_object_version_number  => l_object_version_number,
          p_list_header_id  => p_list_header_id,
          p_order_number  => p_order_number,
          p_list_action_type  => p_list_action_type,
          p_incl_object_name  => p_incl_object_name,
          p_arc_incl_object_from  => p_arc_incl_object_from,
          p_incl_object_id  => p_incl_object_id,
          p_incl_object_wb_sheet  => p_incl_object_wb_sheet,
          p_incl_object_wb_owner  => p_incl_object_wb_owner,
          p_incl_object_cell_code  => p_incl_object_cell_code,
          p_rank  => p_rank,
          p_no_of_rows_available  => p_no_of_rows_available,
          p_no_of_rows_requested  => p_no_of_rows_requested,
          p_no_of_rows_used  => p_no_of_rows_used,
          p_distribution_pct  => p_distribution_pct,
          p_result_text  => p_result_text,
          p_description  => p_description,
          p_arc_action_used_by  => p_arc_action_used_by,
          p_action_used_by_id  => p_action_used_by_id,
          p_incl_control_group  => p_incl_control_group,
          p_no_of_rows_targeted  => p_no_of_rows_targeted);
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
 else
    close c_chk_col_exists;

      OPEN c_obj_verno;
      FETCH c_obj_verno INTO l_object_version_number  ,l_last_updated_by;
      CLOSE c_obj_verno;


      if (l_last_updated_by in (1,2,0) OR
              NVL(p_custom_mode,'PRESERVE')='FORCE') THEN



      -- Invoke table handler(AMS_LIST_SELECT_ACTIONS_PKG.Update_Row)
      AMS_LIST_SELECT_ACTIONS_PKG.Update_Row(
          p_list_select_action_id  => l_list_select_action_id,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => nvl(l_user_id,p_last_updated_by),
          p_creation_date  => SYSDATE,
          p_created_by  => nvl(l_user_id,p_created_by),
          p_last_update_login  => nvl(l_user_id,p_last_update_login),
          p_object_version_number  => p_object_version_number,
          p_list_header_id  => p_list_header_id,
          p_order_number  => p_order_number,
          p_list_action_type  => p_list_action_type,
          p_incl_object_name  => p_incl_object_name,
          p_arc_incl_object_from  => p_arc_incl_object_from,
          p_incl_object_id  => p_incl_object_id,
          p_incl_object_wb_sheet  => p_incl_object_wb_sheet,
          p_incl_object_wb_owner  => p_incl_object_wb_owner,
          p_incl_object_cell_code  => p_incl_object_cell_code,
          p_rank  => p_rank,
          p_no_of_rows_available  => p_no_of_rows_available,
          p_no_of_rows_requested  => p_no_of_rows_requested,
          p_no_of_rows_used  => p_no_of_rows_used,
          p_distribution_pct  => p_distribution_pct,
          p_result_text  => p_result_text,
          p_description  => p_description,
          p_arc_action_used_by  => p_arc_action_used_by,
          p_action_used_by_id  => p_action_used_by_id,
          p_incl_control_group  => p_incl_control_group,
          p_no_of_rows_targeted  => p_no_of_rows_targeted);
      --

      end if;
 end if;
end;


END AMS_LIST_SELECT_ACTIONS_PKG;

/
