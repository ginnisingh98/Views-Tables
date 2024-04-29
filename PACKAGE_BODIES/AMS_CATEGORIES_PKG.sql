--------------------------------------------------------
--  DDL for Package Body AMS_CATEGORIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_CATEGORIES_PKG" as
/* $Header: amslctyb.pls 120.0 2005/05/31 16:52:41 appldev noship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_CATEGORY_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ARC_CATEGORY_CREATED_FOR in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_PARENT_CATEGORY_ID in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
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
  X_CATEGORY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_ACCRUED_LIABILITY_ACCOUNT in NUMBER,
  X_DED_ADJUSTMENT_ACCOUNT in NUMBER
) is
  cursor C is select ROWID from AMS_CATEGORIES_B
    where CATEGORY_ID = X_CATEGORY_ID
    ;
begin
  insert into AMS_CATEGORIES_B (
    CATEGORY_ID,
    OBJECT_VERSION_NUMBER,
    ARC_CATEGORY_CREATED_FOR,
    ENABLED_FLAG,
    PARENT_CATEGORY_ID,
    ATTRIBUTE_CATEGORY,
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
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    ACCRUED_LIABILITY_ACCOUNT,
    DED_ADJUSTMENT_ACCOUNT
  ) values (
    X_CATEGORY_ID,
    X_OBJECT_VERSION_NUMBER,
    X_ARC_CATEGORY_CREATED_FOR,
    X_ENABLED_FLAG,
    X_PARENT_CATEGORY_ID,
    X_ATTRIBUTE_CATEGORY,
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
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_ACCRUED_LIABILITY_ACCOUNT,
    X_DED_ADJUSTMENT_ACCOUNT
  );

  insert into AMS_CATEGORIES_TL (
    CATEGORY_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    CATEGORY_NAME,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_CATEGORY_ID,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_CATEGORY_NAME,
    X_DESCRIPTION,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from AMS_CATEGORIES_TL T
    where T.CATEGORY_ID = X_CATEGORY_ID
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
  X_CATEGORY_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ARC_CATEGORY_CREATED_FOR in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_PARENT_CATEGORY_ID in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
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
  X_CATEGORY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_ACCRUED_LIABILITY_ACCOUNT in NUMBER,
  X_DED_ADJUSTMENT_ACCOUNT in NUMBER
) is
  cursor c is select
      OBJECT_VERSION_NUMBER,
      ARC_CATEGORY_CREATED_FOR,
      ENABLED_FLAG,
      PARENT_CATEGORY_ID,
      ATTRIBUTE_CATEGORY,
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
      ACCRUED_LIABILITY_ACCOUNT,
      DED_ADJUSTMENT_ACCOUNT
    from AMS_CATEGORIES_B
    where CATEGORY_ID = X_CATEGORY_ID
    for update of CATEGORY_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      CATEGORY_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from AMS_CATEGORIES_TL
    where CATEGORY_ID = X_CATEGORY_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of CATEGORY_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
           OR ((recinfo.OBJECT_VERSION_NUMBER is null) AND (X_OBJECT_VERSION_NUMBER is null)))
      AND ((recinfo.ARC_CATEGORY_CREATED_FOR = X_ARC_CATEGORY_CREATED_FOR)
           OR ((recinfo.ARC_CATEGORY_CREATED_FOR is null) AND (X_ARC_CATEGORY_CREATED_FOR is null)))
      AND (recinfo.ENABLED_FLAG = X_ENABLED_FLAG)
      AND ((recinfo.PARENT_CATEGORY_ID = X_PARENT_CATEGORY_ID)
           OR ((recinfo.PARENT_CATEGORY_ID is null) AND (X_PARENT_CATEGORY_ID is null)))
      AND ((recinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
           OR ((recinfo.ATTRIBUTE_CATEGORY is null) AND (X_ATTRIBUTE_CATEGORY is null)))
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
      AND ((recinfo.ACCRUED_LIABILITY_ACCOUNT = X_ACCRUED_LIABILITY_ACCOUNT)
           OR ((recinfo.ACCRUED_LIABILITY_ACCOUNT is null) AND (X_ACCRUED_LIABILITY_ACCOUNT is null)))
      AND ((recinfo.DED_ADJUSTMENT_ACCOUNT = X_DED_ADJUSTMENT_ACCOUNT)
           OR ((recinfo.DED_ADJUSTMENT_ACCOUNT is null) AND (X_DED_ADJUSTMENT_ACCOUNT is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.CATEGORY_NAME = X_CATEGORY_NAME)
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
  X_CATEGORY_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ARC_CATEGORY_CREATED_FOR in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_PARENT_CATEGORY_ID in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
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
  X_CATEGORY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_ACCRUED_LIABILITY_ACCOUNT in NUMBER,
  X_DED_ADJUSTMENT_ACCOUNT in NUMBER
) is
begin
  update AMS_CATEGORIES_B set
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    ARC_CATEGORY_CREATED_FOR = X_ARC_CATEGORY_CREATED_FOR,
    ENABLED_FLAG = X_ENABLED_FLAG,
    PARENT_CATEGORY_ID = X_PARENT_CATEGORY_ID,
    ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY,
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
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    ACCRUED_LIABILITY_ACCOUNT = X_ACCRUED_LIABILITY_ACCOUNT,
    DED_ADJUSTMENT_ACCOUNT = X_DED_ADJUSTMENT_ACCOUNT
  where CATEGORY_ID = X_CATEGORY_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update AMS_CATEGORIES_TL set
    CATEGORY_NAME = X_CATEGORY_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where CATEGORY_ID = X_CATEGORY_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_CATEGORY_ID in NUMBER
) is
begin
  delete from AMS_CATEGORIES_TL
  where CATEGORY_ID = X_CATEGORY_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from AMS_CATEGORIES_B
  where CATEGORY_ID = X_CATEGORY_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from AMS_CATEGORIES_TL T
  where not exists
    (select NULL
    from AMS_CATEGORIES_B B
    where B.CATEGORY_ID = T.CATEGORY_ID
    );

  update AMS_CATEGORIES_TL T set (
      CATEGORY_NAME,
      DESCRIPTION
    ) = (select
      B.CATEGORY_NAME,
      B.DESCRIPTION
    from AMS_CATEGORIES_TL B
    where B.CATEGORY_ID = T.CATEGORY_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.CATEGORY_ID,
      T.LANGUAGE
  ) in (select
      SUBT.CATEGORY_ID,
      SUBT.LANGUAGE
    from AMS_CATEGORIES_TL SUBB, AMS_CATEGORIES_TL SUBT
    where SUBB.CATEGORY_ID = SUBT.CATEGORY_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.CATEGORY_NAME <> SUBT.CATEGORY_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into AMS_CATEGORIES_TL (
    CATEGORY_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    CATEGORY_NAME,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.CATEGORY_ID,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.CATEGORY_NAME,
    B.DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from AMS_CATEGORIES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AMS_CATEGORIES_TL T
    where T.CATEGORY_ID = B.CATEGORY_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure TRANSLATE_ROW(
       x_category_id    in NUMBER
     , x_category_name  in VARCHAR2
     , x_description    in VARCHAR2
     , x_owner   in VARCHAR2
 ) is
 begin
    update AMS_CATEGORIES_TL set
       category_name = nvl(x_category_name, category_name),
       description = nvl(x_description, description),
       source_lang = userenv('LANG'),
       last_update_date = sysdate,
       last_updated_by = decode(x_owner, 'SEED', 1, 0),
       last_update_login = 0
    where  category_id = x_category_id
    and      userenv('LANG') in (language, source_lang);
end TRANSLATE_ROW;

procedure  LOAD_ROW(
  X_CATEGORY_ID   IN NUMBER,
  X_ARC_CATEGORY_CREATED_FOR in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_PARENT_CATEGORY_ID in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
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
  X_CATEGORY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_Owner in  VARCHAR2,
  X_ACCRUED_LIABILITY_ACCOUNT in NUMBER,
  X_DED_ADJUSTMENT_ACCOUNT in NUMBER,
  X_CUSTOM_MODE in VARCHAR2
) is

l_user_id   number := 1;
l_obj_verno  number;
l_dummy_char  varchar2(1);
l_row_id    varchar2(100);
l_category_id   number;
l_db_luby_id number;


cursor  c_db_data_details is
  select last_updated_by, nvl(object_version_number,1)
  from    AMS_CATEGORIES_B
  where  category_id =  X_CATEGORY_ID;
/*
cursor  c_obj_verno is
  select object_version_number
  from    AMS_CATEGORIES_B
  where  category_id =  X_CATEGORY_ID;
*/
cursor c_chk_cty_exists is
  select 'x'
  from   AMS_CATEGORIES_B
  where  category_id = X_CATEGORY_ID;

