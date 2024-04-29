--------------------------------------------------------
--  DDL for Package Body BNE_LAYOUT_BLOCKS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BNE_LAYOUT_BLOCKS_PKG" as
/* $Header: bnelaybb.pls 120.4 2005/09/04 23:24:42 dvayro noship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_LAYOUT_CODE in VARCHAR2,
  X_BLOCK_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_PARENT_ID in NUMBER,
  X_LAYOUT_ELEMENT in VARCHAR2,
  X_STYLE_CLASS in VARCHAR2,
  X_STYLE in VARCHAR2,
  X_ROW_STYLE_CLASS in VARCHAR2,
  X_ROW_STYLE in VARCHAR2,
  X_COL_STYLE_CLASS in VARCHAR2,
  X_COL_STYLE in VARCHAR2,
  X_PROMPT_DISPLAYED_FLAG in VARCHAR2,
  X_PROMPT_STYLE_CLASS in VARCHAR2,
  X_PROMPT_STYLE in VARCHAR2,
  X_HINT_DISPLAYED_FLAG in VARCHAR2,
  X_HINT_STYLE_CLASS in VARCHAR2,
  X_HINT_STYLE in VARCHAR2,
  X_ORIENTATION in VARCHAR2,
  X_LAYOUT_CONTROL in VARCHAR2,
  X_DISPLAY_FLAG in VARCHAR2,
  X_BLOCKSIZE in NUMBER,
  X_MINSIZE in NUMBER,
  X_MAXSIZE in NUMBER,
  X_SEQUENCE_NUM in NUMBER,
  X_PROMPT_COLSPAN in NUMBER,
  X_HINT_COLSPAN in NUMBER,
  X_ROW_COLSPAN in NUMBER,
  X_SUMMARY_STYLE_CLASS in VARCHAR2,
  X_SUMMARY_STYLE in VARCHAR2,
  X_USER_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_PROMPT_ABOVE in VARCHAR2,
  X_TITLE_STYLE_CLASS in VARCHAR2,
  X_TITLE_STYLE in VARCHAR2
) is
  cursor C is select ROWID from BNE_LAYOUT_BLOCKS_B
    where APPLICATION_ID = X_APPLICATION_ID
    and LAYOUT_CODE = X_LAYOUT_CODE
    and BLOCK_ID = X_BLOCK_ID
    ;
begin
  insert into BNE_LAYOUT_BLOCKS_B (
    APPLICATION_ID,
    LAYOUT_CODE,
    BLOCK_ID,
    OBJECT_VERSION_NUMBER,
    PARENT_ID,
    LAYOUT_ELEMENT,
    STYLE_CLASS,
    STYLE,
    ROW_STYLE_CLASS,
    ROW_STYLE,
    COL_STYLE_CLASS,
    COL_STYLE,
    PROMPT_DISPLAYED_FLAG,
    PROMPT_STYLE_CLASS,
    PROMPT_STYLE,
    HINT_DISPLAYED_FLAG,
    HINT_STYLE_CLASS,
    HINT_STYLE,
    ORIENTATION,
    LAYOUT_CONTROL,
    DISPLAY_FLAG,
    BLOCKSIZE,
    MINSIZE,
    MAXSIZE,
    SEQUENCE_NUM,
    PROMPT_COLSPAN,
    HINT_COLSPAN,
    ROW_COLSPAN,
    SUMMARY_STYLE_CLASS,
    SUMMARY_STYLE,
	TITLE_STYLE_CLASS,
	TITLE_STYLE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_APPLICATION_ID,
    X_LAYOUT_CODE,
    X_BLOCK_ID,
    X_OBJECT_VERSION_NUMBER,
    X_PARENT_ID,
    X_LAYOUT_ELEMENT,
    X_STYLE_CLASS,
    X_STYLE,
    X_ROW_STYLE_CLASS,
    X_ROW_STYLE,
    X_COL_STYLE_CLASS,
    X_COL_STYLE,
    X_PROMPT_DISPLAYED_FLAG,
    X_PROMPT_STYLE_CLASS,
    X_PROMPT_STYLE,
    X_HINT_DISPLAYED_FLAG,
    X_HINT_STYLE_CLASS,
    X_HINT_STYLE,
    X_ORIENTATION,
    X_LAYOUT_CONTROL,
    X_DISPLAY_FLAG,
    X_BLOCKSIZE,
    X_MINSIZE,
    X_MAXSIZE,
    X_SEQUENCE_NUM,
    X_PROMPT_COLSPAN,
    X_HINT_COLSPAN,
    X_ROW_COLSPAN,
    X_SUMMARY_STYLE_CLASS,
    X_SUMMARY_STYLE,
	X_TITLE_STYLE_CLASS,
	X_TITLE_STYLE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into BNE_LAYOUT_BLOCKS_TL (
    APPLICATION_ID,
    LAYOUT_CODE,
    BLOCK_ID,
    USER_NAME,
	PROMPT_ABOVE,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LAST_UPDATE_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_APPLICATION_ID,
    X_LAYOUT_CODE,
    X_BLOCK_ID,
    X_USER_NAME,
	X_PROMPT_ABOVE,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_LAST_UPDATE_DATE,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from BNE_LAYOUT_BLOCKS_TL T
    where T.APPLICATION_ID = X_APPLICATION_ID
    and T.LAYOUT_CODE = X_LAYOUT_CODE
    and T.BLOCK_ID = X_BLOCK_ID
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
  X_APPLICATION_ID in NUMBER,
  X_LAYOUT_CODE in VARCHAR2,
  X_BLOCK_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_PARENT_ID in NUMBER,
  X_LAYOUT_ELEMENT in VARCHAR2,
  X_STYLE_CLASS in VARCHAR2,
  X_STYLE in VARCHAR2,
  X_ROW_STYLE_CLASS in VARCHAR2,
  X_ROW_STYLE in VARCHAR2,
  X_COL_STYLE_CLASS in VARCHAR2,
  X_COL_STYLE in VARCHAR2,
  X_PROMPT_DISPLAYED_FLAG in VARCHAR2,
  X_PROMPT_STYLE_CLASS in VARCHAR2,
  X_PROMPT_STYLE in VARCHAR2,
  X_HINT_DISPLAYED_FLAG in VARCHAR2,
  X_HINT_STYLE_CLASS in VARCHAR2,
  X_HINT_STYLE in VARCHAR2,
  X_ORIENTATION in VARCHAR2,
  X_LAYOUT_CONTROL in VARCHAR2,
  X_DISPLAY_FLAG in VARCHAR2,
  X_BLOCKSIZE in NUMBER,
  X_MINSIZE in NUMBER,
  X_MAXSIZE in NUMBER,
  X_SEQUENCE_NUM in NUMBER,
  X_PROMPT_COLSPAN in NUMBER,
  X_HINT_COLSPAN in NUMBER,
  X_ROW_COLSPAN in NUMBER,
  X_SUMMARY_STYLE_CLASS in VARCHAR2,
  X_SUMMARY_STYLE in VARCHAR2,
  X_USER_NAME in VARCHAR2,
  X_PROMPT_ABOVE in VARCHAR2,
  X_TITLE_STYLE_CLASS in VARCHAR2,
  X_TITLE_STYLE in VARCHAR2
) is
  cursor c is select
      OBJECT_VERSION_NUMBER,
      PARENT_ID,
      LAYOUT_ELEMENT,
      STYLE_CLASS,
      STYLE,
      ROW_STYLE_CLASS,
      ROW_STYLE,
      COL_STYLE_CLASS,
      COL_STYLE,
      PROMPT_DISPLAYED_FLAG,
      PROMPT_STYLE_CLASS,
      PROMPT_STYLE,
      HINT_DISPLAYED_FLAG,
      HINT_STYLE_CLASS,
      HINT_STYLE,
      ORIENTATION,
      LAYOUT_CONTROL,
      DISPLAY_FLAG,
      BLOCKSIZE,
      MINSIZE,
      MAXSIZE,
      SEQUENCE_NUM,
      PROMPT_COLSPAN,
      HINT_COLSPAN,
      ROW_COLSPAN,
      SUMMARY_STYLE_CLASS,
      SUMMARY_STYLE,
	  TITLE_STYLE_CLASS,
	  TITLE_STYLE
    from BNE_LAYOUT_BLOCKS_B
    where APPLICATION_ID = X_APPLICATION_ID
    and LAYOUT_CODE = X_LAYOUT_CODE
    and BLOCK_ID = X_BLOCK_ID
    for update of APPLICATION_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      USER_NAME,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from BNE_LAYOUT_BLOCKS_TL
    where APPLICATION_ID = X_APPLICATION_ID
    and LAYOUT_CODE = X_LAYOUT_CODE
    and BLOCK_ID = X_BLOCK_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of APPLICATION_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
      AND ((recinfo.PARENT_ID = X_PARENT_ID)
           OR ((recinfo.PARENT_ID is null) AND (X_PARENT_ID is null)))
      AND (recinfo.LAYOUT_ELEMENT = X_LAYOUT_ELEMENT)
      AND ((recinfo.STYLE_CLASS = X_STYLE_CLASS)
           OR ((recinfo.STYLE_CLASS is null) AND (X_STYLE_CLASS is null)))
      AND ((recinfo.STYLE = X_STYLE)
           OR ((recinfo.STYLE is null) AND (X_STYLE is null)))
      AND ((recinfo.ROW_STYLE_CLASS = X_ROW_STYLE_CLASS)
           OR ((recinfo.ROW_STYLE_CLASS is null) AND (X_ROW_STYLE_CLASS is null)))
      AND ((recinfo.ROW_STYLE = X_ROW_STYLE)
           OR ((recinfo.ROW_STYLE is null) AND (X_ROW_STYLE is null)))
      AND ((recinfo.COL_STYLE_CLASS = X_COL_STYLE_CLASS)
           OR ((recinfo.COL_STYLE_CLASS is null) AND (X_COL_STYLE_CLASS is null)))
      AND ((recinfo.COL_STYLE = X_COL_STYLE)
           OR ((recinfo.COL_STYLE is null) AND (X_COL_STYLE is null)))
      AND (recinfo.PROMPT_DISPLAYED_FLAG = X_PROMPT_DISPLAYED_FLAG)
      AND ((recinfo.PROMPT_STYLE_CLASS = X_PROMPT_STYLE_CLASS)
           OR ((recinfo.PROMPT_STYLE_CLASS is null) AND (X_PROMPT_STYLE_CLASS is null)))
      AND ((recinfo.PROMPT_STYLE = X_PROMPT_STYLE)
           OR ((recinfo.PROMPT_STYLE is null) AND (X_PROMPT_STYLE is null)))
      AND (recinfo.HINT_DISPLAYED_FLAG = X_HINT_DISPLAYED_FLAG)
      AND ((recinfo.HINT_STYLE_CLASS = X_HINT_STYLE_CLASS)
           OR ((recinfo.HINT_STYLE_CLASS is null) AND (X_HINT_STYLE_CLASS is null)))
      AND ((recinfo.HINT_STYLE = X_HINT_STYLE)
           OR ((recinfo.HINT_STYLE is null) AND (X_HINT_STYLE is null)))
      AND (recinfo.ORIENTATION = X_ORIENTATION)
      AND (recinfo.LAYOUT_CONTROL = X_LAYOUT_CONTROL)
      AND (recinfo.DISPLAY_FLAG = X_DISPLAY_FLAG)
      AND (recinfo.BLOCKSIZE = X_BLOCKSIZE)
      AND (recinfo.MINSIZE = X_MINSIZE)
      AND (recinfo.MAXSIZE = X_MAXSIZE)
      AND (recinfo.SEQUENCE_NUM = X_SEQUENCE_NUM)
      AND ((recinfo.PROMPT_COLSPAN = X_PROMPT_COLSPAN)
           OR ((recinfo.PROMPT_COLSPAN is null) AND (X_PROMPT_COLSPAN is null)))
      AND ((recinfo.HINT_COLSPAN = X_HINT_COLSPAN)
           OR ((recinfo.HINT_COLSPAN is null) AND (X_HINT_COLSPAN is null)))
      AND ((recinfo.ROW_COLSPAN = X_ROW_COLSPAN)
           OR ((recinfo.ROW_COLSPAN is null) AND (X_ROW_COLSPAN is null)))
      AND ((recinfo.SUMMARY_STYLE_CLASS = X_SUMMARY_STYLE_CLASS)
           OR ((recinfo.SUMMARY_STYLE_CLASS is null) AND (X_SUMMARY_STYLE_CLASS is null)))
      AND ((recinfo.SUMMARY_STYLE = X_SUMMARY_STYLE)
           OR ((recinfo.SUMMARY_STYLE is null) AND (X_SUMMARY_STYLE is null)))
	  AND ((recinfo.TITLE_STYLE_CLASS = X_TITLE_STYLE_CLASS)
           OR ((recinfo.TITLE_STYLE_CLASS is null) AND (X_TITLE_STYLE_CLASS is null)))
      AND ((recinfo.TITLE_STYLE = X_TITLE_STYLE)
           OR ((recinfo.TITLE_STYLE is null) AND (X_TITLE_STYLE is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.USER_NAME = X_USER_NAME)
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
  X_APPLICATION_ID in NUMBER,
  X_LAYOUT_CODE in VARCHAR2,
  X_BLOCK_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_PARENT_ID in NUMBER,
  X_LAYOUT_ELEMENT in VARCHAR2,
  X_STYLE_CLASS in VARCHAR2,
  X_STYLE in VARCHAR2,
  X_ROW_STYLE_CLASS in VARCHAR2,
  X_ROW_STYLE in VARCHAR2,
  X_COL_STYLE_CLASS in VARCHAR2,
  X_COL_STYLE in VARCHAR2,
  X_PROMPT_DISPLAYED_FLAG in VARCHAR2,
  X_PROMPT_STYLE_CLASS in VARCHAR2,
  X_PROMPT_STYLE in VARCHAR2,
  X_HINT_DISPLAYED_FLAG in VARCHAR2,
  X_HINT_STYLE_CLASS in VARCHAR2,
  X_HINT_STYLE in VARCHAR2,
  X_ORIENTATION in VARCHAR2,
  X_LAYOUT_CONTROL in VARCHAR2,
  X_DISPLAY_FLAG in VARCHAR2,
  X_BLOCKSIZE in NUMBER,
  X_MINSIZE in NUMBER,
  X_MAXSIZE in NUMBER,
  X_SEQUENCE_NUM in NUMBER,
  X_PROMPT_COLSPAN in NUMBER,
  X_HINT_COLSPAN in NUMBER,
  X_ROW_COLSPAN in NUMBER,
  X_SUMMARY_STYLE_CLASS in VARCHAR2,
  X_SUMMARY_STYLE in VARCHAR2,
  X_USER_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_PROMPT_ABOVE in VARCHAR2,
  X_TITLE_STYLE_CLASS in VARCHAR2,
  X_TITLE_STYLE in VARCHAR2
) is
begin
  update BNE_LAYOUT_BLOCKS_B set
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    PARENT_ID = X_PARENT_ID,
    LAYOUT_ELEMENT = X_LAYOUT_ELEMENT,
    STYLE_CLASS = X_STYLE_CLASS,
    STYLE = X_STYLE,
    ROW_STYLE_CLASS = X_ROW_STYLE_CLASS,
    ROW_STYLE = X_ROW_STYLE,
    COL_STYLE_CLASS = X_COL_STYLE_CLASS,
    COL_STYLE = X_COL_STYLE,
    PROMPT_DISPLAYED_FLAG = X_PROMPT_DISPLAYED_FLAG,
    PROMPT_STYLE_CLASS = X_PROMPT_STYLE_CLASS,
    PROMPT_STYLE = X_PROMPT_STYLE,
    HINT_DISPLAYED_FLAG = X_HINT_DISPLAYED_FLAG,
    HINT_STYLE_CLASS = X_HINT_STYLE_CLASS,
    HINT_STYLE = X_HINT_STYLE,
    ORIENTATION = X_ORIENTATION,
    LAYOUT_CONTROL = X_LAYOUT_CONTROL,
    DISPLAY_FLAG = X_DISPLAY_FLAG,
    BLOCKSIZE = X_BLOCKSIZE,
    MINSIZE = X_MINSIZE,
    MAXSIZE = X_MAXSIZE,
    SEQUENCE_NUM = X_SEQUENCE_NUM,
    PROMPT_COLSPAN = X_PROMPT_COLSPAN,
    HINT_COLSPAN = X_HINT_COLSPAN,
    ROW_COLSPAN = X_ROW_COLSPAN,
    SUMMARY_STYLE_CLASS = X_SUMMARY_STYLE_CLASS,
    SUMMARY_STYLE = X_SUMMARY_STYLE,
	TITLE_STYLE_CLASS = X_TITLE_STYLE_CLASS,
	TITLE_STYLE = X_TITLE_STYLE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where APPLICATION_ID = X_APPLICATION_ID
  and LAYOUT_CODE = X_LAYOUT_CODE
  and BLOCK_ID = X_BLOCK_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update BNE_LAYOUT_BLOCKS_TL set
    USER_NAME = X_USER_NAME,
	PROMPT_ABOVE = X_PROMPT_ABOVE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where APPLICATION_ID = X_APPLICATION_ID
  and LAYOUT_CODE = X_LAYOUT_CODE
  and BLOCK_ID = X_BLOCK_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_LAYOUT_CODE in VARCHAR2,
  X_BLOCK_ID in NUMBER
) is
begin
  delete from BNE_LAYOUT_BLOCKS_TL
  where APPLICATION_ID = X_APPLICATION_ID
  and LAYOUT_CODE = X_LAYOUT_CODE
  and BLOCK_ID = X_BLOCK_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from BNE_LAYOUT_BLOCKS_B
  where APPLICATION_ID = X_APPLICATION_ID
  and LAYOUT_CODE = X_LAYOUT_CODE
  and BLOCK_ID = X_BLOCK_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from BNE_LAYOUT_BLOCKS_TL T
  where not exists
    (select NULL
    from BNE_LAYOUT_BLOCKS_B B
    where B.APPLICATION_ID = T.APPLICATION_ID
    and B.LAYOUT_CODE = T.LAYOUT_CODE
    and B.BLOCK_ID = T.BLOCK_ID
    );

  update BNE_LAYOUT_BLOCKS_TL T set (
      USER_NAME
    ) = (select
      B.USER_NAME
    from BNE_LAYOUT_BLOCKS_TL B
    where B.APPLICATION_ID = T.APPLICATION_ID
    and B.LAYOUT_CODE = T.LAYOUT_CODE
    and B.BLOCK_ID = T.BLOCK_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.APPLICATION_ID,
      T.LAYOUT_CODE,
      T.BLOCK_ID,
      T.LANGUAGE
  ) in (select
      SUBT.APPLICATION_ID,
      SUBT.LAYOUT_CODE,
      SUBT.BLOCK_ID,
      SUBT.LANGUAGE
    from BNE_LAYOUT_BLOCKS_TL SUBB, BNE_LAYOUT_BLOCKS_TL SUBT
    where SUBB.APPLICATION_ID = SUBT.APPLICATION_ID
    and SUBB.LAYOUT_CODE = SUBT.LAYOUT_CODE
    and SUBB.BLOCK_ID = SUBT.BLOCK_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.USER_NAME <> SUBT.USER_NAME
  ));

  insert into BNE_LAYOUT_BLOCKS_TL (
    APPLICATION_ID,
    LAYOUT_CODE,
    BLOCK_ID,
    USER_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LAST_UPDATE_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.APPLICATION_ID,
    B.LAYOUT_CODE,
    B.BLOCK_ID,
    B.USER_NAME,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.LAST_UPDATE_DATE,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from BNE_LAYOUT_BLOCKS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from BNE_LAYOUT_BLOCKS_TL T
    where T.APPLICATION_ID = B.APPLICATION_ID
    and T.LAYOUT_CODE = B.LAYOUT_CODE
    and T.BLOCK_ID = B.BLOCK_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

--------------------------------------------------------------------------------
--  PROCEDURE:   TRANSLATE_ROW                                                --
--                                                                            --
--  DESCRIPTION: Load a translation into the BNE_LAYOUT_BLOCKS entity.        --
--               This proc is called from the apps loader.                    --
--                                                                            --
--  SEE:   http://www-apps.us.oracle.com/atg/plans/r115/fndloadqr.txt         --
--                                                                            --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date       Username  Description                                          --
--  1-Oct-02   DGROVES   CREATED                                              --
--------------------------------------------------------------------------------
procedure TRANSLATE_ROW(
  x_layout_asn            in VARCHAR2,
  x_layout_code           in VARCHAR2,
  x_block_id              in VARCHAR2,
  x_user_name             in VARCHAR2,
  x_owner                 in VARCHAR2,
  x_last_update_date      in VARCHAR2,
  x_custom_mode           in VARCHAR2,
  x_prompt_above          in VARCHAR2
)
is
  l_app_id          number;
  f_luby            number;  -- entity owner in file
  f_ludate          date;    -- entity update date in file
  db_luby           number;  -- entity owner in db
  db_ludate         date;    -- entity update date in db
begin
  -- translate values to IDs
  l_app_id        := BNE_LCT_TOOLS_PKG.ASN_TO_APP_ID(x_layout_asn);

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);
  begin
    select LAST_UPDATED_BY, LAST_UPDATE_DATE
    into db_luby, db_ludate
    from BNE_LAYOUT_BLOCKS_TL
    where APPLICATION_ID  = l_app_id
    and   LAYOUT_CODE     = x_layout_code
    and   BLOCK_ID        = x_block_id
    and   LANGUAGE        = userenv('LANG');

    -- Test for customization and version
    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, x_custom_mode)) then

      update BNE_LAYOUT_BLOCKS_TL
      set USER_NAME         = x_user_name,
	      PROMPT_ABOVE      = x_prompt_above,
          LAST_UPDATE_DATE  = f_ludate,
          LAST_UPDATED_BY   = f_luby,
          LAST_UPDATE_LOGIN = 0,
          SOURCE_LANG       = userenv('LANG')
      where APPLICATION_ID   = l_app_id
      AND   LAYOUT_CODE      = x_layout_code
      AND   BLOCK_ID         = x_block_id
      AND   userenv('LANG') in (LANGUAGE, SOURCE_LANG)
      ;
    end if;
  exception
    when no_data_found then
      -- Do not insert missing translations, skip this row
      null;
  end;
end TRANSLATE_ROW;


--------------------------------------------------------------------------------
--  PROCEDURE:     LOAD_ROW                                                   --
--                                                                            --
--  DESCRIPTION:   Load a row into the BNE_LAYOUT_BLOCKS entity.              --
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
  x_object_version_number       in VARCHAR2,
  x_parent_id                   in VARCHAR2,
  x_layout_element              in VARCHAR2,
  x_style_class                 in VARCHAR2,
  x_style                       in VARCHAR2,
  x_row_style_class             in VARCHAR2,
  x_row_style                   in VARCHAR2,
  x_col_style_class             in VARCHAR2,
  x_col_style                   in VARCHAR2,
  x_prompt_displayed_flag       in VARCHAR2,
  x_prompt_style_class          in VARCHAR2,
  x_prompt_style                in VARCHAR2,
  x_hint_displayed_flag         in VARCHAR2,
  x_hint_style_class            in VARCHAR2,
  x_hint_style                  in VARCHAR2,
  x_orientation                 in VARCHAR2,
  x_layout_control              in VARCHAR2,
  x_display_flag                in VARCHAR2,
  x_blocksize                   in VARCHAR2,
  x_minsize                     in VARCHAR2,
  x_maxsize                     in VARCHAR2,
  x_sequence_num                in VARCHAR2,
  x_prompt_colspan              in VARCHAR2,
  x_hint_colspan                in VARCHAR2,
  x_row_colspan                 in VARCHAR2,
  x_summary_style_class         in VARCHAR2,
  x_summary_style               in VARCHAR2,
  x_user_name                   in VARCHAR2,
  x_owner                       in VARCHAR2,
  x_last_update_date            in VARCHAR2,
  x_custom_mode                 in VARCHAR2,
  x_prompt_above                in VARCHAR2,
  x_title_style_class           in VARCHAR2,
  x_title_style                 in VARCHAR2
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
  l_app_id                        := BNE_LCT_TOOLS_PKG.ASN_TO_APP_ID(x_layout_asn);

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);
  begin
    select LAST_UPDATED_BY, LAST_UPDATE_DATE
    into db_luby, db_ludate
    from BNE_LAYOUT_BLOCKS_B
    where APPLICATION_ID = l_app_id
    and   LAYOUT_CODE    = x_layout_code
    and   BLOCK_ID       = x_block_id;

    -- Test for customization and version
    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, x_custom_mode)) then
      -- Update existing row
      BNE_LAYOUT_BLOCKS_PKG.Update_Row(
        X_APPLICATION_ID               => l_app_id,
        X_LAYOUT_CODE                  => x_layout_code,
        X_BLOCK_ID                     => x_block_id,
        X_OBJECT_VERSION_NUMBER        => x_object_version_number,
        X_PARENT_ID                    => x_parent_id,
        X_LAYOUT_ELEMENT               => x_layout_element,
        X_STYLE_CLASS                  => x_style_class,
        X_STYLE                        => x_style,
        X_ROW_STYLE_CLASS              => x_row_style_class,
        X_ROW_STYLE                    => x_row_style,
        X_COL_STYLE_CLASS              => x_col_style_class,
        X_COL_STYLE                    => x_col_style,
        X_PROMPT_DISPLAYED_FLAG        => x_prompt_displayed_flag,
        X_PROMPT_STYLE_CLASS           => x_prompt_style_class,
        X_PROMPT_STYLE                 => x_prompt_style,
        X_HINT_DISPLAYED_FLAG          => x_hint_displayed_flag,
        X_HINT_STYLE_CLASS             => x_hint_style_class,
        X_HINT_STYLE                   => x_hint_style,
        X_ORIENTATION                  => x_orientation,
        X_LAYOUT_CONTROL               => x_layout_control,
        X_DISPLAY_FLAG                 => x_display_flag,
        X_BLOCKSIZE                    => x_blocksize,
        X_MINSIZE                      => x_minsize,
        X_MAXSIZE                      => x_maxsize,
        X_SEQUENCE_NUM                 => x_sequence_num,
        X_PROMPT_COLSPAN               => x_prompt_colspan,
        X_HINT_COLSPAN                 => x_hint_colspan,
        X_ROW_COLSPAN                  => x_row_colspan,
        X_SUMMARY_STYLE_CLASS          => x_summary_style_class,
        X_SUMMARY_STYLE                => x_summary_style,
		X_USER_NAME                    => x_user_name,
		X_LAST_UPDATE_DATE             => f_ludate,
        X_LAST_UPDATED_BY              => f_luby,
        X_LAST_UPDATE_LOGIN            => 0,
		X_PROMPT_ABOVE                 => x_prompt_above,
        X_TITLE_STYLE_CLASS            => x_title_style_class,
		X_TITLE_STYLE                  => x_title_style
      );
    end if;
  exception
    when no_data_found then
      -- Record doesn't exist - insert in all cases
      BNE_LAYOUT_BLOCKS_PKG.Insert_Row(
        X_ROWID                        => l_row_id,
        X_APPLICATION_ID               => l_app_id,
        X_LAYOUT_CODE                  => x_layout_code,
        X_BLOCK_ID                     => x_block_id,
        X_OBJECT_VERSION_NUMBER        => x_object_version_number,
        X_PARENT_ID                    => x_parent_id,
        X_LAYOUT_ELEMENT               => x_layout_element,
        X_STYLE_CLASS                  => x_style_class,
        X_STYLE                        => x_style,
        X_ROW_STYLE_CLASS              => x_row_style_class,
        X_ROW_STYLE                    => x_row_style,
        X_COL_STYLE_CLASS              => x_col_style_class,
        X_COL_STYLE                    => x_col_style,
        X_PROMPT_DISPLAYED_FLAG        => x_prompt_displayed_flag,
        X_PROMPT_STYLE_CLASS           => x_prompt_style_class,
        X_PROMPT_STYLE                 => x_prompt_style,
        X_HINT_DISPLAYED_FLAG          => x_hint_displayed_flag,
        X_HINT_STYLE_CLASS             => x_hint_style_class,
        X_HINT_STYLE                   => x_hint_style,
        X_ORIENTATION                  => x_orientation,
        X_LAYOUT_CONTROL               => x_layout_control,
        X_DISPLAY_FLAG                 => x_display_flag,
        X_BLOCKSIZE                    => x_blocksize,
        X_MINSIZE                      => x_minsize,
        X_MAXSIZE                      => x_maxsize,
        X_SEQUENCE_NUM                 => x_sequence_num,
        X_PROMPT_COLSPAN               => x_prompt_colspan,
        X_HINT_COLSPAN                 => x_hint_colspan,
        X_ROW_COLSPAN                  => x_row_colspan,
        X_SUMMARY_STYLE_CLASS          => x_summary_style_class,
        X_SUMMARY_STYLE                => x_summary_style,
		X_USER_NAME                    => x_user_name,
		X_CREATION_DATE                => f_ludate,
        X_CREATED_BY                   => f_luby,
        X_LAST_UPDATE_DATE             => f_ludate,
        X_LAST_UPDATED_BY              => f_luby,
        X_LAST_UPDATE_LOGIN            => 0,
		X_PROMPT_ABOVE                 => x_prompt_above,
        X_TITLE_STYLE_CLASS            => x_title_style_class,
		X_TITLE_STYLE                  => x_title_style
      );
  end;
end LOAD_ROW;


end BNE_LAYOUT_BLOCKS_PKG;

/
