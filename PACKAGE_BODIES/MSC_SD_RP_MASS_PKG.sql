--------------------------------------------------------
--  DDL for Package Body MSC_SD_RP_MASS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_SD_RP_MASS_PKG" as
/* $Header: MSCRPSDB.pls 120.0.12010000.3 2010/04/23 21:33:10 hulu noship $ */


X_LANG VARCHAR2(2);

procedure INSERT_ROW (
  X_TABLE_NAME		in VARCHAR2,
  X_COLUMN_NAME		in VARCHAR2,
  X_VALUE_TYPE		in VARCHAR2,
  X_OPERATION_LOV_SQL	in VARCHAR2,
  X_VALUE_LOV_NAME	in VARCHAR2,
  X_FIELD_NAME		IN VARCHAR2,
  X_DEPENDENT_COLUMN    IN VARCHAR2,
  X_CREATION_DATE	in DATE,
  X_CREATED_BY		in NUMBER,
  X_LAST_UPDATE_DATE	in DATE,
  X_LAST_UPDATED_BY	in NUMBER,
  X_LAST_UPDATE_LOGIN	in NUMBER
) is

begin
  insert into MSC_ORP_MASS_UPDATE_COLUMNS_B (
    TABLE_NAME,
    COLUMN_NAME,
    VALUE_TYPE,
    OPERATION_LOV_SQL,
    VALUE_LOV_NAME,
    DEPENDENT_COLUMN,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
   ) values (
    X_TABLE_NAME,
    X_COLUMN_NAME,
    X_VALUE_TYPE,
    X_OPERATION_LOV_SQL,
    X_VALUE_LOV_NAME,
    X_DEPENDENT_COLUMN,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into MSC_ORP_MASS_UPDATE_COLUMNS_TL (
    TABLE_NAME,
    COLUMN_NAME,
    FIELD_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_TABLE_NAME,
    X_COLUMN_NAME,
    X_FIELD_NAME,
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
    from MSC_ORP_MASS_UPDATE_COLUMNS_TL T
    where T.TABLE_NAME = X_TABLE_NAME
    AND   T.COLUMN_NAME= X_COLUMN_NAME
    and T.LANGUAGE = L.LANGUAGE_CODE);


end INSERT_ROW;



procedure TRANSLATE_ROW (
  X_TABLE_NAME		in VARCHAR2,
  X_COLUMN_NAME		in VARCHAR2,
  X_FIELD_NAME		IN VARCHAR2 ,
  X_OWNER               in VARCHAR2,
  X_LAST_UPDATE_DATE    in VARCHAR2,
  X_CUSTOM_MODE         in VARCHAR2)
is
  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db


begin
  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(X_LAST_UPDATE_DATE, 'YYYY/MM/DD'), sysdate);

  select last_updated_by, last_update_date
  into db_luby, db_ludate
  from MSC_ORP_MASS_UPDATE_COLUMNS_TL
  where TABLE_NAME      = X_TABLE_NAME
  and COLUMN_NAME	= X_COLUMN_NAME
  and language            = userenv('LANG');

  if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                db_ludate, X_CUSTOM_MODE)) then
    update MSC_ORP_MASS_UPDATE_COLUMNS_TL set
      FIELD_NAME        = X_FIELD_NAME,
      last_update_date  = f_ludate,
      last_updated_by   = f_luby,
      last_update_login = 0,
      source_lang       = userenv('LANG')
    where TABLE_NAME       = X_TABLE_NAME
    and COLUMN_NAME   = X_COLUMN_NAME
    and userenv('LANG') in (language, source_lang);

  END IF;

end TRANSLATE_ROW;



procedure UPDATE_ROW (
  X_TABLE_NAME		IN VARCHAR2,
  X_COLUMN_NAME		IN VARCHAR2,
  X_VALUE_TYPE		IN VARCHAR2,
  X_OPERATION_LOV_SQL	IN VARCHAR2,
  X_VALUE_LOV_NAME	IN VARCHAR2,
  X_DEPENDENT_COLUMN    IN VARCHAR2,
  X_FIELD_NAME		IN VARCHAR2,
  X_LAST_UPDATE_DATE	IN DATE,
  X_LAST_UPDATED_BY	IN NUMBER,
  X_LAST_UPDATE_LOGIN	IN NUMBER
) is


