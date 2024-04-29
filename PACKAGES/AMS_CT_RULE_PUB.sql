--------------------------------------------------------
--  DDL for Package AMS_CT_RULE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_CT_RULE_PUB" AUTHID CURRENT_USER AS
/* $Header: amspctrs.pls 120.1 2006/02/22 02:25:51 anchaudh noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_Ct_Rule_PUB
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
--             ct_rule_rec_type
--   -------------------------------------------------------
--   Parameters:
--       content_rule_id
--       created_by
--       creation_date
--       last_updated_by
--       last_updated_date
--       last_update_login
--       object_version_number
--       object_type
--       object_id
--       sender
--       reply_to
--       cover_letter_id
--       table_of_content_flag
--       trigger_code
--       subject
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
TYPE ct_rule_rec_type IS RECORD
(
       content_rule_id                 NUMBER := FND_API.G_MISS_NUM,
       created_by                      NUMBER := FND_API.G_MISS_NUM,
       creation_date                   DATE := FND_API.G_MISS_DATE,
       last_updated_by                 NUMBER := FND_API.G_MISS_NUM,
       last_updated_date               DATE := FND_API.G_MISS_DATE,
       last_update_login               NUMBER := FND_API.G_MISS_NUM,
       object_version_number           NUMBER := FND_API.G_MISS_NUM,
       object_type                     VARCHAR2(30) := FND_API.G_MISS_CHAR,
       object_id                       NUMBER := FND_API.G_MISS_NUM,
       sender                          VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       reply_to                        VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       cover_letter_id                 NUMBER := FND_API.G_MISS_NUM,
       table_of_content_flag           VARCHAR2(1) := FND_API.G_MISS_CHAR,
       trigger_code                    VARCHAR2(30) := FND_API.G_MISS_CHAR,
       subject                         VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       sender_display_name             VARCHAR2(2000) := FND_API.G_MISS_CHAR--anchaudh
);

g_miss_ct_rule_rec          ct_rule_rec_type;
TYPE  ct_rule_tbl_type      IS TABLE OF ct_rule_rec_type INDEX BY BINARY_INTEGER;
g_miss_ct_rule_tbl          ct_rule_tbl_type;

TYPE ct_rule_sort_rec_type IS RECORD
(
      -- Please define your own sort by record here.
      created_by   NUMBER := NULL
);

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_Ct_Rule
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
--       p_ct_rule_rec            IN   ct_rule_rec_type  Required
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

PROCEDURE Create_Ct_Rule(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_ct_rule_rec               IN   ct_rule_rec_type  := g_miss_ct_rule_rec,
    x_content_rule_id                   OUT NOCOPY  NUMBER
     );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_Ct_Rule
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
--       p_ct_rule_rec            IN   ct_rule_rec_type  Required
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

PROCEDURE Update_Ct_Rule(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_ct_rule_rec               IN    ct_rule_rec_type,
    x_object_version_number      OUT NOCOPY  NUMBER
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_Ct_Rule
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
--       p_CONTENT_RULE_ID                IN   NUMBER
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

PROCEDURE Delete_Ct_Rule(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_content_rule_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Lock_Ct_Rule
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
--       p_ct_rule_rec            IN   ct_rule_rec_type  Required
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

PROCEDURE Lock_Ct_Rule(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_content_rule_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
    );

END AMS_Ct_Rule_PUB;

 

/
