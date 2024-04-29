--------------------------------------------------------
--  DDL for Package AMS_EVTREGS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_EVTREGS_PVT" AUTHID CURRENT_USER as
/*$Header: amsvregs.pls 115.33 2002/11/22 23:37:27 dbiswas ship $*/
-- Start of Comments
-- Package name     : AMS_EvtRegs_PVT
-- Purpose          : This package is a Private API for managing event registrations
-- Procedures		:
--  create_evtregs
--  update_evtregs
--  delete_evtregs
--  lock_evtregs
--  validate_evtregs
-- History          :    created   sugupta     10/15/99
--    01-MAR-2002  dcastlem  Implemented invite list validation and
--                           automatic registration for capacity changes
--    12-MAR-2002  dcastlem  Added support for general Public API
--                           (AMS_Registrants_PUB)
--    05-APR-2002  dcastlem  Refined waitlist code
--    08-APR-2002  dcastlem  Copied write_interaction from AMS_ScheduleRules_PVT
-- NOTE             :
-- End of Comments

--   *******************************************************
--    Start of Comments
--   -------------------------------------------------------
--    Record name:evt_regs_Rec_Type
--   -------------------------------------------------------
--   End of Comments

TYPE evt_regs_Rec_Type
IS RECORD
(
   EVENT_REGISTRATION_ID           NUMBER,
   LAST_UPDATE_DATE                DATE,
   LAST_UPDATED_BY                 NUMBER ,
   CREATION_DATE                   DATE,
   CREATED_BY                      NUMBER,
   LAST_UPDATE_LOGIN               NUMBER,
   OBJECT_VERSION_NUMBER           NUMBER,
   EVENT_OFFER_ID                  NUMBER,
   APPLICATION_ID                  NUMBER,
   ACTIVE_FLAG                     VARCHAR2(1),
   OWNER_USER_ID                   NUMBER,
   SYSTEM_STATUS_CODE              VARCHAR2(30),
   DATE_REGISTRATION_PLACED        DATE,
   USER_STATUS_ID                  NUMBER,
   LAST_REG_STATUS_DATE            DATE,
   REG_SOURCE_TYPE_CODE            VARCHAR2(30),
   REGISTRATION_SOURCE_ID          NUMBER,
   CONFIRMATION_CODE               VARCHAR2(30),
   SOURCE_CODE                     VARCHAR2(30),
   REGISTRATION_GROUP_ID           NUMBER,
   REGISTRANT_PARTY_ID             NUMBER,
   REGISTRANT_CONTACT_ID           NUMBER,
   REGISTRANT_ACCOUNT_ID           NUMBER,
   ATTENDANT_PARTY_ID              NUMBER,
   ATTENDANT_CONTACT_ID            NUMBER,
   ATTENDANT_ACCOUNT_ID            NUMBER,
   ORIGINAL_REGISTRANT_CONTACT_ID  NUMBER,
   PROSPECT_FLAG                   VARCHAR2(1),
   ATTENDED_FLAG                   VARCHAR2(1),
   CONFIRMED_FLAG                  VARCHAR2(1),
   EVALUATED_FLAG                  VARCHAR2(1),
   WAITLISTED_FLAG                 VARCHAR2(1),
   ATTENDANCE_RESULT_CODE          VARCHAR2(4000),
   WAITLISTED_PRIORITY             NUMBER,
   TARGET_LIST_ID                  NUMBER,
   INBOUND_MEDIA_ID                NUMBER,
   INBOUND_CHANNEL_ID              NUMBER,
   CANCELLATION_CODE               VARCHAR2(30),
   CANCELLATION_REASON_CODE        VARCHAR2(30),
   ATTENDANCE_FAILURE_REASON       VARCHAR2(30),
   ATTENDANT_LANGUAGE              VARCHAR2(4),
   SALESREP_ID                     NUMBER,
   ORDER_HEADER_ID                 NUMBER,
   ORDER_LINE_ID                   NUMBER,
   DESCRIPTION                     VARCHAR2(4000),
   MAX_ATTENDEE_OVERRIDE_FLAG      VARCHAR2(1),
   INVITE_ONLY_OVERRIDE_FLAG       VARCHAR2(1),
   PAYMENT_STATUS_CODE             VARCHAR2(30),
   AUTO_REGISTER_FLAG              VARCHAR2(1),
   ATTRIBUTE_CATEGORY              VARCHAR2(30),
   ATTRIBUTE1                      VARCHAR2(150),
   ATTRIBUTE2                      VARCHAR2(150),
   ATTRIBUTE3                      VARCHAR2(150),
   ATTRIBUTE4                      VARCHAR2(150),
   ATTRIBUTE5                      VARCHAR2(150),
   ATTRIBUTE6                      VARCHAR2(150),
   ATTRIBUTE7                      VARCHAR2(150),
   ATTRIBUTE8                      VARCHAR2(150),
   ATTRIBUTE9                      VARCHAR2(150),
   ATTRIBUTE10                     VARCHAR2(150),
   ATTRIBUTE11                     VARCHAR2(150),
   ATTRIBUTE12                     VARCHAR2(150),
   ATTRIBUTE13                     VARCHAR2(150),
   ATTRIBUTE14                     VARCHAR2(150),
   ATTRIBUTE15                     VARCHAR2(150),
   attendee_role_type              VARCHAR2(30),  -- Hornet : added for imeeting integration
   notification_type               VARCHAR2(30),  -- Hornet : added for imeeting integration
   last_notified_time              DATE,          -- Hornet : added for imeeting integration
   EVENT_JOIN_TIME                 DATE,          -- Hornet : added for imeeting integration
   EVENT_EXIT_TIME                 DATE,          -- Hornet : added for imeeting integration*/
   MEETING_ENCRYPTION_KEY_CODE     VARCHAR2(150)  -- Hornet : added for imeeting integration
);

