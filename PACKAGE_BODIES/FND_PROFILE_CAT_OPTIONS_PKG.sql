--------------------------------------------------------
--  DDL for Package Body FND_PROFILE_CAT_OPTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_PROFILE_CAT_OPTIONS_PKG" as
/* $Header: FNDPRCTB.pls 120.7 2006/09/21 10:28:13 stadepal noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_PROFILE_OPTION_ID in NUMBER,
  X_CATEGORY_NAME in VARCHAR2,
  X_PROFILE_OPTION_APPLICATION_I in NUMBER,
  X_DISPLAY_SEQUENCE in NUMBER,
  X_DISPLAY_TYPE in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_APPLICATION_ID in NUMBER
) is
  cursor C is select ROWID from FND_PROFILE_CAT_OPTIONS
    where PROFILE_OPTION_ID = X_PROFILE_OPTION_ID
    and CATEGORY_NAME = upper(X_CATEGORY_NAME)
    and PROFILE_OPTION_APPLICATION_ID = X_PROFILE_OPTION_APPLICATION_I
    and APPLICATION_ID = X_APPLICATION_ID
    ;
begin
  insert into FND_PROFILE_CAT_OPTIONS (
    PROFILE_OPTION_APPLICATION_ID,
    PROFILE_OPTION_ID,
    CATEGORY_NAME,
    APPLICATION_ID,
    DISPLAY_SEQUENCE,
    DISPLAY_TYPE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_PROFILE_OPTION_APPLICATION_I,
    X_PROFILE_OPTION_ID,
    upper(X_CATEGORY_NAME),
    X_APPLICATION_ID,
    X_DISPLAY_SEQUENCE,
    X_DISPLAY_TYPE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

/******************Commented. Since TL table is dropped
  insert into FND_PROFILE_CAT_OPTIONS_TL (
    PROFILE_OPTION_APPLICATION_ID,
    PROFILE_OPTION_ID,
    CATEGORY_NAME,
    APPLICATION_ID,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    DESCRIPTION_OVERRIDE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_PROFILE_OPTION_APPLICATION_I,
    X_PROFILE_OPTION_ID,
    X_CATEGORY_NAME,
    X_APPLICATION_ID,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    X_DESCRIPTION_OVERRIDE,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from FND_PROFILE_CAT_OPTIONS_TL T
    where T.PROFILE_OPTION_ID = X_PROFILE_OPTION_ID
    and T.CATEGORY_NAME = X_CATEGORY_NAME
    and T.PROFILE_OPTION_APPLICATION_ID = X_PROFILE_OPTION_APPLICATION_I
    and T.APPLICATION_ID = X_APPLICATION_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
  ***********************************/

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_PROFILE_OPTION_ID in NUMBER,
  X_CATEGORY_NAME in VARCHAR2,
  X_PROFILE_OPTION_APPLICATION_I in NUMBER,
  X_DISPLAY_SEQUENCE in NUMBER,
  X_DISPLAY_TYPE in VARCHAR2,
  X_APPLICATION_ID in NUMBER
) is
  cursor c is select
      DISPLAY_SEQUENCE,
      DISPLAY_TYPE
    from FND_PROFILE_CAT_OPTIONS
    where PROFILE_OPTION_ID = X_PROFILE_OPTION_ID
    and CATEGORY_NAME = upper(X_CATEGORY_NAME)
    and PROFILE_OPTION_APPLICATION_ID = X_PROFILE_OPTION_APPLICATION_I
    and APPLICATION_ID = X_APPLICATION_ID
    for update of PROFILE_OPTION_ID nowait;
  recinfo c%rowtype;

