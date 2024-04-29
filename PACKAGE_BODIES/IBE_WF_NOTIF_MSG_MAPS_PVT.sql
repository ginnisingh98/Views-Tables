--------------------------------------------------------
--  DDL for Package Body IBE_WF_NOTIF_MSG_MAPS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_WF_NOTIF_MSG_MAPS_PVT" as
/* $Header: IBEVWNMB.pls 120.2 2005/06/15 03:46:56 appldev  $ */

--g_debug boolean := TRUE;
g_debug boolean := FALSE;
procedure debug(p_msg VARCHAR2) IS
  l_debug VARCHAR2(1);

BEGIN
        l_debug  := NVL(FND_PROFILE.VALUE('IBE_DEBUG'),'N');

  if( g_debug = TRUE ) then
	--dbms_output.put_line(p_msg);
	IF (l_debug = 'Y') THEN
   	IBE_UTIL.debug(p_msg);
	END IF;
  end if;
end;
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  P_NOTIF_MSG_MAP_ID in NUMBER,
  P_NOTIF_SETUP_ID in NUMBER,
  P_NOTIFICATION_NAME in VARCHAR2,
  P_USER_TYPE in VARCHAR2,
  P_ENABLED_FLAG in VARCHAR2,
  P_DEFAULT_MSG_MAP_FLAG in VARCHAR2,
  P_OBJECT_VERSION_NUMBER in NUMBER,
  P_ALL_ORG_FLAG in VARCHAR2,
  P_ALL_MSITE_FLAG in VARCHAR2,
  P_ALL_USER_TYPE_FLAG in VARCHAR2,
  P_MSITE_ID in NUMBER,
  P_ORG_ID   IN NUMBER,
  P_MESSAGE_NAME in VARCHAR2,
  P_CREATION_DATE in DATE,
  P_CREATED_BY in NUMBER,
  P_LAST_UPDATE_DATE in DATE,
  P_LAST_UPDATED_BY in NUMBER,
  P_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from IBE_WF_NOTIF_MSG_MAPS
    where NOTIF_MSG_MAP_ID = P_NOTIF_MSG_MAP_ID
    and NOTIF_SETUP_ID = P_NOTIF_SETUP_ID
    ;
begin
  insert into IBE_WF_NOTIF_MSG_MAPS (
    NOTIFICATION_NAME,
    USER_TYPE,
    MESSAGE_NAME,
    ENABLED_FLAG,
    DEFAULT_MSG_MAP_FLAG,
    NOTIF_MSG_MAP_ID,
    OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    NOTIF_SETUP_ID,
    LAST_UPDATED_BY,
    ALL_ORG_FLAG,
    ALL_MSITE_FLAG,
    ALL_USER_TYPE_FLAG,
    MSITE_ID,
    ORG_ID,
    CREATION_DATE,
    CREATED_BY
  ) select
    P_NOTIFICATION_NAME,
    P_USER_TYPE,
    P_MESSAGE_NAME,
    P_ENABLED_FLAG,
    P_DEFAULT_MSG_MAP_FLAG,
    P_NOTIF_MSG_MAP_ID,
    P_OBJECT_VERSION_NUMBER,
    P_LAST_UPDATE_DATE,
    P_LAST_UPDATE_LOGIN,
    P_NOTIF_SETUP_ID,
    P_LAST_UPDATED_BY,
    P_ALL_ORG_FLAG,
    P_ALL_MSITE_FLAG,
    P_ALL_USER_TYPE_FLAG,
    P_MSITE_ID,
    P_ORG_ID,
    P_CREATION_DATE,
    P_CREATED_BY
  from DUAL
  where not exists
    (select NULL
    from IBE_WF_NOTIF_MSG_MAPS T
    where T.NOTIF_MSG_MAP_ID = P_NOTIF_MSG_MAP_ID
    and T.NOTIF_SETUP_ID = P_NOTIF_SETUP_ID);

  open c;
  fetch c into x_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  P_NOTIF_MSG_MAP_ID in NUMBER,
  P_NOTIF_SETUP_ID in NUMBER,
  P_NOTIFICATION_NAME in VARCHAR2,
  P_USER_TYPE in VARCHAR2,
  P_ENABLED_FLAG in VARCHAR2,
  P_DEFAULT_MSG_MAP_FLAG in VARCHAR2,
  P_OBJECT_VERSION_NUMBER in NUMBER,
  P_ALL_ORG_FLAG in VARCHAR2,
  P_ALL_MSITE_FLAG in VARCHAR2,
  P_ALL_USER_TYPE_FLAG in VARCHAR2,
  P_MSITE_ID in NUMBER,
  P_ORG_ID IN NUMBER,
  P_MESSAGE_NAME in VARCHAR2
) is
  cursor c1 is select
      NOTIFICATION_NAME,
      USER_TYPE,
      ENABLED_FLAG,
      DEFAULT_MSG_MAP_FLAG,
      OBJECT_VERSION_NUMBER,
      ALL_ORG_FLAG,
      ALL_MSITE_FLAG,
      ALL_USER_TYPE_FLAG,
      MSITE_ID,
      ORG_ID,
      MESSAGE_NAME
    from IBE_WF_NOTIF_MSG_MAPS
    where NOTIF_MSG_MAP_ID = P_NOTIF_MSG_MAP_ID
    and NOTIF_SETUP_ID = P_NOTIF_SETUP_ID
    for update of NOTIF_MSG_MAP_ID nowait;
