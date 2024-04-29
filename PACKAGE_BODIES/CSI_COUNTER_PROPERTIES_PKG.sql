--------------------------------------------------------
--  DDL for Package Body CSI_COUNTER_PROPERTIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_COUNTER_PROPERTIES_PKG" as
/* $Header: csitcpib.pls 120.1 2008/04/03 21:52:12 devijay ship $*/

G_PKG_NAME CONSTANT VARCHAR2(30)  := 'CSI_COUNTER_PROPERTIES_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csitcpib.pls';

PROCEDURE Insert_Row(
	px_COUNTER_PROPERTY_ID             IN OUT NOCOPY NUMBER
  	,p_COUNTER_ID                      NUMBER
  	,p_PROPERTY_DATA_TYPE              VARCHAR2
  	,p_IS_NULLABLE                     VARCHAR2
  	,p_DEFAULT_VALUE                   VARCHAR2
  	,p_MINIMUM_VALUE                   VARCHAR2
  	,p_MAXIMUM_VALUE                   VARCHAR2
  	,p_UOM_CODE                        VARCHAR2
  	,p_START_DATE_ACTIVE               DATE
  	,p_END_DATE_ACTIVE                 DATE
  	,p_OBJECT_VERSION_NUMBER           NUMBER
	,p_SECURITY_GROUP_ID			   NUMBER
  	,p_LAST_UPDATE_DATE                DATE
  	,p_LAST_UPDATED_BY                 NUMBER
  	,p_CREATION_DATE                   DATE
  	,p_CREATED_BY                      NUMBER
  	,p_LAST_UPDATE_LOGIN               NUMBER
  	,p_ATTRIBUTE1                      VARCHAR2
  	,p_ATTRIBUTE2                      VARCHAR2
  	,p_ATTRIBUTE3                      VARCHAR2
  	,p_ATTRIBUTE4                      VARCHAR2
  	,p_ATTRIBUTE5                      VARCHAR2
  	,p_ATTRIBUTE6                      VARCHAR2
  	,p_ATTRIBUTE7                      VARCHAR2
  	,p_ATTRIBUTE8                      VARCHAR2
  	,p_ATTRIBUTE9                      VARCHAR2
  	,p_ATTRIBUTE10                     VARCHAR2
  	,p_ATTRIBUTE11                     VARCHAR2
  	,p_ATTRIBUTE12                     VARCHAR2
  	,p_ATTRIBUTE13                     VARCHAR2
  	,p_ATTRIBUTE14                     VARCHAR2
  	,p_ATTRIBUTE15                     VARCHAR2
  	,p_ATTRIBUTE_CATEGORY              VARCHAR2
  	,p_MIGRATED_FLAG                   VARCHAR2
  	,p_PROPERTY_LOV_TYPE               VARCHAR2
	,p_CREATE_FROM_CTR_PROP_TMPL_ID    NUMBER
        ,p_NAME	                        VARCHAR2
        ,p_DESCRIPTION                  VARCHAR2
        ) IS

	CURSOR C1 IS
	SELECT CSI_COUNTER_PROPERTIES_B_S.nextval
	FROM dual;