/*  murali jun17 2001
   I am commenting following function , because the generating rosetta wrapper does not dupport function
   returing record type. The comment will break the support given to tele sales. This version does not
   support tele sales*/
-- FUNCTION  GET_Reg_Rec  RETURN  AMS_EvtRegs_PVT.evt_regs_Rec_Type;

FUNCTION check_reg_availability(  p_effective_capacity  IN  NUMBER
                                , p_event_offer_id      IN  NUMBER
                               )
RETURN NUMBER;

FUNCTION check_number_registered(p_event_offer_id IN NUMBER)
RETURN NUMBER;

FUNCTION check_number_waitlisted(p_event_offer_id IN NUMBER)
RETURN NUMBER;

-----------------------------------------------------------------------------------
--   API Name : Create_evtregs
--   Type     : Private
--   Pre-Req  :
--   Parameters:
--   IN
--       p_api_version_number      IN  NUMBER            Required
--       p_init_msg_list           IN  VARCHAR2           Optional  Default = FND_API_G_FALSE
--       p_commit                  IN  VARCHAR2           Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN  NUMBER             Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       P_evt_regs_Rec            IN  evt_regs_Rec_Type  Required
--       p_system_status_code      IN  VARCHAR2           Required
--   OUT
--       x_EVENT_REGISTRATION_ID   OUT  NUMBER
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   NOTES
--    1. object_version_number will be set to 1.
--    2. If EVENT_REGISTRATION_ID is passed in, the uniqueness will be checked.
--       Raise exception in case of duplicates.
--    3. If EVENT_REGISTRATION_ID is not passed in, generate a unique one from
--       the sequence.
--    4. If a flag column is passed in, check if it is 'Y' or 'N'.
--       Raise exception for invalid flag.
--    5. If a flag column is not passed in, default it to 'Y' or 'N'.
--    6. Please don't pass in any FND_API.g_mess_char/num/date.
-----------------------------------------------------------------------------------
PROCEDURE Create_evtregs(  P_Api_Version_Number         IN   NUMBER
                         , P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE
                         , P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE
                         , p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL
                         , p_evt_regs_rec               IN   evt_regs_Rec_Type
                         , p_block_fulfillment          IN   VARCHAR2     := FND_API.G_FALSE
                         , x_event_registration_id      OUT NOCOPY  NUMBER
                         , x_confirmation_code          OUT NOCOPY  VARCHAR2
                         , x_system_status_code         OUT NOCOPY  VARCHAR2
                         , x_return_status              OUT NOCOPY  VARCHAR2
                         , x_msg_count                  OUT NOCOPY  NUMBER
                         , x_msg_data                   OUT NOCOPY  VARCHAR2
                        );

