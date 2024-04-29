--------------------------------------------------------
--  DDL for Package Body HZ_WORD_REPLACEMENTS1_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_WORD_REPLACEMENTS1_PKG" as
/*$Header: ARHDQWRB.pls 120.12 2006/06/29 13:45:06 rarajend noship $ */

PROCEDURE Insert_Row(
                  x_Rowid               IN OUT NOCOPY    VARCHAR2,
                  x_WORD_LIST_ID                  NUMBER,
                  x_ORIGINAL_WORD                 VARCHAR2,
                  x_REPLACEMENT_WORD              VARCHAR2,
                  x_TYPE                          VARCHAR2,
                  x_COUNTRY_CODE                  VARCHAR2,
                  x_LAST_UPDATE_DATE              DATE,
                  x_LAST_UPDATED_BY               NUMBER,
                  x_CREATION_DATE                 DATE,
                  x_CREATED_BY                    NUMBER,
                  x_LAST_UPDATE_LOGIN             NUMBER,
                  x_ATTRIBUTE_CATEGORY            VARCHAR2,
                  x_ATTRIBUTE1                    VARCHAR2,
                  x_ATTRIBUTE2                    VARCHAR2,
                  x_ATTRIBUTE3                    VARCHAR2,
                  x_ATTRIBUTE4                    VARCHAR2,
                  x_ATTRIBUTE5                    VARCHAR2,
                  x_ATTRIBUTE6                    VARCHAR2,
                  x_ATTRIBUTE7                    VARCHAR2,
                  x_ATTRIBUTE8                    VARCHAR2,
                  x_ATTRIBUTE9                    VARCHAR2,
                  x_ATTRIBUTE10                   VARCHAR2,
                  x_ATTRIBUTE11                   VARCHAR2,
                  x_ATTRIBUTE12                   VARCHAR2,
                  x_ATTRIBUTE13                   VARCHAR2,
                  x_ATTRIBUTE14                   VARCHAR2,
                  x_ATTRIBUTE15                   VARCHAR2,
                  x_object_version_number IN OUT NOCOPY NUMBER,
                  x_msg_count             IN OUT NOCOPY NUMBER,
		  x_condition_id                 NUMBER DEFAULT NULL,
		  x_user_spec_cond_value         VARCHAR2 DEFAULT NULL
 ) IS
  CURSOR C IS SELECT rowid FROM HZ_WORD_REPLACEMENTS
            WHERE WORD_LIST_ID  = x_WORD_LIST_ID
            AND   ORIGINAL_WORD =  UPPER(x_ORIGINAL_WORD);
 OAERR  EXCEPTION;
  l_count NUMBER;
  p_msg_count number := 0;
  p_msg_data varchar2(1000);
 BEGIN
   IF x_WORD_LIST_ID IS NOT NULL THEN
      x_msg_count := 0;
      /* Original Word is unique for a word list  */
      SELECT count(*) INTO l_count
        FROM   hz_word_replacements
        WHERE  word_list_id     = x_WORD_LIST_ID
	AND    delete_flag      = 'N'
        AND    original_word    = UPPER(x_ORIGINAL_WORD)
	AND    (condition_id IS NULL
                 OR
                (decode(x_CONDITION_ID, FND_API.G_MISS_NUM, NULL, x_CONDITION_ID) IS NULL)
		 OR
		 ( (condition_id = x_condition_id)
		    AND ( nvl(user_spec_cond_value,FND_API.G_MISS_CHAR) = nvl(x_user_spec_cond_value,FND_API.G_MISS_CHAR )
		          OR nvl(replacement_word,FND_API.G_MISS_CHAR) = nvl(upper(x_replacement_word),FND_API.G_MISS_CHAR)
		        )
		 )
	       );

      IF l_count > 0 THEN
         x_msg_count := x_msg_count +1;
         l_count := 0;
         FND_MESSAGE.SET_NAME( 'AR', 'HZ_DUPL_WORD' );
         FND_MESSAGE.SET_TOKEN( 'WORD', UPPER(x_ORIGINAL_WORD) );
         FND_MSG_PUB.ADD;
     END IF;
     /*  No Cyclic Pairs  */
   SELECT count(*) INTO l_count
     FROM   hz_word_replacements
     WHERE  word_list_id     = x_WORD_LIST_ID
     AND    delete_flag      = 'N'
      AND   (original_word    = UPPER(x_REPLACEMENT_WORD) OR
             replacement_word = UPPER(x_ORIGINAL_WORD));
   IF l_count > 0 THEN
        x_msg_count := x_msg_count+1;
        l_count := 0;
        FND_MESSAGE.SET_NAME( 'AR', 'HZ_DQM_WR_CYCLIC' );
        FND_MESSAGE.SET_TOKEN( 'ORIGINALWORD', UPPER(x_ORIGINAL_WORD) );
        FND_MESSAGE.SET_TOKEN( 'REPLACEMENTWORD', UPPER(x_REPLACEMENT_WORD) );
        FND_MSG_PUB.ADD;
   END IF;
      /* Pairs cannot be same */
   IF UPPER(x_ORIGINAL_WORD) = UPPER(x_REPLACEMENT_WORD) THEN
        x_msg_count := x_msg_count+1;
        FND_MESSAGE.SET_NAME( 'AR', 'HZ_DQM_WR_SAME_PAIR_VALUE' );
        FND_MESSAGE.SET_TOKEN( 'WORD', UPPER(x_REPLACEMENT_WORD) );
        FND_MSG_PUB.ADD;
   END IF;
    /*   Original Word is Mandatory  */
   IF (x_ORIGINAL_WORD IS NULL OR x_ORIGINAL_WORD = FND_API.G_MISS_CHAR)
   THEN
      x_msg_count := x_msg_count+1;
      FND_MESSAGE.SET_NAME( 'AR', 'HZ_DQM_WR_ORIG_WORD_MANDATORY' );
      FND_MSG_PUB.ADD;
   END IF;

   IF x_msg_count > 0 THEN
      return;
   END IF;
   END IF;

