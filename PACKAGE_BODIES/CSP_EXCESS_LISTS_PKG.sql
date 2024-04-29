--------------------------------------------------------
--  DDL for Package Body CSP_EXCESS_LISTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_EXCESS_LISTS_PKG" as
/* $Header: csptexcb.pls 120.0.12010000.2 2009/05/14 13:13:48 htank ship $ */
-- Start of Comments
-- Package name     : CSP_EXCESS_LISTS_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments
G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSP_EXCESS_LISTS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csptexcb.pls';
PROCEDURE Insert_Row(
          px_EXCESS_LINE_ID   IN OUT NOCOPY NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_ORGANIZATION_ID    NUMBER,
          p_SUBINVENTORY_CODE    VARCHAR2,
          p_CONDITION_CODE    VARCHAR2,
          p_INVENTORY_ITEM_ID    NUMBER,
          p_EXCESS_QUANTITY    NUMBER,
          p_REQUISITION_LINE_ID    NUMBER,
          p_RETURNED_QUANTITY    NUMBER,
          p_CURRENT_RETURN_QTY    NUMBER,
          p_EXCESS_STATUS   VARCHAR2,
          p_RETURN_ORG_ID NUMBER  :=  FND_API.G_MISS_NUM,
          p_RETURN_SUB_INV  VARCHAR2  :=  FND_API.G_MISS_CHAR,
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
          p_ATTRIBUTE15    VARCHAR2)
 IS
   CURSOR C2 IS SELECT CSP_EXCESS_LISTS_S1.nextval FROM sys.dual;
BEGIN

      if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                    'csp.plsql.CSP_EXCESS_LISTS_PKG.Insert_Row',
                    'Begin...');
      end if;

   If (px_EXCESS_LINE_ID IS NULL) OR (px_EXCESS_LINE_ID = FND_API.G_MISS_NUM) then
       OPEN C2;
       FETCH C2 INTO px_EXCESS_LINE_ID;
       CLOSE C2;
   End If;

  if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                'csp.plsql.CSP_EXCESS_LISTS_PKG.Insert_Row',
                'px_EXCESS_LINE_ID = ' || px_EXCESS_LINE_ID);
  end if;

   INSERT INTO CSP_EXCESS_LISTS(
           EXCESS_LINE_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           ORGANIZATION_ID,
           SUBINVENTORY_CODE,
           CONDITION_CODE,
           INVENTORY_ITEM_ID,
           EXCESS_QUANTITY,
           REQUISITION_LINE_ID,
           RETURNED_QUANTITY,
           CURRENT_RETURN_QTY,
           EXCESS_STATUS,
           return_organization_id,
           return_subinventory_name,
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
           ATTRIBUTE15
          ) VALUES (
           px_EXCESS_LINE_ID,
           decode( p_CREATED_BY, FND_API.G_MISS_NUM, NULL, p_CREATED_BY),
           decode( p_CREATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_CREATION_DATE),
           decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATED_BY),
           decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_LAST_UPDATE_DATE),
           decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATE_LOGIN),
           decode( p_ORGANIZATION_ID, FND_API.G_MISS_NUM, NULL, p_ORGANIZATION_ID),
           decode( p_SUBINVENTORY_CODE, FND_API.G_MISS_CHAR, NULL, p_SUBINVENTORY_CODE),
           decode( p_CONDITION_CODE, FND_API.G_MISS_CHAR, NULL, p_CONDITION_CODE),
           decode( p_INVENTORY_ITEM_ID, FND_API.G_MISS_NUM, NULL, p_INVENTORY_ITEM_ID),
           decode( p_EXCESS_QUANTITY, FND_API.G_MISS_NUM, NULL, p_EXCESS_QUANTITY),
           decode( p_REQUISITION_LINE_ID, FND_API.G_MISS_NUM, NULL, p_REQUISITION_LINE_ID),
           decode( p_RETURNED_QUANTITY, FND_API.G_MISS_NUM, NULL, p_RETURNED_QUANTITY),
           decode( p_CURRENT_RETURN_QTY, FND_API.G_MISS_NUM, NULL, p_CURRENT_RETURN_QTY),
           decode( p_EXCESS_STATUS, FND_API.G_MISS_CHAR, NULL, p_EXCESS_STATUS),

           decode( p_RETURN_ORG_ID, FND_API.G_MISS_NUM, NULL, p_RETURN_ORG_ID),
           decode( p_RETURN_SUB_INV, FND_API.G_MISS_CHAR, NULL, p_RETURN_SUB_INV),

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
           decode( p_ATTRIBUTE15, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE15));

  if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                'csp.plsql.CSP_EXCESS_LISTS_PKG.Insert_Row',
                'Record inserted...');
  end if;

