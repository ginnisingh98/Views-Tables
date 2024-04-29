--------------------------------------------------------
--  DDL for Package Body IBE_WF_NOTIF_SETUP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_WF_NOTIF_SETUP_PVT" as
/* $Header: IBEVWFNB.pls 120.2 2005/07/25 12:35:02 appldev ship $ */


g_debug boolean := TRUE;

procedure debug(p_msg VARCHAR2)
IS
BEGIN
   if( g_debug = TRUE ) then
--	dbms_output.put_line(p_msg);
    null;
  end if;
end;

procedure INSERT_ROW (

  X_ROWID in out NOCOPY VARCHAR2,
  P_NOTIF_SETUP_ID in NUMBER,
  P_ORG_ID_FLAG in VARCHAR2,
  P_MSITE_ID_FLAG in VARCHAR2,
  P_USER_TYPE_FLAG in VARCHAR2,
  P_ENABLED_FLAG in VARCHAR2,
  P_DEFAULT_MESSAGE_NAME in VARCHAR2,
  P_UPDATE_ENABLED_FLAG in VARCHAR2,
  P_OBJECT_VERSION_NUMBER in NUMBER,
  P_NOTIFICATION_NAME in VARCHAR2,
  p_customized_flag IN VARCHAR2,
  P_CREATION_DATE in DATE,
  P_CREATED_BY in NUMBER,
  P_LAST_UPDATE_DATE in DATE,
  P_LAST_UPDATED_BY in NUMBER,
  P_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is
    select ROWID
    from IBE_WF_NOTIF_SETUP
    where NOTIF_SETUP_ID = p_NOTIF_SETUP_ID;
begin
  insert into IBE_WF_NOTIF_SETUP (
    NOTIF_SETUP_ID,
    NOTIFICATION_NAME,
    ORG_ID_FLAG,
    MSITE_ID_FLAG,
    USER_TYPE_FLAG,
    ENABLED_FLAG,
    DEFAULT_MESSAGE_NAME,
    UPDATE_ENABLED_FLAG,
    CUSTOMIZED_FLAG,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER
  ) select
    P_NOTIF_SETUP_ID,
    P_NOTIFICATION_NAME,
    P_ORG_ID_FLAG,
    P_MSITE_ID_FLAG,
    P_USER_TYPE_FLAG,
    P_ENABLED_FLAG,
    P_DEFAULT_MESSAGE_NAME,
    P_UPDATE_ENABLED_FLAG,
    P_CUSTOMIZED_FLAG,
    P_CREATED_BY,
    P_CREATION_DATE,
    P_LAST_UPDATED_BY,
    P_LAST_UPDATE_DATE,
    P_LAST_UPDATE_LOGIN,
    P_OBJECT_VERSION_NUMBER
 FROM DUAL
 WHERE not exists
    (select NULL
    from IBE_WF_NOTIF_SETUP T
    where T.NOTIF_SETUP_ID = P_NOTIF_SETUP_ID);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;
end INSERT_ROW;

procedure LOCK_ROW (
  P_NOTIF_SETUP_ID in NUMBER,
  P_ORG_ID_FLAG in VARCHAR2,
  P_MSITE_ID_FLAG in VARCHAR2,
  P_USER_TYPE_FLAG in VARCHAR2,
  P_ENABLED_FLAG in VARCHAR2,
  P_DEFAULT_MESSAGE_NAME in VARCHAR2,
  P_UPDATE_ENABLED_FLAG in VARCHAR2,
  P_OBJECT_VERSION_NUMBER in NUMBER,
  P_NOTIFICATION_NAME in VARCHAR2,
  P_CUSTOMIZED_FLAG  IN VARCHAR2
) is
  cursor c1 is select
      ORG_ID_FLAG,
      MSITE_ID_FLAG,
      USER_TYPE_FLAG,
      ENABLED_FLAG,
      DEFAULT_MESSAGE_NAME,
      UPDATE_ENABLED_FLAG,
      OBJECT_VERSION_NUMBER,
      NOTIFICATION_NAME,
      CUSTOMIZED_FLAG
    from IBE_WF_NOTIF_SETUP
    where NOTIF_SETUP_ID = p_NOTIF_SETUP_ID
    for update of NOTIF_SETUP_ID nowait;
begin
  for tlinfo in c1 loop
      if (    (tlinfo.NOTIFICATION_NAME = P_NOTIFICATION_NAME)
          AND (tlinfo.ORG_ID_FLAG = P_ORG_ID_FLAG)
          AND (tlinfo.MSITE_ID_FLAG = P_MSITE_ID_FLAG)
          AND (tlinfo.USER_TYPE_FLAG = P_USER_TYPE_FLAG)
          AND (tlinfo.ENABLED_FLAG = P_ENABLED_FLAG)
          AND (tlinfo.DEFAULT_MESSAGE_NAME = P_DEFAULT_MESSAGE_NAME)
          AND (tlinfo.CUSTOMIZED_FLAG = P_CUSTOMIZED_FLAG)
          AND (tlinfo.UPDATE_ENABLED_FLAG = P_UPDATE_ENABLED_FLAG)
          AND ((tlinfo.OBJECT_VERSION_NUMBER = P_OBJECT_VERSION_NUMBER)
               OR ((tlinfo.OBJECT_VERSION_NUMBER is null) AND (P_OBJECT_VERSION_NUMBER is null)))
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
  end loop;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  P_NOTIF_SETUP_ID in NUMBER,
  P_ORG_ID_FLAG in VARCHAR2,
  P_MSITE_ID_FLAG in VARCHAR2,
  P_USER_TYPE_FLAG in VARCHAR2,
  P_ENABLED_FLAG in VARCHAR2,
  P_DEFAULT_MESSAGE_NAME in VARCHAR2,
  P_UPDATE_ENABLED_FLAG in VARCHAR2,
  P_OBJECT_VERSION_NUMBER in NUMBER,
  P_NOTIFICATION_NAME in VARCHAR2,
  P_CUSTOMIZED_FLAG IN VARCHAR2,
  P_LAST_UPDATE_DATE in DATE,
  P_LAST_UPDATED_BY in NUMBER,
  P_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  --debug('update_row 1');
  --debug('p_notif_setup_id is ' || p_notif_setup_id);
  --debug('p_notification_name is ' || p_notification_name);
  update IBE_WF_NOTIF_SETUP set
    ORG_ID_FLAG = P_ORG_ID_FLAG,
    MSITE_ID_FLAG = P_MSITE_ID_FLAG,
    USER_TYPE_FLAG = p_USER_TYPE_FLAG,
    ENABLED_FLAG = P_ENABLED_FLAG,
    DEFAULT_MESSAGE_NAME = P_DEFAULT_MESSAGE_NAME,
    UPDATE_ENABLED_FLAG = P_UPDATE_ENABLED_FLAG,
    OBJECT_VERSION_NUMBER = P_OBJECT_VERSION_NUMBER,
    NOTIFICATION_NAME = P_NOTIFICATION_NAME,
    CUSTOMIZED_FLAG = P_CUSTOMIZED_FLAG,
    LAST_UPDATE_DATE = P_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = P_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = P_LAST_UPDATE_LOGIN
  where NOTIF_SETUP_ID = P_NOTIF_SETUP_ID;

  --debug('update_row 2');
  if (sql%notfound) then
     --debug('update_row 3');
    FND_MESSAGE.SET_NAME('IBE', 'IBE_WF_NOTIF_NAME_NOT_FOUND');
    FND_MESSAGE.SET_NAME('NAME', p_notification_name);
    FND_MSG_PUB.ADD;
    raise no_data_found;
  end if;
  --debug('update_row 4');
end UPDATE_ROW;

procedure DELETE_ROW (
  P_NOTIF_SETUP_ID in NUMBER
) is
begin
  delete from IBE_WF_NOTIF_SETUP
  where NOTIF_SETUP_ID = p_NOTIF_SETUP_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
EXCEPTION
  when NO_DATA_FOUND then
    FND_MESSAGE.SET_NAME('IBE', 'IBE_WF_NOTIF_NOT_FOUND');
    FND_MESSAGE.SET_TOKEN('ID', p_notif_setup_id);
    FND_MSG_PUB.ADD;
end DELETE_ROW;

procedure LOAD_ROW(
  P_NOTIF_SETUP_ID in NUMBER,
  P_OWNER	   IN VARCHAR2,
  P_ORG_ID_FLAG in VARCHAR2,
  P_MSITE_ID_FLAG in VARCHAR2,
  P_USER_TYPE_FLAG in VARCHAR2,
  P_ENABLED_FLAG in VARCHAR2,
  P_DEFAULT_MESSAGE_NAME in VARCHAR2,
  P_UPDATE_ENABLED_FLAG in VARCHAR2,
  P_OBJECT_VERSION_NUMBER in NUMBER,
  p_customized_flag IN VARCHAR2,
  P_NOTIFICATION_NAME in VARCHAR2,
  P_LAST_UPDATE_DATE in varchar2,
  P_CUSTOM_MODE  in Varchar2) IS

 l_row_id VARCHAR2(64);
 l_enabled_flag VARCHAR2(1);

 f_luby    number;  -- entity owner in file
 f_ludate  date;    -- entity update date in file
 db_luby   number;  -- entity owner in db
 db_ludate date;    -- entity update date in db

BEGIN

 -- Translate owner to file_last_updated_by
 f_luby := fnd_load_util.owner_id(P_OWNER);
 -- Translate char last_update_date to date
 f_ludate := nvl(to_date(P_LAST_UPDATE_DATE, 'YYYY/MM/DD'), sysdate);

 select LAST_UPDATED_BY, LAST_UPDATE_DATE
   	into db_luby, db_ludate
  	from IBE_WF_NOTIF_SETUP
   	where notif_setup_id = P_NOTIF_SETUP_ID;

 --Invoke standard merge comparison routine UPLOAD_TEST to determine whether to upload or not
IF (fnd_load_util.upload_test(f_luby, f_ludate, db_luby, db_ludate, P_CUSTOM_MODE)) then
  --dbms_output.put_line('l_merge_data is true');
  if( p_customized_flag = 'Y' ) then
      BEGIN
	       select enabled_flag
	       into l_enabled_flag
	       from ibe_wf_notif_setup
	       where notif_setup_id = p_notif_setup_id;
      EXCEPTION
	   when no_data_found then
	   raise no_data_found;
      END;
     update_row(
	   p_notif_setup_id	=> p_notif_Setup_id,
	   p_org_id_flag		=> p_org_id_flag,
	   p_msite_id_flag		=> p_msite_id_flag,
	   p_user_type_flag	=> p_user_type_flag,
	   p_enabled_flag		=> l_enabled_flag,
	   p_default_message_name	=> p_default_message_name,
	   p_update_enabled_flag	=> p_update_enabled_flag,
	   p_object_version_number => p_object_version_number,
	   p_notification_name	=> p_notification_name,
	   p_customized_flag	=> p_customized_flag,
	   p_last_update_date	=> f_ludate, --sysdate,
	   p_last_updated_by	=> f_luby,--user_id,
	   p_last_update_login	=> f_luby);--user_id);
  else
      update_row(
	   p_notif_setup_id	=> p_notif_Setup_id,
	   p_org_id_flag		=> p_org_id_flag,
	   p_msite_id_flag		=> p_msite_id_flag,
	   p_user_type_flag	=> p_user_type_flag,
	   p_enabled_flag		=> p_enabled_flag,
	   p_default_message_name	=> p_default_message_name,
	   p_update_enabled_flag	=> p_update_enabled_flag,
	   p_object_version_number => p_object_version_number,
	   p_notification_name	=> p_notification_name,
	   p_customized_flag	=> p_customized_flag,
	   p_last_update_date	=> f_ludate, --sysdate,
	   p_last_updated_by	=> f_luby,--user_id,
	   p_last_update_login	=> f_luby);--user_id);
  end if;
  --dbms_output.put_line('after update');
 END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
     insert_row(
        X_ROWID 		    => l_row_id,
        P_NOTIF_SETUP_ID 	=> p_notif_Setup_id,
        P_ORG_ID_FLAG 		=> p_org_id_flag,
        P_MSITE_ID_FLAG 	=> p_msite_id_flag,
        P_USER_TYPE_FLAG 	=> p_user_type_flag,
        P_ENABLED_FLAG 		=> p_enabled_flag,
        P_DEFAULT_MESSAGE_NAME  => p_default_message_name,
        P_UPDATE_ENABLED_FLAG 	=> p_update_enabled_flag,
        P_OBJECT_VERSION_NUMBER => p_object_version_number,
        P_NOTIFICATION_NAME 	=> p_notification_name,
        p_customized_flag 	=> p_customized_flag,
        P_CREATION_DATE 	=> f_ludate, --sysdate,
        P_CREATED_BY 		=> f_luby,--user_id,
        P_LAST_UPDATE_DATE 	=> f_ludate, --sysdate,
        P_LAST_UPDATED_BY 	=> f_luby,--user_id,
        P_LAST_UPDATE_LOGIN => f_luby);--user_id);

