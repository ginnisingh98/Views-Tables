--------------------------------------------------------
--  DDL for Package Body AHL_VISIT_TASKS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_VISIT_TASKS_PKG" as
/* $Header: AHLLTSKB.pls 120.1.12010000.3 2010/02/02 10:12:23 tchimira ship $ */
-- TCHIMIRA::BUG 9303368 :: 02-02-2010::START
-- Catch the dup_val_on_index exception and re-insert with current maximum + 1 for visit_task_number
procedure INTERNAL_INSERT_B_ROW (
  X_DEPARTMENT_ID in NUMBER,
  X_PRICE_LIST_ID in NUMBER,
  X_STATUS_CODE in VARCHAR2,
  X_ESTIMATED_PRICE in NUMBER,
  X_ACTUAL_PRICE in NUMBER,
  X_ACTUAL_COST in NUMBER,
  X_STAGE_ID in NUMBER,
  X_END_DATE_TIME in DATE,
  X_START_DATE_TIME in DATE,
  X_PAST_TASK_START_DATE in DATE,
  X_PAST_TASK_END_DATE in DATE,
  X_INVENTORY_ITEM_ID in NUMBER,
  X_INSTANCE_ID in NUMBER,
  X_PRIMARY_VISIT_TASK_ID in NUMBER,
  X_SUMMARY_TASK_FLAG in VARCHAR2,
  X_ORIGINATING_TASK_ID in NUMBER,
  X_VISIT_TASK_NUMBER in NUMBER,
  X_ITEM_ORGANIZATION_ID in NUMBER,
  X_SERVICE_REQUEST_ID in NUMBER,
  X_TASK_TYPE_CODE in VARCHAR2,
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
  X_VISIT_TASK_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_VISIT_ID in NUMBER,
  X_PROJECT_TASK_ID in NUMBER,
  X_COST_PARENT_ID in NUMBER,
  X_MR_ROUTE_ID in NUMBER,
  X_MR_ID in NUMBER,
  X_DURATION in NUMBER,
  X_UNIT_EFFECTIVITY_ID in NUMBER,
  X_START_FROM_HOUR in NUMBER,
  X_QUANTITY in NUMBER,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
l_count NUMBER;
l_visit_task_number NUMBER;
L_MAX_RETRIES NUMBER := 50;
begin
  l_count         := 0;
  l_visit_task_number  := X_VISIT_TASK_NUMBER;

  -- Call insert statement in a loop, till either DUP_VAL_ON_INDEX is not thrown or l_count < L_MAX_RETRIES
  WHILE l_count < L_MAX_RETRIES LOOP
    begin
  insert into AHL_VISIT_TASKS_B (
    DEPARTMENT_ID,
    PRICE_LIST_ID,
    STATUS_CODE,
    ESTIMATED_PRICE,
    ACTUAL_PRICE,
    ACTUAL_COST,
    STAGE_ID,
    END_DATE_TIME,
    START_DATE_TIME,
    PAST_TASK_START_DATE,
    PAST_TASK_END_DATE,
    INVENTORY_ITEM_ID,
    INSTANCE_ID,
    PRIMARY_VISIT_TASK_ID,
    SUMMARY_TASK_FLAG,
    ORIGINATING_TASK_ID,
    VISIT_TASK_NUMBER,
    ITEM_ORGANIZATION_ID,
    SERVICE_REQUEST_ID,
    TASK_TYPE_CODE,
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
    VISIT_TASK_ID,
    OBJECT_VERSION_NUMBER,
    VISIT_ID,
    PROJECT_TASK_ID,
    COST_PARENT_ID,
    MR_ROUTE_ID,
    MR_ID,
    DURATION,
    UNIT_EFFECTIVITY_ID,
    START_FROM_HOUR,
    QUANTITY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_DEPARTMENT_ID,
    X_PRICE_LIST_ID,
    X_STATUS_CODE,
    X_ESTIMATED_PRICE,
    X_ACTUAL_PRICE,
    X_ACTUAL_COST,
    X_STAGE_ID,
    X_END_DATE_TIME,
    X_START_DATE_TIME,
    X_PAST_TASK_START_DATE,
    X_PAST_TASK_END_DATE,
    X_INVENTORY_ITEM_ID,
    X_INSTANCE_ID,
    X_PRIMARY_VISIT_TASK_ID,
    X_SUMMARY_TASK_FLAG,
    X_ORIGINATING_TASK_ID,
    l_visit_task_number,
    X_ITEM_ORGANIZATION_ID,
    X_SERVICE_REQUEST_ID,
    X_TASK_TYPE_CODE,
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
    X_VISIT_TASK_ID,
    X_OBJECT_VERSION_NUMBER,
    X_VISIT_ID,
    X_PROJECT_TASK_ID,
    X_COST_PARENT_ID,
    X_MR_ROUTE_ID,
    X_MR_ID,
    X_DURATION,
    X_UNIT_EFFECTIVITY_ID,
    X_START_FROM_HOUR,
    X_QUANTITY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );
      -- Exit the while loop if the above insert is successful
      EXIT;
      -- If the insert is not successful catch DUP_VAL_ON_INDEX and increment the l_count by 1
      -- Also fetch the current maximum visit task number +1 into the local variable l_visit_task_number
    EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
        -- If l_count is L_MAX_RETRIES - 1 and still there is this exception,
        -- no more retries are permitted, so raise the exception DUP_VAL_ON_INDEX
        IF (l_count = L_MAX_RETRIES - 1) THEN
          RAISE DUP_VAL_ON_INDEX;
        END IF;
        l_count := l_count + 1;
        select MAX(visit_task_number) + 1 INTO l_visit_task_number FROM Ahl_Visit_Tasks_B;
    END;  -- Nested block with Exception Handler
  END LOOP;

END INTERNAL_INSERT_B_ROW;
-- TCHIMIRA::BUG 9303368 :: 02-02-2010::END

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_VISIT_TASK_ID in NUMBER,
  X_DEPARTMENT_ID in NUMBER,
  X_PRICE_LIST_ID in NUMBER,
  X_STATUS_CODE in VARCHAR2,
  X_ESTIMATED_PRICE in NUMBER,
  X_ACTUAL_PRICE in NUMBER,
  X_ACTUAL_COST in NUMBER,
  X_STAGE_ID in NUMBER,
  X_END_DATE_TIME in DATE,
  X_START_DATE_TIME in DATE,
  --SKPATHAK :: ER: 9147951 :: 11-JAN-2010 :: Add past dates too
  X_PAST_TASK_START_DATE in DATE,
  X_PAST_TASK_END_DATE in DATE,
  X_INVENTORY_ITEM_ID in NUMBER,
  X_INSTANCE_ID in NUMBER,
  X_PRIMARY_VISIT_TASK_ID in NUMBER,
  X_SUMMARY_TASK_FLAG in VARCHAR2,
  X_ORIGINATING_TASK_ID in NUMBER,
  X_VISIT_TASK_NUMBER in NUMBER,
  X_ITEM_ORGANIZATION_ID in NUMBER,
  X_SERVICE_REQUEST_ID in NUMBER,
  X_TASK_TYPE_CODE in VARCHAR2,
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
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_VISIT_ID in NUMBER,
  X_PROJECT_TASK_ID in NUMBER,
  X_COST_PARENT_ID in NUMBER,
  X_MR_ROUTE_ID in NUMBER,
  X_MR_ID in NUMBER,
  X_DURATION in NUMBER,
  X_UNIT_EFFECTIVITY_ID in NUMBER,
  X_START_FROM_HOUR in NUMBER,
  X_VISIT_TASK_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_QUANTITY in NUMBER, -- Added by rnahata for Issue 105
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from AHL_VISIT_TASKS_B
    where VISIT_TASK_ID = X_VISIT_TASK_ID
    ;
begin
  -- TCHIMIRA::BUG 9303368 :: 02-02-2010
  -- Call the new internal procedure INTERNAL_INSERT_B_ROW to insert into AHL_VISIT_TASKS_B
  INTERNAL_INSERT_B_ROW (
    X_DEPARTMENT_ID,
    X_PRICE_LIST_ID,
    X_STATUS_CODE,
    X_ESTIMATED_PRICE,
    X_ACTUAL_PRICE,
    X_ACTUAL_COST,
    X_STAGE_ID,
    X_END_DATE_TIME,
    X_START_DATE_TIME,
    --SKPATHAK :: ER: 9147951 :: 11-JAN-2010 :: Add past dates too
    X_PAST_TASK_START_DATE,
    X_PAST_TASK_END_DATE,
    X_INVENTORY_ITEM_ID,
    X_INSTANCE_ID,
    X_PRIMARY_VISIT_TASK_ID,
    X_SUMMARY_TASK_FLAG,
    X_ORIGINATING_TASK_ID,
    X_VISIT_TASK_NUMBER,
    X_ITEM_ORGANIZATION_ID,
    X_SERVICE_REQUEST_ID,
    X_TASK_TYPE_CODE,
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
    X_VISIT_TASK_ID,
    X_OBJECT_VERSION_NUMBER,
    X_VISIT_ID,
    X_PROJECT_TASK_ID,
    X_COST_PARENT_ID,
    X_MR_ROUTE_ID,
    X_MR_ID,
    X_DURATION,
    X_UNIT_EFFECTIVITY_ID,
    X_START_FROM_HOUR,
    X_QUANTITY, -- Added by rnahata for Issue 105
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into AHL_VISIT_TASKS_TL (
    VISIT_TASK_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    DESCRIPTION,
    VISIT_TASK_NAME,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_VISIT_TASK_ID,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_DESCRIPTION,
    X_VISIT_TASK_NAME,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from AHL_VISIT_TASKS_TL T
    where T.VISIT_TASK_ID = X_VISIT_TASK_ID
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
  X_VISIT_TASK_ID in NUMBER,
  X_DEPARTMENT_ID in NUMBER,
  X_PRICE_LIST_ID in NUMBER,
  X_STATUS_CODE in VARCHAR2,
  X_ESTIMATED_PRICE in NUMBER,
  X_ACTUAL_PRICE in NUMBER,
  X_ACTUAL_COST in NUMBER,
  X_STAGE_ID in NUMBER,
  X_END_DATE_TIME in DATE,
  X_START_DATE_TIME in DATE,
  --SKPATHAK :: ER: 9147951 :: 11-JAN-2010 :: Add past dates too
  X_PAST_TASK_START_DATE in DATE,
  X_PAST_TASK_END_DATE in DATE,
  X_INVENTORY_ITEM_ID in NUMBER,
  X_INSTANCE_ID in NUMBER,
  X_PRIMARY_VISIT_TASK_ID in NUMBER,
  X_SUMMARY_TASK_FLAG in VARCHAR2,
  X_ORIGINATING_TASK_ID in NUMBER,
  X_VISIT_TASK_NUMBER in NUMBER,
  X_ITEM_ORGANIZATION_ID in NUMBER,
  X_SERVICE_REQUEST_ID in NUMBER,
  X_TASK_TYPE_CODE in VARCHAR2,
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
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_VISIT_ID in NUMBER,
  X_PROJECT_TASK_ID in NUMBER,
  X_COST_PARENT_ID in NUMBER,
  X_MR_ROUTE_ID in NUMBER,
  X_MR_ID in NUMBER,
  X_DURATION in NUMBER,
  X_UNIT_EFFECTIVITY_ID in NUMBER,
  X_START_FROM_HOUR in NUMBER,
  X_VISIT_TASK_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      DEPARTMENT_ID,
      PRICE_LIST_ID,
      STATUS_CODE,
      ESTIMATED_PRICE,
      ACTUAL_PRICE,
      ACTUAL_COST,
      STAGE_ID,
      END_DATE_TIME,
      START_DATE_TIME,
      --SKPATHAK :: ER: 9147951 :: 11-JAN-2010 :: Add past dates too
      PAST_TASK_START_DATE,
      PAST_TASK_END_DATE,
      INVENTORY_ITEM_ID,
      INSTANCE_ID,
      PRIMARY_VISIT_TASK_ID,
      SUMMARY_TASK_FLAG,
      ORIGINATING_TASK_ID,
      VISIT_TASK_NUMBER,
      ITEM_ORGANIZATION_ID,
      SERVICE_REQUEST_ID,
      TASK_TYPE_CODE,
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
      OBJECT_VERSION_NUMBER,
      VISIT_ID,
      PROJECT_TASK_ID,
      COST_PARENT_ID,
      MR_ROUTE_ID,
      MR_ID,
      DURATION,
      UNIT_EFFECTIVITY_ID,
      START_FROM_HOUR
    from AHL_VISIT_TASKS_B
    where VISIT_TASK_ID = X_VISIT_TASK_ID
    for update of VISIT_TASK_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      VISIT_TASK_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from AHL_VISIT_TASKS_TL
    where VISIT_TASK_ID = X_VISIT_TASK_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of VISIT_TASK_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.DEPARTMENT_ID = X_DEPARTMENT_ID)
           OR ((recinfo.DEPARTMENT_ID is null) AND (X_DEPARTMENT_ID is null)))
      AND ((recinfo.PRICE_LIST_ID = X_PRICE_LIST_ID)
           OR ((recinfo.PRICE_LIST_ID is null) AND (X_PRICE_LIST_ID is null)))
      AND ((recinfo.STATUS_CODE = X_STATUS_CODE)
           OR ((recinfo.STATUS_CODE is null) AND (X_STATUS_CODE is null)))
      AND ((recinfo.ESTIMATED_PRICE = X_ESTIMATED_PRICE)
           OR ((recinfo.ESTIMATED_PRICE is null) AND (X_ESTIMATED_PRICE is null)))
      AND ((recinfo.ACTUAL_PRICE = X_ACTUAL_PRICE)
           OR ((recinfo.ACTUAL_PRICE is null) AND (X_ACTUAL_PRICE is null)))
      AND ((recinfo.ACTUAL_COST = X_ACTUAL_COST)
           OR ((recinfo.ACTUAL_COST is null) AND (X_ACTUAL_COST is null)))
      AND ((recinfo.STAGE_ID = X_STAGE_ID)
           OR ((recinfo.STAGE_ID is null) AND (X_STAGE_ID is null)))
      AND ((recinfo.END_DATE_TIME = X_END_DATE_TIME)
           OR ((recinfo.END_DATE_TIME is null) AND (X_END_DATE_TIME is null)))
      AND ((recinfo.START_DATE_TIME = X_START_DATE_TIME)
           OR ((recinfo.START_DATE_TIME is null) AND (X_START_DATE_TIME is null)))
      --SKPATHAK :: ER: 9147951 :: 11-JAN-2010 :: Add past dates too
      AND ((recinfo.PAST_TASK_START_DATE = X_PAST_TASK_START_DATE)
           OR ((recinfo.PAST_TASK_START_DATE is null) AND (X_PAST_TASK_START_DATE is null)))
      AND ((recinfo.PAST_TASK_END_DATE = X_PAST_TASK_END_DATE)
           OR ((recinfo.PAST_TASK_END_DATE is null) AND (X_PAST_TASK_END_DATE is null)))

      AND ((recinfo.INVENTORY_ITEM_ID = X_INVENTORY_ITEM_ID)
           OR ((recinfo.INVENTORY_ITEM_ID is null) AND (X_INVENTORY_ITEM_ID is null)))
      AND ((recinfo.INSTANCE_ID = X_INSTANCE_ID)
           OR ((recinfo.INSTANCE_ID is null) AND (X_INSTANCE_ID is null)))
      AND ((recinfo.PRIMARY_VISIT_TASK_ID = X_PRIMARY_VISIT_TASK_ID)
           OR ((recinfo.PRIMARY_VISIT_TASK_ID is null) AND (X_PRIMARY_VISIT_TASK_ID is null)))
      AND (recinfo.SUMMARY_TASK_FLAG = X_SUMMARY_TASK_FLAG)
      AND ((recinfo.ORIGINATING_TASK_ID = X_ORIGINATING_TASK_ID)
           OR ((recinfo.ORIGINATING_TASK_ID is null) AND (X_ORIGINATING_TASK_ID is null)))
      AND (recinfo.VISIT_TASK_NUMBER = X_VISIT_TASK_NUMBER)
      AND ((recinfo.ITEM_ORGANIZATION_ID = X_ITEM_ORGANIZATION_ID)
           OR ((recinfo.ITEM_ORGANIZATION_ID is null) AND (X_ITEM_ORGANIZATION_ID is null)))
      AND ((recinfo.SERVICE_REQUEST_ID = X_SERVICE_REQUEST_ID)
           OR ((recinfo.SERVICE_REQUEST_ID is null) AND (X_SERVICE_REQUEST_ID is null)))
      AND (recinfo.TASK_TYPE_CODE = X_TASK_TYPE_CODE)
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
      AND (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
      AND (recinfo.VISIT_ID = X_VISIT_ID)
      AND ((recinfo.PROJECT_TASK_ID = X_PROJECT_TASK_ID)
           OR ((recinfo.PROJECT_TASK_ID is null) AND (X_PROJECT_TASK_ID is null)))
      AND ((recinfo.COST_PARENT_ID = X_COST_PARENT_ID)
           OR ((recinfo.COST_PARENT_ID is null) AND (X_COST_PARENT_ID is null)))
      AND ((recinfo.MR_ROUTE_ID = X_MR_ROUTE_ID)
           OR ((recinfo.MR_ROUTE_ID is null) AND (X_MR_ROUTE_ID is null)))
      AND ((recinfo.MR_ID = X_MR_ID)
           OR ((recinfo.MR_ID is null) AND (X_MR_ID is null)))
      AND ((recinfo.DURATION = X_DURATION)
           OR ((recinfo.DURATION is null) AND (X_DURATION is null)))
      AND ((recinfo.UNIT_EFFECTIVITY_ID = X_UNIT_EFFECTIVITY_ID)
           OR ((recinfo.UNIT_EFFECTIVITY_ID is null) AND (X_UNIT_EFFECTIVITY_ID is null)))
      AND ((recinfo.START_FROM_HOUR = X_START_FROM_HOUR)
           OR ((recinfo.START_FROM_HOUR is null) AND (X_START_FROM_HOUR is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.VISIT_TASK_NAME = X_VISIT_TASK_NAME)
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
  X_VISIT_TASK_ID in NUMBER,
  X_DEPARTMENT_ID in NUMBER,
  X_PRICE_LIST_ID in NUMBER,
  X_STATUS_CODE in VARCHAR2,
  X_ESTIMATED_PRICE in NUMBER,
  X_ACTUAL_PRICE in NUMBER,
  X_ACTUAL_COST in NUMBER,
  X_STAGE_ID in NUMBER,
  X_END_DATE_TIME in DATE,
  X_START_DATE_TIME in DATE,
  --SKPATHAK :: ER: 9147951 :: 11-JAN-2010 :: Add past dates too
  X_PAST_TASK_START_DATE in DATE,
  X_PAST_TASK_END_DATE in DATE,
  X_INVENTORY_ITEM_ID in NUMBER,
  X_INSTANCE_ID in NUMBER,
  X_PRIMARY_VISIT_TASK_ID in NUMBER,
  X_SUMMARY_TASK_FLAG in VARCHAR2,
  X_ORIGINATING_TASK_ID in NUMBER,
  X_VISIT_TASK_NUMBER in NUMBER,
  X_ITEM_ORGANIZATION_ID in NUMBER,
  X_SERVICE_REQUEST_ID in NUMBER,
  X_TASK_TYPE_CODE in VARCHAR2,
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
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_VISIT_ID in NUMBER,
  X_PROJECT_TASK_ID in NUMBER,
  X_COST_PARENT_ID in NUMBER,
  X_MR_ROUTE_ID in NUMBER,
  X_MR_ID in NUMBER,
  X_DURATION in NUMBER,
  X_UNIT_EFFECTIVITY_ID in NUMBER,
  X_START_FROM_HOUR in NUMBER,
  X_VISIT_TASK_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_QUANTITY  in NUMBER, -- Added by rnahata for Issue 105
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update AHL_VISIT_TASKS_B set
    DEPARTMENT_ID = X_DEPARTMENT_ID,
    PRICE_LIST_ID = X_PRICE_LIST_ID,
    STATUS_CODE = X_STATUS_CODE,
    ESTIMATED_PRICE = X_ESTIMATED_PRICE,
    ACTUAL_PRICE = X_ACTUAL_PRICE,
    ACTUAL_COST = X_ACTUAL_COST,
    STAGE_ID = X_STAGE_ID,
    END_DATE_TIME = X_END_DATE_TIME,
    START_DATE_TIME = X_START_DATE_TIME,
    --SKPATHAK :: ER: 9147951 :: 11-JAN-2010 :: Add past dates too
    PAST_TASK_START_DATE = X_PAST_TASK_START_DATE,
    PAST_TASK_END_DATE = X_PAST_TASK_END_DATE,
    INVENTORY_ITEM_ID = X_INVENTORY_ITEM_ID,
    INSTANCE_ID = X_INSTANCE_ID,
    PRIMARY_VISIT_TASK_ID = X_PRIMARY_VISIT_TASK_ID,
    SUMMARY_TASK_FLAG = X_SUMMARY_TASK_FLAG,
    ORIGINATING_TASK_ID = X_ORIGINATING_TASK_ID,
    VISIT_TASK_NUMBER = X_VISIT_TASK_NUMBER,
    ITEM_ORGANIZATION_ID = X_ITEM_ORGANIZATION_ID,
    SERVICE_REQUEST_ID = X_SERVICE_REQUEST_ID,
    TASK_TYPE_CODE = X_TASK_TYPE_CODE,
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
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    VISIT_ID = X_VISIT_ID,
    PROJECT_TASK_ID = X_PROJECT_TASK_ID,
    COST_PARENT_ID = X_COST_PARENT_ID,
    MR_ROUTE_ID = X_MR_ROUTE_ID,
    MR_ID = X_MR_ID,
    DURATION = X_DURATION,
    UNIT_EFFECTIVITY_ID = X_UNIT_EFFECTIVITY_ID,
    START_FROM_HOUR = X_START_FROM_HOUR,
    QUANTITY = X_QUANTITY, -- Added by rnahata for Issue 105
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where VISIT_TASK_ID = X_VISIT_TASK_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update AHL_VISIT_TASKS_TL set
    VISIT_TASK_NAME = X_VISIT_TASK_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where VISIT_TASK_ID = X_VISIT_TASK_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_VISIT_TASK_ID in NUMBER
) is
begin
  delete from AHL_VISIT_TASKS_TL
  where VISIT_TASK_ID = X_VISIT_TASK_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from AHL_VISIT_TASKS_B
  where VISIT_TASK_ID = X_VISIT_TASK_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from AHL_VISIT_TASKS_TL T
  where not exists
    (select NULL
    from AHL_VISIT_TASKS_B B
    where B.VISIT_TASK_ID = T.VISIT_TASK_ID
    );

  update AHL_VISIT_TASKS_TL T set (
      VISIT_TASK_NAME,
      DESCRIPTION
    ) = (select
      B.VISIT_TASK_NAME,
      B.DESCRIPTION
    from AHL_VISIT_TASKS_TL B
    where B.VISIT_TASK_ID = T.VISIT_TASK_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.VISIT_TASK_ID,
      T.LANGUAGE
  ) in (select
      SUBT.VISIT_TASK_ID,
      SUBT.LANGUAGE
    from AHL_VISIT_TASKS_TL SUBB, AHL_VISIT_TASKS_TL SUBT
    where SUBB.VISIT_TASK_ID = SUBT.VISIT_TASK_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.VISIT_TASK_NAME <> SUBT.VISIT_TASK_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into AHL_VISIT_TASKS_TL (
    VISIT_TASK_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    DESCRIPTION,
    VISIT_TASK_NAME,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.VISIT_TASK_ID,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.DESCRIPTION,
    B.VISIT_TASK_NAME,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from AHL_VISIT_TASKS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AHL_VISIT_TASKS_TL T
    where T.VISIT_TASK_ID = B.VISIT_TASK_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end AHL_VISIT_TASKS_PKG;

/