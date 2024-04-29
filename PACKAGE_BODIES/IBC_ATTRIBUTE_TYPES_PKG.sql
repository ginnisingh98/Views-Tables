--------------------------------------------------------
--  DDL for Package Body IBC_ATTRIBUTE_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBC_ATTRIBUTE_TYPES_PKG" AS
/* $Header: ibctattb.pls 120.4 2006/06/22 09:19:19 sharma ship $*/

-- Purpose: Table Handler for Ibc_Attribute_Types_b table.

-- MODIFICATION HISTORY
-- Person            Date        Comments
-- ---------         ------      ------------------------------------------
-- Sri Rangarajan    01/06/2002      Created Package
-- shitij.vatsa      11/04/2002      Updated for FND_API.G_MISS_XXX
-- vicho             11/13/2002      Added Overloaded procedures for OA UI
-- Subir Anshumali   06/03/2005      Declared OUT and IN OUT arguments as references using the NOCOPY hint
-- Sharma	     07/04/2005  Modified LOAD_ROW, TRANSLATE_ROW and created
--				 LOAD_SEED_ROW for R12 LCT standards bug 4411674

PROCEDURE insert_row (
 x_rowid OUT NOCOPY VARCHAR2
,p_attribute_type_code             IN VARCHAR2
,p_content_type_code               IN VARCHAR2
,p_data_type_code                  IN VARCHAR2
,p_data_length                     IN NUMBER
,p_min_instances                   IN NUMBER
,p_max_instances                   IN NUMBER
,p_reference_code                  IN VARCHAR2
,p_default_value                   IN VARCHAR2
,p_updateable_flag                 IN VARCHAR2
,p_object_version_number           IN NUMBER
,p_attribute_type_name             IN VARCHAR2
,p_description                     IN VARCHAR2
,p_creation_date                   IN DATE          --DEFAULT NULL
,p_created_by                      IN NUMBER        --DEFAULT NULL
,p_last_update_date                IN DATE          --DEFAULT NULL
,p_last_updated_by                 IN NUMBER        --DEFAULT NULL
,p_last_update_login               IN NUMBER        --DEFAULT NULL
,p_display_order                   IN NUMBER
,p_flex_value_set_id               IN NUMBER
) IS
  CURSOR c IS SELECT ROWID FROM ibc_attribute_types_b
    WHERE attribute_type_code = p_attribute_type_code
    AND content_type_code = p_content_type_code
    ;
BEGIN
  INSERT INTO ibc_attribute_types_b (
     attribute_type_code
    ,content_type_code
    ,data_type_code
    ,data_length
    ,min_instances
    ,max_instances
    ,reference_code
    ,default_value
    ,updateable_flag
    ,object_version_number
    ,creation_date
    ,created_by
    ,last_update_date
    ,last_updated_by
    ,last_update_login
    ,display_order
    ,flex_value_set_id
  ) VALUES (
     p_attribute_type_code
    ,p_content_type_code
    ,p_data_type_code
    ,DECODE(p_data_length,FND_API.G_MISS_NUM,NULL,p_data_length)
    ,DECODE(p_min_instances,FND_API.G_MISS_NUM,NULL,p_min_instances)
    ,DECODE(p_max_instances,FND_API.G_MISS_NUM,NULL,p_max_instances)
    ,DECODE(p_reference_code,FND_API.G_MISS_CHAR,NULL,p_reference_code)
    ,DECODE(p_default_value,FND_API.G_MISS_CHAR,NULL,p_default_value)
    ,DECODE(p_updateable_flag,FND_API.G_MISS_CHAR,NULL,p_updateable_flag)
    ,DECODE(p_object_version_number,FND_API.G_MISS_NUM,1,NULL,1,p_object_version_number)
    ,DECODE(p_creation_date,FND_API.G_MISS_DATE,SYSDATE,NULL,SYSDATE,p_creation_date)
    ,DECODE(p_created_by,FND_API.G_MISS_NUM,FND_GLOBAL.user_id,NULL,FND_GLOBAL.user_id,p_created_by)
    ,DECODE(p_last_update_date,FND_API.G_MISS_DATE,SYSDATE,NULL,SYSDATE,p_last_update_date)
    ,DECODE(p_last_updated_by,FND_API.G_MISS_NUM,FND_GLOBAL.user_id,NULL,FND_GLOBAL.user_id,p_last_updated_by)
    ,DECODE(p_last_update_login,FND_API.G_MISS_NUM,FND_GLOBAL.login_id,NULL,FND_GLOBAL.user_id,p_last_update_login)
    ,DECODE(p_display_order,FND_API.G_MISS_NUM,NULL,p_display_order)
    ,DECODE(p_flex_value_set_id,FND_API.G_MISS_NUM,NULL,p_flex_value_set_id)
   );

  INSERT INTO ibc_attribute_types_tl (
     attribute_type_code
    ,content_type_code
    ,attribute_type_name
    ,description
    ,creation_date
    ,created_by
    ,last_update_date
    ,last_updated_by
    ,last_update_login
    ,language
    ,source_lang
  ) SELECT
     p_attribute_type_code
    ,p_content_type_code
    ,p_attribute_type_name
    ,DECODE(p_description,FND_API.G_MISS_CHAR,NULL,p_description)
    ,DECODE(p_creation_date,FND_API.G_MISS_DATE,SYSDATE,NULL,SYSDATE,p_creation_date)
    ,DECODE(p_created_by,FND_API.G_MISS_NUM,FND_GLOBAL.user_id,NULL,FND_GLOBAL.user_id,p_created_by)
    ,DECODE(p_last_update_date,FND_API.G_MISS_DATE,SYSDATE,NULL,SYSDATE,p_last_update_date)
    ,DECODE(p_last_updated_by,FND_API.G_MISS_NUM,FND_GLOBAL.user_id,NULL,FND_GLOBAL.user_id,p_last_updated_by)
    ,DECODE(p_last_update_login,FND_API.G_MISS_NUM,FND_GLOBAL.login_id,NULL,FND_GLOBAL.user_id,p_last_update_login)
    ,l.language_code
    ,USERENV('lang')
  FROM fnd_languages l
  WHERE l.installed_flag IN ('I', 'B')
  AND NOT EXISTS
    (SELECT NULL
    FROM ibc_attribute_types_tl T
    WHERE T.attribute_type_code = p_attribute_type_code
    AND T.content_type_code = p_content_type_code
    AND T.LANGUAGE = l.language_code);

  OPEN c;
  FETCH c INTO x_rowid;
  IF (c%NOTFOUND) THEN
    CLOSE c;
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE c;

