--------------------------------------------------------
--  DDL for Package Body HZ_DUP_BATCH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_DUP_BATCH_PKG" AS
/*$Header: ARHDQDBB.pls 115.8 2004/01/09 20:09:51 acng ship $ */

PROCEDURE Insert_Row(
                      px_DUP_BATCH_ID              IN OUT NOCOPY  NUMBER,
	              p_DUP_BATCH_NAME             VARCHAR2,
                      p_MATCH_RULE_ID                     NUMBER,
                      p_APPLICATION_ID               NUMBER,
                      p_REQUEST_TYPE                 VARCHAR2,
 		      p_CREATED_BY                 NUMBER,
                      p_CREATION_DATE              DATE,
                      p_LAST_UPDATE_LOGIN          NUMBER,
                      p_LAST_UPDATE_DATE           DATE,
                      p_LAST_UPDATED_BY            NUMBER) IS

 CURSOR C2 IS SELECT  HZ_DUP_BATCH_s.nextval FROM sys.dual;

 BEGIN

   IF (px_DUP_BATCH_ID IS NULL) OR (px_DUP_BATCH_ID = 0) OR (px_DUP_BATCH_ID = FND_API.G_MISS_NUM) THEN
       OPEN C2;
       FETCH C2 INTO px_DUP_BATCH_ID;
       CLOSE C2;

   END IF;

   INSERT INTO HZ_DUP_BATCH(
                DUP_BATCH_ID,
                DUP_BATCH_NAME,
                MATCH_RULE_ID,
                APPLICATION_ID,
                REQUEST_TYPE,
                CREATED_BY,
                CREATION_DATE,
                LAST_UPDATE_LOGIN,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY
               )
               VALUES (
                px_DUP_BATCH_ID,
                decode(p_DUP_BATCH_NAME, FND_API.G_MISS_CHAR, NULL,
                       p_DUP_BATCH_NAME||' - '||px_DUP_BATCH_ID),
                decode(p_MATCH_RULE_ID, FND_API.G_MISS_NUM, NULL,
                                                   p_MATCH_RULE_ID),
                decode(p_APPLICATION_ID, FND_API.G_MISS_NUM, NULL,
                                                   p_APPLICATION_ID),
                decode(p_REQUEST_TYPE, FND_API.G_MISS_CHAR, NULL,
                                                   p_REQUEST_TYPE),
                HZ_UTILITY_V2PUB.CREATED_BY,
                HZ_UTILITY_V2PUB.CREATION_DATE,
                HZ_UTILITY_V2PUB.LAST_UPDATE_LOGIN,
                HZ_UTILITY_V2PUB.LAST_UPDATE_DATE,
                HZ_UTILITY_V2PUB.LAST_UPDATED_BY
              );

End Insert_Row;

PROCEDURE Update_Row(
                      p_DUP_BATCH_ID                NUMBER,
	                  p_DUP_BATCH_NAME              VARCHAR2,
                      p_CREATED_BY                        NUMBER,
                      p_CREATION_DATE                     DATE,
                      p_LAST_UPDATE_LOGIN                 NUMBER,
                      p_LAST_UPDATE_DATE                  DATE,
                      p_LAST_UPDATED_BY                   NUMBER
   ) IS
   BEGIN
   UPDATE HZ_DUP_BATCH
   SET
      DUP_BATCH_NAME   = decode(p_DUP_BATCH_NAME, FND_API.G_MISS_CHAR, NULL,
                                      p_DUP_BATCH_NAME),
      CREATED_BY             = CREATED_BY,
      CREATION_DATE          = CREATION_DATE,
      LAST_UPDATE_LOGIN      = HZ_UTILITY_V2PUB.LAST_UPDATE_LOGIN,
      LAST_UPDATE_DATE       = HZ_UTILITY_V2PUB.LAST_UPDATE_DATE,
      LAST_UPDATED_BY        = HZ_UTILITY_V2PUB.LAST_UPDATED_BY
    where DUP_batch_id = p_DUP_batch_id;


    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
 END Update_Row;

PROCEDURE Delete_Row(p_DUP_batch_id NUMBER) IS
BEGIN
   DELETE FROM hz_DUP_batch
   where DUP_batch_id = p_DUP_batch_id ;

   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;

PROCEDURE Lock_Row(
                      p_DUP_BATCH_ID       IN OUT NOCOPY  NUMBER,
	                  p_DUP_BATCH_NAME              VARCHAR2,
                      p_CREATED_BY                        NUMBER,
                      p_CREATION_DATE                     DATE,
                      p_LAST_UPDATE_LOGIN                 NUMBER,
                      p_LAST_UPDATE_DATE                  DATE,
                      p_LAST_UPDATED_BY                   NUMBER
 ) IS
 CURSOR C IS
 SELECT *
 FROM hz_DUP_batch
 WHERE DUP_batch_id  = p_DUP_batch_id
 FOR UPDATE OF DUP_batch_id NOWAIT;
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
          (   (Recinfo.DUP_BATCH_ID = p_DUP_BATCH_ID)
           OR (     (Recinfo.DUP_BATCH_ID IS NULL)
                AND  (p_DUP_BATCH_ID IS NULL )))
    AND   (   (Recinfo.DUP_BATCH_NAME = p_DUP_BATCH_NAME)
           OR (      (Recinfo.DUP_BATCH_NAME IS NULL)
                AND  (p_DUP_BATCH_NAME IS NULL )))
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
END HZ_DUP_BATCH_PKG;

/
