--------------------------------------------------------
--  DDL for Package CSC_GROUP_CHECKS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSC_GROUP_CHECKS_PVT" AUTHID CURRENT_USER as
/* $Header: cscvpgcs.pls 120.1 2005/08/03 23:01:07 mmadhavi noship $ */
-- Start of Comments
-- Package name     : CSC_GROUP_CHECKS_PVT
-- Purpose          :
-- History          :
-- 27 Nov 02   jamose For Fnd_Api_G_Miss* and NOCOPY changes
-- NOTE             :
-- End of Comments

-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;
--   *******************************************************
--    Start of Comments
--   -------------------------------------------------------
--    Record name:GROUP_CHK_Rec_Type
--   -------------------------------------------------------
--   Parameters:
--    GROUP_ID
--    CHECK_ID
--    CHECK_SEQUENCE
--    END_DATE_ACTIVE
--    START_DATE_ACTIVE
--    CATEGORY_CODE
--    CATEGORY_SEQUENCE
--    THRESHOLD_FLAG
--    CRITICAL_FLAG
--    SEEDED_FLAG
--    CREATED_BY
--    CREATION_DATE
--    LAST_UPDATED_BY
--    LAST_UPDATE_DATE
--    LAST_UPDATE_LOGIN
--
--    Required:
--    Defaults:
--
--   End of Comments

TYPE GROUP_CHK_Rec_Type IS RECORD
(
       GROUP_ID                        NUMBER,
       CHECK_ID                        NUMBER,
       CHECK_SEQUENCE                  NUMBER,
       END_DATE_ACTIVE                 DATE ,
       START_DATE_ACTIVE               DATE ,
       CATEGORY_CODE                   VARCHAR2(30),
       CATEGORY_SEQUENCE               NUMBER ,
       THRESHOLD_FLAG                  VARCHAR2(3),
       CRITICAL_FLAG                   VARCHAR2(1), --mmadhavi added for JIT
       SEEDED_FLAG                     VARCHAR2(3),
       CREATED_BY                      NUMBER ,
       CREATION_DATE                   DATE,
       LAST_UPDATED_BY                 NUMBER,
       LAST_UPDATE_DATE                DATE,
       LAST_UPDATE_LOGIN               NUMBER
);

G_MISS_GROUP_CHK_REC          GROUP_CHK_Rec_Type;
TYPE  GROUP_CHK_Tbl_Type      IS TABLE OF GROUP_CHK_Rec_Type
                                    INDEX BY BINARY_INTEGER;
G_MISS_GROUP_CHK_TBL          GROUP_CHK_Tbl_Type;

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_group_checks
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = CSC_CORE_UTILS_PVT.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL
--       P_GROUP_CHK_Rec     IN GROUP_CHK_Rec_Type  Required
--
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--
--   End of Comments
--

PROCEDURE Create_group_checks(
    P_Api_Version_Number      IN   NUMBER,
    P_Init_Msg_List           IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit                  IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level        IN   NUMBER       := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    P_GROUP_ID                 IN     NUMBER ,
    P_CHECK_ID                 IN     NUMBER ,
    P_END_DATE_ACTIVE          IN     DATE ,
    P_START_DATE_ACTIVE        IN     DATE ,
    P_CATEGORY_CODE            IN     VARCHAR2 DEFAULT NULL,
    P_CATEGORY_SEQUENCE        IN     NUMBER DEFAULT NULL,
    P_THRESHOLD_FLAG           IN     VARCHAR2,
    P_CRITICAL_FLAG            IN     VARCHAR2, --mmadhavi added for JIT project
    P_SEEDED_FLAG              IN     VARCHAR2,
    P_CREATED_BY               IN     NUMBER,
    P_CREATION_DATE            IN     DATE,
    P_LAST_UPDATED_BY          IN     NUMBER,
    P_LAST_UPDATE_DATE         IN     DATE,
    P_LAST_UPDATE_LOGIN        IN     NUMBER,
    P_Check_Sequence	      IN  NUMBER ,
    X_Return_Status           OUT NOCOPY VARCHAR2,
    X_Msg_Count               OUT NOCOPY NUMBER,
    X_Msg_Data                OUT NOCOPY VARCHAR2
    );


