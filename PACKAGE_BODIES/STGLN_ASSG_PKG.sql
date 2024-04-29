--------------------------------------------------------
--  DDL for Package Body STGLN_ASSG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."STGLN_ASSG_PKG" AS
/* $Header: WMSDSLNB.pls 120.1 2005/06/20 05:50:52 appldev ship $ */
procedure INSERT_ROW (
  X_ROWID 			 IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
  X_DOCK_DOOR_ID 			in NUMBER,
  X_STAGE_LANE_ID 			in NUMBER,
  X_DOCK_DOOR_ORGANIZATION_ID 		in NUMBER,
  X_STAGING_LANE_ORGANIZATION_ID 	in NUMBER,
  X_ENTRY_SEQUENCE 			in NUMBER,
  X_ENABLED 				in VARCHAR2,
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
  X_ATTRIBUTE15 			in VARCHAR2
) is
  cursor get_row is
    select ROWID from WMS_STAGINGLANES_ASSIGNMENTS
    where DOCK_DOOR_ID = X_DOCK_DOOR_ID
    and   DOCK_DOOR_ORGANIZATION_ID = X_DOCK_DOOR_ORGANIZATION_ID
    AND   STAGE_LANE_ID = X_STAGE_LANE_ID
    and   STAGING_LANE_ORGANIZATION_ID = X_STAGING_LANE_ORGANIZATION_ID
    and   ENTRY_SEQUENCE = X_ENTRY_SEQUENCE;
begin
  insert into WMS_STAGINGLANES_ASSIGNMENTS (
    DOCK_DOOR_ID,
    STAGE_LANE_ID,
    DOCK_DOOR_ORGANIZATION_ID,
    STAGING_LANE_ORGANIZATION_ID,
    ENTRY_SEQUENCE,
    ENABLED,
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
    ATTRIBUTE15)
values (
    X_DOCK_DOOR_ID,
    X_STAGE_LANE_ID,
    X_DOCK_DOOR_ORGANIZATION_ID,
    X_STAGING_LANE_ORGANIZATION_ID,
    X_ENTRY_SEQUENCE,
    X_ENABLED,
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
    X_ATTRIBUTE15
  );
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
  X_ROWID                               IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
  X_DOCK_DOOR_ID                        in NUMBER,
  X_STAGE_LANE_ID                       in NUMBER,
  X_DOCK_DOOR_ORGANIZATION_ID           in NUMBER,
  X_STAGING_LANE_ORGANIZATION_ID        in NUMBER,
  X_ENTRY_SEQUENCE                      in NUMBER,
  X_ENABLED                             in VARCHAR2,
  X_CREATION_DATE                       in DATE,
  X_CREATED_BY                          in NUMBER,
  X_LAST_UPDATE_DATE                    in DATE,
  X_LAST_UPDATED_BY                     in NUMBER,
  X_LAST_UPDATE_LOGIN                   in NUMBER,
  X_ATTRIBUTE_CATEGORY                  in VARCHAR2,
  X_ATTRIBUTE1                          in VARCHAR2,
  X_ATTRIBUTE2                          in VARCHAR2,
  X_ATTRIBUTE3                          in VARCHAR2,
  X_ATTRIBUTE4                          in VARCHAR2,
  X_ATTRIBUTE5                          in VARCHAR2,
  X_ATTRIBUTE6                          in VARCHAR2,
  X_ATTRIBUTE7                          in VARCHAR2,
  X_ATTRIBUTE8                          in VARCHAR2,
  X_ATTRIBUTE9                          in VARCHAR2,
  X_ATTRIBUTE10                         in VARCHAR2,
  X_ATTRIBUTE11                         in VARCHAR2,
  X_ATTRIBUTE12                         in VARCHAR2,
  X_ATTRIBUTE13                         in VARCHAR2,
  X_ATTRIBUTE14                         in VARCHAR2,
  X_ATTRIBUTE15                         in VARCHAR2)
is
  cursor get_lock is select
   	DOCK_DOOR_ID,
  	STAGE_LANE_ID,
  	DOCK_DOOR_ORGANIZATION_ID,
  	STAGING_LANE_ORGANIZATION_ID,
  	ENTRY_SEQUENCE,
  	ENABLED,
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
	ATTRIBUTE15
 from WMS_STAGINGLANES_ASSIGNMENTS
 where ROWID = X_ROWID
 for update of DOCK_DOOR_ID nowait;
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