END LOAD_ROW;

function Check_Notif_Duplicate(
   p_notification_name IN VARCHAR2)
RETURN BOOLEAN IS
   l_exists VARCHAR2(1) := '0';
   l_return_status VARCHAR2(1);
BEGIN
   --debug('in Validate_Name ' || p_notification_name);
   select '1'
   into l_exists
   from dual
   where exists(
	  select distinct notification_name
	  from ibe_wf_notif_setup
	  where notification_name = p_notification_name);

   if( l_exists = '1' ) then
       FND_MESSAGE.SET_NAME('IBE', 'IBE_WF_DUP_NOTIF_SETUP');
       FND_MESSAGE.SET_TOKEN('NAME', p_notification_name);
       FND_MSG_PUB.ADD;
       return FALSE;
   else
       return TRUE;
   end if;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
     --dbms_output.put_line('return true');
       return TRUE;
END;

FUNCTION Check_Notif_Exists(
   p_notif_setup_id IN NUMBER,
   p_object_version_number IN NUMBER := FND_API.G_MISS_NUM) RETURN BOOLEAN
IS
  l_exists VARCHAR2(1) := '0';
BEGIN
  if( p_object_version_number = FND_API.G_MISS_NUM  OR p_object_version_number is NULL ) then
      select '1'
      into l_exists
      From Dual
      where exists(
          select notif_setup_id, object_version_number, notification_name
          from ibe_wf_notif_setup
          where notif_setup_id = p_notif_setup_id);

      if( l_exists = '1' ) then
         return TRUE;
      else
	  FND_MESSAGE.SET_NAME('IBE', 'IBE_WF_NOTIF_NOT_FOUND');
          FND_MESSAGE.SET_TOKEN('ID', to_char(p_notif_setup_id));
	  FND_MSG_PUB.ADD;
	  return false;
      END if;
   else
      select '1'
      into l_exists
      From Dual
      where exists(
          select notif_setup_id, object_version_number, notification_name
          from ibe_wf_notif_setup
          where notif_setup_id = p_notif_setup_id
	  And object_version_number = p_object_version_number);

      if( l_exists = '1' ) then
         return TRUE;
      else
	  FND_MESSAGE.SET_NAME('IBE', 'IBE_WF_NOTIF_VER_NOT_MATCH');
	  FND_MESSAGE.SET_TOKEN('ID', to_char(p_notif_setup_id));
	  FND_MSG_PUB.ADD;
	  return false;
      END if;
   end if;

