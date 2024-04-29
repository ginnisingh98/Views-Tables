--------------------------------------------------------
--  DDL for Package CSC_RELATIONSHIP_PLANS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSC_RELATIONSHIP_PLANS_PVT" AUTHID CURRENT_USER as
/* $Header: cscvrlps.pls 120.0 2005/05/30 15:53:06 appldev noship $ */
-- Start of Comments
-- Package name     : CSC_RELATIONSHIP_PLANS_PVT
-- Purpose          : This package contains all procedures and functions that are required
--                    to create and modify plan headers and disable plans.
-- History          :
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
--                             - Added a new procedure VALIDATE_END_USER_TYPE
--                             Added the dbdrv command.
-- 05-23-2002    dejoseph      Added checkfile syntax.
-- 11-13-2002	 bhroy		NOCOPY changes made
-- 11-27-2002	 bhroy		All the default values have been removed
--
-- End of Comments

-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;

TYPE CSC_PLAN_HEADERS_B_REC_TYPE IS RECORD
(
       ROW_ID                          ROWID,
       PLAN_ID                         NUMBER,
       ORIGINAL_PLAN_ID                NUMBER,
       PLAN_GROUP_CODE                 VARCHAR2(30),
       START_DATE_ACTIVE               DATE,
       END_DATE_ACTIVE                 DATE,
       USE_FOR_CUST_ACCOUNT            VARCHAR2(1),
       END_USER_TYPE                   VARCHAR2(30),
       CUSTOMIZED_PLAN                 VARCHAR2(1),
       PROFILE_CHECK_ID                NUMBER,
       RELATIONAL_OPERATOR             VARCHAR2(30),
       CRITERIA_VALUE_HIGH             VARCHAR2(50),
       CRITERIA_VALUE_LOW              VARCHAR2(50),
       CREATION_DATE                   DATE,
       LAST_UPDATE_DATE                DATE,
       CREATED_BY                      NUMBER,
       LAST_UPDATED_BY                 NUMBER,
       LAST_UPDATE_LOGIN               NUMBER,
       ATTRIBUTE1                      VARCHAR2(150),
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
       OBJECT_VERSION_NUMBER           NUMBER );

G_MISS_CSC_PLAN_HEADERS_B_REC          CSC_PLAN_HEADERS_B_REC_TYPE;

/*
TYPE CSC_PARTY_ID_REC_TYPE IS RECORD (
	  PARTY_ID                    NUMBER := FND_API.G_MISS_NUM,
       CUST_ACCOUNT_ID             NUMBER := FND_API.G_MISS_NUM,
       CUST_ACCOUNT_ORG            NUMBER := FND_API.G_MISS_NUM );

TYPE CSC_PARTY_ID_TBL_TYPE         IS TABLE OF CSC_PARTY_ID_REC_TYPE
							INDEX BY BINARY_INTEGER;
G_MISS_PARTY_ID_TBL                CSC_PARTY_ID_TBL_TYPE;
*/

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  create_plan_header
   --   Type    :  Private
   --   Pre-Req :  None.
   --   Parameters:
   --   IN
   --       p_api_version_number      IN   NUMBER     Required
   --       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
   --       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
   --       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
   --       P_CSC_PLAN_HEADERS_B_REC  IN   CSC_PLAN_HEADERS_B_REC_TYPE  Required
   --       P_DESCRIPTION             IN   VARCHAR2   Required -- Plan description for translation
   --                                                          -- table
   --       P_NAME                    IN   VARCHAR2   Required -- Plan name for translation table.
   --       P_PARTY_ID_TBL            IN   CSC_CUST_PLANS_PVT.CSC_PARTY_ID_TBL_TYPE
   --									    Optional  Default =
   --                                                    CSC_CUST_PLANS_PVT.G_MISS_PARTY_ID_TBL
   --                          -- If a plan is being customized, then this table of party_ids
   --                          -- store the ids of the parties for which the plan is being
   --                          -- customized
   --                          -- If a 'CUSTOMIZED ACCOUNT LEVEL' plan ie. CUSTOMIZED_PLAN='Y'
   --                          -- and 'USE_FOR_CUST_ACCOUNT='Y', is being created, then the
   --                          -- ACCOUNT_ID and ACCOUNT_ORG columns in the table type
   --                          -- should be specified.
   --
   --   OUT :
   --       x_plan_id                 OUT NOCOPY  NUMBER
   --       x_object_version_number   OUT NOCOPY  NUMBER
   --       x_return_status           OUT NOCOPY  VARCHAR2
   --       x_msg_count               OUT NOCOPY  NUMBER
   --       x_msg_data                OUT NOCOPY  VARCHAR2
   --   Version : Current version 1.0
   --
   --   End of Comments
   --
