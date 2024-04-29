--------------------------------------------------------
--  DDL for Package OZF_SETTLEMENT_DOC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_SETTLEMENT_DOC_PVT" AUTHID CURRENT_USER AS
/* $Header: ozfvcsds.pls 120.2 2005/12/02 04:59:47 kdhulipa ship $ */

-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;

TYPE settlement_doc_rec_type IS RECORD
(
   settlement_doc_id               NUMBER       ,
   object_version_number           NUMBER       ,
   last_update_date                DATE         ,
   last_updated_by                 NUMBER       ,
   creation_date                   DATE         ,
   created_by                      NUMBER       ,
   last_update_login               NUMBER       ,
   request_id                      NUMBER       ,
   program_application_id          NUMBER       ,
   program_update_date             DATE         ,
   program_id                      NUMBER       ,
   created_from                    VARCHAR2(30) ,
   claim_id                        NUMBER       ,
   claim_line_id                   NUMBER       ,
   payment_method                  VARCHAR2(30) ,
   settlement_id                   NUMBER       ,
   settlement_type                 VARCHAR2(30) ,
   settlement_type_id              NUMBER       ,
   settlement_number               VARCHAR2(30) ,
   settlement_date                 DATE         ,
   settlement_amount               NUMBER       ,
   settlement_acctd_amount         NUMBER       ,
   status_code                     VARCHAR2(30) ,
   attribute_category              VARCHAR2(30) ,
   attribute1                      VARCHAR2(150),
   attribute2                      VARCHAR2(150),
   attribute3                      VARCHAR2(150),
   attribute4                      VARCHAR2(150),
   attribute5                      VARCHAR2(150),
   attribute6                      VARCHAR2(150),
   attribute7                      VARCHAR2(150),
   attribute8                      VARCHAR2(150),
   attribute9                      VARCHAR2(150),
   attribute10                     VARCHAR2(150),
   attribute11                     VARCHAR2(150),
   attribute12                     VARCHAR2(150),
   attribute13                     VARCHAR2(150),
   attribute14                     VARCHAR2(150),
   attribute15                     VARCHAR2(150),
   org_id                          NUMBER       ,
   discount_taken                  NUMBER       ,
   payment_reference_id            NUMBER       ,
   payment_reference_number        VARCHAR2(30) ,
   payment_status                  VARCHAR2(30) ,
   group_claim_id                  NUMBER       ,
   gl_date                         DATE         ,
   wo_rec_trx_id                   NUMBER
);

g_miss_settlement_doc_rec          settlement_doc_rec_type;
TYPE settlement_doc_tbl_type IS TABLE OF settlement_doc_rec_type
INDEX BY BINARY_INTEGER;
g_miss_settlement_doc_tbl          settlement_doc_tbl_type;


------------------------------------------------------------------
-- Update_Payment_Detail
--    Update_Payment_Detail
--
-- PURPOSE
--    Update claim payment detail for deduction settled in AR.
--
-- PARAMETERS
--    p_claim_id: claim identifier.
--
-- NOTES
------------------------------------------------------------------
PROCEDURE Update_Payment_Detail(
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.g_false
   ,p_commit                 IN    VARCHAR2 := FND_API.g_false
   ,p_validation_level       IN    NUMBER   := FND_API.g_valid_level_full

   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER

   ,p_claim_id               IN    NUMBER
   ,p_payment_method         IN    VARCHAR2
   ,p_deduction_type         IN    VARCHAR2
   ,p_cash_receipt_id        IN    NUMBER   := NULL
   ,p_customer_trx_id        IN    NUMBER   := NULL
   ,p_adjust_id              IN    NUMBER   := NULL
   ,p_settlement_doc_id      IN    NUMBER   := NULL

   ,p_settlement_mode        IN    VARCHAR2 := NULL
);


PROCEDURE Update_Payment_Detail(
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.g_false
   ,p_commit                 IN    VARCHAR2 := FND_API.g_false
   ,p_validation_level       IN    NUMBER   := FND_API.g_valid_level_full

   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER

   ,p_claim_id               IN    NUMBER
   ,p_payment_method         IN    VARCHAR2
   ,p_deduction_type         IN    VARCHAR2
   ,p_cash_receipt_id        IN    NUMBER   := NULL
   ,p_customer_trx_id        IN    NUMBER   := NULL
   ,p_adjust_id              IN    NUMBER   := NULL
   ,p_settlement_doc_id      IN    NUMBER   := NULL

   ,p_settlement_mode        IN    VARCHAR2 := NULL
   ,p_settlement_amount                 IN    NUMBER
);


