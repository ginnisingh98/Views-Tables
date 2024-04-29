--------------------------------------------------------
--  DDL for Package Body AML_MONITOR_CONDITIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AML_MONITOR_CONDITIONS_PVT" as
/* $Header: amlvlmcb.pls 115.6 2003/01/23 03:41:23 swkhanna noship $ */
-- Start of Comments
-- Package name     : AML_MONITOR_CONDITIONS_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AML_MONITOR_CONDITIONS_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amlvlmcb.pls';
AS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);

-- ********************************************************
-- PROCEDURE : Create_Monitor_Condition
--
-- ********************************************************
PROCEDURE Create_monitor_condition(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2   := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2   := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    P_Identity_Resource_Id       IN   NUMBER,
    P_CONDITION_Rec              IN   AML_MONITOR_CONDITIONS_PUB.CONDITION_Rec_Type,
    X_MONITOR_CONDITION_ID       OUT  NOCOPY NUMBER,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Create_monitor_condition';
l_api_version_number      CONSTANT NUMBER   := 2.0;
l_return_status_full        VARCHAR2(1);
l_identity_sales_member_rec AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
l_access_flag               VARCHAR2(1);
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_MONITOR_CONDITION_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --
      -- ******************************************************************
      -- Validate Environment
      -- ******************************************************************
      IF FND_GLOBAL.User_Id IS NULL
      THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('AMS', 'UT_CANNOT_GET_PROFILE_VALUE');
              FND_MESSAGE.Set_Token('PROFILE', 'USER_ID', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Debug message
      IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Validate_monitor_condition');
      END IF;

      -- Invoke validation procedures
      Validate_monitor_condition(
          p_init_msg_list    => FND_API.G_FALSE,
          p_validation_level => p_validation_level,
          p_validation_mode  => AS_UTILITY_PVT.G_CREATE,
          P_CONDITION_Rec  =>  P_CONDITION_Rec,
          x_return_status    => x_return_status,
          x_msg_count        => x_msg_count,
          x_msg_data         => x_msg_data);

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;



      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Calling create table handler');
      END IF;


      -- Invoke table handler(AML_MONITOR_CONDITIONS_PKG.Insert_Row)
      AML_MONITOR_CONDITIONS_PKG.Insert_Row(
          px_MONITOR_CONDITION_ID  => x_MONITOR_CONDITION_ID
         ,p_LAST_UPDATE_DATE  => SYSDATE
         ,p_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID
         ,p_CREATION_DATE  => SYSDATE
         ,p_CREATED_BY  => FND_GLOBAL.USER_ID
         ,p_LAST_UPDATE_LOGIN  => FND_GLOBAL.CONC_LOGIN_ID
         ,p_OBJECT_VERSION_NUMBER  => p_CONDITION_rec.OBJECT_VERSION_NUMBER
         ,p_REQUEST_ID  => p_CONDITION_rec.REQUEST_ID
         ,p_PROGRAM_APPLICATION_ID  => p_CONDITION_rec.PROGRAM_APPLICATION_ID
         ,p_PROGRAM_ID  => p_CONDITION_rec.PROGRAM_ID
         ,p_PROGRAM_UPDATE_DATE  => p_CONDITION_rec.PROGRAM_UPDATE_DATE
         ,p_PROCESS_RULE_ID  => p_CONDITION_rec.PROCESS_RULE_ID
         ,p_MONITOR_TYPE_CODE  => p_CONDITION_rec.MONITOR_TYPE_CODE
         ,p_TIME_LAG_NUM  => p_CONDITION_rec.TIME_LAG_NUM
         ,p_TIME_LAG_UOM_CODE  => p_CONDITION_rec.TIME_LAG_UOM_CODE
         ,p_TIME_LAG_FROM_STAGE  => p_CONDITION_rec.TIME_LAG_FROM_STAGE
         ,p_TIME_LAG_TO_STAGE  => p_CONDITION_rec.TIME_LAG_TO_STAGE
         ,p_Expiration_Relative     => p_CONDITION_rec.Expiration_Relative
         ,p_Reminder_Defined        => p_CONDITION_rec.Reminder_Defined
         ,p_Total_Reminders         => p_CONDITION_rec.Total_Reminders
         ,p_Reminder_Frequency      => p_CONDITION_rec.Reminder_Frequency
         ,p_Reminder_Freq_uom_code  => p_CONDITION_rec.Reminder_Freq_uom_code
         ,p_Timeout_Defined         => p_CONDITION_rec.Timeout_Defined
         ,p_Timeout_Duration        => p_CONDITION_rec.Timeout_Duration
         ,p_Timeout_uom_code        => p_CONDITION_rec.Timeout_uom_code
         ,p_Notify_Owner        => p_CONDITION_rec.Notify_Owner
         ,p_Notify_Owner_Manager    => p_CONDITION_rec.Notify_Owner_Manager
         ,p_ATTRIBUTE_CATEGORY  => p_CONDITION_rec.ATTRIBUTE_CATEGORY
         ,p_ATTRIBUTE1  => p_CONDITION_rec.ATTRIBUTE1
         ,p_ATTRIBUTE2  => p_CONDITION_rec.ATTRIBUTE2
         ,p_ATTRIBUTE3  => p_CONDITION_rec.ATTRIBUTE3
         ,p_ATTRIBUTE4  => p_CONDITION_rec.ATTRIBUTE4
         ,p_ATTRIBUTE5  => p_CONDITION_rec.ATTRIBUTE5
         ,p_ATTRIBUTE6  => p_CONDITION_rec.ATTRIBUTE6
         ,p_ATTRIBUTE7  => p_CONDITION_rec.ATTRIBUTE7
         ,p_ATTRIBUTE8  => p_CONDITION_rec.ATTRIBUTE8
         ,p_ATTRIBUTE9  => p_CONDITION_rec.ATTRIBUTE9
         ,p_ATTRIBUTE10  => p_CONDITION_rec.ATTRIBUTE10
         ,p_ATTRIBUTE11  => p_CONDITION_rec.ATTRIBUTE11
         ,p_ATTRIBUTE12  => p_CONDITION_rec.ATTRIBUTE12
         ,p_ATTRIBUTE13  => p_CONDITION_rec.ATTRIBUTE13
         ,p_ATTRIBUTE14  => p_CONDITION_rec.ATTRIBUTE14
         ,p_ATTRIBUTE15  => p_CONDITION_rec.ATTRIBUTE15
);      -- Hint: Primary key should be returned.
      -- x_MONITOR_CONDITION_ID := px_MONITOR_CONDITION_ID;

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
          END IF;

      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'end');
      END IF;


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Create_monitor_condition;
-- *******************************************************************
-- PROCEDURE : Update_monitor_condition
--
-- *******************************************************************

PROCEDURE Update_monitor_condition(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2   := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2   := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    p_identity_salesforce_id     IN   NUMBER,
    P_CONDITION_Rec              IN   AML_MONITOR_CONDITIONS_PUB.CONDITION_Rec_Type,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2
    )
 IS

Cursor C_Get_monitor_condition(C_MONITOR_CONDITION_ID Number) IS
    Select rowid,
           MONITOR_CONDITION_ID,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_LOGIN,
           OBJECT_VERSION_NUMBER,
           REQUEST_ID,
           PROGRAM_APPLICATION_ID,
           PROGRAM_ID,
           PROGRAM_UPDATE_DATE,
           PROCESS_RULE_ID,
           MONITOR_TYPE_CODE,
           TIME_LAG_NUM,
           TIME_LAG_UOM_CODE,
           TIME_LAG_FROM_STAGE,
           TIME_LAG_TO_STAGE,
           Expiration_Relative,
           Reminder_Defined,
           Total_Reminders,
           Reminder_Frequency,
           Reminder_Freq_uom_code,
           Timeout_Defined,
           Timeout_Duration,
           Timeout_uom_code,
           Notify_Owner,
           Notify_Owner_Manager,
           ATTRIBUTE_CATEGORY,
           ATTRIBUTE1,
           ATTRIBUTE2,
           ATTRIBUTE3,
           ATTRIBUTE4,
           ATTRIBUTE5,
           ATTRIBUTE6,
           ATTRIBUTE7,
           ATTRIBUTE8,
           ATTRIBUTE9,
           ATTRIBUTE10,
           ATTRIBUTE11,
           ATTRIBUTE12,
           ATTRIBUTE13,
           ATTRIBUTE14,
           ATTRIBUTE15
    From  AML_MONITOR_CONDITIONS
    where monitor_condition_id = c_monitor_condition_id
    For Update NOWAIT;

l_api_name                CONSTANT VARCHAR2(30) := 'Update_monitor_condition';
l_api_version_number      CONSTANT NUMBER   := 2.0;
-- Local Variables
l_ref_CONDITION_rec  AML_MONITOR_CONDITIONS_PUB.CONDITION_Rec_Type;
l_tar_CONDITION_rec  AML_MONITOR_CONDITIONS_PUB.CONDITION_Rec_Type := P_CONDITION_Rec;
l_rowid  ROWID;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_MONITOR_CONDITION_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'start');
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --


      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: - Open Cursor to Select');
      END IF;

      Open C_Get_monitor_condition( l_tar_CONDITION_rec.MONITOR_CONDITION_ID);

      Fetch C_Get_monitor_condition into
               l_rowid,
               l_ref_CONDITION_rec.MONITOR_CONDITION_ID,
               l_ref_CONDITION_rec.LAST_UPDATE_DATE,
               l_ref_CONDITION_rec.LAST_UPDATED_BY,
               l_ref_CONDITION_rec.CREATION_DATE,
               l_ref_CONDITION_rec.CREATED_BY,
               l_ref_CONDITION_rec.LAST_UPDATE_LOGIN,
               l_ref_CONDITION_rec.OBJECT_VERSION_NUMBER,
               l_ref_CONDITION_rec.REQUEST_ID,
               l_ref_CONDITION_rec.PROGRAM_APPLICATION_ID,
               l_ref_CONDITION_rec.PROGRAM_ID,
               l_ref_CONDITION_rec.PROGRAM_UPDATE_DATE,
               l_ref_CONDITION_rec.PROCESS_RULE_ID,
               l_ref_CONDITION_rec.MONITOR_TYPE_CODE,
               l_ref_CONDITION_rec.TIME_LAG_NUM,
               l_ref_CONDITION_rec.TIME_LAG_UOM_CODE,
               l_ref_CONDITION_rec.TIME_LAG_FROM_STAGE,
               l_ref_CONDITION_rec.TIME_LAG_TO_STAGE,
               l_ref_CONDITION_rec.Expiration_Relative,
               l_ref_CONDITION_rec.Reminder_Defined,
               l_ref_CONDITION_rec.Total_Reminders,
               l_ref_CONDITION_rec.Reminder_Frequency,
               l_ref_CONDITION_rec.Reminder_Freq_uom_code,
               l_ref_CONDITION_rec.Timeout_Defined,
               l_ref_CONDITION_rec.Timeout_Duration,
               l_ref_CONDITION_rec.Timeout_uom_code,
               l_ref_CONDITION_rec.Notify_Owner,
               l_ref_CONDITION_rec.Notify_Owner_Manager,
               l_ref_CONDITION_rec.ATTRIBUTE_CATEGORY,
               l_ref_CONDITION_rec.ATTRIBUTE1,
               l_ref_CONDITION_rec.ATTRIBUTE2,
               l_ref_CONDITION_rec.ATTRIBUTE3,
               l_ref_CONDITION_rec.ATTRIBUTE4,
               l_ref_CONDITION_rec.ATTRIBUTE5,
               l_ref_CONDITION_rec.ATTRIBUTE6,
               l_ref_CONDITION_rec.ATTRIBUTE7,
               l_ref_CONDITION_rec.ATTRIBUTE8,
               l_ref_CONDITION_rec.ATTRIBUTE9,
               l_ref_CONDITION_rec.ATTRIBUTE10,
               l_ref_CONDITION_rec.ATTRIBUTE11,
               l_ref_CONDITION_rec.ATTRIBUTE12,
               l_ref_CONDITION_rec.ATTRIBUTE13,
               l_ref_CONDITION_rec.ATTRIBUTE14,
               l_ref_CONDITION_rec.ATTRIBUTE15;

       If ( C_Get_monitor_condition%NOTFOUND) Then
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
               FND_MESSAGE.Set_Name('AMS', 'API_MISSING_UPDATE_TARGET');
               FND_MESSAGE.Set_Token ('INFO', 'monitor_condition', FALSE);
               FND_MSG_PUB.Add;
           END IF;
           Close C_Get_monitor_condition;
           raise FND_API.G_EXC_ERROR;
       END IF;

      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: - Close Cursor');
      END IF;

      Close     C_Get_monitor_condition;



      If (l_tar_CONDITION_rec.last_update_date is NULL or
          l_tar_CONDITION_rec.last_update_date = FND_API.G_MISS_Date ) Then
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('AMS', 'API_MISSING_ID');
              FND_MESSAGE.Set_Token('COLUMN', 'Last_Update_Date', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          raise FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      If (l_tar_CONDITION_rec.last_update_date <> l_ref_CONDITION_rec.last_update_date) Then
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('AMS', 'API_RECORD_CHANGED');
              FND_MESSAGE.Set_Token('INFO', 'monitor_condition', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          raise FND_API.G_EXC_ERROR;
      End if;

      -- Debug message
      IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Validate_monitor_condition');
      END IF;

      -- Invoke validation procedures
      Validate_monitor_condition(
          p_init_msg_list    => FND_API.G_FALSE,
          p_validation_level => p_validation_level,
          p_validation_mode  => AS_UTILITY_PVT.G_UPDATE,
          P_CONDITION_Rec  =>  P_CONDITION_Rec,
          x_return_status    => x_return_status,
          x_msg_count        => x_msg_count,
          x_msg_data         => x_msg_data);

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;



      -- Hint: Add corresponding Master-Detail business logic here if necessary.

      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Calling update table handler');
      END IF;

      -- Invoke table handler(aml_MONITOR_CONDITIONS_PKG.Update_Row)
      AML_MONITOR_CONDITIONS_PKG.Update_Row(
          p_MONITOR_CONDITION_ID  => p_CONDITION_rec.MONITOR_CONDITION_ID
         ,p_LAST_UPDATE_DATE  => SYSDATE
         ,p_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID
         ,p_CREATION_DATE  => FND_API.G_MISS_DATE
         ,p_CREATED_BY     => FND_API.G_MISS_NUM
         ,p_LAST_UPDATE_LOGIN  => FND_GLOBAL.CONC_LOGIN_ID
         ,p_OBJECT_VERSION_NUMBER  => p_CONDITION_rec.OBJECT_VERSION_NUMBER
         ,p_REQUEST_ID  => p_CONDITION_rec.REQUEST_ID
         ,p_PROGRAM_APPLICATION_ID  => p_CONDITION_rec.PROGRAM_APPLICATION_ID
         ,p_PROGRAM_ID  => p_CONDITION_rec.PROGRAM_ID
         ,p_PROGRAM_UPDATE_DATE  => p_CONDITION_rec.PROGRAM_UPDATE_DATE
         ,p_PROCESS_RULE_ID  => p_CONDITION_rec.PROCESS_RULE_ID
         ,p_MONITOR_TYPE_CODE  => p_CONDITION_rec.MONITOR_TYPE_CODE
         ,p_TIME_LAG_NUM  => p_CONDITION_rec.TIME_LAG_NUM
         ,p_TIME_LAG_UOM_CODE  => p_CONDITION_rec.TIME_LAG_UOM_CODE
         ,p_TIME_LAG_FROM_STAGE  => p_CONDITION_rec.TIME_LAG_FROM_STAGE
         ,p_TIME_LAG_TO_STAGE  => p_CONDITION_rec.TIME_LAG_TO_STAGE
         ,p_Expiration_Relative          => p_CONDITION_rec.Expiration_Relative
         ,p_Reminder_Defined             => p_CONDITION_rec.Reminder_Defined
         ,p_Total_Reminders              => p_CONDITION_rec.Total_Reminders
         ,p_Reminder_Frequency           => p_CONDITION_rec.Reminder_Frequency
         ,p_Reminder_Freq_uom_code       => p_CONDITION_rec.Reminder_Freq_uom_code
         ,p_Timeout_Defined              => p_CONDITION_rec.Timeout_Defined
         ,p_Timeout_Duration             => p_CONDITION_rec.Timeout_Duration
         ,p_Timeout_uom_code             => p_CONDITION_rec.Timeout_uom_code
         ,p_Notify_Owner             => p_CONDITION_rec.Notify_Owner
         ,p_Notify_Owner_Manager     => p_CONDITION_rec.Notify_Owner_Manager
         ,p_ATTRIBUTE_CATEGORY  => p_CONDITION_rec.ATTRIBUTE_CATEGORY
         ,p_ATTRIBUTE1  => p_CONDITION_rec.ATTRIBUTE1
         ,p_ATTRIBUTE2  => p_CONDITION_rec.ATTRIBUTE2
         ,p_ATTRIBUTE3  => p_CONDITION_rec.ATTRIBUTE3
         ,p_ATTRIBUTE4  => p_CONDITION_rec.ATTRIBUTE4
         ,p_ATTRIBUTE5  => p_CONDITION_rec.ATTRIBUTE5
         ,p_ATTRIBUTE6  => p_CONDITION_rec.ATTRIBUTE6
         ,p_ATTRIBUTE7  => p_CONDITION_rec.ATTRIBUTE7
         ,p_ATTRIBUTE8  => p_CONDITION_rec.ATTRIBUTE8
         ,p_ATTRIBUTE9  => p_CONDITION_rec.ATTRIBUTE9
         ,p_ATTRIBUTE10  => p_CONDITION_rec.ATTRIBUTE10
         ,p_ATTRIBUTE11  => p_CONDITION_rec.ATTRIBUTE11
         ,p_ATTRIBUTE12  => p_CONDITION_rec.ATTRIBUTE12
         ,p_ATTRIBUTE13  => p_CONDITION_rec.ATTRIBUTE13
         ,p_ATTRIBUTE14  => p_CONDITION_rec.ATTRIBUTE14
         ,p_ATTRIBUTE15  => p_CONDITION_rec.ATTRIBUTE15
);      --
      -- End of API body.
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'end');
      END IF;


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Update_monitor_condition;


--********************************************************************
PROCEDURE Delete_monitor_condition(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2   := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2   := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    p_identity_salesforce_id     IN   NUMBER,
    P_CONDITION_Rec              IN   AML_MONITOR_CONDITIONS_PUB.CONDITION_Rec_Type,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2
    )


 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Delete_monitor_condition';
l_api_version_number      CONSTANT NUMBER   := 2.0;
l_identity_sales_member_rec  AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_MONITOR_CONDITION_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --

      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Calling delete table handler');
      END IF;

      -- Invoke table handler(aml_MONITOR_CONDITIONS_PKG.Delete_Row)
      AML_MONITOR_CONDITIONS_PKG.Delete_Row(
          p_process_rule_id  => p_CONDITION_rec.PROCESS_RULE_ID);
      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'end');
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Delete_monitor_condition;

