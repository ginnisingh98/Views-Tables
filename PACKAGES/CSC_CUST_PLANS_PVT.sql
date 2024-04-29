--------------------------------------------------------
--  DDL for Package CSC_CUST_PLANS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSC_CUST_PLANS_PVT" AUTHID CURRENT_USER as
/* $Header: cscvctps.pls 115.14 2002/12/04 16:08:29 bhroy ship $ */
-- Start of Comments
-- Package name     : CSC_CUST_PLANS_PVT
-- Purpose          : Private package to perform inserts, updates and deletes operations
--                    on CSC_CUST_PLANS table. It contains procedure to perform item
--                    level validations if the validation level is set to 100 (FULL).
-- History          :
-- MM-DD-YYYY    NAME          MODIFICATIONS
-- 10-28-1999    dejoseph      Created.
-- 12-08-1999    dejoseph      'Arcs'ed in for first code freeze.
-- 12-21-1999    dejoseph      'Arcs'ed in for second code freeze.
-- 01-03-2000    dejoseph      'Arcs'ed in for third code freeze. (10-JAN-2000)
-- 01-31-2000    dejoseph      'Arcs'ed in for fourth code freeze. (07-FEB-2000)
-- 02-13-2000    dejoseph      'Arcs'ed on for fifth code freeze. (21-FEB-2000)
-- 02-28-2000    dejoseph      'Arcs'ed on for sixth code freeze. (06-MAR-2000)
-- 04-10-2000    dejoseph      Removed org_id validations and all reference to org_id in lieu
--                             of TCA's decision to drop column ORG_ID from
--                             hz_cust_accounts table. Also removed reference to cust_account_org.
-- 26-11-2002	bhroy		G_MISS_XXX defaults of API parameters removed, added WHENEVER OSERROR EXIT FAILURE ROLLBACK

-- NOTE             :
-- End of Comments

-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;

-- Id of record inserted into CSC_CUST_PLANS_AUDIT when-ever and insert, update or
-- a delete is performed on the CSC_CUST_PLANS table.
--				NOCOPY changes made for OUT NOCOPY parameters
G_PLAN_AUDIT_ID          NUMBER := FND_API.G_MISS_NUM;

TYPE CSC_CUST_PLANS_Rec_Type IS RECORD
(
       CUST_PLAN_ID                    NUMBER ,
       PLAN_ID                         NUMBER,
       PARTY_ID                        NUMBER,
       CUST_ACCOUNT_ID                 NUMBER,
       -- CUST_ACCOUNT_ORG                NUMBER        := FND_API.G_MISS_NUM,,
       START_DATE_ACTIVE               DATE ,
       END_DATE_ACTIVE                 DATE,
       MANUAL_FLAG                     VARCHAR2(3),
       PLAN_STATUS_CODE                VARCHAR2(30),
       REQUEST_ID                      NUMBER ,
       PROGRAM_APPLICATION_ID          NUMBER ,
       PROGRAM_ID                      NUMBER ,
       PROGRAM_UPDATE_DATE             DATE   ,
       CREATION_DATE                   DATE   ,
       LAST_UPDATE_DATE                DATE  ,
       CREATED_BY                      NUMBER ,
       LAST_UPDATED_BY                 NUMBER  ,
       LAST_UPDATE_LOGIN               NUMBER ,
       ATTRIBUTE1                      VARCHAR2(450) ,
       ATTRIBUTE2                      VARCHAR2(450),
       ATTRIBUTE3                      VARCHAR2(450) ,
       ATTRIBUTE4                      VARCHAR2(450),
       ATTRIBUTE5                      VARCHAR2(450) ,
       ATTRIBUTE6                      VARCHAR2(450),
       ATTRIBUTE7                      VARCHAR2(450) ,
       ATTRIBUTE8                      VARCHAR2(450),
       ATTRIBUTE9                      VARCHAR2(450) ,
       ATTRIBUTE10                     VARCHAR2(450),
       ATTRIBUTE11                     VARCHAR2(450) ,
       ATTRIBUTE12                     VARCHAR2(450),
       ATTRIBUTE13                     VARCHAR2(450) ,
       ATTRIBUTE14                     VARCHAR2(450),
       ATTRIBUTE15                     VARCHAR2(450) ,
       ATTRIBUTE_CATEGORY              VARCHAR2(90) ,
       OBJECT_VERSION_NUMBER           NUMBER       );

G_MISS_CSC_CUST_PLANS_REC          CSC_CUST_PLANS_Rec_Type;

TYPE  CSC_CUST_PLANS_Tbl_Type      IS TABLE OF CSC_CUST_PLANS_Rec_Type
                                   INDEX BY BINARY_INTEGER;
G_MISS_CSC_CUST_PLANS_TBL          CSC_CUST_PLANS_Tbl_Type;

