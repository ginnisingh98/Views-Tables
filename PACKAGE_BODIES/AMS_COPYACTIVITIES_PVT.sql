--------------------------------------------------------
--  DDL for Package Body AMS_COPYACTIVITIES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_COPYACTIVITIES_PVT" AS
/* $Header: amsvcpab.pls 120.6 2007/12/26 09:33:54 spragupa ship $ */

 g_pkg_name   CONSTANT VARCHAR2(30) := 'AMS_Copyactivities_PVT';
---------------------------------------------------------------------
-- PROCEDURE
--    copy_deliverable
--
-- HISTORY
--  10/27/99  MPANDE  Created.

--  07/11/2000 SKARUMUR Modified

--  Copy Campaign: Included calls to copy Teams,Tasks ans Partners

--  Included over loaded procedures to handle logging

--  Messages.  Added 4 wrapper procedures

--  Modified campaign creation to include new columns, Changed population

--  of owner_user_id and user_status_id.  Using version to assure uniqueness
-- 17-Jul-2000 choang  Copy event header changes: 1) new owner_user_id
--                     should come from current user.  2) Forced commit
--                     in create event API call.
-- 17-Jul-2000 choang  Copy event offer changes: 1) new owner_user_id
--                     should come from current user.  2) added custom_setup_id
--                     to pass into create_eventoffer API.  3) Removed
--                     calls to create object attributes.
-- 25-Jan-2001 ptendulk  Modified Copy campaign procedure.
--                       Don't copy business units while copying campaign.
-- 17-Feb-2001 ptendulk  Added commit after each api to commit after success.
-- 21-Aug-2001 ptendulk  Modified the new campaign copy api added .
-- 05-Oct-2001 rrajesh   Modified the new campaign copy api added - to get the
--                       owner field from UI.
-- 18-OCT-2001 rrajesh   Modified attchment copy for CAMP and CSCH
--                       Added DELV and GEOS attributes to Campaign Copy
-- 22-OCT-2001 rrajesh   Bugfix: 2068786
-- 24-OCT-2001 rrajesh   fix:2072789
-- 29-OCT-2001 rrajesh   Bug fix: 2081684
-- 31-jan-2002 soagrawa  Fixed bug# 2207969 in copy_campaign_new
-- 07-feb-2002 soagrawa  Fixed bug# 2217842 in copy_campaign_new
-- 14-may-2002 mukumar   Commented act_resource_copy API since we are not supporting the resource copy
-- 07-jun-2002 aranka    Event data was not getting copied Bug #2401609
-- 13-aug-2002 soagrawa  Fixed bug# 2511347 in copy_campaign_new
-- 29-may-2003 soagrawa  Fixed bug# 2949268 in copy_schedule_Attributes
-- 05-oct-2003 sodixit   Modified copy_schedule_Attributes to copy target group and collateral for 11.5.10
-- 20-May-2004 dhsingh	 Modified copy_event_offer and copy_event_header for better performance
-- 05-Aug-2005 anchaudh  Added api for copy of collateral contents attached to the non-direct marketing activities.
-- 24-Apr-2006 vmodur    Bug 5171873 Set OVN for Copied EVEH, EVEO and EONE to 2 for DFF Copy Issue
-- 24-Dec-2007 spragupa	 ER - 6467510 - Extend Copy functionality to include TASKS for campaign schedules/activities
---------------------------------------------------------------------

   g_file_name varchar2(30) := 'amsvcpab.pls';
   AMS_DEBUG_HIGH_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE copy_event_header(
      p_api_version         IN       NUMBER,
      p_init_msg_list       IN       VARCHAR2 := fnd_api.g_false,
      x_return_status       OUT NOCOPY      VARCHAR2,
      x_msg_count           OUT NOCOPY      NUMBER,
      x_msg_data            OUT NOCOPY      VARCHAR2,
      x_eveh_id             OUT NOCOPY      NUMBER,
      p_src_eveh_id         IN       NUMBER,
      p_new_eveh_name       IN       VARCHAR2,
      p_par_eveh_id         IN       NUMBER,
      p_eveh_elements_rec   IN       eveh_elements_rec_type,
      p_start_date          IN       DATE := NULL,
      p_end_date            IN       DATE := NULL,
      x_transaction_id      OUT NOCOPY      NUMBER,
      p_source_code         IN       VARCHAR2 := NULL) IS
      BEGIN

      AMS_CPYutility_pvt.refresh_log_mesg;
          copy_event_header(
                     p_api_version        => p_api_version,
                     p_init_msg_list      => p_init_msg_list,
                     x_return_status      => x_return_status,
                     x_msg_count          => x_msg_count ,
                     x_msg_data           => x_msg_data ,
                     x_eveh_id            => x_eveh_id ,
                     p_src_eveh_id        => p_src_eveh_id,
                     p_new_eveh_name      => p_new_eveh_name,
                     p_par_eveh_id        => p_par_eveh_id,
                     p_eveh_elements_rec  => p_eveh_elements_rec,
                     p_start_date         => p_start_date,
                  p_end_date           => p_end_date ,
                     p_source_code        => p_source_code);
      AMS_CPYutility_pvt.insert_log_mesg(x_transaction_id);
     END;

  PROCEDURE copy_event_offer(
      p_api_version         IN       NUMBER,
      p_init_msg_list       IN       VARCHAR2 := fnd_api.g_false,
      x_return_status       OUT NOCOPY      VARCHAR2,
      x_msg_count           OUT NOCOPY      NUMBER,
      x_msg_data            OUT NOCOPY      VARCHAR2,
      x_eveo_id             OUT NOCOPY      NUMBER,
      p_src_eveo_id         IN       NUMBER,
      p_event_header_id     IN       NUMBER,
      p_new_eveo_name       IN       VARCHAR2 := NULL,
      p_par_eveo_id         IN       NUMBER := NULL,
      p_eveo_elements_rec   IN       eveo_elements_rec_type,
      p_start_date          IN       DATE := NULL,
      p_end_date            IN       DATE := NULL,
      x_transaction_id      OUT NOCOPY      NUMBER ,
      p_source_code         IN       VARCHAR2 :=NULL) IS
    BEGIN
         AMS_CPYutility_pvt.refresh_log_mesg;
             copy_event_offer(
                      p_api_version        => p_api_version,
                      p_init_msg_list      => p_init_msg_list,
                      x_return_status      => x_return_status,
                      x_msg_count          => x_msg_count,
                      x_msg_data           => x_msg_data,
                      x_eveo_id            => x_eveo_id,
                      p_src_eveo_id        => p_src_eveo_id,
                      p_event_header_id    => p_event_header_id,
                      p_new_eveo_name      => p_new_eveo_name,
                      p_par_eveo_id        => p_par_eveo_id,
                      p_eveo_elements_rec  => p_eveo_elements_rec,
                      p_start_date         => p_start_date,
                      p_end_date           => p_end_date,
                      p_source_code        => p_source_code   );
         AMS_CPYutility_pvt.insert_log_mesg(x_transaction_id);
     END;
   PROCEDURE copy_deliverables(
      p_api_version         IN       NUMBER,
      p_init_msg_list       IN       VARCHAR2 := fnd_api.g_false,
      x_return_status       OUT NOCOPY      VARCHAR2,
      x_msg_count           OUT NOCOPY      NUMBER,
      x_msg_data            OUT NOCOPY      VARCHAR2,
      x_deliverable_id      OUT NOCOPY      NUMBER,
      p_src_deliv_id        IN       NUMBER,
      p_new_deliv_name      IN       VARCHAR2,
      p_new_deliv_code      IN       VARCHAR2 := NULL,
      p_deli_elements_rec   IN       deli_elements_rec_type,
      p_new_version         IN       VARCHAR2,
      x_transaction_id      OUT NOCOPY      NUMBER) IS
    BEGIN
         AMS_CPYutility_pvt.refresh_log_mesg;

               copy_deliverables( p_api_version        => p_api_version,
                         p_init_msg_list      => p_init_msg_list ,
                         x_return_status      => x_return_status ,
                         x_msg_count          => x_msg_count ,
                         x_msg_data           => x_msg_data ,
                         x_deliverable_id     => x_deliverable_id,
                         p_src_deliv_id       => p_src_deliv_id ,
                         p_new_deliv_name     => p_new_deliv_name,
                         p_new_deliv_code     => p_new_deliv_code,
                         p_deli_elements_rec  => p_deli_elements_rec,
                         p_new_version        => p_new_version );

         AMS_CPYutility_pvt.insert_log_mesg(x_transaction_id);

    END;

   PROCEDURE copy_campaign(
      p_api_version         IN       NUMBER,
      p_init_msg_list       IN       VARCHAR2 := fnd_api.g_false,
      x_return_status       OUT NOCOPY      VARCHAR2,
      x_msg_count           OUT NOCOPY      NUMBER,
      x_msg_data            OUT NOCOPY      VARCHAR2,
      x_campaign_id         OUT NOCOPY      NUMBER,
      p_src_camp_id         IN       NUMBER,
      p_new_camp_name       IN       VARCHAR2 := NULL,
      p_par_camp_id         IN       NUMBER := NULL,
      p_source_code         IN       VARCHAR2 := NULL,
      p_camp_elements_rec   IN       camp_elements_rec_type,
      p_end_date            IN       DATE := NULL,
      p_start_date          IN       DATE := NULL,
    x_transaction_id      OUT NOCOPY      NUMBER) IS
    BEGIN

      AMS_CPYutility_pvt.refresh_log_mesg;

            copy_campaign( p_api_version       => p_api_version,
                      p_init_msg_list     => p_init_msg_list,
                      x_return_status     => x_return_status,
                      x_msg_count         => x_msg_count,
                      x_msg_data          => x_msg_data ,
                      x_campaign_id       => x_campaign_id,
                      p_src_camp_id       => p_src_camp_id,
                      p_new_camp_name     => p_new_camp_name,
                      p_par_camp_id       => p_par_camp_id,
                      p_source_code       => p_source_code,
                      p_camp_elements_rec => p_camp_elements_rec,
                      p_end_date          => p_end_date,
                      p_start_date        => p_start_date );

      AMS_CPYutility_pvt.insert_log_mesg(x_transaction_id);

   END;
---------------------------------------------------------------------

-- Added by rrajesh on 08/14/01
-- to support the common copy functionality

-- 21-Aug-2001   ptendulk    Modified to get data from screen
--                           Added Copy Schedule Routine.
-- 31-jan-2002   soagrawa    Fixed bug# 2207969
-- 07-feb-2002   soagrawa    Fixed bug# 2217842
-- 13-aug-2002   soagrawa    Fixed bug# 2511347
---------------------------------------------------------------------
PROCEDURE copy_campaign_new(
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

   l_api_name                  CONSTANT VARCHAR2(30) := 'copy_campaign_new';
   l_api_version_number        CONSTANT NUMBER   := 1.0;
   l_return_status_full        VARCHAR2(1);
   l_object_version_number     NUMBER := 1;
   l_org_id                    NUMBER := FND_API.G_MISS_NUM;
   l_campaign_id               NUMBER;
   l_new_campaign_id           NUMBER;
   l_dummy                     NUMBER;

   l_return_status             VARCHAR2(1);
   l_custom_setup_id           NUMBER := 1;
   l_campaign_name             VARCHAR(50);
   l_country_name              VARCHAR(50);
   l_coordinator_name          VARCHAR(50);

   l_date_number               NUMBER := 0;
   l_errnum	               NUMBER;
   l_errcode                   VARCHAR2(80);
   l_errmsg                    VARCHAR2(3000);
   l_msg_count	               NUMBER;
   l_msg_data                  VARCHAR2(2000);

   -- Added by rrajesh on 08/31/01
   l_new_schedule_id           NUMBER;
   l_tmp_schedule_id           NUMBER;
   -- soagrawa 07-feb-2002   bug# 2217842
   -- changed buffer size for the following
   x_schedule_ids              VARCHAR2(4000) := '';           --VARCHAR2(80);
   l_schedule_ids              VARCHAR2(4000) := '';           --VARCHAR2(80);
   l_index                     NUMBER := 1;
   l_length                    NUMBER;
   l_counter                   NUMBER;
   l_str_schedule_id           VARCHAR(20);
   -- end change 08/31/01

   CURSOR fetch_camp_details (camp_id NUMBER) IS
   SELECT * FROM ams_campaigns_vl
   WHERE campaign_id = camp_id ;

   l_reference_rec             fetch_camp_details%ROWTYPE;
   l_camp_rec                  ams_campaign_pvt.camp_rec_type;
   l_new_reference_rec         fetch_camp_details%ROWTYPE;

BEGIN

   -- Standard Start of API savepoint
   SAVEPOINT COPY_Camp_Common_PVT;

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

   -- Writing to PL/SQL table
   --WRITE_TO_ACT_LOG('start new copy function','CAMP',1111);

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --
   -- Start of API body
   --
   OPEN fetch_camp_details(p_source_object_id);
   FETCH fetch_camp_details INTO l_reference_rec;
   CLOSE fetch_camp_details;

   l_camp_rec.campaign_id := null;

   -- Copying Campaign Details
   -- a) Copying Fields from source Campaign Fields
   l_camp_rec.global_flag              := l_reference_rec.global_flag;
   l_camp_rec.custom_setup_id          := l_reference_rec.custom_setup_id;
   l_camp_rec.business_unit_id         := null ;
   l_camp_rec.private_flag             := l_reference_rec.private_flag;
   l_camp_rec.partner_flag             := l_reference_rec.partner_flag;
   l_camp_rec.template_flag            := l_reference_rec.template_flag;
   l_camp_rec.cascade_source_code_flag := l_reference_rec.cascade_source_code_flag;
   l_camp_rec.inherit_attributes_flag  := l_reference_rec.inherit_attributes_flag;
   l_camp_rec.rollup_type              := l_reference_rec.rollup_type;
   l_camp_rec.campaign_type            := l_reference_rec.campaign_type;
   l_camp_rec.priority                 := l_reference_rec.priority;
   l_camp_rec.fund_source_type         := l_reference_rec.fund_source_type;
   l_camp_rec.fund_source_id           := l_reference_rec.fund_source_id;
   l_camp_rec.application_id           := l_reference_rec.application_id;
   l_camp_rec.media_id                 := l_reference_rec.media_id;
   l_camp_rec.media_type_code          := l_reference_rec.media_type_code;
   l_camp_rec.transaction_currency_code:= l_reference_rec.transaction_currency_code;
   l_camp_rec.functional_currency_code :=  l_reference_rec.functional_currency_code;
   -- Bugfix: 2068786. Modified by rrajesh on 10/22/01
   --l_camp_rec.budget_amount_tc         := l_reference_rec.budget_amount_tc;
   --l_camp_rec.budget_amount_fc         := l_reference_rec.budget_amount_fc;
   l_camp_rec.budget_amount_tc         := null;
   l_camp_rec.budget_amount_fc         := null;
   -- End fix: 2068786
   l_camp_rec.event_type               := l_reference_rec.event_type;
   l_camp_rec.content_source           := l_reference_rec.content_source;
   l_camp_rec.cc_call_strategy         := l_reference_rec.cc_call_strategy;
   l_camp_rec.cc_manager_user_id       := l_reference_rec.cc_manager_user_id;
   l_camp_rec.forecasted_revenue       := l_reference_rec.forecasted_revenue;
   l_camp_rec.forecasted_cost          := l_reference_rec.forecasted_cost;
   l_camp_rec.forecasted_response      := l_reference_rec.forecasted_response;
   l_camp_rec.target_response          := l_reference_rec.target_response;
   l_camp_rec.country_code             := l_reference_rec.country_code;
   l_camp_rec.language_code            := l_reference_rec.language_code;
   l_camp_rec.attribute_category       := l_reference_rec.attribute_category;
   l_camp_rec.attribute1               := l_reference_rec.attribute1;
   l_camp_rec.attribute2               := l_reference_rec.attribute2;
   l_camp_rec.attribute3               := l_reference_rec.attribute3;
   l_camp_rec.attribute4               := l_reference_rec.attribute4;
   l_camp_rec.attribute5               := l_reference_rec.attribute5;
   l_camp_rec.attribute6               := l_reference_rec.attribute6;
   l_camp_rec.attribute7               := l_reference_rec.attribute7;
   l_camp_rec.attribute8               := l_reference_rec.attribute8;
   l_camp_rec.attribute9               := l_reference_rec.attribute9;
   l_camp_rec.attribute10              := l_reference_rec.attribute10;
   l_camp_rec.attribute11              := l_reference_rec.attribute11;
   l_camp_rec.attribute12              := l_reference_rec.attribute12;
   l_camp_rec.attribute13              := l_reference_rec.attribute13;
   l_camp_rec.attribute14              := l_reference_rec.attribute14;
   l_camp_rec.attribute15              := l_reference_rec.attribute15;
   l_camp_rec.duration                 := l_reference_rec.duration;
   l_camp_rec.duration_uom_code        := l_reference_rec.duration_uom_code;
   l_camp_rec.campaign_theme           := l_reference_rec.campaign_theme;
   l_camp_rec.description              := l_reference_rec.description;

