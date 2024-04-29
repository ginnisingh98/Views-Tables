--------------------------------------------------------
--  DDL for Package Body AMS_EVTREGS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_EVTREGS_PVT" as
/*$Header: amsvregb.pls 120.0 2005/06/01 23:09:42 appldev noship $*/
--------------------------------------------------------------------------------------
-- Package name
--    AMS_EvtRegs_PVT
-- Purpose
--    This package is a Private API for managing event registrations
-- History
--    16-OCT-1999  sugupta   Created
--    27-NOV-2001  mukumar   added code to support if the effective capacity is zero.
--    01-MAR-2002  dcastlem  Implemented invite list validation and
--                           automatic registration for capacity changes
--    12-MAR-2002  dcastlem  Added support for general Public API
--                           (AMS_Registrants_PUB)
--    05-APR-2002  dcastlem  Refined waitlist code
--                           Fixed bug 2284681 - cancel end date
--    08-APR-2002  dcastlem  Copied write_interaction from AMS_ScheduleRules_PVT
--    28-MAY-2002  dcastlem  removed task creation from prioritize_waitlist
--    28-MAY-2002  dcastlem  disallowed cancelled registrants to transfer
--    24-OCT-2002  soagrawa  Checking for registration id sequence value's uniqueness
--    12-NOV-2002  musman    Restricted the cancelled registrant to update the attended flag
--    18-nov-2002  soagrawa  Fixed bug# 2672928 regding fulfilling for CSCH of type events
--    20-dec-2002  soagrawa  Fixed bug# 2600986 ini query of contact_in_invite_list
--    24-dec-2002  soagrawa  added get_user_id for calls to check_content_rule to pass a valid user id
--    29-jan-2003  soagrawa  Modified update_evtregs_wrapper to fix bug# 2775357
--    03-feb-2003  soagrawa  Fixed bug# 2777302
--    13-Feb-2003  soagrawa  Modified cursor c_id_exists for soagrawa's above fix.
--    08-Mar-2003  ptendulk  modified write interactions procedure. Bug # 2838162
--    13-Mar-2003  dbiswas   Check for date_registration_placed. bug 2845867
--    20-Mar-2003  dbiswas   Modified update statements in cancel_evtregs for NI issue
--    16-Apr-2003  dbiswas   Modified cursor for contact_in_invite_list to carry fix for NI bug# 2610067
--                           to the next releases
--    23-May-2003  SOAGRAWA  fixed bug# 2949603
--    23-May-2003  SOAGRAWA  fixed bug# 2525529
--    27-may-2003  soagrawa  Fixed NI issue about result of interaction in write_interaction  bug# 2978948
--    24-jun-2003  anchaudh  fixed bug#3020564
--    19-aug-2003  anchaudh  Fixed bug#3101955
--    29-aug-2003  anchaudh  Fixed bug#3119915
--    08-jun-2004  soagrawa  Modified cursor in contact_in_invite_list for performance bug# 3667627
--    15-Feb-2005  sikalyan   Fixed bug#4185688
--------------------------------------------------------------------------------------

G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_EvtRegs_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amsvregb.pls';

AMS_DEBUG_HIGH_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

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

PROCEDURE Insert_evtregs(  p_evt_regs_Rec           IN   evt_regs_Rec_Type
                         , p_system_status_code     IN   VARCHAR2
                         , p_block_fulfillment      IN  VARCHAR2  := FND_API.G_FALSE
                         , x_confirmation_code      OUT NOCOPY  VARCHAR2
                         , x_event_registration_id  OUT NOCOPY  NUMBER
                        )
IS

   l_evt_regs_Rec           evt_regs_Rec_Type  := p_evt_regs_Rec;
   l_system_status_code     VARCHAR2(30)       := p_system_status_code;
   l_event_registration_id  NUMBER             := l_evt_regs_Rec.EVENT_REGISTRATION_ID;
   l_confirmation_code      VARCHAR2(30)       := l_evt_regs_rec.confirmation_code;
   l_waitlisted_priority    NUMBER             := NULL;
   l_confirmation_id        NUMBER;
   l_code_prefix            VARCHAR2(50)       := FND_PROFILE.Value('AMS_CONF_CODE_PREFIX');
   /*dbiswas Mar 13, 2003 */
   l_date_reg_placed        DATE               := l_evt_regs_rec.DATE_REGISTRATION_PLACED;

/* Following code is modified by ptendulk to move to 1:1 ffm
   l_email            AMF_REQUEST.string_tbl_type;
   l_fax              AMF_REQUEST.string_tbl_type;
   l_bind_values      AMF_REQUEST.string_tbl_type;
   l_party_id         AMF_REQUEST.number_tbl_type;
*/

   l_email            JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;
   l_fax              JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;
   l_party_id         JTF_FM_REQUEST_GRP.G_NUMBER_TBL_TYPE;
   l_bind_names       JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;
   l_bind_values      JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;



   l_return_status        VARCHAR2(1);
   l_msg_count            NUMBER;
   l_msg_data             VARCHAR2(2000);
   l_request_history_id   NUMBER;

   l_object_type          VARCHAR2(30);
   l_end_date             DATE;
   l_dummy                NUMBER;

/*
   CURSOR c_get_email_address(p_party_id IN NUMBER) is
   select email_address
   from hz_parties
   where party_id = p_party_id;

   CURSOR c_get_email_address_b2b(  p_contact_id  IN NUMBER
                                  , p_party_id    IN NUMBER
                                 )
   IS
   select email_address
   from hz_parties hzp,
        hz_relationships hzpr
   where hzp.party_id = hzpr.party_id
     and hzpr.object_id = p_party_id
     and hzpr.subject_id = p_contact_id;
*/

   CURSOR c_get_object_type(p_event_offer_id IN NUMBER) IS
   SELECT event_object_type,
          trunc(event_end_date) + 1,
          parent_type
   from ams_event_offers_all_b
   where event_offer_id = p_event_offer_id;

   CURSOR c_evt_regs_seq IS
   SELECT ams_event_registrations_s.NEXTVAL
   FROM DUAL;

   -- added by soagrawa on 24-oct-2002 for uniqueness sake
   -- needed so as to not conflict with ids generated in migration
   CURSOR c_id_exists (l_id IN NUMBER) IS
   SELECT 1
     FROM dual
    WHERE  EXISTS (SELECT 1
--                    FROM AMS_event_offers_all_B   Modified by ptendulk on 12-Feb-2002
--                    WHERE event_offer_id = l_id);
                    FROM ams_event_registrations
                    WHERE event_registration_id = l_id);

   CURSOR c_evt_reg_conf_seq IS
   SELECT ams_event_reg_confirmation_s.nextval
   FROM dual;

   CURSOR c_evt_reg_waitlist_seq IS
   SELECT ams_reg_waitlist_priority_s.nextval
   FROM dual;

   CURSOR c_evt_reg_status IS
   SELECT user_status_id
   FROM ams_user_statuses_b
   WHERE SYSTEM_STATUS_CODE = p_system_status_code
     and SYSTEM_STATUS_TYPE = 'AMS_EVENT_REG_STATUS'
     and default_flag = 'Y';       --anchaudh:fixed bug#3020564 on 24-jun-2003.

   -- soagrawa 18-nov-2002 for bug# 2672928
   l_csch_id          NUMBER;
   l_object_id        NUMBER;
   l_parent_type      VARCHAR2(10);

   CURSOR c_csch_id (obj_id NUMBER) IS
   SELECT schedule_id
     FROM ams_campaign_schedules_b
    WHERE related_event_id = obj_id;


BEGIN
   IF (l_event_registration_id IS NULL)
   THEN
      -- added by soagrawa on 24-oct-2002 for uniqueness sake
      -- encapsulated sequence nextval retrieval in a loop
      -- for uniqueness sake
      LOOP
         l_dummy := NULL;
         OPEN c_evt_regs_seq;
         FETCH c_evt_regs_seq  INTO l_event_registration_id;
         CLOSE c_evt_regs_seq;

         OPEN c_id_exists(l_event_registration_id);
         FETCH c_id_exists INTO l_dummy;
         CLOSE c_id_exists;
         EXIT WHEN l_dummy IS NULL;
      END LOOP;
      -- end soagrawa 24-oct-2002
   END IF; -- l_event_registration_id

   IF (l_confirmation_code IS NULL)
   THEN
      OPEN c_evt_reg_conf_seq;
      FETCH c_evt_reg_conf_seq
      INTO l_confirmation_id;
      CLOSE c_evt_reg_conf_seq;
   END IF; -- l_confirmation_code

   l_confirmation_code := l_code_prefix || to_char(l_confirmation_id);

   IF (l_system_status_code = 'WAITLISTED')
   THEN
      open c_evt_reg_waitlist_seq;
      fetch c_evt_reg_waitlist_seq
      into l_waitlisted_priority;
      close c_evt_reg_waitlist_seq;
   END IF; -- l_system_status_code

   OPEN c_evt_reg_status;
   FETCH c_evt_reg_status
   INTO l_evt_regs_Rec.user_status_id;
      -- error out if user status not found...
   CLOSE c_evt_reg_status;

    -- added by dbiswas on Mar 12, 2003 for bug 2845867
   IF l_date_reg_placed = Fnd_Api.g_miss_date THEN
      l_date_reg_placed := sysdate;
   END IF;
   -- end update on Mar 12, 2003

   INSERT INTO AMS_EVENT_REGISTRATIONS(
      EVENT_REGISTRATION_ID,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_LOGIN,
      OBJECT_VERSION_NUMBER,
      EVENT_OFFER_ID,
      APPLICATION_ID,
      ACTIVE_FLAG,
      OWNER_USER_ID,
      DATE_REGISTRATION_PLACED,
      USER_STATUS_ID,
      SYSTEM_STATUS_CODE,
      LAST_REG_STATUS_DATE,
      REG_SOURCE_TYPE_CODE,
      REGISTRATION_SOURCE_ID,
      CONFIRMATION_CODE,
      SOURCE_CODE,
      REGISTRATION_GROUP_ID,
      REGISTRANT_PARTY_ID,
      REGISTRANT_CONTACT_ID,
      REGISTRANT_ACCOUNT_ID,
      ATTENDANT_PARTY_ID,
      ATTENDANT_CONTACT_ID,
      ATTENDANT_ACCOUNT_ID,
      ORIGINAL_REGISTRANT_CONTACT_ID,
      PROSPECT_FLAG,
      ATTENDED_FLAG,
      CONFIRMED_FLAG,
      EVALUATED_FLAG,
      ATTENDANCE_RESULT_CODE,
      WAITLISTED_PRIORITY,
      TARGET_LIST_ID,
      INBOUND_MEDIA_ID,
      INBOUND_CHANNEL_ID,
      CANCELLATION_CODE,
      CANCELLATION_REASON_CODE,
      ATTENDANCE_FAILURE_REASON,
      ATTENDANT_LANGUAGE,
      SALESREP_ID,
      ORDER_HEADER_ID,
      ORDER_LINE_ID,
      DESCRIPTION,
      MAX_ATTENDEE_OVERRIDE_FLAG,
      INVITE_ONLY_OVERRIDE_FLAG,
      PAYMENT_STATUS_CODE,
      AUTO_REGISTER_FLAG,
      ATTRIBUTE_CATEGORY,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15,
      attendee_role_type, /* Hornet : added for imeeting integration*/
      notification_type, /* Hornet : added for imeeting integration*/
      last_notified_time, /* Hornet : added for imeeting integration*/
      EVENT_JOIN_TIME,/* Hornet : added for imeeting integration*/
      EVENT_EXIT_TIME, /* Hornet : added for imeeting integration*/
      MEETING_ENCRYPTION_KEY_CODE /* Hornet : added for imeeting integration*/
   ) VALUES (
      l_event_registration_id,
      SYSDATE,
      FND_GLOBAL.user_id,
      SYSDATE,
      FND_GLOBAL.user_id,
      FND_GLOBAL.conc_login_id,
      1,  -- object_version_number
      l_evt_regs_rec.EVENT_OFFER_ID,
      l_evt_regs_rec.APPLICATION_ID,
      nvl(l_evt_regs_rec.ACTIVE_FLAG, 'Y'),
      l_evt_regs_rec.OWNER_USER_ID,
      nvl(l_date_reg_placed,sysdate),
      l_evt_regs_rec.USER_STATUS_ID,
      l_system_status_code,
      nvl(l_evt_regs_rec.LAST_REG_STATUS_DATE, sysdate),
      l_evt_regs_rec.REG_SOURCE_TYPE_CODE,
      l_evt_regs_rec.REGISTRATION_SOURCE_ID,
      l_confirmation_code,
      l_evt_regs_rec.SOURCE_CODE,
      l_evt_regs_rec.REGISTRATION_GROUP_ID,
      l_evt_regs_rec.REGISTRANT_PARTY_ID,
      l_evt_regs_rec.REGISTRANT_CONTACT_ID,
      l_evt_regs_rec.REGISTRANT_ACCOUNT_ID,
      l_evt_regs_rec.ATTENDANT_PARTY_ID,
      l_evt_regs_rec.ATTENDANT_CONTACT_ID,
      l_evt_regs_rec.ATTENDANT_ACCOUNT_ID,
      nvl(l_evt_regs_rec.ORIGINAL_REGISTRANT_CONTACT_ID,l_evt_regs_rec.REGISTRANT_CONTACT_ID),
      nvl(l_evt_regs_rec.PROSPECT_FLAG, 'N'),
      nvl(l_evt_regs_rec.ATTENDED_FLAG, 'N'),
      nvl(l_evt_regs_rec.CONFIRMED_FLAG, 'N'),
      nvl(l_evt_regs_rec.EVALUATED_FLAG, 'N'),
      l_evt_regs_rec.ATTENDANCE_RESULT_CODE,
      l_waitlisted_priority,
      l_evt_regs_rec.TARGET_LIST_ID,
      l_evt_regs_rec.INBOUND_MEDIA_ID,
      l_evt_regs_rec.INBOUND_CHANNEL_ID,
      l_evt_regs_rec.CANCELLATION_CODE,
      l_evt_regs_rec.CANCELLATION_REASON_CODE,
      l_evt_regs_rec.ATTENDANCE_FAILURE_REASON,
      l_evt_regs_rec.ATTENDANT_LANGUAGE,
      l_evt_regs_rec.SALESREP_ID,
      l_evt_regs_rec.ORDER_HEADER_ID,
      l_evt_regs_rec.ORDER_LINE_ID,
      l_evt_regs_rec.DESCRIPTION,
      nvl(l_evt_regs_rec.MAX_ATTENDEE_OVERRIDE_FLAG, 'N'),
      nvl(l_evt_regs_rec.INVITE_ONLY_OVERRIDE_FLAG, 'N'),
      l_evt_regs_rec.PAYMENT_STATUS_CODE,
      nvl(l_evt_regs_rec.AUTO_REGISTER_FLAG, 'Y'),
      l_evt_regs_rec.ATTRIBUTE_CATEGORY,
      l_evt_regs_rec.ATTRIBUTE1,
      l_evt_regs_rec.ATTRIBUTE2,
      l_evt_regs_rec.ATTRIBUTE3,
      l_evt_regs_rec.ATTRIBUTE4,
      l_evt_regs_rec.ATTRIBUTE5,
      l_evt_regs_rec.ATTRIBUTE6,
      l_evt_regs_rec.ATTRIBUTE7,
      l_evt_regs_rec.ATTRIBUTE8,
      l_evt_regs_rec.ATTRIBUTE9,
      l_evt_regs_rec.ATTRIBUTE10,
      l_evt_regs_rec.ATTRIBUTE11,
      l_evt_regs_rec.ATTRIBUTE12,
      l_evt_regs_rec.ATTRIBUTE13,
      l_evt_regs_rec.ATTRIBUTE14,
      l_evt_regs_rec.ATTRIBUTE15,
      l_evt_regs_rec.attendee_role_type, /* Hornet : added for imeeting integration*/
      l_evt_regs_rec.notification_type, /* Hornet : added for imeeting integration*/
      l_evt_regs_rec.last_notified_time, /* Hornet : added for imeeting integration*/
      l_evt_regs_rec.EVENT_JOIN_TIME, /* Hornet : added for imeeting integration*/
      l_evt_regs_rec.EVENT_EXIT_TIME, /* Hornet : added for imeeting integration*/
      l_evt_regs_rec.MEETING_ENCRYPTION_KEY_CODE /* Hornet : added for imeeting integration*/
   );
   x_confirmation_code := l_confirmation_code;
   x_event_registration_id := l_event_registration_id;

/*
   IF (l_evt_regs_rec.attendant_contact_id = l_evt_regs_rec.attendant_party_id)
   THEN
      -- B2C
      open c_get_email_address(l_evt_regs_rec.attendant_contact_id);
      fetch c_get_email_address
      into l_email(0);
      close c_get_email_address;
   ELSE
      open c_get_email_address_b2b(  l_evt_regs_rec.attendant_contact_id
                                   , l_evt_regs_rec.attendant_party_id
                                  );
      fetch c_get_email_address_b2b
      into l_email(0);
      close c_get_email_address_b2b;
   END IF;
   --l_party_id(0) := l_evt_regs_rec.attendant_contact_id;
*/
   open c_get_object_type(l_evt_regs_rec.event_offer_id);
   fetch c_get_object_type
   into l_object_type,
        l_end_date,
        l_parent_type;
   close c_get_object_type;

   -- soagrawa 18-nov-2002 for bug# 2672928
   l_object_id := l_evt_regs_rec.event_offer_id;

   IF l_object_type = 'EONE'
   THEN
      IF l_parent_type = 'CAMP'
      THEN

         OPEN  c_csch_id(l_object_id);
         FETCH c_csch_id INTO l_csch_id;
         CLOSE c_csch_id;

         l_object_type  :=  'CSCH';
         l_object_id    :=  l_csch_id;
      END IF;
   END IF;
   -- end soagrawa 18-nov-2002

   IF (    (nvl(l_evt_regs_rec.ATTENDED_FLAG, 'N') = 'N')
       AND (sysdate < l_end_date)
      )
   THEN


      /* Following code is modified by ptendulk on 12-Dec-2002 to move to 1:1
      l_bind_values(0) := to_char(l_event_registration_id);
      l_bind_values(1) := to_char(l_event_registration_id); */
      l_bind_names(1)  := 'REGISTRATION_ID' ;
      l_bind_values(1) := TO_CHAR(l_event_registration_id);

      IF (l_system_status_code = 'REGISTERED')
      THEN
         -- Interaction
         write_interaction(  p_event_offer_id => l_evt_regs_rec.EVENT_OFFER_ID
                             -- dbiswas 16-apr-2003 for NI issue with interactions (part of 2610067)
                             --, p_party_id       => l_evt_regs_rec.ATTENDANT_PARTY_ID
                             , p_party_id       => l_evt_regs_rec.ATTENDANT_CONTACT_ID
                          );

         -- Fulfillment
         IF (    (nvl(FND_PROFILE.value('AMS_FULFILL_ENABLE_FLAG'), 'N') = 'Y')
             AND (nvl(p_block_fulfillment, FND_API.G_FALSE) <> FND_API.G_TRUE)
            )
         THEN
            IF (AMS_DEBUG_HIGH_ON) THEN

                AMS_Utility_PVT.Debug_Message('Calling check_content_rule for fulfillment (registered)');
            END IF;
            AMS_CT_RULE_PVT.check_content_rule(  p_api_version          => 1.0 -- IN  NUMBER
                                               , p_init_msg_list        => FND_API.g_false -- IN  VARCHAR2  := FND_API.g_false
                                               , p_commit               => FND_API.g_false-- IN  VARCHAR2  := FND_API.g_false
                                               , p_object_type          => l_object_type -- IN  VARCHAR2
                                               , p_object_id            => l_object_id  --l_evt_regs_rec.event_offer_id -- IN  NUMBER
                                               , p_trigger_type         => 'REG_CONFIRM' -- IN  VARCHAR2
            --                                 , p_requestor_type       => -- IN  VARCHAR2  := NULL
                                               -- Following line is modified by ptendulk on 12-Dec-2002
                                               , p_requestor_id         => get_user_id(l_evt_regs_rec.OWNER_USER_ID)
                                               --, p_requestor_id         => AMS_Utility_PVT.get_resource_id(l_evt_regs_rec.OWNER_USER_ID) -- IN  NUMBER
            --                                 , p_server_group         => -- IN  NUMBER := NULL
            --                                 , p_scheduled_date       => -- IN  DATE  := SYSDATE
            --                                 , p_media_types          => -- IN  VARCHAR2 := 'E'
            --                                 , p_archive              => -- IN  VARCHAR2 := 'N'
            --                                 , p_log_user_ih          => -- IN  VARCHAR2 := 'N'
            --                                   , p_request_type         => 'MASS_CUSTOM' -- IN  VARCHAR2 := 'TEST_EMAIL'
            --                                 , p_language_code        => -- IN  VARCHAR2 := NULL
            --                                 , p_profile_id           => -- IN  NUMBER   := NULL
            --                                 , p_order_id             => -- IN  NUMBER   := NULL
            --                                 , p_collateral_id        => -- IN  NUMBER   := NULL
                                               , p_party_id             => l_party_id -- IN  JTF_REQUEST_GRP.G_NUMBER_TBL_TYPE
                                               , p_email                => l_email -- IN  JTF_REQUEST_GRP.G_VARCHAR_TBL_TYPE
                                               , p_fax                  => l_fax -- IN  JTF_REQUEST_GRP.G_VARCHAR_TBL_TYPE
                                               -- Following line is added by ptendulk on 12-Dec-2002
                                               , p_bind_names           => l_bind_names -- IN JTF_REQUEST_GRP.G_VARCHAR_TBL_TYPE
                                               , p_bind_values          => l_bind_values -- IN  JTF_REQUEST_GRP.G_VARCHAR_TBL_TYPE
                                               , x_return_status        => l_return_status -- OUT VARCHAR2
                                               , x_msg_count            => l_msg_count -- OUT NUMBER
                                               , x_msg_data             => l_msg_data -- OUT VARCHAR2
                                               , x_request_history_id   => l_request_history_id  -- OUT NUMBER
                                              );
            IF (AMS_DEBUG_HIGH_ON) THEN
                AMS_Utility_PVT.debug_message('Request ID: ' || l_request_history_id);
            END IF;

            IF l_return_status = FND_API.g_ret_sts_error THEN
               RAISE FND_API.g_exc_error;
            ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
               RAISE FND_API.g_exc_unexpected_error;
            END IF;


         END IF;
      ELSIF (l_system_status_code = 'WAITLISTED')
      THEN
         -- Fulfillment
         IF (    (nvl(FND_PROFILE.value('AMS_FULFILL_ENABLE_FLAG'), 'N') = 'Y')
             AND (nvl(p_block_fulfillment, FND_API.G_FALSE) <> FND_API.G_TRUE)
            )
         THEN
            IF (AMS_DEBUG_HIGH_ON) THEN

                AMS_Utility_PVT.Debug_Message('Calling check_content_rule for fulfillment (waitlisted)');
            END IF;
            AMS_CT_RULE_PVT.check_content_rule(  p_api_version          => 1.0 -- IN  NUMBER
                                               , p_init_msg_list        => FND_API.g_false -- IN  VARCHAR2  := FND_API.g_false
                                               , p_commit               => FND_API.g_false-- IN  VARCHAR2  := FND_API.g_false
                                               , p_object_type          => l_object_type -- IN  VARCHAR2
                                               , p_object_id            => l_object_id  --l_evt_regs_rec.event_offer_id -- IN  NUMBER
                                               , p_trigger_type         => 'REG_WAITLIST' -- IN  VARCHAR2
            --                                 , p_requestor_type       => -- IN  VARCHAR2  := NULL
                                               -- Following line is modified by ptendulk on 12-Dec-2002
                                               , p_requestor_id         => get_user_id(l_evt_regs_rec.OWNER_USER_ID)
                                               --, p_requestor_id         => AMS_Utility_PVT.get_resource_id(l_evt_regs_rec.OWNER_USER_ID) -- IN  NUMBER
            --                                 , p_server_group         => -- IN  NUMBER := NULL
            --                                 , p_scheduled_date       => -- IN  DATE  := SYSDATE
            --                                 , p_media_types          => -- IN  VARCHAR2 := 'E'
            --                                 , p_archive              => -- IN  VARCHAR2 := 'N'
            --                                 , p_log_user_ih          => -- IN  VARCHAR2 := 'N'
            --                                 , p_request_type         => 'MASS_CUSTOM' -- IN  VARCHAR2 := 'TEST_EMAIL'
            --                                 , p_language_code        => -- IN  VARCHAR2 := NULL
            --                                 , p_profile_id           => -- IN  NUMBER   := NULL
            --                                 , p_order_id             => -- IN  NUMBER   := NULL
            --                                 , p_collateral_id        => -- IN  NUMBER   := NULL
                                               , p_party_id             => l_party_id -- IN  AMF_REQUEST.number_tbl_type
                                               , p_email                => l_email -- IN  AMF_REQUEST.string_tbl_type
                                               , p_fax                  => l_fax -- IN  AMF_REQUEST.string_tbl_type
                                               -- Following line is added by ptendulk on 12-Dec-2002
                                               , p_bind_names           => l_bind_names -- IN JTF_REQUEST_GRP.G_VARCHAR_TBL_TYPE
                                               , p_bind_values          => l_bind_values -- IN  AMF_REQUEST.string_tbl_type
                                               , x_return_status        => l_return_status -- OUT VARCHAR2
                                               , x_msg_count            => l_msg_count -- OUT NUMBER
                                               , x_msg_data             => l_msg_data -- OUT VARCHAR2
                                               , x_request_history_id   => l_request_history_id  -- OUT NUMBER
                                              );
            IF (AMS_DEBUG_HIGH_ON) THEN
                AMS_Utility_PVT.debug_message('Request ID: ' || l_request_history_id);
            END IF;

            IF l_return_status = FND_API.g_ret_sts_error THEN
               RAISE FND_API.g_exc_error;
            ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
               RAISE FND_API.g_exc_unexpected_error;
            END IF;

         END IF;
      END IF;
   END IF;  -- attendance flag and sysdate

END Insert_evtregs;

FUNCTION check_number_registered(p_event_offer_id IN NUMBER)
RETURN NUMBER
IS
   cursor c_num_registered is
   select count(*)
   from AMS_EVENT_REGISTRATIONS
   where event_offer_id = p_event_offer_id
     and system_status_code = 'REGISTERED';

   l_num_registered NUMBER := 0;

BEGIN

   open c_num_registered;
   fetch c_num_registered
   into l_num_registered;
   close c_num_registered;

   return l_num_registered;

END;

FUNCTION check_number_waitlisted(p_event_offer_id IN NUMBER)
RETURN NUMBER
IS
   cursor c_num_waitlisted is
   select count(*)
   from AMS_EVENT_REGISTRATIONS
   where event_offer_id = p_event_offer_id
     and system_status_code = 'WAITLISTED';

   l_num_waitlisted NUMBER := 0;

BEGIN

   open c_num_waitlisted;
   fetch c_num_waitlisted
   into l_num_waitlisted;
   close c_num_waitlisted;

   return l_num_waitlisted;

END;

FUNCTION check_reg_availability(  p_effective_capacity  IN  NUMBER
                                , p_event_offer_id      IN  NUMBER
                               )
RETURN NUMBER -- return no. of seat availability
IS

   l_availability NUMBER := 0;
   l_max_capacity NUMBER;
