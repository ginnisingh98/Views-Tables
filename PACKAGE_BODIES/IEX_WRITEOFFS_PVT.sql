--------------------------------------------------------
--  DDL for Package Body IEX_WRITEOFFS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_WRITEOFFS_PVT" as
/* $Header: iexvwrob.pls 120.2 2008/01/09 12:31:01 gnramasa ship $ */
-- Start of Comments
-- Package name     : IEX_writeoffs_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'IEX_WRITEOFFS_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'iexvwrob.pls';


-- Hint: Primary key needs to be returned.
--PG_DEBUG NUMBER(2) := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));
PG_DEBUG NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

PROCEDURE Create_writeoffs(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_writeoffs_Rec              IN    writeoffs_Rec_Type  := G_MISS_writeoffs_REC,
    X_WRITEOFF_ID                OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'CREATE_WRITEOFFS';
l_api_version_number      CONSTANT NUMBER   := 2.0;
l_return_status_full      VARCHAR2(1);
v_rowid                   VARCHAR2(24);

v_writeoff_id             iex_writeoffs.writeoff_id%TYPE;
v_object_version_number   iex_writeoffs.object_version_number%TYPE;
v_active_flag             iex_writeoffs.active_flag%TYPE;

Cursor c2 is SELECT IEX_WRITEOFFS_S.nextval from dual;
 BEGIN
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         IEX_DEBUG_PUB.LogMessage ('Create_writeoffs: ' || '********* start of Procedure =>'||
                    'IEX_WRITEOFFS_PVT.create_WRITEOFFS ******** ');
      END IF;

  -- Standard Start of API savepoint
      SAVEPOINT CREATE_WRITEOFFS_PVT;

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
--         IF PG_DEBUG < 10  THEN
         IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
            IEX_DEBUG_PUB.LogMessage('Create_writeoffs: ' || 'After Global user Check');
         END IF;

      --object version Number
         v_object_version_number :=1;
	    --Active_flag
	    v_active_flag :='Y';
--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           IEX_DEBUG_PUB.LogMessage('Create_writeoffs: ' || 'Active Flag is  '|| v_active_flag);
        END IF;

            OPEN C2;
            FETCH C2 INTO v_writeoff_id;
            CLOSE C2;
--        IF PG_DEBUG < 10  THEN
           IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
               IEX_DEBUG_PUB.LogMessage('Create_writeoffs: ' || 'After writeoff_id Check and writeoff_id is =>'||
                                  v_writeoff_id);
           END IF;

           IF (p_writeoffs_rec.writeoff_type IS NULL) OR
                   (p_writeoffs_rec.writeoff_type= FND_API.G_MISS_CHAR) THEN
               fnd_message.set_name('IEX', 'IEX_API_ALL_MISSING_PARAM');
               fnd_message.set_token('API_NAME', l_api_name);
               fnd_message.set_token('MISSING_PARAM', 'writeoff_type');
               fnd_msg_pub.add;
               RAISE FND_API.G_EXC_ERROR;
           END IF;

           IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
              IEX_DEBUG_PUB.LogMessage('Create_writeoffs: ' || 'After writeoff_type Check ');
           END IF;

           IF (p_writeoffs_rec.writeoff_reason IS NULL) OR
                   (p_writeoffs_rec.writeoff_reason= FND_API.G_MISS_CHAR) THEN
               fnd_message.set_name('IEX', 'IEX_API_ALL_MISSING_PARAM');
               fnd_message.set_token('API_NAME', l_api_name);
               fnd_message.set_token('MISSING_PARAM', 'writeoff_reason');
               fnd_msg_pub.add;
               RAISE FND_API.G_EXC_ERROR;
           END IF;

           IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
              IEX_DEBUG_PUB.LogMessage('Create_writeoffs: ' || 'After writeoff_reason Check ');
           END IF;

           IF (p_writeoffs_rec.party_id IS NULL) OR
                   (p_writeoffs_rec.party_id = FND_API.G_MISS_NUM) THEN
               fnd_message.set_name('IEX', 'IEX_API_ALL_MISSING_PARAM');
               fnd_message.set_token('API_NAME', l_api_name);
               fnd_message.set_token('MISSING_PARAM', 'party_id');
               fnd_msg_pub.add;
               RAISE FND_API.G_EXC_ERROR;
           END IF;
           IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
              IEX_DEBUG_PUB.LogMessage('Create_writeoffs: ' || 'After party_id Check ');
           END IF;


      IEX_WRITEOFFS_PKG.Insert_Row(
          x_rowid                   => v_rowid,
          p_WRITEOFF_ID             => v_WRITEOFF_ID,
          p_PARTY_ID                => p_writeoffs_rec.PARTY_ID,
          p_DELINQUENCY_ID          => p_writeoffs_rec.DELINQUENCY_ID,
          p_CAS_ID                  => p_writeoffs_rec.CAS_ID,
          p_CUST_ACCOUNT_ID         => p_writeoffs_rec.CUST_ACCOUNT_ID,
          p_DISPOSITION_CODE        => p_writeoffs_rec.DISPOSITION_CODE,
          p_OBJECT_ID               => p_writeoffs_rec.OBJECT_ID,
          p_OBJECT_CODE             => p_writeoffs_rec.OBJECT_CODE,
          p_WRITEOFF_TYPE           => p_writeoffs_rec.WRITEOFF_TYPE,
          p_ACTIVE_FLAG             => v_ACTIVE_FLAG,
          p_OBJECT_VERSION_NUMBER   => v_OBJECT_VERSION_NUMBER,
          p_WRITEOFF_REASON         => p_writeoffs_rec.WRITEOFF_REASON,
          p_WRITEOFF_AMOUNT         => p_writeoffs_rec.WRITEOFF_AMOUNT,
          p_WRITEOFF_CURRENCY_CODE  => p_writeoffs_rec.WRITEOFF_CURRENCY_CODE,
          p_WRITEOFF_DATE           => p_writeoffs_rec.WRITEOFF_DATE,
          p_WRITEOFF_REQUEST_DATE   => p_writeoffs_rec.WRITEOFF_REQUEST_DATE,
          p_WRITEOFF_PROCESS        => p_writeoffs_rec.WRITEOFF_PROCESS,
          p_WRITEOFF_SCORE          => p_writeoffs_rec.WRITEOFF_SCORE,
          p_BAD_DEBT_REASON         => p_writeoffs_rec.BAD_DEBT_REASON,
          p_LEASING_CODE            => p_writeoffs_rec.LEASING_CODE,
          p_REPOSSES_SCH_DATE       => p_writeoffs_rec.REPOSSES_SCH_DATE,
          p_REPOSSES_COMP_DATE      => p_writeoffs_rec.REPOSSES_COMP_DATE,
          p_CREDIT_HOLD_YN          => p_writeoffs_rec.CREDIT_HOLD_YN,
          p_APPROVER_ID             => p_writeoffs_rec.APPROVER_ID,
          p_EXTERNAL_AGENT_ID       => p_writeoffs_rec.EXTERNAL_AGENT_ID,
          p_PROCEDURE_CODE              => p_writeoffs_rec.PROCEDURE_CODE,
          p_CHECKLIST_CODE              => p_writeoffs_rec.CHECKLIST_CODE,
          p_REQUEST_ID              => p_writeoffs_rec.REQUEST_ID,
          p_PROGRAM_APPLICATION_ID  => p_writeoffs_rec.PROGRAM_APPLICATION_ID,
          p_PROGRAM_ID              => p_writeoffs_rec.PROGRAM_ID,
          p_PROGRAM_UPDATE_DATE     => p_writeoffs_rec.PROGRAM_UPDATE_DATE,
          p_ATTRIBUTE_CATEGORY      => p_writeoffs_rec.ATTRIBUTE_CATEGORY,
          p_ATTRIBUTE1              => p_writeoffs_rec.ATTRIBUTE1,
          p_ATTRIBUTE2              => p_writeoffs_rec.ATTRIBUTE2,
          p_ATTRIBUTE3              => p_writeoffs_rec.ATTRIBUTE3,
          p_ATTRIBUTE4              => p_writeoffs_rec.ATTRIBUTE4,
          p_ATTRIBUTE5              => p_writeoffs_rec.ATTRIBUTE5,
          p_ATTRIBUTE6              => p_writeoffs_rec.ATTRIBUTE6,
          p_ATTRIBUTE7              => p_writeoffs_rec.ATTRIBUTE7,
          p_ATTRIBUTE8              => p_writeoffs_rec.ATTRIBUTE8,
          p_ATTRIBUTE9              => p_writeoffs_rec.ATTRIBUTE9,
          p_ATTRIBUTE10             => p_writeoffs_rec.ATTRIBUTE10,
          p_ATTRIBUTE11             => p_writeoffs_rec.ATTRIBUTE11,
          p_ATTRIBUTE12             => p_writeoffs_rec.ATTRIBUTE12,
          p_ATTRIBUTE13             => p_writeoffs_rec.ATTRIBUTE13,
          p_ATTRIBUTE14             => p_writeoffs_rec.ATTRIBUTE14,
          p_ATTRIBUTE15             => p_writeoffs_rec.ATTRIBUTE15,
          p_CREATED_BY              => FND_GLOBAL.USER_ID,
          p_CREATION_DATE           => SYSDATE,
          p_LAST_UPDATED_BY         => FND_GLOBAL.USER_ID,
          p_LAST_UPDATE_DATE        => SYSDATE,
          p_LAST_UPDATE_LOGIN       => p_writeoffs_rec.LAST_UPDATE_LOGIN
         ,p_CREDIT_HOLD_REQUEST_FLAG   => p_writeoffs_rec.CREDIT_HOLD_REQUEST_FLAG
         ,p_CREDIT_HOLD_APPROVED_FLAG  => p_writeoffs_rec.CREDIT_HOLD_APPROVED_FLAG
         ,p_SERVICE_HOLD_REQUEST_FLAG  => p_writeoffs_rec.SERVICE_HOLD_REQUEST_FLAG
         ,p_SERVICE_HOLD_APPROVED_FLAG => p_writeoffs_rec.SERVICE_HOLD_APPROVED_FLAG
         ,p_SUGGESTION_APPROVED_FLAG   => p_writeoffs_rec.SUGGESTION_APPROVED_FLAG
         ,p_CUSTOMER_SITE_USE_ID      => p_writeoffs_rec.CUSTOMER_SITE_USE_ID
         ,p_ORG_ID                    => p_writeoffs_rec.ORG_ID
         ,p_CONTRACT_ID               => p_writeoffs_rec.CONTRACT_ID
         ,p_CONTRACT_NUMBER           => p_writeoffs_rec.CONTRACT_NUMBER
         );



        x_WRITEOFF_ID := v_WRITEOFF_ID;
--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           IEX_DEBUG_PUB.LogMessage('Create_writeoffs: ' || 'After Calling IEX_WRITEOFFS_PKG.'||
                            'Insert_Row and WRITEOFF_ID is => '||x_WRITEOFF_ID);
        END IF;
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



      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         IEX_DEBUG_PUB.LogMessage ('Create_writeoffs: ' || '********* end of Procedure =>'||
               'IEX_WRITEOFFS_PVT.create_WRITEOFFS ******** ');
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
End Create_writeoffs;


PROCEDURE Update_writeoffs(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_writeoffs_Rec              IN    writeoffs_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    xo_object_version_number     OUT NOCOPY NUMBER
    ) IS

l_api_name                CONSTANT VARCHAR2(30) := 'UPDATE_WRITEOFFS';
l_api_version_number      CONSTANT NUMBER   := 2.0;
l_object_version_number   number := 1.0;
/*
l_object_version_number   iex_writeoffs.object_version_number%TYPE
                            :=p_writeoffs_Rec.object_version_number;
*/
BEGIN
--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.LogMessage ('Update_writeoffs: ' || '********* start of Procedure =>'||
            'IEX_WRITEOFFS_PVT.update_WRITEOFFS ******** ');
     END IF;
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_WRITEOFFS_PVT;

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
      -- Api body
      --

     -- Invoke table handler(IEX_CASES_ALL_B_PKG.Update_Row)
      -- call locking table handler
      /*
      IEX_WRITEOFFS_PKG.lock_row (
         P_WRITEOFFS_Rec.writeoff_id,
         l_object_version_number
      );
     */
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.LogMessage ('IEX_WRITEOFFS_PVT.update_WRITEOFFS, before calling IEX_WRITEOFFS_PKG.Update_Row');
      END IF;

      -- Invoke table handler(IEX_WRITEOFFS_PKG.Update_Row)
      IEX_WRITEOFFS_PKG.Update_Row(
          p_WRITEOFF_ID             => p_writeoffs_rec.WRITEOFF_ID,
          p_PARTY_ID                => p_writeoffs_rec.PARTY_ID,
          p_DELINQUENCY_ID          => p_writeoffs_rec.DELINQUENCY_ID,
          p_CAS_ID                  => p_writeoffs_rec.CAS_ID,
          p_CUST_ACCOUNT_ID         => p_writeoffs_rec.CUST_ACCOUNT_ID,
          p_DISPOSITION_CODE        => p_writeoffs_rec.DISPOSITION_CODE,
          p_OBJECT_ID               => p_writeoffs_rec.OBJECT_ID,
          p_OBJECT_CODE             => p_writeoffs_rec.OBJECT_CODE,
          p_WRITEOFF_TYPE           => p_writeoffs_rec.WRITEOFF_TYPE,
          p_ACTIVE_FLAG             => p_writeoffs_rec.ACTIVE_FLAG,
          p_OBJECT_VERSION_NUMBER   => l_OBJECT_VERSION_NUMBER + 1,
          p_WRITEOFF_REASON         => p_writeoffs_rec.WRITEOFF_REASON,
          p_WRITEOFF_AMOUNT         => p_writeoffs_rec.WRITEOFF_AMOUNT,
          p_WRITEOFF_CURRENCY_CODE  => p_writeoffs_rec.WRITEOFF_CURRENCY_CODE,
          p_WRITEOFF_DATE           => p_writeoffs_rec.WRITEOFF_DATE,
          p_WRITEOFF_REQUEST_DATE   => p_writeoffs_rec.WRITEOFF_REQUEST_DATE,
          p_WRITEOFF_PROCESS        => p_writeoffs_rec.WRITEOFF_PROCESS,
          p_WRITEOFF_SCORE          => p_writeoffs_rec.WRITEOFF_SCORE,
          p_BAD_DEBT_REASON         => p_writeoffs_rec.BAD_DEBT_REASON,
          p_LEASING_CODE            => p_writeoffs_rec.LEASING_CODE,
          p_REPOSSES_SCH_DATE       => p_writeoffs_rec.REPOSSES_SCH_DATE,
          p_REPOSSES_COMP_DATE      => p_writeoffs_rec.REPOSSES_COMP_DATE,
          p_CREDIT_HOLD_YN          => p_writeoffs_rec.CREDIT_HOLD_YN,
          p_APPROVER_ID             => p_writeoffs_rec.APPROVER_ID,
          p_EXTERNAL_AGENT_ID       => p_writeoffs_rec.EXTERNAL_AGENT_ID,
          p_PROCEDURE_CODE          => p_writeoffs_rec.PROCEDURE_CODE,
          p_CHECKLIST_CODE          => p_writeoffs_rec.CHECKLIST_CODE,
          p_REQUEST_ID              => p_writeoffs_rec.REQUEST_ID,
          p_PROGRAM_APPLICATION_ID  => p_writeoffs_rec.PROGRAM_APPLICATION_ID,
          p_PROGRAM_ID              => p_writeoffs_rec.PROGRAM_ID,
          p_PROGRAM_UPDATE_DATE     => p_writeoffs_rec.PROGRAM_UPDATE_DATE,
          p_ATTRIBUTE_CATEGORY      => p_writeoffs_rec.ATTRIBUTE_CATEGORY,
          p_ATTRIBUTE1              => p_writeoffs_rec.ATTRIBUTE1,
          p_ATTRIBUTE2              => p_writeoffs_rec.ATTRIBUTE2,
          p_ATTRIBUTE3              => p_writeoffs_rec.ATTRIBUTE3,
          p_ATTRIBUTE4              => p_writeoffs_rec.ATTRIBUTE4,
          p_ATTRIBUTE5              => p_writeoffs_rec.ATTRIBUTE5,
          p_ATTRIBUTE6              => p_writeoffs_rec.ATTRIBUTE6,
          p_ATTRIBUTE7              => p_writeoffs_rec.ATTRIBUTE7,
          p_ATTRIBUTE8              => p_writeoffs_rec.ATTRIBUTE8,
          p_ATTRIBUTE9              => p_writeoffs_rec.ATTRIBUTE9,
          p_ATTRIBUTE10             => p_writeoffs_rec.ATTRIBUTE10,
          p_ATTRIBUTE11             => p_writeoffs_rec.ATTRIBUTE11,
          p_ATTRIBUTE12             => p_writeoffs_rec.ATTRIBUTE12,
          p_ATTRIBUTE13             => p_writeoffs_rec.ATTRIBUTE13,
          p_ATTRIBUTE14             => p_writeoffs_rec.ATTRIBUTE14,
          p_ATTRIBUTE15             => p_writeoffs_rec.ATTRIBUTE15,
          p_LAST_UPDATED_BY         => FND_GLOBAL.USER_ID,
          p_LAST_UPDATE_DATE        => SYSDATE,
          p_LAST_UPDATE_LOGIN       => p_writeoffs_rec.LAST_UPDATE_LOGIN
         ,p_CREDIT_HOLD_REQUEST_FLAG   => p_writeoffs_rec.CREDIT_HOLD_REQUEST_FLAG
         ,p_CREDIT_HOLD_APPROVED_FLAG  => p_writeoffs_rec.CREDIT_HOLD_APPROVED_FLAG
         ,p_SERVICE_HOLD_REQUEST_FLAG  => p_writeoffs_rec.SERVICE_HOLD_REQUEST_FLAG
         ,p_SERVICE_HOLD_APPROVED_FLAG => p_writeoffs_rec.SERVICE_HOLD_APPROVED_FLAG
         ,p_SUGGESTION_APPROVED_FLAG   => p_writeoffs_rec.SUGGESTION_APPROVED_FLAG
         ,p_CUSTOMER_SITE_USE_ID      => p_writeoffs_rec.CUSTOMER_SITE_USE_ID
         ,p_ORG_ID                    => p_writeoffs_rec.ORG_ID
         ,p_CONTRACT_ID               => p_writeoffs_rec.CONTRACT_ID
         ,p_CONTRACT_NUMBER           => p_writeoffs_rec.CONTRACT_NUMBER
         );

      --
      -- End of API body.
      --
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.LogMessage ('IEX_WRITEOFFS_PVT.update_WRITEOFFS is successfull');
      END IF;
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
        IEX_DEBUG_PUB.LogMessage ('Update_writeoffs: ' || '********* END of Procedure =>'||
             'IEX_WRITEOFFS_PVT.update_WRITEOFFS ******** ');
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
End Update_writeoffs;


PROCEDURE Delete_writeoffs(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_writeoff_id                IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'DELETE_WRITEOFFS';
l_api_version_number      CONSTANT NUMBER   := 2.0;

 BEGIN
--       IF PG_DEBUG < 10  THEN
       IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
          IEX_DEBUG_PUB.LogMessage ('Delete_writeoffs: ' || '********* Start of Procedure =>'||
                     'IEX_WRITEOFFS_PVT.DELETE_WRITEOFFS ******** ');
       END IF;


      -- Standard Start of API savepoint
      SAVEPOINT DELETE_WRITEOFFS_PVT;

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
      -- Api body
      --

      -- Invoke table handler(IEX_WRITEOFFS_PKG.Delete_Row)
         IEX_WRITEOFFS_PKG.Delete_Row(
          p_WRITEOFF_ID  => p_WRITEOFF_ID);
      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


--       IF PG_DEBUG < 10  THEN
       IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
          IEX_DEBUG_PUB.LogMessage ('Delete_writeoffs: ' || '********* End of Procedure =>'||
                    'IEX_WRITEOFFS_PVT.DELETE_WRITEOFFS ******** ');
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
End Delete_writeoffs;



End IEX_WRITEOFFS_PVT;

/
