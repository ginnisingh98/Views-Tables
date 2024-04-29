--------------------------------------------------------
--  DDL for Package Body HZ_DUP_SET_PARTIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_DUP_SET_PARTIES_PKG" AS
/*$Header: ARHDQDPB.pls 120.5 2005/07/08 04:37:45 rchanamo noship $ */

PROCEDURE Insert_Row(
                      p_DUP_PARTY_ID         IN OUT NOCOPY       NUMBER,
                      p_DUP_SET_ID           IN OUT NOCOPY       NUMBER,
                      p_merge_flag                        VARCHAR2,
                      p_not_dup                           VARCHAR2,
                      p_SCORE                             NUMBER,
                      p_MERGE_SEQ_ID                      NUMBER,
                      p_MERGE_BATCH_ID                    NUMBER,
                      p_MERGE_BATCH_NAME                  VARCHAR2,
                      p_CREATED_BY                        NUMBER,
                      p_CREATION_DATE                     DATE,
                      p_LAST_UPDATE_LOGIN                 NUMBER,
                      p_LAST_UPDATE_DATE                  DATE,
                      p_LAST_UPDATED_BY                   NUMBER)
  IS
  CURSOR c_dup_batch IS SELECT DUP_BATCH_ID
  FROM HZ_DUP_SETS WHERE DUP_SET_ID = p_dup_set_id;
  l_dup_set_batch_id NUMBER(15);

  BEGIN
   --Start of Bug No: 4244529
   OPEN  c_dup_batch;
   FETCH c_dup_batch INTO l_dup_set_batch_id;
   IF(c_dup_batch%NOTFOUND)THEN
    --Raise the error.
    FND_MESSAGE.SET_NAME('AR', 'HZ_DUP_SET_NOT_FOUND');
    APP_EXCEPTION.RAISE_EXCEPTION;
   END IF;
   CLOSE c_dup_batch;
   --End of Bug No: 4244529
   INSERT INTO HZ_DUP_SET_PARTIES(
                DUP_PARTY_ID,
                DUP_SET_ID,
                MERGE_FLAG,
                NOT_DUP,
                SCORE,
                MERGE_SEQ_ID ,
                MERGE_BATCH_ID,
                MERGE_BATCH_NAME ,
                CREATED_BY,
                CREATION_DATE,
                LAST_UPDATE_LOGIN,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
		DUP_SET_BATCH_ID --Bug No: 4244529
               )
               VALUES (
                p_DUP_PARTY_ID,
                p_DUP_SET_ID,
                decode(p_MERGE_FLAG,          FND_API.G_MISS_CHAR, NULL,
                                              p_MERGE_FLAG),
                decode(p_NOT_DUP,             FND_API.G_MISS_CHAR, NULL,
                                              p_NOT_DUP),
                decode(p_SCORE,               FND_API.G_MISS_NUM, NULL,
                                              p_SCORE),
                decode(p_MERGE_SEQ_ID,        FND_API.G_MISS_NUM, NULL,
                                              p_MERGE_SEQ_ID),
                decode(p_MERGE_BATCH_ID,      FND_API.G_MISS_NUM, NULL,
                                              p_MERGE_BATCH_ID),
                decode(p_MERGE_BATCH_NAME,    FND_API.G_MISS_CHAR, NULL,
                                              p_MERGE_BATCH_NAME),
                hz_utility_v2pub.created_by,
                hz_utility_v2pub.creation_date,
                hz_utility_v2pub.last_update_login,
                hz_utility_v2pub.last_update_date,
                hz_utility_v2pub.last_updated_by,
		l_dup_set_batch_id --Bug No: 4244529
              );

End Insert_Row;

PROCEDURE Update_Row(
                      p_DUP_PARTY_ID                      NUMBER,
                      p_DUP_SET_ID                        NUMBER,
                      p_merge_flag                        VARCHAR2,
                      p_NOT_DUP                           VARCHAR2,
                      p_SCORE                             NUMBER,
                      p_MERGE_SEQ_ID                      NUMBER,
                      p_MERGE_BATCH_ID                    NUMBER,
                      p_MERGE_BATCH_NAME                  VARCHAR2,
                      p_CREATED_BY                        NUMBER,
                      p_CREATION_DATE                     DATE,
                      p_LAST_UPDATE_LOGIN                 NUMBER,
                      p_LAST_UPDATE_DATE                  DATE,
                      p_LAST_UPDATED_BY                   NUMBER)
    IS
   BEGIN
   UPDATE HZ_DUP_SET_PARTIES
   SET
   MERGE_FLAG =          decode(p_MERGE_FLAG,          FND_API.G_MISS_CHAR, MERGE_FLAG,
                                                       p_MERGE_FLAG),
   NOT_DUP =             decode(p_NOT_DUP,             FND_API.G_MISS_CHAR, NOT_DUP,
                                                       p_NOT_DUP),
   SCORE =               decode(p_SCORE,               FND_API.G_MISS_NUM, SCORE,
                                                       p_SCORE),
   MERGE_SEQ_ID =        decode(p_MERGE_SEQ_ID ,       FND_API.G_MISS_NUM, MERGE_SEQ_ID,
                                                       p_MERGE_SEQ_ID),
   MERGE_BATCH_ID =      decode(p_MERGE_BATCH_ID,      FND_API.G_MISS_NUM, MERGE_BATCH_ID,
                                                       p_MERGE_BATCH_ID),
   MERGE_BATCH_NAME =    decode(p_MERGE_BATCH_NAME,    FND_API.G_MISS_CHAR, MERGE_BATCH_NAME,
                                                       p_MERGE_BATCH_NAME),
   created_by =          created_by,
   creation_date=        creation_date,
    last_update_login=    hz_utility_v2pub.last_update_login,
   last_update_date=     hz_utility_v2pub.last_update_date,
   last_updated_by=      hz_utility_v2pub.last_updated_by
   where DUP_PARTY_ID  = p_DUP_PARTY_ID
   and  DUP_SET_ID = p_DUP_SET_ID;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
 END Update_Row;

