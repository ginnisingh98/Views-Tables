--------------------------------------------------------
--  DDL for Package Body AMS_EVHRULES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_EVHRULES_PVT" AS
/* $Header: amsvebrb.pls 120.1 2006/01/20 06:02:55 vmodur noship $ */
g_pkg_name   CONSTANT VARCHAR2(30):='AMS_EvhRules_PVT';

-----------------------------------------------------------------------
-- PROCEDURE
--    handle_evh_status
--
-- HISTORY
--    11/19/99  rvaka  Created.
--  07/20/2000 THIS PROCEDURE SHOULDNT BE CALLED AS IT DOESNT DIFFERENTIATES
-- WHETHER THE EVENT LEVEL IS MAIN OR SUB.. IF NEED BE, USE AFTER CHANGING THE CODE
-- TO INCLUDE CHECK AGAINST AMS_EVENT_AGENDA_STATUS FOR EVENT_LEVEL=SUB
-----------------------------------------------------------------------
AMS_DEBUG_HIGH_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

-- soagrawa 03-feb-2003
-- added get_user_id bug# 2781219

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


 --==========================================================================
-- PROCEDURE
--    Complete_Event_Offers
--
-- PURPOSE
--    The api is created to complete the underlying schedules of an event
--
-- HISTORY
--    05-Jan-2004  soagrawa   Created.
--    17-Mar-2005  spendem    Call api to raise business event. enh # 3805347
--=============================================================================


PROCEDURE Complete_Event_Offers(p_eveh_id   IN  NUMBER) IS

   -- Modified the cursor to select event_object_type, as per enh # 3805347
   CURSOR c_ev_schedule IS
      SELECT event_offer_id, object_version_number, system_status_code, event_object_type
      FROM ams_event_offers_all_b
      WHERE  event_header_id = p_eveh_id
      AND system_status_code <> 'COMPLETED' ;

   l_event_offer_id        NUMBER ;
   l_obj_version           NUMBER ;
   l_status_code           VARCHAR2(30) ;
   l_status_id             NUMBER := AMS_Utility_PVT.get_default_user_status('AMS_EVENT_STATUS','COMPLETED');
   l_obj_type              VARCHAR2(4); -- added as per enh # 3805347

BEGIN

   OPEN c_ev_schedule ;
   LOOP
      FETCH c_ev_schedule
      INTO l_event_offer_id, l_obj_version, l_status_code, l_obj_type;
      EXIT WHEN c_ev_schedule%NOTFOUND ;
      IF FND_API.G_TRUE = AMS_Utility_PVT.Check_Status_Change('AMS_EVENT_STATUS',l_status_code,'COMPLETED') THEN
         -- Can cancel the event offer
         UPDATE ams_event_offers_all_b
         SET    system_status_code = 'COMPLETED',
                last_status_date = SYSDATE,
                user_status_id = l_status_id,
                object_version_number = object_version_number + 1
         WHERE  event_offer_id = l_event_offer_id
         AND    object_version_number = l_obj_version ;

	 -- call to api to raise business event, as per enh # 3805347
         AMS_SCHEDULERULES_PVT.RAISE_BE_ON_STATUS_CHANGE(p_obj_id => l_event_offer_id,
							 p_obj_type => l_obj_type,
  						         p_old_status_code => l_status_code,
							 p_new_status_code => 'COMPLETED' );


         IF (SQL%NOTFOUND) THEN
            CLOSE c_ev_schedule ;
            AMS_Utility_PVT.Error_Message('AMS_API_RECORD_NOT_FOUND');
            RAISE FND_API.g_exc_error;
         END IF;

         AMS_EvhRules_PVT.process_leads(p_event_id  => l_event_offer_id);

      ELSE -- Can not cancel the schedule as the status is can not go to cancel from current status
         CLOSE c_ev_schedule;
         AMS_Utility_PVT.Error_Message('AMS_EVEH_CANNOT_COMPLETE');
         RAISE FND_API.g_exc_error;
      END IF ;

   END LOOP;
   CLOSE c_ev_schedule;

END Complete_Event_Offers;