if
-- check if the mandatory columns match  values in the form
     ((recinfo.DOCK_DOOR_ID = X_DOCK_DOOR_ID)
AND  (recinfo.STAGE_LANE_ID = X_STAGE_LANE_ID)
AND  (recinfo.DOCK_DOOR_ORGANIZATION_ID = X_DOCK_DOOR_ORGANIZATION_ID)
AND   (recinfo.STAGING_LANE_ORGANIZATION_ID = X_STAGING_LANE_ORGANIZATION_ID)
AND   (recinfo.ENTRY_SEQUENCE = X_ENTRY_SEQUENCE)
AND   (recinfo.ENABLED = X_ENABLED)
AND   (recinfo.CREATION_DATE = X_CREATION_DATE)
AND   (recinfo.CREATED_BY = X_CREATED_BY)
AND   (recinfo.LAST_UPDATE_DATE = X_LAST_UPDATE_DATE)
AND   (recinfo.LAST_UPDATED_BY = X_LAST_UPDATED_BY)
AND   (recinfo.LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN)
-- check if the non-mandatory columns match  values in the form
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
  X_ROWID                               IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
  X_DOCK_DOOR_ID                        in NUMBER,
  X_STAGE_LANE_ID                       in NUMBER,
  X_DOCK_DOOR_ORGANIZATION_ID           in NUMBER,
  X_STAGING_LANE_ORGANIZATION_ID        in NUMBER,
  X_ENTRY_SEQUENCE                      in NUMBER,
  X_ENABLED                             in VARCHAR2,
  X_LAST_UPDATE_DATE                    in DATE,
  X_LAST_UPDATED_BY                     in NUMBER,
  X_LAST_UPDATE_LOGIN                   in NUMBER,
  X_ATTRIBUTE_CATEGORY                  in VARCHAR2,
  X_ATTRIBUTE1                          in VARCHAR2,
  X_ATTRIBUTE2                          in VARCHAR2,
  X_ATTRIBUTE3                          in VARCHAR2,
  X_ATTRIBUTE4                          in VARCHAR2,
  X_ATTRIBUTE5                          in VARCHAR2,
  X_ATTRIBUTE6                          in VARCHAR2,
  X_ATTRIBUTE7                          in VARCHAR2,
  X_ATTRIBUTE8                          in VARCHAR2,
  X_ATTRIBUTE9                          in VARCHAR2,
  X_ATTRIBUTE10                         in VARCHAR2,
  X_ATTRIBUTE11                         in VARCHAR2,
  X_ATTRIBUTE12                         in VARCHAR2,
  X_ATTRIBUTE13                         in VARCHAR2,
  X_ATTRIBUTE14                         in VARCHAR2,
  X_ATTRIBUTE15                         in VARCHAR2)
is
begin
update WMS_STAGINGLANES_ASSIGNMENTS set
    STAGE_LANE_ID = X_STAGE_LANE_ID,
    STAGING_LANE_ORGANIZATION_ID = X_STAGING_LANE_ORGANIZATION_ID,
    ENABLED = X_ENABLED,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    ATTRIBUTE_CATEGORY  = X_ATTRIBUTE_CATEGORY,
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
    ATTRIBUTE15 = X_ATTRIBUTE15
where DOCK_DOOR_ID = X_DOCK_DOOR_ID
  and DOCK_DOOR_ORGANIZATION_ID = X_DOCK_DOOR_ORGANIZATION_ID
  and ENTRY_SEQUENCE = X_ENTRY_SEQUENCE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;

/********************************************************************************/

procedure DELETE_ROW (
  X_DOCK_DOOR_ID in NUMBER,
  X_DOCK_DOOR_ORGANIZATION_ID in NUMBER,
  X_ENTRY_SEQUENCE in NUMBER)
is
begin
  delete from WMS_STAGINGLANES_ASSIGNMENTS
  where DOCK_DOOR_ID = X_DOCK_DOOR_ID
  and   DOCK_DOOR_ORGANIZATION_ID  = X_DOCK_DOOR_ORGANIZATION_ID
  and   ENTRY_SEQUENCE = X_ENTRY_SEQUENCE;

  if (sql%notfound) then
      raise no_data_found;
  end if;

end DELETE_ROW;

/*******************************************************************************/

end STGLN_ASSG_PKG;

/
