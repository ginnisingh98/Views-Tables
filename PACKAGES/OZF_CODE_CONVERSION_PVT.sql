--------------------------------------------------------
--  DDL for Package OZF_CODE_CONVERSION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_CODE_CONVERSION_PVT" AUTHID CURRENT_USER as
/* $Header: ozfvsccs.pls 120.2 2007/12/24 10:27:13 gdeepika ship $ */
-- Start of Comments
-- Package name     : ozf_code_conversion_pvt
-- Purpose          :
-- History          : 09-OCT-2003  vansub   Created
-- NOTE             :
-- End of Comments

-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;
--   *******************************************************
--    Start of Comments
--   -------------------------------------------------------
--    Record name:code_conversion_rec_type
--   -------------------------------------------------------
--   Parameters:
--   CODE_CONVERSION_ID     ,
--   OBJECT_VERSION_NUMBER  ,
--   LAST_UPDATE_DATE       ,
--   LAST_UPDATED_BY        ,
--   CREATION_DATE          ,
--   CREATED_BY             ,
--   LAST_UPDATE_LOGIN      ,
--   ORG_ID                 ,
--   PARTY_ID               ,
--   CUST_ACCOUNT_ID        ,
--   CODE_CONVERSION_TYPE   ,
--   VALUE_SET_ID	    ,
--   EXTERNAL_CODE          ,
--   INTERNAL_CODE          ,
--   DESCRIPTION            ,
--   START_DATE_ACTIVE      ,
--   END_DATE_ACTIVE        ,
--   ATTRIBUTE_CATEGORY     ,
--   ATTRIBUTE1             ,
--   ATTRIBUTE2             ,
--   ATTRIBUTE3             ,
--   ATTRIBUTE4             ,
--   ATTRIBUTE5             ,
--   ATTRIBUTE6             ,
--   ATTRIBUTE7             ,
--   ATTRIBUTE8             ,
--   ATTRIBUTE9             ,
--   ATTRIBUTE10            ,
--   ATTRIBUTE11            ,
--   ATTRIBUTE12            ,
--   ATTRIBUTE13            ,
--   ATTRIBUTE14            ,
--   ATTRIBUTE15            ,
--   SECURITY_GROUP_ID      ,

--    Required:
--    Defaults:
--
--   End of Comments

TYPE code_conversion_rec_type IS RECORD
(
   CODE_CONVERSION_ID     NUMBER,
   OBJECT_VERSION_NUMBER  NUMBER,
   LAST_UPDATE_DATE       DATE,
   LAST_UPDATED_BY        NUMBER,
   CREATION_DATE          DATE,
   CREATED_BY             NUMBER,
   LAST_UPDATE_LOGIN      NUMBER,
   ORG_ID                 NUMBER,
   PARTY_ID               NUMBER,
   CUST_ACCOUNT_ID        NUMBER,
   CODE_CONVERSION_TYPE   VARCHAR2(30),
   EXTERNAL_CODE          VARCHAR2(240),
   INTERNAL_CODE          VARCHAR2(240),
   DESCRIPTION            VARCHAR2(240),
   START_DATE_ACTIVE      DATE,
   END_DATE_ACTIVE        DATE,
   ATTRIBUTE_CATEGORY     VARCHAR2(30),
   ATTRIBUTE1             VARCHAR2(150),
   ATTRIBUTE2             VARCHAR2(150),
   ATTRIBUTE3             VARCHAR2(150),
   ATTRIBUTE4             VARCHAR2(150),
   ATTRIBUTE5             VARCHAR2(150),
   ATTRIBUTE6             VARCHAR2(150),
   ATTRIBUTE7             VARCHAR2(150),
   ATTRIBUTE8             VARCHAR2(150),
   ATTRIBUTE9             VARCHAR2(150),
   ATTRIBUTE10            VARCHAR2(150),
   ATTRIBUTE11            VARCHAR2(150),
   ATTRIBUTE12            VARCHAR2(150),
   ATTRIBUTE13            VARCHAR2(150),
   ATTRIBUTE14            VARCHAR2(150),
   ATTRIBUTE15            VARCHAR2(150),
   SECURITY_GROUP_ID      NUMBER

);