TYPE CSC_PARTY_ID_REC_TYPE IS RECORD (
       PARTY_ID                        NUMBER        := NULL,
       CUST_ACCOUNT_ID                 NUMBER        := NULL,
       -- CUST_ACCOUNT_ORG                NUMBER        := NULL,
	  OBJECT_VERSION_NUMBER           NUMBER        := NULL);

TYPE CSC_PARTY_ID_TBL_TYPE         IS TABLE OF CSC_PARTY_ID_REC_TYPE
                                   INDEX BY BINARY_INTEGER;
G_MISS_PARTY_ID_TBL                CSC_PARTY_ID_TBL_TYPE;

-- Table of object_version_numbers to store when multiple updates are done in enable and
-- disable plans.
TYPE CSC_OBJ_VER_NUM_TBL_TYPE      IS TABLE OF NUMBER
				               INDEX BY BINARY_INTEGER;

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  Create_cust_plans
   --   Type    :  Private
   --   Pre-Req :  None.
   --   Function:  Does item level validations if required and calls the insert table
   --              handler to insert record into CSC_CUST_PLANS table.
   --   Parameters:
   --   IN
   --       p_api_version_number      IN   NUMBER     Required
   --       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
   --       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
   --       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
   --       P_CSC_CUST_PLANS_Rec      IN   CSC_CUST_PLANS_Rec_Type  Required
   --
   --   OUT NOCOPY:
   --       x_cust_plan_id            OUT  NOCOPY NUMBER
   --       x_object_version_number   OUT  NOCOPY NUMBER
   --       x_return_status           OUT  NOCOPY VARCHAR2
   --       x_msg_count               OUT  NOCOPY NUMBER
   --       x_msg_data                OUT  NOCOPY VARCHAR2
   --   Version : Current version 1.0
   --   End of Comments
   --
