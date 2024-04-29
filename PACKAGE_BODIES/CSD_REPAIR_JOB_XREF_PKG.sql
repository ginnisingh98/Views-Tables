--------------------------------------------------------
--  DDL for Package Body CSD_REPAIR_JOB_XREF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_REPAIR_JOB_XREF_PKG" as
/* $Header: csdtdrjb.pls 115.12 2003/09/15 21:32:59 sragunat ship $ */
-- Start of Comments
-- Package name     : CSD_REPAIR_JOB_XREF_PKG
-- Purpose          :
-- History          : Added Columns Inventory_Item_ID and Item_Revision -- travi
-- History          : 01/17/2002, TRAVI added column OBJECT_VERSION_NUMBER
-- History          : 08/20/2003, Shiv Ragunathan, 11.5.10 Changes: Added parameters
-- History          :   p_source_type_code, p_source_id1, p_ro_service_code_id, p_job_name
-- History          :   to Insert_row procedure.
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSD_REPAIR_JOB_XREF_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csdtrjxb.pls';
l_debug        NUMBER := csd_gen_utility_pvt.g_debug_level;

PROCEDURE Insert_Row(
          px_REPAIR_JOB_XREF_ID   IN OUT NOCOPY NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_REPAIR_LINE_ID    NUMBER,
          p_WIP_ENTITY_ID    NUMBER,
          p_GROUP_ID    NUMBER,
          p_ORGANIZATION_ID    NUMBER,
          p_QUANTITY    NUMBER,
        p_INVENTORY_ITEM_ID  NUMBER,
        p_ITEM_REVISION      VARCHAR2,
          p_SOURCE_TYPE_CODE 		VARCHAR2,
          p_SOURCE_ID1       		NUMBER,
          p_RO_SERVICE_CODE_ID  	NUMBER,
          p_JOB_NAME     		VARCHAR2,
        p_OBJECT_VERSION_NUMBER  	NUMBER,
          p_ATTRIBUTE_CATEGORY    	VARCHAR2,
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
        P_QUANTITY_COMPLETED NUMBER)

 IS
   CURSOR C2 IS SELECT CSD_REPAIR_JOB_XREF_S1.nextval FROM sys.dual;
BEGIN
   If (px_REPAIR_JOB_XREF_ID IS NULL) OR (px_REPAIR_JOB_XREF_ID = FND_API.G_MISS_NUM) then
       OPEN C2;
       FETCH C2 INTO px_REPAIR_JOB_XREF_ID;
       CLOSE C2;
   End If;

   IF l_debug > 0 THEN
     csd_gen_utility_pvt.add('CSD_REPAIR_JOB_XREF_PKG.Insert_Row OVN : '||to_char(p_OBJECT_VERSION_NUMBER));
   END IF;

   INSERT INTO CSD_REPAIR_JOB_XREF(
           REPAIR_JOB_XREF_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           REPAIR_LINE_ID,
           WIP_ENTITY_ID,
           GROUP_ID,
           ORGANIZATION_ID,
           QUANTITY,
         INVENTORY_ITEM_ID,
         ITEM_REVISION,
         SOURCE_TYPE_CODE,
          SOURCE_ID1       ,
          RO_SERVICE_CODE_ID ,
          JOB_NAME,
         OBJECT_VERSION_NUMBER,
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
         QUANTITY_COMPLETED
          ) VALUES (
           px_REPAIR_JOB_XREF_ID,
           decode( p_CREATED_BY, FND_API.G_MISS_NUM, NULL, p_CREATED_BY),
           decode( p_CREATION_DATE, fnd_api.g_miss_date, to_date(null), p_CREATION_DATE),
           decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATED_BY),
           decode( p_LAST_UPDATE_DATE, fnd_api.g_miss_date, to_date(null), p_LAST_UPDATE_DATE),
           decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATE_LOGIN),
           decode( p_REPAIR_LINE_ID, FND_API.G_MISS_NUM, NULL, p_REPAIR_LINE_ID),
           decode( p_WIP_ENTITY_ID, FND_API.G_MISS_NUM, NULL, p_WIP_ENTITY_ID),
           decode( p_GROUP_ID, FND_API.G_MISS_NUM, NULL, p_GROUP_ID),
           decode( p_ORGANIZATION_ID, FND_API.G_MISS_NUM, NULL, p_ORGANIZATION_ID),
           decode( p_QUANTITY, FND_API.G_MISS_NUM, NULL, p_QUANTITY),
           decode( p_INVENTORY_ITEM_ID, FND_API.G_MISS_NUM, NULL, p_INVENTORY_ITEM_ID),
           decode( p_ITEM_REVISION, FND_API.G_MISS_CHAR, NULL, p_ITEM_REVISION),
           decode( p_SOURCE_TYPE_CODE, FND_API.G_MISS_CHAR, NULL, p_SOURCE_TYPE_CODE ),
           decode( p_SOURCE_ID1, FND_API.G_MISS_NUM, NULL, p_SOURCE_ID1),
           decode( p_RO_SERVICE_CODE_ID, FND_API.G_MISS_NUM, NULL, p_RO_SERVICE_CODE_ID),
           decode( p_JOB_NAME, FND_API.G_MISS_CHAR, NULL, p_JOB_NAME ),
           decode( p_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, NULL, p_OBJECT_VERSION_NUMBER),
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
           decode( p_QUANTITY_completed, FND_API.G_MISS_NUM, NULL, p_QUANTITY_completed));
