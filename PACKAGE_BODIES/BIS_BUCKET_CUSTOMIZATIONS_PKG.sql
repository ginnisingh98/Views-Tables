--------------------------------------------------------
--  DDL for Package Body BIS_BUCKET_CUSTOMIZATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_BUCKET_CUSTOMIZATIONS_PKG" as
/* $Header: BISPBUCB.pls 115.1 2004/02/15 21:55:32 ankgoel noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_ID in NUMBER,
  X_RANGE8_HIGH in NUMBER,
  X_RANGE9_LOW in NUMBER,
  X_RANGE9_HIGH in NUMBER,
  X_RANGE10_LOW in NUMBER,
  X_RANGE10_HIGH in NUMBER,
  X_CUSTOMIZED in VARCHAR2,
  X_RANGE7_LOW in NUMBER,
  X_RANGE7_HIGH in NUMBER,
  X_RANGE8_LOW in NUMBER,
  X_BUCKET_ID in NUMBER,
  X_USER_ID in NUMBER,
  X_RESPONSIBILITY_ID in NUMBER,
  X_APPLICATION_ID in NUMBER,
  X_ORG_ID in NUMBER,
  X_SITE_ID in NUMBER,
  X_PAGE_ID in NUMBER,
  X_FUNCTION_ID in NUMBER,
  X_RANGE1_LOW in NUMBER,
  X_RANGE1_HIGH in NUMBER,
  X_RANGE2_LOW in NUMBER,
  X_RANGE2_HIGH in NUMBER,
  X_RANGE3_LOW in NUMBER,
  X_RANGE3_HIGH in NUMBER,
  X_RANGE4_LOW in NUMBER,
  X_RANGE4_HIGH in NUMBER,
  X_RANGE5_LOW in NUMBER,
  X_RANGE5_HIGH in NUMBER,
  X_RANGE6_LOW in NUMBER,
  X_RANGE6_HIGH in NUMBER,
  X_RANGE1_NAME in VARCHAR2,
  X_RANGE2_NAME in VARCHAR2,
  X_RANGE3_NAME in VARCHAR2,
  X_RANGE4_NAME in VARCHAR2,
  X_RANGE5_NAME in VARCHAR2,
  X_RANGE6_NAME in VARCHAR2,
  X_RANGE7_NAME in VARCHAR2,
  X_RANGE8_NAME in VARCHAR2,
  X_RANGE9_NAME in VARCHAR2,
  X_RANGE10_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from BIS_BUCKET_CUSTOMIZATIONS
    where ID = X_ID
    ;
begin
  insert into BIS_BUCKET_CUSTOMIZATIONS (
    RANGE8_HIGH,
    RANGE9_LOW,
    RANGE9_HIGH,
    RANGE10_LOW,
    RANGE10_HIGH,
    CUSTOMIZED,
    RANGE7_LOW,
    RANGE7_HIGH,
    RANGE8_LOW,
    ID,
    BUCKET_ID,
    USER_ID,
    RESPONSIBILITY_ID,
    APPLICATION_ID,
    ORG_ID,
    SITE_ID,
    PAGE_ID,
    FUNCTION_ID,
    RANGE1_LOW,
    RANGE1_HIGH,
    RANGE2_LOW,
    RANGE2_HIGH,
    RANGE3_LOW,
    RANGE3_HIGH,
    RANGE4_LOW,
    RANGE4_HIGH,
    RANGE5_LOW,
    RANGE5_HIGH,
    RANGE6_LOW,
    RANGE6_HIGH,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_RANGE8_HIGH,
    X_RANGE9_LOW,
    X_RANGE9_HIGH,
    X_RANGE10_LOW,
    X_RANGE10_HIGH,
    X_CUSTOMIZED,
    X_RANGE7_LOW,
    X_RANGE7_HIGH,
    X_RANGE8_LOW,
    X_ID,
    X_BUCKET_ID,
    X_USER_ID,
    X_RESPONSIBILITY_ID,
    X_APPLICATION_ID,
    X_ORG_ID,
    X_SITE_ID,
    X_PAGE_ID,
    X_FUNCTION_ID,
    X_RANGE1_LOW,
    X_RANGE1_HIGH,
    X_RANGE2_LOW,
    X_RANGE2_HIGH,
    X_RANGE3_LOW,
    X_RANGE3_HIGH,
    X_RANGE4_LOW,
    X_RANGE4_HIGH,
    X_RANGE5_LOW,
    X_RANGE5_HIGH,
    X_RANGE6_LOW,
    X_RANGE6_HIGH,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into BIS_BUCKET_CUSTOMIZATIONS_TL (
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    RANGE7_NAME,
    RANGE8_NAME,
    RANGE9_NAME,
    RANGE10_NAME,
    ID,
    RANGE1_NAME,
    RANGE2_NAME,
    RANGE3_NAME,
    RANGE4_NAME,
    RANGE5_NAME,
    RANGE6_NAME,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    X_RANGE7_NAME,
    X_RANGE8_NAME,
    X_RANGE9_NAME,
    X_RANGE10_NAME,
    X_ID,
    X_RANGE1_NAME,
    X_RANGE2_NAME,
    X_RANGE3_NAME,
    X_RANGE4_NAME,
    X_RANGE5_NAME,
    X_RANGE6_NAME,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from BIS_BUCKET_CUSTOMIZATIONS_TL T
    where T.ID = X_ID
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
  X_ID in NUMBER,
  X_RANGE8_HIGH in NUMBER,
  X_RANGE9_LOW in NUMBER,
  X_RANGE9_HIGH in NUMBER,
  X_RANGE10_LOW in NUMBER,
  X_RANGE10_HIGH in NUMBER,
  X_CUSTOMIZED in VARCHAR2,
  X_RANGE7_LOW in NUMBER,
  X_RANGE7_HIGH in NUMBER,
  X_RANGE8_LOW in NUMBER,
  X_BUCKET_ID in NUMBER,
  X_USER_ID in NUMBER,
  X_RESPONSIBILITY_ID in NUMBER,
  X_APPLICATION_ID in NUMBER,
  X_ORG_ID in NUMBER,
  X_SITE_ID in NUMBER,
  X_PAGE_ID in NUMBER,
  X_FUNCTION_ID in NUMBER,
  X_RANGE1_LOW in NUMBER,
  X_RANGE1_HIGH in NUMBER,
  X_RANGE2_LOW in NUMBER,
  X_RANGE2_HIGH in NUMBER,
  X_RANGE3_LOW in NUMBER,
  X_RANGE3_HIGH in NUMBER,
  X_RANGE4_LOW in NUMBER,
  X_RANGE4_HIGH in NUMBER,
  X_RANGE5_LOW in NUMBER,
  X_RANGE5_HIGH in NUMBER,
  X_RANGE6_LOW in NUMBER,
  X_RANGE6_HIGH in NUMBER,
  X_RANGE1_NAME in VARCHAR2,
  X_RANGE2_NAME in VARCHAR2,
  X_RANGE3_NAME in VARCHAR2,
  X_RANGE4_NAME in VARCHAR2,
  X_RANGE5_NAME in VARCHAR2,
  X_RANGE6_NAME in VARCHAR2,
  X_RANGE7_NAME in VARCHAR2,
  X_RANGE8_NAME in VARCHAR2,
  X_RANGE9_NAME in VARCHAR2,
  X_RANGE10_NAME in VARCHAR2
) is
  cursor c is select
      RANGE8_HIGH,
      RANGE9_LOW,
      RANGE9_HIGH,
      RANGE10_LOW,
      RANGE10_HIGH,
      CUSTOMIZED,
      RANGE7_LOW,
      RANGE7_HIGH,
      RANGE8_LOW,
      BUCKET_ID,
      USER_ID,
      RESPONSIBILITY_ID,
      APPLICATION_ID,
      ORG_ID,
      SITE_ID,
      PAGE_ID,
      FUNCTION_ID,
      RANGE1_LOW,
      RANGE1_HIGH,
      RANGE2_LOW,
      RANGE2_HIGH,
      RANGE3_LOW,
      RANGE3_HIGH,
      RANGE4_LOW,
      RANGE4_HIGH,
      RANGE5_LOW,
      RANGE5_HIGH,
      RANGE6_LOW,
      RANGE6_HIGH
    from BIS_BUCKET_CUSTOMIZATIONS
    where ID = X_ID
    for update of ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      RANGE1_NAME,
      RANGE2_NAME,
      RANGE3_NAME,
      RANGE4_NAME,
      RANGE5_NAME,
      RANGE6_NAME,
      RANGE7_NAME,
      RANGE8_NAME,
      RANGE9_NAME,
      RANGE10_NAME,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from BIS_BUCKET_CUSTOMIZATIONS_TL
    where ID = X_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.RANGE8_HIGH = X_RANGE8_HIGH)
           OR ((recinfo.RANGE8_HIGH is null) AND (X_RANGE8_HIGH is null)))
      AND ((recinfo.RANGE9_LOW = X_RANGE9_LOW)
           OR ((recinfo.RANGE9_LOW is null) AND (X_RANGE9_LOW is null)))
      AND ((recinfo.RANGE9_HIGH = X_RANGE9_HIGH)
           OR ((recinfo.RANGE9_HIGH is null) AND (X_RANGE9_HIGH is null)))
      AND ((recinfo.RANGE10_LOW = X_RANGE10_LOW)
           OR ((recinfo.RANGE10_LOW is null) AND (X_RANGE10_LOW is null)))
      AND ((recinfo.RANGE10_HIGH = X_RANGE10_HIGH)
           OR ((recinfo.RANGE10_HIGH is null) AND (X_RANGE10_HIGH is null)))
      AND ((recinfo.CUSTOMIZED = X_CUSTOMIZED)
           OR ((recinfo.CUSTOMIZED is null) AND (X_CUSTOMIZED is null)))
      AND ((recinfo.RANGE7_LOW = X_RANGE7_LOW)
           OR ((recinfo.RANGE7_LOW is null) AND (X_RANGE7_LOW is null)))
      AND ((recinfo.RANGE7_HIGH = X_RANGE7_HIGH)
           OR ((recinfo.RANGE7_HIGH is null) AND (X_RANGE7_HIGH is null)))
      AND ((recinfo.RANGE8_LOW = X_RANGE8_LOW)
           OR ((recinfo.RANGE8_LOW is null) AND (X_RANGE8_LOW is null)))
      AND (recinfo.BUCKET_ID = X_BUCKET_ID)
      AND ((recinfo.USER_ID = X_USER_ID)
           OR ((recinfo.USER_ID is null) AND (X_USER_ID is null)))
      AND ((recinfo.RESPONSIBILITY_ID = X_RESPONSIBILITY_ID)
           OR ((recinfo.RESPONSIBILITY_ID is null) AND (X_RESPONSIBILITY_ID is null)))
      AND ((recinfo.APPLICATION_ID = X_APPLICATION_ID)
           OR ((recinfo.APPLICATION_ID is null) AND (X_APPLICATION_ID is null)))
      AND ((recinfo.ORG_ID = X_ORG_ID)
                 OR ((recinfo.ORG_ID is null) AND (X_ORG_ID is null)))
      AND ((recinfo.SITE_ID = X_SITE_ID)
           OR ((recinfo.SITE_ID is null) AND (X_SITE_ID is null)))
      AND ((recinfo.PAGE_ID = X_PAGE_ID)
           OR ((recinfo.PAGE_ID is null) AND (X_PAGE_ID is null)))
      AND ((recinfo.FUNCTION_ID = X_FUNCTION_ID)
           OR ((recinfo.FUNCTION_ID is null) AND (X_FUNCTION_ID is null)))
      AND ((recinfo.RANGE1_LOW = X_RANGE1_LOW)
           OR ((recinfo.RANGE1_LOW is null) AND (X_RANGE1_LOW is null)))
      AND ((recinfo.RANGE1_HIGH = X_RANGE1_HIGH)
           OR ((recinfo.RANGE1_HIGH is null) AND (X_RANGE1_HIGH is null)))
      AND ((recinfo.RANGE2_LOW = X_RANGE2_LOW)
           OR ((recinfo.RANGE2_LOW is null) AND (X_RANGE2_LOW is null)))
      AND ((recinfo.RANGE2_HIGH = X_RANGE2_HIGH)
           OR ((recinfo.RANGE2_HIGH is null) AND (X_RANGE2_HIGH is null)))
      AND ((recinfo.RANGE3_LOW = X_RANGE3_LOW)
           OR ((recinfo.RANGE3_LOW is null) AND (X_RANGE3_LOW is null)))
      AND ((recinfo.RANGE3_HIGH = X_RANGE3_HIGH)
           OR ((recinfo.RANGE3_HIGH is null) AND (X_RANGE3_HIGH is null)))
      AND ((recinfo.RANGE4_LOW = X_RANGE4_LOW)
           OR ((recinfo.RANGE4_LOW is null) AND (X_RANGE4_LOW is null)))
      AND ((recinfo.RANGE4_HIGH = X_RANGE4_HIGH)
           OR ((recinfo.RANGE4_HIGH is null) AND (X_RANGE4_HIGH is null)))
      AND ((recinfo.RANGE5_LOW = X_RANGE5_LOW)
           OR ((recinfo.RANGE5_LOW is null) AND (X_RANGE5_LOW is null)))
      AND ((recinfo.RANGE5_HIGH = X_RANGE5_HIGH)
           OR ((recinfo.RANGE5_HIGH is null) AND (X_RANGE5_HIGH is null)))
      AND ((recinfo.RANGE6_LOW = X_RANGE6_LOW)
           OR ((recinfo.RANGE6_LOW is null) AND (X_RANGE6_LOW is null)))
      AND ((recinfo.RANGE6_HIGH = X_RANGE6_HIGH)
           OR ((recinfo.RANGE6_HIGH is null) AND (X_RANGE6_HIGH is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.RANGE1_NAME = X_RANGE1_NAME)
               OR ((tlinfo.RANGE1_NAME is null) AND (X_RANGE1_NAME is null)))
          AND ((tlinfo.RANGE2_NAME = X_RANGE2_NAME)
               OR ((tlinfo.RANGE2_NAME is null) AND (X_RANGE2_NAME is null)))
          AND ((tlinfo.RANGE3_NAME = X_RANGE3_NAME)
               OR ((tlinfo.RANGE3_NAME is null) AND (X_RANGE3_NAME is null)))
          AND ((tlinfo.RANGE4_NAME = X_RANGE4_NAME)
               OR ((tlinfo.RANGE4_NAME is null) AND (X_RANGE4_NAME is null)))
          AND ((tlinfo.RANGE5_NAME = X_RANGE5_NAME)
               OR ((tlinfo.RANGE5_NAME is null) AND (X_RANGE5_NAME is null)))
          AND ((tlinfo.RANGE6_NAME = X_RANGE6_NAME)
               OR ((tlinfo.RANGE6_NAME is null) AND (X_RANGE6_NAME is null)))
          AND ((tlinfo.RANGE7_NAME = X_RANGE7_NAME)
               OR ((tlinfo.RANGE7_NAME is null) AND (X_RANGE7_NAME is null)))
          AND ((tlinfo.RANGE8_NAME = X_RANGE8_NAME)
               OR ((tlinfo.RANGE8_NAME is null) AND (X_RANGE8_NAME is null)))
          AND ((tlinfo.RANGE9_NAME = X_RANGE9_NAME)
               OR ((tlinfo.RANGE9_NAME is null) AND (X_RANGE9_NAME is null)))
          AND ((tlinfo.RANGE10_NAME = X_RANGE10_NAME)
               OR ((tlinfo.RANGE10_NAME is null) AND (X_RANGE10_NAME is null)))
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
  X_ID in NUMBER,
  X_RANGE8_HIGH in NUMBER,
  X_RANGE9_LOW in NUMBER,
  X_RANGE9_HIGH in NUMBER,
  X_RANGE10_LOW in NUMBER,
  X_RANGE10_HIGH in NUMBER,
  X_CUSTOMIZED in VARCHAR2,
  X_RANGE7_LOW in NUMBER,
  X_RANGE7_HIGH in NUMBER,
  X_RANGE8_LOW in NUMBER,
  X_BUCKET_ID in NUMBER,
  X_USER_ID in NUMBER,
  X_RESPONSIBILITY_ID in NUMBER,
  X_APPLICATION_ID in NUMBER,
  X_ORG_ID in NUMBER,
  X_SITE_ID in NUMBER,
  X_PAGE_ID in NUMBER,
  X_FUNCTION_ID in NUMBER,
  X_RANGE1_LOW in NUMBER,
  X_RANGE1_HIGH in NUMBER,
  X_RANGE2_LOW in NUMBER,
  X_RANGE2_HIGH in NUMBER,
  X_RANGE3_LOW in NUMBER,
  X_RANGE3_HIGH in NUMBER,
  X_RANGE4_LOW in NUMBER,
  X_RANGE4_HIGH in NUMBER,
  X_RANGE5_LOW in NUMBER,
  X_RANGE5_HIGH in NUMBER,
  X_RANGE6_LOW in NUMBER,
  X_RANGE6_HIGH in NUMBER,
  X_RANGE1_NAME in VARCHAR2,
  X_RANGE2_NAME in VARCHAR2,
  X_RANGE3_NAME in VARCHAR2,
  X_RANGE4_NAME in VARCHAR2,
  X_RANGE5_NAME in VARCHAR2,
  X_RANGE6_NAME in VARCHAR2,
  X_RANGE7_NAME in VARCHAR2,
  X_RANGE8_NAME in VARCHAR2,
  X_RANGE9_NAME in VARCHAR2,
  X_RANGE10_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update BIS_BUCKET_CUSTOMIZATIONS set
    RANGE8_HIGH = X_RANGE8_HIGH,
    RANGE9_LOW = X_RANGE9_LOW,
    RANGE9_HIGH = X_RANGE9_HIGH,
    RANGE10_LOW = X_RANGE10_LOW,
    RANGE10_HIGH = X_RANGE10_HIGH,
    CUSTOMIZED = X_CUSTOMIZED,
    RANGE7_LOW = X_RANGE7_LOW,
    RANGE7_HIGH = X_RANGE7_HIGH,
    RANGE8_LOW = X_RANGE8_LOW,
    BUCKET_ID = X_BUCKET_ID,
    USER_ID = X_USER_ID,
    RESPONSIBILITY_ID = X_RESPONSIBILITY_ID,
    APPLICATION_ID = X_APPLICATION_ID,
    ORG_ID = X_ORG_ID,
    SITE_ID = X_SITE_ID,
    PAGE_ID = X_PAGE_ID,
    FUNCTION_ID = X_FUNCTION_ID,
    RANGE1_LOW = X_RANGE1_LOW,
    RANGE1_HIGH = X_RANGE1_HIGH,
    RANGE2_LOW = X_RANGE2_LOW,
    RANGE2_HIGH = X_RANGE2_HIGH,
    RANGE3_LOW = X_RANGE3_LOW,
    RANGE3_HIGH = X_RANGE3_HIGH,
    RANGE4_LOW = X_RANGE4_LOW,
    RANGE4_HIGH = X_RANGE4_HIGH,
    RANGE5_LOW = X_RANGE5_LOW,
    RANGE5_HIGH = X_RANGE5_HIGH,
    RANGE6_LOW = X_RANGE6_LOW,
    RANGE6_HIGH = X_RANGE6_HIGH,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ID = X_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update BIS_BUCKET_CUSTOMIZATIONS_TL set
    RANGE1_NAME = X_RANGE1_NAME,
    RANGE2_NAME = X_RANGE2_NAME,
    RANGE3_NAME = X_RANGE3_NAME,
    RANGE4_NAME = X_RANGE4_NAME,
    RANGE5_NAME = X_RANGE5_NAME,
    RANGE6_NAME = X_RANGE6_NAME,
    RANGE7_NAME = X_RANGE7_NAME,
    RANGE8_NAME = X_RANGE8_NAME,
    RANGE9_NAME = X_RANGE9_NAME,
    RANGE10_NAME = X_RANGE10_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where ID = X_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_ID in NUMBER
) is
begin
  delete from BIS_BUCKET_CUSTOMIZATIONS_TL
  where ID = X_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from BIS_BUCKET_CUSTOMIZATIONS
  where ID = X_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from BIS_BUCKET_CUSTOMIZATIONS_TL T
  where not exists
    (select NULL
    from BIS_BUCKET_CUSTOMIZATIONS B
    where B.ID = T.ID
    );

  update BIS_BUCKET_CUSTOMIZATIONS_TL T set (
      RANGE1_NAME,
      RANGE2_NAME,
      RANGE3_NAME,
      RANGE4_NAME,
      RANGE5_NAME,
      RANGE6_NAME,
      RANGE7_NAME,
      RANGE8_NAME,
      RANGE9_NAME,
      RANGE10_NAME
    ) = (select
      B.RANGE1_NAME,
      B.RANGE2_NAME,
      B.RANGE3_NAME,
      B.RANGE4_NAME,
      B.RANGE5_NAME,
      B.RANGE6_NAME,
      B.RANGE7_NAME,
      B.RANGE8_NAME,
      B.RANGE9_NAME,
      B.RANGE10_NAME
    from BIS_BUCKET_CUSTOMIZATIONS_TL B
    where B.ID = T.ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.ID,
      T.LANGUAGE
  ) in (select
      SUBT.ID,
      SUBT.LANGUAGE
    from BIS_BUCKET_CUSTOMIZATIONS_TL SUBB, BIS_BUCKET_CUSTOMIZATIONS_TL SUBT
    where SUBB.ID = SUBT.ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.RANGE1_NAME <> SUBT.RANGE1_NAME
      or (SUBB.RANGE1_NAME is null and SUBT.RANGE1_NAME is not null)
      or (SUBB.RANGE1_NAME is not null and SUBT.RANGE1_NAME is null)
      or SUBB.RANGE2_NAME <> SUBT.RANGE2_NAME
      or (SUBB.RANGE2_NAME is null and SUBT.RANGE2_NAME is not null)
      or (SUBB.RANGE2_NAME is not null and SUBT.RANGE2_NAME is null)
      or SUBB.RANGE3_NAME <> SUBT.RANGE3_NAME
      or (SUBB.RANGE3_NAME is null and SUBT.RANGE3_NAME is not null)
      or (SUBB.RANGE3_NAME is not null and SUBT.RANGE3_NAME is null)
      or SUBB.RANGE4_NAME <> SUBT.RANGE4_NAME
      or (SUBB.RANGE4_NAME is null and SUBT.RANGE4_NAME is not null)
      or (SUBB.RANGE4_NAME is not null and SUBT.RANGE4_NAME is null)
      or SUBB.RANGE5_NAME <> SUBT.RANGE5_NAME
      or (SUBB.RANGE5_NAME is null and SUBT.RANGE5_NAME is not null)
      or (SUBB.RANGE5_NAME is not null and SUBT.RANGE5_NAME is null)
      or SUBB.RANGE6_NAME <> SUBT.RANGE6_NAME
      or (SUBB.RANGE6_NAME is null and SUBT.RANGE6_NAME is not null)
      or (SUBB.RANGE6_NAME is not null and SUBT.RANGE6_NAME is null)
      or SUBB.RANGE7_NAME <> SUBT.RANGE7_NAME
      or (SUBB.RANGE7_NAME is null and SUBT.RANGE7_NAME is not null)
      or (SUBB.RANGE7_NAME is not null and SUBT.RANGE7_NAME is null)
      or SUBB.RANGE8_NAME <> SUBT.RANGE8_NAME
      or (SUBB.RANGE8_NAME is null and SUBT.RANGE8_NAME is not null)
      or (SUBB.RANGE8_NAME is not null and SUBT.RANGE8_NAME is null)
      or SUBB.RANGE9_NAME <> SUBT.RANGE9_NAME
      or (SUBB.RANGE9_NAME is null and SUBT.RANGE9_NAME is not null)
      or (SUBB.RANGE9_NAME is not null and SUBT.RANGE9_NAME is null)
      or SUBB.RANGE10_NAME <> SUBT.RANGE10_NAME
      or (SUBB.RANGE10_NAME is null and SUBT.RANGE10_NAME is not null)
      or (SUBB.RANGE10_NAME is not null and SUBT.RANGE10_NAME is null)
  ));

  insert into BIS_BUCKET_CUSTOMIZATIONS_TL (
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    RANGE7_NAME,
    RANGE8_NAME,
    RANGE9_NAME,
    RANGE10_NAME,
    ID,
    RANGE1_NAME,
    RANGE2_NAME,
    RANGE3_NAME,
    RANGE4_NAME,
    RANGE5_NAME,
    RANGE6_NAME,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.RANGE7_NAME,
    B.RANGE8_NAME,
    B.RANGE9_NAME,
    B.RANGE10_NAME,
    B.ID,
    B.RANGE1_NAME,
    B.RANGE2_NAME,
    B.RANGE3_NAME,
    B.RANGE4_NAME,
    B.RANGE5_NAME,
    B.RANGE6_NAME,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from BIS_BUCKET_CUSTOMIZATIONS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from BIS_BUCKET_CUSTOMIZATIONS_TL T
    where T.ID = B.ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end BIS_BUCKET_CUSTOMIZATIONS_PKG;

/
