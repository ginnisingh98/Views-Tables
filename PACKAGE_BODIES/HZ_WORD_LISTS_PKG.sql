--------------------------------------------------------
--  DDL for Package Body HZ_WORD_LISTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_WORD_LISTS_PKG" AS
/* $Header: ARHDQWLB.pls 120.5 2005/06/16 21:11:22 jhuang noship $ */
PROCEDURE Insert_Row(
                      X_WORD_LIST_ID           IN OUT   NOCOPY NUMBER,
                      X_WORD_LIST_NAME                   VARCHAR2,
                      X_LANGUAGE                         VARCHAR2,
                      X_SOURCE_NAME                      VARCHAR2,
                      X_CREATED_BY                        NUMBER,
                      X_CREATION_DATE                     DATE,
                      X_LAST_UPDATE_LOGIN                 NUMBER,
                      X_LAST_UPDATE_DATE                  DATE,
                      X_LAST_UPDATED_BY                   NUMBER,
                      X_OBJECT_VERSION_NUMBER             NUMBER,
                      X_MSG_COUNT              IN OUT   NOCOPY NUMBER,
		      X_NON_DELIMITED_FLAG                VARCHAR2 DEFAULT 'N')
  IS
l_count NUMBER;
BEGIN
IF x_WORD_LIST_ID IS NOT NULL THEN
      x_msg_count := 0;
      /* Word List should be unique */
      SELECT count(*) INTO l_count
        FROM   hz_word_lists
        WHERE  word_list_name     = UPPER(X_WORD_LIST_NAME);

      IF l_count > 0 THEN
         x_msg_count := x_msg_count +1;
         l_count := 0;
         FND_MESSAGE.SET_NAME( 'AR', 'HZ_DUPL_WORD_LIST' );
         FND_MSG_PUB.ADD;
         return;
     END IF;
END IF;
    Insert_Row(
               X_WORD_LIST_ID,
               X_WORD_LIST_NAME,
               X_LANGUAGE,
               X_SOURCE_NAME,
               X_CREATED_BY,
               X_CREATION_DATE,
               X_LAST_UPDATE_LOGIN,
               X_LAST_UPDATE_DATE,
               X_LAST_UPDATED_BY,
               X_OBJECT_VERSION_NUMBER,
	       X_NON_DELIMITED_FLAG);
END Insert_Row;
PROCEDURE Insert_Row(
                      X_WORD_LIST_ID           IN OUT   NOCOPY NUMBER,
	                  X_WORD_LIST_NAME                   VARCHAR2,
 		              X_LANGUAGE                         VARCHAR2,
                      X_SOURCE_NAME                      VARCHAR2,
                      X_CREATED_BY                        NUMBER,
                      X_CREATION_DATE                     DATE,
                      X_LAST_UPDATE_LOGIN                 NUMBER,
                      X_LAST_UPDATE_DATE                  DATE,
                      X_LAST_UPDATED_BY                   NUMBER,
                      X_OBJECT_VERSION_NUMBER             NUMBER,
		      X_NON_DELIMITED_FLAG                VARCHAR2 DEFAULT 'N')
  IS
  CURSOR C2 IS SELECT  HZ_WORD_LISTS_s.nextval FROM sys.dual;
 BEGIN
    IF ( X_WORD_LIST_ID IS NULL) OR (X_WORD_LIST_ID = FND_API.G_MISS_NUM) THEN
        OPEN C2;
        FETCH C2 INTO X_WORD_LIST_ID;
        CLOSE C2;
    END IF;

   INSERT INTO HZ_WORD_LISTS(
                WORD_LIST_ID,
	            WORD_LIST_NAME,
 		        LANGUAGE,
                SOURCE_NAME,
                CREATED_BY,
                CREATION_DATE,
                LAST_UPDATE_LOGIN,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                OBJECT_VERSION_NUMBER,
		NON_DELIMITED_FLAG
               )
               VALUES (
                decode(X_WORD_LIST_ID,               FND_API.G_MISS_NUM,  NULL,
                                                     X_WORD_LIST_ID),
                decode(X_WORD_LIST_NAME,             FND_API.G_MISS_CHAR,  NULL,
                                                     UPPER(X_WORD_LIST_NAME)),
                decode(X_LANGUAGE,                   FND_API.G_MISS_CHAR,  NULL,
                                                     X_LANGUAGE),
                decode(X_SOURCE_NAME,                FND_API.G_MISS_CHAR,  NULL,
                                                     X_SOURCE_NAME),
                decode(X_created_by,                 FND_API.G_MISS_NUM,  NULL,
                                                     X_created_by),
                decode(X_creation_date,              FND_API.G_MISS_DATE, NULL,
                                                     X_creation_date),
                decode(X_last_update_login,          FND_API.G_MISS_NUM,  NULL,
                                                     X_last_update_login),
                decode(X_last_update_date,           FND_API.G_MISS_DATE, NULL,
                                                     X_last_update_date),
                decode(X_last_updated_by,            FND_API.G_MISS_NUM,  NULL,
                                                     X_last_updated_by),
                1,
		decode(X_NON_DELIMITED_FLAG,FND_API.G_MISS_CHAR,NULL,X_NON_DELIMITED_FLAG)
                );

End Insert_Row;

