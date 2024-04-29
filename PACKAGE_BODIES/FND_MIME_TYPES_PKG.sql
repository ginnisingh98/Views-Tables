--------------------------------------------------------
--  DDL for Package Body FND_MIME_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_MIME_TYPES_PKG" as
/* $Header: AFCPMMTB.pls 120.3 2006/08/21 09:14:39 pbasha ship $ */

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_FILE_FORMAT_CODE in VARCHAR2,
  X_MIME_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_ALLOW_CLIENT_ENCODING in VARCHAR2
) is
  cursor C is select ROWID from FND_MIME_TYPES_TL
    where FILE_FORMAT_CODE = X_FILE_FORMAT_CODE
    and MIME_TYPE = X_MIME_TYPE
    and LANGUAGE = userenv('LANG')
    ;
begin
  insert into FND_MIME_TYPES_TL (
    DESCRIPTION,
    LAST_UPDATE_LOGIN,
    FILE_FORMAT_CODE,
    MIME_TYPE,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LANGUAGE,
    SOURCE_LANG,
	ALLOW_CLIENT_ENCODING
  ) select
    X_DESCRIPTION,
    X_LAST_UPDATE_LOGIN,
    X_FILE_FORMAT_CODE,
    X_MIME_TYPE,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    L.LANGUAGE_CODE,
    userenv('LANG'),
	X_ALLOW_CLIENT_ENCODING
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from FND_MIME_TYPES_TL T
    where T.FILE_FORMAT_CODE = X_FILE_FORMAT_CODE
    and T.MIME_TYPE = X_MIME_TYPE
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
  X_FILE_FORMAT_CODE in VARCHAR2,
  X_MIME_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c1 is select
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from FND_MIME_TYPES_TL
    where FILE_FORMAT_CODE = X_FILE_FORMAT_CODE
    and MIME_TYPE = X_MIME_TYPE
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of FILE_FORMAT_CODE nowait;
begin
  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.DESCRIPTION = X_DESCRIPTION)
               OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
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
  X_FILE_FORMAT_CODE in VARCHAR2,
  X_MIME_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_ALLOW_CLIENT_ENCODING in VARCHAR2
) is
begin
  update FND_MIME_TYPES_TL set
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG'),
	ALLOW_CLIENT_ENCODING = X_ALLOW_CLIENT_ENCODING
  where FILE_FORMAT_CODE = X_FILE_FORMAT_CODE
  and MIME_TYPE = X_MIME_TYPE
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  -- Since we are only using the TL table, we have to
  -- make sure that ALLOW_CLIENT_ENCODING is updated for
  -- all languages.
  -- (This column should not be in a TL table)
  -- Bug 4171265
  update FND_MIME_TYPES_TL SET
    ALLOW_CLIENT_ENCODING = X_ALLOW_CLIENT_ENCODING
    where FILE_FORMAT_CODE = X_FILE_FORMAT_CODE
    and MIME_TYPE = X_MIME_type;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_FILE_FORMAT_CODE in VARCHAR2,
  X_MIME_TYPE in VARCHAR2
) is
begin
  delete from FND_MIME_TYPES_TL
  where FILE_FORMAT_CODE = X_FILE_FORMAT_CODE
  and MIME_TYPE = X_MIME_TYPE;

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

  update FND_MIME_TYPES_TL T set (
      DESCRIPTION
    ) = (select
      B.DESCRIPTION
    from FND_MIME_TYPES_TL B
    where B.FILE_FORMAT_CODE = T.FILE_FORMAT_CODE
    and B.MIME_TYPE = T.MIME_TYPE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.FILE_FORMAT_CODE,
      T.MIME_TYPE,
      T.LANGUAGE
  ) in (select
      SUBT.FILE_FORMAT_CODE,
      SUBT.MIME_TYPE,
      SUBT.LANGUAGE
    from FND_MIME_TYPES_TL SUBB, FND_MIME_TYPES_TL SUBT
    where SUBB.FILE_FORMAT_CODE = SUBT.FILE_FORMAT_CODE
    and SUBB.MIME_TYPE = SUBT.MIME_TYPE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));
*/

  insert into FND_MIME_TYPES_TL (
    DESCRIPTION,
    LAST_UPDATE_LOGIN,
    FILE_FORMAT_CODE,
    MIME_TYPE,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LANGUAGE,
    SOURCE_LANG,
    ALLOW_CLIENT_ENCODING
  ) select
    B.DESCRIPTION,
    B.LAST_UPDATE_LOGIN,
    B.FILE_FORMAT_CODE,
    B.MIME_TYPE,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG,
    B.ALLOW_CLIENT_ENCODING
  from FND_MIME_TYPES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from FND_MIME_TYPES_TL T
    where T.FILE_FORMAT_CODE = B.FILE_FORMAT_CODE
    and T.MIME_TYPE = B.MIME_TYPE
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure LOAD_ROW (
  X_FILE_FORMAT_CODE		in VARCHAR2,
  X_MIME_TYPE			in VARCHAR2,
  X_OWNER			in VARCHAR2,
  X_DESCRIPTION 		in VARCHAR2) is

