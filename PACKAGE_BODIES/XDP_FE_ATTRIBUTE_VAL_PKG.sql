--------------------------------------------------------
--  DDL for Package Body XDP_FE_ATTRIBUTE_VAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XDP_FE_ATTRIBUTE_VAL_PKG" as
/* $Header: XDPFEAVB.pls 120.2 2005/07/14 22:49:31 appldev ship $ */
procedure INSERT_ROW (
  X_ROWID in OUT NOCOPY VARCHAR2,
  X_FE_ATTRIBUTE_ID in NUMBER,
  X_FE_GENERIC_CONFIG_ID in NUMBER,
  X_FE_ATTRIBUTE_VALUE in VARCHAR2,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from XDP_FE_ATTRIBUTE_VAL
    where FE_ATTRIBUTE_ID = X_FE_ATTRIBUTE_ID
    and FE_GENERIC_CONFIG_ID = X_FE_GENERIC_CONFIG_ID
    ;
begin
  insert into XDP_FE_ATTRIBUTE_VAL (
    FE_ATTRIBUTE_ID,
    FE_GENERIC_CONFIG_ID,
    FE_ATTRIBUTE_VALUE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_FE_ATTRIBUTE_ID,
    X_FE_GENERIC_CONFIG_ID,
    X_FE_ATTRIBUTE_VALUE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into XDP_FE_ATTRIBUTE_VAL_TL (
    FE_ATTRIBUTE_ID,
    FE_GENERIC_CONFIG_ID,
    DISPLAY_NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_FE_ATTRIBUTE_ID,
    X_FE_GENERIC_CONFIG_ID,
    X_DISPLAY_NAME,
    X_DESCRIPTION,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from XDP_FE_ATTRIBUTE_VAL_TL T
    where T.FE_ATTRIBUTE_ID = X_FE_ATTRIBUTE_ID
    and T.FE_GENERIC_CONFIG_ID = X_FE_GENERIC_CONFIG_ID
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
  X_FE_ATTRIBUTE_ID in NUMBER,
  X_FE_GENERIC_CONFIG_ID in NUMBER,
  X_FE_ATTRIBUTE_VALUE in VARCHAR2,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      FE_ATTRIBUTE_VALUE
    from XDP_FE_ATTRIBUTE_VAL
    where FE_ATTRIBUTE_ID = X_FE_ATTRIBUTE_ID
    and FE_GENERIC_CONFIG_ID = X_FE_GENERIC_CONFIG_ID
    for update of FE_ATTRIBUTE_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      DISPLAY_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from XDP_FE_ATTRIBUTE_VAL_TL
    where FE_ATTRIBUTE_ID = X_FE_ATTRIBUTE_ID
    and FE_GENERIC_CONFIG_ID = X_FE_GENERIC_CONFIG_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of FE_ATTRIBUTE_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.FE_ATTRIBUTE_VALUE = X_FE_ATTRIBUTE_VALUE)
           OR ((recinfo.FE_ATTRIBUTE_VALUE is null) AND (X_FE_ATTRIBUTE_VALUE is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.DISPLAY_NAME = X_DISPLAY_NAME)
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
  X_FE_ATTRIBUTE_ID in NUMBER,
  X_FE_GENERIC_CONFIG_ID in NUMBER,
  X_FE_ATTRIBUTE_VALUE in VARCHAR2,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update XDP_FE_ATTRIBUTE_VAL set
    FE_ATTRIBUTE_VALUE = X_FE_ATTRIBUTE_VALUE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where FE_ATTRIBUTE_ID = X_FE_ATTRIBUTE_ID
  and FE_GENERIC_CONFIG_ID = X_FE_GENERIC_CONFIG_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update XDP_FE_ATTRIBUTE_VAL_TL set
    DISPLAY_NAME = X_DISPLAY_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where FE_ATTRIBUTE_ID = X_FE_ATTRIBUTE_ID
  and FE_GENERIC_CONFIG_ID = X_FE_GENERIC_CONFIG_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_FE_ATTRIBUTE_ID in NUMBER,
  X_FE_GENERIC_CONFIG_ID in NUMBER
) is
begin
  delete from XDP_FE_ATTRIBUTE_VAL_TL
  where FE_ATTRIBUTE_ID = X_FE_ATTRIBUTE_ID
  and FE_GENERIC_CONFIG_ID = X_FE_GENERIC_CONFIG_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from XDP_FE_ATTRIBUTE_VAL
  where FE_ATTRIBUTE_ID = X_FE_ATTRIBUTE_ID
  and FE_GENERIC_CONFIG_ID = X_FE_GENERIC_CONFIG_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from XDP_FE_ATTRIBUTE_VAL_TL T
  where not exists
    (select NULL
    from XDP_FE_ATTRIBUTE_VAL B
    where B.FE_ATTRIBUTE_ID = T.FE_ATTRIBUTE_ID
    and B.FE_GENERIC_CONFIG_ID = T.FE_GENERIC_CONFIG_ID
    );

  update XDP_FE_ATTRIBUTE_VAL_TL T set (
      DISPLAY_NAME,
      DESCRIPTION
    ) = (select
      B.DISPLAY_NAME,
      B.DESCRIPTION
    from XDP_FE_ATTRIBUTE_VAL_TL B
    where B.FE_ATTRIBUTE_ID = T.FE_ATTRIBUTE_ID
    and B.FE_GENERIC_CONFIG_ID = T.FE_GENERIC_CONFIG_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.FE_ATTRIBUTE_ID,
      T.FE_GENERIC_CONFIG_ID,
      T.LANGUAGE
  ) in (select
      SUBT.FE_ATTRIBUTE_ID,
      SUBT.FE_GENERIC_CONFIG_ID,
      SUBT.LANGUAGE
    from XDP_FE_ATTRIBUTE_VAL_TL SUBB, XDP_FE_ATTRIBUTE_VAL_TL SUBT
    where SUBB.FE_ATTRIBUTE_ID = SUBT.FE_ATTRIBUTE_ID
    and SUBB.FE_GENERIC_CONFIG_ID = SUBT.FE_GENERIC_CONFIG_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DISPLAY_NAME <> SUBT.DISPLAY_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into XDP_FE_ATTRIBUTE_VAL_TL (
    FE_ATTRIBUTE_ID,
    FE_GENERIC_CONFIG_ID,
    DISPLAY_NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.FE_ATTRIBUTE_ID,
    B.FE_GENERIC_CONFIG_ID,
    B.DISPLAY_NAME,
    B.DESCRIPTION,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from XDP_FE_ATTRIBUTE_VAL_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from XDP_FE_ATTRIBUTE_VAL_TL T
    where T.FE_ATTRIBUTE_ID = B.FE_ATTRIBUTE_ID
    and T.FE_GENERIC_CONFIG_ID = B.FE_GENERIC_CONFIG_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure LOAD_ROW (
  X_FE_ATTRIBUTE_ID in NUMBER,
  X_FE_GENERIC_CONFIG_ID in NUMBER,
  X_FE_ATTRIBUTE_VALUE in VARCHAR2,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2) IS
begin

  declare
     user_id            number := 0;
     row_id             varchar2(64);

  begin

     /* The following derivation has been replaced with the FND API.		dputhiye 15-JUL-2005. R12 ATG "Seed Version by Date" Uptake */
     --if (X_OWNER = 'SEED') then
     --   user_id := 1;
     --end if;
     user_id := fnd_load_util.owner_id(X_OWNER);

     XDP_FE_ATTRIBUTE_VAL_PKG.UPDATE_ROW (
  	X_FE_ATTRIBUTE_ID => X_FE_ATTRIBUTE_ID,
  	X_FE_GENERIC_CONFIG_ID => X_FE_GENERIC_CONFIG_ID,
  	X_FE_ATTRIBUTE_VALUE => X_FE_ATTRIBUTE_VALUE,
  	X_DISPLAY_NAME => X_DISPLAY_NAME,
  	X_DESCRIPTION => X_DESCRIPTION,
        X_LAST_UPDATE_DATE => sysdate,
        X_LAST_UPDATED_BY => user_id,
        X_LAST_UPDATE_LOGIN => 0);

    exception
       when NO_DATA_FOUND then
          XDP_FE_ATTRIBUTE_VAL_PKG.INSERT_ROW (
             	X_ROWID => row_id,
  		X_FE_ATTRIBUTE_ID => X_FE_ATTRIBUTE_ID,
  		X_FE_GENERIC_CONFIG_ID => X_FE_GENERIC_CONFIG_ID,
  		X_FE_ATTRIBUTE_VALUE => X_FE_ATTRIBUTE_VALUE,
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
   X_FE_ATTRIBUTE_ID in NUMBER,
   X_FE_GENERIC_CONFIG_ID in NUMBER,
   X_DISPLAY_NAME in VARCHAR2,
   X_DESCRIPTION in VARCHAR2,
   X_OWNER in VARCHAR2) IS

begin

    -- only update rows that have not been altered by user

    update XDP_FE_ATTRIBUTE_VAL_TL
    set display_name = X_DISPLAY_NAME,
        description = X_DESCRIPTION,
        source_lang = userenv('LANG'),
        last_update_date = sysdate,
	--last_updated_by = decode(X_OWNER, 'SEED', 1, 0),
	last_updated_by = fnd_load_util.owner_id(X_OWNER),		/*dputhiye 15-JUL-2005. DECODE replaced with FND API.*/
        last_update_login = 0
  where fe_attribute_id = X_FE_ATTRIBUTE_ID
    and fe_generic_config_id = X_FE_GENERIC_CONFIG_ID
    and   userenv('LANG') in (language, source_lang);

end TRANSLATE_ROW;


end XDP_FE_ATTRIBUTE_VAL_PKG;

/
