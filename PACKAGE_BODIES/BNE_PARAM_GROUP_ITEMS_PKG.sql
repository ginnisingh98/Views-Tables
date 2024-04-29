--------------------------------------------------------
--  DDL for Package Body BNE_PARAM_GROUP_ITEMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BNE_PARAM_GROUP_ITEMS_PKG" as
/* $Header: bnepargib.pls 120.2 2005/06/29 03:40:36 dvayro noship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_PARAM_LIST_CODE in VARCHAR2,
  X_GROUP_SEQ_NUM in NUMBER,
  X_SEQUENCE_NUM in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_PARAM_SEQ_NUM in NUMBER,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from BNE_PARAM_GROUP_ITEMS
    where APPLICATION_ID = X_APPLICATION_ID
    and PARAM_LIST_CODE = X_PARAM_LIST_CODE
    and GROUP_SEQ_NUM = X_GROUP_SEQ_NUM
    and SEQUENCE_NUM = X_SEQUENCE_NUM
    ;
begin
  insert into BNE_PARAM_GROUP_ITEMS (
    APPLICATION_ID,
    PARAM_LIST_CODE,
    GROUP_SEQ_NUM,
    SEQUENCE_NUM,
    OBJECT_VERSION_NUMBER,
    PARAM_SEQ_NUM,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN
  ) values (
    X_APPLICATION_ID,
    X_PARAM_LIST_CODE,
    X_GROUP_SEQ_NUM,
    X_SEQUENCE_NUM,
    X_OBJECT_VERSION_NUMBER,
    X_PARAM_SEQ_NUM,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN
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
  X_PARAM_LIST_CODE in VARCHAR2,
  X_GROUP_SEQ_NUM in NUMBER,
  X_SEQUENCE_NUM in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_PARAM_SEQ_NUM in NUMBER
) is
  cursor c1 is select
      OBJECT_VERSION_NUMBER,
      PARAM_SEQ_NUM
    from BNE_PARAM_GROUP_ITEMS
    where APPLICATION_ID = X_APPLICATION_ID
    and PARAM_LIST_CODE = X_PARAM_LIST_CODE
    and GROUP_SEQ_NUM = X_GROUP_SEQ_NUM
    and SEQUENCE_NUM = X_SEQUENCE_NUM
    for update of APPLICATION_ID nowait;
begin
  for tlinfo in c1 loop
    if (    (tlinfo.PARAM_SEQ_NUM = X_PARAM_SEQ_NUM)
        AND (tlinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
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
  X_PARAM_LIST_CODE in VARCHAR2,
  X_GROUP_SEQ_NUM in NUMBER,
  X_SEQUENCE_NUM in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_PARAM_SEQ_NUM in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update BNE_PARAM_GROUP_ITEMS set
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    PARAM_SEQ_NUM = X_PARAM_SEQ_NUM,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where APPLICATION_ID = X_APPLICATION_ID
  and PARAM_LIST_CODE = X_PARAM_LIST_CODE
  and GROUP_SEQ_NUM = X_GROUP_SEQ_NUM
  and SEQUENCE_NUM = X_SEQUENCE_NUM
  ;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_PARAM_LIST_CODE in VARCHAR2,
  X_GROUP_SEQ_NUM in NUMBER,
  X_SEQUENCE_NUM in NUMBER
) is
begin
  delete from BNE_PARAM_GROUP_ITEMS
  where APPLICATION_ID = X_APPLICATION_ID
  and PARAM_LIST_CODE = X_PARAM_LIST_CODE
  and GROUP_SEQ_NUM = X_GROUP_SEQ_NUM
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
--  DESCRIPTION:   Load a row into the BNE_PARAM_GROUP_ITEMS entity.          --
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
  x_param_list_asn        IN VARCHAR2,
  x_param_list_code       IN VARCHAR2,
  x_group_seq_num         IN VARCHAR2,
  x_sequence_num          IN VARCHAR2,
  x_object_version_number IN VARCHAR2,
  x_param_seq_num         IN VARCHAR2,
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
  l_app_id            := BNE_LCT_TOOLS_PKG.ASN_TO_APP_ID(x_param_list_asn);

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);
  begin
    select LAST_UPDATED_BY, LAST_UPDATE_DATE
    into db_luby, db_ludate
    from BNE_PARAM_GROUP_ITEMS
    where APPLICATION_ID  = l_app_id
    and   PARAM_LIST_CODE = x_param_list_code
    and   GROUP_SEQ_NUM   = x_group_seq_num
    and   SEQUENCE_NUM    = x_sequence_num;

    -- Test for customization and version
    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, x_custom_mode)) then
      -- Update existing row
      BNE_PARAM_GROUP_ITEMS_PKG.Update_Row(
        X_APPLICATION_ID        => l_app_id,
        X_PARAM_LIST_CODE       => x_param_list_code,
        X_GROUP_SEQ_NUM         => x_group_seq_num,
        X_SEQUENCE_NUM          => x_sequence_num,
        X_OBJECT_VERSION_NUMBER => x_object_version_number,
        X_PARAM_SEQ_NUM         => x_param_seq_num,
        X_LAST_UPDATE_DATE      => f_ludate,
        X_LAST_UPDATED_BY       => f_luby,
        X_LAST_UPDATE_LOGIN     => 0
      );
    end if;
  exception
    when no_data_found then
      -- Record doesn't exist - insert in all cases
      BNE_PARAM_GROUP_ITEMS_PKG.Insert_Row(
        X_ROWID                 => l_row_id,
        X_APPLICATION_ID        => l_app_id,
        X_PARAM_LIST_CODE       => x_param_list_code,
        X_GROUP_SEQ_NUM         => x_group_seq_num,
        X_SEQUENCE_NUM          => x_sequence_num,
        X_OBJECT_VERSION_NUMBER => x_object_version_number,
        X_PARAM_SEQ_NUM         => x_param_seq_num,
        X_CREATION_DATE         => f_ludate,
        X_CREATED_BY            => f_luby,
        X_LAST_UPDATE_DATE      => f_ludate,
        X_LAST_UPDATED_BY       => f_luby,
        X_LAST_UPDATE_LOGIN     => 0
      );
  end;
end LOAD_ROW;


end BNE_PARAM_GROUP_ITEMS_PKG;

/