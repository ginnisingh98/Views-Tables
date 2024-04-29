--------------------------------------------------------
--  DDL for Package CSC_PROFILE_GROUPS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSC_PROFILE_GROUPS_PVT" AUTHID CURRENT_USER as
/* $Header: cscvpgrs.pls 115.8 2002/12/03 18:29:49 jamose ship $ */
-- Start of Comments
-- Package name     : CSC_PROFILE_GROUPS_PVT
-- Purpose          :
-- History          :
-- 29 Nov 02   jamose made changes for the NOCOPY and FND_API.G_MISS*
-- NOTE             :
-- End of Comments

-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;
--   *******************************************************
--    Start of Comments
--   -------------------------------------------------------
--    Record name:PROF_GROUP_Rec_Type
--   -------------------------------------------------------
--   Parameters:
--    GROUP_ID
--    CREATED_BY
--    CREATION_DATE
--    LAST_UPDATED_BY
--    LAST_UPDATE_DATE
--    LAST_UPDATE_LOGIN
--    GROUP_NAME
--    GROUP_NAME_CODE
--    DESCRIPTION
--    START_DATE_ACTIVE
--    END_DATE_ACTIVE
--    USE_IN_CUSTOMER_DASHBOARD
--    SEEDED_FLAG
--    APPLICATION_ID
--
--
--   End of Comments

TYPE PROF_GROUP_Rec_Type IS RECORD
(
       GROUP_ID                        NUMBER,
       CREATED_BY                      NUMBER,
       CREATION_DATE                   DATE,
       LAST_UPDATED_BY                 NUMBER,
       LAST_UPDATE_DATE                DATE,
       LAST_UPDATE_LOGIN               NUMBER,
       GROUP_NAME                      VARCHAR2(240),
       GROUP_NAME_CODE                 VARCHAR2(240),
       DESCRIPTION                     VARCHAR2(720),
       PARTY_TYPE		                  VARCHAR2(30),
       START_DATE_ACTIVE               DATE,
       END_DATE_ACTIVE                 DATE,
       USE_IN_CUSTOMER_DASHBOARD       VARCHAR2(3),
       SEEDED_FLAG                     VARCHAR2(3),
       OBJECT_VERSION_NUMBER 	         NUMBER,
       APPLICATION_ID                  NUMBER

);

G_MISS_PROF_GROUP_REC          PROF_GROUP_Rec_Type;
TYPE  PROF_GROUP_Tbl_Type      IS TABLE OF PROF_GROUP_Rec_Type INDEX BY BINARY_INTEGER;
G_MISS_PROF_GROUP_TBL          PROF_GROUP_Tbl_Type;

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_profile_groups
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = CSC_CORE_UTILS_PVT.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL
--       P_PROF_GROUP_Rec     IN PROF_GROUP_Rec_Type  Required
--
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--
--   End of Comments
--

PROCEDURE Create_profile_groups(
    PX_Group_Id			         IN OUT NOCOPY NUMBER,
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit                     IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level           IN   NUMBER       := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    P_GROUP_ID                   IN   NUMBER DEFAULT NULL,
    P_CREATED_BY                 IN   NUMBER,
    P_CREATION_DATE              IN   DATE,
    P_LAST_UPDATED_BY            IN   NUMBER,
    P_LAST_UPDATE_DATE           IN   DATE,
    P_LAST_UPDATE_LOGIN          IN   NUMBER,
    P_GROUP_NAME                 IN   VARCHAR2,
    P_GROUP_NAME_CODE            IN   VARCHAR2,
    P_DESCRIPTION                IN   VARCHAR2,
    P_PARTY_TYPE		            IN   VARCHAR2,
    P_START_DATE_ACTIVE          IN   DATE,
    P_END_DATE_ACTIVE            IN   DATE,
    P_USE_IN_CUSTOMER_DASHBOARD  IN   VARCHAR2,
    P_SEEDED_FLAG                IN   VARCHAR2,
    X_Object_Version_Number     OUT NOCOPY NUMBER,
    P_APPLICATION_ID             IN   NUMBER,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    );