g_miss_code_conversion_rec          code_conversion_rec_type;
TYPE  code_conversion_tbl_type  IS TABLE OF code_conversion_rec_type;
g_miss_code_conversion_tbl      code_conversion_tbl_type;

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  create_code_conversion
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN  NUMBER     Required
--       p_init_msg_list           IN  VARCHAR2   Optional  Default=FND_API_G_FALSE
--       p_commit                  IN  VARCHAR2   Optional  Default=FND_API.G_FALSE
--       p_validation_level        IN  NUMBER     Optional  Default=FND_API.G_VALID_LEVEL_FULL
--       P_code_conversion_tbl     IN code_conversion_tbl_type  Required
--
--   OUT:
--       x_return_status           OUT NOCOPY VARCHAR2
--       x_msg_count               OUT NOCOPY NUMBER
--       x_msg_data                OUT NOCOPY VARCHAR2
--   Version : Current version 1.0
--
--   End of Comments
--
PROCEDURE create_code_conversion(
p_api_version_number         IN   	 NUMBER,
p_init_msg_list              IN          VARCHAR2     := FND_API.G_FALSE,
P_Commit                     IN          VARCHAR2     := FND_API.G_FALSE,
p_validation_level           IN          NUMBER       := FND_API.G_VALID_LEVEL_FULL,
x_return_status              OUT NOCOPY  VARCHAR2,
x_msg_count                  OUT NOCOPY  NUMBER,
x_msg_data                   OUT NOCOPY  VARCHAR2,
p_code_conversion_tbl        IN          code_conversion_tbl_type ,
x_code_conversion_id_tbl         OUT NOCOPY  JTF_NUMBER_TABLE);

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_code_conversion
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN  NUMBER    Required
--       p_init_msg_list           IN  VARCHAR2  Optional  Default=FND_API_G_FALSE
--       p_commit                  IN  VARCHAR2  Optional  Default=FND_API.G_FALSE
--       p_validation_level        IN  NUMBER    Optional  Default=FND_API.G_VALID_LEVEL_FULL
--       p_code_conversion_tbl     IN          code_conversion_tbl_type  Required
--
--   OUT:
--       x_return_status           OUT NOCOPY VARCHAR2
--       x_msg_count               OUT NOCOPY NUMBER
--       x_msg_data                OUT NOCOPY VARCHAR2
--       x_object_version_number   OUT NOCOPY NUMBER
--   Version : Current version 1.0
--
--   End of Comments
--
PROCEDURE Update_code_conversion(
    P_Api_Version_Number         IN  NUMBER,
    P_Init_Msg_List              IN  VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN  VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    p_code_conversion_tbl        IN          code_conversion_tbl_type  ,
    X_Object_Version_Number      OUT NOCOPY  JTF_NUMBER_TABLE);
