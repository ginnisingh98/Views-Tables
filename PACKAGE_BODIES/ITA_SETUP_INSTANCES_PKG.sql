--------------------------------------------------------
--  DDL for Package Body ITA_SETUP_INSTANCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ITA_SETUP_INSTANCES_PKG" as
/* $Header: itatinsb.pls 120.0 2005/05/31 16:37:12 appldev noship $ */


procedure INSERT_ROW (
  X_INSTANCE_CODE in VARCHAR2,
  X_INSTANCE_NAME in VARCHAR2,
  X_DBC_FILE_PATH in VARCHAR2,
  X_DBC_FILE_NAME in VARCHAR2,
  X_CURRENT_FLAG in VARCHAR2,
  X_MASTER_FLAG in VARCHAR2,
  X_SECURITY_GROUP_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  insert into ITA_SETUP_INSTANCES_B (
    INSTANCE_CODE,
    DBC_FILE_PATH,
    DBC_FILE_NAME,
    CURRENT_FLAG,
    MASTER_FLAG,
    SECURITY_GROUP_ID,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_INSTANCE_CODE,
    X_DBC_FILE_PATH,
    X_DBC_FILE_NAME,
    X_CURRENT_FLAG,
    X_MASTER_FLAG,
    X_SECURITY_GROUP_ID,
    X_OBJECT_VERSION_NUMBER,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into ITA_SETUP_INSTANCES_TL (
    INSTANCE_CODE,
    INSTANCE_NAME,
    SECURITY_GROUP_ID,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_INSTANCE_CODE,
    X_INSTANCE_NAME,
    X_SECURITY_GROUP_ID,
    X_OBJECT_VERSION_NUMBER,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists (
    select null
    from ITA_SETUP_INSTANCES_TL tl
    where
      tl.INSTANCE_CODE = X_INSTANCE_CODE and
      tl.LANGUAGE = L.LANGUAGE_CODE);
end INSERT_ROW;


procedure LOCK_ROW (
  X_INSTANCE_CODE in VARCHAR2,
  X_INSTANCE_NAME in VARCHAR2,
  X_DBC_FILE_PATH in VARCHAR2,
  X_DBC_FILE_NAME in VARCHAR2,
  X_CURRENT_FLAG in VARCHAR2,
  X_MASTER_FLAG in VARCHAR2,
  X_SECURITY_GROUP_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER
) is
  cursor c is select
	INSTANCE_CODE,
  	DBC_FILE_PATH,
  	DBC_FILE_NAME,
  	CURRENT_FLAG,
  	MASTER_FLAG,
      SECURITY_GROUP_ID,
      OBJECT_VERSION_NUMBER
    from ITA_SETUP_INSTANCES_B
    where INSTANCE_CODE = X_INSTANCE_CODE
    for update of INSTANCE_CODE nowait;
  recinfo c%rowtype;

  cursor c1 is select
      INSTANCE_NAME,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from ITA_SETUP_INSTANCES_TL
    where
      INSTANCE_CODE = X_INSTANCE_CODE and
      userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of INSTANCE_CODE nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.INSTANCE_CODE = X_INSTANCE_CODE)
      and ((recinfo.DBC_FILE_PATH = X_DBC_FILE_PATH)
           or ((recinfo.DBC_FILE_PATH is null) and (X_DBC_FILE_PATH is null)))
      and ((recinfo.DBC_FILE_NAME = X_DBC_FILE_NAME)
           or ((recinfo.DBC_FILE_NAME is null) and (X_DBC_FILE_NAME is null)))
      and ((recinfo.CURRENT_FLAG = X_CURRENT_FLAG)
           or ((recinfo.CURRENT_FLAG is null) and (X_CURRENT_FLAG is null)))
      and ((recinfo.MASTER_FLAG = X_MASTER_FLAG)
           or ((recinfo.MASTER_FLAG is null) and (X_MASTER_FLAG is null)))
      and ((recinfo.SECURITY_GROUP_ID = X_SECURITY_GROUP_ID)
           or ((recinfo.SECURITY_GROUP_ID is null) and (X_SECURITY_GROUP_ID is null)))
      and ((recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
           or ((recinfo.OBJECT_VERSION_NUMBER is null) and (X_OBJECT_VERSION_NUMBER is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.INSTANCE_NAME = X_INSTANCE_NAME)
               or ((tlinfo.INSTANCE_NAME is null) and (X_INSTANCE_NAME is null)))
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
  X_INSTANCE_CODE in VARCHAR2,
  X_INSTANCE_NAME in VARCHAR2,
  X_DBC_FILE_PATH in VARCHAR2,
  X_DBC_FILE_NAME in VARCHAR2,
  X_CURRENT_FLAG in VARCHAR2,
  X_MASTER_FLAG in VARCHAR2,
  X_SECURITY_GROUP_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update ITA_SETUP_INSTANCES_B set
    INSTANCE_CODE = X_INSTANCE_CODE,
    DBC_FILE_PATH = X_DBC_FILE_PATH,
    DBC_FILE_NAME = X_DBC_FILE_NAME,
    MASTER_FLAG = X_MASTER_FLAG,
    CURRENT_FLAG = X_CURRENT_FLAG,
    SECURITY_GROUP_ID = X_SECURITY_GROUP_ID,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where INSTANCE_CODE = X_INSTANCE_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update ITA_SETUP_INSTANCES_TL set
    INSTANCE_NAME = X_INSTANCE_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where
    INSTANCE_CODE = X_INSTANCE_CODE and
    userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;


procedure DELETE_ROW (
  X_INSTANCE_CODE in VARCHAR2
) is
begin
  delete from ITA_SETUP_INSTANCES_TL
  where INSTANCE_CODE = X_INSTANCE_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from ITA_SETUP_INSTANCES_B
  where INSTANCE_CODE = X_INSTANCE_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;


procedure LOAD_ROW (
  X_INSTANCE_CODE in VARCHAR2,
  X_INSTANCE_NAME in VARCHAR2,
  X_DBC_FILE_PATH in VARCHAR2,
  X_DBC_FILE_NAME in VARCHAR2,
  X_CURRENT_FLAG in VARCHAR2,
  X_MASTER_FLAG in VARCHAR2,
  X_LAST_UPDATE_DATE in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2
) is

f_luby	number;	-- entity owner in file
f_ludate	date;		-- entity update date in file
db_luby	number;	-- entity owner in db
db_ludate	date;		-- entity update date in db

begin
	-- Translate owner to file_last_updated_by
	f_luby := fnd_load_util.owner_id(X_OWNER);

	-- Translate char last_update_date to date
	f_ludate := nvl(to_date(X_LAST_UPDATE_DATE, 'YYYY/MM/DD'), sysdate);

	select LAST_UPDATED_BY, LAST_UPDATE_DATE into db_luby, db_ludate
	from ITA_SETUP_INSTANCES_B
	where INSTANCE_CODE = X_INSTANCE_CODE;

	if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby, db_ludate, X_CUSTOM_MODE))
	then ITA_SETUP_INSTANCES_PKG.UPDATE_ROW (
		X_INSTANCE_CODE			=> X_INSTANCE_CODE,
		X_INSTANCE_NAME			=> X_INSTANCE_NAME,
		X_DBC_FILE_PATH			=> X_DBC_FILE_PATH,
		X_DBC_FILE_NAME			=> X_DBC_FILE_NAME,
		X_CURRENT_FLAG			=> X_CURRENT_FLAG,
		X_MASTER_FLAG			=> X_MASTER_FLAG,
		X_SECURITY_GROUP_ID		=> null,
		X_OBJECT_VERSION_NUMBER		=> 1,
		X_LAST_UPDATE_DATE		=> f_ludate,
		X_LAST_UPDATED_BY			=> f_luby,
		X_LAST_UPDATE_LOGIN		=> 0);
	end if;
	exception when NO_DATA_FOUND
	then ITA_SETUP_INSTANCES_PKG.INSERT_ROW (
		X_INSTANCE_CODE			=> X_INSTANCE_CODE,
		X_INSTANCE_NAME			=> X_INSTANCE_NAME,
		X_DBC_FILE_PATH			=> X_DBC_FILE_PATH,
		X_DBC_FILE_NAME			=> X_DBC_FILE_NAME,
		X_CURRENT_FLAG			=> X_CURRENT_FLAG,
		X_MASTER_FLAG			=> X_MASTER_FLAG,
		X_SECURITY_GROUP_ID		=> null,
		X_OBJECT_VERSION_NUMBER		=> 1,
		X_CREATION_DATE			=> f_ludate,
		X_CREATED_BY			=> f_luby,
		X_LAST_UPDATE_DATE		=> f_ludate,
		X_LAST_UPDATED_BY			=> f_luby,
		X_LAST_UPDATE_LOGIN		=> 0);
end LOAD_ROW;


procedure ADD_LANGUAGE
is
begin
  delete from ITA_SETUP_INSTANCES_TL tl
  where not exists (
    select null
    from ITA_SETUP_INSTANCES_B b
    where b.INSTANCE_CODE = tl.INSTANCE_CODE
    );

  update ITA_SETUP_INSTANCES_TL tl set (
      INSTANCE_NAME
    ) = (select
      b.INSTANCE_NAME
    from ITA_SETUP_INSTANCES_TL b
    where
      b.INSTANCE_CODE = tl.INSTANCE_CODE and
      b.LANGUAGE = tl.SOURCE_LANG)
  where (
      tl.INSTANCE_CODE,
      tl.LANGUAGE
  ) in (select
      subtl.INSTANCE_CODE,
      subtl.LANGUAGE
    from ITA_SETUP_INSTANCES_TL subb, ITA_SETUP_INSTANCES_TL subtl
    where
      subb.INSTANCE_CODE = subtl.INSTANCE_CODE and
      subb.LANGUAGE = subtl.SOURCE_LANG and
    	(subb.INSTANCE_NAME <> subtl.INSTANCE_NAME or
        (subb.INSTANCE_NAME is null and subtl.INSTANCE_NAME is not null) or
        (subb.INSTANCE_NAME is not null and subtl.INSTANCE_NAME is null)));

  insert into ITA_SETUP_INSTANCES_TL (
    INSTANCE_CODE,
    INSTANCE_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    SECURITY_GROUP_ID,
    OBJECT_VERSION_NUMBER,
    LANGUAGE,
    SOURCE_LANG
  ) select
    b.INSTANCE_CODE,
    b.INSTANCE_NAME,
    b.CREATED_BY,
    b.CREATION_DATE,
    b.LAST_UPDATED_BY,
    b.LAST_UPDATE_DATE,
    b.LAST_UPDATE_LOGIN,
    b.SECURITY_GROUP_ID,
    b.OBJECT_VERSION_NUMBER,
    L.LANGUAGE_CODE,
    b.SOURCE_LANG
  from ITA_SETUP_INSTANCES_TL b, FND_LANGUAGES L
  where
    L.INSTALLED_FLAG in ('I', 'B') and
    b.LANGUAGE = userenv('LANG') and
    not exists (
     select null
     from ITA_SETUP_INSTANCES_TL tl
     where
       tl.INSTANCE_CODE = b.INSTANCE_CODE and
       tl.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;


procedure TRANSLATE_ROW (
  X_INSTANCE_CODE in VARCHAR2,
  X_INSTANCE_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2
) is

f_luby	number;	-- entity owner in file
f_ludate	date;		-- entity update date in file
db_luby	number;	-- entity owner in db
db_ludate	date;		-- entity update date in db

begin
	-- Translate owner to file_last_updated_by
	f_luby := fnd_load_util.owner_id(X_OWNER);

	-- Translate char last_update_date to date
	f_ludate := nvl(to_date(X_LAST_UPDATE_DATE, 'YYYY/MM/DD'), sysdate);

	select LAST_UPDATED_BY, LAST_UPDATE_DATE into db_luby, db_ludate
	from ITA_SETUP_INSTANCES_TL
	where INSTANCE_CODE = X_INSTANCE_CODE and LANGUAGE = userenv('LANG');

	if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby, db_ludate, X_CUSTOM_MODE))
	then update ITA_SETUP_INSTANCES_TL set
		INSTANCE_NAME		= nvl(X_INSTANCE_NAME, INSTANCE_NAME),
		SOURCE_LANG			= userenv('LANG'),
		LAST_UPDATE_DATE		= f_ludate,
		LAST_UPDATED_BY		= f_luby,
		LAST_UPDATE_LOGIN		= 0
	where	INSTANCE_CODE = X_INSTANCE_CODE and userenv('LANG') in (LANGUAGE, SOURCE_LANG);
	end if;
end TRANSLATE_ROW;


end ITA_SETUP_INSTANCES_PKG;

/