PROCEDURE handle_evh_status(
   p_user_status_id  IN  NUMBER,
   x_status_code     OUT NOCOPY VARCHAR2,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS
   l_status_code     VARCHAR2(30);
   CURSOR e_status_code IS
   SELECT system_status_code
     FROM ams_user_statuses_vl
    WHERE user_status_id = p_user_status_id
      AND system_status_type = 'AMS_EVENT_STATUS';
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
   OPEN e_status_code;
   FETCH e_status_code INTO l_status_code;
   CLOSE e_status_code;
   IF l_status_code IS NULL THEN
      x_return_status := FND_API.g_ret_sts_error;
      AMS_Utility_PVT.error_message('AMS_EVH_NO_USER_STATUS');
   END IF;
   x_status_code := l_status_code;
END handle_evh_status;
---------------------------------------------------------------------
-- PROCEDURE
--    check_evh_update
--
-- HISTORY
--    11/19/99  rvaka  Created.
--    04/03/00  sugupta modified
---------------------------------------------------------------------
PROCEDURE check_evh_update(
   p_evh_rec       IN  AMS_EventHeader_PVT.evh_rec_type,
   x_return_status  OUT NOCOPY VARCHAR2
)
IS
  CURSOR c_evh IS
   SELECT *
     FROM ams_event_headers_vl
    WHERE event_header_id = p_evh_rec.event_header_id;

   CURSOR c_source_code IS
   SELECT 1
     FROM ams_source_codes
    WHERE source_code = p_evh_rec.source_code
    AND active_flag = 'Y';

   l_msg_data  VARCHAR2(2000);
   l_msg_count NUMBER;
   l_dummy  NUMBER;
   l_evh_rec  c_evh%ROWTYPE;

BEGIN
   x_return_status := FND_API.g_ret_sts_success;

     OPEN c_evh;
   FETCH c_evh INTO l_evh_rec;
   IF c_evh%NOTFOUND THEN
      CLOSE c_evh;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_evh;

 ---------------------------- status codes-----------------------
   -- change status through workflow
      -- modified sugupta 07/20/2000
   --NOT NEEDED FOR EVENT AGENDAS

   -- Commented the old style of approval process call.
   -- gdeodhar : Oct 06, 2000.
/*
 if p_evh_rec.event_level = 'MAIN' then
   IF p_evh_rec.user_status_id <> FND_API.g_miss_num
      AND p_evh_rec.user_status_id <> l_evh_rec.user_status_id
   THEN
      AMS_WFCmpApr_PVT.StartProcess(
         p_approval_for => 'EVEH',
         p_approval_for_id => p_evh_rec.event_header_id,
         p_object_version_number => p_evh_rec.object_version_number,
         p_orig_stat_id => l_evh_rec.user_status_id,
         p_new_stat_id => p_evh_rec.user_status_id,
         p_requester_userid => FND_GLOBAL.user_id
      );
   END IF;

   -- the following will be locked after theme approval
   IF l_evh_rec.system_status_code <> 'NEW' THEN
      IF p_evh_rec.event_header_name <> FND_API.g_miss_char
         AND p_evh_rec.event_header_name <> l_evh_rec.event_header_name
      THEN
         AMS_Utility_PVT.error_message('AMS_EVH_UPDATE_EVH_NAME');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
      IF p_evh_rec.active_from_date <> FND_API.g_miss_date
         AND p_evh_rec.active_from_date <>
            l_evh_rec.active_from_date
      THEN
         AMS_Utility_PVT.error_message('AMS_EVH_UPDATE_START_DATE');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
      IF p_evh_rec.active_to_date <> FND_API.g_miss_date
         AND p_evh_rec.active_to_date <>
            l_evh_rec.active_to_date
      THEN
         AMS_Utility_PVT.error_message('AMS_EVH_UPDATE_END_DATE');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;
 end if; -- event_level MAIN
*/
   -- Commented part for the old style of approval process call ends.
   -- Locking of fields will be added later.
   -- gdeodhar : Oct 06, 2000.


   ----------------------------------------------------------------------------
   ------------- source_code logic ------------------
   ----------------------------------------------------------------------------
   -- modified sugupta 07/20/2000
   --NOT NEEDED FOR EVENT AGENDAS
/*  commented OUT NOCOPY by murali on july17 2001
IF p_evh_rec.event_level = 'MAIN' THEN
   IF p_evh_rec.source_code <> FND_API.g_miss_char
      AND p_evh_rec.source_code <> l_evh_rec.source_code
   THEN
       IF p_evh_rec.source_code IS NULL THEN
        AMS_Utility_PVT.error_message('AMS_EVH_NO_SOURCE_CODE');
        x_return_status := FND_API.g_ret_sts_error;
        RETURN;
      END IF;

      -- source_code cannot be changed if status is not NEW
      IF l_evh_rec.system_status_code <> 'NEW' THEN
        AMS_Utility_PVT.error_message('AMS_EVH_UPDATE_SOURCE_CODE');
        x_return_status := FND_API.g_ret_sts_error;
        RETURN;
      END IF;

      -- check if the new source code is unique
      l_dummy := NULL;
      OPEN c_source_code;
      FETCH c_source_code INTO l_dummy;
      CLOSE c_source_code;

      IF l_dummy IS NOT NULL THEN
        AMS_Utility_PVT.error_message('AMS_EVH_DUPE_SOURCE');
        x_return_status := FND_API.g_ret_sts_error;
        RETURN;
      END IF;

      -- otherwise revoke the old one and add the new one to ams_source_codes
      AMS_SourceCode_PVT.revoke_sourcecode(
        p_api_version        => 1.0,
        p_init_msg_list      => FND_API.g_false,
        p_commit             => FND_API.g_false,
        p_validation_level   => FND_API.g_valid_level_full,

        x_return_status      => x_return_status,
        x_msg_count          => l_msg_count,
        x_msg_data           => l_msg_data,

        p_sourcecode         => p_evh_rec.source_code
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

        p_sourcecode         => p_evh_rec.source_code,
        p_sourcecode_for     => 'EVEH',
        p_sourcecode_for_id  => p_evh_rec.event_header_id,
        x_sourcecode_id      => l_dummy
      );

      IF x_return_status <> FND_API.g_ret_sts_success THEN
        RAISE FND_API.g_exc_error;
      END IF;

   END IF; -- p_evh_rec.source_code
 END IF;  -- p_evh_rec.event_level
*/
END check_evh_update;
---------------------------------------------------------------------
-- PROCEDURE
--    check_evh_fund_source
--
-- HISTORY
--    11/19/99  rvaka  Created.
---------------------------------------------------------------------
PROCEDURE check_evh_fund_source(
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
   CURSOR c_eone IS
   SELECT 1
     FROM ams_event_offers_vl
    WHERE event_offer_id = p_fund_source_id;
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
   IF p_fund_source_type IS NULL AND p_fund_source_id IS NULL THEN
      RETURN;
   ELSIF p_fund_source_type IS NULL AND p_fund_source_id IS NOT NULL THEN
      AMS_Utility_PVT.error_message('AMS_EVH_NO_FUND_SOURCE_TYPE');
   END IF;
   IF p_fund_source_type = 'FUND' THEN
   -- todo add code to check against a fund
      NULL;
   ELSIF p_fund_source_type = 'CAMP' THEN
      IF p_fund_source_id IS NOT NULL THEN
         OPEN c_camp;
         FETCH c_camp INTO l_dummy;
         IF c_camp%NOTFOUND THEN
            x_return_status := FND_API.g_ret_sts_error;
            AMS_Utility_PVT.error_message('AMS_EVH_BAD_FUND_SOURCE_CAMP');
         END IF;
         CLOSE c_camp;
      END IF;
   ELSIF p_fund_source_type = 'EVEH' THEN
      IF p_fund_source_id IS NOT NULL THEN
         OPEN c_eveh;
         FETCH c_eveh INTO l_dummy;
         IF c_eveh%NOTFOUND THEN
            x_return_status := FND_API.g_ret_sts_error;
            AMS_Utility_PVT.error_message('AMS_EVH_BAD_FUND_SOURCE_EVEH');
         END IF;
         CLOSE c_eveh;
      END IF;
   ELSIF p_fund_source_type = 'EVEO' THEN
      IF p_fund_source_id IS NOT NULL THEN
         OPEN c_eveo;
         FETCH c_eveo INTO l_dummy;
         IF c_eveo%NOTFOUND THEN
            x_return_status := FND_API.g_ret_sts_error;
            AMS_Utility_PVT.error_message('AMS_EVH_BAD_FUND_SOURCE_EVEO');
         END IF;
         CLOSE c_eveo;
      END IF;
   ELSIF p_fund_source_type = 'EONE' THEN
      IF p_fund_source_id IS NOT NULL THEN
         OPEN c_eone;
         FETCH c_eone INTO l_dummy;
         IF c_eone%NOTFOUND THEN
            x_return_status := FND_API.g_ret_sts_error;
            AMS_Utility_PVT.error_message('AMS_EVH_BAD_FUND_SOURCE_EVEO');
         END IF;
         CLOSE c_eone;
      END IF;
   ELSE
      x_return_status := FND_API.g_ret_sts_error;
      AMS_Utility_PVT.error_message('AMS_EVH_BAD_FUND_SOURCE');
   END IF;
END check_evh_fund_source;
---------------------------------------------------------------------
-- PROCEDURE
--    check_evh_calendar
--
-- HISTORY
--    10/01/2000  sugupta  Created.
---------------------------------------------------------------------
PROCEDURE check_evh_calendar(
   p_evh_calendar   IN  VARCHAR2,
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

   CURSOR c_evh_calendar IS
   SELECT 1
   FROM   DUAL
   WHERE  EXISTS(
             SELECT 1
             FROM   gl_periods_v
             WHERE  period_set_name = p_evh_calendar
          );

   CURSOR c_start_period IS
   SELECT start_date, end_date
   FROM   gl_periods_v
   WHERE  period_set_name = p_evh_calendar
   AND    period_name = p_start_period_name;

   CURSOR c_end_period IS
   SELECT start_date, end_date
   FROM   gl_periods_v
   WHERE  period_set_name = p_evh_calendar
   AND    period_name = p_end_period_name;

BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   -- check if p_evh_calendar is null
   IF p_evh_calendar IS NULL
      AND p_start_period_name IS NULL
      AND p_end_period_name IS NULL
   THEN
      RETURN;
   ELSIF p_evh_calendar IS NULL THEN
      x_return_status := FND_API.g_ret_sts_error;
      AMS_Utility_PVT.error_message('AMS_EVH_NO_EVENT_CALENDAR');
      RETURN;
   END IF;

   -- check if p_evh_calendar is valid
   OPEN c_evh_calendar;
   FETCH c_evh_calendar INTO l_dummy;
   CLOSE c_evh_calendar;

   IF l_dummy IS NULL THEN
      x_return_status := FND_API.g_ret_sts_error;
      AMS_Utility_PVT.error_message('AMS_EVH_BAD_EVENT_CALENDAR');
      RETURN;
   END IF;

   -- check p_start_period_name
   IF p_start_period_name IS NOT NULL THEN
      OPEN c_start_period;
      FETCH c_start_period INTO l_start_start, l_start_end;
      CLOSE c_start_period;

      IF l_start_start IS NULL THEN
         x_return_status := FND_API.g_ret_sts_error;
         AMS_Utility_PVT.error_message('AMS_CAMP_BAD_START_PERIOD'); -- resusing CAMP message
         RETURN;
      ELSIF p_start_date < l_start_start OR p_start_date > l_start_end THEN
         x_return_status := FND_API.g_ret_sts_error;
         AMS_Utility_PVT.error_message('AMS_EVH_OUT_START_PERIOD');
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
         AMS_Utility_PVT.error_message('AMS_CAMP_BAD_END_PERIOD'); --resuing CAMP message
         RETURN;
      ELSIF p_end_date < l_end_start OR p_end_date > l_end_end THEN
         x_return_status := FND_API.g_ret_sts_error;
         AMS_Utility_PVT.error_message('AMS_EVH_OUT_END_PERIOD');
         RETURN;
      END IF;
   END IF;

   -- compare the start date and the end date
   IF l_start_start > l_end_end THEN
      x_return_status := FND_API.g_ret_sts_error;
      AMS_Utility_PVT.error_message('AMS_CAMP_BAD_PERIODS');--resuing CAMP message
   END IF;

END check_evh_calendar;

---------------------------------------------------------------------
-- PROCEDURE
--    push_source_code
--
-- HISTORY
--    11/01/99  holiu  Created.
---------------------------------------------------------------------
/*
PROCEDURE push_source_code(
   p_source_code    IN  VARCHAR2,
   p_arc_object     IN  VARCHAR2,
   p_object_id      IN  NUMBER
)
IS
   l_pk  NUMBER;
   CURSOR c_seq IS
   SELECT ams_source_codes_s.NEXTVAL
     FROM DUAL;
BEGIN
   OPEN c_seq;
   FETCH c_seq INTO l_pk;
   CLOSE c_seq;
   INSERT INTO ams_source_codes(
      source_code_id,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login,
      object_version_number,
      source_code,
      source_code_for_id,
      arc_source_code_for
   )
   VALUES(
      l_pk,
      SYSDATE,
      FND_GLOBAL.user_id,
      SYSDATE,
      FND_GLOBAL.user_id,
      FND_GLOBAL.conc_login_id,
      1,  -- object_version_number
      p_source_code,
      p_object_id,
      p_arc_object
   );
END push_source_code;
*/
-----------------------------------------------------------------------
-- PROCEDURE
--    udpate_evh_source_code
--
-- HISTORY
--    09/31/00  sugupta  Created.
-----------------------------------------------------------------------
PROCEDURE update_evh_source_code(
   p_evh_id      IN  NUMBER,
   p_source_code      IN  VARCHAR2,
   p_global_flag      IN  VARCHAR2,
   x_source_code      OUT NOCOPY VARCHAR2,
   x_return_status    OUT NOCOPY VARCHAR2
)
IS

   l_msg_data  VARCHAR2(2000);
   l_msg_count NUMBER;

   l_source_code       VARCHAR2(30);
   l_global_flag       VARCHAR2(1);
   l_custom_setup_id   NUMBER;
   l_source_code_id    NUMBER;

   CURSOR c_old_info IS
   SELECT global_flag, source_code
   FROM   ams_event_headers_vl
   WHERE  event_header_id = p_evh_id;

   CURSOR c_source_code IS
   SELECT source_code_id
   FROM   ams_source_codes
   WHERE  source_code = x_source_code
   AND    active_flag = 'Y';

   CURSOR c_setup_id IS
   SELECT SETUP_TYPE_ID
   FROM AMS_EVENT_HEADERS_ALL_B
   WHERE EVENT_HEADER_ID = p_evh_id;
   /*
   CURSOR c_setup_id IS
   SELECT custom_setup_id
   FROM   ams_object_attributes
   WHERE  object_type = 'EVEH'
   AND    object_id = p_evh_id;
   */
BEGIN

   x_source_code := p_source_code;
   x_return_status := FND_API.g_ret_sts_success;

   OPEN c_old_info;
   FETCH c_old_info INTO l_global_flag, l_source_code;
   CLOSE c_old_info;

   OPEN c_setup_id;
   FETCH c_setup_id INTO l_custom_setup_id;
   CLOSE c_setup_id;
   -- generate a new source code if global flag is updated and
   -- source code is not cascaded to schedules
   IF p_global_flag <> l_global_flag THEN
      x_source_code := AMS_SourceCode_PVT.get_new_source_code(
         p_object_type  => 'EVEH',
         p_custsetup_id => l_custom_setup_id,
         p_global_flag  => p_global_flag
      );
   END IF;

   IF x_source_code = l_source_code THEN
      RETURN;
   END IF;

   IF x_source_code IS NULL THEN
      AMS_Utility_PVT.error_message('AMS_EVO_NO_SOURCE_CODE');
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

   -- check if the new source code is unique
   OPEN c_source_code;
   FETCH c_source_code INTO l_source_code_id;
   CLOSE c_source_code;

   IF l_source_code_id IS NOT NULL THEN
      AMS_Utility_PVT.error_message('AMS_CAMP_DUPLICATE_CODE'); --reuse message
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

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
      p_sourcecode_for     => 'EVEH',
      p_sourcecode_for_id  => p_evh_id,
      x_sourcecode_id      => l_source_code_id
   );
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RAISE FND_API.g_exc_error;
   END IF;

END update_evh_source_code;

-----------------------------------------------------------------------
-- PROCEDURE
--    udpate_evo_source_code
--
-- HISTORY
--    09/31/00  sugupta  Created.
-----------------------------------------------------------------------
PROCEDURE update_evo_source_code(
   p_evo_id      IN  NUMBER,
   p_source_code      IN  VARCHAR2,
   p_global_flag      IN  VARCHAR2,
   x_source_code      OUT NOCOPY VARCHAR2,
   x_return_status    OUT NOCOPY VARCHAR2
)
IS

   l_msg_data  VARCHAR2(2000);
   l_msg_count NUMBER;

   l_source_code       VARCHAR2(30);
   l_global_flag       VARCHAR2(1);
   l_custom_setup_id   NUMBER;
   l_source_code_id    NUMBER;

   CURSOR c_old_info IS
   SELECT global_flag, source_code
   FROM   ams_event_offers_vl
   WHERE  event_offer_id = p_evo_id;

   CURSOR c_source_code IS
   SELECT source_code_id
   FROM   ams_source_codes
   WHERE  source_code = x_source_code
   AND    active_flag = 'Y';

   CURSOR c_setup_id IS
   SELECT SETUP_TYPE_ID
   FROM AMS_EVENT_OFFERS_ALL_B
   WHERE EVENT_HEADER_ID = p_evo_id;
   /*
   CURSOR c_setup_id IS
   SELECT custom_setup_id
   FROM   ams_object_attributes
   WHERE  object_type = 'EVEO'
   AND    object_id = p_evo_id;
   */
BEGIN

   x_source_code := p_source_code;
   x_return_status := FND_API.g_ret_sts_success;

   OPEN c_old_info;
   FETCH c_old_info INTO l_global_flag, l_source_code;
   CLOSE c_old_info;

   OPEN c_setup_id;
   FETCH c_setup_id INTO l_custom_setup_id;
   CLOSE c_setup_id;

   -- generate a new source code if global flag is updated and
   -- source code is not cascaded to schedules
   IF p_global_flag <> l_global_flag THEN
      x_source_code := AMS_SourceCode_PVT.get_new_source_code(
         p_object_type  => 'EVEO',
         p_custsetup_id => l_custom_setup_id,
         p_global_flag  => p_global_flag
      );
   END IF;

   IF x_source_code = l_source_code THEN
      RETURN;
   END IF;

   IF x_source_code IS NULL THEN
      AMS_Utility_PVT.error_message('AMS_EVO_NO_SOURCE_CODE');
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

   -- check if the new source code is unique
   OPEN c_source_code;
   FETCH c_source_code INTO l_source_code_id;
   CLOSE c_source_code;

   IF l_source_code_id IS NOT NULL THEN
      AMS_Utility_PVT.error_message('AMS_CAMP_DUPLICATE_CODE'); --reuse message
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

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
      p_sourcecode_for     => 'EVEO',
      p_sourcecode_for_id  => p_evo_id,
      x_sourcecode_id      => l_source_code_id
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RAISE FND_API.g_exc_error;
   END IF;

END update_evo_source_code;

-----------------------------------------------------------------------
-- PROCEDURE
--    udpate_eone_source_code
--
-- HISTORY
--    09/31/00  sugupta  Created.
-----------------------------------------------------------------------
PROCEDURE update_eone_source_code(
   p_evo_id      IN  NUMBER,
   p_source_code      IN  VARCHAR2,
   p_global_flag      IN  VARCHAR2,
   x_source_code      OUT NOCOPY VARCHAR2,
   x_return_status    OUT NOCOPY VARCHAR2
)
IS

   l_msg_data  VARCHAR2(2000);
   l_msg_count NUMBER;

   l_source_code       VARCHAR2(30);
   l_global_flag       VARCHAR2(1);
   l_custom_setup_id   NUMBER;
   l_source_code_id    NUMBER;

   CURSOR c_old_info IS
   SELECT global_flag, source_code
   FROM   ams_event_offers_vl
   WHERE  event_offer_id = p_evo_id;

   CURSOR c_source_code IS
   SELECT source_code_id
   FROM   ams_source_codes
   WHERE  source_code = x_source_code
   AND    active_flag = 'Y';

   CURSOR c_setup_id IS
   SELECT SETUP_TYPE_ID
   FROM AMS_EVENT_OFFERS_ALL_B
   WHERE EVENT_HEADER_ID = p_evo_id;
   /*
   CURSOR c_setup_id IS
   SELECT custom_setup_id
   FROM   ams_object_attributes
   WHERE  object_type = 'EONE'
   AND    object_id = p_evo_id;
   */
BEGIN

   x_source_code := p_source_code;
   x_return_status := FND_API.g_ret_sts_success;

   OPEN c_old_info;
   FETCH c_old_info INTO l_global_flag, l_source_code;
   CLOSE c_old_info;

   OPEN c_setup_id;
   FETCH c_setup_id INTO l_custom_setup_id;
   CLOSE c_setup_id;

   -- generate a new source code if global flag is updated and
   -- source code is not cascaded to schedules
   IF p_global_flag <> l_global_flag THEN
      x_source_code := AMS_SourceCode_PVT.get_new_source_code(
         p_object_type  => 'EONE',
         p_custsetup_id => l_custom_setup_id,
         p_global_flag  => p_global_flag
      );
   END IF;

   IF x_source_code = l_source_code THEN
      RETURN;
   END IF;

   IF x_source_code IS NULL THEN
      AMS_Utility_PVT.error_message('AMS_EVO_NO_SOURCE_CODE');
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

   -- check if the new source code is unique
   OPEN c_source_code;
   FETCH c_source_code INTO l_source_code_id;
   CLOSE c_source_code;

   IF l_source_code_id IS NOT NULL THEN
      AMS_Utility_PVT.error_message('AMS_CAMP_DUPLICATE_CODE'); --reuse message
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

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
      p_sourcecode_for     => 'EONE',
      p_sourcecode_for_id  => p_evo_id,
      x_sourcecode_id      => l_source_code_id
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RAISE FND_API.g_exc_error;
   END IF;

END update_eone_source_code;



----------------------------------------------------------------------------------------------------------------
-- PROCEDURE
--    udpate_event_status
--
-- HISTORY
--    09/25/00  mukumar  Created.
--    25-Oct-2002 soagrawa  Added code for automatic budget line approval enh# 2445453
--    17-Mar-2005 spendem   code inclusions for raising a business event on UserStatus change. dummy enh # 3805347
-------------------------------------------------------------------------------------------------------------------
PROCEDURE update_event_status(
   p_event_id    IN  NUMBER,
   p_event_activity_type  IN VARCHAR2,
   p_user_status_id       IN NUMBER,
   p_fund_amount_tc       IN NUMBER,
   p_currency_code_tc     IN VARCHAR2
)
IS

   l_old_status_id     NUMBER;
   l_old_status_id1    NUMBER;
   l_new_status_id     NUMBER;
   l_deny_status_id    NUMBER;
   l_object_version    NUMBER;
   l_object_version1   NUMBER;
   l_approval_type     VARCHAR2(30);
   l_return_status     VARCHAR2(1);
   l_bgtsrc_exist      NUMBER;
   l_custom_setup_id   NUMBER;
   l_custom_setup_id1  NUMBER;
   l_event_header_id   NUMBER;
   l_event_offer_id    NUMBER;
   l_program_id        NUMBER;
   l_parent_id         NUMBER;
   l_parent_system_status_code  VARCHAR2(30);
   l_system_status_code  VARCHAR2(30);
   l_msg_count          NUMBER ;
   l_msg_data           VARCHAR2(2000);
   l_old_status_code    VARCHAR2(30);   -- added as per enh # 3805347
   l_new_status_code    VARCHAR2(30);   -- added as per enh # 3805347

   CURSOR c_old_status_EVEH (l_event_header_id IN NUMBER) IS
   SELECT user_status_id, object_version_number, setup_type_id, program_id
   FROM   ams_event_headers_all_b
   WHERE  event_header_id = l_event_header_id;

   -- Modified the cursor as per enh # 3805347
   CURSOR c_old_status_EVEO IS
   SELECT user_status_id, object_version_number, setup_type_id, event_header_id, system_status_code
   FROM   ams_event_offers_all_b
   WHERE  event_offer_id = p_event_id;

   -- Modified the cursor as per enh # 3805347
   CURSOR c_old_status_EONE IS
   SELECT user_status_id, object_version_number, setup_type_id, parent_id, system_status_code
   FROM   ams_event_offers_all_b
   WHERE  event_offer_id = p_event_id;

   /* Cursor to get the user status id of  program */
   CURSOR c_PROGRAM_status (l_event_offer_id IN NUMBER) IS
   SELECT user_status_id
   FROM   ams_campaigns_all_b
   WHERE  campaign_id = l_event_offer_id;



   CURSOR c_bgtsrc_exist IS
   SELECT 1
     FROM DUAL
    WHERE EXISTS(
          SELECT 1
            FROM ozf_act_budgets --anchaudh: changed call from ams_act_budgets to ozf_act_budgets : bug#3453430
           WHERE act_budget_used_by_id = p_event_id
             AND arc_act_budget_used_by = p_event_activity_type);

BEGIN

    IF p_event_activity_type = 'EVEH' THEN

      OPEN c_old_status_EVEH(p_event_id);
      FETCH c_old_status_EVEH INTO l_old_status_id, l_object_version, l_custom_setup_id, l_program_id;
      CLOSE c_old_status_EVEH;

     IF l_program_id IS NOT NULL then

         OPEN c_PROGRAM_status(l_program_id);
         FETCH c_PROGRAM_status INTO l_old_status_id1;
         CLOSE c_PROGRAM_status;

      END IF;

      l_system_status_code := AMS_Utility_PVT.get_system_status_code(p_user_status_id);
      l_parent_system_status_code := AMS_Utility_PVT.get_system_status_code(l_old_status_id1);

      If l_system_status_code = 'ACTIVE' and l_parent_system_status_code <> 'ACTIVE'THEN
         FND_MESSAGE.set_name('AMS', 'AMS_PROGRAM_NOT_ACTIVE');
         FND_MSG_PUB.add;
         RAISE FND_API.g_exc_error;
      END IF;

    ELSIF p_event_activity_type ='EVEO' THEN

      -- Modified the cursor as per enh # 3805347
      OPEN c_old_status_EVEO;
      FETCH c_old_status_EVEO INTO l_old_status_id, l_object_version, l_custom_setup_id, l_event_header_id, l_old_status_code;
      CLOSE c_old_status_EVEO;

      IF l_event_header_id IS NOT NULL then

         OPEN c_old_status_EVEH(l_event_header_id);
         FETCH c_old_status_EVEH INTO l_old_status_id1, l_object_version1, l_custom_setup_id1, l_program_id;
         CLOSE c_old_status_EVEH;

      END IF;

      l_system_status_code := AMS_Utility_PVT.get_system_status_code(p_user_status_id);
      l_parent_system_status_code := AMS_Utility_PVT.get_system_status_code(l_old_status_id1);

      If l_system_status_code = 'ACTIVE' and l_parent_system_status_code <> 'ACTIVE'THEN
         -- changed 'AMS_EVENT_NOT ACTIVE' to 'AMS_EVENT_NOT_ACTIVE'
         FND_MESSAGE.set_name('AMS', 'AMS_EVENT_NOT_ACTIVE');
         FND_MSG_PUB.add;
         RAISE FND_API.g_exc_error;
      END IF;

    ELSIF p_event_activity_type ='EONE' THEN

      -- Modified the cursor as per enh # 3805347
      OPEN c_old_status_EONE;
      FETCH c_old_status_EONE INTO l_old_status_id, l_object_version, l_custom_setup_id, l_parent_id, l_old_status_code;
      CLOSE c_old_status_EONE;

        IF l_parent_id IS NOT NULL then

         OPEN c_PROGRAM_status(l_parent_id);
         FETCH c_PROGRAM_status INTO l_old_status_id1;
         CLOSE c_PROGRAM_status;

      END IF;

      l_system_status_code := AMS_Utility_PVT.get_system_status_code(p_user_status_id);
      l_parent_system_status_code := AMS_Utility_PVT.get_system_status_code(l_old_status_id1);

      If l_system_status_code = 'ACTIVE' and l_parent_system_status_code <> 'ACTIVE'THEN
         FND_MESSAGE.set_name('AMS', 'AMS_PROGRAM_NOT_ACTIVE');
         FND_MSG_PUB.add;
         RAISE FND_API.g_exc_error;
      END IF;

    END IF;

    /* If there is no chnage in  user status, just return i.e. if the status is new, and
       user again selects new as user status .
     */

    IF l_old_status_id = p_user_status_id THEN
      RETURN;
    END IF;

-- Call the procedure which will make the new status as CLOSED if it is COMPLETED.

-- Call the procedure which does lead import.

-- The following procedure checks whether the status change is allowed from the
-- approval perspective.
-- So the code which does the Lead Import has to be called before this line.

   AMS_Utility_PVT.check_new_status_change(
      p_object_type      => p_event_activity_type,
      p_object_id        => p_event_id,
      p_old_status_id    => l_old_status_id,
      p_new_status_id    => p_user_status_id,
      p_custom_setup_id    => l_custom_setup_id,
      x_approval_type    => l_approval_type,
      x_return_status    => l_return_status
   );

   IF l_return_status <> FND_API.g_ret_sts_success THEN
      RAISE FND_API.g_exc_error;
   END IF;

   IF l_approval_type = 'BUDGET' THEN
/* commented  on oct 30 to support zero budget approval
-- Check if budget source has been assigned to the event.
     OPEN c_bgtsrc_exist;
     FETCH c_bgtsrc_exist INTO l_bgtsrc_exist;
     CLOSE c_bgtsrc_exist;
     IF l_bgtsrc_exist IS NOT NULL THEN

        -- Also check if budget amount has been specified.
        IF p_fund_amount_tc IS NOT NULL
           AND p_currency_code_tc IS NOT NULL
           AND p_fund_amount_tc <> FND_API.g_miss_num
          AND p_currency_code_tc <> FND_API.g_miss_char
          THEN
     */
           l_new_status_id := AMS_Utility_PVT.get_default_user_status(
             'AMS_EVENT_STATUS',
             'SUBMITTED_BA'
           );
           l_deny_status_id := AMS_Utility_PVT.get_default_user_status(
             'AMS_EVENT_STATUS',
             'DENIED_BA'
           );
           AMS_Approval_PVT.StartProcess(
             p_activity_type => p_event_activity_type,
             p_activity_id => p_event_id,
             p_approval_type => l_approval_type,
             p_object_version_number => l_object_version,
             p_orig_stat_id => l_old_status_id,
             p_new_stat_id => p_user_status_id,
             p_reject_stat_id => l_deny_status_id,
             p_requester_userid =>
             AMS_Utility_PVT.get_resource_id(FND_GLOBAL.user_id),
             p_workflowprocess => 'AMS_APPROVAL',
             p_item_type => 'AMSAPRV'
           );
/*          ELSE
            AMS_Utility_PVT.error_message('AMS_EVE_NO_BGT_AMT');
            -- Please Specify the Budget Amount Before seeking Approval! Error.
            RAISE FND_API.g_exc_error;
          END IF;
     ELSE
        AMS_Utility_PVT.error_message('AMS_EVE_NO_BGT_SRC');
        -- Please Specify Budget Source Before seeking Approval! Error.
        RAISE FND_API.g_exc_error;
     END IF;
   */
   ELSIF l_approval_type = 'THEME' THEN
      l_new_status_id := AMS_Utility_PVT.get_default_user_status(
         'AMS_EVENT_STATUS',
         'SUBMITTED_TA'
      );
      l_deny_status_id := AMS_Utility_PVT.get_default_user_status(
         'AMS_EVENT_STATUS',
         'DENIED_TA'
      );
      AMS_Approval_PVT.StartProcess(
         p_activity_type => p_event_activity_type,
         p_activity_id => p_event_id,
         p_approval_type => 'CONCEPT',
         p_object_version_number => l_object_version,
         p_orig_stat_id => l_old_status_id,
         p_new_stat_id => p_user_status_id,
         p_reject_stat_id => l_deny_status_id,
         p_requester_userid =>
       AMS_Utility_PVT.get_resource_id(FND_GLOBAL.user_id),
         p_workflowprocess => 'AMS_CONCEPT_APPROVAL',
         p_item_type => 'AMSAPRV'
      );
   ELSE

      -- Following budget line api call added by soagrawa on 25-oct-2002
      -- for enhancement # 2445453
      If l_system_status_code = 'ACTIVE'
      THEN
         --anchaudh: changed call from ams_budgetapproval_pvt to ozf_budget_approval_pvt: bug#3453430
         OZF_BudgetApproval_PVT.budget_request_approval(
             p_init_msg_list         => FND_API.G_FALSE
             , p_api_version           => 1.0
             , p_commit                => FND_API.G_False
             , x_return_status         => l_return_status
             , x_msg_count             => l_msg_count
             , x_msg_data              => l_msg_data
             , p_object_type           => p_event_activity_type
             , p_object_id             => p_event_id
             -- , x_status_code           =>
             );

         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      END IF;
      l_new_status_id := p_user_status_id;
   END IF;

   -- Update header or offers table with the new status

    IF p_event_activity_type = 'EVEH' THEN
     /*  UPDATE ams_event_headers_all_b
       SET  user_status_id = l_new_status_id,
         system_status_code = AMS_Utility_PVT.get_system_status_code(l_new_status_id),
         last_status_date = SYSDATE
       WHERE  event_header_id = p_event_id; */

       AMS_EvhRules_PVT.Update_Event_Header_Status(p_event_header_id => p_event_id,
                                 p_new_status_id => l_new_status_id,
                                 p_new_status_code => AMS_Utility_PVT.get_system_status_code(l_new_status_id)
                                 );

    ELSIF p_event_activity_type ='EVEO' THEN
         UPDATE ams_event_offers_all_b
         SET  user_status_id = l_new_status_id,
              system_status_code = AMS_Utility_PVT.get_system_status_code(l_new_status_id),
              last_status_date = SYSDATE
         WHERE  event_offer_id = p_event_id;

         l_new_status_code := AMS_Utility_PVT.get_system_status_code(l_new_status_id); -- added as per enh # 3805347

	 -- call to api to raise business event, as per enh # 3805347
	 AMS_SCHEDULERULES_PVT.RAISE_BE_ON_STATUS_CHANGE(p_obj_id => p_event_id,
							 p_obj_type => p_event_activity_type,
							 p_old_status_code => l_old_status_code,
							 p_new_status_code => l_new_status_code );



    ELSIF p_event_activity_type ='EONE' THEN
         UPDATE ams_event_offers_all_b
         SET  user_status_id = l_new_status_id,
              system_status_code = AMS_Utility_PVT.get_system_status_code(l_new_status_id),
              last_status_date = SYSDATE
         WHERE  event_offer_id = p_event_id;

     l_new_status_code := AMS_Utility_PVT.get_system_status_code(l_new_status_id); -- added as per enh # 3805347

     -- call to api to raise business event, as per enh # 3805347
     AMS_SCHEDULERULES_PVT.RAISE_BE_ON_STATUS_CHANGE(p_obj_id => p_event_id,
					             p_obj_type => p_event_activity_type,
     					             p_old_status_code => l_old_status_code,
					             p_new_status_code => l_new_status_code );


    END IF;
-- GDEODHAR : Added the following code :
-- Call the procedure which does lead import if necessary.
-- Lead Import will be done only if the new status is CLOSED.
-- Assumption : In Events area : if the status is changed to COMPLETED,
--              it will be automatically changed to CLOSED before
--              this point.

   --IF l_new_status_id = 7 THEN -- The following is better than hardcoding 7 here

   -- 05-jan-2004 soagrawa  Fixed bug# 3100394 related to completing an event header
   IF AMS_Utility_PVT.get_system_status_code(l_new_status_id) = 'COMPLETED'
   THEN
      IF p_event_activity_type = 'EVEH'
      THEN
         Complete_Event_Offers(p_eveh_id => p_event_id);
      ELSIF ((p_event_activity_type = 'EONE') OR (p_event_activity_type = 'EVEO'))
      THEN
         -- Call the lead import procedure.
         process_leads(p_event_id => p_event_id);
      END IF;
   END IF;

END update_event_status;


--=======================================================================
-- PROCEDURE
--    process_leads
--
-- NOTES
--    This procedure is created to create leads in OTS based on the event
--    registrations and attendance.
--    When the status of the event schedule is changed to CLOSED, this
--    procedure will be called.
--    This method should be pulled out from here and be created as a concurrent
--    program as this operation is more suited for batch operations.
--
-- HISTORY
--    08/02/2001    gdeodhar   Created.
--    22-oct-2002   soagrawa   Modified API signature to take obj type and obj srccd
--                             to be able to generate leads against non-event src cd.
--    05-feb-2003   soagrawa   Bug# 2787303: consolidated 2 separate cursors into 1 cursor
--=======================================================================

PROCEDURE process_leads(
   p_event_id             IN  NUMBER
 , p_obj_type             IN  VARCHAR2 := NULL
 , p_obj_srccd            IN  VARCHAR2 := NULL
)
IS
   l_lit_batch_id NUMBER;              --Batch ID of this Lead Import process for the lead interface tabel.
   l_reg_lead_flag VARCHAR2(1);        --Value of CREATE_REGISTRANT_LEAD_FLAG from ams_event_offers_all_b.
   l_atnd_lead_flag VARCHAR2(1);       --Value of CREATE_ATTENDANT_LEAD_FLAG from ams_event_offers_all_b.
   l_evnt_sched_src_cd VARCHAR2(30);   --Value of the source code for event schedule.
   l_loaded_rows NUMBER;               --holds the count of rows that were inserted in the import interface table for this batch.
   l_request_id NUMBER;                --request id. Used when we call the concurrent program.
   l_return_status VARCHAR2(1);        --holds the status coming back from other procedure calls.

   CURSOR c_batch_id IS                --Cursor to pick up the Batch ID.
   SELECT as_sl_imp_batch_s.NEXTVAL
     FROM DUAL;

   CURSOR c_get_evnt_sched_src_cd(event_id_in IN NUMBER) IS
   SELECT source_code
     FROM ams_event_offers_all_b
    WHERE event_offer_id = event_id_in;

   CURSOR c_get_reg_lead_flag(event_id_in IN NUMBER) IS
   SELECT create_registrant_lead_flag
     FROM ams_event_offers_all_b
    WHERE event_offer_id = event_id_in;

   CURSOR c_get_atnd_lead_flag(event_id_in IN NUMBER) IS
   SELECT create_attendant_lead_flag
     FROM ams_event_offers_all_b
    WHERE event_offer_id = event_id_in;

   -- following cursor added by soagrawa on 22-oct-2002
   -- to merge the above 3 cursors into 1 single cursor
   -- while fixing bug# 2594717
   CURSOR c_get_evnt_details(event_id_in IN NUMBER) IS
   SELECT source_code, create_registrant_lead_flag, create_attendant_lead_flag
     FROM ams_event_offers_all_b
    WHERE event_offer_id = event_id_in;


   -- The following is actually : create leads for enrollees.
   CURSOR c_get_registrant_for_lead (event_id_in IN NUMBER) IS
   SELECT registrant_party_id
          , registrant_contact_id
          , attendant_party_id
          , attendant_contact_id
     FROM ams_event_registrations
    WHERE event_offer_id = event_id_in
      AND system_status_code = 'REGISTERED'  -- In future when we kill the REGISTERED status and leave ENROLLED, change this to ENROLLED.
      AND active_flag = 'Y';

   l_registrant_for_lead_rec c_get_registrant_for_lead%ROWTYPE;

   CURSOR c_get_attendant_for_lead (event_id_in IN NUMBER) IS
   SELECT registrant_party_id
          , registrant_contact_id
          , attendant_party_id
          , attendant_contact_id
     FROM ams_event_registrations
    WHERE event_offer_id = event_id_in
      AND system_status_code = 'REGISTERED'  -- In future when we kill the REGISTERED status and leave ENROLLED, change this to ENROLLED.
      AND attended_flag = 'Y'
      AND active_flag = 'Y';

   l_attendant_for_lead_rec c_get_attendant_for_lead%ROWTYPE;

   CURSOR c_loaded_rows_for_lead (batch_id_in IN NUMBER) IS
      SELECT COUNT(*)
        FROM as_import_interface
       WHERE batch_id = batch_id_in;

   -- dbiswas 23-apr-2003 added cursor for NI bug# 2610067 carryforward to next releases
   CURSOR c_get_person_id (rel_party_id_in IN NUMBER) IS
   SELECT subject_id  -- person id
     FROM hz_relationships -- anchaudh: bug fix 3764927.
    WHERE party_id = rel_party_id_in
      AND directional_flag = 'F';

     l_reg_att_party_id   NUMBER;

   -- soagrawa 05-feb-2003 bug# 2787303
   CURSOR c_get_reg_att_for_lead (event_id_in IN NUMBER) IS
   SELECT reg.registrant_party_id party_id
          , reg.registrant_contact_id contact_id
     FROM ams_event_registrations reg,
          ams_event_offers_all_b event
    WHERE reg.event_offer_id = event_id_in
      AND reg.system_status_code = 'REGISTERED'  -- In future when we kill the REGISTERED status and leave ENROLLED, change this to ENROLLED.
      AND reg.active_flag = 'Y'
      AND event.event_offer_id = reg.event_offer_id
      AND event.create_registrant_lead_flag = 'Y'
                  UNION
   SELECT reg.attendant_party_id party_id
          , reg.attendant_contact_id contact_id
     FROM ams_event_registrations reg,
          ams_event_offers_all_b event
    WHERE reg.event_offer_id = event_id_in
      AND reg.system_status_code = 'REGISTERED'  -- In future when we kill the REGISTERED status and leave ENROLLED, change this to ENROLLED.
      AND reg.active_flag = 'Y'
      AND reg.attended_flag = 'Y'
      AND event.event_offer_id = reg.event_offer_id
      AND event.create_attendant_lead_flag = 'Y';

   l_reg_att_for_lead_rec c_get_reg_att_for_lead%ROWTYPE;

BEGIN
   -- Pick up the Batch ID from the sequence.
   -- This will be recorded in the Lead Import Interface table for each lead we create.

   OPEN c_batch_id;
   FETCH c_batch_id INTO l_lit_batch_id;
   CLOSE c_batch_id;

   -- Call to the following 3 separate cursors compiled into one single cursor
   -- by soagrawa on 22-oct-2002
   -- while fixing bug# 2594717
   /*
   -- Pick up the value of SOURCE_CODE for the event shchedule.

   OPEN c_get_evnt_sched_src_cd(p_event_id);
   FETCH c_get_evnt_sched_src_cd INTO l_evnt_sched_src_cd;
   CLOSE c_get_evnt_sched_src_cd;

   -- Pick up the value of CREATE_REGISTRANT_LEAD_FLAG for the event shchedule.
   -- This is actually for CREATE_ENROLLEE_AS_LEAD.

   OPEN c_get_reg_lead_flag(p_event_id);
   FETCH c_get_reg_lead_flag INTO l_reg_lead_flag;
   CLOSE c_get_reg_lead_flag;

   -- Pick up the value of CREATE_ATTENDANT_LEAD_FLAG for the event shchedule.

   OPEN c_get_atnd_lead_flag(p_event_id);
   FETCH c_get_atnd_lead_flag INTO l_atnd_lead_flag;
   CLOSE c_get_atnd_lead_flag;
   */

   OPEN  c_get_evnt_details(p_event_id);
   FETCH c_get_evnt_details INTO l_evnt_sched_src_cd, l_reg_lead_flag, l_atnd_lead_flag;
   CLOSE c_get_evnt_details;

   IF p_obj_type  IS NOT NULL
   AND p_obj_srccd IS NOT NULL
   THEN
        l_evnt_sched_src_cd := p_obj_srccd;
   END IF;

   -- soagrawa 05-feb-2003 bug# 2787303
   -- consolidated 2 separate cursors into 1 cursor
/*
   IF l_reg_lead_flag = 'Y'
   THEN
      -- Pick up each record from ams_event_registrations for this event schedule.
      -- Create a lead record for the Registrant in Lead Import Interface table.
      -- Mark the record to say the the Lead is created for the Registrant.

      OPEN c_get_registrant_for_lead(p_event_id);
      LOOP
         FETCH c_get_registrant_for_lead INTO l_registrant_for_lead_rec;
         EXIT WHEN c_get_registrant_for_lead%NOTFOUND;

         -- Assumption : attendant_party_id has party_id from HZ_PARTIES
         -- against whom the lead has to be created.
         -- This is actually the enrollee and not the person who calls in (the call center) to do the registrations.


      -- insert_lead_rec(l_registrant_for_lead_rec.attendant_party_id
      --                   ,l_lit_batch_id
      --                   ,p_event_id
      --                   ,l_evnt_sched_src_cd);



      if (l_registrant_for_lead_rec.registrant_party_id = l_registrant_for_lead_rec.registrant_contact_id)
      then
          insert_lead_rec(
                 p_party_id        => l_registrant_for_lead_rec.registrant_party_id
                  ,p_lit_batch_id    => l_lit_batch_id
                  ,p_event_id        => p_event_id
                  ,p_source_code     => l_evnt_sched_src_cd);
      else

          insert_lead_rec(
                 p_party_id        => l_registrant_for_lead_rec.registrant_party_id
                  ,p_lit_batch_id    => l_lit_batch_id
                  ,p_event_id        => p_event_id
                  ,p_source_code     => l_evnt_sched_src_cd
               ,p_contact_party_id => l_registrant_for_lead_rec.registrant_contact_id);

      end if;



      END LOOP;
      CLOSE c_get_registrant_for_lead;

   END IF;

   IF l_atnd_lead_flag = 'Y'
   THEN
      -- Pick up each record from ams_event_registrations for this event schedule where the enrollee has attended the event.
      -- This is indicated by a flag : ATTENDED_FLAG in ams_event_registrations.
      -- Create a lead record for the Attendee in Lead Import Interface table.
      -- Mark the record to say the the Lead is created for the Attendee.

      OPEN c_get_attendant_for_lead(p_event_id);
      LOOP
         FETCH c_get_attendant_for_lead INTO l_attendant_for_lead_rec;
         EXIT WHEN c_get_attendant_for_lead%NOTFOUND;

         -- Assumption : registrant_party_id has party_id from HZ_PARTIES
         -- against whom the lead has to be created.

         --insert_lead_rec(l_attendant_for_lead_rec.attendant_party_id
         --               ,l_lit_batch_id
         --               ,p_event_id
         --               ,l_evnt_sched_src_cd);
         --
         --
   if (l_attendant_for_lead_rec.attendant_party_id = l_attendant_for_lead_rec.attendant_contact_id)
   then
           insert_lead_rec(
                 p_party_id         => l_attendant_for_lead_rec.attendant_party_id
                  ,p_lit_batch_id    => l_lit_batch_id
                  ,p_event_id        => p_event_id
                  ,p_source_code     => l_evnt_sched_src_cd);
   else
            insert_lead_rec(
                 p_party_id         => l_attendant_for_lead_rec.attendant_party_id
                  ,p_lit_batch_id    => l_lit_batch_id
                  ,p_event_id        => p_event_id
                  ,p_source_code     => l_evnt_sched_src_cd
               ,p_contact_party_id => l_attendant_for_lead_rec.attendant_contact_id);

   end if;


      END LOOP;
      CLOSE c_get_attendant_for_lead;

   END IF;
*/

-- soagrawa 05-feb-2003  bug# 2787303
-- added processing based on new cursor
      OPEN c_get_reg_att_for_lead(p_event_id);
      LOOP
         FETCH c_get_reg_att_for_lead INTO l_reg_att_for_lead_rec;
         EXIT WHEN c_get_reg_att_for_lead%NOTFOUND;

            if (l_reg_att_for_lead_rec.party_id = l_reg_att_for_lead_rec.contact_id)
            then
                    insert_lead_rec(
                          p_party_id         => l_reg_att_for_lead_rec.party_id
                           ,p_lit_batch_id    => l_lit_batch_id
                           ,p_event_id        => p_event_id
                           ,p_source_code     => l_evnt_sched_src_cd);
            else
            -- b2b
            -- dbiswas 23-apr-2003 modified for NI bug# 2610067
               OPEN c_get_person_id(l_reg_att_for_lead_rec.contact_id);
               FETCH c_get_person_id INTO l_reg_att_party_id;
               CLOSE c_get_person_id;

                     insert_lead_rec(
                            p_party_id         => l_reg_att_for_lead_rec.party_id
                           ,p_lit_batch_id    => l_lit_batch_id
                           ,p_event_id        => p_event_id
                           ,p_source_code     => l_evnt_sched_src_cd
                          -- ,p_contact_party_id => l_reg_att_for_lead_rec.contact_id);
                           ,p_contact_party_id => l_reg_att_party_id);

            end if;


      END LOOP;
      CLOSE c_get_reg_att_for_lead;



   -- At this point we will have added all the records in as_import_interface table.
   -- Now we can call the concurrent program for lead process.

   OPEN c_loaded_rows_for_lead(l_lit_batch_id);
   FETCH c_loaded_rows_for_lead INTO l_loaded_rows;
   CLOSE c_loaded_rows_for_lead;

   -- Later add a new message for the following.
   -- Using the one from Lists area for now.
   FND_MESSAGE.set_name ('AMS', 'AMS_IMP_LOADED_NO_ROWS');
   FND_MESSAGE.set_token ('NUM_ROWS', l_loaded_rows);

   l_request_id := 0;

   -- Call the concurrent program for leads.
   l_request_id := FND_REQUEST.SUBMIT_REQUEST (
                   application       => 'AS',
                   program           => 'ASXSLIMP',
                   argument1         => 'MARKETING', --'NEW'
                   argument2         => NULL,
                   argument3         => l_lit_batch_id --NULL
                  );

   AMS_Utility_PVT.Create_Log (
                  x_return_status   => l_return_status,
                  p_arc_log_used_by => 'EREG',
                  p_log_used_by_id  => p_event_id,
                  p_msg_data        => 'Starting LEAD program (ASXSLIMP) -- concurrent program_id is ' || to_char(l_request_id),
                  p_msg_type        => 'DEBUG'
                 );

   IF l_request_id = 0 THEN
      RAISE FND_API.g_exc_unexpected_error;
      --Change the above to raise a specific error later.
   END IF;

   -- Import completed successfully
   -- Later add a new message for the following.
   -- Using the one from Lists area.
   FND_MESSAGE.set_name ('AMS', 'AMS_IMP_LOAD_COMPLETE');
   FND_MESSAGE.set_token ('REQUEST_ID', l_request_id);

END process_leads;

--=======================================================================
-- PROCEDURE
--    insert_lead_rec
--
-- NOTES
--    This procedure actually inserts a record in the lead import interface
--    table.
--
-- HISTORY
--    08/13/2001    gdeodhar   Created.
--=======================================================================

PROCEDURE insert_lead_rec(
    p_party_id             IN  NUMBER
   ,p_lit_batch_id        IN  NUMBER
   ,p_event_id            IN  NUMBER
   ,p_source_code         IN  VARCHAR2
   ,p_contact_party_id     IN NUMBER := NULL
)
IS
   l_seq NUMBER;                     --Next value for the primary key in the import lead interface table.
   l_party_type VARCHAR2(30);        --party_type for the p_party_id.
   l_party_site_id NUMBER;           --primary party_site_id for the party_id from hz_party_sites table.

   CURSOR c_rec_id IS                --Cursor to pick up the next value in the sequence.
   SELECT as_import_interface_s.NEXTVAL
     FROM DUAL;

                                     --Cursor to pick up the data from HZ_PARTIES table.
   CURSOR c_party_info (party_id_in IN NUMBER) IS
   SELECT party_type
     FROM hz_parties
    WHERE party_id = party_id_in;

                                     --Cursor to pick up the data from HZ_PARTIE_SITES table.
   CURSOR c_party_site_info (party_id_in IN NUMBER) IS
   SELECT party_site_id
     FROM hz_party_sites
    WHERE party_id = party_id_in
      AND identifying_address_flag = 'Y';

BEGIN
   -- Pick up the next value from the sequence.
   -- This will be recorded in the Lead Import Interface table as the primary key.

   OPEN c_rec_id;
   FETCH c_rec_id INTO l_seq;
   CLOSE c_rec_id;

   -- pick up the party_type.

   OPEN c_party_info(p_party_id);
   FETCH c_party_info INTO l_party_type;
   CLOSE c_party_info;

   -- pick up the party_site_id.

   OPEN c_party_site_info(p_party_id);
   FETCH c_party_site_info INTO l_party_site_id;
   CLOSE c_party_site_info;

   -- insert the record in as_import_interface table.

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
   , LEAD_NOTE                       --         VARCHAR2(2000)
   , SOURCE_SYSTEM                   --         VARCHAR2(30)
   , PARTY_TYPE                      --         VARCHAR2(30)
   , BATCH_ID                        --         NUMBER(15)
   , PARTY_ID                        --         NUMBER(15)
   , PARTY_SITE_ID                   --         NUMBER(15)
   ,load_status
   ,contact_party_id
   )
   VALUES
   (
    l_seq                                          --IMPORT_INTERFACE_ID   --NOT NULL NUMBER
   , SYSDATE                                       --LAST_UPDATE_DATE      --NOT NULL DATE
   , FND_GLOBAL.user_id                            --LAST_UPDATED_BY       --NOT NULL NUMBER
   , SYSDATE                                       --CREATION_DATE         --NOT NULL DATE
   , FND_GLOBAL.user_id                            --CREATED_BY            --NOT NULL NUMBER
   , FND_GLOBAL.conc_login_id                      --LAST_UPDATE_LOGIN     --NOT NULL NUMBER
   , 'LEAD_LOAD'                                   --LOAD_TYPE             --         VARCHAR2(20)
   , SYSDATE                                       --LOAD_DATE             --NOT NULL DATE
   , p_source_code                                 --PROMOTION_CODE        --         VARCHAR2(50)
   , FND_PROFILE.Value('AS_DEFAULT_LEAD_STATUS')   --STATUS_CODE           --         VARCHAR2(30)
   , 'Event Registrant is created as a lead.'      --LEAD_NOTE             --         VARCHAR2(2000)
   , 'MARKETING'                                   --SOURCE_SYSTEM         --         VARCHAR2(30)
   , l_party_type                                  --PARTY_TYPE            --         VARCHAR2(30)
   , p_lit_batch_id                                --BATCH_ID              --         NUMBER(15)
   , p_party_id                                    --PARTY_ID              --         NUMBER(15)
   , l_party_site_id                               --PARTY_SITE_ID         --         NUMBER(15)
   ,'NEW'
   , p_contact_party_id                                      -- load_status
   );