BEGIN
	IF (px_COUNTER_PROPERTY_ID IS NULL) OR (px_COUNTER_PROPERTY_ID = FND_API.G_MISS_NUM) THEN
		OPEN C1;
		FETCH C1 INTO px_COUNTER_PROPERTY_ID;
		CLOSE C1;
	END IF;

	INSERT INTO CSI_COUNTER_PROPERTIES_B(
		COUNTER_PROPERTY_ID
  		,COUNTER_ID
  		,PROPERTY_DATA_TYPE
  		,IS_NULLABLE
  		,DEFAULT_VALUE
  		,MINIMUM_VALUE
  		,MAXIMUM_VALUE
  		,UOM_CODE
  		,START_DATE_ACTIVE
  		,END_DATE_ACTIVE
  		,OBJECT_VERSION_NUMBER
		,SECURITY_GROUP_ID
  		,LAST_UPDATE_DATE
  		,LAST_UPDATED_BY
  		,CREATION_DATE
  		,CREATED_BY
  		,LAST_UPDATE_LOGIN
  		,ATTRIBUTE1
  		,ATTRIBUTE2
  		,ATTRIBUTE3
  		,ATTRIBUTE4
  		,ATTRIBUTE5
  		,ATTRIBUTE6
  		,ATTRIBUTE7
  		,ATTRIBUTE8
  		,ATTRIBUTE9
  		,ATTRIBUTE10
  		,ATTRIBUTE11
  		,ATTRIBUTE12
  		,ATTRIBUTE13
  		,ATTRIBUTE14
  		,ATTRIBUTE15
  		,ATTRIBUTE_CATEGORY
  		,MIGRATED_FLAG
  		,PROPERTY_LOV_TYPE
		,CREATED_FROM_CTR_PROP_TMPL_ID
	)
	VALUES(
		px_COUNTER_PROPERTY_ID
  		,decode(p_COUNTER_ID, FND_API.G_MISS_NUM, NULL, p_COUNTER_ID)
  		,decode(p_PROPERTY_DATA_TYPE, FND_API.G_MISS_CHAR, NULL, p_PROPERTY_DATA_TYPE)
  		,decode(p_IS_NULLABLE, FND_API.G_MISS_CHAR, NULL, p_IS_NULLABLE)
  		,decode(p_DEFAULT_VALUE, FND_API.G_MISS_CHAR, NULL, p_DEFAULT_VALUE)
  		,decode(p_MINIMUM_VALUE, FND_API.G_MISS_CHAR, NULL, p_MINIMUM_VALUE)
  		,decode(p_MAXIMUM_VALUE, FND_API.G_MISS_CHAR, NULL, p_MAXIMUM_VALUE)
  		,decode(p_UOM_CODE, FND_API.G_MISS_CHAR, NULL, p_UOM_CODE)
  		,decode(p_START_DATE_ACTIVE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_START_DATE_ACTIVE)
  		,decode(p_END_DATE_ACTIVE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_END_DATE_ACTIVE)
  		,decode(p_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, NULL, p_OBJECT_VERSION_NUMBER)
		,decode(p_SECURITY_GROUP_ID, FND_API.G_MISS_NUM, NULL, p_SECURITY_GROUP_ID)
		,decode(p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_LAST_UPDATE_DATE)
  		,decode(p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATED_BY)
  		,decode(p_CREATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_CREATION_DATE)
  		,decode(p_CREATED_BY, FND_API.G_MISS_NUM, NULL, p_CREATED_BY)
  		,decode(p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATE_LOGIN)
  		,decode(p_ATTRIBUTE1, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE1)
  		,decode(p_ATTRIBUTE2, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE2)
  		,decode(p_ATTRIBUTE3, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE3)
  		,decode(p_ATTRIBUTE4, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE4)
  		,decode(p_ATTRIBUTE5, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE5)
  		,decode(p_ATTRIBUTE6, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE6)
  		,decode(p_ATTRIBUTE7, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE7)
  		,decode(p_ATTRIBUTE8, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE8)
  		,decode(p_ATTRIBUTE9, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE9)
  		,decode(p_ATTRIBUTE10, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE10)
  		,decode(p_ATTRIBUTE11, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE11)
  		,decode(p_ATTRIBUTE12, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE12)
  		,decode(p_ATTRIBUTE13, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE13)
  		,decode(p_ATTRIBUTE14, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE14)
  		,decode(p_ATTRIBUTE15, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE15)
  		,decode(p_ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE_CATEGORY)
  		,decode(p_MIGRATED_FLAG, FND_API.G_MISS_CHAR, NULL, p_MIGRATED_FLAG)
  		,decode(p_PROPERTY_LOV_TYPE, FND_API.G_MISS_CHAR, NULL, p_PROPERTY_LOV_TYPE)
		,decode(p_CREATE_FROM_CTR_PROP_TMPL_ID, FND_API.G_MISS_CHAR, NULL, p_CREATE_FROM_CTR_PROP_TMPL_ID)
	);

	INSERT INTO CSI_COUNTER_PROPERTIES_TL(
		COUNTER_PROPERTY_ID
		,NAME
		,DESCRIPTION
		,LANGUAGE
		,SOURCE_LANG
		,CREATED_BY
		,CREATION_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_DATE
		,LAST_UPDATE_LOGIN
		,SECURITY_GROUP_ID
		,MIGRATED_FLAG
	)
	SELECT px_counter_property_id
		   ,decode(p_name, fnd_api.g_miss_char, NULL, p_name)
		   ,decode(p_description, fnd_api.g_miss_char, NULL, p_description)
		   ,L.language_code
		   ,userenv('LANG')
		   ,decode(p_created_by, fnd_api.g_miss_num, NULL, p_created_by)
		   ,decode(p_creation_date, fnd_api.g_miss_date, to_date(NULL), p_creation_date)
		   ,decode(p_last_updated_by, fnd_api.g_miss_num, NULL, p_last_updated_by)
		   ,decode(p_last_update_date, fnd_api.g_miss_date, to_date(NULL), p_last_update_date)
		   ,decode(p_last_update_login, fnd_api.g_miss_num, NULL, p_last_update_login)
		   ,decode(p_SECURITY_GROUP_ID, fnd_api.g_miss_num, NULL, p_SECURITY_GROUP_ID)
		   ,decode(p_migrated_flag, fnd_api.g_miss_char, NULL, p_migrated_flag)
    FROM   fnd_languages L
    WHERE  L.installed_flag IN ('I','B')
	AND	   NOT EXISTS (SELECT 'x'
					   FROM   CSI_COUNTER_PROPERTIES_TL cct
					   WHERE  cct.counter_property_id = px_counter_property_id
					   AND    cct.language = L.language_code);
