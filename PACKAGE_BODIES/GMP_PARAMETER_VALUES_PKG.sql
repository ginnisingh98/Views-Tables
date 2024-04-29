--------------------------------------------------------
--  DDL for Package Body GMP_PARAMETER_VALUES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMP_PARAMETER_VALUES_PKG" as
/* $Header: GMPPVALB.pls 115.2 2002/10/25 20:16:48 sgidugu noship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PARAMETER_ID in NUMBER,
  X_PARAMETER_VALUE in VARCHAR2,
  X_PARAMETER_VALUE_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from GMP_PARAMETER_VALUES_B
    where PARAMETER_ID = X_PARAMETER_ID
    ;
begin
  insert into GMP_PARAMETER_VALUES_B (
    PARAMETER_ID,
    PARAMETER_VALUE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_PARAMETER_ID,
    X_PARAMETER_VALUE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into GMP_PARAMETER_VALUES_TL (
    LAST_UPDATE_LOGIN,
    PARAMETER_ID,
    PARAMETER_VALUE,
    PARAMETER_VALUE_DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_LAST_UPDATE_LOGIN,
    X_PARAMETER_ID,
    X_PARAMETER_VALUE,
    X_PARAMETER_VALUE_DESCRIPTION,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from GMP_PARAMETER_VALUES_TL T
    where T.PARAMETER_ID = X_PARAMETER_ID
    and   T.PARAMETER_VALUE = X_PARAMETER_VALUE
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
  X_PARAMETER_ID in NUMBER,
  X_PARAMETER_VALUE in VARCHAR2,
  X_PARAMETER_VALUE_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      PARAMETER_VALUE
    from GMP_PARAMETER_VALUES_B
    where PARAMETER_ID = X_PARAMETER_ID
    and   PARAMETER_VALUE =  X_PARAMETER_VALUE
    for update of PARAMETER_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      PARAMETER_VALUE_DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from GMP_PARAMETER_VALUES_TL
    where PARAMETER_ID = X_PARAMETER_ID
    and   PARAMETER_VALUE =  X_PARAMETER_VALUE
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of PARAMETER_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.PARAMETER_VALUE = X_PARAMETER_VALUE)
           OR ((recinfo.PARAMETER_VALUE is null) AND (X_PARAMETER_VALUE is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.PARAMETER_VALUE_DESCRIPTION = X_PARAMETER_VALUE_DESCRIPTION)
               OR ((tlinfo.PARAMETER_VALUE_DESCRIPTION is null) AND (X_PARAMETER_VALUE_DESCRIPTION is null)))
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
  X_PARAMETER_ID in NUMBER,
  X_PARAMETER_VALUE in VARCHAR2,
  X_PARAMETER_VALUE_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update GMP_PARAMETER_VALUES_B set
    PARAMETER_VALUE = X_PARAMETER_VALUE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where PARAMETER_ID = X_PARAMETER_ID
    and PARAMETER_VALUE =  X_PARAMETER_VALUE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update GMP_PARAMETER_VALUES_TL set
    PARAMETER_VALUE_DESCRIPTION = X_PARAMETER_VALUE_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where PARAMETER_ID = X_PARAMETER_ID
    and   PARAMETER_VALUE =  X_PARAMETER_VALUE
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_PARAMETER_ID in NUMBER,
  X_PARAMETER_VALUE in VARCHAR2
) is
begin
  delete from GMP_PARAMETER_VALUES_TL
  where PARAMETER_ID = X_PARAMETER_ID
  and   PARAMETER_VALUE = X_PARAMETER_VALUE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from GMP_PARAMETER_VALUES_B
  where PARAMETER_ID = X_PARAMETER_ID
  and   PARAMETER_VALUE = X_PARAMETER_VALUE;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from GMP_PARAMETER_VALUES_TL T
  where not exists
    (select NULL
    from GMP_PARAMETER_VALUES_B B
    where B.PARAMETER_ID = T.PARAMETER_ID
    and   B.PARAMETER_VALUE = T.PARAMETER_VALUE
    );

  update GMP_PARAMETER_VALUES_TL T set (
      PARAMETER_VALUE_DESCRIPTION
    ) = (select
      B.PARAMETER_VALUE_DESCRIPTION
    from GMP_PARAMETER_VALUES_TL B
    where B.PARAMETER_ID = T.PARAMETER_ID
    and   B.PARAMETER_VALUE = T.PARAMETER_VALUE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.PARAMETER_ID,
      T.LANGUAGE
  ) in (select
      SUBT.PARAMETER_ID,
      SUBT.LANGUAGE
    from GMP_PARAMETER_VALUES_TL SUBB, GMP_PARAMETER_VALUES_TL SUBT
    where SUBB.PARAMETER_ID = SUBT.PARAMETER_ID
    and   SUBB.PARAMETER_VALUE = SUBT.PARAMETER_VALUE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.PARAMETER_VALUE_DESCRIPTION <> SUBT.PARAMETER_VALUE_DESCRIPTION
      or (SUBB.PARAMETER_VALUE_DESCRIPTION is null and SUBT.PARAMETER_VALUE_DESCRIPTION is not null)
      or (SUBB.PARAMETER_VALUE_DESCRIPTION is not null and SUBT.PARAMETER_VALUE_DESCRIPTION is null)
  ));

  insert into GMP_PARAMETER_VALUES_TL (
    LAST_UPDATE_LOGIN,
    PARAMETER_ID,
    PARAMETER_VALUE,
    PARAMETER_VALUE_DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.LAST_UPDATE_LOGIN,
    B.PARAMETER_ID,
    B.PARAMETER_VALUE,
    B.PARAMETER_VALUE_DESCRIPTION,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from GMP_PARAMETER_VALUES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from GMP_PARAMETER_VALUES_TL T
    where T.PARAMETER_ID = B.PARAMETER_ID
    and   T.PARAMETER_VALUE = B.PARAMETER_VALUE
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end GMP_PARAMETER_VALUES_PKG;

/
