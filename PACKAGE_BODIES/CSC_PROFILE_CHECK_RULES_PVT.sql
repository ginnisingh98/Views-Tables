--------------------------------------------------------
--  DDL for Package Body CSC_PROFILE_CHECK_RULES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSC_PROFILE_CHECK_RULES_PVT" as
/* $Header: cscvpcrb.pls 115.13 2002/12/03 17:57:22 jamose ship $ */
-- Start of Comments
-- Package name     : CSC_PROFILE_CHECK_RULES_PVT
-- Purpose          :
-- History          :26 Nov 02 jamose made changes for the NOCOPY and FND_API.G_MISS*
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSC_PROFILE_CHECK_RULES_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'cscvucrb.pls';

PROCEDURE Convert_Columns_to_Rec(
    P_CHECK_ID     		 IN  NUMBER,
    P_BLOCK_ID     		 IN  NUMBER,
    P_SEQUENCE           IN  NUMBER,
    P_CREATED_BY         IN  NUMBER,
    P_CREATION_DATE      IN  DATE,
    P_LAST_UPDATED_BY    IN  NUMBER,
    P_LAST_UPDATE_DATE   IN  DATE,
    P_LAST_UPDATE_LOGIN  IN  NUMBER,
    P_LOGICAL_OPERATOR   IN  VARCHAR2,
    P_LEFT_PAREN         IN  VARCHAR2,
    P_COMPARISON_OPERATOR  IN  VARCHAR2,
    P_EXPRESSION           IN  VARCHAR2,
    P_EXPR_TO_BLOCK_ID     IN  NUMBER,
    P_RIGHT_PAREN          IN  VARCHAR2,
    P_SEEDED_FLAG          IN  VARCHAR2,
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
   X_CHK_RULES_rec.SEEDED_FLAG := P_SEEDED_FLAG;
   X_CHK_RULES_rec.CREATED_BY := P_CREATED_BY;
   X_CHK_RULES_rec.CREATION_DATE := P_CREATION_DATE;
   X_CHK_RULES_rec.LAST_UPDATED_BY := P_LAST_UPDATED_BY;
   X_CHK_RULES_rec.LAST_UPDATE_DATE := P_LAST_UPDATE_DATE;
   X_CHK_RULES_rec.LAST_UPDATE_LOGIN := P_LAST_UPDATE_LOGIN;

END;


PROCEDURE Create_profile_check_rules(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit                     IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level           IN   NUMBER       := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    P_CHECK_ID     		         IN  NUMBER,
    P_BLOCK_ID     		         IN  NUMBER,
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
    P_CHECK_ID         	   => P_CHECK_ID,
    P_BLOCK_ID     	   => P_BLOCK_ID,
    P_SEQUENCE     	   => P_SEQUENCE,
    P_CREATED_BY       	   => P_CREATED_BY,
    P_CREATION_DATE        => P_CREATION_DATE,
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
    p_validation_level      => p_validation_level,
    P_CHK_RULES_Rec         => l_CHK_RULES_Rec,
    X_OBJECT_VERSION_NUMBER  => X_OBJECT_VERSION_NUMBER,
    X_Return_Status           => X_Return_Status,
    X_Msg_Count               => X_Msg_Count,
    X_Msg_Data                => X_Msg_Data
    );


END Create_profile_check_rules;

PROCEDURE Create_profile_check_rules(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit                     IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level           IN   NUMBER       := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    P_CHK_RULES_Rec              IN   CHK_RULES_Rec_Type  := G_MISS_CHK_RULES_REC,
    X_Object_Version_Number      OUT NOCOPY NUMBER,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    )
 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Create_profile_check_rules';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_return_status        VARCHAR2(1);

-- local record type
l_chk_rules_rec	CHK_RULES_REC_TYPE := P_CHK_RULES_Rec;
l_check_id Number;

BEGIN

      -- Standard Start of API savepoint
      SAVEPOINT CREATE_PROFILE_CHECK_RULES_PVT;


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
          Validate_profile_check_rules(
	     p_api_name	  => l_api_name,
             p_init_msg_list    => CSC_CORE_UTILS_PVT.G_FALSE,
             p_validation_level => p_validation_level,
             p_validation_mode  => CSC_CORE_UTILS_PVT.G_CREATE,
	     P_CHK_RULES_Rec  => p_CHK_RULES_Rec,
             x_return_status    => x_return_status,
             x_msg_count        => x_msg_count,
             x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Invoke table handler(CSC_PROF_CHECK_RULES_PKG.Insert_Row)

      CSC_PROFILE_CHECK_RULES_PKG.Insert_Row(
          p_CHECK_ID  		=> l_CHK_RULES_rec.CHECK_ID,
          p_SEQUENCE  		=> l_CHK_RULES_rec.SEQUENCE,
          p_CREATED_BY  	=> FND_GLOBAL.USER_ID,
          p_CREATION_DATE  	=> SYSDATE,
          p_LAST_UPDATED_BY  	=> FND_GLOBAL.USER_ID,
          p_LAST_UPDATE_DATE  	=> SYSDATE,
          p_LAST_UPDATE_LOGIN  	=> FND_GLOBAL.CONC_LOGIN_ID,
          p_LOGICAL_OPERATOR  	=> l_CHK_RULES_rec.LOGICAL_OPERATOR,
          p_LEFT_PAREN  	=> l_CHK_RULES_rec.LEFT_PAREN,
          p_BLOCK_ID  		=> l_CHK_RULES_rec.BLOCK_ID,
          p_COMPARISON_OPERATOR => l_CHK_RULES_rec.COMPARISON_OPERATOR,
          p_EXPRESSION  	=> l_CHK_RULES_rec.EXPRESSION,
          p_EXPR_TO_BLOCK_ID  	=> l_CHK_RULES_rec.EXPR_TO_BLOCK_ID,
          p_RIGHT_PAREN  	=> l_CHK_RULES_rec.RIGHT_PAREN,
          p_SEEDED_FLAG         => l_CHK_RULES_rec.SEEDED_FLAG,
          x_OBJECT_VERSION_NUMBER => X_OBJECT_VERSION_NUMBER);

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
    		  ROLLBACK TO Create_profile_check_rules_PVT;
    		  x_return_status := FND_API.G_RET_STS_ERROR;
    		  FND_MSG_PUB.Count_And_Get(
      		 p_count => x_msg_count,
        		 p_data  => x_msg_data );
              APP_EXCEPTION.RAISE_EXCEPTION;
          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    		  ROLLBACK TO Create_profile_check_rules_PVT;
    		  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    		  FND_MSG_PUB.Count_And_Get(
      		 p_count => x_msg_count,
        		 p_data  => x_msg_data );
              APP_EXCEPTION.RAISE_EXCEPTION;
          WHEN OTHERS THEN
    		  ROLLBACK TO Create_profile_check_rules_PVT;
    		  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    		  FND_MSG_PUB.Count_And_Get(
      		 p_count => x_msg_count,
        		 p_data  => x_msg_data );
		  FND_MSG_PUB.Build_Exc_Msg;
              APP_EXCEPTION.RAISE_EXCEPTION;

End Create_profile_check_rules;



PROCEDURE Update_profile_check_rules(
    P_Api_Version_Number         IN  NUMBER,
    P_Init_Msg_List              IN  VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit                     IN  VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level           IN  NUMBER       := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    P_CHECK_ID     		         IN  NUMBER,
    P_BLOCK_ID     		         IN  NUMBER,
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

 Update_profile_check_rules(
    P_Api_Version_Number    => P_Api_Version_Number ,
    P_Init_Msg_List         => P_Init_Msg_List,
    P_Commit                => P_Commit,
    p_validation_level      => p_validation_level,
    P_CHK_RULES_Rec         => l_CHK_RULES_Rec,
    PX_Object_Version_Number  => PX_OBJECT_VERSION_NUMBER,
    X_Return_Status           => X_Return_Status,
    X_Msg_Count               => X_Msg_Count,
    X_Msg_Data                => X_Msg_Data
    );


END Update_profile_check_rules;


PROCEDURE Update_profile_check_rules(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit                     IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level           IN  NUMBER       := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    P_CHK_RULES_Rec       IN    CHK_RULES_Rec_Type  := G_MISS_CHK_RULES_REC,
    PX_OBJECT_VERSION_NUMBER    IN OUT NOCOPY NUMBER,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    )

 IS

Cursor C_Get_profile_check_rules(c_CHECK_ID NUMBER,c_sequence NUMBER,c_object_version_number NUMBER) IS
    Select rowid,
           CHECK_ID,
           SEQUENCE,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           LOGICAL_OPERATOR,
           LEFT_PAREN,
           BLOCK_ID,
           COMPARISON_OPERATOR,
           EXPRESSION,
           EXPR_TO_BLOCK_ID,
           RIGHT_PAREN
    From  CSC_PROF_CHECK_RULES_VL
    Where check_id = c_check_id
    and sequence = c_sequence
    and object_version_number = c_object_version_number
    For Update NOWAIT;
l_api_name                CONSTANT VARCHAR2(30) := 'Update_profile_check_rules';
l_api_version_number      CONSTANT NUMBER   := 1.0;
-- Local Variables
l_rowid  ROWID;

--local record type
l_old_CHK_RULES_rec CHK_RULES_Rec_Type := G_MISS_CHK_RULES_REC;

l_CHK_RULES_rec CHK_RULES_Rec_Type := P_CHK_RULES_Rec;

 BEGIN

      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_PROFILE_CHECK_RULES_PVT;

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

      Open C_Get_profile_check_rules( l_CHK_RULES_REC.CHECK_ID,l_CHK_RULES_REC.SEQUENCE,px_Object_Version_Number);

      Fetch C_Get_profile_check_rules into
               l_rowid,
               l_old_CHK_RULES_rec.CHECK_ID,
               l_old_CHK_RULES_rec.SEQUENCE,
               l_old_CHK_RULES_rec.CREATED_BY,
               l_old_CHK_RULES_rec.CREATION_DATE,
               l_old_CHK_RULES_rec.LAST_UPDATED_BY,
               l_old_CHK_RULES_rec.LAST_UPDATE_DATE,
               l_old_CHK_RULES_rec.LAST_UPDATE_LOGIN,
               l_old_CHK_RULES_rec.LOGICAL_OPERATOR,
               l_old_CHK_RULES_rec.LEFT_PAREN,
               l_old_CHK_RULES_rec.BLOCK_ID,
               l_old_CHK_RULES_rec.COMPARISON_OPERATOR,
               l_old_CHK_RULES_rec.EXPRESSION,
               l_old_CHK_RULES_rec.EXPR_TO_BLOCK_ID,
               l_old_CHK_RULES_rec.RIGHT_PAREN;

       If ( C_Get_profile_check_rules%NOTFOUND) Then
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
		   CSC_CORE_UTILS_PVT.Record_Is_Locked_Msg(p_api_name => l_api_name);
           END IF;
           raise FND_API.G_EXC_ERROR;
       END IF;


      IF ( P_validation_level >= CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL)
      THEN
	    -- bug 1231208 -- > Validation mode should be UPDATE here
          -- Invoke validation procedures
          Validate_profile_check_rules(
		  p_api_name	  => l_api_name,
                  p_init_msg_list    => CSC_CORE_UTILS_PVT.G_FALSE,
                  p_validation_level => p_validation_level,
                  --p_validation_mode  => CSC_CORE_UTILS_PVT.G_CREATE,
                  p_validation_mode  => CSC_CORE_UTILS_PVT.G_UPDATE,
		  P_CHK_RULES_Rec  => p_CHK_RULES_Rec,
                  x_return_status    => x_return_status,
                  x_msg_count        => x_msg_count,
                  x_msg_data         => x_msg_data);


      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Invoke table handler(CSC_PROF_CHECK_RULES_PKG.Update_Row)
      CSC_PROFILE_CHECK_RULES_PKG.Update_Row(
          p_CHECK_ID  => csc_core_utils_pvt.get_g_miss_num(l_CHK_RULES_rec.CHECK_ID,l_old_CHK_RULES_rec.CHECK_ID),
          p_SEQUENCE  => csc_core_utils_pvt.get_g_miss_num(l_CHK_RULES_rec.SEQUENCE,l_old_CHK_RULES_rec.SEQUENCE),
          p_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID,
          p_LAST_UPDATE_DATE  => SYSDATE,
          p_LAST_UPDATE_LOGIN  => FND_GLOBAL.CONC_LOGIN_ID,
          p_LOGICAL_OPERATOR  =>csc_core_utils_pvt.get_g_miss_char(l_CHK_RULES_rec.LOGICAL_OPERATOR,l_old_CHK_RULES_rec.LOGICAL_OPERATOR),
          p_LEFT_PAREN  => csc_core_utils_pvt.get_g_miss_char(l_CHK_RULES_rec.LEFT_PAREN,l_old_CHK_RULES_rec.LEFT_PAREN),
          p_BLOCK_ID  => csc_core_utils_pvt.get_g_miss_num(l_CHK_RULES_rec.BLOCK_ID,l_old_CHK_RULES_rec.BLOCK_ID),
          p_COMPARISON_OPERATOR  =>csc_core_utils_pvt.get_g_miss_char(l_CHK_RULES_rec.COMPARISON_OPERATOR,l_old_CHK_RULES_rec.COMPARISON_OPERATOR),
          p_EXPRESSION  => csc_core_utils_pvt.get_g_miss_char(l_CHK_RULES_rec.EXPRESSION,l_old_CHK_RULES_rec.EXPRESSION),
          p_EXPR_TO_BLOCK_ID  => csc_core_utils_pvt.get_g_miss_num(l_CHK_RULES_rec.EXPR_TO_BLOCK_ID,l_old_CHK_RULES_rec.EXPR_TO_BLOCK_ID),
          p_RIGHT_PAREN  => csc_core_utils_pvt.get_g_miss_char(l_CHK_RULES_rec.RIGHT_PAREN,l_old_CHK_RULES_rec.RIGHT_PAREN),
          p_SEEDED_FLAG  => csc_core_utils_pvt.get_g_miss_char(l_CHK_RULES_rec.SEEDED_FLAG,l_old_CHK_RULES_rec.SEEDED_FLAG),
          px_OBJECT_VERSION_NUMBER => px_OBJECT_VERSION_NUMBER );

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
    		  ROLLBACK TO Update_profile_check_rules_PVT;
    		  x_return_status := FND_API.G_RET_STS_ERROR;
    		  FND_MSG_PUB.Count_And_Get(
      		 p_count => x_msg_count,
        		 p_data  => x_msg_data );
              APP_EXCEPTION.RAISE_EXCEPTION;
          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    		  ROLLBACK TO Update_profile_check_rules_PVT;
    		  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    		  FND_MSG_PUB.Count_And_Get(
      		 p_count => x_msg_count,
        		 p_data  => x_msg_data );
              APP_EXCEPTION.RAISE_EXCEPTION;
          WHEN OTHERS THEN
    		  ROLLBACK TO Update_profile_check_rules_PVT;
    		  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    		  FND_MSG_PUB.Count_And_Get(
      		 p_count => x_msg_count,
        		 p_data  => x_msg_data );
		  FND_MSG_PUB.Build_Exc_Msg;
            APP_EXCEPTION.RAISE_EXCEPTION;
End Update_profile_check_rules;


PROCEDURE Delete_profile_check_rules(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit                     IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level           IN   NUMBER       := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    P_CHECK_ID			 IN   NUMBER,
    p_SEQUENCE                   IN   NUMBER,
    p_OBJECT_VERSION_NUMBER      IN   NUMBER,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Delete_profile_check_rules';
l_api_version_number      CONSTANT NUMBER   := 1.0;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_PROFILE_CHECK_RULES_PVT;

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

      -- Invoke table handler(CSC_PROF_CHECK_RULES_PKG.Delete_Row)

      CSC_PROFILE_CHECK_RULES_PKG.Delete_Row(p_CHECK_ID  => p_CHECK_ID,
                        p_SEQUENCE => p_SEQUENCE,
                        p_OBJECT_VERSION_NUMBER => p_OBJECT_VERSION_NUMBER );

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
    		  ROLLBACK TO Delete_profile_check_rules_PVT;
    		  x_return_status := FND_API.G_RET_STS_ERROR;
    		  FND_MSG_PUB.Count_And_Get(
      		 p_count => x_msg_count,
        		 p_data  => x_msg_data );
            APP_EXCEPTION.RAISE_EXCEPTION;
          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    		  ROLLBACK TO Delete_profile_check_rules_PVT;
    		  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    		  FND_MSG_PUB.Count_And_Get(
      		 p_count => x_msg_count,
        		 p_data  => x_msg_data );
            APP_EXCEPTION.RAISE_EXCEPTION;
          WHEN OTHERS THEN
    		  ROLLBACK TO Delete_profile_check_rules_PVT;
    		  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    		  FND_MSG_PUB.Count_And_Get(
      		 p_count => x_msg_count,
        		 p_data  => x_msg_data );
		  FND_MSG_PUB.Build_Exc_Msg;
            APP_EXCEPTION.RAISE_EXCEPTION;
End Delete_profile_check_rules;


-- Item-level validation procedures
PROCEDURE Validate_CHECK_ID (
    P_Api_Name		IN	VARCHAR2,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_CHECK_ID                IN   NUMBER,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    )
IS
Cursor C1 IS
 Select NULL
 From csc_prof_checks_b
 where check_id = p_check_id;
l_dummy NUMBER;
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- validate NOT NULL column
      IF(p_CHECK_ID is NULL)
      THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
	    CSC_CORE_UTILS_PVT.mandatory_arg_error(
		  p_Api_name => p_Api_Name,
		  p_Argument => 'p_CHECK_ID',
		  p_Argument_Value => p_CHECK_ID);

      END IF;

	 -- Correction for 1231208 --> The check id should be a valid
	 -- check id in csc_prof_checks_b - so %FOUND shoudl not raise
	 -- any  error
      IF(p_validation_mode = CSC_CORE_UTILS_PVT.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_CHECK_ID is not NULL and p_CHECK_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
	    IF p_CHECK_ID is not NULL and p_CHECK_ID <> CSC_CORE_UTILS_PVT.G_MISS_NUM
	    THEN
		Open C1;
		Fetch C1 INTO l_dummy;
		--IF C1%FOUND THEN
		IF C1%NOTFOUND THEN
			--Changed as % found is valid and %notfound
				 -- is error in this case
              x_return_status := FND_API.G_RET_STS_ERROR;
              CSC_CORE_UTILS_PVT.Add_Invalid_Argument_Msg (
	            p_Api_Name => p_Api_Name,
	            p_Argument 	=> 'p_CHECK_ID',
 	            p_Argument_Value => to_char(p_CHECK_ID));
		END IF;
		Close C1;
	    END IF;
      ELSIF(p_validation_mode = CSC_CORE_UTILS_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_CHECK_ID <> CSC_CORE_UTILS_PVT.G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
	    IF p_CHECK_ID <> CSC_CORE_UTILS_PVT.G_MISS_NUM
	    THEN
		--** update not allowed
            NULL;
	    END IF;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_CHECK_ID;


PROCEDURE Validate_SEQUENCE (
    P_Api_Name		IN	VARCHAR2,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_SEQUENCE                IN   NUMBER,
    p_check_id			IN	NUMBER,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    )
IS
Cursor C1 is
 Select NULL
 From csc_prof_check_rules_b
 Where check_id = p_Check_id
 And sequence = p_sequence;
l_dummy varchar2(30);
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- validate NOT NULL column
      IF(p_SEQUENCE is NULL)
      THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
	    CSC_CORE_UTILS_PVT.mandatory_arg_error(
		  p_Api_name => p_Api_Name,
		  p_Argument => 'p_SEQUENCE',
		  p_Argument_Value => p_SEQUENCE);

      END IF;

      IF(p_validation_mode = CSC_CORE_UTILS_PVT.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_SEQUENCE is not NULL and p_SEQUENCE <> CSC_CORE_UTILS_PVT.G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;

	    IF p_SEQUENCE <> CSC_CORE_UTILS_PVT.G_MISS_NUM
	    THEN
	      Open C1;
 		 Fetch C1 into l_dummy;
		 IF C1%FOUND THEN
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    CSC_CORE_UTILS_PVT.Add_Invalid_Argument_Msg (
	                     p_Api_Name => p_Api_Name,
	                     p_Argument 	=> 'p_CHECK_ID',
 	                     p_Argument_Value => to_char(p_CHECK_ID));
		 END IF;
	      Close C1;
          END IF;
      ELSIF(p_validation_mode = CSC_CORE_UTILS_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_SEQUENCE <> CSC_CORE_UTILS_PVT.G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
	    IF p_SEQUENCE <> CSC_CORE_UTILS_PVT.G_MISS_NUM
	    THEN
		--**cannot update sequence as part of pk
          NULL;
	    END IF;
      END IF;

END Validate_SEQUENCE;


PROCEDURE Validate_EXPR_TO_BLOCK_ID (
    P_Api_Name		IN	VARCHAR2,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_EXPR_TO_BLOCK_ID                IN   NUMBER,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    )
IS
   Cursor C1 is
    Select NULL
    From csc_prof_blocks_b
    Where block_id = p_expr_to_block_id;
l_dummy varchar2(30);
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
	    IF p_EXPR_TO_BLOCK_ID is not NULL and p_EXPR_TO_BLOCK_ID <> CSC_CORE_UTILS_PVT.G_MISS_NUM
	    THEN
		Open C1;
		Fetch C1 into l_dummy;
		IF C1%NOTFOUND THEN
                  x_return_status := FND_API.G_RET_STS_ERROR;
                  CSC_CORE_UTILS_PVT.Add_Invalid_Argument_Msg (
	                p_Api_Name => p_Api_Name,
	                p_Argument 	=> 'p_Expr_to_BLOCK_ID',
 	                p_Argument_Value => to_char(p_Expr_to_BLOCK_ID));
		END IF;
		Close C1;
             END IF;

      ELSIF(p_validation_mode = CSC_CORE_UTILS_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_BLOCK_ID <> CSC_CORE_UTILS_PVT.G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
	    IF p_EXPR_TO_BLOCK_ID <> CSC_CORE_UTILS_PVT.G_MISS_NUM THEN
		Open C1;
		Fetch C1 into l_dummy;
		IF C1%NOTFOUND THEN
                 x_return_status := FND_API.G_RET_STS_ERROR;
                 CSC_CORE_UTILS_PVT.Add_Invalid_Argument_Msg (
	              p_Api_Name  => p_Api_Name,
	              p_Argument  => 'p_EXPR_To_BLOCK_ID',
 	              p_Argument_Value => to_char(p_EXPR_TO_BLOCK_ID));
		END IF;
		Close C1;
	    END IF;
          NULL;
      END IF;

END Validate_Expr_to_Block_Id;



PROCEDURE Validate_BLOCK_ID (
    P_Api_Name		IN	VARCHAR2,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_BLOCK_ID                IN   NUMBER,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    )
IS
    Cursor C1 is
    Select NULL
    From csc_prof_blocks_b
    Where block_id = p_block_id;
l_dummy varchar2(30);
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- validate NOT NULL column
      IF(p_BLOCK_ID is NULL)
      THEN
	    --mandatory arg error
          x_return_status := FND_API.G_RET_STS_ERROR;
          CSC_CORE_UTILS_PVT.mandatory_arg_error(
		  p_Api_name => p_Api_Name,
		  p_Argument => 'p_BLOCK_ID',
		  p_Argument_Value => p_BLOCK_ID);

      END IF;

      IF(p_validation_mode = CSC_CORE_UTILS_PVT.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_BLOCK_ID is not NULL and p_BLOCK_ID <> CSC_CORE_UTILS_PVT.G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
	    IF p_BLOCK_ID is not NULL and p_BLOCK_ID <> CSC_CORE_UTILS_PVT.G_MISS_NUM
	    THEN
		Open C1;
		Fetch C1 into l_dummy;
		IF C1%NOTFOUND THEN
              x_return_status := FND_API.G_RET_STS_ERROR;
              CSC_CORE_UTILS_PVT.Add_Invalid_Argument_Msg (
	            p_Api_Name => p_Api_Name,
	            p_Argument 	=> 'p_BLOCK_ID',
 	            p_Argument_Value => to_char(p_BLOCK_ID));
		END IF;
		Close C1;
	    ELSE
		   x_return_status := FND_API.G_RET_STS_ERROR;
	        CSC_CORE_UTILS_PVT.mandatory_arg_error(
		           p_Api_name => p_Api_Name,
		           p_Argument => 'p_BLOCK_ID',
		           p_Argument_Value => p_BLOCK_ID);
	    END IF;

      ELSIF(p_validation_mode = CSC_CORE_UTILS_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_BLOCK_ID <> CSC_CORE_UTILS_PVT.G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
	    IF p_BLOCK_ID <> CSC_CORE_UTILS_PVT.G_MISS_NUM THEN
		Open C1;
		Fetch C1 into l_dummy;
		IF C1%NOTFOUND THEN
              x_return_status := FND_API.G_RET_STS_ERROR;
              CSC_CORE_UTILS_PVT.Add_Invalid_Argument_Msg (
	            p_Api_Name => p_Api_Name,
	            p_Argument 	=> 'p_BLOCK_ID',
 	            p_Argument_Value => to_char(p_BLOCK_ID));
		END IF;
		Close C1;
	    END IF;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_BLOCK_ID;

/*
PROCEDURE build_rule(
    p_CHK_RULES_Tbl IN CHK_RULES_Tbl_Type,
    rule OUT NOCOPY VARCHAR2
    )
IS
BEGIN

     rule := 'SELECT 1 FROM dual WHERE';
     FOR i IN 1..p_Chk_Rules_Tbl.Count LOOP

       rule := rule || ' ' || p_Chk_Rules_Tbl(i).logical_operator || ' ' ||
	 p_Chk_Rules_Tbl(i).left_paren ||
	 'EXISTS (SELECT 1 FROM csc_prof_block_results_b WHERE block_id = ' ||
	 p_Chk_Rules_Tbl(i).block_id || ' AND customer_id = :customer_id' ||
	 ' AND value ' || p_Chk_Rules_Tbl(i).comparison_operator;
       IF (p_Chk_Rules_Tbl(i).comparison_operator NOT IN ('IS NULL', 'IS NOT NULL')) THEN
	  rule := rule || ' ' || p_Chk_Rules_Tbl(i).expression1;
	  IF (p_Chk_Rules_Tbl(i).comparison_operator IN ('BETWEEN', 'NOT BETWEEN')) THEN
	     rule := ' AND ' || p_Chk_Rules_Tbl(i).EXPR_TO_BLOCK_ID;
	  END IF;
       END IF;
       rule := rule || ')' || p_Chk_Rules_Tbl(i).right_paren;

     END LOOP;

END build_Rule;
*/

PROCEDURE validate_rule(
    p_Sql_Stmnt		IN	VARCHAR2,
    X_return_Status	OUT NOCOPY VARCHAR2
    )
IS
cursor_id NUMBER;
BEGIN
      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

	cursor_id := dbms_sql.open_cursor;
	dbms_sql.parse(cursor_id,p_Sql_Stmnt,dbms_Sql.native);
	dbms_sql.close_cursor(cursor_id);
   EXCEPTION
	WHEN OTHERS THEN
      IF (dbms_sql.is_open(cursor_id)) THEN
	  dbms_sql.close_cursor(cursor_id);
      END IF;
	x_return_status := FND_API.G_RET_STS_SUCCESS;
END;


/*
PROCEDURE Validate_CONDITION(
    P_Api_Name		IN	VARCHAR2,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    p_Chk_Rules_Tbl   IN CHK_RULES_Tbl_Type,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    )
 IS
l_condition VARCHAR2(2000);
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- build the rule using the table.
	build_rule(p_Chk_Rules_Tbl,l_condition);

	-- validate rule
	validate_rule(l_condition,x_Return_status);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END;
*/

PROCEDURE Validate_profile_check_rules(
    P_Api_Name		IN	VARCHAR2,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Validation_level           IN   NUMBER := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    P_Validation_mode            IN   VARCHAR2,
    P_CHK_RULES_Rec     IN    CHK_RULES_Rec_Type,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    )
IS
l_api_name   CONSTANT VARCHAR2(30) := 'Validate_profile_check_rules';
l_Sequence varchar2(10);
 BEGIN


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


          Validate_CHECK_ID(
		  p_api_name		=> p_api_name,
              p_init_msg_list          => CSC_CORE_UTILS_PVT.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_CHECK_ID   => p_chk_rules_rec.CHECK_ID,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_SEQUENCE(
	      p_api_name		=> p_api_name,
              p_init_msg_list          => CSC_CORE_UTILS_PVT.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_SEQUENCE   => P_CHK_RULES_Rec.SEQUENCE,
	      p_CHECK_ID	=> p_CHK_RULES_Rec.Check_Id,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;


          Validate_BLOCK_ID(
		  p_api_name		=> p_api_name,
              p_init_msg_list          => CSC_CORE_UTILS_PVT.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_BLOCK_ID   => p_Chk_rules_rec.BLOCK_ID,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;



          Validate_EXPR_TO_BLOCK_ID(
	      p_api_name		=> p_api_name,
              p_init_msg_list          => CSC_CORE_UTILS_PVT.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_EXPR_TO_BLOCK_ID   => p_Chk_rules_rec.Expr_TO_BLOCK_ID,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          --Validate seeded flag

          CSC_CORE_UTILS_PVT.Validate_Seeded_Flag(
           p_api_name        =>'CSC_PROF_CHECK_RULES_PVT.VALIDATE_SEEDED_FLAG',
           p_seeded_flag     => p_Chk_rules_rec.seeded_flag,
           x_return_status   => x_return_status );

           IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
              RAISE FND_API.G_EXC_ERROR;
           END IF;

/*
          Validate_CONDITION(
		  p_api_name		=> p_api_name,
              p_init_msg_list          => CSC_CORE_UTILS_PVT.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_CHK_RULES_Tbl   => P_CHK_RULES_Tbl,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;
*/

END Validate_profile_check_rules;

End CSC_PROFILE_CHECK_RULES_PVT;

/
