--------------------------------------------------------
--  DDL for Package Body FA_LOOKUP_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_LOOKUP_TYPES_PKG" as
/* $Header: faxiltb.pls 120.7.12010000.2 2009/07/19 10:39:44 glchen ship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_LOOKUP_TYPE in VARCHAR2,
  X_USER_MAINTAINABLE in VARCHAR2,
  X_MEANING in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) is
  cursor C is select ROWID from FA_LOOKUP_TYPES_B
    where LOOKUP_TYPE = X_LOOKUP_TYPE
    ;
begin
  insert into FA_LOOKUP_TYPES_B (
    LOOKUP_TYPE,
    USER_MAINTAINABLE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_LOOKUP_TYPE,
    X_USER_MAINTAINABLE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into FA_LOOKUP_TYPES_TL (
    LOOKUP_TYPE,
    MEANING,
    DESCRIPTION,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_LOOKUP_TYPE,
    X_MEANING,
    X_DESCRIPTION,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from FA_LOOKUP_TYPES_TL T
    where T.LOOKUP_TYPE = X_LOOKUP_TYPE
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
  X_LOOKUP_TYPE in VARCHAR2,
  X_USER_MAINTAINABLE in VARCHAR2,
  X_MEANING in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) is
  cursor c is select
      USER_MAINTAINABLE
    from FA_LOOKUP_TYPES_B
    where LOOKUP_TYPE = X_LOOKUP_TYPE
    for update of LOOKUP_TYPE nowait;
  recinfo c%rowtype;

  cursor c1 is select
      MEANING,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from FA_LOOKUP_TYPES_TL
    where LOOKUP_TYPE = X_LOOKUP_TYPE
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of LOOKUP_TYPE nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.USER_MAINTAINABLE = X_USER_MAINTAINABLE)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.MEANING = X_MEANING)
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
  X_LOOKUP_TYPE in VARCHAR2,
  X_USER_MAINTAINABLE in VARCHAR2,
  X_MEANING in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) is
begin
  update FA_LOOKUP_TYPES_B set
    USER_MAINTAINABLE = X_USER_MAINTAINABLE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where LOOKUP_TYPE = X_LOOKUP_TYPE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update FA_LOOKUP_TYPES_TL set
    MEANING = X_MEANING,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where LOOKUP_TYPE = X_LOOKUP_TYPE
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_LOOKUP_TYPE in VARCHAR2
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) is
begin
  delete from FA_LOOKUP_TYPES_TL
  where LOOKUP_TYPE = X_LOOKUP_TYPE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from FA_LOOKUP_TYPES_B
  where LOOKUP_TYPE = X_LOOKUP_TYPE;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;
/* bug 8355119
procedure ADD_LANGUAGE
is
begin
  delete from FA_LOOKUP_TYPES_TL T
  where not exists
    (select NULL
    from FA_LOOKUP_TYPES_B B
    where B.LOOKUP_TYPE = T.LOOKUP_TYPE
    );*/
