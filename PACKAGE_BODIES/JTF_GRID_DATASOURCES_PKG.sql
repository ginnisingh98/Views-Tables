--------------------------------------------------------
--  DDL for Package Body JTF_GRID_DATASOURCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_GRID_DATASOURCES_PKG" AS
/* $Header: JTFGDPKB.pls 120.3 2006/09/20 08:03:45 snellepa ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_GRID_DATASOURCE_NAME in VARCHAR2,
  X_DB_VIEW_NAME in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_DEFAULT_ROW_HEIGHT in NUMBER,
  X_MAX_QUERIED_ROWS in NUMBER,
  X_WHERE_CLAUSE in VARCHAR2,
  X_ALT_COLOR_CODE in VARCHAR2,
  X_ALT_COLOR_INTERVAL in NUMBER,
  X_TITLE_TEXT in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_FETCH_SIZE in NUMBER
) is
  cursor C is select ROWID from JTF_GRID_DATASOURCES_B
    where GRID_DATASOURCE_NAME = X_GRID_DATASOURCE_NAME
    ;
begin
  insert into JTF_GRID_DATASOURCES_B (
    GRID_DATASOURCE_NAME,
    DB_VIEW_NAME,
    APPLICATION_ID,
    DEFAULT_ROW_HEIGHT,
    MAX_QUERIED_ROWS,
    WHERE_CLAUSE,
    ALT_COLOR_CODE,
    ALT_COLOR_INTERVAL,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    FETCH_SIZE
  ) values (
    X_GRID_DATASOURCE_NAME,
    X_DB_VIEW_NAME,
    X_APPLICATION_ID,
    X_DEFAULT_ROW_HEIGHT,
    X_MAX_QUERIED_ROWS,
    X_WHERE_CLAUSE,
    X_ALT_COLOR_CODE,
    X_ALT_COLOR_INTERVAL,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_FETCH_SIZE
  );

  insert into JTF_GRID_DATASOURCES_TL (
    GRID_DATASOURCE_NAME,
    TITLE_TEXT,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_GRID_DATASOURCE_NAME,
    X_TITLE_TEXT,
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
    from JTF_GRID_DATASOURCES_TL T
    where T.GRID_DATASOURCE_NAME = X_GRID_DATASOURCE_NAME
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
  X_GRID_DATASOURCE_NAME in VARCHAR2,
  X_DB_VIEW_NAME in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_DEFAULT_ROW_HEIGHT in NUMBER,
  X_MAX_QUERIED_ROWS in NUMBER,
  X_WHERE_CLAUSE in VARCHAR2,
  X_ALT_COLOR_CODE in VARCHAR2,
  X_ALT_COLOR_INTERVAL in NUMBER,
  X_TITLE_TEXT in VARCHAR2,
  X_FETCH_SIZE in NUMBER
) is
  cursor c is select
      DB_VIEW_NAME,
      APPLICATION_ID,
      DEFAULT_ROW_HEIGHT,
      MAX_QUERIED_ROWS,
      WHERE_CLAUSE,
      ALT_COLOR_CODE,
      ALT_COLOR_INTERVAL,
      FETCH_SIZE
    from JTF_GRID_DATASOURCES_B
    where GRID_DATASOURCE_NAME = X_GRID_DATASOURCE_NAME
    for update of GRID_DATASOURCE_NAME nowait;
  recinfo c%rowtype;

  cursor c1 is select
      TITLE_TEXT,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from JTF_GRID_DATASOURCES_TL
    where GRID_DATASOURCE_NAME = X_GRID_DATASOURCE_NAME
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of GRID_DATASOURCE_NAME nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.DB_VIEW_NAME = X_DB_VIEW_NAME)
      AND (recinfo.APPLICATION_ID = X_APPLICATION_ID)
      AND (recinfo.DEFAULT_ROW_HEIGHT = X_DEFAULT_ROW_HEIGHT)
      AND ((recinfo.MAX_QUERIED_ROWS = X_MAX_QUERIED_ROWS)
           OR ((recinfo.MAX_QUERIED_ROWS is null) AND (X_MAX_QUERIED_ROWS is null)))
      AND ((recinfo.WHERE_CLAUSE = X_WHERE_CLAUSE)
           OR ((recinfo.WHERE_CLAUSE is null) AND (X_WHERE_CLAUSE is null)))
      AND ((recinfo.ALT_COLOR_CODE = X_ALT_COLOR_CODE)
           OR ((recinfo.ALT_COLOR_CODE is null) AND (X_ALT_COLOR_CODE is null)))
      AND ((recinfo.ALT_COLOR_INTERVAL = X_ALT_COLOR_INTERVAL)
           OR ((recinfo.ALT_COLOR_INTERVAL is null) AND (X_ALT_COLOR_INTERVAL is null)))
      AND ((recinfo.FETCH_SIZE = X_FETCH_SIZE)
           OR ((recinfo.FETCH_SIZE is null) AND (X_FETCH_SIZE is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.TITLE_TEXT = X_TITLE_TEXT)
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
  X_GRID_DATASOURCE_NAME in VARCHAR2,
  X_DB_VIEW_NAME in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_DEFAULT_ROW_HEIGHT in NUMBER,
  X_MAX_QUERIED_ROWS in NUMBER,
  X_WHERE_CLAUSE in VARCHAR2,
  X_ALT_COLOR_CODE in VARCHAR2,
  X_ALT_COLOR_INTERVAL in NUMBER,
  X_TITLE_TEXT in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_FETCH_SIZE in NUMBER
) is
begin
  update JTF_GRID_DATASOURCES_B set
    DB_VIEW_NAME = X_DB_VIEW_NAME,
    APPLICATION_ID = X_APPLICATION_ID,
    DEFAULT_ROW_HEIGHT = X_DEFAULT_ROW_HEIGHT,
    MAX_QUERIED_ROWS = X_MAX_QUERIED_ROWS,
    WHERE_CLAUSE = X_WHERE_CLAUSE,
    ALT_COLOR_CODE = X_ALT_COLOR_CODE,
    ALT_COLOR_INTERVAL = X_ALT_COLOR_INTERVAL,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    FETCH_SIZE = X_FETCH_SIZE
  where GRID_DATASOURCE_NAME = X_GRID_DATASOURCE_NAME;
  if (sql%notfound) then
    raise no_data_found;
  end if;
  update JTF_GRID_DATASOURCES_TL set
    TITLE_TEXT = X_TITLE_TEXT,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where GRID_DATASOURCE_NAME = X_GRID_DATASOURCE_NAME
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;


/** this procedure is for INTERNAL USE only.

This procedure delete the metadata definition without deleting the customization data

This procedure should be invoked only from the LOAD_ROW procedure which will re-load the metadata
definition.
*/

