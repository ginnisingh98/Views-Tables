--------------------------------------------------------
--  DDL for Package CSC_PROFILE_CHECK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSC_PROFILE_CHECK_PVT" AUTHID CURRENT_USER as
/* $Header: cscvpcks.pls 115.11 2002/12/03 17:52:08 jamose ship $ */
-- Start of Comments
-- Package name     : CSC_CHECK_PVT
-- Purpose          :
-- History          :25 Nov 02, JAmose For FND_API_G_MISS* changes
--                   for Performance
-- NOTE             :
-- End of Comments

-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;
--   *******************************************************
--    Start of Comments
--   -------------------------------------------------------
--    Record name:Check_Rec_Type
--   -------------------------------------------------------
--   Parameters:
--    CHECK_ID
--    CHECK_NAME
--    CHECK_NAME_CODE
--    DESCRIPTION
--    START_DATE_ACTIVE
--    END_DATE_ACTIVE
--    SEEDED_FLAG
--    SELECT_TYPE
--    SELECT_BLOCK_ID
--    DATA_TYPE
--    FORMAT_MASK
--    THRESHOLD_GRADE
--    THRESHOLD_RATING_CODE
--    CHECK_UPPER_LOWER_FLAG
--    THRESHOLD_COLOR_CODE
--    CHECK_LEVEL
--    CATEGORY_CODE
--    CREATED_BY
--    CREATION_DATE
--    LAST_UPDATED_BY
--    LAST_UPDATE_DATE
--    LAST_UPDATE_LOGIN
--    APPLICATION_ID
--
--   End of Comments

TYPE Check_Rec_Type IS RECORD
(
       CHECK_ID                        NUMBER,
       CHECK_NAME                      VARCHAR2(240),
       CHECK_NAME_CODE                 VARCHAR2(240),
       DESCRIPTION                     VARCHAR2(720),
       START_DATE_ACTIVE               DATE ,
       END_DATE_ACTIVE                 DATE ,
       SEEDED_FLAG                     VARCHAR2(3),
       SELECT_TYPE                     VARCHAR2(3),
       SELECT_BLOCK_ID                 NUMBER,
       DATA_TYPE                       VARCHAR2(90),
       FORMAT_MASK                     VARCHAR2(90),
       THRESHOLD_GRADE                 VARCHAR2(9),
       THRESHOLD_RATING_CODE           VARCHAR2(90),
       CHECK_UPPER_LOWER_FLAG          VARCHAR2(3),
       THRESHOLD_COLOR_CODE            VARCHAR2(90),
       CHECK_LEVEL                     VARCHAR2(20),
       -- CATEGORY_CODE                VARCHAR2(30),
       CREATED_BY                      NUMBER,
       CREATION_DATE                   DATE,
       LAST_UPDATED_BY                 NUMBER,
       LAST_UPDATE_DATE                DATE ,
       LAST_UPDATE_LOGIN               NUMBER,
       OBJECT_VERSION_NUMBER           NUMBER,
       APPLICATION_ID                  NUMBER
);

G_MISS_Check_REC          Check_Rec_Type;
TYPE  Check_Tbl_Type      IS TABLE OF Check_Rec_Type
                                    INDEX BY BINARY_INTEGER;
G_MISS_Check_TBL          Check_Tbl_Type;


--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_Profile_check
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = CSC_CORE_UTILS_PVT.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL
--       P_Check_Rec     	     IN Check_Rec_Type  Required
--
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--
--   End of Comments
--

PROCEDURE Create_Profile_Check(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2 := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit                     IN   VARCHAR2 := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level           IN   NUMBER   := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    p_CHECK_NAME                 IN   VARCHAR2 DEFAULT NULL,
    p_CHECK_NAME_CODE            IN   VARCHAR2 DEFAULT NULL,
    p_DESCRIPTION                IN   VARCHAR2 DEFAULT NULL,
    p_START_DATE_ACTIVE          IN   DATE DEFAULT NULL,
    p_END_DATE_ACTIVE            IN   DATE DEFAULT NULL,
    p_SEEDED_FLAG                IN   VARCHAR2 DEFAULT NULL,
    p_SELECT_TYPE                IN   VARCHAR2 DEFAULT NULL,
    p_SELECT_BLOCK_ID            IN   NUMBER DEFAULT NULL,
    p_DATA_TYPE                  IN   VARCHAR2 DEFAULT NULL,
    p_FORMAT_MASK                IN   VARCHAR2 DEFAULT NULL,
    p_THRESHOLD_GRADE            IN   VARCHAR2 DEFAULT NULL,
    p_THRESHOLD_RATING_CODE      IN   VARCHAR2 DEFAULT NULL,
    p_CHECK_UPPER_LOWER_FLAG     IN   VARCHAR2 DEFAULT NULL,
    p_THRESHOLD_COLOR_CODE       IN   VARCHAR2 DEFAULT NULL,
    p_CHECK_LEVEL                IN   VARCHAR2 DEFAULT NULL,
    --p_CATEGORY_CODE            IN   VARCHAR2 DEFAULT NULL,
    p_CREATED_BY                 IN   NUMBER DEFAULT NULL,
    p_CREATION_DATE              IN   DATE DEFAULT NULL,
    p_LAST_UPDATED_BY            IN   NUMBER DEFAULT NULL,
    p_LAST_UPDATE_DATE           IN   DATE DEFAULT NULL,
    p_LAST_UPDATE_LOGIN          IN   NUMBER DEFAULT NULL,
    X_CHECK_ID     		     OUT  NOCOPY NUMBER,
    X_Object_Version_Number  OUT NOCOPY NUMBER,
    p_APPLICATION_ID             IN   NUMBER  DEFAULT NULL,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    );