PROCEDURE Delete_Row(p_DUP_PARTY_ID    NUMBER, p_DUP_SET_ID    NUMBER) IS
BEGIN
   DELETE FROM hz_dup_set_parties
   where DUP_PARTY_ID  = p_DUP_PARTY_ID
   and  DUP_SET_ID = p_DUP_SET_ID;

   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;

 END Delete_Row;

PROCEDURE Lock_Row(
                      p_DUP_PARTY_ID         IN OUT NOCOPY       NUMBER,
                      p_DUP_SET_ID           IN OUT NOCOPY        NUMBER,
                      p_MERGE_FLAG                        VARCHAR2,
                      p_NOT_DUP                           VARCHAR2,
                      p_SCORE                             NUMBER,
                      p_MERGE_SEQ_ID                      NUMBER,
                      p_MERGE_BATCH_ID                    NUMBER,
                      p_MERGE_BATCH_NAME                  VARCHAR2,
                      p_CREATED_BY                        NUMBER,
                      p_CREATION_DATE                     DATE,
                      p_LAST_UPDATE_LOGIN                 NUMBER,
                      p_LAST_UPDATE_DATE                  DATE,
                      p_LAST_UPDATED_BY                   NUMBER)
  IS
 CURSOR C IS
 SELECT *
 FROM hz_dup_set_parties
  where DUP_PARTY_ID  = p_DUP_PARTY_ID
   and  DUP_SET_ID = p_DUP_SET_ID
 FOR UPDATE OF dup_party_id , dup_set_id NOWAIT;
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
           (Recinfo.DUP_PARTY_ID = p_DUP_PARTY_ID)
     AND   (Recinfo.DUP_SET_ID = p_DUP_SET_ID)
     AND   (   (Recinfo.SCORE = p_SCORE)
           OR (      (Recinfo.SCORE IS NULL)
                AND  (p_SCORE IS NULL )))
     AND   (   (Recinfo.MERGE_FLAG = p_MERGE_FLAG)
           OR (      (Recinfo.MERGE_FLAG IS NULL)
                AND  (p_MERGE_FLAG IS NULL )))
     AND   (   (Recinfo.NOT_DUP = p_NOT_DUP)
           OR (      (Recinfo.NOT_DUP IS NULL)
                AND  (p_NOT_DUP IS NULL )))
     AND   (   (Recinfo.MERGE_SEQ_ID = p_MERGE_SEQ_ID)
           OR (      (Recinfo.MERGE_SEQ_ID IS NULL)
                AND  (p_MERGE_SEQ_ID IS NULL )))
     AND   (   (Recinfo.MERGE_BATCH_ID = p_MERGE_BATCH_ID)
           OR (      (Recinfo.MERGE_BATCH_ID IS NULL)
                AND  (p_MERGE_BATCH_ID IS NULL )))
    AND   (   (Recinfo.MERGE_BATCH_NAME = p_MERGE_BATCH_NAME)
           OR (      (Recinfo.MERGE_BATCH_NAME IS NULL)
                AND  (p_MERGE_BATCH_NAME IS NULL )))
    AND    (     (Recinfo.CREATED_BY = p_CREATED_BY )
             OR (     (Recinfo.CREATED_BY IS NULL)
                 AND (p_CREATED_BY IS NULL )))
    AND    (     (Recinfo.CREATION_DATE = p_CREATION_DATE)
             OR (     (Recinfo.CREATION_DATE IS NULL)
                 AND (p_CREATION_DATE  IS NULL )))
    AND    (     (Recinfo.LAST_UPDATE_LOGIN= p_LAST_UPDATE_LOGIN)
             OR (     (Recinfo.LAST_UPDATE_LOGIN  IS NULL)
                 AND (p_LAST_UPDATE_LOGIN  IS NULL )))
    AND (    ( Recinfo.LAST_UPDATE_DATE = p_LAST_UPDATE_DATE)
            OR (    ( Recinfo.LAST_UPDATE_DATE IS NULL )
                AND (  p_LAST_UPDATE_DATE IS NULL )))
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
END HZ_DUP_SET_PARTIES_PKG;

/
