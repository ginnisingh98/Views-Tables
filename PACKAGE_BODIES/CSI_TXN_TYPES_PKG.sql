--------------------------------------------------------
--  DDL for Package Body CSI_TXN_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_TXN_TYPES_PKG" as
/* $Header: csittstb.pls 115.8 2002/11/12 00:25:58 rmamidip noship $ */
-- Start of Comments
-- Package name     : CSI_TXN_TYPES_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSI_TXN_TYPES_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csittstb.pls';

PROCEDURE Insert_Row(
          px_TRANSACTION_TYPE_ID   IN OUT NOCOPY NUMBER,
          p_SOURCE_APPLICATION_ID    NUMBER,
          p_SOURCE_TRANSACTION_TYPE    VARCHAR2,
          p_SOURCE_TXN_TYPE_NAME    VARCHAR2,
          p_DESCRIPTION    VARCHAR2,
          p_SOURCE_OBJECT_CODE    VARCHAR2,
          p_IN_OUT_FLAG    VARCHAR2,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_OBJECT_VERSION_NUMBER    NUMBER,
          p_SUB_TYPE_ID     NUMBER,
          p_DEFAULT_FLAG    VARCHAR2,
          p_UPDATE_IB_FLAG    VARCHAR2,
          p_SEEDED_FLAG       VARCHAR2
          )

 IS
   CURSOR C2 IS SELECT CSI_TXN_TYPES_S.nextval FROM sys.dual;
BEGIN
   If (px_TRANSACTION_TYPE_ID IS NULL) OR (px_TRANSACTION_TYPE_ID = FND_API.G_MISS_NUM) then
       OPEN C2;
       FETCH C2 INTO px_TRANSACTION_TYPE_ID;
       CLOSE C2;
   End If;
   INSERT INTO CSI_TXN_TYPES(
           TRANSACTION_TYPE_ID,
           SOURCE_APPLICATION_ID,
           SOURCE_TRANSACTION_TYPE,
           SOURCE_TXN_TYPE_NAME,
           DESCRIPTION,
           SOURCE_OBJECT_CODE,
           IN_OUT_FLAG,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           OBJECT_VERSION_NUMBER,
           SEEDED_FLAG
          ) VALUES (
           px_TRANSACTION_TYPE_ID,
           decode( p_SOURCE_APPLICATION_ID, FND_API.G_MISS_NUM, NULL, p_SOURCE_APPLICATION_ID),
           decode( p_SOURCE_TRANSACTION_TYPE, FND_API.G_MISS_CHAR, NULL, p_SOURCE_TRANSACTION_TYPE),
           decode( p_SOURCE_TXN_TYPE_NAME, FND_API.G_MISS_CHAR, NULL, p_SOURCE_TXN_TYPE_NAME),
           decode( p_DESCRIPTION, FND_API.G_MISS_CHAR, NULL, p_DESCRIPTION),
           decode( p_SOURCE_OBJECT_CODE, FND_API.G_MISS_CHAR, NULL, p_SOURCE_OBJECT_CODE),
           decode( p_IN_OUT_FLAG, FND_API.G_MISS_CHAR, NULL, p_IN_OUT_FLAG),
           decode( p_CREATED_BY, FND_API.G_MISS_NUM, NULL, p_CREATED_BY),
           decode( p_CREATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_CREATION_DATE),
           decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATED_BY),
           decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_LAST_UPDATE_DATE),
           decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATE_LOGIN),
           decode( p_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, NULL, p_OBJECT_VERSION_NUMBER),
           'N'
        );

   INSERT INTO CSI_SOURCE_IB_TYPES(
                  TRANSACTION_TYPE_ID,
                  SUB_TYPE_ID,
                  DEFAULT_FLAG,
                  UPDATE_IB_FLAG,
                  CREATED_BY,
                  CREATION_DATE,
                  LAST_UPDATED_BY,
                  LAST_UPDATE_DATE,
                  LAST_UPDATE_LOGIN,
                  SEEDED_FLAG,
                  OBJECT_VERSION_NUMBER
                  ) VALUES (
                   px_TRANSACTION_TYPE_ID,
                   decode( p_SUB_TYPE_ID, FND_API.G_MISS_NUM, NULL, p_SUB_TYPE_ID),
                   decode( p_DEFAULT_FLAG, FND_API.G_MISS_CHAR, NULL, p_DEFAULT_FLAG),
                   decode( p_UPDATE_IB_FLAG, FND_API.G_MISS_CHAR, NULL, p_UPDATE_IB_FLAG),
                   decode( p_CREATED_BY, FND_API.G_MISS_NUM, NULL, p_CREATED_BY),
                   decode( p_CREATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_CREATION_DATE),
                   decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATED_BY),
                   decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_LAST_UPDATE_DATE),
                   decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATE_LOGIN),
                   'N',
                    1 );


