--------------------------------------------------------
--  DDL for Package OZF_PROCESS_SETUP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_PROCESS_SETUP_PVT" AUTHID CURRENT_USER as
/* $Header: ozfvpses.pls 120.2 2008/07/03 07:08:31 kdass noship $ */
-- Start of Comments
-- Package name     : ozf_process_setup_pvt
-- Purpose          :
-- History          : 09-OCT-2003  vansub   Created
-- NOTE             :
-- End of Comments

-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;
--   *******************************************************
--    Start of Comments
--   -------------------------------------------------------
--    Record name:process_setup_rec_type
--   -------------------------------------------------------
--   Parameters:
--   PROCESS_SETUP_ID         ,
--   SUPP_TRADE_PROFILE_ID    ,
--   OBJECT_VERSION_NUMBER    ,
--   LAST_UPDATE_DATE         ,
--   LAST_UPDATED_BY          ,
--   CREATION_DATE            ,
--   CREATED_BY               ,
--   LAST_UPDATE_LOGIN        ,
--   REQUEST_ID               ,
--   PROGRAM_APPLICATION_ID   ,
--   PROGRAM_UPDATE_DATE      ,
--   PROGRAM_ID               ,
--   CREATED_FROM             ,
--   PROCESS_CODE             ,
--   ENABLED_FLAG             ,
--   AUTOMATIC_FLAG              ,
--   ATTRIBUTE_CATEGORY       ,
--   ATTRIBUTE1               ,
--   ATTRIBUTE2               ,
--   ATTRIBUTE3               ,
--   ATTRIBUTE4               ,
--   ATTRIBUTE5               ,
--   ATTRIBUTE6               ,
--   ATTRIBUTE7               ,
--   ATTRIBUTE8               ,
--   ATTRIBUTE9               ,
--   ATTRIBUTE10              ,
--   ATTRIBUTE11              ,
--   ATTRIBUTE12              ,
--   ATTRIBUTE13              ,
--   ATTRIBUTE14              ,
--   ATTRIBUTE15              ,
--   ORG_ID                   ,
--     SECURITY_GROUP_ID       ,
--    Required:
--    Defaults:
--
--   End of Comments

