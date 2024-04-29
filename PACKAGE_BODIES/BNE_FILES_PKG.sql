--------------------------------------------------------
--  DDL for Package Body BNE_FILES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BNE_FILES_PKG" as
/* $Header: bnefileb.pls 120.2 2005/06/29 03:39:56 dvayro noship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_CONTENT_CODE in VARCHAR2,
  X_USER_FILE_NAME in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_MIDDLE_TIER_FILE_NAME in VARCHAR2,
  X_START_LINE in NUMBER,
  X_COLUMN_DELIMITER_CHAR in VARCHAR2,
  X_IGNORE_CONSEC_DELIMS_FLAG in VARCHAR2,
  X_SEQUENCE_NUM in NUMBER,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from BNE_FILES
    where APPLICATION_ID = X_APPLICATION_ID
    and CONTENT_CODE = X_CONTENT_CODE
    and USER_FILE_NAME = X_USER_FILE_NAME
    ;
begin
  insert into BNE_FILES (
    OBJECT_VERSION_NUMBER,
    MIDDLE_TIER_FILE_NAME,
    USER_FILE_NAME,
    START_LINE,
    COLUMN_DELIMITER_CHAR,
    IGNORE_CONSEC_DELIMS_FLAG,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LAST_UPDATE_DATE,
    SEQUENCE_NUM,
    CONTENT_CODE,
    APPLICATION_ID
  ) values (
    X_OBJECT_VERSION_NUMBER,
    X_MIDDLE_TIER_FILE_NAME,
    X_USER_FILE_NAME,
    X_START_LINE,
    X_COLUMN_DELIMITER_CHAR,
    X_IGNORE_CONSEC_DELIMS_FLAG,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_LAST_UPDATE_DATE,
    X_SEQUENCE_NUM,
    X_CONTENT_CODE,
    X_APPLICATION_ID
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
  X_USER_FILE_NAME in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_MIDDLE_TIER_FILE_NAME in VARCHAR2,
  X_START_LINE in NUMBER,
  X_COLUMN_DELIMITER_CHAR in VARCHAR2,
  X_IGNORE_CONSEC_DELIMS_FLAG in VARCHAR2,
  X_SEQUENCE_NUM in NUMBER
) is
  cursor c1 is select
      OBJECT_VERSION_NUMBER,
      MIDDLE_TIER_FILE_NAME,
      START_LINE,
      COLUMN_DELIMITER_CHAR,
      IGNORE_CONSEC_DELIMS_FLAG,
      SEQUENCE_NUM,
      CONTENT_CODE
    from BNE_FILES
    where APPLICATION_ID = X_APPLICATION_ID
    and CONTENT_CODE = X_CONTENT_CODE
    and USER_FILE_NAME = X_USER_FILE_NAME
    for update of APPLICATION_ID nowait;
begin
  for tlinfo in c1 loop
      if (    (tlinfo.CONTENT_CODE = X_CONTENT_CODE)
          AND (tlinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
          AND (tlinfo.MIDDLE_TIER_FILE_NAME = X_MIDDLE_TIER_FILE_NAME)
          AND (tlinfo.START_LINE = X_START_LINE)
          AND (tlinfo.COLUMN_DELIMITER_CHAR = X_COLUMN_DELIMITER_CHAR)
          AND (tlinfo.IGNORE_CONSEC_DELIMS_FLAG = X_IGNORE_CONSEC_DELIMS_FLAG)
          AND (tlinfo.SEQUENCE_NUM = X_SEQUENCE_NUM)
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
  X_USER_FILE_NAME in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_MIDDLE_TIER_FILE_NAME in VARCHAR2,
  X_START_LINE in NUMBER,
  X_COLUMN_DELIMITER_CHAR in VARCHAR2,
  X_IGNORE_CONSEC_DELIMS_FLAG in VARCHAR2,
  X_SEQUENCE_NUM in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update BNE_FILES set
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    MIDDLE_TIER_FILE_NAME = X_MIDDLE_TIER_FILE_NAME,
    START_LINE = X_START_LINE,
    COLUMN_DELIMITER_CHAR = X_COLUMN_DELIMITER_CHAR,
    IGNORE_CONSEC_DELIMS_FLAG = X_IGNORE_CONSEC_DELIMS_FLAG,
    SEQUENCE_NUM = X_SEQUENCE_NUM,
    CONTENT_CODE = X_CONTENT_CODE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where APPLICATION_ID = X_APPLICATION_ID
  and CONTENT_CODE = X_CONTENT_CODE
  and USER_FILE_NAME = X_USER_FILE_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_CONTENT_CODE in VARCHAR2,
  X_USER_FILE_NAME in VARCHAR2
) is
begin
  delete from BNE_FILES
  where APPLICATION_ID = X_APPLICATION_ID
  and CONTENT_CODE = X_CONTENT_CODE
  and USER_FILE_NAME = X_USER_FILE_NAME;

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
--  DESCRIPTION:   Load a row into the BNE_FILES entity.                      --
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
  x_content_asn                 in VARCHAR2,
  x_content_code                in VARCHAR2,
  x_user_file_name              in VARCHAR2,
  x_object_version_number       in VARCHAR2,
  x_middle_tier_file_name       in VARCHAR2,
  x_start_line                  in VARCHAR2,
  x_column_delimiter_char       in VARCHAR2,
  x_ignore_consec_delims_flag   in VARCHAR2,
  x_sequence_num                in VARCHAR2,
  x_owner                       in VARCHAR2,
  x_last_update_date            in VARCHAR2,
  x_custom_mode                 in VARCHAR2
)
is
  l_app_id                      number;
  l_row_id                      varchar2(64);
  f_luby                        number;  -- entity owner in file
  f_ludate                      date;    -- entity update date in file
  db_luby                       number;  -- entity owner in db
  db_ludate                     date;    -- entity update date in db
begin
  -- translate values to IDs
  l_app_id                        := BNE_LCT_TOOLS_PKG.ASN_TO_APP_ID(x_content_asn);

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);
  begin
    select LAST_UPDATED_BY, LAST_UPDATE_DATE
    into db_luby, db_ludate
    from BNE_FILES
    where APPLICATION_ID = l_app_id
    and   CONTENT_CODE   = x_content_code
    and   USER_FILE_NAME = x_user_file_name;

    -- Test for customization and version
    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, x_custom_mode)) then
      -- Update existing row
      BNE_FILES_PKG.Update_Row(
        X_APPLICATION_ID               => l_app_id,
        X_CONTENT_CODE                 => x_content_code,
        X_USER_FILE_NAME               => x_user_file_name,
        X_OBJECT_VERSION_NUMBER        => x_object_version_number,
        X_MIDDLE_TIER_FILE_NAME        => x_middle_tier_file_name,
        X_START_LINE                   => x_start_line,
        X_COLUMN_DELIMITER_CHAR        => x_column_delimiter_char,
        X_IGNORE_CONSEC_DELIMS_FLAG    => x_ignore_consec_delims_flag,
        X_SEQUENCE_NUM                 => x_sequence_num,
        X_LAST_UPDATE_DATE             => f_ludate,
        X_LAST_UPDATED_BY              => f_luby,
        X_LAST_UPDATE_LOGIN            => 0
      );
    end if;
  exception
    when no_data_found then
      -- Record doesn't exist - insert in all cases
      BNE_FILES_PKG.Insert_Row(
        X_ROWID                        => l_row_id,
        X_APPLICATION_ID               => l_app_id,
        X_CONTENT_CODE                 => x_content_code,
        X_USER_FILE_NAME               => x_user_file_name,
        X_OBJECT_VERSION_NUMBER        => x_object_version_number,
        X_MIDDLE_TIER_FILE_NAME        => x_middle_tier_file_name,
        X_START_LINE                   => x_start_line,
        X_COLUMN_DELIMITER_CHAR        => x_column_delimiter_char,
        X_IGNORE_CONSEC_DELIMS_FLAG    => x_ignore_consec_delims_flag,
        X_SEQUENCE_NUM                 => x_sequence_num,
        X_CREATION_DATE                => f_ludate,
        X_CREATED_BY                   => f_luby,
        X_LAST_UPDATE_DATE             => f_ludate,
        X_LAST_UPDATED_BY              => f_luby,
        X_LAST_UPDATE_LOGIN            => 0
      );
  end;
end LOAD_ROW;

end BNE_FILES_PKG;

/
