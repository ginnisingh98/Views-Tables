--------------------------------------------------------
--  DDL for Package Body BNE_INTEGRATOR_VIEWERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BNE_INTEGRATOR_VIEWERS_PKG" as
/* $Header: bneintviewerb.pls 120.0 2005/08/18 07:09:51 dagroves noship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_INTEGRATOR_APP_ID in NUMBER,
  X_INTEGRATOR_CODE in VARCHAR2,
  X_VIEWER_APP_ID in NUMBER,
  X_VIEWER_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from BNE_INTEGRATOR_VIEWERS
    where INTEGRATOR_APP_ID = X_INTEGRATOR_APP_ID
    and INTEGRATOR_CODE = X_INTEGRATOR_CODE
    and VIEWER_APP_ID = X_VIEWER_APP_ID
    and VIEWER_CODE = X_VIEWER_CODE
    ;
begin
  insert into BNE_INTEGRATOR_VIEWERS (
    INTEGRATOR_APP_ID,
    INTEGRATOR_CODE,
    VIEWER_APP_ID,
    VIEWER_CODE,
    OBJECT_VERSION_NUMBER,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LAST_UPDATE_DATE
  ) values (
    X_INTEGRATOR_APP_ID,
    X_INTEGRATOR_CODE,
    X_VIEWER_APP_ID,
    X_VIEWER_CODE,
    X_OBJECT_VERSION_NUMBER,
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
  X_INTEGRATOR_APP_ID in NUMBER,
  X_INTEGRATOR_CODE in VARCHAR2,
  X_VIEWER_APP_ID in NUMBER,
  X_VIEWER_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER
) is
  cursor c1 is select
       INTEGRATOR_APP_ID,
       INTEGRATOR_CODE,
       VIEWER_APP_ID,
       VIEWER_CODE,
       OBJECT_VERSION_NUMBER
    from BNE_INTEGRATOR_VIEWERS
    where INTEGRATOR_APP_ID = X_INTEGRATOR_APP_ID
    and INTEGRATOR_CODE = X_INTEGRATOR_CODE
    and VIEWER_APP_ID = X_VIEWER_APP_ID
    and VIEWER_CODE = X_VIEWER_CODE
    for update of INTEGRATOR_APP_ID nowait;
begin
  for tlinfo in c1 loop
      if ((tlinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
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
  X_INTEGRATOR_APP_ID in NUMBER,
  X_INTEGRATOR_CODE in VARCHAR2,
  X_VIEWER_APP_ID in NUMBER,
  X_VIEWER_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update BNE_INTEGRATOR_VIEWERS set
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where INTEGRATOR_APP_ID = X_INTEGRATOR_APP_ID
  and INTEGRATOR_CODE = X_INTEGRATOR_CODE
  and VIEWER_APP_ID = X_VIEWER_APP_ID
  and VIEWER_CODE = X_VIEWER_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_INTEGRATOR_APP_ID in NUMBER,
  X_INTEGRATOR_CODE in VARCHAR2,
  X_VIEWER_APP_ID in NUMBER,
  X_VIEWER_CODE in VARCHAR2
) is
begin
  delete from BNE_INTEGRATOR_VIEWERS
  where INTEGRATOR_APP_ID = X_INTEGRATOR_APP_ID
  and INTEGRATOR_CODE = X_INTEGRATOR_CODE
  and VIEWER_APP_ID = X_VIEWER_APP_ID
  and VIEWER_CODE = X_VIEWER_CODE;

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
--  DESCRIPTION:   Load a row into the BNE_INTEGRATOR_VIEWERS entity.         --
--                 This proc is called from the apps loader.                  --
--                                                                            --
--  SEE:     http://www-apps.us.oracle.com/atg/plans/r115/fndloadqr.txt       --
--                                                                            --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date       Username  Description                                          --
--------------------------------------------------------------------------------
procedure LOAD_ROW(
  x_integrator_asn              in VARCHAR2,
  x_integrator_code             in VARCHAR2,
  x_viewer_asn                  in VARCHAR2,
  x_viewer_code                 in VARCHAR2,
  x_object_version_number       in VARCHAR2,
  x_owner                       in VARCHAR2,
  x_last_update_date            in VARCHAR2,
  x_custom_mode                 in VARCHAR2
)
is
  l_integrator_app_id   number;
  l_viewer_app_id       number;
  l_row_id              varchar2(64);
  f_luby                number;  -- entity owner in file
  f_ludate              date;    -- entity update date in file
  db_luby               number;  -- entity owner in db
  db_ludate             date;    -- entity update date in db
begin
  -- translate values to IDs
  l_integrator_app_id := BNE_LCT_TOOLS_PKG.ASN_TO_APP_ID(x_integrator_asn);
  l_viewer_app_id     := BNE_LCT_TOOLS_PKG.ASN_TO_APP_ID(x_viewer_asn);

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);
  begin
    select LAST_UPDATED_BY, LAST_UPDATE_DATE
    into db_luby, db_ludate
    from BNE_INTEGRATOR_VIEWERS
    where INTEGRATOR_APP_ID = l_integrator_app_id
    and INTEGRATOR_CODE = x_integrator_code
    and VIEWER_APP_ID = l_viewer_app_id
    and VIEWER_CODE = x_viewer_code;

    -- Test for customization and version
    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, x_custom_mode)) then
      -- Update existing row
      BNE_INTEGRATOR_VIEWERS_PKG.Update_Row(
        X_INTEGRATOR_APP_ID     => l_integrator_app_id,
        X_INTEGRATOR_CODE       => x_integrator_code,
        X_VIEWER_APP_ID         => l_viewer_app_id,
        X_VIEWER_CODE           => x_viewer_code,
        X_OBJECT_VERSION_NUMBER => x_object_version_number,
        X_LAST_UPDATE_DATE      => f_ludate,
        X_LAST_UPDATED_BY       => f_luby,
        X_LAST_UPDATE_LOGIN     => 0
      );
    end if;
  exception
    when no_data_found then
      -- Record doesn't exist - insert in all cases
      BNE_INTEGRATOR_VIEWERS_PKG.Insert_Row(
        X_ROWID                 => l_row_id,
        X_INTEGRATOR_APP_ID     => l_integrator_app_id,
        X_INTEGRATOR_CODE       => x_integrator_code,
        X_VIEWER_APP_ID         => l_viewer_app_id,
        X_VIEWER_CODE           => x_viewer_code,
        X_OBJECT_VERSION_NUMBER => x_object_version_number,
        X_CREATION_DATE         => f_ludate,
        X_CREATED_BY            => f_luby,
        X_LAST_UPDATE_DATE      => f_ludate,
        X_LAST_UPDATED_BY       => f_luby,
        X_LAST_UPDATE_LOGIN     => 0
      );
  end;

end LOAD_ROW;


end BNE_INTEGRATOR_VIEWERS_PKG;

/
