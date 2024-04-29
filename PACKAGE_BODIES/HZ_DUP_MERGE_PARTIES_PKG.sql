--------------------------------------------------------
--  DDL for Package Body HZ_DUP_MERGE_PARTIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_DUP_MERGE_PARTIES_PKG" AS
/*$Header: ARHDQDMB.pls 120.4 2005/06/16 21:10:36 jhuang noship $ */

PROCEDURE Insert_Row(
                      p_DUP_BATCH_ID      IN OUT          NOCOPY NUMBER,
                      p_MERGE_FROM_ID     IN OUT          NOCOPY NUMBER,
                      p_MERGE_TO_ID       IN OUT          NOCOPY NUMBER,
                      p_CREATED_BY                        NUMBER,
                      p_CREATION_DATE                     DATE,
                      p_LAST_UPDATE_LOGIN                 NUMBER,
                      p_LAST_UPDATE_DATE                  DATE,
                      p_LAST_UPDATED_BY                   NUMBER)
 IS

  BEGIN

   INSERT INTO HZ_DUP_MERGE_PARTIES(
                DUP_BATCH_ID,
                MERGE_FROM_ID,
                MERGE_TO_ID,
                CREATED_BY,
                CREATION_DATE,
                LAST_UPDATE_LOGIN,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY
               )
               VALUES (
                p_DUP_BATCH_ID,
                p_MERGE_FROM_ID,
                p_MERGE_TO_ID,
                hz_utility_v2pub.created_by,
                hz_utility_v2pub.creation_date,
                hz_utility_v2pub.last_update_login,
                hz_utility_v2pub.last_update_date,
                hz_utility_v2pub.last_updated_by
              );

End Insert_Row;


PROCEDURE Delete_Row(p_DUP_batch_id NUMBER,
                     p_MERGE_FROM_ID   NUMBER,
                     p_MERGE_TO_ID     NUMBER) IS
BEGIN
   DELETE FROM hz_DUP_MERGE_PARTIES
   where DUP_batch_id = p_DUP_batch_id
   AND MERGE_FROM_ID = p_MERGE_FROM_ID
   AND MERGE_TO_ID   = p_MERGE_TO_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;

PROCEDURE Lock_Row(
                      p_DUP_BATCH_ID      IN OUT          NOCOPY NUMBER,
                      p_MERGE_FROM_ID     IN OUT          NOCOPY NUMBER,
                      p_MERGE_TO_ID       IN OUT          NOCOPY NUMBER,
                      p_CREATED_BY                        NUMBER,
                      p_CREATION_DATE                     DATE,
                      p_LAST_UPDATE_LOGIN                 NUMBER,
                      p_LAST_UPDATE_DATE                  DATE,
                      p_LAST_UPDATED_BY                   NUMBER
 ) IS

 CURSOR C IS
 SELECT *
 FROM hz_DUP_MERGE_PARTIES
 WHERE DUP_batch_id  = p_DUP_batch_id
 AND   MERGE_FROM_ID   = p_MERGE_FROM_ID
 AND  MERGE_TO_ID      = P_MERGE_TO_ID
 FOR UPDATE OF DUP_batch_id, MERGE_FROM_ID , MERGE_TO_ID NOWAIT;
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
    AND   (   (Recinfo.MERGE_FROM_ID = p_MERGE_FROM_ID)
           OR (      (Recinfo.MERGE_FROM_ID IS NULL)
                AND  (p_MERGE_FROM_ID IS NULL )))
    AND   (   (Recinfo.MERGE_TO_ID = p_MERGE_TO_ID)
           OR (      (Recinfo.MERGE_TO_ID IS NULL)
                AND  (p_MERGE_TO_ID IS NULL )))
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
END HZ_DUP_MERGE_PARTIES_PKG;

/
