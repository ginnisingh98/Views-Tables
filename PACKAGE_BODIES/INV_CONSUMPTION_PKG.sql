--------------------------------------------------------
--  DDL for Package Body INV_CONSUMPTION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_CONSUMPTION_PKG" as
/* $Header: INVCNTHB.pls 115.4 2002/12/20 20:23:39 satkumar noship $ */
procedure INSERT_ROW (
  X_ROWID 		IN out NOCOPY varchar2,
  X_TRANSACTION_TYPE_ID	    IN NUMBER,
  X_ORGANIZATION_ID	    IN NUMBER,
  X_SUBINVENTORY_CODE	    IN VARCHAR2,
  X_XFER_SUBINVENTORY_CODE  IN VARCHAR2,
  x_from_locator_id         IN NUMBER,
  x_to_locator_id           IN NUMBER,
  X_INVENTORY_ITEM_ID	    IN NUMBER,
  x_owning_organization_id  IN	NUMBER,
  x_planning_organization_id IN	NUMBER,
  x_consume_consigned_flag   IN	VARCHAR2,
  X_CONSUME_VMI_FLAG	     IN VARCHAR2,
  X_ATTRIBUTE_CATEGORY 		in VARCHAR2,
  X_ATTRIBUTE1			in VARCHAR2,
  X_ATTRIBUTE2			in VARCHAR2,
  X_ATTRIBUTE3			in VARCHAR2,
  X_ATTRIBUTE4			in VARCHAR2,
  X_ATTRIBUTE5			in VARCHAR2,
  X_ATTRIBUTE6			in VARCHAR2,
  X_ATTRIBUTE7			in VARCHAR2,
  X_ATTRIBUTE8			in VARCHAR2,
  X_ATTRIBUTE9			in VARCHAR2,
  X_ATTRIBUTE10			in VARCHAR2,
  X_ATTRIBUTE11			in VARCHAR2,
  X_ATTRIBUTE12			in VARCHAR2,
  X_ATTRIBUTE13			in VARCHAR2,
  X_ATTRIBUTE14			in VARCHAR2,
  X_ATTRIBUTE15			in VARCHAR2,
  X_CREATION_DATE 		in DATE,
  X_CREATED_BY 			in NUMBER,
  X_LAST_UPDATE_DATE 		in DATE,
  X_LAST_UPDATED_BY 		in NUMBER,
  X_LAST_UPDATE_LOGIN 		in NUMBER,
  x_weight                      IN number
) is

   CURSOR C IS SELECT rowid FROM MTL_CONSUMPTION_DEFINITION
     WHERE transaction_type_id = x_transaction_type_id
     and nvl(ORGANIZATION_ID, nvl(X_ORGANIZATION_ID,-999))= nvl(X_ORGANIZATION_ID,-999)
     and nvl(SUBINVENTORY_CODE, nvl(X_SUBINVENTORY_CODE,-999)) = nvl(X_SUBINVENTORY_CODE,-999)
     and nvl(XFER_SUBINVENTORY_CODE, nvl(X_XFER_SUBINVENTORY_CODE, -999) )
                                                    = nvl(X_XFER_SUBINVENTORY_CODE, -999)
     and  nvl(FROM_LOCATOR_ID, nvl(X_FROM_LOCATOR_ID, -999)) = nvl(X_FROM_LOCATOR_ID, -999)
     and  nvl(TO_LOCATOR_ID, nvl(X_TO_LOCATOR_ID, -999)) = nvl(X_TO_LOCATOR_ID, -999)
     and nvl(INVENTORY_ITEM_ID,nvl(X_INVENTORY_ITEM_ID ,- 999)) = nvl(X_INVENTORY_ITEM_ID ,-999)
     and nvl(weight,nvl(X_weight ,- 999)) = nvl( X_weight ,-999)
     and nvl(OWNING_ORGANIZATION_ID, nvl(X_OWNING_ORGANIZATION_ID, -999) )
                                                = nvl(X_OWNING_ORGANIZATION_ID, -999)
     and nvl(PLANNING_ORGANIZATION_ID,nvl(X_PLANNING_ORGANIZATION_ID,-999))=nvl(X_PLANNING_ORGANIZATION_ID,-999);


 begin
   insert into MTL_CONSUMPTION_DEFINITION (
  TRANSACTION_TYPE_ID,
  ORGANIZATION_ID,
  SUBINVENTORY_CODE,
  XFER_SUBINVENTORY_CODE,
  from_locator_id,
  to_locator_id,
  INVENTORY_ITEM_ID,
  owning_organization_id,
  planning_organization_id,
  consume_consigned_flag,
  CONSUME_VMI_FLAG,
  ATTRIBUTE_CATEGORY,
  attribute1,
  attribute2,
  attribute3,
  attribute4,
  attribute5,
  attribute6,
  attribute7,
  attribute8,
  attribute9,
  attribute10,
  attribute11,
  attribute12,
  attribute13,
  attribute14,
  attribute15,
  creation_date,
  created_by,
  last_update_date,
  last_updated_by,
  last_update_login,
   WEIGHT)
     values (
  X_TRANSACTION_TYPE_ID,
  X_ORGANIZATION_ID,
  X_SUBINVENTORY_CODE,
  X_XFER_SUBINVENTORY_CODE,
  X_from_locator_id,
  X_to_locator_id,
  X_INVENTORY_ITEM_ID,
  X_owning_organization_id,
  X_planning_organization_id,
  X_consume_consigned_flag,
  X_CONSUME_VMI_FLAG,
  X_ATTRIBUTE_CATEGORY,
  X_attribute1,
  X_attribute2,
  X_attribute3,
  X_attribute4,
  X_attribute5,
  X_attribute6,
  X_attribute7,
  X_attribute8,
  X_attribute9,
  X_attribute10,
  X_attribute11,
  X_attribute12,
  X_attribute13,
  X_attribute14,
  X_attribute15,
  X_creation_date,
  x_created_by,
  X_last_update_date,
  X_last_updated_by,
	     x_last_update_login,
	     X_WEIGHT);

   OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;

