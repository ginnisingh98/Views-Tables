--------------------------------------------------------
--  DDL for Package Body AMS_CAMPAIGN_SCHEDULES_B_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_CAMPAIGN_SCHEDULES_B_PKG" as
/* $Header: amstschb.pls 120.3 2006/05/31 11:56:41 srivikri ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--      AMS_CAMPAIGN_SCHEDULES_B_PKG
-- Purpose
--      Table api to create/insert/update campaign Schedules.
-- History
--      22-Jan-2000    ptendulk     Created.
--      24-sep-2001    soagrawa     Removed security group id from everywhere
--      26-sep-2001    soagrawa     Modified insert_row and update_row to save date properly
--      26-dec-2001    aranka       Modified update_row to comment creation_date and created_by Bug#2160058
--      31-jan-2002    soagrawa     Modified update_row for bug# 2160058, 2204087
--      12-jun-2002    soagrawa     Added add_language for bug# 2323843 for mainline
--      12-jun-2002    soagrawa     Fixed ATT bug# 2376329 created by updated by issue from insert_row
--      26-Jan-2003    ptendulk     Commented debug messages. Bug 2767243
--       27-jun-2003    anchaudh     Added four more columns(trig_repeat_flag,trgp_exclude_prev,orig_csch_id,cover_letter_version) to be inserted and updated into the table.
--       12-aug-2003    dbiswas      Added 3 new columns(usage,purpose,last_activation_date) to be inserted and updated into the table.
--       25-aug-2003    dbiswas      Added 1 new columns(sales_methodology_id) to be inserted and updated into the table.
--       27-jul-2005    dbiswas      Added 1 new columns(notify_on_activation_flag) to be inserted and updated into the table.
--       29-May-2006    srivikri     added column delivery_mode
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_CAMPAIGN_SCHEDULES_B_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amstschb.pls';

-- ===============================================================
-- Start of Comments
-- Procedure name
--      Insert_Row
-- Purpose
--      Table api to insert campaign Schedules.
-- History
--      22-Jan-2000    ptendulk     Created.
--      26-Sep-2001    ptendulk     Modified inserting date, so that time would be saved as well
--       27-jun-2003    anchaudh     Added four more columns(trig_repeat_flag,trgp_exclude_prev,orig_csch_id,cover_letter_version) to be inserted and updated into the table.
--       12-aug-2003    dbiswas      Added 3 new columns(usage,purpose,last_activation_date) to be inserted and updated into the table.
--       25-aug-2003    dbiswas      Added 1 new column(sales_methodology_id) to be inserted and updated into the table.
--       27-jul-2005    dbiswas      Added 1 new columns(notify_on_activation_flag) to be inserted and updated into the table.
--       29-May-2006    srivikri     added column delivery_mode
-- NOTE
--
-- End of Comments
-- ===============================================================
PROCEDURE Insert_Row(
          px_schedule_id   IN OUT NOCOPY NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_campaign_id    NUMBER,
          p_user_status_id    NUMBER,
          p_status_code    VARCHAR2,
          p_status_date    DATE,
          p_source_code    VARCHAR2,
          p_use_parent_code_flag    VARCHAR2,
          p_start_date_time    DATE,
          p_end_date_time    DATE,
          p_timezone_id    NUMBER,
          p_activity_type_code    VARCHAR2,
          p_activity_id    NUMBER,
          p_arc_marketing_medium_from    VARCHAR2,
          p_marketing_medium_id    NUMBER,
          p_custom_setup_id    NUMBER,
          p_triggerable_flag    VARCHAR2,
          p_trigger_id    NUMBER,
          p_notify_user_id    NUMBER,
          p_approver_user_id    NUMBER,
          p_owner_user_id    NUMBER,
          p_active_flag    VARCHAR2,
          p_cover_letter_id    NUMBER,
          p_reply_to_mail    VARCHAR2,
          p_mail_sender_name    VARCHAR2,
          p_mail_subject    VARCHAR2,
          p_from_fax_no    VARCHAR2,
          p_accounts_closed_flag    VARCHAR2,
          px_org_id   IN OUT NOCOPY NUMBER,
          p_objective_code    VARCHAR2,
          p_country_id    NUMBER,
          p_campaign_calendar    VARCHAR2,
          p_start_period_name    VARCHAR2,
          p_end_period_name    VARCHAR2,
          p_priority    VARCHAR2,
          p_workflow_item_key    VARCHAR2,
          p_transaction_currency_code VARCHAR2,
          p_functional_currency_code VARCHAR2,
          p_budget_amount_tc NUMBER,
          p_budget_amount_fc NUMBER,
          p_language_code VARCHAR2,
          p_task_id NUMBER,
          p_related_event_from VARCHAR2,
          p_related_event_id NUMBER,
          p_attribute_category    VARCHAR2,
          p_attribute1    VARCHAR2,
          p_attribute2    VARCHAR2,
          p_attribute3    VARCHAR2,
          p_attribute4    VARCHAR2,
          p_attribute5    VARCHAR2,
          p_attribute6    VARCHAR2,
          p_attribute7    VARCHAR2,
          p_attribute8    VARCHAR2,
          p_attribute9    VARCHAR2,
          p_attribute10    VARCHAR2,
          p_attribute11    VARCHAR2,
          p_attribute12    VARCHAR2,
          p_attribute13    VARCHAR2,
          p_attribute14    VARCHAR2,
          p_attribute15    VARCHAR2,
          p_activity_attribute_category    VARCHAR2,
          p_activity_attribute1    VARCHAR2,
          p_activity_attribute2    VARCHAR2,
          p_activity_attribute3    VARCHAR2,
          p_activity_attribute4    VARCHAR2,
          p_activity_attribute5    VARCHAR2,
          p_activity_attribute6    VARCHAR2,
          p_activity_attribute7    VARCHAR2,
          p_activity_attribute8    VARCHAR2,
          p_activity_attribute9    VARCHAR2,
          p_activity_attribute10    VARCHAR2,
          p_activity_attribute11    VARCHAR2,
          p_activity_attribute12    VARCHAR2,
          p_activity_attribute13    VARCHAR2,
          p_activity_attribute14    VARCHAR2,
          p_activity_attribute15    VARCHAR2,
          -- removed by soagrawa on 24-sep-2001
          -- p_security_group_id    NUMBER,
          p_query_id                NUMBER,
          p_include_content_flag    VARCHAR2,
          p_content_type            VARCHAR2,
          p_test_email_address      VARCHAR2,
          p_schedule_name           VARCHAR2,
          p_schedule_description    VARCHAR2,
          p_greeting_text           VARCHAR2,
           p_footer_text             VARCHAR2,
	  --added by anchaudh on 30-apr-2003
	  p_trig_repeat_flag       VARCHAR2,
	  p_tgrp_exclude_prev_flag   VARCHAR2,
          --added by anchaudh on 06-may-2003
	  p_orig_csch_id      NUMBER,
	  p_cover_letter_version   NUMBER,
          --added by dbiswas on 12-aug-2003
          p_usage                     VARCHAR2,
          p_purpose                   VARCHAR2,
          p_last_activation_date      DATE,
          p_sales_methodology_id      NUMBER,
          p_printer_address           VARCHAR2,
          --added by dbiswas on 27-jul-2005
          p_notify_on_activation_flag VARCHAR2,
	  --added by anchaudh on 01-feb-2006
          p_sender_display_name  VARCHAR2,
     --added by srivikri
          p_delivery_mode  VARCHAR2
)

 IS
   x_rowid    VARCHAR2(30);
   -- date variables added by ptendulk on 26-sep-2001
   l_start_date DATE ;
   l_end_date   DATE ;
BEGIN


   px_object_version_number := 1;

   -- added by ptendulk on 26-sep-2001
   -- for storing time correctly in the database
   -- DBMS_OUTPUT.PUT_LINE('Start date : '||TO_CHAR(p_start_date_time,'DDMMYY HH:MI:SS PM'));

   IF p_start_date_time = FND_API.g_miss_date THEN
      l_start_date := NULL ;
   ELSE
      l_start_date := p_start_date_time ;
   END IF ;

   IF p_end_date_time = FND_API.g_miss_date THEN
      l_end_date := null ;
   ELSE
      l_end_date := p_end_date_time ;
   END IF ;

   -- end ptendulk 26-sep-2001

   INSERT INTO AMS_CAMPAIGN_SCHEDULES_B(
           schedule_id,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           last_update_login,
           object_version_number,
           campaign_id,
           user_status_id,
           status_code,
           status_date,
           source_code,
           use_parent_code_flag,
           start_date_time,
           end_date_time,
           timezone_id,
           activity_type_code,
           activity_id,
           arc_marketing_medium_from,
           marketing_medium_id,
           custom_setup_id,
           triggerable_flag,
           trigger_id,
           notify_user_id,
           approver_user_id,
           owner_user_id,
           active_flag,
           cover_letter_id,
           reply_to_mail,
           mail_sender_name,
           mail_subject,
           from_fax_no,
           accounts_closed_flag,
           org_id,
           objective_code,
           country_id,
           campaign_calendar,
           start_period_name,
           end_period_name,
           priority,
           workflow_item_key,
           transaction_currency_code,
           functional_currency_code,
           budget_amount_tc,
           budget_amount_fc,
           language_code,
           task_id,
           related_event_from,
           related_event_id,
           attribute_category,
           attribute1,
           attribute2,
           attribute3,
           attribute4,
           attribute5,
           attribute6,
           attribute7,
           attribute8,
           attribute9,
           attribute10,
           attribute11,
           attribute12,
           attribute13,
           attribute14,
           attribute15,
           activity_attribute_category,
           activity_attribute1,
           activity_attribute2,
           activity_attribute3,
           activity_attribute4,
           activity_attribute5,
           activity_attribute6,
           activity_attribute7,
           activity_attribute8,
           activity_attribute9,
           activity_attribute10,
           activity_attribute11,
           activity_attribute12,
           activity_attribute13,
           activity_attribute14,
           activity_attribute15,
           -- removed by soagrawa on 24-sep-2001
           -- security_group_id,
           query_id,
           include_content_flag,
           content_type,
           test_email_address,
--added by anchaudh on 30-apr-2003
           trig_repeat_flag,
	   tgrp_exclude_prev_flag,
--added by anchaudh on 06-may-2003
           orig_csch_id,
	   cover_letter_version,
--added by dbiswas on 12-aug-2003
           usage,
           purpose,
           last_activation_date,
           sales_methodology_id,
           printer_address,
           notify_on_activation_flag,
	   sender_display_name,
      delivery_mode
   ) VALUES (
           DECODE( px_schedule_id, FND_API.g_miss_num, NULL, px_schedule_id),
           -- last updated by, created by, last update login modified by soagrawa  on 12-jun-2002 for ATT bug 2376329
           DECODE( p_last_update_date, FND_API.g_miss_date, SYSDATE, p_last_update_date),
           DECODE( p_last_updated_by, FND_API.g_miss_num, FND_GLOBAL.USER_ID, p_last_updated_by),
           DECODE( p_creation_date, FND_API.g_miss_date, SYSDATE, p_creation_date),
           DECODE( p_created_by, FND_API.g_miss_num, FND_GLOBAL.USER_ID, p_created_by),
           DECODE( p_last_update_login, FND_API.g_miss_num, FND_GLOBAL.LOGIN_ID, p_last_update_login),
           /*
           DECODE( p_last_update_date, FND_API.g_miss_date, NULL, p_last_update_date),
           DECODE( p_last_updated_by, FND_API.g_miss_num, NULL, p_last_updated_by),
           DECODE( p_creation_date, FND_API.g_miss_date, NULL, p_creation_date),
           DECODE( p_created_by, FND_API.g_miss_num, NULL, p_created_by),
           DECODE( p_last_update_login, FND_API.g_miss_num, NULL, p_last_update_login),
           */
           DECODE( px_object_version_number, FND_API.g_miss_num, NULL, px_object_version_number),
           DECODE( p_campaign_id, FND_API.g_miss_num, NULL, p_campaign_id),
           DECODE( p_user_status_id, FND_API.g_miss_num, NULL, p_user_status_id),
           DECODE( p_status_code, FND_API.g_miss_char, NULL, p_status_code),
           DECODE( p_status_date, FND_API.g_miss_date, SYSDATE, p_status_date),
           DECODE( p_source_code, FND_API.g_miss_char, NULL, p_source_code),
           DECODE( p_use_parent_code_flag, FND_API.g_miss_char, 'N', p_use_parent_code_flag),
           -- date stuff modified by ptendulk on 26-sep-2001
           -- as the time was not being saved from the api.
           --DECODE( p_start_date_time, FND_API.g_miss_date, NULL, TO_DATE(TO_CHAR(p_start_date_time,'DDMMRRRR HH:MI:SS PM'),'DDMMRRRR HH:MI:SS PM')),
           --TO_DATE(TO_CHAR(p_start_date_time,'DDMMRRRR HH:MI:SS PM'),'DDMMRRRR HH:MI:SS PM'),
           l_start_date,
           --DECODE( p_end_date_time, FND_API.g_miss_date, NULL, p_end_date_time),
           l_end_date,
           DECODE( p_timezone_id, FND_API.g_miss_num, NULL, p_timezone_id),
           DECODE( p_activity_type_code, FND_API.g_miss_char, NULL, p_activity_type_code),
           DECODE( p_activity_id, FND_API.g_miss_num, NULL, p_activity_id),
           DECODE( p_arc_marketing_medium_from, FND_API.g_miss_char, NULL, p_arc_marketing_medium_from),
           DECODE( p_marketing_medium_id, FND_API.g_miss_num, NULL, p_marketing_medium_id),
           DECODE( p_custom_setup_id, FND_API.g_miss_num, NULL, p_custom_setup_id),
           DECODE( p_triggerable_flag, FND_API.g_miss_char, 'N', p_triggerable_flag),
           DECODE( p_trigger_id, FND_API.g_miss_num, NULL, p_trigger_id),
           DECODE( p_notify_user_id, FND_API.g_miss_num, NULL, p_notify_user_id),
           DECODE( p_approver_user_id, FND_API.g_miss_num, NULL, p_approver_user_id),
           DECODE( p_owner_user_id, FND_API.g_miss_num, NULL, p_owner_user_id),
           DECODE( p_active_flag, FND_API.g_miss_char, 'Y', p_active_flag),
           DECODE( p_cover_letter_id, FND_API.g_miss_num, NULL, p_cover_letter_id),
           DECODE( p_reply_to_mail, FND_API.g_miss_char, NULL, p_reply_to_mail),
           DECODE( p_mail_sender_name, FND_API.g_miss_char, NULL, p_mail_sender_name),
           DECODE( p_mail_subject, FND_API.g_miss_char, NULL, p_mail_subject),
           DECODE( p_from_fax_no, FND_API.g_miss_char, NULL, p_from_fax_no),
           DECODE( p_accounts_closed_flag, FND_API.g_miss_char, 'N', p_accounts_closed_flag),
           DECODE( px_org_id, FND_API.g_miss_num, NULL, px_org_id),
           DECODE( p_objective_code, FND_API.g_miss_char, NULL, p_objective_code),
           DECODE( p_country_id, FND_API.g_miss_num, NULL, p_country_id),
           DECODE( p_campaign_calendar, FND_API.g_miss_char, NULL, p_campaign_calendar),
           DECODE( p_start_period_name, FND_API.g_miss_char, NULL, p_start_period_name),
           DECODE( p_end_period_name, FND_API.g_miss_char, NULL, p_end_period_name),
           DECODE( p_priority, FND_API.g_miss_char, NULL, p_priority),
           DECODE( p_workflow_item_key, FND_API.g_miss_char, NULL, p_workflow_item_key),
           DECODE( p_transaction_currency_code, FND_API.g_miss_char, NULL, p_transaction_currency_code),
           DECODE( p_functional_currency_code, FND_API.g_miss_char, NULL, p_functional_currency_code),
           DECODE( p_budget_amount_tc ,FND_API.g_miss_num,NULL,p_budget_amount_tc),
           DECODE( p_budget_amount_fc ,FND_API.g_miss_num,NULL,p_budget_amount_fc),
           DECODE( p_language_code ,FND_API.g_miss_char,NULL,p_language_code),
           DECODE( p_task_id ,FND_API.g_miss_num,NULL,p_task_id),
           DECODE( p_related_event_from ,FND_API.g_miss_char,NULL,p_related_event_from),
           DECODE( p_related_event_id ,FND_API.g_miss_num,NULL,p_related_event_id),
           DECODE( p_attribute_category, FND_API.g_miss_char, NULL, p_attribute_category),
           DECODE( p_attribute1, FND_API.g_miss_char, NULL, p_attribute1),
           DECODE( p_attribute2, FND_API.g_miss_char, NULL, p_attribute2),
           DECODE( p_attribute3, FND_API.g_miss_char, NULL, p_attribute3),
           DECODE( p_attribute4, FND_API.g_miss_char, NULL, p_attribute4),
           DECODE( p_attribute5, FND_API.g_miss_char, NULL, p_attribute5),
           DECODE( p_attribute6, FND_API.g_miss_char, NULL, p_attribute6),
           DECODE( p_attribute7, FND_API.g_miss_char, NULL, p_attribute7),
           DECODE( p_attribute8, FND_API.g_miss_char, NULL, p_attribute8),
           DECODE( p_attribute9, FND_API.g_miss_char, NULL, p_attribute9),
           DECODE( p_attribute10, FND_API.g_miss_char, NULL, p_attribute10),
           DECODE( p_attribute11, FND_API.g_miss_char, NULL, p_attribute11),
           DECODE( p_attribute12, FND_API.g_miss_char, NULL, p_attribute12),
           DECODE( p_attribute13, FND_API.g_miss_char, NULL, p_attribute13),
           DECODE( p_attribute14, FND_API.g_miss_char, NULL, p_attribute14),
           DECODE( p_attribute15, FND_API.g_miss_char, NULL, p_attribute15),
           DECODE( p_activity_attribute_category, FND_API.g_miss_char, NULL, p_activity_attribute_category),
           DECODE( p_activity_attribute1, FND_API.g_miss_char, NULL, p_activity_attribute1),
           DECODE( p_activity_attribute2, FND_API.g_miss_char, NULL, p_activity_attribute2),
           DECODE( p_activity_attribute3, FND_API.g_miss_char, NULL, p_activity_attribute3),
           DECODE( p_activity_attribute4, FND_API.g_miss_char, NULL, p_activity_attribute4),
           DECODE( p_activity_attribute5, FND_API.g_miss_char, NULL, p_activity_attribute5),
           DECODE( p_activity_attribute6, FND_API.g_miss_char, NULL, p_activity_attribute6),
           DECODE( p_activity_attribute7, FND_API.g_miss_char, NULL, p_activity_attribute7),
           DECODE( p_activity_attribute8, FND_API.g_miss_char, NULL, p_activity_attribute8),
           DECODE( p_activity_attribute9, FND_API.g_miss_char, NULL, p_activity_attribute9),
           DECODE( p_activity_attribute10, FND_API.g_miss_char, NULL, p_activity_attribute10),
           DECODE( p_activity_attribute11, FND_API.g_miss_char, NULL, p_activity_attribute11),
           DECODE( p_activity_attribute12, FND_API.g_miss_char, NULL, p_activity_attribute12),
           DECODE( p_activity_attribute13, FND_API.g_miss_char, NULL, p_activity_attribute13),
           DECODE( p_activity_attribute14, FND_API.g_miss_char, NULL, p_activity_attribute14),
           DECODE( p_activity_attribute15, FND_API.g_miss_char, NULL, p_activity_attribute15),
           -- removed by soagrawa on 24-sep-2001
           -- DECODE( p_security_group_id, FND_API.g_miss_num, NULL, p_security_group_id),
           DECODE( p_query_id, FND_API.g_miss_num, NULL, p_query_id),
           DECODE( p_include_content_flag, FND_API.g_miss_char,NULL,p_include_content_flag),
           DECODE( p_content_type, FND_API.g_miss_char,NULL,p_content_type),
            DECODE( p_test_email_address, FND_API.g_miss_char,NULL,p_test_email_address),
