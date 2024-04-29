--------------------------------------------------------
--  DDL for Package Body BEVENT_DEVICE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEVENT_DEVICE_PKG" AS
/* $Header: WMSDEVBB.pls 120.0 2005/05/25 09:00:00 appldev noship $ */
procedure INSERT_ROW (
  X_ROWID 			         IN OUT NOCOPY VARCHAR2,
  X_BUSINESS_EVENT_ID  			in NUMBER,
  X_DEVICE_ID	 			in NUMBER,
  X_LEVEL_TYPE		 		in NUMBER,
  X_LEVEL_VALUE			 	in NUMBER,
  X_ORGANIZATION_ID 			in NUMBER,
  X_SUBINVENTORY_CODE			in VARCHAR2,
  X_AUTO_ENABLED_FLAG                   in VARCHAR2,
  X_COMMENTS                            in VARCHAR2,
  X_ENABLED_FLAG                        in VARCHAR2,
  X_CREATION_DATE 			in DATE,
  X_CREATED_BY 				in NUMBER,
  X_LAST_UPDATE_DATE 			in DATE,
  X_LAST_UPDATED_BY 			in NUMBER,
  X_LAST_UPDATE_LOGIN 			in NUMBER,
  X_ATTRIBUTE_CATEGORY 			in VARCHAR2,
  X_ATTRIBUTE1 				in VARCHAR2,
  X_ATTRIBUTE2 				in VARCHAR2,
  X_ATTRIBUTE3 				in VARCHAR2,
  X_ATTRIBUTE4 				in VARCHAR2,
  X_ATTRIBUTE5 				in VARCHAR2,
  X_ATTRIBUTE6 				in VARCHAR2,
  X_ATTRIBUTE7 				in VARCHAR2,
  X_ATTRIBUTE8 				in VARCHAR2,
  X_ATTRIBUTE9 				in VARCHAR2,
  X_ATTRIBUTE10 			in VARCHAR2,
  X_ATTRIBUTE11 			in VARCHAR2,
  X_ATTRIBUTE12 			in VARCHAR2,
  X_ATTRIBUTE13 			in VARCHAR2,
  X_ATTRIBUTE14 			in VARCHAR2,
  X_ATTRIBUTE15 			in VARCHAR2,
  x_verification_required               IN VARCHAR2
) is
  cursor get_row is
    select ROWID
    from  wms_bus_event_devices
    where BUSINESS_EVENT_ID 	= X_BUSINESS_EVENT_ID
    and   DEVICE_ID 		= X_DEVICE_ID
    and   LEVEL_VALUE 		= X_LEVEL_VALUE
    and   ORGANIZATION_ID 	= X_ORGANIZATION_ID;
begin
  insert into wms_bus_event_devices (
    BUSINESS_EVENT_ID,
    DEVICE_ID,
    LEVEL_TYPE,
    LEVEL_VALUE,
    ORGANIZATION_ID,
    SUBINVENTORY_CODE,
    AUTO_ENABLED_FLAG,
    COMMENTS,
    ENABLED_FLAG,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
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
    attribute15,
    VERIFICATION_REQUIRED)
values (
    X_BUSINESS_EVENT_ID,
    X_DEVICE_ID,
    X_LEVEL_TYPE,
    X_LEVEL_VALUE,
    X_ORGANIZATION_ID,
    X_SUBINVENTORY_CODE,
    X_AUTO_ENABLED_FLAG,
    X_COMMENTS,
    X_ENABLED_FLAG,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
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
    x_attribute15,
    X_VERIFICATION_REQUIRED );
  open get_row;
  fetch get_row into X_ROWID;
  if (get_row%notfound) then
    close get_row;
    raise no_data_found;
  end if;
  close get_row;

end insert_row;

/*****************************************************************/

