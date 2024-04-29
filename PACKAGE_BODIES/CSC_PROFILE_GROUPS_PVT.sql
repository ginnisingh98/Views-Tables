--------------------------------------------------------
--  DDL for Package Body CSC_PROFILE_GROUPS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSC_PROFILE_GROUPS_PVT" as
/* $Header: cscvpgrb.pls 115.13 2002/12/03 18:30:11 jamose ship $ */
-- Start of Comments
-- Package name     : CSC_PROFILE_GROUPS_PVT
-- Purpose          :
-- History          :
-- 29 Nov 02   jamose made changes for the NOCOPY and FND_API.G_MISS*
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSC_PROFILE_GROUPS_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'cscvpgrb.pls';

PROCEDURE Convert_Columns_to_Rec(
    P_GROUP_ID                   IN   NUMBER ,
    P_CREATED_BY                 IN   NUMBER ,
    P_CREATION_DATE              IN   DATE 	,
    P_LAST_UPDATED_BY            IN   NUMBER ,
    P_LAST_UPDATE_DATE           IN   DATE 	,
    P_LAST_UPDATE_LOGIN          IN   NUMBER ,
    P_GROUP_NAME                 IN   VARCHAR2,
    P_GROUP_NAME_CODE            IN   VARCHAR2,
    P_DESCRIPTION                IN   VARCHAR2,
    P_PARTY_TYPE		            IN   VARCHAR2 ,
    P_START_DATE_ACTIVE          IN   DATE,
    P_END_DATE_ACTIVE            IN   DATE,
    P_USE_IN_CUSTOMER_DASHBOARD  IN   VARCHAR2,
    P_SEEDED_FLAG                IN   VARCHAR2,
    P_OBJECT_VERSION_NUMBER 	   IN   NUMBER DEFAULT NULL,
    P_APPLICATION_ID             IN   NUMBER,
    X_PROF_GROUP_Rec             OUT  NOCOPY  PROF_GROUP_Rec_Type
    )
   IS
 BEGIN

    X_Prof_group_rec.GROUP_ID := P_GROUP_ID;
    X_Prof_group_rec.CREATED_BY := P_CREATED_BY;
    X_Prof_group_rec.CREATION_DATE :=  P_CREATION_DATE;
    X_Prof_group_rec.LAST_UPDATED_BY := P_LAST_UPDATED_BY;
    X_Prof_group_rec.LAST_UPDATE_DATE := P_LAST_UPDATE_DATE;
    X_Prof_group_rec.LAST_UPDATE_LOGIN := P_LAST_UPDATE_LOGIN;
    X_Prof_group_rec.GROUP_NAME    := P_GROUP_NAME;
    X_Prof_group_rec.GROUP_NAME_CODE  := P_GROUP_NAME_CODE;
    X_Prof_group_rec.DESCRIPTION   := P_DESCRIPTION;
    X_Prof_group_rec.PARTY_TYPE := P_PARTY_TYPE;
    X_Prof_group_rec.START_DATE_ACTIVE := P_START_DATE_ACTIVE;
    X_Prof_group_rec.END_DATE_ACTIVE   := P_END_DATE_ACTIVE;
    X_Prof_group_rec.USE_IN_CUSTOMER_DASHBOARD := P_USE_IN_CUSTOMER_DASHBOARD;
    X_Prof_group_rec.SEEDED_FLAG := P_SEEDED_FLAG;
    X_Prof_group_rec.OBJECT_VERSION_NUMBER := P_OBJECT_VERSION_NUMBER;
    X_Prof_group_rec.APPLICATION_ID := P_APPLICATION_ID;


 END;


