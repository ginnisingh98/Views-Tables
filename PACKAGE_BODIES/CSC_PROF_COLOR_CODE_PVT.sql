--------------------------------------------------------
--  DDL for Package Body CSC_PROF_COLOR_CODE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSC_PROF_COLOR_CODE_PVT" as
/* $Header: cscvpccb.pls 115.7 2002/12/03 19:31:56 jamose ship $ */
-- Start of Comments
-- Package name     : CSC_PROF_COLOR_CODE_PVT
-- Purpose          :
-- History          :
-- 27 Nov 02   jamose For Fnd_Api_G_Miss* and NOCOPY changes
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSC_PROF_COLOR_CODE_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'cscvpccb.pls';

----------------------------------------------------------------------------
-- Start of Procedure Body Convert_Columns_to_Rec
----------------------------------------------------------------------------

PROCEDURE Convert_Columns_to_Rec (
       p_COLOR_CODE                      VARCHAR2 DEFAULT NULL,
       p_RATING_CODE                     VARCHAR2,
       p_LAST_UPDATE_DATE                DATE,
       p_LAST_UPDATED_BY                 NUMBER,
       p_CREATION_DATE                   DATE,
       p_CREATED_BY                      NUMBER,
       p_LAST_UPDATE_LOGIN               NUMBER,
       x_prof_color_rec     OUT  NOCOPY  prof_color_Rec_Type
    )
  IS
BEGIN

    x_prof_color_rec.COLOR_CODE := p_COLOR_CODE;
    x_prof_color_rec.RATING_CODE := p_RATING_CODE;
    x_prof_color_rec.created_by := p_created_by;
    x_prof_color_rec.creation_date := p_creation_date;
    x_prof_color_rec.last_updated_by := p_last_updated_by;
    x_prof_color_rec.last_update_date := p_last_update_date;
    x_prof_color_rec.last_update_login := p_last_update_login;

END Convert_Columns_to_Rec;

PROCEDURE Create_prof_color_code(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit                     IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level           IN   NUMBER       := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    px_COLOR_CODE                IN OUT NOCOPY   VARCHAR2 ,
    p_RATING_CODE                IN   VARCHAR2,
    p_LAST_UPDATE_DATE           IN   DATE,
    p_LAST_UPDATED_BY            IN   NUMBER,
    p_CREATION_DATE              IN   DATE,
    p_CREATED_BY                 IN   NUMBER,
    p_LAST_UPDATE_LOGIN          IN   NUMBER,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    )

 IS
l_prof_color_rec prof_color_Rec_Type;
BEGIN
  Convert_Columns_to_Rec (
       p_COLOR_CODE => px_COLOR_CODE,
       p_RATING_CODE => p_RATING_CODE   ,
       p_LAST_UPDATE_DATE => p_LAST_UPDATE_DATE ,
       p_LAST_UPDATED_BY=>p_LAST_UPDATED_BY  ,
       p_CREATION_DATE => p_CREATION_DATE    ,
       p_CREATED_BY => p_CREATED_BY       ,
       p_LAST_UPDATE_LOGIN => p_LAST_UPDATE_LOGIN ,
       x_prof_color_rec=> l_prof_color_rec );

 Create_prof_color_code(
    P_Api_Version_Number    => P_Api_Version_Number,
    P_Init_Msg_List         => P_Init_Msg_List,
    P_Commit                => P_Commit,
    p_validation_level      => p_validation_level,
    P_prof_color_rec => l_prof_color_rec,
    PX_COLOR_CODE     		=> PX_COLOR_CODE,
    X_Return_Status           => X_Return_Status,
    X_Msg_Count               => X_Msg_Count,
    X_Msg_Data                => X_Msg_Data   );


END Create_prof_color_code;


