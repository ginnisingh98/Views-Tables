--------------------------------------------------------
--  DDL for Package Body FND_OBJECTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_OBJECTS_PKG" as
/* $Header: AFSCOBJB.pls 120.2 2005/10/27 18:21:01 tmorrow ship $ */

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_OBJECT_ID in NUMBER,
  X_OBJ_NAME in VARCHAR2,
  X_PK1_COLUMN_NAME in VARCHAR2,
  X_PK2_COLUMN_NAME in VARCHAR2,
  X_PK3_COLUMN_NAME in VARCHAR2,
  X_PK4_COLUMN_NAME in VARCHAR2,
  X_PK5_COLUMN_NAME in VARCHAR2,
  X_PK1_COLUMN_TYPE in VARCHAR2,
  X_PK2_COLUMN_TYPE in VARCHAR2,
  X_PK3_COLUMN_TYPE in VARCHAR2,
  X_PK4_COLUMN_TYPE in VARCHAR2,
  X_PK5_COLUMN_TYPE in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_DATABASE_OBJECT_NAME in VARCHAR2,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from FND_OBJECTS
    where OBJECT_ID = X_OBJECT_ID
    ;
begin
  insert into FND_OBJECTS (
    PK4_COLUMN_TYPE,
    PK5_COLUMN_TYPE,
    PK1_COLUMN_TYPE,
    PK2_COLUMN_TYPE,
    PK3_COLUMN_TYPE,
    OBJECT_ID,
    OBJ_NAME,
    APPLICATION_ID,
    DATABASE_OBJECT_NAME,
    PK1_COLUMN_NAME,
    PK2_COLUMN_NAME,
    PK3_COLUMN_NAME,
    PK4_COLUMN_NAME,
    PK5_COLUMN_NAME,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_PK4_COLUMN_TYPE,
    X_PK5_COLUMN_TYPE,
    X_PK1_COLUMN_TYPE,
    X_PK2_COLUMN_TYPE,
    X_PK3_COLUMN_TYPE,
    X_OBJECT_ID,
    X_OBJ_NAME,
    X_APPLICATION_ID,
    X_DATABASE_OBJECT_NAME,
    X_PK1_COLUMN_NAME,
    X_PK2_COLUMN_NAME,
    X_PK3_COLUMN_NAME,
    X_PK4_COLUMN_NAME,
    X_PK5_COLUMN_NAME,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into FND_OBJECTS_TL (
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    OBJECT_ID,
    DISPLAY_NAME,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    X_OBJECT_ID,
    X_DISPLAY_NAME,
    X_DESCRIPTION,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from FND_OBJECTS_TL T
    where T.OBJECT_ID = X_OBJECT_ID
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
  X_OBJECT_ID in NUMBER,
  X_OBJ_NAME in VARCHAR2,
  X_PK1_COLUMN_NAME in VARCHAR2,
  X_PK2_COLUMN_NAME in VARCHAR2,
  X_PK3_COLUMN_NAME in VARCHAR2,
  X_PK4_COLUMN_NAME in VARCHAR2,
  X_PK5_COLUMN_NAME in VARCHAR2,
  X_PK1_COLUMN_TYPE in VARCHAR2,
  X_PK2_COLUMN_TYPE in VARCHAR2,
  X_PK3_COLUMN_TYPE in VARCHAR2,
  X_PK4_COLUMN_TYPE in VARCHAR2,
  X_PK5_COLUMN_TYPE in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_DATABASE_OBJECT_NAME in VARCHAR2,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      PK4_COLUMN_TYPE,
      PK5_COLUMN_TYPE,
      PK1_COLUMN_TYPE,
      PK2_COLUMN_TYPE,
      PK3_COLUMN_TYPE,
      OBJ_NAME,
      APPLICATION_ID,
      DATABASE_OBJECT_NAME,
      PK1_COLUMN_NAME,
      PK2_COLUMN_NAME,
      PK3_COLUMN_NAME,
      PK4_COLUMN_NAME,
      PK5_COLUMN_NAME
    from FND_OBJECTS
    where OBJECT_ID = X_OBJECT_ID
    for update of OBJECT_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      DISPLAY_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from FND_OBJECTS_TL
    where OBJECT_ID = X_OBJECT_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of OBJECT_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.PK4_COLUMN_TYPE = X_PK4_COLUMN_TYPE) OR
          ((recinfo.PK4_COLUMN_TYPE IS NULL) AND (X_PK4_COLUMN_TYPE IS NULL)))
      AND ((recinfo.PK5_COLUMN_TYPE = X_PK5_COLUMN_TYPE) OR
          ((recinfo.PK5_COLUMN_TYPE IS NULL) AND (X_PK5_COLUMN_TYPE IS NULL)))
      AND (recinfo.PK1_COLUMN_TYPE = X_PK1_COLUMN_TYPE)
      AND ((recinfo.PK2_COLUMN_TYPE = X_PK2_COLUMN_TYPE) OR
          ((recinfo.PK2_COLUMN_TYPE IS NULL) AND (X_PK2_COLUMN_TYPE IS NULL)))
      AND ((recinfo.PK3_COLUMN_TYPE = X_PK3_COLUMN_TYPE) OR
          ((recinfo.PK3_COLUMN_TYPE IS NULL) AND (X_PK3_COLUMN_TYPE IS NULL)))
      AND (recinfo.OBJ_NAME = X_OBJ_NAME)
      AND (recinfo.APPLICATION_ID = X_APPLICATION_ID)
      AND (recinfo.DATABASE_OBJECT_NAME = X_DATABASE_OBJECT_NAME)
      AND (recinfo.PK1_COLUMN_NAME = X_PK1_COLUMN_NAME)
      AND ((recinfo.PK2_COLUMN_NAME = X_PK2_COLUMN_NAME) OR
          ((recinfo.PK2_COLUMN_NAME IS NULL) AND (X_PK2_COLUMN_NAME IS NULL)))
      AND ((recinfo.PK3_COLUMN_NAME = X_PK3_COLUMN_NAME) OR
          ((recinfo.PK3_COLUMN_NAME IS NULL) AND (X_PK3_COLUMN_NAME IS NULL)))
      AND ((recinfo.PK4_COLUMN_NAME = X_PK4_COLUMN_NAME) OR
          ((recinfo.PK4_COLUMN_NAME IS NULL) AND (X_PK4_COLUMN_NAME IS NULL)))
      AND ((recinfo.PK5_COLUMN_NAME = X_PK5_COLUMN_NAME) OR
          ((recinfo.PK5_COLUMN_NAME IS NULL) AND (X_PK5_COLUMN_NAME IS NULL)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.DISPLAY_NAME = X_DISPLAY_NAME)
          AND (tlinfo.DESCRIPTION = X_DESCRIPTION)
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
  X_OBJECT_ID in NUMBER,
  X_OBJ_NAME in VARCHAR2,
  X_PK1_COLUMN_NAME in VARCHAR2,
  X_PK2_COLUMN_NAME in VARCHAR2,
  X_PK3_COLUMN_NAME in VARCHAR2,
  X_PK4_COLUMN_NAME in VARCHAR2,
  X_PK5_COLUMN_NAME in VARCHAR2,
  X_PK1_COLUMN_TYPE in VARCHAR2,
  X_PK2_COLUMN_TYPE in VARCHAR2,
  X_PK3_COLUMN_TYPE in VARCHAR2,
  X_PK4_COLUMN_TYPE in VARCHAR2,
  X_PK5_COLUMN_TYPE in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_DATABASE_OBJECT_NAME in VARCHAR2,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update FND_OBJECTS set
    PK4_COLUMN_TYPE = X_PK4_COLUMN_TYPE,
    PK5_COLUMN_TYPE = X_PK5_COLUMN_TYPE,
    PK1_COLUMN_TYPE = X_PK1_COLUMN_TYPE,
    PK2_COLUMN_TYPE = X_PK2_COLUMN_TYPE,
    PK3_COLUMN_TYPE = X_PK3_COLUMN_TYPE,
    APPLICATION_ID = X_APPLICATION_ID,
    DATABASE_OBJECT_NAME = X_DATABASE_OBJECT_NAME,
    PK1_COLUMN_NAME = X_PK1_COLUMN_NAME,
    PK2_COLUMN_NAME = X_PK2_COLUMN_NAME,
    PK3_COLUMN_NAME = X_PK3_COLUMN_NAME,
    PK4_COLUMN_NAME = X_PK4_COLUMN_NAME,
    PK5_COLUMN_NAME = X_PK5_COLUMN_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where OBJECT_ID = X_OBJECT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update FND_OBJECTS_TL set
    DISPLAY_NAME = X_DISPLAY_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where OBJECT_ID = X_OBJECT_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

/* Overloaded version below */
procedure LOAD_ROW (
  X_OBJ_NAME      	in VARCHAR2,
  X_OWNER 		in VARCHAR2,
  X_PK1_COLUMN_NAME	in VARCHAR2,
  X_PK2_COLUMN_NAME	in VARCHAR2,
  X_PK3_COLUMN_NAME	in VARCHAR2,
  X_PK4_COLUMN_NAME	in VARCHAR2,
  X_PK5_COLUMN_NAME	in VARCHAR2,
  X_PK1_COLUMN_TYPE	in VARCHAR2,
  X_PK2_COLUMN_TYPE	in VARCHAR2,
  X_PK3_COLUMN_TYPE	in VARCHAR2,
  X_PK4_COLUMN_TYPE	in VARCHAR2,
  X_PK5_COLUMN_TYPE	in VARCHAR2,
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_DATABASE_OBJECT_NAME in VARCHAR2,
  X_DISPLAY_NAME        in VARCHAR2,
  X_DESCRIPTION         in VARCHAR2,
  X_CUSTOM_MODE         in VARCHAR2
) is
begin
  fnd_objects_pkg.LOAD_ROW (
    X_OBJ_NAME      	=> X_OBJ_NAME,
    X_OWNER 		=> X_OWNER,
    X_PK1_COLUMN_NAME	=> X_PK1_COLUMN_NAME,
    X_PK2_COLUMN_NAME	=> X_PK2_COLUMN_NAME,
    X_PK3_COLUMN_NAME	=> X_PK3_COLUMN_NAME,
    X_PK4_COLUMN_NAME	=> X_PK4_COLUMN_NAME,
    X_PK5_COLUMN_NAME	=> X_PK5_COLUMN_NAME,
    X_PK1_COLUMN_TYPE	=> X_PK1_COLUMN_TYPE,
    X_PK2_COLUMN_TYPE	=> X_PK2_COLUMN_TYPE,
    X_PK3_COLUMN_TYPE	=> X_PK3_COLUMN_TYPE,
    X_PK4_COLUMN_TYPE	=> X_PK4_COLUMN_TYPE,
    X_PK5_COLUMN_TYPE	=> X_PK5_COLUMN_TYPE,
    X_APPLICATION_SHORT_NAME => X_APPLICATION_SHORT_NAME,
    X_DATABASE_OBJECT_NAME => X_DATABASE_OBJECT_NAME,
    X_DISPLAY_NAME        => X_DISPLAY_NAME,
    X_DESCRIPTION         => X_DESCRIPTION,
    X_CUSTOM_MODE         => X_CUSTOM_MODE,
    X_LAST_UPDATE_DATE    => null
  );
end LOAD_ROW;

/* Overloaded version above */
procedure LOAD_ROW (
  X_OBJ_NAME      	in VARCHAR2,
  X_OWNER 		in VARCHAR2,
  X_PK1_COLUMN_NAME	in VARCHAR2,
  X_PK2_COLUMN_NAME	in VARCHAR2,
  X_PK3_COLUMN_NAME	in VARCHAR2,
  X_PK4_COLUMN_NAME	in VARCHAR2,
  X_PK5_COLUMN_NAME	in VARCHAR2,
  X_PK1_COLUMN_TYPE	in VARCHAR2,
  X_PK2_COLUMN_TYPE	in VARCHAR2,
  X_PK3_COLUMN_TYPE	in VARCHAR2,
  X_PK4_COLUMN_TYPE	in VARCHAR2,
  X_PK5_COLUMN_TYPE	in VARCHAR2,
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_DATABASE_OBJECT_NAME in VARCHAR2,
  X_DISPLAY_NAME        in VARCHAR2,
  X_DESCRIPTION         in VARCHAR2,
  X_CUSTOM_MODE         in VARCHAR2,
  X_LAST_UPDATE_DATE    in VARCHAR2
) is
 app_id  number;
 obj_id  number;
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

  select application_id into app_id
  from   fnd_application
  where  application_short_name = X_APPLICATION_SHORT_NAME;

  select object_id, last_updated_by, last_update_date
  into obj_id, db_luby, db_ludate
  from fnd_objects
  where obj_name = X_OBJ_NAME;

  if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                db_ludate, X_CUSTOM_MODE)) then
    fnd_objects_pkg.UPDATE_ROW (
       X_OBJECT_ID              => obj_id,
       X_OBJ_NAME               => X_OBJ_NAME,
       X_PK1_COLUMN_NAME        => X_PK1_COLUMN_NAME,
       X_PK2_COLUMN_NAME        => X_PK2_COLUMN_NAME,
       X_PK3_COLUMN_NAME        => X_PK3_COLUMN_NAME,
       X_PK4_COLUMN_NAME        => X_PK4_COLUMN_NAME,
       X_PK5_COLUMN_NAME        => X_PK5_COLUMN_NAME,
       X_PK1_COLUMN_TYPE        => X_PK1_COLUMN_TYPE,
       X_PK2_COLUMN_TYPE        => X_PK2_COLUMN_TYPE,
       X_PK3_COLUMN_TYPE        => X_PK3_COLUMN_TYPE,
       X_PK4_COLUMN_TYPE        => X_PK4_COLUMN_TYPE,
       X_PK5_COLUMN_TYPE        => X_PK5_COLUMN_TYPE,
       X_APPLICATION_ID         => app_id,
       X_DATABASE_OBJECT_NAME   => X_DATABASE_OBJECT_NAME,
       X_DISPLAY_NAME           => X_DISPLAY_NAME,
       X_DESCRIPTION            => X_DESCRIPTION,
       X_LAST_UPDATE_DATE       => f_ludate,
       X_LAST_UPDATED_BY        => f_luby,
       X_LAST_UPDATE_LOGIN      => 0 );
  end if;
