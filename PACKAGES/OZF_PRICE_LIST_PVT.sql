--------------------------------------------------------
--  DDL for Package OZF_PRICE_LIST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_PRICE_LIST_PVT" AUTHID CURRENT_USER as
/* $Header: ozfvprls.pls 120.0 2005/06/01 03:37:34 appldev noship $ */

-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;
--   *******************************************************
--    Start of Comments
--   -------------------------------------------------------
--    Record name:OZF_PRICE_LIST_Rec_Type
--   -------------------------------------------------------
--   Parameters:
--    PRICE_LIST_ATTRIBUTE_ID
--    USER_STATUS_ID
--    STATUS_CODE
--    OWNER_ID
--    QP_LIST_HEADER_ID
--    OBJECT_VERSION_NUMBER
--    STATUS_DATE
--    WF_ITEM_KEY
--    CREATED_BY
--    CREATION_DATE
--    LAST_UPDATE_DATE
--    LAST_UPDATE_LOGIN
--    LAST_UPDATED_BY
--
--    Required:
--    Defaults:
--    Note: This is automatic generated record definition, it includes all columns
--          defined in the table, developer must manually add or delete some of the attributes.
--
--   End of Comments

TYPE OZF_PRICE_LIST_Rec_Type IS RECORD
(
       PRICE_LIST_ATTRIBUTE_ID         NUMBER ,
       USER_STATUS_ID                  NUMBER ,
       CUSTOM_SETUP_ID                 NUMBER ,
       STATUS_CODE                     VARCHAR2(30) ,
       OWNER_ID                        NUMBER ,
       QP_LIST_HEADER_ID               NUMBER ,
       OBJECT_VERSION_NUMBER           NUMBER ,
       STATUS_DATE                     DATE ,
       WF_ITEM_KEY                     VARCHAR2(100) ,
       CREATED_BY                      NUMBER ,
       CREATION_DATE                   DATE ,
       LAST_UPDATE_DATE                DATE ,
       LAST_UPDATE_LOGIN               NUMBER ,
       LAST_UPDATED_BY                 NUMBER
);

G_MISS_OZF_PRICE_LIST_REC          OZF_PRICE_LIST_Rec_Type;
TYPE  OZF_PRICE_LIST_Tbl_Type      IS TABLE OF OZF_PRICE_LIST_Rec_Type
                                    INDEX BY BINARY_INTEGER;
G_MISS_OZF_PRICE_LIST_TBL          OZF_PRICE_LIST_Tbl_Type;

TYPE OZF_PRICE_LIST_sort_rec_type IS RECORD
(
      -- Please define your own sort by record here.
      USER_STATUS_ID   NUMBER := NULL
);

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_price_list
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       P_OZF_PRICE_LIST_Rec     IN OZF_PRICE_LIST_Rec_Type  Required
--
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--
PROCEDURE Create_price_list(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    P_OZF_PRICE_LIST_Rec     IN      OZF_PRICE_LIST_Rec_Type  := G_MISS_OZF_PRICE_LIST_REC,
    X_PRICE_LIST_ATTRIBUTE_ID              OUT NOCOPY  NUMBER
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_price_list
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       P_OZF_PRICE_LIST_Rec     IN OZF_PRICE_LIST_Rec_Type  Required
--
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--
PROCEDURE Update_price_list(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,

    P_OZF_PRICE_LIST_Rec     IN    OZF_PRICE_LIST_Rec_Type,
    X_Object_Version_Number      OUT NOCOPY  NUMBER
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_price_list
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_PRICE_LIST_ATTRIBUTE_ID IN   NUMBER
--       p_object_version_number  IN   NUMBER     Optional  Default = NULL
--
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--
PROCEDURE Delete_price_list(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER  := FND_API.G_VALID_LEVEL_FULL  ,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    P_PRICE_LIST_ATTRIBUTE_ID  IN  NUMBER,
    P_Object_Version_Number      IN   NUMBER
    );

FUNCTION get_user_status_name(p_user_status_id IN NUMBER) return VARCHAR2;

End OZF_PRICE_LIST_PVT;

 

/
