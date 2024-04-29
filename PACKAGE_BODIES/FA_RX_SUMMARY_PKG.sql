--------------------------------------------------------
--  DDL for Package Body FA_RX_SUMMARY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_RX_SUMMARY_PKG" as
/* $Header: faxrxsmb.pls 120.5.12010000.2 2009/07/19 13:15:51 glchen ship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_REPORT_ID in NUMBER,
  X_ATTRIBUTE_SET in VARCHAR2,
  X_COLUMN_NAME in VARCHAR2,
  X_SUMMARY_FUNCTION in VARCHAR2,
  X_PRINT_LEVEL in NUMBER,
  X_RESET_LEVEL in NUMBER,
  X_COMPUTE_LEVEL in NUMBER,
  X_DISPLAY_STATUS in VARCHAR2,
  X_SUMMARY_PROMPT in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from FA_RX_SUMMARY_TL
    where REPORT_ID = X_REPORT_ID
    and ATTRIBUTE_SET = X_ATTRIBUTE_SET
    and COLUMN_NAME = X_COLUMN_NAME
    and SUMMARY_FUNCTION = X_SUMMARY_FUNCTION
    and PRINT_LEVEL = X_PRINT_LEVEL
    and RESET_LEVEL = X_RESET_LEVEL
    and COMPUTE_LEVEL = X_COMPUTE_LEVEL
    and LANGUAGE = userenv('LANG')
    ;
begin
  insert into FA_RX_SUMMARY_TL (
    REPORT_ID,
    ATTRIBUTE_SET,
    COLUMN_NAME,
    PRINT_LEVEL,
    RESET_LEVEL,
    COMPUTE_LEVEL,
    SUMMARY_FUNCTION,
    SUMMARY_PROMPT,
    DISPLAY_STATUS,
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
    X_PRINT_LEVEL,
    X_RESET_LEVEL,
    X_COMPUTE_LEVEL,
    X_SUMMARY_FUNCTION,
    X_SUMMARY_PROMPT,
    X_DISPLAY_STATUS,
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
    from FA_RX_SUMMARY_TL T
    where T.REPORT_ID = X_REPORT_ID
    and T.ATTRIBUTE_SET = X_ATTRIBUTE_SET
    and T.COLUMN_NAME = X_COLUMN_NAME
    and T.SUMMARY_FUNCTION = X_SUMMARY_FUNCTION
    and T.PRINT_LEVEL = X_PRINT_LEVEL
    and T.RESET_LEVEL = X_RESET_LEVEL
    and T.COMPUTE_LEVEL = X_COMPUTE_LEVEL
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
  X_SUMMARY_FUNCTION in VARCHAR2,
  X_PRINT_LEVEL in NUMBER,
  X_RESET_LEVEL in NUMBER,
  X_COMPUTE_LEVEL in NUMBER,
  X_DISPLAY_STATUS in VARCHAR2,
  X_SUMMARY_PROMPT in VARCHAR2
) is
  cursor c1 is select
      DISPLAY_STATUS,
      SUMMARY_PROMPT,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from FA_RX_SUMMARY_TL
    where REPORT_ID = X_REPORT_ID
    and ATTRIBUTE_SET = X_ATTRIBUTE_SET
    and COLUMN_NAME = X_COLUMN_NAME
    and SUMMARY_FUNCTION = X_SUMMARY_FUNCTION
    and PRINT_LEVEL = X_PRINT_LEVEL
    and RESET_LEVEL = X_RESET_LEVEL
    and COMPUTE_LEVEL = X_COMPUTE_LEVEL
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of REPORT_ID nowait;
begin
  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.SUMMARY_PROMPT = X_SUMMARY_PROMPT)
               OR ((tlinfo.SUMMARY_PROMPT is null) AND (X_SUMMARY_PROMPT is null)))
          AND ((tlinfo.DISPLAY_STATUS = X_DISPLAY_STATUS)
               OR ((tlinfo.DISPLAY_STATUS is null) AND (X_DISPLAY_STATUS is null)))
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
  X_SUMMARY_FUNCTION in VARCHAR2,
  X_PRINT_LEVEL in NUMBER,
  X_RESET_LEVEL in NUMBER,
  X_COMPUTE_LEVEL in NUMBER,
  X_DISPLAY_STATUS in VARCHAR2,
  X_SUMMARY_PROMPT in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update FA_RX_SUMMARY_TL set
    DISPLAY_STATUS = X_DISPLAY_STATUS,
    SUMMARY_PROMPT = X_SUMMARY_PROMPT,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where REPORT_ID = X_REPORT_ID
  and ATTRIBUTE_SET = X_ATTRIBUTE_SET
  and COLUMN_NAME = X_COLUMN_NAME
  and SUMMARY_FUNCTION = X_SUMMARY_FUNCTION
  and PRINT_LEVEL = X_PRINT_LEVEL
  and RESET_LEVEL = X_RESET_LEVEL
  and COMPUTE_LEVEL = X_COMPUTE_LEVEL
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_REPORT_ID in NUMBER,
  X_ATTRIBUTE_SET in VARCHAR2,
  X_COLUMN_NAME in VARCHAR2,
  X_SUMMARY_FUNCTION in VARCHAR2,
  X_PRINT_LEVEL in NUMBER,
  X_RESET_LEVEL in NUMBER,
  X_COMPUTE_LEVEL in NUMBER
) is
begin
  delete from FA_RX_SUMMARY_TL
  where REPORT_ID = X_REPORT_ID
  and ATTRIBUTE_SET = X_ATTRIBUTE_SET
  and COLUMN_NAME = X_COLUMN_NAME
  and SUMMARY_FUNCTION = X_SUMMARY_FUNCTION
  and PRINT_LEVEL = X_PRINT_LEVEL
  and RESET_LEVEL = X_RESET_LEVEL
  and COMPUTE_LEVEL = X_COMPUTE_LEVEL;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  update FA_RX_SUMMARY_TL T set (
      SUMMARY_PROMPT
    ) = (select
      B.SUMMARY_PROMPT
    from FA_RX_SUMMARY_TL B
    where B.REPORT_ID = T.REPORT_ID
    and B.ATTRIBUTE_SET = T.ATTRIBUTE_SET
    and B.COLUMN_NAME = T.COLUMN_NAME
    and B.SUMMARY_FUNCTION = T.SUMMARY_FUNCTION
    and B.PRINT_LEVEL = T.PRINT_LEVEL
    and B.RESET_LEVEL = T.RESET_LEVEL
    and B.COMPUTE_LEVEL = T.COMPUTE_LEVEL
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.REPORT_ID,
      T.ATTRIBUTE_SET,
      T.COLUMN_NAME,
      T.SUMMARY_FUNCTION,
      T.PRINT_LEVEL,
      T.RESET_LEVEL,
      T.COMPUTE_LEVEL,
      T.LANGUAGE
  ) in (select
      SUBT.REPORT_ID,
      SUBT.ATTRIBUTE_SET,
      SUBT.COLUMN_NAME,
      SUBT.SUMMARY_FUNCTION,
      SUBT.PRINT_LEVEL,
      SUBT.RESET_LEVEL,
      SUBT.COMPUTE_LEVEL,
      SUBT.LANGUAGE
    from FA_RX_SUMMARY_TL SUBB, FA_RX_SUMMARY_TL SUBT
    where SUBB.REPORT_ID = SUBT.REPORT_ID
    and SUBB.ATTRIBUTE_SET = SUBT.ATTRIBUTE_SET
    and SUBB.COLUMN_NAME = SUBT.COLUMN_NAME
    and SUBB.SUMMARY_FUNCTION = SUBT.SUMMARY_FUNCTION
    and SUBB.PRINT_LEVEL = SUBT.PRINT_LEVEL
    and SUBB.RESET_LEVEL = SUBT.RESET_LEVEL
    and SUBB.COMPUTE_LEVEL = SUBT.COMPUTE_LEVEL
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.SUMMARY_PROMPT <> SUBT.SUMMARY_PROMPT
      or (SUBB.SUMMARY_PROMPT is null and SUBT.SUMMARY_PROMPT is not null)
      or (SUBB.SUMMARY_PROMPT is not null and SUBT.SUMMARY_PROMPT is null)
  ));

  insert into FA_RX_SUMMARY_TL (
    REPORT_ID,
    ATTRIBUTE_SET,
    COLUMN_NAME,
    PRINT_LEVEL,
    RESET_LEVEL,
    COMPUTE_LEVEL,
    SUMMARY_FUNCTION,
    SUMMARY_PROMPT,
    DISPLAY_STATUS,
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
    B.PRINT_LEVEL,
    B.RESET_LEVEL,
    B.COMPUTE_LEVEL,
    B.SUMMARY_FUNCTION,
    B.SUMMARY_PROMPT,
    B.DISPLAY_STATUS,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.LAST_UPDATED_BY,
    B.CREATED_BY,
    B.CREATION_DATE,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from FA_RX_SUMMARY_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from FA_RX_SUMMARY_TL T
    where T.REPORT_ID = B.REPORT_ID
    and T.ATTRIBUTE_SET = B.ATTRIBUTE_SET
    and T.COLUMN_NAME = B.COLUMN_NAME
    and T.SUMMARY_FUNCTION = B.SUMMARY_FUNCTION
    and T.PRINT_LEVEL = B.PRINT_LEVEL
    and T.RESET_LEVEL = B.RESET_LEVEL
    and T.COMPUTE_LEVEL = B.COMPUTE_LEVEL
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure LOAD_ROW (
  X_REPORT_ID in NUMBER,
  X_ATTRIBUTE_SET in VARCHAR2,
  X_COLUMN_NAME in VARCHAR2,
  X_SUMMARY_FUNCTION in VARCHAR2,
  X_PRINT_LEVEL in NUMBER,
  X_RESET_LEVEL in NUMBER,
  X_COMPUTE_LEVEL in NUMBER,
  X_DISPLAY_STATUS in VARCHAR2,
  X_SUMMARY_PROMPT in VARCHAR2,
  X_OWNER in VARCHAR2
  ) is
begin
	LOAD_ROW (
	  X_REPORT_ID => X_REPORT_ID ,
	  X_ATTRIBUTE_SET => X_ATTRIBUTE_SET ,
	  X_COLUMN_NAME  => X_COLUMN_NAME ,
	  X_SUMMARY_FUNCTION =>  X_SUMMARY_FUNCTION ,
	  X_PRINT_LEVEL  => X_PRINT_LEVEL ,
	  X_RESET_LEVEL  => X_RESET_LEVEL ,
	  X_COMPUTE_LEVEL  => X_COMPUTE_LEVEL ,
	  X_DISPLAY_STATUS => X_DISPLAY_STATUS,
	  X_SUMMARY_PROMPT  => X_SUMMARY_PROMPT ,
	  X_OWNER  => X_OWNER ,
	  X_LAST_UPDATE_DATE  => null,
	  X_CUSTOM_MODE  => null
	  );
end LOAD_ROW;

procedure LOAD_ROW (
  X_REPORT_ID in NUMBER,
  X_ATTRIBUTE_SET in VARCHAR2,
  X_COLUMN_NAME in VARCHAR2,
  X_SUMMARY_FUNCTION in VARCHAR2,
  X_PRINT_LEVEL in NUMBER,
  X_RESET_LEVEL in NUMBER,
  X_COMPUTE_LEVEL in NUMBER,
  X_DISPLAY_STATUS in VARCHAR2,
  X_SUMMARY_PROMPT in VARCHAR2,
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
		from	FA_RX_SUMMARY_TL
		where	REPORT_ID = X_REPORT_ID
		and ATTRIBUTE_SET = X_ATTRIBUTE_SET
		and COLUMN_NAME = X_COLUMN_NAME
		and SUMMARY_FUNCTION = X_SUMMARY_FUNCTION
		and PRINT_LEVEL = X_PRINT_LEVEL
		and RESET_LEVEL = X_RESET_LEVEL
		and COMPUTE_LEVEL = X_COMPUTE_LEVEL
		and language = userenv('LANG');

	--* End
	--*
	If (fnd_load_util.upload_test(f_luby, f_ludate, db_luby, db_ludate, X_CUSTOM_MODE)) Then
		UPDATE_ROW(
			X_REPORT_ID =>		X_REPORT_ID,
			X_ATTRIBUTE_SET =>	X_ATTRIBUTE_SET,
			X_COLUMN_NAME =>	X_COLUMN_NAME,
			X_SUMMARY_FUNCTION =>	X_SUMMARY_FUNCTION,
			X_PRINT_LEVEL =>	X_PRINT_LEVEL,
			X_RESET_LEVEL =>	X_RESET_LEVEL,
			X_COMPUTE_LEVEL =>	X_COMPUTE_LEVEL,
			X_DISPLAY_STATUS =>	X_DISPLAY_STATUS,
			X_SUMMARY_PROMPT =>	X_SUMMARY_PROMPT,
			X_LAST_UPDATE_DATE =>	f_ludate,
			X_LAST_UPDATED_BY =>	f_luby,
			X_LAST_UPDATE_LOGIN =>	0);
	End If;
	exception
  when NO_DATA_FOUND then
	INSERT_ROW(
		X_ROWID =>		row_id,
		X_REPORT_ID =>		X_REPORT_ID,
		X_ATTRIBUTE_SET =>	X_ATTRIBUTE_SET,
		X_COLUMN_NAME =>	X_COLUMN_NAME,
		X_SUMMARY_FUNCTION =>	X_SUMMARY_FUNCTION,
		X_PRINT_LEVEL =>	X_PRINT_LEVEL,
		X_RESET_LEVEL =>	X_RESET_LEVEL,
		X_COMPUTE_LEVEL =>	X_COMPUTE_LEVEL,
		X_DISPLAY_STATUS =>	X_DISPLAY_STATUS,
		X_SUMMARY_PROMPT =>	X_SUMMARY_PROMPT,
		X_CREATION_DATE =>	f_ludate,
		X_CREATED_BY =>		f_luby,
		X_LAST_UPDATE_DATE =>	f_ludate,
		X_LAST_UPDATED_BY =>	f_luby,
		X_LAST_UPDATE_LOGIN =>	0);
  end;
end LOAD_ROW;

procedure TRANSLATE_ROW (
  X_REPORT_ID in NUMBER,
  X_ATTRIBUTE_SET in VARCHAR2,
  X_COLUMN_NAME in VARCHAR2,
  X_SUMMARY_FUNCTION in VARCHAR2,
  X_PRINT_LEVEL in NUMBER,
  X_RESET_LEVEL in NUMBER,
  X_COMPUTE_LEVEL in NUMBER,
  X_SUMMARY_PROMPT in VARCHAR2,
  X_OWNER in VARCHAR2
  ) is
begin
	TRANSLATE_ROW (
	  X_REPORT_ID => X_REPORT_ID ,
	  X_ATTRIBUTE_SET => X_ATTRIBUTE_SET ,
	  X_COLUMN_NAME  => X_COLUMN_NAME ,
	  X_SUMMARY_FUNCTION =>  X_SUMMARY_FUNCTION ,
	  X_PRINT_LEVEL  => X_PRINT_LEVEL ,
	  X_RESET_LEVEL  => X_RESET_LEVEL ,
	  X_COMPUTE_LEVEL  => X_COMPUTE_LEVEL ,
	  X_SUMMARY_PROMPT  => X_SUMMARY_PROMPT ,
	  X_OWNER  => X_OWNER ,
	  X_LAST_UPDATE_DATE  => null,
	  X_CUSTOM_MODE  => null
	  ) ;
End TRANSLATE_ROW;

procedure TRANSLATE_ROW (
  X_REPORT_ID in NUMBER,
  X_ATTRIBUTE_SET in VARCHAR2,
  X_COLUMN_NAME in VARCHAR2,
  X_SUMMARY_FUNCTION in VARCHAR2,
  X_PRINT_LEVEL in NUMBER,
  X_RESET_LEVEL in NUMBER,
  X_COMPUTE_LEVEL in NUMBER,
  X_SUMMARY_PROMPT in VARCHAR2,
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

	update FA_RX_SUMMARY_TL
	set	SUMMARY_PROMPT = X_SUMMARY_PROMPT,
		LAST_UPDATE_DATE = f_ludate,
		LAST_UPDATED_BY = f_luby,
		LAST_UPDATE_LOGIN = 0,
		SOURCE_LANG = userenv('LANG')
	where REPORT_ID = X_REPORT_ID
	and ATTRIBUTE_SET = X_ATTRIBUTE_SET
	and COLUMN_NAME = X_COLUMN_NAME
	and SUMMARY_FUNCTION = X_SUMMARY_FUNCTION
	and PRINT_LEVEL = X_PRINT_LEVEL
	and RESET_LEVEL = X_RESET_LEVEL
	and COMPUTE_LEVEL = X_COMPUTE_LEVEL
	and userenv('LANG') in (LANGUAGE, SOURCE_LANG);
end TRANSLATE_ROW;

end FA_RX_SUMMARY_PKG;

/