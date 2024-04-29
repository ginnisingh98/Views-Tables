--------------------------------------------------------
--  DDL for Package AML_MONITOR_CONDITIONS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AML_MONITOR_CONDITIONS_PUB" AUTHID CURRENT_USER as
/* $Header: amlplmcs.pls 115.1 2002/12/06 04:56:21 ajchatto noship $ */
-- Start of Comments
-- Package name     : AS_SALES_LEADS_PUB
-- Purpose          : Sales Leads Monitor
-- NOTE             :
-- History          :
--     11/23/2002 AJCHATTO  Created.
-- End of Comments

TYPE CONDITION_Rec_Type IS RECORD
(
       MONITOR_CONDITION_ID            NUMBER := FND_API.G_MISS_NUM
,       LAST_UPDATE_DATE                DATE := FND_API.G_MISS_DATE
,       LAST_UPDATED_BY                 NUMBER := FND_API.G_MISS_NUM
,       CREATION_DATE                   DATE := FND_API.G_MISS_DATE
,       CREATED_BY                      NUMBER := FND_API.G_MISS_NUM
,       LAST_UPDATE_LOGIN               NUMBER := FND_API.G_MISS_NUM
,       OBJECT_VERSION_NUMBER           NUMBER := FND_API.G_MISS_NUM
,       REQUEST_ID                      NUMBER := FND_API.G_MISS_NUM
,       PROGRAM_APPLICATION_ID          NUMBER := FND_API.G_MISS_NUM
,       PROGRAM_ID                      NUMBER := FND_API.G_MISS_NUM
,       PROGRAM_UPDATE_DATE             DATE := FND_API.G_MISS_DATE
,       PROCESS_RULE_ID                 NUMBER := FND_API.G_MISS_NUM
,       MONITOR_TYPE_CODE               VARCHAR2(30) := FND_API.G_MISS_CHAR
,       TIME_LAG_NUM                    NUMBER := FND_API.G_MISS_NUM
,       TIME_LAG_UOM_CODE               VARCHAR2(10) := FND_API.G_MISS_CHAR
,       TIME_LAG_FROM_STAGE              VARCHAR2(100) := FND_API.G_MISS_CHAR
,       TIME_LAG_TO_STAGE               VARCHAR2(100) := FND_API.G_MISS_CHAR
,       Expiration_Relative             varchar2(1) := FND_API.G_MISS_CHAR
,       Reminder_Defined                varchar2(1) := FND_API.G_MISS_CHAR
,       Total_Reminders                 number := FND_API.G_MISS_NUM
,       Reminder_Frequency              number := FND_API.G_MISS_NUM
,       Reminder_Freq_uom_code          varchar2(30) := FND_API.G_MISS_CHAR
,       Timeout_Defined                 varchar2(10) := FND_API.G_MISS_CHAR
,       Timeout_Duration                number := FND_API.G_MISS_NUM
,       Timeout_uom_code                varchar2(30) := FND_API.G_MISS_CHAR
,       Notify_Owner                    VARCHAR2(1) := FND_API.G_MISS_CHAR
,       Notify_Owner_Manager            VARCHAR2(1) := FND_API.G_MISS_CHAR
,       ATTRIBUTE_CATEGORY              VARCHAR2(30) := FND_API.G_MISS_CHAR
,       ATTRIBUTE1                      VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE2                      VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE3                      VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE4                      VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE5                      VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE6                      VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE7                      VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE8                      VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE9                      VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE10                     VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE11                     VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE12                     VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE13                     VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE14                     VARCHAR2(150) := FND_API.G_MISS_CHAR
,       ATTRIBUTE15                     VARCHAR2(150) := FND_API.G_MISS_CHAR
);

G_MISS_CONDITION_REC          CONDITION_Rec_Type;

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_monitor_condition
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_check_access_flag       IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_admin_flag              IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_admin_group_id          IN   NUMBER     Required
--       P_CONDITION_Rec           IN CONDITION_Rec_Type  Required
--       p_profile_tbl             IN   AS_UTILITY_PUB.PROFILE_TBL_TYPE     Required
--
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 2.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--
PROCEDURE Create_monitor_condition(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2   := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2   := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    P_Identity_Resource_Id       IN   NUMBER,
    P_CONDITION_Rec              IN   CONDITION_Rec_Type  := G_MISS_CONDITION_REC,
    X_MONITOR_CONDITION_ID       OUT  NOCOPY NUMBER,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_monitor_condition
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_check_access_flag       IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_admin_flag              IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_admin_group_id          IN   NUMBER     Required
--       p_identity_salesforce_id  IN   NUMBER     Optional  Default = NULL
--       P_CONDITION_Rec     IN CONDITION_Rec_Type  Required
--       p_profile_tbl             IN   AS_UTILITY_PUB.PROFILE_TBL_TYPE     Required
--
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 2.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--
-- Hint: Add corresponding update detail table procedures if it's master-detail relationship.
PROCEDURE Update_monitor_condition(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2   := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2   := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    p_identity_salesforce_id     IN   NUMBER,
    P_CONDITION_Rec     IN    CONDITION_Rec_Type,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_monitor_condition
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_check_access_flag       IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_admin_flag              IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_admin_group_id          IN   NUMBER     Required
--       p_identity_salesforce_id  IN   NUMBER     Optional  Default = NULL
--       P_CONDITION_Rec     IN CONDITION_Rec_Type  Required
--       p_profile_tbl             IN   AS_UTILITY_PUB.PROFILE_TBL_TYPE     Required
--
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 2.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--
-- Hint: Add corresponding delete detail table procedures if it's master-detail relationship.
--       The Master delete procedure may not be needed depends on different business requirements.
PROCEDURE Delete_monitor_condition(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2   := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2   := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    p_identity_salesforce_id     IN   NUMBER,
    P_CONDITION_Rec     IN CONDITION_Rec_Type,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2
    );


End AML_MONITOR_CONDITIONS_PUB;

 

/