PROCEDURE Create_cust_plans(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     ,
    P_Commit                     IN   VARCHAR2     ,
    p_validation_level           IN   NUMBER       ,
    P_CSC_CUST_PLANS_Rec         IN   CSC_CUST_PLANS_Rec_Type  ,
    X_CUST_PLAN_ID               OUT  NOCOPY NUMBER,
    X_OBJECT_VERSION_NUMBER      OUT  NOCOPY NUMBER,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2
    );

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  Create_cust_plans (Overloaded procedure to take in a detailed list
   --                                 of parameters instead of a record type parameter)
   --   Type    :  Private
   --   Pre-Req :
   --   Parameters:
   --   IN
   --       p_api_version_number      IN   NUMBER     Required
   --       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
   --       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
   --       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
   --       P_PLAN_ID                 IN   NUMBER := FND_API.G_MISS_NUM,
   --       P_CUST_PLAN_ID            IN   NUMBER := FND_API.G_MISS_NUM,
   --       P_PARTY_ID                IN   NUMBER := FND_API.G_MISS_NUM,
   --       P_CUST_ACCOUNT_ID         IN   NUMBER := FND_API.G_MISS_NUM,
   --       P_CUST_ACCOUNT_ORG        IN   NUMBER := FND_API.G_MISS_NUM,
   --       P_PLAN_NAME               IN   VARCHAR2(90) := FND_API.G_MISS_CHAR,
   --       P_GROUP_NAME              IN   VARCHAR2(80) := FND_API.G_MISS_CHAR,
   --       P_PARTY_NUMBER            IN   VARCHAR2(30) := FND_API.G_MISS_CHAR,
   --       P_PARTY_NAME              IN   VARCHAR2(255) := FND_API.G_MISS_CHAR,
   --       P_PARTY_TYPE              IN   VARCHAR2(30) := FND_API.G_MISS_CHAR,
   --       P_ACCOUNT_NUMBER          IN   VARCHAR2(30) := FND_API.G_MISS_CHAR,
   --       P_ACCOUNT_NAME            IN   VARCHAR2(240) := FND_API.G_MISS_CHAR,
   --       P_PRIORITY                IN   NUMBER := FND_API.G_MISS_NUM,
   --       P_START_DATE_ACTIVE       IN   DATE := FND_API.G_MISS_DATE,
   --       P_END_DATE_ACTIVE         IN   DATE := FND_API.G_MISS_DATE,
   --       P_CUSTOMIZED_PLAN         IN   VARCHAR2(3) := FND_API.G_MISS_CHAR,
   --       P_USE_FOR_CUST_ACCOUNT    IN   VARCHAR2(3) := FND_API.G_MISS_CHAR,
   --       P_PLAN_STATUS_CODE        IN   VARCHAR2(30) := FND_API.G_MISS_CHAR,
   --       P_PLAN_STATUS_MEANING     IN   VARCHAR2(80) := FND_API.G_MISS_CHAR,
   --       P_MANUAL_FLAG             IN   VARCHAR2(3) := FND_API.G_MISS_CHAR,
   --       P_REQUEST_ID              IN   NUMBER := FND_API.G_MISS_NUM,
   --       P_PROGRAM_APPLICATION_ID  IN   NUMBER := FND_API.G_MISS_NUM,
   --       P_PROGRAM_ID              IN   NUMBER := FND_API.G_MISS_NUM,
   --       P_PROGRAM_UPDATE_DATE     IN   DATE := FND_API.G_MISS_DATE,
   --       P_CREATION_DATE           IN   DATE := FND_API.G_MISS_DATE,
   --       P_LAST_UPDATE_DATE        IN   DATE := FND_API.G_MISS_DATE,
   --       P_CREATED_BY              IN   NUMBER := FND_API.G_MISS_NUM,
   --       P_LAST_UPDATED_BY         IN   NUMBER := FND_API.G_MISS_NUM,
   --       P_LAST_UPDATE_LOGIN       IN   NUMBER := FND_API.G_MISS_NUM,
   --       P_ATTRIBUTE1              IN   VARCHAR2(450) := FND_API.G_MISS_CHAR,
   --       P_ATTRIBUTE2              IN   VARCHAR2(450) := FND_API.G_MISS_CHAR,
   --       P_ATTRIBUTE3              IN   VARCHAR2(450) := FND_API.G_MISS_CHAR,
   --       P_ATTRIBUTE4              IN   VARCHAR2(450) := FND_API.G_MISS_CHAR,
   --       P_ATTRIBUTE5              IN   VARCHAR2(450) := FND_API.G_MISS_CHAR,
   --       P_ATTRIBUTE6              IN   VARCHAR2(450) := FND_API.G_MISS_CHAR,
   --       P_ATTRIBUTE7              IN   VARCHAR2(450) := FND_API.G_MISS_CHAR,
   --       P_ATTRIBUTE8              IN   VARCHAR2(450) := FND_API.G_MISS_CHAR,
   --       P_ATTRIBUTE9              IN   VARCHAR2(450) := FND_API.G_MISS_CHAR,
   --       P_ATTRIBUTE10             IN   VARCHAR2(450) := FND_API.G_MISS_CHAR,
   --       P_ATTRIBUTE11             IN   VARCHAR2(450) := FND_API.G_MISS_CHAR,
   --       P_ATTRIBUTE12             IN   VARCHAR2(450) := FND_API.G_MISS_CHAR,
   --       P_ATTRIBUTE13             IN   VARCHAR2(450) := FND_API.G_MISS_CHAR,
   --       P_ATTRIBUTE14             IN   VARCHAR2(450) := FND_API.G_MISS_CHAR,
   --       P_ATTRIBUTE15             IN   VARCHAR2(450) := FND_API.G_MISS_CHAR,
   --       P_ATTRIBUTE_CATEGORY      IN   VARCHAR2(90) := FND_API.G_MISS_CHAR,
   --       P_OBJECT_VERSION_NUMBER   IN   NUMBER := FND_API.G_MISS_NUM
   --
   --       X_CUST_PLAN_ID            OUT  NOCOPY NUMBER,
   --       X_OBJECT_VERSION_NUMBER   OUT   NOCOPY NUMBER
   --       x_return_status           OUT   NOCOPY VARCHAR2
   --       x_msg_count               OUT   NOCOPY NUMBER
   --       x_msg_data                OUT   NOCOPY VARCHAR2
   --   Version : Current version 1.0
   --
   --   End of Comments
   --

