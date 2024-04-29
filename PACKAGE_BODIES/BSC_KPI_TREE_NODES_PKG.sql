--------------------------------------------------------
--  DDL for Package Body BSC_KPI_TREE_NODES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_KPI_TREE_NODES_PKG" as
/* $Header: BSCKTNDB.pls 120.1 2007/02/09 09:15:21 ashankar ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_INDICATOR in NUMBER,
  X_NODE_ID in NUMBER,
  X_SIMULATE_FLAG in NUMBER,
  X_FORMAT_ID in NUMBER,
  X_COLOR_FLAG in NUMBER,
  X_COLOR_METHOD in NUMBER,
  X_NAVIGATES_TO_TREND in NUMBER,
  X_TOP_POSITION in NUMBER,
  X_LEFT_POSITION in NUMBER,
  X_WIDTH in NUMBER,
  X_HEIGHT in NUMBER,
  X_NAME in VARCHAR2,
  X_HELP in VARCHAR2,
  X_Y_AXIS_TITLE IN VARCHAR
) is
  cursor C is select ROWID from BSC_KPI_TREE_NODES_B
    where INDICATOR = X_INDICATOR
    and NODE_ID = X_NODE_ID
    ;
begin
  insert into BSC_KPI_TREE_NODES_B (
    INDICATOR,
    NODE_ID,
    SIMULATE_FLAG,
    FORMAT_ID,
    COLOR_FLAG,
    COLOR_METHOD,
    NAVIGATES_TO_TREND,
    TOP_POSITION,
    LEFT_POSITION,
    WIDTH,
    HEIGHT
  ) values (
    X_INDICATOR,
    X_NODE_ID,
    X_SIMULATE_FLAG,
    X_FORMAT_ID,
    X_COLOR_FLAG,
    X_COLOR_METHOD,
    X_NAVIGATES_TO_TREND,
    X_TOP_POSITION,
    X_LEFT_POSITION,
    X_WIDTH,
    X_HEIGHT
  );

  insert into BSC_KPI_TREE_NODES_TL (
    INDICATOR,
    NODE_ID,
    NAME,
    HELP,
    Y_AXIS_TITLE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_INDICATOR,
    X_NODE_ID,
    X_NAME,
    X_HELP,
    X_Y_AXIS_TITLE,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from BSC_KPI_TREE_NODES_TL T
    where T.INDICATOR = X_INDICATOR
    and T.NODE_ID = X_NODE_ID
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
  X_NODE_ID in NUMBER,
  X_SIMULATE_FLAG in NUMBER,
  X_FORMAT_ID in NUMBER,
  X_COLOR_FLAG in NUMBER,
  X_COLOR_METHOD in NUMBER,
  X_NAVIGATES_TO_TREND in NUMBER,
  X_TOP_POSITION in NUMBER,
  X_LEFT_POSITION in NUMBER,
  X_WIDTH in NUMBER,
  X_HEIGHT in NUMBER,
  X_NAME in VARCHAR2,
  X_HELP in VARCHAR2
) is
  cursor c is select
      SIMULATE_FLAG,
      FORMAT_ID,
      COLOR_FLAG,
      COLOR_METHOD,
      NAVIGATES_TO_TREND,
      TOP_POSITION,
      LEFT_POSITION,
      WIDTH,
      HEIGHT
    from BSC_KPI_TREE_NODES_B
    where INDICATOR = X_INDICATOR
    and NODE_ID = X_NODE_ID
    for update of INDICATOR nowait;
  recinfo c%rowtype;

  cursor c1 is select
      NAME,
      HELP,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from BSC_KPI_TREE_NODES_TL
    where INDICATOR = X_INDICATOR
    and NODE_ID = X_NODE_ID
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
  if (    (recinfo.SIMULATE_FLAG = X_SIMULATE_FLAG)
      AND (recinfo.FORMAT_ID = X_FORMAT_ID)
      AND (recinfo.COLOR_FLAG = X_COLOR_FLAG)
      AND (recinfo.COLOR_METHOD = X_COLOR_METHOD)
      AND (recinfo.NAVIGATES_TO_TREND = X_NAVIGATES_TO_TREND)
      AND (recinfo.TOP_POSITION = X_TOP_POSITION)
      AND (recinfo.LEFT_POSITION = X_LEFT_POSITION)
      AND (recinfo.WIDTH = X_WIDTH)
      AND (recinfo.HEIGHT = X_HEIGHT)
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
  X_INDICATOR in NUMBER,
  X_NODE_ID in NUMBER,
  X_SIMULATE_FLAG in NUMBER,
  X_FORMAT_ID in NUMBER,
  X_COLOR_FLAG in NUMBER,
  X_COLOR_METHOD in NUMBER,
  X_NAVIGATES_TO_TREND in NUMBER,
  X_TOP_POSITION in NUMBER,
  X_LEFT_POSITION in NUMBER,
  X_WIDTH in NUMBER,
  X_HEIGHT in NUMBER,
  X_NAME in VARCHAR2,
  X_HELP in VARCHAR2,
  X_Y_AXIS_TITLE IN VARCHAR
) is
begin
  update BSC_KPI_TREE_NODES_B set
    SIMULATE_FLAG = X_SIMULATE_FLAG,
    FORMAT_ID = X_FORMAT_ID,
    COLOR_FLAG = X_COLOR_FLAG,
    COLOR_METHOD = X_COLOR_METHOD,
    NAVIGATES_TO_TREND = X_NAVIGATES_TO_TREND,
    TOP_POSITION = X_TOP_POSITION,
    LEFT_POSITION = X_LEFT_POSITION,
    WIDTH = X_WIDTH,
    HEIGHT = X_HEIGHT
  where INDICATOR = X_INDICATOR
  and NODE_ID = X_NODE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update BSC_KPI_TREE_NODES_TL set
    NAME = X_NAME,
    HELP = X_HELP,
    Y_AXIS_TITLE =X_Y_AXIS_TITLE,
    SOURCE_LANG = userenv('LANG')
  where INDICATOR = X_INDICATOR
  and NODE_ID = X_NODE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_INDICATOR in NUMBER,
  X_NODE_ID in NUMBER
) is
begin
  delete from BSC_KPI_TREE_NODES_TL
  where INDICATOR = X_INDICATOR
  and NODE_ID = X_NODE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from BSC_KPI_TREE_NODES_B
  where INDICATOR = X_INDICATOR
  and NODE_ID = X_NODE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from BSC_KPI_TREE_NODES_TL T
  where not exists
    (select NULL
    from BSC_KPI_TREE_NODES_B B
    where B.INDICATOR = T.INDICATOR
    and B.NODE_ID = T.NODE_ID
    );

  update BSC_KPI_TREE_NODES_TL T set (
      NAME,
      HELP,Y_AXIS_TITLE
    ) = (select
      B.NAME,
      B.HELP,B.Y_AXIS_TITLE
    from BSC_KPI_TREE_NODES_TL B
    where B.INDICATOR = T.INDICATOR
    and B.NODE_ID = T.NODE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.INDICATOR,
      T.NODE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.INDICATOR,
      SUBT.NODE_ID,
      SUBT.LANGUAGE
    from BSC_KPI_TREE_NODES_TL SUBB, BSC_KPI_TREE_NODES_TL SUBT
    where SUBB.INDICATOR = SUBT.INDICATOR
    and SUBB.NODE_ID = SUBT.NODE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or SUBB.HELP <> SUBT.HELP
      or SUBB.Y_AXIS_TITLE <> SUBT.Y_AXIS_TITLE
  ));

  insert into BSC_KPI_TREE_NODES_TL (
    INDICATOR,
    NODE_ID,
    NAME,
    HELP,
    Y_AXIS_TITLE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.INDICATOR,
    B.NODE_ID,
    B.NAME,
    B.HELP,
    B.Y_AXIS_TITLE,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from BSC_KPI_TREE_NODES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from BSC_KPI_TREE_NODES_TL T
    where T.INDICATOR = B.INDICATOR
    and T.NODE_ID = B.NODE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end BSC_KPI_TREE_NODES_PKG;

/
