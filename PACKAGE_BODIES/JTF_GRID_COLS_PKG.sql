--------------------------------------------------------
--  DDL for Package Body JTF_GRID_COLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_GRID_COLS_PKG" AS
/* $Header: JTFGCPKB.pls 120.4 2006/09/20 07:58:17 snellepa ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_GRID_DATASOURCE_NAME in VARCHAR2,
  X_GRID_COL_ALIAS in VARCHAR2,
  X_DB_COL_NAME in VARCHAR2,
  X_DATA_TYPE_CODE in VARCHAR2,
  X_QUERY_SEQ in NUMBER,
  X_SORTABLE_FLAG in VARCHAR2,
  X_SORT_ASC_BY_DEFAULT_FLAG in VARCHAR2,
  X_VISIBLE_FLAG in VARCHAR2,
  X_FREEZE_VISIBLE_FLAG in VARCHAR2,
  X_DISPLAY_SEQ in NUMBER,
  X_DISPLAY_TYPE_CODE in VARCHAR2,
  X_DISPLAY_HSIZE in NUMBER,
  X_HEADER_ALIGNMENT_CODE in VARCHAR2,
  X_CELL_ALIGNMENT_CODE in VARCHAR2,
  X_DISPLAY_FORMAT_TYPE_CODE in VARCHAR2,
  X_DISPLAY_FORMAT_MASK in VARCHAR2,
  X_CHECKBOX_CHECKED_VALUE in VARCHAR2,
  X_CHECKBOX_UNCHECKED_VALUE in VARCHAR2,
  X_CHECKBOX_OTHER_VALUES in VARCHAR2,
  X_DB_CURRENCY_CODE_COL in VARCHAR2,
  X_LABEL_TEXT in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_QUERY_ALLOWED_FLAG in VARCHAR2,
  X_VALIDATION_OBJECT_CODE in VARCHAR2,
  X_QUERY_DISPLAY_SEQ in NUMBER,
  X_DB_SORT_COLUMN in VARCHAR2,
  X_FIRE_POST_QUERY_FLAG in VARCHAR2,
  X_IMAGE_DESCRIPTION_COL in VARCHAR2
) is
  cursor C is select ROWID from JTF_GRID_COLS_B
    where GRID_DATASOURCE_NAME = X_GRID_DATASOURCE_NAME
    and GRID_COL_ALIAS = X_GRID_COL_ALIAS
    ;
begin
 -- defaulting the query allowed flag since it is eventually going to be a not null column

  insert into JTF_GRID_COLS_B (
    GRID_DATASOURCE_NAME,
    GRID_COL_ALIAS,
    DB_COL_NAME,
    DATA_TYPE_CODE,
    QUERY_SEQ,
    SORTABLE_FLAG,
    SORT_ASC_BY_DEFAULT_FLAG,
    VISIBLE_FLAG,
    FREEZE_VISIBLE_FLAG,
    DISPLAY_SEQ,
    DISPLAY_TYPE_CODE,
    DISPLAY_HSIZE,
    HEADER_ALIGNMENT_CODE,
    CELL_ALIGNMENT_CODE,
    DISPLAY_FORMAT_TYPE_CODE,
    DISPLAY_FORMAT_MASK,
    CHECKBOX_CHECKED_VALUE,
    CHECKBOX_UNCHECKED_VALUE,
    CHECKBOX_OTHER_VALUES,
    DB_CURRENCY_CODE_COL,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    QUERY_ALLOWED_FLAG,
    VALIDATION_OBJECT_CODE,
    QUERY_DISPLAY_SEQ,
    DB_SORT_COLUMN,
    FIRE_POST_QUERY_FLAG,
    IMAGE_DESCRIPTION_COL
  ) values (
    X_GRID_DATASOURCE_NAME,
    X_GRID_COL_ALIAS,
    X_DB_COL_NAME,
    X_DATA_TYPE_CODE,
    X_QUERY_SEQ,
    X_SORTABLE_FLAG,
    X_SORT_ASC_BY_DEFAULT_FLAG,
    X_VISIBLE_FLAG,
    X_FREEZE_VISIBLE_FLAG,
    X_DISPLAY_SEQ,
    X_DISPLAY_TYPE_CODE,
    X_DISPLAY_HSIZE,
    X_HEADER_ALIGNMENT_CODE,
    X_CELL_ALIGNMENT_CODE,
    X_DISPLAY_FORMAT_TYPE_CODE,
    X_DISPLAY_FORMAT_MASK,
    X_CHECKBOX_CHECKED_VALUE,
    X_CHECKBOX_UNCHECKED_VALUE,
    X_CHECKBOX_OTHER_VALUES,
    X_DB_CURRENCY_CODE_COL,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    decode(X_QUERY_ALLOWED_FLAG,NULL,'F',X_QUERY_ALLOWED_FLAG),
    X_VALIDATION_OBJECT_CODE,
    X_QUERY_DISPLAY_SEQ,
    X_DB_SORT_COLUMN,
    X_FIRE_POST_QUERY_FLAG,
    X_IMAGE_DESCRIPTION_COL
  );

  insert into JTF_GRID_COLS_TL (
    GRID_DATASOURCE_NAME,
    GRID_COL_ALIAS,
    LABEL_TEXT,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_GRID_DATASOURCE_NAME,
    X_GRID_COL_ALIAS,
    X_LABEL_TEXT,
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
    from JTF_GRID_COLS_TL T
    where T.GRID_DATASOURCE_NAME = X_GRID_DATASOURCE_NAME
    and T.GRID_COL_ALIAS = X_GRID_COL_ALIAS
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

  -- update the last updated by if it is 'SEED'
  update_header(x_grid_datasource_name, x_last_updated_by, x_last_update_date);

end INSERT_ROW;

procedure LOCK_ROW (
  X_GRID_DATASOURCE_NAME in VARCHAR2,
  X_GRID_COL_ALIAS in VARCHAR2,
  X_DB_COL_NAME in VARCHAR2,
  X_DATA_TYPE_CODE in VARCHAR2,
  X_QUERY_SEQ in NUMBER,
  X_SORTABLE_FLAG in VARCHAR2,
  X_SORT_ASC_BY_DEFAULT_FLAG in VARCHAR2,
  X_VISIBLE_FLAG in VARCHAR2,
  X_FREEZE_VISIBLE_FLAG in VARCHAR2,
  X_DISPLAY_SEQ in NUMBER,
  X_DISPLAY_TYPE_CODE in VARCHAR2,
  X_DISPLAY_HSIZE in NUMBER,
  X_HEADER_ALIGNMENT_CODE in VARCHAR2,
  X_CELL_ALIGNMENT_CODE in VARCHAR2,
  X_DISPLAY_FORMAT_TYPE_CODE in VARCHAR2,
  X_DISPLAY_FORMAT_MASK in VARCHAR2,
  X_CHECKBOX_CHECKED_VALUE in VARCHAR2,
  X_CHECKBOX_UNCHECKED_VALUE in VARCHAR2,
  X_CHECKBOX_OTHER_VALUES in VARCHAR2,
  X_DB_CURRENCY_CODE_COL in VARCHAR2,
  X_LABEL_TEXT in VARCHAR2,
  X_QUERY_ALLOWED_FLAG in VARCHAR2,
  X_VALIDATION_OBJECT_CODE in VARCHAR2,
  X_QUERY_DISPLAY_SEQ in NUMBER,
  X_DB_SORT_COLUMN in VARCHAR2,
  X_FIRE_POST_QUERY_FLAG in VARCHAR2,
  X_IMAGE_DESCRIPTION_COL in VARCHAR2
) is
  cursor c is select
      DB_COL_NAME,
      DATA_TYPE_CODE,
      QUERY_SEQ,
      SORTABLE_FLAG,
      SORT_ASC_BY_DEFAULT_FLAG,
      VISIBLE_FLAG,
      FREEZE_VISIBLE_FLAG,
      DISPLAY_SEQ,
      DISPLAY_TYPE_CODE,
      DISPLAY_HSIZE,
      HEADER_ALIGNMENT_CODE,
      CELL_ALIGNMENT_CODE,
      DISPLAY_FORMAT_TYPE_CODE,
      DISPLAY_FORMAT_MASK,
      CHECKBOX_CHECKED_VALUE,
      CHECKBOX_UNCHECKED_VALUE,
      CHECKBOX_OTHER_VALUES,
      DB_CURRENCY_CODE_COL,
      QUERY_ALLOWED_FLAG,
      VALIDATION_OBJECT_CODE,
      QUERY_DISPLAY_SEQ,
      DB_SORT_COLUMN,
      FIRE_POST_QUERY_FLAG,
      IMAGE_DESCRIPTION_COL
    from JTF_GRID_COLS_B
    where GRID_DATASOURCE_NAME = X_GRID_DATASOURCE_NAME
    and GRID_COL_ALIAS = X_GRID_COL_ALIAS
    for update of GRID_DATASOURCE_NAME nowait;
  recinfo c%rowtype;

  cursor c1 is select
      LABEL_TEXT,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from JTF_GRID_COLS_TL
    where GRID_DATASOURCE_NAME = X_GRID_DATASOURCE_NAME
    and GRID_COL_ALIAS = X_GRID_COL_ALIAS
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
  if (    (recinfo.DB_COL_NAME = X_DB_COL_NAME)
      AND (recinfo.DATA_TYPE_CODE = X_DATA_TYPE_CODE)
      AND (recinfo.QUERY_SEQ = X_QUERY_SEQ)
      AND (recinfo.SORTABLE_FLAG = X_SORTABLE_FLAG)
      AND (recinfo.SORT_ASC_BY_DEFAULT_FLAG = X_SORT_ASC_BY_DEFAULT_FLAG)
      AND (recinfo.VISIBLE_FLAG = X_VISIBLE_FLAG)
      AND (recinfo.FREEZE_VISIBLE_FLAG = X_FREEZE_VISIBLE_FLAG)
      AND (recinfo.DISPLAY_SEQ = X_DISPLAY_SEQ)
      AND (recinfo.DISPLAY_TYPE_CODE = X_DISPLAY_TYPE_CODE)
      AND (recinfo.DISPLAY_HSIZE = X_DISPLAY_HSIZE)
      AND (recinfo.HEADER_ALIGNMENT_CODE = X_HEADER_ALIGNMENT_CODE)
      AND (recinfo.CELL_ALIGNMENT_CODE = X_CELL_ALIGNMENT_CODE)
      AND ((recinfo.DISPLAY_FORMAT_TYPE_CODE = X_DISPLAY_FORMAT_TYPE_CODE)
           OR ((recinfo.DISPLAY_FORMAT_TYPE_CODE is null) AND (X_DISPLAY_FORMAT_TYPE_CODE is null)))
      AND ((recinfo.DISPLAY_FORMAT_MASK = X_DISPLAY_FORMAT_MASK)
           OR ((recinfo.DISPLAY_FORMAT_MASK is null) AND (X_DISPLAY_FORMAT_MASK is null)))
      AND ((recinfo.CHECKBOX_CHECKED_VALUE = X_CHECKBOX_CHECKED_VALUE)
           OR ((recinfo.CHECKBOX_CHECKED_VALUE is null) AND (X_CHECKBOX_CHECKED_VALUE is null)))
      AND ((recinfo.CHECKBOX_UNCHECKED_VALUE = X_CHECKBOX_UNCHECKED_VALUE)
           OR ((recinfo.CHECKBOX_UNCHECKED_VALUE is null) AND (X_CHECKBOX_UNCHECKED_VALUE is null)))
      AND ((recinfo.CHECKBOX_OTHER_VALUES = X_CHECKBOX_OTHER_VALUES)
           OR ((recinfo.CHECKBOX_OTHER_VALUES is null) AND (X_CHECKBOX_OTHER_VALUES is null)))
      AND ((recinfo.DB_CURRENCY_CODE_COL = X_DB_CURRENCY_CODE_COL)
           OR ((recinfo.DB_CURRENCY_CODE_COL is null) AND (X_DB_CURRENCY_CODE_COL is null)))
       AND (recinfo.QUERY_ALLOWED_FLAG = X_QUERY_ALLOWED_FLAG)
       AND ((recinfo.VALIDATION_OBJECT_CODE = X_VALIDATION_OBJECT_CODE)
           OR ((recinfo.VALIDATION_OBJECT_CODE is null) AND (X_VALIDATION_OBJECT_CODE is null)))
       AND ((recinfo.QUERY_DISPLAY_SEQ = X_QUERY_DISPLAY_SEQ)
           OR ((recinfo.QUERY_DISPLAY_SEQ is null) AND (X_QUERY_DISPLAY_SEQ is null)))
       AND ((recinfo.DB_SORT_COLUMN = X_DB_SORT_COLUMN)
          OR ((recinfo.DB_SORT_COLUMN is null) AND (X_DB_SORT_COLUMN is null)))
       AND ((recinfo.FIRE_POST_QUERY_FLAG = X_FIRE_POST_QUERY_FLAG)
           OR ((recinfo.FIRE_POST_QUERY_FLAG is null) AND (X_FIRE_POST_QUERY_FLAG is null)))
       AND ((recinfo.IMAGE_DESCRIPTION_COL = X_IMAGE_DESCRIPTION_COL)
           OR ((recinfo.IMAGE_DESCRIPTION_COL is null) AND (X_IMAGE_DESCRIPTION_COL is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.LABEL_TEXT = X_LABEL_TEXT)
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
  X_GRID_COL_ALIAS in VARCHAR2,
  X_DB_COL_NAME in VARCHAR2,
  X_DATA_TYPE_CODE in VARCHAR2,
  X_QUERY_SEQ in NUMBER,
  X_SORTABLE_FLAG in VARCHAR2,
  X_SORT_ASC_BY_DEFAULT_FLAG in VARCHAR2,
  X_VISIBLE_FLAG in VARCHAR2,
  X_FREEZE_VISIBLE_FLAG in VARCHAR2,
  X_DISPLAY_SEQ in NUMBER,
  X_DISPLAY_TYPE_CODE in VARCHAR2,
  X_DISPLAY_HSIZE in NUMBER,
  X_HEADER_ALIGNMENT_CODE in VARCHAR2,
  X_CELL_ALIGNMENT_CODE in VARCHAR2,
  X_DISPLAY_FORMAT_TYPE_CODE in VARCHAR2,
  X_DISPLAY_FORMAT_MASK in VARCHAR2,
  X_CHECKBOX_CHECKED_VALUE in VARCHAR2,
  X_CHECKBOX_UNCHECKED_VALUE in VARCHAR2,
  X_CHECKBOX_OTHER_VALUES in VARCHAR2,
  X_DB_CURRENCY_CODE_COL in VARCHAR2,
  X_LABEL_TEXT in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_QUERY_ALLOWED_FLAG in VARCHAR2,
  X_VALIDATION_OBJECT_CODE in VARCHAR2,
  X_QUERY_DISPLAY_SEQ in NUMBER,
  X_DB_SORT_COLUMN in VARCHAR2,
  X_FIRE_POST_QUERY_FLAG in VARCHAR2,
  X_IMAGE_DESCRIPTION_COL in VARCHAR2
) is
begin
  update JTF_GRID_COLS_B set
    DB_COL_NAME = X_DB_COL_NAME,
    DATA_TYPE_CODE = X_DATA_TYPE_CODE,
    QUERY_SEQ = X_QUERY_SEQ,
    SORTABLE_FLAG = X_SORTABLE_FLAG,
    SORT_ASC_BY_DEFAULT_FLAG = X_SORT_ASC_BY_DEFAULT_FLAG,
    VISIBLE_FLAG = X_VISIBLE_FLAG,
    FREEZE_VISIBLE_FLAG = X_FREEZE_VISIBLE_FLAG,
    DISPLAY_SEQ = X_DISPLAY_SEQ,
    DISPLAY_TYPE_CODE = X_DISPLAY_TYPE_CODE,
    DISPLAY_HSIZE = X_DISPLAY_HSIZE,
    HEADER_ALIGNMENT_CODE = X_HEADER_ALIGNMENT_CODE,
    CELL_ALIGNMENT_CODE = X_CELL_ALIGNMENT_CODE,
    DISPLAY_FORMAT_TYPE_CODE = X_DISPLAY_FORMAT_TYPE_CODE,
    DISPLAY_FORMAT_MASK = X_DISPLAY_FORMAT_MASK,
    CHECKBOX_CHECKED_VALUE = X_CHECKBOX_CHECKED_VALUE,
    CHECKBOX_UNCHECKED_VALUE = X_CHECKBOX_UNCHECKED_VALUE,
    CHECKBOX_OTHER_VALUES = X_CHECKBOX_OTHER_VALUES,
    DB_CURRENCY_CODE_COL = X_DB_CURRENCY_CODE_COL,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    QUERY_ALLOWED_FLAG = X_QUERY_ALLOWED_FLAG,
    VALIDATION_OBJECT_CODE = X_VALIDATION_OBJECT_CODE,
    QUERY_DISPLAY_SEQ  = X_QUERY_DISPLAY_SEQ ,
    DB_SORT_COLUMN = X_DB_SORT_COLUMN,
    FIRE_POST_QUERY_FLAG = X_FIRE_POST_QUERY_FLAG,
    IMAGE_DESCRIPTION_COL = X_IMAGE_DESCRIPTION_COL
  where GRID_DATASOURCE_NAME = X_GRID_DATASOURCE_NAME
  and GRID_COL_ALIAS = X_GRID_COL_ALIAS;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update JTF_GRID_COLS_TL set
    LABEL_TEXT = X_LABEL_TEXT,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where GRID_DATASOURCE_NAME = X_GRID_DATASOURCE_NAME
  and GRID_COL_ALIAS = X_GRID_COL_ALIAS
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;

  -- update the last updated by if it is 'SEED'
  update_header(x_grid_datasource_name, x_last_updated_by, x_last_update_date);

end UPDATE_ROW;


procedure DELETE_ROW (
  X_GRID_DATASOURCE_NAME in VARCHAR2,
  X_GRID_COL_ALIAS in VARCHAR2
) is
  grid_id JTF_CUSTOM_GRID_COLS.custom_grid_id%TYPE;
  WasError Boolean :=False;
begin
 --null;
  Begin
	 select custom_grid_id into grid_id from
	 JTF_CUSTOM_GRID_COLS where grid_datasource_name=X_GRID_DATASOURCE_NAME;
  Exception
  When Others then
	WasError:=True;
  End;

If Not WasError Then
  delete from JTF_CUSTOM_GRID_COLS
  where GRID_DATASOURCE_NAME = X_GRID_DATASOURCE_NAME
  and GRID_COL_ALIAS = X_GRID_COL_ALIAS
  and custom_grid_id=grid_id;
End If;

  delete from JTF_GRID_COLS_TL
  where GRID_DATASOURCE_NAME = X_GRID_DATASOURCE_NAME
  and GRID_COL_ALIAS = X_GRID_COL_ALIAS;

  delete from JTF_GRID_COLS_B
  where GRID_DATASOURCE_NAME = X_GRID_DATASOURCE_NAME
  and GRID_COL_ALIAS = X_GRID_COL_ALIAS;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure DELETE_ALL_ROWS (
  X_GRID_DATASOURCE_NAME in VARCHAR2
) is

  grid_id JTF_CUSTOM_GRID_COLS.custom_grid_id%TYPE;
  wasError Boolean :=False;
begin
--  null;

  Begin
  SELECT CUSTOM_GRID_ID INTO GRID_ID FROM
  JTF_CUSTOM_GRID_COLS where grid_datasource_name=X_GRID_DATASOURCE_NAME;
  Exception
  When Others Then
	WasError:=True;
  End;

  If Not WasError then
	  delete from JTF_CUSTOM_GRID_COLS
	  where GRID_DATASOURCE_NAME = X_GRID_DATASOURCE_NAME
	  and CUSTOM_GRID_ID=GRID_ID;
  End If;

  delete from JTF_GRID_COLS_TL
  where GRID_DATASOURCE_NAME = X_GRID_DATASOURCE_NAME;

  delete from JTF_GRID_COLS_B
  where GRID_DATASOURCE_NAME = X_GRID_DATASOURCE_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ALL_ROWS;


procedure ADD_LANGUAGE
is
begin
  delete from JTF_GRID_COLS_TL T
  where not exists
    (select NULL
    from JTF_GRID_COLS_B B
    where B.GRID_DATASOURCE_NAME = T.GRID_DATASOURCE_NAME
    and B.GRID_COL_ALIAS = T.GRID_COL_ALIAS
    );

  update JTF_GRID_COLS_TL T set (
      LABEL_TEXT
    ) = (select
      B.LABEL_TEXT
    from JTF_GRID_COLS_TL B
    where B.GRID_DATASOURCE_NAME = T.GRID_DATASOURCE_NAME
    and B.GRID_COL_ALIAS = T.GRID_COL_ALIAS
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.GRID_DATASOURCE_NAME,
      T.GRID_COL_ALIAS,
      T.LANGUAGE
  ) in (select
      SUBT.GRID_DATASOURCE_NAME,
      SUBT.GRID_COL_ALIAS,
      SUBT.LANGUAGE
    from JTF_GRID_COLS_TL SUBB, JTF_GRID_COLS_TL SUBT
    where SUBB.GRID_DATASOURCE_NAME = SUBT.GRID_DATASOURCE_NAME
    and SUBB.GRID_COL_ALIAS = SUBT.GRID_COL_ALIAS
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.LABEL_TEXT <> SUBT.LABEL_TEXT
  ));

  insert into JTF_GRID_COLS_TL (
    GRID_DATASOURCE_NAME,
    GRID_COL_ALIAS,
    LABEL_TEXT,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.GRID_DATASOURCE_NAME,
    B.GRID_COL_ALIAS,
    B.LABEL_TEXT,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from JTF_GRID_COLS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from JTF_GRID_COLS_TL T
    where T.GRID_DATASOURCE_NAME = B.GRID_DATASOURCE_NAME
    and T.GRID_COL_ALIAS = B.GRID_COL_ALIAS
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;


procedure LOAD_ROW (X_GRID_DATASOURCE_NAME in VARCHAR2,
  X_GRID_COL_ALIAS in VARCHAR2,
  X_DB_COL_NAME in VARCHAR2,
  X_DATA_TYPE_CODE in VARCHAR2,
  X_QUERY_SEQ in NUMBER,
  X_SORTABLE_FLAG in VARCHAR2,
  X_SORT_ASC_BY_DEFAULT_FLAG in VARCHAR2,
  X_VISIBLE_FLAG in VARCHAR2,
  X_FREEZE_VISIBLE_FLAG in VARCHAR2,
  X_DISPLAY_SEQ in NUMBER,
  X_DISPLAY_TYPE_CODE in VARCHAR2,
  X_DISPLAY_HSIZE in NUMBER,
  X_HEADER_ALIGNMENT_CODE in VARCHAR2,
  X_CELL_ALIGNMENT_CODE in VARCHAR2,
  X_DISPLAY_FORMAT_TYPE_CODE in VARCHAR2,
  X_DISPLAY_FORMAT_MASK in VARCHAR2,
  X_CHECKBOX_CHECKED_VALUE in VARCHAR2,
  X_CHECKBOX_UNCHECKED_VALUE in VARCHAR2,
  X_CHECKBOX_OTHER_VALUES in VARCHAR2,
  X_DB_CURRENCY_CODE_COL in VARCHAR2,
  X_LABEL_TEXT in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_QUERY_ALLOWED_FLAG in VARCHAR2,
  X_VALIDATION_OBJECT_CODE in VARCHAR2,
  X_QUERY_DISPLAY_SEQ in NUMBER,
  X_DB_SORT_COLUMN in VARCHAR2,
  X_FIRE_POST_QUERY_FLAG in VARCHAR2,
  X_IMAGE_DESCRIPTION_COL in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2,
  X_LAST_UPDATE_DATE in VARCHAR2) is
  row_id  varchar2(64);
  user    number;
  dummy varchar2(1);
  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db
  cursor c_check_unique is
    select 'x'
    from jtf_grid_cols_vl
    where grid_datasource_name = X_GRID_DATASOURCE_NAME
    and   grid_col_alias      <> X_GRID_COL_ALIAS
    and   label_text           = X_LABEL_TEXT;
begin

        -- Translate owner to file_last_updated_by
        f_luby := fnd_load_util.owner_id(X_OWNER);

        -- Translate char last_update_date to date
        f_ludate := nvl(to_date(X_LAST_UPDATE_DATE, 'YYYY/MM/DD'), sysdate);

      begin


          select LAST_UPDATED_BY, LAST_UPDATE_DATE
          into db_luby, db_ludate
          from JTF_GRID_COLS_B
          where GRID_DATASOURCE_NAME = x_grid_datasource_name
	  AND GRID_COL_ALIAS = X_GRID_COL_ALIAS;


        /*
          select 'X'
          into dummy
          from JTF_GRID_COLS_B
          where GRID_DATASOURCE_NAME = x_grid_datasource_name;
         */

          -- Test for customization and version
          if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                        db_ludate, X_CUSTOM_MODE)) then

           UPDATE_ROW (X_GRID_DATASOURCE_NAME => X_GRID_DATASOURCE_NAME
  	      	  ,X_GRID_COL_ALIAS => X_GRID_COL_ALIAS
		      ,X_DB_COL_NAME => X_DB_COL_NAME
		    ,X_DATA_TYPE_CODE => X_DATA_TYPE_CODE
		    ,X_QUERY_SEQ => X_QUERY_SEQ
		    ,X_SORTABLE_FLAG => X_SORTABLE_FLAG
		    ,X_SORT_ASC_BY_DEFAULT_FLAG => X_SORT_ASC_BY_DEFAULT_FLAG
		    ,X_VISIBLE_FLAG  => X_VISIBLE_FLAG
		    ,X_FREEZE_VISIBLE_FLAG => X_FREEZE_VISIBLE_FLAG
		    ,X_DISPLAY_SEQ => X_DISPLAY_SEQ
		    ,X_DISPLAY_TYPE_CODE => X_DISPLAY_TYPE_CODE
		    ,X_DISPLAY_HSIZE => X_DISPLAY_HSIZE
		    ,X_HEADER_ALIGNMENT_CODE => X_HEADER_ALIGNMENT_CODE
		    ,X_CELL_ALIGNMENT_CODE => X_CELL_ALIGNMENT_CODE
		    ,X_DISPLAY_FORMAT_TYPE_CODE => X_DISPLAY_FORMAT_TYPE_CODE
		    ,X_DISPLAY_FORMAT_MASK => X_DISPLAY_FORMAT_MASK
		    ,X_CHECKBOX_CHECKED_VALUE => X_CHECKBOX_CHECKED_VALUE
		    ,X_CHECKBOX_UNCHECKED_VALUE => X_CHECKBOX_UNCHECKED_VALUE
		    ,X_CHECKBOX_OTHER_VALUES => X_CHECKBOX_OTHER_VALUES
		    ,X_DB_CURRENCY_CODE_COL => X_DB_CURRENCY_CODE_COL
		    ,X_LABEL_TEXT => X_LABEL_TEXT
		    ,X_LAST_UPDATE_DATE => f_ludate
		    ,X_LAST_UPDATED_BY => f_luby
		    ,X_LAST_UPDATE_LOGIN => 0
		    ,X_QUERY_ALLOWED_FLAG       => X_QUERY_ALLOWED_FLAG
		    ,X_VALIDATION_OBJECT_CODE   => X_VALIDATION_OBJECT_CODE
		    ,X_QUERY_DISPLAY_SEQ        => X_QUERY_DISPLAY_SEQ
		    ,X_DB_SORT_COLUMN     => X_DB_SORT_COLUMN
		    ,X_FIRE_POST_QUERY_FLAG    => X_FIRE_POST_QUERY_FLAG
		    ,X_IMAGE_DESCRIPTION_COL   => X_IMAGE_DESCRIPTION_COL);
              end if;


