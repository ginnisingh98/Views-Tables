--------------------------------------------------------
--  DDL for Package Body CAC_SR_TEMPLATES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CAC_SR_TEMPLATES_PKG" as
/* $Header: cacsrtmplb.pls 120.1 2005/07/02 02:19:08 appldev noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_TEMPLATE_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_TEMPLATE_TYPE in VARCHAR2,
  X_TEMPLATE_LENGTH_DAYS in NUMBER,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_DELETED_DATE in DATE,
  X_TEMPLATE_NAME in VARCHAR2,
  X_TEMPLATE_DESC in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from CAC_SR_TEMPLATES_B
    where TEMPLATE_ID = X_TEMPLATE_ID
    ;
begin
  insert into CAC_SR_TEMPLATES_B (
    TEMPLATE_ID,
    OBJECT_VERSION_NUMBER,
    TEMPLATE_TYPE,
    TEMPLATE_LENGTH_DAYS,
    START_DATE_ACTIVE,
    END_DATE_ACTIVE,
    DELETED_DATE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_TEMPLATE_ID,
    X_OBJECT_VERSION_NUMBER,
    X_TEMPLATE_TYPE,
    X_TEMPLATE_LENGTH_DAYS,
    X_START_DATE_ACTIVE,
    X_END_DATE_ACTIVE,
    X_DELETED_DATE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into CAC_SR_TEMPLATES_TL (
    TEMPLATE_NAME,
    TEMPLATE_DESC,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    TEMPLATE_ID,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_TEMPLATE_NAME,
    X_TEMPLATE_DESC,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    X_TEMPLATE_ID,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from CAC_SR_TEMPLATES_TL T
    where T.TEMPLATE_ID = X_TEMPLATE_ID
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
  X_TEMPLATE_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_TEMPLATE_TYPE in VARCHAR2,
  X_TEMPLATE_LENGTH_DAYS in NUMBER,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_DELETED_DATE in DATE,
  X_TEMPLATE_NAME in VARCHAR2,
  X_TEMPLATE_DESC in VARCHAR2
) is
  cursor c is select
      OBJECT_VERSION_NUMBER,
      TEMPLATE_TYPE,
      TEMPLATE_LENGTH_DAYS,
      START_DATE_ACTIVE,
      END_DATE_ACTIVE,
      DELETED_DATE
    from CAC_SR_TEMPLATES_B
    where TEMPLATE_ID = X_TEMPLATE_ID
    for update of TEMPLATE_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      TEMPLATE_NAME,
      TEMPLATE_DESC,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from CAC_SR_TEMPLATES_TL
    where TEMPLATE_ID = X_TEMPLATE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of TEMPLATE_ID nowait;
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
      AND (recinfo.TEMPLATE_TYPE = X_TEMPLATE_TYPE)
      AND ((recinfo.TEMPLATE_LENGTH_DAYS = X_TEMPLATE_LENGTH_DAYS)
           OR ((recinfo.TEMPLATE_LENGTH_DAYS is null) AND (X_TEMPLATE_LENGTH_DAYS is null)))
      AND (recinfo.START_DATE_ACTIVE = X_START_DATE_ACTIVE)
      AND ((recinfo.END_DATE_ACTIVE = X_END_DATE_ACTIVE)
           OR ((recinfo.END_DATE_ACTIVE is null) AND (X_END_DATE_ACTIVE is null)))
      AND ((recinfo.DELETED_DATE = X_DELETED_DATE)
           OR ((recinfo.DELETED_DATE is null) AND (X_DELETED_DATE is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.TEMPLATE_NAME = X_TEMPLATE_NAME)
          AND ((tlinfo.TEMPLATE_DESC = X_TEMPLATE_DESC)
               OR ((tlinfo.TEMPLATE_DESC is null) AND (X_TEMPLATE_DESC is null)))
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
  X_TEMPLATE_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_TEMPLATE_TYPE in VARCHAR2,
  X_TEMPLATE_LENGTH_DAYS in NUMBER,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_DELETED_DATE in DATE,
  X_TEMPLATE_NAME in VARCHAR2,
  X_TEMPLATE_DESC in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update CAC_SR_TEMPLATES_B set
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    TEMPLATE_TYPE = X_TEMPLATE_TYPE,
    TEMPLATE_LENGTH_DAYS = X_TEMPLATE_LENGTH_DAYS,
    START_DATE_ACTIVE = X_START_DATE_ACTIVE,
    END_DATE_ACTIVE = X_END_DATE_ACTIVE,
    DELETED_DATE = X_DELETED_DATE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where TEMPLATE_ID = X_TEMPLATE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update CAC_SR_TEMPLATES_TL set
    TEMPLATE_NAME = X_TEMPLATE_NAME,
    TEMPLATE_DESC = X_TEMPLATE_DESC,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where TEMPLATE_ID = X_TEMPLATE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_TEMPLATE_ID in NUMBER
) is
begin
  delete from CAC_SR_TEMPLATES_TL
  where TEMPLATE_ID = X_TEMPLATE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from CAC_SR_TEMPLATES_B
  where TEMPLATE_ID = X_TEMPLATE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from CAC_SR_TEMPLATES_TL T
  where not exists
    (select NULL
    from CAC_SR_TEMPLATES_B B
    where B.TEMPLATE_ID = T.TEMPLATE_ID
    );

  update CAC_SR_TEMPLATES_TL T set (
      TEMPLATE_NAME,
      TEMPLATE_DESC
    ) = (select
      B.TEMPLATE_NAME,
      B.TEMPLATE_DESC
    from CAC_SR_TEMPLATES_TL B
    where B.TEMPLATE_ID = T.TEMPLATE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.TEMPLATE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.TEMPLATE_ID,
      SUBT.LANGUAGE
    from CAC_SR_TEMPLATES_TL SUBB, CAC_SR_TEMPLATES_TL SUBT
    where SUBB.TEMPLATE_ID = SUBT.TEMPLATE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.TEMPLATE_NAME <> SUBT.TEMPLATE_NAME
      or SUBB.TEMPLATE_DESC <> SUBT.TEMPLATE_DESC
      or (SUBB.TEMPLATE_DESC is null and SUBT.TEMPLATE_DESC is not null)
      or (SUBB.TEMPLATE_DESC is not null and SUBT.TEMPLATE_DESC is null)
  ));

  insert into CAC_SR_TEMPLATES_TL (
    TEMPLATE_NAME,
    TEMPLATE_DESC,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    TEMPLATE_ID,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.TEMPLATE_NAME,
    B.TEMPLATE_DESC,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.TEMPLATE_ID,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from CAC_SR_TEMPLATES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from CAC_SR_TEMPLATES_TL T
    where T.TEMPLATE_ID = B.TEMPLATE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end CAC_SR_TEMPLATES_PKG;

/
