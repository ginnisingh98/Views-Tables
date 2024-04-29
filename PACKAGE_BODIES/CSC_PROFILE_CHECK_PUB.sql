--------------------------------------------------------
--  DDL for Package Body CSC_PROFILE_CHECK_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSC_PROFILE_CHECK_PUB" as
/* $Header: cscppckb.pls 115.16 2002/11/29 03:25:49 bhroy ship $ */
-- Start of Comments
-- Package name     : CSC_CHECK_PUB
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSC_PROFILE_CHECK_PUB';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'cscpuckb.pls';

PROCEDURE Convert_Pub_to_pvt_Rec(
    p_check_rec	IN	CHECK_Rec_Type,
    x_pvt_check_rec OUT NOCOPY CSC_PROFILE_CHECK_PVT.CHECK_Rec_Type
    )
IS
BEGIN

    x_pvt_Check_rec.CHECK_ID := P_Check_Rec.CHECK_ID;
    x_pvt_Check_rec.CHECK_NAME_CODE := P_Check_Rec.CHECK_NAME_CODE;
    x_pvt_Check_rec.START_DATE_ACTIVE := P_Check_Rec.START_DATE_ACTIVE;
    x_pvt_Check_rec.END_DATE_ACTIVE := P_Check_Rec.END_DATE_ACTIVE;
    x_pvt_Check_rec.SEEDED_FLAG := P_Check_Rec.SEEDED_FLAG;
    x_pvt_Check_rec.SELECT_TYPE := P_Check_Rec.SELECT_TYPE;
    x_pvt_Check_rec.SELECT_BLOCK_ID := P_Check_Rec.SELECT_BLOCK_ID;
    x_pvt_Check_rec.DATA_TYPE := P_Check_Rec.DATA_TYPE;
    x_pvt_Check_rec.FORMAT_MASK := P_Check_Rec.FORMAT_MASK;
    x_pvt_Check_rec.THRESHOLD_GRADE := P_Check_Rec.THRESHOLD_GRADE;
    x_pvt_Check_rec.THRESHOLD_RATING_CODE := P_Check_Rec.THRESHOLD_RATING_CODE;
    x_pvt_Check_rec.THRESHOLD_COLOR_CODE := P_Check_Rec.THRESHOLD_COLOR_CODE;
    x_pvt_Check_rec.CHECK_LEVEL := P_Check_Rec.CHECK_LEVEL;
    x_pvt_Check_rec.CHECK_UPPER_LOWER_FLAG := P_Check_Rec.CHECK_UPPER_LOWER_FLAG;
    x_pvt_Check_rec.CREATED_BY := P_Check_Rec.CREATED_BY;
    x_pvt_Check_rec.CREATION_DATE := P_Check_Rec.CREATION_DATE;
    x_pvt_Check_rec.LAST_UPDATED_BY := P_Check_Rec.LAST_UPDATED_BY;
    x_pvt_Check_rec.LAST_UPDATE_DATE := P_Check_Rec.LAST_UPDATE_DATE;
    x_pvt_Check_rec.LAST_UPDATE_LOGIN := P_Check_Rec.LAST_UPDATE_LOGIN;
    x_pvt_Check_rec.OBJECT_VERSION_NUMBER := P_Check_Rec.OBJECT_VERSION_NUMBER;
    x_pvt_Check_rec.APPLICATION_ID := P_Check_Rec.APPLICATION_ID;

END Convert_pub_to_pvt_rec;

