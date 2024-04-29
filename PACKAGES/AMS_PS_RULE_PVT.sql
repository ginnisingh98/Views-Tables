--------------------------------------------------------
--  DDL for Package AMS_PS_RULE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_PS_RULE_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvruls.pls 115.7 2002/11/25 20:48:32 ryedator ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_Ps_Rule_PVT
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================

-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;

--================================================================
--    Start of Comments
--   -------------------------------------------------------
--    Record name
--             ps_rules_tuple_rec_type
--   -------------------------------------------------------
--   Parameters:
--       name
--       value
--
--   End of Comments
TYPE ps_rules_tuple_rec_type IS RECORD
(
    name    VARCHAR2(30) := FND_API.G_MISS_CHAR,
    value   VARCHAR2(30) := FND_API.G_MISS_CHAR
);

g_miss_ps_rules_tuple_rec          ps_rules_tuple_rec_type;
TYPE  ps_rules_tuple_tbl_type      IS TABLE OF ps_rules_tuple_rec_type INDEX BY BINARY_INTEGER;
g_miss_ps_rules_tuple_tbl          ps_rules_tuple_tbl_type;

--===============================================================
--    Start of Comments
--   -------------------------------------------------------
--    Record name
--             ps_rules_rec_type
--   -------------------------------------------------------
--   Parameters:
--       created_by
--       creation_date
--       last_updated_by
--       last_update_date
--       last_update_login
--       object_version_number
--       rule_id
--       rulegroup_id
--       posting_id
--       strategy_id
--       bus_priority_code
--       bus_priority_disp_order
--       filter table
--       strategy table
--       clausevalue1
--       clausevalue2
--       clausevalue3
--       clausevalue4
--       clausevalue5
--       clausevalue6
--       clausevalue7
--       clausevalue8
--       clausevalue9
--       clausevalue10
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
TYPE visitor_type_rec IS RECORD
(
        anon BOOLEAN    := false,
        rgoh BOOLEAN    := false,
        rgnoh BOOLEAN   := false
);

TYPE ps_rules_rec_type IS RECORD
(
       created_by                 NUMBER := FND_API.G_MISS_NUM,
       creation_date              DATE := FND_API.G_MISS_DATE,
       last_updated_by            NUMBER := FND_API.G_MISS_NUM,
       last_update_date           DATE := FND_API.G_MISS_DATE,
       last_update_login          NUMBER := FND_API.G_MISS_NUM,
       object_version_number      NUMBER := FND_API.G_MISS_NUM,
       rule_id                    NUMBER := FND_API.G_MISS_NUM,
       rulegroup_id               NUMBER := FND_API.G_MISS_NUM,
       posting_id                 NUMBER := FND_API.G_MISS_NUM,
       strategy_id                NUMBER := FND_API.G_MISS_NUM,
       exec_priority              NUMBER := FND_API.G_MISS_NUM,
       bus_priority_code          VARCHAR2(30) := FND_API.G_MISS_CHAR,
       bus_priority_disp_order    VARCHAR2(30) := FND_API.G_MISS_CHAR,
       clausevalue1               VARCHAR2(30) := FND_API.G_MISS_CHAR,
       clausevalue2               NUMBER := FND_API.G_MISS_NUM,
       clausevalue3               VARCHAR2(30) := FND_API.G_MISS_CHAR,
       clausevalue4               VARCHAR2(30) := FND_API.G_MISS_CHAR,
       clausevalue5               NUMBER := FND_API.G_MISS_NUM,
       clausevalue6               VARCHAR2(30) := FND_API.G_MISS_CHAR,
       clausevalue7               VARCHAR2(30) := FND_API.G_MISS_CHAR,
       clausevalue8               VARCHAR2(30) := FND_API.G_MISS_CHAR,
       clausevalue9               VARCHAR2(30) := FND_API.G_MISS_CHAR,
       clausevalue10              VARCHAR2(30) := FND_API.G_MISS_CHAR,
       use_clause6                VARCHAR2(1) := FND_API.G_MISS_CHAR,
       use_clause7                VARCHAR2(1) := FND_API.G_MISS_CHAR,
       use_clause8                VARCHAR2(1) := FND_API.G_MISS_CHAR,
       use_clause9                VARCHAR2(1) := FND_API.G_MISS_CHAR,
       use_clause10               VARCHAR2(1) := FND_API.G_MISS_CHAR
);

g_miss_ps_rules_rec      ps_rules_rec_type;
TYPE  ps_rules_tbl_type  IS TABLE OF ps_rules_rec_type INDEX BY BINARY_INTEGER;
g_miss_ps_rules_tbl      ps_rules_tbl_type;