PROCEDURE Create_cust_plans(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    p_validation_level           IN   NUMBER,
    P_PLAN_ID                    IN   NUMBER,
    P_CUST_PLAN_ID               IN   NUMBER,
    P_PARTY_ID                   IN   NUMBER,
    P_CUST_ACCOUNT_ID            IN   NUMBER,
    -- P_CUST_ACCOUNT_ORG           IN   NUMBER,
    P_START_DATE_ACTIVE          IN   DATE,
    P_END_DATE_ACTIVE            IN   DATE,
    P_MANUAL_FLAG                IN   VARCHAR2,
    P_PLAN_STATUS_CODE           IN   VARCHAR2,
    P_REQUEST_ID                 IN   NUMBER,
    P_PROGRAM_APPLICATION_ID     IN   NUMBER,
    P_PROGRAM_ID                 IN   NUMBER,
    P_PROGRAM_UPDATE_DATE        IN   DATE,
    P_CREATION_DATE              IN   DATE,
    P_LAST_UPDATE_DATE           IN   DATE,
    P_CREATED_BY                 IN   NUMBER,
    P_LAST_UPDATED_BY            IN   NUMBER,
    P_LAST_UPDATE_LOGIN          IN   NUMBER,
    P_ATTRIBUTE1                 IN   VARCHAR2,
    P_ATTRIBUTE2                 IN   VARCHAR2,
    P_ATTRIBUTE3                 IN   VARCHAR2,
    P_ATTRIBUTE4                 IN   VARCHAR2,
    P_ATTRIBUTE5                 IN   VARCHAR2,
    P_ATTRIBUTE6                 IN   VARCHAR2,
    P_ATTRIBUTE7                 IN   VARCHAR2,
    P_ATTRIBUTE8                 IN   VARCHAR2,
    P_ATTRIBUTE9                 IN   VARCHAR2,
    P_ATTRIBUTE10                IN   VARCHAR2,
    P_ATTRIBUTE11                IN   VARCHAR2,
    P_ATTRIBUTE12                IN   VARCHAR2,
    P_ATTRIBUTE13                IN   VARCHAR2,
    P_ATTRIBUTE14                IN   VARCHAR2,
    P_ATTRIBUTE15                IN   VARCHAR2,
    P_ATTRIBUTE_CATEGORY         IN   VARCHAR2,
    P_OBJECT_VERSION_NUMBER      IN   NUMBER,
    X_CUST_PLAN_ID               OUT  NOCOPY NUMBER,
    X_OBJECT_VERSION_NUMBER      OUT  NOCOPY NUMBER,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2
    );

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  Update_cust_plans
   --   Type    :  Private
   --   Pre-Req :  Record in CSC_CUST_PLANS to be updated.
   --   Function:  Does item level validations if required and calls the update table handler
   --              to update the record in CSC_CUST_PLANS.
   --   Parameters:
   --   IN
   --       p_api_version_number      IN   NUMBER     Required
   --       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
   --       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
   --       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
   --       P_CSC_CUST_PLANS_Rec      IN   CSC_CUST_PLANS_Rec_Type  Required
   --
   --   OUT NOCOPY :
   --       X_OBJECT_VERSION_NUMBER   OUT   NOCOPY NUMBER
   --       x_return_status           OUT   NOCOPY VARCHAR2
   --       x_msg_count               OUT   NOCOPY NUMBER
   --       x_msg_data                OUT   NOCOPY VARCHAR2
   --   Version : Current version 1.0
   --
   --   End of Comments
   --
PROCEDURE Update_cust_plans(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    p_validation_level           IN   NUMBER  ,
    P_CSC_CUST_PLANS_Rec         IN   CSC_CUST_PLANS_Rec_Type,
    X_OBJECT_VERSION_NUMBER      OUT  NOCOPY NUMBER,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2
    );

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  Update_cust_plans (Overloaded procedure to take in a detailed list
   --                                 of parameters instead of a record type parameter)
   --   Type    :  Private
   --   Pre-Req :
   --   Parameters:
   --   IN
   --       p_api_version_number      IN   NUMBER     Required
   --       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
   --       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
   --       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
   --       P_PLAN_ID                 IN   NUMBER := FND_API.G_MISS_NUM,
   --       P_CUST_PLAN_ID            IN   NUMBER := FND_API.G_MISS_NUM,
   --       P_PARTY_ID                IN   NUMBER := FND_API.G_MISS_NUM,
   --       P_CUST_ACCOUNT_ID         IN   NUMBER := FND_API.G_MISS_NUM,
   --       P_CUST_ACCOUNT_ORG        IN   NUMBER := FND_API.G_MISS_NUM,
   --       P_START_DATE_ACTIVE       IN   DATE := FND_API.G_MISS_DATE,
   --       P_END_DATE_ACTIVE         IN   DATE := FND_API.G_MISS_DATE,
   --       P_MANUAL_FLAG             IN   VARCHAR2(3) := FND_API.G_MISS_CHAR,
   --       P_PLAN_STATUS_CODE        IN   VARCHAR2(30) := FND_API.G_MISS_CHAR,
   --       P_REQUEST_ID              IN   NUMBER := FND_API.G_MISS_NUM,
   --       P_PROGRAM_APPLICATION_ID  IN   NUMBER := FND_API.G_MISS_NUM,
   --       P_PROGRAM_ID              IN   NUMBER := FND_API.G_MISS_NUM,
   --       P_PROGRAM_UPDATE_DATE     IN   DATE := FND_API.G_MISS_DATE,
   --       P_CREATION_DATE           IN   DATE := FND_API.G_MISS_DATE,
   --       P_LAST_UPDATE_DATE        IN   DATE := FND_API.G_MISS_DATE,
   --       P_CREATED_BY              IN   NUMBER := FND_API.G_MISS_NUM,
   --       P_LAST_UPDATED_BY         IN   NUMBER := FND_API.G_MISS_NUM,
   --       P_LAST_UPDATE_LOGIN       IN   NUMBER := FND_API.G_MISS_NUM,
   --       P_ATTRIBUTE1              IN   VARCHAR2(450) := FND_API.G_MISS_CHAR,
   --       P_ATTRIBUTE2              IN   VARCHAR2(450) := FND_API.G_MISS_CHAR,
   --       P_ATTRIBUTE3              IN   VARCHAR2(450) := FND_API.G_MISS_CHAR,
   --       P_ATTRIBUTE4              IN   VARCHAR2(450) := FND_API.G_MISS_CHAR,
   --       P_ATTRIBUTE5              IN   VARCHAR2(450) := FND_API.G_MISS_CHAR,
   --       P_ATTRIBUTE6              IN   VARCHAR2(450) := FND_API.G_MISS_CHAR,
   --       P_ATTRIBUTE7              IN   VARCHAR2(450) := FND_API.G_MISS_CHAR,
   --       P_ATTRIBUTE8              IN   VARCHAR2(450) := FND_API.G_MISS_CHAR,
   --       P_ATTRIBUTE9              IN   VARCHAR2(450) := FND_API.G_MISS_CHAR,
   --       P_ATTRIBUTE10             IN   VARCHAR2(450) := FND_API.G_MISS_CHAR,
   --       P_ATTRIBUTE11             IN   VARCHAR2(450) := FND_API.G_MISS_CHAR,
   --       P_ATTRIBUTE12             IN   VARCHAR2(450) := FND_API.G_MISS_CHAR,
   --       P_ATTRIBUTE13             IN   VARCHAR2(450) := FND_API.G_MISS_CHAR,
   --       P_ATTRIBUTE14             IN   VARCHAR2(450) := FND_API.G_MISS_CHAR,
   --       P_ATTRIBUTE15             IN   VARCHAR2(450) := FND_API.G_MISS_CHAR,
   --       P_ATTRIBUTE_CATEGORY      IN   VARCHAR2(90) := FND_API.G_MISS_CHAR,
   --       P_OBJECT_VERSION_NUMBER   IN   NUMBER := FND_API.G_MISS_NUM
   --
   --   OUT NOCOPY :
   --       X_OBJECT_VERSION_NUMBER   OUT   NOCOPY NUMBER
   --       x_return_status           OUT   NOCOPY VARCHAR2
   --       x_msg_count               OUT   NOCOPY NUMBER
   --       x_msg_data                OUT   NOCOPY VARCHAR2
   --   Version : Current version 1.0
   --
   --   End of Comments
   --