BEGIN

   if (p_effective_capacity = 0)
   then
     select reg_maximum_capacity into l_max_capacity          --anchaudh added for bug#3119915.
     from AMS_event_offers_all_B
     where event_offer_id = p_event_offer_id;

      if(l_max_capacity is null) then              --anchaudh added for bug#3119915.
      l_availability := 1;
     else
      l_availability := 0;         --anchaudh :fixed bug#3101955,changed l_availability := 0 instead of  l_availability := 1
     end if;
   else
      l_availability := round(p_effective_capacity - check_number_registered(p_event_offer_id => p_event_offer_id));
   end if; -- p_effective_capacity

   return l_availability;

END check_reg_availability;

FUNCTION check_waitlist_availability(  l_reg_waitlist_pct    IN  NUMBER
                                     , l_effective_capacity  IN   NUMBER
                                     , l_event_offer_id      IN   NUMBER
                                    )
RETURN VARCHAR2 -- FND_API.g_true or false
IS

   cursor c_num_waitlist_done is
   select count(*)
   from AMS_EVENT_REGISTRATIONS
   where event_offer_id = l_event_offer_id
     and system_status_code = 'WAITLISTED';

   l_num_of_waitlist_done  NUMBER := 0;
   l_availability          NUMBER := 0;

BEGIN

   IF (l_reg_waitlist_pct is NULL)
   THEN
      return FND_API.g_true;
   ELSE
      open c_num_waitlist_done;
      fetch c_num_waitlist_done
      into l_num_of_waitlist_done;
      close c_num_waitlist_done;

      l_availability := (round(l_reg_waitlist_pct*l_effective_capacity/100) - l_num_of_waitlist_done);

      IF (l_availability > 0)
      THEN
         return  FND_API.g_true;
      ELSE
         return  FND_API.g_false;
      END IF; -- l_availabilty > 0
   END IF; -- l_reg_waitlist_pct is NULL

END check_waitlist_availability;

FUNCTION contact_in_invite_list(  p_event_offer_id        IN  NUMBER
                                , p_attendant_contact_id  IN  NUMBER
                                , p_attendant_party_id    IN   NUMBER
                               )
RETURN VARCHAR2 -- FND_API.g_true or false
IS
   l_count  NUMBER  :=  0;


   -- soagrawa modified query for bug# 2600986
   -- soagrawa modified the cursor for bug# 2525529
   -- soagrawa modified the cursor on 08-jun-2004 for performance bug# 3667627

   CURSOR c_exists_in_invite_list
   IS
   SELECT 1
   FROM    ams_list_entries le
           , ams_act_lists al
   WHERE al.list_used_by_id = p_event_offer_id
   AND al.list_used_by in ('EVEO', 'EONE')
   AND al.list_act_type = 'TARGET'
   AND le.list_header_id = al.list_header_id
   AND le.party_id = p_attendant_contact_id;

/*
   CURSOR c_exists_in_invite_list
   IS
   SELECT COUNT(1)
   FROM    ams_list_entries le
   WHERE EXISTS (SELECT 1
                 FROM ams_act_lists al
                 WHERE list_used_by_id = p_event_offer_id
                   AND list_used_by in ('EVEO', 'EONE')
                   AND list_act_type = 'TARGET'
                   AND le.list_header_id = al.list_header_id
                   AND le.party_id = p_attendant_contact_id );
*/
/*
   CURSOR c_exists_in_invite_list
   IS
   SELECT COUNT(1)
   FROM    ams_list_entries le
   WHERE EXISTS (SELECT 1
                 FROM ams_act_lists al
                 WHERE list_used_by_id = p_event_offer_id
                   AND list_used_by in ('EVEO', 'EONE')
                   AND list_act_type = 'TARGET'
                   AND le.list_header_id = al.list_header_id
                   AND ((le.party_id = p_attendant_contact_id
                         AND le.list_entry_source_system_type = 'PERSON_LIST')
                      -- dbiswas modified the following to carry fix for NI bug# 2610067 on 16-apr-2003
                      or(le.party_id IN (SELECT subject_id  -- person id
                                        FROM ar.hz_relationships
                                        WHERE party_id = p_attendant_contact_id
                                        -- soagrawa 23-may-2003 fixed bug# 2949603
                                        -- AND   directional_flag = 'F'
                                        AND subject_Type = 'PERSON'
                                        AND object_Type = 'ORGANIZATION'
                                        )
                         and le.list_entry_source_system_type ='ORGANIZATION_CONTACT_LIST')));
*/


/*
                      (SELECT party_id
                                        FROM ar.hz_relationships
                                        WHERE subject_id = p_attendant_contact_id
                                        AND   subject_type = 'PERSON'
                                        AND   object_type = 'ORGANIZATION'
                                        AND   object_id = le.col147
                                        AND   object_id = p_attendant_party_id)
                         and le.list_entry_source_system_type ='ORGANIZATION_CONTACT_LIST')));
*/
/*   select count(1)
   from ams_list_entries le
   where exists (select 1
                 from ams_act_lists al
                 where list_used_by_id = p_event_offer_id
                   and list_used_by in ('EVEO', 'EONE')
                   and list_act_type = 'TARGET'
                   and le.list_header_id = al.list_header_id
                   and le.party_id = p_attendant_contact_id
                );
/*
     and exists (select 1
                 from hz_relationships re
                 where subject_id = p_attendant_contact_id
                   and subject_type = 'PERSON'
                   and le.party_id = re.party_id
                );
*/

BEGIN

   -- get invite list for event offer id and verify l_attendant_contact_id is in the invite list *
   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_Utility_PVT.Debug_Message('Checking if contact is in invite list');
   END IF;
   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_Utility_PVT.Debug_Message('(event_offer_id, attendant_contact_id) = (' || p_event_offer_id || ',' || p_attendant_contact_id || ')');
   END IF;

   open c_exists_in_invite_list;
   fetch c_exists_in_invite_list
   into l_count;
   close c_exists_in_invite_list;

   IF (AMS_DEBUG_HIGH_ON) THEN



       AMS_Utility_PVT.Debug_Message('l_count: ' || l_count);

   END IF;

   IF (l_count > 0)
   THEN
      return FND_API.g_true;
   END IF; -- l_count > 0

   return FND_API.g_false;

END contact_in_invite_list;

-- SUB PART OF FK VALIDATION BELOW
PROCEDURE check_registrant_fk_info(  p_registrant_party_id    IN  NUMBER
                                   , p_registrant_contact_id  IN  NUMBER
                                   , p_registrant_account_id  IN  NUMBER
                                   , x_return_status          OUT NOCOPY VARCHAR2
                                  )
IS

BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   ------------------------- registrant party id -------------------
   IF (   (p_registrant_party_id is NOT NULL)
       OR (p_registrant_party_id <> FND_API.g_miss_num)
      )
   THEN
      IF (AMS_Utility_PVT.check_fk_exists(  'hz_parties'
                                          , 'party_id'
                                          , p_registrant_party_id
                                         ) = FND_API.g_false
         )
      THEN
         AMS_Utility_Pvt.Error_Message(p_message_name => 'AMS_EVT_REG_BAD_PARTY_ID');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF; -- check_fk_exists
   END IF; -- p_registrant_party_id

   /*
   -------------------------registration CONTACT id-------------------
   IF p_registrant_contact_id IS NOT NULL OR p_registrant_contact_id <> FND_API.g_miss_num THEN
      IF AMS_Utility_PVT.check_fk_exists(
            'hz_org_contacts',
            'org_contact_id',
             p_registrant_contact_id,
         AMS_Utility_PVT.g_number,
         'party_relationship_id ='|| p_registrant_party_id
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_EVT_REG_BAD_CONTACT_ID');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         --RETURN;
      END IF;
   END IF;
   */

   -------------------------registration account id-------------------
   IF (    (p_registrant_account_id IS NOT NULL)
       AND (p_registrant_account_id <> FND_API.g_miss_num)
      )
   THEN
      IF (AMS_Utility_PVT.check_fk_exists(  'hz_cust_accounts'
                                          , 'cust_account_id'
                                          , p_registrant_account_id
                                          , AMS_Utility_PVT.g_number
                                          , 'party_id ='|| p_registrant_party_id
                                         ) = FND_API.g_false
         )
      THEN
         AMS_Utility_Pvt.Error_Message(p_message_name => 'AMS_EVT_REG_BAD_ACCOUNT_ID');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF; -- check_fk_exists
   END IF; -- p_registrant_account_id

END check_registrant_fk_info;

PROCEDURE transfer_insert(  p_Api_Version_Number      IN  NUMBER
                          , p_Init_Msg_List           IN  VARCHAR2  := FND_API.G_FALSE
                          , p_Commit                  IN  VARCHAR2  := FND_API.G_FALSE
                          , p_old_offer_id            IN  NUMBER
                          , p_new_offer_id            IN  NUMBER
                          , p_system_status_code      IN  VARCHAR2
                          , p_reg_status_date         IN  DATE
                          , p_old_confirmation_code   IN  VARCHAR2
                          , p_registrant_account_id   IN  NUMBER
                          , p_registrant_party_id     IN  NUMBER
                          , p_registrant_contact_id   IN  NUMBER
                          , p_attendant_party_id      IN  NUMBER
                          , p_attendant_contact_id    IN  NUMBER
                          , x_new_confirmation_code   OUT NOCOPY VARCHAR2
                          , x_new_system_status_code  OUT NOCOPY VARCHAR2
                          , x_new_registration_id     OUT NOCOPY NUMBER
                          , x_Return_Status           OUT NOCOPY VARCHAR2
                          , x_Msg_Count               OUT NOCOPY NUMBER
                          , x_Msg_Data                OUT NOCOPY VARCHAR2
                         )
IS

   l_return_status       VARCHAR2(1);
   l_api_name            CONSTANT VARCHAR2(30)  := 'transfer_insert';
   l_api_version_number  CONSTANT NUMBER        := 1.0;
   l_full_name           VARCHAR2(60)           := G_PKG_NAME || '.' || l_api_name;

   CURSOR c_reg IS
   SELECT
      EVENT_REGISTRATION_ID,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_LOGIN,
      OBJECT_VERSION_NUMBER,
      EVENT_OFFER_ID,
      APPLICATION_ID,
      ACTIVE_FLAG,
      OWNER_USER_ID ,
      SYSTEM_STATUS_CODE,
      DATE_REGISTRATION_PLACED,
      USER_STATUS_ID,
      LAST_REG_STATUS_DATE,
      REG_SOURCE_TYPE_CODE,
      REGISTRATION_SOURCE_ID,
      CONFIRMATION_CODE,
      SOURCE_CODE,
      REGISTRATION_GROUP_ID,
      REGISTRANT_PARTY_ID,
      REGISTRANT_CONTACT_ID,
      REGISTRANT_ACCOUNT_ID,
      ATTENDANT_PARTY_ID,
      ATTENDANT_CONTACT_ID,
      ATTENDANT_ACCOUNT_ID,
      ORIGINAL_REGISTRANT_CONTACT_ID,
      PROSPECT_FLAG,
      ATTENDED_FLAG,
      CONFIRMED_FLAG,
      EVALUATED_FLAG,
      null,
      ATTENDANCE_RESULT_CODE,
      WAITLISTED_PRIORITY,
      TARGET_LIST_ID,
      INBOUND_MEDIA_ID,
      INBOUND_CHANNEL_ID,
      CANCELLATION_CODE,
      CANCELLATION_REASON_CODE,
      ATTENDANCE_FAILURE_REASON,
      ATTENDANT_LANGUAGE,
      SALESREP_ID,
      ORDER_HEADER_ID,
      ORDER_LINE_ID,
      DESCRIPTION,
      MAX_ATTENDEE_OVERRIDE_FLAG,
      INVITE_ONLY_OVERRIDE_FLAG,
      PAYMENT_STATUS_CODE,
      AUTO_REGISTER_FLAG,
      ATTRIBUTE_CATEGORY,
      ATTRIBUTE1 ,
      ATTRIBUTE2 ,
      ATTRIBUTE3 ,
      ATTRIBUTE4 ,
      ATTRIBUTE5 ,
      ATTRIBUTE6 ,
      ATTRIBUTE7 ,
      ATTRIBUTE8 ,
      ATTRIBUTE9 ,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15,
      attendee_role_type,           -- Hornet : added for imeeting integration
      notification_type,            -- Hornet : added for imeeting integration
      last_notified_time,           -- Hornet : added for imeeting integration
      EVENT_JOIN_TIME,              -- Hornet : added for imeeting integration
      EVENT_EXIT_TIME,              -- Hornet : added for imeeting integration
      MEETING_ENCRYPTION_KEY_CODE   -- Hornet : added for imeeting integration
   FROM ams_event_registrations
   WHERE confirmation_code = p_old_confirmation_code
     and event_offer_id = p_old_offer_id;

   l_evt_regs_rec  evt_regs_rec_type;

BEGIN

   -- Standard Start of API savepoint
   SAVEPOINT transfer_insert_PVT;
   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   IF (FND_API.to_boolean(p_init_msg_list))
   THEN
      FND_MSG_PUB.initialize;
   END IF; -- p_init_msg_list

   -- Standard call to check for call compatibility.
   IF (NOT FND_API.Compatible_API_Call(  l_api_version_number
                                       , p_api_version_number
                                       , l_api_name
                                       , G_PKG_NAME
                                      )
      )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF; -- compatible API call

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   OPEN c_reg;
   FETCH c_reg
   INTO l_evt_regs_rec;
   IF (c_reg%NOTFOUND)
   THEN
      CLOSE c_reg;
      AMS_Utility_Pvt.Error_Message(p_message_name => 'AMS_API_RECORD_NOT_FOUND');
      RAISE FND_API.g_exc_error;
   END IF; -- c_reg%NOTFOUND
   CLOSE c_reg;


   -- validate the registrant fk info....
   check_registrant_fk_info(  p_registrant_party_id
                            , p_registrant_contact_id
                            , p_registrant_account_id
                            , l_return_status
                           );

   IF (l_return_status = FND_API.g_ret_sts_unexp_error)
   THEN
      RAISE FND_API.g_exc_unexpected_error;
   ELSIF (l_return_status = FND_API.g_ret_sts_error)
   THEN
      RAISE FND_API.g_exc_error;
   END IF; -- l_return_status

   -- make changes to the record...
   l_evt_regs_rec.event_registration_id := NULL;
   l_evt_regs_rec.confirmation_code := NULL;
   l_evt_regs_rec.object_version_number := NULL;
   l_evt_regs_rec.system_status_code := NULL;
   l_evt_regs_rec.event_offer_id := p_new_offer_id;
   l_evt_regs_rec.date_registration_placed := NULL;
   l_evt_regs_rec.last_reg_status_date := p_reg_status_date;

   if (p_registrant_contact_id IS NOT NULL)
   then
      l_evt_regs_rec.ORIGINAL_REGISTRANT_CONTACT_ID := l_evt_regs_rec.REGISTRANT_CONTACT_ID;
   end if; -- p_registrant_contact_id

   l_evt_regs_rec.REGISTRANT_ACCOUNT_ID := nvl(p_registrant_account_id,l_evt_regs_rec.REGISTRANT_ACCOUNT_ID);
   l_evt_regs_rec.REGISTRANT_PARTY_ID := nvl(p_registrant_party_id,l_evt_regs_rec.REGISTRANT_PARTY_ID);
   l_evt_regs_rec.REGISTRANT_CONTACT_ID := nvl(p_registrant_contact_id,l_evt_regs_rec.REGISTRANT_CONTACT_ID);
   l_evt_regs_rec.ATTENDANT_PARTY_ID := nvl(p_attendant_party_id,l_evt_regs_rec.ATTENDANT_PARTY_ID);
   l_evt_regs_rec.ATTENDANT_CONTACT_ID := nvl(p_attendant_contact_id,l_evt_regs_rec.ATTENDANT_CONTACT_ID);

   Insert_evtRegs(  l_evt_regs_rec
                  , p_system_status_code
                  , FND_API.G_FALSE
                  , x_new_confirmation_code
                  , x_new_registration_id
                 );
   x_new_system_status_code := p_system_status_code;
   -- should i be committing before cancel_evtregs call....or just use cancel_evtregs commit call
   -- something wrong  happens...rollback...called in transfer and validate....return l_return status

   IF FND_API.to_boolean(p_commit)
   THEN
      COMMIT;
   END IF; -- p_commit

   FND_MSG_PUB.count_and_get(  p_encoded => FND_API.g_false
                             , p_count   => x_msg_count
                             , p_data    => x_msg_data
                            );

   IF (AMS_DEBUG_HIGH_ON) THEN



       AMS_Utility_PVT.debug_message(l_full_name ||': end');

   END IF;

EXCEPTION

   WHEN FND_API.g_exc_error
   THEN
      ROLLBACK TO transfer_insert_PVT;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(  p_encoded => FND_API.g_false
                                , p_count   => x_msg_count
                                , p_data    => x_msg_data
                               );

   WHEN FND_API.g_exc_unexpected_error
   THEN
     ROLLBACK TO transfer_insert_PVT;
      x_return_status := FND_API.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get(  p_encoded => FND_API.g_false
                                , p_count   => x_msg_count
                                , p_data    => x_msg_data
                               );

   WHEN OTHERS
   THEN
      ROLLBACK TO transfer_insert_PVT;
      x_return_status := FND_API.g_ret_sts_unexp_error;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
      THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF; -- check_msg_level

      FND_MSG_PUB.count_and_get(  p_encoded => FND_API.g_false
                                , p_count   => x_msg_count
                                , p_data    => x_msg_data
                               );

END transfer_insert;

-- 2/16/00 sugupta- added function Get_Reg_Rec to get rec type for telesales
FUNCTION Get_Reg_Rec
RETURN AMS_EvtRegs_PVT.evt_regs_Rec_Type
IS
   TMP_REC  AMS_EvtRegs_PVT.evt_regs_Rec_Type;
BEGIN
   RETURN TMP_REC;
END Get_Reg_Rec;


PROCEDURE Create_evtregs(  P_Api_Version_Number     IN  NUMBER
                         , P_Init_Msg_List          IN  VARCHAR2  := FND_API.G_FALSE
                         , P_Commit                 IN  VARCHAR2  := FND_API.G_FALSE
                         , p_validation_level       IN  NUMBER    := FND_API.G_VALID_LEVEL_FULL
                         , p_evt_regs_rec           IN  evt_regs_Rec_Type
                         , p_block_fulfillment      IN  VARCHAR2  := FND_API.G_FALSE
                         , x_event_registration_id  OUT NOCOPY NUMBER
                         , x_confirmation_code      OUT NOCOPY VARCHAR2
                         , x_system_status_code     OUT NOCOPY VARCHAR2
                         , x_return_status          OUT NOCOPY VARCHAR2
                         , x_msg_count              OUT NOCOPY NUMBER
                         , x_msg_data               OUT NOCOPY VARCHAR2
                        )
IS

   l_api_name                    CONSTANT VARCHAR2(30)  := 'Create_evtregs';
   l_api_version_number          CONSTANT NUMBER        := 1.0;
   l_full_name                   CONSTANT VARCHAR2(60)  := G_PKG_NAME || '.' || l_api_name;
   l_return_status               VARCHAR2(1);
   l_evt_regs_rec                evt_regs_rec_type      := P_evt_regs_Rec;
   l_event_offer_id              NUMBER                 :=  l_evt_regs_Rec.event_offer_id;
   l_invite_only_override_flag   VARCHAR2(1)            := NVL(l_evt_regs_Rec.invite_only_override_flag, 'N');
   l_attendant_party_id          NUMBER                 := l_evt_regs_Rec.attendant_party_id;
   l_attendant_contact_id        NUMBER                 := l_evt_regs_Rec.attendant_contact_id;
   l_max_attendee_override_flag  VARCHAR2(1)            := l_evt_regs_Rec.max_attendee_override_flag;
   l_waitlist_flag               VARCHAR2(1)            := l_evt_regs_Rec.waitlisted_flag;
   l_invited_only_flag           VARCHAR2(1)            := 'N';
   l_waitlist_allowed_flag       VARCHAR2(1)            := 'N';
   l_reg_required_flag           VARCHAR2(1);
   l_reg_frozen_flag             VARCHAR2(1);
   l_effective_capacity          NUMBER;
   l_reg_waitlist_pct            NUMBER;
   l_system_status_code          VARCHAR2(30);

   Cursor get_offer_details(l_event_offer_id NUMBER) is
   select
      REG_INVITED_ONLY_FLAG,
      REG_WAITLIST_ALLOWED_FLAG,
      REG_REQUIRED_FLAG,
      REG_FROZEN_FLAG,
      REG_EFFECTIVE_CAPACITY,
      REG_WAITLIST_PCT
   from ams_event_offers_all_b
   where EVENT_OFFER_ID = l_event_offer_id;


BEGIN

   -- Standard Start of API savepoint
   SAVEPOINT CREATE_EvtRegs_PVT;
   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   IF FND_API.to_boolean(p_init_msg_list)
   THEN
      FND_MSG_PUB.initialize;
   END IF; -- p_init_msg_list

   -- Standard call to check for call compatibility.
   IF (NOT FND_API.Compatible_API_Call(  l_api_version_number
                                       , p_api_version_number
                                       , l_api_name
                                       , G_PKG_NAME
                                      )
      )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF; -- compatible API call

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Validate Environment
   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_Utility_PVT.debug_message(l_full_name ||': validate');
   END IF;

   Validate_evtregs(  p_api_version_number => l_api_version_number
                    , p_init_msg_list      => p_init_msg_list
                    , p_validation_level   => p_validation_level
                    , P_evt_regs_Rec       => l_evt_regs_Rec
                    , p_validation_mode    => JTF_PLSQL_API.g_create
                    , x_return_status      => l_return_status
                    , x_msg_count          => x_msg_count
                    , x_msg_data           => x_msg_data
                   );

   IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
   THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error
   THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF; -- l_return_status

   -----------------------insert------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_Utility_PVT.debug_message(l_full_name || ': insert');
   END IF;

   IF (l_event_offer_id is NULL)
   then
      -- already validated
      IF (AMS_DEBUG_HIGH_ON) THEN

          AMS_UTILITY_PVT.debug_message('Corresponding event offering information is not provided');
      END IF;
   ELSE

      open get_offer_details(l_event_offer_id);
      fetch get_offer_details
      into
         l_invited_only_flag,
         l_waitlist_allowed_flag,
         l_reg_required_flag,
         l_reg_frozen_flag,
         l_effective_capacity,
         l_reg_waitlist_pct;
      close get_offer_details;

      IF (AMS_DEBUG_HIGH_ON) THEN



          AMS_UTILITY_PVT.debug_message('l_invited_only_flag: ' || l_invited_only_flag);

      END IF;
      IF (AMS_DEBUG_HIGH_ON) THEN

          AMS_UTILITY_PVT.debug_message('l_invite_only_override_flag: ' || l_invite_only_override_flag);
      END IF;

      -- soagrawa modified call out to contact_in_invite_list for bug# 2600986
      IF (l_invited_only_flag = 'Y')
      THEN
         IF (    (l_invite_only_override_flag = 'N')
             AND (contact_in_invite_list(  l_event_offer_id
                                         , l_attendant_contact_id
                                         , l_attendant_party_id
                                        ) = FND_API.g_false
                 )
            )
         THEN
            IF (AMS_DEBUG_HIGH_ON) THEN

                AMS_UTILITY_PVT.debug_message('The attendant is not on the invite list');
            END IF;
            AMS_UTILITY_PVT.error_message('AMS_EVT_REG_NOT_INVITED');
            x_return_status := FND_API.g_ret_sts_error;
            RAISE FND_API.G_EXC_ERROR;
         ELSE
            l_system_status_code := 'REGISTERED';

            Insert_evtRegs(  p_evt_regs_rec          => l_evt_regs_rec
                           , p_system_status_code    => l_system_status_code
                           , p_block_fulfillment     => p_block_fulfillment
                           , x_confirmation_code     => x_confirmation_code
                           , x_event_registration_id => x_event_registration_id
                          );

            x_system_status_code := 'REGISTERED';
         END IF; -- invite only override flag
      ELSE -- INVITE ONLY FLAG IS NO
         IF (l_reg_required_flag = 'N')
         THEN
            IF (AMS_DEBUG_HIGH_ON) THEN

                AMS_UTILITY_PVT.DEBUG_MESSAGE ('Registration for this event offering is not required');
            END IF;
            AMS_UTILITY_PVT.error_message('AMS_EVT_REG_NOT_REQ');
            x_return_status := FND_API.g_ret_sts_error;
            RAISE FND_API.G_EXC_ERROR;
         ELSE --reg required flag is Y
            IF (l_reg_frozen_flag = 'Y')
            THEN
               IF (AMS_DEBUG_HIGH_ON) THEN

                   AMS_UTILITY_PVT.debug_message('Registrations for this event offering are no longer accepted');
               END IF;
               AMS_UTILITY_PVT.error_message('AMS_EVT_REG_FROZEN');
               x_return_status := FND_API.g_ret_sts_error;
               RAISE FND_API.G_EXC_ERROR;
            END IF;

            IF (   (l_max_attendee_override_flag = 'Y')
                OR (l_waitlist_flag = 'N')
                OR (    (nvl(l_waitlist_flag, 'X') = 'X')
                    AND (check_reg_availability(l_effective_capacity, l_event_offer_id) > 0)
                   )
               )
            THEN
               l_system_status_code := 'REGISTERED';
               Insert_evtRegs(  p_evt_regs_rec          => l_evt_regs_rec
                              , p_system_status_code    => l_system_status_code
                              , p_block_fulfillment     => p_block_fulfillment
                              , x_confirmation_code     => x_confirmation_code
                              , x_event_registration_id => x_event_registration_id
                             );
               x_system_status_code := 'REGISTERED';

            ELSE -- check for waitlist
               IF (    (l_waitlist_allowed_flag = 'N')
                   AND (nvl(l_waitlist_flag, 'X') <> 'Y')
                  )
               THEN
                  IF (AMS_DEBUG_HIGH_ON) THEN

                      AMS_UTILITY_PVT.debug_message('Registrations sold out. Waitlist not allowed for this event offering');
                  END IF;
                  AMS_UTILITY_PVT.error_message('AMS_EVT_REG_NO_WAIT_ALLOWED');
                  x_return_status := FND_API.g_ret_sts_error;
                  RAISE FND_API.G_EXC_ERROR;
               ELSE -- wailist allowed
--                if (l_reg_waitlist_pct is NOT NULL)
--                then
                     if (    (nvl(l_waitlist_flag, 'X') <> 'Y')
                         AND (check_waitlist_availability(  l_reg_waitlist_pct
                                                          , l_effective_capacity
                                                          , l_event_offer_id
                                                         ) = FND_API.g_false
                             )
                        )
                     THEN
                        IF (AMS_DEBUG_HIGH_ON) THEN

                            AMS_UTILITY_PVT.debug_message('Eff Capacity:' || l_effective_capacity || 'and wait:' || l_reg_waitlist_pct);
                        END IF;
                        IF (AMS_DEBUG_HIGH_ON) THEN

                            AMS_UTILITY_PVT.debug_message('Waiting list for this event offer ing is full');
                        END IF;
                        AMS_UTILITY_PVT.error_message('AMS_EVT_REG_NO_WAIT_AVAILABLE');
                        x_return_status := FND_API.g_ret_sts_error;
                        RAISE FND_API.G_EXC_ERROR;
                     end if; -- check_waitlist_availability
