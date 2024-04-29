--------------------------------------------------------
--  DDL for Package Body FND_DOC_CATEGORIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_DOC_CATEGORIES_PKG" as
/* $Header: AFAKCATB.pls 115.15 2004/02/06 20:49:39 blash ship $ */


procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_CATEGORY_ID in NUMBER,
  X_APPLICATION_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_DEFAULT_DATATYPE_ID in NUMBER,
  X_USER_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER) is
  cursor C is select ROWID from FND_DOCUMENT_CATEGORIES
    where CATEGORY_ID = X_CATEGORY_ID;
begin

  insert into FND_DOCUMENT_CATEGORIES (
    CATEGORY_ID,
    APPLICATION_ID,
    NAME,
    START_DATE_ACTIVE,
    END_DATE_ACTIVE,
    ATTRIBUTE_CATEGORY,
    ATTRIBUTE1,
    ATTRIBUTE2,
    ATTRIBUTE3,
    ATTRIBUTE4,
    ATTRIBUTE5,
    ATTRIBUTE6,
    ATTRIBUTE7,
    ATTRIBUTE8,
    ATTRIBUTE9,
    ATTRIBUTE10,
    ATTRIBUTE11,
    ATTRIBUTE12,
    ATTRIBUTE13,
    ATTRIBUTE14,
    ATTRIBUTE15,
    DEFAULT_DATATYPE_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_CATEGORY_ID,
    X_APPLICATION_ID,
    X_NAME,
    X_START_DATE_ACTIVE,
    X_END_DATE_ACTIVE,
    X_ATTRIBUTE_CATEGORY,
    X_ATTRIBUTE1,
    X_ATTRIBUTE2,
    X_ATTRIBUTE3,
    X_ATTRIBUTE4,
    X_ATTRIBUTE5,
    X_ATTRIBUTE6,
    X_ATTRIBUTE7,
    X_ATTRIBUTE8,
    X_ATTRIBUTE9,
    X_ATTRIBUTE10,
    X_ATTRIBUTE11,
    X_ATTRIBUTE12,
    X_ATTRIBUTE13,
    X_ATTRIBUTE14,
    X_ATTRIBUTE15,
    X_DEFAULT_DATATYPE_ID,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN );

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

  insert into FND_DOCUMENT_CATEGORIES_TL (
    CATEGORY_ID,
    LANGUAGE,
    NAME,
    USER_NAME,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    SOURCE_LANG,
    app_source_version
  ) select
    X_CATEGORY_ID,
    L.LANGUAGE_CODE,
    X_NAME,
    X_USER_NAME,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    userenv('LANG'),
    '<schema><<' || USER || '>>'
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from FND_DOCUMENT_CATEGORIES_TL T
    where T.CATEGORY_ID = X_CATEGORY_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end INSERT_ROW;