-----------------------------------------------------------------------------------
--   API Name : Update_evtregs
--   Type     : Private
--   Pre-Req  :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER            Required
--       p_init_msg_list           IN   VARCHAR2          Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2          Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER            Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       P_evt_regs_Rec            IN  evt_regs_Rec_Type  Required  (record with new items)
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   NOTES
--    1. Raise exception if the object_version_number doesn't match.
--    2. If an attribute is passed in as FND_API.g_miss_char/num/date,
--       that column won't be updated.
-----------------------------------------------------------------------------------
PROCEDURE Update_evtregs(  P_Api_Version_Number         IN  NUMBER
                         , P_Init_Msg_List              IN  VARCHAR2  := FND_API.G_FALSE
                         , P_Commit                     IN  VARCHAR2  := FND_API.G_FALSE
                         , p_validation_level           IN  NUMBER    := FND_API.G_VALID_LEVEL_FULL
                         , P_evt_regs_Rec               IN  evt_regs_Rec_Type
                         , p_block_fulfillment          IN  VARCHAR2  := FND_API.G_FALSE
                         , X_Return_Status              OUT NOCOPY VARCHAR2
                         , X_Msg_Count                  OUT NOCOPY NUMBER
                         , X_Msg_Data                   OUT NOCOPY VARCHAR2
                        );

-----------------------------------------------------------------------------------
--   API Name:  Update_evtregs_wrapper
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number        IN  NUMBER     Required
--       p_init_msg_list             IN  VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                    IN  VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level          IN  NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       P_evt_regs_Rec              IN  evt_regs_Rec_Type  Required (record with new items)
--       p_cancellation_reason_code  IN  VARCHAR2   Optional  Default = NULL
--   OUT
--       x_cancellation_code       OUT  VARCHAR2
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   NOTES
--    1. Call update or cancel depending on the status code
-----------------------------------------------------------------------------------
PROCEDURE UPDATE_evtregs_wrapper(  P_Api_Version_Number        IN   NUMBER
                                 , P_Init_Msg_List             IN   VARCHAR2  := FND_API.G_FALSE
                                 , P_Commit                    IN   VARCHAR2  := FND_API.G_FALSE
                                 , p_validation_level          IN   NUMBER    := FND_API.G_VALID_LEVEL_FULL
                                 , P_evt_regs_Rec              IN   evt_regs_Rec_Type
                                 , p_block_fulfillment         IN   VARCHAR2  := FND_API.G_FALSE
                                 , p_cancellation_reason_code  IN   VARCHAR2  := NULL
                                 , x_cancellation_code         OUT NOCOPY  VARCHAR2
                                 , X_Return_Status             OUT NOCOPY  VARCHAR2
                                 , X_Msg_Count                 OUT NOCOPY  NUMBER
                                 , X_Msg_Data                  OUT NOCOPY  VARCHAR2
                                );

-----------------------------------------------------------------------------------
--   API Name : Cancel_evtregs
--   Type     : Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number        IN  NUMBER    Required
--       p_init_msg_list             IN  VARCHAR2  Optional  Default = FND_API_G_FALSE
--       p_commit                    IN  VARCHAR2  Optional  Default = FND_API.G_FALSE
--       p_event_offer_id            IN  NUMBER    Required
--       p_registrant_party_id       IN  NUMBER
--       p_confirmation_code         IN  VARCHAR2  Required
--       p_registration_group_id     IN  NUMBER
--       p_cancellation_reason_code  IN  VARCHAR2  Required
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   NOTES
--    1. Raise exception if the object_version_number doesn't match.
--       modified sugupta 06/21/2000 return cancellation code as varchar2
-----------------------------------------------------------------------------------
PROCEDURE Cancel_evtregs(  P_Api_Version_Number         IN  NUMBER
                         , P_Init_Msg_List              IN  VARCHAR2  := FND_API.G_FALSE
                         , P_Commit                     IN  VARCHAR2  := FND_API.G_FALSE
                         , p_object_version             IN  NUMBER
                         , p_event_offer_id             IN  NUMBER
                         , p_registrant_party_id        IN  NUMBER
                         , p_confirmation_code          IN  VARCHAR2
                         , p_registration_group_id      IN  NUMBER
                         , p_cancellation_reason_code   IN  VARCHAR2
                         , p_block_fulfillment          IN  VARCHAR2  := FND_API.G_FALSE
                         , x_cancellation_code          OUT NOCOPY VARCHAR2
                         , X_Return_Status              OUT NOCOPY VARCHAR2
                         , X_Msg_Count                  OUT NOCOPY NUMBER
                         , X_Msg_Data                   OUT NOCOPY VARCHAR2
);

