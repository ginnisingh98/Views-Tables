--------------------------------------------------------
--  DDL for Package Body QP_PARAMETERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_PARAMETERS_PKG" as
/* $Header: QPXUPARB.pls 120.0 2005/08/05 00:26:47 nirmkuma noship $ */

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_PARAMETER_ID in NUMBER,
  X_VALUE_SET_ID in NUMBER,
  X_ADVANCED_PRICING_ONLY in VARCHAR2,
  X_SEEDED_VALUE in VARCHAR2,
  X_PARAMETER_CODE in VARCHAR2,
  X_PARAMETER_LEVEL in VARCHAR2,
  X_PARAMETER_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from QP_PARAMETERS_B
    where PARAMETER_ID = X_PARAMETER_ID
    ;
begin
  insert into QP_PARAMETERS_B (
    VALUE_SET_ID,
    ADVANCED_PRICING_ONLY,
    SEEDED_VALUE,
    PARAMETER_CODE,
    PARAMETER_ID,
    PARAMETER_LEVEL,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_VALUE_SET_ID,
    X_ADVANCED_PRICING_ONLY,
    X_SEEDED_VALUE,
    X_PARAMETER_CODE,
    X_PARAMETER_ID,
    X_PARAMETER_LEVEL,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into QP_PARAMETERS_TL (
    PARAMETER_ID,
    PARAMETER_NAME,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_PARAMETER_ID,
    X_PARAMETER_NAME,
    X_DESCRIPTION,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from QP_PARAMETERS_TL T
    where T.PARAMETER_ID = X_PARAMETER_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

  QP_PARAM_UTIL.Populate_Parameter_Values( X_PARAMETER_ID,
                                     X_SEEDED_VALUE,
                                     X_PARAMETER_LEVEL);

end INSERT_ROW;

procedure LOCK_ROW (
  X_PARAMETER_ID in NUMBER,
  X_VALUE_SET_ID in NUMBER,
  X_ADVANCED_PRICING_ONLY in VARCHAR2,
  X_SEEDED_VALUE in VARCHAR2,
  X_PARAMETER_CODE in VARCHAR2,
  X_PARAMETER_LEVEL in VARCHAR2,
  X_PARAMETER_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      VALUE_SET_ID,
      ADVANCED_PRICING_ONLY,
      SEEDED_VALUE,
      PARAMETER_CODE,
      PARAMETER_LEVEL
    from QP_PARAMETERS_B
    where PARAMETER_ID = X_PARAMETER_ID
    for update of PARAMETER_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      PARAMETER_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from QP_PARAMETERS_TL
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
  if (    ((recinfo.VALUE_SET_ID = X_VALUE_SET_ID)
           OR ((recinfo.VALUE_SET_ID is null) AND (X_VALUE_SET_ID is null)))
      AND ((recinfo.ADVANCED_PRICING_ONLY = X_ADVANCED_PRICING_ONLY)
           OR ((recinfo.ADVANCED_PRICING_ONLY is null) AND (X_ADVANCED_PRICING_ONLY is null)))
      AND ((recinfo.SEEDED_VALUE = X_SEEDED_VALUE)
           OR ((recinfo.SEEDED_VALUE is null) AND (X_SEEDED_VALUE is null)))
      AND (recinfo.PARAMETER_CODE = X_PARAMETER_CODE)
      AND (recinfo.PARAMETER_LEVEL = X_PARAMETER_LEVEL)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.PARAMETER_NAME = X_PARAMETER_NAME)
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
  X_PARAMETER_ID in NUMBER,
  X_VALUE_SET_ID in NUMBER,
  X_ADVANCED_PRICING_ONLY in VARCHAR2,
  X_SEEDED_VALUE in VARCHAR2,
  X_PARAMETER_CODE in VARCHAR2,
  X_PARAMETER_LEVEL in VARCHAR2,
  X_PARAMETER_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update QP_PARAMETERS_B set
    VALUE_SET_ID = X_VALUE_SET_ID,
    ADVANCED_PRICING_ONLY = X_ADVANCED_PRICING_ONLY,
    SEEDED_VALUE = X_SEEDED_VALUE,
    PARAMETER_CODE = X_PARAMETER_CODE,
    PARAMETER_LEVEL = X_PARAMETER_LEVEL,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where PARAMETER_ID = X_PARAMETER_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update QP_PARAMETERS_TL set
    PARAMETER_NAME = X_PARAMETER_NAME,
    DESCRIPTION = X_DESCRIPTION,
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

  delete from QP_PARAMETERS_TL
  where PARAMETER_ID = X_PARAMETER_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from QP_PARAMETERS_B
  where PARAMETER_ID = X_PARAMETER_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from QP_PARAMETER_VALUES
  where PARAMETER_ID = X_PARAMETER_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from QP_PARAMETERS_TL T
  where not exists
    (select NULL
    from QP_PARAMETERS_B B
    where B.PARAMETER_ID = T.PARAMETER_ID
    );

  update QP_PARAMETERS_TL T set (
      PARAMETER_NAME,
      DESCRIPTION
    ) = (select
      B.PARAMETER_NAME,
      B.DESCRIPTION
    from QP_PARAMETERS_TL B
    where B.PARAMETER_ID = T.PARAMETER_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.PARAMETER_ID,
      T.LANGUAGE
  ) in (select
      SUBT.PARAMETER_ID,
      SUBT.LANGUAGE
    from QP_PARAMETERS_TL SUBB, QP_PARAMETERS_TL SUBT
    where SUBB.PARAMETER_ID = SUBT.PARAMETER_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.PARAMETER_NAME <> SUBT.PARAMETER_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into QP_PARAMETERS_TL (
    PARAMETER_ID,
    PARAMETER_NAME,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.PARAMETER_ID,
    B.PARAMETER_NAME,
    B.DESCRIPTION,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from QP_PARAMETERS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from QP_PARAMETERS_TL T
    where T.PARAMETER_ID = B.PARAMETER_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end QP_PARAMETERS_PKG;

/
