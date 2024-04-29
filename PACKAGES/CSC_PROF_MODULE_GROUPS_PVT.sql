--------------------------------------------------------
--  DDL for Package CSC_PROF_MODULE_GROUPS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSC_PROF_MODULE_GROUPS_PVT" AUTHID CURRENT_USER as
/* $Header: cscvpmgs.pls 115.15 2002/12/09 08:43:50 agaddam ship $ */
-- Start of Comments
-- Package name     : CSC_PROF_MODULE_GROUPS_PVT
-- Purpose          :
-- History          :
--  26 Nov 02 JAmose  Addition of NOCOPY and the Removal of Fnd_Api.G_MISS*
--                    from the definition for the performance reason
-- NOTE             :
-- End of Comments

-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;
--   *******************************************************
--    Start of Comments
--   -------------------------------------------------------
--    Record name:PROF_MODULE_GRP_Rec_Type
--   -------------------------------------------------------
--   Parameters:
--    MODULE_GROUP_ID
--    FORM_FUNCTION_ID
--    PARTY_TYPE
--    GROUP_ID
--    DASHBOARD_GROUP_FLAG
--    CURRENCY_CODE
--    LAST_UPDATE_DATE
--    LAST_UPDATED_BY
--    CREATION_DATE
--    CREATED_BY
--    LAST_UPDATE_LOGIN
--    SEEDED_FLAG
--    APPLICATION_ID
--    DASHBOARD_GROUP_ID
--
--    Required:
--    Defaults:
--
--   End of Comments

TYPE PROF_MODULE_GRP_Rec_Type IS RECORD
(
       MODULE_GROUP_ID                 NUMBER,
       FORM_FUNCTION_ID                NUMBER,
       FORM_FUNCTION_NAME              VARCHAR2(30),
       RESPONSIBILITY_ID               NUMBER,
       RESP_APPL_ID                    NUMBER,
       PARTY_TYPE                      VARCHAR2(30),
       GROUP_ID                        NUMBER,
       DASHBOARD_GROUP_FLAG            VARCHAR2(3),
       CURRENCY_CODE                   VARCHAR2(15),
       LAST_UPDATE_DATE                DATE,
       LAST_UPDATED_BY                 NUMBER,
       CREATION_DATE                   DATE,
       CREATED_BY                      NUMBER,
       LAST_UPDATE_LOGIN               NUMBER,
       SEEDED_FLAG                     VARCHAR2(3),
       APPLICATION_ID                  NUMBER,
       DASHBOARD_GROUP_ID              NUMBER
);

G_MISS_PROF_MODULE_GRP_REC          PROF_MODULE_GRP_Rec_Type;
TYPE  PROF_MODULE_GRP_Tbl_Type      IS TABLE OF PROF_MODULE_GRP_Rec_Type
                                    INDEX BY BINARY_INTEGER;
G_MISS_PROF_MODULE_GRP_TBL          PROF_MODULE_GRP_Tbl_Type;

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_prof_module_groups
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       P_PROF_MODULE_GRP_Rec     IN PROF_MODULE_GRP_Rec_Type  Required
--
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--
--   End of Comments
--

PROCEDURE Create_prof_module_groups(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit                     IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level           IN   NUMBER       := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    PX_MODULE_GROUP_ID           IN OUT  NOCOPY NUMBER,
    p_FORM_FUNCTION_ID           NUMBER,
    p_FORM_FUNCTION_NAME         VARCHAR2,
    p_RESPONSIBILITY_ID          NUMBER,
    p_RESP_APPL_ID               NUMBER,
    p_PARTY_TYPE                 VARCHAR2,
    p_GROUP_ID                   NUMBER,
    p_DASHBOARD_GROUP_FLAG       VARCHAR2,
    p_CURRENCY_CODE              VARCHAR2,
    p_LAST_UPDATE_DATE           DATE,
    p_LAST_UPDATED_BY            NUMBER,
    p_CREATION_DATE              DATE,
    p_CREATED_BY                 NUMBER,
    p_LAST_UPDATE_LOGIN          NUMBER,
    p_SEEDED_FLAG                VARCHAR2,
    p_APPLICATION_ID             NUMBER,
    p_DASHBOARD_GROUP_ID         NUMBER,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    );


