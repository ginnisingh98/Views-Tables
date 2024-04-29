--------------------------------------------------------
--  DDL for Package OZF_OM_VALIDATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_OM_VALIDATION_PVT" AUTHID CURRENT_USER AS
/* $Header: ozfvomvs.pls 115.0 2003/06/26 05:10:04 mchang noship $ */

TYPE claim_line_item_rec_type IS RECORD
(
   claim_line_index            NUMBER,
   source_object_class         OZF_CLAIM_LINES.source_object_class%TYPE,
   source_object_id            OZF_CLAIM_LINES.source_object_id%TYPE,
   source_object_line_id       OZF_CLAIM_LINES.source_object_line_id%TYPE,
   item_id                     OZF_CLAIM_LINES.item_id%TYPE,
   quantity                    OZF_CLAIM_LINES.quantity%TYPE,
   quantity_uom                OZF_CLAIM_LINES.quantity_uom%TYPE,
   rate                        OZF_CLAIM_LINES.rate%TYPE,
   currency_code               OZF_CLAIM_LINES.currency_code%TYPE
);

TYPE claim_line_item_tbl_type is TABLE OF claim_line_item_rec_type
   INDEX BY BINARY_INTEGER;

------------------------------------------------------------------
-- PROCEDURE
--    Get_Default_Order_Type
--
-- PURPOSE
--
-- PARAMETERS
--    p_x_claim_line_rec: claim line record.
--
-- NOTES
------------------------------------------------------------------
PROCEDURE Get_Default_Order_Type(
    p_api_version           IN  NUMBER
   ,p_init_msg_list         IN  VARCHAR2 := FND_API.g_false
   ,p_validation_level      IN  NUMBER   := FND_API.g_valid_level_full

   ,x_return_status         OUT NOCOPY VARCHAR2
   ,x_msg_data              OUT NOCOPY VARCHAR2
   ,x_msg_count             OUT NOCOPY NUMBER

   ,p_reason_code_id        IN  NUMBER
   ,p_claim_type_id         IN  NUMBER
   ,p_set_of_books_id       IN  NUMBER
   ,x_order_type_id         OUT NOCOPY NUMBER
);


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
--    Validate claim line record for RMA settlement.
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
);

------------------------------------------------------------------
-- PROCEDURE
--    Validate_Claim_Line_Tbl
--
-- PURPOSE
--    Validate claim line record for RMA settlement.
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
--    Complete_RMA_Validation
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
PROCEDURE Complete_RMA_Validation(
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.g_false
   ,p_validation_level       IN    NUMBER   := FND_API.g_valid_level_full

   ,x_return_status          OUT   NOCOPY VARCHAR2
   ,x_msg_data               OUT   NOCOPY VARCHAR2
   ,x_msg_count              OUT   NOCOPY NUMBER

   ,p_claim_rec              IN    OZF_CLAIM_PVT.claim_rec_type
   ,x_claim_rec              OUT   NOCOPY OZF_CLAIM_PVT.claim_rec_type
);


END OZF_OM_VALIDATION_PVT;

 

/
