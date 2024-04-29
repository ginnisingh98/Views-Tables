--------------------------------------------------------
--  DDL for Package CSC_RELATIONSHIP_PLANS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSC_RELATIONSHIP_PLANS_PUB" AUTHID CURRENT_USER as
/* $Header: cscprlps.pls 120.0 2005/05/30 15:49:10 appldev noship $ */
-- Start of Comments
-- Package name     : CSC_RELATIONSHIP_PLANS_PUB
-- Purpose          : This package contains all procedures and functions that are required
--                    to create and modify plan headers and disable plans.
-- History
-- MM-DD-YYYY    NAME          MODIFICATIONS
-- 10-08-1999    dejoseph      Created.
-- 12-08-1999    dejoseph      'Arcs'ed in for first code freeze.
-- 12-21-1999    dejoseph      'Arcs'ed in for second code freeze.
-- 01-03-2000    dejoseph      'Arcs'ed in for third code freeze. (10-JAN-2000)
-- 01-31-2000    dejoseph      'Arcs'ed in for fourth code freeze. (07-FEB-2000)
-- 02-13-2000    dejoseph      'Arcs'ed on for fifth code freeze. (21-FEB-2000)
-- 02-28-2000    dejoseph      'Arcs'ed on for sixth code freeze. (06-MAR-2000)
-- 02-18-2002    dejoseph      Added changes to uptake new functionality for 11.5.8.
--                             Ct. / Agent facing application
--                             - Added new IN parameter END_USER_TYPE
--                             Added the dbdrv command.
-- 05-23-2002    dejoseph      Added checkfile syntax.
-- 11-12-2002	 bhroy		NOCOPY changes made
-- 11-27-2002	 bhroy		All the default values have been removed, added WHENEVER OSERROR EXIT FAILURE ROLLBACK
-- End of Comments

-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;

TYPE CSC_PLAN_HEADERS_B_REC_TYPE IS RECORD
(
       ROW_ID                          ROWID ,
       PLAN_ID                         NUMBER,
       ORIGINAL_PLAN_ID                NUMBER,
       PLAN_GROUP_CODE                 VARCHAR2(30),
       START_DATE_ACTIVE               DATE,
       END_DATE_ACTIVE                 DATE,
       USE_FOR_CUST_ACCOUNT            VARCHAR2(1),
       END_USER_TYPE                   VARCHAR2(30),
       CUSTOMIZED_PLAN                 VARCHAR2(1),
       PROFILE_CHECK_ID                NUMBER ,
       RELATIONAL_OPERATOR             VARCHAR2(30),
       CRITERIA_VALUE_HIGH             VARCHAR2(50),
       CRITERIA_VALUE_LOW              VARCHAR2(50),
       CREATION_DATE                   DATE ,
       LAST_UPDATE_DATE                DATE,
       CREATED_BY                      NUMBER ,
       LAST_UPDATED_BY                 NUMBER,
       LAST_UPDATE_LOGIN               NUMBER,
       ATTRIBUTE1                      VARCHAR2(150) ,
       ATTRIBUTE2                      VARCHAR2(150),
       ATTRIBUTE3                      VARCHAR2(150),
       ATTRIBUTE4                      VARCHAR2(150),
       ATTRIBUTE5                      VARCHAR2(150),
       ATTRIBUTE6                      VARCHAR2(150),
       ATTRIBUTE7                      VARCHAR2(150),
       ATTRIBUTE8                      VARCHAR2(150),
       ATTRIBUTE9                      VARCHAR2(150),
       ATTRIBUTE10                     VARCHAR2(150),
       ATTRIBUTE11                     VARCHAR2(150),
       ATTRIBUTE12                     VARCHAR2(150),
       ATTRIBUTE13                     VARCHAR2(150),
       ATTRIBUTE14                     VARCHAR2(150),
       ATTRIBUTE15                     VARCHAR2(150),
       ATTRIBUTE_CATEGORY              VARCHAR2(90),
       OBJECT_VERSION_NUMBER           NUMBER
);

