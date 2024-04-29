--------------------------------------------------------
--  DDL for Package Body AMS_SCHEDULERULES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_SCHEDULERULES_PVT" AS
/* $Header: amsvsbrb.pls 120.31.12010000.3 2009/06/19 11:23:05 rsatyava ship $ */


g_pkg_name   CONSTANT VARCHAR2(30):='AMS_ScheduleRules_PVT';
g_log_level  CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
--========================================================================
-- FUNCTION
--    Target_Group_Exist
-- Purpose
--    Created to check if the target group exist or not.
-- HISTORY
--    19-Jan-2000   ptendulk    Created.
--    31-jan-2002   soagrawa    Modified signature to take used_by as well
--                              so that events team could use it too
--                              This is related to fix for bug# 2207286
--========================================================================
AMS_DEBUG_HIGH_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);



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
-- PROCEDURE
--    Handle_Status
-- Purpose
--    Created to get the system status code for the user status id
-- HISTORY
--    19-Jan-2000   ptendulk    Created.
--
--========================================================================
PROCEDURE Handle_Status(
   p_user_status_id    IN     NUMBER,
   p_sys_status_code   IN     VARCHAR2,
   x_status_code       OUT NOCOPY    VARCHAR2,
   x_return_status     OUT NOCOPY    VARCHAR2
)
IS

   l_status_code     VARCHAR2(30);

   CURSOR c_status_code IS
   SELECT system_status_code
   FROM   ams_user_statuses_vl
   WHERE  user_status_id = p_user_status_id
   AND    system_status_type = p_sys_status_code
   AND    enabled_flag = 'Y';

BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   OPEN  c_status_code;
   FETCH c_status_code INTO l_status_code;
   CLOSE c_status_code;

   IF l_status_code IS NULL THEN
      x_return_status := FND_API.g_ret_sts_error;
      AMS_Utility_PVT.error_message('AMS_CAMP_BAD_USER_STATUS');
   END IF;

   x_status_code := l_status_code;

END Handle_Status;


--========================================================================
-- PROCEDURE
--    validate_activation_rules
-- Purpose
--    Created to validate the activation rules going forward in R12
-- HISTORY
--    27-Jul-2005   anchaudh    Created.
--
--========================================================================
PROCEDURE validate_activation_rules(
   p_scheduleid    IN     NUMBER,
   x_status_code   OUT NOCOPY    VARCHAR2
)
IS
   l_status_code     VARCHAR2(30);
   l_return_status  VARCHAR2(1);
   l_msg_count      NUMBER;
   l_msg_data       VARCHAR2(2000);

BEGIN

   SAVEPOINT validate_activation_rules;

   -- Initialize API return status to SUCCESS
   x_status_code := FND_API.G_RET_STS_SUCCESS;

   AMS_ScheduleRules_PVT.collateral_activation_rule(
    p_scheduleid         => p_scheduleid,
    x_status_code        => l_return_status,
    x_msg_count          => l_msg_count,
    x_msg_data           => l_msg_data)  ;

   IF l_return_status = fnd_api.g_ret_sts_error THEN
      x_status_code := FND_API.g_ret_sts_error;
      RAISE FND_API.g_exc_error;
   END IF;

   --similarly, call other validation apis also, as the api validate_activation_rules itself is just a placeholder
   -- for other valiation rules api like collateral,collaboration validations etc.

   /*AMS_Collab_assoc_PVT .IS_COLLAB_CONTENT_APPROVED (p_schedule_id   => p_schedule_id,
                                               x_return_status => l_return_status,
                      x_msg_count          => l_msg_count,
                                               x_msg_data           => l_msg_data)  ;

   IF l_return_status = fnd_api.g_ret_sts_error THEN
      x_status_code := FND_API.g_ret_sts_error;
      RAISE FND_API.g_exc_error;
   END IF;*/

   AMS_WEBMARKETING_PVT.WEBMARKETING_CONTENT_STATUS (p_campaign_activity_id   => p_scheduleid,
                                               x_return_status => l_return_status,
                      x_msg_count          => l_msg_count,
                                               x_msg_data           => l_msg_data);

   IF l_return_status = fnd_api.g_ret_sts_error THEN
      x_status_code := FND_API.g_ret_sts_error;
      RAISE FND_API.g_exc_error;
   END IF;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

       ROLLBACK TO validate_activation_rules;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

       ROLLBACK TO validate_activation_rules;

   WHEN OTHERS THEN

       ROLLBACK TO validate_activation_rules;


END validate_activation_rules;


--=================================================================================
-- PROCEDURE
--    collateral_activation_rule
-- Purpose
--    Created to validate the collateral content status before activity activation
-- HISTORY
--    27-Jul-2005   anchaudh    Created.
--
--=================================================================================
PROCEDURE collateral_activation_rule(
   p_scheduleid    IN     NUMBER,
   x_status_code   OUT NOCOPY    VARCHAR2,
   x_msg_count     OUT NOCOPY    NUMBER,
   x_msg_data      OUT NOCOPY    VARCHAR2
)
IS
   l_status_code        VARCHAR2(30);
   l_content_name_text  VARCHAR2 (2000):= null;
   l_content_name_text_dm  VARCHAR2 (2000):= null;
   l_content_item_id    NUMBER;
   l_content_item_exists_id    NUMBER;
   l_content_item_exists_ndm_id  NUMBER;
   l_content_item_id_dm    NUMBER;
   l_activity_id        NUMBER;
   l_activity_type_code VARCHAR2(30);
   l_content_name       VARCHAR2 (2000);
   l_content_name_dm      VARCHAR2 (2000);
   l_content_name_exists VARCHAR2 (2000);
   l_content_exists      VARCHAR2(1) := 'Y';
   l_content_exists_ndm  VARCHAR2(1) := 'Y';


   CURSOR c_sched_details IS
   SELECT activity_id,activity_type_code
   FROM   ams_campaign_schedules_b
   WHERE  schedule_id = p_scheduleid;

   CURSOR C_Content_CL( l_obj_id IN NUMBER)   IS
   SELECT ibcassn.content_item_id,citm.name
   FROM   IBC_ASSOCIATIONS IbcAssn,ibc_citems_v citm
   WHERE  IbcAssn.ASSOCIATED_OBJECT_VAL1 = to_char(l_obj_id )
   AND     IbcAssn.Content_item_id    = citm.citem_id
   AND    citm.item_status <> 'APPROVED'
   AND    ibcassn.ASSOCIATION_TYPE_CODE = 'AMS_CSCH' ;

   CURSOR C_Content_NDM( l_obj_id IN NUMBER)   IS
   SELECT ibcassn.content_item_id,citm.name
   FROM   IBC_ASSOCIATIONS IbcAssn,ibc_citems_v citm
   WHERE  IbcAssn.ASSOCIATED_OBJECT_VAL1 = to_char(l_obj_id )
   AND     IbcAssn.Content_item_id    = citm.citem_id
   AND    citm.item_status <> 'APPROVED'
   AND    ibcassn.ASSOCIATION_TYPE_CODE = 'AMS_COLLAT'
   AND    citm.VERSION = 1 ;

   CURSOR C_Content_Exists( l_obj_id IN NUMBER)   IS
   SELECT count(1)
   FROM   IBC_ASSOCIATIONS IbcAssn,ibc_citems_v citm
   WHERE  IbcAssn.ASSOCIATED_OBJECT_VAL1 = to_char(l_obj_id )
   AND     IbcAssn.Content_item_id    = citm.citem_id
   AND    ibcassn.ASSOCIATION_TYPE_CODE in ('AMS_CSCH') ;

   CURSOR C_Content_Exists_NDM( l_obj_id IN NUMBER)   IS
   SELECT count(1)
   FROM   IBC_ASSOCIATIONS IbcAssn,ibc_citems_v citm
   WHERE  IbcAssn.ASSOCIATED_OBJECT_VAL1 = to_char(l_obj_id )
   AND     IbcAssn.Content_item_id    = citm.citem_id
   AND    ibcassn.ASSOCIATION_TYPE_CODE in ('AMS_COLLAT') ;


BEGIN

   l_status_code := FND_API.g_ret_sts_success;

   OPEN c_sched_details ;
   FETCH c_sched_details INTO l_activity_id,l_activity_type_code;
   CLOSE c_sched_details ;

   OPEN  C_Content_Exists(p_scheduleid);
    LOOP
      FETCH C_Content_Exists INTO l_content_item_exists_id;
      if (l_content_item_exists_id = 0) then
   l_content_exists := 'N';
   exit;
      else
        l_content_exists := 'Y';
   exit;
      end if;

    END LOOP;
   CLOSE C_Content_Exists;

   OPEN  C_Content_Exists_NDM(p_scheduleid);
    LOOP
      FETCH C_Content_Exists_NDM INTO l_content_item_exists_ndm_id;
      if (l_content_item_exists_ndm_id = 0) then
   l_content_exists_ndm := 'N';
   exit;
      else
        l_content_exists_ndm := 'Y';
   exit;
      end if;
    END LOOP;
   CLOSE C_Content_Exists_NDM;


   if (l_activity_type_code = 'DIRECT_MARKETING') then

      IF (l_content_exists = 'Y')  THEN

         --anchaudh : starts : cover letter related validation during activity activation.
         if (l_activity_id = 10 OR l_activity_id = 20 OR l_activity_id = 480) then
          OPEN  C_Content_CL(p_scheduleid);
              LOOP
            FETCH C_Content_CL INTO l_content_item_id,l_content_name;
            EXIT WHEN C_Content_CL%NOTFOUND;
         if (C_Content_CL%found) then
            l_status_code := fnd_api.g_ret_sts_error;
         end if;
          END LOOP;
          CLOSE C_Content_CL;

          If l_status_code = fnd_api.g_ret_sts_error THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
             FND_MESSAGE.set_name('AMS', 'AMS_COVER_LETTER_APPRV_MSG');
             FND_MESSAGE.Set_Token('COVER_LETTER_NAME',l_content_name);
             FND_MSG_PUB.add;
         END IF;

         FND_MSG_PUB.Count_AND_Get( p_count           =>      x_msg_count,
                  p_data            =>      x_msg_data,
                  p_encoded         =>      FND_API.G_FALSE
                );
          END IF;
         end if;
         --anchaudh : ends : cover letter related validation during activity activation.

         --anchaudh : starts : generic direct marketing collateral content's validation during activity activation.

         IF ((l_activity_type_code = 'DIRECT_MARKETING') AND (l_activity_id <> 10 AND l_activity_id <> 20 AND l_activity_id <> 480)) THEN

           OPEN  C_Content_CL(p_scheduleid);
           LOOP
            FETCH C_Content_CL INTO l_content_item_id_dm,l_content_name_dm;
            EXIT WHEN C_Content_CL%NOTFOUND;
         if (C_Content_CL%found) then
            l_status_code := fnd_api.g_ret_sts_error;

            if(l_content_name_dm is not null) then
             if (l_content_name_text_dm is null) then
               l_content_name_text_dm := l_content_name_dm;
                  else
               l_content_name_text_dm := l_content_name_text_dm || ',' || l_content_name_dm ;
                  end if;
            end if;

         end if;
           END LOOP;
           CLOSE C_Content_CL;

           If l_status_code = fnd_api.g_ret_sts_error THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
             FND_MESSAGE.set_name('AMS', 'AMS_COLLATEARL_CONTENT_APRVMSG');
             FND_MESSAGE.Set_Token('COLLATERAL_CONTENT_NAMES', l_content_name_text_dm);
             FND_MSG_PUB.add;
         END IF;

         FND_MSG_PUB.Count_AND_Get( p_count           =>      x_msg_count,
                  p_data            =>      x_msg_data,
                  p_encoded         =>      FND_API.G_FALSE
                );
           END IF;

         END IF;

      --anchaudh : ends : generic direct marketing collateral content's validation during activity activation.

      ELSIF (l_activity_id <> 460 ) THEN --kbasavar skip the validation for telemarketing

          l_status_code := fnd_api.g_ret_sts_error;

          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
            THEN
           FND_MESSAGE.set_name('AMS', 'AMS_COLLAT_CONTENT_NOT_EXISTS');
           FND_MSG_PUB.add;
          END IF;

          FND_MSG_PUB.Count_AND_Get( p_count           =>      x_msg_count,
                  p_data            =>      x_msg_data,
                  p_encoded         =>      FND_API.G_FALSE);

      END IF;--IF (l_content_exists = 'Y') THEN

   end if;--if (l_activity_type_code = 'DIRECT_MARKETING')

   if(l_content_exists_ndm = 'Y') then
   --anchaudh : starts : collateral content in NMD activity related validation during the activity activation.
   IF ((l_activity_type_code = 'BROADCAST') OR (l_activity_type_code = 'PUBLIC_RELATIONS') OR (l_activity_type_code = 'IN_STORE')) THEN
    OPEN  C_Content_NDM(p_scheduleid);
    LOOP
      FETCH C_Content_NDM INTO l_content_item_id,l_content_name;
      EXIT WHEN C_Content_NDM%NOTFOUND;
   if (C_Content_NDM%found) then
      l_status_code := fnd_api.g_ret_sts_error;
      if(l_content_name is not null) then
       if (l_content_name_text is null) then
         l_content_name_text := l_content_name;
            else
         l_content_name_text := l_content_name_text || ',' || l_content_name ;
            end if;
      end if;
   end if;
    END LOOP;
    CLOSE C_Content_NDM;

    If l_status_code = fnd_api.g_ret_sts_error THEN
   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
   THEN
       FND_MESSAGE.set_name('AMS', 'AMS_COLLATEARL_CONTENT_APRVMSG');
       FND_MESSAGE.Set_Token('COLLATERAL_CONTENT_NAMES', l_content_name_text);
       FND_MSG_PUB.add;
   END IF;

   FND_MSG_PUB.Count_AND_Get( p_count           =>      x_msg_count,
            p_data            =>      x_msg_data,
            p_encoded         =>      FND_API.G_FALSE
          );
    END IF;
   END IF;
   --anchaudh : ends : collateral content in NDM activity related validation during the activity activation.
   end if;--if(l_content_exists_ndm = 'Y')


   x_status_code := l_status_code;

END collateral_activation_rule;



--========================================================================
-- FUNCTION
--    Generate_Schedule_Code
-- Purpose
--    Created to generate source code for schedule.
--
-- Note
--    Schedule code is generated using combination
--     camp source code + custom setup suffix + unique number
--
-- HISTORY
--    30-Jan-2000   ptendulk    Created.
--
--========================================================================
FUNCTION Generate_Schedule_Code(p_campaign_source_code   IN    VARCHAR2,
                                p_setup_id               IN    NUMBER)
   RETURN VARCHAR2
IS
   PRAGMA AUTONOMOUS_TRANSACTION;
   CURSOR c_sequence_value IS
      SELECT gde.scode_number_element
      FROM   ams_generated_codes gde
      WHERE gde.scode_char_element = p_campaign_source_code
      FOR UPDATE ;

   CURSOR c_setup_suffix IS
      SELECT source_code_suffix
      FROM   ams_custom_setups_b
      WHERE  custom_setup_id = p_setup_id  ;

   l_suffix VARCHAR2(3);
   l_seq    NUMBER ;
   l_source_code VARCHAR2(50);  --anchaudh bug fix 3861594
BEGIN
   OPEN c_setup_suffix ;
   FETCH c_setup_suffix INTO l_suffix ;
   CLOSE c_setup_suffix ;

   IF l_suffix IS NULL
   THEN
      l_suffix := '' ;
   END IF ;

   OPEN c_sequence_value;
   FETCH c_sequence_value INTO l_seq;
   CLOSE c_sequence_value;

   IF l_seq IS NULL THEN
      l_seq := 0 ;

      INSERT INTO ams_generated_codes (
         gen_code_id,
         last_update_date,
         last_updated_by,
         creation_date,
         created_by,
         last_update_login,
         object_version_number,
         scode_char_element,
         scode_number_element,
         arc_source_code_for
      ) VALUES (
         ams_source_codes_gen_s.NEXTVAL,
         SYSDATE,
         FND_GLOBAL.user_id,
         SYSDATE,
         FND_GLObAL.user_id,
         FND_GLOBAL.conc_login_id,
         1,    -- object version number
         p_campaign_source_code,
         0,
         'NONE'   -- Not generated for any specific object
      );

        COMMIT;
      l_source_code := p_campaign_source_code || l_suffix || TO_CHAR(l_seq) ;
   ELSE
      -- Update the generate code with the new
      -- upper limit of the numeric sequence.
      LOOP
         l_source_code := p_campaign_source_code || l_suffix || TO_CHAR(l_seq + 1) ;
         EXIT WHEN AMS_SourceCode_PVT.is_source_code_unique (l_source_code) = FND_API.g_true;
         l_seq := l_seq + 1 ;
      END LOOP;

      UPDATE ams_generated_codes gde
      SET    gde.scode_number_element = l_seq + 1
      WHERE  gde.scode_char_element = p_campaign_source_code ;
      COMMIT ;

   END IF ;

   RETURN l_source_code ;

END Generate_Schedule_Code;

--========================================================================
-- PROCEDURE
--    Handle_Schedule_Source_Code
-- Purpose
--    Created to get the source code for the schedules.
-- HISTORY
--    30-Jan-2000   ptendulk    Created.
--
--========================================================================
PROCEDURE Handle_Schedule_Source_Code(
   p_source_code    IN  VARCHAR2,
   p_camp_id        IN  NUMBER,
   p_setup_id       IN  NUMBER,
   p_cascade_flag   IN  VARCHAR2,
   x_source_code    OUT NOCOPY VARCHAR2,
   x_return_status  OUT NOCOPY VARCHAR2
)
IS

   CURSOR c_camp IS
   SELECT source_code,
          global_flag
     FROM ams_campaigns_vl
    WHERE campaign_id = p_camp_id;

   l_source_code   VARCHAR2(30);
   l_dummy_src_code VARCHAR2(50);
   l_global_flag   VARCHAR2(1);

BEGIN

   x_source_code := p_source_code;
   x_return_status := FND_API.g_ret_sts_success;

   OPEN c_camp;
   FETCH c_camp INTO l_source_code, l_global_flag;
   IF c_camp%NOTFOUND THEN  -- campaign_id is invalid
      CLOSE c_camp;
      x_return_status := FND_API.g_ret_sts_error;
      AMS_Utility_PVT.error_message('AMS_CAMP_BAD_ID');
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_camp;

   IF p_cascade_flag = 'Y' THEN
      IF p_source_code IS NULL THEN
         x_source_code := l_source_code;
      ELSIF p_source_code <> l_source_code THEN
         x_return_status := FND_API.g_ret_sts_error;
         AMS_Utility_PVT.error_message('AMS_CSCH_CODE_NOT_CASCADE');
      END IF;
   ELSE
      IF p_source_code IS NULL THEN
         l_dummy_src_code := Generate_Schedule_Code(l_source_code,p_setup_id);
         --x_source_code := AMS_SourceCode_PVT.get_new_source_code(
         --   'CSCH', p_setup_id, l_global_flag);
    --anchaudh bug fix 3861594 starts
         IF(length(l_dummy_src_code) > 30) THEN
            x_return_status := FND_API.g_ret_sts_error;
            AMS_Utility_PVT.error_message('AMS_CSCH_SRC_CODE_ERROR');
         ELSE
            x_source_code := l_dummy_src_code; --Generate_Schedule_Code(l_source_code,p_setup_id);
            --x_source_code := AMS_SourceCode_PVT.get_new_source_code(
            --   'CSCH', p_setup_id, l_global_flag);
         END IF;
         --anchaudh bug fix 3861594 ends
      ELSIF AMS_SourceCode_PVT.is_source_code_unique(p_source_code) = FND_API.g_false
      THEN
         x_return_status := FND_API.g_ret_sts_error;
         AMS_Utility_PVT.error_message('AMS_CAMP_DUPLICATE_CODE');
      END IF;
   END IF;

END Handle_Schedule_Source_Code;

--========================================================================
-- PROCEDURE
--    Push_Source_Code
-- Purpose
--    Created to push the source code for the schedule
--    after the schedule is created.
-- HISTORY
--    19-Jan-2000   ptendulk    Created.
--    16-May-2001   soagrawa
--
--========================================================================
PROCEDURE Push_Source_Code(
           p_source_code    IN  VARCHAR2,
           p_arc_object     IN  VARCHAR2,
           p_object_id      IN  NUMBER,
           p_related_source_code    IN    VARCHAR2 := NULL,
           p_related_source_object  IN    VARCHAR2 := NULL,
           p_related_source_id      IN    NUMBER   := NULL
)
IS

   l_sourcecode_id  NUMBER;
   l_return_status  VARCHAR2(1);
   l_msg_count      NUMBER;
   l_msg_data       VARCHAR2(2000);

BEGIN

   AMS_SourceCode_PVT.Create_SourceCode(
      p_api_version        => 1.0,
      p_init_msg_list      => FND_API.g_false,
      p_commit             => FND_API.g_false,
      p_validation_level   => FND_API.g_valid_level_full,

      x_return_status      => l_return_status,
      x_msg_count          => l_msg_count,
      x_msg_data           => l_msg_data,

      p_sourcecode         => p_source_code,
      p_sourcecode_for     => p_arc_object,
      p_sourcecode_for_id  => p_object_id,
      p_related_sourcecode => p_related_source_code,
      p_releated_sourceobj => p_related_source_object,
      p_related_sourceid   => p_related_source_id,
      x_sourcecode_id      => l_sourcecode_id
   );

   IF l_return_status <> FND_API.g_ret_sts_success THEN
      RAISE FND_API.g_exc_error;
   END IF;

END Push_Source_Code;



--========================================================================
-- PROCEDURE
--    Check_Source_Code
--
-- Purpose
--    Created to check the source code for the schedule before updation
--
-- HISTORY
--    19-Jan-2000   ptendulk    Created.
--    12-DEC-2001   soagrawa    Logic modified by soagrawa. Bug# 2133264:
--                              entire procedure rewritten
--    31-jan-2001   soagrawa    Fixed code for bug# 2207286 (re: TGRP and source code)
--========================================================================

/*PROCEDURE Check_Source_Code(
   p_schedule_rec   IN  AMS_Camp_Schedule_PVT.schedule_rec_type,
   x_return_status  OUT NOCOPY VARCHAR2
)
IS

   l_cascade_flag  VARCHAR2(1);
   l_source_code   VARCHAR2(30);
   l_camp_id       NUMBER;
   l_dummy         NUMBER;
   l_msg_count     NUMBER;
   l_msg_data      VARCHAR2(2000);

   CURSOR c_source_code IS
   SELECT 1
     FROM ams_source_codes
    WHERE source_code = p_schedule_rec.source_code
      AND active_flag = 'Y';

   CURSOR c_schedule IS
   SELECT campaign_id, source_code, use_parent_code_flag
     FROM ams_campaign_schedules_b
    WHERE schedule_id = p_schedule_rec.schedule_id;

   CURSOR c_list_header IS
   SELECT 1
     FROM ams_list_headers_all
    WHERE arc_list_used_by = 'CSCH'
      AND list_used_by_id = p_schedule_rec.schedule_id
      AND status_code <> 'NEW';

BEGIN
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message('Check Source Code ');
   END IF;
   x_return_status := FND_API.g_ret_sts_success;

   -- cannot update to null
   IF p_schedule_rec.source_code IS NULL THEN
      AMS_Utility_PVT.Error_Message('AMS_CAMP_NO_SOURCE_CODE');
      RAISE FND_API.g_exc_error;
   END IF;

   -- query the campaign_id and the old source_code
   OPEN c_schedule;
   FETCH c_schedule INTO l_camp_id, l_source_code, l_cascade_flag ;
   IF c_schedule%NOTFOUND THEN
      CLOSE c_schedule;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_schedule;

   -- if source_code is not changed, return
   IF p_schedule_rec.source_code = FND_API.g_miss_char
   OR p_schedule_rec.source_code = l_source_code
   THEN
      RETURN;
   END IF;

   -- check if source code is cascaded from campaign
   IF l_cascade_flag = 'Y' THEN
      x_return_status := FND_API.g_ret_sts_error;
      AMS_Utility_PVT.error_message('AMS_CSCH_CODE_NOT_CASCADE');
      RETURN;
   END IF;
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message('Check Source Code uniqueness ');
   END IF;
   -- check if the new source code is unique
   OPEN c_source_code;
   FETCH c_source_code INTO l_dummy;
   CLOSE c_source_code;
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message('Dup Code '||l_dummy);
   END IF;
   IF l_dummy IS NOT NULL THEN
      AMS_Utility_PVT.error_message('AMS_CAMP_DUPLICATE_CODE');
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

   -- cannot update source code if schedule has "old" list headers
   OPEN c_list_header;
   FETCH c_list_header INTO l_dummy;
   CLOSE c_list_header;
   IF l_dummy IS NOT NULL THEN
      AMS_Utility_PVT.error_message('AMS_CSCH_UPDATE_SOURCE_CODE');
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_Utility_PVT.debug_message('Revoke Source Code ');

   END IF;
   AMS_SourceCode_PVT.revoke_sourcecode(
      p_api_version        => 1.0,
      p_init_msg_list      => FND_API.g_false,
      p_commit             => FND_API.g_false,
      p_validation_level   => FND_API.g_valid_level_full,

      x_return_status      => x_return_status,
      x_msg_count          => l_msg_count,
      x_msg_data           => l_msg_data,

      p_sourcecode         => l_source_code
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RAISE FND_API.g_exc_error;
   END IF;

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_Utility_PVT.debug_message('Create  Source Code ');

   END IF;
   AMS_SourceCode_PVT.create_sourcecode(
      p_api_version        => 1.0,
      p_init_msg_list      => FND_API.g_false,
      p_commit             => FND_API.g_false,
      p_validation_level   => FND_API.g_valid_level_full,

      x_return_status      => x_return_status,
      x_msg_count          => l_msg_count,
      x_msg_data           => l_msg_data,

      p_sourcecode         => p_schedule_rec.source_code,
      p_sourcecode_for     => 'CSCH',
      p_sourcecode_for_id  => p_schedule_rec.schedule_id,
      p_related_sourcecode => p_schedule_rec.related_source_code,
      p_releated_sourceobj => p_schedule_rec.related_source_object,
      p_related_sourceid   => p_schedule_rec.related_source_id,
      x_sourcecode_id      => l_dummy
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RAISE FND_API.g_exc_error;
   END IF;

END Check_Source_Code;
*/

PROCEDURE Check_Source_Code(
   p_schedule_rec   IN AMS_Camp_Schedule_PVT.schedule_rec_type,
   x_return_status  OUT NOCOPY VARCHAR2,
   x_source_code    OUT NOCOPY VARCHAR2
)
IS

   l_cascade_flag  VARCHAR2(1);
   l_source_code   VARCHAR2(30);
   p_sch_source_code VARCHAR2(30);
   l_camp_id       NUMBER;
   l_dummy         NUMBER;
   l_msg_count     NUMBER;
   l_msg_data      VARCHAR2(2000);

   l_camp_source_code   VARCHAR2(30);
   l_camp_global_flag   VARCHAR2(1);

   CURSOR c_source_code IS
   SELECT 1
     FROM ams_source_codes
    WHERE source_code = p_schedule_rec.source_code
      AND active_flag = 'Y';

   CURSOR c_schedule IS
   SELECT campaign_id, source_code, use_parent_code_flag
     FROM ams_campaign_schedules_b
    WHERE schedule_id = p_schedule_rec.schedule_id;

   CURSOR c_list_header IS
   SELECT 1
     FROM ams_list_headers_all
    WHERE arc_list_used_by = 'CSCH'
      AND list_used_by_id = p_schedule_rec.schedule_id
      AND status_code <> 'NEW';

   CURSOR c_camp IS
   SELECT source_code,
          global_flag
     FROM ams_campaigns_vl
    WHERE campaign_id = p_schedule_rec.campaign_id;

