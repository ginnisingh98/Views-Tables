--------------------------------------------------------
--  DDL for Package Body QPR_TRANSF_HEADERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QPR_TRANSF_HEADERS_PKG" as
/* $Header: QPRUTRHB.pls 120.0 2007/12/24 20:07:54 vinnaray noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_TRANSF_HEADER_ID in NUMBER,
  X_TRANSF_GROUP_ID in NUMBER,
  X_FROM_DIM_MEAS_CODE in VARCHAR2,
  X_FROM_DIM_HIER_CODE in VARCHAR2,
  X_LIMIT_DIM_FLAG in VARCHAR2,
  X_FROM_LEVEL_ID in NUMBER,
  X_MEAS_CODE in VARCHAR2,
  X_TO_DIM_CODE in VARCHAR2,
  X_TO_HIER_CODE in VARCHAR2,
  X_TO_LEVEL_ID in NUMBER,
  X_TO_VALUE in VARCHAR2,
  X_TO_VALUE_DESC in VARCHAR2,
  X_PROGRAM_LOGIN_ID in NUMBER,
  X_REQUEST_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from QPR_TRANSF_HEADERS_B
    where TRANSF_HEADER_ID = X_TRANSF_HEADER_ID
    ;
begin
  insert into QPR_TRANSF_HEADERS_B (
    TRANSF_GROUP_ID,
    FROM_DIM_MEAS_CODE,
    FROM_DIM_HIER_CODE,
    LIMIT_DIM_FLAG,
    FROM_LEVEL_ID,
    MEAS_CODE,
    TO_DIM_CODE,
    TO_HIER_CODE,
    TO_LEVEL_ID,
    TO_VALUE,
    TO_VALUE_DESC,
    PROGRAM_LOGIN_ID,
    REQUEST_ID,
    TRANSF_HEADER_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_TRANSF_GROUP_ID,
    X_FROM_DIM_MEAS_CODE,
    X_FROM_DIM_HIER_CODE,
    X_LIMIT_DIM_FLAG,
    X_FROM_LEVEL_ID,
    X_MEAS_CODE,
    X_TO_DIM_CODE,
    X_TO_HIER_CODE,
    X_TO_LEVEL_ID,
    X_TO_VALUE,
    X_TO_VALUE_DESC,
    X_PROGRAM_LOGIN_ID,
    X_REQUEST_ID,
    X_TRANSF_HEADER_ID,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into QPR_TRANSF_HEADERS_TL (
    TRANSF_HEADER_ID,
    NAME,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    --PROGRAM_ID,
    PROGRAM_LOGIN_ID,
    --PROGRAM_APPLICATION_ID,
    REQUEST_ID,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_TRANSF_HEADER_ID,
    X_NAME,
    X_DESCRIPTION,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    --X_PROGRAM_ID,
    X_PROGRAM_LOGIN_ID,
    --X_PROGRAM_APPLICATION_ID,
    X_REQUEST_ID,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from QPR_TRANSF_HEADERS_TL T
    where T.TRANSF_HEADER_ID = X_TRANSF_HEADER_ID
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
  X_TRANSF_HEADER_ID in NUMBER,
  X_TRANSF_GROUP_ID in NUMBER,
  X_FROM_DIM_MEAS_CODE in VARCHAR2,
  X_FROM_DIM_HIER_CODE in VARCHAR2,
  X_LIMIT_DIM_FLAG in VARCHAR2,
  X_FROM_LEVEL_ID in NUMBER,
  X_MEAS_CODE in VARCHAR2,
  X_TO_DIM_CODE in VARCHAR2,
  X_TO_HIER_CODE in VARCHAR2,
  X_TO_LEVEL_ID in NUMBER,
  X_TO_VALUE in VARCHAR2,
  X_TO_VALUE_DESC in VARCHAR2,
  X_PROGRAM_LOGIN_ID in NUMBER,
  X_REQUEST_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      TRANSF_GROUP_ID,
      FROM_DIM_MEAS_CODE,
      FROM_DIM_HIER_CODE,
      LIMIT_DIM_FLAG,
      FROM_LEVEL_ID,
      MEAS_CODE,
      TO_DIM_CODE,
      TO_HIER_CODE,
      TO_LEVEL_ID,
      TO_VALUE,
      TO_VALUE_DESC,
      PROGRAM_LOGIN_ID,
      REQUEST_ID
    from QPR_TRANSF_HEADERS_B
    where TRANSF_HEADER_ID = X_TRANSF_HEADER_ID
    for update of TRANSF_HEADER_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from QPR_TRANSF_HEADERS_TL
    where TRANSF_HEADER_ID = X_TRANSF_HEADER_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of TRANSF_HEADER_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.TRANSF_GROUP_ID = X_TRANSF_GROUP_ID)
      AND ((recinfo.FROM_DIM_MEAS_CODE = X_FROM_DIM_MEAS_CODE)
           OR ((recinfo.FROM_DIM_MEAS_CODE is null) AND (X_FROM_DIM_MEAS_CODE is null)))
      AND ((recinfo.FROM_DIM_HIER_CODE = X_FROM_DIM_HIER_CODE)
           OR ((recinfo.FROM_DIM_HIER_CODE is null) AND (X_FROM_DIM_HIER_CODE is null)))
      AND ((recinfo.LIMIT_DIM_FLAG = X_LIMIT_DIM_FLAG)
           OR ((recinfo.LIMIT_DIM_FLAG is null) AND (X_LIMIT_DIM_FLAG is null)))
      AND ((recinfo.FROM_LEVEL_ID = X_FROM_LEVEL_ID)
           OR ((recinfo.FROM_LEVEL_ID is null) AND (X_FROM_LEVEL_ID is null)))
      AND ((recinfo.MEAS_CODE = X_MEAS_CODE)
           OR ((recinfo.MEAS_CODE is null) AND (X_MEAS_CODE is null)))
      AND ((recinfo.TO_DIM_CODE = X_TO_DIM_CODE)
           OR ((recinfo.TO_DIM_CODE is null) AND (X_TO_DIM_CODE is null)))
      AND ((recinfo.TO_HIER_CODE = X_TO_HIER_CODE)
           OR ((recinfo.TO_HIER_CODE is null) AND (X_TO_HIER_CODE is null)))
      AND ((recinfo.TO_LEVEL_ID = X_TO_LEVEL_ID)
           OR ((recinfo.TO_LEVEL_ID is null) AND (X_TO_LEVEL_ID is null)))
      AND ((recinfo.TO_VALUE = X_TO_VALUE)
           OR ((recinfo.TO_VALUE is null) AND (X_TO_VALUE is null)))
      AND ((recinfo.TO_VALUE_DESC = X_TO_VALUE_DESC)
           OR ((recinfo.TO_VALUE_DESC is null) AND (X_TO_VALUE_DESC is null)))
      AND ((recinfo.PROGRAM_LOGIN_ID = X_PROGRAM_LOGIN_ID)
           OR ((recinfo.PROGRAM_LOGIN_ID is null) AND (X_PROGRAM_LOGIN_ID is null)))
      AND ((recinfo.REQUEST_ID = X_REQUEST_ID)
           OR ((recinfo.REQUEST_ID is null) AND (X_REQUEST_ID is null)))
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
  X_TRANSF_HEADER_ID in NUMBER,
  X_TRANSF_GROUP_ID in NUMBER,
  X_FROM_DIM_MEAS_CODE in VARCHAR2,
  X_FROM_DIM_HIER_CODE in VARCHAR2,
  X_LIMIT_DIM_FLAG in VARCHAR2,
  X_FROM_LEVEL_ID in NUMBER,
  X_MEAS_CODE in VARCHAR2,
  X_TO_DIM_CODE in VARCHAR2,
  X_TO_HIER_CODE in VARCHAR2,
  X_TO_LEVEL_ID in NUMBER,
  X_TO_VALUE in VARCHAR2,
  X_TO_VALUE_DESC in VARCHAR2,
  X_PROGRAM_LOGIN_ID in NUMBER,
  X_REQUEST_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update QPR_TRANSF_HEADERS_B set
    TRANSF_GROUP_ID = X_TRANSF_GROUP_ID,
    FROM_DIM_MEAS_CODE = X_FROM_DIM_MEAS_CODE,
    FROM_DIM_HIER_CODE = X_FROM_DIM_HIER_CODE,
    LIMIT_DIM_FLAG = X_LIMIT_DIM_FLAG,
    FROM_LEVEL_ID = X_FROM_LEVEL_ID,
    MEAS_CODE = X_MEAS_CODE,
    TO_DIM_CODE = X_TO_DIM_CODE,
    TO_HIER_CODE = X_TO_HIER_CODE,
    TO_LEVEL_ID = X_TO_LEVEL_ID,
    TO_VALUE = X_TO_VALUE,
    TO_VALUE_DESC = X_TO_VALUE_DESC,
    PROGRAM_LOGIN_ID = X_PROGRAM_LOGIN_ID,
    REQUEST_ID = X_REQUEST_ID,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where TRANSF_HEADER_ID = X_TRANSF_HEADER_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update QPR_TRANSF_HEADERS_TL set
    NAME = X_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where TRANSF_HEADER_ID = X_TRANSF_HEADER_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_TRANSF_HEADER_ID in NUMBER
) is
begin
  delete from QPR_TRANSF_HEADERS_TL
  where TRANSF_HEADER_ID = X_TRANSF_HEADER_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from QPR_TRANSF_HEADERS_B
  where TRANSF_HEADER_ID = X_TRANSF_HEADER_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from QPR_TRANSF_HEADERS_TL T
  where not exists
    (select NULL
    from QPR_TRANSF_HEADERS_B B
    where B.TRANSF_HEADER_ID = T.TRANSF_HEADER_ID
    );

  update QPR_TRANSF_HEADERS_TL T set (
      NAME,
      DESCRIPTION
    ) = (select
      B.NAME,
      B.DESCRIPTION
    from QPR_TRANSF_HEADERS_TL B
    where B.TRANSF_HEADER_ID = T.TRANSF_HEADER_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.TRANSF_HEADER_ID,
      T.LANGUAGE
  ) in (select
      SUBT.TRANSF_HEADER_ID,
      SUBT.LANGUAGE
    from QPR_TRANSF_HEADERS_TL SUBB, QPR_TRANSF_HEADERS_TL SUBT
    where SUBB.TRANSF_HEADER_ID = SUBT.TRANSF_HEADER_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into QPR_TRANSF_HEADERS_TL (
    TRANSF_HEADER_ID,
    NAME,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    PROGRAM_ID,
    PROGRAM_LOGIN_ID,
    PROGRAM_APPLICATION_ID,
    REQUEST_ID,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.TRANSF_HEADER_ID,
    B.NAME,
    B.DESCRIPTION,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.PROGRAM_ID,
    B.PROGRAM_LOGIN_ID,
    B.PROGRAM_APPLICATION_ID,
    B.REQUEST_ID,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from QPR_TRANSF_HEADERS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from QPR_TRANSF_HEADERS_TL T
    where T.TRANSF_HEADER_ID = B.TRANSF_HEADER_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end QPR_TRANSF_HEADERS_PKG;

/
