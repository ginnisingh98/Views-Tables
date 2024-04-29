--------------------------------------------------------
--  DDL for Package Body AMS_USER_STATUSES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_USER_STATUSES_PKG" as
/* $Header: amslustb.pls 120.1 2006/05/08 01:35:17 mayjain noship $ */
AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

procedure INSERT_ROW (
  X_ROWID in OUT NOCOPY VARCHAR2,
  X_USER_STATUS_ID in NUMBER,
  X_DEFAULT_FLAG in VARCHAR2,
  X_SEEDED_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_SYSTEM_STATUS_TYPE in VARCHAR2,
  X_SYSTEM_STATUS_CODE in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_APPLICATION_ID in NUMBER DEFAULT '530'
) is
  cursor C is select ROWID from AMS_USER_STATUSES_B
    where USER_STATUS_ID = X_USER_STATUS_ID
    ;
begin
  insert into AMS_USER_STATUSES_B (
    DEFAULT_FLAG,
    SEEDED_FLAG,
    USER_STATUS_ID,
    OBJECT_VERSION_NUMBER,
    SYSTEM_STATUS_TYPE,
    SYSTEM_STATUS_CODE,
    ENABLED_FLAG,
    START_DATE_ACTIVE,
    END_DATE_ACTIVE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    APPLICATION_ID
  ) values (
    X_DEFAULT_FLAG,
    X_SEEDED_FLAG,
    X_USER_STATUS_ID,
    X_OBJECT_VERSION_NUMBER,
    X_SYSTEM_STATUS_TYPE,
    X_SYSTEM_STATUS_CODE,
    X_ENABLED_FLAG,
    X_START_DATE_ACTIVE,
    X_END_DATE_ACTIVE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_APPLICATION_ID
  );

  insert into AMS_USER_STATUSES_TL (
    USER_STATUS_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    NAME,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_USER_STATUS_ID,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_NAME,
    X_DESCRIPTION,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from AMS_USER_STATUSES_TL T
    where T.USER_STATUS_ID = X_USER_STATUS_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_USER_STATUS_ID in NUMBER,
  X_DEFAULT_FLAG in VARCHAR2,
  X_SEEDED_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_SYSTEM_STATUS_TYPE in VARCHAR2,
  X_SYSTEM_STATUS_CODE in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      DEFAULT_FLAG,
      SEEDED_FLAG,
      OBJECT_VERSION_NUMBER,
      SYSTEM_STATUS_TYPE,
      SYSTEM_STATUS_CODE,
      ENABLED_FLAG,
      START_DATE_ACTIVE,
      END_DATE_ACTIVE
    from AMS_USER_STATUSES_B
    where USER_STATUS_ID = X_USER_STATUS_ID
    for update of USER_STATUS_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from AMS_USER_STATUSES_TL
    where USER_STATUS_ID = X_USER_STATUS_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of USER_STATUS_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.DEFAULT_FLAG = X_DEFAULT_FLAG)
           OR ((recinfo.DEFAULT_FLAG is null) AND (X_DEFAULT_FLAG is null)))
      AND ((recinfo.SEEDED_FLAG = X_SEEDED_FLAG)
           OR ((recinfo.SEEDED_FLAG is null) AND (X_SEEDED_FLAG is null)))
      AND ((recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
           OR ((recinfo.OBJECT_VERSION_NUMBER is null) AND (X_OBJECT_VERSION_NUMBER is null)))
      AND ((recinfo.SYSTEM_STATUS_TYPE = X_SYSTEM_STATUS_TYPE)
           OR ((recinfo.SYSTEM_STATUS_TYPE is null) AND (X_SYSTEM_STATUS_TYPE is null)))
      AND ((recinfo.SYSTEM_STATUS_CODE = X_SYSTEM_STATUS_CODE)
           OR ((recinfo.SYSTEM_STATUS_CODE is null) AND (X_SYSTEM_STATUS_CODE is null)))
      AND ((recinfo.ENABLED_FLAG = X_ENABLED_FLAG)
           OR ((recinfo.ENABLED_FLAG is null) AND (X_ENABLED_FLAG is null)))
      AND ((recinfo.START_DATE_ACTIVE = X_START_DATE_ACTIVE)
           OR ((recinfo.START_DATE_ACTIVE is null) AND (X_START_DATE_ACTIVE is null)))
      AND ((recinfo.END_DATE_ACTIVE = X_END_DATE_ACTIVE)
           OR ((recinfo.END_DATE_ACTIVE is null) AND (X_END_DATE_ACTIVE is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.NAME = X_NAME)
               OR ((tlinfo.NAME is null) AND (X_NAME is null)))
          AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
               OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
    end if;
  end loop;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_USER_STATUS_ID in NUMBER,
  X_DEFAULT_FLAG in VARCHAR2,
  X_SEEDED_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_SYSTEM_STATUS_TYPE in VARCHAR2,
  X_SYSTEM_STATUS_CODE in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_APPLICATION_ID in NUMBER DEFAULT '530'
) is

/*08-May-2006  mayjain  fix for bug 5166318*/
cursor count_def_flag (P_SYSTEM_STATUS_TYPE VARCHAR2, P_SYSTEM_STATUS_CODE VARCHAR2)
IS
select count(1)
from AMS_USER_STATUSES_B
where SYSTEM_STATUS_TYPE = P_SYSTEM_STATUS_TYPE and
SYSTEM_STATUS_CODE = P_SYSTEM_STATUS_CODE and
ENABLED_FLAG = 'Y' and
DEFAULT_FLAG = 'Y' and
SEEDED_FLAG <> 'Y';

l_def_count NUMBER := 0;
l_default_flag VARCHAR2(1) :='Y';
/*08-May-2006  mayjain  fix for bug 5166318*/
begin

  /*08-May-2006  mayjain  fix for bug 5166318*/
  -- The default flag should be defaulted to the one in ldt file.
  l_default_flag := X_DEFAULT_FLAG;
  -- If this is a seeded and default user status
  IF (X_DEFAULT_FLAG = 'Y') and (X_SEEDED_FLAG = 'Y')
  THEN
      -- Find out if there is a custom user status that is default
      open count_def_flag (X_SYSTEM_STATUS_TYPE, X_SYSTEM_STATUS_CODE);
      fetch count_def_flag into l_def_count;
      close count_def_flag;

      -- if there is a custom default user status, then the seeded user status should be marked as 'N'
      IF l_def_count > 0
      THEN l_default_flag := 'N';
      END IF;
  END IF;
  /*08-May-2006  mayjain  fix for bug 5166318*/

  update AMS_USER_STATUSES_B set
    DEFAULT_FLAG = l_default_flag, /*08-May-2006  mayjain  fix for bug 5166318*/
    SEEDED_FLAG = X_SEEDED_FLAG,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    SYSTEM_STATUS_TYPE = X_SYSTEM_STATUS_TYPE,
    SYSTEM_STATUS_CODE = X_SYSTEM_STATUS_CODE,
    ENABLED_FLAG = X_ENABLED_FLAG,
    START_DATE_ACTIVE = X_START_DATE_ACTIVE,
    END_DATE_ACTIVE = X_END_DATE_ACTIVE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    APPLICATION_ID = X_APPLICATION_ID
  where USER_STATUS_ID = X_USER_STATUS_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update AMS_USER_STATUSES_TL set
    NAME = X_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where USER_STATUS_ID = X_USER_STATUS_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_USER_STATUS_ID in NUMBER
) is
begin
  delete from AMS_USER_STATUSES_TL
  where USER_STATUS_ID = X_USER_STATUS_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from AMS_USER_STATUSES_B
  where USER_STATUS_ID = X_USER_STATUS_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from AMS_USER_STATUSES_TL T
  where not exists
    (select NULL
    from AMS_USER_STATUSES_B B
    where B.USER_STATUS_ID = T.USER_STATUS_ID
    );

  update AMS_USER_STATUSES_TL T set (
      NAME,
      DESCRIPTION
    ) = (select
      B.NAME,
      B.DESCRIPTION
    from AMS_USER_STATUSES_TL B
    where B.USER_STATUS_ID = T.USER_STATUS_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.USER_STATUS_ID,
      T.LANGUAGE
  ) in (select
      SUBT.USER_STATUS_ID,
      SUBT.LANGUAGE
    from AMS_USER_STATUSES_TL SUBB, AMS_USER_STATUSES_TL SUBT
    where SUBB.USER_STATUS_ID = SUBT.USER_STATUS_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or (SUBB.NAME is null and SUBT.NAME is not null)
      or (SUBB.NAME is not null and SUBT.NAME is null)
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into AMS_USER_STATUSES_TL (
    USER_STATUS_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    NAME,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.USER_STATUS_ID,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.NAME,
    B.DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from AMS_USER_STATUSES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AMS_USER_STATUSES_TL T
    where T.USER_STATUS_ID = B.USER_STATUS_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;



procedure TRANSLATE_ROW(
	  X_USER_STATUS_ID	in NUMBER,
	  X_NAME		in VARCHAR2,
	  X_DESCRIPTION		in VARCHAR2,
	  X_OWNER		in VARCHAR2
 ) IS

 begin
    update AMS_USER_STATUSES_TL set
       name = nvl(x_name, name),
       description = nvl(x_description, description),
       source_lang = userenv('LANG'),
       last_update_date = sysdate,
       last_updated_by = decode(x_owner, 'SEED', 1, 0),
       last_update_login = 0
    where  user_status_id = x_user_status_id
    and      userenv('LANG') in (language, source_lang);
end TRANSLATE_ROW;

/* This procedure is used to load the data from flat file to customer's database.
  If there is no row existing for the data from flat file then create the data.
  else
    1) modify the whole data when data in db is not modified by customer which can be found
      by comparing last updated by value to be
          SEED/DATAMERGE(1), or
          INITIAL SETUP/ORACLE (2), or
          SYSTEM ADMINISTRATOR (0).or
    2) modify the whole data when custom_mode is 'FORCE'
    3) if the data in db is modified by customer, which can be found by
      by comparing last updated by value to be not of 0,1,2, then
        in that case modify only the user unexposed data with last updated by as 3 to
        distinguish that data is updated by patch.
*/
procedure LOAD_ROW (
  X_USER_STATUS_ID		in NUMBER,
  X_DEFAULT_FLAG		in VARCHAR2 DEFAULT 'N',
  X_SEEDED_FLAG			in VARCHAR2 DEFAULT 'Y',
  X_OBJECT_VERSION_NUMBER	in NUMBER,
  X_SYSTEM_STATUS_TYPE		in VARCHAR2,
  X_SYSTEM_STATUS_CODE		in VARCHAR2,
  X_ENABLED_FLAG		in VARCHAR2 DEFAULT 'Y',
  X_START_DATE_ACTIVE		in DATE,
  X_END_DATE_ACTIVE		in DATE,
  X_NAME			in VARCHAR2,
  X_DESCRIPTION			in VARCHAR2,
  X_OWNER			in VARCHAR2,
  X_APPLICATION_ID		in NUMBER DEFAULT '530',
  X_CUSTOM_MODE                 in VARCHAR2
  ) IS



l_user_id   number := 1;
l_obj_verno  number;
l_dummy_char  varchar2(1);
l_row_id    varchar2(100);
l_user_status_id   number;
l_db_luby_id number;
/*
cursor  c_obj_verno is
  select object_version_number
  from    AMS_USER_STATUSES_B
  where  user_status_id =  X_USER_STATUS_ID;
*/
cursor c_chk_ust_exists is
  select 'x'
  from    AMS_USER_STATUSES_B
  where  user_status_id =  X_USER_STATUS_ID;

cursor c_get_ust_id is
   select AMS_USER_STATUSES_B_S.nextval
   from dual;

cursor  c_db_data_details is
  select last_updated_by, nvl(object_version_number,1)
  from   AMS_USER_STATUSES_B
  where  user_status_id =  X_USER_STATUS_ID;
BEGIN

  -- set the last_updated_by to be used while updating the data in customer data.
  if X_OWNER = 'SEED' then
    l_user_id := 1;
  elsif X_OWNER = 'ORACLE' THEN
    l_user_id := 2;
  elsif X_OWNER = 'SYSADMIN' THEN
    l_user_id := 0;
  end if ;

 open c_chk_ust_exists;
 fetch c_chk_ust_exists into l_dummy_char;
 if c_chk_ust_exists%notfound
 then
    -- data does not exist at customer site and hence create the data
    close c_chk_ust_exists;
    if X_USER_STATUS_ID is null
    then
      open c_get_ust_id;
      fetch c_get_ust_id into l_user_status_id;
      close c_get_ust_id;
    else
       l_user_status_id := X_USER_STATUS_ID;
    end if;
    l_obj_verno := 1;

    AMS_USER_STATUSES_PKG.INSERT_ROW(
    X_ROWID			=> l_row_id,
    X_USER_STATUS_ID		=> l_user_status_id,
    X_DEFAULT_FLAG		=> X_DEFAULT_FLAG,
    X_SEEDED_FLAG		=> X_SEEDED_FLAG,
    X_OBJECT_VERSION_NUMBER	=> l_obj_verno,
    X_SYSTEM_STATUS_TYPE	=> X_SYSTEM_STATUS_TYPE,
    X_SYSTEM_STATUS_CODE	=> X_SYSTEM_STATUS_CODE,
    X_ENABLED_FLAG		=> X_ENABLED_FLAG,
    X_START_DATE_ACTIVE		=> X_START_DATE_ACTIVE,
    X_END_DATE_ACTIVE		=> X_END_DATE_ACTIVE,
    X_NAME			=> X_NAME,
    X_DESCRIPTION		=> X_DESCRIPTION,
    X_CREATION_DATE		=> SYSDATE,
    X_CREATED_BY		=> l_user_id,
    X_LAST_UPDATE_DATE		=> SYSDATE,
    X_LAST_UPDATED_BY		=> l_user_id,
    X_LAST_UPDATE_LOGIN		=> 0,
    X_APPLICATION_ID		=> X_APPLICATION_ID);


else
   -- update the data as per above rules
   close c_chk_ust_exists;
   open c_db_data_details;
   fetch c_db_data_details into l_db_luby_id, l_obj_verno;
   close c_db_data_details;
-- assigning value for l_user_status_id
	l_user_status_id := X_USER_STATUS_ID;

   if (l_db_luby_id IN (1,2,0)
      OR NVL(x_custom_mode,'PRESERVE') = 'FORCE') THEN

      AMS_USER_STATUSES_PKG.UPDATE_ROW(
         X_USER_STATUS_ID               => l_user_status_id,
         X_OBJECT_VERSION_NUMBER        => l_obj_verno + 1,
         X_DEFAULT_FLAG                 => X_DEFAULT_FLAG,
         X_SEEDED_FLAG                  => X_SEEDED_FLAG,
         X_SYSTEM_STATUS_TYPE           => X_SYSTEM_STATUS_TYPE,
         X_SYSTEM_STATUS_CODE           => X_SYSTEM_STATUS_CODE,
         X_ENABLED_FLAG                 => X_ENABLED_FLAG,
         X_START_DATE_ACTIVE            => X_START_DATE_ACTIVE,
         X_END_DATE_ACTIVE              => X_END_DATE_ACTIVE,
         X_NAME	                        => X_NAME,
         X_DESCRIPTION                  => X_DESCRIPTION,
         X_LAST_UPDATE_DATE             => SYSDATE,
         X_LAST_UPDATED_BY              => l_user_id,
         X_LAST_UPDATE_LOGIN            => 0,
         X_APPLICATION_ID               => X_APPLICATION_ID);

   end if;

end if;
END LOAD_ROW;


end AMS_USER_STATUSES_PKG;

/
