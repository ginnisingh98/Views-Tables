--------------------------------------------------------
--  DDL for Package Body MTL_ITEM_TEMPLATES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MTL_ITEM_TEMPLATES_PKG" AS
/* $Header: INVVTEMB.pls 120.1.12010000.5 2008/11/17 23:17:00 akbharga ship $ */

PROCEDURE INSERT_ROW(P_Item_Templates_Rec IN  MTL_ITEM_TEMPLATES_B%ROWTYPE,
                     X_ROWID              OUT NOCOPY ROWID) IS
BEGIN

   INSERT INTO MTL_ITEM_TEMPLATES_B (
      TEMPLATE_ID,
      TEMPLATE_NAME,
      DESCRIPTION,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      CREATION_DATE,
      CREATED_BY,
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
      ATTRIBUTE15,
      REQUEST_ID,
      PROGRAM_APPLICATION_ID,
      PROGRAM_ID,
      PROGRAM_UPDATE_DATE,
      CONTEXT_ORGANIZATION_ID,
      GLOBAL_ATTRIBUTE_CATEGORY,
      GLOBAL_ATTRIBUTE1,
      GLOBAL_ATTRIBUTE2,
      GLOBAL_ATTRIBUTE3,
      GLOBAL_ATTRIBUTE4,
      GLOBAL_ATTRIBUTE5,
      GLOBAL_ATTRIBUTE6,
      GLOBAL_ATTRIBUTE7,
      GLOBAL_ATTRIBUTE8,
      GLOBAL_ATTRIBUTE9,
      GLOBAL_ATTRIBUTE10,
      GLOBAL_ATTRIBUTE11,
      GLOBAL_ATTRIBUTE12,
      GLOBAL_ATTRIBUTE13,
      GLOBAL_ATTRIBUTE14,
      GLOBAL_ATTRIBUTE15,
      GLOBAL_ATTRIBUTE16,
      GLOBAL_ATTRIBUTE17,
      GLOBAL_ATTRIBUTE18,
      GLOBAL_ATTRIBUTE19,
      GLOBAL_ATTRIBUTE20
)
   VALUES (
      P_Item_Templates_Rec.TEMPLATE_ID,
      P_Item_Templates_Rec.TEMPLATE_NAME,
      P_Item_Templates_Rec.DESCRIPTION,
      P_Item_Templates_Rec.LAST_UPDATE_DATE,
      P_Item_Templates_Rec.LAST_UPDATED_BY,
      P_Item_Templates_Rec.CREATION_DATE,
      P_Item_Templates_Rec.CREATED_BY,
      P_Item_Templates_Rec.LAST_UPDATE_LOGIN,
      P_Item_Templates_Rec.ATTRIBUTE_CATEGORY,
      P_Item_Templates_Rec.ATTRIBUTE1,
      P_Item_Templates_Rec.ATTRIBUTE2,
      P_Item_Templates_Rec.ATTRIBUTE3,
      P_Item_Templates_Rec.ATTRIBUTE4,
      P_Item_Templates_Rec.ATTRIBUTE5,
      P_Item_Templates_Rec.ATTRIBUTE6,
      P_Item_Templates_Rec.ATTRIBUTE7,
      P_Item_Templates_Rec.ATTRIBUTE8,
      P_Item_Templates_Rec.ATTRIBUTE9,
      P_Item_Templates_Rec.ATTRIBUTE10,
      P_Item_Templates_Rec.ATTRIBUTE11,
      P_Item_Templates_Rec.ATTRIBUTE12,
      P_Item_Templates_Rec.ATTRIBUTE13,
      P_Item_Templates_Rec.ATTRIBUTE14,
      P_Item_Templates_Rec.ATTRIBUTE15,
      P_Item_Templates_Rec.REQUEST_ID,
      P_Item_Templates_Rec.PROGRAM_APPLICATION_ID,
      P_Item_Templates_Rec.PROGRAM_ID,
      P_Item_Templates_Rec.PROGRAM_UPDATE_DATE,
      P_Item_Templates_Rec.CONTEXT_ORGANIZATION_ID,
      P_Item_Templates_Rec.GLOBAL_ATTRIBUTE_CATEGORY,
      P_Item_Templates_Rec.GLOBAL_ATTRIBUTE1,
      P_Item_Templates_Rec.GLOBAL_ATTRIBUTE2,
      P_Item_Templates_Rec.GLOBAL_ATTRIBUTE3,
      P_Item_Templates_Rec.GLOBAL_ATTRIBUTE4,
      P_Item_Templates_Rec.GLOBAL_ATTRIBUTE5,
      P_Item_Templates_Rec.GLOBAL_ATTRIBUTE6,
      P_Item_Templates_Rec.GLOBAL_ATTRIBUTE7,
      P_Item_Templates_Rec.GLOBAL_ATTRIBUTE8,
      P_Item_Templates_Rec.GLOBAL_ATTRIBUTE9,
      P_Item_Templates_Rec.GLOBAL_ATTRIBUTE10,
      P_Item_Templates_Rec.GLOBAL_ATTRIBUTE11,
      P_Item_Templates_Rec.GLOBAL_ATTRIBUTE12,
      P_Item_Templates_Rec.GLOBAL_ATTRIBUTE13,
      P_Item_Templates_Rec.GLOBAL_ATTRIBUTE14,
      P_Item_Templates_Rec.GLOBAL_ATTRIBUTE15,
      P_Item_Templates_Rec.GLOBAL_ATTRIBUTE16,
      P_Item_Templates_Rec.GLOBAL_ATTRIBUTE17,
      P_Item_Templates_Rec.GLOBAL_ATTRIBUTE18,
      P_Item_Templates_Rec.GLOBAL_ATTRIBUTE19,
      P_Item_Templates_Rec.GLOBAL_ATTRIBUTE20
)
   RETURNING ROWID INTO X_ROWID;

   INSERT INTO MTL_ITEM_TEMPLATES_TL (
      TEMPLATE_ID,
      TEMPLATE_NAME,
      DESCRIPTION,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN,
      LANGUAGE,
      SOURCE_LANG)
   SELECT   P_Item_Templates_Rec.TEMPLATE_ID,
            P_Item_Templates_Rec.TEMPLATE_NAME,
            P_Item_Templates_Rec.DESCRIPTION,
            P_Item_Templates_Rec.CREATION_DATE,
            P_Item_Templates_Rec.CREATED_BY,
            P_Item_Templates_Rec.LAST_UPDATE_DATE,
            P_Item_Templates_Rec.LAST_UPDATED_BY,
            P_Item_Templates_Rec.LAST_UPDATE_LOGIN,
            L.LANGUAGE_CODE,
            USERENV('LANG')
   FROM FND_LANGUAGES L
   WHERE L.INSTALLED_FLAG in ('I', 'B')
   AND NOT EXISTS (SELECT NULL
                   FROM MTL_ITEM_TEMPLATES_TL T
                   WHERE T.TEMPLATE_ID = P_Item_Templates_Rec.TEMPLATE_ID
                   AND   T.LANGUAGE    = L.LANGUAGE_CODE);