Insert_Row(
                  x_Rowid             ,
                  x_WORD_LIST_ID      ,
                  x_ORIGINAL_WORD     ,
                  x_REPLACEMENT_WORD  ,
                  x_TYPE              ,
                  x_COUNTRY_CODE      ,
                  x_LAST_UPDATE_DATE  ,
                  x_LAST_UPDATED_BY   ,
                  x_CREATION_DATE     ,
                  x_CREATED_BY        ,
                  x_LAST_UPDATE_LOGIN ,
                  x_ATTRIBUTE_CATEGORY,
                  x_ATTRIBUTE1        ,
                  x_ATTRIBUTE2        ,
                  x_ATTRIBUTE3        ,
                  x_ATTRIBUTE4        ,
                  x_ATTRIBUTE5        ,
                  x_ATTRIBUTE6        ,
                  x_ATTRIBUTE7        ,
                  x_ATTRIBUTE8        ,
                  x_ATTRIBUTE9        ,
                  x_ATTRIBUTE10       ,
                  x_ATTRIBUTE11       ,
                  x_ATTRIBUTE12       ,
                  x_ATTRIBUTE13       ,
                  x_ATTRIBUTE14       ,
                  x_ATTRIBUTE15       ,
                  x_object_version_number,
		  x_condition_id  ,
		  x_user_spec_cond_value
               );

END Insert_Row;

