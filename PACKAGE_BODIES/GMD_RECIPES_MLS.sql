--------------------------------------------------------
--  DDL for Package Body GMD_RECIPES_MLS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_RECIPES_MLS" as
/* $Header: GMDRMLSB.pls 120.1.12010000.2 2008/11/12 18:43:22 rnalla ship $ */
procedure INSERT_ROW (
  X_ROWID in OUT NOCOPY VARCHAR2,
  X_RECIPE_ID in NUMBER,
  X_OWNER_ID in NUMBER,
  X_OWNER_LAB_TYPE in VARCHAR2,
  X_DELETE_MARK in NUMBER,
  X_TEXT_CODE in NUMBER,
  X_RECIPE_NO in VARCHAR2,
  X_RECIPE_VERSION in NUMBER,
  X_OWNER_ORGANIZATION_ID in NUMBER,
  X_CREATION_ORGANIZATION_ID in NUMBER,
  X_FORMULA_ID in NUMBER,
  X_ROUTING_ID in NUMBER,
  X_PROJECT_ID in NUMBER,
  X_RECIPE_STATUS in VARCHAR2,
  X_CALCULATE_STEP_QUANTITY in NUMBER,
  X_PLANNED_PROCESS_LOSS in NUMBER,
  X_CONTIGUOUS_IND IN NUMBER,
  X_ENHANCED_PI_IND IN VARCHAR2,
  X_RECIPE_TYPE IN NUMBER,
  X_RECIPE_DESCRIPTION in VARCHAR2,
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
  X_ATTRIBUTE16 in VARCHAR2,
  X_ATTRIBUTE17 in VARCHAR2,
  X_ATTRIBUTE18 in VARCHAR2,
  X_ATTRIBUTE19 in VARCHAR2,
  X_ATTRIBUTE20 in VARCHAR2,
  X_ATTRIBUTE21 in VARCHAR2,
  X_ATTRIBUTE22 in VARCHAR2,
  X_ATTRIBUTE23 in VARCHAR2,
  X_ATTRIBUTE24 in VARCHAR2,
  X_ATTRIBUTE25 in VARCHAR2,
  X_ATTRIBUTE26 in VARCHAR2,
  X_ATTRIBUTE27 in VARCHAR2,
  X_ATTRIBUTE28 in VARCHAR2,
  X_ATTRIBUTE29 in VARCHAR2,
  X_ATTRIBUTE30 in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_FIXED_PROCESS_LOSS in NUMBER, /* 6811759*/
  X_FIXED_PROCESS_LOSS_UOM in VARCHAR2
) is
  cursor C is select ROWID from GMD_RECIPES_B
    where RECIPE_ID = X_RECIPE_ID
    ;
