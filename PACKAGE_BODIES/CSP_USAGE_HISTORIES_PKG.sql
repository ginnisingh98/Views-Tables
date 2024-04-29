--------------------------------------------------------
--  DDL for Package Body CSP_USAGE_HISTORIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_USAGE_HISTORIES_PKG" as
/* $Header: csptpusb.pls 115.4 2002/11/26 06:36:14 hhaugeru ship $ */
-- Start of Comments
-- Package name     : CSP_USAGE_HISTORIES_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSP_USAGE_HISTORIES_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csptpusb.pls';

PROCEDURE Insert_Row(
          px_USAGE_ID   IN OUT NOCOPY NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_INVENTORY_ITEM_ID    NUMBER,
          p_ORGANIZATION_ID    NUMBER,
          p_HIERARCHY_NODE_ID    NUMBER,
          p_PARTS_LOOP_ID    NUMBER,
          p_PERIOD_TYPE    VARCHAR2,
          p_PERIOD_START_DATE    DATE,
          p_QUANTITY    NUMBER,
		p_HISTORY_DATA_TYPE NUMBER ,
		p_USAGE_HEADER_ID NUMBER ,
          p_ATTRIBUTE_CATEGORY    VARCHAR2,
          p_ATTRIBUTE1    VARCHAR2,
          p_ATTRIBUTE2    VARCHAR2,
          p_ATTRIBUTE3    VARCHAR2,
          p_ATTRIBUTE4    VARCHAR2,
          p_ATTRIBUTE5    VARCHAR2,
          p_ATTRIBUTE6    VARCHAR2,
          p_ATTRIBUTE7    VARCHAR2,
          p_ATTRIBUTE8    VARCHAR2,
          p_ATTRIBUTE9    VARCHAR2,
          p_ATTRIBUTE10    VARCHAR2,
          p_ATTRIBUTE11    VARCHAR2,
          p_ATTRIBUTE12    VARCHAR2,
          p_ATTRIBUTE13    VARCHAR2,
          p_ATTRIBUTE14    VARCHAR2,
          p_ATTRIBUTE15    VARCHAR2,
          p_REQUEST_ID    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_SUBINVENTORY_CODE    VARCHAR2,
          p_TRANSACTION_TYPE_ID    NUMBER)

 IS
   CURSOR C2 IS SELECT CSP_USAGE_HISTORIES_S1.nextval FROM sys.dual;