end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID 		in varchar2,
  X_TRANSACTION_TYPE_ID	IN NUMBER,
  X_ORGANIZATION_ID	IN NUMBER,
  X_SUBINVENTORY_CODE	IN VARCHAR2,
  X_XFER_SUBINVENTORY_CODE IN VARCHAR2,
  x_from_locator_id   IN NUMBER,
  x_to_locator_id     IN NUMBER,
  X_INVENTORY_ITEM_ID	IN NUMBER,
  x_owning_organization_id IN	NUMBER,
  x_planning_organization_id IN	NUMBER,
  x_consume_consigned_flag IN	VARCHAR2,
  X_CONSUME_VMI_FLAG	IN VARCHAR2,
  X_ATTRIBUTE_CATEGORY 		in VARCHAR2,
  X_ATTRIBUTE1			in VARCHAR2,
  X_ATTRIBUTE2			in VARCHAR2,
  X_ATTRIBUTE3			in VARCHAR2,
  X_ATTRIBUTE4			in VARCHAR2,
  X_ATTRIBUTE5			in VARCHAR2,
  X_ATTRIBUTE6			in VARCHAR2,
  X_ATTRIBUTE7			in VARCHAR2,
  X_ATTRIBUTE8			in VARCHAR2,
  X_ATTRIBUTE9			in VARCHAR2,
  X_ATTRIBUTE10			in VARCHAR2,
  X_ATTRIBUTE11			in VARCHAR2,
  X_ATTRIBUTE12			in VARCHAR2,
  X_ATTRIBUTE13			in VARCHAR2,
  X_ATTRIBUTE14			in VARCHAR2,
  X_ATTRIBUTE15			in VARCHAR2,
  x_weight                      IN NUMBER
) is
   cursor c is SELECT
     TRANSACTION_TYPE_ID,
     ORGANIZATION_ID,
     SUBINVENTORY_CODE,
     XFER_SUBINVENTORY_CODE,
     from_locator_id,
     to_locator_id,
     INVENTORY_ITEM_ID,
     owning_organization_id,
     planning_organization_id,
     consume_consigned_flag,
     CONSUME_VMI_FLAG,
     weight,
     ATTRIBUTE_CATEGORY,
     attribute1,
     attribute2,
     attribute3,
     attribute4,
     attribute5,
     attribute6,
     attribute7,
     attribute8,
     attribute9,
     attribute10,
     attribute11,
     attribute12,
     attribute13,
     attribute14,
     attribute15
    from MTL_CONSUMPTION_DEFINITION
    where ROWID = X_ROWID
    for update OF TRANSACTION_TYPE_ID nowait;
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

  if (     (recinfo.TRANSACTION_TYPE_ID = X_TRANSACTION_TYPE_ID)
      AND ((recinfo.ORGANIZATION_ID = X_ORGANIZATION_ID)
           OR ((recinfo.ORGANIZATION_ID is null) AND (X_ORGANIZATION_ID is null)))
      AND ((recinfo.SUBINVENTORY_CODE = X_SUBINVENTORY_CODE)
	   OR ((recinfo.SUBINVENTORY_CODE is null) AND (X_SUBINVENTORY_CODE is null)))
      AND ((recinfo.XFER_SUBINVENTORY_CODE = x_xfer_SUBINVENTORY_CODE)
	   OR ((recinfo.XFER_SUBINVENTORY_CODE is null) AND (X_XFER_SUBINVENTORY_CODE is null)))
      AND ((recinfo.from_locator_id = x_from_locator_id)
	   OR ((recinfo.from_locator_id is null) AND (X_from_locator_id is null)))
      AND ((recinfo.TO_locator_id = x_TO_locator_id)
	   OR ((recinfo.TO_locator_id is null) AND (X_TO_locator_id is null)))
      AND ((recinfo.INVENTORY_ITEM_ID = x_inventory_item_id)
	   OR ((recinfo.inventory_item_id is null) AND (X_INVENTORY_ITEM_ID is null)))
      AND ((recinfo.owning_organization_id = x_owning_organization_id)
	   OR ((recinfo.owning_organization_id is null) AND (x_owning_organization_id is null)))
      AND ((recinfo.planning_organization_id  = x_planning_organization_id)
	  OR ((recinfo.planning_organization_id is null) AND (x_planning_organization_id is null)))
      AND ((recinfo.consume_consigned_flag  = x_consume_consigned_flag)
	   OR ((recinfo.consume_consigned_flag is null) AND (x_consume_consigned_flag is null)))
      AND ((recinfo.CONSUME_VMI_FLAG  = x_CONSUME_VMI_FLAG)
	   OR ((recinfo.CONSUME_VMI_FLAG is null) AND (x_CONSUME_VMI_FLAG is null)))
      AND ((recinfo.weight  = x_weight)
	   OR ((recinfo.weight is null) AND (x_weight is null)))
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
    return;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
end LOCK_ROW;

procedure UPDATE_ROW (
  x_rowid IN varchar2,
  X_TRANSACTION_TYPE_ID	IN NUMBER,
  X_ORGANIZATION_ID	IN NUMBER,
  X_SUBINVENTORY_CODE	IN VARCHAR2,
  X_XFER_SUBINVENTORY_CODE IN VARCHAR2,
  x_from_locator_id IN NUMBER,
  x_to_locator_id IN NUMBER,
  X_INVENTORY_ITEM_ID	IN NUMBER,
  x_owning_organization_id IN	NUMBER,
  x_planning_organization_id IN	NUMBER,
  x_consume_consigned_flag IN	VARCHAR2,
  X_CONSUME_VMI_FLAG	IN VARCHAR2,
  X_ATTRIBUTE_CATEGORY 		in VARCHAR2,
  X_ATTRIBUTE1			in VARCHAR2,
  X_ATTRIBUTE2			in VARCHAR2,
  X_ATTRIBUTE3			in VARCHAR2,
  X_ATTRIBUTE4			in VARCHAR2,
  X_ATTRIBUTE5			in VARCHAR2,
  X_ATTRIBUTE6			in VARCHAR2,
  X_ATTRIBUTE7			in VARCHAR2,
  X_ATTRIBUTE8			in VARCHAR2,
  X_ATTRIBUTE9			in VARCHAR2,
  X_ATTRIBUTE10			in VARCHAR2,
  X_ATTRIBUTE11			in VARCHAR2,
  X_ATTRIBUTE12			in VARCHAR2,
  X_ATTRIBUTE13			in VARCHAR2,
  X_ATTRIBUTE14			in VARCHAR2,
  X_ATTRIBUTE15			in VARCHAR2,
  X_LAST_UPDATE_DATE 		in DATE,
  X_LAST_UPDATED_BY 		in NUMBER,
  X_LAST_UPDATE_LOGIN 		in NUMBER,
  x_weight                      IN number
) is

begin
  update MTL_CONSUMPTION_DEFINITION mcd set
    transaction_type_id         = X_transaction_type_id,
    organization_id             = x_organization_id,
    subinventory_code           = x_subinventory_code,
    xfer_subinventory_code      = x_XFER_SUBINVENTORY_CODE,
    from_locator_id             = x_from_locator_id,
    to_locator_id               = x_to_locator_id,
    inventory_item_id           = x_INVENTORY_ITEM_ID,
    owning_organization_id      = x_owning_organization_id,
    planning_organization_id    = x_planning_organization_id,
    consume_consigned_flag      = x_consume_consigned_flag,
    consume_vmi_flag            = x_consume_vmi_flag,
    weight                      = x_weight,
    ATTRIBUTE_CATEGORY 		= X_ATTRIBUTE_CATEGORY,
    ATTRIBUTE1			= X_ATTRIBUTE1,
    ATTRIBUTE2			= X_ATTRIBUTE2,
    ATTRIBUTE3			= X_ATTRIBUTE3,
    ATTRIBUTE4			= X_ATTRIBUTE4,
    ATTRIBUTE5			= X_ATTRIBUTE5,
    ATTRIBUTE6			= X_ATTRIBUTE6,
    ATTRIBUTE7			= X_ATTRIBUTE7,
    ATTRIBUTE8			= X_ATTRIBUTE8,
    ATTRIBUTE9			= X_ATTRIBUTE9,
    ATTRIBUTE10			= X_ATTRIBUTE10,
    ATTRIBUTE11			= X_ATTRIBUTE11,
    ATTRIBUTE12			= X_ATTRIBUTE12,
    ATTRIBUTE13			= X_ATTRIBUTE13,
    ATTRIBUTE14			= X_ATTRIBUTE14,
    ATTRIBUTE15			= X_ATTRIBUTE15,
    LAST_UPDATE_DATE 		= X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY 		= X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN 		= X_LAST_UPDATE_LOGIN
    WHERE mcd.ROWID = X_ROWID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;

procedure DELETE_ROW (
  X_ROWID in varchar2
) is
begin
  delete from mtl_consumption_definition MCD
  where mcd.ROWID = X_ROWID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

end INV_CONSUMPTION_PKG;

/