begin
  for tlinfo in c1 loop
      if (    ((tlinfo.MESSAGE_NAME = P_MESSAGE_NAME)
               OR ((tlinfo.MESSAGE_NAME is null) AND (P_MESSAGE_NAME is null)))
          AND (tlinfo.NOTIFICATION_NAME = P_NOTIFICATION_NAME)
          AND ((tlinfo.USER_TYPE = P_USER_TYPE)
               OR ((tlinfo.USER_TYPE is null) AND (P_USER_TYPE is null)))
          AND ((tlinfo.ENABLED_FLAG = P_ENABLED_FLAG)
               OR ((tlinfo.ENABLED_FLAG is null) AND (P_ENABLED_FLAG is null)))
          AND ((tlinfo.DEFAULT_MSG_MAP_FLAG = P_DEFAULT_MSG_MAP_FLAG)
               OR ((tlinfo.DEFAULT_MSG_MAP_FLAG is null) AND (P_DEFAULT_MSG_MAP_FLAG is null)))
          AND (tlinfo.OBJECT_VERSION_NUMBER = P_OBJECT_VERSION_NUMBER)
          AND ((tlinfo.ALL_ORG_FLAG = P_ALL_ORG_FLAG)
               OR ((tlinfo.ALL_ORG_FLAG is null) AND (P_ALL_ORG_FLAG is null)))
          AND ((tlinfo.ALL_MSITE_FLAG = P_ALL_MSITE_FLAG)
               OR ((tlinfo.ALL_MSITE_FLAG is null) AND (P_ALL_MSITE_FLAG is null)))
          AND ((tlinfo.ALL_USER_TYPE_FLAG = P_ALL_USER_TYPE_FLAG)
               OR ((tlinfo.ALL_USER_TYPE_FLAG is null) AND (P_ALL_USER_TYPE_FLAG is null)))
          AND ((tlinfo.MSITE_ID = P_MSITE_ID)
               OR ((tlinfo.MSITE_ID is null) AND (P_MSITE_ID is null)))
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
  P_NOTIF_MSG_MAP_ID in NUMBER,
  P_NOTIF_SETUP_ID in NUMBER,
  P_NOTIFICATION_NAME in VARCHAR2,
  P_USER_TYPE in VARCHAR2,
  P_ENABLED_FLAG in VARCHAR2,
  P_DEFAULT_MSG_MAP_FLAG in VARCHAR2,
  P_OBJECT_VERSION_NUMBER in NUMBER,
  P_ALL_ORG_FLAG in VARCHAR2,
  P_ALL_MSITE_FLAG in VARCHAR2,
  P_ALL_USER_TYPE_FLAG in VARCHAR2,
  P_MSITE_ID in NUMBER,
  P_ORG_ID in NUMBER,
  P_MESSAGE_NAME in VARCHAR2,
  P_LAST_UPDATE_DATE in DATE,
  P_LAST_UPDATED_BY in NUMBER,
  P_LAST_UPDATE_LOGIN in NUMBER
) is
begin
   debug('update_row 1');
   debug('update_row 2 ' || p_notification_name);
   debug('update_row 3 ' || p_notif_setup_id);
   debug('update_row 4 ' || p_notif_msg_map_id);
  update IBE_WF_NOTIF_MSG_MAPS set
    NOTIF_SETUP_ID = P_NOTIF_SETUP_ID,
    NOTIFICATION_NAME = P_NOTIFICATION_NAME,
    USER_TYPE = P_USER_TYPE,
    ENABLED_FLAG = P_ENABLED_FLAG,
    DEFAULT_MSG_MAP_FLAG = P_DEFAULT_MSG_MAP_FLAG,
    OBJECT_VERSION_NUMBER = P_OBJECT_VERSION_NUMBER,
    ALL_ORG_FLAG = P_ALL_ORG_FLAG,
    ALL_MSITE_FLAG = P_ALL_MSITE_FLAG,
    ALL_USER_TYPE_FLAG = P_ALL_USER_TYPE_FLAG,
    MSITE_ID = P_MSITE_ID,
    MESSAGE_NAME = P_MESSAGE_NAME,
    ORG_ID = P_ORG_ID,
    LAST_UPDATE_DATE = P_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = P_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = P_LAST_UPDATE_LOGIN
  where NOTIF_MSG_MAP_ID = P_NOTIF_MSG_MAP_ID;
  --bug 2212390 and NOTIF_SETUP_ID = P_NOTIF_SETUP_ID;
  --And last_updated_by = p_last_updated_by;

   debug('update_row 5 ' || p_notif_msg_map_id);
  if (sql%notfound) then
   debug('update_row 6 ' || p_notif_msg_map_id);
    raise no_data_found;
  end if;
   debug('update_row 7 ' || p_notif_msg_map_id);
