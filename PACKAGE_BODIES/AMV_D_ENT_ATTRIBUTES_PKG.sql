--------------------------------------------------------
--  DDL for Package Body AMV_D_ENT_ATTRIBUTES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMV_D_ENT_ATTRIBUTES_PKG" as
/* $Header: amvtattb.pls 120.1 2005/06/21 17:47:22 appldev ship $ */
procedure LOAD_ROW (
  X_ATTRIBUTE_ID in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in VARCHAR2,
  X_ENTITY_ID in VARCHAR2,
  X_DATA_TYPE in VARCHAR2,
  X_STATUS in VARCHAR2,
  X_COLUMN_NAME in VARCHAR2,
  X_USAGE_INDICATOR in VARCHAR2,
  X_VALIDATION_TYPE in VARCHAR2,
  X_RANGE_LOW_VALUE in VARCHAR2,
  X_RANGE_HIGH_VALUE in VARCHAR2,
  X_FUNCTION_CALL in VARCHAR2,
  X_ATTRIBUTE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2)
is
l_user_id           number := 0;
l_attribute_id    number := 0;
l_entity_id   number := 0;
l_object_version_number number := 0;
l_row_id            varchar2(64);
begin
     if (X_OWNER = 'SEED') then
		l_user_id := 1;
	end if;
	l_attribute_id := to_number(x_attribute_id);
	l_object_version_number := to_number(x_object_version_number);
	l_entity_id := to_number(x_entity_id);
	--
     AMV_D_ENT_ATTRIBUTES_PKG.UPDATE_ROW (
		X_ATTRIBUTE_ID   => l_attribute_id,
		X_OBJECT_VERSION_NUMBER => l_object_version_number,
		X_ENTITY_ID => l_entity_id,
		X_DATA_TYPE => x_data_type,
		X_STATUS => x_status,
		X_COLUMN_NAME => x_column_name,
		X_USAGE_INDICATOR => x_usage_indicator,
		X_VALIDATION_TYPE => x_validation_type,
		X_RANGE_HIGH_VALUE => x_range_high_value,
		X_RANGE_LOW_VALUE => x_range_low_value,
		X_FUNCTION_CALL => x_function_call,
		X_ATTRIBUTE_NAME => x_attribute_name,
		X_DESCRIPTION       => x_description,
		X_LAST_UPDATE_DATE  => sysdate,
		X_LAST_UPDATED_BY   => l_user_id,
		X_LAST_UPDATE_LOGIN => 0
		);
exception
	when NO_DATA_FOUND then
     AMV_D_ENT_ATTRIBUTES_PKG.INSERT_ROW (
		X_ROWID          => l_row_id,
		X_ATTRIBUTE_ID   => l_attribute_id,
		X_OBJECT_VERSION_NUMBER => l_object_version_number,
		X_ENTITY_ID => l_entity_id,
		X_DATA_TYPE => x_data_type,
		X_STATUS => x_status,
		X_COLUMN_NAME => x_column_name,
		X_USAGE_INDICATOR => x_usage_indicator,
		X_VALIDATION_TYPE => x_validation_type,
		X_RANGE_HIGH_VALUE => x_range_high_value,
		X_RANGE_LOW_VALUE => x_range_low_value,
		X_FUNCTION_CALL => x_function_call,
		X_ATTRIBUTE_NAME => x_attribute_name,
		X_DESCRIPTION       => x_description,
          X_CREATION_DATE     => sysdate,
		X_CREATED_BY        => l_user_id,
		X_LAST_UPDATE_DATE  => sysdate,
		X_LAST_UPDATED_BY   => l_user_id,
		X_LAST_UPDATE_LOGIN => 0
		);
end LOAD_ROW;

procedure TRANSLATE_ROW (
  X_ATTRIBUTE_ID in NUMBER,
  X_ATTRIBUTE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2)
is
begin
	update AMV_D_ENT_ATTRIBUTES_TL set
		ATTRIBUTE_NAME = x_attribute_name,
		DESCRIPTION       = x_description,
		LAST_UPDATE_DATE  = sysdate,
		LAST_UPDATED_BY   = decode(x_owner, 'SEED', 1, 0),
		LAST_UPDATE_LOGIN = 0,
		SOURCE_LANG = userenv('LANG')
	where userenv('LANG') in (LANGUAGE, SOURCE_LANG)
	and ATTRIBUTE_ID = x_attribute_id;
