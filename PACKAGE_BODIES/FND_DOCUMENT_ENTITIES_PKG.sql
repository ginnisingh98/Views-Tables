--------------------------------------------------------
--  DDL for Package Body FND_DOCUMENT_ENTITIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_DOCUMENT_ENTITIES_PKG" AS
/* $Header: AFAKDOCB.pls 115.14 2004/02/06 20:50:21 blash ship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_DOCUMENT_ENTITY_ID in NUMBER,
  X_DATA_OBJECT_CODE in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_TABLE_NAME in VARCHAR2,
  X_PK1_COLUMN in VARCHAR2,
  X_PK2_COLUMN in VARCHAR2,
  X_PK3_COLUMN in VARCHAR2,
  X_PK4_COLUMN in VARCHAR2,
  X_PK5_COLUMN in VARCHAR2,
  X_USER_ENTITY_NAME in VARCHAR2,
  X_USER_ENTITY_PROMPT in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from FND_DOCUMENT_ENTITIES
    where DATA_OBJECT_CODE = X_DATA_OBJECT_CODE;
begin

  insert into FND_DOCUMENT_ENTITIES (
    DOCUMENT_ENTITY_ID,
    DATA_OBJECT_CODE,
    APPLICATION_ID,
    TABLE_NAME,
    PK1_COLUMN,
    PK2_COLUMN,
    PK3_COLUMN,
    PK4_COLUMN,
    PK5_COLUMN,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_DOCUMENT_ENTITY_ID,
    X_DATA_OBJECT_CODE,
    X_APPLICATION_ID,
    X_TABLE_NAME,
    X_PK1_COLUMN,
    X_PK2_COLUMN,
    X_PK3_COLUMN,
    X_PK4_COLUMN,
    X_PK5_COLUMN,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

  insert into FND_DOCUMENT_ENTITIES_TL (
    DOCUMENT_ENTITY_ID,
    DATA_OBJECT_CODE,
    LANGUAGE,
    USER_ENTITY_NAME,
    USER_ENTITY_PROMPT,
    SOURCE_LANG,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) select
    X_DOCUMENT_ENTITY_ID,
    X_DATA_OBJECT_CODE,
    L.LANGUAGE_CODE,
    X_USER_ENTITY_NAME,
    X_USER_ENTITY_PROMPT,
    userenv('LANG'),
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from FND_DOCUMENT_ENTITIES_TL T
    where T.DATA_OBJECT_CODE = X_DATA_OBJECT_CODE
    and T.LANGUAGE = L.LANGUAGE_CODE);
end INSERT_ROW;

procedure LOCK_ROW (
  X_DOCUMENT_ENTITY_ID in NUMBER,
  X_DATA_OBJECT_CODE in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_TABLE_NAME in VARCHAR2,
  X_PK1_COLUMN in VARCHAR2,
  X_PK2_COLUMN in VARCHAR2,
  X_PK3_COLUMN in VARCHAR2,
  X_PK4_COLUMN in VARCHAR2,
  X_PK5_COLUMN in VARCHAR2,
  X_USER_ENTITY_NAME in VARCHAR2,
  X_USER_ENTITY_PROMPT in VARCHAR2
) is
  cursor c is select
      APPLICATION_ID,
      TABLE_NAME,
      PK1_COLUMN,
      PK2_COLUMN,
      PK3_COLUMN,
      PK4_COLUMN,
      PK5_COLUMN
    from FND_DOCUMENT_ENTITIES
    where DATA_OBJECT_CODE = X_DATA_OBJECT_CODE
    for update of DOCUMENT_ENTITY_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      USER_ENTITY_NAME,
      USER_ENTITY_PROMPT
    from FND_DOCUMENT_ENTITIES_TL
    where DATA_OBJECT_CODE = X_DATA_OBJECT_CODE
    and LANGUAGE = userenv('LANG')
    for update of DOCUMENT_ENTITY_ID nowait;
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
  if (NOT( (recinfo.APPLICATION_ID = X_APPLICATION_ID)
      AND (recinfo.TABLE_NAME = X_TABLE_NAME)
      AND ((recinfo.PK1_COLUMN = X_PK1_COLUMN)
           OR ((recinfo.PK1_COLUMN is null)
               AND (X_PK1_COLUMN is null)))
      AND ((recinfo.PK2_COLUMN = X_PK2_COLUMN)
           OR ((recinfo.PK2_COLUMN is null)
               AND (X_PK2_COLUMN is null)))
      AND ((recinfo.PK3_COLUMN = X_PK3_COLUMN)
           OR ((recinfo.PK3_COLUMN is null)
               AND (X_PK3_COLUMN is null)))
      AND ((recinfo.PK4_COLUMN = X_PK4_COLUMN)
           OR ((recinfo.PK4_COLUMN is null)
               AND (X_PK4_COLUMN is null)))
      AND ((recinfo.PK5_COLUMN = X_PK5_COLUMN)
           OR ((recinfo.PK5_COLUMN is null)
               AND (X_PK5_COLUMN is null)))
  )) then
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

  if (NOT( (tlinfo.USER_ENTITY_NAME = X_USER_ENTITY_NAME)
      AND (tlinfo.USER_ENTITY_PROMPT = X_USER_ENTITY_PROMPT)
  )) then
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_DOCUMENT_ENTITY_ID in NUMBER,
  X_DATA_OBJECT_CODE in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_TABLE_NAME in VARCHAR2,
  X_PK1_COLUMN in VARCHAR2,
  X_PK2_COLUMN in VARCHAR2,
  X_PK3_COLUMN in VARCHAR2,
  X_PK4_COLUMN in VARCHAR2,
  X_PK5_COLUMN in VARCHAR2,
  X_USER_ENTITY_NAME in VARCHAR2,
  X_USER_ENTITY_PROMPT in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
    update FND_DOCUMENT_ENTITIES set
      DOCUMENT_ENTITY_ID = X_DOCUMENT_ENTITY_ID,
      DATA_OBJECT_CODE = X_DATA_OBJECT_CODE,
      APPLICATION_ID = X_APPLICATION_ID,
      TABLE_NAME = X_TABLE_NAME,
      PK1_COLUMN = X_PK1_COLUMN,
      PK2_COLUMN = X_PK2_COLUMN,
      PK3_COLUMN = X_PK3_COLUMN,
      PK4_COLUMN = X_PK4_COLUMN,
      PK5_COLUMN = X_PK5_COLUMN,
      LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
      LAST_UPDATED_BY = X_LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
    where DATA_OBJECT_CODE = X_DATA_OBJECT_CODE;
  if (sql%notfound) then
    raise no_data_found;
  end if;

  update FND_DOCUMENT_ENTITIES_TL set
    USER_ENTITY_NAME = X_USER_ENTITY_NAME,
    USER_ENTITY_PROMPT = X_USER_ENTITY_PROMPT,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where DATA_OBJECT_CODE = X_DATA_OBJECT_CODE
  and LANGUAGE = userenv('LANG');
  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_DOCUMENT_ENTITY_ID in NUMBER,
  X_DATA_OBJECT_CODE in VARCHAR2
) is
begin
  delete from FND_DOCUMENT_ENTITIES
  where DATA_OBJECT_CODE = X_DATA_OBJECT_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from FND_DOCUMENT_ENTITIES_TL
  where DATA_OBJECT_CODE = X_DATA_OBJECT_CODE;
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

  delete from FND_DOCUMENT_ENTITIES_TL T
  where not exists
    (select NULL
    from FND_DOCUMENT_ENTITIES B
    where B.DATA_OBJECT_CODE = T.DATA_OBJECT_CODE
    );

  update FND_DOCUMENT_ENTITIES_TL T set (
      USER_ENTITY_NAME,
      USER_ENTITY_PROMPT
    ) = (select
      B.USER_ENTITY_NAME,
      B.USER_ENTITY_PROMPT
    from FND_DOCUMENT_ENTITIES_TL B
    where B.DATA_OBJECT_CODE = T.DATA_OBJECT_CODE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.DOCUMENT_ENTITY_ID,
      T.LANGUAGE
  ) in (select
      SUBT.DOCUMENT_ENTITY_ID,
      SUBT.LANGUAGE
    from FND_DOCUMENT_ENTITIES_TL SUBB, FND_DOCUMENT_ENTITIES_TL SUBT
    where SUBB.DATA_OBJECT_CODE = SUBT.DATA_OBJECT_CODE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.USER_ENTITY_NAME <> SUBT.USER_ENTITY_NAME
      or SUBB.USER_ENTITY_PROMPT <> SUBT.USER_ENTITY_PROMPT
  ));
*/

  insert into FND_DOCUMENT_ENTITIES_TL (
    DOCUMENT_ENTITY_ID,
    DATA_OBJECT_CODE,
    LANGUAGE,
    USER_ENTITY_NAME,
    USER_ENTITY_PROMPT,
    SOURCE_LANG,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) select
    M.DOCUMENT_ENTITY_ID,
    M.DATA_OBJECT_CODE,
    L.LANGUAGE_CODE,
    M.USER_ENTITY_NAME,
    M.USER_ENTITY_PROMPT,
    M.SOURCE_LANG,
    M.CREATION_DATE,
    M.CREATED_BY,
    M.LAST_UPDATE_DATE,
    M.LAST_UPDATED_BY,
    M.LAST_UPDATE_LOGIN
  from FND_DOCUMENT_ENTITIES_TL M, FND_LANGUAGES B, FND_LANGUAGES L
  where B.INSTALLED_FLAG = 'B'
  and L.INSTALLED_FLAG in ('I', 'B')
  and M.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from FND_DOCUMENT_ENTITIES_TL T
    where T.DATA_OBJECT_CODE = M.DATA_OBJECT_CODE
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure TRANSLATE_ROW (
   X_DATA_OBJECT_CODE in varchar2,
   X_APP_SHORT_NAME in varchar2,
   X_USER_ENTITY_NAME in varchar2,
   X_USER_ENTITY_PROMPT in varchar2,
   X_OWNER in varchar2) IS