G_MISS_CSC_PLAN_HEADERS_B_REC          CSC_PLAN_HEADERS_B_REC_TYPE;

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  create_plan_header
   --   Type    :  Public
   --   Pre-Req :  None
   --   Function:  Procedure to create a plan header. Insert records into CSC_PLAN_HEADERS_B
   --              and CSC_PLAN_HEADERS_TL
   --   Parameters:
   --   IN
   --       p_api_version_number      IN   NUMBER     Required
   --       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
   --       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
   --       P_CSC_PLAN_HEADERS_B_Rec  IN   CSC_PLAN_HEADERS_B_REC_TYPE  Required
   --       P_DESCRIPTION             IN   VARCHAR2   Required -- Plan description for translation
   --                                                          -- table
   --       P_NAME                    IN   VARCHAR2   Required -- Plan name for translation table.
   --       P_PARTY_ID_TBL            IN   CSC_CUST_PLANS_PVT.CSC_PARTY_ID_TBL_TYPE
   --							              Optional  Default =
   --                                                CSC_CUST_PLANS_PVT.G_MISS_PARTY_ID_TBL
   --                          -- If a plan is being customized, then this table of party_ids
   --                          -- store the ids of the parties for which the plan is being
   --                          -- customized.
   --                          -- If a 'CUSTOMIZED ACCOUNT LEVEL' plan ie. CUSTOMIZED_PLAN='Y'
   --                          -- and 'USE_FOR_CUST_ACCOUNT='Y', is being created, then the
   --                          -- ACCOUNT_ID and ACCOUNT_ORG should be specified.
   --
   --   OUT  NOCOPY:
   --       x_plan_id                 OUT NOCOPY  NUMBER
   --       x_object_version_number   OUT NOCOPY  NUMBER
   --       x_return_status           OUT NOCOPY  VARCHAR2
   --       x_msg_count               OUT NOCOPY  NUMBER
   --       x_msg_data                OUT NOCOPY  VARCHAR2
   --   Version : Current version 1.0
   --
   --   End of Comments

