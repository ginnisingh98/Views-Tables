--------------------------------------------------------
--  DDL for Package Body FND_SECURITY_GROUPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_SECURITY_GROUPS_PKG" as
/* $Header: AFSCGRPB.pls 120.2 2006/02/13 01:55:15 stadepal ship $ */


--  Overloaded.  This is the obsolete old version.
procedure LOAD_ROW (
  X_SECURITY_GROUP_KEY	in 	VARCHAR2,
  X_OWNER               in	VARCHAR2,
  X_SECURITY_GROUP_NAME	in	VARCHAR2,
  X_DESCRIPTION		in	VARCHAR2) is
begin

     fnd_security_groups_pkg.LOAD_ROW (
       X_SECURITY_GROUP_KEY => X_SECURITY_GROUP_KEY,
       X_OWNER => X_OWNER,
       X_SECURITY_GROUP_NAME => X_SECURITY_GROUP_NAME,
       X_DESCRIPTION => X_DESCRIPTION,
       x_custom_mode => '',
       x_last_update_date => '');

end LOAD_ROW;

-- This is the overloaded version to use in new code.
procedure LOAD_ROW (
  X_SECURITY_GROUP_KEY	in 	VARCHAR2,
  X_OWNER               in	VARCHAR2,
  X_SECURITY_GROUP_NAME	in	VARCHAR2,
  X_DESCRIPTION		in	VARCHAR2,
  x_custom_mode         in      varchar2,
  x_last_update_date    in      varchar2) is

     sgroup_id number;
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

     begin
       select security_group_id,LAST_UPDATED_BY, LAST_UPDATE_DATE
       into sgroup_id, db_luby, db_ludate
       from   fnd_security_groups
       where  security_group_key = X_SECURITY_GROUP_KEY;

    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, X_CUSTOM_MODE)) then
       fnd_security_groups_pkg.UPDATE_ROW (
         X_SECURITY_GROUP_ID => sgroup_id,
         X_SECURITY_GROUP_KEY => X_SECURITY_GROUP_KEY,
         X_SECURITY_GROUP_NAME => X_SECURITY_GROUP_NAME,
         X_DESCRIPTION => X_DESCRIPTION,
         X_LAST_UPDATE_DATE => f_ludate,
         X_LAST_UPDATED_BY => f_luby,
         X_LAST_UPDATE_LOGIN => 0 );
      end if;
     exception
      when NO_DATA_FOUND then

       select fnd_security_groups_s.nextval into sgroup_id from dual;

       fnd_security_groups_pkg.INSERT_ROW (
         X_ROWID => row_id,
         X_SECURITY_GROUP_ID => sgroup_id,
         X_SECURITY_GROUP_KEY => X_SECURITY_GROUP_KEY,
         X_SECURITY_GROUP_NAME => X_SECURITY_GROUP_NAME,
         X_DESCRIPTION => X_DESCRIPTION,
         X_CREATION_DATE => f_ludate,
         X_CREATED_BY => f_luby,
         X_LAST_UPDATE_DATE => f_ludate,
         X_LAST_UPDATED_BY => f_luby,
         X_LAST_UPDATE_LOGIN => 0 );
  end;
end LOAD_ROW;

-- OVERLOADED! This is the obsolete version for backward compatibility.
procedure TRANSLATE_ROW (
  X_SECURITY_GROUP_KEY	in 	VARCHAR2,
  X_OWNER               in	VARCHAR2,
  X_SECURITY_GROUP_NAME	in	VARCHAR2,
  X_DESCRIPTION		in	VARCHAR2) is
begin

 FND_SECURITY_GROUPS_PKG.translate_row(
  x_security_group_key => x_security_group_key,
  x_owner => x_owner,
  x_security_group_name => x_security_group_name,
  x_description => x_description,
  x_custom_mode => '',
  x_last_update_date => '');

end TRANSLATE_ROW;

