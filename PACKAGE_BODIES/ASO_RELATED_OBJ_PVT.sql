--------------------------------------------------------
--  DDL for Package Body ASO_RELATED_OBJ_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_RELATED_OBJ_PVT" as
/* $Header: asovobjb.pls 120.1 2005/06/29 12:42:22 appldev ship $ */
-- Start of Comments
-- Package name     : aso_RELATED_OBJ_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'aso_RELATED_OBJ_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'asovobjb.pls';


-- Hint: Primary key needs to be returned.
PROCEDURE Create_related_obj(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
  p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
  P_RELATED_OBJ_Rec     IN    ASO_quote_PUB.RELATED_OBJ_Rec_Type  := ASO_quote_PUB.G_MISS_RELATED_OBJ_REC,
    X_RELATED_OBJECT_ID     OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Create_related_obj';
G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_return_status_full        VARCHAR2(1);
l_x_status                VARCHAR2(1);

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_RELATED_OBJ_PVT;

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
              FND_MESSAGE.Set_Name(' + appShortName +', 'UT_CANNOT_GET_PROFILE_VALUE');
              FND_MESSAGE.Set_Token('PROFILE', 'USER_ID', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;



         IF ( P_validation_level >= ASO_UTILITY_PVT.G_VALID_LEVEL_ITEM) THEN



          -- Invoke validation procedures
    ASO_VALIDATE_PVT.Validate_QTE_OBJ_TYPE_CODE (
    P_Init_Msg_List            =>     P_Init_Msg_List  ,
    P_QUOTE_OBJECT_TYPE_CODE   => P_RELATED_OBJ_Rec.QUOTE_OBJECT_TYPE_CODE,
    X_Return_Status           => X_Return_Status ,
    X_Msg_Count               => X_Msg_Count  ,
    X_Msg_Data                =>  X_Msg_Data
    );
        IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
     ASO_VALIDATE_PVT.Validate_OBJECT_TYPE_CODE (
    P_Init_Msg_List            =>     P_Init_Msg_List  ,
    P_OBJECT_TYPE_CODE   => P_RELATED_OBJ_Rec.OBJECT_TYPE_CODE,
    X_Return_Status           => X_Return_Status ,
    X_Msg_Count               => X_Msg_Count  ,
    X_Msg_Data                =>  X_Msg_Data
    );
        IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
 	 ASO_VALIDATE_PVT.Validate_RLTSHIP_TYPE_CODE (
    P_Init_Msg_List            =>     P_Init_Msg_List  ,
    P_RELATIONSHIP_TYPE_CODE   => P_RELATED_OBJ_Rec.RELATIONSHIP_TYPE_CODE,
    X_Return_Status           => X_Return_Status ,
    X_Msg_Count               => X_Msg_Count  ,
    X_Msg_Data                =>  X_Msg_Data
    );
        IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


     END IF;

     IF p_related_obj_rec.quote_object_type_code = 'HEADER' and
        p_related_obj_rec.quote_object_id is not null THEN

          aso_conc_req_int.lock_exists( p_quote_header_id  =>  p_related_obj_rec.quote_object_id,
                                        x_status           =>  l_x_status );

          IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('create_related_obj: l_x_status: '|| l_x_status);
          END IF;

          if l_x_status = fnd_api.g_true then

              if fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) then
                  fnd_message.set_name('ASO', 'ASO_CONC_REQUEST_RUNNING');
                  fnd_msg_pub.add;
              end if;

              x_return_status := fnd_api.g_ret_sts_error;
              raise fnd_api.g_exc_error;

          end if;

     END IF;

      -- Invoke table handler(ASO_QUOTE_RELATED_OBJECTS_PKG.Insert_Row)
      ASO_QUOTE_RELATED_OBJECTS_PKG.Insert_Row(
          px_RELATED_OBJECT_ID  => x_RELATED_OBJECT_ID,
          p_CREATION_DATE  => SYSDATE,
          p_CREATED_BY  => G_USER_ID,
          p_LAST_UPDATE_DATE  => SYSDATE,
          p_LAST_UPDATED_BY  => G_USER_ID,
          p_LAST_UPDATE_LOGIN  => G_LOGIN_ID,
          p_REQUEST_ID  => p_RELATED_OBJ_rec.REQUEST_ID,
         p_PROGRAM_APPLICATION_ID  => p_RELATED_OBJ_rec.PROGRAM_APPLICATION_ID,
          p_PROGRAM_ID  => p_RELATED_OBJ_rec.PROGRAM_ID,
          p_PROGRAM_UPDATE_DATE  => p_RELATED_OBJ_rec.PROGRAM_UPDATE_DATE,
         p_QUOTE_OBJECT_TYPE_CODE  => p_RELATED_OBJ_rec.QUOTE_OBJECT_TYPE_CODE,
          p_QUOTE_OBJECT_ID  => p_RELATED_OBJ_rec.QUOTE_OBJECT_ID,
          p_OBJECT_TYPE_CODE  => p_RELATED_OBJ_rec.OBJECT_TYPE_CODE,
          p_OBJECT_ID  => p_RELATED_OBJ_rec.OBJECT_ID,
         p_RELATIONSHIP_TYPE_CODE  => p_RELATED_OBJ_rec.RELATIONSHIP_TYPE_CODE,
          p_RECIPROCAL_FLAG  => p_RELATED_OBJ_rec.RECIPROCAL_FLAG,
		p_OBJECT_VERSION_NUMBER => p_RELATED_OBJ_rec.OBJECT_VERSION_NUMBER);


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
	      ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
		   P_API_NAME => L_API_NAME
		  ,P_PKG_NAME => G_PKG_NAME
		  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
		  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
		  ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
		  ,X_MSG_COUNT => X_MSG_COUNT
		  ,X_MSG_DATA => X_MSG_DATA
		  ,X_RETURN_STATUS => X_RETURN_STATUS);

	  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	      ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
		   P_API_NAME => L_API_NAME
		  ,P_PKG_NAME => G_PKG_NAME
		  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
		  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
		  ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
		  ,X_MSG_COUNT => X_MSG_COUNT
		  ,X_MSG_DATA => X_MSG_DATA
		  ,X_RETURN_STATUS => X_RETURN_STATUS);

	  WHEN OTHERS THEN
	      ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
		   P_API_NAME => L_API_NAME
		  ,P_PKG_NAME => G_PKG_NAME
		  ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
		  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
		  ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
		  ,X_MSG_COUNT => X_MSG_COUNT
		  ,X_MSG_DATA => X_MSG_DATA
		  ,X_RETURN_STATUS => X_RETURN_STATUS);

