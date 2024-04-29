--------------------------------------------------------
--  DDL for Package Body AMS_SCHEDULER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_SCHEDULER_PVT" AS
/* $Header: amsvrptb.pls 120.3.12000000.3 2007/07/18 06:06:27 amlal ship $*/
--

G_PKG_NAME      CONSTANT VARCHAR2(30):='AMS_SCHEDULER_PVT';
G_FILE_NAME     CONSTANT VARCHAR2(15):='amsvrptb.pls';
g_log_level     CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;

--========================================================================
-- PROCEDURE
--    WRITE_LOG
-- Purpose
--   This method will be used to write logs for this api
-- HISTORY
--    10-Oct-2000   dbiswas    Created.
--
--========================================================================

PROCEDURE WRITE_LOG             ( p_api_name      IN VARCHAR2,
                                  p_log_message   IN VARCHAR2 )
IS

   l_api_name   VARCHAR2(30);
   l_log_mesg   VARCHAR2(2000);
   l_return_status VARCHAR2(1);
BEGIN
      l_api_name := p_api_name;
      l_log_mesg := p_log_message;
      AMS_Utility_PVT.debug_message (
                        p_log_level   => g_log_level,
                        p_module_name => 'ams.plsql.'||'.'|| g_pkg_name||'.'||l_api_name,
                        p_text => p_log_message
                       );

   AMS_Utility_PVT.Create_Log (
                     x_return_status   => l_return_status,
                     p_arc_log_used_by => 'CSCH',
                     p_log_used_by_id  => 1,
                     p_msg_data        => 'amsvrptb.pls: '||p_log_message,
                     p_msg_type        => 'DEBUG'
                     );
 END WRITE_LOG;


FUNCTION Target_Group_Exist (p_schedule_id IN NUMBER --)
                             , p_obj_type IN VARCHAR2 :='CSCH')
RETURN VARCHAR2
IS
   CURSOR c_target_det
   IS SELECT 1
      FROM   ams_act_lists la
      WHERE  list_act_type = 'TARGET'
      AND    list_used_by = p_obj_type --'CSCH'
      AND    list_used_by_id = p_schedule_id
      AND    EXISTS (SELECT *
                     FROM   ams_list_entries le
                     WHERE  le.list_header_id = la.list_header_id) ;
   l_dummy  NUMBER ;
BEGIN
   OPEN c_target_det ;
   FETCH c_target_det INTO l_dummy ;
   CLOSE c_target_det ;

   IF l_dummy IS NULL THEN
      RETURN FND_API.g_false ;
   ELSE
      RETURN FND_API.g_true;
   END IF;

END Target_Group_Exist ;


--========================================================================
--PROCEDURE
--    Schedule_Repeat
-- Purpose
--   This package calculates next run for repeating schedules
-- HISTORY
--    10-Oct-2000   dbiswas    Created.
--    29-aug-2005   soagrawa   Modified to add debug component for R12 Monitors / Rpt Sch
--========================================================================

PROCEDURE Schedule_Repeat             ( p_last_run_date    IN   DATE,
                                        p_frequency        IN NUMBER,
                                        p_frequency_type   IN VARCHAR2,
                                        x_next_run_date    OUT NOCOPY  DATE,
                                        x_return_status    OUT NOCOPY  VARCHAR2,
                                        x_msg_count        OUT     NOCOPY NUMBER,
                                        x_msg_data         OUT NOCOPY  VARCHAR2)
IS

    l_last_run_date         DATE ;
    l_frequency            NUMBER;
    l_frequency_type VARCHAR2(30);
    l_next_run_date         DATE ;
    l_api_name       VARCHAR2(30);
    l_msg_count            NUMBER;
    l_msg_data     VARCHAR2(2000);
    l_debug_mode           VARCHAR2(30);