--aranka added 06/07/02
   l_camp_rec.related_event_from       := l_reference_rec.related_event_from;
   l_camp_rec.related_event_id         := l_reference_rec.related_event_id;

   -- b)   Null fields
   l_camp_rec.start_period_name          := NULL;
   l_camp_rec.end_period_name            := NULL;
   l_camp_rec.forecasted_plan_start_date := NULL;
   l_camp_rec.forecasted_plan_end_date   := NULL;
   l_camp_rec.forecasted_exec_start_date := NULL;
   l_camp_rec.forecasted_exec_end_date   := NULL;
   l_camp_rec.actual_plan_start_date     := NULL;
   l_camp_rec.actual_plan_end_date       := NULL;
   l_camp_rec.channel_id                 := NULL;
   l_camp_rec.arc_channel_from           := NULL;

   -- c)  Fields Different between source campaign and copied campaign
   -- version to be taken from the screen: modified by soagrawa on 07-nov-2001, bug# 2082641
   -- l_camp_rec.version_no                 := l_reference_rec.version_no;
   l_camp_rec.object_version_number      := 1;
   l_camp_rec.campaign_calendar          := FND_PROFILE.value('AMS_CAMPAIGN_DEFAULT_CALENDER');
   l_camp_rec.city_id                    := TO_NUMBER(FND_PROFILE.value('AMS_SRCGEN_USER_CITY'));
   -- Following line is commented out by rrajesh on 10/05/01.
   -- getting owner from UI.
   --l_camp_rec.owner_user_id              := l_reference_rec.owner_user_id;
   l_camp_rec.user_status_id             := AMS_Utility_PVT.get_default_user_status('AMS_CAMPAIGN_STATUS','NEW');
   l_camp_rec.status_code                := 'NEW';
   l_camp_rec.status_date                := SYSDATE;

   -- l_date number is the difference between start date of source
   -- Campaign and end data of source campaign date
   l_date_number := ams_cpyutility_pvt.get_dates('CAMP',
                                                 p_source_object_id,
                                                 l_return_status);

   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR ;
   ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
   END IF;

   -- Following code is added by ptendulk on 18Aug2001
   AMS_CpyUtility_PVT.get_column_value ('newObjName', p_copy_columns_table, l_camp_rec.campaign_name);
   l_camp_rec.campaign_name := NVL (l_camp_rec.campaign_name, l_reference_rec.campaign_name);

   AMS_CpyUtility_PVT.get_column_value ('startDate', p_copy_columns_table, l_camp_rec.actual_exec_start_date);
   l_camp_rec.actual_exec_start_date := NVL (l_camp_rec.actual_exec_start_date, l_reference_rec.actual_exec_start_date);

   /* mayjain 8-Aug-2005
   -- End date of copied(new) campaign is start date(user input)+l_date_number
   l_camp_rec.actual_exec_end_date := l_camp_rec.actual_exec_start_date + l_date_number ;
   */


   AMS_CpyUtility_PVT.get_column_value ('newObjName', p_copy_columns_table, l_camp_rec.campaign_name);
   l_camp_rec.campaign_name := NVL (l_camp_rec.campaign_name, l_reference_rec.campaign_name);

   AMS_CpyUtility_PVT.get_column_value ('sourceCode', p_copy_columns_table, l_camp_rec.source_code);

   -- Getting owner value from UI. Changed by rrajesh on 10/05.
   AMS_CpyUtility_PVT.get_column_value ('ownerId', p_copy_columns_table, l_camp_rec.owner_user_id);

   -- version to be taken from the screen: modified by soagrawa on 07-nov-2001, bug# 2082641
   AMS_CpyUtility_PVT.get_column_value ('versionNum', p_copy_columns_table, l_camp_rec.version_no);
   l_camp_rec.version_no := NVL (l_camp_rec.version_no, l_reference_rec.version_no);

   /* mayjain 8-Aug-2005 */
   /* changes foe R12 */
   AMS_CpyUtility_PVT.get_column_value ('endDate', p_copy_columns_table, l_camp_rec.actual_exec_end_date);
   --l_camp_rec.actual_exec_end_date := NVL (l_camp_rec.actual_exec_end_date, l_reference_rec.actual_exec_end_date);

   AMS_CpyUtility_PVT.get_column_value ('parentCampaignId', p_copy_columns_table, l_camp_rec.parent_campaign_id);
   --l_camp_rec.parent_campaign_id := NVL (l_camp_rec.parent_campaign_id, l_reference_rec.parent_campaign_id);

   AMS_CpyUtility_PVT.get_column_value ('description', p_copy_columns_table, l_camp_rec.description);
   --l_camp_rec.description := NVL (l_camp_rec.description, l_reference_rec.description);

   AMS_CpyUtility_PVT.get_column_value ('attribute_category', p_copy_columns_table, l_camp_rec.attribute_category);
   --l_camp_rec.attribute_category := NVL (l_camp_rec.attribute_category, l_reference_rec.attribute_category);

   AMS_CpyUtility_PVT.get_column_value ('attribute1', p_copy_columns_table, l_camp_rec.attribute1);
   --l_camp_rec.attribute1 := NVL (l_camp_rec.attribute1, l_reference_rec.attribute1);

   AMS_CpyUtility_PVT.get_column_value ('attribute2', p_copy_columns_table, l_camp_rec.attribute2);
   --l_camp_rec.attribute2 := NVL (l_camp_rec.attribute2, l_reference_rec.attribute2);

   AMS_CpyUtility_PVT.get_column_value ('attribute3', p_copy_columns_table, l_camp_rec.attribute3);
   --l_camp_rec.attribute3 := NVL (l_camp_rec.attribute3, l_reference_rec.attribute3);

   AMS_CpyUtility_PVT.get_column_value ('attribute4', p_copy_columns_table, l_camp_rec.attribute4);
   --l_camp_rec.attribute4 := NVL (l_camp_rec.attribute1, l_reference_rec.attribute4);

   AMS_CpyUtility_PVT.get_column_value ('attribute5', p_copy_columns_table, l_camp_rec.attribute5);
   --l_camp_rec.attribute5 := NVL (l_camp_rec.attribute5, l_reference_rec.attribute5);

   AMS_CpyUtility_PVT.get_column_value ('attribute6', p_copy_columns_table, l_camp_rec.attribute6);
   --l_camp_rec.attribute6 := NVL (l_camp_rec.attribute6, l_reference_rec.attribute6);

   AMS_CpyUtility_PVT.get_column_value ('attribute7', p_copy_columns_table, l_camp_rec.attribute7);
   --l_camp_rec.attribute7 := NVL (l_camp_rec.attribute7, l_reference_rec.attribute7);

   AMS_CpyUtility_PVT.get_column_value ('attribute8', p_copy_columns_table, l_camp_rec.attribute8);
   --l_camp_rec.attribute8 := NVL (l_camp_rec.attribute8, l_reference_rec.attribute8);

   AMS_CpyUtility_PVT.get_column_value ('attribute9', p_copy_columns_table, l_camp_rec.attribute9);
   --l_camp_rec.attribute9 := NVL (l_camp_rec.attribute9, l_reference_rec.attribute9);

   AMS_CpyUtility_PVT.get_column_value ('attribute10', p_copy_columns_table, l_camp_rec.attribute10);
   --l_camp_rec.attribute10 := NVL (l_camp_rec.attribute10, l_reference_rec.attribute10);

   AMS_CpyUtility_PVT.get_column_value ('attribute11', p_copy_columns_table, l_camp_rec.attribute11);
   --l_camp_rec.attribute11 := NVL (l_camp_rec.attribute11, l_reference_rec.attribute11);

   AMS_CpyUtility_PVT.get_column_value ('attribute12', p_copy_columns_table, l_camp_rec.attribute12);
   --l_camp_rec.attribute12 := NVL (l_camp_rec.attribute12, l_reference_rec.attribute12);

   AMS_CpyUtility_PVT.get_column_value ('attribute13', p_copy_columns_table, l_camp_rec.attribute13);
   --l_camp_rec.attribute13 := NVL (l_camp_rec.attribute13, l_reference_rec.attribute13);

   AMS_CpyUtility_PVT.get_column_value ('attribute14', p_copy_columns_table, l_camp_rec.attribute14);
   --l_camp_rec.attribute14 := NVL (l_camp_rec.attribute14, l_reference_rec.attribute14);

   AMS_CpyUtility_PVT.get_column_value ('attribute15', p_copy_columns_table, l_camp_rec.attribute15);
   --l_camp_rec.attribute15 := NVL (l_camp_rec.attribute15, l_reference_rec.attribute15);
   /* mayjain 8-Aug-2005 */
   /* changes foe R12 */

   -- ----------------------------
   -- call create api
   -- ----------------------------
     ams_campaign_pub.create_campaign( p_api_version,
       p_init_msg_list,
       -- Bug fix: 2081684
       -- p_commit,
       FND_API.G_FALSE,
       -- End Bug fix: 2081684
       p_validation_level,
       x_return_status,
       x_msg_count,
       x_msg_data,
       l_camp_rec,
       l_new_campaign_id );

   --WRITE_TO_ACT_LOG('new campaign created successfully','CAMP',1111);

   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- Attributes:
   -- Access???
   -- Messages        MESG
   -- Attachments     ATCH
   -- Products        PROD
   -- Geo Area
   -- Association
   -- Market Segments         CELL
   -- Tasks        TASK
   -- Partners        PTNR
   -- Schedules
   -- Subcamp

   --WRITE_TO_ACT_LOG('Copy Sched Attrib'|| AMS_CpyUtility_PVT.is_copy_attribute ('CSCH', p_attributes_table), 'CAMP',1111);

   IF AMS_CpyUtility_PVT.is_copy_attribute ('CSCH', p_attributes_table) = FND_API.G_TRUE
   THEN
      IF ams_cpyutility_pvt.check_attrib_exists('CAMP', p_source_object_id ,'CSCH') = FND_API.G_TRUE -- Bug fix: 2081684
      THEN
      --Following code is modified by rrajesh on 08/31/01.
      --To copy selected schedules
      /*ams_copyelements_pvt.copy_act_schedules
                              ( p_old_camp_id    =>   p_source_object_id,
                                p_new_camp_id    =>   l_new_campaign_id,
                                p_new_start_date =>   l_camp_rec.actual_exec_start_date,
                                x_return_status  =>   l_return_status,
                                x_msg_count      =>   l_msg_count,
                                x_msg_data       =>   l_msg_data );*/

       -- Get the Schedule Ids as comma separated variables.
       IF (AMS_DEBUG_HIGH_ON) THEN

           AMS_UTILITY_PVT.debug_message('Getting scheduleid values');
       END IF;
       AMS_CpyUtility_PVT.get_column_value ('scheduleIdRec', p_copy_columns_table, x_schedule_ids);
       l_schedule_ids := NVL (x_schedule_ids, '');

       IF (AMS_DEBUG_HIGH_ON) THEN



           AMS_UTILITY_PVT.debug_message('scheduleId Rec:' || l_schedule_ids ||';');

       END IF;

	   -- added by soagrawa on 19-aug-2002
	   --if l_schedule_ids = 'undefined'
	   --then l_schedule_ids := '';
	   --end if;

       IF (AMS_DEBUG_HIGH_ON) THEN



           AMS_UTILITY_PVT.debug_message('scheduleId Rec:' || l_schedule_ids ||';');

       END IF;

       --WRITE_TO_ACT_LOG('Schedule Id Rec:'|| l_schedule_ids ,'CAMP',1111);



       -- Separate comma separated l_schedule_ids to number values and use for copy
       l_counter := 0;

             LOOP
                 l_length := nvl(LENGTH(nvl(l_schedule_ids,'')),0);
                 EXIT WHEN l_length = 0;
                 l_index := INSTR(l_schedule_ids,',');

                 --WRITE_TO_ACT_LOG('index:'|| l_index ,'CAMP',1111);
                 IF l_index = 0 THEN
                    IF  l_length > 0 THEN
                       l_tmp_schedule_id := TO_NUMBER(l_schedule_ids);
                       l_schedule_ids := '';
                    END IF;
                 ELSE
                    l_str_schedule_id := SUBSTR(l_schedule_ids, 1, l_index-1);
                    l_tmp_schedule_id := TO_NUMBER(l_str_schedule_id);
                 END IF;
                 IF l_tmp_schedule_id IS NOT NULL
                 THEN
                    --WRITE_TO_ACT_LOG('calling schedule copy for schedule id:' || l_tmp_schedule_id ,'CAMP',1111);
                    IF (AMS_DEBUG_HIGH_ON) THEN

                        AMS_UTILITY_PVT.debug_message('calling schedule copy for schedule id:' || l_tmp_schedule_id);
                    END IF;
                    ams_copyelements_pvt.copy_selected_schedule
                                    ( p_old_camp_id    =>   p_source_object_id,
                                      p_new_camp_id    =>   l_new_campaign_id,
                                      p_old_schedule_id=>   l_tmp_schedule_id,
                                      p_new_start_date =>   l_camp_rec.actual_exec_start_date,
                                      p_new_end_date   =>   l_camp_rec.actual_exec_end_date,
                                      x_return_status  =>   l_return_status,
                                      x_msg_count      =>   l_msg_count,
                                      x_msg_data       =>   l_msg_data );
                    --WRITE_TO_ACT_LOG('return status from ams_copyelements_pvt.copy_campaign_schedules'||x_return_status||':'||l_new_schedule_id,'CAMP',1111);
                 END IF;
                 -- EXIT WHEN LENGTH(l_schedule_ids) = 0;
                 l_schedule_ids := SUBSTR(l_schedule_ids, l_index+1);
                 l_counter := l_counter + 1;
             END LOOP;
             -- end modification. 08/31/01

   END IF; -- Bug fix: 2081684

   END IF;
   --WRITE_TO_ACT_LOG('schedules copied succesfully','CAMP',1111);
   IF AMS_CpyUtility_PVT.is_copy_attribute ('MESG', p_attributes_table) = FND_API.G_TRUE
   THEN
      IF ams_cpyutility_pvt.check_attrib_exists('CAMP', p_source_object_id ,'MESG') = FND_API.G_TRUE -- Bug fix: 2081684
      THEN
      ams_copyelements_pvt.copy_act_messages
                              ( p_src_act_type  =>'CAMP',
                                p_src_act_id    =>p_source_object_id,
                                p_new_act_id    =>l_new_campaign_id,
                                p_errnum        =>l_errnum,
                                p_errcode       =>l_errcode,
                                p_errmsg        =>l_errmsg);
      END IF;
   END IF;
   IF AMS_CpyUtility_PVT.is_copy_attribute ('ATCH', p_attributes_table) = FND_API.G_TRUE
   THEN
      -- modified by soagrawa on 31-jan-2002   bug#  2207969
      IF ams_cpyutility_pvt.check_attrib_exists('AMS_CAMP', p_source_object_id ,'ATCH') = FND_API.G_TRUE -- Bug fix: 2081684
      -- IF ams_cpyutility_pvt.check_attrib_exists('CAMP', p_source_object_id ,'ATCH') = FND_API.G_TRUE -- Bug fix: 2081684
      THEN
      -- Modified by rrajesh on 10/18/01
      /*ams_copyelements_pvt.copy_act_attachments
                              ( p_src_act_type  =>'CAMP',
                                p_src_act_id    =>p_source_object_id,
                                p_new_act_id    =>l_new_campaign_id,
                                p_errnum        =>l_errnum,
                                p_errcode       =>l_errcode,
                                p_errmsg        =>l_errmsg); */
      ams_copyelements_pvt.copy_act_attachments
                              ( p_src_act_type  =>'AMS_CAMP',
                                p_src_act_id    =>p_source_object_id,
                                p_new_act_id    =>l_new_campaign_id,
                                p_errnum        =>l_errnum,
                                p_errcode       =>l_errcode,
                                p_errmsg        =>l_errmsg);
      -- end change 10/18/01
      END IF;
   END IF;
   -- Added by rrajesh on 10/18/01
   IF AMS_CpyUtility_PVT.is_copy_attribute ('GEOS', p_attributes_table) = FND_API.G_TRUE
   THEN
       IF ams_cpyutility_pvt.check_attrib_exists('CAMP', p_source_object_id ,'GEOS') = FND_API.G_TRUE -- Bug fix: 2081684
       THEN
       ams_copyelements_pvt.copy_act_geo_areas
                            ( p_src_act_type   => 'CAMP',
                              p_src_act_id     => p_source_object_id,
                              p_new_act_id     => l_new_campaign_id,
                              p_errnum         => l_errnum,
                              p_errcode        => l_errcode,
                              p_errmsg         => l_errmsg);
       END IF;
   END IF;
   IF AMS_CpyUtility_PVT.is_copy_attribute ('DELV', p_attributes_table) = FND_API.G_TRUE
   THEN
       IF ams_cpyutility_pvt.check_attrib_exists('CAMP', p_source_object_id ,'DELV') = FND_API.G_TRUE -- Bug fix: 2081684
       THEN
       ams_copyelements_pvt.copy_object_associations
                            ( p_src_act_type   => 'CAMP',
                              p_src_act_id     =>p_source_object_id,
                              p_new_act_id     =>l_new_campaign_id,
                              p_errnum         => l_errnum,
                              p_errcode        => l_errcode,
                              p_errmsg         => l_errmsg);
       END IF;
   END IF;

   -- end change 10/18/01
   IF AMS_CpyUtility_PVT.is_copy_attribute ('PROD', p_attributes_table) = FND_API.G_TRUE
   THEN
       IF ams_cpyutility_pvt.check_attrib_exists('CAMP', p_source_object_id ,'PROD') = FND_API.G_TRUE -- Bug fix: 2081684
       THEN
       ams_copyelements_pvt.copy_act_prod
                            ( p_src_act_type   => 'CAMP',
                              p_src_act_id     =>p_source_object_id,
                              p_new_act_id     =>l_new_campaign_id,
                              p_errnum         => l_errnum,
                              p_errcode        => l_errcode,
                              p_errmsg         => l_errmsg);
       END IF;
   END IF;
   IF AMS_CpyUtility_PVT.is_copy_attribute ('CELL', p_attributes_table) = FND_API.G_TRUE
   THEN
       IF ams_cpyutility_pvt.check_attrib_exists('CAMP', p_source_object_id ,'CELL') = FND_API.G_TRUE -- Bug fix: 2081684
       THEN
       ams_copyelements_pvt.copy_act_market_segments
                                     ( p_src_act_type =>'CAMP',
                                       p_src_act_id   =>p_source_object_id,
                                       p_new_act_id   =>l_new_campaign_id,
                                       p_errnum       =>l_errnum,
                                       p_errcode      =>l_errcode,
                                       p_errmsg       =>l_errmsg);
      END IF;
   END IF;
   IF AMS_CpyUtility_PVT.is_copy_attribute ('PTNR', p_attributes_table) = FND_API.G_TRUE
   THEN
        IF ams_cpyutility_pvt.check_attrib_exists('CAMP', p_source_object_id ,'PTNR') = FND_API.G_TRUE -- Bug fix: 2081684
        THEN
        -- Bug fix:2072789
        /*ams_copyelements_pvt.copy_partners
                                  (p_init_msg_list        => fnd_api.g_true,
                                   p_api_version          => l_api_version_number,
                                   x_return_status        => l_return_status,
                                   x_msg_count            => l_msg_count,
                                   x_msg_data             => l_msg_data,
                                   p_old_camp_id          =>p_source_object_id,
                                   p_new_camp_id          =>l_new_campaign_id); */
        ams_copyelements_pvt.copy_partners
                                  (p_api_version          => l_api_version_number,
                                   p_init_msg_list        => fnd_api.g_true,
                                   x_return_status        => l_return_status,
                                   x_msg_count            => l_msg_count,
                                   x_msg_data             => l_msg_data,
                                   p_old_camp_id          =>p_source_object_id,
                                   p_new_camp_id          =>l_new_campaign_id);
        -- End fix:fix:2072789
        END IF;
   END IF;

   OPEN fetch_camp_details(l_new_campaign_id);
   FETCH fetch_camp_details INTO l_new_reference_rec;
   CLOSE fetch_camp_details;

   x_new_object_id    := l_new_campaign_id;
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
   --WRITE_TO_ACT_LOG('All attributes copied succesfully','CAMP',1111);
 EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO COPY_Camp_Common_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count   => x_msg_count,
             p_data    => x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO COPY_Camp_Common_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count => x_msg_count,
             p_data  => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO COPY_Camp_Common_PVT;
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