End Create_related_obj;




PROCEDURE Update_related_obj(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_RELATED_OBJ_Rec     IN    ASO_QUOTE_PUB.RELATED_OBJ_Rec_Type,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    )

 IS

Cursor C_Get_related_obj(RELATED_OBJECT_ID Number) IS
    Select --rowid,
           RELATED_OBJECT_ID,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_LOGIN,
           REQUEST_ID,
           PROGRAM_APPLICATION_ID,
           PROGRAM_ID,
           PROGRAM_UPDATE_DATE,
           QUOTE_OBJECT_TYPE_CODE,
           QUOTE_OBJECT_ID,
           OBJECT_TYPE_CODE,
           OBJECT_ID,
           RELATIONSHIP_TYPE_CODE,
           RECIPROCAL_FLAG
        --   QUOTE_OBJECT_CODE
    From  ASO_QUOTE_RELATED_OBJECTS
    where related_object_id = P_RELATED_OBJ_Rec.related_object_id;
    --For Update NOWAIT;

l_api_name                CONSTANT VARCHAR2(30) := 'Update_related_obj';
l_api_version_number      CONSTANT NUMBER   := 1.0;

l_ref_RELATED_OBJ_rec  aso_quote_pub.RELATED_OBJ_Rec_Type;
l_tar_RELATED_OBJ_rec  aso_quote_pub.RELATED_OBJ_Rec_Type := P_RELATED_OBJ_Rec;
l_rowid  ROWID;
G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
l_x_status        varchar2(1);

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_RELATED_OBJ_PVT;

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

      Open C_Get_related_obj( l_tar_RELATED_OBJ_rec.RELATED_OBJECT_ID);

      Fetch C_Get_related_obj into
              -- l_rowid,
               l_ref_RELATED_OBJ_rec.RELATED_OBJECT_ID,
               l_ref_RELATED_OBJ_rec.CREATION_DATE,
               l_ref_RELATED_OBJ_rec.CREATED_BY,
               l_ref_RELATED_OBJ_rec.LAST_UPDATE_DATE,
               l_ref_RELATED_OBJ_rec.LAST_UPDATED_BY,
               l_ref_RELATED_OBJ_rec.LAST_UPDATE_LOGIN,
               l_ref_RELATED_OBJ_rec.REQUEST_ID,
               l_ref_RELATED_OBJ_rec.PROGRAM_APPLICATION_ID,
               l_ref_RELATED_OBJ_rec.PROGRAM_ID,
               l_ref_RELATED_OBJ_rec.PROGRAM_UPDATE_DATE,
               l_ref_RELATED_OBJ_rec.QUOTE_OBJECT_TYPE_CODE,
               l_ref_RELATED_OBJ_rec.QUOTE_OBJECT_ID,
               l_ref_RELATED_OBJ_rec.OBJECT_TYPE_CODE,
               l_ref_RELATED_OBJ_rec.OBJECT_ID,
               l_ref_RELATED_OBJ_rec.RELATIONSHIP_TYPE_CODE,
               l_ref_RELATED_OBJ_rec.RECIPROCAL_FLAG;
          --     l_ref_RELATED_OBJ_rec.QUOTE_OBJECT_CODE;

       If ( C_Get_related_obj%NOTFOUND) Then
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
               FND_MESSAGE.Set_Name('aso', 'API_MISSING_UPDATE_TARGET');
               FND_MESSAGE.Set_Token ('INFO', 'related_obj', FALSE);
               FND_MSG_PUB.Add;
           END IF;
           raise FND_API.G_EXC_ERROR;
       END IF;
       -- Debug Message
      -- ASO_UTILITY_PVT.Print(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'Private API: - Close Cursor');
       Close     C_Get_related_obj;



      If (l_tar_RELATED_OBJ_rec.last_update_date is NULL or
          l_tar_RELATED_OBJ_rec.last_update_date = FND_API.G_MISS_Date ) Then
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('aso', 'API_MISSING_ID');
              FND_MESSAGE.Set_Token('COLUMN', 'Last_Update_Date', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          raise FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      If (l_tar_RELATED_OBJ_rec.last_update_date <> l_ref_RELATED_OBJ_rec.last_update_date) Then
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('aso', 'API_RECORD_CHANGED');
              FND_MESSAGE.Set_Token('INFO', 'related_obj', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          raise FND_API.G_EXC_ERROR;
      End if;

     IF ( P_validation_level >= ASO_UTILITY_PVT.G_VALID_LEVEL_ITEM) THEN

	 ASO_VALIDATE_PVT.Validate_QTE_OBJ_TYPE_CODE (
    P_Init_Msg_List            =>     P_Init_Msg_List  ,
    P_QUOTE_OBJECT_TYPE_CODE   => P_RELATED_OBJ_Rec.QUOTE_OBJECT_TYPE_CODE,
    X_Return_Status           => X_Return_Status ,
    X_Msg_Count               => X_Msg_Count  ,
    X_Msg_Data                =>  X_Msg_Data
    );
        IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
     ASO_VALIDATE_PVT.Validate_OBJECT_TYPE_CODE (
    P_Init_Msg_List            =>     P_Init_Msg_List  ,
    P_OBJECT_TYPE_CODE   => P_RELATED_OBJ_Rec.OBJECT_TYPE_CODE,
    X_Return_Status           => X_Return_Status ,
    X_Msg_Count               => X_Msg_Count  ,
    X_Msg_Data                =>  X_Msg_Data
    );
        IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
 	 ASO_VALIDATE_PVT.Validate_RLTSHIP_TYPE_CODE(
    P_Init_Msg_List            =>     P_Init_Msg_List  ,
    P_RELATIONSHIP_TYPE_CODE   => P_RELATED_OBJ_Rec.RELATIONSHIP_TYPE_CODE,
    X_Return_Status           => X_Return_Status ,
    X_Msg_Count               => X_Msg_Count  ,
    X_Msg_Data                =>  X_Msg_Data
    );
        IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      END IF;

      IF p_related_obj_rec.quote_object_type_code = 'HEADER' and
         p_related_obj_rec.quote_object_id is not null THEN

          aso_conc_req_int.lock_exists( p_quote_header_id  =>  p_related_obj_rec.quote_object_id ,
                                        x_status           =>  l_x_status );

          IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('update_related_obj: l_x_status: '|| l_x_status);
          END IF;

          if l_x_status = fnd_api.g_true then

              if fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) then
                  fnd_message.set_name('ASO', 'ASO_CONC_REQUEST_RUNNING');
                  fnd_msg_pub.add;
              end if;

              x_return_status := fnd_api.g_ret_sts_error;
              raise fnd_api.g_exc_error;

          end if;

     END IF;

      -- Invoke table handler(ASO_QUOTE_RELATED_OBJECTS_PKG.Update_Row)
      ASO_QUOTE_RELATED_OBJECTS_PKG.Update_Row(
          p_RELATED_OBJECT_ID  => p_RELATED_OBJ_rec.RELATED_OBJECT_ID,
          p_CREATION_DATE  => SYSDATE,
          p_CREATED_BY  => G_USER_ID,
          p_LAST_UPDATE_DATE  => SYSDATE,
          p_LAST_UPDATED_BY  => G_USER_ID,
          p_LAST_UPDATE_LOGIN  => G_LOGIN_ID,
          p_REQUEST_ID  => p_RELATED_OBJ_rec.REQUEST_ID,
          p_PROGRAM_APPLICATION_ID  => p_RELATED_OBJ_rec.PROGRAM_APPLICATION_ID,
          p_PROGRAM_ID  => p_RELATED_OBJ_rec.PROGRAM_ID,
          p_PROGRAM_UPDATE_DATE  => p_RELATED_OBJ_rec.PROGRAM_UPDATE_DATE,
          p_QUOTE_OBJECT_TYPE_CODE  => p_RELATED_OBJ_rec.QUOTE_OBJECT_TYPE_CODE,
          p_QUOTE_OBJECT_ID  => p_RELATED_OBJ_rec.QUOTE_OBJECT_ID,
          p_OBJECT_TYPE_CODE  => p_RELATED_OBJ_rec.OBJECT_TYPE_CODE,
          p_OBJECT_ID  => p_RELATED_OBJ_rec.OBJECT_ID,
          p_RELATIONSHIP_TYPE_CODE  => p_RELATED_OBJ_rec.RELATIONSHIP_TYPE_CODE,
          p_RECIPROCAL_FLAG  => p_RELATED_OBJ_rec.RECIPROCAL_FLAG,
		p_OBJECT_VERSION_NUMBER => p_RELATED_OBJ_rec.OBJECT_VERSION_NUMBER);

	 IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
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

	EXCEPTION
	  WHEN FND_API.G_EXC_ERROR THEN
	      ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
		   P_API_NAME => L_API_NAME
		  ,P_PKG_NAME => G_PKG_NAME
		  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
		  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
		  ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
		  ,X_MSG_COUNT => X_MSG_COUNT
		  ,X_MSG_DATA => X_MSG_DATA
		  ,X_RETURN_STATUS => X_RETURN_STATUS);

	  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	      ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
		   P_API_NAME => L_API_NAME
		  ,P_PKG_NAME => G_PKG_NAME
		  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
		  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
		  ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
		  ,X_MSG_COUNT => X_MSG_COUNT
		  ,X_MSG_DATA => X_MSG_DATA
		  ,X_RETURN_STATUS => X_RETURN_STATUS);

	  WHEN OTHERS THEN
	      ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
		   P_API_NAME => L_API_NAME
		  ,P_PKG_NAME => G_PKG_NAME
		  ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
		  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
		  ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
		  ,X_MSG_COUNT => X_MSG_COUNT
		  ,X_MSG_DATA => X_MSG_DATA
		  ,X_RETURN_STATUS => X_RETURN_STATUS);


