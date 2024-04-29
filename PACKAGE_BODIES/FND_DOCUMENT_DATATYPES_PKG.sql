--------------------------------------------------------
--  DDL for Package Body FND_DOCUMENT_DATATYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_DOCUMENT_DATATYPES_PKG" as
/* $Header: AFAKDTPB.pls 115.15 2004/05/27 21:07:41 blash ship $ */


procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_DATATYPE_ID in NUMBER,
  X_LANGUAGE in VARCHAR2,
  X_NAME in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_USER_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
)is
  cursor C is select ROWID from FND_DOCUMENT_DATATYPES
    where DATATYPE_ID = X_DATATYPE_ID
    and LANGUAGE = X_LANGUAGE
    and NAME = X_NAME
    and LANGUAGE = userenv('LANG');
begin
  insert into FND_DOCUMENT_DATATYPES (
    DATATYPE_ID,
    NAME,
    USER_NAME,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    START_DATE_ACTIVE,
    END_DATE_ACTIVE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_DATATYPE_ID,
    X_NAME,
    X_USER_NAME,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_START_DATE_ACTIVE,
    X_END_DATE_ACTIVE,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from FND_DOCUMENT_DATATYPES T
    where T.DATATYPE_ID = X_DATATYPE_ID
    and T.LANGUAGE = X_LANGUAGE
    and T.NAME = X_NAME
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
  X_DATATYPE_ID in NUMBER,
  X_LANGUAGE in VARCHAR2,
  X_NAME in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_USER_NAME in VARCHAR2
) is
  cursor c1 is select
      START_DATE_ACTIVE,
      END_DATE_ACTIVE,
      USER_NAME
    from FND_DOCUMENT_DATATYPES
    where DATATYPE_ID = X_DATATYPE_ID
    and LANGUAGE = X_LANGUAGE
    and NAME = X_NAME
    and LANGUAGE = userenv('LANG')
    for update of DATATYPE_ID nowait;
  tlinfo c1%rowtype;

begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    close c1;
    return;
  end if;
  close c1;

  if (    (tlinfo.USER_NAME = X_USER_NAME)
      AND ((tlinfo.START_DATE_ACTIVE = X_START_DATE_ACTIVE)
           OR ((tlinfo.START_DATE_ACTIVE is null) AND (X_START_DATE_ACTIVE is null)))
      AND ((tlinfo.END_DATE_ACTIVE = X_END_DATE_ACTIVE)
           OR ((tlinfo.END_DATE_ACTIVE is null) AND (X_END_DATE_ACTIVE is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_DATATYPE_ID in NUMBER,
  X_LANGUAGE in VARCHAR2,
  X_NAME in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_USER_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update FND_DOCUMENT_DATATYPES set
    START_DATE_ACTIVE = X_START_DATE_ACTIVE,
    END_DATE_ACTIVE = X_END_DATE_ACTIVE,
    USER_NAME = X_USER_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where DATATYPE_ID = X_DATATYPE_ID
  and LANGUAGE = X_LANGUAGE
  and NAME = X_NAME
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_DATATYPE_ID in NUMBER,
  X_LANGUAGE in VARCHAR2,
  X_NAME in VARCHAR2
) is
begin
  delete from FND_DOCUMENT_DATATYPES
  where DATATYPE_ID = X_DATATYPE_ID
  and LANGUAGE = X_LANGUAGE
  and NAME = X_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin

/* Mar/19/03 requested by Ric Ginsberg */
/* The following update statements are commented out */
/* as a quick workaround to fix the time-consuming table handler issue */
/* Eventually we'll need to turn them into a separate fix_language procedure */
/*

  update FND_DOCUMENT_DATATYPES T set (
      USER_NAME
    ) = (select
      B.USER_NAME
    from FND_DOCUMENT_DATATYPES B
    where B.DATATYPE_ID = T.DATATYPE_ID
    and B.NAME = T.NAME
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.DATATYPE_ID,
      T.NAME,
      T.LANGUAGE
  ) in (select
      SUBT.DATATYPE_ID,
      SUBT.NAME,
      SUBT.LANGUAGE
    from FND_DOCUMENT_DATATYPES SUBB, FND_DOCUMENT_DATATYPES SUBT
    where SUBB.DATATYPE_ID = SUBT.DATATYPE_ID
    and SUBB.NAME = SUBT.NAME
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.USER_NAME <> SUBT.USER_NAME
  ));
*/

  insert into FND_DOCUMENT_DATATYPES (
    DATATYPE_ID,
    NAME,
    USER_NAME,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    START_DATE_ACTIVE,
    END_DATE_ACTIVE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.DATATYPE_ID,
    B.NAME,
    B.USER_NAME,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.START_DATE_ACTIVE,
    B.END_DATE_ACTIVE,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from FND_DOCUMENT_DATATYPES B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from FND_DOCUMENT_DATATYPES T
    where T.DATATYPE_ID = B.DATATYPE_ID
    and T.NAME = B.NAME
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure TRANSLATE_ROW (
  X_DATATYPE_ID	in	VARCHAR2,
  X_NAME	in	VARCHAR2,
  X_USER_NAME	in	VARCHAR2,
  X_OWNER	in	VARCHAR2) IS
begin

  update fnd_document_datatypes set
    user_name = nvl(X_USER_NAME,user_name),
    last_update_date  = sysdate,
    last_updated_by   = decode(X_OWNER, 'SEED', 1, 0),
    last_update_login = 0,
    source_lang       = userenv('LANG')
  where name = X_NAME
   and  datatype_id = to_number(X_DATATYPE_ID)
   and  userenv('LANG') in (language, source_lang);

end TRANSLATE_ROW;

-- Overloaded for BUG 3087292.
procedure TRANSLATE_ROW (
  X_DATATYPE_ID	in	VARCHAR2,
  X_NAME	in	VARCHAR2,
  X_USER_NAME	in	VARCHAR2,
  X_OWNER	in	VARCHAR2,
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
  from fnd_document_datatypes
  where name = X_NAME
  and  datatype_id = to_number(X_DATATYPE_ID)
  and LANGUAGE = userenv('LANG');

  if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                   db_ludate, X_CUSTOM_MODE)) then
    update fnd_document_datatypes set
      user_name = nvl(X_USER_NAME,user_name),
      last_update_date  = f_ludate,
      last_updated_by   = f_luby,
      last_update_login = 0,
      source_lang       = userenv('LANG')
    where name = X_NAME
    and  datatype_id = to_number(X_DATATYPE_ID)
    and  userenv('LANG') in (language, source_lang);
  end if;

end TRANSLATE_ROW;

procedure LOAD_ROW (
  X_DATATYPE_ID	in	VARCHAR2,
  X_NAME	in	VARCHAR2,
  X_OWNER	in	VARCHAR2,
  X_START_DATE_ACTIVE	in	VARCHAR2,
  X_END_DATE_ACTIVE	in	VARCHAR2,
  X_USER_NAME	in	VARCHAR2)
IS
    l_user_id	number := 0 ;
    l_row_id	varchar2(64);

begin

  if (X_OWNER = 'SEED') then
     l_user_id := 1;
  end if;

  UPDATE_ROW (
    X_DATATYPE_ID	=> to_number(X_DATATYPE_ID),
    X_LANGUAGE		=> userenv('LANG'),
    X_NAME		=> X_NAME,
    X_START_DATE_ACTIVE	=> to_date(X_START_DATE_ACTIVE, 'YYYY/MM/DD'),
    X_END_DATE_ACTIVE	=> to_date(X_END_DATE_ACTIVE, 'YYYY/MM/DD'),
    X_USER_NAME		=> X_USER_NAME,
    X_LAST_UPDATE_DATE	=> sysdate,
    X_LAST_UPDATED_BY	=> l_user_id,
    X_LAST_UPDATE_LOGIN	=> 0 );

exception
  when NO_DATA_FOUND then

  INSERT_ROW (
    X_ROWID		=> l_row_id,
    X_DATATYPE_ID	=> to_number(X_DATATYPE_ID),
    X_LANGUAGE		=> userenv('LANG'),
    X_NAME		=> X_NAME,
    X_START_DATE_ACTIVE	=> to_date(X_START_DATE_ACTIVE, 'YYYY/MM/DD'),
    X_END_DATE_ACTIVE	=> to_date(X_END_DATE_ACTIVE, 'YYYY/MM/DD'),
    X_USER_NAME		=> X_USER_NAME,
    X_CREATION_DATE	=> sysdate,
    X_CREATED_BY		=> l_user_id,
    X_LAST_UPDATE_DATE	=> sysdate,
    X_LAST_UPDATED_BY	=> l_user_id,
    X_LAST_UPDATE_LOGIN	=> 0);

end LOAD_ROW;

-- Overloaded for BUG 3087292.
procedure LOAD_ROW (
  X_DATATYPE_ID	in	VARCHAR2,
  X_NAME	in	VARCHAR2,
  X_OWNER	in	VARCHAR2,
  X_START_DATE_ACTIVE	in	VARCHAR2,
  X_END_DATE_ACTIVE	in	VARCHAR2,
  X_USER_NAME	in	VARCHAR2,
  X_LAST_UPDATE_DATE      in      VARCHAR2,
  X_CUSTOM_MODE           in      VARCHAR2)
IS
    l_user_id	number := 0 ;
    l_row_id	varchar2(64);
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
  from fnd_document_datatypes
  where name = X_NAME
  and language = userenv('LANG')
  and  datatype_id = to_number(X_DATATYPE_ID);

  if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                   db_ludate, X_CUSTOM_MODE)) then
    UPDATE_ROW (
      X_DATATYPE_ID	=> to_number(X_DATATYPE_ID),
      X_LANGUAGE		=> userenv('LANG'),
      X_NAME		=> X_NAME,
      X_START_DATE_ACTIVE	=> to_date(X_START_DATE_ACTIVE, 'YYYY/MM/DD'),
      X_END_DATE_ACTIVE	=> to_date(X_END_DATE_ACTIVE, 'YYYY/MM/DD'),
      X_USER_NAME		=> X_USER_NAME,
      X_LAST_UPDATE_DATE	=> f_ludate,
      X_LAST_UPDATED_BY	=>  f_luby,
      X_LAST_UPDATE_LOGIN	=> 0 );
  end if;

exception
  when NO_DATA_FOUND then

  INSERT_ROW (
    X_ROWID		=> l_row_id,
    X_DATATYPE_ID	=> to_number(X_DATATYPE_ID),
    X_LANGUAGE		=> userenv('LANG'),
    X_NAME		=> X_NAME,
    X_START_DATE_ACTIVE	=> to_date(X_START_DATE_ACTIVE, 'YYYY/MM/DD'),
    X_END_DATE_ACTIVE	=> to_date(X_END_DATE_ACTIVE, 'YYYY/MM/DD'),
    X_USER_NAME		=> X_USER_NAME,
    X_CREATION_DATE 	=> f_ludate,
    X_CREATED_BY	=> f_luby,
    X_LAST_UPDATE_DATE   => f_ludate,
    X_LAST_UPDATED_BY    => f_luby,
    X_LAST_UPDATE_LOGIN	=> 0);

end LOAD_ROW;

end FND_DOCUMENT_DATATYPES_PKG;

/