---------------------------------------------------------------------
-- PROCEDURE
--    Update_Claim_From_Settlement
--
-- PURPOSE
--    Update Claim Status and payment_status
--    When Claim Status is 'CLOSED', Update fund paid amount to
--    sum of utilizations associated to a claim.
--
-- PARAMETERS
--    p_claim_id                    claim_id
--    p_object_version_number       claim object_version_number
--    p_status_code                 claim status code
--    p_payment_status              claim payment_status
---------------------------------------------------------------------
PROCEDURE Update_Claim_From_Settlement(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.g_false,
    p_commit                     IN   VARCHAR2     := FND_API.g_false,
    p_validation_level           IN   NUMBER       := FND_API.g_valid_level_full,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_claim_id                IN NUMBER,
    p_object_version_number   IN NUMBER,
    p_status_code             IN VARCHAR2,
    p_payment_status          IN VARCHAR2
);


---------------------------------------------------------------------
-- PROCEDURE
--    Populate_Settlement_Data
--
-- PURPOSE
--    Populate settlement data
--
-- PARAMETERS
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Populate_Settlement_Data(
    ERRBUF             OUT NOCOPY VARCHAR2,
    RETCODE            OUT NOCOPY NUMBER,
    p_org_id           IN  NUMBER        DEFAULT NULL,
    p_claim_class      IN  VARCHAR2      DEFAULT NULL,
    p_payment_method   IN  VARCHAR2      DEFAULT NULL,
    p_cust_account_id  IN  NUMBER        DEFAULT NULL,
    p_claim_type_id    IN  NUMBER        DEFAULT NULL,
    p_reason_code_id   IN  NUMBER        DEFAULT NULL
);


---------------------------------------------------------------------
-- PROCEDURE
--    Get_Payable_Settlement
--
-- PURPOSE
--
-- PARAMETERS
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Get_Payable_Settlement(
    p_api_version_number   IN   NUMBER,
    p_init_msg_list        IN   VARCHAR2  := FND_API.G_FALSE,
    p_commit               IN   VARCHAR2  := FND_API.G_FALSE,
    p_validation_level     IN   NUMBER    := FND_API.G_VALID_LEVEL_FULL,

    p_claim_class          IN   VARCHAR2      DEFAULT NULL,
    p_payment_method       IN   VARCHAR2      DEFAULT NULL,
    p_cust_account_id      IN   NUMBER        DEFAULT NULL,
    p_claim_type_id        IN   NUMBER        DEFAULT NULL,
    p_reason_code_id       IN   NUMBER        DEFAULT NULL,

    x_return_status        OUT NOCOPY  VARCHAR2,
    x_msg_count            OUT NOCOPY  NUMBER,
    x_msg_data             OUT NOCOPY  VARCHAR2
);


---------------------------------------------------------------------
-- PROCEDURE
--    Get_Receivable_Settlement
--
-- PURPOSE
--
-- PARAMETERS
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Get_Receivable_Settlement(
    p_api_version_number   IN   NUMBER,
    p_init_msg_list        IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit               IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level     IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    p_claim_class          IN   VARCHAR2      DEFAULT NULL,
    p_payment_method       IN   VARCHAR2      DEFAULT NULL,
    p_cust_account_id      IN   NUMBER        DEFAULT NULL,
    p_claim_type_id        IN   NUMBER        DEFAULT NULL,
    p_reason_code_id       IN   NUMBER        DEFAULT NULL,

    x_return_status        OUT NOCOPY  VARCHAR2,
    x_msg_count            OUT NOCOPY  NUMBER,
    x_msg_data             OUT NOCOPY  VARCHAR2
);


