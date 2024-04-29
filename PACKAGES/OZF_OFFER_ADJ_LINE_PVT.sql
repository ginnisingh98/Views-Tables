--------------------------------------------------------
--  DDL for Package OZF_OFFER_ADJ_LINE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_OFFER_ADJ_LINE_PVT" AUTHID CURRENT_USER AS
/* $Header: ozfvoals.pls 120.2 2006/05/22 19:03:50 rssharma noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_Offer_Adj_Line_PVT
-- Purpose
--
-- History
--
-- NOTE
--
-- This Api is generated with Latest version of
-- Rosetta, where g_miss indicates NULL and
-- NULL indicates missing value. Rosetta Version 1.55
-- Mon May 22 2006:12/0 PM  RSSHARMA Expose debug_message method
-- End of Comments
-- ===============================================================

-- Default number of records fetch per call
-- G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;
--===================================================================
--    Start of Comments
--   -------------------------------------------------------
--    Record name
--             offadj_line_rec_type
--   -------------------------------------------------------
--   Parameters:
--       offer_adjustment_line_id
--       offer_adjustment_id
--       list_line_id
--       arithmetic_operator
--       original_discount
--       modified_discount
--       last_update_date
--       last_updated_by
--       creation_date
--       created_by
--       last_update_login
--       object_version_number
--       list_header_id
--       accrual_flag
--       list_line_id_td
--       original_discount_td
--       modified_discount_td
--	 quantity
--
--    Required
--
--    Defaults
--
--    Note: This is automatic generated record definition, it includes all columns
--          defined in the table, developer must manually add or delete some of the attributes.
--
--   End of Comments

--===================================================================
TYPE offadj_line_rec_type IS RECORD
(
       offer_adjustment_line_id        NUMBER,
       offer_adjustment_id             NUMBER,
       list_line_id                    NUMBER,
       arithmetic_operator             VARCHAR2(30),
       original_discount               NUMBER,
       modified_discount               NUMBER,
       last_update_date                DATE,
       last_updated_by                 NUMBER,
       creation_date                   DATE,
       created_by                      NUMBER,
       last_update_login               NUMBER,
       object_version_number           NUMBER,
       list_header_id                  NUMBER,
       accrual_flag                    VARCHAR2(1),
       list_line_id_td                 NUMBER,
       original_discount_td            NUMBER,
       modified_discount_td            NUMBER,
       quantity                        NUMBER,
       created_from_adjustments        VARCHAR2(1),
       discount_end_date               DATE
);

g_miss_offadj_line_rec          offadj_line_rec_type := NULL;
TYPE  offadj_line_tbl_type      IS TABLE OF offadj_line_rec_type INDEX BY BINARY_INTEGER;
g_miss_offadj_line_tbl          offadj_line_tbl_type;



 TYPE offadj_new_line_rec_type IS RECORD
(
       offer_adjustment_line_id        NUMBER,
       offer_adjustment_id             NUMBER,
       list_header_id                  NUMBER,
       list_line_id                    NUMBER,
       list_line_type_code             VARCHAR2(30),
       operand                         NUMBER,
       arithmetic_operator             VARCHAR2(30),
       product_attr                    VARCHAR2(30),
       product_attr_val                VARCHAR2(240),
       product_uom_code                VARCHAR2(30),
       pricing_attr                    VARCHAR2(30),
       pricing_attr_value_from         VARCHAR2(240),
       pricing_attr_value_to           VARCHAR2(240),
       pricing_attribute_id            NUMBER,
       order_value_from                NUMBER,
       order_value_to                  NUMBER,
       qualifier_id                    NUMBER,
       inactive_flag                   VARCHAR2(1),
       max_qty_per_order_id            NUMBER,
       max_qty_per_customer_id         NUMBER,
       max_qty_per_rule_id             NUMBER,
       max_orders_per_customer_id      NUMBER,
       max_amount_per_rule_id          NUMBER,
       qd_arithmetic_operator          VARCHAR2(30),
       qd_operand                      NUMBER,
       qd_estimated_qty_is_max         VARCHAR2(1),
       qd_estimated_amount_is_max      VARCHAR2(1),
       price_by_formula_id             NUMBER,
       operation                       VARCHAR2(30),
       benefit_price_list_line_id       NUMBER,
       benefit_uom_code                 VARCHAR2(30),
       benefit_qty                      NUMBER,
       last_update_date                DATE,
       last_updated_by                 NUMBER,
       creation_date                   DATE,
       created_by                      NUMBER,
       last_update_login               NUMBER,
       object_version_number           NUMBER,
       start_date_active               DATE,
       end_date_active                 DATE,
       attribute1                      VARCHAR2(240),
       attribute2                      VARCHAR2(240),
       attribute3                      VARCHAR2(240),
       attribute4                      VARCHAR2(240),
       attribute5                      VARCHAR2(240),
       attribute6                      VARCHAR2(240),
       attribute7                      VARCHAR2(240),
       attribute8                      VARCHAR2(240),
       attribute9                      VARCHAR2(240),
       attribute10                      VARCHAR2(240),
       attribute11                      VARCHAR2(240),
       attribute12                      VARCHAR2(240),
       attribute13                      VARCHAR2(240),
       attribute14                      VARCHAR2(240),
       attribute15                      VARCHAR2(240),
       context                         VARCHAR2(30),
       discount_end_date                DATE
);
g_miss_offadj_new_line_rec      offadj_new_line_rec_type := NULL;
TYPE  offadj_New_line_tbl_type      IS TABLE OF offadj_new_line_rec_type INDEX BY BINARY_INTEGER;


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_Offer_Adj_Line
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
--       p_offadj_line_rec            IN   offadj_line_rec_type  Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   History
--
--   NOTE
--
--   End of Comments
--   ==============================================================================

PROCEDURE Create_Offer_Adj_Line(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_offadj_line_rec              IN   offadj_line_rec_type  := g_miss_offadj_line_rec,
    x_offer_adjustment_line_id              OUT NOCOPY  NUMBER
     );


PROCEDURE Create_New_Offer_Adj_Line(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

--    p_offadj_line_rec              IN   offadj_line_rec_type  := g_miss_offadj_line_rec,
    p_list_line_rec                IN   offadj_new_line_rec_type := g_miss_offadj_new_line_rec,
    x_offer_adjustment_line_id              OUT NOCOPY  NUMBER
     );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_Offer_Adj_Line
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
--       p_offadj_line_rec            IN   offadj_line_rec_type  Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   History
--
--   NOTE
--
--   End of Comments
--   ==============================================================================

PROCEDURE Update_Offer_Adj_Line(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_offadj_line_rec               IN    offadj_line_rec_type,
    x_object_version_number      OUT NOCOPY  NUMBER
    );


PROCEDURE Update_New_Offer_Adj_Line(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

--    p_offadj_line_rec               IN    offadj_line_rec_type,
    p_list_line_rec                 IN    offadj_new_line_rec_type,
    x_object_version_number      OUT NOCOPY  NUMBER
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_Offer_Adj_Line
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
--       p_offer_adjustment_line_id                IN   NUMBER
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
--   History
--
--   NOTE
--
--   End of Comments
--   ==============================================================================

PROCEDURE Delete_Offer_Adj_Line(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_offer_adjustment_line_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Lock_Offer_Adj_Line
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
--       p_offadj_line_rec            IN   offadj_line_rec_type  Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   History
--
--   NOTE
--
--   End of Comments
--   ==============================================================================

PROCEDURE Lock_Offer_Adj_Line(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_offer_adjustment_line_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
    );


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Validate_Offer_Adj_Line
--
--   Version : Current version 1.0
--   p_validation_mode is a constant defined in OZF_UTILITY_PVT package
--           For create: G_CREATE, for update: G_UPDATE
--   Note: 1. This is automated generated item level validation procedure.
--           The actual validation detail is needed to be added.
--           2. We can also validate table instead of record. There will be an option for user to choose.
--
--   History
--
--   NOTE
--
--   End of Comments
--   ==============================================================================


PROCEDURE Validate_Offer_Adj_Line(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_offadj_line_rec               IN   offadj_line_rec_type,
    p_validation_mode            IN    VARCHAR2,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Offadj_Line_Items
--
--   Version : Current version 1.0
--   p_validation_mode is a constant defined in OZF_UTILITY_PVT package
--           For create: G_CREATE, for update: G_UPDATE
--   Note: 1. This is automated generated item level validation procedure.
--           The actual validation detail is needed to be added.
--           2. Validate the unique keys, lookups here
--
--   History
--
--   NOTE
--
--   End of Comments
--   ==============================================================================


PROCEDURE Check_Offadj_Line_Items (
    P_offadj_line_rec     IN    offadj_line_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Validate_Offadj_Line_Rec
--
--   Version : Current version 1.0
--   p_validation_mode is a constant defined in OZF_UTILITY_PVT package
--           For create: G_CREATE, for update: G_UPDATE
--   Note: 1. This is automated generated item level validation procedure.
--           The actual validation detail is needed to be added.
--           2. Developer can manually added inter-field level validation.
--
--   History
--
--   NOTE
--
--   End of Comments
--   ==============================================================================


PROCEDURE Validate_Offadj_Line_Rec (
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_offadj_line_rec               IN    offadj_line_rec_type
    );

PROCEDURE debug_message(
                        p_message_text   IN  VARCHAR2
                        );

FUNCTION get_price_list_name(p_list_line_id IN NUMBER)
RETURN VARCHAR2 ;
END OZF_Offer_Adj_Line_PVT;

 

/
