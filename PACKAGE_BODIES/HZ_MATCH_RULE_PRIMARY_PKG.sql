--------------------------------------------------------
--  DDL for Package Body HZ_MATCH_RULE_PRIMARY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_MATCH_RULE_PRIMARY_PKG" AS
/*$Header: ARHDQMPB.pls 120.6 2005/10/30 04:19:06 appldev noship $ */
PROCEDURE Insert_Row(
                    px_PRIMARY_ATTRIBUTE_ID IN OUT NOCOPY   NUMBER,
                    p_MATCH_RULE_ID                   NUMBER,
                    p_ATTRIBUTE_ID                    NUMBER,
                    p_ACTIVE_FLAG                     VARCHAR2,
                    p_FILTER_FLAG                     VARCHAR2,
                    p_CREATED_BY                      NUMBER,
                    p_CREATION_DATE                   DATE,
                    p_LAST_UPDATE_LOGIN               NUMBER,
                    p_LAST_UPDATE_DATE                DATE,
                    p_LAST_UPDATED_BY                 NUMBER,
                    p_OBJECT_VERSION_NUMBER           NUMBER,
		    p_DISPLAY_ORDER		      NUMBER DEFAULT NULL)
 IS
  CURSOR C2 IS SELECT  HZ_MATCH_RULE_PRIMARY_s.nextval FROM sys.dual;
  l_success VARCHAR2(1);
 BEGIN
   l_success := 'N';
   WHILE l_success = 'N' LOOP
   BEGIN
     IF ( px_PRIMARY_ATTRIBUTE_ID IS NULL) OR (px_PRIMARY_ATTRIBUTE_ID = FND_API.G_MISS_NUM) THEN
        OPEN C2;
        FETCH C2 INTO px_PRIMARY_ATTRIBUTE_ID;
        CLOSE C2;
     END IF;
     INSERT INTO HZ_MATCH_RULE_PRIMARY(
                PRIMARY_ATTRIBUTE_ID,
                MATCH_RULE_ID,
                ATTRIBUTE_ID,
                ACTIVE_FLAG,
                FILTER_FLAG,
                CREATED_BY,
                CREATION_DATE,
                LAST_UPDATE_LOGIN,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                OBJECT_VERSION_NUMBER,
		DISPLAY_ORDER
               )
               VALUES (
                px_PRIMARY_ATTRIBUTE_ID,
                decode(p_MATCH_RULE_ID,    FND_API.G_MISS_NUM, NULL, p_MATCH_RULE_ID),
                decode(p_ATTRIBUTE_ID,     FND_API.G_MISS_NUM, NULL, p_ATTRIBUTE_ID),
                decode(p_ACTIVE_FLAG,      FND_API.G_MISS_CHAR, NULL, p_ACTIVE_FLAG),
                decode(p_FILTER_FLAG,      FND_API.G_MISS_CHAR, NULL, p_FILTER_FLAG),
                decode(p_created_by,       FND_API.G_MISS_NUM,  NULL, p_created_by),
                decode(p_creation_date,    FND_API.G_MISS_DATE, to_date(NULL), p_creation_date),
                decode(p_last_update_login,FND_API.G_MISS_NUM,  NULL, p_last_update_login),
                decode(p_last_update_date, FND_API.G_MISS_DATE, to_date(NULL), p_last_update_date),
                decode(p_last_updated_by,  FND_API.G_MISS_NUM,  NULL, p_last_updated_by),
                1,
		decode(p_DISPLAY_ORDER, FND_API.G_MISS_NUM, NULL, p_DISPLAY_ORDER)
                );
      l_success := 'Y';
      EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
         IF INSTRB( SQLERRM, 'HZ_MATCH_RULE_PRIMARY_U1' ) <> 0 THEN
            DECLARE
              l_count             NUMBER;
              l_dummy             VARCHAR2(1);
            BEGIN
              l_count := 1;
              WHILE l_count > 0 LOOP
                 SELECT  HZ_MATCH_RULE_PRIMARY_s.nextval
		  into  px_PRIMARY_ATTRIBUTE_ID FROM sys.dual;
                 BEGIN
                  SELECT 'Y' INTO l_dummy
                  FROM HZ_MATCH_RULE_PRIMARY
                  WHERE PRIMARY_ATTRIBUTE_ID =  px_PRIMARY_ATTRIBUTE_ID;
                  l_count := 1;
                 EXCEPTION WHEN NO_DATA_FOUND THEN
                  l_count := 0;
                 END;
             END LOOP;
          END;
        END IF;
     END;
  END LOOP;
