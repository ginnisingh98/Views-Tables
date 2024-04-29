--------------------------------------------------------
--  DDL for Package Body AMW_OPINION_COMPONTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMW_OPINION_COMPONTS_PKG" as
/* $Header: amwtopcb.pls 115.3 2003/12/08 19:34:26 cpetriuc noship $ */

procedure INSERT_ROW (
  X_OPINION_COMPONENT_ID in NUMBER,
  X_OPINION_COMPONENT_CODE in VARCHAR2,
  X_OBJECT_OPINION_TYPE_ID in NUMBER,
  X_PAGE_ORDER in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_OPINION_COMPONENT_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  insert into AMW_OPINION_COMPONTS_B (
    OPINION_COMPONENT_ID,
    OPINION_COMPONENT_CODE,
    OBJECT_OPINION_TYPE_ID,
    PAGE_ORDER,
    SECURITY_GROUP_ID,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_OPINION_COMPONENT_ID,
    X_OPINION_COMPONENT_CODE,
    X_OBJECT_OPINION_TYPE_ID,
    X_PAGE_ORDER,
    X_SECURITY_GROUP_ID,
    X_OBJECT_VERSION_NUMBER,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into AMW_OPINION_COMPONTS_TL (
    OPINION_COMPONENT_ID,
    OPINION_COMPONENT_NAME,
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
    X_OPINION_COMPONENT_ID,
    X_OPINION_COMPONENT_NAME,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    X_SECURITY_GROUP_ID,
    X_OBJECT_VERSION_NUMBER,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from AMW_OPINION_COMPONTS_TL T
    where T.OPINION_COMPONENT_ID = X_OPINION_COMPONENT_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end INSERT_ROW;

procedure LOCK_ROW (
  X_OPINION_COMPONENT_ID in NUMBER,
  X_OPINION_COMPONENT_CODE in VARCHAR2,
  X_OBJECT_OPINION_TYPE_ID in NUMBER,
  X_PAGE_ORDER in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_OPINION_COMPONENT_NAME in VARCHAR2
) is
  cursor c is select
	OPINION_COMPONENT_CODE,
      OBJECT_OPINION_TYPE_ID,
      PAGE_ORDER,
      SECURITY_GROUP_ID,
      OBJECT_VERSION_NUMBER
    from AMW_OPINION_COMPONTS_B
    where OPINION_COMPONENT_ID = X_OPINION_COMPONENT_ID
    for update of OPINION_COMPONENT_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      OPINION_COMPONENT_NAME,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from AMW_OPINION_COMPONTS_TL
    where OPINION_COMPONENT_ID = X_OPINION_COMPONENT_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of OPINION_COMPONENT_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.OPINION_COMPONENT_CODE = X_OPINION_COMPONENT_CODE)
	AND (recinfo.OBJECT_OPINION_TYPE_ID = X_OBJECT_OPINION_TYPE_ID)
      AND (recinfo.PAGE_ORDER = X_PAGE_ORDER)
      AND ((recinfo.SECURITY_GROUP_ID = X_SECURITY_GROUP_ID)
           OR ((recinfo.SECURITY_GROUP_ID is null) AND (X_SECURITY_GROUP_ID is null)))
      AND ((recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
           OR ((recinfo.OBJECT_VERSION_NUMBER is null) AND (X_OBJECT_VERSION_NUMBER is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.OPINION_COMPONENT_NAME = X_OPINION_COMPONENT_NAME)
               OR ((tlinfo.OPINION_COMPONENT_NAME is null) AND (X_OPINION_COMPONENT_NAME is null)))
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
  X_OPINION_COMPONENT_ID in NUMBER,
  X_OPINION_COMPONENT_CODE in VARCHAR2,
  X_OBJECT_OPINION_TYPE_ID in NUMBER,
  X_PAGE_ORDER in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_OPINION_COMPONENT_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update AMW_OPINION_COMPONTS_B set
    OPINION_COMPONENT_CODE = X_OPINION_COMPONENT_CODE,
    OBJECT_OPINION_TYPE_ID = X_OBJECT_OPINION_TYPE_ID,
    PAGE_ORDER = X_PAGE_ORDER,
    SECURITY_GROUP_ID = X_SECURITY_GROUP_ID,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where OPINION_COMPONENT_ID = X_OPINION_COMPONENT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update AMW_OPINION_COMPONTS_TL set
    OPINION_COMPONENT_NAME = X_OPINION_COMPONENT_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where OPINION_COMPONENT_ID = X_OPINION_COMPONENT_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_OPINION_COMPONENT_ID in NUMBER
) is
begin
  delete from AMW_OPINION_COMPONTS_TL
  where OPINION_COMPONENT_ID = X_OPINION_COMPONENT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from AMW_OPINION_COMPONTS_B
  where OPINION_COMPONENT_ID = X_OPINION_COMPONENT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from AMW_OPINION_COMPONTS_TL T
  where not exists
    (select NULL
    from AMW_OPINION_COMPONTS_B B
    where B.OPINION_COMPONENT_ID = T.OPINION_COMPONENT_ID
    );

  update AMW_OPINION_COMPONTS_TL T set (
      OPINION_COMPONENT_NAME
    ) = (select
      B.OPINION_COMPONENT_NAME
    from AMW_OPINION_COMPONTS_TL B
    where B.OPINION_COMPONENT_ID = T.OPINION_COMPONENT_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.OPINION_COMPONENT_ID,
      T.LANGUAGE
  ) in (select
      SUBT.OPINION_COMPONENT_ID,
      SUBT.LANGUAGE
    from AMW_OPINION_COMPONTS_TL SUBB, AMW_OPINION_COMPONTS_TL SUBT
    where SUBB.OPINION_COMPONENT_ID = SUBT.OPINION_COMPONENT_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.OPINION_COMPONENT_NAME <> SUBT.OPINION_COMPONENT_NAME
      or (SUBB.OPINION_COMPONENT_NAME is null and SUBT.OPINION_COMPONENT_NAME is not null)
      or (SUBB.OPINION_COMPONENT_NAME is not null and SUBT.OPINION_COMPONENT_NAME is null)
  ));

  insert into AMW_OPINION_COMPONTS_TL (
    OPINION_COMPONENT_ID,
    OPINION_COMPONENT_NAME,
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
    B.OPINION_COMPONENT_ID,
    B.OPINION_COMPONENT_NAME,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.SECURITY_GROUP_ID,
    B.OBJECT_VERSION_NUMBER,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from AMW_OPINION_COMPONTS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AMW_OPINION_COMPONTS_TL T
    where T.OPINION_COMPONENT_ID = B.OPINION_COMPONENT_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure LOAD_ROW(
	X_OPINION_COMPONENT_ID		in NUMBER,
	X_OPINION_COMPONENT_NAME	in VARCHAR2,
	X_OPINION_COMPONENT_CODE	in VARCHAR2,
	X_OBJECT_OPINION_TYPE_ID	in NUMBER,
	X_PAGE_ORDER			in NUMBER,
	X_LAST_UPDATE_DATE    		in VARCHAR2,
	X_OWNER				in VARCHAR2,
	X_CUSTOM_MODE			in VARCHAR2) is

f_luby	number;	-- entity owner in file
f_ludate	date;		-- entity update date in file
db_luby	number;	-- entity owner in db
db_ludate	date;		-- entity update date in db

begin
	-- Translate owner to file_last_updated_by
	f_luby := fnd_load_util.owner_id(X_OWNER);

	-- Translate char last_update_date to date
	f_ludate := nvl(to_date(X_LAST_UPDATE_DATE, 'YYYY/MM/DD'), sysdate);

	select last_updated_by, last_update_date into db_luby, db_ludate
	from AMW_OPINION_COMPONTS_B
	where opinion_component_id = X_OPINION_COMPONENT_ID;

	if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby, db_ludate, X_CUSTOM_MODE))
	then AMW_OPINION_COMPONTS_PKG.UPDATE_ROW(
		X_OPINION_COMPONENT_ID		=> X_OPINION_COMPONENT_ID,
		X_OPINION_COMPONENT_CODE	=> X_OPINION_COMPONENT_CODE,
		X_OBJECT_OPINION_TYPE_ID	=> X_OBJECT_OPINION_TYPE_ID,
		X_PAGE_ORDER			=> X_PAGE_ORDER,
		X_SECURITY_GROUP_ID		=> null,
		X_OBJECT_VERSION_NUMBER		=> 1,
		X_OPINION_COMPONENT_NAME	=> X_OPINION_COMPONENT_NAME,
		X_LAST_UPDATE_DATE		=> f_ludate,
		X_LAST_UPDATED_BY			=> f_luby,
		X_LAST_UPDATE_LOGIN		=> 0);
	end if;
	exception when NO_DATA_FOUND
	then AMW_OPINION_COMPONTS_PKG.INSERT_ROW(
		X_OPINION_COMPONENT_ID		=> X_OPINION_COMPONENT_ID,
		X_OPINION_COMPONENT_CODE	=> X_OPINION_COMPONENT_CODE,
		X_OBJECT_OPINION_TYPE_ID	=> X_OBJECT_OPINION_TYPE_ID,
		X_PAGE_ORDER			=> X_PAGE_ORDER,
		X_SECURITY_GROUP_ID		=> null,
		X_OBJECT_VERSION_NUMBER		=> 1,
		X_OPINION_COMPONENT_NAME	=> X_OPINION_COMPONENT_NAME,
		X_CREATION_DATE			=> f_ludate,
		X_CREATED_BY			=> f_luby,
		X_LAST_UPDATE_DATE		=> f_ludate,
		X_LAST_UPDATED_BY			=> f_luby,
		X_LAST_UPDATE_LOGIN		=> 0);
end LOAD_ROW;

procedure TRANSLATE_ROW(
	X_OPINION_COMPONENT_ID		in NUMBER,
	X_OPINION_COMPONENT_NAME	in VARCHAR2,
	X_LAST_UPDATE_DATE    		in VARCHAR2,
	X_OWNER				in VARCHAR2,
	X_CUSTOM_MODE			in VARCHAR2) is

f_luby	number;	-- entity owner in file
f_ludate	date;		-- entity update date in file
db_luby	number;	-- entity owner in db
db_ludate	date;		-- entity update date in db

begin
	-- Translate owner to file_last_updated_by
	f_luby := fnd_load_util.owner_id(X_OWNER);

	-- Translate char last_update_date to date
	f_ludate := nvl(to_date(X_LAST_UPDATE_DATE, 'YYYY/MM/DD'), sysdate);

	select last_updated_by, last_update_date into db_luby, db_ludate
	from AMW_OPINION_COMPONTS_TL
	where opinion_component_id = X_OPINION_COMPONENT_ID and language = userenv('LANG');

	if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby, db_ludate, X_CUSTOM_MODE))
	then update AMW_OPINION_COMPONTS_TL set
		opinion_component_name	= nvl(X_OPINION_COMPONENT_NAME, opinion_component_name),
		source_lang			= userenv('LANG'),
		last_update_date		= f_ludate,
		last_updated_by		= f_luby,
		last_update_login		= 0
	where	opinion_component_id = X_OPINION_COMPONENT_ID and userenv('LANG') in (language, source_lang);
	end if;
end TRANSLATE_ROW;

end AMW_OPINION_COMPONTS_PKG;

/