--added by anchaudh on 30-apr-2003
           DECODE( p_trig_repeat_flag, FND_API.g_miss_char, 'N',p_trig_repeat_flag),
           DECODE( p_tgrp_exclude_prev_flag, FND_API.g_miss_char, 'N', p_tgrp_exclude_prev_flag),
--added by anchaudh on 06-may-2003
           DECODE( p_orig_csch_id, FND_API.g_miss_num, NULL, p_orig_csch_id),
           DECODE( p_cover_letter_version, FND_API.g_miss_num, NULL, p_cover_letter_version),
            DECODE( p_usage, FND_API.g_miss_char,NULL,p_usage),
            DECODE( p_purpose, FND_API.g_miss_char,NULL,p_purpose),
            DECODE( p_last_activation_date, FND_API.g_miss_date,NULL,p_last_activation_date),
            DECODE( p_sales_methodology_id, FND_API.g_miss_num,NULL,p_sales_methodology_id),
            DECODE( p_printer_address, FND_API.g_miss_char,NULL,p_printer_address),
            DECODE( p_notify_on_activation_flag, FND_API.g_miss_char,NULL,p_notify_on_activation_flag),
	    DECODE( p_sender_display_name, FND_API.g_miss_char,NULL,p_sender_display_name)--anchaudh
       ,DECODE( p_delivery_mode, FND_API.g_miss_char, NULL, p_delivery_mode)
           );

   INSERT INTO AMS_CAMPAIGN_SCHEDULES_TL(
           schedule_id,
           language,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           last_update_login,
           source_lang,
           schedule_name,
           description,
           -- removed by soagrawa on 24-sep-2001
           -- security_group_id,
           greeting_text,
           footer_text
           )
   SELECT
           DECODE( px_schedule_id, FND_API.g_miss_num, NULL, px_schedule_id),
           l.language_code,
           SYSDATE,
           FND_GLOBAL.user_id,
           SYSDATE,
           FND_GLOBAL.user_id,
           FND_GLOBAL.conc_login_id,
           USERENV('LANG'),
           DECODE( p_schedule_name, FND_API.g_miss_char, NULL, p_schedule_name),
           DECODE( p_schedule_description, FND_API.g_miss_char, NULL, p_schedule_description),
           -- removed by soagrawa on 24-sep-2001
           -- DECODE( p_security_group_id, FND_API.g_miss_num, NULL, p_security_group_id),
           DECODE( p_greeting_text, FND_API.g_miss_char, NULL, p_greeting_text),
           DECODE( p_footer_text, FND_API.g_miss_char, NULL, p_footer_text)
   FROM    fnd_languages l
   WHERE   l.installed_flag IN ('I','B')
   AND     NOT EXISTS(
                      SELECT NULL
                      FROM   ams_campaign_schedules_tl t
                      WHERE  t.schedule_id = DECODE( px_schedule_id, FND_API.g_miss_num, NULL, px_schedule_id)
                      AND    t.language = l.language_code ) ;