PROCEDURE Create_prof_color_code(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit                     IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level           IN   NUMBER       := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    P_prof_color_rec     IN    prof_color_Rec_Type  := G_MISS_prof_color_rec_type_REC,
    px_COLOR_CODE     		IN OUT NOCOPY VARCHAR2,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Create_prof_color_code';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_return_status_full        VARCHAR2(1);
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_PROF_COLOR_CODE_PVT;

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


      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Invoke validation procedures
          Validate_prof_color_code(
              p_init_msg_list    => CSC_CORE_UTILS_PVT.G_FALSE,
              p_validation_level => p_validation_level,
              p_validation_mode  => CSC_CORE_UTILS_PVT.G_CREATE,
              P_prof_color_rec_type_Rec  =>  P_prof_color_rec,
              x_return_status    => x_return_status,
              x_msg_count        => x_msg_count,
              x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


     CSC_COLOR_CODES_PKG.Insert_Row(
          px_COLOR_CODE  => px_COLOR_CODE,
          p_RATING_CODE  => P_prof_color_rec.RATING_CODE,
          p_LAST_UPDATE_DATE  => SYSDATE,
          p_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID,
          p_CREATION_DATE  => SYSDATE,
          p_CREATED_BY  => FND_GLOBAL.USER_ID,
          p_LAST_UPDATE_LOGIN  => p_prof_color_rec.LAST_UPDATE_LOGIN);

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
		 ROLLBACK TO CREATE_PROF_COLOR_CODE_PVT;
           x_return_status :=  FND_API.G_RET_STS_ERROR ;
           --FND_MSG_PUB.Count_And_Get(p_count =>x_msg_count,
                                     --p_data => x_msg_data) ;

           APP_EXCEPTION.RAISE_EXCEPTION;
          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		 ROLLBACK TO CREATE_PROF_COLOR_CODE_PVT;
           x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR ;
           --FND_MSG_PUB.Count_And_Get(p_count =>x_msg_count,
                                     --p_data => x_msg_data) ;
           APP_EXCEPTION.RAISE_EXCEPTION;

          WHEN OTHERS THEN
		 ROLLBACK TO CREATE_PROF_COLOR_CODE_PVT;
           x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR ;
           --FND_MSG_PUB.Count_And_Get(p_count =>x_msg_count,
                                     --p_data => x_msg_data) ;
    	      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
           	    FND_MSG_PUB.Build_Exc_Msg(G_PKG_NAME, l_api_name);
    	      END IF;
           APP_EXCEPTION.RAISE_EXCEPTION;

End Create_prof_color_code;


PROCEDURE Update_prof_color_code(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit                     IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level           IN   NUMBER       := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    p_COLOR_CODE                 IN   VARCHAR2,
    p_RATING_CODE                IN   VARCHAR2,
    p_LAST_UPDATE_DATE           IN   DATE,
    p_LAST_UPDATED_BY            IN   NUMBER,
    p_CREATION_DATE              IN   DATE DEFAULT NULL,
    p_CREATED_BY                 IN   NUMBER DEFAULT NULL,
    p_LAST_UPDATE_LOGIN          IN   NUMBER,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    )

IS
 l_prof_color_rec prof_color_Rec_Type;
BEGIN

 Convert_Columns_to_Rec (
       p_COLOR_CODE    ,
       p_RATING_CODE   ,
       p_LAST_UPDATE_DATE ,
       p_LAST_UPDATED_BY  ,
       p_CREATION_DATE    ,
       p_CREATED_BY       ,
       p_LAST_UPDATE_LOGIN ,
       l_prof_color_rec );

 Update_prof_color_code(
    P_Api_Version_Number    => P_Api_Version_Number,
    P_Init_Msg_List         => P_Init_Msg_List,
    P_Commit                => P_Commit,
    p_validation_level      => p_validation_level,
    P_prof_color_rec   => l_prof_color_rec,
    X_Return_Status           => X_Return_Status,
    X_Msg_Count               => X_Msg_Count,
    X_Msg_Data                => X_Msg_Data );


END Update_prof_color_code;

PROCEDURE Update_prof_color_code(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit                     IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level           IN  NUMBER       := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    P_prof_color_rec     IN    prof_color_Rec_Type,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    )

 IS

Cursor C_Get_prof_color_code(c_RATING_CODE VARCHAR2) IS
    Select rowid,
           COLOR_CODE,
           RATING_CODE,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_LOGIN
    From  CSC_COLOR_CODES
    Where RATING_CODE = c_RATING_CODE
    For Update NOWAIT;
l_old_prof_color_rec     CSC_COLOR_CODES%ROWTYPE;
l_api_name                CONSTANT VARCHAR2(30) := 'Update_prof_color_code';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_rowid  ROWID;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_PROF_COLOR_CODE_PVT;

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


      Open C_Get_prof_color_code( P_prof_color_rec.RATING_CODE);

      Fetch C_Get_prof_color_code into
               l_rowid,
               l_old_prof_color_rec.COLOR_CODE,
               l_old_prof_color_rec.RATING_CODE,
               l_old_prof_color_rec.LAST_UPDATE_DATE,
               l_old_prof_color_rec.LAST_UPDATED_BY,
               l_old_prof_color_rec.CREATION_DATE,
               l_old_prof_color_rec.CREATED_BY,
               l_old_prof_color_rec.LAST_UPDATE_LOGIN;

       If ( C_Get_prof_color_code%NOTFOUND) Then
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
		CSC_CORE_UTILS_PVT.RECORD_IS_LOCKED_MSG(l_api_name);
           END IF;
           raise FND_API.G_EXC_ERROR;

       END IF;
       Close     C_Get_prof_color_code;


      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN

          -- Invoke validation procedures
          Validate_prof_color_code(
              p_init_msg_list    => FND_API.G_FALSE,
              p_validation_level => p_validation_level,
              p_validation_mode  => CSC_CORE_UTILS_PVT.G_UPDATE,
              P_prof_color_rec_type_Rec  =>  P_prof_color_rec,
              x_return_status    => x_return_status,
              x_msg_count        => x_msg_count,
              x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Invoke table handler(CSC_COLOR_CODES_PKG.Update_Row)
      CSC_COLOR_CODES_PKG.Update_Row(
          p_COLOR_CODE  =>csc_core_utils_pvt.Get_G_Miss_Char(p_prof_color_rec.COLOR_CODE,l_old_prof_color_rec.COLOR_CODE),
          p_RATING_CODE  =>csc_core_utils_pvt.Get_G_Miss_Char(p_prof_color_rec.RATING_CODE,l_old_prof_color_rec.RATING_CODE),
          p_LAST_UPDATE_DATE  => SYSDATE,
          p_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID,
          p_LAST_UPDATE_LOGIN  =>csc_core_utils_pvt.Get_G_Miss_Char(p_prof_color_rec.LAST_UPDATE_LOGIN,l_old_prof_color_rec.LAST_UPDATE_LOGIN));
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
		 ROLLBACK TO UPDATE_PROF_COLOR_CODE_PVT;
           x_return_status :=  FND_API.G_RET_STS_ERROR ;
           --FND_MSG_PUB.Count_And_Get(p_count =>x_msg_count,
                                     --p_data => x_msg_data) ;
           APP_EXCEPTION.RAISE_EXCEPTION;

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		 ROLLBACK TO UPDATE_PROF_COLOR_CODE_PVT;
           x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR ;
           --FND_MSG_PUB.Count_And_Get(p_count =>x_msg_count,
                                     --p_data => x_msg_data) ;
           APP_EXCEPTION.RAISE_EXCEPTION;

          WHEN OTHERS THEN
		 ROLLBACK TO UPDATE_PROF_COLOR_CODE_PVT;
           x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR ;
           --FND_MSG_PUB.Count_And_Get(p_count =>x_msg_count,
                                     --p_data => x_msg_data) ;
    	      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
           	    FND_MSG_PUB.Build_Exc_Msg(G_PKG_NAME, l_api_name);
    	      END IF;
           APP_EXCEPTION.RAISE_EXCEPTION;

End Update_prof_color_code;


PROCEDURE Delete_prof_color_code(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit                     IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level           IN   NUMBER       := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    P_COLOR_CODE			   IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Delete_prof_color_code';
l_api_version_number      CONSTANT NUMBER   := 1.0;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_PROF_COLOR_CODE_PVT;

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
      -- Invoke table handler(CSC_COLOR_CODES_PKG.Delete_Row)
      CSC_COLOR_CODES_PKG.Delete_Row(
          p_COLOR_CODE  => p_COLOR_CODE);
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
		 ROLLBACK TO DELETE_PROF_COLOR_CODE_PVT;
           x_return_status :=  FND_API.G_RET_STS_ERROR ;
           --FND_MSG_PUB.Count_And_Get(p_count =>x_msg_count,
                                     --p_data => x_msg_data) ;
           APP_EXCEPTION.RAISE_EXCEPTION;

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		 ROLLBACK TO DELETE_PROF_COLOR_CODE_PVT;
           x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR ;
           --FND_MSG_PUB.Count_And_Get(p_count =>x_msg_count,
                                     --p_data => x_msg_data) ;
           APP_EXCEPTION.RAISE_EXCEPTION;

          WHEN OTHERS THEN
		 ROLLBACK TO DELETE_PROF_COLOR_CODE_PVT;
           x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR ;
           --FND_MSG_PUB.Count_And_Get(p_count =>x_msg_count,
                                     --p_data => x_msg_data) ;
    	      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
           	    FND_MSG_PUB.Build_Exc_Msg(G_PKG_NAME, l_api_name);
    	      END IF;
           APP_EXCEPTION.RAISE_EXCEPTION;

End Delete_prof_color_code;


-- Item-level validation procedures
PROCEDURE Validate_COLOR_CODE (
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_COLOR_CODE                IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    )
IS
 p_Api_Name Varchar2(100) := 'Validate_Prof_Color_Code';

BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- validate NOT NULL column
      IF(p_COLOR_CODE is NULL)
      THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      IF(p_validation_mode = CSC_CORE_UTILS_PVT.G_CREATE)
      THEN
          -- Hint: Validate data
		  IF p_COLOR_CODE is not NULL and p_COLOR_CODE <> CSC_CORE_UTILS_PVT.G_MISS_CHAR THEN
			-- **********************
			-- No Validation for Color codes for now...
			-- *********************
			NULL;
		 else
			 CSC_CORE_UTILS_PVT.mandatory_arg_error(
				p_api_name => p_api_name,
				p_argument => 'p_color_code',
				p_argument_value => p_color_code);
		 end if;
      ELSIF(p_validation_mode = CSC_CORE_UTILS_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
		  IF p_COLOR_CODE is not NULL and p_COLOR_CODE <> CSC_CORE_UTILS_PVT.G_MISS_CHAR THEN
			-- **********************
			-- No Validation for Color codes for now...
			-- *********************
			NULL;
		 else
			 CSC_CORE_UTILS_PVT.mandatory_arg_error(
				p_api_name => p_api_name,
				p_argument => 'p_color_code',
				p_argument_value => p_color_code);
		 end if;

      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_COLOR_CODE;


PROCEDURE Validate_RATING_CODE (
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_RATING_CODE                IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    )
IS
	l_lookup_code varchar2(100);
	l_dummy		varchar2(1);
      p_Api_Name    varchar2(30) := 'Validate_Rating_Code';
	cursor c is
		select null
		from csc_lookups
		where lookup_type = 'CSC_PROF_RATINGS'
		and   lookup_code = p_rating_code
		and   enabled_flag = 'Y'
		and   trunc(sysdate) between trunc(nvl(start_date_Active,sysdate))
			 and trunc(nvl(end_date_active,sysdate));
	cursor c1 is
            select null
		from csc_color_codes
		where rating_code = p_rating_code;
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- validate NOT NULL column
      IF(p_RATING_CODE is NULL and p_RATING_CODE = CSC_CORE_UTILS_PVT.G_MISS_CHAR)
      THEN
			 x_return_status := FND_API.G_RET_STS_ERROR;
			 CSC_CORE_UTILS_PVT.mandatory_arg_error(
				p_api_name => p_api_name,
				p_argument => 'P_RATING_CODE',
				p_argument_value => p_rating_code);
      END IF;

      -- IF(p_validation_mode = CSC_CORE_UTILS_PVT.G_CREATE)
      --THEN
          -- Hint: Validate data
          IF p_RATING_CODE is not NULL and p_RATING_CODE <> CSC_CORE_UTILS_PVT.G_MISS_CHAR THEN
			-- Check whethere code is defined in CSC_LOOKUPS
			-- for CSC_PROF_RATINGS
			l_lookup_code := p_rating_code;
			open c;
			fetch c into l_dummy;
			if c%notfound then
				   x_return_status := FND_API.G_RET_STS_ERROR;
				   CSC_CORE_UTILS_PVT.Add_Invalid_Argument_Msg(
					  p_api_name => p_api_name,
			              p_argument_value  => p_rating_code,
			              p_argument  => 'p_rating_code');
			else
				IF(p_validation_mode = CSC_CORE_UTILS_PVT.G_CREATE)
				THEN
				  open c1;
				  fetch c1 into l_dummy;
				  if c1%found then
				    x_return_status := FND_API.G_RET_STS_ERROR;
				    CSC_CORE_UTILS_PVT.Add_Duplicate_Value_Msg(
		   			  p_api_name	=> p_api_name,
		     			  p_argument	=> 'p_rating_code' ,
  		     			  p_argument_value => p_rating_code );
				  end if;
				  close c1;
				END IF;
			end if;
			close c;
		END IF;

      --END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_RATING_CODE;

PROCEDURE Validate_prof_color_code(
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Validation_level           IN   NUMBER := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    P_Validation_mode            IN   VARCHAR2,
    P_prof_color_rec_type_Rec     IN    prof_color_Rec_Type,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    )
IS
l_api_name   CONSTANT VARCHAR2(30) := 'Validate_prof_color_code';
 BEGIN



      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_validation_level > CSC_CORE_UTILS_PVT.G_VALID_LEVEL_NONE) THEN

          Validate_COLOR_CODE(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_COLOR_CODE   => P_prof_color_rec_type_Rec.COLOR_CODE,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_RATING_CODE(
              p_init_msg_list          => CSC_CORE_UTILS_PVT.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_RATING_CODE   => P_prof_color_rec_type_Rec.RATING_CODE,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

      END IF;


END Validate_prof_color_code;

End CSC_PROF_COLOR_CODE_PVT;

/
