--------------------------------------------------------
--  DDL for Package Body BNE_LAYOUT_COLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BNE_LAYOUT_COLS_PKG" as
/* $Header: bnelaycolb.pls 120.3 2005/08/18 07:45:02 dagroves noship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_LAYOUT_CODE in VARCHAR2,
  X_BLOCK_ID in NUMBER,
  X_SEQUENCE_NUM in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_INTERFACE_APP_ID in NUMBER,
  X_INTERFACE_CODE in VARCHAR2,
  X_INTERFACE_SEQ_NUM in NUMBER,
  X_STYLE_CLASS in VARCHAR2,
  X_HINT_STYLE in VARCHAR2,
  X_HINT_STYLE_CLASS in VARCHAR2,
  X_PROMPT_STYLE in VARCHAR2,
  X_PROMPT_STYLE_CLASS in VARCHAR2,
  X_DEFAULT_TYPE in VARCHAR2,
  X_DEFAULT_VALUE in VARCHAR2,
  X_STYLE in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_DISPLAY_WIDTH in NUMBER,
  X_READ_ONLY_FLAG in VARCHAR2
) is
  cursor C is select ROWID from BNE_LAYOUT_COLS
    where APPLICATION_ID = X_APPLICATION_ID
    and LAYOUT_CODE = X_LAYOUT_CODE
    and BLOCK_ID = X_BLOCK_ID
    and SEQUENCE_NUM = X_SEQUENCE_NUM
    ;
begin
  insert into BNE_LAYOUT_COLS (
    APPLICATION_ID,
    LAYOUT_CODE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LAST_UPDATE_DATE,
    BLOCK_ID,
    OBJECT_VERSION_NUMBER,
    INTERFACE_APP_ID,
    INTERFACE_CODE,
    INTERFACE_SEQ_NUM,
    SEQUENCE_NUM,
    STYLE,
    STYLE_CLASS,
    HINT_STYLE,
    HINT_STYLE_CLASS,
    PROMPT_STYLE,
    PROMPT_STYLE_CLASS,
    DEFAULT_TYPE,
    DEFAULT_VALUE,
    DISPLAY_WIDTH,
	READ_ONLY_FLAG,
    CREATED_BY,
    CREATION_DATE
  ) values (
    X_APPLICATION_ID,
    X_LAYOUT_CODE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_LAST_UPDATE_DATE,
    X_BLOCK_ID,
    X_OBJECT_VERSION_NUMBER,
    X_INTERFACE_APP_ID,
    X_INTERFACE_CODE,
    X_INTERFACE_SEQ_NUM,
    X_SEQUENCE_NUM,
    X_STYLE,
    X_STYLE_CLASS,
    X_HINT_STYLE,
    X_HINT_STYLE_CLASS,
    X_PROMPT_STYLE,
    X_PROMPT_STYLE_CLASS,
    X_DEFAULT_TYPE,
    X_DEFAULT_VALUE,
    X_DISPLAY_WIDTH,
	X_READ_ONLY_FLAG,
    X_CREATED_BY,
    X_CREATION_DATE
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
  X_LAYOUT_CODE in VARCHAR2,
  X_BLOCK_ID in NUMBER,
  X_SEQUENCE_NUM in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_INTERFACE_APP_ID in NUMBER,
  X_INTERFACE_CODE in VARCHAR2,
  X_INTERFACE_SEQ_NUM in NUMBER,
  X_STYLE_CLASS in VARCHAR2,
  X_HINT_STYLE in VARCHAR2,
  X_HINT_STYLE_CLASS in VARCHAR2,
  X_PROMPT_STYLE in VARCHAR2,
  X_PROMPT_STYLE_CLASS in VARCHAR2,
  X_DEFAULT_TYPE in VARCHAR2,
  X_DEFAULT_VALUE in VARCHAR2,
  X_STYLE in VARCHAR2,
  X_DISPLAY_WIDTH in NUMBER,
  X_READ_ONLY_FLAG in VARCHAR2
) is
  cursor c1 is select
      OBJECT_VERSION_NUMBER,
      INTERFACE_APP_ID,
      INTERFACE_CODE,
      INTERFACE_SEQ_NUM,
      STYLE_CLASS,
      HINT_STYLE,
      HINT_STYLE_CLASS,
      PROMPT_STYLE,
      PROMPT_STYLE_CLASS,
      DEFAULT_TYPE,
      DEFAULT_VALUE,
      STYLE,
      DISPLAY_WIDTH,
	  READ_ONLY_FLAG
    from BNE_LAYOUT_COLS
    where APPLICATION_ID = X_APPLICATION_ID
    and LAYOUT_CODE = X_LAYOUT_CODE
    and BLOCK_ID = X_BLOCK_ID
    and SEQUENCE_NUM = X_SEQUENCE_NUM
    for update of APPLICATION_ID nowait;
begin
  for tlinfo in c1 loop
      if (    ((tlinfo.STYLE = X_STYLE)
               OR ((tlinfo.STYLE is null) AND (X_STYLE is null)))
          AND ((tlinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
               OR ((tlinfo.OBJECT_VERSION_NUMBER is null) AND (X_OBJECT_VERSION_NUMBER is null)))
          AND (tlinfo.INTERFACE_APP_ID = X_INTERFACE_APP_ID)
          AND (tlinfo.INTERFACE_CODE = X_INTERFACE_CODE)
          AND (tlinfo.INTERFACE_SEQ_NUM = X_INTERFACE_SEQ_NUM)
          AND ((tlinfo.STYLE_CLASS = X_STYLE_CLASS)
               OR ((tlinfo.STYLE_CLASS is null) AND (X_STYLE_CLASS is null)))
          AND ((tlinfo.HINT_STYLE = X_HINT_STYLE)
               OR ((tlinfo.HINT_STYLE is null) AND (X_HINT_STYLE is null)))
          AND ((tlinfo.HINT_STYLE_CLASS = X_HINT_STYLE_CLASS)
               OR ((tlinfo.HINT_STYLE_CLASS is null) AND (X_HINT_STYLE_CLASS is null)))
          AND ((tlinfo.PROMPT_STYLE = X_PROMPT_STYLE)
               OR ((tlinfo.PROMPT_STYLE is null) AND (X_PROMPT_STYLE is null)))
          AND ((tlinfo.PROMPT_STYLE_CLASS = X_PROMPT_STYLE_CLASS)
               OR ((tlinfo.PROMPT_STYLE_CLASS is null) AND (X_PROMPT_STYLE_CLASS is null)))
          AND ((tlinfo.DEFAULT_TYPE = X_DEFAULT_TYPE)
               OR ((tlinfo.DEFAULT_TYPE is null) AND (X_DEFAULT_TYPE is null)))
          AND ((tlinfo.DEFAULT_VALUE = X_DEFAULT_VALUE)
               OR ((tlinfo.DEFAULT_VALUE is null) AND (X_DEFAULT_VALUE is null)))
          AND ((tlinfo.DISPLAY_WIDTH = X_DISPLAY_WIDTH)
               OR ((tlinfo.DISPLAY_WIDTH is null) AND (X_DISPLAY_WIDTH is null)))
		  AND ((tlinfo.READ_ONLY_FLAG = X_READ_ONLY_FLAG)
               OR ((tlinfo.READ_ONLY_FLAG is null) AND (X_READ_ONLY_FLAG is null)))
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
  X_LAYOUT_CODE in VARCHAR2,
  X_BLOCK_ID in NUMBER,
  X_SEQUENCE_NUM in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_INTERFACE_APP_ID in NUMBER,
  X_INTERFACE_CODE in VARCHAR2,
  X_INTERFACE_SEQ_NUM in NUMBER,
  X_STYLE_CLASS in VARCHAR2,
  X_HINT_STYLE in VARCHAR2,
  X_HINT_STYLE_CLASS in VARCHAR2,
  X_PROMPT_STYLE in VARCHAR2,
  X_PROMPT_STYLE_CLASS in VARCHAR2,
  X_DEFAULT_TYPE in VARCHAR2,
  X_DEFAULT_VALUE in VARCHAR2,
  X_STYLE in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_DISPLAY_WIDTH in NUMBER,
  X_READ_ONLY_FLAG in VARCHAR2
) is
begin
  update BNE_LAYOUT_COLS set
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    INTERFACE_APP_ID = X_INTERFACE_APP_ID,
    INTERFACE_CODE = X_INTERFACE_CODE,
    INTERFACE_SEQ_NUM = X_INTERFACE_SEQ_NUM,
    STYLE_CLASS = X_STYLE_CLASS,
    HINT_STYLE = X_HINT_STYLE,
    HINT_STYLE_CLASS = X_HINT_STYLE_CLASS,
    PROMPT_STYLE = X_PROMPT_STYLE,
    PROMPT_STYLE_CLASS = X_PROMPT_STYLE_CLASS,
    DEFAULT_TYPE = X_DEFAULT_TYPE,
    DEFAULT_VALUE = X_DEFAULT_VALUE,
    STYLE = X_STYLE,
    DISPLAY_WIDTH = X_DISPLAY_WIDTH,
	READ_ONLY_FLAG = X_READ_ONLY_FLAG,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where APPLICATION_ID = X_APPLICATION_ID
  and LAYOUT_CODE = X_LAYOUT_CODE
  and BLOCK_ID = X_BLOCK_ID
  and SEQUENCE_NUM = X_SEQUENCE_NUM;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_LAYOUT_CODE in VARCHAR2,
  X_BLOCK_ID in NUMBER,
  X_SEQUENCE_NUM in NUMBER
) is
begin
  delete from BNE_LAYOUT_COLS
  where APPLICATION_ID = X_APPLICATION_ID
  and LAYOUT_CODE = X_LAYOUT_CODE
  and BLOCK_ID = X_BLOCK_ID
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
--  DESCRIPTION:   Load a row into the BNE_LAYOUT_COLS entity.                --
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
  x_layout_asn                  in VARCHAR2,
  x_layout_code                 in VARCHAR2,
  x_block_id                    in VARCHAR2,
  x_sequence_num                in VARCHAR2,
  x_object_version_number       in VARCHAR2,
  x_interface_asn               in VARCHAR2,
  x_interface_code              in VARCHAR2,
  x_interface_seq_num           in VARCHAR2,
  x_style_class                 in VARCHAR2,
  x_hint_style                  in VARCHAR2,
  x_hint_style_class            in VARCHAR2,
  x_prompt_style                in VARCHAR2,
  x_prompt_style_class          in VARCHAR2,
  x_default_type                in VARCHAR2,
  x_default_value               in VARCHAR2,
  x_style                       in VARCHAR2,
  x_owner                       in VARCHAR2,
  x_last_update_date            in VARCHAR2,
  x_custom_mode                 in VARCHAR2,
  x_display_width               in VARCHAR2,
  x_read_only_flag              in VARCHAR2
)
is
  l_app_id                      number;
  l_interface_app_id            number;
  l_row_id                      varchar2(64);
  f_luby                        number;  -- entity owner in file
  f_ludate                      date;    -- entity update date in file
  db_luby                       number;  -- entity owner in db
  db_ludate                     date;    -- entity update date in db
begin
  -- translate values to IDs
  l_app_id                        := BNE_LCT_TOOLS_PKG.ASN_TO_APP_ID(x_layout_asn);
  l_interface_app_id              := BNE_LCT_TOOLS_PKG.ASN_TO_APP_ID(x_interface_asn);

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);
  begin
    select LAST_UPDATED_BY, LAST_UPDATE_DATE
    into db_luby, db_ludate
    from BNE_LAYOUT_COLS
    where APPLICATION_ID = l_app_id
    and   LAYOUT_CODE    = x_layout_code
    and   BLOCK_ID       = x_block_id
    and   SEQUENCE_NUM   = x_sequence_num;

    -- Test for customization and version
    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, x_custom_mode)) then
      -- Update existing row
      BNE_LAYOUT_COLS_PKG.Update_Row(
        X_APPLICATION_ID               => l_app_id,
        X_LAYOUT_CODE                  => x_layout_code,
        X_BLOCK_ID                     => x_block_id,
        X_SEQUENCE_NUM                 => x_sequence_num,
        X_OBJECT_VERSION_NUMBER        => x_object_version_number,
        X_INTERFACE_APP_ID             => l_interface_app_id,
        X_INTERFACE_CODE               => x_interface_code,
        X_INTERFACE_SEQ_NUM            => x_interface_seq_num,
        X_STYLE_CLASS                  => x_style_class,
        X_HINT_STYLE                   => x_hint_style,
        X_HINT_STYLE_CLASS             => x_hint_style_class,
        X_PROMPT_STYLE                 => x_prompt_style,
        X_PROMPT_STYLE_CLASS           => x_prompt_style_class,
        X_DEFAULT_TYPE                 => x_default_type,
        X_DEFAULT_VALUE                => x_default_value,
        X_STYLE                        => x_style,
        X_DISPLAY_WIDTH                => x_display_width,
		X_READ_ONLY_FLAG               => x_read_only_flag,
        X_LAST_UPDATE_DATE             => f_ludate,
        X_LAST_UPDATED_BY              => f_luby,
        X_LAST_UPDATE_LOGIN            => 0
      );
    end if;
  exception
    when no_data_found then
      -- Record doesn't exist - insert in all cases
      BNE_LAYOUT_COLS_PKG.Insert_Row(
        X_ROWID                        => l_row_id,
        X_APPLICATION_ID               => l_app_id,
        X_LAYOUT_CODE                  => x_layout_code,
        X_BLOCK_ID                     => x_block_id,
        X_SEQUENCE_NUM                 => x_sequence_num,
        X_OBJECT_VERSION_NUMBER        => x_object_version_number,
        X_INTERFACE_APP_ID             => l_interface_app_id,
        X_INTERFACE_CODE               => x_interface_code,
        X_INTERFACE_SEQ_NUM            => x_interface_seq_num,
        X_STYLE_CLASS                  => x_style_class,
        X_HINT_STYLE                   => x_hint_style,
        X_HINT_STYLE_CLASS             => x_hint_style_class,
        X_PROMPT_STYLE                 => x_prompt_style,
        X_PROMPT_STYLE_CLASS           => x_prompt_style_class,
        X_DEFAULT_TYPE                 => x_default_type,
        X_DEFAULT_VALUE                => x_default_value,
        X_STYLE                        => x_style,
        X_DISPLAY_WIDTH                => x_display_width,
	X_READ_ONLY_FLAG	       => x_read_only_flag,
        X_CREATION_DATE                => f_ludate,
        X_CREATED_BY                   => f_luby,
        X_LAST_UPDATE_DATE             => f_ludate,
        X_LAST_UPDATED_BY              => f_luby,
        X_LAST_UPDATE_LOGIN            => 0
      );
  end;
end LOAD_ROW;

end BNE_LAYOUT_COLS_PKG;

/
