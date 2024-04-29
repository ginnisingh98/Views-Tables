--------------------------------------------------------
--  DDL for Package Body BSC_SYS_CALENDARS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_SYS_CALENDARS_PKG" as
/* $Header: BSCCALDB.pls 115.5 2003/01/10 23:57:05 meastmon ship $ */
procedure INSERT_ROW (
  X_CALENDAR_ID in NUMBER,
  X_EDW_FLAG in NUMBER,
  X_FISCAL_YEAR in NUMBER,
  X_FISCAL_CHANGE in NUMBER,
  X_RANGE_YR_MOD in NUMBER,
  X_CURRENT_YEAR in NUMBER,
  X_START_MONTH in NUMBER,
  X_START_DAY in NUMBER,
  X_NAME in VARCHAR2,
  X_HELP in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  insert into BSC_SYS_CALENDARS_B (
	  CALENDAR_ID,
	  EDW_FLAG,
	  FISCAL_YEAR,
	  FISCAL_CHANGE,
	  RANGE_YR_MOD ,
	  CURRENT_YEAR ,
	  START_MONTH ,
	  START_DAY ,
	  CREATION_DATE ,
	  CREATED_BY,
	  LAST_UPDATE_DATE,
	  LAST_UPDATED_BY ,
	  LAST_UPDATE_LOGIN
  ) values (
	  X_CALENDAR_ID,
	  X_EDW_FLAG,
	  X_FISCAL_YEAR,
	  X_FISCAL_CHANGE,
	  X_RANGE_YR_MOD ,
	  X_CURRENT_YEAR ,
	  X_START_MONTH ,
	  X_START_DAY ,
	  X_CREATION_DATE ,
	  X_CREATED_BY,
	  X_LAST_UPDATE_DATE,
	  X_LAST_UPDATED_BY ,
	  X_LAST_UPDATE_LOGIN
  );

  insert into BSC_SYS_CALENDARS_TL (
    CALENDAR_ID,
    NAME,
    HELP,
    CREATION_DATE ,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY ,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_CALENDAR_ID,
    X_NAME,
    X_HELP,
    X_CREATION_DATE ,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY ,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from BSC_SYS_CALENDARS_TL T
    where T.CALENDAR_ID = X_CALENDAR_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

end INSERT_ROW;

procedure TRANSLATE_ROW(
  X_CALENDAR_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_HELP in VARCHAR2)
is
begin
  update BSC_SYS_CALENDARS_TL set
        NAME = NVL(X_NAME,NAME),
        HELP = NVL(X_HELP, HELP),
        SOURCE_LANG = userenv('LANG')
 where
        userenv('LANG') in (LANGUAGE, SOURCE_LANG)
        and CALENDAR_ID = X_CALENDAR_ID;
end TRANSLATE_ROW;

procedure LOCK_ROW (
  X_CALENDAR_ID in NUMBER,
  X_EDW_FLAG in NUMBER,
  X_FISCAL_YEAR in NUMBER,
  X_FISCAL_CHANGE in NUMBER,
  X_RANGE_YR_MOD in NUMBER,
  X_CURRENT_YEAR in NUMBER,
  X_START_MONTH in NUMBER,
  X_START_DAY in NUMBER,
  X_NAME in VARCHAR2,
  X_HELP in VARCHAR2
) is
  cursor c is select
	  CALENDAR_ID,
	  EDW_FLAG,
	  FISCAL_YEAR,
	  FISCAL_CHANGE,
	  RANGE_YR_MOD ,
	  CURRENT_YEAR ,
	  START_MONTH ,
	  START_DAY
    from BSC_SYS_CALENDARS_B
    where CALENDAR_ID = X_CALENDAR_ID
    for update of CALENDAR_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      NAME,
      HELP,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from BSC_SYS_CALENDARS_TL
    where CALENDAR_ID = X_CALENDAR_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of CALENDAR_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.EDW_FLAG = X_EDW_FLAG)
      AND (recinfo.FISCAL_YEAR = X_FISCAL_YEAR)
      AND (recinfo.FISCAL_CHANGE = X_FISCAL_CHANGE)
      AND (recinfo.RANGE_YR_MOD = X_RANGE_YR_MOD)
      AND ((recinfo.CURRENT_YEAR = X_CURRENT_YEAR)
           OR ((recinfo.CURRENT_YEAR is null) AND (X_CURRENT_YEAR is null)))
      AND ((recinfo.START_MONTH = X_START_MONTH)
           OR ((recinfo.START_MONTH is null) AND (X_START_MONTH is null)))
      AND ((recinfo.START_DAY = X_START_DAY)
           OR ((recinfo.START_DAY is null) AND (X_START_DAY is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.NAME = X_NAME)
          AND (tlinfo.HELP = X_HELP)
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
  X_CALENDAR_ID in NUMBER,
  X_EDW_FLAG in NUMBER,
  X_FISCAL_YEAR in NUMBER,
  X_FISCAL_CHANGE in NUMBER,
  X_RANGE_YR_MOD in NUMBER,
  X_CURRENT_YEAR in NUMBER,
  X_START_MONTH in NUMBER,
  X_START_DAY in NUMBER,
  X_NAME in VARCHAR2,
  X_HELP in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update BSC_SYS_CALENDARS_B set
	  EDW_FLAG = X_EDW_FLAG,
	  FISCAL_YEAR = DECODE(LAST_UPDATED_BY,1,X_FISCAL_YEAR,FISCAL_YEAR),
	  FISCAL_CHANGE =DECODE(LAST_UPDATED_BY,1,X_FISCAL_CHANGE,FISCAL_CHANGE),
	  RANGE_YR_MOD =DECODE(LAST_UPDATED_BY,1,X_RANGE_YR_MOD,RANGE_YR_MOD),
	  CURRENT_YEAR =DECODE(LAST_UPDATED_BY,1,X_CURRENT_YEAR,CURRENT_YEAR),
	  START_MONTH = DECODE(LAST_UPDATED_BY,1,X_START_MONTH,START_MONTH),
	  START_DAY = DECODE(LAST_UPDATED_BY,1,X_START_DAY,START_DAY),
	  LAST_UPDATE_DATE = DECODE(LAST_UPDATED_BY,1,X_LAST_UPDATE_DATE,LAST_UPDATE_DATE),
	  LAST_UPDATED_BY = DECODE(LAST_UPDATED_BY,1,X_LAST_UPDATED_BY,LAST_UPDATED_BY),
	  LAST_UPDATE_LOGIN = DECODE(LAST_UPDATED_BY,1,X_LAST_UPDATE_LOGIN,LAST_UPDATE_LOGIN)
  WHERE CALENDAR_ID = X_CALENDAR_ID;
  if (sql%notfound) then
    raise no_data_found;
  end if;

  update BSC_SYS_CALENDARS_TL set
    NAME = X_NAME,
    HELP = X_HELP,
    SOURCE_LANG = userenv('LANG')
  where CALENDAR_ID = X_CALENDAR_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_CALENDAR_ID in NUMBER
) is
begin
  delete from BSC_SYS_CALENDARS_TL
  where CALENDAR_ID = X_CALENDAR_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from BSC_SYS_CALENDARS_B
  where CALENDAR_ID = X_CALENDAR_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from BSC_SYS_CALENDARS_TL T
  where not exists
    (select NULL
    from BSC_SYS_CALENDARS_B B
    where B.CALENDAR_ID = T.CALENDAR_ID
    );

  update BSC_SYS_CALENDARS_TL T set (
      NAME,
      HELP
    ) = (select
      B.NAME,
      B.HELP
    from BSC_SYS_CALENDARS_TL B
    where B.CALENDAR_ID = T.CALENDAR_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.CALENDAR_ID,
      T.LANGUAGE
  ) in (select
      SUBT.CALENDAR_ID,
      SUBT.LANGUAGE
    from BSC_SYS_CALENDARS_TL SUBB, BSC_SYS_CALENDARS_TL SUBT
    where SUBB.CALENDAR_ID = SUBT.CALENDAR_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or SUBB.HELP <> SUBT.HELP
  ));

  insert into BSC_SYS_CALENDARS_TL (
    CALENDAR_ID,
    NAME,
    HELP,
    LANGUAGE,
    SOURCE_LANG,
    CREATION_DATE ,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY
  ) select
    B.CALENDAR_ID,
    B.NAME,
    B.HELP,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG,
    B.CREATION_DATE ,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY
  from BSC_SYS_CALENDARS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from BSC_SYS_CALENDARS_TL T
    where T.CALENDAR_ID = B.CALENDAR_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end BSC_SYS_CALENDARS_PKG;

/
