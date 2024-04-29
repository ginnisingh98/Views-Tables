--------------------------------------------------------
--  DDL for Package Body CS_KB_SETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_KB_SETS_PKG" AS
/* $Header: cskbsb.pls 120.0 2005/06/01 15:19:23 appldev noship $ */
/*=======================================================================+
 |  Copyright (c) 1999 Oracle Corporation Redwood Shores, California, USA|
 |                            All rights reserved.                       |
 +=======================================================================+
 | FILENAME cskbsb.pls
 | DESCRIPTION
 |   PL/SQL body for package:  CS_KB_SETS_PKG
 |   This contains Table Handlers for CS_KB_SETS_B / _TL
 |
 |   HISTORY
 |     10.18.99    A. WONG Created
 |     01.05.00    HBALA   Added LOAD_ROW, TRANSLATE_ROW
 |     18-Aug-2003 MKETTLE 11.5.10 Cleanup - Reinstated use of Table
 |                         Handlers
 |     17-May-2005 MKETTLE Cleanup - Removed unused Apis: Does_Set_Exist
 *=======================================================================*/

 -- Private apis
 PROCEDURE Get_Who(
   X_SYSDATE  OUT NOCOPY date,
   X_USER_ID  OUT NOCOPY number,
   X_LOGIN_ID OUT NOCOPY number)
 IS
 BEGIN
  X_SYSDATE := sysdate;
  X_USER_ID := fnd_global.user_id;
  X_LOGIN_ID := fnd_global.login_id;
 END Get_Who;

 --Table Handlers:
 PROCEDURE Insert_Row(
   X_ROWID              IN OUT NOCOPY VARCHAR2,
   X_SET_ID             IN NUMBER,
   X_SET_NUMBER         IN VARCHAR2,
   X_SET_TYPE_ID        IN NUMBER,
   X_SET_NAME           IN VARCHAR2,
   X_GROUP_FLAG         IN NUMBER,
   X_STATUS             IN VARCHAR2,
   X_ACCESS_LEVEL       IN NUMBER,
   X_NAME               IN VARCHAR2,
   X_DESCRIPTION        IN VARCHAR2,
   X_CREATION_DATE      IN DATE,
   X_CREATED_BY         IN NUMBER,
   X_LAST_UPDATE_DATE   IN DATE,
   X_LAST_UPDATED_BY    IN NUMBER,
   X_LAST_UPDATE_LOGIN  IN NUMBER,
   X_LOCKED_BY          IN NUMBER,
   X_LOCK_DATE          IN DATE,
   X_ATTRIBUTE_CATEGORY IN VARCHAR2,
   X_ATTRIBUTE1         IN VARCHAR2,
   X_ATTRIBUTE2         IN VARCHAR2,
   X_ATTRIBUTE3         IN VARCHAR2,
   X_ATTRIBUTE4         IN VARCHAR2,
   X_ATTRIBUTE5         IN VARCHAR2,
   X_ATTRIBUTE6         IN VARCHAR2,
   X_ATTRIBUTE7         IN VARCHAR2,
   X_ATTRIBUTE8         IN VARCHAR2,
   X_ATTRIBUTE9         IN VARCHAR2,
   X_ATTRIBUTE10        IN VARCHAR2,
   X_ATTRIBUTE11        IN VARCHAR2,
   X_ATTRIBUTE12        IN VARCHAR2,
   X_ATTRIBUTE13        IN VARCHAR2,
   X_ATTRIBUTE14        IN VARCHAR2,
   X_ATTRIBUTE15        IN VARCHAR2,
   X_EMPLOYEE_ID        IN NUMBER,
   X_PARTY_ID           IN NUMBER,
   X_START_ACTIVE_DATE  IN DATE,
   X_END_ACTIVE_DATE    IN DATE,
   X_PRIORITY_CODE      IN NUMBER,
   X_VISIBILITY_ID      IN NUMBER )
 IS

  CURSOR c IS
  SELECT rowid
  FROM CS_KB_SETS_B
  WHERE set_id = x_set_id;
 BEGIN

  INSERT INTO CS_KB_SETS_B (
    set_id,
    set_number,
    set_type_id,
    set_name,
    group_flag,
    status,
    access_level,
    creation_date,
    created_by,
    last_update_date,
    last_updated_by,
    last_update_login,
    locked_by,
    lock_date,
    attribute_category,
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
    employee_id,
    party_id,
    start_active_date,
    end_active_date,
    priority_code,
    original_author,
    original_author_date,
    visibility_id,
    latest_version_flag,
    USAGE_SCORE )
  VALUES (
    x_set_id,
    x_set_number,
    x_set_type_id,
    x_set_name,
    x_group_flag,
    x_status,
    null, --l_access_level, --Commented out 14-Jul-2003 - Not required in 11.5.10
    x_creation_date,
    x_created_by,
    x_last_update_date,
    x_last_updated_by,
    x_last_update_login,
    x_locked_by,
    x_lock_date,
    x_attribute_category,
    x_attribute1,
    x_attribute2,
    x_attribute3,
    x_attribute4,
    x_attribute5,
    x_attribute6,
    x_attribute7,
    x_attribute8,
    x_attribute9,
    x_attribute10,
    x_attribute11,
    x_attribute12,
    x_attribute13,
    x_attribute14,
    x_attribute15,
    x_employee_id,
    x_party_id,
    x_start_active_date,
    x_end_active_date,
    4, --l_priority_code,
    x_created_by,
    x_creation_date,
    x_visibility_id,
    'Y',
    0 );

  INSERT INTO CS_KB_SETS_TL (
    set_id,
    name,
    description,
    creation_date,
    created_by,
    last_update_date,
    last_updated_by,
    last_update_login,
    language,
    source_lang
  ) SELECT
    x_set_id,
    x_name,
    x_description,
    x_creation_date,
    x_created_by,
    x_last_update_date,
    x_last_updated_by,
    x_last_update_login,
    l.language_code,
    USERENV('LANG')
  FROM fnd_languages l
  WHERE l.installed_flag IN ('I', 'B')
  AND NOT EXISTS
    (SELECT NULL
     FROM CS_KB_SETS_TL t
     WHERE t.set_id = x_set_id
     AND t.language = l.language_code);

  OPEN c;
  FETCH c INTO x_rowid;
  IF (c%NOTFOUND) THEN
    CLOSE c;
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE c;

 END Insert_Row;


 PROCEDURE Lock_Row (
   X_SET_ID             IN NUMBER,
   X_SET_NUMBER         IN VARCHAR2,
   X_SET_TYPE_ID        IN NUMBER,
   X_SET_NAME           IN VARCHAR2,
   X_GROUP_FLAG         IN NUMBER,
   X_STATUS             IN VARCHAR2,
   X_ACCESS_LEVEL       IN NUMBER,
   X_NAME               IN VARCHAR2,
   X_DESCRIPTION        IN VARCHAR2,
   X_LOCKED_BY          IN NUMBER,
   X_LOCK_DATE          IN DATE,
   X_ATTRIBUTE_CATEGORY IN VARCHAR2,
   X_ATTRIBUTE1         IN VARCHAR2,
   X_ATTRIBUTE2         IN VARCHAR2,
   X_ATTRIBUTE3         IN VARCHAR2,
   X_ATTRIBUTE4         IN VARCHAR2,
   X_ATTRIBUTE5         IN VARCHAR2,
   X_ATTRIBUTE6         IN VARCHAR2,
   X_ATTRIBUTE7         IN VARCHAR2,
   X_ATTRIBUTE8         IN VARCHAR2,
   X_ATTRIBUTE9         IN VARCHAR2,
   X_ATTRIBUTE10        IN VARCHAR2,
   X_ATTRIBUTE11        IN VARCHAR2,
   X_ATTRIBUTE12        IN VARCHAR2,
   X_ATTRIBUTE13        IN VARCHAR2,
   X_ATTRIBUTE14        IN VARCHAR2,
   X_ATTRIBUTE15        IN VARCHAR2,
   X_EMPLOYEE_ID        IN NUMBER,
   X_PARTY_ID           IN NUMBER,
   X_START_ACTIVE_DATE  IN DATE,
   X_END_ACTIVE_DATE    IN DATE,
   X_PRIORITY_CODE      IN NUMBER )
 IS
  CURSOR c IS
   SELECT
      set_id,
      set_number,
      set_type_id,
      set_name,
      group_flag,
      status,
      access_level,
      locked_by,
      lock_date,
      attribute_category,
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
      employee_id,
      party_id,
      start_active_date,
      end_active_date,
      priority_code
   FROM CS_KB_SETS_B
   WHERE set_id = x_set_id
   FOR UPDATE OF set_id NOWAIT;

  recinfo c%ROWTYPE;

  CURSOR c1 IS
   SELECT
      name,
      description,
      decode(language, USERENV('LANG'), 'Y', 'N') baselang
   FROM CS_KB_SETS_TL
   WHERE set_id = x_set_id
   AND USERENV('LANG') IN (language, source_lang)
   FOR UPDATE OF set_id NOWAIT;

 BEGIN
  OPEN c;
  FETCH c INTO recinfo;
  IF (c%NOTFOUND) THEN
    CLOSE c;
    FND_MESSAGE.set_name('FND', 'FORM_RECORD_DELETED');
    APP_EXCEPTION.raise_exception;
  END IF;
  CLOSE c;
  IF (    ((recinfo.attribute_category = x_attribute_category)
           OR ((recinfo.attribute_category IS NULL) AND (x_attribute_category IS NULL)))
      AND ((recinfo.attribute1 = x_attribute1)
           OR ((recinfo.attribute1 IS NULL) AND (x_attribute1 IS NULL)))
      AND ((recinfo.attribute2 = x_attribute2)
           OR ((recinfo.attribute2 IS NULL) AND (x_attribute2 IS NULL)))
      AND ((recinfo.attribute3 = x_attribute3)
           OR ((recinfo.attribute3 IS NULL) AND (x_attribute3 IS NULL)))
      AND ((recinfo.attribute4 = x_attribute4)
           OR ((recinfo.attribute4 IS NULL) AND (x_attribute4 IS NULL)))
      AND ((recinfo.attribute5 = x_attribute5)
           OR ((recinfo.attribute5 IS NULL) AND (x_attribute5 IS NULL)))
      AND ((recinfo.attribute6 = x_attribute6)
           OR ((recinfo.attribute6 IS NULL) AND (x_attribute6 IS NULL)))
      AND ((recinfo.attribute7 = x_attribute7)
           OR ((recinfo.attribute7 IS NULL) AND (x_attribute7 IS NULL)))
      AND ((recinfo.attribute8 = x_attribute8)
           OR ((recinfo.attribute8 IS NULL) AND (x_attribute8 IS NULL)))
      AND ((recinfo.attribute9 = x_attribute9)
           OR ((recinfo.attribute9 IS NULL) AND (x_attribute9 IS NULL)))
      AND ((recinfo.attribute10 = x_attribute10)
           OR ((recinfo.attribute10 IS NULL) AND (x_attribute10 IS NULL)))
      AND ((recinfo.attribute11 = x_attribute11)
           OR ((recinfo.attribute11 IS NULL) AND (x_attribute11 IS NULL)))
      AND ((recinfo.attribute12 = x_attribute12)
           OR ((recinfo.attribute12 IS NULL) AND (x_attribute12 IS NULL)))
      AND ((recinfo.attribute13 = x_attribute13)
           OR ((recinfo.attribute13 IS NULL) AND (x_attribute13 IS NULL)))
      AND ((recinfo.attribute14 = x_attribute14)
           OR ((recinfo.attribute14 IS NULL) AND (x_attribute14 IS NULL)))
      AND ((recinfo.attribute15 = x_attribute15)
           OR ((recinfo.attribute15 IS NULL) AND (x_attribute15 IS NULL)))
      AND ((recinfo.employee_id = x_employee_id)
           OR ((recinfo.employee_id IS NULL) AND (x_employee_id IS NULL)))
      AND ((recinfo.party_id = x_party_id)
           OR ((recinfo.party_id IS NULL) AND (x_party_id IS NULL)))
      AND ((recinfo.group_flag = x_group_flag)
           OR ((recinfo.group_flag IS NULL) AND (x_group_flag IS NULL)))
      AND ((recinfo.status = x_status)
           OR ((recinfo.status IS NULL) AND (x_status IS NULL)))
      AND ((recinfo.access_level = x_access_level)
           OR ((recinfo.access_level IS NULL) AND (x_access_level IS NULL)))
      AND ((recinfo.set_type_id = x_set_type_id)
           OR ((recinfo.set_type_id IS NULL) AND (x_set_type_id IS NULL)))
      AND ((recinfo.set_number = x_set_number)
           OR ((recinfo.set_number IS NULL) AND (x_set_number IS NULL)))
      AND ((recinfo.set_id = x_set_id)
           OR ((recinfo.set_id IS NULL) AND (x_set_id IS NULL)))
      AND ((recinfo.locked_by = x_locked_by)
           OR ((recinfo.locked_by IS NULL) AND (x_locked_by IS NULL)))
      AND ((recinfo.lock_date = x_lock_date)
           OR ((recinfo.lock_date IS NULL) AND (x_lock_date IS NULL)))
      AND ((recinfo.set_name = x_set_name)
           OR ((recinfo.set_name IS NULL) AND (x_set_name IS NULL)))
      AND ((recinfo.start_active_date = x_start_active_date)
           OR ((recinfo.start_active_date IS NULL) AND (x_start_active_date IS NULL)))
      AND ((recinfo.end_active_date = x_end_active_date)
           OR ((recinfo.end_active_date IS NULL) AND (x_end_active_date IS NULL)))
      AND ((recinfo.priority_code = x_priority_code)
           OR ((recinfo.priority_code IS NULL) AND (x_priority_code IS NULL)))
  ) THEN
    NULL;
  ELSE
    FND_MESSAGE.set_name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.raise_exception;
  END IF;

  FOR tlinfo IN c1 LOOP
    IF (tlinfo.baselang = 'Y') THEN
      IF (    ((tlinfo.name = x_name)
               OR ((tlinfo.name IS NULL) AND (x_name IS NULL)))
          AND ((tlinfo.description = x_description)
               OR ((tlinfo.description IS NULL) AND (x_description IS NULL)))
      ) THEN
        NULL;
      ELSE
        FND_MESSAGE.set_name('FND', 'FORM_RECORD_CHANGED');
        APP_EXCEPTION.raise_exception;
      END IF;
    END IF;
  END LOOP;
  RETURN;
 END Lock_Row;


 PROCEDURE Update_Row (
   X_SET_ID             IN NUMBER,
   X_SET_NUMBER         IN VARCHAR2,
   X_SET_TYPE_ID        IN NUMBER,
   X_SET_NAME           IN VARCHAR2,
   X_GROUP_FLAG         IN NUMBER,
   X_STATUS             IN VARCHAR2,
   X_ACCESS_LEVEL       IN NUMBER,
   X_NAME               IN VARCHAR2,
   X_DESCRIPTION        IN VARCHAR2,
   X_LAST_UPDATE_DATE   IN DATE,
   X_LAST_UPDATED_BY    IN NUMBER,
   X_LAST_UPDATE_LOGIN  IN NUMBER,
   X_LOCKED_BY          IN NUMBER,
   X_LOCK_DATE          IN DATE,
   X_ATTRIBUTE_CATEGORY IN VARCHAR2,
   X_ATTRIBUTE1         IN VARCHAR2,
   X_ATTRIBUTE2         IN VARCHAR2,
   X_ATTRIBUTE3         IN VARCHAR2,
   X_ATTRIBUTE4         IN VARCHAR2,
   X_ATTRIBUTE5         IN VARCHAR2,
   X_ATTRIBUTE6         IN VARCHAR2,
   X_ATTRIBUTE7         IN VARCHAR2,
   X_ATTRIBUTE8         IN VARCHAR2,
   X_ATTRIBUTE9         IN VARCHAR2,
   X_ATTRIBUTE10        IN VARCHAR2,
   X_ATTRIBUTE11        IN VARCHAR2,
   X_ATTRIBUTE12        IN VARCHAR2,
   X_ATTRIBUTE13        IN VARCHAR2,
   X_ATTRIBUTE14        IN VARCHAR2,
   X_ATTRIBUTE15        IN VARCHAR2,
   X_EMPLOYEE_ID        IN NUMBER,
   X_PARTY_ID           IN NUMBER,
   X_START_ACTIVE_DATE  IN DATE,
   X_END_ACTIVE_DATE    IN DATE,
   X_PRIORITY_CODE      IN NUMBER,
   X_VISIBILITY_ID      IN NUMBER )
 IS

 BEGIN

  UPDATE CS_KB_SETS_B SET
    set_type_id = x_set_type_id,
    set_name = x_set_name,
    group_flag = x_group_flag,
    status = x_status,
    --access_level = l_access_level,
    last_update_date = x_last_update_date,
    last_updated_by = x_last_updated_by,
    last_update_login = x_last_update_login,
    locked_by = x_locked_by,
    lock_date = x_lock_date,
    attribute_category = x_attribute_category,
    attribute1 = x_attribute1,
    attribute2 = x_attribute2,
    attribute3 = x_attribute3,
    attribute4 = x_attribute4,
    attribute5 = x_attribute5,
    attribute6 = x_attribute6,
    attribute7 = x_attribute7,
    attribute8 = x_attribute8,
    attribute9 = x_attribute9,
    attribute10 = x_attribute10,
    attribute11 = x_attribute11,
    attribute12 = x_attribute12,
    attribute13 = x_attribute13,
    attribute14 = x_attribute14,
    attribute15 = x_attribute15,
    employee_id = x_employee_id,
    party_id = x_party_id,
    start_active_date = x_start_active_date,
    end_active_date = x_end_active_date,
    --priority_code = l_priority_code,
    visibility_id = x_visibility_id
  WHERE set_id = x_set_id;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

  UPDATE CS_KB_SETS_TL SET
    name = x_name,
    description = x_description,
    last_update_date = x_last_update_date,
    last_updated_by = x_last_updated_by,
    last_update_login = x_last_update_login,
    source_lang = USERENV('LANG')
  WHERE set_id = x_set_id
  AND USERENV('LANG') IN (language, source_lang);

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

 END Update_Row;


 PROCEDURE Delete_Row (
   X_SET_NUMBER IN VARCHAR2 )
 IS

 CURSOR c IS
  SELECT set_id
  FROM CS_KB_SETS_B
  WHERE set_number = X_SET_NUMBER;

 BEGIN

  FOR rec IN c LOOP
    DELETE FROM CS_KB_SETS_TL
    WHERE set_id = rec.set_id;
  END LOOP;

  DELETE FROM CS_KB_SETS_B
  WHERE set_number = x_set_number;
  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

 END Delete_Row;


 PROCEDURE Add_Language
 IS

 BEGIN

  DELETE FROM CS_KB_SETS_TL t
  WHERE NOT EXISTS
    (SELECT NULL
     FROM CS_KB_SETS_B b
     WHERE b.set_id = t.set_id );

  UPDATE CS_KB_SETS_TL T SET (
      name,
      description
    ) = (SELECT
      b.name,
      b.description
    FROM CS_KB_SETS_TL b
    WHERE b.set_id = t.set_id
    AND b.language = t.source_lang)
  WHERE (
      t.set_id,
      t.language
  ) IN (SELECT
      subt.set_id,
      subt.language
    FROM CS_KB_SETS_TL subb, CS_KB_SETS_TL subt
    WHERE subb.set_id = subt.set_id
    AND subb.language = subt.source_lang
    AND (subb.name <> subt.name
      OR (subb.name IS NULL AND subt.name IS NOT NULL)
      OR (subb.name IS not NULL AND subt.name IS NULL)
      OR subb.description <> subt.description
      OR (subb.description IS NULL AND subt.description IS NOT NULL)
      OR (subb.description IS NOT NULL AND subt.description IS NULL)
  ));

  INSERT INTO CS_KB_SETS_TL (
    set_id,
    name,
    description,
    creation_date,
    created_by,
    last_update_date,
    last_update_login,
    last_updated_by,
    language,
    source_lang
  ) SELECT
    b.set_id,
    b.name,
    b.description,
    b.creation_date,
    b.created_by,
    b.last_update_date,
    b.last_update_login,
    b.last_updated_by,
    l.language_code,
    b.source_lang
  FROM CS_KB_SETS_TL b, fnd_languages l --bayu
  WHERE l.installed_flag IN ('I', 'B')
  AND b.language = USERENV('LANG')
  AND NOT EXISTS
    (SELECT NULL
    FROM CS_KB_SETS_TL t
    WHERE t.set_id = b.set_id
    AND t.language = l.language_code);

 END Add_Language;


 PROCEDURE Translate_Row(
   X_SET_ID     IN NUMBER,
   X_SET_NUMBER IN VARCHAR2,
   X_OWNER      IN VARCHAR2,
   X_NAME       IN VARCHAR2) IS
 BEGIN

  UPDATE CS_KB_SETS_TL SET
	name = x_name,
	last_update_date  = SYSDATE,
    last_updated_by   = decode(x_owner, 'SEED', 1, 0),
    last_update_login = 0,
    source_lang       = USERENV('LANG')
  WHERE set_id = X_SET_ID
  AND USERENV('LANG') IN (language, source_lang);

 END Translate_Row;


 PROCEDURE Load_Row(
   X_SET_ID        IN NUMBER,
   X_SET_NUMBER    IN VARCHAR2,
   X_SET_TYPE_ID   IN NUMBER,
   X_STATUS        IN VARCHAR2,
   X_ACCESS_LEVEL  IN NUMBER,
   X_OWNER         IN VARCHAR2,
   X_NAME          IN VARCHAR2,
   X_VISIBILITY_ID IN NUMBER)
 IS

  l_user_id NUMBER;
  l_rowid VARCHAR2(100);
  l_locked_by NUMBER;
  l_lock_date DATE;

 BEGIN

    IF (x_owner = 'SEED') THEN
      l_user_id := 1;
    ELSE
      l_user_id := 0;
    END IF;

    CS_KB_SOLUTION_PVT.Get_Lock_Info(x_set_number, l_locked_by, l_lock_date);

    Update_Row(
      x_set_id => x_set_id,
      x_set_number => x_set_number,
      x_set_type_id => x_set_type_id,
      x_set_name => NULL,
      x_group_flag => NULL,
      x_status => x_status,
      x_access_level => x_access_level,
      x_name => x_name,
      x_description => NULL,
      x_last_update_date => SYSDATE,
      x_last_updated_by => l_user_id,
      x_last_update_login => 0,
      x_locked_by => l_locked_by,
      x_lock_date => l_lock_date,
      x_visibility_id => x_visibility_id);

 EXCEPTION
  WHEN NO_DATA_FOUND THEN
        	Insert_Row(
       		  x_rowid => l_rowid,
              x_set_id => x_set_id,
              x_set_number => x_set_number,
              x_set_type_id => x_set_type_id,
              x_set_name => NULL,
              x_group_flag => NULL,
              x_status => x_status,
              x_access_level => x_access_level,
              x_name => x_name,
              x_description => NULL,
    		  x_creation_date => SYSDATE,
    		  x_created_by => l_user_id,
    		  x_last_update_date => SYSDATE,
    		  x_last_updated_by => l_user_id,
    		  x_last_update_login => 0,
              x_locked_by => NULL,
              x_lock_date => NULL,
              x_visibility_id => x_visibility_id);

 END Load_Row;


END CS_KB_SETS_PKG;

/