PROCEDURE Insert_Row(
                  x_Rowid               IN OUT NOCOPY    VARCHAR2,
                  x_WORD_LIST_ID                  NUMBER,
                  x_ORIGINAL_WORD                 VARCHAR2,
                  x_REPLACEMENT_WORD              VARCHAR2,
                  x_TYPE                          VARCHAR2,
                  x_COUNTRY_CODE                  VARCHAR2,
                  x_LAST_UPDATE_DATE              DATE,
                  x_LAST_UPDATED_BY               NUMBER,
                  x_CREATION_DATE                 DATE,
                  x_CREATED_BY                    NUMBER,
                  x_LAST_UPDATE_LOGIN             NUMBER,
                  x_ATTRIBUTE_CATEGORY            VARCHAR2,
                  x_ATTRIBUTE1                    VARCHAR2,
                  x_ATTRIBUTE2                    VARCHAR2,
                  x_ATTRIBUTE3                    VARCHAR2,
                  x_ATTRIBUTE4                    VARCHAR2,
                  x_ATTRIBUTE5                    VARCHAR2,
                  x_ATTRIBUTE6                    VARCHAR2,
                  x_ATTRIBUTE7                    VARCHAR2,
                  x_ATTRIBUTE8                    VARCHAR2,
                  x_ATTRIBUTE9                    VARCHAR2,
                  x_ATTRIBUTE10                   VARCHAR2,
                  x_ATTRIBUTE11                   VARCHAR2,
                  x_ATTRIBUTE12                   VARCHAR2,
                  x_ATTRIBUTE13                   VARCHAR2,
                  x_ATTRIBUTE14                   VARCHAR2,
                  x_ATTRIBUTE15                   VARCHAR2,
                  x_object_version_number   IN OUT NOCOPY      NUMBER,
		  x_condition_id                 NUMBER DEFAULT NULL,
		  x_user_spec_cond_value         VARCHAR2 DEFAULT NULL
 ) IS
  CURSOR C IS SELECT rowid FROM HZ_WORD_REPLACEMENTS
            WHERE WORD_LIST_ID  = x_WORD_LIST_ID
            AND   ORIGINAL_WORD =  UPPER(x_ORIGINAL_WORD);

 BEGIN
   INSERT INTO HZ_WORD_REPLACEMENTS(
           WORD_LIST_ID,
           ORIGINAL_WORD,
           REPLACEMENT_WORD,
           TYPE,
           COUNTRY_CODE,
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
           OBJECT_VERSION_NUMBER,
	   CONDITION_ID,
	   USER_SPEC_COND_VALUE,
	   STAGED_FLAG,
	   DELETE_FLAG
          )
          VALUES (
           decode( x_WORD_LIST_ID, FND_API.G_MISS_NUM, NULL, x_WORD_LIST_ID),
           decode( x_ORIGINAL_WORD, FND_API.G_MISS_CHAR, NULL, UPPER(x_ORIGINAL_WORD)),
           decode( x_REPLACEMENT_WORD, FND_API.G_MISS_CHAR, NULL, UPPER(x_REPLACEMENT_WORD)),
           decode( x_TYPE, FND_API.G_MISS_CHAR, NULL, x_TYPE),
           decode( x_COUNTRY_CODE, FND_API.G_MISS_CHAR, NULL, x_COUNTRY_CODE),
           decode( x_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, NULL,x_LAST_UPDATE_DATE),
           decode( x_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL,x_LAST_UPDATED_BY),
           decode( x_CREATION_DATE, FND_API.G_MISS_DATE, NULL,x_CREATION_DATE),
           decode( x_CREATED_BY, FND_API.G_MISS_NUM, NULL,x_CREATED_BY),
           decode( x_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL,x_LAST_UPDATE_LOGIN),
           decode( x_ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR, NULL,x_ATTRIBUTE_CATEGORY),
           decode( x_ATTRIBUTE1, FND_API.G_MISS_CHAR, NULL,x_ATTRIBUTE1),
           decode( x_ATTRIBUTE2, FND_API.G_MISS_CHAR, NULL,x_ATTRIBUTE2),
           decode( x_ATTRIBUTE3, FND_API.G_MISS_CHAR, NULL,x_ATTRIBUTE3),
           decode( x_ATTRIBUTE4, FND_API.G_MISS_CHAR, NULL,x_ATTRIBUTE4),
           decode( x_ATTRIBUTE5, FND_API.G_MISS_CHAR, NULL,x_ATTRIBUTE5),
           decode( x_ATTRIBUTE6, FND_API.G_MISS_CHAR, NULL,x_ATTRIBUTE6),
           decode( x_ATTRIBUTE7, FND_API.G_MISS_CHAR, NULL,x_ATTRIBUTE7),
           decode( x_ATTRIBUTE8, FND_API.G_MISS_CHAR, NULL,x_ATTRIBUTE8),
           decode( x_ATTRIBUTE9, FND_API.G_MISS_CHAR, NULL,x_ATTRIBUTE9),
           decode( x_ATTRIBUTE10, FND_API.G_MISS_CHAR, NULL,x_ATTRIBUTE10),
           decode( x_ATTRIBUTE11, FND_API.G_MISS_CHAR, NULL,x_ATTRIBUTE11),
           decode( x_ATTRIBUTE12, FND_API.G_MISS_CHAR, NULL,x_ATTRIBUTE12),
           decode( x_ATTRIBUTE13, FND_API.G_MISS_CHAR, NULL,x_ATTRIBUTE13),
           decode( x_ATTRIBUTE14, FND_API.G_MISS_CHAR, NULL,x_ATTRIBUTE14),
           decode( x_ATTRIBUTE15, FND_API.G_MISS_CHAR, NULL,x_ATTRIBUTE15),
           1,
	   decode(x_CONDITION_ID, FND_API.G_MISS_NUM, NULL, x_CONDITION_ID),
	   decode(x_USER_SPEC_COND_VALUE,FND_API.G_MISS_CHAR,null,x_USER_SPEC_COND_VALUE),
	   'N',
           'N'
          );
   OPEN C;
   FETCH C INTO x_Rowid;
   If (C%NOTFOUND) then
       CLOSE C;
       RAISE NO_DATA_FOUND;
   End If;