end TRANSLATE_ROW;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ATTRIBUTE_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ENTITY_ID in NUMBER,
  X_DATA_TYPE in VARCHAR2,
  X_STATUS in VARCHAR2,
  X_COLUMN_NAME in VARCHAR2,
  X_USAGE_INDICATOR in VARCHAR2,
  X_VALIDATION_TYPE in VARCHAR2,
  X_RANGE_LOW_VALUE in VARCHAR2,
  X_RANGE_HIGH_VALUE in VARCHAR2,
  X_FUNCTION_CALL in VARCHAR2,
  X_ATTRIBUTE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from AMV_D_ENT_ATTRIBUTES_B
    where ATTRIBUTE_ID = X_ATTRIBUTE_ID
    ;
begin
  insert into AMV_D_ENT_ATTRIBUTES_B (
    ATTRIBUTE_ID,
    OBJECT_VERSION_NUMBER,
    ENTITY_ID,
    DATA_TYPE,
    STATUS,
    COLUMN_NAME,
    USAGE_INDICATOR,
    VALIDATION_TYPE,
    RANGE_LOW_VALUE,
    RANGE_HIGH_VALUE,
    FUNCTION_CALL,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_ATTRIBUTE_ID,
    X_OBJECT_VERSION_NUMBER,
    X_ENTITY_ID,
    X_DATA_TYPE,
    X_STATUS,
    X_COLUMN_NAME,
    X_USAGE_INDICATOR,
    X_VALIDATION_TYPE,
    X_RANGE_LOW_VALUE,
    X_RANGE_HIGH_VALUE,
    X_FUNCTION_CALL,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into AMV_D_ENT_ATTRIBUTES_TL (
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    ATTRIBUTE_NAME,
    DESCRIPTION,
    ATTRIBUTE_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_ATTRIBUTE_NAME,
    X_DESCRIPTION,
    X_ATTRIBUTE_ID,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from AMV_D_ENT_ATTRIBUTES_TL T
    where T.ATTRIBUTE_ID = X_ATTRIBUTE_ID
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
  X_ATTRIBUTE_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ENTITY_ID in NUMBER,
  X_DATA_TYPE in VARCHAR2,
  X_STATUS in VARCHAR2,
  X_COLUMN_NAME in VARCHAR2,
  X_USAGE_INDICATOR in VARCHAR2,
  X_VALIDATION_TYPE in VARCHAR2,
  X_RANGE_LOW_VALUE in VARCHAR2,
  X_RANGE_HIGH_VALUE in VARCHAR2,
  X_FUNCTION_CALL in VARCHAR2,
  X_ATTRIBUTE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      OBJECT_VERSION_NUMBER,
      ENTITY_ID,
      DATA_TYPE,
      STATUS,
      COLUMN_NAME,
      USAGE_INDICATOR,
      VALIDATION_TYPE,
      RANGE_LOW_VALUE,
      RANGE_HIGH_VALUE,
      FUNCTION_CALL
    from AMV_D_ENT_ATTRIBUTES_B
    where ATTRIBUTE_ID = X_ATTRIBUTE_ID
    for update of ATTRIBUTE_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      ATTRIBUTE_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from AMV_D_ENT_ATTRIBUTES_TL
    where ATTRIBUTE_ID = X_ATTRIBUTE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of ATTRIBUTE_ID nowait;
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
      AND (recinfo.ENTITY_ID = X_ENTITY_ID)
      AND (recinfo.DATA_TYPE = X_DATA_TYPE)
      AND (recinfo.STATUS = X_STATUS)
      AND (recinfo.COLUMN_NAME = X_COLUMN_NAME)
      AND (recinfo.USAGE_INDICATOR = X_USAGE_INDICATOR)
      AND ((recinfo.VALIDATION_TYPE = X_VALIDATION_TYPE)
           OR ((recinfo.VALIDATION_TYPE is null) AND (X_VALIDATION_TYPE is null)))
      AND ((recinfo.RANGE_LOW_VALUE = X_RANGE_LOW_VALUE)
           OR ((recinfo.RANGE_LOW_VALUE is null) AND (X_RANGE_LOW_VALUE is null)))
      AND ((recinfo.RANGE_HIGH_VALUE = X_RANGE_HIGH_VALUE)
           OR ((recinfo.RANGE_HIGH_VALUE is null) AND (X_RANGE_HIGH_VALUE is null)))
      AND ((recinfo.FUNCTION_CALL = X_FUNCTION_CALL)
           OR ((recinfo.FUNCTION_CALL is null) AND (X_FUNCTION_CALL is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.ATTRIBUTE_NAME = X_ATTRIBUTE_NAME)
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
  X_ATTRIBUTE_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ENTITY_ID in NUMBER,
  X_DATA_TYPE in VARCHAR2,
  X_STATUS in VARCHAR2,
  X_COLUMN_NAME in VARCHAR2,
  X_USAGE_INDICATOR in VARCHAR2,
  X_VALIDATION_TYPE in VARCHAR2,
  X_RANGE_LOW_VALUE in VARCHAR2,
  X_RANGE_HIGH_VALUE in VARCHAR2,
  X_FUNCTION_CALL in VARCHAR2,
  X_ATTRIBUTE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update AMV_D_ENT_ATTRIBUTES_B set
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    ENTITY_ID = X_ENTITY_ID,
    DATA_TYPE = X_DATA_TYPE,
    STATUS = X_STATUS,
    COLUMN_NAME = X_COLUMN_NAME,
    USAGE_INDICATOR = X_USAGE_INDICATOR,
    VALIDATION_TYPE = X_VALIDATION_TYPE,
    RANGE_LOW_VALUE = X_RANGE_LOW_VALUE,
    RANGE_HIGH_VALUE = X_RANGE_HIGH_VALUE,
    FUNCTION_CALL = X_FUNCTION_CALL,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ATTRIBUTE_ID = X_ATTRIBUTE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update AMV_D_ENT_ATTRIBUTES_TL set
    ATTRIBUTE_NAME = X_ATTRIBUTE_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where ATTRIBUTE_ID = X_ATTRIBUTE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_ATTRIBUTE_ID in NUMBER
) is
begin
  delete from AMV_D_ENT_ATTRIBUTES_TL
  where ATTRIBUTE_ID = X_ATTRIBUTE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from AMV_D_ENT_ATTRIBUTES_B
  where ATTRIBUTE_ID = X_ATTRIBUTE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from AMV_D_ENT_ATTRIBUTES_TL T
  where not exists
    (select NULL
    from AMV_D_ENT_ATTRIBUTES_B B
    where B.ATTRIBUTE_ID = T.ATTRIBUTE_ID
    );

  update AMV_D_ENT_ATTRIBUTES_TL T set (
      ATTRIBUTE_NAME,
      DESCRIPTION
    ) = (select
      B.ATTRIBUTE_NAME,
      B.DESCRIPTION
    from AMV_D_ENT_ATTRIBUTES_TL B
    where B.ATTRIBUTE_ID = T.ATTRIBUTE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.ATTRIBUTE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.ATTRIBUTE_ID,
      SUBT.LANGUAGE
    from AMV_D_ENT_ATTRIBUTES_TL SUBB, AMV_D_ENT_ATTRIBUTES_TL SUBT
    where SUBB.ATTRIBUTE_ID = SUBT.ATTRIBUTE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.ATTRIBUTE_NAME <> SUBT.ATTRIBUTE_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into AMV_D_ENT_ATTRIBUTES_TL (
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    ATTRIBUTE_NAME,
    DESCRIPTION,
    ATTRIBUTE_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.ATTRIBUTE_NAME,
    B.DESCRIPTION,
    B.ATTRIBUTE_ID,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from AMV_D_ENT_ATTRIBUTES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AMV_D_ENT_ATTRIBUTES_TL T
    where T.ATTRIBUTE_ID = B.ATTRIBUTE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end AMV_D_ENT_ATTRIBUTES_PKG;

/
