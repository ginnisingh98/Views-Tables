--------------------------------------------------------
--  DDL for Package Body MTL_UNITS_OF_MEASURE_TL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MTL_UNITS_OF_MEASURE_TL_PKG" as
/* $Header: INVUOMSB.pls 120.2.12010000.2 2009/01/05 09:33:45 juherber ship $ */
procedure INSERT_ROW (
  X_ROW_ID IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
  X_UNIT_OF_MEASURE in VARCHAR2,
  X_UNIT_OF_MEASURE_TL in VARCHAR2,
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
  X_DISABLE_DATE in DATE,
  X_BASE_UOM_FLAG in VARCHAR2,
  X_UOM_CODE in VARCHAR2,
  X_UOM_CLASS in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_PROGRAM_APPLICATION_ID in NUMBER,
  X_PROGRAM_ID in NUMBER,
  X_PROGRAM_UPDATE_DATE in DATE
) IS
BEGIN
   INSERT_ROW
     (
      X_ROW_ID ,
      X_UNIT_OF_MEASURE ,
      X_UNIT_OF_MEASURE_TL ,
      X_ATTRIBUTE_CATEGORY ,
      X_ATTRIBUTE1 ,
      X_ATTRIBUTE2 ,
      X_ATTRIBUTE3 ,
      X_ATTRIBUTE4 ,
      X_ATTRIBUTE5 ,
      X_ATTRIBUTE6 ,
      X_ATTRIBUTE7 ,
      X_ATTRIBUTE8 ,
      X_ATTRIBUTE9 ,
      X_ATTRIBUTE10 ,
      X_ATTRIBUTE11 ,
      X_ATTRIBUTE12 ,
      X_ATTRIBUTE13 ,
      X_ATTRIBUTE14 ,
      X_ATTRIBUTE15 ,
      X_REQUEST_ID ,
      X_DISABLE_DATE ,
      X_BASE_UOM_FLAG ,
      X_UOM_CODE ,
      X_UOM_CLASS ,
      X_DESCRIPTION ,
      X_CREATION_DATE ,
      X_CREATED_BY ,
      X_LAST_UPDATE_DATE ,
      X_LAST_UPDATED_BY ,
      X_LAST_UPDATE_LOGIN ,
      X_PROGRAM_APPLICATION_ID ,
      X_PROGRAM_ID ,
      X_PROGRAM_UPDATE_DATE ,
      userenv('LANG')
      );
END insert_row;
--
procedure LOCK_ROW (
  X_UNIT_OF_MEASURE in VARCHAR2,
  X_UNIT_OF_MEASURE_TL in VARCHAR2,
  X_UOM_CODE in VARCHAR2,
  X_UOM_CLASS in VARCHAR2,
  X_BASE_UOM_FLAG in VARCHAR2,
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
)
  IS
BEGIN
   lock_row
     (X_UNIT_OF_MEASURE ,
      X_UNIT_OF_MEASURE_TL ,
      X_UOM_CODE ,
      X_UOM_CLASS ,
      X_BASE_UOM_FLAG ,
      X_DESCRIPTION ,
      X_DISABLE_DATE ,
      X_ATTRIBUTE_CATEGORY ,
      X_ATTRIBUTE1 ,
      X_ATTRIBUTE2 ,
      X_ATTRIBUTE3 ,
      X_ATTRIBUTE4 ,
      X_ATTRIBUTE5 ,
      X_ATTRIBUTE6 ,
      X_ATTRIBUTE7 ,
      X_ATTRIBUTE8 ,
      X_ATTRIBUTE9 ,
      X_ATTRIBUTE10 ,
      X_ATTRIBUTE11 ,
      X_ATTRIBUTE12 ,
      X_ATTRIBUTE13 ,
      X_ATTRIBUTE14 ,
      X_ATTRIBUTE15 ,
      X_REQUEST_ID ,
      userenv('LANG')
      );
END lock_row;
--

procedure UPDATE_ROW (
  X_UNIT_OF_MEASURE in VARCHAR2,
  X_UNIT_OF_MEASURE_TL in VARCHAR2,
  X_UOM_CODE in VARCHAR2,
  X_UOM_CLASS in VARCHAR2,
  X_BASE_UOM_FLAG in VARCHAR2,
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
)
  IS
