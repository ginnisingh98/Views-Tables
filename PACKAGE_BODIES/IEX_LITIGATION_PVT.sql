--------------------------------------------------------
--  DDL for Package Body IEX_LITIGATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_LITIGATION_PVT" as
/* $Header: iexvltgb.pls 120.2 2007/12/20 09:37:01 gnramasa noship $ */
-- Start of Comments
-- Package name     : IEX_LITIGATION_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'IEX_LITIGATION_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'iexvltgb.pls';


-- Hint: Primary key needs to be returned.
PG_DEBUG NUMBER(2) := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));

PROCEDURE Create_litigation(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2   := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2   := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag          IN   VARCHAR2   := FND_API.G_FALSE,
    P_Admin_Flag                 IN   VARCHAR2   := FND_API.G_FALSE,
    P_Admin_Group_Id             IN   NUMBER,
    P_Identity_Salesforce_Id     IN   NUMBER,
    -- P_profile_tbl                IN   AS_UTILITY_PUB.PROFILE_TBL_TYPE,
    P_LTG_Rec     IN    LTG_Rec_Type  := G_MISS_LTG_REC,
  --Hint: Add detail tables as parameter lists if it's master-detail relationship.
    X_LITIGATION_ID     OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Create_litigation';
l_api_version_number      CONSTANT NUMBER   := 2.0;
l_return_status_full        VARCHAR2(1);
l_identity_sales_member_rec AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
l_access_flag               VARCHAR2(1);
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_LITIGATION_PVT;

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
              FND_MESSAGE.Set_Name('IEX', 'UT_CANNOT_GET_PROFILE_VALUE');
              FND_MESSAGE.Set_Token('PROFILE', 'USER_ID', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      IF p_validation_level = FND_API.G_VALID_LEVEL_FULL
      THEN
          AS_SALES_ORG_MANAGER_PVT.Get_CurrentUser(
              p_api_version_number => 2.0
             ,p_init_msg_list      => p_init_msg_list
             ,p_salesforce_id => NULL
             ,p_admin_group_id => p_admin_group_id
             ,x_return_status => x_return_status
             ,x_msg_count => x_msg_count
             ,x_msg_data => x_msg_data
             ,x_sales_member_rec => l_identity_sales_member_rec);


          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
          END IF;

      END IF;


      -- Invoke validation procedures
      Validate_litigation(
          p_init_msg_list    => FND_API.G_FALSE,
          p_validation_level => p_validation_level,
          p_validation_mode  => AS_UTILITY_PVT.G_CREATE,
          P_LTG_Rec  =>  P_LTG_Rec,
          x_return_status    => x_return_status,
          x_msg_count        => x_msg_count,
          x_msg_data         => x_msg_data);

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      IF p_check_access_flag = 'Y'
      THEN
          -- Please un-comment here and complete it
--        AS_ACCESS_PUB.Has_???Access(
--            p_api_version_number     => 2.0
--           ,p_init_msg_list          => p_init_msg_list
--           ,p_validation_level       => p_validation_level
--           ,p_profile_tbl            => p_profile_tbl
--           ,p_admin_flag             => p_admin_flag
--           ,p_admin_group_id         => p_admin_group_id
--           ,p_person_id              => l_identity_sales_member_rec.employee_person_id
--           ,p_customer_id            =>
--           ,p_check_access_flag      => 'Y'
--           ,p_identity_salesforce_id => p_identity_salesforce_id
--           ,p_partner_cont_party_id  => NULL
--           ,x_return_status          => x_return_status
--           ,x_msg_count              => x_msg_count
--           ,x_msg_data               => x_msg_data
--           ,x_access_flag            => l_access_flag);



          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
          END IF;

      END IF;
      -- Hint: Add corresponding Master-Detail business logic here if necessary.

    -- Start added for bug 6601993 gnramasa 20th Dec 07
      -- Invoke table handler(IEX_LITIGATIONS_PKG.Insert_Row)
      IEX_LITIGATIONS_PKG.Insert_Row(
          px_LITIGATION_ID  => x_LITIGATION_ID
         ,p_DELINQUENCY_ID  => p_LTG_rec.DELINQUENCY_ID
         ,p_PARTY_ID  => p_LTG_rec.PARTY_ID
         ,p_UNPAID_REASON_CODE  => p_LTG_rec.UNPAID_REASON_CODE
         ,p_JUDGEMENT_DATE  => p_LTG_rec.JUDGEMENT_DATE
         ,p_DISPOSITION_CODE  => p_LTG_rec.DISPOSITION_CODE
         ,p_REQUEST_ID  => p_LTG_rec.REQUEST_ID
         ,p_PROGRAM_APPLICATION_ID  => p_LTG_rec.PROGRAM_APPLICATION_ID
         ,p_PROGRAM_ID  => p_LTG_rec.PROGRAM_ID
         ,p_PROGRAM_UPDATE_DATE  => p_LTG_rec.PROGRAM_UPDATE_DATE
         ,p_ATTRIBUTE_CATEGORY  => p_LTG_rec.ATTRIBUTE_CATEGORY
         ,p_ATTRIBUTE1  => p_LTG_rec.ATTRIBUTE1
         ,p_ATTRIBUTE2  => p_LTG_rec.ATTRIBUTE2
         ,p_ATTRIBUTE3  => p_LTG_rec.ATTRIBUTE3
         ,p_ATTRIBUTE4  => p_LTG_rec.ATTRIBUTE4
         ,p_ATTRIBUTE5  => p_LTG_rec.ATTRIBUTE5
         ,p_ATTRIBUTE6  => p_LTG_rec.ATTRIBUTE6
         ,p_ATTRIBUTE7  => p_LTG_rec.ATTRIBUTE7
         ,p_ATTRIBUTE8  => p_LTG_rec.ATTRIBUTE8
         ,p_ATTRIBUTE9  => p_LTG_rec.ATTRIBUTE9
         ,p_ATTRIBUTE10  => p_LTG_rec.ATTRIBUTE10
         ,p_ATTRIBUTE11  => p_LTG_rec.ATTRIBUTE11
         ,p_ATTRIBUTE12  => p_LTG_rec.ATTRIBUTE12
         ,p_ATTRIBUTE13  => p_LTG_rec.ATTRIBUTE13
         ,p_ATTRIBUTE14  => p_LTG_rec.ATTRIBUTE14
         ,p_ATTRIBUTE15  => p_LTG_rec.ATTRIBUTE15
         ,p_CREATED_BY  => FND_GLOBAL.USER_ID
         ,p_CREATION_DATE  => SYSDATE
         ,p_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID
         ,p_LAST_UPDATE_DATE  => SYSDATE
         ,p_LAST_UPDATE_LOGIN  => FND_GLOBAL.CONC_LOGIN_ID
         ,p_CREDIT_HOLD_REQUEST_FLAG  => p_LTG_rec.CREDIT_HOLD_REQUEST_FLAG
         ,p_CREDIT_HOLD_APPROVED_FLAG  => p_LTG_rec.CREDIT_HOLD_APPROVED_FLAG
         ,p_SERVICE_HOLD_REQUEST_FLAG  => p_LTG_rec.SERVICE_HOLD_REQUEST_FLAG
         ,p_SERVICE_HOLD_APPROVED_FLAG  => p_LTG_rec.SERVICE_HOLD_APPROVED_FLAG
         ,p_SUGGESTION_APPROVED_FLAG  => p_LTG_rec.SUGGESTION_APPROVED_FLAG
	 ,p_CUST_ACCOUNT_ID  => p_LTG_rec. CUST_ACCOUNT_ID
	 ,p_CUSTOMER_SITE_USE_ID  => p_LTG_rec.CUSTOMER_SITE_USE_ID
	 ,p_ORG_ID  => p_LTG_rec.ORG_ID
	 ,p_CONTRACT_ID  => p_LTG_rec.CONTRACT_ID
	 ,p_CONTRACT_NUMBER  => p_LTG_rec.CONTRACT_NUMBER);
      -- Hint: Primary key should be returned.
      -- x_LITIGATION_ID := px_LITIGATION_ID;

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
End Create_litigation;


-- Hint: Add corresponding update detail table procedures if it's master-detail relationship.
PROCEDURE Update_litigation(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2   := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2   := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag          IN   VARCHAR2   := FND_API.G_FALSE,
    P_Admin_Flag                 IN   VARCHAR2   := FND_API.G_FALSE,
    P_Admin_Group_Id             IN   NUMBER,
    P_Identity_Salesforce_Id     IN   NUMBER,
    -- P_profile_tbl                IN   AS_UTILITY_PUB.PROFILE_TBL_TYPE,
    P_LTG_Rec     IN    LTG_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
/*
Cursor C_Get_litigation(LITIGATION_ID Number) IS
    Select rowid,
           LITIGATION_ID,
           DELINQUENCY_ID,
           PARTY_ID,
           UNPAID_REASON_CODE,
           JUDGEMENT_DATE,
           DISPOSITION_CODE,
           REQUEST_ID,
           PROGRAM_APPLICATION_ID,
           PROGRAM_ID,
           PROGRAM_UPDATE_DATE,
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
           ATTRIBUTE15,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           CREDIT_HOLD_REQUEST_FLAG,
           CREDIT_HOLD_APPROVED_FLAG,
           SERVICE_HOLD_REQUEST_FLAG,
           SERVICE_HOLD_APPROVED_FLAG,
           SUGGESTION_APPROVED_FLAG
    From  IEX_LITIGATIONS
    -- Hint: Developer need to provide Where clause
    For Update NOWAIT;
*/
l_api_name                CONSTANT VARCHAR2(30) := 'Update_litigation';
l_api_version_number      CONSTANT NUMBER   := 2.0;
-- Local Variables
l_identity_sales_member_rec   AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
l_ref_LTG_rec  IEX_litigation_PVT.LTG_Rec_Type;
l_tar_LTG_rec  IEX_litigation_PVT.LTG_Rec_Type := P_LTG_Rec;
l_rowid  ROWID;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_LITIGATION_PVT;

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

      IF p_validation_level = FND_API.G_VALID_LEVEL_FULL
      THEN
          AS_SALES_ORG_MANAGER_PVT.Get_CurrentUser(
              p_api_version_number => 2.0
             ,p_init_msg_list      => p_init_msg_list
             ,p_salesforce_id => p_identity_salesforce_id
             ,p_admin_group_id => p_admin_group_id
             ,x_return_status => x_return_status
             ,x_msg_count => x_msg_count
             ,x_msg_data => x_msg_data
             ,x_sales_member_rec => l_identity_sales_member_rec);


          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
          END IF;

      END IF;

/*
      Open C_Get_litigation( l_tar_LTG_rec.LITIGATION_ID);

      Fetch C_Get_litigation into
               l_rowid,
               l_ref_LTG_rec.LITIGATION_ID,
               l_ref_LTG_rec.DELINQUENCY_ID,
               l_ref_LTG_rec.PARTY_ID,
               l_ref_LTG_rec.UNPAID_REASON_CODE,
               l_ref_LTG_rec.JUDGEMENT_DATE,
               l_ref_LTG_rec.DISPOSITION_CODE,
               l_ref_LTG_rec.REQUEST_ID,
               l_ref_LTG_rec.PROGRAM_APPLICATION_ID,
               l_ref_LTG_rec.PROGRAM_ID,
               l_ref_LTG_rec.PROGRAM_UPDATE_DATE,
               l_ref_LTG_rec.ATTRIBUTE_CATEGORY,
               l_ref_LTG_rec.ATTRIBUTE1,
               l_ref_LTG_rec.ATTRIBUTE2,
               l_ref_LTG_rec.ATTRIBUTE3,
               l_ref_LTG_rec.ATTRIBUTE4,
               l_ref_LTG_rec.ATTRIBUTE5,
               l_ref_LTG_rec.ATTRIBUTE6,
               l_ref_LTG_rec.ATTRIBUTE7,
               l_ref_LTG_rec.ATTRIBUTE8,
               l_ref_LTG_rec.ATTRIBUTE9,
               l_ref_LTG_rec.ATTRIBUTE10,
               l_ref_LTG_rec.ATTRIBUTE11,
               l_ref_LTG_rec.ATTRIBUTE12,
               l_ref_LTG_rec.ATTRIBUTE13,
               l_ref_LTG_rec.ATTRIBUTE14,
               l_ref_LTG_rec.ATTRIBUTE15,
               l_ref_LTG_rec.CREATED_BY,
               l_ref_LTG_rec.CREATION_DATE,
               l_ref_LTG_rec.LAST_UPDATED_BY,
               l_ref_LTG_rec.LAST_UPDATE_DATE,
               l_ref_LTG_rec.LAST_UPDATE_LOGIN,
               l_ref_LTG_rec.CREDIT_HOLD_REQUEST_FLAG,
               l_ref_LTG_rec.CREDIT_HOLD_APPROVED_FLAG,
               l_ref_LTG_rec.SERVICE_HOLD_REQUEST_FLAG,
               l_ref_LTG_rec.SERVICE_HOLD_APPROVED_FLAG,
               l_ref_LTG_rec.SUGGESTION_APPROVED_FLAG;

       If ( C_Get_litigation%NOTFOUND) Then
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
               FND_MESSAGE.Set_Name('IEX', 'API_MISSING_UPDATE_TARGET');
               FND_MESSAGE.Set_Token ('INFO', 'litigation', FALSE);
               FND_MSG_PUB.Add;
           END IF;
           Close C_Get_litigation;
           raise FND_API.G_EXC_ERROR;
       END IF;
       Close     C_Get_litigation;
*/


      If (l_tar_LTG_rec.last_update_date is NULL or
          l_tar_LTG_rec.last_update_date = FND_API.G_MISS_Date ) Then
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('IEX', 'API_MISSING_ID');
              FND_MESSAGE.Set_Token('COLUMN', 'Last_Update_Date', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          raise FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      /*
      If (l_tar_LTG_rec.last_update_date <> l_ref_LTG_rec.last_update_date) Then
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('IEX', 'API_RECORD_CHANGED');
              FND_MESSAGE.Set_Token('INFO', 'litigation', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          raise FND_API.G_EXC_ERROR;
      End if;
      */

      -- Invoke validation procedures
      Validate_litigation(
          p_init_msg_list    => FND_API.G_FALSE,
          p_validation_level => p_validation_level,
          p_validation_mode  => AS_UTILITY_PVT.G_UPDATE,
          P_LTG_Rec  =>  P_LTG_Rec,
          x_return_status    => x_return_status,
          x_msg_count        => x_msg_count,
          x_msg_data         => x_msg_data);

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      IF p_check_access_flag = 'Y'
      THEN
          -- Please un-comment here and complete it
--        AS_ACCESS_PUB.Has_???Access(
--            p_api_version_number     => 2.0
--           ,p_init_msg_list          => p_init_msg_list
--           ,p_validation_level       => p_validation_level
--           ,p_profile_tbl            => p_profile_tbl
--           ,p_admin_flag             => p_admin_flag
--           ,p_admin_group_id         => p_admin_group_id
--           ,p_person_id              => l_identity_sales_member_rec.employee_person_id
--           ,p_customer_id            =>
--           ,p_check_access_flag      => 'Y'
--           ,p_identity_salesforce_id => p_identity_salesforce_id
--           ,p_partner_cont_party_id  => NULL
--           ,x_return_status          => x_return_status
--           ,x_msg_count              => x_msg_count
--           ,x_msg_data               => x_msg_data
--           ,x_access_flag            => l_access_flag);



          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
          END IF;

      END IF;
      -- Hint: Add corresponding Master-Detail business logic here if necessary.


      -- Invoke table handler(IEX_LITIGATIONS_PKG.Update_Row)
      IEX_LITIGATIONS_PKG.Update_Row(
          p_LITIGATION_ID  => p_LTG_rec.LITIGATION_ID
         ,p_DELINQUENCY_ID  => p_LTG_rec.DELINQUENCY_ID
         ,p_PARTY_ID  => p_LTG_rec.PARTY_ID
         ,p_UNPAID_REASON_CODE  => p_LTG_rec.UNPAID_REASON_CODE
         ,p_JUDGEMENT_DATE  => p_LTG_rec.JUDGEMENT_DATE
         ,p_DISPOSITION_CODE  => p_LTG_rec.DISPOSITION_CODE
         ,p_REQUEST_ID  => p_LTG_rec.REQUEST_ID
         ,p_PROGRAM_APPLICATION_ID  => p_LTG_rec.PROGRAM_APPLICATION_ID
         ,p_PROGRAM_ID  => p_LTG_rec.PROGRAM_ID
         ,p_PROGRAM_UPDATE_DATE  => p_LTG_rec.PROGRAM_UPDATE_DATE
         ,p_ATTRIBUTE_CATEGORY  => p_LTG_rec.ATTRIBUTE_CATEGORY
         ,p_ATTRIBUTE1  => p_LTG_rec.ATTRIBUTE1
         ,p_ATTRIBUTE2  => p_LTG_rec.ATTRIBUTE2
         ,p_ATTRIBUTE3  => p_LTG_rec.ATTRIBUTE3
         ,p_ATTRIBUTE4  => p_LTG_rec.ATTRIBUTE4
         ,p_ATTRIBUTE5  => p_LTG_rec.ATTRIBUTE5
         ,p_ATTRIBUTE6  => p_LTG_rec.ATTRIBUTE6
         ,p_ATTRIBUTE7  => p_LTG_rec.ATTRIBUTE7
         ,p_ATTRIBUTE8  => p_LTG_rec.ATTRIBUTE8
         ,p_ATTRIBUTE9  => p_LTG_rec.ATTRIBUTE9
         ,p_ATTRIBUTE10  => p_LTG_rec.ATTRIBUTE10
         ,p_ATTRIBUTE11  => p_LTG_rec.ATTRIBUTE11
         ,p_ATTRIBUTE12  => p_LTG_rec.ATTRIBUTE12
         ,p_ATTRIBUTE13  => p_LTG_rec.ATTRIBUTE13
         ,p_ATTRIBUTE14  => p_LTG_rec.ATTRIBUTE14
         ,p_ATTRIBUTE15  => p_LTG_rec.ATTRIBUTE15
         ,p_CREATED_BY     => FND_API.G_MISS_NUM
         ,p_CREATION_DATE  => FND_API.G_MISS_DATE
         ,p_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID
         ,p_LAST_UPDATE_DATE  => SYSDATE
         ,p_LAST_UPDATE_LOGIN  => FND_GLOBAL.CONC_LOGIN_ID
         ,p_CREDIT_HOLD_REQUEST_FLAG  => p_LTG_rec.CREDIT_HOLD_REQUEST_FLAG
         ,p_CREDIT_HOLD_APPROVED_FLAG  => p_LTG_rec.CREDIT_HOLD_APPROVED_FLAG
         ,p_SERVICE_HOLD_REQUEST_FLAG  => p_LTG_rec.SERVICE_HOLD_REQUEST_FLAG
         ,p_SERVICE_HOLD_APPROVED_FLAG  => p_LTG_rec.SERVICE_HOLD_APPROVED_FLAG
         ,p_SUGGESTION_APPROVED_FLAG  => p_LTG_rec.SUGGESTION_APPROVED_FLAG
	 ,p_CUST_ACCOUNT_ID  => p_LTG_rec. CUST_ACCOUNT_ID
	 ,p_CUSTOMER_SITE_USE_ID  => p_LTG_rec.CUSTOMER_SITE_USE_ID
	 ,p_ORG_ID  => p_LTG_rec.ORG_ID
	 ,p_CONTRACT_ID  => p_LTG_rec.CONTRACT_ID
	 ,p_CONTRACT_NUMBER  => p_LTG_rec.CONTRACT_NUMBER);

     -- End added for bug 6601993 gnramasa 20th Dec 07
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
End Update_litigation;


-- Hint: Add corresponding delete detail table procedures if it's master-detail relationship.
--       The Master delete procedure may not be needed depends on different business requirements.
PROCEDURE Delete_litigation(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2   := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2   := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag          IN   VARCHAR2   := FND_API.G_FALSE,
    P_Admin_Flag                 IN   VARCHAR2   := FND_API.G_FALSE,
    P_Admin_Group_Id             IN   NUMBER,
    P_Identity_Salesforce_Id     IN   NUMBER,
    P_Profile_Tbl                IN   AS_UTILITY_PUB.PROFILE_TBL_TYPE,
    P_LTG_Rec     IN LTG_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Delete_litigation';
l_api_version_number      CONSTANT NUMBER   := 2.0;
l_identity_sales_member_rec  AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_LITIGATION_PVT;

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

      IF p_validation_level = FND_API.G_VALID_LEVEL_FULL
      THEN
          AS_SALES_ORG_MANAGER_PVT.Get_CurrentUser(
              p_api_version_number => 2.0
             ,p_init_msg_list      => p_init_msg_list
             ,p_salesforce_id => p_identity_salesforce_id
             ,p_admin_group_id => p_admin_group_id
             ,x_return_status => x_return_status
             ,x_msg_count => x_msg_count
             ,x_msg_data => x_msg_data
             ,x_sales_member_rec => l_identity_sales_member_rec);


          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
          END IF;

      END IF;

      IF p_check_access_flag = 'Y'
      THEN
          -- Please un-comment here and complete it
--        AS_ACCESS_PUB.Has_???Access(
--            p_api_version_number     => 2.0
--           ,p_init_msg_list          => p_init_msg_list
--           ,p_validation_level       => p_validation_level
--           ,p_profile_tbl            => p_profile_tbl
--           ,p_admin_flag             => p_admin_flag
--           ,p_admin_group_id         => p_admin_group_id
--           ,p_person_id              => l_identity_sales_member_rec.employee_person_id
--           ,p_customer_id            =>
--           ,p_check_access_flag      => 'Y'
--           ,p_identity_salesforce_id => p_identity_salesforce_id
--           ,p_partner_cont_party_id  => NULL
--           ,x_return_status          => x_return_status
--           ,x_msg_count              => x_msg_count
--           ,x_msg_data               => x_msg_data
--           ,x_access_flag            => l_access_flag);



          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
          END IF;

      END IF;

      -- Invoke table handler(IEX_LITIGATIONS_PKG.Delete_Row)
      IEX_LITIGATIONS_PKG.Delete_Row(
          p_LITIGATION_ID  => p_LTG_rec.LITIGATION_ID);
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
End Delete_litigation;


-- This procudure defines the columns for the Dynamic SQL.
PROCEDURE Define_Columns(
    P_LTG_Rec   IN  LTG_Rec_Type,
    p_cur_get_LTG   IN   NUMBER
)
IS
BEGIN

      -- define all columns for IEX_LITIGATIONS view
      dbms_sql.define_column(p_cur_get_LTG, 1, P_LTG_Rec.LITIGATION_ID);
      dbms_sql.define_column(p_cur_get_LTG, 2, P_LTG_Rec.DELINQUENCY_ID);
      dbms_sql.define_column(p_cur_get_LTG, 3, P_LTG_Rec.PARTY_ID);
      dbms_sql.define_column(p_cur_get_LTG, 4, P_LTG_Rec.UNPAID_REASON_CODE, 30);
      dbms_sql.define_column(p_cur_get_LTG, 5, P_LTG_Rec.JUDGEMENT_DATE);
      dbms_sql.define_column(p_cur_get_LTG, 6, P_LTG_Rec.DISPOSITION_CODE, 30);
      dbms_sql.define_column(p_cur_get_LTG, 7, P_LTG_Rec.REQUEST_ID);
      dbms_sql.define_column(p_cur_get_LTG, 8, P_LTG_Rec.ATTRIBUTE_CATEGORY, 240);
      dbms_sql.define_column(p_cur_get_LTG, 9, P_LTG_Rec.ATTRIBUTE1, 240);
      dbms_sql.define_column(p_cur_get_LTG, 10, P_LTG_Rec.ATTRIBUTE2, 240);
      dbms_sql.define_column(p_cur_get_LTG, 11, P_LTG_Rec.ATTRIBUTE3, 240);
      dbms_sql.define_column(p_cur_get_LTG, 12, P_LTG_Rec.ATTRIBUTE4, 240);
      dbms_sql.define_column(p_cur_get_LTG, 13, P_LTG_Rec.ATTRIBUTE5, 240);
      dbms_sql.define_column(p_cur_get_LTG, 14, P_LTG_Rec.ATTRIBUTE6, 240);
      dbms_sql.define_column(p_cur_get_LTG, 15, P_LTG_Rec.ATTRIBUTE7, 240);
      dbms_sql.define_column(p_cur_get_LTG, 16, P_LTG_Rec.ATTRIBUTE8, 240);
      dbms_sql.define_column(p_cur_get_LTG, 17, P_LTG_Rec.ATTRIBUTE9, 240);
      dbms_sql.define_column(p_cur_get_LTG, 18, P_LTG_Rec.ATTRIBUTE10, 240);
      dbms_sql.define_column(p_cur_get_LTG, 19, P_LTG_Rec.ATTRIBUTE11, 240);
      dbms_sql.define_column(p_cur_get_LTG, 20, P_LTG_Rec.ATTRIBUTE12, 240);
      dbms_sql.define_column(p_cur_get_LTG, 21, P_LTG_Rec.ATTRIBUTE13, 240);
      dbms_sql.define_column(p_cur_get_LTG, 22, P_LTG_Rec.ATTRIBUTE14, 240);
      dbms_sql.define_column(p_cur_get_LTG, 23, P_LTG_Rec.ATTRIBUTE15, 240);
      dbms_sql.define_column(p_cur_get_LTG, 24, P_LTG_Rec.CREDIT_HOLD_REQUEST_FLAG, 240);
      dbms_sql.define_column(p_cur_get_LTG, 25, P_LTG_Rec.CREDIT_HOLD_APPROVED_FLAG, 240);
      dbms_sql.define_column(p_cur_get_LTG, 26, P_LTG_Rec.SERVICE_HOLD_REQUEST_FLAG, 240);
      dbms_sql.define_column(p_cur_get_LTG, 27, P_LTG_Rec.SERVICE_HOLD_APPROVED_FLAG, 240);
      dbms_sql.define_column(p_cur_get_LTG, 28, P_LTG_Rec.SUGGESTION_APPROVED_FLAG, 240);

END Define_Columns;

-- This procudure gets column values by the Dynamic SQL.
PROCEDURE Get_Column_Values(
    p_cur_get_LTG   IN   NUMBER,
    X_LTG_Rec       OUT NOCOPY  LTG_Rec_Type
)
IS
BEGIN

      -- get all column values for IEX_LITIGATIONS table
      dbms_sql.column_value(p_cur_get_LTG, 1, X_LTG_Rec.LITIGATION_ID);
      dbms_sql.column_value(p_cur_get_LTG, 2, X_LTG_Rec.DELINQUENCY_ID);
      dbms_sql.column_value(p_cur_get_LTG, 3, X_LTG_Rec.PARTY_ID);
      dbms_sql.column_value(p_cur_get_LTG, 4, X_LTG_Rec.UNPAID_REASON_CODE);
      dbms_sql.column_value(p_cur_get_LTG, 5, X_LTG_Rec.JUDGEMENT_DATE);
      dbms_sql.column_value(p_cur_get_LTG, 6, X_LTG_Rec.DISPOSITION_CODE);
      dbms_sql.column_value(p_cur_get_LTG, 7, X_LTG_Rec.REQUEST_ID);
      dbms_sql.column_value(p_cur_get_LTG, 8, X_LTG_Rec.ATTRIBUTE_CATEGORY);
      dbms_sql.column_value(p_cur_get_LTG, 9, X_LTG_Rec.ATTRIBUTE1);
      dbms_sql.column_value(p_cur_get_LTG, 10, X_LTG_Rec.ATTRIBUTE2);
      dbms_sql.column_value(p_cur_get_LTG, 11, X_LTG_Rec.ATTRIBUTE3);
      dbms_sql.column_value(p_cur_get_LTG, 12, X_LTG_Rec.ATTRIBUTE4);
      dbms_sql.column_value(p_cur_get_LTG, 13, X_LTG_Rec.ATTRIBUTE5);
      dbms_sql.column_value(p_cur_get_LTG, 14, X_LTG_Rec.ATTRIBUTE6);
      dbms_sql.column_value(p_cur_get_LTG, 15, X_LTG_Rec.ATTRIBUTE7);
      dbms_sql.column_value(p_cur_get_LTG, 16, X_LTG_Rec.ATTRIBUTE8);
      dbms_sql.column_value(p_cur_get_LTG, 17, X_LTG_Rec.ATTRIBUTE9);
      dbms_sql.column_value(p_cur_get_LTG, 18, X_LTG_Rec.ATTRIBUTE10);
      dbms_sql.column_value(p_cur_get_LTG, 19, X_LTG_Rec.ATTRIBUTE11);
      dbms_sql.column_value(p_cur_get_LTG, 20, X_LTG_Rec.ATTRIBUTE12);
      dbms_sql.column_value(p_cur_get_LTG, 21, X_LTG_Rec.ATTRIBUTE13);
      dbms_sql.column_value(p_cur_get_LTG, 22, X_LTG_Rec.ATTRIBUTE14);
      dbms_sql.column_value(p_cur_get_LTG, 23, X_LTG_Rec.ATTRIBUTE15);
      dbms_sql.column_value(p_cur_get_LTG, 24, X_LTG_Rec.CREDIT_HOLD_REQUEST_FLAG);
      dbms_sql.column_value(p_cur_get_LTG, 25, X_LTG_Rec.CREDIT_HOLD_APPROVED_FLAG);
      dbms_sql.column_value(p_cur_get_LTG, 26, X_LTG_Rec.SERVICE_HOLD_REQUEST_FLAG);
      dbms_sql.column_value(p_cur_get_LTG, 27, X_LTG_Rec.SERVICE_HOLD_APPROVED_FLAG);
      dbms_sql.column_value(p_cur_get_LTG, 28, X_LTG_Rec.SUGGESTION_APPROVED_FLAG);

END Get_Column_Values;

PROCEDURE Gen_LTG_order_cl(
    p_order_by_rec   IN   LTG_sort_rec_type,
    x_order_by_cl    OUT NOCOPY  VARCHAR2,
    x_return_status  OUT NOCOPY  VARCHAR2,
    x_msg_count      OUT NOCOPY  NUMBER,
    x_msg_data       OUT NOCOPY  VARCHAR2
)
IS
l_order_by_cl        VARCHAR2(1000)   := NULL;
l_util_order_by_tbl  AS_UTILITY_PVT.Util_order_by_tbl_type;
BEGIN

      -- Hint: Developer should add more statements according to IEX_sort_rec_type
      -- Ex:
      -- l_util_order_by_tbl(1).col_choice := p_order_by_rec.customer_name;
      -- l_util_order_by_tbl(1).col_name := 'Customer_Name';


      AS_UTILITY_PVT.Translate_OrderBy(
          p_api_version_number   =>   1.0
         ,p_init_msg_list        =>   FND_API.G_FALSE
         ,p_validation_level     =>   FND_API.G_VALID_LEVEL_FULL
         ,p_order_by_tbl         =>   l_util_order_by_tbl
         ,x_order_by_clause      =>   l_order_by_cl
         ,x_return_status        =>   x_return_status
         ,x_msg_count            =>   x_msg_count
         ,x_msg_data             =>   x_msg_data);

      IF(l_order_by_cl IS NOT NULL) THEN
          x_order_by_cl := 'order by' || l_order_by_cl;
      ELSE
          x_order_by_cl := NULL;
      END IF;

END Gen_LTG_order_cl;

-- This procedure bind the variables for the Dynamic SQL
PROCEDURE Bind(
    P_LTG_Rec   IN   LTG_Rec_Type,
    -- Hint: Add more binding variables here
    p_cur_get_LTG   IN   NUMBER
)
IS
BEGIN
      -- Bind variables
      -- Only those that are not NULL

      -- The following example applies to all columns,
      -- developers can copy and paste them.
      IF( (P_LTG_Rec.LITIGATION_ID IS NOT NULL) AND (P_LTG_Rec.LITIGATION_ID <> FND_API.G_MISS_NUM) )
      THEN
          DBMS_SQL.BIND_VARIABLE(p_cur_get_LTG, ':p_LITIGATION_ID', P_LTG_Rec.LITIGATION_ID);
      END IF;

END Bind;

PROCEDURE Gen_Select(
    x_select_cl   OUT NOCOPY   VARCHAR2
)
IS
BEGIN

      x_select_cl := 'Select ' ||
                'IEX_LITIGATIONS.LITIGATION_ID,' ||
                'IEX_LITIGATIONS.DELINQUENCY_ID,' ||
                'IEX_LITIGATIONS.PARTY_ID,' ||
                'IEX_LITIGATIONS.UNPAID_REASON_CODE,' ||
                'IEX_LITIGATIONS.JUDGEMENT_DATE,' ||
                'IEX_LITIGATIONS.DISPOSITION_CODE,' ||
                'IEX_LITIGATIONS.REQUEST_ID,' ||
                'IEX_LITIGATIONS.PROGRAM_APPLICATION_ID,' ||
                'IEX_LITIGATIONS.PROGRAM_ID,' ||
                'IEX_LITIGATIONS.PROGRAM_UPDATE_DATE,' ||
                'IEX_LITIGATIONS.ATTRIBUTE_CATEGORY,' ||
                'IEX_LITIGATIONS.ATTRIBUTE1,' ||
                'IEX_LITIGATIONS.ATTRIBUTE2,' ||
                'IEX_LITIGATIONS.ATTRIBUTE3,' ||
                'IEX_LITIGATIONS.ATTRIBUTE4,' ||
                'IEX_LITIGATIONS.ATTRIBUTE5,' ||
                'IEX_LITIGATIONS.ATTRIBUTE6,' ||
                'IEX_LITIGATIONS.ATTRIBUTE7,' ||
                'IEX_LITIGATIONS.ATTRIBUTE8,' ||
                'IEX_LITIGATIONS.ATTRIBUTE9,' ||
                'IEX_LITIGATIONS.ATTRIBUTE10,' ||
                'IEX_LITIGATIONS.ATTRIBUTE11,' ||
                'IEX_LITIGATIONS.ATTRIBUTE12,' ||
                'IEX_LITIGATIONS.ATTRIBUTE13,' ||
                'IEX_LITIGATIONS.ATTRIBUTE14,' ||
                'IEX_LITIGATIONS.ATTRIBUTE15,' ||
                'IEX_LITIGATIONS.CREATED_BY,' ||
                'IEX_LITIGATIONS.CREATION_DATE,' ||
                'IEX_LITIGATIONS.LAST_UPDATED_BY,' ||
                'IEX_LITIGATIONS.LAST_UPDATE_DATE,' ||
                'IEX_LITIGATIONS.LAST_UPDATE_LOGIN,' ||
                'IEX_LITIGATIONS.SECURITY_GROUP_ID,' ||
                'IEX_LITIGATIONS.CREDIT_HOLD_REQUEST_FLAG,' ||
                'IEX_LITIGATIONS.CREDIT_HOLD_APPROVED_FLAG,' ||
                'IEX_LITIGATIONS.SERVICE_HOLD_REQUEST_FLAG,' ||
                'IEX_LITIGATIONS.SERVICE_HOLD_APPROVED_FLAG,' ||
                'IEX_LITIGATIONS.SUGGESTION_APPROVED_FLAG,' ||
                'from IEX_LITIGATIONS';

END Gen_Select;

PROCEDURE Gen_LTG_Where(
    P_LTG_Rec     IN   LTG_Rec_Type,
    x_LTG_where   OUT NOCOPY   VARCHAR2
)
IS
-- cursors to check if wildcard values '%' and '_' have been passed
-- as item values
CURSOR c_chk_str1(p_rec_item VARCHAR2) IS
    SELECT INSTR(p_rec_item, '%', 1, 1)
    FROM DUAL;
CURSOR c_chk_str2(p_rec_item VARCHAR2) IS
    SELECT INSTR(p_rec_item, '_', 1, 1)
    FROM DUAL;

-- return values from cursors
str_csr1   NUMBER;
str_csr2   NUMBER;
l_operator VARCHAR2(10);
BEGIN

      -- There are three examples for each kind of datatype:
      -- NUMBER, DATE, VARCHAR2.
      -- Developer can copy and paste the following codes for your own record.

      -- example for NUMBER datatype
      IF( (P_LTG_Rec.LITIGATION_ID IS NOT NULL) AND (P_LTG_Rec.LITIGATION_ID <> FND_API.G_MISS_NUM) )
      THEN
          IF(x_LTG_where IS NULL) THEN
              x_LTG_where := 'Where';
          ELSE
              x_LTG_where := x_LTG_where || ' AND ';
          END IF;
          x_LTG_where := x_LTG_where || 'P_LTG_Rec.LITIGATION_ID = :p_LITIGATION_ID';
      END IF;

      -- example for DATE datatype
      IF( (P_LTG_Rec.JUDGEMENT_DATE IS NOT NULL) AND (P_LTG_Rec.JUDGEMENT_DATE <> FND_API.G_MISS_DATE) )
      THEN
          -- check if item value contains '%' wildcard
          OPEN c_chk_str1(P_LTG_Rec.JUDGEMENT_DATE);
          FETCH c_chk_str1 INTO str_csr1;
          CLOSE c_chk_str1;

          IF(str_csr1 <> 0) THEN
              l_operator := ' LIKE ';
          ELSE
              l_operator := ' = ';
          END IF;

          -- check if item value contains '_' wildcard
          OPEN c_chk_str2(P_LTG_Rec.JUDGEMENT_DATE);
          FETCH c_chk_str2 INTO str_csr2;
          CLOSE c_chk_str2;

          IF(str_csr2 <> 0) THEN
              l_operator := ' LIKE ';
          ELSE
              l_operator := ' = ';
          END IF;

          IF(x_LTG_where IS NULL) THEN
              x_LTG_where := 'Where ';
          ELSE
              x_LTG_where := x_LTG_where || ' AND ';
          END IF;
          x_LTG_where := x_LTG_where || 'P_LTG_Rec.JUDGEMENT_DATE ' || l_operator || ' :p_JUDGEMENT_DATE';
      END IF;

      -- example for VARCHAR2 datatype
      IF( (P_LTG_Rec.UNPAID_REASON_CODE IS NOT NULL) AND (P_LTG_Rec.UNPAID_REASON_CODE <> FND_API.G_MISS_CHAR) )
      THEN
          -- check if item value contains '%' wildcard
          OPEN c_chk_str1(P_LTG_Rec.UNPAID_REASON_CODE);
          FETCH c_chk_str1 INTO str_csr1;
          CLOSE c_chk_str1;

          IF(str_csr1 <> 0) THEN
              l_operator := ' LIKE ';
          ELSE
              l_operator := ' = ';
          END IF;

          -- check if item value contains '_' wildcard
          OPEN c_chk_str2(P_LTG_Rec.UNPAID_REASON_CODE);
          FETCH c_chk_str2 INTO str_csr2;
          CLOSE c_chk_str2;

          IF(str_csr2 <> 0) THEN
              l_operator := ' LIKE ';
          ELSE
              l_operator := ' = ';
          END IF;

          IF(x_LTG_where IS NULL) THEN
              x_LTG_where := 'Where ';
          ELSE
              x_LTG_where := x_LTG_where || ' AND ';
          END IF;
          x_LTG_where := x_LTG_where || 'P_LTG_Rec.UNPAID_REASON_CODE ' || l_operator || ' :p_UNPAID_REASON_CODE';
      END IF;

      -- Add more IF statements for each column below


END Gen_LTG_Where;

PROCEDURE Get_litigation(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2   := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    P_Admin_Group_id             IN   NUMBER,
    P_identity_salesforce_id     IN   NUMBER     := NULL,
    P_LTG_Rec                    IN   LTG_Rec_Type,
  -- Hint: Add list of bind variables here
    p_rec_requested              IN   NUMBER  := G_DEFAULT_NUM_REC_FETCH,
    p_start_rec_prt              IN   NUMBER  := 1,
    p_return_tot_count           IN   NUMBER  := FND_API.G_FALSE,
  -- Hint: user defined record type
    p_order_by_rec               IN   LTG_sort_rec_type,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    X_LTG_Tbl                    OUT NOCOPY  LTG_Tbl_Type,
    x_returned_rec_count         OUT NOCOPY  NUMBER,
    x_next_rec_ptr               OUT NOCOPY  NUMBER,
    x_tot_rec_count              OUT NOCOPY  NUMBER
  -- other optional parameters
--  x_tot_rec_amount             OUT NOCOPY  NUMBER
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Get_litigation';
l_api_version_number      CONSTANT NUMBER   := 2.0;

-- Local identity variables
l_identity_sales_member_rec  AS_SALES_MEMBER_PUB.Sales_member_rec_Type;

-- Local record counters
l_returned_rec_count     NUMBER := 0; -- number of records returned in x_X_LTG_Rec
l_next_record_ptr        NUMBER := 1;
l_ignore                 NUMBER;

-- total number of records accessable by caller
l_tot_rec_count          NUMBER := 0;
l_tot_rec_amount         NUMBER := 0;

-- Status local variables
l_return_status          VARCHAR2(1); -- Return value from procedures
l_return_status_full     VARCHAR2(1); -- Calculated return status from

-- Dynamic SQL statement elements
l_cur_get_LTG            NUMBER;
l_select_cl              VARCHAR2(2000) := '';
l_order_by_cl            VARCHAR2(2000);
l_LTG_where    VARCHAR2(2000) := '';

-- For flex field query
l_flex_where_tbl_type    AS_FOUNDATION_PVT.flex_where_tbl_type;
l_flex_where             VARCHAR2(2000) := NULL;
l_counter                NUMBER;

-- Local scratch record
l_LTG_rec   LTG_Rec_Type;
l_crit_LTG_rec    LTG_Rec_Type;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT GET_LITIGATION_PVT;

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

      IF p_validation_level = FND_API.G_VALID_LEVEL_FULL
      THEN
          AS_SALES_ORG_MANAGER_PVT.Get_CurrentUser(
              p_api_version_number => 2.0
             ,p_init_msg_list      => p_init_msg_list
             ,p_salesforce_id => p_identity_salesforce_id
             ,p_admin_group_id => p_admin_group_id
             ,x_return_status => x_return_status
             ,x_msg_count => x_msg_count
             ,x_msg_data => x_msg_data
             ,x_sales_member_rec => l_identity_sales_member_rec);


          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
          END IF;

      END IF;
      -- *************************************************
      -- Generate Dynamic SQL based on criteria passed in.
      -- Doing this for performance. Indexes are disabled when using NVL within static SQL statement.
      -- Ignore condition when criteria is NULL
      -- Generate Select clause and From clause
      -- Hint: Developer should modify Gen_Select procedure.
      Gen_Select(l_select_cl);

      -- Hint: Developer should modify and implement Gen_Where precedure.
      Gen_LTG_Where(l_crit_LTG_rec, l_LTG_where);

      -- Generate Where clause for flex fields
      -- Hint: Developer can use table/view alias in the From clause generated in Gen_Select procedure

      FOR l_counter IN 1..15 LOOP
          l_flex_where_tbl_type(l_counter).name := 'IEX_LITIGATIONS.attribute' || l_counter;
      END LOOP;

      l_flex_where_tbl_type(16).name := 'IEX_LITIGATIONS.attribute_category';
      l_flex_where_tbl_type(1).value := P_LTG_Rec.attribute1;
      l_flex_where_tbl_type(2).value := P_LTG_Rec.attribute2;
      l_flex_where_tbl_type(3).value := P_LTG_Rec.attribute3;
      l_flex_where_tbl_type(4).value := P_LTG_Rec.attribute4;
      l_flex_where_tbl_type(5).value := P_LTG_Rec.attribute5;
      l_flex_where_tbl_type(6).value := P_LTG_Rec.attribute6;
      l_flex_where_tbl_type(7).value := P_LTG_Rec.attribute7;
      l_flex_where_tbl_type(8).value := P_LTG_Rec.attribute8;
      l_flex_where_tbl_type(9).value := P_LTG_Rec.attribute9;
      l_flex_where_tbl_type(10).value := P_LTG_Rec.attribute10;
      l_flex_where_tbl_type(11).value := P_LTG_Rec.attribute11;
      l_flex_where_tbl_type(12).value := P_LTG_Rec.attribute12;
      l_flex_where_tbl_type(13).value := P_LTG_Rec.attribute13;
      l_flex_where_tbl_type(14).value := P_LTG_Rec.attribute14;
      l_flex_where_tbl_type(15).value := P_LTG_Rec.attribute15;
      l_flex_where_tbl_type(16).value := P_LTG_Rec.attribute_category;

      AS_FOUNDATION_PVT.Gen_Flexfield_Where(
          p_flex_where_tbl_type   => l_flex_where_tbl_type,
          x_flex_where_clause     => l_flex_where);

      -- Hint: if master/detail relationship, generate Where clause for lines level criteria
      -- Generate order by clause
      Gen_LTG_order_cl(p_order_by_rec, l_order_by_cl, l_return_status, x_msg_count, x_msg_data);


      l_cur_get_LTG := dbms_sql.open_cursor;

      -- Hint: concatenate all where clause (include flex field/line level if any applies)
      --    dbms_sql.parse(l_cur_get_LTG, l_select_cl || l_head_where || l_flex_where || l_lines_where
      --    || l_steam_where || l_order_by_cl, dbms_sql.native);

      -- Hint: Developer should implement Bind Variables procedure according to bind variables in the parameter list
      -- Bind(l_crit_LTG_rec, l_crit_exp_purchase_rec, p_start_date, p_end_date,
      --      p_crit_exp_salesforce_id, p_crit_ptr_salesforce_id,
      --      p_crit_salesgroup_id, p_crit_ptr_manager_person_id,
      --      p_win_prob_ceiling, p_win_prob_floor,
      --      p_total_amt_ceiling, p_total_amt_floor,
      --      l_cur_get_LTG);

      -- Bind flexfield variables
      AS_FOUNDATION_PVT.Bind_Flexfield_Where(
          p_cursor_id   =>   l_cur_get_LTG,
          p_flex_where_tbl_type => l_flex_where_tbl_type);

      -- Define all Select Columns
      Define_Columns(l_crit_LTG_rec, l_cur_get_LTG);

      -- Execute

      l_ignore := dbms_sql.execute(l_cur_get_LTG);


      -- This loop is here to avoid calling a function in the main
      -- cursor. Basically, calling this function seems to disable
      -- index, but verification is needed. This is a good
      -- place to optimize the code if required.

      LOOP
      -- 1. There are more rows in the cursor.
      -- 2. User does not care about total records, and we need to return more.
      -- 3. Or user cares about total number of records.
      IF((dbms_sql.fetch_rows(l_cur_get_LTG)>0) AND ((p_return_tot_count = FND_API.G_TRUE)
        OR (l_returned_rec_count<p_rec_requested) OR (p_rec_requested=FND_API.G_MISS_NUM)))
      THEN

          -- Hint: Developer need to implement this part
          --      dbms_sql.column_value(l_cur_get_opp, 1, l_opp_rec.lead_id);
          --      dbms_sql.column_value(l_cur_get_opp, 7, l_opp_rec.customer_id);
          --      dbms_sql.column_value(l_cur_get_opp, 8, l_opp_rec.address_id);

          -- Hint: Check access for this record (e.x. AS_ACCESS_PVT.Has_OpportunityAccess)
          -- Return this particular record if
          -- 1. The caller has access to record.
          -- 2. The number of records returned < number of records caller requested in this run.
          -- 3. The record comes AFTER or Equal to the start index the caller requested.

          -- Developer should check whether there is access privilege here
--          IF(l_LTG_rec.member_access <> 'N' OR l_LTG_rec.member_role <> 'N') THEN
              Get_Column_Values(l_cur_get_LTG, l_LTG_rec);
              l_tot_rec_count := l_tot_rec_count + 1;
              IF(l_returned_rec_count < p_rec_requested) AND (l_tot_rec_count >= p_start_rec_prt) THEN
                  l_returned_rec_count := l_returned_rec_count + 1;
                  -- insert into resultant tables
                  X_LTG_Tbl(l_returned_rec_count) := l_LTG_rec;
              END IF;
--          END IF;
      ELSE
          EXIT;
      END IF;
      END LOOP;
      --
      -- End of API body
      --


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
End Get_litigation;


-- Item-level validation procedures
PROCEDURE Validate_LITIGATION_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_LITIGATION_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     AS_UTILITY_PVT.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- validate NOT NULL column
      IF(p_LITIGATION_ID is NULL)
      THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      IF(p_validation_mode = AS_UTILITY_PVT.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_LITIGATION_ID is not NULL and p_LITIGATION_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = AS_UTILITY_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_LITIGATION_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_LITIGATION_ID;


PROCEDURE Validate_DELINQUENCY_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_DELINQUENCY_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     AS_UTILITY_PVT.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
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
          -- Hint: Validate data
          -- IF p_DELINQUENCY_ID is not NULL and p_DELINQUENCY_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = AS_UTILITY_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_DELINQUENCY_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_DELINQUENCY_ID;


PROCEDURE Validate_PARTY_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PARTY_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     AS_UTILITY_PVT.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
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
          -- Hint: Validate data
          -- IF p_PARTY_ID is not NULL and p_PARTY_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = AS_UTILITY_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_PARTY_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PARTY_ID;


PROCEDURE Validate_UNPAID_REASON_CODE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_UNPAID_REASON_CODE                IN   VARCHAR2,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     AS_UTILITY_PVT.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
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
          -- Hint: Validate data
          -- IF p_UNPAID_REASON_CODE is not NULL and p_UNPAID_REASON_CODE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = AS_UTILITY_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_UNPAID_REASON_CODE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_UNPAID_REASON_CODE;


PROCEDURE Validate_JUDGEMENT_DATE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_JUDGEMENT_DATE                IN   DATE,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     AS_UTILITY_PVT.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
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
          -- Hint: Validate data
          -- IF p_JUDGEMENT_DATE is not NULL and p_JUDGEMENT_DATE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = AS_UTILITY_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_JUDGEMENT_DATE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_JUDGEMENT_DATE;


PROCEDURE Validate_DISPOSITION_CODE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_DISPOSITION_CODE                IN   VARCHAR2,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     AS_UTILITY_PVT.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
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
          -- Hint: Validate data
          -- IF p_DISPOSITION_CODE is not NULL and p_DISPOSITION_CODE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = AS_UTILITY_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_DISPOSITION_CODE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_DISPOSITION_CODE;


PROCEDURE v_CREDIT_HOLD_REQUEST_FLAG (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_CREDIT_HOLD_REQUEST_FLAG                IN   VARCHAR2,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     AS_UTILITY_PVT.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
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
          -- Hint: Validate data
          -- IF p_CREDIT_HOLD_REQUEST_FLAG is not NULL and p_CREDIT_HOLD_REQUEST_FLAG <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = AS_UTILITY_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_CREDIT_HOLD_REQUEST_FLAG <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END v_CREDIT_HOLD_REQUEST_FLAG;


PROCEDURE v_CREDIT_HOLD_APPROVED_FLAG (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_CREDIT_HOLD_APPROVED_FLAG                IN   VARCHAR2,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     AS_UTILITY_PVT.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
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
          -- Hint: Validate data
          -- IF p_CREDIT_HOLD_APPROVED_FLAG is not NULL and p_CREDIT_HOLD_APPROVED_FLAG <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = AS_UTILITY_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_CREDIT_HOLD_APPROVED_FLAG <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END v_CREDIT_HOLD_APPROVED_FLAG;


PROCEDURE v_SERVICE_HOLD_REQUEST_FLAG (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_SERVICE_HOLD_REQUEST_FLAG                IN   VARCHAR2,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     AS_UTILITY_PVT.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
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
          -- Hint: Validate data
          -- IF p_SERVICE_HOLD_REQUEST_FLAG is not NULL and p_SERVICE_HOLD_REQUEST_FLAG <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = AS_UTILITY_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_SERVICE_HOLD_REQUEST_FLAG <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END v_SERVICE_HOLD_REQUEST_FLAG;


PROCEDURE v_SERVICE_HOLD_APPROVED_FLAG (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_SERVICE_HOLD_APPROVED_FLAG                IN   VARCHAR2,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     AS_UTILITY_PVT.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
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
          -- Hint: Validate data
          -- IF p_SERVICE_HOLD_APPROVED_FLAG is not NULL and p_SERVICE_HOLD_APPROVED_FLAG <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = AS_UTILITY_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_SERVICE_HOLD_APPROVED_FLAG <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END v_SERVICE_HOLD_APPROVED_FLAG;


PROCEDURE v_SUGGESTION_APPROVED_FLAG (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_SUGGESTION_APPROVED_FLAG                IN   VARCHAR2,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     AS_UTILITY_PVT.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
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
          -- Hint: Validate data
          -- IF p_SUGGESTION_APPROVED_FLAG is not NULL and p_SUGGESTION_APPROVED_FLAG <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = AS_UTILITY_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_SUGGESTION_APPROVED_FLAG <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END v_SUGGESTION_APPROVED_FLAG;


-- Hint: inter-field level validation can be added here.
-- Hint: If p_validation_mode = AS_UTILITY_PVT.G_VALIDATE_UPDATE, we should use cursor
--       to get old values for all fields used in inter-field validation and set all G_MISS_XXX fields to original value
--       stored in database table.
PROCEDURE Validate_LTG_rec(
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_LTG_Rec     IN    LTG_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Hint: Validate data
      -- If data not valid
      -- THEN
      -- x_return_status := FND_API.G_RET_STS_ERROR;


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_LTG_Rec;

PROCEDURE Validate_litigation(
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    P_Validation_mode            IN   VARCHAR2,
    P_LTG_Rec     IN    LTG_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
l_api_name   CONSTANT VARCHAR2(30) := 'Validate_litigation';
BEGIN



      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_validation_level >= AS_UTILITY_PUB.G_VALID_LEVEL_ITEM) THEN
          -- Hint: We provide validation procedure for every column. Developer should delete
          --       unnecessary validation procedures.
          Validate_LITIGATION_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_LITIGATION_ID   => P_LTG_Rec.LITIGATION_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT NOCOPY parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);

          Validate_DELINQUENCY_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_DELINQUENCY_ID   => P_LTG_Rec.DELINQUENCY_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT NOCOPY parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);

          Validate_PARTY_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_PARTY_ID   => P_LTG_Rec.PARTY_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT NOCOPY parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);

          Validate_UNPAID_REASON_CODE(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_UNPAID_REASON_CODE   => P_LTG_Rec.UNPAID_REASON_CODE,
              -- Hint: You may add x_item_property_rec as one of your OUT NOCOPY parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);

          Validate_JUDGEMENT_DATE(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_JUDGEMENT_DATE   => P_LTG_Rec.JUDGEMENT_DATE,
              -- Hint: You may add x_item_property_rec as one of your OUT NOCOPY parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);

          Validate_DISPOSITION_CODE(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_DISPOSITION_CODE   => P_LTG_Rec.DISPOSITION_CODE,
              -- Hint: You may add x_item_property_rec as one of your OUT NOCOPY parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);

          v_CREDIT_HOLD_REQUEST_FLAG(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_CREDIT_HOLD_REQUEST_FLAG   => P_LTG_Rec.CREDIT_HOLD_REQUEST_FLAG,
              -- Hint: You may add x_item_property_rec as one of your OUT NOCOPY parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);

          v_CREDIT_HOLD_APPROVED_FLAG(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_CREDIT_HOLD_APPROVED_FLAG   => P_LTG_Rec.CREDIT_HOLD_APPROVED_FLAG,
              -- Hint: You may add x_item_property_rec as one of your OUT NOCOPY parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);

          v_SERVICE_HOLD_REQUEST_FLAG(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_SERVICE_HOLD_REQUEST_FLAG   => P_LTG_Rec.SERVICE_HOLD_REQUEST_FLAG,
              -- Hint: You may add x_item_property_rec as one of your OUT NOCOPY parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);

          v_SERVICE_HOLD_APPROVED_FLAG(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_SERVICE_HOLD_APPROVED_FLAG   => P_LTG_Rec.SERVICE_HOLD_APPROVED_FLAG,
              -- Hint: You may add x_item_property_rec as one of your OUT NOCOPY parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);

          v_SUGGESTION_APPROVED_FLAG(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_SUGGESTION_APPROVED_FLAG   => P_LTG_Rec.SUGGESTION_APPROVED_FLAG,
              -- Hint: You may add x_item_property_rec as one of your OUT NOCOPY parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);

      END IF;

      IF (p_validation_level >= AS_UTILITY_PUB.G_VALID_LEVEL_RECORD) THEN
          -- Hint: Inter-field level validation can be added here
          -- invoke record level validation procedures
          Validate_LTG_Rec(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
          P_LTG_Rec     =>    P_LTG_Rec,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;
      END IF;

      IF (p_validation_level >= AS_UTILITY_PUB.G_VALID_LEVEL_INTER_RECORD) THEN
          -- invoke inter-record level validation procedures
          NULL;
      END IF;

      IF (p_validation_level >= AS_UTILITY_PUB.G_VALID_LEVEL_INTER_ENTITY) THEN
          -- invoke inter-entity level validation procedures
          NULL;
      END IF;


END Validate_litigation;

End IEX_LITIGATION_PVT;

/
