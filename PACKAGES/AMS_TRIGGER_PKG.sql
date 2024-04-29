--------------------------------------------------------
--  DDL for Package AMS_TRIGGER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_TRIGGER_PKG" AUTHID CURRENT_USER AS
/* $Header: amsttrgs.pls 115.2 2002/11/16 01:45:06 dbiswas ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--      AMS_TRIGGER_PKG
-- Purpose
--      Table api for Triggers.
-- History
--      16-apr-2002    soagrawa     Created
--      16-apr-2002    soagrawa     Added add_language for bug# 2323843
--      12-jun-2002    soagrawa     Added insert_row, update_row, delete_row, lock_row
-- NOTE
--
-- End of Comments
-- ===============================================================


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
           p_security_group_id    NUMBER);

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
           p_security_group_id    NUMBER);

 PROCEDURE Delete_Row(
     p_TRIGGER_ID  NUMBER);

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
           p_security_group_id    NUMBER);





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

PROCEDURE ADD_LANGUAGE;


END AMS_TRIGGER_PKG;

 

/
