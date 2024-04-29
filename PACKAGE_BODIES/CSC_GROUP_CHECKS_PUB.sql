--------------------------------------------------------
--  DDL for Package Body CSC_GROUP_CHECKS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSC_GROUP_CHECKS_PUB" as
/* $Header: cscppgcb.pls 115.11 2002/11/29 04:45:00 bhroy ship $ */
-- Start of Comments
-- Package name     : CSC_GROUP_CHECKS_PUB
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSC_GROUP_CHECKS_PUB';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'cscpugcb.pls';

PROCEDURE Convert_Columns_to_Rec(
    P_GROUP_ID                 IN     NUMBER,
    P_CHECK_ID                 IN     NUMBER,
    P_CHECK_SEQUENCE           IN     NUMBER,
    P_END_DATE_ACTIVE          IN     DATE,
    P_START_DATE_ACTIVE        IN     DATE,
    P_CATEGORY_CODE            IN     VARCHAR2,
    P_CATEGORY_SEQUENCE        IN     NUMBER,
    P_THRESHOLD_FLAG           IN     VARCHAR2,
    P_SEEDED_FLAG              IN     VARCHAR2,
    P_CREATED_BY               IN     NUMBER,
    P_CREATION_DATE            IN     DATE,
    P_LAST_UPDATED_BY          IN     NUMBER,
    P_LAST_UPDATE_DATE         IN     DATE,
    P_LAST_UPDATE_LOGIN        IN     NUMBER,
    X_GROUP_CHK_Rec     	OUT NOCOPY    GROUP_CHK_Rec_Type
    )
   IS
BEGIN
    X_GROUP_CHK_Rec.GROUP_ID              :=  P_GROUP_ID;
    X_GROUP_CHK_Rec.CHECK_ID              := P_CHECK_ID;
    X_GROUP_CHK_Rec.CHECK_SEQUENCE        := P_CHECK_SEQUENCE;
    X_GROUP_CHK_Rec.END_DATE_ACTIVE       :=  P_END_DATE_ACTIVE;
    X_GROUP_CHK_Rec.START_DATE_ACTIVE     := P_START_DATE_ACTIVE;
    X_GROUP_CHK_Rec.CATEGORY_CODE         := P_CATEGORY_CODE;
    X_GROUP_CHK_Rec.CATEGORY_SEQUENCE     := P_CATEGORY_SEQUENCE;
    X_GROUP_CHK_Rec.THRESHOLD_FLAG        := P_THRESHOLD_FLAG;
    X_GROUP_CHK_Rec.SEEDED_FLAG           := P_SEEDED_FLAG;
    X_GROUP_CHK_Rec.CREATED_BY            := P_CREATED_BY;
    X_GROUP_CHK_Rec.CREATION_DATE         := P_CREATION_DATE;
    X_GROUP_CHK_Rec.LAST_UPDATED_BY       := P_LAST_UPDATED_BY;
    X_GROUP_CHK_Rec.LAST_UPDATE_DATE      := P_LAST_UPDATE_DATE;
    X_GROUP_CHK_Rec.LAST_UPDATE_LOGIN     := P_LAST_UPDATE_LOGIN;

END Convert_Columns_to_Rec;

