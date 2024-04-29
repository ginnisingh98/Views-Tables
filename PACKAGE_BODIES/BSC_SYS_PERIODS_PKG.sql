--------------------------------------------------------
--  DDL for Package Body BSC_SYS_PERIODS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_SYS_PERIODS_PKG" as
/* $Header: BSCSPRDB.pls 115.6 2003/02/12 14:29:33 adeulgao ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_YEAR in NUMBER,
  X_PERIODICITY_ID in NUMBER,
  X_PERIOD_ID in NUMBER,
  X_MONTH in NUMBER,
  X_NAME in VARCHAR2,
  X_SHORT_NAME in VARCHAR2
) is
  cursor C is select ROWID from BSC_SYS_PERIODS_TL
    where YEAR = X_YEAR
    and PERIODICITY_ID = X_PERIODICITY_ID
    and PERIOD_ID = X_PERIOD_ID
    and MONTH = X_MONTH
    and LANGUAGE = userenv('LANG')
    ;
begin
  insert into BSC_SYS_PERIODS_TL (
    YEAR,
    PERIODICITY_ID,
    PERIOD_ID,
    MONTH,
    NAME,
    SHORT_NAME,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_YEAR,
    X_PERIODICITY_ID,
    X_PERIOD_ID,
    X_MONTH,
    X_NAME,
    X_SHORT_NAME,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from BSC_SYS_PERIODS_TL T
    where T.YEAR = X_YEAR
    and T.PERIODICITY_ID = X_PERIODICITY_ID
    and T.PERIOD_ID = X_PERIOD_ID
    and T.MONTH = X_MONTH
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
  X_YEAR in NUMBER,
  X_PERIODICITY_ID in NUMBER,
  X_PERIOD_ID in NUMBER,
  X_MONTH in NUMBER,
  X_NAME in VARCHAR2,
  X_SHORT_NAME in VARCHAR2
) is
  cursor c1 is select
      NAME,
      SHORT_NAME,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from BSC_SYS_PERIODS_TL
    where YEAR = X_YEAR
    and PERIODICITY_ID = X_PERIODICITY_ID
    and PERIOD_ID = X_PERIOD_ID
    and MONTH = X_MONTH
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of YEAR nowait;
begin
  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.NAME = X_NAME)
               OR ((tlinfo.NAME is null) AND (X_NAME is null)))
          AND ((tlinfo.SHORT_NAME = X_SHORT_NAME)
               OR ((tlinfo.SHORT_NAME is null) AND (X_SHORT_NAME is null)))
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
  X_YEAR in NUMBER,
  X_PERIODICITY_ID in NUMBER,
  X_PERIOD_ID in NUMBER,
  X_MONTH in NUMBER,
  X_NAME in VARCHAR2,
  X_SHORT_NAME in VARCHAR2
) is
begin
  update BSC_SYS_PERIODS_TL set
    NAME = X_NAME,
    SHORT_NAME = X_SHORT_NAME,
    SOURCE_LANG = userenv('LANG')
  where YEAR = X_YEAR
  and PERIODICITY_ID = X_PERIODICITY_ID
  and PERIOD_ID = X_PERIOD_ID
  and MONTH = X_MONTH
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_YEAR in NUMBER,
  X_PERIODICITY_ID in NUMBER,
  X_PERIOD_ID in NUMBER,
  X_MONTH in NUMBER
) is
begin
  delete from BSC_SYS_PERIODS_TL
  where YEAR = X_YEAR
  and PERIODICITY_ID = X_PERIODICITY_ID
  and PERIOD_ID = X_PERIOD_ID
  and MONTH = X_MONTH;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  update BSC_SYS_PERIODS_TL T set (
      NAME,
      SHORT_NAME
    ) = (select
      B.NAME,
      B.SHORT_NAME
    from BSC_SYS_PERIODS_TL B
    where B.YEAR = T.YEAR
    and B.PERIODICITY_ID = T.PERIODICITY_ID
    and B.PERIOD_ID = T.PERIOD_ID
    and B.MONTH = T.MONTH
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.YEAR,
      T.PERIODICITY_ID,
      T.PERIOD_ID,
      T.MONTH,
      T.LANGUAGE
  ) in (select
      SUBT.YEAR,
      SUBT.PERIODICITY_ID,
      SUBT.PERIOD_ID,
      SUBT.MONTH,
      SUBT.LANGUAGE
    from BSC_SYS_PERIODS_TL SUBB, BSC_SYS_PERIODS_TL SUBT
    where SUBB.YEAR = SUBT.YEAR
    and SUBB.PERIODICITY_ID = SUBT.PERIODICITY_ID
    and SUBB.PERIOD_ID = SUBT.PERIOD_ID
    and SUBB.MONTH = SUBT.MONTH
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or (SUBB.NAME is null and SUBT.NAME is not null)
      or (SUBB.NAME is not null and SUBT.NAME is null)
      or SUBB.SHORT_NAME <> SUBT.SHORT_NAME
      or (SUBB.SHORT_NAME is null and SUBT.SHORT_NAME is not null)
      or (SUBB.SHORT_NAME is not null and SUBT.SHORT_NAME is null)
  ));

  insert into BSC_SYS_PERIODS_TL (
    YEAR,
    PERIODICITY_ID,
    PERIOD_ID,
    MONTH,
    NAME,
    SHORT_NAME,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.YEAR,
    B.PERIODICITY_ID,
    B.PERIOD_ID,
    B.MONTH,
    B.NAME,
    B.SHORT_NAME,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from BSC_SYS_PERIODS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from BSC_SYS_PERIODS_TL T
    where T.YEAR = B.YEAR
    and T.PERIODICITY_ID = B.PERIODICITY_ID
    and T.PERIOD_ID = B.PERIOD_ID
    and T.MONTH = B.MONTH
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end BSC_SYS_PERIODS_PKG;

/
