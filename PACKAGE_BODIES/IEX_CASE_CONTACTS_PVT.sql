--------------------------------------------------------
--  DDL for Package Body IEX_CASE_CONTACTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_CASE_CONTACTS_PVT" as
/* $Header: iexvconb.pls 120.1 2006/05/30 21:13:08 scherkas noship $ */
-- Start of Comments
-- Package name     : IEX_CASE_CONTACTS_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'IEX_CASE_CONTACTS_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'iexvconb.pls';


-- Hint: Primary key needs to be returned.
--PG_DEBUG NUMBER(2) := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));
PG_DEBUG NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

PROCEDURE Create_case_contact(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_case_contact_Rec           IN    case_contact_Rec_Type  := G_MISS_case_contact_REC,
    X_CAS_CONTACT_ID             OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Create_case_contact';
l_api_version_number      CONSTANT NUMBER   := 2.0;
l_return_status_full      VARCHAR2(1);
v_rowid                   VARCHAR2(24);
v_cas_contact_id          iex_case_contacts.cas_contact_id%TYPE;
v_object_version_number   iex_case_contacts.object_version_number%TYPE;
v_active_flag             iex_case_contacts.active_flag%TYPE;
v_address_id              iex_case_contacts.address_id%TYPE;
v_phone_id                iex_case_contacts.phone_id%TYPE;
v_primary_flag            iex_case_contacts.primary_flag%TYPE;

Cursor c2 is SELECT IEX_CASE_CONTACTS_S.nextval from dual;

CURSOR C_GET_ADDRESS(P_PARTY_ID NUMBER) IS
   SELECT PARTY_SITE_ID
   FROM HZ_PARTY_SITES
   WHERE PARTY_ID = P_PARTY_ID
   AND IDENTIFYING_ADDRESS_FLAG = 'Y';

cursor c_get_phone(x_owner_table_id number) is
    select contact_point_id
    from hz_contact_points
    where owner_table_id = x_owner_table_id
    and owner_table_name = 'HZ_PARTIES'
    and contact_point_type = 'PHONE'
    and primary_flag = 'Y';

 BEGIN
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         IEX_DEBUG_PUB.LogMessage ('********* start of Procedure =>IEX_CASE_CONTACTS_PVT.Create_case_contact ******** ');
      END IF;
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_CASE_CONTACT_PVT;

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
         IEX_DEBUG_PUB.LogMessage('Create_case_contact: ' || 'After Compatibility Check');
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
         IEX_DEBUG_PUB.LogMessage('Create_case_contact: ' || 'After Global user Check');
      END IF;

      --IF p_validation_level = FND_API.G_VALID_LEVEL_FULL THEN

         --object version Number
         v_object_version_number :=1;
	    --Active_flag
	    v_active_flag :='Y';

         -- get cas_id
            OPEN C2;
            FETCH C2 INTO v_CAS_CONTACT_ID;
            CLOSE C2;
--         IF PG_DEBUG < 10  THEN
         IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
            IEX_DEBUG_PUB.LogMessage('Create_case_contact: ' || 'After CAS CONTACT ID Check and cas_contact_id is => '||v_cas_contact_id);
         END IF;
         --check for cas_id
           IF (p_case_contact_rec.cas_id IS NULL) OR (p_case_contact_rec.cas_ID = FND_API.G_MISS_NUM) THEN
               fnd_message.set_name('IEX', 'IEX_API_ALL_MISSING_PARAM');
               fnd_message.set_token('API_NAME', l_api_name);
               fnd_message.set_token('MISSING_PARAM', 'cas_id');
               fnd_msg_pub.add;
               RAISE FND_API.G_EXC_ERROR;
           END IF;
--           IF PG_DEBUG < 10  THEN
           IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
              IEX_DEBUG_PUB.LogMessage('Create_case_contact: ' || 'After CAS ID Check ');
           END IF;
         --check for contact_party_id
           IF (p_case_contact_rec.contact_party_id IS NULL) OR (p_case_contact_rec.contact_party_id = FND_API.G_MISS_NUM) THEN
               fnd_message.set_name('IEX', 'IEX_API_ALL_MISSING_PARAM');
               fnd_message.set_token('API_NAME', l_api_name);
               fnd_message.set_token('MISSING_PARAM', 'contact_party_id');
               fnd_msg_pub.add;
               RAISE FND_API.G_EXC_ERROR;
           END IF;
--           IF PG_DEBUG < 10  THEN
           IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
              IEX_DEBUG_PUB.LogMessage('Create_case_contact: ' || 'After CAS contact ID Check ');
           END IF;
           --Populate default address_id if it is not passed
              IF (p_case_contact_rec.address_id IS NULL)
                   OR (p_case_contact_rec.address_id = FND_API.G_MISS_NUM) THEN
                 OPEN  C_GET_ADDRESS(p_case_contact_rec.CONTACT_PARTY_ID);
                 FETCH C_GET_ADDRESS INTO v_address_id;
                 CLOSE C_GET_ADDRESS;
              ELSE
                 v_address_id :=p_case_contact_rec.address_id;
              END IF;
           --Populate default phone_id if it is not passed
              IF (p_case_contact_rec.phone_id IS NULL)
                   OR (p_case_contact_rec.phone_id = FND_API.G_MISS_NUM) THEN
                 OPEN  C_GET_phone(p_case_contact_rec.CONTACT_PARTY_ID);
                 FETCH C_GET_phone INTO v_phone_id;
                 CLOSE C_GET_phone;
              ELSE
                 v_phone_id :=p_case_contact_rec.phone_id;
              END IF;
           -- Primary flag // added on 01/07/02
           IF (p_case_contact_rec.primary_flag IS NULL)
                OR (p_case_contact_rec.primary_flag = FND_API.G_MISS_CHAR) THEN
                    v_primary_flag :='N';
           ELSE
                v_primary_flag :=p_case_contact_rec.primary_flag;
           END IF;

      --END IF;
--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           IEX_DEBUG_PUB.LogMessage('Create_case_contact: ' || 'Before calling IEX_CASE_CONTACTS_PKG.Insert_Row');
        END IF;
        -- Invoke table handler(IEX_CASE_CONTACTS_PKG.Insert_Row)
      IEX_CASE_CONTACTS_PKG.Insert_Row(
          x_rowid                  =>v_rowid,
          p_CAS_CONTACT_ID         => v_CAS_CONTACT_ID,
          p_CAS_ID                 => p_case_contact_rec.CAS_ID,
          p_CONTACT_PARTY_ID       => p_case_contact_rec.CONTACT_PARTY_ID,
          p_OBJECT_VERSION_NUMBER  => v_OBJECT_VERSION_NUMBER,
          p_ACTIVE_FLAG            => v_ACTIVE_FLAG,
          p_address_id             => v_address_id,
          p_phone_id               => v_phone_id,
          p_REQUEST_ID             => p_case_contact_rec.REQUEST_ID,
          p_PROGRAM_APPLICATION_ID => p_case_contact_rec.PROGRAM_APPLICATION_ID,
          p_PROGRAM_ID             => p_case_contact_rec.PROGRAM_ID,
          p_PROGRAM_UPDATE_DATE    => p_case_contact_rec.PROGRAM_UPDATE_DATE,
          p_ATTRIBUTE_CATEGORY     => p_case_contact_rec.ATTRIBUTE_CATEGORY,
          p_ATTRIBUTE1  => p_case_contact_rec.ATTRIBUTE1,
          p_ATTRIBUTE2  => p_case_contact_rec.ATTRIBUTE2,
          p_ATTRIBUTE3  => p_case_contact_rec.ATTRIBUTE3,
          p_ATTRIBUTE4  => p_case_contact_rec.ATTRIBUTE4,
          p_ATTRIBUTE5  => p_case_contact_rec.ATTRIBUTE5,
          p_ATTRIBUTE6  => p_case_contact_rec.ATTRIBUTE6,
          p_ATTRIBUTE7  => p_case_contact_rec.ATTRIBUTE7,
          p_ATTRIBUTE8  => p_case_contact_rec.ATTRIBUTE8,
          p_ATTRIBUTE9  => p_case_contact_rec.ATTRIBUTE9,
          p_ATTRIBUTE10  => p_case_contact_rec.ATTRIBUTE10,
          p_ATTRIBUTE11  => p_case_contact_rec.ATTRIBUTE11,
          p_ATTRIBUTE12  => p_case_contact_rec.ATTRIBUTE12,
          p_ATTRIBUTE13  => p_case_contact_rec.ATTRIBUTE13,
          p_ATTRIBUTE14  => p_case_contact_rec.ATTRIBUTE14,
          p_ATTRIBUTE15  => p_case_contact_rec.ATTRIBUTE15,
          p_CREATED_BY         => FND_GLOBAL.USER_ID,
          p_CREATION_DATE      => SYSDATE,
          p_LAST_UPDATED_BY    => FND_GLOBAL.USER_ID,
          p_LAST_UPDATE_DATE   => SYSDATE,
          p_LAST_UPDATE_LOGIN  => p_case_contact_rec.LAST_UPDATE_LOGIN,
          p_PRIMARY_FLAG       => V_PRIMARY_FLAG
          );

          x_CAS_CONTACT_ID := V_CAS_CONTACT_ID;
--          IF PG_DEBUG < 10  THEN
          IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
             IEX_DEBUG_PUB.LogMessage('Create_case_contact: ' || 'After Calling IEX_CASE_CONTACTS_PKG.Insert_Row and cas Contact id => '
                                    ||x_cas_contact_id);
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
         IEX_DEBUG_PUB.LogMessage ('********* End of Procedure =>IEX_CASE_CONTACTS_PVT.Create_case_contact ******** ');
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
End Create_case_contact;


-- Hint: Add corresponding update detail table procedures if it's master-detail relationship.
PROCEDURE Update_case_contact(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_case_contact_Rec           IN    case_contact_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    xo_object_version_number     OUT NOCOPY NUMBER

    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'UPDATE_CASE_CONTACT';
l_api_version_number      CONSTANT NUMBER   := 2.0;
l_object_version_number iex_case_contacts.object_version_number%TYPE:=p_case_contact_rec.object_version_number;
 BEGIN
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         IEX_DEBUG_PUB.LogMessage ('********* start of Procedure =>IEX_CASE_CONTACTS_PVT.update_case_contact ******** ');
      END IF;
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_case_contact_PVT;

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
      IEX_CASE_CONTACTS_PKG.lock_row (
         p_case_contact_rec.cas_contact_id,
         l_object_version_number
      );

      -- Invoke table handler(IEX_CASE_CONTACTS_PKG.Update_Row)
      IEX_CASE_CONTACTS_PKG.Update_Row(
          p_CAS_CONTACT_ID         => p_case_contact_rec.CAS_CONTACT_ID,
          p_CAS_ID                 => p_case_contact_rec.CAS_ID,
          p_CONTACT_PARTY_ID       => p_case_contact_rec.CONTACT_PARTY_ID,
          p_OBJECT_VERSION_NUMBER  => l_OBJECT_VERSION_NUMBER +1,
          p_ACTIVE_FLAG           => p_case_contact_rec.ACTIVE_FLAG,
          p_REQUEST_ID             => p_case_contact_rec.REQUEST_ID,
          p_address_id             => p_case_contact_rec.address_id,
          p_phone_id               => p_case_contact_rec.phone_id,
          p_PROGRAM_APPLICATION_ID => p_case_contact_rec.PROGRAM_APPLICATION_ID,
          p_PROGRAM_ID             => p_case_contact_rec.PROGRAM_ID,
          p_PROGRAM_UPDATE_DATE    => p_case_contact_rec.PROGRAM_UPDATE_DATE,
          p_ATTRIBUTE_CATEGORY     => p_case_contact_rec.ATTRIBUTE_CATEGORY,
          p_ATTRIBUTE1  => p_case_contact_rec.ATTRIBUTE1,
          p_ATTRIBUTE2  => p_case_contact_rec.ATTRIBUTE2,
          p_ATTRIBUTE3  => p_case_contact_rec.ATTRIBUTE3,
          p_ATTRIBUTE4  => p_case_contact_rec.ATTRIBUTE4,
          p_ATTRIBUTE5  => p_case_contact_rec.ATTRIBUTE5,
          p_ATTRIBUTE6  => p_case_contact_rec.ATTRIBUTE6,
          p_ATTRIBUTE7  => p_case_contact_rec.ATTRIBUTE7,
          p_ATTRIBUTE8  => p_case_contact_rec.ATTRIBUTE8,
          p_ATTRIBUTE9  => p_case_contact_rec.ATTRIBUTE9,
          p_ATTRIBUTE10  => p_case_contact_rec.ATTRIBUTE10,
          p_ATTRIBUTE11  => p_case_contact_rec.ATTRIBUTE11,
          p_ATTRIBUTE12  => p_case_contact_rec.ATTRIBUTE12,
          p_ATTRIBUTE13  => p_case_contact_rec.ATTRIBUTE13,
          p_ATTRIBUTE14  => p_case_contact_rec.ATTRIBUTE14,
          p_ATTRIBUTE15  => p_case_contact_rec.ATTRIBUTE15,
          p_LAST_UPDATED_BY    => FND_GLOBAL.USER_ID,
          p_LAST_UPDATE_DATE   => SYSDATE,
          p_LAST_UPDATE_LOGIN  => p_case_contact_rec.LAST_UPDATE_LOGIN,
          p_PRIMARY_FLAG       => p_case_contact_rec.PRIMARY_FLAG);

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
         IEX_DEBUG_PUB.LogMessage ('********* end of Procedure =>IEX_CASE_CONTACTS_PVT.update_case_contact ******** ');
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
End Update_case_contact;


-- Hint: Add corresponding delete detail table procedures if it's master-detail relationship.
--       The Master delete procedure may not be needed depends on different business requirements.
PROCEDURE Delete_case_contact(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_cas_contact_ID             IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'DELETE_CASE_CONTACT';
l_api_version_number      CONSTANT NUMBER   := 2.0;

 BEGIN
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         IEX_DEBUG_PUB.LogMessage ('********* start of Procedure =>IEX_CASE_CONTACTS_PVT.delete_case_contact ******** ');
      END IF;
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_case_contact_PVT;

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

      -- Invoke table handler(IEX_CASE_CONTACTS_PKG.Delete_Row)
      IEX_CASE_CONTACTS_PKG.Delete_Row(
          p_CAS_CONTACT_ID  => p_CAS_CONTACT_ID);
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
         IEX_DEBUG_PUB.LogMessage ('********* End of Procedure =>IEX_CASE_CONTACTS_PVT.delete_case_contact ******** ');
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
End Delete_case_contact;


End IEX_CASE_CONTACTS_PVT;

/