End Update_related_obj;



PROCEDURE Delete_related_obj(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_RELATED_OBJ_Rec     IN ASO_QUOTE_PUB.RELATED_OBJ_Rec_Type,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Delete_related_obj';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_x_status                         VARCHAR2(1);

l_quote_object_type_code           varchar2(30);
l_quote_object_id                  number;

cursor quote_object is
select quote_object_type_code, quote_object_id
from aso_quote_related_objects
where related_object_id = p_related_obj_rec.related_object_id;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_RELATED_OBJ_PVT;

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

      open quote_object;
      fetch quote_object into l_quote_object_type_code, l_quote_object_id;
      close quote_object;

      IF l_quote_object_type_code = 'HEADER' and
         l_quote_object_id is not null THEN

          aso_conc_req_int.lock_exists( p_quote_header_id  =>  l_quote_object_id,
                                        x_status           =>  l_x_status );

          IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('delete_related_obj: l_x_status: '|| l_x_status);
          END IF;

          if l_x_status = fnd_api.g_true then

              if fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) then
                  fnd_message.set_name('ASO', 'ASO_CONC_REQUEST_RUNNING');
                  fnd_msg_pub.add;
              end if;

              x_return_status := fnd_api.g_ret_sts_error;
              raise fnd_api.g_exc_error;

          end if;

     END IF;

      -- Invoke table handler(ASO_QUOTE_RELATED_OBJECTS_PKG.Delete_Row)
      ASO_QUOTE_RELATED_OBJECTS_PKG.Delete_Row(
          p_RELATED_OBJECT_ID  => p_RELATED_OBJ_rec.RELATED_OBJECT_ID);

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
         p_data           =>   x_msg_data);

  EXCEPTION
	  WHEN FND_API.G_EXC_ERROR THEN
	      ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
		   P_API_NAME => L_API_NAME
		  ,P_PKG_NAME => G_PKG_NAME
		  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
		  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
		  ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
		  ,X_MSG_COUNT => X_MSG_COUNT
		  ,X_MSG_DATA => X_MSG_DATA
		  ,X_RETURN_STATUS => X_RETURN_STATUS);

	  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	      ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
		   P_API_NAME => L_API_NAME
		  ,P_PKG_NAME => G_PKG_NAME
		  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
		  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
		  ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
		  ,X_MSG_COUNT => X_MSG_COUNT
		  ,X_MSG_DATA => X_MSG_DATA
		  ,X_RETURN_STATUS => X_RETURN_STATUS);

	  WHEN OTHERS THEN
	      ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
		   P_API_NAME => L_API_NAME
		  ,P_PKG_NAME => G_PKG_NAME
		  ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
		  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
		  ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
		  ,X_MSG_COUNT => X_MSG_COUNT
		  ,X_MSG_DATA => X_MSG_DATA
		  ,X_RETURN_STATUS => X_RETURN_STATUS);