END insert_row;

PROCEDURE lock_row (
  p_attribute_type_code IN VARCHAR2,
  p_content_type_code IN VARCHAR2,
  p_data_type_code IN VARCHAR2,
  p_data_length IN NUMBER,
  p_min_instances IN NUMBER,
  p_max_instances IN NUMBER,
  p_reference_code IN VARCHAR2,
  p_default_value IN VARCHAR2,
  p_updateable_flag IN VARCHAR2,
  p_object_version_number IN NUMBER,
  p_attribute_type_name IN VARCHAR2,
  p_description IN VARCHAR2
) IS
  CURSOR c IS SELECT
      data_type_code,
      data_length,
      min_instances,
      max_instances,
      reference_code,
      default_value,
      updateable_flag,
      object_version_number
    FROM ibc_attribute_types_b
    WHERE attribute_type_code = p_attribute_type_code
    AND content_type_code = p_content_type_code
    FOR UPDATE OF attribute_type_code NOWAIT;
  recinfo c%ROWTYPE;

  CURSOR c1 IS SELECT
      attribute_type_name,
      description,
      DECODE(LANGUAGE, USERENV('lang'), 'y', 'n') baselang
    FROM ibc_attribute_types_tl
    WHERE attribute_type_code = p_attribute_type_code
    AND content_type_code = p_content_type_code
    AND USERENV('lang') IN (LANGUAGE, source_lang)
    FOR UPDATE OF attribute_type_code NOWAIT;
BEGIN
  OPEN c;
  FETCH c INTO recinfo;
  IF (c%NOTFOUND) THEN
    CLOSE c;
    fnd_message.set_name('fnd', 'form_record_deleted');
    app_exception.raise_exception;
  END IF;
  CLOSE c;
  IF (    (recinfo.data_type_code = p_data_type_code)
      AND ((recinfo.data_length = p_data_length)
           OR ((recinfo.data_length IS NULL) AND (p_data_length IS NULL)))
      AND (recinfo.min_instances = p_min_instances)
      AND (recinfo.max_instances = p_max_instances)
      AND ((recinfo.reference_code = p_reference_code)
           OR ((recinfo.reference_code IS NULL) AND (p_reference_code IS NULL)))
      AND ((recinfo.default_value = p_default_value)
           OR ((recinfo.default_value IS NULL) AND (p_default_value IS NULL)))
      AND ((recinfo.updateable_flag = p_updateable_flag)
           OR ((recinfo.updateable_flag IS NULL) AND (p_updateable_flag IS NULL)))
      AND (recinfo.object_version_number = p_object_version_number)

  ) THEN
    NULL;
  ELSE
    fnd_message.set_name('fnd', 'form_record_changed');
    app_exception.raise_exception;
  END IF;

  FOR tlinfo IN c1 LOOP
    IF (tlinfo.baselang = 'y') THEN
      IF (    (tlinfo.attribute_type_name = p_attribute_type_name)
          AND ((tlinfo.description = p_description)
               OR ((tlinfo.description IS NULL) AND (p_description IS NULL)))
      ) THEN
        NULL;
      ELSE
        fnd_message.set_name('fnd', 'form_record_changed');
        app_exception.raise_exception;
      END IF;
    END IF;
  END LOOP;
  RETURN;
END lock_row;

