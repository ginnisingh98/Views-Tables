--------------------------------------------------------
--  DDL for Package Body CSC_CHECK_RATINGS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSC_CHECK_RATINGS_PVT" as
/* $Header: cscvprab.pls 120.1 2006/05/31 11:46:09 adhanara noship $ */
-- Start of Comments
-- Package name     : CSC_CHECK_RATINGS_PVT
-- Purpose          :
-- History          :
-- 18 Nov 02   jamose made changes for the NOCOPY and FND_API.G_MISS*
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSC_CHECK_RATINGS_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'cscvurab.pls';


PROCEDURE Convert_Columns_to_Rec(
    p_CHECK_RATING_ID            IN   NUMBER DEFAULT NULL,
    p_CHECK_ID                   IN   NUMBER,
    p_CHECK_RATING_GRADE         IN   VARCHAR2,
    p_RATING_COLOR_ID            IN   NUMBER,
    p_RATING_CODE                IN   VARCHAR2,
    p_COLOR_CODE                 IN   VARCHAR2,
    p_RANGE_LOW_VALUE            IN   VARCHAR2,
    p_RANGE_HIGH_VALUE           IN   VARCHAR2,
    p_LAST_UPDATE_DATE           IN   DATE,
    p_LAST_UPDATED_BY            IN   NUMBER,
    p_CREATION_DATE              IN   DATE,
    p_CREATED_BY                 IN   NUMBER,
    p_LAST_UPDATE_LOGIN          IN   NUMBER,
    p_SEEDED_FLAG                IN   VARCHAR2,
    X_Chk_rating_rec		   OUT NOCOPY CHK_RATING_Rec_Type
  )
IS
BEGIN

    X_Chk_rating_rec.CHECK_ID		:= P_CHECK_ID;
    X_Chk_rating_rec.CHECK_RATING_ID  := P_CHECK_RATING_ID;
    X_Chk_rating_rec.CHECK_ID        := P_CHECK_ID;
    X_Chk_rating_rec.CHECK_RATING_GRADE  := P_CHECK_RATING_GRADE;
    X_Chk_rating_rec.RATING_COLOR_ID   := P_RATING_COLOR_ID;
    X_Chk_rating_rec.RATING_CODE     := P_RATING_CODE;
    X_Chk_rating_rec.COLOR_CODE      := P_COLOR_CODE;
    X_Chk_rating_rec.RANGE_LOW_VALUE  := P_RANGE_LOW_VALUE;
    X_Chk_rating_rec.RANGE_HIGH_VALUE  := P_RANGE_HIGH_VALUE;
    X_Chk_rating_rec.CREATED_BY := P_CREATED_BY;
    X_Chk_rating_rec.CREATION_DATE :=  P_CREATION_DATE;
    X_Chk_rating_rec.LAST_UPDATED_BY := P_LAST_UPDATED_BY;
    X_Chk_rating_rec.LAST_UPDATE_DATE := P_LAST_UPDATE_DATE;
    X_Chk_rating_rec.LAST_UPDATE_LOGIN := P_LAST_UPDATE_LOGIN;
    X_Chk_rating_rec.SEEDED_FLAG := P_SEEDED_FLAG;

END Convert_Columns_to_Rec;