--
BEGIN
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     l_api_name   :='Schedule_Repeat';
     l_last_run_date := p_last_run_date;
     l_frequency := p_frequency;
     l_frequency_type := p_frequency_type;

     WRITE_LOG(l_api_name, 'Schedule_Repeat: Start'||'.'||p_last_run_date);
     WRITE_LOG(l_api_name, 'Schedule_Repeat: Frequency type is '||l_frequency_type);
     WRITE_LOG(l_api_name, 'Schedule_Repeat: Frequency is '||l_frequency);
     WRITE_LOG(l_api_name, 'Schedule_Repeat: Last run date is '||l_last_run_date);

     l_debug_mode := FND_PROFILE.value('AMS_MONITOR_DEBUG_INTERVAL');

     WRITE_LOG(l_api_name, 'Schedule_Repeat: Debug Mode is '||l_debug_mode);

     IF l_debug_mode IS NOT NULL THEN
                l_next_run_date := l_last_run_date + (to_number(l_debug_mode)/(24*60)) ;
     ELSIF l_frequency_type = 'DAILY' THEN
                l_next_run_date := l_last_run_date + l_frequency;
     ELSIF         l_frequency_type = 'WEEKLY' THEN
                l_next_run_date := l_last_run_date + (7 * l_frequency) ;
     ELSIF         l_frequency_type = 'MONTHLY' THEN
                l_next_run_date := add_months(l_last_run_date , l_frequency) ;
     ELSIF         l_frequency_type = 'YEARLY' THEN
                l_next_run_date := add_months(l_last_run_date , (12*l_frequency)) ;
     ElSIF         l_frequency_type = 'HOURLY' THEN
                l_next_run_date := l_last_run_date + (l_frequency/24) ;
     END IF;

     WRITE_LOG(l_api_name, 'Schedule_Repeat: Next run date is '||l_next_run_date);
     x_next_run_date := l_next_run_date ;

     WRITE_LOG (l_api_name, 'Schedule_Repeat: Success'||'.'||p_last_run_date);

EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
               x_return_status := FND_API.G_RET_STS_ERROR ;
               FND_MSG_PUB.count_and_get (
                                           p_count         => x_msg_count,
                                           p_data          => x_msg_data,
                                           p_encoded       => FND_API.G_FALSE
                                          );
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
               FND_MSG_PUB.count_and_get (
                                           p_count         => x_msg_count,
                                           p_data          => x_msg_data,
                                           p_encoded       => FND_API.G_FALSE
                                          );
     WHEN OTHERS THEN
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
               FND_MSG_PUB.count_and_get (
                                           p_count         => x_msg_count,
                                           p_data          => x_msg_data,
                                           p_encoded       => FND_API.G_FALSE
                                          );
END Schedule_Repeat;

--=============================================================================================================
--PROCEDURE
--    Create_Next_Schedule
-- Purpose
--   This package creates the next schedule to be used by the workflow
-- HISTORY
--    10-Oct-2000   dbiswas    Created.
--    18-feb-2004   soagrawa   Fixed bug# 3452264
--    23-mar-2004   soagrawa   Now creating association with OCM item conditionally
--    21-apr-2004   soagrawa   Made changes to fix bug# 3570234
--    28-jan-2005   spendem    fix for bug # 4145845. Added to_char function to the schedule_id
--    17-Mar-2005   spendem    call the API to raise business event on status change as per enh # 3805347
--==============================================================================================================

PROCEDURE Create_Next_Schedule        ( p_parent_sched_id          IN NUMBER,
                                        p_child_sched_st_date      IN   DATE,
                                        p_child_sched_en_date      IN   DATE,
                                        x_child_sched_id        OUT NOCOPY NUMBER,
                                        -- soagrawa added on 18-feb-2004 for bug# 3452264
                                        p_orig_sch_name            IN VARCHAR2 ,
                                        p_trig_repeat_flag            IN VARCHAR2,
                                        x_msg_count      OUT NOCOPY  NUMBER,
                                        x_msg_data      OUT NOCOPY  VARCHAR2,
                                        x_return_status OUT NOCOPY  VARCHAR2
                                       )
