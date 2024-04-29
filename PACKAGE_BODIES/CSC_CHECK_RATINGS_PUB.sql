--------------------------------------------------------
--  DDL for Package Body CSC_CHECK_RATINGS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSC_CHECK_RATINGS_PUB" as
/* $Header: cscpprab.pls 115.12 2002/11/29 04:05:49 bhroy ship $ */
-- Start of Comments
-- Package name     : CSC_CHECK_RATINGS_PUB
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSC_CHECK_RATINGS_PUB';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'cscpurab.pls';

PROCEDURE Convert_Pub_to_pvt_Rec(
    P_CHK_RATING_Rec     	IN    CHK_RATING_Rec_Type,
    x_PVT_CHK_RATING_Rec     	OUT NOCOPY    CSC_CHECK_RATINGS_PVT.CHK_RATING_Rec_Type
    )
IS
BEGIN
       x_pvt_CHK_RATING_REC.CHECK_ID             := P_CHK_RATING_Rec.CHECK_ID;
       x_pvt_CHK_RATING_REC.CHECK_RATING_GRADE   := P_CHK_RATING_Rec.CHECK_RATING_GRADE;
       x_pvt_CHK_RATING_REC.RATING_COLOR_ID      := P_CHK_RATING_Rec.RATING_COLOR_ID;
       x_pvt_CHK_RATING_REC.RATING_CODE          := P_CHK_RATING_Rec.RATING_CODE;
       x_pvt_CHK_RATING_REC.COLOR_CODE           := P_CHK_RATING_Rec.COLOR_CODE;
       x_pvt_CHK_RATING_REC.RANGE_LOW_VALUE      := P_CHK_RATING_Rec.RANGE_LOW_VALUE;
       x_pvt_CHK_RATING_REC.RANGE_HIGH_VALUE     := P_CHK_RATING_Rec.RANGE_HIGH_VALUE;
       x_pvt_CHK_RATING_REC.LAST_UPDATE_DATE     := P_CHK_RATING_Rec.LAST_UPDATE_DATE;
       x_pvt_CHK_RATING_REC.LAST_UPDATED_BY      := P_CHK_RATING_Rec.LAST_UPDATED_BY;
       x_pvt_CHK_RATING_REC.CREATION_DATE        := P_CHK_RATING_Rec.CREATION_DATE;
       x_pvt_CHK_RATING_REC.CREATED_BY           := P_CHK_RATING_Rec.CREATED_BY;
       x_pvt_CHK_RATING_REC.LAST_UPDATE_LOGIN    := P_CHK_RATING_Rec.LAST_UPDATE_LOGIN;
       x_pvt_CHK_RATING_REC.SEEDED_FLAG          := P_CHK_RATING_Rec.SEEDED_FLAG;

END Convert_pub_to_pvt_rec;

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
    X_Chk_rating_rec		   OUT NOCOPY  CHK_RATING_Rec_Type
  )
IS
BEGIN

    X_Chk_rating_rec.CHECK_ID	      := P_CHECK_ID;
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
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    p_validation_level           IN   NUMBER,
    px_CHECK_RATING_ID            IN OUT NOCOPY  NUMBER,
    p_CHECK_ID                   IN   NUMBER,
    p_CHECK_RATING_GRADE        IN   VARCHAR2,
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
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
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
    p_SEEDED_FLAG       => p_SEEDED_FLAG,
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
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    p_validation_level           IN   NUMBER  ,
    px_Check_Rating_ID		 IN OUT NOCOPY NUMBER,
    P_CHK_RATING_Rec     	 IN    CHK_RATING_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Create_check_ratings';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_PVT_CHK_RATING_Rec      CSC_CHECK_RATINGS_PVT.CHK_RATING_Rec_Type;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_CHECK_RATINGS_PUB;

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
      Convert_Pub_to_pvt_Rec(
    		P_CHK_RATING_Rec     => P_CHK_RATING_Rec,
    		x_PVT_CHK_RATING_Rec => l_PVT_CHK_RATING_Rec );


      CSC_check_ratings_PVT.Create_check_ratings(
      P_Api_Version_Number         => 1.0,
      P_Init_Msg_List              => CSC_CORE_UTILS_PVT.G_FALSE,
      P_Commit                     => CSC_CORE_UTILS_PVT.G_FALSE,
      P_Validation_Level           => CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
      px_Check_Rating_id		=>  	px_check_rating_id,
      P_CHK_RATING_Rec     	=>    l_PVT_CHK_RATING_Rec ,
      X_Return_Status              => x_return_status,
      X_Msg_Count                  => x_msg_count,
      X_Msg_Data                   => x_msg_data
      );


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
    		ROLLBACK TO Create_check_ratings_PUB;
    		x_return_status := FND_API.G_RET_STS_ERROR;
    		FND_MSG_PUB.Count_And_Get
      			( p_count => x_msg_count,
        		  	  p_data  => x_msg_data
      			);
  	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    		ROLLBACK TO Create_check_ratings_PUB;
    		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    		FND_MSG_PUB.Count_And_Get
      			( p_count => x_msg_count,
        		  	  p_data  => x_msg_data
      			);
  	WHEN OTHERS THEN
    		ROLLBACK TO Create_check_ratings_PUB;
    		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      			FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    		END IF;
    		FND_MSG_PUB.Count_And_Get
      			( p_count => x_msg_count,
        		  	  p_data  => x_msg_data
      			);
