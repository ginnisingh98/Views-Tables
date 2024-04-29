--------------------------------------------------------
--  DDL for Package Body ICX_USER_SEC_ATTR_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_USER_SEC_ATTR_PUB" AS
-- $Header: ICXPTUSB.pls 115.1 99/07/17 03:21:23 porting ship $

PROCEDURE Create_User_Sec_Attr
(  p_api_version_number		IN	NUMBER,
   p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
   p_simulate			IN	VARCHAR2 := FND_API.G_FALSE,
   p_commit			IN	VARCHAR2 := FND_API.G_FALSE,
   p_validation_level		IN	NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_return_status		OUT	VARCHAR2,
   p_msg_count			OUT	NUMBER,
   p_msg_data			OUT	VARCHAR2,
--   p_msg_entity			OUT	VARCHAR2,
--   p_msg_entity_index		OUT	NUMBER,
   p_web_user_id		IN	NUMBER,
   p_attribute_code		IN	VARCHAR2,
   p_attribute_appl_id		IN	NUMBER,
   p_varchar2_value             IN      VARCHAR2,
   p_date_value                 IN      DATE,
   p_number_value               IN      NUMBER,
   p_created_by			IN	NUMBER,
   p_creation_date		IN	DATE,
   p_last_updated_by		IN	NUMBER,
   p_last_update_date		IN	DATE,
   p_last_update_login		IN	NUMBER
)
IS
   l_api_name		CONSTANT VARCHAR2(30) := 'Create_User_Sec_Attr';
   l_api_version_number	CONSTANT NUMBER	      := 1.0;
   l_return_status		 VARCHAR2(10);

   l_dummy_id			 NUMBER;
   l_duplicate			 NUMBER := 0;

BEGIN

   -- Standard Start of API savepoint

   SAVEPOINT Create_User_Sec_Attr_PUB;

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

   -- ***************************
   -- VALIDATION

   -- ***************************


   -- Call private api to create web_user_responsibility

   ICX_User_Sec_Attr_PVT.Create_User_Sec_Attr
   (
      p_api_version_number	=>	p_api_version_number	,
      p_init_msg_list		=>	p_init_msg_list		,
      p_simulate		=>	p_simulate		,
      p_commit			=>	p_commit		,
      p_validation_level	=>	p_validation_level	,
      p_return_status		=>	l_return_status		,
      p_msg_count		=>	p_msg_count		,
      p_msg_data		=>	p_msg_data		,
--      p_msg_entity		=>	p_msg_entity		,
--      p_msg_entity_index	=>	p_msg_entity_index	,
      p_web_user_id		=>	p_web_user_id		,
      p_attribute_code		=>	p_attribute_code	,
      p_attribute_appl_id	=>	p_attribute_appl_id	,
      p_varchar2_value		=>	p_varchar2_value	,
      p_date_value		=>	p_date_value		,
      p_number_value		=>	p_number_value		,
      p_created_by		=>	p_created_by		,
      p_creation_date		=>	p_creation_date		,
      p_last_updated_by		=>	p_last_updated_by	,
      p_last_update_date	=>	p_last_update_date	,
      p_last_update_login	=>	p_last_update_login
   );

   -- Both G_EXC_ERROR and G_EXC_UNEXPECTED_ERROR are handled in
   -- the API exception handler.

   if l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
   then

   -- Unexpected error, abort processing.

      raise FND_API.G_EXC_UNEXPECTED_ERROR;

   elsif l_return_status = FND_API.G_RET_STS_ERROR THEN

   -- Error, abort processing

      raise FND_API.G_EXC_ERROR;

   end if;

   -- Standard check of p_simulate and p_commit parameters

   if FND_API.To_Boolean( p_simulate)
   then
      ROLLBACK to Create_User_Sec_Attr_PUB;

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

      Rollback to Create_User_Sec_Attr_PUB;
      p_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get
      (
         p_count		=> p_msg_count,
         p_data			=> p_msg_data
      );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      Rollback to Create_User_Sec_Attr_PUB;
      p_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get
      (
         p_count		=> p_msg_count,
         p_data			=> p_msg_data
      );

   WHEN OTHERS THEN

      Rollback to Create_User_Sec_Attr_PUB;
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

end Create_User_Sec_Attr;




PROCEDURE Delete_User_Sec_Attr
(  p_api_version_number		IN	NUMBER,
   p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
   p_simulate			IN	VARCHAR2 := FND_API.G_FALSE,
   p_commit			IN	VARCHAR2 := FND_API.G_FALSE,
   p_validation_level		IN	NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_return_status		OUT	VARCHAR2,
   p_msg_count			OUT	NUMBER,
   p_msg_data			OUT	VARCHAR2,
--   p_msg_entity			OUT	VARCHAR2,
--   p_msg_entity_index		OUT	NUMBER,
   p_web_user_id		IN	NUMBER,
   p_attribute_code		IN	VARCHAR2,
   p_attribute_appl_id		IN	NUMBER,
   p_varchar2_value             IN      VARCHAR2,
   p_date_value                 IN      DATE,
   p_number_value               IN      NUMBER

)
IS
   l_api_name		CONSTANT VARCHAR2(30) := 'Delete_User_Sec_Attr';
   l_api_version_number	CONSTANT NUMBER	      := 1.0;
   l_return_status		 VARCHAR2(10);

BEGIN

   -- Standard Start of API savepoint

   SAVEPOINT Delete_User_Sec_Attr_PUB;

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

   ICX_User_Sec_Attr_PVT.Delete_User_Sec_Attr
   (
      p_api_version_number	=>	p_api_version_number	,
      p_init_msg_list		=>	p_init_msg_list		,
      p_simulate		=>	p_simulate		,
      p_commit			=>	p_commit		,
      p_validation_level	=>	p_validation_level	,
      p_return_status		=>	l_return_status		,
      p_msg_count		=>	p_msg_count		,
      p_msg_data		=>	p_msg_data		,
--      p_msg_entity		=>	p_msg_entity		,
--      p_msg_entity_index	=>	p_msg_entity_index	,
      p_web_user_id		=>	p_web_user_id		,
      p_attribute_code		=>	p_attribute_code	,
      p_attribute_appl_id	=>	p_attribute_appl_id     ,
      p_varchar2_value		=>	p_varchar2_value	,
      p_date_value		=>	p_date_value		,
      p_number_value		=>	p_number_value
   );

   -- Both G_EXC_ERROR and G_EXC_UNEXPECTED_ERROR are handled in
   -- the API exception handler.

   if l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
   then

   -- Unexpected error, abort processing.

      raise FND_API.G_EXC_UNEXPECTED_ERROR;

   elsif l_return_status = FND_API.G_RET_STS_ERROR THEN

   -- Error, abort processing

      raise FND_API.G_EXC_ERROR;

   end if;

   -- Standard check of p_simulate and p_commit parameters

   if FND_API.To_Boolean( p_simulate)
   then
      ROLLBACK to Delete_User_Sec_Attr_PUB;

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

      Rollback to Delete_User_Sec_Attr_PUB;
      p_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get
      (
         p_count		=> p_msg_count,
         p_data			=> p_msg_data
      );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      Rollback to Delete_User_Sec_Attr_PUB;
      p_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get
      (
         p_count		=> p_msg_count,
         p_data			=> p_msg_data
      );

   WHEN OTHERS THEN

      Rollback to Delete_User_Sec_Attr_PUB;
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

end Delete_User_Sec_Attr;


END ICX_User_Sec_Attr_PUB;

/