PROCEDURE create_plan_header(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    p_validation_level           IN   NUMBER,
    P_CSC_PLAN_HEADERS_B_REC     IN   CSC_PLAN_HEADERS_B_REC_TYPE,
    P_DESCRIPTION                IN   VARCHAR2,
    P_NAME                       IN   VARCHAR2,
    P_PARTY_ID_TBL               IN   CSC_CUST_PLANS_PVT.CSC_PARTY_ID_TBL_TYPE,
    X_PLAN_ID                    OUT NOCOPY  NUMBER,
    X_Object_Version_Number      OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2 );


   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  create_plan_header  (overloaded procedure to take in individual parameters
   --                                   rather than a record type)
   --   Type    :  Private
   --   Pre-Req :  None.
   --   Parameters:
   --   IN
   --       p_api_version_number      IN   NUMBER     Required
   --       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
   --       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
   --       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
   --       p_ROW_ID                  IN   ROWID := FND_API.G_MISS_CHAR
   --       p_PLAN_ID                 IN   NUMBER := FND_API.G_MISS_NUM
   --       p_ORIGINAL_PLAN_ID        IN   NUMBER := FND_API.G_MISS_NUM
   --       p_PLAN_GROUP_CODE         IN   VARCHAR2(30) := FND_API.G_MISS_CHAR
   --       p_START_DATE_ACTIVE       IN   DATE := FND_API.G_MISS_DATE
   --       p_END_DATE_ACTIVE         IN   DATE := FND_API.G_MISS_DATE
   --       p_USE_FOR_CUST_ACCOUNT    IN   VARCHAR2(1) := FND_API.G_MISS_CHAR
   --       p_END_USER_TYPE           IN   VARCHAR2(30):= CSC_CORE_UTILS_PVT.G_MISS_CHAR
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
   --                                                    CSC_CUST_PLANS_PVT.G_MISS_PARTY_ID_TBL
   --                          -- If a plan is being customized, then this table of party_ids
   --                          -- store the ids of the parties for which the plan is being
   --                          -- customized
   --                          -- If a 'CUSTOMIZED ACCOUNT LEVEL' plan ie. CUSTOMIZED_PLAN='Y'
   --                          -- and 'USE_FOR_CUST_ACCOUNT='Y', is being created, then the
   --                          -- ACCOUNT_ID and ACCOUNT_ORG columns in the table type should
   --                          -- be specified.
   --
   --   OUT NOCOPY:
   --       x_plan_id                 OUT NOCOPY  NUMBER
   --       x_object_version_number   OUT NOCOPY  NUMBER
   --       x_return_status           OUT NOCOPY  VARCHAR2
   --       x_msg_count               OUT NOCOPY  NUMBER
   --       x_msg_data                OUT NOCOPY  VARCHAR2
   --   Version : Current version 1.0
   --
   --   End of Comments
   --
