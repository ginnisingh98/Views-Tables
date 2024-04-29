--------------------------------------------------------
--  DDL for Package OZF_CLAIM_SETTLEMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_CLAIM_SETTLEMENT_PVT" AUTHID CURRENT_USER AS
/* $Header: ozfvcsts.pls 120.1 2005/08/09 06:39:11 appldev ship $ */

---------------------------------------------------------------------
-- PROCEDURE
--    Check_Transaction_Balance
--
-- PURPOSE
--    Check whether the original transaction balance is changed.
--
-- PARAMETERS
--    p_customer_trx_id
--    p_claim_amount
--    p_claim_number
--    x_return_status
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Check_Transaction_Balance(
    p_customer_trx_id        IN    NUMBER
   ,p_claim_amount           IN    NUMBER
   ,p_claim_number           IN    VARCHAR2
   ,x_return_status          OUT NOCOPY   VARCHAR2
) ;

---------------------------------------------------------------------
-- PROCEDURE
--    Complete_Settlement
--
-- PURPOSE
--    Complete settlement record is done in this procedure.
--
-- PARAMETERS
--    p_claim_rec           : OZF_CLAIM_PVT.claim_rec_type
--    x_claim_rec           : OZF_CLAIM_PVT.claim_rec_type
--    x_return_status
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Complete_Settlement(
    p_api_version            IN  NUMBER
   ,p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL

   ,x_return_status          OUT NOCOPY VARCHAR2
   ,x_msg_data               OUT NOCOPY VARCHAR2
   ,x_msg_count              OUT NOCOPY NUMBER

   ,p_claim_rec              IN  OZF_CLAIM_PVT.claim_rec_type
   ,x_claim_rec              OUT NOCOPY OZF_CLAIM_PVT.claim_rec_type
);


---------------------------------------------------------------------
-- PROCEDURE
--   Settle_Claim
--
-- NOTES
--
-- HISTORY
--   10-AUG-2001  mchang  Create.
---------------------------------------------------------------------
PROCEDURE Settle_Claim(
    p_api_version            IN  NUMBER
   ,p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL

   ,x_return_status          OUT NOCOPY VARCHAR2
   ,x_msg_data               OUT NOCOPY VARCHAR2
   ,x_msg_count              OUT NOCOPY NUMBER

   ,p_claim_id               IN  NUMBER
   ,p_curr_status            IN  VARCHAR2
   ,p_prev_status            IN  VARCHAR2
);

---------------------------------------------------------------------
-- PROCEDURE
--   Raise_Business_Event
--
-- NOTES
--
-- HISTORY
--   10-OCT-2003  mchang  Create.
---------------------------------------------------------------------
PROCEDURE Raise_Business_Event(
    p_api_version            IN  NUMBER
   ,p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL

   ,x_return_status          OUT NOCOPY VARCHAR2
   ,x_msg_data               OUT NOCOPY VARCHAR2
   ,x_msg_count              OUT NOCOPY NUMBER

   ,p_claim_id               IN  NUMBER
   ,p_old_status             IN  VARCHAR2
   ,p_new_status             IN  VARCHAR2
   ,p_event_name             IN  VARCHAR2
);


---------------------------------------------------------------------
-- PROCEDURE
--   Claim_Approval_Required
--
-- NOTES
--
-- HISTORY
--   8-AUG-2005  SSHIVALI  Create.
---------------------------------------------------------------------
PROCEDURE Claim_Approval_Required(
    p_claim_id                   IN  NUMBER

   ,x_return_status              OUT NOCOPY VARCHAR2
   ,x_msg_data                   OUT NOCOPY VARCHAR2
   ,x_msg_count                  OUT NOCOPY NUMBER

   ,x_approval_require           OUT NOCOPY VARCHAR2
);
END OZF_CLAIM_SETTLEMENT_PVT;

 

/