End Create_check_ratings;


PROCEDURE Update_check_ratings(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    p_validation_level           IN   NUMBER  ,
    p_CHECK_RATING_ID            IN   NUMBER,
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
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
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
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    p_validation_level           IN   NUMBER  ,
    P_CHK_RATING_Rec    	   IN   CHK_RATING_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Update_check_ratings';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_pvt_CHK_RATING_rec  CSC_CHECK_RATINGS_PVT.CHK_RATING_Rec_Type;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_CHECK_RATINGS_PUB;

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
      Convert_Pub_to_pvt_Rec(
    		P_CHK_RATING_Rec     => P_CHK_RATING_Rec,
    		x_PVT_CHK_RATING_Rec => l_PVT_CHK_RATING_Rec );


    CSC_check_ratings_PVT.Update_check_ratings(
     P_Api_Version_Number         => 1.0,
     P_Init_Msg_List              => CSC_CORE_UTILS_PVT.G_FALSE,
     P_Commit                     => CSC_CORE_UTILS_PVT.G_FALSE,
     P_Validation_Level           => CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
     P_CHK_RATING_Rec     	=>    l_PVT_CHK_RATING_Rec ,
     X_Return_Status              => x_return_status,
     X_Msg_Count                  => x_msg_count,
     X_Msg_Data                   => x_msg_data
     );


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
    		ROLLBACK TO Update_check_ratings_PUB;
    		x_return_status := FND_API.G_RET_STS_ERROR;
    		FND_MSG_PUB.Count_And_Get
      			( p_count => x_msg_count,
        		  	  p_data  => x_msg_data
      			);
  	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    		ROLLBACK TO Update_check_ratings_PUB;
    		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    		FND_MSG_PUB.Count_And_Get
      			( p_count => x_msg_count,
        		  	  p_data  => x_msg_data
      			);
  	WHEN OTHERS THEN
    		ROLLBACK TO Update_check_ratings_PUB;
    		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      			FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    		END IF;
    		FND_MSG_PUB.Count_And_Get
      			( p_count => x_msg_count,
        		  	  p_data  => x_msg_data
      			);
End Update_check_ratings;


PROCEDURE Delete_check_ratings(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    p_validation_level           IN   NUMBER  ,
    P_CHECK_RATING_ID     IN NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Delete_check_ratings';
l_api_version_number      CONSTANT NUMBER   := 2.0;
l_pvt_CHK_RATING_rec  CSC_CHECK_RATINGS_PVT.CHK_RATING_Rec_Type;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_CHECK_RATINGS_PUB;

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


    CSC_check_ratings_PVT.Delete_check_ratings(
    P_Api_Version_Number         => 1.0,
    P_Init_Msg_List              => CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit                     => p_commit,
    P_Validation_Level           => CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    P_CHECK_RATING_Id  => p_CHECK_RATING_Id,
    X_Return_Status              => x_return_status,
    X_Msg_Count                  => x_msg_count,
    X_Msg_Data                   => x_msg_data );



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
    		ROLLBACK TO Delete_check_ratings_PUB;
    		x_return_status := FND_API.G_RET_STS_ERROR;
    		FND_MSG_PUB.Count_And_Get
      			( p_count => x_msg_count,
        		  	  p_data  => x_msg_data
      			);
  	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    		ROLLBACK TO Delete_check_ratings_PUB;
    		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    		FND_MSG_PUB.Count_And_Get
      			( p_count => x_msg_count,
        		  	  p_data  => x_msg_data
      			);
  	WHEN OTHERS THEN
    		ROLLBACK TO Delete_check_ratings_PUB;
    		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      			FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    		END IF;
    		FND_MSG_PUB.Count_And_Get
      			( p_count => x_msg_count,
        		  	  p_data  => x_msg_data
      			);

End Delete_check_ratings;


End CSC_CHECK_RATINGS_PUB;

/