END	Insert_Row;

PROCEDURE Update_Row(
	p_COUNTER_PROPERTY_ID              NUMBER
  	,p_COUNTER_ID                      NUMBER
  	,p_PROPERTY_DATA_TYPE              VARCHAR2
  	,p_IS_NULLABLE                     VARCHAR2
  	,p_DEFAULT_VALUE                   VARCHAR2
  	,p_MINIMUM_VALUE                   VARCHAR2
  	,p_MAXIMUM_VALUE                   VARCHAR2
  	,p_UOM_CODE                        VARCHAR2
  	,p_START_DATE_ACTIVE               DATE
  	,p_END_DATE_ACTIVE                 DATE
  	,p_OBJECT_VERSION_NUMBER           NUMBER
	,p_SECURITY_GROUP_ID			   NUMBER
  	,p_LAST_UPDATE_DATE                DATE
  	,p_LAST_UPDATED_BY                 NUMBER
  	,p_CREATION_DATE                   DATE
  	,p_CREATED_BY                      NUMBER
  	,p_LAST_UPDATE_LOGIN               NUMBER
  	,p_ATTRIBUTE1                      VARCHAR2
  	,p_ATTRIBUTE2                      VARCHAR2
  	,p_ATTRIBUTE3                      VARCHAR2
  	,p_ATTRIBUTE4                      VARCHAR2
  	,p_ATTRIBUTE5                      VARCHAR2
  	,p_ATTRIBUTE6                      VARCHAR2
  	,p_ATTRIBUTE7                      VARCHAR2
  	,p_ATTRIBUTE8                      VARCHAR2
  	,p_ATTRIBUTE9                      VARCHAR2
  	,p_ATTRIBUTE10                     VARCHAR2
  	,p_ATTRIBUTE11                     VARCHAR2
  	,p_ATTRIBUTE12                     VARCHAR2
  	,p_ATTRIBUTE13                     VARCHAR2
  	,p_ATTRIBUTE14                     VARCHAR2
  	,p_ATTRIBUTE15                     VARCHAR2
  	,p_ATTRIBUTE_CATEGORY              VARCHAR2
  	,p_MIGRATED_FLAG                   VARCHAR2
  	,p_PROPERTY_LOV_TYPE               VARCHAR2
	,p_CREATE_FROM_CTR_PROP_TMPL_ID    NUMBER
        ,p_NAME	                        VARCHAR2
        ,p_DESCRIPTION                  VARCHAR2
        ) IS
