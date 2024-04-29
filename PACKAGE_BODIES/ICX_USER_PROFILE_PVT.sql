--------------------------------------------------------
--  DDL for Package Body ICX_USER_PROFILE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_USER_PROFILE_PVT" AS
-- $Header: ICXVUPFB.pls 120.1 2005/10/07 14:29:07 gjimenez noship $

PROCEDURE Create_Profile
(  p_api_version_number		IN	NUMBER,
   p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
   p_simulate			IN	VARCHAR2 := FND_API.G_FALSE,
   p_commit			IN	VARCHAR2 := FND_API.G_FALSE,
   p_validation_level		IN	NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_return_status		OUT	NOCOPY VARCHAR2,
   p_msg_count			OUT	NOCOPY NUMBER,
   p_msg_data			OUT	NOCOPY VARCHAR2,
   p_user_id			IN	NUMBER,
   p_days_needed_by		IN	NUMBER   := NULL,
   p_req_default_template	IN	VARCHAR2 := NULL,
   p_req_override_loc_flag	IN	VARCHAR2 := NULL,
   p_req_override_req_code	IN	VARCHAR2 := NULL,
   p_created_by			IN	NUMBER,
   p_creation_date		IN	DATE,
   p_last_updated_by		IN	NUMBER,
   p_last_update_date		IN	DATE,
   p_last_update_login		IN	NUMBER
)
IS
l_api_name		CONSTANT VARCHAR2(30) := 'Create_Profile';
l_api_version_number	CONSTANT NUMBER	      := 1.0;
l_return_stat		BOOLEAN;

BEGIN

   -- Standard Start of API savepoint

   SAVEPOINT Create_Profile_PVT;

   -- Standard call to check for call compatibility.

   if NOT FND_API.Compatible_API_Call
   (
	l_api_version_number,
	p_api_version_number,
	l_api_name,
	G_PKG_NAME
   )
   then
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   -- Initialize message list if p_init_msg_list is set to TRUE.

   if FND_API.to_Boolean( p_init_msg_list)
   then
      FND_MSG_PUB.initialize;
   end if;

   -- Initialize API return status to success

   p_return_status := FND_API.G_RET_STS_SUCCESS;

   l_return_stat := FND_PROFILE.SAVE(X_NAME =>'ICX_DAYS_NEEDED_BY',
                X_VALUE         => p_days_needed_by,
                X_LEVEL_NAME    =>'USER',
                X_LEVEL_VALUE   => p_user_id);

   if l_return_stat = FALSE then
             fnd_message.set_name('FND','SQL-NO INSERT');
             fnd_message.set_token('TABLE','FND_USER');
             fnd_msg_pub.Add;
             raise FND_API.G_EXC_ERROR;
   end if;

   l_return_stat := FND_PROFILE.SAVE(X_NAME =>'ICX_REQ_DEFAULT_TEMPLATE',
                X_VALUE         => p_req_default_template,
                X_LEVEL_NAME    =>'USER',
                X_LEVEL_VALUE   => p_user_id);

   if l_return_stat = FALSE then
             fnd_message.set_name('FND','SQL-NO INSERT');
             fnd_message.set_token('TABLE','FND_USER');
             fnd_msg_pub.Add;
             raise FND_API.G_EXC_ERROR;
   end if;

   l_return_stat := FND_PROFILE.SAVE(X_NAME =>'ICX_REQ_OVERRIDE_REQUESTOR_CODE',
                X_VALUE         => p_req_override_req_code,
                X_LEVEL_NAME    =>'USER',
                X_LEVEL_VALUE   => p_user_id);

   if l_return_stat = FALSE then
             fnd_message.set_name('FND','SQL-NO INSERT');
             fnd_message.set_token('TABLE','FND_USER');
             fnd_msg_pub.Add;
             raise FND_API.G_EXC_ERROR;
   end if;

   l_return_stat := FND_PROFILE.SAVE(X_NAME =>'ICX_REQ_OVERRIDE_LOCATION_FLAG',
                X_VALUE         => p_req_override_loc_flag,
                X_LEVEL_NAME    =>'USER',
                X_LEVEL_VALUE   => p_user_id);

   if l_return_stat = FALSE then
             fnd_message.set_name('FND','SQL-NO INSERT');
             fnd_message.set_token('TABLE','FND_USER');
             fnd_msg_pub.Add;
             raise FND_API.G_EXC_ERROR;
   end if;

   -- Standard check of p_simulate and p_commit parameters

   if FND_API.To_Boolean( p_simulate)
   then
      ROLLBACK to Create_Profile_PVT;

   elsif FND_API.To_Boolean( p_commit)
   then
      commit work;
   end if;

   -- Standard call to get message count and if count is 1, get message info.

   FND_MSG_PUB.Count_And_Get
   (
      p_count		=> p_msg_count,
      p_data		=> p_msg_data
   );

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

      Rollback to Create_Profile_PVT;
      p_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get
      (
         p_count		=> p_msg_count,
         p_data			=> p_msg_data
      );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      Rollback to Create_Profile_PVT;
      p_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get
      (
         p_count		=> p_msg_count,
         p_data			=> p_msg_data
      );

   WHEN OTHERS THEN

      Rollback to Create_Profile_PVT;
      p_return_status := FND_API.G_RET_STS_ERROR;

      if FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      then
         FND_MSG_PUB.Add_Exc_Msg
         (
            G_FILE_NAME,
            G_PKG_NAME,
            l_api_name
         );
      end if;

      FND_MSG_PUB.Count_And_Get
      (
         p_count		=> p_msg_count,
         p_data			=> p_msg_data
      );

