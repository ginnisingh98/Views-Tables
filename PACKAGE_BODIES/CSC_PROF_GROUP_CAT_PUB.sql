--------------------------------------------------------
--  DDL for Package Body CSC_PROF_GROUP_CAT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSC_PROF_GROUP_CAT_PUB" as
/* $Header: cscppcab.pls 115.8 2002/11/29 07:27:52 bhroy ship $ */
-- Start of Comments
-- Package name     : CSC_PROF_GROUP_CAT_PUB
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSC_PROF_GROUP_CAT_PUB';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'cscppgcb.pls';

-- Start of Comments

PROCEDURE Convert_pub_to_pvt_Rec (
		P_PROF_GRP_CAT_Rec     IN    CSC_PROF_GROUP_CAT_PUB.PROF_GRP_CAT_Rec_Type,
		x_pvt_PROF_GRP_CAT_rec OUT NOCOPY   CSC_PROF_GROUP_CAT_PVT.PROF_GRP_CAT_Rec_Type
)
IS
l_any_errors       BOOLEAN   := FALSE;
BEGIN

    x_pvt_PROF_GRP_CAT_rec.GROUP_CATEGORY_ID := P_PROF_GRP_CAT_Rec.GROUP_CATEGORY_ID;
    x_pvt_PROF_GRP_CAT_rec.GROUP_ID := P_PROF_GRP_CAT_Rec.GROUP_ID;
    x_pvt_PROF_GRP_CAT_rec.CATEGORY_CODE := P_PROF_GRP_CAT_Rec.CATEGORY_CODE;
    x_pvt_PROF_GRP_CAT_rec.CATEGORY_SEQUENCE := P_PROF_GRP_CAT_Rec.CATEGORY_SEQUENCE;
    x_pvt_PROF_GRP_CAT_rec.CREATED_BY := P_PROF_GRP_CAT_Rec.CREATED_BY;
    x_pvt_PROF_GRP_CAT_rec.CREATION_DATE := P_PROF_GRP_CAT_Rec.CREATION_DATE;
    x_pvt_PROF_GRP_CAT_rec.LAST_UPDATED_BY := P_PROF_GRP_CAT_Rec.LAST_UPDATED_BY;
    x_pvt_PROF_GRP_CAT_rec.LAST_UPDATE_DATE := P_PROF_GRP_CAT_Rec.LAST_UPDATE_DATE;
    x_pvt_PROF_GRP_CAT_rec.LAST_UPDATE_LOGIN := P_PROF_GRP_CAT_Rec.LAST_UPDATE_LOGIN;
    x_pvt_PROF_GRP_CAT_rec.SEEDED_FLAG := P_PROF_GRP_CAT_Rec.SEEDED_FLAG;


  -- If there is an error in conversion precessing, raise an error.
    IF l_any_errors
    THEN
        raise FND_API.G_EXC_ERROR;
    END IF;

END Convert_pub_to_pvt_Rec;


PROCEDURE Convert_Columns_to_Rec (
    p_GROUP_CATEGORY_ID               NUMBER DEFAULT NULL,
    p_GROUP_ID                        NUMBER,
    p_CATEGORY_CODE                   VARCHAR2,
    p_CATEGORY_SEQUENCE               NUMBER,
    p_CREATED_BY                      NUMBER,
    p_CREATION_DATE                   DATE,
    p_LAST_UPDATED_BY                 NUMBER,
    p_LAST_UPDATE_DATE                DATE,
    p_LAST_UPDATE_LOGIN               NUMBER,
    p_SEEDED_FLAG                     VARCHAR2,
    x_PROF_GRP_CAT_rec    OUT NOCOPY    PROF_GRP_CAT_Rec_Type
    )
  IS