BEGIN
	UPDATE CSI_COUNTER_PROPERTIES_B
	SET
  		COUNTER_ID = decode(p_COUNTER_ID, NULL, COUNTER_ID, FND_API.G_MISS_NUM, NULL, p_COUNTER_ID)
  		,PROPERTY_DATA_TYPE = decode(p_PROPERTY_DATA_TYPE, NULL, PROPERTY_DATA_TYPE, FND_API.G_MISS_CHAR, NULL, p_PROPERTY_DATA_TYPE)
  		,IS_NULLABLE = decode(p_IS_NULLABLE, NULL, IS_NULLABLE, FND_API.G_MISS_CHAR, NULL, p_IS_NULLABLE)
  		,DEFAULT_VALUE = decode(p_DEFAULT_VALUE, NULL, DEFAULT_VALUE, FND_API.G_MISS_CHAR, NULL, p_DEFAULT_VALUE)
  		,MINIMUM_VALUE = decode(p_MINIMUM_VALUE, NULL, MINIMUM_VALUE, FND_API.G_MISS_CHAR, NULL, p_MINIMUM_VALUE)
  		,MAXIMUM_VALUE = decode(p_MAXIMUM_VALUE, NULL, MAXIMUM_VALUE, FND_API.G_MISS_CHAR, NULL, p_MAXIMUM_VALUE)
  		,UOM_CODE = decode(p_UOM_CODE, NULL, UOM_CODE, FND_API.G_MISS_CHAR, NULL, p_UOM_CODE)
  		,START_DATE_ACTIVE = decode(p_START_DATE_ACTIVE, NULL, START_DATE_ACTIVE, FND_API.G_MISS_DATE, NULL, p_START_DATE_ACTIVE)
  		,END_DATE_ACTIVE = decode(p_END_DATE_ACTIVE, NULL, END_DATE_ACTIVE, FND_API.G_MISS_DATE, NULL, p_END_DATE_ACTIVE)
  		,OBJECT_VERSION_NUMBER = decode(p_OBJECT_VERSION_NUMBER, NULL, OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, NULL, p_OBJECT_VERSION_NUMBER)
  		,SECURITY_GROUP_ID = decode(p_SECURITY_GROUP_ID, NULL, SECURITY_GROUP_ID, FND_API.G_MISS_NUM, NULL,  p_SECURITY_GROUP_ID)
  		,LAST_UPDATE_DATE = decode(p_LAST_UPDATE_DATE, NULL, LAST_UPDATE_DATE, FND_API.G_MISS_DATE, NULL, p_LAST_UPDATE_DATE)
  		,LAST_UPDATED_BY = decode(p_LAST_UPDATED_BY, NULL, LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATED_BY)
  		,CREATION_DATE = decode(p_CREATION_DATE, NULL, CREATION_DATE, FND_API.G_MISS_DATE, CREATION_DATE, p_CREATION_DATE)
	    ,CREATED_BY = decode(p_CREATED_BY, NULL, CREATED_BY, FND_API.G_MISS_NUM, CREATED_BY, p_CREATED_BY)
  		,LAST_UPDATE_LOGIN = decode(p_LAST_UPDATE_LOGIN, NULL, LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATE_LOGIN)
  		,ATTRIBUTE1 = decode(p_ATTRIBUTE1, NULL, ATTRIBUTE1, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE1)
  		,ATTRIBUTE2 = decode(p_ATTRIBUTE2, NULL, ATTRIBUTE2, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE2)
  		,ATTRIBUTE3 = decode(p_ATTRIBUTE3, NULL, ATTRIBUTE3, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE3)
  		,ATTRIBUTE4 = decode(p_ATTRIBUTE4, NULL, ATTRIBUTE4, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE4)
  		,ATTRIBUTE5 = decode(p_ATTRIBUTE5, NULL, ATTRIBUTE5, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE5)
  		,ATTRIBUTE6 = decode(p_ATTRIBUTE6, NULL, ATTRIBUTE6, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE6)
  		,ATTRIBUTE7 = decode(p_ATTRIBUTE7, NULL, ATTRIBUTE7, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE7)
  		,ATTRIBUTE8 = decode(p_ATTRIBUTE8, NULL, ATTRIBUTE8, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE8)
  		,ATTRIBUTE9 = decode(p_ATTRIBUTE9, NULL, ATTRIBUTE9, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE9)
  		,ATTRIBUTE10 = decode(p_ATTRIBUTE10, NULL, ATTRIBUTE10, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE10)
  		,ATTRIBUTE11 = decode(p_ATTRIBUTE11, NULL, ATTRIBUTE11, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE11)
  		,ATTRIBUTE12 = decode(p_ATTRIBUTE12, NULL, ATTRIBUTE12, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE12)
  		,ATTRIBUTE13 = decode(p_ATTRIBUTE13, NULL, ATTRIBUTE13, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE13)
  		,ATTRIBUTE14 = decode(p_ATTRIBUTE14, NULL, ATTRIBUTE14, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE14)
  		,ATTRIBUTE15 = decode(p_ATTRIBUTE15, NULL, ATTRIBUTE15, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE15)
  		,ATTRIBUTE_CATEGORY = decode(p_ATTRIBUTE_CATEGORY, NULL, ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE_CATEGORY)
  		,MIGRATED_FLAG = decode(p_MIGRATED_FLAG, NULL, MIGRATED_FLAG, FND_API.G_MISS_CHAR, NULL, p_MIGRATED_FLAG)
  		,PROPERTY_LOV_TYPE = decode(p_PROPERTY_LOV_TYPE, NULL, PROPERTY_LOV_TYPE, FND_API.G_MISS_CHAR, NULL, p_PROPERTY_LOV_TYPE)
  		,CREATED_FROM_CTR_PROP_TMPL_ID = decode(p_CREATE_FROM_CTR_PROP_TMPL_ID, NULL, CREATED_FROM_CTR_PROP_TMPL_ID, FND_API.G_MISS_NUM, NULL, p_CREATE_FROM_CTR_PROP_TMPL_ID)
	WHERE COUNTER_PROPERTY_ID = p_COUNTER_PROPERTY_ID;

	UPDATE CSI_COUNTER_PROPERTIES_TL
    SET    source_lang        = userenv('LANG'),
           name               = decode(p_name, NULL, name, fnd_api.g_miss_char, NULL, p_name),
           description        = decode(p_description, NULL, description, fnd_api.g_miss_char, NULL, p_description),
           created_by         = decode( p_created_by, NULL,created_by, fnd_api.g_miss_num,created_by, p_created_by),
           creation_date      = decode( p_creation_date, NULL,creation_date, fnd_api.g_miss_date, creation_date, p_creation_date),
           last_updated_by    = decode(p_last_updated_by, NULL, last_updated_by, fnd_api.g_miss_num, NULL, p_last_updated_by),
           last_update_date   = decode(p_last_update_date, NULL, last_update_date, fnd_api.g_miss_date, NULL, p_last_update_date),
           last_update_login  = decode(p_last_update_login, NULL, last_update_login, fnd_api.g_miss_num, NULL, p_last_update_login),
           SECURITY_GROUP_ID  = decode(p_SECURITY_GROUP_ID, NULL, SECURITY_GROUP_ID, fnd_api.g_miss_num, NULL, p_SECURITY_GROUP_ID),
           migrated_flag      = decode(p_migrated_flag, NULL, migrated_flag, fnd_api.g_miss_char, NULL, p_migrated_flag)
	WHERE  COUNTER_PROPERTY_ID = p_COUNTER_PROPERTY_ID
    AND    userenv('LANG') IN (LANGUAGE,SOURCE_LANG);

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
END	Update_Row;