--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_Profile_check
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = CSC_CORE_UTILS_PVT.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL
--       P_Check_Rec     	     IN Check_Rec_Type  Required
--
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--
--   End of Comments
--


PROCEDURE Create_Profile_Check(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit                     IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level           IN   NUMBER       := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    P_Check_Rec     		         IN   Check_Rec_Type  := G_MISS_CHECK_REC,
    X_CHECK_ID     		         OUT NOCOPY NUMBER,
    X_Object_Version_Number      OUT NOCOPY NUMBER,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    );

PROCEDURE Update_Profile_Check(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit                     IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level           IN   NUMBER       := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    p_CHECK_ID     		 IN   NUMBER  DEFAULT NULL,
    p_CHECK_NAME                 IN   VARCHAR2 DEFAULT NULL,
    p_CHECK_NAME_CODE            IN   VARCHAR2 DEFAULT NULL,
    p_DESCRIPTION                IN   VARCHAR2 DEFAULT NULL,
    p_START_DATE_ACTIVE          IN   DATE DEFAULT NULL,
    p_END_DATE_ACTIVE            IN   DATE DEFAULT NULL,
    p_SEEDED_FLAG                IN   VARCHAR2 DEFAULT NULL,
    p_SELECT_TYPE                IN   VARCHAR2 DEFAULT NULL,
    p_SELECT_BLOCK_ID            IN   NUMBER DEFAULT NULL,
    p_DATA_TYPE                  IN   VARCHAR2 DEFAULT NULL,
    p_FORMAT_MASK                IN   VARCHAR2 DEFAULT NULL,
    p_THRESHOLD_GRADE            IN   VARCHAR2 DEFAULT NULL,
    p_THRESHOLD_RATING_CODE      IN   VARCHAR2 DEFAULT NULL,
    p_CHECK_UPPER_LOWER_FLAG     IN   VARCHAR2 DEFAULT NULL,
    p_THRESHOLD_COLOR_CODE       IN   VARCHAR2 DEFAULT NULL,
    p_CHECK_LEVEL                IN   VARCHAR2 DEFAULT NULL,
    p_CREATED_BY                 IN   NUMBER DEFAULT NULL,
    p_CREATION_DATE              IN   DATE DEFAULT NULL,
    p_LAST_UPDATED_BY            IN   NUMBER DEFAULT NULL,
    p_LAST_UPDATE_DATE           IN   DATE DEFAULT NULL,
    p_LAST_UPDATE_LOGIN          IN   NUMBER DEFAULT NULL,
    px_OBJECT_VERSION_NUMBER     IN OUT NOCOPY   NUMBER,
    p_APPLICATION_ID             IN NUMBER DEFAULT NULL,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    ) ;



--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_check
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = CSC_CORE_UTILS_PVT.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL
--       P_Check_Rec     	     IN   Check_Rec_Type  Required
--
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--
--   End of Comments
--
PROCEDURE Update_Profile_check(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit                     IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level           IN   NUMBER       := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    P_Check_Rec     		   IN   Check_Rec_Type,
    PX_OBJECT_VERSION_NUMBER     IN OUT NOCOPY NUMBER,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    );

PROCEDURE Delete_profile_check(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    p_Check_Id			            IN   NUMBER,
    p_OBJECT_VERSION_NUMBER      IN   NUMBER,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    );

PROCEDURE Validate_Check(
    p_init_msg_list	IN    VARCHAR2	:=	CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level 	IN 	NUMBER := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    p_Validation_mode 	IN 	VARCHAR2,
    p_check_rec 	      IN 	Check_Rec_Type,
    X_Return_Status	OUT NOCOPY	VARCHAR2,
    X_MSg_count	   OUT	NOCOPY NUMBER,
    X_Msg_Data  	OUT NOCOPY	VARCHAR2
    );

PROCEDURE Validate_check_level
( p_api_name         IN  VARCHAR2,
  p_parameter_name   IN  VARCHAR2,
  p_check_level      IN  VARCHAR2,
  x_return_status    OUT NOCOPY VARCHAR2
);



End CSC_PROFILE_CHECK_PVT;

 

/
