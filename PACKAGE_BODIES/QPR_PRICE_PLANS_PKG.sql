--------------------------------------------------------
--  DDL for Package Body QPR_PRICE_PLANS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QPR_PRICE_PLANS_PKG" as
/* $Header: QPRUPPLB.pls 120.0 2007/12/24 20:04:00 vinnaray noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_PRICE_PLAN_ID in NUMBER,
  X_REQUEST_ID in NUMBER,
  X_PROGRAM_LOGIN_ID in NUMBER,
  X_INSTANCE_ID in NUMBER,
  X_AW_TYPE_CODE in VARCHAR2,
  X_AW_STATUS_CODE in VARCHAR2,
  X_TEMPLATE_FLAG in VARCHAR2,
  X_SEEDED_FLAG in VARCHAR2,
  X_AW_CODE in VARCHAR2,
  X_AW_CREATED_FLAG in VARCHAR2,
  X_START_DATE in DATE,
  X_END_DATE in DATE,
  X_BASE_UOM_CODE in VARCHAR2,
  X_USE_FOR_DEAL_FLAG in VARCHAR2,
  X_CURRENCY_CODE in VARCHAR2,
  X_AW_XML in CLOB,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from QPR_PRICE_PLANS_B
    where PRICE_PLAN_ID = X_PRICE_PLAN_ID
    ;
begin
  insert into QPR_PRICE_PLANS_B (
    REQUEST_ID,
    PROGRAM_LOGIN_ID,
    PRICE_PLAN_ID,
    INSTANCE_ID,
    AW_TYPE_CODE,
    AW_STATUS_CODE,
    TEMPLATE_FLAG,
    SEEDED_FLAG,
    AW_CODE,
    AW_CREATED_FLAG,
    START_DATE,
    END_DATE,
    BASE_UOM_CODE,
    USE_FOR_DEAL_FLAG,
    CURRENCY_CODE,
    AW_XML,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_REQUEST_ID,
    X_PROGRAM_LOGIN_ID,
    X_PRICE_PLAN_ID,
    X_INSTANCE_ID,
    X_AW_TYPE_CODE,
    X_AW_STATUS_CODE,
    X_TEMPLATE_FLAG,
    X_SEEDED_FLAG,
    X_AW_CODE,
    X_AW_CREATED_FLAG,
    X_START_DATE,
    X_END_DATE,
    X_BASE_UOM_CODE,
    X_USE_FOR_DEAL_FLAG,
    X_CURRENCY_CODE,
    X_AW_XML,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into QPR_PRICE_PLANS_TL (
    NAME,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    REQUEST_ID,
    PRICE_PLAN_ID,
    LAST_UPDATE_LOGIN,
    --PROGRAM_ID,
    --PROGRAM_LOGIN_ID,
    --PROGRAM_APPLICATION_ID,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_NAME,
    X_DESCRIPTION,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_REQUEST_ID,
    X_PRICE_PLAN_ID,
    X_LAST_UPDATE_LOGIN,
    --X_PROGRAM_ID,
    --X_PROGRAM_LOGIN_ID,
    --X_PROGRAM_APPLICATION_ID,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from QPR_PRICE_PLANS_TL T
    where T.PRICE_PLAN_ID = X_PRICE_PLAN_ID
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
  X_PRICE_PLAN_ID in NUMBER,
  X_REQUEST_ID in NUMBER,
  X_PROGRAM_LOGIN_ID in NUMBER,
  X_INSTANCE_ID in NUMBER,
  X_AW_TYPE_CODE in VARCHAR2,
  X_AW_STATUS_CODE in VARCHAR2,
  X_TEMPLATE_FLAG in VARCHAR2,
  X_SEEDED_FLAG in VARCHAR2,
  X_AW_CODE in VARCHAR2,
  X_AW_CREATED_FLAG in VARCHAR2,
  X_START_DATE in DATE,
  X_END_DATE in DATE,
  X_BASE_UOM_CODE in VARCHAR2,
  X_USE_FOR_DEAL_FLAG in VARCHAR2,
  X_CURRENCY_CODE in VARCHAR2,
  X_AW_XML in CLOB,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      REQUEST_ID,
      PROGRAM_LOGIN_ID,
      INSTANCE_ID,
      AW_TYPE_CODE,
      AW_STATUS_CODE,
      TEMPLATE_FLAG,
      SEEDED_FLAG,
      AW_CODE,
      AW_CREATED_FLAG,
      START_DATE,
      END_DATE,
      BASE_UOM_CODE,
      USE_FOR_DEAL_FLAG,
      CURRENCY_CODE,
      AW_XML
    from QPR_PRICE_PLANS_B
    where PRICE_PLAN_ID = X_PRICE_PLAN_ID
    for update of PRICE_PLAN_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from QPR_PRICE_PLANS_TL
    where PRICE_PLAN_ID = X_PRICE_PLAN_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of PRICE_PLAN_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.REQUEST_ID = X_REQUEST_ID)
           OR ((recinfo.REQUEST_ID is null) AND (X_REQUEST_ID is null)))
      AND ((recinfo.PROGRAM_LOGIN_ID = X_PROGRAM_LOGIN_ID)
           OR ((recinfo.PROGRAM_LOGIN_ID is null) AND (X_PROGRAM_LOGIN_ID is null)))
      AND (recinfo.INSTANCE_ID = X_INSTANCE_ID)
      AND (recinfo.AW_TYPE_CODE = X_AW_TYPE_CODE)
      AND ((recinfo.AW_STATUS_CODE = X_AW_STATUS_CODE)
           OR ((recinfo.AW_STATUS_CODE is null) AND (X_AW_STATUS_CODE is null)))
      AND ((recinfo.TEMPLATE_FLAG = X_TEMPLATE_FLAG)
           OR ((recinfo.TEMPLATE_FLAG is null) AND (X_TEMPLATE_FLAG is null)))
      AND ((recinfo.SEEDED_FLAG = X_SEEDED_FLAG)
           OR ((recinfo.SEEDED_FLAG is null) AND (X_SEEDED_FLAG is null)))
      AND ((recinfo.AW_CODE = X_AW_CODE)
           OR ((recinfo.AW_CODE is null) AND (X_AW_CODE is null)))
      AND ((recinfo.AW_CREATED_FLAG = X_AW_CREATED_FLAG)
           OR ((recinfo.AW_CREATED_FLAG is null) AND (X_AW_CREATED_FLAG is null)))
      AND ((recinfo.START_DATE = X_START_DATE)
           OR ((recinfo.START_DATE is null) AND (X_START_DATE is null)))
      AND ((recinfo.END_DATE = X_END_DATE)
           OR ((recinfo.END_DATE is null) AND (X_END_DATE is null)))
      AND ((recinfo.BASE_UOM_CODE = X_BASE_UOM_CODE)
           OR ((recinfo.BASE_UOM_CODE is null) AND (X_BASE_UOM_CODE is null)))
      AND ((recinfo.USE_FOR_DEAL_FLAG = X_USE_FOR_DEAL_FLAG)
           OR ((recinfo.USE_FOR_DEAL_FLAG is null) AND (X_USE_FOR_DEAL_FLAG is null)))
      AND ((recinfo.CURRENCY_CODE = X_CURRENCY_CODE)
           OR ((recinfo.CURRENCY_CODE is null) AND (X_CURRENCY_CODE is null)))
      AND (recinfo.AW_XML = X_AW_XML)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.NAME = X_NAME)
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
  X_PRICE_PLAN_ID in NUMBER,
  X_REQUEST_ID in NUMBER,
  X_PROGRAM_LOGIN_ID in NUMBER,
  X_INSTANCE_ID in NUMBER,
  X_AW_TYPE_CODE in VARCHAR2,
  X_AW_STATUS_CODE in VARCHAR2,
  X_TEMPLATE_FLAG in VARCHAR2,
  X_SEEDED_FLAG in VARCHAR2,
  X_AW_CODE in VARCHAR2,
  X_AW_CREATED_FLAG in VARCHAR2,
  X_START_DATE in DATE,
  X_END_DATE in DATE,
  X_BASE_UOM_CODE in VARCHAR2,
  X_USE_FOR_DEAL_FLAG in VARCHAR2,
  X_CURRENCY_CODE in VARCHAR2,
  X_AW_XML in CLOB,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update QPR_PRICE_PLANS_B set
    REQUEST_ID = X_REQUEST_ID,
    PROGRAM_LOGIN_ID = X_PROGRAM_LOGIN_ID,
    INSTANCE_ID = X_INSTANCE_ID,
    AW_TYPE_CODE = X_AW_TYPE_CODE,
    AW_STATUS_CODE = X_AW_STATUS_CODE,
    TEMPLATE_FLAG = X_TEMPLATE_FLAG,
    SEEDED_FLAG = X_SEEDED_FLAG,
    AW_CODE = X_AW_CODE,
    AW_CREATED_FLAG = X_AW_CREATED_FLAG,
    START_DATE = X_START_DATE,
    END_DATE = X_END_DATE,
    BASE_UOM_CODE = X_BASE_UOM_CODE,
    USE_FOR_DEAL_FLAG = X_USE_FOR_DEAL_FLAG,
    CURRENCY_CODE = X_CURRENCY_CODE,
    AW_XML = X_AW_XML,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where PRICE_PLAN_ID = X_PRICE_PLAN_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update QPR_PRICE_PLANS_TL set
    NAME = X_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where PRICE_PLAN_ID = X_PRICE_PLAN_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_PRICE_PLAN_ID in NUMBER
) is
begin
  delete from QPR_PRICE_PLANS_TL
  where PRICE_PLAN_ID = X_PRICE_PLAN_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from QPR_PRICE_PLANS_B
  where PRICE_PLAN_ID = X_PRICE_PLAN_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from QPR_PRICE_PLANS_TL T
  where not exists
    (select NULL
    from QPR_PRICE_PLANS_B B
    where B.PRICE_PLAN_ID = T.PRICE_PLAN_ID
    );

  update QPR_PRICE_PLANS_TL T set (
      NAME,
      DESCRIPTION
    ) = (select
      B.NAME,
      B.DESCRIPTION
    from QPR_PRICE_PLANS_TL B
    where B.PRICE_PLAN_ID = T.PRICE_PLAN_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.PRICE_PLAN_ID,
      T.LANGUAGE
  ) in (select
      SUBT.PRICE_PLAN_ID,
      SUBT.LANGUAGE
    from QPR_PRICE_PLANS_TL SUBB, QPR_PRICE_PLANS_TL SUBT
    where SUBB.PRICE_PLAN_ID = SUBT.PRICE_PLAN_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into QPR_PRICE_PLANS_TL (
    NAME,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    REQUEST_ID,
    PRICE_PLAN_ID,
    LAST_UPDATE_LOGIN,
    PROGRAM_ID,
    PROGRAM_LOGIN_ID,
    PROGRAM_APPLICATION_ID,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.NAME,
    B.DESCRIPTION,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.REQUEST_ID,
    B.PRICE_PLAN_ID,
    B.LAST_UPDATE_LOGIN,
    B.PROGRAM_ID,
    B.PROGRAM_LOGIN_ID,
    B.PROGRAM_APPLICATION_ID,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from QPR_PRICE_PLANS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from QPR_PRICE_PLANS_TL T
    where T.PRICE_PLAN_ID = B.PRICE_PLAN_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end QPR_PRICE_PLANS_PKG;

/
