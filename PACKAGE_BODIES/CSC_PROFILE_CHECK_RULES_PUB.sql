--------------------------------------------------------
--  DDL for Package Body CSC_PROFILE_CHECK_RULES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSC_PROFILE_CHECK_RULES_PUB" as
/* $Header: cscppcrb.pls 115.11 2002/11/29 03:43:20 bhroy ship $ */
-- Start of Comments
-- Package name     : CSC_PROFILE_CHECK_RULES_PUB
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSC_PROFILE_CHECK_RULES_PUB';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'cscpucrb.pls';
----------------------------------------------------------------------------
-- Convert_pub_to_pvt_rec Procedure
----------------------------------------------------------------------------

PROCEDURE Convert_pub_to_pvt_Rec (
         P_chk_rules_Rec        IN   CSC_profile_check_rules_PUB.Chk_Rules_Rec_Type,
         x_pvt_chk_rules_rec    OUT NOCOPY   CSC_profile_check_rules_PVT.Chk_Rules_Rec_Type
)
IS
l_any_errors       BOOLEAN   := FALSE;
BEGIN
    x_pvt_chk_rules_rec.CHECK_ID := P_chk_rules_rec.CHECK_ID;
    x_pvt_chk_rules_rec.BLOCK_ID := P_chk_rules_rec.BLOCK_ID;
    x_pvt_chk_rules_rec.SEQUENCE := P_chk_rules_rec.SEQUENCE;
    x_pvt_chk_rules_rec.LOGICAL_OPERATOR := P_chk_rules_rec.LOGICAL_OPERATOR;
    x_pvt_chk_rules_rec.LEFT_PAREN := P_chk_rules_rec.LEFT_PAREN;
    x_pvt_chk_rules_rec.COMPARISON_OPERATOR := P_chk_rules_rec.COMPARISON_OPERATOR;
    x_pvt_chk_rules_rec.EXPRESSION := P_chk_rules_rec.EXPRESSION;
    x_pvt_chk_rules_rec.EXPR_TO_BLOCK_ID := P_chk_rules_rec.EXPR_TO_BLOCK_ID;
    x_pvt_chk_rules_rec.RIGHT_PAREN := P_chk_rules_rec.RIGHT_PAREN;
    x_pvt_chk_rules_rec.SEEDED_FLAG := P_chk_rules_rec.SEEDED_FLAG;
    x_pvt_chk_rules_rec.CREATED_BY := P_chk_rules_rec.CREATED_BY;
    x_pvt_chk_rules_rec.CREATION_DATE := P_chk_rules_rec.CREATION_DATE;
    x_pvt_chk_rules_rec.LAST_UPDATED_BY := P_chk_rules_rec.LAST_UPDATED_BY;
    x_pvt_chk_rules_rec.LAST_UPDATE_DATE := P_chk_rules_rec.LAST_UPDATE_DATE;
    x_pvt_chk_rules_rec.LAST_UPDATE_LOGIN := P_chk_rules_rec.LAST_UPDATE_LOGIN;
    x_pvt_chk_rules_rec.SEEDED_FLAG := P_chk_rules_rec.SEEDED_FLAG;

    -- If there is an error in conversion precessing, raise an error.
    IF l_any_errors
    THEN
        raise FND_API.G_EXC_ERROR;
    END IF;
END Convert_pub_to_pvt_Rec;


PROCEDURE Convert_Columns_to_Rec(
    P_CHECK_ID     		   IN  NUMBER,
    P_BLOCK_ID     		   IN  NUMBER,
    P_SEQUENCE                   IN  NUMBER,
    P_CREATED_BY                 IN  NUMBER,
    P_CREATION_DATE              IN  DATE,
    P_LAST_UPDATED_BY            IN  NUMBER,
    P_LAST_UPDATE_DATE           IN  DATE,
    P_LAST_UPDATE_LOGIN          IN  NUMBER,
    P_LOGICAL_OPERATOR           IN  VARCHAR2,
    P_LEFT_PAREN                 IN  VARCHAR2,
    P_COMPARISON_OPERATOR        IN  VARCHAR2,
    P_EXPRESSION                 IN  VARCHAR2,
    P_EXPR_TO_BLOCK_ID           IN  NUMBER,
    P_RIGHT_PAREN                IN  VARCHAR2,
    P_SEEDED_FLAG                IN  VARCHAR2,
    X_CHK_RULES_Rec		   OUT NOCOPY CHK_RULES_Rec_Type
    )
