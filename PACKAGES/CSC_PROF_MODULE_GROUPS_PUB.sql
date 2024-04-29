--------------------------------------------------------
--  DDL for Package CSC_PROF_MODULE_GROUPS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSC_PROF_MODULE_GROUPS_PUB" AUTHID CURRENT_USER as
/* $Header: cscppmgs.pls 115.14 2002/12/09 08:44:47 agaddam ship $ */
-- Start of Comments
-- Package name     : CSC_PROF_MODULE_GROUPS_PUB
-- Purpose          :
-- History          :
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
--    ROW_ID
--    MODULE_GROUP_ID
--    FORM_FUNCTION_ID
--    FORM_FUNCTION_NAME
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
       ROW_ID                          ROWID,
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

TYPE PROF_MODULE_GRP_sort_rec_type IS RECORD
(
      -- Please define your own sort by record here.
      MODULE_GROUP_ID   NUMBER := NULL
);

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_prof_module_groups
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       P_PROF_MODULE_GRP_Rec     IN PROF_MODULE_GRP_Rec_Type  Required
--
--   OUT :
--       x_return_status           OUT NOCOPY  VARCHAR2
--       x_msg_count               OUT NOCOPY  NUMBER
--       x_msg_data                OUT NOCOPY  VARCHAR2
--
--   End of Comments
--

PROCEDURE Create_prof_module_groups(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    PX_MODULE_GROUP_ID     IN OUT NOCOPY  NUMBER,
    p_FORM_FUNCTION_ID                NUMBER DEFAULT NULL,
    p_FORM_FUNCTION_NAME              VARCHAR2 DEFAULT NULL,
    p_RESPONSIBILITY_ID               NUMBER DEFAULT NULL,
    p_RESP_APPL_ID               NUMBER DEFAULT NULL,
    p_PARTY_TYPE                      VARCHAR2 DEFAULT NULL,
    p_GROUP_ID                        NUMBER DEFAULT NULL,
    p_DASHBOARD_GROUP_FLAG            VARCHAR2 DEFAULT NULL,
    p_CURRENCY_CODE                   VARCHAR2 DEFAULT NULL,
    p_LAST_UPDATE_DATE                DATE DEFAULT NULL,
    p_LAST_UPDATED_BY                 NUMBER DEFAULT NULL,
    p_CREATION_DATE                   DATE DEFAULT NULL,
    p_CREATED_BY                      NUMBER DEFAULT NULL,
    p_LAST_UPDATE_LOGIN               NUMBER DEFAULT NULL,
    p_SEEDED_FLAG                     VARCHAR2 DEFAULT NULL,
    p_APPLICATION_ID                  NUMBER DEFAULT NULL,
    p_DASHBOARD_GROUP_ID              NUMBER DEFAULT NULL,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );


PROCEDURE Create_prof_module_groups(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    P_PROF_MODULE_GRP_Rec     IN    PROF_MODULE_GRP_Rec_Type,
    PX_MODULE_GROUP_ID     IN OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_prof_module_groups
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       P_PROF_MODULE_GRP_Rec     IN PROF_MODULE_GRP_Rec_Type  Required
--
--   OUT :
--       x_return_status           OUT NOCOPY  VARCHAR2
--       x_msg_count               OUT NOCOPY  NUMBER
--       x_msg_data                OUT NOCOPY  VARCHAR2
--   Version : Current version 1.0
--
--   End of Comments
--

PROCEDURE Update_prof_module_groups(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    P_MODULE_GROUP_ID     		  NUMBER DEFAULT NULL,
    p_FORM_FUNCTION_ID                NUMBER DEFAULT NULL,
    p_FORM_FUNCTION_NAME              VARCHAR2 DEFAULT NULL,
    p_RESPONSIBILITY_ID               NUMBER DEFAULT NULL,
    p_RESP_APPL_ID               NUMBER DEFAULT NULL,
    p_PARTY_TYPE                      VARCHAR2 DEFAULT NULL,
    p_GROUP_ID                        NUMBER DEFAULT NULL,
    p_DASHBOARD_GROUP_FLAG            VARCHAR2 DEFAULT NULL,
    p_CURRENCY_CODE                   VARCHAR2 DEFAULT NULL,
    p_LAST_UPDATE_DATE                DATE DEFAULT NULL,
    p_LAST_UPDATED_BY                 NUMBER DEFAULT NULL,
    p_CREATION_DATE                   DATE DEFAULT NULL,
    p_CREATED_BY                      NUMBER DEFAULT NULL,
    p_LAST_UPDATE_LOGIN               NUMBER DEFAULT NULL,
    p_SEEDED_FLAG                     VARCHAR2 DEFAULT NULL,
    p_APPLICATION_ID                  NUMBER DEFAULT NULL,
    p_DASHBOARD_GROUP_ID              NUMBER DEFAULT NULL,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );


PROCEDURE Update_prof_module_groups(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    P_PROF_MODULE_GRP_Rec     IN    PROF_MODULE_GRP_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_prof_module_groups
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       P_PROF_MODULE_GRP_Rec     IN PROF_MODULE_GRP_Rec_Type  Required
--
--   OUT :
--       x_return_status           OUT NOCOPY  VARCHAR2
--       x_msg_count               OUT NOCOPY  NUMBER
--       x_msg_data                OUT NOCOPY  VARCHAR2
--   Version : Current version 1.0
--
--   End of Comments
--
PROCEDURE Delete_prof_module_groups(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    P_PROF_MODULE_GRP_Rec     IN PROF_MODULE_GRP_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );


End CSC_PROF_MODULE_GROUPS_PUB;

 

/