EXCEPTION
WHEN NO_DATA_FOUND THEN
   NULL;

End Insert_Row;

PROCEDURE Delete_Row(X_WORD_LIST_ID  IN  NUMBER) IS
BEGIN
  DELETE FROM HZ_WORD_REPLACEMENTS
  WHERE WORD_LIST_ID = X_WORD_LIST_ID;
END;

PROCEDURE Delete_Row( x_WORD_LIST_ID IN NUMBER, X_ORIGINAL_WORD IN VARCHAR2,X_CONDITION_ID IN NUMBER,x_user_spec_cond_value IN  VARCHAR2)
 IS
 CURSOR C IS SELECT STAGED_FLAG FROM HZ_WORD_REPLACEMENTS
     WHERE  WORD_LIST_ID = x_WORD_LIST_ID
     AND ORIGINAL_WORD   = x_ORIGINAL_WORD
     AND NVL(CONDITION_ID,-99) = NVL(X_CONDITION_ID,-99)
     AND nvl(user_spec_cond_value,FND_API.G_MISS_CHAR) = nvl(x_user_spec_cond_value,FND_API.G_MISS_CHAR)
     AND DELETE_FLAG = 'N';
 l_staged_flag varchar2(1);
 BEGIN
   OPEN C;
   FETCH C INTO l_staged_flag;
