--------------------------------------------------------
--  DDL for Package Body FND_OBJECT_INSTANCE_SETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_OBJECT_INSTANCE_SETS_PKG" as
/* $Header: AFSCOISB.pls 120.2 2005/10/27 18:19:53 tmorrow ship $ */

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_INSTANCE_SET_ID in NUMBER,
  X_INSTANCE_SET_NAME in VARCHAR2,
  X_OBJECT_ID in NUMBER,
  X_PREDICATE in VARCHAR2,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from FND_OBJECT_INSTANCE_SETS
    where INSTANCE_SET_ID = X_INSTANCE_SET_ID
    ;
begin
  insert into FND_OBJECT_INSTANCE_SETS (
    INSTANCE_SET_ID,
    INSTANCE_SET_NAME,
    OBJECT_ID,
    PREDICATE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_INSTANCE_SET_ID,
    X_INSTANCE_SET_NAME,
    X_OBJECT_ID,
    X_PREDICATE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into FND_OBJECT_INSTANCE_SETS_TL (
    INSTANCE_SET_ID,
    DISPLAY_NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_INSTANCE_SET_ID,
    X_DISPLAY_NAME,
    X_DESCRIPTION,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from FND_OBJECT_INSTANCE_SETS_TL T
    where T.INSTANCE_SET_ID = X_INSTANCE_SET_ID
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
  X_INSTANCE_SET_ID in NUMBER,
  X_INSTANCE_SET_NAME in VARCHAR2,
  X_OBJECT_ID in NUMBER,
  X_PREDICATE in VARCHAR2,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      INSTANCE_SET_NAME,
      OBJECT_ID,
      PREDICATE
    from FND_OBJECT_INSTANCE_SETS
    where INSTANCE_SET_ID = X_INSTANCE_SET_ID
    for update of INSTANCE_SET_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      DISPLAY_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from FND_OBJECT_INSTANCE_SETS_TL
    where INSTANCE_SET_ID = X_INSTANCE_SET_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of INSTANCE_SET_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.INSTANCE_SET_NAME = X_INSTANCE_SET_NAME)
      AND (recinfo.OBJECT_ID = X_OBJECT_ID)
      AND ((recinfo.PREDICATE = X_PREDICATE)
           OR ((recinfo.PREDICATE is null) AND (X_PREDICATE is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.DISPLAY_NAME = X_DISPLAY_NAME)
          AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
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
  X_INSTANCE_SET_ID in NUMBER,
  X_INSTANCE_SET_NAME in VARCHAR2,
  X_OBJECT_ID in NUMBER,
  X_PREDICATE in VARCHAR2,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update FND_OBJECT_INSTANCE_SETS set
    OBJECT_ID = X_OBJECT_ID,
    PREDICATE = X_PREDICATE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where INSTANCE_SET_ID = X_INSTANCE_SET_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update FND_OBJECT_INSTANCE_SETS_TL set
    DISPLAY_NAME = X_DISPLAY_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where INSTANCE_SET_ID = X_INSTANCE_SET_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

/* Overloaded version below */
procedure LOAD_ROW (
  X_INSTANCE_SET_NAME  	in VARCHAR2,
  X_OWNER 		in VARCHAR2,
  X_OBJECT_NAME         in VARCHAR2,
  X_PREDICATE           in VARCHAR2,
  X_DISPLAY_NAME        in VARCHAR2,
  X_DESCRIPTION         in VARCHAR2,
  X_CUSTOM_MODE         in VARCHAR2
) is
begin
  fnd_object_instance_sets_pkg.LOAD_ROW (
    X_INSTANCE_SET_NAME   => X_INSTANCE_SET_NAME,
    X_OWNER 		  => X_OWNER,
    X_OBJECT_NAME         => X_OBJECT_NAME,
    X_PREDICATE           => X_PREDICATE,
    X_DISPLAY_NAME        => X_DISPLAY_NAME,
    X_DESCRIPTION         => X_DESCRIPTION,
    X_CUSTOM_MODE         => X_CUSTOM_MODE,
    X_LAST_UPDATE_DATE    => null
  );
end LOAD_ROW;

/* Overloaded version above */
procedure LOAD_ROW (
  X_INSTANCE_SET_NAME  	in VARCHAR2,
  X_OWNER 		in VARCHAR2,
  X_OBJECT_NAME         in VARCHAR2,
  X_PREDICATE           in VARCHAR2,
  X_DISPLAY_NAME        in VARCHAR2,
  X_DESCRIPTION         in VARCHAR2,
  X_CUSTOM_MODE         in VARCHAR2,
  X_LAST_UPDATE_DATE    in VARCHAR2
) is
 ins_set_id  number;
 obj_id number;
 row_id varchar2(64);
 f_luby    number;  -- entity owner in file
 f_ludate  date;    -- entity update date in file
 db_luby   number;  -- entity owner in db
 db_ludate date;    -- entity update date in db
begin
  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

  select OBJECT_ID into obj_id
  from FND_OBJECTS where OBJ_NAME = X_OBJECT_NAME;

-- Be careful, invalid object might cause no_data_found.
-- Fix it later after discussion

  select INSTANCE_SET_ID, LAST_UPDATED_BY, LAST_UPDATE_DATE
  into ins_set_id, db_luby, db_ludate
  from fnd_object_instance_sets
  where INSTANCE_SET_NAME = X_INSTANCE_SET_NAME;

  if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                db_ludate, X_CUSTOM_MODE)) then
    fnd_object_instance_sets_pkg.UPDATE_ROW (
      X_INSTANCE_SET_ID           => ins_set_id,
      X_INSTANCE_SET_NAME         => X_INSTANCE_SET_NAME,
      X_OBJECT_ID                 => obj_id,
      X_PREDICATE                 => X_PREDICATE,
      X_DISPLAY_NAME              => X_DISPLAY_NAME,
      X_DESCRIPTION               => X_DESCRIPTION,
      X_LAST_UPDATE_DATE          => f_ludate,
      X_LAST_UPDATED_BY           => f_luby,
      X_LAST_UPDATE_LOGIN         => 0 );
  end if;

exception
  when NO_DATA_FOUND then

    select fnd_object_instance_sets_s.nextval into ins_set_id from dual;

    fnd_object_instance_sets_pkg.INSERT_ROW(
         X_ROWID                  => row_id,
         X_INSTANCE_SET_ID        => ins_set_id,
         X_INSTANCE_SET_NAME      => X_INSTANCE_SET_NAME,
         X_OBJECT_ID              => obj_id,
         X_PREDICATE              => X_PREDICATE,
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
  X_INSTANCE_SET_NAME           in VARCHAR2,
  X_OWNER 			in VARCHAR2,
  X_DISPLAY_NAME        	in VARCHAR2,
  X_DESCRIPTION			in VARCHAR2,
  X_CUSTOM_MODE                 in VARCHAR2
) is
begin
  fnd_object_instance_sets_pkg.TRANSLATE_ROW (
    X_INSTANCE_SET_NAME         => X_INSTANCE_SET_NAME,
    X_OWNER 			=> X_OWNER ,
    X_DISPLAY_NAME        	=> X_DISPLAY_NAME,
    X_DESCRIPTION		=> X_DESCRIPTION,
    X_CUSTOM_MODE               => X_CUSTOM_MODE,
    X_LAST_UPDATE_DATE          => null
  );
end TRANSLATE_ROW;

/* Overloaded version above */
procedure TRANSLATE_ROW (
  X_INSTANCE_SET_NAME           in VARCHAR2,
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
  from fnd_object_instance_sets_tl
  where instance_set_id = (select i.instance_set_id
                          from fnd_object_instance_sets i
                          where i.instance_set_name = X_INSTANCE_SET_NAME)
  and userenv('LANG') = LANGUAGE;

  if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                db_ludate, X_CUSTOM_MODE)) then
    update fnd_object_instance_sets_tl set
      display_name        = nvl(X_DISPLAY_NAME, display_name),
      description         = nvl(X_DESCRIPTION, description),
      source_lang         = userenv('LANG'),
      last_update_date    = f_ludate,
      last_updated_by     = f_luby,
      last_update_login   = 0
    where instance_set_id = (select i.instance_set_id
                          from fnd_object_instance_sets i
                          where i.instance_set_name = X_INSTANCE_SET_NAME)
    and userenv('LANG') in (language, source_lang);
  end if;