procedure DELETE_ROW_PRESERVE_CUSTOM(
  X_GRID_DATASOURCE_NAME in VARCHAR2
) is
  cursor sort_cols(x_grid_datasource_name in varchar2) is
    select 'X'
    from jtf_grid_sort_cols
    where grid_datasource_name = x_grid_datasource_name;

begin
  -- cascade delete to all related tables except customization tables

  for i in sort_cols(x_grid_datasource_name) loop
    delete from JTF_GRID_SORT_COLS
    where GRID_DATASOURCE_NAME = X_GRID_DATASOURCE_NAME;
  end loop;

  delete from JTF_GRID_DATASOURCES_TL
  where GRID_DATASOURCE_NAME = X_GRID_DATASOURCE_NAME;

  delete from JTF_GRID_DATASOURCES_B
  where GRID_DATASOURCE_NAME = X_GRID_DATASOURCE_NAME;

  delete from JTF_GRID_COLS_TL
  where GRID_DATASOURCE_NAME = X_GRID_DATASOURCE_NAME ;

  delete from JTF_GRID_COLS_B
  where GRID_DATASOURCE_NAME = X_GRID_DATASOURCE_NAME ;

  if (sql%notfound) then
    null; --the  metadata is being uploaded for the first time
  end if;
end DELETE_ROW_PRESERVE_CUSTOM;

