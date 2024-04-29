--------------------------------------------------------
--  DDL for Package Body FA_LOOKUPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_LOOKUPS_PKG" as
/* $Header: faxilob.pls 120.9.12010000.2 2009/07/19 10:36:56 glchen ship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_LOOKUP_TYPE in VARCHAR2,
  X_LOOKUP_CODE in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE_CATEGORY_CODE in VARCHAR2,
  X_MEANING in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) is
  cursor C is select ROWID from FA_LOOKUPS_B
    where LOOKUP_TYPE = X_LOOKUP_TYPE
    and LOOKUP_CODE = X_LOOKUP_CODE
    ;
begin
  insert into FA_LOOKUPS_B (
    LOOKUP_TYPE,
    LOOKUP_CODE,
    ENABLED_FLAG,
    START_DATE_ACTIVE,
    END_DATE_ACTIVE,
    ATTRIBUTE1,
    ATTRIBUTE2,
    ATTRIBUTE3,
    ATTRIBUTE4,
    ATTRIBUTE5,
    ATTRIBUTE6,
    ATTRIBUTE7,
    ATTRIBUTE8,
    ATTRIBUTE9,
    ATTRIBUTE10,
    ATTRIBUTE11,
    ATTRIBUTE12,
    ATTRIBUTE13,
    ATTRIBUTE14,
    ATTRIBUTE15,
    ATTRIBUTE_CATEGORY_CODE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_LOOKUP_TYPE,
    X_LOOKUP_CODE,
    X_ENABLED_FLAG,
    X_START_DATE_ACTIVE,
    X_END_DATE_ACTIVE,
    X_ATTRIBUTE1,
    X_ATTRIBUTE2,
    X_ATTRIBUTE3,
    X_ATTRIBUTE4,
    X_ATTRIBUTE5,
    X_ATTRIBUTE6,
    X_ATTRIBUTE7,
    X_ATTRIBUTE8,
    X_ATTRIBUTE9,
    X_ATTRIBUTE10,
    X_ATTRIBUTE11,
    X_ATTRIBUTE12,
    X_ATTRIBUTE13,
    X_ATTRIBUTE14,
    X_ATTRIBUTE15,
    X_ATTRIBUTE_CATEGORY_CODE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into FA_LOOKUPS_TL (
    LOOKUP_TYPE,
    LOOKUP_CODE,
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
    X_LOOKUP_CODE,
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
    from FA_LOOKUPS_TL T
    where T.LOOKUP_TYPE = X_LOOKUP_TYPE
    and T.LOOKUP_CODE = X_LOOKUP_CODE
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
  X_LOOKUP_CODE in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE_CATEGORY_CODE in VARCHAR2,
  X_MEANING in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) is
  cursor c is select
      ENABLED_FLAG,
      START_DATE_ACTIVE,
      END_DATE_ACTIVE,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15,
      ATTRIBUTE_CATEGORY_CODE
    from FA_LOOKUPS_B
    where LOOKUP_TYPE = X_LOOKUP_TYPE
    and LOOKUP_CODE = X_LOOKUP_CODE
    for update of LOOKUP_TYPE nowait;
  recinfo c%rowtype;

  cursor c1 is select
      MEANING,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from FA_LOOKUPS_TL
    where LOOKUP_TYPE = X_LOOKUP_TYPE
    and LOOKUP_CODE = X_LOOKUP_CODE
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
  if (    (recinfo.ENABLED_FLAG = X_ENABLED_FLAG)
      AND ((recinfo.START_DATE_ACTIVE = X_START_DATE_ACTIVE)
           OR ((recinfo.START_DATE_ACTIVE is null) AND (X_START_DATE_ACTIVE is null)))
      AND ((recinfo.END_DATE_ACTIVE = X_END_DATE_ACTIVE)
           OR ((recinfo.END_DATE_ACTIVE is null) AND (X_END_DATE_ACTIVE is null)))
      AND ((recinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
           OR ((recinfo.ATTRIBUTE1 is null) AND (X_ATTRIBUTE1 is null)))
      AND ((recinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
           OR ((recinfo.ATTRIBUTE2 is null) AND (X_ATTRIBUTE2 is null)))
      AND ((recinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
           OR ((recinfo.ATTRIBUTE3 is null) AND (X_ATTRIBUTE3 is null)))
      AND ((recinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
           OR ((recinfo.ATTRIBUTE4 is null) AND (X_ATTRIBUTE4 is null)))
      AND ((recinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
           OR ((recinfo.ATTRIBUTE5 is null) AND (X_ATTRIBUTE5 is null)))
      AND ((recinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
           OR ((recinfo.ATTRIBUTE6 is null) AND (X_ATTRIBUTE6 is null)))
      AND ((recinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
           OR ((recinfo.ATTRIBUTE7 is null) AND (X_ATTRIBUTE7 is null)))
      AND ((recinfo.ATTRIBUTE8 = X_ATTRIBUTE8)
           OR ((recinfo.ATTRIBUTE8 is null) AND (X_ATTRIBUTE8 is null)))
      AND ((recinfo.ATTRIBUTE9 = X_ATTRIBUTE9)
           OR ((recinfo.ATTRIBUTE9 is null) AND (X_ATTRIBUTE9 is null)))
      AND ((recinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
           OR ((recinfo.ATTRIBUTE10 is null) AND (X_ATTRIBUTE10 is null)))
      AND ((recinfo.ATTRIBUTE11 = X_ATTRIBUTE11)
           OR ((recinfo.ATTRIBUTE11 is null) AND (X_ATTRIBUTE11 is null)))
      AND ((recinfo.ATTRIBUTE12 = X_ATTRIBUTE12)
           OR ((recinfo.ATTRIBUTE12 is null) AND (X_ATTRIBUTE12 is null)))
      AND ((recinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
           OR ((recinfo.ATTRIBUTE13 is null) AND (X_ATTRIBUTE13 is null)))
      AND ((recinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
           OR ((recinfo.ATTRIBUTE14 is null) AND (X_ATTRIBUTE14 is null)))
      AND ((recinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
           OR ((recinfo.ATTRIBUTE15 is null) AND (X_ATTRIBUTE15 is null)))
      AND ((recinfo.ATTRIBUTE_CATEGORY_CODE = X_ATTRIBUTE_CATEGORY_CODE)
           OR ((recinfo.ATTRIBUTE_CATEGORY_CODE is null) AND (X_ATTRIBUTE_CATEGORY_CODE is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.MEANING = X_MEANING)
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
  X_LOOKUP_TYPE in VARCHAR2,
  X_LOOKUP_CODE in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE_CATEGORY_CODE in VARCHAR2,
  X_MEANING in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) is
begin
  update FA_LOOKUPS_B set
    ENABLED_FLAG = X_ENABLED_FLAG,
    START_DATE_ACTIVE = X_START_DATE_ACTIVE,
    END_DATE_ACTIVE = X_END_DATE_ACTIVE,
    ATTRIBUTE1 = X_ATTRIBUTE1,
    ATTRIBUTE2 = X_ATTRIBUTE2,
    ATTRIBUTE3 = X_ATTRIBUTE3,
    ATTRIBUTE4 = X_ATTRIBUTE4,
    ATTRIBUTE5 = X_ATTRIBUTE5,
    ATTRIBUTE6 = X_ATTRIBUTE6,
    ATTRIBUTE7 = X_ATTRIBUTE7,
    ATTRIBUTE8 = X_ATTRIBUTE8,
    ATTRIBUTE9 = X_ATTRIBUTE9,
    ATTRIBUTE10 = X_ATTRIBUTE10,
    ATTRIBUTE11 = X_ATTRIBUTE11,
    ATTRIBUTE12 = X_ATTRIBUTE12,
    ATTRIBUTE13 = X_ATTRIBUTE13,
    ATTRIBUTE14 = X_ATTRIBUTE14,
    ATTRIBUTE15 = X_ATTRIBUTE15,
    ATTRIBUTE_CATEGORY_CODE = X_ATTRIBUTE_CATEGORY_CODE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where LOOKUP_TYPE = X_LOOKUP_TYPE
  and LOOKUP_CODE = X_LOOKUP_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update FA_LOOKUPS_TL set
    MEANING = X_MEANING,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where LOOKUP_TYPE = X_LOOKUP_TYPE
  and LOOKUP_CODE = X_LOOKUP_CODE
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_LOOKUP_TYPE in VARCHAR2,
  X_LOOKUP_CODE in VARCHAR2
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) is
begin
  delete from FA_LOOKUPS_TL
  where LOOKUP_TYPE = X_LOOKUP_TYPE
  and LOOKUP_CODE = X_LOOKUP_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from FA_LOOKUPS_B
  where LOOKUP_TYPE = X_LOOKUP_TYPE
  and LOOKUP_CODE = X_LOOKUP_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from FA_LOOKUPS_TL T
  where not exists
    (select NULL
    from FA_LOOKUPS_B B
    where B.LOOKUP_TYPE = T.LOOKUP_TYPE
    and B.LOOKUP_CODE = T.LOOKUP_CODE
    );

  update FA_LOOKUPS_TL T set (
      MEANING,
      DESCRIPTION
    ) = (select
      B.MEANING,
      B.DESCRIPTION
    from FA_LOOKUPS_TL B
    where B.LOOKUP_TYPE = T.LOOKUP_TYPE
    and B.LOOKUP_CODE = T.LOOKUP_CODE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.LOOKUP_TYPE,
      T.LOOKUP_CODE,
      T.LANGUAGE
  ) in (select
      SUBT.LOOKUP_TYPE,
      SUBT.LOOKUP_CODE,
      SUBT.LANGUAGE
    from FA_LOOKUPS_TL SUBB, FA_LOOKUPS_TL SUBT
    where SUBB.LOOKUP_TYPE = SUBT.LOOKUP_TYPE
    and SUBB.LOOKUP_CODE = SUBT.LOOKUP_CODE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.MEANING <> SUBT.MEANING
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into FA_LOOKUPS_TL (
    LOOKUP_TYPE,
    LOOKUP_CODE,
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
    B.LOOKUP_CODE,
    B.MEANING,
    B.DESCRIPTION,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from FA_LOOKUPS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from FA_LOOKUPS_TL T
    where T.LOOKUP_TYPE = B.LOOKUP_TYPE
    and T.LOOKUP_CODE = B.LOOKUP_CODE
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure LOAD_ROW (
    X_LOOKUP_TYPE in VARCHAR2,
    X_LOOKUP_CODE in VARCHAR2,
    X_OWNER in VARCHAR2,
    X_MEANING in VARCHAR2,
    X_ENABLED_FLAG in VARCHAR2,
    X_DESCRIPTION in VARCHAR2,
    X_START_DATE_ACTIVE in DATE,
    X_END_DATE_ACTIVE in DATE,
    X_ATTRIBUTE1 in VARCHAR2,
    X_ATTRIBUTE2 in VARCHAR2,
    X_ATTRIBUTE3 in VARCHAR2,
    X_ATTRIBUTE4 in VARCHAR2,
    X_ATTRIBUTE5 in VARCHAR2,
    X_ATTRIBUTE6 in VARCHAR2,
    X_ATTRIBUTE7 in VARCHAR2,
    X_ATTRIBUTE8 in VARCHAR2,
    X_ATTRIBUTE9 in VARCHAR2,
    X_ATTRIBUTE10 in VARCHAR2,
    X_ATTRIBUTE11 in VARCHAR2,
    X_ATTRIBUTE12 in VARCHAR2,
    X_ATTRIBUTE13 in VARCHAR2,
    X_ATTRIBUTE14 in VARCHAR2,
    X_ATTRIBUTE15 in VARCHAR2,
    X_ATTRIBUTE_CATEGORY_CODE in VARCHAR2
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
  from	fa_lookups
  where lookup_type = X_Lookup_Type
  and	lookup_code = X_Lookup_Code;

if (h_record_exists > 0) then
  fa_lookups_pkg.update_row (
    X_Lookup_Type		=> X_Lookup_Type,
    X_Lookup_Code		=> X_Lookup_Code,
    X_Enabled_Flag		=> X_Enabled_Flag,
    X_Start_Date_Active		=> X_Start_Date_Active,
    X_End_Date_Active		=> X_End_Date_Active,
    X_Attribute1		=> X_Attribute1,
    X_Attribute2                => X_Attribute2,
    X_Attribute3                => X_Attribute3,
    X_Attribute4                => X_Attribute4,
    X_Attribute5                => X_Attribute5,
    X_Attribute6                => X_Attribute6,
    X_Attribute7                => X_Attribute7,
    X_Attribute8                => X_Attribute8,
    X_Attribute9                => X_Attribute9,
    X_Attribute10               => X_Attribute10,
    X_Attribute11               => X_Attribute11,
    X_Attribute12               => X_Attribute12,
    X_Attribute13               => X_Attribute13,
    X_Attribute14               => X_Attribute14,
    X_Attribute15               => X_Attribute15,
    X_Attribute_Category_Code	=> X_Attribute_Category_Code,
    X_Meaning			=> X_Meaning,
    X_Description		=> X_Description,
    X_Last_Update_Date		=> sysdate,
    X_Last_Updated_By		=> user_id,
    X_Last_Update_Login		=> 0
, p_log_level_rec => p_log_level_rec);
else
  fa_lookups_pkg.insert_row (
    X_Rowid			=> row_id,
    X_Lookup_Type               => X_Lookup_Type,
    X_Lookup_Code               => X_Lookup_Code,
    X_Enabled_Flag              => X_Enabled_Flag,
    X_Start_Date_Active         => X_Start_Date_Active,
    X_End_Date_Active           => X_End_Date_Active,
    X_Attribute1                => X_Attribute1,
    X_Attribute2                => X_Attribute2,
    X_Attribute3                => X_Attribute3,
    X_Attribute4                => X_Attribute4,
    X_Attribute5                => X_Attribute5,
    X_Attribute6                => X_Attribute6,
    X_Attribute7                => X_Attribute7,
    X_Attribute8                => X_Attribute8,
    X_Attribute9                => X_Attribute9,
    X_Attribute10               => X_Attribute10,
    X_Attribute11               => X_Attribute11,
    X_Attribute12               => X_Attribute12,
    X_Attribute13               => X_Attribute13,
    X_Attribute14               => X_Attribute14,
    X_Attribute15               => X_Attribute15,
    X_Attribute_Category_Code   => X_Attribute_Category_Code,
    X_Meaning                   => X_Meaning,
    X_Description               => X_Description,
    X_Creation_Date		=> sysdate,
    X_Created_By		=> user_id,
    X_Last_Update_Date          => sysdate,
    X_Last_Updated_By           => user_id,
    X_Last_Update_Login         => 0
, p_log_level_rec => p_log_level_rec);
end if;

exception
   when others then
       FA_STANDARD_PKG.RAISE_ERROR(
			CALLED_FN => 'fa_lookups_pkg.load_row',
			CALLING_FN => 'upload fa_lookups',
                        p_log_level_rec => p_log_level_rec);

end LOAD_ROW;
/*Bug 8355119 overloading function for release specific signatures*/
procedure LOAD_ROW (
    X_CUSTOM_MODE in VARCHAR2,
    X_LOOKUP_TYPE in VARCHAR2,
    X_LOOKUP_CODE in VARCHAR2,
    X_OWNER in VARCHAR2,
    X_LAST_UPDATE_DATE in DATE,
    X_MEANING in VARCHAR2,
    X_ENABLED_FLAG in VARCHAR2,
    X_DESCRIPTION in VARCHAR2,
    X_START_DATE_ACTIVE in DATE,
    X_END_DATE_ACTIVE in DATE,
    X_ATTRIBUTE1 in VARCHAR2,
    X_ATTRIBUTE2 in VARCHAR2,
    X_ATTRIBUTE3 in VARCHAR2,
    X_ATTRIBUTE4 in VARCHAR2,
    X_ATTRIBUTE5 in VARCHAR2,
    X_ATTRIBUTE6 in VARCHAR2,
    X_ATTRIBUTE7 in VARCHAR2,
    X_ATTRIBUTE8 in VARCHAR2,
    X_ATTRIBUTE9 in VARCHAR2,
    X_ATTRIBUTE10 in VARCHAR2,
    X_ATTRIBUTE11 in VARCHAR2,
    X_ATTRIBUTE12 in VARCHAR2,
    X_ATTRIBUTE13 in VARCHAR2,
    X_ATTRIBUTE14 in VARCHAR2,
    X_ATTRIBUTE15 in VARCHAR2,
    X_ATTRIBUTE_CATEGORY_CODE in VARCHAR2,
    p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) is

  h_record_exists	number(15);

  user_id		number;
  row_id		varchar2(64);

  db_last_updated_by   number;
  db_last_update_date  date;