EXCEPTION
   when NO_DATA_FOUND then
	 FND_MESSAGE.SET_NAME('IBE', 'IBE_WF_NOTIF_NOT_FOUND');
	 FND_MESSAGE.SET_TOKEN('ID', p_notif_setup_id);
	 FND_MSG_PUB.ADD;
      return FALSE;
END;


procedure Save_WF_NOTIF_Setup(
   p_api_version        	IN NUMBER,
   p_init_msg_list      	IN VARCHAR2 := FND_API.G_FALSE,
   p_commit             	IN VARCHAR2 := FND_API.G_FALSE,
   x_return_status      	OUT NOCOPY VARCHAR2,
   x_msg_count          	OUT NOCOPY NUMBER,
   x_msg_data           	OUT NOCOPY VARCHAR2,
   P_NOTIF_SETUP_ID 		in NUMBER,
   P_ORG_ID_FLAG 		in VARCHAR2,
   P_MSITE_ID_FLAG 		in VARCHAR2,
   P_USER_TYPE_FLAG 		in VARCHAR2,
   P_ENABLED_FLAG 		in VARCHAR2,
   P_DEFAULT_MESSAGE_NAME 	in VARCHAR2,
   P_UPDATE_ENABLED_FLAG 	in VARCHAR2,
   p_object_version_number	IN NUMBER := FND_API.G_MISS_NUM,
   P_NOTIFICATION_NAME 		in VARCHAR2,
   p_customized_flag		IN VARCHAR2
) IS
   l_api_name 		CONSTANT VARCHAR2(30) := 'save_wf_notif_setup';
   l_full_name 		CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
   l_operation_type 	VARCHAR2(10) := 'INSERT';
   l_return_status 	VARCHAR2(1);
   l_msg_data		VARCHAR2(2000);
   l_msg_count		NUMBER;
   l_notif_setup_id	NUMBER;
   l_notification_name  VARCHAR2(30);
   l_exists		VARCHAr2(1);
   l_object_version_number NUMBER;
   cursor wf_setup_seq IS
	select ibe_wf_notif_setup_s1.nextval
        From dual;
   l_rowid 	ROWID;
