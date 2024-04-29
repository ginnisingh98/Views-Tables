--------------------------------------------------------
--  DDL for Package Body FND_MENUS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_MENUS_PKG" as
/* $Header: AFMNMNUB.pls 120.1.12010000.2 2008/11/07 23:24:17 jvalenti ship $ */

procedure INSERT_ROW (
	X_ROWID in out nocopy VARCHAR2,
	X_MENU_ID in NUMBER,
	X_MENU_NAME in VARCHAR2,
	X_USER_MENU_NAME in VARCHAR2,
	X_MENU_TYPE in VARCHAR2,
	X_DESCRIPTION in VARCHAR2,
	X_CREATION_DATE in DATE,
	X_CREATED_BY in NUMBER,
	X_LAST_UPDATE_DATE in DATE,
	X_LAST_UPDATED_BY in NUMBER,
	X_LAST_UPDATE_LOGIN in NUMBER
)
is
	cursor C is select ROWID from FND_MENUS
		where MENU_ID = X_MENU_ID;

begin

	insert into FND_MENUS (
		MENU_ID,
		MENU_NAME,
		TYPE,
		CREATION_DATE,
		CREATED_BY,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		LAST_UPDATE_LOGIN
	)
	values (
		X_MENU_ID,
		X_MENU_NAME,
		X_MENU_TYPE,
		X_CREATION_DATE,
		X_CREATED_BY,
		X_LAST_UPDATE_DATE,
		X_LAST_UPDATED_BY,
		X_LAST_UPDATE_LOGIN
	);

	-- Added for Function Security Cache Invalidation Project
	fnd_function_security_cache.insert_menu(X_MENU_ID);

	insert into FND_MENUS_TL (
		MENU_ID,
		USER_MENU_NAME,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		LAST_UPDATE_LOGIN,
		CREATION_DATE,
		CREATED_BY,
		DESCRIPTION,
		LANGUAGE,
		SOURCE_LANG
	) select	X_MENU_ID,
				X_USER_MENU_NAME,
				X_LAST_UPDATE_DATE,
				X_LAST_UPDATED_BY,
				X_LAST_UPDATE_LOGIN,
				X_CREATION_DATE,
				X_CREATED_BY,
				X_DESCRIPTION,
				L.LANGUAGE_CODE,
				userenv('LANG')
	from		FND_LANGUAGES L
	where		L.INSTALLED_FLAG in ('I', 'B')
	and	not exists (select	NULL
					from	FND_MENUS_TL T
					where	T.MENU_ID = X_MENU_ID
					and		T.LANGUAGE = L.LANGUAGE_CODE);

	open c;
	fetch c into X_ROWID;
	if (c%notfound) then
		close c;
		raise no_data_found;
	end if;
	close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_MENU_ID in NUMBER,
  X_MENU_NAME in VARCHAR2,
  X_USER_MENU_NAME in VARCHAR2,
  X_MENU_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      MENU_NAME, TYPE
    from FND_MENUS
    where MENU_ID = X_MENU_ID
    for update of MENU_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      USER_MENU_NAME,
      DESCRIPTION
    from FND_MENUS_TL
    where MENU_ID = X_MENU_ID
    and LANGUAGE = userenv('LANG')
    for update of MENU_ID nowait;
  tlinfo c1%rowtype;

begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.MENU_NAME = X_MENU_NAME)
      AND ((recinfo.TYPE = X_MENU_TYPE)
           OR ((recinfo.TYPE is null) AND (X_MENU_TYPE is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    close c1;
    return;
  end if;
  close c1;

  if (    (tlinfo.USER_MENU_NAME = X_USER_MENU_NAME)
      AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
           OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
	X_MENU_ID in NUMBER,
	X_MENU_NAME in VARCHAR2,
	X_USER_MENU_NAME in VARCHAR2,
	X_MENU_TYPE in VARCHAR2,
	X_DESCRIPTION in VARCHAR2,
	X_LAST_UPDATE_DATE in DATE,
	X_LAST_UPDATED_BY in NUMBER,
	X_LAST_UPDATE_LOGIN in NUMBER
)
is

begin
	update	FND_MENUS
	set		MENU_NAME = X_MENU_NAME,
				TYPE = X_MENU_TYPE,
				LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
				LAST_UPDATED_BY = X_LAST_UPDATED_BY,
				LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
	where		MENU_ID = X_MENU_ID;

	if (sql%notfound) then
		raise no_data_found;
	else
		-- This means that a menu was updated.
		-- Added for Function Security Cache Invalidation Project
		fnd_function_security_cache.update_menu(X_MENU_ID);
	end if;

	update	FND_MENUS_TL
	set		USER_MENU_NAME = X_USER_MENU_NAME,
			DESCRIPTION = X_DESCRIPTION,
			LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
			LAST_UPDATED_BY = X_LAST_UPDATED_BY,
			LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
			SOURCE_LANG = userenv('LANG')
	where	MENU_ID = X_MENU_ID
	and		userenv('LANG') in (LANGUAGE, SOURCE_LANG);

	if (sql%notfound) then
		raise no_data_found;
	end if;
end UPDATE_ROW;

/* Overloaded version below */
procedure LOAD_ROW (
  X_MENU_NAME in VARCHAR2,
  X_MENU_TYPE in VARCHAR2,
  X_USER_MENU_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2
) is
begin
  fnd_menus_pkg.LOAD_ROW (
    X_MENU_NAME => X_MENU_NAME,
    X_MENU_TYPE => X_MENU_TYPE,
    X_USER_MENU_NAME => X_USER_MENU_NAME,
    X_DESCRIPTION => X_DESCRIPTION,
    X_OWNER => X_OWNER,
    X_CUSTOM_MODE => X_CUSTOM_MODE,
    X_LAST_UPDATE_DATE => null
  );
end LOAD_ROW;

/* Overloaded version above */
procedure LOAD_ROW (
  X_MENU_NAME in VARCHAR2,
  X_MENU_TYPE in VARCHAR2,
  X_USER_MENU_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2,
  X_LAST_UPDATE_DATE in VARCHAR2
) is
 man_id  number;
 row_id  varchar2(64);
 f_luby    number;  -- entity owner in file
 f_ludate  date;    -- entity update date in file
 db_luby   number;  -- entity owner in db
 db_ludate date;    -- entity update date in db
begin
  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

  select menu_id, last_updated_by, last_update_date
  into man_id, db_luby, db_ludate
  from fnd_menus
  where menu_name = X_MENU_NAME;

  if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                db_ludate, X_CUSTOM_MODE)) then
    fnd_menus_pkg.UPDATE_ROW (
       X_MENU_ID                => man_id,
       X_MENU_NAME              => X_MENU_NAME,
       X_USER_MENU_NAME         => X_USER_MENU_NAME,
       X_MENU_TYPE              => X_MENU_TYPE,
       X_DESCRIPTION            => X_DESCRIPTION,
       X_LAST_UPDATE_DATE       => f_ludate,
       X_LAST_UPDATED_BY        => f_luby,
       X_LAST_UPDATE_LOGIN      => 0 );
  end if;
exception
  when NO_DATA_FOUND then

    select fnd_menus_s.nextval into man_id from dual;

    fnd_menus_pkg.INSERT_ROW(
       X_ROWID                  => row_id,
       X_MENU_ID                => man_id,
       X_MENU_NAME              => X_MENU_NAME,
       X_USER_MENU_NAME         => X_USER_MENU_NAME,
       X_MENU_TYPE              => X_MENU_TYPE,
       X_DESCRIPTION            => X_DESCRIPTION,
       X_CREATION_DATE          => f_ludate,
       X_CREATED_BY             => f_luby,
       X_LAST_UPDATE_DATE       => f_ludate,
       X_LAST_UPDATED_BY        => f_luby,
       X_LAST_UPDATE_LOGIN      => 0 );
end LOAD_ROW;

procedure DELETE_ROW (
	X_MENU_ID in NUMBER
)
is

begin

	delete	from FND_MENUS
	where		MENU_ID = X_MENU_ID;

	if (sql%notfound) then
		raise no_data_found;
	else
		-- This means that a menu was deleted.
		-- Added for Function Security Cache Invalidation Project
		fnd_function_security_cache.delete_menu(X_MENU_ID);
	end if;

	delete	from FND_MENUS_TL
	where		MENU_ID = X_MENU_ID;

	if (sql%notfound) then
		raise no_data_found;
	end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
/* Mar/19/03 requested by Ric Ginsberg */
/* The following delete and update statements are commented out */
/* as a quick workaround to fix the time-consuming table handler issue */
/* Eventually we'll need to turn them into a separate fix_language procedure */
/*

  delete from FND_MENUS_TL T
  where not exists
    (select NULL
    from FND_MENUS B
    where B.MENU_ID = T.MENU_ID
    );

  update FND_MENUS_TL T set (
      USER_MENU_NAME,
      DESCRIPTION
    ) = (select
      B.USER_MENU_NAME,
      B.DESCRIPTION
    from FND_MENUS_TL B
    where B.MENU_ID = T.MENU_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.MENU_ID,
      T.LANGUAGE
  ) in (select
      SUBT.MENU_ID,
      SUBT.LANGUAGE
    from FND_MENUS_TL SUBB, FND_MENUS_TL SUBT
    where SUBB.MENU_ID = SUBT.MENU_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.USER_MENU_NAME <> SUBT.USER_MENU_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));
*/

  insert into FND_MENUS_TL (
    MENU_ID,
    USER_MENU_NAME,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATION_DATE,
    CREATED_BY,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.MENU_ID,
    B.USER_MENU_NAME,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from FND_MENUS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from FND_MENUS_TL T
    where T.MENU_ID = B.MENU_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

/* Overloaded version below */
procedure TRANSLATE_ROW (
  X_MENU_ID in NUMBER,
  X_USER_MENU_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2
) is
begin
  fnd_menus_pkg.TRANSLATE_ROW (
    X_MENU_ID => X_MENU_ID,
    X_USER_MENU_NAME => X_USER_MENU_NAME,
    X_DESCRIPTION => X_DESCRIPTION,
    X_OWNER => X_OWNER,
    X_CUSTOM_MODE => X_CUSTOM_MODE,
    X_LAST_UPDATE_DATE => null
  );
end TRANSLATE_ROW;

/* Overloaded version above */
procedure TRANSLATE_ROW (
  X_MENU_ID in NUMBER,
  X_USER_MENU_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2,
  X_LAST_UPDATE_DATE in VARCHAR2
) is
 f_luby    number;  -- entity owner in file
 f_ludate  date;    -- entity update date in file
 db_luby   number;  -- entity owner in db
 db_ludate date;    -- entity update date in db
begin
  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

  select LAST_UPDATED_BY, LAST_UPDATE_DATE
  into db_luby, db_ludate
  from FND_MENUS_TL
  where MENU_ID = X_MENU_ID
  and userenv('LANG') = LANGUAGE;

  if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                db_ludate, X_CUSTOM_MODE)) then
    update FND_MENUS_TL set
      USER_MENU_NAME = X_USER_MENU_NAME,
      DESCRIPTION = X_DESCRIPTION,
      LAST_UPDATE_DATE = f_ludate,
      LAST_UPDATED_BY = f_luby,
      LAST_UPDATE_LOGIN = 0,
      SOURCE_LANG = userenv('LANG')
    where MENU_ID = X_MENU_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG);
  end if;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end TRANSLATE_ROW;

procedure SET_NEW_MENU is
begin
  FND_MENUS_PKG.currentryseq := 0;
end SET_NEW_MENU;

function NEXT_ENTRY_SEQUENCE return number is
begin
	--Bug6525216 Making the sequence in increments of 5.

  FND_MENUS_PKG.currentryseq := FND_MENUS_PKG.currentryseq + 5;
  return(FND_MENUS_PKG.currentryseq);
end NEXT_ENTRY_SEQUENCE;

function VALIDATE_MENU_TYPE(X_MENU_TYPE in VARCHAR2) return boolean is
  buffer varchar2(80);
begin
  begin
    if (X_MENU_TYPE is null) then
      return(true);
    end if;

    select meaning into buffer
    from fnd_lookups
    where LOOKUP_TYPE = 'MENU_TYPE'
    and lookup_code = upper(X_MENU_TYPE);
  exception
    when no_data_found then
      return(false);
  end;

  return(true);

end VALIDATE_MENU_TYPE;

end FND_MENUS_PKG;

/