end Create_Profile;


PROCEDURE Update_Profile
(  p_api_version_number		IN	NUMBER,
   p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
   p_simulate			IN	VARCHAR2 := FND_API.G_FALSE,
   p_commit			IN	VARCHAR2 := FND_API.G_FALSE,
   p_validation_level		IN	NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_return_status		OUT	NOCOPY VARCHAR2,
   p_msg_count			OUT	NOCOPY NUMBER,
   p_msg_data			OUT	NOCOPY VARCHAR2,
   p_user_id			IN	NUMBER,
   p_days_needed_by		IN	NUMBER   := FND_API.G_MISS_NUM,
   p_req_default_template	IN	VARCHAR2 := FND_API.G_MISS_CHAR,
   p_req_override_loc_flag	IN	VARCHAR2 := FND_API.G_MISS_CHAR,
   p_req_override_req_code	IN	VARCHAR2 := FND_API.G_MISS_CHAR,
   p_last_updated_by		IN	NUMBER,
   p_last_update_date		IN	DATE,
   p_last_update_login		IN	NUMBER
)
IS

l_api_name		CONSTANT VARCHAR2(30) := 'Update_Profile';
l_api_version_number	CONSTANT NUMBER	      := 1.0;
l_return_stat           BOOLEAN;

BEGIN

   -- Standard Start of API savepoint

   SAVEPOINT Update_Profile_PVT;

   -- Standard call to check for call compatibility.

   if NOT FND_API.Compatible_API_Call
   (
	l_api_version_number,
	p_api_version_number,
	l_api_name,
	G_PKG_NAME
   )
   then
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   -- Initialize message list if p_init_msg_list is set to TRUE.

   if FND_API.to_Boolean( p_init_msg_list)
   then
      FND_MSG_PUB.initialize;
   end if;

   -- Initialize API return status to success

   p_return_status := FND_API.G_RET_STS_SUCCESS;

   -- ************
   -- DAYS_NEEDED_BY
   -- ************
   if p_days_needed_by <> FND_API.G_MISS_NUM
   then
   l_return_stat := FND_PROFILE.SAVE(X_NAME =>'ICX_DAYS_NEEDED_BY',
                X_VALUE         => p_days_needed_by,
                X_LEVEL_NAME    =>'USER',
                X_LEVEL_VALUE   => p_user_id);

   if l_return_stat = FALSE then
             fnd_message.set_name('FND','SQL-NO INSERT');
             fnd_message.set_token('TABLE','FND_USER');
             fnd_msg_pub.Add;
             raise FND_API.G_EXC_ERROR;
   end if;
   end if;
   -- ************
   -- REQ_DEFAULT_TEMPLATE
   -- ************
   if p_req_default_template <> FND_API.G_MISS_CHAR
   then
   l_return_stat := FND_PROFILE.SAVE(X_NAME =>'ICX_REQ_DEFAULT_TEMPLATE',
                X_VALUE         => p_req_default_template,
                X_LEVEL_NAME    =>'USER',
                X_LEVEL_VALUE   => p_user_id);

   if l_return_stat = FALSE then
             fnd_message.set_name('FND','SQL-NO INSERT');
             fnd_message.set_token('TABLE','FND_USER');
             fnd_msg_pub.Add;
             raise FND_API.G_EXC_ERROR;
   end if;
   end if;
   -- ************
   -- REQ_OVERRIDE_LOC_FLAG
   -- ************
   if p_req_override_loc_flag <> FND_API.G_MISS_CHAR
   then
   l_return_stat := FND_PROFILE.SAVE(X_NAME =>'ICX_REQ_OVERRIDE_LOCATION_FLAG',
                X_VALUE         => p_req_override_loc_flag,
                X_LEVEL_NAME    =>'USER',
                X_LEVEL_VALUE   => p_user_id);

   if l_return_stat = FALSE then
             fnd_message.set_name('FND','SQL-NO INSERT');
             fnd_message.set_token('TABLE','FND_USER');
             fnd_msg_pub.Add;
             raise FND_API.G_EXC_ERROR;
   end if;
   end if;
   -- ************
   -- REQ_OVERRIDE_REQ_CODE
   -- ************
   if p_req_override_req_code <> FND_API.G_MISS_CHAR
   then
   l_return_stat := FND_PROFILE.SAVE(X_NAME =>'ICX_REQ_OVERRIDE_REQUESTOR_CODE',
                X_VALUE         => p_req_override_req_code,
                X_LEVEL_NAME    =>'USER',
                X_LEVEL_VALUE   => p_user_id);

   if l_return_stat = FALSE then
             fnd_message.set_name('FND','SQL-NO INSERT');
             fnd_message.set_token('TABLE','FND_USER');
             fnd_msg_pub.Add;
             raise FND_API.G_EXC_ERROR;
   end if;
   end if;

   -- Standard check of p_simulate and p_commit parameters

   if FND_API.To_Boolean( p_simulate)
   then
      ROLLBACK to Update_Profile_PVT;

   elsif FND_API.To_Boolean( p_commit)
   then
      commit work;
   end if;

   -- Standard call to get message count and if count is 1, get message info.

   FND_MSG_PUB.Count_And_Get
   (
      p_count		=> p_msg_count,
      p_data		=> p_msg_data
   );

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

      Rollback to Update_Profile_PVT;
      p_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get
      (
         p_count		=> p_msg_count,
         p_data			=> p_msg_data
      );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      Rollback to Update_Profile_PVT;
      p_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get
      (
         p_count		=> p_msg_count,
         p_data			=> p_msg_data
      );

   WHEN OTHERS THEN

      Rollback to Update_Profile_PVT;
      p_return_status := FND_API.G_RET_STS_ERROR;

      if FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      then
         FND_MSG_PUB.Add_Exc_Msg
         (
            G_FILE_NAME,
            G_PKG_NAME,
            l_api_name
         );
      end if;

      FND_MSG_PUB.Count_And_Get
      (
         p_count		=> p_msg_count,
         p_data			=> p_msg_data
      );

