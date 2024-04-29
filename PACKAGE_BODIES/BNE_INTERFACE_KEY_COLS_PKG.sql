--------------------------------------------------------
--  DDL for Package Body BNE_INTERFACE_KEY_COLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BNE_INTERFACE_KEY_COLS_PKG" as
/* $Header: bneintkeycolb.pls 120.2 2005/06/29 03:40:06 dvayro noship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_KEY_CODE in VARCHAR2,
  X_SEQUENCE_NUM in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_INTERFACE_APP_ID in NUMBER,
  X_INTERFACE_CODE in VARCHAR2,
  X_INTERFACE_SEQ_NUM in NUMBER,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from BNE_INTERFACE_KEY_COLS
    where APPLICATION_ID = X_APPLICATION_ID
    and KEY_CODE = X_KEY_CODE
    and SEQUENCE_NUM = X_SEQUENCE_NUM
    ;
begin
  insert into BNE_INTERFACE_KEY_COLS (
    APPLICATION_ID,
    KEY_CODE,
    SEQUENCE_NUM,
    OBJECT_VERSION_NUMBER,
    INTERFACE_APP_ID,
    INTERFACE_CODE,
    INTERFACE_SEQ_NUM,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LAST_UPDATE_DATE
  ) values (
    X_APPLICATION_ID,
    X_KEY_CODE,
    X_SEQUENCE_NUM,
    X_OBJECT_VERSION_NUMBER,
    X_INTERFACE_APP_ID,
    X_INTERFACE_CODE,
    X_INTERFACE_SEQ_NUM,
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
  X_KEY_CODE in VARCHAR2,
  X_SEQUENCE_NUM in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_INTERFACE_APP_ID in NUMBER,
  X_INTERFACE_CODE in VARCHAR2,
  X_INTERFACE_SEQ_NUM in NUMBER
) is
  cursor c1 is select
      OBJECT_VERSION_NUMBER,
      INTERFACE_APP_ID,
      INTERFACE_CODE,
      INTERFACE_SEQ_NUM
    from BNE_INTERFACE_KEY_COLS
    where APPLICATION_ID = X_APPLICATION_ID
    and KEY_CODE = X_KEY_CODE
    and SEQUENCE_NUM = X_SEQUENCE_NUM
    for update of APPLICATION_ID nowait;
begin
  for tlinfo in c1 loop
    if ((tlinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
        AND (tlinfo.INTERFACE_APP_ID = X_INTERFACE_APP_ID)
        AND (tlinfo.INTERFACE_CODE = X_INTERFACE_CODE)
        AND (tlinfo.INTERFACE_SEQ_NUM = X_INTERFACE_SEQ_NUM)
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
  X_KEY_CODE in VARCHAR2,
  X_SEQUENCE_NUM in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_INTERFACE_APP_ID in NUMBER,
  X_INTERFACE_CODE in VARCHAR2,
  X_INTERFACE_SEQ_NUM in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update BNE_INTERFACE_KEY_COLS set
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    INTERFACE_APP_ID      = X_INTERFACE_APP_ID,
    INTERFACE_CODE        = X_INTERFACE_CODE,
    INTERFACE_SEQ_NUM     = X_INTERFACE_SEQ_NUM,
    LAST_UPDATE_DATE      = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY       = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN     = X_LAST_UPDATE_LOGIN
  where APPLICATION_ID = X_APPLICATION_ID
  and KEY_CODE         = X_KEY_CODE
  and SEQUENCE_NUM     = X_SEQUENCE_NUM
  ;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_KEY_CODE in VARCHAR2,
  X_SEQUENCE_NUM in NUMBER
) is
begin
  delete from BNE_INTERFACE_KEY_COLS
  where APPLICATION_ID = X_APPLICATION_ID
  and KEY_CODE = X_KEY_CODE
  and SEQUENCE_NUM = X_SEQUENCE_NUM;

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
--  DESCRIPTION:   Load a row into the BNE_INTERFACE_KEY_COLS entity.         --
--                 This proc is called from the apps loader.                  --
--                                                                            --
--  SEE:     http://www-apps.us.oracle.com/atg/plans/r115/fndloadqr.txt       --
--                                                                            --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date       Username  Description                                          --
--  28-May-04  DGROVES   CREATED                                              --
--------------------------------------------------------------------------------
procedure LOAD_ROW(
  x_key_asn                     in VARCHAR2,
  x_key_code                    in VARCHAR2,
  x_sequence_num                in VARCHAR2,
  x_object_version_number       in VARCHAR2,
  x_interface_asn               in VARCHAR2,
  x_interface_code              in VARCHAR2,
  x_interface_seq_num           in VARCHAR2,
  x_owner                       in VARCHAR2,
  x_last_update_date            in VARCHAR2,
  x_custom_mode                 in VARCHAR2
)
is
  l_app_id            number;
  l_interface_app_id  number;
  l_row_id            varchar2(64);
  f_luby              number;  -- entity owner in file
  f_ludate            date;    -- entity update date in file
  db_luby             number;  -- entity owner in db
  db_ludate           date;    -- entity update date in db
begin
  -- translate values to IDs
  l_app_id             := BNE_LCT_TOOLS_PKG.ASN_TO_APP_ID(x_key_asn);
  l_interface_app_id   := BNE_LCT_TOOLS_PKG.ASN_TO_APP_ID(x_interface_asn);

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);
  begin
    select LAST_UPDATED_BY, LAST_UPDATE_DATE
    into db_luby, db_ludate
    from BNE_INTERFACE_KEY_COLS
    where APPLICATION_ID  = l_app_id
    and   KEY_CODE        = x_key_code
    and   SEQUENCE_NUM    = x_sequence_num;

    -- Test for customization and version
    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, x_custom_mode)) then
      -- Update existing row
      BNE_INTERFACE_KEY_COLS_PKG.Update_Row(
        X_APPLICATION_ID           => l_app_id,
        X_KEY_CODE                 => x_key_code,
        X_SEQUENCE_NUM             => x_sequence_num,
        X_OBJECT_VERSION_NUMBER    => x_object_version_number,
        X_INTERFACE_APP_ID         => l_interface_app_id,
        X_INTERFACE_CODE           => x_interface_code,
        X_INTERFACE_SEQ_NUM        => x_interface_seq_num,
        X_LAST_UPDATE_DATE         => f_ludate,
        X_LAST_UPDATED_BY          => f_luby,
        X_LAST_UPDATE_LOGIN        => 0
      );
    end if;
  exception
    when no_data_found then
      -- Record doesn't exist - insert in all cases
      BNE_INTERFACE_KEY_COLS_PKG.Insert_Row(
        X_ROWID                    => l_row_id,
        X_APPLICATION_ID           => l_app_id,
        X_KEY_CODE                 => x_key_code,
        X_SEQUENCE_NUM             => x_sequence_num,
        X_OBJECT_VERSION_NUMBER    => x_object_version_number,
        X_INTERFACE_APP_ID         => l_interface_app_id,
        X_INTERFACE_CODE           => x_interface_code,
        X_INTERFACE_SEQ_NUM        => x_interface_seq_num,
        X_CREATION_DATE            => f_ludate,
        X_CREATED_BY               => f_luby,
        X_LAST_UPDATE_DATE         => f_ludate,
        X_LAST_UPDATED_BY          => f_luby,
        X_LAST_UPDATE_LOGIN        => 0
      );
  end;
end LOAD_ROW;

end BNE_INTERFACE_KEY_COLS_PKG;

/
