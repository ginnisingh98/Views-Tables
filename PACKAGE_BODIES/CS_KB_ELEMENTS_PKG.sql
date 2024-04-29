--------------------------------------------------------
--  DDL for Package Body CS_KB_ELEMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_KB_ELEMENTS_PKG" AS
/* $Header: cskbelb.pls 120.0 2005/06/01 11:41:58 appldev noship $ */
/*=======================================================================+
 |  Copyright (c) 1999 Oracle Corporation Redwood Shores, California, USA|
 |                            All rights reserved.                       |
 +=======================================================================+
 | FILENAME cskbelb.pls
 | DESCRIPTION
 |   PL/SQL body for package:  CS_KB_ELEMENTS_PKG
 |   This contains the Private Table Handlers for a Statement (Element)
 |
 |   History:
 |     10.18.99    AWWONG Created
 |     01.05.00    HBALA   Added LOAD_ROW, TRANSLATE_ROW
 |     01.20.00    AWWONG  Add check links before delete, fill name(2000)
 |     18-Nov-2003 MKETTLE Cleanup for 11.5.10
 |                         - Obsolete unused apis
 |                         - Moved ELE_AUDIT table Handlers back here
 |     17-May-2005 MKETTLE Cleanup - Removed obs Incr_Element_Element in 115.50
 *=======================================================================*/

 PROCEDURE Get_Who(
   X_SYSDATE  OUT NOCOPY DATE,
   X_USER_ID  OUT NOCOPY NUMBER,
   X_LOGIN_ID OUT NOCOPY NUMBER )
 IS
 BEGIN

  x_sysdate  := sysdate;
  x_user_id  := fnd_global.user_id;
  x_login_id := fnd_global.login_id;

 END Get_Who;

 PROCEDURE Insert_Row (
   X_ROWID              IN OUT NOCOPY VARCHAR2,
   X_ELEMENT_ID         IN            NUMBER,
   X_ELEMENT_NUMBER     IN            VARCHAR2,
   X_ELEMENT_TYPE_ID    IN            NUMBER,
   X_ELEMENT_NAME       IN            VARCHAR2,
   X_GROUP_FLAG         IN            NUMBER,
   X_STATUS             IN            VARCHAR2,
   X_ACCESS_LEVEL       IN            NUMBER,
   X_NAME               IN            VARCHAR2,
   X_DESCRIPTION        IN            CLOB,
   X_CREATION_DATE      IN            DATE,
   X_CREATED_BY         IN            NUMBER,
   X_LAST_UPDATE_DATE   IN            DATE,
   X_LAST_UPDATED_BY    IN            NUMBER,
   X_LAST_UPDATE_LOGIN  IN            NUMBER,
   X_LOCKED_BY          IN            NUMBER,
   X_LOCK_DATE          IN            DATE,
   X_ATTRIBUTE_CATEGORY IN            VARCHAR2,
   X_ATTRIBUTE1         IN            VARCHAR2,
   X_ATTRIBUTE2         IN            VARCHAR2,
   X_ATTRIBUTE3         IN            VARCHAR2,
   X_ATTRIBUTE4         IN            VARCHAR2,
   X_ATTRIBUTE5         IN            VARCHAR2,
   X_ATTRIBUTE6         IN            VARCHAR2,
   X_ATTRIBUTE7         IN            VARCHAR2,
   X_ATTRIBUTE8         IN            VARCHAR2,
   X_ATTRIBUTE9         IN            VARCHAR2,
   X_ATTRIBUTE10        IN            VARCHAR2,
   X_ATTRIBUTE11        IN            VARCHAR2,
   X_ATTRIBUTE12        IN            VARCHAR2,
   X_ATTRIBUTE13        IN            VARCHAR2,
   X_ATTRIBUTE14        IN            VARCHAR2,
   X_ATTRIBUTE15        IN            VARCHAR2,
   X_START_ACTIVE_DATE  IN            DATE,
   X_END_ACTIVE_DATE    IN            DATE,
   X_CONTENT_TYPE       IN            VARCHAR2 )

 IS

  l_access_level CS_KB_ELEMENTS_B.ACCESS_LEVEL%TYPE;
  l_content_type CS_KB_ELEMENTS_B.CONTENT_TYPE%TYPE;

  l_srclen       INTEGER :=0;
  l_clob         CLOB;

  CURSOR c IS
   SELECT rowid
   FROM CS_KB_ELEMENTS_B
   WHERE element_id = x_element_id;

  CURSOR c_tl(c_id IN NUMBER) IS
   SELECT element_id,
          language,
          description
   FROM CS_KB_ELEMENTS_TL
   WHERE element_id = c_id;

 BEGIN

  IF x_access_level IS NULL THEN
    FND_PROFILE.GET('CS_KB_SMP_SOL_ACCESS_LEVEL', l_access_level);

    IF l_access_level is null THEN
      l_access_level := 3000;
    END IF;

  ELSE
    l_access_level := x_access_level;
  END IF;

  IF x_content_type IS NULL THEN
    FND_PROFILE.GET('CS_KB_SMP_SOL_CONTENT_TYPE', l_content_type);

    IF l_content_type is null THEN
      l_content_type := 'TEXT/HTML';
    END IF;

  ELSE
    l_content_type := x_content_type;
  END IF;

  INSERT INTO CS_KB_ELEMENTS_B (
    element_id,
    element_number,
    element_type_id,
    element_name,
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
    start_active_date,
    end_active_date,
    content_type
  ) VALUES (
    x_element_id,
    x_element_number,
    x_element_type_id,
    x_element_name,
    x_group_flag,
    x_status,
    l_access_level,
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
    x_start_active_date,
    x_end_active_date,
    l_content_type );

  INSERT INTO CS_KB_ELEMENTS_TL (
    element_id,
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
    x_element_id,
    x_name,
    empty_clob(),
    x_creation_date,
    x_created_by,
    x_last_update_date,
    x_last_updated_by,
    x_last_update_login,
    l.language_code,
    USERENV('LANG')
  FROM FND_LANGUAGES l
  WHERE l.installed_flag IN ('I', 'B')
  AND NOT EXISTS
    (SELECT NULL
    FROM CS_KB_ELEMENTS_TL t
    WHERE t.element_id = x_element_id
    AND t.language = l.language_code);

  --INSERT given clob INTO clob_locator FOR all languages.
  IF(x_description IS NOT NULL AND
     DBMS_LOB.getlength(x_description)>0) THEN

    l_srclen := DBMS_LOB.getlength(x_description);

    FOR rectl IN c_tl(x_element_id) LOOP

      DBMS_LOB.copy(rectl.description, x_description, l_srclen, 1,1);

    END LOOP;

  END IF;

  OPEN c;
  FETCH c INTO x_rowid;
  IF (c%NOTFOUND) THEN
    CLOSE c;
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE c;

 END Insert_Row;


 PROCEDURE Lock_Row (
   X_ELEMENT_ID         IN            NUMBER,
   X_ELEMENT_NUMBER     IN            VARCHAR2,
   X_ELEMENT_TYPE_ID    IN            NUMBER,
   X_ELEMENT_NAME       IN            VARCHAR2,
   X_GROUP_FLAG         IN            NUMBER,
   X_STATUS             IN            VARCHAR2,
   X_ACCESS_LEVEL       IN            NUMBER,
   X_NAME               IN            VARCHAR2,
   X_DESCRIPTION        IN            CLOB,
   X_LOCKED_BY          IN            NUMBER,
   X_LOCK_DATE          IN            DATE,
   X_ATTRIBUTE_CATEGORY IN            VARCHAR2,
   X_ATTRIBUTE1         IN            VARCHAR2,
   X_ATTRIBUTE2         IN            VARCHAR2,
   X_ATTRIBUTE3         IN            VARCHAR2,
   X_ATTRIBUTE4         IN            VARCHAR2,
   X_ATTRIBUTE5         IN            VARCHAR2,
   X_ATTRIBUTE6         IN            VARCHAR2,
   X_ATTRIBUTE7         IN            VARCHAR2,
   X_ATTRIBUTE8         IN            VARCHAR2,
   X_ATTRIBUTE9         IN            VARCHAR2,
   X_ATTRIBUTE10        IN            VARCHAR2,
   X_ATTRIBUTE11        IN            VARCHAR2,
   X_ATTRIBUTE12        IN            VARCHAR2,
   X_ATTRIBUTE13        IN            VARCHAR2,
   X_ATTRIBUTE14        IN            VARCHAR2,
   X_ATTRIBUTE15        IN            VARCHAR2,
   X_START_ACTIVE_DATE  IN            DATE,
   X_END_ACTIVE_DATE    IN            DATE,
   X_CONTENT_TYPE       IN            VARCHAR2 )
 IS
  CURSOR c IS
   SELECT
      element_id,
      element_number,
      element_type_id,
      element_name,
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
      start_active_date,
      end_active_date,
      content_type
   FROM CS_KB_ELEMENTS_B
   WHERE element_id = x_element_id
   FOR UPDATE OF element_id NOWAIT;

  recinfo c%ROWTYPE;

  CURSOR c1 IS
   SELECT name,
          description,
          decode(language, USERENV('LANG'), 'Y', 'N') baselang
   FROM CS_KB_ELEMENTS_TL
   WHERE element_id = x_element_id
   AND   USERENV('LANG') IN (language, source_lang)
   FOR UPDATE OF element_id NOWAIT;

 BEGIN

  OPEN c;
  FETCH c INTO recinfo;
  IF (c%NOTFOUND) THEN
    CLOSE c;
    FND_MESSAGE.set_name('FND', 'FORM_RECORD_DELETED');
    APP_EXCEPTION.raise_exception;
  END IF;
  CLOSE c;
  IF (   ((recinfo.element_number = x_element_number)
           OR ((recinfo.element_number IS NULL) AND (x_element_number IS NULL)))
      AND ((recinfo.element_id = x_element_id)
           OR ((recinfo.element_id IS NULL) AND (x_element_id IS NULL)))
      AND ((recinfo.locked_by = x_locked_by)
           OR ((recinfo.locked_by IS NULL) AND (x_locked_by IS NULL)))
      AND ((recinfo.lock_date = x_lock_date)
           OR ((recinfo.lock_date IS NULL) AND (x_lock_date IS NULL)))
      AND ((recinfo.element_type_id = x_element_type_id)
           OR ((recinfo.element_type_id IS NULL) AND (x_element_type_id IS NULL)))
      AND ((recinfo.element_name = x_element_name)
           OR ((recinfo.element_name IS NULL) AND (x_element_name IS NULL)))
      AND ((recinfo.group_flag = x_group_flag)
           OR ((recinfo.group_flag IS NULL) AND (x_group_flag IS NULL)))
      AND ((recinfo.status = x_status)
           OR ((recinfo.status IS NULL) AND (x_status IS NULL)))
      AND ((recinfo.access_level = x_access_level)
           OR ((recinfo.access_level IS NULL) AND (x_access_level IS NULL)))
      AND ((recinfo.attribute_category = x_attribute_category)
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
      AND ((recinfo.start_active_date = x_start_active_date)
           OR ((recinfo.start_active_date IS NULL) AND (x_start_active_date IS NULL)))
      AND ((recinfo.end_active_date = x_end_active_date)
           OR ((recinfo.end_active_date IS NULL) AND (x_end_active_date IS NULL)))
      AND ((recinfo.content_type = x_content_type)
           OR ((recinfo.content_type IS NULL) AND (x_content_type IS NULL)))
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
          AND ((
               DBMS_LOB.compare(x_description, tlinfo.description,
                                DBMS_LOB.getlength(x_description),1,1)=0 )
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
   X_ELEMENT_ID         IN            NUMBER,
   X_ELEMENT_NUMBER     IN            VARCHAR2,
   X_ELEMENT_TYPE_ID    IN            NUMBER,
   X_ELEMENT_NAME       IN            VARCHAR2,
   X_GROUP_FLAG         IN            NUMBER,
   X_STATUS             IN            VARCHAR2,
   X_ACCESS_LEVEL       IN            NUMBER,
   X_NAME               IN            VARCHAR2,
   X_DESCRIPTION        IN            CLOB,
   X_LAST_UPDATE_DATE   IN            DATE,
   X_LAST_UPDATED_BY    IN            NUMBER,
   X_LAST_UPDATE_LOGIN  IN            NUMBER,
   X_LOCKED_BY          IN            NUMBER,
   X_LOCK_DATE          IN            DATE,
   X_ATTRIBUTE_CATEGORY IN            VARCHAR2,
   X_ATTRIBUTE1         IN            VARCHAR2,
   X_ATTRIBUTE2         IN            VARCHAR2,
   X_ATTRIBUTE3         IN            VARCHAR2,
   X_ATTRIBUTE4         IN            VARCHAR2,
   X_ATTRIBUTE5         IN            VARCHAR2,
   X_ATTRIBUTE6         IN            VARCHAR2,
   X_ATTRIBUTE7         IN            VARCHAR2,
   X_ATTRIBUTE8         IN            VARCHAR2,
   X_ATTRIBUTE9         IN            VARCHAR2,
   X_ATTRIBUTE10        IN            VARCHAR2,
   X_ATTRIBUTE11        IN            VARCHAR2,
   X_ATTRIBUTE12        IN            VARCHAR2,
   X_ATTRIBUTE13        IN            VARCHAR2,
   X_ATTRIBUTE14        IN            VARCHAR2,
   X_ATTRIBUTE15        IN            VARCHAR2,
   X_START_ACTIVE_DATE  IN            DATE,
   X_END_ACTIVE_DATE    IN            DATE,
   X_CONTENT_TYPE       IN            VARCHAR2 )
 IS

  l_access_level CS_KB_ELEMENTS_B.ACCESS_LEVEL%TYPE;
  l_content_type CS_KB_ELEMENTS_B.CONTENT_TYPE%TYPE;

  l_srclen INTEGER :=0;
  l_destlen INTEGER :=0;

  CURSOR c_tl(c_id IN NUMBER) IS
   SELECT element_id,
          language,
          description
   FROM CS_KB_ELEMENTS_TL
   WHERE element_id = c_id
   AND USERENV('LANG') IN (language, source_lang) FOR UPDATE;

 BEGIN
  IF x_access_level IS NULL THEN
    FND_PROFILE.GET('CS_KB_SMP_SOL_ACCESS_LEVEL', l_access_level);

    IF l_access_level is null THEN
      l_access_level := 3000;
    END IF;

  ELSE
    l_access_level := x_access_level;
  END IF;

  IF x_content_type IS NULL THEN
    FND_PROFILE.GET('CS_KB_SMP_SOL_CONTENT_TYPE', l_content_type);

    IF l_content_type is null THEN
      l_content_type := 'TEXT/HTML';
    END IF;

  ELSE
    l_content_type := x_content_type;
  END IF;

  UPDATE CS_KB_ELEMENTS_B SET
    element_type_id    = x_element_type_id,
    element_name       = x_element_name,
    group_flag         = x_group_flag,
    status             = x_status,
    access_level       = l_access_level,
    last_update_date   = x_last_update_date,
    last_updated_by    = x_last_updated_by,
    last_update_login  = x_last_update_login,
    locked_by          = x_locked_by,
    lock_date          = x_lock_date,
    attribute_category = x_attribute_category,
    attribute1         = x_attribute1,
    attribute2         = x_attribute2,
    attribute3         = x_attribute3,
    attribute4         = x_attribute4,
    attribute5         = x_attribute5,
    attribute6         = x_attribute6,
    attribute7         = x_attribute7,
    attribute8         = x_attribute8,
    attribute9         = x_attribute9,
    attribute10        = x_attribute10,
    attribute11        = x_attribute11,
    attribute12        = x_attribute12,
    attribute13        = x_attribute13,
    attribute14        = x_attribute14,
    attribute15        = x_attribute15,
    start_active_date  = x_start_active_date,
    end_active_date    = x_end_active_date,
    content_type       = l_content_type
  WHERE element_id = x_element_id;
  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

  UPDATE CS_KB_ELEMENTS_TL SET
    name              = x_name,
    description       = EMPTY_CLOB(),
    last_update_date  = x_last_update_date,
    last_updated_by   = x_last_updated_by,
    last_update_login = x_last_update_login,
    source_lang       = USERENV('LANG')
  WHERE element_id = x_element_id
  AND USERENV('LANG') IN (language, source_lang);

  IF(x_description IS NOT NULL AND
     DBMS_LOB.getlength(x_description)>0) THEN
     l_srclen := DBMS_LOB.getlength(x_description);

    FOR rectl IN c_tl(x_element_id) LOOP
      DBMS_LOB.copy(rectl.description, x_description, l_srclen, 1,1);
    END LOOP;

  END IF;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

 END Update_Row;


 PROCEDURE Delete_Row (
   X_ELEMENT_NUMBER IN VARCHAR2)
 IS

  CURSOR c IS
   SELECT element_id
   FROM CS_KB_ELEMENTS_B
   WHERE element_number = x_element_number;

 BEGIN

  FOR rec IN c LOOP

    DELETE FROM CS_KB_ELEMENTS_TL
    WHERE element_id = rec.element_id;

  END LOOP;

  DELETE FROM CS_KB_ELEMENTS_B
  WHERE element_number = x_element_number;

 END Delete_Row;

 PROCEDURE Add_Language
 IS
 BEGIN

  DELETE FROM CS_KB_ELEMENTS_TL t
  WHERE NOT EXISTS (SELECT NULL
                    FROM CS_KB_ELEMENTS_B b
                    WHERE b.element_id = t.element_id );

  UPDATE CS_KB_ELEMENTS_TL t
  SET ( name,
        description
      ) = (SELECT b.name,
                  b.description
           FROM CS_KB_ELEMENTS_TL b
           WHERE b.element_id = t.element_id
           AND b.language = t.source_lang )
  WHERE ( t.element_id,
          t.language) IN (SELECT subt.element_id,
                                 subt.language
                          FROM CS_KB_ELEMENTS_TL subb,
                               CS_KB_ELEMENTS_TL subt
                          WHERE subb.element_id = subt.element_id
                          AND subb.language = subt.source_lang
                          AND (subb.name <> subt.name
                           OR (subb.name IS NULL AND subt.name IS NOT NULL)
                           OR (subb.name IS NOT NULL AND subt.name IS NULL)
                           OR DBMS_LOB.compare(subb.description, subt.description,
                                               DBMS_LOB.getlength(subb.description), 1,1)<>0
                           OR (subb.description IS NULL AND subt.description IS NOT NULL)
                           OR (subb.description IS NOT NULL AND subt.description IS NULL)
                         ));

  INSERT INTO CS_KB_ELEMENTS_TL (
    element_id,
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
    b.element_id,
    b.name,
    b.description,
    b.creation_date,
    b.created_by,
    b.last_update_date,
    b.last_updated_by,
    b.last_update_login,
    l.language_code,
    b.source_lang
  FROM CS_KB_ELEMENTS_TL b, fnd_languages l
  WHERE l.installed_flag IN ('I', 'B')
  AND b.language = USERENV('LANG')
  AND NOT EXISTS
    (SELECT NULL
     FROM CS_KB_ELEMENTS_TL t
     WHERE t.element_id = b.element_id
     AND t.language = l.language_code);

 END Add_Language;


 PROCEDURE Translate_Row(
   X_ELEMENT_ID     IN NUMBER,
   X_ELEMENT_NUMBER IN VARCHAR2,
   X_OWNER          IN VARCHAR2,
   X_NAME           IN VARCHAR2,
   X_DESCRIPTION    IN VARCHAR2)
 IS

  l_srclen integer :=0;
  l_destlen integer :=0;

  CURSOR c_tl(c_id IN NUMBER) IS
   SELECT
      element_id,
      language,
      description
   FROM CS_KB_ELEMENTS_TL
   WHERE element_id = c_id
   AND USERENV('LANG') IN (language, source_lang) FOR UPDATE;

  l_user_id NUMBER;
  l_clob    clob := NULL;
  l_offset  NUMBER;
  l_amt     NUMBER;

 BEGIN
  -- write desc to temporary clob
  IF(x_description IS NOT NULL ) THEN
    DBMS_LOB.createtemporary(l_clob, true, DBMS_LOB.session);
    l_offset := 1;
    l_amt := length(x_description);
    DBMS_LOB.write(l_clob, l_amt, l_offset, x_description);
  END IF;

  -- UPDATE translated non-clob portions FOR specified language
  UPDATE CS_KB_ELEMENTS_TL SET
	    name = x_name,
	    last_update_date  = SYSDATE,
        last_updated_by   = decode(x_owner, 'SEED', 1, 0),
        last_update_login = 0,
        source_lang       = USERENV('LANG')
  WHERE element_id = TO_NUMBER(x_element_id) --change
  AND USERENV('LANG') IN (language, source_lang);

  --copy given clob INTO clob_locator FOR current language.
  FOR rectl IN c_tl(x_element_id) LOOP
     l_srclen := 0;
     IF(x_description IS NOT NULL AND
       DBMS_LOB.getlength(l_clob)>0) THEN
       l_srclen := DBMS_LOB.getlength(l_clob);
     END IF;

     l_destlen := DBMS_LOB.getlength(rectl.description);

     IF(l_destlen > l_srclen) THEN
       DBMS_LOB.trim(rectl.description, l_srclen);
     END IF;

     IF(x_description IS NOT NULL AND
       DBMS_LOB.getlength(l_clob)>0) THEN
       --DBMS_LOB.copy(rectl.description, l_clob, DBMS_LOB.lobmaxsize, 1,1);
       DBMS_LOB.copy(rectl.description, l_clob, l_srclen, 1,1);
     END IF;
  END LOOP;

  IF(x_description IS NOT NULL) THEN
     DBMS_LOB.freetemporary(l_clob);
  END IF;

 EXCEPTION
   WHEN NO_DATA_FOUND THEN
   NULL;
 END Translate_Row;


 PROCEDURE Load_Row(
   X_ELEMENT_ID      IN NUMBER,
   X_ELEMENT_NUMBER  IN VARCHAR2,
   X_ELEMENT_TYPE_ID IN NUMBER,
   X_STATUS          IN VARCHAR2,
   X_ACCESS_LEVEL    IN NUMBER,
   X_OWNER           IN VARCHAR2,
   X_NAME            IN VARCHAR2,
   X_DESCRIPTION     IN VARCHAR2)
 IS

  l_user_id NUMBER;
  l_rowid VARCHAR2(100);
  l_clob clob := NULL;
  l_offset NUMBER;
  l_amt    NUMBER;
  l_locked_by NUMBER;
  l_lock_date DATE;

 BEGIN

  IF (x_owner = 'SEED') THEN
    l_user_id := 1;
  ELSE
    l_user_id := 0;
  END IF;

  -- write desc to clob

  IF( x_description IS NOT NULL)  THEN

     DBMS_LOB.createtemporary(l_clob, true, DBMS_LOB.session);
     l_offset := 1;
     l_amt := length(x_description);
     DBMS_LOB.write(l_clob, l_amt, l_offset, x_description);

  END IF;

  Update_Row(
    X_ELEMENT_ID        => x_element_id,
    X_ELEMENT_NUMBER    => x_element_number,
    X_ELEMENT_TYPE_ID   => x_element_type_id,
    X_ELEMENT_NAME      => NULL,
    X_GROUP_FLAG        => NULL,
    X_STATUS            => x_status,
    X_ACCESS_LEVEL      => x_access_level,
    X_NAME              => x_name,
    X_DESCRIPTION       => l_clob,
    X_LAST_UPDATE_DATE  => SYSDATE,
    X_LAST_UPDATED_BY   => l_user_id,
    X_LAST_UPDATE_LOGIN => 0,
    X_LOCKED_BY         => null,
    X_LOCK_DATE         => null);

 EXCEPTION
   WHEN NO_DATA_FOUND THEN
     Insert_Row(
       		x_rowid             => l_rowid,
            x_element_id        => x_element_id,
            x_element_number    => x_element_number,
            x_element_type_id   => x_element_type_id,
            x_element_name      => NULL,
            x_group_flag        => NULL,
            x_status            => x_status,
            x_access_level      => x_access_level,
            x_name              => x_name,
            x_description       => l_clob,
    		x_creation_date     => SYSDATE,
    		x_created_by        => l_user_id,
    		x_last_update_date  => SYSDATE,
    		x_last_updated_by   => l_user_id,
    		x_last_update_login => 0,
            x_locked_by         => NULL,
            x_lock_date         => NULL);

     IF(x_description IS NOT NULL) THEN
       DBMS_LOB.freetemporary(l_clob);
     END IF;

 END Load_Row;

-- 13-Jan-2004 MK
-- Added api back as required by import program
 PROCEDURE Update_Clobs(
   P_ELEMENT_ID IN NUMBER)
 IS
  l_srclen integer :=0;
  l_destlen integer :=0;
  l_clob clob;

  l_sysdate  DATE := sysdate;
  l_user_id  NUMBER(15) := fnd_global.user_id;
  l_login_id NUMBER(15) := fnd_global.login_id;

  CURSOR C_TL IS
   SELECT
     description
   FROM CS_KB_ELEMENTS_TL
   WHERE element_id = p_element_id
   AND userenv('LANG') = SOURCE_LANG
   AND userenv('LANG') <> LANGUAGE
   FOR UPDATE;

  CURSOR c_desc IS
   SELECT description
   FROM cs_kb_elements_tl
   WHERE element_id = p_element_id
   AND language = userenv('LANG');
 BEGIN

  OPEN  c_desc;
  FETCH c_desc INTO l_clob;
  CLOSE c_desc;

  IF (sql%notfound) THEN
    RETURN;
  END IF;

  UPDATE CS_KB_ELEMENTS_TL SET
    description       = EMPTY_CLOB() ,
    last_update_date  = l_sysdate,
    last_updated_by   = l_user_id,
    last_update_login = l_login_id
  WHERE element_id = p_element_id
  AND userenv('LANG') = SOURCE_LANG
  AND userenv('LANG') <> LANGUAGE;

  FOR recTL IN C_TL LOOP
    l_srclen := 0;
    IF (l_clob IS NOT NULL AND

      dbms_lob.getlength(l_clob)>0) THEN
      l_srclen := dbms_lob.getlength(l_clob);
      dbms_lob.copy(recTL.description, l_clob, l_srclen, 1,1);

    END IF;

  END LOOP;

 END Update_Clobs;

END CS_KB_ELEMENTS_PKG;

/
