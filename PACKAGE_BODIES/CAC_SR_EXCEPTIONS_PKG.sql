--------------------------------------------------------
--  DDL for Package Body CAC_SR_EXCEPTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CAC_SR_EXCEPTIONS_PKG" as
/* $Header: cacsrexcpb.pls 120.1 2005/07/02 02:18:27 appldev noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_EXCEPTION_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_EXCEPTION_GROUP in VARCHAR2,
  X_EXCEPTION_TYPE in VARCHAR2,
  X_PERIOD_CATEGORY_ID in NUMBER,
  X_TEMPLATE_ID in NUMBER,
  X_START_DATE_TIME in DATE,
  X_END_DATE_TIME in DATE,
  X_WHOLE_DAY_FLAG in VARCHAR2,
  X_EXCEPTION_NAME in VARCHAR2,
  X_EXCEPTION_DESC in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from CAC_SR_EXCEPTIONS_B
    where EXCEPTION_ID = X_EXCEPTION_ID
    ;
begin
  insert into CAC_SR_EXCEPTIONS_B (
    EXCEPTION_ID,
    OBJECT_VERSION_NUMBER,
    EXCEPTION_GROUP,
    EXCEPTION_TYPE,
    PERIOD_CATEGORY_ID,
    TEMPLATE_ID,
    START_DATE_TIME,
    END_DATE_TIME,
    WHOLE_DAY_FLAG,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_EXCEPTION_ID,
    X_OBJECT_VERSION_NUMBER,
    X_EXCEPTION_GROUP,
    X_EXCEPTION_TYPE,
    X_PERIOD_CATEGORY_ID,
    X_TEMPLATE_ID,
    X_START_DATE_TIME,
    X_END_DATE_TIME,
    X_WHOLE_DAY_FLAG,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into CAC_SR_EXCEPTIONS_TL (
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    EXCEPTION_NAME,
    EXCEPTION_DESC,
    EXCEPTION_ID,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    X_CREATED_BY,
    X_EXCEPTION_NAME,
    X_EXCEPTION_DESC,
    X_EXCEPTION_ID,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from CAC_SR_EXCEPTIONS_TL T
    where T.EXCEPTION_ID = X_EXCEPTION_ID
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
  X_EXCEPTION_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_EXCEPTION_GROUP in VARCHAR2,
  X_EXCEPTION_TYPE in VARCHAR2,
  X_PERIOD_CATEGORY_ID in NUMBER,
  X_TEMPLATE_ID in NUMBER,
  X_START_DATE_TIME in DATE,
  X_END_DATE_TIME in DATE,
  X_WHOLE_DAY_FLAG in VARCHAR2,
  X_EXCEPTION_NAME in VARCHAR2,
  X_EXCEPTION_DESC in VARCHAR2
) is
  cursor c is select
      OBJECT_VERSION_NUMBER,
      EXCEPTION_GROUP,
      EXCEPTION_TYPE,
      PERIOD_CATEGORY_ID,
      TEMPLATE_ID,
      START_DATE_TIME,
      END_DATE_TIME,
      WHOLE_DAY_FLAG
    from CAC_SR_EXCEPTIONS_B
    where EXCEPTION_ID = X_EXCEPTION_ID
    for update of EXCEPTION_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      EXCEPTION_NAME,
      EXCEPTION_DESC,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from CAC_SR_EXCEPTIONS_TL
    where EXCEPTION_ID = X_EXCEPTION_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of EXCEPTION_ID nowait;
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
      AND ((recinfo.EXCEPTION_GROUP = X_EXCEPTION_GROUP)
           OR ((recinfo.EXCEPTION_GROUP is null) AND (X_EXCEPTION_GROUP is null)))
      AND (recinfo.EXCEPTION_TYPE = X_EXCEPTION_TYPE)
      AND ((recinfo.PERIOD_CATEGORY_ID = X_PERIOD_CATEGORY_ID)
           OR ((recinfo.PERIOD_CATEGORY_ID is null) AND (X_PERIOD_CATEGORY_ID is null)))
      AND ((recinfo.TEMPLATE_ID = X_TEMPLATE_ID)
           OR ((recinfo.TEMPLATE_ID is null) AND (X_TEMPLATE_ID is null)))
      AND (recinfo.START_DATE_TIME = X_START_DATE_TIME)
      AND (recinfo.END_DATE_TIME = X_END_DATE_TIME)
      AND ((recinfo.WHOLE_DAY_FLAG = X_WHOLE_DAY_FLAG)
           OR ((recinfo.WHOLE_DAY_FLAG is null) AND (X_WHOLE_DAY_FLAG is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.EXCEPTION_NAME = X_EXCEPTION_NAME)
          AND ((tlinfo.EXCEPTION_DESC = X_EXCEPTION_DESC)
               OR ((tlinfo.EXCEPTION_DESC is null) AND (X_EXCEPTION_DESC is null)))
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
  X_EXCEPTION_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_EXCEPTION_GROUP in VARCHAR2,
  X_EXCEPTION_TYPE in VARCHAR2,
  X_PERIOD_CATEGORY_ID in NUMBER,
  X_TEMPLATE_ID in NUMBER,
  X_START_DATE_TIME in DATE,
  X_END_DATE_TIME in DATE,
  X_WHOLE_DAY_FLAG in VARCHAR2,
  X_EXCEPTION_NAME in VARCHAR2,
  X_EXCEPTION_DESC in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update CAC_SR_EXCEPTIONS_B set
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    EXCEPTION_GROUP = X_EXCEPTION_GROUP,
    EXCEPTION_TYPE = X_EXCEPTION_TYPE,
    PERIOD_CATEGORY_ID = X_PERIOD_CATEGORY_ID,
    TEMPLATE_ID = X_TEMPLATE_ID,
    START_DATE_TIME = X_START_DATE_TIME,
    END_DATE_TIME = X_END_DATE_TIME,
    WHOLE_DAY_FLAG = X_WHOLE_DAY_FLAG,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where EXCEPTION_ID = X_EXCEPTION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update CAC_SR_EXCEPTIONS_TL set
    EXCEPTION_NAME = X_EXCEPTION_NAME,
    EXCEPTION_DESC = X_EXCEPTION_DESC,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where EXCEPTION_ID = X_EXCEPTION_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_EXCEPTION_ID in NUMBER
) is
begin
  delete from CAC_SR_EXCEPTIONS_TL
  where EXCEPTION_ID = X_EXCEPTION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from CAC_SR_EXCEPTIONS_B
  where EXCEPTION_ID = X_EXCEPTION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from CAC_SR_EXCEPTIONS_TL T
  where not exists
    (select NULL
    from CAC_SR_EXCEPTIONS_B B
    where B.EXCEPTION_ID = T.EXCEPTION_ID
    );

  update CAC_SR_EXCEPTIONS_TL T set (
      EXCEPTION_NAME,
      EXCEPTION_DESC
    ) = (select
      B.EXCEPTION_NAME,
      B.EXCEPTION_DESC
    from CAC_SR_EXCEPTIONS_TL B
    where B.EXCEPTION_ID = T.EXCEPTION_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.EXCEPTION_ID,
      T.LANGUAGE
  ) in (select
      SUBT.EXCEPTION_ID,
      SUBT.LANGUAGE
    from CAC_SR_EXCEPTIONS_TL SUBB, CAC_SR_EXCEPTIONS_TL SUBT
    where SUBB.EXCEPTION_ID = SUBT.EXCEPTION_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.EXCEPTION_NAME <> SUBT.EXCEPTION_NAME
      or SUBB.EXCEPTION_DESC <> SUBT.EXCEPTION_DESC
      or (SUBB.EXCEPTION_DESC is null and SUBT.EXCEPTION_DESC is not null)
      or (SUBB.EXCEPTION_DESC is not null and SUBT.EXCEPTION_DESC is null)
  ));

  insert into CAC_SR_EXCEPTIONS_TL (
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    EXCEPTION_NAME,
    EXCEPTION_DESC,
    EXCEPTION_ID,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.CREATED_BY,
    B.EXCEPTION_NAME,
    B.EXCEPTION_DESC,
    B.EXCEPTION_ID,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from CAC_SR_EXCEPTIONS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from CAC_SR_EXCEPTIONS_TL T
    where T.EXCEPTION_ID = B.EXCEPTION_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end CAC_SR_EXCEPTIONS_PKG;

/
