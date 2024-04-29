--------------------------------------------------------
--  DDL for Package Body ICX_USER_SEC_ATTR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_USER_SEC_ATTR_PVT" AS
-- $Header: ICXVTUSB.pls 120.4 2005/10/26 14:08:59 tshort noship $

PROCEDURE Create_User_Sec_Attr
(  p_api_version_number		IN	NUMBER,
   p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
   p_simulate			IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit			IN	VARCHAR2 := FND_API.G_FALSE,
   p_validation_level		IN	NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_return_status		OUT NOCOPY	VARCHAR2,
   p_msg_count			OUT NOCOPY	NUMBER,
   p_msg_data			OUT NOCOPY	VARCHAR2,
--   p_msg_entity			OUT	VARCHAR2,
--   p_msg_entity_index		OUT	NUMBER,
   p_web_user_id                IN      NUMBER,
   p_attribute_code             IN      VARCHAR2,
   p_attribute_appl_id          IN      NUMBER,
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

l_duplicate			 NUMBER       := 0;

BEGIN
   -- Standard Start of API savepoint

   SAVEPOINT Create_User_Sec_Attr_PVT;

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
   -- VALIDATION - RESP_SEC_ATTR
   -- ************************************
--   select responsibility_id
   select count(*)
     into l_duplicate
     from ak_web_user_sec_attr_values
    where web_user_id       = p_web_user_id
      and attribute_code    = p_attribute_code
      and attribute_application_id = p_attribute_appl_id
      and ((varchar2_value  = p_varchar2_value)
	  or (varchar2_value is null and p_varchar2_value is null))
      and ((date_value      = p_date_value)
	  or (date_value is null and p_date_value is null))
      and ((number_value    = p_number_value)
	  or (number_value is null and p_number_value is null));

   if l_duplicate <> 0
--   if SQL%FOUND
   then
      -- responsibility-securing_attribute already exists

-- !!!!Need create message through Rami

      fnd_message.set_name('FND','SECURITY-DUPLICATE USER RESP');
      fnd_msg_pub.Add;
      raise FND_API.G_EXC_ERROR;
   else
      INSERT into AK_WEB_USER_SEC_ATTR_VALUES
      (
	 WEB_USER_ID			,
	 ATTRIBUTE_APPLICATION_ID	,
         ATTRIBUTE_CODE			,
	 VARCHAR2_VALUE			,
	 DATE_VALUE			,
	 NUMBER_VALUE			,
         CREATED_BY			,
         CREATION_DATE			,
         LAST_UPDATED_BY		,
         LAST_UPDATE_DATE		,
         LAST_UPDATE_LOGIN
      )
      values
      (
	 p_web_user_id			,
	 p_attribute_appl_id		,
         p_attribute_code		,
	 p_varchar2_value		,
	 p_date_value			,
	 p_number_value			,
         p_created_by			,
         p_creation_date		,
         p_last_updated_by		,
         p_last_update_date		,
         p_last_update_login
      );

-- taken out per Peter's suggestion

/*      if SQL%NOTFOUND
      then
         -- Unable to INSERT

         fnd_message.set_name('FND','SQL-NO INSERT');
         fnd_message.set_token('TABLE','FND_USER');
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

      Rollback to Create_User_Sec_Attr_PVT;
      p_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get
      (
         p_count		=> p_msg_count,
         p_data			=> p_msg_data
      );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      Rollback to Create_User_Sec_Attr_PVT;
      p_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get
      (
         p_count		=> p_msg_count,
         p_data			=> p_msg_data
      );

   WHEN OTHERS THEN

      Rollback to Create_User_Sec_Attr_PVT;
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
   p_simulate			IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit			IN	VARCHAR2 := FND_API.G_FALSE,
   p_validation_level		IN	NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_return_status		OUT NOCOPY	VARCHAR2,
   p_msg_count			OUT NOCOPY	NUMBER,
   p_msg_data			OUT NOCOPY	VARCHAR2,
--   p_msg_entity			OUT	VARCHAR2,
--   p_msg_entity_index		OUT	NUMBER,
   p_web_user_id                IN      NUMBER,
   p_attribute_code             IN      VARCHAR2,
   p_attribute_appl_id          IN      NUMBER,
   p_varchar2_value             IN      VARCHAR2,
   p_date_value                 IN      DATE,
   p_number_value               IN      NUMBER

)
IS
l_api_name		CONSTANT VARCHAR2(30) := 'Delete_User_Sec_Attr';
l_api_version_number	CONSTANT NUMBER	      := 1.0;

BEGIN

   -- Standard Start of API savepoint

   SAVEPOINT Delete_User_Sec_Attr_PVT;

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

   Delete from AK_WEB_USER_SEC_ATTR_VALUES
    where web_user_id 	    = p_web_user_id
      and attribute_code    = p_attribute_code
      and attribute_application_id = p_attribute_appl_id
      and ((varchar2_value  = p_varchar2_value)
	  or (varchar2_value is null and p_varchar2_value is null))
      and ((date_value	    = p_date_value)
	  or (date_value is null and p_date_value is null))
      and ((number_value    = p_number_value)
	  or (number_value is null and p_number_value is null));

   if SQL%NOTFOUND
   then

-- Need to replace message after creating messages through Rami
-- !!!!

      fnd_message.set_name('FND','SQL-NO DELETE');
      fnd_message.set_token('TABLE','FND_USER_RESPONSIBILITY');
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

      Rollback to Delete_User_Sec_Attr_PVT;
      p_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get
      (
         p_count		=> p_msg_count,
         p_data			=> p_msg_data
      );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      Rollback to Delete_User_Sec_Attr_PVT;
      p_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get
      (
         p_count		=> p_msg_count,
         p_data			=> p_msg_data
      );

   WHEN OTHERS THEN

      Rollback to Delete_User_Sec_Attr_PVT;
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

PROCEDURE Create_Def_User_Sec_Attr
(  p_api_version_number         IN      NUMBER,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE,
   p_simulate                   IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_web_user_id                    IN      NUMBER,
   p_resp_application_id	IN	NUMBER,
   p_responsibility_id          IN      NUMBER,
   p_created_by                 IN      NUMBER,
   p_creation_date              IN      DATE,
   p_last_updated_by            IN      NUMBER,
   p_last_update_date           IN      DATE,
   p_last_update_login          IN      NUMBER,
   p_return_status              OUT NOCOPY     VARCHAR2,
   p_msg_count                  OUT NOCOPY     NUMBER,
   p_msg_data                   OUT NOCOPY     VARCHAR2
) is

l_api_name              CONSTANT VARCHAR2(30) := 'Create_Def_User_Sec_Attr';
l_api_version_number    CONSTANT NUMBER       := 1.0;

l_customer_contact_id	number;
l_vendor_contact_id	number;
l_internal_contact_id	number;
l_data_type		varchar2(30);
l_varchar2_value	varchar2(240);
l_date_value		date;
l_number_value		number;

l_duplicate                      NUMBER       := 0;

l_return_status varchar2(1);
l_msg_count number;
l_msg_data varchar2(2000);

cursor cust_sec_attr is
        select  b.REGION_APPLICATION_ID,b.REGION_CODE,
                a.ATTRIBUTE_APPLICATION_ID,a.ATTRIBUTE_CODE
        from    AK_OBJECT_ATTRIBUTES c,
                AK_REGIONS b,
                AK_RESP_SECURITY_ATTRIBUTES a
        where   a.RESPONSIBILITY_ID = p_responsibility_id
        and     a.RESP_APPLICATION_ID = p_resp_application_id
        and     a.ATTRIBUTE_CODE = b.REGION_CODE
        and     b.DATABASE_OBJECT_NAME = c.DATABASE_OBJECT_NAME
        and     c.ATTRIBUTE_CODE = 'ICX_CUSTOMER_CONTACT_ID';

cursor int_sec_attr is
        select  b.REGION_APPLICATION_ID,b.REGION_CODE,
                a.ATTRIBUTE_APPLICATION_ID,a.ATTRIBUTE_CODE
        from    AK_OBJECT_ATTRIBUTES c,
                AK_REGIONS b,
                AK_RESP_SECURITY_ATTRIBUTES a
        where   a.RESPONSIBILITY_ID = p_responsibility_id
        and     a.RESP_APPLICATION_ID = p_resp_application_id
        and     a.ATTRIBUTE_CODE = b.REGION_CODE
        and     b.DATABASE_OBJECT_NAME = c.DATABASE_OBJECT_NAME
        and     c.ATTRIBUTE_CODE = 'ICX_INTERNAL_CONTACT_ID';

cursor supp_sec_attr is
        select  b.REGION_APPLICATION_ID,b.REGION_CODE,
                a.ATTRIBUTE_APPLICATION_ID,a.ATTRIBUTE_CODE
        from    AK_OBJECT_ATTRIBUTES c,
                AK_REGIONS b,
                AK_RESP_SECURITY_ATTRIBUTES a
        where   a.RESPONSIBILITY_ID = p_responsibility_id
        and     a.RESP_APPLICATION_ID = p_resp_application_id
        and     a.ATTRIBUTE_CODE = b.REGION_CODE
        and     b.DATABASE_OBJECT_NAME = c.DATABASE_OBJECT_NAME
        and     c.ATTRIBUTE_CODE = 'ICX_SUPPLIER_CONTACT_ID';

begin

   -- Standard Start of API savepoint

   SAVEPOINT Create_Def_User_Sec_Attr;

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
   -- VALIDATION - RESP_SEC_ATTR
   -- ************************************

select  CUSTOMER_ID,SUPPLIER_ID,EMPLOYEE_ID
into    l_customer_contact_id,l_vendor_contact_id,l_internal_contact_id
from    FND_USER
where   USER_ID = p_web_user_id;

if l_customer_contact_id is not null
then
for s in cust_sec_attr loop

ak_query_pkg.exec_query(
P_PARENT_REGION_APPL_ID => s.REGION_APPLICATION_ID,
P_PARENT_REGION_CODE => s.REGION_CODE,
P_WHERE_CLAUSE => 'CONTACT_ID = '||l_customer_contact_id,
P_RETURN_PARENTS => 'T',
P_RETURN_CHILDREN => 'F');

-- icx_on_utilities2.printPLSQLtables;

select    DATA_TYPE
into      l_data_type
from      AK_ATTRIBUTES
where     ATTRIBUTE_CODE = s.ATTRIBUTE_CODE
and       ATTRIBUTE_APPLICATION_ID = s.ATTRIBUTE_APPLICATION_ID;

for r in ak_query_pkg.g_results_table.FIRST..ak_query_pkg.g_results_table.LAST loop
    if l_data_type = 'NUMBER'
    then
	l_varchar2_value := '';
	l_date_value := '';
	l_number_value := to_number(ak_query_pkg.g_results_table(r).value1);
    elsif l_data_type = 'DATE'
    then
        l_varchar2_value := '';
        l_date_value := to_date(ak_query_pkg.g_results_table(r).value1,icx_sec.getID(icx_sec.PV_DATE_FORMAT));
        l_number_value := '';
    else
        l_varchar2_value := ak_query_pkg.g_results_table(r).value1;
        l_date_value := '';
        l_number_value := '';
    end if;

    ICX_User_Sec_Attr_PVT.Create_User_Sec_Attr(
        p_api_version_number    => 1.0,
        p_init_msg_list         => 'T',
        p_commit                => 'T',
        p_return_status         => l_return_status,
        p_msg_count             => l_msg_count,
        p_msg_data              => l_msg_data,
        p_web_user_id           => p_web_user_id,
        p_attribute_code        => s.ATTRIBUTE_CODE,
        p_attribute_appl_id     => s.ATTRIBUTE_APPLICATION_ID,
        p_varchar2_value        => l_varchar2_value,
        p_date_value            => l_date_value,
        p_number_value          => l_number_value,
        p_created_by            => p_created_by,
        p_creation_date         => p_creation_date,
        p_last_updated_by       => p_last_updated_by,
        p_last_update_date      => p_last_update_date,
        p_last_update_login     => p_last_update_login);

end loop; -- results

end loop; -- cust_sec_attr
end if;

if l_internal_contact_id is not null
then
for s in int_sec_attr loop

ak_query_pkg.exec_query(
P_PARENT_REGION_APPL_ID => s.REGION_APPLICATION_ID,
P_PARENT_REGION_CODE => s.REGION_CODE,
P_WHERE_CLAUSE => 'CONTACT_ID = '||l_internal_contact_id,
P_RETURN_PARENTS => 'T',
P_RETURN_CHILDREN => 'F');

-- icx_on_utilities2.printPLSQLtables;

select    DATA_TYPE
into      l_data_type
from      AK_ATTRIBUTES
where     ATTRIBUTE_CODE = s.ATTRIBUTE_CODE
and       ATTRIBUTE_APPLICATION_ID = s.ATTRIBUTE_APPLICATION_ID;

for r in ak_query_pkg.g_results_table.FIRST..ak_query_pkg.g_results_table.LAST loop
    if l_data_type = 'NUMBER'
    then
        l_varchar2_value := '';
        l_date_value := '';
        l_number_value := to_number(ak_query_pkg.g_results_table(r).value1);
    elsif l_data_type = 'DATE'
    then
        l_varchar2_value := '';
        l_date_value := to_date(ak_query_pkg.g_results_table(r).value1,icx_sec.getID(icx_sec.PV_DATE_FORMAT));
        l_number_value := '';
    else
        l_varchar2_value := ak_query_pkg.g_results_table(r).value1;
        l_date_value := '';
        l_number_value := '';
    end if;

    ICX_User_Sec_Attr_PVT.Create_User_Sec_Attr(
        p_api_version_number    => 1.0,
        p_init_msg_list         => 'T',
        p_commit                => 'T',
        p_return_status         => l_return_status,
        p_msg_count             => l_msg_count,
        p_msg_data              => l_msg_data,
        p_web_user_id           => p_web_user_id,
        p_attribute_code        => s.ATTRIBUTE_CODE,
        p_attribute_appl_id     => s.ATTRIBUTE_APPLICATION_ID,
        p_varchar2_value        => l_varchar2_value,
        p_date_value            => l_date_value,
        p_number_value          => l_number_value,
        p_created_by            => p_created_by,
        p_creation_date         => p_creation_date,
        p_last_updated_by       => p_last_updated_by,
        p_last_update_date      => p_last_update_date,
        p_last_update_login     => p_last_update_login);

end loop; -- results

end loop; -- int_sec_attr
end if;

if l_vendor_contact_id is not null
then
for s in supp_sec_attr loop

ak_query_pkg.exec_query(
P_PARENT_REGION_APPL_ID => s.REGION_APPLICATION_ID,
P_PARENT_REGION_CODE => s.REGION_CODE,
P_WHERE_CLAUSE => 'CONTACT_ID = '||l_vendor_contact_id,
P_RETURN_PARENTS => 'T',
P_RETURN_CHILDREN => 'F');

-- icx_on_utilities2.printPLSQLtables;

select    DATA_TYPE
into      l_data_type
from      AK_ATTRIBUTES
where     ATTRIBUTE_CODE = s.ATTRIBUTE_CODE
and       ATTRIBUTE_APPLICATION_ID = s.ATTRIBUTE_APPLICATION_ID;

for r in ak_query_pkg.g_results_table.FIRST..ak_query_pkg.g_results_table.LAST loop
    if l_data_type = 'NUMBER'
    then
        l_varchar2_value := '';
        l_date_value := '';
        l_number_value := to_number(ak_query_pkg.g_results_table(r).value1);
    elsif l_data_type = 'DATE'
    then
        l_varchar2_value := '';
        l_date_value := to_date(ak_query_pkg.g_results_table(r).value1,icx_sec.getID(icx_sec.PV_DATE_FORMAT));
        l_number_value := '';
    else
        l_varchar2_value := ak_query_pkg.g_results_table(r).value1;
        l_date_value := '';
        l_number_value := '';
    end if;

    ICX_User_Sec_Attr_PVT.Create_User_Sec_Attr(
        p_api_version_number    => 1.0,
        p_init_msg_list         => 'T',
        p_commit                => 'T',
        p_return_status         => l_return_status,
        p_msg_count             => l_msg_count,
        p_msg_data              => l_msg_data,
        p_web_user_id           => p_web_user_id,
        p_attribute_code        => s.ATTRIBUTE_CODE,
        p_attribute_appl_id     => s.ATTRIBUTE_APPLICATION_ID,
        p_varchar2_value        => l_varchar2_value,
        p_date_value            => l_date_value,
        p_number_value          => l_number_value,
        p_created_by            => p_created_by,
        p_creation_date         => p_creation_date,
        p_last_updated_by       => p_last_updated_by,
        p_last_update_date      => p_last_update_date,
        p_last_update_login     => p_last_update_login);

end loop; -- results

end loop; -- supp_sec_attr
end if;


/*
   if l_duplicate <> 0
   then
      -- responsibility-securing_attribute already exists

-- !!!!Need create message through Rami

      fnd_message.set_name('FND','SECURITY-DUPLICATE USER RESP');
      fnd_msg_pub.Add;
      raise FND_API.G_EXC_ERROR;
   else
   end if;
*/

   -- Standard check of p_commit;

   if FND_API.To_Boolean( p_commit)
   then
      commit work;
   end if;

   -- Standard call to get message count and if count is 1, get message info.

   FND_MSG_PUB.Count_And_Get
   (
      p_count           => p_msg_count,
      p_data            => p_msg_data
   );

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

      Rollback to Create_Def_User_Sec_Attr;
      p_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get
      (
         p_count                => p_msg_count,
         p_data                 => p_msg_data
      );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      Rollback to Create_Def_User_Sec_Attr;
      p_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get
      (
         p_count                => p_msg_count,
         p_data                 => p_msg_data
      );

   WHEN OTHERS THEN

      Rollback to Create_Def_User_Sec_Attr;
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
         p_count                => p_msg_count,
         p_data                 => p_msg_data
      );

end Create_Def_User_Sec_Attr;

end ICX_User_Sec_Attr_PVT;

/