null;
END insert_lead_rec;

--=======================================================================
-- PROCEDURE
--    Convert_Evnt_Currency
-- NOTES
--    This procedure is created to convert the transaction currency into
--    functional currency.
-- HISTORY
--    10/30/2000    mukumar   Created.
--=======================================================================
PROCEDURE Convert_Evnt_Currency(
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

END Convert_Evnt_Currency;

--=======================================================================
-- PROCEDURE
--    Add_Update_Access_record
-- NOTES
--    This procedure is to create or update Acess_record(owner record)
-- HISTORY
--    10/30/2000    mukumar   Created.
--=======================================================================
PROCEDURE Add_Update_Access_record(
   p_object_type     IN    VARCHAR2,
   p_object_id      IN    NUMBER,
   p_Owner_user_id  IN    NUMBER,
   x_return_status    OUT NOCOPY VARCHAR2,
   x_msg_count        OUT NOCOPY VARCHAR2,
   x_msg_data         OUT NOCOPY VARCHAR2
   )
   IS

   l_owner_user_id  NUMBER;
   l_Access_rec     AMS_access_PVT.access_rec_type;
   l_access_id     NUMBER;
   l_ret_stat      VARCHAR2(1);
   l_msg_data      VARCHAR2(2000);
   l_msg_cnt       NUMBER;

   CURSOR c_get_access_data(object_type_in IN VARCHAR2, object_id_in IN NUMBER, owner_user_id_in  IN NUMBER) IS
   SELECT USER_OR_ROLE_ID
   FROM AMS_ACT_ACCESS
   WHERE ACT_ACCESS_TO_OBJECT_ID = object_id_in
     AND ARC_ACT_ACCESS_TO_OBJECT = object_type_in
     AND OWNER_FLAG = 'Y';
BEGIN
   open c_get_access_data(p_object_type, p_object_id, p_Owner_user_id);
   fetch c_get_access_data INTO l_owner_user_id;
   If c_get_access_data%NOTFOUND THEN
      l_Access_rec.ACT_ACCESS_TO_OBJECT_ID := p_object_id;
      l_Access_rec.ARC_ACT_ACCESS_TO_OBJECT := p_object_type;
      l_Access_rec.USER_OR_ROLE_ID := p_Owner_user_id;
      l_Access_rec.OBJECT_VERSION_NUMBER := 1;
      l_Access_rec.OWNER_FLAG := 'Y';
      l_Access_rec.ARC_USER_OR_ROLE_TYPE := 'USER';
      AMS_access_PVT.create_access(p_api_version => 1,
                                   x_return_status => x_return_status,
                                   x_msg_count => x_msg_count,
                                   x_msg_data => x_msg_data,
                                   p_access_rec => l_Access_rec,
                                   x_access_id  => l_access_id);
   ELSE
          IF (l_owner_user_id <> p_Owner_user_id) THEN
         AMS_access_PVT.update_object_owner(p_api_version => 1,
                        x_return_status => x_return_status,
                          x_msg_data => x_msg_data,
                          x_msg_count => x_msg_count,
                          p_object_type => p_object_type,
                          p_object_id => p_object_id,
                          p_resource_id => p_Owner_user_id,
                          p_old_resource_id => l_owner_user_id);
      END IF;
   END IF;

END Add_Update_Access_record;
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
--========================================================================
-- PROCEDURE
--    Create_list
--
-- PURPOSE
--
--
-- NOTE
--    The list of Type <> is created in list header and the association is
--    created in the ams_act_lists table.
--
-- HISTORY
--  06/01/01   mukumar    created
--
--========================================================================
PROCEDURE Create_list
               (p_evo_id     IN     NUMBER,
                p_evo_name   IN     VARCHAR2,
            p_obj_type   In     VARCHAR2,
                p_owner_id        IN     NUMBER)
IS
   l_return_status      VARCHAR2(1) ;
   l_msg_count          NUMBER ;
   l_msg_data           VARCHAR2(2000);
   l_api_version        NUMBER := 1.0 ;
   l_dummy              number;

   l_list_header_rec    AMS_ListHeader_Pvt.list_header_rec_type;
   l_act_list_rec       AMS_Act_List_Pvt.act_list_rec_type;
   l_list_header_id     NUMBER ;
   l_act_list_header_id NUMBER ;

   CURSOR c_evnt_name_exist(name_in in VARCHAR2) IS
   SELECT count(event_offer_name)
   FROM ams_event_offers_vl
   WHERE event_offer_name = name_in;
BEGIN
   null;
/*
   l_dummy := 0;
   --   AMS_ListHeader_PVT.init_listheader_rec(l_list_header_rec);
   open c_evnt_name_exist(p_evo_name);
   fetch c_evnt_name_exist into l_dummy;
   close c_evnt_name_exist;
   if l_dummy > 0 then
   l_list_header_rec.list_name :=  p_evo_name ||' - '||AMS_Utility_PVT.get_lookup_meaning('AMS_SYS_ARC_QUALIFIER','ILST') || to_char(l_dummy+1) ;
   else
   l_list_header_rec.list_name :=  p_evo_name ||' - '||AMS_Utility_PVT.get_lookup_meaning('AMS_SYS_ARC_QUALIFIER','ILST');
   end if;
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
   l_act_list_rec.list_used_by     := p_obj_type;
   l_act_list_rec.list_used_by_id  := p_evo_id ;
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

--==========================================================================
-- PROCEDURE
--    Cancel_RollupEvent
--
-- PURPOSE
--    Cancels the Rolup event and their associated event schedules. If the status
--    order rules does not permit it, it will error out.
--
-- NOTES
-- HISTORY
--    17-Jul-2001  mukumar    Created.
--==========================================================================

PROCEDURE Cancel_RollupEvent(p_evh_id   IN  NUMBER) IS

   CURSOR c_evh IS
      SELECT event_header_id,object_version_number,system_status_code
      FROM ams_event_headers_all_b
      WHERE  EVENT_HEADER_ID  = p_evh_id
      AND system_status_code <> 'CANCELLED' ;

   l_event_header_id        NUMBER ;
   l_obj_version        NUMBER ;
   l_status_code        VARCHAR2(30) ;
   l_status_id  NUMBER := AMS_Utility_PVT.get_default_user_status('AMS_EVENT_STATUS','CANCELLED');

BEGIN

   Cancel_Exec_Event(p_evh_id);
   OPEN c_evh ;
   LOOP
      FETCH c_evh INTO l_event_header_id,l_obj_version,l_status_code ;
      EXIT WHEN c_evh%NOTFOUND ;
      IF FND_API.G_TRUE = AMS_Utility_PVT.Check_Status_Change('AMS_EVENT_STATUS',l_status_code,'CANCELLED') THEN
         -- Can cancel the schedule
         UPDATE ams_event_headers_all_b
         SET    system_status_code = 'CANCELLED',
                last_status_date = SYSDATE,
                user_status_id = l_status_id,
                object_version_number = object_version_number + 1
         WHERE  event_header_id = l_event_header_id
         AND    object_version_number = l_obj_version ;

         IF (SQL%NOTFOUND) THEN
            CLOSE c_evh ;
            AMS_Utility_PVT.Error_Message('AMS_API_RECORD_NOT_FOUND');
            RAISE FND_API.g_exc_error;
         END IF;
      ELSE -- Can not cancel the schedule as the status is can not go to cancel from current status
         CLOSE c_evh;
         AMS_Utility_PVT.Error_Message('AMS_EVH_CANNOT_CANCEL');
         RAISE FND_API.g_exc_error;
      END IF ;

   END LOOP;
   CLOSE c_evh;


END Cancel_RollupEvent;

--================================================================================
-- PROCEDURE
--    Cancel_Exec_Event
--
-- PURPOSE
--    Cancels the Rolup event and their associated event schedules. If the status
--    order rules does not permit it, it will error out.
--
-- NOTES
-- HISTORY
--    17-Jul-2001  mukumar    Created.
--    17-Mar-2005  spendem    Modified to raise the business event. enh # 3805347
--==================================================================================

PROCEDURE Cancel_Exec_Event(p_evh_id   IN  NUMBER) IS

   -- Modified the select statement of the cursor to get event_object_type, as per enh # 3805347
   CURSOR c_evo_list IS
      SELECT event_offer_id,object_version_number,system_status_code, event_object_type
      FROM ams_event_offers_all_b
      WHERE  event_header_id  = p_evh_id
      AND system_status_code <> 'CANCELLED' ;

   l_event_offer_id     NUMBER ;
   l_obj_version        NUMBER ;
   l_status_code        VARCHAR2(30) ;
   l_status_id          NUMBER := AMS_Utility_PVT.get_default_user_status('AMS_EVENT_STATUS','CANCELLED');
   l_obj_type           VARCHAR2(4);  -- added as per enh # 3805347

BEGIN

   OPEN c_evo_list ;
   LOOP
      FETCH c_evo_list INTO l_event_offer_id,l_obj_version,l_status_code,l_obj_type ; -- modified as per enh # 3805347
      EXIT WHEN c_evo_list%NOTFOUND ;
      IF FND_API.G_TRUE = AMS_Utility_PVT.Check_Status_Change('AMS_EVENT_STATUS',l_status_code,'CANCELLED') THEN
         -- Can cancel the schedule
         UPDATE ams_event_offers_all_b
         SET    system_status_code = 'CANCELLED',
                last_status_date = SYSDATE,
                user_status_id = l_status_id,
                object_version_number = object_version_number + 1
         WHERE  event_offer_id = l_event_offer_id
         AND    object_version_number = l_obj_version ;

	 -- call to api to raise business event, as per enh # 3805347
         AMS_SCHEDULERULES_PVT.RAISE_BE_ON_STATUS_CHANGE(p_obj_id => l_event_offer_id,
							 p_obj_type => l_obj_type,
     							 p_old_status_code => l_status_code,
							 p_new_status_code => 'CANCELLED' );


         IF (SQL%NOTFOUND) THEN
            CLOSE c_evo_list ;
            AMS_Utility_PVT.Error_Message('AMS_API_RECORD_NOT_FOUND');
            RAISE FND_API.g_exc_error;
         END IF;
      ELSE -- Can not cancel the schedule as the status is can not go to cancel from current status
         CLOSE c_evo_list;
         AMS_Utility_PVT.Error_Message('AMS_EVO_CANNOT_CANCEL');
         RAISE FND_API.g_exc_error;
      END IF ;

   END LOOP;
   CLOSE c_evo_list;


END Cancel_exec_event;

--===============================================================================
-- PROCEDURE
--    Cancel_oneoff_Event
--
-- PURPOSE
--    Cancels the Rolup event and their associated event schedules. If the status
--    order rules does not permit it, it will error out.
--
-- NOTES
-- HISTORY
--    17-Jul-2001  mukumar    Created.
--    17-Mar-2005  spendem    Modified to raise the business event. enh # 3805347
--=================================================================================

PROCEDURE Cancel_oneoff_event(p_offer_id   IN  NUMBER) IS

   -- Modified the select statement of the cursor to get event_object_type, as per enh # 3805347
   CURSOR c_evo_list IS
      SELECT event_offer_id,object_version_number,system_status_code, event_object_type
      FROM ams_event_offers_all_b
      WHERE  event_offer_id  = p_offer_id
      AND system_status_code <> 'CANCELLED' ;

   l_event_offer_id     NUMBER ;
   l_obj_version        NUMBER ;
   l_status_code        VARCHAR2(30) ;
   l_status_id          NUMBER := AMS_Utility_PVT.get_default_user_status('AMS_EVENT_STATUS','CANCELLED');
   l_obj_type           VARCHAR2(4);   -- added as per enh # 3805347

BEGIN

   OPEN c_evo_list ;
   LOOP
      FETCH c_evo_list INTO l_event_offer_id,l_obj_version,l_status_code, l_obj_type;  -- Modified as per enh # 3805347
      EXIT WHEN c_evo_list%NOTFOUND ;
      IF FND_API.G_TRUE = AMS_Utility_PVT.Check_Status_Change('AMS_EVENT_STATUS',l_status_code,'CANCELLED') THEN
         -- Can cancel the schedule
         UPDATE ams_event_offers_all_b
         SET    system_status_code = 'CANCELLED',
                last_status_date = SYSDATE,
                user_status_id = l_status_id,
                object_version_number = object_version_number + 1
         WHERE  event_offer_id = l_event_offer_id
         AND    object_version_number = l_obj_version ;

	 -- call to api to raise business event, as per enh # 3805347
         AMS_SCHEDULERULES_PVT.RAISE_BE_ON_STATUS_CHANGE(p_obj_id => l_event_offer_id,
							 p_obj_type => l_obj_type,
     							 p_old_status_code => l_status_code,
							 p_new_status_code => 'CANCELLED' );


         IF (SQL%NOTFOUND) THEN
            CLOSE c_evo_list ;
            AMS_Utility_PVT.Error_Message('AMS_API_RECORD_NOT_FOUND');
            RAISE FND_API.g_exc_error;
         END IF;
      ELSE -- Can not cancel the schedule as the status is can not go to cancel from current status
         CLOSE c_evo_list;
         AMS_Utility_PVT.Error_Message('AMS_EONE_CANNOT_CANCEL');
         RAISE FND_API.g_exc_error;
      END IF ;

   END LOOP;
   CLOSE c_evo_list;


END Cancel_oneoff_event;

--==========================================================================
-- FUNCTION
--    cancel_all_Event
--
-- PURPOSE
--    completes all Rolup event and their associated event schedules. If the status
--    order rules does not permit it, it will error out.
--
-- NOTES
-- HISTORY
--    17-Jul-2001  mukumar    Created.
--    18-Feb-2002  GMADANA    Modified.
--                 Changed it from procrdure to Function which returns
--                 TRUE if all the event schedules or event headers attached
--                 to a given program id are CANCELLED or FALSE otherwise.
--==========================================================================


FUNCTION  Cancel_all_Event(p_prog_id   IN  NUMBER) RETURN VARCHAR2
IS

      CURSOR c_evh_list IS
      SELECT count(*)
      FROM ams_event_headers_all_b
      WHERE  program_id  = p_prog_id
      AND system_status_code NOT IN ('CANCELLED', 'ARCHIVED');

      CURSOR c_evo_list IS
      SELECT count(*)
      FROM ams_event_offers_all_b
      WHERE  parent_id  = p_prog_id
      AND event_object_type = 'EONE'
      AND parent_type = 'RCAM'
      AND system_status_code NOT IN ('CANCELLED', 'ARCHIVED');

   l_event_offers        NUMBER ;
   l_event_headers       NUMBER ;

BEGIN
      OPEN c_evh_list;
      FETCH c_evh_list INTO l_event_headers ;
      CLOSE c_evh_list;

      OPEN c_evo_list ;
      FETCH c_evo_list INTO l_event_offers;
      CLOSE c_evo_list;

      IF(l_event_offers > 0 OR l_event_headers > 0)
      THEN
         RETURN  FND_API.g_false;
      ELSE
         RETURN FND_API.g_true;
      END IF;

END Cancel_all_event;

--==========================================================================
-- PROCEDURE
--    complete_RollupEvent
--
-- PURPOSE
--    completes the Rolup event and their associated event schedules. If the status
--    order rules does not permit it, it will error out.
--
-- NOTES
-- HISTORY
--    17-Jul-2001  mukumar    Created.
--==========================================================================

PROCEDURE complete_RollupEvent(p_evh_id   IN  NUMBER) IS

   CURSOR c_evh IS
      SELECT event_header_id,object_version_number,system_status_code
      FROM ams_event_headers_all_b
      WHERE  EVENT_HEADER_ID  = p_evh_id
      AND system_status_code <> 'COMPLETED' ;

   l_event_header_id        NUMBER ;
   l_obj_version        NUMBER ;
   l_status_code        VARCHAR2(30) ;
   l_status_id  NUMBER := AMS_Utility_PVT.get_default_user_status('AMS_EVENT_STATUS','COMPLETED');

BEGIN

   complete_Exec_Event(p_evh_id);
   OPEN c_evh ;
   LOOP
      FETCH c_evh INTO l_event_header_id,l_obj_version,l_status_code ;
      EXIT WHEN c_evh%NOTFOUND ;
      IF FND_API.G_TRUE = AMS_Utility_PVT.Check_Status_Change('AMS_EVENT_STATUS',l_status_code,'COMPLETED') THEN
         -- Can complete the schedule
         UPDATE ams_event_headers_all_b
         SET    system_status_code = 'COMPLETED',
                last_status_date = SYSDATE,
                user_status_id = l_status_id,
                object_version_number = object_version_number + 1
         WHERE  event_header_id = l_event_header_id
         AND    object_version_number = l_obj_version ;

         IF (SQL%NOTFOUND) THEN
            CLOSE c_evh ;
            AMS_Utility_PVT.Error_Message('AMS_API_RECORD_NOT_FOUND');
            RAISE FND_API.g_exc_error;
         END IF;
      ELSE -- Can not complete the schedule as the status is can not go to complete from current status
         CLOSE c_evh;
         AMS_Utility_PVT.Error_Message('AMS_EVH_CANNOT_COMPLETE');
         RAISE FND_API.g_exc_error;
      END IF ;

   END LOOP;
   CLOSE c_evh;

END complete_RollupEvent;

--==================================================================================
-- PROCEDURE
--    complete_Exec_Event
--
-- PURPOSE
--    completes the Rolup event and their associated event schedules. If the status
--    order rules does not permit it, it will error out.
--
-- NOTES
-- HISTORY
--    17-Jul-2001  mukumar    Created.
--    17-Mar-2005  spendem    Modified to raise the business event. enh # 3805347
--===================================================================================

PROCEDURE complete_Exec_Event(p_evh_id   IN  NUMBER) IS

   -- Modified the select statement of the cursor to get event_object_type, as per enh # 3805347
   CURSOR c_evo_list IS
      SELECT event_offer_id,object_version_number,system_status_code, event_object_type
      FROM ams_event_offers_all_b
      WHERE  event_header_id  = p_evh_id
      AND system_status_code <> 'COMPLETED' ;

   l_event_offer_id     NUMBER ;
   l_obj_version        NUMBER ;
   l_status_code        VARCHAR2(30) ;
   l_status_id          NUMBER := AMS_Utility_PVT.get_default_user_status('AMS_EVENT_STATUS','COMPLETED');
   l_obj_type           VARCHAR2(4);  -- added as per enh # 3805347

BEGIN

   OPEN c_evo_list ;
   LOOP
      FETCH c_evo_list INTO l_event_offer_id,l_obj_version,l_status_code, l_obj_type;  -- Modified as per enh # 3805347.
      EXIT WHEN c_evo_list%NOTFOUND ;
      IF FND_API.G_TRUE = AMS_Utility_PVT.Check_Status_Change('AMS_EVENT_STATUS',l_status_code,'COMPLETED') THEN
         -- Can complete the schedule
         UPDATE ams_event_offers_all_b
         SET    system_status_code = 'COMPLETED',
                last_status_date = SYSDATE,
                user_status_id = l_status_id,
                object_version_number = object_version_number + 1
         WHERE  event_offer_id = l_event_offer_id
         AND    object_version_number = l_obj_version ;

	 -- call to api to raise business event, as per enh # 3805347
         AMS_SCHEDULERULES_PVT.RAISE_BE_ON_STATUS_CHANGE(p_obj_id => l_event_offer_id,
							 p_obj_type => l_obj_type,
							 p_old_status_code => l_status_code,
							 p_new_status_code => 'COMPLETED' );


         IF (SQL%NOTFOUND) THEN
            CLOSE c_evo_list ;
            AMS_Utility_PVT.Error_Message('AMS_API_RECORD_NOT_FOUND');
            RAISE FND_API.g_exc_error;
         END IF;
      ELSE -- Can not complete the schedule as the status is can not go to complete from current status
         CLOSE c_evo_list;
         AMS_Utility_PVT.Error_Message('AMS_EVO_CANNOT_COMPLETE');
         RAISE FND_API.g_exc_error;
      END IF ;

   END LOOP;
   CLOSE c_evo_list;

END complete_exec_event;

--=================================================================================
-- PROCEDURE
--    complete_oneoff_Event
--
-- PURPOSE
--    completes the Rolup event and their associated event schedules. If the status
--    order rules does not permit it, it will error out.
--
-- NOTES
-- HISTORY
--    17-Jul-2001  mukumar    Created.
--    17-Mar-2005  spendem    Modified to raise the business event. enh # 3805347
--===================================================================================

PROCEDURE complete_oneoff_event(p_offer_id   IN  NUMBER) IS

   -- Modified the select statement of the cursor to get event_object_type, as per enh # 3805347
   CURSOR c_evo_list IS
      SELECT event_offer_id,object_version_number,system_status_code, event_object_type
      FROM ams_event_offers_all_b
      WHERE  event_offer_id  = p_offer_id
      AND system_status_code <> 'COMPLETED';

   l_event_offer_id     NUMBER ;
   l_obj_version        NUMBER ;
   l_status_code        VARCHAR2(30) ;
   l_status_id          NUMBER := AMS_Utility_PVT.get_default_user_status('AMS_EVENT_STATUS','COMPLETED');
   l_obj_type           VARCHAR2(4);   -- added as per enh # 3805347

BEGIN

   OPEN c_evo_list ;
   LOOP
      FETCH c_evo_list INTO l_event_offer_id,l_obj_version,l_status_code, l_obj_type;   -- Modified as per enh # 3805347
      EXIT WHEN c_evo_list%NOTFOUND ;
      IF FND_API.G_TRUE = AMS_Utility_PVT.Check_Status_Change('AMS_EVENT_STATUS',l_status_code,'COMPLETED') THEN
         -- Can complete the schedule
         UPDATE ams_event_offers_all_b
         SET    system_status_code = 'COMPLETED',
                last_status_date = SYSDATE,
                user_status_id = l_status_id,
                object_version_number = object_version_number + 1
         WHERE  event_offer_id = l_event_offer_id
         AND    object_version_number = l_obj_version ;



	 -- call to api to raise business event, as per enh # 3805347
         AMS_SCHEDULERULES_PVT.RAISE_BE_ON_STATUS_CHANGE(p_obj_id => l_event_offer_id,
							 p_obj_type => l_obj_type,
							 p_old_status_code => l_status_code,
							 p_new_status_code => 'COMPLETED' );

         IF (SQL%NOTFOUND) THEN
            CLOSE c_evo_list ;
            AMS_Utility_PVT.Error_Message('AMS_API_RECORD_NOT_FOUND');
            RAISE FND_API.g_exc_error;
         END IF;
      ELSE -- Can not complete the schedule as the status is can not go to complete from current status
         CLOSE c_evo_list;
         AMS_Utility_PVT.Error_Message('AMS_EONE_CANNOT_COMPLETE');
         RAISE FND_API.g_exc_error;
      END IF ;

   END LOOP;
   CLOSE c_evo_list;


END complete_oneoff_event;

--==========================================================================
-- PROCEDURE
--    complete_all_Event
--
-- PURPOSE
--    completes all Rolup event and their associated event schedules. If the status
--    order rules does not permit it, it will error out.
--
-- NOTES
-- HISTORY
--    17-Jul-2001  mukumar    Created.
--==========================================================================

PROCEDURE complete_all_Event(p_prog_id   IN  NUMBER) IS

      CURSOR c_evh_list IS
      SELECT event_header_id,object_version_number,system_status_code
      FROM ams_event_headers_all_b
      WHERE  program_id  = p_prog_id;

      CURSOR c_evo_list IS
      SELECT event_offer_id,object_version_number,system_status_code
      FROM ams_event_offers_all_b
      WHERE  parent_id  = p_prog_id
      AND event_object_type = 'EONE'
      AND parent_type = 'RCAM';

   l_event_offer_id        NUMBER ;
   l_event_header_id        NUMBER ;
   l_obj_version        NUMBER ;
   l_status_code        VARCHAR2(30) ;
   l_status_id  NUMBER := AMS_Utility_PVT.get_default_user_status('AMS_EVENT_STATUS','COMPLETED');

BEGIN
     OPEN c_evh_list;
     LOOP
   FETCH c_evh_list INTO l_event_header_id,l_obj_version,l_status_code ;
   EXIT WHEN c_evh_list%NOTFOUND ;
   complete_RollupEvent(l_event_header_id);
     END LOOP;
     CLOSE c_evh_list;

   OPEN c_evo_list ;
   LOOP
      FETCH c_evo_list INTO l_event_offer_id,l_obj_version,l_status_code ;
      EXIT WHEN c_evo_list%NOTFOUND ;
      complete_oneoff_event(l_event_offer_id);
   END LOOP;
   CLOSE c_evo_list;

END complete_all_event;

--==========================================================================
-- PROCEDURE
--    Create_inventory_item
--
-- PURPOSE
--    completes all Rolup event and their associated event schedules. If the status
--    order rules does not permit it, it will error out.
--
-- NOTES
-- HISTORY
--    17-Jul-2001  mukumar    Created.
--==========================================================================

PROCEDURE create_inventory_item(p_item_number    IN  VARCHAR2,
                                p_item_desc      IN  VARCHAR2,
            p_item_long_desc IN  VARCHAR2,
            p_user_id        IN  NUMBER,
            x_org_id         OUT NOCOPY NUMBER,
            x_inv_item_id    OUT NOCOPY NUMBER,
            x_return_status  OUT NOCOPY  VARCHAR2,
            x_msg_count      OUT NOCOPY  NUMBER,
            x_msg_data       OUT NOCOPY  VARCHAR2) IS

l_org_id          NUMBER;
l_owner_id        NUMBER;
p_item_owner_Rec  AMS_ITEM_OWNER_PVT.ITEM_OWNER_Rec_Type;
Item_rec_in         AMS_ITEM_OWNER_PVT.ITEM_REC_TYPE; --INV_Item_GRP.Item_rec_type;
Item_rec_out        AMS_ITEM_OWNER_PVT.ITEM_REC_TYPE; --INV_Item_GRP.Item_rec_type;
Error_tbl           AMS_ITEM_OWNER_PVT.Error_tbl_type;
x_item_return_status VARCHAR2(1);
l_api_name           CONSTANT VARCHAR2(30) := 'create_inventory_item';
l_err_txt         VARCHAR2(4000);
inv_item_creation_error EXCEPTION;

BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   l_org_id := FND_PROFILE.Value('AMS_ITEM_ORGANIZATION_ID');
   p_item_owner_rec.ORGANIZATION_ID := l_org_id;
   p_item_owner_rec.ITEM_NUMBER := p_item_number;
   p_item_owner_rec.OWNER_ID  := p_user_id;
   p_item_owner_rec.is_master_item := 'Y';

   Item_rec_in.ORGANIZATION_ID      := l_org_id;
   Item_rec_in.ITEM_NUMBER          :=  p_item_number;
   Item_rec_in.DESCRIPTION          :=  p_item_desc;
   Item_rec_in.LONG_DESCRIPTION     :=  p_item_long_desc;
   x_org_id := l_org_id;

   AMS_ITEM_OWNER_PVT.Create_item_owner(
      P_Api_Version_Number    => 1.0,
      X_Return_Status         => x_return_status,
      X_Msg_Count             => x_msg_count,
      X_Msg_Data              => x_msg_data,
      P_ITEM_OWNER_Rec        => p_item_owner_rec,
      X_ITEM_OWNER_ID         => l_owner_id,  ---  for create api
      P_ITEM_REC_In           => Item_rec_in,
      P_ITEM_REC_Out          => Item_rec_out,
      x_item_return_status    => x_item_return_status,
      x_Error_tbl             => Error_tbl
      );

      IF x_item_return_status <> FND_API.g_ret_sts_success THEN
         RAISE inv_item_creation_error;
     else
        IF x_return_status = FND_API.g_ret_sts_success THEN
                 x_inv_item_id := Item_rec_out.INVENTORY_ITEM_ID;
               x_org_id := Item_rec_out.ORGANIZATION_ID;
         END IF;

      END IF;
EXCEPTION

   WHEN inv_item_creation_error THEN

       FOR i IN 1 .. error_tbl.count LOOP
          l_err_txt := error_tbl(i).message_name;
       END LOOP;
/*
       x_msg_data := l_err_txt;
          FND_MSG_PUB.count_and_get(
                p_encoded => FND_API.g_false,
                p_count   => x_msg_count,
                p_data    =>  x_msg_data
          );
*/
        FND_MESSAGE.set_name('INV', l_err_txt); -- error_tbl(i).message_name);
        FND_MSG_PUB.add;
      --END LOOP;

   WHEN FND_API.g_exc_unexpected_error THEN
      --x_return_status := FND_API.g_ret_sts_unexp_error ;
      x_msg_count := error_tbl.count;
      FOR i IN 1 .. error_tbl.count LOOP
          FND_MSG_PUB.count_and_get(
                p_encoded => FND_API.g_false,
                p_count   => x_msg_count,
                p_data    => error_tbl(i).message_text
          );
      END LOOP;

   WHEN OTHERS THEN
     -- x_return_status := FND_API.g_ret_sts_unexp_error;
      x_msg_count := error_tbl.count;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
      THEN
        FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FOR i IN 1 .. error_tbl.count LOOP
          FND_MSG_PUB.count_and_get(
                p_encoded => FND_API.g_false,
                p_count   => x_msg_count,
               -- p_data    => x_msg_data
               p_data    => error_tbl(i).message_text
          );
      END LOOP;