PROCEDURE Update_Row(
                      X_WORD_LIST_ID                     NUMBER,
                      X_WORD_LIST_NAME                   VARCHAR2,
                      X_LANGUAGE                         VARCHAR2,
                      X_SOURCE_NAME                      VARCHAR2,
                      X_CREATED_BY                        NUMBER,
                      X_CREATION_DATE                     DATE,
                      X_LAST_UPDATE_LOGIN                 NUMBER,
                      X_LAST_UPDATE_DATE                  DATE,
                      X_LAST_UPDATED_BY                   NUMBER,
                      X_OBJECT_VERSION_NUMBER  IN OUT     NOCOPY NUMBER,
                      X_MSG_COUNT           IN OUT        NOCOPY NUMBER,
		      X_NON_DELIMITED_FLAG                VARCHAR2 DEFAULT 'N')
IS
l_count NUMBER;
BEGIN
IF x_WORD_LIST_ID IS NOT NULL THEN
      x_msg_count := 0;
      /* Word List should be unique */
      SELECT count(*) INTO l_count
        FROM   hz_word_lists
        WHERE  word_list_name     = UPPER(x_WORD_LIST_name)
           AND WORD_LIST_ID       <> X_WORD_LIST_ID;

      IF l_count > 0 THEN
         x_msg_count := x_msg_count +1;
         l_count := 0;
         FND_MESSAGE.SET_NAME( 'AR', 'HZ_DUPL_WORD_LIST' );
         FND_MSG_PUB.ADD;
         return;
     END IF;
END IF;
   Update_Row(
              X_WORD_LIST_ID,
              X_WORD_LIST_NAME,
              X_LANGUAGE,
              X_SOURCE_NAME,
              X_CREATED_BY,
              X_CREATION_DATE,
              X_LAST_UPDATE_LOGIN,
              X_LAST_UPDATE_DATE,
              X_LAST_UPDATED_BY,
              X_OBJECT_VERSION_NUMBER,
	      X_NON_DELIMITED_FLAG);
END;
PROCEDURE Update_Row(
                      X_WORD_LIST_ID                     NUMBER,
	                  X_WORD_LIST_NAME                   VARCHAR2,
 		              X_LANGUAGE                         VARCHAR2,
                      X_SOURCE_NAME                      VARCHAR2,
                      X_CREATED_BY                        NUMBER,
                      X_CREATION_DATE                     DATE,
                      X_LAST_UPDATE_LOGIN                 NUMBER,
                      X_LAST_UPDATE_DATE                  DATE,
                      X_LAST_UPDATED_BY                   NUMBER,
                      X_OBJECT_VERSION_NUMBER  IN OUT     NOCOPY NUMBER,
		      X_NON_DELIMITED_FLAG                VARCHAR2 DEFAULT 'N')
IS
 p_object_version_number number;

BEGIN

 p_object_version_number := NVL(X_object_version_number, 1) + 1;


   UPDATE HZ_WORD_LISTS
   SET
      WORD_LIST_NAME    = decode(X_WORD_LIST_NAME, FND_API.G_MISS_CHAR, WORD_LIST_NAME,
                                 UPPER(X_WORD_LIST_NAME)),
      LANGUAGE          = decode(X_LANGUAGE ,   FND_API.G_MISS_CHAR , LANGUAGE,
                                 X_LANGUAGE),
      SOURCE_NAME       = decode(X_SOURCE_NAME,   FND_API.G_MISS_CHAR , SOURCE_NAME,
                                 X_SOURCE_NAME),
      -- bug 3032780
      /*
      CREATED_BY        = decode(X_created_by,FND_API.G_MISS_NUM,  CREATED_BY,
                                 X_created_by),
      CREATION_DATE     = decode(X_CREATION_DATE,FND_API.G_MISS_DATE, CREATION_DATE,
                                 X_CREATION_DATE),*/
      LAST_UPDATE_LOGIN = decode(X_LAST_UPDATE_LOGIN,FND_API.G_MISS_NUM, LAST_UPDATE_LOGIN,
                                 X_LAST_UPDATE_LOGIN),
      LAST_UPDATE_DATE  = decode(X_LAST_UPDATE_DATE, FND_API.G_MISS_DATE,LAST_UPDATE_DATE,
                                 X_LAST_UPDATE_DATE),
      LAST_UPDATED_BY   = decode(X_LAST_UPDATED_BY,  FND_API.G_MISS_NUM,LAST_UPDATED_BY,
                                 X_LAST_UPDATED_BY),
      OBJECT_VERSION_NUMBER = p_object_version_number,
      NON_DELIMITED_FLAG = decode(X_NON_DELIMITED_FLAG,FND_API.G_MISS_CHAR,NON_DELIMITED_FLAG,
                                 X_NON_DELIMITED_FLAG)
    WHERE WORD_LIST_ID  = X_WORD_LIST_ID;


    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;

 X_OBJECT_VERSION_NUMBER := p_object_version_number;

 END Update_Row;

 PROCEDURE Delete_Row(X_WORD_LIST_ID   NUMBER)
 IS
 BEGIN
   --Delete all the word replacements
   HZ_WORD_REPLACEMENTS1_PKG.Delete_Row(X_WORD_LIST_ID); --Bug No: 3868758.

   DELETE FROM HZ_WORD_LISTS
   WHERE WORD_LIST_ID  = X_WORD_LIST_ID;

   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;

PROCEDURE Lock_Row(
                      X_WORD_LIST_ID           IN OUT   NOCOPY NUMBER,
	                  X_OBJECT_VERSION_NUMBER  IN       NUMBER)
 IS
 CURSOR C IS
 SELECT OBJECT_VERSION_NUMBER
 FROM HZ_WORD_LISTS
 WHERE WORD_LIST_ID  = X_WORD_LIST_ID
 FOR UPDATE OF word_list_id NOWAIT;
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
END HZ_WORD_LISTS_PKG;

/