PROCEDURE create_plan_header(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := NULL,
    P_Commit                     IN   VARCHAR2     := NULL,
    P_CSC_PLAN_HEADERS_B_REC     IN   CSC_PLAN_HEADERS_B_REC_TYPE := NULL,
    P_DESCRIPTION                IN   VARCHAR2,
    P_NAME                       IN   VARCHAR2,
    P_PARTY_ID_TBL               IN   CSC_CUST_PLANS_PVT.CSC_PARTY_ID_TBL_TYPE,
    X_PLAN_ID                    OUT NOCOPY  NUMBER,
    X_OBJECT_VERSION_NUMBER      OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2  );


   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  create_plan_header (overloaded procedure to take in individual parameters
   --                                  rather than a record type)
   --   Type    :  Public
   --   Pre-Req :  None
   --   Function:  Procedure to create a plan header. Insert records into CSC_PLAN_HEADERS_B
   --              and CSC_PLAN_HEADERS_TL
   --   Parameters:
   --   IN
   --       p_api_version_number      IN   NUMBER     Required
   --       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
   --       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
   --       p_ROW_ID                  IN   ROWID := FND_API.G_MISS_CHAR
   --       p_PLAN_ID                 IN   NUMBER := FND_API.G_MISS_NUM
   --       p_ORIGINAL_PLAN_ID        IN   NUMBER := FND_API.G_MISS_NUM
   --       p_PLAN_GROUP_CODE         IN   VARCHAR2(30) := FND_API.G_MISS_CHAR
   --       p_START_DATE_ACTIVE       IN   DATE := FND_API.G_MISS_DATE
   --       p_END_DATE_ACTIVE         IN   DATE := FND_API.G_MISS_DATE
   --       p_USE_FOR_CUST_ACCOUNT    IN   VARCHAR2(1) := FND_API.G_MISS_CHAR
   --       p_END_USER_TYPE           IN   VARCHAR2(30):= FND_API.G_MISS_CHAR
   --       p_CUSTOMIZED_PLAN         IN   VARCHAR2(1) := FND_API.G_MISS_CHAR
   --       p_PROFILE_CHECK_ID        IN   NUMBER := FND_API.G_MISS_NUM
   --       p_RELATIONAL_OPERATOR     IN   VARCHAR2(30) := FND_API.G_MISS_CHAR
   --       p_CRITERIA_VALUE_HIGH     IN   VARCHAR2(50) := FND_API.G_MISS_CHAR
   --       p_CRITERIA_VALUE_LOW      IN   VARCHAR2(50) := FND_API.G_MISS_CHAR
   --       p_CREATION_DATE           IN   DATE := FND_API.G_MISS_DATE
   --       p_LAST_UPDATE_DATE        IN   DATE := FND_API.G_MISS_DATE
   --       p_CREATED_BY              IN   NUMBER := FND_API.G_MISS_NUM
   --       p_LAST_UPDATED_BY         IN   NUMBER := FND_API.G_MISS_NUM
   --       p_LAST_UPDATE_LOGIN       IN   NUMBER := FND_API.G_MISS_NUM
   --       p_ATTRIBUTE1              IN   VARCHAR2(150) := FND_API.G_MISS_CHAR
   --       p_ATTRIBUTE2              IN   VARCHAR2(150) := FND_API.G_MISS_CHAR
   --       p_ATTRIBUTE3              IN   VARCHAR2(150) := FND_API.G_MISS_CHAR
   --       p_ATTRIBUTE4              IN   VARCHAR2(150) := FND_API.G_MISS_CHAR
   --       p_ATTRIBUTE5              IN   VARCHAR2(150) := FND_API.G_MISS_CHAR
   --       p_ATTRIBUTE6              IN   VARCHAR2(150) := FND_API.G_MISS_CHAR
   --       p_ATTRIBUTE7              IN   VARCHAR2(150) := FND_API.G_MISS_CHAR
   --       p_ATTRIBUTE8              IN   VARCHAR2(150) := FND_API.G_MISS_CHAR
   --       p_ATTRIBUTE9              IN   VARCHAR2(150) := FND_API.G_MISS_CHAR
   --       p_ATTRIBUTE10             IN   VARCHAR2(150) := FND_API.G_MISS_CHAR
   --       p_ATTRIBUTE11             IN   VARCHAR2(150) := FND_API.G_MISS_CHAR
   --       p_ATTRIBUTE12             IN   VARCHAR2(150) := FND_API.G_MISS_CHAR
   --       p_ATTRIBUTE13             IN   VARCHAR2(150) := FND_API.G_MISS_CHAR
   --       p_ATTRIBUTE14             IN   VARCHAR2(150) := FND_API.G_MISS_CHAR
   --       p_ATTRIBUTE15             IN   VARCHAR2(150) := FND_API.G_MISS_CHAR
   --       p_ATTRIBUTE_CATEGORY      IN   VARCHAR2(90)  := FND_API.G_MISS_CHAR
   --       p_OBJECT_VERSION_NUMBER   IN   NUMBER := FND_API.G_MISS_NUM
   --       P_DESCRIPTION             IN   VARCHAR2   Required -- Plan description for translation
   --                                                          -- table
   --       P_NAME                    IN   VARCHAR2   Required -- Plan name for translation table.
   --       P_PARTY_ID_TBL            IN   CSC_CUST_PLANS_PVT.CSC_PARTY_ID_TBL_TYPE
   --									    Optional  Default =
   --                                                   CSC_CUST_PLANS_PVT.G_MISS_PARTY_ID_TBL
   --                          -- If a plan is being customized, then this table of party_ids
   --                          -- store the ids of the parties for which the plan is being
   --                          -- customized
   --                          -- If a 'CUSTOMIZED ACCOUNT LEVEL' plan ie. CUSTOMIZED_PLAN='Y'
   --                          -- and 'USE_FOR_CUST_ACCOUNT='Y', is being created, then the
   --                          -- ACCOUNT_ID and ACCOUNT_ORG should be specified.
   --
   --   OUT  NOCOPY:
   --       x_plan_id                 OUT NOCOPY  NUMBER
   --       x_object_version_number   OUT NOCOPY  NUMBER
   --       x_return_status           OUT NOCOPY  VARCHAR2
   --       x_msg_count               OUT NOCOPY  NUMBER
   --       x_msg_data                OUT NOCOPY  VARCHAR2
   --   Version : Current version 1.0
   --
   --   End of Comments