PROCEDURE update_row (
 p_attribute_type_code             IN VARCHAR2
,p_attribute_type_name             IN VARCHAR2      --DEFAULT NULL
,p_content_type_code               IN VARCHAR2
,p_data_length                     IN NUMBER        --DEFAULT NULL
,p_data_type_code                  IN VARCHAR2      --DEFAULT NULL
,p_default_value                   IN VARCHAR2      --DEFAULT NULL
,p_description                     IN VARCHAR2      --DEFAULT NULL
,p_last_updated_by                 IN NUMBER        --DEFAULT NULL
,p_last_update_date                IN DATE          --DEFAULT NULL
,p_last_update_login               IN NUMBER        --DEFAULT NULL
,p_max_instances                   IN NUMBER        --DEFAULT NULL
,p_min_instances                   IN NUMBER        --DEFAULT NULL
,p_object_version_number           IN NUMBER        --DEFAULT NULL
,p_reference_code                  IN VARCHAR2      --DEFAULT NULL
,p_updateable_flag                 IN VARCHAR2      --DEFAULT NULL
,p_display_order                   IN NUMBER
,p_flex_value_set_id               IN NUMBER
)
IS
BEGIN
  UPDATE ibc_attribute_types_b SET
    content_type_code         = DECODE(p_content_type_code,FND_API.G_MISS_CHAR,NULL,NULL,content_type_code,p_content_type_code)
   ,data_type_code            = DECODE(p_data_type_code,FND_API.G_MISS_CHAR,NULL,NULL,data_type_code,p_data_type_code)
   ,data_length               = DECODE(p_data_length,FND_API.G_MISS_NUM,NULL,NULL,data_length,p_data_length)
   ,min_instances             = DECODE(p_min_instances,FND_API.G_MISS_NUM,NULL,NULL,min_instances,p_min_instances)
   ,max_instances             = DECODE(p_max_instances,FND_API.G_MISS_NUM,NULL,NULL,max_instances,p_max_instances)
   ,reference_code            = DECODE(p_reference_code,FND_API.G_MISS_CHAR,NULL,NULL,reference_code,p_reference_code)
   ,default_value             = DECODE(p_default_value,FND_API.G_MISS_CHAR,NULL,NULL,default_value,p_default_value)
   ,updateable_flag           = DECODE(p_updateable_flag,FND_API.G_MISS_CHAR,NULL,NULL,updateable_flag,p_updateable_flag)
   ,object_version_number     = NVL(object_version_number,0) + 1
   ,last_update_date          = DECODE(p_last_update_date,FND_API.G_MISS_DATE,SYSDATE,NULL,SYSDATE,p_last_update_date)
   ,last_updated_by           = DECODE(p_last_updated_by,FND_API.G_MISS_NUM,FND_GLOBAL.user_id,NULL,FND_GLOBAL.user_id,p_last_updated_by)
   ,last_update_login         = DECODE(p_last_update_login,FND_API.G_MISS_NUM,FND_GLOBAL.login_id,NULL,FND_GLOBAL.user_id,p_last_update_login)
   ,display_order             = DECODE(p_display_order,FND_API.G_MISS_NUM,NULL,NULL,display_order,p_display_order)
   ,flex_value_set_id         = DECODE(p_flex_value_set_id,FND_API.G_MISS_NUM,NULL,NULL,flex_value_set_id,p_flex_value_set_id)
  WHERE attribute_type_code = p_attribute_type_code
  AND content_type_code = p_content_type_code
  AND object_version_number = DECODE(p_object_version_number,
                                       fnd_api.g_miss_num,
                                       object_version_number,
                                       NULL,
                                       object_version_number,
                                       p_object_version_number);

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

  UPDATE ibc_attribute_types_tl SET
    attribute_type_name       = DECODE(p_attribute_type_name,FND_API.G_MISS_CHAR,NULL,NULL,attribute_type_name,p_attribute_type_name)
   ,description               = DECODE(p_description,FND_API.G_MISS_CHAR,NULL,NULL,description,p_description)
   ,last_update_date          = DECODE(p_last_update_date,FND_API.G_MISS_DATE,SYSDATE,NULL,SYSDATE,p_last_update_date)
   ,last_updated_by           = DECODE(p_last_updated_by,FND_API.G_MISS_NUM,FND_GLOBAL.user_id,NULL,FND_GLOBAL.user_id,p_last_updated_by)
   ,last_update_login         = DECODE(p_last_update_login,FND_API.G_MISS_NUM,FND_GLOBAL.login_id,NULL,FND_GLOBAL.user_id,p_last_update_login)
   ,source_lang               = USERENV('lang')
  WHERE attribute_type_code = p_attribute_type_code
  AND content_type_code = p_content_type_code
  AND USERENV('lang') IN (LANGUAGE, source_lang);

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;
END update_row;

PROCEDURE delete_row (
  p_attribute_type_code IN VARCHAR2,
  p_content_type_code IN VARCHAR2
) IS
BEGIN
  DELETE FROM ibc_attribute_types_tl
  WHERE attribute_type_code = p_attribute_type_code
  AND content_type_code = p_content_type_code;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

  DELETE FROM ibc_attribute_types_b
  WHERE attribute_type_code = p_attribute_type_code
  AND content_type_code = p_content_type_code;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;
END delete_row;

--
-- Overloaded Delete to delete all the content Types
--