--   ====================================================================
--    Start of Comments
--   ====================================================================
--   API Name
--           Create_Ps_Rule
--   Type
--         Private
--   Pre-Req
--
--   Parameters
--
--   IN
--      p_api_version_number  IN   NUMBER   Required
--      p_init_msg_list       IN   VARCHAR2 Optional  Default = FND_API_G_FALSE
--      p_commit              IN   VARCHAR2 Optional  Default = FND_API.G_FALSE
--      p_validation_level    IN   NUMBER   Optional  Default = FND_API.G_VALID_LEVEL_FULL
--      p_ps_rules_rec        IN   ps_rules_rec_type  Required
--
--   OUT
--      x_return_status       OUT  VARCHAR2
--      x_msg_count           OUT  NUMBER
--      x_msg_data            OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--   ===============================================================
--

PROCEDURE Create_Ps_Rule(
    p_api_version_number    IN   NUMBER,
    p_init_msg_list         IN   VARCHAR2  := FND_API.G_FALSE,
    p_commit                IN   VARCHAR2  := FND_API.G_FALSE,
    p_validation_level      IN   NUMBER    := FND_API.G_VALID_LEVEL_FULL,

    x_return_status         OUT NOCOPY  VARCHAR2,
    x_msg_count             OUT NOCOPY  NUMBER,
    x_msg_data              OUT NOCOPY  VARCHAR2,

    p_ps_rules_rec          IN   ps_rules_rec_type := g_miss_ps_rules_rec,
    p_visitor_rec           IN   visitor_type_rec := NULL,
    x_rule_id               OUT NOCOPY  NUMBER
   );

--  ================================================================
--    Start of Comments
--  ================================================================
--   API Name
--           Update_Ps_Rule
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--     p_api_version_number   IN   NUMBER   Required
--     p_init_msg_list        IN   VARCHAR2 Optional  Default = FND_API_G_FALSE
--     p_commit               IN   VARCHAR2 Optional  Default = FND_API.G_FALSE
--     p_validation_level     IN   NUMBER   Optional  Default = FND_API.G_VALID_LEVEL_FULL
--     p_ps_rules_rec         IN   ps_rules_rec_type  Required
--
--   OUT
--     x_return_status        OUT  VARCHAR2
--     x_msg_count            OUT  NUMBER
--     x_msg_data             OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--  ==============================================================
--

PROCEDURE Update_Ps_Rule(
    p_api_version_number    IN NUMBER,
    p_init_msg_list         IN VARCHAR2     := FND_API.G_FALSE,
    p_commit                IN VARCHAR2     := FND_API.G_FALSE,
    p_validation_level      IN NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,

    p_ps_rules_rec          IN  ps_rules_rec_type,
    p_visitor_rec           IN  visitor_type_rec,
    p_ps_filter_tbl         IN  ps_rules_tuple_tbl_type,
    p_ps_strategy_tbl       IN  ps_rules_tuple_tbl_type,
    x_object_version_number OUT NOCOPY NUMBER
    );


PROCEDURE Update_Ps_Rule_Alt(
    p_api_version_number     IN  NUMBER,
    p_init_msg_list          IN  VARCHAR2  := FND_API.G_FALSE,
    p_commit                 IN  VARCHAR2  := FND_API.G_FALSE,
    p_validation_level       IN  NUMBER    := FND_API.G_VALID_LEVEL_FULL,

    x_return_status          OUT NOCOPY VARCHAR2,
    x_msg_count              OUT NOCOPY NUMBER,
    x_msg_data               OUT NOCOPY VARCHAR2,

    p_ps_rules_rec           IN  ps_rules_rec_type,
    p_visitor_rec            IN  visitor_type_rec,
    p_ps_filter_tbl          IN  ps_rules_tuple_tbl_type,
    p_ps_strategy_tbl        IN  ps_rules_tuple_tbl_type,
    p_vistype_change         IN  BOOLEAN,
    p_rem_change             IN  BOOLEAN,

    x_object_version_number  OUT NOCOPY NUMBER
   );


--  ============================================================
--    Start of Comments
--  ============================================================
--   API Name
--           Delete_Ps_Rule
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--     p_api_version_number    IN  NUMBER   Required
--     p_init_msg_list         IN  VARCHAR2 Optional  Default = FND_API_G_FALSE
--     p_commit                IN  VARCHAR2 Optional  Default = FND_API.G_FALSE
--     p_validation_level      IN  NUMBER   Optional  Default = FND_API.G_VALID_LEVEL_FULL
--     p_RULE_ID               IN  NUMBER
--     p_object_version_number IN  NUMBER   Optional  Default = NULL
--
--   OUT
--     x_return_status       OUT  VARCHAR2
--     x_msg_count           OUT  NUMBER
--     x_msg_data            OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--   ===========================================================
--