PROCEDURE Create_group_checks(
    P_Api_Version_Number      IN   NUMBER,
    P_Init_Msg_List           IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit                  IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level        IN   NUMBER       := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    P_GROUP_CHK_Rec     	IN   GROUP_CHK_Rec_Type,
    -- X_Check_Sequence     OUT NOCOPY NUMBER,
    X_Return_Status           OUT NOCOPY VARCHAR2,
    X_Msg_Count               OUT NOCOPY NUMBER,
    X_Msg_Data                OUT NOCOPY VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_group_checks
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = CSC_CORE_UTILS_PVT.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL
--       p_identity_salesforce_id  IN   NUMBER     Optional  Default = NULL
--       P_GROUP_CHK_Rec     IN GROUP_CHK_Rec_Type  Required
--
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--
--   End of Comments
--
PROCEDURE Update_group_checks(
    P_Api_Version_Number      IN   NUMBER,
    P_Init_Msg_List           IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit                  IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level        IN   NUMBER       := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    P_GROUP_ID                 IN     NUMBER,
    P_CHECK_ID                 IN     NUMBER,
    P_CHECK_SEQUENCE           IN     NUMBER,
    P_END_DATE_ACTIVE          IN     DATE,
    P_START_DATE_ACTIVE        IN     DATE,
    P_CATEGORY_CODE            IN     VARCHAR2 DEFAULT NULL,
    P_CATEGORY_SEQUENCE        IN     NUMBER DEFAULT NULL,
    P_THRESHOLD_FLAG           IN     VARCHAR2,
    P_CRITICAL_FLAG            IN     VARCHAR2, --mmadhavi added for JIT project
    P_SEEDED_FLAG              IN     VARCHAR2 DEFAULT NULL,
    P_CREATED_BY               IN     NUMBER DEFAULT NULL,
    P_CREATION_DATE            IN     DATE DEFAULT NULL,
    P_LAST_UPDATED_BY          IN     NUMBER,
    P_LAST_UPDATE_DATE         IN     DATE,
    P_LAST_UPDATE_LOGIN        IN     NUMBER,
    X_Return_Status           OUT NOCOPY VARCHAR2,
    X_Msg_Count               OUT NOCOPY NUMBER,
    X_Msg_Data                OUT NOCOPY VARCHAR2
    );


PROCEDURE Update_group_checks(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit                     IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level           IN  NUMBER       := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    P_GROUP_CHK_Rec     IN    GROUP_CHK_Rec_Type,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_group_checks
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = CSC_CORE_UTILS_PVT.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL
--       P_GROUP_CHK_Rec     IN GROUP_CHK_Rec_Type  Required
--
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--
--   End of Comments
--
PROCEDURE Delete_group_checks(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit                     IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level           IN   NUMBER       := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    P_GROUP_ID     		   IN   NUMBER,
    P_CHECK_ID			   IN   NUMBER,
    P_CHECK_SEQUENCE			   IN   NUMBER,
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
-- End of Commens

PROCEDURE Validate_GROUP_ID (
    P_Api_Name		IN	VARCHAR2,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_GROUP_ID                IN   NUMBER,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    );

-- Start of Comments
--
-- Item level validation procedures
--
--
-- End of Comments

PROCEDURE Validate_CHECK_ID (
    P_Api_Name		IN	VARCHAR2,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_CHECK_ID                IN   NUMBER,
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

PROCEDURE Validate_CHECK_SEQUENCE (
    P_Api_Name		IN	VARCHAR2,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_CHECK_SEQUENCE                IN   NUMBER,
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

PROCEDURE Validate_CATEGORY_CODE (
    P_Api_Name		IN	VARCHAR2,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_CATEGORY_CODE                IN   VARCHAR2,
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

PROCEDURE Validate_CATEGORY_SEQUENCE (
    P_Api_Name		IN	VARCHAR2,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_CHECK_ID			IN	NUMBER,
    P_CATEGORY_SEQUENCE                IN   NUMBER,
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

PROCEDURE Validate_THRESHOLD_FLAG (
    P_Api_Name		IN	VARCHAR2,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_THRESHOLD_FLAG                IN   VARCHAR2,
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

PROCEDURE Validate_group_checks(
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Validation_level           IN   NUMBER := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    P_Validation_mode            IN   VARCHAR2,
    P_GROUP_CHK_Rec     IN    GROUP_CHK_Rec_Type,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    );
End CSC_GROUP_CHECKS_PVT;

 

/