End Insert_Row;

PROCEDURE Update_Row(
          p_REPAIR_JOB_XREF_ID    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_REPAIR_LINE_ID    NUMBER,
          p_WIP_ENTITY_ID    NUMBER,
          p_GROUP_ID    NUMBER,
          p_ORGANIZATION_ID    NUMBER,
          p_QUANTITY    NUMBER,
        p_INVENTORY_ITEM_ID  NUMBER,
        p_ITEM_REVISION      VARCHAR2,
        p_OBJECT_VERSION_NUMBER  NUMBER,
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
        p_quantity_completed NUMBER)

 IS
 BEGIN

    IF l_debug > 0 THEN
        csd_gen_utility_pvt.add('CSD_REPAIR_JOB_XREF_PKG.Update_Row OVN : '||to_char(p_OBJECT_VERSION_NUMBER));
    END IF;

    Update CSD_REPAIR_JOB_XREF
    SET
              CREATED_BY = decode( p_CREATED_BY, FND_API.G_MISS_NUM, CREATED_BY, p_CREATED_BY),
              CREATION_DATE = decode( p_CREATION_DATE, FND_API.G_MISS_DATE, CREATION_DATE, p_CREATION_DATE),
              LAST_UPDATED_BY = decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, LAST_UPDATED_BY, p_LAST_UPDATED_BY),
              LAST_UPDATE_DATE = decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, LAST_UPDATE_DATE, p_LAST_UPDATE_DATE),
              LAST_UPDATE_LOGIN = decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, LAST_UPDATE_LOGIN, p_LAST_UPDATE_LOGIN),
              REPAIR_LINE_ID = decode( p_REPAIR_LINE_ID, FND_API.G_MISS_NUM, REPAIR_LINE_ID, p_REPAIR_LINE_ID),
              WIP_ENTITY_ID = decode( p_WIP_ENTITY_ID, FND_API.G_MISS_NUM, WIP_ENTITY_ID, p_WIP_ENTITY_ID),
              GROUP_ID = decode( p_GROUP_ID, FND_API.G_MISS_NUM, GROUP_ID, p_GROUP_ID),
              ORGANIZATION_ID = decode( p_ORGANIZATION_ID, FND_API.G_MISS_NUM, ORGANIZATION_ID, p_ORGANIZATION_ID),
              QUANTITY = decode( p_QUANTITY, FND_API.G_MISS_NUM, QUANTITY, p_QUANTITY),
              INVENTORY_ITEM_ID = decode( p_INVENTORY_ITEM_ID, FND_API.G_MISS_NUM, INVENTORY_ITEM_ID, p_INVENTORY_ITEM_ID),
              ITEM_REVISION = decode( p_ITEM_REVISION, FND_API.G_MISS_CHAR, ITEM_REVISION, p_ITEM_REVISION),
              OBJECT_VERSION_NUMBER = decode( p_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, OBJECT_VERSION_NUMBER, p_OBJECT_VERSION_NUMBER),
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

              QUANTITY_COMPLETED = decode( p_QUANTITY_completed,
            FND_API.G_MISS_NUM, QUANTITY_COMPLETED, p_QUANTITY_completed)
    where REPAIR_JOB_XREF_ID = p_REPAIR_JOB_XREF_ID;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;

