--------------------------------------------------------
--  DDL for Package OZF_AR_VALIDATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_AR_VALIDATION_PVT" AUTHID CURRENT_USER AS
/* $Header: ozfvarvs.pls 120.1 2005/08/19 03:36:20 appldev ship $ */

------------------------------------------------------------------
-- PROCEDURE
--    Pay_Deduction
--
-- PURPOSE
--    An API to handle all kinds of payment for deduction.
--
-- PARAMETERS
--    p_claim_id: claim identifier.
--
-- NOTES
------------------------------------------------------------------
PROCEDURE Complete_AR_Validation(
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.g_false
   ,p_commit                 IN    VARCHAR2 := FND_API.g_false
   ,p_validation_level       IN    NUMBER   := FND_API.g_valid_level_full

   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER

   ,p_claim_rec              IN    OZF_CLAIM_PVT.claim_rec_type
);

/*=======================================================================*
 | PROCEDURE
 |    Validate_CreditTo_Information
 |
 | NOTES
 |
 | HISTORY
 |    03-May-2005   Sahana   Created for Bug4308173
 *=======================================================================*/

PROCEDURE  Validate_CreditTo_Information(
    p_claim_rec             IN  OZF_CLAIM_PVT.claim_rec_type
   ,p_invoice_id            IN  NUMBER DEFAULT NULL
   ,x_return_status         OUT NOCOPY VARCHAR2
);

/*=======================================================================*
 | Function
 |    Check_to_Process_SETL_WF
 |
 |
 | NOTES
 |   When settling by invoice creditmemo, settlement should be done by
 |   receivable role in the following cases:
 |   1. Different credit types are mixed.
 |   2. Credit is not to source invoice.
 |
 |
 | HISTORY
 |    16-May-2005  Sahana  Created for Bug4308173
 |
 *=======================================================================*/
FUNCTION Check_to_Process_SETL_WF(
    p_claim_rec              IN    OZF_CLAIM_PVT.claim_rec_type
   ,x_return_status          OUT NOCOPY   VARCHAR2
) RETURN BOOLEAN;

END OZF_AR_VALIDATION_PVT;

 

/