exception
  when no_data_found then
    INSERT_ROW (X_ROWID => row_id
        ,X_GRID_DATASOURCE_NAME => X_GRID_DATASOURCE_NAME
        ,X_GRID_COL_ALIAS => X_GRID_COL_ALIAS
        ,X_DB_COL_NAME => X_DB_COL_NAME
        ,X_DATA_TYPE_CODE => X_DATA_TYPE_CODE
        ,X_QUERY_SEQ => X_QUERY_SEQ
        ,X_SORTABLE_FLAG => X_SORTABLE_FLAG
        ,X_SORT_ASC_BY_DEFAULT_FLAG => X_SORT_ASC_BY_DEFAULT_FLAG
        ,X_VISIBLE_FLAG  => X_VISIBLE_FLAG
        ,X_FREEZE_VISIBLE_FLAG  => X_FREEZE_VISIBLE_FLAG
        ,X_DISPLAY_SEQ =>  X_DISPLAY_SEQ
        ,X_DISPLAY_TYPE_CODE =>  X_DISPLAY_TYPE_CODE
        ,X_DISPLAY_HSIZE  => X_DISPLAY_HSIZE
        ,X_HEADER_ALIGNMENT_CODE  => X_HEADER_ALIGNMENT_CODE
        ,X_CELL_ALIGNMENT_CODE =>  X_CELL_ALIGNMENT_CODE
        ,X_DISPLAY_FORMAT_TYPE_CODE  => X_DISPLAY_FORMAT_TYPE_CODE
        ,X_DISPLAY_FORMAT_MASK  =>  X_DISPLAY_FORMAT_MASK
        ,X_CHECKBOX_CHECKED_VALUE =>  X_CHECKBOX_CHECKED_VALUE
        ,X_CHECKBOX_UNCHECKED_VALUE =>  X_CHECKBOX_UNCHECKED_VALUE
        ,X_CHECKBOX_OTHER_VALUES =>  X_CHECKBOX_OTHER_VALUES
        ,X_DB_CURRENCY_CODE_COL =>  X_DB_CURRENCY_CODE_COL
        ,X_LABEL_TEXT =>  X_LABEL_TEXT
        ,X_CREATION_DATE =>  f_ludate
        ,X_CREATED_BY =>  f_luby
        ,X_LAST_UPDATE_DATE =>  f_ludate
        ,X_LAST_UPDATED_BY =>  f_luby
        ,X_LAST_UPDATE_LOGIN =>  0
        ,X_QUERY_ALLOWED_FLAG       => X_QUERY_ALLOWED_FLAG
        ,X_VALIDATION_OBJECT_CODE   => X_VALIDATION_OBJECT_CODE
        ,X_QUERY_DISPLAY_SEQ        => X_QUERY_DISPLAY_SEQ
        ,X_DB_SORT_COLUMN     => X_DB_SORT_COLUMN
        ,X_FIRE_POST_QUERY_FLAG    => X_FIRE_POST_QUERY_FLAG
        ,X_IMAGE_DESCRIPTION_COL   => X_IMAGE_DESCRIPTION_COL);
  end;