PROCEDURE create_plan_header(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    p_validation_level           IN   NUMBER,
    P_ROW_ID                     IN   ROWID,
    P_PLAN_ID                    IN   NUMBER,
    P_ORIGINAL_PLAN_ID           IN   NUMBER,
    P_PLAN_GROUP_CODE            IN   VARCHAR2,
    P_START_DATE_ACTIVE          IN   DATE,
    P_END_DATE_ACTIVE            IN   DATE,
    P_USE_FOR_CUST_ACCOUNT       IN   VARCHAR2,
    P_END_USER_TYPE              IN   VARCHAR2,
    P_CUSTOMIZED_PLAN            IN   VARCHAR2,
    P_PROFILE_CHECK_ID           IN   NUMBER,
    P_RELATIONAL_OPERATOR        IN   VARCHAR2,
    P_CRITERIA_VALUE_HIGH        IN   VARCHAR2,
    P_CRITERIA_VALUE_LOW         IN   VARCHAR2,
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
    P_DESCRIPTION                IN   VARCHAR2,
    P_NAME                       IN   VARCHAR2,
    P_PARTY_ID_TBL               IN   CSC_CUST_PLANS_PVT.CSC_PARTY_ID_TBL_TYPE,
    X_PLAN_ID                    OUT NOCOPY  NUMBER,
    X_Object_Version_Number      OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2);

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  update_plan_header
   --   Type    :  Private
   --   Pre-Req :  None
   --   Function:  Procedure to update a plan header. Updates record into CSC_PLAN_HEADERS_B
   --   Parameters:
   --   IN
   --       p_api_version_number      IN   NUMBER     Required
   --       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
   --       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
   --       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
   --       P_CSC_PLAN_HEADERS_B_REC  IN   CSC_PLAN_HEADERS_B_REC_TYPE  Required
   --       P_DESCRIPTION             IN   VARCHAR2   Required
   --       P_NAME                    IN   VARCHAR2   Required
   --       P_PARTY_ID_TBL            IN   CSC_CUST_PLANS_PVT.CSC_PARTY_ID_TBL_TYPE
   --									    Optional  Default =
   --                                                    CSC_CUST_PLANS_PVT.G_MISS_PARTY_ID_TBL
   --                          -- If a plan is being customized, then this table of party_ids
   --                          -- store the ids of the parties for which the plan is being
   --                          -- customized
   --                          -- If a 'CUSTOMIZED ACCOUNT LEVEL' plan ie. CUSTOMIZED_PLAN='Y'
   --                          -- and 'USE_FOR_CUST_ACCOUNT='Y', is being created, then the
   --                          -- ACCOUNT_ID and ACCOUNT_ORG columns in the table type should
   --                          -- be specified.
   --
   --   OUT NOCOPY:
   --       x_object_version_number   OUT NOCOPY  NUMBER
   --       x_return_status           OUT NOCOPY  VARCHAR2
   --       x_msg_count               OUT NOCOPY  NUMBER
   --       x_msg_data                OUT NOCOPY  VARCHAR2
   --   Version : Current version 1.0
   --
   --   End of Comments
   --

PROCEDURE update_plan_header(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    p_validation_level           IN   NUMBER,
    P_CSC_PLAN_HEADERS_B_REC     IN   CSC_PLAN_HEADERS_B_REC_TYPE,
    P_DESCRIPTION                IN   VARCHAR2,
    P_NAME                       IN   VARCHAR2,
    P_PARTY_ID_TBL               IN   CSC_CUST_PLANS_PVT.CSC_PARTY_ID_TBL_TYPE,
    X_Object_Version_Number      OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );


   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  update_plan_header (overloaded procedure to take in individual parameters
   --                                    rather than a record type)
   --   Type    :  Private
   --   Pre-Req :  None
   --   Function:  Procedure to update a plan header. Updates record into CSC_PLAN_HEADERS_B
   --   Parameters:
   --   IN
   --       p_api_version_number      IN   NUMBER     Required
   --       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
   --       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
   --       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
   --       p_ROW_ID                  IN   ROWID := FND_API.G_MISS_CHAR
   --       p_PLAN_ID                 IN   NUMBER := FND_API.G_MISS_NUM
   --       p_ORIGINAL_PLAN_ID        IN   NUMBER := FND_API.G_MISS_NUM
   --       p_PLAN_GROUP_CODE         IN   VARCHAR2(30) := FND_API.G_MISS_CHAR
   --       p_START_DATE_ACTIVE       IN   DATE := FND_API.G_MISS_DATE
   --       p_END_DATE_ACTIVE         IN   DATE := FND_API.G_MISS_DATE
   --       p_USE_FOR_CUST_ACCOUNT    IN   VARCHAR2(1) := FND_API.G_MISS_CHAR
   --       p_END_USER_TYPE           IN   VARCHAR2(30):= CSC_CORE_UTILS_PVT.G_MISS_CHAR
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
   --                                                    CSC_CUST_PLANS_PVT.G_MISS_PARTY_ID_TBL
   --                          -- If a plan is being customized, then this table of party_ids
   --                          -- store the ids of the parties for which the plan is being
   --                          -- customized
   --                          -- If a 'CUSTOMIZED ACCOUNT LEVEL' plan ie. CUSTOMIZED_PLAN='Y'
   --                          -- and 'USE_FOR_CUST_ACCOUNT='Y', is being created, then the
   --                          -- ACCOUNT_ID and ACCOUNT_ORG columns in the table type should
   --                          -- be specified.
   --
   --   OUT NOCOPY:
   --       x_object_version_number   OUT NOCOPY  NUMBER
   --       x_return_status           OUT NOCOPY  VARCHAR2
   --       x_msg_count               OUT NOCOPY  NUMBER
   --       x_msg_data                OUT NOCOPY  VARCHAR2
   --   Version : Current version 1.0
   --
   --   End of Comments
   --