procedure LOCK_ROW (
  X_ROWID 			        IN OUT NOCOPY VARCHAR2,
  X_BUSINESS_EVENT_ID  			in NUMBER,
  X_DEVICE_ID	 			in NUMBER,
  X_LEVEL_TYPE		 		in NUMBER,
  X_LEVEL_VALUE			 	in NUMBER,
  X_ORGANIZATION_ID 			in NUMBER,
  X_SUBINVENTORY_CODE			in VARCHAR2,
  X_AUTO_ENABLED_FLAG                   in VARCHAR2,
  X_COMMENTS                            in VARCHAR2,
  X_ENABLED_FLAG                        in VARCHAR2,
  X_ATTRIBUTE_CATEGORY 			in VARCHAR2,
  X_ATTRIBUTE1 				in VARCHAR2,
  X_ATTRIBUTE2 				in VARCHAR2,
  X_ATTRIBUTE3 				in VARCHAR2,
  X_ATTRIBUTE4 				in VARCHAR2,
  X_ATTRIBUTE5 				in VARCHAR2,
  X_ATTRIBUTE6 				in VARCHAR2,
  X_ATTRIBUTE7 				in VARCHAR2,
  X_ATTRIBUTE8 				in VARCHAR2,
  X_ATTRIBUTE9 				in VARCHAR2,
  X_ATTRIBUTE10 			in VARCHAR2,
  X_ATTRIBUTE11 			in VARCHAR2,
  X_ATTRIBUTE12 			in VARCHAR2,
  X_ATTRIBUTE13 			in VARCHAR2,
  X_ATTRIBUTE14 			in VARCHAR2,
  X_ATTRIBUTE15 			in VARCHAR2,
  x_verification_required               IN VARCHAR2
  )
  is
  cursor get_lock is
  select
   	BUSINESS_EVENT_ID,
  	DEVICE_ID,
  	LEVEL_TYPE,
  	LEVEL_VALUE,
  	ORGANIZATION_ID,
  	SUBINVENTORY_CODE,
  	AUTO_ENABLED_FLAG,
  	COMMENTS,
  	ENABLED_FLAG,
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
        attribute15,
        VERIFICATION_REQUIRED
 from wms_bus_event_devices
 where ROWID = X_ROWID
 for update of DEVICE_ID nowait;
 recinfo get_lock%rowtype;

begin
  open get_lock;
  fetch get_lock into recinfo;
  if (get_lock%notfound) then
    close get_lock;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close get_lock;