/*   If (C%NOTFOUND) then
       CLOSE C;
       RAISE NO_DATA_FOUND;
   End If;*/
   CLOSE C;
   IF(l_staged_flag = 'N') then
     DELETE FROM HZ_WORD_REPLACEMENTS
     WHERE  WORD_LIST_ID = x_WORD_LIST_ID
     AND ORIGINAL_WORD   = x_ORIGINAL_WORD
     AND NVL(CONDITION_ID,-99) = NVL(X_CONDITION_ID,-99)
     AND nvl(user_spec_cond_value,FND_API.G_MISS_CHAR) = nvl(x_user_spec_cond_value,FND_API.G_MISS_CHAR)
     AND DELETE_FLAG = 'N'
     AND STAGED_FLAG = 'N';
   ELSE
    UPDATE HZ_WORD_REPLACEMENTS
    SET DELETE_FLAG = 'Y'
    WHERE  WORD_LIST_ID = x_WORD_LIST_ID
    AND ORIGINAL_WORD   = x_ORIGINAL_WORD
    AND NVL(CONDITION_ID,-99) = NVL(X_CONDITION_ID,-99)
    AND nvl(user_spec_cond_value,FND_API.G_MISS_CHAR) = nvl(x_user_spec_cond_value,FND_API.G_MISS_CHAR)
    AND DELETE_FLAG = 'N'
    AND STAGED_FLAG = 'Y' ;
   END IF;
 END Delete_Row;


PROCEDURE Update_Row(
                  x_Rowid                         VARCHAR2,
                  x_WORD_LIST_ID                  NUMBER,
                  x_ORIGINAL_WORD                 VARCHAR2,
                  x_REPLACEMENT_WORD              VARCHAR2,
                  x_TYPE                          VARCHAR2,
                  x_COUNTRY_CODE                  VARCHAR2,
                  x_LAST_UPDATE_DATE              DATE,
                  x_LAST_UPDATED_BY               NUMBER,
                  x_CREATION_DATE                 DATE,
                  x_CREATED_BY                    NUMBER,
                  x_LAST_UPDATE_LOGIN             NUMBER,
                  x_ATTRIBUTE_CATEGORY            VARCHAR2,
                  x_ATTRIBUTE1                    VARCHAR2,
                  x_ATTRIBUTE2                    VARCHAR2,
                  x_ATTRIBUTE3                    VARCHAR2,
                  x_ATTRIBUTE4                    VARCHAR2,
                  x_ATTRIBUTE5                    VARCHAR2,
                  x_ATTRIBUTE6                    VARCHAR2,
                  x_ATTRIBUTE7                    VARCHAR2,
                  x_ATTRIBUTE8                    VARCHAR2,
                  x_ATTRIBUTE9                    VARCHAR2,
                  x_ATTRIBUTE10                   VARCHAR2,
                  x_ATTRIBUTE11                   VARCHAR2,
                  x_ATTRIBUTE12                   VARCHAR2,
                  x_ATTRIBUTE13                   VARCHAR2,
                  x_ATTRIBUTE14                   VARCHAR2,
                  x_ATTRIBUTE15                   VARCHAR2,
                  x_object_version_number in out NOCOPY  NUMBER,
                  x_msg_count              in out NOCOPY NUMBER,
		  x_condition_id                 NUMBER DEFAULT NULL,
		  x_user_spec_cond_value         VARCHAR2 DEFAULT NULL
 ) IS

