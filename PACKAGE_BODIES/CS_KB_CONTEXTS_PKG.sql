--------------------------------------------------------
--  DDL for Package Body CS_KB_CONTEXTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_KB_CONTEXTS_PKG" as
/* $Header: cskbconb.pls 120.3 2006/04/28 11:35:28 mkettle noship $ */
/*=======================================================================+
 |  Copyright (c) 1997 Oracle Corporation Redwood Shores, California, USA|
 |                            All rights reserved.                       |
 +=======================================================================+
 | FILENAME
 | DESCRIPTION
 |   PL/SQL body for package:  CS_KB_CONTEXTS_PKG
 |
 |   History:
 |   04 Apr 05 Matt Kettle   Created
 |   05 Aug 05 Matt Kettle   Added Load_Seed_Row
 *=======================================================================*/

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_CONTEXT_ID in NUMBER,
  X_CONTEXT_TYPE in VARCHAR2,
  X_CONTEXT_VALUE in NUMBER,
  X_CONTEXT_VALUE2 in NUMBER,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
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
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from CS_KB_CONTEXTS
    where CONTEXT_ID = X_CONTEXT_ID;
begin
  insert into CS_KB_CONTEXTS (
    CONTEXT_ID,
    CONTEXT_TYPE,
    CONTEXT_VALUE,
    CONTEXT_VALUE2,
    START_DATE_ACTIVE,
    END_DATE_ACTIVE,
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
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_CONTEXT_ID,
    X_CONTEXT_TYPE,
    X_CONTEXT_VALUE,
    X_CONTEXT_VALUE2,
    X_START_DATE_ACTIVE,
    X_END_DATE_ACTIVE,
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
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
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
  X_CONTEXT_ID in NUMBER,
  X_CONTEXT_TYPE in VARCHAR2,
  X_CONTEXT_VALUE in NUMBER,
  X_CONTEXT_VALUE2 in NUMBER,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
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
  X_ATTRIBUTE15 in VARCHAR2
) is
  cursor c is select
      CONTEXT_TYPE,
      CONTEXT_VALUE,
      CONTEXT_VALUE2,
      START_DATE_ACTIVE,
      END_DATE_ACTIVE,
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
      ATTRIBUTE15
    from CS_KB_CONTEXTS
    where CONTEXT_ID = X_CONTEXT_ID
    for update of CONTEXT_ID nowait;

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
  if (    (recinfo.CONTEXT_TYPE = X_CONTEXT_TYPE)
      AND (recinfo.CONTEXT_VALUE = X_CONTEXT_VALUE)
      AND ((recinfo.CONTEXT_VALUE2 = X_CONTEXT_VALUE2)
           OR ((recinfo.CONTEXT_VALUE2 is null) AND (X_CONTEXT_VALUE2 is null)))
      AND ((recinfo.START_DATE_ACTIVE = X_START_DATE_ACTIVE)
           OR ((recinfo.START_DATE_ACTIVE is null) AND (X_START_DATE_ACTIVE is null)))
      AND ((recinfo.END_DATE_ACTIVE = X_END_DATE_ACTIVE)
           OR ((recinfo.END_DATE_ACTIVE is null) AND (X_END_DATE_ACTIVE is null)))
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
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  return;

end LOCK_ROW;

procedure UPDATE_ROW (
  X_CONTEXT_ID in NUMBER,
  X_CONTEXT_TYPE in VARCHAR2,
  X_CONTEXT_VALUE in NUMBER,
  X_CONTEXT_VALUE2 in NUMBER,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
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
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update CS_KB_CONTEXTS set
    CONTEXT_TYPE = X_CONTEXT_TYPE,
    CONTEXT_VALUE = X_CONTEXT_VALUE,
    CONTEXT_VALUE2 = X_CONTEXT_VALUE2,
    START_DATE_ACTIVE = X_START_DATE_ACTIVE,
    END_DATE_ACTIVE = X_END_DATE_ACTIVE,
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
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where CONTEXT_ID = X_CONTEXT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;

procedure DELETE_ROW (
  X_CONTEXT_ID in NUMBER
) is
begin

  delete from CS_KB_CONTEXTS
  where CONTEXT_ID = X_CONTEXT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

PROCEDURE LOAD_ROW(
  X_CONTEXT_ID in NUMBER,
  X_CONTEXT_TYPE in VARCHAR2,
  X_CONTEXT_VALUE in NUMBER,
  X_CONTEXT_VALUE2 in NUMBER,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_OWNER in varchar2,
  X_LAST_UPDATE_DATE in varchar2,
  X_CUSTOM_MODE in varchar2,
  X_RESPONSIBILITY_KEY in VARCHAR2) IS

  CURSOR Get_Resp_Id IS
  SELECT Responsibility_Id
  FROM FND_RESPONSIBILITY
  WHERE Responsibility_Key = X_RESPONSIBILITY_KEY
  AND Application_Id = X_CONTEXT_VALUE2;

  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db
  db_ovn    NUMBER;
  l_rowid rowid;
  l_context_value NUMBER;
BEGIN

  l_context_value :=null;
  -- For a Responsibility Seeding retrieve the Responsibilty Id from
  -- Responsibility Key
  IF X_CONTEXT_TYPE = 'R' THEN
    OPEN  Get_Resp_Id;
    FETCH Get_Resp_Id INTO l_context_value;
    CLOSE Get_Resp_Id;
  END IF;
  IF l_context_value IS NULL THEN
   l_context_value := X_CONTEXT_VALUE;
  END IF;

  -- Translate a true null value to fnd_api.g_miss_char
  -- Note table handler apis should be coded to treat
  -- fnd_api.g_miss_* as true nulls, and not as no-change.
  --	if (x_meaning = fnd_load_util.null_value) then
  --          l_meaning := fnd_api.g_miss_char;
  --        else
  --          l_meaning := x_meaning;
  --        end if;

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(X_OWNER);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(X_LAST_UPDATE_DATE, 'YYYY/MM/DD'), sysdate);
  BEGIN
    SELECT LAST_UPDATED_BY, LAST_UPDATE_DATE, OBJECT_VERSION_NUMBER
    INTO db_luby, db_ludate, db_ovn
    FROM CS_KB_CONTEXTS
    WHERE CONTEXT_ID = X_CONTEXT_ID;

	-- Test for customization and version
    IF (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, X_CUSTOM_MODE)) THEN
	  -- Update existing row
      UPDATE_ROW (
        X_CONTEXT_ID => X_CONTEXT_ID,
        X_CONTEXT_TYPE => X_CONTEXT_TYPE,
        X_CONTEXT_VALUE => l_context_value,
        X_CONTEXT_VALUE2  => X_CONTEXT_VALUE2,
        X_START_DATE_ACTIVE => X_START_DATE_ACTIVE,
        X_END_DATE_ACTIVE => X_END_DATE_ACTIVE,
        X_OBJECT_VERSION_NUMBER => db_ovn+1,
        X_ATTRIBUTE_CATEGORY => null,
        X_ATTRIBUTE1 => null,
        X_ATTRIBUTE2 => null,
        X_ATTRIBUTE3 => null,
        X_ATTRIBUTE4 => null,
        X_ATTRIBUTE5 => null,
        X_ATTRIBUTE6 => null,
        X_ATTRIBUTE7 => null,
        X_ATTRIBUTE8 => null,
        X_ATTRIBUTE9 => null,
        X_ATTRIBUTE10 => null,
        X_ATTRIBUTE11 => null,
        X_ATTRIBUTE12 => null,
        X_ATTRIBUTE13 => null,
        X_ATTRIBUTE14 => null,
        X_ATTRIBUTE15 => null,
        X_LAST_UPDATE_DATE  => f_ludate,
        X_LAST_UPDATED_BY => f_luby,
        X_LAST_UPDATE_LOGIN  => 0);

    END IF;
  EXCEPTION
    WHEN no_data_found THEN
      -- Record doesn't exist - insert in all cases
      INSERT_ROW (
        X_ROWID => l_rowid,
        X_CONTEXT_ID => X_CONTEXT_ID,
        X_CONTEXT_TYPE => X_CONTEXT_TYPE,
        X_CONTEXT_VALUE => l_context_value,
        X_CONTEXT_VALUE2 => X_CONTEXT_VALUE2,
        X_START_DATE_ACTIVE => X_START_DATE_ACTIVE,
        X_END_DATE_ACTIVE => X_END_DATE_ACTIVE,
        X_OBJECT_VERSION_NUMBER => 1,
        X_ATTRIBUTE_CATEGORY => null,
        X_ATTRIBUTE1 => null,
        X_ATTRIBUTE2 => null,
        X_ATTRIBUTE3 => null,
        X_ATTRIBUTE4 => null,
        X_ATTRIBUTE5 => null,
        X_ATTRIBUTE6 => null,
        X_ATTRIBUTE7 => null,
        X_ATTRIBUTE8 => null,
        X_ATTRIBUTE9 => null,
        X_ATTRIBUTE10 => null,
        X_ATTRIBUTE11 => null,
        X_ATTRIBUTE12 => null,
        X_ATTRIBUTE13 => null,
        X_ATTRIBUTE14 => null,
        X_ATTRIBUTE15 => null,
        X_CREATION_DATE => f_ludate,
        X_CREATED_BY => f_luby,
        X_LAST_UPDATE_DATE => f_ludate,
        X_LAST_UPDATED_BY => f_luby,
        X_LAST_UPDATE_LOGIN => 0);

  END;

END LOAD_ROW;

PROCEDURE LOAD_SEED_ROW(
  X_UPLOAD_MODE in VARCHAR2,
  X_CONTEXT_ID in NUMBER,
  X_CONTEXT_TYPE in VARCHAR2,
  X_CONTEXT_VALUE in NUMBER,
  X_CONTEXT_VALUE2 in NUMBER,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_OWNER in VARCHAR2,
  X_LAST_UPDATE_DATE in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2,
  X_RESPONSIBILITY_KEY in VARCHAR2) IS

BEGIN

 if (X_UPLOAD_MODE = 'NLS') then
   null; -- Entity is not translatable
 else
   LOAD_ROW(
       X_CONTEXT_ID,
       X_CONTEXT_TYPE,
       X_CONTEXT_VALUE,
       X_CONTEXT_VALUE2,
       X_START_DATE_ACTIVE,
       X_END_DATE_ACTIVE,
       X_OWNER,
       X_LAST_UPDATE_DATE,
       X_CUSTOM_MODE,
       X_RESPONSIBILITY_KEY );

 end if;

END LOAD_SEED_ROW;

end CS_KB_CONTEXTS_PKG;

/