BEGIN
   update_row
     (x_UNIT_OF_MEASURE ,
      X_UNIT_OF_MEASURE_TL ,
      X_UOM_CODE ,
      X_UOM_CLASS ,
      X_BASE_UOM_FLAG ,
      X_DESCRIPTION ,
      X_DISABLE_DATE ,
      X_ATTRIBUTE_CATEGORY ,
      X_ATTRIBUTE1 ,
      X_ATTRIBUTE2 ,
      X_ATTRIBUTE3 ,
      X_ATTRIBUTE4 ,
      X_ATTRIBUTE5 ,
      X_ATTRIBUTE6 ,
      X_ATTRIBUTE7 ,
      X_ATTRIBUTE8 ,
      X_ATTRIBUTE9 ,
      X_ATTRIBUTE10 ,
      X_ATTRIBUTE11 ,
      X_ATTRIBUTE12 ,
      X_ATTRIBUTE13 ,
      X_ATTRIBUTE14 ,
      X_ATTRIBUTE15 ,
      X_REQUEST_ID ,
      X_LAST_UPDATE_DATE ,
      X_LAST_UPDATED_BY ,
      X_LAST_UPDATE_LOGIN ,
      userenv('LANG')
      );
END update_row;
--

procedure DELETE_ROW (
  X_UNIT_OF_MEASURE in VARCHAR2
) as
begin
  delete from MTL_UNITS_OF_MEASURE_TL
  where UNIT_OF_MEASURE = X_UNIT_OF_MEASURE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

procedure LOAD_ROW (
  X_UNIT_OF_MEASURE in VARCHAR2,
  X_UOM_CODE in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_UNIT_OF_MEASURE_TL in VARCHAR2,
  X_UOM_CLASS in VARCHAR2,
  X_BASE_UOM_FLAG in VARCHAR2,
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
  X_APPL_SHORT_NAME in VARCHAR2
) as
   user_id NUMBER;
   row_id VARCHAR2(64);
   l_program_application_id number;
begin
   if x_owner = 'SEED' then
      user_id := 1;
   else
      user_id := 0;
   end if;

   if( X_APPL_SHORT_NAME is not null ) then
	select application_id
	into l_program_application_id
	from fnd_application
	where application_short_name = X_APPL_SHORT_NAME;
   end if;

   mtl_units_of_measure_tl_pkg.update_row(
      x_unit_of_measure => x_unit_of_measure,
      x_unit_of_measure_tl => x_unit_of_measure_tl,
      x_uom_code => x_uom_code,
      x_uom_class => x_uom_class,
      x_base_uom_flag => x_base_uom_flag,
      x_description => x_description,
      x_disable_date => x_disable_date,
      x_attribute_category => x_attribute_category,
      x_attribute1 => x_attribute1,
      x_attribute2 => x_attribute2,
      x_attribute3 => x_attribute3,
      x_attribute4 => x_attribute4,
      x_attribute5 => x_attribute5,
      x_attribute6 => x_attribute6,
      x_attribute7 => x_attribute7,
      x_attribute8 => x_attribute8,
      x_attribute9 => x_attribute9,
      x_attribute10 => x_attribute10,
      x_attribute11 => x_attribute11,
      x_attribute12 => x_attribute12,
      x_attribute13 => x_attribute13,
      x_attribute14 => x_attribute14,
      x_attribute15 => x_attribute14,
      x_request_id => x_request_id,
      x_last_update_date => sysdate,
      x_last_updated_by => user_id,
      x_last_update_login => 0);