/* bug 8355119*/
procedure ADD_LANGUAGE(p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
is
begin
  delete from FA_LOOKUP_TYPES_TL T
  where not exists
    (select NULL
    from FA_LOOKUP_TYPES_B B
    where B.LOOKUP_TYPE = T.LOOKUP_TYPE
    );

  update FA_LOOKUP_TYPES_TL T set (
      MEANING,
      DESCRIPTION
    ) = (select
      B.MEANING,
      B.DESCRIPTION
    from FA_LOOKUP_TYPES_TL B
    where B.LOOKUP_TYPE = T.LOOKUP_TYPE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.LOOKUP_TYPE,
      T.LANGUAGE
  ) in (select
      SUBT.LOOKUP_TYPE,
      SUBT.LANGUAGE
    from FA_LOOKUP_TYPES_TL SUBB, FA_LOOKUP_TYPES_TL SUBT
    where SUBB.LOOKUP_TYPE = SUBT.LOOKUP_TYPE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.MEANING <> SUBT.MEANING
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
  ));

  insert into FA_LOOKUP_TYPES_TL (
    LOOKUP_TYPE,
    MEANING,
    DESCRIPTION,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.LOOKUP_TYPE,
    B.MEANING,
    B.DESCRIPTION,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from FA_LOOKUP_TYPES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from FA_LOOKUP_TYPES_TL T
    where T.LOOKUP_TYPE = B.LOOKUP_TYPE
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure LOAD_ROW (
    X_LOOKUP_TYPE in VARCHAR2,
    X_OWNER in VARCHAR2,
    X_MEANING in VARCHAR2,
    X_DESCRIPTION in VARCHAR2,
    X_USER_MAINTAINABLE in VARCHAR2
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) is

  h_record_exists	number(15);

  user_id		number;
  row_id		varchar2(64);

begin

  if (X_Owner = 'SEED') then
     user_id := 1;
  else
     user_id := 0;
  end if;

select count(*)
into	h_record_exists
from	fa_lookup_types
where	lookup_type = X_Lookup_Type;

if (h_record_exists > 0) then
  fa_lookup_types_pkg.update_row (
    X_Lookup_Type		=> X_Lookup_Type,
    X_User_Maintainable		=> X_User_Maintainable,
    X_Meaning			=> X_Meaning,
    X_Description		=> X_Description,
    X_Last_Update_Date		=> sysdate,
    X_Last_Updated_By		=> user_id,
    X_Last_Update_Login		=> 0
  , p_log_level_rec => p_log_level_rec);
else
  fa_lookup_types_pkg.insert_row (
    X_Rowid			=> row_id,
    X_Lookup_Type		=> X_Lookup_Type,
    X_User_Maintainable         => X_User_Maintainable,
    X_Meaning                   => X_Meaning,
    X_Description               => X_Description,
    X_Creation_Date		=> sysdate,
    X_Created_By		=> user_id,
    X_Last_Update_Date           => sysdate,
    X_Last_Updated_By           => user_id,
    X_Last_Update_Login         => 0
  , p_log_level_rec => p_log_level_rec);
end if;

exception
    when others then
         FA_STANDARD_PKG.RAISE_ERROR(
			CALLED_FN => 'fa_lookup_types_pkg.load_row',
			CALLING_FN => 'upload fa_lookup_types',
                        p_log_level_rec => p_log_level_rec);

end LOAD_ROW;
/*Bug 8355119 overloading function for release specific signatures*/
procedure LOAD_ROW (
    X_CUSTOM_MODE in VARCHAR2,
    X_LOOKUP_TYPE in VARCHAR2,
    X_OWNER in VARCHAR2,
    X_LAST_UPDATE_DATE in DATE,
    X_MEANING in VARCHAR2,
    X_DESCRIPTION in VARCHAR2,
    X_USER_MAINTAINABLE in VARCHAR2,
    p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) is

  h_record_exists	number(15);

  user_id		number;
  row_id		varchar2(64);

  db_last_updated_by   number;
  db_last_update_date  date;

begin

   user_id := fnd_load_util.owner_id (X_Owner);

   select count(*)
   into   h_record_exists
   from   fa_lookup_types
   where  lookup_type = X_Lookup_Type;

   if (h_record_exists > 0) then

      select last_updated_by, last_update_date
      into   db_last_updated_by, db_last_update_date
      from   fa_lookup_types
      where  lookup_type = x_lookup_type;

      if (fnd_load_util.upload_test(user_id, x_last_update_date,
                                    db_last_updated_by, db_last_update_date,
                                    X_CUSTOM_MODE)) then

         fa_lookup_types_pkg.update_row (
             X_Lookup_Type		=> X_Lookup_Type,
             X_User_Maintainable	=> X_User_Maintainable,
             X_Meaning			=> X_Meaning,
             X_Description		=> X_Description,
             X_Last_Update_Date		=> x_Last_Update_Date,
             X_Last_Updated_By		=> user_id,
             X_Last_Update_Login	=> 0
             ,p_log_level_rec => p_log_level_rec);
      end if;
else
  fa_lookup_types_pkg.insert_row (
    X_Rowid			=> row_id,
    X_Lookup_Type		=> X_Lookup_Type,
    X_User_Maintainable         => X_User_Maintainable,
    X_Meaning                   => X_Meaning,
    X_Description               => X_Description,
    X_Creation_Date		=> sysdate,
    X_Created_By		=> user_id,
    X_Last_Update_Date          => X_Last_Update_Date,
    X_Last_Updated_By           => user_id,
    X_Last_Update_Login         => 0
    ,p_log_level_rec => p_log_level_rec);
end if;

exception
    when others then
         FA_STANDARD_PKG.RAISE_ERROR(
			CALLED_FN => 'fa_lookup_types_pkg.load_row',
			CALLING_FN => 'upload fa_lookup_types'
			,p_log_level_rec => p_log_level_rec);

end LOAD_ROW;

procedure TRANSLATE_ROW (
    X_LOOKUP_TYPE in VARCHAR2,
    X_OWNER in VARCHAR2,
    X_MEANING in VARCHAR2,
    X_DESCRIPTION in VARCHAR2
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) is

   user_id	number;

begin

   if (X_Owner = 'SEED') then
      user_id := 1;
   else
      user_id := 0;
   end if;

update FA_LOOKUP_TYPES_TL set
    MEANING = nvl(X_Meaning, MEANING),
    DESCRIPTION = nvl(X_Description, DESCRIPTION),
    LAST_UPDATE_DATE = sysdate,
    LAST_UPDATED_BY = user_id,
    LAST_UPDATE_LOGIN = 0,
    SOURCE_LANG = userenv('LANG')
where userenv('LANG') in (LANGUAGE, SOURCE_LANG)
and LOOKUP_TYPE = X_LOOKUP_TYPE;


exception
    when others then
         FA_STANDARD_PKG.RAISE_ERROR(
                        CALLED_FN => 'fa_lookup_types_pkg.translate_row',
                        CALLING_FN => 'upload fa_lookup_types',
                        p_log_level_rec => p_log_level_rec);

end TRANSLATE_ROW;
/*Bug 8355119 overloading function for release specific signatures*/
procedure TRANSLATE_ROW (
    X_CUSTOM_MODE in VARCHAR2,
    X_LOOKUP_TYPE in VARCHAR2,
    X_OWNER in VARCHAR2,
    X_LAST_UPDATE_DATE in DATE,
    X_MEANING in VARCHAR2,
    X_DESCRIPTION in VARCHAR2,
    p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) is

   user_id	number;

  db_last_updated_by   number;
  db_last_update_date  date;

begin

select last_updated_by, last_update_date
into   db_last_updated_by, db_last_update_date
from   fa_lookup_types_tl
where  lookup_type = x_lookup_type
and    userenv('LANG') in (LANGUAGE, SOURCE_LANG);

user_id := fnd_load_util.owner_id (X_Owner);

if (fnd_load_util.upload_test(user_id, sysdate,
                              db_last_updated_by, db_last_update_date,
                              X_CUSTOM_MODE)) then

   update FA_LOOKUP_TYPES_TL set
       MEANING           = nvl(X_Meaning, MEANING),
       DESCRIPTION       = nvl(X_Description, DESCRIPTION),
       LAST_UPDATE_DATE  = X_Last_Update_Date,
       LAST_UPDATED_BY   = user_id,
       LAST_UPDATE_LOGIN = 0,
       SOURCE_LANG = userenv('LANG')
   where userenv('LANG') in (LANGUAGE, SOURCE_LANG)
   and LOOKUP_TYPE = X_LOOKUP_TYPE;

end if;

exception
    when others then
         FA_STANDARD_PKG.RAISE_ERROR(
                        CALLED_FN => 'fa_lookup_types_pkg.translate_row',
                        CALLING_FN => 'upload fa_lookup_types'
                        ,p_log_level_rec => p_log_level_rec);

end TRANSLATE_ROW;
/*bug 8355119 adding R12 specific funtion LOAD_SEED_ROW*/
procedure LOAD_SEED_ROW (
             x_upload_mode              IN VARCHAR2,
             x_custom_mode              IN VARCHAR2,
             x_lookup_type              IN VARCHAR2,
             x_owner                    IN VARCHAR2,
             x_last_update_date         IN DATE,
             x_meaning                  IN VARCHAR2,
             x_description              IN VARCHAR2,
             x_user_maintainable        IN VARCHAR2) IS


BEGIN

        if (x_upload_mode = 'NLS') then
           fa_lookup_types_pkg.TRANSLATE_ROW (
             x_custom_mode              => x_custom_mode,
             x_lookup_type              => x_lookup_type,
             x_owner                    => x_owner,
             x_last_update_date         => x_last_update_date,
             x_meaning                  => x_meaning,
             x_description              => x_description);
         else
            fa_lookup_types_pkg.LOAD_ROW (
             x_custom_mode              => x_custom_mode,
             x_lookup_type              => x_lookup_type,
             x_owner                    => x_owner,
             x_last_update_date         => x_last_update_date,
             x_meaning                  => x_meaning,
             x_description              => x_description,
             x_user_maintainable        => x_user_maintainable);
         end if;

END LOAD_SEED_ROW;

end FA_LOOKUP_TYPES_PKG;

/