BEGIN
   If (px_USAGE_ID IS NULL) OR (px_USAGE_ID = FND_API.G_MISS_NUM) then
       OPEN C2;
       FETCH C2 INTO px_USAGE_ID;
       CLOSE C2;
   End If;
   INSERT INTO CSP_USAGE_HISTORIES(
           USAGE_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           INVENTORY_ITEM_ID,
           ORGANIZATION_ID,
           HIERARCHY_NODE_ID,
           PARTS_LOOP_ID,
           PERIOD_TYPE,
           PERIOD_START_DATE,
           QUANTITY,
		 HISTORY_DATA_TYPE,
		 USAGE_HEADER_ID,
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
           REQUEST_ID,
           PROGRAM_APPLICATION_ID,
           PROGRAM_ID,
           PROGRAM_UPDATE_DATE,
           SUBINVENTORY_CODE,
           TRANSACTION_TYPE_ID
          ) VALUES (
           px_USAGE_ID,
           decode( p_CREATED_BY, FND_API.G_MISS_NUM, NULL, p_CREATED_BY),
           decode( p_CREATION_DATE, FND_API.G_MISS_DATE, to_date(null), p_CREATION_DATE),
           decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATED_BY),
           decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, to_date(null), p_LAST_UPDATE_DATE),
           decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATE_LOGIN),
           decode( p_INVENTORY_ITEM_ID, FND_API.G_MISS_NUM, NULL, p_INVENTORY_ITEM_ID),
           decode( p_ORGANIZATION_ID, FND_API.G_MISS_NUM, NULL, p_ORGANIZATION_ID),
           decode( p_HIERARCHY_NODE_ID, FND_API.G_MISS_NUM, NULL, p_HIERARCHY_NODE_ID),
           decode( p_PARTS_LOOP_ID, FND_API.G_MISS_NUM, NULL, p_PARTS_LOOP_ID),
           decode( p_PERIOD_TYPE, FND_API.G_MISS_CHAR, NULL, p_PERIOD_TYPE),
           decode( p_PERIOD_START_DATE, FND_API.G_MISS_DATE, to_date(null), p_PERIOD_START_DATE),
           decode( p_QUANTITY, FND_API.G_MISS_NUM, NULL, p_QUANTITY),
           decode( p_HISTORY_DATA_TYPE, FND_API.G_MISS_NUM, NULL,p_HISTORY_DATA_TYPE),
           decode( p_USAGE_HEADER_ID, FND_API.G_MISS_NUM, NULL, p_USAGE_HEADER_ID),
           decode( p_ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE_CATEGORY),
           decode( p_ATTRIBUTE1, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE1),
           decode( p_ATTRIBUTE2, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE2),
           decode( p_ATTRIBUTE3, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE3),
           decode( p_ATTRIBUTE4, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE4),
           decode( p_ATTRIBUTE5, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE5),
           decode( p_ATTRIBUTE6, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE6),
           decode( p_ATTRIBUTE7, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE7),
           decode( p_ATTRIBUTE8, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE8),
           decode( p_ATTRIBUTE9, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE9),
           decode( p_ATTRIBUTE10, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE10),
           decode( p_ATTRIBUTE11, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE11),
           decode( p_ATTRIBUTE12, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE12),
           decode( p_ATTRIBUTE13, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE13),
           decode( p_ATTRIBUTE14, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE14),
           decode( p_ATTRIBUTE15, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE15),
           decode( p_REQUEST_ID, FND_API.G_MISS_NUM, NULL, p_REQUEST_ID),
           decode( p_PROGRAM_APPLICATION_ID, FND_API.G_MISS_NUM, NULL, p_PROGRAM_APPLICATION_ID),
           decode( p_PROGRAM_ID, FND_API.G_MISS_NUM, NULL, p_PROGRAM_ID),
           decode( p_PROGRAM_UPDATE_DATE, FND_API.G_MISS_DATE, to_date(null), p_PROGRAM_UPDATE_DATE),
           decode( p_SUBINVENTORY_CODE, FND_API.G_MISS_CHAR, NULL, p_SUBINVENTORY_CODE),
           decode( p_TRANSACTION_TYPE_ID, FND_API.G_MISS_NUM, NULL, p_TRANSACTION_TYPE_ID));
End Insert_Row;

