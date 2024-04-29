--------------------------------------------------------
--  DDL for Package Body CSC_PROF_MODULE_GROUPS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSC_PROF_MODULE_GROUPS_PUB" as
/* $Header: cscppmgb.pls 115.15 2002/12/09 08:45:14 agaddam ship $ */
-- Start of Comments
-- Package name     : CSC_PROF_MODULE_GROUPS_PUB
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSC_PROF_MODULE_GROUPS_PUB';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'cscppmgb.pls';

PROCEDURE Convert_pub_to_pvt_Rec (
         P_PROF_MODULE_GRP_rec        IN   CSC_PROF_MODULE_GROUPS_PUB.PROF_MODULE_GRP_Rec_Type,
         x_pvt_PROF_MODULE_GRP_rec    OUT NOCOPY  CSC_PROF_MODULE_GROUPS_PVT.PROF_MODULE_GRP_Rec_Type
)
IS
l_any_errors       BOOLEAN   := FALSE;
BEGIN

    x_pvt_PROF_MODULE_GRP_rec.MODULE_GROUP_ID := P_PROF_MODULE_GRP_Rec.MODULE_GROUP_ID;
    x_pvt_PROF_MODULE_GRP_rec.FORM_FUNCTION_ID := P_PROF_MODULE_GRP_Rec.FORM_FUNCTION_ID;
    x_pvt_PROF_MODULE_GRP_rec.FORM_FUNCTION_NAME := P_PROF_MODULE_GRP_Rec.FORM_FUNCTION_NAME;
    x_pvt_PROF_MODULE_GRP_rec.RESPONSIBILITY_ID := P_PROF_MODULE_GRP_Rec.RESPONSIBILITY_ID;
    x_pvt_PROF_MODULE_GRP_rec.RESP_APPL_ID := P_PROF_MODULE_GRP_Rec.RESP_APPL_ID;
    x_pvt_PROF_MODULE_GRP_rec.PARTY_TYPE := P_PROF_MODULE_GRP_Rec.PARTY_TYPE;
    x_pvt_PROF_MODULE_GRP_rec.GROUP_ID := P_PROF_MODULE_GRP_Rec.GROUP_ID;
    x_pvt_PROF_MODULE_GRP_rec.DASHBOARD_GROUP_FLAG := P_PROF_MODULE_GRP_Rec.DASHBOARD_GROUP_FLAG;
    x_pvt_PROF_MODULE_GRP_rec.CURRENCY_CODE := P_PROF_MODULE_GRP_Rec.CURRENCY_CODE;
    x_pvt_PROF_MODULE_GRP_rec.LAST_UPDATE_DATE := P_PROF_MODULE_GRP_Rec.LAST_UPDATE_DATE;
    x_pvt_PROF_MODULE_GRP_rec.LAST_UPDATED_BY := P_PROF_MODULE_GRP_Rec.LAST_UPDATED_BY;
    x_pvt_PROF_MODULE_GRP_rec.CREATION_DATE := P_PROF_MODULE_GRP_Rec.CREATION_DATE;
    x_pvt_PROF_MODULE_GRP_rec.CREATED_BY := P_PROF_MODULE_GRP_Rec.CREATED_BY;
    x_pvt_PROF_MODULE_GRP_rec.LAST_UPDATE_LOGIN := P_PROF_MODULE_GRP_Rec.LAST_UPDATE_LOGIN;
    x_pvt_PROF_MODULE_GRP_rec.SEEDED_FLAG:= P_PROF_MODULE_GRP_Rec.SEEDED_FLAG;
    x_pvt_PROF_MODULE_GRP_rec.APPLICATION_ID:= P_PROF_MODULE_GRP_Rec.APPLICATION_ID;
    x_pvt_PROF_MODULE_GRP_rec.DASHBOARD_GROUP_ID := P_PROF_MODULE_GRP_Rec.DASHBOARD_GROUP_ID;

  -- If there is an error in conversion precessing, raise an error.
    IF l_any_errors
    THEN
        raise FND_API.G_EXC_ERROR;
    END IF;

END Convert_pub_to_pvt_Rec;

