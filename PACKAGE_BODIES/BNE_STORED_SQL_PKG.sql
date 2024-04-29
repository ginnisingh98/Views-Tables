--------------------------------------------------------
--  DDL for Package Body BNE_STORED_SQL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BNE_STORED_SQL_PKG" as
/* $Header: bnestsqlb.pls 120.2 2005/06/29 03:41:06 dvayro noship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_CONTENT_CODE in VARCHAR2,
  X_QUERY in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_QUERY_APP_ID in NUMBER,
  X_QUERY_CODE in VARCHAR2
) is
  cursor C is select ROWID from BNE_STORED_SQL
    where APPLICATION_ID = X_APPLICATION_ID
    and CONTENT_CODE = X_CONTENT_CODE
    ;
begin
  insert into BNE_STORED_SQL (
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LAST_UPDATE_DATE,
    QUERY,
    CREATED_BY,
    CREATION_DATE,
    OBJECT_VERSION_NUMBER,
    APPLICATION_ID,
    CONTENT_CODE,
    QUERY_APP_ID,
    QUERY_CODE
  ) values (
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_LAST_UPDATE_DATE,
    X_QUERY,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_OBJECT_VERSION_NUMBER,
    X_APPLICATION_ID,
    X_CONTENT_CODE,
    X_QUERY_APP_ID,
    X_QUERY_CODE
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
  X_CONTENT_CODE in VARCHAR2,
  X_QUERY in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_QUERY_APP_ID in NUMBER,
  X_QUERY_CODE in VARCHAR2
) is
  cursor c1 is select
      QUERY,
      OBJECT_VERSION_NUMBER,
      QUERY_APP_ID,
      QUERY_CODE
    from BNE_STORED_SQL
    where APPLICATION_ID = X_APPLICATION_ID
    and CONTENT_CODE = X_CONTENT_CODE
    for update of APPLICATION_ID nowait;
begin
  for tlinfo in c1 loop
      if (    (tlinfo.QUERY = X_QUERY)
          AND (tlinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
      AND ((tlinfo.QUERY_APP_ID = X_QUERY_APP_ID)
           OR ((tlinfo.QUERY_APP_ID is null) AND (X_QUERY_APP_ID is null)))
      AND ((tlinfo.QUERY_CODE = X_QUERY_CODE)
           OR ((tlinfo.QUERY_CODE is null) AND (X_QUERY_CODE is null)))
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
  X_CONTENT_CODE in VARCHAR2,
  X_QUERY in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_QUERY_APP_ID in NUMBER,
  X_QUERY_CODE in VARCHAR2
) is
begin
  update BNE_STORED_SQL set
    QUERY = X_QUERY,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    CONTENT_CODE = X_CONTENT_CODE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    QUERY_APP_ID = X_QUERY_APP_ID,
    QUERY_CODE = X_QUERY_CODE
  where APPLICATION_ID = X_APPLICATION_ID
  and CONTENT_CODE = X_CONTENT_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_CONTENT_CODE in VARCHAR2
) is
begin
  delete from BNE_STORED_SQL
  where APPLICATION_ID = X_APPLICATION_ID
  and CONTENT_CODE = X_CONTENT_CODE;

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
--  DESCRIPTION:   Load a row into the BNE_STORED_SQL entity.                 --
--                 This proc is called from the apps loader.                  --
--                                                                            --
--  SEE:     http://www-apps.us.oracle.com/atg/plans/r115/fndloadqr.txt       --
--                                                                            --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date       Username  Description                                          --
--  1-Oct-02   DGROVES   CREATED                                              --
--------------------------------------------------------------------------------
procedure LOAD_ROW(
  x_content_asn           in VARCHAR2,
  x_content_code          in VARCHAR2,
  x_object_version_number in VARCHAR2,
  x_query                 in VARCHAR2,
  x_owner                 in VARCHAR2,
  x_last_update_date      in VARCHAR2,
  x_custom_mode           in VARCHAR2,
  x_query_app_asn         in VARCHAR2,
  x_query_code            in VARCHAR2
)
is
  l_app_id                    number;
  l_query_app_id              number;
  l_row_id                    varchar2(64);
  f_luby                      number;  -- entity owner in file
  f_ludate                    date;    -- entity update date in file
  db_luby                     number;  -- entity owner in db
  db_ludate                   date;    -- entity update date in db
begin
  -- translate values to IDs
  l_app_id            := BNE_LCT_TOOLS_PKG.ASN_TO_APP_ID(x_content_asn);
  l_query_app_id      := BNE_LCT_TOOLS_PKG.ASN_TO_APP_ID(x_query_app_asn);

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);
  begin
    select LAST_UPDATED_BY, LAST_UPDATE_DATE
    into db_luby, db_ludate
    from BNE_STORED_SQL
    where APPLICATION_ID  = l_app_id
    and   CONTENT_CODE    = x_content_code;

    -- Test for customization and version
    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, x_custom_mode)) then
      -- Update existing row
      BNE_STORED_SQL_PKG.Update_Row(
        X_APPLICATION_ID               => l_app_id,
        X_CONTENT_CODE                 => x_content_code,
        X_QUERY                        => x_query,
        X_OBJECT_VERSION_NUMBER        => x_object_version_number,
        X_LAST_UPDATE_DATE             => f_ludate,
        X_LAST_UPDATED_BY              => f_luby,
        X_LAST_UPDATE_LOGIN            => 0,
        X_QUERY_APP_ID                 => l_query_app_id,
        X_QUERY_CODE                   => x_query_code
      );
    end if;
  exception
    when no_data_found then
      -- Record doesn't exist - insert in all cases
      BNE_STORED_SQL_PKG.Insert_Row(
        X_ROWID                        => l_row_id,
        X_APPLICATION_ID               => l_app_id,
        X_CONTENT_CODE                 => x_content_code,
        X_QUERY                        => x_query,
        X_OBJECT_VERSION_NUMBER        => x_object_version_number,
        X_CREATION_DATE                => f_ludate,
        X_CREATED_BY                   => f_luby,
        X_LAST_UPDATE_DATE             => f_ludate,
        X_LAST_UPDATED_BY              => f_luby,
        X_LAST_UPDATE_LOGIN            => 0,
        X_QUERY_APP_ID                 => l_query_app_id,
        X_QUERY_CODE                   => x_query_code
      );
  end;
end LOAD_ROW;

end BNE_STORED_SQL_PKG;

/
