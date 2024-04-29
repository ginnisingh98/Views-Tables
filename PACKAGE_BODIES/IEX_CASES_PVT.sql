--------------------------------------------------------
--  DDL for Package Body IEX_CASES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_CASES_PVT" as
/* $Header: iexvcasb.pls 120.2 2006/05/30 17:52:15 scherkas noship $ */
-- Start of Comments
-- Package name     : IEX_CASES_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'IEX_CASES_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'iexvaseb.pls';

--PG_DEBUG NUMBER(2) := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));
PG_DEBUG NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

PROCEDURE Create_cas(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_cas_Rec                    IN    cas_Rec_Type  := G_MISS_cas_REC,
    X_CASE_ID                     OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'CREATE_CAS';
l_api_version_number      CONSTANT NUMBER   := 2.0;
v_org_id                   iex_cases_all_b.org_id%TYPE;
v_cas_id                   iex_cases_all_b.cas_id%TYPE;
v_case_number              iex_cases_all_b.case_number%TYPE;
v_active_flag              iex_cases_all_b.active_flag%TYPE;
v_object_version_number    iex_cases_all_b.object_version_number%TYPE;
v_status_code              iex_cases_all_b.status_code%TYPE;
v_case_state               iex_cases_all_b.case_state%TYPE;
v_CASE_ESTABLISHED_DATE    DATE;
v_rowid                    VARCHAR2(24);
 Cursor c2 is SELECT IEX_CASES_ALL_B_S.nextval from dual;

 BEGIN
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         IEX_DEBUG_PUB.LogMessage ('********* Start of Procedure =>IEX_CASES_PVT.Create_cas ******** ');
      END IF;
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_CAS_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                           	               p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         IEX_DEBUG_PUB.LogMessage('Create_cas: ' || 'After Compatibility Check');
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
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
              FND_MESSAGE.Set_Name('IEX', 'IEX_CANNOT_GET_PROFILE_VALUE');
              FND_MESSAGE.Set_Token('PROFILE', 'USER_ID', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         IEX_DEBUG_PUB.LogMessage('Create_cas: ' || 'After Global user Check');
      END IF;

      -- Get org_id if not present
      IF (p_cas_rec.org_id IS NULL) OR (p_cas_rec.ORG_ID = FND_API.G_MISS_NUM) THEN
             --Bug#4679639 schekuri 20-OCT-2005
             --Used mo_global.get_current_org_id to get ORG_ID
	     --v_org_id := fnd_profile.value('ORG_ID');
	     v_org_id := mo_global.get_current_org_id;
       else
         v_org_id :=p_cas_rec.org_id;
      END IF;
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         IEX_DEBUG_PUB.LogMessage('Create_cas: ' || 'After ORG ID Check and Org_id is => '||v_org_id);
      END IF;

      -- Set Status_code to 'CURRENT'
          v_status_code :='CURRENT';
      -- Set Status_code to Open
          v_case_state :='OPEN';

      --object version Number
      v_object_version_number :=1;
       -- get cas_id
       OPEN C2;
       FETCH C2 INTO v_CAS_ID;
       CLOSE C2;
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         IEX_DEBUG_PUB.LogMessage('Create_cas: ' || 'After CAS ID Check and cas_id is => '||v_cas_id);
      END IF;

       --Case number
       If (p_cas_rec.CASE_NUMBER IS NULL) OR (p_cas_rec.CASE_NUMBER = FND_API.G_MISS_CHAR) then
          v_case_number:=v_cas_id;
        else
          v_case_number :=  p_cas_rec.CASE_NUMBER;
       end if;
--       IF PG_DEBUG < 10  THEN
       IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
          IEX_DEBUG_PUB.LogMessage('Create_cas: ' || 'After CAS Number Check and cas_number is => '||v_case_number);
       END IF;

       --Active_flag
          v_active_flag:='Y';
--       IF PG_DEBUG < 10  THEN
       IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
          IEX_DEBUG_PUB.LogMessage('Create_cas: ' || 'After active flag  Check' );
       END IF;

       --Case established Date
       If (p_cas_rec.CASE_ESTABLISHED_DATE IS NULL) OR (p_cas_rec.CASE_ESTABLISHED_DATE = FND_API.G_MISS_DATE) then
          v_CASE_ESTABLISHED_DATE:=sysdate;
        else
          v_CASE_ESTABLISHED_DATE :=  p_cas_rec.CASE_ESTABLISHED_DATE;
       end if;
--       IF PG_DEBUG < 10  THEN
       IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
          IEX_DEBUG_PUB.LogMessage('Create_cas: ' || 'After Case ESTABLISHED Date Check and case_ESTABLISHED is => '||v_case_ESTABLISHED_DATE);
       END IF;
          -- Added on 11/21/01
     	--Party Id check
          IF (p_cas_rec.party_id IS NULL) OR (p_cas_rec.party_id =FND_API.G_MISS_NUM) THEN
  	         fnd_message.set_name('IEX', 'IEX_API_ALL_MISSING_PARAM');
		    fnd_message.set_token('API_NAME', l_api_name);
		    fnd_message.set_token('MISSING_PARAM', 'party_id');
		    fnd_msg_pub.add;
              RAISE FND_API.G_EXC_ERROR;
		END IF;
--		IF PG_DEBUG < 10  THEN
		IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		   IEX_DEBUG_PUB.LogMessage ('Create_cas: ' || 'After Party id check');
		END IF;

--       IF PG_DEBUG < 10  THEN
       IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
          IEX_DEBUG_PUB.LogMessage('Create_cas: ' || 'Before Calling iex_cases_pkg.insert_row');
       END IF;
       -- Invoke table handler(IEX_CASES_ALL_B_PKG.Insert_Row)
      IEX_CASES_PKG.Insert_Row(
          x_rowid   =>v_rowid,
          x_CAS_ID  => v_CAS_ID,
          x_CASE_NUMBER  => v_CASE_NUMBER,
          x_active_flag  => v_active_flag,
          x_party_id     => p_cas_rec.party_id,
          x_ORIG_CAS_ID  => p_cas_rec.orig_cas_id,
          x_CASE_STATE   => v_CASE_STATE,
          x_STATUS_CODE  => v_STATUS_CODE,
          x_OBJECT_VERSION_NUMBER  => v_OBJECT_VERSION_NUMBER,
          x_CASE_ESTABLISHED_DATE  => v_CASE_ESTABLISHED_DATE,
          x_CASE_CLOSING_DATE  => p_cas_rec.CASE_CLOSING_DATE,
          X_OWNER_RESOURCE_ID  => p_cas_rec.OWNER_RESOURCE_ID,
          x_ACCESS_RESOURCE_ID  => p_cas_rec.ACCESS_RESOURCE_ID,
          X_COMMENTS    =>P_CAS_REC.COMMENTS,
          X_PREDICTED_RECOVERY_AMOUNT =>p_cas_rec.PREDICTED_RECOVERY_AMOUNT,
          X_PREDICTED_CHANCE =>p_cas_rec.PREDICTED_CHANCE,
          x_REQUEST_ID  => p_cas_rec.REQUEST_ID,
          x_PROGRAM_APPLICATION_ID  => p_cas_rec.PROGRAM_APPLICATION_ID,
          x_PROGRAM_ID  => p_cas_rec.PROGRAM_ID,
          x_PROGRAM_UPDATE_DATE  => p_cas_rec.PROGRAM_UPDATE_DATE,
          x_ATTRIBUTE_CATEGORY  => p_cas_rec.ATTRIBUTE_CATEGORY,
          x_ATTRIBUTE1  => p_cas_rec.ATTRIBUTE1,
          x_ATTRIBUTE2  => p_cas_rec.ATTRIBUTE2,
          x_ATTRIBUTE3  => p_cas_rec.ATTRIBUTE3,
          x_ATTRIBUTE4  => p_cas_rec.ATTRIBUTE4,
          x_ATTRIBUTE5  => p_cas_rec.ATTRIBUTE5,
          x_ATTRIBUTE6  => p_cas_rec.ATTRIBUTE6,
          x_ATTRIBUTE7  => p_cas_rec.ATTRIBUTE7,
          x_ATTRIBUTE8  => p_cas_rec.ATTRIBUTE8,
          x_ATTRIBUTE9  => p_cas_rec.ATTRIBUTE9,
          x_ATTRIBUTE10  => p_cas_rec.ATTRIBUTE10,
          x_ATTRIBUTE11  => p_cas_rec.ATTRIBUTE11,
          x_ATTRIBUTE12  => p_cas_rec.ATTRIBUTE12,
          x_ATTRIBUTE13  => p_cas_rec.ATTRIBUTE13,
          x_ATTRIBUTE14  => p_cas_rec.ATTRIBUTE14,
          x_ATTRIBUTE15  => p_cas_rec.ATTRIBUTE15,
          x_CREATED_BY  => FND_GLOBAL.USER_ID,
          X_CREATION_DATE  => SYSDATE,
          x_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID,
          X_LAST_UPDATE_DATE  => SYSDATE,
          x_LAST_UPDATE_LOGIN  => FND_GLOBAL.CONC_LOGIN_ID,
          x_CLOSE_REASON  => p_cas_rec.CLOSE_REASON,
          x_org_id       =>v_org_id);

      -- Hint: Primary key should be returned.
        x_CASE_ID := v_CAS_ID;
--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           IEX_DEBUG_PUB.LogMessage('Create_cas: ' || 'After Calling iex_cases_pkg.insert_row and case id => '||x_case_id);
        END IF;



      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      --
      -- End of API body.
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.LogMessage ('********* End of Procedure =>IEX_CASES_PVT.Create_cas ******** ');
     END IF;
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
End Create_cas;


-- Hint: Add corresponding update detail table procedures if it's master-detail relationship.
PROCEDURE Update_cas(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_cas_Rec                    IN    cas_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    XO_OBJECT_VERSION_NUMBER     OUT NOCOPY  NUMBER
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'UPDATE_CAS';
l_api_version_number      CONSTANT NUMBER   := 2.0;
l_object_version_number iex_cases_all_b.object_version_number%TYPE:=p_cas_rec.object_version_number;

 BEGIN
--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.LogMessage ('********* Start of Procedure =>IEX_CASES_PVT.update_cas ******** ');
     END IF;
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_CAS_PVT;

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


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         IEX_DEBUG_PUB.LogMessage('Update_cas: ' || 'Before Calling iex_cases_pkg.lock_row');
      END IF;
     -- Invoke table handler(IEX_CASES_ALL_B_PKG.Update_Row)
      -- call locking table handler
      IEX_CASES_PKG.lock_row (
         p_cas_rec.cas_id,
         l_object_version_number
      );
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         IEX_DEBUG_PUB.LogMessage('Update_cas: ' || 'Before Calling iex_cases_pkg.update_row');
      END IF;
      IEX_CASES_PKG.Update_Row(
          x_CAS_ID  => p_cas_rec.CAS_ID,
          x_CASE_NUMBER  => p_cas_rec.CASE_NUMBER,
          x_ACTIVE_FLAG  => p_cas_rec.ACTIVE_FLAG,
          x_PARTY_ID  => p_cas_rec.PARTY_ID,
          x_ORIG_CAS_ID  => p_cas_rec.orig_cas_id,
          x_CASE_STATE   => p_cas_rec.CASE_STATE,
          x_STATUS_CODE  => p_cas_rec.STATUS_CODE,
          x_OBJECT_VERSION_NUMBER  => l_OBJECT_VERSION_NUMBER +1,
          x_CASE_ESTABLISHED_DATE  => p_cas_rec.CASE_ESTABLISHED_DATE,
          x_CASE_CLOSING_DATE  => p_cas_rec.CASE_CLOSING_DATE,
          x_OWNER_RESOURCE_ID  => p_cas_rec.OWNER_RESOURCE_ID,
          x_ACCESS_RESOURCE_ID  => p_cas_rec.ACCESS_RESOURCE_ID,
          x_REQUEST_ID  => p_cas_rec.REQUEST_ID,
          X_COMMENTS    =>P_CAS_REC.COMMENTS,
          X_PREDICTED_RECOVERY_AMOUNT =>p_cas_rec.PREDICTED_RECOVERY_AMOUNT,
          X_PREDICTED_CHANCE =>p_cas_rec.PREDICTED_CHANCE,
          x_PROGRAM_APPLICATION_ID  => p_cas_rec.PROGRAM_APPLICATION_ID,
          x_PROGRAM_ID  => p_cas_rec.PROGRAM_ID,
          x_PROGRAM_UPDATE_DATE  => p_cas_rec.PROGRAM_UPDATE_DATE,
          x_ATTRIBUTE_CATEGORY  => p_cas_rec.ATTRIBUTE_CATEGORY,
          x_ATTRIBUTE1  => p_cas_rec.ATTRIBUTE1,
          x_ATTRIBUTE2  => p_cas_rec.ATTRIBUTE2,
          x_ATTRIBUTE3  => p_cas_rec.ATTRIBUTE3,
          x_ATTRIBUTE4  => p_cas_rec.ATTRIBUTE4,
          x_ATTRIBUTE5  => p_cas_rec.ATTRIBUTE5,
          x_ATTRIBUTE6  => p_cas_rec.ATTRIBUTE6,
          x_ATTRIBUTE7  => p_cas_rec.ATTRIBUTE7,
          x_ATTRIBUTE8  => p_cas_rec.ATTRIBUTE8,
          x_ATTRIBUTE9  => p_cas_rec.ATTRIBUTE9,
          x_ATTRIBUTE10  => p_cas_rec.ATTRIBUTE10,
          x_ATTRIBUTE11  => p_cas_rec.ATTRIBUTE11,
          x_ATTRIBUTE12  => p_cas_rec.ATTRIBUTE12,
          x_ATTRIBUTE13  => p_cas_rec.ATTRIBUTE13,
          x_ATTRIBUTE14  => p_cas_rec.ATTRIBUTE14,
          x_ATTRIBUTE15  => p_cas_rec.ATTRIBUTE15,
          x_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID,
          x_LAST_UPDATE_DATE  => SYSDATE,
          x_LAST_UPDATE_LOGIN  => FND_GLOBAL.CONC_LOGIN_ID,
          x_CLOSE_REASON  => p_cas_rec.CLOSE_REASON,
          x_org_id       =>p_cas_rec.org_id);

     --Return Version number
      xo_object_version_number := l_object_version_number + 1;
      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         IEX_DEBUG_PUB.LogMessage ('********* End of Procedure =>IEX_CASES_PVT.Update_cas ******** ');
      END IF;
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
End Update_cas;


-- Hint: Add corresponding delete detail table procedures if it's master-detail relationship.
--       The Master delete procedure may not be needed depends on different business requirements.
PROCEDURE Delete_cas(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_cas_Id                     IN NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'DELETE_CAS';
l_api_version_number      CONSTANT NUMBER   := 2.0;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_CAS_PVT;

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


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      --
      -- API body
      --

      -- call table handler to insert into jtf_tasks_temp_groups
      iex_cases_pkg.delete_row (p_cas_id);

      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
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
End Delete_cas;




End IEX_CASES_PVT;

/
