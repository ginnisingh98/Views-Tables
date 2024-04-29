--------------------------------------------------------
--  DDL for Package Body BSC_SYS_DIM_LEVELS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_SYS_DIM_LEVELS_PKG" as
/* $Header: BSCSDMLB.pls 115.6 2003/02/12 14:29:16 adeulgao ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_DIM_LEVEL_ID in NUMBER,
  X_LEVEL_TABLE_NAME in VARCHAR2,
  X_TABLE_TYPE in NUMBER,
  X_LEVEL_PK_COL in VARCHAR2,
  X_ABBREVIATION in VARCHAR2,
  X_VALUE_ORDER_BY in NUMBER,
  X_COMP_ORDER_BY in NUMBER,
  X_CUSTOM_GROUP in NUMBER,
  X_USER_KEY_SIZE in NUMBER,
  X_DISP_KEY_SIZE in NUMBER,
  X_NAME in VARCHAR2,
  X_HELP in VARCHAR2,
  X_TOTAL_DISP_NAME in VARCHAR2,
  X_COMP_DISP_NAME in VARCHAR2
) is
  cursor C is select ROWID from BSC_SYS_DIM_LEVELS_B
    where DIM_LEVEL_ID = X_DIM_LEVEL_ID
    ;
begin
  insert into BSC_SYS_DIM_LEVELS_B (
    DIM_LEVEL_ID,
    LEVEL_TABLE_NAME,
    TABLE_TYPE,
    LEVEL_PK_COL,
    ABBREVIATION,
    VALUE_ORDER_BY,
    COMP_ORDER_BY,
    CUSTOM_GROUP,
    USER_KEY_SIZE,
    DISP_KEY_SIZE
  ) values (
    X_DIM_LEVEL_ID,
    X_LEVEL_TABLE_NAME,
    X_TABLE_TYPE,
    X_LEVEL_PK_COL,
    X_ABBREVIATION,
    X_VALUE_ORDER_BY,
    X_COMP_ORDER_BY,
    X_CUSTOM_GROUP,
    X_USER_KEY_SIZE,
    X_DISP_KEY_SIZE
  );

  insert into BSC_SYS_DIM_LEVELS_TL (
    DIM_LEVEL_ID,
    NAME,
    HELP,
    TOTAL_DISP_NAME,
    COMP_DISP_NAME,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_DIM_LEVEL_ID,
    X_NAME,
    X_HELP,
    X_TOTAL_DISP_NAME,
    X_COMP_DISP_NAME,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from BSC_SYS_DIM_LEVELS_TL T
    where T.DIM_LEVEL_ID = X_DIM_LEVEL_ID
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
  X_DIM_LEVEL_ID in NUMBER,
  X_LEVEL_TABLE_NAME in VARCHAR2,
  X_TABLE_TYPE in NUMBER,
  X_LEVEL_PK_COL in VARCHAR2,
  X_ABBREVIATION in VARCHAR2,
  X_VALUE_ORDER_BY in NUMBER,
  X_COMP_ORDER_BY in NUMBER,
  X_CUSTOM_GROUP in NUMBER,
  X_USER_KEY_SIZE in NUMBER,
  X_DISP_KEY_SIZE in NUMBER,
  X_NAME in VARCHAR2,
  X_HELP in VARCHAR2,
  X_TOTAL_DISP_NAME in VARCHAR2,
  X_COMP_DISP_NAME in VARCHAR2
) is
  cursor c is select
      LEVEL_TABLE_NAME,
      TABLE_TYPE,
      LEVEL_PK_COL,
      ABBREVIATION,
      VALUE_ORDER_BY,
      COMP_ORDER_BY,
      CUSTOM_GROUP,
      USER_KEY_SIZE,
      DISP_KEY_SIZE
    from BSC_SYS_DIM_LEVELS_B
    where DIM_LEVEL_ID = X_DIM_LEVEL_ID
    for update of DIM_LEVEL_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      NAME,
      HELP,
      TOTAL_DISP_NAME,
      COMP_DISP_NAME,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from BSC_SYS_DIM_LEVELS_TL
    where DIM_LEVEL_ID = X_DIM_LEVEL_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of DIM_LEVEL_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.LEVEL_TABLE_NAME = X_LEVEL_TABLE_NAME)
      AND (recinfo.TABLE_TYPE = X_TABLE_TYPE)
      AND (recinfo.LEVEL_PK_COL = X_LEVEL_PK_COL)
      AND (recinfo.ABBREVIATION = X_ABBREVIATION)
      AND (recinfo.VALUE_ORDER_BY = X_VALUE_ORDER_BY)
      AND (recinfo.COMP_ORDER_BY = X_COMP_ORDER_BY)
      AND (recinfo.CUSTOM_GROUP = X_CUSTOM_GROUP)
      AND (recinfo.USER_KEY_SIZE = X_USER_KEY_SIZE)
      AND (recinfo.DISP_KEY_SIZE = X_DISP_KEY_SIZE)
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
          AND ((tlinfo.TOTAL_DISP_NAME = X_TOTAL_DISP_NAME)
               OR ((tlinfo.TOTAL_DISP_NAME is null) AND (X_TOTAL_DISP_NAME is null)))
          AND ((tlinfo.COMP_DISP_NAME = X_COMP_DISP_NAME)
               OR ((tlinfo.COMP_DISP_NAME is null) AND (X_COMP_DISP_NAME is null)))
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
  X_DIM_LEVEL_ID in NUMBER,
  X_LEVEL_TABLE_NAME in VARCHAR2,
  X_TABLE_TYPE in NUMBER,
  X_LEVEL_PK_COL in VARCHAR2,
  X_ABBREVIATION in VARCHAR2,
  X_VALUE_ORDER_BY in NUMBER,
  X_COMP_ORDER_BY in NUMBER,
  X_CUSTOM_GROUP in NUMBER,
  X_USER_KEY_SIZE in NUMBER,
  X_DISP_KEY_SIZE in NUMBER,
  X_NAME in VARCHAR2,
  X_HELP in VARCHAR2,
  X_TOTAL_DISP_NAME in VARCHAR2,
  X_COMP_DISP_NAME in VARCHAR2
) is
begin
  update BSC_SYS_DIM_LEVELS_B set
    LEVEL_TABLE_NAME = X_LEVEL_TABLE_NAME,
    TABLE_TYPE = X_TABLE_TYPE,
    LEVEL_PK_COL = X_LEVEL_PK_COL,
    ABBREVIATION = X_ABBREVIATION,
    VALUE_ORDER_BY = X_VALUE_ORDER_BY,
    COMP_ORDER_BY = X_COMP_ORDER_BY,
    CUSTOM_GROUP = X_CUSTOM_GROUP,
    USER_KEY_SIZE = X_USER_KEY_SIZE,
    DISP_KEY_SIZE = X_DISP_KEY_SIZE
  where DIM_LEVEL_ID = X_DIM_LEVEL_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update BSC_SYS_DIM_LEVELS_TL set
    NAME = X_NAME,
    HELP = X_HELP,
    TOTAL_DISP_NAME = X_TOTAL_DISP_NAME,
    COMP_DISP_NAME = X_COMP_DISP_NAME,
    SOURCE_LANG = userenv('LANG')
  where DIM_LEVEL_ID = X_DIM_LEVEL_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_DIM_LEVEL_ID in NUMBER
) is
begin
  delete from BSC_SYS_DIM_LEVELS_TL
  where DIM_LEVEL_ID = X_DIM_LEVEL_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from BSC_SYS_DIM_LEVELS_B
  where DIM_LEVEL_ID = X_DIM_LEVEL_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from BSC_SYS_DIM_LEVELS_TL T
  where not exists
    (select NULL
    from BSC_SYS_DIM_LEVELS_B B
    where B.DIM_LEVEL_ID = T.DIM_LEVEL_ID
    );

  update BSC_SYS_DIM_LEVELS_TL T set (
      NAME,
      HELP,
      TOTAL_DISP_NAME,
      COMP_DISP_NAME
    ) = (select
      B.NAME,
      B.HELP,
      B.TOTAL_DISP_NAME,
      B.COMP_DISP_NAME
    from BSC_SYS_DIM_LEVELS_TL B
    where B.DIM_LEVEL_ID = T.DIM_LEVEL_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.DIM_LEVEL_ID,
      T.LANGUAGE
  ) in (select
      SUBT.DIM_LEVEL_ID,
      SUBT.LANGUAGE
    from BSC_SYS_DIM_LEVELS_TL SUBB, BSC_SYS_DIM_LEVELS_TL SUBT
    where SUBB.DIM_LEVEL_ID = SUBT.DIM_LEVEL_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or SUBB.HELP <> SUBT.HELP
      or SUBB.TOTAL_DISP_NAME <> SUBT.TOTAL_DISP_NAME
      or (SUBB.TOTAL_DISP_NAME is null and SUBT.TOTAL_DISP_NAME is not null)
      or (SUBB.TOTAL_DISP_NAME is not null and SUBT.TOTAL_DISP_NAME is null)
      or SUBB.COMP_DISP_NAME <> SUBT.COMP_DISP_NAME
      or (SUBB.COMP_DISP_NAME is null and SUBT.COMP_DISP_NAME is not null)
      or (SUBB.COMP_DISP_NAME is not null and SUBT.COMP_DISP_NAME is null)
  ));

  insert into BSC_SYS_DIM_LEVELS_TL (
    DIM_LEVEL_ID,
    NAME,
    HELP,
    TOTAL_DISP_NAME,
    COMP_DISP_NAME,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.DIM_LEVEL_ID,
    B.NAME,
    B.HELP,
    B.TOTAL_DISP_NAME,
    B.COMP_DISP_NAME,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from BSC_SYS_DIM_LEVELS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from BSC_SYS_DIM_LEVELS_TL T
    where T.DIM_LEVEL_ID = B.DIM_LEVEL_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end BSC_SYS_DIM_LEVELS_PKG;

/