p_object_version_number number := null;
p_msg_count number := 1;
p_msg_data varchar2(1000);
l_count NUMBER;
BEGIN
    x_msg_count := 0;
         /* Pairs cannot be same */
    IF x_ORIGINAL_WORD = UPPER(x_REPLACEMENT_WORD) THEN
        x_msg_count := x_msg_count+1;
        l_count := 0;
        FND_MESSAGE.SET_NAME( 'AR', 'HZ_DQM_WR_SAME_PAIR_VALUE' );
        FND_MESSAGE.SET_TOKEN( 'WORD', UPPER(x_REPLACEMENT_WORD) );
        FND_MSG_PUB.ADD;
    END IF;

    /* Original Word is unique for a word list  */
      SELECT count(*) INTO l_count
        FROM   hz_word_replacements
        WHERE  word_list_id     = x_WORD_LIST_ID
        AND    delete_flag      = 'N'
        AND    original_word    = UPPER(x_ORIGINAL_WORD)
	AND    (condition_id IS NULL
                 OR
                (decode(x_CONDITION_ID, FND_API.G_MISS_NUM, NULL, x_CONDITION_ID) IS NULL)
		 OR
		 ( (condition_id = x_condition_id)
		    AND ( nvl(user_spec_cond_value,FND_API.G_MISS_CHAR) = nvl(x_user_spec_cond_value,FND_API.G_MISS_CHAR )
		          OR nvl(replacement_word,FND_API.G_MISS_CHAR) = nvl(upper(x_replacement_word),FND_API.G_MISS_CHAR)
		        )
		 )
	       )
	AND   rowid <> x_Rowid;

      IF l_count > 0 THEN
         x_msg_count := x_msg_count +1;
         l_count := 0;
         FND_MESSAGE.SET_NAME( 'AR', 'HZ_DUPL_WORD' );
         FND_MESSAGE.SET_TOKEN( 'WORD', UPPER(x_ORIGINAL_WORD) );
         FND_MSG_PUB.ADD;
     END IF;

          /* No Cyclic Pairs */
   SELECT count(*) INTO l_count
     FROM   hz_word_replacements
     WHERE  word_list_id     = x_WORD_LIST_ID
     AND    delete_flag      = 'N'
      AND   (original_word    = UPPER(x_REPLACEMENT_WORD) OR
             replacement_word = UPPER(x_ORIGINAL_WORD))
      AND    rowid            <> x_Rowid;
   IF l_count > 0 THEN
        x_msg_count := x_msg_count+1;
        l_count := 0;
        FND_MESSAGE.SET_NAME( 'AR', 'HZ_DQM_WR_CYCLIC' );
        FND_MESSAGE.SET_TOKEN( 'ORIGINALWORD', UPPER(x_ORIGINAL_WORD) );
        FND_MESSAGE.SET_TOKEN( 'REPLACEMENTWORD', UPPER(x_REPLACEMENT_WORD) );
        FND_MSG_PUB.ADD;
   END IF;
   IF x_msg_count > 0 THEN
      return;
   END IF;
Update_Row(
                  x_Rowid             ,
                  x_WORD_LIST_ID      ,
                  x_ORIGINAL_WORD     ,
                  x_REPLACEMENT_WORD  ,
                  x_TYPE              ,
                  x_COUNTRY_CODE      ,
                  x_LAST_UPDATE_DATE  ,
                  x_LAST_UPDATED_BY   ,
                  x_CREATION_DATE     ,
                  x_CREATED_BY        ,
                  x_LAST_UPDATE_LOGIN ,
                  x_ATTRIBUTE_CATEGORY,
                  x_ATTRIBUTE1        ,
                  x_ATTRIBUTE2        ,
                  x_ATTRIBUTE3        ,
                  x_ATTRIBUTE4        ,
                  x_ATTRIBUTE5        ,
                  x_ATTRIBUTE6        ,
                  x_ATTRIBUTE7        ,
                  x_ATTRIBUTE8        ,
                  x_ATTRIBUTE9        ,
                  x_ATTRIBUTE10       ,
                  x_ATTRIBUTE11       ,
                  x_ATTRIBUTE12       ,
                  x_ATTRIBUTE13       ,
                  x_ATTRIBUTE14       ,
                  x_ATTRIBUTE15       ,
                  x_object_version_number,
		  x_condition_id  ,
		  x_user_spec_cond_value
                  );