/*EXCEPTION
  when NO_DATA_FOUND THEN
	FND_MESSAGE.SET_NAME('IBE', 'IBE_WF_NOTIF_MSG_MAP_NOT_FOUND');
	FND_MESSAGE.SET_TOKEN('ID', p_notif_msg_map_id);
        FND_MSG_PUB.ADD;*/
/* added by abhandar 07/21/03*/
EXCEPTION
   WHEN DUP_VAL_ON_INDEX THEN
	 FND_MESSAGE.SET_NAME('IBE', 'IBE_WF_NOTIF_MSG_MAP_DUPINDEX');
	 FND_MESSAGE.SET_TOKEN('ID', p_notif_msg_map_id);
     FND_MSG_PUB.ADD;

end UPDATE_ROW;

procedure DELETE_ROW (
  P_NOTIF_MSG_MAP_ID in NUMBER,
  P_NOTIF_SETUP_ID in NUMBER
) is
begin
  delete from IBE_WF_NOTIF_MSG_MAPS
  where NOTIF_MSG_MAP_ID = P_NOTIF_MSG_MAP_ID
  and NOTIF_SETUP_ID = P_NOTIF_SETUP_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
EXCEPTION
  when NO_DATA_FOUND THEN
	FND_MESSAGE.SET_NAME('IBE', 'IBE_WF_NOTIF_MSG_MAP_NOT_FOUND');
	FND_MESSAGE.SET_TOKEN('ID', p_notif_msg_map_id);
        FND_MSG_PUB.ADD;
end DELETE_ROW;

procedure LOAD_SEED_ROW (
	P_NOTIF_MSG_MAP_ID in NUMBER,
	P_NOTIF_SETUP_ID in NUMBER,
	P_OWNER      IN VARCHAR2,
	P_NOTIFICATION_NAME in VARCHAR2,
	P_USER_TYPE in VARCHAR2,
	P_ENABLED_FLAG in VARCHAR2,
	P_DEFAULT_MSG_MAP_FLAG in VARCHAR2,
	P_OBJECT_VERSION_NUMBER in NUMBER,
	P_ALL_ORG_FLAG in VARCHAR2,
	P_ALL_MSITE_FLAG in VARCHAR2,
	P_ALL_USER_TYPE_FLAG in VARCHAR2,
	P_MSITE_ID in NUMBER,
	P_ORG_ID  IN NUMBER,
	P_MESSAGE_NAME in VARCHAR2,
	P_LAST_UPDATE_DATE in VARCHAR2,
	P_CUSTOM_MODE in VARCHAR2,
	P_UPLOAD_MODE in VARCHAR2
)

IS

BEGIN --{

	if (P_UPLOAD_MODE = 'NLS')
	then --{
		null;
	else
         ibe_wf_notif_msg_maps_pvt.load_row(
             p_notif_msg_map_id      => P_NOTIF_MSG_MAP_ID,
             p_notif_setup_id        => P_NOTIF_SETUP_ID,
             p_owner                 => P_OWNER,
             p_notification_name     => P_NOTIFICATION_NAME,
             p_user_type             => P_USER_TYPE,
             p_enabled_flag          => P_ENABLED_FLAG,
             p_default_msg_map_flag  => P_DEFAULT_MSG_MAP_FLAG,
             p_object_version_number => P_OBJECT_VERSION_NUMBER,
             p_all_org_flag          => P_ALL_ORG_FLAG,
             p_all_msite_flag        => P_ALL_MSITE_FLAG,
             p_all_user_type_flag    => P_ALL_USER_TYPE_FLAG,
             p_msite_id              => P_MSITE_ID,
             p_org_id                => P_ORG_ID,
             p_message_name          => P_MESSAGE_NAME,
			 p_last_update_date      => P_LAST_UPDATE_DATE,
			 p_custom_mode           => P_CUSTOM_MODE
		);
	end if; --}

END LOAD_SEED_ROW; --}