--                end if; -- l_reg_waitlist_pct
                  l_system_status_code := 'WAITLISTED';
                  Insert_evtRegs(  p_evt_regs_rec          => l_evt_regs_rec
                                 , p_system_status_code    => l_system_status_code
                                 , p_block_fulfillment     => p_block_fulfillment
                                 , x_confirmation_code     => x_confirmation_code
                                 , x_event_registration_id => x_event_registration_id
                                );
                  x_system_status_code := 'WAITLISTED';

               END IF; -- wailist allowed
            END IF; -- check reg else waitlist availability
         END IF; -- Reg required flag is Y else N
      END IF; -- invite only flag is Y else N
   END IF; -- event offer id not null

   IF FND_API.to_boolean(p_commit)
   THEN
      COMMIT;
   END IF; -- p_commit

   FND_MSG_PUB.count_and_get(  p_encoded => FND_API.g_false
                             , p_count   => x_msg_count
                             , p_data    => x_msg_data
                            );

   IF (AMS_DEBUG_HIGH_ON) THEN



       AMS_Utility_PVT.debug_message(l_full_name || ': end');

   END IF;

EXCEPTION

   WHEN FND_API.g_exc_error
   THEN
      ROLLBACK TO CREATE_EvtRegs_PVT;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(  p_encoded => FND_API.g_false
                                , p_count   => x_msg_count
                                , p_data    => x_msg_data
                               );

   WHEN FND_API.g_exc_unexpected_error
   THEN
      ROLLBACK TO CREATE_EvtRegs_PVT;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(  p_encoded => FND_API.g_false
                                , p_count   => x_msg_count
                                , p_data    => x_msg_data
                               );

   WHEN OTHERS
   THEN
      ROLLBACK TO CREATE_EvtRegs_PVT;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
      THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.count_and_get(  p_encoded => FND_API.g_false
                                , p_count   => x_msg_count
                                , p_data    => x_msg_data
                               );

End Create_evtregs;

PROCEDURE UPDATE_evtregs_wrapper(  P_Api_Version_Number         IN  NUMBER
                                 , P_Init_Msg_List              IN  VARCHAR2 := FND_API.G_FALSE
                                 , P_Commit                     IN  VARCHAR2 := FND_API.G_FALSE
                                 , p_validation_level           IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
                                 , P_evt_regs_Rec               IN  evt_regs_Rec_Type
                                 , p_block_fulfillment          IN  VARCHAR2 := FND_API.G_FALSE
                                 , p_cancellation_reason_code   IN  VARCHAR2 := NULL
                                 , x_cancellation_code          OUT NOCOPY VARCHAR2
                                 , X_Return_Status              OUT NOCOPY VARCHAR2
                                 , X_Msg_Count                  OUT NOCOPY NUMBER
                                 , X_Msg_Data                   OUT NOCOPY VARCHAR2
                                )

IS

   l_api_name                 CONSTANT VARCHAR2(30) := 'Update_evtregs_wrapper';
   l_api_version_number       CONSTANT NUMBER       := 1.0;
   l_full_name                VARCHAR2(60)          := G_PKG_NAME || '.' || l_api_name;
   l_return_status            VARCHAR2(1);
   l_cancel_id                NUMBER;
   l_cancellation_reason_code VARCHAR2(30)          := nvl(  p_cancellation_reason_code
                                                           , P_evt_regs_Rec.cancellation_reason_code
                                                          );

   CURSOR c_reg IS
   SELECT *
   FROM ams_event_registrations
   WHERE event_registration_id = p_evt_regs_rec.event_registration_id;

   Cursor c_cancel_status_id is
   select user_status_id
   from ams_user_statuses_vl
   where system_status_type = 'AMS_EVENT_REG_STATUS'
     and system_status_code = 'CANCELLED'
     and default_flag = 'Y';

   l_evt_regs_Rec        c_reg%ROWTYPE;

BEGIN

   -- Standard Start of API savepoint
   SAVEPOINT UPDATE_evtregs_wrapper;

   -- Standard call to check for call compatibility.
   IF (NOT FND_API.Compatible_API_Call(  l_api_version_number
                                       , p_api_version_number
                                       , l_api_name
                                       , G_PKG_NAME
                                      )
      )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF; -- compatible API call


   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF (FND_API.to_Boolean(p_init_msg_list))
   THEN
      FND_MSG_PUB.initialize;
   END IF; -- p_init_msg_list

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   OPEN c_reg;
   FETCH c_reg
   INTO l_evt_regs_rec;
   IF c_reg%NOTFOUND THEN
      CLOSE c_reg;
      AMS_UTILITY_PVT.error_message('AMS_API_RECORD_NOT_FOUND');
      RAISE FND_API.g_exc_error;
   END IF; -- c_reg%NOTFOUND
   CLOSE c_reg;

   open c_cancel_status_id;
   fetch c_cancel_status_id
   into l_cancel_id;
   close c_cancel_status_id;

   -- soagrawa added on 29-jan-2003
  /* IF ((l_evt_regs_rec.user_status_id = p_evt_regs_rec.user_status_id
        OR p_evt_regs_rec.user_status_id = FND_API.g_miss_num)
      AND (l_evt_regs_rec.attended_flag = p_evt_regs_rec.attended_flag
        OR p_evt_regs_rec.attended_flag = FND_API.g_miss_char)
      AND (l_evt_regs_rec.reg_source_type_code = p_evt_regs_rec.reg_source_type_code
        OR p_evt_regs_rec.reg_source_type_code = FND_API.g_miss_char)
      )
   THEN
      AMS_UTILITY_PVT.debug_message('Nothing changed');
      RETURN;
   ELSE
      AMS_UTILITY_PVT.debug_message('Something changed');
   END IF;
*/

   -- soagrawa 29-jan-2003  modified the following code for bug# 2775357
   IF ( ( l_evt_regs_rec.user_status_id = l_cancel_id
       OR p_evt_regs_Rec.user_status_id = l_cancel_id)
   AND p_evt_regs_Rec.attended_flag = 'Y')
   THEN
      IF p_evt_regs_Rec.attended_flag <> l_evt_regs_Rec.attended_flag
         AND l_evt_regs_rec.user_status_id <> p_evt_regs_rec.user_status_id
      THEN
         -- trying to update both attended flag to Y and status to cancel
         -- A registrant who has already attended cannot have his registration cancelled.
         AMS_UTILITY_PVT.error_message('AMS_EVT_REG_NO_ATTENDED_1');
         RAISE FND_API.g_exc_error;

      ELSIF l_evt_regs_rec.user_status_id <> p_evt_regs_rec.user_status_id
      THEN
         -- trying to update status to cancel when attended flag is already Y
         -- A registrant who has already attended cannot have his registration cancelled.
         AMS_UTILITY_PVT.error_message('AMS_EVT_REG_NO_ATTENDED_1');
         RAISE FND_API.g_exc_error;

      ELSIF p_evt_regs_Rec.attended_flag <> l_evt_regs_Rec.attended_flag
      THEN
         -- trying to update attended flag to Y when status is already cancelled
         -- Cannot update the Attended flag for the Registrant whose Registration Status is Cancelled.
         AMS_UTILITY_PVT.error_message('AMS_EVT_REG_NO_ATTENDED');
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;



   IF (    (l_evt_regs_rec.user_status_id <> l_cancel_id)
       AND (p_evt_regs_rec.user_status_id =  l_cancel_id)
      )
   THEN
       cancel_evtregs(  p_api_version_number       => p_api_version_number
                      , p_init_msg_list            => p_init_msg_list
                      , p_commit                   => p_commit
                      , p_object_version           => p_evt_regs_rec.object_version_number
                      , p_event_offer_id           => l_evt_regs_rec.event_offer_id
                      , p_registrant_party_id      => l_evt_regs_rec.registrant_party_id
                      , p_confirmation_code        => l_evt_regs_rec.confirmation_code
                      , p_registration_group_id    => l_evt_regs_rec.registration_group_id
                      , p_cancellation_reason_code => l_cancellation_reason_code
                      , p_block_fulfillment        => p_block_fulfillment
                      , x_cancellation_code        => x_cancellation_code
                      , x_return_status            => x_return_status
                      , x_msg_count                => x_msg_count
                      , x_msg_data                 => x_msg_data
                     );
   ELSE
       update_evtregs(  p_api_version_number => p_api_version_number
                      , p_init_msg_list      => p_init_msg_list
                      , p_commit             => p_commit
                      , p_validation_level   => p_validation_level
                      , p_evt_regs_rec       => p_evt_regs_rec
                      , p_block_fulfillment  => p_block_fulfillment
                      , x_return_status      => x_return_status
                      , x_msg_count          => x_msg_count
                      , x_msg_data           => x_msg_data
                     );
   END IF; -- l_cancel_id

EXCEPTION

   WHEN FND_API.g_exc_error
   THEN
      ROLLBACK TO UPDATE_evtregs_wrapper;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(  p_encoded => FND_API.g_false
                                , p_count   => x_msg_count
                                , p_data    => x_msg_data
                               );

   WHEN FND_API.g_exc_unexpected_error
   THEN
      ROLLBACK TO UPDATE_evtregs_wrapper;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(  p_encoded => FND_API.g_false
                                , p_count   => x_msg_count
                                , p_data    => x_msg_data
                               );

   WHEN OTHERS
   THEN
      ROLLBACK TO UPDATE_evtregs_wrapper;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
      THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.count_and_get(  p_encoded => FND_API.g_false
                                , p_count   => x_msg_count
                                , p_data    => x_msg_data
                               );
END Update_evtregs_wrapper;

PROCEDURE Update_evtregs(  P_Api_Version_Number  IN  NUMBER
                         , P_Init_Msg_List       IN  VARCHAR2  := FND_API.G_FALSE
                         , P_Commit              IN  VARCHAR2  := FND_API.G_FALSE
                         , p_validation_level    IN  NUMBER    := FND_API.G_VALID_LEVEL_FULL
                         , P_evt_regs_Rec        IN  evt_regs_Rec_Type
                         , p_block_fulfillment   IN  VARCHAR2  := FND_API.G_FALSE
                         , X_Return_Status       OUT NOCOPY VARCHAR2
                         , X_Msg_Count           OUT NOCOPY NUMBER
                         , X_Msg_Data            OUT NOCOPY VARCHAR2
                        )

IS

   l_api_name           CONSTANT VARCHAR2(30) := 'Update_evtregs';
   l_api_version_number CONSTANT NUMBER       := 1.0;
   l_full_name          VARCHAR2(60)          := G_PKG_NAME || '.' || l_api_name;
   l_evt_regs_Rec       evt_regs_Rec_Type;
   l_return_status      VARCHAR2(1);
   l_msg_count          NUMBER;
   l_msg_data           VARCHAR2(2000);
   l_old_reg_status     VARCHAR2(30);
   l_event_capacity     NUMBER;
   l_event_status       VARCHAR2(30);
   l_event_status_name  VARCHAR2(120);

/* Following code is modified by ptendulk to move to 1:1 ffm
   l_email            AMF_REQUEST.string_tbl_type;
   l_fax              AMF_REQUEST.string_tbl_type;
   l_bind_values      AMF_REQUEST.string_tbl_type;
   l_party_id         AMF_REQUEST.number_tbl_type;
*/

   l_email            JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;
   l_fax              JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;
   l_party_id         JTF_FM_REQUEST_GRP.G_NUMBER_TBL_TYPE;
   l_bind_names       JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;
   l_bind_values      JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;



   l_object_type      VARCHAR2(30);
   l_end_date         DATE;
   l_request_history_id   NUMBER;

   CURSOR c_get_object_type(p_event_offer_id IN NUMBER) IS
   SELECT event_object_type,
          trunc(event_end_date) + 1,
          parent_type
   from ams_event_offers_all_b
   where event_offer_id = p_event_offer_id;

   cursor c_old_reg_status(p_reg_id NUMBER) is
   select system_status_code
   from ams_event_registrations
   where event_registration_id = p_reg_id;

   cursor c_event_details(p_event_id NUMBER) is
   select e.reg_effective_capacity,
          e.system_status_code,
          u.name
   from ams_event_offers_all_b e,
        ams_user_statuses_vl u
   where e.event_offer_id = p_event_id
     and e.user_status_id = u.user_status_id;

   cursor c_get_status_code(p_status_id IN NUMBER) IS
   select system_status_code
   from ams_user_statuses_b
   where user_status_id = p_status_id
     and system_status_type = 'AMS_EVENT_REG_STATUS';

   -- soagrawa 18-nov-2002 for bug# 2672928
   l_csch_id          NUMBER;
   l_object_id        NUMBER;
   l_parent_type      VARCHAR2(10);

   CURSOR c_csch_id (obj_id NUMBER) IS
   SELECT schedule_id
     FROM ams_campaign_schedules_b
    WHERE related_event_id = obj_id;


BEGIN

   -- Standard Start of API savepoint
   SAVEPOINT UPDATE_EvtRegs_PVT;

   -- Standard call to check for call compatibility.
   IF (NOT FND_API.Compatible_API_Call(  l_api_version_number
                                       , p_api_version_number
                                       , l_api_name
                                       , G_PKG_NAME
                                      )
      )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF; -- compatible API call


   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF (FND_API.to_Boolean(p_init_msg_list))
   THEN
      FND_MSG_PUB.initialize;
   END IF; -- p_init_msg_list

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- add complete_evtreg_rec to complete rec with existing values instead of empty FND_API.g_miss_char
   -- replace g_miss_char/num/date with current column values
   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_Utility_PVT.debug_message(l_full_name ||': complete');
   END IF;
   complete_evtreg_rec(P_evt_regs_Rec, l_evt_regs_Rec);

   -- not now...unique key val provided...sugupta:todo- check for unique key  before calling
   ----------------------- validate ----------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_Utility_PVT.debug_message(l_full_name ||': validate');
   END IF;

   -- Invoke validation procedures
   Validate_evtregs(  p_api_version_number => l_api_version_number
                    , p_init_msg_list      => FND_API.G_FALSE
                    , p_validation_level   => p_validation_level
                    , P_evt_regs_Rec       => l_evt_regs_Rec
                    , p_validation_mode    => JTF_PLSQL_API.g_update
                    , x_return_status      => l_return_status
                    , x_msg_count          => x_msg_count
                    , x_msg_data           => x_msg_data
                   );

   IF (l_return_status = FND_API.g_ret_sts_unexp_error)
   THEN
      RAISE FND_API.g_exc_unexpected_error;
   ELSIF (l_return_status = FND_API.g_ret_sts_error)
   THEN
      RAISE FND_API.g_exc_error;
   END IF; -- l_return_status

   OPEN c_old_reg_status(l_evt_regs_Rec.event_registration_id);
   FETCH c_old_reg_status
   INTO l_old_reg_status;
   CLOSE c_old_reg_status;

   OPEN c_event_details(l_evt_regs_Rec.event_offer_id);
   FETCH c_event_details
   INTO l_event_capacity,
        l_event_status,
        l_event_status_name;
   CLOSE c_event_details;

   IF (nvl(l_event_status, 'X') in ('ARCHIVED', 'CLOSED'))
   THEN
      AMS_Utility_PVT.Error_Message('AMS_EVENT_REG_UPDATE_ERROR', 'STATUS', l_event_status_name);
      RAISE FND_API.g_exc_error;
   END IF;

   -- make sure the status code matches the user status id
   OPEN c_get_status_code(l_evt_regs_Rec.user_status_id);
   FETCH c_get_status_code
   INTO l_evt_regs_rec.system_status_code;
   CLOSE c_get_status_code;

   IF (    (l_old_reg_status = 'WAITLISTED')
       AND (l_evt_regs_Rec.system_status_code = 'REGISTERED')
       AND (l_evt_regs_Rec.max_attendee_override_flag <> 'Y')
       AND (check_reg_availability(  l_event_capacity
                                   , l_evt_regs_Rec.event_offer_id
                                  ) <= 0
           )
      )
   THEN
      AMS_UTILITY_PVT.error_message('AMS_EVT_REG_NO_WAIT_AVAILABLE');
      RAISE FND_API.g_exc_error;
   END IF;

   IF (    (l_old_reg_status = 'WAITLISTED')
       AND (l_evt_regs_Rec.system_status_code = 'REGISTERED')
      )
   THEN
      l_evt_regs_Rec.WAITLISTED_PRIORITY := null;
   END IF;
   -------------------------- update --------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_Utility_PVT.debug_message(l_full_name || ': update');
   END IF;

   update AMS_EVENT_REGISTRATIONS set
      LAST_UPDATE_DATE =  sysdate,
      LAST_UPDATED_BY = FND_GLOBAL.user_id,
      LAST_UPDATE_LOGIN = FND_GLOBAL.conc_login_id,
      OBJECT_VERSION_NUMBER = l_evt_regs_Rec.OBJECT_VERSION_NUMBER + 1,
      EVENT_OFFER_ID = l_evt_regs_Rec.EVENT_OFFER_ID,
      APPLICATION_ID = l_evt_regs_Rec.APPLICATION_ID,
      ACTIVE_FLAG = nvl(l_evt_regs_Rec.ACTIVE_FLAG,'Y'),
      OWNER_USER_ID = l_evt_regs_Rec.OWNER_USER_ID,
      DATE_REGISTRATION_PLACED = nvl(l_evt_regs_Rec.DATE_REGISTRATION_PLACED,sysdate),
      USER_STATUS_ID = l_evt_regs_Rec.USER_STATUS_ID,
      SYSTEM_STATUS_CODE = l_evt_regs_Rec.SYSTEM_STATUS_CODE,
      LAST_REG_STATUS_DATE = nvl(l_evt_regs_Rec.LAST_REG_STATUS_DATE, sysdate),
      REG_SOURCE_TYPE_CODE = l_evt_regs_Rec.REG_SOURCE_TYPE_CODE,
      REGISTRATION_SOURCE_ID = l_evt_regs_Rec.REGISTRATION_SOURCE_ID,
      CONFIRMATION_CODE = l_evt_regs_Rec.CONFIRMATION_CODE,
      SOURCE_CODE = l_evt_regs_Rec.SOURCE_CODE,
      REGISTRATION_GROUP_ID = l_evt_regs_Rec.REGISTRATION_GROUP_ID,
      REGISTRANT_PARTY_ID = l_evt_regs_Rec.REGISTRANT_PARTY_ID,
      REGISTRANT_CONTACT_ID = l_evt_regs_Rec.REGISTRANT_CONTACT_ID,
      ATTENDANT_PARTY_ID = l_evt_regs_Rec.ATTENDANT_PARTY_ID,
      ATTENDANT_CONTACT_ID = l_evt_regs_Rec.ATTENDANT_CONTACT_ID,
      ORIGINAL_REGISTRANT_CONTACT_ID = l_evt_regs_Rec.ORIGINAL_REGISTRANT_CONTACT_ID,
      PROSPECT_FLAG = l_evt_regs_Rec.PROSPECT_FLAG,
      ATTENDED_FLAG = l_evt_regs_Rec.ATTENDED_FLAG,
      CONFIRMED_FLAG = l_evt_regs_Rec.CONFIRMED_FLAG,
      EVALUATED_FLAG = l_evt_regs_Rec.EVALUATED_FLAG,
      ATTENDANCE_RESULT_CODE = l_evt_regs_Rec.ATTENDANCE_RESULT_CODE,
      WAITLISTED_PRIORITY = l_evt_regs_Rec.WAITLISTED_PRIORITY,
      TARGET_LIST_ID = l_evt_regs_Rec.TARGET_LIST_ID,
      INBOUND_MEDIA_ID = l_evt_regs_Rec.INBOUND_MEDIA_ID,
      INBOUND_CHANNEL_ID = l_evt_regs_Rec.INBOUND_CHANNEL_ID,
      CANCELLATION_CODE = l_evt_regs_Rec.CANCELLATION_CODE,
      CANCELLATION_REASON_CODE = l_evt_regs_Rec.CANCELLATION_REASON_CODE,
      ATTENDANCE_FAILURE_REASON = l_evt_regs_Rec.ATTENDANCE_FAILURE_REASON,
      ATTENDANT_LANGUAGE = l_evt_regs_Rec.ATTENDANT_LANGUAGE,
      SALESREP_ID = l_evt_regs_Rec.SALESREP_ID,
      ORDER_HEADER_ID = l_evt_regs_Rec.ORDER_HEADER_ID,
      ORDER_LINE_ID = l_evt_regs_Rec.ORDER_LINE_ID,
      DESCRIPTION = l_evt_regs_Rec.DESCRIPTION,
      MAX_ATTENDEE_OVERRIDE_FLAG = l_evt_regs_Rec.MAX_ATTENDEE_OVERRIDE_FLAG,
      INVITE_ONLY_OVERRIDE_FLAG = l_evt_regs_Rec.INVITE_ONLY_OVERRIDE_FLAG,
      PAYMENT_STATUS_CODE = l_evt_regs_Rec.PAYMENT_STATUS_CODE,
      AUTO_REGISTER_FLAG = l_evt_regs_Rec.AUTO_REGISTER_FLAG,
      ATTRIBUTE_CATEGORY = l_evt_regs_Rec.ATTRIBUTE_CATEGORY,
      ATTRIBUTE1 = l_evt_regs_Rec.ATTRIBUTE1,
      ATTRIBUTE2 = l_evt_regs_Rec.ATTRIBUTE2,
      ATTRIBUTE3 = l_evt_regs_Rec.ATTRIBUTE3,
      ATTRIBUTE4 = l_evt_regs_Rec.ATTRIBUTE4,
      ATTRIBUTE5 = l_evt_regs_Rec.ATTRIBUTE5,
      ATTRIBUTE6 = l_evt_regs_Rec.ATTRIBUTE6,
      ATTRIBUTE7 = l_evt_regs_Rec.ATTRIBUTE7,
      ATTRIBUTE8 = l_evt_regs_Rec.ATTRIBUTE8,
      ATTRIBUTE9 = l_evt_regs_Rec.ATTRIBUTE9,
      ATTRIBUTE10 = l_evt_regs_Rec.ATTRIBUTE10,
      ATTRIBUTE11 = l_evt_regs_Rec.ATTRIBUTE11,
      ATTRIBUTE12 = l_evt_regs_Rec.ATTRIBUTE12,
      ATTRIBUTE13 = l_evt_regs_Rec.ATTRIBUTE13,
      ATTRIBUTE14 = l_evt_regs_Rec.ATTRIBUTE14,
      ATTRIBUTE15 = l_evt_regs_Rec.ATTRIBUTE15,
      attendee_role_type = l_evt_regs_rec.attendee_role_type,                  -- Hornet : added for imeeting integration
      notification_type = l_evt_regs_rec.notification_type,                    -- Hornet : added for imeeting integration
      last_notified_time = l_evt_regs_rec.last_notified_time,                  -- Hornet : added for imeeting integration
      EVENT_JOIN_TIME = l_evt_regs_rec.EVENT_JOIN_TIME,                        -- Hornet : added for imeeting integration
      EVENT_EXIT_TIME = l_evt_regs_rec.EVENT_EXIT_TIME,                        -- Hornet : added for imeeting integration
      MEETING_ENCRYPTION_KEY_CODE = l_evt_regs_rec.MEETING_ENCRYPTION_KEY_CODE -- Hornet : added for imeeting integration
      where EVENT_REGISTRATION_ID = l_evt_regs_Rec.EVENT_REGISTRATION_ID
     and object_version_number = l_evt_regs_Rec.object_version_number;

   IF (SQL%NOTFOUND) THEN
      AMS_UTILITY_PVT.error_message('AMS_API_RECORD_NOT_FOUND');
      RAISE FND_API.g_exc_error;
   END IF; -- SQL%NOTFOUND

   IF (    (l_old_reg_status = 'WAITLISTED')
       AND (l_evt_regs_Rec.system_status_code = 'REGISTERED')
      )
   THEN

      open c_get_object_type(l_evt_regs_rec.event_offer_id);
      fetch c_get_object_type
      into l_object_type,
           l_end_date,
           l_parent_type;
      close c_get_object_type;

      -- soagrawa 18-nov-2002 for bug# 2672928
      l_object_id := l_evt_regs_rec.event_offer_id;

      IF l_object_type = 'EONE'
      THEN
         IF l_parent_type = 'CAMP'
         THEN

            OPEN  c_csch_id(l_object_id);
            FETCH c_csch_id INTO l_csch_id;
            CLOSE c_csch_id;

            l_object_type  :=  'CSCH';
            l_object_id    :=  l_csch_id;
         END IF;
      END IF;
      -- end soagrawa 18-nov-2002


      IF (    (nvl(l_evt_regs_rec.ATTENDED_FLAG, 'N') = 'N')
          AND (sysdate < l_end_date)
         )
      THEN

         write_interaction(  p_event_offer_id => l_evt_regs_rec.EVENT_OFFER_ID
                          -- dbiswas 16-apr-2003 for NI issue with interactions (part of 2610067)
                          -- , p_party_id       => l_evt_regs_rec.ATTENDANT_PARTY_ID
                           , p_party_id       => l_evt_regs_rec.ATTENDANT_CONTACT_ID
                          );

         /* Following code is modified by ptendulk on 12-Dec-2002 to move to 1:1
         l_bind_values(0) := to_char(l_evt_regs_Rec.EVENT_REGISTRATION_ID);
         l_bind_values(1) := to_char(l_evt_regs_Rec.EVENT_REGISTRATION_ID); */
         l_bind_names(1)  := 'REGISTRATION_ID' ;
         l_bind_values(1) := TO_CHAR(l_evt_regs_Rec.event_registration_id);


         IF (    (nvl(FND_PROFILE.value('AMS_FULFILL_ENABLE_FLAG'), 'N') = 'Y')
             AND (nvl(p_block_fulfillment, FND_API.G_FALSE) <> FND_API.G_TRUE)
            )
         THEN
            AMS_CT_RULE_PVT.check_content_rule(  p_api_version          => 1.0 -- IN  NUMBER
                                               , p_init_msg_list        => FND_API.g_false -- IN  VARCHAR2  := FND_API.g_false
                                               , p_commit               => FND_API.g_false-- IN  VARCHAR2  := FND_API.g_false
                                               , p_object_type          => l_object_type -- IN  VARCHAR2
                                               , p_object_id            => l_object_id  -- l_evt_regs_rec.event_offer_id -- IN  NUMBER
                                               , p_trigger_type         => 'REG_CONFIRM' -- IN  VARCHAR2
            --                                 , p_requestor_type       => -- IN  VARCHAR2  := NULL
                                               -- Following line is modified by ptendulk on 12-Dec-2002
                                               , p_requestor_id         => get_user_id(l_evt_regs_rec.OWNER_USER_ID)
                                               --, p_requestor_id         => AMS_Utility_PVT.get_resource_id(l_evt_regs_rec.OWNER_USER_ID) -- IN  NUMBER
            --                                 , p_server_group         => -- IN  NUMBER := NULL
            --                                 , p_scheduled_date       => -- IN  DATE  := SYSDATE
            --                                 , p_media_types          => -- IN  VARCHAR2 := 'E'
            --                                 , p_archive              => -- IN  VARCHAR2 := 'N'
            --                                 , p_log_user_ih          => -- IN  VARCHAR2 := 'N'
            --                                 , p_request_type         => 'MASS_CUSTOM' -- IN  VARCHAR2 := 'TEST_EMAIL'
            --                                 , p_language_code        => -- IN  VARCHAR2 := NULL
            --                                 , p_profile_id           => -- IN  NUMBER   := NULL
            --                                 , p_order_id             => -- IN  NUMBER   := NULL
            --                                 , p_collateral_id        => -- IN  NUMBER   := NULL
                                               , p_party_id             => l_party_id -- IN  AMF_REQUEST.number_tbl_type
                                               , p_email                => l_email -- IN  AMF_REQUEST.string_tbl_type
                                               , p_fax                  => l_fax -- IN  AMF_REQUEST.string_tbl_type
                                               -- Following line is added by ptendulk on 12-Dec-2002
                                               , p_bind_names           => l_bind_names -- IN JTF_REQUEST_GRP.G_VARCHAR_TBL_TYPE
                                               , p_bind_values          => l_bind_values -- IN  AMF_REQUEST.string_tbl_type
                                               , x_return_status        => l_return_status -- OUT VARCHAR2
                                               , x_msg_count            => l_msg_count -- OUT NUMBER
                                               , x_msg_data             => l_msg_data -- OUT VARCHAR2
                                               , x_request_history_id   => l_request_history_id  -- OUT NUMBER
                                              );
            IF (AMS_DEBUG_HIGH_ON) THEN
                AMS_Utility_PVT.debug_message('Request ID: ' || l_request_history_id);
            END IF;

            IF l_return_status = FND_API.g_ret_sts_error THEN
               RAISE FND_API.g_exc_error;
            ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
               RAISE FND_API.g_exc_unexpected_error;
            END IF;

         END IF;
      END IF; -- ATTENDANCE FLAG
   END IF;


   -- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit )
   THEN
       COMMIT WORK;
   END IF; -- p_commit

   FND_MSG_PUB.count_and_get(  p_encoded => FND_API.g_false
                             , p_count   => x_msg_count
                             , p_data    => x_msg_data
                            );

   IF (AMS_DEBUG_HIGH_ON) THEN



       AMS_Utility_PVT.debug_message(l_full_name ||': end');

   END IF;


