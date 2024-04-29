--------------------------------------------------------
--  DDL for Package Body PV_SELCRIT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_SELCRIT_PVT" as
/* $Header: pvrvescb.pls 115.9 2004/06/07 22:45:20 solin ship $ */
-- Start of Comments
-- Package name     : PV_SELCRIT_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'PV_SELCRIT_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'pvrvescb.pls';


-- Hint: Primary key needs to be returned.
AS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Create_selcrit(
    P_Api_Version_Number       IN   NUMBER,
    P_Init_Msg_List            IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                   IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level         IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Identity_Resource_Id     IN   NUMBER,
    P_SELCRIT_Rec              IN   PV_RULE_RECTYPE_PUB.SELCRIT_Rec_Type
                                 := PV_RULE_RECTYPE_PUB.G_MISS_SELCRIT_REC,
    X_SELECTION_CRITERIA_ID    OUT NOCOPY  NUMBER,
    X_Return_Status            OUT NOCOPY  VARCHAR2,
    X_Msg_Count                OUT NOCOPY  NUMBER,
    X_Msg_Data                 OUT NOCOPY  VARCHAR2
    )
 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Create_selcrit';
l_api_version_number      CONSTANT NUMBER   := 2.0;
l_return_status_full        VARCHAR2(1);
l_access_flag               VARCHAR2(1);
l_previous_status	    VARCHAR2(30);
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_SELCRIT_PVT;

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

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'Private API: Validate_selcrit');
      END IF;

      -- Invoke validation procedures
      Validate_selcrit(
          p_init_msg_list    => FND_API.G_FALSE,
          p_validation_level => p_validation_level,
          p_validation_mode  => AS_UTILITY_PVT.G_CREATE,
          P_SELCRIT_Rec      => P_SELCRIT_Rec,
          x_return_status    => x_return_status,
          x_msg_count        => x_msg_count,
          x_msg_data         => x_msg_data);

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Hint: Add corresponding Master-Detail business logic here if necessary.

       -- ---------------------------------------------------------------------
      -- Status check for LEAD_MONITOR rules. This is checked only in the case
      -- of an Create.
      -- The requirements of LEAD_MONITOR rules are such that when the status
      -- of the rule is 'ACTIVE', nothing on the html page is updatable.
      -- ---------------------------------------------------------------------
      IF (p_SELCRIT_REC.SELECTION_TYPE_CODE = 'MONITOR_SCOPE') THEN
             -- --------------------------------------------------------------
             -- Check the database for the "before" image. We need to compare
             -- the before image to the after image.
             -- --------------------------------------------------------------
             FOR x IN (SELECT status_code FROM pv_process_rules_b
                       WHERE  process_rule_id = p_SELCRIT_rec.PROCESS_RULE_ID)
             LOOP
                l_previous_status := x.status_code;
             END LOOP;

             IF (l_previous_status = 'ACTIVE') THEN
                FND_MESSAGE.Set_Name('PV', 'PV_MONITOR_RULE_ACTIVE');
                FND_MSG_PUB.Add;
                RAISE FND_API.G_EXC_ERROR;
             END IF;
       END IF;

      -- Debug Message
      IF (AS_DEBUG_HIGH_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Calling create table handler');
      END IF;

      -- Invoke table handler(PV_ENTY_SELECT_CRITERIA_PKG.Insert_Row)
      PV_ENTY_SELECT_CRITERIA_PKG.Insert_Row(
          px_SELECTION_CRITERIA_ID  => x_SELECTION_CRITERIA_ID
         ,p_LAST_UPDATE_DATE  => SYSDATE
         ,p_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID
         ,p_CREATION_DATE  => SYSDATE
         ,p_CREATED_BY  => FND_GLOBAL.USER_ID
         ,p_LAST_UPDATE_LOGIN  => FND_GLOBAL.CONC_LOGIN_ID
         ,p_OBJECT_VERSION_NUMBER  => p_SELCRIT_rec.OBJECT_VERSION_NUMBER
         ,p_REQUEST_ID  => p_SELCRIT_rec.REQUEST_ID
         ,p_PROGRAM_APPLICATION_ID  => p_SELCRIT_rec.PROGRAM_APPLICATION_ID
         ,p_PROGRAM_ID  => p_SELCRIT_rec.PROGRAM_ID
         ,p_PROGRAM_UPDATE_DATE  => p_SELCRIT_rec.PROGRAM_UPDATE_DATE
         ,p_PROCESS_RULE_ID  => p_SELCRIT_rec.PROCESS_RULE_ID
         ,p_ATTRIBUTE_ID  => p_SELCRIT_rec.ATTRIBUTE_ID
         ,p_SELECTION_TYPE_CODE  => p_SELCRIT_rec.SELECTION_TYPE_CODE
         ,p_OPERATOR  => p_SELCRIT_rec.OPERATOR
         ,p_RANK  => p_SELCRIT_rec.RANK
         ,p_ATTRIBUTE_CATEGORY  => p_SELCRIT_rec.ATTRIBUTE_CATEGORY
         ,p_ATTRIBUTE1  => p_SELCRIT_rec.ATTRIBUTE1
         ,p_ATTRIBUTE2  => p_SELCRIT_rec.ATTRIBUTE2
         ,p_ATTRIBUTE3  => p_SELCRIT_rec.ATTRIBUTE3
         ,p_ATTRIBUTE4  => p_SELCRIT_rec.ATTRIBUTE4
         ,p_ATTRIBUTE5  => p_SELCRIT_rec.ATTRIBUTE5
         ,p_ATTRIBUTE6  => p_SELCRIT_rec.ATTRIBUTE6
         ,p_ATTRIBUTE7  => p_SELCRIT_rec.ATTRIBUTE7
         ,p_ATTRIBUTE8  => p_SELCRIT_rec.ATTRIBUTE8
         ,p_ATTRIBUTE9  => p_SELCRIT_rec.ATTRIBUTE9
         ,p_ATTRIBUTE10  => p_SELCRIT_rec.ATTRIBUTE10
         ,p_ATTRIBUTE11  => p_SELCRIT_rec.ATTRIBUTE11
         ,p_ATTRIBUTE12  => p_SELCRIT_rec.ATTRIBUTE12
         ,p_ATTRIBUTE13  => p_SELCRIT_rec.ATTRIBUTE13
         ,p_ATTRIBUTE14  => p_SELCRIT_rec.ATTRIBUTE14
         ,p_ATTRIBUTE15  => p_SELCRIT_rec.ATTRIBUTE15
);      -- Hint: Primary key should be returned.
      -- x_SELECTION_CRITERIA_ID := px_SELECTION_CRITERIA_ID;

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
End Create_selcrit;


-- Hint: Add corresponding update detail table procedures if it's master-detail relationship.
PROCEDURE Update_selcrit(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Identity_Resource_Id       IN   NUMBER,
    P_SELCRIT_Rec                IN   PV_RULE_RECTYPE_PUB.SELCRIT_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS

Cursor C_Get_selcrit(pc_SELECTION_CRITERIA_ID Number) IS
    Select object_version_number
    From  PV_ENTY_SELECT_CRITERIA
    where selection_criteria_id = pc_selection_criteria_id
    For Update NOWAIT;

l_api_name                CONSTANT VARCHAR2(30) := 'Update_selcrit';
l_api_version_number      CONSTANT NUMBER   := 2.0;
l_previous_status	  VARCHAR2(30);
-- Local Variables
l_ref_SELCRIT_rec  PV_RULE_RECTYPE_PUB.SELCRIT_Rec_Type;
l_tar_SELCRIT_rec  PV_RULE_RECTYPE_PUB.SELCRIT_Rec_Type := P_SELCRIT_Rec;
l_rowid  ROWID;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_SELCRIT_PVT;

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

      Open C_Get_selcrit( l_tar_SELCRIT_rec.SELECTION_CRITERIA_ID);
      Fetch C_Get_selcrit into
               l_ref_SELCRIT_rec.object_version_number;

       If ( C_Get_selcrit%NOTFOUND) Then
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
               FND_MESSAGE.Set_Name('PV', 'API_MISSING_UPDATE_TARGET');
               FND_MESSAGE.Set_Token ('INFO', 'selcrit', FALSE);
               FND_MSG_PUB.Add;
           END IF;
           Close C_Get_selcrit;
           raise FND_API.G_EXC_ERROR;
       END IF;
       -- Debug Message
       IF (AS_DEBUG_HIGH_ON) THEN

       AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'Private API: - Close Cursor');
       END IF;
       Close     C_Get_selcrit;

      If (l_tar_SELCRIT_rec.object_version_number is NULL or
          l_tar_SELCRIT_rec.object_version_number = FND_API.G_MISS_NUM ) Then
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('PV', 'API_MISSING_ID');
              FND_MESSAGE.Set_Token('COLUMN', 'object_version_number', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          raise FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      If (l_tar_SELCRIT_rec.object_version_number <> l_ref_SELCRIT_rec.object_version_number) Then
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('PV', 'API_RECORD_CHANGED');
              FND_MESSAGE.Set_Token('INFO', 'selcrit', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          raise FND_API.G_EXC_ERROR;
      End if;

      -- Debug message
      IF (AS_DEBUG_HIGH_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'Private API: Validate_selcrit');
      END IF;

      -- Invoke validation procedures
      Validate_selcrit(
          p_init_msg_list    => FND_API.G_FALSE,
          p_validation_level => p_validation_level,
          p_validation_mode  => AS_UTILITY_PVT.G_UPDATE,
          P_SELCRIT_Rec      =>  P_SELCRIT_Rec,
          x_return_status    => x_return_status,
          x_msg_count        => x_msg_count,
          x_msg_data         => x_msg_data);

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Hint: Add corresponding Master-Detail business logic here if necessary.

    -- ---------------------------------------------------------------------
      -- Status check for LEAD_MONITOR rules. This is checked only in the case
      -- of an update.
      -- The requirements of LEAD_MONITOR rules are such that when the status
      -- of the rule is 'ACTIVE', nothing on the html page is updatable.
      -- ---------------------------------------------------------------------
      IF (p_SELCRIT_REC.SELECTION_TYPE_CODE = 'MONITOR_SCOPE') THEN
             -- --------------------------------------------------------------
             -- Check the database for the "before" image. We need to compare
             -- the before image to the after image.
             -- --------------------------------------------------------------
             FOR x IN (SELECT status_code FROM pv_process_rules_b
                       WHERE  process_rule_id = p_SELCRIT_rec.PROCESS_RULE_ID)
             LOOP
                l_previous_status := x.status_code;
             END LOOP;

             IF (l_previous_status = 'ACTIVE') THEN
                FND_MESSAGE.Set_Name('PV', 'PV_MONITOR_RULE_ACTIVE');
                FND_MSG_PUB.Add;
                RAISE FND_API.G_EXC_ERROR;
             END IF;
       END IF;



      -- Debug Message
      IF (AS_DEBUG_HIGH_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Calling update table handler');
      END IF;

      -- Invoke table handler(PV_ENTY_SELECT_CRITERIA_PKG.Update_Row)
      PV_ENTY_SELECT_CRITERIA_PKG.Update_Row(
          p_SELECTION_CRITERIA_ID  => p_SELCRIT_rec.SELECTION_CRITERIA_ID
         ,p_LAST_UPDATE_DATE  => SYSDATE
         ,p_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID
         ,p_CREATION_DATE  => FND_API.G_MISS_DATE
         ,p_CREATED_BY     => FND_API.G_MISS_NUM
         ,p_LAST_UPDATE_LOGIN  => FND_GLOBAL.CONC_LOGIN_ID
         ,p_OBJECT_VERSION_NUMBER  => p_SELCRIT_rec.OBJECT_VERSION_NUMBER
         ,p_REQUEST_ID  => p_SELCRIT_rec.REQUEST_ID
         ,p_PROGRAM_APPLICATION_ID  => p_SELCRIT_rec.PROGRAM_APPLICATION_ID
         ,p_PROGRAM_ID  => p_SELCRIT_rec.PROGRAM_ID
         ,p_PROGRAM_UPDATE_DATE  => p_SELCRIT_rec.PROGRAM_UPDATE_DATE
         ,p_PROCESS_RULE_ID  => p_SELCRIT_rec.PROCESS_RULE_ID
         ,p_ATTRIBUTE_ID  => p_SELCRIT_rec.ATTRIBUTE_ID
         ,p_SELECTION_TYPE_CODE  => p_SELCRIT_rec.SELECTION_TYPE_CODE
         ,p_OPERATOR  => p_SELCRIT_rec.OPERATOR
         ,p_RANK  => p_SELCRIT_rec.RANK
         ,p_ATTRIBUTE_CATEGORY  => p_SELCRIT_rec.ATTRIBUTE_CATEGORY
         ,p_ATTRIBUTE1  => p_SELCRIT_rec.ATTRIBUTE1
         ,p_ATTRIBUTE2  => p_SELCRIT_rec.ATTRIBUTE2
         ,p_ATTRIBUTE3  => p_SELCRIT_rec.ATTRIBUTE3
         ,p_ATTRIBUTE4  => p_SELCRIT_rec.ATTRIBUTE4
         ,p_ATTRIBUTE5  => p_SELCRIT_rec.ATTRIBUTE5
         ,p_ATTRIBUTE6  => p_SELCRIT_rec.ATTRIBUTE6
         ,p_ATTRIBUTE7  => p_SELCRIT_rec.ATTRIBUTE7
         ,p_ATTRIBUTE8  => p_SELCRIT_rec.ATTRIBUTE8
         ,p_ATTRIBUTE9  => p_SELCRIT_rec.ATTRIBUTE9
         ,p_ATTRIBUTE10  => p_SELCRIT_rec.ATTRIBUTE10
         ,p_ATTRIBUTE11  => p_SELCRIT_rec.ATTRIBUTE11
         ,p_ATTRIBUTE12  => p_SELCRIT_rec.ATTRIBUTE12
         ,p_ATTRIBUTE13  => p_SELCRIT_rec.ATTRIBUTE13
         ,p_ATTRIBUTE14  => p_SELCRIT_rec.ATTRIBUTE14
         ,p_ATTRIBUTE15  => p_SELCRIT_rec.ATTRIBUTE15
);      --
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
End Update_selcrit;


-- Hint: Add corresponding delete detail table procedures if it's master-detail relationship.
--       The Master delete procedure may not be needed depends on different business requirements.
PROCEDURE Delete_selcrit(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Identity_Resource_Id       IN   NUMBER,
    P_SELCRIT_Rec                IN   PV_RULE_RECTYPE_PUB.SELCRIT_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Delete_selcrit';
l_api_version_number      CONSTANT NUMBER   := 2.0;

cursor lc_value_rows(pc_criteria_id number) is
   select attr_value_id from pv_selected_attr_values
   where selection_criteria_id = pc_criteria_id;

l_SELATTVAL_rec  PV_RULE_RECTYPE_PUB.SELATTVAL_Rec_Type;

l_attr_value_id number;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_SELCRIT_PVT;

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

      begin

         open lc_value_rows (pc_criteria_id => p_SELCRIT_rec.SELECTION_CRITERIA_ID);
         loop

            fetch lc_value_rows into l_attr_value_id;
            exit when lc_value_rows%notfound;

            l_selattval_rec.attr_value_id := l_attr_value_id;

            PV_selattval_PVT.Delete_selattval(
               P_Api_Version_Number         => 2.0,
               P_Init_Msg_List              => FND_API.G_FALSE,
               P_Commit                     => p_commit,
               P_Validation_Level           => p_Validation_Level,
               P_Identity_Resource_Id       => P_Identity_Resource_Id,
               P_SELATTVAL_Rec              => l_SELATTVAL_Rec,
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
         close lc_value_rows;

      exception
      when others then
         close lc_value_rows;
         raise;
      end;

      -- Debug Message
      IF (AS_DEBUG_HIGH_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Private API: Calling PV_ENTY_SELECT_CRITERIA_PKG.Delete_Row');
      END IF;

      PV_ENTY_SELECT_CRITERIA_PKG.Delete_Row(
          p_SELECTION_CRITERIA_ID  => p_SELCRIT_rec.SELECTION_CRITERIA_ID);
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
End Delete_selcrit;


-- Item-level validation procedures
PROCEDURE Validate_SELECTION_CRITERIA_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_SELECTION_CRITERIA_ID      IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
  CURSOR C_selection_criteria_id_exists (pc_selection_criteria_id NUMBER) IS
      SELECT 'X'
      FROM  pv_enty_select_criteria
      WHERE selection_criteria_id = pc_selection_criteria_id;

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
          IF (p_selection_criteria_id IS NOT NULL) AND
             (p_selection_criteria_id <> FND_API.G_MISS_NUM)
          THEN
              AS_UTILITY_PVT.Set_Message(
                  p_msg_level    => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name     => 'API_INVALID_ID',
                  p_token1       => 'selection_criteria_id',
                  p_token1_value => p_selection_criteria_id);

              x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;

      ELSIF(p_validation_mode = AS_UTILITY_PVT.G_UPDATE)
      THEN
          -- validate NOT NULL column
          IF (p_selection_criteria_id IS NULL) OR
             (p_selection_criteria_id = FND_API.G_MISS_NUM)
          THEN
              AS_UTILITY_PVT.Set_Message(
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'API_MISSING_LEAD_ID');

              x_return_status := FND_API.G_RET_STS_ERROR;
          ELSE
              OPEN  C_selection_criteria_id_exists (p_selection_criteria_id);
              FETCH C_selection_criteria_id_exists into l_val;

              IF C_selection_criteria_id_exists%NOTFOUND
              THEN
                  AS_UTILITY_PVT.Set_Message(
                      p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                      p_msg_name      => 'API_INVALID_ID',
                      p_token1        => 'selection_criteria_id',
                      p_token1_value  => p_selection_criteria_id );

                  x_return_status := FND_API.G_RET_STS_ERROR;
              END IF;

              CLOSE C_selection_criteria_id_exists;
          END IF;
      END IF;


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_SELECTION_CRITERIA_ID;


PROCEDURE Validate_selcrit(
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    P_Validation_mode            IN   VARCHAR2,
    P_SELCRIT_Rec                IN   PV_RULE_RECTYPE_PUB.SELCRIT_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS

   -- ---------------------------------------------------------------------------
   -- Chandra added ('INPUT_FILTER', 'MONITOR_SCOPE')
   -- ---------------------------------------------------------------------------
   cursor lc_chk_input_filter_dups (pc_rule_id number, pc_attribute_id number) is
   select rule.process_rule_name, attr.name
   from
      pv_process_rules_vl rule, pv_attributes_vl attr, pv_enty_select_criteria crit
   where
      crit.process_rule_id         = pc_rule_id
      and crit.attribute_id        = pc_attribute_id
      and crit.selection_type_code IN ('INPUT_FILTER', 'MONITOR_SCOPE')
      and crit.process_rule_id     = rule.process_rule_id
      and crit.attribute_id        = attr.attribute_id;

   cursor lc_tie_break_operator (pc_lookup_code varchar2) is
   select lookup_code
   from pv_lookups where lookup_type = 'PV_TIE_BREAKING_OPERATOR'
   and lookup_code = pc_lookup_code;

   l_rule_name           varchar2(300);
   l_operator            varchar2(300);
   l_attribute_name      varchar2(300);
   l_api_name   CONSTANT VARCHAR2(30) := 'Validate_selcrit';
   l_rank                number;
   l_attribute_id        number;

 BEGIN

      -- Debug Message
      IF (AS_DEBUG_HIGH_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_validation_level >= AS_UTILITY_PUB.G_VALID_LEVEL_ITEM) THEN

          Validate_SELECTION_CRITERIA_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_SELECTION_CRITERIA_ID  => P_SELCRIT_Rec.SELECTION_CRITERIA_ID,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          pv_common_checks_pvt.Validate_OBJECT_VERSION_NUMBER(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_OBJECT_VERSION_NUMBER  => P_SELCRIT_Rec.OBJECT_VERSION_NUMBER,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          pv_common_checks_pvt.Validate_PROCESS_RULE_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_PROCESS_RULE_ID        => P_SELCRIT_Rec.PROCESS_RULE_ID,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          pv_common_checks_pvt.Validate_Lookup(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_TABLE_NAME             => 'PV_ENTY_SELECT_CRITERIA',
              p_COLUMN_NAME            => 'SELECTION_TYPE_CODE',
              p_lookup_type            => 'PV_SELECTION_TYPE_CODE',
              p_lookup_code            => P_SELCRIT_Rec.SELECTION_TYPE_CODE,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;


          --ryellapu - Additional checks to Rank and Attribute id to avoid any duplicate values

	  if p_SELCRIT_REC.SELECTION_TYPE_CODE = 'TIE_BREAKING' then
	     begin

	     if p_SELCRIT_REC.rank is null then
	        FND_MESSAGE.Set_Name('PV', 'PV_NULLCHECK_TIEBR_RANK');
                FND_MSG_PUB.Add;
                x_return_status := FND_API.G_RET_STS_ERROR;
                raise FND_API.G_EXC_ERROR;
	     end if;

	     select rank into l_rank from pv_enty_select_criteria
	       where process_rule_id = p_SELCRIT_REC.process_rule_id and
	             rank            = p_SELCRIT_REC.rank;

	     if l_rank is not null then
	        FND_MESSAGE.Set_Name('PV', 'PV_DUPLICATE_TIEBR_RANK');
                FND_MSG_PUB.Add;
                x_return_status := FND_API.G_RET_STS_ERROR;
                raise FND_API.G_EXC_ERROR;
             end if;
	     exception
	      when no_data_found then
	        null;
	      when others then
	        x_return_status := FND_API.G_RET_STS_ERROR;
	        raise FND_API.G_EXC_ERROR;
	     end;
	    end if;

	    if p_SELCRIT_REC.SELECTION_TYPE_CODE = 'TIE_BREAKING' then
             begin
	     select attribute_id into l_attribute_id from pv_enty_select_criteria
	       where process_rule_id = p_SELCRIT_REC.process_rule_id and
	             attribute_id    = p_SELCRIT_REC.attribute_id;

	     if (l_attribute_id is not null and p_validation_mode = AS_UTILITY_PVT.G_CREATE) then
	        FND_MESSAGE.Set_Name('PV', 'PV_DUPLICATE_TIEBR_ATTRIBUTE');
                FND_MSG_PUB.Add;
                x_return_status := FND_API.G_RET_STS_ERROR;
                raise FND_API.G_EXC_ERROR;
             end if;
	     exception
	      when no_data_found then
	      null;
	     end;
	  end if;


          if p_SELCRIT_REC.SELECTION_TYPE_CODE = 'TIE_BREAKING' then

             open lc_tie_break_operator( pc_lookup_code => p_SELCRIT_REC.OPERATOR);
             fetch lc_tie_break_operator into l_operator;
             close lc_tie_break_operator;

             if l_operator is NULL then

                pv_common_checks_pvt.Set_Message(
                    p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                    p_msg_name      => 'API_INVALID_CODE',
                    p_token1        => 'TABLE_NAME',
                    p_token1_value  => 'PV_ENTY_SELECT_CRITERIA',
                    p_token2        => 'COLUMN_NAME',
                    p_token2_value  => 'OPERATOR',
                    p_token3        => 'LOOKUP_TYPE',
                    p_token3_value  => 'PV_TIE_BREAKING_OPERATOR',
                    p_token4        => 'LOOKUP_CODE',
                    p_token4_value  => p_SELCRIT_REC.OPERATOR);

               x_return_status := FND_API.G_RET_STS_ERROR;
               raise FND_API.G_EXC_ERROR;

             end if;

          else

             pv_common_checks_pvt.Validate_OPERATOR(
                 p_init_msg_list          => FND_API.G_FALSE,
                 p_validation_mode        => p_validation_mode,
                 p_TABLE_NAME             => 'PV_ENTY_SELECT_CRITERIA',
                 p_COLUMN_NAME            => 'OPERATOR',
                 p_attribute_id           => P_SELCRIT_REC.ATTRIBUTE_ID,
                 p_OPERATOR_CODE          => P_SELCRIT_Rec.OPERATOR,
                 x_return_status          => x_return_status,
                 x_msg_count              => x_msg_count,
                 x_msg_data               => x_msg_data);

          end if;

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

      END IF;

      IF (p_validation_level >= AS_UTILITY_PUB.G_VALID_LEVEL_RECORD) THEN
          -- Hint: Inter-field level validation can be added here
          -- invoke record level validation procedures
          NULL;
      END IF;

      IF (p_validation_level >= AS_UTILITY_PUB.G_VALID_LEVEL_INTER_RECORD) THEN

         -- ---------------------------------------------------------------------------
         -- Chandra added ('INPUT_FILTER', 'MONITOR_SCOPE')
         -- ---------------------------------------------------------------------------
         if p_validation_mode = AS_UTILITY_PVT.G_CREATE and
            p_SELCRIT_REC.SELECTION_TYPE_CODE IN ('INPUT_FILTER', 'MONITOR_SCOPE') then

            open lc_chk_input_filter_dups (pc_rule_id      => p_SELCRIT_REC.process_rule_id,
                                           pc_attribute_id => p_SELCRIT_REC.attribute_id);

            fetch lc_chk_input_filter_dups into l_rule_name, l_attribute_name;
            close lc_chk_input_filter_dups;

            if l_attribute_name is not null then

               pv_common_checks_pvt.Set_Message(
                   p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                   p_msg_name      => 'PV_DUPLICATE_INPUT_FILTER',
                   p_token1        => 'RULE_NAME',
                   p_token1_value  => l_rule_name,
                   p_token2        => 'ATTRIBUTE_NAME',
                   p_token2_value  => l_attribute_name);

               x_return_status := FND_API.G_RET_STS_ERROR;

            end if;

         end if;

      END IF;

      IF (p_validation_level >= AS_UTILITY_PUB.G_VALID_LEVEL_INTER_ENTITY) THEN
          -- invoke inter-entity level validation procedures
          NULL;
      END IF;


      -- Debug Message
      IF (AS_DEBUG_HIGH_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'end');
      END IF;

END Validate_selcrit;

End PV_SELCRIT_PVT;

/
