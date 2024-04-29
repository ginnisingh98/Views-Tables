--------------------------------------------------------
--  DDL for Package CSC_CHECK_RATINGS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSC_CHECK_RATINGS_PVT" AUTHID CURRENT_USER as
/* $Header: cscvpras.pls 115.9 2002/12/03 18:01:41 jamose ship $ */
-- Start of Comments
-- Package name     : CSC_CHECK_RATINGS_PVT
-- Purpose          :
-- History          :
-- 18 Nov 02   jamose made changes for the NOCOPY and FND_API.G_MISS*
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
--    CHECK_RATING_ID
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
G_MISS_CHK_RATING_TBL          CHK_RATING_Tbl_Type;

TYPE RATE_ID_Tbl_Type		 IS TABLE OF NUMBER
						INDEX BY BINARY_INTEGER;


--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_check_ratings
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = CSC_CORE_UTILS_PVT.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL
--       P_CHK_RATING_Rec     IN CHK_RATING_Rec_Type  Required
--
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--
--   End of Comments
--
PROCEDURE Create_check_ratings(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit                     IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level           IN   NUMBER       := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    px_CHECK_RATING_ID            IN OUT NOCOPY NUMBER ,
    p_CHECK_ID                   IN   NUMBER ,
    p_CHECK_RATING_GRADE        IN   VARCHAR2,
    p_RATING_COLOR_ID            IN   NUMBER DEFAULT NULL,
    p_RATING_CODE                IN   VARCHAR2 ,
    p_COLOR_CODE                 IN   VARCHAR2 ,
    p_RANGE_LOW_VALUE            IN   VARCHAR2 ,
    p_RANGE_HIGH_VALUE           IN   VARCHAR2 ,
    p_LAST_UPDATE_DATE           IN   DATE ,
    p_LAST_UPDATED_BY            IN   NUMBER,
    p_CREATION_DATE              IN   DATE ,
    p_CREATED_BY                 IN   NUMBER,
    p_LAST_UPDATE_LOGIN          IN   NUMBER,
    p_SEEDED_FLAG                IN   VARCHAR2,
    -- X_RATE_ID			   OUT NOCOPY NUMBER,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    );

PROCEDURE Create_check_ratings(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit                     IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level           IN   NUMBER       := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    px_Check_Rating_ID		 IN OUT NOCOPY  NUMBER,
    P_CHK_RATING_Rec     	IN    CHK_RATING_Rec_Type  := G_MISS_CHK_RATING_Rec,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_check_ratings
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = CSC_CORE_UTILS_PVT.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL
--       p_identity_salesforce_id  IN   NUMBER     Optional  Default = NULL
--       P_CHK_RATING_Rec     IN CHK_RATING_Rec_Type  Required
--
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--
--   End of Comments
--
PROCEDURE Update_check_ratings(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2 := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit                     IN   VARCHAR2 := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level           IN   NUMBER   := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    p_CHECK_RATING_ID            IN   NUMBER,
    p_CHECK_ID                   IN   NUMBER,
    p_CHECK_RATING_GRADE         IN   VARCHAR2,
    p_RATING_COLOR_ID            IN   NUMBER DEFAULT NULL,
    p_RATING_CODE                IN   VARCHAR2,
    p_COLOR_CODE                 IN   VARCHAR2,
    p_RANGE_LOW_VALUE            IN   VARCHAR2,
    p_RANGE_HIGH_VALUE           IN   VARCHAR2,
    p_LAST_UPDATE_DATE           IN   DATE,
    p_LAST_UPDATED_BY            IN   NUMBER,
    p_CREATION_DATE              IN   DATE,
    p_CREATED_BY                 IN   NUMBER,
    p_LAST_UPDATE_LOGIN          IN   NUMBER,
    p_SEEDED_FLAG                IN   VARCHAR2 ,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    );

PROCEDURE Update_check_ratings(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit                     IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level           IN  NUMBER       := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    P_CHK_RATING_Rec    	   IN    CHK_RATING_Rec_Type  := G_MISS_CHK_RATING_Rec,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_check_ratings
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = CSC_CORE_UTILS_PVT.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL
--       p_identity_salesforce_id  IN   NUMBER     Optional  Default = NULL
--       P_CHK_RATING_Rec     IN CHK_RATING_Rec_Type  Required
--
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--
--   End of Comments
--
PROCEDURE Delete_check_ratings(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit                     IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level           IN   NUMBER       := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    P_CHECK_RATING_ID     IN NUMBER,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    );

-- Start of Comments
--
-- Item level validation procedures
--

PROCEDURE Validate_check_ratings(
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Validation_level           IN   NUMBER := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    P_Validation_mode            IN   VARCHAR2,
    p_CHK_RATING_REC   IN CHK_RATING_Rec_Type,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    );
End CSC_CHECK_RATINGS_PVT;

 

/
