--------------------------------------------------------
--  DDL for Package Body CSC_PROFILE_CHECK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSC_PROFILE_CHECK_PVT" as
/* $Header: cscvpckb.pls 120.1.12010000.2 2009/07/20 09:47:01 spamujul ship $ */
-- Start of Comments
-- Package name     : CSC_PROFILE_CHECK_PVT
-- Purpose          :
-- History          : Sudhakar 08/17/00 modified validate_check_name,
--                     validate_check_code and validate_select_block_id
--                  : 11/25/02 JAmose for the G_MISS* and NOCOPY changes
--                  : for performance reason
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSC_PROFILE_CHECK_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'cscvpckb.pls';

G_UPDATE   CONSTANT VARCHAR2(30) := 'UPDATE';
G_CREATE   CONSTANT VARCHAR2(30) := 'CREATE';

PROCEDURE Convert_Columns_to_Rec(
   p_CHECK_ID			    IN   NUMBER DEFAULT NULL,
   p_CHECK_NAME          IN   VARCHAR2,
   p_CHECK_NAME_CODE     IN   VARCHAR2,
   p_DESCRIPTION         IN   VARCHAR2 ,
   p_START_DATE_ACTIVE   IN   DATE,
   p_END_DATE_ACTIVE     IN   DATE,
   p_SEEDED_FLAG         IN   VARCHAR2,
   p_SELECT_TYPE         IN   VARCHAR2,
   p_SELECT_BLOCK_ID     IN   NUMBER ,
   p_DATA_TYPE           IN   VARCHAR2,
   p_FORMAT_MASK             IN   VARCHAR2,
   p_THRESHOLD_GRADE         IN   VARCHAR2,
   p_THRESHOLD_RATING_CODE   IN   VARCHAR2,
   p_CHECK_UPPER_LOWER_FLAG  IN   VARCHAR2,
   p_THRESHOLD_COLOR_CODE    IN   VARCHAR2,
   p_CHECK_LEVEL             IN   VARCHAR2,
   p_CREATED_BY              IN   NUMBER ,
   p_CREATION_DATE           IN   DATE   ,
   p_LAST_UPDATED_BY         IN   NUMBER ,
   p_LAST_UPDATE_DATE        IN   DATE   ,
   p_LAST_UPDATE_LOGIN       IN   NUMBER ,
   p_OBJECT_VERSION_NUMBER   IN   NUMBER DEFAULT NULL,
   p_APPLICATION_ID          IN   NUMBER ,
   X_Check_Rec     		     OUT NOCOPY  Check_Rec_Type
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
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit                     IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level           IN   NUMBER       := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    p_CHECK_NAME                 IN   VARCHAR2 DEFAULT NULL,
    p_CHECK_NAME_CODE            IN   VARCHAR2 DEFAULT NULL,
    p_DESCRIPTION                IN   VARCHAR2 DEFAULT NULL,
    p_START_DATE_ACTIVE          IN   DATE DEFAULT NULL,
    p_END_DATE_ACTIVE            IN   DATE DEFAULT NULL,
    p_SEEDED_FLAG                IN   VARCHAR2 DEFAULT NULL,
    p_SELECT_TYPE                IN   VARCHAR2 DEFAULT NULL,
    p_SELECT_BLOCK_ID            IN   NUMBER DEFAULT NULL,
    p_DATA_TYPE                  IN   VARCHAR2 DEFAULT NULL,
    p_FORMAT_MASK                IN   VARCHAR2 DEFAULT NULL,
    p_THRESHOLD_GRADE            IN   VARCHAR2 DEFAULT NULL,
    p_THRESHOLD_RATING_CODE      IN   VARCHAR2 DEFAULT NULL,
    p_CHECK_UPPER_LOWER_FLAG     IN   VARCHAR2 DEFAULT NULL,
    p_THRESHOLD_COLOR_CODE       IN   VARCHAR2 DEFAULT NULL,
    p_CHECK_LEVEL                IN   VARCHAR2 DEFAULT NULL,
    p_CREATED_BY                 IN   NUMBER DEFAULT NULL,
    p_CREATION_DATE              IN   DATE DEFAULT NULL,
    p_LAST_UPDATED_BY            IN   NUMBER DEFAULT NULL,
    p_LAST_UPDATE_DATE           IN   DATE DEFAULT NULL,
    p_LAST_UPDATE_LOGIN          IN   NUMBER DEFAULT NULL,
    X_CHECK_ID     		   OUT NOCOPY NUMBER,
    X_Object_Version_Number OUT NOCOPY  NUMBER,
    p_APPLICATION_ID             IN   NUMBER  DEFAULT NULL,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2
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
    p_CREATED_BY              => p_CREATED_BY,
    p_CREATION_DATE           => p_CREATION_DATE,
    p_LAST_UPDATED_BY        => p_LAST_UPDATED_BY,
    p_LAST_UPDATE_DATE       => p_LAST_UPDATE_DATE,
    p_LAST_UPDATE_LOGIN      => p_LAST_UPDATE_LOGIN,
    p_APPLICATION_ID         => p_APPLICATION_ID,
    X_Check_Rec		     => l_Check_rec
    );


   Create_Profile_Check(
    P_Api_Version_Number         => P_Api_Version_Number,
    P_Init_Msg_List              => P_Init_Msg_List,
    P_Commit                     => P_Commit,
    p_validation_level           => p_validation_level,
    P_Check_Rec     		 => l_Check_Rec,
    X_CHECK_ID     		 => X_CHECK_ID,
    X_OBJECT_VERSION_NUMBER      => X_OBJECT_VERSION_NUMBER,
    X_Return_Status              => X_Return_Status,
    X_Msg_Count                  => X_Msg_Count,
    X_Msg_Data                   => X_Msg_Data
    );

END Create_Profile_Check;

