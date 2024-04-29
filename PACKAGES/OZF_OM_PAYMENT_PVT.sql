--------------------------------------------------------
--  DDL for Package OZF_OM_PAYMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_OM_PAYMENT_PVT" AUTHID CURRENT_USER AS
/* $Header: ozfvomps.pls 115.0 2003/06/26 05:09:58 mchang noship $ */

------------------------------------------------------------------
-- PROCEDURE
--    Create_OM_Payment
--
-- PURPOSE
--    An API to handle RMA settlement scenario.
--
-- PARAMETERS
--    p_claim_id: claim identifier.
--
-- NOTES
------------------------------------------------------------------
PROCEDURE Create_OM_Payment(
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.g_false
   ,p_commit                 IN    VARCHAR2 := FND_API.g_false
   ,p_validation_level       IN    NUMBER   := FND_API.g_valid_level_full

   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER

   ,p_claim_id               IN    NUMBER
);


------------------------------------------------------------------
-- PROCEDURE
--    Complete_RMA_Order
--
-- PURPOSE
--    An API to create a RMA order in Order Management.
--
-- PARAMETERS
--    p_claim_rec: claim record.
--    p_claim_line_tbl: claim line table.
--
-- NOTES
------------------------------------------------------------------
PROCEDURE Complete_RMA_Order(
    p_x_claim_rec            IN OUT NOCOPY  OZF_CLAIM_PVT.claim_rec_type
   ,p_claim_line_tbl         IN    OZF_CLAIM_LINE_PVT.claim_line_tbl_type

   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
);


------------------------------------------------------------------
-- PROCEDURE
--    Book_RMA_Order
--
-- PURPOSE
--    An API to book a RMA order in Order Management.
--
-- PARAMETERS
--    p_claim_rec: claim record.
--
-- NOTES
------------------------------------------------------------------
PROCEDURE Book_RMA_Order(
    p_claim_rec              IN    OZF_CLAIM_PVT.claim_rec_type
   ,p_claim_line_tbl         IN    OZF_CLAIM_LINE_PVT.claim_line_tbl_type

   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
);

------------------------------------------------------------------
-- PROCEDURE
--    Query_Claim
--
-- PURPOSE
--
--
-- PARAMETERS
--    p_claim_id: claim identifier.
--
-- NOTES
------------------------------------------------------------------
PROCEDURE Query_Claim(
    p_claim_id           IN    NUMBER
   ,x_claim_rec          OUT NOCOPY   OZF_Claim_PVT.claim_rec_type
   ,x_return_status      OUT NOCOPY   VARCHAR2
);

------------------------------------------------------------------
-- PROCEDURE
--    Query_Claim
--
-- PURPOSE
--    An API to book a RMA order in Order Management.
--
-- PARAMETERS
--    p_claim_id: claim identifier.
--
-- NOTES
------------------------------------------------------------------
PROCEDURE Query_Claim_Line(
    p_claim_id           IN    NUMBER
   ,x_claim_line_tbl     OUT NOCOPY   OZF_CLAIM_LINE_PVT.claim_line_tbl_type
   ,x_return_status      OUT NOCOPY   VARCHAR2
);

END OZF_OM_PAYMENT_PVT;

 

/
