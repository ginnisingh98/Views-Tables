--------------------------------------------------------
--  DDL for Package Body MTL_CROSS_REFERENCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MTL_CROSS_REFERENCES_PKG" AS
/* $Header: INVIDXRB.pls 120.0 2005/06/22 23:08:19 lparihar noship $ */

   PROCEDURE INSERT_ROW (
         P_SOURCE_SYSTEM_ID       IN NUMBER
        ,P_START_DATE_ACTIVE      IN DATE
        ,P_END_DATE_ACTIVE        IN DATE
        ,P_OBJECT_VERSION_NUMBER  IN NUMBER
        ,P_UOM_CODE               IN VARCHAR2
        ,P_REVISION_ID            IN NUMBER
        ,P_EPC_GTIN_SERIAL        IN NUMBER
        ,P_INVENTORY_ITEM_ID      IN NUMBER
        ,P_ORGANIZATION_ID        IN NUMBER
        ,P_CROSS_REFERENCE_TYPE   IN VARCHAR2
        ,P_CROSS_REFERENCE        IN VARCHAR2
        ,P_ORG_INDEPENDENT_FLAG   IN VARCHAR2
        ,P_REQUEST_ID             IN NUMBER
        ,P_ATTRIBUTE1             IN VARCHAR2
        ,P_ATTRIBUTE2             IN VARCHAR2
        ,P_ATTRIBUTE3             IN VARCHAR2
        ,P_ATTRIBUTE4             IN VARCHAR2
        ,P_ATTRIBUTE5             IN VARCHAR2
        ,P_ATTRIBUTE6             IN VARCHAR2
        ,P_ATTRIBUTE7             IN VARCHAR2
        ,P_ATTRIBUTE8             IN VARCHAR2
        ,P_ATTRIBUTE9             IN VARCHAR2
        ,P_ATTRIBUTE10            IN VARCHAR2
        ,P_ATTRIBUTE11            IN VARCHAR2
        ,P_ATTRIBUTE12            IN VARCHAR2
        ,P_ATTRIBUTE13            IN VARCHAR2
        ,P_ATTRIBUTE14            IN VARCHAR2
        ,P_ATTRIBUTE15            IN VARCHAR2
        ,P_ATTRIBUTE_CATEGORY     IN VARCHAR2
        ,P_DESCRIPTION            IN VARCHAR2
        ,P_CREATION_DATE          IN DATE
        ,P_CREATED_BY             IN NUMBER
        ,P_LAST_UPDATE_DATE       IN DATE
        ,P_LAST_UPDATED_BY        IN NUMBER
        ,P_LAST_UPDATE_LOGIN      IN NUMBER
        ,P_PROGRAM_APPLICATION_ID IN NUMBER
        ,P_PROGRAM_ID             IN NUMBER
        ,P_PROGRAM_UPDATE_DATE    IN DATE
        ,X_CROSS_REFERENCE_ID     OUT NOCOPY NUMBER) IS

    CURSOR C_CHECK_INSERT IS
       SELECT 'Y'
       FROM   MTL_CROSS_REFERENCES_B
       WHERE  CROSS_REFERENCE_ID = X_CROSS_REFERENCE_ID;

     l_exists VARCHAR2(1);

   BEGIN

      INSERT INTO MTL_CROSS_REFERENCES_B (
             SOURCE_SYSTEM_ID
            ,START_DATE_ACTIVE
            ,END_DATE_ACTIVE
            ,OBJECT_VERSION_NUMBER
            ,UOM_CODE
            ,REVISION_ID
            ,CROSS_REFERENCE_ID
            ,EPC_GTIN_SERIAL
            ,INVENTORY_ITEM_ID
            ,ORGANIZATION_ID
            ,CROSS_REFERENCE_TYPE
            ,CROSS_REFERENCE
            ,ORG_INDEPENDENT_FLAG
            ,REQUEST_ID
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
            ,CREATION_DATE
            ,CREATED_BY
            ,LAST_UPDATE_DATE
            ,LAST_UPDATED_BY
            ,LAST_UPDATE_LOGIN
            ,PROGRAM_APPLICATION_ID
            ,PROGRAM_ID
            ,PROGRAM_UPDATE_DATE)
      VALUES(
             P_SOURCE_SYSTEM_ID
            ,P_START_DATE_ACTIVE
            ,P_END_DATE_ACTIVE
            ,NVL(P_OBJECT_VERSION_NUMBER,1)
            ,P_UOM_CODE
            ,P_REVISION_ID
            ,MTL_CROSS_REFERENCES_B_S.NEXTVAL
            ,NVL(P_EPC_GTIN_SERIAL,0)
            ,P_INVENTORY_ITEM_ID
            ,P_ORGANIZATION_ID
            ,P_CROSS_REFERENCE_TYPE
            ,P_CROSS_REFERENCE
            ,P_ORG_INDEPENDENT_FLAG
            ,P_REQUEST_ID
            ,P_ATTRIBUTE1
            ,P_ATTRIBUTE2
            ,P_ATTRIBUTE3
            ,P_ATTRIBUTE4
            ,P_ATTRIBUTE5
            ,P_ATTRIBUTE6
            ,P_ATTRIBUTE7
            ,P_ATTRIBUTE8
            ,P_ATTRIBUTE9
            ,P_ATTRIBUTE10
            ,P_ATTRIBUTE11
            ,P_ATTRIBUTE12
            ,P_ATTRIBUTE13
            ,P_ATTRIBUTE14
            ,P_ATTRIBUTE15
            ,P_ATTRIBUTE_CATEGORY
            ,NVL(P_CREATION_DATE,SYSDATE)
            ,NVL(P_CREATED_BY,FND_GLOBAL.USER_ID)
            ,NVL(P_LAST_UPDATE_DATE,SYSDATE)
            ,NVL(P_LAST_UPDATED_BY,FND_GLOBAL.USER_ID)
            ,NVL(P_LAST_UPDATE_LOGIN,FND_GLOBAL.LOGIN_ID)
            ,P_PROGRAM_APPLICATION_ID
            ,P_PROGRAM_ID
            ,P_PROGRAM_UPDATE_DATE)
      RETURNING CROSS_REFERENCE_ID INTO X_CROSS_REFERENCE_ID ;

      INSERT INTO MTL_CROSS_REFERENCES_TL (
             LAST_UPDATE_LOGIN
            ,DESCRIPTION
            ,CREATION_DATE
            ,CREATED_BY
            ,LAST_UPDATE_DATE
            ,LAST_UPDATED_BY
            ,CROSS_REFERENCE_ID
            ,LANGUAGE
            ,SOURCE_LANG)
      SELECT
            NVL(P_LAST_UPDATE_LOGIN,FND_GLOBAL.LOGIN_ID),
            P_DESCRIPTION,
            NVL(P_CREATION_DATE,SYSDATE),
            NVL(P_CREATED_BY,FND_GLOBAL.USER_ID),
            NVL(P_LAST_UPDATE_DATE,SYSDATE),
            NVL(P_LAST_UPDATED_BY,FND_GLOBAL.USER_ID),
            X_CROSS_REFERENCE_ID,
            L.LANGUAGE_CODE,
            USERENV('LANG')
      FROM  FND_LANGUAGES L
      WHERE L.INSTALLED_FLAG in ('I', 'B')
      AND   NOT EXISTS  (SELECT NULL
                         FROM   MTL_CROSS_REFERENCES_TL T
                        WHERE   T.CROSS_REFERENCE_ID = X_CROSS_REFERENCE_ID
                        AND     T.LANGUAGE = L.LANGUAGE_CODE);

      OPEN C_CHECK_INSERT;
      FETCH C_CHECK_INSERT INTO l_exists;
      IF (C_CHECK_INSERT%NOTFOUND) THEN
         CLOSE C_CHECK_INSERT;
         RAISE NO_DATA_FOUND;
      END IF;
      CLOSE C_CHECK_INSERT;
   END INSERT_ROW;

   PROCEDURE LOCK_ROW (
         P_CROSS_REFERENCE_ID     IN NUMBER
        ,P_SOURCE_SYSTEM_ID       IN NUMBER
        ,P_START_DATE_ACTIVE      IN DATE
        ,P_END_DATE_ACTIVE        IN DATE
        ,P_OBJECT_VERSION_NUMBER  IN NUMBER
        ,P_UOM_CODE               IN VARCHAR2
        ,P_REVISION_ID            IN NUMBER
        ,P_EPC_GTIN_SERIAL        IN NUMBER
        ,P_INVENTORY_ITEM_ID      IN NUMBER
        ,P_ORGANIZATION_ID        IN NUMBER
        ,P_CROSS_REFERENCE_TYPE   IN VARCHAR2
        ,P_CROSS_REFERENCE        IN VARCHAR2
        ,P_ORG_INDEPENDENT_FLAG   IN VARCHAR2
        ,P_ATTRIBUTE1             IN VARCHAR2
        ,P_ATTRIBUTE2             IN VARCHAR2
        ,P_ATTRIBUTE3             IN VARCHAR2
        ,P_ATTRIBUTE4             IN VARCHAR2
        ,P_ATTRIBUTE5             IN VARCHAR2
        ,P_ATTRIBUTE6             IN VARCHAR2
        ,P_ATTRIBUTE7             IN VARCHAR2
        ,P_ATTRIBUTE8             IN VARCHAR2
        ,P_ATTRIBUTE9             IN VARCHAR2
        ,P_ATTRIBUTE10            IN VARCHAR2
        ,P_ATTRIBUTE11            IN VARCHAR2
        ,P_ATTRIBUTE12            IN VARCHAR2
        ,P_ATTRIBUTE13            IN VARCHAR2
        ,P_ATTRIBUTE14            IN VARCHAR2
        ,P_ATTRIBUTE15            IN VARCHAR2
        ,P_ATTRIBUTE_CATEGORY     IN VARCHAR2
        ,P_DESCRIPTION            IN VARCHAR2) IS

   CURSOR C_CROSS_REF_B IS
      SELECT
          SOURCE_SYSTEM_ID
         ,START_DATE_ACTIVE
         ,END_DATE_ACTIVE
         ,OBJECT_VERSION_NUMBER
         ,UOM_CODE
         ,REVISION_ID
         ,EPC_GTIN_SERIAL
         ,INVENTORY_ITEM_ID
         ,ORGANIZATION_ID
         ,CROSS_REFERENCE_TYPE
         ,CROSS_REFERENCE
         ,ORG_INDEPENDENT_FLAG
         ,REQUEST_ID
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
      FROM MTL_CROSS_REFERENCES_B
      WHERE CROSS_REFERENCE_ID = P_CROSS_REFERENCE_ID
      FOR UPDATE OF CROSS_REFERENCE_ID NOWAIT;

   CURSOR C_CROSS_REF_TL IS
      SELECT
          DESCRIPTION
         ,DECODE(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
      FROM MTL_CROSS_REFERENCES_TL
      WHERE CROSS_REFERENCE_ID = P_CROSS_REFERENCE_ID
      AND   USERENV('LANG') IN (LANGUAGE, SOURCE_LANG)
      FOR UPDATE OF CROSS_REFERENCE_ID NOWAIT;

      l_recinfo C_CROSS_REF_B%ROWTYPE;

   BEGIN

      OPEN C_CROSS_REF_B;
      FETCH C_CROSS_REF_B INTO l_recinfo;
      IF (C_CROSS_REF_B%NOTFOUND) THEN
         CLOSE C_CROSS_REF_B;
         FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
         APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
      CLOSE C_CROSS_REF_B;

      IF (((l_recinfo.SOURCE_SYSTEM_ID = P_SOURCE_SYSTEM_ID)
           OR ((l_recinfo.SOURCE_SYSTEM_ID is null) AND (P_SOURCE_SYSTEM_ID is null)))
      AND ((l_recinfo.OBJECT_VERSION_NUMBER = P_OBJECT_VERSION_NUMBER)
           OR ((l_recinfo.OBJECT_VERSION_NUMBER is null) AND (P_OBJECT_VERSION_NUMBER is null)))
      AND ((l_recinfo.UOM_CODE = P_UOM_CODE)
           OR ((l_recinfo.UOM_CODE is null) AND (P_UOM_CODE is null)))
      AND ((l_recinfo.REVISION_ID = P_REVISION_ID)
           OR ((l_recinfo.REVISION_ID is null) AND (P_REVISION_ID is null)))
      AND ((l_recinfo.EPC_GTIN_SERIAL = P_EPC_GTIN_SERIAL)
           OR ((l_recinfo.EPC_GTIN_SERIAL is null) AND (P_EPC_GTIN_SERIAL is null)))
      AND (l_recinfo.INVENTORY_ITEM_ID = P_INVENTORY_ITEM_ID)
      AND ((l_recinfo.ORGANIZATION_ID = P_ORGANIZATION_ID)
           OR ((l_recinfo.ORGANIZATION_ID is null) AND (P_ORGANIZATION_ID is null)))
      AND (l_recinfo.CROSS_REFERENCE_TYPE = P_CROSS_REFERENCE_TYPE)
      AND (l_recinfo.CROSS_REFERENCE = P_CROSS_REFERENCE)
      AND (l_recinfo.ORG_INDEPENDENT_FLAG = P_ORG_INDEPENDENT_FLAG)
      AND ((l_recinfo.ATTRIBUTE1 = P_ATTRIBUTE1)
           OR ((l_recinfo.ATTRIBUTE1 is null) AND (P_ATTRIBUTE1 is null)))
      AND ((l_recinfo.ATTRIBUTE2 = P_ATTRIBUTE2)
           OR ((l_recinfo.ATTRIBUTE2 is null) AND (P_ATTRIBUTE2 is null)))
      AND ((l_recinfo.ATTRIBUTE3 = P_ATTRIBUTE3)
           OR ((l_recinfo.ATTRIBUTE3 is null) AND (P_ATTRIBUTE3 is null)))
      AND ((l_recinfo.ATTRIBUTE4 = P_ATTRIBUTE4)
           OR ((l_recinfo.ATTRIBUTE4 is null) AND (P_ATTRIBUTE4 is null)))
      AND ((l_recinfo.ATTRIBUTE5 = P_ATTRIBUTE5)
           OR ((l_recinfo.ATTRIBUTE5 is null) AND (P_ATTRIBUTE5 is null)))
      AND ((l_recinfo.ATTRIBUTE6 = P_ATTRIBUTE6)
           OR ((l_recinfo.ATTRIBUTE6 is null) AND (P_ATTRIBUTE6 is null)))
      AND ((l_recinfo.ATTRIBUTE7 = P_ATTRIBUTE7)
           OR ((l_recinfo.ATTRIBUTE7 is null) AND (P_ATTRIBUTE7 is null)))
      AND ((l_recinfo.ATTRIBUTE8 = P_ATTRIBUTE8)
           OR ((l_recinfo.ATTRIBUTE8 is null) AND (P_ATTRIBUTE8 is null)))
      AND ((l_recinfo.ATTRIBUTE9 = P_ATTRIBUTE9)
           OR ((l_recinfo.ATTRIBUTE9 is null) AND (P_ATTRIBUTE9 is null)))
      AND ((l_recinfo.ATTRIBUTE10 = P_ATTRIBUTE10)
           OR ((l_recinfo.ATTRIBUTE10 is null) AND (P_ATTRIBUTE10 is null)))
      AND ((l_recinfo.ATTRIBUTE11 = P_ATTRIBUTE11)
           OR ((l_recinfo.ATTRIBUTE11 is null) AND (P_ATTRIBUTE11 is null)))
      AND ((l_recinfo.ATTRIBUTE12 = P_ATTRIBUTE12)
           OR ((l_recinfo.ATTRIBUTE12 is null) AND (P_ATTRIBUTE12 is null)))
      AND ((l_recinfo.ATTRIBUTE13 = P_ATTRIBUTE13)
           OR ((l_recinfo.ATTRIBUTE13 is null) AND (P_ATTRIBUTE13 is null)))
      AND ((l_recinfo.ATTRIBUTE14 = P_ATTRIBUTE14)
           OR ((l_recinfo.ATTRIBUTE14 is null) AND (P_ATTRIBUTE14 is null)))
      AND ((l_recinfo.ATTRIBUTE15 = P_ATTRIBUTE15)
           OR ((l_recinfo.ATTRIBUTE15 is null) AND (P_ATTRIBUTE15 is null)))
      AND ((l_recinfo.ATTRIBUTE_CATEGORY = P_ATTRIBUTE_CATEGORY)
           OR ((l_recinfo.ATTRIBUTE_CATEGORY is null) AND (P_ATTRIBUTE_CATEGORY is null))))
      THEN
         NULL;
      ELSE
         FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
         APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;

     FOR cur IN C_CROSS_REF_TL LOOP
        IF (cur.BASELANG = 'Y') THEN
           IF (((cur.DESCRIPTION = P_DESCRIPTION)
               OR ((cur.DESCRIPTION is null) AND (P_DESCRIPTION is null))))
           THEN
              NULL;
           ELSE
              FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
              APP_EXCEPTION.RAISE_EXCEPTION;
           END IF;
        END IF;
     END LOOP;

   END LOCK_ROW;

   PROCEDURE UPDATE_ROW (
         P_CROSS_REFERENCE_ID     IN NUMBER
        ,P_SOURCE_SYSTEM_ID       IN NUMBER
        ,P_START_DATE_ACTIVE      IN DATE
        ,P_END_DATE_ACTIVE        IN DATE
        ,P_UOM_CODE               IN VARCHAR2
        ,P_REVISION_ID            IN NUMBER
        ,P_EPC_GTIN_SERIAL        IN NUMBER
        ,P_INVENTORY_ITEM_ID      IN NUMBER
        ,P_ORGANIZATION_ID        IN NUMBER
        ,P_CROSS_REFERENCE_TYPE   IN VARCHAR2
        ,P_CROSS_REFERENCE        IN VARCHAR2
        ,P_ORG_INDEPENDENT_FLAG   IN VARCHAR2
        ,P_REQUEST_ID             IN NUMBER
        ,P_ATTRIBUTE1             IN VARCHAR2
        ,P_ATTRIBUTE2             IN VARCHAR2
        ,P_ATTRIBUTE3             IN VARCHAR2
        ,P_ATTRIBUTE4             IN VARCHAR2
        ,P_ATTRIBUTE5             IN VARCHAR2
        ,P_ATTRIBUTE6             IN VARCHAR2
        ,P_ATTRIBUTE7             IN VARCHAR2
        ,P_ATTRIBUTE8             IN VARCHAR2
        ,P_ATTRIBUTE9             IN VARCHAR2
        ,P_ATTRIBUTE10            IN VARCHAR2
        ,P_ATTRIBUTE11            IN VARCHAR2
        ,P_ATTRIBUTE12            IN VARCHAR2
        ,P_ATTRIBUTE13            IN VARCHAR2
        ,P_ATTRIBUTE14            IN VARCHAR2
        ,P_ATTRIBUTE15            IN VARCHAR2
        ,P_ATTRIBUTE_CATEGORY     IN VARCHAR2
        ,P_DESCRIPTION            IN VARCHAR2
        ,P_LAST_UPDATE_DATE       IN DATE
        ,P_LAST_UPDATED_BY        IN NUMBER
        ,P_LAST_UPDATE_LOGIN      IN NUMBER
        ,X_OBJECT_VERSION_NUMBER  OUT NOCOPY NUMBER) IS
   BEGIN
      UPDATE MTL_CROSS_REFERENCES_B
      SET
             SOURCE_SYSTEM_ID      = P_SOURCE_SYSTEM_ID
            ,START_DATE_ACTIVE     = P_START_DATE_ACTIVE
            ,END_DATE_ACTIVE       = P_END_DATE_ACTIVE
            ,OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER+1
            ,UOM_CODE              = P_UOM_CODE
            ,REVISION_ID           = P_REVISION_ID
            ,EPC_GTIN_SERIAL       = NVL(P_EPC_GTIN_SERIAL,EPC_GTIN_SERIAL)
            ,INVENTORY_ITEM_ID     = P_INVENTORY_ITEM_ID
            ,ORGANIZATION_ID       = P_ORGANIZATION_ID
            ,CROSS_REFERENCE_TYPE  = P_CROSS_REFERENCE_TYPE
            ,CROSS_REFERENCE       = P_CROSS_REFERENCE
            ,ORG_INDEPENDENT_FLAG  = P_ORG_INDEPENDENT_FLAG
            ,REQUEST_ID            = P_REQUEST_ID
            ,ATTRIBUTE1            = P_ATTRIBUTE1
            ,ATTRIBUTE2            = P_ATTRIBUTE2
            ,ATTRIBUTE3            = P_ATTRIBUTE3
            ,ATTRIBUTE4            = P_ATTRIBUTE4
            ,ATTRIBUTE5            = P_ATTRIBUTE5
            ,ATTRIBUTE6            = P_ATTRIBUTE6
            ,ATTRIBUTE7            = P_ATTRIBUTE7
            ,ATTRIBUTE8            = P_ATTRIBUTE8
            ,ATTRIBUTE9            = P_ATTRIBUTE9
            ,ATTRIBUTE10           = P_ATTRIBUTE10
            ,ATTRIBUTE11           = P_ATTRIBUTE11
            ,ATTRIBUTE12           = P_ATTRIBUTE12
            ,ATTRIBUTE13           = P_ATTRIBUTE13
            ,ATTRIBUTE14           = P_ATTRIBUTE14
            ,ATTRIBUTE15           = P_ATTRIBUTE15
            ,ATTRIBUTE_CATEGORY    = P_ATTRIBUTE_CATEGORY
            ,LAST_UPDATE_DATE      = NVL(P_LAST_UPDATE_DATE,SYSDATE)
            ,LAST_UPDATED_BY       = NVL(P_LAST_UPDATED_BY,FND_GLOBAL.USER_ID)
            ,LAST_UPDATE_LOGIN     = NVL(P_LAST_UPDATE_LOGIN,FND_GLOBAL.LOGIN_ID)
      WHERE CROSS_REFERENCE_ID = P_CROSS_REFERENCE_ID
      RETURNING OBJECT_VERSION_NUMBER INTO X_OBJECT_VERSION_NUMBER;

      IF (SQL%NOTFOUND) THEN
         RAISE NO_DATA_FOUND;
      END IF;

      UPDATE MTL_CROSS_REFERENCES_TL
      SET    DESCRIPTION       = P_DESCRIPTION,
             LAST_UPDATE_DATE  = NVL(P_LAST_UPDATE_DATE,SYSDATE),
             LAST_UPDATED_BY   = NVL(P_LAST_UPDATE_LOGIN,FND_GLOBAL.USER_ID),
             LAST_UPDATE_LOGIN = NVL(P_LAST_UPDATED_BY,FND_GLOBAL.LOGIN_ID),
             SOURCE_LANG       = USERENV('LANG')
      WHERE CROSS_REFERENCE_ID = P_CROSS_REFERENCE_ID
      AND   USERENV('LANG') IN (LANGUAGE, SOURCE_LANG);

      IF (SQL%NOTFOUND) THEN
         RAISE NO_DATA_FOUND;
      END IF;

   END UPDATE_ROW;

   PROCEDURE DELETE_ROW (P_CROSS_REFERENCE_ID IN NUMBER) IS
   BEGIN

      DELETE FROM MTL_CROSS_REFERENCES_TL
      WHERE CROSS_REFERENCE_ID = P_CROSS_REFERENCE_ID;

      IF (SQL%NOTFOUND) THEN
         RAISE NO_DATA_FOUND;
      END IF;

      DELETE FROM MTL_CROSS_REFERENCES_B
      WHERE CROSS_REFERENCE_ID = P_CROSS_REFERENCE_ID;

      IF (SQL%NOTFOUND) THEN
         RAISE NO_DATA_FOUND;
      END IF;

   END DELETE_ROW;

   PROCEDURE ADD_LANGUAGE IS
   BEGIN
      DELETE MTL_CROSS_REFERENCES_TL T
      WHERE NOT EXISTS (SELECT NULL
                        FROM   MTL_CROSS_REFERENCES_B B
                        WHERE  B.CROSS_REFERENCE_ID = T.CROSS_REFERENCE_ID);

      UPDATE MTL_CROSS_REFERENCES_TL T
      SET (DESCRIPTION) = (SELECT B.DESCRIPTION
                           FROM   MTL_CROSS_REFERENCES_TL B
                           WHERE  B.CROSS_REFERENCE_ID = T.CROSS_REFERENCE_ID
                           AND    B.LANGUAGE = T.SOURCE_LANG)
      WHERE (T.CROSS_REFERENCE_ID,T.LANGUAGE) IN
            (SELECT SUBT.CROSS_REFERENCE_ID
                   ,SUBT.LANGUAGE
             FROM MTL_CROSS_REFERENCES_TL SUBB,
                  MTL_CROSS_REFERENCES_TL SUBT
             WHERE SUBB.CROSS_REFERENCE_ID = SUBT.CROSS_REFERENCE_ID
             AND   SUBB.LANGUAGE = SUBT.SOURCE_LANG
             AND  (SUBB.DESCRIPTION <> SUBT.DESCRIPTION
               OR (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
               OR (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)));

      INSERT INTO MTL_CROSS_REFERENCES_TL (
             LAST_UPDATE_LOGIN
            ,DESCRIPTION
            ,CREATION_DATE
            ,CREATED_BY
            ,LAST_UPDATE_DATE
            ,LAST_UPDATED_BY
            ,CROSS_REFERENCE_ID
            ,LANGUAGE
            ,SOURCE_LANG)
      SELECT /*+ ORDERED */
             B.LAST_UPDATE_LOGIN
            ,B.DESCRIPTION
            ,B.CREATION_DATE
            ,B.CREATED_BY
            ,B.LAST_UPDATE_DATE
            ,B.LAST_UPDATED_BY
            ,B.CROSS_REFERENCE_ID
            ,L.LANGUAGE_CODE
            ,B.SOURCE_LANG
      FROM  MTL_CROSS_REFERENCES_TL B,
            FND_LANGUAGES L
      WHERE L.INSTALLED_FLAG in ('I', 'B')
      AND   B.LANGUAGE = USERENV('LANG')
      AND   NOT EXISTS (SELECT NULL
                        FROM MTL_CROSS_REFERENCES_TL T
                        WHERE T.CROSS_REFERENCE_ID = B.CROSS_REFERENCE_ID
                        AND   T.LANGUAGE = L.LANGUAGE_CODE);
   END ADD_LANGUAGE;

END MTL_CROSS_REFERENCES_PKG;

/