END create_inventory_item;


-------------------------------------------------------------------------------
-- Procedure      Update_Event_Header_Status
--
-- Purpose  If the Event Header Status is Active, make all the schedules
--          attached to it which are in available status as Active
--
--          If the Event Header is cancelled, all its children are also
--          cancelled.
--
-- HISTORY
--    07-Jan-2002  gmadana    Created.
--    15-Feb-2002  gmadana    Modified.
--          If the Event Header is to be cancelled, first check whether its
--          children are cancelled. If any one of them is not Cancelled, then
--          you cannot cancel the Event Header.
--    03/11/2002 Changed the messages AMS_EVENT_NOT ACTIVE to AMS_EVENT_NOT_ACTIVE
--    17-Mar-2005  spendem    Modified to raise the business event. enh # 3805347
-----------------------------------------------------------------------------------
PROCEDURE Update_Event_Header_Status (
   p_event_header_id         IN NUMBER,
   p_new_status_id           IN NUMBER,
   p_new_status_code         IN VARCHAR2
 ) IS
   l_schedule_id             NUMBER ;
   l_obj_version             NUMBER ;
   l_evh_obj_ver             NUMBER;
   l_status_code             VARCHAR2(30) ;
   l_numOfSchedules          NUMBER;
   l_obj_type                VARCHAR2(4);  -- added as per enh # 3805347

