--------------------------------------------------------
--  DDL for Package Body XDP_ADAPTER_TYPE_ATTRS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XDP_ADAPTER_TYPE_ATTRS_PKG" as
/* $Header: XDPATYAB.pls 120.2 2005/07/14 05:20:54 appldev ship $ */

procedure INSERT_ROW (
  X_ROWID in OUT NOCOPY VARCHAR2,
  X_ADAPTER_TYPE_ATTRS_ID in NUMBER,
  X_ADAPTER_TYPE in VARCHAR2,
  X_ATTRIBUTE_NAME in VARCHAR2,
  X_DEFAULT_VALUE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from XDP_ADAPTER_TYPE_ATTRS_B
    where ADAPTER_TYPE_ATTRS_ID = X_ADAPTER_TYPE_ATTRS_ID
    ;
begin
  insert into XDP_ADAPTER_TYPE_ATTRS_B (
    ADAPTER_TYPE_ATTRS_ID,
    ADAPTER_TYPE,
    ATTRIBUTE_NAME,
    DEFAULT_VALUE,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_ADAPTER_TYPE_ATTRS_ID,
    X_ADAPTER_TYPE,
    X_ATTRIBUTE_NAME,
    X_DEFAULT_VALUE,
    X_OBJECT_VERSION_NUMBER,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into XDP_ADAPTER_TYPE_ATTRS_TL (
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    DESCRIPTION,
    CREATED_BY,
    ADAPTER_TYPE_ATTRS_ID,
    DISPLAY_NAME,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_OBJECT_VERSION_NUMBER,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    X_DESCRIPTION,
    X_CREATED_BY,
    X_ADAPTER_TYPE_ATTRS_ID,
    X_DISPLAY_NAME,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from XDP_ADAPTER_TYPE_ATTRS_TL T
    where T.ADAPTER_TYPE_ATTRS_ID = X_ADAPTER_TYPE_ATTRS_ID
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
  X_ADAPTER_TYPE_ATTRS_ID in NUMBER,
  X_ADAPTER_TYPE in VARCHAR2,
  X_ATTRIBUTE_NAME in VARCHAR2,
  X_DEFAULT_VALUE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      ADAPTER_TYPE,
      ATTRIBUTE_NAME,
      DEFAULT_VALUE,
      OBJECT_VERSION_NUMBER
    from XDP_ADAPTER_TYPE_ATTRS_B
    where ADAPTER_TYPE_ATTRS_ID = X_ADAPTER_TYPE_ATTRS_ID
    for update of ADAPTER_TYPE_ATTRS_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      DISPLAY_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from XDP_ADAPTER_TYPE_ATTRS_TL
    where ADAPTER_TYPE_ATTRS_ID = X_ADAPTER_TYPE_ATTRS_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of ADAPTER_TYPE_ATTRS_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.ADAPTER_TYPE = X_ADAPTER_TYPE)
      AND (recinfo.ATTRIBUTE_NAME = X_ATTRIBUTE_NAME)
      AND ((recinfo.DEFAULT_VALUE = X_DEFAULT_VALUE)
           OR ((recinfo.DEFAULT_VALUE is null) AND (X_DEFAULT_VALUE is null)))
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
      if (    (tlinfo.DISPLAY_NAME = X_DISPLAY_NAME)
          AND (tlinfo.DESCRIPTION = X_DESCRIPTION)
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
  X_ADAPTER_TYPE_ATTRS_ID in NUMBER,
  X_ADAPTER_TYPE in VARCHAR2,
  X_ATTRIBUTE_NAME in VARCHAR2,
  X_DEFAULT_VALUE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update XDP_ADAPTER_TYPE_ATTRS_B set
    ADAPTER_TYPE = X_ADAPTER_TYPE,
    ATTRIBUTE_NAME = X_ATTRIBUTE_NAME,
    DEFAULT_VALUE = X_DEFAULT_VALUE,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ADAPTER_TYPE_ATTRS_ID = X_ADAPTER_TYPE_ATTRS_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update XDP_ADAPTER_TYPE_ATTRS_TL set
    DISPLAY_NAME = X_DISPLAY_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where ADAPTER_TYPE_ATTRS_ID = X_ADAPTER_TYPE_ATTRS_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_ADAPTER_TYPE_ATTRS_ID in NUMBER
) is
begin
  delete from XDP_ADAPTER_TYPE_ATTRS_TL
  where ADAPTER_TYPE_ATTRS_ID = X_ADAPTER_TYPE_ATTRS_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from XDP_ADAPTER_TYPE_ATTRS_B
  where ADAPTER_TYPE_ATTRS_ID = X_ADAPTER_TYPE_ATTRS_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from XDP_ADAPTER_TYPE_ATTRS_TL T
  where not exists
    (select NULL
    from XDP_ADAPTER_TYPE_ATTRS_B B
    where B.ADAPTER_TYPE_ATTRS_ID = T.ADAPTER_TYPE_ATTRS_ID
    );

  update XDP_ADAPTER_TYPE_ATTRS_TL T set (
      DISPLAY_NAME,
      DESCRIPTION
    ) = (select
      B.DISPLAY_NAME,
      B.DESCRIPTION
    from XDP_ADAPTER_TYPE_ATTRS_TL B
    where B.ADAPTER_TYPE_ATTRS_ID = T.ADAPTER_TYPE_ATTRS_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.ADAPTER_TYPE_ATTRS_ID,
      T.LANGUAGE
  ) in (select
      SUBT.ADAPTER_TYPE_ATTRS_ID,
      SUBT.LANGUAGE
    from XDP_ADAPTER_TYPE_ATTRS_TL SUBB, XDP_ADAPTER_TYPE_ATTRS_TL SUBT
    where SUBB.ADAPTER_TYPE_ATTRS_ID = SUBT.ADAPTER_TYPE_ATTRS_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DISPLAY_NAME <> SUBT.DISPLAY_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
  ));

  insert into XDP_ADAPTER_TYPE_ATTRS_TL (
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    DESCRIPTION,
    CREATED_BY,
    ADAPTER_TYPE_ATTRS_ID,
    DISPLAY_NAME,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.OBJECT_VERSION_NUMBER,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.DESCRIPTION,
    B.CREATED_BY,
    B.ADAPTER_TYPE_ATTRS_ID,
    B.DISPLAY_NAME,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from XDP_ADAPTER_TYPE_ATTRS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from XDP_ADAPTER_TYPE_ATTRS_TL T
    where T.ADAPTER_TYPE_ATTRS_ID = B.ADAPTER_TYPE_ATTRS_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure LOAD_ROW (
        X_ADAPTER_TYPE_ATTRS_ID in NUMBER,
        X_ADAPTER_TYPE in VARCHAR2,
        X_ATTRIBUTE_NAME in VARCHAR2,
        X_DEFAULT_VALUE in VARCHAR2,
        X_DISPLAY_NAME in VARCHAR2,
        X_DESCRIPTION in VARCHAR2,
        X_OWNER in VARCHAR2) IS
begin

  declare
     user_id            number := 0;
     row_id             varchar2(64);

  begin

     /* The following derivation has been replaced with the FND API.		dputhiye 14-JUL-2005. R12 ATG "Seed Version by Date" Uptake */
     --if (X_OWNER = 'SEED') then
     --   user_id := 1;
     --end if;
     user_id := FND_LOAD_UTIL.OWNER_ID(X_OWNER);

     XDP_ADAPTER_TYPE_ATTRS_PKG.UPDATE_ROW (
        X_ADAPTER_TYPE_ATTRS_ID => X_ADAPTER_TYPE_ATTRS_ID,
        X_ADAPTER_TYPE => X_ADAPTER_TYPE,
        X_ATTRIBUTE_NAME => X_ATTRIBUTE_NAME,
        X_DEFAULT_VALUE => X_DEFAULT_VALUE,
        X_OBJECT_VERSION_NUMBER => null,
        X_DISPLAY_NAME => X_DISPLAY_NAME,
        X_DESCRIPTION => X_DESCRIPTION,
        X_LAST_UPDATE_DATE => sysdate,
        X_LAST_UPDATED_BY => user_id,
        X_LAST_UPDATE_LOGIN => 0);

    exception
       when NO_DATA_FOUND then
          XDP_ADAPTER_TYPE_ATTRS_PKG.INSERT_ROW (
                X_ROWID => row_id,
                X_ADAPTER_TYPE_ATTRS_ID => X_ADAPTER_TYPE_ATTRS_ID,
                X_ADAPTER_TYPE => X_ADAPTER_TYPE,
                X_ATTRIBUTE_NAME => X_ATTRIBUTE_NAME,
                X_DEFAULT_VALUE => X_DEFAULT_VALUE,
                X_OBJECT_VERSION_NUMBER => null,
                X_DISPLAY_NAME => X_DISPLAY_NAME,
                X_DESCRIPTION => X_DESCRIPTION,
                X_CREATION_DATE => sysdate,
                X_CREATED_BY => user_id,
                X_LAST_UPDATE_DATE => sysdate,
                X_LAST_UPDATED_BY => user_id,
                X_LAST_UPDATE_LOGIN => 0);
   end;
end LOAD_ROW;

procedure TRANSLATE_ROW (
        X_ADAPTER_TYPE_ATTRS_ID in NUMBER,
        X_DISPLAY_NAME in VARCHAR2,
        X_DESCRIPTION in VARCHAR2,
        X_OWNER in VARCHAR2
) IS

BEGIN
    -- only update rows that have not been altered by user

    UPDATE XDP_ADAPTER_TYPE_ATTRS_TL
    SET display_name = X_DISPLAY_NAME,
        description = X_DESCRIPTION,
        source_lang = userenv('LANG'),
        last_update_date = sysdate,
        --last_updated_by = decode(X_OWNER, 'SEED', 1, 0),		/*dputhiye 14-JUL-2005. DECODE replaced with FND API.*/
	last_updated_by = fnd_load_util.owner_id(X_OWNER),
        last_update_login = 0
    where adapter_type_attrs_id = X_ADAPTER_TYPE_ATTRS_ID
      and userenv('LANG') in (language, source_lang);

end TRANSLATE_ROW;

end XDP_ADAPTER_TYPE_ATTRS_PKG;

/