PROCEDURE Lock_Row(
	p_COUNTER_PROPERTY_ID              NUMBER
  	,p_COUNTER_ID                      NUMBER
  	,p_PROPERTY_DATA_TYPE              VARCHAR2
  	,p_IS_NULLABLE                     VARCHAR2
  	,p_DEFAULT_VALUE                   VARCHAR2
  	,p_MINIMUM_VALUE                   VARCHAR2
  	,p_MAXIMUM_VALUE                   VARCHAR2
  	,p_UOM_CODE                        VARCHAR2
  	,p_START_DATE_ACTIVE               DATE
  	,p_END_DATE_ACTIVE                 DATE
  	,p_OBJECT_VERSION_NUMBER           NUMBER
	,p_SECURITY_GROUP_ID			   NUMBER
  	,p_LAST_UPDATE_DATE                DATE
  	,p_LAST_UPDATED_BY                 NUMBER
  	,p_CREATION_DATE                   DATE
  	,p_CREATED_BY                      NUMBER
  	,p_LAST_UPDATE_LOGIN               NUMBER
  	,p_ATTRIBUTE1                      VARCHAR2
  	,p_ATTRIBUTE2                      VARCHAR2
  	,p_ATTRIBUTE3                      VARCHAR2
  	,p_ATTRIBUTE4                      VARCHAR2
  	,p_ATTRIBUTE5                      VARCHAR2
  	,p_ATTRIBUTE6                      VARCHAR2
  	,p_ATTRIBUTE7                      VARCHAR2
  	,p_ATTRIBUTE8                      VARCHAR2
  	,p_ATTRIBUTE9                      VARCHAR2
  	,p_ATTRIBUTE10                     VARCHAR2
  	,p_ATTRIBUTE11                     VARCHAR2
  	,p_ATTRIBUTE12                     VARCHAR2
  	,p_ATTRIBUTE13                     VARCHAR2
  	,p_ATTRIBUTE14                     VARCHAR2
  	,p_ATTRIBUTE15                     VARCHAR2
  	,p_ATTRIBUTE_CATEGORY              VARCHAR2
  	,p_MIGRATED_FLAG                   VARCHAR2
  	,p_PROPERTY_LOV_TYPE               VARCHAR2
	,p_CREATE_FROM_CTR_PROP_TMPL_ID    NUMBER
        ,p_NAME	                        VARCHAR2
        ,p_DESCRIPTION                  VARCHAR2
        ) IS

	CURSOR C1 IS
	SELECT *
	FROM CSI_COUNTER_PROPERTIES_B
	WHERE COUNTER_PROPERTY_ID = p_COUNTER_PROPERTY_ID
	FOR UPDATE of COUNTER_PROPERTY_ID NOWAIT;
	Recinfo C1%ROWTYPE;

	CURSOR C2 IS
	SELECT name,
           description,
           decode(language, userenv('LANG'), 'Y', 'N') baselang
	FROM   CSI_COUNTER_PROPERTIES_TL
	WHERE  COUNTER_PROPERTY_ID = p_COUNTER_PROPERTY_ID
	AND    userenv('LANG') IN (LANGUAGE, SOURCE_LANG)
	FOR UPDATE of COUNTER_PROPERTY_ID NOWAIT;