END INSERT_ROW;

PROCEDURE LOCK_ROW (P_Item_Templates_Rec IN  MTL_ITEM_TEMPLATES_B%ROWTYPE) IS

   CURSOR c_get_item_templates IS
   SELECT
        TEMPLATE_ID,
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
        CONTEXT_ORGANIZATION_ID
   FROM MTL_ITEM_TEMPLATES_B
   WHERE TEMPLATE_ID = P_Item_Templates_Rec.TEMPLATE_ID;

   CURSOR c_get_templates_trans IS
   SELECT
       TEMPLATE_NAME,
       DESCRIPTION,
       DECODE(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
   FROM MTL_ITEM_TEMPLATES_TL
   WHERE TEMPLATE_ID = P_Item_Templates_Rec.TEMPLATE_ID
   AND   USERENV('LANG') IN (LANGUAGE, SOURCE_LANG);

   recinfo c_get_item_templates%rowtype;

BEGIN

   OPEN  c_get_item_templates;
   FETCH c_get_item_templates INTO recinfo;
   IF (c_get_item_templates%notfound) THEN
      CLOSE c_get_item_templates;
      fnd_message.set_name('FND','FORM_RECORD_DELETED');
      Raise FND_API.g_EXC_UNEXPECTED_ERROR;
   END IF;
   CLOSE c_get_item_templates;

   IF ((recinfo.TEMPLATE_ID = P_Item_Templates_Rec.Template_Id)
      AND ((recinfo.CONTEXT_ORGANIZATION_ID = P_Item_Templates_Rec.CONTEXT_ORGANIZATION_ID)
           OR ((recinfo.CONTEXT_ORGANIZATION_ID is null) AND (P_Item_Templates_Rec.CONTEXT_ORGANIZATION_ID is null)))
      AND ((recinfo.ATTRIBUTE_CATEGORY = P_Item_Templates_Rec.ATTRIBUTE_CATEGORY)
           OR ((recinfo.ATTRIBUTE_CATEGORY is null) AND (P_Item_Templates_Rec.ATTRIBUTE_CATEGORY is null)))
      AND ((recinfo.ATTRIBUTE1 = P_Item_Templates_Rec.ATTRIBUTE1)
           OR ((recinfo.ATTRIBUTE1 is null) AND (P_Item_Templates_Rec.ATTRIBUTE1 is null)))
      AND ((recinfo.ATTRIBUTE2 = P_Item_Templates_Rec.ATTRIBUTE2)
           OR ((recinfo.ATTRIBUTE2 is null) AND (P_Item_Templates_Rec.ATTRIBUTE2 is null)))
      AND ((recinfo.ATTRIBUTE3 = P_Item_Templates_Rec.ATTRIBUTE3)
           OR ((recinfo.ATTRIBUTE3 is null) AND (P_Item_Templates_Rec.ATTRIBUTE3 is null)))
      AND ((recinfo.ATTRIBUTE4 = P_Item_Templates_Rec.ATTRIBUTE4)
           OR ((recinfo.ATTRIBUTE4 is null) AND (P_Item_Templates_Rec.ATTRIBUTE4 is null)))
      AND ((recinfo.ATTRIBUTE5 = P_Item_Templates_Rec.ATTRIBUTE5)
           OR ((recinfo.ATTRIBUTE5 is null) AND (P_Item_Templates_Rec.ATTRIBUTE5 is null)))
      AND ((recinfo.ATTRIBUTE6 = P_Item_Templates_Rec.ATTRIBUTE6)
           OR ((recinfo.ATTRIBUTE6 is null) AND (P_Item_Templates_Rec.ATTRIBUTE6 is null)))
      AND ((recinfo.ATTRIBUTE7 = P_Item_Templates_Rec.ATTRIBUTE7)
           OR ((recinfo.ATTRIBUTE7 is null) AND (P_Item_Templates_Rec.ATTRIBUTE7 is null)))
      AND ((recinfo.ATTRIBUTE8 = P_Item_Templates_Rec.ATTRIBUTE8)
           OR ((recinfo.ATTRIBUTE8 is null) AND (P_Item_Templates_Rec.ATTRIBUTE8 is null)))
      AND ((recinfo.ATTRIBUTE9 = P_Item_Templates_Rec.ATTRIBUTE9)
           OR ((recinfo.ATTRIBUTE9 is null) AND (P_Item_Templates_Rec.ATTRIBUTE9 is null)))
      AND ((recinfo.ATTRIBUTE10 = P_Item_Templates_Rec.ATTRIBUTE10)
           OR ((recinfo.ATTRIBUTE10 is null) AND (P_Item_Templates_Rec.ATTRIBUTE10 is null)))
      AND ((recinfo.ATTRIBUTE11 = P_Item_Templates_Rec.ATTRIBUTE11)
           OR ((recinfo.ATTRIBUTE11 is null) AND (P_Item_Templates_Rec.ATTRIBUTE11 is null)))
      AND ((recinfo.ATTRIBUTE12 = P_Item_Templates_Rec.ATTRIBUTE12)
           OR ((recinfo.ATTRIBUTE12 is null) AND (P_Item_Templates_Rec.ATTRIBUTE12 is null)))
      AND ((recinfo.ATTRIBUTE13 = P_Item_Templates_Rec.ATTRIBUTE13)
           OR ((recinfo.ATTRIBUTE13 is null) AND (P_Item_Templates_Rec.ATTRIBUTE13 is null)))
      AND ((recinfo.ATTRIBUTE14 = P_Item_Templates_Rec.ATTRIBUTE14)
           OR ((recinfo.ATTRIBUTE14 is null) AND (P_Item_Templates_Rec.ATTRIBUTE14 is null)))
      AND ((recinfo.ATTRIBUTE15 = P_Item_Templates_Rec.ATTRIBUTE15)
           OR ((recinfo.ATTRIBUTE15 is null) AND (P_Item_Templates_Rec.ATTRIBUTE15 is null))))
   THEN
      NULL;
   ELSE
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      Raise FND_API.g_EXC_UNEXPECTED_ERROR;
   END IF;

   FOR tlinfo IN c_get_templates_trans
   LOOP
      IF (tlinfo.BASELANG = 'Y') THEN
         IF((tlinfo.DESCRIPTION = P_Item_Templates_Rec.DESCRIPTION)
             OR ((tlinfo.DESCRIPTION is null) AND (P_Item_Templates_Rec.DESCRIPTION is null))
         AND ((tlinfo.template_name = P_Item_Templates_Rec.TEMPLATE_NAME)
             OR ((tlinfo.template_name is null) AND (P_Item_Templates_Rec.TEMPLATE_NAME is null))))
         THEN
            NULL;
         ELSE
            fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
            Raise FND_API.g_EXC_UNEXPECTED_ERROR;
         END IF;
      END IF;
   END LOOP;

EXCEPTION
   WHEN FND_API.g_EXC_UNEXPECTED_ERROR THEN
      IF ( c_get_item_templates%ISOPEN ) THEN
        CLOSE c_get_item_templates;
      END IF;
      IF ( c_get_templates_trans%ISOPEN ) THEN
        CLOSE c_get_templates_trans;
      END IF;
      app_exception.raise_exception;
END LOCK_ROW;

PROCEDURE UPDATE_ROW (P_Item_Templates_Rec IN  MTL_ITEM_Templates_B%ROWTYPE) IS
BEGIN
   UPDATE MTL_ITEM_TEMPLATES_B
   SET
        LAST_UPDATE_DATE = P_Item_Templates_Rec.LAST_UPDATE_DATE,
        LAST_UPDATED_BY = P_Item_Templates_Rec.LAST_UPDATED_BY,
        CREATION_DATE = P_Item_Templates_Rec.CREATION_DATE,
        CREATED_BY = P_Item_Templates_Rec.CREATED_BY,
        LAST_UPDATE_LOGIN = P_Item_Templates_Rec.LAST_UPDATE_LOGIN,
        ATTRIBUTE_CATEGORY = P_Item_Templates_Rec.ATTRIBUTE_CATEGORY,
        ATTRIBUTE1 = P_Item_Templates_Rec.ATTRIBUTE1,
        ATTRIBUTE2 = P_Item_Templates_Rec.ATTRIBUTE2,
        ATTRIBUTE3 = P_Item_Templates_Rec.ATTRIBUTE3,
        ATTRIBUTE4 = P_Item_Templates_Rec.ATTRIBUTE4,
        ATTRIBUTE5 = P_Item_Templates_Rec.ATTRIBUTE5,
        ATTRIBUTE6 = P_Item_Templates_Rec.ATTRIBUTE6,
        ATTRIBUTE7 = P_Item_Templates_Rec.ATTRIBUTE7,
        ATTRIBUTE8 = P_Item_Templates_Rec.ATTRIBUTE8,
        ATTRIBUTE9 = P_Item_Templates_Rec.ATTRIBUTE9,
        ATTRIBUTE10 = P_Item_Templates_Rec.ATTRIBUTE10,
        ATTRIBUTE11 = P_Item_Templates_Rec.ATTRIBUTE11,
        ATTRIBUTE12 = P_Item_Templates_Rec.ATTRIBUTE12,
        ATTRIBUTE13 = P_Item_Templates_Rec.ATTRIBUTE13,
        ATTRIBUTE14 = P_Item_Templates_Rec.ATTRIBUTE14,
        ATTRIBUTE15 = P_Item_Templates_Rec.ATTRIBUTE15,
        REQUEST_ID = P_Item_Templates_Rec.REQUEST_ID,
        PROGRAM_APPLICATION_ID = P_Item_Templates_Rec.PROGRAM_APPLICATION_ID,
        PROGRAM_ID = P_Item_Templates_Rec.PROGRAM_ID,
        PROGRAM_UPDATE_DATE = P_Item_Templates_Rec.PROGRAM_UPDATE_DATE ,
        CONTEXT_ORGANIZATION_ID = P_Item_Templates_Rec.CONTEXT_ORGANIZATION_ID,
        GLOBAL_ATTRIBUTE_CATEGORY = P_Item_Templates_Rec.GLOBAL_ATTRIBUTE_CATEGORY ,
        GLOBAL_ATTRIBUTE1 = P_Item_Templates_Rec.GLOBAL_ATTRIBUTE1,
        GLOBAL_ATTRIBUTE2 = P_Item_Templates_Rec.GLOBAL_ATTRIBUTE2,
        GLOBAL_ATTRIBUTE3 = P_Item_Templates_Rec.GLOBAL_ATTRIBUTE3,
        GLOBAL_ATTRIBUTE4 = P_Item_Templates_Rec.GLOBAL_ATTRIBUTE4,
        GLOBAL_ATTRIBUTE5 = P_Item_Templates_Rec.GLOBAL_ATTRIBUTE5,
        GLOBAL_ATTRIBUTE6 = P_Item_Templates_Rec.GLOBAL_ATTRIBUTE6,
        GLOBAL_ATTRIBUTE7 = P_Item_Templates_Rec.GLOBAL_ATTRIBUTE7,
        GLOBAL_ATTRIBUTE8 = P_Item_Templates_Rec.GLOBAL_ATTRIBUTE8,
        GLOBAL_ATTRIBUTE9 = P_Item_Templates_Rec.GLOBAL_ATTRIBUTE9,
        GLOBAL_ATTRIBUTE10 = P_Item_Templates_Rec.GLOBAL_ATTRIBUTE10,
        GLOBAL_ATTRIBUTE11 = P_Item_Templates_Rec.GLOBAL_ATTRIBUTE11,
        GLOBAL_ATTRIBUTE12 = P_Item_Templates_Rec.GLOBAL_ATTRIBUTE12,
        GLOBAL_ATTRIBUTE13 = P_Item_Templates_Rec.GLOBAL_ATTRIBUTE13,
        GLOBAL_ATTRIBUTE14 = P_Item_Templates_Rec.GLOBAL_ATTRIBUTE14,
        GLOBAL_ATTRIBUTE15 = P_Item_Templates_Rec.GLOBAL_ATTRIBUTE15,
        GLOBAL_ATTRIBUTE16 = P_Item_Templates_Rec.GLOBAL_ATTRIBUTE16,
        GLOBAL_ATTRIBUTE17 = P_Item_Templates_Rec.GLOBAL_ATTRIBUTE17,
        GLOBAL_ATTRIBUTE18 = P_Item_Templates_Rec.GLOBAL_ATTRIBUTE18,
        GLOBAL_ATTRIBUTE19 = P_Item_Templates_Rec.GLOBAL_ATTRIBUTE19,
        GLOBAL_ATTRIBUTE20 = P_Item_Templates_Rec.GLOBAL_ATTRIBUTE20
   WHERE TEMPLATE_ID = P_Item_Templates_Rec.TEMPLATE_ID;

   IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
   END IF;

   UPDATE MTL_ITEM_TEMPLATES_TL set
      TEMPLATE_NAME     = P_Item_Templates_Rec.TEMPLATE_NAME,
      DESCRIPTION       = P_Item_Templates_Rec.DESCRIPTION,
      LAST_UPDATE_DATE  = P_Item_Templates_Rec.LAST_UPDATE_DATE,
      LAST_UPDATED_BY   = P_Item_Templates_Rec.LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN = P_Item_Templates_Rec.LAST_UPDATE_LOGIN,
      SOURCE_LANG       = USERENV('LANG')
   WHERE TEMPLATE_ID = P_Item_Templates_Rec.TEMPLATE_ID
   AND  USERENV('LANG')   IN (LANGUAGE, SOURCE_LANG);

   IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
   END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
       app_exception.raise_exception;

END UPDATE_ROW;

PROCEDURE DELETE_ROW (P_Template_Id IN NUMBER) IS
BEGIN

   DELETE FROM MTL_ITEM_TEMPLATES_TL
   WHERE TEMPLATE_ID = P_Template_Id;

   IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
   END IF;

   DELETE FROM MTL_ITEM_TEMPLATES_B
   WHERE TEMPLATE_ID = P_Template_Id;

   IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
   END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
       app_exception.raise_exception;
END DELETE_ROW;

PROCEDURE ADD_LANGUAGE IS
BEGIN
   DELETE FROM MTL_ITEM_TEMPLATES_TL T
   WHERE NOT EXISTS(SELECT NULL
                    FROM MTL_ITEM_TEMPLATES_B B
                    WHERE B.TEMPLATE_ID = T.TEMPLATE_ID);

   UPDATE MTL_ITEM_TEMPLATES_TL T
   SET (TEMPLATE_NAME,DESCRIPTION) = (SELECT B.TEMPLATE_NAME,B.DESCRIPTION
                        FROM   MTL_ITEM_TEMPLATES_TL B
                        WHERE  B.TEMPLATE_ID = T.TEMPLATE_ID
                        AND    B.LANGUAGE          = T.SOURCE_LANG)
   WHERE (T.TEMPLATE_ID,
          T.LANGUAGE) IN (SELECT SUBT.TEMPLATE_ID,
                                 SUBT.LANGUAGE
                          FROM   MTL_ITEM_TEMPLATES_TL SUBT,
                  MTL_ITEM_TEMPLATES_TL SUBB
                          WHERE  SUBB.TEMPLATE_ID = SUBT.TEMPLATE_ID
                          AND    SUBB.LANGUAGE = SUBT.SOURCE_LANG
                          AND   (SUBB.DESCRIPTION <> SUBT.DESCRIPTION
                                or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
                                or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null))
           AND (SUBB.TEMPLATE_NAME <> SUBT.TEMPLATE_NAME
                                or (SUBB.TEMPLATE_NAME is null and SUBT.TEMPLATE_NAME is not null)
            or (SUBB.TEMPLATE_NAME is not null and SUBT.TEMPLATE_NAME is null)));

   INSERT INTO MTL_ITEM_TEMPLATES_TL (
    TEMPLATE_ID,
    TEMPLATE_NAME,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
   ) SELECT B.TEMPLATE_ID,
            B.TEMPLATE_NAME,
            B.DESCRIPTION,
            B.CREATION_DATE,
            B.CREATED_BY,
            B.LAST_UPDATE_DATE,
            B.LAST_UPDATED_BY,
            B.LAST_UPDATE_LOGIN,
            L.LANGUAGE_CODE,
            B.SOURCE_LANG
     FROM  MTL_ITEM_TEMPLATES_TL B,
           FND_LANGUAGES L
     WHERE L.INSTALLED_FLAG IN ('I', 'B')
     AND   B.LANGUAGE = USERENV('LANG')
     AND  NOT EXISTS (SELECT NULL
                      FROM MTL_ITEM_TEMPLATES_TL T
                      WHERE T.TEMPLATE_ID = B.TEMPLATE_ID
                      AND T.LANGUAGE      = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end MTL_ITEM_TEMPLATES_PKG;

/