BEGIN
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message('Check Source Code ');
   END IF;
   x_return_status := FND_API.g_ret_sts_success;


   -- query the campaign_id and the old source_code
   OPEN c_schedule;
   FETCH c_schedule INTO l_camp_id, l_source_code, l_cascade_flag;
   IF c_schedule%NOTFOUND THEN
      CLOSE c_schedule;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
      RETURN;
   END IF;
   CLOSE c_schedule;

   x_source_code := l_source_code;
   p_sch_source_code := l_source_code;

   -- commented out by soagrawa on 31-jan-2002 as no longer valid
   -- cannot update source code if schedule has "old" list headers
   /*
   OPEN c_list_header;
   FETCH c_list_header INTO l_dummy;
   CLOSE c_list_header;
   IF l_dummy IS NOT NULL THEN
      AMS_Utility_PVT.error_message('AMS_CSCH_UPDATE_SOURCE_CODE');
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;
   */

   -- if source_code is not changed, return
   IF /*p_schedule_rec.source_code = FND_API.g_miss_char
   OR */p_schedule_rec.source_code = l_source_code
   THEN
      RETURN;
   END IF;

   -- following code added by soagrawa on 31-jan-2002 for bug# 2207286
   IF FND_API.G_TRUE = Target_Group_Exist(p_schedule_rec.schedule_id) THEN
      AMS_Utility_PVT.Error_Message('AMS_CSCH_UPDATE_SOURCE_CODE');
      RAISE FND_API.g_exc_error;
   END IF ;

   -- get campaign's source code
   OPEN c_camp;
   FETCH c_camp INTO l_camp_source_code, l_camp_global_flag;
   IF c_camp%NOTFOUND THEN  -- campaign_id is invalid
      CLOSE c_camp;
      x_return_status := FND_API.g_ret_sts_error;
      AMS_Utility_PVT.error_message('AMS_CAMP_BAD_ID');
      RAISE FND_API.g_exc_error;
      RETURN;
   END IF;
   CLOSE c_camp;


   -- Logic for source code update:
   -- if cascade flag is Y
   --    if current source code == campaign source code
   --       => return
   --    else
   --       => 1. revoke old source code
   --          2. take campaign's source code to populate schedule's

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_Utility_PVT.debug_message('Check Source Code: use parent source code flag is '||p_schedule_rec.use_parent_code_flag);

   END IF;
   l_cascade_flag := p_schedule_rec.use_parent_code_flag;


   -- check if source code is cascaded from campaign
   IF l_cascade_flag = 'Y' THEN
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_Utility_PVT.debug_message('Check Source Code: use parent source code flag is Y');
      END IF;
      IF l_source_code = l_camp_source_code
      THEN
         IF (AMS_DEBUG_HIGH_ON) THEN

         AMS_Utility_PVT.debug_message('nothing to change');
         END IF;
         RETURN;
      ELSE
         -- revoke old source code
         IF (AMS_DEBUG_HIGH_ON) THEN

         AMS_Utility_PVT.debug_message('revoke previous, and put campaign source code');
         END IF;
         AMS_SourceCode_PVT.revoke_sourcecode(
            p_api_version        => 1.0,
            p_init_msg_list      => FND_API.g_false,
            p_commit             => FND_API.g_false,
            p_validation_level   => FND_API.g_valid_level_full,

            x_return_status      => x_return_status,
            x_msg_count          => l_msg_count,
            x_msg_data           => l_msg_data,

            p_sourcecode         => l_source_code
         );
         IF x_return_status <> FND_API.g_ret_sts_success THEN
            RAISE FND_API.g_exc_error;
            RETURN;
         END IF;

         -- populate camp's srccd into schedule
         x_source_code := l_camp_source_code;
         IF (AMS_DEBUG_HIGH_ON) THEN

         AMS_Utility_PVT.debug_message('put campaign source code - all OK');
         END IF;
      END IF;


   -- else   (Cascade flag is N)
   --    if source code is null
   --       => 1. system generate it
   --          2. push it into the source code table
   --    else (not null)
   --       => 1. check for uniqueness
   --              if unique => push it in source code table
   --              else error out.


   ELSE   -- cascade flag is N
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_Utility_PVT.debug_message('Check Source Code: use parent source code flag is N');
      END IF;
      IF p_schedule_rec.source_code IS NULL
         OR p_schedule_rec.source_code = FND_API.g_miss_char
         OR p_schedule_rec.source_code = ''
         THEN
         IF (AMS_DEBUG_HIGH_ON) THEN

         AMS_Utility_PVT.debug_message('Gotta system generate it');
         END IF;
         -- system generate it
         x_source_code := Generate_Schedule_Code(l_camp_source_code,p_schedule_rec.custom_setup_id);
         -- see if current in database is same as campaign's
         IF p_sch_source_code <> l_camp_source_code THEN
            -- revoke
            IF (AMS_DEBUG_HIGH_ON) THEN

            AMS_Utility_PVT.debug_message('Revoke Source Code '||p_sch_source_code);
            END IF;
            AMS_SourceCode_PVT.revoke_sourcecode(
               p_api_version        => 1.0,
               p_init_msg_list      => FND_API.g_false,
               p_commit             => FND_API.g_false,
               p_validation_level   => FND_API.g_valid_level_full,

               x_return_status      => x_return_status,
               x_msg_count          => l_msg_count,
               x_msg_data           => l_msg_data,

               p_sourcecode         => p_sch_source_code
            );
            IF x_return_status <> FND_API.g_ret_sts_success THEN
               RAISE FND_API.g_exc_error;
               RETURN;
            END IF;
         END IF;

            IF (AMS_DEBUG_HIGH_ON) THEN



            AMS_Utility_PVT.debug_message('push it '||x_source_code);

            END IF;
            -- push system generated one into source code table

            -- soagrawa 22-oct-2002 for bug# 2594717
            IF P_schedule_rec.related_event_id IS NOT NULL
            THEN
               AMS_CampaignRules_PVT.push_source_code(
                  x_source_code,
                  'CSCH',
                  p_schedule_rec.schedule_id,
                  p_schedule_rec.related_source_code,
                  p_schedule_rec.related_source_object,
                  p_schedule_rec.related_source_id
                 );
            ELSE
               AMS_CampaignRules_PVT.push_source_code(
                  x_source_code,
                  'CSCH',
                  p_schedule_rec.schedule_id
                 );
            END IF;

      ELSE  -- source code is not null
         IF (AMS_DEBUG_HIGH_ON) THEN

         AMS_Utility_PVT.debug_message('is it unique? '||p_schedule_rec.source_code);
         END IF;
         IF AMS_SourceCode_PVT.is_source_code_unique(p_schedule_rec.source_code) = FND_API.g_false
         THEN
            -- if not unique
            x_return_status := FND_API.g_ret_sts_error;
            AMS_Utility_PVT.error_message('AMS_CAMP_DUPLICATE_CODE');
            RETURN;
         ELSE
            -- yes unique
            -- remove whatever was earlier
            IF p_sch_source_code <> l_camp_source_code THEN
               -- revoke
               IF (AMS_DEBUG_HIGH_ON) THEN

               AMS_Utility_PVT.debug_message('Revoke Source Code '||p_sch_source_code);
               END IF;
               AMS_SourceCode_PVT.revoke_sourcecode(
                  p_api_version        => 1.0,
                  p_init_msg_list      => FND_API.g_false,
                  p_commit             => FND_API.g_false,
                  p_validation_level   => FND_API.g_valid_level_full,

                  x_return_status      => x_return_status,
                  x_msg_count          => l_msg_count,
                  x_msg_data           => l_msg_data,

                  p_sourcecode         => p_sch_source_code
               );
               IF x_return_status <> FND_API.g_ret_sts_success THEN
                  RAISE FND_API.g_exc_error;
                  RETURN;
               END IF;
            END IF;

            -- push user's code into source code table
            x_source_code := p_schedule_rec.source_code;

            -- soagrawa 22-oct-2002 for bug# 2594717
            IF P_schedule_rec.related_event_id IS NOT NULL
            THEN
               AMS_CampaignRules_PVT.push_source_code(
                  x_source_code,
                  'CSCH',
                  p_schedule_rec.schedule_id,
                  p_schedule_rec.related_source_code,
                  p_schedule_rec.related_source_object,
                  p_schedule_rec.related_source_id
                 );
            ELSE
               AMS_CampaignRules_PVT.push_source_code(
                  x_source_code,
                  'CSCH',
                  p_schedule_rec.schedule_id
                 );
            END IF;
         END IF;
      END IF;

   END IF;

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_Utility_PVT.debug_message('Final source code is '||x_source_code);

   END IF;

END Check_Source_Code;

--========================================================================
-- PROCEDURE
--    Check_Sched_Dates_Vs_Camp
--
-- Purpose
--    Created to check if the schedules start and end date are within
--    campaigns start date and end date.
--
-- HISTORY
--    02-Feb-2001   ptendulk    Created.

--========================================================================
PROCEDURE Check_Sched_Dates_Vs_Camp(
   p_campaign_id    IN  NUMBER,
   p_start_date     IN  DATE,
   p_end_date       IN  DATE,
   x_return_status  OUT NOCOPY VARCHAR2
)
IS

   CURSOR c_campaign IS
   SELECT actual_exec_start_date,
          actual_exec_end_date
     FROM ams_campaigns_all_b
    WHERE campaign_id = p_campaign_id;

   l_parent_start_date  DATE;
   l_parent_end_date    DATE;

BEGIN

   x_return_status := FND_API.g_ret_sts_success;
   IF p_campaign_id IS NULL THEN
      RETURN;
   END IF;

   OPEN c_campaign;
   FETCH c_campaign INTO l_parent_start_date, l_parent_end_date;
   IF c_campaign%NOTFOUND THEN
      CLOSE c_campaign;
      x_return_status := FND_API.g_ret_sts_error;
      AMS_Utility_PVT.error_message('AMS_CSCH_NO_CAMP_ID');
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_campaign;

   ---------------------- start date ----------------------------
   IF p_start_date IS NOT NULL THEN
      IF l_parent_start_date IS NULL THEN
         x_return_status := FND_API.g_ret_sts_error;
         AMS_Utility_PVT.error_message('AMS_CSCH_CAMP_START_NULL');
      ELSIF p_start_date < l_parent_start_date THEN
         x_return_status := FND_API.g_ret_sts_error;
         AMS_Utility_PVT.error_message('AMS_CSCH_START_BEF_CAMP_START');
      ELSIF p_start_date > l_parent_end_date THEN
         x_return_status := FND_API.g_ret_sts_error;
         AMS_Utility_PVT.error_message('AMS_CSCH_START_AFT_CAMP_END');
      END IF;
   END IF;

   ---------------------- end date ------------------------------
   IF p_end_date IS NOT NULL THEN
      IF l_parent_end_date IS NULL THEN
         x_return_status := FND_API.g_ret_sts_error;
         AMS_Utility_PVT.error_message('AMS_CSCH_CAMP_END_NULL');
      ELSIF p_end_date > l_parent_end_date THEN
         x_return_status := FND_API.g_ret_sts_error;
         AMS_Utility_PVT.error_message('AMS_CSCH_END_AFT_CAMP_END');
      ELSIF p_end_date < l_parent_start_date THEN
         x_return_status := FND_API.g_ret_sts_error;
         AMS_Utility_PVT.error_message('AMS_CSCH_END_BEF_CAMP_START');
      END IF;
   END IF;

END Check_Sched_Dates_Vs_Camp;


--========================================================================
-- PROCEDURE
--    Check_Schedule_Update
--
-- Purpose
--    Created to check if the user can update the schedule details
--    It also checks for the locked columns and if user tries to update
--    API will be errored out.
--
--  Note
--    1. Can't update Currency if the budget line exist for the schedule.
--    2. Only user/sysadmin can change the owner field.
--
-- HISTORY
--    13-Feb-2001   ptendulk    Created.
--    08-Jul-2002   soagrawa    Fixed reopened bug# 2406677 in check_schedule_update
--    13-feb-2003   soagrawa    Fixed CRMAP bug# 2795823
--                              checking for access against the schedule, and NOT against the parent campaign
--========================================================================
PROCEDURE Check_Schedule_Update(
   p_schedule_rec    IN   AMS_Camp_Schedule_PVT.schedule_rec_type,
   x_return_status   OUT NOCOPY  VARCHAR2
)
IS
   CURSOR c_resource IS
   SELECT resource_id
   FROM   ams_jtf_rs_emp_v
   WHERE  user_id = FND_GLOBAL.user_id ;

   CURSOR c_schedule IS
   SELECT *
     FROM ams_campaign_schedules_vl
    WHERE schedule_id = p_schedule_rec.schedule_id;

   CURSOR c_bud_line IS
   SELECT 1
   FROM   DUAL
   WHERE  EXISTS(
          SELECT activity_budget_id
          FROM   ozf_act_budgets
          WHERE  arc_act_budget_used_by = 'CSCH'
          AND    act_budget_used_by_id = p_schedule_rec.schedule_id );


   l_bud_exist     VARCHAR2(1);
   l_schedule_rec  c_schedule%ROWTYPE;

   l_resource  NUMBER ;
   l_access    VARCHAR2(1);
   l_admin_user BOOLEAN;


BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   OPEN c_resource ;
   FETCH c_resource INTO l_resource;
   CLOSE c_resource ;

-- Modified by soagrawa on 13-feb-2003 to fix CRMAP bug# 2795823
-- checking for access against the schedule, and NOT against the parent campaign.
/*
   l_access := AMS_Access_PVT.Check_Update_Access(p_object_id          => p_schedule_rec.campaign_id ,
                                                  p_object_type        => 'CAMP',
                                                  p_user_or_role_id    => l_resource,
                                                  p_user_or_role_type  => 'USER');
*/

   l_access := AMS_Access_PVT.Check_Update_Access(p_object_id          => p_schedule_rec.schedule_id ,
                                                  p_object_type        => 'CSCH',
                                                  p_user_or_role_id    => l_resource,
                                                  p_user_or_role_type  => 'USER');

   IF l_access = 'N' THEN
      AMS_Utility_PVT.error_message('AMS_CAMP_NO_ACCESS');
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF ;

   OPEN c_schedule;
   FETCH c_schedule INTO l_schedule_rec;
   IF c_schedule%NOTFOUND THEN
      CLOSE c_schedule;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_schedule;

   l_admin_user := AMS_Access_PVT.Check_Admin_Access(l_resource);

   -- Only owner/ Super Admin can change the owner.
   IF p_schedule_rec.owner_user_id <> FND_API.g_miss_num
   AND p_schedule_rec.owner_user_id <> l_schedule_rec.owner_user_id
   AND l_admin_user = FALSE
   -- following line modified by soagrawa on 08-jul-2002
   -- for fixing reopened bug# 2406677
   -- AND p_schedule_rec.owner_user_id <> l_resource
   AND l_schedule_rec.owner_user_id <> l_resource
   THEN
      AMS_Utility_PVT.error_message('AMS_CAMP_OWNER_ACCESS');
      x_return_status := FND_API.g_ret_sts_error;
   END IF;

   OPEN c_bud_line ;
   FETCH c_bud_line INTO l_bud_exist;
   CLOSE c_bud_line ;

   IF p_schedule_rec.transaction_currency_code <> FND_API.g_miss_char
   AND p_schedule_rec.transaction_currency_code <> l_schedule_rec.transaction_currency_code
   AND l_bud_exist IS NOT NULL
   THEN
      AMS_Utility_PVT.error_message('AMS_CSCH_BUD_PRESENT');
      x_return_status := FND_API.g_ret_sts_error;
   END IF ;


END Check_Schedule_Update;

--========================================================================
-- PROCEDURE
--    Check_Schedule_Activity
--
-- PURPOSE
--    This api is created to validate the activity type , activity
--    and marketing medium attached to the schedule.
--
-- HISTORY
--  13-Feb-2001    ptendulk    Created.
--
--========================================================================
PROCEDURE Check_Schedule_Activity(
   p_schedule_id       IN  NUMBER,
   p_activity_type     IN  VARCHAR2,
   p_activity_id       IN  NUMBER,
   p_medium_id         IN  NUMBER,
   p_arc_channel_from  IN  VARCHAR2,
   p_status_code       IN  VARCHAR2,
   x_return_status     OUT NOCOPY VARCHAR2
)
IS

   l_type   VARCHAR2(30);
   l_dummy  NUMBER;

   CURSOR c_media IS
   SELECT media_type_code
     FROM ams_media_b
    WHERE media_id = p_activity_id
      AND enabled_flag = 'Y';

   CURSOR c_channel_media IS
   SELECT 1
     FROM ams_media_channels
    WHERE channel_id = p_medium_id
      AND media_id = p_activity_id;

--   CURSOR c_eveh IS
--   SELECT event_type_code
--     FROM ams_event_headers_all_b
--    WHERE event_header_id = p_channel_id;
--
--   CURSOR c_eveo IS
--   SELECT event_type_code
--     FROM ams_event_offers_all_b
--    WHERE event_offer_id = p_channel_id;

--   CURSOR c_camp_event IS
--   SELECT 1
--   FROM   DUAL
--   WHERE  EXISTS(
--         SELECT campaign_id
--          FROM   ams_campaigns_vl
--          WHERE  media_type_code = 'EVENTS'
--          AND    arc_channel_from = p_arc_channel_from
--          AND    channel_id = p_channel_id
--          AND    (campaign_id <> p_campaign_id OR p_campaign_id IS NULL));

--   Following line(Was the last line of the above cursor) is commented by ptendulk
--   on 14 Aug 2000 Ref Bug : 1378977
--
--          AND    (campaign_id = p_campaign_id OR p_campaign_id IS NULL));

BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   -- for execution campaigns, media_type and media are required
   IF p_activity_type IS NULL THEN
      AMS_Utility_PVT.error_message('AMS_CSCH_NO_MEDIA_TYPE');
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

   IF p_activity_type <> 'EVENTS' AND p_activity_id IS NULL THEN
      AMS_Utility_PVT.error_message('AMS_CSCH_NO_MEDIA');
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

   IF p_activity_type = 'EVENTS' AND p_activity_type IS NULL THEN
      AMS_Utility_PVT.error_message('AMS_CAMP_EC_NO_EVENT_TYPE');
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

   -- validate media_id
   IF p_activity_id IS NOT NULL THEN
      OPEN c_media;
      FETCH c_media INTO l_type;
      CLOSE c_media;

      IF l_type <> p_activity_type THEN
         AMS_Utility_PVT.error_message('AMS_CAMP_BAD_MEDIA_ID');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   -- validate media channel id
   -- IF p_activity_type <> 'EVENTS'AND p_medium_id IS NOT NULL THEN
   IF p_activity_type <> 'EVENTS' AND p_activity_type <> 'DEAL' AND p_activity_type <> 'TRADE_PROMOTION' AND (p_medium_id IS NOT NULL AND p_medium_id <> FND_API.g_miss_num) THEN
    OPEN c_channel_media;
    FETCH c_channel_media INTO l_dummy;
    CLOSE c_channel_media;

    IF l_dummy IS NULL OR p_activity_id IS NULL THEN
         AMS_Utility_PVT.error_message('AMS_CAMP_BAD_CHANNEL');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   IF p_activity_type  <> 'TRADE_PROMOTION'
   AND p_activity_type <> 'DEAL'
   AND p_activity_type <> 'DIRECT_MARKETING'
   AND p_activity_type <> 'DIRECT_SALES'
   AND p_activity_type <> 'INTERNET'
   AND p_medium_id IS NULL --AND p_medium_id <> FND_API.g_miss_num
   AND p_status_code IN ('SUBMITTED_BA', 'AVAILABLE', 'ACTIVE')
   THEN
      IF p_activity_type = 'EVENTS' THEN
-- dbiswas commented out the following error mesg for R12.
--         AMS_Utility_PVT.error_message('AMS_CAMP_EVENT_REQUIRED');
           null;
      ELSE
         AMS_Utility_PVT.error_message('AMS_CAMP_CHANNEL_REQUIRED');
          x_return_status := FND_API.g_ret_sts_error;
      END IF;
--      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;



   -- validate event channel id
--   IF p_media_type = 'EVENTS' AND p_channel_id IS NOT NULL THEN
--      IF p_arc_channel_from = 'EVEO' THEN
--         OPEN c_eveo;
--         FETCH c_eveo INTO l_type;
--         IF c_eveo%NOTFOUND OR l_type <> p_event_type THEN
--            x_return_status := FND_API.g_ret_sts_error;
--            AMS_Utility_PVT.error_message('AMS_CAMP_BAD_CHANNEL');
--         END IF;
--         CLOSE c_eveo;
--      ELSIF p_arc_channel_from = 'EVEH' THEN
--         OPEN c_eveh;
--         FETCH c_eveh INTO l_type;
--         IF c_eveh%NOTFOUND OR l_type <> p_event_type THEN
--            x_return_status := FND_API.g_ret_sts_error;
--            AMS_Utility_PVT.error_message('AMS_CAMP_BAD_CHANNEL');
--         END IF;
--         CLOSE c_eveh;
--      ELSE
--         x_return_status := FND_API.g_ret_sts_error;
--         AMS_Utility_PVT.error_message('AMS_CAMP_BAD_ARC_CHANNEL');
--      END IF;

      -- event associated to a campaign cannot be associated to other campaigns
--      OPEN c_camp_event;
--      FETCH c_camp_event INTO l_dummy;
--      IF c_camp_event%FOUND THEN
--         x_return_status := FND_API.g_ret_sts_error;
--         AMS_Utility_PVT.error_message('AMS_CAMP_EVENT_IN_USE');
--      END IF;
--      CLOSE c_camp_event;
--   END IF;

END Check_Schedule_Activity;

-- Start of Comments
--
-- NAME
--   Update_List_Sent_Out_Date
--
-- PURPOSE
--
--
-- NOTES
--
--
-- HISTORY
--   17-MAY-2001        soagrawa    created
-- End of Comments
PROCEDURE Update_List_Sent_Out_Date
            (p_api_version             IN     NUMBER,
             p_init_msg_list           IN     VARCHAR2 := FND_API.G_False,
             p_commit                  IN     VARCHAR2 := FND_API.G_False,

             x_return_status           OUT NOCOPY    VARCHAR2,
             x_msg_count               OUT NOCOPY    NUMBER  ,
             x_msg_data                OUT NOCOPY    VARCHAR2,

             p_list_header_id          IN     NUMBER)
             -- p_schedule_id             IN     NUMBER,
             -- p_exec_flag               IN     VARCHAR2)
IS

   CURSOR c_list_details IS
   SELECT object_version_number
   FROM   ams_list_headers_all
   WHERE  list_header_id = p_list_header_id ;

   -- g_pkg_name CONSTANT VARCHAR2(30) := 'NONE';

   l_list_rec     AMS_LISTHEADER_PVT.list_header_rec_type;
   l_api_name      CONSTANT VARCHAR2(30)  := 'AMS_EXEC_SCHEDULE';
   l_api_version   CONSTANT NUMBER        := 1.0;
   l_full_name     CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;


   l_return_status  VARCHAR2(1);

BEGIN
   --
   -- Standard Start of API savepoint
   --
   SAVEPOINT Update_List_Header;

   --
   -- Debug Message
   --
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   --
   -- Initialize message list IF p_init_msg_list is set to TRUE.
   --
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
   END IF;

   --
   -- Standard call to check for call compatibility.
   --
   IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
   THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --
   --  Initialize API return status to success
   --
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Update the list header with the Schedule details.
   AMS_LISTHEADER_PVT.Init_ListHeader_rec(x_listheader_rec  => l_list_rec);
   l_list_rec.list_header_id := p_list_header_id ;

   -- get the obj version number
   OPEN c_list_details ;
   FETCH c_list_details INTO l_list_rec.object_version_number ;
   CLOSE c_list_details ;


   --
   -- Update the list sent out date with sysdate if success
   --

   l_list_rec.sent_out_date := sysdate  ;

   --l_list_rec.arc_list_used_by := 'CSCH' ;  -- Campaign Schedule
   --l_list_rec.list_used_by_id  := p_schedule_id ;  -- Campaign Schedule

   AMS_LISTHEADER_PVT.Update_ListHeader
            ( p_api_version                      => p_api_version,
              p_init_msg_list                    => FND_API.G_FALSE,
              p_commit                           => FND_API.G_FALSE,
              p_validation_level                 => FND_API.G_VALID_LEVEL_FULL,

              x_return_status                    => x_return_status,
              x_msg_count                        => x_msg_count,
              x_msg_data                         => x_msg_data ,

              p_listheader_rec                   => l_list_rec
                );

   -- If any errors happen abort API.
   IF x_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
   ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --
   -- Standard check of p_commit.
   --
   IF FND_API.To_Boolean ( p_commit )
   THEN
        COMMIT WORK;
   END IF;

   --
   -- Standard call to get message count AND IF count is 1, get message info.
   --
   FND_MSG_PUB.Count_AND_Get
     ( p_count       =>      x_msg_count,
       p_data        =>      x_msg_data,
       p_encoded    =>      FND_API.G_FALSE
      );

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_Utility_PVT.debug_message(l_full_name ||': end');

   END IF;



EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN

       ROLLBACK TO Update_List_Header;
       x_return_status := FND_API.G_RET_STS_ERROR ;

       FND_MSG_PUB.Count_AND_Get
                ( p_count       =>      x_msg_count,
                  p_data        =>      x_msg_data,
                  p_encoded       =>      FND_API.G_FALSE
                );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

       ROLLBACK TO Update_List_Header;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

       FND_MSG_PUB.Count_AND_Get
                ( p_count       =>      x_msg_count,
                  p_data        =>      x_msg_data,
                  p_encoded       =>      FND_API.G_FALSE
                );

   WHEN OTHERS THEN

       ROLLBACK TO Update_List_Header;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

       IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
       THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;

       FND_MSG_PUB.Count_AND_Get
                ( p_count       =>      x_msg_count,
                  p_data        =>      x_msg_data,
                  p_encoded       =>      FND_API.G_FALSE
                );
END Update_List_Sent_Out_Date ;







--=====================================================================================================
-- PROCEDURE
--    Complete_Schedule
--
-- PURPOSE
--    This api is created to complete active schedules.
--
--
-- Note
--    This procedure will be called by concurrent program to complete the
--    schedule.
--
-- HISTORY
--  24-Aug-2003    ptendulk    Created
--  17-Mar-2005    spendem     call the API to raise business event on status change as per enh # 3805347
--========================================================================================================
PROCEDURE Complete_Schedule
               (
               p_api_version             IN     NUMBER,
               p_init_msg_list           IN     VARCHAR2 := FND_API.G_False,
               p_commit                  IN     VARCHAR2 := FND_API.G_False,
               p_schedule_id             IN     NUMBER := NULL,

               x_return_status           OUT NOCOPY    VARCHAR2,
               x_msg_count               OUT NOCOPY    NUMBER  ,
               x_msg_data                OUT NOCOPY    VARCHAR2 )
IS
   CURSOR c_completed_schedule IS
   SELECT schedule_id, object_version_number
   FROM   ams_campaign_schedules_b
   WHERE  status_code = 'ACTIVE'
   AND    end_date_time <= SYSDATE ;

   CURSOR c_status(l_status_code VARCHAR2) IS
   SELECT user_status_id
   FROM   ams_user_statuses_b
   WHERE  system_status_type = 'AMS_CAMPAIGN_SCHEDULE_STATUS'
   AND    system_status_code = l_status_code
   AND    default_flag = 'Y'
   AND    enabled_flag = 'Y' ;

   l_status_id             NUMBER ;
   l_schedule_id           NUMBER ;
   l_obj_version           NUMBER ;
   l_api_version   CONSTANT NUMBER := 1.0 ;
   l_api_name      CONSTANT VARCHAR2(30)  := 'Complete_Schedule';

