--------------------------------------------------------
--  DDL for Package Body MTL_UOM_CLASSES_TL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MTL_UOM_CLASSES_TL_PKG" as
/* $Header: INVUOCSB.pls 120.2 2006/06/16 15:08:15 amohamme noship $ */
--
/* this version assumes that the userenv('LANG') is the language for the user session */
procedure INSERT_ROW (
  X_ROWID IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
  X_UOM_CLASS in VARCHAR2,
  X_UOM_CLASS_TL in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_DISABLE_DATE in DATE,
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
  X_REQUEST_ID in NUMBER,
  X_PROGRAM_ID in NUMBER,
  X_PROGRAM_APPLICATION_ID in NUMBER,
  X_PROGRAM_UPDATE_DATE in DATE,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) as
begin
   insert_row (
	       x_rowid,
	       x_uom_class ,
	       x_uom_class_tl ,
	       x_description ,
	       x_disable_date,
	       x_attribute_category ,
	       x_attribute1 ,
	       x_attribute2 ,
	       x_attribute3 ,
	       x_attribute4 ,
	       x_attribute5 ,
	       x_attribute6 ,
	       x_attribute7 ,
	       x_attribute8 ,
	       x_attribute9 ,
	       x_attribute10 ,
	       x_attribute11 ,
	       x_attribute12 ,
	       x_attribute13 ,
	       x_attribute14 ,
	       x_attribute15 ,
	       x_request_id,
	       x_program_id,
	       x_program_application_id,
	       x_program_update_date,
	       x_creation_date,
	       x_created_by,
	       x_last_update_date,
	       x_last_updated_by,
               x_last_update_login,
	       userenv('LANG')
	       );
end INSERT_ROW;
--
/* this version assumes that the userenv('LANG') is the language for the user session */
procedure LOCK_ROW (
  X_UOM_CLASS in VARCHAR2,
  X_UOM_CLASS_TL in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_DISABLE_DATE in DATE,
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
  X_REQUEST_ID in NUMBER
) as
begin
   lock_row (x_uom_class,
	     x_uom_class_tl,
	     x_description,
	     x_disable_date,
	     x_attribute_category,
	     x_attribute1 ,
	     x_attribute2 ,
	     x_attribute3 ,
	     x_attribute4 ,
	     x_attribute5 ,
	     x_attribute6 ,
	     x_attribute7 ,
	     x_attribute8 ,
	     x_attribute9 ,
	     x_attribute10 ,
	     x_attribute11 ,
	     x_attribute12 ,
	     x_attribute13 ,
	     x_attribute14 ,
	     x_attribute15 ,
	     x_request_id ,
	     userenv('LANG')
	     );
end LOCK_ROW;
--
/* this version assumes that the userenv('LANG') is the language for the user session */
procedure UPDATE_ROW (
  X_UOM_CLASS in VARCHAR2,
  X_UOM_CLASS_TL in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_DISABLE_DATE in DATE,
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
  X_REQUEST_ID in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) as
begin
   update_row (
	       x_uom_class ,
	       x_uom_class_tl ,
	       x_description ,
	       x_disable_date ,
	       x_attribute_category ,
	       x_attribute1 ,
	       x_attribute2 ,
	       x_attribute3 ,
	       x_attribute4 ,
	       x_attribute5 ,
	       x_attribute6 ,
	       x_attribute7 ,
	       x_attribute8 ,
	       x_attribute9 ,
	       x_attribute10 ,
	       x_attribute11 ,
	       x_attribute12 ,
	       x_attribute13 ,
	       x_attribute14 ,
	       x_attribute15 ,
	       x_request_id ,
	       x_last_update_date ,
	       x_last_updated_by ,
	       x_last_update_login ,
	       userenv('LANG')
	       );
end UPDATE_ROW;
--
procedure DELETE_ROW (
  X_UOM_CLASS in VARCHAR2
) as
begin
  delete from MTL_UOM_CLASSES_TL
  where UOM_CLASS = X_UOM_CLASS;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;
