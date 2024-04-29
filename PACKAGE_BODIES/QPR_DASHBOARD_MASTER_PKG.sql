--------------------------------------------------------
--  DDL for Package Body QPR_DASHBOARD_MASTER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QPR_DASHBOARD_MASTER_PKG" as
/* $Header: QPRUDBMB.pls 120.0 2007/12/24 20:02:09 vinnaray noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_DASHBOARD_ID in NUMBER,
  X_REQUEST_ID in NUMBER,
  X_USER_ID in NUMBER,
  X_PLAN_ID in VARCHAR2,
  X_DASHBOARD_TYPE in VARCHAR2,
  X_DEFAULT_FLAG in VARCHAR2,
  X_SOURCE_TEMPLATE_ID in NUMBER,
  X_PROGRAM_LOGIN_ID in NUMBER,
  X_DASHBOARD_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from QPR_DASHBOARD_MASTER_B
    where DASHBOARD_ID = X_DASHBOARD_ID
    ;
begin
  insert into QPR_DASHBOARD_MASTER_B (
    REQUEST_ID,
    DASHBOARD_ID,
    USER_ID,
    PLAN_ID,
    DASHBOARD_TYPE,
    DEFAULT_FLAG,
    SOURCE_TEMPLATE_ID,
    PROGRAM_LOGIN_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_REQUEST_ID,
    X_DASHBOARD_ID,
    X_USER_ID,
    X_PLAN_ID,
    X_DASHBOARD_TYPE,
    X_DEFAULT_FLAG,
    X_SOURCE_TEMPLATE_ID,
    X_PROGRAM_LOGIN_ID,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into QPR_DASHBOARD_MASTER_TL (
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    DASHBOARD_ID,
    DASHBOARD_NAME,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_DASHBOARD_ID,
    X_DASHBOARD_NAME,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from QPR_DASHBOARD_MASTER_TL T
    where T.DASHBOARD_ID = X_DASHBOARD_ID
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
  X_DASHBOARD_ID in NUMBER,
  X_REQUEST_ID in NUMBER,
  X_USER_ID in NUMBER,
  X_PLAN_ID in VARCHAR2,
  X_DASHBOARD_TYPE in VARCHAR2,
  X_DEFAULT_FLAG in VARCHAR2,
  X_SOURCE_TEMPLATE_ID in NUMBER,
  X_PROGRAM_LOGIN_ID in NUMBER,
  X_DASHBOARD_NAME in VARCHAR2
) is
  cursor c is select
      REQUEST_ID,
      USER_ID,
      PLAN_ID,
      DASHBOARD_TYPE,
      DEFAULT_FLAG,
      SOURCE_TEMPLATE_ID,
      PROGRAM_LOGIN_ID
    from QPR_DASHBOARD_MASTER_B
    where DASHBOARD_ID = X_DASHBOARD_ID
    for update of DASHBOARD_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      DASHBOARD_NAME,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from QPR_DASHBOARD_MASTER_TL
    where DASHBOARD_ID = X_DASHBOARD_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of DASHBOARD_ID nowait;
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
      AND ((recinfo.USER_ID = X_USER_ID)
           OR ((recinfo.USER_ID is null) AND (X_USER_ID is null)))
      AND ((recinfo.PLAN_ID = X_PLAN_ID)
           OR ((recinfo.PLAN_ID is null) AND (X_PLAN_ID is null)))
      AND (recinfo.DASHBOARD_TYPE = X_DASHBOARD_TYPE)
      AND (recinfo.DEFAULT_FLAG = X_DEFAULT_FLAG)
      AND ((recinfo.SOURCE_TEMPLATE_ID = X_SOURCE_TEMPLATE_ID)
           OR ((recinfo.SOURCE_TEMPLATE_ID is null) AND (X_SOURCE_TEMPLATE_ID is null)))
      AND ((recinfo.PROGRAM_LOGIN_ID = X_PROGRAM_LOGIN_ID)
           OR ((recinfo.PROGRAM_LOGIN_ID is null) AND (X_PROGRAM_LOGIN_ID is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.DASHBOARD_NAME = X_DASHBOARD_NAME)
               OR ((tlinfo.DASHBOARD_NAME is null) AND (X_DASHBOARD_NAME is null)))
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
  X_DASHBOARD_ID in NUMBER,
  X_REQUEST_ID in NUMBER,
  X_USER_ID in NUMBER,
  X_PLAN_ID in VARCHAR2,
  X_DASHBOARD_TYPE in VARCHAR2,
  X_DEFAULT_FLAG in VARCHAR2,
  X_SOURCE_TEMPLATE_ID in NUMBER,
  X_PROGRAM_LOGIN_ID in NUMBER,
  X_DASHBOARD_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update QPR_DASHBOARD_MASTER_B set
    REQUEST_ID = X_REQUEST_ID,
    USER_ID = X_USER_ID,
    PLAN_ID = X_PLAN_ID,
    DASHBOARD_TYPE = X_DASHBOARD_TYPE,
    DEFAULT_FLAG = X_DEFAULT_FLAG,
    SOURCE_TEMPLATE_ID = X_SOURCE_TEMPLATE_ID,
    PROGRAM_LOGIN_ID = X_PROGRAM_LOGIN_ID,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where DASHBOARD_ID = X_DASHBOARD_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update QPR_DASHBOARD_MASTER_TL set
    DASHBOARD_NAME = X_DASHBOARD_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where DASHBOARD_ID = X_DASHBOARD_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_DASHBOARD_ID in NUMBER
) is
begin
  delete from QPR_DASHBOARD_MASTER_TL
  where DASHBOARD_ID = X_DASHBOARD_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from QPR_DASHBOARD_MASTER_B
  where DASHBOARD_ID = X_DASHBOARD_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from QPR_DASHBOARD_MASTER_TL T
  where not exists
    (select NULL
    from QPR_DASHBOARD_MASTER_B B
    where B.DASHBOARD_ID = T.DASHBOARD_ID
    );

  update QPR_DASHBOARD_MASTER_TL T set (
      DASHBOARD_NAME
    ) = (select
      B.DASHBOARD_NAME
    from QPR_DASHBOARD_MASTER_TL B
    where B.DASHBOARD_ID = T.DASHBOARD_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.DASHBOARD_ID,
      T.LANGUAGE
  ) in (select
      SUBT.DASHBOARD_ID,
      SUBT.LANGUAGE
    from QPR_DASHBOARD_MASTER_TL SUBB, QPR_DASHBOARD_MASTER_TL SUBT
    where SUBB.DASHBOARD_ID = SUBT.DASHBOARD_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DASHBOARD_NAME <> SUBT.DASHBOARD_NAME
      or (SUBB.DASHBOARD_NAME is null and SUBT.DASHBOARD_NAME is not null)
      or (SUBB.DASHBOARD_NAME is not null and SUBT.DASHBOARD_NAME is null)
  ));

  insert into QPR_DASHBOARD_MASTER_TL (
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    DASHBOARD_ID,
    DASHBOARD_NAME,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.DASHBOARD_ID,
    B.DASHBOARD_NAME,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from QPR_DASHBOARD_MASTER_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from QPR_DASHBOARD_MASTER_TL T
    where T.DASHBOARD_ID = B.DASHBOARD_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end QPR_DASHBOARD_MASTER_PKG;

/
