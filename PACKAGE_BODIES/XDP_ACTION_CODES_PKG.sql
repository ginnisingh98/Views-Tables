--------------------------------------------------------
--  DDL for Package Body XDP_ACTION_CODES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XDP_ACTION_CODES_PKG" as
/* $Header: XDPACTNB.pls 120.1 2005/06/08 23:36:10 appldev  $ */

procedure INSERT_ROW (
  X_ROWID in OUT NOCOPY VARCHAR2,
  X_ACTION_CODE_ID in NUMBER,
  X_ACTION_CODE in VARCHAR2,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from XDP_ACTION_CODES
    where ACTION_CODE_ID = X_ACTION_CODE_ID
    ;
begin
  insert into XDP_ACTION_CODES (
    ACTION_CODE_ID,
    ACTION_CODE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_ACTION_CODE_ID,
    X_ACTION_CODE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into XDP_ACTION_CODES_TL (
    ACTION_CODE_ID,
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
    X_ACTION_CODE_ID,
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
    from XDP_ACTION_CODES_TL T
    where T.ACTION_CODE_ID = X_ACTION_CODE_ID
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
  X_ACTION_CODE_ID in NUMBER,
  X_ACTION_CODE in VARCHAR2,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      ACTION_CODE
    from XDP_ACTION_CODES
    where ACTION_CODE_ID = X_ACTION_CODE_ID
    for update of ACTION_CODE_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      DISPLAY_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from XDP_ACTION_CODES_TL
    where ACTION_CODE_ID = X_ACTION_CODE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of ACTION_CODE_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.ACTION_CODE = X_ACTION_CODE)
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
  X_ACTION_CODE_ID in NUMBER,
  X_ACTION_CODE in VARCHAR2,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update XDP_ACTION_CODES set
    ACTION_CODE = X_ACTION_CODE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ACTION_CODE_ID = X_ACTION_CODE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update XDP_ACTION_CODES_TL set
    DISPLAY_NAME = X_DISPLAY_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where ACTION_CODE_ID = X_ACTION_CODE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_ACTION_CODE_ID in NUMBER
) is
begin
  delete from XDP_ACTION_CODES_TL
  where ACTION_CODE_ID = X_ACTION_CODE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from XDP_ACTION_CODES
  where ACTION_CODE_ID = X_ACTION_CODE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from XDP_ACTION_CODES_TL T
  where not exists
    (select NULL
    from XDP_ACTION_CODES B
    where B.ACTION_CODE_ID = T.ACTION_CODE_ID
    );

  update XDP_ACTION_CODES_TL T set (
      DISPLAY_NAME,
      DESCRIPTION
    ) = (select
      B.DISPLAY_NAME,
      B.DESCRIPTION
    from XDP_ACTION_CODES_TL B
    where B.ACTION_CODE_ID = T.ACTION_CODE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.ACTION_CODE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.ACTION_CODE_ID,
      SUBT.LANGUAGE
    from XDP_ACTION_CODES_TL SUBB, XDP_ACTION_CODES_TL SUBT
    where SUBB.ACTION_CODE_ID = SUBT.ACTION_CODE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DISPLAY_NAME <> SUBT.DISPLAY_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into XDP_ACTION_CODES_TL (
    ACTION_CODE_ID,
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
    B.ACTION_CODE_ID,
    B.DISPLAY_NAME,
    B.DESCRIPTION,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from XDP_ACTION_CODES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from XDP_ACTION_CODES_TL T
    where T.ACTION_CODE_ID = B.ACTION_CODE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;


procedure LOAD_ROW (
  X_ACTION_CODE_ID in NUMBER,
  X_ACTION_CODE in VARCHAR2,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2) IS
begin

  declare
     user_id            number := 0;
     row_id             varchar2(64);

  begin

     if (X_OWNER = 'SEED') then
        user_id := 1;
     end if;

     XDP_ACTION_CODES_PKG.UPDATE_ROW (
        X_ACTION_CODE_ID => X_ACTION_CODE_ID,
        X_ACTION_CODE => X_ACTION_CODE,
        X_DISPLAY_NAME => X_DISPLAY_NAME,
        X_DESCRIPTION => X_DESCRIPTION,
        X_LAST_UPDATE_DATE => sysdate,
        X_LAST_UPDATED_BY => user_id,
        X_LAST_UPDATE_LOGIN => 0);

    exception
       when NO_DATA_FOUND then
          XDP_ACTION_CODES_PKG.INSERT_ROW (
             X_ROWID => row_id,
             X_ACTION_CODE_ID => X_ACTION_CODE_ID,
             X_ACTION_CODE => X_ACTION_CODE,
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
   X_ACTION_CODE_ID in NUMBER,
   X_DISPLAY_NAME in VARCHAR2,
   X_DESCRIPTION in VARCHAR2,
   X_OWNER in VARCHAR2) IS

begin

    -- only update rows that have not been altered by user

    update XDP_ACTION_CODES_TL
    set display_name = X_DISPLAY_NAME,
        description = X_DESCRIPTION,
        source_lang = userenv('LANG'),
        last_update_date = sysdate,
        last_updated_by = decode(X_OWNER, 'SEED', 1, 0),
        last_update_login = 0
    where action_code_id = X_ACTION_CODE_ID
    and   userenv('LANG') in (language, source_lang);

end TRANSLATE_ROW;


end XDP_ACTION_CODES_PKG;

/
