--------------------------------------------------------
--  DDL for Package Body BSC_SYS_DATASETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_SYS_DATASETS_PKG" as
/* $Header: BSCDSETB.pls 120.0 2005/06/01 17:03:43 appldev noship $ */
procedure INSERT_ROW (
  X_DATASET_ID in NUMBER,
  X_PROJECTION_FLAG in NUMBER,
  X_MEASURE_ID1 in NUMBER,
  X_OPERATION in VARCHAR2,
  X_MEASURE_ID2 in NUMBER,
  X_FORMAT_ID in NUMBER,
  X_COLOR_METHOD in NUMBER,
  X_NAME in VARCHAR2,
  X_HELP in VARCHAR2,
  X_CREATION_DATE in DATE       DEFAULT NULL,
  X_CREATED_BY in NUMBER        DEFAULT NULL,
  X_LAST_UPDATE_DATE in DATE    DEFAULT NULL,
  X_LAST_UPDATED_BY in NUMBER   DEFAULT NULL,
  X_LAST_UPDATE_LOGIN in NUMBER DEFAULT NULL
) is
begin
  insert into BSC_SYS_DATASETS_B (
    PROJECTION_FLAG,
    DATASET_ID,
    MEASURE_ID1,
    OPERATION,
    MEASURE_ID2,
    FORMAT_ID,
    COLOR_METHOD,
    CREATION_DATE ,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY ,
    LAST_UPDATE_LOGIN
  ) values (
    X_PROJECTION_FLAG,
    X_DATASET_ID,
    X_MEASURE_ID1,
    X_OPERATION,
    X_MEASURE_ID2,
    X_FORMAT_ID,
    X_COLOR_METHOD,
    X_CREATION_DATE ,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY ,
    X_LAST_UPDATE_LOGIN
  );

  insert into BSC_SYS_DATASETS_TL (
    DATASET_ID,
    NAME,
    HELP,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_DATASET_ID,
    X_NAME,
    X_HELP,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from BSC_SYS_DATASETS_TL T
    where T.DATASET_ID = X_DATASET_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

end INSERT_ROW;

procedure TRANSLATE_ROW(
  X_DATASET_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_HELP in VARCHAR2)
is
begin
  update BSC_SYS_DATASETS_TL set
        NAME = NVL(X_NAME,NAME),
        HELP = NVL(X_HELP, HELP),
        SOURCE_LANG = userenv('LANG')
 where
        userenv('LANG') in (LANGUAGE, SOURCE_LANG)
        and dataset_id = X_DATASET_ID;
end TRANSLATE_ROW;

procedure LOCK_ROW (
  X_DATASET_ID in NUMBER,
  X_PROJECTION_FLAG in NUMBER,
  X_MEASURE_ID1 in NUMBER,
  X_OPERATION in VARCHAR2,
  X_MEASURE_ID2 in NUMBER,
  X_FORMAT_ID in NUMBER,
  X_COLOR_METHOD in NUMBER,
  X_NAME in VARCHAR2,
  X_HELP in VARCHAR2
) is
  cursor c is select
      PROJECTION_FLAG,
      MEASURE_ID1,
      OPERATION,
      MEASURE_ID2,
      FORMAT_ID,
      COLOR_METHOD
    from BSC_SYS_DATASETS_B
    where DATASET_ID = X_DATASET_ID
    for update of DATASET_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      NAME,
      HELP,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from BSC_SYS_DATASETS_TL
    where DATASET_ID = X_DATASET_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of DATASET_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.PROJECTION_FLAG = X_PROJECTION_FLAG)
           OR ((recinfo.PROJECTION_FLAG is null) AND (X_PROJECTION_FLAG is null)))
      AND (recinfo.MEASURE_ID1 = X_MEASURE_ID1)
      AND ((recinfo.OPERATION = X_OPERATION)
           OR ((recinfo.OPERATION is null) AND (X_OPERATION is null)))
      AND ((recinfo.MEASURE_ID2 = X_MEASURE_ID2)
           OR ((recinfo.MEASURE_ID2 is null) AND (X_MEASURE_ID2 is null)))
      AND (recinfo.FORMAT_ID = X_FORMAT_ID)
      AND (recinfo.COLOR_METHOD = X_COLOR_METHOD)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.NAME = X_NAME)
          AND (tlinfo.HELP = X_HELP)
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
  X_DATASET_ID in NUMBER,
  X_PROJECTION_FLAG in NUMBER,
  X_MEASURE_ID1 in NUMBER,
  X_OPERATION in VARCHAR2,
  X_MEASURE_ID2 in NUMBER,
  X_FORMAT_ID in NUMBER,
  X_COLOR_METHOD in NUMBER,
  X_NAME in VARCHAR2,
  X_HELP in VARCHAR2,
  X_CREATION_DATE in DATE       DEFAULT NULL,
  X_CREATED_BY in NUMBER        DEFAULT NULL,
  X_LAST_UPDATE_DATE in DATE    DEFAULT NULL,
  X_LAST_UPDATED_BY in NUMBER   DEFAULT NULL,
  X_LAST_UPDATE_LOGIN in NUMBER DEFAULT NULL
) is
begin
  update BSC_SYS_DATASETS_B set
    PROJECTION_FLAG = X_PROJECTION_FLAG,
    MEASURE_ID1 = X_MEASURE_ID1,
    OPERATION = X_OPERATION,
    MEASURE_ID2 = X_MEASURE_ID2,
    FORMAT_ID = X_FORMAT_ID,
    COLOR_METHOD = X_COLOR_METHOD,
    LAST_UPDATE_DATE = DECODE(LAST_UPDATED_BY,1,X_LAST_UPDATE_DATE,LAST_UPDATE_DATE),
    LAST_UPDATED_BY = DECODE(LAST_UPDATED_BY,1,X_LAST_UPDATED_BY,LAST_UPDATED_BY),
    LAST_UPDATE_LOGIN = DECODE(LAST_UPDATED_BY,1,X_LAST_UPDATE_LOGIN,LAST_UPDATE_LOGIN)
  where DATASET_ID = X_DATASET_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update BSC_SYS_DATASETS_TL set
    NAME = X_NAME,
    HELP = X_HELP,
    SOURCE_LANG = userenv('LANG')
  where DATASET_ID = X_DATASET_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_DATASET_ID in NUMBER
) is
begin
  delete from BSC_SYS_DATASETS_TL
  where DATASET_ID = X_DATASET_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from BSC_SYS_DATASETS_B
  where DATASET_ID = X_DATASET_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from BSC_SYS_DATASETS_TL T
  where not exists
    (select NULL
    from BSC_SYS_DATASETS_B B
    where B.DATASET_ID = T.DATASET_ID
    );

  update BSC_SYS_DATASETS_TL T set (
      NAME,
      HELP,Y_AXIS_TITLE
    ) = (select
      B.NAME,
      B.HELP,B.Y_AXIS_TITLE
    from BSC_SYS_DATASETS_TL B
    where B.DATASET_ID = T.DATASET_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.DATASET_ID,
      T.LANGUAGE
  ) in (select
      SUBT.DATASET_ID,
      SUBT.LANGUAGE
    from BSC_SYS_DATASETS_TL SUBB, BSC_SYS_DATASETS_TL SUBT
    where SUBB.DATASET_ID = SUBT.DATASET_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or SUBB.HELP <> SUBT.HELP or SUBB.Y_AXIS_TITLE <> SUBT.Y_AXIS_TITLE
  ));

  insert into BSC_SYS_DATASETS_TL (
    DATASET_ID,
    NAME,
    HELP,
    Y_AXIS_TITLE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.DATASET_ID,
    B.NAME,
    B.HELP,
    B.Y_AXIS_TITLE,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from BSC_SYS_DATASETS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from BSC_SYS_DATASETS_TL T
    where T.DATASET_ID = B.DATASET_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end BSC_SYS_DATASETS_PKG;

/