begin

  user_id := fnd_load_util.owner_id (X_Owner);

  select count(*)
  into	h_record_exists
  from	fa_lookups
  where lookup_type = X_Lookup_Type
  and	lookup_code = X_Lookup_Code;

  if (h_record_exists > 0) then

     select last_updated_by, last_update_date
     into   db_last_updated_by, db_last_update_date
     from   fa_lookups
     where  lookup_type = x_lookup_type
     and    lookup_code = x_lookup_code;

     if (fnd_load_util.upload_test(user_id, x_last_update_date,
                                   db_last_updated_by, db_last_update_date,
                                   X_CUSTOM_MODE)) then

        fa_lookups_pkg.update_row (
           X_Lookup_Type		=> X_Lookup_Type,
           X_Lookup_Code		=> X_Lookup_Code,
           X_Enabled_Flag		=> X_Enabled_Flag,
           X_Start_Date_Active		=> X_Start_Date_Active,
           X_End_Date_Active		=> X_End_Date_Active,
           X_Attribute1                 => X_Attribute1,
           X_Attribute2                 => X_Attribute2,
           X_Attribute3                 => X_Attribute3,
           X_Attribute4                 => X_Attribute4,
           X_Attribute5                 => X_Attribute5,
           X_Attribute6                 => X_Attribute6,
           X_Attribute7                 => X_Attribute7,
           X_Attribute8                 => X_Attribute8,
           X_Attribute9                 => X_Attribute9,
           X_Attribute10                => X_Attribute10,
           X_Attribute11                => X_Attribute11,
           X_Attribute12                => X_Attribute12,
           X_Attribute13                => X_Attribute13,
           X_Attribute14                => X_Attribute14,
           X_Attribute15                => X_Attribute15,
           X_Attribute_Category_Code	=> X_Attribute_Category_Code,
           X_Meaning			=> X_Meaning,
           X_Description		=> X_Description,
           X_Last_Update_Date		=> X_Last_Update_Date,
           X_Last_Updated_By		=> user_id,
           X_Last_Update_Login		=> 0
           ,p_log_level_rec => p_log_level_rec);
   end if;