BEGIN
   --
   -- Standard Start of API savepoint
   --
   SAVEPOINT AMS_COMPLETE_SCHEDULE;

   --
   -- Debug Message
   --
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_api_name || ': start');
   END IF;

   --
   -- Initialize message list IF p_init_msg_list is set to TRUE.
   --
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
       FND_MSG_PUB.initialize;
   END IF;

   --
   -- Standard call to check for call compatibility.
   --
   IF NOT FND_API.Compatible_API_Call ( 1.0,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
   THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --
   --  Initialize API return status to success
   --
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Chenge the status of all the schedules which are active to
   -- completed.
   OPEN c_status('COMPLETED') ;
   FETCH c_status INTO l_status_id ;
   IF c_status%NOTFOUND THEN
      CLOSE c_status;
      AMS_Utility_PVT.error_message('AMS_CAMP_BAD_USER_STATUS');
      RETURN ;
   END IF ;
   CLOSE c_status ;

   OPEN c_completed_schedule ;
   LOOP
      FETCH c_completed_schedule INTO l_schedule_id, l_obj_version ;
      EXIT WHEN c_completed_schedule%NOTFOUND ;

      -- Update the status of the schedule to Active.
      UPDATE ams_campaign_schedules_b
      SET    status_code = 'COMPLETED',
             status_date = SYSDATE ,
             user_status_id     = l_status_id,
             object_version_number = l_obj_version + 1
      WHERE  schedule_id = l_schedule_id ;

     -- call to api to raise business event, as per enh # 3805347
     RAISE_BE_ON_STATUS_CHANGE(p_obj_id => l_schedule_id,
                               p_obj_type => 'CSCH',
                               p_old_status_code => 'ACTIVE',
                               p_new_status_code => 'COMPLETED');

   END LOOP;
   CLOSE c_completed_schedule;
   --
   -- Standard check of p_commit.
   --
   IF FND_API.To_Boolean ( p_commit )
   THEN
        COMMIT WORK;
   END IF;

   --
   -- Standard call to get message count AND IF count is 1, get message info.
   --
   FND_MSG_PUB.Count_AND_Get
     ( p_count       =>      x_msg_count,
       p_data        =>      x_msg_data,
       p_encoded    =>      FND_API.G_FALSE
      );

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_Utility_PVT.debug_message(l_api_name ||' : end Status : ' || x_return_status);

   END IF;



EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN

       IF (c_completed_schedule%ISOPEN) THEN
          CLOSE c_completed_schedule ;
       END IF;
       ROLLBACK TO AMS_COMPLETE_SCHEDULE;
       x_return_status := FND_API.G_RET_STS_ERROR ;

       FND_MSG_PUB.Count_AND_Get
                ( p_count       =>      x_msg_count,
                  p_data        =>      x_msg_data,
                  p_encoded       =>      FND_API.G_FALSE
                );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       IF (c_completed_schedule%ISOPEN) THEN
          CLOSE c_completed_schedule ;
       END IF;
       ROLLBACK TO AMS_COMPLETE_SCHEDULE;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

       FND_MSG_PUB.Count_AND_Get
                ( p_count       =>      x_msg_count,
                  p_data        =>      x_msg_data,
                  p_encoded       =>      FND_API.G_FALSE
                );

   WHEN OTHERS THEN
       IF (c_completed_schedule%ISOPEN) THEN
          CLOSE c_completed_schedule ;
       END IF;
       ROLLBACK TO AMS_COMPLETE_SCHEDULE;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

       IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
       THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;

       FND_MSG_PUB.Count_AND_Get
                ( p_count       =>      x_msg_count,
                  p_data        =>      x_msg_data,
                  p_encoded       =>      FND_API.G_FALSE
                );

END Complete_Schedule;


--========================================================================
-- PROCEDURE
--    Activate_Schedule
--
-- PURPOSE
--    This api is created to be used by concurrent program to activate
--    schedules. It will internally call the Activate schedules api to
--    activate the schedule.

--
-- HISTORY
--  17-Mar-2001    ptendulk    Created.
--
--========================================================================
PROCEDURE Activate_Schedule
               (errbuf            OUT NOCOPY    VARCHAR2,
                retcode           OUT NOCOPY    NUMBER)
IS
   l_return_status    VARCHAR2(1) ;
   l_msg_count        NUMBER ;
   l_msg_data         VARCHAR2(2000);
   l_api_version      NUMBER := 1.0 ;
BEGIN
   FND_MSG_PUB.initialize;

   Complete_Schedule(
         p_api_version             => l_api_version ,

         x_return_status           => l_return_status,
         x_msg_count               => l_msg_count,
         x_msg_data                => l_msg_data
   ) ;
   -- Write_log ;
   Ams_Utility_Pvt.Write_Conc_log ;

   IF(l_return_status = FND_API.G_RET_STS_SUCCESS)THEN
      retcode :=0;
   ELSE
      retcode  := 2;
      errbuf   :=  l_msg_data ;
   END IF;
END Activate_Schedule;


--========================================================================
-- PROCEDURE
--    Update_Schedule_Status
--
-- PURPOSE
--    This api is created to be used for schedule status changes.
--
-- HISTORY
--  28-Mar-2001    ptendulk    Created.
--  24-May-2001    ptendulk    Added check to validate marketing medium before
--                             schedule goes active.
--  12-Jun-2001    ptendulk    Event type schedule can go active without marketing
--                             medium.
--  04-dec-2001    soagrawa    Modified code for 0 budget approvals.
--  04-dec-2001    soagrawa    Modified condition for checking for existence of target group
--                             Now looking for only direct marketing of type email/fax/telemarketing
--  25-Oct-2002    soagrawa    Added code for automatic budget line approval enh# 2445453
--  30-sep-2003    soagrawa    Modified code for cover letter id retrieval and validation
--========================================================================
PROCEDURE Update_Schedule_Status(
   p_schedule_id      IN  NUMBER,
   p_campaign_id      IN  NUMBER,
   p_user_status_id   IN  NUMBER,
   p_budget_amount    IN  NUMBER,
   p_asn_group_id     IN  VARCHAR2 DEFAULT NULL -- anchaudh added for leads bug.
)
IS

   l_budget_exist      NUMBER;
   l_old_status_id     NUMBER;
   l_new_status_id     NUMBER;
   l_deny_status_id    NUMBER;
   l_object_version    NUMBER;
   l_approval_type     VARCHAR2(30);
   l_return_status     VARCHAR2(1);
   l_start_time        DATE;
   l_timezone          NUMBER;
   l_start_wf_process  VARCHAR2(1) := 'Y';

   CURSOR c_old_status IS
   SELECT user_status_id, object_version_number,
          start_date_time, timezone_id,activity_type_code,
          activity_id,marketing_medium_id,custom_setup_id,
          cover_letter_id, printer_address
   FROM   ams_campaign_schedules_b
   WHERE  schedule_id = p_schedule_id;

   CURSOR c_budget_exist IS
   SELECT 1
   FROM   DUAL
   WHERE  EXISTS(
          SELECT 1
          FROM   ozf_act_budgets
          WHERE  arc_act_budget_used_by = 'CSCH'
          AND    act_budget_used_by_id = p_schedule_id);

   CURSOR c_camp_status IS
   SELECT   status_code
   FROM     ams_campaigns_all_b
   WHERE    campaign_id = p_campaign_id ;

   -- soagrawa added the following cursor on 30-sep-2003 for stamping version in 11.5.10
   CURSOR c_cover_letter_det IS
   SELECT ci.live_citem_version_id
     FROM ibc_associations assoc, ibc_content_Items ci
    WHERE assoc.association_type_code = 'AMS_CSCH'
      AND assoc.associated_object_val1 = to_char(p_schedule_id) -- fix for bug # 4145845
      AND assoc.content_item_id = ci.content_Item_id;

   -- dbiswas added the following cursor on 23-mar-2003 for content item approval in 11.5.10
   CURSOR c_attr_available (p_custom_setup_id IN NUMBER)IS
   SELECT attr_available_flag
     FROM ams_custom_Setup_attr atr,
          ams_Custom_setups_vl vl
    WHERE vl.object_type ='CSCH'
      AND vl.custom_Setup_id = atr.custom_Setup_id
      AND atr.object_attribute in ('COLLAB','MEDIA_PLANNER')
      AND vl.custom_setup_id = p_custom_setup_id;

   -- dbiswas added the following cursor on 26-may-2005 for pretty URL uniqueness in 11.5.10.RUP4
   CURSOR c_system_url (p_schedule_id  IN NUMBER)IS
   SELECT system_url, pretty_url_id, ctd_id
     FROM ams_system_pretty_url sysUrl,
          ams_pretty_url_assoc  assoc
    WHERE assoc.used_by_obj_type ='CSCH'
      AND assoc.used_by_obj_id = p_schedule_id
      AND assoc.system_url_id = sysUrl.system_url_id;

   -- dbiswas added the following 2 cursors on 30 Aug 06 for validating PU and CTD reqd fields
   CURSOR c_pretty_url (p_pretty_url_id IN NUMBER)IS
   SELECT *
     FROM ams_pretty_url
    WHERE pretty_url_id = p_pretty_url_id;

   CURSOR c_ctd_items (p_ctd_id IN NUMBER)IS
   SELECT *
     FROM ams_ctds
    WHERE ctd_id = p_ctd_id;

   l_status_code           VARCHAR2(30);
   l_activity_type_code    VARCHAR2(30);
   l_activity_id           NUMBER ;
   l_marketing_med_id      NUMBER ;
   l_schedule_status_code  VARCHAR2(30) := AMS_Utility_PVT.get_system_status_code(p_user_status_id) ;
   l_custom_setup_id       NUMBER;
   l_cover_letter_id       NUMBER ;

   l_msg_count             NUMBER ;
   l_msg_data              VARCHAR2(2000);
   l_cover_letter_ver_id   NUMBER; -- soagrawa added 30-sep-2003 or 11.5.10
   l_printer_address       VARCHAR2(255);
   l_fulfilment          VARCHAR2(30);
   l_attr_available      VARCHAR2(30);
   l_system_url          VARCHAR2(4000); -- dbiswas added 26May05 for 11.5.10.RUP4
   l_pretty_url_id       NUMBER; -- dbiswas added 30Aug06 for R12 bug 5477945
   l_ctd_id              NUMBER;
   l_pretty_url_rec      AMS_PRETTY_URL_PVT.pretty_url_rec_type;
   l_ctd_rec             AMS_CTD_PVT.ctd_rec_type;

   x_status_code         VARCHAR2(30);

BEGIN

   OPEN c_old_status;
   FETCH c_old_status INTO l_old_status_id, l_object_version, l_start_time,
   l_timezone, l_activity_type_code, l_activity_id, l_marketing_med_id,l_custom_setup_id,l_cover_letter_id, l_printer_address ;
   CLOSE c_old_status;

   IF l_old_status_id = p_user_status_id THEN
      RETURN;
   END IF;

   -- Follwing code is modified by ptendulk on 10-Jul-2001
   -- The old procedure is replaced by new to check the type
   -- of the approval required as ams_object_attribute table is
   -- obsoleted now.
   AMS_Utility_PVT.check_new_status_change(
      p_object_type      => 'CSCH',
      p_object_id        => p_schedule_id,
      p_old_status_id    => l_old_status_id,
      p_new_status_id    => p_user_status_id,
      p_custom_setup_id  => l_custom_setup_id,
      x_approval_type    => l_approval_type,
      x_return_status    => l_return_status
   );


   IF l_return_status <> FND_API.g_ret_sts_success THEN
      RAISE FND_API.g_exc_error;
   END IF;

-- dbiswas added the following pretty url check for bug 4472099
   IF l_schedule_status_code = 'SUBMITTED_BA'
   THEN
         IF (AMS_DEBUG_HIGH_ON) THEN
           AMS_Utility_PVT.debug_message('Is Pretty URL supported for schedule '||p_schedule_id||' with Activity Type = '||l_activity_type_code ||' and activity id = '||l_activity_id);
         END IF;
         IF (((l_activity_type_code = 'DIRECT_MARKETING') AND ((l_activity_id <> 20) AND (l_activity_id <> 460 )))
             OR((l_activity_type_code = 'BROADCAST') OR (l_activity_type_code = 'PUBLIC_RELATIONS') OR (l_activity_type_code = 'IN_STORE')))
         THEN
               IF (AMS_DEBUG_HIGH_ON) THEN
                   AMS_Utility_PVT.debug_message('Pretty URL IS supported for schedule '||p_schedule_id||' with Activity Type = '||l_activity_type_code ||' and activity id = '||l_activity_id);
               END IF;
               OPEN c_system_url(p_schedule_id);
               FETCH c_system_url INTO l_system_url, l_pretty_url_id, l_ctd_id ;
               CLOSE c_system_url;
               IF(l_system_url IS NOT NULL) THEN
	       -- dbiswas added the following checks for bug 5477945. Mandatory fields check for PrettyUrl
	          OPEN c_pretty_url(l_pretty_url_id);
		  FETCH c_pretty_url INTO l_pretty_url_rec;
		  CLOSE c_pretty_url;
		  IF (l_pretty_url_rec.pretty_url_id IS NOT NULL) THEN
                     AMS_PRETTY_URL_PVT.CHECK_PU_MANDATORY_FIELDS(
                            p_pretty_url_rec => l_pretty_url_rec,
                            x_return_status => l_return_status);
                     IF l_return_status <> FND_API.g_ret_sts_success THEN
                            RAISE FND_API.g_exc_error;
                     END IF;
                  ELSE --Pretty URL rec not found, but system url exists. ERROR
		     RAISE FND_API.g_exc_error;
                  END IF;

		  -- Mandatory fields check for CTD
   	          OPEN c_ctd_items(l_ctd_id);
		  FETCH c_ctd_items INTO l_ctd_rec;
		  CLOSE c_ctd_items;
                  IF (l_ctd_rec.ctd_id IS NOT NULL) THEN
                      AMS_CTD_PVT.CHECK_MANDATORY_FIELDS(
		                       p_ctd_rec => l_ctd_rec,
				       x_return_status => l_return_status
				       );
                      IF l_return_status <> FND_API.g_ret_sts_success THEN
                          RAISE FND_API.g_exc_error;
                     END IF ;
		  ELSE --CTD Referenced in System url but does not exist. ERROR
                     RAISE FND_API.g_exc_error;
                  END IF ;

                  AMS_PRETTY_URL_PVT.IS_SYSTEM_URL_UNIQ(p_sys_url => l_system_url ,
                                                         p_current_used_by_id => p_schedule_id,
                                                         p_current_used_by_type => 'CSCH',
                                                         x_return_status => l_return_status);
                   IF l_return_status <> FND_API.g_ret_sts_success THEN
                       RAISE FND_API.g_exc_error;
                   END IF ;
                   --
               END IF;
         END IF;
   END IF; -- end bug fix # 4472099

   -- Schedule Can not go active unless the campaign is Active
   -- Schedule Camapign Rule 2/5
   IF l_schedule_status_code = 'ACTIVE' OR
      -- Following line is added by ptendulk on 06-Oct-2001
      l_schedule_status_code = 'AVAILABLE'
   THEN

         -- anchaudh : calling validate activation rules api from R12 onwards; for any activity validation rule, going forward.
         validate_activation_rules(p_scheduleid => p_schedule_id , x_status_code => x_status_code);
         IF x_status_code <> FND_API.g_ret_sts_success THEN
            RAISE FND_API.g_exc_error;
         END IF ;

      -- Following line of code is added by ptendulk on 08-Jul-2001
      --Check if the schedule has target group attached and generated.
      -- Following line is modified by ptendulk on 06-Oct-2001 .
      -- IF l_activity_type_code IN ('DIRECT_MARKETING','INTERNET','DEAL','TRADE_PROMOTION') THEN
      -- SALES related stuff added by asaha on 18th Feb, 2004
         IF    (l_activity_type_code = 'DIRECT_MARKETING' OR  l_activity_type_code = 'DIRECT_SALES') THEN
         -- following line added by soagrawa on 04-dec-2001
            -- modified by soagrawa on 15-aug-2002 for bug# 2515493 - added direct mail 480
            IF (l_activity_id = 10 OR l_activity_id = 20 OR l_activity_id = 460 OR l_activity_id = 480 OR l_activity_id = 500) THEN
               IF FND_API.G_FALSE = Target_Group_Exist(p_schedule_id) THEN
                  AMS_Utility_PVT.Error_Message('AMS_CSCH_NO_TARGET_GROUP');
                  RAISE FND_API.g_exc_error;
               END IF ;
            END IF;

            -- see if live cover letter version exists for email, fax, print
            -- soagrawa modified the way l_cover_letter_id is populated on 30-sep-2003 for 11.5.10
            OPEN  c_cover_letter_det;
            FETCH c_cover_letter_det INTO l_cover_letter_ver_id;
            CLOSE c_cover_letter_det;
            -- soagrawa added 480 on 30-sep-2003 for 11.5.10
            IF (l_activity_id = 20 OR l_activity_id = 10 OR l_activity_id = 480)
            AND l_cover_letter_ver_id IS NULL THEN
               AMS_Utility_PVT.Error_Message('AMS_CSCH_NO_COVER_LETTER');
               RAISE FND_API.g_exc_error;
            END IF ;

            -- soagrawa added printer validation on 18-nov-2003 for 11.5.10
            l_fulfilment := FND_PROFILE.Value('AMS_FULFILL_ENABLE_FLAG');
            IF l_activity_id = 480
            AND l_fulfilment <> 'N'
            AND l_printer_address IS NULL THEN
               AMS_Utility_PVT.Error_Message('AMS_CSCH_NO_PRINTER');
               RAISE FND_API.g_exc_error;
            END IF ;

         END IF ;

    --anchaudh : commenting out the call to AMS_ActProduct_PVT.IS_ALL_CONTENT_APPROVED for R12 .

         --dbiswas added content validation for Collab midtab on 18-Mar-2004 for 11.5.10
         /*OPEN c_attr_available(l_custom_setup_id);
         FETCH c_attr_available INTO l_attr_available;
         CLOSE c_attr_available;
         IF (l_attr_available = 'Y') THEN
           AMS_ActProduct_PVT.IS_ALL_CONTENT_APPROVED (p_schedule_id   => p_schedule_id,
                                                       x_return_status => l_return_status);
           IF l_return_status <> 'Y'
           THEN AMS_Utility_PVT.Error_Message('AMS_CONTENT_NOT_APPROVED');
               RAISE FND_API.g_exc_error;
            END IF ;
         END IF;*/

    --anchaudh: from R12 onwards, the above content valdation would be taken care of in the api : validate_activation_rules


         --dbiswas added pretty URL uniqueness check for pretty URL region on May 26, 2005 for 11.5.10.RUP4
         IF (AMS_DEBUG_HIGH_ON) THEN
           AMS_Utility_PVT.debug_message('Is Pretty URL supported for schedule '||p_schedule_id||' with Activity Type = '||l_activity_type_code ||' and activity id = '||l_activity_id);
         END IF;
         IF (((l_activity_type_code = 'DIRECT_MARKETING') AND ((l_activity_id <> 20) AND (l_activity_id <> 460 )))
             OR((l_activity_type_code = 'BROADCAST') OR (l_activity_type_code = 'PUBLIC_RELATIONS') OR (l_activity_type_code = 'IN_STORE')))
         THEN
               IF (AMS_DEBUG_HIGH_ON) THEN
                   AMS_Utility_PVT.debug_message('Pretty URL IS supported for schedule '||p_schedule_id||' with Activity Type = '||l_activity_type_code ||' and activity id = '||l_activity_id);
               END IF;
               OPEN c_system_url(p_schedule_id);
               FETCH c_system_url INTO l_system_url, l_pretty_url_id, l_ctd_id;
               CLOSE c_system_url;
               IF(l_system_url IS NOT NULL) THEN
	       -- dbiswas added the following checks for bug 5477945. Mandatory fields check for PrettyUrl
	          OPEN c_pretty_url(l_pretty_url_id);
		  FETCH c_pretty_url INTO l_pretty_url_rec;
		  CLOSE c_pretty_url;
		  IF (l_pretty_url_rec.pretty_url_id IS NOT NULL) THEN
                     AMS_PRETTY_URL_PVT.CHECK_PU_MANDATORY_FIELDS(
                            p_pretty_url_rec => l_pretty_url_rec,
                            x_return_status => l_return_status);
                     IF l_return_status <> FND_API.g_ret_sts_success THEN
                            RAISE FND_API.g_exc_error;
                     END IF;
                  ELSE --Pretty URL rec not found, but system url exists. ERROR
		     RAISE FND_API.g_exc_error;
                  END IF;

		  -- Mandatory fields check for CTD
   	          OPEN c_ctd_items(l_ctd_id);
		  FETCH c_ctd_items INTO l_ctd_rec;
		  CLOSE c_ctd_items;
                  IF (l_ctd_rec.ctd_id IS NOT NULL) THEN
                      AMS_CTD_PVT.CHECK_MANDATORY_FIELDS(
		                       p_ctd_rec => l_ctd_rec,
				       x_return_status => l_return_status
				       );
                      IF l_return_status <> FND_API.g_ret_sts_success THEN
                          RAISE FND_API.g_exc_error;
                     END IF ;
		  ELSE --CTD Referenced in System url but does not exist. ERROR
                     RAISE FND_API.g_exc_error;
                  END IF ;

                  AMS_PRETTY_URL_PVT.IS_SYSTEM_URL_UNIQ(p_sys_url => l_system_url ,
                                                         p_current_used_by_id => p_schedule_id,
                                                         p_current_used_by_type => 'CSCH',
                                                         x_return_status => l_return_status);
                   IF l_return_status <> FND_API.g_ret_sts_success THEN
                       RAISE FND_API.g_exc_error;
                   END IF ;
               END IF;
         END IF;


      IF l_marketing_med_id IS NULL THEN
         IF l_activity_type_code <> 'DIRECT_MARKETING' AND
            l_activity_type_code <> 'INTERNET' AND
            -- Following line of code is added by ptendulk on 12-Jun-2001
            -- Mktg medium is not mandatory for event type schedules
            l_activity_type_code <> 'EVENTS' AND
            -- Following Line of code is added by ptendulk on 06-Oct-2001
            l_activity_type_code <> 'DEAL' AND
            l_activity_type_code <> 'TRADE_PROMOTION' AND
            -- Following Line of code is added by asaha on 09-Sep-2003 for Sales Channel
            l_activity_type_code <> 'DIRECT_SALES'
         THEN
            AMS_Utility_PVT.Error_Message('AMS_CAMP_CHANNEL_REQUIRED');
            RAISE FND_API.g_exc_error;
         END IF ;
      END IF ;

      OPEN c_camp_status ;
      FETCH c_camp_status INTO l_status_code ;
      CLOSE c_camp_status;

      IF l_status_code <> 'ACTIVE' THEN
         AMS_Utility_PVT.Error_Message('AMS_CSCH_CAMP_NO_ACTIVE');
         RAISE FND_API.g_exc_error;
      END IF ;
   END IF ; -- Active or Available


   IF l_approval_type = 'BUDGET' THEN

      /* vmodur 19-Dec-2005 */
      AMS_Approval_PVT.Must_Preview(
         p_activity_id => p_schedule_id,
         p_activity_type => 'CSCH',
         p_approval_type => 'BUDGET',
         p_act_budget_id => null,
         p_requestor_id => AMS_Utility_PVT.get_resource_id(FND_GLOBAL.user_id),
         x_must_preview => l_start_wf_process,
         x_return_status => l_return_status);

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

       /* vmodur 19-Dec-2005 */
      IF (l_start_wf_process = 'Y') THEN -- If the user is not the approver and budget approval reqd
        -- start budget approval process
        l_new_status_id := AMS_Utility_PVT.get_default_user_status(
           'AMS_CAMPAIGN_SCHEDULE_STATUS',
           'SUBMITTED_BA'
         );
        l_deny_status_id := AMS_Utility_PVT.get_default_user_status(
           'AMS_CAMPAIGN_SCHEDULE_STATUS',
           'DENIED_BA'
         );

      AMS_Approval_PVT.StartProcess(
         p_activity_type => 'CSCH',
         p_activity_id => p_schedule_id,
         p_approval_type => l_approval_type,
         p_object_version_number => l_object_version,
         p_orig_stat_id => l_old_status_id,
         p_new_stat_id => p_user_status_id,
         p_reject_stat_id => l_deny_status_id,
         p_requester_userid => AMS_Utility_PVT.get_resource_id(FND_GLOBAL.user_id),
         p_workflowprocess => 'AMS_APPROVAL',
         p_item_type => 'AMSAPRV'
      );
      ELSE -- If user equals approver and budget approval reqd
         IF (AMS_DEBUG_HIGH_ON) THEN
            AMS_Utility_PVT.Debug_Message('No need to start Workflow Process for Approval, Status Code ' || l_schedule_status_code );
         END IF;
         -- Following budget line api call added by soagrawa on 25-oct-2002
         -- for enhancement # 2445453

         IF l_schedule_status_code = 'ACTIVE' THEN
         OZF_BudgetApproval_PVT.budget_request_approval(
             p_init_msg_list         => FND_API.G_FALSE
             , p_api_version           => 1.0
             , p_commit                => FND_API.G_False
             , x_return_status         => l_return_status
             , x_msg_count             => l_msg_count
             , x_msg_data              => l_msg_data
             , p_object_type           => 'CSCH'
             , p_object_id             => p_schedule_id
             --, x_status_code           =>
             );

            IF l_return_status = FND_API.G_RET_STS_ERROR THEN
               RAISE FND_API.G_EXC_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
         END IF; -- Active
         l_new_status_id := p_user_status_id;

      END IF; -- IF budget approval reqd

   ELSE -- No BUDGET Approval

         IF (AMS_DEBUG_HIGH_ON) THEN
            AMS_Utility_PVT.Debug_Message('No Approval' || l_schedule_status_code );
         END IF;
         -- Following budget line api call added by soagrawa on 25-oct-2002
         -- for enhancement # 2445453

         IF l_schedule_status_code = 'ACTIVE' THEN
         OZF_BudgetApproval_PVT.budget_request_approval(
             p_init_msg_list         => FND_API.G_FALSE
             , p_api_version           => 1.0
             , p_commit                => FND_API.G_False
             , x_return_status         => l_return_status
             , x_msg_count             => l_msg_count
             , x_msg_data              => l_msg_data
             , p_object_type           => 'CSCH'
             , p_object_id             => p_schedule_id
             --, x_status_code           =>
             );

            IF l_return_status = FND_API.G_RET_STS_ERROR THEN
               RAISE FND_API.G_EXC_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
          END IF;
      l_new_status_id := p_user_status_id;

   END IF; -- If Budget

   --insert_log_mesg('Anirban got value of asn_group_id in api Update_Schedule_Status in amsvsbrb.pls as :'||p_asn_group_id);

   update_status(p_schedule_id      =>   p_schedule_id,
                 p_new_status_id    =>   l_new_status_id,
                 p_new_status_code  =>   AMS_Utility_PVT.get_system_status_code(l_new_status_id),
       p_asn_group_id     =>   p_asn_group_id -- anchaudh added for leads bug.
                 );

END Update_Schedule_Status;



--========================================================================
-- PROCEDURE
--    Create_list
--
-- PURPOSE
--    This api is called after the creation of the Direct marketing schedules
--    to create the default target group for the schedule. User can go to the
--    target group screen to modify the details.
--
-- NOTE
--    The list of Type Target is created in list header and the association is
--    created in the ams_act_lists table.
--
-- HISTORY
--  18-May-2001    ptendulk    Created.
--  18-Aug-2001    ptendulk    Modified the Target group name
--
--========================================================================
PROCEDURE Create_list
               (p_schedule_id     IN     NUMBER,
                p_schedule_name   IN     VARCHAR2,
                p_owner_id        IN     NUMBER)
IS
   l_return_status      VARCHAR2(1) ;
   l_msg_count          NUMBER ;
   l_msg_data           VARCHAR2(2000);
   l_api_version        NUMBER := 1.0 ;

   l_list_header_rec    AMS_ListHeader_Pvt.list_header_rec_type;
   l_act_list_rec       AMS_Act_List_Pvt.act_list_rec_type;
   l_list_header_id     NUMBER ;
   l_act_list_header_id NUMBER ;

   l_tmp NUMBER ;

BEGIN
   NULL;
/*  Following code is modified by ptendulk on 25-Oct-2001
    As we don't have to create the target group for schedules at
    schedule creation.
   --   AMS_ListHeader_PVT.init_listheader_rec(l_list_header_rec);
   l_list_header_rec.list_name :=  p_schedule_name ||TO_CHAR(p_schedule_id)||' - '||AMS_Utility_PVT.get_lookup_meaning('AMS_SYS_ARC_QUALIFIER','TGRP');
   l_list_header_rec.list_type :=  'TARGET';
   -- Have to be removed.
   l_list_header_rec.list_source_type := 'PERSON_LIST' ;
   l_list_header_rec.owner_user_id :=  p_owner_id;
   AMS_ListHeader_PVT.Create_Listheader
      ( p_api_version           => 1.0,
        p_init_msg_list         => FND_API.g_false,
        p_commit                => FND_API.g_false,
        p_validation_level      => FND_API.g_valid_level_full,

        x_return_status         => l_return_status,
        x_msg_count             => l_msg_count,
        x_msg_data              => l_msg_data,
        p_listheader_rec        => l_list_header_rec,
        x_listheader_id         => l_list_header_id
        );

   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   l_act_list_rec.list_header_id   := l_list_header_id;
   l_act_list_rec.list_used_by     := 'CSCH';
   l_act_list_rec.list_used_by_id  := p_schedule_id ;
   l_act_list_rec.list_act_type    := 'TARGET';

   AMS_Act_List_PVT.Create_Act_List(
      p_api_version_number    => 1.0,
      p_init_msg_list         => FND_API.g_false,
      p_commit                => FND_API.g_false,
      p_validation_level      => FND_API.g_valid_level_full,
      x_return_status         => l_return_status,
      x_msg_count             => l_msg_count,
      x_msg_data              => l_msg_data,
      p_act_list_rec          => l_act_list_rec  ,
      x_act_list_header_id    => l_act_list_header_id
      ) ;

   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   */
END Create_list;



--========================================================================
-- PROCEDURE
--    Create_Schedule_Access
--
-- PURPOSE
--    This api is called in Create schedule api to give the access for
--    schedule to the team members of the campaign.
--
-- NOTE
--
-- HISTORY
--  11-Sep-2001    ptendulk    Created.
--
--========================================================================
PROCEDURE Create_Schedule_Access(p_schedule_id        IN NUMBER,
                                 p_campaign_id        IN NUMBER,
                                 p_owner_id           IN NUMBER,
                                 p_init_msg_list      IN VARCHAR2,
                                 p_commit             IN VARCHAR2,
                                 p_validation_level   IN NUMBER,

                                 x_return_status     OUT NOCOPY VARCHAR2,
                                 x_msg_count         OUT NOCOPY NUMBER,
                                 x_msg_data          OUT NOCOPY VARCHAR2
                                 )
IS

   CURSOR c_access_det IS
   SELECT *
   FROM ams_act_access
   WHERE arc_act_access_to_object = 'CAMP'
   AND   act_access_to_object_id = p_campaign_id ;
   l_access_det c_access_det%ROWTYPE;

   l_access_rec   AMS_Access_Pvt.access_rec_type ;
   l_dummy_id     NUMBER ;

BEGIN

   l_access_rec.act_access_to_object_id := p_schedule_id  ;
   l_access_rec.arc_act_access_to_object := 'CSCH' ;
   l_access_rec.user_or_role_id := p_owner_id ;
   l_access_rec.arc_user_or_role_type := 'USER' ;
   l_access_rec.owner_flag := 'Y' ;
   l_access_rec.delete_flag := 'N' ;
   l_access_rec.admin_flag := 'Y' ;

   AMS_Access_Pvt.Create_Access(
           p_api_version       => 1,
           p_init_msg_list     => p_init_msg_list,
           p_commit            => p_commit,
           p_validation_level  => p_validation_level,

           x_return_status     => x_return_status,
           x_msg_count         => x_msg_count,
           x_msg_data          => x_msg_data,

           p_access_rec        => l_access_rec,
           x_access_id         => l_dummy_id
        );
   IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;


   OPEN c_access_det ;
   LOOP
      FETCH c_access_det INTO l_access_det;
      EXIT WHEN c_access_det%NOTFOUND ;

      IF l_access_det.arc_user_or_role_type = 'USER'
      AND l_access_det.user_or_role_id = p_owner_id
      THEN
         -- Entry of user is already gone is dont do anything
         NULL ;
      ELSE
         -- Create Access for the team /owner
         l_access_rec.owner_flag := 'N' ;
         l_access_rec.user_or_role_id := l_access_det.user_or_role_id ;
         l_access_rec.arc_user_or_role_type := l_access_det.arc_user_or_role_type ;
         l_access_rec.delete_flag := l_access_det.delete_flag ;
         --l_access_rec.admin_flag := l_access_rec.admin_flag ;
    l_access_rec.admin_flag := l_access_det.admin_flag ;--anchaudh: changed rec type to l_access_det.

         AMS_Access_Pvt.Create_Access(
                 p_api_version       => 1,
                 p_init_msg_list     => p_init_msg_list,
                 p_commit            => p_commit,
                 p_validation_level  => p_validation_level,

                 x_return_status     => x_return_status,
                 x_msg_count         => x_msg_count,
                 x_msg_data          => x_msg_data,

                 p_access_rec        => l_access_rec,
                 x_access_id         => l_dummy_id
              );
         IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            CLOSE c_access_det;
            RAISE FND_API.G_EXC_ERROR;
         ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            CLOSE c_access_det;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

      END IF ;

   END LOOP;
   CLOSE c_access_det ;

END Create_Schedule_Access ;





--========================================================================
-- PROCEDURE
--    get_user_id
--
-- PURPOSE
--    This api will take a resource id and give the corresponding user_id
--
-- NOTE
--
-- HISTORY
--  19-mar-2002    soagrawa    Created
--========================================================================


FUNCTION get_user_id (
   p_resource_id IN NUMBER
)
RETURN NUMBER
IS
   l_user_id     NUMBER;

   CURSOR c_user IS
      SELECT user_id
      FROM   ams_jtf_rs_emp_v
      WHERE  resource_id = p_resource_id;
BEGIN
   OPEN c_user;
   FETCH c_user INTO l_user_id;
   IF c_user%NOTFOUND THEN
      l_user_id := -1;
      -- Adding an error message will cause the function
    -- to violate the WNDS pragma, preventing it from
    -- being able to be called from a SQL statement.
   END IF;
   CLOSE c_user;

   RETURN l_user_id;
END get_user_id;



--========================================================================
-- PROCEDURE
--    write_interaction
--
-- PURPOSE
--    This api is called in update_Status to write to interaction history
--    if it was DIRECT_MARKETING  Direct Mail
--
-- NOTE
--
-- HISTORY
--  19-mar-2002    soagrawa    Created to log interactions for
--                             DIRECT_MARKETING MAIL
--  27-may-2003    soagrawa    Fixed NI issue about result of interaction  bug# 2978948
--========================================================================

PROCEDURE  write_interaction(
               p_schedule_id               IN     NUMBER
)

IS

   -- CURSOR:
   -- get the target grp for this CSCH
   -- get  the list entries from that target group
   -- get the party_id for those list entries

   CURSOR c_parties_det IS
      SELECT party_id
      FROM ams_list_entries
      WHERE list_header_id =
                           (SELECT list_header_id
                           FROM ams_act_lists
                           WHERE list_used_by = 'CSCH'
                           AND list_act_type = 'TARGET'
                           AND list_used_by_id = p_schedule_id)
      AND enabled_flag = 'Y';


   CURSOR c_sch_det IS
   SELECT start_date_time, end_date_time, owner_user_id, source_code
   FROM   ams_campaign_schedules_b
   WHERE  schedule_id = p_schedule_id;

   CURSOR c_media_item_id IS
      SELECT JTF_IH_MEDIA_ITEMS_S1.NEXTVAL
      FROM dual;

   CURSOR c_interactions_id IS
      SELECT jtf_ih_interactions_s1.NEXTVAL
      FROM dual;

   CURSOR c_activities_id IS
      SELECT JTF_IH_ACTIVITIES_S1.NEXTVAL
      FROM dual;

   l_interaction_rec       JTF_IH_PUB.interaction_rec_type;
   l_activities            JTF_IH_PUB.activity_tbl_type;
   l_activity_rec          JTF_IH_PUB.activity_rec_type;
   l_media_rec             JTF_IH_PUB.media_rec_type;
   l_interaction_id        NUMBER;
   l_media_id              NUMBER;
   l_party_id              NUMBER;
   l_schedule_start_time   DATE;
   l_schedule_end_time     DATE;
   l_schedule_owner_id     NUMBER;
   l_schedule_source_code  VARCHAR2(30);

   l_return_status  VARCHAR2(1);
   l_msg_count      NUMBER;
   l_msg_data       VARCHAR2(2000);
   l_user_id        NUMBER;

BEGIN

   OPEN c_sch_det;
   FETCH c_sch_det INTO l_schedule_start_time, l_schedule_end_time, l_schedule_owner_id, l_schedule_source_code;
   CLOSE c_sch_det;

   l_user_id :=  get_user_id(p_resource_id   =>   l_schedule_owner_id);

   -- populate media_rec
   OPEN c_media_item_id;
   FETCH c_media_item_id INTO l_media_rec.media_id ;
   CLOSE c_media_item_id;
   -- l_media_rec.media_id                 := JTF_IH_MEDIA_ITEMS_S1.nextval;
   l_media_rec.end_date_time            := l_schedule_end_time ;
   l_media_rec.start_date_time          := l_schedule_start_time ;
   l_media_rec.media_item_type          := 'MAIL' ;

   -- create media_rec
   JTF_IH_PUB.Create_MediaItem
   (
      p_api_version      =>     1.0,
      p_init_msg_list    =>     FND_API.g_false,
         p_commit           =>     FND_API.g_false,
      -- p_resp_appl_id     =>     l_resp_appl_id,
      -- p_resp_id          =>     l_resp_id,
      p_user_id          =>     l_user_id,
      -- p_login_id         =>     l_login_id,
      x_return_status    => l_return_status,
      x_msg_count        => l_msg_count,
      x_msg_data         => l_msg_data,
      p_media_rec        => l_media_rec,
      x_media_id         => l_media_id
   );
   IF l_return_status <> FND_API.g_ret_sts_success THEN
       RAISE FND_API.g_exc_error;
       RETURN;
   END IF;

   IF (AMS_DEBUG_HIGH_ON) THEN
   AMS_Utility_PVT.debug_message('Write interaction: created media item ');
   END IF;

   -- loop for each party id found
   OPEN c_parties_det;
   LOOP
      FETCH  c_parties_det INTO l_party_id ;
      EXIT WHEN c_parties_det%NOTFOUND ;

      IF (AMS_DEBUG_HIGH_ON) THEN



      AMS_Utility_PVT.debug_message('Write interaction: looping for party id ');

      END IF;

      -- populate interaction record
      /*OPEN c_interactions_id;
      FETCH c_interactions_id INTO l_interaction_id ;
      CLOSE c_interactions_id;*/
      -- l_interaction_id := jtf_ih_interactions_s1.nextval ;

      l_interaction_rec.interaction_id         := l_interaction_id ;
      l_interaction_rec.end_date_time          := l_schedule_end_time ;
      l_interaction_rec.start_date_time        := l_schedule_start_time ;
      l_interaction_rec.handler_id             := 530 ;
      l_interaction_rec.outcome_id             := 10 ; -- request processed
-- soagrawa added on 27-may-2003 for NI interaction issue  bug# 2978948
      l_interaction_rec.result_id              := 8 ; -- sent
      l_interaction_rec.resource_id            := l_schedule_owner_id ;
      l_interaction_rec.party_id               := l_party_id ; -- looping for all party ids in the list
      l_interaction_rec.object_id              := p_schedule_id ;
      l_interaction_rec.object_type            := 'CSCH';
      l_interaction_rec.source_code            := l_schedule_source_code;

      -- populate activity record
      /*OPEN c_activities_id;
      FETCH c_activities_id INTO l_activity_rec.activity_id ;
      CLOSE c_activities_id;*/
      -- l_activity_rec.activity_id               := JTF_IH_ACTIVITIES_S1.nextval ;
      l_activity_rec.end_date_time             := l_schedule_end_time ;
      l_activity_rec.start_date_time           := l_schedule_start_time ;
      l_activity_rec.media_id                  := l_media_id ;
      l_activity_rec.action_item_id            := 3 ; -- collateral
      --l_activity_rec.interaction_id            := l_interaction_id ;
      l_activity_rec.outcome_id                := 10 ; -- request processed
      l_activity_rec.result_id                 := 8 ; -- sent
      l_activity_rec.action_id                 := 5 ; -- sent

      -- populate activity table with the activity record
      l_activities(1) := l_activity_rec;

      -- create interaction
      JTF_IH_PUB.Create_Interaction
      (
         p_api_version      =>     1.0,
         p_init_msg_list    =>     FND_API.g_false,
         p_commit           =>     FND_API.g_false,
         -- p_resp_appl_id     =>     l_resp_appl_id, -- 530
         -- p_resp_id          =>     l_resp_id,      -- fnd global
         p_user_id          =>     l_user_id,
         -- p_login_id         =>     l_login_id,
         x_return_status    =>     l_return_status,
         x_msg_count        =>     l_msg_count,
         x_msg_data         =>     l_msg_data,
         p_interaction_rec  =>     l_interaction_rec,
         p_activities       =>     l_activities
      );
      IF l_return_status <> FND_API.g_ret_sts_success THEN
          RAISE FND_API.g_exc_error;
          RETURN;
      END IF;

   END LOOP;
   CLOSE c_parties_det;




END write_interaction;








--========================================================================
-- PROCEDURE
--    Update_Status
--
-- PURPOSE
--    This api is called in Update schedule api (and in approvals' api)
--
-- NOTE
--
-- HISTORY
--  26-Sep-2001    soagrawa    Created.
--  05-dec-2001    soagrawa    Added code for updating status of the related event
--                             for schedules of type event
--  08-mar-2002    soagrawa    Added code to call an events api if changing event schedule
--                             status to closed :fix for bug# 2254382
--  19-mar-2002    soagrawa    Added code to fix bug# 2263166 regding TGRP purging
--  14-may-2002    soagrawa    Modified for status of new schedule eblast
--  08-jul-2002    soagrawa    Fixed content related bug# 2442744
--  26-jul-2002    soagrawa    Fixed order of template approval and call to submit_conc_request
--                             for bug# 2463596
--  24-sep-2002    soagrawa    Fixed condition for call to process_leads, refer to bug# 2582436
--  26-may-2003    anchaudh    Called list api Update_Prev_contacted_count
--  24-Aug-2003    ptendulk    Modified to call business event on the schedule activation
--  06-Sep-2003    ptendulk    Modified the workflow parameter name to SCHEDULE_ID from AMS_SCHEDULE_ID
--  26-sep-2003    soagrawa    Modified to accommodate triggers and repeating schedules
--  17-Mar-2005    spendem     call the API to raise business event on status change as per enh # 3805347
--========================================================================================================
PROCEDURE update_status(         p_schedule_id             IN NUMBER,
                                 p_new_status_id           IN NUMBER,
                                 p_new_status_code         IN VARCHAR2,
             p_asn_group_id            IN VARCHAR2 DEFAULT NULL -- anchaudh added for leads bug.
                                 )
IS

   CURSOR c_sch_det IS
   SELECT start_date_time, timezone_id,
          activity_type_code, activity_id,
          related_event_id           -- soagrawa 05-dec-2001 - now also retrieving related event id.
                                     -- so as to update the event's status
          , user_status_id, status_code  -- soagrawa 19-mar-2002
          , source_code                  -- soagrawa 22-oct-2002   for bug# 2594717
          , NVL(triggerable_flag,'N')    -- soagrawa 26-sep-2003   for trigger and repeating schedule code change
          , NVL(trig_repeat_flag,'N')    -- soagrawa 26-sep-2003   for trigger and repeating schedule code change
          , orig_csch_id                 -- soagrawa 26-sep-2003   for trigger and repeating schedule code change
          , owner_user_id                -- vmodur
          , campaign_id                  -- vmodur
   FROM   ams_campaign_schedules_b
   WHERE  schedule_id = p_schedule_id;

   l_source_code           VARCHAR2(30);
   l_new_status_id         NUMBER;
   l_activity_type_code    VARCHAR2(30);
   l_activity_id           NUMBER ;
   l_start_time            DATE;
   l_sys_start_time        DATE;
   l_timezone              NUMBER;
   l_related_event_id      NUMBER;
   l_old_status_id         NUMBER;
   l_old_status_code       VARCHAR2(30);
   l_triggerable_flag      VARCHAR2(1); -- soagrawa 26-sep-2003   for trigger and repeating schedule code change
   l_trig_repeat_flag      VARCHAR2(1); -- soagrawa 26-sep-2003   for trigger and repeating schedule code change
   l_orig_csch_id          NUMBER;      -- soagrawa 26-sep-2003   for trigger and repeating schedule code change

   /* REMOVED BY SOAGRAWA ON 26-SEP-2003 : NOT BEING USED ANY MORE
   -- the following cursor and vars added by soagrawa
   -- on 19-mar-2002 for bug# 2263166

   CURSOR c_tgrp_det
   IS SELECT list_header_id
      FROM   ams_act_lists la
      WHERE  list_act_type = 'TARGET'
      AND    list_used_by = 'CSCH'
      AND    list_used_by_id = p_schedule_id
      AND    EXISTS (SELECT *
                     FROM   ams_list_entries le
                     WHERE  le.list_header_id = la.list_header_id) ;
   */

   l_return_status  VARCHAR2(1);
   l_msg_count      NUMBER;
   l_msg_data       VARCHAR2(2000);
   l_tgrp_id        NUMBER;

   /* REMOVED BY SOAGRAWA ON 26-SEP-2003 : NOT BEING USED ANY MORE
   -- the following cursor and variables added by soagrawa on 14-may-2002
   -- for approving item
   CURSOR c_template_det (p_content_item_id NUMBER)
   IS SELECT ver.citem_version_id, ver.object_version_number, ci.content_item_status
      FROM   ibc_citem_versions_vl ver
             , ibc_content_items ci
      WHERE  ci.content_item_id = p_content_item_id
      AND    ci.content_item_id = ver.content_item_id;
   */

   l_citem_ver_id          NUMBER;
   l_RESOURCE_id          NUMBER;
   p_num_asn_group_id     number;
   l_obj_ver_num           NUMBER;
   l_content_item_status   VARCHAR2(20);
   l_def_flag              VARCHAR2(1);

   l_parameter_list  WF_PARAMETER_LIST_T;
   l_new_item_key    VARCHAR2(30);
   l_owner_user_id   NUMBER;
   l_campaign_id     NUMBER;

   l_user_id NUMBER;
   l_resp_id NUMBER;
   l_resp_appl_id NUMBER;
   l_evo_rec AMS_EVENTOFFER_PVT.evo_rec_type; -- vmodur

  -- dbiswas added the following cursor for bug 2852078
   CURSOR c_is_default_flag_on (p_user_status_id NUMBER)
   IS
   SELECT default_flag
     FROM ams_user_statuses_b
    WHERE user_status_id = p_user_status_id;

BEGIN

   l_user_id := FND_GLOBAL.USER_ID;
   l_resp_id := FND_GLOBAL.RESP_ID;
   l_resp_appl_id := FND_GLOBAL.RESP_APPL_ID;

   -- soagrawa on 19-mar-2002
   -- moved the cursor data retrieval from after update to before update
   OPEN c_sch_det;
   FETCH c_sch_det INTO l_start_time, l_timezone, l_activity_type_code, l_activity_id, l_related_event_id
         , l_old_status_id, l_old_status_code, l_source_code
         , l_triggerable_flag, l_trig_repeat_flag, l_orig_csch_id, l_owner_user_id, l_campaign_id;
   CLOSE c_sch_det;

   UPDATE ams_campaign_schedules_b
   SET    user_status_id = p_new_status_id,
          status_code    = p_new_status_code, -- AMS_Utility_PVT.get_system_status_code(p_new_status_id),
          status_date    = SYSDATE,
          object_version_number = object_version_number + 1,
          last_update_date = SYSDATE
   WHERE  schedule_id    = p_schedule_id;

   -- call to api to raise business event, as per enh # 3805347
     RAISE_BE_ON_STATUS_CHANGE(p_obj_id => p_schedule_id,
                               p_obj_type => 'CSCH',
                p_old_status_code => l_old_status_code,
                               p_new_status_code => p_new_status_code );


   OPEN c_is_default_flag_on(p_new_status_id);
   FETCH c_is_default_flag_on INTO l_def_flag;
   CLOSE c_is_default_flag_on;

   IF (p_new_status_code = 'ACTIVE' OR p_new_status_code = 'AVAILABLE')
   THEN
      IF ((l_old_status_code <> 'ON_HOLD' AND l_old_status_code <> 'AVAILABLE')
      -- Don't submit process if the status is updated from avail as in avail status
      -- there will be process created already
         AND l_def_flag = 'Y')
      THEN

         -- soagrawa 26-sep-2003   Modified logic and code for trigger and repeating schedule code change

         -- Logic:
         --   If it is a triggerable schedule, do nothing.
         --   If it is a non-triggerable repeating schedule's parent instance, raise business event for repeating schedule oracle.apps.ams.campaign.RepeatScheduleEvent with start date of the schedule.
         --   Otherwise, raise business event for schedule execution with start date of the schedule.

         IF l_triggerable_flag <> 'Y'   -- not triggerable
         THEN
            IF l_trig_repeat_flag = 'Y' AND l_orig_csch_id IS NULL  -- repeating csch parent instance
            THEN
               l_new_item_key    := p_schedule_id || 'RPT' || TO_CHAR(SYSDATE,'DDMMRRRRHH24MISS');
               l_parameter_list := WF_PARAMETER_LIST_T();
               wf_event.AddParameterToList(p_name           => 'SCHEDULE_ID',
                                          p_value           => p_schedule_id,
                                          p_parameterlist   => l_parameter_list);

               AMS_UTILITY_PVT.Convert_Timezone(
                     p_init_msg_list   => FND_API.G_TRUE,
                     x_return_status   => l_return_status,
                     x_msg_count       => l_msg_count,
                     x_msg_data        => l_msg_data,

                     p_user_tz_id      => l_timezone,
                     p_in_time         => l_start_time,
                     p_convert_type    => 'SYS',

                     x_out_time        => l_sys_start_time
                     );

               -- If any errors happen let start time be sysdate
               IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                  l_start_time := SYSDATE;
               ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  l_start_time := SYSDATE;
               END IF;

               AMS_Utility_PVT.debug_message('Raise Business event for Repeating Schedule');
               WF_EVENT.Raise
                  ( p_event_name   =>  'oracle.apps.ams.campaign.RepeatScheduleEvent',
                    p_event_key    =>  l_new_item_key,
                    p_parameters   =>  l_parameter_list,
                    p_send_date    =>  l_sys_start_time);

            ELSE -- not repeating csch parent instance
               l_new_item_key    := p_schedule_id || TO_CHAR(SYSDATE,'DDMMRRRRHH24MISS');
               l_parameter_list := WF_PARAMETER_LIST_T();

               wf_event.AddParameterToList(p_name           => 'SCHEDULE_ID',
                                          p_value           => p_schedule_id,
                                          p_parameterlist   => l_parameter_list);
               --ANCHAUDH starts modification for the leads bug.
               IF ((p_asn_group_id IS NOT NULL) AND (p_asn_group_id <> FND_API.g_miss_char)) THEN
              p_num_asn_group_id := to_number(p_asn_group_id);
                   --insert_log_mesg('Anirban passing value of the param in WF, in amsvsbrb.pls as :'||p_num_asn_group_id);

                   wf_event.AddParameterToList(p_name           => 'ASN_GROUP_ID',
                                               p_value           => p_num_asn_group_id,
                                               p_parameterlist   => l_parameter_list);
               ELSE
                   p_num_asn_group_id := to_number('9999');
                   wf_event.AddParameterToList(p_name           => 'ASN_GROUP_ID',
                                               p_value           => p_num_asn_group_id,
                                               p_parameterlist   => l_parameter_list);

         --insert_log_mesg('Anirban passing value of the param in WF, in amsvsbrb.pls as NULL for ASN_GROUP_ID :'||p_num_asn_group_id);

               END IF;


               l_RESOURCE_id := AMS_Utility_PVT.get_resource_id(FND_GLOBAL.user_id);
               --insert_log_mesg('Anirban passing value of l_RESOURCE_id in WF, in amsvsbrb.pls as :'||l_RESOURCE_id);
               wf_event.AddParameterToList(p_name           => 'ASN_RESOURCE_ID',
                                          p_value           => l_RESOURCE_id,
                                          p_parameterlist   => l_parameter_list);

               --ANCHAUDH starts modification for the leads bug.

               AMS_UTILITY_PVT.Convert_Timezone(
                     p_init_msg_list   => FND_API.G_TRUE,
                     x_return_status   => l_return_status,
                     x_msg_count       => l_msg_count,
                     x_msg_data        => l_msg_data,

                     p_user_tz_id      => l_timezone,
                     p_in_time         => l_start_time,
                     p_convert_type    => 'SYS',

                     x_out_time        => l_sys_start_time
                     );

               -- If any errors happen let start time be sysdate
               IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                  l_sys_start_time := SYSDATE;
               ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  l_sys_start_time := SYSDATE;
               END IF;

      AMS_Utility_PVT.Create_Log (
            x_return_status   => l_return_status,
            p_arc_log_used_by => 'CSCH',
            p_log_used_by_id  => p_schedule_id,
            p_msg_data        => 'Before Raise : started with : '||TO_CHAR(l_user_id)||' '||TO_CHAR(l_resp_id)||' '||TO_CHAR(l_resp_appl_id),
            p_msg_type        => 'DEBUG'
            );

               AMS_Utility_PVT.debug_message('Raise Business event for schedule execution');
               WF_EVENT.Raise
                  ( p_event_name   =>  'oracle.apps.ams.campaign.ExecuteSchedule',
                    p_event_key    =>  l_new_item_key,
                    p_parameters   =>  l_parameter_list,
                    p_send_date    =>  l_sys_start_time);
            END IF; -- repeating parent instance check
         END IF; -- not triggerable

         UPDATE ams_campaign_schedules_b
         SET workflow_item_key = l_new_item_key
         WHERE schedule_id  = p_schedule_id ;

      END IF;
   ELSIF (p_new_status_code = 'COMPLETED' AND l_activity_type_code = 'EVENTS')
   THEN
      IF l_def_flag = 'Y' THEN
         AMS_EvhRules_PVT.process_leads(p_event_id  => l_related_event_id,
                                        p_obj_type  => 'CSCH',
                                        p_obj_srccd => l_source_code);
      END IF;
   END IF;

   IF  l_activity_type_code = 'EVENTS'
   THEN
      l_new_status_id := AMS_Utility_PVT.get_default_user_status('AMS_EVENT_STATUS',p_new_status_code);

   --Added by ANSKUMAR for Fulfilment

   IF p_new_status_code='ACTIVE' OR p_new_status_code='CANCELLED'
       THEN
       l_evo_rec.event_offer_id     := l_related_event_id;
       l_evo_rec.event_object_type  := 'EONE';
       l_evo_rec.user_status_id     := l_new_status_id;
       l_evo_rec.system_status_code := p_new_status_code;
      --l_evo_rec.last_status_date   := SYSDATE;
      --l_evo_rec.owner_user_id      := l_owner_user_id;
      --l_evo_rec.application_id     := 530;
      --l_evo_rec.event_level        := 'MAIN';
      --l_evo_rec.parent_type        := 'CAMP';
      --l_evo_rec.parent_id          := l_campaign_id;
      --l_evo_rec.custom_setup_id    := 3000;

      AMS_EventOffer_PVT.fulfill_event_offer(p_evo_rec =>  l_evo_rec,
                                            x_return_status => l_return_status);

    END IF;
      -- Not handling return_stauts here

      UPDATE ams_event_offers_all_b
      SET    user_status_id     = l_new_status_id,
             system_status_code = p_new_status_code,
             last_status_date   = SYSDATE
      WHERE  event_offer_id     = l_related_event_id;


   END IF;

END update_status;




--=====================================================================
-- PROCEDURE
--    Update_Schedule_Owner
--
-- PURPOSE
--    The api is created to update the owner of the schedule from the
--    access table if the owner is changed in update.
--
--    Algorithm:
--      1. Call update_object_owner from access_pvt
--      2. Add access from campaign to schedules
--
-- HISTORY
--    06-Jun-2002 soagrawa    Created. Refer to bug# 2406677
--    18-jun-2002 soagrawa    Fixed bug# 2421601
--=====================================================================
PROCEDURE Update_Schedule_Owner(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,
   p_object_type       IN  VARCHAR2 := NULL ,
   p_schedule_id       IN  NUMBER,
   p_owner_id          IN  NUMBER   )
IS

   CURSOR c_owner IS
   SELECT owner_user_id , campaign_id
   FROM   ams_campaign_schedules_vl
   WHERE  schedule_id = p_schedule_id ;

   CURSOR c_access_csch_det(p_owner NUMBER) IS
   SELECT *
   FROM ams_act_access
   WHERE arc_act_access_to_object = 'CSCH'
   AND   user_or_role_id = p_owner
   AND   arc_user_or_role_type = 'USER'
   AND   act_access_to_object_id = p_schedule_id;

   CURSOR c_access_camp_det(p_campaign_id NUMBER) IS
   SELECT *
   FROM ams_act_access
   WHERE arc_act_access_to_object = 'CAMP'
   -- AND   user_or_role_id = p_owner_id
   AND   arc_user_or_role_type = 'USER'
   AND   act_access_to_object_id = p_campaign_id;


   l_access_csch_rec c_access_csch_det%ROWTYPE;
   l_access_camp_rec c_access_camp_det%ROWTYPE;

   l_access_rec   AMS_Access_Pvt.access_rec_type ;

   l_old_owner    NUMBER ;
   l_campaign_id  NUMBER ;

   l_dummy_id     NUMBER ;


BEGIN
   -- the following 2 lines added by soagrawa on 18-jun-2002
   -- for bug# 2421601
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message('Update schedule owner ');
   END IF;
   x_return_status := FND_API.g_ret_sts_success;

   OPEN c_owner ;
   FETCH c_owner INTO l_old_owner, l_campaign_id ;
   IF c_owner%NOTFOUND THEN
      CLOSE c_owner;
      AMS_Utility_Pvt.Error_Message('AMS_API_RECORD_NOT_FOUND');
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_owner ;

   IF p_owner_id <> l_old_owner THEN

        -- call update_owner_object
        AMS_Access_PVT.update_object_owner(
           p_api_version       => p_api_version,
           p_init_msg_list     => p_init_msg_list,
           p_commit            => p_commit,
           p_validation_level  => p_validation_level,
           x_return_status     => x_return_status,
           x_msg_count         => x_msg_count,
           x_msg_data          => x_msg_data,
           p_object_type       => nvl(p_object_type,'CSCH'),
           p_object_id         => p_schedule_id,
           p_resource_id       => p_owner_id,
           p_old_resource_id   => l_old_owner
        );

         IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

      -- get all the access list ppl of campaign
      -- check if they are not in the access list of the schedule
      -- if they are        do nothing
      -- if they are not    add them


         OPEN c_access_camp_det(l_campaign_id) ;
         LOOP
            FETCH c_access_camp_det INTO l_access_camp_rec;
            EXIT WHEN c_access_camp_det%NOTFOUND ;

               OPEN  c_access_csch_det(l_access_camp_rec.user_or_role_id);
               FETCH c_access_csch_det INTO l_access_csch_rec;
               IF c_access_csch_det%NOTFOUND THEN

                     -- Create Access
                     l_access_rec.act_access_to_object_id := p_schedule_id  ;
                     l_access_rec.arc_act_access_to_object := 'CSCH' ;
                     l_access_rec.owner_flag := 'N' ;
                     l_access_rec.user_or_role_id := l_access_camp_rec.user_or_role_id ;
                     l_access_rec.arc_user_or_role_type := l_access_camp_rec.arc_user_or_role_type ;
                     l_access_rec.delete_flag := l_access_camp_rec.delete_flag ;
                     l_access_rec.admin_flag := l_access_camp_rec.admin_flag ;

                     AMS_Access_Pvt.Create_Access(
                             p_api_version       => p_api_version,
                             p_init_msg_list     => p_init_msg_list,
                             p_commit            => p_commit,
                             p_validation_level  => p_validation_level,

                             x_return_status     => x_return_status,
                             x_msg_count         => x_msg_count,
                             x_msg_data          => x_msg_data,

                             p_access_rec        => l_access_rec,
                             x_access_id         => l_dummy_id
                          );
                     IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                        CLOSE c_access_csch_det;
                        CLOSE c_access_camp_det;
                        RAISE FND_API.G_EXC_ERROR;
                     ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                        CLOSE c_access_csch_det;
                        CLOSE c_access_camp_det;
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                     END IF;


               ELSE
                  -- do nothing
                  NULL;
               END IF;
               CLOSE c_access_csch_det;

         END LOOP;
         CLOSE c_access_camp_det ;

   END IF ;

END Update_Schedule_Owner ;





-- Start of Comments
--
-- NAME
--   Handle_Error
--
-- PURPOSE
--   This Procedure will Get all the Errors from the Message stack and
--   Set the Workflow item attribut with the Error Messages
--
-- Used By Activities
--
--
-- NOTES
--
-- HISTORY
--   03-Sep-2003        ptendulk            created
--   14-Oct-2003        dbiswas             added wf_attrib to signature
-- End of Comments
PROCEDURE Handle_Error
            (p_itemtype                 IN VARCHAR2    ,
             p_itemkey                  IN VARCHAR2    ,
             p_msg_count                IN NUMBER      , -- Number of error Messages
             p_msg_data                 IN VARCHAR2   ,
             p_wf_err_attrib            IN VARCHAR2 := 'ERROR_MSG'
            )
IS
   l_msg_count       NUMBER ;
   l_msg_data        VARCHAR2(2000);
   l_final_data      VARCHAR2(4000);
   l_msg_index       NUMBER ;
   l_cnt             NUMBER := 0 ;
   l_return_status   VARCHAR2(1);
   l_schedule_id     NUMBER ;
BEGIN

   l_schedule_id := WF_ENGINE.GetItemAttrText(
               itemtype    =>     p_itemtype,
               itemkey     =>     p_itemkey ,
               aname       =>    'SCHEDULE_ID');

   AMS_Utility_PVT.Create_Log (
                     x_return_status   => l_return_status,
                     p_arc_log_used_by => 'CSCH',
                     p_log_used_by_id  => l_schedule_id,
                     p_msg_data        => 'Error Message handling',
                     p_msg_type        => 'DEBUG'
                     );

   WHILE l_cnt < p_msg_count
   LOOP
      FND_MSG_PUB.Get(p_msg_index      => l_cnt + 1,
                      p_encoded        => FND_API.G_FALSE,
                      p_data           => l_msg_data,
                      p_msg_index_out  => l_msg_index )       ;
      l_final_data := l_final_data ||l_msg_index||': '||l_msg_data||fnd_global.local_chr(10);
      l_cnt := l_cnt + 1 ;

   END LOOP ;

   WF_ENGINE.SetItemAttrText(itemtype     =>    p_itemtype,
                             itemkey      =>    p_itemkey ,
                             aname        =>    'ERROR_MESSAGE',
                             avalue       =>    l_final_data   );

END Handle_Error;



--=====================================================================
-- PROCEDURE
--    Init_Schedule_val
--
-- PURPOSE
--    This api will be used by schedule execution workflow to initialize the schedule
--    parameter values.
--
-- HISTORY
--    23-Aug-2003  ptendulk       Created.
--    19-Sep-2003  dbiswas        Update out to out nocopy
--    09-nov-2004   anchaudh      Now setting item owner along with bug fix for bug# 3799053
--=====================================================================
PROCEDURE Init_Schedule_val(itemtype    IN     VARCHAR2,
                            itemkey     IN     VARCHAR2,
                            actid       IN     NUMBER,
                            funcmode    IN     VARCHAR2,
                            result      OUT NOCOPY    VARCHAR2) IS
   l_schedule_id NUMBER;

   CURSOR c_schedule_det(l_csch_id NUMBER) IS
   SELECT schedule_name, status_code,owner_user_id,
   DECODE(activity_type_code,'DIRECT_SALES','SALES','DIRECT_MARKETING','DIRECT_MARKETING','OTHERS') activity_type,
   activity_id, start_date_time, end_date_time
   FROM ams_campaign_schedules_vl
   WHERE schedule_id = l_csch_id ;
   l_schedule_rec c_schedule_det%ROWTYPE;

   CURSOR c_emp_dtl(l_res_id IN NUMBER) IS
   SELECT employee_id
   FROM   ams_jtf_rs_emp_v
   WHERE  resource_id = l_res_id ;
   l_emp_id NUMBER;
   l_user_name VARCHAR2(100);
   l_display_name VARCHAR2(100);
   l_return_status VARCHAR2(1);
   l_user_id NUMBER;
   l_resp_id NUMBER;
   l_resp_appl_id NUMBER;

BEGIN
   IF (funcmode = 'RUN')
   THEN

      l_schedule_id := WF_ENGINE.GetItemAttrText(
                  itemtype    =>     itemtype,
                  itemkey     =>     itemkey ,
                  aname       =>    'SCHEDULE_ID');

      l_user_id := FND_GLOBAL.USER_ID;
      l_resp_id := FND_GLOBAL.RESP_ID;
      l_resp_appl_id := FND_GLOBAL.RESP_APPL_ID;

      AMS_Utility_PVT.Create_Log (
            x_return_status   => l_return_status,
            p_arc_log_used_by => 'CSCH',
            p_log_used_by_id  => l_schedule_id,
            p_msg_data        => 'Init_Schedule_val : started with '||TO_CHAR(l_user_id)||' '||TO_CHAR(l_resp_id)||' '||TO_CHAR(l_resp_appl_id),
            p_msg_type        => 'DEBUG'
            );

      OPEN c_schedule_det(l_schedule_id);
      FETCH c_schedule_det INTO l_schedule_rec ;
      CLOSE c_schedule_det;

      OPEN c_emp_dtl(l_schedule_rec.owner_user_id);
      FETCH c_emp_dtl INTO l_emp_id;
         -- soagrawa setting item owner along with bug fix for bug# 3799053
         IF c_emp_dtl%FOUND
         THEN
            WF_DIRECTORY.getrolename
                 ( p_orig_system      => 'PER',
                   p_orig_system_id   => l_emp_id ,
                   p_name             => l_user_name,
                   p_display_name     => l_display_name );

            IF l_user_name IS NOT NULL THEN
               Wf_Engine.SetItemOwner(itemtype    => itemtype,
                                itemkey     => itemkey,
                                owner       => l_user_name);
            END IF;
         END IF;
      CLOSE c_emp_dtl;

      WF_ENGINE.SetItemAttrText(itemtype =>   itemtype,
                                itemkey  =>   itemkey,
                                aname    =>   'SCHEDULE_NAME',
                                avalue   =>   l_schedule_rec.schedule_name);

      WF_ENGINE.SetItemUserkey(itemtype  =>   itemtype,
                                itemkey  =>   itemkey ,
                                userkey  =>   l_schedule_rec.schedule_name);

      WF_ENGINE.SetItemAttrText(itemtype =>   itemtype,
                                itemkey  =>   itemkey,
                                aname    =>   'SCHEDULE_OWNER',
                                avalue   =>   l_user_name);

       WF_ENGINE.SetItemAttrText(itemtype =>   itemtype,
                                itemkey  =>   itemkey,
                                aname    =>   'WF_ADMINISTRATOR',
                                avalue   =>   l_user_name);

     WF_ENGINE.SetItemAttrText(itemtype =>   itemtype,
                                itemkey  =>   itemkey,
                                aname    =>   'SCHEDULE_STATUS',
                                avalue   =>   l_schedule_rec.status_code);

      WF_ENGINE.SetItemAttrText(itemtype =>   itemtype,
                                itemkey  =>   itemkey,
                                aname    =>   'SCHEDULE_CHANNEL',
                                avalue   =>   l_schedule_rec.activity_id );

      WF_ENGINE.SetItemAttrText(itemtype =>   itemtype,
                                itemkey  =>   itemkey,
                                aname    =>   'ACTIVITY_TYPE',
                                avalue   =>   l_schedule_rec.activity_type );

      WF_ENGINE.SetItemAttrText(itemtype =>   itemtype,
                                itemkey  =>   itemkey,
                                aname    =>   'ERROR_FLAG',
                                avalue   =>   'N');
      WF_ENGINE.SetItemAttrText(itemtype =>   itemtype,
                                itemkey  =>   itemkey,
                                aname    =>   'AMS_SCHEDULE_START_DATE',
                                avalue   =>   l_schedule_rec.start_date_time );

      WF_ENGINE.SetItemAttrText(itemtype =>   itemtype,
                                itemkey  =>   itemkey,
                                aname    =>   'AMS_SCHEDULE_END_DATE',
                                avalue   =>   l_schedule_rec.end_date_time );

   END IF;

   --  CANCEL mode  - Normal Process Execution
   IF (funcmode = 'CANCEL')
   THEN
      RETURN;
   END IF;

   --  TIMEOUT mode  - Normal Process Execution
   IF (funcmode = 'TIMEOUT')
   THEN
      RETURN;
   END IF;
   -- dbms_output.put_line('End Check Trigger stat :'||result);

EXCEPTION
   WHEN OTHERS THEN
      wf_core.context(G_PKG_NAME,'Init_Schedule_val',itemtype,itemkey,actid,funcmode);
      RAISE ;
END ;

/* Commented for sql rep 14423973. Bug 4956974
PROCEDURE AMS_SELECTOR
( p_itemtype in varchar2
, p_itemkey in varchar2
, p_actid in number
, p_funcmode in varchar2
, p_result in out nocopy varchar2)
IS
l_user_id NUMBER;
l_resp_id NUMBER;
l_resp_appl_id NUMBER;
l_return_status     VARCHAR2(1);
l_schedule_id NUMBER;

CURSOR c_schedule_creator_id (p_schedule_id IN NUMBER) IS
select created_by
from ams_campaign_schedules_b
where schedule_id = p_schedule_id;

CURSOR c_user_resp_dtl(p_user_id IN NUMBER) IS
SELECT responsibility_id
FROM   fnd_user_resp_groups
WHERE  responsibility_application_id = 530
and user_id = p_user_id
and rownum < 2;

BEGIN
IF (p_funcmode = 'RUN') THEN
-- Code that determines Start Process
p_result := 'COMPLETE';
ELSIF (p_funcmode = 'TEST_CTX') THEN
-- Code that compares current session context
-- with the work item context required to execute
-- the workflow safely
l_user_id := FND_GLOBAL.USER_ID;
l_resp_id := FND_GLOBAL.RESP_ID;
l_resp_appl_id := FND_GLOBAL.RESP_APPL_ID;

l_schedule_id := WF_ENGINE.GetItemAttrText(
              itemtype    =>     p_itemtype,
              itemkey     =>     p_itemkey ,
              aname       =>    'SCHEDULE_ID');

AMS_Utility_PVT.Create_Log (
        x_return_status   => l_return_status,
        p_arc_log_used_by => 'CSCH',
        p_log_used_by_id  => l_schedule_id,
        p_msg_data        => 'Ams_Selector TEST_CTX : started with : '||TO_CHAR(l_user_id)||' '||TO_CHAR(l_resp_id)||' '||TO_CHAR(l_resp_appl_id),
        p_msg_type        => 'DEBUG'
       );

if l_user_id < 0 then
-- If the background engine is executing the
-- Selector/Callback function, the workflow engine
-- Will immediately run the Selector/Callback
-- Function in SET_CTX mode
OPEN c_schedule_creator_id(l_schedule_id);
FETCH c_schedule_creator_id INTO l_user_id;
CLOSE c_schedule_creator_id;

OPEN c_user_resp_dtl(l_user_id);
FETCH c_user_resp_dtl INTO l_resp_id;
CLOSE c_user_resp_dtl;

l_resp_appl_id := 530;

AMS_Utility_PVT.Create_Log (
        x_return_status   => l_return_status,
        p_arc_log_used_by => 'CSCH',
        p_log_used_by_id  => l_schedule_id,
        p_msg_data        => 'Ams_Selector TEST_CTX : setting the apps ctx to : '||TO_CHAR(l_user_id)||' '||TO_CHAR(l_resp_id)||' '||TO_CHAR(l_resp_appl_id),
        p_msg_type        => 'DEBUG'
       );

-- Set the database session context
FND_GLOBAL.Apps_Initialize(l_user_id, l_resp_id, l_resp_appl_id);
p_result := 'COMPLETE:FALSE';
else
p_result := 'COMPLETE:TRUE';
end if;
ELSIF(p_funcmode = 'SET_CTX') THEN
-- Code that sets the current session context
-- based on the work item context stored in item attributes
-- get Item Attributes for user_id, responsibility_id and application_id
-- this assumes that they were set as item attribute, probably through
-- definition.
l_schedule_id := WF_ENGINE.GetItemAttrText(
              itemtype    =>     p_itemtype,
              itemkey     =>     p_itemkey ,
              aname       =>    'SCHEDULE_ID');

OPEN c_schedule_creator_id(l_schedule_id);
FETCH c_schedule_creator_id INTO l_user_id;
CLOSE c_schedule_creator_id;

OPEN c_user_resp_dtl(l_user_id);
FETCH c_user_resp_dtl INTO l_resp_id;
CLOSE c_user_resp_dtl;

l_resp_appl_id := 530;

-- Set the database session context which also sets the org
--FND_GLOBAL.Apps_Initialize(l_user_id, l_resp_id, l_resp_appl_id);
AMS_Utility_PVT.Create_Log (
        x_return_status   => l_return_status,
        p_arc_log_used_by => 'CSCH',
        p_log_used_by_id  => l_schedule_id,
        p_msg_data        => 'Ams_Selector SET_CTX : setting the apps ctx to : '||TO_CHAR(l_user_id)||' '||TO_CHAR(l_resp_id)||' '||TO_CHAR(l_resp_appl_id),
        p_msg_type        => 'DEBUG'
       );

p_result := 'COMPLETE';
ELSE
p_result := 'COMPLETE';
END IF;
EXCEPTION
WHEN OTHERS THEN NULL;
WF_CORE.Context('PROD_STANDARD_WF', 'AMS_SELECTOR', p_itemtype, p_itemkey, p_actid, p_funcmode);
RAISE;
END AMS_SELECTOR;
*/

--=====================================================================
-- PROCEDURE
--    Check_Schedule_Status
--
-- PURPOSE
--    This api will be used by schedule execution workflow to check schedule status
--    The schedule can be in available or active status. if the schedule is available
--    workflow will update the status to active.
--
-- HISTORY
--    23-Aug-2003  ptendulk       Created.
--    19-Sep-2003  dbiswas        Added nocopy
--=====================================================================
PROCEDURE Check_Schedule_Status(itemtype    IN     VARCHAR2,
                                itemkey     IN     VARCHAR2,
                                actid       IN     NUMBER,
                                funcmode    IN     VARCHAR2,
                                result      OUT NOCOPY    VARCHAR2) IS
    l_schedule_status   VARCHAR2(30) ;
    l_return_status     VARCHAR2(1);
    l_schedule_id       NUMBER;
BEGIN
-- dbms_output.put_line('Process Check_Repeat');
    --  RUN mode  - Normal Process Execution
    IF (funcmode = 'RUN')
    THEN
        l_schedule_id  := WF_ENGINE.GetItemAttrText(
                                 itemtype    =>    itemtype,
                                 itemkey      =>     itemkey ,
                                 aname      =>    'SCHEDULE_ID' );

      AMS_Utility_PVT.Create_Log (
            x_return_status   => l_return_status,
            p_arc_log_used_by => 'CSCH',
            p_log_used_by_id  => l_schedule_id,
            p_msg_data        => 'Check_Schedule_Status : started',
            p_msg_type        => 'DEBUG'
            );

        l_schedule_status  := WF_ENGINE.GetItemAttrText(
                                 itemtype    =>    itemtype,
                                 itemkey      =>     itemkey ,
                                 aname      =>    'SCHEDULE_STATUS' );


      -- make sure that last activation date is updated
      UPDATE ams_campaign_schedules_b
      SET last_activation_date = SYSDATE,
        object_version_number = object_version_number + 1,
        last_update_date = SYSDATE,
        last_updated_by = FND_GLOBAL.user_id
      WHERE schedule_id = l_schedule_id ;

      IF   l_schedule_status  = 'ACTIVE' THEN
         result := 'COMPLETE:ACTIVE' ;
      ELSE
         result := 'COMPLETE:AVAILABLE' ;
      END IF ;
    END IF;

    --  CANCEL mode  - Normal Process Execution
    IF (funcmode = 'CANCEL')
    THEN
       result := 'COMPLETE:' ;
      RETURN;
    END IF;

    --  TIMEOUT mode  - Normal Process Execution
    IF (funcmode = 'TIMEOUT')
    THEN
       result := 'COMPLETE:' ;
      RETURN;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
         wf_core.context(G_PKG_NAME,'Check_Schedule_Status',itemtype,itemkey,actid,funcmode);
        raise ;
END Check_Schedule_Status ;


--=========================================================================================================
-- PROCEDURE
--    Update_Schedule_Status
--
-- PURPOSE
--    This api will be used by schedule execution workflow to update schedule status
--    It will update the schedule status to Active.
--
-- HISTORY
--    23-Aug-2003  ptendulk       Created.
--    19-Sep-2003  dbiswas        Added nocopy
--    17-Mar-2005  spendem        call the API to raise business event on status change as per enh # 3805347
--===========================================================================================================
PROCEDURE Update_Schedule_Status(itemtype    IN     VARCHAR2,
                                itemkey     IN     VARCHAR2,
                                actid       IN     NUMBER,
                                funcmode    IN     VARCHAR2,
                                result      OUT NOCOPY    VARCHAR2) IS

   -- declare cursor as per enh # 3805347
   CURSOR c_csch_det(p_schedule_id IN NUMBER) IS
   SELECT status_code
   FROM   ams_campaign_schedules_b
   WHERE  schedule_id = p_schedule_id;

   l_schedule_id NUMBER;
   l_user_status_id NUMBER ;
   l_return_status VARCHAR2(1);
   l_old_status_code VARCHAR2(30);  -- added as per enh # 3805347.

BEGIN
-- dbms_output.put_line('Process Check_Repeat');
    --  RUN mode  - Normal Process Execution
   IF (funcmode = 'RUN')
   THEN
      l_schedule_id  := WF_ENGINE.GetItemAttrText(
                                 itemtype   =>    itemtype,
                                 itemkey    =>     itemkey ,
                                 aname      =>    'SCHEDULE_ID' );

      AMS_Utility_PVT.Create_Log (
            x_return_status   => l_return_status,
            p_arc_log_used_by => 'CSCH',
            p_log_used_by_id  => l_schedule_id,
            p_msg_data        => 'Update_Schedule_Status : started',
            p_msg_type        => 'DEBUG'
            );


   -- open cursor here for enh # 3805347
   OPEN c_csch_det(l_schedule_id);
   FETCH c_csch_det INTO l_old_status_code;
   CLOSE c_csch_det;

      l_user_status_id := AMS_Utility_PVT.get_default_user_status('AMS_CAMPAIGN_SCHEDULE_STATUS','ACTIVE') ;

      UPDATE ams_campaign_schedules_b
      SET status_code = 'ACTIVE',
          user_status_id = l_user_status_id,
          status_date = SYSDATE,
          last_activation_date = SYSDATE,
          object_version_number = object_version_number + 1,
          last_update_date = SYSDATE,
          last_updated_by = FND_GLOBAL.user_id
      WHERE schedule_id = l_schedule_id ;

     -- call to api to raise business event, as per enh # 3805347
     RAISE_BE_ON_STATUS_CHANGE(p_obj_id => l_schedule_id,
                               p_obj_type => 'CSCH',
                p_old_status_code => l_old_status_code,
                               p_new_status_code => 'ACTIVE' );

   END IF;

   --  CANCEL mode  - Normal Process Execution
   IF (funcmode = 'CANCEL')
   THEN
      RETURN;
   END IF;

   --  TIMEOUT mode  - Normal Process Execution
   IF (funcmode = 'TIMEOUT')
   THEN
      RETURN;
   END IF;
   -- dbms_output.put_line('End Check Trigger stat :'||result);
EXCEPTION
   WHEN OTHERS THEN
      wf_core.context(G_PKG_NAME,'Update_Schedule_Status',itemtype,itemkey,actid,funcmode);
      RAISE ;
END Update_Schedule_Status ;


--=====================================================================
-- PROCEDURE
--    Check_Schedule_Act_Type
--
-- PURPOSE
--    This api will be used by schedule execution workflow to check schedule activity
--    Based on the activity type different apis will be called.
--
-- HISTORY
--    23-Aug-2003  ptendulk       Created.
--    19-Sep-2003  dbiswas        Added nocopy
--=====================================================================
PROCEDURE Check_Schedule_Act_Type(itemtype    IN     VARCHAR2,
                                itemkey     IN     VARCHAR2,
                                actid       IN     NUMBER,
                                funcmode    IN     VARCHAR2,
                                result      OUT NOCOPY    VARCHAR2) IS
    l_schedule_activity   VARCHAR2(30) ;
    l_return_status     VARCHAR2(1);
    l_schedule_id       NUMBER;
BEGIN
-- dbms_output.put_line('Process Check_Repeat');
    --  RUN mode  - Normal Process Execution
    IF (funcmode = 'RUN')
    THEN
         l_schedule_id  := WF_ENGINE.GetItemAttrText(
                                 itemtype    =>    itemtype,
                                 itemkey      =>     itemkey ,
                                 aname      =>    'SCHEDULE_ID' );

         AMS_Utility_PVT.Create_Log (
            x_return_status   => l_return_status,
            p_arc_log_used_by => 'CSCH',
            p_log_used_by_id  => l_schedule_id,
            p_msg_data        => 'Check_Schedule_Act_Type : started',
            p_msg_type        => 'DEBUG'
            );

        l_schedule_activity  := WF_ENGINE.GetItemAttrText(
                                 itemtype    =>    itemtype,
                                 itemkey      =>     itemkey ,
                                 aname      =>    'ACTIVITY_TYPE' );


      result := 'COMPLETE:'||l_schedule_activity ;

    END IF;

    --  CANCEL mode  - Normal Process Execution
    IF (funcmode = 'CANCEL')
    THEN
       result := 'COMPLETE:' ;
      RETURN;
    END IF;

    --  TIMEOUT mode  - Normal Process Execution
    IF (funcmode = 'TIMEOUT')
    THEN
       result := 'COMPLETE:' ;
      RETURN;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
         wf_core.context(G_PKG_NAME,'Check_Schedule_Act_Type',itemtype,itemkey,actid,funcmode);
        raise ;
END Check_Schedule_Act_Type ;

--=====================================================================
-- PROCEDURE
--    Execute_Direct_Marketing
--
-- PURPOSE
--    This api will be used by schedule execution workflow to execute schedule
--    of type Direct Marketing
--
-- ALGORITHM
--    1. Does target group exist?
--       Yes => 1.1   Increase usage
--              1.2   Is channel Email, Print, Fax
--                    Yes => 1.2.1  Increase contacted count
--                           1.2.2  Stamp version in ibc_associations table
--                           1.2.3  Send Fulfillment Request
--                           1.2.4  Update list sent out date
--
--  Any error in any of the API callouts?
--   => a) Set attribute ERROR_FLAG to Y
--      b) Call Handle_err to set error msg values
--      c) Return
--
-- OPEN ISSUES
--   1. Use Enable Fulfillment profile before fulilling?
--   2. If not enabled => write interaction or not?
--
-- HISTORY
--    23-Aug-2003  ptendulk       Created.
--    19-Sep-2003  dbiswas        Added nocopy
--    29-sep-2003  soagrawa       Modified to clean up the code and removed interaction for direct mail channel
--    29-sep-2003  soagrawa       Modified to clean up the code and removed interaction for direct mail channel
--    05-apr-2004  soagrawa       added ELSE part for when TGRP does not exist
--                                this is needed for automated flows like Repeating Schedules / Triggers
--                                pls refer bug# 3553087
--    29-apr-2004  anchaudh        fixed the reopened bug#3553087
--    09-nov-2004  anchaudh       fixed bug# 3799053 about FFM requests being created with random user ids
--    28-jan-2005  spendem        fix for bug # 4145845. Added to_char function to the schedule_id
--    14-mar-2005  spendem        fix for bug # 4184571. Adding a filter for unwanted error.
--=========================================================================================================
PROCEDURE Execute_Direct_Marketing(itemtype  IN     VARCHAR2,
                                itemkey      IN     VARCHAR2,
                                actid        IN     NUMBER,
                                funcmode     IN     VARCHAR2,
                                result       OUT  NOCOPY   VARCHAR2) IS

   CURSOR c_tgrp_det(l_csch_id IN NUMBER) IS
   SELECT list_header_id
     FROM ams_act_lists la
    WHERE list_act_type = 'TARGET'
      AND list_used_by = 'CSCH'
      AND list_used_by_id = l_csch_id
      AND EXISTS (SELECT *
                    FROM   ams_list_entries le
                   WHERE  le.list_header_id = la.list_header_id) ;

   -- soagrawa added the following cursor on 30-sep-2003 for stamping version
   CURSOR c_cover_letter_det (l_csch_id IN NUMBER) IS
   SELECT assoc.association_id, assoc.content_item_id, ci.live_citem_version_id
     FROM ibc_associations assoc, ibc_content_Items ci
    WHERE assoc.association_type_code = 'AMS_CSCH'
    AND assoc.associated_object_val1 = to_char(l_csch_id) -- fix for bug # 4145845
      AND assoc.content_item_id = ci.content_Item_id;

    -- anchaudh added the following cursor on 01-nov-2004 for getting csch owner, bug# 3799053
   CURSOR c_csch_det (l_csch_id IN NUMBER) IS
       SELECT owner_user_id
       FROM   ams_campaign_schedules_b
       WHERE  schedule_id = l_csch_id ;

   l_csch_owner_user_id  NUMBER;
   l_schedule_id         NUMBER;
   l_return_status       VARCHAR2(1) := FND_API.g_ret_sts_success ;
   l_log_return_status   VARCHAR2(1) := FND_API.g_ret_sts_success ;
   l_activity_id         NUMBER;
   l_msg_count           NUMBER;
   l_msg_data            VARCHAR2(2000);
   l_list_id             NUMBER;
   l_request_id          NUMBER;
   l_association_id      NUMBER;
   l_cover_letter_id     NUMBER;
   l_cover_letter_ver_id NUMBER;
   l_error_msg      VARCHAR2(4000);