Exception
   when no_data_found then
      mtl_units_of_measure_tl_pkg.insert_row(
        x_row_id => row_id,
	x_unit_of_measure => x_unit_of_measure,
	x_unit_of_measure_tl => x_unit_of_measure_tl,
	x_attribute_category => x_attribute_category,
	x_attribute1 => x_attribute1,
	x_attribute2 => x_attribute2,
	x_attribute3 => x_attribute3,
	x_attribute4 => x_attribute4,
	x_attribute5 => x_attribute5,
	x_attribute6 => x_attribute6,
	x_attribute7 => x_attribute7,
	x_attribute8 => x_attribute8,
	x_attribute9 => x_attribute9,
	x_attribute10 => x_attribute10,
	x_attribute11 => x_attribute11,
	x_attribute12 => x_attribute12,
	x_attribute13 => x_attribute13,
	x_attribute14 => x_attribute14,
	x_attribute15 => x_attribute15,
	x_request_id => x_request_id,
	x_disable_date => x_disable_date,
	x_base_uom_flag => x_base_uom_flag,
	x_uom_code => x_uom_code,
	x_uom_class => x_uom_class,
	x_description => x_description,
	x_creation_date => sysdate,
	x_created_by => user_id,
	x_last_update_date => sysdate,
	x_last_updated_by => user_id,
	x_last_update_login => 0,
	x_program_application_id => l_program_application_id,
	x_program_id => null,
	x_program_update_date => null);
end LOAD_ROW;

procedure TRANSLATE_ROW (
  X_UNIT_OF_MEASURE in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_UNIT_OF_MEASURE_TL in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) as
BEGIN


  update mtl_units_of_measure_tl set
     unit_of_measure_tl = X_UNIT_OF_MEASURE_TL,
     description = X_DESCRIPTION,
     LAST_UPDATE_DATE = sysdate,
     LAST_UPDATED_BY = decode(x_owner, 'SEED', 1, 0),
     LAST_UPDATE_LOGIN = 0,
     SOURCE_LANG = userenv('LANG')
   where userenv('LANG') in (LANGUAGE, SOURCE_LANG)
  and unit_of_measure = x_unit_of_measure;
end TRANSLATE_ROW;

