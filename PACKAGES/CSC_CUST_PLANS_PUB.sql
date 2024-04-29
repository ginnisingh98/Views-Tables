--------------------------------------------------------
--  DDL for Package CSC_CUST_PLANS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSC_CUST_PLANS_PUB" AUTHID CURRENT_USER as
/* $Header: cscpctps.pls 120.0 2005/05/30 15:48:11 appldev noship $ */
-- Start of Comments
-- Package name     : CSC_CUST_PLANS_PUB
-- Purpose          : Public package contains defnitions of procedure, and
--                    functions to insert, update and delete records in
--                    CSC_CUST_PLANS table.
-- History          :
-- MM-DD-YYYY    NAME          MODIFICATIONS
-- 10-28-1999    dejoseph      Created.
-- 12-08-1999    dejoseph      'Arcs'ed in for first code freeze.
-- 12-21-1999    dejoseph      'Arcs'ed in for second code freeze.
-- 01-03-2000    dejoseph      'Arcs'ed in for third code freeze. (10-JAN-2000)
-- 01-31-2000    dejoseph      'Arcs'ed in for fourth code freeze. (07-FEB-2000)
-- 02-13-2000    dejoseph      'Arcs'ed on for fifth code freeze. (21-FEB-2000)
-- 02-28-2000    dejoseph      'Arcs'ed on for sixth code freeze. (06-MAR-2000)
-- 04-10-2000    dejoseph      Removed reference to cust_account_org in lieu of TCA's
--                             decision to drop column org_id from hz_cust_accounts.
-- 26-11-2002	bhroy		G_MISS_XXX defaults of API parameters removed, added WHENEVER OSERROR EXIT FAILURE ROLLBACK

-- NOTE             :
-- End of Comments

-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;

TYPE CSC_CUST_PLANS_Rec_Type IS RECORD
(
       ROW_ID                          ROWID,
       PLAN_ID                         NUMBER,
       CUST_PLAN_ID                    NUMBER,
       PARTY_ID                        NUMBER,
       CUST_ACCOUNT_ID                 NUMBER,
       PLAN_NAME                       VARCHAR2(90),
       GROUP_NAME                      VARCHAR2(80),
       PARTY_NUMBER                    VARCHAR2(30),
       PARTY_NAME                      VARCHAR2(255),
       PARTY_TYPE                      VARCHAR2(30),
       ACCOUNT_NUMBER                  VARCHAR2(30),
       ACCOUNT_NAME                    VARCHAR2(240),
       START_DATE_ACTIVE               DATE,
       END_DATE_ACTIVE                 DATE,
       CUSTOMIZED_PLAN                 VARCHAR2(3),
       USE_FOR_CUST_ACCOUNT            VARCHAR2(3),
       PLAN_STATUS_CODE                VARCHAR2(30),
       PLAN_STATUS_MEANING             VARCHAR2(80),
       MANUAL_FLAG                     VARCHAR2(3),
       REQUEST_ID                      NUMBER,
       PROGRAM_APPLICATION_ID          NUMBER,
       PROGRAM_ID                      NUMBER,
       PROGRAM_UPDATE_DATE             DATE,
       CREATION_DATE                   DATE,
       LAST_UPDATE_DATE                DATE,
       CREATED_BY                      NUMBER,
       LAST_UPDATED_BY                 NUMBER,
       USER_NAME                       VARCHAR2(100),
       LAST_UPDATE_LOGIN               NUMBER,
       ATTRIBUTE1                      VARCHAR2(450),
       ATTRIBUTE2                      VARCHAR2(450),
       ATTRIBUTE3                      VARCHAR2(450),
       ATTRIBUTE4                      VARCHAR2(450),
       ATTRIBUTE5                      VARCHAR2(450),
       ATTRIBUTE6                      VARCHAR2(450),
       ATTRIBUTE7                      VARCHAR2(450),
       ATTRIBUTE8                      VARCHAR2(450),
       ATTRIBUTE9                      VARCHAR2(450),
       ATTRIBUTE10                     VARCHAR2(450),
       ATTRIBUTE11                     VARCHAR2(450),
       ATTRIBUTE12                     VARCHAR2(450),
       ATTRIBUTE13                     VARCHAR2(450),
       ATTRIBUTE14                     VARCHAR2(450),
       ATTRIBUTE15                     VARCHAR2(450),
       ATTRIBUTE_CATEGORY              VARCHAR2(90),
       OBJECT_VERSION_NUMBER           NUMBER
);

