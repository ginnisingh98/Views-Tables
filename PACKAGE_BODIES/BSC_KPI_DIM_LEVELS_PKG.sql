--------------------------------------------------------
--  DDL for Package Body BSC_KPI_DIM_LEVELS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_KPI_DIM_LEVELS_PKG" as
/* $Header: BSCKDIMB.pls 115.7 2003/02/12 14:25:48 adrao ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_INDICATOR in NUMBER,
  X_DIM_SET_ID in NUMBER,
  X_DIM_LEVEL_INDEX in NUMBER,
  X_LEVEL_TABLE_NAME in VARCHAR2,
  X_LEVEL_VIEW_NAME in VARCHAR2,
  X_FILTER_COLUMN in VARCHAR2,
  X_FILTER_VALUE in NUMBER,
  X_DEFAULT_VALUE in VARCHAR2,
  X_DEFAULT_TYPE in NUMBER,
  X_VALUE_ORDER_BY in NUMBER,
  X_COMP_ORDER_BY in NUMBER,
  X_LEVEL_PK_COL in VARCHAR2,
  X_PARENT_LEVEL_INDEX in NUMBER,
  X_PARENT_LEVEL_REL in VARCHAR2,
  X_TABLE_RELATION in VARCHAR2,
  X_PARENT_LEVEL_INDEX2 in NUMBER,
  X_PARENT_LEVEL_REL2 in VARCHAR2,
  X_STATUS in NUMBER,
  X_PARENT_IN_TOTAL in NUMBER,
  X_POSITION in NUMBER,
  X_TOTAL0 in NUMBER,
  X_LEVEL_DISPLAY in NUMBER,
  X_NO_ITEMS in NUMBER,
  X_DEFAULT_KEY_VALUE in NUMBER,
  X_USER_LEVEL0 in NUMBER,
  X_USER_LEVEL1 in NUMBER,
  X_USER_LEVEL1_DEFAULT in NUMBER,
  X_USER_LEVEL2 in NUMBER,
  X_USER_LEVEL2_DEFAULT in NUMBER,
  X_NAME in VARCHAR2,
  X_HELP in VARCHAR2,
  X_TOTAL_DISP_NAME in VARCHAR2,
  X_COMP_DISP_NAME in VARCHAR2
) is
  cursor C is select ROWID from BSC_KPI_DIM_LEVELS_B
    where INDICATOR = X_INDICATOR
    and DIM_SET_ID = X_DIM_SET_ID
    and DIM_LEVEL_INDEX = X_DIM_LEVEL_INDEX
    ;
begin
  insert into BSC_KPI_DIM_LEVELS_B (
    INDICATOR,
    DIM_SET_ID,
    DIM_LEVEL_INDEX,
    LEVEL_TABLE_NAME,
    LEVEL_VIEW_NAME,
    FILTER_COLUMN,
    FILTER_VALUE,
    DEFAULT_VALUE,
    DEFAULT_TYPE,
    VALUE_ORDER_BY,
    COMP_ORDER_BY,
    LEVEL_PK_COL,
    PARENT_LEVEL_INDEX,
    PARENT_LEVEL_REL,
    TABLE_RELATION,
    PARENT_LEVEL_INDEX2,
    PARENT_LEVEL_REL2,
    STATUS,
    PARENT_IN_TOTAL,
    POSITION,
    TOTAL0,
    LEVEL_DISPLAY,
    NO_ITEMS,
    DEFAULT_KEY_VALUE,
    USER_LEVEL0,
    USER_LEVEL1,
    USER_LEVEL1_DEFAULT,
    USER_LEVEL2,
    USER_LEVEL2_DEFAULT
  ) values (
    X_INDICATOR,
    X_DIM_SET_ID,
    X_DIM_LEVEL_INDEX,
    X_LEVEL_TABLE_NAME,
    X_LEVEL_VIEW_NAME,
    X_FILTER_COLUMN,
    X_FILTER_VALUE,
    X_DEFAULT_VALUE,
    X_DEFAULT_TYPE,
    X_VALUE_ORDER_BY,
    X_COMP_ORDER_BY,
    X_LEVEL_PK_COL,
    X_PARENT_LEVEL_INDEX,
    X_PARENT_LEVEL_REL,
    X_TABLE_RELATION,
    X_PARENT_LEVEL_INDEX2,
    X_PARENT_LEVEL_REL2,
    X_STATUS,
    X_PARENT_IN_TOTAL,
    X_POSITION,
    X_TOTAL0,
    X_LEVEL_DISPLAY,
    X_NO_ITEMS,
    X_DEFAULT_KEY_VALUE,
    X_USER_LEVEL0,
    X_USER_LEVEL1,
    X_USER_LEVEL1_DEFAULT,
    X_USER_LEVEL2,
    X_USER_LEVEL2_DEFAULT
  );

  insert into BSC_KPI_DIM_LEVELS_TL (
    INDICATOR,
    DIM_SET_ID,
    DIM_LEVEL_INDEX,
    NAME,
    HELP,
    TOTAL_DISP_NAME,
    COMP_DISP_NAME,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_INDICATOR,
    X_DIM_SET_ID,
    X_DIM_LEVEL_INDEX,
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
    from BSC_KPI_DIM_LEVELS_TL T
    where T.INDICATOR = X_INDICATOR
    and T.DIM_SET_ID = X_DIM_SET_ID
    and T.DIM_LEVEL_INDEX = X_DIM_LEVEL_INDEX
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
  X_INDICATOR in NUMBER,
  X_DIM_SET_ID in NUMBER,
  X_DIM_LEVEL_INDEX in NUMBER,
  X_LEVEL_TABLE_NAME in VARCHAR2,
  X_LEVEL_VIEW_NAME in VARCHAR2,
  X_FILTER_COLUMN in VARCHAR2,
  X_FILTER_VALUE in NUMBER,
  X_DEFAULT_VALUE in VARCHAR2,
  X_DEFAULT_TYPE in NUMBER,
  X_VALUE_ORDER_BY in NUMBER,
  X_COMP_ORDER_BY in NUMBER,
  X_LEVEL_PK_COL in VARCHAR2,
  X_PARENT_LEVEL_INDEX in NUMBER,
  X_PARENT_LEVEL_REL in VARCHAR2,
  X_TABLE_RELATION in VARCHAR2,
  X_PARENT_LEVEL_INDEX2 in NUMBER,
  X_PARENT_LEVEL_REL2 in VARCHAR2,
  X_STATUS in NUMBER,
  X_PARENT_IN_TOTAL in NUMBER,
  X_POSITION in NUMBER,
  X_TOTAL0 in NUMBER,
  X_LEVEL_DISPLAY in NUMBER,
  X_NO_ITEMS in NUMBER,
  X_DEFAULT_KEY_VALUE in NUMBER,
  X_USER_LEVEL0 in NUMBER,
  X_USER_LEVEL1 in NUMBER,
  X_USER_LEVEL1_DEFAULT in NUMBER,
  X_USER_LEVEL2 in NUMBER,
  X_USER_LEVEL2_DEFAULT in NUMBER,
  X_NAME in VARCHAR2,
  X_HELP in VARCHAR2,
  X_TOTAL_DISP_NAME in VARCHAR2,
  X_COMP_DISP_NAME in VARCHAR2
) is
  cursor c is select
      LEVEL_TABLE_NAME,
      LEVEL_VIEW_NAME,
      FILTER_COLUMN,
      FILTER_VALUE,
      DEFAULT_VALUE,
      DEFAULT_TYPE,
      VALUE_ORDER_BY,
      COMP_ORDER_BY,
      LEVEL_PK_COL,
      PARENT_LEVEL_INDEX,
      PARENT_LEVEL_REL,
      TABLE_RELATION,
      PARENT_LEVEL_INDEX2,
      PARENT_LEVEL_REL2,
      STATUS,
      PARENT_IN_TOTAL,
      POSITION,
      TOTAL0,
      LEVEL_DISPLAY,
      NO_ITEMS,
      DEFAULT_KEY_VALUE,
      USER_LEVEL0,
      USER_LEVEL1,
      USER_LEVEL1_DEFAULT,
      USER_LEVEL2,
      USER_LEVEL2_DEFAULT
    from BSC_KPI_DIM_LEVELS_B
    where INDICATOR = X_INDICATOR
    and DIM_SET_ID = X_DIM_SET_ID
    and DIM_LEVEL_INDEX = X_DIM_LEVEL_INDEX
    for update of INDICATOR nowait;
  recinfo c%rowtype;

  cursor c1 is select
      NAME,
      HELP,
      TOTAL_DISP_NAME,
      COMP_DISP_NAME,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from BSC_KPI_DIM_LEVELS_TL
    where INDICATOR = X_INDICATOR
    and DIM_SET_ID = X_DIM_SET_ID
    and DIM_LEVEL_INDEX = X_DIM_LEVEL_INDEX
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of INDICATOR nowait;
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
      AND ((recinfo.LEVEL_VIEW_NAME = X_LEVEL_VIEW_NAME)
           OR ((recinfo.LEVEL_VIEW_NAME is null) AND (X_LEVEL_VIEW_NAME is null)))
      AND ((recinfo.FILTER_COLUMN = X_FILTER_COLUMN)
           OR ((recinfo.FILTER_COLUMN is null) AND (X_FILTER_COLUMN is null)))
      AND ((recinfo.FILTER_VALUE = X_FILTER_VALUE)
           OR ((recinfo.FILTER_VALUE is null) AND (X_FILTER_VALUE is null)))
      AND ((recinfo.DEFAULT_VALUE = X_DEFAULT_VALUE)
           OR ((recinfo.DEFAULT_VALUE is null) AND (X_DEFAULT_VALUE is null)))
      AND ((recinfo.DEFAULT_TYPE = X_DEFAULT_TYPE)
           OR ((recinfo.DEFAULT_TYPE is null) AND (X_DEFAULT_TYPE is null)))
      AND (recinfo.VALUE_ORDER_BY = X_VALUE_ORDER_BY)
      AND (recinfo.COMP_ORDER_BY = X_COMP_ORDER_BY)
      AND (recinfo.LEVEL_PK_COL = X_LEVEL_PK_COL)
      AND ((recinfo.PARENT_LEVEL_INDEX = X_PARENT_LEVEL_INDEX)
           OR ((recinfo.PARENT_LEVEL_INDEX is null) AND (X_PARENT_LEVEL_INDEX is null)))
      AND ((recinfo.PARENT_LEVEL_REL = X_PARENT_LEVEL_REL)
           OR ((recinfo.PARENT_LEVEL_REL is null) AND (X_PARENT_LEVEL_REL is null)))
      AND ((recinfo.TABLE_RELATION = X_TABLE_RELATION)
           OR ((recinfo.TABLE_RELATION is null) AND (X_TABLE_RELATION is null)))
      AND ((recinfo.PARENT_LEVEL_INDEX2 = X_PARENT_LEVEL_INDEX2)
           OR ((recinfo.PARENT_LEVEL_INDEX2 is null) AND (X_PARENT_LEVEL_INDEX2 is null)))
      AND ((recinfo.PARENT_LEVEL_REL2 = X_PARENT_LEVEL_REL2)
           OR ((recinfo.PARENT_LEVEL_REL2 is null) AND (X_PARENT_LEVEL_REL2 is null)))
      AND (recinfo.STATUS = X_STATUS)
      AND ((recinfo.PARENT_IN_TOTAL = X_PARENT_IN_TOTAL)
           OR ((recinfo.PARENT_IN_TOTAL is null) AND (X_PARENT_IN_TOTAL is null)))
      AND (recinfo.POSITION = X_POSITION)
      AND ((recinfo.TOTAL0 = X_TOTAL0)
           OR ((recinfo.TOTAL0 is null) AND (X_TOTAL0 is null)))
      AND ((recinfo.LEVEL_DISPLAY = X_LEVEL_DISPLAY)
           OR ((recinfo.LEVEL_DISPLAY is null) AND (X_LEVEL_DISPLAY is null)))
      AND ((recinfo.NO_ITEMS = X_NO_ITEMS)
           OR ((recinfo.NO_ITEMS is null) AND (X_NO_ITEMS is null)))
      AND ((recinfo.DEFAULT_KEY_VALUE = X_DEFAULT_KEY_VALUE)
           OR ((recinfo.DEFAULT_KEY_VALUE is null) AND (X_DEFAULT_KEY_VALUE is null)))
      AND ((recinfo.USER_LEVEL0 = X_USER_LEVEL0)
           OR ((recinfo.USER_LEVEL0 is null) AND (X_USER_LEVEL0 is null)))
      AND ((recinfo.USER_LEVEL1 = X_USER_LEVEL1)
           OR ((recinfo.USER_LEVEL1 is null) AND (X_USER_LEVEL1 is null)))
      AND ((recinfo.USER_LEVEL1_DEFAULT = X_USER_LEVEL1_DEFAULT)
           OR ((recinfo.USER_LEVEL1_DEFAULT is null) AND (X_USER_LEVEL1_DEFAULT is null)))
      AND ((recinfo.USER_LEVEL2 = X_USER_LEVEL2)
           OR ((recinfo.USER_LEVEL2 is null) AND (X_USER_LEVEL2 is null)))
      AND ((recinfo.USER_LEVEL2_DEFAULT = X_USER_LEVEL2_DEFAULT)
           OR ((recinfo.USER_LEVEL2_DEFAULT is null) AND (X_USER_LEVEL2_DEFAULT is null)))
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
  X_INDICATOR in NUMBER,
  X_DIM_SET_ID in NUMBER,
  X_DIM_LEVEL_INDEX in NUMBER,
  X_LEVEL_TABLE_NAME in VARCHAR2,
  X_LEVEL_VIEW_NAME in VARCHAR2,
  X_FILTER_COLUMN in VARCHAR2,
  X_FILTER_VALUE in NUMBER,
  X_DEFAULT_VALUE in VARCHAR2,
  X_DEFAULT_TYPE in NUMBER,
  X_VALUE_ORDER_BY in NUMBER,
  X_COMP_ORDER_BY in NUMBER,
  X_LEVEL_PK_COL in VARCHAR2,
  X_PARENT_LEVEL_INDEX in NUMBER,
  X_PARENT_LEVEL_REL in VARCHAR2,
  X_TABLE_RELATION in VARCHAR2,
  X_PARENT_LEVEL_INDEX2 in NUMBER,
  X_PARENT_LEVEL_REL2 in VARCHAR2,
  X_STATUS in NUMBER,
  X_PARENT_IN_TOTAL in NUMBER,
  X_POSITION in NUMBER,
  X_TOTAL0 in NUMBER,
  X_LEVEL_DISPLAY in NUMBER,
  X_NO_ITEMS in NUMBER,
  X_DEFAULT_KEY_VALUE in NUMBER,
  X_USER_LEVEL0 in NUMBER,
  X_USER_LEVEL1 in NUMBER,
  X_USER_LEVEL1_DEFAULT in NUMBER,
  X_USER_LEVEL2 in NUMBER,
  X_USER_LEVEL2_DEFAULT in NUMBER,
  X_NAME in VARCHAR2,
  X_HELP in VARCHAR2,
  X_TOTAL_DISP_NAME in VARCHAR2,
  X_COMP_DISP_NAME in VARCHAR2
) is
begin
  update BSC_KPI_DIM_LEVELS_B set
    LEVEL_TABLE_NAME = X_LEVEL_TABLE_NAME,
    LEVEL_VIEW_NAME = X_LEVEL_VIEW_NAME,
    FILTER_COLUMN = X_FILTER_COLUMN,
    FILTER_VALUE = X_FILTER_VALUE,
    DEFAULT_VALUE = X_DEFAULT_VALUE,
    DEFAULT_TYPE = X_DEFAULT_TYPE,
    VALUE_ORDER_BY = X_VALUE_ORDER_BY,
    COMP_ORDER_BY = X_COMP_ORDER_BY,
    LEVEL_PK_COL = X_LEVEL_PK_COL,
    PARENT_LEVEL_INDEX = X_PARENT_LEVEL_INDEX,
    PARENT_LEVEL_REL = X_PARENT_LEVEL_REL,
    TABLE_RELATION = X_TABLE_RELATION,
    PARENT_LEVEL_INDEX2 = X_PARENT_LEVEL_INDEX2,
    PARENT_LEVEL_REL2 = X_PARENT_LEVEL_REL2,
    STATUS = X_STATUS,
    PARENT_IN_TOTAL = X_PARENT_IN_TOTAL,
    POSITION = X_POSITION,
    TOTAL0 = X_TOTAL0,
    LEVEL_DISPLAY = X_LEVEL_DISPLAY,
    NO_ITEMS = X_NO_ITEMS,
    DEFAULT_KEY_VALUE = X_DEFAULT_KEY_VALUE,
    USER_LEVEL0 = X_USER_LEVEL0,
    USER_LEVEL1 = X_USER_LEVEL1,
    USER_LEVEL1_DEFAULT = X_USER_LEVEL1_DEFAULT,
    USER_LEVEL2 = X_USER_LEVEL2,
    USER_LEVEL2_DEFAULT = X_USER_LEVEL2_DEFAULT
  where INDICATOR = X_INDICATOR
  and DIM_SET_ID = X_DIM_SET_ID
  and DIM_LEVEL_INDEX = X_DIM_LEVEL_INDEX;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update BSC_KPI_DIM_LEVELS_TL set
    NAME = X_NAME,
    HELP = X_HELP,
    TOTAL_DISP_NAME = X_TOTAL_DISP_NAME,
    COMP_DISP_NAME = X_COMP_DISP_NAME,
    SOURCE_LANG = userenv('LANG')
  where INDICATOR = X_INDICATOR
  and DIM_SET_ID = X_DIM_SET_ID
  and DIM_LEVEL_INDEX = X_DIM_LEVEL_INDEX
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_INDICATOR in NUMBER,
  X_DIM_SET_ID in NUMBER,
  X_DIM_LEVEL_INDEX in NUMBER
) is
begin
  delete from BSC_KPI_DIM_LEVELS_TL
  where INDICATOR = X_INDICATOR
  and DIM_SET_ID = X_DIM_SET_ID
  and DIM_LEVEL_INDEX = X_DIM_LEVEL_INDEX;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from BSC_KPI_DIM_LEVELS_B
  where INDICATOR = X_INDICATOR
  and DIM_SET_ID = X_DIM_SET_ID
  and DIM_LEVEL_INDEX = X_DIM_LEVEL_INDEX;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from BSC_KPI_DIM_LEVELS_TL T
  where not exists
    (select NULL
    from BSC_KPI_DIM_LEVELS_B B
    where B.INDICATOR = T.INDICATOR
    and B.DIM_SET_ID = T.DIM_SET_ID
    and B.DIM_LEVEL_INDEX = T.DIM_LEVEL_INDEX
    );

  update BSC_KPI_DIM_LEVELS_TL T set (
      NAME,
      HELP,
      TOTAL_DISP_NAME,
      COMP_DISP_NAME
    ) = (select
      B.NAME,
      B.HELP,
      B.TOTAL_DISP_NAME,
      B.COMP_DISP_NAME
    from BSC_KPI_DIM_LEVELS_TL B
    where B.INDICATOR = T.INDICATOR
    and B.DIM_SET_ID = T.DIM_SET_ID
    and B.DIM_LEVEL_INDEX = T.DIM_LEVEL_INDEX
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.INDICATOR,
      T.DIM_SET_ID,
      T.DIM_LEVEL_INDEX,
      T.LANGUAGE
  ) in (select
      SUBT.INDICATOR,
      SUBT.DIM_SET_ID,
      SUBT.DIM_LEVEL_INDEX,
      SUBT.LANGUAGE
    from BSC_KPI_DIM_LEVELS_TL SUBB, BSC_KPI_DIM_LEVELS_TL SUBT
    where SUBB.INDICATOR = SUBT.INDICATOR
    and SUBB.DIM_SET_ID = SUBT.DIM_SET_ID
    and SUBB.DIM_LEVEL_INDEX = SUBT.DIM_LEVEL_INDEX
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

  insert into BSC_KPI_DIM_LEVELS_TL (
    INDICATOR,
    DIM_SET_ID,
    DIM_LEVEL_INDEX,
    NAME,
    HELP,
    TOTAL_DISP_NAME,
    COMP_DISP_NAME,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.INDICATOR,
    B.DIM_SET_ID,
    B.DIM_LEVEL_INDEX,
    B.NAME,
    B.HELP,
    B.TOTAL_DISP_NAME,
    B.COMP_DISP_NAME,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from BSC_KPI_DIM_LEVELS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from BSC_KPI_DIM_LEVELS_TL T
    where T.INDICATOR = B.INDICATOR
    and T.DIM_SET_ID = B.DIM_SET_ID
    and T.DIM_LEVEL_INDEX = B.DIM_LEVEL_INDEX
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end BSC_KPI_DIM_LEVELS_PKG;

/
