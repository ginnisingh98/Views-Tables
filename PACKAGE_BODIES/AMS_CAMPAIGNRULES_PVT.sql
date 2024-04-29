--------------------------------------------------------
--  DDL for Package Body AMS_CAMPAIGNRULES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_CAMPAIGNRULES_PVT" AS
/* $Header: amsvcbrb.pls 120.6 2006/04/12 03:19:24 mayjain noship $ */


g_pkg_name   CONSTANT VARCHAR2(30):='AMS_CampaignRules_PVT';

AMS_DEBUG_HIGH_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Archive_Schedules(
   p_campaign_id                   IN  NUMBER
   );

PROCEDURE Archive_Campaigns(
   p_program_id                   IN  NUMBER
   );

PROCEDURE Activate_Campaigns(
   p_program_id                   IN  NUMBER
   ) ;

PROCEDURE Hold_Campaigns(
   p_program_id                   IN  NUMBER,
   p_system_status_code    IN  VARCHAR2
   );


PROCEDURE Update_Related_Source_Code(
   p_source_code                   IN  VARCHAR2,
   p_source_code_for_id            IN  NUMBER,
   p_source_code_for               IN  VARCHAR2,
   p_related_source_code           IN  VARCHAR2,
   p_related_source_code_for_id    IN  NUMBER,
   p_related_source_code_for       IN  VARCHAR2,
   x_return_status                 OUT NOCOPY VARCHAR2
) ;