PROCEDURE Convert_Columns_to_Rec (
     p_MODULE_GROUP_ID                 NUMBER DEFAULT NULL,
     p_FORM_FUNCTION_ID                NUMBER,
     p_FORM_FUNCTION_NAME              VARCHAR2,
     p_RESPONSIBILITY_ID               NUMBER,
     p_RESP_APPL_ID                    NUMBER,
     p_PARTY_TYPE                      VARCHAR2,
     p_GROUP_ID                        NUMBER,
     p_DASHBOARD_GROUP_FLAG            VARCHAR2,
     p_CURRENCY_CODE                   VARCHAR2,
     p_LAST_UPDATE_DATE                DATE,
     p_LAST_UPDATED_BY                 NUMBER,
     p_CREATION_DATE                   DATE,
     p_CREATED_BY                      NUMBER,
     p_LAST_UPDATE_LOGIN               NUMBER,
     p_SEEDED_FLAG                     VARCHAR2,
     p_APPLICATION_ID                  NUMBER,
     p_DASHBOARD_GROUP_ID              NUMBER,
     x_PROF_MODULE_GRP_Rec     OUT NOCOPY     PROF_MODULE_GRP_Rec_Type    )
  IS
BEGIN

    x_PROF_MODULE_GRP_rec.MODULE_GROUP_ID := P_MODULE_GROUP_ID;
    x_PROF_MODULE_GRP_rec.FORM_FUNCTION_ID := P_FORM_FUNCTION_ID;
    x_PROF_MODULE_GRP_rec.FORM_FUNCTION_NAME := P_FORM_FUNCTION_NAME;
    x_PROF_MODULE_GRP_rec.RESPONSIBILITY_ID := P_RESPONSIBILITY_ID;
    x_PROF_MODULE_GRP_rec.RESP_APPL_ID := P_RESP_APPL_ID;
    x_PROF_MODULE_GRP_rec.PARTY_TYPE := P_PARTY_TYPE;
    x_PROF_MODULE_GRP_rec.GROUP_ID := P_GROUP_ID;
    x_PROF_MODULE_GRP_rec.DASHBOARD_GROUP_FLAG := P_DASHBOARD_GROUP_FLAG;
    x_PROF_MODULE_GRP_rec.CURRENCY_CODE := P_CURRENCY_CODE;
    x_PROF_MODULE_GRP_rec.LAST_UPDATE_DATE := P_LAST_UPDATE_DATE;
    x_PROF_MODULE_GRP_rec.LAST_UPDATED_BY := P_LAST_UPDATED_BY;
    x_PROF_MODULE_GRP_rec.CREATION_DATE := P_CREATION_DATE;
    x_PROF_MODULE_GRP_rec.CREATED_BY := P_CREATED_BY;
    x_PROF_MODULE_GRP_rec.LAST_UPDATE_LOGIN := P_LAST_UPDATE_LOGIN;
    x_PROF_MODULE_GRP_rec.SEEDED_FLAG := P_SEEDED_FLAG;
    x_PROF_MODULE_GRP_rec.APPLICATION_ID := P_APPLICATION_ID;
    x_PROF_MODULE_GRP_rec.DASHBOARD_GROUP_ID := P_DASHBOARD_GROUP_ID;

END Convert_Columns_to_Rec;