--
procedure LOAD_ROW (
  X_UOM_CLASS in VARCHAR2,
  X_UOM_CLASS_TL in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_DISABLE_DATE in DATE,
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
  X_REQUEST_ID in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_APPL_SHORT_NAME in VARCHAR2
) as
  user_id NUMBER;
  row_id VARCHAR2(64);
  l_program_id NUMBER;
  l_program_application_id NUMBER;
begin
  l_program_id := null;

  if( X_APPL_SHORT_NAME is not null ) then
	select application_id
	into l_program_application_id
	from fnd_application
	where application_short_name = X_APPL_SHORT_NAME;
  end if;


  user_id := fnd_load_util.owner_id(x_owner);

  mtl_uom_classes_tl_pkg.update_row(
  X_UOM_CLASS => X_UOM_CLASS,
  X_UOM_CLASS_TL => X_UOM_CLASS_TL,
  X_DESCRIPTION => X_DESCRIPTION,
  X_DISABLE_DATE => X_DISABLE_DATE,
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
  X_ATTRIBUTE10 => X_ATTRIBUTE10,
  X_ATTRIBUTE11 => X_ATTRIBUTE11,
  X_ATTRIBUTE12 => X_ATTRIBUTE12,
  X_ATTRIBUTE13 => X_ATTRIBUTE13,
  X_ATTRIBUTE14 => X_ATTRIBUTE14,
  X_ATTRIBUTE15 => X_ATTRIBUTE15,
  X_REQUEST_ID => X_REQUEST_ID,
  X_LAST_UPDATE_DATE => X_LAST_UPDATE_DATE,
  X_LAST_UPDATED_BY => user_id,
  X_LAST_UPDATE_LOGIN => 0);
exception
  when no_data_found then
    mtl_uom_classes_tl_pkg.insert_row(
  	X_ROWID => row_id,
  	X_UOM_CLASS => x_uom_class,
  	X_UOM_CLASS_TL => x_uom_class_tl,
  	X_DESCRIPTION => x_description,
  	X_DISABLE_DATE => x_disable_date,
  	X_ATTRIBUTE_CATEGORY => x_attribute_category,
  	X_ATTRIBUTE1 => x_attribute1,
  	X_ATTRIBUTE2 => x_attribute2,
  	X_ATTRIBUTE3 => x_attribute3,
  	X_ATTRIBUTE4 => x_attribute4,
  	X_ATTRIBUTE5 => x_attribute5,
  	X_ATTRIBUTE6 => x_attribute6,
  	X_ATTRIBUTE7 => x_attribute7,
  	X_ATTRIBUTE8 => x_attribute8,
  	X_ATTRIBUTE9 => x_attribute9,
  	X_ATTRIBUTE10 => x_attribute10,
  	X_ATTRIBUTE11 => x_attribute11,
  	X_ATTRIBUTE12 => x_attribute12,
  	X_ATTRIBUTE13 => x_attribute13,
  	X_ATTRIBUTE14 => x_attribute14,
  	X_ATTRIBUTE15 => x_attribute15,
  	X_REQUEST_ID => x_request_id,
        X_PROGRAM_ID => l_program_id,
  	X_PROGRAM_APPLICATION_ID => l_program_application_id,
  	X_PROGRAM_UPDATE_DATE => X_LAST_UPDATE_DATE,
  	X_CREATION_DATE => X_LAST_UPDATE_DATE,
  	X_CREATED_BY => user_id,
  	X_LAST_UPDATE_DATE => X_LAST_UPDATE_DATE,
  	X_LAST_UPDATED_BY => user_id,
  	X_LAST_UPDATE_LOGIN => 0
    );
end LOAD_ROW;
--
procedure TRANSLATE_ROW(
  X_UOM_CLASS in VARCHAR2,
  X_UOM_CLASS_TL in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2
) as
f_luby    number;  -- entity owner in file
begin
   -- Translate owner to file_last_updated_by
   f_luby := fnd_load_util.owner_id(x_owner);

   update mtl_uom_classes_tl set
     uom_class_tl = x_uom_class_tl,
     description = x_description,
     last_update_date = sysdate,
     last_updated_by = f_luby,
     last_update_login = 0,
     source_lang = userenv('LANG')
   where userenv('LANG') in (LANGUAGE, SOURCE_LANG)
   and uom_class = x_uom_class;
