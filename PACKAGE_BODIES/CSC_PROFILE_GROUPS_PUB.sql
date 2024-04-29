--------------------------------------------------------
--  DDL for Package Body CSC_PROFILE_GROUPS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSC_PROFILE_GROUPS_PUB" as
/* $Header: cscppgrb.pls 115.11 2002/11/29 05:18:41 bhroy ship $ */
-- Start of Comments
-- Package name     : CSC_PROFILE_GROUPS_PUB
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSC_PROFILE_GROUPS_PUB';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'cscpugrb.pls';

PROCEDURE Convert_Pub_to_pvt_rec
  ( p_groups_rec     IN    PROF_GROUP_Rec_Type,
    x_pvt_groups_rec OUT NOCOPY   CSC_PROFILE_GROUPS_PVT.PROF_GROUP_Rec_Type
  )
IS
BEGIN

    x_pvt_Groups_rec.GROUP_ID := P_Groups_Rec.GROUP_ID;
    x_pvt_Groups_rec.GROUP_NAME := P_Groups_Rec.GROUP_NAME;
    x_pvt_Groups_rec.DESCRIPTION := P_Groups_Rec.DESCRIPTION;
    x_pvt_Groups_rec.GROUP_NAME_CODE := P_Groups_Rec.GROUP_NAME_CODE;
    x_pvt_Groups_rec.START_DATE_ACTIVE := P_Groups_Rec.START_DATE_ACTIVE;
    x_pvt_Groups_rec.END_DATE_ACTIVE := P_Groups_Rec.END_DATE_ACTIVE;
    x_pvt_Groups_rec.USE_IN_CUSTOMER_DASHBOARD := P_Groups_Rec.USE_IN_CUSTOMER_DASHBOARD;
    x_pvt_Groups_rec.PARTY_TYPE := P_Groups_Rec.PARTY_TYPE;
    x_pvt_Groups_rec.CREATED_BY := P_Groups_Rec.CREATED_BY;
    x_pvt_Groups_rec.CREATION_DATE := P_Groups_Rec.CREATION_DATE;
    x_pvt_Groups_rec.LAST_UPDATED_BY := P_Groups_Rec.LAST_UPDATED_BY;
    x_pvt_Groups_rec.LAST_UPDATE_DATE := P_Groups_Rec.LAST_UPDATE_DATE;
    x_pvt_Groups_rec.LAST_UPDATE_LOGIN := P_Groups_Rec.LAST_UPDATE_LOGIN;
    x_pvt_Groups_rec.OBJECT_VERSION_NUMBER := P_Groups_Rec.OBJECT_VERSION_NUMBER;
    x_pvt_Groups_rec.APPLICATION_ID := P_Groups_Rec.APPLICATION_ID;

END Convert_Pub_to_pvt_rec;
PROCEDURE Convert_Columns_to_Rec(
    P_GROUP_ID                   IN   NUMBER,
    P_CREATED_BY                 IN   NUMBER,
    P_CREATION_DATE              IN   DATE,
    P_LAST_UPDATED_BY            IN   NUMBER,
    P_LAST_UPDATE_DATE           IN   DATE,
    P_LAST_UPDATE_LOGIN          IN   NUMBER,
    P_GROUP_NAME                 IN   VARCHAR2,
    P_GROUP_NAME_CODE            IN   VARCHAR2,
    P_DESCRIPTION                IN   VARCHAR2,
    P_PARTY_TYPE		 IN   VARCHAR2,
    P_START_DATE_ACTIVE          IN   DATE,
    P_END_DATE_ACTIVE            IN   DATE,
    P_USE_IN_CUSTOMER_DASHBOARD  IN   VARCHAR2,
    P_SEEDED_FLAG         IN   VARCHAR2,
    P_OBJECT_VERSION_NUMBER 	 IN   NUMBER DEFAULT NULL,
    P_APPLICATION_ID             IN   NUMBER,
    X_PROF_GROUP_Rec     OUT NOCOPY    PROF_GROUP_Rec_Type
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
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    P_GROUP_ID                   IN   NUMBER,
    P_CREATED_BY                 IN   NUMBER,
    P_CREATION_DATE              IN   DATE,
    P_LAST_UPDATED_BY            IN   NUMBER,
    P_LAST_UPDATE_DATE           IN   DATE,
    P_LAST_UPDATE_LOGIN          IN   NUMBER,
    P_GROUP_NAME                 IN   VARCHAR2,
    P_GROUP_NAME_CODE            IN   VARCHAR2,
    P_DESCRIPTION                IN   VARCHAR2,
    P_PARTY_TYPE		         IN   VARCHAR2,
    P_START_DATE_ACTIVE          IN   DATE,
    P_END_DATE_ACTIVE            IN   DATE,
    P_USE_IN_CUSTOMER_DASHBOARD  IN   VARCHAR2,
    P_SEEDED_FLAG         IN   VARCHAR2,
    X_Object_Version_Number OUT NOCOPY  NUMBER,
    P_APPLICATION_ID             IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
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
      P_DESCRIPTION    	=>          P_DESCRIPTION,
      P_PARTY_TYPE 	=>		P_PARTY_TYPE,
      P_START_DATE_ACTIVE 	=>    P_START_DATE_ACTIVE,
      P_END_DATE_ACTIVE 	=>    P_END_DATE_ACTIVE,
      P_USE_IN_CUSTOMER_DASHBOARD 	=>  P_USE_IN_CUSTOMER_DASHBOARD,
      P_SEEDED_FLAG 	=>        P_SEEDED_FLAG,
      P_APPLICATION_ID          => P_APPLICATION_ID,
      X_PROF_GROUP_Rec     => l_prof_group_rec
	);

      Create_profile_groups(
      P_Api_Version_Number         => 1.0,
      P_Init_Msg_List              => p_Init_Msg_List,
      P_Commit                     => p_Commit,
      PX_GROUP_ID                  => px_GROUP_ID,
      P_PROF_GROUP_Rec  	   =>  l_prof_group_rec,
      X_Object_Version_Number      => x_Object_Version_Number,
      X_Return_Status              => x_return_status,
      X_Msg_Count                  => x_msg_count,
      X_Msg_Data                   => x_msg_data);