END Update_Row;

PROCEDURE Delete_Row(
    p_REPAIR_JOB_XREF_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM CSD_REPAIR_JOB_XREF
    WHERE REPAIR_JOB_XREF_ID = p_REPAIR_JOB_XREF_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;

PROCEDURE Lock_Row(
          p_REPAIR_JOB_XREF_ID    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_REPAIR_LINE_ID    NUMBER,
          p_WIP_ENTITY_ID    NUMBER,
          p_GROUP_ID    NUMBER,
          p_ORGANIZATION_ID    NUMBER,
          p_QUANTITY    NUMBER,
        p_INVENTORY_ITEM_ID  NUMBER,
        p_ITEM_REVISION      VARCHAR2,
        p_OBJECT_VERSION_NUMBER  NUMBER,
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
        p_quantity_completed NUMBER)

 IS
   CURSOR C IS
        SELECT *
         FROM CSD_REPAIR_JOB_XREF
        WHERE REPAIR_JOB_XREF_ID =  p_REPAIR_JOB_XREF_ID
        FOR UPDATE of REPAIR_JOB_XREF_ID NOWAIT;
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

    -- travi added for Inventory_Item_ID , Item_Revision and OBJECT_VERSION_NUMBER
    if (
           (      Recinfo.REPAIR_JOB_XREF_ID = p_REPAIR_JOB_XREF_ID)
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
       AND (    ( Recinfo.REPAIR_LINE_ID = p_REPAIR_LINE_ID)
            OR (    ( Recinfo.REPAIR_LINE_ID IS NULL )
                AND (  p_REPAIR_LINE_ID IS NULL )))
       AND (    ( Recinfo.WIP_ENTITY_ID = p_WIP_ENTITY_ID)
            OR (    ( Recinfo.WIP_ENTITY_ID IS NULL )
                AND (  p_WIP_ENTITY_ID IS NULL )))
       AND (    ( Recinfo.GROUP_ID = p_GROUP_ID)
            OR (    ( Recinfo.GROUP_ID IS NULL )
                AND (  p_GROUP_ID IS NULL )))
       AND (    ( Recinfo.ORGANIZATION_ID = p_ORGANIZATION_ID)
            OR (    ( Recinfo.ORGANIZATION_ID IS NULL )
                AND (  p_ORGANIZATION_ID IS NULL )))
       AND (    ( Recinfo.QUANTITY = p_QUANTITY)
            OR (    ( Recinfo.QUANTITY IS NULL )
                AND (  p_QUANTITY IS NULL )))
       AND (    ( Recinfo.INVENTORY_ITEM_ID = p_INVENTORY_ITEM_ID)
            OR (    ( Recinfo.INVENTORY_ITEM_ID IS NULL )
                AND (  p_INVENTORY_ITEM_ID IS NULL )))
       AND (    ( Recinfo.ITEM_REVISION = p_ITEM_REVISION)
            OR (    ( Recinfo.ITEM_REVISION IS NULL )
                AND (  p_ITEM_REVISION IS NULL )))
       AND (    ( Recinfo.OBJECT_VERSION_NUMBER = p_OBJECT_VERSION_NUMBER)
            OR (    ( Recinfo.OBJECT_VERSION_NUMBER IS NULL )
                AND (  p_OBJECT_VERSION_NUMBER IS NULL )))
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
       AND (    ( Recinfo.quantity_completed= p_quantity_completed)
            OR (    ( Recinfo.quantity_completed IS NULL )
                AND (  p_quantity_completed IS NULL )))
       ) then
       return;
   else
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   End If;
END Lock_Row;

End CSD_REPAIR_JOB_XREF_PKG;

/