PROCEDURE update_plan_header(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    p_validation_level           IN   NUMBER,
    P_ROW_ID                     IN   ROWID,
    P_PLAN_ID                    IN   NUMBER,
    P_ORIGINAL_PLAN_ID           IN   NUMBER,
    P_PLAN_GROUP_CODE            IN   VARCHAR2,
    P_START_DATE_ACTIVE          IN   DATE,
    P_END_DATE_ACTIVE            IN   DATE,
    P_USE_FOR_CUST_ACCOUNT       IN   VARCHAR2,
    P_END_USER_TYPE              IN   VARCHAR2,
    P_CUSTOMIZED_PLAN            IN   VARCHAR2,
    P_PROFILE_CHECK_ID           IN   NUMBER,
    P_RELATIONAL_OPERATOR        IN   VARCHAR2,
    P_CRITERIA_VALUE_HIGH        IN   VARCHAR2,
    P_CRITERIA_VALUE_LOW         IN   VARCHAR2,
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
    P_DESCRIPTION                IN   VARCHAR2,
    P_NAME                       IN   VARCHAR2,
    P_PARTY_ID_TBL               IN   CSC_CUST_PLANS_PVT.CSC_PARTY_ID_TBL_TYPE,
    X_Object_Version_Number      OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );


   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  Disable_plan
   --   Type    :  Private
   --   Pre-Req :  Existing plan that is enabled.
   --   Function:  Disables an existing enabled plan. Modifies the end_date_active in the
   --              CSC_PLAN_HEADERS_B table to sysdate + 1.
   --   Parameters:
   --   IN
   --       p_api_version_number      IN   NUMBER     Required
   --       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
   --       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
   --       p_plan_id                 IN   NUMBER
   --
   --   OUT :
   --       x_return_status           OUT NOCOPY  VARCHAR2
   --       x_msg_count               OUT NOCOPY  NUMBER
   --       x_msg_data                OUT NOCOPY  VARCHAR2
   --   Version : Current version 1.0
   --
   --   End of Comments
   --

