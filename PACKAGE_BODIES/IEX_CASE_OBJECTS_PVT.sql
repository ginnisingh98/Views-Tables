--------------------------------------------------------
--  DDL for Package Body IEX_CASE_OBJECTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_CASE_OBJECTS_PVT" as
/* $Header: iexvcobb.pls 120.1 2006/05/30 21:12:34 scherkas noship $ */
-- Start of Comments
-- Package name     : IEX_case_objects_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'IEX_CASE_OBJECTS_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'iexvcobb.pls';


-- Hint: Primary key needs to be returned.
--PG_DEBUG NUMBER(2) := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));
PG_DEBUG NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

PROCEDURE Create_case_objects(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_case_object_Rec            IN    case_object_Rec_Type  := G_MISS_case_object_REC,
    X_CASE_OBJECT_ID             OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'CREATE_CASE_OBJECTS';
l_api_version_number      CONSTANT NUMBER   := 2.0;

v_rowid                    VARCHAR2(24);
v_case_object_id           iex_case_objects.case_object_id%TYPE;
v_active_flag           iex_case_objects.active_flag%TYPE;
v_object_version_number    iex_case_objects.object_version_number%TYPE;
 Cursor c2 is SELECT IEX_CASE_OBJECTS_S.nextval from dual;
 BEGIN
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         IEX_DEBUG_PUB.LogMessage ('********* Start of Procedure =>IEX_CASE_OBJECTS_PVT.Create_case_objects ******** ');
      END IF;
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_case_objects_PVT;

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
         IEX_DEBUG_PUB.LogMessage('Create_case_objects: ' || 'After Compatibility Check');
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
         IEX_DEBUG_PUB.LogMessage('Create_case_objects: ' || 'After Global user Check');
      END IF;

        --object version Number
      v_object_version_number :=1;
      --Active Flag
	  v_active_flag :='Y';
--	  IF PG_DEBUG < 10  THEN
	  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	     IEX_DEBUG_PUB.LogMessage('Create_case_objects: ' || 'After active flag  Check' );
	  END IF;




      -- get case_object_id
       OPEN C2;
       FETCH C2 INTO v_CASE_OBJECT_ID;
       CLOSE C2;
--       IF PG_DEBUG < 10  THEN
       IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
          IEX_DEBUG_PUB.LogMessage('Create_case_objects: ' || 'After Case OBJECT ID Check and case_object_id is => '||v_case_object_id);
       END IF;

      -- Invoke table handler(IEX_CASE_OBJECTS_PKG.Insert_Row)
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         IEX_DEBUG_PUB.LogMessage('Create_case_objects: ' || 'Before Calling IEX_CASE_OBJECTS_PKG.Insert_Row');
      END IF;
      IEX_CASE_OBJECTS_PKG.Insert_Row(
          x_rowid                  =>v_rowid,
          x_CASE_OBJECT_ID         => v_CASE_OBJECT_ID,
          x_OBJECT_ID              => p_case_object_rec.OBJECT_ID,
          x_OBJECT_CODE            => p_case_object_rec.OBJECT_CODE,
          x_active_flag            => v_active_flag,
          x_OBJECT_VERSION_NUMBER  => v_OBJECT_VERSION_NUMBER,
          x_CAS_ID                 => p_case_object_rec.CAS_ID,
          x_REQUEST_ID             => p_case_object_rec.REQUEST_ID,
          x_PROGRAM_APPLICATION_ID => p_case_object_rec.PROGRAM_APPLICATION_ID,
          x_PROGRAM_ID             => p_case_object_rec.PROGRAM_ID,
          x_PROGRAM_UPDATE_DATE    => p_case_object_rec.PROGRAM_UPDATE_DATE,
          x_ATTRIBUTE_CATEGORY     => p_case_object_rec.ATTRIBUTE_CATEGORY,
          x_ATTRIBUTE1            => p_case_object_rec.ATTRIBUTE1,
          x_ATTRIBUTE2            => p_case_object_rec.ATTRIBUTE2,
          x_ATTRIBUTE3  => p_case_object_rec.ATTRIBUTE3,
          x_ATTRIBUTE4  => p_case_object_rec.ATTRIBUTE4,
          x_ATTRIBUTE5  => p_case_object_rec.ATTRIBUTE5,
          x_ATTRIBUTE6  => p_case_object_rec.ATTRIBUTE6,
          x_ATTRIBUTE7  => p_case_object_rec.ATTRIBUTE7,
          x_ATTRIBUTE8  => p_case_object_rec.ATTRIBUTE8,
          x_ATTRIBUTE9  => p_case_object_rec.ATTRIBUTE9,
          x_ATTRIBUTE10  => p_case_object_rec.ATTRIBUTE10,
          x_ATTRIBUTE11  => p_case_object_rec.ATTRIBUTE11,
          x_ATTRIBUTE12  => p_case_object_rec.ATTRIBUTE12,
          x_ATTRIBUTE13  => p_case_object_rec.ATTRIBUTE13,
          x_ATTRIBUTE14  => p_case_object_rec.ATTRIBUTE14,
          x_ATTRIBUTE15  => p_case_object_rec.ATTRIBUTE15,
          x_CREATED_BY  => FND_GLOBAL.USER_ID,
          x_CREATION_DATE  => SYSDATE,
          x_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID,
          x_LAST_UPDATE_DATE  => SYSDATE,
          x_LAST_UPDATE_LOGIN  => FND_GLOBAL.CONC_LOGIN_ID);

      -- Hint: Primary key should be returned.
        x_CASE_OBJECT_ID := v_CASE_OBJECT_ID;
--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           IEX_DEBUG_PUB.LogMessage('Create_case_objects: ' || 'After Calling IEX_CASE_OBJECTS_PKG.Insert_Row and case objectid => '||x_CASE_OBJECT_ID);
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
         IEX_DEBUG_PUB.LogMessage ('********* End of Procedure =>IEX_CASE_OBJECTS_PVT.Create_case_objects ******** ');
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
End Create_case_objects;


-- Hint: Add corresponding update detail table procedures if it's master-detail relationship.
PROCEDURE Update_case_objects(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_case_object_Rec            IN    case_object_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
     XO_OBJECT_VERSION_NUMBER     OUT NOCOPY  NUMBER
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'UPDATE_CASE_OBJECTS';
l_api_version_number      CONSTANT NUMBER   := 2.0;
l_object_version_number iex_case_objects.object_version_number%TYPE:=p_case_object_rec.object_version_number;
 BEGIN
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         IEX_DEBUG_PUB.LogMessage ('********* Start of Procedure =>IEX_CASE_OBJECTS_PVT.update_case_objects ******** ');
      END IF;
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_case_objects_PVT;

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

      -- Invoke table handler(IEX_CASE_OBJECTS_PKG.Update_Row)
       -- call locking table handler
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         IEX_DEBUG_PUB.LogMessage('Update_case_objects: ' || 'Before Calling IEX_CASE_OBJECTS_PKG.lock_row');
      END IF;
      IEX_CASE_OBJECTS_PKG.lock_row (
         p_case_object_rec.CASE_OBJECT_ID,
         l_object_version_number
      );
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         IEX_DEBUG_PUB.LogMessage('Update_case_objects: ' || 'Before Calling IEX_CASE_OBJECTS_PKG.update_row');
      END IF;
      IEX_CASE_OBJECTS_PKG.Update_Row(
          x_CASE_OBJECT_ID  => p_case_object_rec.CASE_OBJECT_ID,
          x_OBJECT_ID  => p_case_object_rec.OBJECT_ID,
          x_OBJECT_CODE  => p_case_object_rec.OBJECT_CODE,
          x_ACTIVE_FLAG  => p_case_object_rec.ACTIVE_FLAG,
          x_OBJECT_VERSION_NUMBER  => l_OBJECT_VERSION_NUMBER +1,
          x_CAS_ID  => p_case_object_rec.CAS_ID,
          x_REQUEST_ID  => p_case_object_rec.REQUEST_ID,
          x_PROGRAM_APPLICATION_ID  => p_case_object_rec.PROGRAM_APPLICATION_ID,
          x_PROGRAM_ID  => p_case_object_rec.PROGRAM_ID,
          x_PROGRAM_UPDATE_DATE  => p_case_object_rec.PROGRAM_UPDATE_DATE,
          x_ATTRIBUTE_CATEGORY  => p_case_object_rec.ATTRIBUTE_CATEGORY,
          x_ATTRIBUTE1  => p_case_object_rec.ATTRIBUTE1,
          x_ATTRIBUTE2  => p_case_object_rec.ATTRIBUTE2,
          x_ATTRIBUTE3  => p_case_object_rec.ATTRIBUTE3,
          x_ATTRIBUTE4  => p_case_object_rec.ATTRIBUTE4,
          x_ATTRIBUTE5  => p_case_object_rec.ATTRIBUTE5,
          x_ATTRIBUTE6  => p_case_object_rec.ATTRIBUTE6,
          x_ATTRIBUTE7  => p_case_object_rec.ATTRIBUTE7,
          x_ATTRIBUTE8  => p_case_object_rec.ATTRIBUTE8,
          x_ATTRIBUTE9  => p_case_object_rec.ATTRIBUTE9,
          x_ATTRIBUTE10  => p_case_object_rec.ATTRIBUTE10,
          x_ATTRIBUTE11  => p_case_object_rec.ATTRIBUTE11,
          x_ATTRIBUTE12  => p_case_object_rec.ATTRIBUTE12,
          x_ATTRIBUTE13  => p_case_object_rec.ATTRIBUTE13,
          x_ATTRIBUTE14  => p_case_object_rec.ATTRIBUTE14,
          x_ATTRIBUTE15  => p_case_object_rec.ATTRIBUTE15,
          x_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID,
          x_LAST_UPDATE_DATE  => SYSDATE,
          x_LAST_UPDATE_LOGIN  => FND_GLOBAL.CONC_LOGIN_ID);

      --Return Version number
      xo_object_version_number := l_object_version_number + 1;
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
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         IEX_DEBUG_PUB.LogMessage ('********* end of Procedure =>IEX_CASE_OBJECTS_PVT.update_case_objects ******** ');
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
End Update_case_objects;


-- Hint: Add corresponding delete detail table procedures if it's master-detail relationship.
--       The Master delete procedure may not be needed depends on different business requirements.
PROCEDURE Delete_case_objects(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_case_object_ID             IN    NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'DELETE_CASE_OBJECTS';
l_api_version_number      CONSTANT NUMBER   := 2.0;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_case_objects_PVT;

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

      -- Invoke table handler(IEX_CASE_OBJECTS_PKG.Delete_Row)
      IEX_CASE_OBJECTS_PKG.Delete_Row(
          X_CASE_OBJECT_ID  => p_CASE_OBJECT_ID);
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
End Delete_case_objects;


End IEX_case_objects_PVT;

/