if   ((recinfo.BUSINESS_EVENT_ID 	= X_BUSINESS_EVENT_ID)
AND   (recinfo.DEVICE_ID 		= X_DEVICE_ID)
AND   (recinfo.ENABLED_FLAG 		= X_ENABLED_FLAG)
AND   (recinfo.LEVEL_TYPE 		= X_LEVEL_TYPE)

AND  ((recinfo.LEVEL_VALUE 	        = X_LEVEL_VALUE)
OR   ((recinfo.LEVEL_VALUE is null) AND (X_LEVEL_VALUE is null)))
AND  ((recinfo.ORGANIZATION_ID	        = X_ORGANIZATION_ID)
OR   ((recinfo.ORGANIZATION_ID is null) AND (X_ORGANIZATION_ID is null)))
AND ((recinfo.SUBINVENTORY_CODE 	= X_SUBINVENTORY_CODE)
OR ((recinfo.SUBINVENTORY_CODE is null) AND (X_SUBINVENTORY_CODE is null)))
AND ((recinfo.AUTO_ENABLED_FLAG 	= X_AUTO_ENABLED_FLAG)
OR ((recinfo.AUTO_ENABLED_FLAG is null) AND (X_AUTO_ENABLED_FLAG is null)))
AND ((recinfo.VERIFICATION_REQUIRED 	= X_VERIFICATION_REQUIRED)
OR ((recinfo.VERIFICATION_REQUIRED is null) AND (X_VERIFICATION_REQUIRED is null)))
AND ((recinfo.COMMENTS = X_COMMENTS)
OR ((recinfo.COMMENTS is null) AND (X_COMMENTS is null)))
AND ((recinfo.attribute_category = X_attribute_category)
OR ((recinfo.attribute_category is null) AND (X_attribute_category is null)))
AND ((recinfo.attribute1 = X_attribute1)
OR ((recinfo.attribute1 is null)  AND (X_attribute1 is null)))
AND ((recinfo.attribute2 = X_attribute2)
OR ((recinfo.attribute2 is null)  AND (X_attribute2 is null)))
AND ((recinfo.attribute3 = X_attribute3)
OR ((recinfo.attribute3 is null)  AND (X_attribute3 is null)))
AND ((recinfo.attribute4 = X_attribute4)
OR ((recinfo.attribute4 is null)  AND (X_attribute4 is null)))
AND ((recinfo.attribute5 = X_attribute5)
OR ((recinfo.attribute5 is null)  AND (X_attribute5 is null)))
AND ((recinfo.attribute6 = X_attribute6)
OR ((recinfo.attribute6 is null)  AND (X_attribute6 is null)))
AND ((recinfo.attribute7 = X_attribute7)
OR ((recinfo.attribute7 is null)  AND (X_attribute7 is null)))
AND ((recinfo.attribute8 = X_attribute8)
OR ((recinfo.attribute8 is null)  AND (X_attribute8 is null)))
AND ((recinfo.attribute9 = X_attribute9)
OR ((recinfo.attribute9 is null)  AND (X_attribute9 is null)))
AND ((recinfo.attribute10 = X_attribute10)
OR ((recinfo.attribute10 is null) AND (X_attribute10 is null)))
AND ((recinfo.attribute11 = X_attribute11)
OR ((recinfo.attribute11 is null) AND (X_attribute11 is null)))
AND ((recinfo.attribute12 = X_attribute12)
OR ((recinfo.attribute12 is null) AND (X_attribute12 is null)))
AND ((recinfo.attribute13 = X_attribute13)
OR ((recinfo.attribute13 is null) AND (X_attribute13 is null)))
AND ((recinfo.attribute14 = X_attribute14)
OR ((recinfo.attribute14 is null) AND (X_attribute14 is null)))
AND ((recinfo.attribute15 = X_attribute15)
OR ((recinfo.attribute15 is null) AND (X_attribute15 is null)))
 )
then
return;
else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
end if;

end LOCK_ROW;

/*******************************************************************************/

