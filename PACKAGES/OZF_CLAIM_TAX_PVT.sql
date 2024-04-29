--------------------------------------------------------
--  DDL for Package OZF_CLAIM_TAX_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_CLAIM_TAX_PVT" AUTHID CURRENT_USER AS
/* $Header: ozfvtaxs.pls 120.2 2005/09/15 22:45:31 appldev ship $ */


/*=======================================================================*
 | PROCEDURE
 |    Validate_Claim_For_Tax
 |
 | NOTES
 |    This API is called from OZF_CLAIM_PVT and inits the Global Tax Structure
 |
 | HISTORY
 *=======================================================================*/
PROCEDURE Validate_Claim_For_Tax(
    p_api_version           IN  NUMBER
   ,p_init_msg_list         IN  VARCHAR2 := FND_API.g_false
   ,p_validation_level    IN  NUMBER   := FND_API.g_valid_level_full

   ,x_return_status       OUT NOCOPY VARCHAR2
   ,x_msg_data             OUT NOCOPY VARCHAR2
   ,x_msg_count           OUT NOCOPY NUMBER

   ,p_claim_rec            IN  OZF_CLAIM_PVT.claim_rec_type
)  ;


------------------------------------------------------------------
-- PROCEDURE
--    Calculate_Claim_Line_AR_Tax
--
-- PURPOSE
--
-- PARAMETERS
--
--
-- NOTES
------------------------------------------------------------------
PROCEDURE Calculate_Claim_Line_Tax(
    p_api_version           IN  NUMBER
   ,p_init_msg_list         IN  VARCHAR2 := FND_API.g_false
   ,p_validation_level      IN  NUMBER   := FND_API.g_valid_level_full

   ,x_return_status         OUT NOCOPY VARCHAR2
   ,x_msg_data              OUT NOCOPY VARCHAR2
   ,x_msg_count             OUT NOCOPY NUMBER

   ,p_x_claim_line_rec      IN OUT NOCOPY OZF_CLAIM_LINE_PVT.claim_line_rec_type
);

END OZF_CLAIM_TAX_PVT;

 

/