END;

PROCEDURE Create_profile_groups(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    P_PROF_GROUP_Rec     IN    PROF_GROUP_Rec_Type,
    PX_GROUP_ID     IN OUT NOCOPY  NUMBER,
    X_Object_Version_Number OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
l_api_name                CONSTANT VARCHAR2(30) := 'Create_profile_groups';
l_api_version_number      CONSTANT NUMBER   := 1.0;

l_pvt_PROF_GROUP_rec    CSC_PROFILE_GROUPS_PVT.PROF_GROUP_Rec_Type;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_PROFILE_GROUPS_PUB;

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

      Convert_Pub_to_pvt_rec(
  	p_groups_rec => P_PROF_GROUP_REC,
      x_pvt_groups_rec => l_pvt_prof_group_Rec
      );


      CSC_profile_groups_PVT.Create_profile_groups(
      P_Api_Version_Number         => 1.0,
      P_Init_Msg_List              => CSC_CORE_UTILS_PVT.G_FALSE,
      P_Commit                     => CSC_CORE_UTILS_PVT.G_FALSE,
      P_Validation_Level           => CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
      P_PROF_GROUP_Rec  	 =>  l_pvt_prof_group_Rec,
      PX_GROUP_ID     		 => Px_GROUP_ID,
      X_Object_Version_Number  => x_Object_Version_Number,
      X_Return_Status              => x_return_status,
      X_Msg_Count                  => x_msg_count,
      X_Msg_Data                   => x_msg_data);



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

      EXCEPTION
  	    WHEN FND_API.G_EXC_ERROR THEN
    		 ROLLBACK TO Create_profile_groups_PUB;
    		 x_return_status := FND_API.G_RET_STS_ERROR;
    		 FND_MSG_PUB.Count_And_Get
      			( p_count => x_msg_count,
        		  	  p_data  => x_msg_data
      			);
  	    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    		 ROLLBACK TO Create_profile_groups_PUB;
    		 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    		 FND_MSG_PUB.Count_And_Get
      			( p_count => x_msg_count,
        		  	  p_data  => x_msg_data
      			);
  	    WHEN OTHERS THEN
    		 ROLLBACK TO Create_profile_groups_PUB;
    		 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    		 IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      			FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    		 END IF;
    		 FND_MSG_PUB.Count_And_Get
      			( p_count => x_msg_count,
        		  	  p_data  => x_msg_data
      			);
End Create_profile_groups;

PROCEDURE Update_profile_groups(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    P_GROUP_ID                   IN   NUMBER,
    P_CREATED_BY                 IN   NUMBER,
    P_CREATION_DATE              IN   DATE,
    P_LAST_UPDATED_BY            IN   NUMBER,
    P_LAST_UPDATE_DATE           IN   DATE,
    P_LAST_UPDATE_LOGIN          IN   NUMBER,
    P_GROUP_NAME                 IN   VARCHAR2,
    P_GROUP_NAME_CODE            IN   VARCHAR2,
    P_DESCRIPTION                IN   VARCHAR2,
    P_PARTY_TYPE		         IN   VARCHAR2,
    P_START_DATE_ACTIVE          IN   DATE,
    P_END_DATE_ACTIVE            IN   DATE,
    P_USE_IN_CUSTOMER_DASHBOARD  IN   VARCHAR2,
    P_SEEDED_FLAG         IN   VARCHAR2,
    PX_OBJECT_VERSION_NUMBER 	   IN OUT NOCOPY   NUMBER,
    P_APPLICATION_ID             IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
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
      P_APPLICATION_ID          => P_APPLICATION_ID,
      X_PROF_GROUP_Rec     => l_prof_group_rec
	);

      Update_profile_groups(
      P_Api_Version_Number         => P_Api_Version_Number,
      P_Init_Msg_List              => P_Init_Msg_List,
      P_Commit                     => P_Commit,
      P_PROF_GROUP_Rec  	=>  l_prof_group_rec,
      PX_Object_Version_Number => px_Object_Version_Number,
      X_Return_Status              => x_return_status,
      X_Msg_Count                  => x_msg_count,
      X_Msg_Data                   => x_msg_data);
END;

PROCEDURE Update_profile_groups(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    P_PROF_GROUP_Rec      IN     PROF_GROUP_Rec_Type,
    PX_Object_Version_Number IN OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Update_profile_groups';
l_api_version_number      CONSTANT NUMBER   := 1.0;

l_pvt_PROF_GROUP_rec  CSC_PROFILE_GROUPS_PVT.PROF_GROUP_Rec_Type;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_PROFILE_GROUPS_PUB;

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

      Convert_Pub_to_pvt_rec(
  	p_groups_rec => P_PROF_GROUP_REC,
      x_pvt_groups_rec => l_pvt_prof_group_Rec );

      CSC_profile_groups_PVT.Update_profile_groups(
      P_Api_Version_Number         => 1.0,
      P_Init_Msg_List              => CSC_CORE_UTILS_PVT.G_FALSE,
      P_Commit                     => p_commit,
      P_Validation_Level           => CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
      P_PROF_GROUP_Rec  =>  l_pvt_prof_group_Rec ,
      PX_Object_Version_Number => px_Object_Version_Number,
      X_Return_Status              => x_return_status,
      X_Msg_Count                  => x_msg_count,
      X_Msg_Data                   => x_msg_data);



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
    		 ROLLBACK TO Update_profile_groups_PUB;
    		 x_return_status := FND_API.G_RET_STS_ERROR;
    		 FND_MSG_PUB.Count_And_Get
      			( p_count => x_msg_count,
        		  	  p_data  => x_msg_data
      			);
  	    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    		 ROLLBACK TO Update_profile_groups_PUB;
    		 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    		 FND_MSG_PUB.Count_And_Get
      			( p_count => x_msg_count,
        		  	  p_data  => x_msg_data
      			);
  	    WHEN OTHERS THEN
    		 ROLLBACK TO Update_profile_groups_PUB;
    		 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    		 IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      			FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    		 END IF;
    		 FND_MSG_PUB.Count_And_Get
      			( p_count => x_msg_count,
        		  	  p_data  => x_msg_data
      			);
End Update_profile_groups;


PROCEDURE Delete_profile_groups(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    P_GROUP_Id     		 IN NUMBER,
    P_Object_Version_Number      IN  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Delete_profile_groups';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_pvt_PROF_GROUP_rec  CSC_PROFILE_GROUPS_PVT.PROF_GROUP_Rec_Type;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_PROFILE_GROUPS_PUB;

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


    CSC_profile_groups_PVT.Delete_profile_groups(
    P_Api_Version_Number         => 1.0,
    P_Init_Msg_List              => CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit                     => p_commit,
    P_Validation_Level           => CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    P_GROUP_Id  => P_GROUP_Id,
    P_OBJECT_VERSION_NUMBER => p_OBJECT_VERSION_NUMBER,
    X_Return_Status              => x_return_status,
    X_Msg_Count                  => x_msg_count,
    X_Msg_Data                   => x_msg_data);



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
    		 ROLLBACK TO Delete_profile_groups_PUB;
    		 x_return_status := FND_API.G_RET_STS_ERROR;
    		 FND_MSG_PUB.Count_And_Get
      			( p_count => x_msg_count,
        		  	  p_data  => x_msg_data
      			);
  	    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    		 ROLLBACK TO Delete_profile_groups_PUB;
    		 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    		 FND_MSG_PUB.Count_And_Get
      			( p_count => x_msg_count,
        		  	  p_data  => x_msg_data
      			);
  	    WHEN OTHERS THEN
    		 ROLLBACK TO Delete_profile_groups_PUB;
    		 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    		 IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      			FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    		 END IF;
    		 FND_MSG_PUB.Count_And_Get
      			( p_count => x_msg_count,
        		  	  p_data  => x_msg_data
      			);
End Delete_profile_groups;



End CSC_PROFILE_GROUPS_PUB;

/