BEGIN
	OPEN C1;
	FETCH C1 INTO Recinfo;
	IF (C1%NOTFOUND) THEN
        CLOSE c1;
        fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
        app_exception.raise_exception;
    END IF;
    CLOSE c1;

    IF  (recinfo.object_version_number=p_object_version_number)
    THEN
      RETURN;
    ELSE
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      app_exception.raise_exception;
    END IF;

	FOR tlinfo IN c2 LOOP
		IF (tlinfo.baselang = 'Y') THEN
			IF (    (tlinfo.name = p_name)
				AND ((tlinfo.description = p_description)
					OR ((tlinfo.description IS NULL) AND (p_description IS NULL)))
			) THEN
				NULL;
			ELSE
				fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
				app_exception.raise_exception;
			END IF;
		END IF;
	END LOOP;
	RETURN;
END Lock_Row;

PROCEDURE Delete_Row(
	p_COUNTER_PROPERTY_ID              NUMBER
       ) IS
BEGIN
	DELETE FROM CSI_COUNTER_PROPERTIES_B
	WHERE COUNTER_PROPERTY_ID = p_COUNTER_PROPERTY_ID;
	IF (SQL%NOTFOUND) then
		RAISE NO_DATA_FOUND;
	END IF;
END	Delete_Row;

