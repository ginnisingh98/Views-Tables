--------------------------------------------------------
--  DDL for Package OZF_CLAIM_SETTLEMENT_VAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_CLAIM_SETTLEMENT_VAL_PVT" AUTHID CURRENT_USER AS
/* $Header: ozfvcsvs.pls 115.1 2003/11/11 03:12:13 mchang noship $ */

------------------------------------------------------------------
-- PROCEDURE
--    Default_Claim_Line
--
-- PURPOSE
--
-- PARAMETERS
--    p_x_claim_line_rec: claim line record.
--
-- NOTES
------------------------------------------------------------------
PROCEDURE Default_Claim_Line(
    p_api_version           IN  NUMBER
   ,p_init_msg_list         IN  VARCHAR2 := FND_API.g_false
   ,p_validation_level      IN  NUMBER   := FND_API.g_valid_level_full

   ,x_return_status         OUT NOCOPY VARCHAR2
   ,x_msg_data              OUT NOCOPY VARCHAR2
   ,x_msg_count             OUT NOCOPY NUMBER

   ,p_x_claim_line_rec      IN OUT NOCOPY OZF_CLAIM_LINE_PVT.claim_line_rec_type
   ,p_def_from_tbl_flag     IN  VARCHAR2 := FND_API.g_false
);


------------------------------------------------------------------
-- PROCEDURE
--    Default_Claim_Line_Tbl
--
-- PURPOSE
--
-- PARAMETERS
--    p_x_claim_line_tbl: claim line table.
--
-- NOTES
------------------------------------------------------------------
PROCEDURE Default_Claim_Line_Tbl(
    p_api_version           IN  NUMBER
   ,p_init_msg_list         IN  VARCHAR2 := FND_API.g_false
   ,p_validation_level      IN  NUMBER   := FND_API.g_valid_level_full

   ,x_return_status         OUT NOCOPY VARCHAR2
   ,x_msg_data              OUT NOCOPY VARCHAR2
   ,x_msg_count             OUT NOCOPY NUMBER

   ,p_x_claim_line_tbl      IN OUT NOCOPY OZF_CLAIM_LINE_PVT.claim_line_tbl_type
);


------------------------------------------------------------------
-- PROCEDURE
--    Validate_Claim_Line
--
-- PURPOSE
--    Validate claim line record for settlement purpose.
--
-- PARAMETERS
--    p_claim_line_rec: claim line record.
--
-- NOTES
------------------------------------------------------------------
PROCEDURE Validate_Claim_Line(
    p_api_version           IN  NUMBER
   ,p_init_msg_list         IN  VARCHAR2 := FND_API.g_false
   ,p_validation_level      IN  NUMBER   := FND_API.g_valid_level_full

   ,x_return_status         OUT NOCOPY VARCHAR2
   ,x_msg_data              OUT NOCOPY VARCHAR2
   ,x_msg_count             OUT NOCOPY NUMBER

   ,p_claim_line_rec        IN  OZF_CLAIM_LINE_PVT.claim_line_rec_type
   ,p_val_from_tbl_flag     IN  VARCHAR2 := FND_API.g_false
);


------------------------------------------------------------------
-- PROCEDURE
--    Validate_Claim_Line_Tbl
--
-- PURPOSE
--    Validate claim line table for settlement purpose.
--
-- PARAMETERS
--    p_claim_line_tbl: claim line table.
--
-- NOTES
------------------------------------------------------------------
PROCEDURE Validate_Claim_Line_Tbl(
    p_api_version           IN  NUMBER
   ,p_init_msg_list         IN  VARCHAR2 := FND_API.g_false
   ,p_validation_level      IN  NUMBER   := FND_API.g_valid_level_full

   ,x_return_status         OUT NOCOPY VARCHAR2
   ,x_msg_data              OUT NOCOPY VARCHAR2
   ,x_msg_count             OUT NOCOPY NUMBER

   ,p_claim_line_tbl        IN  OZF_CLAIM_LINE_PVT.claim_line_tbl_type
);


------------------------------------------------------------------
-- PROCEDURE
--    Complete_Claim_Validation
--
-- PURPOSE
--    Validate claim record for RMA settlement when claim status
--    change to COMPLETE.
--
-- PARAMETERS
--    p_claim_rec: claim record.
--
-- NOTES
------------------------------------------------------------------
PROCEDURE Complete_Claim_Validation(
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.g_false
   ,p_validation_level       IN    NUMBER   := FND_API.g_valid_level_full

   ,x_return_status          OUT   NOCOPY VARCHAR2
   ,x_msg_data               OUT   NOCOPY VARCHAR2
   ,x_msg_count              OUT   NOCOPY NUMBER

   ,p_claim_rec              IN    OZF_CLAIM_PVT.claim_rec_type
   ,x_claim_rec              OUT   NOCOPY OZF_CLAIM_PVT.claim_rec_type
);


------------------------------------------------------------------
-- PROCEDURE
--    Complete_Claim
--
-- PURPOSE
--    Complete claim record for settlement purpose.
--
-- PARAMETERS
--    p_claim_rec: claim record.
--
-- NOTES
------------------------------------------------------------------
PROCEDURE Complete_Claim(
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.g_false
   ,p_validation_level       IN    NUMBER   := FND_API.g_valid_level_full

   ,x_return_status          OUT   NOCOPY VARCHAR2
   ,x_msg_data               OUT   NOCOPY VARCHAR2
   ,x_msg_count              OUT   NOCOPY NUMBER

   ,p_x_claim_rec            IN OUT NOCOPY OZF_CLAIM_PVT.claim_rec_type
);

FUNCTION gl_date_in_open(
    p_application_id        IN NUMBER
   ,p_claim_id              IN NUMBER
)
RETURN BOOLEAN;

END OZF_CLAIM_SETTLEMENT_VAL_PVT;

 

/