End Insert_Row;

PROCEDURE Update_Row(
          p_TRANSACTION_TYPE_ID    NUMBER,
          p_SOURCE_APPLICATION_ID    NUMBER,
          p_SOURCE_TRANSACTION_TYPE    VARCHAR2,
          p_SOURCE_TXN_TYPE_NAME    VARCHAR2,
          p_DESCRIPTION    VARCHAR2,
          p_SOURCE_OBJECT_CODE    VARCHAR2,
          p_IN_OUT_FLAG    VARCHAR2,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_OBJECT_VERSION_NUMBER    NUMBER,
          p_SUB_TYPE_ID     NUMBER,
          p_DEFAULT_FLAG    VARCHAR2,
          p_UPDATE_IB_FLAG    VARCHAR2)


 IS
 BEGIN
    Update CSI_TXN_TYPES
    SET
              SOURCE_APPLICATION_ID = decode( p_SOURCE_APPLICATION_ID, FND_API.G_MISS_NUM, SOURCE_APPLICATION_ID, p_SOURCE_APPLICATION_ID),
              SOURCE_TRANSACTION_TYPE = decode( p_SOURCE_TRANSACTION_TYPE, FND_API.G_MISS_CHAR, SOURCE_TRANSACTION_TYPE, p_SOURCE_TRANSACTION_TYPE),
              SOURCE_TXN_TYPE_NAME = decode( p_SOURCE_TXN_TYPE_NAME, FND_API.G_MISS_CHAR, SOURCE_TXN_TYPE_NAME, p_SOURCE_TXN_TYPE_NAME),
              DESCRIPTION = decode( p_DESCRIPTION, FND_API.G_MISS_CHAR, DESCRIPTION, p_DESCRIPTION),
              SOURCE_OBJECT_CODE = decode( p_SOURCE_OBJECT_CODE, FND_API.G_MISS_CHAR, SOURCE_OBJECT_CODE, p_SOURCE_OBJECT_CODE),
              IN_OUT_FLAG = decode( p_IN_OUT_FLAG, FND_API.G_MISS_CHAR, IN_OUT_FLAG, p_IN_OUT_FLAG),
              CREATED_BY = decode( p_CREATED_BY, FND_API.G_MISS_NUM, CREATED_BY, p_CREATED_BY),
              CREATION_DATE = decode( p_CREATION_DATE, FND_API.G_MISS_DATE, CREATION_DATE, p_CREATION_DATE),
              LAST_UPDATED_BY = decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, LAST_UPDATED_BY, p_LAST_UPDATED_BY),
              LAST_UPDATE_DATE = decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, LAST_UPDATE_DATE, p_LAST_UPDATE_DATE),
              LAST_UPDATE_LOGIN = decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, LAST_UPDATE_LOGIN, p_LAST_UPDATE_LOGIN),
              OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1
              --OBJECT_VERSION_NUMBER = decode( p_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, OBJECT_VERSION_NUMBER, p_OBJECT_VERSION_NUMBER)
    where TRANSACTION_TYPE_ID = p_TRANSACTION_TYPE_ID;

    Update CSI_SOURCE_IB_TYPES
    SET
              DEFAULT_FLAG = decode( p_DEFAULT_FLAG, FND_API.G_MISS_CHAR, DEFAULT_FLAG, p_DEFAULT_FLAG),
              UPDATE_IB_FLAG = decode( p_UPDATE_IB_FLAG, FND_API.G_MISS_CHAR, UPDATE_IB_FLAG, p_UPDATE_IB_FLAG),
              CREATED_BY = decode( p_CREATED_BY, FND_API.G_MISS_NUM, CREATED_BY, p_CREATED_BY),
              CREATION_DATE = decode( p_CREATION_DATE, FND_API.G_MISS_DATE, CREATION_DATE, p_CREATION_DATE),
              LAST_UPDATED_BY = decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, LAST_UPDATED_BY, p_LAST_UPDATED_BY),
              LAST_UPDATE_DATE = decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, LAST_UPDATE_DATE, p_LAST_UPDATE_DATE),
              LAST_UPDATE_LOGIN = decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, LAST_UPDATE_LOGIN, p_LAST_UPDATE_LOGIN),
              OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1
    where TRANSACTION_TYPE_ID = p_TRANSACTION_TYPE_ID
    and   SUB_TYPE_ID         = p_sub_type_id;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