end TRANSLATE_ROW;
--
procedure ADD_LANGUAGE
as
begin
  update MTL_UOM_CLASSES_TL T set (
      UOM_CLASS_TL,
      DESCRIPTION
    ) = (select
      B.UOM_CLASS,
      B.DESCRIPTION
    from MTL_UOM_CLASSES_TL B
    where B.UOM_CLASS = T.UOM_CLASS
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.UOM_CLASS,
      T.LANGUAGE
  ) in (select
      SUBT.UOM_CLASS,
      SUBT.LANGUAGE
    from MTL_UOM_CLASSES_TL SUBB, MTL_UOM_CLASSES_TL SUBT
    where SUBB.UOM_CLASS = SUBT.UOM_CLASS
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.UOM_CLASS <> SUBT.UOM_CLASS
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into MTL_UOM_CLASSES_TL (
    UOM_CLASS,
    UOM_CLASS_TL,
    DESCRIPTION,
    DISABLE_DATE,
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
    REQUEST_ID,
    PROGRAM_ID,
    PROGRAM_APPLICATION_ID,
    PROGRAM_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.UOM_CLASS,
    B.UOM_CLASS_TL,
    B.DESCRIPTION,
    B.DISABLE_DATE,
    B.ATTRIBUTE_CATEGORY,
    B.ATTRIBUTE1,
    B.ATTRIBUTE2,
    B.ATTRIBUTE3,
    B.ATTRIBUTE4,
    B.ATTRIBUTE5,
    B.ATTRIBUTE6,
    B.ATTRIBUTE7,
    B.ATTRIBUTE8,
    B.ATTRIBUTE9,
    B.ATTRIBUTE10,
    B.ATTRIBUTE11,
    B.ATTRIBUTE12,
    B.ATTRIBUTE13,
    B.ATTRIBUTE14,
    B.ATTRIBUTE15,
    B.REQUEST_ID,
    B.PROGRAM_ID,
    B.PROGRAM_APPLICATION_ID,
    B.PROGRAM_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from MTL_UOM_CLASSES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from MTL_UOM_CLASSES_TL T
    where T.UOM_CLASS = B.UOM_CLASS
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

--
/* this version takes x_language as the language for the user session
 * overloaded by Oracle Exchange
 */
procedure INSERT_ROW (
  X_ROWID IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
  X_UOM_CLASS in VARCHAR2,
  X_UOM_CLASS_TL in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_DISABLE_DATE in DATE,
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
  X_REQUEST_ID in NUMBER,
  X_PROGRAM_ID in NUMBER,
  X_PROGRAM_APPLICATION_ID in NUMBER,
  X_PROGRAM_UPDATE_DATE in DATE,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  x_language IN VARCHAR2
) as
  cursor C is select ROWID from MTL_UOM_CLASSES_TL
    where UOM_CLASS = X_UOM_CLASS
    and LANGUAGE = x_language
    ;
begin
  insert into MTL_UOM_CLASSES_TL (
    UOM_CLASS,
    UOM_CLASS_TL,
    DESCRIPTION,
    DISABLE_DATE,
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
    REQUEST_ID,
    PROGRAM_ID,
    PROGRAM_APPLICATION_ID,
    PROGRAM_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_UOM_CLASS,
    X_UOM_CLASS_TL,
    X_DESCRIPTION,
    X_DISABLE_DATE,
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
    X_REQUEST_ID,
    X_PROGRAM_ID,
    X_PROGRAM_APPLICATION_ID,
    X_PROGRAM_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    L.LANGUAGE_CODE,
    x_language
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from MTL_UOM_CLASSES_TL T
    where T.UOM_CLASS = X_UOM_CLASS
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;
--
/* this version takes x_language as the language for the user session
 * overloaded by Oracle exchange
 */
procedure LOCK_ROW (
  X_UOM_CLASS in VARCHAR2,
  X_UOM_CLASS_TL in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_DISABLE_DATE in DATE,
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
  X_REQUEST_ID in NUMBER,
  x_language   IN VARCHAR2
) as
  cursor c1 is select
      UOM_CLASS,
      DESCRIPTION,
      DISABLE_DATE,
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
      decode(LANGUAGE, x_language, 'Y', 'N') BASELANG
    from MTL_UOM_CLASSES_TL
    where UOM_CLASS = X_UOM_CLASS
    and x_language in (LANGUAGE, SOURCE_LANG)
    for update of UOM_CLASS nowait;
begin
  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.UOM_CLASS = X_UOM_CLASS)
          AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
               OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
          AND ((tlinfo.DISABLE_DATE = X_DISABLE_DATE)
               OR ((tlinfo.DISABLE_DATE is null) AND (X_DISABLE_DATE is null)))
          AND ((tlinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
               OR ((tlinfo.ATTRIBUTE_CATEGORY is null) AND (X_ATTRIBUTE_CATEGORY is null)))
          AND ((tlinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
               OR ((tlinfo.ATTRIBUTE1 is null) AND (X_ATTRIBUTE1 is null)))
          AND ((tlinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
               OR ((tlinfo.ATTRIBUTE2 is null) AND (X_ATTRIBUTE2 is null)))
          AND ((tlinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
               OR ((tlinfo.ATTRIBUTE3 is null) AND (X_ATTRIBUTE3 is null)))
          AND ((tlinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
               OR ((tlinfo.ATTRIBUTE4 is null) AND (X_ATTRIBUTE4 is null)))
          AND ((tlinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
               OR ((tlinfo.ATTRIBUTE5 is null) AND (X_ATTRIBUTE5 is null)))
          AND ((tlinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
               OR ((tlinfo.ATTRIBUTE6 is null) AND (X_ATTRIBUTE6 is null)))
          AND ((tlinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
               OR ((tlinfo.ATTRIBUTE10 is null) AND (X_ATTRIBUTE10 is null)))
          AND ((tlinfo.ATTRIBUTE11 = X_ATTRIBUTE11)
               OR ((tlinfo.ATTRIBUTE11 is null) AND (X_ATTRIBUTE11 is null)))
          AND ((tlinfo.ATTRIBUTE12 = X_ATTRIBUTE12)
               OR ((tlinfo.ATTRIBUTE12 is null) AND (X_ATTRIBUTE12 is null)))
          AND ((tlinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
               OR ((tlinfo.ATTRIBUTE13 is null) AND (X_ATTRIBUTE13 is null)))
          AND ((tlinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
               OR ((tlinfo.ATTRIBUTE14 is null) AND (X_ATTRIBUTE14 is null)))
          AND ((tlinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
               OR ((tlinfo.ATTRIBUTE15 is null) AND (X_ATTRIBUTE15 is null)))
          AND ((tlinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
               OR ((tlinfo.ATTRIBUTE7 is null) AND (X_ATTRIBUTE7 is null)))
          AND ((tlinfo.ATTRIBUTE8 = X_ATTRIBUTE8)
               OR ((tlinfo.ATTRIBUTE8 is null) AND (X_ATTRIBUTE8 is null)))
          AND ((tlinfo.ATTRIBUTE9 = X_ATTRIBUTE9)
               OR ((tlinfo.ATTRIBUTE9 is null) AND (X_ATTRIBUTE9 is null)))
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
--
/* this version takes x_language as the language for the user session
 * overloaded by Oracle Exchange
 */
procedure UPDATE_ROW (
  X_UOM_CLASS in VARCHAR2,
  X_UOM_CLASS_TL in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_DISABLE_DATE in DATE,
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
  X_REQUEST_ID in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  x_language IN VARCHAR2
) as
begin
  update MTL_UOM_CLASSES_TL set
    UOM_CLASS_TL = X_UOM_CLASS_TL,
    DESCRIPTION = X_DESCRIPTION,
    DISABLE_DATE = X_DISABLE_DATE,
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
    REQUEST_ID = X_REQUEST_ID,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = x_language
  where UOM_CLASS = X_UOM_CLASS
  and x_language in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;
--

end MTL_UOM_CLASSES_TL_PKG;

/