PROCEDURE Convert_Pub_to_Pvt_Rec(
    P_GROUP_CHK_Rec     IN    GROUP_CHK_Rec_Type,
    X_PVT_Group_chk_rec     OUT NOCOPY   CSC_GROUP_CHECKS_PVT.GROUP_CHK_Rec_Type
)
IS
BEGIN

    X_PVT_GROUP_CHK_Rec.GROUP_ID              :=  P_GROUP_CHK_Rec.GROUP_ID;
    X_PVT_GROUP_CHK_Rec.CHECK_ID              := P_GROUP_CHK_Rec.CHECK_ID;
    X_PVT_GROUP_CHK_Rec.CHECK_SEQUENCE        := P_GROUP_CHK_Rec.CHECK_SEQUENCE;
    X_PVT_GROUP_CHK_Rec.END_DATE_ACTIVE       :=  P_GROUP_CHK_Rec.END_DATE_ACTIVE;
    X_PVT_GROUP_CHK_Rec.START_DATE_ACTIVE     := P_GROUP_CHK_Rec.START_DATE_ACTIVE;
    X_PVT_GROUP_CHK_Rec.CATEGORY_CODE         := P_GROUP_CHK_Rec.CATEGORY_CODE;
    X_PVT_GROUP_CHK_Rec.CATEGORY_SEQUENCE     := P_GROUP_CHK_Rec.CATEGORY_SEQUENCE;
    X_PVT_GROUP_CHK_Rec.THRESHOLD_FLAG        := P_GROUP_CHK_Rec.THRESHOLD_FLAG;
    X_PVT_GROUP_CHK_Rec.SEEDED_FLAG           := P_GROUP_CHK_Rec.SEEDED_FLAG ;
    X_PVT_GROUP_CHK_Rec.CREATED_BY            := P_GROUP_CHK_Rec.CREATED_BY;
    X_PVT_GROUP_CHK_Rec.CREATION_DATE         := P_GROUP_CHK_Rec.CREATION_DATE;
    X_PVT_GROUP_CHK_Rec.LAST_UPDATED_BY       := P_GROUP_CHK_Rec.LAST_UPDATED_BY;
    X_PVT_GROUP_CHK_Rec.LAST_UPDATE_DATE      := P_GROUP_CHK_Rec.LAST_UPDATE_DATE;
    X_PVT_GROUP_CHK_Rec.LAST_UPDATE_LOGIN     := P_GROUP_CHK_Rec.LAST_UPDATE_LOGIN;

END Convert_Pub_to_Pvt_Rec;



PROCEDURE Create_group_checks(
    P_Api_Version_Number      IN   NUMBER,
    P_Init_Msg_List           IN   VARCHAR2,
    P_Commit                  IN   VARCHAR2,
    p_validation_level        IN   NUMBER,
    P_GROUP_ID                 IN     NUMBER,
    P_CHECK_ID                 IN     NUMBER,
    P_CHECK_SEQUENCE           IN     NUMBER,
    P_END_DATE_ACTIVE          IN     DATE,
    P_START_DATE_ACTIVE        IN     DATE,
    P_CATEGORY_CODE            IN     VARCHAR2,
    P_CATEGORY_SEQUENCE        IN     NUMBER,
    P_THRESHOLD_FLAG           IN     VARCHAR2,
    P_SEEDED_FLAG              IN     VARCHAR2,
    P_CREATED_BY               IN     NUMBER,
    P_CREATION_DATE            IN     DATE,
    P_LAST_UPDATED_BY          IN     NUMBER,
    P_LAST_UPDATE_DATE         IN     DATE,
    P_LAST_UPDATE_LOGIN        IN     NUMBER,
    X_Return_Status           OUT NOCOPY  VARCHAR2,
    X_Msg_Count               OUT NOCOPY  NUMBER,
    X_Msg_Data                OUT NOCOPY  VARCHAR2
    )
  IS
 l_group_Chk_Rec Group_chk_Rec_Type;
 BEGIN

 Convert_Columns_to_Rec(
    P_GROUP_ID                => P_GROUP_ID,
    P_CHECK_ID                => P_CHECK_ID,
    P_CHECK_SEQUENCE          => P_CHECK_SEQUENCE,
    P_END_DATE_ACTIVE         => P_END_DATE_ACTIVE,
    P_START_DATE_ACTIVE       => P_START_DATE_ACTIVE,
    P_CATEGORY_CODE           => P_CATEGORY_CODE,
    P_CATEGORY_SEQUENCE       => P_CATEGORY_SEQUENCE,
    P_THRESHOLD_FLAG          => P_THRESHOLD_FLAG,
    P_SEEDED_FLAG             => P_SEEDED_FLAG,
    P_CREATED_BY              => P_CREATED_BY,
    P_CREATION_DATE           => P_CREATION_DATE,
    P_LAST_UPDATED_BY         => P_LAST_UPDATED_BY,
    P_LAST_UPDATE_DATE        => P_LAST_UPDATE_DATE,
    P_LAST_UPDATE_LOGIN       => P_LAST_UPDATE_LOGIN,
    X_GROUP_CHK_Rec     	=> l_GROUP_CHK_Rec
    );

  Create_group_checks(
      P_Api_Version_Number         => P_Api_Version_Number,
      P_Init_Msg_List              => CSC_CORE_UTILS_PVT.G_FALSE,
      P_Commit                     => CSC_CORE_UTILS_PVT.G_FALSE,
      P_GROUP_CHK_Rec     	     => l_Group_Chk_Rec,
      X_Return_Status              => x_return_status,
      X_Msg_Count                  => x_msg_count,
      X_Msg_Data                   => x_msg_data);


 END Create_group_checks;


