--------------------------------------------------------
--  DDL for Package Body FND_DEBUG_OPTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_DEBUG_OPTIONS_PKG" as
-- $Header: AFOAMDOB.pls 120.1 2005/07/02 03:02:36 appldev noship $



    procedure LOAD_ROW (
                     X_DEBUG_OPTION_NAME in VARCHAR2,
                    X_ENABLED_FLAG in VARCHAR2,
                    X_TYPE in VARCHAR2,
                    X_SEPARATOR in VARCHAR2,
                    X_TRACE_FILE_TOKEN in VARCHAR2,
                    X_DESCRIPTION in VARCHAR2,
                     X_OWNER in VARCHAR2


           ) is
          begin
           FND_DEBUG_OPTIONS_PKG.LOAD_ROW (
        X_DEBUG_OPTION_NAME => X_DEBUG_OPTION_NAME,
        X_ENABLED_FLAG => X_ENABLED_FLAG,
        X_TYPE => X_TYPE,
        X_SEPARATOR=> X_SEPARATOR,
        X_TRACE_FILE_TOKEN => X_TRACE_FILE_TOKEN,
        X_DESCRIPTION=>X_DESCRIPTION,
        X_OWNER=>X_OWNER,
        x_custom_mode => '',
        x_last_update_date => '');

          end;

   procedure LOAD_ROW (
    X_DEBUG_OPTION_NAME in VARCHAR2,
          X_ENABLED_FLAG in VARCHAR2,
          X_TYPE in VARCHAR2,
          X_SEPARATOR in VARCHAR2,
          X_TRACE_FILE_TOKEN in VARCHAR2,
          X_DESCRIPTION in VARCHAR2,
    x_custom_mode         in      varchar2,
    x_last_update_date    in      varchar2,
    X_OWNER               in         VARCHAR2)is


       f_luby    number;  -- entity owner in file
       f_ludate  date;    -- entity update date in file
       db_luby   number:=0;  -- entity owner in db
       db_ludate date:=null;    -- entity update date in db
       row_id varchar2(64);

     begin


       -- Translate owner to file_last_updated_by
       f_luby := fnd_load_util.owner_id(x_owner);

       -- Translate char last_update_date to date
       f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);




       begin



       if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                   db_ludate, X_CUSTOM_MODE)) then


         FND_DEBUG_OPTIONS_PKG.UPDATE_ROW (
           X_DEBUG_OPTION_NAME =>X_DEBUG_OPTION_NAME,
           X_ENABLED_FLAG => X_ENABLED_FLAG,
           X_TYPE => X_TYPE,
           X_SEPARATOR => X_SEPARATOR,
                     X_TRACE_FILE_TOKEN => X_TRACE_FILE_TOKEN,
           X_DESCRIPTION=>X_DESCRIPTION,
           X_LAST_UPDATE_DATE => f_ludate,
           X_LAST_UPDATED_BY => f_luby,
           X_LAST_UPDATE_LOGIN => 0
           );


         end if;
       exception
         when NO_DATA_FOUND then

         FND_DEBUG_OPTIONS_PKG.INSERT_ROW (
           X_ROWID => row_id,
           X_DEBUG_OPTION_NAME =>X_DEBUG_OPTION_NAME,
           X_ENABLED_FLAG => X_ENABLED_FLAG,
           X_TYPE => X_TYPE,
           X_SEPARATOR => X_SEPARATOR,
                     X_TRACE_FILE_TOKEN => X_TRACE_FILE_TOKEN,
            X_DESCRIPTION=>X_DESCRIPTION,
           X_CREATION_DATE => f_ludate,
           X_CREATED_BY => f_luby,
           X_LAST_UPDATE_DATE => f_ludate,
           X_LAST_UPDATED_BY => f_luby,
           X_LAST_UPDATE_LOGIN => 0 );
     end;
   end LOAD_ROW;

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_DEBUG_OPTION_NAME in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_TYPE in VARCHAR2,
  X_SEPARATOR in VARCHAR2,
  X_TRACE_FILE_TOKEN in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from FND_DEBUG_OPTIONS
    where DEBUG_OPTION_NAME = X_DEBUG_OPTION_NAME
    ;
