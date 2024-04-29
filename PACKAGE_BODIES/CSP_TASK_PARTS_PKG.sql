--------------------------------------------------------
--  DDL for Package Body CSP_TASK_PARTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_TASK_PARTS_PKG" as
/* $Header: cspttapb.pls 115.3 2002/11/26 07:42:33 hhaugeru noship $ */
-- Start of Comments
-- Package name     : CSP_TASK_PARTS_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments
G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSP_TASK_PARTS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'cspttapb.pls';
PROCEDURE Insert_Row(
          px_TASK_PART_ID   IN OUT NOCOPY NUMBER,
          p_PRODUCT_TASK_ID    NUMBER,
          p_INVENTORY_ITEM_ID    NUMBER,
          p_MANUAL_QUANTITY    NUMBER,
          p_MANUAL_PERCENTAGE    NUMBER,
          p_QUANTITY_USED    NUMBER,
          p_ACTUAL_TIMES_USED    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
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
          p_PRIMARY_UOM_CODE    VARCHAR2,
          p_REVISION    VARCHAR2,
          p_START_DATE    DATE,
          p_END_DATE    DATE,
          P_ROLLUP_QUANTITY_USED NUMBER,
          P_ROLLUP_TIMES_USED NUMBER,
          P_SUBSTITUTE_ITEM NUMBER)
 IS
   CURSOR C2 IS SELECT CSP_TASK_PARTS_S1.nextval FROM sys.dual;
BEGIN
   If (px_TASK_PART_ID IS NULL) OR (px_TASK_PART_ID = FND_API.G_MISS_NUM) then
       OPEN C2;
       FETCH C2 INTO px_TASK_PART_ID;
       CLOSE C2;
   End If;
   INSERT INTO CSP_TASK_PARTS(
           TASK_PART_ID,
           PRODUCT_TASK_ID,
           INVENTORY_ITEM_ID,
           MANUAL_QUANTITY,
           MANUAL_PERCENTAGE,
           QUANTITY_USED,
           ACTUAL_TIMES_USED,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
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
           PRIMARY_UOM_CODE,
           REVISION,
           START_DATE,
           END_DATE,
           ROLLUP_QUANTITY_USED,
           ROLLUP_TIMES_USED,
           SUBSTITUTE_ITEM
          ) VALUES (
           px_TASK_PART_ID,
           decode( p_PRODUCT_TASK_ID, FND_API.G_MISS_NUM, NULL, p_PRODUCT_TASK_ID),
           decode( p_INVENTORY_ITEM_ID, FND_API.G_MISS_NUM, NULL, p_INVENTORY_ITEM_ID),
           decode( p_MANUAL_QUANTITY, FND_API.G_MISS_NUM, NULL, p_MANUAL_QUANTITY),
           decode( p_MANUAL_PERCENTAGE, FND_API.G_MISS_NUM, NULL, p_MANUAL_PERCENTAGE),
           decode( p_QUANTITY_USED, FND_API.G_MISS_NUM, NULL, p_QUANTITY_USED),
           decode( p_ACTUAL_TIMES_USED, FND_API.G_MISS_NUM, NULL, p_ACTUAL_TIMES_USED),
           decode( p_CREATED_BY, FND_API.G_MISS_NUM, NULL, p_CREATED_BY),
           decode( p_CREATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_CREATION_DATE),
           decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATED_BY),
           decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_LAST_UPDATE_DATE),
           decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATE_LOGIN),
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
           decode( p_PRIMARY_UOM_CODE, FND_API.G_MISS_CHAR, NULL, p_PRIMARY_UOM_CODE),
           decode( p_REVISION, FND_API.G_MISS_CHAR, NULL, p_REVISION),
           decode( p_START_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_START_DATE),
           decode( p_END_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_END_DATE),
           decode( P_ROLLUP_QUANTITY_USED, FND_API.G_MISS_NUM, NULL, P_ROLLUP_QUANTITY_USED),
           decode( P_ROLLUP_TIMES_USED, FND_API.G_MISS_NUM, NULL, P_ROLLUP_TIMES_USED),
           decode( P_SUBSTITUTE_ITEM, FND_API.G_MISS_NUM, NULL, P_SUBSTITUTE_ITEM)
           );