procedure ADD_LANGUAGE
as
BEGIN

  update MTL_UNITS_OF_MEASURE_TL T set (
      UNIT_OF_MEASURE_TL,
      DESCRIPTION
    ) = (select
      B.UNIT_OF_MEASURE,
      B.DESCRIPTION
    from MTL_UNITS_OF_MEASURE_TL B
    where B.UNIT_OF_MEASURE = T.UNIT_OF_MEASURE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.UNIT_OF_MEASURE,
      T.LANGUAGE
  ) in (select
      SUBT.UNIT_OF_MEASURE,
      SUBT.LANGUAGE
    from MTL_UNITS_OF_MEASURE_TL SUBB, MTL_UNITS_OF_MEASURE_TL SUBT
    where SUBB.UNIT_OF_MEASURE = SUBT.UNIT_OF_MEASURE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.UNIT_OF_MEASURE_TL <> SUBT.UNIT_OF_MEASURE_TL
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into MTL_UNITS_OF_MEASURE_TL (
    UNIT_OF_MEASURE,
    UNIT_OF_MEASURE_TL,
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
    PROGRAM_APPLICATION_ID,
    PROGRAM_ID,
    PROGRAM_UPDATE_DATE,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    DESCRIPTION,
    DISABLE_DATE,
    ATTRIBUTE_CATEGORY,
    BASE_UOM_FLAG,
    UOM_CODE,
    UOM_CLASS,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.UNIT_OF_MEASURE,
    B.UNIT_OF_MEASURE_TL,
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
    B.PROGRAM_APPLICATION_ID,
    B.PROGRAM_ID,
    B.PROGRAM_UPDATE_DATE,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.DESCRIPTION,
    B.DISABLE_DATE,
    B.ATTRIBUTE_CATEGORY,
    B.BASE_UOM_FLAG,
    B.UOM_CODE,
    B.UOM_CLASS,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from MTL_UNITS_OF_MEASURE_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from MTL_UNITS_OF_MEASURE_TL T
    where T.UNIT_OF_MEASURE = B.UNIT_OF_MEASURE
     and T.LANGUAGE = L.LANGUAGE_CODE);


end ADD_LANGUAGE;

--

/* overloaded by Oracle Exchange */
procedure INSERT_ROW (
  X_ROW_ID IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
  X_UNIT_OF_MEASURE in VARCHAR2,
  X_UNIT_OF_MEASURE_TL in VARCHAR2,
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
  X_DISABLE_DATE in DATE,
  X_BASE_UOM_FLAG in VARCHAR2,
  X_UOM_CODE in VARCHAR2,
  X_UOM_CLASS in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_PROGRAM_APPLICATION_ID in NUMBER,
  X_PROGRAM_ID in NUMBER,
  X_PROGRAM_UPDATE_DATE in DATE,
  x_language IN VARCHAR2
) as
  cursor C is select ROWID from MTL_UNITS_OF_MEASURE_TL
    where UNIT_OF_MEASURE = X_UNIT_OF_MEASURE
    and LANGUAGE = x_language
    ;
begin
  insert into MTL_UNITS_OF_MEASURE_TL (
    UNIT_OF_MEASURE,
    UNIT_OF_MEASURE_TL,
    UOM_CODE,
    UOM_CLASS,
    BASE_UOM_FLAG,
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
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    REQUEST_ID,
    PROGRAM_APPLICATION_ID,
    PROGRAM_ID,
    PROGRAM_UPDATE_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_UNIT_OF_MEASURE,
    X_UNIT_OF_MEASURE_TL,
    X_UOM_CODE,
    X_UOM_CLASS,
    X_BASE_UOM_FLAG,
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
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_REQUEST_ID,
    X_PROGRAM_APPLICATION_ID,
    X_PROGRAM_ID,
    X_PROGRAM_UPDATE_DATE,
    L.LANGUAGE_CODE,
    x_language
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from MTL_UNITS_OF_MEASURE_TL T
    where T.UNIT_OF_MEASURE = X_UNIT_OF_MEASURE
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into X_ROW_ID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;
--
/* overloaded by Oracle Exchange */
procedure LOCK_ROW (
  X_UNIT_OF_MEASURE in VARCHAR2,
  X_UNIT_OF_MEASURE_TL in VARCHAR2,
  X_UOM_CODE in VARCHAR2,
  X_UOM_CLASS in VARCHAR2,
  X_BASE_UOM_FLAG in VARCHAR2,
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
  x_language IN VARCHAR2
) as
  cursor c1 is select
      UOM_CODE,
      UOM_CLASS,
      UNIT_OF_MEASURE,
      UNIT_OF_MEASURE_TL,
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
      BASE_UOM_FLAG,
      decode(LANGUAGE, x_language, 'Y', 'N') BASELANG
    from MTL_UNITS_OF_MEASURE_TL
    where UNIT_OF_MEASURE = X_UNIT_OF_MEASURE
    and x_language in (LANGUAGE, SOURCE_LANG)
    for update of UNIT_OF_MEASURE nowait;
begin
  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if( (tlinfo.UNIT_OF_MEASURE = X_UNIT_OF_MEASURE) AND
          (tlinfo.UNIT_OF_MEASURE_TL = X_UNIT_OF_MEASURE_TL)
          AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
               OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
          AND (tlinfo.BASE_UOM_FLAG = X_BASE_UOM_FLAG)
          AND (tlinfo.UOM_CODE = X_UOM_CODE)
          AND (tlinfo.UOM_CLASS = X_UOM_CLASS)
          AND ((tlinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
               OR ((tlinfo.ATTRIBUTE_CATEGORY is null) AND (X_ATTRIBUTE_CATEGORY is null)))
          AND ((tlinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
               OR ((tlinfo.ATTRIBUTE1 is null) AND (X_ATTRIBUTE1 is null)))
          AND ((tlinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
               OR ((tlinfo.ATTRIBUTE2 is null) AND (X_ATTRIBUTE2 is null)))
          AND ((tlinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
               OR ((tlinfo.ATTRIBUTE3 is null) AND (X_ATTRIBUTE3 is null)))
          AND ((tlinfo.DISABLE_DATE = X_DISABLE_DATE)
               OR ((tlinfo.DISABLE_DATE is null) AND (X_DISABLE_DATE is null)))
          AND ((tlinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
               OR ((tlinfo.ATTRIBUTE4 is null) AND (X_ATTRIBUTE4 is null)))
          AND ((tlinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
               OR ((tlinfo.ATTRIBUTE5 is null) AND (X_ATTRIBUTE5 is null)))
          AND ((tlinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
               OR ((tlinfo.ATTRIBUTE6 is null) AND (X_ATTRIBUTE6 is null)))
          AND ((tlinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
               OR ((tlinfo.ATTRIBUTE7 is null) AND (X_ATTRIBUTE7 is null)))
          AND ((tlinfo.ATTRIBUTE8 = X_ATTRIBUTE8)
               OR ((tlinfo.ATTRIBUTE8 is null) AND (X_ATTRIBUTE8 is null)))
          AND ((tlinfo.ATTRIBUTE9 = X_ATTRIBUTE9)
               OR ((tlinfo.ATTRIBUTE9 is null) AND (X_ATTRIBUTE9 is null)))
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
/* overloaded by Oracle Exchange */
procedure UPDATE_ROW (
  X_UNIT_OF_MEASURE in VARCHAR2,
  X_UNIT_OF_MEASURE_TL in VARCHAR2,
  X_UOM_CODE in VARCHAR2,
  X_UOM_CLASS in VARCHAR2,
  X_BASE_UOM_FLAG in VARCHAR2,
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
BEGIN

  update MTL_UNITS_OF_MEASURE_TL set
    UOM_CODE = X_UOM_CODE,
    UOM_CLASS = X_UOM_CLASS,
    UNIT_OF_MEASURE_TL = X_UNIT_OF_MEASURE_TL,
    DESCRIPTION = X_DESCRIPTION,
    DISABLE_DATE = X_DISABLE_DATE,
    BASE_UOM_FLAG = X_BASE_UOM_FLAG,
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
  where UNIT_OF_MEASURE = X_UNIT_OF_MEASURE
  and x_language in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;

--Fix for 7627256
--Disable_Date is updated for all languages
  update MTL_UNITS_OF_MEASURE_TL set
  DISABLE_DATE = X_DISABLE_DATE,
  REQUEST_ID = X_REQUEST_ID,
  LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
  LAST_UPDATED_BY = X_LAST_UPDATED_BY,
  LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where UNIT_OF_MEASURE = X_UNIT_OF_MEASURE;
--End Fix for 7627256

end UPDATE_ROW;
--


 -- Bug 5100785 : This API is called from the Translation Trigger of UOM block of the
 -- INVSDUOM.fmb form to ensure that unit_of_measure_tl records are unique.
 -- The 4th parameter l_temp is of no use but needed to
 -- follow the way fnd handles edit OF translated records
PROCEDURE validate_translated_row
  (
   X_UNIT_OF_MEASURE    in VARCHAR2,
   X_language IN VARCHAR2,
   X_UNIT_OF_MEASURE_TL in VARCHAR2,
   l_temp IN VARCHAR2
   ) AS

l_row_cnt NUMBER;

BEGIN


   -- USE THE FACT THAT UNIT_OF_MEASURE WILL BE UNIQUE FOR THAT LANGUAGE
   -- This validation is to ensure that unit_of_measure_tl will also be
   -- UNIQUE IN the table

   SELECT COUNT(1) INTO l_row_cnt from MTL_UNITS_OF_MEASURE_TL T
     where unit_of_measure_tl = x_unit_of_measure_tl
     AND  UNIT_OF_MEASURE <> x_unit_of_measure
     AND  X_language in (LANGUAGE, SOURCE_LANG);

 --inv_log_util.trace('', 'ROW_CNT :'||l_row_cnt, 9);


   IF l_row_cnt > 0 THEN
      fnd_message.set_name('INV','INV_UNIT_EXISTS');
      FND_MESSAGE.SET_TOKEN('VALUE1',X_UNIT_OF_MEASURE_TL);
      fnd_message.raise_error;
   END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
       NULL;
   WHEN TOO_MANY_ROWS THEN
      fnd_message.set_name('INV','INV_UNIT_EXISTS');
      fnd_message.raise_error;

 END validate_translated_row;


end MTL_UNITS_OF_MEASURE_TL_PKG;

/