IS
    l_parent_sched_id     NUMBER;
    l_child_sched_st_date  DATE;
    l_child_sched_en_date  DATE;

    l_next_run_date        DATE ;
    l_api_name      VARCHAR2(30);

    l_date_suffix   VARCHAR2(25);
    l_dummy               NUMBER;
    l_msg_count          NUMBER ;
    l_msg_data    VARCHAR2(2000);
    l_schedule_rec     AMS_Camp_Schedule_PVT.schedule_rec_type;
    l_new_sched_id NUMBER := NULL;

   CURSOR c_sched(p_orig_sched_id  IN NUMBER) IS
        SELECT *
        FROM ams_campaign_schedules_vl
        WHERE schedule_id = p_orig_sched_id;

      l_parent_rec   c_sched%ROWTYPE;

   CURSOR c_channel_media(p_medium_id NUMBER, p_activity_id NUMBER) IS
   SELECT 1
     FROM ams_media_channels
    WHERE channel_id = p_medium_id
      AND media_id = p_activity_id
      AND ACTIVE_TO_DATE > SYSDATE;

   CURSOR c_def_status(p_status_code VARCHAR2) IS
   SELECT user_status_id
   FROM   ams_user_statuses_b
   WHERE  system_status_type = 'AMS_CAMPAIGN_SCHEDULE_STATUS'
   AND    system_status_code = p_status_code
   AND    default_flag = 'Y'
   AND    enabled_flag = 'Y';

   -- soagrawa added on 21-apr-2004 for bug# 3570234
   CURSOR c_max_sch_det(p_schedule_id NUMBER) IS
   select schedule_id
   from ams_campaign_schedules_b
   where creation_date = (select max(creation_date)
                               from ams_campaign_schedules_b
                              where nvl(orig_csch_id, schedule_id) = p_schedule_id);

   l_tgrp_copy_from_csch_id   NUMBER;

   l_def_avail_status      NUMBER;
   l_def_new_status        NUMBER;
   l_return_status         VARCHAR2(1);

   l_errnum                       NUMBER;
   l_errmsg                       VARCHAR2(3000);
   l_errcode                      VARCHAR2(80);

   CURSOR c_get_assoc IS
   SELECT content_item_id
     FROM ibc_associations
    WHERE association_type_code  = 'AMS_CSCH'
    AND ASSOCIATED_OBJECT_VAL1 = to_char(p_parent_sched_id);  -- fix for bug # 4145845
   l_content_item_id      NUMBER;


BEGIN
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     l_api_name   :='Create_Next_Schedule';

     l_parent_sched_id       := p_parent_sched_id;
     l_child_sched_st_date   := p_child_sched_st_date;
     l_child_sched_en_date   := p_child_sched_en_date;

     OPEN c_sched(p_parent_sched_id);
     FETCH c_sched INTO l_parent_rec ;
     CLOSE c_sched;


    l_schedule_rec.start_date_time     := l_child_sched_st_date;
    l_schedule_rec.end_date_time       := l_child_sched_en_date;
    l_schedule_rec.timezone_id         := l_parent_rec.timezone_id;
    l_schedule_rec.campaign_id         := l_parent_rec.campaign_id;
    l_schedule_rec.use_parent_code_flag:= l_parent_rec.use_parent_code_flag;
    l_schedule_rec.use_parent_code_flag:= l_parent_rec.use_parent_code_flag;
    l_schedule_rec.source_code         := NULL;
    l_schedule_rec.activity_type_code  := l_parent_rec.activity_type_code;
    l_schedule_rec.activity_id         := l_parent_rec.activity_id;
    l_schedule_rec.marketing_medium_id := null;
   -- validate media channel id
    IF l_parent_rec.marketing_medium_id IS NOT NULL
    THEN
        WRITE_LOG (l_api_name, 'Create_Next_Schedule: Orig csch mktmg med is not null'||'.'||l_parent_rec.marketing_medium_id);

        OPEN  c_channel_media(l_parent_rec.marketing_medium_id, l_parent_rec.activity_id);
        FETCH c_channel_media INTO l_dummy;
        CLOSE c_channel_media;

        IF l_dummy IS NULL
        THEN
           l_schedule_rec.marketing_medium_id := null;
        ELSE
           l_schedule_rec.marketing_medium_id := l_parent_rec.marketing_medium_id;
        END IF;
    END IF;
    WRITE_LOG (l_api_name, 'Create_Next_Schedule: Activity id is '|| l_schedule_rec.activity_id||'; Mktg Med is '||l_schedule_rec.marketing_medium_id);


    OPEN  c_def_status('NEW');
    FETCH c_def_status INTO l_def_new_status;
    CLOSE c_def_status;

    l_schedule_rec.user_status_id := l_def_new_status;
    l_schedule_rec.status_code := 'NEW';

    -- -------------------------- COPY COVER LETTER ----------------------------------------

    l_date_suffix := ' - ' || TO_CHAR(SYSDATE,'DD-MON-RRRR HH24:MI:SS');
--   to be completed later

    -- ------------------------- END COPY COVER LETTER -------------------------------------