--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  update_code_conversion_tbl
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN  NUMBER    Required
--       p_init_msg_list           IN  VARCHAR2  Optional  Default=FND_API_G_FALSE
--       p_commit                  IN  VARCHAR2  Optional  Default=FND_API.G_FALSE
--       p_validation_level        IN  NUMBER    Optional  Default=FND_API.G_VALID_LEVEL_FULL
--       p_code_conversion_tbl     IN          code_conversion_tbl_type  ,  Required
--
--   OUT:
--       x_return_status           OUT NOCOPY VARCHAR2
--       x_msg_count               OUT NOCOPY NUMBER
--       x_msg_data                OUT NOCOPY VARCHAR2
--   Version : Current version 1.0
--
--   End of Comments
--
PROCEDURE update_code_conversion_tbl(
    P_Api_Version_Number         IN  NUMBER,
    P_Init_Msg_List              IN  VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN  VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2,
    p_code_conversion_tbl        IN  code_conversion_tbl_type
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_code_conversion
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number    IN  NUMBER   Required
--       p_init_msg_list         IN  VARCHAR2 Optional  Default=FND_API_G_FALSE
--       p_commit                IN  VARCHAR2 Optional  Default=FND_API.G_FALSE
--       p_validation_level      IN  NUMBER   Optional  Default=FND_API.G_VALID_LEVEL_FULL
--       p_code_conversion_id    IN  NUMBER
--       p_object_version_number IN  NUMBER   Optional  Default=NULL
--       p_external_code         IN  NUMBER   Optional  Default=NULL
--
--   OUT:
--       x_return_status         OUT NOCOPY VARCHAR2
--       x_msg_count             OUT NOCOPY NUMBER
--       x_msg_data              OUT NOCOPY VARCHAR2
--   Version : Current version 1.0
--
--   End of Comments
--
PROCEDURE Delete_code_conversion(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2   := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2   := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    X_Return_Status              OUT  NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY  NUMBER,
    X_Msg_Data                   OUT  NOCOPY  VARCHAR2,
    P_code_conversion_id         IN   NUMBER,
    P_Object_Version_Number      IN   NUMBER,
    p_external_code		 IN   VARCHAR2,
    p_code_conversion_type	 IN   VARCHAR2

    );



PROCEDURE delete_code_conversion_tbl(
    P_Api_Version_Number         IN  NUMBER,
    P_Init_Msg_List              IN  VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN  VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2,
    P_code_conversion_Tbl        IN  code_conversion_Tbl_Type
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Check_uniq_code_conversion
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_code_conversion_tbl        IN          code_conversion_tbl_type  ,   Required
--       p_validation_mode       IN  VARCHAR2 Optional  Default=JTF_PLSQL_API.g_create
--
--   OUT:
--       x_return_status         OUT NOCOPY VARCHAR2
--
--   Version : Current version 1.0
--   Description : Checks the uniqueness of the Reason Mapping for a Customer .
--
--   End of Comments
PROCEDURE Check_uniq_code_conversion(
    p_code_conversion_rec       IN  code_conversion_rec_type  ,
    p_validation_mode		IN  VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status		OUT NOCOPY   VARCHAR2
);

/***
-- Start of Comments
--
-- Record level validation procedures
--
-- p_validation_mode is a constant defined in OZF_UTILITY_PVT package
--                  For create: G_CREATE, for update: G_UPDATE
-- End of Comments

PROCEDURE validate_code_conversion_Rec(
    P_Api_Version_Number         IN	     NUMBER,
    P_Init_Msg_List              IN          VARCHAR2     := FND_API.G_FALSE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    p_code_conversion_tbl        IN	     CODE_CONVERSION_TBL_TYPE
    );

***/
-- Start of Comments
--
--  validation procedures
--
-- p_validation_mode is a constant defined in OZF_UTILITY_PVT package
--                  For create: G_CREATE, for update: G_UPDATE
-- End of Comments

PROCEDURE Validate_code_conversion(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    P_Validation_mode		 IN   VARCHAR2,
    p_code_conversion_tbl        IN   code_conversion_tbl_type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );
-- Start of Comments
--
--  get_claim_reason
--       Translate the external code to the internal code.
--
-- End of Comments
PROCEDURE convert_code(
    p_cust_account_id		IN NUMBER,
    p_party_id			IN NUMBER,
    p_code_conversion_type      IN VARCHAR2,
    p_external_code		IN VARCHAR2,
    x_internal_code		OUT NOCOPY VARCHAR2,
    X_Return_Status             OUT NOCOPY  VARCHAR2,
    X_Msg_Count                 OUT NOCOPY  NUMBER,
    X_Msg_Data                  OUT NOCOPY  VARCHAR2
   );

--   *******************************************************
--    Start of Comments
--   -------------------------------------------------------
--    Record name:supp_code_conversion_rec_type
--   -------------------------------------------------------
--   Parameters:
--	CODE_CONVERSION_ID             ,
--	OBJECT_VERSION_NUMBER          ,
--	LAST_UPDATE_DATE               ,
--	LAST_UPDATED_BY                ,
--	LAST_UPDATE_BY                 ,
--	CREATION_DATE                  ,
--	CREATED_BY                     ,
--	LAST_UPDATE_LOGIN              ,
--	SUPP_TRADE_PROFILE_ID          ,
--	ORG_ID                         ,
--	CODE_CONVERSION_TYPE           ,
--	EXTERNAL_CODE                  ,
--	INTERNAL_CODE                  ,
--	DESCRIPTION                    ,
--	START_DATE_ACTIVE              ,
--	END_DATE_ACTIVE                ,
--	ATTRIBUTE_CATEGORY             ,
--	ATTRIBUTE1                     ,
--	ATTRIBUTE2                     ,
--	ATTRIBUTE3                     ,
--	ATTRIBUTE4                     ,
--	ATTRIBUTE5                     ,
--	ATTRIBUTE6                     ,
--	ATTRIBUTE7                     ,
--	ATTRIBUTE8                     ,
--	ATTRIBUTE9                     ,
--	ATTRIBUTE10                    ,
--	ATTRIBUTE11                    ,
--	ATTRIBUTE12                    ,
--	ATTRIBUTE13                    ,
--	ATTRIBUTE14                    ,
--	ATTRIBUTE15                    ,
--	SECURITY_GROUP_ID              ,
--    Required:
--    Defaults:
--
--   End of Comments

TYPE supp_code_conversion_rec_type IS RECORD
(
   CODE_CONVERSION_ID     NUMBER,
   OBJECT_VERSION_NUMBER  NUMBER,
   LAST_UPDATE_DATE       DATE,
   LAST_UPDATED_BY        NUMBER,
   CREATION_DATE          DATE,
   CREATED_BY             NUMBER,
   LAST_UPDATE_LOGIN      NUMBER,
   ORG_ID                 NUMBER,
   SUPP_TRADE_PROFILE_ID  NUMBER,
   CODE_CONVERSION_TYPE   VARCHAR2(30),
   EXTERNAL_CODE          VARCHAR2(240),
   INTERNAL_CODE          VARCHAR2(240),
   DESCRIPTION            VARCHAR2(240),
   START_DATE_ACTIVE      DATE,
   END_DATE_ACTIVE        DATE,
   ATTRIBUTE_CATEGORY     VARCHAR2(30),
   ATTRIBUTE1             VARCHAR2(150),
   ATTRIBUTE2             VARCHAR2(150),
   ATTRIBUTE3             VARCHAR2(150),
   ATTRIBUTE4             VARCHAR2(150),
   ATTRIBUTE5             VARCHAR2(150),
   ATTRIBUTE6             VARCHAR2(150),
   ATTRIBUTE7             VARCHAR2(150),
   ATTRIBUTE8             VARCHAR2(150),
   ATTRIBUTE9             VARCHAR2(150),
   ATTRIBUTE10            VARCHAR2(150),
   ATTRIBUTE11            VARCHAR2(150),
   ATTRIBUTE12            VARCHAR2(150),
   ATTRIBUTE13            VARCHAR2(150),
   ATTRIBUTE14            VARCHAR2(150),
   ATTRIBUTE15            VARCHAR2(150),
   SECURITY_GROUP_ID      NUMBER

);

g_miss_supp_code_conv_rec          supp_code_conversion_rec_type;
TYPE  supp_code_conversion_tbl_type  IS TABLE OF supp_code_conversion_rec_type;
g_miss_supp_code_conv_tbl      supp_code_conversion_tbl_type;

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  create_supp_code_conversion
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN  NUMBER     Required
--       p_init_msg_list           IN  VARCHAR2   Optional  Default=FND_API_G_FALSE
--       p_commit                  IN  VARCHAR2   Optional  Default=FND_API.G_FALSE
--       p_validation_level        IN  NUMBER     Optional  Default=FND_API.G_VALID_LEVEL_FULL
--       P_supp_code_conversion_tbl     IN supp_code_conversion_tbl_type  Required
--
--   OUT:
--       x_return_status           OUT NOCOPY VARCHAR2
--       x_msg_count               OUT NOCOPY NUMBER
--       x_msg_data                OUT NOCOPY VARCHAR2
--   Version : Current version 1.0
--
--   End of Comments
--
PROCEDURE create_supp_code_conversion(
p_api_version_number         IN   	 NUMBER,
p_init_msg_list              IN          VARCHAR2     := FND_API.G_FALSE,
P_Commit                     IN          VARCHAR2     := FND_API.G_FALSE,
p_validation_level           IN          NUMBER       := FND_API.G_VALID_LEVEL_FULL,
x_return_status              OUT NOCOPY  VARCHAR2,
x_msg_count                  OUT NOCOPY  NUMBER,
x_msg_data                   OUT NOCOPY  VARCHAR2,
p_supp_code_conversion_tbl        IN          supp_code_conversion_tbl_type ,
x_supp_code_conversion_id_tbl         OUT NOCOPY  JTF_NUMBER_TABLE);

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_supp_code_conversion
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN  NUMBER    Required
--       p_init_msg_list           IN  VARCHAR2  Optional  Default=FND_API_G_FALSE
--       p_commit                  IN  VARCHAR2  Optional  Default=FND_API.G_FALSE
--       p_validation_level        IN  NUMBER    Optional  Default=FND_API.G_VALID_LEVEL_FULL
--       p_supp_code_conversion_tbl     IN          supp_code_conversion_tbl_type  Required
--
--   OUT:
--       x_return_status           OUT NOCOPY VARCHAR2
--       x_msg_count               OUT NOCOPY NUMBER
--       x_msg_data                OUT NOCOPY VARCHAR2
--       x_object_version_number   OUT NOCOPY NUMBER
--   Version : Current version 1.0
--
--   End of Comments
--
PROCEDURE Update_supp_code_conversion(
    P_Api_Version_Number         IN  NUMBER,
    P_Init_Msg_List              IN  VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN  VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    p_supp_code_conversion_tbl        IN          supp_code_conversion_tbl_type  ,
    X_Object_Version_Number      OUT NOCOPY  JTF_NUMBER_TABLE);
--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  update_supp_code_conversion_tbl
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN  NUMBER    Required
--       p_init_msg_list           IN  VARCHAR2  Optional  Default=FND_API_G_FALSE
--       p_commit                  IN  VARCHAR2  Optional  Default=FND_API.G_FALSE
--       p_validation_level        IN  NUMBER    Optional  Default=FND_API.G_VALID_LEVEL_FULL
--       p_supp_code_conversion_tbl     IN          supp_code_conversion_tbl_type  ,  Required
--
--   OUT:
--       x_return_status           OUT NOCOPY VARCHAR2
--       x_msg_count               OUT NOCOPY NUMBER
--       x_msg_data                OUT NOCOPY VARCHAR2
--   Version : Current version 1.0
--
--   End of Comments
--
PROCEDURE update_supp_code_conv_tbl(
    P_Api_Version_Number         IN  NUMBER,
    P_Init_Msg_List              IN  VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN  VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2,
    p_supp_code_conversion_tbl        IN  supp_code_conversion_tbl_type
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_supp_code_conversion
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number    IN  NUMBER   Required
--       p_init_msg_list         IN  VARCHAR2 Optional  Default=FND_API_G_FALSE
--       p_commit                IN  VARCHAR2 Optional  Default=FND_API.G_FALSE
--       p_validation_level      IN  NUMBER   Optional  Default=FND_API.G_VALID_LEVEL_FULL
--       p_code_conversion_id    IN  NUMBER
--       p_object_version_number IN  NUMBER   Optional  Default=NULL
--       p_external_code         IN  NUMBER   Optional  Default=NULL
--
--   OUT:
--       x_return_status         OUT NOCOPY VARCHAR2
--       x_msg_count             OUT NOCOPY NUMBER
--       x_msg_data              OUT NOCOPY VARCHAR2
--   Version : Current version 1.0
--
--   End of Comments
--
PROCEDURE Delete_supp_code_conversion(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2   := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2   := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    X_Return_Status              OUT  NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY  NUMBER,
    X_Msg_Data                   OUT  NOCOPY  VARCHAR2,
    P_code_conversion_id         IN   NUMBER,
    P_Object_Version_Number      IN   NUMBER
    );



PROCEDURE delete_supp_code_conv_tbl(
    P_Api_Version_Number         IN  NUMBER,
    P_Init_Msg_List              IN  VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN  VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2,
    P_supp_code_conversion_Tbl        IN  supp_code_conversion_Tbl_Type
    );


End ozf_code_conversion_pvt;



/