end Update_Profile;



PROCEDURE Delete_Profile
(  p_api_version_number		IN	NUMBER,
   p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
   p_simulate			IN	VARCHAR2 := FND_API.G_FALSE,
   p_commit			IN	VARCHAR2 := FND_API.G_FALSE,
   p_validation_level		IN	NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_return_status		OUT	nocopy VARCHAR2,
   p_msg_count			OUT	nocopy NUMBER,
   p_msg_data			OUT	nocopy VARCHAR2,
   p_user_id			IN	NUMBER
)
IS
l_api_name		CONSTANT VARCHAR2(30) := 'Delete_Profile';
l_api_version_number	CONSTANT NUMBER	      := 1.0;

l_error_tab			 VARCHAR2(40);
l_error_col			 VARCHAR2(40);
l_error_val			 VARCHAR2(40);

e_cannot_delete			 EXCEPTION;
l_return_stat			 BOOLEAN;

BEGIN

   -- Standard Start of API savepoint

   SAVEPOINT Delete_Profile_PVT;

   -- Standard call to check for call compatibility.

   if NOT FND_API.Compatible_API_Call
   (
	l_api_version_number,
	p_api_version_number,
	l_api_name,
	G_PKG_NAME
   )
   then
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   -- Initialize message list if p_init_msg_list is set to TRUE.

   if FND_API.to_Boolean( p_init_msg_list)
   then
      FND_MSG_PUB.initialize;
   end if;

   -- Initialize API return status to success

   p_return_status := FND_API.G_RET_STS_SUCCESS;


   l_return_stat := FND_PROFILE.SAVE(X_NAME =>'ICX_DAYS_NEEDED_BY',
                X_VALUE         => '',
                X_LEVEL_NAME    =>'USER',
                X_LEVEL_VALUE   => p_user_id);

   if l_return_stat = FALSE then
             fnd_message.set_name('FND','SQL-NO INSERT');
             fnd_message.set_token('TABLE','FND_USER');
             fnd_msg_pub.Add;
             raise FND_API.G_EXC_ERROR;
   end if;

   l_return_stat := FND_PROFILE.SAVE(X_NAME =>'ICX_REQ_DEFAULT_TEMPLATE',
                X_VALUE         => '',
                X_LEVEL_NAME    =>'USER',
                X_LEVEL_VALUE   => p_user_id);

   if l_return_stat = FALSE then
             fnd_message.set_name('FND','SQL-NO INSERT');
             fnd_message.set_token('TABLE','FND_USER');
             fnd_msg_pub.Add;
             raise FND_API.G_EXC_ERROR;
   end if;

   l_return_stat := FND_PROFILE.SAVE(X_NAME =>'ICX_REQ_OVERRIDE_REQUESTOR_CODE',
                X_VALUE         => '',
                X_LEVEL_NAME    =>'USER',
                X_LEVEL_VALUE   => p_user_id);

   if l_return_stat = FALSE then
             fnd_message.set_name('FND','SQL-NO INSERT');
             fnd_message.set_token('TABLE','FND_USER');
             fnd_msg_pub.Add;
             raise FND_API.G_EXC_ERROR;
   end if;

   l_return_stat := FND_PROFILE.SAVE(X_NAME =>'ICX_REQ_OVERRIDE_LOCATION_FLAG',
                X_VALUE         => '',
                X_LEVEL_NAME    =>'USER',
                X_LEVEL_VALUE   => p_user_id);

   if l_return_stat = FALSE then
             fnd_message.set_name('FND','SQL-NO INSERT');
             fnd_message.set_token('TABLE','FND_USER');
             fnd_msg_pub.Add;
             raise FND_API.G_EXC_ERROR;
   end if;

   -- Standard check of p_simulate and p_commit parameters

   if FND_API.To_Boolean( p_simulate)
   then
      ROLLBACK to Delete_Profile_PVT;

   elsif FND_API.To_Boolean( p_commit)
   then
      commit work;
   end if;

   -- Standard call to get message count and if count is 1, get message info.

   FND_MSG_PUB.Count_And_Get
   (
      p_count		=> p_msg_count,
      p_data		=> p_msg_data
   );

