--------------------------------------------------------
--  DDL for Package Body FND_FORM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_FORM_PKG" as
/* $Header: AFFMFBFB.pls 120.2 2005/10/26 10:21:06 rsheh ship $ */

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_FORM_ID in NUMBER,
  X_FORM_NAME in VARCHAR2,
  X_AUDIT_ENABLED_FLAG in VARCHAR2,
  X_USER_FORM_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from FND_FORM
    where APPLICATION_ID = X_APPLICATION_ID
    and FORM_ID = X_FORM_ID
    ;
begin
  insert into FND_FORM (
    APPLICATION_ID,
    FORM_ID,
    FORM_NAME,
    AUDIT_ENABLED_FLAG,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_APPLICATION_ID,
    X_FORM_ID,
    X_FORM_NAME,
    X_AUDIT_ENABLED_FLAG,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into FND_FORM_TL (
    APPLICATION_ID,
    FORM_ID,
    USER_FORM_NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_APPLICATION_ID,
    X_FORM_ID,
    X_USER_FORM_NAME,
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
    from FND_FORM_TL T
    where T.APPLICATION_ID = X_APPLICATION_ID
    and T.FORM_ID = X_FORM_ID
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
  X_APPLICATION_ID in NUMBER,
  X_FORM_ID in NUMBER,
  X_FORM_NAME in VARCHAR2,
  X_AUDIT_ENABLED_FLAG in VARCHAR2,
  X_USER_FORM_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      FORM_NAME,
      AUDIT_ENABLED_FLAG
    from FND_FORM
    where APPLICATION_ID = X_APPLICATION_ID
    and FORM_ID = X_FORM_ID
    for update of APPLICATION_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      USER_FORM_NAME,
      DESCRIPTION
    from FND_FORM_TL
    where APPLICATION_ID = X_APPLICATION_ID
    and FORM_ID = X_FORM_ID
    and LANGUAGE = userenv('LANG')
    for update of APPLICATION_ID nowait;
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
  if (    (recinfo.FORM_NAME = X_FORM_NAME)
      AND (recinfo.AUDIT_ENABLED_FLAG = X_AUDIT_ENABLED_FLAG)
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

  if (    (tlinfo.USER_FORM_NAME = X_USER_FORM_NAME)
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
  X_APPLICATION_ID in NUMBER,
  X_FORM_ID in NUMBER,
  X_FORM_NAME in VARCHAR2,
  X_AUDIT_ENABLED_FLAG in VARCHAR2,
  X_USER_FORM_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update FND_FORM set
    FORM_NAME = X_FORM_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where APPLICATION_ID = X_APPLICATION_ID
  and FORM_ID = X_FORM_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update FND_FORM_TL set
    USER_FORM_NAME = X_USER_FORM_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where APPLICATION_ID = X_APPLICATION_ID
  and FORM_ID = X_FORM_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

/* Overloaded version below */
procedure LOAD_ROW (
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_FORM_NAME in VARCHAR2,
  X_AUDIT_ENABLED_FLAG in VARCHAR2,
  X_USER_FORM_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2
) is
begin
  fnd_form_pkg.LOAD_ROW (
    X_APPLICATION_SHORT_NAME => X_APPLICATION_SHORT_NAME,
    X_FORM_NAME => X_FORM_NAME,
    X_AUDIT_ENABLED_FLAG => X_AUDIT_ENABLED_FLAG,
    X_USER_FORM_NAME => X_USER_FORM_NAME,
    X_DESCRIPTION => X_DESCRIPTION,
    X_OWNER => X_OWNER,
    X_CUSTOM_MODE => X_CUSTOM_MODE,
    X_LAST_UPDATE_DATE => null
  );
end LOAD_ROW;

/* Overloaded version above */
procedure LOAD_ROW (
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_FORM_NAME in VARCHAR2,
  X_AUDIT_ENABLED_FLAG in VARCHAR2,
  X_USER_FORM_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2,
  X_LAST_UPDATE_DATE in VARCHAR2
) is
 app_id  number;
 frm_id  number;
 row_id varchar2(64);
 v_audit_enabled_flag varchar2(1);
 f_luby    number;  -- entity owner in file
 f_ludate  date;    -- entity update date in file
 db_luby   number;  -- entity owner in db
 db_ludate date;    -- entity update date in db
begin
  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(X_OWNER);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(X_LAST_UPDATE_DATE, 'YYYY/MM/DD'), sysdate);

  select application_id into app_id
  from   fnd_application
  where  application_short_name = X_APPLICATION_SHORT_NAME;

  if (X_AUDIT_ENABLED_FLAG is null) then
    v_audit_enabled_flag := 'N';
  else
    v_audit_enabled_flag := X_AUDIT_ENABLED_FLAG;
  end if;

  select form_id, last_updated_by, last_update_date
  into frm_id, db_luby, db_ludate
  from fnd_form
  where form_name = X_FORM_NAME
  and   application_id = app_id;

  if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                db_ludate, X_CUSTOM_MODE)) then
    fnd_form_pkg.UPDATE_ROW (
       X_APPLICATION_ID         => app_id,
       X_FORM_ID                => frm_id,
       X_FORM_NAME              => X_FORM_NAME,
       X_AUDIT_ENABLED_FLAG     => X_AUDIT_ENABLED_FLAG,
       X_USER_FORM_NAME         => X_USER_FORM_NAME,
       X_DESCRIPTION            => X_DESCRIPTION,
       X_LAST_UPDATE_DATE       => f_ludate,
       X_LAST_UPDATED_BY        => f_luby,
       X_LAST_UPDATE_LOGIN      => 0 );
  end if;

exception
  when NO_DATA_FOUND then

    select fnd_form_s.nextval into frm_id from dual;

    fnd_form_pkg.INSERT_ROW(
         X_ROWID                  => row_id,
         X_APPLICATION_ID         => app_id,
         X_FORM_ID                => frm_id,
         X_FORM_NAME              => X_FORM_NAME,
         X_AUDIT_ENABLED_FLAG     => v_audit_enabled_flag,
         X_USER_FORM_NAME         => X_USER_FORM_NAME,
         X_DESCRIPTION            => X_DESCRIPTION,
         X_CREATION_DATE          => f_ludate,
         X_CREATED_BY             => f_luby,
         X_LAST_UPDATE_DATE       => f_ludate,
         X_LAST_UPDATED_BY        => f_luby,
         X_LAST_UPDATE_LOGIN      => 0 );
end LOAD_ROW;
procedure DELETE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_FORM_ID in NUMBER
) is
begin
  delete from FND_FORM
  where APPLICATION_ID = X_APPLICATION_ID
  and FORM_ID = X_FORM_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from FND_FORM_TL
  where APPLICATION_ID = X_APPLICATION_ID
  and FORM_ID = X_FORM_ID;

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

  delete from FND_FORM_TL T
  where not exists
    (select NULL
    from FND_FORM B
    where B.APPLICATION_ID = T.APPLICATION_ID
    and B.FORM_ID = T.FORM_ID
    );

  update FND_FORM_TL T set (
      USER_FORM_NAME,
      DESCRIPTION
    ) = (select
      B.USER_FORM_NAME,
      B.DESCRIPTION
    from FND_FORM_TL B
    where B.APPLICATION_ID = T.APPLICATION_ID
    and B.FORM_ID = T.FORM_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.APPLICATION_ID,
      T.FORM_ID,
      T.LANGUAGE
  ) in (select
      SUBT.APPLICATION_ID,
      SUBT.FORM_ID,
      SUBT.LANGUAGE
    from FND_FORM_TL SUBB, FND_FORM_TL SUBT
    where SUBB.APPLICATION_ID = SUBT.APPLICATION_ID
    and SUBB.FORM_ID = SUBT.FORM_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.USER_FORM_NAME <> SUBT.USER_FORM_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));
