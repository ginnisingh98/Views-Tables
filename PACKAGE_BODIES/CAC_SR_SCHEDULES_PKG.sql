--------------------------------------------------------
--  DDL for Package Body CAC_SR_SCHEDULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CAC_SR_SCHEDULES_PKG" as
/* $Header: cacsrschdlb.pls 120.1 2005/07/02 02:19:01 appldev noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_SCHEDULE_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_TEMPLATE_ID in NUMBER,
  X_TEMPLATE_OVN in NUMBER,
  X_SCHEDULE_CATEGORY in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_DELETED_DATE in DATE,
  X_SCHEDULE_NAME in VARCHAR2,
  X_SCHEDULE_DESC in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from CAC_SR_SCHEDULES_B
    where SCHEDULE_ID = X_SCHEDULE_ID
    ;
begin
  insert into CAC_SR_SCHEDULES_B (
    SCHEDULE_ID,
    OBJECT_VERSION_NUMBER,
    TEMPLATE_ID,
    TEMPLATE_OVN,
    SCHEDULE_CATEGORY,
    START_DATE_ACTIVE,
    END_DATE_ACTIVE,
    DELETED_DATE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_SCHEDULE_ID,
    X_OBJECT_VERSION_NUMBER,
    X_TEMPLATE_ID,
    X_TEMPLATE_OVN,
    X_SCHEDULE_CATEGORY,
    X_START_DATE_ACTIVE,
    X_END_DATE_ACTIVE,
    X_DELETED_DATE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into CAC_SR_SCHEDULES_TL (
    SCHEDULE_ID,
    SCHEDULE_NAME,
    SCHEDULE_DESC,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_SCHEDULE_ID,
    X_SCHEDULE_NAME,
    X_SCHEDULE_DESC,
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
    from CAC_SR_SCHEDULES_TL T
    where T.SCHEDULE_ID = X_SCHEDULE_ID
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
  X_SCHEDULE_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_TEMPLATE_ID in NUMBER,
  X_TEMPLATE_OVN in NUMBER,
  X_SCHEDULE_CATEGORY in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_DELETED_DATE in DATE,
  X_SCHEDULE_NAME in VARCHAR2,
  X_SCHEDULE_DESC in VARCHAR2
) is
  cursor c is select
      OBJECT_VERSION_NUMBER,
      TEMPLATE_ID,
      TEMPLATE_OVN,
      SCHEDULE_CATEGORY,
      START_DATE_ACTIVE,
      END_DATE_ACTIVE,
      DELETED_DATE
    from CAC_SR_SCHEDULES_B
    where SCHEDULE_ID = X_SCHEDULE_ID
    for update of SCHEDULE_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      SCHEDULE_NAME,
      SCHEDULE_DESC,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from CAC_SR_SCHEDULES_TL
    where SCHEDULE_ID = X_SCHEDULE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of SCHEDULE_ID nowait;
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
      AND (recinfo.TEMPLATE_ID = X_TEMPLATE_ID)
      AND (recinfo.TEMPLATE_OVN = X_TEMPLATE_OVN)
      AND (recinfo.SCHEDULE_CATEGORY = X_SCHEDULE_CATEGORY)
      AND (recinfo.START_DATE_ACTIVE = X_START_DATE_ACTIVE)
      AND (recinfo.END_DATE_ACTIVE = X_END_DATE_ACTIVE)
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
      if (    (tlinfo.SCHEDULE_NAME = X_SCHEDULE_NAME)
          AND ((tlinfo.SCHEDULE_DESC = X_SCHEDULE_DESC)
               OR ((tlinfo.SCHEDULE_DESC is null) AND (X_SCHEDULE_DESC is null)))
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
  X_SCHEDULE_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_TEMPLATE_ID in NUMBER,
  X_TEMPLATE_OVN in NUMBER,
  X_SCHEDULE_CATEGORY in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_DELETED_DATE in DATE,
  X_SCHEDULE_NAME in VARCHAR2,
  X_SCHEDULE_DESC in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update CAC_SR_SCHEDULES_B set
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    TEMPLATE_ID = X_TEMPLATE_ID,
    TEMPLATE_OVN = X_TEMPLATE_OVN,
    SCHEDULE_CATEGORY = X_SCHEDULE_CATEGORY,
    START_DATE_ACTIVE = X_START_DATE_ACTIVE,
    END_DATE_ACTIVE = X_END_DATE_ACTIVE,
    DELETED_DATE = X_DELETED_DATE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where SCHEDULE_ID = X_SCHEDULE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update CAC_SR_SCHEDULES_TL set
    SCHEDULE_NAME = X_SCHEDULE_NAME,
    SCHEDULE_DESC = X_SCHEDULE_DESC,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where SCHEDULE_ID = X_SCHEDULE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_SCHEDULE_ID in NUMBER
) is
begin
  delete from CAC_SR_SCHEDULES_TL
  where SCHEDULE_ID = X_SCHEDULE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from CAC_SR_SCHEDULES_B
  where SCHEDULE_ID = X_SCHEDULE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from CAC_SR_SCHEDULES_TL T
  where not exists
    (select NULL
    from CAC_SR_SCHEDULES_B B
    where B.SCHEDULE_ID = T.SCHEDULE_ID
    );

  update CAC_SR_SCHEDULES_TL T set (
      SCHEDULE_NAME,
      SCHEDULE_DESC
    ) = (select
      B.SCHEDULE_NAME,
      B.SCHEDULE_DESC
    from CAC_SR_SCHEDULES_TL B
    where B.SCHEDULE_ID = T.SCHEDULE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.SCHEDULE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.SCHEDULE_ID,
      SUBT.LANGUAGE
    from CAC_SR_SCHEDULES_TL SUBB, CAC_SR_SCHEDULES_TL SUBT
    where SUBB.SCHEDULE_ID = SUBT.SCHEDULE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.SCHEDULE_NAME <> SUBT.SCHEDULE_NAME
      or SUBB.SCHEDULE_DESC <> SUBT.SCHEDULE_DESC
      or (SUBB.SCHEDULE_DESC is null and SUBT.SCHEDULE_DESC is not null)
      or (SUBB.SCHEDULE_DESC is not null and SUBT.SCHEDULE_DESC is null)
  ));

  insert into CAC_SR_SCHEDULES_TL (
    SCHEDULE_ID,
    SCHEDULE_NAME,
    SCHEDULE_DESC,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.SCHEDULE_ID,
    B.SCHEDULE_NAME,
    B.SCHEDULE_DESC,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from CAC_SR_SCHEDULES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from CAC_SR_SCHEDULES_TL T
    where T.SCHEDULE_ID = B.SCHEDULE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end CAC_SR_SCHEDULES_PKG;

/