cursor c_get_ctyid is
   select AMS_CATEGORIES_B_S.nextval
   from dual;

BEGIN

  -- set the last_updated_by to be used while updating the data in customer data.
  if X_OWNER = 'SEED' then
    l_user_id := 1;
  elsif X_OWNER = 'ORACLE' THEN
    l_user_id := 2;
  elsif X_OWNER = 'SYSADMIN' THEN
    l_user_id := 0;
  end if ;

 open c_chk_cty_exists;
 fetch c_chk_cty_exists into l_dummy_char;
 if c_chk_cty_exists%notfound
-- data does not exist at customer site and hence create the data
 then
    close c_chk_cty_exists;
    if X_CATEGORY_ID is null
    then
      open c_get_ctyid;
      fetch c_get_ctyid into l_category_id;
      close c_get_ctyid;
    else
       l_category_id := X_CATEGORY_ID;
    end if;
    l_obj_verno := 1;
    AMS_CATEGORIES_PKG.INSERT_ROW(
    X_ROWID                    =>   l_row_id,
    X_CATEGORY_ID              =>  l_category_id,
    X_OBJECT_VERSION_NUMBER    => l_obj_verno,
    X_ARC_CATEGORY_CREATED_FOR => X_ARC_CATEGORY_CREATED_FOR ,
    X_ENABLED_FLAG             => X_ENABLED_FLAG,
    X_PARENT_CATEGORY_ID       => X_PARENT_CATEGORY_ID,
    X_ATTRIBUTE_CATEGORY       =>  X_ATTRIBUTE_CATEGORY,
    X_ATTRIBUTE1               =>  X_ATTRIBUTE1,
    X_ATTRIBUTE2               =>  X_ATTRIBUTE2,
    X_ATTRIBUTE3               =>  X_ATTRIBUTE3,
    X_ATTRIBUTE4               =>  X_ATTRIBUTE4,
    X_ATTRIBUTE5               =>  X_ATTRIBUTE5,
    X_ATTRIBUTE6               =>  X_ATTRIBUTE6,
    X_ATTRIBUTE7               =>  X_ATTRIBUTE7,
    X_ATTRIBUTE8               =>  X_ATTRIBUTE8,
    X_ATTRIBUTE9               =>  X_ATTRIBUTE9,
    X_ATTRIBUTE10              =>  X_ATTRIBUTE10,
    X_ATTRIBUTE11              =>  X_ATTRIBUTE11,
    X_ATTRIBUTE12              =>  X_ATTRIBUTE12,
    X_ATTRIBUTE13              =>  X_ATTRIBUTE13,
    X_ATTRIBUTE14              =>  X_ATTRIBUTE14,
    X_ATTRIBUTE15              =>  X_ATTRIBUTE15,
    X_CATEGORY_NAME            =>  X_CATEGORY_NAME,
    X_DESCRIPTION              =>  X_DESCRIPTION,
    X_CREATION_DATE            =>  SYSDATE,
    X_CREATED_BY               =>  l_user_id,
    X_LAST_UPDATE_DATE         =>  SYSDATE,
    X_LAST_UPDATED_BY          =>  l_user_id,
    X_LAST_UPDATE_LOGIN	       =>  0,
    X_ACCRUED_LIABILITY_ACCOUNT => X_ACCRUED_LIABILITY_ACCOUNT,
    X_DED_ADJUSTMENT_ACCOUNT    => X_DED_ADJUSTMENT_ACCOUNT
  );
