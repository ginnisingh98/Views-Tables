--------------------------------------------------------
--  DDL for Package Body CSC_GROUP_CHECKS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSC_GROUP_CHECKS_PVT" as
/* $Header: cscvpgcb.pls 120.1 2005/08/03 23:01:50 mmadhavi noship $ */
-- Start of Comments
-- Package name     : CSC_GROUP_CHECKS_PVT
-- Purpose          :
-- History          :
-- 27 Nov 02   jamose For Fnd_Api_G_Miss* and NOCOPY changes
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSC_GROUP_CHECKS_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'cscvugcb.pls';

PROCEDURE Convert_Columns_to_Rec(
    P_GROUP_ID                 IN     NUMBER ,
    P_CHECK_ID                 IN     NUMBER ,
    P_CHECK_SEQUENCE           IN     NUMBER ,
    P_END_DATE_ACTIVE          IN     DATE ,
    P_START_DATE_ACTIVE        IN     DATE ,
    P_CATEGORY_CODE            IN     VARCHAR2,
    P_CATEGORY_SEQUENCE        IN     NUMBER ,
    P_THRESHOLD_FLAG           IN     VARCHAR2,
    P_CRITICAL_FLAG            IN     VARCHAR2,
    P_SEEDED_FLAG              IN     VARCHAR2,
    P_CREATED_BY               IN     NUMBER,
    P_CREATION_DATE            IN     DATE ,
    P_LAST_UPDATED_BY          IN     NUMBER,
    P_LAST_UPDATE_DATE         IN     DATE ,
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
    X_GROUP_CHK_Rec.CRITICAL_FLAG         := P_CRITICAL_FLAG;
    X_GROUP_CHK_Rec.SEEDED_FLAG           := P_SEEDED_FLAG;
    X_GROUP_CHK_Rec.CREATED_BY            := P_CREATED_BY;
    X_GROUP_CHK_Rec.CREATION_DATE         := P_CREATION_DATE;
    X_GROUP_CHK_Rec.LAST_UPDATED_BY       := P_LAST_UPDATED_BY;
    X_GROUP_CHK_Rec.LAST_UPDATE_DATE      := P_LAST_UPDATE_DATE;
    X_GROUP_CHK_Rec.LAST_UPDATE_LOGIN     := P_LAST_UPDATE_LOGIN;
 END Convert_Columns_to_Rec;


PROCEDURE Create_group_checks(
    P_Api_Version_Number      IN   NUMBER,
    P_Init_Msg_List           IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit                  IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level        IN   NUMBER       := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    P_GROUP_ID                 IN     NUMBER ,
    P_CHECK_ID                 IN     NUMBER ,
    P_END_DATE_ACTIVE          IN     DATE ,
    P_START_DATE_ACTIVE        IN     DATE ,
    P_CATEGORY_CODE            IN     VARCHAR2 DEFAULT NULL ,
    P_CATEGORY_SEQUENCE        IN     NUMBER DEFAULT NULL,
    P_THRESHOLD_FLAG           IN     VARCHAR2 ,
    P_CRITICAL_FLAG            IN     VARCHAR2 ,
    P_SEEDED_FLAG              IN     VARCHAR2 ,
    P_CREATED_BY               IN     NUMBER ,
    P_CREATION_DATE            IN     DATE ,
    P_LAST_UPDATED_BY          IN     NUMBER,
    P_LAST_UPDATE_DATE         IN     DATE,
    P_LAST_UPDATE_LOGIN        IN     NUMBER ,
    P_Check_Sequence	      IN  NUMBER ,
    X_Return_Status           OUT NOCOPY VARCHAR2,
    X_Msg_Count               OUT NOCOPY NUMBER,
    X_Msg_Data                OUT NOCOPY VARCHAR2
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
    P_CRITICAL_FLAG           => P_CRITICAL_FLAG,
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
      P_Init_Msg_List              => p_Init_Msg_List,
      P_Commit                     => p_Commit,
      P_Validation_Level           => p_validation_level,
      P_GROUP_CHK_Rec     	     => l_Group_Chk_Rec,
	 --X_Check_Sequence             => p_Check_Sequence,
      X_Return_Status              => x_return_status,
      X_Msg_Count                  => x_msg_count,
      X_Msg_Data                   => x_msg_data);


 END Create_group_checks;


PROCEDURE Create_group_checks(
    P_Api_Version_Number      IN   NUMBER,
    P_Init_Msg_List           IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit                  IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level        IN   NUMBER       := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    P_GROUP_CHK_Rec     	IN   GROUP_CHK_Rec_Type,
    -- X_Check_Sequence	OUT NOCOPY	NUMBER,
    X_Return_Status           OUT NOCOPY VARCHAR2,
    X_Msg_Count               OUT NOCOPY NUMBER,
    X_Msg_Data                OUT NOCOPY VARCHAR2
    )
 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Create_group_checks';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_return_status_full        VARCHAR2(1);
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_GROUP_CHECKS_PVT;

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
          Validate_group_checks(
              p_init_msg_list    => CSC_CORE_UTILS_PVT.G_FALSE,
              p_validation_level => p_validation_level,
              p_validation_mode  => CSC_CORE_UTILS_PVT.G_CREATE,
              P_GROUP_CHK_Rec  =>  P_GROUP_CHK_Rec,
              x_return_status    => x_return_status,
              x_msg_count        => x_msg_count,
              x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Invoke table handler(CSC_PROF_GROUP_CHECKS_PKG.Insert_Row)
      CSC_PROF_GROUP_CHECKS_PKG.Insert_Row(
          p_GROUP_ID  => p_GROUP_CHK_rec.GROUP_ID,
          p_CHECK_ID  => p_GROUP_CHK_rec.CHECK_ID,
          P_CHECK_SEQUENCE  => p_GROUP_CHK_rec.CHECK_SEQUENCE,
          p_END_DATE_ACTIVE  => p_GROUP_CHK_rec.END_DATE_ACTIVE,
          p_START_DATE_ACTIVE  => p_GROUP_CHK_rec.START_DATE_ACTIVE,
          p_CATEGORY_CODE  => p_GROUP_CHK_rec.CATEGORY_CODE,
          p_CATEGORY_SEQUENCE  => p_GROUP_CHK_rec.CATEGORY_SEQUENCE,
          p_THRESHOLD_FLAG  => p_GROUP_CHK_rec.THRESHOLD_FLAG,
	  p_CRITICAL_FLAG  => p_GROUP_CHK_rec.CRITICAL_FLAG,
          p_SEEDED_FLAG     => p_GROUP_CHK_rec.SEEDED_FLAG,
          p_CREATED_BY  => FND_GLOBAL.USER_ID,
          p_CREATION_DATE  => SYSDATE,
          p_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID,
          p_LAST_UPDATE_DATE  => SYSDATE,
          p_LAST_UPDATE_LOGIN  => FND_GLOBAL.CONC_LOGIN_ID);

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
    		ROLLBACK TO Create_group_checks_PVT;
    		x_return_status := FND_API.G_RET_STS_ERROR;
    		FND_MSG_PUB.Count_And_Get
      			( p_count => x_msg_count,
        		  	  p_data  => x_msg_data
      			);
          APP_EXCEPTION.RAISE_EXCEPTION;
  	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    		ROLLBACK TO Create_group_checks_PVT;
    		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    		FND_MSG_PUB.Count_And_Get
      			( p_count => x_msg_count,
        		  	  p_data  => x_msg_data
      			);
          APP_EXCEPTION.RAISE_EXCEPTION;
  	WHEN OTHERS THEN
    		ROLLBACK TO Create_group_checks_PVT;
    		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      	FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    		FND_MSG_PUB.Count_And_Get
      			( p_count => x_msg_count,
        		  	  p_data  => x_msg_data
      			);
          APP_EXCEPTION.RAISE_EXCEPTION;
End Create_group_checks;


PROCEDURE Update_group_checks(
    P_Api_Version_Number      IN   NUMBER,
    P_Init_Msg_List           IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit                  IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level        IN   NUMBER       := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    P_GROUP_ID                 IN     NUMBER ,
    P_CHECK_ID                 IN     NUMBER ,
    P_CHECK_SEQUENCE           IN     NUMBER ,
    P_END_DATE_ACTIVE          IN     DATE ,
    P_START_DATE_ACTIVE        IN     DATE ,
    P_CATEGORY_CODE            IN     VARCHAR2 DEFAULT NULL,
    P_CATEGORY_SEQUENCE        IN     NUMBER DEFAULT NULL ,
    P_THRESHOLD_FLAG           IN     VARCHAR2,
    P_CRITICAL_FLAG            IN     VARCHAR2,
    P_SEEDED_FLAG              IN     VARCHAR2 DEFAULT NULL,
    P_CREATED_BY               IN     NUMBER DEFAULT NULL,
    P_CREATION_DATE            IN     DATE DEFAULT NULL,
    P_LAST_UPDATED_BY          IN     NUMBER,
    P_LAST_UPDATE_DATE         IN     DATE,
    P_LAST_UPDATE_LOGIN        IN     NUMBER,
    X_Return_Status           OUT NOCOPY VARCHAR2,
    X_Msg_Count               OUT NOCOPY NUMBER,
    X_Msg_Data                OUT NOCOPY VARCHAR2
    )
  IS
l_GROUP_CHK_REC GROUP_CHK_REC_TYPE;
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
    P_CRITICAL_FLAG           => P_CRITICAL_FLAG,
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
      P_Validation_Level           => CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
      P_GROUP_CHK_Rec     	     => l_Group_Chk_Rec,
      X_Return_Status              => x_return_status,
      X_Msg_Count                  => x_msg_count,
      X_Msg_Data                   => x_msg_data);


 END Update_group_checks;




PROCEDURE Update_group_checks(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit                     IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level           IN  NUMBER       := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    P_GROUP_CHK_Rec     IN    GROUP_CHK_Rec_Type,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    )

 IS

Cursor C_Get_group_checks(c_GROUP_ID Number, C_CHECK_ID NUMBER) IS
    Select rowid,
           GROUP_ID,
           CHECK_ID,
           CHECK_SEQUENCE,
           END_DATE_ACTIVE,
           START_DATE_ACTIVE,
           CATEGORY_CODE,
           CATEGORY_SEQUENCE,
           THRESHOLD_FLAG,
	   CRITICAL_FLAG,
           SEEDED_FLAG,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN
    From  CSC_PROF_GROUP_CHECKS
    Where GROUP_ID  = c_GROUP_ID
    And   CHECK_ID = c_CHECK_ID
    For Update NOWAIT;

l_api_name                CONSTANT VARCHAR2(30) := 'Update_group_checks';
l_api_version_number      CONSTANT NUMBER   := 1.0;
-- Local Variables
l_old_GROUP_CHK_rec  CSC_group_checks_PVT.GROUP_CHK_Rec_Type ;
l_rowid  ROWID;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_GROUP_CHECKS_PVT;

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

      Open C_Get_group_checks( p_group_chk_rec.GROUP_ID, p_group_chk_rec.CHECK_ID);

      Fetch C_Get_group_checks into
               l_rowid,
               l_old_GROUP_CHK_rec.GROUP_ID,
               l_old_GROUP_CHK_rec.CHECK_ID,
               l_old_GROUP_CHK_rec.CHECK_SEQUENCE,
               l_old_GROUP_CHK_rec.END_DATE_ACTIVE,
               l_old_GROUP_CHK_rec.START_DATE_ACTIVE,
               l_old_GROUP_CHK_rec.CATEGORY_CODE,
               l_old_GROUP_CHK_rec.CATEGORY_SEQUENCE,
               l_old_GROUP_CHK_rec.THRESHOLD_FLAG,
	       l_old_GROUP_CHK_rec.CRITICAL_FLAG,
               l_old_GROUP_CHK_rec.SEEDED_FLAG,
               l_old_GROUP_CHK_rec.CREATED_BY,
               l_old_GROUP_CHK_rec.CREATION_DATE,
               l_old_GROUP_CHK_rec.LAST_UPDATED_BY,
               l_old_GROUP_CHK_rec.LAST_UPDATE_DATE,
               l_old_GROUP_CHK_rec.LAST_UPDATE_LOGIN;

       If ( C_Get_group_checks%NOTFOUND) Then
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
              CSC_CORE_UTILS_PVT.RECORD_IS_LOCKED_MSG(p_api_name=>l_api_name);
               --FND_MESSAGE.Set_Name('CSC', 'API_MISSING_UPDATE_TARGET');
               --FND_MESSAGE.Set_Token ('INFO', 'CSC_PROF_GROUP_CHECKS', FALSE);
               --FND_MSG_PUB.Add;
           END IF;
           raise FND_API.G_EXC_ERROR;
       END IF;

      IF ( P_validation_level >= CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL)
      THEN

          -- Invoke validation procedures
          Validate_group_checks(
              p_init_msg_list    => CSC_CORE_UTILS_PVT.G_FALSE,
              p_validation_level => p_validation_level,
              p_validation_mode  => CSC_CORE_UTILS_PVT.G_UPDATE,
              P_GROUP_CHK_Rec  =>  P_GROUP_CHK_rec,
              x_return_status    => x_return_status,
              x_msg_count        => x_msg_count,
              x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
      -- Invoke table handler(CSC_PROF_GROUP_CHECKS_PKG.Update_Row)
      CSC_PROF_GROUP_CHECKS_PKG.Update_Row(
          p_GROUP_ID  =>csc_core_utils_pvt.Get_G_Miss_num(p_GROUP_CHK_rec.GROUP_ID,l_old_GROUP_CHK_rec.GROUP_ID),
          p_CHECK_ID  =>csc_core_utils_pvt.Get_G_Miss_num(p_GROUP_CHK_rec.CHECK_ID,l_old_GROUP_CHK_rec.CHECK_ID),
          p_CHECK_SEQUENCE  =>csc_core_utils_pvt.Get_G_Miss_num(p_GROUP_CHK_rec.CHECK_SEQUENCE,l_old_GROUP_CHK_rec.CHECK_SEQUENCE),
          p_END_DATE_ACTIVE  =>csc_core_utils_pvt.Get_G_Miss_Date(p_GROUP_CHK_rec.END_DATE_ACTIVE,l_old_GROUP_CHK_rec.END_DATE_ACTIVE),
          p_START_DATE_ACTIVE  =>csc_core_utils_pvt.Get_G_Miss_Date(p_GROUP_CHK_rec.START_DATE_ACTIVE,l_old_GROUP_CHK_rec.START_DATE_ACTIVE),
          p_CATEGORY_CODE  => csc_core_utils_pvt.Get_G_Miss_Char(p_GROUP_CHK_rec.CATEGORY_CODE,l_old_GROUP_CHK_rec.CATEGORY_CODE),
          p_CATEGORY_SEQUENCE  =>csc_core_utils_pvt.Get_G_Miss_num(p_GROUP_CHK_rec.CATEGORY_SEQUENCE,l_old_GROUP_CHK_rec.CATEGORY_SEQUENCE),
          p_THRESHOLD_FLAG  =>csc_core_utils_pvt.Get_G_Miss_Char(p_GROUP_CHK_rec.THRESHOLD_FLAG,l_old_GROUP_CHK_rec.THRESHOLD_FLAG),
	  p_CRITICAL_FLAG  =>csc_core_utils_pvt.Get_G_Miss_Char(p_GROUP_CHK_rec.CRITICAL_FLAG,l_old_GROUP_CHK_rec.CRITICAL_FLAG),
          p_SEEDED_FLAG     =>csc_core_utils_pvt.Get_G_Miss_Char(p_GROUP_CHK_rec.SEEDED_FLAG,l_old_GROUP_CHK_rec.SEEDED_FLAG),
          p_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID,
          p_LAST_UPDATE_DATE  => SYSDATE,
          p_LAST_UPDATE_LOGIN  => FND_GLOBAL.CONC_LOGIN_ID);

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
    		ROLLBACK TO Update_group_checks_PVT;
    		x_return_status := FND_API.G_RET_STS_ERROR;
    		FND_MSG_PUB.Count_And_Get
      			( p_count => x_msg_count,
        		  	  p_data  => x_msg_data
      			);
          APP_EXCEPTION.RAISE_EXCEPTION;
  	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    		ROLLBACK TO Update_group_checks_PVT;
    		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    		FND_MSG_PUB.Count_And_Get
      			( p_count => x_msg_count,
        		  	  p_data  => x_msg_data
      			);
          APP_EXCEPTION.RAISE_EXCEPTION;
  	WHEN OTHERS THEN
    		ROLLBACK TO Update_group_checks_PVT;
    		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      	FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    		FND_MSG_PUB.Count_And_Get
      			( p_count => x_msg_count,
        		  	  p_data  => x_msg_data
      			);
          APP_EXCEPTION.RAISE_EXCEPTION;
End Update_group_checks;


PROCEDURE Delete_group_checks(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit                     IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level           IN   NUMBER       := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    P_GROUP_ID     		   IN   NUMBER,
    P_CHECK_ID			   IN   NUMBER,
    P_CHECK_SEQUENCE			   IN   NUMBER,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    )
 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Delete_group_checks';
l_api_version_number      CONSTANT NUMBER   := 1.0;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_GROUP_CHECKS_PVT;

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

      -- Invoke table handler(CSC_PROF_GROUP_CHECKS_PKG.Delete_Row)
       CSC_PROF_GROUP_CHECKS_PKG.Delete_Row(
           p_GROUP_ID  => p_GROUP_ID,
	     P_CHECK_ID  => P_CHECK_ID,
	     p_CHECK_SEQUENCE  => p_CHECK_SEQUENCE );
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
    		ROLLBACK TO Delete_group_checks_PVT;
    		x_return_status := FND_API.G_RET_STS_ERROR;
    		FND_MSG_PUB.Count_And_Get
      			( p_count => x_msg_count,
        		  	  p_data  => x_msg_data
      			);
          APP_EXCEPTION.RAISE_EXCEPTION;
  	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    		ROLLBACK TO Delete_group_checks_PVT;
    		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    		FND_MSG_PUB.Count_And_Get
      			( p_count => x_msg_count,
        		  	  p_data  => x_msg_data
      			);
          APP_EXCEPTION.RAISE_EXCEPTION;
  	WHEN OTHERS THEN
    		ROLLBACK TO Delete_group_checks_PVT;
    		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      	FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    		FND_MSG_PUB.Count_And_Get
      			( p_count => x_msg_count,
        		  	  p_data  => x_msg_data
      			);
          APP_EXCEPTION.RAISE_EXCEPTION;
End Delete_group_checks;


-- Item-level validation procedures
PROCEDURE Validate_GROUP_ID (
    P_Api_Name		IN	VARCHAR2,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_GROUP_ID                IN   NUMBER,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    )
IS
CURSOR C1 IS SELECT NULL
		 FROM csc_prof_groups_b
		 WHERE group_id = p_GROUP_ID;
l_dummy number;
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
          -- IF p_GROUP_ID is not NULL and p_GROUP_ID <> CSC_CORE_UTILS_PVT.G_MISS_CHAR
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
			            p_argument  => p_GROUP_ID);
		END IF;
		Close C1;
	    END IF;
      ELSIF(p_validation_mode = CSC_CORE_UTILS_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_GROUP_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
	    IF p_GROUP_ID <> CSC_CORE_UTILS_PVT.G_MISS_NUM THEN
		Open C1;
		Fetch C1 into l_dummy;
		IF C1%NOTFOUND THEN
        	   x_return_status := FND_API.G_RET_STS_ERROR;
        	   CSC_CORE_UTILS_PVT.Add_Invalid_Argument_Msg(
					p_api_name => p_api_name,
			            p_argument_value  => p_GROUP_ID,
			            p_argument  => p_GROUP_ID);
		END IF;
		Close C1;
	    END IF;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_GROUP_ID;


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
CURSOR C1 IS SELECT NULL
		 FROM csc_prof_checks_b
		 WHERE check_id = p_CHECK_ID;
l_dummy number;
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
		   p_api_name => p_api_name,
		   p_argument => 'p_CHECK_ID',
		   p_argument_value => p_CHECK_ID);
      END IF;

      IF(p_validation_mode = CSC_CORE_UTILS_PVT.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_CHECK_ID is not NULL and p_CHECK_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
	    IF p_CHECK_ID is not NULL and p_CHECK_ID <> CSC_CORE_UTILS_PVT.G_MISS_NUM
	    THEN
		Open C1;
		Fetch C1 into l_dummy;
		IF C1%NOTFOUND THEN
        	   x_return_status := FND_API.G_RET_STS_ERROR;
        	   CSC_CORE_UTILS_PVT.Add_Invalid_Argument_Msg(
					p_api_name => p_api_name,
			            p_argument_value  => p_CHECK_ID,
			            p_argument  => p_CHECK_ID);
		END IF;
		Close C1;
	    END IF;
      ELSIF(p_validation_mode = CSC_CORE_UTILS_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_CHECK_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
	    IF p_CHECK_ID <> CSC_CORE_UTILS_PVT.G_MISS_NUM
 	    THEN
		Open C1;
		Fetch C1 into l_dummy;
		IF C1%NOTFOUND THEN
        	   x_return_status := FND_API.G_RET_STS_ERROR;
        	   CSC_CORE_UTILS_PVT.Add_Invalid_Argument_Msg(
					p_api_name => p_api_name,
			            p_argument_value  => p_CHECK_ID,
			            p_argument  => p_CHECK_ID);
		END IF;
		Close C1;
	    END IF;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_CHECK_ID;


PROCEDURE Validate_CHECK_SEQUENCE (
    P_Api_Name		IN	VARCHAR2,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_CHECK_SEQUENCE                IN   NUMBER,
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
      IF(p_CHECK_SEQUENCE is NULL)
      THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
	    CSC_CORE_UTILS_PVT.mandatory_arg_error(
		   p_api_name => p_api_name,
		   p_argument => 'p_CHECK_SEQUENCE',
		   p_argument_value => p_CHECK_SEQUENCE);
      END IF;

      IF(p_validation_mode = CSC_CORE_UTILS_PVT.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_CHECK_SEQUENCE is not NULL and p_CHECK_SEQUENCE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = CSC_CORE_UTILS_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_CHECK_SEQUENCE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_CHECK_SEQUENCE;



PROCEDURE Validate_CATEGORY_CODE (
    P_Api_Name		IN	VARCHAR2,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_CATEGORY_CODE                IN   VARCHAR2,
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

	NULL;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_CATEGORY_CODE;


PROCEDURE Validate_CATEGORY_SEQUENCE (
    P_Api_Name		IN	VARCHAR2,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_CHECK_ID			IN	NUMBER,
    P_CATEGORY_SEQUENCE                IN   NUMBER,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    )
IS
CURSOR C1 IS SELECT NULL
		 FROM csc_prof_group_Checks
		 WHERE check_id = p_CHECK_ID
		 AND category_sequence = p_CATEGORY_SEQUENCE;
l_dummy number;
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
	    IF p_CATEGORY_SEQUENCE <> CSC_CORE_UTILS_PVT.G_MISS_CHAR THEN
		Open C1;
		Fetch C1 into l_dummy;
		IF C1%FOUND THEN
        	   x_return_status := FND_API.G_RET_STS_ERROR;
	    	   CSC_CORE_UTILS_PVT.Add_Duplicate_Value_Msg(
		         p_api_name	=> p_api_name,
		         p_argument	=> 'p_CATEGORY_SEQUENCE' ,
  		         p_argument_value => p_CATEGORY_SEQUENCE);

		END IF;
		Close C1;
         END IF;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_CATEGORY_SEQUENCE;


PROCEDURE Validate_THRESHOLD_FLAG (
    P_Api_Name		IN	VARCHAR2,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_THRESHOLD_FLAG                IN   VARCHAR2,
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

	IF (p_THRESHOLD_FLAG IS NOT NULL) AND
	    (p_THRESHOLD_FLAG <> CSC_CORE_UTILS_PVT.G_MISS_CHAR)
	THEN
    	 IF CSC_CORE_UTILS_PVT.lookup_code_not_exists(
 		p_effective_date  => trunc(sysdate),
  		p_lookup_type     => 'YES_NO',
  		p_lookup_code     => p_THRESHOLD_FLAG ) <> FND_API.G_RET_STS_SUCCESS
    	 THEN
        	x_return_status := FND_API.G_RET_STS_ERROR;
        	CSC_CORE_UTILS_PVT.Add_Invalid_Argument_Msg(
					p_api_name => p_api_name,
			            p_argument_value  => p_THRESHOLD_FLAG,
			            p_argument  => 'p_THRESHOLD_FLAG');
       END IF;
	END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_THRESHOLD_FLAG;


PROCEDURE Validate_group_checks(
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Validation_level           IN   NUMBER := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    P_Validation_mode            IN   VARCHAR2,
    P_GROUP_CHK_Rec     IN    GROUP_CHK_Rec_Type,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    )
IS
p_api_name   CONSTANT VARCHAR2(30) := 'Validate_group_checks';
 BEGIN


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
          Validate_GROUP_ID(
		  p_api_name	=>	p_api_name,
              p_init_msg_list          => CSC_CORE_UTILS_PVT.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_GROUP_ID   => P_GROUP_CHK_REC.GROUP_ID,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;
/*
          Validate_CHECK_ID(
		  p_api_name	=>	p_api_name,
              p_init_msg_list          => CSC_CORE_UTILS_PVT.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_CHECK_ID   => P_GROUP_CHK_Rec.CHECK_ID,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;
		*/

          Validate_CHECK_SEQUENCE(
		  p_api_name	=>	p_api_name,
              p_init_msg_list          => CSC_CORE_UTILS_PVT.G_FALSE,
              p_validation_mode        => p_validation_mode,
		 --  p_CHECK_ID		=> P_GROUP_CHK_Rec.CHECK_ID,
              p_CHECK_SEQUENCE   => P_GROUP_CHK_Rec.CHECK_SEQUENCE,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          CSC_CORE_UTILS_PVT.Validate_Seeded_Flag(
           p_api_name        =>'CSC_PROF_GROUP_CHECKS_PVT.VALIDATE_SEEDED_FLAG',
           p_seeded_flag     => P_GROUP_CHK_Rec.seeded_flag,
           x_return_status   => x_return_status );

           IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
              RAISE FND_API.G_EXC_ERROR;
           END IF;
/*
          Validate_CATEGORY_CODE(
		  p_api_name	=>	p_api_name,
              p_init_msg_list          => CSC_CORE_UTILS_PVT.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_CATEGORY_CODE   => P_GROUP_CHK_Rec.CATEGORY_CODE,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

	    CSC_CORE_UTILS_PVT.Validate_Start_End_Dt(
		  p_api_name 		=> p_Api_name,
     		  p_start_date		=> P_GROUP_CHK_Rec.start_date_active,
     		  p_end_date		=> P_GROUP_CHK_Rec.end_date_active,
     		  x_return_status	=> x_return_status );
  	    IF x_return_status  <> FND_API.G_RET_STS_SUCCESS THEN
       	 raise FND_API.G_EXC_ERROR;
  	    END IF;

          Validate_CATEGORY_SEQUENCE(
		  p_api_name	=>	p_api_name,
              p_init_msg_list          => CSC_CORE_UTILS_PVT.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_CATEGORY_SEQUENCE   => P_GROUP_CHK_Rec.CATEGORY_SEQUENCE,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_THRESHOLD_FLAG(
		  p_api_name	=>	p_api_name,
              p_init_msg_list          => CSC_CORE_UTILS_PVT.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_THRESHOLD_FLAG   => P_GROUP_CHK_Rec.THRESHOLD_FLAG,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;
*/


END Validate_group_checks;

End CSC_GROUP_CHECKS_PVT;

/
