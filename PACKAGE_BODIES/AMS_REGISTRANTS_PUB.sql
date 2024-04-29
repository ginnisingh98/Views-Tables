--------------------------------------------------------
--  DDL for Package Body AMS_REGISTRANTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_REGISTRANTS_PUB" AS
/* $Header: amspevrb.pls 115.15 2004/02/18 10:45:53 anchaudh ship $ */
   g_pkg_name   CONSTANT VARCHAR2(30):='AMS_Registrants_PUB';
   G_FILE_NAME     CONSTANT VARCHAR2(15):='amsvevrb.pls';
   g_log_level     CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;

AMS_DEBUG_HIGH_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Get_Party_Detail_Reg_Rec(  p_reg_det_rec   IN  RegistrationDet
                                   , x_reg_party_rec OUT NOCOPY AMS_Registrants_PVT.party_detail_rec_type
                                  );

PROCEDURE Get_Party_Detail_Att_Rec(  p_reg_det_rec   IN  RegistrationDet
                                   , x_att_party_rec OUT NOCOPY AMS_Registrants_PVT.party_detail_rec_type
                                  );

--=============================================================================
-- Start of Comment
--=============================================================================
--API Name
--	Write_log
--Type
--	Public
--Purpose
--	Used to write logs for this API
--Author
--	Dhirendra Singh
--=============================================================================
--
PROCEDURE Write_log (p_api_name		IN VARCHAR2,
		     p_log_message 	IN VARCHAR2)
IS
	l_api_name	VARCHAR(30);
	l_log_msg	VARCHAR(2000);
BEGIN
	l_api_name := p_api_name;
	l_log_msg  := p_log_message;

	IF (AMS_DEBUG_HIGH_ON)
	THEN AMS_Utility_PVT.debug_message(p_log_message);
	END IF;
	AMS_Utility_PVT.debug_message(
				p_log_level 	=> g_log_level,
				p_module_name 	=> G_FILE_NAME ||'.'||g_pkg_name||'.'||l_api_name||'.',
				p_text		=> p_log_message
				);

--EXCEPTION
-- currently no exception handled

END Write_log;



--==============================================================================
-- Start of Comments
--==============================================================================
--API Name
--   Register
--Type
--   Public
--Pre-Req
--
--Parameters
--
--IN
--    p_api_version_number      IN   NUMBER     Required
--    p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--    p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--    p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--    p_reg_det_rec             IN   RegistrationDet  Required
--
--OUT
--    x_return_status           OUT  VARCHAR2
--    x_msg_count               OUT  NUMBER
--    x_msg_data                OUT  VARCHAR2
--Version : Current version 1.0
--
--End of Comments
--==============================================================================
--

PROCEDURE Register(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_reg_det_rec                IN   RegistrationDet,
    p_block_fulfillment          IN   VARCHAR2     := FND_API.G_FALSE,
    p_owner_user_id              IN   NUMBER,
    p_application_id             IN   NUMBER,
    x_confirm_code               OUT NOCOPY  VARCHAR2
     )

IS

   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Register';
   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_full_name                 CONSTANT VARCHAR2(60)  := G_PKG_NAME || '.' || l_api_name;

   l_reg_party_id              NUMBER  := p_reg_det_rec.reg_party_id;
   l_reg_contact_id            NUMBER  := p_reg_det_rec.reg_contact_id;
   l_att_party_id              NUMBER  := p_reg_det_rec.att_party_id;
   l_att_contact_id            NUMBER  := p_reg_det_rec.att_contact_id;

   l_reg_rec                  AMS_Registrants_PVT.party_detail_rec_type;
   l_att_rec                  AMS_Registrants_PVT.party_detail_rec_type;

   l_evt_regs_rec             AMS_EvtRegs_PVT.evt_regs_Rec_Type;
   l_event_registration_id    NUMBER;
   l_event_id                 NUMBER;
   l_status_id                NUMBER;
   l_object_version_number    NUMBER;
   l_system_status_code       VARCHAR2(30) := 'REGISTERED';
   l_confirmation_code        VARCHAR2(30) := p_reg_det_rec.confirmation_code;
   l_cancellation_code        VARCHAR2(30);
   l_waitlisted_flag          VARCHAR2(1)  := p_reg_det_rec.waitlisted_flag;
   l_attended_flag            VARCHAR2(1)  := p_reg_det_rec.attendance_flag;

   l_return_status            VARCHAR2(1);

   -- soagrawa 03-feb-2003
   l_update_reg_rec           VARCHAR2(1);

   --dbiswas 13-Mar-2003
   l_dummy                    NUMBER;

   -- soagrawa added the following on 24-apr-2003 for bug 2863012
   l_reg_status               VARCHAR2(30);

   Cursor c_event_registration_id_exists(  p_reg_party_id      NUMBER
                                         , p_reg_contact_id    NUMBER
                                         , p_att_party_id      NUMBER
                                         , p_att_contact_id    NUMBER
                                         , p_event_offer_id    NUMBER
                                        )
   IS
   select event_registration_id,
          object_version_number,
          confirmation_code,
          system_status_code
   from ams_event_registrations
   where REGISTRANT_PARTY_ID = p_reg_party_id
     and REGISTRANT_CONTACT_ID = p_reg_contact_id
     and ATTENDANT_PARTY_ID = p_att_party_id
     and ATTENDANT_CONTACT_ID = p_att_contact_id
     and EVENT_OFFER_ID = p_event_offer_id
   order by event_registration_id desc;

   Cursor c_event_reg_id_conf_code(p_confirmation_code VARCHAR2) Is
   select event_registration_id,
          object_version_number,
          REGISTRANT_PARTY_ID,
          REGISTRANT_CONTACT_ID,
          ATTENDANT_PARTY_ID,
          ATTENDANT_CONTACT_ID,
          system_status_code
   from ams_event_registrations
   where confirmation_code = p_confirmation_code;

   Cursor c_find_status_id(l_system_status_code VARCHAR2) is
   select user_status_id
   from ams_user_statuses_vl
   where system_status_type = 'AMS_EVENT_REG_STATUS'
     and system_status_code = l_system_status_code
     and default_flag = 'Y';

   -- dbiswas added the following cursor for bug 2839226
   Cursor c_contact_id_exists(p_reg_contact_id NUMBER ) IS
     SELECT 1
     FROM hz_parties
     WHERE party_id = p_reg_contact_id;

   -- soagrawa added the following 24-apr-2003 cursor for bug 2863012
   Cursor c_get_reg_status(p_reg_id NUMBER ) IS
   select system_status_code
     from ams_event_registrations
    where event_registration_id = p_reg_id;

   -- soagrawa 09-jun-2003 added to fix bug# 2997372
   CURSOR c_party_Type (p_party_id NUMBER) IS
   select party_type
   from hz_parties
   where party_id = p_party_id;

   CURSOR c_rel_det (p_party_id NUMBER) IS
   select object_id
   from hz_relationships
   where party_id = p_party_id
   and object_type = 'ORGANIZATION';

   l_party_type   VARCHAR2(30);
   -- end soagrawa 09-jun-2003

   -- soagrawa 09-jun-2003 added to fix bug# 2997411
   CURSOR c_rel_validate (p_party_id NUMBER, p_org_id NUMBER) IS
   SELECT 1
   From hz_relationships
   where party_id = p_party_id
   and object_type = 'ORGANIZATION'
   and object_id = p_org_id;

   l_dummy2   NUMBER;
   -- end soagrawa 09-jun-2003



BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT Register_Registrants_PUB;


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

   /*
   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message(l_full_name || ': start');
   END IF ;*/
   Write_log(L_API_NAME, l_full_name || ': start');

   l_return_status := FND_API.g_ret_sts_success;

   IF (p_reg_det_rec.event_source_code IS NULL)
   THEN
      AMS_Utility_PVT.Error_Message('AMS_EVEO_NO_SOURCE_CODE');
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   ELSE
      l_event_id := AMS_Registrants_PVT.Get_Event_Det(p_reg_det_rec.event_source_code);
   END IF;

   IF (l_confirmation_code is not null)
   THEN
      Open c_event_reg_id_conf_code(l_confirmation_code);
      Fetch c_event_reg_id_conf_code
      Into l_event_registration_id,
           l_object_version_number,
           l_reg_party_id,
           l_reg_contact_id,
           l_att_party_id,
           l_att_contact_id,
           l_system_status_code;
      Close c_event_reg_id_conf_code;
   END IF;


   IF (l_event_registration_id IS NULL)
   THEN
      -- Registrant Party Id
      -- soagrawa 09-jun-2003 bug# 2997411
      IF l_reg_contact_id IS NOT NULL
         AND l_reg_party_id IS NOT null
         AND l_reg_contact_id <> l_reg_party_id
      THEN
         -- B2B
         l_dummy2 := 0;

         OPEN  c_rel_validate(l_reg_contact_id, l_reg_party_id);
         FETCH c_rel_validate INTO l_dummy2;
         CLOSE c_rel_validate;

         IF l_dummy2 IS NULL OR l_dummy2 = 0
         THEN
            -- Throw an Error
            AMS_Utility_PVT.error_message('AMS_REG_B2B_IMP_TIP');
            RAISE FND_API.g_exc_error;
         END IF;
      END IF;
      -- soagrawa end 09-jun-2003 bug# 2997411


      -- bug 2839226
      IF (l_reg_contact_id IS NOT NULL)
      THEN
       OPEN c_contact_id_exists(l_reg_contact_id);
       FETCH c_contact_id_exists
       INTO l_dummy;

       CLOSE c_contact_id_exists;
          IF l_dummy is null THEN
	     AMS_Utility_PVT.Error_Message('AMS_INVALID_REG_CONTACT_ID');
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;

      ELSE
         Get_Party_Detail_Reg_Rec(  p_reg_det_rec => p_reg_det_rec
                                  , x_reg_party_rec => l_reg_rec
                                 );
         AMS_Registrants_PVT.get_party_id(  p_api_version      => 1.0
                                          , p_commit           => FND_API.g_false
                                          , p_validation_level => FND_API.g_valid_level_full
                                          , p_rec              => l_reg_rec
                                          , x_return_status    => l_return_status
                                          , x_msg_count        => x_msg_count
                                          , x_msg_data         => x_msg_data
                                          , x_new_party_id     => l_reg_contact_id
                                          , x_new_org_party_id => l_reg_party_id
                                         );
         IF (   (l_reg_contact_id is null)
             OR (l_return_status <> FND_API.g_ret_sts_success)
            )
         THEN
            -- Throw an Error
            AMS_Utility_PVT.error_message('AMS_EVT_REG_NO_PARTY');
            RAISE FND_API.g_exc_error;
         END IF; -- l_reg_contact_id error
      END IF; -- registrant ids
      -- What do we do here?  How do we get the ORG id if it exists?

      -- soagrawa 09-jun-2003 modified to fix bug# 2997372
      --l_reg_party_id := nvl(l_reg_party_id, l_reg_contact_id);
      IF l_reg_party_id IS NULL
      THEN
         OPEN  c_party_Type(l_reg_contact_id);
         FETCH c_party_Type INTO l_party_type;
         CLOSE c_party_Type;

         IF l_party_type = 'PARTY_RELATIONSHIP'
         THEN
            -- B2B
            OPEN  c_rel_det(l_reg_contact_id);
            FETCH c_rel_det INTO l_reg_party_id;
            CLOSE c_rel_det;
         ELSE
            -- B2C
            l_reg_party_id := l_reg_contact_id;
         END IF;
      END IF;
      -- end soagrawa 09-jun-2003


      -- Attendant Party Id
      -- bug 2839226

      -- soagrawa 09-jun-2003 bug# 2997411
      IF l_att_contact_id IS NOT NULL
         AND l_att_party_id IS NOT null
         AND l_att_contact_id <> l_att_party_id
      THEN
         -- B2B

         l_dummy2 := 0;

         OPEN  c_rel_validate(l_att_contact_id, l_att_party_id);
         FETCH c_rel_validate INTO l_dummy2;
         CLOSE c_rel_validate;

         IF l_dummy2 IS NULL OR l_dummy2 = 0
         THEN
            -- Throw an Error
            AMS_Utility_PVT.error_message('AMS_ATT_B2B_IMP_TIP');
            RAISE FND_API.g_exc_error;
         END IF;
      END IF;
      -- soagrawa end 09-jun-2003 bug# 2997411

      IF (l_att_contact_id is not null)
      THEN
         -- reset l_dummy
         l_dummy := NULL;
         OPEN c_contact_id_exists(l_att_contact_id);
         FETCH c_contact_id_exists
         INTO l_dummy;

         CLOSE c_contact_id_exists;
            IF l_dummy is null THEN
       	       AMS_Utility_PVT.Error_Message('AMS_INVALID_ATT_CONTACT_ID');
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

    -- end bug 2839226

      ELSE
         -- Following code is modified by ptendulk for better error handling.
         -- check here if the first name, last name and email address of the attendant is sent,
         -- if not sent , then use the registrant id as attendant. This way in import when
         -- user maps only registrant, the attendant will be picked up from attendant.

         IF (p_reg_det_rec.att_first_name IS NOT NULL AND
            p_reg_det_rec.att_last_name IS NOT NULL AND
            p_reg_det_rec.att_email_address IS NOT NULL )
         THEN

            Get_Party_Detail_Att_Rec(  p_reg_det_rec => p_reg_det_rec
                                     , x_att_party_rec => l_att_rec
                                    );
            AMS_Registrants_PVT.get_party_id(  p_api_version      => 1.0
                                             , p_commit           => FND_API.g_false
                                             , p_validation_level => FND_API.g_valid_level_full
                                             , p_rec              => l_att_rec
                                             , x_return_status    => l_return_status
                                             , x_msg_count        => x_msg_count
                                             , x_msg_data         => x_msg_data
                                             , x_new_party_id     => l_att_contact_id
                                             , x_new_org_party_id => l_att_party_id
                                            );
            IF (   (l_att_contact_id is null)
                OR (l_return_status <> FND_API.g_ret_sts_success)
               )
            THEN
               -- Throw an Error
               AMS_Utility_PVT.error_message('AMS_EVT_ATT_NO_PARTY');
               RAISE FND_API.g_exc_error;
            END IF; -- l_reg_contact_id error
            --IF (   (l_att_contact_id is null)
            --    OR (l_return_status <> FND_API.g_ret_sts_success)
            --   )
            --THEN
            --   l_att_contact_id := l_reg_contact_id;
            --   l_att_party_id := l_reg_party_id;
            --END IF; -- second attendant contact id
         ELSE
            l_att_contact_id := l_reg_contact_id;
            l_att_party_id := l_reg_party_id;
         END IF;
      END IF; -- attendant ids
      -- What do we do here?  How do we get the ORG id if it exists?

      -- soagrawa 09-jun-2003 modified to fix bug# 2997372
      --l_att_party_id := nvl(l_att_party_id, l_att_contact_id);
      IF l_att_party_id IS NULL
      THEN
         OPEN  c_party_Type(l_att_contact_id);
         FETCH c_party_Type INTO l_party_type;
         CLOSE c_party_Type;

         IF l_party_type = 'PARTY_RELATIONSHIP'
         THEN
            -- B2B
            OPEN  c_rel_det(l_att_contact_id);
            FETCH c_rel_det INTO l_att_party_id;
            CLOSE c_rel_det;
         ELSE
            -- B2C
            l_att_party_id := l_att_contact_id;
         END IF;
      END IF;
      -- end soagrawa 09-jun-2003


      -- Try to see if event registration id exists
      Open c_event_registration_id_exists(  l_reg_party_id
                                          , l_reg_contact_id
                                          , l_att_party_id
                                          , l_att_contact_id
                                          , l_event_id
                                         );
      Fetch c_event_registration_id_exists
      Into l_event_registration_id,
           l_object_version_number,
           l_confirmation_code,
           l_system_status_code;
      Close c_event_registration_id_exists;
      /**
      IF (AMS_DEBUG_HIGH_ON) THEN
         AMS_Utility_PVT.debug_message('Event Registration ID: ' || l_event_registration_id);
      END IF;*/
      Write_log(L_API_NAME, 'Event Registration ID: ' || l_event_registration_id);

   END IF; -- l_event_registration_id

   x_confirm_code := l_confirmation_code;

   IF (p_reg_det_rec.cancellation_flag = 'Y')
   THEN
      -- Call cancel
      IF (l_event_registration_id is null)
      THEN
         -- throw error - cannot cancel a registration that doesn't exist
         AMS_Utility_PVT.error_message('AMS_EVT_REG_CANC_NO_CODE');
         RAISE FND_API.g_exc_error;
      END IF; -- l_event_registration_id
      AMS_EvtRegs_PUB.Cancel_Registration(  P_Api_Version_Number        => 1.0
                                          , P_Init_Msg_List             => FND_API.G_FALSE
                                          , P_Commit                    => FND_API.G_FALSE
                                          , p_object_version            => l_object_version_number
                                          , P_event_offer_id            => l_event_id
                                          , p_registrant_party_id       => l_reg_party_id
                                          , p_confirmation_code         => l_confirmation_code
                                          , p_registration_group_id     => null
                                          , p_cancellation_reason_code  => p_reg_det_rec.cancellation_reason_code
                                          , p_block_fulfillment         => p_block_fulfillment
                                          , x_cancellation_code         => l_cancellation_code
                                          , X_Return_Status             => l_return_status
                                          , X_Msg_Count                 => x_msg_count
                                          , X_Msg_Data                  => x_msg_data
                                         );

   ELSE

      -- Cancellation Flag is not 'Y' - call create/update

      IF (l_event_registration_id is not null)
      THEN
         -- Prepare Record for Update
         AMS_EvtRegs_PUB.init_reg_rec(x_evt_regs_rec => l_evt_regs_rec);

         IF (   (l_waitlisted_flag = 'N')
             OR (l_attended_flag = 'Y')
            )
         THEN
            l_system_status_code := 'REGISTERED';
         ELSIF (l_waitlisted_flag = 'Y')
         THEN
            l_system_status_code := 'WAITLISTED';
         END IF;

         Open c_find_status_id(l_system_status_code);
         Fetch c_find_status_id
         Into l_status_id;
         Close c_find_status_id;

         l_evt_regs_rec.USER_STATUS_ID := l_status_id;
         l_evt_regs_rec.waitlisted_priority := null;
         l_evt_regs_rec.system_status_code := l_system_status_code;
         l_evt_regs_rec.object_version_number := l_object_version_number;
         l_evt_regs_rec.confirmation_code := l_confirmation_code;

      END IF; -- l_event_registration_id

      l_evt_regs_rec.event_offer_id := l_event_id;
      l_evt_regs_rec.event_registration_id := l_event_registration_id;
      l_evt_regs_rec.owner_user_id := p_owner_user_id;
      l_evt_regs_rec.application_id := p_application_id;
      l_evt_regs_rec.waitlisted_flag := l_waitlisted_flag;

      l_evt_regs_rec.ATTENDED_FLAG := nvl(l_attended_flag, l_evt_regs_rec.ATTENDED_FLAG);
      IF (l_evt_regs_Rec.ATTENDED_FLAG = 'Y')
      THEN
         l_evt_regs_Rec.max_attendee_override_flag := 'Y';
      END IF;

      l_evt_regs_rec.REG_SOURCE_TYPE_CODE := p_reg_det_rec.registration_source_type;

      l_evt_regs_rec.REGISTRANT_PARTY_ID := l_reg_party_id;
      l_evt_regs_rec.REGISTRANT_CONTACT_ID := l_reg_contact_id;
      l_evt_regs_rec.ATTENDANT_PARTY_ID := l_att_party_id;
      l_evt_regs_rec.ATTENDANT_CONTACT_ID := l_att_contact_id;

      IF (l_event_registration_id is not null)
      THEN

         -- soagrawa 03-feb-2003
         -- such a registration already exists

         IF p_reg_det_rec.update_reg_rec IS NULL
         THEN
            l_update_reg_rec := 'Y';
         ELSE
            l_update_reg_rec := p_reg_det_rec.update_reg_rec;
         END IF;

	/*
         AMS_Utility_PVT.debug_message('Value of l_update_reg_rec is '||l_update_reg_rec);
	*/
	 Write_log(L_API_NAME, 'Value of l_update_reg_rec is '||l_update_reg_rec);

         IF l_update_reg_rec = 'C'
         THEN

	/*
               IF (AMS_DEBUG_HIGH_ON) THEN
                  AMS_Utility_PVT.debug_message('Calling AMS_EvtRegs_PUB.Register');
               END IF;
	*/
	 Write_log(L_API_NAME, 'Calling AMS_EvtRegs_PUB.Register');

               l_event_registration_id := null;
               l_evt_regs_rec.event_registration_id := null;
               l_evt_regs_rec.confirmation_code := p_reg_det_rec.confirmation_code;

               l_evt_regs_rec.event_offer_id := l_event_id;
               l_evt_regs_rec.event_registration_id := l_event_registration_id;
               l_evt_regs_rec.owner_user_id := p_owner_user_id;
               l_evt_regs_rec.application_id := p_application_id;
               l_evt_regs_rec.waitlisted_flag := l_waitlisted_flag;

               l_evt_regs_rec.ATTENDED_FLAG := nvl(l_attended_flag, l_evt_regs_rec.ATTENDED_FLAG);
               IF (l_evt_regs_Rec.ATTENDED_FLAG = 'Y')
               THEN
                  l_evt_regs_Rec.max_attendee_override_flag := 'Y';
               END IF;

               l_evt_regs_rec.REG_SOURCE_TYPE_CODE := p_reg_det_rec.registration_source_type;

               l_evt_regs_rec.REGISTRANT_PARTY_ID := l_reg_party_id;
               l_evt_regs_rec.REGISTRANT_CONTACT_ID := l_reg_contact_id;
               l_evt_regs_rec.ATTENDANT_PARTY_ID := l_att_party_id;
               l_evt_regs_rec.ATTENDANT_CONTACT_ID := l_att_contact_id;
               l_evt_regs_rec.system_status_code := null;
               l_evt_regs_rec.user_status_id := null;
               l_evt_regs_rec.registration_group_id := null;
               l_evt_regs_rec.registration_source_id := null;

               AMS_EvtRegs_PUB.Register(  P_Api_Version_Number    => 1.0
                                        , P_Init_Msg_List         => FND_API.G_FALSE
                                        , P_Commit                => FND_API.G_FALSE
                                        , P_evt_regs_Rec          => l_evt_regs_rec
                                        , p_block_fulfillment      => p_block_fulfillment
                                        , x_event_registration_id => l_event_registration_id
                                        , x_confirmation_code	   => x_confirm_code
                                        , x_system_status_code    => l_system_status_code
                                        , X_Return_Status         => l_return_status
                                        , X_Msg_Count             => x_msg_count
                                        , X_Msg_Data              => x_msg_data
                                       );

         ELSIF l_update_reg_rec = 'N'
         THEN

               -- soagrawa added the following on 24-apr-2003 for bug 2863012
               -- see if existing registration's status is cancelled
               -- if yes, then dont throw error
               OPEN  c_get_reg_status(l_event_registration_id);
               FETCH c_get_reg_status INTO l_reg_status;
               CLOSE c_get_reg_status;

               IF l_reg_status = 'CANCELLED'
               THEN
		/*
                  IF (AMS_DEBUG_HIGH_ON) THEN
                     AMS_Utility_PVT.debug_message('Calling AMS_EvtRegs_PUB.Register');
                  END IF;
		*/
		Write_log(L_API_NAME, 'Calling AMS_EvtRegs_PUB.Register');

                  l_event_registration_id := null;
                  l_evt_regs_rec.event_registration_id := null;
                  l_evt_regs_rec.confirmation_code := p_reg_det_rec.confirmation_code;

                  l_evt_regs_rec.event_offer_id := l_event_id;
                  l_evt_regs_rec.event_registration_id := l_event_registration_id;
                  l_evt_regs_rec.owner_user_id := p_owner_user_id;
                  l_evt_regs_rec.application_id := p_application_id;
                  l_evt_regs_rec.waitlisted_flag := l_waitlisted_flag;

                  l_evt_regs_rec.ATTENDED_FLAG := nvl(l_attended_flag, l_evt_regs_rec.ATTENDED_FLAG);
                  IF (l_evt_regs_Rec.ATTENDED_FLAG = 'Y')
                  THEN
                     l_evt_regs_Rec.max_attendee_override_flag := 'Y';
                  END IF;

                  l_evt_regs_rec.REG_SOURCE_TYPE_CODE := p_reg_det_rec.registration_source_type;

                  l_evt_regs_rec.REGISTRANT_PARTY_ID := l_reg_party_id;
                  l_evt_regs_rec.REGISTRANT_CONTACT_ID := l_reg_contact_id;
                  l_evt_regs_rec.ATTENDANT_PARTY_ID := l_att_party_id;
                  l_evt_regs_rec.ATTENDANT_CONTACT_ID := l_att_contact_id;
                  l_evt_regs_rec.system_status_code := null;
                  l_evt_regs_rec.user_status_id := null;
                  l_evt_regs_rec.registration_group_id := null;
                  l_evt_regs_rec.registration_source_id := null;

                  AMS_EvtRegs_PUB.Register(  P_Api_Version_Number    => 1.0
                                           , P_Init_Msg_List         => FND_API.G_FALSE
                                           , P_Commit                => FND_API.G_FALSE
                                           , P_evt_regs_Rec          => l_evt_regs_rec
                                           , p_block_fulfillment      => p_block_fulfillment
                                           , x_event_registration_id => l_event_registration_id
                                           , x_confirmation_code	   => x_confirm_code
                                           , x_system_status_code    => l_system_status_code
                                           , X_Return_Status         => l_return_status
                                           , X_Msg_Count             => x_msg_count
                                           , X_Msg_Data              => x_msg_data
                                          );

               ELSE
		/*
                  IF (AMS_DEBUG_HIGH_ON) THEN
                     AMS_Utility_PVT.debug_message('Throwing error ');
                  END IF;
		*/
		Write_log(L_API_NAME, 'Throwing error ');

                  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
                     FND_MESSAGE.set_name('AMS', 'AMS_PARTY_ALREADY_REGISTERED');
                     FND_MSG_PUB.add;
                  END IF;

                  l_return_status := FND_API.g_ret_sts_error;

               END IF;


         ELSE -- default is update 'U'

	/*
               IF (AMS_DEBUG_HIGH_ON) THEN
                  AMS_Utility_PVT.debug_message('Calling AMS_EvtRegs_PUB.Update_Registration');
                  AMS_Utility_PVT.debug_message('object version number: ' || l_evt_regs_rec.object_version_number);
               END IF ;
	*/
	       Write_log(L_API_NAME, 'Calling AMS_EvtRegs_PUB.Update_Registration');
	       Write_log(L_API_NAME, 'object version number: ' || l_evt_regs_rec.object_version_number);

               AMS_EvtRegs_PUB.Update_Registration(  P_Api_Version_Number => 1.0
                                                   , P_Init_Msg_List      => FND_API.G_FALSE
                                                   , P_Commit             => FND_API.G_FALSE
                                                   , P_evt_regs_Rec       => l_evt_regs_rec
                                                   , p_block_fulfillment  => p_block_fulfillment
                                                   , X_Return_Status      => l_return_status
                                                   , X_Msg_Count          => x_msg_count
                                                   , X_Msg_Data           => x_msg_data
                                                  );

         END IF;
      ELSE
		/*
         IF (AMS_DEBUG_HIGH_ON) THEN
            AMS_Utility_PVT.debug_message('Calling AMS_EvtRegs_PUB.Register');
         END IF;
		*/
	 Write_log(L_API_NAME,'Calling AMS_EvtRegs_PUB.Register');
         AMS_EvtRegs_PUB.Register(  P_Api_Version_Number    => 1.0
                                  , P_Init_Msg_List         => FND_API.G_FALSE
                                  , P_Commit                => FND_API.G_FALSE
                                  , P_evt_regs_Rec          => l_evt_regs_rec
                                  , p_block_fulfillment      => p_block_fulfillment
                                  , x_event_registration_id => l_event_registration_id
                                  , x_confirmation_code	   => x_confirm_code
                                  , x_system_status_code    => l_system_status_code
                                  , X_Return_Status         => l_return_status
                                  , X_Msg_Count             => x_msg_count
                                  , X_Msg_Data              => x_msg_data
                                 );
      END IF; -- l_event_registration_id

   END IF; -- call cancel

   -- Check return status of create/update/cancel
   IF (l_return_status = FND_API.g_ret_sts_unexp_error)
   THEN
      RAISE FND_API.g_exc_unexpected_error;
   ELSIF (l_return_status = FND_API.g_ret_sts_error)
   THEN
      RAISE FND_API.g_exc_error;
   END IF; -- l_return_status

   IF FND_API.to_boolean(p_commit)
   THEN
      COMMIT;
   END IF; -- p_commit

   FND_MSG_PUB.count_and_get(  p_encoded => FND_API.g_false
                             , p_count   => x_msg_count
                             , p_data    => x_msg_data
                            );

   x_return_status := l_return_status;