BEGIN

    --  RUN mode  - Normal Process Execution
   IF (funcmode = 'RUN')
   THEN
      -- get schedule id
      l_schedule_id  := WF_ENGINE.GetItemAttrText(
                                 itemtype   =>    itemtype,
                                 itemkey    =>     itemkey ,
                                 aname      =>    'SCHEDULE_ID' );

      AMS_Utility_PVT.Create_Log (
            x_return_status   => l_log_return_status,
            p_arc_log_used_by => 'CSCH',
            p_log_used_by_id  => l_schedule_id,
            p_msg_data        => 'Execute_Direct_Marketing : started for schedule id '||l_schedule_id,
            p_msg_type        => 'DEBUG'
            );


      -- get schedule activity
      l_activity_id := WF_ENGINE.GetItemAttrText(
                                 itemtype   =>    itemtype,
                                 itemkey    =>     itemkey ,
                                 aname      =>    'SCHEDULE_CHANNEL' );
      --
      -- 1. Does target group exist?
      --
      OPEN  c_tgrp_det (l_schedule_id) ;
      FETCH c_tgrp_det INTO l_list_id ;
      CLOSE c_tgrp_det ;


      IF FND_API.G_TRUE = Target_Group_Exist(l_schedule_id)
      THEN
         --
         -- Yes => 1.1   Increase usage
         --
         AMS_Utility_PVT.Create_Log (
               x_return_status   => l_log_return_status,
               p_arc_log_used_by => 'CSCH',
               p_log_used_by_id  => l_schedule_id,
               p_msg_data        => 'Execute_Direct_Marketing : Increase usage',
               p_msg_type        => 'DEBUG'
               );

         AMS_List_Purge_PVT.Increase_Usage
         (
           p_api_version      =>     1.0,
           p_init_msg_list    =>     FND_API.g_false,
           p_commit           =>     FND_API.g_false,
           p_validation_level =>     FND_API.g_valid_level_full,
           x_return_status    =>     l_return_status,
           x_msg_count        =>     l_msg_count,
           x_msg_data         =>     l_msg_data,
           p_list_header_id   =>     l_list_id -- target group id
         );

         IF l_return_status <> FND_API.g_ret_sts_success THEN
            WF_ENGINE.SetItemAttrText(itemtype =>   itemtype,
                       itemkey  =>   itemkey,
                       aname    =>   'ERROR_FLAG',
                       avalue   =>   'Y');
            Handle_Error(p_itemtype  => itemtype,
                         p_itemkey   => itemkey,
                         p_msg_count => l_msg_count,
                         p_msg_data  => l_msg_data);
            RETURN;
         END IF;

         --
         -- 1.2   Is channel Email, Print, Fax
         --
         IF (l_activity_id = 10 OR l_activity_id = 20 OR l_activity_id = 480)
         THEN
            AMS_Utility_PVT.Create_Log (
                     x_return_status   => l_log_return_status,
                     p_arc_log_used_by => 'CSCH',
                     p_log_used_by_id  => l_schedule_id,
                     p_msg_data        => 'Execute_Direct_Marketing : update previously contacted',
                     p_msg_type        => 'DEBUG'
                     );

            --
            -- Yes => 1.2.1  Increase contacted count
            --
            AMS_Listheader_PVT.Update_Prev_Contacted_Count(
                  p_used_by_id            =>  l_schedule_id,
                  p_used_by               =>  'CSCH',
                  p_last_contacted_date   =>  sysdate,
                  p_init_msg_list         =>  FND_API.g_false,
                  p_commit                =>  FND_API.g_false,
                  x_return_status         =>  l_return_status,
                  x_msg_count             =>  l_msg_count,
                  x_msg_data              =>  l_msg_data
             );

             IF l_return_status <> FND_API.g_ret_sts_success THEN
               WF_ENGINE.SetItemAttrText(itemtype =>   itemtype,
                          itemkey  =>   itemkey,
                          aname    =>   'ERROR_FLAG',
                          avalue   =>   'Y');
               Handle_Error(p_itemtype  => itemtype,
                            p_itemkey   => itemkey,
                            p_msg_count => l_msg_count,
                            p_msg_data  => l_msg_data);
               RETURN;
             END IF;