PROCEDURE delete_rows (
  p_content_type_code IN VARCHAR2
) IS
BEGIN
  DELETE FROM ibc_attribute_types_tl
  WHERE attribute_type_code = attribute_type_code
  AND content_type_code = p_content_type_code;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

  DELETE FROM ibc_attribute_types_b
  WHERE attribute_type_code = attribute_type_code
  AND content_type_code = p_content_type_code;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;
END delete_rows;

PROCEDURE add_language
IS
BEGIN
  DELETE FROM ibc_attribute_types_tl T
  WHERE NOT EXISTS
    (SELECT NULL
    FROM ibc_attribute_types_b b
    WHERE b.attribute_type_code = T.attribute_type_code
    AND b.content_type_code = T.content_type_code
    );

  UPDATE ibc_attribute_types_tl T SET (
      attribute_type_name,
      description
    ) = (SELECT
      b.attribute_type_name,
      b.description
    FROM ibc_attribute_types_tl b
    WHERE b.attribute_type_code = T.attribute_type_code
    AND b.content_type_code = T.content_type_code
    AND b.LANGUAGE = T.source_lang)
  WHERE (
      T.attribute_type_code,
      T.content_type_code,
      T.LANGUAGE
  ) IN (SELECT
      subt.attribute_type_code,
      subt.content_type_code,
      subt.LANGUAGE
    FROM ibc_attribute_types_tl subb, ibc_attribute_types_tl subt
    WHERE subb.attribute_type_code = subt.attribute_type_code
    AND subb.content_type_code = subt.content_type_code
    AND subb.LANGUAGE = subt.source_lang
    AND (subb.attribute_type_name <> subt.attribute_type_name
      OR subb.description <> subt.description
      OR (subb.description IS NULL AND subt.description IS NOT NULL)
      OR (subb.description IS NOT NULL AND subt.description IS NULL)
  ));

  INSERT INTO ibc_attribute_types_tl (
    attribute_type_code,
    content_type_code,
    attribute_type_name,
    description,
    created_by,
    creation_date,
    last_updated_by,
    last_update_date,
    last_update_login,
    LANGUAGE,
    source_lang
  ) SELECT
    b.attribute_type_code,
    b.content_type_code,
    b.attribute_type_name,
    b.description,
    b.created_by,
    b.creation_date,
    b.last_updated_by,
    b.last_update_date,
    b.last_update_login,
    l.language_code,
    b.source_lang
  FROM ibc_attribute_types_tl b, fnd_languages l
  WHERE l.installed_flag IN ('I', 'B')
  AND b.LANGUAGE = USERENV('lang')
  AND NOT EXISTS
    (SELECT NULL
    FROM ibc_attribute_types_tl T
    WHERE T.attribute_type_code = b.attribute_type_code
    AND T.content_type_code = b.content_type_code
    AND T.LANGUAGE = l.language_code);
END add_language;

PROCEDURE LOAD_SEED_ROW (
 p_upload_mode			   IN VARCHAR2,
 p_attribute_type_code             IN VARCHAR2
,p_content_type_code               IN VARCHAR2
,p_data_type_code                  IN VARCHAR2
,p_data_length                     IN NUMBER
,p_min_instances                   IN NUMBER
,p_max_instances                   IN NUMBER
,p_reference_code                  IN VARCHAR2
,p_default_value                   IN VARCHAR2
,p_updateable_flag                 IN VARCHAR2
,p_attribute_type_name             IN VARCHAR2
,p_description                     IN VARCHAR2
,p_owner                           IN VARCHAR2
,p_display_order		   IN NUMBER	    DEFAULT NULL
,p_flex_value_set_id		   IN NUMBER	    DEFAULT NULL,
 p_last_update_date IN VARCHAR2 ) IS

 BEGIN
	IF (p_upload_mode = 'NLS') THEN
		IBC_ATTRIBUTE_TYPES_PKG.TRANSLATE_ROW (
		p_upload_mode => p_upload_mode,
		p_content_type_code  	=> p_content_type_code,
		p_attribute_type_code	=> p_attribute_type_code,
		p_attribute_type_name	=> p_attribute_type_name,
		p_description		=> p_description,
		p_owner			=> p_owner,
		p_last_update_date => p_last_update_date);
	ELSE
		IBC_ATTRIBUTE_TYPES_PKG.LOAD_ROW (
		p_upload_mode => p_upload_mode,
		p_attribute_type_code	=> p_attribute_type_code,
		p_content_type_code	=> p_content_type_code,
		p_data_type_code	=>p_data_type_code,
		p_data_length		=>TO_NUMBER(p_data_length),
		p_min_instances		=>TO_NUMBER(p_min_instances),
		p_max_instances		=>TO_NUMBER(p_max_instances),
		p_reference_code	=>p_reference_code,
		p_default_value		=>p_default_value,
		p_updateable_flag	=>p_updateable_flag,
		p_attribute_type_name	=>p_attribute_type_name,
		p_description		=>p_description,
		p_owner			=>p_owner,
		p_display_order		=>p_display_order,
		p_flex_value_set_id	=>p_flex_value_set_id,
		p_last_update_date => p_last_update_date);
	END IF;

 END;