PROCEDURE Create_profile_groups(
    PX_Group_Id			   IN OUT NOCOPY NUMBER,
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit                     IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level           IN   NUMBER       := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    P_GROUP_ID                   IN   NUMBER DEFAULT NULL,
    P_CREATED_BY                 IN   NUMBER,
    P_CREATION_DATE              IN   DATE,
    P_LAST_UPDATED_BY            IN   NUMBER,
    P_LAST_UPDATE_DATE           IN   DATE,
    P_LAST_UPDATE_LOGIN          IN   NUMBER,
    P_GROUP_NAME                 IN   VARCHAR2,
    P_GROUP_NAME_CODE            IN   VARCHAR2,
    P_DESCRIPTION                IN   VARCHAR2,
    P_PARTY_TYPE		            IN   VARCHAR2,
    P_START_DATE_ACTIVE          IN   DATE,
    P_END_DATE_ACTIVE            IN   DATE,
    P_USE_IN_CUSTOMER_DASHBOARD  IN   VARCHAR2,
    P_SEEDED_FLAG                IN   VARCHAR2,
    X_Object_Version_Number      OUT NOCOPY NUMBER,
    P_APPLICATION_ID             IN   NUMBER,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    )
IS
l_prof_group_rec PROF_GROUP_REC_TYPE := G_MISS_PROF_GROUP_REC;
BEGIN

      Convert_Columns_to_Rec(
      P_GROUP_ID  	=>   P_GROUP_ID,
      P_CREATED_BY   	=>   P_CREATED_BY,
      P_CREATION_DATE  	=>   P_CREATION_DATE,
      P_LAST_UPDATED_BY 	=>    P_LAST_UPDATED_BY,
      P_LAST_UPDATE_DATE 	=>    P_LAST_UPDATE_DATE,
      P_LAST_UPDATE_LOGIN 	=>    P_LAST_UPDATE_LOGIN,
      P_GROUP_NAME       	=>    P_GROUP_NAME,
      P_GROUP_NAME_CODE   	=>    P_GROUP_NAME_CODE,
      P_DESCRIPTION    	        =>    P_DESCRIPTION,
      P_PARTY_TYPE 	        =>    P_PARTY_TYPE,
      P_START_DATE_ACTIVE 	=>    P_START_DATE_ACTIVE,
      P_END_DATE_ACTIVE 	=>    P_END_DATE_ACTIVE,
      P_USE_IN_CUSTOMER_DASHBOARD 	=>  P_USE_IN_CUSTOMER_DASHBOARD,
      P_SEEDED_FLAG 	        =>    P_SEEDED_FLAG,
      P_APPLICATION_ID          =>    P_APPLICATION_ID,
      X_PROF_GROUP_Rec     => l_prof_group_rec
	);
      Create_profile_groups(
	 PX_Group_ID			=> PX_Group_Id,
      P_Api_Version_Number         => 1.0,
      P_Init_Msg_List              => CSC_CORE_UTILS_PVT.G_FALSE,
      P_Commit                     => CSC_CORE_UTILS_PVT.G_FALSE,
      P_Validation_Level           => CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
      P_PROF_GROUP_Rec  	      =>  l_prof_group_rec,
	 X_Object_Version_Number  => x_Object_Version_Number,
      X_Return_Status              => x_return_status,
      X_Msg_Count                  => x_msg_count,
      X_Msg_Data                   => x_msg_data);


END;