EXCEPTION

   WHEN NO_DATA_FOUND or e_cannot_delete THEN

      Rollback to Delete_Profile_PVT;
      p_return_status := FND_API.G_RET_STS_ERROR;

      fnd_message.set_name('FND','SQL-NO DELETE');
      fnd_message.set_token('TABLE', 'ICX_USER_PROFILES');

      fnd_msg_pub.Add;

      FND_MSG_PUB.Count_And_Get
      (
         p_count		=> p_msg_count,
         p_data			=> p_msg_data
      );

   WHEN FND_API.G_EXC_ERROR THEN

      Rollback to Delete_Profile_PVT;
      p_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get
      (
         p_count		=> p_msg_count,
         p_data			=> p_msg_data
      );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      Rollback to Delete_Profile_PVT;
      p_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get
      (
         p_count		=> p_msg_count,
         p_data			=> p_msg_data
      );

   WHEN OTHERS THEN

      Rollback to Delete_Profile_PVT;
      p_return_status := FND_API.G_RET_STS_ERROR;

      if FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      then
         FND_MSG_PUB.Add_Exc_Msg
         (
            G_FILE_NAME,
            G_PKG_NAME,
            l_api_name
         );
      end if;

      FND_MSG_PUB.Count_And_Get
      (
         p_count		=> p_msg_count,
         p_data			=> p_msg_data
      );

end Delete_Profile;


END ICX_User_Profile_PVT;

/