end TRANSLATE_ROW;

procedure DELETE_ROW (
  X_INSTANCE_SET_ID in NUMBER
) is
begin
  delete from FND_OBJECT_INSTANCE_SETS_TL
  where INSTANCE_SET_ID = X_INSTANCE_SET_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from FND_OBJECT_INSTANCE_SETS
  where INSTANCE_SET_ID = X_INSTANCE_SET_ID;

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

  delete from FND_OBJECT_INSTANCE_SETS_TL T
  where not exists
    (select NULL
    from FND_OBJECT_INSTANCE_SETS B
    where B.INSTANCE_SET_ID = T.INSTANCE_SET_ID
    );

  update FND_OBJECT_INSTANCE_SETS_TL T set (
      DISPLAY_NAME,
      DESCRIPTION
    ) = (select
      B.DISPLAY_NAME,
      B.DESCRIPTION
    from FND_OBJECT_INSTANCE_SETS_TL B
    where B.INSTANCE_SET_ID = T.INSTANCE_SET_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.INSTANCE_SET_ID,
      T.LANGUAGE
  ) in (select
      SUBT.INSTANCE_SET_ID,
      SUBT.LANGUAGE
    from FND_OBJECT_INSTANCE_SETS_TL SUBB, FND_OBJECT_INSTANCE_SETS_TL SUBT
    where SUBB.INSTANCE_SET_ID = SUBT.INSTANCE_SET_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DISPLAY_NAME <> SUBT.DISPLAY_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));
*/

  insert into FND_OBJECT_INSTANCE_SETS_TL (
    INSTANCE_SET_ID,
    DISPLAY_NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.INSTANCE_SET_ID,
    B.DISPLAY_NAME,
    B.DESCRIPTION,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from FND_OBJECT_INSTANCE_SETS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from FND_OBJECT_INSTANCE_SETS_TL T
    where T.INSTANCE_SET_ID = B.INSTANCE_SET_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end FND_OBJECT_INSTANCE_SETS_PKG;

/