-- Modified the select statement of the cursor to get event_object_type, as per enh # 3805347
CURSOR c_schedule IS
     SELECT event_offer_id , object_version_number, event_object_type
     FROM  ams_event_offers_vl
     WHERE event_header_id = p_event_header_id
     AND system_status_code = 'AVAILABLE';

CURSOR c_header_obj_ver IS
     SELECT object_version_number
     FROM ams_event_headers_vl
     WHERE event_header_id = p_event_header_id;

CURSOR c_no_schedule IS
     SELECT count(*)
     FROM  ams_event_offers_vl
     WHERE event_header_id = p_event_header_id
     AND system_status_code NOT IN ( 'CANCELLED', 'ARCHIVED');

CURSOR c_header_status IS
     SELECT system_status_code
     FROM  ams_event_headers_vl
     WHERE event_header_id = p_event_header_id;


 BEGIN

     /* Getting the obj_ver_num of Event Header */
     OPEN c_header_obj_ver;
     FETCH c_header_obj_ver INTO l_evh_obj_ver;
     IF c_header_obj_ver%NOTFOUND THEN
        CLOSE c_header_obj_ver;
     END IF;


   /* If the Event Header Status is Active, make all the schedules
      attached to it which are in available status as Active.
      If the Event Header Status is Cancelled, check whether all the schedules
      attached to it Cancelled. If No, you cannot cancel the Event Header.
   */

   IF(p_new_status_code = 'ACTIVE') THEN

      /* updating the Event Header */
      UPDATE ams_event_headers_all_b
      SET    user_status_id = p_new_status_id,
             system_status_code    = p_new_status_code,
             last_status_date    = SYSDATE,
             object_version_number = l_evh_obj_ver + 1
      WHERE  event_header_id    = p_event_header_id;

     /*Updating the Schedules */
     OPEN c_schedule;
       LOOP
          FETCH c_schedule INTO l_schedule_id, l_obj_version, l_obj_type;  -- Modified the fetch, as per enh # 3805347
          EXIT WHEN c_schedule%NOTFOUND ;

           UPDATE ams_event_offers_all_b
           SET  system_status_code = 'ACTIVE',
                last_status_date = SYSDATE ,
                user_status_id     = p_new_status_id,
                object_version_number = l_obj_version + 1
           WHERE  event_offer_id = l_schedule_id ;

           -- call to api to raise business event, as per enh # 3805347
           AMS_SCHEDULERULES_PVT.RAISE_BE_ON_STATUS_CHANGE(p_obj_id => l_schedule_id,
							   p_obj_type => l_obj_type,
							   p_old_status_code => 'AVAILABLE',
							   p_new_status_code => 'ACTIVE' );


       END LOOP;
     CLOSE c_schedule;

   ELSIF(p_new_status_code = 'CANCELLED') THEN

        /* Check if all the children are Cancelled. If 'Yes' then cancel
           Event Header.
        */

         /* Getting the obj_ver_num of Event Header */
         OPEN c_no_schedule;
         FETCH c_no_schedule INTO l_numOfSchedules;
         IF c_no_schedule%NOTFOUND THEN
            CLOSE c_no_schedule;
         END IF;

         OPEN c_header_status;
         FETCH c_header_status INTO l_status_code;
         CLOSE c_header_status;

        IF (l_numOfSchedules = 0
        --   AND  Fnd_Api.G_TRUE = Ams_Utility_Pvt.Check_Status_Change('AMS_EVENT_STATUS',l_status_code,'CANCELLED')
           )
        THEN

              UPDATE ams_event_headers_all_b
              SET    user_status_id = p_new_status_id,
                     system_status_code  = p_new_status_code,
                     last_status_date    = SYSDATE,
                     object_version_number = l_evh_obj_ver + 1
              WHERE  event_header_id     = p_event_header_id;
         ELSE

            FND_MESSAGE.set_name('AMS', 'AMS_EVH_CANNOT_CANCEL');
            FND_MSG_PUB.add;
            RAISE FND_API.g_exc_error;

         END IF;

 ELSE
        /* Bug #2250937  03/05/2002*/

         UPDATE ams_event_headers_all_b
         SET    user_status_id = p_new_status_id,
                system_status_code  = p_new_status_code,
                last_status_date    = SYSDATE,
                object_version_number = l_evh_obj_ver + 1
          WHERE  event_header_id     = p_event_header_id;
  END IF;

 END Update_Event_Header_Status;