else
   -- Update the data as per above rules
   close c_chk_cty_exists;
   open c_db_data_details;
   fetch c_db_data_details into l_db_luby_id, l_obj_verno;
   close c_db_data_details;

   if (l_db_luby_id IN (1,2,0)
      OR NVL(x_custom_mode,'PRESERVE') = 'FORCE') THEN

    AMS_CATEGORIES_PKG.UPDATE_ROW(
    X_CATEGORY_ID              =>  X_CATEGORY_ID,
    X_OBJECT_VERSION_NUMBER    => l_obj_verno + 1,
    X_ARC_CATEGORY_CREATED_FOR => X_ARC_CATEGORY_CREATED_FOR ,
    X_ENABLED_FLAG             => X_ENABLED_FLAG,
    X_PARENT_CATEGORY_ID       => X_PARENT_CATEGORY_ID,
    X_ATTRIBUTE_CATEGORY       =>  X_ATTRIBUTE_CATEGORY,
    X_ATTRIBUTE1               =>  X_ATTRIBUTE1,
    X_ATTRIBUTE2               =>  X_ATTRIBUTE2,
    X_ATTRIBUTE3               =>  X_ATTRIBUTE3,
    X_ATTRIBUTE4               =>  X_ATTRIBUTE4,
    X_ATTRIBUTE5               =>  X_ATTRIBUTE5,
    X_ATTRIBUTE6               =>  X_ATTRIBUTE6,
    X_ATTRIBUTE7               =>  X_ATTRIBUTE7,
    X_ATTRIBUTE8               =>  X_ATTRIBUTE8,
    X_ATTRIBUTE9               =>  X_ATTRIBUTE9,
    X_ATTRIBUTE10              =>  X_ATTRIBUTE10,
    X_ATTRIBUTE11              =>  X_ATTRIBUTE11,
    X_ATTRIBUTE12              =>  X_ATTRIBUTE12,
    X_ATTRIBUTE13              =>  X_ATTRIBUTE13,
    X_ATTRIBUTE14              =>  X_ATTRIBUTE14,
    X_ATTRIBUTE15              =>  X_ATTRIBUTE15,
    X_CATEGORY_NAME            =>  X_CATEGORY_NAME,
    X_DESCRIPTION              =>  X_DESCRIPTION,
    X_LAST_UPDATE_DATE         =>  SYSDATE,
    X_LAST_UPDATED_BY          =>  l_user_id,
    X_LAST_UPDATE_LOGIN	       =>  0,
    X_ACCRUED_LIABILITY_ACCOUNT => X_ACCRUED_LIABILITY_ACCOUNT,
    X_DED_ADJUSTMENT_ACCOUNT    => X_DED_ADJUSTMENT_ACCOUNT
  );

  end if;
end if;

END LOAD_ROW;

end AMS_CATEGORIES_PKG;

/