-- *******************************************************************
PROCEDURE Validate_MONITOR_CONDITION_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_MONITOR_CONDITION_ID       IN   NUMBER,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2
    )
IS
  CURSOR C_condition_Id_Exists (C_MONITOR_CONDITION_ID NUMBER) IS
      SELECT 'X'
      FROM  aml_monitor_conditions
      WHERE MONITOR_CONDITION_ID = C_MONITOR_CONDITION_ID;

  l_val   VARCHAR2(1);
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = AS_UTILITY_PVT.G_CREATE)
      THEN
          IF (p_monitor_condition_id IS NOT NULL) AND
             (p_monitor_condition_id <> FND_API.G_MISS_NUM)
          THEN
              OPEN  C_condition_Id_Exists (p_monitor_condition_id);
              FETCH C_condition_Id_Exists into l_val;

              IF C_condition_Id_Exists%NOTFOUND
              THEN
                  AS_UTILITY_PVT.Set_Message(
                      p_msg_level => FND_MSG_PUB.G_MSG_LVL_ERROR,
                      p_msg_name => 'API_INVALID_ID',
                      p_token1 => 'COLUMN',
                      p_token1_value => 'MONITOR_CONDITION_ID',
                      p_token2 => 'VALUE',
                      p_token2_value => p_monitor_condition_id);

                  x_return_status := FND_API.G_RET_STS_ERROR;
              END IF;
              CLOSE C_condition_Id_Exists ;
          END IF;

      ELSIF(p_validation_mode = AS_UTILITY_PVT.G_UPDATE)
      THEN
          -- validate NOT NULL column
          IF (p_monitor_condition_id IS NULL) OR
             (p_monitor_condition_id = FND_API.G_MISS_NUM)
          THEN
              AS_UTILITY_PVT.Set_Message(
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'API_MISSING_ID',
                  p_token1        => 'COLUMN',
                  p_token1_value  => 'MONITOR_CONDITION_ID');

              x_return_status := FND_API.G_RET_STS_ERROR;
          ELSE
              OPEN  C_condition_Id_Exists (p_monitor_condition_id);
              FETCH C_condition_Id_Exists into l_val;

              IF C_condition_Id_Exists%NOTFOUND
              THEN
                  AS_UTILITY_PVT.Set_Message(
                      p_msg_level => FND_MSG_PUB.G_MSG_LVL_ERROR,
                      p_msg_name => 'API_INVALID_ID',
                      p_token1 => 'COLUMN',
                      p_token1_value => 'MONITOR_CONDITION_ID',
                      p_token2 => 'VALUE',
                      p_token2_value => p_monitor_condition_id);

                  x_return_status := FND_API.G_RET_STS_ERROR;
              END IF;

              CLOSE C_condition_Id_Exists;
          END IF;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_MONITOR_CONDITION_ID;