---------------------------------------------------------------------
-- PROCEDURE
--    Get_RMA_Settlement
--
-- PURPOSE
--
-- PARAMETERS
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Get_RMA_Settlement(
   p_api_version_number         IN   NUMBER,
   p_init_msg_list              IN   VARCHAR2,
   p_commit                     IN   VARCHAR2,
   p_validation_level           IN   NUMBER,

   p_claim_class                IN  VARCHAR2,
   p_payment_method             IN  VARCHAR2,
   p_cust_account_id            IN  NUMBER,
   p_claim_type_id              IN  NUMBER,
   p_reason_code_id             IN  NUMBER,

   x_return_status              OUT NOCOPY  VARCHAR2,
   x_msg_count                  OUT NOCOPY  NUMBER,
   x_msg_data                   OUT NOCOPY  VARCHAR2
);


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_Settlement_Doc
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_settlement_doc_rec            IN   settlement_doc_rec_type  Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--   ==============================================================================
--
PROCEDURE Create_Settlement_Doc(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_settlement_doc_rec         IN   settlement_doc_rec_type  := g_miss_settlement_doc_rec,
    x_settlement_doc_id          OUT NOCOPY  NUMBER
);


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_Settlement_Doc
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_settlement_doc_rec            IN   settlement_doc_rec_type  Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--   ==============================================================================
--
PROCEDURE Update_Settlement_Doc(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_settlement_doc_rec         IN   settlement_doc_rec_type,
    x_object_version_number      OUT NOCOPY  NUMBER
);


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_Settlement_Doc
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_SETTLEMENT_DOC_ID                IN   NUMBER
--       p_object_version_number   IN   NUMBER     Optional  Default = NULL
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--   ==============================================================================
--
PROCEDURE Delete_Settlement_Doc(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_settlement_doc_id          IN   NUMBER,
    p_object_version_number      IN   NUMBER
);


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Lock_Settlement_Doc
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_settlement_doc_rec            IN   settlement_doc_rec_type  Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--   ==============================================================================
--
PROCEDURE Lock_Settlement_Doc(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_settlement_doc_id          IN  NUMBER,
    p_object_version             IN  NUMBER
);


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Validate_Settlement_Doc
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_settlement_doc_rec      IN   settlement_doc_rec_type  Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--
--   Version : Current version 1.0
--
--   End of Comments
--   ==============================================================================
--
PROCEDURE Validate_Settlement_Doc(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    p_settlement_doc_rec         IN   settlement_doc_rec_type,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
);


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Check_Settle_Doc_Items
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_settlement_doc_rec      IN   settlement_doc_rec_type  Required
--       p_validation_mode         IN   VARCHAR2  : is a constant defined in OZF_UTILITY_PVT package
--                                                  For create: G_CREATE, for update: G_UPDATE
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--
--   Version : Current version 1.0
--
--   End of Comments
--   ==============================================================================
--
PROCEDURE Check_Settle_Doc_Items (
    P_settlement_doc_rec         IN    settlement_doc_rec_type,
    p_validation_mode            IN    VARCHAR2,
    x_return_status              OUT NOCOPY   VARCHAR2
);


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Check_Settle_Doc_Record
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_settlement_doc_rec      IN   settlement_doc_rec_type  Required
--       p_complete_rec            IN   settlement_doc_rec_type  Optional Default = NULL
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--
--   Version : Current version 1.0
--
--   End of Comments
--   ==============================================================================
--
PROCEDURE Check_Settle_Doc_Record(
    p_settlement_doc_rec   IN    settlement_doc_rec_type,
    p_complete_rec         IN    settlement_doc_rec_type  := NULL,
    x_return_status        OUT NOCOPY   VARCHAR2
);


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Complete_Settle_Doc_Rec
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_settlement_doc_rec      IN   settlement_doc_rec_type  Required
--
--   OUT
--       x_complete_rec            OUT  settlement_doc_rec_type
--
--   Version : Current version 1.0
--
--   End of Comments
--   ==============================================================================
--
PROCEDURE Complete_Settle_Doc_Rec(
   p_settlement_doc_rec  IN  settlement_doc_rec_type,
   x_complete_rec        OUT NOCOPY settlement_doc_rec_type
);

PROCEDURE Create_Settlement_Doc_Tbl(
    p_api_version_number    IN   NUMBER,
    p_init_msg_list         IN   VARCHAR2,
    p_commit                IN   VARCHAR2,
    p_validation_level      IN   NUMBER,

    x_return_status         OUT NOCOPY  VARCHAR2,
    x_msg_count             OUT NOCOPY  NUMBER,
    x_msg_data              OUT NOCOPY  VARCHAR2,

    p_settlement_doc_tbl    IN   settlement_doc_tbl_type,
    x_settlement_doc_id_tbl             OUT NOCOPY  JTF_NUMBER_TABLE
);

PROCEDURE Update_Settlement_Doc_Tbl(
    p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2,
    p_commit                 IN   VARCHAR2,
    p_validation_level       IN   NUMBER,

    x_return_status          OUT NOCOPY  VARCHAR2,
    x_msg_count              OUT NOCOPY  NUMBER,
    x_msg_data               OUT NOCOPY  VARCHAR2,

    p_settlement_doc_tbl     IN   settlement_doc_tbl_type
);

END OZF_SETTLEMENT_DOC_PVT;

 

/