-- OVERLOADED! This is the version to use in new code.
procedure TRANSLATE_ROW (
  X_SECURITY_GROUP_KEY	in 	VARCHAR2,
  X_OWNER               in	VARCHAR2,
  X_SECURITY_GROUP_NAME	in	VARCHAR2,
  X_DESCRIPTION		in	VARCHAR2,
  X_CUSTOM_MODE		in	VARCHAR2,
  X_LAST_UPDATE_DATE	in	VARCHAR2) is

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
    from fnd_security_groups_tl
    where security_group_id = (select security_group_id
			     from   fnd_security_groups
                             where  security_group_key = X_SECURITY_GROUP_KEY)
                              and LANGUAGE = userenv('LANG');

    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, X_CUSTOM_MODE)) then
     update fnd_security_groups_tl set
      security_group_name = nvl(X_SECURITY_GROUP_NAME, security_group_name),
      description         = nvl(X_DESCRIPTION, description),
      source_lang         = userenv('LANG'),
      last_update_date    = f_ludate,
      last_updated_by     = f_luby,
      last_update_login   = 0
     where security_group_id = (select security_group_id
			     from   fnd_security_groups
                             where  security_group_key = X_SECURITY_GROUP_KEY)
                              and userenv('LANG') in (language, source_lang);
   end if;
   exception
    when no_data_found then
      null;
 end;

end TRANSLATE_ROW;

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_SECURITY_GROUP_ID in NUMBER,
  X_SECURITY_GROUP_KEY in VARCHAR2,
  X_SECURITY_GROUP_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from FND_SECURITY_GROUPS
    where SECURITY_GROUP_ID = X_SECURITY_GROUP_ID
    ;
begin
  insert into FND_SECURITY_GROUPS (
    SECURITY_GROUP_ID,
    SECURITY_GROUP_KEY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_SECURITY_GROUP_ID,
    X_SECURITY_GROUP_KEY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  -- Added for Function Security Cache Invalidation Project
  fnd_function_security_cache.insert_secgrp(X_SECURITY_GROUP_ID);

  insert into FND_SECURITY_GROUPS_TL (
    SECURITY_GROUP_ID,
    SECURITY_GROUP_NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_SECURITY_GROUP_ID,
    X_SECURITY_GROUP_NAME,
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
    from FND_SECURITY_GROUPS_TL T
    where T.SECURITY_GROUP_ID = X_SECURITY_GROUP_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  -- Bug3813798 Moved this call to happen after the translation table
  -- is updated to resolve the problem where the Security group key
  -- was being used in the display name for the role instead of the
  -- security group name when the security group is initially created.

  fnd_user_resp_groups_api.sync_roles_all_resps(X_SECURITY_GROUP_ID,
                                                X_SECURITY_GROUP_KEY);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_SECURITY_GROUP_ID in NUMBER,
  X_SECURITY_GROUP_KEY in VARCHAR2,
  X_SECURITY_GROUP_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      SECURITY_GROUP_KEY
    from FND_SECURITY_GROUPS
    where SECURITY_GROUP_ID = X_SECURITY_GROUP_ID
    for update of SECURITY_GROUP_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      SECURITY_GROUP_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from FND_SECURITY_GROUPS_TL
    where SECURITY_GROUP_ID = X_SECURITY_GROUP_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of SECURITY_GROUP_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.SECURITY_GROUP_KEY = X_SECURITY_GROUP_KEY)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.SECURITY_GROUP_NAME = X_SECURITY_GROUP_NAME)
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
  X_SECURITY_GROUP_ID in NUMBER,
  X_SECURITY_GROUP_KEY in VARCHAR2,
  X_SECURITY_GROUP_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  p_security_group_name  VARCHAR2(80);