PROCEDURE Disable_plan(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_plan_id                    IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

   -- Item level validation procedures.
   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  validate_plan_id
   --   Type    :  Private
   --   Pre-Req :  None.
   --   Function:  Performs validation on the value of plan_id
   --   Parameters:
   --   IN
   -- p_validation_mode is a constant defined in CSC_CORE_UTILS_PVT package
   -- For create: G_CREATE, for update: G_UPDATE
   --       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
   --       p_validation_mode         IN   VARCHAR2
   --       p_plan_id                 IN   NUMBER
   --
   --   OUT :
   --       x_return_status           OUT NOCOPY  VARCHAR2
   --       x_msg_count               OUT NOCOPY  NUMBER
   --       x_msg_data                OUT NOCOPY  VARCHAR2
   --   Version : Current version 1.0
   --
   --   End of Comments
   --

PROCEDURE Validate_PLAN_ID (
    P_Init_Msg_List              IN   VARCHAR2,
    P_Validation_mode            IN   VARCHAR2,
    P_PLAN_ID                    IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  validate_name
   --   Type    :  Private
   --   Pre-Req :  None.
   --   Function:  Performs validation on the value of plan_name
   --   Parameters:
   --   IN
   -- p_validation_mode is a constant defined in CSC_CORE_UTILS_PVT package
   -- For create: G_CREATE, for update: G_UPDATE
   --       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
   --       p_validation_mode         IN   VARCHAR2
   --       p_plan_name               IN   NUMBER
   --
   --   OUT :
   --       x_return_status           OUT NOCOPY  VARCHAR2
   --       x_msg_count               OUT NOCOPY  NUMBER
   --       x_msg_data                OUT NOCOPY  VARCHAR2
   --   Version : Current version 1.0
   --
   --   End of Comments
   --
PROCEDURE Validate_NAME (
    P_Init_Msg_List              IN   VARCHAR2,
    P_Validation_mode            IN   VARCHAR2,
    P_PLAN_ID                    IN   NUMBER,
    P_NAME                       IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  validate_original_plan_id
   --   Type    :  Private
   --   Pre-Req :  None.
   --   Function:  Performs validation on the value of plan_id
   --   Parameters:
   --   IN
   -- p_validation_mode is a constant defined in CSC_CORE_UTILS_PVT package
   -- For create: G_CREATE, for update: G_UPDATE
   --       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
   --       p_validation_mode         IN   VARCHAR2
   --       p_original_plan_id        IN   NUMBER
   --       p_customized_plan         IN   VARCHAR2   Optional  Default = 'N'
   --
   --   OUT :
   --       x_return_status           OUT NOCOPY  VARCHAR2
   --       x_msg_count               OUT NOCOPY  NUMBER
   --       x_msg_data                OUT NOCOPY  VARCHAR2
   --   Version : Current version 1.0
   --
   --   End of Comments
   --
PROCEDURE Validate_ORIGINAL_PLAN_ID (
    P_Init_Msg_List              IN   VARCHAR2,
    P_Validation_mode            IN   VARCHAR2,
    P_PLAN_ID                    IN   NUMBER,
    P_ORIGINAL_PLAN_ID           IN   NUMBER,
    P_CUSTOMIZED_PLAN            IN   VARCHAR2     := 'N',
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  validate_plan_group_code
   --   Type    :  Private
   --   Pre-Req :  None.
   --   Function:  Performs validation on the value of plan_group_code
   --   Parameters:
   --   IN
   -- p_validation_mode is a constant defined in CSC_CORE_UTILS_PVT package
   -- For create: G_CREATE, for update: G_UPDATE
   --       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
   --       p_validation_mode         IN   VARCHAR2
   --       p_plan_group_code         IN   NUMBER
   --
   --   OUT :
   --       x_return_status           OUT NOCOPY  VARCHAR2
   --       x_msg_count               OUT NOCOPY  NUMBER
   --       x_msg_data                OUT NOCOPY  VARCHAR2
   --   Version : Current version 1.0
   --
   --   End of Comments
   --
PROCEDURE Validate_Plan_Group_Code (
    P_Init_Msg_List              IN   VARCHAR2,
    P_Validation_mode            IN   VARCHAR2,
    P_PLAN_GROUP_CODE            IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  validate_use_for_cust_account
   --   Type    :  Private
   --   Pre-Req :  None.
   --   Function:  Performs validation on the value of use_for_cust_account.
   --   Parameters:
   --   IN
   -- p_validation_mode is a constant defined in CSC_CORE_UTILS_PVT package
   -- For create: G_CREATE, for update: G_UPDATE
   --       p_init_msg_list            IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
   --       p_validation_mode          IN   VARCHAR2
   --       p_plan_id                  IN   NUMBER
   --       p_use_for_cust_account     IN   NUMBER
   --       p_old_use_for_cust_account IN   VARCHAR2   Optional  Default = FND_API.G_MISS_CHAR
   --
   --   OUT :
   --       x_return_status            OUT NOCOPY  VARCHAR2
   --       x_msg_count                OUT NOCOPY  NUMBER
   --       x_msg_data                 OUT NOCOPY  VARCHAR2
   --   Version : Current version 1.0
   --
   --   End of Comments
   --
PROCEDURE Validate_USE_FOR_CUST_ACCOUNT (
    P_Init_Msg_List              IN   VARCHAR2,
    P_Validation_mode            IN   VARCHAR2,
    P_PLAN_ID                    IN   NUMBER,
    P_USE_FOR_CUST_ACCOUNT       IN   VARCHAR2,
    P_OLD_USE_FOR_CUST_ACCOUNT   IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  validate_end_user_type
   --   Type    :  Private
   --   Pre-Req :  None.
   --   Function:  Performs validation on the value of end_user_type. This column gets its
   --              value from a lookup. LOOKUP_TYPE = CSC_END_USER_TYPE and the valid
   --              LOOKUP_CODES are 'CUST' and 'AGENT'. This is a NULLABLE column.
   --   Parameters:
   --   IN
   -- p_validation_mode is a constant defined in CSC_CORE_UTILS_PVT package
   -- For create: G_CREATE, for update: G_UPDATE
   --       p_init_msg_list            IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
   --       p_validation_mode          IN   VARCHAR2
   --       p_end_user_type            IN   VARCHAR2
   --
   --   OUT :
   --       x_return_status            OUT NOCOPY  VARCHAR2
   --       x_msg_count                OUT NOCOPY  NUMBER
   --       x_msg_data                 OUT NOCOPY  VARCHAR2
   --   Version : Current version 1.0
   --
   --   End of Comments
   --
PROCEDURE Validate_END_USER_TYPE (
    P_Init_Msg_List              IN   VARCHAR2,
    P_Validation_mode            IN   VARCHAR2,
    P_END_USER_TYPE              IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  validate_customized_plan
   --   Type    :  Private
   --   Pre-Req :  None.
   --   Function:  Performs validation on the value of customized_plan
   --   Parameters:
   --   IN
   -- p_validation_mode is a constant defined in CSC_CORE_UTILS_PVT package
   -- For create: G_CREATE, for update: G_UPDATE
   --       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
   --       p_validation_mode         IN   VARCHAR2
   --       p_customized_plan         IN   NUMBER
   --
   --   OUT :
   --       x_return_status           OUT NOCOPY  VARCHAR2
   --       x_msg_count               OUT NOCOPY  NUMBER
   --       x_msg_data                OUT NOCOPY  VARCHAR2
   --   Version : Current version 1.0
   --
   --   End of Comments
   --
PROCEDURE Validate_CUSTOMIZED_PLAN (
    P_Init_Msg_List              IN   VARCHAR2,
    P_Validation_mode            IN   VARCHAR2,
    P_CUSTOMIZED_PLAN            IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  validate_profile_check_id
   --   Type    :  Private
   --   Pre-Req :  None.
   --   Function:  Performs validation on the value of profile_check_id
   --   Parameters:
   --   IN
   -- p_validation_mode is a constant defined in CSC_CORE_UTILS_PVT package
   -- For create: G_CREATE, for update: G_UPDATE
   --       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
   --       p_validation_mode         IN   VARCHAR2
   --       p_plan_id                 IN   NUMBER
   --       p_profile_check_id        IN   NUMBER
   --       p_old_profile_check_id    IN   NUMBER     Optional  Default = FND_API.G_MISS_NUM
   --
   --   OUT :
   --       x_return_status           OUT NOCOPY  VARCHAR2
   --       x_msg_count               OUT NOCOPY  NUMBER
   --       x_msg_data                OUT NOCOPY  VARCHAR2
   --   Version : Current version 1.0
   --
   --   End of Comments
   --
PROCEDURE Validate_PROFILE_CHECK_ID (
    P_Init_Msg_List              IN   VARCHAR2,
    P_Validation_mode            IN   VARCHAR2,
    P_PLAN_ID                    IN   NUMBER,
    P_PROFILE_CHECK_ID           IN   NUMBER,
    P_OLD_PROFILE_CHECK_ID       IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  validate_criteria_value_low
   --   Type    :  Private
   --   Pre-Req :  None.
   --   Function:  Performs validation on the value of criteria_value_low
   --   Parameters:
   --   IN
   -- p_validation_mode is a constant defined in CSC_CORE_UTILS_PVT package
   -- For create: G_CREATE, for update: G_UPDATE
   --       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
   --       p_validation_mode         IN   VARCHAR2
   --       p_plan_id                 IN   NUMBER
   --       p_criteria_value_low      IN   NUMBER
   --       p_old_criteria_value_low  IN   NUMBER     Optional  Default = FND_API.G_MISS_NUM
   --
   --   OUT :
   --       x_return_status           OUT NOCOPY  VARCHAR2
   --       x_msg_count               OUT NOCOPY  NUMBER
   --       x_msg_data                OUT NOCOPY  VARCHAR2
   --   Version : Current version 1.0
   --
   --   End of Comments
   --
PROCEDURE Validate_CRITERIA_VALUE_LOW (
    P_Init_Msg_List              IN   VARCHAR2,
    P_Validation_mode            IN   VARCHAR2,
    P_PLAN_ID                    IN   NUMBER,
    P_CRITERIA_VALUE_LOW         IN   VARCHAR2,
    P_OLD_CRITERIA_VALUE_LOW     IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  validate_criteria_value_high
   --   Type    :  Private
   --   Pre-Req :  None.
   --   Function:  Performs validation on the value of criteria_value_high
   --   Parameters:
   --   IN
   -- p_validation_mode is a constant defined in CSC_CORE_UTILS_PVT package
   -- For create: G_CREATE, for update: G_UPDATE
   --       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
   --       p_validation_mode         IN   VARCHAR2
   --       p_plan_id                 IN   NUMBER
   --       p_criteria_value_high     IN   VARCHAR2
   --       p_old_criteria_value_high IN   VARCHAR2   Optional  Default = FND_API.G_MISS_CHAR
   --
   --   OUT :
   --       x_return_status           OUT NOCOPY  VARCHAR2
   --       x_msg_count               OUT NOCOPY  NUMBER
   --       x_msg_data                OUT NOCOPY  VARCHAR2
   --   Version : Current version 1.0
   --
   --   End of Comments
   --
PROCEDURE Validate_CRITERIA_VALUE_HIGH (
    P_Init_Msg_List              IN   VARCHAR2,
    P_Validation_mode            IN   VARCHAR2,
    P_PLAN_ID                    IN   NUMBER,
    P_CRITERIA_VALUE_HIGH        IN   VARCHAR2,
    P_OLD_CRITERIA_VALUE_HIGH    IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  validate_relational_operator
   --   Type    :  Private
   --   Pre-Req :  None.
   --   Function:  Performs validation on the value of relational_operator
   --   Parameters:
   --   IN
   -- p_validation_mode is a constant defined in CSC_CORE_UTILS_PVT package
   -- For create: G_CREATE, for update: G_UPDATE
   --       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
   --       p_validation_mode         IN   VARCHAR2
   --       p_plan_id                 IN   NUMBER
   --       p_relational_operator     IN   VARCHAR2
   --       p_old_relational_operator IN   VARCHAR2   Optional  Default = FND_API.G_MISS_CHAR
   --
   --   OUT :
   --       x_return_status           OUT NOCOPY  VARCHAR2
   --       x_msg_count               OUT NOCOPY  NUMBER
   --       x_msg_data                OUT NOCOPY  VARCHAR2
   --   Version : Current version 1.0
   --
   --   End of Comments
   --
PROCEDURE Validate_RELATIONAL_OPERATOR (
    P_Init_Msg_List              IN   VARCHAR2,
    P_Validation_mode            IN   VARCHAR2,
    P_PLAN_ID                    IN   NUMBER,
    P_RELATIONAL_OPERATOR        IN   VARCHAR2,
    P_OLD_RELATIONAL_OPERATOR    IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  validate_plan_criteria
   --   Type    :  Private
   --   Pre-Req :  None.
   --   Function:  Performs validation on the values used to define the plan
   --              criteria. ie. relational_operator, criteria_value_low and
   --              criteria_value_high.
   --   Parameters:
   --   IN
   -- p_validation_mode is a constant defined in CSC_CORE_UTILS_PVT package
   -- For create: G_CREATE, for update: G_UPDATE
   --       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
   --       p_validation_mode         IN   VARCHAR2
   --       p_plan_id                 IN   NUMBER
   --       p_relational_operator     IN   VARCHAR2
   --       p_criteria_value_low      IN   VARCHAR2
   --       p_criteria_value_high     IN   VARCHAR2
   --
   --   OUT :
   --       x_return_status           OUT NOCOPY  VARCHAR2
   --       x_msg_count               OUT NOCOPY  NUMBER
   --       x_msg_data                OUT NOCOPY  VARCHAR2
   --   Version : Current version 1.0
   --
   --   End of Comments
   --
PROCEDURE Validate_Plan_Criteria (
    P_Init_Msg_List              IN   VARCHAR2,
    P_Validation_mode            IN   VARCHAR2,
    P_PLAN_ID                    IN   NUMBER,
    P_RELATIONAL_OPERATOR        IN   VARCHAR2,
    P_CRITERIA_VALUE_LOW         IN   VARCHAR2,
    P_CRITERIA_VALUE_HIGH        IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2 );

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  validate_start_date_active
   --   Type    :  Private
   --   Pre-Req :  None.
   --   Function:  Performs validation on the value of start_date_active. For updates
   --              start_date_active should be less than the minimum of
   --              csc_cust_plans.start_date_active.
   --   Parameters:
   --   IN
   -- p_validation_mode is a constant defined in CSC_CORE_UTILS_PVT package
   -- For create: G_CREATE, for update: G_UPDATE
   --       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
   --       p_validation_mode         IN   VARCHAR2
   --       p_plan_id                 IN   NUMBER
   --       p_start_date_active       IN   DATE
   --
   --   OUT :
   --       x_return_status           OUT NOCOPY  VARCHAR2
   --       x_msg_count               OUT NOCOPY  NUMBER
   --       x_msg_data                OUT NOCOPY  VARCHAR2
   --   Version : Current version 1.0
   --
   --   End of Comments
   --
PROCEDURE Validate_START_DATE_ACTIVE (
    P_Init_Msg_List              IN   VARCHAR2,
    P_Validation_mode            IN   VARCHAR2,
    P_PLAN_ID                    IN   NUMBER,
    P_START_DATE_ACTIVE          IN   DATE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );


   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  validate_end_date_active
   --   Type    :  Private
   --   Pre-Req :  None.
   --   Function:  Performs validation on the value of end_date_active. For updates
   --              end_date_active should be greater than the maximum of
   --              csc_cust_plans.end_date_active.
   --   Parameters:
   --   IN
   -- p_validation_mode is a constant defined in CSC_CORE_UTILS_PVT package
   -- For create: G_CREATE, for update: G_UPDATE
   --       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
   --       p_validation_mode         IN   VARCHAR2
   --       p_plan_id                 IN   NUMBER
   --       p_end_date_active         IN   DATE
   --
   --   OUT :
   --       x_return_status           OUT NOCOPY  VARCHAR2
   --       x_msg_count               OUT NOCOPY  NUMBER
   --       x_msg_data                OUT NOCOPY  VARCHAR2
   --   Version : Current version 1.0
   --
   --   End of Comments
   --
PROCEDURE Validate_END_DATE_ACTIVE (
    P_Init_Msg_List              IN   VARCHAR2,
    P_Validation_mode            IN   VARCHAR2,
    P_PLAN_ID                    IN   NUMBER,
    P_END_DATE_ACTIVE            IN   DATE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );


   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  validate_csc_relationship_plans
   --   Type    :  Private
   --   Pre-Req :  Existing plan.
   --   Function:  Performs item level validation.
   --   Parameters:
   --   IN
   -- p_validation_mode is a constant defined in CSC_CORE_UTILS_PVT package
   -- For create: G_CREATE, for update: G_UPDATE
   --       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
   --       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
   --       p_validation_mode         IN   VARCHAR2
   --       P_CSC_PLAN_HEADERS_B_REC  IN   CSC_PLAN_HEADERS_B_REC_TYPE
   --       P_OLD_PLAN_HEADERS_B_REC  IN   CSC_PLAN_HEADERS_B_REC_TYPE
   --                                                 Optional  Default = P_CSC_PLAN_HEADERS_B_REC
   --                         -- This record type is used to pass the original values of a plan
   --                         -- when performing an update, to compare old values with the new
   --                         -- updated values. Updates are not allowed on certain columns
   --                         -- under certain situations, ie. update of use_for_cust_account are
   --                         -- not allowed if there are customers accounts associated to the plan.
   --       P_DESCRIPTION             IN   VARCHAR2,
   --       P_NAME                    IN   VARCHAR2,
   --       P_PARTY_ID_TBL            IN   CSC_CUST_PLANS_PVT.CSC_PARTY_ID_TBL_TYPE
   --									    Optional  Default =
   --                                                    CSC_CUST_PLANS_PVT.G_MISS_PARTY_ID_TBL
   --                          -- If a plan is being customized, then this table of party_ids
   --                          -- store the ids of the parties for which the plan is being
   --                          -- customized
   --                          -- If a 'CUSTOMIZED ACCOUNT LEVEL' plan ie. CUSTOMIZED_PLAN='Y'
   --                          -- and 'USE_FOR_CUST_ACCOUNT='Y', is being created, then the
   --                          -- ACCOUNT_ID and ACCOUNT_ORG columns in the table type should
   --                          -- be specified.
   --
   --
   --   OUT :
   --       x_return_status           OUT NOCOPY  VARCHAR2
   --       x_msg_count               OUT NOCOPY  NUMBER
   --       x_msg_data                OUT NOCOPY  VARCHAR2
   --   Version : Current version 1.0
   --
   --   End of Comments
   --
PROCEDURE Validate_csc_relationship_plan(
   P_Init_Msg_List              IN   VARCHAR2,
   P_Validation_level           IN   NUMBER,
   P_Validation_mode            IN   VARCHAR2,
   P_CSC_PLAN_HEADERS_B_REC     IN   CSC_PLAN_HEADERS_B_REC_TYPE,
   P_OLD_PLAN_HEADERS_B_REC     IN   CSC_PLAN_HEADERS_B_REC_TYPE := NULL,
   P_DESCRIPTION                IN   VARCHAR2,
   P_NAME                       IN   VARCHAR2,
   X_Return_Status              OUT NOCOPY  VARCHAR2,
   X_Msg_Count                  OUT NOCOPY  NUMBER,
   X_Msg_Data                   OUT NOCOPY  VARCHAR2
   );

End CSC_RELATIONSHIP_PLANS_PVT;

 

/
