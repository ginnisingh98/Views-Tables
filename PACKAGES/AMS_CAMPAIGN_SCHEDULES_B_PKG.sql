--------------------------------------------------------
--  DDL for Package AMS_CAMPAIGN_SCHEDULES_B_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_CAMPAIGN_SCHEDULES_B_PKG" AUTHID CURRENT_USER AS
/* $Header: amstschs.pls 120.3 2006/05/31 11:55:41 srivikri ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--      AMS_CAMPAIGN_SCHEDULES_B_PKG
-- Purpose
--      Table api to create/insert/update campaign Schedules.
-- History
--      22-Jan-2000    ptendulk     Created.
--      24-sep-2001    soagrawa     Removed security group id from everywhere
--      12-jun-2002    soagrawa     Added add_language for bug# 2323843 for mainline
--       27-jun-2003    anchaudh     Added four more columns(trig_repeat_flag,trgp_exclude_prev,orig_csch_id,cover_letter_version) to be inserted and updated into the table.
--       12-aug-2003    dbiswas      Added 3 new columns(usage,purpose,last_activation_date) to be inserted and updated into the table.
--       25-aug-2003    dbiswas      Added 1 new columns(sales_methodology_id) to be inserted and updated into the table.
--       27-jul-2005    dbiswas      Added 1 new columns(notify_on_activation_flag) to be inserted and updated into the table.
--       29-May-2006    srivikri     Added new column - Delivery Mode
-- NOTE
--
-- End of Comments
-- ===============================================================


-- ===============================================================
-- Start of Comments
-- Procedure name
--      Insert_Row
-- Purpose
--      Table api to insert campaign Schedules.
-- History
--      22-Jan-2000    ptendulk     Created.
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
          -- p_security_group_id       NUMBER,
          p_query_id                NUMBER,
          p_include_content_flag    VARCHAR2,
          p_content_type            VARCHAR2,
          p_test_email_address      VARCHAR2,
          p_schedule_name           VARCHAR2,
          p_schedule_description    VARCHAR2,
          p_greeting_text           VARCHAR2,
         p_footer_text             VARCHAR2,
 --added by anchaudh on 30-apr-2003
	  p_trig_repeat_flag      VARCHAR2,
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
          p_notify_on_activation_flag  VARCHAR2,
	  --added by anchaudh on 01-feb-2006
          p_sender_display_name  VARCHAR2,
     -- added by srivikri on 29-May-2006
         p_delivery_mode VARCHAR2
);

-- ===============================================================
-- Start of Comments
-- Procedure name
--      Update_Row
-- Purpose
--      Table api to update campaign Schedules.
-- History
--      22-Jan-2000    ptendulk     Created.
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
	  p_trig_repeat_flag      VARCHAR2,
	  p_tgrp_exclude_prev_flag   VARCHAR2,
--added by anchaudh on 06-may-2003
	  p_orig_csch_id      NUMBER,
	  p_cover_letter_version   NUMBER,
--added by dbiswas on 12-aug-2003
	  p_usage      VARCHAR2,
	  p_purpose      VARCHAR2,
	  p_last_activation_date      DATE,
          p_sales_methodology_id      NUMBER,
          p_printer_address           VARCHAR2,
--added by dbiswas on 27-jul-2005
	  p_notify_on_activation_flag  VARCHAR2,
	  --added by anchaudh on 01-feb-2006
          p_sender_display_name  VARCHAR2,
     -- added by srivikri on 29-May-2006
         p_delivery_mode VARCHAR2

);

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
    p_schedule_id  NUMBER);

-- ===============================================================
-- Start of Comments
-- Procedure name
--      Lock_Row
-- Purpose
--      Table api to Lock campaign Schedules.
-- History
--      22-Jan-2000    ptendulk     Created.
-- NOTE
--
-- End of Comments
-- ===============================================================
PROCEDURE Lock_Row(
          p_schedule_id    NUMBER      );




-- ===============================================================
-- Start of Comments
-- Procedure name
--      ADD_LANGUAGE
-- Purpose
--
-- History
--      12-jun-2002    soagrawa     Created. Refer to bug# 2323843 for mailine
-- NOTE
--
-- End of Comments
-- ===============================================================

PROCEDURE ADD_LANGUAGE;


END AMS_CAMPAIGN_SCHEDULES_B_PKG;

 

/
