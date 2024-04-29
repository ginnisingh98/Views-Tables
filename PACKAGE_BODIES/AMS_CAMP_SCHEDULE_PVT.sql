--------------------------------------------------------
--  DDL for Package Body AMS_CAMP_SCHEDULE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_CAMP_SCHEDULE_PVT" as
/* $Header: amsvschb.pls 120.12 2007/12/26 09:36:36 spragupa ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_Camp_Schedule_PVT
-- Purpose
--          Private api created to Update/insert/Delete campaign
--          schedules
-- History
--    22-Jan-2001    ptendulk      Created.
--    18-May-2001    ptendulk    Modified the Create_camp_schedule procedure.
--    24-May-2001    ptendulk    Modified Check
--    31-May-2001    ptendulk    Modified Create_camp_Schedule procedure to add trigger call
--    16-Jun-2001    soagrawa    Modified copy_schedule api for source code changes
--    25-Jun-2001    ptendulk    Create Target group for Internet, Trade promo and deal schedules.
--    08-Jul-2001    ptendulk    Modified Validate_schedule_rec api, refer bug# 1856924
--    17-Jul-2001    ptendulk    Moved the code to start trigger workflow in business rules api
--                               Change the call to the bus rule api.
--    19-Jul-2001    ptendulk    Added columns for eBlast
--    01-Aug-2001    ptendulk    Replaced  ams_utility_pvt check_uniqueness call with
--                               manual check. Refer bug #1913448
--    18-Aug-2001    ptendulk    Added else if to take the schedule id from the api input
--                               parameter if passed.
--    11-Sep-2001    ptendulk    Added code to add the access to the schedule upon creation
--    24-sep-2001    soagrawa    Removed security group id from everywhere
--    26-sep-2001    soagrawa    Modified update_camp_schedule for start and end dates
--    12-oct-2001    soagrawa    Modified create_camp_schedule : capitalizing the generated source code
--    22 oct-2001    soagrawa    Modified copy api to fix bug# 2068786
--    03-dec-2001    soagrawa    Modified check_schedule_inter_entity: not checking against campaign's period
--                               anymore. Refer to bug# 2132456.
--    03-dec-2001    soagrawa    Modified validate_schedule_rec, bug# 2131521
--    13-dec-2001    soagrawa    In update procedure, modified source code related code, bug# 2133264
--    10-jan-2002    soagrawa    Fixed bug# 2178737
--    25-jan-2002    soagrawa    Fixed bug# 2175580 in copy schedule method
--    07-feb-2002    soagrawa    Fixed bug# 2229618 (copy does not retain the specified source code)
--                               in copy schedule method
--    20-mar-2002    soagrawa    Modified source code related code, bug# 2273902 in update_camp_schedule
--    28-mar-2002    soagrawa    Fixed bug# 2289769
--    23-apr-2002    soagrawa    Modified validation for cover letter id for new eblast
--    22-may-2002    soagrawa    Fixed bug# 2380670
--    06-jun-2002    soagrawa    Fixed bug# 2406677 in update. Now updating access table if owner changes.
--    12-jun-2002    soagrawa    Fixed ATT bug# 2376329 created by updated by issue from insert_row
--    02-jul-2002    soagrawa    Fixed bug# 2442695 in copy_camp_schedule
--    06-feb-2003    soagrawa    Fixed bug# 2788922 in copy_camp_schedule
--    24-jun-2003    dbiswas     Fixed bug# 3008802 in copy_camp_schedule
--    27-jun-2003    anchaudh    completed  triggers changes for 11510.
--    12-aug-2003    dbiswas     Added 3 new columns for schedule_rec_type
--    13-aug-2003    soagrawa    Fixed bug# 3096925 in update_camp_schedule
--    25-aug-2003    dbiswas     Added 1 new column(sales_methodology_id) for schedule_rec_type
--    23-mar-2004    soagrawa    Modified validation for triggerable schedules in validate_Schedule_rec
--                               keeping repeating schedules in consideration
--    28-jul-2004    dhsingh     Fix for Bug#3798545
--    17-may-2005    soagrawa    Added integration with locking rule API validation API
--    26-jul-2005    dbiswas     Added 1 new column(notify_on_activation_flag) for schedule_rec_type
--    29-May-2006    srivikri    added column delivery_mode
--    24-Dec-2007    spragupa	 ER - 6467510 - Extend Copy functionality to include TASKS for campaign schedules/activities
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_Camp_Schedule_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amsvschb.pls';

G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;

--===================================================================
-- NAME
--    Create_Camp_Schedule
--
-- PURPOSE
--    Creates the Campaign schedules.
--
-- NOTES
--
-- HISTORY
--   22-Jan-2001     PTENDULK    Created
--   18-May-2001     ptendulk    Added call to create list after the
--                               Direct Marketing schedule is created.
--   31-May-2001     ptendulk    Added Trigger creation after the schedule is created.
--   12-oct-2001     soagrawa    Capitalizing the generated source code
--   27-jun-2003    anchaudh  added the extra columns to be inserted for triggers changes.
--   29-May-2006    srivikri    added column delivery_mode
--===================================================================
AMS_DEBUG_HIGH_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);



PROCEDURE Create_Camp_Schedule(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_schedule_rec               IN   schedule_rec_type  := g_miss_schedule_rec,
    x_schedule_id                OUT NOCOPY  NUMBER
     )

 IS
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_Camp_Schedule';
   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_return_status_full        VARCHAR2(1);
   l_object_version_number     NUMBER := 1;
   l_org_id                    NUMBER := FND_API.G_MISS_NUM;
   l_schedule_id               NUMBER;
   l_dummy                     NUMBER;

   l_schedule_rec              schedule_rec_type := p_schedule_rec ;
   CURSOR c_id IS
      SELECT ams_campaign_schedules_b_s.NEXTVAL
      FROM dual;

   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1 FROM dual
      WHERE EXISTS (SELECT 1 FROM AMS_CAMPAIGN_SCHEDULES_B
                    WHERE SCHEDULE_ID = l_id);

   --CURSOR c_trig_exists (l_schedule_id IN NUMBER) IS
   --   SELECT 1 FROM dual
   --   WHERE EXISTS (SELECT 1 FROM ams_campaign_schedules_b
   --                 WHERE campaign_id = p_schedule_rec.campaign_id
   --                 AND   trigger_id = p_schedule_rec.trigger_id
   --                 AND   schedule_id <> l_schedule_id );

   -- soagrawa 22-oct-2002 for bug# 2594717
   CURSOR c_eone_srccd IS
   SELECT source_code
     FROM ams_event_offers_all_b
    WHERE event_offer_id = P_schedule_rec.related_event_id;

   l_eone_srccd    VARCHAR2(30);
   l_new_event_offer_id        NUMBER;
   l_event_offer_rec           AMS_EventOffer_PVT.evo_rec_type;


BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT CREATE_Camp_Schedule_PVT;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                        p_api_version_number,
                                        l_api_name,
                                        G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
   END IF;


   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (AMS_DEBUG_HIGH_ON) THEN



      AMS_UTILITY_PVT.debug_message('before handle_shced_source_code');

      END IF;
   -- Handle Status
   AMS_ScheduleRules_PVT.Handle_Status(
          p_schedule_rec.user_status_id,
          'AMS_CAMPAIGN_SCHEDULE_STATUS',
          l_schedule_rec.status_code,
          x_return_status
          );
   IF x_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
   ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
   END IF;
--
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('After handle_status');
   END IF;
   -- default campaign calendar
   IF p_schedule_rec.campaign_calendar IS NULL
   AND (p_schedule_rec.start_period_name IS NOT NULL
   OR p_schedule_rec.end_period_name IS NOT NULL)
   THEN
        l_schedule_rec.campaign_calendar := FND_PROFILE.value('AMS_CAMPAIGN_DEFAULT_CALENDER');
   END IF;

      IF (AMS_DEBUG_HIGH_ON) THEN



      AMS_UTILITY_PVT.debug_message('before handle_shced_source_code *'||p_schedule_rec.campaign_id||'*');

      END IF;
   -- default source_code
   AMS_ScheduleRules_PVT.Handle_Schedule_Source_Code(
                                p_source_code   => p_schedule_rec.source_code,
                                p_camp_id       => p_schedule_rec.campaign_id,
                                p_setup_id      => p_schedule_rec.custom_setup_id,
                                p_cascade_flag  => p_schedule_rec.use_parent_code_flag,
                                x_source_code   => l_schedule_rec.source_code,
                                x_return_status => x_return_status ) ;
   IF x_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
   ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
   END IF;
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('After handle_shced_source_code');
      END IF;

   -- Added BY soagrawa ON 12-oct-2001
   -- to capitalize the automatically generated source code

   l_schedule_rec.source_code := UPPER(l_schedule_rec.source_code);

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_Utility_PVT.debug_message('Source code : ' ||l_schedule_rec.source_code );

   END IF;
--
--
--
--   -- Local variable initialization
--
   IF p_schedule_rec.schedule_id IS NULL OR p_schedule_rec.schedule_id = FND_API.g_miss_num THEN
      LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_schedule_id;
         CLOSE c_id;

         OPEN c_id_exists(l_schedule_id);
         FETCH c_id_exists INTO l_dummy;
         CLOSE c_id_exists;
         EXIT WHEN l_dummy IS NULL;
      END LOOP;
   -- Following line of code is added by ptendulk on 18-Aug-2001
   ELSE
      l_schedule_id := p_schedule_rec.schedule_id ;
   END IF;

   -- =========================================================================
   -- Validate Environment
   -- =========================================================================
   IF FND_GLOBAL.User_Id IS NULL
   THEN
      AMS_Utility_PVT.Error_Message(p_message_name  =>  'AMS_USER_PROFILE_MISSING' );
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- If activity type code = 'EVENTS' create the underlying event for R12
   -- dbiswas added extra logic for related_source_id, related_source_code and related_source_object
   -- for bug 5019554
   IF l_schedule_rec.activity_type_code = 'EVENTS' AND
      l_schedule_rec.related_source_id  IS NULL
      AND l_schedule_rec.related_source_code  IS NULL
      AND l_schedule_rec.related_source_object IS NULL
   THEN
     -- initialize underlying dummy event
      l_event_offer_rec.event_level                 := 'MAIN' ;
      l_event_offer_rec.event_type_code             := 'BRIEFING' ;
      l_event_offer_rec.event_object_type           := 'EONE' ;
      l_event_offer_rec.reg_required_flag           := 'N' ;
      l_event_offer_rec.reg_charge_flag             := 'N' ;
      l_event_offer_rec.reg_invited_only_flag       := 'N' ;
      l_event_offer_rec.event_standalone_flag       := 'Y';
      l_event_offer_rec.create_attendant_lead_flag  := 'N' ;
      l_event_offer_rec.create_registrant_lead_flag := 'N' ;
      l_event_offer_rec.private_flag                := 'N' ;
      l_event_offer_rec.parent_type                 := 'CAMP';
      l_event_offer_rec.system_status_code          := 'NEW';
      l_event_offer_rec.user_status_id              := 1;
      l_event_offer_rec.application_id              := 530;
      l_event_offer_rec.country_code                := l_schedule_rec.country_id;
      l_event_offer_rec.custom_setup_id             := 3000;
      l_event_offer_rec.event_start_date            := l_schedule_rec.start_date_time ;
      l_event_offer_rec.event_end_date              := l_schedule_rec.end_date_time ;
      l_event_offer_rec.event_offer_name            := l_schedule_rec.schedule_name;
      l_event_offer_rec.owner_user_id               := l_schedule_rec.owner_user_id;
      l_event_offer_rec.event_language_code         := l_schedule_rec.language_code;
      l_event_offer_rec.parent_id                   := l_schedule_rec.campaign_id;
      --anshu changes for bug#5006677 starts
      l_event_offer_rec.timezone_id                 := l_schedule_rec.timezone_id;
      l_event_offer_rec.currency_code_fc            := l_schedule_rec.functional_currency_code;
      l_event_offer_rec.currency_code_tc            := l_schedule_rec.transaction_currency_code;
      --anshu changes for bug#5006677 ends

      -- null valued attributes
      l_event_offer_rec.event_location_id           := NULL;
      l_event_offer_rec.business_unit_id            := NULL;
      l_event_offer_rec.event_venue_id              := NULL;
      l_event_offer_rec.reg_start_date              := NULL;
      l_event_offer_rec.reg_end_date                := NULL;
      l_event_offer_rec.city                        := NULL;
      l_event_offer_rec.state                       := NULL;
      l_event_offer_rec.country                     := NULL;
      l_event_offer_rec.description                 := NULL;
      l_event_offer_rec.start_period_name           := NULL;
      l_event_offer_rec.end_period_name             := NULL;
      l_event_offer_rec.priority_type_code          := NULL;
      l_event_offer_rec.INVENTORY_ITEM_ID           := NULL;
      l_event_offer_rec.PRICELIST_HEADER_ID         := NULL;
      l_event_offer_rec.PRICELIST_LINE_ID           := NULL;
      l_event_offer_rec.FORECASTED_REVENUE          := NULL;
      l_event_offer_rec.ACTUAL_REVENUE              := NULL;
      l_event_offer_rec.FORECASTED_COST             := NULL;
      l_event_offer_rec.ACTUAL_COST                 := NULL;
      l_event_offer_rec.FUND_SOURCE_TYPE_CODE       := NULL;
      l_event_offer_rec.FUND_SOURCE_ID              := NULL;
      l_event_offer_rec.FUND_AMOUNT_FC              := NULL;
      l_event_offer_rec.FUND_AMOUNT_TC              := NULL;

      -- Debug message
      IF (AMS_DEBUG_HIGH_ON) THEN
          AMS_UTILITY_PVT.debug_message('before calling create event offer');
      END IF;

      AMS_EventOffer_PUB.create_EventOffer(
         p_api_version       => 1.0,
         p_init_msg_list     => FND_API.G_FALSE,
         p_commit            => FND_API.G_FALSE,
         p_validation_level  =>  FND_API.g_valid_level_full,
         p_evo_rec           => l_event_offer_rec,
         x_return_status     => x_return_status,
         x_msg_count         => x_msg_count,
         x_msg_data          => x_msg_data,
         x_evo_id            => l_new_event_offer_id
      );


      -- Debug message
      IF (AMS_DEBUG_HIGH_ON) THEN
          AMS_UTILITY_PVT.debug_message('after calling create event offer '||l_new_event_offer_id);
     END IF;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- update new schedule with this id
      l_schedule_rec.related_event_from              :=  'EONE';
      l_schedule_rec.related_event_id                :=  l_new_event_offer_id;
      l_schedule_rec.custom_setup_id                 :=3000;
   END IF;

   IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
   THEN
      -- Debug message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: Validate_Camp_Schedule');
      END IF;

      -- Invoke validation procedures
      Validate_camp_schedule(
            p_api_version_number     => 1.0,
            p_init_msg_list          => FND_API.G_FALSE,
            p_validation_level       => p_validation_level,
            p_schedule_rec           => l_schedule_rec,
            p_validation_mode        => JTF_PLSQL_API.g_create,
            x_return_status          => x_return_status,
            x_msg_count              => x_msg_count,
            x_msg_data               => x_msg_data);
   END IF;

   IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- Get the functional Currency code
   IF p_schedule_rec.budget_amount_tc IS NOT NULL AND
      p_schedule_rec.budget_amount_tc <> FND_API.G_MISS_NUM
   THEN

       AMS_CampaignRules_PVT.Convert_Camp_Currency(
           p_tc_curr     => p_schedule_rec.transaction_currency_code,
           p_tc_amt      => p_schedule_rec.budget_amount_tc,
           x_fc_curr     => l_schedule_rec.functional_currency_code,
           x_fc_amt      => l_schedule_rec.budget_amount_fc
           ) ;
   END IF ;

   -- Debug Message
--   IF (AMS_DEBUG_HIGH_ON) THEN      AMS_UTILITY_PVT.debug_message( 'Private API: Calling create table handler source :'||p_schedule_rec.source_code);   END IF;

   -- Invoke table handler(AMS_CAMPAIGN_SCHEDULES_B_PKG.Insert_Row)
   AMS_CAMPAIGN_SCHEDULES_B_PKG.Insert_Row(
          px_schedule_id  => l_schedule_id,
          -- modified by soagrawa on 12-jun-2002 for ATT bug# 2376329
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_creation_date  => SYSDATE,
          p_created_by  => FND_GLOBAL.USER_ID,
          p_last_update_login  => FND_GLOBAL.LOGIN_ID,
          /*
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => G_USER_ID,
          p_creation_date  => SYSDATE,
          p_created_by  => G_USER_ID,
          p_last_update_login  => G_LOGIN_ID,
          */
          px_object_version_number  => l_object_version_number,
          p_campaign_id  => p_schedule_rec.campaign_id,
          p_user_status_id  => p_schedule_rec.user_status_id,
          p_status_code  => l_schedule_rec.status_code,
          p_status_date  => NVL(p_schedule_rec.status_date,SYSDATE),
          p_source_code  => l_schedule_rec.source_code,
          p_use_parent_code_flag  => p_schedule_rec.use_parent_code_flag,
          p_start_date_time  => p_schedule_rec.start_date_time,
          p_end_date_time  => p_schedule_rec.end_date_time,
          p_timezone_id  => p_schedule_rec.timezone_id,
          p_activity_type_code  => p_schedule_rec.activity_type_code,
          p_activity_id  => p_schedule_rec.activity_id,
          p_arc_marketing_medium_from  => p_schedule_rec.arc_marketing_medium_from,
          p_marketing_medium_id  => p_schedule_rec.marketing_medium_id,
          p_custom_setup_id  => p_schedule_rec.custom_setup_id,
          p_triggerable_flag  => p_schedule_rec.triggerable_flag,
          p_trigger_id  => p_schedule_rec.trigger_id,
          p_notify_user_id  => p_schedule_rec.notify_user_id,
          p_approver_user_id  => p_schedule_rec.approver_user_id,
          p_owner_user_id  => p_schedule_rec.owner_user_id,
          p_active_flag  => p_schedule_rec.active_flag,
          -- soagrawa removed on 03-nov-2003 for 11.5.10
           p_cover_letter_id  => null,
          p_reply_to_mail  => p_schedule_rec.reply_to_mail,
          p_mail_sender_name  => p_schedule_rec.mail_sender_name,
          p_mail_subject  => p_schedule_rec.mail_subject,
          p_from_fax_no  => p_schedule_rec.from_fax_no,
          p_accounts_closed_flag  => NVL(p_schedule_rec.accounts_closed_flag,'N'),
          px_org_id  => l_org_id,
          p_objective_code  => p_schedule_rec.objective_code,
          p_country_id  => p_schedule_rec.country_id,
          p_campaign_calendar  => l_schedule_rec.campaign_calendar,
          p_start_period_name  => p_schedule_rec.start_period_name,
          p_end_period_name  => p_schedule_rec.end_period_name,
          p_priority  => p_schedule_rec.priority,
          p_workflow_item_key  => p_schedule_rec.workflow_item_key,
          p_transaction_currency_code => p_schedule_rec.transaction_currency_code,
          p_functional_currency_code => l_schedule_rec.functional_currency_code,
          p_budget_amount_tc => p_schedule_rec.budget_amount_tc,
          p_budget_amount_fc => l_schedule_rec.budget_amount_fc,
          p_language_code => p_schedule_rec.language_code,
          p_task_id => p_schedule_rec.task_id,
          p_related_event_from => l_schedule_rec.related_event_from,
          p_related_event_id => l_schedule_rec.related_event_id,
          p_attribute_category  => p_schedule_rec.attribute_category,
          p_attribute1  => p_schedule_rec.attribute1,
          p_attribute2  => p_schedule_rec.attribute2,
          p_attribute3  => p_schedule_rec.attribute3,
          p_attribute4  => p_schedule_rec.attribute4,
          p_attribute5  => p_schedule_rec.attribute5,
          p_attribute6  => p_schedule_rec.attribute6,
          p_attribute7  => p_schedule_rec.attribute7,
          p_attribute8  => p_schedule_rec.attribute8,
          p_attribute9  => p_schedule_rec.attribute9,
          p_attribute10  => p_schedule_rec.attribute10,
          p_attribute11  => p_schedule_rec.attribute11,
          p_attribute12  => p_schedule_rec.attribute12,
          p_attribute13  => p_schedule_rec.attribute13,
          p_attribute14  => p_schedule_rec.attribute14,
          p_attribute15  => p_schedule_rec.attribute15,
          p_activity_attribute_category  => p_schedule_rec.activity_attribute_category,
          p_activity_attribute1  => p_schedule_rec.activity_attribute1,
          p_activity_attribute2  => p_schedule_rec.activity_attribute2,
          p_activity_attribute3  => p_schedule_rec.activity_attribute3,
          p_activity_attribute4  => p_schedule_rec.activity_attribute4,
          p_activity_attribute5  => p_schedule_rec.activity_attribute5,
          p_activity_attribute6  => p_schedule_rec.activity_attribute6,
          p_activity_attribute7  => p_schedule_rec.activity_attribute7,
          p_activity_attribute8  => p_schedule_rec.activity_attribute8,
          p_activity_attribute9  => p_schedule_rec.activity_attribute9,
          p_activity_attribute10  => p_schedule_rec.activity_attribute10,
          p_activity_attribute11  => p_schedule_rec.activity_attribute11,
          p_activity_attribute12  => p_schedule_rec.activity_attribute12,
          p_activity_attribute13  => p_schedule_rec.activity_attribute13,
          p_activity_attribute14  => p_schedule_rec.activity_attribute14,
          p_activity_attribute15  => p_schedule_rec.activity_attribute15,
          -- removed by soagrawa on 24-sep-2001
          -- p_security_group_id  => p_schedule_rec.security_group_id,
          p_query_id              => p_schedule_rec.query_id,
          p_include_content_flag  => p_schedule_rec.include_content_flag,
          p_content_type          => p_schedule_rec.content_type,
          p_test_email_address    => p_schedule_rec.test_email_address,
          p_schedule_name         => p_schedule_rec.schedule_name,
          p_schedule_description  => p_schedule_rec.description,
          p_greeting_text         => p_schedule_rec.greeting_text,
          p_footer_text           => p_schedule_rec.footer_text,
        --following is added by anchaudh on 27-jun-2003
          p_trig_repeat_flag    => p_schedule_rec.trig_repeat_flag,
          p_tgrp_exclude_prev_flag     => p_schedule_rec.tgrp_exclude_prev_flag,
          p_orig_csch_id    => p_schedule_rec.orig_csch_id,
          p_cover_letter_version     => p_schedule_rec.cover_letter_version,
       -- added by dbiswas on Aug 12, 2003
          p_usage                    => p_schedule_rec.usage,
          p_purpose                  => p_schedule_rec.purpose,
          p_last_activation_date     => p_schedule_rec.last_activation_date,
          p_sales_methodology_id     => p_schedule_rec.sales_methodology_id,
          p_printer_address          => p_schedule_rec.printer_address,
       -- added by dbiswas on Jul 27, 2005
          p_notify_on_activation_flag => p_schedule_rec.notify_on_activation_flag,
	  -- added by anchaudh on Feb 01, 2006
          p_sender_display_name => p_schedule_rec.sender_display_name,
     --    added by srivikri on 29-May-2006
          p_delivery_mode       => p_schedule_rec.delivery_mode

 );

   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_ERROR;
   END IF;


   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message('Before Source code : '||l_schedule_id );
   END IF;

   -- need to push the source code to ams_source_codes
   IF p_schedule_rec.use_parent_code_flag = 'N' THEN

     -- soagrawa 22-oct-2002 for bug# 2594717
     IF P_schedule_rec.related_event_id IS NOT NULL
     THEN
         OPEN  c_eone_srccd;
         FETCH c_eone_srccd INTO l_eone_srccd;
         CLOSE c_eone_srccd;

         AMS_CampaignRules_PVT.push_source_code(
            l_schedule_rec.source_code,
            'CSCH',
            l_schedule_id,
            l_eone_srccd,     --P_schedule_rec.related_source_code,
            P_schedule_rec.related_source_object,
            P_schedule_rec.related_event_id -- P_schedule_rec.related_source_id
           );
     ELSE
         AMS_CampaignRules_PVT.push_source_code(
            l_schedule_rec.source_code,
            'CSCH',
            l_schedule_id
           );
     END IF;
   END IF ;


   -- Following code is added by ptendulk on 11-Sep-2001
   -- Create access record for the schedules  from campaigs
      AMS_ScheduleRules_PVT.Create_Schedule_Access(
                                 p_schedule_id        => l_schedule_id ,
                                 p_campaign_id        => p_schedule_rec.campaign_id ,
                                 p_owner_id           => p_schedule_rec.owner_user_id,
                                 p_init_msg_list      => p_init_msg_list,
                                 p_commit             => p_commit,
                                 p_validation_level   => p_validation_level,

                                 x_return_status      => x_return_status,
                                 x_msg_count          => x_msg_count,
                                 x_msg_data           => x_msg_data
                                 );

   -- Following line of code is added by ptendulk on 31-May-2001
   -- to start the trigger workflow process.
   -- Start the trigger if the schedule is using trigger and the trigger
   -- does not have any other schedule associated to it.


 /*  IF p_schedule_rec.trigger_id IS NOT NULL AND
      p_schedule_rec.trigger_id <> FND_API.G_MISS_NUM AND
      p_schedule_rec.triggerable_flag IS NOT NULL AND
      p_schedule_rec.triggerable_flag = 'Y'
   THEN
      -- Following code is commented by ptendulk on 16-Jul-2001
      -- Moved the code to the business rule api.
      --OPEN c_trig_exists(l_schedule_id);
      --FETCH c_trig_exists INTO l_dummy;
      --CLOSE c_trig_exists;

      --IF l_dummy IS NULL THEN
      --   -- Start the trigger process as this is the first schedule associated to the schedule.
      --   AMS_WFTRIG_PVT.StartProcess(p_trigger_id   =>  p_schedule_rec.trigger_id) ;
      --END IF ;
      AMS_ScheduleRules_PVT.Start_Trigger_Process(p_schedule_id   =>   p_schedule_rec.schedule_id,
                                                  p_trigger_id    =>   p_schedule_rec.trigger_id) ;
   END IF;*/

   -- create object association when channel is event
   --IF l_camp_rec.media_type_code = 'EVENTS'