IS
BEGIN
   X_CHK_RULES_rec.CHECK_ID := P_CHECK_ID;
   X_CHK_RULES_rec.BLOCK_ID := P_BLOCK_ID;
   X_CHK_RULES_rec.SEQUENCE := P_SEQUENCE;
   X_CHK_RULES_rec.LOGICAL_OPERATOR := P_LOGICAL_OPERATOR;
   X_CHK_RULES_rec.LEFT_PAREN := P_LEFT_PAREN;
   X_CHK_RULES_rec.COMPARISON_OPERATOR := P_COMPARISON_OPERATOR;
   X_CHK_RULES_rec.EXPRESSION := P_EXPRESSION;
   X_CHK_RULES_rec.EXPR_TO_BLOCK_ID := P_EXPR_TO_BLOCK_ID;
   X_CHK_RULES_rec.RIGHT_PAREN := P_RIGHT_PAREN;
   X_CHK_RULES_rec.CREATED_BY := P_CREATED_BY;
   X_CHK_RULES_rec.CREATION_DATE := P_CREATION_DATE;
   X_CHK_RULES_rec.LAST_UPDATED_BY := P_LAST_UPDATED_BY;
   X_CHK_RULES_rec.LAST_UPDATE_DATE := P_LAST_UPDATE_DATE;
   X_CHK_RULES_rec.LAST_UPDATE_LOGIN := P_LAST_UPDATE_LOGIN;
   X_CHK_RULES_rec.SEEDED_FLAG := P_SEEDED_FLAG;
END;

PROCEDURE Create_profile_check_rules(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    P_CHECK_ID     		   IN  NUMBER,
    P_BLOCK_ID     		   IN  NUMBER,
    P_SEQUENCE                   IN  NUMBER,
    P_CREATED_BY                 IN  NUMBER,
    P_CREATION_DATE              IN  DATE,
    P_LAST_UPDATED_BY            IN  NUMBER,
    P_LAST_UPDATE_DATE           IN  DATE,
    P_LAST_UPDATE_LOGIN          IN  NUMBER,
    P_LOGICAL_OPERATOR           IN  VARCHAR2,
    P_LEFT_PAREN                 IN  VARCHAR2,
    P_COMPARISON_OPERATOR        IN  VARCHAR2,
    P_EXPRESSION                 IN  VARCHAR2,
    P_EXPR_TO_BLOCK_ID           IN  NUMBER,
    P_RIGHT_PAREN                IN  VARCHAR2,
    P_SEEDED_FLAG                IN  VARCHAR2,
    X_OBJECT_VERSION_NUMBER      OUT NOCOPY NUMBER,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    )
IS
l_CHK_RULES_Rec CHK_RULES_Rec_Type;
BEGIN

 Convert_Columns_to_Rec(
    P_CHECK_ID     	   => P_CHECK_ID,
    P_BLOCK_ID     	   => P_BLOCK_ID,
    P_SEQUENCE     	   => P_SEQUENCE,
    P_CREATED_BY   	   => P_CREATED_BY,
    P_CREATION_DATE    	   => P_CREATION_DATE,
    P_LAST_UPDATED_BY      => P_LAST_UPDATED_BY,
    P_LAST_UPDATE_DATE     => P_LAST_UPDATE_DATE,
    P_LAST_UPDATE_LOGIN    => P_LAST_UPDATE_LOGIN,
    P_LOGICAL_OPERATOR     => P_LOGICAL_OPERATOR,
    P_LEFT_PAREN           => P_LEFT_PAREN,
    P_COMPARISON_OPERATOR  => P_COMPARISON_OPERATOR,
    P_EXPRESSION           => P_EXPRESSION,
    P_EXPR_TO_BLOCK_ID     => P_EXPR_TO_BLOCK_ID,
    P_RIGHT_PAREN          => P_RIGHT_PAREN,
    P_SEEDED_FLAG          => P_SEEDED_FLAG,
    X_CHK_RULES_Rec	   => l_CHK_RULES_Rec
    );

 Create_profile_check_rules(
    P_Api_Version_Number    => P_Api_Version_Number ,
    P_Init_Msg_List         => P_Init_Msg_List,
    P_Commit                => P_Commit,
    P_CHK_RULES_Rec         => l_CHK_RULES_Rec,
    X_OBJECT_VERSION_NUMBER  => X_OBJECT_VERSION_NUMBER,
    X_Return_Status           => X_Return_Status,
    X_Msg_Count               => X_Msg_Count,
    X_Msg_Data                => X_Msg_Data
    );