PROCEDURE Convert_Columns_to_Rec(
    p_CHECK_ID		         IN   NUMBER DEFAULT NULL,
    p_CHECK_NAME                 IN   VARCHAR2,
    p_CHECK_NAME_CODE            IN   VARCHAR2,
    p_DESCRIPTION                IN   VARCHAR2,
    p_START_DATE_ACTIVE          IN   DATE,
    p_END_DATE_ACTIVE            IN   DATE,
    p_SEEDED_FLAG                IN   VARCHAR2,
    p_SELECT_TYPE                IN   VARCHAR2,
    p_SELECT_BLOCK_ID            IN   NUMBER,
    p_DATA_TYPE                  IN   VARCHAR2,
    p_FORMAT_MASK                IN   VARCHAR2,
    p_THRESHOLD_GRADE            IN   VARCHAR2,
    p_THRESHOLD_RATING_CODE      IN   VARCHAR2,
    p_CHECK_UPPER_LOWER_FLAG     IN   VARCHAR2,
    p_THRESHOLD_COLOR_CODE       IN   VARCHAR2,
    p_CHECK_LEVEL                IN   VARCHAR2,
    -- p_CATEGORY_CODE              IN   VARCHAR2 := FND_API.G_MISS_CHAR,
    p_CREATED_BY                 IN   NUMBER,
    p_CREATION_DATE              IN   DATE,
    p_LAST_UPDATED_BY            IN   NUMBER,
    p_LAST_UPDATE_DATE           IN   DATE,
    p_LAST_UPDATE_LOGIN          IN   NUMBER,
    p_OBJECT_VERSION_NUMBER      IN   NUMBER DEFAULT NULL,
    p_APPLICATION_ID             IN   NUMBER,
    X_Check_Rec     		   OUT NOCOPY   Check_Rec_Type
    )
IS
BEGIN
    X_Check_Rec.CHECK_ID    := p_CHECK_ID;
    X_Check_Rec.CHECK_NAME  := p_CHECK_NAME;
    X_Check_Rec.CHECK_NAME_CODE := p_CHECK_NAME_CODE;
    X_Check_Rec.DESCRIPTION := p_DESCRIPTION;
    X_Check_Rec.START_DATE_ACTIVE := p_START_DATE_ACTIVE;
    X_Check_Rec.END_DATE_ACTIVE := p_END_DATE_ACTIVE;
    X_Check_Rec.SEEDED_FLAG  := p_SEEDED_FLAG;
    X_Check_Rec.SELECT_TYPE  := p_SELECT_TYPE;
    X_Check_Rec.SELECT_BLOCK_ID  := p_SELECT_BLOCK_ID;
    X_Check_Rec.DATA_TYPE  := p_DATA_TYPE;
    X_Check_Rec.FORMAT_MASK := p_FORMAT_MASK;
    X_Check_Rec.THRESHOLD_GRADE := p_THRESHOLD_GRADE;
    X_Check_Rec.THRESHOLD_RATING_CODE := p_THRESHOLD_RATING_CODE;
    X_Check_Rec.CHECK_UPPER_LOWER_FLAG := p_CHECK_UPPER_LOWER_FLAG;
    X_Check_Rec.THRESHOLD_COLOR_CODE := p_THRESHOLD_COLOR_CODE;
    X_Check_Rec.CHECK_LEVEL := p_CHECK_LEVEL;
    --X_Check_Rec.CATEGORY_CODE := p_CATEGORY_CODE;
    X_Check_Rec.CREATED_BY := p_CREATED_BY;
    X_Check_Rec.CREATION_DATE := p_CREATION_DATE;
    X_Check_Rec.LAST_UPDATED_BY := p_LAST_UPDATED_BY;
    X_Check_Rec.LAST_UPDATE_DATE := p_LAST_UPDATE_DATE;
    X_Check_Rec.LAST_UPDATE_LOGIN :=  p_LAST_UPDATE_LOGIN;
    X_Check_Rec.OBJECT_VERSION_NUMBER := p_OBJECT_VERSION_NUMBER;
    X_Check_Rec.APPLICATION_ID := p_APPLICATION_ID;
END Convert_Columns_to_Rec;