-------------------------------------------------------------------
-- PROCEDURE
--    lock_evtregs
--
-- PURPOSE
--    Lock a event registration.
--
-- PARAMETERS
--    P_EVENT_REGISTRATION_ID
--    p_object_version: the object_version_number
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------
PROCEDURE lock_evtregs(
   p_api_version_Number		IN  NUMBER,
   p_init_msg_list			IN  VARCHAR2 := FND_API.g_false,
   p_validation_level		IN  NUMBER   := FND_API.g_valid_level_full,

  x_return_status		 OUT NOCOPY VARCHAR2,
  x_msg_count			 OUT NOCOPY NUMBER,
  x_msg_data			 OUT NOCOPY VARCHAR2,

  P_EVENT_REGISTRATION_ID	IN  NUMBER,
  p_object_version			IN  NUMBER
);

PROCEDURE delete_evtRegs(
   p_api_version_number IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2 := FND_API.g_false,
   p_commit            IN  VARCHAR2 := FND_API.g_false,
   p_object_version    IN  NUMBER,
   p_event_registration_id   IN  NUMBER,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2
);

PROCEDURE prioritize_waitlist(
   p_api_version_number         IN   NUMBER,
   p_Init_Msg_List              IN   VARCHAR2   := FND_API.G_FALSE,
   P_Commit                     IN   VARCHAR2   := FND_API.G_FALSE,
   p_override_availability      IN   VARCHAR2   := FND_API.G_FALSE,
   p_event_offer_id     		IN   NUMBER,

   x_return_status              OUT NOCOPY  VARCHAR2,
   x_msg_count                  OUT NOCOPY  NUMBER,
   x_msg_data                   OUT NOCOPY  VARCHAR2
);
-------------------------------------------------------
-- Start of Comments
--
-- PROCEDURE
--  substitute_and_validate
--
-- HISTORY
--    11/16/99  sugupta  Added.
-- PURPOSE
-- called by substitute_enrollee in PUB API..
--  Substitute an enrollee(attendant) for an existing event registration..
-- Who can substitute is NOT verified in this API call...
-- If registrant information is also provided, then the existing
-- 'registrant information' is replaced...
-- 'Attendant information' is mandatory, but for account information...
-- if registrant info is changed, reg_contact id is stored in original_reg_contact_id column..
-------------------------------------------------------------

PROCEDURE substitute_and_validate(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,

    p_confirmation_code	         IN   VARCHAR2,	-- required
    p_attendant_party_id		 IN   NUMBER,	-- required
    p_attendant_contact_id		 IN   NUMBER,	-- required
    p_attendant_account_id       IN   NUMBER,	-- required
    p_registrant_party_id		 IN   NUMBER,
    p_registrant_contact_id		 IN   NUMBER,	-- required
    p_registrant_account_id		 IN   NUMBER,

    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
);
-------------------------------------------------------
-- Start of Comments
--
-- PROCEDURE
--  transfer_and_validate
--
-- HISTORY
--    11/16/99  sugupta  Added.
-- PURPOSE
-- called by transfer_enrollee in PUB API..
--  TRansfer an enrollee(attendant) for an existing event registration..
--  from one event offering to another offering..id's are mandatory..
-- Who can transfer is NOT verified in this API call...
-- Waitlist flag input is mandatory which means that if the other offering is full, is
-- the attendant willing to get waitlisted....
-- if the offering is full, and waitlisting is not wanted or even wailist is full, then
-- the transfer will fail...
-- PAYMENT details are not taken care of in this API call....
--------------------------------------------------------------