G_MISS_CSC_CUST_PLANS_REC          CSC_CUST_PLANS_Rec_Type;

TYPE  CSC_CUST_PLANS_Tbl_Type      IS TABLE OF CSC_CUST_PLANS_Rec_Type
                                   INDEX BY BINARY_INTEGER;
G_MISS_CSC_CUST_PLANS_TBL          CSC_CUST_PLANS_Tbl_Type;

TYPE CSC_PARTY_ID_REC_TYPE IS RECORD (
       PARTY_ID                        NUMBER,
       CUST_ACCOUNT_ID                 NUMBER);

TYPE CSC_PARTY_ID_TBL_TYPE         IS TABLE OF CSC_PARTY_ID_REC_TYPE
                                   INDEX BY BINARY_INTEGER;
G_MISS_PARTY_ID_TBL                CSC_PARTY_ID_TBL_TYPE;


   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  Create_cust_plans
   --   Type    :  Public
   --   Pre-Req :
   --   Parameters:
   --   IN
   --       p_api_version_number      IN   NUMBER     Required
   --       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
   --       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
   --       P_CSC_CUST_PLANS_Rec      IN   CSC_CUST_PLANS_Rec_Type  Required
   --
   --   OUT NOCOPY:
   --       X_CUST_PLAN_ID            OUT  NOCOPY NUMBER
   --       X_OBJECT_VERSION_NUMBER   OUT  NOCOPY NUMBER
   --       x_return_status           OUT  NOCOPY VARCHAR2
   --       x_msg_count               OUT  NOCOPY NUMBER
   --       x_msg_data                OUT  NOCOPY VARCHAR2
   --   Version : Current version 1.0
   --
   --   End of Comments
   --