End Insert_Row;
PROCEDURE Update_Row(
          p_TASK_PART_ID    NUMBER,
          p_PRODUCT_TASK_ID    NUMBER,
          p_INVENTORY_ITEM_ID    NUMBER,
          p_MANUAL_QUANTITY    NUMBER,
          p_MANUAL_PERCENTAGE    NUMBER,
          p_QUANTITY_USED    NUMBER,
          p_ACTUAL_TIMES_USED    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
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
          p_PRIMARY_UOM_CODE    VARCHAR2,
          p_REVISION    VARCHAR2,
          p_START_DATE    DATE,
          p_END_DATE    DATE,
          P_ROLLUP_QUANTITY_USED NUMBER,
          P_ROLLUP_TIMES_USED NUMBER,
          P_SUBSTITUTE_ITEM NUMBER)
 IS
 BEGIN
    Update CSP_TASK_PARTS
    SET
              PRODUCT_TASK_ID = decode( p_PRODUCT_TASK_ID, FND_API.G_MISS_NUM, PRODUCT_TASK_ID, p_PRODUCT_TASK_ID),
              INVENTORY_ITEM_ID = decode( p_INVENTORY_ITEM_ID, FND_API.G_MISS_NUM, INVENTORY_ITEM_ID, p_INVENTORY_ITEM_ID),
              MANUAL_QUANTITY = decode( p_MANUAL_QUANTITY, FND_API.G_MISS_NUM, MANUAL_QUANTITY, p_MANUAL_QUANTITY),
              MANUAL_PERCENTAGE = decode( p_MANUAL_PERCENTAGE, FND_API.G_MISS_NUM, MANUAL_PERCENTAGE, p_MANUAL_PERCENTAGE),
              QUANTITY_USED = decode( p_QUANTITY_USED, FND_API.G_MISS_NUM, QUANTITY_USED, p_QUANTITY_USED),
              ACTUAL_TIMES_USED = decode( p_ACTUAL_TIMES_USED, FND_API.G_MISS_NUM, ACTUAL_TIMES_USED, p_ACTUAL_TIMES_USED),
              CREATED_BY = decode( p_CREATED_BY, FND_API.G_MISS_NUM, CREATED_BY, p_CREATED_BY),
              CREATION_DATE = decode( p_CREATION_DATE, FND_API.G_MISS_DATE, CREATION_DATE, p_CREATION_DATE),
              LAST_UPDATED_BY = decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, LAST_UPDATED_BY, p_LAST_UPDATED_BY),
              LAST_UPDATE_DATE = decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, LAST_UPDATE_DATE, p_LAST_UPDATE_DATE),
              LAST_UPDATE_LOGIN = decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, LAST_UPDATE_LOGIN, p_LAST_UPDATE_LOGIN),
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
              PRIMARY_UOM_CODE = decode( p_PRIMARY_UOM_CODE, FND_API.G_MISS_CHAR, PRIMARY_UOM_CODE, p_PRIMARY_UOM_CODE),
              REVISION = decode( p_REVISION, FND_API.G_MISS_CHAR, REVISION, p_REVISION),
              START_DATE = decode( p_START_DATE, FND_API.G_MISS_DATE, START_DATE, p_START_DATE),
              END_DATE = decode( p_END_DATE, FND_API.G_MISS_DATE, END_DATE, p_END_DATE),
              ROLLUP_QUANTITY_USED = decode( P_ROLLUP_QUANTITY_USED, FND_API.G_MISS_NUM, INVENTORY_ITEM_ID, P_ROLLUP_QUANTITY_USED),
              ROLLUP_TIMES_USED = decode( P_ROLLUP_TIMES_USED, FND_API.G_MISS_NUM, ROLLUP_TIMES_USED, P_ROLLUP_TIMES_USED),
              SUBSTITUTE_ITEM = decode( P_SUBSTITUTE_ITEM, FND_API.G_MISS_NUM, SUBSTITUTE_ITEM, P_SUBSTITUTE_ITEM)
      where TASK_PART_ID = p_TASK_PART_ID;
    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