PROCEDURE transfer_and_validate(
    P_Api_Version_Number     IN   NUMBER,
    P_Init_Msg_List          IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                 IN   VARCHAR2     := FND_API.G_FALSE,
    p_object_version	 	 IN   NUMBER,
    p_old_confirmation_code	 IN   VARCHAR2,	--required
    p_old_offer_id			 IN   NUMBER,	--required
    p_new_offer_id			 IN   NUMBER,	--required
    p_waitlist_flag			 IN   VARCHAR2,	--required
    p_registrant_account_id		IN  NUMBER,  -- can be null
    p_registrant_party_id		IN	NUMBER,  -- can be null
    p_registrant_contact_id		IN	NUMBER,  -- can be null
    p_attendant_party_id         IN   NUMBER,-- can be null
    p_attendant_contact_id       IN   NUMBER,-- can be null
    x_new_confirmation_code		 OUT NOCOPY  VARCHAR2,
    x_old_cancellation_code		 OUT NOCOPY  VARCHAR2,
    x_new_registration_id        OUT NOCOPY  NUMBER,
    x_old_system_status_code	 OUT NOCOPY  VARCHAR2,
    x_new_system_status_code     OUT NOCOPY  VARCHAR2,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
);
----------------------------------------------------------------------
-- Start of Comments
--
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
-- PURPOSE
--    Validate the event registration colums against criteria, self explanatory
--    with the name of procedures- checking for required fields, unique key,
--   foreign keys, lookup items, flag values .
---------------------------------------------------------------------
PROCEDURE check_evtRegs_items(
   p_evt_Regs_rec        IN  evt_regs_Rec_Type,
   p_validation_mode       IN  VARCHAR2,
   x_return_status       OUT NOCOPY VARCHAR2
);

PROCEDURE check_evtRegs_req_items(
      p_evt_Regs_rec       IN   evt_regs_Rec_Type,
      x_return_status     OUT NOCOPY  VARCHAR2
);

PROCEDURE check_evtRegs_uk_items(
      p_confirmation_code		IN   VARCHAR2,
      p_event_registration_id 	IN   NUMBER,
	  p_validation_mode			IN   VARCHAR2 := JTF_PLSQL_API.g_create,
      x_return_status		 OUT NOCOPY  VARCHAR2
);

PROCEDURE check_evtRegs_fk_items(
      p_evt_Regs_rec      IN    evt_regs_Rec_Type,
	  p_validation_mode   IN   VARCHAR2,
      x_return_status    OUT NOCOPY   VARCHAR2

);

PROCEDURE check_evtRegs_lookup_items(
      p_evt_Regs_rec     IN    evt_regs_Rec_Type,
      x_return_status   OUT NOCOPY   VARCHAR2
);

PROCEDURE check_evtRegs_flag_items(
      p_evt_Regs_rec      IN    evt_regs_Rec_Type,
      x_return_status    OUT NOCOPY   VARCHAR2
);

PROCEDURE  check_evtRegs_record(
      p_evt_Regs_rec      IN    evt_regs_Rec_Type,
      x_return_status    OUT NOCOPY   VARCHAR2
);

-- Start of Comments
--
-- PURPOSE
--    Validate a event registration record.
--
-- NOTES
--    1. P_evt_regs_Rec should be the complete evevt reg record. There
--       should not be any FND_API.g_miss_char/num/date in it.
--
-- End of Comments

PROCEDURE Validate_evtregs(
   p_api_version_number			IN   NUMBER,
   P_Init_Msg_List				IN   VARCHAR2		:= FND_API.G_FALSE,
   P_Validation_level           IN   NUMBER			:= FND_API.G_VALID_LEVEL_FULL,
   P_evt_regs_Rec     			IN   evt_regs_Rec_Type,
   p_validation_mode			IN   VARCHAR2 := JTF_PLSQL_API.g_create,

   X_Return_Status              OUT NOCOPY  VARCHAR2,
   X_Msg_Count                  OUT NOCOPY  NUMBER,
   X_Msg_Data                   OUT NOCOPY  VARCHAR2

);
---------------------------------------------------------------------
-- PROCEDURE
--    init_evtregs_rec
--
-- HISTORY
--    06/29/2000  sugupta  Create.
---------------------------------------------------------------------
PROCEDURE init_evtregs_rec(
   x_evt_regs_rec  OUT NOCOPY  evt_regs_Rec_Type
);
-------------------------------------------------------
-- Start of Comments
--
-- PROCEDURE
--  COMPLETE_EVTREG_REC
--
-- HISTORY
--    11/01/99  sugupta  Created.
-- PURPOSE
--  complete a partial record passed in with col values to be updated
--  with other unchanged col values in existing row in table..
--  to be used in update_evtRegs ..
-------------------------------------------------------------

PROCEDURE COMPLETE_EVTREG_REC(
     P_evt_regs_Rec      IN    evt_regs_Rec_Type,
     x_complete_Rec      OUT NOCOPY   evt_regs_Rec_Type
);

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
--========================================================================

PROCEDURE write_interaction(  p_event_offer_id   IN  NUMBER
                            , p_party_id         IN  NUMBER
                           );


End AMS_EvtRegs_PVT;

 

/
