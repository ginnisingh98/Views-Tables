--------------------------------------------------------
--  DDL for Package AMS_METRIC_FORMULA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_METRIC_FORMULA_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvmtfs.pls 115.1 2003/10/01 21:07:46 dmvincen noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_METRIC_FORMULA_PVT
-- Purpose
--
-- History
--   09/11/2003  dmvincen  Created.
--
-- NOTE
--
-- End of Comments
-- ===============================================================

-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;
--===================================================================
--    Start of Comments
--   -------------------------------------------------------
--    Record name
--             met_formula_rec_type
--   -------------------------------------------------------
--   Parameters:
--       metric_formula_id
--       last_update_date
--       last_updated_by
--       creation_date
--       created_by
--       last_update_login
--       object_version_number
--       metric_id
--       source_type
--       source_id
--       source_sub_id
--       source_value
--       token
--       notation_type
--       use_sub_id_flag
--       sequence
--
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
TYPE met_formula_rec_type IS RECORD
(
       metric_formula_id               NUMBER ,
       last_update_date                DATE ,
       last_updated_by                 NUMBER ,
       creation_date                   DATE ,
       created_by                      NUMBER ,
       last_update_login               NUMBER ,
       object_version_number           NUMBER ,
       metric_id                       NUMBER ,
       source_type                     VARCHAR2(30) ,
       source_id                       NUMBER ,
       source_sub_id                   NUMBER ,
       source_value                    NUMBER ,
       token                           VARCHAR2(30) ,
       notation_type                   VARCHAR2(30) ,
       use_sub_id_flag                 VARCHAR2(1) ,
       sequence                        NUMBER
);

g_miss_met_formula_rec          met_formula_rec_type;
TYPE  met_formula_tbl_type      IS TABLE OF met_formula_rec_type INDEX BY BINARY_INTEGER;
g_miss_met_formula_tbl          met_formula_tbl_type;

--   ==============================================================================
--   API Name
--           Create_Metric_Formula
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
--       p_met_formula_rec         IN   met_formula_rec_type  Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   ==============================================================================

PROCEDURE Create_Metric_Formula(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT nocopy VARCHAR2,
    x_msg_count                  OUT nocopy NUMBER,
    x_msg_data                   OUT nocopy VARCHAR2,

    p_met_formula_rec            IN   met_formula_rec_type  := g_miss_met_formula_rec,
    x_metric_formula_id          OUT nocopy NUMBER
);

--   ==============================================================================
--   API Name
--           Update_Metric_formula
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
--       p_met_formula_rec         IN   met_formula_rec_type  Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   ==============================================================================
--

PROCEDURE Update_Metric_Formula(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT nocopy VARCHAR2,
    x_msg_count                  OUT nocopy NUMBER,
    x_msg_data                   OUT nocopy VARCHAR2,

    p_met_formula_rec            IN    met_formula_rec_type,
    x_object_version_number      OUT nocopy NUMBER
    );

--   ==============================================================================
--   API Name
--           Delete_Metric_Formula
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
--       p_METRIC_FORMULA_ID       IN   NUMBER
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
--   ==============================================================================
--

PROCEDURE Delete_Metric_Formula(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT nocopy VARCHAR2,
    x_msg_count                  OUT nocopy NUMBER,
    x_msg_data                   OUT nocopy VARCHAR2,
    p_metric_formula_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    );

--   ==============================================================================
--   API Name
--           Lock_Metric_Formula
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
--       p_met_formula_rec         IN   met_formula_rec_type  Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   ==============================================================================

PROCEDURE Lock_Metric_Formula(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT nocopy VARCHAR2,
    x_msg_count                  OUT nocopy NUMBER,
    x_msg_data                   OUT nocopy VARCHAR2,

    p_metric_formula_id          IN  NUMBER,
    p_object_version             IN  NUMBER
    );


-- Start of Comments
--
--  validation procedures
--
-- p_validation_mode is a constant defined in AMS_UTILITY_PVT package
--                  For create: G_CREATE, for update: G_UPDATE
-- Note: 1. This is automated generated item level validation procedure.
--          The actual validation detail is needed to be added.
--       2. We can also validate table instead of record. There will be an option for user to choose.
-- End of Comments

PROCEDURE Validate_Metric_Formula(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2 := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_metric_formula_rec         IN   met_formula_rec_type,
    p_validation_mode            IN    VARCHAR2,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    );

--
--  validation procedures
--
-- p_validation_mode is a constant defined in null_UTILITY_PVT package
--                  For create: G_CREATE, for update: G_UPDATE
-- Note: 1. This is automated generated item level validation procedure.
--          The actual validation detail is needed to be added.
--       2. Validate the unique keys, lookups here

PROCEDURE Check_metric_formula_Items (
    p_metric_formula_rec  IN    met_formula_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    );

--
-- Record level validation procedures
--
-- p_validation_mode is a constant defined in null_UTILITY_PVT package
--                  For create: G_CREATE, for update: G_UPDATE
-- Note: 1. This is automated generated item level validation procedure.
--          The actual validation detail is needed to be added.
--       2. Developer can manually added inter-field level validation.

PROCEDURE Validate_metric_formula_rec(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_metric_formula_rec         IN    met_formula_rec_type
    );

-- Formula level validation.
--
-- Validates the formula entered for a specified metric.
-- The formula is written as text into ams_metrics_all_b.formula, and
-- is verified for correctness, and transformed into postfix notation for
-- refresh engine processing.  This procedure is best called on the VO.create
-- method after all modifications have been completed.
--
PROCEDURE VALIDATE_FORMULA(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_metric_id                  IN    NUMBER,
    p_object_version_number      IN   NUMBER
);
END AMS_METRIC_FORMULA_PVT;

 

/
