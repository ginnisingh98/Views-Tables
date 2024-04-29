--------------------------------------------------------
--  DDL for Package Body GMP_PROCESS_PARAMETER_SET_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMP_PROCESS_PARAMETER_SET_PKG" as
/* $Header: GMPPRSEB.pls 115.2 2002/10/25 20:14:34 sgidugu noship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PARAMETER_SET_ID in NUMBER,
  X_PARAMETER_SET in VARCHAR2,
  X_SET_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from GMP_PROCESS_PARAMETER_SET_B
    where PARAMETER_SET_ID = X_PARAMETER_SET_ID
    ;
begin
  insert into GMP_PROCESS_PARAMETER_SET_B (
    PARAMETER_SET_ID,
    PARAMETER_SET,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_PARAMETER_SET_ID,
    X_PARAMETER_SET,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into GMP_PROCESS_PARAMETER_SET_TL (
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    PARAMETER_SET_ID,
    SET_DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_PARAMETER_SET_ID,
    X_SET_DESCRIPTION,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from GMP_PROCESS_PARAMETER_SET_TL T
    where T.PARAMETER_SET_ID = X_PARAMETER_SET_ID
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
  X_PARAMETER_SET_ID in NUMBER,
  X_PARAMETER_SET in VARCHAR2,
  X_SET_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      PARAMETER_SET
    from GMP_PROCESS_PARAMETER_SET_B
    where PARAMETER_SET_ID = X_PARAMETER_SET_ID
    for update of PARAMETER_SET_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      SET_DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from GMP_PROCESS_PARAMETER_SET_TL
    where PARAMETER_SET_ID = X_PARAMETER_SET_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of PARAMETER_SET_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.PARAMETER_SET = X_PARAMETER_SET)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.SET_DESCRIPTION = X_SET_DESCRIPTION)
               OR ((tlinfo.SET_DESCRIPTION is null) AND (X_SET_DESCRIPTION is null)))
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
  X_PARAMETER_SET_ID in NUMBER,
  X_PARAMETER_SET in VARCHAR2,
  X_SET_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update GMP_PROCESS_PARAMETER_SET_B set
    PARAMETER_SET = X_PARAMETER_SET,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where PARAMETER_SET_ID = X_PARAMETER_SET_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update GMP_PROCESS_PARAMETER_SET_TL set
    SET_DESCRIPTION = X_SET_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where PARAMETER_SET_ID = X_PARAMETER_SET_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_PARAMETER_SET_ID in NUMBER
) is
begin
  delete from GMP_PROCESS_PARAMETER_SET_TL
  where PARAMETER_SET_ID = X_PARAMETER_SET_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from GMP_PROCESS_PARAMETER_SET_B
  where PARAMETER_SET_ID = X_PARAMETER_SET_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from GMP_PROCESS_PARAMETER_SET_TL T
  where not exists
    (select NULL
    from GMP_PROCESS_PARAMETER_SET_B B
    where B.PARAMETER_SET_ID = T.PARAMETER_SET_ID
    );

  update GMP_PROCESS_PARAMETER_SET_TL T set (
      SET_DESCRIPTION
    ) = (select
      B.SET_DESCRIPTION
    from GMP_PROCESS_PARAMETER_SET_TL B
    where B.PARAMETER_SET_ID = T.PARAMETER_SET_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.PARAMETER_SET_ID,
      T.LANGUAGE
  ) in (select
      SUBT.PARAMETER_SET_ID,
      SUBT.LANGUAGE
    from GMP_PROCESS_PARAMETER_SET_TL SUBB, GMP_PROCESS_PARAMETER_SET_TL SUBT
    where SUBB.PARAMETER_SET_ID = SUBT.PARAMETER_SET_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.SET_DESCRIPTION <> SUBT.SET_DESCRIPTION
      or (SUBB.SET_DESCRIPTION is null and SUBT.SET_DESCRIPTION is not null)
      or (SUBB.SET_DESCRIPTION is not null and SUBT.SET_DESCRIPTION is null)
  ));

  insert into GMP_PROCESS_PARAMETER_SET_TL (
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    PARAMETER_SET_ID,
    SET_DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.PARAMETER_SET_ID,
    B.SET_DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from GMP_PROCESS_PARAMETER_SET_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from GMP_PROCESS_PARAMETER_SET_TL T
    where T.PARAMETER_SET_ID = B.PARAMETER_SET_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end GMP_PROCESS_PARAMETER_SET_PKG;

/