procedure UPDATE_ROW (
  X_BUSINESS_EVENT_ID  			in NUMBER,
  X_DEVICE_ID	 			in NUMBER,
  X_LEVEL_TYPE		 		in NUMBER,
  X_LEVEL_VALUE			 	in NUMBER,
  X_ORGANIZATION_ID 			in NUMBER,
  X_SUBINVENTORY_CODE			in VARCHAR2,
  X_AUTO_ENABLED_FLAG                   in VARCHAR2,
  X_COMMENTS                            in VARCHAR2,
  X_ENABLED_FLAG                        in VARCHAR2,
  X_LAST_UPDATE_DATE 			in DATE,
  X_LAST_UPDATED_BY 			in NUMBER,
  X_LAST_UPDATE_LOGIN 			in NUMBER,
  X_ATTRIBUTE_CATEGORY 			in VARCHAR2,
  X_ATTRIBUTE1 				in VARCHAR2,
  X_ATTRIBUTE2 				in VARCHAR2,
  X_ATTRIBUTE3 				in VARCHAR2,
  X_ATTRIBUTE4 				in VARCHAR2,
  X_ATTRIBUTE5 				in VARCHAR2,
  X_ATTRIBUTE6 				in VARCHAR2,
  X_ATTRIBUTE7 				in VARCHAR2,
  X_ATTRIBUTE8 				in VARCHAR2,
  X_ATTRIBUTE9 				in VARCHAR2,
  X_ATTRIBUTE10 			in VARCHAR2,
  X_ATTRIBUTE11 			in VARCHAR2,
  X_ATTRIBUTE12 			in VARCHAR2,
  X_ATTRIBUTE13 			in VARCHAR2,
  X_ATTRIBUTE14 			in VARCHAR2,
  X_ATTRIBUTE15 			in VARCHAR2,
  x_verification_required               IN VARCHAR2
) is
begin
update wms_bus_event_devices
set
  LEVEL_TYPE		= X_LEVEL_TYPE,
  LEVEL_VALUE		= X_LEVEL_VALUE,
  ORGANIZATION_ID 	= X_ORGANIZATION_ID,
  SUBINVENTORY_CODE	= X_SUBINVENTORY_CODE,
  AUTO_ENABLED_FLAG     = X_AUTO_ENABLED_FLAG,
  COMMENTS              = X_COMMENTS,
  ENABLED_FLAG          = X_ENABLED_FLAG,
  LAST_UPDATE_DATE 	= X_LAST_UPDATE_DATE,
  LAST_UPDATED_BY 	= X_LAST_UPDATED_BY,
  LAST_UPDATE_LOGIN 	= X_LAST_UPDATE_LOGIN,
  ATTRIBUTE_CATEGORY 	= X_ATTRIBUTE_CATEGORY,
  ATTRIBUTE1 		= X_ATTRIBUTE1,
  ATTRIBUTE2 		= X_ATTRIBUTE2,
  ATTRIBUTE3 		= X_ATTRIBUTE3,
  ATTRIBUTE4 		= X_ATTRIBUTE4,
  ATTRIBUTE5 		= X_ATTRIBUTE5,
  ATTRIBUTE6 		= X_ATTRIBUTE6,
  ATTRIBUTE7 		= X_ATTRIBUTE7,
  ATTRIBUTE8 		= X_ATTRIBUTE8,
  ATTRIBUTE9 		= X_ATTRIBUTE9,
  ATTRIBUTE10 		= X_ATTRIBUTE10,
  ATTRIBUTE11 		= X_ATTRIBUTE11,
  ATTRIBUTE12 		= X_ATTRIBUTE12,
  ATTRIBUTE13 		= X_ATTRIBUTE13,
  ATTRIBUTE14 		= X_ATTRIBUTE14,
  ATTRIBUTE15 		= x_attribute15,
  verification_required = x_VERIFICATION_REQUIRED
where BUSINESS_EVENT_ID = X_BUSINESS_EVENT_ID
  and DEVICE_ID 	= X_DEVICE_ID
  and ORGANIZATION_ID 	= X_ORGANIZATION_ID;
--  and LEVEL_TYPE	= X_LEVEL_TYPE;
  -- and LEVEL_VALUE	= nvl(X_LEVEL_VALUE, LEVEL_VALUE)
  -- and SUBINVENTORY_CODE = nvl(X_SUBINVENTORY_CODE, SUBINVENTORY_CODE);

  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;

/********************************************************************************/

procedure DELETE_ROW (
  X_BUSINESS_EVENT_ID 			in NUMBER,
  X_DEVICE_ID 				in NUMBER,
  X_ORGANIZATION_ID 			in NUMBER,
  X_LEVEL_TYPE				in number,
  X_LEVEL_VALUE				in number,
  X_SUBINVENTORY_CODE			in varchar)
is
begin
  delete from wms_bus_event_devices
  where BUSINESS_EVENT_ID 		= X_BUSINESS_EVENT_ID
  and DEVICE_ID 			= X_DEVICE_ID
  and ORGANIZATION_ID 			= X_ORGANIZATION_ID
  and LEVEL_TYPE			= X_LEVEL_TYPE
  and LEVEL_VALUE			= X_LEVEL_VALUE
  and nvl(SUBINVENTORY_CODE,'aaa') 	= nvl(X_SUBINVENTORY_CODE,'aaa');


  if (sql%notfound) then
      raise no_data_found;
  end if;

end DELETE_ROW;

/*******************************************************************************/

end BEVENT_DEVICE_PKG;

/