--  Set the attribs for the child rec
    -- soagrawa modified on 18-feb-2004 for bug# 3452264

    WRITE_LOG (l_api_name, 'CSCH name passed is p_orig_sch_name '||p_orig_sch_name);
    IF p_orig_sch_name is NOT null
    THEN
      -- use this name instead
       IF length(p_orig_sch_name || l_date_suffix) <= 240
       THEN
          l_schedule_rec.schedule_name       := p_orig_sch_name || l_date_suffix;
       ELSE
          l_schedule_rec.schedule_name       := substr(p_orig_sch_name,1,240-length(l_date_suffix)) || l_date_suffix;
       END IF;
    ELSE
       IF length(l_parent_rec.schedule_name || l_date_suffix) <= 240
       THEN
          l_schedule_rec.schedule_name       := l_parent_rec.schedule_name || l_date_suffix;
       ELSE
          l_schedule_rec.schedule_name       := substr(l_parent_rec.schedule_name,1,240-length(l_date_suffix)) || l_date_suffix;
       END IF;
    END IF;

    l_schedule_rec.reply_to_mail       := l_parent_rec.reply_to_mail;
    l_schedule_rec.mail_sender_name    := l_parent_rec.mail_sender_name;
    l_schedule_rec.mail_subject        := l_parent_rec.mail_subject;
    l_schedule_rec.from_fax_no         := l_parent_rec.from_fax_no;
    l_schedule_rec.campaign_calendar   := l_parent_rec.campaign_calendar;

    l_schedule_rec.accounts_closed_flag := l_parent_rec.accounts_closed_flag;
    l_schedule_rec.org_id               := l_parent_rec.org_id;
    l_schedule_rec.objective_code       := l_parent_rec.objective_code;
    l_schedule_rec.country_id           := l_parent_rec.country_id;
    l_schedule_rec.priority             := l_parent_rec.priority;
    l_schedule_rec.transaction_currency_code := l_parent_rec.transaction_currency_code;
    l_schedule_rec.functional_currency_code := l_parent_rec.functional_currency_code;
    l_schedule_rec.language_code        := l_parent_rec.language_code;
    l_schedule_rec.task_id              := l_parent_rec.task_id;
    l_schedule_rec.attribute_category   := l_parent_rec.attribute_category;
    l_schedule_rec.attribute1           := l_parent_rec.attribute1;
    l_schedule_rec.attribute2           := l_parent_rec.attribute2;
    l_schedule_rec.attribute3           := l_parent_rec.attribute3;
    l_schedule_rec.attribute4           := l_parent_rec.attribute4;
    l_schedule_rec.attribute5           := l_parent_rec.attribute5;
    l_schedule_rec.attribute6           := l_parent_rec.attribute6;
    l_schedule_rec.attribute7           := l_parent_rec.attribute7;
    l_schedule_rec.attribute8           := l_parent_rec.attribute8;
    l_schedule_rec.attribute9           := l_parent_rec.attribute9;
    l_schedule_rec.attribute10          := l_parent_rec.attribute10;
    l_schedule_rec.attribute11          := l_parent_rec.attribute11;
    l_schedule_rec.attribute12          := l_parent_rec.attribute12;
    l_schedule_rec.attribute13          := l_parent_rec.attribute13;
    l_schedule_rec.attribute14          := l_parent_rec.attribute14;
    l_schedule_rec.attribute15          := l_parent_rec.attribute15;
    l_schedule_rec.activity_attribute_category := l_parent_rec.activity_attribute_category;
    l_schedule_rec.activity_attribute1  := l_parent_rec.activity_attribute1;
    l_schedule_rec.activity_attribute2  := l_parent_rec.activity_attribute2;
    l_schedule_rec.activity_attribute3  := l_parent_rec.activity_attribute3;
    l_schedule_rec.activity_attribute4  := l_parent_rec.activity_attribute4;
    l_schedule_rec.activity_attribute5  := l_parent_rec.activity_attribute5;
    l_schedule_rec.activity_attribute6  := l_parent_rec.activity_attribute6;
    l_schedule_rec.activity_attribute7  := l_parent_rec.activity_attribute7;
    l_schedule_rec.activity_attribute8  := l_parent_rec.activity_attribute8;
    l_schedule_rec.activity_attribute9  := l_parent_rec.activity_attribute9;
    l_schedule_rec.activity_attribute10 := l_parent_rec.activity_attribute10;
    l_schedule_rec.activity_attribute11 := l_parent_rec.activity_attribute11;
    l_schedule_rec.activity_attribute12 := l_parent_rec.activity_attribute12;
    l_schedule_rec.activity_attribute13 := l_parent_rec.activity_attribute13;
    l_schedule_rec.activity_attribute14 := l_parent_rec.activity_attribute14;
    l_schedule_rec.activity_attribute15 := l_parent_rec.activity_attribute15;
    l_schedule_rec.custom_setup_id      := l_parent_rec.custom_setup_id; -- copy the same, even if disabled
    l_schedule_rec.triggerable_flag     := l_parent_rec.triggerable_flag;
    l_schedule_rec.trigger_id           := l_parent_rec.trigger_id;
    -- soagrawa added on 18-feb-2004 for bug# 3452264
    l_schedule_rec.trig_repeat_flag     := p_trig_repeat_flag;
    l_schedule_rec.tgrp_exclude_prev_flag := l_parent_rec.tgrp_exclude_prev_flag;
    l_schedule_rec.notify_user_id       := l_parent_rec.notify_user_id;
    l_schedule_rec.approver_user_id     := l_parent_rec.approver_user_id;
    l_schedule_rec.owner_user_id        := l_parent_rec.owner_user_id;
