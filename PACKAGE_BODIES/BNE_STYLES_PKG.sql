--------------------------------------------------------
--  DDL for Package Body BNE_STYLES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BNE_STYLES_PKG" as
/* $Header: bnestyleb.pls 120.2 2005/06/29 03:41:08 dvayro noship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_STYLE_CODE in VARCHAR2,
  X_PARENT_STYLE_CODE in VARCHAR2,
  X_PARENT_STYLE_APP_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_STYLESHEET_APP_ID in NUMBER,
  X_STYLESHEET_CODE in VARCHAR2,
  X_STYLE_CLASS in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from BNE_STYLES
    where APPLICATION_ID = X_APPLICATION_ID
    and STYLE_CODE = X_STYLE_CODE
    ;
begin
  insert into BNE_STYLES (
    PARENT_STYLE_CODE,
    PARENT_STYLE_APP_ID,
    APPLICATION_ID,
    STYLE_CODE,
    OBJECT_VERSION_NUMBER,
    STYLESHEET_APP_ID,
    STYLESHEET_CODE,
    STYLE_CLASS,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LAST_UPDATE_DATE
  ) values (
    X_PARENT_STYLE_CODE,
    X_PARENT_STYLE_APP_ID,
    X_APPLICATION_ID,
    X_STYLE_CODE,
    X_OBJECT_VERSION_NUMBER,
    X_STYLESHEET_APP_ID,
    X_STYLESHEET_CODE,
    X_STYLE_CLASS,
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
  X_STYLE_CODE in VARCHAR2,
  X_PARENT_STYLE_CODE in VARCHAR2,
  X_PARENT_STYLE_APP_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_STYLESHEET_APP_ID in NUMBER,
  X_STYLESHEET_CODE in VARCHAR2,
  X_STYLE_CLASS in VARCHAR2
) is
  cursor c1 is select
      PARENT_STYLE_CODE,
      PARENT_STYLE_APP_ID,
      OBJECT_VERSION_NUMBER,
      STYLESHEET_APP_ID,
      STYLESHEET_CODE,
      STYLE_CLASS
    from BNE_STYLES
    where APPLICATION_ID = X_APPLICATION_ID
    and STYLE_CODE = X_STYLE_CODE
    for update of APPLICATION_ID nowait;
begin
  for tlinfo in c1 loop
      if (    (tlinfo.STYLE_CLASS = X_STYLE_CLASS)
          AND ((tlinfo.PARENT_STYLE_CODE = X_PARENT_STYLE_CODE)
               OR ((tlinfo.PARENT_STYLE_CODE is null) AND (X_PARENT_STYLE_CODE is null)))
          AND ((tlinfo.PARENT_STYLE_APP_ID = X_PARENT_STYLE_APP_ID)
               OR ((tlinfo.PARENT_STYLE_APP_ID is null) AND (X_PARENT_STYLE_APP_ID is null)))
          AND (tlinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
          AND (tlinfo.STYLESHEET_APP_ID = X_STYLESHEET_APP_ID)
          AND (tlinfo.STYLESHEET_CODE = X_STYLESHEET_CODE)
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
  X_STYLE_CODE in VARCHAR2,
  X_PARENT_STYLE_CODE in VARCHAR2,
  X_PARENT_STYLE_APP_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_STYLESHEET_APP_ID in NUMBER,
  X_STYLESHEET_CODE in VARCHAR2,
  X_STYLE_CLASS in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update BNE_STYLES set
    PARENT_STYLE_CODE = X_PARENT_STYLE_CODE,
    PARENT_STYLE_APP_ID = X_PARENT_STYLE_APP_ID,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    STYLESHEET_APP_ID = X_STYLESHEET_APP_ID,
    STYLESHEET_CODE = X_STYLESHEET_CODE,
    STYLE_CLASS = X_STYLE_CLASS,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where APPLICATION_ID = X_APPLICATION_ID
  and STYLE_CODE = X_STYLE_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_STYLE_CODE in VARCHAR2
) is
begin
  delete from BNE_STYLES
  where APPLICATION_ID = X_APPLICATION_ID
  and STYLE_CODE = X_STYLE_CODE;

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
--  DESCRIPTION:   Load a row into the BNE_STYLES entity.                     --
--                 This proc is called from the apps loader.                  --
--                                                                            --
--  SEE: 	   http://www-apps.us.oracle.com/atg/plans/r115/fndloadqr.txt --
-- 									      --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date       Username  Description                                          --
--  1-Oct-02   DGROVES   CREATED                                              --
--------------------------------------------------------------------------------

procedure LOAD_ROW(
  x_style_asn             IN VARCHAR2,
  x_style_code            IN VARCHAR2,
  x_object_version_number IN VARCHAR2,
  x_stylesheet_asn        IN VARCHAR2,
  x_stylesheet_code       IN VARCHAR2,
  x_parent_style_asn      IN VARCHAR2,
  x_parent_style_code     IN VARCHAR2,
  x_style_class           IN VARCHAR2,
  x_owner                 IN VARCHAR2,
  x_last_update_date      IN VARCHAR2,
  x_custom_mode           IN VARCHAR2
)
is
  l_app_id          number;
  l_ss_app_id       number;
  l_par_app_id      number;
  l_row_id          varchar2(64);
  f_luby            number;  -- entity owner in file
  f_ludate          date;    -- entity update date in file
  db_luby           number;  -- entity owner in db
  db_ludate         date;    -- entity update date in db
begin
  -- translate values to IDs
  l_app_id       := BNE_LCT_TOOLS_PKG.ASN_TO_APP_ID(x_style_asn);
  l_ss_app_id    := BNE_LCT_TOOLS_PKG.ASN_TO_APP_ID(x_stylesheet_asn);
  l_par_app_id   := BNE_LCT_TOOLS_PKG.ASN_TO_APP_ID(x_parent_style_asn);

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);
  begin
    select LAST_UPDATED_BY, LAST_UPDATE_DATE
    into db_luby, db_ludate
    from BNE_STYLES
    where APPLICATION_ID = l_app_id
    and   STYLE_CODE     = x_style_code;

    -- Test for customization and version
    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, x_custom_mode)) then
      -- Update existing row
      BNE_STYLES_PKG.Update_Row(
        X_APPLICATION_ID        => l_app_id,
        X_STYLE_CODE            => x_style_code,
        X_PARENT_STYLE_CODE     => x_parent_style_code,
        X_PARENT_STYLE_APP_ID   => l_par_app_id,
        X_OBJECT_VERSION_NUMBER => x_object_version_number,
        X_STYLESHEET_APP_ID     => l_ss_app_id,
        X_STYLESHEET_CODE       => x_stylesheet_code,
        X_STYLE_CLASS           => x_style_class,
        X_LAST_UPDATE_DATE      => f_ludate,
        X_LAST_UPDATED_BY       => f_luby,
        X_LAST_UPDATE_LOGIN     => 0
      );
    end if;
  exception
    when no_data_found then
      -- Record doesn't exist - insert in all cases
      BNE_STYLES_PKG.Insert_Row(
        X_ROWID                 => l_row_id,
        X_APPLICATION_ID        => l_app_id,
        X_STYLE_CODE            => x_style_code,
        X_PARENT_STYLE_CODE     => x_parent_style_code,
        X_PARENT_STYLE_APP_ID   => l_par_app_id,
        X_OBJECT_VERSION_NUMBER => x_object_version_number,
        X_STYLESHEET_APP_ID     => l_ss_app_id,
        X_STYLESHEET_CODE       => x_stylesheet_code,
        X_STYLE_CLASS           => x_style_class,
        X_CREATION_DATE         => f_ludate,
        X_CREATED_BY            => f_luby,
        X_LAST_UPDATE_DATE      => f_ludate,
        X_LAST_UPDATED_BY       => f_luby,
        X_LAST_UPDATE_LOGIN     => 0
      );
  end;

end LOAD_ROW;

end BNE_STYLES_PKG;

/