begin

   update fnd_document_entities_tl set
     user_entity_name  = nvl(X_USER_ENTITY_NAME,user_entity_name),
     user_entity_prompt  = nvl(X_USER_ENTITY_PROMPT,user_entity_prompt),
     last_update_date  = sysdate,
     last_updated_by   = decode(X_OWNER, 'SEED', 1, 0),
     last_update_login = 0,
     source_lang       = userenv('LANG')
   where data_object_code = X_DATA_OBJECT_CODE
    and userenv('LANG') in (language, source_lang);

end TRANSLATE_ROW;

-- Overloaded for BUG 3087292.

procedure TRANSLATE_ROW (
   X_DATA_OBJECT_CODE in varchar2,
   X_APP_SHORT_NAME in varchar2,
   X_USER_ENTITY_NAME in varchar2,
   X_USER_ENTITY_PROMPT in varchar2,
   X_OWNER              in varchar2,
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
   from fnd_document_entities_tl
   where data_object_code = X_DATA_OBJECT_CODE
   and LANGUAGE = userenv('LANG');

   if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                   db_ludate, X_CUSTOM_MODE)) then
     update fnd_document_entities_tl set
       user_entity_name  = nvl(X_USER_ENTITY_NAME,user_entity_name),
       user_entity_prompt  = nvl(X_USER_ENTITY_PROMPT,user_entity_prompt),
       last_update_date  = f_ludate,
       last_updated_by   = f_luby,
       last_update_login = 0,
       source_lang       = userenv('LANG')
     where data_object_code = X_DATA_OBJECT_CODE
     and userenv('LANG') in (language, source_lang);
   end if;