EXCEPTION

   WHEN FND_API.g_exc_error
   THEN
      ROLLBACK TO UPDATE_EvtRegs_PVT;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(  p_encoded => FND_API.g_false
                                , p_count   => x_msg_count
                                , p_data    => x_msg_data
                               );

   WHEN FND_API.g_exc_unexpected_error
   THEN
      ROLLBACK TO UPDATE_EvtRegs_PVT;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(  p_encoded => FND_API.g_false
                                , p_count   => x_msg_count
                                , p_data    => x_msg_data
                               );

   WHEN OTHERS
   THEN
      ROLLBACK TO UPDATE_EvtRegs_PVT;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
      THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF; -- check_msg_level
      FND_MSG_PUB.count_and_get(  p_encoded => FND_API.g_false
                                , p_count   => x_msg_count
                                , p_data    => x_msg_data
                               );

End Update_evtregs;

-- modified sugupta 06/21/2000
-- return cancellation code as Varchar2

PROCEDURE Cancel_evtregs(  P_Api_Version_Number        IN  NUMBER
                         , P_Init_Msg_List             IN  VARCHAR2  := FND_API.G_FALSE
                         , P_Commit                    IN  VARCHAR2  := FND_API.G_FALSE
                         , p_object_version            IN  NUMBER
                         , p_event_offer_id            IN  NUMBER
                         , p_registrant_party_id       IN  NUMBER
                         , p_confirmation_code         IN  VARCHAR2
                         , p_registration_group_id     IN  NUMBER
                         , p_cancellation_reason_code  IN  VARCHAR2
                         , p_block_fulfillment         IN  VARCHAR2  := FND_API.G_FALSE
                         , x_cancellation_code         OUT NOCOPY VARCHAR2
                         , X_Return_Status             OUT NOCOPY VARCHAR2
                         , X_Msg_Count                 OUT NOCOPY NUMBER
                         , X_Msg_Data                  OUT NOCOPY VARCHAR2
                        )

IS

   l_api_name                 CONSTANT VARCHAR2(30) := 'Cancel_evtregs';
   l_api_version_number       CONSTANT NUMBER       := 1.0;
   l_full_name                VARCHAR2(60)          := G_PKG_NAME || '.' || l_api_name;
   l_return_status            VARCHAR2(1);
   l_msg_count                NUMBER;
   l_msg_data                 VARCHAR2(2000);
   l_event_registration_id    NUMBER;
   l_event_offer_id           NUMBER                := p_event_offer_id;
   l_registrant_party_id      NUMBER                := p_registrant_party_id;
   l_confirmation_code        VARCHAR2(30)          := p_confirmation_code;
   l_registration_group_id    NUMBER                := p_registration_group_id;
   l_cancellation_id          NUMBER;
   l_cancellation_code        VARCHAR2(30);
   l_cancellation_reason_code VARCHAR2(30)          := p_cancellation_reason_code;
   l_reg_charge_flag          VARCHAR2(1);
   l_attended_flag            VARCHAR2(1);
   l_event_end_date           DATE;
   l_event_end_date_time      DATE;
   l_reg_end_date             DATE;
   l_reg_end_time             DATE;
   l_user_stat_id             NUMBER;
   l_event_status       VARCHAR2(30);
   l_event_status_name  VARCHAR2(120);

/* Following code is modified by ptendulk to move to 1:1 ffm
   l_email            AMF_REQUEST.string_tbl_type;
   l_fax              AMF_REQUEST.string_tbl_type;
   l_bind_values      AMF_REQUEST.string_tbl_type;
   l_party_id         AMF_REQUEST.number_tbl_type;
*/

   l_email            JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;
   l_fax              JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;
   l_party_id         JTF_FM_REQUEST_GRP.G_NUMBER_TBL_TYPE;
   l_bind_names       JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;
   l_bind_values      JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;

   l_object_type      VARCHAR2(30);
   l_request_history_id   NUMBER;

   l_owner_user_id   NUMBER;

   CURSOR c_get_object_type(p_event_offer_id IN NUMBER) IS
   SELECT event_object_type, parent_type
   from ams_event_offers_all_b
   where event_offer_id = p_event_offer_id;


   /* what to do with registrant_party_id...not validating coz transfer calls
   this procedure and they might not give the registrant party id..*/
   /* alternate cursor cancel_get_offer_details wud be not to use
   event_registration_id , and write update cancel reg where clause
   as in where clause of this cursor, instead of using event_registration_id
   */
   -- indeed i need not get offer_id as confirmation code should be enuf to get all information..

   l_csch_id          NUMBER;
   l_object_id        NUMBER;
   l_parent_type      VARCHAR2(10);

   CURSOR c_csch_id (obj_id NUMBER) IS
   SELECT schedule_id
     FROM ams_campaign_schedules_b
    WHERE related_event_id = obj_id;


   Cursor cancel_get_offer_details(  l_event_offer_id      NUMBER
                                   , l_confirmation_code   VARCHAR2
                                   , l_registrant_party_id NUMBER
                                  )
   is
   select
      reg.event_registration_id,
-- soagrawa 03-feb-2003 bug# 2777302, now getting owner user id from event
--      reg.owner_user_id,
      offers.owner_user_id,
      offers.system_status_code,
      usrsts.name,
      reg.attended_flag,
      offers.REG_CHARGE_FLAG,
      offers.EVENT_END_DATE,
      offers.EVENT_END_DATE_TIME,
      offers.REG_END_DATE,
      offers.REG_END_TIME
   from ams_event_offers_all_b offers, ams_event_registrations reg, ams_user_statuses_vl usrsts
   where offers.EVENT_OFFER_ID = l_event_offer_id
     and reg.EVENT_OFFER_ID = l_event_offer_id
     and reg.CONFIRMATION_CODE = l_confirmation_code
     and nvl(l_registrant_party_id, reg.REGISTRANT_PARTY_ID) = reg.REGISTRANT_PARTY_ID
     and offers.user_status_id = usrsts.user_status_id;

   Cursor cancel_reg_conf_details(  l_registration_group_id NUMBER
                                  , l_event_offer_id  NUMBER
                                 )
   is
   select
      REGISTRANT_PARTY_ID,
      CONFIRMATION_CODE
   from ams_event_registrations
   where EVENT_OFFER_ID = l_event_offer_id
     and REGISTRATION_GROUP_ID = l_registration_group_id;

   l_cancel_reg_conf_data cancel_reg_conf_details%ROWTYPE;

   CURSOR c_evtregs_cancel_seq IS
   select ams_event_reg_cancellation_s.nextval
   from dual;

   Cursor cur_user_stat_id is
   select USER_STATUS_ID
   from AMS_USER_STATUSES_VL
   where SYSTEM_STATUS_CODE = 'CANCELLED'
     and DEFAULT_FLAG = 'Y'
     and SYSTEM_STATUS_TYPE = 'AMS_EVENT_REG_STATUS';

BEGIN

   -- Standard Start of API savepoint
   SAVEPOINT Cancel_EvtRegs_PVT;
   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_Utility_PVT.debug_message(l_full_name || ': start');
   END IF;

   -- Standard call to check for call compatibility.
   IF (NOT FND_API.Compatible_API_Call(  l_api_version_number
                                       , p_api_version_number
                                       , l_api_name
                                       , G_PKG_NAME
                                      )
      )
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF; -- compatible API call

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF (FND_API.to_Boolean(p_init_msg_list))
   THEN
      FND_MSG_PUB.initialize;
   END IF; -- p_init_msg_list

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF (AMS_DEBUG_HIGH_ON) THEN
       AMS_Utility_PVT.debug_message(l_full_name || ': cancel');
   END IF;

   open cur_user_stat_id;
   FETCH cur_user_stat_id
   INTO l_user_stat_id;
   close cur_user_stat_id;

   open c_get_object_type(p_event_offer_id);
   fetch c_get_object_type
   into l_object_type, l_parent_type;
   close c_get_object_type;


   -- soagrawa 18-nov-2002 for bug# 2672928
   l_object_id := p_event_offer_id;

   IF l_object_type = 'EONE'
   THEN
      IF l_parent_type = 'CAMP'
      THEN

         OPEN  c_csch_id(l_object_id);
         FETCH c_csch_id INTO l_csch_id;
         CLOSE c_csch_id;

         l_object_type  :=  'CSCH';
         l_object_id    :=  l_csch_id;
      END IF;
   END IF;
   -- end soagrawa 18-nov-2002


   IF (l_event_offer_id is NULL)
   then
      IF (AMS_DEBUG_HIGH_ON) THEN

          AMS_UTILITY_PVT.debug_message(' Corresponding event offering information is not provided');
      END IF;
      AMS_Utility_PVT.error_message('AMS_EVT_REG_CANC_NO_EVOID');
      x_return_status := FND_API.g_ret_sts_error;
      RAISE FND_API.G_EXC_ERROR;
   ELSE
      IF l_registration_group_id is NULL
      THEN
         IF l_confirmation_code is NULL
         THEN
            IF (AMS_DEBUG_HIGH_ON) THEN

                AMS_UTILITY_PVT.debug_message(' Corresponding confirmation code for the event offering is not provided');
            END IF;
            AMS_Utility_PVT.error_message('AMS_EVT_REG_CANC_NO_CODE');
            x_return_status := FND_API.g_ret_sts_error;
            RAISE FND_API.G_EXC_ERROR;
         ELSE
            IF (AMS_DEBUG_HIGH_ON) THEN

                AMS_Utility_PVT.debug_message(l_full_name ||': before off det cursor');
            END IF;
            open cancel_get_offer_details(  l_event_offer_id
                                          , l_confirmation_code
                                          , l_registrant_party_id
                                         );
            fetch cancel_get_offer_details
            into
               l_event_registration_id,
               l_owner_user_id,
               l_event_status,
               l_event_status_name,
               l_attended_flag,
               l_reg_charge_flag,
               l_event_end_date,
               l_event_end_date_time,
               l_reg_end_date,
               l_reg_end_time;
            close cancel_get_offer_details;
            IF (AMS_DEBUG_HIGH_ON) THEN

                AMS_Utility_PVT.debug_message(l_full_name ||': after off det cursor');
            END IF;
            IF (nvl(l_event_status, 'X') in ('ARCHIVED', 'CLOSED'))
            THEN
               AMS_Utility_PVT.Error_Message('AMS_EVENT_REG_UPDATE_ERROR', 'STATUS', l_event_status_name);
               RAISE FND_API.g_exc_error;
            END IF;

            IF (l_reg_charge_flag = 'N')
            THEN
               IF l_cancellation_code IS NULL
               THEN
                  OPEN c_evtregs_cancel_seq;
                  FETCH c_evtregs_cancel_seq
                  INTO l_cancellation_id;
                  CLOSE c_evtregs_cancel_seq;
               END IF; -- l_cancellation_code
               l_cancellation_code := to_char(l_cancellation_id);

               UPDATE ams_event_registrations SET
                  system_status_code = 'CANCELLED',
                  USER_STATUS_ID = l_user_stat_id,
                  cancellation_code = l_cancellation_code,
                  cancellation_reason_code = l_cancellation_reason_code,
                  waitlisted_priority = null
                 -- added by dbiswas for NI issue on 19-mar-2003
                  , last_update_date = sysdate
                  , last_updated_by = FND_GLOBAL.USER_ID
                  , LAST_UPDATE_LOGIN = FND_GLOBAL.conc_login_id
                  -- added by dbiswas to carry fix for NI issue on 16-apr-2003
                  , last_reg_status_date = sysdate
               WHERE event_registration_id = l_event_registration_id
                 and object_version_number = p_object_version;

               IF (    (l_attended_flag = 'N')
                   AND (sysdate < (trunc(l_event_end_date) + 1))
                  )
               THEN
                     /*  Following changes are made by ptendulk on 13-Dec-2002 to implement 1:1
                     l_bind_values(0) := to_char(l_event_registration_id);
                     l_bind_values(1) := to_char(l_event_registration_id);  */

                     l_bind_names(1) := 'REGISTRATION_ID' ;
                     l_bind_values(1):= TO_CHAR(l_event_registration_id) ;

                     IF (    (nvl(FND_PROFILE.value('AMS_FULFILL_ENABLE_FLAG'), 'N') = 'Y')
                         AND (nvl(p_block_fulfillment, FND_API.G_FALSE) <> FND_API.G_TRUE)
                        )
                     THEN

                        AMS_CT_RULE_PVT.check_content_rule(  p_api_version          => 1.0 -- IN  NUMBER
                                                           , p_init_msg_list        => FND_API.g_false -- IN  VARCHAR2  := FND_API.g_false
                                                           , p_commit               => FND_API.g_false-- IN  VARCHAR2  := FND_API.g_false
                                                           , p_object_type          => l_object_type -- IN  VARCHAR2
                                                           , p_object_id            => l_object_id --p_event_offer_id -- IN  NUMBER
                                                           , p_trigger_type         => 'REG_CANCEL' -- IN  VARCHAR2
                        --                                 , p_requestor_type       => -- IN  VARCHAR2  := NULL
--                                                         , p_requestor_id         => l_owner_user_id   -- Change made by ptendulk on 12-Dec-2002
                                                           , p_requestor_id         => get_user_id(l_owner_user_id)
--                                                         , p_requestor_id         => AMS_Utility_PVT.get_resource_id(l_OWNER_USER_ID) -- IN  NUMBER
                        --                                 , p_server_group         => -- IN  NUMBER := NULL
                        --                                 , p_scheduled_date       => -- IN  DATE  := SYSDATE
                        --                                 , p_media_types          => -- IN  VARCHAR2 := 'E'
                        --                                 , p_archive              => -- IN  VARCHAR2 := 'N'
                        --                                 , p_log_user_ih          => -- IN  VARCHAR2 := 'N'
                        --                                 , p_request_type         => 'MASS_CUSTOM' -- IN  VARCHAR2 := 'TEST_EMAIL'
                        --                                 , p_language_code        => -- IN  VARCHAR2 := NULL
                        --                                 , p_profile_id           => -- IN  NUMBER   := NULL
                        --                                 , p_order_id             => -- IN  NUMBER   := NULL
                        --                                 , p_collateral_id        => -- IN  NUMBER   := NULL
                                                           , p_party_id             => l_party_id -- IN  AMF_REQUEST.number_tbl_type
                                                           , p_email                => l_email -- IN  AMF_REQUEST.string_tbl_type
                                                           , p_fax                  => l_fax -- IN  AMF_REQUEST.string_tbl_type
                                                           , p_bind_names           => l_bind_names  -- IN Added by ptendulk on 13-Dec-2002
                                                           , p_bind_values          => l_bind_values -- IN  AMF_REQUEST.string_tbl_type
                                                           , x_return_status        => l_return_status -- OUT VARCHAR2
                                                           , x_msg_count            => l_msg_count -- OUT NUMBER
                                                           , x_msg_data             => l_msg_data -- OUT VARCHAR2
                                                           , x_request_history_id   => l_request_history_id  -- OUT NUMBER
                                                          );
                        IF (AMS_DEBUG_HIGH_ON) THEN
                            AMS_Utility_PVT.debug_message('Request ID: ' || l_request_history_id);
                        END IF;

                        IF l_return_status = FND_API.g_ret_sts_error THEN
                           RAISE FND_API.g_exc_error;
                        ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                           RAISE FND_API.g_exc_unexpected_error;
                        END IF;

                     END IF;
               END IF; -- attended flag and sysdate
               x_cancellation_code := l_cancellation_code;
               -- call to prioritize_waillist upon cancellation
               prioritize_waitlist(  p_api_version_number => p_api_version_number
                                   , p_Init_Msg_List      => p_Init_Msg_List
                                   , p_commit             => p_commit
                                   , p_event_offer_id     => l_event_offer_id
                                   , X_Return_Status      => l_return_status
                                   , X_Msg_Count          => x_msg_count
                                   , X_Msg_Data           => x_msg_data
                                  );
               IF l_return_status = FND_API.g_ret_sts_unexp_error
               THEN
                  RAISE FND_API.g_exc_unexpected_error;
               ELSIF l_return_status = FND_API.g_ret_sts_error
               THEN
                  RAISE FND_API.g_exc_error;
               END IF; -- l_return_status

            ELSE
               IF (nvl(l_event_end_date, sysdate+1) < sysdate)
               then
                  IF (AMS_DEBUG_HIGH_ON) THEN

                      AMS_UTILITY_PVT.debug_message(' Cannot cancel a PAID event if cancellation date is later than Event end date.');
                  END IF;
               ELSE
                  IF (l_cancellation_code IS NULL)
                  THEN
                     OPEN c_evtregs_cancel_seq;
                     FETCH c_evtregs_cancel_seq
                     INTO l_cancellation_id;
                     CLOSE c_evtregs_cancel_seq;
                  END IF; -- l_cancellation_code
                  l_cancellation_code := to_char(l_cancellation_id);
                  UPDATE ams_event_registrations SET
                     system_status_code = 'CANCELLED',
                     USER_STATUS_ID = l_user_stat_id,
                     cancellation_code = l_cancellation_code,
                     cancellation_reason_code = l_cancellation_reason_code,
                     waitlisted_priority = null
                       -- added by dbiswas for NI issue on 19-mar-2003
                     , last_update_date = sysdate
                     , last_updated_by = FND_GLOBAL.USER_ID
                     , LAST_UPDATE_LOGIN = FND_GLOBAL.conc_login_id
                  -- added by dbiswas to carry fix for NI issue on 16-apr-2003
                  , last_reg_status_date = sysdate
                  WHERE event_registration_id = l_event_registration_id
                    and object_version_number = p_object_version;

                  IF (    (l_attended_flag = 'N')
                      AND (sysdate < (trunc(l_event_end_date) + 1))
                     )
                  THEN

                     /* Following code is modified by ptendulk on 12-Dec-2002 to move to 1:1
                     l_bind_values(0) := to_char(l_event_registration_id);
                     l_bind_values(1) := to_char(l_event_registration_id); */
                     l_bind_names(1)  := 'REGISTRATION_ID' ;
                     l_bind_values(1) := TO_CHAR(l_event_registration_id);

                     IF (    (nvl(FND_PROFILE.value('AMS_FULFILL_ENABLE_FLAG'), 'N') = 'Y')
                         AND (nvl(p_block_fulfillment, FND_API.G_FALSE) <> FND_API.G_TRUE)
                        )
                     THEN
                        AMS_CT_RULE_PVT.check_content_rule(  p_api_version          => 1.0 -- IN  NUMBER
                                                           , p_init_msg_list        => FND_API.g_false -- IN  VARCHAR2  := FND_API.g_false
                                                           , p_commit               => FND_API.g_false-- IN  VARCHAR2  := FND_API.g_false
                                                           , p_object_type          => l_object_type -- IN  VARCHAR2
                                                           , p_object_id            => l_object_id --p_event_offer_id -- IN  NUMBER
                                                           , p_trigger_type         => 'REG_CANCEL' -- IN  VARCHAR2
                        --                                 , p_requestor_type       => -- IN  VARCHAR2  := NULL
                                                           -- Following line is modified by ptendulk on 12-Dec-2002
--                                                           , p_requestor_id         => l_owner_user_id
                                                           , p_requestor_id         => get_user_id(l_owner_user_id)
                                                           --, p_requestor_id         => AMS_Utility_PVT.get_resource_id(l_owner_user_id) -- IN  NUMBER
                        --                                 , p_server_group         => -- IN  NUMBER := NULL
                        --                                 , p_scheduled_date       => -- IN  DATE  := SYSDATE
                        --                                 , p_media_types          => -- IN  VARCHAR2 := 'E'
                        --                                 , p_archive              => -- IN  VARCHAR2 := 'N'
                        --                                 , p_log_user_ih          => -- IN  VARCHAR2 := 'N'
                        --                                 , p_request_type         => 'MASS_CUSTOM' -- IN  VARCHAR2 := 'TEST_EMAIL'
                        --                                 , p_language_code        => -- IN  VARCHAR2 := NULL
                        --                                 , p_profile_id           => -- IN  NUMBER   := NULL
                        --                                 , p_order_id             => -- IN  NUMBER   := NULL
                        --                                 , p_collateral_id        => -- IN  NUMBER   := NULL
                                                           , p_party_id             => l_party_id -- IN  AMF_REQUEST.number_tbl_type
                                                           , p_email                => l_email -- IN  AMF_REQUEST.string_tbl_type
                                                           , p_fax                  => l_fax -- IN  AMF_REQUEST.string_tbl_type
                                                           -- Following line is added by ptendulk on 12-Dec-2002
                                                           , p_bind_names           => l_bind_names -- IN JTF_REQUEST_GRP.G_VARCHAR_TBL_TYPE
                                                           , p_bind_values          => l_bind_values -- IN  AMF_REQUEST.string_tbl_type
                                                           , x_return_status        => l_return_status -- OUT VARCHAR2
                                                           , x_msg_count            => l_msg_count -- OUT NUMBER
                                                           , x_msg_data             => l_msg_data -- OUT VARCHAR2
                                                           , x_request_history_id   => l_request_history_id  -- OUT NUMBER
                                                          );
                        IF (AMS_DEBUG_HIGH_ON) THEN
                            AMS_Utility_PVT.debug_message('Request ID: ' || l_request_history_id);
                        END IF;

                        IF l_return_status = FND_API.g_ret_sts_error THEN
                           RAISE FND_API.g_exc_error;
                        ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                           RAISE FND_API.g_exc_unexpected_error;
                        END IF;
                     END IF;
                  END IF;
                  x_cancellation_code := l_cancellation_code;
                  -- call to prioritize_waillist upon cancellation
                  prioritize_waitlist(  p_api_version_number => p_api_version_number
                                      , p_Init_Msg_List      => p_Init_Msg_List
                                      , p_commit             => p_commit
                                      , p_event_offer_id     => l_event_offer_id
                                      , X_Return_Status      => l_return_status
                                      , X_Msg_Count          => x_msg_count
                                      , X_Msg_Data           => x_msg_data
                                     );
                  IF l_return_status = FND_API.g_ret_sts_unexp_error
                  THEN
                     RAISE FND_API.g_exc_unexpected_error;
                  ELSIF l_return_status = FND_API.g_ret_sts_error
                  THEN
                     RAISE FND_API.g_exc_error;
                  END IF; -- l_return_status

               END IF; -- event end date < sysdate
            END IF; -- reg charge flag

         END IF; -- confirmation code null
      ELSE  /* registration group id is NOT NULL */
         FOR cancel_reg_conf_data in cancel_reg_conf_details(  l_registration_group_id
                                                             , l_event_offer_id
                                                            )
         LOOP
            -- might want to add another if loop to check if the reg system_status_code is already cancelled ....
            IF (AMS_DEBUG_HIGH_ON) THEN

                AMS_Utility_PVT.debug_message(l_full_name ||': gp id not null-before off det cursor');
            END IF;
	    -- sikalyan Fixed Bug 4185688 Updated the Conditional Check for a Registrant Group
            IF (    (cancel_reg_conf_data.confirmation_code IS NOT NULL)
                AND (cancel_reg_conf_data.registrant_party_id IS NOT NULL)
		AND (cancel_reg_conf_data.confirmation_code = l_confirmation_code)
		AND (cancel_reg_conf_data.registrant_party_id = l_registrant_party_id)
               )
            THEN
               open cancel_get_offer_details(  l_event_offer_id
                                             , cancel_reg_conf_data.confirmation_code
                                             , cancel_reg_conf_data.registrant_party_id
                                            );
               fetch cancel_get_offer_details
               into
                  l_event_registration_id,
                  l_owner_user_id,
                  l_event_status,
                  l_event_status_name,
                  l_attended_flag,
                  l_reg_charge_flag,
                  l_event_end_date,
                  l_event_end_date_time,
                  l_reg_end_date,
                  l_reg_end_time;
               close cancel_get_offer_details;
               IF (AMS_DEBUG_HIGH_ON) THEN

                   AMS_Utility_PVT.debug_message(l_full_name ||': gp id not null-after off det cursor');
               END IF;
               IF (nvl(l_event_status, 'X') in ('ARCHIVED', 'CLOSED'))
               THEN
                  AMS_Utility_PVT.Error_Message('AMS_EVENT_REG_UPDATE_ERROR', 'STATUS', l_event_status_name);
                  RAISE FND_API.g_exc_error;
               END IF;

               IF (l_reg_charge_flag = 'N')
               THEN
                  IF (l_cancellation_code IS NULL)
                  THEN
                     OPEN c_evtregs_cancel_seq;
                     FETCH c_evtregs_cancel_seq
                     INTO l_cancellation_id;
                     CLOSE c_evtregs_cancel_seq;
                  END IF; -- l_cancellation_code
                  l_cancellation_code := to_char(l_cancellation_id);

                  UPDATE ams_event_registrations SET
                     system_status_code = 'CANCELLED',
                     USER_STATUS_ID = l_user_stat_id,
                     cancellation_code = l_cancellation_code,
                     cancellation_reason_code = l_cancellation_reason_code,
                     waitlisted_priority = null
                     -- added by dbiswas for NI issue on 19-mar-2003
                     , last_update_date = sysdate
                     , last_updated_by = FND_GLOBAL.USER_ID
                     , LAST_UPDATE_LOGIN = FND_GLOBAL.conc_login_id
                  -- added by dbiswas to carry fix for NI issue on 16-apr-2003
                  , last_reg_status_date = sysdate
                  WHERE event_registration_id = l_event_registration_id
                    and object_version_number = p_object_version;

                  IF (    (l_attended_flag = 'N')
                      AND (sysdate < (trunc(l_event_end_date) + 1))
                     )
                  THEN

                     /* Following code is modified by ptendulk on 12-Dec-2002 to move to 1:1
                     l_bind_values(0) := to_char(l_event_registration_id);
                     l_bind_values(1) := to_char(l_event_registration_id); */
                     l_bind_names(1)  := 'REGISTRATION_ID' ;
                     l_bind_values(1) := TO_CHAR(l_event_registration_id);

                     IF (    (nvl(FND_PROFILE.value('AMS_FULFILL_ENABLE_FLAG'), 'N') = 'Y')
                         AND (nvl(p_block_fulfillment, FND_API.G_FALSE) <> FND_API.G_TRUE)
                        )
                     THEN
                        AMS_CT_RULE_PVT.check_content_rule(  p_api_version          => 1.0 -- IN  NUMBER
                                                           , p_init_msg_list        => FND_API.g_false -- IN  VARCHAR2  := FND_API.g_false
                                                           , p_commit               => FND_API.g_false-- IN  VARCHAR2  := FND_API.g_false
                                                           , p_object_type          => l_object_type -- IN  VARCHAR2
                                                           , p_object_id            => l_object_id --p_event_offer_id -- IN  NUMBER
                                                           , p_trigger_type         => 'REG_CANCEL' -- IN  VARCHAR2
                        --                                 , p_requestor_type       => -- IN  VARCHAR2  := NULL
                                                           -- Following line is modified by ptendulk on 12-Dec-2002
--                                                           , p_requestor_id         => l_owner_user_id
                                                           , p_requestor_id         => get_user_id(l_owner_user_id)
                                                           --, p_requestor_id         => AMS_Utility_PVT.get_resource_id(l_owner_user_id) -- IN  NUMBER
                        --                                 , p_server_group         => -- IN  NUMBER := NULL
                        --                                 , p_scheduled_date       => -- IN  DATE  := SYSDATE
                        --                                 , p_media_types          => -- IN  VARCHAR2 := 'E'
                        --                                 , p_archive              => -- IN  VARCHAR2 := 'N'
                        --                                 , p_log_user_ih          => -- IN  VARCHAR2 := 'N'
                        --                                 , p_request_type         => 'MASS_CUSTOM' -- IN  VARCHAR2 := 'TEST_EMAIL'
                        --                                 , p_language_code        => -- IN  VARCHAR2 := NULL
                        --                                 , p_profile_id           => -- IN  NUMBER   := NULL
                        --                                 , p_order_id             => -- IN  NUMBER   := NULL
                        --                                 , p_collateral_id        => -- IN  NUMBER   := NULL
                                                           , p_party_id             => l_party_id -- IN  AMF_REQUEST.number_tbl_type
                                                           , p_email                => l_email -- IN  AMF_REQUEST.string_tbl_type
                                                           , p_fax                  => l_fax -- IN  AMF_REQUEST.string_tbl_type
                                                           -- Following line is added by ptendulk on 12-Dec-2002
                                                           , p_bind_names           => l_bind_names -- IN JTF_REQUEST_GRP.G_VARCHAR_TBL_TYPE
                                                           , p_bind_values          => l_bind_values -- IN  AMF_REQUEST.string_tbl_type
                                                           , x_return_status        => l_return_status -- OUT VARCHAR2
                                                           , x_msg_count            => l_msg_count -- OUT NUMBER
                                                           , x_msg_data             => l_msg_data -- OUT VARCHAR2
                                                           , x_request_history_id   => l_request_history_id  -- OUT NUMBER
                                                          );
                        IF (AMS_DEBUG_HIGH_ON) THEN
                            AMS_Utility_PVT.debug_message('Request ID: ' || l_request_history_id);
                        END IF;

                        IF l_return_status = FND_API.g_ret_sts_error THEN
                           RAISE FND_API.g_exc_error;
                        ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                           RAISE FND_API.g_exc_unexpected_error;
                        END IF;
                     END IF;
                  END IF;
                  x_cancellation_code := l_cancellation_code;
                  -- call to prioritize_waitlist upon cancellation
                  prioritize_waitlist(  p_api_version_number => p_api_version_number
                                      , p_Init_Msg_List      => p_Init_Msg_List
                                      , p_commit             => p_commit
                                      , p_event_offer_id     => l_event_offer_id
                                      , X_Return_Status      => l_return_status
                                      , X_Msg_Count          => x_msg_count
                                      , X_Msg_Data           => x_msg_data
                                     );
                  IF l_return_status = FND_API.g_ret_sts_unexp_error
                  THEN
                     RAISE FND_API.g_exc_unexpected_error;
                  ELSIF l_return_status = FND_API.g_ret_sts_error
                  THEN
                     RAISE FND_API.g_exc_error;
                  END IF; -- l_return_status

               ELSE
                  IF (l_event_end_date < sysdate)
                  then
                     IF (AMS_DEBUG_HIGH_ON) THEN

                         AMS_UTILITY_PVT.debug_message('Cannot cancel a PAID event if cancellation date is later than Event end date.');
                     END IF;
                     IF (AMS_DEBUG_HIGH_ON) THEN

                         AMS_UTILITY_PVT.debug_message('AMS_EVT_REG_CANC_DATE');
                     END IF;
                     x_return_status := FND_API.g_ret_sts_error;
                     RAISE FND_API.G_EXC_ERROR;
                  ELSE
                     IF (l_cancellation_code IS NULL)
                     THEN
                        OPEN c_evtregs_cancel_seq;
                        FETCH c_evtregs_cancel_seq
                        INTO l_cancellation_id;
                        CLOSE c_evtregs_cancel_seq;
                     END IF; -- l_cancellation_code
                     l_cancellation_code := to_char(l_cancellation_id);

                     UPDATE ams_event_registrations SET
                        system_status_code = 'CANCELLED',
                        USER_STATUS_ID = l_user_stat_id,
                        cancellation_code = l_cancellation_code,
                        cancellation_reason_code = l_cancellation_reason_code,
                        waitlisted_priority = null
                        -- added by dbiswas for NI issue on 19-mar-2003
                        , last_update_date = sysdate
                        , last_updated_by = FND_GLOBAL.USER_ID
                        , LAST_UPDATE_LOGIN = FND_GLOBAL.conc_login_id
                  -- added by dbiswas to carry fix for NI issue on 16-apr-2003
                  , last_reg_status_date = sysdate
                     WHERE event_registration_id = l_event_registration_id
                       and object_version_number = p_object_version;

                     IF (    (l_attended_flag = 'N')
                         AND (sysdate < (trunc(l_event_end_date) + 1))
                        )
                     THEN

                        /* Following code is modified by ptendulk on 12-Dec-2002 to move to 1:1
                        l_bind_values(0) := to_char(l_event_registration_id);
                        l_bind_values(1) := to_char(l_event_registration_id); */
                        l_bind_names(1)  := 'REGISTRATION_ID' ;
                        l_bind_values(1) := TO_CHAR(l_event_registration_id);

                        IF (    (nvl(FND_PROFILE.value('AMS_FULFILL_ENABLE_FLAG'), 'N') = 'Y')
                            AND (nvl(p_block_fulfillment, FND_API.G_FALSE) <> FND_API.G_TRUE)
                           )
                        THEN
                           AMS_CT_RULE_PVT.check_content_rule(  p_api_version          => 1.0 -- IN  NUMBER
                                                              , p_init_msg_list        => FND_API.g_false -- IN  VARCHAR2  := FND_API.g_false
                                                              , p_commit               => FND_API.g_false-- IN  VARCHAR2  := FND_API.g_false
                                                           , p_object_type          => l_object_type -- IN  VARCHAR2
                                                           , p_object_id            => l_object_id --p_event_offer_id -- IN  NUMBER
                                                              , p_trigger_type         => 'REG_CANCEL' -- IN  VARCHAR2
                           --                                 , p_requestor_type       => -- IN  VARCHAR2  := NULL
                                                              -- Following line is modified by ptendulk on 12-Dec-2002
--                                                              , p_requestor_id         => l_owner_user_id
                                                              , p_requestor_id         => get_user_id(l_owner_user_id)
                                                              --, p_requestor_id         => AMS_Utility_PVT.get_resource_id(l_owner_user_id) -- IN  NUMBER
                           --                                 , p_server_group         => -- IN  NUMBER := NULL
                           --                                 , p_scheduled_date       => -- IN  DATE  := SYSDATE
                           --                                 , p_media_types          => -- IN  VARCHAR2 := 'E'
                           --                                 , p_archive              => -- IN  VARCHAR2 := 'N'
                           --                                 , p_log_user_ih          => -- IN  VARCHAR2 := 'N'
                           --                                 , p_request_type         => 'MASS_CUSTOM' -- IN  VARCHAR2 := 'TEST_EMAIL'
                           --                                 , p_language_code        => -- IN  VARCHAR2 := NULL
                           --                                 , p_profile_id           => -- IN  NUMBER   := NULL
                           --                                 , p_order_id             => -- IN  NUMBER   := NULL
                           --                                 , p_collateral_id        => -- IN  NUMBER   := NULL
                                                              , p_party_id             => l_party_id -- IN  AMF_REQUEST.number_tbl_type
                                                              , p_email                => l_email -- IN  AMF_REQUEST.string_tbl_type
                                                              , p_fax                  => l_fax -- IN  AMF_REQUEST.string_tbl_type
                                                              -- Following line is added by ptendulk on 12-Dec-2002
                                                              , p_bind_names           => l_bind_names -- IN JTF_REQUEST_GRP.G_VARCHAR_TBL_TYPE
                                                              , p_bind_values          => l_bind_values -- IN  AMF_REQUEST.string_tbl_type
                                                              , x_return_status        => l_return_status -- OUT VARCHAR2
                                                              , x_msg_count            => l_msg_count -- OUT NUMBER
                                                              , x_msg_data             => l_msg_data -- OUT VARCHAR2
                                                              , x_request_history_id   => l_request_history_id  -- OUT NUMBER
                                                             );
                           IF (AMS_DEBUG_HIGH_ON) THEN
                               AMS_Utility_PVT.debug_message('Request ID: ' || l_request_history_id);
                           END IF;

                           IF l_return_status = FND_API.g_ret_sts_error THEN
                              RAISE FND_API.g_exc_error;
                           ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                              RAISE FND_API.g_exc_unexpected_error;
                           END IF;
                        END IF;
                     END IF;
                     x_cancellation_code := l_cancellation_code;
                     -- call to prioritize_waitlist upon cancellation
                     prioritize_waitlist(  p_api_version_number => p_api_version_number
                                         , p_Init_Msg_List      => p_Init_Msg_List
                                         , p_commit             => p_commit
                                         , p_event_offer_id     => l_event_offer_id
                                         , X_Return_Status      => l_return_status
                                         , X_Msg_Count          => x_msg_count
                                         , X_Msg_Data           => x_msg_data
                                        );
                     IF l_return_status = FND_API.g_ret_sts_unexp_error
                     THEN
                        RAISE FND_API.g_exc_unexpected_error;
                     ELSIF l_return_status = FND_API.g_ret_sts_error
                     THEN
                        RAISE FND_API.g_exc_error;
                     END IF; -- l_return_status
                  END IF; -- event end date
               END IF; -- reg charge flag
            END IF; -- CONF CODE NOT NULL
         END LOOP; -- for cancel_reg_conf_data
      END IF; -- registration group id null
   END IF; -- event offer id

   -- Standard check for p_commit
   IF (FND_API.to_Boolean(p_commit))
   THEN
      COMMIT WORK;
   END IF; -- p_commit

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.count_and_get(  p_encoded => FND_API.g_false
                             , p_count   => x_msg_count
                             , p_data    => x_msg_data
                            );

   IF (AMS_DEBUG_HIGH_ON) THEN



       AMS_Utility_PVT.debug_message(l_full_name ||': end');

   END IF;

