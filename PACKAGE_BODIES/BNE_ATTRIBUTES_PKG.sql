--------------------------------------------------------
--  DDL for Package Body BNE_ATTRIBUTES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BNE_ATTRIBUTES_PKG" as
/* $Header: bneattsb.pls 120.2 2005/06/29 03:39:39 dvayro noship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_ATTRIBUTE_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
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
  X_ATTRIBUTE_NAME1 in VARCHAR2,
  X_ATTRIBUTE_NAME2 in VARCHAR2,
  X_ATTRIBUTE_NAME3 in VARCHAR2,
  X_ATTRIBUTE_NAME4 in VARCHAR2,
  X_ATTRIBUTE_NAME5 in VARCHAR2,
  X_ATTRIBUTE_NAME6 in VARCHAR2,
  X_ATTRIBUTE_NAME7 in VARCHAR2,
  X_ATTRIBUTE_NAME8 in VARCHAR2,
  X_ATTRIBUTE_NAME9 in VARCHAR2,
  X_ATTRIBUTE_NAME10 in VARCHAR2,
  X_ATTRIBUTE_NAME11 in VARCHAR2,
  X_ATTRIBUTE_NAME12 in VARCHAR2,
  X_ATTRIBUTE_NAME13 in VARCHAR2,
  X_ATTRIBUTE_NAME14 in VARCHAR2,
  X_ATTRIBUTE_NAME15 in VARCHAR2,
  X_ATTRIBUTE_NAME16 in VARCHAR2,
  X_ATTRIBUTE_NAME17 in VARCHAR2,
  X_ATTRIBUTE_NAME18 in VARCHAR2,
  X_ATTRIBUTE_NAME19 in VARCHAR2,
  X_ATTRIBUTE_NAME20 in VARCHAR2,
  X_ATTRIBUTE_NAME21 in VARCHAR2,
  X_ATTRIBUTE_NAME22 in VARCHAR2,
  X_ATTRIBUTE_NAME23 in VARCHAR2,
  X_ATTRIBUTE_NAME24 in VARCHAR2,
  X_ATTRIBUTE_NAME25 in VARCHAR2,
  X_ATTRIBUTE_NAME26 in VARCHAR2,
  X_ATTRIBUTE_NAME27 in VARCHAR2,
  X_ATTRIBUTE_NAME28 in VARCHAR2,
  X_ATTRIBUTE_NAME29 in VARCHAR2,
  X_ATTRIBUTE_NAME30 in VARCHAR2
) is
  cursor C is select ROWID from BNE_ATTRIBUTES
    where APPLICATION_ID = X_APPLICATION_ID
    and ATTRIBUTE_CODE = X_ATTRIBUTE_CODE
    ;
begin
  insert into BNE_ATTRIBUTES (
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    APPLICATION_ID,
    ATTRIBUTE_CODE,
    OBJECT_VERSION_NUMBER,
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
    ATTRIBUTE25,
    ATTRIBUTE26,
    ATTRIBUTE27,
    ATTRIBUTE28,
    ATTRIBUTE29,
    ATTRIBUTE30,
    ATTRIBUTE_NAME1,
    ATTRIBUTE_NAME2,
    ATTRIBUTE_NAME3,
    ATTRIBUTE_NAME4,
    ATTRIBUTE_NAME5,
    ATTRIBUTE_NAME6,
    ATTRIBUTE_NAME7,
    ATTRIBUTE_NAME8,
    ATTRIBUTE_NAME9,
    ATTRIBUTE_NAME10,
    ATTRIBUTE_NAME11,
    ATTRIBUTE_NAME12,
    ATTRIBUTE_NAME13,
    ATTRIBUTE_NAME14,
    ATTRIBUTE_NAME15,
    ATTRIBUTE_NAME16,
    ATTRIBUTE_NAME17,
    ATTRIBUTE_NAME18,
    ATTRIBUTE_NAME19,
    ATTRIBUTE_NAME20,
    ATTRIBUTE_NAME21,
    ATTRIBUTE_NAME22,
    ATTRIBUTE_NAME23,
    ATTRIBUTE_NAME24,
    ATTRIBUTE_NAME25,
    ATTRIBUTE_NAME26,
    ATTRIBUTE_NAME27,
    ATTRIBUTE_NAME28,
    ATTRIBUTE_NAME29,
    ATTRIBUTE_NAME30
  ) values (
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    X_CREATED_BY,
    X_APPLICATION_ID,
    X_ATTRIBUTE_CODE,
    X_OBJECT_VERSION_NUMBER,
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
    X_ATTRIBUTE25,
    X_ATTRIBUTE26,
    X_ATTRIBUTE27,
    X_ATTRIBUTE28,
    X_ATTRIBUTE29,
    X_ATTRIBUTE30,
    X_ATTRIBUTE_NAME1,
    X_ATTRIBUTE_NAME2,
    X_ATTRIBUTE_NAME3,
    X_ATTRIBUTE_NAME4,
    X_ATTRIBUTE_NAME5,
    X_ATTRIBUTE_NAME6,
    X_ATTRIBUTE_NAME7,
    X_ATTRIBUTE_NAME8,
    X_ATTRIBUTE_NAME9,
    X_ATTRIBUTE_NAME10,
    X_ATTRIBUTE_NAME11,
    X_ATTRIBUTE_NAME12,
    X_ATTRIBUTE_NAME13,
    X_ATTRIBUTE_NAME14,
    X_ATTRIBUTE_NAME15,
    X_ATTRIBUTE_NAME16,
    X_ATTRIBUTE_NAME17,
    X_ATTRIBUTE_NAME18,
    X_ATTRIBUTE_NAME19,
    X_ATTRIBUTE_NAME20,
    X_ATTRIBUTE_NAME21,
    X_ATTRIBUTE_NAME22,
    X_ATTRIBUTE_NAME23,
    X_ATTRIBUTE_NAME24,
    X_ATTRIBUTE_NAME25,
    X_ATTRIBUTE_NAME26,
    X_ATTRIBUTE_NAME27,
    X_ATTRIBUTE_NAME28,
    X_ATTRIBUTE_NAME29,
    X_ATTRIBUTE_NAME30
  );

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_APPLICATION_ID in NUMBER,
  X_ATTRIBUTE_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
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
  X_ATTRIBUTE_NAME1 in VARCHAR2,
  X_ATTRIBUTE_NAME2 in VARCHAR2,
  X_ATTRIBUTE_NAME3 in VARCHAR2,
  X_ATTRIBUTE_NAME4 in VARCHAR2,
  X_ATTRIBUTE_NAME5 in VARCHAR2,
  X_ATTRIBUTE_NAME6 in VARCHAR2,
  X_ATTRIBUTE_NAME7 in VARCHAR2,
  X_ATTRIBUTE_NAME8 in VARCHAR2,
  X_ATTRIBUTE_NAME9 in VARCHAR2,
  X_ATTRIBUTE_NAME10 in VARCHAR2,
  X_ATTRIBUTE_NAME11 in VARCHAR2,
  X_ATTRIBUTE_NAME12 in VARCHAR2,
  X_ATTRIBUTE_NAME13 in VARCHAR2,
  X_ATTRIBUTE_NAME14 in VARCHAR2,
  X_ATTRIBUTE_NAME15 in VARCHAR2,
  X_ATTRIBUTE_NAME16 in VARCHAR2,
  X_ATTRIBUTE_NAME17 in VARCHAR2,
  X_ATTRIBUTE_NAME18 in VARCHAR2,
  X_ATTRIBUTE_NAME19 in VARCHAR2,
  X_ATTRIBUTE_NAME20 in VARCHAR2,
  X_ATTRIBUTE_NAME21 in VARCHAR2,
  X_ATTRIBUTE_NAME22 in VARCHAR2,
  X_ATTRIBUTE_NAME23 in VARCHAR2,
  X_ATTRIBUTE_NAME24 in VARCHAR2,
  X_ATTRIBUTE_NAME25 in VARCHAR2,
  X_ATTRIBUTE_NAME26 in VARCHAR2,
  X_ATTRIBUTE_NAME27 in VARCHAR2,
  X_ATTRIBUTE_NAME28 in VARCHAR2,
  X_ATTRIBUTE_NAME29 in VARCHAR2,
  X_ATTRIBUTE_NAME30 in VARCHAR2
) is
  cursor c1 is select
      OBJECT_VERSION_NUMBER,
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
      ATTRIBUTE25,
      ATTRIBUTE26,
      ATTRIBUTE27,
      ATTRIBUTE28,
      ATTRIBUTE29,
      ATTRIBUTE30,
      ATTRIBUTE_NAME1,
      ATTRIBUTE_NAME2,
      ATTRIBUTE_NAME3,
      ATTRIBUTE_NAME4,
      ATTRIBUTE_NAME5,
      ATTRIBUTE_NAME6,
      ATTRIBUTE_NAME7,
      ATTRIBUTE_NAME8,
      ATTRIBUTE_NAME9,
      ATTRIBUTE_NAME10,
      ATTRIBUTE_NAME11,
      ATTRIBUTE_NAME12,
      ATTRIBUTE_NAME13,
      ATTRIBUTE_NAME14,
      ATTRIBUTE_NAME15,
      ATTRIBUTE_NAME16,
      ATTRIBUTE_NAME17,
      ATTRIBUTE_NAME18,
      ATTRIBUTE_NAME19,
      ATTRIBUTE_NAME20,
      ATTRIBUTE_NAME21,
      ATTRIBUTE_NAME22,
      ATTRIBUTE_NAME23,
      ATTRIBUTE_NAME24,
      ATTRIBUTE_NAME25,
      ATTRIBUTE_NAME26,
      ATTRIBUTE_NAME27,
      ATTRIBUTE_NAME28,
      ATTRIBUTE_NAME29,
      ATTRIBUTE_NAME30
    from BNE_ATTRIBUTES
    where APPLICATION_ID = X_APPLICATION_ID
    and ATTRIBUTE_CODE = X_ATTRIBUTE_CODE
    for update of APPLICATION_ID nowait;
begin
  for tlinfo in c1 loop
      if (    (tlinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
          AND ((tlinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
               OR ((tlinfo.ATTRIBUTE1 is null) AND (X_ATTRIBUTE1 is null)))
          AND ((tlinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
               OR ((tlinfo.ATTRIBUTE2 is null) AND (X_ATTRIBUTE2 is null)))
          AND ((tlinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
               OR ((tlinfo.ATTRIBUTE3 is null) AND (X_ATTRIBUTE3 is null)))
          AND ((tlinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
               OR ((tlinfo.ATTRIBUTE4 is null) AND (X_ATTRIBUTE4 is null)))
          AND ((tlinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
               OR ((tlinfo.ATTRIBUTE5 is null) AND (X_ATTRIBUTE5 is null)))
          AND ((tlinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
               OR ((tlinfo.ATTRIBUTE6 is null) AND (X_ATTRIBUTE6 is null)))
          AND ((tlinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
               OR ((tlinfo.ATTRIBUTE7 is null) AND (X_ATTRIBUTE7 is null)))
          AND ((tlinfo.ATTRIBUTE8 = X_ATTRIBUTE8)
               OR ((tlinfo.ATTRIBUTE8 is null) AND (X_ATTRIBUTE8 is null)))
          AND ((tlinfo.ATTRIBUTE9 = X_ATTRIBUTE9)
               OR ((tlinfo.ATTRIBUTE9 is null) AND (X_ATTRIBUTE9 is null)))
          AND ((tlinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
               OR ((tlinfo.ATTRIBUTE10 is null) AND (X_ATTRIBUTE10 is null)))
          AND ((tlinfo.ATTRIBUTE11 = X_ATTRIBUTE11)
               OR ((tlinfo.ATTRIBUTE11 is null) AND (X_ATTRIBUTE11 is null)))
          AND ((tlinfo.ATTRIBUTE12 = X_ATTRIBUTE12)
               OR ((tlinfo.ATTRIBUTE12 is null) AND (X_ATTRIBUTE12 is null)))
          AND ((tlinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
               OR ((tlinfo.ATTRIBUTE13 is null) AND (X_ATTRIBUTE13 is null)))
          AND ((tlinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
               OR ((tlinfo.ATTRIBUTE14 is null) AND (X_ATTRIBUTE14 is null)))
          AND ((tlinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
               OR ((tlinfo.ATTRIBUTE15 is null) AND (X_ATTRIBUTE15 is null)))
          AND ((tlinfo.ATTRIBUTE16 = X_ATTRIBUTE16)
               OR ((tlinfo.ATTRIBUTE16 is null) AND (X_ATTRIBUTE16 is null)))
          AND ((tlinfo.ATTRIBUTE17 = X_ATTRIBUTE17)
               OR ((tlinfo.ATTRIBUTE17 is null) AND (X_ATTRIBUTE17 is null)))
          AND ((tlinfo.ATTRIBUTE18 = X_ATTRIBUTE18)
               OR ((tlinfo.ATTRIBUTE18 is null) AND (X_ATTRIBUTE18 is null)))
          AND ((tlinfo.ATTRIBUTE19 = X_ATTRIBUTE19)
               OR ((tlinfo.ATTRIBUTE19 is null) AND (X_ATTRIBUTE19 is null)))
          AND ((tlinfo.ATTRIBUTE20 = X_ATTRIBUTE20)
               OR ((tlinfo.ATTRIBUTE20 is null) AND (X_ATTRIBUTE20 is null)))
          AND ((tlinfo.ATTRIBUTE21 = X_ATTRIBUTE21)
               OR ((tlinfo.ATTRIBUTE21 is null) AND (X_ATTRIBUTE21 is null)))
          AND ((tlinfo.ATTRIBUTE22 = X_ATTRIBUTE22)
               OR ((tlinfo.ATTRIBUTE22 is null) AND (X_ATTRIBUTE22 is null)))
          AND ((tlinfo.ATTRIBUTE23 = X_ATTRIBUTE23)
               OR ((tlinfo.ATTRIBUTE23 is null) AND (X_ATTRIBUTE23 is null)))
          AND ((tlinfo.ATTRIBUTE24 = X_ATTRIBUTE24)
               OR ((tlinfo.ATTRIBUTE24 is null) AND (X_ATTRIBUTE24 is null)))
          AND ((tlinfo.ATTRIBUTE25 = X_ATTRIBUTE25)
               OR ((tlinfo.ATTRIBUTE25 is null) AND (X_ATTRIBUTE25 is null)))
          AND ((tlinfo.ATTRIBUTE26 = X_ATTRIBUTE26)
               OR ((tlinfo.ATTRIBUTE26 is null) AND (X_ATTRIBUTE26 is null)))
          AND ((tlinfo.ATTRIBUTE27 = X_ATTRIBUTE27)
               OR ((tlinfo.ATTRIBUTE27 is null) AND (X_ATTRIBUTE27 is null)))
          AND ((tlinfo.ATTRIBUTE28 = X_ATTRIBUTE28)
               OR ((tlinfo.ATTRIBUTE28 is null) AND (X_ATTRIBUTE28 is null)))
          AND ((tlinfo.ATTRIBUTE29 = X_ATTRIBUTE29)
               OR ((tlinfo.ATTRIBUTE29 is null) AND (X_ATTRIBUTE29 is null)))
          AND ((tlinfo.ATTRIBUTE30 = X_ATTRIBUTE30)
               OR ((tlinfo.ATTRIBUTE30 is null) AND (X_ATTRIBUTE30 is null)))
          AND ((tlinfo.ATTRIBUTE_NAME1 = X_ATTRIBUTE_NAME1)
               OR ((tlinfo.ATTRIBUTE_NAME1 is null) AND (X_ATTRIBUTE_NAME1 is null)))
          AND ((tlinfo.ATTRIBUTE_NAME2 = X_ATTRIBUTE_NAME2)
               OR ((tlinfo.ATTRIBUTE_NAME2 is null) AND (X_ATTRIBUTE_NAME2 is null)))
          AND ((tlinfo.ATTRIBUTE_NAME3 = X_ATTRIBUTE_NAME3)
               OR ((tlinfo.ATTRIBUTE_NAME3 is null) AND (X_ATTRIBUTE_NAME3 is null)))
          AND ((tlinfo.ATTRIBUTE_NAME4 = X_ATTRIBUTE_NAME4)
               OR ((tlinfo.ATTRIBUTE_NAME4 is null) AND (X_ATTRIBUTE_NAME4 is null)))
          AND ((tlinfo.ATTRIBUTE_NAME5 = X_ATTRIBUTE_NAME5)
               OR ((tlinfo.ATTRIBUTE_NAME5 is null) AND (X_ATTRIBUTE_NAME5 is null)))
          AND ((tlinfo.ATTRIBUTE_NAME6 = X_ATTRIBUTE_NAME6)
               OR ((tlinfo.ATTRIBUTE_NAME6 is null) AND (X_ATTRIBUTE_NAME6 is null)))
          AND ((tlinfo.ATTRIBUTE_NAME7 = X_ATTRIBUTE_NAME7)
               OR ((tlinfo.ATTRIBUTE_NAME7 is null) AND (X_ATTRIBUTE_NAME7 is null)))
          AND ((tlinfo.ATTRIBUTE_NAME8 = X_ATTRIBUTE_NAME8)
               OR ((tlinfo.ATTRIBUTE_NAME8 is null) AND (X_ATTRIBUTE_NAME8 is null)))
          AND ((tlinfo.ATTRIBUTE_NAME9 = X_ATTRIBUTE_NAME9)
               OR ((tlinfo.ATTRIBUTE_NAME9 is null) AND (X_ATTRIBUTE_NAME9 is null)))
          AND ((tlinfo.ATTRIBUTE_NAME10 = X_ATTRIBUTE_NAME10)
               OR ((tlinfo.ATTRIBUTE_NAME10 is null) AND (X_ATTRIBUTE_NAME10 is null)))
          AND ((tlinfo.ATTRIBUTE_NAME11 = X_ATTRIBUTE_NAME11)
               OR ((tlinfo.ATTRIBUTE_NAME11 is null) AND (X_ATTRIBUTE_NAME11 is null)))
          AND ((tlinfo.ATTRIBUTE_NAME12 = X_ATTRIBUTE_NAME12)
               OR ((tlinfo.ATTRIBUTE_NAME12 is null) AND (X_ATTRIBUTE_NAME12 is null)))
          AND ((tlinfo.ATTRIBUTE_NAME13 = X_ATTRIBUTE_NAME13)
               OR ((tlinfo.ATTRIBUTE_NAME13 is null) AND (X_ATTRIBUTE_NAME13 is null)))
          AND ((tlinfo.ATTRIBUTE_NAME14 = X_ATTRIBUTE_NAME14)
               OR ((tlinfo.ATTRIBUTE_NAME14 is null) AND (X_ATTRIBUTE_NAME14 is null)))
          AND ((tlinfo.ATTRIBUTE_NAME15 = X_ATTRIBUTE_NAME15)
               OR ((tlinfo.ATTRIBUTE_NAME15 is null) AND (X_ATTRIBUTE_NAME15 is null)))
          AND ((tlinfo.ATTRIBUTE_NAME16 = X_ATTRIBUTE_NAME16)
               OR ((tlinfo.ATTRIBUTE_NAME16 is null) AND (X_ATTRIBUTE_NAME16 is null)))
          AND ((tlinfo.ATTRIBUTE_NAME17 = X_ATTRIBUTE_NAME17)
               OR ((tlinfo.ATTRIBUTE_NAME17 is null) AND (X_ATTRIBUTE_NAME17 is null)))
          AND ((tlinfo.ATTRIBUTE_NAME18 = X_ATTRIBUTE_NAME18)
               OR ((tlinfo.ATTRIBUTE_NAME18 is null) AND (X_ATTRIBUTE_NAME18 is null)))
          AND ((tlinfo.ATTRIBUTE_NAME19 = X_ATTRIBUTE_NAME19)
               OR ((tlinfo.ATTRIBUTE_NAME19 is null) AND (X_ATTRIBUTE_NAME19 is null)))
          AND ((tlinfo.ATTRIBUTE_NAME20 = X_ATTRIBUTE_NAME20)
               OR ((tlinfo.ATTRIBUTE_NAME20 is null) AND (X_ATTRIBUTE_NAME20 is null)))
          AND ((tlinfo.ATTRIBUTE_NAME21 = X_ATTRIBUTE_NAME21)
               OR ((tlinfo.ATTRIBUTE_NAME21 is null) AND (X_ATTRIBUTE_NAME21 is null)))
          AND ((tlinfo.ATTRIBUTE_NAME22 = X_ATTRIBUTE_NAME22)
               OR ((tlinfo.ATTRIBUTE_NAME22 is null) AND (X_ATTRIBUTE_NAME22 is null)))
          AND ((tlinfo.ATTRIBUTE_NAME23 = X_ATTRIBUTE_NAME23)
               OR ((tlinfo.ATTRIBUTE_NAME23 is null) AND (X_ATTRIBUTE_NAME23 is null)))
          AND ((tlinfo.ATTRIBUTE_NAME24 = X_ATTRIBUTE_NAME24)
               OR ((tlinfo.ATTRIBUTE_NAME24 is null) AND (X_ATTRIBUTE_NAME24 is null)))
          AND ((tlinfo.ATTRIBUTE_NAME25 = X_ATTRIBUTE_NAME25)
               OR ((tlinfo.ATTRIBUTE_NAME25 is null) AND (X_ATTRIBUTE_NAME25 is null)))
          AND ((tlinfo.ATTRIBUTE_NAME26 = X_ATTRIBUTE_NAME26)
               OR ((tlinfo.ATTRIBUTE_NAME26 is null) AND (X_ATTRIBUTE_NAME26 is null)))
          AND ((tlinfo.ATTRIBUTE_NAME27 = X_ATTRIBUTE_NAME27)
               OR ((tlinfo.ATTRIBUTE_NAME27 is null) AND (X_ATTRIBUTE_NAME27 is null)))
          AND ((tlinfo.ATTRIBUTE_NAME28 = X_ATTRIBUTE_NAME28)
               OR ((tlinfo.ATTRIBUTE_NAME28 is null) AND (X_ATTRIBUTE_NAME28 is null)))
          AND ((tlinfo.ATTRIBUTE_NAME29 = X_ATTRIBUTE_NAME29)
               OR ((tlinfo.ATTRIBUTE_NAME29 is null) AND (X_ATTRIBUTE_NAME29 is null)))
          AND ((tlinfo.ATTRIBUTE_NAME30 = X_ATTRIBUTE_NAME30)
               OR ((tlinfo.ATTRIBUTE_NAME30 is null) AND (X_ATTRIBUTE_NAME30 is null)))
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
  end loop;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_ATTRIBUTE_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
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
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_ATTRIBUTE_NAME1 in VARCHAR2,
  X_ATTRIBUTE_NAME2 in VARCHAR2,
  X_ATTRIBUTE_NAME3 in VARCHAR2,
  X_ATTRIBUTE_NAME4 in VARCHAR2,
  X_ATTRIBUTE_NAME5 in VARCHAR2,
  X_ATTRIBUTE_NAME6 in VARCHAR2,
  X_ATTRIBUTE_NAME7 in VARCHAR2,
  X_ATTRIBUTE_NAME8 in VARCHAR2,
  X_ATTRIBUTE_NAME9 in VARCHAR2,
  X_ATTRIBUTE_NAME10 in VARCHAR2,
  X_ATTRIBUTE_NAME11 in VARCHAR2,
  X_ATTRIBUTE_NAME12 in VARCHAR2,
  X_ATTRIBUTE_NAME13 in VARCHAR2,
  X_ATTRIBUTE_NAME14 in VARCHAR2,
  X_ATTRIBUTE_NAME15 in VARCHAR2,
  X_ATTRIBUTE_NAME16 in VARCHAR2,
  X_ATTRIBUTE_NAME17 in VARCHAR2,
  X_ATTRIBUTE_NAME18 in VARCHAR2,
  X_ATTRIBUTE_NAME19 in VARCHAR2,
  X_ATTRIBUTE_NAME20 in VARCHAR2,
  X_ATTRIBUTE_NAME21 in VARCHAR2,
  X_ATTRIBUTE_NAME22 in VARCHAR2,
  X_ATTRIBUTE_NAME23 in VARCHAR2,
  X_ATTRIBUTE_NAME24 in VARCHAR2,
  X_ATTRIBUTE_NAME25 in VARCHAR2,
  X_ATTRIBUTE_NAME26 in VARCHAR2,
  X_ATTRIBUTE_NAME27 in VARCHAR2,
  X_ATTRIBUTE_NAME28 in VARCHAR2,
  X_ATTRIBUTE_NAME29 in VARCHAR2,
  X_ATTRIBUTE_NAME30 in VARCHAR2
) is
begin
  update BNE_ATTRIBUTES set
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
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
    ATTRIBUTE25 = X_ATTRIBUTE25,
    ATTRIBUTE26 = X_ATTRIBUTE26,
    ATTRIBUTE27 = X_ATTRIBUTE27,
    ATTRIBUTE28 = X_ATTRIBUTE28,
    ATTRIBUTE29 = X_ATTRIBUTE29,
    ATTRIBUTE30 = X_ATTRIBUTE30,
    ATTRIBUTE_NAME1 = X_ATTRIBUTE_NAME1,
    ATTRIBUTE_NAME2 = X_ATTRIBUTE_NAME2,
    ATTRIBUTE_NAME3 = X_ATTRIBUTE_NAME3,
    ATTRIBUTE_NAME4 = X_ATTRIBUTE_NAME4,
    ATTRIBUTE_NAME5 = X_ATTRIBUTE_NAME5,
    ATTRIBUTE_NAME6 = X_ATTRIBUTE_NAME6,
    ATTRIBUTE_NAME7 = X_ATTRIBUTE_NAME7,
    ATTRIBUTE_NAME8 = X_ATTRIBUTE_NAME8,
    ATTRIBUTE_NAME9 = X_ATTRIBUTE_NAME9,
    ATTRIBUTE_NAME10 = X_ATTRIBUTE_NAME10,
    ATTRIBUTE_NAME11 = X_ATTRIBUTE_NAME11,
    ATTRIBUTE_NAME12 = X_ATTRIBUTE_NAME12,
    ATTRIBUTE_NAME13 = X_ATTRIBUTE_NAME13,
    ATTRIBUTE_NAME14 = X_ATTRIBUTE_NAME14,
    ATTRIBUTE_NAME15 = X_ATTRIBUTE_NAME15,
    ATTRIBUTE_NAME16 = X_ATTRIBUTE_NAME16,
    ATTRIBUTE_NAME17 = X_ATTRIBUTE_NAME17,
    ATTRIBUTE_NAME18 = X_ATTRIBUTE_NAME18,
    ATTRIBUTE_NAME19 = X_ATTRIBUTE_NAME19,
    ATTRIBUTE_NAME20 = X_ATTRIBUTE_NAME20,
    ATTRIBUTE_NAME21 = X_ATTRIBUTE_NAME21,
    ATTRIBUTE_NAME22 = X_ATTRIBUTE_NAME22,
    ATTRIBUTE_NAME23 = X_ATTRIBUTE_NAME23,
    ATTRIBUTE_NAME24 = X_ATTRIBUTE_NAME24,
    ATTRIBUTE_NAME25 = X_ATTRIBUTE_NAME25,
    ATTRIBUTE_NAME26 = X_ATTRIBUTE_NAME26,
    ATTRIBUTE_NAME27 = X_ATTRIBUTE_NAME27,
    ATTRIBUTE_NAME28 = X_ATTRIBUTE_NAME28,
    ATTRIBUTE_NAME29 = X_ATTRIBUTE_NAME29,
    ATTRIBUTE_NAME30 = X_ATTRIBUTE_NAME30,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where APPLICATION_ID = X_APPLICATION_ID
  and ATTRIBUTE_CODE = X_ATTRIBUTE_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_ATTRIBUTE_CODE in VARCHAR2
) is
begin
  delete from BNE_ATTRIBUTES
  where APPLICATION_ID = X_APPLICATION_ID
  and ATTRIBUTE_CODE = X_ATTRIBUTE_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  null;
end ADD_LANGUAGE;

--------------------------------------------------------------------------------
--  PROCEDURE:     LOAD_ROW                                                   --
--                                                                            --
--  DESCRIPTION:   Load a row into the BNE_ATTRIBUTES entity.                 --
--                 This proc is called from the apps loader.                  --
--                                                                            --
--  SEE:     http://www-apps.us.oracle.com/atg/plans/r115/fndloadqr.txt --
--                        --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date       Username  Description                                          --
--  1-Oct-02   DGROVES   CREATED                                              --
--------------------------------------------------------------------------------


procedure LOAD_ROW(
  x_attribute_asn         IN VARCHAR2,
  x_attribute_code        IN VARCHAR2,
  x_object_version_number IN VARCHAR2,
  x_attribute1            IN VARCHAR2,
  x_attribute2            IN VARCHAR2,
  x_attribute3            IN VARCHAR2,
  x_attribute4            IN VARCHAR2,
  x_attribute5            IN VARCHAR2,
  x_attribute6            IN VARCHAR2,
  x_attribute7            IN VARCHAR2,
  x_attribute8            IN VARCHAR2,
  x_attribute9            IN VARCHAR2,
  x_attribute10           IN VARCHAR2,
  x_attribute11           IN VARCHAR2,
  x_attribute12           IN VARCHAR2,
  x_attribute13           IN VARCHAR2,
  x_attribute14           IN VARCHAR2,
  x_attribute15           IN VARCHAR2,
  x_attribute16           IN VARCHAR2,
  x_attribute17           IN VARCHAR2,
  x_attribute18           IN VARCHAR2,
  x_attribute19           IN VARCHAR2,
  x_attribute20           IN VARCHAR2,
  x_attribute21           IN VARCHAR2,
  x_attribute22           IN VARCHAR2,
  x_attribute23           IN VARCHAR2,
  x_attribute24           IN VARCHAR2,
  x_attribute25           IN VARCHAR2,
  x_attribute26           IN VARCHAR2,
  x_attribute27           IN VARCHAR2,
  x_attribute28           IN VARCHAR2,
  x_attribute29           IN VARCHAR2,
  x_attribute30           IN VARCHAR2,
  x_owner                 IN VARCHAR2,
  x_last_update_date      IN VARCHAR2,
  x_custom_mode           IN VARCHAR2,
  X_ATTRIBUTE_NAME1       in VARCHAR2,
  X_ATTRIBUTE_NAME2       in VARCHAR2,
  X_ATTRIBUTE_NAME3       in VARCHAR2,
  X_ATTRIBUTE_NAME4       in VARCHAR2,
  X_ATTRIBUTE_NAME5       in VARCHAR2,
  X_ATTRIBUTE_NAME6       in VARCHAR2,
  X_ATTRIBUTE_NAME7       in VARCHAR2,
  X_ATTRIBUTE_NAME8       in VARCHAR2,
  X_ATTRIBUTE_NAME9       in VARCHAR2,
  X_ATTRIBUTE_NAME10      in VARCHAR2,
  X_ATTRIBUTE_NAME11      in VARCHAR2,
  X_ATTRIBUTE_NAME12      in VARCHAR2,
  X_ATTRIBUTE_NAME13      in VARCHAR2,
  X_ATTRIBUTE_NAME14      in VARCHAR2,
  X_ATTRIBUTE_NAME15      in VARCHAR2,
  X_ATTRIBUTE_NAME16      in VARCHAR2,
  X_ATTRIBUTE_NAME17      in VARCHAR2,
  X_ATTRIBUTE_NAME18      in VARCHAR2,
  X_ATTRIBUTE_NAME19      in VARCHAR2,
  X_ATTRIBUTE_NAME20      in VARCHAR2,
  X_ATTRIBUTE_NAME21      in VARCHAR2,
  X_ATTRIBUTE_NAME22      in VARCHAR2,
  X_ATTRIBUTE_NAME23      in VARCHAR2,
  X_ATTRIBUTE_NAME24      in VARCHAR2,
  X_ATTRIBUTE_NAME25      in VARCHAR2,
  X_ATTRIBUTE_NAME26      in VARCHAR2,
  X_ATTRIBUTE_NAME27      in VARCHAR2,
  X_ATTRIBUTE_NAME28      in VARCHAR2,
  X_ATTRIBUTE_NAME29      in VARCHAR2,
  X_ATTRIBUTE_NAME30      in VARCHAR2
)
is
  l_app_id          number;
  l_row_id          varchar2(64);
  f_luby            number;  -- entity owner in file
  f_ludate          date;    -- entity update date in file
  db_luby           number;  -- entity owner in db
  db_ludate         date;    -- entity update date in db
begin
  -- translate values to IDs
  l_app_id       := BNE_LCT_TOOLS_PKG.ASN_TO_APP_ID(x_attribute_asn);

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);
  begin
    select LAST_UPDATED_BY, LAST_UPDATE_DATE
    into db_luby, db_ludate
    from BNE_ATTRIBUTES
    where APPLICATION_ID = l_app_id
    and   ATTRIBUTE_CODE = x_attribute_code;

    -- Test for customization and version
    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, x_custom_mode)) then
      -- Update existing row

      BNE_ATTRIBUTES_PKG.Update_Row(
        X_APPLICATION_ID        => l_app_id,
        X_ATTRIBUTE_CODE        => x_attribute_code,
        X_OBJECT_VERSION_NUMBER => x_object_version_number,
        X_ATTRIBUTE1            => x_attribute1,
        X_ATTRIBUTE2            => x_attribute2,
        X_ATTRIBUTE3            => x_attribute3,
        X_ATTRIBUTE4            => x_attribute4,
        X_ATTRIBUTE5            => x_attribute5,
        X_ATTRIBUTE6            => x_attribute6,
        X_ATTRIBUTE7            => x_attribute7,
        X_ATTRIBUTE8            => x_attribute8,
        X_ATTRIBUTE9            => x_attribute9,
        X_ATTRIBUTE10           => x_attribute10,
        X_ATTRIBUTE11           => x_attribute11,
        X_ATTRIBUTE12           => x_attribute12,
        X_ATTRIBUTE13           => x_attribute13,
        X_ATTRIBUTE14           => x_attribute14,
        X_ATTRIBUTE15           => x_attribute15,
        X_ATTRIBUTE16           => x_attribute16,
        X_ATTRIBUTE17           => x_attribute17,
        X_ATTRIBUTE18           => x_attribute18,
        X_ATTRIBUTE19           => x_attribute19,
        X_ATTRIBUTE20           => x_attribute20,
        X_ATTRIBUTE21           => x_attribute21,
        X_ATTRIBUTE22           => x_attribute22,
        X_ATTRIBUTE23           => x_attribute23,
        X_ATTRIBUTE24           => x_attribute24,
        X_ATTRIBUTE25           => x_attribute25,
        X_ATTRIBUTE26           => x_attribute26,
        X_ATTRIBUTE27           => x_attribute27,
        X_ATTRIBUTE28           => x_attribute28,
        X_ATTRIBUTE29           => x_attribute29,
        X_ATTRIBUTE30           => x_attribute30,
        X_ATTRIBUTE_NAME1       => x_attribute_name1,
        X_ATTRIBUTE_NAME2       => x_attribute_name2,
        X_ATTRIBUTE_NAME3       => x_attribute_name3,
        X_ATTRIBUTE_NAME4       => x_attribute_name4,
        X_ATTRIBUTE_NAME5       => x_attribute_name5,
        X_ATTRIBUTE_NAME6       => x_attribute_name6,
        X_ATTRIBUTE_NAME7       => x_attribute_name7,
        X_ATTRIBUTE_NAME8       => x_attribute_name8,
        X_ATTRIBUTE_NAME9       => x_attribute_name9,
        X_ATTRIBUTE_NAME10      => x_attribute_name10,
        X_ATTRIBUTE_NAME11      => x_attribute_name11,
        X_ATTRIBUTE_NAME12      => x_attribute_name12,
        X_ATTRIBUTE_NAME13      => x_attribute_name13,
        X_ATTRIBUTE_NAME14      => x_attribute_name14,
        X_ATTRIBUTE_NAME15      => x_attribute_name15,
        X_ATTRIBUTE_NAME16      => x_attribute_name16,
        X_ATTRIBUTE_NAME17      => x_attribute_name17,
        X_ATTRIBUTE_NAME18      => x_attribute_name18,
        X_ATTRIBUTE_NAME19      => x_attribute_name19,
        X_ATTRIBUTE_NAME20      => x_attribute_name20,
        X_ATTRIBUTE_NAME21      => x_attribute_name21,
        X_ATTRIBUTE_NAME22      => x_attribute_name22,
        X_ATTRIBUTE_NAME23      => x_attribute_name23,
        X_ATTRIBUTE_NAME24      => x_attribute_name24,
        X_ATTRIBUTE_NAME25      => x_attribute_name25,
        X_ATTRIBUTE_NAME26      => x_attribute_name26,
        X_ATTRIBUTE_NAME27      => x_attribute_name27,
        X_ATTRIBUTE_NAME28      => x_attribute_name28,
        X_ATTRIBUTE_NAME29      => x_attribute_name29,
        X_ATTRIBUTE_NAME30      => x_attribute_name30,
        X_LAST_UPDATE_DATE      => f_ludate,
        X_LAST_UPDATED_BY       => f_luby,
        X_LAST_UPDATE_LOGIN     => 0
      );
    end if;
  exception
    when no_data_found then
      -- Record doesn't exist - insert in all cases
      BNE_ATTRIBUTES_PKG.Insert_Row(
        X_ROWID                 => l_row_id,
        X_APPLICATION_ID        => l_app_id,
        X_ATTRIBUTE_CODE        => x_attribute_code,
        X_OBJECT_VERSION_NUMBER => x_object_version_number,
        X_ATTRIBUTE1            => x_attribute1,
        X_ATTRIBUTE2            => x_attribute2,
        X_ATTRIBUTE3            => x_attribute3,
        X_ATTRIBUTE4            => x_attribute4,
        X_ATTRIBUTE5            => x_attribute5,
        X_ATTRIBUTE6            => x_attribute6,
        X_ATTRIBUTE7            => x_attribute7,
        X_ATTRIBUTE8            => x_attribute8,
        X_ATTRIBUTE9            => x_attribute9,
        X_ATTRIBUTE10           => x_attribute10,
        X_ATTRIBUTE11           => x_attribute11,
        X_ATTRIBUTE12           => x_attribute12,
        X_ATTRIBUTE13           => x_attribute13,
        X_ATTRIBUTE14           => x_attribute14,
        X_ATTRIBUTE15           => x_attribute15,
        X_ATTRIBUTE16           => x_attribute16,
        X_ATTRIBUTE17           => x_attribute17,
        X_ATTRIBUTE18           => x_attribute18,
        X_ATTRIBUTE19           => x_attribute19,
        X_ATTRIBUTE20           => x_attribute20,
        X_ATTRIBUTE21           => x_attribute21,
        X_ATTRIBUTE22           => x_attribute22,
        X_ATTRIBUTE23           => x_attribute23,
        X_ATTRIBUTE24           => x_attribute24,
        X_ATTRIBUTE25           => x_attribute25,
        X_ATTRIBUTE26           => x_attribute26,
        X_ATTRIBUTE27           => x_attribute27,
        X_ATTRIBUTE28           => x_attribute28,
        X_ATTRIBUTE29           => x_attribute29,
        X_ATTRIBUTE30           => x_attribute30,
        X_ATTRIBUTE_NAME1       => x_attribute_name1,
        X_ATTRIBUTE_NAME2       => x_attribute_name2,
        X_ATTRIBUTE_NAME3       => x_attribute_name3,
        X_ATTRIBUTE_NAME4       => x_attribute_name4,
        X_ATTRIBUTE_NAME5       => x_attribute_name5,
        X_ATTRIBUTE_NAME6       => x_attribute_name6,
        X_ATTRIBUTE_NAME7       => x_attribute_name7,
        X_ATTRIBUTE_NAME8       => x_attribute_name8,
        X_ATTRIBUTE_NAME9       => x_attribute_name9,
        X_ATTRIBUTE_NAME10      => x_attribute_name10,
        X_ATTRIBUTE_NAME11      => x_attribute_name11,
        X_ATTRIBUTE_NAME12      => x_attribute_name12,
        X_ATTRIBUTE_NAME13      => x_attribute_name13,
        X_ATTRIBUTE_NAME14      => x_attribute_name14,
        X_ATTRIBUTE_NAME15      => x_attribute_name15,
        X_ATTRIBUTE_NAME16      => x_attribute_name16,
        X_ATTRIBUTE_NAME17      => x_attribute_name17,
        X_ATTRIBUTE_NAME18      => x_attribute_name18,
        X_ATTRIBUTE_NAME19      => x_attribute_name19,
        X_ATTRIBUTE_NAME20      => x_attribute_name20,
        X_ATTRIBUTE_NAME21      => x_attribute_name21,
        X_ATTRIBUTE_NAME22      => x_attribute_name22,
        X_ATTRIBUTE_NAME23      => x_attribute_name23,
        X_ATTRIBUTE_NAME24      => x_attribute_name24,
        X_ATTRIBUTE_NAME25      => x_attribute_name25,
        X_ATTRIBUTE_NAME26      => x_attribute_name26,
        X_ATTRIBUTE_NAME27      => x_attribute_name27,
        X_ATTRIBUTE_NAME28      => x_attribute_name28,
        X_ATTRIBUTE_NAME29      => x_attribute_name29,
        X_ATTRIBUTE_NAME30      => x_attribute_name30,
        X_CREATION_DATE         => f_ludate,
        X_CREATED_BY            => f_luby,
        X_LAST_UPDATE_DATE      => f_ludate,
        X_LAST_UPDATED_BY       => f_luby,
        X_LAST_UPDATE_LOGIN     => 0
      );
  end;
end LOAD_ROW;

end BNE_ATTRIBUTES_PKG;

/