begin



  insert into FND_DEBUG_OPTIONS (
    DEBUG_OPTION_NAME,
    ENABLED_FLAG,
    TYPE,
    SEPARATOR,
    TRACE_FILE_TOKEN,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_DEBUG_OPTION_NAME,
    X_ENABLED_FLAG,
    X_TYPE,
    X_SEPARATOR,
    X_TRACE_FILE_TOKEN,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into FND_DEBUG_OPTIONS_TL (
    DEBUG_OPTION_NAME,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_DEBUG_OPTION_NAME,
    X_DESCRIPTION,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from FND_DEBUG_OPTIONS_TL T
    where T.DEBUG_OPTION_NAME = X_DEBUG_OPTION_NAME
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure UPDATE_ROW (
  X_DEBUG_OPTION_NAME in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_TYPE in VARCHAR2,
  X_SEPARATOR in VARCHAR2,
  X_TRACE_FILE_TOKEN in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update FND_DEBUG_OPTIONS set
    ENABLED_FLAG = X_ENABLED_FLAG,
    TYPE = X_TYPE,
    SEPARATOR = X_SEPARATOR,
    TRACE_FILE_TOKEN = X_TRACE_FILE_TOKEN,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where DEBUG_OPTION_NAME = X_DEBUG_OPTION_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update FND_DEBUG_OPTIONS_TL set
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where DEBUG_OPTION_NAME = X_DEBUG_OPTION_NAME
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;


procedure ADD_LANGUAGE
is
begin
  delete from FND_DEBUG_OPTIONS_TL T
  where not exists
    (select NULL
    from FND_DEBUG_OPTIONS B
    where B.DEBUG_OPTION_NAME = T.DEBUG_OPTION_NAME
    );

  update FND_DEBUG_OPTIONS_TL T set (
      DESCRIPTION
    ) = (select
      B.DESCRIPTION
    from FND_DEBUG_OPTIONS_TL B
    where B.DEBUG_OPTION_NAME = T.DEBUG_OPTION_NAME
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.DEBUG_OPTION_NAME,
      T.LANGUAGE
  ) in (select
      SUBT.DEBUG_OPTION_NAME,
      SUBT.LANGUAGE
    from FND_DEBUG_OPTIONS_TL SUBB, FND_DEBUG_OPTIONS_TL SUBT
    where SUBB.DEBUG_OPTION_NAME = SUBT.DEBUG_OPTION_NAME
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DESCRIPTION <> SUBT.DESCRIPTION
  ));

  insert into FND_DEBUG_OPTIONS_TL (
    DEBUG_OPTION_NAME,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.DEBUG_OPTION_NAME,
    B.DESCRIPTION,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from FND_DEBUG_OPTIONS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from FND_DEBUG_OPTIONS_TL T
    where T.DEBUG_OPTION_NAME = B.DEBUG_OPTION_NAME
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;


procedure DELETE_ROW (
  X_DEBUG_OPTION_NAME in VARCHAR2
) is
begin
  delete from FND_DEBUG_OPTIONS_TL
  where DEBUG_OPTION_NAME = X_DEBUG_OPTION_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from FND_DEBUG_OPTIONS
  where DEBUG_OPTION_NAME = X_DEBUG_OPTION_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;


procedure LOCK_ROW (
  X_DEBUG_OPTION_NAME in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_TYPE in VARCHAR2,
  X_SEPARATOR in VARCHAR2,
  X_TRACE_FILE_TOKEN in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      ENABLED_FLAG,
      TYPE,
      SEPARATOR,
      TRACE_FILE_TOKEN
    from FND_DEBUG_OPTIONS
    where DEBUG_OPTION_NAME = X_DEBUG_OPTION_NAME
    for update of DEBUG_OPTION_NAME nowait;
  recinfo c%rowtype;

  cursor c1 is select
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from FND_DEBUG_OPTIONS_TL
    where DEBUG_OPTION_NAME = X_DEBUG_OPTION_NAME
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of DEBUG_OPTION_NAME nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.ENABLED_FLAG = X_ENABLED_FLAG)
      AND (recinfo.TYPE = X_TYPE)
      AND (recinfo.SEPARATOR = X_SEPARATOR)
      AND ((recinfo.TRACE_FILE_TOKEN = X_TRACE_FILE_TOKEN)
           OR ((recinfo.TRACE_FILE_TOKEN is null) AND (X_TRACE_FILE_TOKEN is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.DESCRIPTION = X_DESCRIPTION)
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







   procedure TRANSLATE_ROW (
     X_DEBUG_OPTION_NAME in VARCHAR2,
     X_OWNER                     in         VARCHAR2,
     X_DESCRIPTION in VARCHAR2) is
   begin

   FND_DEBUG_OPTIONS_PKG.translate_row(
     X_DEBUG_OPTION_NAME => X_DEBUG_OPTION_NAME,
     X_OWNER=>X_OWNER,
     X_DESCRIPTION=>X_DESCRIPTION,
     x_custom_mode => '',
     x_last_update_date => '');

   end TRANSLATE_ROW;





procedure TRANSLATE_ROW (
     X_DEBUG_OPTION_NAME in VARCHAR2,
     X_OWNER in VARCHAR2,
     X_DESCRIPTION in VARCHAR2,
     X_CUSTOM_MODE in VARCHAR2,
     X_LAST_UPDATE_DATE         in VARCHAR2) is

       f_luby    number;  -- entity owner in file
       f_ludate  date;    -- entity update date in file
       db_luby   number:=0;  -- entity owner in db
       db_ludate date:=null;    -- entity update date in db

   begin

     -- Translate owner to file_last_updated_by
     f_luby := fnd_load_util.owner_id(x_owner);

     -- Translate char last_update_date to date
     f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

     begin

       if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                   db_ludate, X_CUSTOM_MODE)) then

       update fnd_debug_options_tl set
                   DESCRIPTION=nvl(X_DESCRIPTION,DESCRIPTION),
                   SOURCE_LANG=userenv('LANG'),
           last_update_date    = f_ludate,
           last_updated_by     = f_luby,
           last_update_login   = 0
        where debug_option_name=X_DEBUG_OPTION_NAME  and userenv('LANG') in (language, source_lang);

       end if;
     exception
       when no_data_found then
         null;
     end;

   end TRANSLATE_ROW;


end FND_DEBUG_OPTIONS_PKG;

/
