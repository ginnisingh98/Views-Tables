--------------------------------------------------------
--  DDL for Package Body HZ_DUP_SETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_DUP_SETS_PKG" AS
/*$Header: ARHDQDSB.pls 120.3 2005/06/16 21:10:48 jhuang ship $ */

PROCEDURE Insert_Row(
                      px_DUP_SET_ID              IN OUT   NOCOPY NUMBER,
	                  p_DUP_BATCH_ID                      NUMBER,
                      p_WINNER_PARTY_ID                   NUMBER,
                      p_STATUS                            VARCHAR2,
                      p_ASSIGNED_TO_USER_ID               NUMBER,
                      p_MERGE_TYPE                        VARCHAR2,
                      p_OBJECT_VERSION_NUMBER             NUMBER,
                      p_CREATED_BY                        NUMBER,
                      p_CREATION_DATE                     DATE,
                      p_LAST_UPDATE_LOGIN                 NUMBER,
                      p_LAST_UPDATE_DATE                  DATE,
                      p_LAST_UPDATED_BY                   NUMBER)
  IS
  CURSOR C2 IS SELECT  HZ_MERGE_BATCH_S.nextval FROM sys.dual;
 BEGIN

    IF ( px_DUP_SET_ID IS NULL) OR (px_DUP_SET_ID = FND_API.G_MISS_NUM) THEN
        OPEN C2;
        FETCH C2 INTO px_DUP_SET_ID;
        CLOSE C2;
    END IF;

   INSERT INTO HZ_DUP_SETS(
                DUP_SET_ID,
                DUP_BATCH_ID,
                WINNER_PARTY_ID,
                STATUS,
                ASSIGNED_TO_USER_ID,
                MERGE_TYPE,
                OBJECT_VERSION_NUMBER,
                CREATED_BY,
                CREATION_DATE,
                LAST_UPDATE_LOGIN,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY
               )
               VALUES (
                px_DUP_SET_ID,
                decode(p_DUP_BATCH_ID,  FND_API.G_MISS_NUM, NULL,
                                        p_DUP_BATCH_ID),
                decode(p_WINNER_PARTY_ID,FND_API.G_MISS_NUM, NULL,
                                         p_WINNER_PARTY_ID),
                decode(p_STATUS,FND_API.G_MISS_CHAR, NULL,
                                         p_STATUS),
                decode(p_ASSIGNED_TO_USER_ID,FND_API.G_MISS_NUM, NULL,
                                         p_ASSIGNED_TO_USER_ID),
                decode(p_MERGE_TYPE,FND_API.G_MISS_CHAR, NULL,
                                         p_MERGE_TYPE),
                decode(p_OBJECT_VERSION_NUMBER,FND_API.G_MISS_NUM, NULL,
                                         p_OBJECT_VERSION_NUMBER),
                hz_utility_v2pub.created_by,
                hz_utility_v2pub.creation_date,
                hz_utility_v2pub.last_update_login,
                hz_utility_v2pub.last_update_date,
                hz_utility_v2pub.last_updated_by
              );

End Insert_Row;

PROCEDURE Update_Row(
                      p_DUP_SET_ID                       NUMBER,
	                  p_DUP_BATCH_ID                     NUMBER,
                      p_WINNER_PARTY_ID                  NUMBER,
                      p_CREATED_BY                       NUMBER,
                      p_CREATION_DATE                    DATE,
                      p_LAST_UPDATE_LOGIN                NUMBER,
                      p_LAST_UPDATE_DATE                 DATE,
                      p_LAST_UPDATED_BY                  NUMBER)
    IS
   BEGIN
   UPDATE HZ_DUP_SETS
   SET
   DUP_BATCH_ID=            decode(p_DUP_BATCH_ID,  FND_API.G_MISS_NUM, NULL,
                                          p_DUP_BATCH_ID),
   WINNER_PARTY_ID =        decode(p_WINNER_PARTY_ID,FND_API.G_MISS_NUM, NULL,
                                           p_WINNER_PARTY_ID),
   created_by =          created_by,
   creation_date=        creation_date,
   last_update_login=    hz_utility_v2pub.last_update_login,
   last_update_date=     hz_utility_v2pub.last_update_date,
   last_updated_by=      hz_utility_v2pub.last_updated_by
   where DUP_SET_ID  = p_DUP_SET_ID;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
 END Update_Row;

PROCEDURE Delete_Row(p_DUP_SET_ID NUMBER) IS
BEGIN
   DELETE FROM HZ_DUP_SETS
   where DUP_SET_ID = p_DUP_SET_ID ;

   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;

PROCEDURE Lock_Row(
                      p_DUP_SET_ID              IN OUT    NOCOPY NUMBER,
	                  p_DUP_BATCH_ID                      NUMBER,
                      p_WINNER_PARTY_ID                   NUMBER,
                      p_CREATED_BY                        NUMBER,
                      p_CREATION_DATE                     DATE,
                      p_LAST_UPDATE_LOGIN                 NUMBER,
                      p_LAST_UPDATE_DATE                  DATE,
                      p_LAST_UPDATED_BY                   NUMBER)
  IS
 CURSOR C IS
 SELECT *
 FROM hz_DUP_SETS
 where DUP_SET_ID = p_DUP_SET_ID
 FOR UPDATE OF DUP_SET_ID NOWAIT;

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
          (   (Recinfo.DUP_SET_ID = p_DUP_SET_ID)
           OR (     (Recinfo.DUP_SET_ID IS NULL)
                AND  (p_DUP_SET_ID IS NULL )))
    AND   (   (Recinfo.DUP_BATCH_ID = p_DUP_BATCH_ID)
           OR (      (Recinfo.DUP_BATCH_ID IS NULL)
                AND  (p_DUP_BATCH_ID IS NULL )))
    AND   (   (Recinfo.WINNER_PARTY_ID = p_WINNER_PARTY_ID)
          OR (      (Recinfo.WINNER_PARTY_ID IS NULL)
                AND  (p_WINNER_PARTY_ID IS NULL )))
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
END HZ_DUP_SETS_PKG;

/
