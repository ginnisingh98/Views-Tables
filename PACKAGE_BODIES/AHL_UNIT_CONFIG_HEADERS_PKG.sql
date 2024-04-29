--------------------------------------------------------
--  DDL for Package Body AHL_UNIT_CONFIG_HEADERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_UNIT_CONFIG_HEADERS_PKG" AS
/* $Header: AHLLUCHB.pls 120.1 2005/06/17 14:16:32 appldev  $ */
-- Purpose: Briefly explain the functionality of the package body

-- Contains common table handler procedures update, insert to be used by Unit Config header table.
-- MODIFICATION HISTORY
-- Person      Date    Comments

-- samgigup	10/10/02
-- ---------   ------  ------------------------------------------
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_UNIT_CONFIG_HEADER_ID in out NOCOPY NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_NAME in VARCHAR2,
  X_MASTER_CONFIG_ID in NUMBER,
  X_CSI_ITEM_INSTANCE_ID in NUMBER,
  X_UNIT_CONFIG_STATUS_CODE in VARCHAR2,
  X_ACTIVE_START_DATE in DATE,
  X_ACTIVE_END_DATE in DATE,
  --X_SECURITY_GROUP_ID in NUMBER,
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
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from AHL_UNIT_CONFIG_HEADERS
    where UNIT_CONFIG_HEADER_ID = X_UNIT_CONFIG_HEADER_ID
    ;
begin
  insert into AHL_UNIT_CONFIG_HEADERS (
  unit_config_header_id,
    OBJECT_VERSION_NUMBER,
    NAME,
    MASTER_CONFIG_ID,
    CSI_ITEM_INSTANCE_ID,
    UNIT_CONFIG_STATUS_CODE,
    ACTIVE_START_DATE,
    ACTIVE_END_DATE,
    --SECURITY_GROUP_ID,
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
    LAST_UPDATE_LOGIN
  ) values (
  ahl_unit_config_headers_s.nextval,
    X_OBJECT_VERSION_NUMBER,
    X_NAME,
    X_MASTER_CONFIG_ID,
    X_CSI_ITEM_INSTANCE_ID,
    X_UNIT_CONFIG_STATUS_CODE,
    X_ACTIVE_START_DATE,
    X_ACTIVE_END_DATE,
    --X_SECURITY_GROUP_ID,
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
    X_LAST_UPDATE_LOGIN)
    RETURNING unit_config_header_id INTO X_unit_config_header_id;



end INSERT_ROW;

procedure LOCK_ROW (
  X_UNIT_CONFIG_HEADER_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_NAME in VARCHAR2,
  X_MASTER_CONFIG_ID in NUMBER,
  X_CSI_ITEM_INSTANCE_ID in NUMBER,
  X_UNIT_CONFIG_STATUS_CODE in VARCHAR2,
  X_ACTIVE_START_DATE in DATE,
  X_ACTIVE_END_DATE in DATE,
 -- X_SECURITY_GROUP_ID in NUMBER,
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
  X_ATTRIBUTE15 in VARCHAR2
) is
  cursor c is select
      OBJECT_VERSION_NUMBER,
      NAME,
      MASTER_CONFIG_ID,
      CSI_ITEM_INSTANCE_ID,
      UNIT_CONFIG_STATUS_CODE,
      ACTIVE_START_DATE,
      ACTIVE_END_DATE,
      --SECURITY_GROUP_ID,
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
      ATTRIBUTE15
    from AHL_UNIT_CONFIG_HEADERS
    where UNIT_CONFIG_HEADER_ID = X_UNIT_CONFIG_HEADER_ID
    for update of UNIT_CONFIG_HEADER_ID nowait;
  recinfo c%rowtype;

begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
      AND (recinfo.NAME = X_NAME)
      AND (recinfo.MASTER_CONFIG_ID = X_MASTER_CONFIG_ID)
      AND (recinfo.CSI_ITEM_INSTANCE_ID = X_CSI_ITEM_INSTANCE_ID)
      AND (recinfo.UNIT_CONFIG_STATUS_CODE = X_UNIT_CONFIG_STATUS_CODE)
      AND (recinfo.ACTIVE_START_DATE = X_ACTIVE_START_DATE)
      AND ((recinfo.ACTIVE_END_DATE = X_ACTIVE_END_DATE)
           OR ((recinfo.ACTIVE_END_DATE is null) AND (X_ACTIVE_END_DATE is null)))
      --AND ((recinfo.SECURITY_GROUP_ID = X_SECURITY_GROUP_ID)
          -- OR ((recinfo.SECURITY_GROUP_ID is null) AND (X_SECURITY_GROUP_ID is null)))
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
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_UNIT_CONFIG_HEADER_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_NAME in VARCHAR2,
  X_MASTER_CONFIG_ID in NUMBER,
  X_CSI_ITEM_INSTANCE_ID in NUMBER,
  X_UNIT_CONFIG_STATUS_CODE in VARCHAR2,
  X_ACTIVE_START_DATE in DATE,
  X_ACTIVE_END_DATE in DATE,
  --X_SECURITY_GROUP_ID in NUMBER,
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
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update AHL_UNIT_CONFIG_HEADERS set
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    NAME = X_NAME,
    MASTER_CONFIG_ID = X_MASTER_CONFIG_ID,
    CSI_ITEM_INSTANCE_ID = X_CSI_ITEM_INSTANCE_ID,
    UNIT_CONFIG_STATUS_CODE = X_UNIT_CONFIG_STATUS_CODE,
    ACTIVE_START_DATE = X_ACTIVE_START_DATE,
    ACTIVE_END_DATE = X_ACTIVE_END_DATE,
    --SECURITY_GROUP_ID = X_SECURITY_GROUP_ID,
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
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where UNIT_CONFIG_HEADER_ID = X_UNIT_CONFIG_HEADER_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;

procedure DELETE_ROW (
  X_UNIT_CONFIG_HEADER_ID in NUMBER
) is
begin

  delete from AHL_UNIT_CONFIG_HEADERS
  where UNIT_CONFIG_HEADER_ID = X_UNIT_CONFIG_HEADER_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
null;
end ADD_LANGUAGE;

end AHL_UNIT_CONFIG_HEADERS_PKG;




/