--------------------------------------------------------
--  DDL for Package Body HZ_DUP_EXCLUSIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_DUP_EXCLUSIONS_PKG" AS
/*$Header: ARHDQDEB.pls 120.5 2005/06/16 21:10:30 jhuang noship $ */

PROCEDURE Insert_Row(
                      px_DUP_EXCLUSION_ID           IN OUT   NOCOPY NUMBER,
	                  p_PARTY_ID                          NUMBER,
                      p_DUP_PARTY_ID                NUMBER,
                      p_FROM_DATE                         DATE,
                      p_TO_DATE                           DATE,
 		              p_CREATED_BY                        NUMBER,
                      p_CREATION_DATE                     DATE,
                      p_LAST_UPDATE_LOGIN                 NUMBER,
                      p_LAST_UPDATE_DATE                  DATE,
                      p_LAST_UPDATED_BY                   NUMBER)
  IS
  CURSOR C2 IS SELECT  HZ_DUP_EXCLUSIONS_s.nextval FROM sys.dual;
 BEGIN
    IF ( px_DUP_EXCLUSION_ID IS NULL) OR (px_DUP_EXCLUSION_ID = FND_API.G_MISS_NUM) THEN
        OPEN C2;
        FETCH C2 INTO px_DUP_EXCLUSION_ID;
        CLOSE C2;
    END IF;

   INSERT INTO HZ_DUP_EXCLUSIONS(
                DUP_EXCLUSION_ID,
                PARTY_ID,
                DUP_PARTY_ID,
                FROM_DATE,
                TO_DATE,
                CREATED_BY,
                CREATION_DATE,
                LAST_UPDATE_LOGIN,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY
               )
               VALUES (
                px_DUP_EXCLUSION_ID,
                decode(p_PARTY_ID, FND_API.G_MISS_NUM, NULL,
                                   p_PARTY_ID),
                decode(p_DUP_PARTY_ID, FND_API.G_MISS_NUM, NULL,
                                   p_DUP_PARTY_ID),
                decode(p_from_date, FND_API.G_MISS_DATE, NULL,
                                        p_from_date),
                decode(p_to_date, FND_API.G_MISS_DATE, NULL,
                                        p_to_date),
                hz_utility_v2pub.created_by,
                hz_utility_v2pub.creation_date,
                hz_utility_v2pub.last_update_login,
                hz_utility_v2pub.last_update_date,
                hz_utility_v2pub.last_updated_by
              );

End Insert_Row;

PROCEDURE Update_Row(
                      p_DUP_EXCLUSION_ID                  NUMBER,
	              p_PARTY_ID                          NUMBER,
                      p_DUP_PARTY_ID                      NUMBER,
                      p_FROM_DATE                         DATE,
                      p_TO_DATE                           DATE,
                      p_CREATED_BY                        NUMBER,
                      p_CREATION_DATE                     DATE,
                      p_LAST_UPDATE_LOGIN                 NUMBER,
                      p_LAST_UPDATE_DATE                  DATE,
                      p_LAST_UPDATED_BY                   NUMBER
   ) IS
   BEGIN
   UPDATE HZ_DUP_EXCLUSIONS
   SET
    PARTY_ID             = decode(p_PARTY_ID, FND_API.G_MISS_NUM, NULL,
                                  p_PARTY_ID),
    DUP_PARTY_ID   = decode(p_DUP_PARTY_ID, FND_API.G_MISS_NUM, NULL,
                                  p_DUP_PARTY_ID),
    FROM_DATE            = decode(p_FROM_DATE,FND_API.G_MISS_DATE, NULL,
                                  p_FROM_DATE),
    TO_DATE              = decode(p_TO_DATE,FND_API.G_MISS_DATE, NULL,
                                  p_TO_DATE),
    CREATED_BY           = created_by,
    CREATION_DATE        = CREATION_DATE,
    LAST_UPDATE_LOGIN    = HZ_UTILITY_V2PUB.LAST_UPDATE_LOGIN,
    LAST_UPDATE_DATE       = HZ_UTILITY_V2PUB.LAST_UPDATE_DATE,
    LAST_UPDATED_BY        = hz_utility_v2pub.LAST_UPDATED_BY
    where DUP_exclusion_id = p_DUP_exclusion_id;


    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
 END Update_Row;