PROCEDURE Create_Profile_Check(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    p_CHECK_NAME                 IN   VARCHAR2,
    p_CHECK_NAME_CODE            IN   VARCHAR2,
    p_DESCRIPTION                IN   VARCHAR2,
    p_START_DATE_ACTIVE          IN   DATE,
    p_END_DATE_ACTIVE            IN   DATE,
    p_SEEDED_FLAG                IN   VARCHAR2,
    p_SELECT_TYPE                IN   VARCHAR2,
    p_SELECT_BLOCK_ID            IN   NUMBER,
    p_DATA_TYPE                  IN   VARCHAR2,
    p_FORMAT_MASK                IN   VARCHAR2,
    p_THRESHOLD_GRADE            IN   VARCHAR2,
    p_THRESHOLD_RATING_CODE      IN   VARCHAR2,
    p_CHECK_UPPER_LOWER_FLAG     IN   VARCHAR2,
    p_THRESHOLD_COLOR_CODE       IN   VARCHAR2,
    p_CHECK_LEVEL                IN   VARCHAR2,
    --p_CATEGORY_CODE              IN   VARCHAR2 := FND_API.G_MISS_CHAR,
    p_CREATED_BY                 IN   NUMBER,
    p_CREATION_DATE              IN   DATE,
    p_LAST_UPDATED_BY            IN   NUMBER,
    p_LAST_UPDATE_DATE           IN   DATE,
    p_LAST_UPDATE_LOGIN          IN   NUMBER,
    X_OBJECT_VERSION_NUMBER      OUT NOCOPY   NUMBER,
    p_APPLICATION_ID             IN   NUMBER,
    X_CHECK_ID     		   OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
  l_Check_Rec     Check_Rec_Type;
BEGIN
   Convert_Columns_to_Rec(
    p_CHECK_NAME              => p_CHECK_NAME,
    p_CHECK_NAME_CODE         => p_CHECK_NAME_CODE,
    p_DESCRIPTION             => p_DESCRIPTION,
    p_START_DATE_ACTIVE       => p_START_DATE_ACTIVE,
    p_END_DATE_ACTIVE         => p_END_DATE_ACTIVE,
    p_SEEDED_FLAG             => p_SEEDED_FLAG,
    p_SELECT_TYPE             => p_SELECT_TYPE,
    p_SELECT_BLOCK_ID         => p_SELECT_BLOCK_ID,
    p_DATA_TYPE               => p_DATA_TYPE,
    p_FORMAT_MASK             => p_FORMAT_MASK,
    p_THRESHOLD_GRADE         => p_THRESHOLD_GRADE,
    p_THRESHOLD_RATING_CODE   => p_THRESHOLD_RATING_CODE,
    p_CHECK_UPPER_LOWER_FLAG  => p_CHECK_UPPER_LOWER_FLAG,
    p_THRESHOLD_COLOR_CODE    => p_THRESHOLD_COLOR_CODE,
    p_CHECK_LEVEL             => p_CHECK_LEVEL,
    -- p_CATEGORY_CODE        => p_CATEGORY_CODE
    p_CREATED_BY              => p_CREATED_BY,
    p_CREATION_DATE           => p_CREATION_DATE,
    p_LAST_UPDATED_BY         => p_LAST_UPDATED_BY,
    p_LAST_UPDATE_DATE        => p_LAST_UPDATE_DATE,
    p_LAST_UPDATE_LOGIN       => p_LAST_UPDATE_LOGIN,
    p_APPLICATION_ID          => p_APPLICATION_ID,
    X_Check_Rec	              => l_Check_rec
    );

   Create_Profile_Check(
    P_Api_Version_Number         => P_Api_Version_Number,
    P_Init_Msg_List              => P_Init_Msg_List,
    P_Commit                     => P_Commit,
    P_Check_Rec     		   => l_Check_Rec,
    X_CHECK_ID     		   => X_CHECK_ID,
    X_OBJECT_VERSION_NUMBER      => X_OBJECT_VERSION_NUMBER,
    X_Return_Status              => X_Return_Status,
    X_Msg_Count                  => X_Msg_Count,
    X_Msg_Data                   => X_Msg_Data
    );
END Create_Profile_Check;


PROCEDURE Create_Profile_Check(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    P_CHECK_Rec     IN    CHECK_Rec_Type,
    X_CHECK_ID      OUT NOCOPY  NUMBER,
    X_OBJECT_VERSION_NUMBER OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
  l_api_name                CONSTANT VARCHAR2(30) := 'Create_check';
  l_api_version_number      CONSTANT NUMBER   := 1.0;

  l_pvt_check_rec    CSC_PROFILE_CHECK_PVT.CHECK_Rec_Type;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_PROFILE_CHECK_PUB;

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

	Convert_Pub_to_Pvt_Rec(
	p_check_Rec => p_check_rec,
	x_pvt_check_rec => l_pvt_check_rec
	);

      --
      -- API body
      --
      CSC_Profile_check_PVT.Create_Profile_check(
      P_Api_Version_Number         => 1.0,
      P_Init_Msg_List              => FND_API.G_FALSE,
      P_Commit                     => FND_API.G_FALSE,
      P_Validation_Level           => FND_API.G_VALID_LEVEL_FULL,
      P_CHECK_Rec  		=>  l_pvt_CHECK_Rec ,
      X_CHECK_ID     		=> x_CHECK_ID,
      X_OBJECT_VERSION_NUMBER      => X_OBJECT_VERSION_NUMBER,
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
    		ROLLBACK TO Create_Profile_Check_PUB;
    		x_return_status := FND_API.G_RET_STS_ERROR;
    		FND_MSG_PUB.Count_And_Get
      			( p_count => x_msg_count,
        		  	  p_data  => x_msg_data
      			);
  	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    		ROLLBACK TO Create_Profile_Check_PUB;
    		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    		FND_MSG_PUB.Count_And_Get
      			( p_count => x_msg_count,
        		  	  p_data  => x_msg_data
      			);
  	WHEN OTHERS THEN
    		ROLLBACK TO Create_Profile_Check_PUB;
    		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      			FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    		END IF;
    		FND_MSG_PUB.Count_And_Get
      			( p_count => x_msg_count,
        		  	  p_data  => x_msg_data
      			);
End Create_Profile_check;


PROCEDURE Update_Profile_Check(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    p_CHECK_ID     		   IN   NUMBER,
    p_CHECK_NAME                 IN   VARCHAR2,
    p_CHECK_NAME_CODE            IN   VARCHAR2,
    p_DESCRIPTION                IN   VARCHAR2,
    p_START_DATE_ACTIVE          IN   DATE,
    p_END_DATE_ACTIVE            IN   DATE,
    p_SEEDED_FLAG                IN   VARCHAR2,
    p_SELECT_TYPE                IN   VARCHAR2,
    p_SELECT_BLOCK_ID            IN   NUMBER,
    p_DATA_TYPE                  IN   VARCHAR2,
    p_FORMAT_MASK                IN   VARCHAR2,
    p_THRESHOLD_GRADE            IN   VARCHAR2,
    p_THRESHOLD_RATING_CODE      IN   VARCHAR2,
    p_CHECK_UPPER_LOWER_FLAG     IN   VARCHAR2,
    p_THRESHOLD_COLOR_CODE       IN   VARCHAR2,
    p_CHECK_LEVEL                IN   VARCHAR2,
    -- p_CATEGORY_CODE              IN   VARCHAR2 := FND_API.G_MISS_CHAR,
    p_CREATED_BY                 IN   NUMBER,
    p_CREATION_DATE              IN   DATE,
    p_LAST_UPDATED_BY            IN   NUMBER,
    p_LAST_UPDATE_DATE           IN   DATE,
    p_LAST_UPDATE_LOGIN          IN   NUMBER,
    px_OBJECT_VERSION_NUMBER      IN OUT NOCOPY  NUMBER ,
    p_APPLICATION_ID             IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
 l_Check_Rec   Check_Rec_Type;
BEGIN

   Convert_Columns_to_Rec(
    p_CHECK_ID			=> p_CHECK_ID,
    p_CHECK_NAME              => p_CHECK_NAME,
    p_CHECK_NAME_CODE         => p_CHECK_NAME_CODE,
    p_DESCRIPTION             => p_DESCRIPTION,
    p_START_DATE_ACTIVE       => p_START_DATE_ACTIVE,
    p_END_DATE_ACTIVE         => p_END_DATE_ACTIVE,
    p_SEEDED_FLAG             => p_SEEDED_FLAG,
    p_SELECT_TYPE             => p_SELECT_TYPE,
    p_SELECT_BLOCK_ID         => p_SELECT_BLOCK_ID,
    p_DATA_TYPE               => p_DATA_TYPE,
    p_FORMAT_MASK             => p_FORMAT_MASK,
    p_THRESHOLD_GRADE         => p_THRESHOLD_GRADE,
    p_THRESHOLD_RATING_CODE   => p_THRESHOLD_RATING_CODE,
    p_CHECK_UPPER_LOWER_FLAG  => p_CHECK_UPPER_LOWER_FLAG,
    p_THRESHOLD_COLOR_CODE    => p_THRESHOLD_COLOR_CODE,
    p_CHECK_LEVEL             => p_CHECK_LEVEL,
    -- p_CATEGORY_CODE        => p_CATEGORY_CODE
    p_CREATED_BY              => p_CREATED_BY,
    p_CREATION_DATE           => p_CREATION_DATE,
    p_LAST_UPDATED_BY         => p_LAST_UPDATED_BY,
    p_LAST_UPDATE_DATE        => p_LAST_UPDATE_DATE,
    p_LAST_UPDATE_LOGIN       => p_LAST_UPDATE_LOGIN,
    p_OBJECT_VERSION_NUMBER   =>px_OBJECT_VERSION_NUMBER,
    p_APPLICATION_ID          => p_APPLICATION_ID,
    X_Check_Rec		      => l_Check_rec
    );


   Update_Profile_check(
    P_Api_Version_Number => P_Api_Version_Number,
    P_Init_Msg_List    => P_Init_Msg_List,
    P_Commit           => P_Commit,
    P_Check_Rec        => l_Check_Rec,
    Px_OBJECT_VERSION_NUMBER      => Px_OBJECT_VERSION_NUMBER,
    X_Return_Status    => X_Return_Status,
    X_Msg_Count        => X_Msg_Count,
    X_Msg_Data         => X_Msg_Data
    );

END;


PROCEDURE Update_Profile_Check(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    P_CHECK_Rec     IN    CHECK_Rec_Type,
    PX_OBJECT_VERSION_NUMBER IN OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Update_check';
l_api_version_number      CONSTANT NUMBER   := 1.0;

l_pvt_check_rec    CSC_PROFILE_CHECK_PVT.CHECK_Rec_Type;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_CHECK_PUB;

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

	Convert_Pub_to_Pvt_Rec(
	p_check_Rec => p_check_rec,
	x_pvt_check_rec => l_pvt_check_rec
	);


    CSC_Profile_check_PVT.Update_Profile_check(
    P_Api_Version_Number         => 1.0,
    P_Init_Msg_List              => FND_API.G_FALSE,
    P_Commit                     => p_commit,
    P_Validation_Level           => FND_API.G_VALID_LEVEL_FULL,
    P_CHECK_Rec  		=>  l_pvt_CHECK_Rec ,
    Px_OBJECT_VERSION_NUMBER      => Px_OBJECT_VERSION_NUMBER,
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
    		ROLLBACK TO Update_Profile_Check_PUB;
    		x_return_status := FND_API.G_RET_STS_ERROR;
    		FND_MSG_PUB.Count_And_Get
      			( p_count => x_msg_count,
        		  	  p_data  => x_msg_data
      			);
  	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    		ROLLBACK TO Update_Profile_Check_PUB;
    		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    		FND_MSG_PUB.Count_And_Get
      			( p_count => x_msg_count,
        		  	  p_data  => x_msg_data
      			);
  	WHEN OTHERS THEN
    		ROLLBACK TO Update_Profile_Check_PUB;
    		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      			FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    		END IF;
    		FND_MSG_PUB.Count_And_Get
      			( p_count => x_msg_count,
        		  	  p_data  => x_msg_data
      			);
End Update_Profile_check;

PROCEDURE Delete_Profile_check(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    p_Check_Id			   IN   NUMBER,
    p_Object_version_number IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Delete_Profile_check';
l_api_version_number      CONSTANT NUMBER   := 1.0;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_CHECK_PUB;

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

    CSC_Profile_check_PVT.Delete_Profile_check(
    P_Api_Version_Number         => 1.0,
    P_Init_Msg_List              => FND_API.G_FALSE,
    P_Commit                     => p_commit,
    P_VALidation_level => FND_API.G_VALID_LEVEL_FULL,
    P_OBJECT_VERSION_NUMBER => P_OBJECT_VERSION_NUMBER,
    P_CHECK_Id  			   => p_CHECK_Id,
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
    		ROLLBACK TO Delete_Profile_Check_PUB;
    		x_return_status := FND_API.G_RET_STS_ERROR;
    		FND_MSG_PUB.Count_And_Get
      			( p_count => x_msg_count,
        		  	  p_data  => x_msg_data
      			);
  	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    		ROLLBACK TO Delete_Profile_Check_PUB;
    		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    		FND_MSG_PUB.Count_And_Get
      			( p_count => x_msg_count,
        		  	  p_data  => x_msg_data
      			);
  	WHEN OTHERS THEN
    		ROLLBACK TO Delete_Profile_Check_PUB;
    		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      			FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    		END IF;
    		FND_MSG_PUB.Count_And_Get
      			( p_count => x_msg_count,
        		  	  p_data  => x_msg_data
      			);
End Delete_Profile_check;



End CSC_PROFILE_CHECK_PUB;

/
