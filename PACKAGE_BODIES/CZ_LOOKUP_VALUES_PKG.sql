--------------------------------------------------------
--  DDL for Package Body CZ_LOOKUP_VALUES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CZ_LOOKUP_VALUES_PKG" as
/* $Header: czilkvlb.pls 120.0 2005/05/25 05:51:13 appldev noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_LIST_NAME in VARCHAR2,
  X_DATA_VALUE in VARCHAR2,
  X_NULL_VALUE_FLAG in VARCHAR2,
  X_DELETED_FLAG in VARCHAR2,
  X_NUMERIC_ID_VALUE in NUMBER,
  X_SEEDED_FLAG in VARCHAR2,
  X_VALUE_LABEL in VARCHAR2,
  X_VALUE_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from CZ_LOOKUP_VALUES_TL
    where LIST_NAME = X_LIST_NAME
    and DATA_VALUE = X_DATA_VALUE
	and language = userenv('LANG');
begin
  insert into CZ_LOOKUP_VALUES_TL (
    LIST_NAME,
    DATA_VALUE,
    NULL_VALUE_FLAG,
    VALUE_LABEL,
    VALUE_DESCRIPTION,
    LAST_UPDATE_LOGIN,
    CREATION_DATE,
    LAST_UPDATE_DATE,
    CREATED_BY,
    LAST_UPDATED_BY,
    DELETED_FLAG,
    NUMERIC_ID_VALUE,
    SEEDED_FLAG,
    SOURCE_LANG,
    LANGUAGE
  ) select
    X_LIST_NAME,
    X_DATA_VALUE,
    X_NULL_VALUE_FLAG,
    X_VALUE_LABEL,
    X_VALUE_DESCRIPTION,
    X_LAST_UPDATE_LOGIN,
    X_CREATION_DATE,
    X_LAST_UPDATE_DATE,
    X_CREATED_BY,
    X_LAST_UPDATED_BY,
    X_DELETED_FLAG,
    X_NUMERIC_ID_VALUE,
    X_SEEDED_FLAG,
    userenv('LANG'),
    L.LANGUAGE_CODE
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from CZ_LOOKUP_VALUES_TL T
    where T.LIST_NAME = X_LIST_NAME
    and T.DATA_VALUE = X_DATA_VALUE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_LIST_NAME in VARCHAR2,
  X_DATA_VALUE in VARCHAR2,
  X_NULL_VALUE_FLAG in VARCHAR2,
  X_DELETED_FLAG in VARCHAR2,
  X_NUMERIC_ID_VALUE in NUMBER,
  X_SEEDED_FLAG in VARCHAR2,
  X_VALUE_LABEL in VARCHAR2,
  X_VALUE_DESCRIPTION in VARCHAR2
) IS
begin
NULL;

end LOCK_ROW;

procedure UPDATE_ROW (
  X_LIST_NAME in VARCHAR2,
  X_DATA_VALUE in VARCHAR2,
  X_NULL_VALUE_FLAG in VARCHAR2,
  X_DELETED_FLAG in VARCHAR2,
  X_NUMERIC_ID_VALUE in NUMBER,
  X_SEEDED_FLAG in VARCHAR2,
  X_VALUE_LABEL in VARCHAR2,
  X_VALUE_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update CZ_LOOKUP_VALUES_TL set
    LIST_NAME = X_LIST_NAME,
    DATA_VALUE = X_DATA_VALUE,
    NULL_VALUE_FLAG = X_NULL_VALUE_FLAG,
    DELETED_FLAG = X_DELETED_FLAG,
    NUMERIC_ID_VALUE = X_NUMERIC_ID_VALUE,
    SEEDED_FLAG = X_SEEDED_FLAG,
    VALUE_LABEL = X_VALUE_LABEL,
    VALUE_DESCRIPTION = X_VALUE_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where LIST_NAME = X_LIST_NAME
  and DATA_VALUE = X_DATA_VALUE;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_LIST_NAME in VARCHAR2,
  X_DATA_VALUE in VARCHAR2
) is
begin
  delete from CZ_LOOKUP_VALUES_TL
  where LIST_NAME = X_LIST_NAME
  and DATA_VALUE = X_DATA_VALUE
  and language = userenv('LANG');

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin

  insert into CZ_LOOKUP_VALUES_TL (
    LIST_NAME,
    DATA_VALUE,
    NULL_VALUE_FLAG,
    VALUE_LABEL,
    VALUE_DESCRIPTION,
    LANGUAGE,
    LAST_UPDATE_LOGIN,
    CREATION_DATE,
    LAST_UPDATE_DATE,
    CREATED_BY,
    LAST_UPDATED_BY,
    DELETED_FLAG,
    NUMERIC_ID_VALUE,
    SEEDED_FLAG,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.LIST_NAME,
    B.DATA_VALUE,
    B.NULL_VALUE_FLAG,
    B.VALUE_LABEL,
    B.VALUE_DESCRIPTION,
    L.LANGUAGE_CODE,
    B.LAST_UPDATE_LOGIN,
    B.CREATION_DATE,
    B.LAST_UPDATE_DATE,
    B.CREATED_BY,
    B.LAST_UPDATED_BY,
    B.DELETED_FLAG,
    B.NUMERIC_ID_VALUE,
    B.SEEDED_FLAG,
    B.SOURCE_LANG
  from CZ_LOOKUP_VALUES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from CZ_LOOKUP_VALUES_TL T
    where T.LIST_NAME = B.LIST_NAME
    and T.DATA_VALUE = B.DATA_VALUE
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

-- ----------------------------------------------------------------------
-- PROCEDURE:  Translate_Row        PUBLIC
--
-- PARAMETERS:
--  x_<developer key>
--  x_<translated columns>
--  x_owner             user owning the row (SEED or other)
--
-- COMMENT:
--  Called from the FNDLOAD config file in 'NLS' mode to upload
--  translations.
-- ----------------------------------------------------------------------

PROCEDURE Translate_Row
(X_LIST_NAME	IN  VARCHAR2,
 X_DATA_VALUE	IN  VARCHAR2,
 x_value_label	IN  VARCHAR2,
 x_value_description	IN  VARCHAR2,
 X_OWNER          IN  VARCHAR2) IS

f_luby    number;  -- entity owner in file

BEGIN

-- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(X_OWNER);

    UPDATE CZ_LOOKUP_VALUES_TL
    SET value_label       = NVL(x_value_label, value_label)
	, value_description  = NVL(x_value_description, value_description)
      , last_update_date  = SYSDATE
      , last_updated_by   = f_luby
      , last_update_login = 0
      , source_lang       = userenv('LANG')
    WHERE LIST_NAME = X_LIST_NAME and DATA_VALUE = X_DATA_VALUE
	AND userenv('LANG') IN (language, source_lang);
commit;

END Translate_Row;

procedure LOAD_ROW
(X_LIST_NAME	IN  VARCHAR2,
 X_DATA_VALUE	IN  VARCHAR2,
 x_value_label	IN  VARCHAR2,
 x_value_description	IN  VARCHAR2,
 X_NULL_VALUE_FLAG IN  VARCHAR2,
 X_DELETED_FLAG	IN	VARCHAR2,
 X_NUMERIC_ID_VALUE IN	VARCHAR2,
 X_CREATION_DATE IN	VARCHAR2,
 X_OWNER          IN  VARCHAR2,
 X_LAST_UPDATE_DATE       in VARCHAR2,
 X_SEEDED_FLAG	 IN VARCHAR2)
IS
  s_lname   cz_lookup_values.list_name%type; -- entity list_name
  s_dvalue  cz_lookup_values.data_value%type; -- entity data_value
  f_luby    number;   -- entity owner in file
  f_ludate  date;     -- entity update date in file
  db_luby   number;   -- entity owner in db
  db_ludate date;     -- entity update date in db
  row_id varchar2(64);


cursor c_lvals is
	select list_name, data_value
	from cz_lookup_values_tl
	where list_name = x_list_name
	and data_value = x_data_value
	and language = userenv('LANG');

begin

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

open c_lvals;
fetch c_lvals into s_lname, s_dvalue;

	if (c_lvals%notfound) then
		-- No matching rows
		CZ_LOOKUP_VALUES_PKG.INSERT_ROW(
			X_ROWID 		   => row_id,
			X_LIST_NAME          => X_LIST_NAME,
			X_DATA_VALUE         => X_DATA_VALUE,
			X_NULL_VALUE_FLAG    => X_NULL_VALUE_FLAG,
			X_DELETED_FLAG       => X_DELETED_FLAG,
			X_NUMERIC_ID_VALUE   => X_NUMERIC_ID_VALUE,
			X_SEEDED_FLAG        => X_SEEDED_FLAG,
			X_VALUE_LABEL        => X_VALUE_LABEL,
			X_VALUE_DESCRIPTION  => X_VALUE_DESCRIPTION,
			X_CREATION_DATE      => nvl(to_date(X_CREATION_DATE, 'RRRR-MM-DD'), sysdate),
			X_CREATED_BY         => UID,
			X_LAST_UPDATE_DATE   => nvl(to_date(X_LAST_UPDATE_DATE, 'RRRR-MM-DD'), sysdate),
			X_LAST_UPDATED_BY    => f_luby,
			X_LAST_UPDATE_LOGIN  => UID
			);
	else
		    loop
			select LAST_UPDATED_BY, LAST_UPDATE_DATE
			into db_luby, db_ludate
			from cz_lookup_values_tl
			where list_name = x_list_name
			and data_value = x_data_value
			and language = userenv('LANG');
        	-- Update row in all matching lookups
			CZ_LOOKUP_VALUES_PKG.UPDATE_ROW (
				X_LIST_NAME => X_LIST_NAME,
				X_DATA_VALUE => X_DATA_VALUE,
				X_NULL_VALUE_FLAG => X_NULL_VALUE_FLAG,
				X_DELETED_FLAG => X_DELETED_FLAG,
				X_NUMERIC_ID_VALUE => X_NUMERIC_ID_VALUE,
				X_SEEDED_FLAG => X_SEEDED_FLAG,
				X_VALUE_LABEL => X_VALUE_LABEL,
				X_VALUE_DESCRIPTION => X_VALUE_DESCRIPTION,
				X_LAST_UPDATE_DATE => f_ludate,
				X_LAST_UPDATED_BY => f_luby,
				X_LAST_UPDATE_LOGIN => 0);

			fetch c_lvals into s_lname, s_dvalue;
			exit when c_lvals%notfound;
			end loop;
	end if;
close c_lvals;

end LOAD_ROW;

end CZ_LOOKUP_VALUES_PKG;

/