PROCEDURE Delete_Ps_Rule(
    p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2  := FND_API.G_FALSE,
    p_commit                 IN   VARCHAR2  := FND_API.G_FALSE,
    p_validation_level       IN   NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    x_return_status          OUT NOCOPY  VARCHAR2,
    x_msg_count              OUT NOCOPY  NUMBER,
    x_msg_data               OUT NOCOPY  VARCHAR2,
    p_rule_id                IN  NUMBER,
    p_object_version_number  IN   NUMBER
    );

PROCEDURE Delete_Ps_Rule_Alt(
    p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2   := FND_API.G_FALSE,
    p_commit                 IN   VARCHAR2   := FND_API.G_FALSE,
    p_validation_level       IN   NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    x_return_status          OUT NOCOPY  VARCHAR2,
    x_msg_count              OUT NOCOPY  NUMBER,
    x_msg_data               OUT NOCOPY  VARCHAR2,
    p_ps_rules_rec           IN   ps_rules_rec_type,
    p_object_version_number  IN   NUMBER
    );

--   ===============================================================
--    Start of Comments
--   ===============================================================
--   API Name
--           Lock_Ps_Rule
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--     p_api_version_number IN   NUMBER     Required
--     p_init_msg_list      IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--     p_commit             IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--     p_validation_level   IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--     p_ps_rules_rec       IN   ps_rules_rec_type  Required
--
--   OUT
--     x_return_status      OUT  VARCHAR2
--     x_msg_count          OUT  NUMBER
--     x_msg_data           OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--   ===============================================================
--

PROCEDURE Lock_Ps_Rule(
    p_api_version_number IN   NUMBER,
    p_init_msg_list      IN   VARCHAR2  := FND_API.G_FALSE,

    x_return_status      OUT NOCOPY  VARCHAR2,
    x_msg_count          OUT NOCOPY  NUMBER,
    x_msg_data           OUT NOCOPY  VARCHAR2,

    p_rule_id            IN  NUMBER,
    p_object_version     IN  NUMBER
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


PROCEDURE Validate_ps_rule(
    p_api_version_number   IN   NUMBER,
    p_init_msg_list        IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level     IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_ps_rules_rec         IN   ps_rules_rec_type,
    x_return_status        OUT NOCOPY  VARCHAR2,
    x_msg_count            OUT NOCOPY  NUMBER,
    x_msg_data             OUT NOCOPY  VARCHAR2
    );

-- Start of Comments
--
--  validation procedures
--
-- p_validation_mode is a constant defined in AMS_UTILITY_PVT package
--           For create: G_CREATE, for update: G_UPDATE
-- Note: 1. This is automated generated item level validation procedure.
--          The actual validation detail is needed to be added.
--       2. Validate the unique keys, lookups here
-- End of Comments

PROCEDURE Check_ps_rules_Items (
    P_ps_rules_rec     IN    ps_rules_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    );


-- Start of Comments
-- Updates Filter information in ams_iba_ps_filters
-- End of Comments
PROCEDURE update_filters(
    p_rulegroup_id  IN NUMBER,
    p_ps_filter_tbl IN ps_rules_tuple_tbl_type,
    x_return_status OUT NOCOPY VARCHAR2
);


-- Start of Comments
-- updates strategy parameter information in ams_iba_ps_strat_params
-- End of Comments
PROCEDURE update_strategy_params(
    p_rulegroup_id  IN NUMBER,
    p_ps_strategy_tbl IN    ps_rules_tuple_tbl_type,
    x_return_status OUT NOCOPY VARCHAR2
);


-- Start of Comments
--
-- Record level validation procedures
--
-- p_validation_mode is a constant defined in AMS_UTILITY_PVT package
--                  For create: G_CREATE, for update: G_UPDATE
-- Note: 1. This is automated generated item level validation procedure.
--          The actual validation detail is needed to be added.
--       2. Developer can manually added inter-field level validation.
-- End of Comments

PROCEDURE Validate_ps_rules_rec(
    p_api_version_number  IN   NUMBER,
    p_init_msg_list       IN   VARCHAR2 := FND_API.G_FALSE,
    x_return_status       OUT NOCOPY  VARCHAR2,
    x_msg_count           OUT NOCOPY  NUMBER,
    x_msg_data            OUT NOCOPY  VARCHAR2,
    p_ps_rules_rec        IN    ps_rules_rec_type
    );
END AMS_Ps_Rule_PVT;


 

/
