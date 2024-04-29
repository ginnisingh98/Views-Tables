--------------------------------------------------------
--  DDL for Package Body CSC_PROF_GROUP_CAT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSC_PROF_GROUP_CAT_PVT" as
/* $Header: cscvpcab.pls 115.9 2002/12/03 19:27:39 jamose ship $ */
-- Start of Comments
-- Package name     : CSC_PROF_GROUP_CAT_PVT
-- Purpose          :
-- History          :
-- 27 Nov 02   jamose For Fnd_Api_G_Miss* and NOCOPY changes
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSC_PROF_GROUP_CAT_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'cscvpgcb.pls';

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
    x_PROF_GRP_CAT_rec    OUT NOCOPY   PROF_GRP_CAT_Rec_Type
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
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit                     IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level           IN   NUMBER       := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    px_GROUP_CATEGORY_ID         IN   OUT NOCOPY     NUMBER,
    p_GROUP_ID                   IN   NUMBER,
    p_CATEGORY_CODE              IN   VARCHAR2,
    p_CATEGORY_SEQUENCE          IN   NUMBER,
    p_CREATED_BY                 IN   NUMBER,
    p_CREATION_DATE              IN   DATE,
    p_LAST_UPDATED_BY            IN   NUMBER,
    p_LAST_UPDATE_DATE           IN   DATE,
    p_LAST_UPDATE_LOGIN          IN   NUMBER,
    p_SEEDED_FLAG                IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
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
    p_validation_level     => p_validation_level,
    PX_GROUP_CATEGORY_ID   => PX_GROUP_CATEGORY_ID,
    P_PROF_GRP_CAT_Rec     => l_PROF_GRP_CAT_Rec,
    X_Return_Status        => X_Return_Status,
    X_Msg_Count            => X_Msg_Count,
    X_Msg_Data             => X_Msg_Data
    );

END Create_csc_prof_group_cat;

