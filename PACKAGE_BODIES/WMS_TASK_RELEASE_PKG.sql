--------------------------------------------------------
--  DDL for Package Body WMS_TASK_RELEASE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_TASK_RELEASE_PKG" as
/* $Header: WMSTKPLB.pls 120.2.12010000.1 2009/03/25 09:55:16 shrmitra noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_CRITERIA_ID in NUMBER,
  X_CONS_LOCATOR_TOLERANCE in NUMBER,
  X_MIN_EQUIP_CAPACITY_FLAG in VARCHAR2,
  X_CUSTOM_TASK_PLAN_FLAG in VARCHAR2,
  X_CUSTOM_PLAN_TOLERANCE in NUMBER,
  X_ORGANIZATION_ID in NUMBER,
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
  X_REPLEN_COMPLETED_FLAG in VARCHAR2,
  X_REPLEN_TOLERANCE in NUMBER,
  X_REV_TRIP_STOP_FLAG in VARCHAR2,
  X_TRIP_STOP_TOLERANCE in NUMBER,
  X_CONS_LOCATOR_FLAG in VARCHAR2,
  X_CRITERIA_NAME in VARCHAR2,
  X_CRITERIA_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from WMS_TASK_RELEASE_B
    where CRITERIA_ID = X_CRITERIA_ID
    ;

	l_ctype c%ROWTYPE;
begin
  insert into WMS_TASK_RELEASE_B (
    CONS_LOCATOR_TOLERANCE,
    MIN_EQUIP_CAPACITY_FLAG,
    CUSTOM_TASK_PLAN_FLAG,
    CUSTOM_PLAN_TOLERANCE,
    ORGANIZATION_ID,
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
    CRITERIA_ID,
    REPLEN_COMPLETED_FLAG,
    REPLEN_TOLERANCE,
    REV_TRIP_STOP_FLAG,
    TRIP_STOP_TOLERANCE,
    CONS_LOCATOR_FLAG,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_CONS_LOCATOR_TOLERANCE,
    X_MIN_EQUIP_CAPACITY_FLAG,
    X_CUSTOM_TASK_PLAN_FLAG,
    X_CUSTOM_PLAN_TOLERANCE,
    X_ORGANIZATION_ID,
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
    X_CRITERIA_ID,
    X_REPLEN_COMPLETED_FLAG,
    X_REPLEN_TOLERANCE,
    X_REV_TRIP_STOP_FLAG,
    X_TRIP_STOP_TOLERANCE,
    X_CONS_LOCATOR_FLAG,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into WMS_TASK_RELEASE_TL (
    CRITERIA_ID,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATE_LOGIN,
    CRITERIA_NAME,
    CRITERIA_DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_CRITERIA_ID,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATE_LOGIN,
    X_CRITERIA_NAME,
    X_CRITERIA_DESCRIPTION,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from WMS_TASK_RELEASE_TL T
    where T.CRITERIA_ID = X_CRITERIA_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  --fetch c into X_ROWID;
  fetch c into l_ctype;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_CRITERIA_ID in NUMBER,
  X_CONS_LOCATOR_TOLERANCE in NUMBER,
  X_MIN_EQUIP_CAPACITY_FLAG in VARCHAR2,
  X_CUSTOM_TASK_PLAN_FLAG in VARCHAR2,
  X_CUSTOM_PLAN_TOLERANCE in NUMBER,
  X_ORGANIZATION_ID in NUMBER,
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
  X_REPLEN_COMPLETED_FLAG in VARCHAR2,
  X_REPLEN_TOLERANCE in NUMBER,
  X_REV_TRIP_STOP_FLAG in VARCHAR2,
  X_TRIP_STOP_TOLERANCE in NUMBER,
  X_CONS_LOCATOR_FLAG in VARCHAR2,
  X_CRITERIA_NAME in VARCHAR2,
  X_CRITERIA_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      CONS_LOCATOR_TOLERANCE,
      MIN_EQUIP_CAPACITY_FLAG,
      CUSTOM_TASK_PLAN_FLAG,
      CUSTOM_PLAN_TOLERANCE,
      ORGANIZATION_ID,
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
      REPLEN_COMPLETED_FLAG,
      REPLEN_TOLERANCE,
      REV_TRIP_STOP_FLAG,
      TRIP_STOP_TOLERANCE,
      CONS_LOCATOR_FLAG
    from WMS_TASK_RELEASE_B
    where CRITERIA_ID = X_CRITERIA_ID
    for update of CRITERIA_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      CRITERIA_NAME,
      CRITERIA_DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from WMS_TASK_RELEASE_TL
    where CRITERIA_ID = X_CRITERIA_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of CRITERIA_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.CONS_LOCATOR_TOLERANCE = X_CONS_LOCATOR_TOLERANCE)
           OR ((recinfo.CONS_LOCATOR_TOLERANCE is null) AND (X_CONS_LOCATOR_TOLERANCE is null)))
      AND ((recinfo.MIN_EQUIP_CAPACITY_FLAG = X_MIN_EQUIP_CAPACITY_FLAG)
           OR ((recinfo.MIN_EQUIP_CAPACITY_FLAG is null) AND (X_MIN_EQUIP_CAPACITY_FLAG is null)))
      AND ((recinfo.CUSTOM_TASK_PLAN_FLAG = X_CUSTOM_TASK_PLAN_FLAG)
           OR ((recinfo.CUSTOM_TASK_PLAN_FLAG is null) AND (X_CUSTOM_TASK_PLAN_FLAG is null)))
      AND ((recinfo.CUSTOM_PLAN_TOLERANCE = X_CUSTOM_PLAN_TOLERANCE)
           OR ((recinfo.CUSTOM_PLAN_TOLERANCE is null) AND (X_CUSTOM_PLAN_TOLERANCE is null)))
      AND (recinfo.ORGANIZATION_ID = X_ORGANIZATION_ID)
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
      AND ((recinfo.REPLEN_COMPLETED_FLAG = X_REPLEN_COMPLETED_FLAG)
           OR ((recinfo.REPLEN_COMPLETED_FLAG is null) AND (X_REPLEN_COMPLETED_FLAG is null)))
      AND ((recinfo.REPLEN_TOLERANCE = X_REPLEN_TOLERANCE)
           OR ((recinfo.REPLEN_TOLERANCE is null) AND (X_REPLEN_TOLERANCE is null)))
      AND ((recinfo.REV_TRIP_STOP_FLAG = X_REV_TRIP_STOP_FLAG)
           OR ((recinfo.REV_TRIP_STOP_FLAG is null) AND (X_REV_TRIP_STOP_FLAG is null)))
      AND ((recinfo.TRIP_STOP_TOLERANCE = X_TRIP_STOP_TOLERANCE)
           OR ((recinfo.TRIP_STOP_TOLERANCE is null) AND (X_TRIP_STOP_TOLERANCE is null)))
      AND ((recinfo.CONS_LOCATOR_FLAG = X_CONS_LOCATOR_FLAG)
           OR ((recinfo.CONS_LOCATOR_FLAG is null) AND (X_CONS_LOCATOR_FLAG is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.CRITERIA_NAME = X_CRITERIA_NAME)
          AND ((tlinfo.CRITERIA_DESCRIPTION = X_CRITERIA_DESCRIPTION)
               OR ((tlinfo.CRITERIA_DESCRIPTION is null) AND (X_CRITERIA_DESCRIPTION is null)))
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
  X_CRITERIA_ID in NUMBER,
  X_CONS_LOCATOR_TOLERANCE in NUMBER,
  X_MIN_EQUIP_CAPACITY_FLAG in VARCHAR2,
  X_CUSTOM_TASK_PLAN_FLAG in VARCHAR2,
  X_CUSTOM_PLAN_TOLERANCE in NUMBER,
  X_ORGANIZATION_ID in NUMBER,
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
  X_REPLEN_COMPLETED_FLAG in VARCHAR2,
  X_REPLEN_TOLERANCE in NUMBER,
  X_REV_TRIP_STOP_FLAG in VARCHAR2,
  X_TRIP_STOP_TOLERANCE in NUMBER,
  X_CONS_LOCATOR_FLAG in VARCHAR2,
  X_CRITERIA_NAME in VARCHAR2,
  X_CRITERIA_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update WMS_TASK_RELEASE_B set
    CONS_LOCATOR_TOLERANCE = X_CONS_LOCATOR_TOLERANCE,
    MIN_EQUIP_CAPACITY_FLAG = X_MIN_EQUIP_CAPACITY_FLAG,
    CUSTOM_TASK_PLAN_FLAG = X_CUSTOM_TASK_PLAN_FLAG,
    CUSTOM_PLAN_TOLERANCE = X_CUSTOM_PLAN_TOLERANCE,
    ORGANIZATION_ID = X_ORGANIZATION_ID,
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
    REPLEN_COMPLETED_FLAG = X_REPLEN_COMPLETED_FLAG,
    REPLEN_TOLERANCE = X_REPLEN_TOLERANCE,
    REV_TRIP_STOP_FLAG = X_REV_TRIP_STOP_FLAG,
    TRIP_STOP_TOLERANCE = X_TRIP_STOP_TOLERANCE,
    CONS_LOCATOR_FLAG = X_CONS_LOCATOR_FLAG,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where CRITERIA_ID = X_CRITERIA_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update WMS_TASK_RELEASE_TL set
    CRITERIA_NAME = X_CRITERIA_NAME,
    CRITERIA_DESCRIPTION = X_CRITERIA_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where CRITERIA_ID = X_CRITERIA_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_CRITERIA_ID in NUMBER
) is
begin
  delete from WMS_TASK_RELEASE_TL
  where CRITERIA_ID = X_CRITERIA_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from WMS_TASK_RELEASE_B
  where CRITERIA_ID = X_CRITERIA_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from WMS_TASK_RELEASE_TL T
  where not exists
    (select NULL
    from WMS_TASK_RELEASE_B B
    where B.CRITERIA_ID = T.CRITERIA_ID
    );

  update WMS_TASK_RELEASE_TL T set (
      CRITERIA_NAME,
      CRITERIA_DESCRIPTION
    ) = (select
      B.CRITERIA_NAME,
      B.CRITERIA_DESCRIPTION
    from WMS_TASK_RELEASE_TL B
    where B.CRITERIA_ID = T.CRITERIA_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.CRITERIA_ID,
      T.LANGUAGE
  ) in (select
      SUBT.CRITERIA_ID,
      SUBT.LANGUAGE
    from WMS_TASK_RELEASE_TL SUBB, WMS_TASK_RELEASE_TL SUBT
    where SUBB.CRITERIA_ID = SUBT.CRITERIA_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.CRITERIA_NAME <> SUBT.CRITERIA_NAME
      or SUBB.CRITERIA_DESCRIPTION <> SUBT.CRITERIA_DESCRIPTION
      or (SUBB.CRITERIA_DESCRIPTION is null and SUBT.CRITERIA_DESCRIPTION is not null)
      or (SUBB.CRITERIA_DESCRIPTION is not null and SUBT.CRITERIA_DESCRIPTION is null)
  ));

  insert into WMS_TASK_RELEASE_TL (
    CRITERIA_ID,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATE_LOGIN,
    CRITERIA_NAME,
    CRITERIA_DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.CRITERIA_ID,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATE_LOGIN,
    B.CRITERIA_NAME,
    B.CRITERIA_DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from WMS_TASK_RELEASE_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from WMS_TASK_RELEASE_TL T
    where T.CRITERIA_ID = B.CRITERIA_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end WMS_TASK_RELEASE_PKG;

/