---------------------------------------------------------------------------------
--       Update_Event_Schedule_Status

-- HISTORY
--    07-Jan-2002  gmadana    Created.
--    17-Mar-2005  spendem    Modified to raise the business event. enh # 3805347
-----------------------------------------------------------------------------------
PROCEDURE Update_Event_Schedule_Status (
   p_event_offer_id          IN NUMBER,
   p_new_status_id           IN NUMBER,
   p_new_status_code         IN VARCHAR2
 ) IS

 -- declare cursor for enh # 3805347
 CURSOR c_eve_det IS
 SELECT system_status_code, event_object_type
 FROM   ams_event_offers_all_b
 WHERE  event_offer_id = p_event_offer_id;

 l_old_status_code VARCHAR2(30); -- added as per enh # 3805347
 l_obj_type        VARCHAR2(4);  -- added as per enh # 3805347

 BEGIN

  --Open cursor to fetch the old status code, as per enh # 3805347
  OPEN c_eve_det;
  FETCH c_eve_det INTO l_old_status_code, l_obj_type;
  CLOSE c_eve_det;

   UPDATE ams_event_offers_all_b
   SET    user_status_id = p_new_status_id,
          system_status_code    = p_new_status_code,
          last_status_date    = SYSDATE
   WHERE  event_offer_id    = p_event_offer_id;

   -- call to api to raise business event, as per enh # 3805347
   AMS_SCHEDULERULES_PVT.RAISE_BE_ON_STATUS_CHANGE(p_obj_id => p_event_offer_id,
						   p_obj_type => l_obj_type,
						   p_old_status_code => l_old_status_code,
						   p_new_status_code => p_new_status_code );



 END Update_Event_Schedule_Status;
 ------------------------------------------------------------------------------------------


 --=====================================================================