PROCEDURE Create_Profile_Check(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit                     IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level           IN   NUMBER       := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    P_Check_Rec     		 IN   Check_Rec_Type := G_MISS_CHECK_REC,
    X_CHECK_ID     		 OUT  NOCOPY NUMBER,
    X_OBJECT_VERSION_NUMBER      OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    )

IS
   l_api_name                CONSTANT VARCHAR2(30) := 'Create_Profile_Check';
   l_api_version_number      CONSTANT NUMBER   := 1.0;
   l_api_name_full VARCHAR2(61) := G_PKG_NAME || '.' || l_api_name ;
BEGIN

      -- Standard Start of API savepoint
      SAVEPOINT CREATE_PROFILE_CHECK_PVT;

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


      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN

          -- Invoke validation procedures
          Validate_check(
              p_init_msg_list    => FND_API.G_FALSE,
              p_Validation_Level => p_Validation_Level,
              p_Validation_Mode  => CSC_CORE_UTILS_PVT.G_CREATE,
              p_CHECK_REC        => p_CHECK_REC,
              x_return_status    => x_return_status,
              x_msg_count        => x_msg_count,
              x_msg_data         => x_msg_data);
      END IF;
      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Invoke table handler(CSC_PROF_CHECKS_PKG.Insert_Row)
      CSC_PROF_CHECKS_PKG.Insert_Row(
          px_CHECK_ID             => x_CHECK_ID,
          p_CHECK_NAME            => p_Check_rec.CHECK_NAME,
          p_CHECK_NAME_CODE       => p_Check_rec.CHECK_NAME_CODE,
          p_DESCRIPTION           => p_Check_rec.DESCRIPTION,
          p_START_DATE_ACTIVE     => p_Check_rec.START_DATE_ACTIVE,
          p_END_DATE_ACTIVE       => p_Check_rec.END_DATE_ACTIVE,
          p_SEEDED_FLAG           => p_Check_rec.SEEDED_FLAG,
          p_SELECT_TYPE           => p_Check_rec.SELECT_TYPE,
          p_SELECT_BLOCK_ID       => p_Check_rec.SELECT_BLOCK_ID,
          p_DATA_TYPE             => p_Check_rec.DATA_TYPE,
          p_FORMAT_MASK           => p_Check_rec.FORMAT_MASK,
          p_THRESHOLD_GRADE       => p_Check_rec.THRESHOLD_GRADE,
          p_THRESHOLD_RATING_CODE => p_Check_rec.THRESHOLD_RATING_CODE,
          p_CHECK_UPPER_LOWER_FLAG => p_Check_rec.CHECK_UPPER_LOWER_FLAG,
          p_THRESHOLD_COLOR_CODE  => p_Check_rec.THRESHOLD_COLOR_CODE,
          p_CHECK_LEVEL           => p_Check_rec.CHECK_LEVEL,
          p_CREATED_BY            => FND_GLOBAL.USER_ID,
          p_CREATION_DATE         => SYSDATE,
          p_LAST_UPDATED_BY       => FND_GLOBAL.USER_ID,
          p_LAST_UPDATE_DATE      => SYSDATE,
          p_LAST_UPDATE_LOGIN     => p_Check_rec.LAST_UPDATE_LOGIN,
	  x_OBJECT_VERSION_NUMBER => X_OBJECT_VERSION_NUMBER,
          p_APPLICATION_ID        => p_Check_rec.APPLICATION_ID);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


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
    		ROLLBACK TO Create_Profile_Check_PVT;
    		x_return_status := FND_API.G_RET_STS_ERROR;
    		FND_MSG_PUB.Count_And_Get
      			( p_count => x_msg_count,
        		  p_data  => x_msg_data
      			);
                APP_EXCEPTION.RAISE_EXCEPTION;
  	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    		ROLLBACK TO Create_Profile_Check_PVT;
    		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    		FND_MSG_PUB.Count_And_Get
      			( p_count => x_msg_count,
        		  p_data  => x_msg_data
      			);
                APP_EXCEPTION.RAISE_EXCEPTION;
  	WHEN OTHERS THEN
    		ROLLBACK TO Create_Profile_Check_PVT;
    		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      	FND_MSG_PUB.Build_Exc_Msg(G_PKG_NAME, l_api_name);
    		FND_MSG_PUB.Count_And_Get
      			( p_count => x_msg_count,
        		  p_data  => x_msg_data
      			);
                APP_EXCEPTION.RAISE_EXCEPTION;
End Create_Profile_Check;