BEGIN
   --debug('Save_wf_notif_setup 1');
   savepoint save_wf_notif_setup;

   if NOT FND_API.Compatible_Api_Call(g_api_version, p_api_version, l_api_name, g_pkg_name) THEN
   --debug('Save_wf_notif_setup 2');
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   if FND_API.To_Boolean(p_init_msg_list) then
   --debug('Save_wf_notif_setup 3');
      FND_MSG_PUB.initialize;
   end if;

   --debug('Save_wf_notif_setup 4');
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   if p_notif_setup_id IS NOT NULL THEN
      --debug('Save_wf_notif_setup 5');
      if( check_notif_exists(p_notif_setup_id, p_object_version_number) = TRUE ) then
         l_operation_type :='UPDATE';
         if( p_object_version_number = FND_API.G_MISS_NUM ) then
             select object_version_number
	     into l_object_version_number
    	     from ibe_wf_notif_setup
             where notif_setup_id = p_notif_setup_id;
         else
	     l_object_version_number := p_object_version_number;
         end if;
         l_object_version_number := l_object_version_number +1;
      else
	 raise FND_API.G_EXC_ERROR;
      end if;
   end if;

   if( p_notification_name is not null AND l_operation_type = 'INSERT') then
   --debug('Save_wf_notif_setup 6');
       if( check_notif_duplicate(p_notification_name) <> TRUE ) then
          --debug('save_wf_notif_setup 7');
	  raise FND_API.G_EXC_ERROR;
       end if;
          --debug('save_wf_notif_setup 7a');

   elsif( p_notification_name is null AND l_operation_type = 'INSERT') then

          --debug('save_wf_notif_setup 9');
       FND_MESSAGE.SET_NAME('IBE', 'IBE_WF_REQUIRED_NOTIF_NAME');
       FND_MESSAGE.SET_TOKEN('NAME', p_notification_name);
       FND_MSG_PUB.ADD;
       raise FND_API.G_EXC_ERROR;
   end if;

          --debug('save_wf_notif_setup 10');
   -- now validate if all parameters that are required is not null

   if( p_org_id_flag is null ) then
	FND_MESSAGE.SET_NAME('IBE', 'IBE_WF_REQUIRED_FIELD');
	FND_MESSAGE.SET_TOKEN('NAME', 'ORG_ID_FLAG');
        FND_MSG_PUB.ADD;
        raise FND_API.G_EXC_ERROR;
   elsif( p_msite_id_flag is null ) THEN
	FND_MESSAGE.SET_NAME('IBE', 'IBE_WF_REQUIRED_FIELD');
	FND_MESSAGE.SET_TOKEN('NAME', 'MSITE_ID_FLAG');
        FND_MSG_PUB.ADD;
        raise FND_API.G_EXC_ERROR;
   elsif( p_user_type_flag is null ) THEN
	FND_MESSAGE.SET_NAME('IBE', 'IBE_WF_REQUIRED_FIELD');
	FND_MESSAGE.SET_TOKEN('NAME', 'USER_TYPE_FLAG');
        FND_MSG_PUB.ADD;
        raise FND_API.G_EXC_ERROR;
   elsif( p_enabled_flag is null ) THEN
	FND_MESSAGE.SET_NAME('IBE', 'IBE_WF_REQUIRED_FIELD');
	FND_MESSAGE.SET_TOKEN('NAME', 'ENABLED_FLAG');
        FND_MSG_PUB.ADD;
        raise FND_API.G_EXC_ERROR;
   elsif( p_default_MESSAGE_NAME is null ) THEN
	FND_MESSAGE.SET_NAME('IBE', 'IBE_WF_REQUIRED_FIELD');
	FND_MESSAGE.SET_TOKEN('NAME', 'DEFAULT_MESSAGE_NAME');
        FND_MSG_PUB.ADD;
        raise FND_API.G_EXC_ERROR;
   end if;

   if( l_operation_type = 'INSERT' ) THEN
          --debug('save_wf_notif_setup 11');
	if( p_customized_flag = 'Y' ) then
            open wf_setup_seq;
            fetch wf_setup_seq into l_notif_setup_id;
            close wf_setup_seq;
            --debug('save_wf_notif_setup 12');
	elsif( p_customized_flag = 'N' ) then
	   BEGIN
	       select nvl(max(notif_setup_id) , 0)
	       into l_notif_setup_id
	       from ibe_wf_notif_setup;
	   EXCEPTION
	       when no_data_found THEN
		l_notif_setup_id := 0;
	   END;
	   l_notif_setup_id := l_notif_Setup_id + 1;

        end if;

        insert_row(
  	    X_ROWID 			=> l_rowid,
            P_NOTIF_SETUP_ID 		=> l_notif_setup_id,
            P_ORG_ID_FLAG 		=> p_org_id_flag,
            P_MSITE_ID_FLAG 		=> p_msite_id_flag,
            P_USER_TYPE_FLAG 		=> p_user_type_flag,
            P_ENABLED_FLAG 		=> p_enabled_flag,
            P_DEFAULT_MESSAGE_NAME 	=> p_default_MESSAGE_NAME,
            P_UPDATE_ENABLED_FLAG 	=> p_UPDATE_ENABLED_FLAG,
            P_OBJECT_VERSION_NUMBER 	=> 1,
            P_NOTIFICATION_NAME 	=> p_notification_name,
	    p_customized_flag		=> p_customized_flag,
            P_CREATION_DATE 		=> sysdate,
            P_CREATED_BY 		=> FND_GLOBAL.user_id,
            P_LAST_UPDATE_DATE 		=> sysdate,
            P_LAST_UPDATED_BY 		=> FND_GLOBAL.user_id,
            P_LAST_UPDATE_LOGIN 	=> FND_GLOBAL.user_id
        );
          --debug('save_wf_notif_setup 13');
    elsif( l_operation_type = 'UPDATE') then
          --debug('save_wf_notif_setup 14');
        l_notif_setup_id := p_notif_setup_id;
	update_row(
  	    P_NOTIF_SETUP_ID 		=> l_notif_setup_id,
            P_ORG_ID_FLAG 		=> p_org_id_flag,
            P_MSITE_ID_FLAG 		=> p_msite_id_flag,
            P_USER_TYPE_FLAG 		=> p_user_type_flag,
            P_ENABLED_FLAG 		=> p_enabled_flag,
            P_DEFAULT_MESSAGE_NAME 	=> p_default_MESSAGE_NAME,
            P_UPDATE_ENABLED_FLAG 	=> p_UPDATE_ENABLED_FLAG,
            P_OBJECT_VERSION_NUMBER 	=> l_object_version_number,
            P_NOTIFICATION_NAME 	=> p_notification_name,
	    p_customized_flag		=> p_customized_flag,
            P_LAST_UPDATE_DATE 		=> sysdate,
            P_LAST_UPDATED_BY 		=> FND_GLOBAL.user_id,
            P_LAST_UPDATE_LOGIN 	=> FND_GLOBAL.user_id
        );
          --debug('save_wf_notif_setup 15');
    end if;

    if FND_API.to_Boolean(p_commit) THEN
          --debug('save_wf_notif_setup 16');
	commit;
    end if;

          --debug('save_wf_notif_setup 17');
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    FND_MSG_PUB.COUNT_AND_GET(p_encoded => FND_API.G_FALSE, P_COUNT => X_MSG_COUNT, P_DATA => X_MSG_DATA);
    if( x_msg_count > 1 ) then
        x_msg_data := FND_MSG_PUB.GET(1, FND_API.G_FALSE);
     end if;
          --debug('save_wf_notif_setup 18');