PROCEDURE create_plan_header (
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := NULL,
    P_Commit                     IN   VARCHAR2     := NULL,
    P_ROW_ID                     IN   ROWID := NULL,
    P_PLAN_ID                    IN   NUMBER := NULL,
    P_ORIGINAL_PLAN_ID           IN   NUMBER := NULL,
    P_PLAN_GROUP_CODE            IN   VARCHAR2 := NULL,
    P_START_DATE_ACTIVE          IN   DATE := NULL,
    P_END_DATE_ACTIVE            IN   DATE := NULL,
    P_USE_FOR_CUST_ACCOUNT       IN   VARCHAR2 := NULL,
    P_END_USER_TYPE              IN   VARCHAR2 := NULL,
    P_CUSTOMIZED_PLAN            IN   VARCHAR2 := NULL,
    P_PROFILE_CHECK_ID           IN   NUMBER := NULL,
    P_RELATIONAL_OPERATOR        IN   VARCHAR2 := NULL,
    P_CRITERIA_VALUE_HIGH        IN   VARCHAR2 := NULL,
    P_CRITERIA_VALUE_LOW         IN   VARCHAR2 := NULL,
    P_CREATION_DATE              IN   DATE := NULL,
    P_LAST_UPDATE_DATE           IN   DATE := NULL,
    P_CREATED_BY                 IN   NUMBER := NULL,
    P_LAST_UPDATED_BY            IN   NUMBER := NULL,
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
    P_ATTRIBUTE_CATEGORY         IN   VARCHAR2  := NULL,
    P_OBJECT_VERSION_NUMBER      IN   NUMBER := NULL,
    P_DESCRIPTION                IN   VARCHAR2,
    P_NAME                       IN   VARCHAR2,
    P_PARTY_ID_TBL               IN   CSC_CUST_PLANS_PVT.CSC_PARTY_ID_TBL_TYPE,
    X_PLAN_ID                    OUT NOCOPY  NUMBER,
    X_OBJECT_VERSION_NUMBER      OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2  );


   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  update_plan_header
   --   Type    :  Public
   --   Pre-Req :  Plan header should be defined. ie. record should exist in CSC_PLAN_HEADERS_B.
   --   Function:  Procedure to update a plan header. Updates record into CSC_PLAN_HEADERS_B and
   --              CSC_PLAN_HEADERS_TL.
   --   Parameters:
   --   IN
   --       p_api_version_number      IN   NUMBER     Required
   --       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
   --       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
   --       P_CSC_PLAN_HEADERS_B_REC  IN   CSC_PLAN_HEADERS_B_REC_TYPE  Required
   --       P_DESCRIPTION             IN   VARCHAR2   Required
   --       P_NAME                    IN   VARCHAR2   Required
   --       P_PARTY_ID_TBL            IN   CSC_CUST_PLANS_PVT.CSC_PARTY_ID_TBL_TYPE
   --									    Optional  Default =
   --                                                CSC_CUST_PLANS_PVT.G_MISS_PARTY_ID_TBL
   --                          -- If a plan is being customized, then this table of party_ids
   --                          -- store the ids of the parties for which the plan is being
   --                          -- customized
   --                          -- If a 'CUSTOMIZED ACCOUNT LEVEL' plan ie. CUSTOMIZED_PLAN='Y'
   --                          -- and 'USE_FOR_CUST_ACCOUNT='Y', is being created, then the
   --                          -- ACCOUNT_ID and ACCOUNT_ORG should be specified.
   --
   --   OUT  NOCOPY:
   --       x_object_version_number   OUT NOCOPY  NUMBER
   --       x_return_status           OUT NOCOPY  VARCHAR2
   --       x_msg_count               OUT NOCOPY  NUMBER
   --       x_msg_data                OUT NOCOPY  VARCHAR2
   --   Version : Current version 1.0
   --
   --   End of Comments