PROCEDURE Delete_Row(p_DUP_exclusion_id NUMBER) IS
BEGIN
   DELETE FROM hz_DUP_exclusions
   where DUP_exclusion_id = p_DUP_exclusion_id ;

   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;

PROCEDURE Lock_Row(
                    p_DUP_EXCLUSION_ID      IN OUT      NOCOPY NUMBER,
	            p_PARTY_ID                          NUMBER,
                    p_DUP_PARTY_ID                      NUMBER,
                    p_FROM_DATE                         DATE,
                    p_TO_DATE                           DATE,
                    p_CREATED_BY                        NUMBER,
                    p_CREATION_DATE                     DATE,
                    p_LAST_UPDATE_LOGIN                 NUMBER,
                    p_LAST_UPDATE_DATE                  DATE,
                    p_LAST_UPDATED_BY                   NUMBER
 ) IS
 CURSOR C IS
 SELECT *
 FROM hz_DUP_exclusions
 WHERE DUP_exclusion_id  = p_DUP_exclusion_id
 FOR UPDATE OF DUP_exclusion_id NOWAIT;
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
          (   (Recinfo.DUP_EXCLUSION_ID = p_DUP_EXCLUSION_ID)
           OR (     (Recinfo.DUP_EXCLUSION_ID IS NULL)
                AND  (p_DUP_EXCLUSION_ID IS NULL )))
    AND   (   (Recinfo.PARTY_ID = p_PARTY_ID)
           OR (      (Recinfo.PARTY_ID IS NULL)
                AND  (p_PARTY_ID IS NULL )))
    AND   (   (Recinfo.DUP_PARTY_ID = p_DUP_PARTY_ID)
           OR (      (Recinfo.DUP_PARTY_ID IS NULL)
                AND  (p_DUP_PARTY_ID IS NULL )))
    AND   (   (Recinfo.FROM_DATE = p_FROM_DATE)
           OR (      (Recinfo.FROM_DATE IS NULL)
                AND  (p_FROM_DATE IS NULL )))
    AND   (   (Recinfo.TO_DATE = p_TO_DATE)
           OR (      (Recinfo.TO_DATE IS NULL)
                AND  (p_TO_DATE IS NULL )))
    AND    (     (Recinfo.CREATED_BY = p_CREATED_BY )
             OR (     (Recinfo.CREATED_BY IS NULL)
                 AND (p_CREATED_BY IS NULL )))
    AND    (     (Recinfo.CREATION_DATE = p_CREATION_DATE)
             OR (     (Recinfo.CREATION_DATE IS NULL)
                 AND (p_CREATION_DATE  IS NULL )))
    AND    (     (Recinfo.LAST_UPDATE_LOGIN= p_LAST_UPDATE_LOGIN)
             OR (     (Recinfo.LAST_UPDATE_LOGIN  IS NULL)
                 AND (p_LAST_UPDATE_LOGIN  IS NULL )))
    AND    (     (Recinfo.LAST_UPDATE_DATE = p_LAST_UPDATE_DATE)
             OR (     (Recinfo.LAST_UPDATE_DATE   IS NULL)
                 AND (p_LAST_UPDATE_DATE  IS NULL )))
    AND    (      (Recinfo.LAST_UPDATED_BY = p_LAST_UPDATED_BY)
             OR (     (Recinfo.LAST_UPDATED_BY   IS NULL)
                  AND (p_LAST_UPDATED_BY   IS NULL )))
      ) then
       return;
   else
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   End If;
END Lock_Row;
END HZ_DUP_EXCLUSIONS_PKG;

/