--    l_schedule_rec.active_flag          := l_parent_rec.active_flag;
    l_schedule_rec.description           := l_parent_rec.description;
    l_schedule_rec.test_email_address    := l_parent_rec.test_email_address;
    --l_schedule_rec.ORIG_CSCH_ID          := l_parent_rec.schedule_id;

    -- Added by AMLAL : Bug 5611404
    l_schedule_rec.delivery_mode    := l_parent_rec.delivery_mode;

    -- Added by AMLAL : Bug 5738978
    l_schedule_rec.printer_address    := l_parent_rec.printer_address;

    l_schedule_rec.NOTIFY_ON_ACTIVATION_FLAG       := l_parent_rec.NOTIFY_ON_ACTIVATION_FLAG; --anchaud added, sept'05.

    IF l_parent_rec.ORIG_CSCH_ID IS NOT null
      THEN
         l_schedule_rec.ORIG_CSCH_ID := l_parent_rec.ORIG_CSCH_ID;
      ELSE
         l_schedule_rec.ORIG_CSCH_ID := l_parent_rec.schedule_id;
    END IF;

    l_schedule_rec.usage                 := l_parent_rec.usage;
    l_schedule_rec.purpose               := l_parent_rec.purpose;
    l_schedule_rec.sales_methodology_id  := l_parent_rec.sales_methodology_id;

    WRITE_LOG (l_api_name, 'Create_Next_Schedule: Before creating schedule');

    -- soagrawa made this change on 21-apr-2003 for bug# 3570234
    OPEN  c_max_sch_det(l_parent_rec.schedule_id);
    FETCH c_max_sch_det INTO l_tgrp_copy_from_csch_id;
    CLOSE c_max_sch_det;

    AMS_Camp_Schedule_PVT.Create_Camp_Schedule(
                              p_api_version_number         => 1.0,
                              p_init_msg_list              => FND_API.G_FALSE,
                              p_commit                     => FND_API.G_FALSE,
                              p_validation_level           => FND_API.G_VALID_LEVEL_FULL,
                              x_return_status              => l_return_status,
                              x_msg_count                  => l_msg_count,
                              x_msg_data                   => l_msg_data,
                              p_schedule_rec               => l_schedule_rec,
                              x_schedule_id                => l_new_sched_id);

    IF l_return_status <> FND_API.g_ret_sts_success
    THEN
        WRITE_LOG(l_api_name, 'Create_Next_Schedule: ERROR: After create schedule'||l_return_status||'New Schedule name '||l_schedule_rec.schedule_name);
        l_return_status :=  FND_API.g_ret_sts_error;

        FOR i IN 1 .. FND_MSG_PUB.count_msg LOOP
            WRITE_LOG(l_api_name, 'Create_Next_Schedule : (' || i || ') ' || FND_MSG_PUB.get(i, FND_API.g_false));
        END LOOP;

        -- schedule creation was not successful
        x_child_sched_id := null;
        x_msg_data       := l_msg_data;
        x_msg_count      := l_msg_count;
        x_return_status  := l_return_status;
        RETURN;

    ELSE
        WRITE_LOG(l_api_name, 'Create_Next_Schedule: SUCCESS: After create schedule'||l_return_status||'New Schedule name '||l_schedule_rec.schedule_name);
    END IF;


   -- if Schedule creation was successful

    --Associate Cover letter
    WRITE_LOG(l_api_name, 'Create_Next_Schedule: Start Copy cover letter '||l_schedule_rec.schedule_name);
    OPEN c_get_assoc;
    FETCH c_get_assoc INTO l_content_item_id;
    CLOSE c_get_assoc;


   IF FND_API.G_TRUE = Target_Group_Exist(p_parent_sched_id)
   THEN
    -- this if statement added by soagrawa on 23-mar-2004
    IF l_content_item_id IS NOT null
    THEN
       IBC_ASSOCIATIONS_GRP.Create_Association (
            p_api_version         => 1.0,
            p_assoc_type_code     => 'AMS_CSCH',
            p_assoc_object1       => l_new_sched_id,
            p_content_item_id     => l_content_item_id,
            x_return_status       => l_return_status,
            x_msg_count           => l_msg_count,
            x_msg_data            => l_msg_data
         );

       IF l_return_status <> FND_API.g_ret_sts_success
       THEN
           WRITE_LOG(l_api_name, 'Create_Next_Schedule: ERROR: After content association'||l_return_status||'New Schedule name '||l_schedule_rec.schedule_name);
           l_return_status :=  FND_API.g_ret_sts_error;

           FOR i IN 1 .. FND_MSG_PUB.count_msg LOOP
               WRITE_LOG(l_api_name, 'Create_Next_Schedule : (' || i || ') ' || FND_MSG_PUB.get(i, FND_API.g_false));
           END LOOP;

           -- association creation was not successful
           x_child_sched_id := null;
           x_msg_data       := l_msg_data;
           x_msg_count      := l_msg_count;
           x_return_status  := l_return_status;
           RETURN;

       ELSE
           WRITE_LOG(l_api_name, 'Create_Next_Schedule: SUCCESS: Aftercontent association'||l_return_status||'New Schedule name '||l_schedule_rec.schedule_name);
       END IF;
    END IF;
   END IF;


    -- anchaudh : added for copy of collateral contents attached to the non-direct marketing activities for R12 .
     ams_copyelements_pvt.copy_act_collateral(
                         p_src_act_type => 'AMS_COLLAT',
                         p_src_act_id   => l_parent_rec.schedule_id,
                         p_new_act_id   => l_new_sched_id,
                         p_errnum       => l_errnum,
                         p_errcode      => l_errcode,
                         p_errmsg       => l_errmsg);


    -- copy metrices
     WRITE_LOG(l_api_name, 'Create_Next_Schedule: Start Copy metrics for New Schedule name '||l_schedule_rec.schedule_name);
     Ams_ActMetric_Pvt.copy_act_metrics (
                          p_api_version                => 1.0,
                          p_init_msg_list              => FND_API.G_FALSE,
                          p_commit                     => FND_API.G_FALSE,
                          p_validation_level           => FND_API.G_VALID_LEVEL_FULL,
                          p_source_object_type         => 'CSCH',
                          p_source_object_id           => l_parent_rec.schedule_id,
                          p_target_object_id           => l_new_sched_id,
                          x_return_status              => l_return_status,
                          x_msg_count                  => l_msg_count,
                          x_msg_data                   => l_msg_data);

     IF l_return_status <> FND_API.g_ret_sts_success
     THEN
        WRITE_LOG(l_api_name, 'Create_Next_Schedule: ERROR: After copy metrics'||l_return_status||'for new schedule name '||l_schedule_rec.schedule_name);
        l_return_status :=  FND_API.g_ret_sts_error;
        FOR i IN 1 .. FND_MSG_PUB.count_msg LOOP
            WRITE_LOG(l_api_name, 'Create_Next_Schedule : (' || i || ') ' || FND_MSG_PUB.get(i, FND_API.g_false));
        END LOOP;

        -- metrics copying was not successful
        x_child_sched_id := null;
        x_msg_data       := l_msg_data;
        x_msg_count      := l_msg_count;
        x_return_status  := l_return_status;
        RETURN;

     ELSE
        WRITE_LOG(l_api_name, 'Create_Next_Schedule: SUCCESS: After copy metrics'||l_return_status||'for new schedule name '||l_schedule_rec.schedule_name);
     END IF;

     WRITE_LOG (l_api_name, 'Create_Next_Schedule: Before copying TGRP, being copied from CSCH id '||l_tgrp_copy_from_csch_id);

    IF FND_API.G_TRUE = Target_Group_Exist(p_parent_sched_id)
    THEN
     -- copy target group
     AMS_ACT_LIST_PVT.copy_target_group(
                            p_from_schedule_id => l_tgrp_copy_from_csch_id,
                            p_to_schedule_id   => l_new_sched_id,
                            p_list_used_by     => 'CSCH',
                            -- soagrawa made this change on 21-apr-2003 for bug# 3570234
                            p_repeat_flag      => FND_API.G_TRUE,
                            x_msg_count        => l_msg_count,
                            x_msg_data         => l_msg_data,
                            x_return_status    => l_return_status
                           ) ;

     IF l_return_status <> FND_API.g_ret_sts_success
     THEN
        WRITE_LOG(l_api_name, 'Create_Next_Schedule: ERROR: After copy target group'||l_return_status||'for new schedule name '||l_schedule_rec.schedule_name);
        l_return_status :=  FND_API.g_ret_sts_error;
        FOR i IN 1 .. FND_MSG_PUB.count_msg LOOP
            WRITE_LOG(l_api_name, 'Create_Next_Schedule : (' || i || ') ' || FND_MSG_PUB.get(i, FND_API.g_false));
        END LOOP;

        -- target group copying was not successful
        x_child_sched_id := null;
        x_msg_data       := l_msg_data;
        x_msg_count      := l_msg_count;
        x_return_status  := l_return_status;
        RETURN;

     ELSE
        WRITE_LOG(l_api_name, 'Create_Next_Schedule: SUCCESS: After copy target group'||l_return_status||'for new schedule name '||l_schedule_rec.schedule_name);
     END IF;
    END IF;



     -- Update status of new schedule to available
     OPEN  c_def_status('AVAILABLE');
     FETCH c_def_status INTO l_def_avail_status;
     CLOSE c_def_status;

     UPDATE AMS_CAMPAIGN_SCHEDULES_B
        SET STATUS_CODE = 'AVAILABLE' ,
            status_date = sysdate,
            user_status_id = l_def_avail_status
      WHERE SCHEDULE_ID = l_new_sched_id;

     -- call to api to raise business event, as per enh # 3805347
     AMS_SCHEDULERULES_PVT.RAISE_BE_ON_STATUS_CHANGE(p_obj_id => l_new_sched_id,
					             p_obj_type => 'CSCH',
						     p_old_status_code => 'NEW',
						     p_new_status_code => 'AVAILABLE');

     -- set return status
     x_child_sched_id := l_new_sched_id;
     x_msg_data      := l_msg_data;
     x_msg_count     := l_msg_count;
     x_return_status := l_return_status;

   END Create_Next_Schedule;