end LOAD_ROW;


procedure TRANSLATE_ROW(X_GRID_DATASOURCE_NAME in VARCHAR2,
  X_GRID_COL_ALIAS in VARCHAR2,
  X_LABEL_TEXT in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2,
  X_LAST_UPDATE_DATE in VARCHAR2) is
  dummy varchar2(1);
  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db
  cursor c_check_unique is
    select 'x'
    from jtf_grid_cols_vl
    where grid_datasource_name = X_GRID_DATASOURCE_NAME
    and   grid_col_alias      <> X_GRID_COL_ALIAS
    and   label_text           = X_LABEL_TEXT;
begin
     -- Translate owner to file_last_updated_by
    f_luby := fnd_load_util.owner_id(X_OWNER);

    -- Translate char last_update_date to date
    f_ludate := nvl(to_date(X_LAST_UPDATE_DATE, 'YYYY/MM/DD'), sysdate);


    select LAST_UPDATED_BY, LAST_UPDATE_DATE
    into db_luby, db_ludate
    from JTF_GRID_COLS_TL
    where GRID_DATASOURCE_NAME = x_grid_datasource_name
    and GRID_COL_ALIAS = X_GRID_COL_ALIAS
    and LANGUAGE = userenv('LANG');

 -- Test for customization and version
    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                        db_ludate, X_CUSTOM_MODE)) then

    -- we we need to check that we are not
    -- going to violate the unique key
    -- on jtf_grid_cols_tl, if so add an '@'
    -- character to the label_text and try again
    -- this will be a recursive call until the
    -- label is unique
    open c_check_unique;
    fetch c_check_unique into dummy;
    if c_check_unique%FOUND then
      close c_check_unique;
      JTF_GRID_COLS_PKG.TRANSLATE_ROW
      (X_GRID_DATASOURCE_NAME     => X_GRID_DATASOURCE_NAME
       ,X_GRID_COL_ALIAS           => X_GRID_COL_ALIAS
       ,X_LABEL_TEXT               => '@'||substrb(X_LABEL_TEXT,1,77)
       ,X_OWNER                    => X_OWNER
       ,X_CUSTOM_MODE              => X_CUSTOM_MODE
       ,X_LAST_UPDATE_DATE         => X_LAST_UPDATE_DATE);
    else
      close c_check_unique;
      begin
        update JTF_GRID_COLS_TL
        set LABEL_TEXT = nvl(X_LABEL_TEXT,LABEL_TEXT)
         ,LAST_UPDATE_DATE = f_ludate
         ,LAST_UPDATED_BY = f_luby
         ,LAST_UPDATE_LOGIN = 0
         ,SOURCE_LANG = userenv('LANG')
        where userenv('LANG') in (LANGUAGE,SOURCE_LANG)
        and GRID_DATASOURCE_NAME = X_GRID_DATASOURCE_NAME
        and GRID_COL_ALIAS = X_GRID_COL_ALIAS;
      exception
          when no_data_found then
            -- Do not insert missing translations, skip this row
            null;
       end;

    end if;
  end if;