else
  fa_lookups_pkg.insert_row (
    X_Rowid			=> row_id,
    X_Lookup_Type               => X_Lookup_Type,
    X_Lookup_Code               => X_Lookup_Code,
    X_Enabled_Flag              => X_Enabled_Flag,
    X_Start_Date_Active         => X_Start_Date_Active,
    X_End_Date_Active           => X_End_Date_Active,
    X_Attribute1                => X_Attribute1,
    X_Attribute2                => X_Attribute2,
    X_Attribute3                => X_Attribute3,
    X_Attribute4                => X_Attribute4,
    X_Attribute5                => X_Attribute5,
    X_Attribute6                => X_Attribute6,
    X_Attribute7                => X_Attribute7,
    X_Attribute8                => X_Attribute8,
    X_Attribute9                => X_Attribute9,
    X_Attribute10               => X_Attribute10,
    X_Attribute11               => X_Attribute11,
    X_Attribute12               => X_Attribute12,
    X_Attribute13               => X_Attribute13,
    X_Attribute14               => X_Attribute14,
    X_Attribute15               => X_Attribute15,
    X_Attribute_Category_Code   => X_Attribute_Category_Code,
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
			CALLED_FN => 'fa_lookups_pkg.load_row',
			CALLING_FN => 'upload fa_lookups'
			,p_log_level_rec => p_log_level_rec);

