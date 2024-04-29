--------------------------------------------------------
--  DDL for Package Body PRP_TOKEN_VALUES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PRP_TOKEN_VALUES_PKG" as
/* $Header: PRPTTKVB.pls 115.2 2002/12/04 23:55:27 vpalaiya noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_TOKEN_VALUE_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_TOKEN_ID in NUMBER,
  X_TOKEN_VALUE in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from PRP_TOKEN_VALUES_TL
    where TOKEN_VALUE_ID = X_TOKEN_VALUE_ID
    and LANGUAGE = userenv('LANG')
    ;
begin
  insert into PRP_TOKEN_VALUES_TL (
    TOKEN_VALUE_ID,
    OBJECT_VERSION_NUMBER,
    TOKEN_ID,
    TOKEN_VALUE,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_TOKEN_VALUE_ID,
    X_OBJECT_VERSION_NUMBER,
    X_TOKEN_ID,
    X_TOKEN_VALUE,
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
    from PRP_TOKEN_VALUES_TL T
    where T.TOKEN_VALUE_ID = X_TOKEN_VALUE_ID
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
  X_TOKEN_VALUE_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_TOKEN_ID in NUMBER,
  X_TOKEN_VALUE in VARCHAR2
) is
  cursor c1 is select
      OBJECT_VERSION_NUMBER,
      TOKEN_ID,
      TOKEN_VALUE,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from PRP_TOKEN_VALUES_TL
    where TOKEN_VALUE_ID = X_TOKEN_VALUE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of TOKEN_VALUE_ID nowait;
begin
  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.TOKEN_VALUE = X_TOKEN_VALUE)
          AND (tlinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
          AND (tlinfo.TOKEN_ID = X_TOKEN_ID)
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
  X_TOKEN_VALUE_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_TOKEN_ID in NUMBER,
  X_TOKEN_VALUE in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update PRP_TOKEN_VALUES_TL set
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    TOKEN_ID = X_TOKEN_ID,
    TOKEN_VALUE = X_TOKEN_VALUE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where TOKEN_VALUE_ID = X_TOKEN_VALUE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_TOKEN_VALUE_ID in NUMBER
) is
begin
  delete from PRP_TOKEN_VALUES_TL
  where TOKEN_VALUE_ID = X_TOKEN_VALUE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  update PRP_TOKEN_VALUES_TL T set (
      TOKEN_VALUE
    ) = (select
      B.TOKEN_VALUE
    from PRP_TOKEN_VALUES_TL B
    where B.TOKEN_VALUE_ID = T.TOKEN_VALUE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.TOKEN_VALUE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.TOKEN_VALUE_ID,
      SUBT.LANGUAGE
    from PRP_TOKEN_VALUES_TL SUBB, PRP_TOKEN_VALUES_TL SUBT
    where SUBB.TOKEN_VALUE_ID = SUBT.TOKEN_VALUE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.TOKEN_VALUE <> SUBT.TOKEN_VALUE
  ));

  insert into PRP_TOKEN_VALUES_TL (
    TOKEN_VALUE_ID,
    OBJECT_VERSION_NUMBER,
    TOKEN_ID,
    TOKEN_VALUE,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.TOKEN_VALUE_ID,
    B.OBJECT_VERSION_NUMBER,
    B.TOKEN_ID,
    B.TOKEN_VALUE,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from PRP_TOKEN_VALUES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from PRP_TOKEN_VALUES_TL T
    where T.TOKEN_VALUE_ID = B.TOKEN_VALUE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end PRP_TOKEN_VALUES_PKG;

/