end TRANSLATE_ROW;
function getVersion return VARCHAR2 IS
begin
 RETURN('$Header: JTFGCPKB.pls 120.4 2006/09/20 07:58:17 snellepa ship $');
end getVersion;

procedure DELETE_ROW (
  X_GRID_DATASOURCE_NAME in VARCHAR2,
  X_LAST_UPDATED_BY in number,
  X_LAST_UPDATE_DATE in date
) is
 grid_id JTF_CUSTOM_GRID_COLS.custom_grid_id%TYPE;
 WasError boolean :=False;
begin

  begin
	select custom_grid_id into grid_id from
	JTF_CUSTOM_GRID_COLS where grid_datasource_name=X_GRID_DATASOURCE_NAME;
  exception
  when others then
	wasError:=True;
  end;

  if Not WasError then
	  delete from JTF_CUSTOM_GRID_COLS
	  where GRID_DATASOURCE_NAME = X_GRID_DATASOURCE_NAME
	  and custom_grid_id=grid_id;
  end If;

  delete from JTF_GRID_COLS_TL
  where GRID_DATASOURCE_NAME = X_GRID_DATASOURCE_NAME ;

  delete from JTF_GRID_COLS_B
  where GRID_DATASOURCE_NAME = X_GRID_DATASOURCE_NAME ;

  update_header(x_grid_datasource_name, x_last_updated_by, x_last_update_date);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure update_header(p_datasource_name in varchar2,
                       p_owner in number:= fnd_global.user_id,
                       p_last_update_date in date ) is
