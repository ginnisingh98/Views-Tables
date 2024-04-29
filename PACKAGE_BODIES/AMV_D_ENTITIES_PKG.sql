--------------------------------------------------------
--  DDL for Package Body AMV_D_ENTITIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMV_D_ENTITIES_PKG" as
/* $Header: amvtentb.pls 120.1 2005/06/21 17:45:42 appldev ship $ */
procedure LOAD_ROW (
  X_ENTITY_ID in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in VARCHAR2,
  X_APPLICATION_ID in VARCHAR2,
  X_STATUS in VARCHAR2,
  X_TABLE_NAME in VARCHAR2,
  X_USAGE_INDICATOR in VARCHAR2,
  X_ENTITY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2 )
is
l_user_id           number := 0;
l_application_id    number := 0;
l_entity_id   number := 0;
l_object_version_number number := 0;
l_row_id            varchar2(64);
begin
     if (X_OWNER = 'SEED') then
		l_user_id := 1;
	end if;
	l_entity_id := to_number(x_entity_id);
	l_application_id := to_number(x_application_id);
	l_object_version_number := to_number(x_object_version_number);
	--
	AMV_D_ENTITIES_PKG.UPDATE_ROW(
		X_ENTITY_ID   => l_entity_id,
		X_OBJECT_VERSION_NUMBER => l_object_version_number,
		X_APPLICATION_ID => l_application_id,
		X_STATUS => x_status,
		X_TABLE_NAME => x_table_name,
		X_USAGE_INDICATOR => x_usage_indicator,
		X_ENTITY_NAME => x_entity_name,
		X_DESCRIPTION       => x_description,
		X_LAST_UPDATE_DATE  => sysdate,
		X_LAST_UPDATED_BY   => l_user_id,
		X_LAST_UPDATE_LOGIN => 0
		);

exception
	when NO_DATA_FOUND then
		AMV_D_ENTITIES_PKG.INSERT_ROW(
              	X_ROWID             => l_row_id,
			X_ENTITY_ID   => l_entity_id,
			X_OBJECT_VERSION_NUMBER => l_object_version_number,
			X_APPLICATION_ID => l_application_id,
			X_STATUS => x_status,
			X_TABLE_NAME => x_table_name,
			X_USAGE_INDICATOR => x_usage_indicator,
			X_ENTITY_NAME => x_entity_name,
			X_DESCRIPTION       => x_description,
			X_CREATION_DATE     => sysdate,
			X_CREATED_BY        => l_user_id,
			X_LAST_UPDATE_DATE  => sysdate,
			X_LAST_UPDATED_BY   => l_user_id,
			X_LAST_UPDATE_LOGIN => 0
			);
end LOAD_ROW;

procedure TRANSLATE_ROW (
  X_ENTITY_ID in NUMBER,
  X_ENTITY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2)
is
begin
	update AMV_D_ENTITIES_TL set
		ENTITY_NAME = x_entity_name,
		DESCRIPTION       = x_description,
		LAST_UPDATE_DATE  = sysdate,
		LAST_UPDATED_BY   = decode(x_owner, 'SEED', 1, 0),
		LAST_UPDATE_LOGIN = 0,
		SOURCE_LANG = userenv('LANG')
	where userenv('LANG') in (LANGUAGE, SOURCE_LANG)
	and ENTITY_ID = x_entity_id;
end TRANSLATE_ROW;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ENTITY_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_APPLICATION_ID in NUMBER,
  X_STATUS in VARCHAR2,
  X_TABLE_NAME in VARCHAR2,
  X_USAGE_INDICATOR in VARCHAR2,
  X_ENTITY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from AMV_D_ENTITIES_B
    where ENTITY_ID = X_ENTITY_ID
    ;
begin
  insert into AMV_D_ENTITIES_B (
    ENTITY_ID,
    OBJECT_VERSION_NUMBER,
    APPLICATION_ID,
    STATUS,
    TABLE_NAME,
    USAGE_INDICATOR,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_ENTITY_ID,
    X_OBJECT_VERSION_NUMBER,
    X_APPLICATION_ID,
    X_STATUS,
    X_TABLE_NAME,
    X_USAGE_INDICATOR,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into AMV_D_ENTITIES_TL (
    ENTITY_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    ENTITY_NAME,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_ENTITY_ID,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_ENTITY_NAME,
    X_DESCRIPTION,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from AMV_D_ENTITIES_TL T
    where T.ENTITY_ID = X_ENTITY_ID
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
  X_ENTITY_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_APPLICATION_ID in NUMBER,
  X_STATUS in VARCHAR2,
  X_TABLE_NAME in VARCHAR2,
  X_USAGE_INDICATOR in VARCHAR2,
  X_ENTITY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      OBJECT_VERSION_NUMBER,
      APPLICATION_ID,
      STATUS,
      TABLE_NAME,
      USAGE_INDICATOR
    from AMV_D_ENTITIES_B
    where ENTITY_ID = X_ENTITY_ID
    for update of ENTITY_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      ENTITY_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from AMV_D_ENTITIES_TL
    where ENTITY_ID = X_ENTITY_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of ENTITY_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
      AND (recinfo.APPLICATION_ID = X_APPLICATION_ID)
      AND (recinfo.STATUS = X_STATUS)
      AND (recinfo.TABLE_NAME = X_TABLE_NAME)
      AND (recinfo.USAGE_INDICATOR = X_USAGE_INDICATOR)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.ENTITY_NAME = X_ENTITY_NAME)
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
  X_ENTITY_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_APPLICATION_ID in NUMBER,
  X_STATUS in VARCHAR2,
  X_TABLE_NAME in VARCHAR2,
  X_USAGE_INDICATOR in VARCHAR2,
  X_ENTITY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update AMV_D_ENTITIES_B set
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    APPLICATION_ID = X_APPLICATION_ID,
    STATUS = X_STATUS,
    TABLE_NAME = X_TABLE_NAME,
    USAGE_INDICATOR = X_USAGE_INDICATOR,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ENTITY_ID = X_ENTITY_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update AMV_D_ENTITIES_TL set
    ENTITY_NAME = X_ENTITY_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where ENTITY_ID = X_ENTITY_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_ENTITY_ID in NUMBER
) is
begin
  delete from AMV_D_ENTITIES_TL
  where ENTITY_ID = X_ENTITY_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from AMV_D_ENTITIES_B
  where ENTITY_ID = X_ENTITY_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from AMV_D_ENTITIES_TL T
  where not exists
    (select NULL
    from AMV_D_ENTITIES_B B
    where B.ENTITY_ID = T.ENTITY_ID
    );

  update AMV_D_ENTITIES_TL T set (
      ENTITY_NAME,
      DESCRIPTION
    ) = (select
      B.ENTITY_NAME,
      B.DESCRIPTION
    from AMV_D_ENTITIES_TL B
    where B.ENTITY_ID = T.ENTITY_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.ENTITY_ID,
      T.LANGUAGE
  ) in (select
      SUBT.ENTITY_ID,
      SUBT.LANGUAGE
    from AMV_D_ENTITIES_TL SUBB, AMV_D_ENTITIES_TL SUBT
    where SUBB.ENTITY_ID = SUBT.ENTITY_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.ENTITY_NAME <> SUBT.ENTITY_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into AMV_D_ENTITIES_TL (
    ENTITY_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    ENTITY_NAME,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.ENTITY_ID,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.ENTITY_NAME,
    B.DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from AMV_D_ENTITIES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AMV_D_ENTITIES_TL T
    where T.ENTITY_ID = B.ENTITY_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end AMV_D_ENTITIES_PKG;

/