--      AND l_camp_rec.channel_id IS NOT NULL
--   THEN
--      AMS_CampaignRules_PVT.create_camp_association(
--         l_camp_rec.campaign_id,
--         l_camp_rec.channel_id,
--         l_camp_rec.arc_channel_from,
--         l_return_status
--      );
--      IF l_return_status = FND_API.g_ret_sts_error THEN
--         RAISE FND_API.g_exc_error;
--      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
--         RAISE FND_API.g_exc_unexpected_error;
--      END IF;
--   END IF;

   -- attach seeded metrics to created schedules
   AMS_RefreshMetric_PVT.copy_seeded_metric(
      p_api_version => 1.0,
      x_return_status => x_return_status,
      x_msg_count => x_msg_count,
      x_msg_data => x_msg_data,
      p_arc_act_metric_used_by =>'CSCH',
      p_act_metric_used_by_id => l_schedule_id,
      p_act_metric_used_by_type => NULL
   );
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message('Metrics Copied Status '||x_return_status);
   END IF;
   IF x_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_Utility_PVT.debug_message('Errr '||sqlerrm);
      END IF;
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_Utility_PVT.debug_message('Create Target Group for schedule : '||l_schedule_id );

   END IF;
   IF p_schedule_rec.activity_type_code IN ('DIRECT_MARKETING','INTERNET','DEAL','TRADE_PROMOTION') THEN
      AMS_ScheduleRules_PVT.Create_list(
         p_schedule_id     =>    l_schedule_id,
         p_schedule_name   =>    p_schedule_rec.schedule_name,
         p_owner_id        =>    p_schedule_rec.owner_user_id) ;
      IF x_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
         IF (AMS_DEBUG_HIGH_ON) THEN

         AMS_Utility_PVT.debug_message('Errr '||sqlerrm);
         END IF;
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF ;

   x_schedule_id := l_schedule_id ;
   --
   -- End of API body
   --

   -- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit )
   THEN
      COMMIT WORK;
   END IF;

   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
     AMS_Utility_Pvt.Error_Message('AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO CREATE_Camp_Schedule_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_Camp_Schedule_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_Camp_Schedule_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
End Create_Camp_Schedule;

--===================================================================
-- NAME
--    Update_Camp_Schedule
--
-- PURPOSE
--    Private api to Update Campaign schedules.
--
-- NOTES
--    1. When the Status of the schedule is updated , depending on
--       status order rules and custom setup , workflow process is
--       submitted for approvals.
--
-- HISTORY
--   22-Jan-2001     PTENDULK   Created
--   26-sep-2001     soagrawa   Modified start date and end date update
--   13-dec-2001     soagrawa   Modified source code related code, bug# 2133264
--   20-mar-2002     soagrawa   Modified source code related code, bug# 2273902
--   06-jun-2002     soagrawa   Fixed bug# 2406677. Now updating access table if owner changes
--   27-jun-2003     anchaudh   added the extra columns to be updated for triggers chnages.
--   13-aug-2003     soagrawa   Fixed bug# 3096925
--   29-May-2006     srivikri   added column delivery_mode
--===================================================================
PROCEDURE Update_Camp_Schedule(
   p_api_version_number         IN   NUMBER,
   p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
   p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
   p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

   x_return_status              OUT NOCOPY  VARCHAR2,
   x_msg_count                  OUT NOCOPY  NUMBER,
   x_msg_data                   OUT NOCOPY  VARCHAR2,

   p_schedule_rec               IN   schedule_rec_type,
   x_object_version_number      OUT NOCOPY  NUMBER
    )

IS

   CURSOR c_get_camp_schedule(schedule_id IN NUMBER) IS
     SELECT *
     FROM  ams_campaign_schedules_vl
     WHERE schedule_id = p_schedule_rec.schedule_id ;

   -- Start: added by anchaudh for trigger related validation on 27-jun-2003.
   CURSOR c_get_trig_schedule_details(schedule_id IN NUMBER) IS
     SELECT  status_code, triggerable_flag, trigger_id,
             trig_repeat_flag, tgrp_exclude_prev_flag, activity_type_code
     FROM  ams_campaign_schedules_b
     WHERE schedule_id = p_schedule_rec.schedule_id ;
   -- End: added by anchaudh for trigger related validation on 27-jun-2003.

   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Camp_Schedule';
   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   -- Local Variables
   l_object_version_number     NUMBER;
   l_schedule_id               NUMBER;
   l_ref_schedule_rec          c_get_Camp_Schedule%ROWTYPE ;
   l_complete_rec              AMS_Camp_Schedule_PVT.schedule_rec_type := P_schedule_rec;
   l_tar_schedule_rec          AMS_Camp_Schedule_PVT.schedule_rec_type := P_schedule_rec;
   x_source_code               VARCHAR2(30);
   l_source_code               VARCHAR2(30);
   -- Start: added by anchaudh for trigger related validation on 27-jun-2003.
   l_status_code               VARCHAR2(30);
   l_triggerable_flag          VARCHAR2(1);
   l_trigger_id                NUMBER;
   l_trig_repeat_flag          VARCHAR2(1);
   l_tgrp_exclude_prev_flag    VARCHAR2(1);
   l_act_type_code             VARCHAR2(30);
   -- End: added by anchaudh for trigger related validation on 27-jun-2003.

   l_field_ak_name_array       JTF_VARCHAR2_TABLE_100 := JTF_VARCHAR2_TABLE_100()   ;
   l_change_indicator_array    JTF_VARCHAR2_TABLE_100 := JTF_VARCHAR2_TABLE_100()   ;


BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT UPDATE_Camp_Schedule_PVT;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                        p_api_version_number,
                                        l_api_name,
                                        G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
   END IF;


   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Private API: - Open Cursor to Select');
   END IF;


   OPEN c_get_Camp_Schedule(l_tar_schedule_rec.schedule_id);
   FETCH c_get_Camp_Schedule INTO l_ref_schedule_rec  ;

   If ( c_get_Camp_Schedule%NOTFOUND) THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
      THEN
         FND_MESSAGE.Set_Name('AMS', 'API_MISSING_UPDATE_TARGET');
         FND_MESSAGE.Set_Token ('INFO', 'Camp_Schedule', FALSE);
         FND_MSG_PUB.Add;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Private API: - Close Cursor');
   END IF;
   CLOSE     c_get_Camp_Schedule;


   IF (l_tar_schedule_rec.object_version_number IS NULL OR
       l_tar_schedule_rec.object_version_number = FND_API.G_MISS_NUM ) THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
      THEN
         FND_MESSAGE.Set_Name('AMS', 'API_VERSION_MISSING');
         FND_MESSAGE.Set_Token('COLUMN', 'Last_Update_Date', FALSE);
         FND_MSG_PUB.ADD;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- Check Whether record has been changed by someone else
   IF (l_tar_schedule_rec.object_version_number <> l_ref_schedule_rec.object_version_number) Then
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
      THEN
         FND_MESSAGE.Set_Name('AMS', 'API_RECORD_CHANGED');
         FND_MESSAGE.Set_Token('INFO', 'Camp_Schedule', FALSE);
         FND_MSG_PUB.ADD;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   Complete_schedule_Rec(P_schedule_rec     =>  p_schedule_rec ,
                         x_complete_rec     =>  l_complete_rec);

   -- soagrawa 13-aug-2003 modified code in the following lines to fix P1 bug 3096925
   -- also modified cursor related to this.
   -- Start: added by anchaudh for trigger related validation on 28-May-2003.
   OPEN c_get_trig_schedule_details(l_tar_schedule_rec.schedule_id);
   FETCH c_get_trig_schedule_details
   INTO l_status_code, l_triggerable_flag, l_trigger_id,
        l_trig_repeat_flag, l_tgrp_exclude_prev_flag, l_act_type_code ;
   CLOSE c_get_trig_schedule_details;

   IF (l_act_type_code = 'DIRECT_MARKETING' AND (l_status_code = 'ACTIVE')) THEN
      IF (  l_complete_rec.triggerable_flag <> l_triggerable_flag
         OR l_complete_rec.trigger_id       <> l_trigger_id
         OR l_complete_rec.trig_repeat_flag <> l_trig_repeat_flag
         OR l_complete_rec.tgrp_exclude_prev_flag <> l_tgrp_exclude_prev_flag)
      THEN
          AMS_Utility_PVT.Error_Message('AMS_TRIG_DETAILS_NO_UPDATE');
          x_return_status := FND_API.G_RET_STS_ERROR;
          RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;
   -- End: added by anchaudh for trigger related validation on 28-May-2003.



   -- Add Locking Rule API validation
   -- soagrawa 17-may-2005 for Web ADI

	/*
	AMS_COVER_LETTER                        cover_letter_id
	AMS_CSCH_OBJECTIVE                      objective_code
	AMS_CURRENCY                            transaction_currency_code
	AMS_DESCRIPTION                         description
	AMS_END_DATE                            end_date_time
	AMS_LANGUAGE                            language_code
	AMS_MARKETING_MEDIUM                    marketing_medium_id
	AMS_NAME                                schedule_name
	AMS_REG_TIMEZONE                        timezone_id
	AMS_REPLY_TO                            reply_to_mail
	AMS_SENDER                              mail_sender_name
	AMS_SEND_NOTIFICATION_TO                notify_user_id
	AMS_SOURCE_CODE                         source_code
	AMS_START_DATE                          start_date_time
	AMS_STATUS                              user_status_id
	AMS_SUBJECT                             mail_subject
	AMS_TRIG_EXEC                           approver_user_id
	AMS_TRIG_TITLE                          triggerable_flag
	AMS_USE_PARENT_SOURCE_CODE              use_parent_code_flag
	AMS_USE_TRIGGER                         trigger_id
	*/


    FOR i in 1 .. 20
    LOOP
       l_field_ak_name_array.extend();
       l_change_indicator_array.extend();
       l_change_indicator_array(i) := 'N';
    END LOOP;

    l_field_ak_name_array(1)  := 'AMS_COVER_LETTER';
    l_field_ak_name_array(2)  := 'AMS_CSCH_OBJECTIVE';
    l_field_ak_name_array(3)  := 'AMS_CURRENCY';
    l_field_ak_name_array(4)  := 'AMS_DESCRIPTION';
    l_field_ak_name_array(5)  := 'AMS_END_DATE';
    l_field_ak_name_array(6)  := 'AMS_LANGUAGE';
    l_field_ak_name_array(7)  := 'AMS_MARKETING_MEDIUM';
    l_field_ak_name_array(8)  := 'AMS_NAME';
    l_field_ak_name_array(9)  := 'AMS_REG_TIMEZONE';
    l_field_ak_name_array(10) := 'AMS_REPLY_TO';
    l_field_ak_name_array(11) := 'AMS_SENDER';
    l_field_ak_name_array(12) := 'AMS_SEND_NOTIFICATION_TO';
    l_field_ak_name_array(13) := 'AMS_SOURCE_CODE';
    l_field_ak_name_array(14) := 'AMS_START_DATE';
    l_field_ak_name_array(15) := 'AMS_STATUS';
    l_field_ak_name_array(16) := 'AMS_SUBJECT';
    l_field_ak_name_array(17) := 'AMS_TRIG_EXEC';
    l_field_ak_name_array(18) := 'AMS_TRIG_TITLE';
    l_field_ak_name_array(19) := 'AMS_USE_PARENT_SOURCE_CODE';
    l_field_ak_name_array(20) := 'AMS_USE_TRIGGER';


    IF l_ref_schedule_rec.cover_letter_id <> l_complete_rec.cover_letter_id
    THEN
       l_change_indicator_array(1) := 'Y';
    END IF;
    IF l_ref_schedule_rec.objective_code <> l_complete_rec.objective_code
    THEN
       l_change_indicator_array(2) := 'Y';
    END IF;
    IF l_ref_schedule_rec.transaction_currency_code <> l_complete_rec.transaction_currency_code
    THEN
       l_change_indicator_array(3) := 'Y';
    END IF;
    IF l_ref_schedule_rec.description <> l_complete_rec.description
    THEN
       l_change_indicator_array(4) := 'Y';
    END IF;
    IF l_ref_schedule_rec.end_date_time <> l_complete_rec.end_date_time
    THEN
       l_change_indicator_array(5) := 'Y';
    END IF;
    IF l_ref_schedule_rec.language_code <> l_complete_rec.language_code
    THEN
       l_change_indicator_array(6) := 'Y';
    END IF;
    IF l_ref_schedule_rec.marketing_medium_id <> l_complete_rec.marketing_medium_id
    THEN
       l_change_indicator_array(7) := 'Y';
    END IF;
    IF l_ref_schedule_rec.schedule_name <> l_complete_rec.schedule_name
    THEN
       l_change_indicator_array(8) := 'Y';
    END IF;
    IF l_ref_schedule_rec.timezone_id <> l_complete_rec.timezone_id
    THEN
       l_change_indicator_array(9) := 'Y';
    END IF;
    IF l_ref_schedule_rec.reply_to_mail <> l_complete_rec.reply_to_mail
    THEN
       l_change_indicator_array(10) := 'Y';
    END IF;
    IF l_ref_schedule_rec.mail_sender_name <> l_complete_rec.mail_sender_name
    THEN
       l_change_indicator_array(11) := 'Y';
    END IF;
    IF l_ref_schedule_rec.notify_user_id <> l_complete_rec.notify_user_id
    THEN
       l_change_indicator_array(12) := 'Y';
    END IF;
    IF l_ref_schedule_rec.source_code <> l_complete_rec.source_code
    THEN
       l_change_indicator_array(13) := 'Y';
    END IF;
    IF l_ref_schedule_rec.start_date_time <> l_complete_rec.start_date_time
    THEN
       l_change_indicator_array(14) := 'Y';
    END IF;
    IF l_ref_schedule_rec.user_status_id <> l_complete_rec.user_status_id
    THEN
       l_change_indicator_array(15) := 'Y';
    END IF;
    IF l_ref_schedule_rec.mail_subject <> l_complete_rec.mail_subject
    THEN
       l_change_indicator_array(16) := 'Y';
    END IF;
    IF l_ref_schedule_rec.approver_user_id <> l_complete_rec.approver_user_id
    THEN
       l_change_indicator_array(17) := 'Y';
    END IF;
    IF l_ref_schedule_rec.triggerable_flag <> l_complete_rec.triggerable_flag
    THEN
       l_change_indicator_array(18) := 'Y';
    END IF;
    IF l_ref_schedule_rec.use_parent_code_flag <> l_complete_rec.use_parent_code_flag
    THEN
       l_change_indicator_array(19) := 'Y';
    END IF;
    IF l_ref_schedule_rec.trigger_id <> l_complete_rec.trigger_id
    THEN
       l_change_indicator_array(20) := 'Y';
    END IF;


    AMS_Utility_PVT.validate_locking_rules(
                     'AMS'
                   , 'CSCH'
                   , 'DETL'
                   , l_ref_schedule_rec.status_code
                   , l_field_ak_name_array
                   , l_change_indicator_array
                   , x_return_status);

    IF x_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
    ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
    END IF;

   -- End Locking Rule API Validation



   -- default campaign_calendar
   IF p_schedule_rec.start_period_name IS NULL
      AND p_schedule_rec.end_period_name IS NULL
   THEN
      l_tar_schedule_rec.campaign_calendar := NULL;
   ELSE
      l_tar_schedule_rec.campaign_calendar := FND_PROFILE.value('AMS_CAMPAIGN_DEFAULT_CALENDER');
   END IF;

   IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
   THEN
      -- Debug message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: Validate_Camp_Schedule');
      END IF;

      -- Invoke validation procedures
      Validate_camp_schedule(
            p_api_version_number     => 1.0,
            p_init_msg_list          => FND_API.G_FALSE,
            p_validation_level       => p_validation_level,
            p_schedule_rec           => p_schedule_rec,
            p_validation_mode        => JTF_PLSQL_API.g_update,
            x_return_status          => x_return_status,
            x_msg_count              => x_msg_count,
            x_msg_data               => x_msg_data);
   END IF;

   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- Check Schedule Update
   AMS_ScheduleRules_PVT.Check_Schedule_Update(
                               p_schedule_rec    =>  l_complete_rec,
                               x_return_status   =>  x_return_status);

   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_ERROR;
   END IF;
   -- Handle Source Code update

   if p_schedule_rec.source_code IS NULL THEN
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_Utility_PVT.debug_message(l_api_name ||': update source code');
      END IF;
   end if ;
   IF p_schedule_rec.use_parent_code_flag = FND_API.g_miss_char
   AND p_schedule_rec.source_code = FND_API.g_miss_char
   THEN
      -- following line added by soagrawa on 20-mar-2002
      l_source_code := l_ref_schedule_rec.source_code;
      -- NULL ;
   ELSE
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_Utility_PVT.debug_message(l_api_name ||': update source code222');
      END IF;
      AMS_ScheduleRules_PVT.Check_Source_Code(
                              p_schedule_rec   => p_schedule_rec,
                              x_return_status  => x_return_status,
                              -- next line added by soagrawa on 12-dec-2001, bug# 2133264
                              x_source_code    => l_source_code -- l_complete_rec.source_code
                              ) ;
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_Utility_PVT.debug_message(l_api_name ||': updated source code '||l_source_code);
      END IF;
      IF x_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;



   END IF ;

   -- Get the functional Currency code
   IF p_schedule_rec.budget_amount_tc IS NOT NULL AND
      p_schedule_rec.budget_amount_tc <> FND_API.G_MISS_NUM THEN
       IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_Utility_pvt.debug_message('Transaction curr : '||p_schedule_rec.transaction_currency_code);
       END IF;
       AMS_CampaignRules_PVT.Convert_Camp_Currency(
           p_tc_curr     => p_schedule_rec.transaction_currency_code,
           p_tc_amt      => p_schedule_rec.budget_amount_tc,
           x_fc_curr     => l_tar_schedule_rec.functional_currency_code,
           x_fc_amt      => l_tar_schedule_rec.budget_amount_fc
           ) ;
   END IF ;


   -- updating access denorm table added by soagrawa on 06-jun-2002
   --refer to bug# 2406677

   -- Change the owner in Access table if the owner is changed.

   IF  p_schedule_rec.owner_user_id <> FND_API.g_miss_num
   THEN
      AMS_ScheduleRules_PVT.Update_Schedule_Owner(
           p_api_version       => p_api_version_number,
           p_init_msg_list     => p_init_msg_list,
           p_commit            => p_commit,
           p_validation_level  => p_validation_level,
           x_return_status     => x_return_status,
           x_msg_count         => x_msg_count,
           x_msg_data          => x_msg_data,
           p_object_type       => 'CSCH' ,
           p_schedule_id       => p_schedule_rec.schedule_id,
           p_owner_id          => p_schedule_rec.owner_user_id
           );
      IF x_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF ;



   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Private API: Calling update table handler sched : '||to_char(p_schedule_rec.schedule_id));
   END IF;

   -- Invoke table handler(AMS_CAMPAIGN_SCHEDULES_B_PKG.Update_Row)
   AMS_CAMPAIGN_SCHEDULES_B_PKG.Update_Row(
          p_schedule_id  => p_schedule_rec.schedule_id,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => G_USER_ID,
          p_creation_date  => SYSDATE,
          p_created_by  => G_USER_ID,
          p_last_update_login  => G_LOGIN_ID,
          p_object_version_number  => p_schedule_rec.object_version_number ,
          p_campaign_id  => p_schedule_rec.campaign_id,
          p_user_status_id  => FND_API.G_MISS_NUM,
          p_status_code  => FND_API.G_MISS_CHAR,
          p_status_date  => FND_API.G_MISS_DATE,
          -- modified on 12-dec-2001 by soagrawa, bug# 2133264
          -- p_source_code  => p_schedule_rec.source_code,
          p_source_code  => l_source_code,
          p_use_parent_code_flag  => p_schedule_rec.use_parent_code_flag,
          -- modified by soagrawa on 26-sep-2001 after changing amstschb.pls
          -- p_start_date_time  => p_schedule_rec.start_date_time,
          -- p_end_date_time  => p_schedule_rec.end_date_time,
          p_start_date_time  => l_complete_rec.start_date_time,
          p_end_date_time  => l_complete_rec.end_date_time,
          p_timezone_id  => p_schedule_rec.timezone_id,
          p_activity_type_code  => p_schedule_rec.activity_type_code,
          p_activity_id  => p_schedule_rec.activity_id,
          p_arc_marketing_medium_from  => p_schedule_rec.arc_marketing_medium_from,
          p_marketing_medium_id  => p_schedule_rec.marketing_medium_id,
          p_custom_setup_id  => p_schedule_rec.custom_setup_id,
          p_triggerable_flag  => p_schedule_rec.triggerable_flag,
          p_trigger_id  => p_schedule_rec.trigger_id,
          p_notify_user_id  => p_schedule_rec.notify_user_id,
          p_approver_user_id  => p_schedule_rec.approver_user_id,
          p_owner_user_id  => p_schedule_rec.owner_user_id,
          p_active_flag  => p_schedule_rec.active_flag,
          -- soagrawa removed on 03-nov-2003 for 11.5.10
          p_cover_letter_id  => null,
          p_reply_to_mail  => p_schedule_rec.reply_to_mail,
          p_mail_sender_name  => p_schedule_rec.mail_sender_name,
          p_mail_subject  => p_schedule_rec.mail_subject,
          p_from_fax_no  => p_schedule_rec.from_fax_no,
          p_accounts_closed_flag  => p_schedule_rec.accounts_closed_flag,
          p_org_id  => p_schedule_rec.org_id,
          p_objective_code  => p_schedule_rec.objective_code,
          p_country_id  => p_schedule_rec.country_id,
          p_campaign_calendar  => l_tar_schedule_rec.campaign_calendar,
          p_start_period_name  => p_schedule_rec.start_period_name,
          p_end_period_name  => p_schedule_rec.end_period_name,
          p_priority  => p_schedule_rec.priority,
          p_workflow_item_key  => p_schedule_rec.workflow_item_key,
          p_transaction_currency_code => p_schedule_rec.transaction_currency_code,
          p_functional_currency_code => l_tar_schedule_rec.functional_currency_code,
          p_attribute_category  => p_schedule_rec.attribute_category,
          p_budget_amount_tc => p_schedule_rec.budget_amount_tc,
          p_budget_amount_fc => l_tar_schedule_rec.budget_amount_fc,
          p_language_code => p_schedule_rec.language_code,
          p_task_id => p_schedule_rec.task_id,
          p_related_event_from => p_schedule_rec.related_event_from,
          p_related_event_id => p_schedule_rec.related_event_id,
          p_attribute1  => p_schedule_rec.attribute1,
          p_attribute2  => p_schedule_rec.attribute2,
          p_attribute3  => p_schedule_rec.attribute3,
          p_attribute4  => p_schedule_rec.attribute4,
          p_attribute5  => p_schedule_rec.attribute5,
          p_attribute6  => p_schedule_rec.attribute6,
          p_attribute7  => p_schedule_rec.attribute7,
          p_attribute8  => p_schedule_rec.attribute8,
          p_attribute9  => p_schedule_rec.attribute9,
          p_attribute10  => p_schedule_rec.attribute10,
          p_attribute11  => p_schedule_rec.attribute11,
          p_attribute12  => p_schedule_rec.attribute12,
          p_attribute13  => p_schedule_rec.attribute13,
          p_attribute14  => p_schedule_rec.attribute14,
          p_attribute15  => p_schedule_rec.attribute15,
          p_activity_attribute_category  => p_schedule_rec.activity_attribute_category,
          p_activity_attribute1  => p_schedule_rec.activity_attribute1,
          p_activity_attribute2  => p_schedule_rec.activity_attribute2,
          p_activity_attribute3  => p_schedule_rec.activity_attribute3,
          p_activity_attribute4  => p_schedule_rec.activity_attribute4,
          p_activity_attribute5  => p_schedule_rec.activity_attribute5,
          p_activity_attribute6  => p_schedule_rec.activity_attribute6,
          p_activity_attribute7  => p_schedule_rec.activity_attribute7,
          p_activity_attribute8  => p_schedule_rec.activity_attribute8,
          p_activity_attribute9  => p_schedule_rec.activity_attribute9,
          p_activity_attribute10  => p_schedule_rec.activity_attribute10,
          p_activity_attribute11  => p_schedule_rec.activity_attribute11,
          p_activity_attribute12  => p_schedule_rec.activity_attribute12,
          p_activity_attribute13  => p_schedule_rec.activity_attribute13,
          p_activity_attribute14  => p_schedule_rec.activity_attribute14,
          p_activity_attribute15  => p_schedule_rec.activity_attribute15,
          -- removed by soagrawa on 24-sep-2001
          -- p_security_group_id  => p_schedule_rec.security_group_id,
          p_query_id              => p_schedule_rec.query_id,
          p_include_content_flag  => p_schedule_rec.include_content_flag,
          p_content_type          => p_schedule_rec.content_type,
          p_test_email_address    => p_schedule_rec.test_email_address,
          p_schedule_name         => p_schedule_rec.schedule_name,
          p_schedule_description  => p_schedule_rec.description,
          p_greeting_text         => p_schedule_rec.greeting_text,
          p_footer_text           => p_schedule_rec.footer_text,
         --following is added by anchaudh on 27-jun-2003
          p_trig_repeat_flag    => p_schedule_rec.trig_repeat_flag,
          p_tgrp_exclude_prev_flag     => p_schedule_rec.tgrp_exclude_prev_flag,
          p_orig_csch_id    => p_schedule_rec.orig_csch_id,
          p_cover_letter_version     => p_schedule_rec.cover_letter_version,
       -- added by dbiswas on Aug 12, 2003
          p_usage                    => p_schedule_rec.usage,
          p_purpose                  => p_schedule_rec.purpose,
          p_last_activation_date     => p_schedule_rec.last_activation_date,
          p_sales_methodology_id     => p_schedule_rec.sales_methodology_id,
          p_printer_address          => p_schedule_rec.printer_address,
       -- added by dbiswas on Jul 27, 2005
          p_notify_on_activation_flag => p_schedule_rec.notify_on_activation_flag,
	  -- added by anchaudh on Feb 01, 2006
          p_sender_display_name => p_schedule_rec.sender_display_name,
          p_delivery_mode       => p_schedule_rec.delivery_mode
          );

   -- create object association when channel is event
--   IF p_schedule_rec.media_type_code = 'EVENTS' THEN
--      AMS_CampaignRules_PVT.create_camp_association(
--         l_camp_rec.campaign_id,
--         l_camp_rec.channel_id,
--         l_camp_rec.arc_channel_from,
--         l_return_status
--      );
--      IF l_return_status = FND_API.g_ret_sts_error THEN
--         RAISE FND_API.g_exc_error;
--      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
--         RAISE FND_API.g_exc_unexpected_error;
--      END IF;
--   END IF;

   -- update campaign status through workflow
--   AMS_ScheduleRules_PVT.Update_Csch_status(
--      p_schedule_rec.schedule_id,
--      p_schedule_rec.user_status_id,
--      p_schedule_rec.budget_amount_tc
--   );

   -- Following line of code is added by ptendulk on 31-May-2001
   -- to start the trigger workflow process.
   -- Start the trigger if the schedule is using trigger and the trigger
   -- does not have any other schedule associated to it.

 /*  IF p_schedule_rec.trigger_id IS NOT NULL AND
      p_schedule_rec.trigger_id <> FND_API.G_MISS_NUM AND
      l_complete_rec.triggerable_flag = 'Y'
   THEN
      AMS_ScheduleRules_PVT.Start_Trigger_Process(p_schedule_id => p_schedule_rec.schedule_id,
                                                  p_trigger_id  => l_complete_rec.trigger_id) ;
   END IF;*/

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_Utility_PVT.Debug_Message('User Status Id : '||l_complete_rec.user_status_id) ;

   END IF;

   --insert_log_mesg('Anirban got value of asn_group_id in api Update_Camp_Schedule in amsvschb.pls as :'||p_schedule_rec.asn_group_id);

   AMS_ScheduleRules_PVT.Update_Schedule_Status(
         p_schedule_id      => p_schedule_rec.schedule_id,
         p_campaign_id      => l_complete_rec.campaign_id,
         p_user_status_id   => l_complete_rec.user_status_id,
         p_budget_amount    => l_complete_rec.budget_amount_tc,
         p_asn_group_id     => p_schedule_rec.asn_group_id  ); -- anchaudh added for leads bug.

   IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
      x_object_version_number := p_schedule_rec.object_version_number + 1 ;
   ELSE
      x_object_version_number := p_schedule_rec.object_version_number ;
   END IF;
   --
   -- End of API body.
   --


   -- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit )
   THEN
      COMMIT WORK;
   END IF;


   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
     AMS_Utility_Pvt.Error_Message('AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO UPDATE_Camp_Schedule_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_Camp_Schedule_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_Camp_Schedule_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
End Update_Camp_Schedule;

--===================================================================
-- NAME
--    Delete_Camp_Schedule
--
-- PURPOSE
--    Private api to Delete Campaign schedules.
--
-- NOTES
--    1. Schedule will be deleted from database if the user attempts
--       delete NEW schedules.
--    2. if the schedule is not new, any attempt to delete the schedule
--       will update the active flag to 'N'
--
-- HISTORY
--   22-Jan-2001     PTENDULK   Created
--===================================================================
PROCEDURE Delete_Camp_Schedule(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_schedule_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    )

IS
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Camp_Schedule';
   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_object_version_number     NUMBER;

   CURSOR c_camp_schedule IS
      SELECT campaign_id, schedule_id, status_code,use_parent_code_flag,source_code
      FROM ams_campaign_schedules_b
      WHERE schedule_id = p_schedule_id
      AND object_version_number = p_object_version_number ;

   l_schedule_id               NUMBER;
   l_status_code               VARCHAR2(30) ;
   l_campaign_id               NUMBER ;
   l_dummy                     NUMBER ;
   l_cascade_flag              VARCHAR2(1);
   l_source_code               VARCHAR2(30);

   CURSOR c_camp IS
   SELECT 1
   FROM   ams_campaign_schedules_b
   WHERE  campaign_id = l_campaign_id
   AND    active_flag = 'Y' ;


BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT DELETE_Camp_Schedule_PVT;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                        p_api_version_number,
                                        l_api_name,
                                        G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   OPEN c_camp_schedule;
   FETCH c_camp_schedule INTO l_campaign_id, l_schedule_id, l_status_code, l_cascade_flag, l_source_code;
   IF (c_camp_schedule%NOTFOUND) THEN
      CLOSE c_camp_schedule;
      AMS_Utility_PVT.Error_Message('AMS_API_RECORD_NOT_FOUND');
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_camp_schedule;

   --
   -- Api body
   --
   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message( 'Private API: Calling delete table handler');
   END IF;

   -- Delete schedule only if the status is new.
   -- Invoke table handler(AMS_CAMPAIGN_SCHEDULES_B_PKG.Delete_Row)
   IF l_status_code = 'NEW' THEN
       AMS_CAMPAIGN_SCHEDULES_B_PKG.Delete_Row(p_schedule_id  => p_schedule_id);
   ELSE
       UPDATE ams_campaign_schedules_b
       SET    object_version_number = object_version_number + 1 ,
              active_flag = 'N'
       WHERE  schedule_id = p_schedule_id
       AND    object_version_number = p_object_version_number  ;
   END IF ;


   OPEN  c_camp ;
   FETCH c_camp INTO l_dummy ;
   CLOSE c_camp ;

   -- Revoke the source code
   IF l_cascade_flag = 'N' THEN
      AMS_SourceCode_PVT.revoke_sourcecode(
         p_api_version        => 1.0,
         p_init_msg_list      => FND_API.g_false,
         p_commit             => FND_API.g_false,
         p_validation_level   => FND_API.g_valid_level_full,

         x_return_status      => x_return_status,
         x_msg_count          => x_msg_count,
         x_msg_data           => x_msg_data,

         p_sourcecode         => l_source_code
      );
   END IF ;

   --
   -- End of API body
   --

   -- Standard check for p_commit
   IF FND_API.to_Boolean(p_commit)
   THEN
      COMMIT WORK;
   END IF;


   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
        );
EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
     AMS_Utility_PVT.Error_Message('AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO DELETE_Camp_Schedule_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_Camp_Schedule_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_Camp_Schedule_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
End Delete_Camp_Schedule;


--===================================================================
-- NAME
--    Lock_Camp_Schedule
--
-- PURPOSE
--    Private api to Lock Campaign schedules.
--
-- NOTES
--
-- HISTORY
--   22-Jan-2001     PTENDULK   Created
--===================================================================
PROCEDURE Lock_Camp_Schedule(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_schedule_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
    )

IS
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_Camp_Schedule';
   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   L_FULL_NAME                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_SCHEDULE_ID                  NUMBER;

   CURSOR c_Camp_Schedule IS
      SELECT SCHEDULE_ID
      FROM AMS_CAMPAIGN_SCHEDULES_B
      WHERE SCHEDULE_ID = p_SCHEDULE_ID
      AND object_version_number = p_object_version
      FOR UPDATE NOWAIT;
BEGIN

   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                        p_api_version_number,
                                        l_api_name,
                                        G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;


   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;


------------------------ lock -------------------------

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_Utility_PVT.debug_message(l_full_name||': start');

   END IF;
   OPEN c_Camp_Schedule;
   FETCH c_Camp_Schedule INTO l_SCHEDULE_ID;

   IF (c_Camp_Schedule%NOTFOUND) THEN
      CLOSE c_Camp_Schedule;
      AMS_Utility_PVT.Error_Message('AMS_API_RECORD_NOT_FOUND');
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_Camp_Schedule;

   -------------------- finish --------------------------
   FND_MSG_PUB.count_and_get(
      p_encoded => FND_API.g_false,
      p_count   => x_msg_count,
      p_data    => x_msg_data);
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name ||': end');
   END IF;
EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
     AMS_Utility_PVT.Error_Message('AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO LOCK_Camp_Schedule_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_Camp_Schedule_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO LOCK_Camp_Schedule_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
End Lock_Camp_Schedule;

--===================================================================
-- NAME
--    Check_Schedule_Uk_Items
--
-- PURPOSE
--    Private api to check unique keys for Campaign schedules.
--
-- NOTES
--
-- HISTORY
--   22-Jan-2001     PTENDULK   Created
--===================================================================
PROCEDURE Check_Schedule_Uk_Items(
    p_schedule_rec               IN  schedule_rec_type,
    p_validation_mode            IN  VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status              OUT NOCOPY VARCHAR2)
IS
   l_valid_flag  VARCHAR2(1);

BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   IF p_validation_mode = JTF_PLSQL_API.g_create THEN
      l_valid_flag := AMS_Utility_PVT.check_uniqueness(
                                       'ams_campaign_schedules_b',
                                       'schedule_id = ' || p_schedule_rec.schedule_id
                                          );
      IF l_valid_flag = FND_API.g_false THEN
         AMS_Utility_PVT.Error_Message('AMS_CSCH_ID_DUPLICATE');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   -- added by soagrawa on 11-jan-2002
   IF p_validation_mode = JTF_PLSQL_API.g_create THEN
      l_valid_flag := AMS_Utility_PVT.check_uniqueness(
                                       'ams_campaign_schedules_b',
                                       'related_event_id = ' || p_schedule_rec.related_event_id
                                          );
      IF l_valid_flag = FND_API.g_false THEN
         AMS_Utility_PVT.Error_Message('AMS_EVO_DUPLICATE_ID');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

END Check_Schedule_Uk_Items;

--===================================================================
-- NAME
--    Check_Schedule_Req_Items
--
-- PURPOSE
--    Private api to check Required items for Campaign schedules.
--
-- NOTES
--
-- HISTORY
--   22-Jan-2001     PTENDULK   Created
--===================================================================
PROCEDURE Check_Schedule_Req_Items(
    p_schedule_rec    IN  schedule_rec_type,
    p_validation_mode IN  VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status   OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   IF p_validation_mode = JTF_PLSQL_API.g_create THEN

      IF p_schedule_rec.campaign_id = FND_API.g_miss_num OR p_schedule_rec.campaign_id IS NULL THEN
         AMS_Utility_Pvt.Error_Message(p_message_name => 'AMS_CSCH_NO_CAMP_ID') ;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_schedule_rec.user_status_id = FND_API.g_miss_num OR p_schedule_rec.user_status_id IS NULL THEN
         AMS_Utility_Pvt.Error_Message(p_message_name => 'AMS_CSCH_NO_STATUS_ID') ;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_schedule_rec.activity_type_code = FND_API.g_miss_char OR p_schedule_rec.activity_type_code IS NULL THEN
         AMS_Utility_Pvt.Error_Message(p_message_name => 'AMS_CSCH_NO_MEDIA_TYPE') ;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_schedule_rec.custom_setup_id = FND_API.g_miss_num OR p_schedule_rec.custom_setup_id IS NULL THEN
         AMS_Utility_Pvt.Error_Message(p_message_name => 'AMS_CSCH_NO_CUS_SETUP') ;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_schedule_rec.triggerable_flag  = FND_API.g_miss_char OR p_schedule_rec.triggerable_flag IS NULL THEN
         AMS_Utility_Pvt.Error_Message(p_message_name => 'AMS_CSCH_NO_TRIG_FLAG') ;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_schedule_rec.owner_user_id = FND_API.g_miss_num OR p_schedule_rec.owner_user_id IS NULL THEN
         AMS_Utility_Pvt.Error_Message(p_message_name => 'AMS_CSCH_NO_OWNER') ;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_schedule_rec.active_flag = FND_API.g_miss_char OR p_schedule_rec.active_flag IS NULL THEN
         AMS_Utility_Pvt.Error_Message(p_message_name => 'AMS_CSCH_NO_ACTIVE_FLAG') ;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_schedule_rec.country_id = FND_API.g_miss_num OR p_schedule_rec.country_id IS NULL THEN
         AMS_Utility_Pvt.Error_Message(p_message_name => 'AMS_CSCH_NO_COUNTRY') ;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_schedule_rec.schedule_name = FND_API.g_miss_char OR p_schedule_rec.schedule_name IS NULL THEN
         AMS_Utility_Pvt.Error_Message(p_message_name => 'AMS_CSCH_NO_NAME') ;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   ELSE
      IF p_schedule_rec.campaign_id IS NULL THEN
         AMS_Utility_Pvt.Error_Message(p_message_name => 'AMS_CSCH_NO_CAMP_ID') ;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_schedule_rec.user_status_id IS NULL THEN
         AMS_Utility_Pvt.Error_Message(p_message_name => 'AMS_CSCH_NO_STATUS_ID') ;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_schedule_rec.activity_type_code IS NULL THEN
         AMS_Utility_Pvt.Error_Message(p_message_name => 'AMS_CSCH_NO_MEDIA_TYPE') ;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_schedule_rec.custom_setup_id IS NULL THEN
         AMS_Utility_Pvt.Error_Message(p_message_name => 'AMS_CSCH_NO_CUS_SETUP') ;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_schedule_rec.triggerable_flag IS NULL THEN
         AMS_Utility_Pvt.Error_Message(p_message_name => 'AMS_CSCH_NO_TRIG_FLAG') ;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_schedule_rec.owner_user_id IS NULL THEN
         AMS_Utility_Pvt.Error_Message(p_message_name => 'AMS_CSCH_NO_OWNER') ;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_schedule_rec.active_flag IS NULL THEN
         AMS_Utility_Pvt.Error_Message(p_message_name => 'AMS_CSCH_NO_ACTIVE_FLAG') ;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_schedule_rec.country_id IS NULL THEN
         AMS_Utility_Pvt.Error_Message(p_message_name => 'AMS_CSCH_NO_COUNTRY') ;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_schedule_rec.schedule_name IS NULL THEN
         AMS_Utility_Pvt.Error_Message(p_message_name => 'AMS_CSCH_NO_NAME') ;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

END Check_Schedule_Req_Items;

--===================================================================
-- NAME
--    Check_Schedule_FK_Items
--
-- PURPOSE
--    Private api to check foreign key items for Campaign schedules.
--
-- NOTES
--
-- HISTORY
--   22-Jan-2001     PTENDULK   Created
--===================================================================
PROCEDURE Check_Schedule_FK_Items(
    p_schedule_rec  IN schedule_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
   l_table_name                  VARCHAR2(30);
   l_pk_name                     VARCHAR2(30);
   l_pk_value                    VARCHAR2(30);
   l_pk_data_type                NUMBER;
   l_additional_where_clause     VARCHAR2(4000);  -- Used by Check_FK_Exists.
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Check Campaign Id
   IF p_schedule_rec.campaign_id <> FND_API.g_miss_num THEN
      l_table_name              := 'ams_campaigns_all_b' ;
      l_pk_name                 := 'campaign_id' ;
      l_pk_value                := p_schedule_rec.campaign_id ;
      l_pk_data_type            := AMS_Utility_PVT.G_NUMBER ;
      l_additional_where_clause := NULL ;

      IF AMS_Utility_PVT.check_fk_exists(
                   p_table_name              => l_table_name,
                   p_pk_name                 => l_pk_name,
                   p_pk_value                => l_pk_value,
                   p_pk_data_type            => l_pk_data_type,
                   p_additional_where_clause => l_additional_where_clause
         ) = FND_API.g_false
      THEN
         AMS_Utility_Pvt.Error_Message(p_message_name => 'AMS_CAMP_BAD_CAMP_ID') ;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   -- Check User Status Id
   IF p_schedule_rec.user_status_id <> FND_API.g_miss_num THEN
      l_table_name              := 'ams_user_statuses_b' ;
      l_pk_name                 := 'user_status_id' ;
      l_pk_value                := p_schedule_rec.user_status_id ;
      l_pk_data_type            := AMS_Utility_PVT.G_NUMBER ;
      l_additional_where_clause := ' NVL(start_date_active,SYSDATE) <= SYSDATE ' ||
                                   ' AND NVL(end_date_active,SYSDATE) >= SYSDATE ';

      IF AMS_Utility_PVT.check_fk_exists(
                   p_table_name              => l_table_name,
                   p_pk_name                 => l_pk_name,
                   p_pk_value                => l_pk_value,
                   p_pk_data_type            => l_pk_data_type,
                   p_additional_where_clause => l_additional_where_clause
         ) = FND_API.g_false
      THEN
         AMS_Utility_Pvt.Error_Message(p_message_name => 'AMS_CSCH_BAD_USER_STATUS') ;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   -- Check Timezone Id
   IF p_schedule_rec.timezone_id <> FND_API.g_miss_num
   AND p_schedule_rec.timezone_id IS NOT NULL THEN
      l_table_name              := 'fnd_timezones_b';
      l_pk_name                 := 'upgrade_tz_id' ;
      l_pk_data_type            := AMS_Utility_PVT.G_NUMBER ;
      l_pk_value                := p_schedule_rec.timezone_id   ;
      l_additional_where_clause := null ;

      IF AMS_Utility_PVT.check_fk_exists(
                   p_table_name              => l_table_name,
                   p_pk_name                 => l_pk_name,
                   p_pk_value                => l_pk_value,
                   p_pk_data_type            => l_pk_data_type,
                   p_additional_where_clause => l_additional_where_clause
         ) = FND_API.g_false
      THEN
         AMS_Utility_Pvt.Error_Message(p_message_name => 'AMS_CAMP_BAD_CAMP_ID') ;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   -- Check Custom Setup Id
   IF p_schedule_rec.custom_setup_id <> FND_API.g_miss_num THEN
      l_table_name              := 'ams_custom_setups_b';
      l_pk_name                 := 'custom_setup_id' ;
      l_pk_data_type            := AMS_Utility_PVT.G_NUMBER ;
      l_pk_value                := p_schedule_rec.custom_setup_id   ;
      l_additional_where_clause := null ;

      IF AMS_Utility_PVT.check_fk_exists(
                   p_table_name              => l_table_name,
                   p_pk_name                 => l_pk_name,
                   p_pk_value                => l_pk_value,
                   p_pk_data_type            => l_pk_data_type,
                   p_additional_where_clause => l_additional_where_clause
         ) = FND_API.g_false
      THEN
         AMS_Utility_Pvt.Error_Message(p_message_name => 'AMS_CSCH_BAD_SETUP') ;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;


   -- Check Trigger Id
   IF p_schedule_rec.trigger_id <> FND_API.g_miss_num AND
      p_schedule_rec.trigger_id IS NOT NULL THEN
      l_table_name              := 'ams_triggers';
      l_pk_name                 := 'trigger_id' ;
      l_pk_data_type            := AMS_Utility_PVT.G_NUMBER ;
      l_pk_value                := p_schedule_rec.trigger_id   ;
      l_additional_where_clause := null ;

      IF AMS_Utility_PVT.check_fk_exists(
                   p_table_name              => l_table_name,
                   p_pk_name                 => l_pk_name,
                   p_pk_value                => l_pk_value,
                   p_pk_data_type            => l_pk_data_type,
                   p_additional_where_clause => l_additional_where_clause
         ) = FND_API.g_false
      THEN
         AMS_Utility_Pvt.Error_Message(p_message_name => 'AMS_CSCH_BAD_TRIGGER') ;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   -- Check Notify User Id
   IF p_schedule_rec.notify_user_id <> FND_API.g_miss_num AND
      p_schedule_rec.notify_user_id IS NOT NULL THEN
      l_table_name              := 'ams_jtf_rs_emp_v';
      l_pk_name                 := 'resource_id' ;
      l_pk_data_type            := AMS_Utility_PVT.G_NUMBER ;
      l_pk_value                := p_schedule_rec.notify_user_id   ;
      l_additional_where_clause := null ;

      IF AMS_Utility_PVT.check_fk_exists(
                   p_table_name              => l_table_name,
                   p_pk_name                 => l_pk_name,
                   p_pk_value                => l_pk_value,
                   p_pk_data_type            => l_pk_data_type,
                   p_additional_where_clause => l_additional_where_clause
         ) = FND_API.g_false
      THEN
         AMS_Utility_Pvt.Error_Message(p_message_name => 'AMS_CSCH_BAD_NOTIFY_TO') ;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   -- Check Approver User Id
   IF p_schedule_rec.approver_user_id <> FND_API.g_miss_num AND
      p_schedule_rec.approver_user_id IS NOT NULL THEN
      l_table_name              := 'ams_jtf_rs_emp_v';
      l_pk_name                 := 'resource_id' ;
      l_pk_data_type            := AMS_Utility_PVT.G_NUMBER ;
      l_pk_value                := p_schedule_rec.approver_user_id   ;
      l_additional_where_clause := null ;

      IF AMS_Utility_PVT.check_fk_exists(
                   p_table_name              => l_table_name,
                   p_pk_name                 => l_pk_name,
                   p_pk_value                => l_pk_value,
                   p_pk_data_type            => l_pk_data_type,
                   p_additional_where_clause => l_additional_where_clause
         ) = FND_API.g_false
      THEN
         AMS_Utility_Pvt.Error_Message(p_message_name => 'AMS_CSCH_BAD_APPROVER') ;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   -- Check Cover Letter
   -- This code modified by soagrawa on 23-apr-2002
   -- as we will no longer be using JTF cover letters
   -- This is for new schedule eblast, wherein a cover letter is an IBC content item

   /*
   IF p_schedule_rec.cover_letter_id <> FND_API.g_miss_num AND
      p_schedule_rec.cover_letter_id IS NOT NULL THEN
      l_table_name              := 'jtf_amv_items_b';
      l_pk_name                 := 'item_id' ;
      l_pk_data_type            := AMS_Utility_PVT.G_NUMBER ;
      l_pk_value                := p_schedule_rec.cover_letter_id   ;
      l_additional_where_clause := ' content_type_id = 20 ' ;

      IF AMS_Utility_PVT.check_fk_exists(
                   p_table_name              => l_table_name,
                   p_pk_name                 => l_pk_name,
                   p_pk_value                => l_pk_value,
                   p_pk_data_type            => l_pk_data_type,
                   p_additional_where_clause => l_additional_where_clause
         ) = FND_API.g_false
      THEN
         AMS_Utility_Pvt.Error_Message(p_message_name => 'AMS_CSCH_BAD_COVER_LETTER') ;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;
   */

   IF p_schedule_rec.cover_letter_id <> FND_API.g_miss_num AND
      p_schedule_rec.cover_letter_id IS NOT NULL THEN
      l_table_name              := 'ibc_content_items';
      l_pk_name                 := 'content_item_id' ;
      l_pk_data_type            := AMS_Utility_PVT.G_NUMBER ;
      l_pk_value                := p_schedule_rec.cover_letter_id   ;
      -- soagrawa modified on 03-nov-2003 for 11.5.10
      --l_additional_where_clause := ' content_type_code = ''AMF_TEMPLATE'' ' ;
      l_additional_where_clause := NULL;

      IF AMS_Utility_PVT.check_fk_exists(
                   p_table_name              => l_table_name,
                   p_pk_name                 => l_pk_name,
                   p_pk_value                => l_pk_value,
                   p_pk_data_type            => l_pk_data_type,
                   p_additional_where_clause => l_additional_where_clause
         ) = FND_API.g_false
      THEN
         AMS_Utility_Pvt.Error_Message(p_message_name => 'AMS_CSCH_BAD_COVER_LETTER') ;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;



   -- Check country
   IF p_schedule_rec.country_id <> FND_API.g_miss_num AND
      p_schedule_rec.country_id IS NOT NULL THEN
      l_table_name              := 'jtf_loc_hierarchies_b';
      l_pk_name                 := 'location_hierarchy_id' ;
      l_pk_data_type            := AMS_Utility_PVT.G_NUMBER ;
      l_pk_value                := p_schedule_rec.country_id   ;
      l_additional_where_clause := null ;

      IF AMS_Utility_PVT.check_fk_exists(
                   p_table_name              => l_table_name,
                   p_pk_name                 => l_pk_name,
                   p_pk_value                => l_pk_value,
                   p_pk_data_type            => l_pk_data_type,
                   p_additional_where_clause => l_additional_where_clause
         ) = FND_API.g_false
      THEN
         AMS_Utility_Pvt.Error_Message(p_message_name => 'AMS_CSCH_BAD_COUNTRY') ;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   -- Check Language Code
   IF p_schedule_rec.language_code <> FND_API.g_miss_char AND
      p_schedule_rec.language_code IS NOT NULL THEN
      l_table_name              := 'fnd_languages';
      l_pk_name                 := 'language_code' ;
      l_pk_data_type            := AMS_Utility_PVT.G_VARCHAR2 ;
      l_pk_value                := p_schedule_rec.language_code   ;
      l_additional_where_clause := null ;

      IF AMS_Utility_PVT.check_fk_exists(
                   p_table_name              => l_table_name,
                   p_pk_name                 => l_pk_name,
                   p_pk_value                => l_pk_value,
                   p_pk_data_type            => l_pk_data_type,
                   p_additional_where_clause => l_additional_where_clause
         ) = FND_API.g_false
      THEN
         AMS_Utility_Pvt.Error_Message(p_message_name => 'AMS_CAMP_BAD_LANG') ;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   -- Check Task Id
   IF p_schedule_rec.task_id <> FND_API.g_miss_num  AND
      p_schedule_rec.task_id  IS NOT NULL THEN
      l_table_name              := 'jtf_tasks_b';
      l_pk_name                 := 'task_id' ;
      l_pk_data_type            := AMS_Utility_PVT.G_NUMBER ;
      l_pk_value                := p_schedule_rec.task_id   ;
      l_additional_where_clause := null ;

      IF AMS_Utility_PVT.check_fk_exists(
                   p_table_name              => l_table_name,
                   p_pk_name                 => l_pk_name,
                   p_pk_value                => l_pk_value,
                   p_pk_data_type            => l_pk_data_type,
                   p_additional_where_clause => l_additional_where_clause
         ) = FND_API.g_false
      THEN
         AMS_Utility_Pvt.Error_Message(p_message_name => 'AMS_CAMP_BAD_TASK') ;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;


END Check_Schedule_FK_Items;

--===================================================================
-- NAME
--    Check_Schedule_Lookup_Items
--
-- PURPOSE
--    Private api to check lookup items for Campaign schedules.
--
-- NOTES
--
-- HISTORY
--   22-Jan-2001     PTENDULK   Created
--===================================================================
PROCEDURE Check_Schedule_Lookup_Items(
    p_schedule_rec IN schedule_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Check status code
   IF p_schedule_rec.status_code <> FND_API.G_MISS_CHAR
   THEN
      IF AMS_Utility_PVT.Check_Lookup_Exists
        ( p_lookup_table_name   => 'AMS_LOOKUPS'
         ,p_lookup_type                => 'AMS_CAMPAIGN_SCHEDULE_STATUS'
         ,p_lookup_code         => p_schedule_rec.status_code ) = FND_API.G_FALSE
      THEN
         AMS_Utility_Pvt.Error_Message(p_message_name => 'AMS_CSCH_BAD_STATUS') ;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;

      END IF;
   END IF;

   -- Check Activity type code
   IF p_schedule_rec.activity_type_code <> FND_API.G_MISS_CHAR
   THEN
      IF AMS_Utility_PVT.Check_Lookup_Exists
        ( p_lookup_table_name   => 'AMS_LOOKUPS'
         ,p_lookup_type                => 'AMS_MEDIA_TYPE'
         ,p_lookup_code         => p_schedule_rec.activity_type_code ) = FND_API.G_FALSE
      THEN
         AMS_Utility_Pvt.Error_Message(p_message_name => 'AMS_CSCH_BAD_ACTIVITY_TYPE') ;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   -- Check Objective
   IF p_schedule_rec.objective_code <> FND_API.G_MISS_CHAR
   THEN
      IF AMS_Utility_PVT.Check_Lookup_Exists
        ( p_lookup_table_name   => 'AMS_LOOKUPS'
         ,p_lookup_type         => 'AMS_SCHEDULE_OBJECTIVE'
         ,p_lookup_code         => p_schedule_rec.objective_code ) = FND_API.G_FALSE
      THEN
         AMS_Utility_Pvt.Error_Message(p_message_name => 'AMS_CSCH_BAD_OBJECTIVE') ;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   -- Check Priority
   IF p_schedule_rec.priority <> FND_API.G_MISS_CHAR
   THEN
      IF AMS_Utility_PVT.Check_Lookup_Exists
        ( p_lookup_table_name   => 'AMS_LOOKUPS'
         ,p_lookup_type                => 'AMS_PRIORITY'
         ,p_lookup_code         => p_schedule_rec.priority ) = FND_API.G_FALSE
      THEN
         AMS_Utility_Pvt.Error_Message(p_message_name => 'AMS_CSCH_BAD_PRIORITY') ;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

END Check_Schedule_Lookup_Items;

--===================================================================
-- NAME
--    Check_Schedule_Flag_Items
--
-- PURPOSE
--    Private api to check Flag items for Campaign schedules.
--
-- NOTES
--
-- HISTORY
--   22-Jan-2001     PTENDULK   Created
--===================================================================
PROCEDURE Check_Schedule_Flag_Items(
    p_schedule_rec   IN   schedule_rec_type,
    x_return_status  OUT NOCOPY  VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Check Use parent code flag
   IF p_schedule_rec.use_parent_code_flag <> FND_API.g_miss_char
      AND p_schedule_rec.use_parent_code_flag IS NOT NULL
   THEN
      IF AMS_Utility_PVT.is_Y_or_N(p_schedule_rec.use_parent_code_flag) = FND_API.g_false
      THEN
         AMS_Utility_PVT.Error_Message('AMS_CAMP_BAD_PARENT_FLAG');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   -- Check Use parent code flag
   IF p_schedule_rec.triggerable_flag <> FND_API.g_miss_char
      AND p_schedule_rec.triggerable_flag IS NOT NULL
   THEN
      IF AMS_Utility_PVT.is_Y_or_N(p_schedule_rec.triggerable_flag) = FND_API.g_false
      THEN
         AMS_Utility_PVT.Error_Message('AMS_CSCH_NO_TRIG_FLAG');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   -- Check Active flag
   IF p_schedule_rec.active_flag <> FND_API.g_miss_char
      AND p_schedule_rec.active_flag IS NOT NULL
   THEN
      IF AMS_Utility_PVT.is_Y_or_N(p_schedule_rec.active_flag) = FND_API.g_false
      THEN
         AMS_Utility_PVT.Error_Message('AMS_CSCH_NO_ACTIVE_FLAG');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   -- Check accounts_closed_flag
   IF p_schedule_rec.accounts_closed_flag <> FND_API.g_miss_char
      AND p_schedule_rec.accounts_closed_flag IS NOT NULL
   THEN
      IF AMS_Utility_PVT.is_Y_or_N(p_schedule_rec.accounts_closed_flag) = FND_API.g_false
      THEN
         AMS_Utility_PVT.Error_Message('AMS_CSCH_ACC_CLOSED_FLAG');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;


END Check_Schedule_Flag_Items ;

--===================================================================
-- NAME
--    Check_schedule_Items
--
-- PURPOSE
--    Private api to items for Campaign schedules.
--
-- NOTES
--
-- HISTORY
--   22-Jan-2001     PTENDULK   Created
--===================================================================
PROCEDURE Check_schedule_Items (
    P_schedule_rec     IN    schedule_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    )
IS
BEGIN

   -- Check Items Uniqueness API calls

   check_schedule_uk_items(
      p_schedule_rec => p_schedule_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- Check Items Required/NOT NULL API calls

   check_schedule_req_items(
      p_schedule_rec => p_schedule_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   -- Check Items Foreign Keys API calls

   check_schedule_FK_items(
      p_schedule_rec => p_schedule_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- Check Items Lookups
   check_schedule_Lookup_items(
      p_schedule_rec => p_schedule_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- Check Items Flags
   Check_Schedule_Flag_Items(
      p_schedule_rec => p_schedule_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

END Check_schedule_Items;

--===================================================================
-- NAME
--    Complete_schedule_Rec
--
-- PURPOSE
--    Private api to complete rec for Campaign schedules.
--
-- NOTES
--
-- HISTORY
--   22-Jan-2001     PTENDULK   Created
--   27-jun-2003     ANCHAUDH  added the extra columns in the record for triggers changes.
--===================================================================
PROCEDURE Complete_schedule_Rec (
    P_schedule_rec     IN    schedule_rec_type,
     x_complete_rec        OUT NOCOPY    schedule_rec_type
    )
IS
   CURSOR c_schedule IS
   SELECT *
   FROM   ams_campaign_schedules_vl
   WHERE  schedule_id = p_schedule_rec.schedule_id;

   l_schedule_rec  c_schedule%ROWTYPE;

BEGIN

   x_complete_rec := p_schedule_rec;

   OPEN c_schedule;
   FETCH c_schedule INTO l_schedule_rec;
   IF c_schedule%NOTFOUND THEN
      CLOSE c_schedule;
      AMS_Utility_PVT.Error_Message('AMS_API_RECORD_NOT_FOUND');
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_schedule;

   IF p_schedule_rec.campaign_id = FND_API.g_miss_num THEN
      x_complete_rec.campaign_id := l_schedule_rec.campaign_id ;
   END IF;

   IF p_schedule_rec.user_status_id = FND_API.g_miss_num THEN
      x_complete_rec.user_status_id := l_schedule_rec.user_status_id;
   END IF;

   -- status_code will go with user_status_id
   x_complete_rec.status_code := AMS_Utility_PVT.get_system_status_code(
         x_complete_rec.user_status_id
   );

   IF p_schedule_rec.status_date = FND_API.g_miss_date
      OR p_schedule_rec.status_date IS NULL
   THEN
      IF p_schedule_rec.user_status_id = l_schedule_rec.user_status_id THEN
      -- no status change, set it to be the original value
         x_complete_rec.status_date := l_schedule_rec.status_date;
      ELSE
      -- status changed, set it to be SYSDATE
         x_complete_rec.status_date := SYSDATE;
      END IF;
   END IF;

   IF p_schedule_rec.source_code = FND_API.g_miss_char THEN
      x_complete_rec.source_code := l_schedule_rec.source_code;
   END IF;

   IF p_schedule_rec.use_parent_code_flag = FND_API.g_miss_char THEN
      x_complete_rec.use_parent_code_flag := l_schedule_rec.use_parent_code_flag;
   END IF;

   IF p_schedule_rec.start_date_time = FND_API.g_miss_date THEN
      x_complete_rec.start_date_time := l_schedule_rec.start_date_time;
   END IF;

   IF p_schedule_rec.end_date_time = FND_API.g_miss_date THEN
      x_complete_rec.end_date_time := l_schedule_rec.end_date_time;
   END IF;

   IF p_schedule_rec.timezone_id = FND_API.g_miss_num THEN
      x_complete_rec.timezone_id := l_schedule_rec.timezone_id;
   END IF;

   IF p_schedule_rec.activity_type_code = FND_API.g_miss_char THEN
      x_complete_rec.activity_type_code := l_schedule_rec.activity_type_code;
   END IF;

   IF p_schedule_rec.activity_id = FND_API.g_miss_num THEN
      x_complete_rec.activity_id := l_schedule_rec.activity_id;
   END IF;

   IF p_schedule_rec.arc_marketing_medium_from = FND_API.g_miss_char THEN
      x_complete_rec.arc_marketing_medium_from := l_schedule_rec.arc_marketing_medium_from;
   END IF;

   IF p_schedule_rec.marketing_medium_id = FND_API.g_miss_num THEN
      x_complete_rec.marketing_medium_id := l_schedule_rec.marketing_medium_id;
   END IF;

   IF p_schedule_rec.custom_setup_id = FND_API.g_miss_num THEN
      x_complete_rec.custom_setup_id := l_schedule_rec.custom_setup_id;
   END IF;

   IF p_schedule_rec.triggerable_flag = FND_API.g_miss_char THEN
      x_complete_rec.triggerable_flag := l_schedule_rec.triggerable_flag;
   END IF;

   IF p_schedule_rec.trigger_id = FND_API.g_miss_num THEN
      x_complete_rec.trigger_id := l_schedule_rec.trigger_id;
   END IF;

   IF p_schedule_rec.notify_user_id = FND_API.g_miss_num THEN
      x_complete_rec.notify_user_id := l_schedule_rec.notify_user_id;
   END IF;

   IF p_schedule_rec.approver_user_id = FND_API.g_miss_num THEN
      x_complete_rec.approver_user_id := l_schedule_rec.approver_user_id;
   END IF;

   IF p_schedule_rec.owner_user_id = FND_API.g_miss_num THEN
      x_complete_rec.owner_user_id := l_schedule_rec.owner_user_id;
   END IF;

   IF p_schedule_rec.active_flag = FND_API.g_miss_char THEN
      x_complete_rec.active_flag := l_schedule_rec.active_flag;
   END IF;

   IF p_schedule_rec.cover_letter_id = FND_API.g_miss_num THEN
      x_complete_rec.cover_letter_id := l_schedule_rec.cover_letter_id;
   END IF;

   IF p_schedule_rec.reply_to_mail = FND_API.g_miss_char THEN
      x_complete_rec.reply_to_mail := l_schedule_rec.reply_to_mail;
   END IF;

   IF p_schedule_rec.mail_sender_name = FND_API.g_miss_char THEN
      x_complete_rec.mail_sender_name := l_schedule_rec.mail_sender_name;
   END IF;

   IF p_schedule_rec.mail_subject = FND_API.g_miss_char THEN
      x_complete_rec.mail_subject := l_schedule_rec.mail_subject;
   END IF;

   IF p_schedule_rec.from_fax_no = FND_API.g_miss_char THEN
      x_complete_rec.from_fax_no := l_schedule_rec.from_fax_no;
   END IF;

   IF p_schedule_rec.accounts_closed_flag = FND_API.g_miss_char THEN
      x_complete_rec.accounts_closed_flag := l_schedule_rec.accounts_closed_flag;
   END IF;

   IF p_schedule_rec.org_id = FND_API.g_miss_num THEN
      x_complete_rec.org_id := l_schedule_rec.org_id;
   END IF;

   IF p_schedule_rec.objective_code = FND_API.g_miss_char THEN
      x_complete_rec.objective_code := l_schedule_rec.objective_code;
   END IF;

   IF p_schedule_rec.country_id = FND_API.g_miss_num THEN
      x_complete_rec.country_id := l_schedule_rec.country_id;
   END IF;

   IF p_schedule_rec.campaign_calendar = FND_API.g_miss_char THEN
      x_complete_rec.campaign_calendar:= l_schedule_rec.campaign_calendar ;
   END IF;

   IF p_schedule_rec.start_period_name = FND_API.g_miss_char THEN
      x_complete_rec.start_period_name := l_schedule_rec.start_period_name;
   END IF;

   IF p_schedule_rec.end_period_name = FND_API.g_miss_char THEN
      x_complete_rec.end_period_name := l_schedule_rec.end_period_name;
   END IF;

   IF p_schedule_rec.priority = FND_API.g_miss_char THEN
      x_complete_rec.priority := l_schedule_rec.priority;
   END IF;

   IF p_schedule_rec.workflow_item_key = FND_API.g_miss_char THEN
      x_complete_rec.workflow_item_key := l_schedule_rec.workflow_item_key;
   END IF;

   IF p_schedule_rec.transaction_currency_code = FND_API.g_miss_char THEN
      x_complete_rec.transaction_currency_code := l_schedule_rec.transaction_currency_code ;
   END IF;

   IF p_schedule_rec.functional_currency_code = FND_API.g_miss_char THEN
      x_complete_rec.functional_currency_code := l_schedule_rec.functional_currency_code ;
   END IF;

   IF p_schedule_rec.budget_amount_tc = FND_API.g_miss_num THEN
      x_complete_rec.budget_amount_tc := l_schedule_rec.budget_amount_tc;
   END IF;

   IF p_schedule_rec.budget_amount_fc = FND_API.g_miss_num THEN
      x_complete_rec.budget_amount_fc := l_schedule_rec.budget_amount_fc;
   END IF;

   IF p_schedule_rec.language_code = FND_API.g_miss_char THEN
      x_complete_rec.language_code := l_schedule_rec.language_code ;
   END IF;

   IF p_schedule_rec.task_id = FND_API.g_miss_num THEN
      x_complete_rec.task_id := l_schedule_rec.task_id;
   END IF;

   IF p_schedule_rec.related_event_from = FND_API.g_miss_char THEN
      x_complete_rec.related_event_from := l_schedule_rec.related_event_from ;
   END IF;

   IF p_schedule_rec.related_event_id = FND_API.g_miss_num THEN
      x_complete_rec.related_event_id := l_schedule_rec.related_event_id;
   END IF;


   IF p_schedule_rec.attribute_category = FND_API.g_miss_char THEN
      x_complete_rec.attribute_category := l_schedule_rec.attribute_category;
   END IF;

   IF p_schedule_rec.attribute1 = FND_API.g_miss_char THEN
      x_complete_rec.attribute1 := l_schedule_rec.attribute1;
   END IF;

   IF p_schedule_rec.attribute2 = FND_API.g_miss_char THEN
      x_complete_rec.attribute2 := l_schedule_rec.attribute2;
   END IF;

   IF p_schedule_rec.attribute3 = FND_API.g_miss_char THEN
      x_complete_rec.attribute3 := l_schedule_rec.attribute3;
   END IF;

   IF p_schedule_rec.attribute4 = FND_API.g_miss_char THEN
      x_complete_rec.attribute4 := l_schedule_rec.attribute4;
   END IF;

   IF p_schedule_rec.attribute5 = FND_API.g_miss_char THEN
      x_complete_rec.attribute5 := l_schedule_rec.attribute5;
   END IF;

   IF p_schedule_rec.attribute6 = FND_API.g_miss_char THEN
      x_complete_rec.attribute6 := l_schedule_rec.attribute6;
   END IF;

   IF p_schedule_rec.attribute7 = FND_API.g_miss_char THEN
      x_complete_rec.attribute7 := l_schedule_rec.attribute7;
   END IF;

   IF p_schedule_rec.attribute8 = FND_API.g_miss_char THEN
      x_complete_rec.attribute8 := l_schedule_rec.attribute8;
   END IF;

   IF p_schedule_rec.attribute9 = FND_API.g_miss_char THEN
      x_complete_rec.attribute9 := l_schedule_rec.attribute9;
   END IF;

   IF p_schedule_rec.attribute10 = FND_API.g_miss_char THEN
      x_complete_rec.attribute10 := l_schedule_rec.attribute10;
   END IF;

   IF p_schedule_rec.attribute11 = FND_API.g_miss_char THEN
      x_complete_rec.attribute11 := l_schedule_rec.attribute11;
   END IF;

   IF p_schedule_rec.attribute12 = FND_API.g_miss_char THEN
      x_complete_rec.attribute12 := l_schedule_rec.attribute12;
   END IF;

   IF p_schedule_rec.attribute13 = FND_API.g_miss_char THEN
      x_complete_rec.attribute13 := l_schedule_rec.attribute13;
   END IF;

   IF p_schedule_rec.attribute14 = FND_API.g_miss_char THEN
      x_complete_rec.attribute14 := l_schedule_rec.attribute14;
   END IF;

   IF p_schedule_rec.attribute15 = FND_API.g_miss_char THEN
      x_complete_rec.attribute15 := l_schedule_rec.attribute15;
   END IF;

   IF p_schedule_rec.attribute_category = FND_API.g_miss_char THEN
      x_complete_rec.attribute_category := l_schedule_rec.attribute_category;
   END IF;

   IF p_schedule_rec.activity_attribute1 = FND_API.g_miss_char THEN
      x_complete_rec.activity_attribute1 := l_schedule_rec.activity_attribute1;
   END IF;

   IF p_schedule_rec.activity_attribute2 = FND_API.g_miss_char THEN
      x_complete_rec.activity_attribute2 := l_schedule_rec.activity_attribute2;
   END IF;

   IF p_schedule_rec.activity_attribute3 = FND_API.g_miss_char THEN
      x_complete_rec.activity_attribute3 := l_schedule_rec.activity_attribute3;
   END IF;

   IF p_schedule_rec.activity_attribute4 = FND_API.g_miss_char THEN
      x_complete_rec.activity_attribute4 := l_schedule_rec.activity_attribute4;
   END IF;

   IF p_schedule_rec.activity_attribute5 = FND_API.g_miss_char THEN
      x_complete_rec.activity_attribute5 := l_schedule_rec.activity_attribute5;
   END IF;

   IF p_schedule_rec.activity_attribute6 = FND_API.g_miss_char THEN
      x_complete_rec.activity_attribute6 := l_schedule_rec.activity_attribute6;
   END IF;

   IF p_schedule_rec.activity_attribute7 = FND_API.g_miss_char THEN
      x_complete_rec.activity_attribute7 := l_schedule_rec.activity_attribute7;
   END IF;

   IF p_schedule_rec.activity_attribute8 = FND_API.g_miss_char THEN
      x_complete_rec.activity_attribute8 := l_schedule_rec.activity_attribute8;
   END IF;

   IF p_schedule_rec.activity_attribute9 = FND_API.g_miss_char THEN
      x_complete_rec.activity_attribute9 := l_schedule_rec.activity_attribute9;
   END IF;

   IF p_schedule_rec.activity_attribute10 = FND_API.g_miss_char THEN
      x_complete_rec.activity_attribute10 := l_schedule_rec.activity_attribute10;
   END IF;

   IF p_schedule_rec.activity_attribute11 = FND_API.g_miss_char THEN
      x_complete_rec.activity_attribute11 := l_schedule_rec.activity_attribute11;
   END IF;

   IF p_schedule_rec.activity_attribute12 = FND_API.g_miss_char THEN
      x_complete_rec.activity_attribute12 := l_schedule_rec.activity_attribute12;
   END IF;

   IF p_schedule_rec.activity_attribute13 = FND_API.g_miss_char THEN
      x_complete_rec.activity_attribute13 := l_schedule_rec.activity_attribute13;
   END IF;

   IF p_schedule_rec.activity_attribute14 = FND_API.g_miss_char THEN
      x_complete_rec.activity_attribute14 := l_schedule_rec.activity_attribute14;
   END IF;

   IF p_schedule_rec.activity_attribute15 = FND_API.g_miss_char THEN
      x_complete_rec.activity_attribute15 := l_schedule_rec.activity_attribute15;
   END IF;

   IF p_schedule_rec.schedule_name = FND_API.g_miss_char THEN
      x_complete_rec.schedule_name := l_schedule_rec.schedule_name;
   END IF;

   IF p_schedule_rec.description = FND_API.g_miss_char THEN
      x_complete_rec.description := l_schedule_rec.description;
   END IF;

   -- removed by soagrawa on 24-sep-2001
   -- IF p_schedule_rec.security_group_id = FND_API.g_miss_num THEN
      -- x_complete_rec.security_group_id := l_schedule_rec.security_group_id;
   -- END IF;

--following are added by anchaudh on 27-jun-2003
   IF p_schedule_rec.trig_repeat_flag = FND_API.g_miss_char THEN
      x_complete_rec.trig_repeat_flag  := l_schedule_rec.trig_repeat_flag;
   END IF;

  IF p_schedule_rec.tgrp_exclude_prev_flag = FND_API.g_miss_char THEN
      x_complete_rec.tgrp_exclude_prev_flag := l_schedule_rec.tgrp_exclude_prev_flag;
   END IF;

  IF p_schedule_rec.orig_csch_id = FND_API.g_miss_num THEN
       x_complete_rec.orig_csch_id  := l_schedule_rec.orig_csch_id;
   END IF;

   IF p_schedule_rec.cover_letter_version = FND_API.g_miss_num THEN
       x_complete_rec.cover_letter_version  := l_schedule_rec.cover_letter_version;
   END IF;

   IF p_schedule_rec.usage = FND_API.g_miss_char THEN
       x_complete_rec.usage  := l_schedule_rec.usage;
   END IF;

   IF p_schedule_rec.purpose = FND_API.g_miss_char THEN
       x_complete_rec.purpose  := l_schedule_rec.purpose;
   END IF;

   IF p_schedule_rec.last_activation_date = FND_API.g_miss_date THEN
      x_complete_rec.last_activation_date := l_schedule_rec.last_activation_date;
   END IF;

   IF p_schedule_rec.sales_methodology_id = FND_API.g_miss_num THEN
      x_complete_rec.sales_methodology_id  := l_schedule_rec.sales_methodology_id;
   END IF;

   IF p_schedule_rec.printer_address = FND_API.g_miss_char THEN
       x_complete_rec.printer_address  := l_schedule_rec.printer_address;
   END IF;

   IF p_schedule_rec.notify_on_activation_flag = FND_API.g_miss_char THEN
       x_complete_rec.notify_on_activation_flag  := l_schedule_rec.notify_on_activation_flag;
   END IF;

   IF p_schedule_rec.sender_display_name = FND_API.g_miss_char THEN
      x_complete_rec.sender_display_name  := l_schedule_rec.sender_display_name;
   END IF;

   IF p_schedule_rec.delivery_mode = FND_API.g_miss_char THEN
      x_complete_rec.delivery_mode  := l_schedule_rec.delivery_mode;
   END IF;

END Complete_schedule_Rec;

--===================================================================
-- NAME
--    Validate_camp_schedule
--
-- PURPOSE
--    Validate schedules
--
-- NOTES
--
-- HISTORY
--   22-Jan-2001     PTENDULK   Created
--===================================================================
PROCEDURE Validate_camp_schedule(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_schedule_rec               IN   schedule_rec_type,
    p_validation_mode            IN   VARCHAR2,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
IS
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Validate_Camp_Schedule';
   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_object_version_number     NUMBER;
   l_schedule_rec  AMS_Camp_Schedule_PVT.schedule_rec_type := p_schedule_rec ;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT VALIDATE_Camp_Schedule_;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                        p_api_version_number,
                                        l_api_name,
                                        G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
      Check_schedule_Items(
                 p_schedule_rec      => p_schedule_rec,
                 p_validation_mode   => JTF_PLSQL_API.g_update,
                 x_return_status     => x_return_status
              );

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END IF;

   IF p_validation_mode = JTF_PLSQL_API.g_update THEN
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_Utility_PVT.debug_message('After Item validation');
      END IF;
      Complete_schedule_Rec(
            p_schedule_rec        => p_schedule_rec,
            x_complete_rec        => l_schedule_rec
         );
   END IF ;

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_Utility_PVT.debug_message('Rec Level Validation');

   END IF;
   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_record THEN
         Validate_schedule_Rec(
           p_api_version_number     => 1.0,
           p_init_msg_list          => FND_API.G_FALSE,
           x_return_status          => x_return_status,
           x_msg_count              => x_msg_count,
           x_msg_data               => x_msg_data,
           p_schedule_rec           => l_schedule_rec);

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END IF;

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_Utility_PVT.debug_message('Inter Entity Level Validation');

   END IF;
   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_record THEN
      Check_Schedule_Inter_Entity(
         p_schedule_rec    =>  p_schedule_rec,
         p_complete_rec    =>  l_schedule_rec,
         p_validation_mode =>  p_validation_mode,
         x_return_status   =>  x_return_status
      ) ;
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END IF ;

   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
        AMS_Utility_PVT.Error_Message('AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO VALIDATE_Camp_Schedule_;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_Camp_Schedule_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_Camp_Schedule_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
End Validate_Camp_Schedule;

--===================================================================
-- NAME
--    Validate_schedule_rec
--
-- PURPOSE
--    Record level validations for schedules.
--
-- NOTES
--
-- HISTORY
--   22-Jan-2001     PTENDULK   Created
--   08-Jul-2001     ptendulk   Added validation for start_Date and
--                              end date Refer bug #1856924
--   03-dec-2001     soagrawa   Added check for event type schedules:
--                              end date should be mandatory
--                              bug# 2131521
--   23-mar-2004     soagrawa   Modified validation for triggerable schedules
--                              keeping repeating schedules in consideration
--===================================================================
PROCEDURE Validate_schedule_rec(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_schedule_rec               IN    schedule_rec_type
    )
IS
BEGIN
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Private API: Validate_Schedule_Rec');
   END IF;

   -- budget amount must come with budget currency
   IF p_schedule_rec.transaction_currency_code IS NULL
      AND p_schedule_rec.budget_amount_tc IS NOT NULL
   THEN
      AMS_Utility_PVT.Error_Message('AMS_CAMP_BUDGET_NO_CURRENCY');
      x_return_status := FND_API.g_ret_sts_error;
   END IF;

   IF p_schedule_rec.end_date_time IS NOT NULL THEN
      IF p_schedule_rec.start_date_time > p_schedule_rec.end_date_time THEN
         AMS_Utility_PVT.Error_Message('AMS_CAMP_START_AFTER_END');
         x_return_status := FND_API.g_ret_sts_error;
      END IF ;
   END IF ;

   -- added by soagrawa on 03-dec-2001 : end date mandatory for schedules of type events
   -- bug# 2131521
   IF p_schedule_rec.activity_type_code = 'EVENTS' THEN
      IF p_schedule_rec.end_date_time IS NULL THEN
         AMS_Utility_PVT.Error_Message('AMS_CSCH_END_DATE_MAND');
         x_return_status := FND_API.G_RET_STS_ERROR;
         RETURN;
      END IF;
   END IF ;
   --end soagrawa 03-dec-2001

--added by anchaudh on 27-jun-2003 : triggers related validations
-- following validations modified by soagrawa on 22-nov-2003 for 11.5.10 repeating schedules' addition

  IF (p_schedule_rec.triggerable_flag = 'Y' AND p_schedule_rec.trigger_id IS NULL) THEN
       AMS_Utility_PVT.Error_Message('AMS_SELECT_TRIGGER');
       x_return_status := FND_API.G_RET_STS_ERROR;
       RETURN;
      END IF;

/*  IF (p_schedule_rec.triggerable_flag = 'N' AND p_schedule_rec.tgrp_exclude_prev_flag = 'Y') THEN
       AMS_Utility_PVT.Error_Message('AMS_DONOT_TRIG_TGRP');
       x_return_status := FND_API.G_RET_STS_ERROR;
       RETURN;
     END IF;
*/

 -- soagrawa added clause  p_schedule_rec.triggerable_flag = 'Y'
 -- on 23-mar-2004
 IF (p_schedule_rec.trig_repeat_flag = 'N' AND p_schedule_rec.triggerable_flag = 'Y' AND p_schedule_rec.tgrp_exclude_prev_flag = 'Y') THEN
      AMS_Utility_PVT.Error_Message('AMS_TRIG_EXCLUDE_TGRP');
       x_return_status := FND_API.G_RET_STS_ERROR;
       RETURN;
     END IF;

/*
 IF (p_schedule_rec.triggerable_flag = 'N' AND p_schedule_rec.trig_repeat_flag = 'Y') THEN
    AMS_Utility_PVT.Error_Message('AMS_DONOT_TRIG_REPEAT');
       x_return_status := FND_API.G_RET_STS_ERROR;
       RETURN;
     END IF;
*/


   --end : triggers related validations

   -- Check the Schedule Uniqueness

   -- Standard call to get message count and if count is 1, get message info.
--   FND_MSG_PUB.Count_And_Get
--        (p_count          =>   x_msg_count,
--         p_data           =>   x_msg_data
--      );
END Validate_schedule_Rec;

--===================================================================
-- NAME
--    Check_Schedule_Inter_Entity
--
-- PURPOSE
--    Inter Entitiy validations for schedules.
--
-- NOTES
--
-- HISTORY
--   22-Jan-2001     PTENDULK   Created
--   24-May-2001     ptendulk   Added check to validate that event schedule is
--                              can not be created for event promotions.
--   01-Aug-2001     ptendulk   1.Added two more cursors for duplicate check
--                              2.Replaced ams_utility_pvt.check_uniqueness check
--                              with manual check. Refer bug #1913448
--===================================================================
PROCEDURE Check_Schedule_Inter_Entity( p_schedule_rec    IN  schedule_rec_type,
                                       p_complete_rec    IN  schedule_rec_type,
                                       p_validation_mode IN  VARCHAR2,
                                       x_return_status   OUT NOCOPY VARCHAR2
)
IS
   l_return_status  VARCHAR2(1);

   l_table_name     VARCHAR2(30);
   l_where_clause   VARCHAR2(4000);
   l_valid_flag     VARCHAR2(1);
   l_pk_name        VARCHAR2(100);
   l_pk_value       NUMBER;
   l_pk_data_type   VARCHAR2(30);

   CURSOR c_camp_status IS
   SELECT   status_code,rollup_type
   FROM     ams_campaigns_all_b
   WHERE    campaign_id = p_schedule_rec.campaign_id ;
   l_status_code  VARCHAR2(30);
   l_rollup_type  VARCHAR2(30);

   CURSOR c_sch_name IS
   SELECT 1 from dual
   WHERE EXISTS (SELECT *
                 FROM  ams_campaign_schedules_vl
                 WHERE campaign_id = p_complete_rec.campaign_id
                 AND   UPPER(schedule_name) = UPPER(p_complete_rec.schedule_name)) ;

   CURSOR c_sch_name_updt IS
   SELECT 1 from dual
   WHERE EXISTS (SELECT *
                 FROM  ams_campaign_schedules_vl
                 WHERE campaign_id = p_complete_rec.campaign_id
                 AND   UPPER(schedule_name) = UPPER(p_complete_rec.schedule_name)
                 AND   schedule_id <> p_complete_rec.schedule_id ) ;
   l_dummy  NUMBER ;

BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   ------------------- check media type ----------------------
--   IF p_camp_rec.parent_campaign_id <> FND_API.g_miss_num
--      OR p_camp_rec.rollup_type <> FND_API.g_miss_char
--      OR p_camp_rec.media_type_code <> FND_API.g_miss_char
--      OR p_camp_rec.media_id <> FND_API.g_miss_num
--      OR p_camp_rec.channel_id <> FND_API.g_miss_num
--      OR p_camp_rec.event_type <> FND_API.g_miss_char
--      OR p_camp_rec.arc_channel_from <> FND_API.g_miss_char
--   THEN
--      AMS_CampaignRules_PVT.check_camp_media_type(
--         p_camp_rec.campaign_id,
--         p_complete_rec.parent_campaign_id,
--         p_complete_rec.rollup_type,
--         p_complete_rec.media_type_code,
--         p_complete_rec.media_id,
--         p_complete_rec.channel_id,
--         p_complete_rec.event_type,
--         p_complete_rec.arc_channel_from,
--         l_return_status
--      );
--      l_return_status := FND_API.g_ret_sts_success ;
--      IF l_return_status <> FND_API.g_ret_sts_success THEN
--         x_return_status := l_return_status;
--      END IF;
--   END IF;


   -- Check the campaign
   -- No schedules can be added to campaigns in Archieved ,cancelled ,completed campaigns or on hold campaigns
   -- Campaign - Schedule  rule 1
   IF p_validation_mode = JTF_PLSQL_API.g_create THEN
      OPEN c_camp_status ;
      FETCH c_camp_status INTO l_status_code,l_rollup_type ;
      CLOSE c_camp_status ;

      IF l_status_code = 'ARCHIVED'
      OR l_status_code = 'CANCELLED'
      OR l_status_code = 'COMPLETED'
      OR l_status_code = 'ON_HOLD'
      THEN
         AMS_Utility_PVT.Error_Message('AMS_CSCH_INVALID_CAMP_STAT');
         x_return_status := FND_API.G_RET_STS_ERROR;
         RETURN;
      END IF ;

      -- Following validation is added by ptendulk on 24-May-2001 to
      -- ensure that event type schedules can not be created for event type campaigns.
      IF l_rollup_type = 'EVCAM' AND p_complete_rec.activity_type_code = 'EVENTS' THEN
         AMS_Utility_PVT.Error_Message('AMS_CSCH_INVALID_EVENT_SCH');
         x_return_status := FND_API.G_RET_STS_ERROR;
         RETURN;
      END IF ;

   END IF ;





/*  - commented by Nari. Will have to add validation for related events
   -- Check Related Event from
   IF (p_schedule_rec.related_event_id IS NOT NULL AND p_schedule_rec.related_event_id <> FND_API.g_miss_num)
   OR (p_schedule_rec.related_event_from IS NOT NULL AND p_schedule_rec.related_event_from <> FND_API.g_miss_char)
   THEN
      -- Get table_name and pk_name for the ARC qualifier.
      AMS_Utility_PVT.Get_Qual_Table_Name_And_PK (
         p_sys_qual                     => p_complete_rec.related_event_from,
         x_return_status                => x_return_status,
         x_table_name                   => l_table_name,
         x_pk_name                      => l_pk_name
      );

      l_pk_value                 := p_complete_rec.related_event_id ;
      l_pk_data_type             := AMS_Utility_PVT.G_NUMBER;
      l_where_clause             := NULL;

      IF AMS_Utility_PVT.Check_FK_Exists (
             p_table_name                   => l_table_name
            ,p_pk_name                      => l_pk_name
            ,p_pk_value                     => l_pk_value
            ,p_pk_data_type                 => l_pk_data_type
            ,p_additional_where_clause      => l_where_clause
         ) = FND_API.G_FALSE
      THEN
         AMS_UTILITY_PVT.Error_Message('AMS_CAMP_INVALID_EVENT');
         x_return_status := FND_API.G_RET_STS_ERROR;
         RETURN;
      END IF;
   END IF ;*/


   -- checking calendar (i.e. periods) : commented out by soagrawa on 03-dec-2001
   --refer to bug# 2132456
   ------------------- check calendar ----------------------
   /*
   IF (p_schedule_rec.campaign_calendar <> FND_API.g_miss_char AND
       p_schedule_rec.campaign_calendar IS NOT NULL ) OR
      (p_schedule_rec.start_period_name <> FND_API.g_miss_char AND
       p_schedule_rec.start_period_name IS NOT NULL ) OR
      (p_schedule_rec.end_period_name <> FND_API.g_miss_char AND
       p_schedule_rec.end_period_name IS NOT NULL) OR
      (p_schedule_rec.start_date_time <> FND_API.g_miss_date AND
       p_schedule_rec.start_date_time IS NOT NULL) OR
      (p_schedule_rec.end_date_time <> FND_API.g_miss_date AND
       p_schedule_rec.end_date_time IS NOT NULL )
   THEN
      AMS_CampaignRules_PVT.check_camp_calendar(
         p_complete_rec.campaign_calendar,
         p_complete_rec.start_period_name,
         p_complete_rec.end_period_name,
         p_complete_rec.start_date_time,
         p_complete_rec.end_date_time,
         l_return_status
      );
      IF l_return_status <> FND_API.g_ret_sts_success THEN
         x_return_status := l_return_status;
         RETURN ;
      END IF;
   END IF;
   */
   -- end soagrawa 03-dec-2001

   ------------------- check dates ------------------------------
   IF (p_schedule_rec.start_date_time <> FND_API.g_miss_date AND
       p_schedule_rec.start_date_time IS NOT NULL) OR
      (p_schedule_rec.end_date_time <> FND_API.g_miss_date AND
       p_schedule_rec.end_date_time IS NOT NULL)
   THEN
      AMS_ScheduleRules_PVT.Check_Sched_Dates_Vs_Camp(
         p_complete_rec.campaign_id,
         p_complete_rec.start_date_time,
         p_complete_rec.end_date_time,
         l_return_status
      );
      IF l_return_status <> FND_API.g_ret_sts_success THEN
         x_return_status := l_return_status;
         RETURN ;
      END IF;
   END IF;

   -- Check Schedule_Name
   IF p_schedule_rec.campaign_id <> FND_API.g_miss_num OR
      p_schedule_rec.schedule_name <> FND_API.g_miss_char
   THEN
      --l_table_name := 'ams_campaign_schedules_vl' ;
      --l_where_clause := 'campaign_id = '||p_complete_rec.campaign_id ;
      --l_where_clause := l_where_clause || ' AND UPPER(schedule_name) = '''||UPPER(p_complete_rec.schedule_name)||'''' ;

      --IF p_validation_mode = JTF_PLSQL_API.g_update THEN
      --   l_where_clause := l_where_clause || ' AND schedule_id <> '||p_complete_rec.schedule_id ;
      --END IF ;

      --l_valid_flag := AMS_Utility_PVT.check_uniqueness( p_table_name   => l_table_name,
      --                                                  p_where_clause => l_where_clause) ;
      --IF l_valid_flag = FND_API.g_false THEN
      --   AMS_Utility_PVT.Error_Message('AMS_CSCH_DUPLICATE_ID');
      --   x_return_status := FND_API.g_ret_sts_error;
      --   RETURN;
      --END IF;
      IF p_validation_mode = JTF_PLSQL_API.g_update THEN
         OPEN c_sch_name_updt;
         FETCH c_sch_name_updt INTO l_dummy ;
         CLOSE c_sch_name_updt ;
      ELSE
         OPEN c_sch_name;
         FETCH c_sch_name INTO l_dummy ;
         CLOSE c_sch_name ;
      END IF ;

      IF l_dummy IS NOT NULL THEN
      -- Duplicate Schedule
         AMS_Utility_PVT.Error_Message('AMS_CSCH_DUPLICATE_ID');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF ;

   END IF;


   -- Check the Activity type , Activity and Marketing medium associated to the schedule.
   IF p_schedule_rec.activity_type_code <> FND_API.g_miss_char
   OR p_schedule_rec.activity_id <> FND_API.g_miss_num
   OR p_schedule_rec.marketing_medium_id <> FND_API.g_miss_num
   OR p_schedule_rec.arc_marketing_medium_from <> FND_API.g_miss_char
   THEN
      AMS_ScheduleRules_PVT.Check_Schedule_Activity(
         p_schedule_id       =>  p_schedule_rec.schedule_id,
         p_activity_type     =>  p_schedule_rec.activity_type_code,
         p_activity_id       =>  p_schedule_rec.activity_id,
         p_medium_id         =>  p_schedule_rec.marketing_medium_id,
         p_arc_channel_from  =>  p_schedule_rec.arc_marketing_medium_from,
         p_status_code       =>  p_complete_rec.status_code,
         x_return_status     =>  x_return_status       ) ;

   END IF;
   -- check parent source flag
   IF p_schedule_rec.activity_type_code = 'EVENTS' AND
      p_schedule_rec.use_parent_code_flag = 'Y'
   THEN
      AMS_Utility_PVT.Error_Message('AMS_CSCH_BAD_PARENT_CODE_FLAG');
      x_return_status := FND_API.g_ret_sts_error;
   END IF;

END Check_Schedule_Inter_Entity;

--===================================================================
-- NAME
--    Init_schedule_rec
--
-- PURPOSE
--    Initialize schedules rec, used for testing.
--
-- NOTES
--
--
-- HISTORY
--   22-Jan-2001     PTENDULK   Created
--   27-jun-2003     ANCHAUDH  added the extra columns in the record for triggers changes.
--===================================================================
PROCEDURE Init_Schedule_Rec(x_schedule_rec OUT NOCOPY schedule_rec_type)
IS
BEGIN
   x_schedule_rec.schedule_id                     := FND_API.G_MISS_NUM  ;
   x_schedule_rec.last_update_date                := FND_API.G_MISS_DATE ;
   x_schedule_rec.last_updated_by                 := FND_API.G_MISS_NUM  ;
   x_schedule_rec.creation_date                   := FND_API.G_MISS_DATE ;
   x_schedule_rec.created_by                      := FND_API.G_MISS_NUM  ;
   x_schedule_rec.last_update_login               := FND_API.G_MISS_NUM;
   x_schedule_rec.object_version_number           := FND_API.G_MISS_NUM ;
   x_schedule_rec.campaign_id                     := FND_API.G_MISS_NUM ;
   x_schedule_rec.user_status_id                  := FND_API.G_MISS_NUM ;
   x_schedule_rec.status_code                     := FND_API.G_MISS_CHAR ;
   x_schedule_rec.status_date                     := FND_API.G_MISS_DATE ;
   x_schedule_rec.source_code                     := FND_API.G_MISS_CHAR ;
   x_schedule_rec.use_parent_code_flag            := FND_API.G_MISS_CHAR ;
   x_schedule_rec.start_date_time                 := FND_API.G_MISS_DATE ;
   x_schedule_rec.end_date_time                   := FND_API.G_MISS_DATE ;
   x_schedule_rec.timezone_id                     := FND_API.G_MISS_NUM ;
   x_schedule_rec.activity_type_code              := FND_API.G_MISS_CHAR ;
   x_schedule_rec.activity_id                     := FND_API.G_MISS_NUM ;
   x_schedule_rec.arc_marketing_medium_from       := FND_API.G_MISS_CHAR ;
   x_schedule_rec.marketing_medium_id             := FND_API.G_MISS_NUM ;
   x_schedule_rec.custom_setup_id                 := FND_API.G_MISS_NUM ;
   x_schedule_rec.triggerable_flag                := FND_API.G_MISS_CHAR ;
   x_schedule_rec.trigger_id                      := FND_API.G_MISS_NUM ;
   x_schedule_rec.notify_user_id                  := FND_API.G_MISS_NUM ;
   x_schedule_rec.approver_user_id                := FND_API.G_MISS_NUM ;
   x_schedule_rec.owner_user_id                   := FND_API.G_MISS_NUM ;
   x_schedule_rec.active_flag                     := FND_API.G_MISS_CHAR ;
   x_schedule_rec.cover_letter_id                 := FND_API.G_MISS_NUM ;
   x_schedule_rec.reply_to_mail                   := FND_API.G_MISS_CHAR ;
   x_schedule_rec.mail_sender_name                := FND_API.G_MISS_CHAR ;
   x_schedule_rec.mail_subject                    := FND_API.G_MISS_CHAR ;
   x_schedule_rec.from_fax_no                     := FND_API.G_MISS_CHAR ;
   x_schedule_rec.accounts_closed_flag            := FND_API.G_MISS_CHAR ;
   x_schedule_rec.org_id                          := FND_API.G_MISS_NUM ;
   x_schedule_rec.objective_code                  := FND_API.G_MISS_CHAR ;
   x_schedule_rec.country_id                      := FND_API.G_MISS_NUM ;
   x_schedule_rec.campaign_calendar               := FND_API.G_MISS_CHAR ;
   x_schedule_rec.start_period_name               := FND_API.G_MISS_CHAR ;
   x_schedule_rec.end_period_name                 := FND_API.G_MISS_CHAR ;
   x_schedule_rec.priority                        := FND_API.G_MISS_CHAR ;
   x_schedule_rec.workflow_item_key               := FND_API.G_MISS_CHAR ;
   x_schedule_rec.transaction_currency_code       := FND_API.G_MISS_CHAR ;
   x_schedule_rec.functional_currency_code        := FND_API.G_MISS_CHAR ;
   x_schedule_rec.budget_amount_tc                := FND_API.G_MISS_NUM ;
   x_schedule_rec.budget_amount_fc                := FND_API.G_MISS_NUM ;
   x_schedule_rec.language_code                   := FND_API.G_MISS_CHAR ;
   x_schedule_rec.task_id                         := FND_API.G_MISS_NUM ;
   x_schedule_rec.related_event_from              := FND_API.G_MISS_CHAR ;
   x_schedule_rec.related_event_id                := FND_API.G_MISS_NUM ;
   x_schedule_rec.attribute_category              := FND_API.G_MISS_CHAR ;
   x_schedule_rec.attribute1                      := FND_API.G_MISS_CHAR ;
   x_schedule_rec.attribute2                      := FND_API.G_MISS_CHAR ;
   x_schedule_rec.attribute3                      := FND_API.G_MISS_CHAR ;
   x_schedule_rec.attribute4                      := FND_API.G_MISS_CHAR ;
   x_schedule_rec.attribute5                      := FND_API.G_MISS_CHAR ;
   x_schedule_rec.attribute6                      := FND_API.G_MISS_CHAR ;
   x_schedule_rec.attribute7                      := FND_API.G_MISS_CHAR ;
   x_schedule_rec.attribute8                      := FND_API.G_MISS_CHAR ;
   x_schedule_rec.attribute9                      := FND_API.G_MISS_CHAR ;
   x_schedule_rec.attribute10                     := FND_API.G_MISS_CHAR ;
   x_schedule_rec.attribute11                     := FND_API.G_MISS_CHAR ;
   x_schedule_rec.attribute12                     := FND_API.G_MISS_CHAR ;
   x_schedule_rec.attribute13                     := FND_API.G_MISS_CHAR ;
   x_schedule_rec.attribute14                     := FND_API.G_MISS_CHAR ;
   x_schedule_rec.attribute15                     := FND_API.G_MISS_CHAR ;
   x_schedule_rec.activity_attribute_category     := FND_API.G_MISS_CHAR ;
   x_schedule_rec.activity_attribute1             := FND_API.G_MISS_CHAR ;
   x_schedule_rec.activity_attribute2             := FND_API.G_MISS_CHAR ;
   x_schedule_rec.activity_attribute3             := FND_API.G_MISS_CHAR ;
   x_schedule_rec.activity_attribute4             := FND_API.G_MISS_CHAR ;
   x_schedule_rec.activity_attribute5             := FND_API.G_MISS_CHAR ;
   x_schedule_rec.activity_attribute6             := FND_API.G_MISS_CHAR ;
   x_schedule_rec.activity_attribute7             := FND_API.G_MISS_CHAR ;
   x_schedule_rec.activity_attribute8             := FND_API.G_MISS_CHAR ;
   x_schedule_rec.activity_attribute9             := FND_API.G_MISS_CHAR ;
   x_schedule_rec.activity_attribute10            := FND_API.G_MISS_CHAR ;
   x_schedule_rec.activity_attribute11            := FND_API.G_MISS_CHAR ;
   x_schedule_rec.activity_attribute12            := FND_API.G_MISS_CHAR ;
   x_schedule_rec.activity_attribute13            := FND_API.G_MISS_CHAR ;
   x_schedule_rec.activity_attribute14            := FND_API.G_MISS_CHAR ;
   x_schedule_rec.activity_attribute15            := FND_API.G_MISS_CHAR ;
   -- removed by soagrawa on 24-sep-2001
   -- x_schedule_rec.security_group_id               := FND_API.G_MISS_NUM ;
   x_schedule_rec.schedule_name                   := FND_API.G_MISS_CHAR ;
   x_schedule_rec.description                     := FND_API.G_MISS_CHAR ;
   x_schedule_rec.related_source_id               := FND_API.G_MISS_NUM ;
   x_schedule_rec.related_source_code             := FND_API.G_MISS_CHAR ;
   x_schedule_rec.related_source_object           := FND_API.G_MISS_CHAR ;
   x_schedule_rec.query_id                        := FND_API.G_MISS_NUM ;
   x_schedule_rec.include_content_flag            := FND_API.G_MISS_CHAR;
   x_schedule_rec.content_type                    := FND_API.G_MISS_CHAR;
   x_schedule_rec.test_email_address              := FND_API.G_MISS_CHAR;
   x_schedule_rec.greeting_text                   := FND_API.G_MISS_CHAR;
   x_schedule_rec.footer_text                     := FND_API.G_MISS_CHAR;
-- following are added by anchaudh on 27-jun-2003
   x_schedule_rec.trig_repeat_flag            := FND_API.G_MISS_CHAR ;
   x_schedule_rec.tgrp_exclude_prev_flag        := FND_API.G_MISS_CHAR ;
   x_schedule_rec.orig_csch_id               := FND_API.G_MISS_NUM ;
   x_schedule_rec.cover_letter_version    := FND_API.G_MISS_NUM ;
-- following are added by dbiswas on 12-aug-2003
   x_schedule_rec.usage                   := FND_API.G_MISS_CHAR ;
   x_schedule_rec.purpose                 := FND_API.G_MISS_CHAR ;
   x_schedule_rec.last_activation_date    := FND_API.G_MISS_DATE ;
   x_schedule_rec.sales_methodology_id    := FND_API.G_MISS_NUM ;
   x_schedule_rec.printer_address         := FND_API.G_MISS_CHAR ;
-- following is added by dbiswas on 27-jul-2005
   x_schedule_rec.notify_on_activation_flag := FND_API.G_MISS_CHAR ;
   -- following is added by anchaudh on 01-Feb-2006
   x_schedule_rec.sender_display_name := FND_API.G_MISS_CHAR ;
   x_schedule_rec.delivery_mode := FND_API.G_MISS_CHAR ;


END Init_Schedule_Rec ;


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Copy_Camp_Schedule
--
--   Description
--           To support the "Copy Schedule" functionality from the schedule overview
--           and detail pages.
--
--   History
--      30-Apr-2001   soagrawa  Created this procedure
--      22-oct-2001   soagrawa  Fixed bug# 2068786
--      10-jan-2002   soagrawa  Fixed bug# 2178737
--      07-feb-2002   soagrawa  Fixed bug# 2229618 (copy does not retain the specified source code)
--      28-mar-2002   soagrawa  Fixed bug# 2289769
--      22-may-2002   soagrawa  Fixed bug# 2380670
--      02-jul-2002   soagrawa  Fixed bug# 2442695 (length of coordinator name)
--      06-feb-2003   soagrawa  Fixed bug# 2788922
--      27-jun-2003  anchaudh  added the extra columns in the record for triggers backporting.
--      11-july-2003  anchaudh  fixed bug#3046802
--   ==============================================================================
--

PROCEDURE Copy_Camp_Schedule(
    p_api_version                IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_source_object_id           IN   NUMBER,
    p_attributes_table           IN   AMS_CpyUtility_PVT.copy_attributes_table_type,
    p_copy_columns_table         IN   AMS_CpyUtility_PVT.copy_columns_table_type,

    x_new_object_id              OUT NOCOPY  NUMBER,
    x_custom_setup_id            OUT NOCOPY  NUMBER
     )
IS

   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Copy_Camp_Schedule';
   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_return_status_full        VARCHAR2(1);
   l_object_version_number     NUMBER := 1;
   l_org_id                    NUMBER := FND_API.G_MISS_NUM;
   l_schedule_id               NUMBER;
   l_new_schedule_id           NUMBER;
   l_dummy                     NUMBER;

   l_return_status             VARCHAR2(1);
   --l_msg_count               NUMBER;
   --l_msg_data                VARCHAR2;
   l_custom_setup_id           NUMBER := 1;
   -- length modified by soagrawa on 10-jan-2002
   -- bug# 2178737
   l_campaign_name             VARCHAR2(240);--VARCHAR(50);
   -- soagrawa modified the sizes of country name and coordinator name
   -- to fix bug# 2442695
   l_country_name              VARCHAR(240);
   l_coordinator_name          VARCHAR(240);

   l_attr_list                 Ams_CopyActivities_PVT.schedule_attr_rec_type;

   CURSOR get_camp_id  IS
   SELECT campaign_id
   FROM   ams_campaigns_vl
   WHERE  campaign_name = l_campaign_name;
/*
   CURSOR get_country_id  IS
   SELECT campaign_id
   FROM   ams_campaigns_vl
   WHERE  campaign_name = l_campaign_name;

*/
/*   CURSOR fetch_sch_details (sch_id NUMBER) IS
   SELECT
       schedule_id,
       last_update_date,
       last_updated_by,
       creation_date,
       created_by,
       last_update_login,
       null, -- obj version number
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
       security_group_id,
       schedule_name,
       description,
       null,null,NULL --related source stuff
   FROM ams_campaign_schedules_vl
   WHERE schedule_id = sch_id;
*/
   CURSOR fetch_sch_details (sch_id NUMBER) IS
   SELECT * FROM ams_campaign_schedules_vl
   WHERE schedule_id = sch_id ;

   CURSOR fetch_event_details (event_id NUMBER) IS
   SELECT * FROM ams_event_offers_vl
   WHERE event_offer_id = event_id ;

   CURSOR c_delivery (delv_id NUMBER) IS
   SELECT delivery_media_type_code
   FROM ams_act_delivery_methods
   WHERE activity_delivery_method_id = delv_id;

   -- soagrawa 22-oct-2002 for bug# 2594717
   CURSOR c_eone_srccd(event_id NUMBER) IS
   SELECT source_code
     FROM ams_event_offers_all_b
    WHERE event_offer_id = event_id;

   l_eone_srccd    VARCHAR2(30);



   l_reference_rec             fetch_sch_details%ROWTYPE;
   -- dhsingh, 28.07.2004, Bug#3798545.
   --l_schedule_rec              schedule_rec_type;
   l_schedule_rec                  AMS_Camp_Schedule_PUB.schedule_rec_type;
   -- END dhsingh.
   l_new_reference_rec         fetch_sch_details%ROWTYPE;

   --added by soagrawa on 11-jan-2002
   l_new_event_offer_id        NUMBER;
   l_event_offer_rec           AMS_EventOffer_PVT.evo_rec_type;
   l_reference_event_rec       fetch_event_details%ROWTYPE;

   l_errnum          NUMBER;
   l_errcode         VARCHAR2(30);
   l_errmsg          VARCHAR2(4000);

BEGIN

   -- Standard Start of API savepoint
   SAVEPOINT COPY_Camp_Schedule_PVT;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
   END IF;


   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;


   --
   -- Start of API body
   --

   -- ----------------------------
   -- fetch source object details
   -- ----------------------------

   OPEN fetch_sch_details(p_source_object_id);
   FETCH fetch_sch_details INTO l_reference_rec;
   CLOSE fetch_sch_details;

   -- Copy GENERAL info from source schedule
   --   IF AMS_CpyUtility_PVT.is_copy_attribute ('DETL', p_attributes_table) = FND_API.G_TRUE THEN
   --      OPEN fetch_sch_details(p_source_object_id);
   --      FETCH fetch_sch_details INTO l_schedule_rec;
   --      CLOSE fetch_sch_details;
   --   END IF;




   l_schedule_rec.schedule_id := null;

   -- following line of code is added by ptendulk on 06-Jun-2001
   --

   l_schedule_rec.activity_type_code              := l_reference_rec.activity_type_code ;
   l_schedule_rec.activity_id                     := l_reference_rec.activity_id;
   l_schedule_rec.arc_marketing_medium_from       := l_reference_rec.arc_marketing_medium_from;
   l_schedule_rec.marketing_medium_id             := l_reference_rec.marketing_medium_id;
   l_schedule_rec.custom_setup_id                 := l_reference_rec.custom_setup_id;
-- anchaudh : for bug#3046802
    l_schedule_rec.triggerable_flag                := 'N'; --l_reference_rec.triggerable_flag;
  -- l_schedule_rec.trigger_id                      := l_reference_rec.trigger_id;
   l_schedule_rec.notify_user_id                  := l_reference_rec.notify_user_id;
   l_schedule_rec.approver_user_id                := l_reference_rec.approver_user_id;
   l_schedule_rec.owner_user_id                   := l_reference_rec.owner_user_id;
   l_schedule_rec.active_flag                     := l_reference_rec.active_flag;

 -- sodixit 09-oct-2003 commented. 11.5.10 onwards, cover_letter information will exists in IBC
 --l_schedule_rec.cover_letter_id                 := l_reference_rec.cover_letter_id;
   l_schedule_rec.reply_to_mail                   := l_reference_rec.reply_to_mail;
   l_schedule_rec.mail_sender_name                := l_reference_rec.mail_sender_name;
   l_schedule_rec.mail_subject                    := l_reference_rec.mail_subject;
   l_schedule_rec.from_fax_no                     := l_reference_rec.from_fax_no;
   l_schedule_rec.accounts_closed_flag            := l_reference_rec.accounts_closed_flag;
   l_schedule_rec.org_id                          := l_reference_rec.org_id;
   l_schedule_rec.objective_code                  := l_reference_rec.objective_code;
   l_schedule_rec.country_id                      := l_reference_rec.country_id;
   l_schedule_rec.campaign_calendar               := l_reference_rec.campaign_calendar;
   l_schedule_rec.start_period_name               := l_reference_rec.start_period_name;
   l_schedule_rec.end_period_name                 := l_reference_rec.end_period_name;
   l_schedule_rec.priority                        := l_reference_rec.priority;
   l_schedule_rec.workflow_item_key               := l_reference_rec.workflow_item_key;
   l_schedule_rec.transaction_currency_code       := l_reference_rec.transaction_currency_code;
   l_schedule_rec.functional_currency_code        := l_reference_rec.functional_currency_code;

   -- sodixit 09-oct-2003 added usage, purpose, sales_methodology_id for 11.5.10.
   l_schedule_rec.usage              := l_reference_rec.usage;
   l_schedule_rec.purpose           := l_reference_rec.purpose;
   l_schedule_rec.sales_methodology_id        := l_reference_rec.sales_methodology_id;
   -- dbiswas 27-jul-2005 added notify_on_activation_flag for R12.
   l_schedule_rec.notify_on_activation_flag := l_reference_rec.notify_on_activation_flag;
   -- commented out by soagrawa on 22-oct-2001 to fix bug# 2068786
   -- l_schedule_rec.budget_amount_tc                := l_reference_rec.budget_amount_tc;
   -- l_schedule_rec.budget_amount_fc                := l_reference_rec.budget_amount_fc;
   l_schedule_rec.language_code                   := l_reference_rec.language_code;
   l_schedule_rec.task_id                         := l_reference_rec.task_id;

   -- removed by soagrawa on 11-jan-2002
   -- l_schedule_rec.related_event_from              := l_reference_rec.related_event_from;
   -- l_schedule_rec.related_event_id                := l_reference_rec.related_event_id;
      l_schedule_rec.related_event_id                := NULL;


   -- end soagrawa 11-jan-2002
   l_schedule_rec.attribute_category              := l_reference_rec.attribute_category;
   l_schedule_rec.attribute1                      := l_reference_rec.attribute1;
   l_schedule_rec.attribute2                      := l_reference_rec.attribute2;
   l_schedule_rec.attribute3                      := l_reference_rec.attribute3;
   l_schedule_rec.attribute4                      := l_reference_rec.attribute4;
   l_schedule_rec.attribute5                      := l_reference_rec.attribute5;
   l_schedule_rec.attribute6                      := l_reference_rec.attribute6;
   l_schedule_rec.attribute7                      := l_reference_rec.attribute7;
   l_schedule_rec.attribute8                      := l_reference_rec.attribute8;
   l_schedule_rec.attribute9                      := l_reference_rec.attribute9;
   l_schedule_rec.attribute10                     := l_reference_rec.attribute10;
   l_schedule_rec.attribute11                     := l_reference_rec.attribute11;
   l_schedule_rec.attribute12                     := l_reference_rec.attribute12;
   l_schedule_rec.attribute13                     := l_reference_rec.attribute13;
   l_schedule_rec.attribute14                     := l_reference_rec.attribute14;
   l_schedule_rec.attribute15                     := l_reference_rec.attribute15;
   l_schedule_rec.activity_attribute_category     := l_reference_rec.activity_attribute_category;
   l_schedule_rec.activity_attribute1             := l_reference_rec.activity_attribute1;
   l_schedule_rec.activity_attribute2             := l_reference_rec.activity_attribute2;
   l_schedule_rec.activity_attribute3             := l_reference_rec.activity_attribute3;
   l_schedule_rec.activity_attribute4             := l_reference_rec.activity_attribute4;
   l_schedule_rec.activity_attribute5             := l_reference_rec.activity_attribute5;
   l_schedule_rec.activity_attribute6             := l_reference_rec.activity_attribute6;
   l_schedule_rec.activity_attribute7             := l_reference_rec.activity_attribute7;
   l_schedule_rec.activity_attribute8             := l_reference_rec.activity_attribute8;
   l_schedule_rec.activity_attribute9             := l_reference_rec.activity_attribute9;
   l_schedule_rec.activity_attribute10            := l_reference_rec.activity_attribute10;
   l_schedule_rec.activity_attribute11            := l_reference_rec.activity_attribute11;
   l_schedule_rec.activity_attribute12            := l_reference_rec.activity_attribute12;
   l_schedule_rec.activity_attribute13            := l_reference_rec.activity_attribute13;
   l_schedule_rec.activity_attribute14            := l_reference_rec.activity_attribute14;
   l_schedule_rec.activity_attribute15            := l_reference_rec.activity_attribute15;
   -- removed by soagrawa on 24-sep-2001
   -- l_schedule_rec.security_group_id               := l_reference_rec.security_group_id;
   l_schedule_rec.schedule_name                   := l_reference_rec.schedule_name;
   --l_schedule_rec.description                     := l_reference_rec.description;

   -- soagrawa 22-oct-2002 for bug# 2594717
   -- l_schedule_rec.related_source_object           := l_reference_rec.related_event_from;
   -- l_schedule_rec.related_source_id               := l_reference_rec.related_event_id;

   l_schedule_rec.query_id                        := l_reference_rec.query_id;
   l_schedule_rec.include_content_flag            := l_reference_rec.include_content_flag;
   l_schedule_rec.greeting_text                   := l_reference_rec.greeting_text;
   l_schedule_rec.footer_text                     := l_reference_rec.footer_text;

   -- anchaudh 01-feb-2006 added sender_display_name column.
   l_schedule_rec.sender_display_name := l_reference_rec.sender_display_name;
   l_schedule_rec.delivery_mode := l_reference_rec.delivery_mode;

   -- soagrawa 22-oct-2002 for bug# 2594717
--   l_schedule_rec.related_source_id               :=  NULL;
--   l_schedule_rec.related_source_code             :=  NULL;
--   l_schedule_rec.related_source_object           :=  NULL;

-- following trigger info won't get copied from now on: anchaudh for bug#3046802
-- following are added by anchaudh on 27-jun-2003
     -- l_schedule_rec.trig_repeat_flag                  := l_reference_rec.trig_repeat_flag;
      --l_schedule_rec.tgrp_exclude_prev_flag             := l_reference_rec.tgrp_exclude_prev_flag;

 --  l_schedule_rec.orig_csch_id                  := l_reference_rec.orig_csch_id;

  -- sodixit 09-oct-2003 commented. 11.5.10 onwards, cover_letter information will exists in IBC
   --l_schedule_rec.cover_letter_version       := l_reference_rec.cover_letter_version;
   -- ------------------------------
   -- copy all required fields
   -- i.e. copy values of all mandatory columns from the copy UI
   -- Mandatory fields for CSCH are Start Date and End Date
   -- ------------------------------

   l_schedule_rec.timezone_id := l_reference_rec.timezone_id;
   --   l_schedule_rec.user_status_id := AMS_Utility_PVT.get_default_user_status() ;-- NEW  l_reference_rec.user_status_id
   l_schedule_rec.user_status_id := AMS_Utility_PVT.get_default_user_status('AMS_CAMPAIGN_SCHEDULE_STATUS','NEW') ;
   l_schedule_rec.status_code := 'NEW';


   -- -------------------------------------------
   -- if field is not passed in from copy_columns_table
   -- copy from the base object
   -- -------------------------------------------


   AMS_CpyUtility_PVT.get_column_value ('StartDate', p_copy_columns_table, l_schedule_rec.start_date_time);
   l_schedule_rec.start_date_time := NVL (l_schedule_rec.start_date_time, l_reference_rec.start_date_time);
   AMS_CpyUtility_PVT.get_column_value ('EndDate', p_copy_columns_table, l_schedule_rec.end_date_time);
   l_schedule_rec.end_date_time := NVL (l_schedule_rec.end_date_time, l_reference_rec.end_date_time);

   -- added by soagrawa on 16-Jun-2001
   AMS_CpyUtility_PVT.get_column_value ('copyParSrcCode', p_copy_columns_table, l_schedule_rec.source_code);
   -- next line commented out by soagrawa on 28-mar-2002
   --l_schedule_rec.source_code := NVL (l_schedule_rec.source_code, l_reference_rec.source_code);
   AMS_CpyUtility_PVT.get_column_value ('copyUseParSrcCode', p_copy_columns_table, l_schedule_rec.use_parent_code_flag);
   l_schedule_rec.use_parent_code_flag := NVL (l_schedule_rec.use_parent_code_flag, l_reference_rec.use_parent_code_flag);

   --
   -- mandatory fields for csch create are
   -- name, lang, coordinator, currency, st date, time zone
   --

   AMS_CpyUtility_PVT.get_column_value ('Language', p_copy_columns_table, l_schedule_rec.language_code);
   l_schedule_rec.language_code := NVL (l_schedule_rec.language_code, l_reference_rec.language_code);
   AMS_CpyUtility_PVT.get_column_value ('CoordinatorName', p_copy_columns_table, l_coordinator_name);
   -- modified by soagrawa for bug# 2380670
   -- AMS_CpyUtility_PVT.get_column_value ('CoordinatorId', p_copy_columns_table, l_reference_rec.owner_user_id);
   AMS_CpyUtility_PVT.get_column_value ('CoordinatorId', p_copy_columns_table, l_schedule_rec.owner_user_id);
   l_schedule_rec.owner_user_id := NVL (l_schedule_rec.owner_user_id, l_reference_rec.owner_user_id);

   AMS_CpyUtility_PVT.get_column_value ('Currency', p_copy_columns_table, l_schedule_rec.transaction_currency_code);
   l_schedule_rec.transaction_currency_code := NVL (l_schedule_rec.transaction_currency_code, l_reference_rec.transaction_currency_code);

   --dbiswas added the following columns that can be edited on the UI.

   AMS_CpyUtility_PVT.get_column_value ('MarketingMediumId', p_copy_columns_table, l_schedule_rec.marketing_medium_id);
   l_schedule_rec.marketing_medium_id := NVL (l_schedule_rec.marketing_medium_id, l_reference_rec.marketing_medium_id);

   AMS_CpyUtility_PVT.get_column_value ('Purpose', p_copy_columns_table, l_schedule_rec.purpose);

   AMS_CpyUtility_PVT.get_column_value ('SourceCode', p_copy_columns_table, l_schedule_rec.source_code);

   AMS_CpyUtility_PVT.get_column_value ('description', p_copy_columns_table, l_schedule_rec.description);


   AMS_CpyUtility_PVT.get_column_value ('attribute_category', p_copy_columns_table, l_schedule_rec.attribute_category);

   AMS_CpyUtility_PVT.get_column_value ('attribute1', p_copy_columns_table, l_schedule_rec.attribute1);

   AMS_CpyUtility_PVT.get_column_value ('attribute2', p_copy_columns_table, l_schedule_rec.attribute2);

   AMS_CpyUtility_PVT.get_column_value ('attribute3', p_copy_columns_table, l_schedule_rec.attribute3);

   AMS_CpyUtility_PVT.get_column_value ('attribute4', p_copy_columns_table, l_schedule_rec.attribute4);

   AMS_CpyUtility_PVT.get_column_value ('attribute5', p_copy_columns_table, l_schedule_rec.attribute5);

   AMS_CpyUtility_PVT.get_column_value ('attribute6', p_copy_columns_table, l_schedule_rec.attribute6);

   AMS_CpyUtility_PVT.get_column_value ('attribute7', p_copy_columns_table, l_schedule_rec.attribute7);

   AMS_CpyUtility_PVT.get_column_value ('attribute8', p_copy_columns_table, l_schedule_rec.attribute8);

   AMS_CpyUtility_PVT.get_column_value ('attribute9', p_copy_columns_table, l_schedule_rec.attribute9);

   AMS_CpyUtility_PVT.get_column_value ('attribute10', p_copy_columns_table, l_schedule_rec.attribute10);

   AMS_CpyUtility_PVT.get_column_value ('attribute11', p_copy_columns_table, l_schedule_rec.attribute11);

   AMS_CpyUtility_PVT.get_column_value ('attribute12', p_copy_columns_table, l_schedule_rec.attribute12);

   AMS_CpyUtility_PVT.get_column_value ('attribute13', p_copy_columns_table, l_schedule_rec.attribute13);

   AMS_CpyUtility_PVT.get_column_value ('attribute14', p_copy_columns_table, l_schedule_rec.attribute14);

   AMS_CpyUtility_PVT.get_column_value ('attribute15', p_copy_columns_table, l_schedule_rec.attribute15);


   AMS_CpyUtility_PVT.get_column_value ('activityAttributeCategory', p_copy_columns_table, l_schedule_rec.activity_attribute_category);

   AMS_CpyUtility_PVT.get_column_value ('activityAttribute1', p_copy_columns_table, l_schedule_rec.activity_attribute1);

   AMS_CpyUtility_PVT.get_column_value ('activityAttribute2', p_copy_columns_table, l_schedule_rec.activity_attribute2);

   AMS_CpyUtility_PVT.get_column_value ('activityAttribute3', p_copy_columns_table, l_schedule_rec.activity_attribute3);

   AMS_CpyUtility_PVT.get_column_value ('activityAttribute4', p_copy_columns_table, l_schedule_rec.activity_attribute4);

   AMS_CpyUtility_PVT.get_column_value ('activityAttribute5', p_copy_columns_table, l_schedule_rec.activity_attribute5);

   AMS_CpyUtility_PVT.get_column_value ('activityAttribute6', p_copy_columns_table, l_schedule_rec.activity_attribute6);

   AMS_CpyUtility_PVT.get_column_value ('activityAttribute7', p_copy_columns_table, l_schedule_rec.activity_attribute7);

   AMS_CpyUtility_PVT.get_column_value ('activityAttribute8', p_copy_columns_table, l_schedule_rec.activity_attribute8);

   AMS_CpyUtility_PVT.get_column_value ('activityAttribute9', p_copy_columns_table, l_schedule_rec.activity_attribute9);

   AMS_CpyUtility_PVT.get_column_value ('activityAttribute10', p_copy_columns_table, l_schedule_rec.activity_attribute10);

   AMS_CpyUtility_PVT.get_column_value ('activityAttribute11', p_copy_columns_table, l_schedule_rec.activity_attribute11);

   AMS_CpyUtility_PVT.get_column_value ('activityAttribute12', p_copy_columns_table, l_schedule_rec.activity_attribute12);

   AMS_CpyUtility_PVT.get_column_value ('activityAttribute13', p_copy_columns_table, l_schedule_rec.activity_attribute13);

   AMS_CpyUtility_PVT.get_column_value ('activityAttribute14', p_copy_columns_table, l_schedule_rec.activity_attribute14);

   AMS_CpyUtility_PVT.get_column_value ('activityAttribute15', p_copy_columns_table, l_schedule_rec.activity_attribute15);

 -- end updates by dbiswas for columns that can be edited from the UI
   -- -------------------------------------------
   -- if field is not passed in from copy_columns_table
   -- copy from the base object
   -- -------------------------------------------

   AMS_CpyUtility_PVT.get_column_value ('newObjName', p_copy_columns_table, l_schedule_rec.schedule_name);

   AMS_CpyUtility_PVT.get_column_value ('CampaignName', p_copy_columns_table, l_campaign_name);
   OPEN get_camp_id;
   FETCH get_camp_id INTO l_schedule_rec.campaign_id;
   CLOSE get_camp_id;

   -- next line removed by soagrawa on 07-mar-2002 to fix bug# 2229618
   -- AMS_CpyUtility_PVT.get_column_value ('CampaignSource', p_copy_columns_table, l_schedule_rec.source_code);

   /*AMS_CpyUtility_PVT.get_column_value ('CountryName', p_copy_columns_table, l_country_name);
   OPEN get_country_id;
   FETCH get_camp_id INTO l_schedule_rec.campaign_id;
   CLOSE get_camp_id;
   */


      -- #Fix for bug 2989203 by asaha
      IF(l_schedule_rec.activity_type_code = 'EVENTS' AND
         l_schedule_rec.use_parent_code_flag = 'Y') THEN
        IF(AMS_DEBUG_HIGH_ON) THEN
          AMS_UTILITY_PVT.Debug_Message('change use parent flag to N for Event type schedule
');
        END IF;
        l_schedule_rec.use_parent_code_flag := 'N';
      END IF;
      -- end of Fix for bug 2989203



   -- AMS_CpyUtility_PVT.get_column_value ('', p_copy_columns_table, l_schedule_rec.);

      AMS_UTILITY_PVT.debug_message('before copying event '||l_schedule_rec.activity_type_code);
      AMS_UTILITY_PVT.debug_message('before copying event '||l_reference_rec.related_event_id);

   -- added by soagrawa on 11-jan-2002
   -- copy event details into a new EONE and update new schedule with that new id
   IF l_schedule_rec.activity_type_code = 'EVENTS'
   -- soagrawa 06-feb-2003 fixed bug# 2788922
   -- AND l_schedule_rec.related_event_id IS NOT null
   AND l_reference_rec.related_event_id IS NOT null
   THEN

      -- get original related event's data
      OPEN fetch_event_details(l_reference_rec.related_event_id);
      FETCH fetch_event_details INTO l_reference_event_rec;
      CLOSE fetch_event_details;

      OPEN c_delivery(l_reference_event_rec.event_delivery_method_id);
      FETCH c_delivery INTO l_event_offer_rec.event_delivery_method_code;
      CLOSE c_delivery;

      -- copy whatever remains same
      l_event_offer_rec.event_level                 := l_reference_event_rec.event_level ;
      l_event_offer_rec.event_type_code             := l_reference_event_rec.event_type_code ;
      l_event_offer_rec.event_object_type           := 'EONE' ;

      -- l_event_offer_rec.event_delivery_method_id    := l_reference_event_rec.event_delivery_method_id ;
      -- dbiswas changed event_venue_id to NULL on 24-Jun-2003. Bug 3008802
      -- l_event_offer_rec.event_venue_id              := l_reference_event_rec.event_venue_id ;
      l_event_offer_rec.event_location_id           := l_reference_event_rec.event_location_id ;
      l_event_offer_rec.reg_required_flag           := l_reference_event_rec.reg_required_flag ;
      l_event_offer_rec.reg_charge_flag             := l_reference_event_rec.reg_charge_flag ;
      l_event_offer_rec.reg_invited_only_flag       := l_reference_event_rec.reg_invited_only_flag ;
      l_event_offer_rec.event_standalone_flag       := l_reference_event_rec.event_standalone_flag ;
      l_event_offer_rec.create_attendant_lead_flag  := l_reference_event_rec.create_attendant_lead_flag ;
      l_event_offer_rec.create_registrant_lead_flag := l_reference_event_rec.create_registrant_lead_flag ;
      l_event_offer_rec.private_flag                := l_reference_event_rec.private_flag ;
      l_event_offer_rec.parent_type                 := l_reference_event_rec.parent_type;
      l_event_offer_rec.country_code                := l_reference_event_rec.country_code;
      l_event_offer_rec.user_status_id              := l_reference_event_rec.user_status_id;
      l_event_offer_rec.system_status_code          := l_reference_event_rec.system_status_code;
      l_event_offer_rec.application_id              := l_reference_event_rec.application_id;
      l_event_offer_rec.custom_setup_id             := l_reference_event_rec.setup_type_id;

      -- modify whatever needs to be changed
      l_event_offer_rec.event_start_date   := l_schedule_rec.start_date_time ;
      l_event_offer_rec.event_end_date     := l_schedule_rec.end_date_time ;
      l_event_offer_rec.event_offer_name   := l_schedule_rec.schedule_name;
      l_event_offer_rec.owner_user_id      := l_schedule_rec.owner_user_id;
      -- l_event_offer_rec.source_code        := NVL (l_event_offer_rec.source_code, NULL);
      -- l_event_offer_rec.currency_code_tc        := NVL (l_event_offer_rec.source_code, NULL);
      l_event_offer_rec.event_language_code:= l_schedule_rec.language_code;
      l_event_offer_rec.parent_id          := l_schedule_rec.campaign_id;

      -- null valued attributes
      l_event_offer_rec.business_unit_id        := NULL;
      l_event_offer_rec.event_venue_id              := NULL;
      -- end update by dbiswas for bug 3008802
      l_event_offer_rec.reg_start_date          := NULL;
      l_event_offer_rec.reg_end_date            := NULL;
      l_event_offer_rec.city                    := NULL;
      l_event_offer_rec.state                   := NULL;
      l_event_offer_rec.country                 :=NULL;
      l_event_offer_rec.description             := NULL;
      l_event_offer_rec.start_period_name       := NULL;
      l_event_offer_rec.end_period_name         := NULL;
      l_event_offer_rec.priority_type_code      := NULL;
      l_event_offer_rec.INVENTORY_ITEM_ID       := NULL;
      l_event_offer_rec.PRICELIST_HEADER_ID     := NULL;
      l_event_offer_rec.PRICELIST_LINE_ID       := NULL;
      l_event_offer_rec.FORECASTED_REVENUE      := NULL;
      l_event_offer_rec.ACTUAL_REVENUE          := NULL;
      l_event_offer_rec.FORECASTED_COST         := NULL;
      l_event_offer_rec.ACTUAL_COST             := NULL;
      l_event_offer_rec.FUND_SOURCE_TYPE_CODE   := NULL;
      l_event_offer_rec.FUND_SOURCE_ID          := NULL;
      l_event_offer_rec.FUND_AMOUNT_FC          := NULL;
      l_event_offer_rec.FUND_AMOUNT_TC          := NULL;

      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('before req_items>'||l_event_offer_rec.event_delivery_method_id||'<');

      END IF;
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('before req_items>'||l_reference_event_rec.event_delivery_method_id||'<');
      END IF;

      AMS_UTILITY_PVT.debug_message('before calling create event offer');

      -- created the  event EONE
      -- dhsingh, 28.07.2004, Bug# 3798545.
      /*
      AMS_EventOffer_PVT.create_event_offer (
         p_api_version       => 1.0,
         p_init_msg_list     => FND_API.G_FALSE,
         p_commit            => FND_API.G_FALSE,
         p_validation_level  =>  FND_API.g_valid_level_full,
         p_evo_rec           => l_event_offer_rec,
         x_return_status     => x_return_status,
         x_msg_count         => x_msg_count,
         x_msg_data          => x_msg_data,
         x_evo_id            => l_new_event_offer_id
      );
      */
      AMS_EventOffer_PUB.create_EventOffer(
         p_api_version       => 1.0,
         p_init_msg_list     => FND_API.G_FALSE,
         p_commit            => FND_API.G_FALSE,
         p_validation_level  =>  FND_API.g_valid_level_full,
         p_evo_rec           => l_event_offer_rec,
         x_return_status     => x_return_status,
         x_msg_count         => x_msg_count,
         x_msg_data          => x_msg_data,
         x_evo_id            => l_new_event_offer_id
      );

      -- END dhsingh

      AMS_UTILITY_PVT.debug_message('after calling create event offer '||l_new_event_offer_id);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;



       /*
       AMS_EventSchedule_Copy_PVT.copy_act_delivery_method(
            p_src_act_type   => 'EONE',
            p_new_act_type   => 'EONE',
            p_src_act_id     =>  l_schedule_rec.related_event_id,
            p_new_act_id     => l_new_event_offer_id,
            p_errnum         => l_errnum,
            p_errcode        => l_errcode,
            p_errmsg         => l_errmsg
         );

      IF l_errnum > 0 THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
      */


      -- update new schedule with this id
      l_schedule_rec.related_event_from              :=  l_schedule_rec.related_event_from;
      l_schedule_rec.related_event_id                :=  l_new_event_offer_id;

      -- soagrawa 22-oct-2002 for bug# 2594717
      OPEN  c_eone_srccd(l_new_event_offer_id);
      FETCH c_eone_srccd INTO l_eone_srccd;
      CLOSE c_eone_srccd;
      l_schedule_rec.related_source_id               :=  l_new_event_offer_id;
      l_schedule_rec.related_source_code             :=  l_eone_srccd;
      l_schedule_rec.related_source_object           :=  'EONE';

   END IF;


   -- ----------------------------
   -- call create api
   -- ----------------------------
   -- dhsingh, 28.07.2004, Bug#3798545
   /*
   Create_Camp_Schedule(
       p_api_version,
       p_init_msg_list,
       p_commit,
       p_validation_level,

       x_return_status,
       x_msg_count,
       x_msg_data,

       l_schedule_rec,
       l_new_schedule_id ) ;
    */
    AMS_Camp_Schedule_PUB.create_camp_schedule(
       p_api_version,
       p_init_msg_list,
       p_commit,
       p_validation_level,

       x_return_status,
       x_msg_count,
       x_msg_data,

       l_schedule_rec,
       l_new_schedule_id ) ;
   -- END dhsingh
   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- Attributes:
   -- Event Agenda    AGEN // Leave for later
   -- Attachments     ATCH
   -- Event Category  CATG // Leave for later
   -- Market          CELL
   -- Deliverables    DELV
   -- Messages        MESG
   -- Products        PROD
   -- Partners        PTNR
   -- Registration    REGS // Leave for later
   -- Task	      TASK


   IF AMS_CpyUtility_PVT.is_copy_attribute ('AGEN', p_attributes_table) = FND_API.G_TRUE
   THEN l_attr_list.p_AGEN := 'Y';
   END IF;

   IF AMS_CpyUtility_PVT.is_copy_attribute ('ATCH', p_attributes_table) = FND_API.G_TRUE
   THEN l_attr_list.p_ATCH := 'Y';
   END IF;

   IF AMS_CpyUtility_PVT.is_copy_attribute ('CATG', p_attributes_table) = FND_API.G_TRUE
   THEN l_attr_list.p_CATG := 'Y';
   END IF;

   IF AMS_CpyUtility_PVT.is_copy_attribute ('CELL', p_attributes_table) = FND_API.G_TRUE
   THEN l_attr_list.p_CELL := 'Y';
   END IF;

   IF AMS_CpyUtility_PVT.is_copy_attribute ('DELV', p_attributes_table) = FND_API.G_TRUE
   THEN l_attr_list.p_DELV := 'Y';
   END IF;

   IF AMS_CpyUtility_PVT.is_copy_attribute ('MESG', p_attributes_table) = FND_API.G_TRUE
   THEN l_attr_list.p_MESG := 'Y';
   END IF;

   IF AMS_CpyUtility_PVT.is_copy_attribute ('PROD', p_attributes_table) = FND_API.G_TRUE
   THEN l_attr_list.p_PROD := 'Y';
   END IF;

   IF AMS_CpyUtility_PVT.is_copy_attribute ('PTNR', p_attributes_table) = FND_API.G_TRUE
   THEN l_attr_list.p_PTNR := 'Y';
   END IF;

   IF AMS_CpyUtility_PVT.is_copy_attribute ('REGS', p_attributes_table) = FND_API.G_TRUE
   THEN l_attr_list.p_REGS := 'Y';
   END IF;

   -- added by soagrawa on 25-jan-2002 bug# 2175580
   IF AMS_CpyUtility_PVT.is_copy_attribute ('CONTENT', p_attributes_table) = FND_API.G_TRUE
   THEN l_attr_list.p_CONTENT := 'Y';
   END IF;

   -- added by sodixit on 04-oct-2003 for 11.5.10. Applicable for both LITE schedules only.
   IF AMS_CpyUtility_PVT.is_copy_attribute ('TGRP', p_attributes_table) = FND_API.G_TRUE
   THEN l_attr_list.p_TGRP := 'Y';
   END IF;

   -- added by sodixit on 04-oct-2003 for 11.5.10. Applicable for both LITE and CLASSIC schedules
   -- For Classic schedules, copy of COLT will always to true - to be in sync with 11.5.9 cover letter copy
  IF  l_schedule_rec.usage = 'LITE'  then
	   IF AMS_CpyUtility_PVT.is_copy_attribute ('COLT', p_attributes_table) = FND_API.G_TRUE
	   THEN
		   l_attr_list.p_COLT := 'Y';
		   -- Debug Message
		   IF (AMS_DEBUG_HIGH_ON) THEN
			   AMS_UTILITY_PVT.debug_message('Copy Attributes, usage is LITE and COLT component is selected' );
		   END IF;
	   ELSE
		   -- Debug Message
		   IF (AMS_DEBUG_HIGH_ON) THEN
			   AMS_UTILITY_PVT.debug_message('Copy Attributes, usage is LITE but COLT component is not selected' );
		   END IF;
	   END IF;
   ELSE
	   l_attr_list.p_COLT := 'Y';
	   -- Debug Message
		   IF (AMS_DEBUG_HIGH_ON) THEN
			   AMS_UTILITY_PVT.debug_message('Copy Attributes, usage is PHAT thus setting copy COLT  to true' );
		   END IF;
   END IF;

   IF AMS_CpyUtility_PVT.is_copy_attribute ('COLT', p_attributes_table) = FND_API.G_TRUE
   THEN l_attr_list.p_COLT := 'Y';
   END IF;

   -- added by sodixit on 04-oct-2003 for 11.5.10. Applicable for LITE schedules.'OFFERING' does not exist for Classic schedules
   IF AMS_CpyUtility_PVT.is_copy_attribute ('OFFERING', p_attributes_table) = FND_API.G_TRUE
   THEN l_attr_list.p_PROD := 'Y';
   END IF;

   -- added by spragupa on 23-nov-2007 for ER 6467510 - For extending COPY functionality for TASKS
   IF AMS_CpyUtility_PVT.is_copy_attribute ('TASK', p_attributes_table) = FND_API.G_TRUE
   THEN l_attr_list.p_TASK := 'Y';
   END IF;

    Ams_CopyActivities_PVT.copy_schedule_attributes (
         p_api_version     => 1.0,
         p_init_msg_list   => FND_API.G_FALSE,
         p_commit          => FND_API.G_FALSE,
         x_return_status   => x_return_status,
         x_msg_count       => x_msg_count,
         x_msg_data        => x_msg_data,
         p_object_type     => 'CSCH',
         p_src_object_id   => p_source_object_id,
         p_tar_object_id   => l_new_schedule_id,
         p_attr_list       => l_attr_list
      );


      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


   OPEN fetch_sch_details(l_new_schedule_id);
   FETCH fetch_sch_details INTO l_new_reference_rec;
   CLOSE fetch_sch_details;

   x_new_object_id    := l_new_schedule_id;
   x_custom_setup_id  := l_new_reference_rec.custom_setup_id;


   IF FND_API.to_Boolean( p_commit )
   THEN
      COMMIT WORK;
   END IF;

   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );


 EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO COPY_Camp_Schedule_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count   => x_msg_count,
             p_data    => x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO COPY_Camp_Schedule_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count => x_msg_count,
             p_data  => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO COPY_Camp_Schedule_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count => x_msg_count,
             p_data  => x_msg_data
      );


END Copy_Camp_Schedule;

END AMS_Camp_Schedule_PVT;

/
