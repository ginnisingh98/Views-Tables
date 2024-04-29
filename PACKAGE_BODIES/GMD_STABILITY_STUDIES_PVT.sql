--------------------------------------------------------
--  DDL for Package Body GMD_STABILITY_STUDIES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_STABILITY_STUDIES_PVT" as
/* $Header: GMDVSSTB.pls 120.2 2005/09/02 01:47:09 svankada noship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_SS_ID in NUMBER,
  X_ATTRIBUTE29 in VARCHAR2,
  X_ATTRIBUTE30 in VARCHAR2,
  X_DELETE_MARK in NUMBER,
  X_STORAGE_SPEC_ID in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE25 in VARCHAR2,
  X_RECOMMENDED_SHELF_LIFE_UNIT in VARCHAR2,
  X_TEXT_CODE in NUMBER,
  X_SCHEDULED_START_DATE in DATE,
  X_SCHEDULED_END_DATE in DATE,
  X_REVISED_START_DATE in DATE,
  X_REVISED_END_DATE in DATE,
  X_ACTUAL_START_DATE in DATE,
  X_ACTUAL_END_DATE in DATE,
  X_RECOMMENDED_SHELF_LIFE in NUMBER,
  X_ATTRIBUTE26 in VARCHAR2,
  X_ATTRIBUTE27 in VARCHAR2,
  X_ATTRIBUTE28 in VARCHAR2,
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
  X_NOTIFICATION_LEAD_TIME in NUMBER,
  X_NOTIFICATION_LEAD_TIME_UNIT in VARCHAR2,
  X_TESTING_GRACE_PERIOD in NUMBER,
  X_TESTING_GRACE_PERIOD_UNIT in VARCHAR2,
  --X_ORGN_CODE in VARCHAR2, -- INVCONV
  X_SS_NO in VARCHAR2,
  X_STATUS in NUMBER,
  X_STORAGE_PLAN_ID in NUMBER,
  --X_ITEM_ID in NUMBER, -- INVCONV
  X_BASE_SPEC_ID in NUMBER,
  --X_QC_LAB_ORGN_CODE in VARCHAR2, -- INVCONV
  X_OWNER in NUMBER,
  X_MATERIAL_SOURCES_CNT in NUMBER,
  X_STORAGE_CONDITIONS_CNT in NUMBER,
  X_PACKAGES_CNT in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_ORGANIZATION_ID in NUMBER, -- INVCONV
  X_INVENTORY_ITEM_ID in NUMBER, -- INVCONV
  X_REVISION in VARCHAR2, -- INVCONV
  X_LAB_ORGANIZATION_ID in NUMBER, -- INVCONV
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from GMD_STABILITY_STUDIES_B
    where SS_ID = X_SS_ID
    ;
begin
  insert into GMD_STABILITY_STUDIES_B (
    ATTRIBUTE29,
    ATTRIBUTE30,
    DELETE_MARK,
    STORAGE_SPEC_ID,
    ATTRIBUTE_CATEGORY,
    ATTRIBUTE25,
    SS_ID,
    RECOMMENDED_SHELF_LIFE_UNIT,
    TEXT_CODE,
    SCHEDULED_START_DATE,
    SCHEDULED_END_DATE,
    REVISED_START_DATE,
    REVISED_END_DATE,
    ACTUAL_START_DATE,
    ACTUAL_END_DATE,
    RECOMMENDED_SHELF_LIFE,
    ATTRIBUTE26,
    ATTRIBUTE27,
    ATTRIBUTE28,
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
    ATTRIBUTE16,
    ATTRIBUTE17,
    ATTRIBUTE18,
    ATTRIBUTE19,
    ATTRIBUTE20,
    ATTRIBUTE21,
    ATTRIBUTE22,
    ATTRIBUTE23,
    ATTRIBUTE24,
    NOTIFICATION_LEAD_TIME,
    NOTIFICATION_LEAD_TIME_UNIT,
    TESTING_GRACE_PERIOD,
    TESTING_GRACE_PERIOD_UNIT,
    --ORGN_CODE, -- INVCONV
    SS_NO,
    STATUS,
    STORAGE_PLAN_ID,
    --ITEM_ID, -- INVCONV
    BASE_SPEC_ID,
    --QC_LAB_ORGN_CODE, -- INVCONV
    OWNER,
    MATERIAL_SOURCES_CNT,
    STORAGE_CONDITIONS_CNT,
    PACKAGES_CNT,
    ORGANIZATION_ID, -- INVCONV
  	INVENTORY_ITEM_ID , -- INVCONV
  	REVISION , -- INVCONV
  	LAB_ORGANIZATION_ID , -- INVCONV
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_ATTRIBUTE29,
    X_ATTRIBUTE30,
    X_DELETE_MARK,
    X_STORAGE_SPEC_ID,
    X_ATTRIBUTE_CATEGORY,
    X_ATTRIBUTE25,
    X_SS_ID,
    X_RECOMMENDED_SHELF_LIFE_UNIT,
    X_TEXT_CODE,
    X_SCHEDULED_START_DATE,
    X_SCHEDULED_END_DATE,
    X_REVISED_START_DATE,
    X_REVISED_END_DATE,
    X_ACTUAL_START_DATE,
    X_ACTUAL_END_DATE,
    X_RECOMMENDED_SHELF_LIFE,
    X_ATTRIBUTE26,
    X_ATTRIBUTE27,
    X_ATTRIBUTE28,
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
    X_ATTRIBUTE16,
    X_ATTRIBUTE17,
    X_ATTRIBUTE18,
    X_ATTRIBUTE19,
    X_ATTRIBUTE20,
    X_ATTRIBUTE21,
    X_ATTRIBUTE22,
    X_ATTRIBUTE23,
    X_ATTRIBUTE24,
    X_NOTIFICATION_LEAD_TIME,
    X_NOTIFICATION_LEAD_TIME_UNIT,
    X_TESTING_GRACE_PERIOD,
    X_TESTING_GRACE_PERIOD_UNIT,
    --X_ORGN_CODE, -- INVCONV
    X_SS_NO,
    X_STATUS,
    X_STORAGE_PLAN_ID,
    --X_ITEM_ID, -- INVCONV
    X_BASE_SPEC_ID,
    --X_QC_LAB_ORGN_CODE, -- INVCONV
    X_OWNER,
    X_MATERIAL_SOURCES_CNT,
    X_STORAGE_CONDITIONS_CNT,
    X_PACKAGES_CNT,
    X_ORGANIZATION_ID , -- INVCONV
  	X_INVENTORY_ITEM_ID , -- INVCONV
  	X_REVISION , -- INVCONV
  	X_LAB_ORGANIZATION_ID , -- INVCONV
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into GMD_STABILITY_STUDIES_TL (
    SS_ID,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_SS_ID,
    X_DESCRIPTION,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from GMD_STABILITY_STUDIES_TL T
    where T.SS_ID = X_SS_ID
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
  X_SS_ID in NUMBER,
  X_ATTRIBUTE29 in VARCHAR2,
  X_ATTRIBUTE30 in VARCHAR2,
  X_DELETE_MARK in NUMBER,
  X_STORAGE_SPEC_ID in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE25 in VARCHAR2,
  X_RECOMMENDED_SHELF_LIFE_UNIT in VARCHAR2,
  X_TEXT_CODE in NUMBER,
  X_SCHEDULED_START_DATE in DATE,
  X_SCHEDULED_END_DATE in DATE,
  X_REVISED_START_DATE in DATE,
  X_REVISED_END_DATE in DATE,
  X_ACTUAL_START_DATE in DATE,
  X_ACTUAL_END_DATE in DATE,
  X_RECOMMENDED_SHELF_LIFE in NUMBER,
  X_ATTRIBUTE26 in VARCHAR2,
  X_ATTRIBUTE27 in VARCHAR2,
  X_ATTRIBUTE28 in VARCHAR2,
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
  X_NOTIFICATION_LEAD_TIME in NUMBER,
  X_NOTIFICATION_LEAD_TIME_UNIT in VARCHAR2,
  X_TESTING_GRACE_PERIOD in NUMBER,
  X_TESTING_GRACE_PERIOD_UNIT in VARCHAR2,
  --X_ORGN_CODE in VARCHAR2,  -- INVCONV
  X_SS_NO in VARCHAR2,
  X_STATUS in NUMBER,
  X_STORAGE_PLAN_ID in NUMBER,
  --X_ITEM_ID in NUMBER, -- INVCONV
  X_BASE_SPEC_ID in NUMBER,
  --X_QC_LAB_ORGN_CODE in VARCHAR2, -- INVCONV
  X_OWNER in NUMBER,
  X_MATERIAL_SOURCES_CNT in NUMBER,
  X_PACKAGES_CNT in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_ORGANIZATION_ID in NUMBER, -- INVCONV
  X_INVENTORY_ITEM_ID in NUMBER, -- INVCONV
  X_REVISION in VARCHAR2, -- INVCONV
  X_LAB_ORGANIZATION_ID in NUMBER -- INVCONV
) is
  cursor c is select
      ATTRIBUTE29,
      ATTRIBUTE30,
      DELETE_MARK,
      STORAGE_SPEC_ID,
      ATTRIBUTE_CATEGORY,
      ATTRIBUTE25,
      RECOMMENDED_SHELF_LIFE_UNIT,
      TEXT_CODE,
      SCHEDULED_START_DATE,
      SCHEDULED_END_DATE,
      REVISED_START_DATE,
      REVISED_END_DATE,
      ACTUAL_START_DATE,
      ACTUAL_END_DATE,
      RECOMMENDED_SHELF_LIFE,
      ATTRIBUTE26,
      ATTRIBUTE27,
      ATTRIBUTE28,
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
      ATTRIBUTE16,
      ATTRIBUTE17,
      ATTRIBUTE18,
      ATTRIBUTE19,
      ATTRIBUTE20,
      ATTRIBUTE21,
      ATTRIBUTE22,
      ATTRIBUTE23,
      ATTRIBUTE24,
      NOTIFICATION_LEAD_TIME,
      NOTIFICATION_LEAD_TIME_UNIT,
      TESTING_GRACE_PERIOD,
      TESTING_GRACE_PERIOD_UNIT,
      --ORGN_CODE, -- INVCONV
      SS_NO,
      STATUS,
      STORAGE_PLAN_ID,
      --ITEM_ID, -- INVCONV
      BASE_SPEC_ID,
      --QC_LAB_ORGN_CODE, -- INVCONV
      OWNER,
      MATERIAL_SOURCES_CNT,
      PACKAGES_CNT,
      ORGANIZATION_ID , -- INVCONV
  	  INVENTORY_ITEM_ID , -- INVCONV
  		REVISION , -- INVCONV
  		LAB_ORGANIZATION_ID -- INVCONV
    from GMD_STABILITY_STUDIES_B
    where SS_ID = X_SS_ID
    for update of SS_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from GMD_STABILITY_STUDIES_TL
    where SS_ID = X_SS_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of SS_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.ATTRIBUTE29 = X_ATTRIBUTE29)
           OR ((recinfo.ATTRIBUTE29 is null) AND (X_ATTRIBUTE29 is null)))
      AND ((recinfo.ATTRIBUTE30 = X_ATTRIBUTE30)
           OR ((recinfo.ATTRIBUTE30 is null) AND (X_ATTRIBUTE30 is null)))
      AND (recinfo.DELETE_MARK = X_DELETE_MARK)
      AND ((recinfo.STORAGE_SPEC_ID = X_STORAGE_SPEC_ID)
           OR ((recinfo.STORAGE_SPEC_ID is null) AND (X_STORAGE_SPEC_ID is null)))
      AND ((recinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
           OR ((recinfo.ATTRIBUTE_CATEGORY is null) AND (X_ATTRIBUTE_CATEGORY is null)))
      AND ((recinfo.ATTRIBUTE25 = X_ATTRIBUTE25)
           OR ((recinfo.ATTRIBUTE25 is null) AND (X_ATTRIBUTE25 is null)))
      AND ((recinfo.RECOMMENDED_SHELF_LIFE_UNIT = X_RECOMMENDED_SHELF_LIFE_UNIT)
           OR ((recinfo.RECOMMENDED_SHELF_LIFE_UNIT is null) AND (X_RECOMMENDED_SHELF_LIFE_UNIT is null)))
      AND ((recinfo.TEXT_CODE = X_TEXT_CODE)
           OR ((recinfo.TEXT_CODE is null) AND (X_TEXT_CODE is null)))
      AND ((recinfo.SCHEDULED_START_DATE = X_SCHEDULED_START_DATE)
           OR ((recinfo.SCHEDULED_START_DATE is null) AND (X_SCHEDULED_START_DATE is null)))
      AND ((recinfo.SCHEDULED_END_DATE = X_SCHEDULED_END_DATE)
           OR ((recinfo.SCHEDULED_END_DATE is null) AND (X_SCHEDULED_END_DATE is null)))
      AND ((recinfo.REVISED_START_DATE = X_REVISED_START_DATE)
           OR ((recinfo.REVISED_START_DATE is null) AND (X_REVISED_START_DATE is null)))
      AND ((recinfo.REVISED_END_DATE = X_REVISED_END_DATE)
           OR ((recinfo.REVISED_END_DATE is null) AND (X_REVISED_END_DATE is null)))
      AND ((recinfo.ACTUAL_START_DATE = X_ACTUAL_START_DATE)
           OR ((recinfo.ACTUAL_START_DATE is null) AND (X_ACTUAL_START_DATE is null)))
      AND ((recinfo.ACTUAL_END_DATE = X_ACTUAL_END_DATE)
           OR ((recinfo.ACTUAL_END_DATE is null) AND (X_ACTUAL_END_DATE is null)))
      AND ((recinfo.RECOMMENDED_SHELF_LIFE = X_RECOMMENDED_SHELF_LIFE)
           OR ((recinfo.RECOMMENDED_SHELF_LIFE is null) AND (X_RECOMMENDED_SHELF_LIFE is null)))
      AND ((recinfo.ATTRIBUTE26 = X_ATTRIBUTE26)
           OR ((recinfo.ATTRIBUTE26 is null) AND (X_ATTRIBUTE26 is null)))
      AND ((recinfo.ATTRIBUTE27 = X_ATTRIBUTE27)
           OR ((recinfo.ATTRIBUTE27 is null) AND (X_ATTRIBUTE27 is null)))
      AND ((recinfo.ATTRIBUTE28 = X_ATTRIBUTE28)
           OR ((recinfo.ATTRIBUTE28 is null) AND (X_ATTRIBUTE28 is null)))
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
      AND ((recinfo.NOTIFICATION_LEAD_TIME = X_NOTIFICATION_LEAD_TIME)
           OR ((recinfo.NOTIFICATION_LEAD_TIME is null) AND (X_NOTIFICATION_LEAD_TIME is null)))
      AND ((recinfo.NOTIFICATION_LEAD_TIME_UNIT = X_NOTIFICATION_LEAD_TIME_UNIT)
           OR ((recinfo.NOTIFICATION_LEAD_TIME_UNIT is null) AND (X_NOTIFICATION_LEAD_TIME_UNIT is null)))
      AND ((recinfo.TESTING_GRACE_PERIOD = X_TESTING_GRACE_PERIOD)
           OR ((recinfo.TESTING_GRACE_PERIOD is null) AND (X_TESTING_GRACE_PERIOD is null)))
      AND ((recinfo.TESTING_GRACE_PERIOD_UNIT = X_TESTING_GRACE_PERIOD_UNIT)
           OR ((recinfo.TESTING_GRACE_PERIOD_UNIT is null) AND (X_TESTING_GRACE_PERIOD_UNIT is null)))
      --AND (recinfo.ORGN_CODE = X_ORGN_CODE) -- INVCONV
      AND (recinfo.SS_NO = X_SS_NO)
      AND (recinfo.STATUS = X_STATUS)
      AND (recinfo.STORAGE_PLAN_ID = X_STORAGE_PLAN_ID)
      --AND (recinfo.ITEM_ID = X_ITEM_ID) -- INVCONV
      AND (recinfo.BASE_SPEC_ID = X_BASE_SPEC_ID)
      --AND (recinfo.QC_LAB_ORGN_CODE = X_QC_LAB_ORGN_CODE) -- INVCONV
      AND (recinfo.OWNER = X_OWNER)
      AND (recinfo.MATERIAL_SOURCES_CNT = X_MATERIAL_SOURCES_CNT)
      AND (recinfo.PACKAGES_CNT = X_PACKAGES_CNT)
      AND (recinfo.ORGANIZATION_ID = X_ORGANIZATION_ID) -- INVCONV
      AND (recinfo.INVENTORY_ITEM_ID = X_INVENTORY_ITEM_ID) -- INVCONV
      AND ((recinfo.REVISION = X_REVISION) OR (recinfo.REVISION IS NULL AND X_REVISION IS NULL))-- INVCONV
      AND (recinfo.LAB_ORGANIZATION_ID = X_LAB_ORGANIZATION_ID) -- INVCONV

  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.DESCRIPTION = X_DESCRIPTION)
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
  X_SS_ID in NUMBER,
  X_ATTRIBUTE29 in VARCHAR2,
  X_ATTRIBUTE30 in VARCHAR2,
  X_DELETE_MARK in NUMBER,
  X_STORAGE_SPEC_ID in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE25 in VARCHAR2,
  X_RECOMMENDED_SHELF_LIFE_UNIT in VARCHAR2,
  X_TEXT_CODE in NUMBER,
  X_SCHEDULED_START_DATE in DATE,
  X_SCHEDULED_END_DATE in DATE,
  X_REVISED_START_DATE in DATE,
  X_REVISED_END_DATE in DATE,
  X_ACTUAL_START_DATE in DATE,
  X_ACTUAL_END_DATE in DATE,
  X_RECOMMENDED_SHELF_LIFE in NUMBER,
  X_ATTRIBUTE26 in VARCHAR2,
  X_ATTRIBUTE27 in VARCHAR2,
  X_ATTRIBUTE28 in VARCHAR2,
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
  X_NOTIFICATION_LEAD_TIME in NUMBER,
  X_NOTIFICATION_LEAD_TIME_UNIT in VARCHAR2,
  X_TESTING_GRACE_PERIOD in NUMBER,
  X_TESTING_GRACE_PERIOD_UNIT in VARCHAR2,
  --X_ORGN_CODE in VARCHAR2, -- INVCONV
  X_SS_NO in VARCHAR2,
  X_STATUS in NUMBER,
  X_STORAGE_PLAN_ID in NUMBER,
  --X_ITEM_ID in NUMBER, -- INVCONV
  X_BASE_SPEC_ID in NUMBER,
  --X_QC_LAB_ORGN_CODE in VARCHAR2, -- INVCONV
  X_OWNER in NUMBER,
  X_MATERIAL_SOURCES_CNT in NUMBER,
  X_STORAGE_CONDITIONS_CNT in NUMBER,
  X_PACKAGES_CNT in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_ORGANIZATION_ID in NUMBER, -- INVCONV
  X_INVENTORY_ITEM_ID in NUMBER, -- INVCONV
  X_REVISION in VARCHAR2, -- INVCONV
  X_LAB_ORGANIZATION_ID in NUMBER, -- INVCONV
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update GMD_STABILITY_STUDIES_B set
    ATTRIBUTE29 = X_ATTRIBUTE29,
    ATTRIBUTE30 = X_ATTRIBUTE30,
    DELETE_MARK = X_DELETE_MARK,
    STORAGE_SPEC_ID = X_STORAGE_SPEC_ID,
    ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY,
    ATTRIBUTE25 = X_ATTRIBUTE25,
    RECOMMENDED_SHELF_LIFE_UNIT = X_RECOMMENDED_SHELF_LIFE_UNIT,
    TEXT_CODE = X_TEXT_CODE,
    SCHEDULED_START_DATE = X_SCHEDULED_START_DATE,
    SCHEDULED_END_DATE = X_SCHEDULED_END_DATE,
    REVISED_START_DATE = X_REVISED_START_DATE,
    REVISED_END_DATE = X_REVISED_END_DATE,
    ACTUAL_START_DATE = X_ACTUAL_START_DATE,
    ACTUAL_END_DATE = X_ACTUAL_END_DATE,
    RECOMMENDED_SHELF_LIFE = X_RECOMMENDED_SHELF_LIFE,
    ATTRIBUTE26 = X_ATTRIBUTE26,
    ATTRIBUTE27 = X_ATTRIBUTE27,
    ATTRIBUTE28 = X_ATTRIBUTE28,
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
    ATTRIBUTE16 = X_ATTRIBUTE16,
    ATTRIBUTE17 = X_ATTRIBUTE17,
    ATTRIBUTE18 = X_ATTRIBUTE18,
    ATTRIBUTE19 = X_ATTRIBUTE19,
    ATTRIBUTE20 = X_ATTRIBUTE20,
    ATTRIBUTE21 = X_ATTRIBUTE21,
    ATTRIBUTE22 = X_ATTRIBUTE22,
    ATTRIBUTE23 = X_ATTRIBUTE23,
    ATTRIBUTE24 = X_ATTRIBUTE24,
    NOTIFICATION_LEAD_TIME = X_NOTIFICATION_LEAD_TIME,
    NOTIFICATION_LEAD_TIME_UNIT = X_NOTIFICATION_LEAD_TIME_UNIT,
    TESTING_GRACE_PERIOD = X_TESTING_GRACE_PERIOD,
    TESTING_GRACE_PERIOD_UNIT = X_TESTING_GRACE_PERIOD_UNIT,
    --ORGN_CODE = X_ORGN_CODE, -- INVCONV
    SS_NO = X_SS_NO,
    STATUS = X_STATUS,
    STORAGE_PLAN_ID = X_STORAGE_PLAN_ID,
    --ITEM_ID = X_ITEM_ID, -- INVCONV
    BASE_SPEC_ID = X_BASE_SPEC_ID,
    --QC_LAB_ORGN_CODE = X_QC_LAB_ORGN_CODE, -- INVCONV
    OWNER = X_OWNER,
    MATERIAL_SOURCES_CNT = X_MATERIAL_SOURCES_CNT,
    STORAGE_CONDITIONS_CNT = X_STORAGE_CONDITIONS_CNT,
    PACKAGES_CNT = X_PACKAGES_CNT,
    ORGANIZATION_ID = X_ORGANIZATION_ID, -- INVCONV
  	INVENTORY_ITEM_ID = X_INVENTORY_ITEM_ID, -- INVCONV
  	REVISION = X_REVISION, -- INVCONV
    LAB_ORGANIZATION_ID = X_LAB_ORGANIZATION_ID, -- INVCONV
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where SS_ID = X_SS_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update GMD_STABILITY_STUDIES_TL set
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where SS_ID = X_SS_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_SS_ID in NUMBER
) is
begin
  delete from GMD_STABILITY_STUDIES_TL
  where SS_ID = X_SS_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from GMD_STABILITY_STUDIES_B
  where SS_ID = X_SS_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from GMD_STABILITY_STUDIES_TL T
  where not exists
    (select NULL
    from GMD_STABILITY_STUDIES_B B
    where B.SS_ID = T.SS_ID
    );

  update GMD_STABILITY_STUDIES_TL T set (
      DESCRIPTION
    ) = (select
      B.DESCRIPTION
    from GMD_STABILITY_STUDIES_TL B
    where B.SS_ID = T.SS_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.SS_ID,
      T.LANGUAGE
  ) in (select
      SUBT.SS_ID,
      SUBT.LANGUAGE
    from GMD_STABILITY_STUDIES_TL SUBB, GMD_STABILITY_STUDIES_TL SUBT
    where SUBB.SS_ID = SUBT.SS_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DESCRIPTION <> SUBT.DESCRIPTION
  ));

  insert into GMD_STABILITY_STUDIES_TL (
    SS_ID,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.SS_ID,
    B.DESCRIPTION,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from GMD_STABILITY_STUDIES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from GMD_STABILITY_STUDIES_TL T
    where T.SS_ID = B.SS_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end GMD_STABILITY_STUDIES_PVT;

/