l_header_owner number;
begin
/*  select last_updated_by
  into l_header_owner
  from jtf_grid_datasources_b
  where grid_datasource_name = p_datasource_name;

  -- if header is not 'SEED' and the cols are modified by 'USER' only then
  -- update the header
  if (l_header_owner = 1 and p_owner <> 1) then
 */
    update jtf_grid_datasources_b
     set last_updated_by = p_owner,
         last_update_date = p_last_update_date
     where grid_Datasource_name = p_datasource_name;
end update_header;


procedure DELETE_ROW (
  X_GRID_DATASOURCE_NAME in VARCHAR2,
  X_GRID_COL_ALIAS in VARCHAR2,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in date
  --X_CUSTOM_MODE in VARCHAR2 := 'FORCE'
) is
begin
   delete from JTF_CUSTOM_GRID_COLS
  where GRID_DATASOURCE_NAME = X_GRID_DATASOURCE_NAME
  and GRID_COL_ALIAS = X_GRID_COL_ALIAS;

  delete from JTF_GRID_COLS_TL
  where GRID_DATASOURCE_NAME = X_GRID_DATASOURCE_NAME
  and GRID_COL_ALIAS = X_GRID_COL_ALIAS;

  delete from JTF_GRID_COLS_B
  where GRID_DATASOURCE_NAME = X_GRID_DATASOURCE_NAME
  and GRID_COL_ALIAS = X_GRID_COL_ALIAS;

   update_header(x_grid_datasource_name, x_last_updated_by, x_last_update_date);

  if (sql%notfound) then
    raise no_data_found;
  end if;


end;

end JTF_GRID_COLS_PKG;

/
