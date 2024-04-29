--------------------------------------------------------
--  DDL for Package AMS_EVTREGS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_EVTREGS_PUB" AUTHID CURRENT_USER as
/*$Header: amspregs.pls 115.18 2003/01/28 00:46:15 dbiswas ship $*/
-- Start of Comments
-- Package name     : AMS_EvtRegs_PUB
-- Purpose          : Public API for Event Registrations
-- History          :  Created sugupta 10/16/99
--    12-MAR-2002    dcastlem    Added support for general Public API
--                               (AMS_Registrants_PUB)
--    27-Jan-2003    dbiswas     Modified p_block_fulfillment = 'F' bug 2769257
-- NOTE             :
-- End of Comments

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Register
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       P_evt_regs_Rec     IN AMS_EVTREGS_PVT.evt_regs_Rec_Type  Required
--
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_event_registration_id   OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--
--   End of Comments
--
PROCEDURE Register(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_evt_regs_Rec				 IN    AMS_EvtRegs_PVT.evt_regs_Rec_Type,
    p_block_fulfillment          IN   VARCHAR2     := 'F',
    x_event_registration_id      OUT NOCOPY  NUMBER,
    x_confirmation_code			 OUT NOCOPY  VARCHAR2,
    x_system_status_code		 OUT NOCOPY  VARCHAR2,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
);
---------------------------------------------------------------------
-- PROCEDURE
--    init_reg_rec
--
-- HISTORY
--    06/29/2000  sugupta  Create.
-- Note: Call this method to initialize the reg rec before calling Update_registration
---------------------------------------------------------------------
PROCEDURE init_reg_rec(
   x_evt_regs_rec  OUT NOCOPY   AMS_EvtRegs_PVT.evt_regs_Rec_Type
);

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_registration
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       P_evt_regs_Rec     IN AMS_EvtRegs_PVT.evt_regs_Rec_Type  Required
--
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--
--   End of Comments
--
PROCEDURE Update_registration(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_evt_regs_Rec				 IN    AMS_EvtRegs_PVT.evt_regs_Rec_Type,
    p_block_fulfillment          IN   VARCHAR2     := 'F',
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
);

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Cancel_Registration
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit            IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_event_offer_id     IN  NUMBER  Required
--       p_registration_number IN NUMBER Required
--       p_registration_group_id  IN NUMBER Optional
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--
--   modified sugupta 06/21/2000 x_cancellation_code shud be varchar2
--   End of Comments
--
PROCEDURE Cancel_Registration(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_object_version             IN   NUMBER,
    p_event_offer_id             IN   NUMBER,
    p_registrant_party_id	     IN   NUMBER,
    p_confirmation_code		     IN   VARCHAR2,
    p_registration_group_id      IN   NUMBER,
    p_cancellation_reason_code   IN   VARCHAR2,
    p_block_fulfillment          IN   VARCHAR2     := 'F',
    x_cancellation_code		   OUT NOCOPY  VARCHAR2,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
);

PROCEDURE delete_Registration(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_object_version		   IN   NUMBER,
    p_event_registration_id	   IN   NUMBER,

    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
);
-------------------------------------------------------
-- Start of Comments
--
-- PROCEDURE
--  prioritize_reg_wailist
--
-- HISTORY
--    11/29/99  sugupta  Added.
-- PURPOSE
--  Registrations for an event can have a wailist. This api call will look to see if it can
-- upgrade a reg status from wailtlisted to registered, if any cancellations or event
-- details have been changed.
-- note that cancelling a registration automatically calls this API internally to
-- upgrade the reg statuses in real time.
-------------------------------------------------------------

PROCEDURE prioritize_reg_wailist(
   p_api_version_number         IN   NUMBER,
   p_Init_Msg_List              IN   VARCHAR2   := FND_API.G_FALSE,
   P_Commit                     IN   VARCHAR2   := FND_API.G_FALSE,
   p_event_offer_id     		IN   NUMBER,

   x_return_status              OUT NOCOPY  VARCHAR2,
   x_msg_count                  OUT NOCOPY  NUMBER,
   x_msg_data                   OUT NOCOPY  VARCHAR2
);

-------------------------------------------------------
-- Start of Comments
--
-- PROCEDURE
--  substitute_enrollee
--
-- HISTORY
--    11/16/99  sugupta  Added.
-- PURPOSE
--  Substitute an enrollee(attendant) for an existing event registration..
-- Who can substitute is NOT verified in this API call...
-- If registrant information is also provided, then the existing
-- 'registrant information' is replaced...
-- 'Attendant information' is mandatory, but for account information...
-- if registrant info is changed, reg_contact id is stored in original_reg_contact_id column..
-------------------------------------------------------------

PROCEDURE substitute_enrollee(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,

    p_confirmation_code	         IN   VARCHAR2,	--required
    p_attendant_party_id		 IN   NUMBER,	--required
    p_attendant_contact_id	     IN   NUMBER,	--required
    p_attendant_account_id       IN   NUMBER,
    p_registrant_party_id	     IN   NUMBER,
    p_registrant_contact_id	     IN   NUMBER,	--required
    p_registrant_account_id	     IN   NUMBER,

    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
);

-------------------------------------------------------
-- Start of Comments
--
-- PROCEDURE
--  transfer_enrollee
--
-- HISTORY
--    11/16/99  sugupta  Added.
-- PURPOSE
--  Transfer an enrollee(attendant) for an existing event registration
--  from one event offering to another offer id...
-- Who can transfer is NOT validated in this API call...
-- Waitlist flag input is mandatory which means if the other offering is full and
-- the attendant is willing to get waitlisted....
-- if the offering is full, and waitlisting is not wanted or even wailist is full, then
-- the transfer will fail...
-- PAYMENT details are not taken care of in this API call....
-------------------------------------------------------------

PROCEDURE transfer_enrollee(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_object_version	 		 IN   NUMBER,
    p_old_confirmation_code		 IN   VARCHAR2,	--required
    p_old_offer_id				 IN   NUMBER,	--required
    p_new_offer_id				 IN   NUMBER,	--required
    p_waitlist_flag				 IN   VARCHAR2,	--required
    p_registrant_account_id		 IN   NUMBER,  -- can be null
    p_registrant_party_id		 IN	  NUMBER,  -- can be null
    p_registrant_contact_id		 IN	  NUMBER,  -- can be null
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

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Get_Registration_details
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--
--       p_return_tot_count        IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_event_registration_id   IN   NUMBER   Required
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--       x_returned_rec_count      OUT   NUMBER
--       x_tot_rec_count           OUT   NUMBER
--
-- Note: will be implemented as a view......
--   End of Comments
--

FUNCTION  GET_Reg_Rec  RETURN  AMS_EvtRegs_PVT.evt_regs_Rec_Type;

End AMS_EvtRegs_PUB;

 

/