procedure DELETE_ROW (
  X_GRID_DATASOURCE_NAME in VARCHAR2
) is
  l_custom_grid_id jtf_custom_grids.custom_grid_id%TYPE;

  cursor custom_grid(x_grid_datasource_name in varchar2) is
    select custom_grid_id
    from jtf_custom_grids
    where grid_datasource_name = x_grid_datasource_name;

  cursor sort_cols(x_grid_datasource_name in varchar2) is
    select 'X'
    from jtf_grid_sort_cols
    where grid_datasource_name = x_grid_datasource_name;

begin
  -- cascade delete to all related tables except JTF_GRID_COLS

  open custom_grid(x_grid_datasource_name);
  fetch custom_grid into l_custom_grid_id;
  while custom_grid%FOUND loop
    delete from JTF_CUSTOM_BIND_VALUES
    where CUSTOM_GRID_ID = l_custom_grid_id;
    fetch custom_grid into l_custom_grid_id;
  end loop;
  close custom_grid;

  delete from JTF_DEF_CUSTOM_GRIDS
  where GRID_DATASOURCE_NAME = X_GRID_DATASOURCE_NAME;

  delete from JTF_CUSTOM_GRIDS
  where GRID_DATASOURCE_NAME = X_GRID_DATASOURCE_NAME;

  for i in sort_cols(x_grid_datasource_name) loop
    delete from JTF_GRID_SORT_COLS
    where GRID_DATASOURCE_NAME = X_GRID_DATASOURCE_NAME;
  end loop;

  delete from JTF_GRID_DATASOURCES_TL
  where GRID_DATASOURCE_NAME = X_GRID_DATASOURCE_NAME;

  delete from JTF_GRID_DATASOURCES_B
  where GRID_DATASOURCE_NAME = X_GRID_DATASOURCE_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from JTF_GRID_DATASOURCES_TL T
  where not exists
    (select NULL
    from JTF_GRID_DATASOURCES_B B
    where B.GRID_DATASOURCE_NAME = T.GRID_DATASOURCE_NAME
    );

  update JTF_GRID_DATASOURCES_TL T set (
      TITLE_TEXT
    ) = (select
      B.TITLE_TEXT
    from JTF_GRID_DATASOURCES_TL B
    where B.GRID_DATASOURCE_NAME = T.GRID_DATASOURCE_NAME
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.GRID_DATASOURCE_NAME,
      T.LANGUAGE
  ) in (select
      SUBT.GRID_DATASOURCE_NAME,
      SUBT.LANGUAGE
    from JTF_GRID_DATASOURCES_TL SUBB, JTF_GRID_DATASOURCES_TL SUBT
    where SUBB.GRID_DATASOURCE_NAME = SUBT.GRID_DATASOURCE_NAME
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.TITLE_TEXT <> SUBT.TITLE_TEXT
  ));

  insert into JTF_GRID_DATASOURCES_TL (
    GRID_DATASOURCE_NAME,
    TITLE_TEXT,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.GRID_DATASOURCE_NAME,
    B.TITLE_TEXT,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from JTF_GRID_DATASOURCES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from JTF_GRID_DATASOURCES_TL T
    where T.GRID_DATASOURCE_NAME = B.GRID_DATASOURCE_NAME
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure LOAD_ROW (
  X_GRID_DATASOURCE_NAME in VARCHAR2,
  X_DB_VIEW_NAME in VARCHAR2,
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_DEFAULT_ROW_HEIGHT in NUMBER,
  X_MAX_QUERIED_ROWS in NUMBER,
  X_WHERE_CLAUSE in VARCHAR2,
  X_ALT_COLOR_CODE in VARCHAR2,
  X_ALT_COLOR_INTERVAL in NUMBER,
  X_TITLE_TEXT in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_FETCH_SIZE in NUMBER,
  X_CUSTOM_MODE in VARCHAR2,
  X_LAST_UPDATE_DATE in VARCHAR2
) is
  row_id      varchar2(64);
  owner_appid number;
  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db
begin

    select APPLICATION_ID
    into owner_appid
    from FND_APPLICATION
    where APPLICATION_SHORT_NAME = X_APPLICATION_SHORT_NAME;


        -- Translate owner to file_last_updated_by
        f_luby := fnd_load_util.owner_id(X_OWNER);

        -- Translate char last_update_date to date
        f_ludate := nvl(to_date(X_LAST_UPDATE_DATE, 'YYYY/MM/DD'), sysdate);


     begin
          select LAST_UPDATED_BY, LAST_UPDATE_DATE
          into db_luby, db_ludate
          from JTF_GRID_DATASOURCES_B
          where GRID_DATASOURCE_NAME = x_grid_datasource_name;

          -- Test for customization and version
          if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                        db_ludate, X_CUSTOM_MODE)) then

          -- test if the metadata can be uploaded
       --  if (test_for_upload(X_CUSTOM_MODE, user, X_GRID_DATASOURCE_NAME)) then


            delete_row_preserve_custom(x_grid_datasource_name);

            INSERT_ROW (X_ROWID => row_id
                       ,X_GRID_DATASOURCE_NAME => X_GRID_DATASOURCE_NAME
                       ,X_DB_VIEW_NAME => X_DB_VIEW_NAME
                       ,X_APPLICATION_ID => owner_appid
                       ,X_DEFAULT_ROW_HEIGHT => X_DEFAULT_ROW_HEIGHT
                       ,X_MAX_QUERIED_ROWS => X_MAX_QUERIED_ROWS
                       ,X_WHERE_CLAUSE => X_WHERE_CLAUSE
                       ,X_ALT_COLOR_CODE => X_ALT_COLOR_CODE
                       ,X_ALT_COLOR_INTERVAL => X_ALT_COLOR_INTERVAL
                       ,X_TITLE_TEXT => X_TITLE_TEXT
                       ,X_CREATION_DATE => f_ludate
                       ,X_CREATED_BY => f_luby
                       ,X_LAST_UPDATE_DATE => f_ludate
                       ,X_LAST_UPDATED_BY => f_luby
                       ,X_LAST_UPDATE_LOGIN => 0
                       ,X_FETCH_SIZE => X_FETCH_SIZE);