PROCEDURE Cancel_Schedule(p_campaign_id     IN  NUMBER) ;
PROCEDURE Cancel_Program(p_program_id       IN  NUMBER) ;
PROCEDURE Complete_Schedule(p_campaign_id   IN  NUMBER) ;
PROCEDURE Complete_Program(p_program_id     IN  NUMBER) ;
PROCEDURE Check_Close_Campaign(p_campaign_id IN  NUMBER) ;
-----------------------------------------------------------------------
-- PROCEDURE
--    handle_camp_status
--
-- HISTORY
--    11/01/99   holiu     Created.
--  07-May-2001  ptendulk  Commented check for system status type as
--                         Programs will also use same api.
-----------------------------------------------------------------------
PROCEDURE handle_camp_status(
   p_user_status_id  IN  NUMBER,
   x_status_code     OUT NOCOPY VARCHAR2,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS

   l_status_code     VARCHAR2(30);

   CURSOR c_status_code IS
   SELECT system_status_code
     FROM ams_user_statuses_b
    WHERE user_status_id = p_user_status_id
    --   Commented by ptendulk on 07-May-2001 as Program and campaign use the same api.
    --   AND system_status_type = 'AMS_CAMPAIGN_STATUS'
      AND enabled_flag = 'Y';

BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   OPEN c_status_code;
   FETCH c_status_code INTO l_status_code ;
   CLOSE c_status_code;

   IF l_status_code IS NULL THEN
      x_return_status := FND_API.g_ret_sts_error;
      AMS_Utility_PVT.error_message('AMS_CAMP_BAD_USER_STATUS');
   END IF;

   x_status_code := l_status_code;

END handle_camp_status;


-----------------------------------------------------------------------
-- PROCEDURE
--    handle_camp_inherit_flag
--
-- HISTORY
--    11/01/99  holiu  Created.
-----------------------------------------------------------------------
PROCEDURE handle_camp_inherit_flag(
   p_parent_id      IN  NUMBER,
   p_rollup_type    IN  VARCHAR2,
   x_inherit_flag   OUT NOCOPY VARCHAR2,
   x_return_status  OUT NOCOPY VARCHAR2
)
IS

   l_rollup_type  VARCHAR2(30);

   CURSOR c_parent IS
   SELECT rollup_type
     FROM ams_campaigns_vl
    WHERE campaign_id = p_parent_id;

BEGIN

   x_inherit_flag := 'N';
   x_return_status := FND_API.g_ret_sts_success;

   IF p_parent_id IS NOT NULL THEN
      OPEN c_parent;
      FETCH c_parent INTO l_rollup_type;
      CLOSE c_parent;

      IF l_rollup_type IS NULL THEN
         AMS_Utility_PVT.error_message('AMS_CAMP_BAD_PARENT_ID');
         x_return_status := FND_API.g_ret_sts_error;
      ELSIF l_rollup_type = 'ECAM' THEN
         AMS_Utility_PVT.error_message('AMS_CAMP_PARENT_IS_EC');
         x_return_status := FND_API.g_ret_sts_error;
      ELSIF l_rollup_type = 'MCAM' THEN
         IF p_rollup_type = 'ECAM' THEN
            x_inherit_flag := 'Y';
         ELSE
            AMS_Utility_PVT.error_message('AMS_CAMP_PARENT_IS_MC');
            x_return_status := FND_API.g_ret_sts_error;
         END IF;
      END IF;
   END IF;

END handle_camp_inherit_flag;


-----------------------------------------------------------------------
-- PROCEDURE
--    create_camp_association
--
-- HISTORY
--   07/15/2000  ptendulk  Created.
-----------------------------------------------------------------------
PROCEDURE create_camp_association(
   p_campaign_id       IN  NUMBER,
   p_event_id          IN  NUMBER,
   p_event_type        IN  VARCHAR2,
   x_return_status     OUT NOCOPY VARCHAR2
)
IS

   l_assc_rec    AMS_Associations_PVT.association_rec_type;
   l_event_type  VARCHAR2(30);
   l_event_id    NUMBER;
   l_obj_ver     NUMBER;
   l_obj_id      NUMBER;

   l_msg_count   NUMBER;
   l_msg_data    VARCHAR2(2000);

   CURSOR c_event_det IS
   SELECT object_association_id,
          object_version_number,
          using_object_id,
          using_object_type
   FROM   ams_object_associations
   WHERE  master_object_type = 'CAMP'
   AND    master_object_id = p_campaign_id
   AND    using_object_type in ('EVEH', 'EVEO');

--   CURSOR c_event_used IS
--   SELECT 1
--   FROM   DUAL
--   WHERE  EXISTS(
--          SELECT 1
--          FROM   ams_object_associations
--         WHERE  master_object_type = 'CAMP'
--          AND    using_object_type = p_event_type
--          AND    using_object_id = p_event_id);

--
-- Following Cursor is rewritten by ptendulk on 14Aug2000
-- Ref. Bug :1378977
--   Check that the event is not associated to any other campaign
--
   CURSOR c_event_used IS
     SELECT master_object_id
     FROM   ams_object_associations
     WHERE  master_object_type = 'CAMP'
     AND    using_object_type = p_event_type
     AND    using_object_id = p_event_id;
   l_master_id   NUMBER ;

BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   -- find out if there is any event already associated to the campaign
   OPEN c_event_det;
   FETCH c_event_det INTO l_obj_id, l_obj_ver, l_event_id, l_event_type;
   CLOSE c_event_det ;

   -- delete it if no longer associated
   IF l_obj_id IS NOT NULL
      AND (l_event_id <> p_event_id OR l_event_type <> p_event_type
         OR p_event_id IS NULL)
   THEN
      l_assc_rec.object_version_number := l_obj_ver;
      l_assc_rec.object_association_id := l_obj_id ;

      AMS_Associations_PVT.delete_association(
         p_api_version           =>  1.0,
         p_init_msg_list         =>  FND_API.g_false,
         p_commit                =>  FND_API.g_false,
         p_validation_level      =>  FND_API.g_valid_level_full,

         x_return_status         =>  x_return_status,
         x_msg_count             =>  l_msg_count,
         x_msg_data              =>  l_msg_data,

         p_object_association_id =>  l_obj_id,
         p_object_version        =>  l_obj_ver
      );
   END IF;

   IF x_return_status = FND_API.g_ret_sts_success
      AND p_event_id IS NOT NULL
   THEN
      -- check if the given event is associated to any campaign
      l_obj_id := 0 ;
      OPEN c_event_used ;
      FETCH c_event_used INTO l_master_id ;
      CLOSE c_event_used ;

--
-- Following code is modified by ptendulk on 14Aug2000
--  Check if the event is associated , if yes check if it is
--  associated to any other campaign if yes give error message
--  if not associated to any campaign, create association
--
      IF l_master_id IS NOT NULL AND
         l_master_id <> p_campaign_id
      THEN
         x_return_status := FND_API.g_ret_sts_error;
         AMS_Utility_PVT.error_message('AMS_CAMP_EVE_EXIST');
    ELSIF l_master_id IS NULL THEN
         -- initialize the association rec
         l_assc_rec.master_object_type := 'CAMP' ;
         l_assc_rec.using_object_type  := p_event_type ;
         l_assc_rec.master_object_id   := p_campaign_id ;
         l_assc_rec.using_object_id    := p_event_id ;
         l_assc_rec.primary_flag       := 'Y' ;
         l_assc_rec.usage_type         := 'CREATED' ;

         AMS_Associations_PVT.create_association(
            p_api_version           =>  1.0,
            p_init_msg_list         =>  FND_API.g_false,
            p_commit                =>  FND_API.g_false,
            p_validation_level      =>  FND_API.g_valid_level_full,

            x_return_status         =>  x_return_status,
            x_msg_count             =>  l_msg_count,
            x_msg_data              =>  l_msg_data,

            p_association_rec       =>  l_assc_rec,
            x_object_association_id =>  l_obj_id
         );
      END IF;
   END IF;

END create_camp_association;


-----------------------------------------------------------------------
-- PROCEDURE
--    Udpate_Camp_Source_Code
--
-- HISTORY
--    06/26/00  holiu      Created.
--  07-Feb-2001 ptendulk   Changed the logic for cascade source_code
--                         flag as it is moved to schedules tables now.
--  12-Jun-2001 ptendulk   Refer bug #1825922
--  16-aug-2002 soagrawa   Fixed bug# 2511783 in update_camp_source_code. This is related to
--                         updating global flag
--
-----------------------------------------------------------------------
PROCEDURE update_camp_source_code(
   p_campaign_id      IN  NUMBER,
   p_source_code      IN  VARCHAR2,
   p_global_flag      IN  VARCHAR2,
   x_source_code      OUT NOCOPY VARCHAR2,
   p_related_source_object  IN    VARCHAR2 := NULL,
   p_related_source_id      IN    NUMBER   := NULL,
   x_return_status    OUT NOCOPY VARCHAR2
)
IS

   l_msg_data  VARCHAR2(2000);
   l_msg_count NUMBER;

   l_source_code       VARCHAR2(30);
   l_global_flag       VARCHAR2(1);
   l_cascade_flag      VARCHAR2(1);
   l_custom_setup_id   NUMBER;
   l_csch_exist        NUMBER;
   l_source_code_id    NUMBER;
   l_status            VARCHAR2(30) ;
   l_rollup_type       VARCHAR2(30) ;

   CURSOR c_old_info IS
   SELECT global_flag, source_code, custom_setup_id, status_code, rollup_type,
          related_event_id
   FROM   ams_campaigns_all_b
   WHERE  campaign_id = p_campaign_id;

   CURSOR c_csch_exist IS
   SELECT 1
     FROM DUAL
    WHERE EXISTS(
          SELECT 1
            FROM ams_campaign_schedules_b
           WHERE campaign_id = p_campaign_id
             AND active_flag = 'Y'
             AND use_parent_code_flag = 'Y' );


   CURSOR c_source_code IS
   SELECT source_code_id
   FROM   ams_source_codes
   WHERE  source_code = x_source_code
   AND    active_flag = 'Y';

   l_rollup             VARCHAR2(30) ;
   l_related_event_id   NUMBER ;

   l_related_source_code   VARCHAR2(30);
   l_related_source_object VARCHAR2(30) := p_related_source_object ;
   l_related_source_id     NUMBER       := p_related_source_id ;

BEGIN

   x_source_code := p_source_code;
   x_return_status := FND_API.g_ret_sts_success;


   OPEN c_old_info;
   FETCH c_old_info INTO l_global_flag, l_source_code, l_custom_setup_id, l_status, l_rollup, l_related_event_id;
   CLOSE c_old_info;

   l_related_source_code := Get_Event_Source_Code(p_related_source_object,p_related_source_id);
   IF l_related_source_code IS NULL THEN
      l_related_source_id     := NULL ;
      l_related_source_object := NULL ;
   END IF ;


   IF p_source_code = l_source_code
   -- following line of code is added by ptendulk on 12-Jun-2001
   -- Refer bug #1825922
   AND p_global_flag = l_global_flag  THEN
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.Debug_Message('Source code is Same') ;
   END IF;
      IF (p_related_source_id IS NULL AND l_related_event_id IS NOT NULL)
      OR (l_related_event_id IS NULL AND p_related_source_id IS NOT NULL)
      THEN
         Update_Related_Source_Code(
            p_source_code                 => p_source_code,
            p_source_code_for_id          => p_campaign_id ,
            p_source_code_for             => 'CAMP',
            p_related_source_code         => l_related_source_code,
            p_related_source_code_for_id  => l_related_source_id,
            p_related_source_code_for     => l_related_source_object,
            x_return_status               => x_return_status
         );
      ELSIF p_related_source_id <> l_related_event_id THEN
         Update_Related_Source_Code(
            p_source_code                 => p_source_code,
            p_source_code_for_id          => p_campaign_id ,
            p_source_code_for             => 'CAMP',
            p_related_source_code         => l_related_source_code,
            p_related_source_code_for_id  => l_related_source_id,
            p_related_source_code_for     => l_related_source_object,
            x_return_status               => x_return_status
         );
      END IF ;
      RETURN ;
   END IF ;

   IF l_rollup = 'RCAM' THEN
      IF p_source_code IS NULL THEN
         AMS_Utility_PVT.Error_Message('AMS_CAMP_NO_PROG_CODE');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      ELSE
--aranka added 07/27/02
         IF AMS_Utility_PVT.check_uniqueness(
                             'ams_campaigns_all_b',
                             'source_code = ''' || p_source_code || ''''
                             || ' AND campaign_id <> '||p_campaign_id
--                             || ''' AND rollup_type = ''RCAM'' AND campaign_id <> '||p_campaign_id
                             ) = FND_API.g_false
         THEN
            AMS_Utility_PVT.Error_Message('AMS_CAMP_BAD_PROG_CODE');
            x_return_status := FND_API.g_ret_sts_error;
            RETURN;
         END IF;
      END IF;
   ELSE

      -- Can not update source code if the Status is not new
      IF l_status <> 'NEW' THEN
         AMS_Utility_PVT.error_message('AMS_CAMP_UPDATE_SRC_STAT');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF ;

     -- all this code added by aranka was removed by SOAGRAWA on 16-AUG-2002
     -- refer to bug# 2511783
     --aranka added 07/27/02
     --sam added start
     --    IF p_source_code IS NOT NULL THEN
     --            IF AMS_Utility_PVT.check_uniqueness(
     --                    'ams_source_codes',
     --                    'source_code = ''' || p_source_code ||
     --                    ''' AND active_flag = ''Y'''
     --                    ) = FND_API.g_false
     --            THEN
     --                    AMS_Utility_PVT.Error_Message('AMS_CAMP_DUPLICATE_CODE');
     --                    x_return_status := FND_API.g_ret_sts_error;
     --                    RETURN;
     --            END IF;
     --            IF AMS_Utility_PVT.check_uniqueness(
     --                    'ams_campaigns_all_b',
     --                    'source_code = ''' || p_source_code || ''''
     --                    || ' AND campaign_id <> '||p_campaign_id
     --                    ) = FND_API.g_false
     --            THEN
     --                    AMS_Utility_PVT.Error_Message('AMS_CAMP_DUPLICATE_CODE');
     --                    x_return_status := FND_API.g_ret_sts_error;
     --                    RETURN;
     --            END IF;
     --    END IF;
     --sam added end

      OPEN c_csch_exist;
      FETCH c_csch_exist INTO l_csch_exist;
      CLOSE c_csch_exist;

      -- source_code cannot be changed if cascade and schedule exists
      IF l_csch_exist IS NOT NULL THEN
         AMS_Utility_PVT.error_message('AMS_CAMP_UPDATE_SOURCE_CODE');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_Utility_PVT.Debug_message('Global Flag : ' ||l_global_flag );
      END IF;
      -- generate a new source code if global flag is updated and
      -- source code is not cascaded to schedules
      IF p_global_flag <> l_global_flag
      THEN
         x_source_code := AMS_SourceCode_PVT.get_new_source_code(
            p_object_type  => 'CAMP',
            p_custsetup_id => l_custom_setup_id,
            p_global_flag  => p_global_flag
         );
      END IF;
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_Utility_PVT.Debug_message('Source Code : ' ||x_source_code );
      END IF;

      IF x_source_code = l_source_code THEN
         RETURN;
      END IF;

      IF x_source_code IS NULL THEN
         AMS_Utility_PVT.error_message('AMS_CAMP_NO_SOURCE_CODE');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      -- check if the new source code is unique
      OPEN c_source_code;
      FETCH c_source_code INTO l_source_code_id;
      CLOSE c_source_code;

      IF l_source_code_id IS NOT NULL THEN
         AMS_Utility_PVT.error_message('AMS_CAMP_DUPLICATE_CODE');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      -- this code added here by soagrawa on 16-aug-2002  for bug# 2511783
      IF x_source_code IS NOT NULL THEN
         IF AMS_Utility_PVT.check_uniqueness(
                        'ams_campaigns_all_b',
                        'source_code = ''' || x_source_code || ''''
                        || ' AND campaign_id <> '||p_campaign_id
                        ) = FND_API.g_false
         THEN
                        AMS_Utility_PVT.Error_Message('AMS_CAMP_DUPLICATE_CODE');
                        x_return_status := FND_API.g_ret_sts_error;
                        RETURN;
         END IF;
      END IF;
      -- end soagrawa

      -- otherwise revoke the old one and add the new one to ams_source_codes
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

      AMS_SourceCode_PVT.create_sourcecode(
         p_api_version        => 1.0,
         p_init_msg_list      => FND_API.g_false,
         p_commit             => FND_API.g_false,
         p_validation_level   => FND_API.g_valid_level_full,

         x_return_status      => x_return_status,
         x_msg_count          => l_msg_count,
         x_msg_data           => l_msg_data,

         p_sourcecode         => x_source_code,
         p_sourcecode_for     => 'CAMP',
         p_sourcecode_for_id  => p_campaign_id,
         p_related_sourcecode => l_related_source_code,
         p_releated_sourceobj => l_related_source_object,
         p_related_sourceid   => l_related_source_id,
         x_sourcecode_id      => l_source_code_id
      );

      IF x_return_status <> FND_API.g_ret_sts_success THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF ;
END update_camp_source_code;


---------------------------------------------------------------------
-- PROCEDURE
--    check_camp_update
--
-- HISTORY
--    11/01/99  holiu  Created.
--    06/26/00  holiu  Move out source code logic.
--    07/15/00  holiu  Requirement changes for going live.
---------------------------------------------------------------------
PROCEDURE check_camp_update(
   p_camp_rec       IN  AMS_Campaign_PVT.camp_rec_type,
   p_complete_rec   IN  AMS_Campaign_PVT.camp_rec_type,
   x_return_status  OUT NOCOPY VARCHAR2
)
IS

   CURSOR c_resource IS
   SELECT resource_id
   FROM   ams_jtf_rs_emp_v
   WHERE  user_id = FND_GLOBAL.user_id ;

   CURSOR c_child IS
   SELECT 1
   FROM   DUAL
   WHERE  EXISTS(
          SELECT campaign_id
          FROM   ams_campaigns_vl
          WHERE  parent_campaign_id = p_camp_rec.campaign_id);

   CURSOR c_camp IS
   SELECT *
     FROM ams_campaigns_vl
    WHERE campaign_id = p_camp_rec.campaign_id;

   l_camp_rec  c_camp%ROWTYPE;
   l_dummy     NUMBER;

   l_resource  NUMBER ;
   l_access    VARCHAR2(1);
   l_admin_user BOOLEAN;
   l_rollup_type   VARCHAR2(30);
   l_owner         NUMBER ;
BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   OPEN c_resource ;
   FETCH c_resource INTO l_resource;
   CLOSE c_resource ;

   IF p_complete_rec.rollup_type = 'RCAM' THEN
      l_rollup_type := 'RCAM'  ;
   ELSE
      l_rollup_type := 'CAMP' ;
   END IF ;

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_Utility_PVT.debug_message('Obj : '||l_rollup_type||p_camp_rec.campaign_id||' User : '||l_resource);

   END IF;

   l_access := AMS_Access_PVT.Check_Update_Access(p_object_id          => p_camp_rec.campaign_id ,
                                                  p_object_type        => l_rollup_type,
                                                  p_user_or_role_id    => l_resource,
                                                  p_user_or_role_type  => 'USER');

   IF l_access = 'N' THEN
      AMS_Utility_PVT.error_message('AMS_CAMP_NO_ACCESS');
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF ;



   OPEN c_camp;
   FETCH c_camp INTO l_camp_rec;
   IF c_camp%NOTFOUND THEN
      CLOSE c_camp;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_camp;

--aranka removed comment 01/18/02
   l_admin_user := AMS_Access_PVT.Check_Admin_Access(l_resource);
--aranka removed comment 01/18/02

   IF p_camp_rec.owner_user_id = FND_API.g_miss_num THEN
      l_owner := p_complete_rec.owner_user_id ;
   ELSE
      l_owner := p_camp_rec.owner_user_id ;
   END IF;

-- aranka added 12/17/01 bug #2148325 start
--   l_admin_user := AMS_Access_PVT.Check_Admin_Access(l_owner);
-- aranka added 12/17/01 bug #2148325 end

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_Utility_PVT.Debug_message('p_camp_rec.owner_user_id  : '|| p_camp_rec.owner_user_id) ;

   END IF;
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.Debug_message('l_camp_rec.owner_user_id  : '|| l_camp_rec.owner_user_id) ;
   END IF;
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.Debug_message('Resource id  : '||l_resource ) ;
   END IF;

   -- Only owner/ Super Admin can change the owner.
   IF p_camp_rec.owner_user_id <> FND_API.g_miss_num
   AND p_camp_rec.owner_user_id <> l_camp_rec.owner_user_id
   AND l_admin_user = FALSE
--aranka added comment 01/18/02
--   AND l_owner <> l_resource
   AND l_camp_rec.owner_user_id <> l_resource
--aranka added comment 01/18/02
   THEN
      AMS_Utility_PVT.error_message('AMS_CAMP_UPDT_OWNER_PERM');
      x_return_status := FND_API.g_ret_sts_error;
   END IF;


   IF (AMS_DEBUG_HIGH_ON) THEN





   AMS_Utility_PVT.Debug_message('Resource id  : '||l_resource ||' Owner : '||p_camp_rec.owner_user_id) ;


   END IF;
   -- Only owner/ Super Admin can change the Business Unit
   IF p_camp_rec.business_unit_id <> FND_API.g_miss_num
   AND p_camp_rec.business_unit_id <> l_camp_rec.business_unit_id
   AND l_admin_user = FALSE
   AND l_owner <> l_resource
   THEN
      AMS_Utility_PVT.error_message('AMS_CAMP_UPDT_BUS_UNIT_PERM');
      x_return_status := FND_API.g_ret_sts_error;
   END IF;

   -- cannot update template_flag if child campaigns exist
   IF p_camp_rec.template_flag <> FND_API.g_miss_char
      AND p_camp_rec.template_flag <> l_camp_rec.template_flag
   THEN
      OPEN c_child;
      FETCH c_child INTO l_dummy;
      IF c_child%FOUND THEN
         AMS_Utility_PVT.error_message('AMS_CAMP_UPDT_TMPL_FLAG');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
      CLOSE c_child;
   END IF;

   -- 07/15/00 holiu:
   --    remove as template campaigns will have status changes
   -- template campaigns won't have any status changes
   --IF p_camp_rec.user_status_id <> FND_API.g_miss_num
   --   AND p_camp_rec.user_status_id <> l_camp_rec.user_status_id
   --   AND l_camp_rec.template_flag = 'Y'
   --THEN
   --   AMS_Utility_PVT.error_message('AMS_CAMP_UPDATE_TEMP_STATUS');
   --   x_return_status := FND_API.g_ret_sts_error;
   --   RETURN;
   --END IF;

   -- aranka added 05/10/02
   -- the following will be locked after available
--   IF l_camp_rec.status_code <> 'NEW'
--   THEN
--      IF p_camp_rec.campaign_name <> FND_API.g_miss_char
--         AND p_camp_rec.campaign_name <> l_camp_rec.campaign_name
--      THEN
--         AMS_Utility_PVT.error_message('AMS_CAMP_UPDATE_CAMPAIGN_NAME');
--         x_return_status := FND_API.g_ret_sts_error;
--      END IF;

      --IF p_camp_rec.channel_id <> FND_API.g_miss_num
      --   AND p_camp_rec.channel_id <> l_camp_rec.channel_id
      --THEN
      --   AMS_Utility_PVT.error_message('AMS_CAMP_UPDATE_CHANNEL');
      --   x_return_status := FND_API.g_ret_sts_error;
      --END IF;

--      IF p_camp_rec.actual_exec_start_date <> FND_API.g_miss_date
--         AND p_camp_rec.actual_exec_start_date <> l_camp_rec.actual_exec_start_date
--         AND (p_camp_rec.actual_exec_start_date IS NOT NULL
--            OR l_camp_rec.actual_exec_start_date IS NOT NULL)
--      THEN
--         AMS_Utility_PVT.error_message('AMS_CAMP_UPDATE_START_DATE');
--         x_return_status := FND_API.g_ret_sts_error;
--      END IF;

      --IF p_camp_rec.actual_exec_end_date <> FND_API.g_miss_date
      --   AND p_camp_rec.actual_exec_end_date <> l_camp_rec.actual_exec_end_date
      --  AND (p_camp_rec.actual_exec_end_date IS NOT NULL
      --      OR l_camp_rec.actual_exec_end_date IS NOT NULL)
      --THEN
      --   AMS_Utility_PVT.error_message('AMS_CAMP_UPDATE_END_DATE');
      --   x_return_status := FND_API.g_ret_sts_error;
      --END IF;
--   END IF;

END Check_Camp_Update;


--======================================================================
-- PROCEDURE
--    check_camp_template_flag
--
-- PURPOSE
--    1. Created to check the template flag for campaigns
--    2. Check if the marketing medium is assigned to the campaign
--       before it goes active.
--
-- HISTORY
--    07/15/00  holiu  Created.
--======================================================================
PROCEDURE Check_Camp_Template_Flag(
   p_parent_id         IN  NUMBER,
   p_channel_id        IN  NUMBER,
   p_template_flag     IN  VARCHAR2,
   p_status_code       IN  VARCHAR2,
   p_rollup_type       IN  VARCHAR2,
   p_media_type        IN  VARCHAR2,
   x_return_status     OUT NOCOPY VARCHAR2
)
IS

   l_template_flag   VARCHAR2(1);

   CURSOR c_parent IS
   SELECT template_flag
     FROM ams_campaigns_vl
    WHERE campaign_id = p_parent_id;

BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   -- Commented by ptendulk as Channels will be attached at the schedule level
   -- channel is required before submitted for non-template campaigns
   --IF p_template_flag = 'N'
   --   AND p_rollup_type = 'ECAM'
   --   AND p_channel_id IS NULL
   --   AND p_status_code IN ('SUBMITTED_TA', 'PLANNING', 'SUBMITTED_BA', 'AVAILABLE', 'ACTIVE')
   --THEN
   --   IF p_media_type = 'EVENTS' THEN
   --      AMS_Utility_PVT.error_message('AMS_CAMP_EVENT_REQUIRED');
   --   ELSE
   --      AMS_Utility_PVT.error_message('AMS_CAMP_CHANNEL_REQUIRED');
   --  END IF;
   --   x_return_status := FND_API.g_ret_sts_error;
   --   RETURN;
   --END IF;

   -- check parent campaign
   IF p_parent_id IS NOT NULL THEN
      OPEN c_parent;
      FETCH c_parent INTO l_template_flag;
      CLOSE c_parent;

      IF l_template_flag <> p_template_flag THEN
         AMS_Utility_PVT.error_message('AMS_CAMP_ASSOC_TEMPLATE');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

END check_camp_template_flag;


-----------------------------------------------------------------------
-- PROCEDURE
--    check_camp_media_type
--
-- HISTORY
--    11/01/99  holiu  Created.
--    02/07/00  holiu  Disable share media type checking.
--    07/14/00  holiu  Both EVEH and EVEO can be channels.
--    07/15/00  holiu  Channel is no longer required for ECAM.
--
-----------------------------------------------------------------------
PROCEDURE check_camp_media_type(
   p_campaign_id       IN  NUMBER,
   p_parent_id         IN  NUMBER,
   p_rollup_type       IN  VARCHAR2,
   p_media_type        IN  VARCHAR2,
   p_media_id          IN  NUMBER,
   p_channel_id        IN  NUMBER,
   p_event_type        IN  VARCHAR2,
   p_arc_channel_from  IN  VARCHAR2,
   x_return_status     OUT NOCOPY VARCHAR2
)
IS

   l_type   VARCHAR2(30);
   l_dummy  NUMBER;

   CURSOR c_media IS
   SELECT media_type_code
     FROM ams_media_vl
    WHERE media_id = p_media_id
    AND enabled_flag = 'Y';

   CURSOR c_channel_media IS
   SELECT 1
     FROM ams_media_channels
    WHERE channel_id = p_channel_id
    AND media_id = p_media_id;

   CURSOR c_eveh IS
   SELECT event_type_code
     FROM ams_event_headers_vl
    WHERE event_header_id = p_channel_id;

   CURSOR c_eveo IS
   SELECT event_type_code
     FROM ams_event_offers_vl
    WHERE event_offer_id = p_channel_id;

   CURSOR c_camp_event IS
   SELECT 1
   FROM   DUAL
   WHERE  EXISTS(
          SELECT campaign_id
          FROM   ams_campaigns_vl
          WHERE  media_type_code = 'EVENTS'
          AND    arc_channel_from = p_arc_channel_from
          AND    channel_id = p_channel_id
          AND    (campaign_id <> p_campaign_id OR p_campaign_id IS NULL));

--   Following line(Was the last line of the above cursor) is commented by ptendulk
--   on 14 Aug 2000 Ref Bug : 1378977
--
--          AND    (campaign_id = p_campaign_id OR p_campaign_id IS NULL));

BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   -- for execution campaigns, media_type and media are required
   IF p_rollup_type = 'ECAM' THEN
      IF p_media_type IS NULL THEN
         AMS_Utility_PVT.error_message('AMS_CAMP_EC_NO_MEDIA_TYPE');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_media_type <> 'EVENTS' AND p_media_id IS NULL THEN
         AMS_Utility_PVT.error_message('AMS_CAMP_EC_NO_MEDIA');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_media_type = 'EVENTS' AND p_event_type IS NULL THEN
         AMS_Utility_PVT.error_message('AMS_CAMP_EC_NO_EVENT_TYPE');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      -- 07/15/00 holiu: remove as channel is no longer required
      --IF p_channel_id IS NULL THEN
      --   AMS_Utility_PVT.error_message('AMS_CAMP_EC_NO_CHANNEL');
      --   x_return_status := FND_API.g_ret_sts_error;
      --   RETURN;
      --END IF;
   END IF;

   ---- all children under the same rollup campaign share the same media type
   --l_type := get_parent_media_type(p_parent_id);
   --IF p_media_type <> l_type THEN
   --   x_return_status := FND_API.g_ret_sts_error;
   --   AMS_Utility_PVT.error_message('AMS_CAMP_SHARE_MEDIA_TYPE');
   --   RETURN;
   --END IF;

   -- validate media_id
   IF p_media_id IS NOT NULL THEN
      OPEN c_media;
      FETCH c_media INTO l_type;
      CLOSE c_media;

      IF l_type <> p_media_type THEN
         AMS_Utility_PVT.error_message('AMS_CAMP_BAD_MEDIA_ID');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   -- validate media channel id
   IF p_media_type <> 'EVENTS'AND p_channel_id IS NOT NULL THEN
    OPEN c_channel_media;
    FETCH c_channel_media INTO l_dummy;
    CLOSE c_channel_media;

    IF l_dummy IS NULL OR p_media_id IS NULL THEN
         AMS_Utility_PVT.error_message('AMS_CAMP_BAD_CHANNEL');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   -- validate event channel id
   IF p_media_type = 'EVENTS' AND p_channel_id IS NOT NULL THEN
      IF p_arc_channel_from = 'EVEO' THEN
         OPEN c_eveo;
         FETCH c_eveo INTO l_type;
         IF c_eveo%NOTFOUND OR l_type <> p_event_type THEN
            x_return_status := FND_API.g_ret_sts_error;
            AMS_Utility_PVT.error_message('AMS_CAMP_BAD_CHANNEL');
         END IF;
         CLOSE c_eveo;
      ELSIF p_arc_channel_from = 'EVEH' THEN
         OPEN c_eveh;
         FETCH c_eveh INTO l_type;
         IF c_eveh%NOTFOUND OR l_type <> p_event_type THEN
            x_return_status := FND_API.g_ret_sts_error;
            AMS_Utility_PVT.error_message('AMS_CAMP_BAD_CHANNEL');
         END IF;
         CLOSE c_eveh;
      ELSE
         x_return_status := FND_API.g_ret_sts_error;
         AMS_Utility_PVT.error_message('AMS_CAMP_BAD_ARC_CHANNEL');
      END IF;

      -- event associated to a campaign cannot be associated to other campaigns
      OPEN c_camp_event;
      FETCH c_camp_event INTO l_dummy;
      IF c_camp_event%FOUND THEN
         x_return_status := FND_API.g_ret_sts_error;
         AMS_Utility_PVT.error_message('AMS_CAMP_EVENT_IN_USE');
      END IF;
      CLOSE c_camp_event;
   END IF;

END check_camp_media_type;


---------------------------------------------------------------------
-- PROCEDURE
--    check_camp_fund_source
--
-- HISTORY
--    11/01/99  holiu  Created.
---------------------------------------------------------------------
PROCEDURE check_camp_fund_source(
   p_fund_source_type  IN  VARCHAR2,
   p_fund_source_id    IN  NUMBER,
   x_return_status     OUT NOCOPY VARCHAR2
)
IS

   l_dummy  NUMBER;

   CURSOR c_camp IS
   SELECT 1
     FROM ams_campaigns_vl
    WHERE campaign_id = p_fund_source_id;

   CURSOR c_eveh IS
   SELECT 1
     FROM ams_event_headers_vl
    WHERE event_header_id = p_fund_source_id;

   CURSOR c_eveo IS
   SELECT 1
     FROM ams_event_offers_vl
    WHERE event_offer_id = p_fund_source_id;

BEGIN

   x_return_status := FND_API.g_ret_sts_success;
   IF p_fund_source_type IS NULL AND p_fund_source_id IS NULL THEN
      RETURN;
   ELSIF p_fund_source_type IS NULL AND p_fund_source_id IS NOT NULL THEN
      x_return_status := FND_API.g_ret_sts_error;
      AMS_Utility_PVT.error_message('AMS_CAMP_NO_FUND_SOURCE_TYPE');
      RETURN;
   END IF;

   IF p_fund_source_type = 'FUND' THEN
      NULL;
   ELSIF p_fund_source_type = 'CAMP' THEN
      IF p_fund_source_id IS NOT NULL THEN
         OPEN c_camp;
         FETCH c_camp INTO l_dummy;
         IF c_camp%NOTFOUND THEN
            x_return_status := FND_API.g_ret_sts_error;
            AMS_Utility_PVT.error_message('AMS_CAMP_BAD_FUND_SOURCE_ID');
         END IF;
         CLOSE c_camp;
      END IF;
   ELSIF p_fund_source_type = 'EVEH' THEN
      IF p_fund_source_id IS NOT NULL THEN
         OPEN c_eveh;
         FETCH c_eveh INTO l_dummy;
         IF c_eveh%NOTFOUND THEN
            x_return_status := FND_API.g_ret_sts_error;
            AMS_Utility_PVT.error_message('AMS_CAMP_BAD_FUND_SOURCE_ID');
         END IF;
         CLOSE c_eveh;
      END IF;
   ELSIF p_fund_source_type = 'EVEO' THEN
      IF p_fund_source_id IS NOT NULL THEN
         OPEN c_eveo;
         FETCH c_eveo INTO l_dummy;
         IF c_eveo%NOTFOUND THEN
            x_return_status := FND_API.g_ret_sts_error;
            AMS_Utility_PVT.error_message('AMS_CAMP_BAD_FUND_SOURCE_ID');
         END IF;
         CLOSE c_eveo;
      END IF;
   ELSE
      x_return_status := FND_API.g_ret_sts_error;
      AMS_Utility_PVT.error_message('AMS_CAMP_BAD_FUND_SOURCE_TYPE');
   END IF;

END check_camp_fund_source;


-----------------------------------------------------------------------
-- PROCEDURE
--    check_camp_calendar
--
-- HISTORY
--    06/21/00  holiu  Created.
-----------------------------------------------------------------------
PROCEDURE check_camp_calendar(
   p_campaign_calendar   IN  VARCHAR2,
   p_start_period_name   IN  VARCHAR2,
   p_end_period_name     IN  VARCHAR2,
   p_start_date          IN  DATE,
   p_end_date            IN  DATE,
   x_return_status       OUT NOCOPY VARCHAR2
)
IS

   l_start_start   DATE;
   l_start_end     DATE;
   l_end_start     DATE;
   l_end_end       DATE;
   l_dummy         NUMBER;

   CURSOR c_campaign_calendar IS
   SELECT 1
   FROM   DUAL
   WHERE  EXISTS(
             SELECT 1
             FROM   gl_periods_v
             WHERE  period_set_name = p_campaign_calendar
          );

   CURSOR c_start_period IS
   SELECT start_date, end_date
   FROM   gl_periods_v
   WHERE  period_set_name = p_campaign_calendar
   AND    period_name = p_start_period_name;

   CURSOR c_end_period IS
   SELECT start_date, end_date
   FROM   gl_periods_v
   WHERE  period_set_name = p_campaign_calendar
   AND    period_name = p_end_period_name;

BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   -- check if p_campaign_calendar is null
   IF p_campaign_calendar IS NULL
      AND p_start_period_name IS NULL
      AND p_end_period_name IS NULL
   THEN
      RETURN;
   ELSIF p_campaign_calendar IS NULL THEN
      x_return_status := FND_API.g_ret_sts_error;
      AMS_Utility_PVT.error_message('AMS_CAMP_NO_CAMPAIGN_CALENDAR');
      RETURN;
   END IF;

   IF p_start_date > p_end_date THEN
      x_return_status := FND_API.g_ret_sts_error;
      AMS_Utility_PVT.error_message('AMS_CAMP_INVALID_DATE');
      RETURN;
   END IF ;


   -- check if p_campaign_calendar is valid
   OPEN c_campaign_calendar;
   FETCH c_campaign_calendar INTO l_dummy;
   CLOSE c_campaign_calendar;

   IF l_dummy IS NULL THEN
      x_return_status := FND_API.g_ret_sts_error;
      AMS_Utility_PVT.error_message('AMS_CAMP_BAD_CAMPAIGN_CALENDAR');
      RETURN;
   END IF;

   -- check p_start_period_name
   IF p_start_period_name IS NOT NULL THEN
      OPEN c_start_period;
      FETCH c_start_period INTO l_start_start, l_start_end;
      CLOSE c_start_period;

      IF l_start_start IS NULL THEN
         x_return_status := FND_API.g_ret_sts_error;
         AMS_Utility_PVT.error_message('AMS_CAMP_BAD_START_PERIOD');
         RETURN;
      ELSIF p_start_date < l_start_start OR p_start_date > l_start_end THEN
         x_return_status := FND_API.g_ret_sts_error;
         AMS_Utility_PVT.error_message('AMS_CAMP_OUT_START_PERIOD');
         RETURN;
      END IF;
   END IF;

   -- check p_end_period_name
   IF p_end_period_name IS NOT NULL THEN
      OPEN c_end_period;
      FETCH c_end_period INTO l_end_start, l_end_end;
      CLOSE c_end_period;

      IF l_end_end IS NULL THEN
         x_return_status := FND_API.g_ret_sts_error;
         AMS_Utility_PVT.error_message('AMS_CAMP_BAD_END_PERIOD');
         RETURN;
      ELSIF p_end_date < l_end_start OR p_end_date > l_end_end THEN
         x_return_status := FND_API.g_ret_sts_error;
         AMS_Utility_PVT.error_message('AMS_CAMP_OUT_END_PERIOD');
         RETURN;
      END IF;
   END IF;

   -- compare the start date and the end date
   IF l_start_start > l_end_end THEN
      x_return_status := FND_API.g_ret_sts_error;
      AMS_Utility_PVT.error_message('AMS_CAMP_BAD_PERIODS');
   END IF;

END check_camp_calendar;


-----------------------------------------------------------------------
-- PROCEDURE
--    check_camp_version
--
-- HISTORY
--    06/22/00  holiu  Created.
--  20-Jun-2001   ptendulk   Modified the c_displayed cursor, as There
--                           will be only one campaign by the name and
--                           version. You can plan on new campaign with same
--                           name on later date but you can not create
--                           new campaign of same name as another campaign
--                           which is not active or cancelled or archived.
--  30-Jul-2001   ptendulk   Removed the city check as the campaign
--                           name will be unique with version.
-----------------------------------------------------------------------
PROCEDURE check_camp_version(
   p_campaign_id         IN  NUMBER,
   p_campaign_name       IN  VARCHAR2,
   p_status_code         IN  VARCHAR2,
   p_start_date          IN  DATE,
   p_city_id             IN  NUMBER,
   p_version_no          IN  NUMBER,
   x_return_status       OUT NOCOPY VARCHAR2
)
IS

   l_active_end_date  DATE;
   l_displayed        NUMBER;
   l_duplicate        NUMBER;

   CURSOR c_active_end_date IS
   SELECT actual_exec_end_date
   FROM   ams_campaigns_vl
   WHERE  campaign_name = p_campaign_name
   -- AND    (city_id = p_city_id OR city_id IS NULL AND p_city_id IS NULL)
   AND    status_code = 'ACTIVE'
   --AND    (campaign_id <> p_campaign_id OR p_campaign_id IS NULL);
   AND NVL(p_campaign_id,-20) <> campaign_id  ;


   CURSOR c_displayed IS
   SELECT 1
   FROM   DUAL
   WHERE  EXISTS(
             SELECT 1
             FROM   ams_campaigns_vl
             WHERE  campaign_name = p_campaign_name
             -- AND    (city_id = p_city_id OR city_id IS NULL AND p_city_id IS NULL)
             AND    show_campaign_flag = 'Y'
             --AND    actual_exec_end_date < SYSDATE
             AND    (p_status_code <> 'CANCELLED' AND p_status_code <> 'ARCHIVED')
             AND    NVL(p_campaign_id,-20) <> campaign_id
             --AND    (campaign_id <> p_campaign_id OR p_campaign_id IS NULL)
          );

   CURSOR c_duplicate IS
   SELECT 1
   FROM   DUAL
   WHERE  EXISTS(
             SELECT 1
             FROM   ams_campaigns_vl
             WHERE  campaign_name = p_campaign_name
             AND    (city_id = p_city_id OR city_id IS NULL AND p_city_id IS NULL)
             -- 25-Aug-2005 mayjain version is no longer supported from R12
             --AND    version_no = p_version_no
             AND    (campaign_id <> p_campaign_id OR p_campaign_id IS NULL)
          );

BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   OPEN c_active_end_date;
   FETCH c_active_end_date INTO l_active_end_date;
   CLOSE c_active_end_date;

   IF l_active_end_date IS NULL THEN -- could be planning old one
      OPEN c_displayed;
      FETCH c_displayed INTO l_displayed;
      CLOSE c_displayed;

      IF l_displayed IS NOT NULL THEN --still planning old one
         OPEN c_duplicate;
         FETCH c_duplicate INTO l_duplicate;
         CLOSE c_duplicate;

         IF l_duplicate IS NOT NULL THEN --duplicate version
            x_return_status := FND_API.g_ret_sts_error;
            AMS_Utility_PVT.error_message('AMS_CAMP_DUPLICATE_VERSION');
         END IF;
      END IF;
   ELSE --plan new one
      IF p_status_code = 'ACTIVE' THEN
         x_return_status := FND_API.g_ret_sts_error;
         AMS_Utility_PVT.error_message('AMS_CAMP_PREV_STILL_ACTIVE');
      ELSIF p_start_date < l_active_end_date THEN
         x_return_status := FND_API.g_ret_sts_error;
         AMS_Utility_PVT.error_message('AMS_CAMP_START_BEF_PREV_END');
      END IF;
   END IF;

END check_camp_version;



---------------------------------------------------------------------
-- PROCEDURE
--    check_camp_status_vs_parent
--
-- HISTORY
--    04/17/2002    aranka       Created.
---------------------------------------------------------------------
PROCEDURE check_camp_status_vs_parent(
   p_parent_id              IN  NUMBER,
   p_status_code            IN  VARCHAR2,
   x_return_status          OUT NOCOPY VARCHAR2
)
IS

   l_api_name   CONSTANT VARCHAR2(30) := 'check_camp_status_vs_parent';
   l_full_name  CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_parent_status_code  VARCHAR2(30);
   l_old_status_id     NUMBER;

   /* Cursor to get the user status id of  program */
   CURSOR c_PROGRAM_status IS
   SELECT user_status_id
   FROM   ams_campaigns_all_b
   WHERE  campaign_id = p_parent_id;

BEGIN
        IF p_parent_id IS NOT NULL then
                OPEN c_PROGRAM_status;
                FETCH c_PROGRAM_status INTO l_old_status_id;
                CLOSE c_PROGRAM_status;
        END IF;

      l_parent_status_code := AMS_Utility_PVT.get_system_status_code(l_old_status_id);

      If p_status_code = 'ACTIVE' and l_parent_status_code <> 'ACTIVE' THEN
         FND_MESSAGE.set_name('AMS', 'AMS_PROGRAM_NOT_ACTIVE');
              FND_MSG_PUB.add;
         RAISE FND_API.g_exc_error;
      END IF;

END check_camp_status_vs_parent;


---------------------------------------------------------------------
-- PROCEDURE
--    check_camp_dates_vs_parent
--
-- HISTORY
--    11/01/99    holiu       Created.
--   23-May-2001  ptendulk    Check for the Business unit of the parent if it is same.
---------------------------------------------------------------------
PROCEDURE check_camp_dates_vs_parent(
   p_parent_id      IN  NUMBER,
   p_rollup_type    IN  VARCHAR2,
   p_start_date     IN  DATE,
   p_end_date       IN  DATE,
   x_return_status  OUT NOCOPY VARCHAR2
)
IS

   l_api_name   CONSTANT VARCHAR2(30) := 'check_camp_dates_vs_parent';
   l_full_name  CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   CURSOR c_parent_camp IS
   SELECT actual_exec_start_date,
          actual_exec_end_date
     FROM ams_campaigns_vl
    WHERE campaign_id = p_parent_id;

   l_parent_start_date  DATE;
   l_parent_end_date    DATE;

--  09-Aug-2002 aranka
   l_msg_name           VARCHAR2(40);

BEGIN

   x_return_status := FND_API.g_ret_sts_success;
   IF p_parent_id IS NULL THEN
      RETURN;
   END IF;

   OPEN c_parent_camp;
   FETCH c_parent_camp INTO l_parent_start_date, l_parent_end_date;
   IF c_parent_camp%NOTFOUND THEN
      CLOSE c_parent_camp;
      x_return_status := FND_API.g_ret_sts_error;
      AMS_Utility_PVT.error_message('AMS_CAMP_BAD_PARENT_ID');
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_parent_camp;

 -- aranka added 12/13/01  bug# 2146013 start
   ---------------------- start date ----------------------------
   IF p_start_date IS NOT NULL THEN
      IF l_parent_start_date IS NULL THEN
         x_return_status := FND_API.g_ret_sts_error;
         AMS_Utility_PVT.error_message('AMS_CAMP_PAR_START_IS_NULL');
      ELSIF p_start_date < l_parent_start_date THEN
         x_return_status := FND_API.g_ret_sts_error;
 --        AMS_Utility_PVT.error_message('AMS_CAMP_START_BEF_PAR_START');
--  09-Aug-2002 aranka
       l_msg_name := 'AMS_CAMP_START_BEF_PAR_START';
       IF ( p_rollup_type = 'RCAM') THEN
         l_msg_name := 'AMS_RCAM_START_BEF_PAR_START';
       END IF;

       AMS_Utility_PVT.error_message(
            l_msg_name,
            'CAMP_START_DATE_AFTR',
            FND_DATE.date_to_chardate(l_parent_start_date)
         );

      ELSIF  (l_parent_end_date IS NOT NULL AND p_start_date > l_parent_end_date) THEN
         x_return_status := FND_API.g_ret_sts_error;
 --        AMS_Utility_PVT.error_message('AMS_CAMP_START_AFT_PAR_END');

       l_msg_name := 'AMS_CAMP_START_AFT_PAR_END';
       IF ( p_rollup_type = 'RCAM') THEN
         l_msg_name := 'AMS_RCAM_START_AFT_PAR_END';
       END IF;

        AMS_Utility_PVT.error_message(
            l_msg_name,
            'CAMP_START_DATE_BFR',
-- aranka added 04/01/02
--            FND_DATE.date_to_chardate(l_parent_start_date)
            FND_DATE.date_to_chardate(l_parent_end_date)
         );

      END IF;
   END IF;

   ---------------------- end date ------------------------------
   IF p_end_date IS NOT NULL THEN
      IF l_parent_end_date IS NULL THEN
         RETURN ; -- As Program End date can be null
         -- x_return_status := FND_API.g_ret_sts_error;
         -- AMS_Utility_PVT.error_message('AMS_CAMP_PAR_END_IS_NULL');
      ELSIF p_end_date > l_parent_end_date THEN
         x_return_status := FND_API.g_ret_sts_error;
 --         AMS_Utility_PVT.error_message('AMS_CAMP_END_AFT_PAR_END');
--  09-Aug-2002 aranka
       l_msg_name := 'AMS_CAMP_END_AFT_PAR_END';
       IF ( p_rollup_type = 'RCAM') THEN
         l_msg_name := 'AMS_RCAM_END_AFT_PAR_END';
       END IF;

        AMS_Utility_PVT.error_message(
            l_msg_name,
            'CAMP_END_DATE_BFR',
-- aranka added 04/01/02
--            FND_DATE.date_to_chardate(l_parent_start_date)
            FND_DATE.date_to_chardate(l_parent_end_date)
         );
      ELSIF p_end_date < l_parent_start_date THEN
         x_return_status := FND_API.g_ret_sts_error;
 --        AMS_Utility_PVT.error_message('AMS_CAMP_END_BEF_PAR_START');

       l_msg_name := 'AMS_CAMP_END_BEF_PAR_START';
       IF ( p_rollup_type = 'RCAM') THEN
         l_msg_name := 'AMS_RCAM_END_BEF_PAR_START';
       END IF;


        AMS_Utility_PVT.error_message(
            l_msg_name,
            'CAMP_END_DATE_AFTR',
            FND_DATE.date_to_chardate(l_parent_start_date)
         );
      END IF;
   END IF;

 -- aranka added 12/13/01 bug# 2146013 end

END check_camp_dates_vs_parent;


---------------------------------------------------------------------
-- PROCEDURE
--    check_camp_dates_vs_child
--
-- HISTORY
--    11/01/99  holiu  Created.
---------------------------------------------------------------------
PROCEDURE check_camp_dates_vs_child(
   p_camp_id        IN  NUMBER,
   p_start_date     IN  DATE,
   p_end_date       IN  DATE,
   x_return_status  OUT NOCOPY VARCHAR2
)
IS

   l_api_name  CONSTANT VARCHAR2(30) := 'check_camp_dates_vs_child';
   l_full_name CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   CURSOR c_sub_camp IS
   SELECT campaign_name AS campaign_name,
          actual_exec_start_date AS start_date,
          actual_exec_end_date AS end_date
     FROM ams_campaigns_vl
    WHERE parent_campaign_id = p_camp_id;

BEGIN

   x_return_status := FND_API.g_ret_sts_success;
   IF p_camp_id IS NULL THEN
      RETURN;
   END IF;

   FOR l_sub_rec IN c_sub_camp LOOP
      IF p_start_date IS NULL AND l_sub_rec.start_date IS NOT NULL THEN
         x_return_status := FND_API.g_ret_sts_error;
         AMS_Utility_PVT.error_message(
            'AMS_CAMP_SUB_START_NOT_NULL',
            'CAMPAIGN_NAME',
            l_sub_rec.campaign_name
         );
      ELSIF p_start_date > l_sub_rec.start_date THEN
         x_return_status := FND_API.g_ret_sts_error;
         AMS_Utility_PVT.error_message(
            'AMS_CAMP_START_AFT_SUB_START',
            'CAMPAIGN_NAME',
            l_sub_rec.campaign_name
         );
      ELSIF (l_sub_rec.end_date IS NOT NULL AND p_start_date > l_sub_rec.end_date) THEN
         x_return_status := FND_API.g_ret_sts_error;
         AMS_Utility_PVT.error_message(
            'AMS_CAMP_START_AFT_SUB_END',
            'CAMPAIGN_NAME',
            l_sub_rec.campaign_name
         );
      END IF;

      IF p_end_date IS NOT NULL AND l_sub_rec.end_date IS NULL THEN
         x_return_status := FND_API.g_ret_sts_error;
         AMS_Utility_PVT.error_message(
            'AMS_CAMP_SUB_END_NOT_NULL',
            'CAMPAIGN_NAME',
            l_sub_rec.campaign_name
         );
      ELSIF p_end_date < l_sub_rec.end_date THEN
         x_return_status := FND_API.g_ret_sts_error;
         AMS_Utility_PVT.error_message(
            'AMS_CAMP_END_BEF_SUB_END',
            'CAMPAIGN_NAME',
            l_sub_rec.campaign_name
         );
      ELSIF p_end_date < l_sub_rec.start_date THEN
         x_return_status := FND_API.g_ret_sts_error;
         AMS_Utility_PVT.error_message(
            'AMS_CAMP_END_BEF_SUB_START',
            'CAMPAIGN_NAME',
            l_sub_rec.campaign_name
         );
      END IF;
   END LOOP;

END check_camp_dates_vs_child;



--=====================================================================
-- PROCEDURE
--    Check_BU_Vs_Child
--
-- PURPOSE
--    Check if the Business unit of children is same as that of parent
--
-- HISTORY
--    23-May-2001  ptendulk  Created.
--=====================================================================
PROCEDURE Check_BU_Vs_Child(
   p_camp_id            IN  NUMBER,
   p_business_unit_id   IN  NUMBER,
   x_return_status      OUT NOCOPY VARCHAR2
)
IS

   l_api_name  CONSTANT VARCHAR2(30) := 'Check_BU_Vs_Child';
   l_full_name CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   CURSOR c_sub_camp IS
   SELECT campaign_name AS campaign_name,
          business_unit_id
   FROM ams_campaigns_vl
   WHERE parent_campaign_id = p_camp_id;

BEGIN

   x_return_status := FND_API.g_ret_sts_success;
   IF p_camp_id IS NULL OR
      p_business_unit_id IS NULL THEN
      RETURN;
   END IF;

   FOR l_sub_rec IN c_sub_camp LOOP
      IF l_sub_rec.business_unit_id IS NOT NULL
      AND p_business_unit_id <> l_sub_rec.business_unit_id
      THEN
         x_return_status := FND_API.g_ret_sts_error;
         AMS_Utility_PVT.error_message(
            'AMS_NOMATCH_CHILD_BU',
            'CAMPAIGN_NAME',
            l_sub_rec.campaign_name
         );
      END IF ;
   END LOOP ;


END Check_BU_Vs_Child;

--==============================================================================
-- PROCEDURE
--    Check_BU_Vs_Parent
--
-- PURPOSE
--    Check if the Business unit of campaign/program is same as that of parent
--
-- HISTORY
--    23-May-2001  ptendulk  Created.
--===============================================================================
PROCEDURE Check_BU_Vs_Parent(
   p_program_id            IN  NUMBER,
   p_business_unit_id   IN  NUMBER,
   x_return_status      OUT NOCOPY VARCHAR2
)
IS

   l_api_name  CONSTANT VARCHAR2(30) := 'Check_BU_Vs_Parent';
   l_full_name CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   CURSOR c_parent_camp IS
   SELECT business_unit_id
   FROM  ams_campaigns_all_b
   WHERE campaign_id = p_program_id;

   l_business_unit_id NUMBER ;
BEGIN

   x_return_status := FND_API.g_ret_sts_success;
   IF p_program_id IS NULL OR
      p_business_unit_id IS NULL THEN
      RETURN;
   END IF;

   OPEN c_parent_camp ;
   FETCH c_parent_camp INTO l_business_unit_id ;
   CLOSE c_parent_camp;

   IF l_business_unit_id IS NOT NULL
   AND l_business_unit_id <> p_business_unit_id
   THEN
      AMS_Utility_PVT.Error_Message('AMS_NOMATCH_PARENT_BU');
      x_return_status := FND_API.g_ret_sts_error ;
   END IF ;

END Check_BU_Vs_Parent;

--=====================================================================
-- PROCEDURE
--    Check_Prog_Dates_Vs_Eveh
--
-- PURPOSE
--    The api is created to check the dates of program vs dates of
--    events. Events dates has to be between program dates.
--
-- HISTORY
--    07-Feb-2001  ptendulk    Created.
--    26-Dec-2002  ptendulk    Fixed bug 2685244, there was no validation before
--=====================================================================
PROCEDURE Check_Prog_Dates_Vs_Eveh(
   p_camp_id        IN  NUMBER,
   p_start_date     IN  DATE,
   p_end_date       IN  DATE,
   x_return_status  OUT NOCOPY VARCHAR2
)
IS

   l_api_name  CONSTANT VARCHAR2(30) := 'Check_Prog_Dates_Vs_Eveh';
   l_full_name CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   CURSOR c_sub_eveh IS
   SELECT event_header_name AS event_name,
          active_from_date AS start_date,
          active_to_date AS end_date
     FROM ams_event_headers_vl
    WHERE program_id = p_camp_id;

   CURSOR c_sub_eone IS
   SELECT event_offer_name AS event_name,
          event_start_date AS start_date,
          event_end_date AS end_date
     FROM ams_event_offers_vl
    WHERE parent_type = 'RCAM'
    AND   parent_id = p_camp_id
    AND   event_standalone_flag = 'Y' ;


BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   IF p_camp_id IS NULL THEN
      RETURN;
   END IF;

   FOR l_sub_rec IN c_sub_eveh LOOP
      IF p_start_date IS NULL AND l_sub_rec.start_date IS NOT NULL THEN
         x_return_status := FND_API.g_ret_sts_error;
         AMS_Utility_PVT.error_message(
            'AMS_EVEH_SUB_START_NOT_NULL',
            'EVENT_NAME',
            l_sub_rec.event_name
         );
      ELSIF p_start_date > l_sub_rec.start_date THEN
         x_return_status := FND_API.g_ret_sts_error;
         AMS_Utility_PVT.error_message(
            'AMS_EVEH_START_AFT_SUB_START',
            'EVENT_NAME',
            l_sub_rec.event_name
         );
      ELSIF (l_sub_rec.end_date IS NOT NULL AND p_start_date > l_sub_rec.end_date) THEN
         x_return_status := FND_API.g_ret_sts_error;
         AMS_Utility_PVT.error_message(
            'AMS_EVEH_START_AFT_SUB_END',
            'EVENT_NAME',
            l_sub_rec.event_name
         );
      END IF;

      IF p_end_date IS NOT NULL AND l_sub_rec.end_date IS NULL THEN
         x_return_status := FND_API.g_ret_sts_error;
         AMS_Utility_PVT.error_message(
            'AMS_EVEH_SUB_END_NOT_NULL',
            'EVENT_NAME',
            l_sub_rec.event_name
         );
      ELSIF p_end_date < l_sub_rec.end_date THEN
         x_return_status := FND_API.g_ret_sts_error;
         AMS_Utility_PVT.error_message(
            'AMS_EVEH_END_BEF_SUB_END',
            'EVENT_NAME',
            l_sub_rec.event_name
         );
      ELSIF p_end_date < l_sub_rec.start_date THEN
         x_return_status := FND_API.g_ret_sts_error;
         AMS_Utility_PVT.error_message(
            'AMS_EVEH_END_BEF_SUB_START',
            'EVENT_NAME',
            l_sub_rec.event_name
         );
      END IF;
   END LOOP;

   FOR l_sub_eone_rec IN c_sub_eone LOOP
      IF p_start_date IS NULL AND l_sub_eone_rec.start_date IS NOT NULL THEN
         x_return_status := FND_API.g_ret_sts_error;
         AMS_Utility_PVT.error_message(
            'AMS_EONE_SUB_START_NOT_NULL',
            'EVENT_NAME',
            l_sub_eone_rec.event_name
         );
      ELSIF p_start_date > l_sub_eone_rec.start_date THEN
         x_return_status := FND_API.g_ret_sts_error;
         AMS_Utility_PVT.error_message(
            'AMS_EONE_START_AFT_SUB_START',
            'EVENT_NAME',
            l_sub_eone_rec.event_name
         );
      ELSIF (l_sub_eone_rec.end_date IS NOT NULL AND p_start_date > l_sub_eone_rec.end_date) THEN
         x_return_status := FND_API.g_ret_sts_error;
         AMS_Utility_PVT.error_message(
            'AMS_EONE_START_AFT_SUB_END',
            'EVENT_NAME',
            l_sub_eone_rec.event_name
         );
      END IF;

      IF p_end_date IS NOT NULL AND l_sub_eone_rec.end_date IS NULL THEN
         x_return_status := FND_API.g_ret_sts_error;
         AMS_Utility_PVT.error_message(
            'AMS_EONE_SUB_END_NOT_NULL',
            'EVENT_NAME',
            l_sub_eone_rec.event_name
         );
      ELSIF p_end_date < l_sub_eone_rec.end_date THEN
         x_return_status := FND_API.g_ret_sts_error;
         AMS_Utility_PVT.error_message(
            'AMS_EONE_END_BEF_SUB_END',
            'EVENT_NAME',
            l_sub_eone_rec.event_name
         );
      ELSIF p_end_date < l_sub_eone_rec.start_date THEN
         x_return_status := FND_API.g_ret_sts_error;
         AMS_Utility_PVT.error_message(
            'AMS_EONE_END_BEF_SUB_START',
            'EVENT_NAME',
            l_sub_eone_rec.event_name
         );
      END IF;
   END LOOP;


END Check_Prog_Dates_Vs_Eveh;

---------------------------------------------------------------------
-- PROCEDURE
--    check_camp_dates_vs_csch
--
-- HISTORY
--    11/01/99  holiu  Created.
--    25-May-2001 ptendulk  Check only dates of Active schedules.
---------------------------------------------------------------------
PROCEDURE check_camp_dates_vs_csch(
   p_camp_id        IN  NUMBER,
   p_start_date     IN  DATE,
   p_end_date       IN  DATE,
   x_return_status  OUT NOCOPY VARCHAR2
)
IS

   l_api_name  CONSTANT VARCHAR2(30) := 'check_camp_dates_vs_csch';
   l_full_name CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   CURSOR c_csch IS
   SELECT start_date_time AS start_date,
          end_date_time AS end_date
   FROM ams_campaign_schedules_b
   WHERE campaign_id = p_camp_id
   -- Following line of code is added by ptendulk on 25-May-2001
    AND   active_flag = 'Y' ;

BEGIN

   x_return_status := FND_API.g_ret_sts_success;
   IF p_camp_id IS NULL THEN
      RETURN;
   END IF;

   FOR l_csch_rec IN c_csch LOOP
      IF p_start_date IS NULL AND l_csch_rec.start_date IS NOT NULL THEN
         x_return_status := FND_API.g_ret_sts_error;
         AMS_Utility_PVT.error_message('AMS_CAMP_CSCH_START_NOT_NULL');
      ELSIF p_start_date > l_csch_rec.start_date THEN
         x_return_status := FND_API.g_ret_sts_error;
         AMS_Utility_PVT.error_message(
            'AMS_CAMP_START_AFT_CSCH_START',
            'SCHEDULE_DATE',
            FND_DATE.date_to_chardate(l_csch_rec.start_date)
         );
      ELSIF l_csch_rec.end_date IS NOT NULL
      AND   p_start_date > l_csch_rec.end_date THEN
         x_return_status := FND_API.g_ret_sts_error;
         AMS_Utility_PVT.error_message(
            'AMS_CAMP_START_AFT_CSCH_END',
            'SCHEDULE_DATE',
            FND_DATE.date_to_chardate(l_csch_rec.end_date)
         );
      END IF;

      IF p_end_date IS NULL AND l_csch_rec.end_date IS NOT NULL THEN
         x_return_status := FND_API.g_ret_sts_error;
         AMS_Utility_PVT.error_message('AMS_CAMP_CSCH_END_NOT_NULL');
      ELSIF l_csch_rec.end_date IS NOT NULL
      AND   p_end_date < l_csch_rec.end_date THEN
         x_return_status := FND_API.g_ret_sts_error;
         AMS_Utility_PVT.error_message(
            'AMS_CAMP_END_BEF_CSCH_END',
            'SCHEDULE_DATE',
            FND_DATE.date_to_chardate(l_csch_rec.end_date)
         );
      ELSIF p_end_date < l_csch_rec.start_date THEN
         x_return_status := FND_API.g_ret_sts_error;
         AMS_Utility_PVT.error_message(
            'AMS_CAMP_END_BEF_CSCH_START',
            'SCHEDULE_DATE',
            FND_DATE.date_to_chardate(l_csch_rec.start_date)
         );
      END IF;
   END LOOP;

END check_camp_dates_vs_csch;


---------------------------------------------------------------------
-- PROCEDURE
--    handle_csch_source_code
--
-- HISTORY
--    11/01/99  holiu  Created.
---------------------------------------------------------------------
PROCEDURE handle_csch_source_code(
   p_source_code    IN  VARCHAR2,
   p_camp_id        IN  NUMBER,
   x_cascade_flag   OUT NOCOPY VARCHAR2,
   x_source_code    OUT NOCOPY VARCHAR2,
   x_return_status  OUT NOCOPY VARCHAR2
)
IS

   CURSOR c_camp IS
   SELECT cascade_source_code_flag,
          source_code,
          custom_setup_id,
          global_flag
     FROM ams_campaigns_vl
    WHERE campaign_id = p_camp_id;

   l_cascade_flag  VARCHAR2(1);
   l_source_code   VARCHAR2(30);
   l_setup_id      NUMBER;
   l_global_flag   VARCHAR2(1);

BEGIN

   x_source_code := p_source_code;
   x_return_status := FND_API.g_ret_sts_success;

   OPEN c_camp;
   FETCH c_camp INTO l_cascade_flag, l_source_code, l_setup_id, l_global_flag;
   IF c_camp%NOTFOUND THEN  -- campaign_id is invalid
      CLOSE c_camp;
      x_return_status := FND_API.g_ret_sts_error;
      AMS_Utility_PVT.error_message('AMS_CAMP_BAD_ID');
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_camp;

   x_cascade_flag := l_cascade_flag;

   IF l_cascade_flag = 'Y' THEN
      IF p_source_code IS NULL THEN
         x_source_code := l_source_code;
      ELSIF p_source_code <> l_source_code THEN
         x_return_status := FND_API.g_ret_sts_error;
         AMS_Utility_PVT.error_message('AMS_CSCH_CODE_NOT_CASCADE');
      END IF;
   ELSE
      IF p_source_code IS NULL THEN
         x_source_code := AMS_SourceCode_PVT.get_new_source_code(
            'CSCH', l_setup_id, l_global_flag);
      ELSIF AMS_SourceCode_PVT.is_source_code_unique(p_source_code) = FND_API.g_false
      THEN
         x_return_status := FND_API.g_ret_sts_error;
         AMS_Utility_PVT.error_message('AMS_CAMP_DUPLICATE_CODE');
      END IF;
   END IF;

END handle_csch_source_code;

-- 10/02/2002
-- Commented this proc because this method is not being used any where and it refers to
-- old AMS_CampaignSchedule_PVT which is no more there. Please refer Bug# 2605184
---------------------------------------------------------------------
-- PROCEDURE
--    check_csch_update
--
-- HISTORY
--    11/01/99  holiu  Created.
---------------------------------------------------------------------
-- PROCEDURE check_csch_update(
--    p_csch_rec       IN  AMS_CampaignSchedule_PVT.csch_rec_type,
--    x_return_status  OUT VARCHAR2
-- )
-- IS

--    l_cascade_flag  VARCHAR2(1);
--    l_source_code   VARCHAR2(30);
--    l_camp_id       NUMBER;
--    l_dummy         NUMBER;
--    l_msg_count     NUMBER;
--    l_msg_data      VARCHAR2(2000);

--    CURSOR c_source_code IS
--    SELECT 1
--      FROM ams_source_codes
--     WHERE source_code = p_csch_rec.source_code
--     AND active_flag = 'Y';

--    CURSOR c_csch IS
--    SELECT campaign_id, source_code
--      FROM ams_campaign_schedules
--     WHERE campaign_schedule_id = p_csch_rec.campaign_schedule_id;

--    CURSOR c_camp IS
--    SELECT cascade_source_code_flag
--      FROM ams_campaigns_vl
--     WHERE campaign_id = l_camp_id;

--    CURSOR c_list_header IS
--    SELECT 1
--      FROM ams_list_headers_all
--     WHERE arc_list_used_by = 'CSCH'
--       AND list_used_by_id = p_csch_rec.campaign_schedule_id
--       AND status_code <> 'NEW';

-- BEGIN

--    x_return_status := FND_API.g_ret_sts_success;

--    -- cannot update to null
--    IF p_csch_rec.source_code IS NULL THEN
--       FND_MESSAGE.set_name('AMS', 'AMS_CAMP_NO_SOURCE_CODE');
--       FND_MSG_PUB.add;
--    END IF;
--
--    -- query the campaign_id and the old source_code
--    OPEN c_csch;
--    FETCH c_csch INTO l_camp_id, l_source_code;
--    IF c_csch%NOTFOUND THEN
--       CLOSE c_csch;
--       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
--          FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
--          FND_MSG_PUB.add;
--       END IF;
--       RAISE FND_API.g_exc_error;
--    END IF;
--    CLOSE c_csch;

--    -- if source_code is not changed, return
--    IF p_csch_rec.source_code = FND_API.g_miss_char
--       OR p_csch_rec.source_code = l_source_code
--    THEN
--       RETURN;
--    END IF;

--    -- check if source code is cascaded from campaign
--    OPEN c_camp;
--    FETCH c_camp INTO l_cascade_flag;
--    CLOSE c_camp;
--    IF l_cascade_flag = 'Y' THEN
--       x_return_status := FND_API.g_ret_sts_error;
--       AMS_Utility_PVT.error_message('AMS_CSCH_CODE_NOT_CASCADE');
--       RETURN;
--    END IF;

--    -- check if the new source code is unique
--    OPEN c_source_code;
--    FETCH c_source_code INTO l_dummy;
--    CLOSE c_source_code;
--    IF l_dummy IS NOT NULL THEN
--       AMS_Utility_PVT.error_message('AMS_CAMP_DUPLICATE_CODE');
--       x_return_status := FND_API.g_ret_sts_error;
--       RETURN;
--    END IF;

--    -- cannot update source code if schedule has "old" list headers
--    OPEN c_list_header;
--    FETCH c_list_header INTO l_dummy;
--    CLOSE c_list_header;
--    IF l_dummy IS NOT NULL THEN
--       AMS_Utility_PVT.error_message('AMS_CSCH_UPDATE_SOURCE_CODE');
--       x_return_status := FND_API.g_ret_sts_error;
--       RETURN;
--    END IF;

--    AMS_SourceCode_PVT.revoke_sourcecode(
--       p_api_version        => 1.0,
--       p_init_msg_list      => FND_API.g_false,
--       p_commit             => FND_API.g_false,
--       p_validation_level   => FND_API.g_valid_level_full,

--       x_return_status      => x_return_status,
--       x_msg_count          => l_msg_count,
--       x_msg_data           => l_msg_data,

--       p_sourcecode         => l_source_code
--    );

--    IF x_return_status <> FND_API.g_ret_sts_success THEN
--       RAISE FND_API.g_exc_error;
--    END IF;

--    AMS_SourceCode_PVT.create_sourcecode(
--       p_api_version        => 1.0,
--       p_init_msg_list      => FND_API.g_false,
--       p_commit             => FND_API.g_false,
--       p_validation_level   => FND_API.g_valid_level_full,

--       x_return_status      => x_return_status,
--       x_msg_count          => l_msg_count,
--       x_msg_data           => l_msg_data,

--       p_sourcecode         => p_csch_rec.source_code,
--       p_sourcecode_for     => 'CSCH',
--       p_sourcecode_for_id  => p_csch_rec.campaign_schedule_id,
--       x_sourcecode_id      => l_dummy
--    );

--    IF x_return_status <> FND_API.g_ret_sts_success THEN
--       RAISE FND_API.g_exc_error;
--    END IF;

-- END check_csch_update;


---------------------------------------------------------------------
-- PROCEDURE
--    check_csch_camp_id
--
-- HISTORY
--    11/01/99  holiu  Created.
---------------------------------------------------------------------
PROCEDURE check_csch_camp_id(
   p_camp_id        IN  NUMBER,
   x_return_status  OUT NOCOPY VARCHAR2
)
IS

   CURSOR c_camp IS
   SELECT rollup_type, media_type_code
     FROM ams_campaigns_vl
    WHERE campaign_id = p_camp_id
      AND active_flag = 'Y';

   l_rollup_type  VARCHAR2(30);
   l_media_type   VARCHAR2(30);

BEGIN

   x_return_status := FND_API.g_ret_sts_success;
   OPEN c_camp;
   FETCH c_camp INTO l_rollup_type, l_media_type;
   IF c_camp%NOTFOUND THEN
      x_return_status := FND_API.g_ret_sts_error;
      AMS_Utility_PVT.error_message('AMS_CAMP_BAD_ID');
   ELSIF l_rollup_type <> 'ECAM' THEN
      x_return_status := FND_API.g_ret_sts_error;
      AMS_Utility_PVT.error_message('AMS_CSCH_NOT_EXEC_CAMP');
   ELSIF l_media_type = 'EVENTS' THEN
      x_return_status := FND_API.g_ret_sts_error;
      AMS_Utility_PVT.error_message('AMS_CSCH_MEDIA_IS_EVENT');
   END IF;
   CLOSE c_camp;

END check_csch_camp_id;


---------------------------------------------------------------------
-- PROCEDURE
--    check_csch_deliv_id
--
-- HISTORY
--    11/01/99  holiu  Created.
---------------------------------------------------------------------
PROCEDURE check_csch_deliv_id(
   p_deliv_id       IN  NUMBER,
   p_camp_id        IN  NUMBER,
   x_return_status  OUT NOCOPY VARCHAR2
)
IS

   l_dummy  NUMBER;

   CURSOR c_camp_deliv IS
   SELECT 1
     FROM ams_object_associations
    WHERE master_object_type = 'CAMP'
      AND master_object_id = p_camp_id
      AND using_object_type = 'DELV'
      AND using_object_id = p_deliv_id;

BEGIN

   x_return_status := FND_API.g_ret_sts_success;
   IF p_deliv_id IS NULL OR p_deliv_id = FND_API.g_miss_num THEN
      RETURN;
   END IF;

   OPEN c_camp_deliv;
   FETCH c_camp_deliv INTO l_dummy;
   IF c_camp_deliv%NOTFOUND THEN
      x_return_status := FND_API.g_ret_sts_error;
      AMS_Utility_PVT.error_message('AMS_CAMP_BAD_DELIV_ID');
   END IF;
   CLOSE c_camp_deliv;

END check_csch_deliv_id;


---------------------------------------------------------------------
-- PROCEDURE
--    check_csch_offer_id
--
-- HISTORY
--    11/01/99  holiu  Created.
---------------------------------------------------------------------
PROCEDURE check_csch_offer_id(
   p_offer_id       IN  NUMBER,
   p_camp_id        IN  NUMBER,
   x_return_status  OUT NOCOPY VARCHAR2
)
IS

   l_dummy  NUMBER;

   CURSOR c_camp_offer IS
   SELECT 1
     FROM ams_act_offers
    WHERE activity_offer_id = p_offer_id
      AND arc_act_offer_used_by = 'CAMP'
      AND act_offer_used_by_id = p_camp_id;

BEGIN

   x_return_status := FND_API.g_ret_sts_success;
   IF p_offer_id IS NULL OR p_offer_id = FND_API.g_miss_num THEN
      RETURN;
   END IF;

   OPEN c_camp_offer;
   FETCH c_camp_offer INTO l_dummy;
   IF c_camp_offer%NOTFOUND THEN
      x_return_status := FND_API.g_ret_sts_error;
      AMS_Utility_PVT.error_message('AMS_CAMP_BAD_OFFER_ID');
   END IF;
   CLOSE c_camp_offer;

END check_csch_offer_id;


---------------------------------------------------------------------
-- PROCEDURE
--    check_csch_dates_vs_camp
--
-- HISTORY
--    11/01/99  holiu  Created.
---------------------------------------------------------------------
PROCEDURE check_csch_dates_vs_camp(
   p_camp_id        IN  NUMBER,
   p_start_date     IN  DATE,
   p_end_date       IN  DATE,
   x_return_status  OUT NOCOPY VARCHAR2
)
IS

   l_api_name   CONSTANT VARCHAR2(30) := 'check_csch_dates_vs_camp';
   l_full_name  CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   CURSOR c_camp IS
   SELECT actual_exec_start_date,
          actual_exec_end_date
     FROM ams_campaigns_vl
    WHERE campaign_id = p_camp_id;

   l_camp_start_date  DATE;
   l_camp_end_date    DATE;

BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   OPEN c_camp;
   FETCH c_camp INTO l_camp_start_date, l_camp_end_date;
   IF c_camp%NOTFOUND THEN
      CLOSE c_camp;
      x_return_status := FND_API.g_ret_sts_error;
      AMS_Utility_PVT.error_message('AMS_CAMP_BAD_ID');
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_camp;

   IF p_start_date IS NOT NULL THEN
      IF l_camp_start_date IS NULL THEN
         x_return_status := FND_API.g_ret_sts_error;
         AMS_Utility_PVT.error_message('AMS_CAMP_PAR_START_IS_NULL');
      ELSIF p_start_date < l_camp_start_date THEN
         x_return_status := FND_API.g_ret_sts_error;
         AMS_Utility_PVT.error_message('AMS_CSCH_START_BEF_CAMP_START');
      ELSIF p_start_date > l_camp_end_date THEN
         x_return_status := FND_API.g_ret_sts_error;
         AMS_Utility_PVT.error_message('AMS_CSCH_START_AFT_CAMP_END');
      END IF;
   END IF;

   IF p_end_date IS NOT NULL THEN
      IF l_camp_end_date IS NULL THEN
         x_return_status := FND_API.g_ret_sts_error;
         AMS_Utility_PVT.error_message('AMS_CAMP_PAR_END_IS_NULL');
      ELSIF p_end_date > l_camp_end_date THEN
         x_return_status := FND_API.g_ret_sts_error;
         AMS_Utility_PVT.error_message('AMS_CSCH_END_AFT_CAMP_END');
      ELSIF p_end_date < l_camp_start_date THEN
         x_return_status := FND_API.g_ret_sts_error;
         AMS_Utility_PVT.error_message('AMS_CSCH_END_BEF_CAMP_START');
      END IF;
   END IF;

END check_csch_dates_vs_camp;


---------------------------------------------------------------------
-- PROCEDURE
--    activate_campaign
--
-- PURPOSE
--    Perform the following tasks when campaigns become active:
--    1. Change the show_campaign_flag of all other versions to 'N'.
--
-- History
--  19-Jun-2001   ptendulk   Added Where clause to Deactivate only same
--                           rollup type, ie. If the campaign get active,
--                           de activate only campaigns not program
--  27-Jun-2001   ptendulk   Added code to deactivate the rollup if the
--                           campaign is getting inactive.
--  30-Jul-2001   ptendulk   Commented city_id check
--  29-jan-2003   soagrawa   Fixed bug# 2764007
---------------------------------------------------------------------
PROCEDURE activate_campaign(
   p_campaign_id    IN  NUMBER
)
IS
   CURSOR c_camp_det IS
   SELECT A.campaign_id,DECODE(a.rollup_type,'RCAM','RCAM','CAMP')
   FROM   ams_campaigns_vl A, ams_campaigns_vl B
   WHERE  B.campaign_id = p_campaign_id
   AND    A.campaign_name = B.campaign_name
   -- AND    (A.city_id = B.city_id OR A.city_id IS NULL AND B.city_id IS NULL)
   AND    A.show_campaign_flag = 'Y'
   AND    A.campaign_id <> p_campaign_id
   -- Following line is added by ptendulk on 19-Jun-2001
   AND    A.rollup_type = B.rollup_type
   AND    a.parent_campaign_id IS NOT NULL ;

   l_camp_id   NUMBER ;
   l_rollup_type     VARCHAR2(30);
   l_return_status   VARCHAR2(30) ;
   l_msg_count       NUMBER ;
   l_msg_data        VARCHAR2(30) ;
BEGIN

   OPEN c_camp_det ;
   LOOP
      FETCH c_camp_det INTO l_camp_id, l_rollup_type ;
      EXIT WHEN c_camp_det%NOTFOUND ;
      -- Call the api to deactivate the parent

      AMS_ACTMETRIC_PUB.Invalidate_Rollup(
         p_api_version       => 1.0,

         x_return_status     => l_return_status,
         x_msg_count         => l_msg_count,
         x_msg_data          => l_msg_data,

         -- p_used_by_type      => 'CAMP',
         p_used_by_type      => l_rollup_type,
         p_used_by_id        => l_camp_id
        );
   END LOOP ;
   CLOSE c_camp_det ;

   -- soagrawa 29-jan-2003  bug# 2764007
   IF l_rollup_type <> 'RCAM'
   THEN
      UPDATE ams_campaigns_all_b
      SET    show_campaign_flag = 'N'
      WHERE  campaign_id IN(
                SELECT A.campaign_id
                FROM   ams_campaigns_vl A, ams_campaigns_vl B
                WHERE  B.campaign_id = p_campaign_id
                AND    A.campaign_name = B.campaign_name
                AND    (A.city_id = B.city_id OR A.city_id IS NULL AND B.city_id IS NULL)
                AND    A.show_campaign_flag = 'Y'
                AND    A.campaign_id <> p_campaign_id
                -- Following line is added by ptendulk on 19-Jun-2001
                AND    A.rollup_type = B.rollup_type
             );
   END IF;

END activate_campaign;


-----------------------------------------------------------------------
-- PROCEDURE
--    udpate_camp_status
--
-- HISTORY
--    06/26/00  holiu     Created.
--  05-Apr-2001 ptendulk  Modified business Rules.
--  20-May-2001 ptendulk  Pass RCAM to check_status_change proc for Programs
--                        Refer bug#1784156
--  16-Jun-2001 ptendulk  Added call to new api check_new_status_change for
--                        approvals
--  24-Sep-2001 ptendulk  Added the code to make private campaign public
--                        when the campaign goes active.
--  30-Oct-2001 ptendulk  Modified after request from gjoby for 0
--                        budget approvals
--  25-Oct-2002 soagrawa  Added code for automatic budget line approval enh# 2445453
-----------------------------------------------------------------------
PROCEDURE update_camp_status(
   p_campaign_id      IN  NUMBER,
   p_user_status_id   IN  NUMBER,
   p_budget_amount    IN  NUMBER,
   p_parent_id        IN  NUMBER
)
IS

   l_budget_exist      NUMBER;
   l_old_status_id     NUMBER;
   l_new_status_id     NUMBER;
   l_deny_status_id    NUMBER;
   l_object_version    NUMBER;
   l_approval_type     VARCHAR2(30);
   l_return_status     VARCHAR2(1);
   l_rollup_type       VARCHAR2(30);

   CURSOR c_old_status IS
   SELECT user_status_id, object_version_number,DECODE(rollup_type,'RCAM','RCAM','CAMP') rollup_type,
          status_code,custom_setup_id
   FROM   ams_campaigns_all_b
   WHERE  campaign_id = p_campaign_id;

   CURSOR c_budget_exist IS
   SELECT 1
   FROM   DUAL
   WHERE  EXISTS(
          SELECT 1
          FROM   ozf_act_budgets
          WHERE  arc_act_budget_used_by = 'CAMP'
          AND    act_budget_used_by_id = p_campaign_id);

   CURSOR c_parent IS
   SELECT   status_code
   FROM     ams_campaigns_all_b
   WHERE    campaign_id = p_parent_id ;
   l_status_code VARCHAR2(30);

   CURSOR c_child IS
   SELECT 1
   FROM   ams_campaigns_all_b
   WHERE  parent_campaign_id = p_campaign_id
   AND    status_code = 'ACTIVE' ;
   l_act_child_exist NUMBER;

   l_system_status_code VARCHAR2(30) := AMS_Utility_PVT.get_system_status_code(p_user_status_id) ;
   l_old_status_code    VARCHAR2(30) ;
   l_custom_setup_id    NUMBER ;
   l_msg_count          NUMBER ;
   l_msg_data           VARCHAR2(2000);
   l_start_wf_process   VARCHAR2(1);

BEGIN

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_Utility_PVT.debug_message('SONALI x');

   END IF;

   OPEN c_old_status;
   FETCH c_old_status INTO l_old_status_id, l_object_version, l_rollup_type, l_old_status_code,l_custom_setup_id ;
   CLOSE c_old_status;

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_Utility_PVT.debug_message('SONALI new '||l_system_status_code);

   END IF;
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message('SONALI old '||l_old_status_code);
   END IF;

   IF l_old_status_id = p_user_status_id THEN
      RETURN;
   END IF;

   -- Follwing code is modified by ptendulk on 16-Jun-2001
   -- The old procedure is replaced by new to check the type
   -- of the approval required as ams_object_attribute table is
   -- obsoleted now.
   AMS_Utility_PVT.check_new_status_change(
--      p_object_type      => 'CAMP',
      p_object_type      => l_rollup_type,
      p_object_id        => p_campaign_id,
      p_old_status_id    => l_old_status_id,
      p_new_status_id    => p_user_status_id,
      p_custom_setup_id  => l_custom_setup_id,
      x_approval_type    => l_approval_type,
      x_return_status    => l_return_status
   );

   --AMS_Utility_PVT.check_status_change(
   --    p_object_type      => 'CAMP',
   --   p_object_type      => l_rollup_type,
   --   p_object_id        => p_campaign_id,
   --   p_old_status_id    => l_old_status_id,
   --   p_new_status_id    => p_user_status_id,
   --   x_approval_type    => l_approval_type,
   --   x_return_status    => l_return_status
   --);

   IF l_return_status <> FND_API.g_ret_sts_success THEN
      RAISE FND_API.g_exc_error;
   END IF;

   -- Following lines of code is modified by ptendulk on 22-May-2001
   -- Check system status code instead of user status id.
   -- Campaign can not go active unless the program is active
   -- program - campaign 3
   IF p_parent_id IS NOT NULL
   -- AND p_user_status_id = 105 THEN
   AND l_system_status_code = 'ACTIVE' THEN
      OPEN c_parent ;
      FETCH c_parent INTO l_status_code ;
      CLOSE c_parent;

      IF l_status_code <> 'ACTIVE' THEN
         AMS_Utility_PVT.Error_Message('AMS_CAMP_PROG_ACTIVE_STAT');
         RAISE FND_API.g_exc_error;
      END IF ;
   END IF ;

   -- Can not cancell /Complete Program if the child campaign is Active
   -- Program Campaign Rules 4.
--   IF p_user_status_id = 106 OR
--      p_user_status_id = 111
   IF l_system_status_code = 'CANCELLED'
   THEN
      IF l_rollup_type = 'RCAM' THEN
         Cancel_Program(p_campaign_id);
         -- Cancel All the children associated to the program.
         IF (AMS_DEBUG_HIGH_ON) THEN

         AMS_Utility_PVT.Debug_Message('Cancel All the events');
         END IF;
         -- Call to cancel events modified by soagrawa on 15-feb-2002
         -- after gmadana modified event rules APIs for bug# 2218013
         --AMS_EvhRules_PVT.Cancel_All_Event(p_prog_id  => p_campaign_id );
         IF FND_API.g_false = AMS_EvhRules_PVT.Cancel_All_Event(p_prog_id  => p_campaign_id)
         THEN
            AMS_Utility_PVT.Error_Message('AMS_COMP_CANNOT_CANCEL');
            RAISE FND_API.g_exc_error;
         END IF;
         IF (AMS_DEBUG_HIGH_ON) THEN

         AMS_Utility_PVT.Debug_Message('After Cancel All the events');
         END IF;
      ELSE
         Cancel_Schedule(p_campaign_id);
      END IF ;

      --OPEN c_child;
      --FETCH c_child INTO l_act_child_exist;
      --CLOSE c_child;

      --IF l_act_child_exist IS NOT NULL THEN
      --   AMS_Utility_PVT.Error_Message('AMS_CAMP_CHILD_ACTIVE');
      --   RAISE FND_API.g_exc_error;
      --END IF ;
   ELSIF l_system_status_code = 'COMPLETED' THEN
      IF l_rollup_type = 'RCAM' THEN
         Complete_Program(p_campaign_id);
         AMS_EvhRules_PVT.Complete_All_Event(p_prog_id  => p_campaign_id );
      ELSE
         Complete_Schedule(p_campaign_id);
      END IF ;

   ELSIF l_system_status_code = 'CLOSED' THEN
      IF l_rollup_type <> 'RCAM' THEN
        Check_Close_Campaign(p_campaign_id);
      END IF;

   ELSIF l_system_status_code = 'ARCHIVED' THEN
      IF l_rollup_type = 'RCAM' THEN
         Archive_Campaigns(p_campaign_id) ;
      ELSE
         Archive_Schedules(p_campaign_id) ;
      END IF ;
   ELSIF l_system_status_code = 'ACTIVE' THEN
      IF l_rollup_type = 'RCAM' THEN
         IF l_old_status_code = 'NEW' THEN
            Activate_Campaigns(p_campaign_id) ;
         ELSIF l_old_status_code = 'ON_HOLD' THEN
            Hold_Campaigns(p_campaign_id,'ACTIVE') ;
         END IF;
      END IF ;
   ELSIF l_system_status_code = 'ON_HOLD' THEN
      IF l_rollup_type = 'RCAM' THEN
         Hold_Campaigns(p_campaign_id,'ON_HOLD') ;
      END IF ;
   END IF ;



   -- Budget Approval
   IF l_approval_type = 'BUDGET' THEN
      /*   Following code is commented by ptendulk on 30-Oct-2001
           for 0 budget approvals
      -- check if budget amount is specified
      IF p_budget_amount IS NULL THEN
         AMS_Utility_PVT.error_message('AMS_EVE_NO_BGT_AMT');
         RAISE FND_API.g_exc_error;
      END IF;

      -- check if there is any budget line
      OPEN c_budget_exist;
      FETCH c_budget_exist INTO l_budget_exist;
      CLOSE c_budget_exist;

      IF l_budget_exist IS NULL THEN
         AMS_Utility_PVT.error_message('AMS_EVE_NO_BGT_SRC');
         RAISE FND_API.g_exc_error;
      END IF;
      End of code commented by ptendulk
      */
      /* mayjain 22-Sep-2005 */
      AMS_Approval_PVT.Must_Preview(
         p_activity_id => p_campaign_id,
         p_activity_type => 'CAMP',
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
       /* mayjain 22-Sep-2005 */

      IF (l_start_wf_process = 'Y') -- If the user is not the approver
      THEN
         -- start budget approval process
         l_new_status_id := AMS_Utility_PVT.get_default_user_status(
            'AMS_CAMPAIGN_STATUS',
            'SUBMITTED_BA'
         );
         l_deny_status_id := AMS_Utility_PVT.get_default_user_status(
            'AMS_CAMPAIGN_STATUS',
            'DENIED_BA'
         );
         AMS_Approval_PVT.StartProcess(
            p_activity_type => 'CAMP',
            p_activity_id => p_campaign_id,
            p_approval_type => l_approval_type,
            p_object_version_number => l_object_version,
            p_orig_stat_id => l_old_status_id,
            p_new_stat_id => p_user_status_id,
            p_reject_stat_id => l_deny_status_id,
            p_requester_userid => AMS_Utility_PVT.get_resource_id(FND_GLOBAL.user_id),
            p_workflowprocess => 'AMS_APPROVAL',
            p_item_type => 'AMSAPRV'
         );
      ELSE -- If user equals approver
         IF (AMS_DEBUG_HIGH_ON) THEN
            AMS_Utility_PVT.Debug_Message('No need to start Workflow Process for Approval, Status Code ' || l_system_status_code );
         END IF;

         IF l_system_status_code = 'ACTIVE' AND l_rollup_type <> 'RCAM'
         THEN
            OZF_BudgetApproval_PVT.budget_request_approval(
                p_init_msg_list         => FND_API.G_FALSE
                , p_api_version           => 1.0
                , p_commit                => FND_API.G_False
                , x_return_status         => l_return_status
                , x_msg_count             => l_msg_count
                , x_msg_data              => l_msg_data
                , p_object_type           => 'CAMP'
                , p_object_id             => p_campaign_id
                --, x_status_code           =>
                );
            IF l_return_status = FND_API.G_RET_STS_ERROR THEN
               RAISE FND_API.G_EXC_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
         END IF;

         l_new_status_id := p_user_status_id;

      END IF; -- IF (l_start_wf_process = 'Y')
   -- Concept Approval
   ELSIF l_approval_type = 'THEME' THEN

      /* mayjain 22-Sep-2005 */
      AMS_Approval_PVT.Must_Preview(
         p_activity_id => p_campaign_id,
         p_activity_type => 'CAMP',
         p_approval_type => 'CONCEPT',
         p_act_budget_id => null,
         p_requestor_id => AMS_Utility_PVT.get_resource_id(FND_GLOBAL.user_id),
         x_must_preview => l_start_wf_process,
         x_return_status => l_return_status);

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
       /* mayjain 22-Sep-2005 */

      IF (l_start_wf_process = 'Y') -- If the user is not the approver
      THEN
         l_new_status_id := AMS_Utility_PVT.get_default_user_status(
            'AMS_CAMPAIGN_STATUS',
            'SUBMITTED_TA'
         );
         l_deny_status_id := AMS_Utility_PVT.get_default_user_status(
            'AMS_CAMPAIGN_STATUS',
            'DENIED_TA'
         );
         AMS_Approval_PVT.StartProcess(
            p_activity_type => 'CAMP',
            p_activity_id => p_campaign_id,
            p_approval_type => 'CONCEPT',
            p_object_version_number => l_object_version,
            p_orig_stat_id => l_old_status_id,
            p_new_stat_id => p_user_status_id,
            p_reject_stat_id => l_deny_status_id,
            p_requester_userid => AMS_Utility_PVT.get_resource_id(FND_GLOBAL.user_id),
            p_workflowprocess => 'AMS_CONCEPT_APPROVAL',
            p_item_type => 'AMSAPRV'
         );

      ELSE -- If user equals approver
         l_new_status_id := p_user_status_id;
      END IF; -- IF (l_start_wf_process = 'Y')

   ELSE
      -- Following budget line api call added by soagrawa on 25-oct-2002
      -- for enhancement # 2445453

      IF l_system_status_code = 'ACTIVE' AND l_rollup_type <> 'RCAM'
      THEN
         OZF_BudgetApproval_PVT.budget_request_approval(
             p_init_msg_list         => FND_API.G_FALSE
             , p_api_version           => 1.0
             , p_commit                => FND_API.G_False
             , x_return_status         => l_return_status
             , x_msg_count             => l_msg_count
             , x_msg_data              => l_msg_data
             , p_object_type           => 'CAMP'
             , p_object_id             => p_campaign_id
             --, x_status_code           =>
             );
         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      END IF;

      l_new_status_id := p_user_status_id;
   END IF;

   update_status(p_campaign_id      =>   p_campaign_id,
                 p_new_status_id    =>   l_new_status_id,
                 p_new_status_code  =>   AMS_Utility_PVT.get_system_status_code(l_new_status_id)
                                 ) ;


   /*  Following code is commented by ptendulk on 08-Oct-2001
       Use the common update api to update the campaign
   UPDATE ams_campaigns_all_b
   SET    user_status_id = l_new_status_id,
          status_code = AMS_Utility_PVT.get_system_status_code(l_new_status_id),
          status_date = SYSDATE
   WHERE  campaign_id = p_campaign_id;

   IF l_system_status_code = 'ACTIVE' AND
      l_new_status_id = p_user_status_id
   THEN
      -- Following code is added by ptendulk on 24-Sep-2001
      -- Make the campaign Non confidential when it goes live.
      UPDATE ams_campaigns_all_b
      SET    private_flag = 'N'
      WHERE  campaign_id = p_campaign_id ;

      Activate_Campaign(p_campaign_id => p_campaign_id );
   END IF ;
     */


END update_camp_status;


---------------------------------------------------------------------
-- PROCEDURE
--    push_source_code
--
-- HISTORY
--    11/01/99  holiu  Created.
---------------------------------------------------------------------
PROCEDURE push_source_code(
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

   AMS_SourceCode_PVT.create_sourcecode(
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

END push_source_code;


-----------------------------------------------------------------------
-- FUNCTION
--    get_parent_media_type
--
-- HISTORY
--    11/01/99  holiu  Created.
-----------------------------------------------------------------------
FUNCTION get_parent_media_type(
   p_parent_id     IN  NUMBER
)
RETURN VARCHAR2
IS

   l_parent_id    NUMBER;
   l_media_type   VARCHAR2(30);

   CURSOR c_parent IS
   SELECT parent_campaign_id,
          media_type_code
     FROM ams_campaigns_vl
    WHERE campaign_id = l_parent_id;

BEGIN

   l_parent_id := p_parent_id;
   OPEN c_parent;
   FETCH c_parent INTO l_parent_id, l_media_type;
   CLOSE c_parent;

   IF l_media_type IS NOT NULL THEN
      RETURN l_media_type;
   ELSIF l_parent_id IS NULL THEN
      RETURN NULL;
   ELSE
      RETURN get_parent_media_type(l_parent_id);
   END IF;

END get_parent_media_type;


-----------------------------------------------------------------------
-- FUNCTION
--    check_camp_parent
--
-- PURPOSE
--    Check if a campaign can be the parent of another campaign.
-----------------------------------------------------------------------
FUNCTION check_camp_parent(
   p_camp_id     IN  NUMBER,
   p_parent_id   IN  NUMBER
)
RETURN VARCHAR2
IS

   l_camp_id   NUMBER;

   CURSOR c_parent IS
   SELECT parent_campaign_id
   FROM   ams_campaigns_vl
   WHERE  campaign_id = l_camp_id;

BEGIN

   l_camp_id := p_parent_id;

   WHILE l_camp_id IS NOT NULL LOOP
      IF l_camp_id = p_camp_id THEN
         RETURN FND_API.g_false;
      END IF;

      OPEN c_parent;
      FETCH c_parent INTO l_camp_id;
      IF c_parent%NOTFOUND THEN
         CLOSE c_parent;
         RETURN FND_API.g_false;
      END IF;
      CLOSE c_parent;
   END LOOP;

   RETURN FND_API.g_true;

END check_camp_parent;


-----------------------------------------------------------------------
-- FUNCTION
--    check_camp_attribute
--
-- HISTORY
--    11/01/99  holiu  Create.
--    09/14/99  holiu  Rewrite.
-----------------------------------------------------------------------
FUNCTION check_camp_attribute(
   p_camp_id     IN  NUMBER,
   p_attribute   IN  VARCHAR2
)
RETURN VARCHAR2
IS

   l_dummy  NUMBER;

   CURSOR c_object_attr IS
   SELECT 1
     FROM ams_object_attributes
    WHERE object_type = 'CAMP'
      AND object_id = p_camp_id
      AND object_attribute = p_attribute;

BEGIN

   OPEN c_object_attr;
   FETCH c_object_attr INTO l_dummy;
   CLOSE c_object_attr;

   IF l_dummy IS NULL THEN
      RETURN FND_API.g_false;
   ELSE
      RETURN FND_API.g_true;
   END IF;

END check_camp_attribute;

--=======================================================================
-- PROCEDURE
--    Convert_Camp_Currency
-- NOTES
--    This procedure is created to convert the transaction currency into
--    functional currency.
-- HISTORY
--    09/27/2000    PTENDULK   Created.
--=======================================================================
PROCEDURE Convert_Camp_Currency(
   p_tc_curr     IN    VARCHAR2,
   p_tc_amt      IN    NUMBER,
   x_fc_curr     OUT NOCOPY   VARCHAR2,
   x_fc_amt      OUT NOCOPY   NUMBER
)
IS
    L_FUNC_CURR_PROF  CONSTANT VARCHAR2(30) := 'AMS_DEFAULT_CURR_CODE';
    l_curr_code VARCHAR2(240) ;
    l_return_status VARCHAR2(30);
BEGIN
    l_curr_code := FND_PROFILE.Value(L_FUNC_CURR_PROF);
    IF l_curr_code IS NULL THEN
        l_curr_code := 'USD' ;
    END IF ;

    AMS_Utility_PVT.Convert_Currency(
        x_return_status    =>  l_return_status ,
        p_from_currency    =>  p_tc_curr,
        p_to_currency      =>  l_curr_code,
        p_from_amount      =>  p_tc_amt,
        x_to_amount        =>  x_fc_amt
     );

   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.g_exc_error;
   END IF;

   x_fc_curr := l_curr_code ;

END Convert_Camp_Currency;

--=======================================================================
-- PROCEDURE
--    Get_Camp_Child_Count
-- NOTES
--    This function is created to return the child count given a campaign
--    id . It is used to tune Campaign Hierarchy tree.
--
-- HISTORY
--    04-Feb-2001    PTENDULK   Created.
--=======================================================================
FUNCTION Get_Camp_Child_Count(   p_campaign_id IN    VARCHAR2 )
   RETURN NUMBER
IS
   l_count NUMBER ;

   CURSOR c_child IS
   SELECT COUNT(campaign_id)
   FROM   ams_campaigns_vl
   WHERE  parent_campaign_id = p_campaign_id
   AND    active_flag = 'Y'
   AND    private_flag = 'N'
   AND    show_campaign_flag = 'Y' ;

BEGIN
   OPEN  c_child ;
   FETCH c_child INTO l_count ;
   CLOSE c_child ;

   RETURN l_count ;

END Get_Camp_Child_Count ;


--=====================================================================
-- PROCEDURE
--    Update_Owner
--
-- PURPOSE
--    The api is created to update the owner of the campaign from the
--    access table if the owner is changed in update.
--
--    Algorithm for CSCH access list manipulation
--     I. For each CSCH of the CAMP do the following:
--        1. Is old campaign owner the same as the schedule owner?
--             Yes:
--                Is new campaign owner in the access list of the schedule
--                  Yes:   do nothing
--                  No:    Add new campaign owner to access list of schedule
--             No:
--                Is old campaign owner in the access list of the schedule
--                  Yes:   Delete access from schedule access list for old campaign owner
--                  No:    Do nothing
--                Is new campaign owner in the access list of the schedule
--                  Yes:   Do nothing
--                  No:    Add new campaign owner to access list of schedule
--
--
-- HISTORY
--    04-Mar-2001  ptendulk    Created.
--    07-Jun-2002  soagrawa    Modified code. Now manipulating CSCH access list
--                             if campaign owner changes. Refer to algorithm above.
--                             This is for bug# 2406677
--=====================================================================
PROCEDURE Update_Owner(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,
   p_object_type       IN  VARCHAR2 := NULL ,
   p_campaign_id       IN  NUMBER,
   p_owner_id          IN  NUMBER   )
IS
   CURSOR c_owner IS
   SELECT owner_user_id
   FROM   ams_campaigns_all_b
   WHERE  campaign_id = p_campaign_id ;

   CURSOR c_schedules IS
   SELECT *
   FROM   ams_campaign_schedules_vl
   WHERE  campaign_id = p_campaign_id;

   CURSOR c_access_csch_det(p_schedule_id NUMBER, p_owner NUMBER) IS
   SELECT *
   FROM ams_act_access
   WHERE arc_act_access_to_object = 'CSCH'
   AND   user_or_role_id = p_owner
   AND   arc_user_or_role_type = 'USER'
   AND   act_access_to_object_id = p_schedule_id;

   c_schedule_rec          c_schedules%ROWTYPE;
   c_schedule_access_rec   c_access_csch_det%ROWTYPE;

   l_access_rec   AMS_Access_Pvt.access_rec_type ;
   l_dummy_id     NUMBER ;

   l_old_owner      NUMBER ;

BEGIN
   OPEN c_owner ;
   FETCH c_owner INTO l_old_owner ;
   IF c_owner%NOTFOUND THEN
      CLOSE c_owner;
      AMS_Utility_Pvt.Error_Message('AMS_API_RECORD_NOT_FOUND');
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_owner ;

   IF p_owner_id <> l_old_owner THEN
        AMS_Access_PVT.update_object_owner(
           p_api_version       => p_api_version,
           p_init_msg_list     => p_init_msg_list,
           p_commit            => p_commit,
           p_validation_level  => p_validation_level,
           x_return_status     => x_return_status,
           x_msg_count         => x_msg_count,
           x_msg_data          => x_msg_data,
           p_object_type       => nvl(p_object_type,'CAMP'),
           p_object_id         => p_campaign_id,
           p_resource_id       => p_owner_id,
           p_old_resource_id   => l_old_owner
        );

         IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

         -- Fetch all the schedules for the campaign
         OPEN c_schedules;
         LOOP
            FETCH c_schedules INTO c_schedule_rec;
            EXIT WHEN c_schedules%NOTFOUND ;

            -- 1. Is old campaign owner the same as the schedule owner?
            IF l_old_owner = c_schedule_rec.owner_user_id
            THEN
                  --  Yes:

                  -- Is new campaign owner in the access list of the schedule
                  OPEN c_access_csch_det(c_schedule_rec.schedule_id, p_owner_id);
                  FETCH c_access_csch_det INTO c_schedule_access_rec;
                  -- Yes:   do nothing
                  IF c_access_csch_det%NOTFOUND THEN
                  -- No:    Add new campaign owner to access list of schedule

                        -- Create Access
                        l_access_rec.act_access_to_object_id := c_schedule_rec.schedule_id  ;
                        l_access_rec.arc_act_access_to_object := 'CSCH' ;
                        l_access_rec.owner_flag := 'N' ;
                        l_access_rec.user_or_role_id := p_owner_id;
                        l_access_rec.arc_user_or_role_type := 'USER' ;
                        l_access_rec.delete_flag := 'N';
                        l_access_rec.admin_flag := 'Y';


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
                           CLOSE c_schedules;
                           RAISE FND_API.G_EXC_ERROR;
                        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                           CLOSE c_access_csch_det;
                           CLOSE c_schedules;
                           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                        END IF;

                  END IF;
                  CLOSE c_access_csch_det ;

            ELSE
                  -- No:

                  -- Is old campaign owner in the access list of the schedule
                  OPEN c_access_csch_det(c_schedule_rec.schedule_id, l_old_owner);
                  FETCH c_access_csch_det INTO c_schedule_access_rec;
                  IF c_access_csch_det%NOTFOUND THEN
                        -- No:    Do nothing
                        NULL;
                  ELSE
                        -- Yes:   Delete access from schedule access list for old campaign owner

                        Ams_Access_pvt.delete_access(
                              p_api_version       => p_api_version,
                              p_init_msg_list     => p_init_msg_list,
                              p_commit            => p_commit,
                              p_validation_level  => p_validation_level,

                              x_return_status     => x_return_status,
                              x_msg_count         => x_msg_count,
                              x_msg_data          => x_msg_data,

                              p_access_id         => c_schedule_access_rec.activity_access_id,
                              p_object_version    => c_schedule_access_rec.object_version_number
                           );
                        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                           CLOSE c_access_csch_det;
                           CLOSE c_schedules;
                           RAISE FND_API.G_EXC_ERROR;
                        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                           CLOSE c_access_csch_det;
                           CLOSE c_schedules;
                           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                        END IF;

                  END IF;
                  CLOSE c_access_csch_det;



                  -- Is new campaign owner in the access list of the schedule
                  OPEN c_access_csch_det(c_schedule_rec.schedule_id, p_owner_id);
                  FETCH c_access_csch_det INTO c_schedule_access_rec;
                  -- Yes:   do nothing
                  IF c_access_csch_det%NOTFOUND THEN
                  -- No:    Add new campaign owner to access list of schedule

                        -- Create Access
                        l_access_rec.act_access_to_object_id := c_schedule_rec.schedule_id  ;
                        l_access_rec.arc_act_access_to_object := 'CSCH' ;
                        l_access_rec.owner_flag := 'N' ;
                        l_access_rec.user_or_role_id := p_owner_id;
                        l_access_rec.arc_user_or_role_type := 'USER' ;
                        l_access_rec.delete_flag := 'N';
                        l_access_rec.admin_flag := 'Y';


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
                           CLOSE c_schedules;
                           RAISE FND_API.G_EXC_ERROR;
                        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                           CLOSE c_access_csch_det;
                           CLOSE c_schedules;
                           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                        END IF;

                  END IF;
                  CLOSE c_access_csch_det ;


            END IF;
         END LOOP;
         CLOSE c_schedules;
   END IF;

END Update_Owner ;

-----------------------------------------------------------------------
-- PROCEDURE
--    validate_event
--
-- PURPOSE
--    Validate the realted event. Check the foreign key against the
--    event tables depending on the event_type passed
--
-- NOTES
-- HISTORY
--    12-Apr-2001  rrajesh    Created.
-----------------------------------------------------------------------
PROCEDURE validate_realted_event(
   p_related_event_id      IN  NUMBER,
   p_related_event_type    IN  VARCHAR2,
   x_return_status         OUT NOCOPY VARCHAR2
) IS

   CURSOR c_event IS
   SELECT event_header_id
   FROM   ams_event_headers_all_b
   WHERE  event_header_id = p_related_event_id ;

   CURSOR c_schedule_event IS
   SELECT event_offer_id
   FROM   ams_event_offers_all_b
   WHERE  event_offer_id = p_related_event_id
   --AND    event_standalone_flag = 'N';
   AND event_object_type = 'EVEO';

   CURSOR c_one_off_event IS
   SELECT event_offer_id
   FROM   ams_event_offers_all_b
   WHERE  event_offer_id = p_related_event_id
   --AND    event_standalone_flag = 'Y';
   AND event_object_type = 'EONE';

   l_tmpEvent NUMBER;

BEGIN

   IF p_related_event_type = 'EVEH' THEN
      OPEN c_event;
      FETCH c_event INTO l_tmpEvent;
      IF c_event%NOTFOUND THEN
         CLOSE c_event;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
      CLOSE c_event;
   ELSIF p_related_event_type = 'EVEO' THEN
     OPEN c_schedule_event;
     FETCH c_schedule_event INTO l_tmpEvent;
     IF c_schedule_event%NOTFOUND THEN
        CLOSE c_schedule_event ;
        x_return_status := FND_API.g_ret_sts_error;
        RETURN;
     END IF;
     CLOSE c_schedule_event ;
   ELSIF p_related_event_type = 'EONE' THEN
     OPEN c_one_off_event;
     FETCH c_one_off_event INTO l_tmpEvent;
     IF c_one_off_event%NOTFOUND THEN
     CLOSE c_one_off_event;
        x_return_status := FND_API.g_ret_sts_error;
        RETURN;
     END IF;
     CLOSE c_one_off_event;
   END IF;
END validate_realted_event;

-----------------------------------------------------------------------
-- PROCEDURE
--    Update_Related_Source_Code
--
-- PURPOSE
--    Update the source code of realted event.
--
-- NOTES
-- HISTORY
--    12-Apr-2001  rrajesh    Created.
-----------------------------------------------------------------------

PROCEDURE Update_Related_Source_Code(
   p_source_code                   IN  VARCHAR2,
   p_source_code_for_id            IN  NUMBER,
   p_source_code_for               IN  VARCHAR2,
   p_related_source_code           IN  VARCHAR2,
   p_related_source_code_for_id    IN  NUMBER,
   p_related_source_code_for       IN  VARCHAR2,
   x_return_status                 OUT NOCOPY VARCHAR2
) IS

   CURSOR c_sc_from_source_codes IS
      SELECT source_code_id
      FROM ams_source_codes
      WHERE  source_code = p_source_code
      AND source_code_for_id = p_source_code_for_id
      AND arc_source_code_for = p_source_code_for;

   l_return_status  VARCHAR2(1);
   l_sourcecode_id  NUMBER;

BEGIN
   OPEN c_sc_from_source_codes;
   FETCH c_sc_from_source_codes INTO l_sourcecode_id;
   IF c_sc_from_source_codes%NOTFOUND THEN
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

   AMS_SourceCode_PVT.modify_sourcecode(
                      p_source_code  =>  p_source_code,
                      p_object_type => p_source_code_for,
                      p_object_id => p_source_code_for_id,
                      p_sourcecode_id => l_sourcecode_id,
                      p_related_sourcecode => p_related_source_code,
                      p_releated_sourceobj => p_related_source_code_for,
                      p_related_sourceid => p_related_source_code_for_id,
                      x_return_status => l_return_status
   );

END Update_Related_Source_Code;

-- PROCEDURE
--    Archive_Schedules
--
-- PURPOSE
--    Archive all the schedules associated to the campaign.
--
-- NOTES
-- HISTORY
--    22-May-2001  ptendulk    Created.
-----------------------------------------------------------------------

PROCEDURE Archive_Schedules(
   p_campaign_id                   IN  NUMBER
   ) IS

   CURSOR c_schedule IS
      SELECT schedule_id , object_version_number
      FROM ams_campaign_schedules_b
      WHERE  campaign_id = p_campaign_id
      AND (status_code = 'COMPLETED' OR status_code = 'CANCELLED') ;

   l_schedule_id     NUMBER ;
   l_obj_version     NUMBER ;
   l_user_status_id  NUMBER := AMS_Utility_PVT.get_default_user_status('AMS_CAMPAIGN_SCHEDULE_STATUS','ARCHIVED');

BEGIN

   OPEN c_schedule ;
   LOOP
      FETCH c_schedule INTO l_schedule_id, l_obj_version;
      EXIT WHEN c_schedule%NOTFOUND ;

      UPDATE   ams_campaign_schedules_b
      SET      status_code = 'ARCHIVED',
               user_status_id = l_user_status_id ,
               status_date = SYSDATE ,
               object_version_number = l_obj_version + 1
      WHERE    schedule_id = l_schedule_id
      AND      object_version_number = l_obj_version ;

      IF (SQL%NOTFOUND) THEN
         CLOSE c_schedule ;
         AMS_Utility_PVT.Error_Message('AMS_API_RECORD_NOT_FOUND');
         RAISE FND_API.g_exc_error;
      END IF;

   END LOOP ;
   CLOSE c_schedule ;


END Archive_Schedules;

-- PROCEDURE
--    Archive_Campaigns
--
-- PURPOSE
--    Archive all the Programs/Campaigns associated to the Program
--
-- NOTES
-- HISTORY
--    22-May-2001  ptendulk    Created.
-----------------------------------------------------------------------

PROCEDURE Archive_Campaigns(
   p_program_id                   IN  NUMBER
   ) IS

   CURSOR c_campaign IS
      SELECT campaign_id , object_version_number,rollup_type
      FROM ams_campaigns_all_b
      WHERE  parent_campaign_id = p_program_id
      AND (status_code = 'COMPLETED' OR status_code = 'CANCELLED') ;

   l_campaign_id        NUMBER ;
   l_obj_version        NUMBER ;
   l_rollup_type        VARCHAR2(30) ;
   l_program_status_id  NUMBER := AMS_Utility_PVT.get_default_user_status('AMS_PROGRAM_STATUS','ARCHIVED');
   l_campaign_status_id NUMBER := AMS_Utility_PVT.get_default_user_status('AMS_CAMPAIGN_STATUS','ARCHIVED');

BEGIN

   OPEN c_campaign ;
   LOOP
      FETCH c_campaign INTO l_campaign_id, l_obj_version, l_rollup_type ;
      EXIT WHEN c_campaign%NOTFOUND ;

      IF l_rollup_type = 'RCAM' THEN
         Archive_Campaigns(l_campaign_id) ;
         UPDATE ams_campaigns_all_b
         SET      status_code = 'ARCHIVED',
                  user_status_id = l_program_status_id ,
                  status_date = SYSDATE ,
                  object_version_number = l_obj_version + 1
         WHERE    campaign_id = l_campaign_id
         AND      object_version_number = l_obj_version ;
      ELSE
         Archive_Schedules(l_campaign_id) ;

         UPDATE   ams_campaigns_all_b
         SET      status_code = 'ARCHIVED',
                  user_status_id = l_campaign_status_id ,
                  status_date = SYSDATE ,
                  object_version_number = l_obj_version + 1
         WHERE    campaign_id = l_campaign_id
         AND      object_version_number = l_obj_version ;

         IF (SQL%NOTFOUND) THEN
            CLOSE c_campaign ;
            AMS_Utility_PVT.Error_Message('AMS_API_RECORD_NOT_FOUND');
            RAISE FND_API.g_exc_error;
         END IF;
      END IF;
   END LOOP ;
   CLOSE c_campaign ;


END Archive_Campaigns;

-- PROCEDURE
--    Activate_Campaigns
--
-- PURPOSE
--    Activate all the Campaigns associated to the Program
--
-- NOTES
-- HISTORY
--    22-May-2001  ptendulk    Created.
-----------------------------------------------------------------------

PROCEDURE Activate_Campaigns(
   p_program_id                   IN  NUMBER
   ) IS

   CURSOR c_campaign IS
      SELECT campaign_id , object_version_number,rollup_type
      FROM ams_campaigns_all_b
      WHERE  parent_campaign_id = p_program_id
      AND status_code = DECODE(rollup_type,'RCAM','NEW','AVAILABLE') ;

   l_campaign_id        NUMBER ;
   l_obj_version        NUMBER ;
   l_rollup_type        VARCHAR2(30) ;
   l_program_status_id  NUMBER := AMS_Utility_PVT.get_default_user_status('AMS_PROGRAM_STATUS','ACTIVE');
   l_campaign_status_id NUMBER := AMS_Utility_PVT.get_default_user_status('AMS_CAMPAIGN_STATUS','ACTIVE');

BEGIN

   OPEN c_campaign ;
   LOOP
      FETCH c_campaign INTO l_campaign_id, l_obj_version, l_rollup_type ;
      EXIT WHEN c_campaign%NOTFOUND ;

      IF l_rollup_type = 'RCAM' THEN
         Activate_Campaigns(l_campaign_id) ;
         UPDATE ams_campaigns_all_b
         SET      status_code = 'ACTIVE',
                  user_status_id = l_program_status_id ,
                  status_date = SYSDATE ,
                  object_version_number = l_obj_version + 1
         WHERE    campaign_id = l_campaign_id
         AND      object_version_number = l_obj_version ;
      ELSE
         UPDATE   ams_campaigns_all_b
         SET      status_code = 'ACTIVE',
                  user_status_id = l_campaign_status_id ,
                  status_date = SYSDATE ,
                  object_version_number = l_obj_version + 1
         WHERE    campaign_id = l_campaign_id
         AND      object_version_number = l_obj_version ;

         IF (SQL%NOTFOUND) THEN
            CLOSE c_campaign ;
            AMS_Utility_PVT.Error_Message('AMS_API_RECORD_NOT_FOUND');
            RAISE FND_API.g_exc_error;
         END IF;
      END IF;
   END LOOP ;
   CLOSE c_campaign ;


END Activate_Campaigns;

--==========================================================================
-- PROCEDURE
--    Hold_Campaigns
--
-- PURPOSE
--    Keep all the Campaigns/programs associated to the Program
--    on hold.
--
-- NOTES
-- HISTORY
--    23-May-2001  ptendulk    Created.
--==========================================================================

PROCEDURE Hold_Campaigns(
   p_program_id            IN  NUMBER,
   p_system_status_code    IN  VARCHAR2
   ) IS

   CURSOR c_campaign IS
      SELECT campaign_id, object_version_number, rollup_type
      FROM ams_campaigns_all_b
      WHERE  parent_campaign_id = p_program_id
      AND status_code = DECODE(p_system_status_code,'ACTIVE','ON_HOLD','ACTIVE') ;

   l_campaign_id        NUMBER ;
   l_obj_version        NUMBER ;
   l_rollup_type        VARCHAR2(30) ;
   l_program_status_id  NUMBER := AMS_Utility_PVT.get_default_user_status('AMS_PROGRAM_STATUS',p_system_status_code);
   l_campaign_status_id NUMBER := AMS_Utility_PVT.get_default_user_status('AMS_CAMPAIGN_STATUS',p_system_status_code);

BEGIN

   OPEN c_campaign ;
   LOOP
      FETCH c_campaign INTO l_campaign_id, l_obj_version, l_rollup_type ;
      EXIT WHEN c_campaign%NOTFOUND ;

      IF l_rollup_type = 'RCAM' THEN
         Hold_Campaigns(l_campaign_id,p_system_status_code) ;
         UPDATE ams_campaigns_all_b
         SET      status_code = p_system_status_code,
                  user_status_id = l_program_status_id ,
                  status_date = SYSDATE ,
                  object_version_number = l_obj_version + 1
         WHERE    campaign_id = l_campaign_id
         AND      object_version_number = l_obj_version ;
      ELSE
         UPDATE   ams_campaigns_all_b
         SET      status_code = p_system_status_code,
                  user_status_id = l_campaign_status_id ,
                  status_date = SYSDATE ,
                  object_version_number = l_obj_version + 1
         WHERE    campaign_id = l_campaign_id
         AND      object_version_number = l_obj_version ;

         IF (SQL%NOTFOUND) THEN
            CLOSE c_campaign ;
            AMS_Utility_PVT.Error_Message('AMS_API_RECORD_NOT_FOUND');
            RAISE FND_API.g_exc_error;
         END IF;
      END IF;
   END LOOP ;
   CLOSE c_campaign ;


END Hold_Campaigns;

--==========================================================================
-- PROCEDURE
--    Cancel_Schedule
--
-- PURPOSE
--    Cancels all the schedules associated to the campaign. If the status
--    order rules does not permit it, it will error out.
--
-- NOTES
-- HISTORY
--    09-Jul-2001  ptendulk    Created.
--    15-feb-2002  soagrawa    Logic modified by  soagrawa to fix bug# 2218013
--                             Before: Cancel a program => cancel all components
--                                     Cancel a campaign => cancel all schedules
--                             Now:    Cancel only if children are cancelled/archived
--==========================================================================

/*
PROCEDURE Cancel_Schedule(p_campaign_id   IN  NUMBER) IS

   CURSOR c_schedule IS
      SELECT schedule_id,object_version_number,status_code
      FROM ams_campaign_schedules_b
      WHERE  campaign_id = p_campaign_id
      AND status_code <> 'CANCELLED' ;

   l_schedule_id        NUMBER ;
   l_obj_version        NUMBER ;
   l_status_code        VARCHAR2(30) ;
   l_status_id  NUMBER := AMS_Utility_PVT.get_default_user_status('AMS_CAMPAIGN_SCHEDULE_STATUS','CANCELLED');

BEGIN

   OPEN c_schedule ;
   LOOP
      FETCH c_schedule INTO l_schedule_id,l_obj_version,l_status_code ;
      EXIT WHEN c_schedule%NOTFOUND ;
      IF FND_API.G_TRUE = AMS_Utility_PVT.Check_Status_Change('AMS_CAMPAIGN_SCHEDULE_STATUS',l_status_code,'CANCELLED') THEN
         -- Can cancel the schedule
         UPDATE ams_campaign_schedules_b
         SET    status_code = 'CANCELLED',
                status_date = SYSDATE,
                user_status_id = l_status_id,
                object_version_number = object_version_number + 1
         WHERE  schedule_id = l_schedule_id
         AND    object_version_number = l_obj_version ;

         IF (SQL%NOTFOUND) THEN
            CLOSE c_schedule ;
            AMS_Utility_PVT.Error_Message('AMS_API_RECORD_NOT_FOUND');
            RAISE FND_API.g_exc_error;
         END IF;
      ELSE -- Can not cancel the schedule as the status is can not go to cancel from current status
         CLOSE c_schedule;
         AMS_Utility_PVT.Error_Message('AMS_CSCH_CANNOT_CANCEL');
         RAISE FND_API.g_exc_error;
      END IF ;

   END LOOP;
   CLOSE c_schedule;


END Cancel_Schedule;
*/


PROCEDURE Cancel_Schedule(p_campaign_id   IN  NUMBER) IS

   CURSOR c_schedule IS
      SELECT count(*)
      FROM ams_campaign_schedules_b
      WHERE  campaign_id = p_campaign_id
      AND status_code <> 'CANCELLED'
      AND status_code <> 'ARCHIVED';

   l_schedule_count     NUMBER;
   -- l_schedule_id        NUMBER ;
   -- l_obj_version        NUMBER ;
   -- l_status_code        VARCHAR2(30) ;
   -- l_status_id  NUMBER := AMS_Utility_PVT.get_default_user_status('AMS_CAMPAIGN_SCHEDULE_STATUS','CANCELLED');

BEGIN

   OPEN  c_schedule ;
   FETCH c_schedule INTO l_schedule_count;
   CLOSE c_schedule ;

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_Utility_PVT.debug_message('SONALI: l_schedule_count is *' || l_schedule_count ||'*');

   END IF;
   IF l_schedule_count > 0
   THEN
         -- cannot cancel
            AMS_Utility_PVT.Error_Message('AMS_CSCH_CANNOT_CANCEL');
            RAISE FND_API.g_exc_error;
   /*
   ELSE
         -- ok cancel
         UPDATE ams_campaigns_all_b
         SET      status_code = 'CANCELLED',
                  user_status_id = l_program_status_id ,
                  status_date = SYSDATE ,
                  -- object_version_number = l_obj_version + 1
         WHERE    campaign_id = l_campaign_id ;
         --AND      object_version_number = l_obj_version ;
         IF (SQL%NOTFOUND) THEN
            CLOSE c_campaign ;
            AMS_Utility_PVT.Error_Message('AMS_API_RECORD_NOT_FOUND');
            RAISE FND_API.g_exc_error;
         END IF;
   */

   END IF;

END Cancel_Schedule;

--==========================================================================
-- PROCEDURE
--    Cancel_Program
--
-- PURPOSE
--    Cancel All the associated campaigns. If the campaign can not be
--    canceled, error out .If the campaign can be cancelled, cancel all
--    the schedules too.
--
-- NOTES
-- HISTORY
--    23-May-2001  ptendulk    Created.
--    15-feb-2002  soagrawa    Logic modified by  soagrawa to fix bug# 2218013
--                             Before: Cancel a program => cancel all components
--                                     Cancel a campaign => cancel all schedules
--                             Now:    Cancel only if children are cancelled/archived
--==========================================================================

/*
PROCEDURE Cancel_Program(
   p_program_id            IN  NUMBER
   ) IS

   CURSOR c_campaign IS
      SELECT campaign_id, object_version_number, rollup_type, status_code
      FROM ams_campaigns_all_b
      WHERE  parent_campaign_id = p_program_id
      AND    status_code <> 'CANCELLED' ;

   l_campaign_id        NUMBER ;
   l_obj_version        NUMBER ;
   l_rollup_type        VARCHAR2(30) ;
   l_status_code        VARCHAR2(30) ;
   l_program_status_id  NUMBER := AMS_Utility_PVT.get_default_user_status('AMS_PROGRAM_STATUS','CANCELLED');
   l_campaign_status_id NUMBER := AMS_Utility_PVT.get_default_user_status('AMS_CAMPAIGN_STATUS','CANCELLED');

BEGIN

   OPEN c_campaign ;
   LOOP
      FETCH c_campaign INTO l_campaign_id, l_obj_version, l_rollup_type,l_status_code ;
      EXIT WHEN c_campaign%NOTFOUND ;

      IF l_rollup_type = 'RCAM' THEN
         Cancel_Program(l_campaign_id) ;
         IF FND_API.G_TRUE = AMS_Utility_PVT.Check_Status_Change('AMS_PROGRAM_STATUS',l_status_code,'CANCELLED') THEN
            UPDATE ams_campaigns_all_b
            SET      status_code = 'CANCELLED',
                     user_status_id = l_program_status_id ,
                     status_date = SYSDATE ,
                     object_version_number = l_obj_version + 1
            WHERE    campaign_id = l_campaign_id
            AND      object_version_number = l_obj_version ;
            IF (SQL%NOTFOUND) THEN
               CLOSE c_campaign ;
               AMS_Utility_PVT.Error_Message('AMS_API_RECORD_NOT_FOUND');
               RAISE FND_API.g_exc_error;
            END IF;
         ELSE
            CLOSE c_campaign;
            AMS_Utility_PVT.Error_Message('AMS_PROG_CANNOT_CANCEL');
            RAISE FND_API.g_exc_error;
         END IF ;
      ELSE
         IF FND_API.G_TRUE = AMS_Utility_PVT.Check_Status_Change('AMS_CAMPAIGN_STATUS',l_status_code,'CANCELLED') THEN
            Cancel_schedule(l_campaign_id);
            UPDATE   ams_campaigns_all_b
            SET      status_code = 'CANCELLED',
                     user_status_id = l_campaign_status_id ,
                     status_date = SYSDATE ,
                     object_version_number = l_obj_version + 1
            WHERE    campaign_id = l_campaign_id
            AND      object_version_number = l_obj_version ;

            IF (SQL%NOTFOUND) THEN
               CLOSE c_campaign ;
               AMS_Utility_PVT.Error_Message('AMS_API_RECORD_NOT_FOUND');
               RAISE FND_API.g_exc_error;
            END IF;
         ELSE
            CLOSE c_campaign;
            AMS_Utility_PVT.Error_Message('AMS_CAMP_CANNOT_CANCEL');
            RAISE FND_API.g_exc_error;
         END IF ;
      END IF;
   END LOOP ;
   CLOSE c_campaign ;


END Cancel_Program;
*/


PROCEDURE Cancel_Program(
   p_program_id            IN  NUMBER
   ) IS

   -- cursor sees if for given program there are any components that are not cancelled / archived
   CURSOR c_campaign IS
      SELECT count(*)
      FROM ams_campaigns_all_b
      WHERE  parent_campaign_id = p_program_id
      AND    status_code <> 'CANCELLED'
      AND    status_code <> 'ARCHIVED';

   l_camp_count         NUMBER;
   -- l_program_status_id  NUMBER := AMS_Utility_PVT.get_default_user_status('AMS_PROGRAM_STATUS','CANCELLED');
   -- l_campaign_status_id NUMBER := AMS_Utility_PVT.get_default_user_status('AMS_CAMPAIGN_STATUS','CANCELLED');


   -- l_campaign_id        NUMBER ;
   -- l_obj_version        NUMBER ;
   -- l_rollup_type        VARCHAR2(30) ;
   -- l_status_code        VARCHAR2(30) ;

BEGIN

   OPEN  c_campaign ;
   FETCH c_campaign INTO l_camp_count;
   CLOSE c_campaign ;

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_Utility_PVT.debug_message('SONALI: l_camp_count is *' || l_camp_count ||'*');

   END IF;
   IF l_camp_count > 0
   THEN
         -- cannot cancel
            AMS_Utility_PVT.Error_Message('AMS_COMP_CANNOT_CANCEL');
            RAISE FND_API.g_exc_error;
   /*
   ELSE
         -- ok cancel
         UPDATE ams_campaigns_all_b
         SET      status_code = 'CANCELLED',
                  user_status_id = l_program_status_id ,
                  status_date = SYSDATE ,
                  -- object_version_number = l_obj_version + 1
         WHERE    campaign_id = l_campaign_id ;
         --AND      object_version_number = l_obj_version ;
         IF (SQL%NOTFOUND) THEN
            CLOSE c_campaign ;
            AMS_Utility_PVT.Error_Message('AMS_API_RECORD_NOT_FOUND');
            RAISE FND_API.g_exc_error;
         END IF;
   */

   END IF;

END Cancel_Program;



--==========================================================================
-- PROCEDURE
--    Complete_Schedule
--
-- PURPOSE
--    Completes all the schedules associated to the campaign. If the status
--    order rules does not permit it, it will error out. This api is similar
--    to the Cancel_Schedule api , only reason to write it seperately is to
--    keep the logic of the complete and cancel status seperate, So that if
--    there is any change , the apis can be modified seperately.
--
-- NOTES
-- HISTORY
--    09-Jul-2001  ptendulk    Created.
--    15-may-2003  soagrawa    Modified code to fix bug# 2962164
--=======================================================================

PROCEDURE Complete_Schedule(p_campaign_id   IN  NUMBER) IS

   CURSOR c_schedule IS
      -- soagrawa added columns to this cursor on 15-may-2003 for bug# 2962164
      SELECT schedule_id,object_version_number,status_code, activity_type_code, related_event_id, source_code
      FROM ams_campaign_schedules_b
      WHERE  campaign_id = p_campaign_id
      -- asaha added more status check for bug 3142886
      AND status_code NOT IN ('COMPLETED','CANCELLED','CLOSED','ARCHIVED') ;

   -- new cursor created by asaha for bug 3132886
   CURSOR c_completed_schedule IS
      SELECT count(*)
      FROM ams_campaign_schedules_b
      WHERE  campaign_id = p_campaign_id
      AND status_code IN ('COMPLETED','CLOSED') ;

   -- mayjain 11-Oct-2005 Bug 4401237
   CURSOR c_no_of_schedules IS
      SELECT count(1)
      FROM ams_campaign_schedules_b
      WHERE  campaign_id = p_campaign_id ;

   l_schedule_id        NUMBER ;
   l_obj_version        NUMBER ;
   l_status_code        VARCHAR2(30) ;
   l_status_id  NUMBER := AMS_Utility_PVT.get_default_user_status('AMS_CAMPAIGN_SCHEDULE_STATUS','COMPLETED');
   -- soagrawa added the following on 15-may-2003 for bug# 2962164
   l_activity_type_code VARCHAR2(30);
   l_related_event_id   NUMBER;
   l_source_code        VARCHAR2(30);
   l_no_complete_scheds  NUMBER;
   l_no_of_scheds NUMBER ;


BEGIN

   OPEN c_schedule ;
   LOOP
      FETCH c_schedule
      INTO l_schedule_id,l_obj_version,l_status_code, l_activity_type_code, l_related_event_id, l_source_code ;
      EXIT WHEN c_schedule%NOTFOUND ;
      IF FND_API.G_TRUE = AMS_Utility_PVT.Check_Status_Change('AMS_CAMPAIGN_SCHEDULE_STATUS',l_status_code,'COMPLETED') THEN
         IF (AMS_DEBUG_HIGH_ON) THEN
            AMS_Utility_PVT.debug_message('MAYANK: l_schedule_id is *' || l_schedule_id ||'*');
            AMS_Utility_PVT.debug_message('MAYANK: l_obj_version is *' || l_obj_version ||'*');
         END IF;

         -- Can complete the schedule
         UPDATE ams_campaign_schedules_b
         SET    status_code = 'COMPLETED',
                status_date = SYSDATE,
                user_status_id = l_status_id,
                object_version_number = object_version_number + 1
         WHERE  schedule_id = l_schedule_id
         AND    object_version_number = l_obj_version ;

         IF (SQL%NOTFOUND) THEN
            CLOSE c_schedule ;
            AMS_Utility_PVT.Error_Message('AMS_API_RECORD_NOT_FOUND');
            RAISE FND_API.g_exc_error;
         END IF;

         -- soagrawa added the following on 15-may-2003 for bug# 2962164
         IF l_activity_type_code = 'EVENTS'
         THEN
            AMS_EvhRules_PVT.process_leads(p_event_id  => l_related_event_id
                                         , p_obj_type  => 'CSCH'
                                         , p_obj_srccd => l_source_code);
         END IF;


      ELSE -- Can not complete the schedule as the status is can not go to complete from current status
         CLOSE c_schedule;
         AMS_Utility_PVT.Error_Message('AMS_CSCH_CANNOT_COMPLETE');
         RAISE FND_API.g_exc_error;
      END IF ;

   END LOOP;
   CLOSE c_schedule;

   -- check added by asaha for bug 3132886
   OPEN c_completed_schedule;
   FETCH c_completed_schedule INTO l_no_complete_scheds;
   CLOSE c_completed_schedule;

   -- mayjain 11-Oct-2005 Bug 4401237
   OPEN c_no_of_schedules;
   FETCH c_no_of_schedules INTO l_no_of_scheds;
   CLOSE c_no_of_schedules;

   -- mayjain 11-Oct-2005 Bug 4401237
   IF (l_no_of_scheds > 0) THEN -- There should be atleast one schedule to make the next check.
      IF(l_no_complete_scheds = 0) THEN
        -- at least 1 completed Schedule is required for the Campaign to be complete
        CLOSE c_completed_schedule;
        AMS_Utility_PVT.Error_Message('AMS_CSCH_CANNOT_COMPLETE');
        RAISE FND_API.g_exc_error;
      END IF;
   END IF;


END Complete_Schedule;

--==========================================================================
-- PROCEDURE
--    Complete_Program
--
-- PURPOSE
--    Completes All the associated campaigns. If the campaign can not be
--    completed, error out .If the campaign can be completed, complete all
--    the schedules too.This api is similar
--    to the Cancel_Program api , only reason to write it seperately is to
--    keep the logic of the complete and cancel status seperate, So that if
--    there is any change , the apis can be modified seperately.
--
-- NOTES
-- HISTORY
--    23-May-2001  ptendulk    Created.
--    15-may-2003  soagrawa    Modified code to fix bug# 2962702
--==========================================================================

PROCEDURE Complete_Program(
   p_program_id            IN  NUMBER
   ) IS

   CURSOR c_campaign IS
      SELECT campaign_id, object_version_number, rollup_type, status_code
      FROM ams_campaigns_all_b
      WHERE  parent_campaign_id = p_program_id
      AND    status_code <> 'COMPLETED' ;

   l_campaign_id        NUMBER ;
   l_obj_version        NUMBER ;
   l_rollup_type        VARCHAR2(30) ;
   l_status_code        VARCHAR2(30) ;
   l_program_status_id  NUMBER := AMS_Utility_PVT.get_default_user_status('AMS_PROGRAM_STATUS','COMPLETED');
   l_campaign_status_id NUMBER := AMS_Utility_PVT.get_default_user_status('AMS_CAMPAIGN_STATUS','COMPLETED');

BEGIN

   OPEN c_campaign ;
   LOOP
      FETCH c_campaign INTO l_campaign_id, l_obj_version, l_rollup_type,l_status_code ;
      EXIT WHEN c_campaign%NOTFOUND ;

      IF l_rollup_type = 'RCAM' THEN
         -- soagrawa 15-may-2003 modified for bug# 2962702
         -- Cancel_Program(l_campaign_id) ;
         Complete_Program(l_campaign_id) ;
         IF FND_API.G_TRUE = AMS_Utility_PVT.Check_Status_Change('AMS_PROGRAM_STATUS',l_status_code,'COMPLETED') THEN
            UPDATE ams_campaigns_all_b
            SET      status_code = 'COMPLETED',
                     user_status_id = l_program_status_id ,
                     status_date = SYSDATE ,
                     object_version_number = l_obj_version + 1
            WHERE    campaign_id = l_campaign_id
            AND      object_version_number = l_obj_version ;
            IF (SQL%NOTFOUND) THEN
               CLOSE c_campaign ;
               AMS_Utility_PVT.Error_Message('AMS_API_RECORD_NOT_FOUND');
               RAISE FND_API.g_exc_error;
            END IF;
         ELSE
            CLOSE c_campaign;
            AMS_Utility_PVT.Error_Message('AMS_PROG_CANNOT_COMPLETE');
            RAISE FND_API.g_exc_error;
         END IF ;
      ELSE
         IF FND_API.G_TRUE = AMS_Utility_PVT.Check_Status_Change('AMS_CAMPAIGN_STATUS',l_status_code,'COMPLETED') THEN
            -- soagrawa 15-may-2003 modified for bug# 2962702
            -- Cancel_schedule(l_campaign_id) ;
            Complete_Schedule(l_campaign_id) ;

            UPDATE   ams_campaigns_all_b
            SET      status_code = 'COMPLETED',
                     user_status_id = l_campaign_status_id ,
                     status_date = SYSDATE ,
                     object_version_number = l_obj_version + 1
            WHERE    campaign_id = l_campaign_id
            AND      object_version_number = l_obj_version ;

            IF (SQL%NOTFOUND) THEN
               CLOSE c_campaign ;
               AMS_Utility_PVT.Error_Message('AMS_API_RECORD_NOT_FOUND');
               RAISE FND_API.g_exc_error;
            END IF;
         ELSE
            CLOSE c_campaign;
            AMS_Utility_PVT.Error_Message('AMS_CAMP_CANNOT_COMPLETE');
            RAISE FND_API.g_exc_error;
         END IF ;
      END IF;
   END LOOP ;
   CLOSE c_campaign ;


END Complete_Program;

-- PROCEDURE
--    Get_Event_Source_Code
--
-- PURPOSE
--    Get the source code for the related event associated to the campaign.
--
-- NOTES
-- HISTORY
--    22-May-2001  ptendulk    Created.
--    08-Oct-2001  ptendulk    Modified cursor queries for event offers and one off.
-----------------------------------------------------------------------

FUNCTION Get_Event_Source_Code(
   p_event_type      VARCHAR2,
   p_event_id        NUMBER
   ) RETURN VARCHAR2
IS
   --Added by rrajesh on 04/13/01 - to update realted_event fields
   CURSOR c_fetch_sourcecode_for_eveh IS
   SELECT source_code
   FROM ams_event_headers_all_b
   WHERE  event_header_id = p_event_id ;

   CURSOR c_fetch_sourcecode_for_eveo IS
   SELECT source_code
   FROM ams_event_offers_all_b
   WHERE event_offer_id = p_event_id
   --AND  event_standalone_flag = 'N';
   AND  event_object_type = 'EVEO';

   CURSOR c_fetch_sourcecode_for_eone IS
   SELECT source_code
   FROM ams_event_offers_all_b
   WHERE  event_offer_id = p_event_id
   --AND    event_standalone_flag = 'Y';
   AND  event_object_type = 'EONE';

   l_source_code     VARCHAR2(30) ;

BEGIN

   IF p_event_type = 'EVEH' THEN
      OPEN c_fetch_sourcecode_for_eveh;
      FETCH c_fetch_sourcecode_for_eveh INTO l_source_code;
      CLOSE c_fetch_sourcecode_for_eveh;
   ELSIF p_event_type = 'EVEO' THEN
      OPEN c_fetch_sourcecode_for_eveo;
      FETCH c_fetch_sourcecode_for_eveo INTO l_source_code;
      CLOSE c_fetch_sourcecode_for_eveo;
   ELSIF p_event_type = 'EONE' THEN
      OPEN c_fetch_sourcecode_for_eone;
      FETCH c_fetch_sourcecode_for_eone INTO l_source_code;
      CLOSE c_fetch_sourcecode_for_eone;
   ELSE
      l_source_code := NULL ;
   END IF;
   RETURN l_source_code ;
END Get_Event_Source_Code ;

--=====================================================================
-- PROCEDURE
--    Update_Rollup
--
-- PURPOSE
--    The api is created to update the rollup for the metrics if the
--    parent of the campaign is changed
--
-- HISTORY
--    31-May-2001  ptendulk    Created.
--=====================================================================
PROCEDURE Update_Rollup(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,
   p_campaign_id       IN  NUMBER,
   p_parent_id         IN  NUMBER   )
IS
   CURSOR c_parent IS
   SELECT parent_campaign_id, DECODE(rollup_type,'RCAM','RCAM','CAMP')
   FROM   ams_campaigns_all_b
   WHERE  campaign_id = p_campaign_id ;
   l_old_parent  NUMBER ;
   l_rollup_type VARCHAR2(30) ;

BEGIN
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.Debug_message('Start Update rollup ');
   END IF;
   OPEN c_parent ;
   FETCH c_parent INTO l_old_parent,l_rollup_type ;
   IF c_parent%NOTFOUND THEN
      CLOSE c_parent;
      AMS_Utility_Pvt.Error_Message('AMS_API_RECORD_NOT_FOUND');
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_parent ;

   IF l_old_parent IS NOT NULL THEN
      IF p_parent_id IS NULL OR
         p_parent_id <> l_old_parent
      THEN
         IF (AMS_DEBUG_HIGH_ON) THEN

         AMS_Utility_PVT.Debug_message('Invalidate the  rollup ');
         END IF;
         -- Change p_used_by_type to l_rollup_type when gliu resolve the
         -- issue for rollup type of seed metric for the program /campaign
         -- as of Jun01-2001
         AMS_ACTMETRIC_PUB.Invalidate_Rollup(
              p_api_version       => p_api_version ,
              p_init_msg_list     => p_init_msg_list,
              p_commit            => p_commit,

              x_return_status     => x_return_status,
              x_msg_count         => x_msg_count,
              x_msg_data          => x_msg_data,

              -- Following line is commented
              --p_used_by_type      => 'CAMP',
              p_used_by_type      => l_rollup_type,
              p_used_by_id        => p_campaign_id
           );
      END IF ;
   END IF;

END Update_Rollup ;

--========================================================================
-- PROCEDURE
--    Update_Status
--
-- PURPOSE
--    This api is called in Update campaign api (and in approvals' api)
--
-- NOTE
--
-- HISTORY
--  26-Sep-2001    soagrawa    Created.
--  07-SEP-2003    asaha       Disabled Update of private_flag to N when
--                             Campaign goes active
--========================================================================
PROCEDURE update_status(         p_campaign_id             IN NUMBER,
                                 p_new_status_id           IN NUMBER,
                                 p_new_status_code         IN VARCHAR2
                                 )
IS

BEGIN
   UPDATE ams_campaigns_all_b
   SET    user_status_id = p_new_status_id,
          status_code = p_new_status_code, -- AMS_Utility_PVT.get_system_status_code(p_new_status_id),
          status_date = SYSDATE
          -- private_flag = DECODE(p_new_status_code,'ACTIVE','N',private_flag)
   WHERE  campaign_id = p_campaign_id;

   IF p_new_status_code = 'ACTIVE' THEN
      activate_campaign(p_campaign_id  => p_campaign_id);
   END IF ;

END update_status;

--========================================================================
-- PROCEDURE
--    Check_Children_Tree
--
-- PURPOSE
--    This api is to check if the hierarchy for the parent child camp is
--    valid. It validates that parent campaign is not one of the
--    childrens of the campaign.
--
-- NOTE
--
-- HISTORY
--  25-Oct-2001    ptendulk    Created.
--
--========================================================================
PROCEDURE Check_Children_Tree(p_campaign_id          IN NUMBER,
                              p_parent_campaign_id   IN NUMBER
                                 )
IS
   CURSOR c_child_tree IS
   SELECT campaign_id
   FROM ams_Campaigns_all_B
   WHERE active_flag = 'Y'
   START WITH campaign_id = p_campaign_id
   CONNECT BY PRIOR campaign_id = parent_campaign_id ;
   l_camp_id NUMBER ;

BEGIN

   OPEN c_child_tree ;
   LOOP
      FETCH c_child_tree INTO l_camp_id ;
      EXIT WHEN c_child_tree%NOTFOUND ;
      IF l_camp_id = p_parent_campaign_id THEN
         CLOSE c_child_tree;
         AMS_Utility_PVT.Error_Message('AMS_CAMP_PARENT_IS_CHILD');
         RAISE FND_API.g_exc_error;
      END IF ;

   END LOOP;
   CLOSE c_child_tree;

END Check_Children_Tree;

--==========================================================================
-- PROCEDURE
--    Check_Close_Campaign
--
-- PURPOSE
--    This procedure is used to check whether the campaign can be closed.
--    All the schedules under this campaign are checked.
--    The campaign will be closed only if all the schedules under the campaign is closed.
--
-- NOTES
-- HISTORY
--    Created by Prageorg on 4/10/2006 to fix Bug 4263210
--=======================================================================

PROCEDURE Check_Close_Campaign(p_campaign_id   IN  NUMBER) IS

  CURSOR c_no_of_open_schedules IS
      SELECT count(1)
      FROM ams_campaign_schedules_b
      WHERE  campaign_id = p_campaign_id
      AND status_code IN ('ACTIVE','AVAILABLE');

    l_no_open_scheds  NUMBER;


BEGIN

   OPEN c_no_of_open_schedules;
   FETCH c_no_of_open_schedules INTO l_no_open_scheds;
   CLOSE c_no_of_open_schedules;

   IF (l_no_open_scheds > 0) THEN
        AMS_Utility_PVT.Error_Message('AMS_CSCH_CANNOT_CLOSE');
        RAISE FND_API.g_exc_error;
   END IF;


END Check_Close_Campaign;

END AMS_CampaignRules_PVT;

/