PROCEDURE Create_cust_plans(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := NULL,
    P_Commit                     IN   VARCHAR2     := NULL,
    P_CSC_CUST_PLANS_Rec         IN   CSC_CUST_PLANS_Rec_Type  := NULL,
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
   --   Type    :  Public
   --   Pre-Req :
   --   Parameters:
   --   IN
   --       p_api_version_number      IN   NUMBER     Required
   --       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
   --       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
   --       P_ROW_ID                  IN   ROWID := FND_API.G_MISS_CHAR,
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
   --       P_USER_NAME               IN   VARCHAR2(100) := FND_API.G_MISS_CHAR,
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
   --   OUT NOCOPY:
   --       X_CUST_PLAN_ID            OUT  NOCOPY NUMBER,
   --       X_OBJECT_VERSION_NUMBER   OUT  NOCOPY NUMBER
   --       x_return_status           OUT  NOCOPY VARCHAR2
   --       x_msg_count               OUT  NOCOPY NUMBER
   --       x_msg_data                OUT  NOCOPY VARCHAR2
   --   Version : Current version 1.0
   --
   --   End of Comments
   --

PROCEDURE Create_cust_plans(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := NULL,
    P_Commit                     IN   VARCHAR2     := NULL,
    P_ROW_ID                     IN   ROWID := NULL,
    P_PLAN_ID                    IN   NUMBER,
    P_CUST_PLAN_ID               IN   NUMBER,
    P_PARTY_ID                   IN   NUMBER,
    P_CUST_ACCOUNT_ID            IN   NUMBER := NULL,
    P_PLAN_NAME                  IN   VARCHAR2 := NULL,
    P_GROUP_NAME                 IN   VARCHAR2 := NULL,
    P_PARTY_NUMBER               IN   VARCHAR2 := NULL,
    P_PARTY_NAME                 IN   VARCHAR2 := NULL,
    P_PARTY_TYPE                 IN   VARCHAR2 := NULL,
    P_ACCOUNT_NUMBER             IN   VARCHAR2 := NULL,
    P_ACCOUNT_NAME               IN   VARCHAR2 := NULL,
    P_START_DATE_ACTIVE          IN   DATE := NULL,
    P_END_DATE_ACTIVE            IN   DATE := NULL,
    P_CUSTOMIZED_PLAN            IN   VARCHAR2 := NULL,
    P_USE_FOR_CUST_ACCOUNT       IN   VARCHAR2 := NULL,
    P_PLAN_STATUS_CODE           IN   VARCHAR2 := NULL,
    P_PLAN_STATUS_MEANING        IN   VARCHAR2 := NULL,
    P_MANUAL_FLAG                IN   VARCHAR2 := NULL,
    P_REQUEST_ID                 IN   NUMBER := NULL,
    P_PROGRAM_APPLICATION_ID     IN   NUMBER := NULL,
    P_PROGRAM_ID                 IN   NUMBER := NULL,
    P_PROGRAM_UPDATE_DATE        IN   DATE := NULL,
    P_CREATION_DATE              IN   DATE := NULL,
    P_LAST_UPDATE_DATE           IN   DATE := NULL,
    P_CREATED_BY                 IN   NUMBER := NULL,
    P_LAST_UPDATED_BY            IN   NUMBER := NULL,
    P_USER_NAME                  IN   VARCHAR2 := NULL,
    P_LAST_UPDATE_LOGIN          IN   NUMBER := NULL,
    P_ATTRIBUTE1                 IN   VARCHAR2 := NULL,
    P_ATTRIBUTE2                 IN   VARCHAR2 := NULL,
    P_ATTRIBUTE3                 IN   VARCHAR2 := NULL,
    P_ATTRIBUTE4                 IN   VARCHAR2 := NULL,
    P_ATTRIBUTE5                 IN   VARCHAR2 := NULL,
    P_ATTRIBUTE6                 IN   VARCHAR2 := NULL,
    P_ATTRIBUTE7                 IN   VARCHAR2 := NULL,
    P_ATTRIBUTE8                 IN   VARCHAR2 := NULL,
    P_ATTRIBUTE9                 IN   VARCHAR2 := NULL,
    P_ATTRIBUTE10                IN   VARCHAR2 := NULL,
    P_ATTRIBUTE11                IN   VARCHAR2 := NULL,
    P_ATTRIBUTE12                IN   VARCHAR2 := NULL,
    P_ATTRIBUTE13                IN   VARCHAR2 := NULL,
    P_ATTRIBUTE14                IN   VARCHAR2 := NULL,
    P_ATTRIBUTE15                IN   VARCHAR2 := NULL,
    P_ATTRIBUTE_CATEGORY         IN   VARCHAR2 := NULL,
    P_OBJECT_VERSION_NUMBER      IN   NUMBER := NULL,
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
   --   Type    :  Public
   --   Pre-Req :
   --   Parameters:
   --   IN
   --       p_api_version_number      IN   NUMBER     Required
   --       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
   --       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
   --       P_CSC_CUST_PLANS_Rec      IN   CSC_CUST_PLANS_Rec_Type  Required
   --
   --   OUT NOCOPY:
   --       X_OBJECT_VERSION_NUMBER   OUT  NOCOPY NUMBER
   --       x_return_status           OUT  NOCOPY VARCHAR2
   --       x_msg_count               OUT  NOCOPY NUMBER
   --       x_msg_data                OUT  NOCOPY VARCHAR2
   --   Version : Current version 1.0
   --
   --   End of Comments
   --
PROCEDURE Update_cust_plans(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := NULL,
    P_Commit                     IN   VARCHAR2     := NULL,
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
   --   Type    :  Public
   --   Pre-Req :
   --   Parameters:
   --   IN
   --       p_api_version_number      IN   NUMBER     Required
   --       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
   --       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
   --       P_ROW_ID                  IN   ROWID := FND_API.G_MISS_CHAR,
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
   --       P_USER_NAME               IN   VARCHAR2(100) := FND_API.G_MISS_CHAR,
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
   --   OUT NOCOPY:
   --       X_OBJECT_VERSION_NUMBER   OUT  NOCOPY NUMBER
   --       x_return_status           OUT  NOCOPY VARCHAR2
   --       x_msg_count               OUT  NOCOPY NUMBER
   --       x_msg_data                OUT  NOCOPY VARCHAR2
   --   Version : Current version 1.0
   --
   --   End of Comments
   --
PROCEDURE Update_cust_plans(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := NULL,
    P_Commit                     IN   VARCHAR2     := NULL,
    P_ROW_ID                     IN   ROWID := NULL,
    P_PLAN_ID                    IN   NUMBER,
    P_CUST_PLAN_ID               IN   NUMBER,
    P_PARTY_ID                   IN   NUMBER,
    P_CUST_ACCOUNT_ID            IN   NUMBER := NULL,
    P_PLAN_NAME                  IN   VARCHAR2 := NULL,
    P_GROUP_NAME                 IN   VARCHAR2 := NULL,
    P_PARTY_NUMBER               IN   VARCHAR2 := NULL,
    P_PARTY_NAME                 IN   VARCHAR2 := NULL,
    P_PARTY_TYPE                 IN   VARCHAR2 := NULL,
    P_ACCOUNT_NUMBER             IN   VARCHAR2 := NULL,
    P_ACCOUNT_NAME               IN   VARCHAR2 := NULL,
    P_START_DATE_ACTIVE          IN   DATE := NULL,
    P_END_DATE_ACTIVE            IN   DATE := NULL,
    P_CUSTOMIZED_PLAN            IN   VARCHAR2 := NULL,
    P_USE_FOR_CUST_ACCOUNT       IN   VARCHAR2 := NULL,
    P_PLAN_STATUS_CODE           IN   VARCHAR2 := NULL,
    P_PLAN_STATUS_MEANING        IN   VARCHAR2 := NULL,
    P_MANUAL_FLAG                IN   VARCHAR2 := NULL,
    P_REQUEST_ID                 IN   NUMBER := NULL,
    P_PROGRAM_APPLICATION_ID     IN   NUMBER := NULL,
    P_PROGRAM_ID                 IN   NUMBER := NULL,
    P_PROGRAM_UPDATE_DATE        IN   DATE := NULL,
    P_CREATION_DATE              IN   DATE := NULL,
    P_LAST_UPDATE_DATE           IN   DATE := NULL,
    P_CREATED_BY                 IN   NUMBER := NULL,
    P_LAST_UPDATED_BY            IN   NUMBER := NULL,
    P_USER_NAME                  IN   VARCHAR2 := NULL,
    P_LAST_UPDATE_LOGIN          IN   NUMBER := NULL,
    P_ATTRIBUTE1                 IN   VARCHAR2 := NULL,
    P_ATTRIBUTE2                 IN   VARCHAR2 := NULL,
    P_ATTRIBUTE3                 IN   VARCHAR2 := NULL,
    P_ATTRIBUTE4                 IN   VARCHAR2 := NULL,
    P_ATTRIBUTE5                 IN   VARCHAR2 := NULL,
    P_ATTRIBUTE6                 IN   VARCHAR2 := NULL,
    P_ATTRIBUTE7                 IN   VARCHAR2 := NULL,
    P_ATTRIBUTE8                 IN   VARCHAR2 := NULL,
    P_ATTRIBUTE9                 IN   VARCHAR2 := NULL,
    P_ATTRIBUTE10                IN   VARCHAR2 := NULL,
    P_ATTRIBUTE11                IN   VARCHAR2 := NULL,
    P_ATTRIBUTE12                IN   VARCHAR2 := NULL,
    P_ATTRIBUTE13                IN   VARCHAR2 := NULL,
    P_ATTRIBUTE14                IN   VARCHAR2 := NULL,
    P_ATTRIBUTE15                IN   VARCHAR2 := NULL,
    P_ATTRIBUTE_CATEGORY         IN   VARCHAR2 := NULL,
    P_OBJECT_VERSION_NUMBER      IN   NUMBER := NULL,
    X_OBJECT_VERSION_NUMBER      OUT  NOCOPY NUMBER,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2
    );

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  ENABLE_PLAN
   --   Type    :  Public
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
   --                                                 Optional  Default = G_MISS_PARTY_ID_TBL
   --       p_plan_status_code        IN   NUMBER     Optional  Default =
   --                                                      CSC_CORE_UTILS_PVT.ENABLE_PLAN
   --   OUT NOCOPY:
   --       x_object_version_number   OUT  NOCOPY NUMBER
   --       x_return_status           OUT  NOCOPY VARCHAR2
   --       x_msg_count               OUT  NOCOPY NUMBER
   --       x_msg_data                OUT  NOCOPY VARCHAR2
   --   Version : Current version 1.0
   --
   --   End of Comments
   --
PROCEDURE ENABLE_PLAN (
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := NULL,
    P_Commit                     IN   VARCHAR2     := NULL,
    P_plan_id                    IN   NUMBER,
    p_party_id_tbl               IN   CSC_PARTY_ID_TBL_TYPE,
    p_plan_status_code           IN   VARCHAR2     := CSC_CORE_UTILS_PVT.ENABLE_PLAN,
    X_OBJECT_VERSION_NUMBER      OUT  NOCOPY NUMBER,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2 );

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  DISABLE_PLAN
   --   Type    :  Public
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
   --                                                 Optional  Default = G_MISS_PARTY_ID_TBL
   --       p_plan_status_code        IN   NUMBER     Optional  Default =
   --                                                      CSC_CORE_UTILS_PVT.ENABLE_PLAN
   --   OUT NOCOPY:
   --       x_object_version_number   OUT  NOCOPY NUMBER
   --       x_return_status           OUT  NOCOPY VARCHAR2
   --       x_msg_count               OUT  NOCOPY NUMBER
   --       x_msg_data                OUT  NOCOPY VARCHAR2
   --   Version : Current version 1.0
   --
   --   End of Comments
   --
PROCEDURE DISABLE_PLAN (
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := NULL,
    P_Commit                     IN   VARCHAR2     := NULL,
    P_plan_id                    IN   NUMBER,
    p_party_id_tbl               IN   CSC_PARTY_ID_TBL_TYPE,
    p_plan_status_code           IN   VARCHAR2     := CSC_CORE_UTILS_PVT.DISABLE_PLAN,
    X_OBJECT_VERSION_NUMBER      OUT  NOCOPY NUMBER,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2 );

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  Delete_cust_plans
   --   Type    :  Public
   --   Pre-Req :
   --   Parameters:
   --   IN
   --       p_api_version_number      IN   NUMBER     Required
   --       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
   --       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
   --       P_CUST_PLAN_ID            IN   NUMBER     Required
   --
   --   OUT NOCOPY:
   --       x_return_status           OUT  NOCOPY VARCHAR2
   --       x_msg_count               OUT  NOCOPY NUMBER
   --       x_msg_data                OUT  NOCOPY VARCHAR2
   --   Version : Current version 1.0
   --
   --   End of Comments
   --
PROCEDURE Delete_cust_plans(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := NULL,
    P_Commit                     IN   VARCHAR2     := NULL,
    P_CUST_PLAN_ID               IN   NUMBER,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2
    );

End CSC_CUST_PLANS_PUB;

 

/