END Create_profile_check_rules;

PROCEDURE Create_profile_check_rules(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    P_CHK_RULES_Rec              IN   CHK_RULES_Rec_Type,
    X_Object_Version_Number      OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Create_profile_check_rules';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_pvt_CHK_RULES_rec    CSC_PROFILE_CHECK_RULES_PVT.CHK_RULES_Rec_Type;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_PROFILE_CHECK_RULES_PUB;

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

      Convert_pub_to_pvt_Rec (
         P_chk_rules_Rec        => P_CHK_RULES_Rec,
         x_pvt_chk_rules_rec    => l_pvt_CHK_RULES_rec
      );

      CSC_profile_check_rules_PVT.Create_profile_check_rules(
      P_Api_Version_Number         => 1.0,
      P_Init_Msg_List              => p_Init_Msg_list,
      P_Commit                     => p_Commit,
      P_Validation_Level           => CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
      P_Chk_rules_Rec       	     => l_pvt_chk_rules_Rec,
      X_Object_Version_Number      => X_Object_Version_Number,
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
    		  ROLLBACK TO Create_profile_check_rules_PUB;
    		  x_return_status := FND_API.G_RET_STS_ERROR;
    		  FND_MSG_PUB.Count_And_Get(
      		 p_count => x_msg_count,
        		 p_data  => x_msg_data );
          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    		  ROLLBACK TO Create_profile_check_rules_PUB;
    		  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    		  FND_MSG_PUB.Count_And_Get(
      		 p_count => x_msg_count,
        		 p_data  => x_msg_data );
          WHEN OTHERS THEN
    		  ROLLBACK TO Create_profile_check_rules_PUB;
    		  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    		  FND_MSG_PUB.Count_And_Get(
      		 p_count => x_msg_count,
        		 p_data  => x_msg_data );

End Create_profile_check_rules;

PROCEDURE Update_profile_check_rules(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    P_CHECK_ID     		   IN  NUMBER,
    P_BLOCK_ID     		   IN  NUMBER,
    P_SEQUENCE                   IN  NUMBER,
    P_CREATED_BY                 IN  NUMBER,
    P_CREATION_DATE              IN  DATE,
    P_LAST_UPDATED_BY            IN  NUMBER,
    P_LAST_UPDATE_DATE           IN  DATE,
    P_LAST_UPDATE_LOGIN          IN  NUMBER,
    P_LOGICAL_OPERATOR           IN  VARCHAR2,
    P_LEFT_PAREN                 IN  VARCHAR2,
    P_COMPARISON_OPERATOR        IN  VARCHAR2,
    P_EXPRESSION                 IN  VARCHAR2,
    P_EXPR_TO_BLOCK_ID           IN  NUMBER,
    P_RIGHT_PAREN                IN  VARCHAR2,
    P_SEEDED_FLAG                IN  VARCHAR2,
    PX_OBJECT_VERSION_NUMBER     IN OUT NOCOPY NUMBER,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    )
IS
l_CHK_RULES_Rec CHK_RULES_Rec_Type;
BEGIN

 Convert_Columns_to_Rec(
    P_CHECK_ID     	   => P_CHECK_ID,
    P_BLOCK_ID     	   => P_BLOCK_ID,
    P_SEQUENCE     	   => P_SEQUENCE,
    P_CREATED_BY       	   => P_CREATED_BY,
    P_CREATION_DATE    	   => P_CREATION_DATE,
    P_LAST_UPDATED_BY      => P_LAST_UPDATED_BY,
    P_LAST_UPDATE_DATE     => P_LAST_UPDATE_DATE,
    P_LAST_UPDATE_LOGIN    => P_LAST_UPDATE_LOGIN,
    P_LOGICAL_OPERATOR     => P_LOGICAL_OPERATOR,
    P_LEFT_PAREN           => P_LEFT_PAREN,
    P_COMPARISON_OPERATOR  => P_COMPARISON_OPERATOR,
    P_EXPRESSION           => P_EXPRESSION,
    P_EXPR_TO_BLOCK_ID     => P_EXPR_TO_BLOCK_ID,
    P_RIGHT_PAREN          => P_RIGHT_PAREN,
    P_SEEDED_FLAG          => P_SEEDED_FLAG,
    X_CHK_RULES_Rec	   => l_CHK_RULES_Rec
    );

 Update_profile_check_rules(
    P_Api_Version_Number    => P_Api_Version_Number ,
    P_Init_Msg_List         => P_Init_Msg_List,
    P_Commit                => P_Commit,
    P_CHK_RULES_Rec         => l_CHK_RULES_Rec,
    PX_Object_Version_Number  => PX_OBJECT_VERSION_NUMBER,
    X_Return_Status           => X_Return_Status,
    X_Msg_Count               => X_Msg_Count,
    X_Msg_Data                => X_Msg_Data
    );

END Update_profile_check_rules;

PROCEDURE Update_profile_check_rules(
    P_Api_Version_Number         IN    NUMBER,
    P_Init_Msg_List              IN    VARCHAR2,
    P_Commit                     IN    VARCHAR2,
    P_CHK_RULES_Rec       	   IN    CHK_RULES_Rec_Type,
    px_OBJECT_VERSION_NUMBER     IN OUT NOCOPY NUMBER,
    X_Return_Status              OUT NOCOPY   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY   NUMBER,
    X_Msg_Data                   OUT NOCOPY   VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Update_profile_check_rules';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_pvt_CHK_RULES_rec  CSC_PROFILE_CHECK_RULES_PVT.CHK_RULES_Rec_Type;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_PROFILE_CHECK_RULES_PUB;

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
      Convert_pub_to_pvt_Rec (
         P_chk_rules_Rec        => P_CHK_RULES_Rec,
         x_pvt_chk_rules_rec    => l_pvt_CHK_RULES_rec
         );


    CSC_profile_check_rules_PVT.Update_profile_check_rules(
    P_Api_Version_Number      => P_Api_Version_Number ,
    P_Init_Msg_List           => P_Init_Msg_List,
    P_Commit                  => P_Commit,
    p_validation_level        => CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    P_CHK_RULES_Rec           => l_PVT_CHK_RULES_Rec,
    PX_Object_Version_Number  => PX_OBJECT_VERSION_NUMBER,
    X_Return_Status           => X_Return_Status,
    X_Msg_Count               => X_Msg_Count,
    X_Msg_Data                => X_Msg_Data
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
    		  ROLLBACK TO Update_profile_check_rules_PUB;
    		  x_return_status := FND_API.G_RET_STS_ERROR;
    		  FND_MSG_PUB.Count_And_Get(
      		 p_count => x_msg_count,
        		 p_data  => x_msg_data );
          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    		  ROLLBACK TO Update_profile_check_rules_PUB;
    		  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    		  FND_MSG_PUB.Count_And_Get(
      		 p_count => x_msg_count,
        		 p_data  => x_msg_data );
          WHEN OTHERS THEN
    		  ROLLBACK TO Update_profile_check_rules_PUB;
    		  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    		  FND_MSG_PUB.Count_And_Get(
      		 p_count => x_msg_count,
        		 p_data  => x_msg_data );

End Update_profile_check_rules;


PROCEDURE Delete_profile_check_rules(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    P_CHECK_ID			 IN   NUMBER,
    p_SEQUENCE                   IN   NUMBER,
    p_OBJECT_VERSION_NUMBER      IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Delete_profile_check_rules';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_pvt_CHK_RULES_rec  CSC_PROFILE_CHECK_RULES_PVT.CHK_RULES_Rec_Type;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_PROFILE_CHECK_RULES_PUB;

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


    CSC_profile_check_rules_PVT.Delete_profile_check_rules(
    P_Api_Version_Number         => 1.0,
    P_Init_Msg_List              => CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit                     => p_commit,
    P_Validation_Level           => CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    P_CHECK_ID			 => P_CHECK_ID,
    p_SEQUENCE                 => P_SEQUENCE,
    p_OBJECT_VERSION_NUMBER    => p_OBJECT_VERSION_NUMBER,
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
    		  ROLLBACK TO Delete_profile_check_rules_PUB;
    		  x_return_status := FND_API.G_RET_STS_ERROR;
    		  FND_MSG_PUB.Count_And_Get(
      		 p_count => x_msg_count,
        		 p_data  => x_msg_data );
          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    		  ROLLBACK TO Delete_profile_check_rules_PUB;
    		  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    		  FND_MSG_PUB.Count_And_Get(
      		 p_count => x_msg_count,
        		 p_data  => x_msg_data );
          WHEN OTHERS THEN
    		  ROLLBACK TO Delete_profile_check_rules_PUB;
    		  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    		  FND_MSG_PUB.Count_And_Get(
      		 p_count => x_msg_count,
        		 p_data  => x_msg_data );

End Delete_profile_check_rules;



End CSC_PROFILE_CHECK_RULES_PUB;

/
