--------------------------------------------------------
--  DDL for Package Body CSI_CTR_PROPERTY_TEMPLATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_CTR_PROPERTY_TEMPLATE_PKG" AS
/* $Header: csitcptb.pls 120.2.12010000.2 2008/10/31 21:21:44 rsinn ship $*/

G_PKG_NAME CONSTANT VARCHAR2(30)  := 'CSI_CTR_PROPERTY_TEMPLATE_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csitcptb.pls';

PROCEDURE Insert_Row(
 	 px_COUNTER_PROPERTY_ID        IN OUT NOCOPY NUMBER
	,p_COUNTER_ID                  NUMBER
	,p_PROPERTY_DATA_TYPE          VARCHAR2
	,p_IS_NULLABLE                 VARCHAR2
	,p_DEFAULT_VALUE               VARCHAR2
	,p_MINIMUM_VALUE               VARCHAR2
	,p_MAXIMUM_VALUE               VARCHAR2
	,p_UOM_CODE                    VARCHAR2
	,p_START_DATE_ACTIVE           DATE
	,p_END_DATE_ACTIVE             DATE
	,p_OBJECT_VERSION_NUMBER       NUMBER
	,p_LAST_UPDATE_DATE            DATE
	,p_LAST_UPDATED_BY             NUMBER
	,p_CREATION_DATE               DATE
	,p_CREATED_BY                  NUMBER
	,p_LAST_UPDATE_LOGIN           NUMBER
	,p_ATTRIBUTE1                  VARCHAR2
	,p_ATTRIBUTE2                  VARCHAR2
	,p_ATTRIBUTE3                  VARCHAR2
	,p_ATTRIBUTE4                  VARCHAR2
	,p_ATTRIBUTE5                  VARCHAR2
	,p_ATTRIBUTE6                  VARCHAR2
	,p_ATTRIBUTE7                  VARCHAR2
	,p_ATTRIBUTE8                  VARCHAR2
	,p_ATTRIBUTE9                  VARCHAR2
	,p_ATTRIBUTE10                 VARCHAR2
	,p_ATTRIBUTE11                 VARCHAR2
	,p_ATTRIBUTE12                 VARCHAR2
	,p_ATTRIBUTE13                 VARCHAR2
	,p_ATTRIBUTE14                 VARCHAR2
	,p_ATTRIBUTE15                 VARCHAR2
	,p_ATTRIBUTE_CATEGORY          VARCHAR2
	,p_MIGRATED_FLAG               VARCHAR2
	,p_PROPERTY_LOV_TYPE           VARCHAR2
        ,p_SECURITY_GROUP_ID           NUMBER
        ,p_NAME	                       VARCHAR2
        ,p_DESCRIPTION                 VARCHAR2
      ) IS

   CURSOR C1 IS
   SELECT CSI_COUNTER_PROPERTIES_B_S.nextval
   FROM   dual;