exception
  when NO_DATA_FOUND then

    select fnd_objects_s.nextval into obj_id from dual;

    fnd_objects_pkg.INSERT_ROW(
         X_ROWID                  => row_id,
         X_OBJ_NAME               => X_OBJ_NAME,
         X_OBJECT_ID              => obj_id,
         X_PK1_COLUMN_NAME        => X_PK1_COLUMN_NAME,
         X_PK2_COLUMN_NAME        => X_PK2_COLUMN_NAME,
         X_PK3_COLUMN_NAME        => X_PK3_COLUMN_NAME,
         X_PK4_COLUMN_NAME        => X_PK4_COLUMN_NAME,
         X_PK5_COLUMN_NAME        => X_PK5_COLUMN_NAME,
         X_PK1_COLUMN_TYPE        => X_PK1_COLUMN_TYPE,
         X_PK2_COLUMN_TYPE        => X_PK2_COLUMN_TYPE,
         X_PK3_COLUMN_TYPE        => X_PK3_COLUMN_TYPE,
         X_PK4_COLUMN_TYPE        => X_PK4_COLUMN_TYPE,
         X_PK5_COLUMN_TYPE        => X_PK5_COLUMN_TYPE,
         X_APPLICATION_ID         => app_id,
         X_DATABASE_OBJECT_NAME   => X_DATABASE_OBJECT_NAME,
         X_DISPLAY_NAME           => X_DISPLAY_NAME,
         X_DESCRIPTION            => X_DESCRIPTION,
         X_CREATION_DATE          => f_ludate,
         X_CREATED_BY             => f_luby,
         X_LAST_UPDATE_DATE       => f_ludate,
         X_LAST_UPDATED_BY        => f_luby,
         X_LAST_UPDATE_LOGIN      => 0 );