/*
                  WF_ENGINE.SetItemAttrText(itemtype =>   itemtype,
                             itemkey  =>   itemkey,
                             aname    =>   'ERROR_FLAG',
                             avalue   =>   'Y');
                  Handle_Error(p_itemtype  => itemtype,
                               p_itemkey   => itemkey,
                               p_msg_count => l_msg_count,
                               p_msg_data  => l_msg_data);*/

            --
            -- 1.2.2  Stamp version in ibc_associations table
       -- anchaudh : from R12 onwards this stamping of cover letter version will take place in the new event subscription api.
            --
            /*AMS_Utility_PVT.Create_Log (
                  x_return_status   => l_log_return_status,
                  p_arc_log_used_by => 'CSCH',
                  p_log_used_by_id  => l_schedule_id,
                  p_msg_data        => 'Execute_Direct_Marketing : Stamping version',
                  p_msg_type        => 'DEBUG'
                  );

            -- get associated cover letter and its live version
            OPEN  c_cover_letter_det(l_schedule_id);
            FETCH c_cover_letter_det INTO l_association_id, l_cover_letter_id, l_cover_letter_ver_id;
            CLOSE c_cover_letter_det;

            IF l_association_id IS NOT null
             AND l_cover_letter_id IS NOT null
             AND l_cover_letter_ver_id IS NOT NULl
            THEN
               Ibc_Associations_Pkg.UPDATE_ROW(
                     p_association_id                  => l_association_id
                     ,p_content_item_id                => l_cover_letter_id
                     ,p_citem_version_id               => l_cover_letter_ver_id
                     ,p_association_type_code          => 'AMS_CSCH'
                     ,p_associated_object_val1         => l_schedule_id );
            ELSE
               -- throw error because no live cover letter is associated with the schedule
               -- either no cover letter is associated OR the cover letter associated has no live ver
               NULL;
            END IF;*/

            --
            -- 1.2.3  Send Fulfillment Request
            --
            AMS_Utility_PVT.Create_Log (
                  x_return_status   => l_log_return_status,
                  p_arc_log_used_by => 'CSCH',
                  p_log_used_by_id  => l_schedule_id,
                  p_msg_data        => 'Execute_Direct_Marketing : Call to fulfillment',
                  p_msg_type        => 'DEBUG'
                  );

             -- user id added by anchaudh on 09-nov-2004 for bug# 3799053
            OPEN  c_csch_det(l_schedule_id);
            FETCH c_csch_det INTO l_csch_owner_user_id;
            CLOSE c_csch_det;

            AMS_Fulfill_PVT.Ams_Fulfill(
                  p_api_version        => 1.0,
                  p_init_msg_list      => FND_API.g_false,
                  p_commit             => FND_API.g_false,
                  x_return_status      => l_return_status,
                  x_msg_count          => l_msg_count,
                  x_msg_data           => l_msg_data,
                  x_request_history_id => l_request_id,
                  p_schedule_id        => l_schedule_id,
        -- user id passing added by anchaudh on 09-nov-2004 for bug# 3799053
                  p_user_id            => Ams_Utility_pvt.get_user_id(l_csch_owner_user_id)
                  ) ;

            AMS_Utility_PVT.Create_Log (
                  x_return_status   => l_log_return_status,
                  p_arc_log_used_by => 'CSCH',
                  p_log_used_by_id  => l_schedule_id,
                  p_msg_data        => 'Execute_Direct_Marketing : Call to fulfillment : Return status is '||l_return_status,
                  p_msg_type        => 'DEBUG'
                  );

            IF l_return_status <> FND_API.g_ret_sts_success THEN
               WF_ENGINE.SetItemAttrText(itemtype =>   itemtype,
                          itemkey  =>   itemkey,
                          aname    =>   'ERROR_FLAG',
                          avalue   =>   'Y');
               Handle_Error(p_itemtype  => itemtype,
                            p_itemkey   => itemkey,
                            p_msg_count => l_msg_count,
                            p_msg_data  => l_msg_data);
               RETURN;
            END IF;

            --
            -- 1.2.4  Update list sent out date
            --
            AMS_Utility_PVT.Create_Log (
                  x_return_status   => l_log_return_status,
                  p_arc_log_used_by => 'CSCH',
                  p_log_used_by_id  => l_schedule_id,
                  p_msg_data        => 'Execute_Direct_Marketing : calling update_list_send_out_date ',
                  p_msg_type        => 'DEBUG'
                  );

            Update_List_Sent_Out_Date(
                  p_api_version       => 1.0,
                  p_init_msg_list     => FND_API.g_false,
                  p_commit            => FND_API.g_false,

                  x_return_status     => l_return_status,
                  x_msg_count         => l_msg_count,
                  x_msg_data          => l_msg_data,

                  p_list_header_id    => l_list_id);

            AMS_Utility_PVT.Create_Log (
                  x_return_status   => l_log_return_status,
                  p_arc_log_used_by => 'CSCH',
                  p_log_used_by_id  => l_schedule_id,
                  p_msg_data        => 'Execute_Direct_Marketing : update_list_send_out_date : Return status is '||l_return_status,
                  p_msg_type        => 'DEBUG'
                  );

            IF l_return_status <> FND_API.g_ret_sts_success THEN
               WF_ENGINE.SetItemAttrText(itemtype =>   itemtype,
                          itemkey  =>   itemkey,
                          aname    =>   'ERROR_FLAG',
                          avalue   =>   'Y');
               Handle_Error(p_itemtype  => itemtype,
                            p_itemkey   => itemkey,
                            p_msg_count => l_msg_count,
                            p_msg_data  => l_msg_data);
               RETURN;
            END IF;

         END IF; -- activity is email / print / fax

      -- 05-apr-2004  soagrawa added ELSE part for when TGRP does not exist
      -- this is needed for automated flows like Repeating Schedules / Triggers
      -- pls refer bug# 3553087

      ELSE
         -- if TGRP does not exist
         -- AMS_Utility_PVT.Error_Message('AMS_CSCH_NO_TARGET_GROUP');

         -- Throw a valid error, if TG does not exist.. Filter should be on channel email.fax/print and Telemarketing.
    -- fix for bug # 4184571
    IF (l_activity_id = 10 OR l_activity_id = 20 OR l_activity_id = 460 OR l_activity_id = 480)
         THEN

    AMS_Utility_PVT.Create_Log (
                     x_return_status   => l_log_return_status,
                     p_arc_log_used_by => 'CSCH',
                     p_log_used_by_id  => l_schedule_id,
                     p_msg_data        => 'Execute_Direct_Marketing : Target Group is empty',
                     p_msg_type        => 'DEBUG'
                     );

         WF_ENGINE.SetItemAttrText(itemtype =>   itemtype,
                       itemkey  =>   itemkey,
                       aname    =>   'ERROR_FLAG',
                       avalue   =>   'Y');

        /* Handle_Error(p_itemtype  => itemtype,     --    29-apr-2004  anchaudh  :    fixed the reopened bug#3553087
                         p_itemkey   => itemkey,
                         p_msg_count => l_msg_count,
                         p_msg_data  => l_msg_data);*/

         l_error_msg := FND_MESSAGE.get_string('AMS','AMS_CSCH_NO_TARGET_GROUP');

         WF_ENGINE.SetItemAttrText(itemtype =>   itemtype,     --    29-apr-2004  anchaudh  :     fixed the reopened bug#3553087
                       itemkey  =>   itemkey,
                       aname    =>   'ERROR_MESSAGE',
                       avalue   =>   l_error_msg);


         END IF;

      END IF; -- target group exists

   END IF; -- func mode is RUN

   --  CANCEL mode  - Normal Process Execution
   IF (funcmode = 'CANCEL')
   THEN
      RETURN;
   END IF;

   --  TIMEOUT mode  - Normal Process Execution
   IF (funcmode = 'TIMEOUT')
   THEN
      RETURN;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      wf_core.context(G_PKG_NAME,'Execute_Direct_Marketing',itemtype,itemkey,actid,funcmode);
      RAISE ;