END Update_Row;
PROCEDURE Update_Row(
                  x_Rowid                         VARCHAR2,
                  x_WORD_LIST_ID                  NUMBER,
                  x_ORIGINAL_WORD                 VARCHAR2,
                  x_REPLACEMENT_WORD              VARCHAR2,
                  x_TYPE                          VARCHAR2,
                  x_COUNTRY_CODE                  VARCHAR2,
                  x_LAST_UPDATE_DATE              DATE,
                  x_LAST_UPDATED_BY               NUMBER,
                  x_CREATION_DATE                 DATE,
                  x_CREATED_BY                    NUMBER,
                  x_LAST_UPDATE_LOGIN             NUMBER,
                  x_ATTRIBUTE_CATEGORY            VARCHAR2,
                  x_ATTRIBUTE1                    VARCHAR2,
                  x_ATTRIBUTE2                    VARCHAR2,
                  x_ATTRIBUTE3                    VARCHAR2,
                  x_ATTRIBUTE4                    VARCHAR2,
                  x_ATTRIBUTE5                    VARCHAR2,
                  x_ATTRIBUTE6                    VARCHAR2,
                  x_ATTRIBUTE7                    VARCHAR2,
                  x_ATTRIBUTE8                    VARCHAR2,
                  x_ATTRIBUTE9                    VARCHAR2,
                  x_ATTRIBUTE10                   VARCHAR2,
                  x_ATTRIBUTE11                   VARCHAR2,
                  x_ATTRIBUTE12                   VARCHAR2,
                  x_ATTRIBUTE13                   VARCHAR2,
                  x_ATTRIBUTE14                   VARCHAR2,
                  x_ATTRIBUTE15                   VARCHAR2,
                  x_object_version_number in out NOCOPY  NUMBER,
		  x_condition_id                 NUMBER DEFAULT NULL,
		  x_user_spec_cond_value         VARCHAR2 DEFAULT NULL
 ) IS

p_object_version_number number := null;