PROCEDURE Update_Profile_Check(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit                     IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level           IN   NUMBER       := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    p_CHECK_ID     		         IN   NUMBER  DEFAULT NULL,
    p_CHECK_NAME                 IN   VARCHAR2 DEFAULT NULL,
    p_CHECK_NAME_CODE            IN   VARCHAR2 DEFAULT NULL,
    p_DESCRIPTION                IN   VARCHAR2 DEFAULT NULL,
    p_START_DATE_ACTIVE          IN   DATE DEFAULT NULL,
    p_END_DATE_ACTIVE            IN   DATE DEFAULT NULL,
    p_SEEDED_FLAG                IN   VARCHAR2 DEFAULT NULL,
    p_SELECT_TYPE                IN   VARCHAR2 DEFAULT NULL,
    p_SELECT_BLOCK_ID            IN   NUMBER DEFAULT NULL,
    p_DATA_TYPE                  IN   VARCHAR2 DEFAULT NULL,
    p_FORMAT_MASK                IN   VARCHAR2 DEFAULT NULL,
    p_THRESHOLD_GRADE            IN   VARCHAR2 DEFAULT NULL,
    p_THRESHOLD_RATING_CODE      IN   VARCHAR2 DEFAULT NULL,
    p_CHECK_UPPER_LOWER_FLAG     IN   VARCHAR2 DEFAULT NULL,
    p_THRESHOLD_COLOR_CODE       IN   VARCHAR2 DEFAULT NULL,
    p_CHECK_LEVEL                IN   VARCHAR2 DEFAULT NULL,
    p_CREATED_BY                 IN   NUMBER DEFAULT NULL,
    p_CREATION_DATE              IN   DATE DEFAULT NULL,
    p_LAST_UPDATED_BY            IN   NUMBER DEFAULT NULL,
    p_LAST_UPDATE_DATE           IN   DATE DEFAULT NULL,
    p_LAST_UPDATE_LOGIN          IN   NUMBER DEFAULT NULL,
    px_OBJECT_VERSION_NUMBER     IN OUT NOCOPY   NUMBER,
    p_APPLICATION_ID             IN NUMBER DEFAULT NULL,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
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
    p_CREATED_BY              => p_CREATED_BY,
    p_CREATION_DATE          => p_CREATION_DATE,
    p_LAST_UPDATED_BY        => p_LAST_UPDATED_BY,
    p_LAST_UPDATE_DATE       => p_LAST_UPDATE_DATE,
    p_LAST_UPDATE_LOGIN      => p_LAST_UPDATE_LOGIN,
    p_APPLICATION_ID         => p_APPLICATION_ID,
    X_Check_Rec		     => l_Check_rec
    );


   Update_Profile_check(
    P_Api_Version_Number => P_Api_Version_Number,
    P_Init_Msg_List    => P_Init_Msg_List,
    P_Commit           => P_Commit,
    p_validation_level => p_validation_level,
    P_CHECK_REC        => l_CHECK_REC,
    PX_OBJECT_VERSION_NUMBER => px_OBJECT_VERSION_NUMBER,
    X_Return_Status    => X_Return_Status,
    X_Msg_Count        => X_Msg_Count,
    X_Msg_Data         => X_Msg_Data
    );

END;


PROCEDURE Update_Profile_check(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit                     IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level           IN   NUMBER       := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    P_Check_Rec     		   IN   Check_Rec_Type,
    PX_Object_Version_Number     IN OUT NOCOPY NUMBER,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    )

 IS
Cursor C_Get_check(c_CHECK_ID Number,c_object_version_number NUMBER) IS
    Select rowid,
           CHECK_ID,
           CHECK_NAME,
           CHECK_NAME_CODE,
           DESCRIPTION,
           START_DATE_ACTIVE,
           END_DATE_ACTIVE,
           SEEDED_FLAG,
           SELECT_TYPE,
           SELECT_BLOCK_ID,
           DATA_TYPE,
           FORMAT_MASK,
           THRESHOLD_GRADE,
           THRESHOLD_RATING_CODE,
           CHECK_UPPER_LOWER_FLAG,
           THRESHOLD_COLOR_CODE,
           CHECK_LEVEL,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
	   OBJECT_VERSION_NUMBER,
           APPLICATION_ID
    From  CSC_PROF_CHECKS_VL
    where check_id = c_check_id
    and object_version_number = c_object_version_number
    For Update NOWAIT;