PROCEDURE update_plan_header(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     :=  NULL,
    P_Commit                     IN   VARCHAR2     := NULL,
    P_CSC_PLAN_HEADERS_B_REC     IN   CSC_PLAN_HEADERS_B_REC_TYPE := NULL,
    P_DESCRIPTION                IN   VARCHAR2 :=  NULL,
    P_NAME                       IN   VARCHAR2 := NULL,
    P_PARTY_ID_TBL               IN   CSC_CUST_PLANS_PVT.CSC_PARTY_ID_TBL_TYPE,
    X_OBJECT_VERSION_NUMBER      OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  update_plan_header (overloaded procedure to take in individual parameters
   --                                  rather than a record type)
   --   Type    :  Public
   --   Pre-Req :  Plan header should be defined. ie. record should exist in CSC_PLAN_HEADERS_B.
   --   Function:  Procedure to update a plan header. Updates record into CSC_PLAN_HEADERS_B and
   --              CSC_PLAN_HEADERS_TL.
   --   Parameters:
   --   IN
   --       p_api_version_number      IN   NUMBER     Required
   --       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
   --       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
   --       p_ROW_ID                  IN   ROWID := FND_API.G_MISS_CHAR
   --       p_PLAN_ID                 IN   NUMBER := FND_API.G_MISS_NUM
   --       p_ORIGINAL_PLAN_ID        IN   NUMBER := FND_API.G_MISS_NUM
   --       p_PLAN_GROUP_CODE         IN   VARCHAR2(30) := FND_API.G_MISS_CHAR
   --       p_START_DATE_ACTIVE       IN   DATE := FND_API.G_MISS_DATE
   --       p_END_DATE_ACTIVE         IN   DATE := FND_API.G_MISS_DATE
   --       p_USE_FOR_CUST_ACCOUNT    IN   VARCHAR2(1) := FND_API.G_MISS_CHAR
   --       p_END_USER_TYPE           IN   VARCHAR2(30):= FND_API.G_MISS_CHAR
   --       p_CUSTOMIZED_PLAN         IN   VARCHAR2(1) := FND_API.G_MISS_CHAR
   --       p_PROFILE_CHECK_ID        IN   NUMBER := FND_API.G_MISS_NUM
   --       p_RELATIONAL_OPERATOR     IN   VARCHAR2(30) := FND_API.G_MISS_CHAR
   --       p_CRITERIA_VALUE_HIGH     IN   VARCHAR2(50) := FND_API.G_MISS_CHAR
   --       p_CRITERIA_VALUE_LOW      IN   VARCHAR2(50) := FND_API.G_MISS_CHAR
   --       p_CREATION_DATE           IN   DATE := FND_API.G_MISS_DATE
   --       p_LAST_UPDATE_DATE        IN   DATE := FND_API.G_MISS_DATE
   --       p_CREATED_BY              IN   NUMBER := FND_API.G_MISS_NUM
   --       p_LAST_UPDATED_BY         IN   NUMBER := FND_API.G_MISS_NUM
   --       p_LAST_UPDATE_LOGIN       IN   NUMBER := FND_API.G_MISS_NUM
   --       p_ATTRIBUTE1              IN   VARCHAR2(150) := FND_API.G_MISS_CHAR
   --       p_ATTRIBUTE2              IN   VARCHAR2(150) := FND_API.G_MISS_CHAR
   --       p_ATTRIBUTE3              IN   VARCHAR2(150) := FND_API.G_MISS_CHAR
   --       p_ATTRIBUTE4              IN   VARCHAR2(150) := FND_API.G_MISS_CHAR
   --       p_ATTRIBUTE5              IN   VARCHAR2(150) := FND_API.G_MISS_CHAR
   --       p_ATTRIBUTE6              IN   VARCHAR2(150) := FND_API.G_MISS_CHAR
   --       p_ATTRIBUTE7              IN   VARCHAR2(150) := FND_API.G_MISS_CHAR
   --       p_ATTRIBUTE8              IN   VARCHAR2(150) := FND_API.G_MISS_CHAR
   --       p_ATTRIBUTE9              IN   VARCHAR2(150) := FND_API.G_MISS_CHAR
   --       p_ATTRIBUTE10             IN   VARCHAR2(150) := FND_API.G_MISS_CHAR
   --       p_ATTRIBUTE11             IN   VARCHAR2(150) := FND_API.G_MISS_CHAR
   --       p_ATTRIBUTE12             IN   VARCHAR2(150) := FND_API.G_MISS_CHAR
   --       p_ATTRIBUTE13             IN   VARCHAR2(150) := FND_API.G_MISS_CHAR
   --       p_ATTRIBUTE14             IN   VARCHAR2(150) := FND_API.G_MISS_CHAR
   --       p_ATTRIBUTE15             IN   VARCHAR2(150) := FND_API.G_MISS_CHAR
   --       p_ATTRIBUTE_CATEGORY      IN   VARCHAR2(90)  := FND_API.G_MISS_CHAR
   --       p_OBJECT_VERSION_NUMBER   IN   NUMBER := FND_API.G_MISS_NUM
   --       P_DESCRIPTION             IN   VARCHAR2   Required
   --       P_NAME                    IN   VARCHAR2   Required
   --       P_PARTY_ID_TBL            IN   CSC_CUST_PLANS_PVT.CSC_PARTY_ID_TBL_TYPE
   --									    Optional  Default =
   --                                               CSC_CUST_PLANS_PVT.G_MISS_PARTY_ID_TBL
   --                          -- If a plan is being customized, then this table of party_ids
   --                          -- store the ids of the parties for which the plan is being
   --                          -- customized
   --                          -- If a 'CUSTOMIZED ACCOUNT LEVEL' plan ie. CUSTOMIZED_PLAN='Y'
   --                          -- and 'USE_FOR_CUST_ACCOUNT='Y', is being created, then the
   --                          -- ACCOUNT_ID and ACCOUNT_ORG should be specified.
   --
   --   OUT  NOCOPY:
   --       x_object_version_number   OUT NOCOPY  NUMBER
   --       x_return_status           OUT NOCOPY  VARCHAR2
   --       x_msg_count               OUT NOCOPY  NUMBER
   --       x_msg_data                OUT NOCOPY  VARCHAR2
   --   Version : Current version 1.0
   --
   --   End of Comments


PROCEDURE update_plan_header(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := NULL,
    P_Commit                     IN   VARCHAR2     := NULL,
    P_ROW_ID                     IN   ROWID := NULL,
    P_PLAN_ID                    IN   NUMBER := NULL,
    P_ORIGINAL_PLAN_ID           IN   NUMBER := NULL,
    P_PLAN_GROUP_CODE            IN   VARCHAR2 := NULL,
    P_START_DATE_ACTIVE          IN   DATE := NULL,
    P_END_DATE_ACTIVE            IN   DATE := NULL,
    P_USE_FOR_CUST_ACCOUNT       IN   VARCHAR2 := NULL,
    P_END_USER_TYPE              IN   VARCHAR2 := NULL,
    P_CUSTOMIZED_PLAN            IN   VARCHAR2 := NULL,
    P_PROFILE_CHECK_ID           IN   NUMBER := NULL,
    P_RELATIONAL_OPERATOR        IN   VARCHAR2 := NULL,
    P_CRITERIA_VALUE_HIGH        IN   VARCHAR2 := NULL,
    P_CRITERIA_VALUE_LOW         IN   VARCHAR2 := NULL,
    P_CREATION_DATE              IN   DATE := NULL,
    P_LAST_UPDATE_DATE           IN   DATE := NULL,
    P_CREATED_BY                 IN   NUMBER := NULL,
    P_LAST_UPDATED_BY            IN   NUMBER := NULL,
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
    P_ATTRIBUTE_CATEGORY         IN   VARCHAR2  := NULL,
    P_OBJECT_VERSION_NUMBER      IN   NUMBER := NULL,
    P_DESCRIPTION                IN   VARCHAR2 := NULL,
    P_NAME                       IN   VARCHAR2 := NULL,
    P_PARTY_ID_TBL               IN   CSC_CUST_PLANS_PVT.CSC_PARTY_ID_TBL_TYPE,
    X_OBJECT_VERSION_NUMBER      OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );


   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  Disable_plan
   --   Type    :  Public
   --   Pre-Req :  Plan header should be defined and enabled. ie. record should exist in
   --              CSC_PLAN_HEADERS_B with a end_date_active > sysdate.
   --   Function:  Procedure to disable a plan. Modifies end_date_active in the CSC_PLAN_HEADERS_B
   --              table to >= sysdate.
   --   Parameters:
   --   IN
   --       p_api_version_number      IN   NUMBER     Required
   --       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
   --       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
   --       P_plan_id                 IN   NUMBER     Required
   --
   --   OUT  NOCOPY:
   --       x_return_status           OUT NOCOPY  VARCHAR2
   --       x_msg_count               OUT NOCOPY  NUMBER
   --       x_msg_data                OUT NOCOPY  VARCHAR2
   --   Version : Current version 1.0
   --
   --   End of Comments

PROCEDURE Disable_plan(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := NULL,
    P_Commit                     IN   VARCHAR2     := NULL,
    P_Plan_id                    IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

End CSC_RELATIONSHIP_PLANS_PUB;

 

/
