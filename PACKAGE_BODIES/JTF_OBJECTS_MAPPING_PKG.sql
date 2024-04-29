--------------------------------------------------------
--  DDL for Package Body JTF_OBJECTS_MAPPING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_OBJECTS_MAPPING_PKG" as
/* $Header: jtfobmab.pls 120.2 2008/01/07 11:08:28 ipananil ship $ */
procedure INSERT_ROW(
  X_ROWID in out NOCOPY VARCHAR2,
  X_MAPPING_ID in NUMBER,
  X_APPLICATION_ID  in NUMBER,
  X_SOURCE_OBJECT_CODE  in VARCHAR2,
  X_OBJECT_CODE in VARCHAR2,
  X_OBJECT_ID in VARCHAR2,
  X_END_DATE  in DATE 	,
  X_SEEDED_FLAG in VARCHAR2,
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
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER ) is
  cursor C is select ROWID from JTF_OBJECT_MAPPINGS
    where MAPPING_ID = X_MAPPING_ID
    ;
begin
  insert into JTF_OBJECT_MAPPINGS(
        MAPPING_ID,
 	APPLICATION_ID  ,
 	SOURCE_OBJECT_CODE  ,
 	OBJECT_CODE ,
        OBJECT_ID ,
 	END_DATE   	,
 	SEEDED_FLAG	,
 	ATTRIBUTE1	,
 	ATTRIBUTE2	,
 	ATTRIBUTE3	,
 	ATTRIBUTE4	,
 	ATTRIBUTE5	,
 	ATTRIBUTE6	,
 	ATTRIBUTE7	,
 	ATTRIBUTE8	,
 	ATTRIBUTE9	,
 	ATTRIBUTE10	,
 	ATTRIBUTE11	,
 	ATTRIBUTE12	,
 	ATTRIBUTE13	,
 	ATTRIBUTE14	,
 	ATTRIBUTE15	,
 	ATTRIBUTE_CATEGORY,
 	CREATION_DATE 	,
 	CREATED_BY  	,
 	LAST_UPDATE_DATE ,
 	LAST_UPDATED_BY ,
 	LAST_UPDATE_LOGIN ,
 	OBJECT_VERSION_NUMBER
  ) values (
    X_MAPPING_ID,
    X_APPLICATION_ID  ,
    X_SOURCE_OBJECT_CODE  ,
    X_OBJECT_CODE ,
    X_OBJECT_ID ,
    X_END_DATE   	,
    X_SEEDED_FLAG	,
    X_ATTRIBUTE1	,
    X_ATTRIBUTE2	,
    X_ATTRIBUTE3	,
    X_ATTRIBUTE4	,
    X_ATTRIBUTE5	,
    X_ATTRIBUTE6	,
    X_ATTRIBUTE7	,
    X_ATTRIBUTE8	,
    X_ATTRIBUTE9	,
    X_ATTRIBUTE10	,
    X_ATTRIBUTE11	,
    X_ATTRIBUTE12	,
    X_ATTRIBUTE13	,
    X_ATTRIBUTE14	,
    X_ATTRIBUTE15	,
    X_ATTRIBUTE_CATEGORY,
    X_CREATION_DATE	,
    X_CREATED_BY	,
    X_LAST_UPDATE_DATE	,
    X_LAST_UPDATED_BY	,
    1			,
    1
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
  X_MAPPING_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER
) is
  cursor c is select
        OBJECT_VERSION_NUMBER
    from JTF_OBJECT_MAPPINGS_V
    where MAPPING_ID = X_MAPPING_ID
    and OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER
    for update of MAPPING_ID nowait;
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

  if (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
  then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

end LOCK_ROW;


procedure UPDATE_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_MAPPING_ID in NUMBER,
  X_APPLICATION_ID  in NUMBER,
  X_SOURCE_OBJECT_CODE  in VARCHAR2,
  X_OBJECT_CODE in VARCHAR2,
  X_OBJECT_ID in VARCHAR2,
  X_END_DATE  in DATE 	,
  X_SEEDED_FLAG in VARCHAR2,
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
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER)
 is
begin
  update JTF_OBJECT_MAPPINGS set
    APPLICATION_ID = X_APPLICATION_ID ,
    SOURCE_OBJECT_CODE  = X_SOURCE_OBJECT_CODE,
    OBJECT_CODE = X_OBJECT_CODE,
    OBJECT_ID=X_OBJECT_ID ,
    END_DATE  = X_END_DATE ,
    SEEDED_FLAG = X_SEEDED_FLAG,
    OBJECT_VERSION_NUMBER =  X_OBJECT_VERSION_NUMBER +1,
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
    ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where MAPPING_ID = X_MAPPING_ID ;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_MAPPING_ID in NUMBER
) is
begin
  delete from JTF_OBJECT_MAPPINGS
  where MAPPING_ID = X_MAPPING_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
 end DELETE_ROW;
end JTF_OBJECTS_MAPPING_PKG;

/