/*
    UPDATE_ROW (X_GRID_DATASOURCE_NAME => X_GRID_DATASOURCE_NAME
    ,X_DB_VIEW_NAME => X_DB_VIEW_NAME
    ,X_APPLICATION_ID => owner_appid
    ,X_DEFAULT_ROW_HEIGHT => X_DEFAULT_ROW_HEIGHT
    ,X_MAX_QUERIED_ROWS => X_MAX_QUERIED_ROWS
    ,X_WHERE_CLAUSE => X_WHERE_CLAUSE
    ,X_ALT_COLOR_CODE => X_ALT_COLOR_CODE
    ,X_ALT_COLOR_INTERVAL => X_ALT_COLOR_INTERVAL
    ,X_TITLE_TEXT => X_TITLE_TEXT
    ,X_LAST_UPDATE_DATE => f_ludate
    ,X_LAST_UPDATED_BY =>  f_luby
    ,X_LAST_UPDATE_LOGIN => 0
    ,X_FETCH_SIZE => X_FETCH_SIZE);
*/
             end if;

exception
  when no_data_found then
   null;

            INSERT_ROW (X_ROWID => row_id
                       ,X_GRID_DATASOURCE_NAME => X_GRID_DATASOURCE_NAME
                       ,X_DB_VIEW_NAME => X_DB_VIEW_NAME
                       ,X_APPLICATION_ID => owner_appid
                       ,X_DEFAULT_ROW_HEIGHT => X_DEFAULT_ROW_HEIGHT
                       ,X_MAX_QUERIED_ROWS => X_MAX_QUERIED_ROWS
                       ,X_WHERE_CLAUSE => X_WHERE_CLAUSE
                       ,X_ALT_COLOR_CODE => X_ALT_COLOR_CODE
                       ,X_ALT_COLOR_INTERVAL => X_ALT_COLOR_INTERVAL
                       ,X_TITLE_TEXT => X_TITLE_TEXT
                       ,X_CREATION_DATE => f_ludate
                       ,X_CREATED_BY => f_luby
                       ,X_LAST_UPDATE_DATE => f_ludate
                       ,X_LAST_UPDATED_BY => f_luby
                       ,X_LAST_UPDATE_LOGIN => 0
                       ,X_FETCH_SIZE => X_FETCH_SIZE);