--========================================================================
--PROCEDURE
--    Create_Scheduler
-- Purpose
--   This procedure creates a row in the ams_scheduler table using the table handler package
-- HISTORY
--    04-may-2005   soagrawa    Created.
--
--========================================================================

PROCEDURE Create_Scheduler        (           p_obj_type    VARCHAR2,
					      p_obj_id    NUMBER,
					      p_freq    NUMBER,
					      p_freq_type    VARCHAR2,
                                              x_msg_count      OUT NOCOPY  NUMBER,
                                              x_msg_data      OUT NOCOPY  VARCHAR2,
                                              x_return_status OUT NOCOPY  VARCHAR2,
                                              x_scheduler_id  OUT NOCOPY  NUMBER
                                       )
IS
     l_scheduler_id   NUMBER;
     l_object_version_number  NUMBER := 1;
     CURSOR c_id IS
       SELECT ams_scheduler_s.NEXTVAL
       FROM dual;


BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   OPEN c_id;
   FETCH c_id INTO l_scheduler_id;
   CLOSE c_id;

   AMS_SCHEDULER_B_PKG.Insert_Row(
          px_scheduler_id  => l_scheduler_id,
          p_created_by  => FND_GLOBAL.USER_ID,
	  p_creation_date  => SYSDATE,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_last_update_date  => SYSDATE,
          p_last_update_login  => FND_GLOBAL.LOGIN_ID,
          px_object_version_number   => l_object_version_number,
          p_object_type    => p_obj_type,
          p_object_id    => p_obj_id,
          p_frequency    => p_freq,
          p_frequency_type    => p_freq_type
	  );

   x_scheduler_id := l_scheduler_id;

END Create_Scheduler;

END AMS_Scheduler_PVT ;

/