PROCEDURE Create_check_ratings(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit                     IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level           IN   NUMBER       := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    px_CHECK_RATING_ID            IN OUT NOCOPY NUMBER,
    p_CHECK_ID                   IN   NUMBER ,
    p_CHECK_RATING_GRADE        IN   VARCHAR2,
    p_RATING_COLOR_ID            IN   NUMBER DEFAULT NULL,
    p_RATING_CODE                IN   VARCHAR2,
    p_COLOR_CODE                 IN   VARCHAR2,
    p_RANGE_LOW_VALUE            IN   VARCHAR2,
    p_RANGE_HIGH_VALUE           IN   VARCHAR2,
    p_LAST_UPDATE_DATE           IN   DATE ,
    p_LAST_UPDATED_BY            IN   NUMBER,
    p_CREATION_DATE              IN   DATE ,
    p_CREATED_BY                 IN   NUMBER,
    p_LAST_UPDATE_LOGIN          IN   NUMBER,
    p_SEEDED_FLAG                IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    )
 IS
 l_chk_rating_rec CHK_RATING_Rec_Type  := G_MISS_CHK_RATING_Rec;
 BEGIN

  Convert_Columns_to_Rec(
    --p_CHECK_RATING_ID    => p_CHECK_RATING_ID,
    p_CHECK_ID           => p_CHECK_ID,
    p_CHECK_RATING_GRADE => p_CHECK_RATING_GRADE,
    p_RATING_COLOR_ID   => p_RATING_COLOR_ID,
    p_RATING_CODE       => p_RATING_CODE,
    p_COLOR_CODE        => p_COLOR_CODE,
    p_RANGE_LOW_VALUE   => p_RANGE_LOW_VALUE,
    p_RANGE_HIGH_VALUE  => p_RANGE_HIGH_VALUE,
    P_CREATED_BY   	=>   P_CREATED_BY,
    P_CREATION_DATE  	=>   P_CREATION_DATE,
    P_LAST_UPDATED_BY 	=>    P_LAST_UPDATED_BY,
    P_LAST_UPDATE_DATE 	=>    P_LAST_UPDATE_DATE,
    P_LAST_UPDATE_LOGIN 	=>    P_LAST_UPDATE_LOGIN,
    P_SEEDED_FLAG       =>  P_SEEDED_FLAG,
    X_CHk_Rating_Rec	=> l_chk_rating_rec
    );

      Create_check_ratings(
      P_Api_Version_Number         => 1.0,
      P_Init_Msg_List              => CSC_CORE_UTILS_PVT.G_FALSE,
      P_Commit                     => CSC_CORE_UTILS_PVT.G_FALSE,
      P_Validation_Level           => CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
      px_Check_Rating_id		=>  	px_check_rating_id,
      P_CHK_RATING_Rec     	=>    l_CHK_RATING_Rec ,
      X_Return_Status              => x_return_status,
      X_Msg_Count                  => x_msg_count,
      X_Msg_Data                   => x_msg_data
      );


END Create_check_ratings;

PROCEDURE Create_check_ratings(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit                     IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level           IN   NUMBER       := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    px_Check_Rating_ID		 IN OUT NOCOPY  NUMBER,
    P_CHK_RATING_Rec     	IN    CHK_RATING_Rec_Type  := G_MISS_CHK_RATING_Rec,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    )
 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Create_check_ratings';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_return_status_full        VARCHAR2(1);