PROCEDURE Create_group_checks(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    P_GROUP_CHK_Rec     IN    GROUP_CHK_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Create_group_checks';
l_api_version_number      CONSTANT NUMBER   := 1.0;

l_pvt_GROUP_CHK_rec    CSC_GROUP_CHECKS_PVT.GROUP_CHK_Rec_Type;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_GROUP_CHECKS_PUB;

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
    	P_GROUP_CHK_Rec     => p_GROUP_chk_rec,
    	X_PVT_Group_chk_rec     => l_pvt_Group_chk_rec
	);

      CSC_group_checks_PVT.Create_group_checks(
      P_Api_Version_Number         => 1.0,
      P_Init_Msg_List              => CSC_CORE_UTILS_PVT.G_FALSE,
      P_Commit                     => CSC_CORE_UTILS_PVT.G_FALSE,
      P_Validation_Level           => CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
      P_GROUP_CHK_Rec  =>  l_pvt_GROUP_CHK_Rec ,
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
    		ROLLBACK TO Create_group_checks_PUB;
    		x_return_status := FND_API.G_RET_STS_ERROR;
    		FND_MSG_PUB.Count_And_Get
      			( p_count => x_msg_count,
        		  	  p_data  => x_msg_data
      			);
  	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    		ROLLBACK TO Create_group_checks_PUB;
    		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    		FND_MSG_PUB.Count_And_Get
      			( p_count => x_msg_count,
        		  	  p_data  => x_msg_data
      			);
  	WHEN OTHERS THEN
    		ROLLBACK TO Create_group_checks_PUB;
    		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      			FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    		END IF;
    		FND_MSG_PUB.Count_And_Get
      			( p_count => x_msg_count,
        		  	  p_data  => x_msg_data
      			);
End Create_group_checks;

PROCEDURE Update_group_checks(
    P_Api_Version_Number      IN   NUMBER,
    P_Init_Msg_List           IN   VARCHAR2,
    P_Commit                  IN   VARCHAR2,
    p_validation_level        IN   NUMBER,
    P_GROUP_ID                 IN     NUMBER,
    P_CHECK_ID                 IN     NUMBER,
    P_CHECK_SEQUENCE           IN     NUMBER,
    P_END_DATE_ACTIVE          IN     DATE,
    P_START_DATE_ACTIVE        IN     DATE,
    P_CATEGORY_CODE            IN     VARCHAR2,
    P_CATEGORY_SEQUENCE        IN     NUMBER,
    P_THRESHOLD_FLAG           IN     VARCHAR2,
    P_SEEDED_FLAG              IN     VARCHAR2,
    P_CREATED_BY               IN     NUMBER,
    P_CREATION_DATE            IN     DATE,
    P_LAST_UPDATED_BY          IN     NUMBER,
    P_LAST_UPDATE_DATE         IN     DATE,
    P_LAST_UPDATE_LOGIN        IN     NUMBER,
    X_Return_Status           OUT NOCOPY  VARCHAR2,
    X_Msg_Count               OUT NOCOPY  NUMBER,
    X_Msg_Data                OUT NOCOPY  VARCHAR2
    )
  IS
l_GROUP_CHK_rec    GROUP_CHK_Rec_Type;
 BEGIN

 Convert_Columns_to_Rec(
    P_GROUP_ID                => P_GROUP_ID,
    P_CHECK_ID                => P_CHECK_ID,
    P_CHECK_SEQUENCE          => P_CHECK_SEQUENCE,
    P_END_DATE_ACTIVE         => P_END_DATE_ACTIVE,
    P_START_DATE_ACTIVE       => P_START_DATE_ACTIVE,
    P_CATEGORY_CODE           => P_CATEGORY_CODE,
    P_CATEGORY_SEQUENCE       => P_CATEGORY_SEQUENCE,
    P_THRESHOLD_FLAG          => P_THRESHOLD_FLAG,
    P_SEEDED_FLAG             => P_SEEDED_FLAG,
    P_CREATED_BY              => P_CREATED_BY,
    P_CREATION_DATE           => P_CREATION_DATE,
    P_LAST_UPDATED_BY         => P_LAST_UPDATED_BY,
    P_LAST_UPDATE_DATE        => P_LAST_UPDATE_DATE,
    P_LAST_UPDATE_LOGIN       => P_LAST_UPDATE_LOGIN,
    X_GROUP_CHK_Rec     	=> l_GROUP_CHK_Rec
    );

  Update_group_checks(
      P_Api_Version_Number         => P_Api_Version_Number,
      P_Init_Msg_List              => CSC_CORE_UTILS_PVT.G_FALSE,
      P_Commit                     => CSC_CORE_UTILS_PVT.G_FALSE,
      P_GROUP_CHK_Rec     	     => l_Group_Chk_Rec,
      X_Return_Status              => x_return_status,
      X_Msg_Count                  => x_msg_count,
      X_Msg_Data                   => x_msg_data);


 END Update_group_checks;


PROCEDURE Update_group_checks(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    P_GROUP_CHK_Rec     IN    GROUP_CHK_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Update_group_checks';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_pvt_GROUP_CHK_rec    CSC_GROUP_CHECKS_PVT.GROUP_CHK_Rec_Type;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_GROUP_CHECKS_PUB;

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
    	P_GROUP_CHK_Rec     => p_GROUP_chk_rec,
    	X_PVT_Group_CHK_rec     => l_pvt_Group_chk_rec
	);

    	CSC_group_checks_PVT.Update_group_checks(
    	P_Api_Version_Number         => 1.0,
    	P_Init_Msg_List              => CSC_CORE_UTILS_PVT.G_FALSE,
    	P_Commit                     => p_commit,
    	P_Validation_Level           => CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    	P_GROUP_CHK_Rec  =>  l_pvt_GROUP_CHK_Rec ,
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
    		ROLLBACK TO Update_group_checks_PUB;
    		x_return_status := FND_API.G_RET_STS_ERROR;
    		FND_MSG_PUB.Count_And_Get
      			( p_count => x_msg_count,
        		  	  p_data  => x_msg_data
      			);
  	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    		ROLLBACK TO Update_group_checks_PUB;
    		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    		FND_MSG_PUB.Count_And_Get
      			( p_count => x_msg_count,
        		  	  p_data  => x_msg_data
      			);
  	WHEN OTHERS THEN
    		ROLLBACK TO Update_group_checks_PUB;
    		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      			FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    		END IF;
    		FND_MSG_PUB.Count_And_Get
      			( p_count => x_msg_count,
        		  	  p_data  => x_msg_data
      			);
End Update_group_checks;


PROCEDURE Delete_group_checks(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    P_GROUP_ID     		   IN   NUMBER,
    P_CHECK_ID			   IN   NUMBER,
    P_CHECK_SEQUENCE			   IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Delete_group_checks';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_pvt_GROUP_CHK_rec  CSC_GROUP_CHECKS_PVT.GROUP_CHK_Rec_Type;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_GROUP_CHECKS_PUB;

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

    CSC_group_checks_PVT.Delete_group_checks(
    P_Api_Version_Number         => 1.0,
    P_Init_Msg_List              => CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit                     => p_commit,
    P_Validation_Level           => CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    P_GROUP_ID     		   => P_GROUP_ID,
    P_CHECK_ID			   => P_CHECK_ID,
    P_CHECK_SEQUENCE		   => P_CHECK_SEQUENCE,
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
    		ROLLBACK TO Delete_group_checks_PUB;
    		x_return_status := FND_API.G_RET_STS_ERROR;
    		FND_MSG_PUB.Count_And_Get
      			( p_count => x_msg_count,
        		  	  p_data  => x_msg_data
      			);
  	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    		ROLLBACK TO Delete_group_checks_PUB;
    		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    		FND_MSG_PUB.Count_And_Get
      			( p_count => x_msg_count,
        		  	  p_data  => x_msg_data
      			);
  	WHEN OTHERS THEN
    		ROLLBACK TO Delete_group_checks_PUB;
    		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      			FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    		END IF;
    		FND_MSG_PUB.Count_And_Get
      			( p_count => x_msg_count,
        		  	  p_data  => x_msg_data
      			);
End Delete_group_checks;

End CSC_GROUP_CHECKS_PUB;

/