PROCEDURE Create_prof_module_groups(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit                     IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level           IN   NUMBER       := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    P_PROF_MODULE_GRP_Rec     IN    PROF_MODULE_GRP_Rec_Type  := G_MISS_PROF_MODULE_GRP_REC,
    PX_MODULE_GROUP_ID     IN OUT NOCOPY NUMBER,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_prof_module_groups
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_identity_salesforce_id  IN   NUMBER     Optional  Default = NULL
--       P_PROF_MODULE_GRP_Rec     IN PROF_MODULE_GRP_Rec_Type  Required
--
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--
--   End of Comments
--
PROCEDURE Update_prof_module_groups(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit                     IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level           IN   NUMBER       := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    P_MODULE_GROUP_ID     		  NUMBER,
    p_FORM_FUNCTION_ID          NUMBER,
    p_FORM_FUNCTION_NAME        VARCHAR2,
    p_RESPONSIBILITY_ID         NUMBER,
    p_RESP_APPL_ID               NUMBER,
    p_PARTY_TYPE                VARCHAR2,
    p_GROUP_ID                  NUMBER,
    p_DASHBOARD_GROUP_FLAG      VARCHAR2,
    p_CURRENCY_CODE             VARCHAR2,
    p_LAST_UPDATE_DATE          DATE,
    p_LAST_UPDATED_BY           NUMBER,
    p_CREATION_DATE             DATE DEFAULT NULL,
    p_CREATED_BY                NUMBER DEFAULT NULL,
    p_LAST_UPDATE_LOGIN         NUMBER,
    p_SEEDED_FLAG               VARCHAR2,
    p_APPLICATION_ID            NUMBER,
    p_DASHBOARD_GROUP_ID        NUMBER,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    );

PROCEDURE Update_prof_module_groups(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit                     IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level           IN  NUMBER       := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    P_PROF_MODULE_GRP_Rec     IN    PROF_MODULE_GRP_Rec_Type,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_prof_module_groups
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_identity_salesforce_id  IN   NUMBER     Optional  Default = NULL
--       P_PROF_MODULE_GRP_Rec     IN PROF_MODULE_GRP_Rec_Type  Required
--
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--
--   End of Comments
--

PROCEDURE Delete_prof_module_groups(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit                     IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level           IN   NUMBER       := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    P_PROF_MODULE_GRP_Id         IN NUMBER,
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

PROCEDURE Validate_MODULE_GROUP_ID (
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_MODULE_GROUP_ID                IN   NUMBER,
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

PROCEDURE Validate_FORM_FUNCTION_ID (
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_FORM_FUNCTION_ID                IN   NUMBER,
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

PROCEDURE Validate_RESPONSIBILITY_ID (
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_RESPONSIBILITY_ID          IN   NUMBER,
    p_RESP_APPL_ID               IN   NUMBER,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    );


PROCEDURE Validate_PARTY_TYPE (
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PARTY_TYPE                IN   VARCHAR2,
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

PROCEDURE Validate_GROUP_ID (
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_GROUP_ID                IN   NUMBER,
    P_PARTY_TYPE              IN   VARCHAR2,
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

PROCEDURE Validate_DASHBOARD_GROUP_FLAG (
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_DASHBOARD_GROUP_FLAG                IN   VARCHAR2,
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

PROCEDURE Validate_CURRENCY_CODE (
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_CURRENCY_CODE                IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    );


PROCEDURE Validate_PROF_MODULE_GRP_Rec(
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PROF_MODULE_GRP_Rec     IN    PROF_MODULE_GRP_Rec_Type,
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

PROCEDURE Validate_prof_module_groups(
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Validation_level           IN   NUMBER := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    P_Validation_mode            IN   VARCHAR2,
    P_PROF_MODULE_GRP_Rec     IN    PROF_MODULE_GRP_Rec_Type,
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


PROCEDURE Validate_DASHBOARD_GROUP_ID (
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_DASHBOARD_GROUP_ID         IN   NUMBER,
    P_PARTY_TYPE                 IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    );

End CSC_PROF_MODULE_GROUPS_PVT;

 

/