end LOAD_ROW;

/* Overloaded version below */
procedure TRANSLATE_ROW (
  X_OBJ_NAME                    in VARCHAR2,
  X_OWNER 			in VARCHAR2,
  X_DISPLAY_NAME        	in VARCHAR2,
  X_DESCRIPTION			in VARCHAR2,
  X_CUSTOM_MODE                 in VARCHAR2
) is
begin
  fnd_objects_pkg.TRANSLATE_ROW (
  X_OBJ_NAME                    => X_OBJ_NAME,
  X_OWNER 			=> X_OWNER,
  X_DISPLAY_NAME        	=> X_DISPLAY_NAME,
  X_DESCRIPTION			=> X_DESCRIPTION,
  X_CUSTOM_MODE                 => X_CUSTOM_MODE,
  X_LAST_UPDATE_DATE            => null
);
end TRANSLATE_ROW;

/* Overloaded version above */
procedure TRANSLATE_ROW (
  X_OBJ_NAME                    in VARCHAR2,
  X_OWNER 			in VARCHAR2,
  X_DISPLAY_NAME        	in VARCHAR2,
  X_DESCRIPTION			in VARCHAR2,
  X_CUSTOM_MODE                 in VARCHAR2,
  X_LAST_UPDATE_DATE            in VARCHAR2
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
  from fnd_objects_tl
  where object_id = (select o.object_id from fnd_objects o
                    where o.obj_name = X_OBJ_NAME)
  and userenv('LANG') = LANGUAGE;

  if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                db_ludate, X_CUSTOM_MODE)) then
    update fnd_objects_tl set
      display_name        = nvl(X_DISPLAY_NAME, display_name),
      description         = nvl(X_DESCRIPTION, description),
      source_lang         = userenv('LANG'),
      last_update_date    = f_ludate,
      last_updated_by     = f_luby,
      last_update_login   = 0
      where object_id = (select o.object_id from fnd_objects o
                    where o.obj_name = X_OBJ_NAME)
    and userenv('LANG') in (language, source_lang);
  end if;