EXCEPTION

   WHEN FND_API.g_exc_error
   THEN
      ROLLBACK TO Cancel_EvtRegs_PVT;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(  p_encoded => FND_API.g_false
                                , p_count   => x_msg_count
                                , p_data    => x_msg_data
                               );

   WHEN FND_API.g_exc_unexpected_error
   THEN
      ROLLBACK TO Cancel_EvtRegs_PVT;
      x_return_status := FND_API.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get(  p_encoded => FND_API.g_false
                                , p_count   => x_msg_count
                                , p_data    => x_msg_data
                               );

   WHEN OTHERS
   THEN
      ROLLBACK TO Cancel_EvtRegs_PVT;
      x_return_status := FND_API.g_ret_sts_unexp_error;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
      THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF; -- check_msg_level
      FND_MSG_PUB.count_and_get(  p_encoded => FND_API.g_false
                                , p_count   => x_msg_count
                                , p_data    => x_msg_data
                               );

End Cancel_evtregs;

PROCEDURE lock_evtregs(  p_api_version_Number     IN  NUMBER
                       , p_init_msg_list          IN  VARCHAR2 := FND_API.g_false
                       , p_validation_level       IN  NUMBER   := FND_API.g_valid_level_full
                       , x_return_status          OUT NOCOPY VARCHAR2
                       , x_msg_count              OUT NOCOPY NUMBER
                       , x_msg_data               OUT NOCOPY VARCHAR2
                       , p_event_registration_id  IN  NUMBER
                       , p_object_version         IN  NUMBER
                      )

IS

   l_api_name           CONSTANT VARCHAR2(30) := 'lock_evtregs';
   l_api_version_number CONSTANT NUMBER       := 1.0;
   l_full_name          CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_reg_id             NUMBER                := p_event_registration_id;

   CURSOR c_reg_b IS
   SELECT event_registration_id
   FROM ams_event_registrations
   WHERE event_registration_id = l_reg_id
     AND object_version_number = p_object_version
   FOR UPDATE OF event_registration_id NOWAIT;

BEGIN

   -------------------- initialize ------------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   IF FND_API.to_boolean(p_init_msg_list)
   THEN
      FND_MSG_PUB.initialize;
   END IF; -- p_init_msg_list

   IF (NOT FND_API.compatible_api_call(  l_api_version_number
                                       , p_api_version_number
                                       , l_api_name
                                       , g_pkg_name
                                      )
      )
   THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF; -- compatible API call

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   ------------------------ lock -------------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_Utility_PVT.debug_message(l_full_name||': lock');
   END IF;

   OPEN c_reg_b;
   FETCH c_reg_b
   INTO l_reg_id;
   IF (c_reg_b%NOTFOUND)
   THEN
      CLOSE c_reg_b;
      AMS_Utility_PVT.error_message('AMS_API_RECORD_NOT_FOUND');
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_reg_b;

   -------------------- finish --------------------------
   FND_MSG_PUB.count_and_get(  p_encoded => FND_API.g_false
                             , p_count   => x_msg_count
                             , p_data    => x_msg_data
                            );

   IF (AMS_DEBUG_HIGH_ON) THEN



       AMS_Utility_PVT.debug_message(l_full_name ||': end');

   END IF;

EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked
   THEN
      x_return_status := FND_API.g_ret_sts_error;
      AMS_Utility_PVT.error_message('AMS_API_RESOURCE_LOCKED');
      FND_MSG_PUB.count_and_get(  p_encoded => FND_API.g_false
                                , p_count   => x_msg_count
                                , p_data    => x_msg_data
                               );

   WHEN FND_API.g_exc_error
   THEN
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(  p_encoded => FND_API.g_false
                                , p_count   => x_msg_count
                                , p_data    => x_msg_data
                               );

   WHEN FND_API.g_exc_unexpected_error
   THEN
      x_return_status := FND_API.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get(  p_encoded => FND_API.g_false
                                , p_count   => x_msg_count
                                , p_data    => x_msg_data
                               );

   WHEN OTHERS
   THEN
      x_return_status := FND_API.g_ret_sts_unexp_error;
      IF (FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error))
      THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF; -- check_msg_Level
      FND_MSG_PUB.count_and_get(  p_encoded => FND_API.g_false
                                , p_count   => x_msg_count
                                , p_data    => x_msg_data
                               );

END lock_evtregs;

PROCEDURE delete_evtRegs(  p_api_version_number     IN  NUMBER
                         , p_init_msg_list          IN  VARCHAR2 := FND_API.g_false
                         , p_commit                 IN  VARCHAR2 := FND_API.g_false
                         , p_object_version         IN  NUMBER
                         , p_event_registration_id  IN  NUMBER
                         , x_return_status          OUT NOCOPY VARCHAR2
                         , x_msg_count              OUT NOCOPY NUMBER
                         , x_msg_data               OUT NOCOPY VARCHAR2
                        )

IS

   l_api_version_number CONSTANT NUMBER       := 1.0;
   l_api_name           CONSTANT VARCHAR2(30) := 'delete_evtRegs';
   l_full_name          CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

BEGIN

   --------------------- initialize -----------------------
   SAVEPOINT delete_evtRegs;
   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   IF FND_API.to_boolean(p_init_msg_list)
   THEN
      FND_MSG_PUB.initialize;
   END IF; -- p_init_msg_list

   IF (NOT FND_API.compatible_api_call(  l_api_version_number
                                       , p_api_version_number
                                       , l_api_name
                                       , g_pkg_name
                                      )
      )
   THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF; -- compatible API call

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   ------------------------ delete ------------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_Utility_PVT.debug_message(l_full_name ||': delete');
   END IF;

   UPDATE ams_event_registrations
   SET active_flag = 'N'
   WHERE event_registration_id = p_event_registration_id
     AND object_version_number = p_object_version;

   IF (SQL%NOTFOUND)
   THEN
      AMS_Utility_PVT.error_message('AMS_API_RECORD_NOT_FOUND');
      RAISE FND_API.g_exc_error;
   END IF; -- SQL%NOTFOUND

   -------------------- finish --------------------------
   IF (FND_API.to_boolean(p_commit))
   THEN
      COMMIT;
   END IF; -- p_commit

   FND_MSG_PUB.count_and_get(  p_encoded => FND_API.g_false
                             , p_count   => x_msg_count
                             , p_data    => x_msg_data
                            );

   IF (AMS_DEBUG_HIGH_ON) THEN



       AMS_Utility_PVT.debug_message(l_full_name ||': end');

   END IF;

EXCEPTION

   WHEN FND_API.g_exc_error
   THEN
      ROLLBACK TO delete_evtRegs;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(  p_encoded => FND_API.g_false
                                , p_count   => x_msg_count
                                , p_data    => x_msg_data
                               );

   WHEN FND_API.g_exc_unexpected_error
   THEN
      ROLLBACK TO delete_evtRegs;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(  p_encoded => FND_API.g_false
                                , p_count   => x_msg_count
                                , p_data    => x_msg_data
                               );

   WHEN OTHERS
   THEN
      ROLLBACK TO delete_evtRegs;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      IF (FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error))
      THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF; -- check_msg_level
      FND_MSG_PUB.count_and_get(  p_encoded => FND_API.g_false
                                , p_count   => x_msg_count
                                , p_data    => x_msg_data
                               );

END delete_evtRegs;

PROCEDURE prioritize_waitlist(  p_api_version_number     IN  NUMBER
                              , p_Init_Msg_List          IN  VARCHAR2  := FND_API.G_FALSE
                              , P_Commit                 IN  VARCHAR2  := FND_API.G_FALSE
                              , p_override_availability  IN  VARCHAR2  := FND_API.G_FALSE
                              , p_event_offer_id         IN  NUMBER
                              , x_return_status          OUT NOCOPY VARCHAR2
                              , x_msg_count              OUT NOCOPY NUMBER
                              , x_msg_data               OUT NOCOPY VARCHAR2
                             )

IS

   l_api_name                   CONSTANT VARCHAR2(30) := 'prioritize_waitlist';
   l_api_version_number         CONSTANT NUMBER       := 1.0;
   l_full_name                  CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_return_status              VARCHAR2(1);
   l_msg_count                NUMBER;
   l_msg_data                 VARCHAR2(2000);
   l_e_auto_register_flag       VARCHAR2(1);
   --l_r_auto_register_flag       VARCHAR2(1);
   l_min_wait_reg_id            NUMBER;
   l_reg_frozen_flag            VARCHAR2(1);
   l_effective_capacity         NUMBER;
   l_event_offer_name           VARCHAR2(240);
   l_owner_user_id              NUMBER;
   l_task_id                    NUMBER;
   l_task_assignment_id         NUMBER;
   l_sales_rep_id               NUMBER;
   l_order_hdr_id               NUMBER;
   l_order_line_id              NUMBER;
   l_waitlist_action_type_code  VARCHAR2(30);

/* Following code is modified by ptendulk to move to 1:1 ffm
   l_email            AMF_REQUEST.string_tbl_type;
   l_fax              AMF_REQUEST.string_tbl_type;
   l_bind_values      AMF_REQUEST.string_tbl_type;
   l_party_id         AMF_REQUEST.number_tbl_type;
*/

   l_email            JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;
   l_fax              JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;
   l_party_id         JTF_FM_REQUEST_GRP.G_NUMBER_TBL_TYPE;
   l_bind_names       JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;
   l_bind_values      JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;

   l_object_type      VARCHAR2(30);
   l_request_history_id   NUMBER;

   Cursor prioritize_get_offer_details(p_event_offer_id NUMBER) is
   select
      b.AUTO_REGISTER_FLAG,
      b.REG_FROZEN_FLAG,
      b.REG_EFFECTIVE_CAPACITY,
      b.OWNER_USER_ID,
      b.event_object_type,
      t.EVENT_OFFER_NAME,
      b.waitlist_action_type_code,
      b.parent_type
   from
      ams_event_offers_all_b b,
      AMS_EVENT_OFFERS_ALL_TL t
   where b.event_offer_id = p_event_offer_id
     and t.event_offer_id = p_event_offer_id;

   Cursor c_prioritize_waiting_minnum(p_event_offer_id NUMBER) is
   select
      event_registration_id,
      --auto_register_flag,
      SALESREP_ID,
      ORDER_HEADER_ID,
      ORDER_LINE_ID
   from ams_event_registrations
   where event_offer_id = p_event_offer_id
     and system_status_code = 'WAITLISTED'
     and waitlisted_priority = (select min(waitlisted_priority)
                                from ams_event_registrations
                                where event_offer_id = p_event_offer_id
                                  and system_status_code = 'WAITLISTED'
                               );

   -- soagrawa 18-nov-2002 for bug# 2672928
   l_csch_id          NUMBER;
   l_object_id        NUMBER;
   l_parent_type      VARCHAR2(10);

   CURSOR c_csch_id (obj_id NUMBER) IS
   SELECT schedule_id
     FROM ams_campaign_schedules_b
    WHERE related_event_id = obj_id;