procedure LOCK_ROW (
  X_CATEGORY_ID in NUMBER,
  X_APPLICATION_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_DEFAULT_DATATYPE_ID in NUMBER,
  X_USER_NAME in VARCHAR2) is
  cursor c is select
      APPLICATION_ID,
      NAME,
      START_DATE_ACTIVE,
      END_DATE_ACTIVE,
      ATTRIBUTE_CATEGORY,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15,
      DEFAULT_DATATYPE_ID
    from FND_DOCUMENT_CATEGORIES
    where CATEGORY_ID = X_CATEGORY_ID
    for update of CATEGORY_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      USER_NAME
    from FND_DOCUMENT_CATEGORIES_TL
    where CATEGORY_ID = X_CATEGORY_ID
    and LANGUAGE = userenv('LANG')
    for update of CATEGORY_ID nowait;
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
      if ( (recinfo.NAME = X_NAME)
      AND ((recinfo.APPLICATION_ID = X_APPLICATION_ID)
	   OR ((recinfo.application_id is null)
	      AND (X_application_id is null)))
      AND ((recinfo.START_DATE_ACTIVE = X_START_DATE_ACTIVE)
           OR ((recinfo.START_DATE_ACTIVE is null)
               AND (X_START_DATE_ACTIVE is null)))
      AND ((recinfo.END_DATE_ACTIVE = X_END_DATE_ACTIVE)
           OR ((recinfo.END_DATE_ACTIVE is null)
               AND (X_END_DATE_ACTIVE is null)))
      AND ((recinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
           OR ((recinfo.ATTRIBUTE_CATEGORY is null)
               AND (X_ATTRIBUTE_CATEGORY is null)))
      AND ((recinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
           OR ((recinfo.ATTRIBUTE1 is null)
               AND (X_ATTRIBUTE1 is null)))
      AND ((recinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
           OR ((recinfo.ATTRIBUTE2 is null)
               AND (X_ATTRIBUTE2 is null)))
      AND ((recinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
           OR ((recinfo.ATTRIBUTE3 is null)
               AND (X_ATTRIBUTE3 is null)))
      AND ((recinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
           OR ((recinfo.ATTRIBUTE4 is null)
               AND (X_ATTRIBUTE4 is null)))
      AND ((recinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
           OR ((recinfo.ATTRIBUTE5 is null)
               AND (X_ATTRIBUTE5 is null)))
      AND ((recinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
           OR ((recinfo.ATTRIBUTE6 is null)
               AND (X_ATTRIBUTE6 is null)))
      AND ((recinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
           OR ((recinfo.ATTRIBUTE7 is null)
               AND (X_ATTRIBUTE7 is null)))
      AND ((recinfo.ATTRIBUTE8 = X_ATTRIBUTE8)
           OR ((recinfo.ATTRIBUTE8 is null)
               AND (X_ATTRIBUTE8 is null)))
      AND ((recinfo.ATTRIBUTE9 = X_ATTRIBUTE9)
           OR ((recinfo.ATTRIBUTE9 is null)
               AND (X_ATTRIBUTE9 is null)))
      AND ((recinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
           OR ((recinfo.ATTRIBUTE10 is null)
               AND (X_ATTRIBUTE10 is null)))
      AND ((recinfo.ATTRIBUTE11 = X_ATTRIBUTE11)
           OR ((recinfo.ATTRIBUTE11 is null)
               AND (X_ATTRIBUTE11 is null)))
      AND ((recinfo.ATTRIBUTE12 = X_ATTRIBUTE12)
           OR ((recinfo.ATTRIBUTE12 is null)
               AND (X_ATTRIBUTE12 is null)))
      AND ((recinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
           OR ((recinfo.ATTRIBUTE13 is null)
               AND (X_ATTRIBUTE13 is null)))
      AND ((recinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
           OR ((recinfo.ATTRIBUTE14 is null)
               AND (X_ATTRIBUTE14 is null)))
      AND ((recinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
           OR ((recinfo.ATTRIBUTE15 is null)
               AND (X_ATTRIBUTE15 is null)))
      AND ((recinfo.DEFAULT_DATATYPE_ID = X_DEFAULT_DATATYPE_ID)
           OR ((recinfo.DEFAULT_DATATYPE_ID is null)
               AND (X_DEFAULT_DATATYPE_ID is null)))
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

  if (NOT( (tlinfo.USER_NAME = X_USER_NAME)
  )) then
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_CATEGORY_ID in NUMBER,
  X_APPLICATION_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_DEFAULT_DATATYPE_ID in NUMBER,
  X_USER_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER) is
begin
    update FND_DOCUMENT_CATEGORIES set
      CATEGORY_ID = X_CATEGORY_ID,
      APPLICATION_ID = X_APPLICATION_ID,
      NAME = X_NAME,
      START_DATE_ACTIVE = X_START_DATE_ACTIVE,
      END_DATE_ACTIVE = X_END_DATE_ACTIVE,
      ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY,
      ATTRIBUTE1 = X_ATTRIBUTE1,
      ATTRIBUTE2 = X_ATTRIBUTE2,
      ATTRIBUTE3 = X_ATTRIBUTE3,
      ATTRIBUTE4 = X_ATTRIBUTE4,
      ATTRIBUTE5 = X_ATTRIBUTE5,
      ATTRIBUTE6 = X_ATTRIBUTE6,
      ATTRIBUTE7 = X_ATTRIBUTE7,
      ATTRIBUTE8 = X_ATTRIBUTE8,
      ATTRIBUTE9 = X_ATTRIBUTE9,
      ATTRIBUTE10 = X_ATTRIBUTE10,
      ATTRIBUTE11 = X_ATTRIBUTE11,
      ATTRIBUTE12 = X_ATTRIBUTE12,
      ATTRIBUTE13 = X_ATTRIBUTE13,
      ATTRIBUTE14 = X_ATTRIBUTE14,
      ATTRIBUTE15 = X_ATTRIBUTE15,
      DEFAULT_DATATYPE_ID = X_DEFAULT_DATATYPE_ID,
      LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
      LAST_UPDATED_BY = X_LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
    where CATEGORY_ID = X_CATEGORY_ID;
  if (sql%notfound) then
    raise no_data_found;
  end if;

  update FND_DOCUMENT_CATEGORIES_TL set
    NAME = X_NAME,
    USER_NAME = X_USER_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    APP_SOURCE_VERSION = '<schema><<' || USER || '>>',
    SOURCE_LANG = userenv('LANG')
  where CATEGORY_ID = X_CATEGORY_ID
  and userenv('LANG') in (LANGUAGE,SOURCE_LANG);
  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (X_CATEGORY_ID in NUMBER) is
begin
 -- need to mark fnd_document_categories.app_source_version with the
 -- USER the delete is being sourced from so that trigger logic can call
 -- the delete stored procedure in the appropriate schema
 -- (R10/10SC compatibility logic) WIP logic operates off tl table
 --UPDATE fnd_document_categories_tl
 -- SET app_source_Version = 'DEL_10SC<schema><<' || USER || '>>'
 --WHERE category_id = X_category_id;

 --  now do the delete
  delete from FND_DOCUMENT_CATEGORIES
  where CATEGORY_ID = X_CATEGORY_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from FND_DOCUMENT_CATEGORIES_TL
  where CATEGORY_ID = X_CATEGORY_ID;
  if (sql%notfound) then
    raise no_data_found;
  end if;

  DELETE FROM fnd_doc_category_usages
  WHERE category_id = x_category_id;

end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin

/* Mar/19/03 requested by Ric Ginsberg */
/* The following delete and update statements are commented out */
/* as a quick workaround to fix the time-consuming table handler issue */
/* Eventually we'll need to turn them into a separate fix_language procedure */
/*

  delete from FND_DOCUMENT_CATEGORIES_TL T
  where not exists
    (select NULL
    from FND_DOCUMENT_CATEGORIES B
    where B.CATEGORY_ID = T.CATEGORY_ID
    );

  update FND_DOCUMENT_CATEGORIES_TL T set (
      USER_NAME
    ) = (select
      B.USER_NAME
    from FND_DOCUMENT_CATEGORIES_TL B
    where B.CATEGORY_ID = T.CATEGORY_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.CATEGORY_ID,
      T.LANGUAGE
  ) in (select
      SUBT.CATEGORY_ID,
      SUBT.LANGUAGE
    from FND_DOCUMENT_CATEGORIES_TL SUBB, FND_DOCUMENT_CATEGORIES_TL SUBT
    where SUBB.CATEGORY_ID = SUBT.CATEGORY_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.USER_NAME <> SUBT.USER_NAME
  ));
*/

  insert into FND_DOCUMENT_CATEGORIES_TL (
    CATEGORY_ID,
    LANGUAGE,
    NAME,
    USER_NAME,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    SOURCE_LANG
  ) select
    M.CATEGORY_ID,
    L.LANGUAGE_CODE,
    M.NAME,
    M.USER_NAME,
    M.CREATION_DATE,
    M.CREATED_BY,
    M.LAST_UPDATE_DATE,
    M.LAST_UPDATED_BY,
    M.LAST_UPDATE_LOGIN,
    M.SOURCE_LANG
  from FND_DOCUMENT_CATEGORIES_TL M, FND_LANGUAGES B, FND_LANGUAGES L
  where B.INSTALLED_FLAG = 'B'
  and L.INSTALLED_FLAG in ('I', 'B')
  and M.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from FND_DOCUMENT_CATEGORIES_TL T
    where T.CATEGORY_ID = M.CATEGORY_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure TRANSLATE_ROW (
        X_CATEGORY_NAME in      VARCHAR2,
        X_USER_NAME     in      VARCHAR2,
        X_OWNER         in      VARCHAR2) IS
begin

   update fnd_document_categories_tl set
     user_name	= nvl(X_USER_NAME,user_name),
     last_update_date  = sysdate,
     last_updated_by   = decode(X_OWNER, 'SEED', 1, 0),
     last_update_login = 0,
     source_lang       = userenv('LANG')
   where name = X_CATEGORY_NAME
    and userenv('LANG') in (language, source_lang);

end TRANSLATE_ROW;

-- Overloaded for BUG 3087292.

procedure TRANSLATE_ROW (
        X_CATEGORY_NAME in      VARCHAR2,
        X_USER_NAME     in      VARCHAR2,
        X_OWNER         in      VARCHAR2,
        X_LAST_UPDATE_DATE in   VARCHAR2,
        X_CUSTOM_MODE   in      VARCHAR2) IS

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
   from fnd_document_categories_tl
   where name = X_CATEGORY_NAME
   and LANGUAGE = userenv('LANG');

   if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                   db_ludate, X_CUSTOM_MODE)) then
     update fnd_document_categories_tl set
       user_name	= nvl(X_USER_NAME,user_name),
       last_update_date  = f_ludate,
       last_updated_by   = f_luby,
       last_update_login = 0,
       source_lang       = userenv('LANG')
     where name = X_CATEGORY_NAME
     and userenv('LANG') in (language, source_lang);
   end if;

end TRANSLATE_ROW;

procedure LOAD_ROW (
        X_CATEGORY_NAME         in      VARCHAR2,
	X_APP_SHORT_NAME	in	VARCHAR2,
        X_OWNER                 in      VARCHAR2,
        X_START_DATE_ACTIVE     in      VARCHAR2,
        X_END_DATE_ACTIVE       in      VARCHAR2,
        X_ATTRIBUTE_CATEGORY    in      VARCHAR2,
        X_ATTRIBUTE1            in      VARCHAR2,
        X_ATTRIBUTE2            in      VARCHAR2,
        X_ATTRIBUTE3            in      VARCHAR2,
        X_ATTRIBUTE4            in      VARCHAR2,
        X_ATTRIBUTE5            in      VARCHAR2,
        X_ATTRIBUTE6            in      VARCHAR2,
        X_ATTRIBUTE7            in      VARCHAR2,
        X_ATTRIBUTE8            in      VARCHAR2,
        X_ATTRIBUTE9            in      VARCHAR2,
        X_ATTRIBUTE10           in      VARCHAR2,
        X_ATTRIBUTE11           in      VARCHAR2,
        X_ATTRIBUTE12           in      VARCHAR2,
        X_ATTRIBUTE13           in      VARCHAR2,
        X_ATTRIBUTE14           in      VARCHAR2,
        X_ATTRIBUTE15           in      VARCHAR2,
        X_DEFAULT_DATATYPE_ID   in      VARCHAR2,
        X_APP_SOURCE_VERSION    in      VARCHAR2,
        X_USER_NAME             in      VARCHAR2 ) IS

   l_user_id 		number := 0 ;
   l_category_id 	number := 0 ;
   l_application_id 	number := 0 ;
   l_row_id 		varchar2(64);

begin
    if (X_OWNER = 'SEED') then
      l_user_id := 1;
    end if;

    -- Get application id from fnd_application
    if (X_APP_SHORT_NAME IS NOT NULL) then
    	select application_id
        into   l_application_id
        from   fnd_application
       where   application_short_name = X_APP_SHORT_NAME;
   else
      l_application_id := NULL ;
   end if;

   begin
      -- Get category Id from fnd_document_categories.
      select category_id, application_id
        into l_category_id, l_application_id
        from fnd_document_categories
      where  name = X_CATEGORY_NAME ;

      UPDATE_ROW (
 	   X_CATEGORY_ID 		=> l_category_id,
 	   X_APPLICATION_ID 	=> l_application_id,
 	   X_NAME		=> X_CATEGORY_NAME,
 	   X_START_DATE_ACTIVE 	=> to_date(X_START_DATE_ACTIVE, 'YYYY/MM/DD'),
 	   X_END_DATE_ACTIVE 	=> to_date(X_END_DATE_ACTIVE, 'YYYY/MM/DD'),
 	   X_ATTRIBUTE_CATEGORY	=> X_ATTRIBUTE_CATEGORY,
 	   X_ATTRIBUTE1 	=> X_ATTRIBUTE1,
 	   X_ATTRIBUTE2 	=> X_ATTRIBUTE2,
 	   X_ATTRIBUTE3		=> X_ATTRIBUTE3,
 	   X_ATTRIBUTE4		=> X_ATTRIBUTE4,
 	   X_ATTRIBUTE5		=> X_ATTRIBUTE5,
 	   X_ATTRIBUTE6		=> X_ATTRIBUTE6,
 	   X_ATTRIBUTE7		=> X_ATTRIBUTE7,
 	   X_ATTRIBUTE8		=> X_ATTRIBUTE8,
 	   X_ATTRIBUTE9		=> X_ATTRIBUTE9,
 	   X_ATTRIBUTE10	=> X_ATTRIBUTE10,
 	   X_ATTRIBUTE11	=> X_ATTRIBUTE11,
 	   X_ATTRIBUTE12	=> X_ATTRIBUTE12,
 	   X_ATTRIBUTE13	=> X_ATTRIBUTE13,
 	   X_ATTRIBUTE14	=> X_ATTRIBUTE14,
 	   X_ATTRIBUTE15	=> X_ATTRIBUTE15,
 	   X_DEFAULT_DATATYPE_ID	=> to_number(X_DEFAULT_DATATYPE_ID),
  	   X_USER_NAME 		=> X_USER_NAME,
 	   X_LAST_UPDATE_DATE	=> sysdate,
 	   X_LAST_UPDATED_BY	=> l_user_id,
 	   X_LAST_UPDATE_LOGIN 	=> 0 );

    exception
      when no_data_found then

      -- Get category id from a sequence.
      select fnd_document_categories_s.nextval
      into l_category_id
      from dual;

      INSERT_ROW (
 	  X_ROWID 		=> l_row_id,
 	  X_CATEGORY_ID 	=> l_category_id,
 	  X_APPLICATION_ID	=> l_application_id,
 	  X_NAME 		=> X_CATEGORY_NAME,
 	  X_START_DATE_ACTIVE	=> to_date(X_START_DATE_ACTIVE, 'YYYY/MM/DD'),
 	  X_END_DATE_ACTIVE	=> to_date(X_END_DATE_ACTIVE, 'YYYY/MM/DD'),
 	  X_ATTRIBUTE_CATEGORY	=> X_ATTRIBUTE_CATEGORY,
 	  X_ATTRIBUTE1		=> X_ATTRIBUTE1,
	  X_ATTRIBUTE2		=> X_ATTRIBUTE2,
          X_ATTRIBUTE3		=> X_ATTRIBUTE3,
          X_ATTRIBUTE4		=> X_ATTRIBUTE4,
          X_ATTRIBUTE5		=> X_ATTRIBUTE5,
          X_ATTRIBUTE6		=> X_ATTRIBUTE6,
          X_ATTRIBUTE7		=> X_ATTRIBUTE7,
          X_ATTRIBUTE8		=> X_ATTRIBUTE8,
          X_ATTRIBUTE9		=> X_ATTRIBUTE9,
          X_ATTRIBUTE10	=> X_ATTRIBUTE10,
          X_ATTRIBUTE11	=> X_ATTRIBUTE11,
          X_ATTRIBUTE12	=> X_ATTRIBUTE12,
          X_ATTRIBUTE13	=> X_ATTRIBUTE13,
          X_ATTRIBUTE14	=> X_ATTRIBUTE14,
          X_ATTRIBUTE15	=> X_ATTRIBUTE15,
          X_DEFAULT_DATATYPE_ID   => to_number(X_DEFAULT_DATATYPE_ID),
          X_USER_NAME          => X_USER_NAME,
          X_CREATION_DATE 	=> sysdate,
 	   X_CREATED_BY		=> l_user_id,
          X_LAST_UPDATE_DATE   => sysdate,
          X_LAST_UPDATED_BY    => l_user_id,
          X_LAST_UPDATE_LOGIN  => 0 );

  end;
end LOAD_ROW;

-- Overloaded for BUG 3087292.

procedure LOAD_ROW (
        X_CATEGORY_NAME         in      VARCHAR2,
	X_APP_SHORT_NAME	in	VARCHAR2,
        X_OWNER                 in      VARCHAR2,
        X_START_DATE_ACTIVE     in      VARCHAR2,
        X_END_DATE_ACTIVE       in      VARCHAR2,
        X_ATTRIBUTE_CATEGORY    in      VARCHAR2,
        X_ATTRIBUTE1            in      VARCHAR2,
        X_ATTRIBUTE2            in      VARCHAR2,
        X_ATTRIBUTE3            in      VARCHAR2,
        X_ATTRIBUTE4            in      VARCHAR2,
        X_ATTRIBUTE5            in      VARCHAR2,
        X_ATTRIBUTE6            in      VARCHAR2,
        X_ATTRIBUTE7            in      VARCHAR2,
        X_ATTRIBUTE8            in      VARCHAR2,
        X_ATTRIBUTE9            in      VARCHAR2,
        X_ATTRIBUTE10           in      VARCHAR2,
        X_ATTRIBUTE11           in      VARCHAR2,
        X_ATTRIBUTE12           in      VARCHAR2,
        X_ATTRIBUTE13           in      VARCHAR2,
        X_ATTRIBUTE14           in      VARCHAR2,
        X_ATTRIBUTE15           in      VARCHAR2,
        X_DEFAULT_DATATYPE_ID   in      VARCHAR2,
        X_APP_SOURCE_VERSION    in      VARCHAR2,
        X_USER_NAME             in      VARCHAR2,
        X_LAST_UPDATE_DATE      in      VARCHAR2,
        X_CUSTOM_MODE           in      VARCHAR2 ) IS

   l_user_id 		number := 0 ;
   l_category_id 	number := 0 ;
   l_application_id 	number := 0 ;
   l_row_id 		varchar2(64);
   f_luby    number;  -- entity owner in file
   f_ludate  date;    -- entity update date in file
   db_luby   number;  -- entity owner in db
   db_ludate date;    -- entity update date in db

begin
   -- Translate owner to file_last_updated_by
   f_luby := fnd_load_util.owner_id(x_owner);

   -- Translate char last_update_date to date
   f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

   -- Get application id from fnd_application
   if (X_APP_SHORT_NAME IS NOT NULL) then
    	select application_id
        into   l_application_id
        from   fnd_application
       where   application_short_name = X_APP_SHORT_NAME;
   else
      l_application_id := NULL ;
   end if;

   begin
      -- Get category Id from fnd_document_categories.
      select category_id, application_id, LAST_UPDATED_BY, LAST_UPDATE_DATE
        into l_category_id, l_application_id, db_luby, db_ludate
        from fnd_document_categories
      where  name = X_CATEGORY_NAME ;

      if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                   db_ludate, X_CUSTOM_MODE)) then
        UPDATE_ROW (
 	     X_CATEGORY_ID 		=> l_category_id,
 	     X_APPLICATION_ID 	=> l_application_id,
 	     X_NAME		=> X_CATEGORY_NAME,
 	     X_START_DATE_ACTIVE => to_date(X_START_DATE_ACTIVE, 'YYYY/MM/DD'),
 	     X_END_DATE_ACTIVE 	=> to_date(X_END_DATE_ACTIVE, 'YYYY/MM/DD'),
 	     X_ATTRIBUTE_CATEGORY	=> X_ATTRIBUTE_CATEGORY,
 	     X_ATTRIBUTE1 	=> X_ATTRIBUTE1,
 	     X_ATTRIBUTE2 	=> X_ATTRIBUTE2,
 	     X_ATTRIBUTE3		=> X_ATTRIBUTE3,
 	     X_ATTRIBUTE4		=> X_ATTRIBUTE4,
 	     X_ATTRIBUTE5		=> X_ATTRIBUTE5,
 	     X_ATTRIBUTE6		=> X_ATTRIBUTE6,
 	     X_ATTRIBUTE7		=> X_ATTRIBUTE7,
 	     X_ATTRIBUTE8		=> X_ATTRIBUTE8,
 	     X_ATTRIBUTE9		=> X_ATTRIBUTE9,
 	     X_ATTRIBUTE10	=> X_ATTRIBUTE10,
 	     X_ATTRIBUTE11	=> X_ATTRIBUTE11,
 	     X_ATTRIBUTE12	=> X_ATTRIBUTE12,
 	     X_ATTRIBUTE13	=> X_ATTRIBUTE13,
 	     X_ATTRIBUTE14	=> X_ATTRIBUTE14,
 	     X_ATTRIBUTE15	=> X_ATTRIBUTE15,
 	     X_DEFAULT_DATATYPE_ID	=> to_number(X_DEFAULT_DATATYPE_ID),
  	     X_USER_NAME 		=> X_USER_NAME,
 	     X_LAST_UPDATE_DATE	=> f_ludate,
 	     X_LAST_UPDATED_BY	=> f_luby,
 	     X_LAST_UPDATE_LOGIN 	=> 0 );
      end if;

    exception
      when no_data_found then

      -- Get category id from a sequence.
      select fnd_document_categories_s.nextval
      into l_category_id
      from dual;

      INSERT_ROW (
 	  X_ROWID 		=> l_row_id,
 	  X_CATEGORY_ID 	=> l_category_id,
 	  X_APPLICATION_ID	=> l_application_id,
 	  X_NAME 		=> X_CATEGORY_NAME,
 	  X_START_DATE_ACTIVE	=> to_date(X_START_DATE_ACTIVE, 'YYYY/MM/DD'),
 	  X_END_DATE_ACTIVE	=> to_date(X_END_DATE_ACTIVE, 'YYYY/MM/DD'),
 	  X_ATTRIBUTE_CATEGORY	=> X_ATTRIBUTE_CATEGORY,
 	  X_ATTRIBUTE1		=> X_ATTRIBUTE1,
	  X_ATTRIBUTE2		=> X_ATTRIBUTE2,
          X_ATTRIBUTE3		=> X_ATTRIBUTE3,
          X_ATTRIBUTE4		=> X_ATTRIBUTE4,
          X_ATTRIBUTE5		=> X_ATTRIBUTE5,
          X_ATTRIBUTE6		=> X_ATTRIBUTE6,
          X_ATTRIBUTE7		=> X_ATTRIBUTE7,
          X_ATTRIBUTE8		=> X_ATTRIBUTE8,
          X_ATTRIBUTE9		=> X_ATTRIBUTE9,
          X_ATTRIBUTE10	=> X_ATTRIBUTE10,
          X_ATTRIBUTE11	=> X_ATTRIBUTE11,
          X_ATTRIBUTE12	=> X_ATTRIBUTE12,
          X_ATTRIBUTE13	=> X_ATTRIBUTE13,
          X_ATTRIBUTE14	=> X_ATTRIBUTE14,
          X_ATTRIBUTE15	=> X_ATTRIBUTE15,
          X_DEFAULT_DATATYPE_ID   => to_number(X_DEFAULT_DATATYPE_ID),
          X_USER_NAME          => X_USER_NAME,
          X_CREATION_DATE 	=> f_ludate,
 	  X_CREATED_BY		=> f_luby,
          X_LAST_UPDATE_DATE   => f_ludate,
          X_LAST_UPDATED_BY    => f_luby,
          X_LAST_UPDATE_LOGIN  => 0 );

  end;
end LOAD_ROW;

end FND_DOC_CATEGORIES_PKG;

/