-- *****************************************************************
PROCEDURE Validate_monitor_condition(
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    P_Validation_mode            IN   VARCHAR2,
    P_CONDITION_Rec              IN   AML_MONITOR_CONDITIONS_PUB.CONDITION_Rec_Type,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2
    )
IS
l_api_name   CONSTANT VARCHAR2(30) := 'Validate_monitor_condition';
    l_val  VARCHAR2(1);

  CURSOR C_time_lag_to_stage_exists (c_time_lag_to_stage VARCHAR2) IS
   SELECT 'X'
   FROM (
      SELECT status_code time_lag_to_stage
      FROM  as_statuses_b
      WHERE lead_flag = 'Y' and enabled_flag = 'Y'
        UNION ALL
      SELECT  lookup_code time_lag_to_stage
      FROM  fnd_lookup_values
      WHERE lookup_type = 'TIME_LAG_TO_STAGE'
      AND enabled_flag = 'Y'
      AND (start_date_active IS NULL OR start_date_active < SYSDATE)
      AND (end_date_active IS NULL OR end_date_active > SYSDATE))
   WHERE time_lag_to_stage = c_time_lag_to_stage;

BEGIN

      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'start');
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


      IF (p_validation_level >= AS_UTILITY_PUB.G_VALID_LEVEL_ITEM) THEN
         -- validate monitor_condition_id
          Validate_MONITOR_CONDITION_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_MONITOR_CONDITION_ID   => P_CONDITION_Rec.MONITOR_CONDITION_ID,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

        -- validate OBJECT_VERSION_NUMBER
          PV_COMMON_CHECKS_PVT.Validate_OBJECT_VERSION_NUMBER(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_OBJECT_VERSION_NUMBER   => P_CONDITION_Rec.OBJECT_VERSION_NUMBER,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;


        -- validate PROCESS_RULE_ID
          pv_common_checks_pvt.Validate_PROCESS_RULE_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_PROCESS_RULE_ID        => P_CONDITION_Rec.PROCESS_RULE_ID,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

        -- validate MONITOR_TYPE_CODE
         if P_CONDITION_Rec.MONITOR_TYPE_CODE is NOT NULL and
             P_CONDITION_Rec.MONITOR_TYPE_CODE <> FND_API.G_MISS_CHAR then

             pv_common_checks_pvt.Validate_Lookup(
                 p_init_msg_list          => FND_API.G_FALSE,
                 p_validation_mode        => p_validation_mode,
                 p_TABLE_NAME             => 'AML_MONITOR_CONDITIONS',
                 p_COLUMN_NAME            => 'MONITOR_TYPE_CODE',
                 p_lookup_type            => 'MONITOR_TYPE',
                 p_lookup_code            => P_CONDITION_Rec.MONITOR_TYPE_CODE,
                 x_return_status          => x_return_status,
                 x_msg_count              => x_msg_count,
                 x_msg_data               => x_msg_data);

             IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
             END IF;

          END IF;


-- Validate_TIME_LAG_UOM_CODE
        if P_CONDITION_Rec.TIME_LAG_UOM_CODE is NOT NULL and
             P_CONDITION_Rec.TIME_LAG_UOM_CODE <> FND_API.G_MISS_CHAR then

             pv_common_checks_pvt.Validate_Lookup(
                 p_init_msg_list          => FND_API.G_FALSE,
                 p_validation_mode        => p_validation_mode,
                 p_TABLE_NAME             => 'AML_MONITOR_CONDITIONS',
                 p_COLUMN_NAME            => 'TIME_LAG_UOM_CODE',
                 p_lookup_type            => 'PV_TIMEOUT_UOM',
                 p_lookup_code            => P_CONDITION_Rec.TIME_LAG_UOM_CODE,
                 x_return_status          => x_return_status,
                 x_msg_count              => x_msg_count,
                 x_msg_data               => x_msg_data);

             IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
             END IF;

          END IF;


-- Time_lag_from_stage = assigned date ,Creation date


-- validate TIME_LAG_FROM_STAGE
         if P_CONDITION_Rec.TIME_LAG_FROM_STAGE is NOT NULL and
             P_CONDITION_Rec.TIME_LAG_FROM_STAGE <> FND_API.G_MISS_CHAR then

             pv_common_checks_pvt.Validate_Lookup(
                 p_init_msg_list          => FND_API.G_FALSE,
                 p_validation_mode        => p_validation_mode,
                 p_TABLE_NAME             => 'AML_MONITOR_CONDITIONS',
                 p_COLUMN_NAME            => 'TIME_LAG_FROM_STAGE',
                 p_lookup_type            => 'TIME_LAG_FROM_STAGE',
                 p_lookup_code            => P_CONDITION_Rec.TIME_LAG_FROM_STAGE,
                 x_return_status          => x_return_status,
                 x_msg_count              => x_msg_count,
                 x_msg_data               => x_msg_data);

             IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
             END IF;

          END IF;


-- validate TIME_LAG_TO_STAGE
         if P_CONDITION_Rec.TIME_LAG_TO_STAGE is NOT NULL and
             P_CONDITION_Rec.TIME_LAG_TO_STAGE <> FND_API.G_MISS_CHAR then

              OPEN C_time_lag_to_stage_exists(P_CONDITION_Rec.TIME_LAG_TO_STAGE);
              FETCH C_time_lag_to_stage_exists INTO  l_val;
              IF C_time_lag_to_stage_exists%NOTFOUND THEN
                AS_UTILITY_PVT.Set_Message(
                p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                p_msg_name      => 'API_INVALID_ID',
                p_token1        => 'COLUMN',
                p_token1_value  => 'TIME_LAG_TO_STAGE',
                p_token2        => 'VALUE',
                p_token2_value  =>  P_CONDITION_Rec.TIME_LAG_TO_STAGE );
                 raise FND_API.G_EXC_ERROR;
              END IF;

          END IF;

--

          -- Validate_Reminder_Freq_uom_code
        if P_CONDITION_Rec.REMINDER_FREQ_UOM_CODE is NOT NULL and
             P_CONDITION_Rec.REMINDER_FREQ_UOM_CODE <> FND_API.G_MISS_CHAR then

             pv_common_checks_pvt.Validate_Lookup(
                 p_init_msg_list          => FND_API.G_FALSE,
                 p_validation_mode        => p_validation_mode,
                 p_TABLE_NAME             => 'AML_MONITOR_CONDITIONS',
                 p_COLUMN_NAME            => 'REMINDER_FREQ_UOM_CODE',
                 p_lookup_type            => 'PV_TIMEOUT_UOM',
                 p_lookup_code            => P_CONDITION_Rec.REMINDER_FREQ_UOM_CODE,
                 x_return_status          => x_return_status,
                 x_msg_count              => x_msg_count,
                 x_msg_data               => x_msg_data);

             IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
             END IF;

          END IF;


    -- Validate_Timeout_uom_code
        if P_CONDITION_Rec.TIMEOUT_UOM_CODE is NOT NULL and
             P_CONDITION_Rec.TIMEOUT_UOM_CODE <> FND_API.G_MISS_CHAR then

             pv_common_checks_pvt.Validate_Lookup(
                 p_init_msg_list          => FND_API.G_FALSE,
                 p_validation_mode        => p_validation_mode,
                 p_TABLE_NAME             => 'AML_MONITOR_CONDITIONS',
                 p_COLUMN_NAME            => 'TIMEOUT_UOM_CODE',
                 p_lookup_type            => 'PV_TIMEOUT_UOM',
                 p_lookup_code            => P_CONDITION_Rec.TIMEOUT_UOM_CODE,
                 x_return_status          => x_return_status,
                 x_msg_count              => x_msg_count,
                 x_msg_data               => x_msg_data);

             IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
             END IF;

          END IF;

      END IF;


      -- Added validation by Ajoy
      IF ((P_CONDITION_Rec.Reminder_Defined = 'Y') AND
          (P_CONDITION_Rec.Total_Reminders IS NULL OR P_CONDITION_Rec.Reminder_Frequency IS NULL)) THEN

            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
       		 FND_MESSAGE.Set_Name('AS', 'AS_LEAD_MNTR_REMIND_REQD');
        	 FND_MSG_PUB.Add;
            END IF;

              x_return_status := FND_API.G_RET_STS_ERROR;
           --   raise FND_API.G_EXC_ERROR;
      END IF;


      IF ((P_CONDITION_Rec.Reminder_Defined = 'N') AND
          (P_CONDITION_Rec.Total_Reminders IS NOT NULL OR P_CONDITION_Rec.Reminder_Frequency IS NOT NULL)) THEN

           AS_UTILITY_PVT.Set_Message(
              p_msg_level    => FND_MSG_PUB.G_MSG_LVL_ERROR,
              p_msg_name     => 'AS_LEAD_MNTR_REMIND_CLR');

              x_return_status := FND_API.G_RET_STS_ERROR;
             -- raise FND_API.G_EXC_ERROR;
      END IF;

      IF (P_CONDITION_Rec.Timeout_Defined = 'Y' AND P_CONDITION_Rec.Timeout_Duration IS NULL)
       OR (P_CONDITION_Rec.Timeout_Defined = 'Y' AND P_CONDITION_Rec.Timeout_Duration < 0)  THEN

            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
       		 FND_MESSAGE.Set_Name('AS', 'AS_LEAD_MNTR_TMOUT_REQD');
        	 FND_MSG_PUB.Add;
            END IF;

              x_return_status := FND_API.G_RET_STS_ERROR;
              --raise FND_API.G_EXC_ERROR;
      END IF;

      IF (P_CONDITION_Rec.Timeout_Defined = 'N' AND P_CONDITION_Rec.Timeout_Duration IS NOT NULL) THEN

           AS_UTILITY_PVT.Set_Message(
              p_msg_level    => FND_MSG_PUB.G_MSG_LVL_ERROR,
              p_msg_name     => 'AS_LEAD_MNTR_TMOUT_CLR');

              x_return_status := FND_API.G_RET_STS_ERROR;
              --raise FND_API.G_EXC_ERROR;
      END IF;

      IF (p_validation_level >= AS_UTILITY_PUB.G_VALID_LEVEL_RECORD) THEN
          -- Hint: Inter-field level validation can be added here
          -- invoke record level validation procedures
            NULL;
      END IF;

      IF (p_validation_level >= AS_UTILITY_PUB.G_VALID_LEVEL_INTER_RECORD) THEN
          -- invoke inter-record level validation procedures
          NULL;
      END IF;

      IF (p_validation_level >= AS_UTILITY_PUB.G_VALID_LEVEL_INTER_ENTITY) THEN
          -- invoke inter-entity level validation procedures
          NULL;
      END IF;


      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'end');
      END IF;

END Validate_monitor_condition;


End AML_MONITOR_CONDITIONS_PVT;

/