procedure LOAD_ROW (
  P_NOTIF_MSG_MAP_ID in NUMBER,
  P_NOTIF_SETUP_ID in NUMBER,
  P_OWNER          IN VARCHAR2,
  P_NOTIFICATION_NAME in VARCHAR2,
  P_USER_TYPE in VARCHAR2,
  P_ENABLED_FLAG in VARCHAR2,
  P_DEFAULT_MSG_MAP_FLAG in VARCHAR2,
  P_OBJECT_VERSION_NUMBER in NUMBER,
  P_ALL_ORG_FLAG in VARCHAR2,
  P_ALL_MSITE_FLAG in VARCHAR2,
  P_ALL_USER_TYPE_FLAG in VARCHAR2,
  P_MSITE_ID in NUMBER,
  P_ORG_ID      IN NUMBER,
  P_MESSAGE_NAME in VARCHAR2,
  P_LAST_UPDATE_DATE in VARCHAR2,
  P_CUSTOM_MODE in VARCHAR2
) IS
  user_id NUMBER;
  l_row_id VARCHAR2(64);
  l_message_name VARCHAR2(30);
  l_enabled_flag VARCHAR2(1);
  l_last_updated_by NUMBER;
  l_last_update_date DATE;
  f_last_updated_by NUMBER;
  f_last_update_date DATE;

BEGIN
  if( p_owner = 'SEED' ) then
      user_id := 1;
  else
      user_id := 0;
  end if;

	f_last_updated_by := fnd_load_util.owner_id(P_OWNER);
	f_last_update_date := nvl(to_date(P_LAST_UPDATE_DATE,'YYYY/MM/DD'),sysdate);

  BEGIN
      select last_updated_by, last_update_date, message_name, enabled_flag
      into l_last_updated_by, l_last_update_date,l_message_name, l_enabled_flag
      from ibe_wf_notif_msg_maps
      where notif_msg_map_id = p_notif_msg_map_id;
  EXCEPTION
      when no_data_found THEN
	raise no_data_found;
  END;

  if (fnd_load_util.upload_test(f_last_updated_by,f_last_update_date,l_last_updated_by,l_last_update_date,P_CUSTOM_MODE))
  then --{
	  if( l_last_updated_by = 1 ) then --{
    	 update_row(
  	      P_NOTIF_MSG_MAP_ID 	=> p_notif_msg_map_id,
    	    P_NOTIF_SETUP_ID 	=> p_notif_setup_id,
	        P_NOTIFICATION_NAME 	=> p_notification_name,
    	    P_USER_TYPE 		=> p_user_type,
	        P_ENABLED_FLAG 		=> p_enabled_flag,
    	    P_DEFAULT_MSG_MAP_FLAG 	=> p_default_msg_map_flag,
    	    P_OBJECT_VERSION_NUMBER	=> p_object_version_number,
	        P_ALL_ORG_FLAG 		=> p_all_org_flag,
    	    P_ALL_MSITE_FLAG 	=> p_all_msite_flag,
	        P_ALL_USER_TYPE_FLAG 	=> p_all_user_type_flag,
    	    P_MSITE_ID 		=> p_msite_id,
     	    P_ORG_ID      		=> p_org_id,
      	    P_MESSAGE_NAME 		=> p_message_name,
            P_LAST_UPDATE_DATE 	=> f_last_update_date,
            P_LAST_UPDATED_BY 	=> f_last_updated_by,
            P_LAST_UPDATE_LOGIN	=> f_last_updated_by
          );
  	 else
    	 update_row(
   	        P_NOTIF_MSG_MAP_ID 	=> p_notif_msg_map_id,
            P_NOTIF_SETUP_ID 	=> p_notif_setup_id,
            P_NOTIFICATION_NAME 	=> p_notification_name,
            P_USER_TYPE 		=> p_user_type,
            P_ENABLED_FLAG 		=> l_enabled_flag,
            P_DEFAULT_MSG_MAP_FLAG 	=> p_default_msg_map_flag,
            P_OBJECT_VERSION_NUMBER	=> p_object_version_number,
            P_ALL_ORG_FLAG 		=> p_all_org_flag,
            P_ALL_MSITE_FLAG 	=> p_all_msite_flag,
            P_ALL_USER_TYPE_FLAG 	=> p_all_user_type_flag,
            P_MSITE_ID 		=> p_msite_id,
            P_ORG_ID      		=> p_org_id,
            P_MESSAGE_NAME 		=> l_message_name,
            P_LAST_UPDATE_DATE 	=> f_last_update_date,
            P_LAST_UPDATED_BY 	=> f_last_updated_by,
            P_LAST_UPDATE_LOGIN	=> f_last_updated_by
         );
    end if; --}
  end if; --}
