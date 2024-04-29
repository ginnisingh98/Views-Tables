--------------------------------------------------------
--  DDL for Package Body BNE_SIMPLE_QUERY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BNE_SIMPLE_QUERY_PKG" as
/* $Header: bnesimplequeryb.pls 120.2 2005/06/29 03:41:01 dvayro noship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_QUERY_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ID_COL in VARCHAR2,
  X_ID_COL_ALIAS in VARCHAR2,
  X_MEANING_COL in VARCHAR2,
  X_MEANING_COL_ALIAS in VARCHAR2,
  X_DESCRIPTION_COL in VARCHAR2,
  X_DESCRIPTION_COL_ALIAS in VARCHAR2,
  X_ADDITIONAL_COLS in VARCHAR2,
  X_OBJECT_NAME in VARCHAR2,
  X_ADDITIONAL_WHERE_CLAUSE in VARCHAR2,
  X_ORDER_BY_CLAUSE in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from BNE_SIMPLE_QUERY
    where APPLICATION_ID = X_APPLICATION_ID
    and QUERY_CODE = X_QUERY_CODE
    ;
begin
  insert into BNE_SIMPLE_QUERY (
    APPLICATION_ID,
    QUERY_CODE,
    OBJECT_VERSION_NUMBER,
    ID_COL,
    ID_COL_ALIAS,
    MEANING_COL,
    MEANING_COL_ALIAS,
    DESCRIPTION_COL,
    DESCRIPTION_COL_ALIAS,
    ADDITIONAL_COLS,
    OBJECT_NAME,
    ADDITIONAL_WHERE_CLAUSE,
    ORDER_BY_CLAUSE,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LAST_UPDATE_DATE
  ) values (
    X_APPLICATION_ID,
    X_QUERY_CODE,
    X_OBJECT_VERSION_NUMBER,
    X_ID_COL,
    X_ID_COL_ALIAS,
    X_MEANING_COL,
    X_MEANING_COL_ALIAS,
    X_DESCRIPTION_COL,
    X_DESCRIPTION_COL_ALIAS,
    X_ADDITIONAL_COLS,
    X_OBJECT_NAME,
    X_ADDITIONAL_WHERE_CLAUSE,
    X_ORDER_BY_CLAUSE,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_LAST_UPDATE_DATE
  );

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_APPLICATION_ID in NUMBER,
  X_QUERY_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ID_COL in VARCHAR2,
  X_ID_COL_ALIAS in VARCHAR2,
  X_MEANING_COL in VARCHAR2,
  X_MEANING_COL_ALIAS in VARCHAR2,
  X_DESCRIPTION_COL in VARCHAR2,
  X_DESCRIPTION_COL_ALIAS in VARCHAR2,
  X_ADDITIONAL_COLS in VARCHAR2,
  X_OBJECT_NAME in VARCHAR2,
  X_ADDITIONAL_WHERE_CLAUSE in VARCHAR2,
  X_ORDER_BY_CLAUSE in VARCHAR2
) is
  cursor c1 is select
      OBJECT_VERSION_NUMBER,
      ID_COL,
      ID_COL_ALIAS,
      MEANING_COL,
      MEANING_COL_ALIAS,
      DESCRIPTION_COL,
      DESCRIPTION_COL_ALIAS,
      ADDITIONAL_COLS,
      OBJECT_NAME,
      ADDITIONAL_WHERE_CLAUSE,
      ORDER_BY_CLAUSE
    from BNE_SIMPLE_QUERY
    where APPLICATION_ID = X_APPLICATION_ID
    and QUERY_CODE = X_QUERY_CODE
    for update of APPLICATION_ID nowait;
begin
  for tlinfo in c1 loop
    if (    (tlinfo.ID_COL_ALIAS = X_ID_COL_ALIAS)
        AND (tlinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
        AND (tlinfo.ID_COL = X_ID_COL)
        AND (tlinfo.MEANING_COL = X_MEANING_COL)
        AND (tlinfo.MEANING_COL_ALIAS = X_MEANING_COL_ALIAS)
        AND ((tlinfo.DESCRIPTION_COL = X_DESCRIPTION_COL)
             OR ((tlinfo.DESCRIPTION_COL is null) AND (X_DESCRIPTION_COL is null)))
        AND ((tlinfo.DESCRIPTION_COL_ALIAS = X_DESCRIPTION_COL_ALIAS)
             OR ((tlinfo.DESCRIPTION_COL_ALIAS is null) AND (X_DESCRIPTION_COL_ALIAS is null)))
        AND ((tlinfo.ADDITIONAL_COLS = X_ADDITIONAL_COLS)
             OR ((tlinfo.ADDITIONAL_COLS is null) AND (X_ADDITIONAL_COLS is null)))
        AND (tlinfo.OBJECT_NAME = X_OBJECT_NAME)
        AND ((tlinfo.ADDITIONAL_WHERE_CLAUSE = X_ADDITIONAL_WHERE_CLAUSE)
             OR ((tlinfo.ADDITIONAL_WHERE_CLAUSE is null) AND (X_ADDITIONAL_WHERE_CLAUSE is null)))
        AND ((tlinfo.ORDER_BY_CLAUSE = X_ORDER_BY_CLAUSE)
             OR ((tlinfo.ORDER_BY_CLAUSE is null) AND (X_ORDER_BY_CLAUSE is null)))
    ) then
      null;
    else
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      app_exception.raise_exception;
    end if;
  end loop;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_QUERY_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ID_COL in VARCHAR2,
  X_ID_COL_ALIAS in VARCHAR2,
  X_MEANING_COL in VARCHAR2,
  X_MEANING_COL_ALIAS in VARCHAR2,
  X_DESCRIPTION_COL in VARCHAR2,
  X_DESCRIPTION_COL_ALIAS in VARCHAR2,
  X_ADDITIONAL_COLS in VARCHAR2,
  X_OBJECT_NAME in VARCHAR2,
  X_ADDITIONAL_WHERE_CLAUSE in VARCHAR2,
  X_ORDER_BY_CLAUSE in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update BNE_SIMPLE_QUERY set
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    ID_COL = X_ID_COL,
    ID_COL_ALIAS = X_ID_COL_ALIAS,
    MEANING_COL = X_MEANING_COL,
    MEANING_COL_ALIAS = X_MEANING_COL_ALIAS,
    DESCRIPTION_COL = X_DESCRIPTION_COL,
    DESCRIPTION_COL_ALIAS = X_DESCRIPTION_COL_ALIAS,
    ADDITIONAL_COLS = X_ADDITIONAL_COLS,
    OBJECT_NAME = X_OBJECT_NAME,
    ADDITIONAL_WHERE_CLAUSE = X_ADDITIONAL_WHERE_CLAUSE,
    ORDER_BY_CLAUSE = X_ORDER_BY_CLAUSE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where APPLICATION_ID = X_APPLICATION_ID
  and QUERY_CODE = X_QUERY_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_QUERY_CODE in VARCHAR2
) is
begin
  delete from BNE_SIMPLE_QUERY
  where APPLICATION_ID = X_APPLICATION_ID
  and QUERY_CODE = X_QUERY_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  null;
end ADD_LANGUAGE;

--------------------------------------------------------------------------------
--  PROCEDURE:     LOAD_ROW                                                   --
--                                                                            --
--  DESCRIPTION:   Load a row into the BNE_SIMPLE_QUERY entity.               --
--                 This proc is called from the apps loader.                  --
--                                                                            --
--  SEE:     http://www-apps.us.oracle.com/atg/plans/r115/fndloadqr.txt       --
--                                                                            --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date       Username  Description                                          --
--  21-Apr-04  DGROVES   CREATED                                              --
--------------------------------------------------------------------------------
procedure LOAD_ROW (
  x_query_asn             IN VARCHAR2,
  x_query_code            IN VARCHAR2,
  x_object_version_number IN VARCHAR2,
  x_id_col                IN VARCHAR2,
  x_id_col_alias          IN VARCHAR2,
  x_meaning_col           IN VARCHAR2,
  x_meaning_col_alias     IN VARCHAR2,
  x_description_col       IN VARCHAR2,
  x_description_col_alias IN VARCHAR2,
  x_additional_cols       IN VARCHAR2,
  x_object_name           IN VARCHAR2,
  x_additional_where_clause IN VARCHAR2,
  x_order_by_clause       IN VARCHAR2,
  x_owner                 IN VARCHAR2,
  x_last_update_date      IN VARCHAR2,
  x_custom_mode           IN VARCHAR2
)
is
  l_app_id            number;
  l_row_id            varchar2(64);
  f_luby              number;  -- entity owner in file
  f_ludate            date;    -- entity update date in file
  db_luby             number;  -- entity owner in db
  db_ludate           date;    -- entity update date in db
begin
  -- translate values to IDs
  l_app_id            := BNE_LCT_TOOLS_PKG.ASN_TO_APP_ID(x_query_asn);

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);
  begin
    select LAST_UPDATED_BY, LAST_UPDATE_DATE
    into db_luby, db_ludate
    from BNE_SIMPLE_QUERY
    where APPLICATION_ID  = l_app_id
    and   QUERY_CODE      = x_query_code;

    -- Test for customization and version
    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, x_custom_mode)) then
      -- Update existing row
      BNE_SIMPLE_QUERY_PKG.Update_Row(
        X_APPLICATION_ID        => l_app_id,
        X_QUERY_CODE            => x_query_code,
        X_OBJECT_VERSION_NUMBER => x_object_version_number,
        X_ID_COL                => x_id_col,
        X_ID_COL_ALIAS          => x_id_col_alias,
        X_MEANING_COL           => x_meaning_col,
        X_MEANING_COL_ALIAS     => x_meaning_col_alias,
        X_DESCRIPTION_COL       => x_description_col,
        X_DESCRIPTION_COL_ALIAS => x_description_col_alias,
        X_ADDITIONAL_COLS       => x_additional_cols,
        X_OBJECT_NAME           => x_object_name,
        X_ADDITIONAL_WHERE_CLAUSE => x_additional_where_clause,
        X_ORDER_BY_CLAUSE       => x_order_by_clause,
        X_LAST_UPDATE_DATE      => f_ludate,
        X_LAST_UPDATED_BY       => f_luby,
        X_LAST_UPDATE_LOGIN     => 0
      );

    end if;
  exception
    when no_data_found then
      -- Record doesn't exist - insert in all cases
      BNE_SIMPLE_QUERY_PKG.Insert_Row(
        X_ROWID                 => l_row_id,
        X_APPLICATION_ID        => l_app_id,
        X_QUERY_CODE            => x_query_code,
        X_OBJECT_VERSION_NUMBER => x_object_version_number,
        X_ID_COL                => x_id_col,
        X_ID_COL_ALIAS          => x_id_col_alias,
        X_MEANING_COL           => x_meaning_col,
        X_MEANING_COL_ALIAS     => x_meaning_col_alias,
        X_DESCRIPTION_COL       => x_description_col,
        X_DESCRIPTION_COL_ALIAS => x_description_col_alias,
        X_ADDITIONAL_COLS       => x_additional_cols,
        X_OBJECT_NAME           => x_object_name,
        X_ADDITIONAL_WHERE_CLAUSE => x_additional_where_clause,
        X_ORDER_BY_CLAUSE       => x_order_by_clause,
        X_CREATION_DATE         => f_ludate,
        X_CREATED_BY            => f_luby,
        X_LAST_UPDATE_DATE      => f_ludate,
        X_LAST_UPDATED_BY       => f_luby,
        X_LAST_UPDATE_LOGIN     => 0
      );
  end;
end LOAD_ROW;


end BNE_SIMPLE_QUERY_PKG;

/