begin
  update MSC_ORP_MASS_UPDATE_COLUMNS_B set
    OPERATION_LOV_SQL	= X_OPERATION_LOV_SQL,
    VALUE_TYPE		= X_VALUE_TYPE,
    VALUE_LOV_NAME	= X_VALUE_LOV_NAME,
    DEPENDENT_COLUMN	= X_DEPENDENT_COLUMN,
    LAST_UPDATE_DATE	= X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY	= X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN	= X_LAST_UPDATE_LOGIN
  where TABLE_NAME	= X_TABLE_NAME
  and COLUMN_NAME	= X_COLUMN_NAME;


  if (sql%notfound) then
    raise no_data_found;
  end if;

  update MSC_ORP_MASS_UPDATE_COLUMNS_TL set
    FIELD_NAME		= X_FIELD_NAME,
    LAST_UPDATE_DATE	= X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY	= X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN	= X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where TABLE_NAME	= X_TABLE_NAME
  and COLUMN_NAME	= X_COLUMN_NAME
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;



procedure LOAD_ROW (
  X_TABLE_NAME		IN VARCHAR2,
  X_COLUMN_NAME		IN VARCHAR2,
  X_VALUE_TYPE		IN VARCHAR2,
  X_OPERATION_LOV_SQL	IN VARCHAR2,
  X_VALUE_LOV_NAME	IN VARCHAR2,
  X_FIELD_NAME		IN VARCHAR2,
  X_DEPENDENT_COLUMN    IN VARCHAR2,
  X_OWNER               in VARCHAR2,
  X_LAST_UPDATE_DATE    in VARCHAR2,
  X_CUSTOM_MODE         in VARCHAR2
  )
is
  L_COLUMN_NAME  VARCHAR2(50);
  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db

  cursor EXISTING_ROW is
    select T.COLUMN_NAME
    from MSC_ORP_MASS_UPDATE_COLUMNS_B T
    where T.TABLE_NAME = X_TABLE_NAME
    AND T.COLUMN_NAME =X_COLUMN_NAME;


begin

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

  open EXISTING_ROW;
  fetch EXISTING_ROW into L_COLUMN_NAME;

  if (EXISTING_ROW%notfound) then

    Insert_Row(
      X_TABLE_NAME          => X_TABLE_NAME,
      x_COLUMN_NAME         => x_COLUMN_NAME,
      x_OPERATION_LOV_SQL   => X_OPERATION_LOV_SQL,
      x_VALUE_TYPE	    => X_VALUE_TYPE,
      x_VALUE_LOV_NAME      => X_VALUE_LOV_NAME,
      X_FIELD_NAME          => x_FIELD_NAME,
      X_DEPENDENT_COLUMN    => X_DEPENDENT_COLUMN,
      x_creation_date       => f_ludate,
      x_created_by          => f_luby,
      x_last_update_date    => f_ludate,
      x_last_updated_by     => f_luby,
      x_last_update_login   => 0);
  else

      select LAST_UPDATED_BY, LAST_UPDATE_DATE
      into db_luby, db_ludate
      from MSC_ORP_MASS_UPDATE_COLUMNS_B
      where TABLE_NAME = x_TABLE_NAME
      and COLUMN_NAME = X_COLUMN_NAME;


      if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                    db_ludate, X_CUSTOM_MODE)) then

        Update_Row(
          x_TABLE_NAME		=> x_TABLE_NAME,
          x_COLUMN_NAME		=> X_COLUMN_NAME,
          x_VALUE_TYPE		=> X_VALUE_TYPE,
          x_OPERATION_LOV_SQL   => X_OPERATION_LOV_SQL,
          x_VALUE_LOV_NAME	=> X_VALUE_LOV_NAME,
          x_FIELD_NAME          => x_FIELD_NAME,
	  X_DEPENDENT_COLUMN	=> X_DEPENDENT_COLUMN,
          x_last_update_date    => f_ludate,
          x_last_updated_by     => f_luby,
          x_last_update_login   => 0);
      end if;



  end if;

  close EXISTING_ROW;

end LOAD_ROW;

procedure ADD_LANGUAGE
is
begin

insert into msc_orp_mass_update_columns_tl (
 TABLE_NAME                            ,
 COLUMN_NAME                              ,
 LANGUAGE                                 ,
 SOURCE_LANG                              ,
 FIELD_NAME                               ,
 LAST_UPDATE_DATE                         ,
 LAST_UPDATED_BY                          ,
 CREATION_DATE                            ,
 CREATED_BY                               ,
 LAST_UPDATE_LOGIN
  ) select
    B.table_name,
    B.column_name,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG,
    B.field_name,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN
  from msc_orp_mass_update_columns_tl  B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from msc_orp_mass_update_columns_tl  T
    where T.table_name = B.table_name
    and T.column_name = B.column_name
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end MSC_SD_RP_MASS_PKG;

/