EXCEPTION
  WHEN NO_DATA_FOUND THEN
     insert_row(
        X_ROWID 		=> l_row_id,
        P_NOTIF_MSG_MAP_ID 	=> p_notif_msg_map_id,
        P_NOTIF_SETUP_ID 	=> p_notif_setup_id,
        P_NOTIFICATION_NAME 	=> p_notification_name,
        P_USER_TYPE 		=> p_user_type,
        P_ENABLED_FLAG 		=> p_enabled_flag,
        P_DEFAULT_MSG_MAP_FLAG 	=> p_default_msg_map_flag,
        P_OBJECT_VERSION_NUMBER => p_object_version_number,
        P_ALL_ORG_FLAG 		=> p_all_org_flag,
        P_ALL_MSITE_FLAG 	=> p_all_msite_flag,
        P_ALL_USER_TYPE_FLAG 	=> p_all_user_type_flag,
        P_MSITE_ID 		=> p_msite_id,
        P_ORG_ID   		=> p_org_id,
        P_MESSAGE_NAME 		=> p_message_name,
        P_CREATION_DATE 	=> f_last_update_date,
        P_CREATED_BY 		=> f_last_updated_by,
        P_LAST_UPDATE_DATE 	=> f_last_update_date,
        P_LAST_UPDATED_BY 	=> f_last_updated_by,
        P_LAST_UPDATE_LOGIN	=> f_last_updated_by);
END LOAD_ROW;

function check_msg_map_exists(
   p_notif_msg_map_id IN NUMBER,
   p_object_version_number IN NUMBER := FND_API.G_MISS_NUM) return BOOLEAN
IS
  l_exists VARCHAR2(1) := '0';
BEGIN
  if( p_object_version_number = FND_API.G_MISS_NUM OR p_object_version_number IS NULL ) then
     select '1'
     into l_exists
     from dual
     where exists (
	select notif_msg_map_id, object_version_number
        From ibe_wf_notif_msg_maps
        where notif_msg_map_id = p_notif_msg_map_id
     );
     if( l_exists <> '1' ) then
	FND_MESSAGE.SET_NAME('IBE', 'IBE_WF_NOTIF_MSG_MAP_NOT_FOUND');
	FND_MESSAGE.SET_TOKEN('ID', p_notif_msg_map_id);
        FND_MSG_PUB.ADD;
        return FALSE;
     else
        return TRUE;
     end if;
  else
     select '1'
     into l_exists
     from dual
     where exists (
	select notif_msg_map_id, object_version_number
        From ibe_wf_notif_msg_maps
        where notif_msg_map_id = p_notif_msg_map_id
	and object_version_number = p_object_version_number
     );
     if( l_exists <> '1' ) then
	FND_MESSAGE.SET_NAME('IBE', 'IBE_WF_NOTIF_MSGMAP_VER_NOT_MATCH');
	FND_MESSAGE.SET_TOKEN('ID', p_notif_msg_map_id);
        FND_MSG_PUB.ADD;
        return FALSE;
     else
        return TRUE;
     end if;
  end if;
EXCEPTION
  when NO_DATA_FOUND THEN
	FND_MESSAGE.SET_NAME('IBE', 'IBE_WF_NOTIF_MSG_MAP_NOT_FOUND');
	FND_MESSAGE.SET_TOKEN('ID', p_notif_msg_map_id);
        FND_MSG_PUB.ADD;
        return FALSE;
END;

FUNCTION check_msg_map_duplicate(
    p_action 	   IN VARCHAR2,
    p_msg_map_id   IN NUMBER,
    p_notification_name IN VARCHAR2,
    p_message_name IN VARCHAR2,
    p_msite_id     IN NUMBER,
    p_org_id       IN NUMBER,
    p_user_type    IN VARCHAR2,
    p_all_org_flag IN VARCHAR2,
    p_all_msite_flag IN VARCHAR2,
    p_all_user_type_flag IN VARCHAR2) RETURN BOOLEAN
IS
   l_exists VARCHAR2(1) := '0';
   l_notif_msg_map_id NUMBER;
BEGIN
    debug('inside check_msg_map_duplicate 1');
    debug('p_notification_name is ' || p_notification_name);
    debug('p_mesage_name is ' || p_message_name);
    debug('p_msite_id is' || p_msite_id);
    debug('p_org_id is ' || p_org_id);
    debug('p_user_Type is ' || p_user_type);
    debug('p_all_org_flag is ' || p_all_org_flag);
    debug('p_all_msite_flag is ' || p_all_msite_flag);
    debug('p_all_user_type_flag is ' || p_all_user_type_flag);

    select min(notif_msg_map_id)
    into l_notif_msg_map_id
    from ibe_wf_notif_msg_maps
    where notification_name = p_notification_name
    and nvl(msite_id, -99999) = nvl(p_msite_id, -99999)
    and nvl(org_id, -99999) = nvl(p_org_id, -99999)
    and nvl(user_type, '@#$%') = nvl(p_user_type, '@#$%')
    and nvl(all_org_flag, '@#$%') = nvl(p_all_org_flag, '@#$%')
    and nvl(all_msite_flag, '@#$%') = nvl(p_all_msite_flag, '@#$%')
    and nvl(all_user_type_flag, '@#$%') = nvl(p_all_user_type_flag, '@#$%');
	   --and message_name = p_message_name);

     if( p_action = 'INSERT' ) Then
         if( l_notif_msg_map_id is not null ) then
             debug('return false');
	     FND_MESSAGE.SET_NAME('IBE', 'IBE_WF_DUP_NOTIF_MSG_MAPS');
	     FND_MESSAGE.SET_TOKEN('NAME', p_message_name);
             FND_MSG_PUB.ADD;
	     return FALSE;
         else
	     return TRUE;
	 end if;
    elsif( p_action='UPDATE') then
        if( l_notif_msg_map_id is not null AND l_notif_msg_map_id <> p_msg_map_id ) then
             debug('return false');
	     FND_MESSAGE.SET_NAME('IBE', 'IBE_WF_DUP_NOTIF_MSG_MAPS');
	     FND_MESSAGE.SET_TOKEN('NAME', p_message_name);
             FND_MSG_PUB.ADD;
	     return FALSE;
	else
            debug('return true');
	    return TRUE;
        end if;
    end if;