BEGIN

   ----------------------- initialize --------------------
   SAVEPOINT prioritize_waitlist;
   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   IF FND_API.to_boolean(p_init_msg_list)
   THEN
      FND_MSG_PUB.initialize;
   END IF; -- p_init_msg_list

   IF (NOT FND_API.compatible_api_call(  l_api_version_number
                                       , p_api_version_number
                                       , l_api_name
                                       , g_pkg_name
                                      )
      )
   THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF; -- compatible API call

   -- Initialize API return status to SUCCESS
   l_return_status := FND_API.G_RET_STS_SUCCESS;

   -- validate not null values passed for required parameters...
   IF (p_event_offer_id IS NULL)
   THEN
      AMS_Utility_PVT.error_message('AMS_EVT_REG_PR_NULL_PARAM');
      l_return_status := FND_API.g_ret_sts_error;
   END IF; -- p_event_offer_id

   /* check Offer id's fk .....*/
   IF (AMS_Utility_PVT.check_fk_exists(  'ams_event_offers_all_b'
                                       , 'event_offer_id'
                                       , p_event_offer_id
                                      ) = FND_API.g_false
      )
   THEN
      AMS_Utility_PVT.error_message('AMS_EVT_REG_PR_BAD_EVOID');
      l_return_status := FND_API.g_ret_sts_error;
      -- RAISE FND_API.g_exc_error;
   END IF; -- check_fk_exists

   ------------------api logic-----------------------
   -- Get the offering details of offer id
   open prioritize_get_offer_details(p_event_offer_id);
   fetch prioritize_get_offer_details
   into
      l_e_auto_register_flag,
      l_reg_frozen_flag,
      l_effective_capacity,
      l_owner_user_id,
      l_object_type,
      l_event_offer_name,
      l_waitlist_action_type_code,
      l_parent_type;
   close prioritize_get_offer_details;

   -- soagrawa 18-nov-2002 for bug# 2672928
   l_object_id := p_event_offer_id;

   IF l_object_type = 'EONE'
   THEN
      IF l_parent_type = 'CAMP'
      THEN

         OPEN  c_csch_id(l_object_id);
         FETCH c_csch_id INTO l_csch_id;
         CLOSE c_csch_id;

         l_object_type  :=  'CSCH';
         l_object_id    :=  l_csch_id;
      END IF;
   END IF;
   -- end soagrawa 18-nov-2002


   IF (l_reg_frozen_flag = 'Y')
   THEN
      IF (AMS_DEBUG_HIGH_ON) THEN

          AMS_UTILITY_PVT.debug_message('Registrations for the event offering are frozen- Cannot prioritize your wait');
      END IF;
      -- AMS_Utility_PVT.error_message('AMS_EVT_REG_PRI_FROZEN');
      -- RAISE FND_API.G_EXC_ERROR;
      RETURN;
   END IF; -- l_reg_frozen_flag

   if (   (p_override_availability = FND_API.G_FALSE)
       AND
          (check_reg_availability(  l_effective_capacity
                                  , p_event_offer_id
                                 ) <= 0
          )
      )
   THEN
      IF (AMS_DEBUG_HIGH_ON) THEN

          AMS_UTILITY_PVT.debug_message('No Waitlist Available');
      END IF;
      -- AMS_Utility_PVT.error_message('AMS_EVT_REG_NO_WAIT_ALLOWED');
      -- RAISE FND_API.G_EXC_ERROR;
      RETURN;
   END IF;

   OPEN c_prioritize_waiting_minnum(p_event_offer_id);
   FETCH c_prioritize_waiting_minnum
   into
      l_min_wait_reg_id,
      --l_r_auto_register_flag,
      l_sales_rep_id,
      l_order_hdr_id,
      l_order_line_id;
   CLOSE c_prioritize_waiting_minnum;
   IF (l_min_wait_reg_id IS NOT NULL)
   THEN
      IF (    (nvl(l_e_auto_register_flag,'N') = 'Y')
          --AND (l_r_auto_register_flag = 'N')
         )
      THEN
         /*
         -- create task for notification
         AMS_TASK_PVT.Create_task(  p_api_version             =>  l_api_version_number
                                  , p_init_msg_list           =>  FND_API.g_false
                                  , p_commit                  =>  FND_API.g_false
                                  , p_task_id                 =>  NULL
                                  , p_task_name               => 'wait list registration task for - '||l_event_offer_name
                                  , p_task_type_id            =>  15  -- from jtf_task_types_vl
                                  , p_task_status_id          =>  13  -- in jtf_task_statuses_vl, 13
                                  , p_task_priority_id        =>  NULL
                                  , p_owner_id                =>  l_owner_user_id
                                  , p_owner_type_code         =>  'RS_EMPLOYEE'
                                  , p_private_flag            =>  'N'
                                  , p_planned_start_date      =>  NULL
                                  , p_planned_end_date        =>  NULL
                                  , p_actual_start_date       =>  NULL
                                  , p_actual_end_date         =>  NULL
                                  , p_source_object_type_code =>  'AMS_EVEO'
                                  , p_source_object_id        =>  p_event_offer_id
                                  , x_return_status           =>  l_return_status
                                  , x_msg_count               =>  x_msg_count
                                  , x_msg_data                =>  x_msg_data
                                  , x_task_id                 =>  l_task_id
                                 );
         IF (l_return_status = FND_API.g_ret_sts_error)
         THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
            THEN
               FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
            END IF; -- check_msg_level
            FND_MSG_PUB.count_and_get(  p_encoded => FND_API.g_false
                                      , p_count   => x_msg_count
                                      , p_data    => x_msg_data
                                     );
            RAISE FND_API.g_exc_error;
         ELSIF (l_return_status = FND_API.g_ret_sts_unexp_error)
         THEN
            IF (FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error))
            THEN
               FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
            END IF; -- check_msg_level
            FND_MSG_PUB.count_and_get(  p_encoded => FND_API.g_false
                                      , p_count   => x_msg_count
                                      , p_data    => x_msg_data
                                     );
            RAISE FND_API.g_exc_unexpected_error;
         END IF; -- l_return_status
         -- create task assignment
         IF (AMS_DEBUG_HIGH_ON) THEN

             AMS_Utility_PVT.debug_message('calling AMS_TASK_PVT.Create_Task_Assignment');
         END IF;
         AMS_TASK_PVT.Create_Task_Assignment(  p_api_version           =>  l_api_version_number
                                             , p_init_msg_list         =>  FND_API.g_false
                                             , p_commit                =>  FND_API.g_false
                                             , p_task_id               =>  l_task_id
                                             , p_resource_type_code    =>  'RS_EMPLOYEE'
                                             , p_resource_id           =>  l_sales_rep_id
                                             , p_assignment_status_id  =>  1
                                             , x_return_status         =>  l_return_status
                                             , x_msg_count             =>  x_msg_count
                                             , x_msg_data              =>  x_msg_data
                                             , x_task_assignment_id    =>  l_task_assignment_id
                                            );
         IF (l_return_status = FND_API.g_ret_sts_error)
         THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
            THEN
               FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
            END IF; -- check_msg_level
            FND_MSG_PUB.count_and_get(  p_encoded => FND_API.g_false
                                      , p_count   => x_msg_count
                                      , p_data    => x_msg_data
                                     );
            RAISE FND_API.g_exc_error;
         ELSIF (l_return_status = FND_API.g_ret_sts_unexp_error)
         THEN
            IF (FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error))
            THEN
               FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
            END IF; -- check_msg_level
            FND_MSG_PUB.count_and_get(  p_encoded => FND_API.g_false
                                      , p_count   => x_msg_count
                                      , p_data    => x_msg_data
                                     );
            RAISE FND_API.g_exc_unexpected_error;
         END IF; -- l_return_status
      ELSE -- l_e_auto_register_flag
         */
         update ams_event_registrations set
            system_status_code = 'REGISTERED',
            waitlisted_priority = null,
            user_status_id = (select user_status_id
                              from ams_user_statuses_vl
                              where system_status_type = 'AMS_EVENT_REG_STATUS'
                                and system_status_code = 'REGISTERED'
                                and default_flag = 'Y'
                             )
         where event_registration_id = l_min_wait_reg_id;

         /* Following code is modified by ptendulk on 12-Dec-2002 to move to 1:1
         l_bind_values(0) := to_char(l_min_wait_reg_id);
         l_bind_values(1) := to_char(l_min_wait_reg_id); */
         l_bind_names(1)  := 'REGISTRATION_ID' ;
         l_bind_values(1) := TO_CHAR(l_min_wait_reg_id);


         IF (nvl(FND_PROFILE.value('AMS_FULFILL_ENABLE_FLAG'), 'N') = 'Y')
         THEN
            AMS_CT_RULE_PVT.check_content_rule(  p_api_version          => 1.0 -- IN  NUMBER
                                               , p_init_msg_list        => FND_API.g_false -- IN  VARCHAR2  := FND_API.g_false
                                               , p_commit               => FND_API.g_false-- IN  VARCHAR2  := FND_API.g_false
                                               , p_object_type          => l_object_type -- IN  VARCHAR2
                                               , p_object_id            => l_object_id --p_event_offer_id -- IN  NUMBER
                                               , p_trigger_type         => 'REG_CONFIRM' -- IN  VARCHAR2
            --                                 , p_requestor_type       => -- IN  VARCHAR2  := NULL
                                               -- Following line is modified by ptendulk on 12-Dec-2002
--                                               , p_requestor_id         => l_owner_user_id
                                               , p_requestor_id         => get_user_id(l_owner_user_id)
                                               --, p_requestor_id         => AMS_Utility_PVT.get_resource_id(l_owner_user_id) -- IN  NUMBER
            --                                 , p_server_group         => -- IN  NUMBER := NULL
            --                                 , p_scheduled_date       => -- IN  DATE  := SYSDATE
            --                                 , p_media_types          => -- IN  VARCHAR2 := 'E'
            --                                 , p_archive              => -- IN  VARCHAR2 := 'N'
            --                                 , p_log_user_ih          => -- IN  VARCHAR2 := 'N'
            --                                 , p_request_type         => 'MASS_CUSTOM' -- IN  VARCHAR2 := 'TEST_EMAIL'
            --                                 , p_language_code        => -- IN  VARCHAR2 := NULL
            --                                 , p_profile_id           => -- IN  NUMBER   := NULL
            --                                 , p_order_id             => -- IN  NUMBER   := NULL
            --                                 , p_collateral_id        => -- IN  NUMBER   := NULL
                                               , p_party_id             => l_party_id -- IN  AMF_REQUEST.number_tbl_type
                                               , p_email                => l_email -- IN  AMF_REQUEST.string_tbl_type
                                               , p_fax                  => l_fax -- IN  AMF_REQUEST.string_tbl_type
                                               -- Following line is added by ptendulk on 12-Dec-2002
                                               , p_bind_names           => l_bind_names -- IN JTF_REQUEST_GRP.G_VARCHAR_TBL_TYPE
                                               , p_bind_values          => l_bind_values -- IN  AMF_REQUEST.string_tbl_type
                                               , x_return_status        => l_return_status -- OUT VARCHAR2
                                               , x_msg_count            => l_msg_count -- OUT NUMBER
                                               , x_msg_data             => l_msg_data -- OUT VARCHAR2
                                               , x_request_history_id   => l_request_history_id  -- OUT NUMBER
                                              );
            IF (AMS_DEBUG_HIGH_ON) THEN
                AMS_Utility_PVT.debug_message('Request ID: ' || l_request_history_id);
            END IF;

            IF l_return_status = FND_API.g_ret_sts_error THEN
               RAISE FND_API.g_exc_error;
            ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
               RAISE FND_API.g_exc_unexpected_error;
            END IF;

         END IF;

         IF (AMS_DEBUG_HIGH_ON) THEN



             AMS_Utility_Pvt.Debug_Message('Registered id ' || l_min_wait_reg_id);

         END IF;
      END IF; -- l_e_auto_register_flag
   END IF; -- l_min_wait_reg_id

   -------------FINISH-----------------------------

   x_return_status := l_return_status;

   -- Standard check for p_commit
   IF (FND_API.to_Boolean(p_commit))
   THEN
       COMMIT WORK;
   END IF; -- p_commit

   FND_MSG_PUB.count_and_get(  p_encoded => FND_API.g_false
                             , p_count   => x_msg_count
                             , p_data    => x_msg_data
                            );

   IF (AMS_DEBUG_HIGH_ON) THEN



       AMS_Utility_PVT.debug_message(l_full_name ||': end');

   END IF;

EXCEPTION

   WHEN FND_API.g_exc_error
   THEN
      ROLLBACK TO prioritize_waitlist;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(  p_encoded => FND_API.g_false
                                , p_count   => x_msg_count
                                , p_data    => x_msg_data
                               );

   WHEN FND_API.g_exc_unexpected_error
   THEN
      ROLLBACK TO prioritize_waitlist;
      x_return_status := FND_API.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get(  p_encoded => FND_API.g_false
                                , p_count   => x_msg_count
                                , p_data    => x_msg_data
                               );

   WHEN OTHERS
   THEN
      ROLLBACK TO prioritize_waitlist;
      x_return_status := FND_API.g_ret_sts_unexp_error;
      IF (FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error))
      THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF; -- check_msg_level
      FND_MSG_PUB.count_and_get(  p_encoded => FND_API.g_false
                                , p_count   => x_msg_count
                                , p_data    => x_msg_data
                               );


END prioritize_waitlist;

-------------------------------------------------------
-- Start of Comments
--
-- PROCEDURE
--  substitute_and_validate
--
-- HISTORY
--    11/16/99  sugupta  Added.
-- PURPOSE
--    called by substitute_enrollee in PUB API..
--    Substitute an enrollee(attendant) for an existing event registration..
--    Who can substitute is NOT verified in this API call...
--    If registrant information is also provided, then the existing
--    'registrant information' is replaced...
--    'Attendant information' is mandatory, but for account information...
--    if registrant info is changed, reg_contact id is stored in original_reg_contact_id column..
-------------------------------------------------------------
PROCEDURE substitute_and_validate(  P_Api_Version_Number     IN  NUMBER
                                  , P_Init_Msg_List          IN  VARCHAR2  := FND_API.G_FALSE
                                  , P_Commit                 IN  VARCHAR2  := FND_API.G_FALSE
                                  , p_confirmation_code      IN  VARCHAR2
                                  , p_attendant_party_id     IN  NUMBER
                                  , p_attendant_contact_id   IN  NUMBER
                                  , p_attendant_account_id   IN  NUMBER
                                  , p_registrant_party_id    IN  NUMBER
                                  , p_registrant_contact_id  IN  NUMBER
                                  , p_registrant_account_id  IN  NUMBER
                                  , X_Return_Status          OUT NOCOPY VARCHAR2
                                  , X_Msg_Count              OUT NOCOPY NUMBER
                                  , X_Msg_Data               OUT NOCOPY VARCHAR2
                                 )

IS

   l_api_name           CONSTANT VARCHAR2(30) := 'substitute_and_validate';
   l_api_version_number CONSTANT NUMBER       := 1.0;
   l_confirmation_code  VARCHAR2(30)          := p_confirmation_code;
   l_full_name          VARCHAR2(60)          := G_PKG_NAME || '.' || l_api_name;
   l_return_status      VARCHAR2(1);

BEGIN

   -- Standard Start of API savepoint
   SAVEPOINT substitute_validate_PVT;
   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_Utility_PVT.debug_message(l_full_name || ': start');
   END IF;

   IF FND_API.to_boolean(p_init_msg_list)
   THEN
      FND_MSG_PUB.initialize;
   END IF; -- p_init_msg_list

   IF (NOT FND_API.compatible_api_call(  l_api_version_number
                                       , p_api_version_number
                                       , l_api_name
                                       , g_pkg_name
                                      )
      )
   THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF; -- compatible API call

   -- Initialize API return status to SUCCESS
   l_return_status := FND_API.G_RET_STS_SUCCESS;

   -- validate not null values passed for required parameters...
   IF (   (p_confirmation_code IS NULL)
       OR (p_attendant_party_id IS NULL)
       OR (p_attendant_contact_id IS NULL)
       OR (p_registrant_contact_id IS NULL)
      )
   THEN
      AMS_Utility_PVT.error_message('AMS_EVT_REG_SUBST_NULL_PARAM');
      x_return_status := FND_API.g_ret_sts_error;
      RAISE FND_API.g_exc_error;
   END IF; -- null ids

   -- validate the registrant fk info....
   check_registrant_fk_info(  p_registrant_party_id
                            , p_registrant_contact_id
                            , p_registrant_account_id
                            , x_return_status => l_return_status
                           );

   IF (l_return_status = FND_API.g_ret_sts_unexp_error)
   THEN
      RAISE FND_API.g_exc_unexpected_error;
   ELSIF (l_return_status = FND_API.g_ret_sts_error)
   THEN
      RAISE FND_API.g_exc_error;
   END IF; -- l_return_status

   -- update sql stmt
   -------------------------- update --------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_Utility_PVT.debug_message(l_full_name || ': update');
   END IF;

   update AMS_EVENT_REGISTRATIONS set
      ATTENDANT_PARTY_ID = p_attendant_party_id,
      ATTENDANT_CONTACT_ID = p_attendant_contact_id,
      ATTENDANT_ACCOUNT_ID = nvl(p_attendant_account_id,attendant_account_id),
      REGISTRANT_PARTY_ID = nvl(p_registrant_party_id, registrant_party_id),
      REGISTRANT_CONTACT_ID = p_registrant_contact_id,
      REGISTRANT_ACCOUNT_ID = nvl(p_registrant_account_id, registrant_account_id),
      ORIGINAL_REGISTRANT_CONTACT_ID = registrant_contact_id
   where CONFIRMATION_CODE LIKE p_confirmation_code;

   IF (SQL%NOTFOUND)
   THEN
      AMS_Utility_PVT.error_message('AMS_API_RECORD_NOT_FOUND');
      RAISE FND_API.g_exc_error;
   END IF; -- SQL%NOTFOUND

   -- Standard check for p_commit
   IF (FND_API.to_Boolean(p_commit))
   THEN
      COMMIT WORK;
   END IF; -- p_commit

   FND_MSG_PUB.count_and_get(  p_encoded => FND_API.g_false
                             , p_count   => x_msg_count
                             , p_data    => x_msg_data
                            );

   IF (AMS_DEBUG_HIGH_ON) THEN



       AMS_Utility_PVT.debug_message(l_full_name ||': end');

   END IF;

EXCEPTION
   WHEN FND_API.g_exc_error
   THEN
      ROLLBACK TO substitute_validate_PVT;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(  p_encoded => FND_API.g_false
                                , p_count   => x_msg_count
                                , p_data    => x_msg_data
                               );

   WHEN FND_API.g_exc_unexpected_error
   THEN
      ROLLBACK TO substitute_validate_PVT;
      x_return_status := FND_API.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get(  p_encoded => FND_API.g_false
                                , p_count   => x_msg_count
                                , p_data    => x_msg_data
                               );

   WHEN OTHERS
   THEN
      ROLLBACK TO substitute_validate_PVT;
      x_return_status := FND_API.g_ret_sts_unexp_error;
      IF (FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error))
      THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF; -- check_msg_level
      FND_MSG_PUB.count_and_get(  p_encoded => FND_API.g_false
                                , p_count   => x_msg_count
                                , p_data    => x_msg_data
                               );

END substitute_and_validate;

-------------------------------------------------------
-- Start of Comments
--
-- PROCEDURE
--  transfer_and_validate
--
-- HISTORY
--    11/16/99  sugupta  Added.
-- PURPOSE
--    called by transfer_enrollee in PUB API..
--    TRansfer an enrollee(attendant) for an existing event registration..
--    from one event offering to another offering..id's are mandatory..
--    Who can transfer is NOT verified in this API call...
--    Waitlist flag input is mandatory which means that if the other offering is full, is
--    the attendant willing to get waitlisted....
--    if the offering is full, and waitlisting is not wanted or even wailist is full, then
--    the transfer will fail...
--    PAYMENT details are not taken care of in this API call....
-------------------------------------------------------------
PROCEDURE transfer_and_validate(  P_Api_Version_Number      IN  NUMBER
                                , P_Init_Msg_List           IN  VARCHAR2  := FND_API.G_FALSE
                                , P_Commit                  IN  VARCHAR2  := FND_API.G_FALSE
                                , p_object_version          IN  NUMBER
                                , p_old_confirmation_code   IN  VARCHAR2
                                , p_old_offer_id            IN  NUMBER
                                , p_new_offer_id            IN  NUMBER
                                , p_waitlist_flag           IN  VARCHAR2
                                , p_registrant_account_id   IN  NUMBER -- can be null
                                , p_registrant_party_id     IN  NUMBER -- can be null
                                , p_registrant_contact_id   IN  NUMBER -- can be null
                                , p_attendant_party_id      IN  NUMBER -- can be null
                                , p_attendant_contact_id    IN  NUMBER -- can be null
                                , x_new_confirmation_code   OUT NOCOPY VARCHAR2
                                , x_old_cancellation_code   OUT NOCOPY VARCHAR2
                                , x_new_registration_id     OUT NOCOPY NUMBER
                                , x_old_system_status_code  OUT NOCOPY VARCHAR2
                                , x_new_system_status_code  OUT NOCOPY VARCHAR2
                                , X_Return_Status           OUT NOCOPY VARCHAR2
                                , X_Msg_Count               OUT NOCOPY NUMBER
                                , X_Msg_Data                OUT NOCOPY VARCHAR2
                               )

IS

   l_api_name                  CONSTANT VARCHAR2(30) := 'transfer_and_validate';
   l_api_version_number        CONSTANT NUMBER       := 1.0;
   l_old_confirmation_code     VARCHAR2(30)          := p_old_confirmation_code;
   l_full_name                 VARCHAR2(60)          := G_PKG_NAME || '.' || l_api_name;
   l_return_status             VARCHAR2(1);
   l_waitlist_allowed_flag     VARCHAR2(1);
   l_reg_required_flag         VARCHAR2(1);
   l_reg_frozen_flag           VARCHAR2(1);
   l_effective_capacity        NUMBER;
   l_reg_waitlist_pct          NUMBER;
   l_cancellation_reason_code  VARCHAR2(30);
   l_system_status_code        VARCHAR2(30);
   l_reg_status_date           DATE;
   l_evt_regs_rec              evt_regs_Rec_type;

   Cursor transfer_get_offer_details(l_event_offer_id NUMBER) is
   select
      REG_WAITLIST_ALLOWED_FLAG,
      REG_REQUIRED_FLAG,
      REG_FROZEN_FLAG,
      REG_EFFECTIVE_CAPACITY,
      REG_WAITLIST_PCT
   from ams_event_offers_all_b
   where event_offer_id = l_event_offer_id;

   Cursor get_registrant_status(p_confirmation_code VARCHAR2) IS
   select system_status_code
   from ams_event_registrations
   where confirmation_code = p_confirmation_code;

BEGIN

   -- Standard Start of API savepoint
   SAVEPOINT transfer_validate_PVT;
   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_Utility_PVT.debug_message(l_full_name || ': start');
   END IF;

   IF FND_API.to_boolean(p_init_msg_list)
   THEN
      FND_MSG_PUB.initialize;
   END IF; -- p_init_msg_list

   IF (NOT FND_API.compatible_api_call(  l_api_version_number
                                       , p_api_version_number
                                       , l_api_name
                                       , g_pkg_name
                                      )
      )
   THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF; -- compatible API call

   -- Initialize API return status to SUCCESS
   l_return_status := FND_API.G_RET_STS_SUCCESS;

   -- validate not null values passed for required parameters...
   IF (   (p_old_confirmation_code IS NULL)
       OR (p_old_offer_id IS NULL)
       OR (p_new_offer_id IS NULL)
       OR (p_waitlist_flag IS NULL)
      )
   THEN
      AMS_Utility_PVT.error_message('AMS_EVT_REG_TR_NULL_PARAM');
      x_return_status := FND_API.g_ret_sts_error;
      RAISE FND_API.g_exc_error;
   END IF; -- null ids

   -- check Offer id's fk .....
   IF (AMS_Utility_PVT.check_fk_exists(  'ams_event_offers_all_b'
                                       , 'event_offer_id'
                                       , p_old_offer_id
                                      ) = FND_API.g_false
      )
   THEN
      AMS_Utility_PVT.error_message('AMS_EVT_REG_TR_BAD_EVOID');
      x_return_status := FND_API.g_ret_sts_error;
      RAISE FND_API.g_exc_error;
   END IF; -- check_fk_exists

   IF (AMS_Utility_PVT.check_fk_exists(  'ams_event_offers_all_b'
                                       , 'event_offer_id'
                                       , p_new_offer_id
                                      ) = FND_API.g_false
      )
   THEN
      AMS_Utility_PVT.error_message('AMS_EVT_REG_TR_BAD_EVOID');
      x_return_status := FND_API.g_ret_sts_error;
      RAISE FND_API.g_exc_error;
   END IF; -- check_fk_exists

   -- Prevent cancelled registrants from cancelled (probably should not be at this level in the tech stack)
   open get_registrant_status(p_old_confirmation_code);
   fetch get_registrant_status
   into l_system_status_code;
   close get_registrant_status;

   IF (nvl(l_system_status_code,'X') = 'CANCELLED')
   THEN
      AMS_Utility_PVT.error_message('AMS_EVT_REG_TR_CANCEL');
      RAISE FND_API.g_exc_error;
   END IF; -- l_system_status_code

   ------------------api logic-----------------------
   -- Get the offering details of new offer id
   open transfer_get_offer_details(p_new_offer_id);
   fetch transfer_get_offer_details
   into
      l_waitlist_allowed_flag,
      l_reg_required_flag,
      l_reg_frozen_flag,
      l_effective_capacity,
      l_reg_waitlist_pct;
   close transfer_get_offer_details;

   IF (AMS_DEBUG_HIGH_ON) THEN



       AMS_UTILITY_PVT.DEBUG_MESSAGE ('after offer details');

   END IF;
   IF (l_reg_required_flag = 'N')
   THEN
      -- call cancel registration...and give the message that reg not required for the other event
      l_cancellation_reason_code := 'TRANSFERRED_TO_OTHER_EVENT';
      Cancel_evtRegs(  P_Api_Version_Number       => p_api_version_number
                     , P_Init_Msg_List            => p_init_msg_list
                     , P_Commit                   => p_commit
                     , p_object_version           => p_object_version
                     , p_event_offer_id           => p_old_offer_id
                     , p_registrant_party_id      => NULL
                     , p_confirmation_code        => p_old_confirmation_code
                     , p_registration_group_id    => NULL
                     , p_cancellation_reason_code => l_cancellation_reason_code
                     , x_cancellation_code        => x_old_cancellation_code
                     , X_Return_Status            => l_return_status
                     , X_Msg_Count                => x_msg_count
                     , X_Msg_Data                 => x_msg_data
                    );
      IF l_return_status = FND_API.g_ret_sts_unexp_error
      THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error
      THEN
         RAISE FND_API.g_exc_error;
      END IF; -- l_return_status

      x_old_system_status_code := 'CANCELLED';
      IF (AMS_DEBUG_HIGH_ON) THEN

          AMS_UTILITY_PVT.DEBUG_MESSAGE ('REgistration for the new event offering is not required, so just cancelling');
      END IF;
      RETURN;
   ELSE -- reg required flag is Y
      IF (l_reg_frozen_flag = 'Y')
      THEN
         IF (AMS_DEBUG_HIGH_ON) THEN

             AMS_UTILITY_PVT.debug_message('Registrations for the new event offering are no longer accepted, Old Registration is not cancelled');
         END IF;
         RETURN;
      END IF; -- l_reg_frozen_flag

      IF (check_reg_availability(l_effective_capacity, p_new_offer_id) > 0)
      THEN
         l_system_status_code := 'REGISTERED';

         -- call insert, then call cancel reg
         IF (AMS_DEBUG_HIGH_ON) THEN

             AMS_UTILITY_PVT.debug_message('Calling transfer_insert');
         END IF;
         transfer_insert(  p_Api_Version_Number      => p_api_version_number
                         , p_Init_Msg_List           => p_init_msg_list
                         , p_Commit                  => p_commit
                         , p_old_offer_id            => p_old_offer_id
                         , p_new_offer_id            => p_new_offer_id
                         , p_system_status_code      => l_system_status_code
                         , p_reg_status_date         => sysdate
                         , p_old_confirmation_code   => p_old_confirmation_code
                         , p_registrant_account_id   => p_registrant_account_id
                         , p_registrant_party_id     => p_registrant_party_id
                         , p_registrant_contact_id   => p_registrant_contact_id
                         , p_attendant_party_id      => p_attendant_party_id
                         , p_attendant_contact_id    => p_attendant_contact_id
                         , x_new_confirmation_code   => x_new_confirmation_code
                         , x_new_system_status_code  => x_new_system_status_code
                         , x_new_registration_id     => x_new_registration_id
                         , x_return_status           => l_return_status
                         , x_Msg_Count               => x_msg_count
                         , x_Msg_Data                => x_msg_data
                        );

         IF (l_return_status = FND_API.g_ret_sts_unexp_error)
         THEN
            RAISE FND_API.g_exc_unexpected_error;
         ELSIF (l_return_status = FND_API.g_ret_sts_error)
         THEN
            RAISE FND_API.g_exc_error;
         END IF; -- l_return_status
         x_new_system_status_code := l_system_status_code;

         -- if reg successfull....call cancel_reg for old event offer id and pass out cancellation code for old
         l_cancellation_reason_code := 'TRANSFERRED_TO_OTHER_EVENT';
         Cancel_evtRegs(  P_Api_Version_Number       => p_api_version_number
                        , P_Init_Msg_List            => p_init_msg_list
                        , P_Commit                   => p_commit
                        , p_object_version           => p_object_version
                        , p_event_offer_id           => p_old_offer_id
                        , p_registrant_party_id      => NULL
                        , p_confirmation_code        => p_old_confirmation_code
                        , p_registration_group_id    => NULL
                        , p_cancellation_reason_code => l_cancellation_reason_code
                        , x_cancellation_code        => x_old_cancellation_code
                        , X_Return_Status            => l_return_status
                        , X_Msg_Count                => x_msg_count
                        , X_Msg_Data                 => x_msg_data
                       );

         IF (l_return_status = FND_API.g_ret_sts_unexp_error)
         THEN
            RAISE FND_API.g_exc_unexpected_error;
         ELSIF (l_return_status = FND_API.g_ret_sts_error)
         THEN
            RAISE FND_API.g_exc_error;
         END IF; -- l_return_status
         x_old_system_status_code := 'CANCELLED';

      ELSE -- check_reg_availability
         IF (p_waitlist_flag = 'Y')
         THEN
            -- checked reg, now check for waitlist
            IF (l_waitlist_allowed_flag = 'N')
            THEN
               IF (AMS_DEBUG_HIGH_ON) THEN

                   AMS_UTILITY_PVT.debug_message('Registrations are sold out. Waitlist not allowed for this event offering');
               END IF;
               RETURN;
            ELSE  -- wailist allowed
               if (check_waitlist_availability(  l_reg_waitlist_pct
                                               , l_effective_capacity
                                               , p_new_offer_id
                                              ) = FND_API.g_false
                  )
               then
                  IF (AMS_DEBUG_HIGH_ON) THEN

                      AMS_UTILITY_PVT.debug_message(' Could not wailist..Waiting list for this event offering is full, the old event is not cancelled');
                  END IF;
                  RETURN;
               else -- waitlist available
                  l_system_status_code := 'WAITLISTED';
                  -- same logic as above....
                  -- YES IT'S THE SAME GODDAMN LOGIC - THAT MEANS THERE'S A BETTER WAY TO DO IT!!!!!!
                  transfer_insert(  p_Api_Version_Number      => p_api_version_number
                                  , p_Init_Msg_List           => p_init_msg_list
                                  , p_Commit                  => p_commit
                                  , p_old_offer_id            => p_old_offer_id
                                  , p_new_offer_id            => p_new_offer_id
                                  , p_system_status_code      => l_system_status_code
                                  , p_reg_status_date         => sysdate
                                  , p_old_confirmation_code   => p_old_confirmation_code
                                  , p_registrant_account_id   => p_registrant_account_id
                                  , p_registrant_party_id     => p_registrant_party_id
                                  , p_registrant_contact_id   => p_registrant_contact_id
                                  , p_attendant_party_id      => p_attendant_party_id
                                  , p_attendant_contact_id    => p_attendant_contact_id
                                  , x_new_confirmation_code   => x_new_confirmation_code
                                  , x_new_system_status_code  => x_new_system_status_code
                                  , x_new_registration_id     => x_new_registration_id
                                  , x_return_status           => l_return_status
                                  , x_Msg_Count               => x_msg_count
                                  , x_Msg_Data                => x_msg_data
                                 );

                  IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                     RAISE FND_API.g_exc_unexpected_error;
                  ELSIF l_return_status = FND_API.g_ret_sts_error THEN
                     RAISE FND_API.g_exc_error;
                  END IF;
                  x_new_system_status_code := l_system_status_code;

                  -- if waitlisting is successfull....call cancel_reg for old event offer id....
                  --and pass OUT NOCOPY cancellation code for old...
                  l_cancellation_reason_code := 'TRANSFERRED_TO_OTHER_EVENT';
                  Cancel_evtRegs(  P_Api_Version_Number       => p_api_version_number
                                 , P_Init_Msg_List            => p_init_msg_list
                                 , P_Commit                   => p_commit
                                 , p_object_version           => p_object_version
                                 , p_event_offer_id           => p_old_offer_id
                                 , p_registrant_party_id      => NULL
                                 , p_confirmation_code        => p_old_confirmation_code
                                 , p_registration_group_id    => NULL
                                 , p_cancellation_reason_code => l_cancellation_reason_code
                                 , x_cancellation_code        => x_old_cancellation_code
                                 , X_Return_Status            => l_return_status
                                 , X_Msg_Count                => x_msg_count
                                 , X_Msg_Data                 => x_msg_data
                                );

                  IF l_return_status = FND_API.g_ret_sts_unexp_error
                  THEN
                     RAISE FND_API.g_exc_unexpected_error;
                  ELSIF l_return_status = FND_API.g_ret_sts_error
                  THEN
                     RAISE FND_API.g_exc_error;
                  END IF;
                  x_old_system_status_code := 'CANCELLED';
               end if; -- waitlist available
            END IF; -- wailist allowed
         END IF; -- waitlist is OK
      END IF; -- check reg availability
   END IF; --Reg required flag


   -- Standard check for p_commit
   IF (FND_API.to_Boolean(p_commit))
   THEN
      COMMIT WORK;
   END IF; -- p_commit

   FND_MSG_PUB.count_and_get(  p_encoded => FND_API.g_false
                             , p_count   => x_msg_count
                             , p_data    => x_msg_data
                            );

   IF (AMS_DEBUG_HIGH_ON) THEN



       AMS_Utility_PVT.debug_message(l_full_name ||': end');

   END IF;