END Insert_Row;


-- ===============================================================
-- Start of Comments
-- Procedure name
--      Update_Row
-- Purpose
--      Table api to update campaign Schedules.
-- History
--      22-Jan-2000    ptendulk     Created.
--      26-sep-2001    soagrawa     Modified updating start date and end date
--      26-dec-2001    aranka       Modified creation_Date and created_by
--      31-jan-2002    soagrawa     Modified last updated by for bug# 2160058, #2204087
--       27-jun-2003    anchaudh     Added four more columns(trig_repeat_flag,trgp_exclude_prev,orig_csch_id,cover_letter_version) to be inserted and updated into the table.
--       12-aug-2003    dbiswas      Added 3 new columns(usage,purpose,last_activation_date) to be inserted and updated into the table.
--       25-aug-2003    dbiswas      Added 1 new column(sales_methodology_id) to be inserted and updated into the table.
--       27-jul-2005    dbiswas      Added 1 new column(notify_on_activation_flag) to be inserted and updated into the table.
--       29-May-2006    srivikri     Added column Delivery_mode
-- NOTE
--
-- End of Comments
-- ===============================================================
PROCEDURE Update_Row(
          p_schedule_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_campaign_id    NUMBER,
          p_user_status_id    NUMBER,
          p_status_code    VARCHAR2,
          p_status_date    DATE,
          p_source_code    VARCHAR2,
          p_use_parent_code_flag    VARCHAR2,
          p_start_date_time    DATE,
          p_end_date_time    DATE,
          p_timezone_id    NUMBER,
          p_activity_type_code    VARCHAR2,
          p_activity_id    NUMBER,
          p_arc_marketing_medium_from    VARCHAR2,
          p_marketing_medium_id    NUMBER,
          p_custom_setup_id    NUMBER,
          p_triggerable_flag    VARCHAR2,
          p_trigger_id    NUMBER,
          p_notify_user_id    NUMBER,
          p_approver_user_id    NUMBER,
          p_owner_user_id    NUMBER,
          p_active_flag    VARCHAR2,
          p_cover_letter_id    NUMBER,
          p_reply_to_mail    VARCHAR2,
          p_mail_sender_name    VARCHAR2,
          p_mail_subject    VARCHAR2,
          p_from_fax_no    VARCHAR2,
          p_accounts_closed_flag    VARCHAR2,
          p_org_id    NUMBER,
          p_objective_code    VARCHAR2,
          p_country_id    NUMBER,
          p_campaign_calendar    VARCHAR2,
          p_start_period_name    VARCHAR2,
          p_end_period_name    VARCHAR2,
          p_priority    VARCHAR2,
          p_workflow_item_key    VARCHAR2,
          p_transaction_currency_code VARCHAR2,
          p_functional_currency_code VARCHAR2,
          p_budget_amount_tc NUMBER,
          p_budget_amount_fc NUMBER,
          p_language_code VARCHAR2,
          p_task_id NUMBER,
          p_related_event_from VARCHAR2,
          p_related_event_id NUMBER,
          p_attribute_category    VARCHAR2,
          p_attribute1    VARCHAR2,
          p_attribute2    VARCHAR2,
          p_attribute3    VARCHAR2,
          p_attribute4    VARCHAR2,
          p_attribute5    VARCHAR2,
          p_attribute6    VARCHAR2,
          p_attribute7    VARCHAR2,
          p_attribute8    VARCHAR2,
          p_attribute9    VARCHAR2,
          p_attribute10    VARCHAR2,
          p_attribute11    VARCHAR2,
          p_attribute12    VARCHAR2,
          p_attribute13    VARCHAR2,
          p_attribute14    VARCHAR2,
          p_attribute15    VARCHAR2,
          p_activity_attribute_category    VARCHAR2,
          p_activity_attribute1    VARCHAR2,
          p_activity_attribute2    VARCHAR2,
          p_activity_attribute3    VARCHAR2,
          p_activity_attribute4    VARCHAR2,
          p_activity_attribute5    VARCHAR2,
          p_activity_attribute6    VARCHAR2,
          p_activity_attribute7    VARCHAR2,
          p_activity_attribute8    VARCHAR2,
          p_activity_attribute9    VARCHAR2,
          p_activity_attribute10    VARCHAR2,
          p_activity_attribute11    VARCHAR2,
          p_activity_attribute12    VARCHAR2,
          p_activity_attribute13    VARCHAR2,
          p_activity_attribute14    VARCHAR2,
          p_activity_attribute15    VARCHAR2,
          -- removed by soagrawa on 24-sep-2001
          -- p_security_group_id    NUMBER  ,
          p_query_id                NUMBER,
          p_include_content_flag    VARCHAR2,
          p_content_type            VARCHAR2,
          p_test_email_address      VARCHAR2,
          p_schedule_name           VARCHAR2,
          p_schedule_description    VARCHAR2,
          p_greeting_text           VARCHAR2,
          p_footer_text             VARCHAR2,
--added by anchaudh on 30-apr-2003
	  p_trig_repeat_flag       VARCHAR2,
	  p_tgrp_exclude_prev_flag   VARCHAR2,
--added by anchaudh on 06-may-2003
	  p_orig_csch_id      NUMBER,
	  p_cover_letter_version   NUMBER,
--added by dbiswas on 12-aug-2003
	  p_usage       VARCHAR2,
	  p_purpose   VARCHAR2,
	  p_last_activation_date   DATE,
          p_sales_methodology_id   NUMBER,
          p_printer_address           VARCHAR2,
--added by dbiswas on 27-jul-2005
	  p_notify_on_activation_flag  VARCHAR2,
	  --added by anchaudh on 01-feb-2006
          p_sender_display_name  VARCHAR2,
          p_delivery_mode VARCHAR2
)
 IS
      -- date variables added by soagrawa on 26-sep-2001
      l_start_date DATE ;
      l_end_date   DATE ;

 BEGIN

   -- added by soagrawa on 26-sep-2001
   -- for storing time correctly in the database
   -- DBMS_OUTPUT.PUT_LINE('Start date : '||TO_CHAR(p_start_date_time,'DDMMYY HH:MI:SS PM'));

   IF p_start_date_time = FND_API.g_miss_date THEN
      l_start_date := NULL ;
   ELSE
      l_start_date := p_start_date_time ;
   END IF ;

   IF p_end_date_time = FND_API.g_miss_date THEN
      l_end_date := null ;
   ELSE
      l_end_date := p_end_date_time ;
   END IF ;

   -- end soagrawa 26-sep-2001
    -- Debug Message Commented by ptendulk Bug 2767243
    -- ams_utility_pvt.debug_message('Transaction currency  :: '||p_transaction_currency_code);
    UPDATE ams_campaign_schedules_b
    SET       schedule_id = DECODE( p_schedule_id, FND_API.g_miss_num, schedule_id, p_schedule_id),
              last_update_date = DECODE( p_last_update_date, FND_API.g_miss_date, last_update_date, p_last_update_date),
              -- last update date modified by soagrawa on 31-jan-2002 for bug# 2160058, 2204087
              last_updated_by = FND_GLOBAL.USER_ID,
              -- last_updated_by = DECODE( p_last_updated_by, FND_API.g_miss_num, last_updated_by, p_last_updated_by),
              -- removed by aranka on 26-dec-2001
              -- creation_date = DECODE( p_creation_date, FND_API.g_miss_date, creation_date, p_creation_date),
              -- created_by = DECODE( p_created_by, FND_API.g_miss_num, created_by, p_created_by),
              -- removed by aranka on 26-dec-2001
              last_update_login = DECODE( p_last_update_login, FND_API.g_miss_num, last_update_login, p_last_update_login),
              object_version_number = DECODE( p_object_version_number, FND_API.g_miss_num, object_version_number, p_object_version_number+ 1),
              campaign_id = DECODE( p_campaign_id, FND_API.g_miss_num, campaign_id, p_campaign_id),
              user_status_id = DECODE( p_user_status_id, FND_API.g_miss_num, user_status_id, p_user_status_id),
              status_code = DECODE( p_status_code, FND_API.g_miss_char, status_code, p_status_code),
              status_date = DECODE( p_status_date, FND_API.g_miss_date, status_date, p_status_date),
              source_code = DECODE( p_source_code, FND_API.g_miss_char, source_code, p_source_code),
              use_parent_code_flag = DECODE( p_use_parent_code_flag, FND_API.g_miss_char, use_parent_code_flag, p_use_parent_code_flag),
              -- date stuff modified by soagrawa on 26-sep-2001 to save time as well, decode messes time up
              -- start_date_time = DECODE( p_start_date_time, FND_API.g_miss_date, start_date_time, p_start_date_time),
              -- end_date_time = DECODE( p_end_date_time, FND_API.g_miss_date, end_date_time, p_end_date_time),
              start_date_time = l_start_date,
              end_date_time = l_end_date,
              timezone_id = DECODE( p_timezone_id, FND_API.g_miss_num, timezone_id, p_timezone_id),
              activity_type_code = DECODE( p_activity_type_code, FND_API.g_miss_char, activity_type_code, p_activity_type_code),
              activity_id = DECODE( p_activity_id, FND_API.g_miss_num, activity_id, p_activity_id),
              arc_marketing_medium_from = DECODE( p_arc_marketing_medium_from, FND_API.g_miss_char, arc_marketing_medium_from, p_arc_marketing_medium_from),
              marketing_medium_id = DECODE( p_marketing_medium_id, FND_API.g_miss_num, marketing_medium_id, p_marketing_medium_id),
              custom_setup_id = DECODE( p_custom_setup_id, FND_API.g_miss_num, custom_setup_id, p_custom_setup_id),
              triggerable_flag = DECODE( p_triggerable_flag, FND_API.g_miss_char, triggerable_flag, p_triggerable_flag),
              trigger_id = DECODE( p_trigger_id, FND_API.g_miss_num, trigger_id, p_trigger_id),
              notify_user_id = DECODE( p_notify_user_id, FND_API.g_miss_num, notify_user_id, p_notify_user_id),
              approver_user_id = DECODE( p_approver_user_id, FND_API.g_miss_num, approver_user_id, p_approver_user_id),
              owner_user_id = DECODE( p_owner_user_id, FND_API.g_miss_num, owner_user_id, p_owner_user_id),
              active_flag = DECODE( p_active_flag, FND_API.g_miss_char, active_flag, p_active_flag),
              cover_letter_id = DECODE( p_cover_letter_id, FND_API.g_miss_num, cover_letter_id, p_cover_letter_id),
              reply_to_mail = DECODE( p_reply_to_mail, FND_API.g_miss_char, reply_to_mail, p_reply_to_mail),
              mail_sender_name = DECODE( p_mail_sender_name, FND_API.g_miss_char, mail_sender_name, p_mail_sender_name),
              mail_subject = DECODE( p_mail_subject, FND_API.g_miss_char, mail_subject, p_mail_subject),
              from_fax_no = DECODE( p_from_fax_no, FND_API.g_miss_char, from_fax_no, p_from_fax_no),
              accounts_closed_flag = DECODE( p_accounts_closed_flag, FND_API.g_miss_char, accounts_closed_flag, p_accounts_closed_flag),
              org_id = DECODE( p_org_id, FND_API.g_miss_num, org_id, p_org_id),
              objective_code = DECODE( p_objective_code, FND_API.g_miss_char, objective_code, p_objective_code),
              country_id = DECODE( p_country_id, FND_API.g_miss_num, country_id, p_country_id),
              campaign_calendar = DECODE( p_campaign_calendar, FND_API.g_miss_char, campaign_calendar, p_campaign_calendar),
              start_period_name = DECODE( p_start_period_name, FND_API.g_miss_char, start_period_name, p_start_period_name),
              end_period_name = DECODE( p_end_period_name, FND_API.g_miss_char, end_period_name, p_end_period_name),
              priority = DECODE( p_priority, FND_API.g_miss_char, priority, p_priority),
              workflow_item_key = DECODE( p_workflow_item_key, FND_API.g_miss_char, workflow_item_key, p_workflow_item_key),
              transaction_currency_code = DECODE(p_transaction_currency_code,FND_API.g_miss_char,transaction_currency_code,p_transaction_currency_code),
              functional_currency_code = DECODE(p_functional_currency_code,FND_API.g_miss_char,functional_currency_code,p_functional_currency_code),
              budget_amount_tc = DECODE( p_budget_amount_tc ,FND_API.g_miss_num,budget_amount_tc,p_budget_amount_tc),
              budget_amount_fc = DECODE( p_budget_amount_fc ,FND_API.g_miss_num,budget_amount_fc,p_budget_amount_fc),
              language_code = DECODE( p_language_code ,FND_API.g_miss_char,language_code,p_language_code),
              task_id = DECODE( p_task_id ,FND_API.g_miss_num,task_id,p_task_id),
              related_event_from = DECODE( p_related_event_from ,FND_API.g_miss_char,related_event_from,p_related_event_from),
              related_event_id = DECODE( p_related_event_id ,FND_API.g_miss_num,related_event_id,p_related_event_id),
              attribute_category = DECODE( p_attribute_category, FND_API.g_miss_char, attribute_category, p_attribute_category),
              attribute1 = DECODE( p_attribute1, FND_API.g_miss_char, attribute1, p_attribute1),
              attribute2 = DECODE( p_attribute2, FND_API.g_miss_char, attribute2, p_attribute2),
              attribute3 = DECODE( p_attribute3, FND_API.g_miss_char, attribute3, p_attribute3),
              attribute4 = DECODE( p_attribute4, FND_API.g_miss_char, attribute4, p_attribute4),
              attribute5 = DECODE( p_attribute5, FND_API.g_miss_char, attribute5, p_attribute5),
              attribute6 = DECODE( p_attribute6, FND_API.g_miss_char, attribute6, p_attribute6),
              attribute7 = DECODE( p_attribute7, FND_API.g_miss_char, attribute7, p_attribute7),
              attribute8 = DECODE( p_attribute8, FND_API.g_miss_char, attribute8, p_attribute8),
              attribute9 = DECODE( p_attribute9, FND_API.g_miss_char, attribute9, p_attribute9),
              attribute10 = DECODE( p_attribute10, FND_API.g_miss_char, attribute10, p_attribute10),
              attribute11 = DECODE( p_attribute11, FND_API.g_miss_char, attribute11, p_attribute11),
              attribute12 = DECODE( p_attribute12, FND_API.g_miss_char, attribute12, p_attribute12),
              attribute13 = DECODE( p_attribute13, FND_API.g_miss_char, attribute13, p_attribute13),
              attribute14 = DECODE( p_attribute14, FND_API.g_miss_char, attribute14, p_attribute14),
              attribute15 = DECODE( p_attribute15, FND_API.g_miss_char, attribute15, p_attribute15),
              activity_attribute_category = DECODE( p_activity_attribute_category, FND_API.g_miss_char, activity_attribute_category, p_activity_attribute_category),
              activity_attribute1 = DECODE( p_activity_attribute1, FND_API.g_miss_char, activity_attribute1, p_activity_attribute1),
              activity_attribute2 = DECODE( p_activity_attribute2, FND_API.g_miss_char, activity_attribute2, p_activity_attribute2),
              activity_attribute3 = DECODE( p_activity_attribute3, FND_API.g_miss_char, activity_attribute3, p_activity_attribute3),
              activity_attribute4 = DECODE( p_activity_attribute4, FND_API.g_miss_char, activity_attribute4, p_activity_attribute4),
              activity_attribute5 = DECODE( p_activity_attribute5, FND_API.g_miss_char, activity_attribute5, p_activity_attribute5),
              activity_attribute6 = DECODE( p_activity_attribute6, FND_API.g_miss_char, activity_attribute6, p_activity_attribute6),
              activity_attribute7 = DECODE( p_activity_attribute7, FND_API.g_miss_char, activity_attribute7, p_activity_attribute7),
              activity_attribute8 = DECODE( p_activity_attribute8, FND_API.g_miss_char, activity_attribute8, p_activity_attribute8),
              activity_attribute9 = DECODE( p_activity_attribute9, FND_API.g_miss_char, activity_attribute9, p_activity_attribute9),
              activity_attribute10 = DECODE( p_activity_attribute10, FND_API.g_miss_char, activity_attribute10, p_activity_attribute10),
              activity_attribute11 = DECODE( p_activity_attribute11, FND_API.g_miss_char, activity_attribute11, p_activity_attribute11),
              activity_attribute12 = DECODE( p_activity_attribute12, FND_API.g_miss_char, activity_attribute12, p_activity_attribute12),
              activity_attribute13 = DECODE( p_activity_attribute13, FND_API.g_miss_char, activity_attribute13, p_activity_attribute13),
              activity_attribute14 = DECODE( p_activity_attribute14, FND_API.g_miss_char, activity_attribute14, p_activity_attribute14),
              activity_attribute15 = DECODE( p_activity_attribute15, FND_API.g_miss_char, activity_attribute15, p_activity_attribute15),
              -- removed by soagrawa on 24-sep-2001
              -- security_group_id = DECODE( p_security_group_id, FND_API.g_miss_num, security_group_id, p_security_group_id),
              query_id = DECODE( p_query_id, FND_API.g_miss_num, query_id, p_query_id),
              include_content_flag = DECODE( p_include_content_flag, FND_API.g_miss_char, include_content_flag, p_include_content_flag),
              content_type = DECODE( p_content_type, FND_API.g_miss_char, content_type, p_content_type),
              test_email_address = DECODE( p_test_email_address, FND_API.g_miss_char, test_email_address, p_test_email_address),