EXCEPTION
    when NO_DATA_FOUND THEN
        debug('return true');
        return TRUE;
END;

procedure save_wf_notif_msg_maps(
   p_api_version                IN NUMBER,
   p_init_msg_list              IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN VARCHAR2 := FND_API.G_FALSE,
   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2,
   P_NOTIF_MSG_MAP_ID           in NUMBER,
   P_NOTIF_SETUP_ID             in NUMBER,
   P_NOTIFICATION_NAME          in VARCHAR2,
   P_USER_TYPE                  in VARCHAR2,
   P_ENABLED_FLAG               in VARCHAR2,
   P_DEFAULT_MSG_MAP_FLAG       in VARCHAR2,
   P_ALL_ORG_FLAG               in VARCHAR2,
   P_ALL_MSITE_FLAG             in VARCHAR2,
   P_ALL_USER_TYPE_FLAG         in VARCHAR2,
   P_MSITE_ID                   in NUMBER,
   P_ORG_ID                     in NUMBER,
   p_object_version_number	IN NUMBER := FND_API.G_MISS_NUM,
   P_MESSAGE_NAME               in VARCHAR2)
IS
   l_api_name VARCHAR2(30) := 'SAVE_WF_NOTIF_MSG_MAPS';
   l_full_name VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
   l_object_version_number NUMBER;
   l_operation_type VARCHAR2(10) := 'INSERT';
   l_rowid ROWID;
   l_exists VARCHAR2(1);
   l_notif_msg_map_id NUMBER;
   l_notif_setup_id NUMBER;