/*
   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message(l_full_name || ': end');
   END IF;
*/
    Write_log(L_API_NAME, l_full_name || ': end');

EXCEPTION

   WHEN FND_API.g_exc_error
   THEN
      ROLLBACK TO Register_Registrants_PUB;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(  p_encoded => FND_API.g_false
                                , p_count   => x_msg_count
                                , p_data    => x_msg_data
                               );

   WHEN FND_API.g_exc_unexpected_error
   THEN
      ROLLBACK TO Register_Registrants_PUB;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(  p_encoded => FND_API.g_false
                                , p_count   => x_msg_count
                                , p_data    => x_msg_data
                               );

   WHEN OTHERS
   THEN
      ROLLBACK TO Register_Registrants_PUB;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      IF (FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error))
      THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF; -- check_msg_level
      FND_MSG_PUB.count_and_get(  p_encoded => FND_API.g_false
                                , p_count   => x_msg_count
                                , p_data    => x_msg_data
                               );

END Register;

PROCEDURE Get_Party_Detail_Reg_Rec(  p_reg_det_rec   IN  RegistrationDet
                                   , x_reg_party_rec OUT NOCOPY AMS_Registrants_PVT.party_detail_rec_type
                                  )

IS

BEGIN

x_reg_party_rec.party_id := p_reg_det_rec.reg_party_id;
x_reg_party_rec.party_type := p_reg_det_rec.reg_party_type;
x_reg_party_rec.contact_id := p_reg_det_rec.reg_contact_id;
x_reg_party_rec.party_name := p_reg_det_rec.reg_party_name;
x_reg_party_rec.title := p_reg_det_rec.reg_title;
x_reg_party_rec.first_name := p_reg_det_rec.reg_first_name;
x_reg_party_rec.middle_name := p_reg_det_rec.reg_middle_name;
x_reg_party_rec.last_name := p_reg_det_rec.reg_last_name;
x_reg_party_rec.address1 := p_reg_det_rec.reg_address1;
x_reg_party_rec.address2 := p_reg_det_rec.reg_address2;
x_reg_party_rec.address3 := p_reg_det_rec.reg_address3;
x_reg_party_rec.address4 := p_reg_det_rec.reg_address4;
x_reg_party_rec.gender := p_reg_det_rec.reg_gender;
x_reg_party_rec.address_line_phonetic := p_reg_det_rec.reg_address_line_phonetic;
x_reg_party_rec.analysis_fy := p_reg_det_rec.reg_analysis_fy;
x_reg_party_rec.apt_flag := p_reg_det_rec.reg_apt_flag;
x_reg_party_rec.best_time_contact_begin := p_reg_det_rec.reg_best_time_contact_begin;
x_reg_party_rec.best_time_contact_end := p_reg_det_rec.reg_best_time_contact_end;
x_reg_party_rec.category_code := p_reg_det_rec.reg_category_code;
x_reg_party_rec.ceo_name := p_reg_det_rec.reg_ceo_name;
x_reg_party_rec.city := p_reg_det_rec.reg_city;
x_reg_party_rec.country := p_reg_det_rec.reg_country;
x_reg_party_rec.county := p_reg_det_rec.reg_county;
x_reg_party_rec.current_fy_potential_rev := p_reg_det_rec.reg_current_fy_potential_rev;
x_reg_party_rec.next_fy_potential_rev := p_reg_det_rec.reg_next_fy_potential_rev;
x_reg_party_rec.household_income := p_reg_det_rec.reg_household_income;
x_reg_party_rec.decision_maker_flag := p_reg_det_rec.reg_decision_maker_flag;
x_reg_party_rec.department := p_reg_det_rec.reg_department;
x_reg_party_rec.dun_no_c := p_reg_det_rec.reg_dun_no_c;
x_reg_party_rec.email_address := p_reg_det_rec.reg_email_address;
x_reg_party_rec.employee_total := p_reg_det_rec.reg_employee_total;
x_reg_party_rec.fy_end_month := p_reg_det_rec.reg_fy_end_month;
x_reg_party_rec.floor := p_reg_det_rec.reg_floor;
x_reg_party_rec.gsa_indicator_flag := p_reg_det_rec.reg_gsa_indicator_flag;
x_reg_party_rec.house_number := p_reg_det_rec.reg_house_number;
x_reg_party_rec.identifying_address_flag := p_reg_det_rec.reg_identifying_address_flag;
x_reg_party_rec.jgzz_fiscal_code := p_reg_det_rec.reg_jgzz_fiscal_code;
x_reg_party_rec.job_title := p_reg_det_rec.reg_job_title;
x_reg_party_rec.last_order_date := p_reg_det_rec.reg_last_order_date;
x_reg_party_rec.org_legal_status := p_reg_det_rec.reg_org_legal_status;
x_reg_party_rec.line_of_business := p_reg_det_rec.reg_line_of_business;
x_reg_party_rec.mission_statement := p_reg_det_rec.reg_mission_statement;
x_reg_party_rec.org_name_phonetic := p_reg_det_rec.reg_org_name_phonetic;
x_reg_party_rec.overseas_address_flag := p_reg_det_rec.reg_overseas_address_flag;
x_reg_party_rec.name_suffix := p_reg_det_rec.reg_name_suffix;
x_reg_party_rec.phone_area_code := p_reg_det_rec.reg_phone_area_code;
x_reg_party_rec.phone_country_code := p_reg_det_rec.reg_phone_country_code;
x_reg_party_rec.phone_extension := p_reg_det_rec.reg_phone_extension;
x_reg_party_rec.phone_number := p_reg_det_rec.reg_phone_number;
x_reg_party_rec.postal_code := p_reg_det_rec.reg_postal_code;
x_reg_party_rec.postal_plus4_code := p_reg_det_rec.reg_postal_plus4_code;
x_reg_party_rec.po_box_no := p_reg_det_rec.reg_po_box_no;
x_reg_party_rec.province := p_reg_det_rec.reg_province;
x_reg_party_rec.rural_route_no := p_reg_det_rec.reg_rural_route_no;
x_reg_party_rec.rural_route_type := p_reg_det_rec.reg_rural_route_type;
x_reg_party_rec.secondary_suffix_element := p_reg_det_rec.reg_secondary_suffix_element;
x_reg_party_rec.sic_code := p_reg_det_rec.reg_sic_code;
x_reg_party_rec.sic_code_type := p_reg_det_rec.reg_sic_code_type;
x_reg_party_rec.site_use_code := p_reg_det_rec.reg_site_use_code;
x_reg_party_rec.state := p_reg_det_rec.reg_state;
x_reg_party_rec.street := p_reg_det_rec.reg_street;
x_reg_party_rec.street_number := p_reg_det_rec.reg_street_number;
x_reg_party_rec.street_suffix := p_reg_det_rec.reg_street_suffix;
x_reg_party_rec.suite := p_reg_det_rec.reg_suite;
x_reg_party_rec.tax_name := p_reg_det_rec.reg_tax_name;
x_reg_party_rec.tax_reference := p_reg_det_rec.reg_tax_reference;
x_reg_party_rec.timezone := p_reg_det_rec.reg_timezone;
x_reg_party_rec.total_no_of_orders := p_reg_det_rec.reg_total_no_of_orders;
x_reg_party_rec.total_order_amount := p_reg_det_rec.reg_total_order_amount;
x_reg_party_rec.year_established := p_reg_det_rec.reg_year_established;
x_reg_party_rec.url := p_reg_det_rec.reg_url;
x_reg_party_rec.survey_notes := p_reg_det_rec.reg_survey_notes;
x_reg_party_rec.contact_me_flag := p_reg_det_rec.reg_contact_me_flag;
x_reg_party_rec.email_ok_flag := p_reg_det_rec.reg_email_ok_flag;

