--------------------------------------------------------
--  DDL for Package Body PV_PROCESS_RULE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_PROCESS_RULE_PVT" as
/* $Header: pvrvprub.pls 115.21 2004/01/13 19:53:33 pklin ship $ */
-- Start of Comments
-- Package name     : PV_PROCESS_RULE_PVT
-- Purpose          :
-- History          :
--      01/08/2002  SOLIN    Created.
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'PV_PROCESS_RULE_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'pvrvprub.pls';

-- -----------------------------------------------------------
--
-- -----------------------------------------------------------
G_PROCESS_TYPE VARCHAR2(30) := NULL;
G_ACTION       VARCHAR2(30) := NULL;


TYPE NUMBER_TABLE IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;


-- Hint: Primary key needs to be returned.
AS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Create_process_rule(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Identity_Resource_Id       IN   NUMBER,
    P_PROCESS_RULE_Rec           IN   PV_RULE_RECTYPE_PUB.RULES_REC_TYPE
                                := PV_RULE_RECTYPE_PUB.G_MISS_RULES_REC,
    X_PROCESS_RULE_ID            OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                  CONSTANT VARCHAR2(30) := 'Create_process_rule';
l_api_version_number        CONSTANT NUMBER   := 2.0;
l_return_status_full        VARCHAR2(1);
l_access_flag               VARCHAR2(1);
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_PROCESS_RULE_PVT;

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
      IF (AS_DEBUG_HIGH_ON) THEN

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
              FND_MESSAGE.Set_Name('PV', 'UT_CANNOT_GET_PROFILE_VALUE');
              FND_MESSAGE.Set_Token('PROFILE', 'USER_ID', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Debug message
      IF (AS_DEBUG_HIGH_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'Private API: Validate_process_rule');
      END IF;

      -- Invoke validation procedures
      Validate_process_rule(
          p_init_msg_list    => FND_API.G_FALSE,
          p_validation_level => p_validation_level,
          p_validation_mode  => AS_UTILITY_PVT.G_CREATE,
	  P_PROCESS_RULE_Rec => p_PROCESS_RULE_rec,
          x_return_status    => x_return_status,
          x_msg_count        => x_msg_count,
          x_msg_data         => x_msg_data);

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

     /*
     --
     -- ========================================================================
              FND_MESSAGE.Set_Name('PV', 'UT_CANNOT_GET_PROFILE_VALUE');
              FND_MESSAGE.Set_Token('TEXT', 'parent_rule_id:' || p_PROCESS_RULE_rec.PARENT_RULE_ID);
              FND_MESSAGE.Set_Token('TEXT', 'child_rule_id:' || x_PROCESS_RULE_ID);
              FND_MESSAGE.Set_Token('TEXT', 'rank:' || p_PROCESS_RULE_rec.rank);
              FND_MSG_PUB.ADD;
              RAISE FND_API.G_EXC_ERROR;
     -- ========================================================================
     */
      Validate_rank(
          P_Init_Msg_List   => FND_API.G_FALSE,
          P_Validation_mode => AS_UTILITY_PVT.G_CREATE,
	  P_Parent_Rule_ID  => p_PROCESS_RULE_rec.PARENT_RULE_ID,
          P_Child_Rule_ID   => x_PROCESS_RULE_ID,
          P_RANK            => p_PROCESS_RULE_rec.rank,
          X_Return_Status   => x_return_status,
          X_Msg_Count       => x_msg_count,
          X_Msg_Data        => x_msg_data);

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      Validate_enddate(
          P_Init_Msg_List   => FND_API.G_FALSE,
          P_Validation_mode => AS_UTILITY_PVT.G_CREATE,
	  P_START_DATE      => p_PROCESS_RULE_rec.start_date,
          P_END_DATE        => p_PROCESS_RULE_rec.end_date,
          X_Return_Status   => x_return_status,
          X_Msg_Count       => x_msg_count,
          X_Msg_Data        => x_msg_data);

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      Validate_startdate(
	  P_Init_Msg_List   => FND_API.G_FALSE,
	  P_Validation_mode => AS_UTILITY_PVT.G_CREATE,
	  P_Parent_Rule_ID  => p_PROCESS_RULE_rec.PARENT_RULE_ID,
	  P_START_DATE      => p_PROCESS_RULE_rec.start_date,
	  X_Return_Status   => x_return_status,
          X_Msg_Count       => x_msg_count,
          X_Msg_Data        => x_msg_data);

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      Validate_status(
	  P_Init_Msg_List   => FND_API.G_FALSE,
          P_Validation_mode => AS_UTILITY_PVT.G_CREATE,
	  P_Parent_Rule_ID  => p_PROCESS_RULE_rec.PARENT_RULE_ID,
	  P_STATUS          => p_PROCESS_RULE_rec.status_code,
	  X_Return_Status   => x_return_status,
          X_Msg_Count       => x_msg_count,
          X_Msg_Data        => x_msg_data);

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Debug Message
      IF (AS_DEBUG_HIGH_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Calling create table handler');
      END IF;


      -- Invoke table handler(PV_PROCESS_RULES_B_PKG.Insert_Row)
      PV_PROCESS_RULES_PKG.Insert_Row(
          px_PROCESS_RULE_ID  => x_PROCESS_RULE_ID
         ,p_PARENT_RULE_ID  => p_PROCESS_RULE_rec.PARENT_RULE_ID
         ,p_LAST_UPDATE_DATE  => SYSDATE
         ,p_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID
         ,p_CREATION_DATE  => SYSDATE
         ,p_CREATED_BY  => FND_GLOBAL.USER_ID
         ,p_LAST_UPDATE_LOGIN  => FND_GLOBAL.CONC_LOGIN_ID
         ,p_OBJECT_VERSION_NUMBER  => p_PROCESS_RULE_rec.OBJECT_VERSION_NUMBER
         ,p_REQUEST_ID  => p_PROCESS_RULE_rec.REQUEST_ID
         ,p_PROGRAM_APPLICATION_ID  => p_PROCESS_RULE_rec.PROGRAM_APPLICATION_ID
         ,p_PROGRAM_ID  => p_PROCESS_RULE_rec.PROGRAM_ID
         ,p_PROGRAM_UPDATE_DATE  => p_PROCESS_RULE_rec.PROGRAM_UPDATE_DATE
         ,p_PROCESS_TYPE  => p_PROCESS_RULE_rec.PROCESS_TYPE
         ,p_RANK  => p_PROCESS_RULE_rec.RANK
         ,p_STATUS_CODE  => p_PROCESS_RULE_rec.STATUS_CODE
         ,p_START_DATE  => p_PROCESS_RULE_rec.START_DATE
         ,p_END_DATE  => p_PROCESS_RULE_rec.END_DATE
         ,p_ACTION  => p_PROCESS_RULE_rec.ACTION
         ,p_ACTION_VALUE  => p_PROCESS_RULE_rec.ACTION_VALUE
         ,p_OWNER_RESOURCE_ID  => p_PROCESS_RULE_rec.OWNER_RESOURCE_ID
         ,p_CURRENCY_CODE  => p_PROCESS_RULE_rec.CURRENCY_CODE
         ,p_PROCESS_RULE_NAME  => p_PROCESS_RULE_rec.PROCESS_RULE_NAME
         ,p_DESCRIPTION  => p_PROCESS_RULE_rec.DESCRIPTION
         ,p_ATTRIBUTE_CATEGORY  => p_PROCESS_RULE_rec.ATTRIBUTE_CATEGORY
         ,p_ATTRIBUTE1  => p_PROCESS_RULE_rec.ATTRIBUTE1
         ,p_ATTRIBUTE2  => p_PROCESS_RULE_rec.ATTRIBUTE2
         ,p_ATTRIBUTE3  => p_PROCESS_RULE_rec.ATTRIBUTE3
         ,p_ATTRIBUTE4  => p_PROCESS_RULE_rec.ATTRIBUTE4
         ,p_ATTRIBUTE5  => p_PROCESS_RULE_rec.ATTRIBUTE5
         ,p_ATTRIBUTE6  => p_PROCESS_RULE_rec.ATTRIBUTE6
         ,p_ATTRIBUTE7  => p_PROCESS_RULE_rec.ATTRIBUTE7
         ,p_ATTRIBUTE8  => p_PROCESS_RULE_rec.ATTRIBUTE8
         ,p_ATTRIBUTE9  => p_PROCESS_RULE_rec.ATTRIBUTE9
         ,p_ATTRIBUTE10  => p_PROCESS_RULE_rec.ATTRIBUTE10
         ,p_ATTRIBUTE11  => p_PROCESS_RULE_rec.ATTRIBUTE11
         ,p_ATTRIBUTE12  => p_PROCESS_RULE_rec.ATTRIBUTE12
         ,p_ATTRIBUTE13  => p_PROCESS_RULE_rec.ATTRIBUTE13
         ,p_ATTRIBUTE14  => p_PROCESS_RULE_rec.ATTRIBUTE14
         ,p_ATTRIBUTE15  => p_PROCESS_RULE_rec.ATTRIBUTE15
);

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
      IF (AS_DEBUG_HIGH_ON) THEN

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
End Create_process_rule;


-- Hint: Add corresponding update detail table procedures if it's master-detail relationship.
PROCEDURE Update_process_rule(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Identity_Resource_Id       IN   NUMBER,
    P_PROCESS_RULE_Rec           IN   PV_RULE_RECTYPE_PUB.RULES_REC_TYPE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS

Cursor C_Get_process_rule(pc_PROCESS_RULE_ID Number) IS
    Select OBJECT_VERSION_NUMBER
    From  PV_PROCESS_RULES_B
    where process_rule_id = pc_process_rule_id
    For Update NOWAIT;

l_api_name                CONSTANT VARCHAR2(30) := 'Update_process_rule';
l_api_version_number      CONSTANT NUMBER   := 2.0;
-- Local Variables
l_ref_PROCESS_RULE_rec    PV_RULE_RECTYPE_PUB.RULES_REC_TYPE;
l_tar_PROCESS_RULE_rec    PV_RULE_RECTYPE_PUB.RULES_REC_TYPE := P_PROCESS_RULE_Rec;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_PROCESS_RULE_PVT;

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
      IF (AS_DEBUG_HIGH_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --

      -- Debug Message
      IF (AS_DEBUG_HIGH_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'Private API: - Open Cursor to Select');
      END IF;


      Open C_Get_process_rule( l_tar_PROCESS_RULE_rec.PROCESS_RULE_ID);

      Fetch C_Get_process_rule into
               l_ref_PROCESS_RULE_rec.OBJECT_VERSION_NUMBER;

      If ( C_Get_process_rule%NOTFOUND) Then
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('AS', 'API_MISSING_UPDATE_TARGET');
              FND_MESSAGE.Set_Token ('INFO', 'process_rule', FALSE);
              FND_MSG_PUB.Add;
          END IF;
          Close C_Get_process_rule;
          raise FND_API.G_EXC_ERROR;
      END IF;
      -- Debug Message
      IF (AS_DEBUG_HIGH_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'Private API: - Close Cursor');
      END IF;
      Close     C_Get_process_rule;

      If (l_tar_PROCESS_RULE_rec.object_version_number is NULL or
          l_tar_PROCESS_RULE_rec.object_version_number = FND_API.G_MISS_NUM ) Then
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('AS', 'API_MISSING_ID');
              FND_MESSAGE.Set_Token('COLUMN', 'object_version_number', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          raise FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      If (l_tar_PROCESS_RULE_rec.object_version_number <> l_ref_PROCESS_RULE_rec.object_version_number) Then
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('AS', 'API_RECORD_CHANGED');
              FND_MESSAGE.Set_Token('INFO', 'process_rule', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          raise FND_API.G_EXC_ERROR;
      End if;

      -- Debug message
      IF (AS_DEBUG_HIGH_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'Private API: Validate_process_rule');
      END IF;

      -- Invoke validation procedures
      Validate_process_rule(
          p_init_msg_list    => FND_API.G_FALSE,
          p_validation_level => p_validation_level,
          p_validation_mode  => AS_UTILITY_PVT.G_UPDATE,
          P_PROCESS_RULE_Rec => P_PROCESS_RULE_Rec,
          x_return_status    => x_return_status,
          x_msg_count        => x_msg_count,
          x_msg_data         => x_msg_data);

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      Validate_rank(
          P_Init_Msg_List   => FND_API.G_FALSE,
          P_Validation_mode => AS_UTILITY_PVT.G_UPDATE,
	  P_Parent_Rule_ID  => p_PROCESS_RULE_rec.PARENT_RULE_ID,
          P_Child_Rule_ID   => P_PROCESS_RULE_Rec.PROCESS_RULE_ID,
          P_RANK            => p_PROCESS_RULE_rec.rank,
          X_Return_Status   => x_return_status,
          X_Msg_Count       => x_msg_count,
          X_Msg_Data        => x_msg_data);

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      Validate_enddate(
          P_Init_Msg_List   => FND_API.G_FALSE,
          P_Validation_mode => AS_UTILITY_PVT.G_UPDATE,
	  P_START_DATE      => p_PROCESS_RULE_rec.start_date,
          P_END_DATE        => p_PROCESS_RULE_rec.end_date,
          X_Return_Status   => x_return_status,
          X_Msg_Count       => x_msg_count,
          X_Msg_Data        => x_msg_data);

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      Validate_startdate(
	  P_Init_Msg_List   => FND_API.G_FALSE,
	  P_Validation_mode => AS_UTILITY_PVT.G_UPDATE,
	  P_Parent_Rule_ID  => p_PROCESS_RULE_rec.PARENT_RULE_ID,
	  P_START_DATE      => p_PROCESS_RULE_rec.start_date,
	  X_Return_Status   => x_return_status,
          X_Msg_Count       => x_msg_count,
          X_Msg_Data        => x_msg_data);

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      G_PROCESS_TYPE := p_PROCESS_RULE_rec.process_type;
      G_ACTION       := 'UPDATE';

      Validate_status(
	  P_Init_Msg_List   => FND_API.G_FALSE,
          P_Validation_mode => AS_UTILITY_PVT.G_UPDATE,
	  P_Parent_Rule_ID  => p_PROCESS_RULE_rec.process_RULE_ID,
	  P_STATUS          => p_PROCESS_RULE_rec.status_code,
	  X_Return_Status   => x_return_status,
          X_Msg_Count       => x_msg_count,
          X_Msg_Data        => x_msg_data);

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Debug Message
      IF (AS_DEBUG_HIGH_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Calling update table handler');
      END IF;

      -- Invoke table handler(PV_PROCESS_RULES_B_PKG.Update_Row)
      PV_PROCESS_RULES_PKG.Update_Row(
          p_PROCESS_RULE_ID  => p_PROCESS_RULE_rec.PROCESS_RULE_ID
         ,p_LAST_UPDATE_DATE  => SYSDATE
         ,p_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID
         ,p_CREATION_DATE  => FND_API.G_MISS_DATE
         ,p_CREATED_BY     => FND_API.G_MISS_NUM
         ,p_LAST_UPDATE_LOGIN  => FND_GLOBAL.CONC_LOGIN_ID
         ,p_OBJECT_VERSION_NUMBER  => p_PROCESS_RULE_rec.OBJECT_VERSION_NUMBER
         ,p_REQUEST_ID  => p_PROCESS_RULE_rec.REQUEST_ID
         ,p_PROGRAM_APPLICATION_ID  => p_PROCESS_RULE_rec.PROGRAM_APPLICATION_ID
         ,p_PROGRAM_ID  => p_PROCESS_RULE_rec.PROGRAM_ID
         ,p_PROGRAM_UPDATE_DATE  => p_PROCESS_RULE_rec.PROGRAM_UPDATE_DATE
         ,p_PROCESS_TYPE  => p_PROCESS_RULE_rec.PROCESS_TYPE
         ,p_RANK  => p_PROCESS_RULE_rec.RANK
         ,p_STATUS_CODE  => p_PROCESS_RULE_rec.STATUS_CODE
         ,p_START_DATE  => p_PROCESS_RULE_rec.START_DATE
         ,p_END_DATE  => p_PROCESS_RULE_rec.END_DATE
         ,p_ACTION  => p_PROCESS_RULE_rec.ACTION
         ,p_ACTION_VALUE  => p_PROCESS_RULE_rec.ACTION_VALUE
         ,p_OWNER_RESOURCE_ID  => p_PROCESS_RULE_rec.OWNER_RESOURCE_ID
         ,p_CURRENCY_CODE  => p_PROCESS_RULE_rec.CURRENCY_CODE
         ,p_PROCESS_RULE_NAME  => p_PROCESS_RULE_rec.PROCESS_RULE_NAME
         ,p_DESCRIPTION  => p_PROCESS_RULE_rec.DESCRIPTION
         ,p_ATTRIBUTE_CATEGORY  => p_PROCESS_RULE_rec.ATTRIBUTE_CATEGORY
         ,p_ATTRIBUTE1  => p_PROCESS_RULE_rec.ATTRIBUTE1
         ,p_ATTRIBUTE2  => p_PROCESS_RULE_rec.ATTRIBUTE2
         ,p_ATTRIBUTE3  => p_PROCESS_RULE_rec.ATTRIBUTE3
         ,p_ATTRIBUTE4  => p_PROCESS_RULE_rec.ATTRIBUTE4
         ,p_ATTRIBUTE5  => p_PROCESS_RULE_rec.ATTRIBUTE5
         ,p_ATTRIBUTE6  => p_PROCESS_RULE_rec.ATTRIBUTE6
         ,p_ATTRIBUTE7  => p_PROCESS_RULE_rec.ATTRIBUTE7
         ,p_ATTRIBUTE8  => p_PROCESS_RULE_rec.ATTRIBUTE8
         ,p_ATTRIBUTE9  => p_PROCESS_RULE_rec.ATTRIBUTE9
         ,p_ATTRIBUTE10  => p_PROCESS_RULE_rec.ATTRIBUTE10
         ,p_ATTRIBUTE11  => p_PROCESS_RULE_rec.ATTRIBUTE11
         ,p_ATTRIBUTE12  => p_PROCESS_RULE_rec.ATTRIBUTE12
         ,p_ATTRIBUTE13  => p_PROCESS_RULE_rec.ATTRIBUTE13
         ,p_ATTRIBUTE14  => p_PROCESS_RULE_rec.ATTRIBUTE14
         ,p_ATTRIBUTE15  => p_PROCESS_RULE_rec.ATTRIBUTE15
);
      --
      -- End of API body.
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      IF (AS_DEBUG_HIGH_ON) THEN

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
End Update_process_rule;

-- ----------------------------------------------------------------------------------------
-- Delete_Process_Rule
--
-- Hint: Add corresponding delete detail table procedures if it's master-detail relationship.
--       The Master delete procedure may not be needed depends on different business requirements.
-- ----------------------------------------------------------------------------------------
PROCEDURE Delete_process_rule(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Identity_Resource_Id       IN   NUMBER,
    P_PROCESS_RULE_Rec           IN   PV_RULE_RECTYPE_PUB.RULES_REC_TYPE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Delete_process_rule';
l_api_version_number      CONSTANT NUMBER   := 2.0;

-- ------------------------------------------------------------------------
-- These columns can be retrieved from the VO to save a database call.
-- However, OSO has a bug that doesn't allow parent_Rule_id to be returned.
-- ------------------------------------------------------------------------
/*
cursor lc_retrieve_rule_components(pc_rule_id number) is
   select parent_rule_id, process_type
   from   pv_process_rules_vl
   where  process_rule_id = pc_rule_id;
*/

-- ------------------------------------------------------------------------
-- SQL is tuned to make use of an index on fnd_profile_option_values
-- ------------------------------------------------------------------------
cursor lc_validate_rule_profile_ref(pc_rule_id number) is
   select process_rule_name
   from   fnd_profile_option_values a, pv_process_rules_tl b,
          fnd_profile_options c
   where  a.profile_option_value = to_char(pc_rule_id)
   and    a.profile_option_value = b.process_rule_id AND
          b.language             = USERENV('LANG') and
          a.application_Id       = 691 and
          a.profile_option_id    = c.profile_option_id AND
          c.profile_option_name  = 'PV_AUTO_MATCHING_RULE';


/* ------------------------------------------------------
cursor lc_validate_rule_referenced(pc_rule_id number) is
   select process_rule_name
   from pv_entity_rules_applied a, pv_process_rules_vl b
   where a.process_rule_id = pc_rule_id
   and   a.process_rule_id = b.process_rule_id;
   ------------------------------------------------------- */
cursor lc_validate_rule_referenced1(pc_rule_id number) is
   SELECT process_rule_name
   FROM   pv_process_rules_vl a
   WHERE  process_rule_id = pc_rule_id AND
          EXISTS (SELECT 'x' FROM pv_entity_rules_applied b
                  WHERE  a.process_rule_id = b.process_rule_id);

cursor lc_validate_rule_referenced2(pc_rule_id number) is
   SELECT process_rule_name
   FROM   pv_process_rules_vl a
   WHERE  process_rule_id = pc_rule_id AND
          EXISTS (SELECT 'x' FROM pv_entity_rules_applied b
                  WHERE  b.parent_process_rule_id = a.process_rule_id);


cursor lc_get_selcrit (pc_rule_id number) is
   select selection_criteria_id
   from pv_enty_select_criteria
   where process_rule_id = pc_rule_id;

cursor lc_get_attr_mapping (pc_rule_id number) is
   select mapping_id
   from pv_entity_attr_mappings
   where process_rule_id = pc_rule_id;

cursor lc_get_entity_routing (pc_rule_id number) is
   select entity_routing_id
   from pv_entity_routings
   where process_rule_id = pc_rule_id;

cursor lc_get_parent_rule_id (pc_rule_id number) is
   select process_rule_id
   from pv_process_rules_vl
   where parent_rule_id = pc_rule_id;


l_ENTYROUT_rec    PV_RULE_RECTYPE_PUB.ENTYROUT_Rec_Type;
l_ENTYATTMAP_rec  PV_RULE_RECTYPE_PUB.ENTYATTMAP_Rec_Type;
l_SELCRIT_rec     PV_RULE_RECTYPE_PUB.SELCRIT_Rec_Type;

l_process_rule_name varchar2(100);
l_selection_criteria_id number;
l_mapping_id            number;
l_entity_routing_id     number;

l_is_main_rule_flag     BOOLEAN;
l_process_type          VARCHAR2(30);
l_process_rule_id       NUMBER;


 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_PROCESS_RULE_PVT;

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
      IF (AS_DEBUG_HIGH_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --
      -- ------------------------------------------------------------------
      -- Find out if the current rule is a main rule or a subrule.
      -- ------------------------------------------------------------------
      FOR x IN (
         SELECT parent_rule_id, process_type
         FROM   pv_process_rules_vl
         WHERE  process_rule_id = p_PROCESS_RULE_rec.PROCESS_RULE_ID)
      LOOP
         IF (x.parent_rule_id IS NOT NULL) THEN
            l_is_main_rule_flag := FALSE;

         ELSE
            l_is_main_rule_flag := TRUE;
         END IF;

         l_process_type := x.process_type;
      END LOOP;


      open lc_validate_rule_profile_ref (pc_rule_id => p_PROCESS_RULE_rec.PROCESS_RULE_ID);
      fetch lc_validate_rule_profile_ref into l_process_rule_name;
      close lc_validate_rule_profile_ref;

      if l_process_rule_name is not null then

          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	  THEN
              FND_MESSAGE.Set_Name('PV', 'PV_RULE_REF_BY_PROFILE');
              FND_MESSAGE.Set_Token('PROCESS_RULE_NAME',l_process_rule_name);
              FND_MSG_PUB.Add;
          END IF;

          RAISE FND_API.G_EXC_ERROR;

	  l_process_rule_name := null;

      end if;

      -- ------------------------------------------------------------------
      -- Check if the rule is referenced by any leads.
      -- ------------------------------------------------------------------
      IF (l_process_type IN ('LEAD_RATING', 'CHANNEL_SELECTION', 'LEAD_QUALIFICATION') AND
          l_is_main_rule_flag)
      THEN
         open lc_validate_rule_referenced2 (pc_rule_id => p_PROCESS_RULE_rec.PROCESS_RULE_ID);
         fetch lc_validate_rule_referenced2 into l_process_rule_name;
         close lc_validate_rule_referenced2;

      ELSE
         open lc_validate_rule_referenced1 (pc_rule_id => p_PROCESS_RULE_rec.PROCESS_RULE_ID);
         fetch lc_validate_rule_referenced1 into l_process_rule_name;
         close lc_validate_rule_referenced1;
      END IF;

      if l_process_rule_name is not null then

          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	  THEN
              FND_MESSAGE.Set_Name('PV', 'PV_RULE_REFERENCED');
              FND_MESSAGE.Set_Token('PROCESS_RULE_NAME',l_process_rule_name);
              FND_MSG_PUB.Add;
          END IF;

          RAISE FND_API.G_EXC_ERROR;

      end if;

      begin

         open lc_get_entity_routing (pc_rule_id => p_PROCESS_RULE_rec.PROCESS_RULE_ID);
         loop

            fetch lc_get_entity_routing into l_entity_routing_id;
            exit when lc_get_entity_routing%notfound;

            l_entyrout_rec.entity_routing_id := l_entity_routing_id;

            PV_entyrout_PVT.Delete_entyrout(
               P_Api_Version_Number         => 2.0,
               P_Init_Msg_List              => FND_API.G_FALSE,
               P_Commit                     => p_commit,
               P_Validation_Level           => p_Validation_Level,
               P_Identity_Resource_Id       => P_Identity_Resource_Id,
               P_ENTYROUT_Rec               => l_ENTYROUT_Rec,
               X_Return_Status              => x_return_status,
               X_Msg_Count                  => x_msg_count,
               X_Msg_Data                   => x_msg_data);

              -- Check return status from the above procedure call
              IF x_return_status = FND_API.G_RET_STS_ERROR then
                  raise FND_API.G_EXC_ERROR;
              elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
                  raise FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;

         end loop;
         close lc_get_entity_routing;

      exception
      when others then
         close lc_get_entity_routing;
         raise;
      end;

      begin

         open lc_get_attr_mapping (pc_rule_id => p_PROCESS_RULE_rec.PROCESS_RULE_ID);
         loop

            fetch lc_get_attr_mapping into l_mapping_id;
            exit when lc_get_attr_mapping%notfound;

            l_entyattmap_rec.mapping_id := l_mapping_id;


            PV_entyattmap_PVT.Delete_entyattmap(
               P_Api_Version_Number         => 2.0,
               P_Init_Msg_List              => FND_API.G_FALSE,
               P_Commit                     => p_commit,
               P_Validation_Level           => p_Validation_Level,
               P_Identity_Resource_Id       => P_Identity_Resource_Id,
               P_ENTYATTMAP_Rec             => l_ENTYATTMAP_Rec,
               X_Return_Status              => x_return_status,
               X_Msg_Count                  => x_msg_count,
               X_Msg_Data                   => x_msg_data);

            -- Check return status from the above procedure call
            IF x_return_status = FND_API.G_RET_STS_ERROR then
                raise FND_API.G_EXC_ERROR;
            elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
                raise FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

         end loop;
         close lc_get_attr_mapping;

      exception
      when others then
         close lc_get_attr_mapping;
         raise;
      end;

      begin

         open lc_get_selcrit (pc_rule_id => p_PROCESS_RULE_rec.PROCESS_RULE_ID);
         loop

            fetch lc_get_selcrit into l_selection_criteria_id;
            exit when lc_get_selcrit%notfound;

            l_selcrit_rec.selection_criteria_id := l_selection_criteria_id;

            PV_selcrit_PVT.Delete_selcrit(
               P_Api_Version_Number         => 2.0,
               P_Init_Msg_List              => FND_API.G_FALSE,
               P_Commit                     => p_commit,
               P_Validation_Level           => p_Validation_Level,
               P_Identity_Resource_Id       => P_Identity_Resource_Id,
               P_SELCRIT_Rec                => l_SELCRIT_Rec,
               X_Return_Status              => x_return_status,
               X_Msg_Count                  => x_msg_count,
               X_Msg_Data                   => x_msg_data);

              -- Check return status from the above procedure call
              IF x_return_status = FND_API.G_RET_STS_ERROR then
                  raise FND_API.G_EXC_ERROR;
              elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
                  raise FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;

         end loop;
         close lc_get_selcrit;

      exception
      when others then
         close lc_get_selcrit;
         raise;
      end;

      -- Debug Message
      IF (AS_DEBUG_HIGH_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: PV_PROCESS_RULES_PKG.Delete_Row');
      END IF;

      -- Invoke table handler(PV_PROCESS_RULES_B_PKG.Delete_Row)
      PV_PROCESS_RULES_PKG.Delete_Row(
          p_PROCESS_RULE_ID  => p_PROCESS_RULE_rec.PROCESS_RULE_ID);
      --
      -- End of API body
      --

      -- Code change by ryellapu to delete the child rules when parent rule is deleted
      -- Invoke table handler(PV_PROCESS_RULES_B_PKG.Delete_Row) to DELETE the child rows

      -- BEGIN OF CHILD RULE DELETION

     begin
      open lc_get_parent_rule_id (pc_rule_id => p_PROCESS_RULE_rec.PROCESS_RULE_ID);
         loop
            fetch lc_get_parent_rule_id into l_process_rule_id;
            exit when lc_get_parent_rule_id%notfound;

       PV_PROCESS_RULES_PKG.Delete_Row(
          p_PROCESS_RULE_ID  => l_process_rule_id);

          -- Check return status from the above procedure call
              IF x_return_status = FND_API.G_RET_STS_ERROR then
                  raise FND_API.G_EXC_ERROR;
              elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
                  raise FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
         end loop;
         close lc_get_parent_rule_id;
	 exception
        when others then
         close lc_get_parent_rule_id;
         raise;
	end;

     -- END OF CHILD RULE DELETION

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      IF (AS_DEBUG_HIGH_ON) THEN

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
End Delete_process_rule;


-- Hint: Primary key needs to be returned.
PROCEDURE Copy_process_rule(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Identity_Resource_Id       IN   NUMBER,
    P_PROCESS_RULE_Rec           IN   PV_RULE_RECTYPE_PUB.RULES_REC_TYPE
                                := PV_RULE_RECTYPE_PUB.G_MISS_RULES_REC,
    X_PROCESS_RULE_ID            OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                  CONSTANT VARCHAR2(30) := 'Copy_process_rule';
l_api_version_number        CONSTANT NUMBER   := 2.0;
l_return_status_full        VARCHAR2(1);
l_access_flag               VARCHAR2(1);

Cursor C_Get_parent_process_rules(pc_PROCESS_RULE_ID Number) IS
    Select RLSB.PROCESS_RULE_ID, RLSB.LAST_UPDATE_DATE, RLSB.LAST_UPDATED_BY, RLSB.CREATION_DATE, RLSB.CREATED_BY,
           RLSB.LAST_UPDATE_LOGIN, RLSB.OBJECT_VERSION_NUMBER, RLSB.REQUEST_ID, RLSB.PROGRAM_APPLICATION_ID, RLSB.PROGRAM_ID,
           RLSB.PROGRAM_UPDATE_DATE, PROCESS_RULE_NAME, PARENT_RULE_ID, PROCESS_TYPE , RANK, STATUS_CODE, START_DATE, END_DATE,
	   ACTION, ACTION_VALUE, OWNER_RESOURCE_ID, CURRENCY_CODE, LANGUAGE, SOURCE_LANG ,DESCRIPTION, ATTRIBUTE_CATEGORY,
	   ATTRIBUTE1, ATTRIBUTE2, ATTRIBUTE3, ATTRIBUTE4, ATTRIBUTE5, ATTRIBUTE6, ATTRIBUTE7, ATTRIBUTE8, ATTRIBUTE9,
	   ATTRIBUTE10, ATTRIBUTE11, ATTRIBUTE12, ATTRIBUTE13, ATTRIBUTE14, ATTRIBUTE15
    From  PV_PROCESS_RULES_B RLSB,PV_PROCESS_RULES_TL RLST
    where RLSB.process_rule_id = RLST.process_rule_id and
          (RLSB.parent_rule_id = pc_process_rule_id or RLSB.process_rule_id = pc_process_rule_id) and
	  RLST.language = USERENV('LANG') order by parent_rule_id desc;

  Cursor C_Get_enty_select_criteria(pc_PROCESS_RULE_ID Number) IS
    Select SELECTION_CRITERIA_ID, LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN,
           OBJECT_VERSION_NUMBER,REQUEST_ID,PROGRAM_APPLICATION_ID,PROGRAM_ID,PROGRAM_UPDATE_DATE,PROCESS_RULE_ID,
           ATTRIBUTE_ID, SELECTION_TYPE_CODE, OPERATOR, RANK, ATTRIBUTE_CATEGORY, ATTRIBUTE1, ATTRIBUTE2, ATTRIBUTE3,
           ATTRIBUTE4, ATTRIBUTE5, ATTRIBUTE6, ATTRIBUTE7, ATTRIBUTE8, ATTRIBUTE9, ATTRIBUTE10, ATTRIBUTE11, ATTRIBUTE12,
           ATTRIBUTE13, ATTRIBUTE14, ATTRIBUTE15
    From  PV_ENTY_SELECT_CRITERIA
    Where process_rule_id = pc_PROCESS_RULE_ID;

  Cursor C_Get_selected_attr_values(pc_SELECTION_CRITERIA_ID Number) IS
    Select ATTR_VALUE_ID,LAST_UPDATE_DATE,LAST_UPDATED_BY,CREATION_DATE,CREATED_BY,LAST_UPDATE_LOGIN,OBJECT_VERSION_NUMBER,
           REQUEST_ID,PROGRAM_APPLICATION_ID,PROGRAM_ID,PROGRAM_UPDATE_DATE,SELECTION_CRITERIA_ID,ATTRIBUTE_VALUE,
           ATTRIBUTE_TO_VALUE,ATTRIBUTE_CATEGORY,ATTRIBUTE1,ATTRIBUTE2,ATTRIBUTE3,ATTRIBUTE4,ATTRIBUTE5,ATTRIBUTE6,
           ATTRIBUTE7,ATTRIBUTE8,ATTRIBUTE9,ATTRIBUTE10,ATTRIBUTE11,ATTRIBUTE12,ATTRIBUTE13,ATTRIBUTE14,ATTRIBUTE15,SCORE
    From  PV_SELECTED_ATTR_VALUES
    Where SELECTION_CRITERIA_ID = pc_SELECTION_CRITERIA_ID;

  Cursor C_Get_entity_attr_mappings(pc_PROCESS_RULE_ID Number) IS
    Select MAPPING_ID,LAST_UPDATE_DATE,LAST_UPDATED_BY,CREATION_DATE,CREATED_BY,LAST_UPDATE_LOGIN,OBJECT_VERSION_NUMBER,
	   REQUEST_ID,PROGRAM_APPLICATION_ID,PROGRAM_ID,PROGRAM_UPDATE_DATE,PROCESS_RULE_ID,SOURCE_ATTR_TYPE,
	   SOURCE_ATTR_ID,TARGET_ATTR_TYPE,TARGET_ATTR_ID,OPERATOR,ATTRIBUTE_CATEGORY,ATTRIBUTE1,ATTRIBUTE2,
	   ATTRIBUTE3,ATTRIBUTE4,ATTRIBUTE5,ATTRIBUTE6,ATTRIBUTE7,ATTRIBUTE8,ATTRIBUTE9,ATTRIBUTE10,ATTRIBUTE11,
	   ATTRIBUTE12,ATTRIBUTE13,ATTRIBUTE14,ATTRIBUTE15
    From  PV_ENTITY_ATTR_MAPPINGS
    Where process_rule_id = pc_PROCESS_RULE_ID;

    Cursor C_Get_entity_routings(pc_PROCESS_RULE_ID Number) IS
    Select ENTITY_ROUTING_ID,LAST_UPDATE_DATE,LAST_UPDATED_BY,CREATION_DATE,CREATED_BY,LAST_UPDATE_LOGIN,OBJECT_VERSION_NUMBER,
	   REQUEST_ID,PROGRAM_APPLICATION_ID,PROGRAM_ID,PROGRAM_UPDATE_DATE,PROCESS_RULE_ID,DISTANCE_FROM_CUSTOMER,
	   DISTANCE_UOM_CODE,MAX_NEAREST_PARTNER,ROUTING_TYPE,BYPASS_CM_OK_FLAG,CM_TIMEOUT,CM_TIMEOUT_UOM_CODE,PARTNER_TIMEOUT,
	   PARTNER_TIMEOUT_UOM_CODE,UNMATCHED_INT_RESOURCE_ID,UNMATCHED_CALL_TAP_FLAG,ATTRIBUTE_CATEGORY,ATTRIBUTE1,
	   ATTRIBUTE2,ATTRIBUTE3,ATTRIBUTE4,ATTRIBUTE5,ATTRIBUTE6,ATTRIBUTE7,ATTRIBUTE8,ATTRIBUTE9,ATTRIBUTE10,ATTRIBUTE11,
	   ATTRIBUTE12,ATTRIBUTE13,ATTRIBUTE14,ATTRIBUTE15
     From PV_ENTITY_ROUTINGS
     Where process_rule_id = pc_PROCESS_RULE_ID;

    --l_PROCESS_RULE_rec		PV_RULE_RECTYPE_PUB.RULES_REC_TYPE;
    --l_ENTY_SELECT_CRITERIA_rec	PV_RULE_RECTYPE_PUB.SELCRIT_REC_TYPE;
    --l_SELECT_ATTR_VALUES_rec	PV_RULE_RECTYPE_PUB.SELATTVAL_REC_TYPE;
    --l_ENTITY_ATTR_MAPPINGS_rec  PV_RULE_RECTYPE_PUB.ENTYATTMAP_REC_TYPE;
    --l_ENTITY_ROUTINGS_rec       PV_RULE_RECTYPE_PUB.ENTYROUT_REC_TYPE;
    --l_api_version_number  CONSTANT NUMBER   := 2.0;
    --l_Init_Msg_List       VARCHAR2(30) := FND_API.G_FALSE;
    --l_Commit              VARCHAR2(30) := FND_API.G_FALSE;
    --l_validation_level    NUMBER       := FND_API.G_VALID_LEVEL_FULL;
    --L_API_NAME            VARCHAR2(30) := 'PV_RULES_COPY_PUB';
    --l_PROCESS_RULE_ID     NUMBER  ;

    l_Return_Status       VARCHAR2(30);
    l_Msg_Count           NUMBER;
    l_Msg_Data            VARCHAR2(1000);
    l_copy_exists         NUMBER := 0;
    l_rule_length         NUMBER := 0;
    l_rule_suffix         VARCHAR2(200);
    v_selection_criteria_id NUMBER;
    x_selection_criteria_id NUMBER;
    x_entity_routing_id     NUMBER;
    x_mapping_id	    NUMBER;
    x_attr_value_id         NUMBER;
    v_dummy                 NUMBER;
    l_parent_rule_id_tbl    NUMBER_TABLE;
    l_parent_rule_id_index  NUMBER :=1;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT COPY_PROCESS_RULE_PVT;

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
      IF (AS_DEBUG_HIGH_ON) THEN

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
              FND_MESSAGE.Set_Name('PV', 'UT_CANNOT_GET_PROFILE_VALUE');
              FND_MESSAGE.Set_Token('PROFILE', 'USER_ID', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Debug message
      IF (AS_DEBUG_HIGH_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'Private API: Validate_process_rule');
      END IF;

      -- Invoke validation procedures
      Validate_process_rule(
          p_init_msg_list    => FND_API.G_FALSE,
          p_validation_level => p_validation_level,
          p_validation_mode  => AS_UTILITY_PVT.G_CREATE,
          P_PROCESS_RULE_Rec  =>  P_PROCESS_RULE_Rec,
          x_return_status    => x_return_status,
          x_msg_count        => x_msg_count,
          x_msg_data         => x_msg_data);

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      FOR V_Get_parent_process_rules IN C_Get_parent_process_rules(P_PROCESS_RULE_Rec.Process_Rule_Id) LOOP
       if C_Get_parent_process_rules%found then

         if l_parent_rule_id_tbl.count > 0 then
           V_Get_parent_process_rules.parent_rule_id := l_parent_rule_id_tbl(2);
	   V_Get_parent_process_rules.last_update_date       := null;
	   V_Get_parent_process_rules.last_updated_by        := null;
	   V_Get_parent_process_rules.creation_date          := null;
	   V_Get_parent_process_rules.created_by	     := null;
	   V_Get_parent_process_rules.last_update_login	     := null;
	   V_Get_parent_process_rules.object_version_number  := null;
	 else
	   V_Get_parent_process_rules.process_rule_name := P_PROCESS_RULE_Rec.process_rule_name;
	   V_Get_parent_process_rules.description	:= P_PROCESS_RULE_Rec.description;
	   V_Get_parent_process_rules.status_code       := P_PROCESS_RULE_Rec.status_code;
	   V_Get_parent_process_rules.start_date        := P_PROCESS_RULE_Rec.start_date;
	   V_Get_parent_process_rules.end_date          := P_PROCESS_RULE_Rec.end_date;
	   V_Get_parent_process_rules.rank              := P_PROCESS_RULE_Rec.rank;
	   V_Get_parent_process_rules.owner_resource_id := P_PROCESS_RULE_Rec.owner_resource_id;
	   V_Get_parent_process_rules.currency_code     := P_PROCESS_RULE_Rec.currency_code;

	   V_Get_parent_process_rules.last_update_date       := null;
	   V_Get_parent_process_rules.last_updated_by        := null;
	   V_Get_parent_process_rules.creation_date          := null;
	   V_Get_parent_process_rules.created_by	     := null;
	   V_Get_parent_process_rules.last_update_login	     := null;
	   V_Get_parent_process_rules.object_version_number  := null;
	 end if;

  PV_PROCESS_RULE_PVT.Create_process_rule(p_api_version_number,p_Init_Msg_List,p_Commit,p_validation_level,
                                          P_Identity_Resource_Id,V_Get_parent_process_rules,
                                          x_PROCESS_RULE_ID,x_Return_Status,x_Msg_Count,x_Msg_Data);

         l_parent_rule_id_index := l_parent_rule_id_index+1;
	 l_parent_rule_id_tbl(l_parent_rule_id_index) := x_PROCESS_RULE_ID;
         V_Get_parent_process_rules.parent_rule_id := l_parent_rule_id_tbl(2);


  if l_parent_rule_id_index > 2 then

         FOR V_Get_enty_select_criteria IN C_Get_enty_select_criteria(V_Get_parent_process_rules.process_rule_id) LOOP
	   if C_Get_enty_select_criteria%found then
	     V_Get_enty_select_criteria.process_rule_id := x_PROCESS_RULE_ID;
	     v_selection_criteria_id := V_Get_enty_select_criteria.SELECTION_CRITERIA_ID;
	     V_Get_enty_select_criteria.SELECTION_CRITERIA_ID := null;
	     PV_SELCRIT_PVT.Create_selcrit(p_api_version_number,p_Init_Msg_List,p_Commit,p_validation_level,
                                           P_Identity_Resource_Id,V_Get_enty_select_criteria,x_selection_criteria_id,x_Return_Status,
				           x_Msg_Count,x_Msg_Data);

         FOR V_Get_selected_attr_values IN C_Get_selected_attr_values(v_selection_criteria_id) LOOP
	   if C_Get_selected_attr_values%found then
	     V_Get_selected_attr_values.SELECTION_CRITERIA_ID := x_selection_criteria_id;
	     V_Get_selected_attr_values.ATTR_VALUE_ID := null;
	     PV_SELATTVAL_PVT.Create_selattval(p_api_version_number,
	                                       p_Init_Msg_List,
	                                       p_Commit,
					       p_validation_level,
                                               P_Identity_Resource_Id,
					       V_Get_selected_attr_values,
					       x_attr_value_id,
					       x_Return_Status,
				               x_Msg_Count,
					       x_Msg_Data);

	   end if;
	 END LOOP;


	   end if;
	 END LOOP;
	 x_PROCESS_RULE_ID := l_parent_rule_id_tbl(2);

	 else

	 FOR V_Get_enty_select_criteria IN C_Get_enty_select_criteria(P_PROCESS_RULE_Rec.Process_Rule_Id) LOOP
	   if C_Get_enty_select_criteria%found then
	     V_Get_enty_select_criteria.process_rule_id := x_PROCESS_RULE_ID;
	     v_selection_criteria_id := V_Get_enty_select_criteria.SELECTION_CRITERIA_ID;
	     V_Get_enty_select_criteria.SELECTION_CRITERIA_ID := null;
	     PV_SELCRIT_PVT.Create_selcrit(p_api_version_number,p_Init_Msg_List,p_Commit,p_validation_level,
                                           P_Identity_Resource_Id,V_Get_enty_select_criteria,x_selection_criteria_id,x_Return_Status,
				           x_Msg_Count,x_Msg_Data);

         FOR V_Get_selected_attr_values IN C_Get_selected_attr_values(v_selection_criteria_id) LOOP
	   if C_Get_selected_attr_values%found then
	     V_Get_selected_attr_values.SELECTION_CRITERIA_ID := x_selection_criteria_id;
	     V_Get_selected_attr_values.ATTR_VALUE_ID := null;
	     PV_SELATTVAL_PVT.Create_selattval(p_api_version_number,p_Init_Msg_List,p_Commit,p_validation_level,
                                               P_Identity_Resource_Id,V_Get_selected_attr_values,x_attr_value_id,x_Return_Status,
				               x_Msg_Count,x_Msg_Data);

	   end if;
	 END LOOP;

	   end if;
	 END LOOP;

  end if;

  FOR V_Get_entity_attr_mappings IN C_Get_entity_attr_mappings(P_PROCESS_RULE_Rec.Process_Rule_Id) LOOP
	   if C_Get_entity_attr_mappings%found then
	     V_Get_entity_attr_mappings.process_rule_id := x_PROCESS_RULE_ID;
	     V_Get_entity_attr_mappings.MAPPING_ID := null;
	     PV_ENTYATTMAP_PVT.Create_entyattmap(p_api_version_number,p_Init_Msg_List,p_Commit,p_validation_level,
                                                 P_Identity_Resource_Id,V_Get_entity_attr_mappings,x_mapping_id,x_Return_Status,
						 x_Msg_Count,x_Msg_Data);
	   end if;
	 END LOOP;

	 FOR V_Get_entity_routings IN C_Get_entity_routings(P_PROCESS_RULE_Rec.Process_Rule_Id) LOOP
	   if C_Get_entity_routings%found then
	     V_Get_entity_routings.process_rule_id := x_PROCESS_RULE_ID;
	     V_Get_entity_routings.ENTITY_ROUTING_ID := null;
	     PV_ENTYROUT_PVT.Create_entyrout(p_api_version_number,p_Init_Msg_List,p_Commit,p_validation_level,
                                             P_Identity_Resource_Id,V_Get_entity_routings,x_entity_routing_id,x_Return_Status,
					     x_Msg_Count,x_Msg_Data);
	   end if;
	 END LOOP;

       end if;
      END LOOP;

         --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      IF (AS_DEBUG_HIGH_ON) THEN

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
End Copy_process_rule;

-- Item-level validation procedures
PROCEDURE Validate_PROCESS_RULE_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PROCESS_RULE_ID            IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
  CURSOR C_Process_Rule_Id_Exists (c_process_rule_id NUMBER) IS
      SELECT 'X'
      FROM  pv_process_rules_b
      WHERE process_rule_id = c_process_rule_id;

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
          IF (p_process_rule_id IS NOT NULL) AND
             (p_process_rule_id <> FND_API.G_MISS_NUM)
          THEN
              OPEN  C_Process_Rule_Id_Exists (p_process_rule_id);
              FETCH C_Process_Rule_Id_Exists into l_val;

              IF C_Process_Rule_Id_Exists%NOTFOUND
              THEN
                  AS_UTILITY_PVT.Set_Message(
                      p_msg_level => FND_MSG_PUB.G_MSG_LVL_ERROR,
                      p_msg_name => 'API_INVALID_ID',
                      p_token1 => 'COLUMN',
                      p_token1_value => 'PROCESS_RULE_ID',
                      p_token2 => 'VALUE',
                      p_token2_value => p_process_rule_id);

                  x_return_status := FND_API.G_RET_STS_ERROR;
              END IF;
              CLOSE C_Process_Rule_Id_Exists ;
          END IF;

      ELSIF(p_validation_mode = AS_UTILITY_PVT.G_UPDATE)
      THEN
          -- validate NOT NULL column
          IF (p_process_rule_id IS NULL) OR
             (p_process_rule_id = FND_API.G_MISS_NUM)
          THEN
              AS_UTILITY_PVT.Set_Message(
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'API_MISSING_ID',
                  p_token1        => 'COLUMN',
                  p_token1_value  => 'PROCESS_RULE_ID');

              x_return_status := FND_API.G_RET_STS_ERROR;
          ELSE
              OPEN  C_Process_Rule_Id_Exists (p_process_rule_id);
              FETCH C_Process_Rule_Id_Exists into l_val;

              IF C_Process_Rule_Id_Exists%NOTFOUND
              THEN
                  AS_UTILITY_PVT.Set_Message(
                      p_msg_level => FND_MSG_PUB.G_MSG_LVL_ERROR,
                      p_msg_name => 'API_INVALID_ID',
                      p_token1 => 'COLUMN',
                      p_token1_value => 'PROCESS_RULE_ID',
                      p_token2 => 'VALUE',
                      p_token2_value => p_process_rule_id);

                  x_return_status := FND_API.G_RET_STS_ERROR;
              END IF;

              CLOSE C_Process_Rule_Id_Exists;
          END IF;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PROCESS_RULE_ID;


PROCEDURE Validate_OWNER_RESOURCE_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_OWNER_RESOURCE_ID          IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
    Cursor C_Check_Resource_Id (C_Resource_Id NUMBER) IS
      SELECT 'X'
      FROM   jtf_rs_resource_extns res
      WHERE  res.resource_id = c_resource_id;

    l_val VARCHAR2(1);
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Validate RESOURCE_ID
      IF (p_owner_resource_id IS NOT NULL
          AND p_owner_resource_id <> FND_API.G_MISS_NUM)
      THEN
          OPEN C_Check_Resource_Id (p_owner_resource_id);
          FETCH C_Check_Resource_Id INTO l_val;
          IF (C_Check_Resource_Id%NOTFOUND)
          THEN
              AS_UTILITY_PVT.Set_Message(
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'API_INVALID_ID',
                  p_token1        => 'COLUMN',
                  p_token1_value  => 'OWNER_RESOURCE_ID',
                  p_token2        => 'VALUE',
                  p_token2_value  =>  p_OWNER_RESOURCE_ID );

              x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
          CLOSE C_Check_Resource_Id;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_OWNER_RESOURCE_ID;


PROCEDURE Validate_CURRENCY_CODE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_CURRENCY_CODE              IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
    CURSOR C_Currency_Exists (C_Currency_Code VARCHAR2) IS
      SELECT  'X'
      FROM  fnd_currencies
      WHERE currency_code = C_Currency_Code
            and nvl(start_date_active, sysdate) <= sysdate
            and nvl(end_date_active, sysdate) >= sysdate
            and enabled_flag = 'Y';

    l_val VARCHAR2(1);
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Validate Currency Code
      IF (p_currency_code is NOT NULL
          AND p_currency_code <> FND_API.G_MISS_CHAR)
      THEN
         OPEN C_Currency_Exists ( p_currency_code );
         FETCH C_Currency_Exists into l_val;
         IF C_Currency_Exists%NOTFOUND THEN
            AS_UTILITY_PVT.Set_Message(
                p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                p_msg_name      => 'API_INVALID_ID',
                p_token1        => 'COLUMN',
                p_token1_value  => 'CURRENCY',
                p_token2        => 'VALUE',
                p_token2_value  =>  p_CURRENCY_CODE );

            x_return_status := FND_API.G_RET_STS_ERROR;
         END IF;
         CLOSE C_Currency_Exists;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_CURRENCY_CODE;

PROCEDURE Validate_RANK (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_Parent_Rule_ID             IN   NUMBER,
    P_Child_Rule_ID              IN   NUMBER,
    P_RANK                       IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
   -- pklin
   cursor lc_chk_criterion_dups (pc_parent_rule_id number,
                                 pc_child_rule_id  number,
                                 pc_rank           number) is
      SELECT child.rank
      FROM   pv_process_rules_vl parent,
             pv_process_rules_vl child
      WHERE  parent.process_rule_id = pc_parent_rule_id AND
             parent.process_rule_id = child.parent_rule_id AND
             child.process_rule_id <> NVL(pc_child_rule_id, 0) AND
	     child.rank = pc_rank;

   l_rank NUMBER;

BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_validation_mode = AS_UTILITY_PVT.G_CREATE OR
          p_validation_mode = AS_UTILITY_PVT.G_UPDATE)
      THEN
          IF (p_rank IS NULL) OR (p_rank = FND_API.G_MISS_NUM) THEN
                  AS_UTILITY_PVT.Set_Message(
                      p_msg_level => FND_MSG_PUB.G_MSG_LVL_ERROR,
                      p_msg_name => 'API_MISSING_RANK',
                      p_token1 => 'RANK',
                      p_token1_value => p_rank);

                  x_return_status := FND_API.G_RET_STS_ERROR;

	  -- -------------------------------------------------------------------------
          -- Check for the duplicate criteria, which are criteria with the same rank
	  -- (Order of Evaluation).
	  -- -------------------------------------------------------------------------
          ELSE
             OPEN lc_chk_criterion_dups(P_Parent_Rule_ID, P_Child_Rule_ID, P_Rank);
             Fetch lc_chk_criterion_dups into l_rank;

	     IF (lc_chk_criterion_dups%FOUND) THEN
                FND_MESSAGE.Set_Name('PV', 'PV_DUPLICATE_CRITERION');
                FND_MSG_PUB.Add;

		CLOSE lc_chk_criterion_dups;
                RAISE FND_API.G_EXC_ERROR;
             END IF;

             -- Debug Message
             IF (AS_DEBUG_HIGH_ON) THEN

             AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'Private API: - Close Cursor');
             END IF;
             CLOSE lc_chk_criterion_dups;
          END IF;
       END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_Rank;


PROCEDURE Validate_enddate(
    P_Init_Msg_List        IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode      IN   VARCHAR2,
    P_START_DATE           IN   DATE,
    P_END_DATE             IN   DATE,
    X_Return_Status        OUT NOCOPY  VARCHAR2,
    X_Msg_Count            OUT NOCOPY  NUMBER,
    X_Msg_Data             OUT NOCOPY  VARCHAR2
    )
IS
l_api_name   CONSTANT VARCHAR2(30) := 'Validate_end_date';
 BEGIN
     -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_validation_mode = AS_UTILITY_PVT.G_CREATE OR
          p_validation_mode = AS_UTILITY_PVT.G_UPDATE)
      THEN
         IF (P_START_DATE is not null and P_END_DATE is not null)
	 THEN
	    IF P_END_DATE < P_START_DATE
	    THEN
	       FND_MESSAGE.Set_Name('PV', 'PV_END_DATE_GREATER_START_DATE');
                FND_MSG_PUB.Add;
                RAISE FND_API.G_EXC_ERROR;
            END IF;
	 END IF;
             -- Debug Message
             IF (AS_DEBUG_HIGH_ON) THEN
             AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'Private API: - Close Cursor');
             END IF;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
END Validate_enddate;

PROCEDURE Validate_startdate(
    P_Init_Msg_List        IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode      IN   VARCHAR2,
    P_Parent_Rule_ID       IN   NUMBER,
    P_START_DATE           IN   DATE,
    X_Return_Status        OUT NOCOPY  VARCHAR2,
    X_Msg_Count            OUT NOCOPY  NUMBER,
    X_Msg_Data             OUT NOCOPY  VARCHAR2
    )
IS
   l_api_name   CONSTANT VARCHAR2(30) := 'Validate_start_date';

BEGIN
     -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_validation_mode = AS_UTILITY_PVT.G_CREATE OR p_validation_mode = AS_UTILITY_PVT.G_UPDATE)
      THEN
         IF (P_PARENT_RULE_ID is null or P_PARENT_RULE_ID = FND_API.G_MISS_NUM) then
	   IF (P_START_DATE is null or P_START_DATE = FND_API.G_MISS_DATE) then
             FND_MESSAGE.Set_Name('PV', 'PV_STARTDATE_NOTNULL');
             FND_MSG_PUB.Add;
             RAISE FND_API.G_EXC_ERROR;
           END IF;
         END IF;
	   IF (AS_DEBUG_HIGH_ON) THEN
             AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'Private API: - Close Cursor');
           END IF;
      END IF;
-- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
END Validate_startdate;

-- ------------------------------------------------------------------------------
--  Validate_status
-- ------------------------------------------------------------------------------
PROCEDURE Validate_status(
    P_Init_Msg_List        IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode      IN   VARCHAR2,
    P_Parent_Rule_ID       IN   NUMBER,
    P_STATUS               IN   VARCHAR2,
    X_Return_Status        OUT NOCOPY  VARCHAR2,
    X_Msg_Count            OUT NOCOPY  NUMBER,
    X_Msg_Data             OUT NOCOPY  VARCHAR2
    )
IS
   l_api_name   CONSTANT VARCHAR2(30) := 'Validate_status';
   l_previous_status     VARCHAR2(30);
   l_result              VARCHAR2(1);

   CURSOR lc_check_rule_reference IS
      SELECT 'x' result
      FROM   fnd_profile_options a,
             fnd_profile_option_values b
      WHERE  a.profile_option_id    = b.profile_option_id AND
             a.profile_option_name  = 'PV_AUTO_MATCHING_RULE' AND
             b.application_id       = 691 AND
             b.profile_option_value = TO_CHAR(p_parent_rule_id);

BEGIN

     -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_validation_mode = AS_UTILITY_PVT.G_CREATE OR p_validation_mode = AS_UTILITY_PVT.G_UPDATE)
      THEN
	 IF (P_PARENT_RULE_ID is null or P_PARENT_RULE_ID = FND_API.G_MISS_NUM) then
	   IF (P_STATUS is null or P_STATUS = FND_API.G_MISS_CHAR) then
             FND_MESSAGE.Set_Name('PV', 'PV_STATUS_NOTNULL');
             FND_MSG_PUB.Add;
             RAISE FND_API.G_EXC_ERROR;
           END IF;
         END IF;
	   IF (AS_DEBUG_HIGH_ON) THEN
             AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'Private API: - Close Cursor');
           END IF;
      END IF;

      -- ---------------------------------------------------------------------
      -- Status check for LEAD_MONITOR rules. This is checked only in the case
      -- of an update.
      -- The requirements of LEAD_MONITOR rules are such that when the status
      -- of the rule is 'ACTIVE', nothing on the html page is updatable.
      -- ---------------------------------------------------------------------
      IF (G_PROCESS_TYPE = 'LEAD_MONITOR' AND G_ACTION = 'UPDATE' AND
          p_status = 'ACTIVE') THEN
             -- --------------------------------------------------------------
             -- Check the database for the "before" image. We need to compare
             -- the before image to the after image.
             -- --------------------------------------------------------------
             FOR x IN (SELECT status_code FROM pv_process_rules_b
                       WHERE  process_rule_id = p_parent_rule_id)
             LOOP
                l_previous_status := x.status_code;
             END LOOP;

             IF (l_previous_status = 'ACTIVE') THEN
                FND_MESSAGE.Set_Name('PV', 'PV_MONITOR_RULE_ACTIVE');
                FND_MSG_PUB.Add;
                RAISE FND_API.G_EXC_ERROR;
             END IF;

      ELSIF (G_PROCESS_TYPE = 'PARTNER_MATCHING' AND G_ACTION = 'UPDATE' AND
             p_status <> 'ACTIVE')
      THEN
         FOR x IN lc_check_rule_reference LOOP
            l_result := x.result;
         END LOOP;

         IF l_result IS NOT NULL THEN
                FND_MESSAGE.Set_Name('PV', 'PV_RULE_REF_BY_PROFILE_STATUS');
                FND_MSG_PUB.Add;
                RAISE FND_API.G_EXC_ERROR;
         END IF;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
END Validate_status;



PROCEDURE Validate_process_rule(
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    P_Validation_mode            IN   VARCHAR2,
    P_PROCESS_RULE_Rec           IN   PV_RULE_RECTYPE_PUB.RULES_REC_TYPE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
l_api_name   CONSTANT VARCHAR2(30) := 'Validate_process_rule';
 BEGIN

      -- Debug Message
      IF (AS_DEBUG_HIGH_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_validation_level >= AS_UTILITY_PUB.G_VALID_LEVEL_ITEM) THEN
          -- Hint: We provide validation procedure for every column. Developer should delete
          --       unnecessary validation procedures.
          Validate_PROCESS_RULE_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_PROCESS_RULE_ID   => P_PROCESS_RULE_Rec.PROCESS_RULE_ID,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          PV_COMMON_CHECKS_PVT.Validate_OBJECT_VERSION_NUMBER(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_OBJECT_VERSION_NUMBER   => P_PROCESS_RULE_Rec.OBJECT_VERSION_NUMBER,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          PV_COMMON_CHECKS_PVT.Validate_Lookup(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_TABLE_NAME             => 'PV_PROCESS_RULES_B',
              p_COLUMN_NAME            => 'PROCESS_TYPE',
              p_LOOKUP_TYPE            => 'PV_PROCESS_TYPE',
              p_LOOKUP_CODE            => P_PROCESS_RULE_Rec.PROCESS_TYPE,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

		if p_PROCESS_RULE_Rec.STATUS_CODE is NOT NULL and
		   p_PROCESS_RULE_Rec.STATUS_CODE <> FND_API.G_MISS_CHAR then

             PV_COMMON_CHECKS_PVT.Validate_Lookup(
                 p_init_msg_list          => FND_API.G_FALSE,
                 p_validation_mode        => p_validation_mode,
                 p_TABLE_NAME             => 'PV_PROCESS_RULES_B',
                 p_COLUMN_NAME            => 'STATUS_CODE',
                 p_LOOKUP_TYPE            => 'PV_RULE_STATUS_CODE',
                 p_LOOKUP_CODE            => P_PROCESS_RULE_Rec.STATUS_CODE,
                 x_return_status          => x_return_status,
                 x_msg_count              => x_msg_count,
                 x_msg_data               => x_msg_data);
             IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                 raise FND_API.G_EXC_ERROR;
             END IF;

		end if;

          Validate_OWNER_RESOURCE_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_OWNER_RESOURCE_ID   => P_PROCESS_RULE_Rec.OWNER_RESOURCE_ID,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_CURRENCY_CODE(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_CURRENCY_CODE   => P_PROCESS_RULE_Rec.CURRENCY_CODE,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

/*
	  Validate_RANK(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              P_Parent_Rule_ID         => p_PROCESS_RULE_rec.PARENT_RULE_ID,
              P_Child_Rule_ID          => p_CHILD_RULE_ID,
              p_RANK    	       => P_PROCESS_RULE_Rec.RANK,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;
*/
      END IF;

      -- Debug Message
      IF (AS_DEBUG_HIGH_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'end');
      END IF;

END Validate_process_rule;

End PV_PROCESS_RULE_PVT;

/
