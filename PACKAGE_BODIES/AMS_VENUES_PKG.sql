--------------------------------------------------------
--  DDL for Package Body AMS_VENUES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_VENUES_PKG" as
/* $Header: amslvnub.pls 115.3 2002/11/16 00:41:58 dbiswas noship $ */
procedure INSERT_ROW (
  X_ROWID in OUT NOCOPY VARCHAR2,
  X_VENUE_ID in NUMBER,
  --X_SECURITY_GROUP_ID in NUMBER,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_VENUE_TYPE_CODE in VARCHAR2,
  X_DIRECT_PHONE_FLAG in VARCHAR2,
  X_INTERNAL_FLAG in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_RATING_CODE in VARCHAR2,
  X_CAPACITY in NUMBER,
  X_AREA_SIZE in NUMBER,
  X_AREA_SIZE_UOM_CODE in VARCHAR2,
  X_CEILING_HEIGHT in NUMBER,
  X_CEILING_HEIGHT_UOM_CODE in VARCHAR2,
  X_USAGE_COST in NUMBER,
  X_USAGE_COST_CURRENCY_CODE in VARCHAR2,
  X_USAGE_COST_UOM_CODE in VARCHAR2,
  X_PARENT_VENUE_ID in NUMBER,
  X_LOCATION_ID in NUMBER,
  X_DIRECTIONS in VARCHAR2,
  X_VENUE_CODE in VARCHAR2,
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
  X_VENUE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from AMS_VENUES_B
    where VENUE_ID = X_VENUE_ID
    ;
begin
  insert into AMS_VENUES_B (
    --SECURITY_GROUP_ID,
    ATTRIBUTE10,
    ATTRIBUTE11,
    ATTRIBUTE12,
    ATTRIBUTE13,
    ATTRIBUTE14,
    ATTRIBUTE15,
    VENUE_ID,
    OBJECT_VERSION_NUMBER,
    VENUE_TYPE_CODE,
    DIRECT_PHONE_FLAG,
    INTERNAL_FLAG,
    ENABLED_FLAG,
    RATING_CODE,
    CAPACITY,
    AREA_SIZE,
    AREA_SIZE_UOM_CODE,
    CEILING_HEIGHT,
    CEILING_HEIGHT_UOM_CODE,
    USAGE_COST,
    USAGE_COST_CURRENCY_CODE,
    USAGE_COST_UOM_CODE,
    PARENT_VENUE_ID,
    LOCATION_ID,
    DIRECTIONS,
    VENUE_CODE,
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
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    --X_SECURITY_GROUP_ID,
    X_ATTRIBUTE10,
    X_ATTRIBUTE11,
    X_ATTRIBUTE12,
    X_ATTRIBUTE13,
    X_ATTRIBUTE14,
    X_ATTRIBUTE15,
    X_VENUE_ID,
    X_OBJECT_VERSION_NUMBER,
    X_VENUE_TYPE_CODE,
    X_DIRECT_PHONE_FLAG,
    X_INTERNAL_FLAG,
    X_ENABLED_FLAG,
    X_RATING_CODE,
    X_CAPACITY,
    X_AREA_SIZE,
    X_AREA_SIZE_UOM_CODE,
    X_CEILING_HEIGHT,
    X_CEILING_HEIGHT_UOM_CODE,
    X_USAGE_COST,
    X_USAGE_COST_CURRENCY_CODE,
    X_USAGE_COST_UOM_CODE,
    X_PARENT_VENUE_ID,
    X_LOCATION_ID,
    X_DIRECTIONS,
    X_VENUE_CODE,
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
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into AMS_VENUES_TL (
    --SECURITY_GROUP_ID,
    VENUE_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    VENUE_NAME,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    --X_SECURITY_GROUP_ID,
    X_VENUE_ID,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_VENUE_NAME,
    X_DESCRIPTION,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from AMS_VENUES_TL T
    where T.VENUE_ID = X_VENUE_ID
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
  X_VENUE_ID in NUMBER,
  --X_SECURITY_GROUP_ID in NUMBER,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_VENUE_TYPE_CODE in VARCHAR2,
  X_DIRECT_PHONE_FLAG in VARCHAR2,
  X_INTERNAL_FLAG in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_RATING_CODE in VARCHAR2,
  X_CAPACITY in NUMBER,
  X_AREA_SIZE in NUMBER,
  X_AREA_SIZE_UOM_CODE in VARCHAR2,
  X_CEILING_HEIGHT in NUMBER,
  X_CEILING_HEIGHT_UOM_CODE in VARCHAR2,
  X_USAGE_COST in NUMBER,
  X_USAGE_COST_CURRENCY_CODE in VARCHAR2,
  X_USAGE_COST_UOM_CODE in VARCHAR2,
  X_PARENT_VENUE_ID in NUMBER,
  X_LOCATION_ID in NUMBER,
  X_DIRECTIONS in VARCHAR2,
  X_VENUE_CODE in VARCHAR2,
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
  X_VENUE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      --SECURITY_GROUP_ID,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15,
      OBJECT_VERSION_NUMBER,
      VENUE_TYPE_CODE,
      DIRECT_PHONE_FLAG,
      INTERNAL_FLAG,
      ENABLED_FLAG,
      RATING_CODE,
      CAPACITY,
      AREA_SIZE,
      AREA_SIZE_UOM_CODE,
      CEILING_HEIGHT,
      CEILING_HEIGHT_UOM_CODE,
      USAGE_COST,
      USAGE_COST_CURRENCY_CODE,
      USAGE_COST_UOM_CODE,
      PARENT_VENUE_ID,
      LOCATION_ID,
      DIRECTIONS,
      VENUE_CODE,
      ATTRIBUTE_CATEGORY,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9
    from AMS_VENUES_B
    where VENUE_ID = X_VENUE_ID
    for update of VENUE_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      VENUE_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from AMS_VENUES_TL
    where VENUE_ID = X_VENUE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of VENUE_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
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
      AND ((recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
           OR ((recinfo.OBJECT_VERSION_NUMBER is null) AND (X_OBJECT_VERSION_NUMBER is null)))
      AND (recinfo.VENUE_TYPE_CODE = X_VENUE_TYPE_CODE)
      AND (recinfo.DIRECT_PHONE_FLAG = X_DIRECT_PHONE_FLAG)
      AND (recinfo.INTERNAL_FLAG = X_INTERNAL_FLAG)
      AND (recinfo.ENABLED_FLAG = X_ENABLED_FLAG)
      AND ((recinfo.RATING_CODE = X_RATING_CODE)
           OR ((recinfo.RATING_CODE is null) AND (X_RATING_CODE is null)))
      AND ((recinfo.CAPACITY = X_CAPACITY)
           OR ((recinfo.CAPACITY is null) AND (X_CAPACITY is null)))
      AND ((recinfo.AREA_SIZE = X_AREA_SIZE)
           OR ((recinfo.AREA_SIZE is null) AND (X_AREA_SIZE is null)))
      AND ((recinfo.AREA_SIZE_UOM_CODE = X_AREA_SIZE_UOM_CODE)
           OR ((recinfo.AREA_SIZE_UOM_CODE is null) AND (X_AREA_SIZE_UOM_CODE is null)))
      AND ((recinfo.CEILING_HEIGHT = X_CEILING_HEIGHT)
           OR ((recinfo.CEILING_HEIGHT is null) AND (X_CEILING_HEIGHT is null)))
      AND ((recinfo.CEILING_HEIGHT_UOM_CODE = X_CEILING_HEIGHT_UOM_CODE)
           OR ((recinfo.CEILING_HEIGHT_UOM_CODE is null) AND (X_CEILING_HEIGHT_UOM_CODE is null)))
      AND ((recinfo.USAGE_COST = X_USAGE_COST)
           OR ((recinfo.USAGE_COST is null) AND (X_USAGE_COST is null)))
      AND ((recinfo.USAGE_COST_CURRENCY_CODE = X_USAGE_COST_CURRENCY_CODE)
           OR ((recinfo.USAGE_COST_CURRENCY_CODE is null) AND (X_USAGE_COST_CURRENCY_CODE is null)))
      AND ((recinfo.USAGE_COST_UOM_CODE = X_USAGE_COST_UOM_CODE)
           OR ((recinfo.USAGE_COST_UOM_CODE is null) AND (X_USAGE_COST_UOM_CODE is null)))
      AND ((recinfo.PARENT_VENUE_ID = X_PARENT_VENUE_ID)
           OR ((recinfo.PARENT_VENUE_ID is null) AND (X_PARENT_VENUE_ID is null)))
      AND ((recinfo.LOCATION_ID = X_LOCATION_ID)
           OR ((recinfo.LOCATION_ID is null) AND (X_LOCATION_ID is null)))
      AND ((recinfo.DIRECTIONS = X_DIRECTIONS)
           OR ((recinfo.DIRECTIONS is null) AND (X_DIRECTIONS is null)))
      AND ((recinfo.VENUE_CODE = X_VENUE_CODE)
           OR ((recinfo.VENUE_CODE is null) AND (X_VENUE_CODE is null)))
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
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.VENUE_NAME = X_VENUE_NAME)
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
  X_VENUE_ID in NUMBER,
  --X_SECURITY_GROUP_ID in NUMBER,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_VENUE_TYPE_CODE in VARCHAR2,
  X_DIRECT_PHONE_FLAG in VARCHAR2,
  X_INTERNAL_FLAG in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_RATING_CODE in VARCHAR2,
  X_CAPACITY in NUMBER,
  X_AREA_SIZE in NUMBER,
  X_AREA_SIZE_UOM_CODE in VARCHAR2,
  X_CEILING_HEIGHT in NUMBER,
  X_CEILING_HEIGHT_UOM_CODE in VARCHAR2,
  X_USAGE_COST in NUMBER,
  X_USAGE_COST_CURRENCY_CODE in VARCHAR2,
  X_USAGE_COST_UOM_CODE in VARCHAR2,
  X_PARENT_VENUE_ID in NUMBER,
  X_LOCATION_ID in NUMBER,
  X_DIRECTIONS in VARCHAR2,
  X_VENUE_CODE in VARCHAR2,
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
  X_VENUE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update AMS_VENUES_B set
    --SECURITY_GROUP_ID = X_SECURITY_GROUP_ID,
    ATTRIBUTE10 = X_ATTRIBUTE10,
    ATTRIBUTE11 = X_ATTRIBUTE11,
    ATTRIBUTE12 = X_ATTRIBUTE12,
    ATTRIBUTE13 = X_ATTRIBUTE13,
    ATTRIBUTE14 = X_ATTRIBUTE14,
    ATTRIBUTE15 = X_ATTRIBUTE15,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    VENUE_TYPE_CODE = X_VENUE_TYPE_CODE,
    DIRECT_PHONE_FLAG = X_DIRECT_PHONE_FLAG,
    INTERNAL_FLAG = X_INTERNAL_FLAG,
    ENABLED_FLAG = X_ENABLED_FLAG,
    RATING_CODE = X_RATING_CODE,
    CAPACITY = X_CAPACITY,
    AREA_SIZE = X_AREA_SIZE,
    AREA_SIZE_UOM_CODE = X_AREA_SIZE_UOM_CODE,
    CEILING_HEIGHT = X_CEILING_HEIGHT,
    CEILING_HEIGHT_UOM_CODE = X_CEILING_HEIGHT_UOM_CODE,
    USAGE_COST = X_USAGE_COST,
    USAGE_COST_CURRENCY_CODE = X_USAGE_COST_CURRENCY_CODE,
    USAGE_COST_UOM_CODE = X_USAGE_COST_UOM_CODE,
    PARENT_VENUE_ID = X_PARENT_VENUE_ID,
    LOCATION_ID = X_LOCATION_ID,
    DIRECTIONS = X_DIRECTIONS,
    VENUE_CODE = X_VENUE_CODE,
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
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where VENUE_ID = X_VENUE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update AMS_VENUES_TL set
    VENUE_NAME = X_VENUE_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where VENUE_ID = X_VENUE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_VENUE_ID in NUMBER
) is
begin
  delete from AMS_VENUES_TL
  where VENUE_ID = X_VENUE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from AMS_VENUES_B
  where VENUE_ID = X_VENUE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from AMS_VENUES_TL T
  where not exists
    (select NULL
    from AMS_VENUES_B B
    where B.VENUE_ID = T.VENUE_ID
    );

  update AMS_VENUES_TL T set (
      VENUE_NAME,
      DESCRIPTION
    ) = (select
      B.VENUE_NAME,
      B.DESCRIPTION
    from AMS_VENUES_TL B
    where B.VENUE_ID = T.VENUE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.VENUE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.VENUE_ID,
      SUBT.LANGUAGE
    from AMS_VENUES_TL SUBB, AMS_VENUES_TL SUBT
    where SUBB.VENUE_ID = SUBT.VENUE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.VENUE_NAME <> SUBT.VENUE_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into AMS_VENUES_TL (
    --SECURITY_GROUP_ID,
    VENUE_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    VENUE_NAME,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    --B.SECURITY_GROUP_ID,
    B.VENUE_ID,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.VENUE_NAME,
    B.DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from AMS_VENUES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AMS_VENUES_TL T
    where T.VENUE_ID = B.VENUE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure TRANSLATE_ROW(
   X_VENUE_ID  in NUMBER,
   X_NAME       in VARCHAR2,
   X_DESCRIPTION          in VARCHAR2,
   X_OWNER      in VARCHAR2
) IS
begin
   update AMS_VENUES_TL set
   venue_name = nvl(x_name, venue_name),
   description = nvl(x_description, description),
   source_lang = userenv('LANG'),
   last_update_date = sysdate,
   last_updated_by = decode(x_owner, 'SEED', 1, 0),
   last_update_login = 0
   where  VENUE_ID = X_VENUE_ID
   and      userenv('LANG') in (language, source_lang);
end TRANSLATE_ROW;

procedure LOAD_ROW (
  X_VENUE_ID in NUMBER,
  --X_SECURITY_GROUP_ID in NUMBER,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_VENUE_TYPE_CODE in VARCHAR2,
  X_DIRECT_PHONE_FLAG in VARCHAR2,
  X_INTERNAL_FLAG in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_RATING_CODE in VARCHAR2,
  X_CAPACITY in NUMBER,
  X_AREA_SIZE in NUMBER,
  X_AREA_SIZE_UOM_CODE in VARCHAR2,
  X_CEILING_HEIGHT in NUMBER,
  X_CEILING_HEIGHT_UOM_CODE in VARCHAR2,
  X_USAGE_COST in NUMBER,
  X_USAGE_COST_CURRENCY_CODE in VARCHAR2,
  X_USAGE_COST_UOM_CODE in VARCHAR2,
  X_PARENT_VENUE_ID in NUMBER,
  X_LOCATION_ID in NUMBER,
  X_DIRECTIONS in VARCHAR2,
  X_VENUE_CODE in VARCHAR2,
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
  X_VENUE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER        in VARCHAR2
  ) IS
  l_user_id number := 0;
  l_obj_verno  number;
  l_venue_id  number;
  l_dummy_char  varchar2(1);
  l_row_id    varchar2(100);

  cursor  c_obj_verno (id_in in NUMBER) is
  select object_version_number
  from    AMS_VENUES_B
  where  VENUE_ID =  id_in;

  cursor c_chk_vnu_exists (id_in in NUMBER) is
  select 'x'
  from    AMS_VENUES_B
  where  VENUE_ID =  id_in;

  cursor c_get_vnu_id is
  select AMS_VENUES_B_S.nextval
  from dual;
BEGIN
     if X_OWNER = 'SEED' then
        l_user_id := 1;
     end if;
     open c_chk_vnu_exists(X_VENUE_ID);
     fetch c_chk_vnu_exists into l_dummy_char;
     if c_chk_vnu_exists%notfound
     then
        close c_chk_vnu_exists;
        if X_VENUE_ID is null
        then
           open c_get_vnu_id;
           fetch c_get_vnu_id into l_venue_id;
           close c_get_vnu_id;
        else
           l_venue_id := X_VENUE_ID;
        end if;
        l_obj_verno := 1;
        AMS_VENUES_PKG.INSERT_ROW (
           X_ROWID  => l_row_id,
           X_VENUE_ID => l_venue_id,
           --X_SECURITY_GROUP_ID => X_SECURITY_GROUP_ID,
           X_ATTRIBUTE10 => X_ATTRIBUTE10,
           X_ATTRIBUTE11 => X_ATTRIBUTE11,
           X_ATTRIBUTE12 => X_ATTRIBUTE12,
           X_ATTRIBUTE13 => X_ATTRIBUTE13,
           X_ATTRIBUTE14 => X_ATTRIBUTE14,
           X_ATTRIBUTE15 => X_ATTRIBUTE15,
           X_OBJECT_VERSION_NUMBER => l_obj_verno,
           X_VENUE_TYPE_CODE => X_VENUE_TYPE_CODE,
           X_DIRECT_PHONE_FLAG => X_DIRECT_PHONE_FLAG,
           X_INTERNAL_FLAG => X_INTERNAL_FLAG,
           X_ENABLED_FLAG => X_ENABLED_FLAG,
           X_RATING_CODE => X_RATING_CODE,
           X_CAPACITY => X_CAPACITY,
           X_AREA_SIZE => X_AREA_SIZE,
           X_AREA_SIZE_UOM_CODE => X_AREA_SIZE_UOM_CODE,
           X_CEILING_HEIGHT => X_CEILING_HEIGHT,
           X_CEILING_HEIGHT_UOM_CODE => X_CEILING_HEIGHT_UOM_CODE,
           X_USAGE_COST => X_USAGE_COST,
           X_USAGE_COST_CURRENCY_CODE => X_USAGE_COST_CURRENCY_CODE,
           X_USAGE_COST_UOM_CODE => X_USAGE_COST_UOM_CODE,
           X_PARENT_VENUE_ID => X_PARENT_VENUE_ID,
           X_LOCATION_ID => X_LOCATION_ID,
           X_DIRECTIONS => X_DIRECTIONS,
           X_VENUE_CODE => X_VENUE_CODE,
           X_ATTRIBUTE_CATEGORY => X_ATTRIBUTE_CATEGORY,
           X_ATTRIBUTE1 => X_ATTRIBUTE1,
           X_ATTRIBUTE2 => X_ATTRIBUTE2,
           X_ATTRIBUTE3 => X_ATTRIBUTE3,
           X_ATTRIBUTE4 => X_ATTRIBUTE4,
           X_ATTRIBUTE5 => X_ATTRIBUTE5,
           X_ATTRIBUTE6 => X_ATTRIBUTE6,
           X_ATTRIBUTE7 => X_ATTRIBUTE7,
           X_ATTRIBUTE8 => X_ATTRIBUTE8,
           X_ATTRIBUTE9 => X_ATTRIBUTE9,
           X_VENUE_NAME => X_VENUE_NAME,
           X_DESCRIPTION => X_DESCRIPTION,
           X_CREATION_DATE => SYSDATE,
           X_CREATED_BY => l_user_id,
           X_LAST_UPDATE_DATE => SYSDATE,
           X_LAST_UPDATED_BY => l_user_id,
           X_LAST_UPDATE_LOGIN => 0
       );
     else
	   close c_chk_vnu_exists;
	   open c_obj_verno(X_VENUE_ID);
	   fetch c_obj_verno into l_obj_verno;
	   close c_obj_verno;
	    -- assigning value for l_user_status_id
	   l_venue_id := X_VENUE_ID;
        AMS_VENUES_PKG.update_row (
           X_VENUE_ID => l_venue_id,
           --X_SECURITY_GROUP_ID => X_SECURITY_GROUP_ID,
           X_ATTRIBUTE10 => X_ATTRIBUTE10,
           X_ATTRIBUTE11 => X_ATTRIBUTE11,
           X_ATTRIBUTE12 => X_ATTRIBUTE12,
           X_ATTRIBUTE13 => X_ATTRIBUTE13,
           X_ATTRIBUTE14 => X_ATTRIBUTE14,
           X_ATTRIBUTE15 => X_ATTRIBUTE15,
           X_OBJECT_VERSION_NUMBER => l_obj_verno+1,
           X_VENUE_TYPE_CODE => X_VENUE_TYPE_CODE,
           X_DIRECT_PHONE_FLAG => X_DIRECT_PHONE_FLAG,
           X_INTERNAL_FLAG => X_INTERNAL_FLAG,
           X_ENABLED_FLAG => X_ENABLED_FLAG,
           X_RATING_CODE => X_RATING_CODE,
           X_CAPACITY => X_CAPACITY,
           X_AREA_SIZE => X_AREA_SIZE,
           X_AREA_SIZE_UOM_CODE => X_AREA_SIZE_UOM_CODE,
           X_CEILING_HEIGHT => X_CEILING_HEIGHT,
           X_CEILING_HEIGHT_UOM_CODE => X_CEILING_HEIGHT_UOM_CODE,
           X_USAGE_COST => X_USAGE_COST,
           X_USAGE_COST_CURRENCY_CODE => X_USAGE_COST_CURRENCY_CODE,
           X_USAGE_COST_UOM_CODE => X_USAGE_COST_UOM_CODE,
           X_PARENT_VENUE_ID => X_PARENT_VENUE_ID,
           X_LOCATION_ID => X_LOCATION_ID,
           X_DIRECTIONS => X_DIRECTIONS,
           X_VENUE_CODE => X_VENUE_CODE,
           X_ATTRIBUTE_CATEGORY => X_ATTRIBUTE_CATEGORY,
           X_ATTRIBUTE1 => X_ATTRIBUTE1,
           X_ATTRIBUTE2 => X_ATTRIBUTE2,
           X_ATTRIBUTE3 => X_ATTRIBUTE3,
           X_ATTRIBUTE4 => X_ATTRIBUTE4,
           X_ATTRIBUTE5 => X_ATTRIBUTE5,
           X_ATTRIBUTE6 => X_ATTRIBUTE6,
           X_ATTRIBUTE7 => X_ATTRIBUTE7,
           X_ATTRIBUTE8 => X_ATTRIBUTE8,
           X_ATTRIBUTE9 => X_ATTRIBUTE9,
           X_VENUE_NAME => X_VENUE_NAME,
           X_DESCRIPTION => X_DESCRIPTION,
           X_LAST_UPDATE_DATE => SYSDATE,
           X_LAST_UPDATED_BY => l_user_id,
           X_LAST_UPDATE_LOGIN => 0
	    );
     END IF;
END LOAD_ROW;
end AMS_VENUES_PKG;

/
