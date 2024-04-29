--------------------------------------------------------
--  DDL for Package Body AMS_CUSTOM_SETUPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_CUSTOM_SETUPS_PKG" as
/* $Header: amslcusb.pls 120.1 2005/08/26 02:38:38 vmodur noship $ */
procedure INSERT_ROW (
  X_ROWID in OUT NOCOPY VARCHAR2,
  X_CUSTOM_SETUP_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ACTIVITY_TYPE_CODE in VARCHAR2,
  X_MEDIA_ID in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
  X_OBJECT_TYPE in VARCHAR2,
  X_SOURCE_CODE_SUFFIX in VARCHAR2,
  X_SETUP_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_ALLOW_ESSENTIAL_GROUPING in VARCHAR2,
  X_USAGE in VARCHAR2,
  X_MIGRATED_CUSTOM_SETUP_ID in NUMBER
) is
  cursor C is select ROWID from AMS_CUSTOM_SETUPS_B
    where CUSTOM_SETUP_ID = X_CUSTOM_SETUP_ID
    ;
begin
  insert into AMS_CUSTOM_SETUPS_B (
    CUSTOM_SETUP_ID,
    OBJECT_VERSION_NUMBER,
    ACTIVITY_TYPE_CODE,
    MEDIA_ID,
    ENABLED_FLAG,
    OBJECT_TYPE,
    SOURCE_CODE_SUFFIX,
    APPLICATION_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    ALLOW_ESSENTIAL_GROUPING,
    USAGE,
    MIGRATED_CUSTOM_SETUP_ID
  ) values (
    X_CUSTOM_SETUP_ID,
    X_OBJECT_VERSION_NUMBER,
    X_ACTIVITY_TYPE_CODE,
    X_MEDIA_ID,
    X_ENABLED_FLAG,
    X_OBJECT_TYPE,
    X_SOURCE_CODE_SUFFIX,
    X_APPLICATION_ID,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_ALLOW_ESSENTIAL_GROUPING,
    X_USAGE,
    X_MIGRATED_CUSTOM_SETUP_ID
  );

  insert into AMS_CUSTOM_SETUPS_TL (
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    SETUP_NAME,
    DESCRIPTION,
    CUSTOM_SETUP_ID,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_SETUP_NAME,
    X_DESCRIPTION,
    X_CUSTOM_SETUP_ID,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from AMS_CUSTOM_SETUPS_TL T
    where T.CUSTOM_SETUP_ID = X_CUSTOM_SETUP_ID
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
  X_CUSTOM_SETUP_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ACTIVITY_TYPE_CODE in VARCHAR2,
  X_MEDIA_ID in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
  X_OBJECT_TYPE in VARCHAR2,
  X_SETUP_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_ALLOW_ESSENTIAL_GROUPING in VARCHAR2,
  X_USAGE in VARCHAR2,
  X_MIGRATED_CUSTOM_SETUP_ID IN NUMBER
) is
  cursor c is select
      OBJECT_VERSION_NUMBER,
      ACTIVITY_TYPE_CODE,
      MEDIA_ID,
      ENABLED_FLAG,
      OBJECT_TYPE,
      ALLOW_ESSENTIAL_GROUPING,
      USAGE,
      MIGRATED_CUSTOM_SETUP_ID
    from AMS_CUSTOM_SETUPS_B
    where CUSTOM_SETUP_ID = X_CUSTOM_SETUP_ID
    for update of CUSTOM_SETUP_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      SETUP_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from AMS_CUSTOM_SETUPS_TL
    where CUSTOM_SETUP_ID = X_CUSTOM_SETUP_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of CUSTOM_SETUP_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
           OR ((recinfo.OBJECT_VERSION_NUMBER is null) AND (X_OBJECT_VERSION_NUMBER is null)))
      AND ((recinfo.ACTIVITY_TYPE_CODE = X_ACTIVITY_TYPE_CODE)
           OR ((recinfo.ACTIVITY_TYPE_CODE is null) AND (X_ACTIVITY_TYPE_CODE is null)))
      AND ((recinfo.MEDIA_ID = X_MEDIA_ID)
           OR ((recinfo.MEDIA_ID is null) AND (X_MEDIA_ID is null)))
      AND (recinfo.ENABLED_FLAG = X_ENABLED_FLAG)
      AND (recinfo.ALLOW_ESSENTIAL_GROUPING = X_ALLOW_ESSENTIAL_GROUPING)
      AND (recinfo.USAGE = X_USAGE)
      AND (recinfo.MIGRATED_CUSTOM_SETUP_ID = X_MIGRATED_CUSTOM_SETUP_ID)
      AND (recinfo.OBJECT_TYPE = X_OBJECT_TYPE)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.SETUP_NAME = X_SETUP_NAME)
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
  X_CUSTOM_SETUP_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ACTIVITY_TYPE_CODE in VARCHAR2,
  X_MEDIA_ID in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
  X_OBJECT_TYPE in VARCHAR2,
  X_SOURCE_CODE_SUFFIX in VARCHAR2,
  X_SETUP_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_ALLOW_ESSENTIAL_GROUPING in VARCHAR2,
  X_USAGE in VARCHAR2,
  X_MIGRATED_CUSTOM_SETUP_ID in NUMBER
) is
begin
  update AMS_CUSTOM_SETUPS_B set
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    ACTIVITY_TYPE_CODE = X_ACTIVITY_TYPE_CODE,
    MEDIA_ID = X_MEDIA_ID,
    ENABLED_FLAG = X_ENABLED_FLAG,
    OBJECT_TYPE = X_OBJECT_TYPE,
    APPLICATION_ID =  X_APPLICATION_ID,
    SOURCE_CODE_SUFFIX = X_SOURCE_CODE_SUFFIX,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    ALLOW_ESSENTIAL_GROUPING = X_ALLOW_ESSENTIAL_GROUPING,
    USAGE=X_USAGE,
    MIGRATED_CUSTOM_SETUP_ID = X_MIGRATED_CUSTOM_SETUP_ID
  where CUSTOM_SETUP_ID = X_CUSTOM_SETUP_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update AMS_CUSTOM_SETUPS_TL set
    SETUP_NAME = X_SETUP_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where CUSTOM_SETUP_ID = X_CUSTOM_SETUP_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_CUSTOM_SETUP_ID in NUMBER
) is
begin
  delete from AMS_CUSTOM_SETUPS_TL
  where CUSTOM_SETUP_ID = X_CUSTOM_SETUP_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from AMS_CUSTOM_SETUPS_B
  where CUSTOM_SETUP_ID = X_CUSTOM_SETUP_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from AMS_CUSTOM_SETUPS_TL T
  where not exists
    (select NULL
    from AMS_CUSTOM_SETUPS_B B
    where B.CUSTOM_SETUP_ID = T.CUSTOM_SETUP_ID
    );

  update AMS_CUSTOM_SETUPS_TL T set (
      SETUP_NAME,
      DESCRIPTION
    ) = (select
      B.SETUP_NAME,
      B.DESCRIPTION
    from AMS_CUSTOM_SETUPS_TL B
    where B.CUSTOM_SETUP_ID = T.CUSTOM_SETUP_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.CUSTOM_SETUP_ID,
      T.LANGUAGE
  ) in (select
      SUBT.CUSTOM_SETUP_ID,
      SUBT.LANGUAGE
    from AMS_CUSTOM_SETUPS_TL SUBB, AMS_CUSTOM_SETUPS_TL SUBT
    where SUBB.CUSTOM_SETUP_ID = SUBT.CUSTOM_SETUP_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.SETUP_NAME <> SUBT.SETUP_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into AMS_CUSTOM_SETUPS_TL (
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    SETUP_NAME,
    DESCRIPTION,
    CUSTOM_SETUP_ID,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.SETUP_NAME,
    B.DESCRIPTION,
    B.CUSTOM_SETUP_ID,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from AMS_CUSTOM_SETUPS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AMS_CUSTOM_SETUPS_TL T
    where T.CUSTOM_SETUP_ID = B.CUSTOM_SETUP_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;


procedure TRANSLATE_ROW(
       X_CUSTOM_SETUP_ID    in NUMBER
     , X_SETUP_NAME  in VARCHAR2
     , X_DESCRIPTION    in VARCHAR2
     , x_owner   in VARCHAR2
 ) is
 begin
  update ams_custom_setups_tl set
    setup_name = nvl(x_SETUP_NAME,   setup_name),
    description = nvl(x_description, description),
    source_lang = userenv('LANG'),
    last_update_date = sysdate,
    last_updated_by = decode(x_owner, 'SEED', 1, 0),
    last_update_login = 0
 where  custom_setup_id = x_custom_setup_id
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
procedure  LOAD_ROW(
  X_CUSTOM_SETUP_ID    in  NUMBER,
  X_ACTIVITY_TYPE_CODE in  VARCHAR2,
  X_MEDIA_ID     in       NUMBER,
  X_ENABLED_FLAG in    VARCHAR2,
  X_OBJECT_TYPE  in    VARCHAR2,
  X_SOURCE_CODE_SUFFIX in VARCHAR2,
  X_SETUP_NAME   in     VARCHAR2,
  X_DESCRIPTION  in   VARCHAR2,
  X_ALLOW_ESSENTIAL_GROUPING in VARCHAR2,
  X_USAGE in VARCHAR2 := NULL,
  X_MIGRATED_CUSTOM_SETUP_ID in NUMBER,
  X_APPLICATION_ID in NUMBER,
  X_Owner        in     VARCHAR2,
  x_custom_mode  IN VARCHAR2,
  X_LAST_UPDATE_DATE in DATE
) is

l_user_id   number := 1;
-- user id to be used in case of exceptions to update the customer modified unexposed data.
l_excp_user_id number := 3 ;

l_obj_verno  number;
l_dummy_number  number;
l_row_id    varchar2(100);
l_CUSTOM_SETUP_ID   number;
l_db_luby_id NUMBER;

cursor  c_db_data_details is
  select last_updated_by, nvl(object_version_number,1)
  from    ams_custom_setups_b
  where  CUSTOM_SETUP_ID =  X_CUSTOM_SETUP_ID;

cursor c_chk_cus_exists is
  select 1
  from   ams_custom_setups_b
   where  CUSTOM_SETUP_ID =  X_CUSTOM_SETUP_ID;

cursor c_get_cusid is
   select ams_custom_setups_b_S.nextval
   from dual;

BEGIN

  -- set the last_updated_by to be used while updating the data in customer data.
  if X_OWNER = 'SEED' then
    l_user_id := 1;
  elsif X_OWNER = 'ORACLE' THEN
    l_user_id := 2;
  elsif X_OWNER = 'SYSADMIN' THEN
    l_user_id := 0;
  end if ;


  open c_chk_cus_exists;
  fetch c_chk_cus_exists into l_dummy_number;
  if c_chk_cus_exists%notfound
  then
    -- data does not exist in customer, and hence create the data.
    close c_chk_cus_exists;
    if x_custom_setup_id is null
    then
      open c_get_cusid;
      fetch c_get_cusid into l_CUSTOM_SETUP_ID;
      close c_get_cusid;
    else
      l_CUSTOM_SETUP_ID := x_custom_setup_id;
    end if;

    l_obj_verno := 1;

    AMS_CUSTOM_SETUPS_PKG.INSERT_ROW(
      X_ROWID  => l_row_id,
      X_CUSTOM_SETUP_ID  => l_CUSTOM_SETUP_ID ,
      X_OBJECT_VERSION_NUMBER => l_obj_verno  ,
      X_ACTIVITY_TYPE_CODE  => X_ACTIVITY_TYPE_CODE,
      X_MEDIA_ID  => X_MEDIA_ID,
      X_ENABLED_FLAG  => X_ENABLED_FLAG,
      X_OBJECT_TYPE  => X_OBJECT_TYPE,
      X_SOURCE_CODE_SUFFIX => X_SOURCE_CODE_SUFFIX,
      X_SETUP_NAME  => X_SETUP_NAME,
      X_DESCRIPTION  => X_DESCRIPTION,
      X_APPLICATION_ID => X_APPLICATION_ID,
      X_CREATION_DATE  => X_LAST_UPDATE_DATE,
      X_CREATED_BY  => l_user_id,
      X_LAST_UPDATE_DATE  => X_LAST_UPDATE_DATE,
      X_LAST_UPDATED_BY  => l_user_id,
      X_LAST_UPDATE_LOGIN  => 0,
      X_ALLOW_ESSENTIAL_GROUPING => X_ALLOW_ESSENTIAL_GROUPING,
      X_USAGE => X_USAGE,
      X_MIGRATED_CUSTOM_SETUP_ID => X_MIGRATED_CUSTOM_SETUP_ID
      );
  else
    -- Update the data as per above rules.
    close c_chk_cus_exists;
    open c_db_data_details;
    fetch c_db_data_details into l_db_luby_id, l_obj_verno;
    close c_db_data_details;
    if ( l_db_luby_id IN (1, 2, 0)
      OR NVL(x_custom_mode,'PRESERVE') = 'FORCE') THEN
      AMS_CUSTOM_SETUPS_PKG.UPDATE_ROW(
        X_CUSTOM_SETUP_ID  => X_CUSTOM_SETUP_ID,
        X_OBJECT_VERSION_NUMBER => l_obj_verno + 1  ,
        X_ACTIVITY_TYPE_CODE  => X_ACTIVITY_TYPE_CODE,
        X_MEDIA_ID  => X_MEDIA_ID ,
        X_ENABLED_FLAG  => X_ENABLED_FLAG,
        X_OBJECT_TYPE  => X_OBJECT_TYPE,
        X_SOURCE_CODE_SUFFIX => X_SOURCE_CODE_SUFFIX,
        X_SETUP_NAME  => X_SETUP_NAME,
        X_DESCRIPTION  => X_DESCRIPTION,
        X_APPLICATION_ID => X_APPLICATION_ID,
        X_LAST_UPDATE_DATE  => X_LAST_UPDATE_DATE,
        X_LAST_UPDATED_BY  => l_user_id,
        X_LAST_UPDATE_LOGIN  => 0,
	X_ALLOW_ESSENTIAL_GROUPING => X_ALLOW_ESSENTIAL_GROUPING,
	X_USAGE => X_USAGE,
        X_MIGRATED_CUSTOM_SETUP_ID => X_MIGRATED_CUSTOM_SETUP_ID
      );
--Commented OUT NOCOPY as this will not be ever needed as per nrengasw, and bgeorge.
/*
    else
      update AMS_CUSTOM_SETUPS_B set
        OBJECT_VERSION_NUMBER = l_obj_verno + 1,
        OBJECT_TYPE  = X_OBJECT_TYPE,
        ACTIVITY_TYPE_CODE  = X_ACTIVITY_TYPE_CODE,
        SOURCE_CODE_SUFFIX = X_SOURCE_CODE_SUFFIX,
        MEDIA_ID  = X_MEDIA_ID , --???
        LAST_UPDATE_DATE = sysdate,
        LAST_UPDATED_BY = l_excp_user_id,
        LAST_UPDATE_LOGIN = 0
      where CUSTOM_SETUP_ID = X_CUSTOM_SETUP_ID;
      if (sql%notfound) then
        raise no_data_found;
      end if;
*/
    end if;
  end if;
END LOAD_ROW;

end AMS_CUSTOM_SETUPS_PKG;

/