PROCEDURE LOAD_ROW (
  p_upload_mode IN VARCHAR2,
  p_attribute_type_code IN VARCHAR2,
  p_content_type_code IN VARCHAR2,
  p_data_type_code IN VARCHAR2,
  p_data_length IN NUMBER,
  p_min_instances IN NUMBER,
  p_max_instances IN NUMBER,
  p_reference_code IN VARCHAR2,
  p_default_value IN VARCHAR2,
  p_updateable_flag IN VARCHAR2,
  p_attribute_type_name IN VARCHAR2,
  p_description IN VARCHAR2,
  p_OWNER IN VARCHAR2,
  p_display_order                  IN NUMBER,
  p_flex_value_set_id              IN NUMBER,
   p_last_update_date IN VARCHAR2 ) IS
BEGIN
  DECLARE
    l_user_id    NUMBER := 0;
    l_row_id     VARCHAR2(64);
    l_last_update_date DATE;

    db_user_id    NUMBER := 0;
    db_last_update_date DATE;
  BEGIN
	--get last updated by user id
	l_user_id := FND_LOAD_UTIL.OWNER_ID(p_OWNER);

	--translate data type VARCHAR2 to DATE for last_update_date
	l_last_update_date := nvl(TO_DATE(p_last_update_date, 'YYYY/MM/DD'),SYSDATE);

	-- get updatedby  and update_date values if existing in db
	SELECT LAST_UPDATED_BY, LAST_UPDATE_DATE INTO db_user_id, db_last_update_date
	FROM ibc_attribute_types_b
        WHERE attribute_type_code = p_attribute_type_code
	AND content_type_code = p_content_type_code
	AND object_version_number = DECODE(object_version_number,
					       fnd_api.g_miss_num,
					       object_version_number,
					       NULL,
					       object_version_number,
					       object_version_number);

	IF (FND_LOAD_UTIL.UPLOAD_TEST(l_user_id, l_last_update_date,
		db_user_id, db_last_update_date, p_upload_mode )) THEN

		Ibc_Attribute_Types_Pkg.Update_row (
			p_attribute_type_code          => NVL(p_attribute_type_code,FND_API.G_MISS_CHAR)
		       ,p_content_type_code            => NVL(p_content_type_code,FND_API.G_MISS_CHAR)
		       ,p_data_type_code               => NVL(p_data_type_code,FND_API.G_MISS_CHAR)
		       ,p_data_length                  => NVL(p_data_length,FND_API.G_MISS_NUM)
		       ,p_min_instances                => NVL(p_min_instances,FND_API.G_MISS_NUM)
		       ,p_max_instances                => NVL(p_max_instances,FND_API.G_MISS_NUM)
		       ,p_reference_code               => NVL(p_reference_code,FND_API.G_MISS_CHAR)
		       ,p_default_value                => NVL(p_default_value,FND_API.G_MISS_CHAR)
		       ,p_updateable_flag              => NVL(p_updateable_flag,FND_API.G_MISS_CHAR)
		       ,p_object_version_number        => NULL
		       ,p_attribute_type_name          => NVL(p_attribute_type_name,FND_API.G_MISS_CHAR)
		       ,p_description                  => NVL(p_description,FND_API.G_MISS_CHAR)
		       ,p_last_update_date             => l_last_update_date
		       ,p_last_updated_by              => l_user_id
		       ,p_last_update_login            => 0
		       ,p_display_order                => NVL(p_display_order,FND_API.G_MISS_NUM)
		       ,p_flex_value_set_id            => NVL(p_flex_value_set_id,FND_API.G_MISS_NUM)
		       );
	END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN

        Ibc_Attribute_Types_Pkg.insert_row (
              x_rowid                    =>l_row_id,
              p_attribute_type_code      =>p_attribute_type_code,
              p_content_type_code        =>p_content_type_code,
              p_data_type_code           =>p_data_type_code,
              p_data_length              =>p_data_length,
              p_min_instances            =>p_min_instances,
              p_max_instances            =>p_max_instances,
              p_reference_code           =>p_reference_code,
              p_default_value            =>p_default_value,
              p_updateable_flag          =>p_updateable_flag,
              p_object_version_number    =>FND_API.G_MISS_NUM,
              p_attribute_type_name      =>p_attribute_type_name,
              p_description              =>p_description,
              p_creation_date            =>l_last_update_date,
              p_created_by               =>l_user_id,
              p_last_update_date         =>l_last_update_date,
              p_last_updated_by          =>l_user_id,
              p_last_update_login        =>0,
              p_display_order            => p_display_order,
              p_flex_value_set_id        => p_flex_value_set_id
            );
   END;
END LOAD_ROW;

PROCEDURE TRANSLATE_ROW (
  p_upload_mode IN VARCHAR2,
  p_CONTENT_TYPE_CODE    IN  VARCHAR2,
  p_ATTRIBUTE_TYPE_CODE  IN  VARCHAR2,
  p_ATTRIBUTE_TYPE_NAME  IN  VARCHAR2,
  p_DESCRIPTION    IN  VARCHAR2,
  p_OWNER IN VARCHAR2,
  p_last_update_date IN VARCHAR2 ) IS

    l_user_id    NUMBER := 0;
    l_row_id     VARCHAR2(64);
    l_last_update_date DATE;

    db_user_id    NUMBER := 0;
    db_last_update_date DATE;