begin
  begin
    -- Get the old Security_Group_Name from the d/b for the current session
    select SECURITY_GROUP_NAME
    into   p_security_group_name
    from   FND_SECURITY_GROUPS_TL
    where  SECURITY_GROUP_ID = X_SECURITY_GROUP_ID
    and    LANGUAGE = userenv('LANG');

  exception
    when no_data_found then
      raise no_data_found;
  end;

  update FND_SECURITY_GROUPS set
    SECURITY_GROUP_KEY = X_SECURITY_GROUP_KEY,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where SECURITY_GROUP_ID = X_SECURITY_GROUP_ID;

	if (sql%notfound) then
		raise no_data_found;
	else
          -- This means that a security group was updated.

          -- Added for Function Security Cache Invalidation Project
          fnd_function_security_cache.update_secgrp(X_SECURITY_GROUP_ID);

	end if;

  update FND_SECURITY_GROUPS_TL set
    SECURITY_GROUP_NAME = X_SECURITY_GROUP_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where SECURITY_GROUP_ID = X_SECURITY_GROUP_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  else
    -- This means that a security group translation was updated.

    -- Bug3813798 Moved call so that the correct display name is
    -- created for the roles defined for this security group.

    -- Bug 4943583. The following check prevents the expensive api
    -- 'fnd_user_resp_groups_api.sync_roles_all_resps' from being called when
    -- columns other than 'SECURITY_GROUP_NAME' (which is used in WF role
    -- DISPLAY_NAME) are modified. This api needs to be called only when the
    -- SECURITY_GROUP_NAME is modified.
    -- This change is to improve the performance.
    -- NOTE: SECURITY_GROUP_KEY can never be updated either through forms or ldt
    --     2) WF role DISPLAY_NAME contains the SECURITY_GROUP_NAME only if
    --        the SECURITY_GROUP_KEY <> 'STANDARD'. When SECURITY_GROUP_NAME is
    --        'STANDARD', then the DISPLAY_NAME is just the Responsibility_Name.
    --        Hence the below call to update the DISPLAY_NAME is not required
    --        when SECURITY_GROUP_KEY is STANDARD.

    if ((X_SECURITY_GROUP_KEY <> 'STANDARD') and
        (X_SECURITY_GROUP_NAME <> p_security_group_name)) then
       -- Call this api only if SECURITY_GROUP_KEY is not 'STANDARD'
       -- and there is a change in SECURITY_GROUP_NAME
       fnd_user_resp_groups_api.sync_roles_all_resps(X_SECURITY_GROUP_ID,
                                                     X_SECURITY_GROUP_KEY);
    end if;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_SECURITY_GROUP_ID in NUMBER
) is
begin
  delete from FND_SECURITY_GROUPS_TL
  where SECURITY_GROUP_ID = X_SECURITY_GROUP_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from FND_SECURITY_GROUPS
  where SECURITY_GROUP_ID = X_SECURITY_GROUP_ID;

	if (sql%notfound) then
		raise no_data_found;
	else
          -- This means that a security group was deleted.

          -- Added for Function Security Cache Invalidation Project
          fnd_function_security_cache.delete_secgrp(X_SECURITY_GROUP_ID);
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

  delete from FND_SECURITY_GROUPS_TL T
  where not exists
    (select NULL
    from FND_SECURITY_GROUPS B
    where B.SECURITY_GROUP_ID = T.SECURITY_GROUP_ID
    );

  update FND_SECURITY_GROUPS_TL T set (
      SECURITY_GROUP_NAME,
      DESCRIPTION
    ) = (select
      B.SECURITY_GROUP_NAME,
      B.DESCRIPTION
    from FND_SECURITY_GROUPS_TL B
    where B.SECURITY_GROUP_ID = T.SECURITY_GROUP_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.SECURITY_GROUP_ID,
      T.LANGUAGE
  ) in (select
      SUBT.SECURITY_GROUP_ID,
      SUBT.LANGUAGE
    from FND_SECURITY_GROUPS_TL SUBB, FND_SECURITY_GROUPS_TL SUBT
    where SUBB.SECURITY_GROUP_ID = SUBT.SECURITY_GROUP_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.SECURITY_GROUP_NAME <> SUBT.SECURITY_GROUP_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));
*/

  insert into FND_SECURITY_GROUPS_TL (
    SECURITY_GROUP_ID,
    SECURITY_GROUP_NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.SECURITY_GROUP_ID,
    B.SECURITY_GROUP_NAME,
    B.DESCRIPTION,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from FND_SECURITY_GROUPS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from FND_SECURITY_GROUPS_TL T
    where T.SECURITY_GROUP_ID = B.SECURITY_GROUP_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end FND_SECURITY_GROUPS_PKG;

/