BEGIN
   --null;
   debug('save_notif_msg_maps 1');
   savepoint save_wf_notif_msg_maps;

   if NOT FND_API.Compatible_Api_Call(g_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   if FND_API.To_Boolean(p_init_msg_list) then
      FND_MSG_PUB.initialize;
   end if;

   x_return_status := FND_API.G_RET_STS_SUCCESS;


   if( p_notif_msg_map_id IS NOT NULL AND p_notif_setup_id IS NOT NULL) THEN
      debug('save_notif_msg_maps 2');
      if( check_msg_map_exists(p_notif_msg_map_id, p_object_version_number) = TRUE ) THEN
	l_operation_type := 'UPDATE';
        if( p_object_version_number = FND_API.G_MISS_NUM ) then
            select object_version_number
            into l_object_version_number
            from ibe_wf_notif_msg_maps
            where notif_msg_map_id = p_notif_msg_map_id
            and notif_setup_id = p_notif_setup_id;
        else
	   l_object_version_number := p_object_version_number;
        end if;
        l_object_version_number := l_object_version_number + 1;
      else
        debug('save_notif_msg_maps 3');
	raise FND_API.G_EXC_ERROR;
      end if;
      if( check_msg_map_duplicate(
                l_operation_type, p_notif_msg_map_id, p_notification_name, p_message_name, p_msite_id, p_org_id, p_user_type,
                p_all_org_flag, p_all_msite_flag, p_all_user_type_flag) <> TRUE ) then
                debug('save_notif_msg_maps 5');
                raise FND_API.G_EXC_ERROR;
      end if;
   end if;

    if( l_operation_type = 'INSERT') THEN
       debug('save_notif_msg_maps 4');
       if( p_notification_name is not null and p_message_name is not null ) then
           if( check_msg_map_duplicate(
		l_operation_type, p_notif_msg_map_id, p_notification_name, p_message_name, p_msite_id, p_org_id, p_user_type,
		p_all_org_flag, p_all_msite_flag, p_all_user_type_flag) <> TRUE ) then
                debug('save_notif_msg_maps 5');
	        raise FND_API.G_EXC_ERROR;
           end if;
      else
         debug('save_notif_msg_maps 6');
         FND_MESSAGE.SET_NAME('IBE', 'IBE_WF_NOTIF_MSG_NAME_REQ');
         FND_MSG_PUB.ADD;
         raise FND_API.G_EXC_ERROR;
      end if;
   end if;

   if( l_operation_type = 'INSERT' ) then
        debug('save_notif_msg_maps 7');
	select ibe_wf_notif_msg_maps_s1.nextval
	into l_notif_msg_map_id
	from dual;

        debug('save_notif_msg_maps 8');
        select notif_setup_id
	into l_notif_setup_id
	from ibe_wf_notif_setup
        where notification_name = p_notification_name;

        debug('save_notif_msg_maps 9');
        insert_row(
  	    X_ROWID 			=> l_rowid,
  	    P_NOTIF_MSG_MAP_ID 		=> l_notif_msg_map_id,
  	    P_NOTIF_SETUP_ID 		=> l_notif_setup_id,
  	    P_NOTIFICATION_NAME 	=> p_notification_name,
 	    P_USER_TYPE 		=> p_user_type,
  	    P_ENABLED_FLAG 		=> p_enabled_flag,
  	    P_DEFAULT_MSG_MAP_FLAG 	=> p_default_msg_map_flag,
  	    P_OBJECT_VERSION_NUMBER 	=> 1.0,
  	    P_ALL_ORG_FLAG 		=> p_all_org_flag,
  	    P_ALL_MSITE_FLAG 		=> p_all_msite_flag,
  	    P_ALL_USER_TYPE_FLAG 	=> p_all_user_type_flag,
  	    P_MSITE_ID 			=> p_msite_id,
  	    P_ORG_ID 			=> p_org_id,
  	    P_MESSAGE_NAME 		=> p_message_name,
  	    P_CREATION_DATE 		=> sysdate,
  	    P_CREATED_BY 		=> FND_GLOBAL.user_id,
  	    P_LAST_UPDATE_DATE 		=> sysdate,
  	    P_LAST_UPDATED_BY 		=> FND_GLOBAL.user_id,
  	    P_LAST_UPDATE_LOGIN 	=> FND_GLOBAL.user_id
        );
        debug('save_notif_msg_maps 10');
   else
        debug('save_notif_msg_maps 11');
        l_notif_msg_map_id := p_notif_msg_map_id;
        l_notif_setup_id := p_notif_setup_id;
      begin
        update_row(
  	    P_NOTIF_MSG_MAP_ID  => l_notif_msg_map_id,
  	    P_NOTIF_SETUP_ID 	=> l_notif_setup_id,
  	    P_NOTIFICATION_NAME => p_notification_name,
  	    P_USER_TYPE 	=> p_user_type,
  	    P_ENABLED_FLAG 	=> p_enabled_flag,
  	    P_DEFAULT_MSG_MAP_FLAG => p_default_msg_map_flag,
  	    P_OBJECT_VERSION_NUMBER => l_object_version_number,
  	    P_ALL_ORG_FLAG 	=> p_all_org_flag,
  	    P_ALL_MSITE_FLAG 	=> p_all_msite_flag,
  	    P_ALL_USER_TYPE_FLAG => p_all_user_type_flag,
  	    P_MSITE_ID 		=> p_msite_id,
  	    P_ORG_ID 		=> p_ORG_id,
  	    P_MESSAGE_NAME 	=> p_message_name,
  	    P_LAST_UPDATE_DATE 	=> sysdate,
  	    P_LAST_UPDATED_BY 	=> FND_GLOBAL.user_id,
  	    P_LAST_UPDATE_LOGIN => FND_GLOBAL.user_id
        );
      Exception
	when no_data_found then
	FND_MESSAGE.SET_NAME('IBE', 'IBE_WF_NOTIF_MSG_MAP_NOT_FOUND');
	FND_MESSAGE.SET_TOKEN('ID', p_notif_msg_map_id);
        FND_MSG_PUB.ADD;
      end;
   debug('save_notif_msg_maps 12');
   end if;

   if( FND_API.to_Boolean(p_commit)) then
   debug('save_notif_msg_maps 13');
	commit;
   end if;

   x_return_status := FND_API.G_RET_STS_SUCCESS;
   FND_MSG_PUB.COUNT_AND_GET(p_encoded => FND_API.G_FALSE, P_COUNT => X_MSG_COUNT, P_DATA => X_MSG_DATA);
   if( x_msg_count > 1 ) then
       x_msg_data := FND_MSG_PUB.GET(1, FND_API.G_FALSE);
    end if;
   debug('save_notif_msg_maps 14');
EXCEPTION
    when FND_API.G_EXC_ERROR THEN
        rollback to save_wf_notif_msg_maps;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.COUNT_AND_GET(p_encoded => FND_API.G_FALSE, P_COUNT => X_MSG_COUNT, P_DATA => X_MSG_DATA);
        if( x_msg_count > 1 ) then
            x_msg_data := FND_MSG_PUB.GET(1, FND_API.G_FALSE);
	end if;

    when FND_API.G_EXC_UNEXPECTED_ERROR THEN
        rollback to save_wf_notif_msg_maps;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.COUNT_AND_GET(p_encoded => FND_API.G_FALSE, P_COUNT => X_MSG_COUNT, P_DATA => X_MSG_DATA);
	if( x_msg_count > 1) then
            x_msg_data := FND_MSG_PUB.GET(1, FND_API.G_FALSE);
	end if;

    when OTHERS then
        rollback to save_wf_notif_msg_maps;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        if FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
           FND_MSG_PUB.ADD_EXC_MSG(g_pkg_name, l_api_name);
        end if;
        FND_MSG_PUB.COUNT_AND_GET(p_encoded => FND_API.G_FALSE, P_COUNT => X_MSG_COUNT, P_DATA => X_MSG_DATA);
	if( x_msg_count > 1 ) then
            x_msg_data := FND_MSG_PUB.GET(1, FND_API.G_FALSE);
	end if;
END save_wf_notif_msg_maps;

procedure delete_wf_notif_msg_maps(
   p_api_version                IN NUMBER,
   p_init_msg_list              IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN VARCHAR2 := FND_API.G_FALSE,
   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2,
   P_NOTIFICATION_NAME          in VARCHAR2,
   p_notif_msg_map_id		IN NUMBER,
   P_MESSAGE_NAME               in VARCHAR2
) IS
   l_notif_msg_map_id		NUMBER;
   l_api_name 	CONSTANT VARCHAR2(30) := 'delete_wf_notif_msg_maps';
   l_notification_name   VARCHAR2(30);
   l_notif_setup_id	 NUMBER;
   cursor wf_notif_setup(p_notification_name IN VARCHAR2) IS
	select notif_setup_id
	from ibe_wf_notif_setup
	where notification_name = p_notification_name;
BEGIN
  --null;
  savepoint delete_wf_notif_msg_maps;

  IF NOT FND_API.compatible_api_call(g_api_version, p_api_version, l_api_name, g_pkg_name ) THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  if( p_notification_name IS NOT NULL AND p_message_name IS NOT NULL ) THEN
      open wf_notif_setup(p_notification_name);
      LOOP
         fetch wf_notif_setup into l_notif_setup_id;
         exit when wf_notif_setup%NOTFOUND;
      end loop;
      close wf_notif_setup;
      if( check_msg_map_exists(p_notif_msg_map_id) = TRUE ) THEN
          delete_row(p_notif_setup_id => l_notif_setup_id, p_notif_msg_map_id => p_notif_msg_map_id);
      else
	  raise no_data_found;
      end if;
  else
      FND_MESSAGE.SET_NAME('IBE', 'IBE_WF_NOTIF_MSG_NAME_REQ');
      FND_MSG_PUB.ADD;
      raise FND_API.G_EXC_ERROR;
  end if;
EXCEPTION
  when NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('IBE', 'IBE_WF_NOTIF_NAME_NOT_FOUND');
      FND_MESSAGE.SET_TOKEN('NAME', p_notification_name);
      --FND_MSG_PUB.ADD;
      --FND_MSG_PUB.COUNT_AND_GET(p_encoded => FND_API.G_FALSE, P_COUNT => X_MSG_COUNT, P_DATA => X_MSG_DATA);
      x_msg_data := FND_MESSAGE.GET;
      x_msg_count := 1;
    when FND_API.G_EXC_ERROR THEN
        rollback to save_wf_notif_msg_maps;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.COUNT_AND_GET(p_encoded => FND_API.G_FALSE, P_COUNT => X_MSG_COUNT, P_DATA => X_MSG_DATA);
	if( x_msg_count > 1 ) then
            x_msg_data := FND_MSG_PUB.GET(1, FND_API.G_FALSE);
	end if;

    when FND_API.G_EXC_UNEXPECTED_ERROR THEN
        rollback to save_wf_notif_msg_maps;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.COUNT_AND_GET(p_encoded => FND_API.G_FALSE, P_COUNT => X_MSG_COUNT, P_DATA => X_MSG_DATA);
	if( x_msg_count > 1 ) then
            x_msg_data := FND_MSG_PUB.GET(1, FND_API.G_FALSE);
	end if;

    when OTHERS then
        rollback to save_wf_notif_msg_maps;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        if FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
           FND_MSG_PUB.ADD_EXC_MSG(g_pkg_name, l_api_name);
        end if;
        FND_MSG_PUB.COUNT_AND_GET(p_encoded => FND_API.G_FALSE, P_COUNT => X_MSG_COUNT, P_DATA => X_MSG_DATA);
	if( x_msg_count > 1 ) then
            x_msg_data := FND_MSG_PUB.GET(1, FND_API.G_FALSE);
	end if;
ENd delete_wf_notif_msg_maps;

end IBE_WF_NOTIF_MSG_MAPS_PVT;

/