PROCEDURE Update_cust_plans(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    p_validation_level           IN   NUMBER,
    P_PLAN_ID                    IN   NUMBER,
    P_CUST_PLAN_ID               IN   NUMBER,
    P_PARTY_ID                   IN   NUMBER,
    P_CUST_ACCOUNT_ID            IN   NUMBER,
    P_START_DATE_ACTIVE          IN   DATE :=  NULL,
    P_END_DATE_ACTIVE            IN   DATE := NULL,
    P_MANUAL_FLAG                IN   VARCHAR2 :=  NULL,
    P_PLAN_STATUS_CODE           IN   VARCHAR2 := NULL,
    P_REQUEST_ID                 IN   NUMBER :=  NULL,
    P_PROGRAM_APPLICATION_ID     IN   NUMBER := NULL,
    P_PROGRAM_ID                 IN   NUMBER := NULL,
    P_PROGRAM_UPDATE_DATE        IN   DATE :=  NULL,
    P_CREATION_DATE              IN   DATE := NULL,
    P_LAST_UPDATE_DATE           IN   DATE :=  NULL,
    P_CREATED_BY                 IN   NUMBER :=  NULL,
    P_LAST_UPDATED_BY            IN   NUMBER :=  NULL,
    P_LAST_UPDATE_LOGIN          IN   NUMBER :=  NULL,
    P_ATTRIBUTE1                 IN   VARCHAR2 :=  NULL,
    P_ATTRIBUTE2                 IN   VARCHAR2 := NULL,
    P_ATTRIBUTE3                 IN   VARCHAR2 :=  NULL,
    P_ATTRIBUTE4                 IN   VARCHAR2 := NULL,
    P_ATTRIBUTE5                 IN   VARCHAR2 :=  NULL,
    P_ATTRIBUTE6                 IN   VARCHAR2 := NULL,
    P_ATTRIBUTE7                 IN   VARCHAR2 := NULL,
    P_ATTRIBUTE8                 IN   VARCHAR2 :=  NULL,
    P_ATTRIBUTE9                 IN   VARCHAR2 := NULL,
    P_ATTRIBUTE10                IN   VARCHAR2 := NULL,
    P_ATTRIBUTE11                IN   VARCHAR2 := NULL,
    P_ATTRIBUTE12                IN   VARCHAR2 := NULL,
    P_ATTRIBUTE13                IN   VARCHAR2 := NULL,
    P_ATTRIBUTE14                IN   VARCHAR2 := NULL,
    P_ATTRIBUTE15                IN   VARCHAR2 := NULL,
    P_ATTRIBUTE_CATEGORY         IN   VARCHAR2 := NULL,
    P_OBJECT_VERSION_NUMBER      IN   NUMBER,
    X_OBJECT_VERSION_NUMBER      OUT NOCOPY NUMBER,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    );


   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  ENABLE_PLAN
   --   Type    :  Private
   --   Pre-Req :  PLAN_STATUS_CODE column in CSC_CUST_PLANS to be updated to 'ENABLED'.
   --   Function:  Calls the update procedure to update the given record in
   --              CSC_CUST_PLANS.
   --   Parameters:
   --   IN
   --       p_api_version_number      IN   NUMBER     Required
   --       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
   --       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
   --       p_plan_id                 IN   NUMBER     Required
   --       p_party_id_tbl            IN   CSC_PARTY_ID_TBL_TYPE
   --                                                 Required
   --       p_plan_status_code        IN   VARCHAR2   Optional  Default =
   --                                                      CSC_CORE_UTILS_PVT.ENABLE_PLAN
   --   OUT NOCOPY :
   --       x_obj_ver_num_tbl         OUT   NOCOPY CSC_OBJ_VER_NUM_TBL_TYPE
   --       x_return_status           OUT   NOCOPY VARCHAR2
   --       x_msg_count               OUT   NOCOPY NUMBER
   --       x_msg_data                OUT   NOCOPY VARCHAR2
   --   Version : Current version 1.0
   --
   --   End of Comments
   --