END Execute_Direct_Marketing;



--=====================================================================
-- PROCEDURE
--    Execute_Sales
--
-- PURPOSE
--    This api will be used by schedule execution workflow to execute schedule
--    of type Sales
--
-- HISTORY
--    23-Aug-2003  ptendulk       Created.
--    19-Sep-2003  dbiswas        Added nocopy
--=====================================================================
PROCEDURE Execute_Sales(itemtype     IN     VARCHAR2,
                        itemkey      IN     VARCHAR2,
                        actid        IN     NUMBER,
                        funcmode     IN     VARCHAR2,
                        result       OUT NOCOPY   VARCHAR2) IS
   l_schedule_id     NUMBER;
   l_return_status   VARCHAR2(1) := FND_API.g_ret_sts_success ;
   l_msg_count       NUMBER;
   l_msg_data        VARCHAR2(2000);
   l_user_id NUMBER;
   l_resp_id NUMBER;
   l_resp_appl_id NUMBER;
BEGIN
    --  RUN mode  - Normal Process Execution
   IF (funcmode = 'RUN')
   THEN
      l_schedule_id  := WF_ENGINE.GetItemAttrText(
                                 itemtype   =>    itemtype,
                                 itemkey    =>     itemkey ,
                                 aname      =>    'SCHEDULE_ID' );

   l_user_id := FND_GLOBAL.USER_ID;
   l_resp_id := FND_GLOBAL.RESP_ID;
   l_resp_appl_id := FND_GLOBAL.RESP_APPL_ID;

      AMS_Utility_PVT.Create_Log (
            x_return_status   => l_return_status,
            p_arc_log_used_by => 'CSCH',
            p_log_used_by_id  => l_schedule_id,
            p_msg_data        => 'Execute_Sales : started with '||TO_CHAR(l_user_id)||' '||TO_CHAR(l_resp_id)||' '||TO_CHAR(l_resp_appl_id),
            p_msg_type        => 'DEBUG'
            );

      -- Call the api to execute the sales schedule , return the error flag in l_return_status
      --generate_leads(l_schedule_id,'CSCH',l_return_status);
      generate_leads(l_schedule_id,'CSCH',l_return_status,itemtype,itemkey);--anchaudh changed the signature of this api for the leads bug.

      AMS_Utility_PVT.Create_Log (
            x_return_status   => l_return_status,
            p_arc_log_used_by => 'CSCH',
            p_log_used_by_id  => l_schedule_id,
            p_msg_data        => 'Execute_Sales : done',
            p_msg_type        => 'DEBUG'
            );

      IF l_return_status <> FND_API.g_ret_sts_success THEN
         WF_ENGINE.SetItemAttrText(itemtype =>   itemtype,
                    itemkey  =>   itemkey,
                    aname    =>   'ERROR_FLAG',
                    avalue   =>   'Y');
         Handle_Error(p_itemtype  => itemtype,
                      p_itemkey   => itemkey,
                      p_msg_count => l_msg_count,
                      p_msg_data  => l_msg_data);
      END IF;

   END IF;
   --  CANCEL mode  - Normal Process Execution
   IF (funcmode = 'CANCEL')
   THEN
      RETURN;
   END IF;

   --  TIMEOUT mode  - Normal Process Execution
   IF (funcmode = 'TIMEOUT')
   THEN
      RETURN;
   END IF;
   -- dbms_output.put_line('End Check Trigger stat :'||result);
EXCEPTION
   WHEN OTHERS THEN
      wf_core.context(G_PKG_NAME,'Execute_Sales',itemtype,itemkey,actid,funcmode);
      RAISE ;
END Execute_Sales;


--=====================================================================
-- PROCEDURE
--    generate_leads
--
-- PURPOSE
--    This api will be used by schedule execution workflow generate leads.
--
-- HISTORY
--    08-Sep-2003  asaha       Created.
--    09-dec-2005  soagrawa    Added limited size batch processing for perf bug 4461415
--=====================================================================
PROCEDURE generate_leads(
   p_obj_id  IN NUMBER,
   p_obj_type  IN VARCHAR2,
   x_return_status OUT NOCOPY VARCHAR2,
   itemtype     IN     VARCHAR2,--anchaudh changed the signature of this api for the leads bug.
   itemkey      IN     VARCHAR2--anchaudh changed the signature of this api for the leads bug.
) IS

l_msg_count             NUMBER;
l_msg_data              VARCHAR2(4000);
l_triggerable_flag      VARCHAR2(1);
l_trig_repeat_flag      VARCHAR2(1);
l_orig_csch_id          NUMBER;
l_csch_offer_id         NUMBER := null;

cursor c_party_relationships_csr(p_party_id NUMBER) is
  select subject_id, object_id
  from hz_relationships
  where party_id = p_party_id;

-- anchaudh 17th Mar'05 : modified the cursor to pull up only purchasable products for bug#3607972.
cursor c_assoc_products_csr(p_schedule_id NUMBER) is
  select inventory_item_id, ams_act_products.category_id, organization_id
  from ams_act_products,ENI_PROD_DEN_HRCHY_PARENTS_V cat
  where arc_act_product_used_by = 'CSCH'
  and act_product_used_by_id = p_schedule_id
   and ams_act_products.category_id = cat.category_id(+)
  and nvl(cat.PURCHASE_INTEREST, 'Y') <> 'N';

cursor c_schedule_details_csr(p_schedule_id NUMBER) is
  select a.source_code, a.sales_methodology_id, b.source_code_id
  from ams_campaign_schedules_b a, ams_source_codes b
  where a.schedule_id = p_schedule_id
  and a.status_code = 'ACTIVE'
  and a.source_code = b.source_code;

CURSOR c_sch_det(p_schedule_id NUMBER) IS -- anchaudh added this new cursor for the leads bug.
   SELECT NVL(triggerable_flag,'N')
         ,NVL(trig_repeat_flag,'N')
    ,orig_csch_id
   FROM   ams_campaign_schedules_b
   WHERE  schedule_id = p_schedule_id;

CURSOR c_sch_det_offer(p_schedule_id NUMBER) IS -- anchaudh added this for bug#4957178.
   select offer_id
   from
   OZF_ACT_OFFERS ACT_OFFER,
   ozf_offers off
   where
   ACT_OFFER.ARC_ACT_OFFER_USED_BY = 'CSCH'
   AND   ACT_OFFER.act_offer_used_by_id = p_schedule_id
   AND   off.qp_list_header_id = ACT_OFFER.qp_list_header_id
   AND   ACT_OFFER.PRIMARY_OFFER_FLAG = 'Y';

   -- soagrawa 09-dec-2005 added this cursor for bug 4461415
cursor c_parties(p_obj_id NUMBER) is
   select decode(pa.party_type,'PARTY_RELATIONSHIP','ORGANIZATION','PERSON') party_type,
   decode(pa.party_type,'PARTY_RELATIONSHIP',rel.subject_id,null) contact_party_id,
   decode(pa.party_type,'PARTY_RELATIONSHIP',TO_NUMBER(le.col147),le.party_id) main_party_id,
   decode(pa.party_type,'PARTY_RELATIONSHIP',le.party_id,null) rel_party_id
   from ams_act_lists la, ams_list_entries le, hz_parties pa, hz_relationships rel
   where la.list_header_id = le.list_header_id
   and la.list_act_type = 'TARGET'
   and la.list_used_by = 'CSCH'
   and la.list_used_by_id = p_obj_id
   and le.enabled_flag = 'Y'
   and le.party_id = pa.party_id
   and pa.party_id = rel.party_id(+)
   and rel.subject_type(+) = 'PERSON';

-- soagrawa 09-dec-2005 added this cursor for bug 4461415
cursor c_lead_headers(srccd VARCHAR2) is
   SELECT IMPORT_INTERFACE_ID
   FROM as_import_interface
   where promotion_code = srccd;


CURSOR c_batch_id IS
SELECT as_sl_imp_batch_s.NEXTVAL
FROM DUAL;

CURSOR c_lead_header_id_csr IS
      SELECT AS_IMPORT_INTERFACE_S.NEXTVAL
      FROM dual;

CURSOR c_lead_header_id_exists_csr (l_id IN NUMBER) IS
      SELECT 1 FROM dual
      WHERE EXISTS (SELECT 1 FROM as_import_interface
                    WHERE import_interface_id = l_id);

CURSOR c_lead_line_id_csr IS
      SELECT AS_IMP_LINES_INTERFACE_S.NEXTVAL
      FROM dual;

CURSOR c_lead_line_id_exists_csr (l_id IN NUMBER) IS
      SELECT 1 FROM dual
      WHERE EXISTS (SELECT 1 FROM as_imp_lines_interface
                    WHERE imp_lines_interface_id = l_id);

CURSOR c_loaded_rows_for_lead (batch_id_in IN NUMBER) IS
   SELECT COUNT(*)
   FROM as_import_interface
   WHERE batch_id = batch_id_in;

l_assoc_product_row c_assoc_products_csr%ROWTYPE;
l_schedule_details c_schedule_details_csr%ROWTYPE;
l_contact_party_details c_party_relationships_csr%ROWTYPE;

TYPE Lead_Header_Id_Table IS TABLE OF as_import_interface.IMPORT_INTERFACE_ID%TYPE;
l_lead_header_ids Lead_Header_Id_Table;  -- no need to initialize

TYPE Main_Party_Id_Table IS TABLE OF hz_parties.PARTY_ID%TYPE;
l_main_party_ids Main_Party_Id_Table;  -- no need to initialize

TYPE Contact_Point_Party_Id_Table IS TABLE OF hz_parties.PARTY_ID%TYPE;
l_contact_point_party_ids Contact_Point_Party_Id_Table;  -- no need to initialize

TYPE Rel_Party_Id_Table IS TABLE OF hz_parties.PARTY_ID%TYPE;
l_rel_party_ids Rel_Party_Id_Table;  -- no need to initialize

TYPE Party_Type_Table IS TABLE OF hz_parties.PARTY_TYPE%TYPE;
l_party_types Party_Type_Table;  -- no need to initialize

l_return_status VARCHAR2(1);
l_party_id NUMBER;
l_org_id VARCHAR2(500);
l_asn_group_id VARCHAR2(500);
l_num_asn_group_id NUMBER;
l_num_asn_resource_id NUMBER;
l_asn_resource_id NUMBER;
l_contact_id NUMBER;
l_rel_party_id NUMBER;
l_party_type VARCHAR2(30);
l_no_of_prods NUMBER := 0;
l_batch_id NUMBER;
l_loaded_rows NUMBER;
l_no_of_tgrp_entries NUMBER := 0;
l_method_id NUMBER;
l_request_id NUMBER;
j NUMBER;

l_lead_header_id NUMBER;
l_lead_line_id NUMBER;
l_dummy NUMBER;

   -- soagrawa 09-dec-2005 added this variable for bug 4461415
l_batch_size NUMBER := 1000;

BEGIN
  x_return_status := FND_API.g_ret_sts_success;

   IF (AMS_DEBUG_HIGH_ON) THEN
     AMS_Utility_PVT.debug_message('generate_leads: Enter');
   END IF;

   IF(p_obj_type <> 'CSCH') THEN

     IF (AMS_DEBUG_HIGH_ON) THEN
       AMS_UTILITY_Pvt.debug_message('generate_leads: Unsupported object type : '||p_obj_type);
     END IF;

     x_return_status := FND_API.g_ret_sts_error;
     return;
   END IF;

   AMS_Utility_PVT.Create_Log (
                  x_return_status   => l_return_status,
                  p_arc_log_used_by => 'CSCH',
                  p_log_used_by_id  => p_obj_id,
                  p_msg_data        => 'Starting lead generation process schedule id is ' || to_char(p_obj_id),
                  p_msg_type        => 'DEBUG'
                 );

   OPEN c_sch_det_offer(p_obj_id);
   FETCH c_sch_det_offer INTO l_csch_offer_id;
   CLOSE c_sch_det_offer;


   OPEN  c_sch_det(p_obj_id); -- anchaudh added for the leads bug.
   FETCH c_sch_det INTO l_triggerable_flag,l_trig_repeat_flag,l_orig_csch_id;
   CLOSE c_sch_det;

   if(l_triggerable_flag = 'N' and l_trig_repeat_flag = 'N' and l_orig_csch_id IS NULL) then -- anchaudh added for the leads bug.

   l_asn_group_id := WF_ENGINE.GetItemAttrText(
                  itemtype    =>     itemtype,
                  itemkey     =>     itemkey ,
                  aname       =>    'ASN_GROUP_ID');--anchaudh added for the leads bug.

   --insert_log_mesg('Anirban inside generate_leads api, value of l_asn_group_id retrieved is :'||l_asn_group_id);

   l_asn_resource_id := WF_ENGINE.GetItemAttrText(
                  itemtype    =>     itemtype,
                  itemkey     =>     itemkey ,
                  aname       =>    'ASN_RESOURCE_ID');--anchaudh added for the leads bug.
   --insert_log_mesg('Anirban inside generate_leads api, value of l_asn_resource_id retrieved is :'||l_asn_resource_id);

   end if;

   OPEN c_schedule_details_csr(p_obj_id);
   FETCH  c_schedule_details_csr INTO l_schedule_details;
   IF(c_schedule_details_csr%NOTFOUND) THEN
     IF (AMS_DEBUG_HIGH_ON) THEN
       AMS_UTILITY_Pvt.debug_message('generate_leads: No Schedule details found for '||TO_CHAR(p_obj_id));
     END IF;
     CLOSE  c_schedule_details_csr;
     x_return_status := FND_API.g_ret_sts_error;
     return;
   END IF;
   CLOSE  c_schedule_details_csr;

   OPEN c_batch_id;
   FETCH c_batch_id INTO l_batch_id;
   CLOSE c_batch_id;
   IF (AMS_DEBUG_HIGH_ON) THEN
     AMS_UTILITY_Pvt.debug_message('generate_leads: generated batch id: '||TO_CHAR(l_batch_id));
   END IF;

   -- bulk collect party related info
   -- soagrawa 09-dec-2005 added LIMIT on this bulk collect bug 4461415 and moved it to a cursor

   open c_parties(p_obj_id);

   loop
     fetch c_parties
     BULK COLLECT INTO l_party_types, l_contact_point_party_ids, l_main_party_ids, l_rel_party_ids
     LIMIT l_batch_size;

   AMS_Utility_PVT.Create_Log (
                  x_return_status   => l_return_status,
                  p_arc_log_used_by => 'CSCH',
                  p_log_used_by_id  => p_obj_id,
                  p_msg_data        => 'Lead interface processing ' || l_main_party_ids.count,
                  p_msg_type        => 'DEBUG'
                 );

      --now generate lead headers for all parties by bulk insert
      FORALL j IN l_main_party_ids.FIRST..l_main_party_ids.LAST
          -- insert in as_import_interface based on target group entry details
          INSERT INTO as_import_interface
          (
             IMPORT_INTERFACE_ID              --NOT NULL NUMBER
            , LAST_UPDATE_DATE                --NOT NULL DATE
            , LAST_UPDATED_BY                 --NOT NULL NUMBER
            , CREATION_DATE                   --NOT NULL DATE
            , CREATED_BY                      --NOT NULL NUMBER
            , LAST_UPDATE_LOGIN               --NOT NULL NUMBER
            , LOAD_TYPE                       --         VARCHAR2(20)
            , LOAD_DATE                       --NOT NULL DATE
            , PROMOTION_CODE                  --         VARCHAR2(50)
            , STATUS_CODE                     --         VARCHAR2(30)
            , SOURCE_SYSTEM                   --         VARCHAR2(30)
            , PARTY_TYPE                      --         VARCHAR2(30)
            , BATCH_ID                        --         NUMBER(15)
            , PARTY_ID                        --         NUMBER(15)
            , PARTY_SITE_ID                   --         NUMBER(15)
            ,load_status                      --         VARCHAR2(20)
            ,contact_party_id                 --         NUMBER
            ,vehicle_response_code
            ,qualified_flag
            ,sales_methodology_id           --         NUMBER
            ,rel_party_id
       ,offer_id                       --anchaudh added for bug#4957178
          )
          VALUES
          (
            AS_IMPORT_INTERFACE_S.NEXTVAL                                --IMPORT_INTERFACE_ID   --NOT NULL NUMBER
            , SYSDATE                                       --LAST_UPDATE_DATE      --NOT NULL DATE
            , FND_GLOBAL.user_id                            --LAST_UPDATED_BY       --NOT NULL NUMBER
            , SYSDATE                                       --CREATION_DATE         --NOT NULL DATE
            , FND_GLOBAL.user_id                            --CREATED_BY            --NOT NULL NUMBER
            , FND_GLOBAL.conc_login_id                      --LAST_UPDATE_LOGIN     --NOT NULL NUMBER
            , 'LEAD_LOAD'                                   --LOAD_TYPE             --         VARCHAR2(20)
            , SYSDATE                                       --LOAD_DATE             --NOT NULL DATE
            , l_schedule_details.source_code                --PROMOTION_CODE        --         VARCHAR2(50)
            , null                                          --STATUS_CODE           --         VARCHAR2(30)
            , 'SALES_CAMPAIGN'                              --SOURCE_SYSTEM         --         VARCHAR2(30)
            , l_party_types(j)                               --PARTY_TYPE            --         VARCHAR2(30)
            , l_batch_id                                     --BATCH_ID              --         NUMBER(15)
            , l_main_party_ids(j)                            --PARTY_ID              --         NUMBER(15)
            , NULL                                           --PARTY_SITE_ID         --         NUMBER(15)
            ,'NEW'                                           -- load_status --      VARCHAR2(20)
            , l_contact_point_party_ids(j)                   -- contact party id, subject id for relationship -- NUMBER
            , 'SALES'
            , 'Y'
            ,l_schedule_details.sales_methodology_id         -- sales methodology id NUMBER
            ,l_rel_party_ids(j)                              -- relationship party id
       ,l_csch_offer_id                                 -- primary offer id --anchaudh added for bug#4957178
          );

          exit when c_parties%notfound;

   end loop;

   close c_parties;

   IF (AMS_DEBUG_HIGH_ON) THEN
     AMS_Utility_PVT.debug_message('generate_leads: insertion done in lead interface tables');
   END IF;






   -- bulk collect lead header ids for lead lines
   -- soagrawa 09-dec-2005 added LIMIT on this bulk collect bug 4461415 and moved it to a cursor

   OPEN c_lead_headers(l_schedule_details.source_code);

   LOOP
      FETCH c_lead_headers
      BULK COLLECT INTO l_lead_header_ids
      LIMIT l_batch_size;

      --open products cursor and collects associated product info
      l_no_of_prods := 0;
      OPEN c_assoc_products_csr(p_obj_id);
      LOOP
        FETCH c_assoc_products_csr INTO l_assoc_product_row;
        EXIT WHEN c_assoc_products_csr%NOTFOUND;

        l_no_of_prods := l_no_of_prods+1;

        FORALL j IN l_lead_header_ids.FIRST..l_lead_header_ids.LAST
          --bulk insert each Product/Product Category in as_imp_lines_interface table
          INSERT INTO as_imp_lines_interface
          (
           IMP_LINES_INTERFACE_ID              --NOT NULL NUMBER
          , IMPORT_INTERFACE_ID              --NOT NULL NUMBER
          , LAST_UPDATE_DATE                --NOT NULL DATE
          , LAST_UPDATED_BY                 --NOT NULL NUMBER
          , CREATION_DATE                   --NOT NULL DATE
          , CREATED_BY                      --NOT NULL NUMBER
          , LAST_UPDATE_LOGIN               --NOT NULL NUMBER
          , CATEGORY_ID                --NOT NULL NUMBER
          , INVENTORY_ITEM_ID               --NUMBER
          , ORGANIZATION_ID                 --NUMBER
          , SOURCE_PROMOTION_ID                  --NUMBER
          )
          VALUES
          (
            AS_IMP_LINES_INTERFACE_S.NEXTVAL              --IMP_LINES_INTERFACE_ID   --NOT NULL NUMBER
            , l_lead_header_ids(j)                        --IMPORT_INTERFACE_ID   --NOT NULL NUMBER
            , SYSDATE                                       --LAST_UPDATE_DATE      --NOT NULL DATE
            , FND_GLOBAL.user_id                            --LAST_UPDATED_BY       --NOT NULL NUMBER
            , SYSDATE                                       --CREATION_DATE         --NOT NULL DATE
            , FND_GLOBAL.user_id                            --CREATED_BY            --NOT NULL NUMBER
            , FND_GLOBAL.conc_login_id                      --LAST_UPDATE_LOGIN     --NOT NULL NUMBER
            ,l_assoc_product_row.category_id
            ,l_assoc_product_row.inventory_item_id
            ,l_assoc_product_row.organization_id
            ,l_schedule_details.source_code_id
          );

      END LOOP;   -- for products
      CLOSE c_assoc_products_csr;

      exit when c_lead_headers%notfound;

   end loop;

   close c_lead_headers;



   IF (AMS_DEBUG_HIGH_ON) THEN
     AMS_UTILITY_Pvt.debug_message('generate_leads: No. of Products/Categories : '||TO_CHAR(l_no_of_prods));
   END IF;

   -- At this point we will have added all the records in as_import_interface table.
   -- Now we can call the concurrent program for lead process.
   OPEN c_loaded_rows_for_lead(l_batch_id);
   FETCH c_loaded_rows_for_lead INTO l_loaded_rows;
   CLOSE c_loaded_rows_for_lead;

   IF (AMS_DEBUG_HIGH_ON) THEN
     AMS_Utility_PVT.debug_message('generate_leads: No of lead header rows created : '||TO_CHAR(l_loaded_rows));
   END IF;

   AMS_Utility_PVT.Create_Log (
                  x_return_status   => l_return_status,
                  p_arc_log_used_by => 'CSCH',
                  p_log_used_by_id  => p_obj_id,
                  p_msg_data        => 'No. of lead headers generated '||TO_CHAR(l_loaded_rows),
                  p_msg_type        => 'DEBUG'
                 );

   l_request_id := 0;

   if(l_triggerable_flag = 'N' and l_trig_repeat_flag = 'N' and l_orig_csch_id IS NULL) then -- anchaudh added for the leads bug.
      l_num_asn_resource_id := to_number(l_asn_resource_id);
      if(l_asn_group_id = '9999') then
        l_num_asn_group_id := null;
      else
        l_num_asn_group_id := to_number(l_asn_group_id);
      end if;
   else
      l_num_asn_group_id := null;
      l_num_asn_resource_id := null;
   end if;

   --insert_log_mesg('Anirban just before calling conc. program , values of :l_num_asn_resource_id and l_num_asn_group_id are :'||l_num_asn_resource_id || ' '||l_num_asn_group_id);

   -- Call the concurrent program for leads.
   l_request_id := FND_REQUEST.SUBMIT_REQUEST (
                   application       => 'AS',
                   program           => 'ASXSLIMP',
                   argument1         => 'SALES_CAMPAIGN',
         argument2         => 'N',
                   --argument2       => NULL,
         argument3         => l_batch_id,
         argument4         => 'N',
                   argument5         => null,
                   argument6         => null,
         argument7         => l_num_asn_resource_id,--anchaudh added for the leads bug.
                   argument8         => l_num_asn_group_id--anchaudh added for the leads bug.
                  );

   --insert_log_mesg('Anirban inside generate_leads api, value of l_batch_id and l_request_id after submitting Conc. request is :'||l_batch_id || '  '||l_request_id);

   AMS_Utility_PVT.Create_Log (
                  x_return_status   => l_return_status,
                  p_arc_log_used_by => 'CSCH',
                  p_log_used_by_id  => p_obj_id,
                  p_msg_data        => 'Starting LEAD program (ASXSLIMP) -- concurrent program_id is ' || to_char(l_request_id) ||' for batch id '||TO_CHAR(l_batch_id),
                  p_msg_type        => 'DEBUG'
                 );

   IF l_request_id = 0 THEN
      l_msg_data := fnd_message.get;
      AMS_Utility_PVT.Create_Log (
                  x_return_status   => l_return_status,
                  p_arc_log_used_by => 'CSCH',
                  p_log_used_by_id  => p_obj_id,
                  p_msg_data        => l_msg_data,
                  p_msg_type        => 'DEBUG'
                 );
       x_return_status := FND_API.g_ret_sts_error;
       --insert_log_mesg('Anirban inside generate_leads api,ERROR occured in the conc. program. ');
       return;
   END IF;

   -- Import completed successfully
   IF (AMS_DEBUG_HIGH_ON) THEN
     AMS_Utility_PVT.debug_message('generate_leads: Submitted Lead import request with request id : '||TO_CHAR(l_request_id));
     AMS_Utility_PVT.debug_message('generate_leads: End');
   END IF;

