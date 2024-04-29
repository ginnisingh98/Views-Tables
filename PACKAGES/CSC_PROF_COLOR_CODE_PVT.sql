--------------------------------------------------------
--  DDL for Package CSC_PROF_COLOR_CODE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSC_PROF_COLOR_CODE_PVT" AUTHID CURRENT_USER as
/* $Header: cscvpccs.pls 115.5 2002/12/03 19:31:38 jamose ship $ */
-- Start of Comments
-- Package name     : CSC_PROF_COLOR_CODE_PVT
-- Purpose          :
-- History          :
-- 27 Nov 02   jamose For Fnd_Api_G_Miss* and NOCOPY changes
-- NOTE             :
-- End of Comments

-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;
--   *******************************************************
--    Start of Comments
--   -------------------------------------------------------
--    Record name:prof_color_Rec_Type
--   -------------------------------------------------------
--   Parameters:
--    COLOR_CODE
--    RATING_CODE
--    LAST_UPDATE_DATE
--    LAST_UPDATED_BY
--    CREATION_DATE
--    CREATED_BY
--    LAST_UPDATE_LOGIN
--
--
--   End of Comments

TYPE prof_color_Rec_Type IS RECORD
(
       COLOR_CODE                      VARCHAR2(30),
       RATING_CODE                     VARCHAR2(30),
       LAST_UPDATE_DATE                DATE,
       LAST_UPDATED_BY                 NUMBER,
       CREATION_DATE                   DATE,
       CREATED_BY                      NUMBER,
       LAST_UPDATE_LOGIN               NUMBER
);

G_MISS_prof_color_rec_type_REC          prof_color_Rec_Type;
TYPE  prof_color_rec_type_Tbl_Type      IS TABLE OF prof_color_Rec_Type
                                    INDEX BY BINARY_INTEGER;
G_MISS_prof_color_rec_type_TBL          prof_color_rec_type_Tbl_Type;

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_prof_color_code
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = CSC_CORE_UTILS_PVT_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = CSC_CORE_UTILS_PVT.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL
--       P_prof_color_rec_type_Rec     IN prof_color_Rec_Type  Required
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
PROCEDURE Create_prof_color_code(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit                     IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level           IN   NUMBER       := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    px_COLOR_CODE                IN OUT NOCOPY    VARCHAR2 ,
    p_RATING_CODE                IN   VARCHAR2,
    p_LAST_UPDATE_DATE           IN   DATE ,
    p_LAST_UPDATED_BY            IN   NUMBER,
    p_CREATION_DATE              IN   DATE,
    p_CREATED_BY                 IN   NUMBER,
    p_LAST_UPDATE_LOGIN          IN   NUMBER,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    );

PROCEDURE Create_prof_color_code(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit                     IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level           IN   NUMBER       := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    P_prof_color_rec     IN    prof_color_Rec_Type  := G_MISS_prof_color_rec_type_REC,
    px_COLOR_CODE     		IN OUT NOCOPY VARCHAR2,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_prof_color_code
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = CSC_CORE_UTILS_PVT_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = CSC_CORE_UTILS_PVT.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL
--       p_identity_salesforce_id  IN   NUMBER     Optional  Default = NULL
--       P_prof_color_rec_type_Rec     IN prof_color_Rec_Type  Required
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

PROCEDURE Update_prof_color_code(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit                     IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level           IN   NUMBER       := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    p_COLOR_CODE                 IN   VARCHAR2,
    p_RATING_CODE                IN   VARCHAR2,
    p_LAST_UPDATE_DATE           IN   DATE ,
    p_LAST_UPDATED_BY            IN   NUMBER,
    p_CREATION_DATE              IN   DATE DEFAULT NULL,
    p_CREATED_BY                 IN   NUMBER DEFAULT NULL,
    p_LAST_UPDATE_LOGIN          IN   NUMBER ,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    );

PROCEDURE Update_prof_color_code(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit                     IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level           IN  NUMBER       := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    P_prof_color_rec     IN    prof_color_Rec_Type,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_prof_color_code
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = CSC_CORE_UTILS_PVT_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = CSC_CORE_UTILS_PVT.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL
--       p_identity_salesforce_id  IN   NUMBER     Optional  Default = NULL
--       P_prof_color_rec_type_Rec     IN prof_color_Rec_Type  Required
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
PROCEDURE Delete_prof_color_code(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit                     IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level           IN   NUMBER       := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    P_COLOR_CODE			   IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    );


-- Start of Comments
--
-- Item level validation procedures
--
-- p_validation_mode is a constant defined in CSC_CORE_UTILS_PVT package
--                  For create: G_CREATE, for update: G_UPDATE
-- Note: 1. This is automated generated item level validation procedure.
--          The actual validation detail is needed to be added.
--
-- End of Comments

PROCEDURE Validate_COLOR_CODE (
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_COLOR_CODE                IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    );

-- Start of Comments
--
-- Item level validation procedures
--
-- p_validation_mode is a constant defined in CSC_CORE_UTILS_PVT package
--                  For create: G_CREATE, for update: G_UPDATE
-- Note: 1. This is automated generated item level validation procedure.
--          The actual validation detail is needed to be added.
--
-- End of Comments

PROCEDURE Validate_RATING_CODE (
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_RATING_CODE                IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    );


-- Start of Comments
--
--  validation procedures
--
-- p_validation_mode is a constant defined in CSC_CORE_UTILS_PVT package
--                  For create: G_CREATE, for update: G_UPDATE
-- Note: 1. This is automated generated item level validation procedure.
--          The actual validation detail is needed to be added.
--       2. We can also validate table instead of record. There will be an option for user to choose.
-- End of Comments

PROCEDURE Validate_prof_color_code(
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Validation_level           IN   NUMBER := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    P_Validation_mode            IN   VARCHAR2,
    P_prof_color_rec_type_Rec     IN    prof_color_Rec_Type,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    );
End CSC_PROF_COLOR_CODE_PVT;

 

/