end TRANSLATE_ROW;

procedure LOAD_ROW (
   X_DATA_OBJECT_CODE in varchar2,
   X_APP_SHORT_NAME in varchar2,
   X_TABLE_NAME in varchar2,
   X_ENTITY_NAME in varchar2,
   X_OWNER in varchar2,
   X_PK1_COLUMN in varchar2,
   X_PK2_COLUMN in varchar2,
   X_PK3_COLUMN in varchar2,
   X_PK4_COLUMN in varchar2,
   X_PK5_COLUMN in varchar2,
   X_USER_ENTITY_NAME in varchar2,
   X_USER_ENTITY_PROMPT in varchar2)is

   l_user_id           	number := 0 ;
   l_document_entity_id	number := 0 ;
   l_application_id     number := 0 ;
   l_row_id             varchar2(64);

begin

   if (X_OWNER = 'SEED') then
      l_user_id := 1;
   end if;

   -- Get application Id from fnd_application.
   select application_id
    into  l_application_id
    from  fnd_application
    where application_short_name = X_APP_SHORT_NAME;

   begin
        -- Get document entity Id from fnd_document_entities.
        select document_entity_id, application_id
          into l_document_entity_id, l_application_id
          from fnd_document_entities
        where  data_object_code = X_DATA_OBJECT_CODE ;

       UPDATE_ROW (
  	   X_DOCUMENT_ENTITY_ID	=> l_document_entity_id,
  	   X_DATA_OBJECT_CODE 	=> X_DATA_OBJECT_CODE,
  	   X_APPLICATION_ID	=> l_application_id,
  	   X_TABLE_NAME	=> X_TABLE_NAME,
  	   X_PK1_COLUMN	=> X_PK1_COLUMN,
  	   X_PK2_COLUMN	=> X_PK2_COLUMN,
  	   X_PK3_COLUMN	=> X_PK3_COLUMN,
  	   X_PK4_COLUMN	=> X_PK4_COLUMN,
  	   X_PK5_COLUMN	=> X_PK5_COLUMN,
  	   X_USER_ENTITY_NAME	=> X_USER_ENTITY_NAME,
  	   X_USER_ENTITY_PROMPT	=> X_USER_ENTITY_PROMPT,
  	   X_LAST_UPDATE_DATE	=> sysdate,
  	   X_LAST_UPDATED_BY	=> l_user_id,
  	   X_LAST_UPDATE_LOGIN	=> 0);

   exception
     when no_data_found then

        select fnd_document_entities_s.nextval
         into  l_document_entity_id
         from  dual;

         INSERT_ROW (
           X_ROWID              => l_row_id,
           X_DOCUMENT_ENTITY_ID	=> l_document_entity_id,
           X_DATA_OBJECT_CODE	=> X_DATA_OBJECT_CODE,
           X_APPLICATION_ID     => l_application_id,
	   X_TABLE_NAME		=> X_TABLE_NAME,
	   X_PK1_COLUMN		=> X_PK1_COLUMN,
	   X_PK2_COLUMN		=> X_PK2_COLUMN,
	   X_PK3_COLUMN		=> X_PK3_COLUMN,
	   X_PK4_COLUMN		=> X_PK4_COLUMN,
	   X_PK5_COLUMN		=> X_PK5_COLUMN,
	   X_USER_ENTITY_NAME	=> X_USER_ENTITY_NAME,
	   X_USER_ENTITY_PROMPT	=> X_USER_ENTITY_PROMPT,
           X_CREATION_DATE      => sysdate,
           X_CREATED_BY         => l_user_id,
           X_LAST_UPDATE_DATE   => sysdate,
           X_LAST_UPDATED_BY    => l_user_id,
           X_LAST_UPDATE_LOGIN  => 0 );
   end;