begin
 fnd_mime_types_pkg.load_row(
	x_file_format_code => x_file_format_code,
	x_mime_type => x_mime_type,
      x_owner => x_owner,
      x_description => x_description,
      x_last_update_date =>null,
      x_custom_mode => null,
	  x_allow_client_encoding => null);

end LOAD_ROW;

procedure TRANSLATE_ROW
  (X_FILE_FORMAT_CODE		in VARCHAR2,
   X_MIME_TYPE 			in VARCHAR2,
   X_OWNER			in VARCHAR2,
   X_DESCRIPTION		in VARCHAR2) is
begin

 fnd_mime_types_pkg.translate_row(
	x_file_format_code => x_file_format_code,
    	x_mime_type => x_mime_type,
	x_owner => x_owner,
	x_description => x_description,
	x_last_update_date => null,
        x_custom_mode => null);

end TRANSLATE_ROW;
--
-- ### OVERLOADED!
--
procedure TRANSLATE_ROW
  (X_FILE_FORMAT_CODE           in VARCHAR2,
   X_MIME_TYPE                  in VARCHAR2,
   X_OWNER                      in VARCHAR2,
   X_DESCRIPTION                in VARCHAR2,
   X_LAST_UPDATE_DATE		  in VARCHAR2,
   X_CUSTOM_MODE			  in VARCHAR2)
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
  from fnd_mime_types_tl
  where file_format_code  = X_FILE_FORMAT_CODE
  and mime_type   	  = X_MIME_TYPE
  and language            = userenv('LANG');

  if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                db_ludate, X_CUSTOM_MODE)) then

    update fnd_mime_types_tl set
      description         = nvl(X_DESCRIPTION, description),
      source_lang         = userenv('LANG'),
      last_updated_by     = f_luby,
      last_update_date    = f_ludate,
      last_update_login   = 0
    where file_format_code = X_FILE_FORMAT_CODE
    and   mime_type = X_MIME_TYPE
    and   userenv('LANG') in (language, source_lang);
  end if;

end TRANSLATE_ROW;
--
--OVERLOADED!!!
--
procedure LOAD_ROW (
  X_FILE_FORMAT_CODE		in VARCHAR2,
  X_MIME_TYPE			in VARCHAR2,
  X_OWNER			in VARCHAR2,
  X_DESCRIPTION 		in VARCHAR2,
  X_LAST_UPDATE_DATE    in VARCHAR2,
  X_CUSTOM_MODE         in VARCHAR2,
  X_ALLOW_CLIENT_ENCODING in VARCHAR2)
 is
  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db
  row_id varchar2(64);
begin

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

 begin

  select last_updated_by, last_update_date
  into db_luby, db_ludate
  from fnd_mime_types_tl
  where file_format_code  = X_FILE_FORMAT_CODE
  and mime_type   	  = X_MIME_TYPE
  and language            = userenv('LANG');

  if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                    db_ludate, X_CUSTOM_MODE)) then

    fnd_mime_types_pkg.UPDATE_ROW (
      X_FILE_FORMAT_CODE =>	X_FILE_FORMAT_CODE,
      X_MIME_TYPE =>		X_MIME_TYPE,
      X_DESCRIPTION =>		X_DESCRIPTION,
      X_LAST_UPDATE_DATE =>	f_ludate,
      X_LAST_UPDATED_BY =>	f_luby,
      X_LAST_UPDATE_LOGIN =>	0,
	  X_ALLOW_CLIENT_ENCODING => X_ALLOW_CLIENT_ENCODING);
    end if;

    exception
      when NO_DATA_FOUND then

        fnd_mime_types_pkg.INSERT_ROW (
  	  X_ROWID =>		 row_id,
	  X_FILE_FORMAT_CODE =>  X_FILE_FORMAT_CODE,
  	  X_MIME_TYPE =>	 X_MIME_TYPE,
	  X_DESCRIPTION =>	 X_DESCRIPTION,
	  X_CREATION_DATE =>	 f_ludate,
	  X_CREATED_BY =>	 f_luby,
	  X_LAST_UPDATE_DATE =>	 f_ludate,
	  X_LAST_UPDATED_BY =>	 f_luby,
	  X_LAST_UPDATE_LOGIN => 0,
	  X_ALLOW_CLIENT_ENCODING => X_ALLOW_CLIENT_ENCODING);
end;
end LOAD_ROW;

end FND_MIME_TYPES_PKG;

/