end TRANSLATE_ROW;

procedure DELETE_ROW (
  X_OBJECT_ID in NUMBER
) is
begin
  delete from FND_OBJECTS_TL
  where OBJECT_ID = X_OBJECT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from FND_OBJECTS
  where OBJECT_ID = X_OBJECT_ID;

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

  delete from FND_OBJECTS_TL T
  where not exists
    (select NULL
    from FND_OBJECTS B
    where B.OBJECT_ID = T.OBJECT_ID
    );

  update FND_OBJECTS_TL T set (
      DISPLAY_NAME,
      DESCRIPTION
    ) = (select
      B.DISPLAY_NAME,
      B.DESCRIPTION
    from FND_OBJECTS_TL B
    where B.OBJECT_ID = T.OBJECT_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.OBJECT_ID,
      T.LANGUAGE
  ) in (select
      SUBT.OBJECT_ID,
      SUBT.LANGUAGE
    from FND_OBJECTS_TL SUBB, FND_OBJECTS_TL SUBT
    where SUBB.OBJECT_ID = SUBT.OBJECT_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DISPLAY_NAME <> SUBT.DISPLAY_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
  ));
*/

  insert into FND_OBJECTS_TL (
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    OBJECT_ID,
    DISPLAY_NAME,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.OBJECT_ID,
    B.DISPLAY_NAME,
    B.DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from FND_OBJECTS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from FND_OBJECTS_TL T
    where T.OBJECT_ID = B.OBJECT_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end FND_OBJECTS_PKG;

/