END generate_leads;






--=====================================================================
-- PROCEDURE
--    Check_WF_Error
--
-- PURPOSE
--    This api will be used by schedule execution workflow to check error
--    The api will check the error flag and based on the value, the error
--    notifications will be sent to schedule owner.
--
-- HISTORY
--    23-Aug-2003  ptendulk       Created.
--    19-Sep-2003  dbiswas        Added nocopy
--=====================================================================
PROCEDURE Check_WF_Error(itemtype    IN     VARCHAR2,
                         itemkey     IN     VARCHAR2,
                         actid       IN     NUMBER,
                         funcmode    IN     VARCHAR2,
                         result      OUT NOCOPY    VARCHAR2) IS
    l_error_flag        VARCHAR2(30) ;
    l_return_status     VARCHAR2(1);
    l_schedule_id       NUMBER;
BEGIN
-- dbms_output.put_line('Process Check_Repeat');
   --  RUN mode  - Normal Process Execution
   IF (funcmode = 'RUN')
   THEN
      l_schedule_id  := WF_ENGINE.GetItemAttrText(
                                 itemtype    =>    itemtype,
                                 itemkey      =>     itemkey ,
                                 aname      =>    'SCHEDULE_ID' );

      AMS_Utility_PVT.Create_Log (
            x_return_status   => l_return_status,
            p_arc_log_used_by => 'CSCH',
            p_log_used_by_id  => l_schedule_id,
            p_msg_data        => 'Check_WF_Error : started',
            p_msg_type        => 'DEBUG'
            );

      l_error_flag  := WF_ENGINE.GetItemAttrText(
                               itemtype   =>    itemtype,
                               itemkey    =>    itemkey ,
                               aname      =>    'ERROR_FLAG' );


      IF   l_error_flag  = 'N' THEN
         result := 'COMPLETE:N' ;
      ELSE
         result := 'COMPLETE:Y' ;
      END IF ;
   END IF;

   --  CANCEL mode  - Normal Process Execution
   IF (funcmode = 'CANCEL')
   THEN
      result := 'COMPLETE:Y' ;
     RETURN;
   END IF;

   --  TIMEOUT mode  - Normal Process Execution
   IF (funcmode = 'TIMEOUT')
   THEN
      result := 'COMPLETE:Y' ;
     RETURN;
   END IF;
EXCEPTION
    WHEN OTHERS THEN
         wf_core.context(G_PKG_NAME,'Check_WF_Error',itemtype,itemkey,actid,funcmode);
        raise ;
END Check_WF_Error ;

--========================================================================
-- PROCEDURE
--    WRITE_LOG
-- Purpose
--   This method will be used to write logs for this api
-- HISTORY
--    10-Oct-2000   dbiswas    Created.
--
--========================================================================

PROCEDURE WRITE_LOG             ( p_api_name      IN VARCHAR2 := NULL,
                                  p_log_message   IN VARCHAR2  := NULL)
IS
   l_api_name   VARCHAR2(30);
   l_log_mesg   VARCHAR2(2000);
   l_return_status VARCHAR2(1);
BEGIN
      l_api_name := p_api_name;
      l_log_mesg := p_log_message;
      AMS_Utility_PVT.debug_message (
                        p_log_level   => g_log_level,
                        p_module_name => 'ams.plsql.'||'.'|| g_pkg_name||'.'||l_api_name||'.'||l_log_mesg,
                        p_text => p_log_message
                       );

   AMS_Utility_PVT.Create_Log (
                     x_return_status   => l_return_status,
                     p_arc_log_used_by => 'CSCH',
                     p_log_used_by_id  => 1,
                     p_msg_data        => p_log_message,
                     p_msg_type        => 'DEBUG'
                     );

 END WRITE_LOG;

--=====================================================================
-- Procedure
--    WF_REPEAT_INIT_VAR
--
-- PURPOSE
--    This api is used by scheduler workflow to initialize the attributes
--    Returns the processId information in the schedules table
--
-- HISTORY
--    07-Oct-2003  dbiswas       Created.
--    09-nov-2004  anchaudh      Now setting item owner along with bug fix for bug# 3799053
--=====================================================================
PROCEDURE Wf_Repeat_Init_var(itemtype    IN     VARCHAR2,
                                   itemkey     IN     VARCHAR2,
                                   actid       IN     NUMBER,
                                   funcmode    IN     VARCHAR2,
                                   result      OUT NOCOPY   VARCHAR2) IS

   CURSOR c_sched_dat (p_schedule_id IN NUMBER) IS
   SELECT csch.schedule_name,
          csch.start_date_time,
          csch.end_date_time,
          csch.status_code,
          csch.owner_user_id,
          csch.activity_id,
          csch.activity_type_code,
          nvl(csch.orig_csch_id, csch.schedule_id),
          scheduler.frequency,
          scheduler.frequency_type,
          camp.actual_exec_start_date,
          camp.actual_exec_end_date,
          parentCSCH.start_date_time,
          parentCSCH.end_date_time,
          parentCSCH.status_code
     FROM ams_campaign_schedules_vl csch,
          ams_scheduler scheduler,
          ams_campaigns_all_b camp,
          ams_campaign_Schedules_b parentCSCH
    WHERE csch.schedule_id = p_schedule_id
      AND scheduler.OBJECT_ID = nvl(csch.orig_csch_id, csch.schedule_id)
      AND scheduler.OBJECT_TYPE = 'CSCH'
      AND camp.campaign_id = csch.campaign_id
      and parentCSCH.schedule_id = nvl(csch.orig_Csch_id,csch.schedule_id);

   CURSOR c_emp_dtl(l_res_id IN NUMBER) IS
   SELECT employee_id
     FROM ams_jtf_rs_emp_v
    WHERE resource_id = l_res_id ;

   l_schedule_id               NUMBER;
   l_schedule_name             VARCHAR2(240);
   l_csch_st_date              DATE;
   l_csch_en_date              DATE;
   l_csch_status               VARCHAR2(30);
   l_csch_owner                NUMBER;
   l_csch_act_id               NUMBER;
   l_csch_act_code             VARCHAR2(30);
   l_csch_orig_id              NUMBER;
   l_sched_freq                NUMBER;
   l_sched_freq_type           VARCHAR2(30);
   l_camp_st_date              DATE;
   l_camp_en_date              DATE;
   l_parent_st_date            DATE;
   l_parent_en_date            DATE;
   l_parent_status             VARCHAR2(30);
   l_api_name                  VARCHAR2(30);
   l_return_status             VARCHAR2(1);
   l_emp_id                    NUMBER;
   l_user_name                 VARCHAR2(100);
   l_display_name              VARCHAR2(100);

   l_temp_varaibale	       VARCHAR2(50);
   l_schedule_next_run_st_date     DATE;



BEGIN
   l_api_name := 'Wf_Repeat_Init_var';
   IF (funcmode = 'RUN')
   THEN

       l_schedule_id := WF_ENGINE.GetItemAttrText(
                  itemtype    =>     itemtype,
                  itemkey     =>     itemkey ,
                  aname       =>    'SCHEDULE_ID');



       l_temp_varaibale := WF_ENGINE.GetItemAttrText(itemtype  =>    itemtype,
                                   itemkey   =>    itemkey ,
                                   aname     =>    'AMS_PARENT_STATUS'
                                   );

       l_schedule_next_run_st_date := to_date(l_temp_varaibale,'DD-MM-RRRR HH24:MI:SS');

       WRITE_LOG (l_api_name, 'WF_REPEAT_INIT_VAR: SCHEDULE ID IS '||l_schedule_id
			       || '|| SCHEDULED KICKOFF TIME: '||to_char(l_schedule_next_run_st_date,'DD-MON-RRRR HH24:MI:SS')
			       || '|| CURRENT SYSTEM TIME: '||to_char(SYSDATE,'DD-MON-RRRR HH24:MI:SS'));

       WRITE_LOG(l_api_name, 'WF_REPEAT_INIT_VAR: AMS_SCHEDULE_NEXT_RUN_ST_DATE DERIVED FROM PARAMETER LIST '
			      ||'SCHEDULE ID RECEIVED IS:' || l_schedule_id
			      ||to_char(l_schedule_next_run_st_date,'DD-MON-RRRR HH24:MI:SS')
			      ||' ; '||'L_TEMP_VARAIBALE VALUE : '
			      ||l_temp_varaibale);



       WF_ENGINE.SetItemAttrNumber(itemtype    =>     itemtype,
                            itemkey     =>   itemkey,
                           aname        =>   'AMS_SCHEDULE_ID',
                           avalue       =>   l_schedule_id);

       UPDATE ams_campaign_schedules_b
       SET    REPEAT_WORKFLOW_ITEM_KEY = itemkey
       WHERE  schedule_id = l_schedule_id;

       WRITE_LOG (l_api_name, 'Wf_Repeat_Init_var: Schedule id is '||l_schedule_id);

       OPEN  c_sched_dat(l_schedule_id);
       FETCH c_sched_dat INTO l_schedule_name,
                              l_csch_st_date,
                              l_csch_en_date,
                              l_csch_status,
                              l_csch_owner,
                              l_csch_act_id,
                              l_csch_act_code,
                              l_csch_orig_id,
                              l_sched_freq,
                              l_sched_freq_type,
                              l_camp_st_date,
                              l_camp_en_date,
                              l_parent_st_date,
                              l_parent_en_date,
                              l_parent_status
                             ;
       CLOSE c_sched_dat;

      OPEN c_emp_dtl(l_csch_owner);
      FETCH c_emp_dtl INTO l_emp_id;
         -- anchaudh setting item owner along with bug fix for bug# 3799053
         IF c_emp_dtl%FOUND
         THEN
            WF_DIRECTORY.getrolename
                 ( p_orig_system      => 'PER',
                   p_orig_system_id   => l_emp_id ,
                   p_name             => l_user_name,
                   p_display_name     => l_display_name );

            IF l_user_name IS NOT NULL THEN
               Wf_Engine.SetItemOwner(itemtype    => itemtype,
                                itemkey     => itemkey,
                                owner       => l_user_name);
            END IF;
         END IF;
      CLOSE c_emp_dtl;

       WF_ENGINE.SetItemAttrText(itemtype    =>     itemtype,
                            itemkey     =>   itemkey,
                           aname    =>     'SCHEDULE_NAME',
                           avalue    =>     l_schedule_name);

       WF_ENGINE.SetItemUserkey(itemtype   =>   itemtype,
                                itemkey     =>   itemkey ,
                                userkey     =>   l_schedule_name);

       WF_ENGINE.SetItemAttrDate(itemtype    =>     itemtype,
                            itemkey     =>   itemkey,
                           aname    =>     'AMS_SCHEDULE_START_DATE',
                           avalue    =>     to_date(l_csch_st_date,'DD-MM-RRRR HH24:MI:SS')  );

       WF_ENGINE.SetItemAttrDate(itemtype    =>     itemtype,
                            itemkey     =>   itemkey,
                           aname    =>     'AMS_SCHEDULE_END_DATE',
                           avalue    =>     to_date(l_csch_en_date,'DD-MM-RRRR HH24:MI:SS')  );

       WF_ENGINE.SetItemAttrText(itemtype    =>     itemtype,
                            itemkey     =>   itemkey,
                           aname    =>     'SCHEDULE_STATUS',
                           avalue    =>     l_csch_status);

       WF_ENGINE.SetItemAttrText(itemtype    =>     itemtype,
                            itemkey     =>   itemkey,
                           aname    =>     'SCHEDULE_OWNER',
                           avalue    =>     l_user_name);

       WF_ENGINE.SetItemAttrText(itemtype    =>     itemtype,
                            itemkey     =>   itemkey,
                           aname    =>     'SCHEDULE_CHANNEL',
                           avalue    =>     l_csch_act_id);

       WF_ENGINE.SetItemAttrText(itemtype    =>     itemtype,
                            itemkey     =>   itemkey,
                           aname    =>     'ACTIVITY_TYPE',
                           avalue    =>     l_csch_act_code);

       WF_ENGINE.SetItemAttrNumber(itemtype    =>     itemtype,
                            itemkey     =>   itemkey,
                           aname    =>     'AMS_ORIG_SCHEDULE_ID',
                           avalue    =>     l_csch_orig_id);

       WF_ENGINE.SetItemAttrNumber(itemtype    =>     itemtype,
                            itemkey     =>   itemkey,
                           aname    =>     'AMS_SCHEDULER_FREQUENCY',
                           avalue    =>     l_sched_freq);

       WF_ENGINE.SetItemAttrText(itemtype    =>     itemtype,
                            itemkey     =>   itemkey,
                           aname    =>     'AMS_SCHEDULER_FREQUENCY_TYPE',
                           avalue    =>     l_sched_freq_type);

       WF_ENGINE.SetItemAttrDate(itemtype    =>     itemtype,
                            itemkey     =>   itemkey,
                           aname    =>     'AMS_CAMPAIGN_START_DATE',
                           avalue    =>     to_date(l_camp_st_date,'DD-MM-RRRR HH24:MI:SS')  );

       WF_ENGINE.SetItemAttrDate(itemtype    =>     itemtype,
                            itemkey     =>   itemkey,
                           aname    =>     'AMS_CAMPAIGN_END_DATE',
                           avalue    =>     to_date(l_camp_en_date,'DD-MM-RRRR HH24:MI:SS')  );

       WF_ENGINE.SetItemAttrDate(itemtype    =>     itemtype,
                            itemkey     =>   itemkey,
                           aname    =>     'AMS_PARENT_START_DATE',
                           avalue    =>     to_date(l_parent_st_date,'DD-MM-RRRR HH24:MI:SS')  );

       WF_ENGINE.SetItemAttrDate(itemtype    =>     itemtype,
                            itemkey     =>   itemkey,
                           aname    =>     'AMS_PARENT_END_DATE',
                           avalue    =>     to_date(l_parent_en_date,'DD-MM-RRRR HH24:MI:SS')  );

       WF_ENGINE.SetItemAttrText(itemtype    =>     itemtype,
                            itemkey     =>   itemkey,
                           aname    =>     'AMS_PARENT_STATUS',
                           avalue    =>     l_parent_status);


       WF_ENGINE.SetItemAttrDate(itemtype  =>    itemtype,
                                 itemkey   =>    itemkey ,
                                 aname     =>    'AMS_SCHEDULER_NEXT_RUN_ST_DATE',
                                 avalue     =>   l_schedule_next_run_st_date);

   END IF;

   --  CANCEL mode  - Normal Process Execution
   IF (funcmode = 'CANCEL')
   THEN
      RETURN;
   END IF;

   --  TIMEOUT mode  - Normal Process Execution
   IF (funcmode = 'TIMEOUT')
   THEN
      RETURN;
   END IF;
   -- dbms_output.put_line('End Check scheduler stat :'||result);
EXCEPTION
    WHEN OTHERS THEN
         wf_core.context(G_PKG_NAME,'Wf_Repeat_Init_var',itemtype,itemkey,actid,funcmode);
        raise ;
END Wf_Repeat_Init_var ;

--=====================================================================
-- Procedure
--    WF_REPEAT_CHECK_EXECUTE
--
-- PURPOSE
--    This api is used by scheduler workflow to check if the schedule
--    should execute or not based on status and dates
--
-- HISTORY
--    07-Oct-2003  dbiswas       Created.
--=====================================================================
PROCEDURE Wf_Repeat_Check_Execute(itemtype    IN     VARCHAR2,
                                   itemkey     IN     VARCHAR2,
                                   actid       IN     NUMBER,
                                   funcmode    IN     VARCHAR2,
                                   result      OUT NOCOPY   VARCHAR2) IS

  CURSOR c_sched_data (p_schedule_id IN NUMBER) IS
   SELECT nvl(csch.orig_csch_id, csch.schedule_id)
   FROM   ams_campaign_schedules_vl csch
   WHERE  csch.schedule_id = p_schedule_id;


  l_schedule_id         NUMBER;
  l_csch_orig_id        NUMBER;
  l_sched_end_date      DATE;
  l_sched_status        VARCHAR2(30);
  l_orig_csch_id        NUMBER;
  l_camp_end_date       DATE;
  l_orig_csch_end_date  DATE;
  l_orig_csch_status    VARCHAR2(30);
  l_api_name            VARCHAR2(30);
  l_return_status        VARCHAR2(1);

BEGIN
   l_api_name := 'WF_REPEAT_CHECK_EXECUTE';

   l_schedule_id := WF_ENGINE.GetItemAttrText(
                        itemtype    =>     itemtype,
                        itemkey     =>     itemkey ,
                        aname       =>    'SCHEDULE_ID');


    OPEN  c_sched_data(l_schedule_id);
    FETCH c_sched_data INTO l_csch_orig_id ;
    CLOSE c_sched_data;


   IF (funcmode = 'RUN')
   THEN
       WRITE_LOG(l_api_name, 'Wf_Repeat_Check_Execute: Schedule id is '||l_schedule_id);

       l_sched_status := WF_ENGINE.GetItemAttrText(
                        itemtype    =>     itemtype,
                        itemkey     =>     itemkey ,
                        aname       =>    'SCHEDULE_STATUS');

       l_sched_end_date  := WF_ENGINE.GetItemAttrDate(
                        itemtype    =>     itemtype,
                        itemkey     =>     itemkey ,
                        aname       =>    'AMS_SCHEDULE_END_DATE');

       l_orig_csch_status  := WF_ENGINE.GetItemAttrText(
                        itemtype    =>     itemtype,
                        itemkey     =>     itemkey ,
                        aname       =>    'AMS_PARENT_STATUS');

       l_orig_csch_end_date  := WF_ENGINE.GetItemAttrDate(
                        itemtype    =>     itemtype,
                        itemkey     =>     itemkey ,
                        aname       =>    'AMS_PARENT_END_DATE');


       l_camp_end_date  := WF_ENGINE.GetItemAttrDate(
                        itemtype    =>     itemtype,
                        itemkey     =>     itemkey ,
                        aname       =>    'AMS_CAMPAIGN_END_DATE');



       WRITE_LOG(l_api_name, 'Wf_Repeat_Check_Execute: Schedule id is '||l_schedule_id||
							'|| SCHEDULE_STATUS is: '||l_sched_status||
							'|| AMS_SCHEDULE_END_DATE is: '||l_sched_end_date||
							'|| AMS_PARENT_STATUS is: '||l_orig_csch_status||
							'|| AMS_PARENT_END_DATE is: '||l_orig_csch_end_date||
							'|| AMS_CAMPAIGN_END_DATE is: '||l_camp_end_date);


       if(l_csch_orig_id <> l_schedule_id) then -- ensuring that for only the child activities, the end date check is performed , and not for the parent activity. Bug#4690754 : anchaudh: 3 Nov'05.

        IF (l_sched_status = 'AVAILABLE' or l_sched_status = 'ACTIVE')
        THEN
          IF (l_orig_csch_status = 'AVAILABLE' or l_orig_csch_status = 'ACTIVE')
          THEN
             IF (nvl(l_orig_csch_end_date, l_camp_end_date) >=SYSDATE)
             THEN
                result := 'COMPLETE:Y' ;
             ELSE
                WRITE_LOG (l_api_name, 'Wf_Repeat_Check_Execute: returns out of bounds for exec date for schedule id '||l_schedule_id);
                result := 'COMPLETE:N';
             END IF;
           END IF;
        END IF;
       else -- ensuring that for only the child activities, the end date check is performed , and not for the parent activity. Bug#4690754 : anchaudh: 3 Nov'05.
        result := 'COMPLETE:Y';
       end if; -- ensuring that for only the child activities, the end date check is performed , and not for the parent activity. Bug#4690754 : anchaudh: 3 Nov'05.

   END IF; --funcmode RUN
   --  CANCEL mode  - Normal Process Execution
   IF (funcmode = 'CANCEL')
   THEN
      RETURN;
   END IF;

   --  TIMEOUT mode  - Normal Process Execution
   IF (funcmode = 'TIMEOUT')
   THEN
      RETURN;
   END IF;
   -- dbms_output.put_line('End Check scheduler stat :'||result);
EXCEPTION
    WHEN OTHERS THEN
         wf_core.context(G_PKG_NAME,'Wf_Repeat_Check_Exec',itemtype,itemkey,actid,funcmode);
        raise ;
END Wf_Repeat_Check_Execute;

--=====================================================================
-- Procedure
--    WF_REPEAT_SCHEDULER
--
-- PURPOSE
--    This api is used by scheduler workflow to check when the next schedule run should be
--
-- HISTORY
--    07-Oct-2003  dbiswas       Created.
--=====================================================================
PROCEDURE Wf_Repeat_Scheduler(itemtype    IN     VARCHAR2,
                                   itemkey     IN     VARCHAR2,
                                   actid       IN     NUMBER,
                                   funcmode    IN     VARCHAR2,
                                   result      OUT NOCOPY   VARCHAR2) IS

  l_schedule_id                      NUMBER;
  l_scheduler_frequency              NUMBER;
  l_scheduler_frequency_type   VARCHAR2(30);
  l_scheduler_next_run_date            DATE;
  l_api_name                   VARCHAR2(30);
  l_msg_count                        NUMBER;
  l_msg_data                 VARCHAR2(2000);

  l_return_status        VARCHAR2(1);

  l_new_last_run_date    DATE;
  l_orig_csch_id         NUMBER;


BEGIN
   l_api_name  := 'WF_REPEAT_SCHEDULER';
   IF (funcmode = 'RUN')
   THEN

       l_schedule_id := WF_ENGINE.GetItemAttrText(
                        itemtype    =>     itemtype,
                        itemkey     =>     itemkey ,
                        aname       =>    'SCHEDULE_ID');
       WRITE_LOG(l_api_name, 'Wf_Repeat_Scheduler: Schedule id ' ||l_schedule_id);

       l_scheduler_frequency := WF_ENGINE.GetItemAttrNumber(
                        itemtype    =>     itemtype,
                        itemkey     =>     itemkey ,
                        aname       =>    'AMS_SCHEDULER_FREQUENCY');

       l_scheduler_frequency_type := WF_ENGINE.GetItemAttrText(
                        itemtype    =>     itemtype,
                        itemkey     =>     itemkey ,
                        aname       =>    'AMS_SCHEDULER_FREQUENCY_TYPE');

       WRITE_LOG(l_api_name, 'Wf_Repeat_Scheduler: Calling AMS_SCHEDULER_PVT.Schedule_Repeat with freq type ' ||l_scheduler_frequency_type);


       l_new_last_run_date := WF_ENGINE.GetItemAttrDate(
					itemtype    =>     itemtype,
					itemkey     =>     itemkey ,
					aname       =>    'AMS_SCHEDULER_NEXT_RUN_ST_DATE');



      SELECT nvl(orig_csch_id, schedule_id)
      INTO l_orig_csch_id
      FROM ams_campaign_schedules_b
      WHERE schedule_id = l_schedule_id;

      IF l_new_last_run_date IS NULL then

		l_new_last_run_date := SYSDATE;
      ELSIF l_new_last_run_date = '' then
		l_new_last_run_date := SYSDATE;
      END IF;



       WRITE_LOG(l_api_name, 'Wf_Repeat_Scheduler: Schedule_Repeat returned last run date from the WF Engine : '||to_char(l_new_last_run_date,'DD-MON-RRRR HH24:MI:SS')||';  For Schedule Id: '||l_schedule_id);


       WRITE_LOG(l_api_name, 'Wf_Repeat_Scheduler: Calling AMS_SCHEDULER_PVT.Schedule_Repeat with freq type ' ||l_scheduler_frequency_type||';  For Schedule Id: '||l_schedule_id);


       AMS_SCHEDULER_PVT.Schedule_Repeat (
                                        p_last_run_date     => l_new_last_run_date,
                                        p_frequency         => l_scheduler_frequency,
                                        p_frequency_type    => l_scheduler_frequency_type,
                                        x_next_run_date     => l_scheduler_next_run_date,
                                        x_return_status     => l_return_status,
                                        x_msg_count         => l_msg_count,
                                        x_msg_data          => l_msg_data);


       IF l_return_status = FND_API.G_RET_STS_SUCCESS
       THEN
           WRITE_LOG(l_api_name, 'Wf_Repeat_Scheduler: Schedule_Repeat returned success for next run date for schedule id: '||l_schedule_id);
           WRITE_LOG(l_api_name, 'Wf_Repeat_Scheduler: Schedule_Repeat returned next run date is : '||to_char(l_scheduler_next_run_date,'DD-MON-RRRR HH24:MI:SS')||' Schedule Id is : '||l_schedule_id);

           WF_ENGINE.SetItemAttrDate(itemtype  =>    itemtype,
                                     itemkey   =>     itemkey ,
                                     aname      =>    'AMS_SCHEDULER_NEXT_RUN_ST_DATE',
                                     avalue      =>   l_scheduler_next_run_date);

           result := 'COMPLETE:SUCCESS' ;
       ELSIF l_return_status <> FND_API.G_RET_STS_SUCCESS
        THEN
           WF_ENGINE.SetItemAttrText(itemtype =>   itemtype,
                             itemkey  =>   itemkey,
                             aname    =>   'ERROR_FLAG',
                             avalue   =>   'Y');
           Handle_Error(p_itemtype  => itemtype,
                        p_itemkey   => itemkey,
                        p_msg_count => l_msg_count,
                        p_msg_data  => l_msg_data,
                        p_wf_err_attrib => 'AMS_SCHEDULER_ERROR_MSG');

           WRITE_LOG(l_api_name, 'Error in scheduling next run start date caught for schedule id: '||l_schedule_id);
           result := 'COMPLETE:ERROR' ;

       END IF ;
    END IF;

    IF (funcmode = 'CANCEL')
    THEN
       result := 'COMPLETE:' ;
      RETURN;
    END IF;

    IF (funcmode = 'TIMEOUT')
    THEN
       result := 'COMPLETE:' ;
      RETURN;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
         wf_core.context(G_PKG_NAME,l_api_name,itemtype,itemkey,actid,funcmode);
        raise ;

  END Wf_Repeat_Scheduler ;

