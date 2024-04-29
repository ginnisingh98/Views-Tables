--------------------------------------------------------
--  DDL for Package Body AMS_TRIGGER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_TRIGGER_PKG" as
/* $Header: amsttrgb.pls 115.2 2002/11/16 01:45:03 dbiswas ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--      AMS_TRIGGER_PKG
-- Purpose
--      Table api for triggers.
-- History
--      16-apr-2002    soagrawa     Created
--      16-apr-2002    soagrawa     Added add_language for bug# 2323843
--      12-jun-2002    soagrawa     Added insert_row, update_row, delete_row, lock_row
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_TRIGGER_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amsttrgb.pls';




 --  ========================================================
 --
 --  NAME
 --      Insert_Row
 --
 --  PURPOSE
 --
 --  NOTES
 --
 --  HISTORY
--      16-apr-2002    soagrawa     Created
 --  ========================================================

 PROCEDURE Insert_Row(
           px_trigger_id   IN OUT NOCOPY NUMBER,
           p_last_update_date    DATE,
           p_last_updated_by    NUMBER,
           p_creation_date    DATE,
           p_created_by    NUMBER,
           p_last_update_login    NUMBER,
           px_object_version_number   IN OUT NOCOPY NUMBER,
           p_process_id    NUMBER,
           p_trigger_created_for_id    NUMBER,
           p_arc_trigger_created_for    VARCHAR2,
           p_triggering_type    VARCHAR2,
           p_trigger_name    VARCHAR2,
           p_view_application_id    NUMBER,
           p_start_date_time    DATE,
           p_last_run_date_time    DATE,
           p_next_run_date_time    DATE,
           p_repeat_daily_start_time    DATE,
           p_repeat_daily_end_time    DATE,
           p_repeat_frequency_type    VARCHAR2,
           p_repeat_every_x_frequency    NUMBER,
           p_repeat_stop_date_time    DATE,
           p_metrics_refresh_type    VARCHAR2,
           p_description    VARCHAR2,
           p_timezone_id    NUMBER,
           p_user_start_date_time    DATE,
           p_user_last_run_date_time    DATE,
           p_user_next_run_date_time    DATE,
           p_user_repeat_daily_start_time    DATE,
           p_user_repeat_daily_end_time    DATE,
           p_user_repeat_stop_date_time    DATE,
           p_security_group_id    NUMBER)

  IS
    x_rowid    VARCHAR2(30);


 BEGIN


    px_object_version_number := 1;


    INSERT INTO AMS_TRIGGERS(
            trigger_id,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            last_update_login,
            object_version_number,
            process_id,
            trigger_created_for_id,
            arc_trigger_created_for,
            triggering_type,
            trigger_name,
            view_application_id,
            start_date_time,
            last_run_date_time,
            next_run_date_time,
            repeat_daily_start_time,
            repeat_daily_end_time,
            repeat_frequency_type,
            repeat_every_x_frequency,
            repeat_stop_date_time,
            metrics_refresh_type,
            description,
           timezone_id,
            user_start_date_time,
            user_last_run_date_time,
            user_next_run_date_time,
            user_repeat_daily_start_time,
            user_repeat_daily_end_time,
            user_repeat_stop_date_time,
            security_group_id
    ) VALUES (
            DECODE( px_trigger_id, FND_API.g_miss_num, NULL, px_trigger_id),
            DECODE( p_last_update_date, FND_API.g_miss_date, NULL, p_last_update_date),
            DECODE( p_last_updated_by, FND_API.g_miss_num, NULL, p_last_updated_by),
            DECODE( p_creation_date, FND_API.g_miss_date, NULL, p_creation_date),
            DECODE( p_created_by, FND_API.g_miss_num, NULL, p_created_by),
            DECODE( p_last_update_login, FND_API.g_miss_num, NULL, p_last_update_login),
            DECODE( px_object_version_number, FND_API.g_miss_num, NULL, px_object_version_number),
            DECODE( p_process_id, FND_API.g_miss_num, NULL, p_process_id),
            DECODE( p_trigger_created_for_id, FND_API.g_miss_num, NULL, p_trigger_created_for_id),
            DECODE( p_arc_trigger_created_for, FND_API.g_miss_char, NULL, p_arc_trigger_created_for),
            DECODE( p_triggering_type, FND_API.g_miss_char, NULL, p_triggering_type),
            DECODE( p_trigger_name, FND_API.g_miss_char, NULL, p_trigger_name),
            DECODE( p_view_application_id, FND_API.g_miss_num, NULL, p_view_application_id),
            DECODE( p_start_date_time, FND_API.g_miss_date, NULL, p_start_date_time),
            DECODE( p_last_run_date_time, FND_API.g_miss_date, NULL, p_last_run_date_time),
            DECODE( p_next_run_date_time, FND_API.g_miss_date, NULL, p_next_run_date_time),
            DECODE( p_repeat_daily_start_time, FND_API.g_miss_date, NULL, p_repeat_daily_start_time),
            DECODE( p_repeat_daily_end_time, FND_API.g_miss_date, NULL, p_repeat_daily_end_time),
            DECODE( p_repeat_frequency_type, FND_API.g_miss_char, NULL, p_repeat_frequency_type),
            DECODE( p_repeat_every_x_frequency, FND_API.g_miss_num, NULL, p_repeat_every_x_frequency),
            DECODE( p_repeat_stop_date_time, FND_API.g_miss_date, NULL, p_repeat_stop_date_time),
            DECODE( p_metrics_refresh_type, FND_API.g_miss_char, NULL, p_metrics_refresh_type),
            DECODE( p_description, FND_API.g_miss_char, NULL, p_description),
            DECODE( p_timezone_id, FND_API.g_miss_num, NULL, p_timezone_id),
            DECODE( p_user_start_date_time, FND_API.g_miss_date, NULL, p_user_start_date_time),
            DECODE( p_user_last_run_date_time, FND_API.g_miss_date, NULL, p_user_last_run_date_time),
            DECODE( p_user_next_run_date_time, FND_API.g_miss_date, NULL, p_user_next_run_date_time),
            DECODE( p_user_repeat_daily_start_time, FND_API.g_miss_date, NULL, p_user_repeat_daily_start_time),
            DECODE( p_user_repeat_daily_end_time, FND_API.g_miss_date, NULL, p_user_repeat_daily_end_time),
            DECODE( p_user_repeat_stop_date_time, FND_API.g_miss_date, NULL, p_user_repeat_stop_date_time),
            DECODE( p_security_group_id, FND_API.g_miss_num, NULL, p_security_group_id));
 END Insert_Row;



 --  ========================================================
 --
 --  NAME
 --      Update_Row
 --
 --  PURPOSE
 --
 --  NOTES
 --
 --  HISTORY
--      16-apr-2002    soagrawa     Created
 --  ========================================================

 PROCEDURE Update_Row(
           p_trigger_id    NUMBER,
           p_last_update_date    DATE,
           p_last_updated_by    NUMBER,
           p_creation_date    DATE,
           p_created_by    NUMBER,
           p_last_update_login    NUMBER,
           p_object_version_number    NUMBER,
           p_process_id    NUMBER,
           p_trigger_created_for_id    NUMBER,
           p_arc_trigger_created_for    VARCHAR2,
           p_triggering_type    VARCHAR2,
           p_trigger_name    VARCHAR2,
           p_view_application_id    NUMBER,
           p_start_date_time    DATE,
           p_last_run_date_time    DATE,
           p_next_run_date_time    DATE,
           p_repeat_daily_start_time    DATE,
           p_repeat_daily_end_time    DATE,
           p_repeat_frequency_type    VARCHAR2,
           p_repeat_every_x_frequency    NUMBER,
           p_repeat_stop_date_time    DATE,
           p_metrics_refresh_type    VARCHAR2,
           p_description    VARCHAR2,
           p_timezone_id    NUMBER,
           p_user_start_date_time    DATE,
           p_user_last_run_date_time    DATE,
           p_user_next_run_date_time    DATE,
           p_user_repeat_daily_start_time    DATE,
           p_user_repeat_daily_end_time    DATE,
           p_user_repeat_stop_date_time    DATE,
           p_security_group_id    NUMBER)

  IS
  BEGIN
     Update AMS_TRIGGERS
     SET
               trigger_id = DECODE( p_trigger_id, FND_API.g_miss_num, trigger_id, p_trigger_id),
               last_update_date = DECODE( p_last_update_date, FND_API.g_miss_date, last_update_date, p_last_update_date),
               last_updated_by = DECODE( p_last_updated_by, FND_API.g_miss_num, last_updated_by, p_last_updated_by),
               creation_date = DECODE( p_creation_date, FND_API.g_miss_date, creation_date, p_creation_date),
               created_by = DECODE( p_created_by, FND_API.g_miss_num, created_by, p_created_by),
               last_update_login = DECODE( p_last_update_login, FND_API.g_miss_num, last_update_login, p_last_update_login),
               object_version_number = DECODE( p_object_version_number, FND_API.g_miss_num, object_version_number, p_object_version_number),
               process_id = DECODE( p_process_id, FND_API.g_miss_num, process_id, p_process_id),
               trigger_created_for_id = DECODE( p_trigger_created_for_id, FND_API.g_miss_num, trigger_created_for_id, p_trigger_created_for_id),
               arc_trigger_created_for = DECODE( p_arc_trigger_created_for, FND_API.g_miss_char, arc_trigger_created_for, p_arc_trigger_created_for),
               triggering_type = DECODE( p_triggering_type, FND_API.g_miss_char, triggering_type, p_triggering_type),
               trigger_name = DECODE( p_trigger_name, FND_API.g_miss_char, trigger_name, p_trigger_name),
               view_application_id = DECODE( p_view_application_id, FND_API.g_miss_num, view_application_id, p_view_application_id),
               start_date_time = DECODE( p_start_date_time, FND_API.g_miss_date, start_date_time, p_start_date_time),
               last_run_date_time = DECODE( p_last_run_date_time, FND_API.g_miss_date, last_run_date_time, p_last_run_date_time),
               next_run_date_time = DECODE( p_next_run_date_time, FND_API.g_miss_date, next_run_date_time, p_next_run_date_time),
               repeat_daily_start_time = DECODE( p_repeat_daily_start_time, FND_API.g_miss_date, repeat_daily_start_time, p_repeat_daily_start_time),
               repeat_daily_end_time = DECODE( p_repeat_daily_end_time, FND_API.g_miss_date, repeat_daily_end_time, p_repeat_daily_end_time),
               repeat_frequency_type = DECODE( p_repeat_frequency_type, FND_API.g_miss_char, repeat_frequency_type, p_repeat_frequency_type),
               repeat_every_x_frequency = DECODE( p_repeat_every_x_frequency, FND_API.g_miss_num, repeat_every_x_frequency, p_repeat_every_x_frequency),
               repeat_stop_date_time = DECODE( p_repeat_stop_date_time, FND_API.g_miss_date, repeat_stop_date_time, p_repeat_stop_date_time),
               metrics_refresh_type = DECODE( p_metrics_refresh_type, FND_API.g_miss_char, metrics_refresh_type, p_metrics_refresh_type),
               description = DECODE( p_description, FND_API.g_miss_char, description, p_description),
               timezone_id = DECODE( p_timezone_id, FND_API.g_miss_num, timezone_id, p_timezone_id),
               user_start_date_time = DECODE( p_user_start_date_time, FND_API.g_miss_date, user_start_date_time, p_user_start_date_time),
               user_last_run_date_time = DECODE( p_user_last_run_date_time, FND_API.g_miss_date, user_last_run_date_time, p_user_last_run_date_time),
               user_next_run_date_time = DECODE( p_user_next_run_date_time, FND_API.g_miss_date, user_next_run_date_time, p_user_next_run_date_time),
               user_repeat_daily_start_time = DECODE( p_user_repeat_daily_start_time, FND_API.g_miss_date, user_repeat_daily_start_time, p_user_repeat_daily_start_time),
               user_repeat_daily_end_time = DECODE( p_user_repeat_daily_end_time, FND_API.g_miss_date, user_repeat_daily_end_time, p_user_repeat_daily_end_time),
               user_repeat_stop_date_time = DECODE( p_user_repeat_stop_date_time, FND_API.g_miss_date, user_repeat_stop_date_time, p_user_repeat_stop_date_time),
               security_group_id = DECODE( p_security_group_id, FND_API.g_miss_num, security_group_id, p_security_group_id)
    WHERE TRIGGER_ID = p_TRIGGER_ID
    AND   object_version_number = p_object_version_number;

    IF (SQL%NOTFOUND) THEN
 RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
 END Update_Row;



 --  ========================================================
 --
 --  NAME
 --      Delete_Row
 --
 --  PURPOSE
 --
 --  NOTES
 --
 --  HISTORY
--      16-apr-2002    soagrawa     Created
 --  ========================================================

 PROCEDURE Delete_Row(
     p_TRIGGER_ID  NUMBER)
  IS
  BEGIN
    DELETE FROM AMS_TRIGGERS
     WHERE TRIGGER_ID = p_TRIGGER_ID;
    If (SQL%NOTFOUND) then
 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    End If;
  END Delete_Row ;




 --  ========================================================
 --
 --  NAME
 --      Lock_Row
 --
 --  PURPOSE
 --
 --  NOTES
 --
 --  HISTORY
--      16-apr-2002    soagrawa     Created
 --  ========================================================


 PROCEDURE Lock_Row(
           p_trigger_id    NUMBER,
           p_last_update_date    DATE,
           p_last_updated_by    NUMBER,
           p_creation_date    DATE,
           p_created_by    NUMBER,
           p_last_update_login    NUMBER,
           p_object_version_number    NUMBER,
           p_process_id    NUMBER,
           p_trigger_created_for_id    NUMBER,
           p_arc_trigger_created_for    VARCHAR2,
           p_triggering_type    VARCHAR2,
           p_trigger_name    VARCHAR2,
           p_view_application_id    NUMBER,
           p_start_date_time    DATE,
           p_last_run_date_time    DATE,
           p_next_run_date_time    DATE,
           p_repeat_daily_start_time    DATE,
           p_repeat_daily_end_time    DATE,
           p_repeat_frequency_type    VARCHAR2,
           p_repeat_every_x_frequency    NUMBER,
           p_repeat_stop_date_time    DATE,
           p_metrics_refresh_type    VARCHAR2,
           p_description    VARCHAR2,
           p_timezone_id    NUMBER,
           p_user_start_date_time    DATE,
           p_user_last_run_date_time    DATE,
           p_user_next_run_date_time    DATE,
           p_user_repeat_daily_start_time    DATE,
           p_user_repeat_daily_end_time    DATE,
           p_user_repeat_stop_date_time    DATE,
           p_security_group_id    NUMBER)

  IS
    CURSOR C IS
         SELECT *
          FROM AMS_TRIGGERS
         WHERE TRIGGER_ID =  p_TRIGGER_ID
         FOR UPDATE of TRIGGER_ID NOWAIT;
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
            (      Recinfo.trigger_id = p_trigger_id)
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
        AND (    ( Recinfo.process_id = p_process_id)
             OR (    ( Recinfo.process_id IS NULL )
                 AND (  p_process_id IS NULL )))
        AND (    ( Recinfo.trigger_created_for_id = p_trigger_created_for_id)
             OR (    ( Recinfo.trigger_created_for_id IS NULL )
                 AND (  p_trigger_created_for_id IS NULL )))
        AND (    ( Recinfo.arc_trigger_created_for = p_arc_trigger_created_for)
             OR (    ( Recinfo.arc_trigger_created_for IS NULL )
                 AND (  p_arc_trigger_created_for IS NULL )))
        AND (    ( Recinfo.triggering_type = p_triggering_type)
             OR (    ( Recinfo.triggering_type IS NULL )
                 AND (  p_triggering_type IS NULL )))
        AND (    ( Recinfo.trigger_name = p_trigger_name)
             OR (    ( Recinfo.trigger_name IS NULL )
                 AND (  p_trigger_name IS NULL )))
        AND (    ( Recinfo.view_application_id = p_view_application_id)
             OR (    ( Recinfo.view_application_id IS NULL )
                 AND (  p_view_application_id IS NULL )))
        AND (    ( Recinfo.start_date_time = p_start_date_time)
             OR (    ( Recinfo.start_date_time IS NULL )
                 AND (  p_start_date_time IS NULL )))
        AND (    ( Recinfo.last_run_date_time = p_last_run_date_time)
             OR (    ( Recinfo.last_run_date_time IS NULL )
                 AND (  p_last_run_date_time IS NULL )))
        AND (    ( Recinfo.next_run_date_time = p_next_run_date_time)
             OR (    ( Recinfo.next_run_date_time IS NULL )
                 AND (  p_next_run_date_time IS NULL )))
        AND (    ( Recinfo.repeat_daily_start_time = p_repeat_daily_start_time)
             OR (    ( Recinfo.repeat_daily_start_time IS NULL )
                 AND (  p_repeat_daily_start_time IS NULL )))
        AND (    ( Recinfo.repeat_daily_end_time = p_repeat_daily_end_time)
             OR (    ( Recinfo.repeat_daily_end_time IS NULL )
                 AND (  p_repeat_daily_end_time IS NULL )))
        AND (    ( Recinfo.repeat_frequency_type = p_repeat_frequency_type)
             OR (    ( Recinfo.repeat_frequency_type IS NULL )
                 AND (  p_repeat_frequency_type IS NULL )))
        AND (    ( Recinfo.repeat_every_x_frequency = p_repeat_every_x_frequency)
             OR (    ( Recinfo.repeat_every_x_frequency IS NULL )
                 AND (  p_repeat_every_x_frequency IS NULL )))
        AND (    ( Recinfo.repeat_stop_date_time = p_repeat_stop_date_time)
             OR (    ( Recinfo.repeat_stop_date_time IS NULL )
                 AND (  p_repeat_stop_date_time IS NULL )))
        AND (    ( Recinfo.metrics_refresh_type = p_metrics_refresh_type)
             OR (    ( Recinfo.metrics_refresh_type IS NULL )
                 AND (  p_metrics_refresh_type IS NULL )))
        AND (    ( Recinfo.description = p_description)
             OR (    ( Recinfo.description IS NULL )
                 AND (  p_description IS NULL )))
        AND (    ( Recinfo.timezone_id = p_timezone_id)
             OR (    ( Recinfo.timezone_id IS NULL )
                 AND (  p_timezone_id IS NULL )))
        AND (    ( Recinfo.user_start_date_time = p_user_start_date_time)
             OR (    ( Recinfo.user_start_date_time IS NULL )
                 AND (  p_user_start_date_time IS NULL )))
        AND (    ( Recinfo.user_last_run_date_time = p_user_last_run_date_time)
             OR (    ( Recinfo.user_last_run_date_time IS NULL )
                 AND (  p_user_last_run_date_time IS NULL )))
        AND (    ( Recinfo.user_next_run_date_time = p_user_next_run_date_time)
             OR (    ( Recinfo.user_next_run_date_time IS NULL )
                 AND (  p_user_next_run_date_time IS NULL )))
        AND (    ( Recinfo.user_repeat_daily_start_time = p_user_repeat_daily_start_time)
             OR (    ( Recinfo.user_repeat_daily_start_time IS NULL )
                 AND (  p_user_repeat_daily_start_time IS NULL )))
        AND (    ( Recinfo.user_repeat_daily_end_time = p_user_repeat_daily_end_time)
             OR (    ( Recinfo.user_repeat_daily_end_time IS NULL )
                 AND (  p_user_repeat_daily_end_time IS NULL )))
        AND (    ( Recinfo.user_repeat_stop_date_time = p_user_repeat_stop_date_time)
             OR (    ( Recinfo.user_repeat_stop_date_time IS NULL )
                 AND (  p_user_repeat_stop_date_time IS NULL )))
        AND (    ( Recinfo.security_group_id = p_security_group_id)
             OR (    ( Recinfo.security_group_id IS NULL )
                 AND (  p_security_group_id IS NULL )))
        ) THEN
        RETURN;
    ELSE
        FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
        APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
 END Lock_Row;



-- ===============================================================
-- Start of Comments
-- Procedure name
--      ADD_LANGUAGE
-- Purpose
--
-- History
--      16-apr-2002    soagrawa     Created. Refer to bug# 2323843.
-- NOTE
--
-- End of Comments
-- ===============================================================



procedure ADD_LANGUAGE
is
begin
  delete from ams_triggers_tl T
  where not exists
    (select NULL
    from ams_triggers B
    where B.trigger_id = T.trigger_id
    );

  update ams_triggers_tl T set (
      trigger_name
      , DESCRIPTION
    ) = (select
      B.trigger_name
      , B.DESCRIPTION
    from ams_triggers_tl B
    where B.trigger_id = T.trigger_id
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.trigger_id,
      T.LANGUAGE
  ) in (select
      SUBT.trigger_id,
      SUBT.LANGUAGE
    from ams_triggers_tl SUBB, ams_triggers_tl SUBT
    where SUBB.trigger_id = SUBT.trigger_id
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.trigger_name <> SUBT.trigger_name
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into ams_triggers_tl (
    trigger_id,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    last_upated_by,
    LAST_UPDATE_LOGIN,
    trigger_name,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.trigger_id,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.last_upated_by,
    B.LAST_UPDATE_LOGIN,
    B.trigger_name,
    B.DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from ams_triggers_tl B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from ams_triggers_tl T
    where T.trigger_id = B.trigger_id
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;


END AMS_TRIGGER_PKG;

/