PROCEDURE ENABLE_PLAN (
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    p_plan_id                    IN   NUMBER,
    p_party_id_tbl               IN   CSC_PARTY_ID_TBL_TYPE,
    p_plan_status_code           IN   VARCHAR2     := CSC_CORE_UTILS_PVT.ENABLE_PLAN,
    X_OBJ_VER_NUM_TBL            OUT  NOCOPY CSC_OBJ_VER_NUM_TBL_TYPE,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2 );

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  DISABLE_PLAN
   --   Type    :  Private
   --   Pre-Req :  PLAN_STATUS_CODE column in CSC_CUST_PLANS to be updated to 'DISABLED'.
   --   Function:  Calls the update procedure to update the given record in
   --              CSC_CUST_PLANS.
   --   Parameters:
   --   IN
   --       p_api_version_number      IN   NUMBER     Required
   --       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
   --       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
   --       p_plan_id                 IN   NUMBER     Required
   --       p_party_id_tbl            IN   CSC_PARTY_ID_TBL_TYPE
   --                                                 Required
   --       p_plan_status_code        IN   NUMBER     Optional  Default =
   --                                                     CSC_CORE_UTILS_PVT.DISABLE_PLAN
   --   OUT NOCOPY :
   --       x_obj_ver_num_tbl         OUT   NOCOPY CSC_OBJ_VER_NUM_TBL_TYPE
   --       x_return_status           OUT   NOCOPY VARCHAR2
   --       x_msg_count               OUT   NOCOPY NUMBER
   --       x_msg_data                OUT   NOCOPY VARCHAR2
   --   Version : Current version 1.0
   --
   --   End of Comments
   --
PROCEDURE DISABLE_PLAN (
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    p_plan_id                    IN   NUMBER,
    p_party_id_tbl               IN   CSC_PARTY_ID_TBL_TYPE,
    p_plan_status_code           IN   VARCHAR2     := CSC_CORE_UTILS_PVT.DISABLE_PLAN,
    X_OBJ_VER_NUM_TBL            OUT  NOCOPY CSC_OBJ_VER_NUM_TBL_TYPE,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2 );

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  Delete_cust_plans
   --   Type    :  Private
   --   Pre-Req :  Record in CSC_CUST_PLANS to be deleted.
   --   Function:  Calls the delete table handler to delete a given record in
   --              CSC_CUST_PLANS.
   --   Parameters:
   --   IN
   --       p_api_version_number      IN   NUMBER     Required
   --       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
   --       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
   --       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
   --       P_CUST_PLAN_ID            IN   NUMBER     Required
   --
   --   OUT NOCOPY :
   --       x_return_status           OUT   NOCOPY VARCHAR2
   --       x_msg_count               OUT   NOCOPY NUMBER
   --       x_msg_data                OUT   NOCOPY VARCHAR2
   --   Version : Current version 1.0
   --
   --   End of Comments
   --