EXCEPTION
    when FND_API.G_EXC_ERROR THEN
	rollback to save_wf_notif_setup;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.COUNT_AND_GET(p_encoded => FND_API.G_FALSE, P_COUNT => X_MSG_COUNT, P_DATA => X_MSG_DATA);
	if( x_msg_count > 1 ) then
            x_msg_data := FND_MSG_PUB.GET(1, FND_API.G_FALSE);
	end if;
    when FND_API.G_EXC_UNEXPECTED_ERROR THEN
	rollback to save_wf_notif_setup;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.COUNT_AND_GET(p_encoded => FND_API.G_FALSE, P_COUNT => X_MSG_COUNT, P_DATA => X_MSG_DATA);
	if( x_msg_count > 1 ) then
            x_msg_data := FND_MSG_PUB.GET(1, FND_API.G_FALSE);
	end if;

    when OTHERS then
	rollback to save_wf_notif_setup;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        if FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
           FND_MSG_PUB.ADD_EXC_MSG(g_pkg_name, l_api_name);
        end if;
        FND_MSG_PUB.COUNT_AND_GET(p_encoded => FND_API.G_FALSE, P_COUNT => X_MSG_COUNT, P_DATA => X_MSG_DATA);
	if( x_msg_count > 1 ) then
            x_msg_data := FND_MSG_PUB.GET(1, FND_API.G_FALSE);
	end if;
