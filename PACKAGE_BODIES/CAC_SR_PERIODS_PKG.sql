--------------------------------------------------------
--  DDL for Package Body CAC_SR_PERIODS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CAC_SR_PERIODS_PKG" as
/* $Header: cacsrperiodb.pls 120.1 2005/07/02 02:18:48 appldev noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_PERIOD_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_PERIOD_CATEGORY_ID in NUMBER,
  X_WEEK_DAY_NUM in NUMBER,
  X_START_TIME_MS in NUMBER,
  X_END_TIME_MS in NUMBER,
  X_DURATION in NUMBER,
  X_DURATION_UOM in VARCHAR2,
  X_SHORT_CODE in VARCHAR2,
  X_HAS_DETAILS in VARCHAR2,
  X_SHOW_IN_LOV in VARCHAR2,
  X_PERIOD_NAME in VARCHAR2,
  X_PERIOD_DESC in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from CAC_SR_PERIODS_B
    where PERIOD_ID = X_PERIOD_ID
    ;
begin
  insert into CAC_SR_PERIODS_B (
    PERIOD_ID,
    OBJECT_VERSION_NUMBER,
    START_DATE_ACTIVE,
    END_DATE_ACTIVE,
    PERIOD_CATEGORY_ID,
    WEEK_DAY_NUM,
    START_TIME_MS,
    END_TIME_MS,
    DURATION,
    DURATION_UOM,
    SHORT_CODE,
    HAS_DETAILS,
    SHOW_IN_LOV,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_PERIOD_ID,
    X_OBJECT_VERSION_NUMBER,
    X_START_DATE_ACTIVE,
    X_END_DATE_ACTIVE,
    X_PERIOD_CATEGORY_ID,
    X_WEEK_DAY_NUM,
    X_START_TIME_MS,
    X_END_TIME_MS,
    X_DURATION,
    X_DURATION_UOM,
    X_SHORT_CODE,
    X_HAS_DETAILS,
    X_SHOW_IN_LOV,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into CAC_SR_PERIODS_TL (
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    PERIOD_ID,
    PERIOD_NAME,
    PERIOD_DESC,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_PERIOD_ID,
    X_PERIOD_NAME,
    X_PERIOD_DESC,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from CAC_SR_PERIODS_TL T
    where T.PERIOD_ID = X_PERIOD_ID
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
  X_PERIOD_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_PERIOD_CATEGORY_ID in NUMBER,
  X_WEEK_DAY_NUM in NUMBER,
  X_START_TIME_MS in NUMBER,
  X_END_TIME_MS in NUMBER,
  X_DURATION in NUMBER,
  X_DURATION_UOM in VARCHAR2,
  X_SHORT_CODE in VARCHAR2,
  X_HAS_DETAILS in VARCHAR2,
  X_SHOW_IN_LOV in VARCHAR2,
  X_PERIOD_NAME in VARCHAR2,
  X_PERIOD_DESC in VARCHAR2
) is
  cursor c is select
      OBJECT_VERSION_NUMBER,
      START_DATE_ACTIVE,
      END_DATE_ACTIVE,
      PERIOD_CATEGORY_ID,
      WEEK_DAY_NUM,
      START_TIME_MS,
      END_TIME_MS,
      DURATION,
      DURATION_UOM,
      SHORT_CODE,
      HAS_DETAILS,
      SHOW_IN_LOV
    from CAC_SR_PERIODS_B
    where PERIOD_ID = X_PERIOD_ID
    for update of PERIOD_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      PERIOD_NAME,
      PERIOD_DESC,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from CAC_SR_PERIODS_TL
    where PERIOD_ID = X_PERIOD_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of PERIOD_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
      AND ((recinfo.START_DATE_ACTIVE = X_START_DATE_ACTIVE)
           OR ((recinfo.START_DATE_ACTIVE is null) AND (X_START_DATE_ACTIVE is null)))
      AND ((recinfo.END_DATE_ACTIVE = X_END_DATE_ACTIVE)
           OR ((recinfo.END_DATE_ACTIVE is null) AND (X_END_DATE_ACTIVE is null)))
      AND (recinfo.PERIOD_CATEGORY_ID = X_PERIOD_CATEGORY_ID)
      AND ((recinfo.WEEK_DAY_NUM = X_WEEK_DAY_NUM)
           OR ((recinfo.WEEK_DAY_NUM is null) AND (X_WEEK_DAY_NUM is null)))
      AND ((recinfo.START_TIME_MS = X_START_TIME_MS)
           OR ((recinfo.START_TIME_MS is null) AND (X_START_TIME_MS is null)))
      AND ((recinfo.END_TIME_MS = X_END_TIME_MS)
           OR ((recinfo.END_TIME_MS is null) AND (X_END_TIME_MS is null)))
      AND ((recinfo.DURATION = X_DURATION)
           OR ((recinfo.DURATION is null) AND (X_DURATION is null)))
      AND ((recinfo.DURATION_UOM = X_DURATION_UOM)
           OR ((recinfo.DURATION_UOM is null) AND (X_DURATION_UOM is null)))
      AND ((recinfo.SHORT_CODE = X_SHORT_CODE)
           OR ((recinfo.SHORT_CODE is null) AND (X_SHORT_CODE is null)))
      AND ((recinfo.HAS_DETAILS = X_HAS_DETAILS)
           OR ((recinfo.HAS_DETAILS is null) AND (X_HAS_DETAILS is null)))
      AND (recinfo.SHOW_IN_LOV = X_SHOW_IN_LOV)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.PERIOD_NAME = X_PERIOD_NAME)
          AND ((tlinfo.PERIOD_DESC = X_PERIOD_DESC)
               OR ((tlinfo.PERIOD_DESC is null) AND (X_PERIOD_DESC is null)))
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
  X_PERIOD_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_PERIOD_CATEGORY_ID in NUMBER,
  X_WEEK_DAY_NUM in NUMBER,
  X_START_TIME_MS in NUMBER,
  X_END_TIME_MS in NUMBER,
  X_DURATION in NUMBER,
  X_DURATION_UOM in VARCHAR2,
  X_SHORT_CODE in VARCHAR2,
  X_HAS_DETAILS in VARCHAR2,
  X_SHOW_IN_LOV in VARCHAR2,
  X_PERIOD_NAME in VARCHAR2,
  X_PERIOD_DESC in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update CAC_SR_PERIODS_B set
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    START_DATE_ACTIVE = X_START_DATE_ACTIVE,
    END_DATE_ACTIVE = X_END_DATE_ACTIVE,
    PERIOD_CATEGORY_ID = X_PERIOD_CATEGORY_ID,
    WEEK_DAY_NUM = X_WEEK_DAY_NUM,
    START_TIME_MS = X_START_TIME_MS,
    END_TIME_MS = X_END_TIME_MS,
    DURATION = X_DURATION,
    DURATION_UOM = X_DURATION_UOM,
    SHORT_CODE = X_SHORT_CODE,
    HAS_DETAILS = X_HAS_DETAILS,
    SHOW_IN_LOV = X_SHOW_IN_LOV,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where PERIOD_ID = X_PERIOD_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update CAC_SR_PERIODS_TL set
    PERIOD_NAME = X_PERIOD_NAME,
    PERIOD_DESC = X_PERIOD_DESC,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where PERIOD_ID = X_PERIOD_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_PERIOD_ID in NUMBER
) is
begin
  delete from CAC_SR_PERIODS_TL
  where PERIOD_ID = X_PERIOD_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from CAC_SR_PERIODS_B
  where PERIOD_ID = X_PERIOD_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from CAC_SR_PERIODS_TL T
  where not exists
    (select NULL
    from CAC_SR_PERIODS_B B
    where B.PERIOD_ID = T.PERIOD_ID
    );

  update CAC_SR_PERIODS_TL T set (
      PERIOD_NAME,
      PERIOD_DESC
    ) = (select
      B.PERIOD_NAME,
      B.PERIOD_DESC
    from CAC_SR_PERIODS_TL B
    where B.PERIOD_ID = T.PERIOD_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.PERIOD_ID,
      T.LANGUAGE
  ) in (select
      SUBT.PERIOD_ID,
      SUBT.LANGUAGE
    from CAC_SR_PERIODS_TL SUBB, CAC_SR_PERIODS_TL SUBT
    where SUBB.PERIOD_ID = SUBT.PERIOD_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.PERIOD_NAME <> SUBT.PERIOD_NAME
      or SUBB.PERIOD_DESC <> SUBT.PERIOD_DESC
      or (SUBB.PERIOD_DESC is null and SUBT.PERIOD_DESC is not null)
      or (SUBB.PERIOD_DESC is not null and SUBT.PERIOD_DESC is null)
  ));

  insert into CAC_SR_PERIODS_TL (
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    PERIOD_ID,
    PERIOD_NAME,
    PERIOD_DESC,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.PERIOD_ID,
    B.PERIOD_NAME,
    B.PERIOD_DESC,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from CAC_SR_PERIODS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from CAC_SR_PERIODS_TL T
    where T.PERIOD_ID = B.PERIOD_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end CAC_SR_PERIODS_PKG;

/