PROCEDURE Create_prof_module_groups(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    PX_MODULE_GROUP_ID           IN OUT NOCOPY  NUMBER,
    p_FORM_FUNCTION_ID                NUMBER,
    p_FORM_FUNCTION_NAME              VARCHAR2,
    p_RESPONSIBILITY_ID                NUMBER,
    p_RESP_APPL_ID                NUMBER,
    p_PARTY_TYPE                      VARCHAR2,
    p_GROUP_ID                        NUMBER,
    p_DASHBOARD_GROUP_FLAG            VARCHAR2,
    p_CURRENCY_CODE                   VARCHAR2,
    p_LAST_UPDATE_DATE                DATE,
    p_LAST_UPDATED_BY                 NUMBER,
    p_CREATION_DATE                   DATE,
    p_CREATED_BY                      NUMBER,
    p_LAST_UPDATE_LOGIN               NUMBER,
    p_SEEDED_FLAG                     VARCHAR2,
    p_APPLICATION_ID                  NUMBER,
    p_DASHBOARD_GROUP_ID              NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
 l_PROF_MODULE_GRP_REC PROF_MODULE_GRP_REC_TYPE;
BEGIN

 Convert_Columns_to_Rec (
     p_FORM_FUNCTION_ID     => p_FORM_FUNCTION_ID,
     p_FORM_FUNCTION_NAME   => p_FORM_FUNCTION_NAME,
     p_RESPONSIBILITY_ID     => p_RESPONSIBILITY_ID,
     p_RESP_APPL_ID         => p_RESP_APPL_ID,
     p_PARTY_TYPE           => p_PARTY_TYPE,
     p_GROUP_ID             => p_GROUP_ID,
     p_DASHBOARD_GROUP_FLAG => p_DASHBOARD_GROUP_FLAG,
     p_CURRENCY_CODE        => p_CURRENCY_CODE,
     p_LAST_UPDATE_DATE     => p_LAST_UPDATE_DATE,
     p_LAST_UPDATED_BY      => p_LAST_UPDATED_BY,
     p_CREATION_DATE        => p_CREATION_DATE,
     p_CREATED_BY           => p_CREATED_BY,
     p_LAST_UPDATE_LOGIN    => p_LAST_UPDATE_LOGIN,
     p_SEEDED_FLAG          => p_SEEDED_FLAG,
     p_APPLICATION_ID       => p_APPLICATION_ID,
     p_DASHBOARD_GROUP_ID   => p_DASHBOARD_GROUP_ID,
     x_PROF_MODULE_GRP_Rec  => l_PROF_MODULE_GRP_Rec    );


Create_prof_module_groups(
    P_Api_Version_Number     => P_Api_Version_Number,
    P_Init_Msg_List          => P_Init_Msg_List,
    P_Commit                 => P_Commit,
    P_PROF_MODULE_GRP_Rec    => l_PROF_MODULE_GRP_Rec,
    PX_MODULE_GROUP_ID       => PX_MODULE_GROUP_ID,
    X_Return_Status          => X_Return_Status,
    X_Msg_Count              => X_Msg_Count,
    X_Msg_Data               => X_Msg_Data
    );

END Create_prof_module_groups;


PROCEDURE Create_prof_module_groups(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    P_PROF_MODULE_GRP_Rec        IN    PROF_MODULE_GRP_Rec_Type,
    PX_MODULE_GROUP_ID           IN OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                   CONSTANT VARCHAR2(30) := 'Create_prof_module_groups';
l_api_version_number         CONSTANT NUMBER   := 2.0;
l_pvt_PROF_MODULE_GRP_rec    CSC_PROF_MODULE_GROUPS_PVT.PROF_MODULE_GRP_Rec_Type;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_PROF_MODULE_GROUPS_PUB;

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

      --
      Convert_pub_to_pvt_Rec (
            P_PROF_MODULE_GRP_rec      =>  p_PROF_MODULE_GRP_rec,
            x_pvt_PROF_MODULE_GRP_rec  =>  l_pvt_PROF_MODULE_GRP_rec
      );


    -- Calling Private package: Create_PROF_MODULE_GROUPS
    -- Hint: Primary key needs to be returned
      CSC_prof_module_groups_PVT.Create_prof_module_groups(
      P_Api_Version_Number         => 2.0,
      P_Init_Msg_List              => FND_API.G_FALSE,
      P_Commit                     => FND_API.G_FALSE,
      P_Validation_Level           => FND_API.G_VALID_LEVEL_FULL,
      P_PROF_MODULE_GRP_Rec        =>  l_pvt_PROF_MODULE_GRP_Rec ,
      PX_MODULE_GROUP_ID           => px_MODULE_GROUP_ID,
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
			ROLLBACK TO  CREATE_PROF_MODULE_GROUPS_PUB;
			 x_return_status :=  FND_API.G_RET_STS_ERROR ;
			 FND_MSG_PUB.Count_And_Get(p_count =>x_msg_count,
								  p_data => x_msg_data) ;

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
			ROLLBACK TO  CREATE_PROF_MODULE_GROUPS_PUB;
			 x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR ;
			 FND_MSG_PUB.Count_And_Get(p_count =>x_msg_count,
								  p_data => x_msg_data) ;

          WHEN OTHERS THEN
			ROLLBACK TO  CREATE_PROF_MODULE_GROUPS_PUB;
			 x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR ;
			 IF FND_MSG_PUB.Check_Msg_Level
						 (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
			 THEN
			 FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
			 END IF ;
			 FND_MSG_PUB.Count_And_Get(p_count =>x_msg_count,
								  p_data => x_msg_data) ;

End Create_prof_module_groups;


PROCEDURE Update_prof_module_groups(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    P_MODULE_GROUP_ID          	      NUMBER,
    p_FORM_FUNCTION_ID                NUMBER,
    p_FORM_FUNCTION_NAME              VARCHAR2,
    p_RESPONSIBILITY_ID                NUMBER,
    p_RESP_APPL_ID                NUMBER,
    p_PARTY_TYPE                      VARCHAR2,
    p_GROUP_ID                        NUMBER,
    p_DASHBOARD_GROUP_FLAG            VARCHAR2,
    p_CURRENCY_CODE                   VARCHAR2,
    p_LAST_UPDATE_DATE                DATE,
    p_LAST_UPDATED_BY                 NUMBER,
    p_CREATION_DATE                   DATE,
    p_CREATED_BY                      NUMBER,
    p_LAST_UPDATE_LOGIN               NUMBER,
    p_SEEDED_FLAG                     VARCHAR2,
    p_APPLICATION_ID                  NUMBER,
    p_DASHBOARD_GROUP_ID              NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
 l_PROF_MODULE_GRP_REC PROF_MODULE_GRP_REC_TYPE;
BEGIN

 Convert_Columns_to_Rec (
     p_FORM_FUNCTION_ID     => p_FORM_FUNCTION_ID,
     p_FORM_FUNCTION_NAME   => p_FORM_FUNCTION_NAME,
     p_RESPONSIBILITY_ID     => p_RESPONSIBILITY_ID,
     p_RESP_APPL_ID     => p_RESP_APPL_ID,
     p_PARTY_TYPE           => p_PARTY_TYPE,
     p_GROUP_ID             => p_GROUP_ID,
     p_DASHBOARD_GROUP_FLAG => p_DASHBOARD_GROUP_FLAG,
     p_CURRENCY_CODE        => p_CURRENCY_CODE,
     p_LAST_UPDATE_DATE     => p_LAST_UPDATE_DATE,
     p_LAST_UPDATED_BY      => p_LAST_UPDATED_BY,
     p_CREATION_DATE        => p_CREATION_DATE,
     p_CREATED_BY           => p_CREATED_BY,
     p_LAST_UPDATE_LOGIN    => p_LAST_UPDATE_LOGIN,
     p_SEEDED_FLAG          => p_SEEDED_FLAG,
     p_APPLICATION_ID       => p_APPLICATION_ID ,
     p_DASHBOARD_GROUP_ID   => p_DASHBOARD_GROUP_ID,
     x_PROF_MODULE_GRP_Rec  => l_PROF_MODULE_GRP_Rec    );


 Update_prof_module_groups(
    P_Api_Version_Number     => P_Api_Version_Number,
    P_Init_Msg_List          => P_Init_Msg_List,
    P_Commit                 => P_Commit,
    P_PROF_MODULE_GRP_Rec    => l_PROF_MODULE_GRP_Rec,
    X_Return_Status          => X_Return_Status,
    X_Msg_Count              => X_Msg_Count,
    X_Msg_Data               => X_Msg_Data
    );

END Update_prof_module_groups;

PROCEDURE Update_prof_module_groups(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    P_PROF_MODULE_GRP_Rec        IN    PROF_MODULE_GRP_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                  CONSTANT VARCHAR2(30) := 'Update_prof_module_groups';
l_api_version_number        CONSTANT NUMBER   := 1.0;
l_pvt_PROF_MODULE_GRP_rec   CSC_PROF_MODULE_GROUPS_PVT.PROF_MODULE_GRP_Rec_Type;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_PROF_MODULE_GROUPS_PUB;

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

      -- Convert the values to ids
      --
      Convert_pub_to_pvt_Rec (
            P_PROF_MODULE_GRP_rec      =>  p_PROF_MODULE_GRP_rec,
            x_pvt_PROF_MODULE_GRP_rec  =>  l_pvt_PROF_MODULE_GRP_rec
      );

    CSC_prof_module_groups_PVT.Update_prof_module_groups(
    P_Api_Version_Number         => 1.0,
    P_Init_Msg_List              => FND_API.G_FALSE,
    P_Commit                     => p_commit,
    P_Validation_Level           => FND_API.G_VALID_LEVEL_FULL,
    P_PROF_MODULE_GRP_Rec  =>  l_pvt_PROF_MODULE_GRP_Rec ,
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
		 ROLLBACK TO UPDATE_PROF_MODULE_GROUPS_PUB;
           x_return_status :=  FND_API.G_RET_STS_ERROR ;
           FND_MSG_PUB.Count_And_Get(p_count =>x_msg_count,
                                     p_data => x_msg_data) ;


          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		 ROLLBACK TO UPDATE_PROF_MODULE_GROUPS_PUB;
           x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR ;
           FND_MSG_PUB.Count_And_Get(p_count =>x_msg_count,
                                     p_data => x_msg_data) ;

          WHEN OTHERS THEN
		 ROLLBACK TO UPDATE_PROF_MODULE_GROUPS_PUB;
           x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR ;
           IF FND_MSG_PUB.Check_Msg_Level
                          (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
           THEN
           FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
           END IF ;
           FND_MSG_PUB.Count_And_Get(p_count =>x_msg_count,
                                     p_data => x_msg_data) ;

End Update_prof_module_groups;


PROCEDURE Delete_prof_module_groups(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    P_PROF_MODULE_GRP_Rec     IN PROF_MODULE_GRP_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Delete_prof_module_groups';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_pvt_PROF_MODULE_GRP_rec  CSC_PROF_MODULE_GROUPS_PVT.PROF_MODULE_GRP_Rec_Type;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_PROF_MODULE_GROUPS_PUB;

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

      -- Convert the values to ids
      --
      Convert_pub_to_pvt_Rec (
            P_PROF_MODULE_GRP_rec      =>  p_PROF_MODULE_GRP_rec,
            x_pvt_PROF_MODULE_GRP_rec  =>  l_pvt_PROF_MODULE_GRP_rec
      );
      -- Convert the values to ids
      --
    CSC_prof_module_groups_PVT.Delete_prof_module_groups(
    P_Api_Version_Number         => 1.0,
    P_Init_Msg_List              => FND_API.G_FALSE,
    P_Commit                     => p_commit,
    P_Validation_Level           => FND_API.G_VALID_LEVEL_FULL,
    P_PROF_MODULE_GRP_Id  => l_pvt_PROF_MODULE_GRP_Rec.module_group_id,
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
		 ROLLBACK TO DELETE_PROF_MODULE_GROUPS_PUB;
    		 x_return_status := FND_API.G_RET_STS_ERROR;
    		 FND_MSG_PUB.Count_And_Get
      			( p_count => x_msg_count,
        		  	  p_data  => x_msg_data
      			);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		 ROLLBACK TO DELETE_PROF_MODULE_GROUPS_PUB;
    		 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    		 FND_MSG_PUB.Count_And_Get
      			( p_count => x_msg_count,
        		  	  p_data  => x_msg_data
      			);

          WHEN OTHERS THEN
		 ROLLBACK TO DELETE_PROF_MODULE_GROUPS_PUB;
    		 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    		 IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      			FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    		 END IF;
    		 FND_MSG_PUB.Count_And_Get
      			( p_count => x_msg_count,
        		  	  p_data  => x_msg_data
      			);

End Delete_prof_module_groups;


End CSC_PROF_MODULE_GROUPS_PUB;

/
