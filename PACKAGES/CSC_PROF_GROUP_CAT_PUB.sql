--------------------------------------------------------
--  DDL for Package CSC_PROF_GROUP_CAT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSC_PROF_GROUP_CAT_PUB" AUTHID CURRENT_USER as
/* $Header: cscppcas.pls 115.8 2002/11/29 07:27:33 bhroy ship $ */
-- Start of Comments
-- Package name     : CSC_PROF_GROUP_CAT_PUB
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;
--   *******************************************************
--    Start of Comments
--   -------------------------------------------------------
--    Record name:PROF_GRP_CAT_Rec_Type
--   -------------------------------------------------------
--   Parameters:
--    ROW_ID
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
       ROW_ID                          ROWID,
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

TYPE PROF_GRP_CAT_sort_rec_type IS RECORD
(
      -- Please define your own sort by record here.
      GROUP_CATEGORY_ID   NUMBER := NULL
);

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_csc_prof_group_cat
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       P_PROF_GRP_CAT_Rec     IN PROF_GRP_CAT_Rec_Type  Required
--
--   OUT :
--       x_return_status           OUT NOCOPY  VARCHAR2
--       x_msg_count               OUT NOCOPY  NUMBER
--       x_msg_data                OUT NOCOPY  VARCHAR2
--   Version : Current version 1.0
--
--   End of Comments
--

PROCEDURE Create_csc_prof_group_cat(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    px_GROUP_CATEGORY_ID         IN OUT NOCOPY      NUMBER,
    p_GROUP_ID                        NUMBER DEFAULT NULL,
    p_CATEGORY_CODE                   VARCHAR2 DEFAULT NULL,
    p_CATEGORY_SEQUENCE               NUMBER  DEFAULT NULL,
    p_CREATED_BY                      NUMBER  DEFAULT NULL,
    p_CREATION_DATE                   DATE  DEFAULT NULL,
    p_LAST_UPDATED_BY                 NUMBER  DEFAULT NULL,
    p_LAST_UPDATE_DATE                DATE  DEFAULT NULL,
    p_LAST_UPDATE_LOGIN               NUMBER  DEFAULT NULL,
    p_SEEDED_FLAG                     VARCHAR2  DEFAULT NULL,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );



PROCEDURE Create_csc_prof_group_cat(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    P_PROF_GRP_CAT_Rec     IN    PROF_GRP_CAT_Rec_Type,
    PX_GROUP_CATEGORY_ID     IN OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_csc_prof_group_cat
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       P_PROF_GRP_CAT_Rec     IN PROF_GRP_CAT_Rec_Type  Required
--
--   OUT :
--       x_return_status           OUT NOCOPY  VARCHAR2
--       x_msg_count               OUT NOCOPY  NUMBER
--       x_msg_data                OUT NOCOPY  VARCHAR2
--   Version : Current version 1.0
--
--   End of Comments
--

PROCEDURE Update_csc_prof_group_cat(
    P_Api_Version_Number         IN   NUMBER DEFAULT NULL,
    P_Init_Msg_List              IN   VARCHAR2 DEFAULT NULL,
    P_Commit                     IN   VARCHAR2 DEFAULT NULL,
    p_GROUP_CATEGORY_ID          IN   NUMBER DEFAULT NULL,
    p_GROUP_ID                        NUMBER DEFAULT NULL,
    p_CATEGORY_CODE                   VARCHAR2 DEFAULT NULL,
    p_CATEGORY_SEQUENCE               NUMBER DEFAULT NULL,
    p_CREATED_BY                      NUMBER DEFAULT NULL,
    p_CREATION_DATE                   DATE DEFAULT NULL,
    p_LAST_UPDATED_BY                 NUMBER DEFAULT NULL,
    p_LAST_UPDATE_DATE                DATE DEFAULT NULL,
    p_LAST_UPDATE_LOGIN               NUMBER DEFAULT NULL,
    p_SEEDED_FLAG                     VARCHAR2 DEFAULT NULL,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );


PROCEDURE Update_csc_prof_group_cat(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    P_PROF_GRP_CAT_Rec     IN    PROF_GRP_CAT_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_csc_prof_group_cat
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       P_PROF_GRP_CAT_Rec     IN PROF_GRP_CAT_Rec_Type  Required
--
--   OUT :
--       x_return_status           OUT NOCOPY  VARCHAR2
--       x_msg_count               OUT NOCOPY  NUMBER
--       x_msg_data                OUT NOCOPY  VARCHAR2
--
PROCEDURE Delete_csc_prof_group_cat(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    P_PROF_GRP_CAT_Rec     IN PROF_GRP_CAT_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );


End CSC_PROF_GROUP_CAT_PUB;

 

/
