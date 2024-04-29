--------------------------------------------------------
--  DDL for Package Body FND_WEB_PRODUCT_FAMILY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_WEB_PRODUCT_FAMILY_PKG" AS
  /* $Header: AFSCWPFB.pls 120.0.12010000.2 2019/08/21 10:46:12 ssumaith noship $ */


 procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_FAMILY_SHORT_NAME in VARCHAR2,
  X_IS_ENABLED in VARCHAR2,
  X_FAMILY_DISPLAY_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor c is select ROWID from FND_WEB_PRODUCT_FAMILY
    where FAMILY_SHORT_NAME = X_FAMILY_SHORT_NAME;
begin
  insert into FND_WEB_PRODUCT_FAMILY (
    FAMILY_SHORT_NAME,
    IS_ENABLED,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_FAMILY_SHORT_NAME,
    X_IS_ENABLED,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into FND_WEB_PRODUCT_FAMILY_TL (
    CREATED_BY,
    CREATION_DATE,
    FAMILY_DISPLAY_NAME,
    FAMILY_SHORT_NAME,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_CREATED_BY,
    X_CREATION_DATE,
    X_FAMILY_DISPLAY_NAME,
    X_FAMILY_SHORT_NAME,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from FND_WEB_PRODUCT_FAMILY_TL T
    where T.FAMILY_SHORT_NAME = X_FAMILY_SHORT_NAME
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
  X_FAMILY_SHORT_NAME in VARCHAR2,
  X_IS_ENABLED in VARCHAR2,
  X_FAMILY_DISPLAY_NAME in VARCHAR2
) is
  cursor c is select
      IS_ENABLED
    from FND_WEB_PRODUCT_FAMILY
    where FAMILY_SHORT_NAME = X_FAMILY_SHORT_NAME
    for update of FAMILY_SHORT_NAME nowait;
  recinfo c%rowtype;

  cursor c1 is select
      FAMILY_DISPLAY_NAME,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from FND_WEB_PRODUCT_FAMILY_TL
    where FAMILY_SHORT_NAME = X_FAMILY_SHORT_NAME
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of FAMILY_SHORT_NAME nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.IS_ENABLED = X_IS_ENABLED)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.FAMILY_DISPLAY_NAME = X_FAMILY_DISPLAY_NAME)
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
  X_FAMILY_SHORT_NAME in VARCHAR2,
  X_IS_ENABLED in VARCHAR2,
  X_FAMILY_DISPLAY_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update FND_WEB_PRODUCT_FAMILY set
    IS_ENABLED = X_IS_ENABLED,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where FAMILY_SHORT_NAME = X_FAMILY_SHORT_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update FND_WEB_PRODUCT_FAMILY_TL set
    FAMILY_DISPLAY_NAME = X_FAMILY_DISPLAY_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where FAMILY_SHORT_NAME = X_FAMILY_SHORT_NAME
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_FAMILY_SHORT_NAME in VARCHAR2
) is
begin
  delete from FND_WEB_PRODUCT_FAMILY_TL
  where FAMILY_SHORT_NAME = X_FAMILY_SHORT_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from FND_WEB_PRODUCT_FAMILY
  where FAMILY_SHORT_NAME = X_FAMILY_SHORT_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;


procedure LOAD_ROW (
  X_OWNER in VARCHAR2,
  X_FAMILY_SHORT_NAME in VARCHAR2,
  X_IS_ENABLED in VARCHAR2,
  X_FAMILY_DISPLAY_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2
 ) is
	f_luby    number;  -- entity owner in file
	f_ludate  date;    -- entity update date in file
	db_luby   number;  -- entity owner in db
	db_ludate date;    -- entity update date in db
	row_id varchar2(64);


 begin