--  end if;
  end;
end LOAD_ROW;
procedure TRANSLATE_ROW (
  X_GRID_DATASOURCE_NAME in VARCHAR2,
  X_TITLE_TEXT in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2,
  X_LAST_UPDATE_DATE in VARCHAR2
) is

  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db

begin

    -- Translate owner to file_last_updated_by
    f_luby := fnd_load_util.owner_id(X_OWNER);

    -- Translate char last_update_date to date
    f_ludate := nvl(to_date(X_LAST_UPDATE_DATE, 'YYYY/MM/DD'), sysdate);


    select LAST_UPDATED_BY, LAST_UPDATE_DATE
    into db_luby, db_ludate
    from JTF_GRID_DATASOURCES_TL
    where GRID_DATASOURCE_NAME = x_grid_datasource_name
    and LANGUAGE = userenv('LANG');

 -- Test for customization and version
    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                        db_ludate, X_CUSTOM_MODE)) then
      begin

         update JTF_GRID_DATASOURCES_TL
         set TITLE_TEXT = X_TITLE_TEXT
            ,LAST_UPDATE_DATE = f_ludate
            ,LAST_UPDATED_BY = f_luby
            ,LAST_UPDATE_LOGIN = 0
            ,SOURCE_LANG = userenv('LANG')
         where userenv('LANG') in (LANGUAGE,SOURCE_LANG)
         and GRID_DATASOURCE_NAME = X_GRID_DATASOURCE_NAME;

      exception
          when no_data_found then
            -- Do not insert missing translations, skip this row
            null;
       end;
     end if;
end TRANSLATE_ROW;
PROCEDURE CHECK_UNIQUE(X_ROWID in VARCHAR2, X_GRID_DATASOURCE_NAME in varchar2) is
  DUMMY NUMBER;
BEGIN
  SELECT COUNT(1)
  INTO DUMMY
  FROM jtf_grid_datasources_vl
  WHERE grid_datasource_name = X_GRID_DATASOURCE_NAME
  AND ((X_ROWID IS NULL) OR (ROWID <> X_ROWID));

  IF (DUMMY >= 1) then
    FND_MESSAGE.SET_NAME('JTF', 'JTF_GRID_UNIQUE_DATASOURCE');
    FND_MESSAGE.SET_TOKEN('DATASOURCE', X_GRID_DATASOURCE_NAME);
    APP_EXCEPTION.RAISE_EXCEPTION;
  END IF;
END CHECK_UNIQUE;

--
-- TEST_FOR_UPLOAD
--   Test whether or not to over-write database row when uploading
--   data from FNDLOAD data file
-- RETURNS
--   TRUE if safe to over-write.

function test_for_upload(p_custom_mode IN VARCHAR2,
                         p_owner IN NUMBER,
                     p_datasource_name IN VARCHAR2) return boolean is
 l_last_updated_by number;
begin
  -- if custom_mode is force return TRUE
  if p_custom_mode is not NULL and p_custom_mode = 'FORCE' then
    return TRUE;
  else
    -- if the last_updated_by is not 'SEED' return false
    select last_updated_by
    into l_last_updated_by
    from jtf_grid_datasources_b
    where grid_datasource_name = p_datasource_name;

    if l_last_updated_by <> p_owner then
       return FALSE;
    else
       return TRUE;
      /*
       -- if customizations exist return FALSE
       select 'x'
       into l_custom_exists
       from jtf_custom_grids
       where grid_Datasource_name = p_datasource_name;

       if l_custom_exists = 'x' then
         return FALSE;
       else
         return TRUE;
       end if;
      */
    end if;
  end if;
exception
  when no_data_found then
    return TRUE;
end test_for_upload;

end JTF_GRID_DATASOURCES_PKG;

/