PROCEDURE add_language IS
BEGIN
	DELETE FROM CSI_COUNTER_PROPERTIES_TL t
	WHERE NOT EXISTS (SELECT NULL
					  FROM   CSI_COUNTER_PROPERTIES_B b
					  WHERE  b.COUNTER_PROPERTY_ID = t.COUNTER_PROPERTY_ID);

	UPDATE CSI_COUNTER_PROPERTIES_TL t
	SET    (name,description) = (SELECT b.name,
                                        b.description
                                 FROM   CSI_COUNTER_PROPERTIES_TL b
								 WHERE  b.COUNTER_PROPERTY_ID = t.COUNTER_PROPERTY_ID
								 AND    b.language  = t.source_lang)
	WHERE (t.COUNTER_PROPERTY_ID, t.language)
	IN (SELECT	subt.COUNTER_PROPERTY_ID,
				subt.language
		FROM	CSI_COUNTER_PROPERTIES_TL subb, CSI_COUNTER_PROPERTIES_TL subt
		WHERE	subb.COUNTER_PROPERTY_ID = subt.COUNTER_PROPERTY_ID
		AND		subb.language  = subt.source_lang
		AND		(subb.name <> subt.name
				 OR subb.description <> subt.description
				 OR (subb.description IS NULL AND subt.description IS NOT NULL)
				 OR (subb.description iS NOT NULL AND subt.description IS NULL)
				)
		);

	INSERT INTO CSI_COUNTER_PROPERTIES_TL(
		COUNTER_PROPERTY_ID,
        name,
        description,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        last_update_login,
        language,
        source_lang
	)
	SELECT  b.COUNTER_PROPERTY_ID,
			b.name,
			b.description,
			b.last_update_date,
			b.last_updated_by,
			b.creation_date,
			b.created_by,
			b.last_update_login,
			l.language_code,
			b.source_lang
	FROM    CSI_COUNTER_PROPERTIES_TL b, fnd_languages l
	WHERE	l.installed_flag in ('I', 'B')
	AND		b.language = userenv('LANG')
	AND		NOT EXISTS (SELECT NULL
						FROM   CSI_COUNTER_PROPERTIES_TL t
						WHERE  t.counter_property_id = b.counter_property_id
						AND    t.language  = l.language_code);
END add_language;

PROCEDURE translate_row (
	p_COUNTER_PROPERTY_ID              NUMBER
          ,p_name              VARCHAR2
          ,p_description       VARCHAR2
          ,p_owner              VARCHAR2
          ) IS
BEGIN
	UPDATE CSI_COUNTER_PROPERTIES_TL
	SET		name              = p_name,
			description       = p_description,
			last_update_date  = sysdate,
			last_updated_by   = decode(p_owner, 'SEED', 1, 0),
			last_update_login = 0,
			source_lang       = userenv('LANG')
	WHERE	COUNTER_PROPERTY_ID = p_COUNTER_PROPERTY_ID
	AND		userenv('LANG') IN (language, source_lang);
END	translate_row;

End CSI_COUNTER_PROPERTIES_PKG;

/
