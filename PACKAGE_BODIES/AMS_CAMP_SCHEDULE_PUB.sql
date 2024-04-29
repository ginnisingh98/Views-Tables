--------------------------------------------------------
--  DDL for Package Body AMS_CAMP_SCHEDULE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_CAMP_SCHEDULE_PUB" as
/* $Header: amspschb.pls 120.4 2006/05/31 11:48:22 srivikri ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_Camp_Schedule_PUB
-- Purpose
--
-- History
--  18-May-2001  soagrawa   Modified schedule_rec_type according to
--                          the latest amsvschs.pls
--  22-May-2001  soagrawa   Added parameter p_validation_level to
--                          the create, update, delete and validate apis
--  19-jul-2001  ptendulk   Added columns for eBlast
--  21-Aug-2001  ptendulk   Changed the ok_to_execute call ,
--                          replaced the PRE with B and POST with A.
--  19-sep-2001  soagrawa   added copy api
--  24-sep-2001  soagrawa   Removed security group id from everywhere
--  27-jun-2003   anchaudh   Added 4 new fields(columns) in the  schedule_rec_type
--  25-aug-2003   dbiswas   Added 1 new field(sales_methodology_id) in the  schedule_rec_type
--  29-May-2006   srivikri  added column delivery_mode

-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_Camp_Schedule_PUB';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amspschb.pls';


PROCEDURE Convert_PubRec_To_PvtRec(
   p_schedule_rec_pub      IN   schedule_rec_type,
   x_schedule_rec_pvt      OUT NOCOPY  AMS_Camp_Schedule_PVT.schedule_rec_type

)

IS
   l_schedule_rec_pub      schedule_rec_type := p_schedule_rec_pub;

BEGIN

       x_schedule_rec_pvt.schedule_id                    :=  l_schedule_rec_pub.schedule_id ;
       x_schedule_rec_pvt.last_update_date               :=  l_schedule_rec_pub.last_update_date;
       x_schedule_rec_pvt.last_updated_by                :=  l_schedule_rec_pub.last_updated_by ;
       x_schedule_rec_pvt.creation_date                  :=  l_schedule_rec_pub.creation_date;
       x_schedule_rec_pvt.created_by                     :=  l_schedule_rec_pub.created_by;
       x_schedule_rec_pvt.last_update_login              :=  l_schedule_rec_pub.last_update_login;
       x_schedule_rec_pvt.object_version_number          :=  l_schedule_rec_pub.object_version_number;
       x_schedule_rec_pvt.campaign_id                    :=  l_schedule_rec_pub.campaign_id;
       x_schedule_rec_pvt.user_status_id                 :=  l_schedule_rec_pub.user_status_id;
       x_schedule_rec_pvt.status_code                    :=  l_schedule_rec_pub.status_code;
       x_schedule_rec_pvt.status_date                    :=  l_schedule_rec_pub.status_date;
       x_schedule_rec_pvt.source_code                    :=  l_schedule_rec_pub.source_code;
       x_schedule_rec_pvt.use_parent_code_flag           :=  l_schedule_rec_pub.use_parent_code_flag;
       x_schedule_rec_pvt.start_date_time                :=  l_schedule_rec_pub.start_date_time;
       x_schedule_rec_pvt.end_date_time                  :=  l_schedule_rec_pub.end_date_time;
       x_schedule_rec_pvt.timezone_id                    :=  l_schedule_rec_pub.timezone_id;
       x_schedule_rec_pvt.activity_type_code             :=  l_schedule_rec_pub.activity_type_code;
       x_schedule_rec_pvt.activity_id                    :=  l_schedule_rec_pub.activity_id;
       x_schedule_rec_pvt.arc_marketing_medium_from      :=  l_schedule_rec_pub.arc_marketing_medium_from;
       x_schedule_rec_pvt.marketing_medium_id            :=  l_schedule_rec_pub.marketing_medium_id;
       x_schedule_rec_pvt.custom_setup_id                :=  l_schedule_rec_pub.custom_setup_id;
       x_schedule_rec_pvt.triggerable_flag               :=  l_schedule_rec_pub.triggerable_flag;
       x_schedule_rec_pvt.trigger_id                     :=  l_schedule_rec_pub.trigger_id;
       x_schedule_rec_pvt.notify_user_id                 :=  l_schedule_rec_pub.notify_user_id;
       x_schedule_rec_pvt.approver_user_id               :=  l_schedule_rec_pub.approver_user_id;
       x_schedule_rec_pvt.owner_user_id                  :=  l_schedule_rec_pub.owner_user_id;
       x_schedule_rec_pvt.active_flag                    :=  l_schedule_rec_pub.active_flag;
       x_schedule_rec_pvt.cover_letter_id                :=  l_schedule_rec_pub.cover_letter_id;
       x_schedule_rec_pvt.reply_to_mail                  :=  l_schedule_rec_pub.reply_to_mail;
       x_schedule_rec_pvt.mail_sender_name               :=  l_schedule_rec_pub.mail_sender_name;
       x_schedule_rec_pvt.mail_subject                   :=  l_schedule_rec_pub.mail_subject;
       x_schedule_rec_pvt.from_fax_no                    :=  l_schedule_rec_pub.from_fax_no;
       x_schedule_rec_pvt.accounts_closed_flag           :=  l_schedule_rec_pub.accounts_closed_flag;
       x_schedule_rec_pvt.org_id                         :=  l_schedule_rec_pub.org_id;
       x_schedule_rec_pvt.objective_code                 :=  l_schedule_rec_pub.objective_code;
       x_schedule_rec_pvt.country_id                     :=  l_schedule_rec_pub.country_id;
       x_schedule_rec_pvt.campaign_calendar              :=  l_schedule_rec_pub.campaign_calendar;
       x_schedule_rec_pvt.start_period_name              :=  l_schedule_rec_pub.start_period_name;
       x_schedule_rec_pvt.end_period_name                :=  l_schedule_rec_pub.end_period_name;
       x_schedule_rec_pvt.priority                       :=  l_schedule_rec_pub.priority;
       x_schedule_rec_pvt.workflow_item_key              :=  l_schedule_rec_pub.workflow_item_key;
       x_schedule_rec_pvt.transaction_currency_code      :=  l_schedule_rec_pub.transaction_currency_code;
       x_schedule_rec_pvt.functional_currency_code       :=  l_schedule_rec_pub.functional_currency_code;
       x_schedule_rec_pvt.budget_amount_tc               :=  l_schedule_rec_pub.budget_amount_tc;
       x_schedule_rec_pvt.budget_amount_fc               :=  l_schedule_rec_pub.budget_amount_fc;
       x_schedule_rec_pvt.language_code                  :=  l_schedule_rec_pub.language_code;
       x_schedule_rec_pvt.task_id                        :=  l_schedule_rec_pub.task_id;
       x_schedule_rec_pvt.related_event_from             :=  l_schedule_rec_pub.related_event_from;
       x_schedule_rec_pvt.related_event_id               :=  l_schedule_rec_pub.related_event_id;
       x_schedule_rec_pvt.attribute_category             :=  l_schedule_rec_pub.attribute_category;
       x_schedule_rec_pvt.attribute1                     :=  l_schedule_rec_pub.attribute1;
       x_schedule_rec_pvt.attribute2                     :=  l_schedule_rec_pub.attribute2;
       x_schedule_rec_pvt.attribute3                     :=  l_schedule_rec_pub.attribute3;
       x_schedule_rec_pvt.attribute4                     :=  l_schedule_rec_pub.attribute4;
       x_schedule_rec_pvt.attribute5                     :=  l_schedule_rec_pub.attribute5;
       x_schedule_rec_pvt.attribute6                     :=  l_schedule_rec_pub.attribute6;
       x_schedule_rec_pvt.attribute7                     :=  l_schedule_rec_pub.attribute7;
       x_schedule_rec_pvt.attribute8                     :=  l_schedule_rec_pub.attribute8;
       x_schedule_rec_pvt.attribute9                     :=  l_schedule_rec_pub.attribute9;
       x_schedule_rec_pvt.attribute10                    :=  l_schedule_rec_pub.attribute10;
       x_schedule_rec_pvt.attribute11                    :=  l_schedule_rec_pub.attribute11;
       x_schedule_rec_pvt.attribute12                    :=  l_schedule_rec_pub.attribute12;
       x_schedule_rec_pvt.attribute13                    :=  l_schedule_rec_pub.attribute13;
       x_schedule_rec_pvt.attribute14                    :=  l_schedule_rec_pub.attribute14;
       x_schedule_rec_pvt.attribute15                    :=  l_schedule_rec_pub.attribute15;
       x_schedule_rec_pvt.activity_attribute_category    :=  l_schedule_rec_pub.activity_attribute_category;
       x_schedule_rec_pvt.activity_attribute1            :=  l_schedule_rec_pub.activity_attribute1;
       x_schedule_rec_pvt.activity_attribute2            :=  l_schedule_rec_pub.activity_attribute2;
       x_schedule_rec_pvt.activity_attribute3            :=  l_schedule_rec_pub.activity_attribute3;
       x_schedule_rec_pvt.activity_attribute4            :=  l_schedule_rec_pub.activity_attribute4;
       x_schedule_rec_pvt.activity_attribute5            :=  l_schedule_rec_pub.activity_attribute5;
       x_schedule_rec_pvt.activity_attribute6            :=  l_schedule_rec_pub.activity_attribute6;
       x_schedule_rec_pvt.activity_attribute7            :=  l_schedule_rec_pub.activity_attribute7;
       x_schedule_rec_pvt.activity_attribute8            :=  l_schedule_rec_pub.activity_attribute8;
       x_schedule_rec_pvt.activity_attribute9            :=  l_schedule_rec_pub.activity_attribute9;
       x_schedule_rec_pvt.activity_attribute10           :=  l_schedule_rec_pub.activity_attribute10;
       x_schedule_rec_pvt.activity_attribute11           :=  l_schedule_rec_pub.activity_attribute11;
       x_schedule_rec_pvt.activity_attribute12           :=  l_schedule_rec_pub.activity_attribute12;
       x_schedule_rec_pvt.activity_attribute13           :=  l_schedule_rec_pub.activity_attribute13;
       x_schedule_rec_pvt.activity_attribute14           :=  l_schedule_rec_pub.activity_attribute14;
       x_schedule_rec_pvt.activity_attribute15           :=  l_schedule_rec_pub.activity_attribute15;
       -- removed by soagrawa on 24-sep-2001
       -- x_schedule_rec_pvt.security_group_id              :=  l_schedule_rec_pub.security_group_id;
       x_schedule_rec_pvt.schedule_name                  :=  l_schedule_rec_pub.schedule_name;
       x_schedule_rec_pvt.description                    :=  l_schedule_rec_pub.description;
       x_schedule_rec_pvt.related_source_code            :=  l_schedule_rec_pub.related_source_code;
       x_schedule_rec_pvt.related_source_object          :=  l_schedule_rec_pub.related_source_object;
       x_schedule_rec_pvt.related_source_id              :=  l_schedule_rec_pub.related_source_id;
       x_schedule_rec_pvt.query_id                       :=  l_schedule_rec_pub.query_id;
       x_schedule_rec_pvt.include_content_flag           :=  l_schedule_rec_pub.include_content_flag;
       x_schedule_rec_pvt.content_type                   :=  l_schedule_rec_pub.content_type;
       x_schedule_rec_pvt.test_email_address             :=  l_schedule_rec_pub.test_email_address;
       x_schedule_rec_pvt.greeting_text                  :=  l_schedule_rec_pub.greeting_text;
       x_schedule_rec_pvt.footer_text                    :=  l_schedule_rec_pub.footer_text;
-- following are added by anchaudh on 27-jun-2003
       x_schedule_rec_pvt.trig_repeat_flag                 :=  l_schedule_rec_pub.trig_repeat_flag;
       x_schedule_rec_pvt.tgrp_exclude_prev_flag     :=  l_schedule_rec_pub.tgrp_exclude_prev_flag;
       x_schedule_rec_pvt.orig_csch_id                 :=  l_schedule_rec_pub.orig_csch_id;
       x_schedule_rec_pvt.cover_letter_version             :=  l_schedule_rec_pub.cover_letter_version;
-- following are added by dbiswas on 12-aug-2003
       x_schedule_rec_pvt.usage                 :=  l_schedule_rec_pub.usage;
       x_schedule_rec_pvt.purpose               :=  l_schedule_rec_pub.purpose;
       x_schedule_rec_pvt.last_activation_date  :=  l_schedule_rec_pub.last_activation_date;
       x_schedule_rec_pvt.sales_methodology_id  :=  l_schedule_rec_pub.sales_methodology_id;
       x_schedule_rec_pvt.printer_address       :=  l_schedule_rec_pub.printer_address;
       x_schedule_rec_pvt.notify_on_activation_flag :=  l_schedule_rec_pub.notify_on_activation_flag;
       x_schedule_rec_pvt.sender_display_name :=  l_schedule_rec_pub.sender_display_name;--anchaudh
       x_schedule_rec_pvt.asn_group_id :=  l_schedule_rec_pub.asn_group_id;--anchaudh for leads bug
       x_schedule_rec_pvt.delivery_mode :=  l_schedule_rec_pub.delivery_mode;

END;



PROCEDURE Create_Camp_Schedule(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER    := FND_API.g_valid_level_full,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_schedule_rec               IN   schedule_rec_type  := g_miss_schedule_rec,
    x_schedule_id                   OUT NOCOPY  NUMBER
     )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_Camp_Schedule';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_return_status  VARCHAR2(1);
l_pvt_schedule_rec    AMS_Camp_Schedule_PVT.schedule_rec_type ;
l_pub_schedule_rec    schedule_rec_type := p_schedule_rec;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_Camp_Schedule_PUB;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      AMS_UTILITY_PVT.debug_message('Public API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- convert public parameter to private-type
      Convert_PubRec_To_PvtRec(l_pub_schedule_rec,l_pvt_schedule_rec);

      -- customer pre-processing
      IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'B', 'C')
         THEN
            AMS_Camp_Schedule_CUHK.create_schedule_pre(
            l_pub_schedule_rec,
            l_return_status
           );

         IF l_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
         ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
         END IF;
      END IF;

   -- vertical industry pre-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'B', 'V')
   THEN
      AMS_Camp_Schedule_VUHK.create_schedule_pre(
         l_pub_schedule_rec,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   -- call business API

    -- Calling Private package: Create_Camp_Schedule
    -- Hint: Primary key needs to be returned
     AMS_Camp_Schedule_PVT.Create_Camp_Schedule(
     p_api_version_number         => 1.0,
     p_init_msg_list              => p_init_msg_list,
     p_commit                     => p_commit,
     p_validation_level           => p_validation_level,
     x_return_status              => x_return_status,
     x_msg_count                  => x_msg_count,
     x_msg_data                   => x_msg_data,
     p_schedule_rec               => l_pvt_schedule_rec,
     x_schedule_id                => x_schedule_id);


      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          RAISE FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      --
      -- End of API body.
      --

 -- customer post-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'A', 'C')
   THEN
      AMS_Camp_Schedule_CUHK.create_schedule_post(
         l_pub_schedule_rec,
         x_schedule_id,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   -- vertical industry post-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'A', 'V')
   THEN
      AMS_Camp_Schedule_VUHK.create_schedule_post(
         l_pub_schedule_rec,
         x_schedule_id,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;


      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      AMS_UTILITY_PVT.debug_message('Public API: ' || l_api_name || 'end');

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('AMS', 'AMS_API_RESOURCE_LOCKED');
        FND_MSG_PUB.add;
     END IF;

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO CREATE_Camp_Schedule_PUB;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_Camp_Schedule_PUB;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_Camp_Schedule_PUB;
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


PROCEDURE Update_Camp_Schedule(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER    := FND_API.g_valid_level_full,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_schedule_rec               IN    schedule_rec_type,
    x_object_version_number      OUT NOCOPY  NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Camp_Schedule';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number  NUMBER;
l_return_status  VARCHAR2(1);
l_pvt_schedule_rec  AMS_Camp_Schedule_PVT.schedule_rec_type;
l_pub_schedule_rec    schedule_rec_type := p_schedule_rec;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_Camp_Schedule_PUB;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      AMS_UTILITY_PVT.debug_message('Public API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- convert public parameter to private-type
      Convert_PubRec_To_PvtRec(l_pub_schedule_rec,l_pvt_schedule_rec);

    -- customer pre-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'B', 'C')
   THEN
      AMS_Camp_Schedule_CUHK.update_schedule_pre(
         l_pub_schedule_rec,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   -- vertical industry pre-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'B', 'V')
   THEN
      AMS_Camp_Schedule_VUHK.update_schedule_pre(
         l_pub_schedule_rec,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;


   -- call business API
    AMS_Camp_Schedule_PVT.Update_Camp_Schedule(
    p_api_version_number         => 1.0,
    p_init_msg_list              => p_init_msg_list,
    p_commit                     => p_commit,
    p_validation_level           => p_validation_level,
    x_return_status              => x_return_status,
    x_msg_count                  => x_msg_count,
    x_msg_data                   => x_msg_data,
    p_schedule_rec               => l_pvt_schedule_rec,
    x_object_version_number      => l_object_version_number );


      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          RAISE FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      --
      -- End of API body
      --

   -- vertical industry post-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'A', 'V')
   THEN
      AMS_Camp_Schedule_VUHK.update_schedule_post(
         l_pub_schedule_rec,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   -- customer post-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'A', 'C')
   THEN
      AMS_Camp_Schedule_CUHK.update_schedule_post(
         l_pub_schedule_rec,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      AMS_UTILITY_PVT.debug_message('Public API: ' || l_api_name || 'end');

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('AMS', 'AMS_API_RESOURCE_LOCKED');
        FND_MSG_PUB.add;
     END IF;

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO UPDATE_Camp_Schedule_PUB;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_Camp_Schedule_PUB;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_Camp_Schedule_PUB;
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


PROCEDURE Delete_Camp_Schedule(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER    := FND_API.g_valid_level_full,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_schedule_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Camp_Schedule';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_SCHEDULE_ID  NUMBER := p_SCHEDULE_ID;
l_object_version  NUMBER := p_object_version_number;
l_return_status  VARCHAR2(1);

l_pvt_schedule_rec  AMS_Camp_Schedule_PVT.schedule_rec_type;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_Camp_Schedule_PUB;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      AMS_UTILITY_PVT.debug_message('Public API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- customer pre-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'B', 'C')
   THEN
      AMS_Camp_Schedule_CUHK.delete_schedule_pre(
         l_SCHEDULE_ID,
         l_object_version,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   -- vertical industry pre-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'B', 'V')
   THEN
      AMS_Camp_Schedule_VUHK.delete_schedule_pre(
         l_SCHEDULE_ID,
         l_object_version,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   -- call business API
    AMS_Camp_Schedule_PVT.Delete_Camp_Schedule(
    p_api_version_number         => 1.0,
    p_init_msg_list              => p_init_msg_list,
    p_commit                     => p_commit,
    p_validation_level           => p_validation_level,
    x_return_status              => x_return_status,
    x_msg_count                  => x_msg_count,
    x_msg_data                   => x_msg_data,
    p_schedule_id                => l_schedule_id,
    p_object_version_number      => l_object_version );


      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          RAISE FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

   -- vertical industry post-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'A', 'V')
   THEN
      AMS_Camp_Schedule_VUHK.delete_schedule_post(
         l_SCHEDULE_ID,
         l_object_version,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   -- customer post-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'A', 'C')
   THEN
      AMS_Camp_Schedule_CUHK.delete_schedule_post(
         l_SCHEDULE_ID,
         l_object_version,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;



      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      AMS_UTILITY_PVT.debug_message('Public API: ' || l_api_name || 'end');

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('AMS', 'AMS_API_RESOURCE_LOCKED');
        FND_MSG_PUB.add;
     END IF;

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO DELETE_Camp_Schedule_PUB;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_Camp_Schedule_PUB;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_Camp_Schedule_PUB;
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




PROCEDURE Validate_Camp_Schedule(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
   x_return_status     OUT NOCOPY VARCHAR2,

   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,
   p_validation_mode   IN   VARCHAR2,
   p_schedule_rec      IN  schedule_rec_type
)


IS

   l_api_name       CONSTANT VARCHAR2(30) := 'Validate_Camp_Schedule';
   l_return_status  VARCHAR2(1);
   l_pvt_schedule_rec  AMS_Camp_Schedule_PVT.schedule_rec_type;
   l_pub_schedule_rec    schedule_rec_type := p_schedule_rec;

BEGIN

   SAVEPOINT validate_camp_schedule_pub;

   -- initialize the message list;
   -- won't do it again when calling private API
   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   Convert_PubRec_To_PvtRec(l_pub_schedule_rec,l_pvt_schedule_rec);

     -- customer pre-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'B', 'C')
   THEN
      AMS_Camp_Schedule_CUHK.validate_schedule_pre(
         l_pub_schedule_rec,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   -- vertical industry pre-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'B', 'V')
   THEN
      AMS_Camp_Schedule_VUHK.validate_schedule_pre(
         l_pub_schedule_rec,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   -- call business API
   AMS_Camp_Schedule_PVT.Validate_camp_schedule(
      p_api_version_number    => p_api_version,
      p_init_msg_list    => p_init_msg_list, --has done before
      p_validation_level  =>p_validation_level,
      p_schedule_rec         => l_pvt_schedule_rec,
      p_validation_mode     =>p_validation_mode,
      x_return_status    => l_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data
        );



   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;





   -- vertical industry post-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'A', 'V')
   THEN
      AMS_Camp_Schedule_VUHK.validate_schedule_post(
         l_pub_schedule_rec,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   -- customer post-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'A', 'C')
   THEN
      AMS_Camp_Schedule_CUHK.validate_schedule_post(
         l_pub_schedule_rec,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;


      -- Debug Message
      AMS_UTILITY_PVT.debug_message('Public API: ' || l_api_name || 'end');

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

EXCEPTION

   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO validate_camp_schedule_pub;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO validate_camp_schedule_pub;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );


   WHEN OTHERS THEN
      ROLLBACK TO validate_camp_schedule_pub;
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
		THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

END Validate_Camp_Schedule;


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
l_pvt_schedule_rec    AMS_Camp_Schedule_PVT.schedule_rec_type;
l_object_version         NUMBER  := p_object_version;
l_SCHEDULE_ID            NUMBER := p_schedule_id;
l_return_status  VARCHAR2(1);
 BEGIN

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
      AMS_UTILITY_PVT.debug_message('Public API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

     -- customer pre-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'B', 'C')
   THEN
      AMS_Camp_Schedule_CUHK.lock_schedule_pre(
         l_SCHEDULE_ID,
         l_object_version,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   -- vertical industry pre-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'B', 'V')
   THEN
      AMS_Camp_Schedule_VUHK.lock_schedule_pre(
         l_SCHEDULE_ID,
         l_object_version,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   -- call business API
     AMS_Camp_Schedule_PVT.Lock_Camp_Schedule(
     p_api_version_number         => 1.0,
     p_init_msg_list              => p_init_msg_list,
     x_return_status              => x_return_status,
     x_msg_count                  => x_msg_count,
     x_msg_data                   => x_msg_data,
     p_schedule_id     => p_schedule_id,
     p_object_version             => p_object_version);


      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          RAISE FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      --
      -- End of API body.
      --

   -- vertical industry post-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'A', 'V')
   THEN
      AMS_Camp_Schedule_VUHK.lock_schedule_post(
         l_SCHEDULE_ID,
         l_object_version,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   -- customer post-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'A', 'C')
   THEN
      AMS_Camp_Schedule_CUHK.lock_schedule_post(
         l_SCHEDULE_ID,
         l_object_version,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;




      -- Debug Message
      AMS_UTILITY_PVT.debug_message('Public API: ' || l_api_name || 'end');

EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('AMS', 'AMS_API_RESOURCE_LOCKED');
        FND_MSG_PUB.add;
     END IF;

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO LOCK_Camp_Schedule_PUB;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_Camp_Schedule_PUB;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO LOCK_Camp_Schedule_PUB;
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
--      18-sep-2001   soagrawa  Added, bug# 2000042
--
--
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
BEGIN

     SAVEPOINT COPY_Camp_Schedule_PUB;
AMS_UTILITY_PVT.debug_message('Public API: ' || l_api_name || 'start copy');
    -- Calling Private package: Create_Camp_Schedule
    -- Hint: Primary key needs to be returned
     AMS_Camp_Schedule_PVT.Copy_Camp_Schedule(
     p_api_version         => L_API_VERSION_NUMBER,
     p_init_msg_list              => p_init_msg_list,
     p_commit                     => p_commit,
     p_validation_level           => p_validation_level,
     x_return_status              => x_return_status,
     x_msg_count                  => x_msg_count,
     x_msg_data                   => x_msg_data,
     p_source_object_id           => p_source_object_id,
     p_attributes_table           => p_attributes_table,
     p_copy_columns_table         => p_copy_columns_table,
     x_new_object_id              => x_new_object_id,
     x_custom_setup_id            => x_custom_setup_id);
AMS_UTILITY_PVT.debug_message('Public API: ' || l_api_name || 'end copy');

      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          RAISE FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('AMS', 'AMS_API_RESOURCE_LOCKED');
        FND_MSG_PUB.add;
     END IF;

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO COPY_Camp_Schedule_PUB;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO COPY_Camp_Schedule_PUB;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO COPY_Camp_Schedule_PUB;
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

End Copy_Camp_Schedule;



END AMS_Camp_Schedule_PUB;

/