END;
-----------------------------------------------------------------------
   PROCEDURE copy_deliverables(
      p_api_version         IN       NUMBER,
      p_init_msg_list       IN       VARCHAR2 := fnd_api.g_false,
      x_return_status       OUT NOCOPY      VARCHAR2,
      x_msg_count           OUT NOCOPY      NUMBER,
      x_msg_data            OUT NOCOPY      VARCHAR2,
      x_deliverable_id      OUT NOCOPY      NUMBER,
      p_src_deliv_id        IN       NUMBER,
      p_new_deliv_name      IN       VARCHAR2,
      p_new_deliv_code      IN       VARCHAR2 := NULL,
      p_deli_elements_rec   IN       deli_elements_rec_type,
      p_new_version         IN       VARCHAR2)
   IS
      l_api_version   CONSTANT NUMBER       := 1.0;
      l_api_name      CONSTANT VARCHAR2(30) := 'copy_deliverable';
      l_full_name     CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
      l_return_status          VARCHAR2(1);
      l_new_deliv_name         ams_deliverables_vl.deliverable_name%TYPE;
      l_deli_count             NUMBER;
      l_name                   VARCHAR2(80);
      l_msg_count              NUMBER;
      l_msg_data               VARCHAR2(512);
      l_new_deliv_id           NUMBER;
      l_deli_rec               ams_deliverable_pvt.deliv_rec_type;
      l_mesg_text              VARCHAR2(2000);
      p_errmsg                 VARCHAR2(3000);
      l_deliv_rec              ams_deliverables_vl%ROWTYPE;
      l_errcode                VARCHAR2(80);
      l_errnum                 NUMBER;
      l_errmsg                 VARCHAR2(3000);
      l_deliv_count            NUMBER;
      l_lookup_meaning         VARCHAR2(80);
      l_counter                NUMBER;

      CURSOR c_deliv_name(l_deliv_name IN VARCHAR2)
      IS
         SELECT COUNT(*)   --deliverable_name
           FROM ams_deliverables_vl
          WHERE deliverable_name = l_deliv_name;
   BEGIN
      SAVEPOINT copy_deliverables;
      IF (AMS_DEBUG_HIGH_ON) THEN

          ams_utility_pvt.debug_message(l_full_name || ': start');
      END IF;

      IF fnd_api.to_boolean(p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

      IF NOT fnd_api.compatible_api_call(
            l_api_version,
            p_api_version,
            l_api_name,
            g_pkg_name)
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      x_return_status := fnd_api.g_ret_sts_success;
      ----------------------- insert -----------------------
      IF (AMS_DEBUG_HIGH_ON) THEN

          ams_utility_pvt.debug_message(l_full_name || ': copy');
      END IF;

      BEGIN
         ams_utility_pvt.get_lookup_meaning(
            'AMS_SYS_ARC_QUALIFIER',
            'DELV',
            l_return_status,
            l_lookup_meaning);
         --  General Message saying copying has started
         fnd_message.set_name('AMS', 'AMS_COPY_ELEMENTS');
         fnd_message.set_token('ELEMENTS', l_lookup_meaning, TRUE);
         l_mesg_text := fnd_message.get;
         -- Writing to the Pl/SQLtable
         ams_cpyutility_pvt.write_log_mesg('DELV', p_src_deliv_id,
                                            l_mesg_text, 'GENERAL');
         l_return_status := NULL;
         l_msg_count := 0;
         l_msg_data := NULL;
         -- selects the deliverable to copy
         SELECT *
           INTO l_deliv_rec
           FROM ams_deliverables_vl
         WHERE  deliverable_id = p_src_deliv_id;
         l_deli_rec.object_version_number := 1;
         l_deli_rec.owner_user_id := fnd_global.user_id;
         l_deli_rec.status_date := SYSDATE;
         l_deli_rec.deliverable_code := p_new_deliv_code;
         l_deli_rec.version := 1.0;
         l_deli_rec.language_code := l_deliv_rec.language_code;
         l_deli_rec.application_id := l_deliv_rec.application_id;
         l_deli_rec.actual_avail_from_date := l_deliv_rec.actual_avail_from_date;
         l_deli_rec.actual_avail_to_date := l_deliv_rec.actual_avail_to_date;
         l_deli_rec.fund_source_id := NULL;   ---functionally cannot copy
         l_deli_rec.fund_source_type := NULL;   -----functionally cannot copy
         l_deli_rec.category_type_id := NULL;   ---functionally cannot copy
         l_deli_rec.category_sub_type_id := NULL;   ---functionally cannot copy
         l_deli_rec.can_fulfill_electronic_flag := 'N';
         l_deli_rec.can_fulfill_physical_flag := 'N';
         l_deli_rec.actual_avail_from_date := NULL;
         l_deli_rec.actual_avail_to_date := NULL;
         l_deli_rec.chargeback_amount := NULL;
         l_deli_rec.chargeback_amount_curr_code := NULL;
         l_deli_rec.non_inv_quantity_on_hand := NULL;
         l_deli_rec.non_inv_quantity_on_order := NULL;
         l_deli_rec.non_inv_quantity_on_reserve := NULL;
         l_deli_rec.budget_amount_tc := NULL;
         l_deli_rec.budget_amount_fc := NULL;
         l_deli_rec.actual_cost := NULL;
         l_deli_rec.deliverable_pick_flag := 'N';
         l_deli_rec.actual_responses := NULL;
         l_deli_rec.inventory_flag := l_deliv_rec.inventory_flag;
         l_deli_rec.transaction_currency_code :=
                                  l_deliv_rec.transaction_currency_code;
         l_deli_rec.functional_currency_code :=
                                  l_deliv_rec.functional_currency_code;
         -- if the kit flag is on then copy the flag and copy the kits
         l_deli_rec.kit_flag := p_deli_elements_rec.p_kitflag;
         l_deli_rec.inventory_item_id := l_deliv_rec.inventory_item_id;
         l_deli_rec.inventory_item_org_id := l_deliv_rec.inventory_item_org_id;
         l_deli_rec.non_inv_ctrl_code := l_deliv_rec.non_inv_ctrl_code;
         l_deli_rec.currency_code := l_deliv_rec.currency_code;
         l_deli_rec.forecasted_cost := l_deliv_rec.forecasted_cost;
         l_deli_rec.forecasted_responses := l_deliv_rec.forecasted_responses;
         l_deli_rec.country := l_deliv_rec.country;
         l_deli_rec.attribute_category := l_deliv_rec.attribute_category;
         l_deli_rec.attribute1 := l_deliv_rec.attribute1;
         l_deli_rec.attribute2 := l_deliv_rec.attribute2;
         l_deli_rec.attribute3 := l_deliv_rec.attribute3;
         l_deli_rec.attribute4 := l_deliv_rec.attribute4;
         l_deli_rec.attribute5 := l_deliv_rec.attribute5;
         l_deli_rec.attribute6 := l_deliv_rec.attribute6;
         l_deli_rec.attribute7 := l_deliv_rec.attribute7;
         l_deli_rec.attribute8 := l_deliv_rec.attribute8;
         l_deli_rec.attribute9 := l_deliv_rec.attribute9;
         l_deli_rec.attribute10 := l_deliv_rec.attribute10;
         l_deli_rec.attribute11 := l_deliv_rec.attribute11;
         l_deli_rec.attribute12 := l_deliv_rec.attribute12;
         l_deli_rec.attribute13 := l_deliv_rec.attribute13;
         l_deli_rec.attribute14 := l_deliv_rec.attribute14;
         l_deli_rec.attribute15 := l_deliv_rec.attribute15;

         -- checks if deliv name is  null
         IF p_new_deliv_name IS NULL
         THEN
            fnd_message.set_name('AMS', 'AMS_COPY_NAME');
            l_new_deliv_name := fnd_message.get;
            l_new_deliv_name :=
                               SUBSTRB(l_new_deliv_name ||
                                       l_deliv_rec.deliverable_name, 1, 240);
         ELSE
            l_new_deliv_name := p_new_deliv_name;
         END IF;
         -- checks if deilv of that name exists-------
         l_counter := 0;

         LOOP
            l_counter := l_counter + 1;
            OPEN c_deliv_name(l_new_deliv_name);
            FETCH c_deliv_name INTO l_deliv_count;
            EXIT WHEN l_deliv_count = 0;
            l_deli_rec.deliverable_name :=
               SUBSTRB(l_new_deliv_name || '-' || l_counter, 1, 240);
            l_new_deliv_name := l_deli_rec.deliverable_name;
            CLOSE c_deliv_name;
         END LOOP;
---- IF DELIV NAME IS NEW THEN PUT THAT ---------------------------
         l_deli_rec.deliverable_name := SUBSTR(l_new_deliv_name, 1, 240);
-------------calling create delivrable-------------
         ams_deliverable_pvt.create_deliverable(
            p_api_version => l_api_version,
            x_return_status => l_return_status,
            x_msg_count => l_msg_count,
            x_msg_data => l_msg_data,
            x_deliv_id => l_new_deliv_id,
            p_deliv_rec => l_deli_rec);
         x_deliverable_id := l_new_deliv_id;

         IF l_return_status = fnd_api.g_ret_sts_error
             OR l_return_status = fnd_api.g_ret_sts_unexp_error
         THEN
            FOR l_counter IN 1 .. l_msg_count
            LOOP
              l_mesg_text := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
              p_errmsg := SUBSTR( l_mesg_text || ',): ' || l_counter ||
                                 ' OF ' || l_msg_count, 1, 3000);
              ams_cpyutility_pvt.write_log_mesg( 'DELV',
                                                 p_src_deliv_id,
                                                 p_errmsg,
                                                 'ERROR');
            END LOOP;
            fnd_message.set_name('AMS', 'AMS_COPY_ERROR2');
            fnd_message.set_token('ELEMENTS', l_lookup_meaning, TRUE);
            l_mesg_text := fnd_message.get;
            p_errmsg := SUBSTR( l_mesg_text || ' - ' ||
                                ams_utility_pvt.get_object_name( 'DELV',
                                                 l_deli_rec.deliverable_id),
                                1, 4000);
            ams_cpyutility_pvt.write_log_mesg('DELV',
                                         p_src_deliv_id, p_errmsg, 'ERROR');
            IF l_return_status = fnd_api.g_ret_sts_error  then
               RAISE fnd_api.g_exc_error;
            ELSE
               RAISE fnd_api.g_exc_unexpected_error;
            END IF;
         END IF;
      END;

      IF x_return_status = fnd_api.g_ret_sts_success
      THEN
         IF p_deli_elements_rec.p_attachments = 'Y'
         THEN
            l_errcode := NULL;
            l_errnum := 0;
            l_errmsg := NULL;
            ams_copyelements_pvt.copy_act_attachments(
                        p_src_act_type => 'DELV',
                        p_src_act_id   => p_src_deliv_id,
                        p_new_act_id   => l_new_deliv_id,
                        p_errnum       => l_errnum,
                        p_errcode      => l_errcode,
                        p_errmsg       => l_errmsg);
         END IF;
-- If the user wants to copy access then the access flag should be 'Y' (Yes)
         IF p_deli_elements_rec.p_products = 'Y'
         THEN
            l_errcode := NULL;
            l_errnum := 0;
            l_errmsg := NULL;

            ams_copyelements_pvt.copy_act_prod(
                         p_src_act_type => 'DELV',
                         p_src_act_id   => p_src_deliv_id,
                         p_new_act_id   => l_new_deliv_id,
                         p_errnum       => l_errnum,
                         p_errcode      => l_errcode,
                         p_errmsg       => l_errmsg);
         END IF;
-- If the user wants to copy access then the access flag should be 'Y' (Yes)

         IF p_deli_elements_rec.p_access = 'Y'
         THEN
            l_errcode := NULL;
            l_errnum := 0;
            l_errmsg := NULL;
            ams_copyelements_pvt.copy_act_access(
                     p_src_act_type => 'DELV',
                     p_src_act_id   => p_src_deliv_id,
                     p_new_act_id   => l_new_deliv_id,
                     p_errnum       => l_errnum,
                     p_errcode      => l_errcode,
                     p_errmsg       => l_errmsg);
      END IF;

         IF p_deli_elements_rec.p_kitflag = 'Y'
         THEN
            l_errcode := NULL;
            l_errnum := 0;
            l_errmsg := NULL;
            ams_copyelements_pvt.copy_deliv_kits( p_src_deliv_id,
                                      l_new_deliv_id,
                                      l_errnum,
                                      l_errcode,
                                      l_errmsg);
         END IF;
         -- If the user wants to copy geo_areas then the geo_area flag
         -- should be 'Y' (Yes)
         IF p_deli_elements_rec.p_geo_areas = 'Y'
         THEN
            l_errcode := NULL;
            l_errnum := 0;
            l_errmsg := NULL;
            ams_copyelements_pvt.copy_act_geo_areas(
                      p_src_act_type => 'DELV',
                      p_src_act_id   => p_src_deliv_id,
                      p_new_act_id   => l_new_deliv_id,
                      p_errnum       => l_errnum,
                      p_errcode      => l_errcode,
                      p_errmsg       => l_errmsg);
          END IF;
          -- If the user wants to copy object_associatiosn then the
          -- obj_asso flag should be 'Y' (Yes).It will copy all the
          -- associations of the deliverable
         IF p_deli_elements_rec.p_obj_asso = 'Y'
         THEN
            l_errcode := NULL;
            l_errnum := 0;
            l_errmsg := NULL;
            ams_copyelements_pvt.copy_object_associations(
                      p_src_act_type => 'DELV',
                      p_src_act_id   => p_src_deliv_id,
                      p_new_act_id   => l_new_deliv_id,
                      p_errnum       => l_errnum,
                      p_errcode      => l_errcode,
                      p_errmsg       => l_errmsg);
         END IF;
      END IF;

      IF   l_return_status  =  FND_API.G_RET_STS_SUCCESS  THEN
         COMMIT ;
      END IF ;

      IF (AMS_DEBUG_HIGH_ON) THEN



          ams_utility_pvt.debug_message(l_full_name || ': end');

      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO copy_deliverables;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get(
            p_encoded => fnd_api.g_false,
            p_count => x_msg_count,
            p_data => x_msg_data);
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO copy_deliverables;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get(
            p_encoded => fnd_api.g_false,
            p_count => x_msg_count,
            p_data => x_msg_data);
      WHEN OTHERS
      THEN
         ROLLBACK TO copy_deliverables;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get(
            p_encoded => fnd_api.g_false,
            p_count => x_msg_count,
            p_data => x_msg_data);
   END copy_deliverables;



   PROCEDURE copy_event_offer(
      p_api_version         IN       NUMBER,
      p_init_msg_list       IN       VARCHAR2 := fnd_api.g_false,
      x_return_status       OUT NOCOPY      VARCHAR2,
      x_msg_count           OUT NOCOPY      NUMBER,
      x_msg_data            OUT NOCOPY      VARCHAR2,
      x_eveo_id             OUT NOCOPY      NUMBER,
      p_src_eveo_id         IN       NUMBER,
      p_event_header_id     IN       NUMBER,
      p_new_eveo_name       IN       VARCHAR2 := NULL,
      p_par_eveo_id         IN       NUMBER := NULL,
      p_eveo_elements_rec   IN       eveo_elements_rec_type,
      p_start_date          IN       DATE := NULL,
      p_end_date            IN       DATE := NULL,
      p_source_code         IN       VARCHAR2 := NUll)
   IS
      l_api_version   CONSTANT NUMBER       := 1.0;
      l_api_name      CONSTANT VARCHAR2(30) := 'copy_event_offer';
      l_full_name     CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
      l_return_status          VARCHAR2(1);
      l_eveo_ele_rec           eveo_elements_rec_type;
      l_name                   VARCHAR2(80);
      l_msg_count              NUMBER;
      l_msg_data               VARCHAR2(512);
      --   l_new_camp_id  NUMBER;
      l_eveo_rec               ams_eventoffer_pvt.evo_rec_type;
      l_mesg_text              VARCHAR2(2000);
      p_errmsg                 VARCHAR2(3000);
      l_eventoffer_rec         ams_event_offers_vl%ROWTYPE;
      l_errcode                VARCHAR2(80);
      l_errnum                 NUMBER;
      l_errmsg                 VARCHAR2(3000);
      l_eveo_elements_rec      eveo_elements_rec_type;
      x_sub_eveo_id            NUMBER;
      l_new_eveo_name          ams_event_offers_vl.event_offer_name%TYPE;
      l_eveo_count             NUMBER;
      l_lookup_meaning         VARCHAR2(80);
      l_counter                NUMBER;
      l_date_number            NUMBER;
      l_custom_setup_id        NUMBER;

      CURSOR sub_eveo_cur
      IS
         SELECT   event_offer_id
         FROM     ams_event_offers_vl
         WHERE  parent_event_offer_id = p_src_eveo_id;

      CURSOR c_eveo_name(l_eveo_name IN VARCHAR2)
      IS
--	 modified by dhsingh on 20.05.2004 for bug# 3631107
--         SELECT   COUNT(*)
--         FROM     ams_event_offers_vl
--         WHERE  event_offer_name = l_eveo_name;
	SELECT   COUNT(*)
	FROM     ams_event_offers_all_tl
	WHERE  event_offer_name = l_eveo_name;
--	end of modification by dhsingh

      CURSOR c_obj_attr
      IS
         SELECT   custom_setup_id
         FROM     ams_object_attributes
         WHERE  object_id = p_src_eveo_id
            AND object_type = 'EVEO';
   BEGIN
      SAVEPOINT copy_event_offer;
      IF (AMS_DEBUG_HIGH_ON) THEN

          ams_utility_pvt.debug_message(l_full_name || ': start');
      END IF;

      IF fnd_api.to_boolean(p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

      IF NOT fnd_api.compatible_api_call(
            l_api_version,
            p_api_version,
            l_api_name,
            g_pkg_name)
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      x_return_status := fnd_api.g_ret_sts_success;
      ----------------------- insert -----------------------
      IF (AMS_DEBUG_HIGH_ON) THEN

          ams_utility_pvt.debug_message(l_full_name || ': start');
      END IF;

      BEGIN
         ams_utility_pvt.get_lookup_meaning(
            'AMS_SYS_ARC_QUALIFIER',
            'EVEO',
            l_return_status,
            l_lookup_meaning);
--  General Message saying copying has started
         fnd_message.set_name('AMS', 'AMS_COPY_ELEMENTS');
         fnd_message.set_token('ELEMENTS', l_lookup_meaning, TRUE);
         l_mesg_text := fnd_message.get;
-- Writing to the Pl/SQLtable
         ams_cpyutility_pvt.write_log_mesg('EVEO', p_src_eveo_id, l_mesg_text, 'GENERAL');
         l_return_status := NULL;
         l_msg_count := 0;
         l_msg_data := NULL;
-- selects the event offers to copy
         SELECT   *
         INTO     l_eventoffer_rec
         FROM     ams_event_offers_vl
         WHERE  event_offer_id = p_src_eveo_id;
         l_eveo_rec.object_version_number := 2; -- Bug 5171873 cannot be 1

         l_eveo_rec.application_id := l_eventoffer_rec.application_id;
         l_eveo_rec.event_header_id := p_event_header_id;
         l_eveo_rec.private_flag := l_eventoffer_rec.private_flag;

         IF p_par_eveo_id IS NULL
         THEN
            l_eveo_rec.event_level := 'MAIN';
         ELSE
            l_eveo_rec.event_level := 'SUB';
         END IF;

         l_eveo_rec.user_status_id := 100;
         l_eveo_rec.system_status_code := 'NEW';
         l_eveo_rec.event_type_code := l_eventoffer_rec.event_type_code;
         l_eveo_rec.event_delivery_method_id :=
                                      l_eventoffer_rec.event_delivery_method_id;
         l_eveo_rec.event_required_flag := l_eventoffer_rec.event_required_flag;
         l_eveo_rec.event_language_code := l_eventoffer_rec.event_language_code;
         l_eveo_rec.event_location_id := l_eventoffer_rec.event_location_id;
         l_eveo_rec.overflow_flag := l_eventoffer_rec.overflow_flag;
         l_eveo_rec.partner_flag := l_eventoffer_rec.partner_flag;
         l_eveo_rec.event_standalone_flag :=
                                      l_eventoffer_rec.event_standalone_flag;
         l_eveo_rec.reg_required_flag := 'Y';
                                       --l_eventoffer_rec.reg_required_flag;
         l_eveo_rec.reg_charge_flag := l_eventoffer_rec.reg_charge_flag;
         l_eveo_rec.reg_invited_only_flag :=
                                      l_eventoffer_rec.reg_invited_only_flag;
         l_eveo_rec.reg_waitlist_allowed_flag :=
            l_eventoffer_rec.reg_waitlist_allowed_flag;
         l_eveo_rec.reg_overbook_allowed_flag :=
            l_eventoffer_rec.reg_overbook_allowed_flag;
         l_eveo_rec.parent_event_offer_id := p_par_eveo_id;
         l_eveo_rec.event_duration := l_eventoffer_rec.event_duration;
         l_eveo_rec.event_duration_uom_code :=
                              l_eventoffer_rec.event_duration_uom_code;

         IF p_start_date IS NOT NULL
         THEN
            l_eveo_rec.event_start_date := p_start_date;
         END IF;

         l_date_number :=
            ams_cpyutility_pvt.get_dates('EVEO',
                                         p_src_eveo_id, l_return_status);

         IF l_eventoffer_rec.event_end_date IS NOT NULL
         THEN
            l_eveo_rec.event_end_date := p_start_date + l_date_number;
         END IF;

         l_eveo_rec.event_start_date_time :=
                         l_eventoffer_rec.event_start_date_time;
         l_eveo_rec.event_end_date_time := l_eventoffer_rec.event_end_date_time;
         l_eveo_rec.reg_maximum_capacity :=
                          l_eventoffer_rec.reg_maximum_capacity;
         l_eveo_rec.reg_overbook_pct := l_eventoffer_rec.reg_overbook_pct;
         l_eveo_rec.reg_effective_capacity :=
                              l_eventoffer_rec.reg_effective_capacity;
         l_eveo_rec.reg_waitlist_pct := l_eventoffer_rec.reg_waitlist_pct;
         l_eveo_rec.reg_minimum_capacity :=
                          l_eventoffer_rec.reg_minimum_capacity;
         -- l_eveo_rec.REG_MINIMUM_REQ_BY_DATE   DATE,
         -- l_eveo_rec.INVENTORY_ITEM_ID         NUMBER,
         l_eveo_rec.organization_id := l_eventoffer_rec.organization_id;
         -- l_eveo_rec.PRICELIST_HEADER_ID       NUMBER,
         -- l_eveo_rec.PRICELIST_LINE_ID         NUMBER,
         l_eveo_rec.org_id := l_eventoffer_rec.org_id;
         l_eveo_rec.waitlist_action_type_code :=
            l_eventoffer_rec.waitlist_action_type_code;
         l_eveo_rec.stream_type_code := l_eventoffer_rec.stream_type_code;
         -- l_eveo_rec.owner_user_id :=     l_eventoffer_rec.owner_user_id;
         l_eveo_rec.owner_user_id :=
			AMS_Utility_PVT.get_resource_id (FND_GLOBAL.user_id);
       -- changed again because eventsAPI has chaged--101;

         l_eveo_rec.event_full_flag := 'N';
         l_eveo_rec.source_code := p_source_code;
        -- l_eveo_rec.FORECASTED_REVENUE
        -- l_eveo_rec.ACTUAL_REVENUE
        -- l_eveo_rec.FORECASTED_COST
        -- l_eveo_rec.ACTUAL_COST
        -- l_eveo_rec.FUND_SOURCE_TYPE_CODE
        -- l_eveo_rec.FUND_SOURCE_ID
         l_eveo_rec.cert_credit_type_code :=
                         l_eventoffer_rec.cert_credit_type_code;
         l_eveo_rec.certification_credits :=
                         l_eventoffer_rec.certification_credits;
         l_eveo_rec.coordinator_id := l_eventoffer_rec.coordinator_id;
         l_eveo_rec.priority_type_code := l_eventoffer_rec.priority_type_code;
         -- l_eveo_rec.CANCELLATION_REASON_CODE
         l_eveo_rec.auto_register_flag := l_eventoffer_rec.auto_register_flag;
         l_eveo_rec.email := l_eventoffer_rec.email;
         l_eveo_rec.phone := l_eventoffer_rec.phone;
         -- l_eveo_rec.FUND_AMOUNT_TC            NUMBER,
         -- l_eveo_rec.FUND_AMOUNT_FC            NUMBER,
         -- l_eveo_rec.CURRENCY_CODE_TC          VARCHAR2(15),
         -- l_eveo_rec.CURRENCY_CODE_FC          VARCHAR2(15),
         l_eveo_rec.url := l_eventoffer_rec.url;
         l_eveo_rec.timezone_id := l_eventoffer_rec.timezone_id;
         l_eveo_rec.event_venue_id := l_eventoffer_rec.event_venue_id;
         -- l_eveo_rec.PRICELIST_HEADER_CURRENCY_CODE VARCHAR2(30),
         -- l_eveo_rec.PRICELIST_LIST_PRICE     NUMBER,
         l_eveo_rec.inbound_script_name := l_eventoffer_rec.inbound_script_name;
         l_eveo_rec.attribute_category := l_eventoffer_rec.attribute_category;
         l_eveo_rec.attribute1 := l_eventoffer_rec.attribute1;
         l_eveo_rec.attribute2 := l_eventoffer_rec.attribute2;
         l_eveo_rec.attribute3 := l_eventoffer_rec.attribute3;
         l_eveo_rec.attribute4 := l_eventoffer_rec.attribute4;
         l_eveo_rec.attribute5 := l_eventoffer_rec.attribute5;
         l_eveo_rec.attribute6 := l_eventoffer_rec.attribute6;
         l_eveo_rec.attribute7 := l_eventoffer_rec.attribute7;
         l_eveo_rec.attribute8 := l_eventoffer_rec.attribute8;
         l_eveo_rec.attribute9 := l_eventoffer_rec.attribute9;
         l_eveo_rec.attribute10 := l_eventoffer_rec.attribute10;
         l_eveo_rec.attribute11 := l_eventoffer_rec.attribute11;
         l_eveo_rec.attribute12 := l_eventoffer_rec.attribute12;
         l_eveo_rec.attribute13 := l_eventoffer_rec.attribute13;
         l_eveo_rec.attribute14 := l_eventoffer_rec.attribute14;
         l_eveo_rec.attribute15 := l_eventoffer_rec.attribute15;

         -- choang - 13-Jul-2000
         -- Added custom_setup_id
         OPEN c_obj_attr;
         FETCH c_obj_attr INTO l_custom_setup_id;
         CLOSE c_obj_attr;
         l_eveo_rec.custom_setup_id := l_custom_setup_id;

         IF p_new_eveo_name IS NULL
         THEN
            fnd_message.set_name('AMS', 'AMS_COPY_NAME');
            l_new_eveo_name := fnd_message.get;
            l_new_eveo_name :=
               SUBSTRB(l_new_eveo_name ||
                       l_eventoffer_rec.event_offer_name, 1, 240);
         ELSE
            l_new_eveo_name := SUBSTRB(p_new_eveo_name, 1, 240);
         END IF;
-- checks if camp of that name exists-------
         l_counter := 0;

         LOOP
            l_counter := l_counter + 1;
            OPEN c_eveo_name(l_new_eveo_name);
            FETCH c_eveo_name INTO l_eveo_count;
            EXIT WHEN l_eveo_count = 0;
            l_eveo_rec.event_offer_name :=
               SUBSTRB(l_new_eveo_name || '-' || l_counter, 1, 240);
            l_new_eveo_name := l_eveo_rec.event_offer_name;
            CLOSE c_eveo_name;
         END LOOP;
        ---- IF eveo NAME IS NEW THEN PUT THAT ---------------------------
         l_eveo_rec.event_offer_name := l_new_eveo_name;
        /* IF   p_par_camp_id = NULL THEN
                     l_campaign_rec.parent_campaign_id  :=  NULL;
          ElSE
                     l_campaign_rec.parent_campaign_id  := p_par_camp_id;
          END IF;*/

         ams_eventoffer_pvt.create_event_offer(
            p_api_version => l_api_version,
            p_init_msg_list => fnd_api.g_true,
            p_commit => FND_API.g_true,
            x_return_status => l_return_status,
            x_msg_count => l_msg_count,
            x_msg_data => l_msg_data,
            x_evo_id => x_eveo_id,
            p_evo_rec => l_eveo_rec);

         IF l_return_status = fnd_api.g_ret_sts_error
             OR l_return_status = fnd_api.g_ret_sts_unexp_error
         THEN
           FOR l_counter IN 1 .. l_msg_count LOOP
              l_mesg_text := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
              p_errmsg := SUBSTR( l_mesg_text || '): ' || l_counter || ' OF ' ||
                                 l_msg_count, 1, 3000);
              ams_cpyutility_pvt.write_log_mesg( 'EVEO',
                                                 p_src_eveo_id,
                                                 p_errmsg,
                                                 'ERROR');
            END LOOP;
            ---- if error then right a copy log message to the log table
            fnd_message.set_name('AMS', 'AMS_COPY_ERROR2');
            fnd_message.set_token('ELEMENTS', l_lookup_meaning, TRUE);
            l_mesg_text := fnd_message.get;
            p_errmsg := SUBSTR( l_mesg_text || ' - ' ||
            ams_utility_pvt.get_object_name('EVEO', p_src_eveo_id),
                                             1, 4000);
            ams_cpyutility_pvt.write_log_mesg('EVEO',
                                              p_src_eveo_id,
                                              p_errmsg,
                                              'ERROR');
            --  Is failed write a copy failed message in the log table
            IF l_return_status = fnd_api.g_ret_sts_error then
               RAISE fnd_api.g_exc_error;
            ELSE
               RAISE fnd_api.g_exc_unexpected_error;
            END IF;
         END IF;
      END;
      -- If the user wants to copy objectives then the objectives
      -- flag should be 'Y' (Yes)
      IF x_return_status = fnd_api.g_ret_sts_success
      THEN
         IF p_eveo_elements_rec.p_messages = 'Y'
         THEN
            l_errcode := NULL;
            l_errnum := 0;
            l_errmsg := NULL;
            ams_copyelements_pvt.copy_act_messages(
                          p_src_act_type => 'EVEO',
                          p_src_act_id   => p_src_eveo_id,
                          p_new_act_id   => x_eveo_id,
                          p_errnum       => l_errnum,
                          p_errcode      => l_errcode,
                          p_errmsg       => l_errmsg);
         END IF;
         -- If the user wants to copy access then the access flag
         -- should be 'Y' (Yes)
         IF p_eveo_elements_rec.p_products = 'Y'
         THEN
            l_errcode := NULL;
            l_errnum := 0;
            l_errmsg := NULL;
            ams_copyelements_pvt.copy_act_prod(
               p_src_act_type => 'EVEO',
               p_src_act_id   => p_src_eveo_id,
               p_new_act_id   => x_eveo_id,
               p_errnum       => l_errnum,
               p_errcode      => l_errcode,
               p_errmsg       => l_errmsg);
         END IF;
         -- If the user wants to copy geo_areas then the geo_area
         -- flag should be 'Y' (Yes)
         IF p_eveo_elements_rec.p_geo_areas = 'Y'
         THEN
            l_errcode := NULL;
            l_errnum := 0;
            l_errmsg := NULL;
            ams_copyelements_pvt.copy_act_geo_areas(
               p_src_act_type => 'EVEO',
               p_src_act_id   => p_src_eveo_id,
               p_new_act_id   => x_eveo_id,
               p_errnum       => l_errnum,
               p_errcode      => l_errcode,
               p_errmsg       => l_errmsg);
         END IF;
         -- If the user wants to copy object_associatiosn then the
         -- obj_asso flag should be 'Y' (Yes).It will copy all the
         -- associations of the campaign
         IF p_eveo_elements_rec.p_obj_asso = 'Y'
         THEN
            l_errcode := NULL;
            l_errnum := 0;
            l_errmsg := NULL;
            ams_copyelements_pvt.copy_object_associations(
               p_src_act_type => 'EVEO',
               p_src_act_id   => p_src_eveo_id,
               p_new_act_id   => x_eveo_id,
               p_errnum       => l_errnum,
               p_errcode      => l_errcode,
               p_errmsg       => l_errmsg);
         END IF;
         -- If the user wants to copy resources then the
         -- resources flag should be 'Y' (Yes)
/*Commented by mukemar on may14 2002 we are not supporting the resource copy
     IF p_eveo_elements_rec.p_resources = 'Y'
         THEN
            l_errcode := NULL;
            l_errnum := 0;
            l_errmsg := NULL;
            ams_copyelements_pvt.copy_act_resources(
                     p_src_act_type => 'EVEO',
                     p_src_act_id   => p_src_eveo_id,
                     p_new_act_id   => x_eveo_id,
                     p_errnum       => l_errnum,
                     p_errcode      => l_errcode,
                     p_errmsg       => l_errmsg);
         END IF;
*/
	 /*
         IF p_eveo_elements_rec.p_offers = 'Y'
         THEN
            l_errcode := NULL;
            l_errnum := 0;
            l_errmsg := NULL;
            ams_copyelements_pvt.copy_act_offers(
                     p_src_act_type => 'EVEO',
                     p_src_act_id   => p_src_eveo_id,
                     p_new_act_id   => x_eveo_id,
                     p_errnum       => l_errnum,
                     p_errcode      => l_errcode,
                     p_errmsg       => l_errmsg);
          END IF;  */
         -- If the user wants to copy geo_areas then the
         -- geo_area flag should be 'Y' (Yes)
         IF p_eveo_elements_rec.p_segments = 'Y'
         THEN
            l_errcode := NULL;
            l_errnum := 0;
            l_errmsg := NULL;
            ams_copyelements_pvt.copy_act_market_segments(
                     p_src_act_type => 'EVEO',
                     p_src_act_id   => p_src_eveo_id,
                     p_new_act_id   => x_eveo_id,
                     p_errnum       => l_errnum,
                     p_errcode      => l_errcode,
                     p_errmsg       => l_errmsg);
         END IF;
         IF p_eveo_elements_rec.p_attachments = 'Y'
         THEN
            l_errcode := NULL;
            l_errnum := 0;
            l_errmsg := NULL;
            ams_copyelements_pvt.copy_act_attachments(
                     p_src_act_type => 'EVEO',
                     p_src_act_id   => p_src_eveo_id,
                     p_new_act_id   => x_eveo_id,
                     p_errnum       => l_errnum,
                     p_errcode      => l_errcode,
                     p_errmsg       => l_errmsg);
         END IF;

         IF p_eveo_elements_rec.p_sub_eveo = 'Y'
         THEN
            FOR sub_eveo_rec IN sub_eveo_cur
            LOOP
               BEGIN
                  l_return_status := NULL;
                  l_msg_count := 0;
                  l_msg_data := NULL;
                  copy_event_offer(
                     p_api_version => 1,
                     p_init_msg_list => fnd_api.g_true,
                     x_return_status => l_return_status,
                     x_msg_data => l_msg_data,
                     x_msg_count => l_msg_count,
                     p_src_eveo_id => sub_eveo_rec.event_offer_id,
                     p_event_header_id => p_event_header_id,
                     p_new_eveo_name => NULL,
                     p_par_eveo_id => x_eveo_id,
                     x_eveo_id => x_sub_eveo_id,
                     p_eveo_elements_rec => l_eveo_elements_rec,
                     p_start_date => p_start_date);
               END;
            END LOOP;
         END IF;
      END IF;

      IF   l_return_status  =  FND_API.G_RET_STS_SUCCESS  THEN
         COMMIT ;
      END IF ;

   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO copy_event_offer;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get(
            p_encoded => fnd_api.g_false,
            p_count => x_msg_count,
            p_data => x_msg_data);
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO copy_event_offer;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         IF (AMS_DEBUG_HIGH_ON) THEN

             ams_utility_pvt.debug_message(l_full_name || ': debug');
         END IF;
         fnd_msg_pub.count_and_get(
            p_encoded => fnd_api.g_false,
            p_count => x_msg_count,
            p_data => x_msg_data);
      WHEN OTHERS
      THEN
         ROLLBACK TO copy_event_offer;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get(
            p_encoded => fnd_api.g_false,
            p_count => x_msg_count,
            p_data => x_msg_data);
   END copy_event_offer;


   PROCEDURE copy_event_header(
      p_api_version         IN       NUMBER,
      p_init_msg_list       IN       VARCHAR2 := fnd_api.g_false,
      x_return_status       OUT NOCOPY      VARCHAR2,
      x_msg_count           OUT NOCOPY      NUMBER,
      x_msg_data            OUT NOCOPY      VARCHAR2,
      x_eveh_id             OUT NOCOPY      NUMBER,
      p_src_eveh_id         IN       NUMBER,
      p_new_eveh_name       IN       VARCHAR2,
      p_par_eveh_id         IN       NUMBER := NULL,
      p_eveh_elements_rec   IN       eveh_elements_rec_type,
      p_start_date          IN       DATE := NULL,
      p_end_date            IN       DATE := NULL,
      p_source_code         IN       VARCHAR2:= NULL )
   IS
      l_api_version   CONSTANT NUMBER        := 1.0;
      l_api_name      CONSTANT VARCHAR2(30)  := 'copy_event_header';
      l_full_name     CONSTANT VARCHAR2(60)  := g_pkg_name || '.' || l_api_name;
      l_return_status          VARCHAR2(1);
      l_eveh_ele_rec           eveh_elements_rec_type;   --:= p_camp_rec;
      l_name                   VARCHAR2(80);
      l_msg_count              NUMBER;
      l_msg_data               VARCHAR2(512);
--   l_new_camp_id  NUMBER;
      l_eveh_rec               ams_eventheader_pvt.evh_rec_type;
      l_mesg_text              VARCHAR2(2000);
      p_errmsg                 VARCHAR2(3000);
      l_eventheader_rec        ams_event_headers_vl%ROWTYPE;
      l_errcode                VARCHAR2(80);
      l_errnum                 NUMBER;
      l_errmsg                 VARCHAR2(3000);
      l_eveh_elements_rec      eveh_elements_rec_type;
      l_eveo_elements_rec      eveo_elements_rec_type;
      x_sub_eveh_id            NUMBER;
      l_new_eveh_name          ams_event_headers_vl.event_header_name%TYPE;
      l_eveh_count             NUMBER;
      l_lookup_meaning         VARCHAR2(80);
      x_eventoffer_id          NUMBER;
      l_counter                NUMBER;
      l_date_number            NUMBER;
      l_custom_setup_id        NUMBER;

      CURSOR sub_eveh_cur IS
      SELECT event_header_id
        FROM ams_event_headers_vl
       WHERE parent_event_header_id = p_src_eveh_id;

      CURSOR c_eveh_name(l_eveh_name IN VARCHAR2) IS
--	modified by dhsingh on 20.05.2004 for bug# 3631107
--      SELECT COUNT(*)
--        FROM ams_event_headers_vl
--       WHERE event_header_name = l_eveh_name;
	SELECT COUNT(*)
	FROM ams_event_headers_all_tl
	WHERE event_header_name = l_eveh_name ;
--	end of modification by dhsingh

      CURSOR sub_eveo_cur IS
      SELECT event_offer_id
        FROM ams_event_offers_vl
       WHERE event_header_id = p_src_eveh_id;

      CURSOR c_obj_attr IS
      SELECT custom_setup_id
        FROM ams_object_attributes
       WHERE object_id = p_src_eveh_id
         AND object_type = 'EVEH';
   BEGIN
      SAVEPOINT copy_event_header;
      IF (AMS_DEBUG_HIGH_ON) THEN

          ams_utility_pvt.debug_message(l_full_name || ': start');
      END IF;

      IF fnd_api.to_boolean(p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

      IF NOT fnd_api.compatible_api_call(
            l_api_version,
            p_api_version,
            l_api_name,
            g_pkg_name)
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      x_return_status := fnd_api.g_ret_sts_success;
      ----------------------- insert -----------------------
      IF (AMS_DEBUG_HIGH_ON) THEN

          ams_utility_pvt.debug_message(l_full_name || ': start');
      END IF;

      BEGIN
         ams_utility_pvt.get_lookup_meaning( 'AMS_SYS_ARC_QUALIFIER',
                                             'EVEH',
                                             l_return_status,
                                             l_lookup_meaning);
--  General Message saying copying has started
         fnd_message.set_name('AMS', 'AMS_COPY_ELEMENTS');
         fnd_message.set_token('ELEMENTS', l_lookup_meaning, TRUE);
         l_mesg_text := fnd_message.get;
-- Writing to the Pl/SQLtable
         ams_cpyutility_pvt.write_log_mesg('EVEH',
                                           p_src_eveh_id,
                                           l_mesg_text,
                                           'GENERAL');
         l_return_status := NULL;
         l_msg_count := 0;
         l_msg_data := NULL;
-- selects the event offers to copy
         SELECT *
           INTO l_eventheader_rec
           FROM ams_event_headers_vl
          WHERE event_header_id = p_src_eveh_id;
         l_eveh_rec.object_version_number := 2; -- Bug 5171873 cannot be 1

         l_eveh_rec.application_id := l_eventheader_rec.application_id;
         l_eveh_rec.private_flag := l_eventheader_rec.private_flag;

         IF p_par_eveh_id IS NULL
         THEN
            l_eveh_rec.event_level := 'MAIN';
         ELSE
            l_eveh_rec.event_level := 'SUB';
         END IF;

         l_eveh_rec.stream_type_code := l_eventheader_rec.stream_type_code;
         l_eveh_rec.event_type_code := l_eventheader_rec.event_type_code;
         l_eveh_rec.overflow_flag := l_eventheader_rec.overflow_flag;
         l_eveh_rec.partner_flag := l_eventheader_rec.partner_flag;
         l_eveh_rec.event_standalone_flag :=  l_eventheader_rec.event_standalone_flag;
         l_eveh_rec.reg_required_flag := l_eventheader_rec.reg_required_flag;
         l_eveh_rec.reg_charge_flag := l_eventheader_rec.reg_charge_flag;
         l_eveh_rec.reg_invited_only_flag := l_eventheader_rec.reg_invited_only_flag;
         l_eveh_rec.parent_event_header_id := p_par_eveh_id;
         l_eveh_rec.duration := l_eventheader_rec.duration;
         l_eveh_rec.duration_uom_code := l_eventheader_rec.duration_uom_code;
         l_eveh_rec.source_code :=  p_source_code;

         -- get the custom_setup_id to determine
         -- the attributes the new copy of event
         -- headers will have.
         OPEN c_obj_attr;
         FETCH c_obj_attr INTO l_custom_setup_id;
         -- Let the event header api handle validation of custom_setup_id.
         CLOSE c_obj_attr;

    IF p_start_date IS NOT NULL
         THEN
            l_eveh_rec.active_from_date := p_start_date;
         END IF;

         l_date_number :=
            ams_cpyutility_pvt.get_dates('EVEH',
                                         p_src_eveh_id,
                                         l_return_status);

         IF l_eventheader_rec.active_to_date IS NOT NULL
         THEN
            l_eveh_rec.active_to_date := p_start_date + l_date_number;
         END IF;

         l_eveh_rec.reg_maximum_capacity :=
                              l_eventheader_rec.reg_maximum_capacity;
         l_eveh_rec.reg_minimum_capacity :=
                              l_eventheader_rec.reg_minimum_capacity;
         l_eveh_rec.org_id := l_eventheader_rec.org_id;
         l_eveh_rec.stream_type_code := l_eventheader_rec.stream_type_code;
         -- l_eveh_rec.owner_user_id := l_eventheader_rec.owner_user_id;
         l_eveh_rec.owner_user_id := AMS_Utility_PVT.get_resource_id (FND_GLOBAL.user_id);

         l_eveh_rec.user_status_id := 1;
         l_eveh_rec.system_status_code := 'NEW';
         l_eveh_rec.cert_credit_type_code :=
                               l_eventheader_rec.cert_credit_type_code;
         l_eveh_rec.certification_credits :=
                               l_eventheader_rec.certification_credits;
         l_eveh_rec.coordinator_id := l_eventheader_rec.coordinator_id;
         l_eveh_rec.priority_type_code := l_eventheader_rec.priority_type_code;
         l_eveh_rec.email := l_eventheader_rec.email;
         l_eveh_rec.phone := l_eventheader_rec.phone;
         l_eveh_rec.url := l_eventheader_rec.url;
         l_eveh_rec.inbound_script_name :=
                              l_eventheader_rec.inbound_script_name;
         l_eveh_rec.attribute_category := l_eventheader_rec.attribute_category;
         l_eveh_rec.attribute1 := l_eventheader_rec.attribute1;
         l_eveh_rec.attribute2 := l_eventheader_rec.attribute2;
         l_eveh_rec.attribute3 := l_eventheader_rec.attribute3;
         l_eveh_rec.attribute4 := l_eventheader_rec.attribute4;
         l_eveh_rec.attribute5 := l_eventheader_rec.attribute5;
         l_eveh_rec.attribute6 := l_eventheader_rec.attribute6;
         l_eveh_rec.attribute7 := l_eventheader_rec.attribute7;
         l_eveh_rec.attribute8 := l_eventheader_rec.attribute8;
         l_eveh_rec.attribute9 := l_eventheader_rec.attribute9;
         l_eveh_rec.attribute10 := l_eventheader_rec.attribute10;
         l_eveh_rec.attribute11 := l_eventheader_rec.attribute11;
         l_eveh_rec.attribute12 := l_eventheader_rec.attribute12;
         l_eveh_rec.attribute13 := l_eventheader_rec.attribute13;
         l_eveh_rec.attribute14 := l_eventheader_rec.attribute14;
         l_eveh_rec.attribute15 := l_eventheader_rec.attribute15;

         l_eveh_rec.custom_setup_id := l_custom_setup_id;

         IF p_new_eveh_name IS NULL
         THEN
            fnd_message.set_name('AMS', 'AMS_COPY_NAME');
            l_new_eveh_name := fnd_message.get;
            l_new_eveh_name :=
              SUBSTRB(l_new_eveh_name ||
                      l_eventheader_rec.event_header_name, 1, 240);
         ELSE
            l_new_eveh_name := SUBSTRB(p_new_eveh_name, 1, 240);
         END IF;
         -- checks if camp of that name exists-------
         l_counter := 1;
         LOOP
            l_counter := l_counter + 1;
            OPEN c_eveh_name(l_new_eveh_name);
            FETCH c_eveh_name INTO l_eveh_count;
            EXIT WHEN l_eveh_count = 0;
            l_eveh_rec.event_header_name :=
               SUBSTRB(l_new_eveh_name || '-' || l_counter, 1, 240);
            l_new_eveh_name := l_eveh_rec.event_header_name;
            CLOSE c_eveh_name;
         END LOOP;
         ---- IF eveh NAME IS NEW THEN PUT THAT ---------------------------
         l_eveh_rec.event_header_name := l_new_eveh_name;
/*        IF   p_par_camp_id = NULL THEN
                     l_campaign_rec.parent_campaign_id  :=  NULL;
          ElSE
                     l_campaign_rec.parent_campaign_id  := p_par_camp_id;
          END IF;*/

         ams_eventheader_pvt.create_event_header(
            p_api_version => l_api_version,
            p_init_msg_list => fnd_api.g_true,
            p_commit => FND_API.g_true,
            x_return_status => l_return_status,
            x_msg_count => l_msg_count,
            x_msg_data => l_msg_data,
            x_evh_id => x_eveh_id,
            p_evh_rec => l_eveh_rec);

         IF l_return_status = fnd_api.g_ret_sts_error
             OR l_return_status = fnd_api.g_ret_sts_unexp_error
         THEN
            FOR l_counter IN 1 .. l_msg_count LOOP
                l_mesg_text := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
                p_errmsg := SUBSTR( l_mesg_text || '): ' || l_counter ||
                                    ' OF ' || l_msg_count, 1, 3000);
                ams_cpyutility_pvt.write_log_mesg( 'EVEH',
                                                   p_src_eveh_id,
                                                   p_errmsg,
                                                   'ERROR');
            END LOOP;
            fnd_message.set_name('AMS', 'AMS_COPY_ERROR2');
            fnd_message.set_token('ELEMENTS', l_lookup_meaning, TRUE);
            l_mesg_text := fnd_message.get;
            p_errmsg := SUBSTR( l_mesg_text || ' - ' ||
                           ams_utility_pvt.get_object_name('EVEH',
                             p_src_eveh_id), 1, 4000);
            ams_cpyutility_pvt.write_log_mesg('EVEH',
                                              p_src_eveh_id,
                                              p_errmsg,
                                              'ERROR');
           --  Is failed write a copy failed message in the log table
            IF l_return_status = fnd_api.g_ret_sts_error then
               RAISE fnd_api.g_exc_error;
            ELSE
               RAISE fnd_api.g_exc_unexpected_error;
            END IF;
         END IF;
      END;
      -- If the user wants to copy objectives then the
      -- objectives flag should be 'Y' (Yes)
      IF x_return_status = fnd_api.g_ret_sts_success
      THEN
         IF p_eveh_elements_rec.p_messages = 'Y'
         THEN
            l_errcode := NULL;
            l_errnum := 0;
            l_errmsg := NULL;
            ams_copyelements_pvt.copy_act_messages(
                        p_src_act_type => 'EVEH',
                        p_src_act_id   => p_src_eveh_id,
                        p_new_act_id   => x_eveh_id,
                        p_errnum       => l_errnum,
                        p_errcode      => l_errcode,
                        p_errmsg       => l_errmsg);
         END IF;
-- If the user wants to copy access then the access flag should be 'Y' (Yes)
         IF p_eveh_elements_rec.p_products = 'Y'
         THEN
            l_errcode := NULL;
            l_errnum := 0;
            l_errmsg := NULL;
            ams_copyelements_pvt.copy_act_prod(
                            p_src_act_type => 'EVEH',
                            p_src_act_id   => p_src_eveh_id,
                            p_new_act_id   => x_eveh_id,
                            p_errnum       => l_errnum,
                            p_errcode      => l_errcode,
                            p_errmsg       => l_errmsg);
          END IF;
          -- If the user wants to copy geo_areas then
          -- the geo_area flag should be 'Y' (Yes)
         IF p_eveh_elements_rec.p_geo_areas = 'Y'
         THEN
            l_errcode := NULL;
            l_errnum := 0;
            l_errmsg := NULL;
            ams_copyelements_pvt.copy_act_geo_areas(
                        p_src_act_type => 'EVEH',
                        p_src_act_id   => p_src_eveh_id,
                        p_new_act_id   => x_eveh_id,
                        p_errnum       => l_errnum,
                        p_errcode      => l_errcode,
                        p_errmsg       => l_errmsg);
         END IF;
-- If the user wants to copy object_associatiosn then the
-- obj_asso flag should be 'Y' (Yes).It will copy all the
-- associations of the campaign
         IF p_eveh_elements_rec.p_obj_asso = 'Y'
         THEN
            l_errcode := NULL;
            l_errnum := 0;
            l_errmsg := NULL;
            ams_copyelements_pvt.copy_object_associations(
                          p_src_act_type => 'EVEH',
                          p_src_act_id   => p_src_eveh_id,
                          p_new_act_id   => x_eveh_id,
                          p_errnum       => l_errnum,
                          p_errcode      => l_errcode,
                          p_errmsg       => l_errmsg);
         END IF;
         -- If the user wants to copy resources then the
         -- resources flag should be 'Y' (Yes)
/*Commented by mukemar on may14 2002 we are not supporting the resource copy
	 IF p_eveh_elements_rec.p_resources = 'Y'
         THEN
            l_errcode := NULL;
            l_errnum := 0;
            l_errmsg := NULL;
            ams_copyelements_pvt.copy_act_resources(
                           p_src_act_type => 'EVEH',
                           p_src_act_id   => p_src_eveh_id,
                           p_new_act_id   => x_eveh_id,
                           p_errnum       => l_errnum,
                           p_errcode      => l_errcode,
                           p_errmsg       => l_errmsg);
         END IF;
*/
	    /*
         IF p_eveh_elements_rec.p_offers = 'Y'
         THEN
            l_errcode := NULL;
            l_errnum := 0;
            l_errmsg := NULL;
            ams_copyelements_pvt.copy_act_offers(
                           p_src_act_type => 'EVEH',
                           p_src_act_id   => p_src_eveh_id,
                           p_new_act_id   => x_eveh_id,
                           p_errnum       => l_errnum,
                           p_errcode      => l_errcode,
                           p_errmsg       => l_errmsg);
          END IF;  */
         -- If the user wants to copy geo_areas then the geo_area
         -- flag should be 'Y' (Yes)
         IF p_eveh_elements_rec.p_segments = 'Y'
         THEN
            l_errcode := NULL;
            l_errnum := 0;
            l_errmsg := NULL;
            ams_copyelements_pvt.copy_act_market_segments(
                   p_src_act_type => 'EVEH',
                   p_src_act_id   => p_src_eveh_id,
                   p_new_act_id   => x_eveh_id,
                   p_errnum       => l_errnum,
                   p_errcode      => l_errcode,
                   p_errmsg       => l_errmsg);
         END IF;

         IF p_eveh_elements_rec.p_attachments = 'Y'
         THEN
            l_errcode := NULL;
            l_errnum := 0;
            l_errmsg := NULL;
            ams_copyelements_pvt.copy_act_attachments(
                     p_src_act_type => 'EVEH',
                     p_src_act_id   => p_src_eveh_id,
                     p_new_act_id   => x_eveh_id,
                     p_errnum       => l_errnum,
                     p_errcode      => l_errcode,
                     p_errmsg       => l_errmsg);
         END IF;

         IF p_eveh_elements_rec.p_sub_eveh = 'Y'
         THEN
            FOR sub_eveh_rec IN sub_eveh_cur
            LOOP
               BEGIN
                  l_return_status := NULL;
                  l_msg_count := 0;
                  l_msg_data := NULL;
                  copy_event_header(
                     p_api_version => 1,
                     p_init_msg_list => fnd_api.g_true,
                     x_return_status => l_return_status,
                     x_msg_data => l_msg_data,
                     x_msg_count => l_msg_count,
                     p_src_eveh_id => sub_eveh_rec.event_header_id,
                     p_new_eveh_name => NULL,
                     p_par_eveh_id => x_eveh_id,
                     x_eveh_id => x_sub_eveh_id,
                     p_eveh_elements_rec => l_eveh_elements_rec,
                     p_start_date => p_start_date);
               END;
            END LOOP;
         END IF;

         IF p_eveh_elements_rec.p_event_offer = 'Y'
         THEN
            FOR sub_eveo_rec IN sub_eveo_cur
            LOOP
               BEGIN
                  l_return_status := NULL;
                  l_msg_count := 0;
                  l_msg_data := NULL;
                  copy_event_offer(
                     p_api_version => 1,
                     x_return_status => l_return_status,
                     p_init_msg_list => fnd_api.g_true,
                     x_msg_count => l_msg_data,
                     x_msg_data => l_msg_count,
                     x_eveo_id => x_eventoffer_id,
                     p_src_eveo_id => sub_eveo_rec.event_offer_id,
                     p_event_header_id => x_eveh_id,
                     p_eveo_elements_rec => l_eveo_elements_rec,
                     p_start_date => p_start_date);
               END;
            END LOOP;
         END IF;
      END IF;
      IF   l_return_status  =  FND_API.G_RET_STS_SUCCESS  THEN
         COMMIT ;
      END IF ;
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO copy_event_header;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get(
            p_encoded => fnd_api.g_false,
            p_count => x_msg_count,
            p_data => x_msg_data);
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO copy_event_header;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         IF (AMS_DEBUG_HIGH_ON) THEN

             ams_utility_pvt.debug_message(l_full_name || ': debug');
         END IF;
         fnd_msg_pub.count_and_get(
            p_encoded => fnd_api.g_false,
            p_count => x_msg_count,
            p_data => x_msg_data);
      WHEN OTHERS
      THEN
         ROLLBACK TO copy_event_header;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get(
            p_encoded => fnd_api.g_false,
            p_count => x_msg_count,
            p_data => x_msg_data);
   END copy_event_header;

PROCEDURE Copy_Campaign (
   p_api_version         IN       NUMBER,
   p_init_msg_list       IN       VARCHAR2 := FND_API.G_FALSE,
   -- Not being added since it involves changes in signature and class
   -- generated by rosseta To be implemented at later stage
   -- p_commit              IN       VARCHAR2 := FND_API.G_FALSE,
   -- p_validation_level    IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   x_return_status       OUT NOCOPY      VARCHAR2,
   x_msg_count           OUT NOCOPY      NUMBER,
   x_msg_data            OUT NOCOPY      VARCHAR2,
   x_campaign_id         OUT NOCOPY      NUMBER,
   p_src_camp_id         IN       NUMBER,
   p_new_camp_name       IN       VARCHAR2,
   p_par_camp_id         IN       NUMBER,
   p_source_code         IN       VARCHAR2 := NULL,
   p_camp_elements_rec   IN       camp_elements_rec_type,
   p_end_date            IN       DATE :=  FND_API.G_MISS_DATE,
   p_start_date          IN       DATE :=  FND_API.G_MISS_DATE)
IS
   l_api_version       CONSTANT   NUMBER        := 1.0;
   l_api_name          CONSTANT   VARCHAR2(30)  := 'Copy_Campaign';
   l_full_name         CONSTANT   VARCHAR2(60)  := g_pkg_name ||'.'||l_api_name;
   l_return_status                VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;
   l_lookup_meaning               VARCHAR2(80);
   -- Stores the resource Id
   l_owner_user_id                NUMBER        := FND_API.G_MISS_NUM;
   l_mesg_text                    VARCHAR2(2000);

   l_campaign_rec                 ams_campaigns_vl%ROWTYPE;
   l_user_status_id               number;
   l_camp_count                   number;
   l_camp_rec                     ams_campaign_pvt.camp_rec_type;
   l_date_number                  NUMBER  := 0;
   l_msg_count                    NUMBER;
   l_msg_data                     VARCHAR2(512);
   l_src_campaign_schedule_id     NUMBER;
   l_campaign_schedule_id         NUMBER;
   l_errnum                       NUMBER;
   l_errmsg                       VARCHAR2(3000);
   l_errcode                      VARCHAR2(80);
   x_sub_camp_id                  NUMBER;
   l_camp_elements_rec            camp_elements_rec_type;

   CURSOR cur_get_campaign IS
   SELECT *
     FROM ams_campaigns_vl
    WHERE campaign_id = p_src_camp_id;

   CURSOR cur_get_default_status IS
   SELECT user_status_id
     FROM ams_user_statuses_b
    WHERE system_status_code = 'NEW'
      AND enabled_flag = 'Y'
      AND sysdate between start_date_active AND NVL(end_date_active,sysdate)
      AND default_flag = 'Y'
      AND system_status_type = 'AMS_CAMPAIGN_STATUS';

   -- Used to bump up the version number if the name is same for the campaign
   CURSOR c_camp_name(l_campaign_name IN VARCHAR2) IS
   SELECT MAX(version_no)
     FROM ams_campaigns_vl
    WHERE campaign_name = l_campaign_name;

   CURSOR c_camp_sche(src_campaign_id IN NUMBER) IS
   SELECT schedule_id
     FROM ams_campaign_schedules_b
    WHERE campaign_id = src_campaign_id;

   CURSOR cur_get_tasks (p_src_camp_id NUMBER) IS
   SELECT task_id
     FROM jtf_tasks_b
    WHERE source_object_type_code = 'AMS_CAMP'
      AND source_object_id = p_src_camp_id;

   CURSOR sub_camp_cur IS
   SELECT campaign_id,
          campaign_name
     FROM ams_campaigns_vl
    WHERE parent_campaign_id = p_src_camp_id;

BEGIN
   x_return_status := fnd_api.g_ret_sts_success;
   --Standard Start API savePoint
   SAVEPOINT Copy_Campaign_PVT;
   IF NOT FND_API.Compatible_API_CALL (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME
                                       )
    THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR  ;
    END IF;
    -- Initialize the message List
    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
       FND_MSG_PUB.initialize ;
    END IF;
    -- Lookup Meaning from ams_lookup for CAMP
    IF (AMS_DEBUG_HIGH_ON) THEN

        ams_utility_pvt.debug_message(l_full_name || ' :Start ');
    END IF;
    ams_utility_pvt.get_lookup_meaning( 'AMS_SYS_ARC_QUALIFIER',
                                        'CAMP',
                                        l_return_status,
                                        l_lookup_meaning);
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR ;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;

    -- Start of Log
    -- General Message saying copying has started
    fnd_message.set_name('AMS','AMS_COPY_ELEMENTS');
    fnd_message.set_token('ELEMENTS',l_lookup_meaning,TRUE);
    l_mesg_text := fnd_message.get ;

    -- Writing to PL/SQL table
    ams_cpyutility_pvt.write_log_mesg( 'CAMP',
                                       p_src_camp_id,
                                       l_mesg_text,
                                       'GENERAL');
    -- Get the source campaign details
    open cur_get_campaign;
    fetch cur_get_campaign into l_campaign_rec;
    close cur_get_campaign;

    -- Call get_resource_id to get the resource id from jtf tables
    -- Returns -1 if the setup of resource was not done properly
    l_owner_user_id  := ams_utility_pvt.get_resource_id(FND_GLOBAL.USER_ID);
    IF l_owner_user_id  = -1 THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;


    -- Id for campaigns status  = 'NEW'
    OPEN cur_get_default_status;
    FETCH cur_get_default_status into l_user_status_id;
    CLOSE cur_get_default_status;
    IF l_user_status_id = FND_API.G_MISS_NUM then
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;

    -- get the max version number of campaign if campaign name is same
    OPEN c_camp_name(p_new_camp_name);
    FETCH c_camp_name INTO l_camp_count;
    CLOSE c_camp_name;


    -- Copying Campaign Details
    -- a) Copying Fields from source Campaign Fields
    l_camp_rec.global_flag              := l_campaign_rec.global_flag;
    l_camp_rec.custom_setup_id          := l_campaign_rec.custom_setup_id;

    -- Start of code modified by ptendulk on 25-Jan-2001
    -- While copying the campaign do not copy the business unit.
    --
    l_camp_rec.business_unit_id         := null ;
    --l_camp_rec.business_unit_id         := l_campaign_rec.business_unit_id;
    -- End of code modified by ptendulk on 25-Jan-2001
    l_camp_rec.private_flag             := l_campaign_rec.private_flag;
    l_camp_rec.partner_flag             := l_campaign_rec.partner_flag;
    l_camp_rec.template_flag            := l_campaign_rec.template_flag;
    l_camp_rec.cascade_source_code_flag :=
                                     l_campaign_rec.cascade_source_code_flag;
    l_camp_rec.inherit_attributes_flag  :=
                                     l_campaign_rec.inherit_attributes_flag;
    l_camp_rec.rollup_type              := l_campaign_rec.rollup_type;
    l_camp_rec.campaign_type            := l_campaign_rec.campaign_type;
    l_camp_rec.priority                 := l_campaign_rec.priority;
    l_camp_rec.fund_source_type         := l_campaign_rec.fund_source_type;
    l_camp_rec.fund_source_id           := l_campaign_rec.fund_source_id;
    l_camp_rec.application_id           := l_campaign_rec.application_id;
    l_camp_rec.media_id                 := l_campaign_rec.media_id;
    -- Set to null
    -- l_camp_rec.channel_id               := l_campaign_rec.channel_id;
    -- l_camp_rec.arc_channel_from         := l_campaign_rec.arc_channel_from;
    --- Media Type code required for an execution camapign
    l_camp_rec.media_type_code          := l_campaign_rec.media_type_code;
    l_camp_rec.transaction_currency_code :=
                                 l_campaign_rec.transaction_currency_code;
    l_camp_rec.functional_currency_code :=
                                 l_campaign_rec.functional_currency_code;
    l_camp_rec.budget_amount_tc         := l_campaign_rec.budget_amount_tc;
    l_camp_rec.budget_amount_fc         := l_campaign_rec.budget_amount_fc;
    l_camp_rec.event_type               := l_campaign_rec.event_type;
    l_camp_rec.content_source           := l_campaign_rec.content_source;
    l_camp_rec.cc_call_strategy         := l_campaign_rec.cc_call_strategy;
    l_camp_rec.cc_manager_user_id       := l_campaign_rec.cc_manager_user_id;
    l_camp_rec.forecasted_revenue       := l_campaign_rec.forecasted_revenue;
    l_camp_rec.forecasted_cost          := l_campaign_rec.forecasted_cost;
    l_camp_rec.forecasted_response      := l_campaign_rec.forecasted_response;
    l_camp_rec.target_response          := l_campaign_rec.target_response;
    l_camp_rec.country_code             := l_campaign_rec.country_code;
    l_camp_rec.language_code            := l_campaign_rec.language_code;
    l_camp_rec.attribute_category       := l_campaign_rec.attribute_category;
    l_camp_rec.attribute1               := l_campaign_rec.attribute1;
    l_camp_rec.attribute2               := l_campaign_rec.attribute2;
    l_camp_rec.attribute3               := l_campaign_rec.attribute3;
    l_camp_rec.attribute4               := l_campaign_rec.attribute4;
    l_camp_rec.attribute5               := l_campaign_rec.attribute5;
    l_camp_rec.attribute6               := l_campaign_rec.attribute6;
    l_camp_rec.attribute7               := l_campaign_rec.attribute7;
    l_camp_rec.attribute8               := l_campaign_rec.attribute8;
    l_camp_rec.attribute9               := l_campaign_rec.attribute9;
    l_camp_rec.attribute10              := l_campaign_rec.attribute10;
    l_camp_rec.attribute11              := l_campaign_rec.attribute11;
    l_camp_rec.attribute12              := l_campaign_rec.attribute12;
    l_camp_rec.attribute13              := l_campaign_rec.attribute13;
    l_camp_rec.attribute14              := l_campaign_rec.attribute14;
    l_camp_rec.attribute15              := l_campaign_rec.attribute15;
    l_camp_rec.duration                 := l_campaign_rec.duration;
    l_camp_rec.duration_uom_code        := l_campaign_rec.duration_uom_code;
    l_camp_rec.source_code              := p_source_code;
    l_camp_rec.campaign_name            := p_new_camp_name;
    l_camp_rec.campaign_theme           := l_campaign_rec.campaign_theme;
    l_camp_rec.description              := l_campaign_rec.description;


    -- b)   Null fields
    l_camp_rec.start_period_name          := NULL;
    l_camp_rec.end_period_name            := NULL;
    l_camp_rec.forecasted_plan_start_date := NULL;
    l_camp_rec.forecasted_plan_end_date   := NULL;
    l_camp_rec.forecasted_exec_start_date := NULL;
    l_camp_rec.forecasted_exec_end_date   := NULL;
    l_camp_rec.actual_plan_start_date     := NULL;
    l_camp_rec.actual_plan_end_date       := NULL;
    l_camp_rec.channel_id                 := NULL;
    l_camp_rec.arc_channel_from           := NULL;


    -- c)  Fields Different between source campaign and copied campaign
    l_camp_rec.version_no                 := nvl(l_camp_count,0) + 1;
    l_camp_rec.object_version_number      := 1;
    -- default campaign calendar
    l_camp_rec.campaign_calendar          :=
                             FND_PROFILE.value('AMS_CAMPAIGN_DEFAULT_CALENDER');
    -- default country
    l_camp_rec.city_id                    :=
                           TO_NUMBER(FND_PROFILE.value('AMS_SRCGEN_USER_CITY'));
    l_camp_rec.owner_user_id              := l_owner_user_id;
    l_camp_rec.user_status_id             := l_user_status_id;
    l_camp_rec.status_code                := 'NEW';
    l_camp_rec.status_date                := SYSDATE;
    --l_camp_rec.active_flag              := l_campaign_rec.active_flag;
    --l_campaign_rec.parent_campaign_id
    l_camp_rec.parent_campaign_id         :=  p_par_camp_id;

    -- End Date Algorithm
    -- l_date number is the difference between start date of source
    -- Campaign and end data of source campaign date
    l_date_number := ams_cpyutility_pvt.get_dates('CAMP',
                                                  p_src_camp_id,
                                                  l_return_status);

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR ;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;

    -- p_start_date is the user  input date
    IF p_start_date IS NOT NULL THEN
       l_camp_rec.actual_exec_start_date := p_start_date;
    END IF;

    -- End date of copied(new) campaign is start date(user input)+l_date_number
    IF l_campaign_rec.actual_exec_end_date IS NOT NULL THEN
       l_camp_rec.actual_exec_end_date := p_start_date + l_date_number;
    END IF;
    -- End of end date alogorithm

    --   Not copying Response related stuff
    --   l_camp_rec.dscript_name       := l_campaign_rec.dscript_name;
    --   l_camp_rec.inbound_url        := l_campaign_rec.inbound_url;
    --   l_camp_rec.inbound_email_id   := l_campaign_rec.inbound_email_id;
    --   l_camp_rec.inbound_phone_no   := l_campaign_rec.inbound_phone_no;
         ----Donot copy the ff_cols------
    /*
    l_camp_rec.ff_priority             := l_campaign_rec.ff_priority;
    l_camp_rec.ff_override_cover_letter  :=
                                       l_campaign_rec.ff_override_cover_letter;
    l_camp_rec.ff_ntf_on_send_flag     := l_campaign_rec.ff_ntf_on_send_flag;
    l_camp_rec.ff_ntf_complete_flag    := l_campaign_rec.ff_ntf_complete_flag;
    l_camp_rec.ff_ntf_exhausted_inv_flag :=
                                       l_campaign_rec.ff_ntf_exhausted_inv_flag;
    l_camp_rec.ff_ntf_bounced_address_flag      :=
                                    l_campaign_rec.ff_ntf_bounced_address_flag;
    l_camp_rec.ff_shipping_method      := l_campaign_rec.ff_shipping_method;
    l_camp_rec.ff_carrier              := l_campaign_rec.ff_carrier;
    l_camp_rec.ff_printing_option      := l_campaign_rec.ff_printing_option;
    l_camp_rec.ff_start_date           := l_campaign_rec.ff_start_date;
    l_camp_rec.ff_special_handling_text :=
                                 l_campaign_rec.ff_special_handling_text;
    */
    -- Calling create campaign API l_camp_rec (Campaign details)
    -- returns campaign Id of the new campaign
    ams_campaign_pvt.create_campaign( p_api_version    => l_api_version,
                                      p_init_msg_list  => fnd_api.g_true,
                                      p_commit         => FND_API.g_true,
                                      x_return_status  => l_return_status,
                                      x_msg_count      => l_msg_count,
                                      x_msg_data       => l_msg_data,
                                      x_camp_id        => x_campaign_id,
                                      p_camp_rec       => l_camp_rec);

     IF ( l_return_status = fnd_api.g_ret_sts_error ) OR
        ( l_return_status = fnd_api.g_ret_sts_error ) then
        FOR l_counter IN 1 .. l_msg_count
        LOOP
          l_mesg_text := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
          l_errmsg := SUBSTR( l_mesg_text || '): ' || l_counter ||
                              ' OF ' || l_msg_count, 1, 3000);
          ams_cpyutility_pvt.write_log_mesg( 'CAMP',
                                             p_src_camp_id,
                                             l_errmsg,
                                             'ERROR');
        END LOOP;
        -- if error then right a copy log message to the log table

        fnd_message.set_name('AMS', 'AMS_COPY_ERROR2');
        fnd_message.set_token('ELEMENTS', l_lookup_meaning, TRUE);
        l_mesg_text := fnd_message.get;
        l_errmsg :=substr(l_mesg_text || ' - ' ||
                          ams_utility_pvt.get_object_name('CAMP',p_src_camp_id),
                          1, 4000);
        ams_cpyutility_pvt.write_log_mesg('CAMP',
                                          p_src_camp_id,
                                          l_errmsg ,
                                          'ERROR');
     END IF ;

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR ;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
     END IF;
     -- Schedules are not copied
     -- Copy the schedule
     -- IF p_camp_elements_rec.p_camp_sch = 'Y' THEN
     --    OPEN c_camp_sche(x_campaign_id);
     -- LOOP
     --    FETCH c_camp_sche INTO l_src_campaign_schedule_id;
     --    EXIT WHEN c_camp_sche%NOTFOUND;
     --       ams_copyelements_pvt.copy_campaign_schedules
     --                 ( p_init_msg_list        => fnd_api.g_true,
     --                   p_api_version          => l_api_version,
     --                   x_return_status        => l_return_status,
     --                   x_msg_count            => l_msg_count,
     --                   x_msg_data             => l_msg_data,
     --                   x_campaign_schedule_id => l_campaign_schedule_id,
     --                   p_src_camp_schedule_id => l_src_campaign_schedule_id,
     --                   p_new_camp_id          => x_campaign_id);
     --  END LOOP;
     --  CLOSE c_camp_sche;
     -- END IF;

      IF p_camp_elements_rec.p_access = 'Y' THEN
         ams_copyelements_pvt.copy_act_access
                        ( p_src_act_type => 'CAMP',
                          p_src_act_id   => p_src_camp_id,
                          p_new_act_id   => x_campaign_id,
                          p_errnum       => l_errnum,
                          p_errcode      => l_errcode,
                          p_errmsg       =>   l_errmsg);
      END IF;


       IF p_camp_elements_rec.p_messages = 'Y' THEN
          ams_copyelements_pvt.copy_act_messages
                              ( p_src_act_type  =>'CAMP',
                                p_src_act_id    =>p_src_camp_id,
                                p_new_act_id    =>x_campaign_id,
                                p_errnum        =>l_errnum,
                                p_errcode       =>l_errcode,
                                p_errmsg        =>l_errmsg);
      END IF;

      IF p_camp_elements_rec.p_attachments = 'Y' THEN
          ams_copyelements_pvt.copy_act_attachments
                              ( p_src_act_type  =>'CAMP',
                                p_src_act_id    =>p_src_camp_id,
                                p_new_act_id    =>x_campaign_id,
                                p_errnum        =>l_errnum,
                                p_errcode       =>l_errcode,
                                p_errmsg        =>l_errmsg);
      END IF;



        -- If the user wants to copy access then the access flag should
        -- be 'Y' (Yes)
         IF p_camp_elements_rec.p_products = 'Y' THEN
            ams_copyelements_pvt.copy_act_prod
                            ( p_src_act_type   => 'CAMP',
                              p_src_act_id     => p_src_camp_id,
                              p_new_act_id     => x_campaign_id,
                              p_errnum         => l_errnum,
                              p_errcode        => l_errcode,
                              p_errmsg         => l_errmsg);
      END IF;

        -- If the user wants to copy geo_areas then the geo_area
        -- flag should be 'Y' (Yes)
         IF p_camp_elements_rec.p_geo_areas = 'Y' THEN
            ams_copyelements_pvt.copy_act_geo_areas
                               ( p_src_act_type => 'CAMP',
                                 p_src_act_id   => p_src_camp_id,
                                 p_new_act_id   => x_campaign_id,
                                 p_errnum       => l_errnum,
                                 p_errcode      => l_errcode,
                                 p_errmsg       => l_errmsg);
       END IF;


      --If the user wants to copy object_associatiosn then the
      -- obj_asso flag should be 'Y' (Yes).
      --If will copy all the associations of the campaign

       IF p_camp_elements_rec.p_obj_asso = 'Y' THEN

        ams_copyelements_pvt.copy_object_associations
                                      ( p_src_act_type => 'CAMP',
                                        p_src_act_id   => p_src_camp_id,
                                        p_new_act_id   => x_campaign_id,
                                        p_errnum       => l_errnum,
                                        p_errcode      => l_errcode,
                                        p_errmsg       => l_errmsg);
       END IF;


    -- If the user wants to copy resources then the resources flag should
    -- be 'Y' (Yes)
    --    IF p_camp_elements_rec.p_resources = 'Y' THEN
    --
    --    ams_copyelements_pvt.copy_act_resources( p_src_act_type   => 'CAMP',
    --                          p_src_act_id     => p_src_camp_id,
    --                          p_new_act_id     => x_campaign_id,
    --                          p_errnum         => l_errnum,
    --                          p_errcode        => l_errcode,
    --                          p_errmsg         => l_errmsg);
    --     END IF;


    --   IF p_camp_elements_rec.p_offers = 'Y' THEN

    --  ams_copyelements_pvt.copy_act_offers
    --                          ( p_src_act_type =>'CAMP',
    --                            p_src_act_id   =>p_src_camp_id,
    --                            p_new_act_id   =>x_campaign_id,
    --                            p_errnum       =>l_errnum,
    --                            p_errcode      =>l_errcode,
    --                            p_errmsg       =>l_errmsg);
    --    END IF;


      IF p_camp_elements_rec.p_segments = 'Y' THEN
         ams_copyelements_pvt.copy_act_market_segments
                                     ( p_src_act_type =>'CAMP',
                                       p_src_act_id   =>p_src_camp_id,
                                       p_new_act_id   =>x_campaign_id,
                                       p_errnum       =>l_errnum,
                                       p_errcode      =>l_errcode,
                                       p_errmsg       =>l_errmsg);
       END IF;


       IF p_camp_elements_rec.p_tasks = 'Y' THEN
           FOR tasks_rec in cur_get_tasks(p_src_camp_id) LOOP
              ams_copyelements_pvt.copy_tasks
                                (p_init_msg_list        => fnd_api.g_true,
                                 p_api_version          => l_api_version,
                                 x_return_status        => l_return_status,
                                 x_msg_count            => l_msg_count,
                                 x_msg_data             => l_msg_data,
                                 p_old_camp_id          => p_src_camp_id,
                                 p_new_camp_id          => x_campaign_id,
                                 p_task_id              => tasks_rec.task_id ,
                                 p_owner_id             =>  l_owner_user_id  ,
                                 p_actual_due_date      =>
                                               l_camp_rec.actual_exec_end_date );
           END LOOP;
         END IF;

       IF p_camp_elements_rec.p_partners = 'Y' THEN

        ams_copyelements_pvt.copy_partners
                                  (p_init_msg_list        => fnd_api.g_true,
                                   p_api_version          => l_api_version,
                                   x_return_status        => l_return_status,
                                   x_msg_count            => l_msg_count,
                                   x_msg_data             => l_msg_data,
                                   p_old_camp_id          => p_src_camp_id,
                                   p_new_camp_id          => x_campaign_id);
         END IF;


       IF p_camp_elements_rec.p_sub_camp = 'Y' THEN
            FOR sub_camp_rec IN sub_camp_cur  LOOP
			commit;
               copy_campaign( p_api_version       => 1,
                              p_init_msg_list     => fnd_api.g_true,
                              x_return_status     => l_return_status,
                              x_msg_data          => l_msg_data,
                              x_msg_count         => l_msg_count,
                              p_src_camp_id       => sub_camp_rec.campaign_id,
                              p_new_camp_name     => sub_camp_rec.campaign_name,
                              p_par_camp_id       => x_campaign_id,
                              x_campaign_id       => x_sub_camp_id,
                              p_camp_elements_rec => p_camp_elements_rec,
                              p_start_date        => p_start_date);
            END LOOP;

   END IF;
    -- End of Log
    -- General Message saying copying has started
    fnd_message.set_name('AMS','AMS_END_COPY_ELEMENTS');
    fnd_message.set_token('ELEMENTS',l_lookup_meaning,TRUE);
    fnd_message.set_token('ELEMENT_NAME',p_new_camp_name,TRUE);
    l_mesg_text := fnd_message.get ;

    -- Writing to PL/SQL table
    ams_cpyutility_pvt.write_log_mesg( 'CAMP',
                                       p_src_camp_id,
                                       l_mesg_text,
                                       'GENERAL');

   IF   l_return_status  =  FND_API.G_RET_STS_SUCCESS  THEN
      COMMIT ;
   END IF ;
   EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO Copy_Campaign_PVT;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_and_Get ( p_count => x_msg_count,
                                      p_data  => x_msg_data
                                    );
       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO Copy_Campaign_PVT;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_and_Get ( p_count => x_msg_count,
                                      p_data  => x_msg_data
                                    );
       WHEN OTHERS THEN
          ROLLBACK TO Copy_Campaign_PVT;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF FND_MSG_PUB.Check_Msg_Level
                 (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
          THEN
             FND_MSG_PUB.Add_Exc_MSG ( G_FILE_NAME,
                                       G_PKG_NAME,
                                       l_api_name
                                     );
           END IF;
           FND_MSG_PUB.Count_and_Get (p_count => x_msg_count,
                                      p_data  => x_msg_data
                                     );

END Copy_Campaign;






   PROCEDURE copy_schedule_attributes (
      p_api_version     IN NUMBER,
      p_init_msg_list   IN VARCHAR2 := FND_API.G_FALSE,
      p_commit          IN VARCHAR2 := FND_API.G_FALSE,
      x_return_status   OUT NOCOPY VARCHAR2,
      x_msg_count       OUT NOCOPY NUMBER,
      x_msg_data        OUT NOCOPY VARCHAR2,
      p_object_type     IN VARCHAR2,
      p_src_object_id   IN NUMBER,
      p_tar_object_id   IN NUMBER,
      p_attr_list       IN schedule_attr_rec_type
   )
   IS
   L_API_NAME           CONSTANT VARCHAR2(30) := 'copy_schedule_attributes';
   L_API_VERSION_NUMBER CONSTANT NUMBER := 1.0;
   L_API_VERSION        CONSTANT NUMBER := 1.0;
   l_errnum                       NUMBER;
   l_errmsg                       VARCHAR2(3000);
   l_errcode                      VARCHAR2(80);
   l_return_status  VARCHAR2(1);
   l_msg_count      NUMBER;
   l_msg_data       VARCHAR2(2000);

   CURSOR c_rel_event_id(p_sch_id NUMBER) IS
   SELECT related_event_id
   FROM   ams_campaign_schedules_b
   WHERE  schedule_id = p_sch_id;

   l_src_eone_id  NUMBER;
   l_tar_eone_id  NUMBER;


BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT copy_schedule_savepoint;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF (AMS_DEBUG_HIGH_ON) THEN



       AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' start');

   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --
   -- Start of API body.
   --

   -- start copying stuff

   -- Event Agenda    AGEN // Leave for later

   -- Attachments     ATCH
   IF p_attr_list.p_ATCH = 'Y'
   THEN
      --Modified by rrajesh on 10/18/01
       /*ams_copyelements_pvt.copy_act_attachments(
                         p_src_act_type => 'CSCH',
                         p_src_act_id   => p_src_object_id,
                         p_new_act_id   => p_tar_object_id,
                         p_errnum       => l_errnum,
                         p_errcode      => l_errcode,
                         p_errmsg       => l_errmsg);*/
       ams_copyelements_pvt.copy_act_attachments(
                         p_src_act_type => 'AMS_CSCH',
                         p_src_act_id   => p_src_object_id,
                         p_new_act_id   => p_tar_object_id,
                         p_errnum       => l_errnum,
                         p_errcode      => l_errcode,
                         p_errmsg       => l_errmsg);
      -- end change 10/18/01
   END IF;

   -- Event Category  CATG // Leave for later
   IF p_attr_list.p_CATG = 'Y'
   THEN
       ams_copyelements_pvt.copy_act_categories(
                         p_src_act_type => 'CSCH',
                         p_src_act_id   => p_src_object_id,
                         p_new_act_id   => p_tar_object_id,
                         p_errnum       => l_errnum,
                         p_errcode      => l_errcode,
                         p_errmsg       => l_errmsg);
   END IF;

   -- Market          CELL
   IF p_attr_list.p_CELL = 'Y'
   THEN
       ams_copyelements_pvt.copy_act_market_segments(
                         p_src_act_type => 'CSCH',
                         p_src_act_id   => p_src_object_id,
                         p_new_act_id   => p_tar_object_id,
                         p_errnum       => l_errnum,
                         p_errcode      => l_errcode,
                         p_errmsg       => l_errmsg);
   END IF;

   -- Deliverables    DELV
   IF p_attr_list.p_DELV = 'Y'
   THEN
       ams_copyelements_pvt.copy_object_associations(
                         p_src_act_type => 'CSCH',
                         p_src_act_id   => p_src_object_id,
                         p_new_act_id   => p_tar_object_id,
                         p_errnum       => l_errnum,
                         p_errcode      => l_errcode,
                         p_errmsg       => l_errmsg);
   END IF;

   -- Messages        MESG
   IF p_attr_list.p_MESG = 'Y'
   THEN
       ams_copyelements_pvt.copy_act_messages(
                         p_src_act_type => 'CSCH',
                         p_src_act_id   => p_src_object_id,
                         p_new_act_id   => p_tar_object_id,
                         p_errnum       => l_errnum,
                         p_errcode      => l_errcode,
                         p_errmsg       => l_errmsg);
   END IF;

   -- Products        PROD
   IF p_attr_list.p_PROD = 'Y'
   THEN
       ams_copyelements_pvt.copy_act_prod(
                         p_src_act_type => 'CSCH',
                         p_src_act_id   => p_src_object_id,
                         p_new_act_id   => p_tar_object_id,
                         p_errnum       => l_errnum,
                         p_errcode      => l_errcode,
                         p_errmsg       => l_errmsg);
   END IF;


    -- COLLAB - TASKS     TASK
    -- start add by spragupa on 23-nov-2007 for ER 6467510 - extens copy functionality for tasks
   IF p_attr_list.p_TASK = 'Y'
   THEN
       ams_copyelements_pvt.copy_act_task(
                         p_src_act_type => 'AMS_CSCH',
                         p_src_act_id   => p_src_object_id,
                         p_new_act_id   => p_tar_object_id,
                         p_errnum       => l_errnum,
                         p_errcode      => l_errcode,
                         p_errmsg       => l_errmsg);
   END IF;

    -- end add by spragupa on 23-nov-2007 for ER 6467510 - extens copy functionality for tasks

   -- Partners        PTNR
   IF p_attr_list.p_PTNR = 'Y'
   THEN
       ams_copyelements_pvt.copy_partners_generic(
                         p_api_version => l_api_version,
                         p_init_msg_list => fnd_api.g_false,
                         x_return_status   => l_return_status,
                         x_msg_count   => l_msg_count,
                         x_msg_data     =>  l_msg_data,
                         p_old_id      => p_src_object_id,
                         p_new_id      => p_tar_object_id,
                         p_type       => 'CSCH');
   END IF;

   -- Registration    REGS // Leave for later

   -- added by soagrawa on 25-jan-2002
   -- Content       CONTENT
   IF p_attr_list.p_CONTENT = 'Y'
   THEN
       ams_copyelements_pvt.copy_act_content(
                         p_src_act_type => 'AMS_CSCH',
                         p_src_act_id   => p_src_object_id,
                         p_new_act_id   => p_tar_object_id,
                         p_errnum       => l_errnum,
                         p_errcode      => l_errcode,
                         p_errmsg       => l_errmsg);
   END IF;

   -- added by sodixit on 04-oct-2003 for 11.5.10
   -- Copy Target Group
   IF p_attr_list.p_TGRP = 'Y'
   THEN
       AMS_Utility_PVT.debug_message (
			FND_LOG.LEVEL_EVENT,
			'ams.plsql.ams_copyactivities_pvt.copy_schedule_attributes',
			'Calling ams_copyelements_pvt.copy_target_group');
       AMS_Utility_PVT.debug_message (
			FND_LOG.LEVEL_EVENT,
			'ams.plsql.ams_copyactivities_pvt.copy_schedule_attributes',
			'p_src_object_id='||p_src_object_id);
       AMS_Utility_PVT.debug_message (
			FND_LOG.LEVEL_EVENT,
			'ams.plsql.ams_copyactivities_pvt.copy_schedule_attributes',
			'p_tar_object_id='||p_tar_object_id);
       ams_copyelements_pvt.copy_target_group(
                        p_src_act_type => 'CSCH',
                         p_src_act_id   => p_src_object_id,
                         p_new_act_id   => p_tar_object_id,
                         p_errnum       => l_errnum,
                         p_errcode      => l_errcode,
                         p_errmsg       => l_errmsg);
   END IF;

   -- added by sodixit on 04-oct-2003 for 11.5.10
   -- Copy Collateral
   IF p_attr_list.p_COLT = 'Y'
   THEN
       AMS_Utility_PVT.debug_message (
			FND_LOG.LEVEL_EVENT,
			'ams.plsql.ams_copyactivities_pvt.copy_schedule_attributes',
			'Calling ams_copyelements_pvt.copy_act_collateral');
       AMS_Utility_PVT.debug_message (
			FND_LOG.LEVEL_EVENT,
			'ams.plsql.ams_copyactivities_pvt.copy_schedule_attributes',
			'p_src_object_id='||p_src_object_id);
       AMS_Utility_PVT.debug_message (
			FND_LOG.LEVEL_EVENT,
			'ams.plsql.ams_copyactivities_pvt.copy_schedule_attributes',
			'p_tar_object_id='||p_tar_object_id);
       ams_copyelements_pvt.copy_act_collateral(
                         p_src_act_type => 'AMS_CSCH',
                         p_src_act_id   => p_src_object_id,
                         p_new_act_id   => p_tar_object_id,
                         p_errnum       => l_errnum,
                         p_errcode      => l_errcode,
                         p_errmsg       => l_errmsg);
       -- anchaudh added for copy of collateral contents attached to the non-direct marketing activities.
       ams_copyelements_pvt.copy_act_collateral(
                         p_src_act_type => 'AMS_COLLAT',
                         p_src_act_id   => p_src_object_id,
                         p_new_act_id   => p_tar_object_id,
                         p_errnum       => l_errnum,
                         p_errcode      => l_errcode,
                         p_errmsg       => l_errmsg);
   END IF;

   -- soagrawa added AGEN on 29-may-2003 for bug# 2949268
   -- Agenda       AGEN
   IF p_attr_list.p_AGEN = 'Y'
   THEN

      OPEN  c_rel_event_id (p_src_object_id);
      FETCH c_rel_event_id INTO l_src_eone_id;
      CLOSE c_rel_event_id;

      OPEN  c_rel_event_id (p_tar_object_id);
      FETCH c_rel_event_id INTO l_tar_eone_id;
      CLOSE c_rel_event_id;

      IF l_src_eone_id IS NOT NULL AND l_tar_eone_id IS NOT null
      THEN
         ams_eventschedule_copy_pvt.copy_event_schedule_agenda (
            p_src_act_type   => 'EONE',
            p_new_act_type   => 'EONE',
            p_src_act_id     => l_src_eone_id,
            p_new_act_id     => l_tar_eone_id,
            p_errnum         => l_errnum,
            p_errcode        => l_errcode,
            p_errmsg         => l_errmsg
         );
      END IF;
   END IF;

   --
   -- End of API body.
   --

   -- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;


   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' end');
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get (
      p_count  => x_msg_count,
      p_data   => x_msg_data
   );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO copy_schedule_savepoint;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count   => x_msg_count,
         p_data    => x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO copy_schedule_savepoint;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO copy_schedule_savepoint;
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
END copy_schedule_attributes;

PROCEDURE WRITE_TO_ACT_LOG(p_msg_data in VARCHAR2,
                           p_arc_log_used_by in VARCHAR2 DEFAULT 'CAMP',
                           p_log_used_by_id in number)
                           IS
 PRAGMA AUTONOMOUS_TRANSACTION;
 l_return_status VARCHAR2(1);
BEGIN
  AMS_UTILITY_PVT.CREATE_LOG(
                             x_return_status    => l_return_status,
                             p_arc_log_used_by  => 'CAMP',
                             p_log_used_by_id   => p_log_used_by_id,
                             p_msg_data         => p_msg_data);
  COMMIT;
END WRITE_TO_ACT_LOG;


END;

/