END Update_Row;
PROCEDURE Delete_Row(
    p_TASK_PART_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM CSP_TASK_PARTS
    WHERE TASK_PART_ID = p_TASK_PART_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;
PROCEDURE Lock_Row(
          p_TASK_PART_ID    NUMBER,
          p_PRODUCT_TASK_ID    NUMBER,
          p_INVENTORY_ITEM_ID    NUMBER,
          p_MANUAL_QUANTITY    NUMBER,
          p_MANUAL_PERCENTAGE    NUMBER,
          p_QUANTITY_USED    NUMBER,
          p_ACTUAL_TIMES_USED    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
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
          p_PRIMARY_UOM_CODE    VARCHAR2,
          p_REVISION    VARCHAR2,
          p_START_DATE    DATE,
          p_END_DATE    DATE,
          P_ROLLUP_QUANTITY_USED NUMBER,
          P_ROLLUP_TIMES_USED NUMBER,
          P_SUBSTITUTE_ITEM NUMBER)
 IS
   CURSOR C IS
        SELECT *
         FROM CSP_TASK_PARTS
        WHERE TASK_PART_ID =  p_TASK_PART_ID
        FOR UPDATE of TASK_PART_ID NOWAIT;
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
           (      Recinfo.TASK_PART_ID = p_TASK_PART_ID)
       AND (    ( Recinfo.PRODUCT_TASK_ID = p_PRODUCT_TASK_ID)
            OR (    ( Recinfo.PRODUCT_TASK_ID IS NULL )
                AND (  p_PRODUCT_TASK_ID IS NULL )))
       AND (    ( Recinfo.INVENTORY_ITEM_ID = p_INVENTORY_ITEM_ID)
            OR (    ( Recinfo.INVENTORY_ITEM_ID IS NULL )
                AND (  p_INVENTORY_ITEM_ID IS NULL )))
       AND (    ( Recinfo.MANUAL_QUANTITY = p_MANUAL_QUANTITY)
            OR (    ( Recinfo.MANUAL_QUANTITY IS NULL )
                AND (  p_MANUAL_QUANTITY IS NULL )))
       AND (    ( Recinfo.MANUAL_PERCENTAGE = p_MANUAL_PERCENTAGE)
            OR (    ( Recinfo.MANUAL_PERCENTAGE IS NULL )
                AND (  p_MANUAL_PERCENTAGE IS NULL )))
       AND (    ( Recinfo.QUANTITY_USED = p_QUANTITY_USED)
            OR (    ( Recinfo.QUANTITY_USED IS NULL )
                AND (  p_QUANTITY_USED IS NULL )))
       AND (    ( Recinfo.ACTUAL_TIMES_USED = p_ACTUAL_TIMES_USED)
            OR (    ( Recinfo.ACTUAL_TIMES_USED IS NULL )
                AND (  p_ACTUAL_TIMES_USED IS NULL )))
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
       AND (    ( Recinfo.PRIMARY_UOM_CODE = p_PRIMARY_UOM_CODE)
            OR (    ( Recinfo.PRIMARY_UOM_CODE IS NULL )
                AND (  p_PRIMARY_UOM_CODE IS NULL )))
       AND (    ( Recinfo.REVISION = p_REVISION)
            OR (    ( Recinfo.REVISION IS NULL )
                AND (  p_REVISION IS NULL )))
       AND (    ( Recinfo.START_DATE = p_START_DATE)
            OR (    ( Recinfo.START_DATE IS NULL )
                AND (  p_START_DATE IS NULL )))
       AND (    ( Recinfo.END_DATE = p_END_DATE)
            OR (    ( Recinfo.END_DATE IS NULL )
                AND (  p_END_DATE IS NULL )))
       AND (    ( Recinfo.ROLLUP_QUANTITY_USED = p_ROLLUP_QUANTITY_USED)
            OR (    ( Recinfo.ROLLUP_QUANTITY_USED IS NULL )
                AND (  p_ROLLUP_QUANTITY_USED IS NULL )))
       AND (    ( Recinfo.ROLLUP_TIMES_USED = p_ROLLUP_TIMES_USED)
            OR (    ( Recinfo.ROLLUP_TIMES_USED IS NULL )
                AND (  p_ROLLUP_TIMES_USED IS NULL )))
       AND (    ( Recinfo.SUBSTITUTE_ITEM = P_SUBSTITUTE_ITEM)
            OR (    ( Recinfo.SUBSTITUTE_ITEM IS NULL )
                AND (  P_SUBSTITUTE_ITEM IS NULL )))
       ) then
       return;
   else
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   End If;
END Lock_Row;
End CSP_TASK_PARTS_PKG;

/
