--------------------------------------------------------
--  DDL for Package Body CSP_MSTRSTCK_LISTS_ITMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_MSTRSTCK_LISTS_ITMS_PKG" as
/* $Header: csptpstb.pls 115.4 2002/11/26 06:40:02 hhaugeru ship $ */
-- Start of Comments
-- Package name     : CSP_MSTRSTCK_LISTS_ITMS_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSP_MSTRSTCK_LISTS_ITMS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csptstcb.pls';

PROCEDURE Insert_Row(
          px_MSL_ID   IN OUT NOCOPY NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_LOGIN    NUMBER,
          p_PARTS_LOOPS_ID    NUMBER,
          p_PLANNER_CODE    VARCHAR2,
          p_INVENTORY_ITEM_ID    NUMBER,
          p_ORGANIZATION_ID    NUMBER,
          p_TOTAL_LOOP_QUANTITY    NUMBER,
          p_TOTAL_LOOP_MIN_GOOD_QUANTITY    NUMBER,
          p_PLANNING_TYPE_CODE    NUMBER,
          p_ATTRIBUTE_CATEGORY    VARCHAR2,
          p_REVISION    VARCHAR2,
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
   CURSOR C2 IS SELECT CSP_MSTRSTCK_LISTS_ITMS_S1.nextval FROM sys.dual;
BEGIN
   If (px_MSL_ID IS NULL) OR (px_MSL_ID = FND_API.G_MISS_NUM) then
       OPEN C2;
       FETCH C2 INTO px_MSL_ID;
       CLOSE C2;
   End If;
   INSERT INTO CSP_MSTRSTCK_LISTS_ITMS(
           MSL_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATED_LOGIN,
           PARTS_LOOPS_ID,
           PLANNER_CODE,
           INVENTORY_ITEM_ID,
           ORGANIZATION_ID,
           TOTAL_LOOP_QUANTITY,
           TOTAL_LOOP_MIN_GOOD_QUANTITY,
           PLANNING_TYPE_CODE,
           ATTRIBUTE_CATEGORY,
           REVISION,
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
           px_MSL_ID,
           decode( p_CREATED_BY, FND_API.G_MISS_NUM, NULL, p_CREATED_BY),
           decode(p_CREATION_DATE, fnd_api.g_miss_date,to_date(null),p_creation_date),
           decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATED_BY),
           decode(p_LAST_UPDATE_DATE, fnd_api.g_miss_date,to_date(null),p_last_update_date),
           decode( p_LAST_UPDATED_LOGIN, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATED_LOGIN),
           decode( p_PARTS_LOOPS_ID, FND_API.G_MISS_NUM, NULL, p_PARTS_LOOPS_ID),
           decode( p_PLANNER_CODE, FND_API.G_MISS_CHAR, NULL, p_PLANNER_CODE),
           decode( p_INVENTORY_ITEM_ID, FND_API.G_MISS_NUM, NULL, p_INVENTORY_ITEM_ID),
           decode( p_ORGANIZATION_ID, FND_API.G_MISS_NUM, NULL, p_ORGANIZATION_ID),
           decode( p_TOTAL_LOOP_QUANTITY, FND_API.G_MISS_NUM, NULL, p_TOTAL_LOOP_QUANTITY),
           decode( p_TOTAL_LOOP_MIN_GOOD_QUANTITY, FND_API.G_MISS_NUM, NULL, p_TOTAL_LOOP_MIN_GOOD_QUANTITY),
           decode( p_PLANNING_TYPE_CODE, FND_API.G_MISS_NUM, NULL, p_PLANNING_TYPE_CODE),
           decode( p_ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE_CATEGORY),
           decode( p_REVISION, FND_API.G_MISS_CHAR, NULL, p_REVISION),
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
End Insert_Row;

PROCEDURE Update_Row(
          p_MSL_ID    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_LOGIN    NUMBER,
          p_PARTS_LOOPS_ID    NUMBER,
          p_PLANNER_CODE    VARCHAR2,
          p_INVENTORY_ITEM_ID    NUMBER,
          p_ORGANIZATION_ID    NUMBER,
          p_TOTAL_LOOP_QUANTITY    NUMBER,
          p_TOTAL_LOOP_MIN_GOOD_QUANTITY    NUMBER,
          p_PLANNING_TYPE_CODE    NUMBER,
          p_ATTRIBUTE_CATEGORY    VARCHAR2,
          p_REVISION    VARCHAR2,
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
    Update CSP_MSTRSTCK_LISTS_ITMS
    SET
              CREATED_BY = decode( p_CREATED_BY, FND_API.G_MISS_NUM, CREATED_BY, p_CREATED_BY),
              CREATION_DATE = decode(p_CREATION_DATE, fnd_api.g_miss_date,creation_date,p_creation_date),
              LAST_UPDATED_BY = decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, LAST_UPDATED_BY, p_LAST_UPDATED_BY),
              LAST_UPDATE_DATE = decode(p_LAST_UPDATE_DATE,fnd_api.g_miss_date,last_update_date,p_last_update_date),
              LAST_UPDATED_LOGIN = decode( p_LAST_UPDATED_LOGIN, FND_API.G_MISS_NUM, LAST_UPDATED_LOGIN, p_LAST_UPDATED_LOGIN),
              PARTS_LOOPS_ID = decode( p_PARTS_LOOPS_ID, FND_API.G_MISS_NUM, PARTS_LOOPS_ID, p_PARTS_LOOPS_ID),
              PLANNER_CODE = decode( p_PLANNER_CODE, FND_API.G_MISS_CHAR, PLANNER_CODE, p_PLANNER_CODE),
              INVENTORY_ITEM_ID = decode( p_INVENTORY_ITEM_ID, FND_API.G_MISS_NUM, INVENTORY_ITEM_ID, p_INVENTORY_ITEM_ID),
              ORGANIZATION_ID = decode( p_ORGANIZATION_ID, FND_API.G_MISS_NUM, ORGANIZATION_ID, p_ORGANIZATION_ID),
              TOTAL_LOOP_QUANTITY = decode( p_TOTAL_LOOP_QUANTITY, FND_API.G_MISS_NUM, TOTAL_LOOP_QUANTITY, p_TOTAL_LOOP_QUANTITY),
              TOTAL_LOOP_MIN_GOOD_QUANTITY = decode( p_TOTAL_LOOP_MIN_GOOD_QUANTITY, FND_API.G_MISS_NUM, TOTAL_LOOP_MIN_GOOD_QUANTITY, p_TOTAL_LOOP_MIN_GOOD_QUANTITY),
              PLANNING_TYPE_CODE = decode( p_PLANNING_TYPE_CODE, FND_API.G_MISS_NUM, PLANNING_TYPE_CODE, p_PLANNING_TYPE_CODE),
              ATTRIBUTE_CATEGORY = decode( p_ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR, ATTRIBUTE_CATEGORY, p_ATTRIBUTE_CATEGORY),
              REVISION = decode( p_REVISION, FND_API.G_MISS_CHAR, REVISION, p_REVISION),
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
    where MSL_ID = p_MSL_ID;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
END Update_Row;

PROCEDURE Delete_Row(
    p_MSL_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM CSP_MSTRSTCK_LISTS_ITMS
    WHERE MSL_ID = p_MSL_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;

PROCEDURE Lock_Row(
          p_MSL_ID    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_LOGIN    NUMBER,
          p_PARTS_LOOPS_ID    NUMBER,
          p_PLANNER_CODE    VARCHAR2,
          p_INVENTORY_ITEM_ID    NUMBER,
          p_ORGANIZATION_ID    NUMBER,
          p_TOTAL_LOOP_QUANTITY    NUMBER,
          p_TOTAL_LOOP_MIN_GOOD_QUANTITY    NUMBER,
          p_PLANNING_TYPE_CODE    NUMBER,
          p_ATTRIBUTE_CATEGORY    VARCHAR2,
          p_REVISION    VARCHAR2,
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
         FROM CSP_MSTRSTCK_LISTS_ITMS
        WHERE MSL_ID =  p_MSL_ID
        FOR UPDATE of MSL_ID NOWAIT;
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
           (      Recinfo.MSL_ID = p_MSL_ID)
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
       AND (    ( Recinfo.LAST_UPDATED_LOGIN = p_LAST_UPDATED_LOGIN)
            OR (    ( Recinfo.LAST_UPDATED_LOGIN IS NULL )
                AND (  p_LAST_UPDATED_LOGIN IS NULL )))
       AND (    ( Recinfo.PARTS_LOOPS_ID = p_PARTS_LOOPS_ID)
            OR (    ( Recinfo.PARTS_LOOPS_ID IS NULL )
                AND (  p_PARTS_LOOPS_ID IS NULL )))
       AND (    ( Recinfo.PLANNER_CODE = p_PLANNER_CODE)
            OR (    ( Recinfo.PLANNER_CODE IS NULL )
                AND (  p_PLANNER_CODE IS NULL )))
       AND (    ( Recinfo.INVENTORY_ITEM_ID = p_INVENTORY_ITEM_ID)
            OR (    ( Recinfo.INVENTORY_ITEM_ID IS NULL )
                AND (  p_INVENTORY_ITEM_ID IS NULL )))
       AND (    ( Recinfo.ORGANIZATION_ID = p_ORGANIZATION_ID)
            OR (    ( Recinfo.ORGANIZATION_ID IS NULL )
                AND (  p_ORGANIZATION_ID IS NULL )))
       AND (    ( Recinfo.TOTAL_LOOP_QUANTITY = p_TOTAL_LOOP_QUANTITY)
            OR (    ( Recinfo.TOTAL_LOOP_QUANTITY IS NULL )
                AND (  p_TOTAL_LOOP_QUANTITY IS NULL )))
       AND (    ( Recinfo.TOTAL_LOOP_MIN_GOOD_QUANTITY = p_TOTAL_LOOP_MIN_GOOD_QUANTITY)
            OR (    ( Recinfo.TOTAL_LOOP_MIN_GOOD_QUANTITY IS NULL )
                AND (  p_TOTAL_LOOP_MIN_GOOD_QUANTITY IS NULL )))
       AND (    ( Recinfo.PLANNING_TYPE_CODE = p_PLANNING_TYPE_CODE)
            OR (    ( Recinfo.PLANNING_TYPE_CODE IS NULL )
                AND (  p_PLANNING_TYPE_CODE IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE_CATEGORY = p_ATTRIBUTE_CATEGORY)
            OR (    ( Recinfo.ATTRIBUTE_CATEGORY IS NULL )
                AND (  p_ATTRIBUTE_CATEGORY IS NULL )))
       AND (    ( Recinfo.REVISION = p_REVISION)
            OR (    ( Recinfo.REVISION IS NULL )
                AND (  p_REVISION IS NULL )))
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

End CSP_MSTRSTCK_LISTS_ITMS_PKG;

/
