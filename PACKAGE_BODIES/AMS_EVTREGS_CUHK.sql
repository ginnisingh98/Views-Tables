--------------------------------------------------------
--  DDL for Package Body AMS_EVTREGS_CUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_EVTREGS_CUHK" AS
/*$Header: amscregb.pls 115.3 2002/11/16 01:44:07 dbiswas ship $*/

-----------------------------------------------------------
-- PROCEDURE
--    Register_pre
--
-- HISTORY
--    10-Apr-2002  gmadana  Created.
------------------------------------------------------------

PROCEDURE Register_pre(
   x_evt_regs_Rec   IN OUT NOCOPY AMS_EvtRegs_Pvt.evt_regs_Rec_Type,
   x_return_status  OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
   -- customer to add the customization codes here
   -- for pre processing
END;

-----------------------------------------------------------
-- PROCEDURE
--    Register_post
--
-- HISTORY
--    10-Apr-2002  gmadana  Created.
------------------------------------------------------------
PROCEDURE Register_post(
   p_evt_regs_Rec           IN  AMS_EvtRegs_Pvt.evt_regs_Rec_Type,
   x_return_status          OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
   -- customer to add the customization codes here
   -- for post processing
END;


-----------------------------------------------------------
-- PROCEDURE
--    delete_Registration_pre
--
-- PURPOSE
--    Customer pre-processing for delete_evtregs.
------------------------------------------------------------
PROCEDURE delete_Registration_pre(
   x_event_registration_id  IN OUT NOCOPY NUMBER,
   x_object_version         IN OUT NOCOPY NUMBER,
   x_return_status          OUT NOCOPY    VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
   -- customer to add the customization codes here
   -- for pre processing
END;

-----------------------------------------------------------
-- PROCEDURE
--   delete_Registration_post
--
-- PURPOSE
--    Customer post-processing for delete_evtregs.
------------------------------------------------------------
PROCEDURE delete_Registration_post(
   p_event_registration_id  IN  NUMBER,
   p_object_version         IN  NUMBER,
   x_return_status          OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
   -- customer to add the customization codes here
   -- for post processing
END;


-----------------------------------------------------------
-- PROCEDURE
--    Update_registration_pre
--
-- PURPOSE
--    Customer pre-processing for update_evtregs.
------------------------------------------------------------
PROCEDURE Update_registration_pre(
   x_evt_regs_Rec   IN OUT NOCOPY AMS_EvtRegs_Pvt.evt_regs_Rec_Type,
   x_return_status  OUT NOCOPY    VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
   -- customer to add the customization codes here
   -- for pre processing
END;


-----------------------------------------------------------
-- PROCEDURE
--    Update_registration_post
--
-- PURPOSE
--    Customer post-processing for update_evtregs.
------------------------------------------------------------
PROCEDURE Update_registration_post(
   p_evt_regs_Rec   IN  AMS_EvtRegs_Pvt.evt_regs_Rec_Type,
   x_return_status  OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
   -- customer to add the customization codes here
   -- for post processing
END;


-----------------------------------------------------------
-- PROCEDURE
--    prioritize_reg_wailist_pre
--
-- PURPOSE
--    Customer pre-processing for prioritize_reg_wailist.
------------------------------------------------------------
PROCEDURE prioritize_reg_wailist_pre(
   x_event_offer_id IN OUT NOCOPY NUMBER,
   x_return_status  OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
   -- customer to add the customization codes here
   -- for pre processing
END;


-----------------------------------------------------------
-- PROCEDURE
--    prioritize_reg_wailist_post
--
-- PURPOSE
--    Customer post-processing for prioritize_reg_wailist.
------------------------------------------------------------
PROCEDURE prioritize_reg_wailist_post(
   p_event_offer_id IN  NUMBER,
   x_return_status  OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
   -- customer to add the customization codes here
   -- for post processing
END;

-----------------------------------------------------------
-- PROCEDURE
--    Cancel_Registration_pre
--
-- PURPOSE
--    Customer pre-processing for Cancel_Registration.
------------------------------------------------------------
PROCEDURE Cancel_Registration_pre(
    p_object_version             IN   NUMBER,
    p_event_offer_id             IN   NUMBER,
    p_registrant_party_id        IN   NUMBER,
    p_confirmation_code          IN   VARCHAR2,
    p_registration_group_id      IN   NUMBER,
    p_cancellation_reason_code   IN   VARCHAR2,
    x_cancellation_code          OUT NOCOPY  VARCHAR2,
    X_Return_Status              OUT NOCOPY  VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
   -- customer to add the customization codes here
   -- for pre processing
END;

-----------------------------------------------------------
-- PROCEDURE
--    Cancel_Registration_post
--
-- PURPOSE
--    Customer post-processing for Cancel_Registration.
------------------------------------------------------------
PROCEDURE Cancel_Registration_post(
    p_object_version             IN   NUMBER,
    p_event_offer_id             IN   NUMBER,
    p_registrant_party_id        IN   NUMBER,
    p_confirmation_code          IN   VARCHAR2,
    p_registration_group_id      IN   NUMBER,
    p_cancellation_reason_code   IN   VARCHAR2,
    x_cancellation_code          OUT NOCOPY  VARCHAR2,
    X_Return_Status              OUT NOCOPY  VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
   -- customer to add the customization codes here
   -- for post processing
END;

-----------------------------------------------------------
-- PROCEDURE
--    substitute_enrollee_pre
--
-- PURPOSE
--    Customer pre-processing for substitute_enrollee.
------------------------------------------------------------
PROCEDURE substitute_enrollee_pre(
    p_confirmation_code          IN   VARCHAR2,   --required
    p_attendant_party_id         IN   NUMBER,   --required
    p_attendant_contact_id       IN   NUMBER,   --required
    p_attendant_account_id       IN   NUMBER,
    p_registrant_party_id        IN   NUMBER,
    p_registrant_contact_id      IN   NUMBER,   --required
    p_registrant_account_id      IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
   -- customer to add the customization codes here
   -- for pre processing
END;

-----------------------------------------------------------
-- PROCEDURE
--    substitute_enrollee_post
--
-- PURPOSE
--    Customer post-processing for substitute_enrollee.
------------------------------------------------------------
PROCEDURE substitute_enrollee_post(
    p_confirmation_code          IN   VARCHAR2,   --required
    p_attendant_party_id         IN   NUMBER,   --required
    p_attendant_contact_id       IN   NUMBER,   --required
    p_attendant_account_id       IN   NUMBER,
    p_registrant_party_id        IN   NUMBER,
    p_registrant_contact_id      IN   NUMBER,   --required
    p_registrant_account_id      IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
   -- customer to add the customization codes here
   -- for post processing
END;

-----------------------------------------------------------
-- PROCEDURE
--    transfer_enrollee_pre
--
-- PURPOSE
--    Customer pre-processing for transfer_enrollee.
------------------------------------------------------------

PROCEDURE transfer_enrollee_pre(
    p_object_version             IN   NUMBER,
    p_old_confirmation_code      IN   VARCHAR2,
    p_old_offer_id               IN   NUMBER,
    p_new_offer_id               IN   NUMBER,
    p_waitlist_flag              IN   VARCHAR2,
    p_registrant_account_id      IN   NUMBER,
    p_registrant_party_id        IN   NUMBER,
    p_registrant_contact_id      IN   NUMBER,
    p_attendant_party_id         IN   NUMBER,
    p_attendant_contact_id       IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
   -- customer to add the customization codes here
   -- for pre processing
END;

-----------------------------------------------------------
-- PROCEDURE
--    transfer_enrollee_post
--
-- PURPOSE
--    Customer post-processing for transfer_enrollee.
------------------------------------------------------------
PROCEDURE transfer_enrollee_post(
    p_object_version             IN   NUMBER,
    p_old_confirmation_code      IN   VARCHAR2,
    p_old_offer_id               IN   NUMBER,
    p_new_offer_id               IN   NUMBER,
    p_waitlist_flag              IN   VARCHAR2,
    p_registrant_account_id      IN   NUMBER,
    p_registrant_party_id        IN   NUMBER,
    p_registrant_contact_id      IN   NUMBER,
    p_attendant_party_id         IN   NUMBER,
    p_attendant_contact_id       IN   NUMBER,
    x_Return_Status              OUT NOCOPY  VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
   -- customer to add the customization codes here
   -- for post processing
END;

End AMS_EvtRegs_CUHK;

/
