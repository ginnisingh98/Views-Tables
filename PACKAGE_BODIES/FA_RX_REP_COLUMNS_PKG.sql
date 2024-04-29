--------------------------------------------------------
--  DDL for Package Body FA_RX_REP_COLUMNS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_RX_REP_COLUMNS_PKG" as
/* $Header: faxrxrcb.pls 120.5.12010000.2 2009/07/19 13:14:52 glchen ship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_REPORT_ID in NUMBER,
  X_ATTRIBUTE_SET in VARCHAR2,
  X_COLUMN_NAME in VARCHAR2,
  X_CURRENCY_COLUMN in VARCHAR2,
  X_PRECISION in NUMBER,
  X_BREAK_GROUP_LEVEL in NUMBER,
  X_MINIMUM_ACCOUNTABLE_UNIT in NUMBER,
  X_UNITS in NUMBER,
  X_FORMAT_MASK in VARCHAR2,
  X_ORDERING in VARCHAR2,
  X_DISPLAY_LENGTH in NUMBER,
  X_DISPLAY_FORMAT in VARCHAR2,
  X_DISPLAY_STATUS in VARCHAR2,
  X_BREAK in VARCHAR2,
  X_ATTRIBUTE_COUNTER in NUMBER,
  X_ATTRIBUTE_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from FA_RX_REP_COLUMNS_B
    where REPORT_ID = X_REPORT_ID
    and ATTRIBUTE_SET = X_ATTRIBUTE_SET
    and COLUMN_NAME = X_COLUMN_NAME
    ;
begin
  insert into FA_RX_REP_COLUMNS_B (
    CURRENCY_COLUMN,
    PRECISION,
    BREAK_GROUP_LEVEL,
    MINIMUM_ACCOUNTABLE_UNIT,
    UNITS,
    FORMAT_MASK,
    REPORT_ID,
    COLUMN_NAME,
    ORDERING,
    DISPLAY_LENGTH,
    DISPLAY_FORMAT,
    DISPLAY_STATUS,
    ATTRIBUTE_SET,
    BREAK,
    ATTRIBUTE_COUNTER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_CURRENCY_COLUMN,
    X_PRECISION,
    X_BREAK_GROUP_LEVEL,
    X_MINIMUM_ACCOUNTABLE_UNIT,
    X_UNITS,
    X_FORMAT_MASK,
    X_REPORT_ID,
    X_COLUMN_NAME,
    X_ORDERING,
    X_DISPLAY_LENGTH,
    X_DISPLAY_FORMAT,
    X_DISPLAY_STATUS,
    X_ATTRIBUTE_SET,
    X_BREAK,
    X_ATTRIBUTE_COUNTER,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into FA_RX_REP_COLUMNS_TL (
    REPORT_ID,
    ATTRIBUTE_SET,
    COLUMN_NAME,
    ATTRIBUTE_NAME,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LAST_UPDATED_BY,
    CREATED_BY,
    CREATION_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_REPORT_ID,
    X_ATTRIBUTE_SET,
    X_COLUMN_NAME,
    X_ATTRIBUTE_NAME,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    X_LAST_UPDATED_BY,
    X_CREATED_BY,
    X_CREATION_DATE,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from FA_RX_REP_COLUMNS_TL T
    where T.REPORT_ID = X_REPORT_ID
    and T.ATTRIBUTE_SET = X_ATTRIBUTE_SET
    and T.COLUMN_NAME = X_COLUMN_NAME
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
  X_REPORT_ID in NUMBER,
  X_ATTRIBUTE_SET in VARCHAR2,
  X_COLUMN_NAME in VARCHAR2,
  X_CURRENCY_COLUMN in VARCHAR2,
  X_PRECISION in NUMBER,
  X_BREAK_GROUP_LEVEL in NUMBER,
  X_MINIMUM_ACCOUNTABLE_UNIT in NUMBER,
  X_UNITS in NUMBER,
  X_FORMAT_MASK in VARCHAR2,
  X_ORDERING in VARCHAR2,
  X_DISPLAY_LENGTH in NUMBER,
  X_DISPLAY_FORMAT in VARCHAR2,
  X_DISPLAY_STATUS in VARCHAR2,
  X_BREAK in VARCHAR2,
  X_ATTRIBUTE_COUNTER in NUMBER,
  X_ATTRIBUTE_NAME in VARCHAR2
) is
  cursor c is select
      CURRENCY_COLUMN,
      PRECISION,
      BREAK_GROUP_LEVEL,
      MINIMUM_ACCOUNTABLE_UNIT,
      UNITS,
      FORMAT_MASK,
      ORDERING,
      DISPLAY_LENGTH,
      DISPLAY_FORMAT,
      DISPLAY_STATUS,
      BREAK,
      ATTRIBUTE_COUNTER
    from FA_RX_REP_COLUMNS_B
    where REPORT_ID = X_REPORT_ID
    and ATTRIBUTE_SET = X_ATTRIBUTE_SET
    and COLUMN_NAME = X_COLUMN_NAME
    for update of REPORT_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      ATTRIBUTE_NAME,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from FA_RX_REP_COLUMNS_TL
    where REPORT_ID = X_REPORT_ID
    and ATTRIBUTE_SET = X_ATTRIBUTE_SET
    and COLUMN_NAME = X_COLUMN_NAME
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of REPORT_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.CURRENCY_COLUMN = X_CURRENCY_COLUMN)
           OR ((recinfo.CURRENCY_COLUMN is null) AND (X_CURRENCY_COLUMN is null)))
      AND ((recinfo.PRECISION = X_PRECISION)
           OR ((recinfo.PRECISION is null) AND (X_PRECISION is null)))
      AND ((recinfo.BREAK_GROUP_LEVEL = X_BREAK_GROUP_LEVEL)
           OR ((recinfo.BREAK_GROUP_LEVEL is null) AND (X_BREAK_GROUP_LEVEL is null)))
      AND ((recinfo.MINIMUM_ACCOUNTABLE_UNIT = X_MINIMUM_ACCOUNTABLE_UNIT)
           OR ((recinfo.MINIMUM_ACCOUNTABLE_UNIT is null) AND (X_MINIMUM_ACCOUNTABLE_UNIT is null)))
      AND ((recinfo.UNITS = X_UNITS)
           OR ((recinfo.UNITS is null) AND (X_UNITS is null)))
      AND ((recinfo.FORMAT_MASK = X_FORMAT_MASK)
           OR ((recinfo.FORMAT_MASK is null) AND (X_FORMAT_MASK is null)))
      AND ((recinfo.ORDERING = X_ORDERING)
           OR ((recinfo.ORDERING is null) AND (X_ORDERING is null)))
      AND ((recinfo.DISPLAY_LENGTH = X_DISPLAY_LENGTH)
           OR ((recinfo.DISPLAY_LENGTH is null) AND (X_DISPLAY_LENGTH is null)))
      AND ((recinfo.DISPLAY_FORMAT = X_DISPLAY_FORMAT)
           OR ((recinfo.DISPLAY_FORMAT is null) AND (X_DISPLAY_FORMAT is null)))
      AND (recinfo.DISPLAY_STATUS = X_DISPLAY_STATUS)
      AND ((recinfo.BREAK = X_BREAK)
           OR ((recinfo.BREAK is null) AND (X_BREAK is null)))
      AND ((recinfo.ATTRIBUTE_COUNTER = X_ATTRIBUTE_COUNTER)
           OR ((recinfo.ATTRIBUTE_COUNTER is null) AND (X_ATTRIBUTE_COUNTER is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.ATTRIBUTE_NAME = X_ATTRIBUTE_NAME)
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
  X_REPORT_ID in NUMBER,
  X_ATTRIBUTE_SET in VARCHAR2,
  X_COLUMN_NAME in VARCHAR2,
  X_CURRENCY_COLUMN in VARCHAR2,
  X_PRECISION in NUMBER,
  X_BREAK_GROUP_LEVEL in NUMBER,
  X_MINIMUM_ACCOUNTABLE_UNIT in NUMBER,
  X_UNITS in NUMBER,
  X_FORMAT_MASK in VARCHAR2,
  X_ORDERING in VARCHAR2,
  X_DISPLAY_LENGTH in NUMBER,
  X_DISPLAY_FORMAT in VARCHAR2,
  X_DISPLAY_STATUS in VARCHAR2,
  X_BREAK in VARCHAR2,
  X_ATTRIBUTE_COUNTER in NUMBER,
  X_ATTRIBUTE_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update FA_RX_REP_COLUMNS_B set
    CURRENCY_COLUMN = X_CURRENCY_COLUMN,
    PRECISION = X_PRECISION,
    BREAK_GROUP_LEVEL = X_BREAK_GROUP_LEVEL,
    MINIMUM_ACCOUNTABLE_UNIT = X_MINIMUM_ACCOUNTABLE_UNIT,
    UNITS = X_UNITS,
    FORMAT_MASK = X_FORMAT_MASK,
    ORDERING = X_ORDERING,
    DISPLAY_LENGTH = X_DISPLAY_LENGTH,
    DISPLAY_FORMAT = X_DISPLAY_FORMAT,
    DISPLAY_STATUS = X_DISPLAY_STATUS,
    BREAK = X_BREAK,
    ATTRIBUTE_COUNTER = X_ATTRIBUTE_COUNTER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where REPORT_ID = X_REPORT_ID
  and ATTRIBUTE_SET = X_ATTRIBUTE_SET
  and COLUMN_NAME = X_COLUMN_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update FA_RX_REP_COLUMNS_TL set
    ATTRIBUTE_NAME = X_ATTRIBUTE_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where REPORT_ID = X_REPORT_ID
  and ATTRIBUTE_SET = X_ATTRIBUTE_SET
  and COLUMN_NAME = X_COLUMN_NAME
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_REPORT_ID in NUMBER,
  X_ATTRIBUTE_SET in VARCHAR2,
  X_COLUMN_NAME in VARCHAR2
) is
begin
  delete from FA_RX_REP_COLUMNS_TL
  where REPORT_ID = X_REPORT_ID
  and ATTRIBUTE_SET = X_ATTRIBUTE_SET
  and COLUMN_NAME = X_COLUMN_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from FA_RX_REP_COLUMNS_B
  where REPORT_ID = X_REPORT_ID
  and ATTRIBUTE_SET = X_ATTRIBUTE_SET
  and COLUMN_NAME = X_COLUMN_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from FA_RX_REP_COLUMNS_TL T
  where not exists
    (select NULL
    from FA_RX_REP_COLUMNS_B B
    where B.REPORT_ID = T.REPORT_ID
    and B.ATTRIBUTE_SET = T.ATTRIBUTE_SET
    and B.COLUMN_NAME = T.COLUMN_NAME
    );

  update FA_RX_REP_COLUMNS_TL T set (
      ATTRIBUTE_NAME
    ) = (select
      B.ATTRIBUTE_NAME
    from FA_RX_REP_COLUMNS_TL B
    where B.REPORT_ID = T.REPORT_ID
    and B.ATTRIBUTE_SET = T.ATTRIBUTE_SET
    and B.COLUMN_NAME = T.COLUMN_NAME
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.REPORT_ID,
      T.ATTRIBUTE_SET,
      T.COLUMN_NAME,
      T.LANGUAGE
  ) in (select
      SUBT.REPORT_ID,
      SUBT.ATTRIBUTE_SET,
      SUBT.COLUMN_NAME,
      SUBT.LANGUAGE
    from FA_RX_REP_COLUMNS_TL SUBB, FA_RX_REP_COLUMNS_TL SUBT
    where SUBB.REPORT_ID = SUBT.REPORT_ID
    and SUBB.ATTRIBUTE_SET = SUBT.ATTRIBUTE_SET
    and SUBB.COLUMN_NAME = SUBT.COLUMN_NAME
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.ATTRIBUTE_NAME <> SUBT.ATTRIBUTE_NAME
  ));

  insert into FA_RX_REP_COLUMNS_TL (
    REPORT_ID,
    ATTRIBUTE_SET,
    COLUMN_NAME,
    ATTRIBUTE_NAME,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LAST_UPDATED_BY,
    CREATED_BY,
    CREATION_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.REPORT_ID,
    B.ATTRIBUTE_SET,
    B.COLUMN_NAME,
    B.ATTRIBUTE_NAME,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.LAST_UPDATED_BY,
    B.CREATED_BY,
    B.CREATION_DATE,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from FA_RX_REP_COLUMNS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from FA_RX_REP_COLUMNS_TL T
    where T.REPORT_ID = B.REPORT_ID
    and T.ATTRIBUTE_SET = B.ATTRIBUTE_SET
    and T.COLUMN_NAME = B.COLUMN_NAME
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure LOAD_ROW(
  X_REPORT_ID in NUMBER,
  X_ATTRIBUTE_SET in VARCHAR2,
  X_COLUMN_NAME in VARCHAR2,
  X_CURRENCY_COLUMN in VARCHAR2,
  X_PRECISION in NUMBER,
  X_BREAK_GROUP_LEVEL in NUMBER,
  X_MINIMUM_ACCOUNTABLE_UNIT in NUMBER,
  X_UNITS in NUMBER,
  X_FORMAT_MASK in VARCHAR2,
  X_ORDERING in VARCHAR2,
  X_DISPLAY_LENGTH in NUMBER,
  X_DISPLAY_FORMAT in VARCHAR2,
  X_DISPLAY_STATUS in VARCHAR2,
  X_BREAK in VARCHAR2,
  X_ATTRIBUTE_COUNTER in NUMBER,
  X_ATTRIBUTE_NAME in VARCHAR2,
  X_OWNER in VARCHAR2) is
begin
	LOAD_ROW(
	  X_REPORT_ID => X_REPORT_ID ,
	  X_ATTRIBUTE_SET => X_ATTRIBUTE_SET ,
	  X_COLUMN_NAME  => X_COLUMN_NAME ,
	  X_CURRENCY_COLUMN  => X_CURRENCY_COLUMN ,
	  X_PRECISION  => X_PRECISION ,
	  X_BREAK_GROUP_LEVEL  => X_BREAK_GROUP_LEVEL ,
	  X_MINIMUM_ACCOUNTABLE_UNIT  => X_MINIMUM_ACCOUNTABLE_UNIT  ,
	  X_UNITS =>  X_UNITS ,
	  X_FORMAT_MASK  => X_FORMAT_MASK ,
	  X_ORDERING  => X_ORDERING ,
	  X_DISPLAY_LENGTH  => X_DISPLAY_LENGTH ,
	  X_DISPLAY_FORMAT  => X_DISPLAY_FORMAT ,
	  X_DISPLAY_STATUS  => X_DISPLAY_STATUS ,
	  X_BREAK  => X_BREAK ,
	  X_ATTRIBUTE_COUNTER  => X_ATTRIBUTE_COUNTER ,
	  X_ATTRIBUTE_NAME  => X_ATTRIBUTE_NAME ,
	  X_OWNER  => X_OWNER ,
	  X_LAST_UPDATE_DATE  => null ,
	  X_CUSTOM_MODE  => null
	);
end LOAD_ROW;

procedure LOAD_ROW(
  X_REPORT_ID in NUMBER,
  X_ATTRIBUTE_SET in VARCHAR2,
  X_COLUMN_NAME in VARCHAR2,
  X_CURRENCY_COLUMN in VARCHAR2,
  X_PRECISION in NUMBER,
  X_BREAK_GROUP_LEVEL in NUMBER,
  X_MINIMUM_ACCOUNTABLE_UNIT in NUMBER,
  X_UNITS in NUMBER,
  X_FORMAT_MASK in VARCHAR2,
  X_ORDERING in VARCHAR2,
  X_DISPLAY_LENGTH in NUMBER,
  X_DISPLAY_FORMAT in VARCHAR2,
  X_DISPLAY_STATUS in VARCHAR2,
  X_BREAK in VARCHAR2,
  X_ATTRIBUTE_COUNTER in NUMBER,
  X_ATTRIBUTE_NAME in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_LAST_UPDATE_DATE in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2
  ) is
	--* Bug#5102292, rravunny
	--* Begin
	--*
			f_luby number;  -- entity owner in file
			f_ludate date;  -- entity update date in file
			db_luby number; -- entity owner in db
			db_ludate date; -- entity update date in db
			db_luby_tl number; -- entity owner in db for _tl
			db_ludate_tl date; -- entity update date in db for _tl

	--* End
	--*
begin
  declare

    row_id varchar2(64);
    user_id number := 0;
  begin

  	--* Bug#5102292, rravunny
	--* Begin
	--*
		f_luby := fnd_load_util.owner_id(X_Owner);

		-- Translate char last_update_date to date
		f_ludate := nvl(to_date(X_Last_Update_Date, 'YYYY/MM/DD HH24:MI:SS'), sysdate);

		select	LAST_UPDATED_BY, LAST_UPDATE_DATE
		into	db_luby, db_ludate
		from	fa_rx_rep_columns_b
		where	report_id = X_Report_Id
		and     ATTRIBUTE_SET = X_ATTRIBUTE_SET
		and     column_name = X_Column_Name;

		Begin
			select	LAST_UPDATED_BY, LAST_UPDATE_DATE
			into	db_luby_tl, db_ludate_tl
			from	fa_rx_rep_columns_tl
			where	report_id = X_Report_Id
			and     ATTRIBUTE_SET = X_ATTRIBUTE_SET
			and     column_name = X_Column_Name
			and     language = userenv('LANG');
		Exception
		When Others Then
			db_luby_tl := db_luby;
			db_ludate_tl := db_ludate;
		End;

	--* End
	--*

     If (
        fnd_load_util.upload_test(f_luby, f_ludate, db_luby, db_ludate, X_CUSTOM_MODE)
        and
	fnd_load_util.upload_test(f_luby, f_ludate, db_luby_tl, db_ludate_tl, X_CUSTOM_MODE)
	)
     Then
      UPDATE_ROW(
	X_REPORT_ID =>			X_REPORT_ID,
	X_ATTRIBUTE_SET =>		X_ATTRIBUTE_SET,
	X_COLUMN_NAME =>		X_COLUMN_NAME,
	X_CURRENCY_COLUMN =>		X_CURRENCY_COLUMN,
	X_PRECISION =>			X_PRECISION,
	X_BREAK_GROUP_LEVEL =>		X_BREAK_GROUP_LEVEL,
	X_MINIMUM_ACCOUNTABLE_UNIT =>	X_MINIMUM_ACCOUNTABLE_UNIT,
	X_UNITS =>			X_UNITS,
	X_FORMAT_MASK =>		X_FORMAT_MASK,
	X_ORDERING =>			X_ORDERING,
	X_DISPLAY_LENGTH =>		X_DISPLAY_LENGTH,
	X_DISPLAY_FORMAT =>		X_DISPLAY_FORMAT,
	X_DISPLAY_STATUS =>		X_DISPLAY_STATUS,
	X_BREAK =>			X_BREAK,
	X_ATTRIBUTE_COUNTER =>		X_ATTRIBUTE_COUNTER,
	X_ATTRIBUTE_NAME =>		X_ATTRIBUTE_NAME,
	X_LAST_UPDATE_DATE =>		f_ludate,
	X_LAST_UPDATED_BY =>		f_luby,
	X_LAST_UPDATE_LOGIN =>		0);
     End If;
  exception
  when NO_DATA_FOUND then
      INSERT_ROW(
	X_ROWID =>			row_id,
	X_REPORT_ID =>			X_REPORT_ID,
	X_ATTRIBUTE_SET =>		X_ATTRIBUTE_SET,
	X_COLUMN_NAME =>		X_COLUMN_NAME,
	X_CURRENCY_COLUMN =>		X_CURRENCY_COLUMN,
	X_PRECISION =>			X_PRECISION,
	X_BREAK_GROUP_LEVEL =>		X_BREAK_GROUP_LEVEL,
	X_MINIMUM_ACCOUNTABLE_UNIT =>	X_MINIMUM_ACCOUNTABLE_UNIT,
	X_UNITS =>			X_UNITS,
	X_FORMAT_MASK =>		X_FORMAT_MASK,
	X_ORDERING =>			X_ORDERING,
	X_DISPLAY_LENGTH =>		X_DISPLAY_LENGTH,
	X_DISPLAY_FORMAT =>		X_DISPLAY_FORMAT,
	X_DISPLAY_STATUS =>		X_DISPLAY_STATUS,
	X_BREAK =>			X_BREAK,
	X_ATTRIBUTE_COUNTER =>		X_ATTRIBUTE_COUNTER,
	X_ATTRIBUTE_NAME =>		X_ATTRIBUTE_NAME,
	X_CREATION_DATE =>		f_ludate,
	X_CREATED_BY =>			f_luby,
	X_LAST_UPDATE_DATE =>		f_ludate,
	X_LAST_UPDATED_BY =>		f_luby,
	X_LAST_UPDATE_LOGIN =>		0);
  end;
end LOAD_ROW;

procedure TRANSLATE_ROW(
  X_REPORT_ID in NUMBER,
  X_ATTRIBUTE_SET in VARCHAR2,
  X_COLUMN_NAME in VARCHAR2,
  X_ATTRIBUTE_NAME in VARCHAR2,
  X_OWNER in VARCHAR2
  )
 Is
 Begin
   TRANSLATE_ROW(
	  X_REPORT_ID => X_REPORT_ID,
	  X_ATTRIBUTE_SET =>  X_ATTRIBUTE_SET,
	  X_COLUMN_NAME  => X_COLUMN_NAME,
	  X_ATTRIBUTE_NAME  => X_ATTRIBUTE_NAME,
	  X_OWNER  => X_OWNER,
	  X_LAST_UPDATE_DATE  => null,
	  X_CUSTOM_MODE =>  null);
 End TRANSLATE_ROW;

procedure TRANSLATE_ROW(
  X_REPORT_ID in NUMBER,
  X_ATTRIBUTE_SET in VARCHAR2,
  X_COLUMN_NAME in VARCHAR2,
  X_ATTRIBUTE_NAME in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_LAST_UPDATE_DATE in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2
  ) is
  f_luby number;  -- entity owner in file
  f_ludate date;  -- entity update date in file
begin
--* Bug#5102292, rravunny
--* Begin
--*
	f_luby := fnd_load_util.owner_id(X_Owner);

	-- Translate char last_update_date to date
	f_ludate := nvl(to_date(X_Last_Update_Date, 'YYYY/MM/DD HH24:MI:SS'), sysdate);

--* End
--*
  update fa_rx_rep_columns_tl set
	attribute_name = X_ATTRIBUTE_NAME,
	LAST_UPDATE_DATE = f_ludate,
	LAST_UPDATED_BY = f_luby,
	LAST_UPDATE_LOGIN = 0,
	SOURCE_LANG = userenv('LANG')
  where
	report_id = X_REPORT_ID
  and	attribute_set = X_ATTRIBUTE_SET
  and	column_name = X_COLUMN_NAME
  and	userenv('LANG') in (language, source_lang);
end TRANSLATE_ROW;

procedure RENUMBER_COLUMNS(
  X_REPORT_ID in NUMBER,
  X_ATTRIBUTE_SET in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_MAX_ATTRIBUTE_COUNTER out nocopy NUMBER,
  X_MAX_BREAK_GROUP_LEVEL out nocopy NUMBER) is

curr_attribute_counter NUMBER := 0;
curr_break_level NUMBER := 0;
prev_break VARCHAR2(1) := 'Y';
prev_break_level NUMBER := NULL;

CURSOR ccol IS SELECT
	report_id,
	attribute_set,
	column_name,
	Nvl(break, 'N') break,
	break_group_level,
	attribute_counter,
	last_update_date,
	last_updated_by,
	last_update_login
FROM fa_rx_rep_columns_b
WHERE
	report_id = X_REPORT_ID AND
	attribute_set = X_ATTRIBUTE_SET AND
	display_status = 'YES'
	ORDER BY Nvl(break, 'N') DESC, break_group_level, attribute_counter
	FOR UPDATE;
begin
      FOR crow IN ccol LOOP
	 curr_attribute_counter := curr_attribute_counter + 1;
	 IF prev_break = 'Y' AND crow.break = 'N' THEN
	    curr_break_level := curr_break_level + 1;
	  ELSIF crow.break = 'Y' AND
	    (prev_break_level IS NULL OR
	     crow.break_group_level IS NULL OR
	     prev_break_level <> crow.break_group_level) THEN
	    curr_break_level := curr_break_level + 1;
	 END IF;

	 UPDATE fa_rx_rep_columns_b SET
	   break = crow.break,
	   break_group_level = curr_break_level,
	   attribute_counter = curr_attribute_counter,
	   last_update_date = X_LAST_UPDATE_DATE,
	   last_updated_by = X_LAST_UPDATED_BY,
	   last_update_login = X_LAST_UPDATE_LOGIN
	   WHERE CURRENT OF ccol;

	 prev_break := crow.break;
	 prev_break_level := crow.break_group_level;
      END LOOP;

      X_MAX_ATTRIBUTE_COUNTER := curr_attribute_counter;
      X_MAX_BREAK_GROUP_LEVEL := curr_break_level;
end RENUMBER_COLUMNS;


end FA_RX_REP_COLUMNS_PKG;

/
