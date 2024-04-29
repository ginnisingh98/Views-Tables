--------------------------------------------------------
--  DDL for Package AMS_PS_RULE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_PS_RULE_PUB" AUTHID CURRENT_USER AS
/* $Header: amspruls.pls 120.0 2005/05/31 22:34:19 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_Ps_Rule_PUB
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

--===================================================================
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
/*
TYPE ps_rules_tuple_rec_type IS RECORD
(
       name     VARCHAR2(30) := FND_API.G_MISS_CHAR,
       value    VARCHAR2(30) := FND_API.G_MISS_CHAR
);

g_miss_ps_rules_tuple_rec          ps_rules_tuple_rec_type;
TYPE  ps_rules_tuple_tbl_type      IS TABLE OF ps_rules_tuple_rec_type INDEX BY BINARY_INTEGER;
g_miss_ps_rules_tuple_tbl          ps_rules_tuple_tbl_type;
*/

--===================================================================
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
--       security_group_id
--       object_version_number
--       rule_id
--       rulegroup_id
--       posting_id
--       strategy_id
--       bus_priority_code
--       bus_priority_disp_order
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
/*
TYPE ps_rules_rec_type IS RECORD
(
       created_by                      NUMBER := FND_API.G_MISS_NUM,
       creation_date                   DATE := FND_API.G_MISS_DATE,
       last_updated_by                 NUMBER := FND_API.G_MISS_NUM,
       last_update_date                DATE := FND_API.G_MISS_DATE,
       last_update_login               NUMBER := FND_API.G_MISS_NUM,
       security_group_id               NUMBER := FND_API.G_MISS_NUM,
       object_version_number           NUMBER := FND_API.G_MISS_NUM,
       rule_id                         NUMBER := FND_API.G_MISS_NUM,
       rulegroup_id                    NUMBER := FND_API.G_MISS_NUM,
       posting_id                      NUMBER := FND_API.G_MISS_NUM,
       strategy_id                     NUMBER := FND_API.G_MISS_NUM,
       bus_priority_code               VARCHAR2(30) := FND_API.G_MISS_CHAR,
       bus_priority_disp_order         VARCHAR2(30) := FND_API.G_MISS_CHAR,
       clausevalue1                    VARCHAR2(30) := FND_API.G_MISS_CHAR,
       clausevalue2                    NUMBER := FND_API.G_MISS_NUM,
       clausevalue3                    VARCHAR2(30) := FND_API.G_MISS_CHAR,
       clausevalue4                    NUMBER := FND_API.G_MISS_NUM,
       clausevalue5                    VARCHAR2(15) := FND_API.G_MISS_CHAR,
       clausevalue6                    VARCHAR2(30) := FND_API.G_MISS_CHAR,
       clausevalue7                    VARCHAR2(30) := FND_API.G_MISS_CHAR,
       clausevalue8                    VARCHAR2(30) := FND_API.G_MISS_CHAR,
       clausevalue9                    VARCHAR2(30) := FND_API.G_MISS_CHAR,
       clausevalue10                   VARCHAR2(30) := FND_API.G_MISS_CHAR
);

g_miss_ps_rules_rec          ps_rules_rec_type;
TYPE  ps_rules_tbl_type      IS TABLE OF ps_rules_rec_type INDEX BY BINARY_INTEGER;
g_miss_ps_rules_tbl          ps_rules_tbl_type;

TYPE ps_rules_sort_rec_type IS RECORD
(
      -- Please define your own sort by record here.
      creation_date   NUMBER := NULL
);

*/
--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_Ps_Rule
--   Type
--           Public
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_ps_rules_rec            IN   ps_rules_rec_type  Required
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
/*
PROCEDURE Create_Ps_Rule(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_ps_rules_rec               IN   ps_rules_rec_type  := g_miss_ps_rules_rec,
    x_rule_id                   OUT NOCOPY  NUMBER
     );
*/
--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_Ps_Rule
--   Type
--           Public
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_ps_rules_rec            IN   ps_rules_rec_type  Required
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
/*
PROCEDURE Update_Ps_Rule(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_ps_rules_rec               IN    ps_rules_rec_type,
    p_ps_filter_tbl              IN    ps_rules_tuple_tbl_type,
    p_ps_strategy_tbl            IN    ps_rules_tuple_tbl_type,
    x_object_version_number      OUT NOCOPY  NUMBER
    );
*/
--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_Ps_Rule
--   Type
--           Public
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_RULE_ID                IN   NUMBER
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
/*

PROCEDURE Delete_Ps_Rule(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_rule_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    );
*/
--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Lock_Ps_Rule
--   Type
--           Public
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_ps_rules_rec            IN   ps_rules_rec_type  Required
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
/*
PROCEDURE Lock_Ps_Rule(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_rule_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
    );

*/
END AMS_Ps_Rule_PUB;


 

/
