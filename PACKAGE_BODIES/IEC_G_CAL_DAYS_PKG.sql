--------------------------------------------------------
--  DDL for Package Body IEC_G_CAL_DAYS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEC_G_CAL_DAYS_PKG" as
/* $Header: IECCDAYB.pls 115.7 2003/08/22 20:41:19 hhuang noship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_DAY_ID in NUMBER,
  X_CALENDAR_ID in NUMBER,
  X_DAY_CODE in VARCHAR2,
  X_PATTERN_CODE in VARCHAR2,
  X_EXCEPTION_MONTH in VARCHAR2,
  X_EXCEPTION_DAY in VARCHAR2,
  X_EXCEPTION_YEAR in VARCHAR2,
  X_EXCEPTION_WEEKDAY_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_DAY_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from IEC_G_CAL_DAYS_B
    where DAY_ID = X_DAY_ID
    ;
begin
  insert into IEC_G_CAL_DAYS_B (
    DAY_ID,
    CALENDAR_ID,
    DAY_CODE,
    PATTERN_CODE,
    EXCEPTION_MONTH,
    EXCEPTION_DAY,
    EXCEPTION_YEAR,
    EXCEPTION_WEEKDAY_CODE,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_DAY_ID,
    X_CALENDAR_ID,
    X_DAY_CODE,
    X_PATTERN_CODE,
    X_EXCEPTION_MONTH,
    X_EXCEPTION_DAY,
    X_EXCEPTION_YEAR,
    X_EXCEPTION_WEEKDAY_CODE,
    X_OBJECT_VERSION_NUMBER,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into IEC_G_CAL_DAYS_TL (
    DAY_ID,
    DAY_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_DAY_ID,
    X_DAY_NAME,
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
    from IEC_G_CAL_DAYS_TL T
    where T.DAY_ID = X_DAY_ID
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
  X_DAY_ID in NUMBER,
  X_CALENDAR_ID in NUMBER,
  X_DAY_CODE in VARCHAR2,
  X_PATTERN_CODE in VARCHAR2,
  X_EXCEPTION_MONTH in VARCHAR2,
  X_EXCEPTION_DAY in VARCHAR2,
  X_EXCEPTION_YEAR in VARCHAR2,
  X_EXCEPTION_WEEKDAY_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_DAY_NAME in VARCHAR2
) is
  cursor c is select
      CALENDAR_ID,
      DAY_CODE,
      PATTERN_CODE,
      EXCEPTION_MONTH,
      EXCEPTION_DAY,
      EXCEPTION_YEAR,
      EXCEPTION_WEEKDAY_CODE,
      OBJECT_VERSION_NUMBER
    from IEC_G_CAL_DAYS_B
    where DAY_ID = X_DAY_ID
    for update of DAY_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      DAY_NAME,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from IEC_G_CAL_DAYS_TL
    where DAY_ID = X_DAY_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of DAY_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.CALENDAR_ID = X_CALENDAR_ID)
      AND (recinfo.DAY_CODE = X_DAY_CODE)
      AND (recinfo.PATTERN_CODE = X_PATTERN_CODE)
      AND ((recinfo.EXCEPTION_MONTH = X_EXCEPTION_MONTH)
           OR ((recinfo.EXCEPTION_MONTH is null) AND (X_EXCEPTION_MONTH is null)))
      AND ((recinfo.EXCEPTION_DAY = X_EXCEPTION_DAY)
           OR ((recinfo.EXCEPTION_DAY is null) AND (X_EXCEPTION_DAY is null)))
      AND ((recinfo.EXCEPTION_YEAR = X_EXCEPTION_YEAR)
           OR ((recinfo.EXCEPTION_YEAR is null) AND (X_EXCEPTION_YEAR is null)))
      AND ((recinfo.EXCEPTION_WEEKDAY_CODE = X_EXCEPTION_WEEKDAY_CODE)
           OR ((recinfo.EXCEPTION_WEEKDAY_CODE is null) AND (X_EXCEPTION_WEEKDAY_CODE is null)))
      AND (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.DAY_NAME = X_DAY_NAME)
               OR ((tlinfo.DAY_NAME is null) AND (X_DAY_NAME is null)))
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
  X_DAY_ID in NUMBER,
  X_CALENDAR_ID in NUMBER,
  X_DAY_CODE in VARCHAR2,
  X_PATTERN_CODE in VARCHAR2,
  X_EXCEPTION_MONTH in VARCHAR2,
  X_EXCEPTION_DAY in VARCHAR2,
  X_EXCEPTION_YEAR in VARCHAR2,
  X_EXCEPTION_WEEKDAY_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_DAY_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update IEC_G_CAL_DAYS_B set
    CALENDAR_ID = X_CALENDAR_ID,
    DAY_CODE = X_DAY_CODE,
    PATTERN_CODE = X_PATTERN_CODE,
    EXCEPTION_MONTH = X_EXCEPTION_MONTH,
    EXCEPTION_DAY = X_EXCEPTION_DAY,
    EXCEPTION_YEAR = X_EXCEPTION_YEAR,
    EXCEPTION_WEEKDAY_CODE = X_EXCEPTION_WEEKDAY_CODE,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where DAY_ID = X_DAY_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update IEC_G_CAL_DAYS_TL set
    DAY_NAME = X_DAY_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where DAY_ID = X_DAY_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_DAY_ID in NUMBER
) is
begin
  delete from IEC_G_CAL_DAYS_TL
  where DAY_ID = X_DAY_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from IEC_G_CAL_DAYS_B
  where DAY_ID = X_DAY_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from IEC_G_CAL_DAYS_TL T
  where not exists
    (select NULL
    from IEC_G_CAL_DAYS_B B
    where B.DAY_ID = T.DAY_ID
    );

  update IEC_G_CAL_DAYS_TL T set (
      DAY_NAME
    ) = (select
      B.DAY_NAME
    from IEC_G_CAL_DAYS_TL B
    where B.DAY_ID = T.DAY_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.DAY_ID,
      T.LANGUAGE
  ) in (select
      SUBT.DAY_ID,
      SUBT.LANGUAGE
    from IEC_G_CAL_DAYS_TL SUBB, IEC_G_CAL_DAYS_TL SUBT
    where SUBB.DAY_ID = SUBT.DAY_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DAY_NAME <> SUBT.DAY_NAME
      or (SUBB.DAY_NAME is null and SUBT.DAY_NAME is not null)
      or (SUBB.DAY_NAME is not null and SUBT.DAY_NAME is null)
  ));

  insert into IEC_G_CAL_DAYS_TL (
    DAY_ID,
    DAY_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.DAY_ID,
    B.DAY_NAME,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from IEC_G_CAL_DAYS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from IEC_G_CAL_DAYS_TL T
    where T.DAY_ID = B.DAY_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure LOAD_ROW (
  X_DAY_ID in NUMBER,
  X_CALENDAR_ID in NUMBER,
  X_DAY_CODE in VARCHAR2,
  X_PATTERN_CODE in VARCHAR2,
  X_EXCEPTION_MONTH in VARCHAR2,
  X_EXCEPTION_DAY in VARCHAR2,
  X_EXCEPTION_YEAR in VARCHAR2,
  X_EXCEPTION_WEEKDAY_CODE in VARCHAR2,
  X_DAY_NAME in VARCHAR2,
  X_OWNER in VARCHAR2
) is

  USER_ID NUMBER := 0;
  ROW_ID  VARCHAR2(500);

begin

  if (X_OWNER = 'SEED') then
    USER_ID := 1;
  end if;

  UPDATE_ROW ( X_DAY_ID
             , X_CALENDAR_ID
             , X_DAY_CODE
             , X_PATTERN_CODE
             , X_EXCEPTION_MONTH
             , X_EXCEPTION_DAY
             , X_EXCEPTION_YEAR
             , X_EXCEPTION_WEEKDAY_CODE
             , 0
             , X_DAY_NAME
             , SYSDATE
             , USER_ID
             , 0);

exception
  when no_data_found then
    INSERT_ROW ( ROW_ID
               , X_DAY_ID
               , X_CALENDAR_ID
               , X_DAY_CODE
               , X_PATTERN_CODE
               , X_EXCEPTION_MONTH
               , X_EXCEPTION_DAY
               , X_EXCEPTION_YEAR
               , X_EXCEPTION_WEEKDAY_CODE
               , 0
               , X_DAY_NAME
               , SYSDATE
               , USER_ID
               , SYSDATE
               , USER_ID
               , 0);

end LOAD_ROW;

procedure TRANSLATE_ROW (
  X_DAY_ID in NUMBER,
  X_DAY_NAME in VARCHAR2,
  X_OWNER in VARCHAR2
) is
begin

  -- only UPDATE rows that have not been altered by user

  update IEC_G_CAL_DAYS_TL set
  SOURCE_LANG = userenv('LANG'),
  DAY_NAME = X_DAY_NAME,
  LAST_UPDATE_DATE = SYSDATE,
  LAST_UPDATED_BY = DECODE(X_OWNER, 'SEED', 1, 0),
  LAST_UPDATE_LOGIN = 0
  where DAY_ID = X_DAY_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

end TRANSLATE_ROW;

end IEC_G_CAL_DAYS_PKG;

/
