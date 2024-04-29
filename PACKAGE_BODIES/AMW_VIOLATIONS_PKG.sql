--------------------------------------------------------
--  DDL for Package Body AMW_VIOLATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMW_VIOLATIONS_PKG" AS
/* $Header: amwtvlab.pls 120.1 2005/06/23 11:39:23 appldev noship $ */

-- ===============================================================
-- Package name
--          AMW_VIOLATIONS_PKG
-- Purpose
--
-- History
-- 		  	11/11/2003    tsho     Creates
--          05/20/2005    tsho     AMW.E add reval_request_id,reval_request_date, reval_requested_by_id
-- ===============================================================



-- ===============================================================
-- Procedure name
--          INSERT_ROW
-- Purpose
-- 		  	create new violation
--          in AMW_VIOLATIONS
-- History
--          05.20.2005 tsho: AMW.E add reval_request_id,reval_request_date, reval_requested_by_id
-- ===============================================================
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_VIOLATION_ID in NUMBER,
  X_CONSTRAINT_REV_ID in NUMBER,
  X_REQUEST_ID in NUMBER,
  X_REQUEST_DATE in DATE,
  X_REQUESTED_BY_ID in NUMBER,
  X_VIOLATOR_NUM in NUMBER,
  X_STATUS_CODE in VARCHAR2,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_CREATION_DATE in DATE,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2      := NULL,
  X_ATTRIBUTE1 in VARCHAR2              := NULL,
  X_ATTRIBUTE2 in VARCHAR2              := NULL,
  X_ATTRIBUTE3 in VARCHAR2              := NULL,
  X_ATTRIBUTE4 in VARCHAR2              := NULL,
  X_ATTRIBUTE5 in VARCHAR2              := NULL,
  X_ATTRIBUTE6 in VARCHAR2              := NULL,
  X_ATTRIBUTE7 in VARCHAR2              := NULL,
  X_ATTRIBUTE8 in VARCHAR2              := NULL,
  X_ATTRIBUTE9 in VARCHAR2              := NULL,
  X_ATTRIBUTE10 in VARCHAR2             := NULL,
  X_ATTRIBUTE11 in VARCHAR2             := NULL,
  X_ATTRIBUTE12 in VARCHAR2             := NULL,
  X_ATTRIBUTE13 in VARCHAR2             := NULL,
  X_ATTRIBUTE14 in VARCHAR2             := NULL,
  X_ATTRIBUTE15 in VARCHAR2             := NULL,
  X_REVAL_REQUEST_ID         in NUMBER  := NULL,
  X_REVAL_REQUEST_DATE       in DATE    := NULL,
  X_REVAL_REQUESTED_BY_ID    in NUMBER  := NULL
) is
  cursor C is select ROWID from AMW_VIOLATIONS
    where VIOLATION_ID = X_VIOLATION_ID
    ;
begin
  insert into AMW_VIOLATIONS (
  VIOLATION_ID,
  CONSTRAINT_REV_ID,
  REQUEST_ID,
  REQUEST_DATE,
  REQUESTED_BY_ID,
  VIOLATOR_NUM,
  STATUS_CODE,
  LAST_UPDATED_BY,
  LAST_UPDATE_DATE,
  CREATED_BY,
  CREATION_DATE,
  LAST_UPDATE_LOGIN,
  SECURITY_GROUP_ID,
  OBJECT_VERSION_NUMBER,
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
  REVAL_REQUEST_ID,
  REVAL_REQUEST_DATE,
  REVAL_REQUESTED_BY_ID
  ) values (
  X_VIOLATION_ID,
  X_CONSTRAINT_REV_ID,
  X_REQUEST_ID,
  X_REQUEST_DATE,
  X_REQUESTED_BY_ID,
  X_VIOLATOR_NUM,
  X_STATUS_CODE,
  X_LAST_UPDATED_BY,
  X_LAST_UPDATE_DATE,
  X_CREATED_BY,
  X_CREATION_DATE,
  X_LAST_UPDATE_LOGIN,
  X_SECURITY_GROUP_ID,
  X_OBJECT_VERSION_NUMBER,
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
  X_REVAL_REQUEST_ID,
  X_REVAL_REQUEST_DATE,
  X_REVAL_REQUESTED_BY_ID
  );

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;



