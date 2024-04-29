--------------------------------------------------------
--  DDL for Package Body CSI_SOURCE_IB_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_SOURCE_IB_TYPES_PKG" as
/* $Header: csitsitb.pls 115.3 2002/11/12 00:23:29 rmamidip noship $ */
-- Start of Comments
-- Package name     : CSI_SOURCE_IB_TYPES_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSI_SOURCE_IB_TYPES_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csitsitb.pls';

PROCEDURE Insert_Row(
          p_TRANSACTION_TYPE_ID    NUMBER,
          px_SUB_TYPE_ID   IN OUT NOCOPY NUMBER,
          p_DEFAULT_FLAG    VARCHAR2,
          p_UPDATE_IB_FLAG    VARCHAR2)

 IS
   CURSOR C2 IS SELECT CSI_TXN_SUB_TYPES_S.nextval FROM sys.dual;
BEGIN
   If (px_SUB_TYPE_ID IS NULL) OR (px_SUB_TYPE_ID = FND_API.G_MISS_NUM) then
       OPEN C2;
       FETCH C2 INTO px_SUB_TYPE_ID;
       CLOSE C2;
   End If;
   INSERT INTO CSI_SOURCE_IB_TYPES(
           TRANSACTION_TYPE_ID,
           SUB_TYPE_ID,
           DEFAULT_FLAG,
           UPDATE_IB_FLAG
          ) VALUES (
           decode( p_TRANSACTION_TYPE_ID, FND_API.G_MISS_NUM, NULL, p_TRANSACTION_TYPE_ID),
           px_SUB_TYPE_ID,
           decode( p_DEFAULT_FLAG, FND_API.G_MISS_CHAR, NULL, p_DEFAULT_FLAG),
           decode( p_UPDATE_IB_FLAG, FND_API.G_MISS_CHAR, NULL, p_UPDATE_IB_FLAG));
End Insert_Row;

PROCEDURE Update_Row(
          p_TRANSACTION_TYPE_ID    NUMBER,
          p_SUB_TYPE_ID    NUMBER,
          p_DEFAULT_FLAG    VARCHAR2,
          p_UPDATE_IB_FLAG    VARCHAR2)

 IS
 BEGIN
    Update CSI_SOURCE_IB_TYPES
    SET
              SUB_TYPE_ID = decode( p_SUB_TYPE_ID, FND_API.G_MISS_NUM, SUB_TYPE_ID, p_SUB_TYPE_ID),
              DEFAULT_FLAG = decode( p_DEFAULT_FLAG, FND_API.G_MISS_CHAR, DEFAULT_FLAG, p_DEFAULT_FLAG),
              UPDATE_IB_FLAG = decode( p_UPDATE_IB_FLAG, FND_API.G_MISS_CHAR, UPDATE_IB_FLAG, p_UPDATE_IB_FLAG)
    where SUB_TYPE_ID = p_SUB_TYPE_ID;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
END Update_Row;

PROCEDURE Delete_Row(
    p_SUB_TYPE_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM CSI_SOURCE_IB_TYPES
    WHERE SUB_TYPE_ID = p_SUB_TYPE_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;

PROCEDURE Lock_Row(
          p_TRANSACTION_TYPE_ID    NUMBER,
          p_SUB_TYPE_ID    NUMBER,
          p_DEFAULT_FLAG    VARCHAR2,
          p_UPDATE_IB_FLAG    VARCHAR2)

 IS
   CURSOR C IS
        SELECT *
         FROM CSI_SOURCE_IB_TYPES
        WHERE SUB_TYPE_ID =  p_SUB_TYPE_ID
        FOR UPDATE of SUB_TYPE_ID NOWAIT;
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
           (      Recinfo.TRANSACTION_TYPE_ID = p_TRANSACTION_TYPE_ID)
       AND (    ( Recinfo.SUB_TYPE_ID = p_SUB_TYPE_ID)
            OR (    ( Recinfo.SUB_TYPE_ID IS NULL )
                AND (  p_SUB_TYPE_ID IS NULL )))
       AND (    ( Recinfo.DEFAULT_FLAG = p_DEFAULT_FLAG)
            OR (    ( Recinfo.DEFAULT_FLAG IS NULL )
                AND (  p_DEFAULT_FLAG IS NULL )))
       AND (    ( Recinfo.UPDATE_IB_FLAG = p_UPDATE_IB_FLAG)
            OR (    ( Recinfo.UPDATE_IB_FLAG IS NULL )
                AND (  p_UPDATE_IB_FLAG IS NULL )))
       ) then
       return;
   else
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   End If;
END Lock_Row;

End CSI_SOURCE_IB_TYPES_PKG;

/