PROCEDURE Create_csc_prof_group_cat(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit                     IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level           IN   NUMBER       := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    PX_GROUP_CATEGORY_ID     IN OUT NOCOPY NUMBER,
    P_PROF_GRP_CAT_Rec     IN    PROF_GRP_CAT_Rec_Type  := G_MISS_PROF_GRP_CAT_REC,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Create_csc_prof_group_cat';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_return_status_full        VARCHAR2(1);
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_CSC_PROF_GROUP_CAT_PVT;

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
          Validate_csc_prof_group_cat(
              p_init_msg_list    => CSC_CORE_UTILS_PVT.G_FALSE,
              p_validation_level => p_validation_level,
              p_validation_mode  => CSC_CORE_UTILS_PVT.G_CREATE,
              P_PROF_GRP_CAT_Rec  =>  P_PROF_GRP_CAT_Rec,
              x_return_status    => x_return_status,
              x_msg_count        => x_msg_count,
              x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Invoke table handler(CSC_PROF_GROUP_CATEGORIES_PKG.Insert_Row)
      CSC_PROF_GROUP_CATEGORIES_PKG.Insert_Row(
          px_GROUP_CATEGORY_ID  => px_GROUP_CATEGORY_ID,
          p_GROUP_ID  => p_PROF_GRP_CAT_rec.GROUP_ID,
          p_CATEGORY_CODE  => p_PROF_GRP_CAT_rec.CATEGORY_CODE,
          p_CATEGORY_SEQUENCE  => p_PROF_GRP_CAT_rec.CATEGORY_SEQUENCE,
          p_CREATED_BY  => FND_GLOBAL.USER_ID,
          p_CREATION_DATE  => SYSDATE,
          p_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID,
          p_LAST_UPDATE_DATE  => SYSDATE,
          p_LAST_UPDATE_LOGIN  => p_PROF_GRP_CAT_rec.LAST_UPDATE_LOGIN,
          p_SEEDED_FLAG   =>  p_PROF_GRP_CAT_rec.SEEDED_FLAG);
      -- Hint: Primary key should be returned.
      -- x_GROUP_CATEGORY_ID := px_GROUP_CATEGORY_ID;

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
      		ROLLBACK TO CREATE_CSC_PROF_GROUP_CAT_PVT;
    			x_return_status := FND_API.G_RET_STS_ERROR;
          	APP_EXCEPTION.RAISE_EXCEPTION;

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      		ROLLBACK TO CREATE_CSC_PROF_GROUP_CAT_PVT;
    			x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          	APP_EXCEPTION.RAISE_EXCEPTION;

          WHEN OTHERS THEN
      		ROLLBACK TO CREATE_CSC_PROF_GROUP_CAT_PVT;
    			x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
			FND_MSG_PUB.Build_Exc_Msg;
          	APP_EXCEPTION.RAISE_EXCEPTION;
End Create_csc_prof_group_cat;

PROCEDURE Update_csc_prof_group_cat(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit                     IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level           IN   NUMBER       := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    p_GROUP_CATEGORY_ID          IN   NUMBER,
    p_GROUP_ID                   IN   NUMBER,
    p_CATEGORY_CODE              IN   VARCHAR2,
    p_CATEGORY_SEQUENCE          IN   NUMBER,
    p_CREATED_BY                 IN   NUMBER DEFAULT NULL,
    p_CREATION_DATE              IN   DATE DEFAULT NULL,
    p_LAST_UPDATED_BY            IN   NUMBER,
    p_LAST_UPDATE_DATE           IN   DATE,
    p_LAST_UPDATE_LOGIN          IN   NUMBER,
    p_SEEDED_FLAG                IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
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
    p_validation_level     => p_validation_level,
    P_PROF_GRP_CAT_Rec     => l_PROF_GRP_CAT_Rec,
    X_Return_Status        => X_Return_Status,
    X_Msg_Count            => X_Msg_Count,
    X_Msg_Data             => X_Msg_Data
    );

END Update_csc_prof_group_cat;


PROCEDURE Update_csc_prof_group_cat(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit                     IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level           IN  NUMBER       := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    P_PROF_GRP_CAT_Rec     IN    PROF_GRP_CAT_Rec_Type,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    )

 IS
Cursor C_Get_csc_prof_group_cat(c_GROUP_CATEGORY_ID Number) IS
    Select rowid,
           GROUP_CATEGORY_ID,
           GROUP_ID,
           CATEGORY_CODE,
           CATEGORY_SEQUENCE,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           SEEDED_FLAG
    From  CSC_PROF_GROUP_CATEGORIES
    Where Group_category_id = c_Group_category_id
    For Update NOWAIT;

l_api_name                CONSTANT VARCHAR2(30) := 'Update_csc_prof_group_cat';
l_api_version_number      CONSTANT NUMBER   := 1.0;
-- Local Variables
l_old_PROF_GRP_CAT_rec  csc_prof_group_cat_PVT.PROF_GRP_CAT_Rec_Type;
l_rowid  ROWID;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_CSC_PROF_GROUP_CAT_PVT;

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


      Open C_Get_csc_prof_group_cat( P_PROF_GRP_CAT_rec.GROUP_CATEGORY_ID);

      Fetch C_Get_csc_prof_group_cat into
               l_rowid,
               l_old_PROF_GRP_CAT_rec.GROUP_CATEGORY_ID,
               l_old_PROF_GRP_CAT_rec.GROUP_ID,
               l_old_PROF_GRP_CAT_rec.CATEGORY_CODE,
               l_old_PROF_GRP_CAT_rec.CATEGORY_SEQUENCE,
               l_old_PROF_GRP_CAT_rec.CREATED_BY,
               l_old_PROF_GRP_CAT_rec.CREATION_DATE,
               l_old_PROF_GRP_CAT_rec.LAST_UPDATED_BY,
               l_old_PROF_GRP_CAT_rec.LAST_UPDATE_DATE,
               l_old_PROF_GRP_CAT_rec.LAST_UPDATE_LOGIN,
               l_old_PROF_GRP_CAT_rec.SEEDED_FLAG;

       If ( C_Get_csc_prof_group_cat%NOTFOUND) Then
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
               CSC_CORE_UTILS_PVT.RECORD_IS_LOCKED_MSG(l_Api_Name);
           END IF;
           raise FND_API.G_EXC_ERROR;
       END IF;


      IF ( P_validation_level >= CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          Validate_csc_prof_group_cat(
              p_init_msg_list    => CSC_CORE_UTILS_PVT.G_FALSE,
              p_validation_level => p_validation_level,
              p_validation_mode  => CSC_CORE_UTILS_PVT.G_UPDATE,
              P_PROF_GRP_CAT_Rec  =>  P_PROF_GRP_CAT_Rec,
              x_return_status    => x_return_status,
              x_msg_count        => x_msg_count,
              x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Invoke table handler(CSC_PROF_GROUP_CATEGORIES_PKG.Update_Row)
      CSC_PROF_GROUP_CATEGORIES_PKG.Update_Row(
          p_GROUP_CATEGORY_ID  =>csc_core_utils_pvt.Get_G_Miss_Num(p_PROF_GRP_CAT_rec.GROUP_CATEGORY_ID,l_old_PROF_GRP_CAT_rec.GROUP_CATEGORY_ID),
          p_GROUP_ID  =>csc_core_utils_pvt.Get_G_Miss_Num(p_PROF_GRP_CAT_rec.GROUP_ID,l_old_PROF_GRP_CAT_rec.GROUP_ID),
          p_CATEGORY_CODE  =>csc_core_utils_pvt.Get_G_Miss_Char(p_PROF_GRP_CAT_rec.CATEGORY_CODE,l_old_PROF_GRP_CAT_rec.CATEGORY_CODE),
          p_CATEGORY_SEQUENCE  =>csc_core_utils_pvt.Get_G_Miss_Num(p_PROF_GRP_CAT_rec.CATEGORY_SEQUENCE,l_old_PROF_GRP_CAT_rec.CATEGORY_SEQUENCE),
          p_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID,
          p_LAST_UPDATE_DATE  => SYSDATE,
          p_LAST_UPDATE_LOGIN  =>csc_core_utils_pvt.Get_G_Miss_Char(p_PROF_GRP_CAT_rec.LAST_UPDATE_LOGIN,l_old_PROF_GRP_CAT_rec.LAST_UPDATE_LOGIN),
          p_SEEDED_FLAG  =>csc_core_utils_pvt.Get_G_Miss_Char(p_PROF_GRP_CAT_rec.SEEDED_FLAG,l_old_PROF_GRP_CAT_rec.SEEDED_FLAG));
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
      		ROLLBACK TO UPDATE_CSC_PROF_GROUP_CAT_PVT;
    	    		x_return_status := FND_API.G_RET_STS_ERROR;
         		APP_EXCEPTION.RAISE_EXCEPTION;

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      		ROLLBACK TO UPDATE_CSC_PROF_GROUP_CAT_PVT;
    	    		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         		APP_EXCEPTION.RAISE_EXCEPTION;

          WHEN OTHERS THEN
      		ROLLBACK TO UPDATE_CSC_PROF_GROUP_CAT_PVT;
    	    		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    	    		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
           	    FND_MSG_PUB.Build_Exc_Msg(G_PKG_NAME, l_api_name);
    	    		END IF;
         		APP_EXCEPTION.RAISE_EXCEPTION;

End Update_csc_prof_group_cat;


PROCEDURE Delete_csc_prof_group_cat(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit                     IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level           IN   NUMBER       := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    P_PROF_GRP_CAT_Rec     IN PROF_GRP_CAT_Rec_Type,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Delete_csc_prof_group_cat';
l_api_version_number      CONSTANT NUMBER   := 1.0;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_CSC_PROF_GROUP_CAT_PVT;

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

      -- Invoke table handler(CSC_PROF_GROUP_CATEGORIES_PKG.Delete_Row)
      CSC_PROF_GROUP_CATEGORIES_PKG.Delete_Row(
          p_GROUP_CATEGORY_ID  => p_PROF_GRP_CAT_rec.GROUP_CATEGORY_ID);
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
      		ROLLBACK TO DELETE_CSC_PROF_GROUP_CAT_PVT;
			x_return_status :=  FND_API.G_RET_STS_ERROR ;
			--FND_MSG_PUB.Count_And_Get(
				--p_count =>x_msg_count,
				   --p_data => x_msg_data
				--);
			APP_EXCEPTION.RAISE_EXCEPTION;

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      		ROLLBACK TO DELETE_CSC_PROF_GROUP_CAT_PVT;
			x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR ;
			--FND_MSG_PUB.Count_And_Get(p_count =>x_msg_count,
								  --p_data => x_msg_data) ;
         		APP_EXCEPTION.RAISE_EXCEPTION;

          WHEN OTHERS THEN
      		ROLLBACK TO DELETE_CSC_PROF_GROUP_CAT_PVT;
			x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR ;
			IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
			THEN
			    FND_MSG_PUB.Build_Exc_Msg(G_PKG_NAME,l_api_name);
			END IF ;
			APP_EXCEPTION.RAISE_EXCEPTION;
End Delete_csc_prof_group_cat;

-- Item-level validation procedures
PROCEDURE Validate_GROUP_CATEGORY_ID (
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_GROUP_CATEGORY_ID                IN   NUMBER,
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

      -- validate NOT NULL column
      IF(p_GROUP_CATEGORY_ID is NULL)
      THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      IF(p_validation_mode = CSC_CORE_UTILS_PVT.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_GROUP_CATEGORY_ID is not NULL and p_GROUP_CATEGORY_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = CSC_CORE_UTILS_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_GROUP_CATEGORY_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_GROUP_CATEGORY_ID;


PROCEDURE Validate_GROUP_ID (
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_GROUP_ID                IN   NUMBER,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    )
IS
 p_Api_Name  VARCHAR2(100) := 'Validate Group Id';
 Cursor C1 is
  Select NULL
   from csc_prof_groups_vl
  where group_id = P_GROUP_ID;
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- validate NOT NULL column
      IF(p_GROUP_ID is NULL)
      THEN
    		x_return_status := FND_API.G_RET_STS_ERROR;
 		CSC_CORE_UTILS_PVT.mandatory_arg_error(
				p_api_name => p_api_name,
				p_argument => 'p_GROUP_ID',
				p_argument_value => p_GROUP_ID);
      END IF;
      IF(p_validation_mode = CSC_CORE_UTILS_PVT.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_GROUP_ID is not NULL and p_GROUP_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          IF p_GROUP_ID = CSC_CORE_UTILS_PVT.G_MISS_NUM
	    THEN
    		x_return_status := FND_API.G_RET_STS_ERROR;
 		CSC_CORE_UTILS_PVT.mandatory_arg_error(
				p_api_name => p_api_name,
				p_argument => 'p_GROUP_ID',
				p_argument_value => p_GROUP_ID);
          ELSIF p_GROUP_ID is not NULL and p_GROUP_ID <> CSC_CORE_UTILS_PVT.G_MISS_NUM
	    THEN
		Open C1;
		Fetch C1 into l_dummy;
		IF C1%NOTFOUND THEN
        		x_return_status := FND_API.G_RET_STS_ERROR;
        		CSC_CORE_UTILS_PVT.Add_Invalid_Argument_Msg(
					p_api_name => p_api_name,
			            p_argument_value  => p_GROUP_ID,
			            p_argument  => 'P_GROUP_ID' );
	      END IF;
		CLOSE C1;
	    END IF;
      ELSIF(p_validation_mode = CSC_CORE_UTILS_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_GROUP_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          IF p_GROUP_ID is not NULL and p_GROUP_ID <> CSC_CORE_UTILS_PVT.G_MISS_NUM
	    THEN
		Open C1;
		Fetch C1 into l_dummy;
		IF C1%NOTFOUND THEN
        		x_return_status := FND_API.G_RET_STS_ERROR;
        		CSC_CORE_UTILS_PVT.Add_Invalid_Argument_Msg(
					p_api_name => p_api_name,
			            p_argument_value  => p_GROUP_ID,
			            p_argument  => 'P_GROUP_ID' );
	      END IF;
		CLOSE C1;
	    END IF;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_GROUP_ID;


PROCEDURE Validate_CATEGORY_CODE (
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_CATEGORY_CODE                IN   VARCHAR2,
    P_GROUP_ID			   IN   NUMBER,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    )
IS
 p_Api_Name Varchar2(100) := 'Validate_Category_Code';
  Cursor C1 is
   Select Null
   from csc_prof_Group_categories
   where group_id = p_GROUP_ID
   and category_code = p_CATEGORY_CODE;
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
          -- IF p_CATEGORY_CODE is not NULL and p_CATEGORY_CODE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
	    IF p_CATEGORY_CODE is not NULL and p_CATEGORY_CODE <> CSC_CORE_UTILS_PVT.G_MISS_CHAR
	    THEN
		Open C1;
		Fetch C1 into l_dummy;
		IF C1%FOUND THEN
        		x_return_status := FND_API.G_RET_STS_ERROR;
	      	CSC_CORE_UTILS_PVT.Add_Duplicate_Value_Msg(
		      		p_api_name	=> p_api_name,
		       		p_argument	=> 'P_CATEGORY_CODE' ,
  		       		p_argument_value => p_CATEGORY_CODE);
		END IF;
		CLOSE C1;
	    END IF;
      ELSIF(p_validation_mode = CSC_CORE_UTILS_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_CATEGORY_CODE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
	    IF p_CATEGORY_CODE is not NULL
	    THEN
		Open C1;
		Fetch C1 into l_dummy;
		IF C1%NOTFOUND THEN
        		x_return_status := FND_API.G_RET_STS_ERROR;
	      	CSC_CORE_UTILS_PVT.Add_Duplicate_Value_Msg(
		      		p_api_name	=> p_api_name,
		       		p_argument	=> 'P_CATEGORY_CODE' ,
  		       		p_argument_value => p_CATEGORY_CODE);
		END IF;
		CLOSE C1;
	    END IF;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_CATEGORY_CODE;


PROCEDURE Validate_CATEGORY_SEQUENCE (
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_CATEGORY_SEQUENCE                IN   NUMBER,
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

      IF(p_validation_mode = CSC_CORE_UTILS_PVT.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_CATEGORY_SEQUENCE is not NULL and p_CATEGORY_SEQUENCE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = CSC_CORE_UTILS_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_CATEGORY_SEQUENCE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_CATEGORY_SEQUENCE;


PROCEDURE Validate_csc_prof_group_cat(
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Validation_level           IN   NUMBER := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    P_Validation_mode            IN   VARCHAR2,
    P_PROF_GRP_CAT_Rec     IN    PROF_GRP_CAT_Rec_Type,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    )
IS
l_api_name   CONSTANT VARCHAR2(30) := 'Validate_csc_prof_group_cat';
 BEGIN



      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_validation_level >= CSC_CORE_UTILS_PVT.G_VALID_LEVEL_NONE) THEN
          -- Hint: We provide validation procedure for every column. Developer should delete
          --       unnecessary validation procedures.
         /*
          Validate_GROUP_CATEGORY_ID(
              p_init_msg_list          => CSC_CORE_UTILS_PVT.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_GROUP_CATEGORY_ID   => P_PROF_GRP_CAT_Rec.GROUP_CATEGORY_ID,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;
        */
          Validate_GROUP_ID(
              p_init_msg_list          => CSC_CORE_UTILS_PVT.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_GROUP_ID   => P_PROF_GRP_CAT_Rec.GROUP_ID,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_CATEGORY_CODE(
              p_init_msg_list          => CSC_CORE_UTILS_PVT.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_CATEGORY_CODE   => P_PROF_GRP_CAT_Rec.CATEGORY_CODE,
    		  P_GROUP_ID	  => P_PROF_GRP_CAT_Rec.GROUP_ID,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_CATEGORY_SEQUENCE(
              p_init_msg_list          => CSC_CORE_UTILS_PVT.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_CATEGORY_SEQUENCE   => P_PROF_GRP_CAT_Rec.CATEGORY_SEQUENCE,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          --Validate seeded flag

        CSC_CORE_UTILS_PVT.Validate_Seeded_Flag(
         p_api_name        =>'CSC_PROF_GROUP_CAT_PVT.VALIDATE_SEEDED_FLAG',
         p_seeded_flag     => p_PROF_GRP_CAT_rec.seeded_flag,
         x_return_status   => x_return_status );

        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
         RAISE FND_API.G_EXC_ERROR;
        END IF;

      END IF;



END Validate_csc_prof_group_cat;

End CSC_PROF_GROUP_CAT_PVT;

/