END Update_Row;

PROCEDURE Delete_Row(
    p_TRANSACTION_TYPE_ID  NUMBER,
    p_SUB_TYPE_ID     NUMBER)
 IS
 BEGIN
/* Commented as the Transaction Type should not be deleted */

--   DELETE FROM CSI_TXN_TYPES
--    WHERE TRANSACTION_TYPE_ID = p_TRANSACTION_TYPE_ID;

   DELETE FROM CSI_SOURCE_IB_TYPES
    WHERE TRANSACTION_TYPE_ID = p_TRANSACTION_TYPE_ID
    AND   SUB_TYPE_ID         = p_SUB_TYPE_ID;

   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;

PROCEDURE Lock_Row(
          p_TRANSACTION_TYPE_ID    NUMBER,
          p_SOURCE_APPLICATION_ID    NUMBER,
          p_SOURCE_TRANSACTION_TYPE    VARCHAR2,
          p_SOURCE_TXN_TYPE_NAME    VARCHAR2,
          p_DESCRIPTION    VARCHAR2,
          p_SOURCE_OBJECT_CODE    VARCHAR2,
          p_IN_OUT_FLAG    VARCHAR2,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_OBJECT_VERSION_NUMBER    NUMBER,
          p_SUB_TYPE_ID     NUMBER,
          p_DEFAULT_FLAG    VARCHAR2,
          p_UPDATE_IB_FLAG    VARCHAR2,
          p_SEEDED_FLAG       VARCHAR2)

 IS
   CURSOR C IS
        SELECT *
         FROM CSI_TXN_TYPES
        WHERE TRANSACTION_TYPE_ID =  p_TRANSACTION_TYPE_ID
        FOR UPDATE of TRANSACTION_TYPE_ID NOWAIT;
   Recinfo C%ROWTYPE;

   CURSOR C1 IS
        SELECT *
         FROM CSI_SOURCE_IB_TYPES
        WHERE TRANSACTION_TYPE_ID = p_TRANSACTION_TYPE_ID
        AND   SUB_TYPE_ID         = p_SUB_TYPE_ID
        FOR UPDATE NOWAIT;

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
           (      Recinfo.TRANSACTION_TYPE_ID = p_TRANSACTION_TYPE_ID)
       AND (    ( Recinfo.SOURCE_APPLICATION_ID = p_SOURCE_APPLICATION_ID)
            OR (    ( Recinfo.SOURCE_APPLICATION_ID IS NULL )
                AND (  p_SOURCE_APPLICATION_ID IS NULL )))
       AND (    ( Recinfo.SOURCE_TRANSACTION_TYPE = p_SOURCE_TRANSACTION_TYPE)
            OR (    ( Recinfo.SOURCE_TRANSACTION_TYPE IS NULL )
                AND (  p_SOURCE_TRANSACTION_TYPE IS NULL )))
       AND (    ( Recinfo.SOURCE_TXN_TYPE_NAME = p_SOURCE_TXN_TYPE_NAME)
            OR (    ( Recinfo.SOURCE_TXN_TYPE_NAME IS NULL )
                AND (  p_SOURCE_TXN_TYPE_NAME IS NULL )))
       AND (    ( Recinfo.DESCRIPTION = p_DESCRIPTION)
            OR (    ( Recinfo.DESCRIPTION IS NULL )
                AND (  p_DESCRIPTION IS NULL )))
       AND (    ( Recinfo.SOURCE_OBJECT_CODE = p_SOURCE_OBJECT_CODE)
            OR (    ( Recinfo.SOURCE_OBJECT_CODE IS NULL )
                AND (  p_SOURCE_OBJECT_CODE IS NULL )))
       AND (    ( Recinfo.IN_OUT_FLAG = p_IN_OUT_FLAG)
            OR (    ( Recinfo.IN_OUT_FLAG IS NULL )
                AND (  p_IN_OUT_FLAG IS NULL )))
       AND (    ( Recinfo.CREATED_BY = p_CREATED_BY)
            OR (    ( Recinfo.CREATED_BY IS NULL )
                AND (  p_CREATED_BY IS NULL )))
       AND (    ( Recinfo.CREATION_DATE = p_CREATION_DATE)
            OR (    ( Recinfo.CREATION_DATE IS NULL )
                AND (  p_CREATION_DATE IS NULL )))
       AND (    ( Recinfo.LAST_UPDATED_BY = p_LAST_UPDATED_BY)
            OR (    ( Recinfo.LAST_UPDATED_BY IS NULL )
                AND (  p_LAST_UPDATED_BY IS NULL )))
       AND (    ( Recinfo.LAST_UPDATE_DATE = p_LAST_UPDATE_DATE)
            OR (    ( Recinfo.LAST_UPDATE_DATE IS NULL )
                AND (  p_LAST_UPDATE_DATE IS NULL )))
       AND (    ( Recinfo.LAST_UPDATE_LOGIN = p_LAST_UPDATE_LOGIN)
            OR (    ( Recinfo.LAST_UPDATE_LOGIN IS NULL )
                AND (  p_LAST_UPDATE_LOGIN IS NULL )))
       AND (    ( Recinfo.OBJECT_VERSION_NUMBER = p_OBJECT_VERSION_NUMBER)
            OR (    ( Recinfo.OBJECT_VERSION_NUMBER IS NULL )
                AND (  p_OBJECT_VERSION_NUMBER IS NULL )))
       /* AND (    ( Recinfo.SEEDED_FLAG = p_SEEDED_FLAG)
            OR (    ( Recinfo.SEEDED_FLAG IS NULL )
                AND (  p_SEEDED_FLAG IS NULL ))) */ --Commented for Bug 2419385. Record updated . Pl. requery to check message.
       ) then
       return;
   else
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   End If;


   for sibtyp in c1 loop
       if(
           ( sibtyp.transaction_type_id = p_transaction_type_id
             AND sibtyp.sub_type_id = p_sub_type_id )
        AND( ( sibtyp.default_flag = p_default_flag )
          OR ( ( sibtyp.default_flag IS NULL )
             AND ( p_default_flag IS NULL )))
        AND( ( sibtyp.update_ib_flag = p_update_ib_flag )
          OR ( ( sibtyp.update_ib_flag IS NULL )
             AND ( p_update_ib_flag IS NULL )))
       AND (    ( sibtyp.CREATED_BY = p_CREATED_BY)
            OR (    ( sibtyp.CREATED_BY IS NULL )
                AND (  p_CREATED_BY IS NULL )))
       AND (    ( sibtyp.CREATION_DATE = p_CREATION_DATE)
            OR (    ( sibtyp.CREATION_DATE IS NULL )
                AND (  p_CREATION_DATE IS NULL )))
       AND (    ( sibtyp.LAST_UPDATED_BY = p_LAST_UPDATED_BY)
            OR (    ( sibtyp.LAST_UPDATED_BY IS NULL )
                AND (  p_LAST_UPDATED_BY IS NULL )))
       AND (    ( sibtyp.LAST_UPDATE_DATE = p_LAST_UPDATE_DATE)
            OR (    ( sibtyp.LAST_UPDATE_DATE IS NULL )
                AND (  p_LAST_UPDATE_DATE IS NULL )))
       AND (    ( sibtyp.LAST_UPDATE_LOGIN = p_LAST_UPDATE_LOGIN)
            OR (    ( sibtyp.LAST_UPDATE_LOGIN IS NULL )
                AND (  p_LAST_UPDATE_LOGIN IS NULL )))
       AND (    (sibtyp.SEEDED_FLAG = p_SEEDED_FLAG)
            OR (    ( sibtyp.SEEDED_FLAG IS NULL )
                AND (  p_SEEDED_FLAG IS NULL )))
       AND (    ( sibtyp.OBJECT_VERSION_NUMBER = p_OBJECT_VERSION_NUMBER)
            OR (    ( sibtyp.OBJECT_VERSION_NUMBER IS NULL )
                AND (  p_OBJECT_VERSION_NUMBER IS NULL )))

         ) then
         return;
       else
         FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
         APP_EXCEPTION.RAISE_EXCEPTION;
       End If;
   End Loop;

END Lock_Row;

End CSI_TXN_TYPES_PKG;

/