--added by anchaudh on 30-apr-2003
              trig_repeat_flag =  DECODE( p_trig_repeat_flag, FND_API.g_miss_char,trig_repeat_flag ,p_trig_repeat_flag),
              tgrp_exclude_prev_flag =  DECODE( p_tgrp_exclude_prev_flag, FND_API.g_miss_char, tgrp_exclude_prev_flag, p_tgrp_exclude_prev_flag),
--added by anchaudh on 06-may-2003
              orig_csch_id = DECODE( p_orig_csch_id, FND_API.g_miss_num, orig_csch_id, p_orig_csch_id),
              cover_letter_version = DECODE( p_cover_letter_version, FND_API.g_miss_num, cover_letter_version, p_cover_letter_version),
--added by dbiswas on 12-aug-2003
              usage =  DECODE( p_usage, FND_API.g_miss_char,usage ,p_usage),
              purpose =  DECODE( p_purpose, FND_API.g_miss_char, purpose, p_purpose),
              last_activation_date =  DECODE( p_last_activation_date, FND_API.g_miss_date, last_activation_date, p_last_activation_date),
              sales_methodology_id =  DECODE( p_sales_methodology_id, FND_API.g_miss_num, sales_methodology_id, p_sales_methodology_id),
              printer_address =  DECODE( p_printer_address, FND_API.g_miss_char, printer_address, p_printer_address),
              notify_on_activation_flag =  DECODE( p_notify_on_activation_flag, FND_API.g_miss_char, notify_on_activation_flag, p_notify_on_activation_flag),
	      sender_display_name =  DECODE( p_sender_display_name, FND_API.g_miss_char, sender_display_name, p_sender_display_name),
         delivery_mode = DECODE( p_delivery_mode, FND_API.g_miss_char, delivery_mode, p_delivery_mode)
   WHERE schedule_id = p_schedule_id
   AND   object_version_number = p_object_version_number;
    -- Debug Message Commented by ptendulk Bug 2767243
    -- AMS_UTILITY_PVT.debug_message('Start Update Table Handler');
   IF (SQL%NOTFOUND) THEN
         RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   UPDATE ams_campaign_schedules_tl
   SET    schedule_name = DECODE(p_schedule_name,FND_API.g_miss_char,schedule_name,p_schedule_name),
          description   = DECODE(p_schedule_description,FND_API.g_miss_char,description,p_schedule_description),
          greeting_text = DECODE(p_greeting_text,FND_API.g_miss_char,greeting_text,p_greeting_text),
          footer_text = DECODE(p_footer_text,FND_API.g_miss_char,footer_text,p_footer_text),
          last_update_date = DECODE( p_last_update_date, FND_API.g_miss_date, last_update_date, p_last_update_date),
          last_updated_by = DECODE( p_last_updated_by, FND_API.g_miss_num, last_updated_by, p_last_updated_by),
          last_update_login = DECODE( p_last_update_login, FND_API.g_miss_num, last_update_login, p_last_update_login),
          source_lang = USERENV('LANG')
   WHERE  schedule_id = p_schedule_id
   AND    USERENV('LANG') IN (language, source_lang);

   IF (SQL%NOTFOUND) THEN
      RAISE FND_API.g_exc_error;
   END IF;