end LOAD_ROW;

-- Overloaded for BUG 3087292.

procedure LOAD_ROW (
   X_DATA_OBJECT_CODE in varchar2,
   X_APP_SHORT_NAME in varchar2,
   X_TABLE_NAME in varchar2,
   X_ENTITY_NAME in varchar2,
   X_OWNER in varchar2,
   X_PK1_COLUMN in varchar2,
   X_PK2_COLUMN in varchar2,
   X_PK3_COLUMN in varchar2,
   X_PK4_COLUMN in varchar2,
   X_PK5_COLUMN in varchar2,
   X_USER_ENTITY_NAME in varchar2,
   X_USER_ENTITY_PROMPT in varchar2,
   X_LAST_UPDATE_DATE      in      VARCHAR2,
   X_CUSTOM_MODE           in      VARCHAR2)is

   l_user_id           	number := 0 ;
   l_document_entity_id	number := 0 ;
   l_application_id     number := 0 ;
   l_row_id             varchar2(64);
   f_luby    number;  -- entity owner in file
   f_ludate  date;    -- entity update date in file
   db_luby   number;  -- entity owner in db
   db_ludate date;    -- entity update date in db

begin
   -- Translate owner to file_last_updated_by
   f_luby := fnd_load_util.owner_id(x_owner);

   -- Translate char last_update_date to date
   f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);


   -- Get application Id from fnd_application.
   select application_id
    into  l_application_id
    from  fnd_application
    where application_short_name = X_APP_SHORT_NAME;

   begin
        -- Get document entity Id from fnd_document_entities.
        select document_entity_id, application_id,
               LAST_UPDATED_BY, LAST_UPDATE_DATE
          into l_document_entity_id, l_application_id, db_luby, db_ludate
          from fnd_document_entities
          where  data_object_code = X_DATA_OBJECT_CODE ;

       if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                   db_ludate, X_CUSTOM_MODE)) then
         UPDATE_ROW (
  	   X_DOCUMENT_ENTITY_ID	=> l_document_entity_id,
  	   X_DATA_OBJECT_CODE 	=> X_DATA_OBJECT_CODE,
  	   X_APPLICATION_ID	=> l_application_id,
  	   X_TABLE_NAME	=> X_TABLE_NAME,
  	   X_PK1_COLUMN	=> X_PK1_COLUMN,
  	   X_PK2_COLUMN	=> X_PK2_COLUMN,
  	   X_PK3_COLUMN	=> X_PK3_COLUMN,
  	   X_PK4_COLUMN	=> X_PK4_COLUMN,
  	   X_PK5_COLUMN	=> X_PK5_COLUMN,
  	   X_USER_ENTITY_NAME	=> X_USER_ENTITY_NAME,
  	   X_USER_ENTITY_PROMPT	=> X_USER_ENTITY_PROMPT,
  	   X_LAST_UPDATE_DATE	=> f_ludate,
  	   X_LAST_UPDATED_BY	=> f_luby,
  	   X_LAST_UPDATE_LOGIN	=> 0);
       end if;

   exception
     when no_data_found then

        select fnd_document_entities_s.nextval
         into  l_document_entity_id
         from  dual;

         INSERT_ROW (
           X_ROWID              => l_row_id,
           X_DOCUMENT_ENTITY_ID	=> l_document_entity_id,
           X_DATA_OBJECT_CODE	=> X_DATA_OBJECT_CODE,
           X_APPLICATION_ID     => l_application_id,
	   X_TABLE_NAME		=> X_TABLE_NAME,
	   X_PK1_COLUMN		=> X_PK1_COLUMN,
	   X_PK2_COLUMN		=> X_PK2_COLUMN,
	   X_PK3_COLUMN		=> X_PK3_COLUMN,
	   X_PK4_COLUMN		=> X_PK4_COLUMN,
	   X_PK5_COLUMN		=> X_PK5_COLUMN,
	   X_USER_ENTITY_NAME	=> X_USER_ENTITY_NAME,
	   X_USER_ENTITY_PROMPT	=> X_USER_ENTITY_PROMPT,
           X_CREATION_DATE 	=> f_ludate,
 	   X_CREATED_BY		=> f_luby,
           X_LAST_UPDATE_DATE   => f_ludate,
           X_LAST_UPDATED_BY    => f_luby,
           X_LAST_UPDATE_LOGIN  => 0 );
   end;
end LOAD_ROW;

end FND_DOCUMENT_ENTITIES_PKG;

/