end LOAD_ROW;

procedure TRANSLATE_ROW (
    X_LOOKUP_TYPE in VARCHAR2,
    X_LOOKUP_CODE in VARCHAR2,
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

update FA_LOOKUPS_TL set
  MEANING = nvl(X_Meaning, MEANING),
  DESCRIPTION = nvl(X_Description, DESCRIPTION),
  LAST_UPDATE_DATE = sysdate,
  LAST_UPDATED_BY = user_id,
  LAST_UPDATE_LOGIN = 0,
  SOURCE_LANG = userenv('LANG')
where userenv('LANG') in (LANGUAGE, SOURCE_LANG)
and LOOKUP_TYPE = X_Lookup_Type
and LOOKUP_CODE = X_Lookup_Code;

end TRANSLATE_ROW;
/*Bug 8355119 overloading function for release specific signatures*/
procedure TRANSLATE_ROW (
    X_CUSTOM_MODE in VARCHAR2,
    X_LOOKUP_TYPE in VARCHAR2,
    X_LOOKUP_CODE in VARCHAR2,
    X_OWNER in VARCHAR2,
    X_LAST_UPDATE_DATE in DATE,
    X_MEANING in VARCHAR2,
    X_DESCRIPTION in VARCHAR2,
    p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) is

  user_id              number;

  db_last_updated_by   number;
  db_last_update_date  date;

begin

select last_updated_by, last_update_date
into   db_last_updated_by, db_last_update_date
from   fa_lookups_tl
where  lookup_type = x_lookup_type
and    lookup_code = x_lookup_code
and    userenv('LANG') in (LANGUAGE, SOURCE_LANG);

user_id := fnd_load_util.owner_id (X_Owner);

if (fnd_load_util.upload_test(user_id, sysdate,
                              db_last_updated_by, db_last_update_date,
                              X_CUSTOM_MODE)) then

   update FA_LOOKUPS_TL set
     MEANING = nvl(X_Meaning, MEANING),
     DESCRIPTION = nvl(X_Description, DESCRIPTION),
     LAST_UPDATE_DATE = X_Last_Update_Date,
     LAST_UPDATED_BY = user_id,
     LAST_UPDATE_LOGIN = 0,
     SOURCE_LANG = userenv('LANG')
   where userenv('LANG') in (LANGUAGE, SOURCE_LANG)
   and LOOKUP_TYPE = X_Lookup_Type
   and LOOKUP_CODE = X_Lookup_Code;

end if;

end TRANSLATE_ROW;
/*bug 8355119 adding R12 specific funtion LOAD_SEED_ROW*/
procedure LOAD_SEED_ROW (
            x_upload_mode               IN VARCHAR2,
            x_custom_mode               IN VARCHAR2,
            x_lookup_type               IN VARCHAR2,
            x_lookup_code               IN VARCHAR2,
            x_owner                     IN VARCHAR2,
            x_last_update_date          IN DATE,
            x_meaning                   IN VARCHAR2,
            x_enabled_flag              IN VARCHAR2,
            x_description               IN VARCHAR2,
            x_start_date_active         IN DATE,
            x_end_date_active           IN DATE,
            x_attribute1                IN VARCHAR2,
            x_attribute2                IN VARCHAR2,
            x_attribute3                IN VARCHAR2,
            x_attribute4                IN VARCHAR2,
            x_attribute5                IN VARCHAR2,
            x_attribute6                IN VARCHAR2,
            x_attribute7                IN VARCHAR2,
            x_attribute8                IN VARCHAR2,
            x_attribute9                IN VARCHAR2,
            x_attribute10               IN VARCHAR2,
            x_attribute11               IN VARCHAR2,
            x_attribute12               IN VARCHAR2,
            x_attribute13               IN VARCHAR2,
            x_attribute14               IN VARCHAR2,
            x_attribute15               IN VARCHAR2,
            x_attribute_category_code   IN VARCHAR2) IS


BEGIN

        if (x_upload_mode = 'NLS') then
           fa_lookups_pkg.TRANSLATE_ROW (
             x_custom_mode              => x_custom_mode,
             x_lookup_type              => x_lookup_type,
             x_lookup_code              => x_lookup_code,
             x_owner                    => x_owner,
             x_last_update_date         => x_last_update_date,
             x_meaning                  => x_meaning,
             x_description              => x_description);
         else
           fa_lookups_pkg.LOAD_ROW (
             x_custom_mode              => x_custom_mode,
             x_lookup_type              => x_lookup_type,
             x_lookup_code              => x_lookup_code,
             x_owner                    => x_owner,
             x_last_update_date         => x_last_update_date,
             x_meaning                  => x_meaning,
             x_enabled_flag             => x_enabled_flag,
             x_description              => x_description,
             x_start_date_active        => x_start_date_active,
             x_end_date_active          => x_end_date_active,
             x_attribute1               => x_attribute1,
             x_attribute2               => x_attribute2,
             x_attribute3               => x_attribute3,
             x_attribute4               => x_attribute4,
             x_attribute5               => x_attribute5,
             x_attribute6               => x_attribute6,
             x_attribute7               => x_attribute7,
             x_attribute8               => x_attribute8,
             x_attribute9               => x_attribute9,
             x_attribute10              => x_attribute10,
             x_attribute11              => x_attribute11,
             x_attribute12              => x_attribute12,
             x_attribute13              => x_attribute13,
             x_attribute14              => x_attribute14,
             x_attribute15              => x_attribute15,
             x_attribute_category_code  => x_attribute_category_code);

         end if;

END LOAD_SEED_ROW;

end FA_LOOKUPS_PKG;

/
