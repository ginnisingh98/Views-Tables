--------------------------------------------------------
--  DDL for Package Body QPR_REPORT_TYPE_HDRS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QPR_REPORT_TYPE_HDRS_PKG" as
/* $Header: QPRURTHB.pls 120.0 2007/12/24 20:06:41 vinnaray noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_REPORT_TYPE_HEADER_ID in NUMBER,
  X_REPORT_DOMAIN_CODE in VARCHAR2,
  X_REPORT_LINE_MERGE_CODE in VARCHAR2,
  X_USER_ID in NUMBER,
  X_PLAN_ID in NUMBER,
  X_REPORT_OPTIONS in CLOB,
  X_REPORT_TYPE_NAME in VARCHAR2,
  X_REPORT_TYPE_TITLE in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from QPR_REPORT_TYPE_HDRS_B
    where REPORT_TYPE_HEADER_ID = X_REPORT_TYPE_HEADER_ID
    ;
begin
  insert into QPR_REPORT_TYPE_HDRS_B (
    REPORT_TYPE_HEADER_ID,
    REPORT_DOMAIN_CODE,
    REPORT_LINE_MERGE_CODE,
    USER_ID,
    PLAN_ID,
    REPORT_OPTIONS,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_REPORT_TYPE_HEADER_ID,
    X_REPORT_DOMAIN_CODE,
    X_REPORT_LINE_MERGE_CODE,
    X_USER_ID,
    X_PLAN_ID,
    X_REPORT_OPTIONS,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into QPR_REPORT_TYPE_HDRS_TL (
    REPORT_TYPE_HEADER_ID,
    REPORT_TYPE_NAME,
    REPORT_TYPE_TITLE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_REPORT_TYPE_HEADER_ID,
    X_REPORT_TYPE_NAME,
    X_REPORT_TYPE_TITLE,
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
    from QPR_REPORT_TYPE_HDRS_TL T
    where T.REPORT_TYPE_HEADER_ID = X_REPORT_TYPE_HEADER_ID
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
  X_REPORT_TYPE_HEADER_ID in NUMBER,
  X_REPORT_DOMAIN_CODE in VARCHAR2,
  X_REPORT_LINE_MERGE_CODE in VARCHAR2,
  X_USER_ID in NUMBER,
  X_PLAN_ID in NUMBER,
  X_REPORT_OPTIONS in CLOB,
  X_REPORT_TYPE_NAME in VARCHAR2,
  X_REPORT_TYPE_TITLE in VARCHAR2
) is
  cursor c is select
      REPORT_DOMAIN_CODE,
      REPORT_LINE_MERGE_CODE,
      USER_ID,
      PLAN_ID,
      REPORT_OPTIONS
    from QPR_REPORT_TYPE_HDRS_B
    where REPORT_TYPE_HEADER_ID = X_REPORT_TYPE_HEADER_ID
    for update of REPORT_TYPE_HEADER_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      REPORT_TYPE_NAME,
      REPORT_TYPE_TITLE,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from QPR_REPORT_TYPE_HDRS_TL
    where REPORT_TYPE_HEADER_ID = X_REPORT_TYPE_HEADER_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of REPORT_TYPE_HEADER_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.REPORT_DOMAIN_CODE = X_REPORT_DOMAIN_CODE)
           OR ((recinfo.REPORT_DOMAIN_CODE is null) AND (X_REPORT_DOMAIN_CODE is null)))
      AND ((recinfo.REPORT_LINE_MERGE_CODE = X_REPORT_LINE_MERGE_CODE)
           OR ((recinfo.REPORT_LINE_MERGE_CODE is null) AND (X_REPORT_LINE_MERGE_CODE is null)))
      AND ((recinfo.USER_ID = X_USER_ID)
           OR ((recinfo.USER_ID is null) AND (X_USER_ID is null)))
      AND ((recinfo.PLAN_ID = X_PLAN_ID)
           OR ((recinfo.PLAN_ID is null) AND (X_PLAN_ID is null)))
      AND ((recinfo.REPORT_OPTIONS = X_REPORT_OPTIONS)
           OR ((recinfo.REPORT_OPTIONS is null) AND (X_REPORT_OPTIONS is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.REPORT_TYPE_NAME = X_REPORT_TYPE_NAME)
               OR ((tlinfo.REPORT_TYPE_NAME is null) AND (X_REPORT_TYPE_NAME is null)))
          AND ((tlinfo.REPORT_TYPE_TITLE = X_REPORT_TYPE_TITLE)
               OR ((tlinfo.REPORT_TYPE_TITLE is null) AND (X_REPORT_TYPE_TITLE is null)))
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
  X_REPORT_TYPE_HEADER_ID in NUMBER,
  X_REPORT_DOMAIN_CODE in VARCHAR2,
  X_REPORT_LINE_MERGE_CODE in VARCHAR2,
  X_USER_ID in NUMBER,
  X_PLAN_ID in NUMBER,
  X_REPORT_OPTIONS in CLOB,
  X_REPORT_TYPE_NAME in VARCHAR2,
  X_REPORT_TYPE_TITLE in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update QPR_REPORT_TYPE_HDRS_B set
    REPORT_DOMAIN_CODE = X_REPORT_DOMAIN_CODE,
    REPORT_LINE_MERGE_CODE = X_REPORT_LINE_MERGE_CODE,
    USER_ID = X_USER_ID,
    PLAN_ID = X_PLAN_ID,
    REPORT_OPTIONS = X_REPORT_OPTIONS,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where REPORT_TYPE_HEADER_ID = X_REPORT_TYPE_HEADER_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update QPR_REPORT_TYPE_HDRS_TL set
    REPORT_TYPE_NAME = X_REPORT_TYPE_NAME,
    REPORT_TYPE_TITLE = X_REPORT_TYPE_TITLE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where REPORT_TYPE_HEADER_ID = X_REPORT_TYPE_HEADER_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_REPORT_TYPE_HEADER_ID in NUMBER
) is
begin
  delete from QPR_REPORT_TYPE_HDRS_TL
  where REPORT_TYPE_HEADER_ID = X_REPORT_TYPE_HEADER_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from QPR_REPORT_TYPE_HDRS_B
  where REPORT_TYPE_HEADER_ID = X_REPORT_TYPE_HEADER_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from QPR_REPORT_TYPE_HDRS_TL T
  where not exists
    (select NULL
    from QPR_REPORT_TYPE_HDRS_B B
    where B.REPORT_TYPE_HEADER_ID = T.REPORT_TYPE_HEADER_ID
    );

  update QPR_REPORT_TYPE_HDRS_TL T set (
      REPORT_TYPE_NAME,
      REPORT_TYPE_TITLE
    ) = (select
      B.REPORT_TYPE_NAME,
      B.REPORT_TYPE_TITLE
    from QPR_REPORT_TYPE_HDRS_TL B
    where B.REPORT_TYPE_HEADER_ID = T.REPORT_TYPE_HEADER_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.REPORT_TYPE_HEADER_ID,
      T.LANGUAGE
  ) in (select
      SUBT.REPORT_TYPE_HEADER_ID,
      SUBT.LANGUAGE
    from QPR_REPORT_TYPE_HDRS_TL SUBB, QPR_REPORT_TYPE_HDRS_TL SUBT
    where SUBB.REPORT_TYPE_HEADER_ID = SUBT.REPORT_TYPE_HEADER_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.REPORT_TYPE_NAME <> SUBT.REPORT_TYPE_NAME
      or (SUBB.REPORT_TYPE_NAME is null and SUBT.REPORT_TYPE_NAME is not null)
      or (SUBB.REPORT_TYPE_NAME is not null and SUBT.REPORT_TYPE_NAME is null)
      or SUBB.REPORT_TYPE_TITLE <> SUBT.REPORT_TYPE_TITLE
      or (SUBB.REPORT_TYPE_TITLE is null and SUBT.REPORT_TYPE_TITLE is not null)
      or (SUBB.REPORT_TYPE_TITLE is not null and SUBT.REPORT_TYPE_TITLE is null)
  ));

  insert into QPR_REPORT_TYPE_HDRS_TL (
    REPORT_TYPE_HEADER_ID,
    REPORT_TYPE_NAME,
    REPORT_TYPE_TITLE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.REPORT_TYPE_HEADER_ID,
    B.REPORT_TYPE_NAME,
    B.REPORT_TYPE_TITLE,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from QPR_REPORT_TYPE_HDRS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from QPR_REPORT_TYPE_HDRS_TL T
    where T.REPORT_TYPE_HEADER_ID = B.REPORT_TYPE_HEADER_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end QPR_REPORT_TYPE_HDRS_PKG;

/