l_api_name                CONSTANT VARCHAR2(30) := 'Update_Profile_check';
l_api_version_number      CONSTANT NUMBER   := 1.0;
-- Local Variables
l_ref_Check_rec  CSC_Profile_check_PVT.Check_Rec_Type;
l_rowid  ROWID;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_PROFILE_CHECK_PVT;

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

      Open C_Get_check( p_Check_rec.CHECK_ID, px_object_version_number);

      Fetch C_Get_check into
               l_rowid,
               l_ref_Check_rec.CHECK_ID,
               l_ref_Check_rec.CHECK_NAME,
               l_ref_Check_rec.CHECK_NAME_CODE,
               l_ref_Check_rec.DESCRIPTION,
               l_ref_Check_rec.START_DATE_ACTIVE,
               l_ref_Check_rec.END_DATE_ACTIVE,
               l_ref_Check_rec.SEEDED_FLAG,
               l_ref_Check_rec.SELECT_TYPE,
               l_ref_Check_rec.SELECT_BLOCK_ID,
               l_ref_Check_rec.DATA_TYPE,
               l_ref_Check_rec.FORMAT_MASK,
               l_ref_Check_rec.THRESHOLD_GRADE,
               l_ref_Check_rec.THRESHOLD_RATING_CODE,
               l_ref_Check_rec.CHECK_UPPER_LOWER_FLAG,
               l_ref_Check_rec.THRESHOLD_COLOR_CODE,
               l_ref_Check_rec.CHECK_LEVEL,
               l_ref_Check_rec.CREATED_BY,
               l_ref_Check_rec.CREATION_DATE,
               l_ref_Check_rec.LAST_UPDATED_BY,
               l_ref_Check_rec.LAST_UPDATE_DATE,
               l_ref_Check_rec.LAST_UPDATE_LOGIN,
	       l_ref_Check_rec.OBJECT_VERSION_NUMBER,
               l_ref_Check_rec.APPLICATION_ID;

       If ( C_Get_check%NOTFOUND) Then
           close C_Get_Check;
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
               CSC_CORE_UTILS_PVT.RECORD_IS_LOCKED_MSG(p_Api_Name => l_api_name);
               --FND_MESSAGE.Set_Name('CSC', 'API_MISSING_UPDATE_TARGET');
               --FND_MESSAGE.Set_Token ('INFO', 'CHECK', FALSE);
               --FND_MSG_PUB.Add;
           END IF;
           raise FND_API.G_EXC_ERROR;
       END IF;
       IF C_Get_Check%ISOPEN THEN
        CLOSE C_Get_Check;
       END IF;

      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN

          -- Invoke validation procedures
          Validate_check(
              p_init_msg_list    => FND_API.G_FALSE,
              p_validation_level => p_validation_level,
              p_validation_mode  => CSC_CORE_UTILS_PVT.G_UPDATE,
              P_Check_Rec  =>  P_Check_Rec,
              x_return_status    => x_return_status,
              x_msg_count        => x_msg_count,
              x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Invoke table handler(CS_PROF_CHECKS_PKG.Update_Row)
      CSC_PROF_CHECKS_PKG.Update_Row(
          p_CHECK_ID  => csc_core_utils_pvt.get_g_miss_num(p_Check_rec.CHECK_ID,l_ref_Check_rec.CHECK_ID),
          p_CHECK_NAME  => csc_core_utils_pvt.get_g_miss_char(p_Check_rec.CHECK_NAME,l_ref_Check_rec.CHECK_NAME),
          p_CHECK_NAME_CODE  => csc_core_utils_pvt.get_g_miss_char(p_Check_rec.CHECK_NAME_CODE,l_ref_Check_rec.CHECK_NAME_CODE),
          p_DESCRIPTION  => csc_core_utils_pvt.get_g_miss_char(p_Check_rec.DESCRIPTION,l_ref_Check_rec.DESCRIPTION),
          p_START_DATE_ACTIVE  => csc_core_utils_pvt.get_g_miss_date(p_Check_rec.START_DATE_ACTIVE,l_ref_Check_rec.START_DATE_ACTIVE),
          p_END_DATE_ACTIVE  => csc_core_utils_pvt.get_g_miss_date(p_Check_rec.END_DATE_ACTIVE,l_ref_Check_rec.END_DATE_ACTIVE),
          p_SEEDED_FLAG  => csc_core_utils_pvt.get_g_miss_char(p_Check_rec.SEEDED_FLAG,l_ref_Check_rec.SEEDED_FLAG),
          p_SELECT_TYPE  => csc_core_utils_pvt.get_g_miss_char(p_Check_rec.SELECT_TYPE,l_ref_Check_rec.SELECT_TYPE),
          p_SELECT_BLOCK_ID  => csc_core_utils_pvt.get_g_miss_num(p_Check_rec.SELECT_BLOCK_ID,l_ref_Check_rec.SELECT_BLOCK_ID),
          p_DATA_TYPE  => csc_core_utils_pvt.get_g_miss_char(p_Check_rec.DATA_TYPE,l_ref_Check_rec.DATA_TYPE),
          p_FORMAT_MASK  => csc_core_utils_pvt.get_g_miss_char(p_Check_rec.FORMAT_MASK,l_ref_Check_rec.FORMAT_MASK),
          p_THRESHOLD_GRADE  => csc_core_utils_pvt.get_g_miss_char(p_Check_rec.THRESHOLD_GRADE,l_ref_Check_rec.THRESHOLD_GRADE),
          p_THRESHOLD_RATING_CODE  => csc_core_utils_pvt.get_g_miss_char(p_Check_rec.THRESHOLD_RATING_CODE,l_ref_Check_rec.THRESHOLD_RATING_CODE),
          p_CHECK_UPPER_LOWER_FLAG  => csc_core_utils_pvt.get_g_miss_char(p_Check_rec.CHECK_UPPER_LOWER_FLAG,l_ref_Check_rec.CHECK_UPPER_LOWER_FLAG),
          p_THRESHOLD_COLOR_CODE  => csc_core_utils_pvt.get_g_miss_char(p_Check_rec.THRESHOLD_COLOR_CODE,l_ref_Check_rec.THRESHOLD_COLOR_CODE),
          p_CHECK_LEVEL           => csc_core_utils_pvt.get_g_miss_char(p_Check_rec.CHECK_LEVEL,l_ref_Check_rec.CHECK_LEVEL),
          p_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID,
          p_LAST_UPDATE_DATE  => SYSDATE,
          p_LAST_UPDATE_LOGIN  => p_Check_rec.LAST_UPDATE_LOGIN,
	       px_OBJECT_VERSION_NUMBER => px_OBJECT_VERSION_NUMBER,
          p_APPLICATION_ID   => csc_core_utils_pvt.get_g_miss_num(p_Check_rec.APPLICATION_ID,l_ref_Check_rec.APPLICATION_ID));

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
    		ROLLBACK TO Update_Profile_check_PVT;
    		x_return_status := FND_API.G_RET_STS_ERROR;
    		FND_MSG_PUB.Count_And_Get
      			( p_encoded => FND_API.G_FALSE,p_count => x_msg_count,
        		  	  p_data  => x_msg_data
      			);
          APP_EXCEPTION.RAISE_EXCEPTION;
  	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    		ROLLBACK TO Update_Profile_check_PVT;
    		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    		FND_MSG_PUB.Count_And_Get
      			( p_count => x_msg_count,
        		  	  p_data  => x_msg_data
      			);
         APP_EXCEPTION.RAISE_EXCEPTION;
  	WHEN OTHERS THEN
    		ROLLBACK TO Update_Profile_check_PVT;
    		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      	FND_MSG_PUB.Build_Exc_Msg(G_PKG_NAME, l_api_name);
    		FND_MSG_PUB.Count_And_Get
      			( p_count => x_msg_count,
        		  	  p_data  => x_msg_data
      			);
          APP_EXCEPTION.RAISE_EXCEPTION;
End Update_Profile_check;

PROCEDURE Delete_profile_check(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    p_Check_Id			   IN   NUMBER,
    p_OBJECT_VERSION_NUMBER      IN   NUMBER,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Delete_profile_check';
l_api_version_number      CONSTANT NUMBER   := 1.0;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_Profile_Checks_PVT;

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
      -- Invoke table handler(CSC_PROF_CHECKS_B_PKG.Delete_Row)
      CSC_PROF_CHECKS_PKG.Delete_Row(
          p_CHECK_ID  => p_CHECK_ID,
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
    		ROLLBACK TO DELETE_Profile_Checks_PVT;
    		x_return_status := FND_API.G_RET_STS_ERROR;
    		FND_MSG_PUB.Count_And_Get( p_encoded => FND_API.G_FALSE,p_count => x_msg_count,
        		  	  p_data  => x_msg_data
      			);
          APP_EXCEPTION.RAISE_EXCEPTION;
  	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    		ROLLBACK TO DELETE_Profile_Checks_PVT;
    		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    		FND_MSG_PUB.Count_And_Get( p_count => x_msg_count,
        		  	  p_data  => x_msg_data
      			);
         APP_EXCEPTION.RAISE_EXCEPTION;
  	WHEN OTHERS THEN
    		ROLLBACK TO DELETE_Profile_Checks_PVT;
    		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      	FND_MSG_PUB.Build_Exc_Msg(G_PKG_NAME, l_api_name);
    		FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
        		  	  p_data  => x_msg_data
      			);
            APP_EXCEPTION.RAISE_EXCEPTION;
End Delete_profile_check;



PROCEDURE Validate_CHECK_NAME (
    p_Api_Name		IN	VARCHAR2,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_CHECK_NAME                 IN   VARCHAR2,
    P_check_id			   IN   NUMBER,
    X_Return_Status              OUT  NOCOPY VARCHAR2
    )
IS
Cursor C2  is
 Select check_id
 from csc_prof_checks_tl
 where check_name = p_check_name
 and language = userenv('LANG');
--local variables
l_dummy NUMBER;
BEGIN

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- validate NOT NULL column
      IF (p_CHECK_NAME is NULL)
      THEN
	    --Mandatory argument error..
          x_return_status := FND_API.G_RET_STS_ERROR;
	    CSC_CORE_UTILS_PVT.mandatory_arg_error(
			p_api_name => p_api_name,
			p_argument => 'p_check_name',
			p_argument_value => p_check_name);
      END IF;

      IF(p_validation_mode = G_CREATE)
      THEN
          -- IF p_CHECK_NAME is not NULL and p_CHECK_NAME <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
	    IF (p_check_name is not NULL and p_CHECK_NAME <> CSC_CORE_UTILS_PVT.G_MISS_CHAR)
	    THEN
		Open C2;
		Fetch C2 into l_dummy;
		  IF C2%FOUND THEN
          	x_return_status := FND_API.G_RET_STS_ERROR;
			CSC_CORE_UTILS_PVT.Add_Duplicate_Value_Msg(
		    		p_api_name	=> p_api_name,
		     	p_argument	=> 'p_check_name' ,
  		     	p_argument_value => p_check_name);
		  END IF;
		Close C2;
	    ELSE
          		x_return_status := FND_API.G_RET_STS_ERROR;
	    		CSC_CORE_UTILS_PVT.mandatory_arg_error(
				p_api_name => p_api_name,
				p_argument => 'p_check_name',
				p_argument_value => p_check_name);

	    END IF;
      ELSIF(p_validation_mode = G_UPDATE)
      THEN
         -- if the check name is passed in and as NULL then
         -- its a mandatory argument error.
         if ( p_check_name IS NULL ) then
	       x_return_status := FND_API.G_RET_STS_ERROR;
	       CSC_CORE_UTILS_PVT.mandatory_arg_error(
		                                   p_api_name => p_api_name,
									p_argument => 'p_check_name',
									p_argument_value => p_check_name);
          -- IF p_CHECK_NAME <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
	    ELSIF p_CHECK_NAME <> CSC_CORE_UTILS_PVT.G_MISS_CHAR
	    THEN
		Open C2;
		Loop
		  Fetch C2 into l_dummy;
		  IF (l_dummy <> p_Check_id) THEN
          	x_return_status := FND_API.G_RET_STS_ERROR;
	    		CSC_CORE_UTILS_PVT.mandatory_arg_error(
				p_api_name => p_api_name,
				p_argument => 'p_check_name',
				p_argument_value => p_check_name);
				exit;
			else
			  exit;
		  END IF;
		End Loop;
		Close C2;
        END IF;
      END IF;

END Validate_CHECK_NAME;


PROCEDURE Validate_CHECK_NAME_CODE (
    P_Api_Name			   IN	  VARCHAR2,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_CHECK_NAME_CODE            IN   VARCHAR2,
    P_check_id			   IN   NUMBER,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2
    )
IS
Cursor C2  is
 Select check_id
 from csc_prof_checks_b
 where check_name_code = p_check_name_code;
--local variables
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
      IF (p_CHECK_NAME_CODE is NULL)
      THEN
	    --Mandatory argument error..
          x_return_status := FND_API.G_RET_STS_ERROR;
	    CSC_CORE_UTILS_PVT.mandatory_arg_error(
			p_api_name => p_api_name,
			p_argument => 'p_check_name_code',
			p_argument_value => p_check_name_code);
      END IF;

      IF(p_validation_mode = G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_CHECK_NAME_CODE is not NULL and p_CHECK_NAME_CODE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
	    IF (p_CHECK_NAME_CODE is not NULL and p_CHECK_NAME_CODE <> CSC_CORE_UTILS_PVT.G_MISS_CHAR)
	    THEN
		Open C2;
		Fetch C2 into l_dummy;
		  IF C2%FOUND THEN
          		x_return_status := FND_API.G_RET_STS_ERROR;
			CSC_CORE_UTILS_PVT.Add_Duplicate_Value_Msg(
		    		p_api_name	=> p_api_name,
		     		p_argument	=> 'p_check_name_code' ,
  		     		p_argument_value => p_check_name_code);
		  END IF;
		Close C2;
	    ELSE
          		x_return_status := FND_API.G_RET_STS_ERROR;
	    		CSC_CORE_UTILS_PVT.mandatory_arg_error(
				p_api_name => p_api_name,
				p_argument => 'p_check_name_code',
				p_argument_value => p_check_name_code);

	    END IF;
      ELSIF(p_validation_mode = G_UPDATE)
      THEN
         -- if the check name code is passed in and as NULL then
         -- its a mandatory argument error.
         if ( p_check_name_code IS NULL ) then
	       x_return_status := FND_API.G_RET_STS_ERROR;
	       CSC_CORE_UTILS_PVT.mandatory_arg_error(
		                              p_api_name => p_api_name,
								p_argument => 'p_check_name_code',
								p_argument_value => p_check_name_code);
          -- Hint: Validate data
          -- IF p_CHECK_NAME_CODE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
	    ELSIF p_CHECK_NAME_CODE <> CSC_CORE_UTILS_PVT.G_MISS_CHAR
	    THEN
		Open C2;
		Loop
		  Fetch C2 into l_dummy;
		  IF (l_dummy <> p_Check_id) THEN
          	x_return_status := FND_API.G_RET_STS_ERROR;
	    		CSC_CORE_UTILS_PVT.mandatory_arg_error(
				p_api_name => p_api_name,
				p_argument => 'p_check_name_code',
				p_argument_value => p_check_name_code);
				exit;
			else
				exit;
		  END IF;
		End Loop;
		Close C2;
         END IF;
      END IF;

END Validate_CHECK_NAME_CODE;


PROCEDURE Validate_START_END_DATE(
    P_Api_Name			   IN	  VARCHAR2,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_START_DATE_ACTIVE          IN   DATE,
    P_END_DATE			   IN	  DATE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
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

  	CSC_CORE_UTILS_PVT.Validate_Start_End_Dt
   		( p_api_name 		=> p_Api_name,
     		  p_start_date		=> p_start_date_active,
     		  p_end_date		=> p_end_date,
     		  x_return_status	=> x_return_status );
  	IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
       	x_return_status := FND_API.G_RET_STS_ERROR;
  	END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_START_END_DATE;


PROCEDURE Validate_SEEDED_FLAG (
    P_Api_Name			 IN   VARCHAR2,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_SEEDED_FLAG                IN   VARCHAR2,
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



	-- Check if the seeded flag is passed in and is not null, if passed in
  	-- check if the lookup code exists in fnd lookups for this date, if not
  	-- its an invalid argument.
  	IF (( p_seeded_flag <> CSC_CORE_UTILS_PVT.G_MISS_CHAR ) AND ( p_seeded_flag IS NOT NULL ))
	THEN
    		IF CSC_CORE_UTILS_PVT.lookup_code_not_exists(
 			p_effective_date  => trunc(sysdate),
  			p_lookup_type     => 'YES_NO',
  			p_lookup_code     => p_seeded_flag ) <> FND_API.G_RET_STS_SUCCESS
      	THEN
        		x_return_status := FND_API.G_RET_STS_ERROR;
        		CSC_CORE_UTILS_PVT.Add_Invalid_Argument_Msg(
					p_api_name => p_api_name,
			            p_argument_value  => p_seeded_flag,
			            p_argument  => 'p_seeded_flag');
     		END IF;
  	END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_SEEDED_FLAG;

PROCEDURE Validate_check_level
( p_api_name        IN  VARCHAR2,
  p_parameter_name  IN  VARCHAR2,
  p_check_level     IN  VARCHAR2,
  x_return_status   OUT NOCOPY VARCHAR2
) IS
  --
 BEGIN
  --
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- check if the check_level is passed in and is not
  -- null

  IF (( p_check_level <> CSC_CORE_UTILS_PVT.G_MISS_CHAR ) AND
        ( p_check_level IS NOT NULL )) THEN
-- Commented the Following condition for  ER#8473903
 --   IF (p_check_level <> 'PARTY' AND p_check_level <> 'ACCOUNT'AND p_check_level <> 'CONTACT' AND p_check_level <> 'EMPLOYEE')
  IF (p_check_level <> 'PARTY' AND p_check_level <> 'ACCOUNT'AND p_check_level <> 'CONTACT' AND p_check_level <> 'EMPLOYEE' AND p_check_level<> 'SITE') -- Included the 'SITE' for NCR ER#8473903
    THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        CSC_CORE_UTILS_PVT.Add_Invalid_Argument_Msg(p_api_name => p_api_name,
                                          p_argument_value  => p_check_level,
                                             p_argument  => p_parameter_name);
 END IF;
  END IF;
END Validate_check_Level;



PROCEDURE Validate_SELECT_TYPE (
    p_Api_Name			 IN   VARCHAR2,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_SELECT_TYPE                IN   VARCHAR2,
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


      IF NOT p_select_type in ('B','T') THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
         	CSC_CORE_UTILS_PVT.Add_Invalid_Argument_Msg(
			      p_api_name => p_api_name,
                     p_argument => 'P_SELECT_TYPE',
	                p_argument_value  => p_select_type);
      END IF;


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_SELECT_TYPE;


PROCEDURE Validate_SELECT_BLOCK_ID (
    P_Api_Name			   IN   VARCHAR2,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_SELECT_BLOCK_ID            IN   NUMBER,
    P_SELECT_TYPE                IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    )
IS
Cursor C2 is
 Select NULL
 from csc_prof_blocks_b
 where block_id = p_select_block_id;

l_dummy number;
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF p_SELECT_TYPE = 'B' THEN
        -- validate NOT NULL column
        IF(p_SELECT_BLOCK_ID is NULL)
        THEN
	  -- Mandatory argument error..
          x_return_status := FND_API.G_RET_STS_ERROR;
	    CSC_CORE_UTILS_PVT.mandatory_arg_error(
			    p_api_name => p_api_name,
			    p_argument => 'p_select_block_id',
			    p_argument_value => p_select_block_id);
        END IF;
      ELSE
        IF (p_SELECT_BLOCK_ID IS NOT NULL) AND  (p_SELECT_BLOCK_ID <> CSC_CORE_UTILS_PVT.G_MISS_NUM)
        THEN
               x_return_status := FND_API.G_RET_STS_ERROR;
          	CSC_CORE_UTILS_PVT.Add_Invalid_Argument_Msg(
		    	    p_api_name => p_api_name,
		    	    p_argument_value  => p_select_block_id,
		            p_argument  => 'p_select_block_id');
        END IF;
      END IF;

      IF(p_validation_mode = G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_SELECT_BLOCK_ID is not NULL and p_SELECT_BLOCK_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          IF p_SELECT_TYPE = 'B' THEN
	     IF (p_SELECT_BLOCK_ID <> CSC_CORE_UTILS_PVT.G_MISS_NUM)
	     THEN
		Open C2;
		Fetch C2 into l_dummy;
		  IF C2%NOTFOUND THEN
          		x_return_status := FND_API.G_RET_STS_ERROR;

          		CSC_CORE_UTILS_PVT.Add_Invalid_Argument_Msg(
			    p_api_name => p_api_name,
		            p_argument_value  => p_select_block_id,
		            p_argument  => 'p_select_block_id');

		  END IF;
		Close C2;
	      ELSE
          		x_return_status := FND_API.G_RET_STS_ERROR;
	    		CSC_CORE_UTILS_PVT.mandatory_arg_error(
				p_api_name => p_api_name,
				p_argument => 'p_select_block_id',
				p_argument_value => p_select_block_id);

	    END IF;
          END IF;
      ELSIF(p_validation_mode = G_UPDATE)
      THEN
         -- if the select block id is passed in and as NULL then
         -- its a mandatory argument error.
	    -- added the outer if condition to fix the bug 1563264
	  IF(p_SELECT_TYPE = 'B') THEN
         if ( p_select_block_id IS NULL ) then
	       x_return_status := FND_API.G_RET_STS_ERROR;
	       CSC_CORE_UTILS_PVT.mandatory_arg_error(
		                              p_api_name => p_api_name,
								p_argument => 'p_select_block_id',
								p_argument_value => p_select_block_id);
          -- Hint: Validate data
          -- IF p_SELECT_BLOCK_ID <> G_MISS_NUM
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
	    ELSIF p_SELECT_BLOCK_ID <> CSC_CORE_UTILS_PVT.G_MISS_NUM
	    THEN
		Open C2;
		Loop
		  Fetch C2 into l_dummy;
		    IF C2%NOTFOUND THEN
          		x_return_status := FND_API.G_RET_STS_ERROR;
          		CSC_CORE_UTILS_PVT.Add_Invalid_Argument_Msg(
				p_api_name => p_api_name,
		            p_argument_value  => p_select_block_id,
		            p_argument  => 'p_select_block_id');
				  exit;
			  else
				  exit;
		  END IF;
		End Loop;
		Close C2;
        END IF;
       END IF;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_SELECT_BLOCK_ID;


PROCEDURE Validate_DATA_TYPE (
    p_Api_Name			IN	VARCHAR2,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_DATA_TYPE                IN   VARCHAR2,
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


	IF p_DATA_TYPE is not NULL and p_DATA_TYPE <> CSC_CORE_UTILS_PVT.G_MISS_CHAR
	THEN
     -- Added 'BOOLEAN' in the IN CLAUSE . Bug #1231208
          IF NOT p_DATA_TYPE IN ('NUMBER','VARCHAR2','DATE', 'BOOLEAN') THEN
                x_return_status := FND_API.G_RET_STS_ERROR;
                CSC_CORE_UTILS_PVT.Add_Invalid_Argument_Msg(
			    p_api_name        => p_api_name,
		            p_argument_value  => p_data_type,
		            p_argument        => 'P_DATA_TYPE');

          END IF;

	END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_DATA_TYPE;

PROCEDURE Validate_THRESHOLD_GRADE (
    p_Api_Name			IN	VARCHAR2,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_THRESHOLD_GRADE            IN   VARCHAR2,
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

          -- IF p_THRESHOLD_GRADE is not NULL and p_THRESHOLD_GRADE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;


      IF(p_validation_mode = CSC_CORE_UTILS_PVT.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_THRESHOLD_GRADE is not NULL and p_THRESHOLD_GRADE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = CSC_CORE_UTILS_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_THRESHOLD_GRADE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_THRESHOLD_GRADE;


PROCEDURE Validate_THRESHOLD_RATING_CODE (
    p_Api_Name			IN	VARCHAR2,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_THRESHOLD_RATING_CODE                IN   VARCHAR2,
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

      -- Hint: Validate data
      -- IF p_THRESHOLD_RATING_CODE is not NULL and p_THRESHOLD_RATING_CODE <> G_MISS_CHAR
      -- verify if data is valid
      -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
      IF (p_THRESHOLD_RATING_CODE is NOT NULL) AND (p_THRESHOLD_RATING_CODE <> CSC_CORE_UTILS_PVT.G_MISS_CHAR)
      THEN
          IF CSC_CORE_UTILS_PVT.csc_lookup_code_not_exists(
                 p_effective_date => trunc(sysdate),
                 p_lookup_type    => 'CSC_PROF_RATINGS',
                 p_lookup_Code    => p_threshold_rating_code ) <> FND_API.G_RET_STS_SUCCESS
          THEN
             x_return_status := FND_API.G_RET_STS_ERROR;
             CSC_CORE_UTILS_PVT.Add_Invalid_Argument_Msg(
						p_api_name=> p_api_name,
                                    p_argument_value => p_threshold_rating_code,
						p_argument=>'P_RATING_CODE' );
	    END IF;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_THRESHOLD_RATING_CODE;


PROCEDURE Validate_UPPER_LOWER_FLAG (
    p_Api_Name			IN   VARCHAR2,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_CHECK_UPPER_LOWER_FLAG                IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
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

	IF p_CHECK_UPPER_LOWER_FLAG NOT IN ('U','L') THEN
		   x_return_status := FND_API.G_RET_STS_ERROR;
             CSC_CORE_UTILS_PVT.Add_Invalid_Argument_Msg(
			    p_api_name => p_api_name,
		            p_argument_value  => p_check_upper_lower_flag,
		            p_argument  => 'P_CHECK_UPPER_LOWER_FLAG');
	END IF;
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_UPPER_LOWER_FLAG;


PROCEDURE Validate_THRESHOLD_COLOR_CODE (
    p_Api_Name			IN  VARCHAR2,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_THRESHOLD_COLOR_CODE                IN   VARCHAR2,
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

END Validate_THRESHOLD_COLOR_CODE;

/*
PROCEDURE Validate_CATEGORY_CODE (
    p_Api_Name			IN VARCHAR2,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_CATEGORY_CODE                IN   VARCHAR2,
    X_Return_Status              OUT  VARCHAR2,
    X_Msg_Count                  OUT  NUMBER,
    X_Msg_Data                   OUT  VARCHAR2
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
*/


PROCEDURE Validate_check(
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Validation_level           IN   NUMBER := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    P_Validation_mode            IN   VARCHAR2,
    P_Check_Rec     IN    Check_Rec_Type,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    )
IS
p_api_name   CONSTANT VARCHAR2(30) := 'Validate_check';
 BEGIN


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


          Validate_CHECK_NAME(
	      p_Api_Name	=> p_Api_Name,
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_CHECK_NAME   => P_Check_Rec.CHECK_NAME,
              p_CHECK_ID     => P_CHECK_REC.CHECK_ID,
              x_return_status          => x_return_status );
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_CHECK_NAME_CODE(
              p_Api_Name	=> p_Api_Name,
              p_init_msg_list          => CSC_CORE_UTILS_PVT.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_CHECK_NAME_CODE   => P_Check_Rec.CHECK_NAME_CODE,
              p_CHECK_ID	=> p_CHECK_Rec.CHECK_ID,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;
	    -- validate start and end date
	    CSC_CORE_UTILS_PVT.Validate_Start_End_Dt(
	       p_api_name 		=> p_Api_name,
             p_start_date		=> p_check_rec.start_date_active,
             p_end_date		=> p_check_rec.end_date_active,
             x_return_status	=> x_return_status );

  	    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
             RAISE FND_API.G_EXC_ERROR;
  	    END IF;

          Validate_SEEDED_FLAG(
              p_APi_Name	=> p_Api_Name,
              p_init_msg_list          => CSC_CORE_UTILS_PVT.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_SEEDED_FLAG   => P_Check_Rec.SEEDED_FLAG,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_SELECT_TYPE(
	      p_Api_Name	=> p_Api_Name,
              p_init_msg_list          => CSC_CORE_UTILS_PVT.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_SELECT_TYPE   => P_Check_Rec.SELECT_TYPE,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;


          Validate_SELECT_BLOCK_ID(
	     p_Api_Name		=> p_Api_Name,
              p_init_msg_list          => CSC_CORE_UTILS_PVT.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_SELECT_BLOCK_ID   => P_Check_Rec.SELECT_BLOCK_ID,
              p_SELECT_TYPE       => P_Check_Rec.SELECT_TYPE,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;


          Validate_DATA_TYPE(
	      p_Api_Name	=> p_Api_Name,
              p_init_msg_list          => CSC_CORE_UTILS_PVT.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_DATA_TYPE   => P_Check_Rec.DATA_TYPE,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;


          Validate_THRESHOLD_GRADE(
	     p_Api_Name		=> p_Api_Name,
              p_init_msg_list          => CSC_CORE_UTILS_PVT.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_THRESHOLD_GRADE   => P_Check_Rec.THRESHOLD_GRADE,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_THRESHOLD_RATING_CODE(
	      p_Api_Name	=> p_Api_Name,
              p_init_msg_list          => CSC_CORE_UTILS_PVT.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_THRESHOLD_RATING_CODE   => P_Check_Rec.THRESHOLD_RATING_CODE,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_UPPER_LOWER_FLAG(
	      p_Api_Name	=> p_Api_Name,
              p_init_msg_list          => CSC_CORE_UTILS_PVT.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_CHECK_UPPER_LOWER_FLAG   => P_Check_Rec.CHECK_UPPER_LOWER_FLAG,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_THRESHOLD_COLOR_CODE(
	     p_Api_Name		=> p_Api_Name,
              p_init_msg_list          => CSC_CORE_UTILS_PVT.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_THRESHOLD_COLOR_CODE   => P_Check_Rec.THRESHOLD_COLOR_CODE,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

         CSC_CORE_UTILS_PVT.Validate_APPLICATION_ID (
           P_Init_Msg_List              => CSC_CORE_UTILS_PVT.G_FALSE,
           P_Application_ID             => P_Check_Rec.application_id,
           p_effective_date             => SYSDATE,
           X_Return_Status              => x_return_status,
           X_Msg_Count                  => x_msg_count,
           X_Msg_Data                   => x_msg_data );

        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                RAISE FND_API.G_EXC_ERROR;
        END IF;

         --Validate Check_level
        Validate_Check_Level(
           p_api_name         => p_api_name,
           p_parameter_name   => 'p_Check_Level',
           p_check_level      => P_Check_Rec.check_level,
           x_return_status    => x_return_status );

        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
         RAISE FND_API.G_EXC_ERROR;
        END IF;

/*
          Validate_CATEGORY_CODE(
	     p_Api_Name		=> p_Api_Name,
              p_init_msg_list          => CSC_CORE_UTILS_PVT.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_CATEGORY_CODE   => P_Check_Rec.CATEGORY_CODE,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;
 */
END Validate_check;

End CSC_PROFILE_CHECK_PVT;

/
