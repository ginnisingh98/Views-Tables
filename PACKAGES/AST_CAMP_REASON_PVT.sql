--------------------------------------------------------
--  DDL for Package AST_CAMP_REASON_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AST_CAMP_REASON_PVT" AUTHID CURRENT_USER as
/* $Header: astvrcns.pls 115.7 2002/02/06 11:44:22 pkm ship   $ */

-- Start of Comments
-- Package name     : AST_camp_reason_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;
--   *******************************************************
--    Start of Comments
--   -------------------------------------------------------
--    Record name:camp_reason_Rec_Type
--   -------------------------------------------------------
--   Parameters:
--
--    Required:
--    Defaults:
--    Note: This is automatic generated record definition, it includes all columns
--          defined in the table, developer must manually add or delete some of the attributes.
--
--   End of Comments

TYPE camp_reason_Rec_Type IS RECORD
(
       reason_id                    NUMBER := FND_API.G_MISS_NUM,
       object_id                     NUMBER := FND_API.G_MISS_NUM,
       object_version_number         NUMBER := FND_API.G_MISS_NUM,
       created_by                    NUMBER := FND_API.G_MISS_NUM,
       creation_date                 DATE := FND_API.G_MISS_DATE,
       last_updated_by               NUMBER := FND_API.G_MISS_NUM,
       last_update_date              DATE := FND_API.G_MISS_DATE,
       last_update_login             NUMBER := FND_API.G_MISS_NUM,
       object_type                   VARCHAR2(30) := FND_API.G_MISS_CHAR,
       source_code_id                NUMBER := FND_API.G_MISS_NUM,
       source_code                   VARCHAR2(30) := FND_API.G_MISS_CHAR
);

G_MISS_camp_reason_REC          camp_reason_Rec_Type;
TYPE  camp_reason_Tbl_Type      IS TABLE OF camp_reason_Rec_Type
                                    INDEX BY BINARY_INTEGER;
G_MISS_camp_reason_TBL          camp_reason_Tbl_Type;

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_camp_reason
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       P_camp_reason_Rec         IN   camp_reason_Rec_Type  Required
--
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 2.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.

--
--   End of Comments
--
FUNCTION get_camp_reason_REC RETURN AST_camp_reason_PVT.camp_reason_rec_type;

PROCEDURE Create_camp_reason(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_camp_reason_Rec            IN   camp_reason_Rec_Type  := G_MISS_camp_reason_REC,
    X_Return_Status              OUT  VARCHAR2,
    X_Msg_Count                  OUT  NUMBER,
    X_Msg_Data                   OUT  VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_camp_reason
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       P_camp_reason_Rec        IN camp_reason_Rec_Type  Required
--
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 2.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.

--
--   End of Comments
--
-- Hint: Add corresponding delete detail table procedures if it's master-detail relationship.
--       The Master delete procedure may not be needed depends on different business requirements.
PROCEDURE Delete_camp_reason(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_camp_reason_Rec            IN   camp_reason_Rec_Type,
    X_Return_Status              OUT  VARCHAR2,
    X_Msg_Count                  OUT  NUMBER,
    X_Msg_Data                   OUT  VARCHAR2
    );
End AST_camp_reason_PVT;

 

/
