--------------------------------------------------------
--  DDL for Package Body AMW_OPINION_VALUES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMW_OPINION_VALUES_PKG" as
/* $Header: amwtopvb.pls 115.10 2004/03/26 22:41:58 cpetriuc noship $ */

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_OPINION_VALUE_ID in NUMBER,
  X_OPINION_VALUE_CODE in VARCHAR2,
  X_OPINION_COMPONENT_ID in NUMBER,
  X_END_DATE in DATE,
  X_ATTACHMENT_ID in NUMBER,
  X_IMAGE_FILE_NAME in VARCHAR2,
  X_DISPLAY_ORDER in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_OPINION_VALUE_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from AMW_OPINION_VALUES_B
    where OPINION_VALUE_ID = X_OPINION_VALUE_ID
    ;
begin
  insert into AMW_OPINION_VALUES_B (
    OPINION_VALUE_ID,
    OPINION_VALUE_CODE,
    OPINION_COMPONENT_ID,
    END_DATE,
    ATTACHMENT_ID,
    IMAGE_FILE_NAME,
    DISPLAY_ORDER,
    SECURITY_GROUP_ID,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_OPINION_VALUE_ID,
    X_OPINION_VALUE_CODE,
    X_OPINION_COMPONENT_ID,
    X_END_DATE,
    X_ATTACHMENT_ID,
    X_IMAGE_FILE_NAME,
    X_DISPLAY_ORDER,
    X_SECURITY_GROUP_ID,
    X_OBJECT_VERSION_NUMBER,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into AMW_OPINION_VALUES_TL (
    OPINION_VALUE_ID,
    OPINION_VALUE_NAME,
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
    X_OPINION_VALUE_ID,
    X_OPINION_VALUE_NAME,
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
    from AMW_OPINION_VALUES_TL T
    where T.OPINION_VALUE_ID = X_OPINION_VALUE_ID
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
  X_OPINION_VALUE_ID in NUMBER,
  X_OPINION_VALUE_CODE in VARCHAR2,
  X_OPINION_COMPONENT_ID in NUMBER,
  X_END_DATE in DATE,
  X_ATTACHMENT_ID in NUMBER,
  X_IMAGE_FILE_NAME in VARCHAR2,
  X_DISPLAY_ORDER in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_OPINION_VALUE_NAME in VARCHAR2
) is
  cursor c is select
      OPINION_VALUE_CODE,
      OPINION_COMPONENT_ID,
      END_DATE,
      ATTACHMENT_ID,
      IMAGE_FILE_NAME,
	DISPLAY_ORDER,
      SECURITY_GROUP_ID,
      OBJECT_VERSION_NUMBER
    from AMW_OPINION_VALUES_B
    where OPINION_VALUE_ID = X_OPINION_VALUE_ID
    for update of OPINION_VALUE_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      OPINION_VALUE_NAME,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from AMW_OPINION_VALUES_TL
    where OPINION_VALUE_ID = X_OPINION_VALUE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of OPINION_VALUE_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.OPINION_VALUE_CODE = X_OPINION_VALUE_CODE)
      AND (recinfo.OPINION_COMPONENT_ID = X_OPINION_COMPONENT_ID)
      AND ((recinfo.END_DATE = X_END_DATE)
           OR ((recinfo.END_DATE is null) AND (X_END_DATE is null)))
      AND ((recinfo.ATTACHMENT_ID = X_ATTACHMENT_ID)
           OR ((recinfo.ATTACHMENT_ID is null) AND (X_ATTACHMENT_ID is null)))
      AND ((recinfo.IMAGE_FILE_NAME = X_IMAGE_FILE_NAME)
           OR ((recinfo.IMAGE_FILE_NAME is null) AND (X_IMAGE_FILE_NAME is null)))
      AND ((recinfo.DISPLAY_ORDER = X_DISPLAY_ORDER)
           OR ((recinfo.DISPLAY_ORDER is null) AND (X_DISPLAY_ORDER is null)))
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
      if (    ((tlinfo.OPINION_VALUE_NAME = X_OPINION_VALUE_NAME)
               OR ((tlinfo.OPINION_VALUE_NAME is null) AND (X_OPINION_VALUE_NAME is null)))
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
  X_OPINION_VALUE_ID in NUMBER,
  X_OPINION_VALUE_CODE in VARCHAR2,
  X_OPINION_COMPONENT_ID in NUMBER,
  X_END_DATE in DATE,
  X_ATTACHMENT_ID in NUMBER,
  X_IMAGE_FILE_NAME in VARCHAR2,
  X_DISPLAY_ORDER in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_OPINION_VALUE_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update AMW_OPINION_VALUES_B set
    OPINION_VALUE_CODE = X_OPINION_VALUE_CODE,
    OPINION_COMPONENT_ID = X_OPINION_COMPONENT_ID,
    END_DATE = X_END_DATE,
    ATTACHMENT_ID = X_ATTACHMENT_ID,
    IMAGE_FILE_NAME = X_IMAGE_FILE_NAME,
    DISPLAY_ORDER = X_DISPLAY_ORDER,
    SECURITY_GROUP_ID = X_SECURITY_GROUP_ID,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where OPINION_VALUE_ID = X_OPINION_VALUE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update AMW_OPINION_VALUES_TL set
    OPINION_VALUE_NAME = X_OPINION_VALUE_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where OPINION_VALUE_ID = X_OPINION_VALUE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_OPINION_VALUE_ID in NUMBER
) is
begin
  delete from AMW_OPINION_VALUES_TL
  where OPINION_VALUE_ID = X_OPINION_VALUE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from AMW_OPINION_VALUES_B
  where OPINION_VALUE_ID = X_OPINION_VALUE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from AMW_OPINION_VALUES_TL T
  where not exists
    (select NULL
    from AMW_OPINION_VALUES_B B
    where B.OPINION_VALUE_ID = T.OPINION_VALUE_ID
    );

  update AMW_OPINION_VALUES_TL T set (
      OPINION_VALUE_NAME
    ) = (select
      B.OPINION_VALUE_NAME
    from AMW_OPINION_VALUES_TL B
    where B.OPINION_VALUE_ID = T.OPINION_VALUE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.OPINION_VALUE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.OPINION_VALUE_ID,
      SUBT.LANGUAGE
    from AMW_OPINION_VALUES_TL SUBB, AMW_OPINION_VALUES_TL SUBT
    where SUBB.OPINION_VALUE_ID = SUBT.OPINION_VALUE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.OPINION_VALUE_NAME <> SUBT.OPINION_VALUE_NAME
      or (SUBB.OPINION_VALUE_NAME is null and SUBT.OPINION_VALUE_NAME is not null)
      or (SUBB.OPINION_VALUE_NAME is not null and SUBT.OPINION_VALUE_NAME is null)
  ));

  insert into AMW_OPINION_VALUES_TL (
    OPINION_VALUE_ID,
    OPINION_VALUE_NAME,
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
    B.OPINION_VALUE_ID,
    B.OPINION_VALUE_NAME,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.SECURITY_GROUP_ID,
    B.OBJECT_VERSION_NUMBER,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from AMW_OPINION_VALUES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AMW_OPINION_VALUES_TL T
    where T.OPINION_VALUE_ID = B.OPINION_VALUE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure LOAD_ROW(
	X_OPINION_VALUE_ID		in NUMBER,
	X_OPINION_VALUE_NAME		in VARCHAR2,
	X_OPINION_VALUE_CODE		in VARCHAR2,
	X_OPINION_COMPONENT_ID		in NUMBER,
	X_END_DATE				in VARCHAR2,
	X_ATTACHMENT_ID			in NUMBER,
	X_IMAGE_FILE_NAME			in VARCHAR2,
	X_DISPLAY_ORDER			in NUMBER,
	X_LAST_UPDATE_DATE    		in VARCHAR2,
	X_OWNER				in VARCHAR2,
	X_CUSTOM_MODE			in VARCHAR2) is

f_luby	number;	-- entity owner in file
f_ludate	date;		-- entity update date in file
db_luby	number;	-- entity owner in db
db_ludate	date;		-- entity update date in db

row_id	rowid;

begin
	-- Translate owner to file_last_updated_by
	f_luby := fnd_load_util.owner_id(X_OWNER);

	-- Translate char last_update_date to date
	f_ludate := nvl(to_date(X_LAST_UPDATE_DATE, 'YYYY/MM/DD'), sysdate);

	select last_updated_by, last_update_date into db_luby, db_ludate
	from AMW_OPINION_VALUES_B
	where opinion_value_id = X_OPINION_VALUE_ID;

	if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby, db_ludate, X_CUSTOM_MODE))
	then AMW_OPINION_VALUES_PKG.UPDATE_ROW(
		X_OPINION_VALUE_ID		=> X_OPINION_VALUE_ID,
		X_OPINION_VALUE_CODE		=> X_OPINION_VALUE_CODE,
		X_OPINION_COMPONENT_ID		=> X_OPINION_COMPONENT_ID,
		X_END_DATE				=> to_date(X_END_DATE, 'YYYY/MM/DD'),
		X_ATTACHMENT_ID			=> X_ATTACHMENT_ID,
		X_IMAGE_FILE_NAME			=> X_IMAGE_FILE_NAME,
		X_DISPLAY_ORDER			=> X_DISPLAY_ORDER,
		X_SECURITY_GROUP_ID		=> null,
		X_OBJECT_VERSION_NUMBER		=> 1,
		X_OPINION_VALUE_NAME		=> X_OPINION_VALUE_NAME,
		X_LAST_UPDATE_DATE		=> f_ludate,
		X_LAST_UPDATED_BY			=> f_luby,
		X_LAST_UPDATE_LOGIN		=> 0);
	end if;
	exception when NO_DATA_FOUND
	then AMW_OPINION_VALUES_PKG.INSERT_ROW(
		X_ROWID				=> row_id,
		X_OPINION_VALUE_ID		=> X_OPINION_VALUE_ID,
		X_OPINION_VALUE_CODE		=> X_OPINION_VALUE_CODE,
		X_OPINION_COMPONENT_ID		=> X_OPINION_COMPONENT_ID,
		X_END_DATE				=> to_date(X_END_DATE, 'YYYY/MM/DD'),
		X_ATTACHMENT_ID			=> X_ATTACHMENT_ID,
		X_IMAGE_FILE_NAME			=> X_IMAGE_FILE_NAME,
		X_DISPLAY_ORDER			=> X_DISPLAY_ORDER,
		X_SECURITY_GROUP_ID		=> null,
		X_OBJECT_VERSION_NUMBER		=> 1,
		X_OPINION_VALUE_NAME		=> X_OPINION_VALUE_NAME,
		X_CREATION_DATE			=> f_ludate,
		X_CREATED_BY			=> f_luby,
		X_LAST_UPDATE_DATE		=> f_ludate,
		X_LAST_UPDATED_BY			=> f_luby,
		X_LAST_UPDATE_LOGIN		=> 0);
end LOAD_ROW;

procedure TRANSLATE_ROW(
	X_OPINION_VALUE_ID	in NUMBER,
	X_OPINION_VALUE_NAME	in VARCHAR2,
	X_LAST_UPDATE_DATE    	in VARCHAR2,
	X_OWNER			in VARCHAR2,
	X_CUSTOM_MODE		in VARCHAR2) is

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
	from AMW_OPINION_VALUES_TL
	where opinion_value_id = X_OPINION_VALUE_ID and language = userenv('LANG');

	if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby, db_ludate, X_CUSTOM_MODE))
	then update AMW_OPINION_VALUES_TL set
		opinion_value_name	= nvl(X_OPINION_VALUE_NAME, opinion_value_name),
		source_lang			= userenv('LANG'),
		last_update_date		= f_ludate,
		last_updated_by		= f_luby,
		last_update_login		= 0
	where	opinion_value_id = X_OPINION_VALUE_ID and userenv('LANG') in (language, source_lang);
	end if;
end TRANSLATE_ROW;

end AMW_OPINION_VALUES_PKG;

/