End Delete_related_obj;




-- Item-level validation procedures
PROCEDURE Validate_RELATED_OBJECT_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_RELATED_OBJECT_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY /* file.sql.39 change */     ASO_UTILITY_PVT.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */   VARCHAR2
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
      IF(p_RELATED_OBJECT_ID is NULL)
      THEN
          --ASO_UTILITY_PVT.Print('ERROR', 'Private related_obj API: -Violate NOT NULL constraint(RELATED_OBJECT_ID)');
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      IF(p_validation_mode = ASO_UTILITY_PVT.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_RELATED_OBJECT_ID is not NULL and p_RELATED_OBJECT_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = ASO_UTILITY_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_RELATED_OBJECT_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_RELATED_OBJECT_ID;


PROCEDURE Validate_REQUEST_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_REQUEST_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY /* file.sql.39 change */     ASO_UTILITY_PVT.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */   VARCHAR2
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

      IF(p_validation_mode = ASO_UTILITY_PVT.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_REQUEST_ID is not NULL and p_REQUEST_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = ASO_UTILITY_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_REQUEST_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_REQUEST_ID;


PROCEDURE Validate_PROGRAM_APPL_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PROGRAM_APPLICATION_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY /* file.sql.39 change */     ASO_UTILITY_PVT.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */   VARCHAR2
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

      IF(p_validation_mode = ASO_UTILITY_PVT.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_PROGRAM_APPLICATION_ID is not NULL and p_PROGRAM_APPLICATION_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = ASO_UTILITY_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_PROGRAM_APPLICATION_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PROGRAM_APPL_ID;


PROCEDURE Validate_PROGRAM_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PROGRAM_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY /* file.sql.39 change */     ASO_UTILITY_PVT.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */   VARCHAR2
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

      IF(p_validation_mode = ASO_UTILITY_PVT.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_PROGRAM_ID is not NULL and p_PROGRAM_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = ASO_UTILITY_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_PROGRAM_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PROGRAM_ID;


PROCEDURE Validate_PROGRAM_UPDATE_DATE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PROGRAM_UPDATE_DATE                IN   DATE,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY /* file.sql.39 change */     ASO_UTILITY_PVT.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */   VARCHAR2
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

      IF(p_validation_mode = ASO_UTILITY_PVT.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_PROGRAM_UPDATE_DATE is not NULL and p_PROGRAM_UPDATE_DATE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = ASO_UTILITY_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_PROGRAM_UPDATE_DATE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PROGRAM_UPDATE_DATE;


PROCEDURE Validate_QTE_OBJ_TYPE_CODE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_QUOTE_OBJECT_TYPE_CODE                IN   VARCHAR2,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY /* file.sql.39 change */     ASO_UTILITY_PVT.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    )
IS
l_count NUMBER;
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = ASO_UTILITY_PVT.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_QUOTE_OBJECT_TYPE_CODE is not NULL and p_QUOTE_OBJECT_TYPE_CODE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;

           select count(*) into l_count
           from aso_lookups
           where lookup_type = 'ASO_QUOTE_OBJECT_TYPE'
           and lookup_code = p_QUOTE_OBJECT_TYPE_CODE;

           IF l_count < 1 THEN
             x_return_status := FND_API.G_RET_STS_ERROR;
           END IF;

      ELSIF(p_validation_mode = ASO_UTILITY_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_QUOTE_OBJECT_TYPE_CODE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;

         IF p_QUOTE_OBJECT_TYPE_CODE <> FND_API.G_MISS_CHAR THEN
          select count(*) into l_count
           from aso_lookups
           where lookup_type = 'ASO_QUOTE_OBJECT_TYPE'
           and lookup_code =  p_QUOTE_OBJECT_TYPE_CODE;

           IF l_count < 1 THEN
             x_return_status := FND_API.G_RET_STS_ERROR;
           END IF;
         END IF;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_QTE_OBJ_TYPE_CODE;


PROCEDURE Validate_QUOTE_OBJECT_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_QUOTE_OBJECT_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY /* file.sql.39 change */     ASO_UTILITY_PVT.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */   VARCHAR2
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
      IF(p_QUOTE_OBJECT_ID is NULL)
      THEN
          --ASO_UTILITY_PVT.Print('ERROR', 'Private related_obj API: -Violate NOT NULL constraint(QUOTE_OBJECT_ID)');
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
/*
      IF(p_validation_mode = ASO_UTILITY_PVT.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_QUOTE_OBJECT_ID is not NULL and p_QUOTE_OBJECT_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;


      ELSIF(p_validation_mode = ASO_UTILITY_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_QUOTE_OBJECT_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;
*/



      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_QUOTE_OBJECT_ID;


PROCEDURE Validate_OBJECT_TYPE_CODE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_OBJECT_TYPE_CODE                IN   VARCHAR2,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY /* file.sql.39 change */     ASO_UTILITY_PVT.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    )
IS
l_count NUMBER;
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- validate NOT NULL column
      IF(p_OBJECT_TYPE_CODE is NULL)
      THEN
          --ASO_UTILITY_PVT.Print('ERROR', 'Private related_obj API: -Violate NOT NULL constraint(OBJECT_TYPE_CODE)');
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      IF(p_validation_mode = ASO_UTILITY_PVT.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_OBJECT_TYPE_CODE is not NULL and p_OBJECT_TYPE_CODE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;

          select count(*) into l_count
          from aso_lookups
          where lookup_type = 'ASO_RELATED_OBJECT_TYPE'
          and lookup_code = p_OBJECT_TYPE_CODE;

          IF l_count < 1 THEN
           x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;

      ELSIF(p_validation_mode = ASO_UTILITY_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_OBJECT_TYPE_CODE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;

           IF p_OBJECT_TYPE_CODE <> FND_API.G_MISS_CHAR THEN
             select count(*) into l_count
             from aso_lookups
             where lookup_type = 'ASO_RELATED_OBJECT_TYPE'
             and lookup_code = p_OBJECT_TYPE_CODE;

             IF l_count < 1 THEN
               x_return_status := FND_API.G_RET_STS_ERROR;
             END IF;
           END IF;
    END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_OBJECT_TYPE_CODE;


PROCEDURE Validate_OBJECT_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_OBJECT_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY /* file.sql.39 change */     ASO_UTILITY_PVT.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */   VARCHAR2
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

      IF(p_validation_mode = ASO_UTILITY_PVT.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_OBJECT_ID is not NULL and p_OBJECT_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = ASO_UTILITY_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_OBJECT_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_OBJECT_ID;


PROCEDURE Validate_RLTSHIP_TYPE_CODE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_RELATIONSHIP_TYPE_CODE                IN   VARCHAR2,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY /* file.sql.39 change */     ASO_UTILITY_PVT.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    )
IS
l_count NUMBER;
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- validate NOT NULL column
      IF(p_RELATIONSHIP_TYPE_CODE is NULL)
      THEN
          --ASO_UTILITY_PVT.Print('ERROR', 'Private related_obj API: -Violate NOT NULL constraint(RELATIONSHIP_TYPE_CODE)');
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      IF(p_validation_mode = ASO_UTILITY_PVT.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_RELATIONSHIP_TYPE_CODE is not NULL and p_RELATIONSHIP_TYPE_CODE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;

          SELECT count(*) into l_count
          from aso_lookups
          where lookup_type = 'ASO_OBJECT_RELATIONSHIP_TYPE'
          and lookup_code = p_RELATIONSHIP_TYPE_CODE;

          IF l_count < 1 THEN
           x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;

      ELSIF(p_validation_mode = ASO_UTILITY_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_RELATIONSHIP_TYPE_CODE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;

           IF p_RELATIONSHIP_TYPE_CODE <> FND_API.G_MISS_CHAR THEN
               SELECT count(*) into l_count
          	from aso_lookups
          	where lookup_type = 'ASO_OBJECT_RELATIONSHIP_TYPE'
          	and lookup_code = p_RELATIONSHIP_TYPE_CODE;

          	IF l_count < 1 THEN
           	x_return_status := FND_API.G_RET_STS_ERROR;
          	END IF;
           END IF;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_RLTSHIP_TYPE_CODE;


PROCEDURE Validate_RECIPROCAL_FLAG (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_RECIPROCAL_FLAG                IN   VARCHAR2,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY /* file.sql.39 change */     ASO_UTILITY_PVT.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */   VARCHAR2
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

      IF(p_validation_mode = ASO_UTILITY_PVT.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_RECIPROCAL_FLAG is not NULL and p_RECIPROCAL_FLAG <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
            IF (p_RECIPROCAL_FLAG <> FND_API.G_TRUE or p_RECIPROCAL_FLAG <> FND_API.G_FALSE) THEN
              x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

      ELSIF(p_validation_mode = ASO_UTILITY_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_RECIPROCAL_FLAG <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
          IF p_RECIPROCAL_FLAG <> FND_API.G_MISS_CHAR THEN
          IF (p_RECIPROCAL_FLAG <> FND_API.G_TRUE or p_RECIPROCAL_FLAG <> FND_API.G_FALSE) THEN
              x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
          END IF;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_RECIPROCAL_FLAG;


PROCEDURE Validate_QUOTE_OBJECT_CODE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_QUOTE_OBJECT_CODE                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY /* file.sql.39 change */     ASO_UTILITY_PVT.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */   VARCHAR2
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
      IF(p_QUOTE_OBJECT_CODE is NULL)
      THEN
          --ASO_UTILITY_PVT.Print('ERROR', 'Private related_obj API: -Violate NOT NULL constraint(QUOTE_OBJECT_CODE)');
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      IF(p_validation_mode = ASO_UTILITY_PVT.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_QUOTE_OBJECT_CODE is not NULL and p_QUOTE_OBJECT_CODE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = ASO_UTILITY_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_QUOTE_OBJECT_CODE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_QUOTE_OBJECT_CODE;


-- Hint: inter-field level validation can be added here.
-- Hint: If p_validation_mode = ASO_UTILITY_PVT.G_VALIDATE_UPDATE, we should use cursor
--       to get old values for all fields used in inter-field validation and set all G_MISS_XXX fields to original value
--       stored in database table.
PROCEDURE Validate_RELATED_OBJ_rec(
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_RELATED_OBJ_Rec     IN    ASO_QUOTE_PUB.RELATED_OBJ_Rec_Type,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    )
IS
l_count NUMBER;
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

         IF  P_RELATED_OBJ_Rec.quote_object_type_code = 'MODEL' then
           select count(*) into l_count
           from aso_quote_headers_all
           where quote_header_id = P_RELATED_OBJ_Rec.quote_object_id;

           IF l_count < 1 THEN
             x_return_status := FND_API.G_RET_STS_ERROR;
           END IF;

         ELSIF P_RELATED_OBJ_Rec.quote_object_type_code = 'LINE' THEN
            select count(*) into l_count
           from aso_quote_lines_all
           where quote_line_id = P_RELATED_OBJ_Rec.quote_object_id;

           IF l_count < 1 THEN
             x_return_status := FND_API.G_RET_STS_ERROR;
           END IF;

         ELSIF P_RELATED_OBJ_Rec.quote_object_type_code = 'SHIPMENT' THEN
           select count(*) into l_count
           from aso_shipments
           where shipment_id = P_RELATED_OBJ_Rec.quote_object_id;

           IF l_count < 1 THEN
             x_return_status := FND_API.G_RET_STS_ERROR;
           END IF;
         END IF;

      -- Debug Message
      --ASO_UTILITY_PVT.Print(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'API_INVALID_RECORD');

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_RELATED_OBJ_Rec;

PROCEDURE Validate_related_obj(
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    P_Validation_mode            IN   VARCHAR2,
    P_RELATED_OBJ_Rec     IN     ASO_QUOTE_PUB.RELATED_OBJ_Rec_Type,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    )
IS
l_api_name   CONSTANT VARCHAR2(30) := 'Validate_related_obj';
 BEGIN

      -- Debug Message
      --ASO_UTILITY_PVT.Print(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_validation_level >= ASO_UTILITY_PVT.G_VALID_LEVEL_ITEM) THEN
          -- Hint: We provide validation procedure for every column. Developer should delete
          --       unnecessary validation procedures.
          Validate_RELATED_OBJECT_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_RELATED_OBJECT_ID   => P_RELATED_OBJ_Rec.RELATED_OBJECT_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT NOCOPY /* file.sql.39 change */ parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_REQUEST_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_REQUEST_ID   => P_RELATED_OBJ_Rec.REQUEST_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT NOCOPY /* file.sql.39 change */ parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_PROGRAM_APPL_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_PROGRAM_APPLICATION_ID   => P_RELATED_OBJ_Rec.PROGRAM_APPLICATION_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT NOCOPY /* file.sql.39 change */ parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_PROGRAM_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_PROGRAM_ID   => P_RELATED_OBJ_Rec.PROGRAM_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT NOCOPY /* file.sql.39 change */ parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_PROGRAM_UPDATE_DATE(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_PROGRAM_UPDATE_DATE   => P_RELATED_OBJ_Rec.PROGRAM_UPDATE_DATE,
              -- Hint: You may add x_item_property_rec as one of your OUT NOCOPY /* file.sql.39 change */ parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_QTE_OBJ_TYPE_CODE(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_QUOTE_OBJECT_TYPE_CODE   => P_RELATED_OBJ_Rec.QUOTE_OBJECT_TYPE_CODE,
              -- Hint: You may add x_item_property_rec as one of your OUT NOCOPY /* file.sql.39 change */ parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_QUOTE_OBJECT_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_QUOTE_OBJECT_ID   => P_RELATED_OBJ_Rec.QUOTE_OBJECT_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT NOCOPY /* file.sql.39 change */ parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_OBJECT_TYPE_CODE(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_OBJECT_TYPE_CODE   => P_RELATED_OBJ_Rec.OBJECT_TYPE_CODE,
              -- Hint: You may add x_item_property_rec as one of your OUT NOCOPY /* file.sql.39 change */ parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_OBJECT_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_OBJECT_ID   => P_RELATED_OBJ_Rec.OBJECT_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT NOCOPY /* file.sql.39 change */ parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_RLTSHIP_TYPE_CODE(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_RELATIONSHIP_TYPE_CODE   => P_RELATED_OBJ_Rec.RELATIONSHIP_TYPE_CODE,
              -- Hint: You may add x_item_property_rec as one of your OUT NOCOPY /* file.sql.39 change */ parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_RECIPROCAL_FLAG(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_RECIPROCAL_FLAG   => P_RELATED_OBJ_Rec.RECIPROCAL_FLAG,
              -- Hint: You may add x_item_property_rec as one of your OUT NOCOPY /* file.sql.39 change */ parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_QUOTE_OBJECT_CODE(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_QUOTE_OBJECT_CODE   => P_RELATED_OBJ_Rec.QUOTE_OBJECT_CODE,
              -- Hint: You may add x_item_property_rec as one of your OUT NOCOPY /* file.sql.39 change */ parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

      END IF;

      IF (p_validation_level >= ASO_UTILITY_PVT.G_VALID_LEVEL_RECORD) THEN
          -- Hint: Inter-field level validation can be added here
          -- invoke record level validation procedures
          Validate_RELATED_OBJ_Rec(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
          P_RELATED_OBJ_Rec     =>    P_RELATED_OBJ_Rec,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;
      END IF;

      IF (p_validation_level >= ASO_UTILITY_PVT.G_VALID_LEVEL_INTER_RECORD) THEN
          -- invoke inter-record level validation procedures
          NULL;
      END IF;

      IF (p_validation_level >= ASO_UTILITY_PVT.G_VALID_LEVEL_INTER_ENTITY) THEN
          -- invoke inter-entity level validation procedures
          NULL;
      END IF;


      -- Debug Message
      --ASO_UTILITY_PVT.Print(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'end');

END Validate_related_obj;

End aso_RELATED_OBJ_PVT;

/