End Insert_Row;

    PROCEDURE Update_Row(
                    p_PRIMARY_ATTRIBUTE_ID           NUMBER,
                    p_MATCH_RULE_ID                   NUMBER,
                    p_ATTRIBUTE_ID                    NUMBER,
                    p_ACTIVE_FLAG                     VARCHAR2,
                    p_FILTER_FLAG                     VARCHAR2,
                    p_CREATED_BY                      NUMBER,
                    p_CREATION_DATE                   DATE,
                    p_LAST_UPDATE_LOGIN               NUMBER,
                    p_LAST_UPDATE_DATE                DATE,
                    p_LAST_UPDATED_BY                 NUMBER,
                    p_OBJECT_VERSION_NUMBER in out NOCOPY   NUMBER,
		    p_DISPLAY_ORDER		      NUMBER DEFAULT NULL
     ) IS

   l_object_version_number number;

   BEGIN

    l_object_version_number := NVL(p_object_version_number, 1) + 1;

   UPDATE hz_match_rule_primary
   SET
      MATCH_RULE_ID         = decode(p_MATCH_RULE_ID,     FND_API.G_MISS_NUM, MATCH_RULE_ID, p_MATCH_RULE_ID),
      ATTRIBUTE_ID          = decode(p_ATTRIBUTE_ID,     FND_API.G_MISS_NUM, ATTRIBUTE_ID, p_ATTRIBUTE_ID),
      ACTIVE_FLAG           = decode(p_ACTIVE_FLAG,      FND_API.G_MISS_CHAR, ACTIVE_FLAG, p_ACTIVE_FLAG),
      FILTER_FLAG           = decode(p_FILTER_FLAG,      FND_API.G_MISS_CHAR, FILTER_FLAG, p_FILTER_FLAG),
      -- Bug 3032780
      /*
      CREATED_BY            = decode(p_created_by,       FND_API.G_MISS_NUM,  CREATED_BY, p_created_by),
      CREATION_DATE         = decode(p_CREATION_DATE,    FND_API.G_MISS_DATE, CREATION_DATE,p_CREATION_DATE),
      */
      LAST_UPDATE_LOGIN     = decode(p_LAST_UPDATE_LOGIN,FND_API.G_MISS_NUM, LAST_UPDATE_LOGIN,p_LAST_UPDATE_LOGIN),
      LAST_UPDATE_DATE      = decode(p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE,LAST_UPDATE_DATE,p_LAST_UPDATE_DATE),
      LAST_UPDATED_BY       = decode(p_LAST_UPDATED_BY,  FND_API.G_MISS_NUM, LAST_UPDATED_BY,p_LAST_UPDATED_BY),
      OBJECT_VERSION_NUMBER = decode(l_OBJECT_VERSION_NUMBER,  FND_API.G_MISS_NUM, OBJECT_VERSION_NUMBER,l_object_version_number),
      DISPLAY_ORDER         = decode(p_DISPLAY_ORDER,   FND_API.G_MISS_NUM, DISPLAY_ORDER, p_DISPLAY_ORDER)
      WHERE PRIMARY_ATTRIBUTE_ID = P_PRIMARY_ATTRIBUTE_ID;

    p_OBJECT_VERSION_NUMBER := l_OBJECT_VERSION_NUMBER;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
 END Update_Row;

PROCEDURE Delete_Row(p_primary_attribute_id NUMBER) IS
BEGIN
   DELETE FROM HZ_MATCH_RULE_PRIMARY
   WHERE primary_attribute_id    =  p_primary_attribute_id;

   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;

PROCEDURE Lock_Row(
                    p_PRIMARY_ATTRIBUTE_ID  IN OUT  NOCOPY   NUMBER,
                    P_OBJECT_VERSION_NUMBER IN NUMBER
 ) IS
 CURSOR C IS

 SELECT OBJECT_VERSION_NUMBER
 FROM hz_match_rule_primary
 WHERE primary_attribute_id  = p_primary_attribute_id
 FOR UPDATE OF primary_attribute_id NOWAIT;
 Recinfo C%ROWTYPE;
 BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    If (C%NOTFOUND) then
        CLOSE C;
        FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
        APP_EXCEPTION.RAISE_EXCEPTION;
    End If;
    CLOSE C;

    if (
         ( Recinfo.OBJECT_VERSION_NUMBER IS NOT NULL AND p_OBJECT_VERSION_NUMBER IS NOT NULL
            AND  Recinfo.OBJECT_VERSION_NUMBER = p_OBJECT_VERSION_NUMBER )
         OR ((Recinfo.OBJECT_VERSION_NUMBER   IS NULL)AND (p_OBJECT_VERSION_NUMBER  IS NULL ))

      ) then
       return;
   else
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   End If;
END Lock_Row;

END HZ_MATCH_RULE_PRIMARY_PKG;

/