-- PROCEDURE
--    Update_Owner
--
-- PURPOSE
--    The api is created to update the owner of the event from the
--    access table if the owner is changed in update.
--
-- HISTORY
--    14-Jan-2001  gmadana    Created.
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
   p_event_id          IN  NUMBER,
   p_owner_id          IN  NUMBER   )
IS
   CURSOR c_header_owner IS
   SELECT owner_user_id
   FROM   ams_event_headers_all_b
   WHERE  event_header_id = p_event_id ;

   CURSOR c_offer_owner IS
   SELECT owner_user_id
   FROM   ams_event_offers_all_b
   WHERE  event_offer_id = p_event_id ;

   l_old_owner  NUMBER ;

BEGIN

  IF p_object_type = 'EVEH' THEN
      OPEN c_header_owner ;
      FETCH c_header_owner INTO l_old_owner ;

      IF c_header_owner%NOTFOUND THEN
          CLOSE c_header_owner;
          AMS_Utility_Pvt.Error_Message('AMS_API_RECORD_NOT_FOUND');
          RAISE FND_API.g_exc_error;
      ELSE
          CLOSE c_header_owner;
      END IF;

   ELSE
      OPEN c_offer_owner ;
      FETCH c_offer_owner INTO l_old_owner ;

      IF c_offer_owner%NOTFOUND THEN
          CLOSE c_offer_owner;
          AMS_Utility_Pvt.Error_Message('AMS_API_RECORD_NOT_FOUND');
          RAISE FND_API.g_exc_error;
      ELSE
          CLOSE c_offer_owner;
      END IF;

   END IF;

   IF p_owner_id <> l_old_owner THEN
       AMS_Access_PVT.update_object_owner(
           p_api_version       => p_api_version,
           p_init_msg_list     => p_init_msg_list,
           p_commit            => p_commit,
           p_validation_level  => p_validation_level,
           x_return_status     => x_return_status,
           x_msg_count         => x_msg_count,
           x_msg_data          => x_msg_data,
           p_object_type       => p_object_type,
           p_object_id         => p_event_id,
           p_resource_id       => p_owner_id,
           p_old_resource_id   => l_old_owner
        );

      IF x_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;

   END IF ;