l_chk_rating_rec		CHK_RATING_Rec_Type;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_CHECK_RATINGS_PVT;

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
          Validate_check_ratings(
              p_init_msg_list    => CSC_CORE_UTILS_PVT.G_FALSE,
              p_validation_level => p_validation_level,
              p_validation_mode  => CSC_CORE_UTILS_PVT.G_CREATE,
    	        p_CHK_RATING_rec   => p_chk_rating_Rec,
              x_return_status    => x_return_status,
              x_msg_count        => x_msg_count,
              x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Invoke table handler(CSC_PROF_CHECK_RATINGS_PKG.Insert_Row)
      CSC_PROF_CHECK_RATINGS_PKG.Insert_Row(
          px_CHECK_RATING_ID  => px_CHECK_RATING_ID,
          p_CHECK_ID  => P_CHK_RATING_rec.CHECK_ID,
          p_CHECK_RATING_GRADE  => P_CHK_RATING_rec.CHECK_RATING_GRADE,
          --p_RATING_COLOR_ID  => P_CHK_RATING_rec.RATING_COLOR_ID,
          p_RATING_CODE  => P_CHK_RATING_rec.RATING_CODE,
          p_COLOR_CODE  => P_CHK_RATING_rec.COLOR_CODE,
          p_RANGE_LOW_VALUE  => P_CHK_RATING_rec.RANGE_LOW_VALUE,
          p_RANGE_HIGH_VALUE  => P_CHK_RATING_rec.RANGE_HIGH_VALUE,
          p_LAST_UPDATE_DATE  => SYSDATE,
          p_LAST_UPDATED_BY  => P_CHK_RATING_rec.LAST_UPDATED_BY,
          p_CREATION_DATE  => SYSDATE,
          p_CREATED_BY  => P_CHK_RATING_rec.CREATED_BY,
          p_LAST_UPDATE_LOGIN  => P_CHK_RATING_rec.LAST_UPDATE_LOGIN ,
          p_SEEDED_FLAG  =>  P_CHK_RATING_rec.SEEDED_FLAG);


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
    		ROLLBACK TO Create_check_ratings_PVT;
    		x_return_status := FND_API.G_RET_STS_ERROR;
    		FND_MSG_PUB.Count_And_Get
      			( p_count => x_msg_count,
        		  	  p_data  => x_msg_data
      			);
          APP_EXCEPTION.RAISE_EXCEPTION;
  	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    		ROLLBACK TO Create_check_ratings_PVT;
    		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    		FND_MSG_PUB.Count_And_Get
      			( p_count => x_msg_count,
        		  	  p_data  => x_msg_data
      			);
          APP_EXCEPTION.RAISE_EXCEPTION;
  	WHEN OTHERS THEN
    		ROLLBACK TO Create_check_ratings_PVT;
    		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      	FND_MSG_PUB.Build_Exc_Msg(G_PKG_NAME, l_api_name);
    		FND_MSG_PUB.Count_And_Get
      			( p_count => x_msg_count,
        		  	  p_data  => x_msg_data
      			);
          APP_EXCEPTION.RAISE_EXCEPTION;
End Create_check_ratings;


PROCEDURE Update_check_ratings(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2 := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit                     IN   VARCHAR2 := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level           IN   NUMBER   := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    p_CHECK_RATING_ID            IN   NUMBER,
    p_CHECK_ID                   IN   NUMBER,
    p_CHECK_RATING_GRADE         IN   VARCHAR2,
    p_RATING_COLOR_ID            IN   NUMBER DEFAULT NULL,
    p_RATING_CODE                IN   VARCHAR2,
    p_COLOR_CODE                 IN   VARCHAR2,
    p_RANGE_LOW_VALUE            IN   VARCHAR2,
    p_RANGE_HIGH_VALUE           IN   VARCHAR2,
    p_LAST_UPDATE_DATE           IN   DATE ,
    p_LAST_UPDATED_BY            IN   NUMBER,
    p_CREATION_DATE              IN   DATE,
    p_CREATED_BY                 IN   NUMBER,
    p_LAST_UPDATE_LOGIN          IN   NUMBER,
    p_SEEDED_FLAG                IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    )
 IS
 l_chk_rating_rec CHK_RATING_Rec_Type  := G_MISS_CHK_RATING_Rec;
 BEGIN

  Convert_Columns_to_Rec(
    p_CHECK_RATING_ID    => p_CHECK_RATING_ID,
    p_CHECK_ID           => p_CHECK_ID,
    p_CHECK_RATING_GRADE => p_CHECK_RATING_GRADE,
    p_RATING_COLOR_ID   => p_RATING_COLOR_ID,
    p_RATING_CODE       => p_RATING_CODE,
    p_COLOR_CODE        => p_COLOR_CODE,
    p_RANGE_LOW_VALUE   => p_RANGE_LOW_VALUE,
    p_RANGE_HIGH_VALUE  => p_RANGE_HIGH_VALUE,
    P_CREATED_BY   	=>   P_CREATED_BY,
    P_CREATION_DATE  	=>   P_CREATION_DATE,
    P_LAST_UPDATED_BY 	=>    P_LAST_UPDATED_BY,
    P_LAST_UPDATE_DATE 	=>    P_LAST_UPDATE_DATE,
    P_LAST_UPDATE_LOGIN 	=>    P_LAST_UPDATE_LOGIN,
    P_SEEDED_FLAG       => P_SEEDED_FLAG,
    X_CHk_Rating_Rec	=> l_chk_rating_rec
    );

      Update_check_ratings(
      P_Api_Version_Number         => 1.0,
      P_Init_Msg_List              => CSC_CORE_UTILS_PVT.G_FALSE,
      P_Commit                     => CSC_CORE_UTILS_PVT.G_FALSE,
      P_Validation_Level           => CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
      P_CHK_RATING_Rec     	=>    l_CHK_RATING_Rec ,
      X_Return_Status              => x_return_status,
      X_Msg_Count                  => x_msg_count,
      X_Msg_Data                   => x_msg_data
      );

END Update_check_ratings;

PROCEDURE Update_check_ratings(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit                     IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level           IN  NUMBER       := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    P_CHK_RATING_Rec    	   IN    CHK_RATING_Rec_Type  := G_MISS_CHK_RATING_Rec,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    )

 IS

Cursor C_Get_check_ratings(c_CHECK_RATING_ID Number) IS
    Select rowid,
           CHECK_RATING_ID,
           CHECK_ID,
           CHECK_RATING_GRADE,
           RATING_CODE,
           COLOR_CODE,
           RANGE_LOW_VALUE,
           RANGE_HIGH_VALUE,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_LOGIN,
           SEEDED_FLAG
    From  CSC_PROF_CHECK_RATINGS
    Where check_id = c_CHECK_RATING_ID
    For Update NOWAIT;
l_api_name                CONSTANT VARCHAR2(30) := 'Update_check_ratings';
l_api_version_number      CONSTANT NUMBER   := 1.0;
-- Local Variables
l_rowid  ROWID;
l_chk_rating_rec		CHK_RATING_Rec_Type;
l_old_chk_rating_rec		CSC_PROF_CHECK_RATINGS%ROWTYPE;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_CHECK_RATINGS_PVT;

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

      Open C_Get_check_ratings( p_chk_rating_rec.CHECK_ID);
      Fetch C_Get_check_ratings into
               l_rowid,
               l_old_CHK_RATING_rec.CHECK_RATING_ID,
               l_old_CHK_RATING_rec.CHECK_ID,
               l_old_CHK_RATING_rec.CHECK_RATING_GRADE,
               l_old_CHK_RATING_rec.RATING_CODE,
               l_old_CHK_RATING_rec.COLOR_CODE,
               l_old_CHK_RATING_rec.RANGE_LOW_VALUE,
               l_old_CHK_RATING_rec.RANGE_HIGH_VALUE,
               l_old_CHK_RATING_rec.LAST_UPDATE_DATE,
               l_old_CHK_RATING_rec.LAST_UPDATED_BY,
               l_old_CHK_RATING_rec.CREATION_DATE,
               l_old_CHK_RATING_rec.CREATED_BY,
               l_old_CHK_RATING_rec.LAST_UPDATE_LOGIN,
               l_old_CHK_RATING_rec.SEEDED_FLAG;
       If ( C_Get_check_ratings%NOTFOUND) Then
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
             CSC_CORE_UTILS_PVT.Record_Is_Locked_msg(p_Api_Name=> l_api_name);
           END IF;
           raise FND_API.G_EXC_ERROR;
       END IF;

      IF ( P_validation_level >= CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL)
      THEN

          -- Invoke validation procedures
          Validate_check_ratings(
              p_init_msg_list    => CSC_CORE_UTILS_PVT.G_FALSE,
              p_validation_level => p_validation_level,
              p_validation_mode  => CSC_CORE_UTILS_PVT.G_UPDATE,
    	      P_CHK_RATING_Rec   => P_CHK_RATING_REC ,
              x_return_status    => x_return_status,
              x_msg_count        => x_msg_count,
              x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Invoke table handler(CSC_PROF_CHECK_RATINGS_PKG.Update_Row)
      CSC_PROF_CHECK_RATINGS_PKG.Update_Row(
          p_CHECK_RATING_ID  => csc_core_utils_pvt.get_g_miss_char(P_CHK_RATING_rec.CHECK_RATING_ID,l_old_CHK_RATING_rec.CHECK_RATING_ID),
          p_CHECK_ID  => csc_core_utils_pvt.get_g_miss_char(p_CHK_RATING_REC.CHECK_ID,l_old_CHK_RATING_rec.CHECK_ID),
          p_CHECK_RATING_GRADE  => csc_core_utils_pvt.get_g_miss_char(P_CHK_RATING_rec.CHECK_RATING_GRADE,l_old_CHK_RATING_rec.CHECK_RATING_GRADE),
          p_RATING_CODE  => csc_core_utils_pvt.get_g_miss_char(P_CHK_RATING_rec.RATING_CODE,l_old_CHK_RATING_rec.RATING_CODE),
          p_COLOR_CODE  => csc_core_utils_pvt.get_g_miss_char(P_CHK_RATING_rec.COLOR_CODE,l_old_CHK_RATING_rec.COLOR_CODE),
          p_RANGE_LOW_VALUE  => csc_core_utils_pvt.get_g_miss_char(P_CHK_RATING_rec.RANGE_LOW_VALUE,l_old_CHK_RATING_rec.RANGE_LOW_VALUE),
          p_RANGE_HIGH_VALUE  => csc_core_utils_pvt.get_g_miss_char(P_CHK_RATING_rec.RANGE_HIGH_VALUE,l_old_CHK_RATING_rec.RANGE_HIGH_VALUE),
          p_LAST_UPDATE_DATE  => SYSDATE,
          p_LAST_UPDATED_BY  => csc_core_utils_pvt.get_g_miss_num(P_CHK_RATING_rec.LAST_UPDATED_BY,l_old_CHK_RATING_rec.LAST_UPDATED_BY),
          p_LAST_UPDATE_LOGIN  => csc_core_utils_pvt.get_g_miss_num(P_CHK_RATING_rec.LAST_UPDATE_LOGIN,l_old_CHK_RATING_rec.LAST_UPDATE_LOGIN),
          p_SEEDED_FLAG => csc_core_utils_pvt.get_g_miss_char(P_CHK_RATING_rec.SEEDED_FLAG,l_old_CHK_RATING_rec.SEEDED_FLAG) );


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
    		ROLLBACK TO Update_check_ratings_PVT;
    		x_return_status := FND_API.G_RET_STS_ERROR;
    		FND_MSG_PUB.Count_And_Get
      			( p_count => x_msg_count,
        		  	  p_data  => x_msg_data
      			);
          APP_EXCEPTION.RAISE_EXCEPTION;
  	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    		ROLLBACK TO Update_check_ratings_PVT;
    		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    		FND_MSG_PUB.Count_And_Get
      			( p_count => x_msg_count,
        		  	  p_data  => x_msg_data
      			);
          APP_EXCEPTION.RAISE_EXCEPTION;
  	WHEN OTHERS THEN
    		ROLLBACK TO Update_check_ratings_PVT;
    		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      	FND_MSG_PUB.Build_Exc_Msg(G_PKG_NAME, l_api_name);
    		FND_MSG_PUB.Count_And_Get
      			( p_count => x_msg_count,
        		  	  p_data  => x_msg_data
      			);
          APP_EXCEPTION.RAISE_EXCEPTION;
End Update_check_ratings;


PROCEDURE Delete_check_ratings(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit                     IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level           IN   NUMBER       := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    P_CHECK_RATING_ID     IN NUMBER,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Delete_check_ratings';
l_api_version_number      CONSTANT NUMBER   := 1.0;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_CHECK_RATINGS_PVT;

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

      -- Invoke table handler(CSC_PROF_CHECK_RATINGS_PKG.Delete_Row)
      CSC_PROF_CHECK_RATINGS_PKG.Delete_Row(
          p_CHECK_RATING_ID  => p_CHECK_RATING_ID);
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
    		ROLLBACK TO Delete_check_ratings_PVT;
    		x_return_status := FND_API.G_RET_STS_ERROR;
    		FND_MSG_PUB.Count_And_Get
      			( p_count => x_msg_count,
        		  	  p_data  => x_msg_data
      			);
          APP_EXCEPTION.RAISE_EXCEPTION;
  	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    		ROLLBACK TO Delete_check_ratings_PVT;
    		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    		FND_MSG_PUB.Count_And_Get
      			( p_count => x_msg_count,
        		  	  p_data  => x_msg_data
      			);
          APP_EXCEPTION.RAISE_EXCEPTION;
  	WHEN OTHERS THEN
    		ROLLBACK TO Delete_check_ratings_PVT;
    		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      	FND_MSG_PUB.Build_Exc_Msg(G_PKG_NAME, l_api_name);
    		FND_MSG_PUB.Count_And_Get
      			( p_count => x_msg_count,
        		  	  p_data  => x_msg_data
      			);
          APP_EXCEPTION.RAISE_EXCEPTION;
End Delete_check_ratings;

-- Item-level validation procedures
PROCEDURE Validate_CHECK_ID (
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_CHECK_ID                IN   NUMBER,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    )
IS
 Cursor C1 is
  Select check_id
  From csc_prof_checks_b
  Where check_id = p_Check_Id;
l_dummy number;
 p_Api_Name VARCHAR2(100) := 'Validate_Check_Id';
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
         -- IF p_CHECK_ID is not NULL and p_CHECK_ID <> G_MISS_NUM
         -- verify if data is valid
         -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
	    IF p_CHECK_ID is not NULL and p_CHECK_ID <> CSC_CORE_UTILS_PVT.G_MISS_NUM
	    THEN
		Open C1;
		Fetch C1 into l_dummy;
		 IF C1%NOTFOUND THEN
              x_return_status := FND_API.G_RET_STS_ERROR;
              CSC_CORE_UTILS_PVT.Add_Invalid_Argument_Msg(
						p_api_name=> p_api_name,
                              p_argument_value => p_check_id,
						p_argument=>'P_CHECK_ID' );
		 END IF;
		Close C1;
         ELSE
		    x_return_status := FND_API.G_RET_STS_ERROR;
		    CSC_CORE_UTILS_PVT.mandatory_arg_error(
			               p_api_name => p_api_name,
			               p_argument => 'P_CHECK_ID',
			               p_argument_Value => p_check_id );
	    END IF;
      ELSIF(p_validation_mode = CSC_CORE_UTILS_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_CHECK_ID <> FND_API.G_MISS_NUM
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
	    IF p_CHECK_ID <> CSC_CORE_UTILS_PVT.G_MISS_NUM
	    THEN
		Open C1;
		Fetch C1 into l_dummy;
		 IF C1%NOTFOUND THEN
                x_return_status := FND_API.G_RET_STS_ERROR;
                CSC_CORE_UTILS_PVT.Add_Invalid_Argument_Msg(
						p_api_name=> p_api_name,
                              p_argument_value => p_check_id,
						p_argument=>'P_CHECK_ID' );
		 END IF;
		Close C1;
         ELSIF p_CHECK_ID IS NULL
	    THEN
		    x_return_status := FND_API.G_RET_STS_ERROR;
		    CSC_CORE_UTILS_PVT.mandatory_arg_error(
			               p_api_name => p_api_name,
			               p_argument => 'P_CHECK_ID',
			               p_argument_Value => p_check_id );
	    END IF;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_CHECK_ID;


PROCEDURE Validate_CHECK_RATING_GRADE (
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_CHECK_RATING_GRADE                IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    )
IS
 p_Api_Name VARCHAR2(100) := 'VALIDATE_CHECK_RATINGS_GRADE';
BEGIN
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;
      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      -- validate NOT NULL column
      IF(p_CHECK_RATING_GRADE is NULL)
      THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
      IF(p_validation_mode = CSC_CORE_UTILS_PVT.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_CHECK_RATING_GRADE is not NULL and p_CHECK_RATING_GRADE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = CSC_CORE_UTILS_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_CHECK_RATING_GRADE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
END Validate_CHECK_RATING_GRADE;



PROCEDURE Validate_RATING_CODE (
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_RATING_CODE                IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    )
IS
 p_Api_Name VARCHAR2(100) := 'VALIDATE_RATING_CODE';
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- validate NOT NULL column
      IF(p_RATING_CODE is NULL)
      THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
		CSC_CORE_UTILS_PVT.mandatory_arg_error(
			   p_api_name => p_api_name,
			   p_argument => 'P_RATING_CODE',
			   p_argument_Value => p_rating_code );
      END IF;

      IF(p_validation_mode = CSC_CORE_UTILS_PVT.G_CREATE)
      THEN
        -- validate NOT NULL column
        IF (p_RATING_CODE is NOT NULL) AND (p_RATING_CODE <> CSC_CORE_UTILS_PVT.G_MISS_CHAR)
        THEN
           IF CSC_CORE_UTILS_PVT.csc_lookup_code_not_exists(
               p_effective_date => trunc(sysdate),
               p_lookup_type    => 'CSC_PROF_RATINGS',
               p_lookup_Code    => p_rating_code ) <> FND_API.G_RET_STS_SUCCESS
           THEN

               x_return_status := FND_API.G_RET_STS_ERROR;
               CSC_CORE_UTILS_PVT.Add_Invalid_Argument_Msg(
						p_api_name=> p_api_name,
                                    p_argument_value => p_rating_code,
						p_argument=>'P_RATING_CODE' );
	     END IF;
        ELSE
              x_return_status := FND_API.G_RET_STS_ERROR;
		  CSC_CORE_UTILS_PVT.mandatory_arg_error(
			   p_api_name => p_api_name,
			   p_argument => 'P_RATING_CODE',
			   p_argument_Value => p_rating_code );
        END IF;
      ELSIF(p_validation_mode = CSC_CORE_UTILS_PVT.G_UPDATE)
      THEN

        IF (p_RATING_CODE is NOT NULL) AND (p_RATING_CODE <> CSC_CORE_UTILS_PVT.G_MISS_CHAR)
        THEN
           IF CSC_CORE_UTILS_PVT.csc_lookup_code_not_exists(
               p_effective_date => trunc(sysdate),
               p_lookup_type    => 'CSC_PROF_RATINGS',
               p_lookup_Code    => p_rating_code ) <> FND_API.G_RET_STS_SUCCESS
           THEN

               x_return_status := FND_API.G_RET_STS_ERROR;
               CSC_CORE_UTILS_PVT.Add_Invalid_Argument_Msg(
						p_api_name=> p_api_name,
                                    p_argument_value => p_rating_code,
						p_argument=>'P_RATING_CODE' );
	     END IF;
        END IF;
      END IF;

       -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
END Validate_RATING_CODE;

PROCEDURE Validate_check_ratings(
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Validation_level           IN   NUMBER := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    P_Validation_mode            IN   VARCHAR2,
    p_CHK_RATING_Rec   IN CHK_RATING_Rec_Type,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    )

IS
l_api_name   CONSTANT VARCHAR2(30) := 'Validate_check_ratings';

 BEGIN

       -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
/*
          Validate_CHECK_RATING_ID(
              p_init_msg_list          => CSC_CORE_UTILS_PVT.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_CHECK_RATING_ID   => l_CHECK_RATING_ID,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;
*/
          Validate_CHECK_ID(
              p_init_msg_list          => CSC_CORE_UTILS_PVT.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_CHECK_ID   => P_CHK_RATING_REC.CHECK_ID,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

/*
          Validate_CHECK_RATING_GRADE(
              p_init_msg_list          => CSC_CORE_UTILS_PVT.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_CHECK_RATING_GRADE   => p_CHK_RATING_REC.CHECK_RATING_GRADE,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;
*/



          Validate_RATING_CODE(
              p_init_msg_list          => CSC_CORE_UTILS_PVT.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_RATING_CODE   	       => p_CHK_RATING_REC.RATING_CODE,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

        CSC_CORE_UTILS_PVT.Validate_Seeded_Flag(
         p_api_name        =>'CSC_CHECK_RATINGS_PVT.VALIDATE_SEEDED_FLAG',
         p_seeded_flag     => p_CHK_RATING_rec.seeded_flag,
         x_return_status   => x_return_status );

        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
         RAISE FND_API.G_EXC_ERROR;
        END IF;



END Validate_check_ratings;

End CSC_CHECK_RATINGS_PVT;

/