EXCEPTION
   WHEN FND_API.g_exc_error
   THEN
      ROLLBACK TO transfer_validate_PVT;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(  p_encoded => FND_API.g_false
                                , p_count   => x_msg_count
                                , p_data    => x_msg_data
                               );

   WHEN FND_API.g_exc_unexpected_error
   THEN
      ROLLBACK TO transfer_validate_PVT;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(  p_encoded => FND_API.g_false
                                , p_count   => x_msg_count
                                , p_data    => x_msg_data
                               );

   WHEN OTHERS
   THEN
      ROLLBACK TO transfer_validate_PVT;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      IF (FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error))
      THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF; -- check_msg_level
      FND_MSG_PUB.count_and_get(  p_encoded => FND_API.g_false
                                , p_count   => x_msg_count
                                , p_data    => x_msg_data
                               );

END transfer_and_validate;

---------------------------------------------------------------------
-- PROCEDURE
--    check_evtRegs_items
--    check_evtRegs_req_items
--    check_evtRegs_uk_items
--    check_evtREgs_fk_items
--    check_evtRegs_lookup_items
--    check_evtRegs_flag_items
--
-- HISTORY
--    11/01/99  sugupta  Created.
---------------------------------------------------------------------
-------------------Required items-----------------------
PROCEDURE check_evtRegs_req_items(  p_evt_Regs_rec   IN  evt_regs_Rec_Type
                                  , x_return_status  OUT NOCOPY VARCHAR2
                                 )

IS

BEGIN

   x_return_status := FND_API.g_ret_sts_success;
   ------------------------ owner_user_id --------------------------
   IF (p_evt_Regs_rec.owner_user_id IS NULL)
   THEN
      AMS_Utility_PVT.error_message('AMS_EVT_REG_NO_OWNER_ID');
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

   /* Should user status be mandatory .. it wont be passed from screen, but derived from system status
   ------------------------ user_status_id --------------------------
   IF p_evt_Regs_rec.user_status_id IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_EVT_REG_NO_USER_STATUS');
         FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;
   */

    ----------------------REG PARTY ID---------------------------------
   IF (p_evt_Regs_rec.registrant_party_id IS NULL)
   THEN
      AMS_Utility_PVT.error_message('AMS_EVT_REG_NO_PARTY');
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

   ------------------------ payment status-Order header/line id --------------------------
   IF (p_evt_Regs_rec.payment_status_code is NOT NULL)
   THEN
      IF (p_evt_Regs_rec.payment_status_code = 'PAID')
      THEN
         IF (p_evt_Regs_rec.order_header_id IS NULL)
         THEN
            AMS_Utility_PVT.error_message('AMS_EVT_REG_NO_ORDER_HEADER');
            x_return_status := FND_API.g_ret_sts_error;
            RETURN;
         END IF; -- order_header_id
      ELSIF (p_evt_Regs_rec.payment_status_code = 'FREE')
      THEN
         IF (p_evt_Regs_rec.order_header_id IS NOT NULL)
         THEN
            AMS_Utility_PVT.error_message('AMS_EVT_REG_BAD_ORDER_HEADER');
            x_return_status := FND_API.g_ret_sts_error;
            RETURN;
         END IF; -- order_header_id
      END IF; -- payment_status_code
   END IF; -- payment_status_code is not null

   ------------------------ Order header/line id --------------------------
   IF (    (p_evt_Regs_rec.order_line_id IS NOT NULL)
       AND (p_evt_Regs_rec.order_header_id IS NULL)
      )
   THEN
      AMS_Utility_PVT.error_message('AMS_EVT_REG_NO_ORDER_HEADER');
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF; -- order_line_id/order_header_id

   ------------------------ Order header/line id-Account needed------------------
   IF (   (p_evt_Regs_rec.order_line_id IS NOT NULL)
       OR (p_evt_Regs_rec.order_header_id IS NOT NULL)
      )
   THEN
      IF (    (p_evt_regs_rec.registrant_account_id is NULL)
          AND (p_evt_regs_rec.attendant_account_id IS NULL)
         )
      THEN
         AMS_Utility_PVT.error_message('AMS_EVT_REG_NO_ACCT_FOR_ORDER');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF; -- registrant_account_id/attendant_account_id
   END IF; -- order_line_id/order_header_id

-----------------------REG CONTACT ID-----------------------------------
   IF (p_evt_Regs_rec.registrant_contact_id IS NULL)
   THEN
      AMS_Utility_PVT.error_message('AMS_EVT_REG_NO_CONTACT_ID');
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF; -- registrant_contact_id

END check_evtRegs_req_items;

----------------- unique key validation --------------------
-- only needed at update_evt..check for valdation mode
-- ask ravi if cross products need validate
PROCEDURE  check_evtRegs_uk_items(  p_confirmation_code      IN  VARCHAR2
                                  , p_event_registration_id  IN  NUMBER
                                  , p_validation_mode        IN  VARCHAR2  := JTF_PLSQL_API.g_create
                                  , x_return_status          OUT NOCOPY VARCHAR2
                                 )

IS

   l_dummy NUMBER;
   cursor c_conf_code(conf_code_in IN VARCHAR2) IS
   SELECT 1 FROM DUAL
   WHERE EXISTS (select 1
                 from ams_event_registrations
                 where confirmation_code = conf_code_in
                );

BEGIN

   -- check reg id, conf code only for create mode
      x_return_status := FND_API.g_ret_sts_success;

   IF (    (p_validation_mode = JTF_PLSQL_API.g_create)
       AND (p_event_registration_id IS NOT NULL)
      )
   THEN
      IF (AMS_Utility_PVT.check_uniqueness(  'ams_event_registrations'
                                           , 'event_registration_id = ' || p_event_registration_id
                                          ) = FND_API.g_false
         )
      THEN
         AMS_Utility_PVT.error_message('AMS_EVT_REG_DUPLICATE_ID');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF; -- check_uniqueness
   END IF; -- p_event_registration_id

   IF (    (p_validation_mode = JTF_PLSQL_API.g_create)
       AND (p_confirmation_code IS NOT NULL)
      )
   THEN
      /* bug#1490374 commented OUT NOCOPY this piece
      IF (AMS_Utility_PVT.check_uniqueness(  'ams_event_registrations'
                                           , 'confirmation_code = ''' || p_confirmation_code || ''''
                                          ) = FND_API.g_false
         )
      */
      open c_conf_code(p_confirmation_code);
      fetch c_conf_code
      into l_dummy;
      close c_conf_code;
      IF (l_dummy <> 1)
      THEN
         AMS_Utility_PVT.error_message('AMS_EVT_REG_DUPLICATE_CODE');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF; -- l_dummy
   END IF; -- p_confirmation_code

END check_evtRegs_uk_items;


------------------------FOREIGN KEY------------------------
PROCEDURE check_evtRegs_fk_items(  p_evt_Regs_rec    IN  evt_regs_Rec_Type
                                 , p_validation_mode IN  VARCHAR2
                                 , x_return_status   OUT NOCOPY VARCHAR2
                                )

IS

BEGIN

   ------------------- EVENT OFFER ID ----------------
   IF (p_evt_regs_rec.event_offer_id <> FND_API.g_miss_num)
   THEN
      IF (AMS_Utility_PVT.check_fk_exists(  'ams_event_offers_all_b'
                                          , 'event_offer_id'
                                          , p_evt_regs_rec.event_offer_id
                                         ) = FND_API.g_false
         )
      THEN
         AMS_Utility_PVT.error_message('AMS_EVT_REG_BAD_EVENT_OFFER_ID');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF; -- check_fk_exists
   END IF; -- event_offer_id

   ------------APPLICATION ID---------------------
   IF (p_evt_regs_rec.application_id <> FND_API.g_miss_num)
   THEN
      IF (AMS_Utility_PVT.check_fk_exists(  'fnd_application'
                                          , 'application_id'
                                          , p_evt_regs_rec.application_id
                                         ) = FND_API.g_false
         )
      THEN
         AMS_Utility_PVT.error_message('AMS_EVT_REG_BAD_APPLICATION_ID');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF; -- check_fk_exists
   END IF; -- application_id

   --------------user status id------------------------
   IF (p_evt_regs_rec.user_status_id <> FND_API.g_miss_num)
   THEN
      IF (AMS_Utility_PVT.check_fk_exists(  'ams_user_statuses_b'
                                          , 'user_status_id'
                                          , p_evt_regs_rec.user_status_id
                                         ) = FND_API.g_false
         )
      THEN
         AMS_Utility_PVT.error_message('AMS_EVT_REG_BAD_USER_STATUS_ID');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF; -- check_fk_exists
   END IF; -- user_status_id

   --------------------------SOURCE CODE-------------------
   IF p_evt_regs_rec.source_code <> FND_API.g_miss_char THEN
      IF (AMS_Utility_PVT.check_fk_exists(  'ams_source_codes'
                                          , 'source_code'
                                          , p_evt_regs_rec.source_code
                                          , AMS_Utility_PVT.g_varchar2
                                         ) = FND_API.g_false
         )
      THEN
         AMS_Utility_PVT.error_message('AMS_EVT_REG_BAD_SOURCE_CODE');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF; -- check_fk_exists
   END IF; -- source_code

   --------------- attendant language-----------------------
   IF (p_evt_regs_rec.attendant_language <> FND_API.g_miss_char)
   THEN
      IF (AMS_Utility_PVT.check_fk_exists(  'fnd_languages'
                                          , 'language_code'
                                          , p_evt_regs_rec.attendant_language
                                          , AMS_Utility_PVT.g_varchar2
                                         ) = FND_API.g_false
         )
      THEN
         AMS_Utility_PVT.error_message('AMS_EVT_REG_BAD_LANGUAGE');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF; -- check_fk_exists
   END IF; -- attendant_language

   ---------------------TARGET LIST ID------------------
   IF (p_evt_regs_rec.target_list_id <> FND_API.g_miss_num)
   THEN
      IF (AMS_Utility_PVT.check_fk_exists(  'ams_list_headers_all'
                                          , 'list_header_id'
                                          , p_evt_regs_rec.target_list_id
                                         ) = FND_API.g_false
         )
      THEN
         AMS_Utility_PVT.error_message('AMS_EVT_REG_BAD_TARGET_LIST_ID');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF; -- check_fk_exists
   END IF; -- target_list_id

   ---------------------SYSTEM STATUS CODE--------------------
   IF (p_evt_regs_rec.system_status_code <> FND_API.g_miss_char)
   THEN
      IF (p_validation_mode = JTF_PLSQL_API.g_create)
      THEN
         IF (AMS_Utility_PVT.check_fk_exists(  'ams_user_statuses_b'
                                             , 'system_status_code'
                                             , p_evt_regs_rec.system_status_code
                                             , AMS_Utility_PVT.g_varchar2
                                            ) = FND_API.g_false
            )
         THEN
            AMS_Utility_PVT.error_message('AMS_EVT_REG_BAD_SYS_STATUS');
            x_return_status := FND_API.g_ret_sts_error;
            RETURN;
         END IF; -- check_fk_exists
      ELSE
         -- will have to validate system status rules against ams_status_order_rules
         -- hongju to provide api..if not I will write it...
         null;
      END IF; -- p_validation_mode
   END IF; -- system_status_code

   -----------Check REGISTRANT fk INFORMATION----------------------
   check_registrant_fk_info(  p_evt_regs_rec.registrant_party_id
                            , p_evt_regs_rec.registrant_contact_id
                            , p_evt_regs_rec.registrant_account_id
                            , x_return_status
                           );

END check_evtRegs_fk_items;


------------------------LOOK UP------------------------
PROCEDURE check_evtRegs_lookup_items(  p_evt_Regs_rec   IN  evt_regs_Rec_Type
                                     , x_return_status  OUT NOCOPY VARCHAR2
                                    )

IS

BEGIN

   x_return_status := FND_API.g_ret_sts_success;
   ----------------------- registration_source_type--------------
   IF (p_evt_regs_rec.reg_source_type_code <> FND_API.g_miss_char)
   THEN
      IF (AMS_Utility_PVT.check_lookup_exists(  p_lookup_type => 'AMS_EVENT_REG_SOURCE'
                                              , p_lookup_code => p_evt_regs_rec.reg_source_type_code
                                             ) = FND_API.g_false
         )
      THEN
         AMS_Utility_PVT.error_message('AMS_EVT_REG_BAD_SOURCE_TYPE');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF; -- check_lookup_exists
   END IF; -- reg_source_type_code

   -----------------------PAYMENT STATUS_CODE--------------
   IF (p_evt_regs_rec.payment_status_code <> FND_API.g_miss_char)
   THEN
      IF (AMS_Utility_PVT.check_lookup_exists(  p_lookup_type => 'AMS_EVENT_PAYMENT_STATUS'
                                              , p_lookup_code => p_evt_regs_rec.payment_status_code
                                             ) = FND_API.g_false
         )
      THEN
         AMS_Utility_PVT.error_message('AMS_EVT_REG_BAD_PAY_STAT');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF; -- check_lookup_exists
   END IF; -- payment_status_code

   ------------------------CANCELLATION REASON CODE-------------------
   IF (p_evt_regs_rec.cancellation_reason_code <> FND_API.g_miss_char)
   THEN
      IF (AMS_Utility_PVT.check_lookup_exists(  p_lookup_type => 'AMS_EVENT_CANCEL_REASON_CODE'
                                              , p_lookup_code => p_evt_regs_rec.cancellation_reason_code
                                             ) = FND_API.g_false
         )
      THEN
         AMS_Utility_PVT.error_message('AMS_EVT_REG_BAD_CANCEL_REASON');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF; -- check_lookup_exists
   END IF; -- cancellation_reason_code

   ------------------------ATTENDANCE FAILURE REASON-------------------
   IF (p_evt_regs_rec.attendance_failure_reason <> FND_API.g_miss_char)
   THEN
      IF (AMS_Utility_PVT.check_lookup_exists(  p_lookup_type => 'AMS_EVENT_ATTENDANCE_FAILURE'
                                              , p_lookup_code => p_evt_regs_rec.attendance_failure_reason
                                             ) = FND_API.g_false
         )
      THEN
         AMS_Utility_PVT.error_message('AMS_EVT_REG_BAD_ATTEN_FAILURE');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF; -- check_lookup_exists
   END IF; -- attendance_failure_reason

END check_evtRegs_lookup_items;

-----------------------FLAG-----------------------
PROCEDURE check_evtRegs_flag_items(  p_evt_Regs_rec  IN  evt_regs_Rec_Type
                                   , x_return_status OUT NOCOPY VARCHAR2
                                  )

IS

BEGIN

   null;
   -- prospect, attended, confirmed, evaluated...

END check_evtRegs_flag_items;

PROCEDURE check_evtRegs_items(  p_evt_Regs_rec    IN  evt_regs_Rec_Type
                              , p_validation_mode IN  VARCHAR2
                              , x_return_status   OUT NOCOPY VARCHAR2
                             )

IS

BEGIN

   IF (AMS_DEBUG_HIGH_ON) THEN



       AMS_Utility_PVT.debug_message(' check req items');

   END IF;
   check_evtRegs_req_items(  p_evt_Regs_rec  => p_evt_Regs_rec
                           , x_return_status => x_return_status
                          );
   IF (x_return_status <> FND_API.g_ret_sts_success)
   THEN
      RETURN;
   END IF;

   IF (AMS_DEBUG_HIGH_ON) THEN



       AMS_Utility_PVT.debug_message('check uk items');

   END IF;
   check_evtRegs_uk_items(  p_confirmation_code => p_evt_Regs_rec.confirmation_code
                          , p_event_registration_id => p_evt_Regs_rec.event_registration_id
                          , x_return_status   => x_return_status
                          , p_validation_mode  => p_validation_mode
                         );
   IF (x_return_status <> FND_API.g_ret_sts_success)
   THEN
      RETURN;
   END IF;

   IF (AMS_DEBUG_HIGH_ON) THEN



       AMS_Utility_PVT.debug_message('check fk items');

   END IF;
   check_evtRegs_fk_items(  p_evt_Regs_rec    => p_evt_Regs_rec
                          , x_return_status  => x_return_status
                          , p_validation_mode  => p_validation_mode
                         );
   IF (x_return_status <> FND_API.g_ret_sts_success)
   THEN
      RETURN;
   END IF;

   IF (AMS_DEBUG_HIGH_ON) THEN



       AMS_Utility_PVT.debug_message('check lookup items');

   END IF;
   check_evtRegs_lookup_items(  p_evt_Regs_rec     => p_evt_Regs_rec
                              , x_return_status   => x_return_status
                             );
   IF (x_return_status <> FND_API.g_ret_sts_success)
   THEN
      RETURN;
   END IF;

   IF (AMS_DEBUG_HIGH_ON) THEN



       AMS_Utility_PVT.debug_message('check flag items');

   END IF;
   check_evtRegs_flag_items(  p_evt_Regs_rec     => p_evt_Regs_rec
                            , x_return_status   => x_return_status
                           );
   IF (x_return_status <> FND_API.g_ret_sts_success)
   THEN
      RETURN;
   END IF;

END check_evtRegs_items;

/*  record validation...*/

PROCEDURE CHECK_EVTREGS_RECORD(  p_evt_Regs_rec   IN  evt_regs_Rec_Type
                               , x_return_status  OUT NOCOPY VARCHAR2
                              )

IS

   l_event_offer_id           NUMBER := p_evt_regs_rec.event_offer_id;
   l_registrant_party_id      NUMBER := p_evt_regs_rec.registrant_party_id;
   l_registrant_contact_id    NUMBER := p_evt_regs_rec.registrant_contact_id;
   l_attendant_party_id       NUMBER := p_evt_regs_rec.attendant_party_id;
   l_attendant_contact_id     NUMBER := p_evt_regs_rec.attendant_contact_id;
   temp_registrant_party_id   NUMBER;
   temp_registrant_contact_id NUMBER;
   temp_attendant_party_id    NUMBER;
   temp_attendant_contact_id  NUMBER;
   temp_event_offer_id        NUMBER;
   l_evt_Regs_rec             evt_regs_Rec_Type;

   CURSOR chkexists(  p_reg_party_id         IN NUMBER
                    , p_reg_contact_id       IN NUMBER
                    , p_attendant_party_id   IN NUMBER
                    , p_attendant_contact_id IN NUMBER
                    , p_event_offer_id       IN NUMBER
                   )
   IS
   select
      registrant_party_id,
      registrant_contact_id,
      attendant_party_id,
      attendant_contact_id,
      event_offer_id
   from ams_event_registrations
   where registrant_party_id = p_reg_party_id
     and registrant_contact_id = p_reg_contact_id
     and attendant_party_id = p_attendant_party_id
     and attendant_contact_id = p_attendant_contact_id
     and event_offer_id = p_event_offer_id;

BEGIN

   OPEN chkexists(  l_registrant_party_id
                  , l_registrant_contact_id
                  , l_attendant_party_id
                  , l_attendant_contact_id
                  , l_event_offer_id
                 );
   FETCH chkexists
   INTO
      temp_registrant_party_id,
      temp_registrant_contact_id,
      temp_attendant_party_id,
      temp_attendant_contact_id,
      temp_event_offer_id;
   IF (chkexists%NOTFOUND)
   THEN
      x_return_status := FND_API.g_ret_sts_success;
   ELSE
      IF (AMS_DEBUG_HIGH_ON) THEN

          AMS_Utility_PVT.debug_message('This record already exists');
      END IF;
      AMS_Utility_PVT.error_message('AMS_EVENT_REGISTRANT_EXISTS');
      x_return_status := FND_API.g_ret_sts_error;
   END IF;
   CLOSE chkexists;

END CHECK_EVTREGS_RECORD;

PROCEDURE Validate_evtregs(  p_api_version_number  IN  NUMBER
                           , p_Init_Msg_List       IN  VARCHAR2  := FND_API.G_FALSE
                           , p_Validation_level    IN  NUMBER    := FND_API.G_VALID_LEVEL_FULL
                           , p_evt_regs_Rec        IN  evt_regs_Rec_Type
                           , p_validation_mode     IN  VARCHAR2  := JTF_PLSQL_API.g_create
                           , X_Return_Status       OUT NOCOPY VARCHAR2
                           , X_Msg_Count           OUT NOCOPY NUMBER
                           , X_Msg_Data            OUT NOCOPY VARCHAR2
                          )

IS

   l_api_name            CONSTANT VARCHAR2(30) := 'Validate_evtregs';
   l_api_version_number  CONSTANT NUMBER       := 1.0;
   l_full_name           CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_return_status       VARCHAR2(1);
   l_evt_regs_rec        evt_regs_Rec_Type     := p_evt_regs_Rec;

BEGIN

   ----------------------- initialize --------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   IF (FND_API.to_boolean(p_init_msg_list))
   THEN
      FND_MSG_PUB.initialize;
   END IF; -- p_init_msg_list

   IF (NOT FND_API.compatible_api_call(  l_api_version_number
                                       , p_api_version_number
                                       , l_api_name
                                       , g_pkg_name
                                      )
      )
   THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF; -- compatible API call

   x_return_status := FND_API.g_ret_sts_success;

   ---------------------- validate ------------------------

   IF (AMS_DEBUG_HIGH_ON) THEN



       AMS_Utility_PVT.debug_message(l_full_name||': check items');

   END IF;
   IF (p_validation_level >= JTF_PLSQL_API.g_valid_level_item)
   THEN
      check_evtRegs_items(  p_evt_regs_Rec    =>  l_evt_regs_Rec
                          , p_validation_mode => p_validation_mode
                          , x_return_status   =>  l_return_status
                         );

      IF (l_return_status = FND_API.g_ret_sts_unexp_error)
      THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF (l_return_status = FND_API.g_ret_sts_error)
      THEN
         RAISE FND_API.g_exc_error;
      END IF; -- l_return_status
   END IF; -- p_validation_level

/*
   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_Utility_PVT.debug_message(l_full_name||': check record');
   END IF;

   IF (p_validation_level >= JTF_PLSQL_API.g_valid_level_record)
   THEN
      check_evtRegs_record(  P_evt_regs_Rec  => l_evt_regs_Rec
                           , x_return_status => l_return_status
                          );
      IF (l_return_status = FND_API.g_ret_sts_unexp_error)
      THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF (l_return_status = FND_API.g_ret_sts_error)
      THEN
         RAISE FND_API.g_exc_error;
      END IF; -- l_return_status
   END IF; -- p_validation_level

   -------------------- finish --------------------------
   FND_MSG_PUB.count_and_get(  p_encoded => FND_API.g_false,
                             , p_count   => x_msg_count,
                             , p_data    => x_msg_data
                            );
*/
   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_Utility_PVT.debug_message(l_full_name ||': end');
   END IF;

EXCEPTION

   WHEN FND_API.g_exc_error
   THEN
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(  p_encoded => FND_API.g_false
                                , p_count   => x_msg_count
                                , p_data    => x_msg_data
                               );

   WHEN FND_API.g_exc_unexpected_error
   THEN
      x_return_status := FND_API.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get(  p_encoded => FND_API.g_false
                                , p_count   => x_msg_count
                                , p_data    => x_msg_data
                               );

   WHEN OTHERS
   THEN
      x_return_status := FND_API.g_ret_sts_unexp_error;
      IF (FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error))
      THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF; -- check_msg_level
      FND_MSG_PUB.count_and_get(  p_encoded => FND_API.g_false
                                , p_count   => x_msg_count
                                , p_data    => x_msg_data
                               );

END Validate_evtregs;

---------------------------------------------------------------------
-- PROCEDURE
--    init_evtregs_rec
--
-- HISTORY
--    06/29/2000  sugupta  Create.
---------------------------------------------------------------------
PROCEDURE init_evtregs_rec(x_evt_regs_rec  OUT NOCOPY  evt_regs_Rec_Type)

IS