BEGIN
	--get last updated by user id
	l_user_id := FND_LOAD_UTIL.OWNER_ID(p_OWNER);

	--translate data type VARCHAR2 to DATE for last_update_date
	l_last_update_date := nvl(TO_DATE(p_last_update_date, 'YYYY/MM/DD'),SYSDATE);

	-- get updatedby  and update_date values if existing in db
	SELECT LAST_UPDATED_BY, LAST_UPDATE_DATE INTO db_user_id, db_last_update_date
	FROM IBC_ATTRIBUTE_TYPES_TL
	WHERE CONTENT_TYPE_CODE = p_CONTENT_TYPE_CODE
	AND     ATTRIBUTE_TYPE_CODE = p_ATTRIBUTE_TYPE_CODE
	AND USERENV('LANG') IN (LANGUAGE, source_lang);

	IF (FND_LOAD_UTIL.UPLOAD_TEST(l_user_id, l_last_update_date,
		db_user_id, db_last_update_date, p_upload_mode )) THEN
		  -- Only update rows which have not been altered by user
		  UPDATE IBC_ATTRIBUTE_TYPES_TL
		  SET description = p_DESCRIPTION,
		      ATTRIBUTE_TYPE_NAME = p_ATTRIBUTE_TYPE_NAME,
		      source_lang = USERENV('LANG'),
		      last_update_date = l_last_update_date,
		      last_updated_by = l_user_id,
		      last_update_login = 0
		  WHERE CONTENT_TYPE_CODE = p_CONTENT_TYPE_CODE
			AND     ATTRIBUTE_TYPE_CODE = p_ATTRIBUTE_TYPE_CODE
		    AND USERENV('LANG') IN (LANGUAGE, source_lang);
	END IF;

END TRANSLATE_ROW;


--
-- Overloaded Procedures for OA Content Type UI
--
PROCEDURE INSERT_ROW (
  X_ROWID IN OUT NOCOPY VARCHAR2,
  X_CONTENT_TYPE_CODE IN VARCHAR2,
  X_ATTRIBUTE_TYPE_CODE IN VARCHAR2,
  X_MIN_INSTANCES IN NUMBER,
  X_MAX_INSTANCES IN NUMBER,
  X_DEFAULT_VALUE IN VARCHAR2,
  X_UPDATEABLE_FLAG IN VARCHAR2,
  X_REFERENCE_CODE IN VARCHAR2,
  X_OBJECT_VERSION_NUMBER IN NUMBER,
  X_SECURITY_GROUP_ID IN NUMBER,
  X_DISPLAY_ORDER IN NUMBER,
  X_FLEX_VALUE_SET_ID IN NUMBER,
  X_DATA_TYPE_CODE IN VARCHAR2,
  X_DATA_LENGTH IN NUMBER,
  X_ATTRIBUTE_TYPE_NAME IN VARCHAR2,
  X_DESCRIPTION IN VARCHAR2,
  X_CREATION_DATE IN DATE,
  X_CREATED_BY IN NUMBER,
  X_LAST_UPDATE_DATE IN DATE,
  X_LAST_UPDATED_BY IN NUMBER,
  X_LAST_UPDATE_LOGIN IN NUMBER
) IS
  CURSOR C IS SELECT ROWID FROM IBC_ATTRIBUTE_TYPES_B
    WHERE CONTENT_TYPE_CODE = X_CONTENT_TYPE_CODE
    AND ATTRIBUTE_TYPE_CODE = X_ATTRIBUTE_TYPE_CODE
    ;