END Update_Owner ;

 --=====================================================================
-- PROCEDURE
--    Send_Out_Information
--
-- PURPOSE
--    The api is created to send information (changed) to customer
--    when ever there is a change in Venue/Date/Status(Cancelled).
--
-- HISTORY
--    24-Apr-2002  gmadana    Created.
--    18-nov-2002  soagrawa   Fixed bug# 2672928
--    13-Dec-2002  ptendulk   Modified the api for 1:1 integration
--    13-feb-2002  soagrawa   Fixed bug# 2798626
-- dbiswas missing fixes for bugs 2837977 and 2908547
--    27-may-2003  soagrawa   Fixed NI Mail profile issue bug# 2978952
--=====================================================================
PROCEDURE Send_Out_Information(
   p_object_type       IN  VARCHAR2,
   p_object_id         IN  NUMBER ,
   p_trigger_type      IN  VARCHAR2 ,
   -- p_bind_values       IN  AMF_REQUEST.string_tbl_type , -- Modified by ptendulk for 1:1
   p_bind_values       IN  JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE,
   p_bind_names        IN  JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE,
   x_return_status     OUT NOCOPY VARCHAR2
)
IS
   l_request_history_id   NUMBER;

/* Following code is modified by ptendulk to move to 1:1 ffm
   l_email            AMF_REQUEST.string_tbl_type;
   l_fax              AMF_REQUEST.string_tbl_type;
   l_party_id         AMF_REQUEST.number_tbl_type;
*/

   l_email            JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;
   l_fax              JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;
   l_party_id         JTF_FM_REQUEST_GRP.G_NUMBER_TBL_TYPE;


   l_msg_count		NUMBER;
   l_logged_in_user_id  NUMBER;
   l_obj_resource_id    NUMBER;
   l_msg_data           VARCHAR2(2000);

   -- following declarations added by soagrawa on 18-nov-2002
   -- for bug# 2672928
   l_object_type      VARCHAR2(10);
   l_object_id        NUMBER;
   l_parent_type      VARCHAR2(10);
   l_csch_id          NUMBER;

   -- soagrawa 03-feb-2003  bug# 2781219
   CURSOR c_get_parent_type IS
   SELECT parent_type, owner_user_id
     FROM ams_event_offers_all_b
    WHERE event_offer_id = p_object_id;

   CURSOR c_csch_id IS
   SELECT schedule_id
     FROM ams_campaign_schedules_b
    WHERE related_event_id = p_object_id;


BEGIN

   -- l_logged_in_user_id  := AMS_Utility_PVT.get_resource_id(FND_GLOBAL.USER_ID);
   l_logged_in_user_id  := FND_GLOBAL.user_id ;

   IF (AMS_DEBUG_HIGH_ON) THEN
       AMS_Utility_PVT.debug_message('Calling AMS_CT_RULE_PVT.check_content_rule');
   END IF;


   -- soagrawa 18-nov-2002 for bug# 2672928
   l_object_type  :=  p_object_type;
   l_object_id    :=  p_object_id;

   OPEN  c_get_parent_type;
   FETCH c_get_parent_type INTO l_parent_type, l_obj_resource_id;
   CLOSE c_get_parent_type;

   IF l_object_type = 'EONE'
   THEN
-- soagrawa 12-feb-2003 bug# 2798626 - removed from here and added out of the IF clause
/*
      OPEN  c_get_parent_type;
      FETCH c_get_parent_type INTO l_parent_type, l_obj_resource_id;
      CLOSE c_get_parent_type;
*/
      IF l_parent_type = 'CAMP'
      THEN

         OPEN  c_csch_id;
         FETCH c_csch_id INTO l_csch_id;
         CLOSE c_csch_id;

         l_object_type  :=  'CSCH';
         l_object_id    :=  l_csch_id;
      END IF;
   END IF;
   -- end soagrawa 18-nov-2002 for bug# 2672928


   AMS_CT_RULE_PVT.check_content_rule(
               p_api_version      => 1.0
              , p_init_msg_list        => FND_API.g_false
              , p_commit               => FND_API.g_false
              , p_object_type          => l_object_type --p_object_type
              , p_object_id            => l_object_id  -- p_object_id
              , p_trigger_type         => p_trigger_type
   --         , p_requestor_type       => NULL
   --           , p_requestor_id         => l_logged_in_user_id
   -- soagrawa 03-feb-2003  bug# 2781219
              , p_requestor_id          =>  get_user_id(l_obj_resource_id) -- l_logged_in_user_id
   --         , p_server_group         =>  NULL
   --         , p_scheduled_date       => SYSDATE
   --         , p_media_types          => 'E'
   --         , p_archive              => 'N'
   --         , p_log_user_ih          => 'N'
   --           , p_request_type         => 'MASS_CUSTOM'
   --         , p_language_code        => NULL
   -- soagrawa fixed NI issue about the mail profiles 27-may-2003 commented out p_profile_id bug# 2978952
   --         , p_profile_id           => NULL
   --         , p_order_id             => NULL
      --      , p_collateral_id        => NULL
              , p_party_id             => l_party_id
              , p_email                => l_email
              , p_fax                  => l_fax
              , p_bind_values          => p_bind_values
              , p_bind_names           => p_bind_names   -- Added by ptendulk on 13-Dec-2002 for 1:1 integration
              , x_return_status        => x_return_status
              , x_msg_count            => l_msg_count
              , x_msg_data             => l_msg_data
              , x_request_history_id   => l_request_history_id
     );


      IF (AMS_DEBUG_HIGH_ON) THEN
          AMS_Utility_PVT.debug_message('Request ID: ' || l_request_history_id);
      END IF;

      IF x_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;

END Send_Out_Information ;


END AMS_EvhRules_PVT;

/