BEGIN
   IF (px_COUNTER_PROPERTY_ID IS NULL) OR (px_COUNTER_PROPERTY_ID = FND_API.G_MISS_NUM) then
      OPEN C1;
      FETCH C1 INTO px_COUNTER_PROPERTY_ID;
      CLOSE C1;
   END IF;

   INSERT INTO CSI_CTR_PROPERTY_TEMPLATE_B(
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
        ,SECURITY_GROUP_ID
      )
   VALUES(
 	 px_COUNTER_PROPERTY_ID
	,decode(p_COUNTER_ID, FND_API.G_MISS_NUM, NULL,p_COUNTER_ID)
	,decode(p_PROPERTY_DATA_TYPE, FND_API.G_MISS_CHAR, NULL, p_PROPERTY_DATA_TYPE)
	,decode(p_IS_NULLABLE, FND_API.G_MISS_CHAR, NULL, p_IS_NULLABLE)
	,decode(p_DEFAULT_VALUE, FND_API.G_MISS_CHAR, NULL, p_DEFAULT_VALUE)
	,decode(p_MINIMUM_VALUE, FND_API.G_MISS_CHAR, NULL, p_MINIMUM_VALUE)
	,decode(p_MAXIMUM_VALUE, FND_API.G_MISS_CHAR, NULL, p_MAXIMUM_VALUE)
	,decode(p_UOM_CODE, FND_API.G_MISS_CHAR, NULL, p_UOM_CODE)
	,decode(p_START_DATE_ACTIVE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_START_DATE_ACTIVE)
	,decode(p_END_DATE_ACTIVE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_END_DATE_ACTIVE)
	,decode(p_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, NULL,p_OBJECT_VERSION_NUMBER)
	,decode(p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_LAST_UPDATE_DATE)
	,decode(p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATED_BY)
	,decode(p_CREATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_CREATION_DATE)
	,decode(p_CREATED_BY, FND_API.G_MISS_NUM, NULL,p_CREATED_BY)
	,decode(p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL,p_LAST_UPDATE_LOGIN)
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
	,decode(p_ATTRIBUTE_CATEGORY , FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE_CATEGORY)
	,decode(p_MIGRATED_FLAG, FND_API.G_MISS_CHAR, NULL, p_MIGRATED_FLAG)
	,decode(p_PROPERTY_LOV_TYPE, FND_API.G_MISS_CHAR, NULL, p_PROPERTY_LOV_TYPE)
        ,decode(p_SECURITY_GROUP_ID, FND_API.G_MISS_NUM, NULL,p_SECURITY_GROUP_ID)
     );

    INSERT INTO CSI_CTR_PROPERTY_TEMPLATE_TL(
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
           ,decode(p_migrated_flag, fnd_api.g_miss_char, NULL, p_migrated_flag)
     FROM   fnd_languages L
     WHERE  L.installed_flag IN ('I','B')
     AND    NOT EXISTS (SELECT 'x'
                        FROM   csi_ctr_property_template_tl cct
                        WHERE  cct.counter_property_id = px_counter_property_id
                        AND    cct.language = L.language_code);
End Insert_Row;

PROCEDURE Update_Row(
 	 p_COUNTER_PROPERTY_ID        NUMBER
	,p_COUNTER_ID                  NUMBER
	,p_PROPERTY_DATA_TYPE          VARCHAR2
	,p_IS_NULLABLE                 VARCHAR2
	,p_DEFAULT_VALUE               VARCHAR2
	,p_MINIMUM_VALUE               VARCHAR2
	,p_MAXIMUM_VALUE               VARCHAR2
	,p_UOM_CODE                    VARCHAR2
	,p_START_DATE_ACTIVE           DATE
	,p_END_DATE_ACTIVE             DATE
	,p_OBJECT_VERSION_NUMBER       NUMBER
	,p_LAST_UPDATE_DATE            DATE
	,p_LAST_UPDATED_BY             NUMBER
	,p_CREATION_DATE               DATE
	,p_CREATED_BY                  NUMBER
	,p_LAST_UPDATE_LOGIN           NUMBER
	,p_ATTRIBUTE1                  VARCHAR2
	,p_ATTRIBUTE2                  VARCHAR2
	,p_ATTRIBUTE3                  VARCHAR2
	,p_ATTRIBUTE4                  VARCHAR2
	,p_ATTRIBUTE5                  VARCHAR2
	,p_ATTRIBUTE6                  VARCHAR2
	,p_ATTRIBUTE7                  VARCHAR2
	,p_ATTRIBUTE8                  VARCHAR2
	,p_ATTRIBUTE9                  VARCHAR2
	,p_ATTRIBUTE10                 VARCHAR2
	,p_ATTRIBUTE11                 VARCHAR2
	,p_ATTRIBUTE12                 VARCHAR2
	,p_ATTRIBUTE13                 VARCHAR2
	,p_ATTRIBUTE14                 VARCHAR2
	,p_ATTRIBUTE15                 VARCHAR2
	,p_ATTRIBUTE_CATEGORY          VARCHAR2
	,p_MIGRATED_FLAG               VARCHAR2
	,p_PROPERTY_LOV_TYPE           VARCHAR2
        ,p_SECURITY_GROUP_ID           NUMBER
        ,p_NAME	                       VARCHAR2
        ,p_DESCRIPTION                 VARCHAR2) IS
 BEGIN
 -- Read the debug profiles values in to global variable 7197402
   CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;
csi_ctr_gen_utility_pvt.put_line(' Default Value = '||p_default_value);

    UPDATE CSI_CTR_PROPERTY_TEMPLATE_B
    SET     COUNTER_ID = decode(p_COUNTER_ID, NULL, COUNTER_ID, FND_API.G_MISS_NUM, NULL, p_COUNTER_ID)
	   ,PROPERTY_DATA_TYPE = decode(p_PROPERTY_DATA_TYPE, NULL, PROPERTY_DATA_TYPE, FND_API.G_MISS_CHAR, NULL, p_PROPERTY_DATA_TYPE)
	   ,IS_NULLABLE = decode(p_IS_NULLABLE, NULL, IS_NULLABLE, FND_API.G_MISS_CHAR, NULL, p_IS_NULLABLE)
	   ,DEFAULT_VALUE = decode(p_DEFAULT_VALUE, NULL, DEFAULT_VALUE, FND_API.G_MISS_CHAR, NULL, p_DEFAULT_VALUE)
	   ,MINIMUM_VALUE = decode(p_MINIMUM_VALUE, NULL, MINIMUM_VALUE, FND_API.G_MISS_CHAR, NULL, p_MINIMUM_VALUE)
	   ,MAXIMUM_VALUE = decode(p_MAXIMUM_VALUE, NULL, MAXIMUM_VALUE, FND_API.G_MISS_CHAR, NULL, p_MAXIMUM_VALUE)
	   ,UOM_CODE = decode(p_UOM_CODE, NULL, UOM_CODE, FND_API.G_MISS_CHAR, NULL, p_UOM_CODE)
 	   ,START_DATE_ACTIVE = decode(p_START_DATE_ACTIVE, NULL, START_DATE_ACTIVE, FND_API.G_MISS_DATE, NULL, p_START_DATE_ACTIVE)
  	   ,END_DATE_ACTIVE = decode(p_END_DATE_ACTIVE, NULL, END_DATE_ACTIVE, FND_API.G_MISS_DATE, NULL,p_END_DATE_ACTIVE)
	   ,OBJECT_VERSION_NUMBER = decode(p_OBJECT_VERSION_NUMBER, NULL, OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, NULL, p_OBJECT_VERSION_NUMBER)
  	   ,LAST_UPDATE_DATE = decode(p_LAST_UPDATE_DATE, NULL, LAST_UPDATE_DATE, FND_API.G_MISS_DATE, NULL,p_LAST_UPDATE_DATE)
	   ,LAST_UPDATED_BY = decode(p_LAST_UPDATED_BY, NULL,LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL,p_LAST_UPDATED_BY)
   	   ,CREATION_DATE = decode(p_CREATION_DATE, NULL, CREATION_DATE, FND_API.G_MISS_DATE, NULL, p_CREATION_DATE)
	   ,CREATED_BY = decode(p_CREATED_BY, NULL, CREATED_BY, FND_API.G_MISS_NUM, NULL, p_CREATED_BY)
	   ,LAST_UPDATE_LOGIN = decode(p_LAST_UPDATE_LOGIN, NULL,LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL,p_LAST_UPDATE_LOGIN)
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
	   ,MIGRATED_FLAG = decode(p_MIGRATED_FLAG, NULL, MIGRATED_FLAG, FND_API.G_MISS_CHAR,NULL, p_MIGRATED_FLAG)
	   ,PROPERTY_LOV_TYPE = decode(p_PROPERTY_LOV_TYPE, NULL, PROPERTY_LOV_TYPE, FND_API.G_MISS_CHAR, NULL, p_PROPERTY_LOV_TYPE)
           ,SECURITY_GROUP_ID     = decode(p_SECURITY_GROUP_ID, NULL, SECURITY_GROUP_ID, FND_API.G_MISS_NUM, NULL, p_SECURITY_GROUP_ID)
    WHERE  COUNTER_PROPERTY_ID = p_COUNTER_PROPERTY_ID;

    UPDATE CSI_CTR_PROPERTY_TEMPLATE_TL
    SET    source_lang        = userenv('LANG'),
           name               = decode(p_name, NULL, name, fnd_api.g_miss_char, NULL, p_name),
           description        = decode(p_description, NULL, description, fnd_api.g_miss_char, NULL, p_description),
           created_by         = decode(p_created_by, NULL, created_by, fnd_api.g_miss_num, NULL, p_created_by),
           creation_date      = decode(p_creation_date, NULL, creation_date,  fnd_api.g_miss_date, NULL, p_creation_date),
           last_updated_by    = decode(p_last_updated_by, NULL, last_updated_by, fnd_api.g_miss_num, NULL,p_last_updated_by),
           last_update_date   = decode(p_last_update_date,NULL,last_update_date,fnd_api.g_miss_date,NULL,p_last_update_date),
           -- last_update_login  = decode(p_last_update_login,last_update_login, fnd_api.g_miss_num,NULL, p_last_update_login),
           migrated_flag      = decode(p_migrated_flag, NULL, migrated_flag, fnd_api.g_miss_char,NULL, p_migrated_flag)
    WHERE counter_property_id = p_counter_property_id
    AND   userenv('LANG') IN (LANGUAGE,SOURCE_LANG);

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;

END Update_Row;

PROCEDURE delete_row(p_COUNTER_PROPERTY_ID NUMBER) IS
BEGIN
   DELETE FROM CSI_CTR_PROPERTY_TEMPLATE_B
   WHERE  COUNTER_PROPERTY_ID = p_COUNTER_PROPERTY_ID;
   IF (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   END IF;
END delete_row;

PROCEDURE Lock_Row(
 	 p_COUNTER_PROPERTY_ID        NUMBER
	,p_COUNTER_ID                  NUMBER
	,p_PROPERTY_DATA_TYPE          VARCHAR2
	,p_IS_NULLABLE                 VARCHAR2
	,p_DEFAULT_VALUE               VARCHAR2
	,p_MINIMUM_VALUE               VARCHAR2
	,p_MAXIMUM_VALUE               VARCHAR2
	,p_UOM_CODE                    VARCHAR2
	,p_START_DATE_ACTIVE           DATE
	,p_END_DATE_ACTIVE             DATE
	,p_OBJECT_VERSION_NUMBER       NUMBER
	,p_LAST_UPDATE_DATE            DATE
	,p_LAST_UPDATED_BY             NUMBER
	,p_CREATION_DATE               DATE
	,p_CREATED_BY                  NUMBER
	,p_LAST_UPDATE_LOGIN           NUMBER
	,p_ATTRIBUTE1                  VARCHAR2
	,p_ATTRIBUTE2                  VARCHAR2
	,p_ATTRIBUTE3                  VARCHAR2
	,p_ATTRIBUTE4                  VARCHAR2
	,p_ATTRIBUTE5                  VARCHAR2
	,p_ATTRIBUTE6                  VARCHAR2
	,p_ATTRIBUTE7                  VARCHAR2
	,p_ATTRIBUTE8                  VARCHAR2
	,p_ATTRIBUTE9                  VARCHAR2
	,p_ATTRIBUTE10                 VARCHAR2
	,p_ATTRIBUTE11                 VARCHAR2
	,p_ATTRIBUTE12                 VARCHAR2
	,p_ATTRIBUTE13                 VARCHAR2
	,p_ATTRIBUTE14                 VARCHAR2
	,p_ATTRIBUTE15                 VARCHAR2
	,p_ATTRIBUTE_CATEGORY          VARCHAR2
	,p_MIGRATED_FLAG               VARCHAR2
	,p_PROPERTY_LOV_TYPE           VARCHAR2
        ,p_SECURITY_GROUP_ID           NUMBER
        ,p_NAME	                       VARCHAR2
        ,p_DESCRIPTION                 VARCHAR2) IS

   CURSOR C1 IS
   SELECT *
   FROM   CSI_CTR_PROPERTY_TEMPLATE_B
   WHERE  COUNTER_PROPERTY_ID = p_COUNTER_PROPERTY_ID
   FOR UPDATE of COUNTER_PROPERTY_ID NOWAIT;
   Recinfo C1%ROWTYPE;

   CURSOR c2 IS
   SELECT name,
          description,
          decode(language, userenv('LANG'), 'Y', 'N') baselang
   FROM   CSI_CTR_PROPERTY_TEMPLATE_TL
   WHERE  counter_property_id = p_counter_property_id
   AND    userenv('LANG') IN (LANGUAGE, SOURCE_LANG)
   FOR UPDATE OF counter_property_id NOWAIT;
BEGIN
    OPEN c1;
    FETCH c1 INTO recinfo;
    IF (c1%notfound) THEN
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

PROCEDURE add_language IS
BEGIN
   DELETE FROM CSI_CTR_PROPERTY_TEMPLATE_TL t
   WHERE NOT EXISTS (SELECT NULL
                     FROM   CSI_CTR_PROPERTY_TEMPLATE_B b
                     WHERE  b.counter_property_id = t.counter_property_id);

   UPDATE CSI_CTR_PROPERTY_TEMPLATE_TL t
   SET    (name,description) = (SELECT b.name,
                                       b.description
                                FROM   CSI_CTR_PROPERTY_TEMPLATE_TL b
                                WHERE  b.counter_property_id = t.counter_property_id
                                AND    b.language  = t.source_lang)
   WHERE (t.counter_property_id,t.language) IN  (SELECT  subt.counter_property_id,
                                                         subt.language
                                       FROM    CSI_CTR_PROPERTY_TEMPLATE_TL subb, CSI_CTR_PROPERTY_TEMPLATE_TL subt
                                       WHERE   subb.counter_property_id = subt.counter_property_id
                                       AND     subb.language  = subt.source_lang
                                       AND    (subb.name <> subt.name
                                               OR subb.description <> subt.description
                                               OR (subb.description IS NULL AND subt.description IS NOT NULL)
                                               OR (subb.description iS NOT NULL AND subt.description IS NULL)
                                               )
                                        );

   INSERT INTO CSI_CTR_PROPERTY_TEMPLATE_TL(
	counter_property_id,
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
   SELECT  b.counter_property_id,
           b.name,
           b.description,
           b.last_update_date,
           b.last_updated_by,
           b.creation_date,
           b.created_by,
           b.last_update_login,
           l.language_code,
           b.source_lang
   FROM  CSI_CTR_PROPERTY_TEMPLATE_TL b, fnd_languages l
   WHERE l.installed_flag in ('I', 'B')
   AND   b.language = userenv('LANG')
   AND   NOT EXISTS (SELECT NULL
                     FROM   CSI_CTR_PROPERTY_TEMPLATE_TL t
                     WHERE  t.counter_property_id = b.counter_property_id
                     AND    t.language  = l.language_code);
END add_language;

PROCEDURE translate_row(
   p_counter_property_id IN NUMBER
   ,p_name             IN VARCHAR2
   ,p_description      IN VARCHAR2
   ,p_owner            IN VARCHAR2) IS
BEGIN
  UPDATE CSI_CTR_PROPERTY_TEMPLATE_TL
  SET   name              = p_name,
        description       = p_description,
        last_update_date  = sysdate,
        last_updated_by   = decode(p_owner, 'SEED', 1, 0),
        last_update_login = 0,
        source_lang       = userenv('LANG')
  WHERE counter_property_id = p_counter_property_id
  AND   userenv('LANG') IN (language, source_lang);
END translate_row;

End CSI_CTR_PROPERTY_TEMPLATE_PKG;

/
