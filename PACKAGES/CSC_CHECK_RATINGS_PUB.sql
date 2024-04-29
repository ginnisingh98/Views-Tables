--------------------------------------------------------
--  DDL for Package CSC_CHECK_RATINGS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSC_CHECK_RATINGS_PUB" AUTHID CURRENT_USER as
/* $Header: cscppras.pls 115.10 2002/11/29 04:05:02 bhroy ship $ */
-- Start of Comments
-- Package name     : CSC_CHECK_RATINGS_PUB
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;
--   *******************************************************
--    Start of Comments
--   -------------------------------------------------------
--    Record name:CHK_RATING_Rec_Type
--   -------------------------------------------------------
--   Parameters:
--    CHECK_ID
--    CHECK_RATING_GRADE
--    RATING_COLOR_ID
--    RATING_CODE
--    COLOR_CODE
--    RANGE_LOW_VALUE
--    RANGE_HIGH_VALUE
--    LAST_UPDATE_DATE
--    LAST_UPDATED_BY
--    CREATION_DATE
--    CREATED_BY
--    LAST_UPDATE_LOGIN
--    SEEDED_FLAG
--
--    Required:
--    Defaults:
--
--   End of Comments

TYPE CHK_RATING_Rec_Type IS RECORD
(
       CHECK_RATING_ID                 NUMBER,
       CHECK_ID                        NUMBER,
       CHECK_RATING_GRADE              VARCHAR2(9),
       RATING_COLOR_ID                 NUMBER,
       RATING_CODE                     VARCHAR2(30),
       COLOR_CODE                      VARCHAR2(30),
       RANGE_LOW_VALUE                 VARCHAR2(240),
       RANGE_HIGH_VALUE                VARCHAR2(240),
       LAST_UPDATE_DATE                DATE,
       LAST_UPDATED_BY                 NUMBER,
       CREATION_DATE                   DATE,
       CREATED_BY                      NUMBER,
       LAST_UPDATE_LOGIN               NUMBER,
       SEEDED_FLAG                     VARCHAR2(3)
);

G_MISS_CHK_RATING_REC          CHK_RATING_Rec_Type;
TYPE  CHK_RATING_Tbl_Type      IS TABLE OF CHK_RATING_Rec_Type
                                    INDEX BY BINARY_INTEGER;
G_MISS_CHK_RATING_TBL          CSC_CHECK_RATINGS_PVT.CHK_RATING_Tbl_Type;


--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_check_ratings
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = CSC_CORE_UTILS_PVT.G_FALSE
--       P_CHK_RATING_Rec     IN CHK_RATING_Rec_Type  Required
--
--   OUT :
--       x_return_status           OUT NOCOPY  VARCHAR2
--       x_msg_count               OUT NOCOPY  NUMBER
--       x_msg_data                OUT NOCOPY  VARCHAR2
--   Version : Current version 1.0
--
--   End of Comments
--
PROCEDURE Create_check_ratings(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    p_validation_level           IN   NUMBER  ,
    px_CHECK_RATING_ID            IN OUT NOCOPY  NUMBER,
    p_CHECK_ID                   IN   NUMBER,
    p_CHECK_RATING_GRADE        IN   VARCHAR2,
    p_RATING_COLOR_ID            IN   NUMBER,
    p_RATING_CODE                IN   VARCHAR2,
    p_COLOR_CODE                 IN   VARCHAR2,
    p_RANGE_LOW_VALUE            IN   VARCHAR2,
    p_RANGE_HIGH_VALUE           IN   VARCHAR2,
    p_LAST_UPDATE_DATE           IN   DATE,
    p_LAST_UPDATED_BY            IN   NUMBER,
    p_CREATION_DATE              IN   DATE,
    p_CREATED_BY                 IN   NUMBER,
    p_LAST_UPDATE_LOGIN          IN   NUMBER,
    p_SEEDED_FLAG                IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );



PROCEDURE Create_check_ratings(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    p_validation_level           IN   NUMBER  ,
    px_Check_Rating_ID		 IN OUT NOCOPY   NUMBER,
    P_CHK_RATING_Rec     	IN    CHK_RATING_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_check_ratings
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = CSC_CORE_UTILS_PVT.G_FALSE
--       P_CHK_RATING_Rec     IN CHK_RATING_Rec_Type  Required
--
--   OUT :
--       x_return_status           OUT NOCOPY  VARCHAR2
--       x_msg_count               OUT NOCOPY  NUMBER
--       x_msg_data                OUT NOCOPY  VARCHAR2
--   Version : Current version 1.0
--
--   End of Comments
--

PROCEDURE Update_check_ratings(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    p_validation_level           IN   NUMBER   DEFAULT NULL,
    p_CHECK_RATING_ID            IN   NUMBER DEFAULT NULL,
    p_CHECK_ID                   IN   NUMBER DEFAULT NULL,
    p_CHECK_RATING_GRADE         IN   VARCHAR2 DEFAULT NULL,
    p_RATING_COLOR_ID            IN   NUMBER DEFAULT NULL,
    p_RATING_CODE                IN   VARCHAR2 DEFAULT NULL,
    p_COLOR_CODE                 IN   VARCHAR2 DEFAULT NULL,
    p_RANGE_LOW_VALUE            IN   VARCHAR2 DEFAULT NULL,
    p_RANGE_HIGH_VALUE           IN   VARCHAR2 DEFAULT NULL,
    p_LAST_UPDATE_DATE           IN   DATE DEFAULT NULL,
    p_LAST_UPDATED_BY            IN   NUMBER DEFAULT NULL,
    p_CREATION_DATE              IN   DATE DEFAULT NULL,
    p_CREATED_BY                 IN   NUMBER DEFAULT NULL,
    p_LAST_UPDATE_LOGIN          IN   NUMBER DEFAULT NULL,
    p_SEEDED_FLAG                IN   VARCHAR2 DEFAULT NULL,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

PROCEDURE Update_check_ratings(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    p_validation_level           IN  NUMBER DEFAULT NULL,
    P_CHK_RATING_Rec    	   IN    CHK_RATING_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_check_ratings
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = CSC_CORE_UTILS_PVT.G_FALSE
--       P_CHK_RATING_Rec     IN CHK_RATING_Rec_Type  Required
--
--   OUT :
--       x_return_status           OUT NOCOPY  VARCHAR2
--       x_msg_count               OUT NOCOPY  NUMBER
--       x_msg_data                OUT NOCOPY  VARCHAR2
--   Version : Current version 1.0
--
--   End of Comments
--
PROCEDURE Delete_check_ratings(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    p_validation_level           IN   NUMBER,
    P_CHECK_RATING_ID     IN NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );
END;

 

/
