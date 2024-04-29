--------------------------------------------------------
--  DDL for Package CSC_PROFILE_GROUPS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSC_PROFILE_GROUPS_PUB" AUTHID CURRENT_USER as
/* $Header: cscppgrs.pls 115.9 2002/11/29 05:16:50 bhroy ship $ */
-- Start of Comments
-- Package name     : CSC_PROFILE_GROUPS_PUB
-- Purpose          :
-- History          :
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
--    CUSTOMER_TYPE_FLAG
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
       PARTY_TYPE		        VARCHAR2(30),
       START_DATE_ACTIVE               DATE,
       END_DATE_ACTIVE                 DATE,
       USE_IN_CUSTOMER_DASHBOARD       VARCHAR2(3),
       CUSTOMER_TYPE_FLAG              VARCHAR2(3),
       SEEDED_FLAG                     VARCHAR2(3),
       OBJECT_VERSION_NUMBER	       NUMBER,
       APPLICATION_ID                  NUMBER
);

G_MISS_PROF_GROUP_REC          PROF_GROUP_Rec_Type;

TYPE  PROF_GROUP_Tbl_Type      IS TABLE OF PROF_GROUP_Rec_Type
                                    INDEX BY BINARY_INTEGER;

G_MISS_PROF_GROUP_TBL          CSC_PROFILE_GROUPS_PVT.PROF_GROUP_Tbl_Type;

TYPE PROF_GROUP_sort_rec_type IS RECORD
(
      -- Please define your own sort by record here.
      CREATED_BY   NUMBER := NULL
);

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_profile_groups
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = CSC_CORE_UTILS_PVT.G_FALSE
--       P_PROF_GROUP_Rec     IN PROF_GROUP_Rec_Type  Required
--
--   OUT :
--       x_return_status           OUT NOCOPY  VARCHAR2
--       x_msg_count               OUT NOCOPY  NUMBER
--       x_msg_data                OUT NOCOPY  VARCHAR2
--   Version : Current version 1.0
--
--   End of Comments
--

PROCEDURE Create_profile_groups(
    PX_Group_Id			   IN OUT NOCOPY NUMBER,
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    P_GROUP_ID                   IN   NUMBER DEFAULT NULL,
    P_CREATED_BY                 IN   NUMBER DEFAULT NULL,
    P_CREATION_DATE              IN   DATE DEFAULT NULL,
    P_LAST_UPDATED_BY            IN   NUMBER DEFAULT NULL,
    P_LAST_UPDATE_DATE           IN   DATE DEFAULT NULL,
    P_LAST_UPDATE_LOGIN          IN   NUMBER DEFAULT NULL,
    P_GROUP_NAME                 IN   VARCHAR2 DEFAULT NULL,
    P_GROUP_NAME_CODE            IN   VARCHAR2 DEFAULT NULL,
    P_DESCRIPTION                IN   VARCHAR2 DEFAULT NULL,
    P_PARTY_TYPE		 IN   VARCHAR2 DEFAULT NULL,
    P_START_DATE_ACTIVE          IN   DATE DEFAULT NULL,
    P_END_DATE_ACTIVE            IN   DATE DEFAULT NULL,
    P_USE_IN_CUSTOMER_DASHBOARD  IN   VARCHAR2 DEFAULT NULL,
    P_SEEDED_FLAG         IN   VARCHAR2 DEFAULT NULL,
    X_Object_Version_Number OUT NOCOPY  NUMBER,
    P_APPLICATION_ID             IN   NUMBER DEFAULT NULL,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

PROCEDURE Create_profile_groups(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    P_PROF_GROUP_Rec     IN    PROF_GROUP_Rec_Type,
    PX_GROUP_ID     IN OUT NOCOPY  NUMBER,
    X_Object_Version_Number OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_profile_groups
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = CSC_CORE_UTILS_PVT.G_FALSE
--       p_identity_salesforce_id  IN   NUMBER     Optional  Default = NULL
--       P_PROF_GROUP_Rec     IN PROF_GROUP_Rec_Type  Required
--
--   OUT :
--       x_return_status           OUT NOCOPY  VARCHAR2
--       x_msg_count               OUT NOCOPY  NUMBER
--       x_msg_data                OUT NOCOPY  VARCHAR2
--   Version : Current version 1.0
--
--   End of Comments
--

PROCEDURE Update_profile_groups(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    P_GROUP_ID                   IN   NUMBER DEFAULT NULL,
    P_CREATED_BY                 IN   NUMBER DEFAULT NULL,
    P_CREATION_DATE              IN   DATE DEFAULT NULL,
    P_LAST_UPDATED_BY            IN   NUMBER DEFAULT NULL,
    P_LAST_UPDATE_DATE           IN   DATE DEFAULT NULL,
    P_LAST_UPDATE_LOGIN          IN   NUMBER DEFAULT NULL,
    P_GROUP_NAME                 IN   VARCHAR2 DEFAULT NULL,
    P_GROUP_NAME_CODE            IN   VARCHAR2  DEFAULT NULL,
    P_DESCRIPTION                IN   VARCHAR2 DEFAULT NULL,
    P_PARTY_TYPE		         IN   VARCHAR2 DEFAULT NULL,
    P_START_DATE_ACTIVE          IN   DATE DEFAULT NULL,
    P_END_DATE_ACTIVE            IN   DATE DEFAULT NULL,
    P_USE_IN_CUSTOMER_DASHBOARD  IN   VARCHAR2  DEFAULT NULL,
    P_SEEDED_FLAG         IN   VARCHAR2 DEFAULT NULL,
    PX_OBJECT_VERSION_NUMBER 	 IN OUT NOCOPY   NUMBER,
    P_APPLICATION_ID             IN   NUMBER  DEFAULT NULL,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

PROCEDURE Update_profile_groups(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    P_PROF_GROUP_Rec      IN     PROF_GROUP_Rec_Type,
    PX_Object_Version_Number IN OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_profile_groups
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = CSC_CORE_UTILS_PVT.G_FALSE
--       P_PROF_GROUP_Rec     IN PROF_GROUP_Rec_Type  Required
--
--   OUT :
--       x_return_status           OUT NOCOPY  VARCHAR2
--       x_msg_count               OUT NOCOPY  NUMBER
--       x_msg_data                OUT NOCOPY  VARCHAR2
--   Version : Current version 1.0
--
--   End of Comments
--
PROCEDURE Delete_profile_groups(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    P_GROUP_Id     IN NUMBER,
    P_OBJECT_VERSION_NUMBER IN NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );


End CSC_PROFILE_GROUPS_PUB;

 

/
