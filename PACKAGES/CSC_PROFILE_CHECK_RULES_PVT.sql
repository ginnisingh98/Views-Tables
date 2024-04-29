--------------------------------------------------------
--  DDL for Package CSC_PROFILE_CHECK_RULES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSC_PROFILE_CHECK_RULES_PVT" AUTHID CURRENT_USER as
/* $Header: cscvpcrs.pls 115.9 2002/12/03 17:56:57 jamose ship $ */
-- Start of Comments
-- Package name     : CSC_PROFILE_CHECK_RULES_PVT
-- Purpose          :
-- History          :26 Nov 02 jamose made changes for the NOCOPY and FND_API.G_MISS*
-- NOTE             :
-- End of Comments

-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;
--   *******************************************************
--    Start of Comments
--   -------------------------------------------------------
--    Record name:CHK_RULES_Rec_Type
--   -------------------------------------------------------
--   Parameters:
--    CHECK_ID
--    SEQUENCE
--    CREATED_BY
--    CREATION_DATE
--    LAST_UPDATED_BY
--    LAST_UPDATE_DATE
--    LAST_UPDATE_LOGIN
--    LOGICAL_OPERATOR
--    LEFT_PAREN
--    BLOCK_ID
--    COMPARISON_OPERATOR
--    EXPRESSION1
--    EXPRESSION2
--    RIGHT_PAREN
--    SEEDED_FLAG
--
--    Required:
--    Defaults:
--
--   End of Comments

TYPE CHK_RULES_Rec_Type IS RECORD
(
       CHECK_ID                        NUMBER,
       SEQUENCE                        NUMBER,
       CREATED_BY                      NUMBER,
       CREATION_DATE                   DATE,
       LAST_UPDATED_BY                 NUMBER,
       LAST_UPDATE_DATE                DATE,
       LAST_UPDATE_LOGIN               NUMBER,
       LOGICAL_OPERATOR                VARCHAR2(30),
       LEFT_PAREN                      VARCHAR2(30),
       BLOCK_ID                        NUMBER,
       COMPARISON_OPERATOR             VARCHAR2(45),
       EXPRESSION                      VARCHAR2(240),
       EXPR_TO_BLOCK_ID                NUMBER,
       RIGHT_PAREN                     VARCHAR2(30),
       SEEDED_FLAG                     VARCHAR2(3));

G_MISS_CHK_RULES_REC          CHK_RULES_Rec_Type;
TYPE  CHK_RULES_Tbl_Type      IS TABLE OF CHK_RULES_Rec_Type
                              INDEX BY BINARY_INTEGER;
G_MISS_CHK_RULES_TBL          CHK_RULES_Tbl_Type;

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_profile_check_rules
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = CSC_CORE_UTILS_PVT.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL
--       P_CHK_RULES_Rec     IN CHK_RULES_Rec_Type  Required
--
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--
--   End of Comments
--
PROCEDURE Create_profile_check_rules(
    P_Api_Version_Number         IN  NUMBER,
    P_Init_Msg_List              IN  VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit                     IN  VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level           IN  NUMBER       := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    P_CHECK_ID     		         IN  NUMBER,
    P_BLOCK_ID     		         IN  NUMBER,
    P_SEQUENCE                   IN  NUMBER,
    P_CREATED_BY                 IN  NUMBER,
    P_CREATION_DATE              IN  DATE,
    P_LAST_UPDATED_BY            IN  NUMBER,
    P_LAST_UPDATE_DATE           IN  DATE,
    P_LAST_UPDATE_LOGIN          IN  NUMBER,
    P_LOGICAL_OPERATOR           IN  VARCHAR2,
    P_LEFT_PAREN                 IN  VARCHAR2,
    P_COMPARISON_OPERATOR        IN  VARCHAR2,
    P_EXPRESSION                 IN  VARCHAR2,
    P_EXPR_TO_BLOCK_ID           IN  NUMBER,
    P_RIGHT_PAREN                IN  VARCHAR2,
    P_SEEDED_FLAG                IN  VARCHAR2,
    X_OBJECT_VERSION_NUMBER      OUT NOCOPY NUMBER,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    );

PROCEDURE Create_profile_check_rules(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit                     IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level           IN   NUMBER       := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    P_CHK_RULES_Rec              IN   CHK_RULES_Rec_Type  := G_MISS_CHK_RULES_REC,
    X_OBJECT_VERSION_NUMBER      OUT NOCOPY NUMBER,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_profile_check_rules
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = CSC_CORE_UTILS_PVT.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL
--       p_identity_salesforce_id  IN   NUMBER     Optional  Default = NULL
--       P_CHK_RULES_Rec     IN CHK_RULES_Rec_Type  Required
--
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--
--   End of Comments
--

PROCEDURE Update_profile_check_rules(
    P_Api_Version_Number         IN  NUMBER,
    P_Init_Msg_List              IN  VARCHAR2  := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit                     IN  VARCHAR2  := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level           IN  NUMBER    := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    P_CHECK_ID     		         IN  NUMBER,
    P_BLOCK_ID     		         IN  NUMBER,
    P_SEQUENCE                   IN  NUMBER,
    P_CREATED_BY                 IN  NUMBER,
    P_CREATION_DATE              IN  DATE,
    P_LAST_UPDATED_BY            IN  NUMBER,
    P_LAST_UPDATE_DATE           IN  DATE,
    P_LAST_UPDATE_LOGIN          IN  NUMBER,
    P_LOGICAL_OPERATOR           IN  VARCHAR2,
    P_LEFT_PAREN                 IN  VARCHAR2,
    P_COMPARISON_OPERATOR        IN  VARCHAR2,
    P_EXPRESSION                 IN  VARCHAR2,
    P_EXPR_TO_BLOCK_ID           IN  NUMBER,
    P_RIGHT_PAREN                IN  VARCHAR2,
    P_SEEDED_FLAG                IN  VARCHAR2,
    PX_OBJECT_VERSION_NUMBER     IN OUT NOCOPY NUMBER,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    );

PROCEDURE Update_profile_check_rules(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2 := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit                     IN   VARCHAR2 := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level           IN  NUMBER    := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    P_CHK_RULES_Rec       IN    CHK_RULES_Rec_Type  := G_MISS_CHK_RULES_REC,
    --P_CHECK_ID     		   IN  NUMBER,
    --P_BLOCK_ID     		   IN  NUMBER,
    PX_OBJECT_VERSION_NUMBER     IN OUT NOCOPY NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_profile_check_rules
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = CSC_CORE_UTILS_PVT.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL
--       p_identity_salesforce_id  IN   NUMBER     Optional  Default = NULL
--       P_CHK_RULES_Rec     IN CHK_RULES_Rec_Type  Required
--
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--
--   End of Comments
--
PROCEDURE Delete_profile_check_rules(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit                     IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level           IN   NUMBER       := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    p_Check_id                   IN   NUMBER,
    p_Sequence                   IN   NUMBER,
    p_OBJECT_VERSION_NUMBER      IN   NUMBER,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Validate_profile_check_rules

PROCEDURE Validate_profile_check_rules(
    P_Api_Name		IN	VARCHAR2,
    P_Init_Msg_List              IN   VARCHAR2 := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Validation_level           IN   NUMBER := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    P_Validation_mode            IN   VARCHAR2,
    P_CHK_RULES_Rec     IN    CHK_RULES_Rec_Type,
    --P_BLOCK_ID		IN	NUMBER,
    --P_CHECK_ID		IN	NUMBER,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    );
End CSC_PROFILE_CHECK_RULES_PVT;

 

/