PROCEDURE Create_profile_groups(
    PX_Group_Id			   IN OUT NOCOPY NUMBER,
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit                     IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level           IN   NUMBER       := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    P_PROF_GROUP_Rec     IN    PROF_GROUP_Rec_Type  := G_MISS_PROF_GROUP_REC,
    X_Object_Version_Number  OUT NOCOPY NUMBER,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_profile_groups
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = CSC_CORE_UTILS_PVT.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL
--       p_identity_salesforce_id  IN   NUMBER     Optional  Default = NULL
--       P_PROF_GROUP_Rec     IN PROF_GROUP_Rec_Type  Required
--
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--
--   End of Comments
--


PROCEDURE Update_profile_groups(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit                     IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level           IN   NUMBER       := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    P_GROUP_ID                   IN   NUMBER ,
    P_CREATED_BY                 IN   NUMBER ,
    P_CREATION_DATE              IN   DATE 	,
    P_LAST_UPDATED_BY            IN   NUMBER ,
    P_LAST_UPDATE_DATE           IN   DATE 	,
    P_LAST_UPDATE_LOGIN          IN   NUMBER ,
    P_GROUP_NAME                 IN   VARCHAR2,
    P_GROUP_NAME_CODE            IN   VARCHAR2,
    P_DESCRIPTION                IN   VARCHAR2,
    P_PARTY_TYPE		         IN   VARCHAR2 ,
    P_START_DATE_ACTIVE          IN   DATE 	,
    P_END_DATE_ACTIVE            IN   DATE 	,
    P_USE_IN_CUSTOMER_DASHBOARD  IN   VARCHAR2,
    P_SEEDED_FLAG         IN   VARCHAR2 ,
    PX_OBJECT_VERSION_NUMBER 	   IN OUT NOCOPY  NUMBER,
    P_APPLICATION_ID             IN   NUMBER ,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    );



PROCEDURE Update_profile_groups(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit                     IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level           IN  NUMBER       := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    P_PROF_GROUP_Rec     IN    PROF_GROUP_Rec_Type,
    PX_Object_Version_Number   IN OUT NOCOPY NUMBER,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_profile_groups
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = CSC_CORE_UTILS_PVT.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL
--       p_identity_salesforce_id  IN   NUMBER     Optional  Default = NULL
--       P_PROF_GROUP_Rec     IN PROF_GROUP_Rec_Type  Required
--
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--
--   End of Comments
--

PROCEDURE Delete_profile_groups(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit                     IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level           IN   NUMBER       := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    P_GROUP_ID                   IN   NUMBER,
    P_OBJECT_VERSION_NUMBER      IN    NUMBER,
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
--
-- End of Comments

PROCEDURE Validate_GROUP_NAME (
    P_Api_Name			 IN	VARCHAR2,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_GROUP_NAME                IN   VARCHAR2,
    P_GROUP_ID                IN   NUMBER,
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
--
-- End of Comments

PROCEDURE Validate_GROUP_NAME_CODE (
    P_Api_Name			 IN	VARCHAR2,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_GROUP_NAME_CODE                IN   VARCHAR2,
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
--
-- End of Comments

PROCEDURE Validate_IN_CUST_DASHBOARD (
    P_Api_Name			 IN	VARCHAR2,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_USE_IN_CUSTOMER_DASHBOARD                IN   VARCHAR2,
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
--
-- End of Comments

PROCEDURE Validate_SEEDED_FLAG (
    P_Api_Name			 IN	VARCHAR2,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_SEEDED_FLAG                IN   VARCHAR2,
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
-- End of Comments

PROCEDURE Validate_profile_groups(
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Validation_level           IN   NUMBER := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    P_Validation_mode            IN   VARCHAR2,
    P_PROF_GROUP_Rec     IN    PROF_GROUP_Rec_Type,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    );
End CSC_PROFILE_GROUPS_PVT;

 

/