END Update_Row;

-- ===============================================================
-- Start of Comments
-- Procedure name
--      Delete_Row
-- Purpose
--      Table api to Delete campaign Schedules.
-- History
--      22-Jan-2000    ptendulk     Created.
-- NOTE
--
-- End of Comments
-- ===============================================================
PROCEDURE Delete_Row(
    p_schedule_id  NUMBER)
IS
BEGIN

   DELETE FROM ams_campaign_schedules_b
   WHERE schedule_id = p_schedule_id;
   If (SQL%NOTFOUND) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   End If;

END Delete_Row ;

-- ===============================================================
-- Start of Comments
-- Procedure name
--      Lock_Row
-- Purpose
--      Table api to lock campaign Schedules.
-- History
--      22-Jan-2000    ptendulk     Created.
-- NOTE
--
-- End of Comments
-- ===============================================================
PROCEDURE Lock_Row(
          p_schedule_id    NUMBER
          )

IS
   CURSOR C IS
        SELECT *
         FROM ams_campaign_schedules_b
        WHERE schedule_id =  p_schedule_id
        FOR UPDATE OF schedule_id NOWAIT;
   Recinfo C%ROWTYPE;
BEGIN
    OPEN c;
    FETCH c INTO Recinfo;
    If (c%NOTFOUND) THEN
        CLOSE c;
        FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
        APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
    CLOSE C;

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
  delete from ams_campaign_schedules_tl T
  where not exists
    (select NULL
    from ams_campaign_schedules_b B
    where B.schedule_id = T.schedule_ID
    );

  update ams_campaign_schedules_tl T set (
      schedule_name
      , DESCRIPTION
      , greeting_text
      , footer_text
    ) = (select
      B.schedule_name
      , B.DESCRIPTION
      , B.greeting_text
      , B.footer_text
    from ams_campaign_schedules_tl B
    where B.schedule_id = T.schedule_id
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.schedule_id,
      T.LANGUAGE
  ) in (select
      SUBT.schedule_id,
      SUBT.LANGUAGE
    from ams_campaign_schedules_tl SUBB, ams_campaign_schedules_tl SUBT
    where SUBB.schedule_id = SUBT.schedule_id
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.schedule_name <> SUBT.schedule_name
      or SUBB.greeting_text <> SUBT.greeting_text
      or (SUBB.greeting_text is null and SUBT.greeting_text is not null)
      or (SUBB.greeting_text is not null and SUBT.greeting_text is null)
      or SUBB.footer_text <> SUBT.footer_text
      or (SUBB.footer_text is null and SUBT.footer_text is not null)
      or (SUBB.footer_text is not null and SUBT.footer_text is null)
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into ams_campaign_schedules_tl (
    schedule_id,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    schedule_name,
    greeting_text,
    footer_text,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.schedule_id,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.schedule_name,
    B.greeting_text,
    B.footer_text,
    B.DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from ams_campaign_schedules_tl B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from ams_campaign_schedules_tl T
    where T.schedule_id = B.schedule_id
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;




END AMS_CAMPAIGN_SCHEDULES_B_PKG;

/
