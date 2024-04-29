--------------------------------------------------------
--  DDL for Package CSC_PROF_COLOR_CODE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSC_PROF_COLOR_CODE_PUB" AUTHID CURRENT_USER as
/* $Header: cscppccs.pls 115.6 2002/11/29 04:21:22 bhroy ship $ */
-- Start of Comments
-- Package name     : CSC_PROF_COLOR_CODE_PUB
-- Purpose          :
-- History          :
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
--    Required:
--    Defaults:
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

TYPE color_rec_sort_rec_type IS RECORD
(
      -- Please define your own sort by record here.
      RATING_CODE   NUMBER := NULL
);

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_prof_color_code
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       P_prof_color_rec_type_Rec     IN prof_color_Rec_Type  Required
--
--   OUT :
--       x_return_status           OUT NOCOPY  VARCHAR2
--       x_msg_count               OUT NOCOPY  NUMBER
--       x_msg_data                OUT NOCOPY  VARCHAR2
--
--   End of Comments
--

PROCEDURE Create_prof_color_code(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    px_COLOR_CODE                IN OUT NOCOPY    VARCHAR2 ,
    p_RATING_CODE                     VARCHAR2 DEFAULT NULL,
    p_LAST_UPDATE_DATE                DATE DEFAULT NULL,
    p_LAST_UPDATED_BY                 NUMBER DEFAULT NULL,
    p_CREATION_DATE                   DATE DEFAULT NULL,
    p_CREATED_BY                      NUMBER DEFAULT NULL,
    p_LAST_UPDATE_LOGIN               NUMBER DEFAULT NULL,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

PROCEDURE Create_prof_color_code(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    P_prof_color_rec     IN    prof_color_Rec_Type,
    px_COLOR_CODE     IN OUT NOCOPY  VARCHAR2,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_prof_color_code
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       P_prof_color_rec_type_Rec     IN prof_color_Rec_Type  Required
--
--   OUT :
--       x_return_status           OUT NOCOPY  VARCHAR2
--       x_msg_count               OUT NOCOPY  NUMBER
--       x_msg_data                OUT NOCOPY  VARCHAR2
--   End of Comments
--

PROCEDURE Update_prof_color_code(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    p_COLOR_CODE                      VARCHAR2 DEFAULT NULL,
    p_RATING_CODE                     VARCHAR2 DEFAULT NULL,
    p_LAST_UPDATE_DATE                DATE DEFAULT NULL,
    p_LAST_UPDATED_BY                 NUMBER DEFAULT NULL,
    p_CREATION_DATE                   DATE DEFAULT NULL,
    p_CREATED_BY                      NUMBER DEFAULT NULL,
    p_LAST_UPDATE_LOGIN               NUMBER DEFAULT NULL,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

PROCEDURE Update_prof_color_code(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    P_prof_color_rec     IN    prof_color_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

End CSC_PROF_COLOR_CODE_PUB;

 

/