BEGIN
  p_object_version_number := NVL(X_object_version_number, 1) + 1;

    Update HZ_WORD_REPLACEMENTS
    SET
             REPLACEMENT_WORD = decode(x_REPLACEMENT_WORD,NULL,REPLACEMENT_WORD, FND_API.G_MISS_CHAR, NULL,UPPER(x_REPLACEMENT_WORD)),
             TYPE = decode( x_TYPE,NULL,TYPE,FND_API.G_MISS_CHAR, NULL, x_TYPE),
             COUNTRY_CODE = decode( x_COUNTRY_CODE, NULL, COUNTRY_CODE,FND_API.G_MISS_CHAR, NULL, x_COUNTRY_CODE),
             LAST_UPDATE_DATE = decode( x_LAST_UPDATE_DATE, NULL,LAST_UPDATE_DATE,FND_API.G_MISS_DATE,NULL,x_LAST_UPDATE_DATE),
             LAST_UPDATED_BY = decode( x_LAST_UPDATED_BY, NULL,LAST_UPDATED_BY,FND_API.G_MISS_NUM,NULL,x_LAST_UPDATED_BY),
             -- Bug 3032780
             /*
             CREATION_DATE = decode( x_CREATION_DATE, NULL,CREATION_DATE,FND_API.G_MISS_DATE,NULL,x_CREATION_DATE),
             CREATED_BY = decode( x_CREATED_BY, NULL,CREATED_BY,FND_API.G_MISS_NUM,NULL,x_CREATED_BY),
             */
             LAST_UPDATE_LOGIN = decode( x_LAST_UPDATE_LOGIN, NULL,LAST_UPDATE_LOGIN,FND_API.G_MISS_NUM,NULL,x_LAST_UPDATE_LOGIN),
             ATTRIBUTE_CATEGORY = decode( x_ATTRIBUTE_CATEGORY, NULL,ATTRIBUTE_CATEGORY,FND_API.G_MISS_CHAR, NULL,x_ATTRIBUTE_CATEGORY),
             ATTRIBUTE1 = decode( x_ATTRIBUTE1, NULL,ATTRIBUTE1,FND_API.G_MISS_CHAR, NULL,x_ATTRIBUTE1),
             ATTRIBUTE2 = decode( x_ATTRIBUTE2, NULL,ATTRIBUTE2,FND_API.G_MISS_CHAR, NULL,x_ATTRIBUTE2),
             ATTRIBUTE3 = decode( x_ATTRIBUTE3, NULL,ATTRIBUTE3,FND_API.G_MISS_CHAR, NULL,x_ATTRIBUTE3),
             ATTRIBUTE4 = decode( x_ATTRIBUTE4, NULL,ATTRIBUTE4,FND_API.G_MISS_CHAR, NULL,x_ATTRIBUTE4),
             ATTRIBUTE5 = decode( x_ATTRIBUTE5, NULL,ATTRIBUTE5,FND_API.G_MISS_CHAR, NULL,x_ATTRIBUTE5),
             ATTRIBUTE6 = decode( x_ATTRIBUTE6, NULL,ATTRIBUTE6,FND_API.G_MISS_CHAR, NULL,x_ATTRIBUTE6),
             ATTRIBUTE7 = decode( x_ATTRIBUTE7, NULL,ATTRIBUTE7,FND_API.G_MISS_CHAR, NULL,x_ATTRIBUTE7),
             ATTRIBUTE8 = decode( x_ATTRIBUTE8, NULL,ATTRIBUTE8,FND_API.G_MISS_CHAR, NULL,x_ATTRIBUTE8),
             ATTRIBUTE9 = decode( x_ATTRIBUTE9, NULL,ATTRIBUTE9,FND_API.G_MISS_CHAR, NULL,x_ATTRIBUTE9),
             ATTRIBUTE10 = decode( x_ATTRIBUTE10, NULL,ATTRIBUTE10,FND_API.G_MISS_CHAR, NULL,x_ATTRIBUTE10),
             ATTRIBUTE11 = decode( x_ATTRIBUTE11, NULL,ATTRIBUTE11,FND_API.G_MISS_CHAR, NULL,x_ATTRIBUTE11),
             ATTRIBUTE12 = decode( x_ATTRIBUTE12, NULL,ATTRIBUTE12,FND_API.G_MISS_CHAR, NULL,x_ATTRIBUTE12),
             ATTRIBUTE13 = decode( x_ATTRIBUTE13, NULL,ATTRIBUTE13,FND_API.G_MISS_CHAR, NULL,x_ATTRIBUTE13),
             ATTRIBUTE14 = decode( x_ATTRIBUTE14, NULL,ATTRIBUTE14,FND_API.G_MISS_CHAR, NULL,x_ATTRIBUTE14),
             ATTRIBUTE15 = decode( x_ATTRIBUTE15, NULL,ATTRIBUTE15,FND_API.G_MISS_CHAR, NULL,x_ATTRIBUTE15),
            OBJECT_VERSION_NUMBER = p_object_version_number,
	    CONDITION_ID = decode(x_CONDITION_ID, NULL, CONDITION_ID,FND_API.G_MISS_NUM,NULL, x_CONDITION_ID),
	    USER_SPEC_COND_VALUE= decode(x_USER_SPEC_COND_VALUE,NULL,USER_SPEC_COND_VALUE,FND_API.G_MISS_CHAR, NULL,x_USER_SPEC_COND_VALUE)
    where rowid = X_RowId;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;

 x_object_version_number :=  p_object_version_number;

 END Update_Row;

PROCEDURE Lock_Row(
                  x_Rowid                         VARCHAR2,
                  x_WORD_LIST_ID                  NUMBER,
                  x_ORIGINAL_WORD                 VARCHAR2,
                  x_object_version_number         NUMBER
 ) IS

   CURSOR C IS
        SELECT object_version_number
          FROM HZ_WORD_REPLACEMENTS
          WHERE rowid =  X_rowid
         FOR UPDATE of ORIGINAL_WORD NOWAIT;
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

      if(
       ( recinfo.OBJECT_VERSION_NUMBER IS NULL AND X_object_version_number IS NULL )
       OR ( recinfo.OBJECT_VERSION_NUMBER IS NOT NULL AND
          X_object_version_number IS NOT NULL AND
          recinfo.OBJECT_VERSION_NUMBER = X_object_version_number )
     ) then
       null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

END Lock_Row;

END HZ_WORD_REPLACEMENTS1_PKG;

/