PROCEDURE Delete_cust_plans(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    p_validation_level           IN   NUMBER  ,
    P_CUST_PLAN_ID               IN   NUMBER,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2
    );

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  Update_for_customized_plans
   --   Type    :  Private
   --   Pre-Req :  Record in CSC_CUST_PLANS to be updated to the new customized plan.
   --   Function:  Calls the update table handler to update the plan_ids of the specified
   --              parties, to the new customized plan id;
   --   Parameters:
   --   IN
   --       p_api_version_number      IN   NUMBER     Required
   --       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
   --       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
   --       p_plan_id                 IN   NUMBER     Required
   --       p_original_plan_id        IN   NUMBER     Required
   --       p_party_id                IN   NUMBER     Required
   --       p_cust_account_id         IN   NUMBER     Optional  Default = NULL
   --       p_cust_account_org        IN   NUMBER     Optional  Default = NULL
   --       p_object_version_number   IN   NUMBER     Required
   --
   --   OUT NOCOPY :
   --       x_object_version_number   OUT   NOCOPY NUMBER
   --       x_return_status           OUT   NOCOPY VARCHAR2
   --       x_msg_count               OUT   NOCOPY NUMBER
   --       x_msg_data                OUT   NOCOPY VARCHAR2
   --   Version : Current version 1.0
   --
   --   End of Comments
   --
PROCEDURE Update_for_customized_plans (
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    P_PLAN_ID                    IN   NUMBER,
    P_ORIGINAL_PLAN_ID           IN   NUMBER,
    P_PARTY_ID                   IN   NUMBER,
    P_CUST_ACCOUNT_ID            IN   NUMBER       := NULL,
    -- P_CUST_ACCOUNT_ORG           IN   NUMBER       := NULL,
    P_OBJECT_VERSION_NUMBER      IN   NUMBER,
    X_OBJECT_VERSION_NUMBER      OUT  NOCOPY NUMBER,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2
    );

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  get_cust_plan_id
   --   Type    :  Private
   --   Pre-Req :  Record in CSC_CUST_PLANS to be deleted.
   --   Function:  This function is used with varying where clauses to return back the
   --              primary key CUST_PLAN_ID.
   --
   --   Parameters:
   --   IN
   --       p_api_version_number      IN   NUMBER     Required
   --       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
   --       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
   --       p_where_clause            IN   VARCHAR2
   --
   --   OUT NOCOPY :
   --       x_cust_plan_id            OUT   NOCOPY NUMBER
   --       x_return_status           OUT   NOCOPY VARCHAR2
   --       x_msg_count               OUT   NOCOPY NUMBER
   --       x_msg_data                OUT   NOCOPY VARCHAR2
   --   Version : Current version 1.0
   --
   --   End of Comments
   --
PROCEDURE GET_CUST_PLAN_ID(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_WHERE_CLAUSE               IN   VARCHAR2,
    X_CUST_PLAN_ID               OUT  NOCOPY NUMBER
    --X_Return_Status              OUT  NOCOPY VARCHAR2,
    --X_Msg_Count                  OUT  NOCOPY NUMBER,
    --X_Msg_Data                   OUT  NOCOPY VARCHAR2
    );

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  Validate_Cust_Plan_Id
   --   Type    :  Private
   --   Pre-Req :
   --   Function:
   --   Parameters:
   --   IN
   --       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
   --       p_validation_mode         IN   VARCHAR2   Required
   --       P_CUST_PLAN_ID            IN   NUMBER     Required
   --
   --   OUT NOCOPY :
   --       x_return_status           OUT   NOCOPY VARCHAR2
   --       x_msg_count               OUT   NOCOPY NUMBER
   --       x_msg_data                OUT   NOCOPY VARCHAR2
   --   Version : Current version 1.0
   --
   --   End of Comments
   --
PROCEDURE Validate_CUST_PLAN_ID (
    P_Init_Msg_List              IN   VARCHAR2,
    P_Validation_mode            IN   VARCHAR2,
    P_CUST_PLAN_ID               IN   NUMBER,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2
    );

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  Validate_Plan_Id
   --   Type    :  Private
   --   Pre-Req :
   --   Function:
   --   Parameters:
   --   IN
   --       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
   --       p_validation_mode         IN   VARCHAR2   Required
   --       p_identity_salesforce_id  IN   NUMBER     Optional  Default = NULL
   --       P_PLAN_ID                 IN   NUMBER     Required
   --
   --   OUT NOCOPY :
   --       x_return_status           OUT   NOCOPY VARCHAR2
   --       x_msg_count               OUT   NOCOPY NUMBER
   --       x_msg_data                OUT   NOCOPY VARCHAR2
   --   Version : Current version 1.0
   --
   --   End of Comments
   --