PROCEDURE Update_Row(
          p_USAGE_ID    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_INVENTORY_ITEM_ID    NUMBER,
          p_ORGANIZATION_ID    NUMBER,
          p_HIERARCHY_NODE_ID    NUMBER,
          p_PARTS_LOOP_ID    NUMBER,
          p_PERIOD_TYPE    VARCHAR2,
          p_PERIOD_START_DATE    DATE,
          p_QUANTITY    NUMBER,
		p_HISTORY_DATA_TYPE NUMBER ,
		p_USAGE_HEADER_ID NUMBER ,
          p_ATTRIBUTE_CATEGORY    VARCHAR2,
          p_ATTRIBUTE1    VARCHAR2,
          p_ATTRIBUTE2    VARCHAR2,
          p_ATTRIBUTE3    VARCHAR2,
          p_ATTRIBUTE4    VARCHAR2,
          p_ATTRIBUTE5    VARCHAR2,
          p_ATTRIBUTE6    VARCHAR2,
          p_ATTRIBUTE7    VARCHAR2,
          p_ATTRIBUTE8    VARCHAR2,
          p_ATTRIBUTE9    VARCHAR2,
          p_ATTRIBUTE10    VARCHAR2,
          p_ATTRIBUTE11    VARCHAR2,
          p_ATTRIBUTE12    VARCHAR2,
          p_ATTRIBUTE13    VARCHAR2,
          p_ATTRIBUTE14    VARCHAR2,
          p_ATTRIBUTE15    VARCHAR2,
          p_REQUEST_ID    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_SUBINVENTORY_CODE    VARCHAR2,
          p_TRANSACTION_TYPE_ID    NUMBER)

 IS
 BEGIN
    Update CSP_USAGE_HISTORIES
    SET
              CREATED_BY = decode( p_CREATED_BY, FND_API.G_MISS_NUM, CREATED_BY, p_CREATED_BY),
              CREATION_DATE = decode( p_CREATION_DATE, FND_API.G_MISS_DATE, CREATION_DATE, p_CREATION_DATE),
              LAST_UPDATED_BY = decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, LAST_UPDATED_BY, p_LAST_UPDATED_BY),
              LAST_UPDATE_DATE = decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, LAST_UPDATE_DATE, p_LAST_UPDATE_DATE),
              LAST_UPDATE_LOGIN = decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, LAST_UPDATE_LOGIN, p_LAST_UPDATE_LOGIN),
              INVENTORY_ITEM_ID = decode( p_INVENTORY_ITEM_ID, FND_API.G_MISS_NUM, INVENTORY_ITEM_ID, p_INVENTORY_ITEM_ID),
              ORGANIZATION_ID = decode( p_ORGANIZATION_ID, FND_API.G_MISS_NUM, ORGANIZATION_ID, p_ORGANIZATION_ID),
              HIERARCHY_NODE_ID = decode( p_HIERARCHY_NODE_ID, FND_API.G_MISS_NUM, HIERARCHY_NODE_ID, p_HIERARCHY_NODE_ID),
              PARTS_LOOP_ID = decode( p_PARTS_LOOP_ID, FND_API.G_MISS_NUM, PARTS_LOOP_ID, p_PARTS_LOOP_ID),
              PERIOD_TYPE = decode( p_PERIOD_TYPE, FND_API.G_MISS_CHAR, PERIOD_TYPE, p_PERIOD_TYPE),
              PERIOD_START_DATE = decode( p_PERIOD_START_DATE, FND_API.G_MISS_DATE, PERIOD_START_DATE, p_PERIOD_START_DATE),
              QUANTITY = decode( p_QUANTITY, FND_API.G_MISS_NUM, QUANTITY, p_QUANTITY),
              HISTORY_DATA_TYPE = decode( p_HISTORY_DATA_TYPE, FND_API.G_MISS_NUM, NULL,p_HISTORY_DATA_TYPE),
              USAGE_HEADER_ID = decode( p_USAGE_HEADER_ID, FND_API.G_MISS_NUM, NULL, p_USAGE_HEADER_ID),
              ATTRIBUTE_CATEGORY = decode( p_ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR, ATTRIBUTE_CATEGORY, p_ATTRIBUTE_CATEGORY),
              ATTRIBUTE1 = decode( p_ATTRIBUTE1, FND_API.G_MISS_CHAR, ATTRIBUTE1, p_ATTRIBUTE1),
              ATTRIBUTE2 = decode( p_ATTRIBUTE2, FND_API.G_MISS_CHAR, ATTRIBUTE2, p_ATTRIBUTE2),
              ATTRIBUTE3 = decode( p_ATTRIBUTE3, FND_API.G_MISS_CHAR, ATTRIBUTE3, p_ATTRIBUTE3),
              ATTRIBUTE4 = decode( p_ATTRIBUTE4, FND_API.G_MISS_CHAR, ATTRIBUTE4, p_ATTRIBUTE4),
              ATTRIBUTE5 = decode( p_ATTRIBUTE5, FND_API.G_MISS_CHAR, ATTRIBUTE5, p_ATTRIBUTE5),
              ATTRIBUTE6 = decode( p_ATTRIBUTE6, FND_API.G_MISS_CHAR, ATTRIBUTE6, p_ATTRIBUTE6),
              ATTRIBUTE7 = decode( p_ATTRIBUTE7, FND_API.G_MISS_CHAR, ATTRIBUTE7, p_ATTRIBUTE7),
              ATTRIBUTE8 = decode( p_ATTRIBUTE8, FND_API.G_MISS_CHAR, ATTRIBUTE8, p_ATTRIBUTE8),
              ATTRIBUTE9 = decode( p_ATTRIBUTE9, FND_API.G_MISS_CHAR, ATTRIBUTE9, p_ATTRIBUTE9),
              ATTRIBUTE10 = decode( p_ATTRIBUTE10, FND_API.G_MISS_CHAR, ATTRIBUTE10, p_ATTRIBUTE10),
              ATTRIBUTE11 = decode( p_ATTRIBUTE11, FND_API.G_MISS_CHAR, ATTRIBUTE11, p_ATTRIBUTE11),
              ATTRIBUTE12 = decode( p_ATTRIBUTE12, FND_API.G_MISS_CHAR, ATTRIBUTE12, p_ATTRIBUTE12),
              ATTRIBUTE13 = decode( p_ATTRIBUTE13, FND_API.G_MISS_CHAR, ATTRIBUTE13, p_ATTRIBUTE13),
              ATTRIBUTE14 = decode( p_ATTRIBUTE14, FND_API.G_MISS_CHAR, ATTRIBUTE14, p_ATTRIBUTE14),
              ATTRIBUTE15 = decode( p_ATTRIBUTE15, FND_API.G_MISS_CHAR, ATTRIBUTE15, p_ATTRIBUTE15),
              REQUEST_ID = decode( p_REQUEST_ID, FND_API.G_MISS_NUM, REQUEST_ID, p_REQUEST_ID),
              PROGRAM_APPLICATION_ID = decode( p_PROGRAM_APPLICATION_ID, FND_API.G_MISS_NUM, PROGRAM_APPLICATION_ID, p_PROGRAM_APPLICATION_ID),
              PROGRAM_ID = decode( p_PROGRAM_ID, FND_API.G_MISS_NUM, PROGRAM_ID, p_PROGRAM_ID),
              PROGRAM_UPDATE_DATE = decode( p_PROGRAM_UPDATE_DATE, FND_API.G_MISS_DATE, PROGRAM_UPDATE_DATE, p_PROGRAM_UPDATE_DATE),
              SUBINVENTORY_CODE = decode( p_SUBINVENTORY_CODE, FND_API.G_MISS_CHAR, SUBINVENTORY_CODE, p_SUBINVENTORY_CODE),
              TRANSACTION_TYPE_ID = decode( p_TRANSACTION_TYPE_ID, FND_API.G_MISS_NUM, TRANSACTION_TYPE_ID, p_TRANSACTION_TYPE_ID)
    where USAGE_ID = p_USAGE_ID;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