TYPE process_setup_rec_type IS RECORD
(
   PROCESS_SETUP_ID     NUMBER,
   OBJECT_VERSION_NUMBER  NUMBER,
   LAST_UPDATE_DATE       DATE,
   LAST_UPDATED_BY        NUMBER,
   CREATION_DATE          DATE,
   CREATED_BY             NUMBER,
   LAST_UPDATE_LOGIN      NUMBER,
   REQUEST_ID             NUMBER,
   PROGRAM_APPLICATION_ID  NUMBER,
   PROGRAM_UPDATE_DATE     DATE  ,
   PROGRAM_ID	           NUMBER,
   CREATED_FROM           VARCHAR2(30),
   ORG_ID                 NUMBER,
   SUPP_TRADE_PROFILE_ID  NUMBER,
   PROCESS_CODE           VARCHAR2(60),
   ENABLED_FLAG           VARCHAR2(30),
   AUTOMATIC_FLAG         VARCHAR2(1),
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

g_miss_process_setup_rec          process_setup_rec_type;
TYPE  process_setup_tbl_type  IS TABLE OF process_setup_rec_type;
g_miss_process_setup_tbl      process_setup_tbl_type;

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  create_process_setup
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN  NUMBER     Required
--       p_init_msg_list           IN  VARCHAR2   Optional  Default=FND_API_G_FALSE
--       p_commit                  IN  VARCHAR2   Optional  Default=FND_API.G_FALSE
--       p_validation_level        IN  NUMBER     Optional  Default=FND_API.G_VALID_LEVEL_FULL
--       P_process_setup_tbl     IN process_setup_tbl_type  Required
--
--   OUT:
--       x_return_status           OUT NOCOPY VARCHAR2
--       x_msg_count               OUT NOCOPY NUMBER
--       x_msg_data                OUT NOCOPY VARCHAR2
--   Version : Current version 1.0
--
--   End of Comments
--
PROCEDURE create_process_setup(
p_api_version_number         IN   	 NUMBER,
p_init_msg_list              IN          VARCHAR2     := FND_API.G_FALSE,
P_Commit                     IN          VARCHAR2     := FND_API.G_FALSE,
p_validation_level           IN          NUMBER       := FND_API.G_VALID_LEVEL_FULL,
x_return_status              OUT NOCOPY  VARCHAR2,
x_msg_count                  OUT NOCOPY  NUMBER,
x_msg_data                   OUT NOCOPY  VARCHAR2,
p_process_setup_tbl        IN          process_setup_tbl_type ,
x_process_setup_id_tbl         OUT NOCOPY  JTF_NUMBER_TABLE);

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_process_setup
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN  NUMBER    Required
--       p_init_msg_list           IN  VARCHAR2  Optional  Default=FND_API_G_FALSE
--       p_commit                  IN  VARCHAR2  Optional  Default=FND_API.G_FALSE
--       p_validation_level        IN  NUMBER    Optional  Default=FND_API.G_VALID_LEVEL_FULL
--       p_process_setup_tbl     IN          process_setup_tbl_type  Required
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
PROCEDURE Update_process_setup(
    P_Api_Version_Number         IN  NUMBER,
    P_Init_Msg_List              IN  VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN  VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    p_process_setup_tbl        IN          process_setup_tbl_type  ,
    X_Object_Version_Number      OUT NOCOPY  JTF_NUMBER_TABLE);
--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  update_process_setup_tbl
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN  NUMBER    Required
--       p_init_msg_list           IN  VARCHAR2  Optional  Default=FND_API_G_FALSE
--       p_commit                  IN  VARCHAR2  Optional  Default=FND_API.G_FALSE
--       p_validation_level        IN  NUMBER    Optional  Default=FND_API.G_VALID_LEVEL_FULL
--       p_process_setup_tbl     IN          process_setup_tbl_type  ,  Required
--
--   OUT:
--       x_return_status           OUT NOCOPY VARCHAR2
--       x_msg_count               OUT NOCOPY NUMBER
--       x_msg_data                OUT NOCOPY VARCHAR2
--   Version : Current version 1.0
--
--   End of Comments
--
PROCEDURE update_process_setup_tbl(
    P_Api_Version_Number         IN  NUMBER,
    P_Init_Msg_List              IN  VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN  VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2,
    p_process_setup_tbl        IN  process_setup_tbl_type
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Check_uniq_process_setup
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_process_setup_tbl        IN          process_setup_tbl_type  ,   Required
--       p_validation_mode       IN  VARCHAR2 Optional  Default=JTF_PLSQL_API.g_create
--
--   OUT:
--       x_return_status         OUT NOCOPY VARCHAR2
--
--   Version : Current version 1.0
--   Description : Checks the uniqueness of the Reason Mapping for a Customer .
--
--   End of Comments
PROCEDURE Check_uniq_process_setup(
    p_process_setup_rec       IN  process_setup_rec_type  ,
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

PROCEDURE validate_process_setup_Rec(
    P_Api_Version_Number         IN	     NUMBER,
    P_Init_Msg_List              IN          VARCHAR2     := FND_API.G_FALSE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    p_process_setup_tbl        IN	     PROCESS_SETUP_TBL_TYPE
    );

***/
-- Start of Comments
--
--  validation procedures
--
-- p_validation_mode is a constant defined in OZF_UTILITY_PVT package
--                  For create: G_CREATE, for update: G_UPDATE
-- End of Comments

PROCEDURE Validate_process_setup(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    P_Validation_mode		 IN   VARCHAR2,
    p_process_setup_tbl        IN   process_setup_tbl_type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

End ozf_process_setup_pvt;



/