PROCEDURE Validate_PLAN_ID (
    P_Init_Msg_List              IN   VARCHAR2,
    P_Validation_mode            IN   VARCHAR2,
    P_PLAN_ID                    IN   NUMBER,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2
    );

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  Validate_Party_Id
   --   Type    :  Private
   --   Pre-Req :
   --   Function:
   --   Parameters:
   --   IN
   --       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
   --       p_validation_mode         IN   VARCHAR2   Required
   --       P_PARTY_ID                IN   NUMBER     Required
   --
   --   OUT NOCOPY :
   --       x_return_status           OUT   NOCOPY VARCHAR2
   --       x_msg_count               OUT   NOCOPY NUMBER
   --       x_msg_data                OUT   NOCOPY VARCHAR2
   --   Version : Current version 1.0
   --
   --   End of Comments
   --
PROCEDURE Validate_PARTY_ID (
    P_Init_Msg_List              IN   VARCHAR2,
    P_Validation_mode            IN   VARCHAR2,
    P_PARTY_ID                   IN   NUMBER,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2
    );

-- Removing org_id completely in lieu of TCA's decision to drop column org_id
-- from HZ_CUST_ACCOUNTS.
   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  Validate_Cust_Acc_Org_Id
   --   Type    :  Private
   --   Pre-Req :
   --   Function:
   --   Parameters:
   --   IN
   --       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
   --       p_validation_mode         IN   VARCHAR2   Required
   --       P_Party_Id                IN   NUMBER     Required
   --       P_Cust_Account_Id         IN   NUMBER     Required
   --       P_Cust_Account_Org        IN   NUMBER     Required
   --
   --   OUT NOCOPY :
   --       x_return_status           OUT   NOCOPY VARCHAR2
   --       x_msg_count               OUT   NOCOPY NUMBER
   --       x_msg_data                OUT   NOCOPY VARCHAR2
   --   Version : Current version 1.0
   --
   --   End of Comments
   --
/****
PROCEDURE Validate_CUST_ACC_ORG_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PARTY_ID                   IN   NUMBER,
    P_CUST_ACCOUNT_ID            IN   NUMBER,
    P_CUST_ACCOUNT_ORG           IN   NUMBER,
    X_Return_Status              OUT  VARCHAR2,
    X_Msg_Count                  OUT  NUMBER,
    X_Msg_Data                   OUT  VARCHAR2
    );
********/

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  Validate_Manual_Flag
   --   Type    :  Private
   --   Pre-Req :
   --   Function:
   --   Parameters:
   --   IN
   --       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
   --       p_validation_mode         IN   NUMBER     Required
   --       P_MANUAL_FLAG             IN   VARCHAR2   Required
   --
   --   OUT NOCOPY :
   --       x_return_status           OUT   NOCOPY VARCHAR2
   --       x_msg_count               OUT   NOCOPY NUMBER
   --       x_msg_data                OUT   NOCOPY VARCHAR2
   --   Version : Current version 1.0
   --
   --   End of Comments
   --
PROCEDURE Validate_MANUAL_FLAG (
    P_Init_Msg_List              IN   VARCHAR2,
    P_Validation_mode            IN   VARCHAR2,
    P_MANUAL_FLAG                IN   VARCHAR2,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2
    );


   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  Validate_Plan_Status_Code
   --   Type    :  Private
   --   Pre-Req :
   --   Function:
   --   Parameters:
   --   IN
   --       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
   --       p_validation_mode         IN   NUMBER     Required
   --       P_Plan_Status_Code        IN   VARCHAR2   Required
   --
   --   OUT NOCOPY :
   --       x_return_status           OUT   NOCOPY VARCHAR2
   --       x_msg_count               OUT   NOCOPY NUMBER
   --       x_msg_data                OUT   NOCOPY VARCHAR2
   --   Version : Current version 1.0
   --
   --   End of Comments
   --
PROCEDURE Validate_PLAN_STATUS_CODE (
    P_Init_Msg_List              IN   VARCHAR2,
    P_Validation_mode            IN   VARCHAR2,
    P_PLAN_STATUS_CODE           IN   VARCHAR2,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2
    );

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  Validate_csc_cust_plans
   --   Type    :  Private
   --   Pre-Req :
   --   Function:
   --   Parameters:
   --   IN
   --       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
   --       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
   --       p_validation_mode         IN   VARCHAR2   Required
   --       P_CSC_CUST_PLANS_Rec      IN   CSC_CUST_PLANS_Rec_Type  Required
   --
   --   OUT NOCOPY :
   --       x_return_status           OUT   NOCOPY VARCHAR2
   --       x_msg_count               OUT   NOCOPY NUMBER
   --       x_msg_data                OUT   NOCOPY VARCHAR2
   --   Version : Current version 1.0
   --
   --   End of Comments
   --
PROCEDURE Validate_csc_cust_plans(
    P_Init_Msg_List              IN   VARCHAR2,
    P_Validation_level           IN   NUMBER ,
    P_Validation_mode            IN   VARCHAR2,
    P_CSC_CUST_PLANS_Rec         IN   CSC_CUST_PLANS_Rec_Type,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2
    );
End CSC_CUST_PLANS_PVT;

 

/