-- Translate owner to file_last_updated_by
        f_luby := fnd_load_util.owner_id(X_OWNER);

        -- Translate char last_update_date to date
        f_ludate := nvl(to_date(X_LAST_UPDATE_DATE, 'YYYY/MM/DD'), sysdate);
        begin
          select LAST_UPDATED_BY, LAST_UPDATE_DATE
          into db_luby, db_ludate
          from FND_WEB_PRODUCT_FAMILY
          where FAMILY_SHORT_NAME = X_FAMILY_SHORT_NAME;


	  -- Test for customization and version
          if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                        db_ludate, X_CUSTOM_MODE)) then
	    -- Update existing row
            FND_WEB_PRODUCT_FAMILY_PKG.UPDATE_ROW (
			  X_FAMILY_SHORT_NAME => X_FAMILY_SHORT_NAME,
			  X_IS_ENABLED => X_IS_ENABLED,
			  X_FAMILY_DISPLAY_NAME => X_FAMILY_DISPLAY_NAME,
			  X_LAST_UPDATE_DATE => f_ludate,
			  X_LAST_UPDATED_BY => f_luby,
			  X_LAST_UPDATE_LOGIN => null
			);
          end if;
        exception
          when no_data_found then
            -- Record doesn't exist - insert in all cases

            FND_WEB_PRODUCT_FAMILY_PKG.INSERT_ROW (
			  X_ROWID => row_id,
			  X_FAMILY_SHORT_NAME => X_FAMILY_SHORT_NAME,
			  X_IS_ENABLED => X_IS_ENABLED,
			  X_FAMILY_DISPLAY_NAME => X_FAMILY_DISPLAY_NAME,
			  X_CREATION_DATE => sysdate,
			  X_CREATED_BY => 0,
			  X_LAST_UPDATE_DATE => f_ludate,
			  X_LAST_UPDATED_BY => f_luby,
			  X_LAST_UPDATE_LOGIN => null
			);
   end;
 end LOAD_ROW;

 procedure TRANSLATE_ROW (
   X_OWNER in VARCHAR2,
   X_FAMILY_SHORT_NAME in VARCHAR2,
   X_IS_ENABLED in VARCHAR2,
   X_FAMILY_DISPLAY_NAME in VARCHAR2,
   X_LAST_UPDATE_DATE in VARCHAR2,
   X_CUSTOM_MODE in VARCHAR2
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

	begin
	select LAST_UPDATED_BY, LAST_UPDATE_DATE
	into db_luby, db_ludate
	from FND_WEB_PRODUCT_FAMILY_TL
	where FAMILY_SHORT_NAME = X_FAMILY_SHORT_NAME
	and LANGUAGE = userenv('LANG');

    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, X_CUSTOM_MODE)) then
      update FND_WEB_PRODUCT_FAMILY_TL set
        FAMILY_DISPLAY_NAME = nvl(X_FAMILY_DISPLAY_NAME,
                                   FAMILY_DISPLAY_NAME),
        SOURCE_LANG              = userenv('LANG'),
        LAST_UPDATE_DATE         = f_ludate,
        LAST_UPDATED_BY          = f_luby,
        LAST_UPDATE_LOGIN        = 0
      where FAMILY_SHORT_NAME = X_FAMILY_SHORT_NAME
      and userenv('LANG') in (LANGUAGE, SOURCE_LANG);
    end if;
  exception
    when no_data_found then
      null;
  end;
 end TRANSLATE_ROW;

 procedure ADD_LANGUAGE
is
begin
/* Mar/19/03 requested by Ric Ginsberg */
/* The following delete and  update statements are commented out */
/* as a quick workaround to fix the time-consuming table handler issue */
/* Eventually we'll need to turn them into a separate fix_language procedure */
/*

  delete from FND_WEB_PRODUCT_FAMILY_TL T
  where not exists
    (select NULL
    from FND_WEB_PRODUCT_FAMILY B
    where B.FAMILY_SHORT_NAME = T.FAMILY_SHORT_NAME
    );

  update FND_WEB_PRODUCT_FAMILY_TL T set (
      FAMILY_DISPLAY_NAME
    ) = (select
      B.FAMILY_DISPLAY_NAME
    from FND_WEB_PRODUCT_FAMILY_TL B
    where B.FAMILY_SHORT_NAME = T.FAMILY_SHORT_NAME
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.FAMILY_SHORT_NAME,
      T.LANGUAGE
  ) in (select
      SUBT.FAMILY_SHORT_NAME,
      SUBT.LANGUAGE
    from FND_WEB_PRODUCT_FAMILY_TL SUBB, FND_WEB_PRODUCT_FAMILY_TL SUBT
    where SUBB.FAMILY_SHORT_NAME = SUBT.FAMILY_SHORT_NAME
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.FAMILY_DISPLAY_NAME <> SUBT.FAMILY_DISPLAY_NAME
  ));

*/

  insert into FND_WEB_PRODUCT_FAMILY_TL (
    CREATED_BY,
    CREATION_DATE,
    FAMILY_DISPLAY_NAME,
    FAMILY_SHORT_NAME,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.CREATED_BY,
    B.CREATION_DATE,
    B.FAMILY_DISPLAY_NAME,
    B.FAMILY_SHORT_NAME,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from FND_WEB_PRODUCT_FAMILY_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from FND_WEB_PRODUCT_FAMILY_TL T
    where T.FAMILY_SHORT_NAME = B.FAMILY_SHORT_NAME
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

 procedure SET_PRODUCT_FAMILY_STATE(
	P_FAMILY_SHORT_NAME in VARCHAR2,
	P_IS_ENABLED in VARCHAR2
	)
 is
 begin
	update FND_WEB_PRODUCT_FAMILY
	set IS_ENABLED = P_IS_ENABLED
	where FAMILY_SHORT_NAME = P_FAMILY_SHORT_NAME;

	-- Invalidate the cache
	FND_WEB_RESOURCE_PKG.InvalidateCache;

 end SET_PRODUCT_FAMILY_STATE;

 procedure DISABLE(
	P_FAMILY_SHORT_NAME in VARCHAR2
	)
 is
 begin	FND_WEB_PRODUCT_FAMILY_PKG.set_product_family_state(P_FAMILY_SHORT_NAME, 'N');
 end DISABLE;

 procedure ENABLE(
	P_FAMILY_SHORT_NAME in VARCHAR2
	)
 is
 begin	FND_WEB_PRODUCT_FAMILY_PKG.set_product_family_state(P_FAMILY_SHORT_NAME, 'Y');
 end ENABLE;

 END fnd_web_product_family_pkg;

/