/******************Commented. Since TL table is dropped
  cursor c1 is select
      DESCRIPTION_OVERRIDE,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from FND_PROFILE_CAT_OPTIONS_TL
    where PROFILE_OPTION_ID = X_PROFILE_OPTION_ID
    and CATEGORY_NAME = X_CATEGORY_NAME
    and PROFILE_OPTION_APPLICATION_ID = X_PROFILE_OPTION_APPLICATION_I
    and APPLICATION_ID = X_APPLICATION_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of PROFILE_OPTION_ID nowait;
***********************/
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.DISPLAY_SEQUENCE = X_DISPLAY_SEQUENCE)
           OR ((recinfo.DISPLAY_SEQUENCE is null) AND (X_DISPLAY_SEQUENCE is null)))
      AND ((recinfo.DISPLAY_TYPE = X_DISPLAY_TYPE)
           OR ((recinfo.DISPLAY_TYPE is null) AND (X_DISPLAY_TYPE is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

/******************Commented. Since TL table is dropped
  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.DESCRIPTION_OVERRIDE = X_DESCRIPTION_OVERRIDE)
               OR ((tlinfo.DESCRIPTION_OVERRIDE is null) AND (X_DESCRIPTION_OVERRIDE is null)))
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
    end if;
  end loop;
***********************/
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_PROFILE_OPTION_ID in NUMBER,
  X_CATEGORY_NAME in VARCHAR2,
  X_PROFILE_OPTION_APPLICATION_I in NUMBER,
  X_DISPLAY_SEQUENCE in NUMBER,
  X_DISPLAY_TYPE in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_APPLICATION_ID in NUMBER
) is
begin
  update FND_PROFILE_CAT_OPTIONS set
    DISPLAY_SEQUENCE = X_DISPLAY_SEQUENCE,
    DISPLAY_TYPE = X_DISPLAY_TYPE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where PROFILE_OPTION_ID = X_PROFILE_OPTION_ID
  and CATEGORY_NAME = upper(X_CATEGORY_NAME)
  and PROFILE_OPTION_APPLICATION_ID = X_PROFILE_OPTION_APPLICATION_I
  and APPLICATION_ID = X_APPLICATION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

/******************Commented. Since TL table is dropped
  update FND_PROFILE_CAT_OPTIONS_TL set
    DESCRIPTION_OVERRIDE = X_DESCRIPTION_OVERRIDE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where PROFILE_OPTION_ID = X_PROFILE_OPTION_ID
  and CATEGORY_NAME = X_CATEGORY_NAME
  and PROFILE_OPTION_APPLICATION_ID = X_PROFILE_OPTION_APPLICATION_I
  and APPLICATION_ID = X_APPLICATION_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
***********************/
end UPDATE_ROW;

procedure DELETE_ROW (
  X_PROFILE_OPTION_ID in NUMBER,
  X_CATEGORY_NAME in VARCHAR2,
  X_PROFILE_OPTION_APPLICATION_I in NUMBER,
  X_APPLICATION_ID in NUMBER
) is
begin
/******************Commented. Since TL table is dropped
  delete from FND_PROFILE_CAT_OPTIONS_TL
  where PROFILE_OPTION_ID = X_PROFILE_OPTION_ID
  and CATEGORY_NAME = X_CATEGORY_NAME
  and PROFILE_OPTION_APPLICATION_ID = X_PROFILE_OPTION_APPLICATION_I
  and APPLICATION_ID = X_APPLICATION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
***********************/

  delete from FND_PROFILE_CAT_OPTIONS
  where PROFILE_OPTION_ID = X_PROFILE_OPTION_ID
  and CATEGORY_NAME = upper(X_CATEGORY_NAME)
  and PROFILE_OPTION_APPLICATION_ID = X_PROFILE_OPTION_APPLICATION_I
  and APPLICATION_ID = X_APPLICATION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

/*** DEPRECATED, DEPRECATED, DEPRECATED  ***/
procedure ADD_LANGUAGE
is
begin
  /** deleted all the code instead of commenting the ADD_LANGUAGE to remove
   ** the dependency between this change and FNDNLINS.sql which has call to
   ** Fnd_profile_cat_options_pkg.add_language. If the api is commented,
   ** then this change requires a change in FNDNLINS.sql.
   **/
  null;
end ADD_LANGUAGE;

/******************Commented ADD_LANGUAGE and TRANSLATE_ROW.
 ******************Since TL table is dropped.
 **/
/*****
procedure TRANSLATE_ROW (
  X_PROFILE_OPTION_APP_NAME in      VARCHAR2,
  X_PROFILE_OPTION_NAME 	 in      VARCHAR2,
  X_CATEGORY_NAME 	   in      VARCHAR2,
  X_APPLICATION_SHORT_NAME   in      VARCHAR2,
  X_DESCRIPTION_OVERRIDE         in      VARCHAR2,
  X_CUSTOM_MODE                 in      VARCHAR2,
  X_OWNER                       in      VARCHAR2,
  X_LAST_UPDATE_DATE            in      VARCHAR2)
is
  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db
  prof_app_id number;
  prof_id number;
  app_id number;
begin

  select application_id into app_id
      from fnd_application
      where application_short_name = X_APPLICATION_SHORT_NAME;

  select profile_option_id, application_id into prof_id, prof_app_id
      from fnd_profile_options
      where profile_option_name = X_PROFILE_OPTION_NAME;

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

  begin
    select LAST_UPDATED_BY, LAST_UPDATE_DATE
    into db_luby, db_ludate
    from FND_PROFILE_CAT_OPTIONS_TL
    where PROFILE_OPTION_APPLICATION_ID = prof_app_id
    and PROFILE_OPTION_ID = prof_id
    and CATEGORY_NAME = X_CATEGORY_NAME
    and APPLICATION_ID = app_id
    and LANGUAGE = userenv('LANG');

    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, X_CUSTOM_MODE)) then

        update FND_PROFILE_CAT_OPTIONS_TL set
               DESCRIPTION_OVERRIDE = X_DESCRIPTION_OVERRIDE,
               LAST_UPDATE_DATE = f_ludate,
               LAST_UPDATED_BY = f_luby,
               LAST_UPDATE_LOGIN = f_luby,
               SOURCE_LANG = userenv('LANG')
               where PROFILE_OPTION_APPLICATION_ID = prof_app_id
               and PROFILE_OPTION_ID = prof_id
               and CATEGORY_NAME = X_CATEGORY_NAME
               and APPLICATION_ID = app_id
               and userenv('LANG') in (LANGUAGE, SOURCE_LANG);
    end if;
  exception
    when no_data_found then
      null;
  end;
end TRANSLATE_ROW;
***********************/

/*** Bug 5060938. Added default param X_PROF_APPL_SHORT_NAME to LOAD_ROW api.
 *** This is required to create a Dummy profile option in Fnd_Profile_Options
 *** table when category ldt is uploaded before it's corresponding profile ldt
 *** to handle No-Data-Found issues.
 ***/
procedure LOAD_ROW (
  X_PROFILE_OPTION_NAME		   in      VARCHAR2,
  X_CATEGORY_NAME 		   in      VARCHAR2,
  X_DISPLAY_SEQUENCE 		   in      VARCHAR2,
  X_DISPLAY_TYPE 		   in      VARCHAR2,
  X_OWNER                          in      VARCHAR2,
  X_CUSTOM_MODE                    in      VARCHAR2,
  X_LAST_UPDATE_DATE               in      VARCHAR2,
  X_APPLICATION_SHORT_NAME         in      VARCHAR2,
  X_PROF_APPL_SHORT_NAME           in      VARCHAR2 default NULL)
is
  row_id    varchar2(64);
  prof_app_id    number;
  prof_id   number;
  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db
  app_id    number;
  retVal    number;

 begin

  select application_id into app_id
	from fnd_application
        where application_short_name = X_APPLICATION_SHORT_NAME;

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

  begin
     select profile_option_id, application_id into prof_id, prof_app_id
            from FND_PROFILE_OPTIONS
            where PROFILE_OPTION_NAME = X_PROFILE_OPTION_NAME;
  exception
   when no_data_found then
     /* The profile option doesn't yet exist so create a dummy profile*/
     /* to serve as a temporary placeholder.  This solves bug */
     /* 5060938 about uploading category ldt before it's related profiles */
     /* hadn't yet been uploaded.  This dummy profile will end up getting */
     /* updated with the real profile information later on during */
     /* the load when the real profile data gets uploaded. */

     /********** WARNING !!!!!!!!!!!! *********/
     /* Here fnd_profile_options_pkg.INSERT_ROW() is called instead of
      * fnd_profile_options_pkg.LOAD_ROW() since in this case there's an extra
      * processing for the values passed to Last_Updated_By and Last_Update_Date

      * In this case, the Creation_Date should be set to X_LAST_UPDATE_DATE
      * whereas the Last_Update_Date should be set to FND_API.G_MISS_DATE.
      * Similarly, Created_By is set to OWNER  and Last_Updated_By to 'SEED'/1.
      * This is to ensure that, 'fnd_load_util.upload_test()' succeeds for this
      * dummy row and consequently this Dummy profile definition always gets
      * updated with the actual definition when the profile ldt shipping the
      * right definition is uploaded.
      */

       select fnd_profile_options_s.nextval
       into prof_id
       from dual;

       /* If X_PROF_APPL_SHORT_NAME is not passed then profile is created with
        * the same application as that of it's category.
        */

       select application_id into prof_app_id
       from   fnd_application
       where  application_short_name = nvl(X_PROF_APPL_SHORT_NAME, X_APPLICATION_SHORT_NAME);

       begin
         fnd_profile_options_pkg.insert_row (
            x_rowid =>                    row_id,
            x_profile_option_name =>      X_PROFILE_OPTION_NAME,
            x_application_id =>           prof_app_id,
            x_profile_option_id =>        prof_id,
            x_write_allowed_flag =>       'N',
            x_read_allowed_flag =>        'N',
            x_user_changeable_flag =>     'N',
            x_user_visible_flag =>        'N',
            x_site_enabled_flag =>        'N',
            x_site_update_allowed_flag => 'N',
            x_app_enabled_flag =>         'N',
            x_app_update_allowed_flag =>  'N',
            x_resp_enabled_flag =>        'N',
            x_resp_update_allowed_flag => 'N',
            x_user_enabled_flag =>        'N',
            x_user_update_allowed_flag => 'N',
            x_start_date_active =>        FND_API.G_MISS_DATE,
            x_sql_validation =>           NULL,
            x_end_date_active =>          FND_API.G_MISS_DATE,
            x_user_profile_option_name => X_PROFILE_OPTION_NAME,
            x_description =>              NULL,
            x_creation_date =>            f_ludate,
            x_created_by =>               f_luby,
            x_last_update_date =>         FND_API.G_MISS_DATE,
            x_last_updated_by =>          fnd_load_util.owner_id('SEED'),
            x_last_update_login =>        0,
            x_hierarchy_type =>		'SECURITY',
            x_server_enabled_flag =>      'N',
            x_server_update_allowed_flag => 'N',
            x_org_enabled_flag => 'N',
            x_org_update_allowed_flag => 'N',
            x_serverresp_enabled_flag =>    'N',
            x_serverresp_upd_allow_fl =>    'N');
       exception
        when dup_val_on_index then
        -- Bug 5453931.
        -- It means actual profile is already inserted by another ldt parallely.
        -- So ignore creation of this dummy profile and get the
        -- Profile_Option_Id and Application_Id of the real profile option from
        -- Fnd_Profile_Options table.
            select profile_option_id, application_id
            into prof_id, prof_app_id
            from FND_PROFILE_OPTIONS
            where PROFILE_OPTION_NAME = X_PROFILE_OPTION_NAME;
       end;
  end;

  begin
      select 1 into retVal
            from FND_PROFILE_CATS
            where NAME = X_CATEGORY_NAME
            and   APPLICATION_ID = app_id;
  exception
  when no_data_found then
    -- Bug 5060938.
    -- While uploading profile ldt (with link info), the referenced category
    -- is not yet uploaded. Hence postpone the upload of this category->option
    -- link info till the category ldt with the definition for this category
    -- and this link info is uploaded.

   /********** WARNING !!!!!!!!!!!! *********/
   /* Placeholder/Stub needs to be created only for the missing profiles when
    * uploading categories. This is not required for this case (missing category
    * when uploading profiles).
    * The main reason for doing this way is, for backward compatibility.
    * The profile ldt's that were extracted with the default behaviour of
    * old 'afscprof.lct' (<= (115.50=120.10)) will not have profile->category
    * link information. So while uploading the category ldt, IF upload of
    * category->option link info is skipped for the missing profiles THEN
    * we can never upload the above information(if profile ldt's were
    * extracted with default behaviour of old afscprof.lct). It's equivalent to
    * loosing this information.

    * We don't have any issues if we skip the upload of this link info for the
    * missing category while uploading the profile ldt. Because this info
    * is always available in the category ldt.

    * NOTE: The new version afscprof.lct(115.51=120.11) always extracts the
    * profile->category information. So, if profiles are re-extracted with
    * the latest version of 'afscprof.lct' then by default they pick up
    * profile->category information also.
    */

    return;
  end;

  begin
    select LAST_UPDATED_BY, LAST_UPDATE_DATE
    into db_luby, db_ludate
    from FND_PROFILE_CAT_OPTIONS
    where PROFILE_OPTION_APPLICATION_ID = prof_app_id
    and PROFILE_OPTION_ID = prof_id
    and CATEGORY_NAME = upper(X_CATEGORY_NAME)
    and APPLICATION_ID = app_id;

    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, X_CUSTOM_MODE)) then

	FND_PROFILE_CAT_OPTIONS_PKG.UPDATE_ROW (
           	X_PROFILE_OPTION_APPLICATION_I => prof_app_id,
  		X_PROFILE_OPTION_ID => prof_id,
  		X_CATEGORY_NAME => X_CATEGORY_NAME,
  		X_APPLICATION_ID => app_id,
  		X_DISPLAY_SEQUENCE => X_DISPLAY_SEQUENCE,
  		X_DISPLAY_TYPE => X_DISPLAY_TYPE,
  		X_LAST_UPDATE_DATE => f_ludate,
            X_LAST_UPDATED_BY => f_luby,
  		X_LAST_UPDATE_LOGIN => f_luby);
   end if;
  exception
     when no_data_found then
         begin
	    FND_PROFILE_CAT_OPTIONS_PKG.INSERT_ROW (
        	   X_ROWID => row_id,
                   X_PROFILE_OPTION_APPLICATION_I => prof_app_id,
     		   X_PROFILE_OPTION_ID => prof_id,
  		   X_CATEGORY_NAME => X_CATEGORY_NAME,
  		   X_APPLICATION_ID => app_id,
  		   X_DISPLAY_SEQUENCE => X_DISPLAY_SEQUENCE,
  		   X_DISPLAY_TYPE => X_DISPLAY_TYPE,
  		   X_CREATION_DATE => f_ludate,
  		   X_CREATED_BY => f_luby,
                   X_LAST_UPDATE_DATE => f_ludate,
                   X_LAST_UPDATED_BY => f_luby,
                   X_LAST_UPDATE_LOGIN => f_luby);
         exception
           when dup_val_on_index then
           -- Bug 5453931.
           -- It means profile->category link information is already inserted
           -- by another ldt parallely. For a given profile->category link,
           -- since the data for this link info is always same from different
           -- ldt's, we can ignore this dup_val_on_index exception while
           -- inserting profile->category link data.
           -- (Only Display_Sequence and Display_Type fields are updateable
           --  in Fnd_Profile_Cat_Options table. But there is no UI feature
           --  to update the above updateable columns. Hence data in
           --  different ldt's is always same for this Fnd_Profile_Cat_Options
           --  entity)

               null;
         end;
  end;
end LOAD_ROW;

end FND_PROFILE_CAT_OPTIONS_PKG;

/