End Insert_Row;
PROCEDURE Update_Row(
          p_EXCESS_LINE_ID    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_ORGANIZATION_ID    NUMBER,
          p_SUBINVENTORY_CODE    VARCHAR2,
          p_CONDITION_CODE    VARCHAR2,
          p_INVENTORY_ITEM_ID    NUMBER,
          p_EXCESS_QUANTITY    NUMBER,
          p_REQUISITION_LINE_ID    NUMBER,
          p_RETURNED_QUANTITY    NUMBER,
          p_CURRENT_RETURN_QTY   NUMBER,
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
          p_ATTRIBUTE15    VARCHAR2)
 IS
 BEGIN
    Update CSP_EXCESS_LISTS
    SET
              CREATED_BY = decode( p_CREATED_BY, FND_API.G_MISS_NUM, CREATED_BY, p_CREATED_BY),
              CREATION_DATE = decode( p_CREATION_DATE, FND_API.G_MISS_DATE, CREATION_DATE, p_CREATION_DATE),
              LAST_UPDATED_BY = decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, LAST_UPDATED_BY, p_LAST_UPDATED_BY),
              LAST_UPDATE_DATE = decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, LAST_UPDATE_DATE, p_LAST_UPDATE_DATE),
              LAST_UPDATE_LOGIN = decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, LAST_UPDATE_LOGIN, p_LAST_UPDATE_LOGIN),
              ORGANIZATION_ID = decode( p_ORGANIZATION_ID, FND_API.G_MISS_NUM, ORGANIZATION_ID, p_ORGANIZATION_ID),
              SUBINVENTORY_CODE = decode( p_SUBINVENTORY_CODE, FND_API.G_MISS_CHAR, SUBINVENTORY_CODE, p_SUBINVENTORY_CODE),
              CONDITION_CODE = decode( p_CONDITION_CODE, FND_API.G_MISS_CHAR, CONDITION_CODE, p_CONDITION_CODE),
              INVENTORY_ITEM_ID = decode( p_INVENTORY_ITEM_ID, FND_API.G_MISS_NUM, INVENTORY_ITEM_ID, p_INVENTORY_ITEM_ID),
              EXCESS_QUANTITY = decode( p_EXCESS_QUANTITY, FND_API.G_MISS_NUM, EXCESS_QUANTITY, p_EXCESS_QUANTITY),
              REQUISITION_LINE_ID = decode( p_REQUISITION_LINE_ID, FND_API.G_MISS_NUM, REQUISITION_LINE_ID, p_REQUISITION_LINE_ID),
              RETURNED_QUANTITY = decode( p_RETURNED_QUANTITY, FND_API.G_MISS_NUM, RETURNED_QUANTITY, p_RETURNED_QUANTITY),
              CURRENT_RETURN_QTY = decode( p_CURRENT_RETURN_QTY, FND_API.G_MISS_NUM, CURRENT_RETURN_QTY, p_CURRENT_RETURN_QTY),
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
              ATTRIBUTE15 = decode( p_ATTRIBUTE15, FND_API.G_MISS_CHAR, ATTRIBUTE15, p_ATTRIBUTE15)
    where EXCESS_LINE_ID = p_EXCESS_LINE_ID;
    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
END Update_Row;
PROCEDURE Delete_Row(
    p_EXCESS_LINE_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM CSP_EXCESS_LISTS
    WHERE EXCESS_LINE_ID = p_EXCESS_LINE_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;
PROCEDURE Lock_Row(
          p_EXCESS_LINE_ID    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_ORGANIZATION_ID    NUMBER,
          p_SUBINVENTORY_CODE    VARCHAR2,
          p_CONDITION_CODE    VARCHAR2,
          p_INVENTORY_ITEM_ID    NUMBER,
          p_EXCESS_QUANTITY    NUMBER,
          p_REQUISITION_LINE_ID    NUMBER,
          p_RETURNED_QUANTITY    NUMBER,
          p_CURRENT_RETURN_QTY   NUMBER,
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
          p_ATTRIBUTE15    VARCHAR2)
 IS
   CURSOR C IS
        SELECT *
         FROM CSP_EXCESS_LISTS
        WHERE EXCESS_LINE_ID =  p_EXCESS_LINE_ID
        FOR UPDATE of EXCESS_LINE_ID NOWAIT;
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
           (      Recinfo.EXCESS_LINE_ID = p_EXCESS_LINE_ID)
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
       AND (    ( Recinfo.ORGANIZATION_ID = p_ORGANIZATION_ID)
            OR (    ( Recinfo.ORGANIZATION_ID IS NULL )
                AND (  p_ORGANIZATION_ID IS NULL )))
       AND (    ( Recinfo.SUBINVENTORY_CODE = p_SUBINVENTORY_CODE)
            OR (    ( Recinfo.SUBINVENTORY_CODE IS NULL )
                AND (  p_SUBINVENTORY_CODE IS NULL )))
       AND (    ( Recinfo.CONDITION_CODE = p_CONDITION_CODE)
            OR (    ( Recinfo.CONDITION_CODE IS NULL )
                AND (  p_CONDITION_CODE IS NULL )))
       AND (    ( Recinfo.INVENTORY_ITEM_ID = p_INVENTORY_ITEM_ID)
            OR (    ( Recinfo.INVENTORY_ITEM_ID IS NULL )
                AND (  p_INVENTORY_ITEM_ID IS NULL )))
       AND (    ( Recinfo.EXCESS_QUANTITY = p_EXCESS_QUANTITY)
            OR (    ( Recinfo.EXCESS_QUANTITY IS NULL )
                AND (  p_EXCESS_QUANTITY IS NULL )))
       AND (    ( Recinfo.REQUISITION_LINE_ID = p_REQUISITION_LINE_ID)
            OR (    ( Recinfo.REQUISITION_LINE_ID IS NULL )
                AND (  p_REQUISITION_LINE_ID IS NULL )))
       AND (    ( Recinfo.RETURNED_QUANTITY = p_RETURNED_QUANTITY)
            OR (    ( Recinfo.RETURNED_QUANTITY IS NULL )
                AND (  p_RETURNED_QUANTITY IS NULL )))
       AND (    ( Recinfo.CURRENT_RETURN_QTY = p_CURRENT_RETURN_QTY)
            OR (    ( Recinfo.CURRENT_RETURN_QTY IS NULL )
                AND (  p_CURRENT_RETURN_QTY IS NULL )))
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
       ) then
       return;
   else
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   End If;
END Lock_Row;
End CSP_EXCESS_LISTS_PKG;

/
