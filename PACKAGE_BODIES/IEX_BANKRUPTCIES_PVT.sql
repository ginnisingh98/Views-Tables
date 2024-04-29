--------------------------------------------------------
--  DDL for Package Body IEX_BANKRUPTCIES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_BANKRUPTCIES_PVT" as
/* $Header: iexvbkrb.pls 120.0 2004/01/24 03:24:43 appldev noship $ */
-- Start of Comments
-- Package name     : IEX_BANKRUPTCIES_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'IEX_BANKRUPTCIES_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'iexvbkrb.pls';


-- Hint: Primary key needs to be returned.
--PG_DEBUG NUMBER(2) := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));
PG_DEBUG NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

PROCEDURE Create_bankruptcy(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_bankruptcy_Rec             IN    bankruptcy_Rec_Type  := G_MISS_bankruptcy_REC,
    X_BANKRUPTCY_ID              OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Create_bankruptcy';
l_api_version_number      CONSTANT NUMBER   := 2.0;
l_return_status_full      VARCHAR2(1);
v_rowid                   VARCHAR2(24);
v_bankruptcy_id           iex_bankruptcies.bankruptcy_id%TYPE;
v_object_version_number   iex_bankruptcies.object_version_number%TYPE;
v_active_flag             iex_bankruptcies.active_flag%TYPE;


Cursor c2 is SELECT IEX_BANKRUPTCIES_S.nextval from dual;
 BEGIN
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         IEX_DEBUG_PUB.LogMessage ('Create_bankruptcy: ' || '********* start of Procedure =>'||
                'IEX_BANKRUPTCIES_PVT.create_BANKRUPTCY ******** ');
      END IF;

      -- Standard Start of API savepoint
      SAVEPOINT CREATE_BANKRUPTCY_PVT;

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
            IEX_DEBUG_PUB.LogMessage('Create_bankruptcy: ' || 'After Global user Check');
         END IF;

      --object version Number
         v_object_version_number :=1;
	    --Active_flag
	    v_active_flag :='Y';
--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           IEX_DEBUG_PUB.LogMessage('Create_bankruptcy: ' || 'Active Flag is  '|| v_active_flag);
        END IF;

        -- get bankruptcy_id
            OPEN C2;
            FETCH C2 INTO v_bankruptcy_id;
            CLOSE C2;
--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           IEX_DEBUG_PUB.LogMessage('Create_bankruptcy: ' || 'After bankruptcy_id Check and bankruptcy_id is =>'||
                                  v_bankruptcy_id);
        END IF;


         --check for party_id
           IF (p_bankruptcy_rec.party_id IS NULL) OR
                   (p_bankruptcy_rec.party_id = FND_API.G_MISS_NUM) THEN
               fnd_message.set_name('IEX', 'IEX_API_ALL_MISSING_PARAM');
               fnd_message.set_token('API_NAME', l_api_name);
               fnd_message.set_token('MISSING_PARAM', 'party_id');
               fnd_msg_pub.add;
               RAISE FND_API.G_EXC_ERROR;
           END IF;
--           IF PG_DEBUG < 10  THEN
           IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
              IEX_DEBUG_PUB.LogMessage('Create_bankruptcy: ' || 'After party_id Check ');
           END IF;


      -- Invoke table handler(IEX_BANKRUPTCIES_PKG.Insert_Row)
      IEX_BANKRUPTCIES_PKG.Insert_Row(
          x_rowid                   =>v_rowid,
          p_BANKRUPTCY_ID           => v_BANKRUPTCY_ID,
          p_CAS_ID                  => p_bankruptcy_rec.CAS_ID,
          p_DELINQUENCY_ID          => p_bankruptcy_rec.DELINQUENCY_ID,
          p_PARTY_ID                => p_bankruptcy_rec.PARTY_ID,
          p_ACTIVE_FLAG             => v_ACTIVE_FLAG,
          p_TRUSTEE_CONTACT_ID      => p_bankruptcy_rec.TRUSTEE_CONTACT_ID,
          p_COURT_ID                => p_bankruptcy_rec.COURT_ID,
          p_FIRM_CONTACT_ID         => p_bankruptcy_rec.FIRM_CONTACT_ID,
          p_COUNSEL_CONTACT_ID      => p_bankruptcy_rec.COUNSEL_CONTACT_ID,
          p_OBJECT_VERSION_NUMBER   => v_OBJECT_VERSION_NUMBER,
          p_CHAPTER_CODE                 => p_bankruptcy_rec.CHAPTER_CODE,
          p_ASSET_AMOUNT            => p_bankruptcy_rec.ASSET_AMOUNT,
          p_ASSET_CURRENCY_CODE     => p_bankruptcy_rec.ASSET_CURRENCY_CODE,
          p_PAYOFF_AMOUNT           => p_bankruptcy_rec.PAYOFF_AMOUNT,
          p_PAYOFF_CURRENCY_CODE    => p_bankruptcy_rec.PAYOFF_CURRENCY_CODE,
          p_BANKRUPTCY_FILE_DATE    => p_bankruptcy_rec.BANKRUPTCY_FILE_DATE,
          p_COURT_ORDER_DATE        => p_bankruptcy_rec.COURT_ORDER_DATE,
          p_FUNDING_DATE            => p_bankruptcy_rec.FUNDING_DATE,
          p_OBJECT_BAR_DATE         => p_bankruptcy_rec.OBJECT_BAR_DATE,
          p_REPOSSESSION_DATE       => p_bankruptcy_rec.REPOSSESSION_DATE,
          p_DISMISSAL_DATE          => p_bankruptcy_rec.DISMISSAL_DATE,
          p_DATE_341A               => p_bankruptcy_rec.DATE_341A,
          p_DISCHARGE_DATE          => p_bankruptcy_rec.DISCHARGE_DATE,
          p_WITHDRAW_DATE           => p_bankruptcy_rec.WITHDRAW_DATE,
          p_CLOSE_DATE              => p_bankruptcy_rec.CLOSE_DATE,
          p_PROCEDURE_CODE              => p_bankruptcy_rec.PROCEDURE_CODE,
          p_MOTION_CODE                 => p_bankruptcy_rec.MOTION_CODE,
          p_CHECKLIST_CODE              => p_bankruptcy_rec.CHECKLIST_CODE,
          p_CEASE_COLLECTIONS_YN    => p_bankruptcy_rec.CEASE_COLLECTIONS_YN,
          p_TURN_OFF_INVOICING_YN   => p_bankruptcy_rec.TURN_OFF_INVOICING_YN,
          p_REQUEST_ID              => p_bankruptcy_rec.REQUEST_ID,
          p_PROGRAM_APPLICATION_ID  => p_bankruptcy_rec.PROGRAM_APPLICATION_ID,
          p_PROGRAM_ID              => p_bankruptcy_rec.PROGRAM_ID,
          p_PROGRAM_UPDATE_DATE     => p_bankruptcy_rec.PROGRAM_UPDATE_DATE,
          p_ATTRIBUTE_CATEGORY      => p_bankruptcy_rec.ATTRIBUTE_CATEGORY,
          p_ATTRIBUTE1              => p_bankruptcy_rec.ATTRIBUTE1,
          p_ATTRIBUTE2              => p_bankruptcy_rec.ATTRIBUTE2,
          p_ATTRIBUTE3              => p_bankruptcy_rec.ATTRIBUTE3,
          p_ATTRIBUTE4              => p_bankruptcy_rec.ATTRIBUTE4,
          p_ATTRIBUTE5              => p_bankruptcy_rec.ATTRIBUTE5,
          p_ATTRIBUTE6              => p_bankruptcy_rec.ATTRIBUTE6,
          p_ATTRIBUTE7              => p_bankruptcy_rec.ATTRIBUTE7,
          p_ATTRIBUTE8              => p_bankruptcy_rec.ATTRIBUTE8,
          p_ATTRIBUTE9              => p_bankruptcy_rec.ATTRIBUTE9,
          p_ATTRIBUTE10             => p_bankruptcy_rec.ATTRIBUTE10,
          p_ATTRIBUTE11             => p_bankruptcy_rec.ATTRIBUTE11,
          p_ATTRIBUTE12             => p_bankruptcy_rec.ATTRIBUTE12,
          p_ATTRIBUTE13             => p_bankruptcy_rec.ATTRIBUTE13,
          p_ATTRIBUTE14             => p_bankruptcy_rec.ATTRIBUTE14,
          p_ATTRIBUTE15             => p_bankruptcy_rec.ATTRIBUTE15,
          p_CREATED_BY              => FND_GLOBAL.USER_ID,
          p_CREATION_DATE           => SYSDATE,
          p_LAST_UPDATED_BY         => FND_GLOBAL.USER_ID,
          p_LAST_UPDATE_DATE        => SYSDATE,
          p_LAST_UPDATE_LOGIN       => p_bankruptcy_rec.LAST_UPDATE_LOGIN
         ,p_CREDIT_HOLD_REQUEST_FLAG   => p_bankruptcy_rec.CREDIT_HOLD_REQUEST_FLAG
         ,p_CREDIT_HOLD_APPROVED_FLAG  => p_bankruptcy_rec.CREDIT_HOLD_APPROVED_FLAG
         ,p_SERVICE_HOLD_REQUEST_FLAG  => p_bankruptcy_rec.SERVICE_HOLD_REQUEST_FLAG
         ,p_SERVICE_HOLD_APPROVED_FLAG => p_bankruptcy_rec.SERVICE_HOLD_APPROVED_FLAG
         ,p_DISPOSITION_CODE           => p_bankruptcy_rec.DISPOSITION_CODE
         ,p_TURN_OFF_INVOICE_YN        => p_bankruptcy_rec.TURN_OFF_INVOICE_YN
         ,p_NOTICE_ASSIGNMENT_YN       => p_bankruptcy_rec.NOTICE_ASSIGNMENT_YN
         ,p_FILE_PROOF_CLAIM_YN        => p_bankruptcy_rec.FILE_PROOF_CLAIM_YN
         ,p_REQUEST_REPURCHASE_YN      => p_bankruptcy_rec.REQUEST_REPURCHASE_YN
         ,p_FEE_PAID_DATE              => p_bankruptcy_rec.FEE_PAID_DATE
         ,p_REAFFIRMATION_DATE         => p_bankruptcy_rec.REAFFIRMATION_DATE
         ,p_RELIEF_STAY_DATE           => p_bankruptcy_rec.RELIEF_STAY_DATE
         ,p_FILE_CONTACT_ID            => p_bankruptcy_rec.FILE_CONTACT_ID
         ,p_CASE_NUMBER                => p_bankruptcy_rec.CASE_NUMBER
);

      -- Hint: Primary key should be returned.
        x_BANKRUPTCY_ID := v_BANKRUPTCY_ID;
--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           IEX_DEBUG_PUB.LogMessage('Create_bankruptcy: ' || 'After Calling IEX_BANKRUPTCIES_PKG.'||
                            'Insert_Row and BANKRUPTCY_ID is => '||x_BANKRUPTCY_ID);
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
         IEX_DEBUG_PUB.LogMessage ('Create_bankruptcy: ' || '********* end of Procedure =>'||
               'IEX_BANKRUPTCIES_PVT.create_BANKRUPTCY ******** ');
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
End Create_bankruptcy;



PROCEDURE Update_bankruptcy(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_bankruptcy_Rec             IN    bankruptcy_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    xo_object_version_number     OUT NOCOPY NUMBER
    ) IS
l_api_name                CONSTANT VARCHAR2(30) := 'UPDATE_BANKRUPTCY';
l_api_version_number      CONSTANT NUMBER   := 2.0;
l_object_version_number iex_BANKRUPTCIES.object_version_number%TYPE
                          :=P_bankruptcy_Rec.object_version_number;

BEGIN
--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.LogMessage ('Update_bankruptcy: ' || '********* start of Procedure =>'||
          'IEX_BANKRUPTCIES_PVT.update_BANKRUPTCY ******** ');
     END IF;
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_BANKRUPTCY_PVT;

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
      IEX_BANKRUPTCIES_PKG.lock_row (
         P_bankruptcy_Rec.bankruptcy_id,
         l_object_version_number
      );


      -- Invoke table handler(IEX_BANKRUPTCIES_PKG.Update_Row)
      IEX_BANKRUPTCIES_PKG.Update_Row(
          p_BANKRUPTCY_ID           => p_bankruptcy_rec.BANKRUPTCY_ID,
          p_CAS_ID                  => p_bankruptcy_rec.CAS_ID,
          p_DELINQUENCY_ID          => p_bankruptcy_rec.DELINQUENCY_ID,
          p_PARTY_ID                => p_bankruptcy_rec.PARTY_ID,
          p_ACTIVE_FLAG             => p_bankruptcy_rec.ACTIVE_FLAG,
          p_TRUSTEE_CONTACT_ID      => p_bankruptcy_rec.TRUSTEE_CONTACT_ID,
          p_COURT_ID                => p_bankruptcy_rec.COURT_ID,
          p_FIRM_CONTACT_ID         => p_bankruptcy_rec.FIRM_CONTACT_ID,
          p_COUNSEL_CONTACT_ID      => p_bankruptcy_rec.COUNSEL_CONTACT_ID,
          p_OBJECT_VERSION_NUMBER   => l_OBJECT_VERSION_NUMBER + 1,
          p_CHAPTER_CODE                => p_bankruptcy_rec.CHAPTER_CODE,
          p_ASSET_AMOUNT            => p_bankruptcy_rec.ASSET_AMOUNT,
          p_ASSET_CURRENCY_CODE     => p_bankruptcy_rec.ASSET_CURRENCY_CODE,
          p_PAYOFF_AMOUNT           => p_bankruptcy_rec.PAYOFF_AMOUNT,
          p_PAYOFF_CURRENCY_CODE   => p_bankruptcy_rec.PAYOFF_CURRENCY_CODE,
          p_BANKRUPTCY_FILE_DATE   => p_bankruptcy_rec.BANKRUPTCY_FILE_DATE,
          p_COURT_ORDER_DATE       => p_bankruptcy_rec.COURT_ORDER_DATE,
          p_FUNDING_DATE           => p_bankruptcy_rec.FUNDING_DATE,
          p_OBJECT_BAR_DATE        => p_bankruptcy_rec.OBJECT_BAR_DATE,
          p_REPOSSESSION_DATE      => p_bankruptcy_rec.REPOSSESSION_DATE,
          p_DISMISSAL_DATE         => p_bankruptcy_rec.DISMISSAL_DATE,
          p_DATE_341A              => p_bankruptcy_rec.DATE_341A,
          p_DISCHARGE_DATE         => p_bankruptcy_rec.DISCHARGE_DATE,
          p_WITHDRAW_DATE          => p_bankruptcy_rec.WITHDRAW_DATE,
          p_CLOSE_DATE             => p_bankruptcy_rec.CLOSE_DATE,
          p_PROCEDURE_CODE             => p_bankruptcy_rec.PROCEDURE_CODE,
          p_MOTION_CODE                => p_bankruptcy_rec.MOTION_CODE,
          p_CHECKLIST_CODE             => p_bankruptcy_rec.CHECKLIST_CODE,
          p_CEASE_COLLECTIONS_YN   => p_bankruptcy_rec.CEASE_COLLECTIONS_YN,
          p_TURN_OFF_INVOICING_YN  => p_bankruptcy_rec.TURN_OFF_INVOICING_YN,
          p_REQUEST_ID             => p_bankruptcy_rec.REQUEST_ID,
          p_PROGRAM_APPLICATION_ID => p_bankruptcy_rec.PROGRAM_APPLICATION_ID,
          p_PROGRAM_ID             => p_bankruptcy_rec.PROGRAM_ID,
          p_PROGRAM_UPDATE_DATE    => p_bankruptcy_rec.PROGRAM_UPDATE_DATE,
          p_ATTRIBUTE_CATEGORY     => p_bankruptcy_rec.ATTRIBUTE_CATEGORY,
          p_ATTRIBUTE1  => p_bankruptcy_rec.ATTRIBUTE1,
          p_ATTRIBUTE2  => p_bankruptcy_rec.ATTRIBUTE2,
          p_ATTRIBUTE3  => p_bankruptcy_rec.ATTRIBUTE3,
          p_ATTRIBUTE4  => p_bankruptcy_rec.ATTRIBUTE4,
          p_ATTRIBUTE5  => p_bankruptcy_rec.ATTRIBUTE5,
          p_ATTRIBUTE6  => p_bankruptcy_rec.ATTRIBUTE6,
          p_ATTRIBUTE7  => p_bankruptcy_rec.ATTRIBUTE7,
          p_ATTRIBUTE8  => p_bankruptcy_rec.ATTRIBUTE8,
          p_ATTRIBUTE9  => p_bankruptcy_rec.ATTRIBUTE9,
          p_ATTRIBUTE10  => p_bankruptcy_rec.ATTRIBUTE10,
          p_ATTRIBUTE11  => p_bankruptcy_rec.ATTRIBUTE11,
          p_ATTRIBUTE12  => p_bankruptcy_rec.ATTRIBUTE12,
          p_ATTRIBUTE13  => p_bankruptcy_rec.ATTRIBUTE13,
          p_ATTRIBUTE14  => p_bankruptcy_rec.ATTRIBUTE14,
          p_ATTRIBUTE15       => p_bankruptcy_rec.ATTRIBUTE15,
          p_LAST_UPDATED_BY   => FND_GLOBAL.USER_ID,
          p_LAST_UPDATE_DATE  => SYSDATE,
          p_LAST_UPDATE_LOGIN => p_bankruptcy_rec.LAST_UPDATE_LOGIN
         ,p_CREDIT_HOLD_REQUEST_FLAG   => p_bankruptcy_rec.CREDIT_HOLD_REQUEST_FLAG
         ,p_CREDIT_HOLD_APPROVED_FLAG  => p_bankruptcy_rec.CREDIT_HOLD_APPROVED_FLAG
         ,p_SERVICE_HOLD_REQUEST_FLAG  => p_bankruptcy_rec.SERVICE_HOLD_REQUEST_FLAG
         ,p_SERVICE_HOLD_APPROVED_FLAG => p_bankruptcy_rec.SERVICE_HOLD_APPROVED_FLAG
         ,p_DISPOSITION_CODE           => p_bankruptcy_rec.DISPOSITION_CODE
         ,p_TURN_OFF_INVOICE_YN        => p_bankruptcy_rec.TURN_OFF_INVOICE_YN
         ,p_NOTICE_ASSIGNMENT_YN       => p_bankruptcy_rec.NOTICE_ASSIGNMENT_YN
         ,p_FILE_PROOF_CLAIM_YN        => p_bankruptcy_rec.FILE_PROOF_CLAIM_YN
         ,p_REQUEST_REPURCHASE_YN      => p_bankruptcy_rec.REQUEST_REPURCHASE_YN
         ,p_FEE_PAID_DATE              => p_bankruptcy_rec.FEE_PAID_DATE
         ,p_REAFFIRMATION_DATE         => p_bankruptcy_rec.REAFFIRMATION_DATE
         ,p_RELIEF_STAY_DATE           => p_bankruptcy_rec.RELIEF_STAY_DATE
         ,p_FILE_CONTACT_ID            => p_bankruptcy_rec.FILE_CONTACT_ID
         ,p_CASE_NUMBER                => p_bankruptcy_rec.CASE_NUMBER
);

        --Return Version number
        xo_object_version_number := l_object_version_number + 1;

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

--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         IEX_DEBUG_PUB.LogMessage ('Update_bankruptcy: ' || '********* end of Procedure =>'||
             'IEX_BANKRUPTCIES_PVT.update_bankruptcy ******** ');
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
End Update_bankruptcy;



PROCEDURE Delete_bankruptcy(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_bankruptcy_id              IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'DELETE_BANKRUPTCY';
l_api_version_number      CONSTANT NUMBER   := 2.0;

 BEGIN

--       IF PG_DEBUG < 10  THEN
       IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
          IEX_DEBUG_PUB.LogMessage ('Delete_bankruptcy: ' || '********* start of Procedure =>'||
             'IEX_BANKRUPTCIES_PVT.delete_bankruptcy ******** ');
       END IF;

      -- Standard Start of API savepoint
      SAVEPOINT DELETE_BANKRUPTCY_PVT;

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

      -- Invoke table handler(IEX_BANKRUPTCIES_PKG.Delete_Row)
      IEX_BANKRUPTCIES_PKG.Delete_Row(
          p_BANKRUPTCY_ID  => p_BANKRUPTCY_ID);
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
         IEX_DEBUG_PUB.LogMessage ('Delete_bankruptcy: ' || '********* end of Procedure =>'||
             'IEX_BANKRUPTCIES_PVT.delete_bankruptcy ******** ');
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
End Delete_bankruptcy;

End IEX_BANKRUPTCIES_PVT;

/