begin
  insert into GMD_RECIPES_B (
    ATTRIBUTE26,
    ATTRIBUTE27,
    ATTRIBUTE28,
    ATTRIBUTE29,
    ATTRIBUTE30,
    OWNER_ID,
    OWNER_LAB_TYPE,
    ATTRIBUTE12,
    ATTRIBUTE13,
    ATTRIBUTE14,
    ATTRIBUTE15,
    ATTRIBUTE16,
    ATTRIBUTE17,
    ATTRIBUTE18,
    ATTRIBUTE19,
    ATTRIBUTE20,
    ATTRIBUTE21,
    ATTRIBUTE22,
    ATTRIBUTE23,
    ATTRIBUTE24,
    ATTRIBUTE25,
    DELETE_MARK,
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
    TEXT_CODE,
    RECIPE_ID,
    RECIPE_NO,
    RECIPE_VERSION,
    OWNER_ORGANIZATION_ID,
    CREATION_ORGANIZATION_ID,
    FORMULA_ID,
    ROUTING_ID,
    PROJECT_ID,
    RECIPE_STATUS,
    CALCULATE_STEP_QUANTITY ,
    PLANNED_PROCESS_LOSS,
    CONTIGUOUS_IND,
    ENHANCED_PI_IND,
    RECIPE_TYPE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    FIXED_PROCESS_LOSS, /* 6811759*/
    FIXED_PROCESS_LOSS_UOM
  ) values (
    X_ATTRIBUTE26,
    X_ATTRIBUTE27,
    X_ATTRIBUTE28,
    X_ATTRIBUTE29,
    X_ATTRIBUTE30,
    X_OWNER_ID,
    X_OWNER_LAB_TYPE,
    X_ATTRIBUTE12,
    X_ATTRIBUTE13,
    X_ATTRIBUTE14,
    X_ATTRIBUTE15,
    X_ATTRIBUTE16,
    X_ATTRIBUTE17,
    X_ATTRIBUTE18,
    X_ATTRIBUTE19,
    X_ATTRIBUTE20,
    X_ATTRIBUTE21,
    X_ATTRIBUTE22,
    X_ATTRIBUTE23,
    X_ATTRIBUTE24,
    X_ATTRIBUTE25,
    X_DELETE_MARK,
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
    X_TEXT_CODE,
    X_RECIPE_ID,
    X_RECIPE_NO,
    X_RECIPE_VERSION,
    X_OWNER_ORGANIZATION_ID,
    X_CREATION_ORGANIZATION_ID,
    X_FORMULA_ID,
    X_ROUTING_ID,
    X_PROJECT_ID,
    X_RECIPE_STATUS,
    X_CALCULATE_STEP_QUANTITY,
    X_PLANNED_PROCESS_LOSS,
    X_CONTIGUOUS_IND,
    X_ENHANCED_PI_IND,
    X_RECIPE_TYPE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_FIXED_PROCESS_LOSS , /* 6811759*/
    X_FIXED_PROCESS_LOSS_UOM
  );


  insert into GMD_RECIPES_TL (
    RECIPE_ID,
    RECIPE_DESCRIPTION,
    SOURCE_LANG,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE
  ) select
    X_RECIPE_ID,
    X_RECIPE_DESCRIPTION,
    userenv('LANG'),
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from GMD_RECIPES_TL T
    where T.RECIPE_ID = X_RECIPE_ID
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
  X_RECIPE_ID in NUMBER,
  X_ATTRIBUTE26 in VARCHAR2,
  X_ATTRIBUTE27 in VARCHAR2,
  X_ATTRIBUTE28 in VARCHAR2,
  X_ATTRIBUTE29 in VARCHAR2,
  X_ATTRIBUTE30 in VARCHAR2,
  X_OWNER_ID in NUMBER,
  X_OWNER_LAB_TYPE in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE16 in VARCHAR2,
  X_ATTRIBUTE17 in VARCHAR2,
  X_ATTRIBUTE18 in VARCHAR2,
  X_ATTRIBUTE19 in VARCHAR2,
  X_ATTRIBUTE20 in VARCHAR2,
  X_ATTRIBUTE21 in VARCHAR2,
  X_ATTRIBUTE22 in VARCHAR2,
  X_ATTRIBUTE23 in VARCHAR2,
  X_ATTRIBUTE24 in VARCHAR2,
  X_ATTRIBUTE25 in VARCHAR2,
  X_DELETE_MARK in NUMBER,
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
  X_TEXT_CODE in NUMBER,
  X_RECIPE_NO in VARCHAR2,
  X_RECIPE_VERSION in NUMBER,
  X_OWNER_ORGANIZATION_ID in NUMBER,
  X_CREATION_ORGANIZATION_ID in NUMBER,
  X_FORMULA_ID in NUMBER,
  X_ROUTING_ID in NUMBER,
  X_PROJECT_ID in NUMBER,
  X_RECIPE_STATUS in VARCHAR2,
  X_CALCULATE_STEP_QUANTITY in NUMBER,
  X_PLANNED_PROCESS_LOSS in NUMBER,
  X_CONTIGUOUS_IND IN NUMBER,
  X_ENHANCED_PI_IND IN VARCHAR2,
  X_RECIPE_TYPE IN NUMBER,
  X_RECIPE_DESCRIPTION in VARCHAR2,
  X_FIXED_PROCESS_LOSS in NUMBER, /* 6811759*/
  X_FIXED_PROCESS_LOSS_UOM in VARCHAR2
) is
  cursor c is select
      ATTRIBUTE26,
      ATTRIBUTE27,
      ATTRIBUTE28,
      ATTRIBUTE29,
      ATTRIBUTE30,
      OWNER_ID,
      OWNER_LAB_TYPE,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15,
      ATTRIBUTE16,
      ATTRIBUTE17,
      ATTRIBUTE18,
      ATTRIBUTE19,
      ATTRIBUTE20,
      ATTRIBUTE21,
      ATTRIBUTE22,
      ATTRIBUTE23,
      ATTRIBUTE24,
      ATTRIBUTE25,
      DELETE_MARK,
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
      TEXT_CODE,
      RECIPE_NO,
      RECIPE_VERSION,
      OWNER_ORGANIZATION_ID,
      CREATION_ORGANIZATION_ID,
      FORMULA_ID,
      ROUTING_ID,
      PROJECT_ID,
      RECIPE_STATUS,
      CALCULATE_STEP_QUANTITY,
      PLANNED_PROCESS_LOSS,
      CONTIGUOUS_IND,
      ENHANCED_PI_IND,
      RECIPE_TYPE,
      FIXED_PROCESS_LOSS, /* 6811759*/
      FIXED_PROCESS_LOSS_UOM
    from GMD_RECIPES_B
    where RECIPE_ID = X_RECIPE_ID
    for update of RECIPE_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      RECIPE_DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from GMD_RECIPES_TL
    where RECIPE_ID = X_RECIPE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of RECIPE_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.ATTRIBUTE26 = X_ATTRIBUTE26)
           OR ((recinfo.ATTRIBUTE26 is null) AND (X_ATTRIBUTE26 is null)))
      AND ((recinfo.ATTRIBUTE27 = X_ATTRIBUTE27)
           OR ((recinfo.ATTRIBUTE27 is null) AND (X_ATTRIBUTE27 is null)))
      AND ((recinfo.ATTRIBUTE28 = X_ATTRIBUTE28)
           OR ((recinfo.ATTRIBUTE28 is null) AND (X_ATTRIBUTE28 is null)))
      AND ((recinfo.ATTRIBUTE29 = X_ATTRIBUTE29)
           OR ((recinfo.ATTRIBUTE29 is null) AND (X_ATTRIBUTE29 is null)))
      AND ((recinfo.ATTRIBUTE30 = X_ATTRIBUTE30)
           OR ((recinfo.ATTRIBUTE30 is null) AND (X_ATTRIBUTE30 is null)))
      AND (recinfo.OWNER_ID = X_OWNER_ID)
      AND ((recinfo.OWNER_LAB_TYPE = X_OWNER_LAB_TYPE)
           OR ((recinfo.OWNER_LAB_TYPE is null) AND (X_OWNER_LAB_TYPE is null)))
      AND ((recinfo.ATTRIBUTE12 = X_ATTRIBUTE12)
           OR ((recinfo.ATTRIBUTE12 is null) AND (X_ATTRIBUTE12 is null)))
      AND ((recinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
           OR ((recinfo.ATTRIBUTE13 is null) AND (X_ATTRIBUTE13 is null)))
      AND ((recinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
           OR ((recinfo.ATTRIBUTE14 is null) AND (X_ATTRIBUTE14 is null)))
      AND ((recinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
           OR ((recinfo.ATTRIBUTE15 is null) AND (X_ATTRIBUTE15 is null)))
      AND ((recinfo.ATTRIBUTE16 = X_ATTRIBUTE16)
           OR ((recinfo.ATTRIBUTE16 is null) AND (X_ATTRIBUTE16 is null)))
      AND ((recinfo.ATTRIBUTE17 = X_ATTRIBUTE17)
           OR ((recinfo.ATTRIBUTE17 is null) AND (X_ATTRIBUTE17 is null)))
      AND ((recinfo.ATTRIBUTE18 = X_ATTRIBUTE18)
           OR ((recinfo.ATTRIBUTE18 is null) AND (X_ATTRIBUTE18 is null)))
      AND ((recinfo.ATTRIBUTE19 = X_ATTRIBUTE19)
           OR ((recinfo.ATTRIBUTE19 is null) AND (X_ATTRIBUTE19 is null)))
      AND ((recinfo.ATTRIBUTE20 = X_ATTRIBUTE20)
           OR ((recinfo.ATTRIBUTE20 is null) AND (X_ATTRIBUTE20 is null)))
      AND ((recinfo.ATTRIBUTE21 = X_ATTRIBUTE21)
           OR ((recinfo.ATTRIBUTE21 is null) AND (X_ATTRIBUTE21 is null)))
      AND ((recinfo.ATTRIBUTE22 = X_ATTRIBUTE22)
           OR ((recinfo.ATTRIBUTE22 is null) AND (X_ATTRIBUTE22 is null)))
      AND ((recinfo.ATTRIBUTE23 = X_ATTRIBUTE23)
           OR ((recinfo.ATTRIBUTE23 is null) AND (X_ATTRIBUTE23 is null)))
      AND ((recinfo.ATTRIBUTE24 = X_ATTRIBUTE24)
           OR ((recinfo.ATTRIBUTE24 is null) AND (X_ATTRIBUTE24 is null)))
      AND ((recinfo.ATTRIBUTE25 = X_ATTRIBUTE25)
           OR ((recinfo.ATTRIBUTE25 is null) AND (X_ATTRIBUTE25 is null)))
      AND (recinfo.DELETE_MARK = X_DELETE_MARK)
      AND ((recinfo.CALCULATE_STEP_QUANTITY = X_CALCULATE_STEP_QUANTITY)
      	  OR ((recinfo.CALCULATE_STEP_QUANTITY is null) AND (X_CALCULATE_STEP_QUANTITY is null)))
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
      AND ((recinfo.TEXT_CODE = X_TEXT_CODE)
           OR ((recinfo.TEXT_CODE is null) AND (X_TEXT_CODE is null)))
      AND (recinfo.RECIPE_NO = X_RECIPE_NO)
      AND (recinfo.RECIPE_VERSION = X_RECIPE_VERSION)
      AND (recinfo.OWNER_ORGANIZATION_ID = X_OWNER_ORGANIZATION_ID)
      AND (recinfo.CREATION_ORGANIZATION_ID = X_CREATION_ORGANIZATION_ID)
      AND (recinfo.FORMULA_ID = X_FORMULA_ID)
      AND ((recinfo.ROUTING_ID = X_ROUTING_ID)
           OR ((recinfo.ROUTING_ID is null) AND (X_ROUTING_ID is null)))
      AND ((recinfo.PROJECT_ID = X_PROJECT_ID)
           OR ((recinfo.PROJECT_ID is null) AND (X_PROJECT_ID is null)))
      AND (recinfo.RECIPE_STATUS = X_RECIPE_STATUS)
      AND ((recinfo.CONTIGUOUS_IND = X_CONTIGUOUS_IND)
           OR ((recinfo.CONTIGUOUS_IND is null) AND (X_CONTIGUOUS_IND is null)))
      AND ((recinfo.ENHANCED_PI_IND = X_ENHANCED_PI_IND)
           OR ((recinfo.ENHANCED_PI_IND is null) AND (X_ENHANCED_PI_IND is null)))
      AND ((recinfo.RECIPE_TYPE = X_RECIPE_TYPE)
           OR ((recinfo.RECIPE_TYPE is null) AND (X_RECIPE_TYPE is null)))
      AND ((recinfo.PLANNED_PROCESS_LOSS = X_PLANNED_PROCESS_LOSS)
           OR ((recinfo.PLANNED_PROCESS_LOSS is null) AND (X_PLANNED_PROCESS_LOSS is null)))
      AND ((recinfo.FIXED_PROCESS_LOSS = X_FIXED_PROCESS_LOSS) /* 6811759*/
           OR ((recinfo.FIXED_PROCESS_LOSS is null) AND (X_FIXED_PROCESS_LOSS is null)))
      AND ((recinfo.FIXED_PROCESS_LOSS_UOM = X_FIXED_PROCESS_LOSS_UOM)
           OR ((recinfo.FIXED_PROCESS_LOSS_UOM is null) AND (X_FIXED_PROCESS_LOSS_UOM is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.RECIPE_DESCRIPTION = X_RECIPE_DESCRIPTION)
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
  X_RECIPE_ID in NUMBER,
  X_OWNER_ID in NUMBER,
  X_OWNER_LAB_TYPE in VARCHAR2,
  X_DELETE_MARK in NUMBER,
  X_RECIPE_NO in VARCHAR2,
  X_RECIPE_VERSION in NUMBER,
  X_OWNER_ORGANIZATION_ID in NUMBER,
  X_CREATION_ORGANIZATION_ID in NUMBER,
  X_FORMULA_ID in NUMBER,
  X_ROUTING_ID in NUMBER,
  X_PROJECT_ID in NUMBER,
  X_RECIPE_STATUS in VARCHAR2,
  X_CALCULATE_STEP_QUANTITY in NUMBER,
  X_PLANNED_PROCESS_LOSS in NUMBER,
  X_CONTIGUOUS_IND IN NUMBER,
  X_ENHANCED_PI_IND IN VARCHAR2,
  X_RECIPE_TYPE IN NUMBER,
  X_RECIPE_DESCRIPTION in VARCHAR2,
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
  X_ATTRIBUTE16 in VARCHAR2,
  X_ATTRIBUTE17 in VARCHAR2,
  X_ATTRIBUTE18 in VARCHAR2,
  X_ATTRIBUTE19 in VARCHAR2,
  X_ATTRIBUTE20 in VARCHAR2,
  X_ATTRIBUTE21 in VARCHAR2,
  X_ATTRIBUTE22 in VARCHAR2,
  X_ATTRIBUTE23 in VARCHAR2,
  X_ATTRIBUTE24 in VARCHAR2,
  X_ATTRIBUTE25 in VARCHAR2,
  X_ATTRIBUTE26 in VARCHAR2,
  X_ATTRIBUTE27 in VARCHAR2,
  X_ATTRIBUTE28 in VARCHAR2,
  X_ATTRIBUTE29 in VARCHAR2,
  X_ATTRIBUTE30 in VARCHAR2,
  X_TEXT_CODE in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_FIXED_PROCESS_LOSS IN NUMBER, /* 6811759*/
  X_FIXED_PROCESS_LOSS_UOM IN VARCHAR2
) is
begin

  update GMD_RECIPES_B set
    ATTRIBUTE26 = X_ATTRIBUTE26,
    ATTRIBUTE27 = X_ATTRIBUTE27,
    ATTRIBUTE28 = X_ATTRIBUTE28,
    ATTRIBUTE29 = X_ATTRIBUTE29,
    ATTRIBUTE30 = X_ATTRIBUTE30,
    OWNER_ID = X_OWNER_ID,
    OWNER_LAB_TYPE = X_OWNER_LAB_TYPE,
    ATTRIBUTE12 = X_ATTRIBUTE12,
    ATTRIBUTE13 = X_ATTRIBUTE13,
    ATTRIBUTE14 = X_ATTRIBUTE14,
    ATTRIBUTE15 = X_ATTRIBUTE15,
    ATTRIBUTE16 = X_ATTRIBUTE16,
    ATTRIBUTE17 = X_ATTRIBUTE17,
    ATTRIBUTE18 = X_ATTRIBUTE18,
    ATTRIBUTE19 = X_ATTRIBUTE19,
    ATTRIBUTE20 = X_ATTRIBUTE20,
    ATTRIBUTE21 = X_ATTRIBUTE21,
    ATTRIBUTE22 = X_ATTRIBUTE22,
    ATTRIBUTE23 = X_ATTRIBUTE23,
    ATTRIBUTE24 = X_ATTRIBUTE24,
    ATTRIBUTE25 = X_ATTRIBUTE25,
    DELETE_MARK = X_DELETE_MARK,
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
    TEXT_CODE = X_TEXT_CODE,
    RECIPE_NO = X_RECIPE_NO,
    RECIPE_VERSION = X_RECIPE_VERSION,
    OWNER_ORGANIZATION_ID = X_OWNER_ORGANIZATION_ID,
    CREATION_ORGANIZATION_ID = X_CREATION_ORGANIZATION_ID,
    FORMULA_ID = X_FORMULA_ID,
    ROUTING_ID = X_ROUTING_ID,
    PROJECT_ID = X_PROJECT_ID,
    RECIPE_STATUS = X_RECIPE_STATUS,
    CALCULATE_STEP_QUANTITY = X_CALCULATE_STEP_QUANTITY,
    PLANNED_PROCESS_LOSS = X_PLANNED_PROCESS_LOSS,
    CONTIGUOUS_IND = X_CONTIGUOUS_IND,
    ENHANCED_PI_IND = X_ENHANCED_PI_IND,
    RECIPE_TYPE = X_RECIPE_TYPE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    FIXED_PROCESS_LOSS = X_FIXED_PROCESS_LOSS, /* 6811759*/
    FIXED_PROCESS_LOSS_UOM = X_FIXED_PROCESS_LOSS_UOM
  where RECIPE_ID = X_RECIPE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update GMD_RECIPES_TL set
    RECIPE_DESCRIPTION = X_RECIPE_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where RECIPE_ID = X_RECIPE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_RECIPE_ID in NUMBER
) is
begin
  delete from GMD_RECIPES_TL
  where RECIPE_ID = X_RECIPE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from GMD_RECIPES_B
  where RECIPE_ID = X_RECIPE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from GMD_RECIPES_TL T
  where not exists
    (select NULL
    from GMD_RECIPES_B B
    where B.RECIPE_ID = T.RECIPE_ID
    );

  update GMD_RECIPES_TL T set (
      RECIPE_DESCRIPTION
    ) = (select
      B.RECIPE_DESCRIPTION
    from GMD_RECIPES_TL B
    where B.RECIPE_ID = T.RECIPE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.RECIPE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.RECIPE_ID,
      SUBT.LANGUAGE
    from GMD_RECIPES_TL SUBB, GMD_RECIPES_TL SUBT
    where SUBB.RECIPE_ID = SUBT.RECIPE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.RECIPE_DESCRIPTION <> SUBT.RECIPE_DESCRIPTION
  ));

  insert into GMD_RECIPES_TL (
    RECIPE_ID,
    RECIPE_DESCRIPTION,
    SOURCE_LANG,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE
  ) select
    B.RECIPE_ID,
    B.RECIPE_DESCRIPTION,
    B.SOURCE_LANG,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE
  from GMD_RECIPES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from GMD_RECIPES_TL T
    where T.RECIPE_ID = B.RECIPE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end GMD_RECIPES_MLS;

/