BEGIN

   x_evt_regs_rec.EVENT_REGISTRATION_ID := FND_API.g_miss_num;
   x_evt_regs_rec.last_update_date := FND_API.g_miss_date;
   x_evt_regs_rec.last_updated_by := FND_API.g_miss_num;
   x_evt_regs_rec.creation_date := FND_API.g_miss_date;
   x_evt_regs_rec.created_by := FND_API.g_miss_num;
   x_evt_regs_rec.last_update_login := FND_API.g_miss_num;
   x_evt_regs_rec.object_version_number := FND_API.g_miss_num;
   x_evt_regs_rec.EVENT_OFFER_ID := FND_API.g_miss_num;
   x_evt_regs_rec.application_id := FND_API.g_miss_num;
   x_evt_regs_rec.ACTIVE_FLAG := FND_API.g_miss_char;
   x_evt_regs_rec.OWNER_USER_ID :=  FND_API.g_miss_num;
   x_evt_regs_rec.SYSTEM_STATUS_CODE :=  FND_API.g_miss_char;
   x_evt_regs_rec.DATE_REGISTRATION_PLACED :=  FND_API.g_miss_date;
   x_evt_regs_rec.USER_STATUS_ID := FND_API.g_miss_num;
   x_evt_regs_rec.LAST_REG_STATUS_DATE := FND_API.g_miss_date;
   x_evt_regs_rec.REG_SOURCE_TYPE_CODE := FND_API.g_miss_char;
   x_evt_regs_rec.REGISTRATION_SOURCE_ID := FND_API.g_miss_num;
   x_evt_regs_rec.CONFIRMATION_CODE := FND_API.g_miss_char;
   x_evt_regs_rec.SOURCE_CODE := FND_API.g_miss_char;
   x_evt_regs_rec.REGISTRATION_GROUP_ID := FND_API.g_miss_num;
   x_evt_regs_rec.REGISTRANT_PARTY_ID := FND_API.g_miss_num;
   x_evt_regs_rec.REGISTRANT_CONTACT_ID := FND_API.g_miss_num;
   x_evt_regs_rec.REGISTRANT_ACCOUNT_ID := FND_API.g_miss_num;
   x_evt_regs_rec.ATTENDANT_PARTY_ID := FND_API.g_miss_num;
   x_evt_regs_rec.ATTENDANT_CONTACT_ID := FND_API.g_miss_num;
   x_evt_regs_rec.ATTENDANT_ACCOUNT_ID := FND_API.g_miss_num;
   x_evt_regs_rec.ORIGINAL_REGISTRANT_CONTACT_ID := FND_API.g_miss_num;
   x_evt_regs_rec.PROSPECT_FLAG := FND_API.g_miss_char;
   x_evt_regs_rec.ATTENDED_FLAG := FND_API.g_miss_char;
   x_evt_regs_rec.CONFIRMED_FLAG := FND_API.g_miss_char;
   x_evt_regs_rec.EVALUATED_FLAG := FND_API.g_miss_char;
   x_evt_regs_rec.ATTENDANCE_RESULT_CODE := FND_API.g_miss_char;
   x_evt_regs_rec.WAITLISTED_PRIORITY := FND_API.g_miss_num;
   x_evt_regs_rec.TARGET_LIST_ID := FND_API.g_miss_num;
   x_evt_regs_rec.INBOUND_MEDIA_ID := fnd_api.g_miss_num;
   x_evt_regs_rec.INBOUND_CHANNEL_ID := fnd_api.g_miss_num;
   x_evt_regs_rec.CANCELLATION_CODE := fnd_api.g_miss_char;
   x_evt_regs_rec.CANCELLATION_REASON_CODE := fnd_api.g_miss_char;
   x_evt_regs_rec.ATTENDANCE_FAILURE_REASON := fnd_api.g_miss_char;
   x_evt_regs_rec.ATTENDANT_LANGUAGE := fnd_api.g_miss_char;
   x_evt_regs_rec.SALESREP_ID := fnd_api.g_miss_num;
   x_evt_regs_rec.ORDER_HEADER_ID := fnd_api.g_miss_num;
   x_evt_regs_rec.ORDER_LINE_ID := fnd_api.g_miss_num;
   x_evt_regs_rec.DESCRIPTION := fnd_api.g_miss_char;
   x_evt_regs_rec.MAX_ATTENDEE_OVERRIDE_FLAG := fnd_api.g_miss_char;
   x_evt_regs_rec.INVITE_ONLY_OVERRIDE_FLAG := fnd_api.g_miss_char;
   x_evt_regs_rec.PAYMENT_STATUS_CODE := fnd_api.g_miss_char;
   x_evt_regs_rec.AUTO_REGISTER_FLAG := fnd_api.g_miss_char;
   x_evt_regs_rec.attribute_category := FND_API.g_miss_char;
   x_evt_regs_rec.attribute1 := FND_API.g_miss_char;
   x_evt_regs_rec.attribute2 := FND_API.g_miss_char;
   x_evt_regs_rec.attribute3 := FND_API.g_miss_char;
   x_evt_regs_rec.attribute4 := FND_API.g_miss_char;
   x_evt_regs_rec.attribute5 := FND_API.g_miss_char;
   x_evt_regs_rec.attribute6 := FND_API.g_miss_char;
   x_evt_regs_rec.attribute7 := FND_API.g_miss_char;
   x_evt_regs_rec.attribute8 := FND_API.g_miss_char;
   x_evt_regs_rec.attribute9 := FND_API.g_miss_char;
   x_evt_regs_rec.attribute10 := FND_API.g_miss_char;
   x_evt_regs_rec.attribute11 := FND_API.g_miss_char;
   x_evt_regs_rec.attribute12 := FND_API.g_miss_char;
   x_evt_regs_rec.attribute13 := FND_API.g_miss_char;
   x_evt_regs_rec.attribute14 := FND_API.g_miss_char;
   x_evt_regs_rec.attribute15 := FND_API.g_miss_char;
   x_evt_regs_rec.attendee_role_type := FND_API.g_miss_char;  -- Hornet : added for imeeting integration
   x_evt_regs_rec.notification_type := FND_API.g_miss_char;   -- Hornet : added for imeeting integration
   x_evt_regs_rec.last_notified_time := FND_API.g_miss_date;  -- Hornet : added for imeeting integration
   x_evt_regs_rec.EVENT_JOIN_TIME := FND_API.g_miss_date;     -- Hornet : added for imeeting integration
   x_evt_regs_rec.EVENT_EXIT_TIME := FND_API.g_miss_date;     -- Hornet : added for imeeting integration
   x_evt_regs_rec.MEETING_ENCRYPTION_KEY_CODE := FND_API.g_miss_char;  --Hornet : added for imeeting integration

END init_evtregs_rec;

--------------complete evtregs rec for update-------------------------
PROCEDURE COMPLETE_EVTREG_REC(  P_evt_regs_Rec  IN  evt_regs_Rec_Type
                              , x_complete_Rec  OUT NOCOPY evt_regs_Rec_Type
                             )

IS

   CURSOR c_reg IS
   SELECT *
   FROM ams_event_registrations
   WHERE event_registration_id = p_evt_regs_rec.event_registration_id;

   l_reg_rec c_reg%ROWTYPE;

BEGIN

   x_complete_rec := p_evt_regs_rec;

   IF (AMS_DEBUG_HIGH_ON) THEN



       AMS_UTILITY_PVT.debug_message('Ev Reg Id:'||  p_evt_regs_rec.event_registration_id);

   END IF;

   OPEN c_reg;
   FETCH c_reg
   INTO l_reg_rec;
   IF (c_reg%NOTFOUND)
   THEN
      CLOSE c_reg;
      AMS_UTILITY_PVT.error_message('AMS_API_RECORD_NOT_FOUND');
      -- RAISE FND_API.g_exc_error;
   END IF; -- c_reg%NOTFOUND
   CLOSE c_reg;

   -- This procedure should complete the record by going through all the items in the incoming record.
   IF (p_evt_regs_rec.EVENT_OFFER_ID = FND_API.g_miss_num)
   THEN
      x_complete_rec.EVENT_OFFER_ID := l_reg_rec.EVENT_OFFER_ID;
   END IF; -- EVENT_OFFER_ID

   IF (p_evt_regs_rec.APPLICATION_ID = FND_API.g_miss_num)
   THEN
      x_complete_rec.APPLICATION_ID := l_reg_rec.APPLICATION_ID;
   END IF; -- APPLICATION_ID

   IF (p_evt_regs_rec.ACTIVE_FLAG = FND_API.g_miss_char)
   THEN
      x_complete_rec.ACTIVE_FLAG := l_reg_rec.ACTIVE_FLAG;
   END IF; -- ACTIVE_FLAG

   IF (p_evt_regs_rec.OWNER_USER_ID = FND_API.g_miss_num)
   THEN
      x_complete_rec.OWNER_USER_ID := l_reg_rec.OWNER_USER_ID;
   END IF; -- OWNER_USER_ID

   IF (p_evt_regs_rec.SYSTEM_STATUS_CODE = FND_API.g_miss_char)
   THEN
      x_complete_rec.SYSTEM_STATUS_CODE := l_reg_rec.SYSTEM_STATUS_CODE;
   END IF; -- SYSTEM_STATUS_CODE

   IF (p_evt_regs_rec.DATE_REGISTRATION_PLACED = FND_API.g_miss_date)
   THEN
      x_complete_rec.DATE_REGISTRATION_PLACED := l_reg_rec.DATE_REGISTRATION_PLACED;
   END IF; -- DATE_REGISTRATION_PLACED

   IF (p_evt_regs_rec.USER_STATUS_ID = FND_API.g_miss_num)
   THEN
      x_complete_rec.USER_STATUS_ID := l_reg_rec.USER_STATUS_ID;
   END IF; -- USER_STATUS_ID

   IF (p_evt_regs_rec.LAST_REG_STATUS_DATE = FND_API.g_miss_date)
   THEN
      x_complete_rec.LAST_REG_STATUS_DATE := l_reg_rec.LAST_REG_STATUS_DATE;
   END IF; -- LAST_REG_STATUS_DATE

   IF (p_evt_regs_rec.REG_SOURCE_TYPE_CODE = FND_API.g_miss_char)
   THEN
      x_complete_rec.REG_SOURCE_TYPE_CODE := l_reg_rec.REG_SOURCE_TYPE_CODE;
   END IF; -- REG_SOURCE_TYPE_CODE

   IF (p_evt_regs_rec.REGISTRATION_SOURCE_ID = FND_API.g_miss_num)
   THEN
      x_complete_rec.REGISTRATION_SOURCE_ID := l_reg_rec.REGISTRATION_SOURCE_ID;
   END IF; -- REGISTRATION_SOURCE_ID

   IF (p_evt_regs_rec.CONFIRMATION_CODE = FND_API.g_miss_char)
   THEN
      x_complete_rec.CONFIRMATION_CODE := l_reg_rec.CONFIRMATION_CODE;
   END IF; -- CONFIRMATION_CODE

   IF (p_evt_regs_rec.SOURCE_CODE = FND_API.g_miss_char)
   THEN
      x_complete_rec.SOURCE_CODE := l_reg_rec.SOURCE_CODE;
   END IF; -- SOURCE_CODE

   IF (p_evt_regs_rec.REGISTRATION_GROUP_ID = FND_API.g_miss_num)
   THEN
      x_complete_rec.REGISTRATION_GROUP_ID := l_reg_rec.REGISTRATION_GROUP_ID;
   END IF; -- REGISTRATION_GROUP_ID

   IF (p_evt_regs_rec.REGISTRANT_PARTY_ID = FND_API.g_miss_num)
   THEN
      x_complete_rec.REGISTRANT_PARTY_ID := l_reg_rec.REGISTRANT_PARTY_ID;
   END IF; -- REGISTRANT_PARTY_ID

   IF (p_evt_regs_rec.REGISTRANT_CONTACT_ID = FND_API.g_miss_num)
   THEN
      x_complete_rec.REGISTRANT_CONTACT_ID := l_reg_rec.REGISTRANT_CONTACT_ID;
   END IF; -- REGISTRANT_CONTACT_ID

   IF (p_evt_regs_rec.REGISTRANT_ACCOUNT_ID = FND_API.g_miss_num)
   THEN
      x_complete_rec.REGISTRANT_ACCOUNT_ID := l_reg_rec.REGISTRANT_ACCOUNT_ID;
   END IF; -- REGISTRANT_ACCOUNT_ID

   IF (p_evt_regs_rec.ATTENDANT_PARTY_ID = FND_API.g_miss_num)
   THEN
      x_complete_rec.ATTENDANT_PARTY_ID := l_reg_rec.ATTENDANT_PARTY_ID;
   END IF; -- ATTENDANT_PARTY_ID

   IF (p_evt_regs_rec.ATTENDANT_CONTACT_ID = FND_API.g_miss_num)
   THEN
      x_complete_rec.ATTENDANT_CONTACT_ID := l_reg_rec.ATTENDANT_CONTACT_ID;
   END IF; -- ATTENDANT_CONTACT_ID

   IF (p_evt_regs_rec.ATTENDANT_ACCOUNT_ID = FND_API.g_miss_num)
   THEN
      x_complete_rec.ATTENDANT_ACCOUNT_ID := l_reg_rec.ATTENDANT_ACCOUNT_ID;
   END IF; -- ATTENDANT_ACCOUNT_ID

   IF (p_evt_regs_rec.ORIGINAL_REGISTRANT_CONTACT_ID = FND_API.g_miss_num)
   THEN
      x_complete_rec.ORIGINAL_REGISTRANT_CONTACT_ID := l_reg_rec.ORIGINAL_REGISTRANT_CONTACT_ID;
   END IF; -- ORIGINAL_REGISTRANT_CONTACT_ID

   IF (p_evt_regs_rec.PROSPECT_FLAG = FND_API.g_miss_char)
   THEN
      x_complete_rec.PROSPECT_FLAG := l_reg_rec.PROSPECT_FLAG;
   END IF; -- PROSPECT_FLAG

   IF (p_evt_regs_rec.ATTENDED_FLAG = FND_API.g_miss_char)
   THEN
      x_complete_rec.ATTENDED_FLAG := l_reg_rec.ATTENDED_FLAG;
   END IF; -- ATTENDED_FLAG

   IF (p_evt_regs_rec.EVALUATED_FLAG = FND_API.g_miss_char)
   THEN
      x_complete_rec.EVALUATED_FLAG := l_reg_rec.EVALUATED_FLAG;
   END IF; -- EVALUATED_FLAG

   IF (p_evt_regs_rec.CONFIRMED_FLAG = FND_API.g_miss_char)
   THEN
      x_complete_rec.CONFIRMED_FLAG := l_reg_rec.CONFIRMED_FLAG;
   END IF; -- CONFIRMED_FLAG

   IF (p_evt_regs_rec.ATTENDANCE_RESULT_CODE = FND_API.g_miss_char)
   THEN
      x_complete_rec.ATTENDANCE_RESULT_CODE := l_reg_rec.ATTENDANCE_RESULT_CODE;
   END IF; -- ATTENDANCE_RESULT_CODE

   IF (p_evt_regs_rec.WAITLISTED_PRIORITY = FND_API.g_miss_num)
   THEN
      x_complete_rec.WAITLISTED_PRIORITY := l_reg_rec.WAITLISTED_PRIORITY;
   END IF; -- WAITLISTED_PRIORITY

   IF (p_evt_regs_rec.TARGET_LIST_ID = FND_API.g_miss_num)
   THEN
      x_complete_rec.TARGET_LIST_ID := l_reg_rec.TARGET_LIST_ID;
   END IF; -- TARGET_LIST_ID

   IF (p_evt_regs_rec.INBOUND_MEDIA_ID = FND_API.g_miss_num)
   THEN
      x_complete_rec.INBOUND_MEDIA_ID := l_reg_rec.INBOUND_MEDIA_ID;
   END IF; -- INBOUND_MEDIA_ID

   IF (p_evt_regs_rec.INBOUND_CHANNEL_ID = FND_API.g_miss_num)
   THEN
      x_complete_rec.INBOUND_CHANNEL_ID := l_reg_rec.INBOUND_CHANNEL_ID;
   END IF; -- INBOUND_CHANNEL_ID

   IF (p_evt_regs_rec.CANCELLATION_CODE = FND_API.g_miss_char)
   THEN
      x_complete_rec.CANCELLATION_CODE := l_reg_rec.CANCELLATION_CODE;
   END IF; -- CANCELLATION_CODE

   IF (p_evt_regs_rec.CANCELLATION_REASON_CODE = FND_API.g_miss_char)
   THEN
      x_complete_rec.CANCELLATION_REASON_CODE := l_reg_rec.CANCELLATION_REASON_CODE;
   END IF; -- CANCELLATION_REASON_CODE

   IF (p_evt_regs_rec.ATTENDANCE_FAILURE_REASON = FND_API.g_miss_char)
   THEN
      x_complete_rec.ATTENDANCE_FAILURE_REASON := l_reg_rec.ATTENDANCE_FAILURE_REASON;
   END IF; -- ATTENDANCE_FAILURE_REASON

   IF (p_evt_regs_rec.ATTENDANT_LANGUAGE = FND_API.g_miss_char)
   THEN
      x_complete_rec.ATTENDANT_LANGUAGE := l_reg_rec.ATTENDANT_LANGUAGE;
   END IF; -- ATTENDANT_LANGUAGE

   IF (p_evt_regs_rec.SALESREP_ID = FND_API.g_miss_num)
   THEN
      x_complete_rec.SALESREP_ID := l_reg_rec.SALESREP_ID;
   END IF; -- SALESREP_ID

   IF (p_evt_regs_rec.ORDER_HEADER_ID = FND_API.g_miss_num)
   THEN
      x_complete_rec.ORDER_HEADER_ID := l_reg_rec.ORDER_HEADER_ID;
   END IF; -- ORDER_HEADER_ID

   IF (p_evt_regs_rec.ORDER_LINE_ID = FND_API.g_miss_num)
   THEN
      x_complete_rec.ORDER_LINE_ID := l_reg_rec.ORDER_LINE_ID;
   END IF; -- ORDER_LINE_ID

   IF (p_evt_regs_rec.DESCRIPTION = FND_API.g_miss_char)
   THEN
      x_complete_rec.DESCRIPTION := l_reg_rec.DESCRIPTION;
   END IF; -- DESCRIPTION

   IF (p_evt_regs_rec.MAX_ATTENDEE_OVERRIDE_FLAG = FND_API.g_miss_char)
   THEN
      x_complete_rec.MAX_ATTENDEE_OVERRIDE_FLAG := l_reg_rec.MAX_ATTENDEE_OVERRIDE_FLAG;
   END IF; -- MAX_ATTENDEE_OVERRIDE_FLAG

   IF (p_evt_regs_rec.INVITE_ONLY_OVERRIDE_FLAG = FND_API.g_miss_char)
   THEN
      x_complete_rec.INVITE_ONLY_OVERRIDE_FLAG := l_reg_rec.INVITE_ONLY_OVERRIDE_FLAG;
   END IF; -- INVITE_ONLY_OVERRIDE_FLAG

   IF (p_evt_regs_rec.PAYMENT_STATUS_CODE = FND_API.g_miss_char)
   THEN
      x_complete_rec.PAYMENT_STATUS_CODE := l_reg_rec.PAYMENT_STATUS_CODE;
   END IF; -- PAYMENT_STATUS_CODE

   IF (p_evt_regs_rec.AUTO_REGISTER_FLAG = FND_API.g_miss_char)
   THEN
      x_complete_rec.AUTO_REGISTER_FLAG := l_reg_rec.AUTO_REGISTER_FLAG;
   END IF; -- AUTO_REGISTER_FLAG

   IF (p_evt_regs_rec.ATTRIBUTE_CATEGORY = FND_API.g_miss_char)
   THEN
      x_complete_rec.ATTRIBUTE_CATEGORY := l_reg_rec.ATTRIBUTE_CATEGORY;
   END IF; -- ATTRIBUTE_CATEGORY

   IF (p_evt_regs_rec.ATTRIBUTE1 = FND_API.g_miss_char)
   THEN
      x_complete_rec.ATTRIBUTE1 := l_reg_rec.ATTRIBUTE1;
   END IF; -- ATTRIBUTE1

   IF (p_evt_regs_rec.ATTRIBUTE2 = FND_API.g_miss_char)
   THEN
      x_complete_rec.ATTRIBUTE2 := l_reg_rec.ATTRIBUTE2;
   END IF; -- ATTRIBUTE2

   IF (p_evt_regs_rec.ATTRIBUTE3 = FND_API.g_miss_char)
   THEN
      x_complete_rec.ATTRIBUTE3 := l_reg_rec.ATTRIBUTE3;
   END IF; -- ATTRIBUTE3

   IF (p_evt_regs_rec.ATTRIBUTE4 = FND_API.g_miss_char)
   THEN
      x_complete_rec.ATTRIBUTE4 := l_reg_rec.ATTRIBUTE4;
   END IF; -- ATTRIBUTE4

   IF (p_evt_regs_rec.ATTRIBUTE5 = FND_API.g_miss_char)
   THEN
      x_complete_rec.ATTRIBUTE5 := l_reg_rec.ATTRIBUTE5;
   END IF; -- ATTRIBUTE5

   IF (p_evt_regs_rec.ATTRIBUTE6 = FND_API.g_miss_char)
   THEN
      x_complete_rec.ATTRIBUTE6 := l_reg_rec.ATTRIBUTE6;
   END IF; -- ATTRIBUTE6

   IF (p_evt_regs_rec.ATTRIBUTE7 = FND_API.g_miss_char)
   THEN
      x_complete_rec.ATTRIBUTE7 := l_reg_rec.ATTRIBUTE7;
   END IF; -- ATTRIBUTE7

   IF (p_evt_regs_rec.ATTRIBUTE8 = FND_API.g_miss_char)
   THEN
      x_complete_rec.ATTRIBUTE8 := l_reg_rec.ATTRIBUTE8;
   END IF; -- ATTRIBUTE8

   IF (p_evt_regs_rec.ATTRIBUTE9 = FND_API.g_miss_char)
   THEN
      x_complete_rec.ATTRIBUTE9 := l_reg_rec.ATTRIBUTE9;
   END IF; -- ATTRIBUTE9

   IF (p_evt_regs_rec.ATTRIBUTE10 = FND_API.g_miss_char)
   THEN
      x_complete_rec.ATTRIBUTE10 := l_reg_rec.ATTRIBUTE10;
   END IF; -- ATTRIBUTE10

   IF (p_evt_regs_rec.ATTRIBUTE11 = FND_API.g_miss_char)
   THEN
      x_complete_rec.ATTRIBUTE11 := l_reg_rec.ATTRIBUTE11;
   END IF; -- ATTRIBUTE11

   IF (p_evt_regs_rec.ATTRIBUTE12 = FND_API.g_miss_char)
   THEN
      x_complete_rec.ATTRIBUTE12 := l_reg_rec.ATTRIBUTE12;
   END IF; -- ATTRIBUTE12

   IF (p_evt_regs_rec.ATTRIBUTE13 = FND_API.g_miss_char)
   THEN
      x_complete_rec.ATTRIBUTE13 := l_reg_rec.ATTRIBUTE13;
   END IF; -- ATTRIBUTE13

   IF (p_evt_regs_rec.ATTRIBUTE14 = FND_API.g_miss_char)
   THEN
      x_complete_rec.ATTRIBUTE14 := l_reg_rec.ATTRIBUTE14;
   END IF; -- ATTRIBUTE14

   IF (p_evt_regs_rec.ATTRIBUTE15 = FND_API.g_miss_char)
   THEN
      x_complete_rec.ATTRIBUTE15 := l_reg_rec.ATTRIBUTE15;
   END IF; -- ATTRIBUTE15

   -- Hornet: following six fields added for imeeting integration
   IF (p_evt_regs_rec.attendee_role_type = FND_API.g_miss_char)
   THEN
      x_complete_rec.attendee_role_type := l_reg_rec.attendee_role_type;
   END IF; -- attendee_role_type

   IF (p_evt_regs_rec.notification_type = FND_API.g_miss_char)
   THEN
        x_complete_rec.notification_type := l_reg_rec.notification_type;
   END IF; -- notification_type

   IF (p_evt_regs_rec.last_notified_time = FND_API.g_miss_date)
   THEN
      x_complete_rec.last_notified_time := l_reg_rec.last_notified_time;
   END IF; -- last_notified_time

   IF (p_evt_regs_rec.EVENT_JOIN_TIME = FND_API.g_miss_date)
   THEN
      x_complete_rec.EVENT_JOIN_TIME := l_reg_rec.EVENT_JOIN_TIME;
   END IF; -- EVENT_JOIN_TIME

   IF (p_evt_regs_rec.EVENT_EXIT_TIME = FND_API.g_miss_date)
   THEN
      x_complete_rec.EVENT_EXIT_TIME := l_reg_rec.EVENT_EXIT_TIME;
   END IF; -- EVENT_EXIT_TIME

   IF (p_evt_regs_rec.MEETING_ENCRYPTION_KEY_CODE = FND_API.g_miss_char)
   THEN
      x_complete_rec.MEETING_ENCRYPTION_KEY_CODE := l_reg_rec.MEETING_ENCRYPTION_KEY_CODE;
   END IF; -- MEETING_ENCRYPTION_KEY_CODE

END COMPLETE_EVTREG_REC;

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
--  08-APR-2002    dcastlem    Copied from AMS_ScheduleRules_PVT
--  08-Mar-2003    ptendulk    Modified start date, end date as system for NI
--  27-may-2003    soagrawa    Fixed NI issue about result of interaction bug# 2978948
--========================================================================

PROCEDURE write_interaction(  p_event_offer_id   IN  NUMBER
                            , p_party_id         IN  NUMBER
                           )

IS

   -- CURSOR:
   -- get the target grp for this CSCH
   -- get  the list entries from that target group
   -- get the party_id for those list entries

   CURSOR c_event_details IS
   SELECT event_object_type,
          source_code,
          reg_start_date,
          event_end_date,
          owner_user_id
   FROM ams_event_offers_all_b
   WHERE event_offer_id = p_event_offer_id;

   CURSOR c_media_item_id IS
   SELECT JTF_IH_MEDIA_ITEMS_S1.NEXTVAL
   FROM dual;

   CURSOR c_interactions_id IS
   SELECT jtf_ih_interactions_s1.NEXTVAL
   FROM dual;

   CURSOR c_activities_id IS
   SELECT JTF_IH_ACTIVITIES_S1.NEXTVAL
   FROM dual;

   CURSOR c_user(p_resource_id IN NUMBER) IS
   SELECT user_id
   FROM   ams_jtf_rs_emp_v
   WHERE  resource_id = p_resource_id;

   l_interaction_rec       JTF_IH_PUB.interaction_rec_type;
   l_activities            JTF_IH_PUB.activity_tbl_type;
   l_activity_rec          JTF_IH_PUB.activity_rec_type;
   l_media_rec             JTF_IH_PUB.media_rec_type;
   l_interaction_id        NUMBER;
   l_media_id              NUMBER;

   l_start_time   DATE;
   l_end_time     DATE;
   l_owner_id     NUMBER;
   l_source_code  VARCHAR2(30);
   l_object_type  VARCHAR2(30);

   l_return_status  VARCHAR2(1);
   l_msg_count      NUMBER;
   l_msg_data       VARCHAR2(2000);
   l_user_id        NUMBER;

BEGIN

   OPEN c_event_details;
   FETCH c_event_details
   INTO l_object_type,
        l_source_code,
        l_start_time,
        l_end_time,
        l_owner_id;
   CLOSE c_event_details;

   OPEN c_user(l_owner_id);
   FETCH c_user
   INTO l_user_id;
   CLOSE c_user;
   --l_user_id :=  get_user_id(p_resource_id   =>   l_owner_id);

   -- populate media_rec
   OPEN c_media_item_id;
   FETCH c_media_item_id INTO l_media_rec.media_id ;
   CLOSE c_media_item_id;
   -- l_media_rec.media_id                 := JTF_IH_MEDIA_ITEMS_S1.nextval;
   l_media_rec.end_date_time            := SYSDATE ; -- l_end_time ; Modified by ptendulk
   l_media_rec.start_date_time          := SYSDATE ; -- l_start_time ; Modified by ptendulk
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


   IF (AMS_DEBUG_HIGH_ON) THEN





       AMS_Utility_PVT.debug_message('Write interaction: looping for party id ');


   END IF;

   -- populate interaction record
   /*OPEN c_interactions_id;
   FETCH c_interactions_id INTO l_interaction_id ;
   CLOSE c_interactions_id;*/
   -- l_interaction_id := jtf_ih_interactions_s1.nextval ;

   --l_interaction_rec.interaction_id         := l_interaction_id ;
   l_interaction_rec.end_date_time          := l_end_time ;
   l_interaction_rec.start_date_time        := l_start_time ;
   l_interaction_rec.handler_id             := 530 ;
   l_interaction_rec.outcome_id             := 10 ; -- request processed
   -- soagrawa added on 27-may-2003 for NI interaction issue  bug# 2978948
   l_interaction_rec.result_id              := 8 ; -- sent
   l_interaction_rec.resource_id            := l_owner_id ;
   l_interaction_rec.party_id               := p_party_id ; -- looping for all party ids in the list
   l_interaction_rec.object_id              := p_event_offer_id ;
   l_interaction_rec.object_type            := l_object_type;
   l_interaction_rec.source_code            := l_source_code;

   -- populate activity record
   /*OPEN c_activities_id;
   FETCH c_activities_id INTO l_activity_rec.activity_id ;
   CLOSE c_activities_id;*/
   -- l_activity_rec.activity_id               := JTF_IH_ACTIVITIES_S1.nextval ;
   l_activity_rec.end_date_time             := SYSDATE ; -- l_end_time ; Modified by ptendulk
   l_activity_rec.start_date_time           := SYSDATE ; -- l_start_time ; Modified by ptendulk
   l_activity_rec.media_id                  := l_media_id ;
   l_activity_rec.action_item_id            := 42 ; -- Event Enrollment
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

END write_interaction;





End AMS_EvtRegs_PVT;

/