PROCEDURE Create_profile_groups(
    PX_Group_Id			   IN OUT NOCOPY NUMBER,
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit                     IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level           IN   NUMBER       := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    P_PROF_GROUP_Rec         IN    PROF_GROUP_Rec_Type  := G_MISS_PROF_GROUP_REC,
    X_Object_Version_Number  OUT NOCOPY NUMBER,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Create_profile_groups';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_return_status_full        VARCHAR2(1);
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_PROFILE_GROUPS_PVT;

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

      IF ( P_validation_level >= CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL)
      THEN

          -- Invoke validation procedures
          Validate_profile_groups(
              p_init_msg_list    => CSC_CORE_UTILS_PVT.G_FALSE,
              p_validation_level => p_validation_level,
              p_validation_mode  => CSC_CORE_UTILS_PVT.G_CREATE,
              P_PROF_GROUP_Rec  =>  P_PROF_GROUP_Rec,
              x_return_status    => x_return_status,
              x_msg_count        => x_msg_count,
              x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Invoke table handler(CSC_PROF_GROUPS_PKG.Insert_Row)
      CSC_PROF_GROUPS_PKG.Insert_Row(
          px_GROUP_ID  => px_GROUP_ID,
          p_CREATED_BY  => FND_GLOBAL.USER_ID,
          p_CREATION_DATE  => SYSDATE,
          p_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID,
          p_LAST_UPDATE_DATE  => SYSDATE,
          p_LAST_UPDATE_LOGIN  => FND_GLOBAL.CONC_LOGIN_ID,
          p_GROUP_NAME  => p_PROF_GROUP_rec.GROUP_NAME,
          p_GROUP_NAME_CODE  => p_PROF_GROUP_rec.GROUP_NAME_CODE,
          p_DESCRIPTION  => p_PROF_GROUP_rec.DESCRIPTION,
          p_START_DATE_ACTIVE  => p_PROF_GROUP_rec.START_DATE_ACTIVE,
          p_END_DATE_ACTIVE  => p_PROF_GROUP_rec.END_DATE_ACTIVE,
          p_USE_IN_CUSTOMER_DASHBOARD  => p_PROF_GROUP_rec.USE_IN_CUSTOMER_DASHBOARD,
          p_PARTY_TYPE  => p_PROF_GROUP_rec.PARTY_TYPE,
          p_SEEDED_FLAG  => p_PROF_GROUP_rec.SEEDED_FLAG,
	     x_OBJECT_VERSION_NUMBER => X_OBJECT_VERSION_NUMBER,
          p_APPLICATION_ID    => p_PROF_GROUP_rec.APPLICATION_ID );


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
    		 ROLLBACK TO Create_profile_groups_PVT;
    		 x_return_status := FND_API.G_RET_STS_ERROR;
    		 FND_MSG_PUB.Count_And_Get
      			( p_count => x_msg_count,
        		  	  p_data  => x_msg_data
      			);
             APP_EXCEPTION.RAISE_EXCEPTION;
  	    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    		 ROLLBACK TO Create_profile_groups_PVT;
    		 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    		 FND_MSG_PUB.Count_And_Get
      			( p_count => x_msg_count,
        		  	  p_data  => x_msg_data
      			);
             APP_EXCEPTION.RAISE_EXCEPTION;
  	    WHEN OTHERS THEN
    		 ROLLBACK TO Create_profile_groups_PVT;
    		 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      	 FND_MSG_PUB.Build_Exc_Msg(G_PKG_NAME, l_api_name);
    		 FND_MSG_PUB.Count_And_Get
      			( p_count => x_msg_count,
        		  	  p_data  => x_msg_data
      			);
             APP_EXCEPTION.RAISE_EXCEPTION;
End Create_profile_groups;

PROCEDURE Update_profile_groups(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit                     IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level           IN   NUMBER       := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    P_GROUP_ID                   IN   NUMBER,
    P_CREATED_BY                 IN   NUMBER,
    P_CREATION_DATE              IN   DATE ,
    P_LAST_UPDATED_BY            IN   NUMBER,
    P_LAST_UPDATE_DATE           IN   DATE ,
    P_LAST_UPDATE_LOGIN          IN   NUMBER,
    P_GROUP_NAME                 IN   VARCHAR2,
    P_GROUP_NAME_CODE            IN   VARCHAR2,
    P_DESCRIPTION                IN   VARCHAR2,
    P_PARTY_TYPE		         IN   VARCHAR2,
    P_START_DATE_ACTIVE          IN   DATE ,
    P_END_DATE_ACTIVE            IN   DATE ,
    P_USE_IN_CUSTOMER_DASHBOARD  IN   VARCHAR2,
    P_SEEDED_FLAG         IN   VARCHAR2,
    PX_OBJECT_VERSION_NUMBER 	   IN OUT NOCOPY  NUMBER,
    P_APPLICATION_ID             IN   NUMBER,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    )
   IS
l_prof_group_Rec  PROF_GROUP_REC_TYPE;
BEGIN
      Convert_Columns_to_Rec(
      P_GROUP_ID  	=>   P_GROUP_ID,
      P_CREATED_BY   	=>   P_CREATED_BY,
      P_CREATION_DATE  	=>   P_CREATION_DATE,
      P_LAST_UPDATED_BY 	=>    P_LAST_UPDATED_BY,
      P_LAST_UPDATE_DATE 	=>    P_LAST_UPDATE_DATE,
      P_LAST_UPDATE_LOGIN 	=>    P_LAST_UPDATE_LOGIN,
      P_GROUP_NAME       	=>    P_GROUP_NAME,
      P_GROUP_NAME_CODE   	=>    P_GROUP_NAME_CODE,
      P_DESCRIPTION    	=>          P_DESCRIPTION,
      P_PARTY_TYPE 	=>		P_PARTY_TYPE,
      P_START_DATE_ACTIVE 	=>    P_START_DATE_ACTIVE,
      P_END_DATE_ACTIVE 	=>    P_END_DATE_ACTIVE,
      P_USE_IN_CUSTOMER_DASHBOARD 	=>  P_USE_IN_CUSTOMER_DASHBOARD,
      P_SEEDED_FLAG 	=>        P_SEEDED_FLAG,
      P_OBJECT_VERSION_NUMBER 	=> PX_OBJECT_VERSION_NUMBER,
      P_APPLICATION_ID         => P_APPLICATION_ID,
      X_PROF_GROUP_Rec     => l_prof_group_rec
	);

      Update_profile_groups(
      P_Api_Version_Number         => P_Api_Version_Number,
      P_Init_Msg_List              => P_Init_Msg_List,
      P_Commit                     => P_Commit,
      P_Validation_Level           => P_Validation_Level,
      P_PROF_GROUP_Rec  	=>  l_prof_group_rec,
	 PX_Object_Version_Number => px_Object_Version_Number,
      X_Return_Status              => x_return_status,
      X_Msg_Count                  => x_msg_count,
      X_Msg_Data                   => x_msg_data);
END;

PROCEDURE Update_profile_groups(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit                     IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level           IN  NUMBER       := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    P_PROF_GROUP_Rec     IN    PROF_GROUP_Rec_Type,
    PX_Object_Version_Number  IN OUT NOCOPY NUMBER,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    )

 IS

Cursor C_Get_profile_groups(c_GROUP_ID Number) IS
    Select GROUP_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           GROUP_NAME,
           GROUP_NAME_CODE,
           DESCRIPTION,
           START_DATE_ACTIVE,
           END_DATE_ACTIVE,
           USE_IN_CUSTOMER_DASHBOARD,
           SEEDED_FLAG,
	   OBJECT_VERSION_NUMBER

    From  CSC_PROF_GROUPS_VL
    Where group_id = c_Group_id
    And object_version_number = px_Object_Version_Number
    For Update NOWAIT;

l_api_name                CONSTANT VARCHAR2(30) := 'Update_profile_groups';
l_api_version_number      CONSTANT NUMBER   := 1.0;
-- Local Variables

l_old_PROF_GROUP_rec  PROF_GROUP_Rec_Type;
l_rowid  ROWID;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_PROFILE_GROUPS_PVT;

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
      Open C_Get_profile_groups( p_PROF_GROUP_rec.GROUP_ID);

      Fetch C_Get_profile_groups into
               l_old_PROF_GROUP_rec.GROUP_ID,
               l_old_PROF_GROUP_rec.CREATED_BY,
               l_old_PROF_GROUP_rec.CREATION_DATE,
               l_old_PROF_GROUP_rec.LAST_UPDATED_BY,
               l_old_PROF_GROUP_rec.LAST_UPDATE_DATE,
               l_old_PROF_GROUP_rec.LAST_UPDATE_LOGIN,
               l_old_PROF_GROUP_rec.GROUP_NAME,
               l_old_PROF_GROUP_rec.GROUP_NAME_CODE,
               l_old_PROF_GROUP_rec.DESCRIPTION,
               l_old_PROF_GROUP_rec.START_DATE_ACTIVE,
               l_old_PROF_GROUP_rec.END_DATE_ACTIVE,
               l_old_PROF_GROUP_rec.USE_IN_CUSTOMER_DASHBOARD,
               l_old_PROF_GROUP_rec.SEEDED_FLAG,
	       l_old_prof_GROUP_rec.OBJECT_VERSION_NUMBER;


       If ( C_Get_profile_groups%NOTFOUND) Then
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
	       CLOSE C_Get_profile_Groups;
               CSC_CORE_UTILS_PVT.RECORD_IS_LOCKED_MSG(p_Api_Name=>l_api_name);
               --FND_MESSAGE.Set_Name('CSC', 'API_MISSING_UPDATE_TARGET');
               --FND_MESSAGE.Set_Token ('INFO', 'CSC_PROF_GROUPS', FALSE);
               --FND_MSG_PUB.Add;
           END IF;
           raise FND_API.G_EXC_ERROR;
       END IF;
	  IF C_Get_Profile_Groups%ISOPEN THEN
          Close C_Get_profile_groups;
       END IF;


      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN

          -- Invoke validation procedures
          Validate_profile_groups(
              p_init_msg_list    => CSC_CORE_UTILS_PVT.G_FALSE,
              p_validation_level => p_validation_level,
              p_validation_mode  => CSC_CORE_UTILS_PVT.G_UPDATE,
              P_PROF_GROUP_Rec  =>  P_PROF_GROUP_Rec,
              x_return_status    => x_return_status,
              x_msg_count        => x_msg_count,
              x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Invoke table handler(CSC_PROF_GROUPS_PKG.Update_Row)
      CSC_PROF_GROUPS_PKG.Update_Row(
          p_GROUP_ID  => csc_core_utils_pvt.Get_G_Miss_num(p_PROF_GROUP_rec.GROUP_ID,l_old_PROF_GROUP_rec.GROUP_ID),
          p_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID,
          p_LAST_UPDATE_DATE  => SYSDATE,
          p_LAST_UPDATE_LOGIN  => FND_GLOBAL.CONC_LOGIN_ID,
          p_GROUP_NAME  =>csc_core_utils_pvt.Get_G_Miss_char(p_PROF_GROUP_rec.GROUP_NAME,l_old_PROF_GROUP_rec.GROUP_NAME),
          p_GROUP_NAME_CODE  =>csc_core_utils_pvt.Get_G_Miss_char( p_PROF_GROUP_rec.GROUP_NAME_CODE,l_old_PROF_GROUP_rec.GROUP_NAME_CODE),
          p_DESCRIPTION  =>csc_core_utils_pvt.Get_G_Miss_char( p_PROF_GROUP_rec.DESCRIPTION,l_old_PROF_GROUP_rec.DESCRIPTION),
          p_START_DATE_ACTIVE  => csc_core_utils_pvt.Get_G_Miss_Date(p_PROF_GROUP_rec.START_DATE_ACTIVE,l_old_PROF_GROUP_rec.START_DATE_ACTIVE),
          p_END_DATE_ACTIVE  => csc_core_utils_pvt.Get_G_Miss_Date(p_PROF_GROUP_rec.END_DATE_ACTIVE,l_old_PROF_GROUP_rec.END_DATE_ACTIVE),
          p_USE_IN_CUSTOMER_DASHBOARD  => csc_core_utils_pvt.Get_G_Miss_char(p_PROF_GROUP_rec.USE_IN_CUSTOMER_DASHBOARD,l_old_PROF_GROUP_rec.USE_IN_CUSTOMER_DASHBOARD),
          p_PARTY_TYPE  => csc_core_utils_pvt.Get_G_Miss_char(p_PROF_GROUP_rec.PARTY_TYPE,l_old_PROF_GROUP_rec.PARTY_TYPE),
          p_SEEDED_FLAG  => csc_core_utils_pvt.Get_G_Miss_char(p_PROF_GROUP_rec.SEEDED_FLAG,l_old_PROF_GROUP_rec.SEEDED_FLAG),
	       PX_OBJECT_VERSION_NUMBER => px_OBJECT_VERSION_NUMBER,
          p_APPLICATION_ID  => csc_core_utils_pvt.Get_G_Miss_num(p_PROF_GROUP_rec.APPLICATION_ID,l_old_PROF_GROUP_rec.APPLICATION_ID) );
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
    		 ROLLBACK TO Update_profile_groups_PVT;
    		 x_return_status := FND_API.G_RET_STS_ERROR;
    		 FND_MSG_PUB.Count_And_Get
      			( p_count => x_msg_count,
        		  	  p_data  => x_msg_data
      			);
           APP_EXCEPTION.RAISE_EXCEPTION;
  	    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    		 ROLLBACK TO Update_profile_groups_PVT;
    		 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    		 FND_MSG_PUB.Count_And_Get
      			( p_count => x_msg_count,
        		  	  p_data  => x_msg_data
      			);
           APP_EXCEPTION.RAISE_EXCEPTION;
  	    WHEN OTHERS THEN
    		 ROLLBACK TO Update_profile_groups_PVT;
    		 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      	 FND_MSG_PUB.Build_Exc_Msg(G_PKG_NAME, l_api_name);
           APP_EXCEPTION.RAISE_EXCEPTION;
End Update_profile_groups;


PROCEDURE Delete_profile_groups(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit                     IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level           IN   NUMBER       := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    P_Group_ID                   IN   NUMBER,
    P_Object_Version_Number      IN   NUMBER,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Delete_profile_groups';
l_api_version_number      CONSTANT NUMBER   := 1.0;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_PROFILE_GROUPS_PVT;

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

      -- Invoke table handler(CSC_PROF_GROUPS_PKG.Delete_Row)
      CSC_PROF_GROUPS_PKG.Delete_Row(
          p_GROUP_ID  => p_GROUP_ID,
		p_OBJECT_VERSION_NUMBER => p_OBJECT_VERSION_NUMBER);
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
    		 ROLLBACK TO Delete_profile_groups_PVT;
    		 x_return_status := FND_API.G_RET_STS_ERROR;
    		 FND_MSG_PUB.Count_And_Get
      			( p_count => x_msg_count,
        		  	  p_data  => x_msg_data
      			);
           APP_EXCEPTION.RAISE_EXCEPTION;
  	    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    		 ROLLBACK TO Delete_profile_groups_PVT;
    		 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    		 FND_MSG_PUB.Count_And_Get
      			( p_count => x_msg_count,
        		  	  p_data  => x_msg_data
      			);
           APP_EXCEPTION.RAISE_EXCEPTION;
  	    WHEN OTHERS THEN
    		 ROLLBACK TO Delete_profile_groups_PVT;
    		 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      	 FND_MSG_PUB.build_Exc_Msg(G_PKG_NAME, l_api_name);
    		 FND_MSG_PUB.Count_And_Get
      			( p_count => x_msg_count,
        		  	  p_data  => x_msg_data
      			);
           APP_EXCEPTION.RAISE_EXCEPTION;
End Delete_profile_groups;


PROCEDURE Validate_GROUP_NAME (
    P_Api_Name			 IN	VARCHAR2,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_GROUP_NAME                IN   VARCHAR2,
    P_GROUP_ID                IN   NUMBER,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    )
IS
 Cursor C1 is
  Select group_id
  From csc_prof_groups_vl
  Where group_name = p_GROUP_NAME;
l_dummy Number;
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- validate NOT NULL column
      IF(p_GROUP_NAME is NULL)
      THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
	    CSC_CORE_UTILS_PVT.mandatory_arg_error(
		  p_api_name => p_api_name,
		  p_argument => 'p_GROUP_NAME',
		  p_argument_value => p_GROUP_NAME);
      END IF;

      IF(p_validation_mode = CSC_CORE_UTILS_PVT.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_GROUP_NAME is not NULL and p_GROUP_NAME <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
	    IF p_GROUP_NAME is not NULL and p_GROUP_NAME <> CSC_CORE_UTILS_PVT.G_MISS_CHAR
	    THEN
		Open C1;
		Fetch C1 into l_dummy;
		IF C1%FOUND THEN
        		x_return_status := FND_API.G_RET_STS_ERROR;
		   	CSC_CORE_UTILS_PVT.Add_Duplicate_Value_Msg(
			      p_api_name	=> p_api_name,
		       	p_argument	=> 'p_GROUP_NAME' ,
  		       	p_argument_value => p_GROUP_NAME);
		END IF;
                close C1;
	    END IF;
          NULL;
      ELSIF(p_validation_mode = CSC_CORE_UTILS_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_GROUP_NAME <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
	    IF p_GROUP_NAME <> CSC_CORE_UTILS_PVT.G_MISS_CHAR
	    THEN
		FOR C1_REC IN C1 LOOP
		 IF c1_rec.group_id <> p_GROUP_ID THEN
        		x_return_status := FND_API.G_RET_STS_ERROR;
		   	CSC_CORE_UTILS_PVT.Add_Duplicate_Value_Msg(
			      p_api_name	=> p_api_name,
		       	p_argument	=> 'p_GROUP_NAME' ,
  		       	p_argument_value => p_GROUP_NAME);
		 END IF;
		END LOOP;
	    END IF;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_GROUP_NAME;


PROCEDURE Validate_GROUP_NAME_CODE (
    P_Api_Name			 IN	VARCHAR2,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_GROUP_NAME_CODE                IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    )
IS
 Cursor C1 is
  Select group_id
  From csc_prof_groups_b
  Where group_name_code = p_GROUP_NAME_CODE;
l_dummy Number;
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = CSC_CORE_UTILS_PVT.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_GROUP_NAME_CODE is not NULL and p_GROUP_NAME_CODE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
	    IF p_GROUP_NAME_CODE is not NULL and p_GROUP_NAME_CODE <> CSC_CORE_UTILS_PVT.G_MISS_CHAR
	    THEN
		Open C1;
		Fetch C1 into l_dummy;
		IF C1%FOUND THEN
        	  x_return_status := FND_API.G_RET_STS_ERROR;
		  CSC_CORE_UTILS_PVT.Add_Duplicate_Value_Msg(
			    p_api_name	=> p_api_name,
		          p_argument	=> 'p_GROUP_NAME_CODE' ,
  		          p_argument_value => p_GROUP_NAME_CODE);
		END IF;
                Close C1;
	    END IF;
          NULL;
      ELSIF(p_validation_mode = CSC_CORE_UTILS_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_GROUP_NAME_CODE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
	--no validate of group name code
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_GROUP_NAME_CODE;



PROCEDURE Validate_IN_CUST_DASHBOARD (
    P_Api_Name			 IN	VARCHAR2,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_USE_IN_CUSTOMER_DASHBOARD                IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
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

      IF ( P_USE_IN_CUSTOMER_DASHBOARD <> CSC_CORE_UTILS_PVT.G_MISS_CHAR ) AND
	     ( P_USE_IN_CUSTOMER_DASHBOARD IS NOT NULL )
	THEN
    	 IF CSC_CORE_UTILS_PVT.lookup_code_not_exists(
 		p_effective_date  => trunc(sysdate),
  		p_lookup_type     => 'YES_NO',
  		p_lookup_code     => P_USE_IN_CUSTOMER_DASHBOARD ) <> FND_API.G_RET_STS_SUCCESS
    	 THEN
        	x_return_status := FND_API.G_RET_STS_ERROR;
        	CSC_CORE_UTILS_PVT.Add_Invalid_Argument_Msg(
					p_api_name => p_api_name,
			            p_argument_value  => P_USE_IN_CUSTOMER_DASHBOARD,
			            p_argument  => 'P_USE_IN_CUSTOMER_DASHBOARD');
       END IF;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_IN_CUST_DASHBOARD;


PROCEDURE Validate_SEEDED_FLAG (
    P_Api_Name			 IN	VARCHAR2,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_SEEDED_FLAG                IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
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

	--Its a hardcode right now but should change i guess.***
	IF ( P_SEEDED_FLAG IS NOT NULL AND
		P_SEEDED_FLAG <> CSC_CORE_UTILS_PVT.G_MISS_CHAR ) THEN
	 IF P_SEEDED_FLAG NOT IN ('Y','N')
	 THEN
        	x_return_status := FND_API.G_RET_STS_ERROR;
        	CSC_CORE_UTILS_PVT.Add_Invalid_Argument_Msg(
					p_api_name => p_api_name,
			            p_argument_value  => P_SEEDED_FLAG,
			            p_argument  => 'P_SEEDED_FLAG');
	 END IF;
	END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_SEEDED_FLAG;


PROCEDURE Validate_profile_groups(
    P_Init_Msg_List              IN   VARCHAR2 := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Validation_level           IN   NUMBER := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    P_Validation_mode            IN   VARCHAR2,
    P_PROF_GROUP_Rec             IN    PROF_GROUP_Rec_Type,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    )
IS
l_api_name   CONSTANT VARCHAR2(30) := 'Validate_profile_groups';
 BEGIN


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

          Validate_GROUP_NAME(
    	      p_Api_Name		   => l_api_name,
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_GROUP_NAME   => P_PROF_GROUP_Rec.GROUP_NAME,
	      p_GROUP_ID	=> P_PROF_GROUP_Rec.GROUP_ID,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;
          Validate_GROUP_NAME_CODE(
    	      p_Api_Name		   => l_api_name,
              p_init_msg_list          => CSC_CORE_UTILS_PVT.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_GROUP_NAME_CODE   => P_PROF_GROUP_Rec.GROUP_NAME_CODE,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

  	    -- validate start and end date
  	  CSC_CORE_UTILS_PVT.Validate_Start_End_Dt(
   		  p_Api_name 		=> l_Api_name,
     		  p_START_DATE		=> P_PROF_GROUP_Rec.START_DATE_ACTIVE,
     		  p_END_DATE		=> P_PROF_GROUP_Rec.END_DATE_ACTIVE,
     		  x_return_status	=> x_return_status );
  	  IF x_return_status  <> FND_API.G_RET_STS_SUCCESS THEN
       	      raise FND_API.G_EXC_ERROR;
  	  END IF;

          Validate_IN_CUST_DASHBOARD(
    	      p_Api_Name		   => l_api_name,
              p_init_msg_list          => CSC_CORE_UTILS_PVT.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_USE_IN_CUSTOMER_DASHBOARD   => P_PROF_GROUP_Rec.USE_IN_CUSTOMER_DASHBOARD,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;
          Validate_SEEDED_FLAG(
    	      p_Api_Name		   => l_api_name,
              p_init_msg_list          => CSC_CORE_UTILS_PVT.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_SEEDED_FLAG   => P_PROF_GROUP_Rec.SEEDED_FLAG,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

         CSC_CORE_UTILS_PVT.Validate_APPLICATION_ID (
           P_Init_Msg_List              => CSC_CORE_UTILS_PVT.G_FALSE,
           P_Application_ID             =>  P_PROF_GROUP_Rec.application_id,
           p_effective_date             => SYSDATE,
           X_Return_Status              => x_return_status,
           X_Msg_Count                  => x_msg_count,
           X_Msg_Data                   => x_msg_data );

        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                RAISE FND_API.G_EXC_ERROR;
        END IF;



END Validate_profile_groups;

End CSC_PROFILE_GROUPS_PVT;

/