END Get_Party_Detail_Reg_Rec;

PROCEDURE Get_Party_Detail_Att_Rec(  p_reg_det_rec   IN  RegistrationDet
                                   , x_att_party_rec OUT NOCOPY AMS_Registrants_PVT.party_detail_rec_type
                                  )

IS

BEGIN

x_att_party_rec.party_id := p_reg_det_rec.att_party_id;
x_att_party_rec.party_type := p_reg_det_rec.att_party_type;
x_att_party_rec.contact_id := p_reg_det_rec.att_contact_id;
x_att_party_rec.party_name := p_reg_det_rec.att_party_name;
x_att_party_rec.title := p_reg_det_rec.att_title;
x_att_party_rec.first_name := p_reg_det_rec.att_first_name;
x_att_party_rec.middle_name := p_reg_det_rec.att_middle_name;
x_att_party_rec.last_name := p_reg_det_rec.att_last_name;
x_att_party_rec.address1 := p_reg_det_rec.att_address1;
x_att_party_rec.address2 := p_reg_det_rec.att_address2;
x_att_party_rec.address3 := p_reg_det_rec.att_address3;
x_att_party_rec.address4 := p_reg_det_rec.att_address4;
x_att_party_rec.gender := p_reg_det_rec.att_gender;
x_att_party_rec.address_line_phonetic := p_reg_det_rec.att_address_line_phonetic;
x_att_party_rec.analysis_fy := p_reg_det_rec.att_analysis_fy;
x_att_party_rec.apt_flag := p_reg_det_rec.att_apt_flag;
x_att_party_rec.best_time_contact_begin := p_reg_det_rec.att_best_time_contact_begin;
x_att_party_rec.best_time_contact_end := p_reg_det_rec.att_best_time_contact_end;
x_att_party_rec.category_code := p_reg_det_rec.att_category_code;
x_att_party_rec.ceo_name := p_reg_det_rec.att_ceo_name;
x_att_party_rec.city := p_reg_det_rec.att_city;
x_att_party_rec.country := p_reg_det_rec.att_country;
x_att_party_rec.county := p_reg_det_rec.att_county;
x_att_party_rec.current_fy_potential_rev := p_reg_det_rec.att_current_fy_potential_rev;
x_att_party_rec.next_fy_potential_rev := p_reg_det_rec.att_next_fy_potential_rev;
x_att_party_rec.household_income := p_reg_det_rec.att_household_income;
x_att_party_rec.decision_maker_flag := p_reg_det_rec.att_decision_maker_flag;
x_att_party_rec.department := p_reg_det_rec.att_department;
x_att_party_rec.dun_no_c := p_reg_det_rec.att_dun_no_c;
x_att_party_rec.email_address := p_reg_det_rec.att_email_address;
x_att_party_rec.employee_total := p_reg_det_rec.att_employee_total;
x_att_party_rec.fy_end_month := p_reg_det_rec.att_fy_end_month;
x_att_party_rec.floor := p_reg_det_rec.att_floor;
x_att_party_rec.gsa_indicator_flag := p_reg_det_rec.att_gsa_indicator_flag;
x_att_party_rec.house_number := p_reg_det_rec.att_house_number;
x_att_party_rec.identifying_address_flag := p_reg_det_rec.att_identifying_address_flag;
x_att_party_rec.jgzz_fiscal_code := p_reg_det_rec.att_jgzz_fiscal_code;
x_att_party_rec.job_title := p_reg_det_rec.att_job_title;
x_att_party_rec.last_order_date := p_reg_det_rec.att_last_order_date;
x_att_party_rec.org_legal_status := p_reg_det_rec.att_org_legal_status;
x_att_party_rec.line_of_business := p_reg_det_rec.att_line_of_business;
x_att_party_rec.mission_statement := p_reg_det_rec.att_mission_statement;
x_att_party_rec.org_name_phonetic := p_reg_det_rec.att_org_name_phonetic;
x_att_party_rec.overseas_address_flag := p_reg_det_rec.att_overseas_address_flag;
x_att_party_rec.name_suffix := p_reg_det_rec.att_name_suffix;
x_att_party_rec.phone_area_code := p_reg_det_rec.att_phone_area_code;
x_att_party_rec.phone_country_code := p_reg_det_rec.att_phone_country_code;
x_att_party_rec.phone_extension := p_reg_det_rec.att_phone_extension;
x_att_party_rec.phone_number := p_reg_det_rec.att_phone_number;
x_att_party_rec.postal_code := p_reg_det_rec.att_postal_code;
x_att_party_rec.postal_plus4_code := p_reg_det_rec.att_postal_plus4_code;
x_att_party_rec.po_box_no := p_reg_det_rec.att_po_box_no;
x_att_party_rec.province := p_reg_det_rec.att_province;
x_att_party_rec.rural_route_no := p_reg_det_rec.att_rural_route_no;
x_att_party_rec.rural_route_type := p_reg_det_rec.att_rural_route_type;
x_att_party_rec.secondary_suffix_element := p_reg_det_rec.att_secondary_suffix_element;
x_att_party_rec.sic_code := p_reg_det_rec.att_sic_code;
x_att_party_rec.sic_code_type := p_reg_det_rec.att_sic_code_type;
x_att_party_rec.site_use_code := p_reg_det_rec.att_site_use_code;
x_att_party_rec.state := p_reg_det_rec.att_state;
x_att_party_rec.street := p_reg_det_rec.att_street;
x_att_party_rec.street_number := p_reg_det_rec.att_street_number;
x_att_party_rec.street_suffix := p_reg_det_rec.att_street_suffix;
x_att_party_rec.suite := p_reg_det_rec.att_suite;
x_att_party_rec.tax_name := p_reg_det_rec.att_tax_name;
x_att_party_rec.tax_reference := p_reg_det_rec.att_tax_reference;
x_att_party_rec.timezone := p_reg_det_rec.att_timezone;
x_att_party_rec.total_no_of_orders := p_reg_det_rec.att_total_no_of_orders;
x_att_party_rec.total_order_amount := p_reg_det_rec.att_total_order_amount;
x_att_party_rec.year_established := p_reg_det_rec.att_year_established;
x_att_party_rec.url := p_reg_det_rec.att_url;
x_att_party_rec.survey_notes := p_reg_det_rec.att_survey_notes;
x_att_party_rec.contact_me_flag := p_reg_det_rec.att_contact_me_flag;
x_att_party_rec.email_ok_flag := p_reg_det_rec.att_email_ok_flag;

END Get_Party_Detail_Att_Rec;

END AMS_Registrants_PUB;

/
