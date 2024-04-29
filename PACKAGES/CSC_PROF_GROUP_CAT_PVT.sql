--------------------------------------------------------
--  DDL for Package CSC_PROF_GROUP_CAT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSC_PROF_GROUP_CAT_PVT" AUTHID CURRENT_USER as
/* $Header: cscvpcas.pls 115.7 2002/12/03 19:27:16 jamose ship $ */
-- Start of Comments
-- Package name     : CSC_PROF_GROUP_CAT_PVT
-- Purpose          :
-- History          :
-- 27 Nov 02   jamose For Fnd_Api_G_Miss* and NOCOPY changes
-- NOTE             :
-- End of Comments

-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;
l_dummy varchar2(100);
--   *******************************************************
--    Start of Comments
--   -------------------------------------------------------
--    Record name:PROF_GRP_CAT_Rec_Type
--   -------------------------------------------------------
--   Parameters:
--    GROUP_CATEGORY_ID
--    GROUP_ID
--    CATEGORY_CODE
--    CATEGORY_SEQUENCE
--    CREATED_BY
--    CREATION_DATE
--    LAST_UPDATED_BY
--    LAST_UPDATE_DATE
--    LAST_UPDATE_LOGIN
--    SEEDED_FLAG
--
--    Required:
--    Defaults:
--
--   End of Comments

TYPE PROF_GRP_CAT_Rec_Type IS RECORD
(
       GROUP_CATEGORY_ID               NUMBER,
       GROUP_ID                        NUMBER,
       CATEGORY_CODE                   VARCHAR2(30),
       CATEGORY_SEQUENCE               NUMBER,
       CREATED_BY                      NUMBER,
       CREATION_DATE                   DATE,
       LAST_UPDATED_BY                 NUMBER,
       LAST_UPDATE_DATE                DATE,
       LAST_UPDATE_LOGIN               NUMBER,
       SEEDED_FLAG                     VARCHAR2(3)
);

G_MISS_PROF_GRP_CAT_REC          PROF_GRP_CAT_Rec_Type;
TYPE  PROF_GRP_CAT_Tbl_Type      IS TABLE OF PROF_GRP_CAT_Rec_Type
                                    INDEX BY BINARY_INTEGER;
G_MISS_PROF_GRP_CAT_TBL          PROF_GRP_CAT_Tbl_Type;

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_csc_prof_group_cat
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       P_PROF_GRP_CAT_Rec     IN PROF_GRP_CAT_Rec_Type  Required
--
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--
--   End of Comments
--
PROCEDURE Create_csc_prof_group_cat(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit                     IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level           IN   NUMBER       := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    px_GROUP_CATEGORY_ID         IN OUT NOCOPY     NUMBER,
    p_GROUP_ID                   IN   NUMBER,
    p_CATEGORY_CODE              IN   VARCHAR2,
    p_CATEGORY_SEQUENCE          IN   NUMBER,
    p_CREATED_BY                 IN   NUMBER,
    p_CREATION_DATE              IN   DATE,
    p_LAST_UPDATED_BY            IN   NUMBER,
    p_LAST_UPDATE_DATE           IN   DATE,
    p_LAST_UPDATE_LOGIN          IN   NUMBER,
    p_SEEDED_FLAG                IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    );

PROCEDURE Create_csc_prof_group_cat(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit                     IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level           IN   NUMBER       := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    PX_GROUP_CATEGORY_ID     IN OUT NOCOPY  NUMBER,
    P_PROF_GRP_CAT_Rec     IN    PROF_GRP_CAT_Rec_Type  := G_MISS_PROF_GRP_CAT_REC,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_csc_prof_group_cat
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       P_PROF_GRP_CAT_Rec     IN PROF_GRP_CAT_Rec_Type  Required
--
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--
--   End of Comments
--
PROCEDURE Update_csc_prof_group_cat(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit                     IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level           IN   NUMBER       := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    p_GROUP_CATEGORY_ID          IN   NUMBER,
    p_GROUP_ID                   IN   NUMBER,
    p_CATEGORY_CODE              IN   VARCHAR2,
    p_CATEGORY_SEQUENCE          IN   NUMBER,
    p_CREATED_BY                 IN   NUMBER DEFAULT NULL,
    p_CREATION_DATE              IN   DATE DEFAULT NULL,
    p_LAST_UPDATED_BY            IN   NUMBER,
    p_LAST_UPDATE_DATE           IN   DATE,
    p_LAST_UPDATE_LOGIN          IN   NUMBER,
    p_SEEDED_FLAG                IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    );

PROCEDURE Update_csc_prof_group_cat(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit                     IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level           IN  NUMBER       := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    P_PROF_GRP_CAT_Rec     IN    PROF_GRP_CAT_Rec_Type,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_csc_prof_group_cat
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       P_PROF_GRP_CAT_Rec     IN PROF_GRP_CAT_Rec_Type  Required
--
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--
--   End of Comments
--

PROCEDURE Delete_csc_prof_group_cat(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit                     IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level           IN   NUMBER       := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    P_PROF_GRP_CAT_Rec     IN PROF_GRP_CAT_Rec_Type,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    );




-- Start of Comments
--
-- Item level validation procedures
--
--
-- End of Comments

PROCEDURE Validate_GROUP_CATEGORY_ID (
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_GROUP_CATEGORY_ID                IN   NUMBER,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    );

-- Start of Comments
--
-- Item level validation procedures
--
--
-- End of Comments

PROCEDURE Validate_GROUP_ID (
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_GROUP_ID                IN   NUMBER,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    );

-- Start of Comments
--
-- Item level validation procedures
--
--
-- End of Comments

PROCEDURE Validate_CATEGORY_CODE (
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_CATEGORY_CODE                IN   VARCHAR2,
    P_GROUP_ID			   IN   NUMBER,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    );


-- Start of Comments
--
-- Item level validation procedures
--
-- End of Comments

PROCEDURE Validate_CATEGORY_SEQUENCE (
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_CATEGORY_SEQUENCE                IN   NUMBER,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    );

-- Start of Comments
--
-- Record level validation procedures
--
-- End of Comments


-- Start of Comments
--
--  validation procedures
--
-- End of Comments

PROCEDURE Validate_csc_prof_group_cat(
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Validation_level           IN   NUMBER := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    P_Validation_mode            IN   VARCHAR2,
    P_PROF_GRP_CAT_Rec     IN    PROF_GRP_CAT_Rec_Type,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    );
End CSC_PROF_GROUP_CAT_PVT;

 

/