BEGIN

    x_PROF_GRP_CAT_rec.GROUP_CATEGORY_ID := P_GROUP_CATEGORY_ID;
    x_PROF_GRP_CAT_rec.GROUP_ID := P_GROUP_ID;
    x_PROF_GRP_CAT_rec.CATEGORY_CODE := P_CATEGORY_CODE;
    x_PROF_GRP_CAT_rec.CATEGORY_SEQUENCE := P_CATEGORY_SEQUENCE;
    x_PROF_GRP_CAT_rec.CREATED_BY := P_CREATED_BY;
    x_PROF_GRP_CAT_rec.CREATION_DATE := P_CREATION_DATE;
    x_PROF_GRP_CAT_rec.LAST_UPDATED_BY := P_LAST_UPDATED_BY;
    x_PROF_GRP_CAT_rec.LAST_UPDATE_DATE := P_LAST_UPDATE_DATE;
    x_PROF_GRP_CAT_rec.LAST_UPDATE_LOGIN := P_LAST_UPDATE_LOGIN;
    x_PROF_GRP_CAT_rec.SEEDED_FLAG := P_SEEDED_FLAG;

END Convert_Columns_to_Rec;


PROCEDURE Create_csc_prof_group_cat(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    px_GROUP_CATEGORY_ID         IN OUT NOCOPY      NUMBER,
    p_GROUP_ID                        NUMBER,
    p_CATEGORY_CODE                   VARCHAR2,
    p_CATEGORY_SEQUENCE               NUMBER,
    p_CREATED_BY                      NUMBER,
    p_CREATION_DATE                   DATE,
    p_LAST_UPDATED_BY                 NUMBER,
    p_LAST_UPDATE_DATE                DATE,
    p_LAST_UPDATE_LOGIN               NUMBER,
    p_SEEDED_FLAG                     VARCHAR2,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
l_PROF_GRP_CAT_Rec  PROF_GRP_CAT_Rec_Type;

BEGIN

 Convert_Columns_to_Rec (
    p_GROUP_ID             => p_GROUP_ID ,
    p_CATEGORY_CODE        => p_CATEGORY_CODE,
    p_CATEGORY_SEQUENCE    => p_CATEGORY_SEQUENCE,
    p_CREATED_BY           => p_CREATED_BY,
    p_CREATION_DATE        => p_CREATION_DATE,
    p_LAST_UPDATED_BY      => p_LAST_UPDATED_BY,
    p_LAST_UPDATE_DATE     => p_LAST_UPDATE_DATE,
    p_LAST_UPDATE_LOGIN    => p_LAST_UPDATE_LOGIN,
    p_SEEDED_FLAG          => p_SEEDED_FLAG,
    x_PROF_GRP_CAT_rec    => l_PROF_GRP_CAT_Rec
    );


Create_csc_prof_group_cat(
    P_Api_Version_Number   => P_Api_Version_Number,
    P_Init_Msg_List        => P_Init_Msg_List,
    P_Commit               => P_Commit ,
    PX_GROUP_CATEGORY_ID   => PX_GROUP_CATEGORY_ID,
    P_PROF_GRP_CAT_Rec     => l_PROF_GRP_CAT_Rec,
    X_Return_Status        => X_Return_Status,
    X_Msg_Count            => X_Msg_Count,
    X_Msg_Data             => X_Msg_Data
    );

END Create_csc_prof_group_cat;


PROCEDURE Create_csc_prof_group_cat(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    P_PROF_GRP_CAT_Rec     IN    PROF_GRP_CAT_Rec_Type,
    PX_GROUP_CATEGORY_ID     IN OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Create_csc_prof_group_cat';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_pvt_PROF_GRP_CAT_rec    CSC_PROF_GROUP_CAT_PVT.PROF_GRP_CAT_Rec_Type;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_CSC_PROF_GROUP_CAT_PUB;

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
		P_PROF_GRP_CAT_Rec      =>  p_PROF_GRP_CAT_rec,
		x_pvt_PROF_GRP_CAT_rec => l_pvt_PROF_GRP_CAT_rec
	);


    -- Calling Private package: Create_CSC_PROF_GROUP_CAT
    -- Hint: Primary key needs to be returned
      csc_prof_group_cat_PVT.Create_csc_prof_group_cat(
      P_Api_Version_Number         => 1.0,
      P_Init_Msg_List              => FND_API.G_FALSE,
      P_Commit                     => FND_API.G_FALSE,
      P_Validation_Level           => FND_API.G_VALID_LEVEL_FULL,
      P_PROF_GRP_CAT_Rec  =>  l_pvt_PROF_GRP_CAT_Rec ,
      PX_GROUP_CATEGORY_ID     => Px_GROUP_CATEGORY_ID,
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
      	 ROLLBACK TO CREATE_CSC_PROF_GROUP_CAT_PUB;
           x_return_status :=  FND_API.G_RET_STS_ERROR ;
           FND_MSG_PUB.Count_And_Get(p_count =>x_msg_count,
                                     p_data => x_msg_data) ;

         WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      	 ROLLBACK TO CREATE_CSC_PROF_GROUP_CAT_PUB;
           x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR ;
           FND_MSG_PUB.Count_And_Get(p_count =>x_msg_count,
                                     p_data => x_msg_data) ;

          WHEN OTHERS THEN
      	 ROLLBACK TO CREATE_CSC_PROF_GROUP_CAT_PUB;
           x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR ;
           IF FND_MSG_PUB.Check_Msg_Level
                          (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
           THEN
           FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
           END IF ;
           FND_MSG_PUB.Count_And_Get(p_count =>x_msg_count,
                                     p_data => x_msg_data) ;

End Create_csc_prof_group_cat;

PROCEDURE Update_csc_prof_group_cat(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    p_GROUP_CATEGORY_ID          IN   NUMBER,
    p_GROUP_ID                        NUMBER,
    p_CATEGORY_CODE                   VARCHAR2,
    p_CATEGORY_SEQUENCE               NUMBER,
    p_CREATED_BY                      NUMBER,
    p_CREATION_DATE                   DATE,
    p_LAST_UPDATED_BY                 NUMBER,
    p_LAST_UPDATE_DATE                DATE,
    p_LAST_UPDATE_LOGIN               NUMBER,
    p_SEEDED_FLAG                     VARCHAR2,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
l_PROF_GRP_CAT_Rec  PROF_GRP_CAT_Rec_Type;

BEGIN

 Convert_Columns_to_Rec (
    p_GROUP_CATEGORY_ID    => p_GROUP_CATEGORY_ID,
    p_GROUP_ID             => p_GROUP_ID ,
    p_CATEGORY_CODE        => p_CATEGORY_CODE,
    p_CATEGORY_SEQUENCE    => p_CATEGORY_SEQUENCE,
    p_CREATED_BY           => p_CREATED_BY,
    p_CREATION_DATE        => p_CREATION_DATE,
    p_LAST_UPDATED_BY      => p_LAST_UPDATED_BY,
    p_LAST_UPDATE_DATE     => p_LAST_UPDATE_DATE,
    p_LAST_UPDATE_LOGIN    => p_LAST_UPDATE_LOGIN,
    p_SEEDED_FLAG          => p_SEEDED_FLAG,
    x_PROF_GRP_CAT_rec    => l_PROF_GRP_CAT_Rec
    );


Update_csc_prof_group_cat(
    P_Api_Version_Number   => P_Api_Version_Number,
    P_Init_Msg_List        => P_Init_Msg_List,
    P_Commit               => P_Commit ,
    P_PROF_GRP_CAT_Rec     => l_PROF_GRP_CAT_Rec,
    X_Return_Status        => X_Return_Status,
    X_Msg_Count            => X_Msg_Count,
    X_Msg_Data             => X_Msg_Data
    );

END Update_csc_prof_group_cat;


-- Hint: Add corresponding update detail table procedures if it's master-detail relationship.
PROCEDURE Update_csc_prof_group_cat(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    P_PROF_GRP_CAT_Rec     IN    PROF_GRP_CAT_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Update_csc_prof_group_cat';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_pvt_PROF_GRP_CAT_rec  CSC_PROF_GROUP_CAT_PVT.PROF_GRP_CAT_Rec_Type;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_CSC_PROF_GROUP_CAT_PUB;

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
		P_PROF_GRP_CAT_Rec      =>  p_PROF_GRP_CAT_rec,
		x_pvt_PROF_GRP_CAT_rec => l_pvt_PROF_GRP_CAT_rec
      );

    csc_prof_group_cat_PVT.Update_csc_prof_group_cat(
    P_Api_Version_Number         => 1.0,
    P_Init_Msg_List              => FND_API.G_FALSE,
    P_Commit                     => p_commit,
    P_Validation_Level           => FND_API.G_VALID_LEVEL_FULL,
    P_PROF_GRP_CAT_Rec  =>  l_pvt_PROF_GRP_CAT_Rec ,
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
      	 ROLLBACK TO UPDATE_CSC_PROF_GROUP_CAT_PUB;
           x_return_status :=  FND_API.G_RET_STS_ERROR ;
           FND_MSG_PUB.Count_And_Get(p_count =>x_msg_count,
                                     p_data => x_msg_data) ;


          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      	 ROLLBACK TO UPDATE_CSC_PROF_GROUP_CAT_PUB;
           x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR ;
           FND_MSG_PUB.Count_And_Get(p_count =>x_msg_count,
                                     p_data => x_msg_data) ;

          WHEN OTHERS THEN
      	 ROLLBACK TO UPDATE_CSC_PROF_GROUP_CAT_PUB;
           x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR ;
           IF FND_MSG_PUB.Check_Msg_Level
                          (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
           THEN
           FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
           END IF ;
           FND_MSG_PUB.Count_And_Get(p_count =>x_msg_count,
                                     p_data => x_msg_data) ;

End Update_csc_prof_group_cat;


-- Hint: Add corresponding delete detail table procedures if it's master-detail relationship.
--       The Master delete procedure may not be needed depends on different business requirements.
PROCEDURE Delete_csc_prof_group_cat(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    P_PROF_GRP_CAT_Rec     IN PROF_GRP_CAT_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Delete_csc_prof_group_cat';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_pvt_PROF_GRP_CAT_rec  CSC_PROF_GROUP_CAT_PVT.PROF_GRP_CAT_Rec_Type;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_CSC_PROF_GROUP_CAT_PUB;

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
		P_PROF_GRP_CAT_Rec      =>  p_PROF_GRP_CAT_rec,
		x_pvt_PROF_GRP_CAT_rec => l_pvt_PROF_GRP_CAT_rec
      );

    csc_prof_group_cat_PVT.Delete_csc_prof_group_cat(
    P_Api_Version_Number         => 1.0,
    P_Init_Msg_List              => FND_API.G_FALSE,
    P_Commit                     => p_commit,
    P_Validation_Level           => FND_API.G_VALID_LEVEL_FULL,
    P_PROF_GRP_CAT_Rec  => l_pvt_PROF_GRP_CAT_Rec,
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
           ROLLBACK TO DELETE_CSC_PROF_GROUP_CAT_PUB;
           x_return_status :=  FND_API.G_RET_STS_ERROR ;
           FND_MSG_PUB.Count_And_Get(p_count =>x_msg_count,
                                     p_data => x_msg_data) ;

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
           ROLLBACK TO DELETE_CSC_PROF_GROUP_CAT_PUB;
           x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR ;
           FND_MSG_PUB.Count_And_Get(p_count =>x_msg_count,
                                     p_data => x_msg_data) ;

          WHEN OTHERS THEN
           ROLLBACK TO DELETE_CSC_PROF_GROUP_CAT_PUB;
           x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR ;
           IF FND_MSG_PUB.Check_Msg_Level
                          (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
           THEN
           FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
           END IF ;
           FND_MSG_PUB.Count_And_Get(p_count =>x_msg_count,
                                     p_data => x_msg_data) ;

End Delete_csc_prof_group_cat;

End CSC_PROF_GROUP_CAT_PUB;

/
