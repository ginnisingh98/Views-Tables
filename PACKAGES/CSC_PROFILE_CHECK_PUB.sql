--------------------------------------------------------
--  DDL for Package CSC_PROFILE_CHECK_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSC_PROFILE_CHECK_PUB" AUTHID CURRENT_USER as
/* $Header: cscppcks.pls 115.13 2002/11/29 03:25:09 bhroy ship $ */
-- Start of Comments
-- Package name     : CSC_CHECK_PUB
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;
--   *******************************************************
--    Start of Comments
--   -------------------------------------------------------
--    Record name:CHECK_Rec_Type
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
--    Required:
--    Defaults:
--   End of Comments

TYPE CHECK_Rec_Type IS RECORD
(
       CHECK_ID                        NUMBER,
       CHECK_NAME                      VARCHAR2(240),
       CHECK_NAME_CODE                 VARCHAR2(240),
       DESCRIPTION                     VARCHAR2(720),
       START_DATE_ACTIVE               DATE,
       END_DATE_ACTIVE                 DATE,
       SEEDED_FLAG                     VARCHAR2(3),
       SELECT_TYPE                     VARCHAR2(3),
       SELECT_BLOCK_ID                 NUMBER,
       DATA_TYPE                       VARCHAR2(90),
       FORMAT_MASK                     VARCHAR2(90),
       THRESHOLD_GRADE                 VARCHAR2(9),
       THRESHOLD_RATING_CODE           VARCHAR2(90),
       CHECK_UPPER_LOWER_FLAG          VARCHAR2(3),
       THRESHOLD_COLOR_CODE            VARCHAR2(90),
       -- CATEGORY_CODE                   VARCHAR2(30) := FND_API.G_MISS_CHAR,
       CHECK_LEVEL                     VARCHAR2(20),
       CREATED_BY                      NUMBER,
       CREATION_DATE                   DATE,
       LAST_UPDATED_BY                 NUMBER,
       LAST_UPDATE_DATE                DATE,
       LAST_UPDATE_LOGIN               NUMBER,
       OBJECT_VERSION_NUMBER	       NUMBER,
       APPLICATION_ID                  NUMBER
);

G_MISS_CHK_REC          CHECK_Rec_Type;
TYPE  CHK_Tbl_Type      IS TABLE OF CHECK_Rec_Type
                                    INDEX BY BINARY_INTEGER;
G_MISS_CHK_TBL          CHK_Tbl_Type;

TYPE CHK_sort_rec_type IS RECORD
(
      -- Please define your own sort by record here.
      CHECK_NAME   NUMBER := NULL
);

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_check
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       P_CHECK_Rec     IN CHECK_Rec_Type  Required
--
--   OUT :
--       x_return_status           OUT NOCOPY  VARCHAR2
--       x_msg_count               OUT NOCOPY  NUMBER
--       x_msg_data                OUT NOCOPY  VARCHAR2
--   Version : Current version 1.0
--   End of Comments
--
PROCEDURE Create_Profile_Check(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
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
    X_OBJECT_VERSION_NUMBER      OUT NOCOPY  NUMBER,
    p_APPLICATION_ID             IN   NUMBER DEFAULT NULL,
    X_CHECK_ID     		   OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

--   *******************************************************
--    Overloaded procedure with record type
--   *******************************************************

PROCEDURE Create_Profile_Check(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    P_CHECK_Rec     IN    CHECK_Rec_Type DEFAULT NULL,
    X_CHECK_ID      OUT NOCOPY  NUMBER,
    X_OBJECT_VERSION_NUMBER OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_check
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       P_CHECK_Rec     IN CHECK_Rec_Type  Required
--
--   OUT :
--       x_return_status           OUT NOCOPY  VARCHAR2
--       x_msg_count               OUT NOCOPY  NUMBER
--       x_msg_data                OUT NOCOPY  VARCHAR2
--   Version : Current version 1.0
--
--   End of Comments
--
PROCEDURE Update_Profile_Check(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    p_CHECK_ID     		   IN   NUMBER DEFAULT NULL,
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
    -- p_CATEGORY_CODE              IN   VARCHAR2 := FND_API.G_MISS_CHAR,
    p_CREATED_BY                 IN   NUMBER DEFAULT NULL,
    p_CREATION_DATE              IN   DATE DEFAULT NULL,
    p_LAST_UPDATED_BY            IN   NUMBER DEFAULT NULL,
    p_LAST_UPDATE_DATE           IN   DATE DEFAULT NULL,
    p_LAST_UPDATE_LOGIN          IN   NUMBER DEFAULT NULL,
    px_OBJECT_VERSION_NUMBER     IN OUT NOCOPY  NUMBER ,
    p_APPLICATION_ID             IN   NUMBER DEFAULT NULL,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

--   *******************************************************
--    Overloaded procedure with record type
--   *******************************************************

PROCEDURE Update_Profile_Check(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    P_CHECK_Rec     IN    CHECK_Rec_Type,
    PX_OBJECT_VERSION_NUMBER IN OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_check
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       P_CHECK_Rec     IN CHECK_Rec_Type  Required
--
--   OUT :
--       x_return_status           OUT NOCOPY  VARCHAR2
--       x_msg_count               OUT NOCOPY  NUMBER
--       x_msg_data                OUT NOCOPY  VARCHAR2
--   Version : Current version 1.0
--
--   End of Comments
--
PROCEDURE Delete_Profile_check(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    p_Check_Id			   IN   NUMBER,
    p_Object_Version_number IN NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );


End CSC_PROFILE_CHECK_PUB;

 

/
