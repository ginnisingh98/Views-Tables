--------------------------------------------------------
--  DDL for Package Body ICX_RESP_EXCL_ATTR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_RESP_EXCL_ATTR_PVT" AS
-- $Header: ICXVTREB.pls 115.1 99/07/17 03:30:37 porting ship $

PROCEDURE Create_Resp_Excl_Attr
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
   p_responsibility_id		IN	NUMBER,
   p_application_id		IN	NUMBER,
   p_attribute_code		IN	VARCHAR2,
   p_attribute_appl_id		IN	NUMBER,
   p_created_by			IN	NUMBER,
   p_creation_date		IN	DATE,
   p_last_updated_by		IN	NUMBER,
   p_last_update_date		IN	DATE,
   p_last_update_login		IN	NUMBER
)
IS
l_api_name		CONSTANT VARCHAR2(30) := 'Create_Resp_Excl_Attr';
l_api_version_number	CONSTANT NUMBER	      := 1.0;

l_duplicate			 NUMBER       := 0;

BEGIN
   -- Standard Start of API savepoint

   SAVEPOINT Create_Resp_Excl_Attr_PVT;

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

   -- ************************************
   -- VALIDATION - RESP_EXCL_ATTR
   -- ************************************
--   select responsibility_id
   select count(*)
     into l_duplicate
     from ak_excluded_items
    where resp_application_id 		= p_application_id
      and attribute_code    		= p_attribute_code
      and responsibility_id 		= p_responsibility_id
      and attribute_application_id 	= p_attribute_appl_id;

   if l_duplicate <> 0
--   if SQL%FOUND
   then
      -- responsibility-excluded_attribute already exists

-- !!!!Need create message through Rami

      fnd_message.set_name('FND','SECURITY-DUPLICATE USER RESP');
      fnd_msg_pub.Add;
      raise FND_API.G_EXC_ERROR;
   else
      INSERT into AK_EXCLUDED_ITEMS
      (
	 RESPONSIBILITY_ID		,
         ATTRIBUTE_APPLICATION_ID,
         ATTRIBUTE_CODE			,
         CREATED_BY			,
         CREATION_DATE			,
         LAST_UPDATED_BY		,
         LAST_UPDATE_DATE		,
         LAST_UPDATE_LOGIN		,
	 RESP_APPLICATION_ID
      )
      values
      (
	 p_responsibility_id		,
         p_attribute_appl_id		,
         p_attribute_code		,
         p_created_by			,
         p_creation_date		,
         p_last_updated_by		,
         p_last_update_date		,
         p_last_update_login            ,
	 p_application_id
      );

-- taken out per Peter's suggestion

/*      if SQL%NOTFOUND
      then
         -- Unable to INSERT

         fnd_message.set_name('FND','SQL-NO INSERT');
         fnd_message.set_token('TABLE','FND_WEB_USERS');
         fnd_msg_pub.Add;
         raise FND_API.G_EXC_ERROR;
      end if;
*/
   end if;

   -- Standard check of p_commit;

   if FND_API.To_Boolean( p_commit)
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

      Rollback to Create_Resp_Excl_Attr_PVT;
      p_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get
      (
         p_count		=> p_msg_count,
         p_data			=> p_msg_data
      );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      Rollback to Create_Resp_Excl_Attr_PVT;
      p_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get
      (
         p_count		=> p_msg_count,
         p_data			=> p_msg_data
      );

   WHEN OTHERS THEN

      Rollback to Create_Resp_Excl_Attr_PVT;
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

end Create_Resp_Excl_Attr;



PROCEDURE Delete_Resp_Excl_Attr
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
   p_responsibility_id		IN	NUMBER,
   p_application_id		IN	NUMBER,
   p_attribute_code		IN	VARCHAR2,
   p_attribute_appl_id		IN	NUMBER
)
IS
l_api_name		CONSTANT VARCHAR2(30) := 'Delete_Resp_Excl_Attr';
l_api_version_number	CONSTANT NUMBER	      := 1.0;

BEGIN

   -- Standard Start of API savepoint

   SAVEPOINT Delete_Resp_Excl_Attr_PVT;

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

   Delete from AK_EXCLUDED_ITEMS
    where resp_application_id    = p_application_id
      and attribute_code    = p_attribute_code
      and responsibility_id = p_responsibility_id
      and attribute_application_id = p_attribute_appl_id;

   if SQL%NOTFOUND
   then

-- Need to replace message after creating messages through Rami
-- !!!!

      fnd_message.set_name('FND','SQL-NO DELETE');
      fnd_message.set_token('TABLE','FND_WEB_USER_RESPONSIBILITY');
      fnd_msg_pub.Add;
      raise FND_API.G_EXC_ERROR;
   end if;

   -- Standard check of p_commit;

   if FND_API.To_Boolean( p_commit)
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

      Rollback to Delete_Resp_Excl_Attr_PVT;
      p_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get
      (
         p_count		=> p_msg_count,
         p_data			=> p_msg_data
      );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      Rollback to Delete_Resp_Excl_Attr_PVT;
      p_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get
      (
         p_count		=> p_msg_count,
         p_data			=> p_msg_data
      );

   WHEN OTHERS THEN

      Rollback to Delete_Resp_Excl_Attr_PVT;
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

end Delete_Resp_Excl_Attr;


END ICX_Resp_Excl_Attr_PVT;

/
