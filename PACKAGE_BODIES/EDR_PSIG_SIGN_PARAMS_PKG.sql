--------------------------------------------------------
--  DDL for Package Body EDR_PSIG_SIGN_PARAMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDR_PSIG_SIGN_PARAMS_PKG" as
/* $Header: EDRSPRMB.pls 120.0.12000000.1 2007/01/18 05:55:33 appldev ship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PARAMETER_ID in NUMBER,
  X_SIGNATURE_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_VALUE in VARCHAR2,
  X_DISPLAY_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from EDR_PSIG_SIGN_PARAMS_B
    where PARAMETER_ID = X_PARAMETER_ID
    ;
begin
  insert into EDR_PSIG_SIGN_PARAMS_B (
    PARAMETER_ID,
    SIGNATURE_ID,
    NAME,
    VALUE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_PARAMETER_ID,
    X_SIGNATURE_ID,
    X_NAME,
    X_VALUE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into EDR_PSIG_SIGN_PARAMS_TL (
    PARAMETER_ID,
    DISPLAY_NAME,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_PARAMETER_ID,
    X_DISPLAY_NAME,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from EDR_PSIG_SIGN_PARAMS_TL T
    where T.PARAMETER_ID = X_PARAMETER_ID
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
  X_SIGNATURE_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_VALUE in VARCHAR2,
  X_DISPLAY_NAME in VARCHAR2
) is
  cursor c is select
      SIGNATURE_ID,
      NAME,
      VALUE
    from EDR_PSIG_SIGN_PARAMS_B
    where PARAMETER_ID = X_PARAMETER_ID
    for update of PARAMETER_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      DISPLAY_NAME,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from EDR_PSIG_SIGN_PARAMS_TL
    where PARAMETER_ID = X_PARAMETER_ID
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
  if (    ((recinfo.SIGNATURE_ID = X_SIGNATURE_ID)
           OR ((recinfo.SIGNATURE_ID is null) AND (X_SIGNATURE_ID is null)))
      AND ((recinfo.NAME = X_NAME)
           OR ((recinfo.NAME is null) AND (X_NAME is null)))
      AND ((recinfo.VALUE = X_VALUE)
           OR ((recinfo.VALUE is null) AND (X_VALUE is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.DISPLAY_NAME = X_DISPLAY_NAME)
               OR ((tlinfo.DISPLAY_NAME is null) AND (X_DISPLAY_NAME is null)))
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
  X_SIGNATURE_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_VALUE in VARCHAR2,
  X_DISPLAY_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update EDR_PSIG_SIGN_PARAMS_B set
    SIGNATURE_ID = X_SIGNATURE_ID,
    NAME = X_NAME,
    VALUE = X_VALUE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where PARAMETER_ID = X_PARAMETER_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update EDR_PSIG_SIGN_PARAMS_TL set
    DISPLAY_NAME = X_DISPLAY_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where PARAMETER_ID = X_PARAMETER_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_PARAMETER_ID in NUMBER
) is
begin
  delete from EDR_PSIG_SIGN_PARAMS_TL
  where PARAMETER_ID = X_PARAMETER_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from EDR_PSIG_SIGN_PARAMS_B
  where PARAMETER_ID = X_PARAMETER_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from EDR_PSIG_SIGN_PARAMS_TL T
  where not exists
    (select NULL
    from EDR_PSIG_SIGN_PARAMS_B B
    where B.PARAMETER_ID = T.PARAMETER_ID
    );

  update EDR_PSIG_SIGN_PARAMS_TL T set (
      DISPLAY_NAME
    ) = (select
      B.DISPLAY_NAME
    from EDR_PSIG_SIGN_PARAMS_TL B
    where B.PARAMETER_ID = T.PARAMETER_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.PARAMETER_ID,
      T.LANGUAGE
  ) in (select
      SUBT.PARAMETER_ID,
      SUBT.LANGUAGE
    from EDR_PSIG_SIGN_PARAMS_TL SUBB, EDR_PSIG_SIGN_PARAMS_TL SUBT
    where SUBB.PARAMETER_ID = SUBT.PARAMETER_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DISPLAY_NAME <> SUBT.DISPLAY_NAME
      or (SUBB.DISPLAY_NAME is null and SUBT.DISPLAY_NAME is not null)
      or (SUBB.DISPLAY_NAME is not null and SUBT.DISPLAY_NAME is null)
  ));

  insert into EDR_PSIG_SIGN_PARAMS_TL (
    PARAMETER_ID,
    DISPLAY_NAME,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.PARAMETER_ID,
    B.DISPLAY_NAME,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from EDR_PSIG_SIGN_PARAMS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from EDR_PSIG_SIGN_PARAMS_TL T
    where T.PARAMETER_ID = B.PARAMETER_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end EDR_PSIG_SIGN_PARAMS_PKG;

/