--=====================================================================
-- Procedure
--    WF_REPEAT_CHECK_CREATE_CSCH
--
-- PURPOSE
--    This api is used by scheduler workflow to check whether to create the next child schedule
--    based on schedule date boundaries. (campaign end date in case parent's end date is null
--
-- HISTORY
--    07-Oct-2003  dbiswas       Created.
--=====================================================================
PROCEDURE WF_REPEAT_CHECK_CREATE_CSCH(itemtype    IN     VARCHAR2,
                                   itemkey     IN     VARCHAR2,
                                   actid       IN     NUMBER,
                                   funcmode    IN     VARCHAR2,
                                   result      OUT NOCOPY   VARCHAR2) IS

  l_schedule_id              NUMBER;
  l_schedule_next_run_date     DATE;
  l_parent_end_date            DATE;
  l_campaign_end_date          DATE;
  l_api_name           VARCHAR2(30);

  l_return_status        VARCHAR2(1);
BEGIN
  l_api_name    := 'WF_REPEAT_CHECK_CREATE_CSCH';
   IF (funcmode = 'RUN')
   THEN

       l_schedule_id := WF_ENGINE.GetItemAttrText(
                        itemtype    =>     itemtype,
                        itemkey     =>     itemkey ,
                        aname       =>    'SCHEDULE_ID');
       WRITE_LOG(l_api_name, 'WF_REPEAT_CHECK_CREATE_CSCH: Started for schedule id ' ||l_schedule_id);

       l_schedule_next_run_date := WF_ENGINE.GetItemAttrDate(
                        itemtype    =>     itemtype,
                        itemkey     =>     itemkey ,
                        aname       =>    'AMS_SCHEDULER_NEXT_RUN_ST_DATE');

       l_parent_end_date := WF_ENGINE.GetItemAttrDate(
                        itemtype    =>     itemtype,
                        itemkey     =>     itemkey ,
                        aname       =>    'AMS_PARENT_END_DATE');

       l_campaign_end_date := WF_ENGINE.GetItemAttrDate(
                        itemtype    =>     itemtype,
                        itemkey     =>     itemkey ,
                        aname       =>    'AMS_CAMPAIGN_END_DATE');

       IF (nvl(l_parent_end_date, l_campaign_end_date) > l_schedule_next_run_date)
       THEN
          result := 'COMPLETE:Y' ;
       ELSE
          result := 'COMPLETE:N' ;
       END IF ;

   END IF ; -- end func mode

    IF (funcmode = 'CANCEL')
    THEN
       result := 'COMPLETE:' ;
      RETURN;
    END IF;

    IF (funcmode = 'TIMEOUT')
    THEN
       result := 'COMPLETE:' ;
      RETURN;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
         wf_core.context(G_PKG_NAME,l_api_name,itemtype,itemkey,actid,funcmode);
        raise ;

  END WF_REPEAT_CHECK_CREATE_CSCH ;

--=====================================================================
-- Procedure
--    WF_REPEAT_CREATE_CSCH
--
-- PURPOSE
--    This api is used by scheduler workflow to create the next child schedule
--
-- HISTORY
--    11-Oct-2003  dbiswas       Created.
--=====================================================================
PROCEDURE WF_REPEAT_CREATE_CSCH(itemtype    IN     VARCHAR2,
                                   itemkey     IN     VARCHAR2,
                                   actid       IN     NUMBER,
                                   funcmode    IN     VARCHAR2,
                                   result      OUT NOCOPY   VARCHAR2) IS

  l_schedule_id                      NUMBER;
  l_schedule_start_date                DATE;
  l_schedule_end_date                  DATE;
  l_scheduler_frequency              NUMBER;
  l_scheduler_frequency_type   VARCHAR2(30);
  l_parent_sched_id                  NUMBER;
  l_parent_end_date                    DATE;
  l_campaign_end_date                  DATE;
  l_api_name                   VARCHAR2(30);
  l_msg_count                        NUMBER;
  l_msg_data                 VARCHAR2(2000);
  l_return_status               VARCHAR2(1);
  l_usr_start_time                     DATE;
  l_start_time                         DATE;
  l_timezone                         NUMBER;
  l_child_sched_id                   NUMBER;

--  CURSOR c_sch_det (p_schedule_id NUMBER) IS
--  SELECT start_date_time, timezone_id
--  FROM   ams_campaign_schedules_b
--  WHERE  schedule_id = p_schedule_id;

BEGIN
   l_api_name    := 'WF_REPEAT_CREATE_CSCH';
   l_schedule_id := WF_ENGINE.GetItemAttrText(
                        itemtype    =>     itemtype,
                        itemkey     =>     itemkey ,
                        aname       =>    'SCHEDULE_ID');

   IF (funcmode = 'RUN')
   THEN
       WRITE_LOG(l_api_name, 'WF_REPEAT_CREATE_CSCH: Schedule id is '||l_schedule_id);

       l_parent_sched_id := WF_ENGINE.GetItemAttrNumber(
                        itemtype    =>     itemtype,
                        itemkey     =>     itemkey ,
                        aname       =>    'AMS_ORIG_SCHEDULE_ID');

       l_campaign_end_date := WF_ENGINE.GetItemAttrDate(
                        itemtype    =>     itemtype,
                        itemkey     =>     itemkey ,
                        aname       =>    'AMS_CAMPAIGN_END_DATE');

       l_parent_end_date := WF_ENGINE.GetItemAttrDate(
                        itemtype    =>     itemtype,
                        itemkey     =>     itemkey ,
                        aname       =>    'AMS_PARENT_END_DATE');

       l_schedule_start_date := WF_ENGINE.GetItemAttrDate(
                        itemtype    =>     itemtype,
                        itemkey     =>     itemkey ,
                        aname       =>    'AMS_SCHEDULER_NEXT_RUN_ST_DATE');

       l_scheduler_frequency := WF_ENGINE.GetItemAttrNumber(
                        itemtype    =>     itemtype,
                        itemkey     =>     itemkey ,
                        aname       =>    'AMS_SCHEDULER_FREQUENCY');

       l_scheduler_frequency_type := WF_ENGINE.GetItemAttrText(
                        itemtype    =>     itemtype,
                        itemkey     =>     itemkey ,
                        aname       =>    'AMS_SCHEDULER_FREQUENCY_TYPE');

        --anchaudh: commented out on 11 Jun '05 to fix bug#4477717 .
       /*AMS_UTILITY_PVT.Convert_Timezone(
             p_init_msg_list   => FND_API.G_TRUE,
             x_return_status   => l_return_status,
             x_msg_count       => l_msg_count,
             x_msg_data        => l_msg_data,
             p_user_tz_id      => l_timezone,
             p_in_time         => l_schedule_start_date,
             p_convert_type    => 'USER',
            x_out_time         => l_usr_start_time
         );

         AMS_SCHEDULER_PVT.Schedule_Repeat(
                                        p_last_run_date     => l_usr_start_time,
                                        p_frequency         => l_scheduler_frequency,
                                        p_frequency_type    => l_scheduler_frequency_type,
                                        x_next_run_date     => l_schedule_end_date,
                                        x_return_status     => l_return_status,
                                        x_msg_count         => l_msg_count,
                                        x_msg_data          => l_msg_data);

          IF(l_return_status <> FND_API.G_RET_STS_SUCCESS)
          THEN
             WF_ENGINE.SetItemAttrText(itemtype =>   itemtype,
                             itemkey  =>   itemkey,
                             aname    =>   'ERROR_FLAG',
                             avalue   =>   'Y');
             Handle_Error(p_itemtype  => itemtype,
                        p_itemkey   => itemkey,
                        p_msg_count => l_msg_count,
                        p_msg_data  => l_msg_data);

             WRITE_LOG (l_api_name, 'Errored when creating child end date'||'.'||l_schedule_start_date);
          END IF;*/


--    OPEN c_sch_det(l_schedule_id);
--    FETCH c_sch_det INTO l_start_time, l_timezone;
--    CLOSE c_sch_det;



   -- If any errors happen let start time be sysdate
   /*IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      l_usr_start_time := SYSDATE;
   ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      l_usr_start_time := SYSDATE;
   END IF;*/

    --IF l_schedule_end_date > nvl(l_parent_end_date, l_campaign_end_date)
     --THEN
        l_schedule_end_date :=  nvl(l_parent_end_date, l_campaign_end_date);
    --END IF;


       AMS_SCHEDULER_PVT.Create_Next_Schedule ( p_parent_sched_id       => l_parent_sched_id,
                                                p_child_sched_st_date   => l_schedule_start_date,--l_usr_start_time,
                                                p_child_sched_en_date   => l_schedule_end_date,
                                                x_child_sched_id        => l_child_sched_id,
                                                x_msg_count              => l_msg_count,
                                                x_msg_data              => l_msg_data,
                                                x_return_status         => l_return_status
                                               );

       IF l_return_status = FND_API.G_RET_STS_SUCCESS
       THEN
          WRITE_LOG(l_api_name, 'WF_REPEAT_CREATE_CSCH: Create next schedule returned Success ');

          WF_ENGINE.SetItemAttrText(itemtype    =>     itemtype,
                            itemkey     =>   itemkey,
                           aname    =>     'AMS_NEW_SCHEDULE_ID',
                           avalue    =>     l_child_sched_id);

          result := 'COMPLETE:SUCCESS' ;
       ELSIF l_return_status <> FND_API.G_RET_STS_SUCCESS
       THEN
          WF_ENGINE.SetItemAttrText(itemtype =>   itemtype,
                                itemkey  =>   itemkey,
                                aname    =>   'ERROR_FLAG',
                                avalue   =>   'Y');
          Handle_Error(p_itemtype  => itemtype,
                       p_itemkey   => itemkey,
                       p_msg_count => l_msg_count,
                       p_msg_data  =>l_msg_data,
                       p_wf_err_attrib => 'AMS_CSCH_CREATE_ERROR'
                      );
          result := 'COMPLETE:ERROR' ;
       END IF; -- success in create_next_schedule
   END IF; -- funcmode RUN

          IF (funcmode = 'CANCEL')
    THEN
       result := 'COMPLETE:' ;
      RETURN;
    END IF;

    IF (funcmode = 'TIMEOUT')
    THEN
       result := 'COMPLETE:' ;
      RETURN;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
         wf_core.context(G_PKG_NAME,l_api_name,itemtype,itemkey,actid,funcmode);
        raise ;

   END WF_REPEAT_CREATE_CSCH;

--=====================================================================
-- Procedure
--    WF_REPEAT_RAISE_EVENT
--
-- PURPOSE
--    This api is used by scheduler workflow to raise the event for the next sched run
--
-- HISTORY
--    11-Oct-2003  dbiswas       Created.
--=====================================================================

   PROCEDURE WF_REPEAT_RAISE_EVENT(itemtype    IN     VARCHAR2,
                                   itemkey     IN     VARCHAR2,
                                   actid       IN     NUMBER,
                                   funcmode    IN     VARCHAR2,
                                   result      OUT NOCOPY    VARCHAR2) IS

    l_schedule_id                   NUMBER;
    l_parameter_list   WF_PARAMETER_LIST_T;
    l_schedule_next_run_st_date       DATE;
    l_temp_variable		      varchar2(50);

    l_sch_text               VARCHAR2(100);
    l_new_item_key            VARCHAR2(30);
    l_api_name                VARCHAR2(30);

BEGIN
   l_api_name := 'WF_REPEAT_RAISE_EVENT';
   IF (funcmode = 'RUN')
   THEN
       l_schedule_id := WF_ENGINE.GetItemAttrText(
                  itemtype    =>     itemtype,
                  itemkey     =>     itemkey ,
                  aname       =>    'AMS_NEW_SCHEDULE_ID');

       l_parameter_list := WF_PARAMETER_LIST_T();

       wf_event.AddParameterToList(p_name => 'SCHEDULE_ID',
                                   p_value => l_schedule_id,
                                   p_parameterlist => l_parameter_list);

       l_schedule_next_run_st_date := WF_ENGINE.GetItemAttrDate(itemtype  =>    itemtype,
                                   itemkey   =>    itemkey ,
                                   aname     =>    'AMS_SCHEDULER_NEXT_RUN_ST_DATE'
                                   );

              l_temp_variable := to_char(l_schedule_next_run_st_date,'DD-MON-RRRR HH24:MI:SS');

       wf_event.AddParameterToList(p_name => 'AMS_PARENT_STATUS',
                                   p_value => l_temp_variable,
                                  p_parameterlist => l_parameter_list);

       WRITE_LOG(l_api_name, 'WF_REPEAT_RAISE_EVENT: ADD AMS_SCHEDULER_NEXT_RUN_ST_DATE TO PARAMTER LIST : '||
			     '|| NEW SCHEDULE ID PASSED: '||l_schedule_id||'; || '
			      ||to_char(l_schedule_next_run_st_date,'DD-MON-RRRR HH24:MI:SS')||' ; '
			      ||'|| L_TEMP_VARIABLE VALUE PASSED: '||l_temp_variable||'|| SYSDATE: '
			      ||to_char(sysdate,'DD-MON-RRRR HH24:MI:SS'));


       l_new_item_key := l_schedule_id ||'RPT'|| TO_CHAR(SYSDATE,'DDMMRRRRHH24MISS');

       WRITE_LOG(l_api_name, 'WF_REPEAT_RAISE_EVENT: Before raising event ');
       WRITE_LOG(l_api_name, 'WF_REPEAT_RAISE_EVENT: Before raising event with key '||l_new_item_key);

       Wf_Event.Raise
         ( p_event_name   =>  'oracle.apps.ams.campaign.RepeatScheduleEvent',
           p_event_key    =>  l_new_item_key,
           p_parameters   =>  l_parameter_list,
           p_send_date    =>  l_schedule_next_run_st_date
         );

   END IF;

   --  CANCEL mode  - Normal Process Execution
   IF (funcmode = 'CANCEL')
   THEN
      RETURN;
   END IF;

   --  TIMEOUT mode  - Normal Process Execution
   IF (funcmode = 'TIMEOUT')
   THEN
      RETURN;
   END IF;
   -- dbms_output.put_line('End Check Trigger stat :'||result);
EXCEPTION
    WHEN OTHERS THEN
         wf_core.context(G_PKG_NAME,l_api_name,itemtype,itemkey,actid,funcmode);
        raise ;
END WF_REPEAT_RAISE_EVENT ;


--===============================================================================================
-- Procedure
--    Raise_BE_On_Status_change
--
-- PURPOSE
--    This api is called to raise a Business event on a UserStatus change for CSCH, EVEO, EONE
--
-- ALGORITHM
--    1. Check for the Object Type (CSCH, EVEO and EONE )
--       Yes => 1.1   Open the respective cursor to get the required values
--              1.2   if old_status_code not equal to new_status_code
--                    Yes => Raise Business event
--
--  Any error in any of the API callouts?
--   => a) Set RETURN STATUS to E
--
-- OPEN ISSUES
--   1. Should we do a explicit exit on Object_type not found.
--
-- HISTORY
--    17-Mar-2005  spendem       Created. Enhancement # 3805347
--===============================================================================================

   PROCEDURE RAISE_BE_ON_STATUS_CHANGE(p_obj_id           IN  NUMBER,
                                       p_obj_type         IN  VARCHAR2,
                   p_old_status_code  IN  VARCHAR2,
                                       p_new_status_code  IN  VARCHAR2 ) IS


   CURSOR c_csch_det IS
   SELECT   related_event_from
          , related_event_id
   FROM   ams_campaign_schedules_b
   WHERE  schedule_id = p_obj_id;


   l_api_version  CONSTANT NUMBER := 1.0 ;
   l_api_name     CONSTANT VARCHAR2(30)  := 'RAISE_BE_ON_STATUS_CHANGE';

   l_old_status_code       VARCHAR2(30);
   l_related_event_from    VARCHAR2(30);
   l_related_event_id      NUMBER;
   l_schedule_type         VARCHAR2(4);
   l_parameter_list        WF_PARAMETER_LIST_T;
   l_new_item_key          VARCHAR2(100);

 BEGIN

        -- input debug messages.
   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_Utility_PVT.debug_message(l_api_name || ': start');

   END IF;


      IF ( p_obj_type = 'CSCH' ) THEN

        l_schedule_type := p_obj_type;

   --open cursor for campaign schedules and fetch values
   OPEN c_csch_det;
   FETCH c_csch_det INTO l_related_event_from, l_related_event_id;
   CLOSE c_csch_det;

   ELSIF ( p_obj_type = 'EVEO' OR p_obj_type = 'EONE' ) THEN

        l_schedule_type := p_obj_type;

   ELSE

        RETURN;

   END IF;

   IF ( p_old_status_code <> p_new_status_code )
   THEN

   l_parameter_list := WF_PARAMETER_LIST_T();
        l_new_item_key    := p_obj_id || 'STATUS' || p_obj_type || TO_CHAR(SYSDATE,'DDMMRRRRHH24MISS');


   wf_event.AddParameterToList(p_name => 'OBJECT_TYPE',
                p_value => l_schedule_type,
                p_parameterlist => l_parameter_list);


   wf_event.AddParameterToList(p_name => 'OBJECT_ID',
                p_value => p_obj_id,
                p_parameterlist => l_parameter_list);


   wf_event.AddParameterToList(p_name => 'OLD_STATUS',
                p_value => p_old_status_code,
                                    p_parameterlist => l_parameter_list);


   wf_event.AddParameterToList(p_name => 'NEW_STATUS',
                                    p_value => p_new_status_code,
                                    p_parameterlist => l_parameter_list);


   wf_event.AddParameterToList(p_name => 'RELATED_EVENT_OBJECT_TYPE',
                                    p_value => l_related_event_from,
                                    p_parameterlist => l_parameter_list);


   wf_event.AddParameterToList(p_name => 'RELATED_EVENT_OBJECT_ID',
                                    p_value => l_related_event_id,
                                    p_parameterlist => l_parameter_list);

   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message('Raise Business event for User Status Change' || ' ' || l_new_item_key);

   END IF;



   WF_EVENT.Raise
                  ( p_event_name   =>  'oracle.apps.ams.common.ObjectStatusChanged',
                    p_event_key    =>  l_new_item_key,
                    p_parameters   =>  l_parameter_list);

        END IF;   -- end if for raise Business event.


 END RAISE_BE_ON_STATUS_CHANGE;


-------------------------------------------------------------
-- Start of Comments
-- Name
-- HANDLE_COLLATERAL
--
-- Purpose
-- This function is called from Business Event
-- anchaudh created for R12.
-------------------------------------------------------------
 FUNCTION HANDLE_COLLATERAL(p_subscription_guid   IN       RAW,
                            p_event               IN OUT NOCOPY  WF_EVENT_T
 ) RETURN VARCHAR2
 IS
   l_schedule_id     NUMBER;
   l_association_id  NUMBER;
   l_citem_id        NUMBER;
   l_citem_ver_id    NUMBER;
   l_Return_status  varchar2(20);
   l_log_return_status   VARCHAR2(1) := FND_API.g_ret_sts_success ;

 CURSOR c_citem_assoc (l_csch_id IN NUMBER) IS
   SELECT assoc.association_id, assoc.content_item_id, ci.live_citem_version_id
   FROM ibc_associations assoc, ibc_content_Items ci
   WHERE assoc.association_type_code in ('AMS_CSCH','AMS_COLLAT')
   AND assoc.associated_object_val1 = to_char(l_csch_id)
   AND assoc.content_item_id = ci.content_Item_id;


 PROCEDURE_NAME CONSTANT    VARCHAR2(30) := 'HANDLE_COLLATERAL';

 BEGIN

   -- Get the Value of SCHEDULE_ID
   l_schedule_id := p_event.getValueForParameter('SCHEDULE_ID');

   OPEN  c_citem_assoc(l_schedule_id);
   LOOP
      FETCH c_citem_assoc INTO l_association_id, l_citem_id, l_citem_ver_id;
      EXIT WHEN c_citem_assoc%NOTFOUND;

      AMS_Utility_PVT.Create_Log (
                  x_return_status   => l_log_return_status,
                  p_arc_log_used_by => 'CSCH',
                  p_log_used_by_id  => l_schedule_id,
                  p_msg_data        => 'HANDLE_COLLATERAL : Stamping collateral versions',
                  p_msg_type        => 'DEBUG'
                  );

      IF l_association_id IS NOT null
      AND l_citem_id IS NOT null
      AND l_citem_ver_id IS NOT NULl
      THEN
         Ibc_Associations_Pkg.UPDATE_ROW(
               p_association_id                  => l_association_id
               ,p_citem_version_id               => l_citem_ver_id
               );
      END IF;
   END LOOP;
   CLOSE c_citem_assoc;


  return 'SUCCESS';

 EXCEPTION

   WHEN OTHERS THEN
      WF_CORE.CONTEXT('AMS_ScheduleRules_PVT','HANDLE_COLLATERAL',
                        p_event.getEventName( ), p_subscription_guid);
      WF_EVENT.setErrorInfo(p_event, 'ERROR');
      RETURN 'ERROR';
 END HANDLE_COLLATERAL;

--===============================================================================================
-- PROCEDURE
--    CHECK_NOTIFICATION_PREFERENCE
--
-- PURPOSE
--    This method will be used to check the notification preference for an activity
--
-- ALGORITHM
--    1. Check for the NOTIFY_ON_ACTIVATION_FLAG for the Schedule Id
--       Y => RETURN True
--       N => RETURN False
--
-- HISTORY
--    08-Aug-2005  srivikri       Created.
--    01-sep-2005  soagrawa       Cleaned up
--    30-sep-2005  srivikri       Changes for Repeating Frequency Region display
--    07-Mar-2006  srivikri       changes for bug 4690754
--===============================================================================================

 PROCEDURE CHECK_NOTIFICATION_PREFERENCE(itemtype    IN     VARCHAR2,
                                itemkey     IN     VARCHAR2,
                                actid       IN     NUMBER,
                                funcmode    IN     VARCHAR2,
                                result      OUT NOCOPY    VARCHAR2) IS

   CURSOR l_sch_det (p_schedule_id NUMBER) IS
   SELECT
       NOTIFY_ON_ACTIVATION_FLAG,
       triggerable_flag,
       trig_repeat_flag,
       source_code,
       Med.media_name,
       lookup.MEANING,
       orig_csch_id,
       frequency,
       frequency_type,
       end_date_time,
       campaign_id
        FROM ams_campaign_schedules_b csch,
            ams_scheduler scheduler,
       AMS_MEDIA_VL Med,
       ams_lookups lookup
        WHERE csch.schedule_id = p_schedule_id
          AND scheduler.OBJECT_ID(+) = nvl(csch.orig_csch_id, csch.schedule_id)
          AND scheduler.OBJECT_TYPE(+) = 'CSCH'
          AND Med.media_id = csch.activity_id
          AND lookup.LOOKUP_TYPE(+) = 'AMS_TRIGGER_FREQUENCY_TYPE'
          AND lookup.LOOKUP_CODE(+) = scheduler.frequency_type;

   CURSOR l_new_sch_det (p_new_schedule_id NUMBER) IS
   SELECT
            schedule_name
    FROM AMS_CAMPAIGN_SCHEDULES_VL
    WHERE SCHEDULE_ID = p_new_schedule_id;

   CURSOR l_camp_det (p_campaign_id NUMBER) IS
   SELECT
            actual_exec_end_date
    FROM AMS_CAMPAIGNS_ALL_B
    WHERE CAMPAIGN_ID = p_campaign_id;


   l_api_version  CONSTANT NUMBER := 1.0 ;
   l_api_name     CONSTANT VARCHAR2(35)  := 'CHECK_NOTIFICATION_PREFERENCE';
   l_flag         VARCHAR2(1);
   l_triggerable_flag VARCHAR2(1);
   l_trig_repeat_flag VARCHAR2(1);
   l_schedule_id  NUMBER;
   l_return_status     VARCHAR2(1);
   --l_repeat_freq_type  VARCHAR2(30);
   l_msg_data          VARCHAR2(30);
   l_source_code       VARCHAR2(30);
   l_new_schedule_id NUMBER;
   l_new_schedule_name VARCHAR2(240);
   l_scheduler_frequency NUMBER;
   l_media_name VARCHAR2(120);
   l_freq_meaning VARCHAR2(80);
   l_orig_csch_id NUMBER;

   l_query_freq NUMBER;
   l_query_freq_type VARCHAR2(80);
   l_csch_end_date DATE;
   l_scheduler_next_run_date DATE;
   l_campaign_end_date DATE;
   l_campaign_id NUMBER;
   l_msg_count NUMBER;

 BEGIN

    --  RUN mode  - Normal Process Execution
    IF (funcmode = 'RUN')
    THEN
        l_schedule_id  := to_number(WF_ENGINE.GetItemAttrText(
                                 itemtype    =>    itemtype,
                                 itemkey      =>     itemkey ,
                                 aname      =>    'SCHEDULE_ID' ));

        AMS_Utility_PVT.Create_Log (
           x_return_status   => l_return_status,
         p_arc_log_used_by => 'CSCH',
         p_log_used_by_id  => l_schedule_id,
         p_msg_data        => 'CHECK_NOTIFICATION_PREFERENCE : started',
         p_msg_type        => 'DEBUG'
         );

   OPEN  l_sch_det(l_schedule_id);
   FETCH l_sch_det INTO l_flag, l_triggerable_flag, l_trig_repeat_flag, l_source_code, l_media_name, l_freq_meaning, l_orig_csch_id,l_query_freq,l_query_freq_type,l_csch_end_date, l_campaign_id;
   CLOSE l_sch_det;

      IF ( l_flag is not null and l_flag = 'Y' ) THEN
       result := 'COMPLETE:T' ;
            AMS_Utility_PVT.Create_Log (
                  x_return_status   => l_return_status,
                  p_arc_log_used_by => 'CSCH',
                  p_log_used_by_id  => l_schedule_id,
                  p_msg_data        => 'CHECK_NOTIFICATION_PREFERENCE : NOTIFICATION PREFERENCE IS YES for schedule id '||l_schedule_id,
                  p_msg_type        => 'DEBUG'
                  );

   ELSE
            AMS_Utility_PVT.Create_Log (
                  x_return_status   => l_return_status,
                  p_arc_log_used_by => 'CSCH',
                  p_log_used_by_id  => l_schedule_id,
                  p_msg_data        => 'CHECK_NOTIFICATION_PREFERENCE : NOTIFICATION PREFERENCE IS NO for schedule id '||l_schedule_id,
                  p_msg_type        => 'DEBUG'
                  );
            result := 'COMPLETE:F';
   END IF;

   IF ((l_triggerable_flag = 'N' AND l_trig_repeat_flag = 'Y') OR l_orig_csch_id IS NOT NULL) THEN
   --Repeating activity
        l_scheduler_frequency  := to_number(WF_ENGINE.GetItemAttrText(
                                 itemtype    =>    itemtype,
                                 itemkey      =>     itemkey ,
                                 aname      =>    'AMS_SCHEDULER_FREQUENCY' ));
        IF (l_scheduler_frequency IS NULL) THEN
        -- this means that the repeating activity is in the Schedule Execution flow
            AMS_SCHEDULER_PVT.Schedule_Repeat (
                                        p_last_run_date     => SYSDATE,
                                        p_frequency         => l_query_freq,
                                        p_frequency_type    => l_query_freq_type,
                                        x_next_run_date     => l_scheduler_next_run_date,
                                        x_return_status     => l_return_status,
                                        x_msg_count         => l_msg_count,
                                        x_msg_data          => l_msg_data);
            OPEN  l_camp_det(l_campaign_id);
            FETCH l_camp_det INTO l_campaign_end_date;
            CLOSE l_camp_det;

            IF (nvl(l_csch_end_date, l_campaign_end_date) <= l_scheduler_next_run_date)
            THEN

            -- if this is the last executed activity Return true
            -- so that the notification will be sent
            -- since the workflow does not flow thru the Notification node if the activity is last one
                  result := 'COMPLETE:T';
            ELSE
            -- returning False, as we dont want to send the Notification twice
                 result := 'COMPLETE:F';
            END IF;
            --RETURN;
        ELSE
         l_new_schedule_id := TO_NUMBER(WF_ENGINE.GetItemAttrText(
               itemtype    =>     itemtype,
               itemkey     =>     itemkey ,
               aname       =>    'AMS_NEW_SCHEDULE_ID'));

         IF l_new_Schedule_id IS NOT NULL
         THEN

         OPEN  l_new_sch_det(l_new_schedule_id);
         FETCH l_new_sch_det INTO l_new_schedule_name;
         CLOSE l_new_sch_det;

         WF_ENGINE.SetItemAttrText(itemtype     =>    itemtype,
                    itemkey      =>    itemkey ,
                    aname        =>    'AMS_NEW_SCHEDULE_NAME',
                    avalue       =>    l_new_schedule_name   );
         END IF;
         WF_ENGINE.SetItemAttrText(itemtype     =>    itemtype,
            itemkey      =>    itemkey ,
            aname        =>    'AMS_SCHEDULER_FREQ_MEANING',
            avalue       =>    l_freq_meaning   );

         END IF;
         -- set the message 'Repeating Activity' from FND_MESSAGES
           FND_MESSAGE.Set_Name('AMS', 'AMS_REPEATING_ACTIVITY_PROMPT');
   ELSE
   -- set the message 'Activity' from FND_MESSAGES to the attribute AMS_ACTIVITY_DESCRIPTION using setItemAttrText
         FND_MESSAGE.Set_Name('AMS', 'AMS_ACTIVITY_PROMPT');
   END IF;
       l_msg_data := FND_MESSAGE.Get;

   WF_ENGINE.SetItemAttrText(itemtype     =>    itemtype,
                             itemkey      =>    itemkey ,
                             aname        =>    'AMS_ACTIVITY_DESCRIPTION',
                             avalue       =>    l_msg_data   );
   WF_ENGINE.SetItemAttrText(itemtype     =>    itemtype,
                             itemkey      =>    itemkey ,
                             aname        =>    'SOURCE_CODE',
                             avalue       =>    l_source_code   );
   WF_ENGINE.SetItemAttrText(itemtype     =>    itemtype,
                             itemkey      =>    itemkey ,
                             aname        =>    'AMS_CHANNEL_DESCRIPTION',
                             avalue       =>    l_media_name   );

   END IF;

    --  CANCEL mode  - Normal Process Execution
    IF (funcmode = 'CANCEL')
    THEN
       result := 'COMPLETE:F' ;
      RETURN;
    END IF;

    --  TIMEOUT mode  - Normal Process Execution
    IF (funcmode = 'TIMEOUT')
    THEN
       result := 'COMPLETE:F' ;
      RETURN;
    END IF;
 EXCEPTION
    WHEN OTHERS THEN
         wf_core.context(G_PKG_NAME,'CHECK_NOTIFICATION_PREFERENCE',itemtype,itemkey,actid,funcmode);
        raise ;
 END CHECK_NOTIFICATION_PREFERENCE;

END AMS_ScheduleRules_PVT ;

/