*/

  insert into FND_FORM_TL (
    APPLICATION_ID,
    FORM_ID,
    USER_FORM_NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.APPLICATION_ID,
    B.FORM_ID,
    B.USER_FORM_NAME,
    B.DESCRIPTION,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from FND_FORM_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from FND_FORM_TL T
    where T.APPLICATION_ID = B.APPLICATION_ID
    and T.FORM_ID = B.FORM_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

/* Overloaded version below */
procedure TRANSLATE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_FORM_ID in VARCHAR2,
  X_USER_FORM_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2
) is
begin
  fnd_form_pkg.TRANSLATE_ROW (
    X_APPLICATION_ID => X_APPLICATION_ID,
    X_FORM_ID => X_FORM_ID,
    X_USER_FORM_NAME => X_USER_FORM_NAME,
    X_DESCRIPTION => X_DESCRIPTION,
    X_OWNER => X_OWNER,
    X_CUSTOM_MODE => X_CUSTOM_MODE,
    X_LAST_UPDATE_DATE => null
  );
end TRANSLATE_ROW;

/* Overloaded version above */
procedure TRANSLATE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_FORM_ID in VARCHAR2,
  X_USER_FORM_NAME in VARCHAR2,
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
  f_luby := fnd_load_util.owner_id(X_OWNER);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(X_LAST_UPDATE_DATE, 'YYYY/MM/DD'), sysdate);

  select LAST_UPDATED_BY, LAST_UPDATE_DATE
  into db_luby, db_ludate
  from FND_FORM_TL
  where APPLICATION_ID = X_APPLICATION_ID
  and FORM_ID = X_FORM_ID
  and userenv('LANG') = LANGUAGE;

  if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                db_ludate, X_CUSTOM_MODE)) then
    update FND_FORM_TL set
      USER_FORM_NAME = X_USER_FORM_NAME,
      DESCRIPTION = X_DESCRIPTION,
      LAST_UPDATE_DATE = f_ludate,
      LAST_UPDATED_BY =  f_luby,
      LAST_UPDATE_LOGIN = 0,
      SOURCE_LANG       = userenv('LANG')
    where APPLICATION_ID = X_APPLICATION_ID
    and FORM_ID = X_FORM_ID
    and userenv('LANG') in (language, source_lang);
  end if;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end TRANSLATE_ROW;
end FND_FORM_PKG;

/