-- ===============================================================
-- Procedure name
--          LOCK_ROW
-- Purpose
--
-- ===============================================================
procedure LOCK_ROW (
  X_VIOLATION_ID in NUMBER,
  X_CONSTRAINT_REV_ID in NUMBER,
  X_REQUEST_ID in NUMBER,
  X_REQUEST_DATE in DATE,
  X_REQUESTED_BY_ID in NUMBER,
  X_VIOLATOR_NUM in NUMBER,
  X_STATUS_CODE in VARCHAR2,
  X_SECURITY_GROUP_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
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
  X_REVAL_REQUEST_ID         in NUMBER  := NULL,
  X_REVAL_REQUEST_DATE       in DATE    := NULL,
  X_REVAL_REQUESTED_BY_ID    in NUMBER  := NULL
) is
  cursor c is select
    CONSTRAINT_REV_ID,
    REQUEST_ID,
    REQUEST_DATE,
    REQUESTED_BY_ID,
    VIOLATOR_NUM,
    STATUS_CODE,
    SECURITY_GROUP_ID,
    OBJECT_VERSION_NUMBER,
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
    REVAL_REQUEST_ID,
    REVAL_REQUEST_DATE,
    REVAL_REQUESTED_BY_ID
    from AMW_VIOLATIONS
    where VIOLATION_ID = X_VIOLATION_ID
    for update of VIOLATION_ID nowait;
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
  if (
          ((recinfo.CONSTRAINT_REV_ID = X_CONSTRAINT_REV_ID)
           OR ((recinfo.CONSTRAINT_REV_ID is null) AND (X_CONSTRAINT_REV_ID is null)))
      AND ((recinfo.REQUEST_ID = X_REQUEST_ID)
           OR ((recinfo.REQUEST_ID is null) AND (X_REQUEST_ID is null)))
      AND ((recinfo.REQUEST_DATE = X_REQUEST_DATE)
           OR ((recinfo.REQUEST_DATE is null) AND (X_REQUEST_DATE is null)))
      AND ((recinfo.REQUESTED_BY_ID = X_REQUESTED_BY_ID)
           OR ((recinfo.REQUESTED_BY_ID is null) AND (X_REQUESTED_BY_ID is null)))
      AND ((recinfo.VIOLATOR_NUM = X_VIOLATOR_NUM)
           OR ((recinfo.VIOLATOR_NUM is null) AND (X_VIOLATOR_NUM is null)))
      AND ((recinfo.STATUS_CODE = X_STATUS_CODE)
           OR ((recinfo.STATUS_CODE is null) AND (X_STATUS_CODE is null)))
      AND ((recinfo.SECURITY_GROUP_ID = X_SECURITY_GROUP_ID)
           OR ((recinfo.SECURITY_GROUP_ID is null) AND (X_SECURITY_GROUP_ID is null)))
      AND ((recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
           OR ((recinfo.OBJECT_VERSION_NUMBER is null) AND (X_OBJECT_VERSION_NUMBER is null)))
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
      AND ((recinfo.REVAL_REQUEST_ID = X_REVAL_REQUEST_ID)
           OR ((recinfo.REVAL_REQUEST_ID is null) AND (X_REVAL_REQUEST_ID is null)))
      AND ((recinfo.REVAL_REQUEST_DATE = X_REVAL_REQUEST_DATE)
           OR ((recinfo.REVAL_REQUEST_DATE is null) AND (X_REVAL_REQUEST_DATE is null)))
      AND ((recinfo.REVAL_REQUESTED_BY_ID = X_REVAL_REQUESTED_BY_ID)
           OR ((recinfo.REVAL_REQUESTED_BY_ID is null) AND (X_REVAL_REQUESTED_BY_ID is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  return;
end LOCK_ROW;



-- ===============================================================
-- Procedure name
--          UPDATE_ROW
-- Purpose
-- 		  	update AMW_VIOLATIONS
-- History
--          05.20.2005 tsho: AMW.E add reval_request_id,reval_request_date, reval_requested_by_id
-- ===============================================================
procedure UPDATE_ROW (
  X_VIOLATION_ID in NUMBER,
  X_CONSTRAINT_REV_ID in NUMBER,
  X_VIOLATOR_NUM in NUMBER,
  X_STATUS_CODE in VARCHAR2,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2      := NULL,
  X_ATTRIBUTE1 in VARCHAR2              := NULL,
  X_ATTRIBUTE2 in VARCHAR2              := NULL,
  X_ATTRIBUTE3 in VARCHAR2              := NULL,
  X_ATTRIBUTE4 in VARCHAR2              := NULL,
  X_ATTRIBUTE5 in VARCHAR2              := NULL,
  X_ATTRIBUTE6 in VARCHAR2              := NULL,
  X_ATTRIBUTE7 in VARCHAR2              := NULL,
  X_ATTRIBUTE8 in VARCHAR2              := NULL,
  X_ATTRIBUTE9 in VARCHAR2              := NULL,
  X_ATTRIBUTE10 in VARCHAR2             := NULL,
  X_ATTRIBUTE11 in VARCHAR2             := NULL,
  X_ATTRIBUTE12 in VARCHAR2             := NULL,
  X_ATTRIBUTE13 in VARCHAR2             := NULL,
  X_ATTRIBUTE14 in VARCHAR2             := NULL,
  X_ATTRIBUTE15 in VARCHAR2             := NULL,
  X_REVAL_REQUEST_ID         in NUMBER  := NULL,
  X_REVAL_REQUEST_DATE       in DATE    := NULL,
  X_REVAL_REQUESTED_BY_ID    in NUMBER  := NULL
) is
begin
  update AMW_VIOLATIONS set
    CONSTRAINT_REV_ID = X_CONSTRAINT_REV_ID,
    VIOLATOR_NUM = X_VIOLATOR_NUM,
    STATUS_CODE = X_STATUS_CODE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SECURITY_GROUP_ID = X_SECURITY_GROUP_ID,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
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
    REVAL_REQUEST_ID      = X_REVAL_REQUEST_ID,
    REVAL_REQUEST_DATE    = X_REVAL_REQUEST_DATE,
    REVAL_REQUESTED_BY_ID = X_REVAL_REQUESTED_BY_ID
  where VIOLATION_ID = X_VIOLATION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;


end UPDATE_ROW;


-- ===============================================================
-- Procedure name
--          DELETE_ROW
-- Purpose
--
-- ===============================================================
procedure DELETE_ROW (
  X_VIOLATION_ID in NUMBER
) is
begin
  delete from AMW_VIOLATIONS
  where VIOLATION_ID = X_VIOLATION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;




-- ----------------------------------------------------------------------
end AMW_VIOLATIONS_PKG;


/