END save_wf_notif_setup;

PROCEDURE delete_wf_notif_setup
(
	p_api_version		IN NUMBER,
	p_init_msg_list		IN VARCHAR2 := FND_API.G_FALSE,
	p_commit		IN VARCHAR2 := FND_API.G_FALSE,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_notification_name	IN VARCHAR2
) IS
  cursor wf_notif_setup(p_notification_name in VARCHAR2) is
     select notif_setup_id
     From IBE_WF_NOTIF_SETUP
     where notification_name = p_notification_name;

  cursor wf_notif_msg_maps(p_notif_setup_id IN NUMBER) IS
     select notif_msg_map_id, notification_name, message_name
     From ibe_wf_notif_msg_maps
     where notif_setup_id = p_notif_setup_id;
     --And default_msg_map_flag <> 'Y';

   l_notif_Setup_id 	NUMBER;
   l_api_name 		CONSTANT VARCHAR2(30) := 'delete_wf_notif_setup';
   l_notification_name VARCHAR2(30);
   l_message_name 	VARCHAR2(30);
   l_notif_msg_map_id	NUMBER;
   l_return_status 	VARCHAR2(1);
BEGIN
 -- null;
  savepoint delete_wf_notif_setup;

  IF NOT FND_API.compatible_api_call(g_api_version, p_api_version, l_api_name, g_pkg_name ) THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  if( p_notification_name IS NOT NULL ) THEN
     OPEN wf_notif_setup(p_notification_name);
     FETCH WF_NOTIF_SETUP into l_notif_setup_id;
     CLOSE WF_NOTIF_SETUP;

     open wf_notif_msg_maps(l_notif_setup_id);
     LOOP
	fetch wf_notif_msg_maps into l_notif_msg_map_id, l_notification_name, l_message_name;
	exit when wf_Notif_Msg_Maps%NOTFOUND;

        IBE_WF_NOTIF_MSG_MAPS_PVT.Delete_Wf_Notif_Msg_MAPS(
	   p_api_version		=> 1.0,
	   p_init_msg_list		=> FND_API.G_FALSE,
	   p_commit			=> FND_API.G_FALSE,
	   x_return_status		=> l_return_status,
	   x_msg_count			=> x_msg_count,
	   x_msg_data			=> x_msg_data,
	   p_notification_name		=> p_notification_name,
           p_notif_msg_map_id		=> l_notif_msg_map_id,
	   p_message_name		=> l_message_name);

	if( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
	   raise FND_API.G_EXC_ERROR;
	end if;
     END LOOP;
     close wf_notif_msg_maps;
     Delete_Row(p_notif_setup_id => l_notif_setup_id);
  else
      FND_MESSAGE.SET_NAME('IBE', 'IBE_WF_REQUIRED_NOTIF_NAME');
      FND_MESSAGE.SET_TOKEN('NAME', 'Notification_Name');
      FND_MSG_PUB.ADD;
      raise FND_API.G_EXC_ERROR;
  end if;
EXCEPTION
   WHEN FND_API.g_exc_error THEN
     ROLLBACK TO delete_wf_notif_setup;
     x_return_status := FND_API.g_ret_sts_error;
     FND_MSG_PUB.COUNT_AND_GET( p_encoded => FND_API.g_false, p_count => x_msg_count, p_data => x_msg_data );
     if( x_msg_count > 1 ) then
        x_msg_data := FND_MSG_PUB.GET(1, FND_API.G_FALSE);
     end if;

   WHEN FND_API.g_exc_unexpected_error THEN
     ROLLBACK TO delete_wf_notif_setup;
     x_return_status := FND_API.g_ret_sts_unexp_error ;
     FND_MSG_PUB.COUNT_AND_GET( p_encoded => FND_API.g_false, p_count => x_msg_count, p_data => x_msg_data );
     if( x_msg_count > 1 ) then
        x_msg_data := FND_MSG_PUB.GET(1, FND_API.G_FALSE);
     end if;
   WHEN OTHERS THEN
     ROLLBACK TO delete_wf_notif_setup;
     x_return_status := FND_API.g_ret_sts_unexp_error ;
     IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
       FND_MSG_PUB.ADD_EXC_MSG(g_pkg_name, l_api_name);
     END IF;
     FND_MSG_PUB.COUNT_AND_GET( p_encoded => FND_API.g_false, p_count => x_msg_count, p_data => x_msg_data );
     if( x_msg_count > 1 ) then
        x_msg_data := FND_MSG_PUB.GET(1, FND_API.G_FALSE);
     end if;
END Delete_wf_notif_setup;

procedure Update_Wf_notif_setup(
    x_return_status 	OUT NOCOPY JTF_VARCHAR2_TABLE_100,
    x_msg_count		OUT NOCOPY NUMBER,
    x_msg_data		OUT NOCOPY JTF_VARCHAR2_TABLE_2000,
    p_notif_name_tbl	IN JTF_VARCHAR2_TABLE_100,
    p_enabled_flag_tbl  IN JTF_VARCHAR2_TABLE_100)
IS
    l_notif_name_tbl JTF_VARCHAR2_TABLE_100;
    l_msite_flag VARCHAR2(1);
    l_org_flag VARCHAR2(1);
    l_user_type_flag VARCHAR2(1);
    l_default_message_name VARCHAR2(30);
    l_update_enabled_flag VARCHAR2(1);
    l_customized_flag VARCHAR2(1);
    l_notif_Setup_id NUMBER;
    l_return_status VARCHAR2(1);
    l_msg_data      VARCHAR2(2000);
    l_msg_count	    NUMBER;
    l_object_version_number NUMBER;
BEGIN
    --null;
    x_return_status := JTF_VARCHAR2_TABLE_100();
    x_msg_data := JTF_VARCHAR2_TABLE_2000();
    if( p_notif_name_tbl IS NULL ) THEN
        x_return_status.extend(1);
        x_return_status(1) := FND_API.G_RET_STS_ERROR;
        x_msg_data.extend(1);
        FND_MESSAGE.SET_NAME('IBE', 'IBE_WF_REQUIRED_NOTIF_NAME');
        FND_MESSAGE.SET_TOKEN('NAME', 'Notification_Name');
	x_msg_data(1) := FND_MESSAGE.GET;
	x_msg_count := 1;
    elsif( p_notif_name_tbl.COUNT <> p_enabled_flag_tbl.COUNT ) THEN
	x_return_status.extend(1);
	x_return_status(1) := FND_API.G_RET_STS_ERROR;
        x_msg_data.extend(1);
	x_msg_data(1) := FND_MESSAGE.GET_STRING('IBE', 'IBE_WF_NOTIF_UPDATE_ERROR');
        x_msg_count := 1;
    else
        update ibe_wf_notif_setup
	set enabled_flag = 'Y'
	where enabled_flag <> 'Y';

        x_return_status.extend(p_notif_name_tbl.COUNT);
        x_msg_data.extend(p_notif_name_tbl.COUNT);
        --debug('number of notif is ' || p_notif_name_tbl.COUNT);
	for i in 1..p_notif_name_tbl.COUNT LOOP
          --debug('p_notif_name ' || i || ' is ' || p_notif_name_tbl(i));
	  x_return_status(i) := FND_API.G_RET_STS_SUCCESS;
          if( p_notif_name_tbl(i) IS NOT NULL ) THEN
	     BEGIN
	      select msite_id_flag, org_id_flag, user_type_flag, default_message_name, update_enabled_flag,
		     customized_flag, notif_setup_id, object_version_number
	      into l_msite_flag, l_org_flag, l_user_type_flag, l_default_message_name, l_update_enabled_flag,
	           l_customized_Flag, l_notif_setup_id, l_object_version_number
	      from ibe_Wf_notif_setup
	      where notification_name = p_notif_name_tbl(i);
	     EXCEPTION
	       when no_data_found THEN
	          x_return_status(i) := FND_API.G_RET_STS_ERROR;
		  x_msg_count := x_msg_count + 1;
                  FND_MESSAGE.SET_NAME('IBE', 'IBE_WF_NOTIF_NAME_NOT_FOUND');
    		  FND_MESSAGE.SET_TOKEN('NAME', p_notif_name_tbl(i));
		  x_msg_data(i) := FND_MESSAGE.GET;
	     end;
	     --debug('l_notif_setup_id is ' || l_notif_setup_id);
	     --debug('l_object_version_number is ' || l_object_version_number);
	     if( x_return_status(i) = FND_API.G_RET_STS_SUCCESS ) then
                IBE_WF_NOTIF_SETUP_PVT.save_wf_notif_setup(
	           p_api_version		=> 1.0,
		   p_init_msg_list		=> FND_API.G_TRUE,
		   p_commit			=> FND_API.G_TRUE,
		   x_return_Status		=> l_return_status,
		   x_msg_count			=> l_msg_count,
		   x_msg_data			=> l_msg_data,
		   p_notif_setup_id		=> l_notif_setup_id,
		   p_org_id_flag		=> l_org_flag,
		   p_msite_id_flag		=> l_msite_flag,
		   p_user_type_flag		=> l_user_type_flag,
		   p_enabled_flag		=> p_enabled_flag_tbl(i),
		   p_default_message_name	=> l_default_message_name,
		   p_update_enabled_flag	=> l_update_enabled_flag,
		   p_object_version_number	=> l_object_version_number,
		   p_notification_name		=> p_notif_name_tbl(i),
		   p_customized_flag		=> l_customized_flag);
	       x_return_status(i) := l_return_status;
               x_msg_data(i) := l_msg_data;
	       x_msg_count := x_msg_count + l_msg_count;
	    end if;
	  else
	     x_return_status(i) := FND_API.G_RET_STS_ERROR;
             FND_MESSAGE.SET_NAME('IBE', 'IBE_WF_REQUIRED_NOTIF_NAME');
             FND_MESSAGE.SET_TOKEN('NAME', 'Notification_Name');
	     x_msg_data(i) := FND_MESSAGE.GET;
	     x_msg_count := x_msg_count + 1;
	  END IF;
        END LOOP;
    end if;
end update_wf_notif_setup;

FUNCTION Check_Notif_Enabled(p_notification_name VARCHAR2) RETURN VARCHAR2 IS
   l_enabled_flag VARCHAR2(1);
BEGIN
   select enabled_flag
   into l_enabled_flag
   from ibe_wf_notif_setup
   where notification_name = p_notification_name;
   return l_enabled_flag;
EXCEPTION
   when NO_DATA_FOUND Then
     return 'N';
END;
Procedure LOAD_SEED_ROW(
  P_NOTIF_SETUP_ID 		    in NUMBER,
  P_OWNER	   			    IN VARCHAR2,
  P_ORG_ID_FLAG 			in VARCHAR2,
  P_MSITE_ID_FLAG 		    in VARCHAR2,
  P_USER_TYPE_FLAG 		    in VARCHAR2,
  P_ENABLED_FLAG 			in VARCHAR2,
  P_DEFAULT_MESSAGE_NAME 	in VARCHAR2,
  P_UPDATE_ENABLED_FLAG 	in VARCHAR2,
  P_OBJECT_VERSION_NUMBER 	in NUMBER,
  p_customized_flag 		IN VARCHAR2,
  P_NOTIFICATION_NAME 		in VARCHAR2,
  P_LAST_UPDATE_DATE		in VARCHAR2,
  P_CUSTOM_MODE             in VARCHAR2,
  P_UPLOAD_MODE             in VARCHAR2)
is

Begin
	 if ( p_upload_mode = 'NLS') then
             null;
      else
         IBE_WF_NOTIF_SETUP_PVT.LOAD_ROW(
		  P_NOTIF_SETUP_ID,
		  P_OWNER,
		  P_ORG_ID_FLAG,
          P_MSITE_ID_FLAG,
          P_USER_TYPE_FLAG,
		  P_ENABLED_FLAG,
		  P_DEFAULT_MESSAGE_NAME,
	      P_UPDATE_ENABLED_FLAG,
		  P_OBJECT_VERSION_NUMBER,
		  P_CUSTOMIZED_FLAG,
		  P_NOTIFICATION_NAME,
          P_LAST_UPDATE_DATE,
          P_CUSTOM_MODE);
	    end if;
end LOAD_SEED_ROW;

end IBE_WF_NOTIF_SETUP_PVT;

/