END Update_Row;

PROCEDURE Delete_Row(
    p_USAGE_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM CSP_USAGE_HISTORIES
    WHERE USAGE_ID = p_USAGE_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;

PROCEDURE Lock_Row(
          p_USAGE_ID    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_INVENTORY_ITEM_ID    NUMBER,
          p_ORGANIZATION_ID    NUMBER,
          p_HIERARCHY_NODE_ID    NUMBER,
          p_PARTS_LOOP_ID    NUMBER,
          p_PERIOD_TYPE    VARCHAR2,
          p_PERIOD_START_DATE    DATE,
          p_QUANTITY    NUMBER,
		p_HISTORY_DATA_TYPE NUMBER ,
		p_USAGE_HEADER_ID NUMBER ,
          p_ATTRIBUTE_CATEGORY    VARCHAR2,
          p_ATTRIBUTE1    VARCHAR2,
          p_ATTRIBUTE2    VARCHAR2,
          p_ATTRIBUTE3    VARCHAR2,
          p_ATTRIBUTE4    VARCHAR2,
          p_ATTRIBUTE5    VARCHAR2,
          p_ATTRIBUTE6    VARCHAR2,
          p_ATTRIBUTE7    VARCHAR2,
          p_ATTRIBUTE8    VARCHAR2,
          p_ATTRIBUTE9    VARCHAR2,
          p_ATTRIBUTE10    VARCHAR2,
          p_ATTRIBUTE11    VARCHAR2,
          p_ATTRIBUTE12    VARCHAR2,
          p_ATTRIBUTE13    VARCHAR2,
          p_ATTRIBUTE14    VARCHAR2,
          p_ATTRIBUTE15    VARCHAR2,
          p_REQUEST_ID    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_SUBINVENTORY_CODE    VARCHAR2,
          p_TRANSACTION_TYPE_ID    NUMBER)

 IS
   CURSOR C IS
        SELECT *
         FROM CSP_USAGE_HISTORIES
        WHERE USAGE_ID =  p_USAGE_ID
        FOR UPDATE of USAGE_ID NOWAIT;
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
           (      Recinfo.USAGE_ID = p_USAGE_ID)
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
       AND (    ( Recinfo.INVENTORY_ITEM_ID = p_INVENTORY_ITEM_ID)
            OR (    ( Recinfo.INVENTORY_ITEM_ID IS NULL )
                AND (  p_INVENTORY_ITEM_ID IS NULL )))
       AND (    ( Recinfo.ORGANIZATION_ID = p_ORGANIZATION_ID)
            OR (    ( Recinfo.ORGANIZATION_ID IS NULL )
                AND (  p_ORGANIZATION_ID IS NULL )))
       AND (    ( Recinfo.HIERARCHY_NODE_ID = p_HIERARCHY_NODE_ID)
            OR (    ( Recinfo.HIERARCHY_NODE_ID IS NULL )
                AND (  p_HIERARCHY_NODE_ID IS NULL )))
       AND (    ( Recinfo.PARTS_LOOP_ID = p_PARTS_LOOP_ID)
            OR (    ( Recinfo.PARTS_LOOP_ID IS NULL )
                AND (  p_PARTS_LOOP_ID IS NULL )))
       AND (    ( Recinfo.PERIOD_TYPE = p_PERIOD_TYPE)
            OR (    ( Recinfo.PERIOD_TYPE IS NULL )
                AND (  p_PERIOD_TYPE IS NULL )))
       AND (    ( Recinfo.HISTORY_DATA_TYPE = p_HISTORY_DATA_TYPE)
            OR (    ( Recinfo.HISTORY_DATA_TYPE IS NULL )
                AND (  p_HISTORY_DATA_TYPE IS NULL )))
       AND (    ( Recinfo.USAGE_HEADER_ID = p_USAGE_HEADER_ID)
            OR (    ( Recinfo.USAGE_HEADER_ID IS NULL )
                AND (  p_USAGE_HEADER_ID IS NULL )))
       AND (    ( Recinfo.PERIOD_START_DATE = p_PERIOD_START_DATE)
            OR (    ( Recinfo.PERIOD_START_DATE IS NULL )
                AND (  p_PERIOD_START_DATE IS NULL )))
       AND (    ( Recinfo.QUANTITY = p_QUANTITY)
            OR (    ( Recinfo.QUANTITY IS NULL )
                AND (  p_QUANTITY IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE_CATEGORY = p_ATTRIBUTE_CATEGORY)
            OR (    ( Recinfo.ATTRIBUTE_CATEGORY IS NULL )
                AND (  p_ATTRIBUTE_CATEGORY IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE1 = p_ATTRIBUTE1)
            OR (    ( Recinfo.ATTRIBUTE1 IS NULL )
                AND (  p_ATTRIBUTE1 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE2 = p_ATTRIBUTE2)
            OR (    ( Recinfo.ATTRIBUTE2 IS NULL )
                AND (  p_ATTRIBUTE2 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE3 = p_ATTRIBUTE3)
            OR (    ( Recinfo.ATTRIBUTE3 IS NULL )
                AND (  p_ATTRIBUTE3 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE4 = p_ATTRIBUTE4)
            OR (    ( Recinfo.ATTRIBUTE4 IS NULL )
                AND (  p_ATTRIBUTE4 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE5 = p_ATTRIBUTE5)
            OR (    ( Recinfo.ATTRIBUTE5 IS NULL )
                AND (  p_ATTRIBUTE5 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE6 = p_ATTRIBUTE6)
            OR (    ( Recinfo.ATTRIBUTE6 IS NULL )
                AND (  p_ATTRIBUTE6 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE7 = p_ATTRIBUTE7)
            OR (    ( Recinfo.ATTRIBUTE7 IS NULL )
                AND (  p_ATTRIBUTE7 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE8 = p_ATTRIBUTE8)
            OR (    ( Recinfo.ATTRIBUTE8 IS NULL )
                AND (  p_ATTRIBUTE8 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE9 = p_ATTRIBUTE9)
            OR (    ( Recinfo.ATTRIBUTE9 IS NULL )
                AND (  p_ATTRIBUTE9 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE10 = p_ATTRIBUTE10)
            OR (    ( Recinfo.ATTRIBUTE10 IS NULL )
                AND (  p_ATTRIBUTE10 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE11 = p_ATTRIBUTE11)
            OR (    ( Recinfo.ATTRIBUTE11 IS NULL )
                AND (  p_ATTRIBUTE11 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE12 = p_ATTRIBUTE12)
            OR (    ( Recinfo.ATTRIBUTE12 IS NULL )
                AND (  p_ATTRIBUTE12 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE13 = p_ATTRIBUTE13)
            OR (    ( Recinfo.ATTRIBUTE13 IS NULL )
                AND (  p_ATTRIBUTE13 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE14 = p_ATTRIBUTE14)
            OR (    ( Recinfo.ATTRIBUTE14 IS NULL )
                AND (  p_ATTRIBUTE14 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE15 = p_ATTRIBUTE15)
            OR (    ( Recinfo.ATTRIBUTE15 IS NULL )
                AND (  p_ATTRIBUTE15 IS NULL )))
       AND (    ( Recinfo.REQUEST_ID = p_REQUEST_ID)
            OR (    ( Recinfo.REQUEST_ID IS NULL )
                AND (  p_REQUEST_ID IS NULL )))
       AND (    ( Recinfo.PROGRAM_APPLICATION_ID = p_PROGRAM_APPLICATION_ID)
            OR (    ( Recinfo.PROGRAM_APPLICATION_ID IS NULL )
                AND (  p_PROGRAM_APPLICATION_ID IS NULL )))
       AND (    ( Recinfo.PROGRAM_ID = p_PROGRAM_ID)
            OR (    ( Recinfo.PROGRAM_ID IS NULL )
                AND (  p_PROGRAM_ID IS NULL )))
       AND (    ( Recinfo.PROGRAM_UPDATE_DATE = p_PROGRAM_UPDATE_DATE)
            OR (    ( Recinfo.PROGRAM_UPDATE_DATE IS NULL )
                AND (  p_PROGRAM_UPDATE_DATE IS NULL )))
       AND (    ( Recinfo.SUBINVENTORY_CODE = p_SUBINVENTORY_CODE)
            OR (    ( Recinfo.SUBINVENTORY_CODE IS NULL )
                AND (  p_SUBINVENTORY_CODE IS NULL )))
       AND (    ( Recinfo.TRANSACTION_TYPE_ID = p_TRANSACTION_TYPE_ID)
            OR (    ( Recinfo.TRANSACTION_TYPE_ID IS NULL )
                AND (  p_TRANSACTION_TYPE_ID IS NULL )))
       ) then
       return;
   else
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   End If;
END Lock_Row;

End CSP_USAGE_HISTORIES_PKG;

/
