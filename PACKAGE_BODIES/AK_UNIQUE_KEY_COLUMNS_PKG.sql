--------------------------------------------------------
--  DDL for Package Body AK_UNIQUE_KEY_COLUMNS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AK_UNIQUE_KEY_COLUMNS_PKG" as
/* $Header: AKDUKCB.pls 115.5 2002/01/17 12:31:12 pkm ship      $ */
--######################################################################
procedure INSERT_ROW (
  X_UNIQUE_KEY_NAME in VARCHAR2,
  X_UNIQUE_KEY_SEQUENCE in NUMBER,
  X_ATTRIBUTE_APPLICATION_ID in NUMBER,
  X_ATTRIBUTE_CODE in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
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
  X_ATTRIBUTE15 in VARCHAR2)
is
begin
  insert into AK_UNIQUE_KEY_COLUMNS (
    UNIQUE_KEY_NAME,
    UNIQUE_KEY_SEQUENCE,
    ATTRIBUTE_APPLICATION_ID,
    ATTRIBUTE_CODE,
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
    X_UNIQUE_KEY_NAME,
    X_UNIQUE_KEY_SEQUENCE,
    X_ATTRIBUTE_APPLICATION_ID,
    X_ATTRIBUTE_CODE,
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
    X_ATTRIBUTE15);
end INSERT_ROW;
--######################################################################
--I-O is based on the unique key columns
--        UNIQUE_KEY_NAME and UNIQUE_KEY_SEQUENCE,
--        which are NOT the Primary Key.
procedure LOCK_ROW (
  X_UNIQUE_KEY_NAME in VARCHAR2,
  X_UNIQUE_KEY_SEQUENCE in NUMBER,
  X_ATTRIBUTE_APPLICATION_ID in NUMBER,
  X_ATTRIBUTE_CODE in VARCHAR2,
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
  X_ATTRIBUTE15 in VARCHAR2)
is
  cursor c is select
      ATTRIBUTE_CODE,
      ATTRIBUTE_APPLICATION_ID,
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
    from AK_UNIQUE_KEY_COLUMNS
    where UNIQUE_KEY_NAME = X_UNIQUE_KEY_NAME
    and UNIQUE_KEY_SEQUENCE = X_UNIQUE_KEY_SEQUENCE
    for update of UNIQUE_KEY_NAME nowait;
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
      if ( (recinfo.ATTRIBUTE_CODE = X_ATTRIBUTE_CODE)
      AND  (recinfo.ATTRIBUTE_APPLICATION_ID = X_ATTRIBUTE_APPLICATION_ID)
      AND ((recinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
           OR ((recinfo.ATTRIBUTE_CATEGORY is null)
               AND (X_ATTRIBUTE_CATEGORY is null)))
      AND ((recinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
           OR ((recinfo.ATTRIBUTE1 is null)
               AND (X_ATTRIBUTE1 is null)))
      AND ((recinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
           OR ((recinfo.ATTRIBUTE2 is null)
               AND (X_ATTRIBUTE2 is null)))
      AND ((recinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
           OR ((recinfo.ATTRIBUTE3 is null)
               AND (X_ATTRIBUTE3 is null)))
      AND ((recinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
           OR ((recinfo.ATTRIBUTE4 is null)
               AND (X_ATTRIBUTE4 is null)))
      AND ((recinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
           OR ((recinfo.ATTRIBUTE5 is null)
               AND (X_ATTRIBUTE5 is null)))
      AND ((recinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
           OR ((recinfo.ATTRIBUTE6 is null)
               AND (X_ATTRIBUTE6 is null)))
      AND ((recinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
           OR ((recinfo.ATTRIBUTE7 is null)
               AND (X_ATTRIBUTE7 is null)))
      AND ((recinfo.ATTRIBUTE8 = X_ATTRIBUTE8)
           OR ((recinfo.ATTRIBUTE8 is null)
               AND (X_ATTRIBUTE8 is null)))
      AND ((recinfo.ATTRIBUTE9 = X_ATTRIBUTE9)
           OR ((recinfo.ATTRIBUTE9 is null)
               AND (X_ATTRIBUTE9 is null)))
      AND ((recinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
           OR ((recinfo.ATTRIBUTE10 is null)
               AND (X_ATTRIBUTE10 is null)))
      AND ((recinfo.ATTRIBUTE11 = X_ATTRIBUTE11)
           OR ((recinfo.ATTRIBUTE11 is null)
               AND (X_ATTRIBUTE11 is null)))
      AND ((recinfo.ATTRIBUTE12 = X_ATTRIBUTE12)
           OR ((recinfo.ATTRIBUTE12 is null)
               AND (X_ATTRIBUTE12 is null)))
      AND ((recinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
           OR ((recinfo.ATTRIBUTE13 is null)
               AND (X_ATTRIBUTE13 is null)))
      AND ((recinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
           OR ((recinfo.ATTRIBUTE14 is null)
               AND (X_ATTRIBUTE14 is null)))
      AND ((recinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
           OR ((recinfo.ATTRIBUTE15 is null)
               AND (X_ATTRIBUTE15 is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;
--######################################################################
--I-O is based on the unique key columns
--        UNIQUE_KEY_NAME and UNIQUE_KEY_SEQUENCE,
--        which are NOT the Primary Key.
procedure UPDATE_ROW (
  X_UNIQUE_KEY_NAME in VARCHAR2,
  X_UNIQUE_KEY_SEQUENCE in NUMBER,
  X_ATTRIBUTE_APPLICATION_ID in NUMBER,
  X_ATTRIBUTE_CODE in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
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
begin
    update AK_UNIQUE_KEY_COLUMNS set
      UNIQUE_KEY_NAME = X_UNIQUE_KEY_NAME,
      UNIQUE_KEY_SEQUENCE = X_UNIQUE_KEY_SEQUENCE,
      ATTRIBUTE_APPLICATION_ID = X_ATTRIBUTE_APPLICATION_ID,
      ATTRIBUTE_CODE = X_ATTRIBUTE_CODE,
      LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
      LAST_UPDATED_BY = X_LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
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
      ATTRIBUTE15 = X_ATTRIBUTE15
    where UNIQUE_KEY_NAME = X_UNIQUE_KEY_NAME
    and UNIQUE_KEY_SEQUENCE = X_UNIQUE_KEY_SEQUENCE;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;
--######################################################################
--I-O is based on the unique key columns
--        UNIQUE_KEY_NAME and UNIQUE_KEY_SEQUENCE,
--        which are NOT the Primary Key.
procedure DELETE_ROW (
  X_UNIQUE_KEY_NAME in VARCHAR2,
  X_UNIQUE_KEY_SEQUENCE in NUMBER,
  X_ATTRIBUTE_APPLICATION_ID in NUMBER,
  X_ATTRIBUTE_CODE in VARCHAR2) is
begin
  delete from AK_UNIQUE_KEY_COLUMNS
  where UNIQUE_KEY_NAME = X_UNIQUE_KEY_NAME
  and UNIQUE_KEY_SEQUENCE = X_UNIQUE_KEY_SEQUENCE;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;
--######################################################################
end AK_UNIQUE_KEY_COLUMNS_PKG;

/