BEGIN
  INSERT INTO IBC_ATTRIBUTE_TYPES_B (
    MIN_INSTANCES,
    MAX_INSTANCES,
    DEFAULT_VALUE,
    UPDATEABLE_FLAG,
    REFERENCE_CODE,
    OBJECT_VERSION_NUMBER,
    SECURITY_GROUP_ID,
    DISPLAY_ORDER,
    ATTRIBUTE_TYPE_CODE,
    CONTENT_TYPE_CODE,
    FLEX_VALUE_SET_ID,
    DATA_TYPE_CODE,
    DATA_LENGTH,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) VALUES (
    X_MIN_INSTANCES,
    X_MAX_INSTANCES,
    X_DEFAULT_VALUE,
    X_UPDATEABLE_FLAG,
    X_REFERENCE_CODE,
    X_OBJECT_VERSION_NUMBER,
    X_SECURITY_GROUP_ID,
    X_DISPLAY_ORDER,
    X_ATTRIBUTE_TYPE_CODE,
    X_CONTENT_TYPE_CODE,
    X_FLEX_VALUE_SET_ID,
    X_DATA_TYPE_CODE,
    X_DATA_LENGTH,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  INSERT INTO IBC_ATTRIBUTE_TYPES_TL (
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    SECURITY_GROUP_ID,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    ATTRIBUTE_TYPE_CODE,
    CONTENT_TYPE_CODE,
    ATTRIBUTE_TYPE_NAME,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) SELECT
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    X_SECURITY_GROUP_ID,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_ATTRIBUTE_TYPE_CODE,
    X_CONTENT_TYPE_CODE,
    X_ATTRIBUTE_TYPE_NAME,
    X_DESCRIPTION,
    L.LANGUAGE_CODE,
    USERENV('LANG')
  FROM FND_LANGUAGES L
  WHERE L.INSTALLED_FLAG IN ('I', 'B')
  AND NOT EXISTS
    (SELECT NULL
    FROM IBC_ATTRIBUTE_TYPES_TL T
    WHERE T.CONTENT_TYPE_CODE = X_CONTENT_TYPE_CODE
    AND T.ATTRIBUTE_TYPE_CODE = X_ATTRIBUTE_TYPE_CODE
    AND T.LANGUAGE = L.LANGUAGE_CODE);

  OPEN c;
  FETCH c INTO X_ROWID;
  IF (c%NOTFOUND) THEN
    CLOSE c;
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE c;

END INSERT_ROW;

PROCEDURE LOCK_ROW (
  X_CONTENT_TYPE_CODE IN VARCHAR2,
  X_ATTRIBUTE_TYPE_CODE IN VARCHAR2,
  X_MIN_INSTANCES IN NUMBER,
  X_MAX_INSTANCES IN NUMBER,
  X_DEFAULT_VALUE IN VARCHAR2,
  X_UPDATEABLE_FLAG IN VARCHAR2,
  X_REFERENCE_CODE IN VARCHAR2,
  X_OBJECT_VERSION_NUMBER IN NUMBER,
  X_SECURITY_GROUP_ID IN NUMBER,
  X_DISPLAY_ORDER IN NUMBER,
  X_FLEX_VALUE_SET_ID IN NUMBER,
  X_DATA_TYPE_CODE IN VARCHAR2,
  X_DATA_LENGTH IN NUMBER,
  X_ATTRIBUTE_TYPE_NAME IN VARCHAR2,
  X_DESCRIPTION IN VARCHAR2
) IS
  CURSOR c IS SELECT
      MIN_INSTANCES,
      MAX_INSTANCES,
      DEFAULT_VALUE,
      UPDATEABLE_FLAG,
      REFERENCE_CODE,
      OBJECT_VERSION_NUMBER,
      SECURITY_GROUP_ID,
      DISPLAY_ORDER,
      FLEX_VALUE_SET_ID,
      DATA_TYPE_CODE,
      DATA_LENGTH
    FROM IBC_ATTRIBUTE_TYPES_B
    WHERE CONTENT_TYPE_CODE = X_CONTENT_TYPE_CODE
    AND ATTRIBUTE_TYPE_CODE = X_ATTRIBUTE_TYPE_CODE
    FOR UPDATE OF CONTENT_TYPE_CODE NOWAIT;
  recinfo c%ROWTYPE;

  CURSOR c1 IS SELECT
      ATTRIBUTE_TYPE_NAME,
      DESCRIPTION,
      DECODE(LANGUAGE, USERENV('LANG'), 'Y', 'N') BASELANG
    FROM IBC_ATTRIBUTE_TYPES_TL
    WHERE CONTENT_TYPE_CODE = X_CONTENT_TYPE_CODE
    AND ATTRIBUTE_TYPE_CODE = X_ATTRIBUTE_TYPE_CODE
    AND USERENV('LANG') IN (LANGUAGE, SOURCE_LANG)
    FOR UPDATE OF CONTENT_TYPE_CODE NOWAIT;
BEGIN
  OPEN c;
  FETCH c INTO recinfo;
  IF (c%NOTFOUND) THEN
    CLOSE c;
    Fnd_Message.set_name('FND', 'FORM_RECORD_DELETED');
    App_Exception.raise_exception;
  END IF;
  CLOSE c;
  IF (    (recinfo.MIN_INSTANCES = X_MIN_INSTANCES)
      AND ((recinfo.MAX_INSTANCES = X_MAX_INSTANCES)
           OR ((recinfo.MAX_INSTANCES IS NULL) AND (X_MAX_INSTANCES IS NULL)))
      AND ((recinfo.DEFAULT_VALUE = X_DEFAULT_VALUE)
           OR ((recinfo.DEFAULT_VALUE IS NULL) AND (X_DEFAULT_VALUE IS NULL)))
      AND (recinfo.UPDATEABLE_FLAG = X_UPDATEABLE_FLAG)
      AND ((recinfo.REFERENCE_CODE = X_REFERENCE_CODE)
           OR ((recinfo.REFERENCE_CODE IS NULL) AND (X_REFERENCE_CODE IS NULL)))
      AND (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
      AND ((recinfo.SECURITY_GROUP_ID = X_SECURITY_GROUP_ID)
           OR ((recinfo.SECURITY_GROUP_ID IS NULL) AND (X_SECURITY_GROUP_ID IS NULL)))
      AND ((recinfo.DISPLAY_ORDER = X_DISPLAY_ORDER)
           OR ((recinfo.DISPLAY_ORDER IS NULL) AND (X_DISPLAY_ORDER IS NULL)))
      AND ((recinfo.FLEX_VALUE_SET_ID = X_FLEX_VALUE_SET_ID)
           OR ((recinfo.FLEX_VALUE_SET_ID IS NULL) AND (X_FLEX_VALUE_SET_ID IS NULL)))
      AND (recinfo.DATA_TYPE_CODE = X_DATA_TYPE_CODE)
      AND ((recinfo.DATA_LENGTH = X_DATA_LENGTH)
           OR ((recinfo.DATA_LENGTH IS NULL) AND (X_DATA_LENGTH IS NULL)))
  ) THEN
    NULL;
  ELSE
    Fnd_Message.set_name('FND', 'FORM_RECORD_CHANGED');
    App_Exception.raise_exception;
  END IF;

  FOR tlinfo IN c1 LOOP
    IF (tlinfo.BASELANG = 'Y') THEN
      IF (    (tlinfo.ATTRIBUTE_TYPE_NAME = X_ATTRIBUTE_TYPE_NAME)
          AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
               OR ((tlinfo.DESCRIPTION IS NULL) AND (X_DESCRIPTION IS NULL)))
      ) THEN
        NULL;
      ELSE
        Fnd_Message.set_name('FND', 'FORM_RECORD_CHANGED');
        App_Exception.raise_exception;
      END IF;
    END IF;
  END LOOP;
  RETURN;
END LOCK_ROW;

PROCEDURE UPDATE_ROW (
  X_CONTENT_TYPE_CODE IN VARCHAR2,
  X_ATTRIBUTE_TYPE_CODE IN VARCHAR2,
  X_MIN_INSTANCES IN NUMBER,
  X_MAX_INSTANCES IN NUMBER,
  X_DEFAULT_VALUE IN VARCHAR2,
  X_UPDATEABLE_FLAG IN VARCHAR2,
  X_REFERENCE_CODE IN VARCHAR2,
  X_OBJECT_VERSION_NUMBER IN NUMBER,
  X_SECURITY_GROUP_ID IN NUMBER,
  X_DISPLAY_ORDER IN NUMBER,
  X_FLEX_VALUE_SET_ID IN NUMBER,
  X_DATA_TYPE_CODE IN VARCHAR2,
  X_DATA_LENGTH IN NUMBER,
  X_ATTRIBUTE_TYPE_NAME IN VARCHAR2,
  X_DESCRIPTION IN VARCHAR2,
  X_LAST_UPDATE_DATE IN DATE,
  X_LAST_UPDATED_BY IN NUMBER,
  X_LAST_UPDATE_LOGIN IN NUMBER
) IS
BEGIN
  UPDATE IBC_ATTRIBUTE_TYPES_B SET
    MIN_INSTANCES = X_MIN_INSTANCES,
    MAX_INSTANCES = X_MAX_INSTANCES,
    DEFAULT_VALUE = X_DEFAULT_VALUE,
    UPDATEABLE_FLAG = X_UPDATEABLE_FLAG,
    REFERENCE_CODE = X_REFERENCE_CODE,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    SECURITY_GROUP_ID = X_SECURITY_GROUP_ID,
    DISPLAY_ORDER = X_DISPLAY_ORDER,
    FLEX_VALUE_SET_ID = X_FLEX_VALUE_SET_ID,
    DATA_TYPE_CODE = X_DATA_TYPE_CODE,
    DATA_LENGTH = X_DATA_LENGTH,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  WHERE CONTENT_TYPE_CODE = X_CONTENT_TYPE_CODE
  AND ATTRIBUTE_TYPE_CODE = X_ATTRIBUTE_TYPE_CODE;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

  UPDATE IBC_ATTRIBUTE_TYPES_TL SET
    ATTRIBUTE_TYPE_NAME = X_ATTRIBUTE_TYPE_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = USERENV('LANG')
  WHERE CONTENT_TYPE_CODE = X_CONTENT_TYPE_CODE
  AND ATTRIBUTE_TYPE_CODE = X_ATTRIBUTE_TYPE_CODE
  AND USERENV('LANG') IN (LANGUAGE, SOURCE_LANG);

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;
END UPDATE_ROW;

PROCEDURE DELETE_ROW (
  X_CONTENT_TYPE_CODE IN VARCHAR2,
  X_ATTRIBUTE_TYPE_CODE IN VARCHAR2
) IS
BEGIN
  DELETE FROM IBC_ATTRIBUTE_TYPES_TL
  WHERE CONTENT_TYPE_CODE = X_CONTENT_TYPE_CODE
  AND ATTRIBUTE_TYPE_CODE = X_ATTRIBUTE_TYPE_CODE;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

  DELETE FROM IBC_ATTRIBUTE_TYPES_B
  WHERE CONTENT_TYPE_CODE = X_CONTENT_TYPE_CODE
  AND ATTRIBUTE_TYPE_CODE = X_ATTRIBUTE_TYPE_CODE;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;
END DELETE_ROW;


END Ibc_Attribute_Types_Pkg;

/
