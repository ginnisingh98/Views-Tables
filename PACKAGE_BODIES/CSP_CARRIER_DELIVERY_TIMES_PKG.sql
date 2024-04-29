--------------------------------------------------------
--  DDL for Package Body CSP_CARRIER_DELIVERY_TIMES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_CARRIER_DELIVERY_TIMES_PKG" AS
/* $Header: csptcdtb.pls 120.0.12010000.4 2012/03/22 22:22:02 hhaugeru ship $ */
-- Start of Comments
-- Package name     : CSP_SCH_INT_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments



G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSP_CARRIER_DELIVERY_TIMES_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csptcdtb.pls';

PROCEDURE Insert_Row(
          px_RELATION_SHIP_ID   IN OUT NOCOPY NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_ORGANIZATION_ID    NUMBER,
          p_SUBINVENTORY_CODE    VARCHAR2,
          p_LOCATION_ID    NUMBER,
          p_SHIPPING_METHODE    VARCHAR2,
          p_LEAD_TIME    NUMBER,
          p_LEAD_TIME_UOM    VARCHAR2,
          p_DELIVERY_TIME    DATE,
          p_CUTOFF_TIME    DATE,
          p_TIMEZONE_ID    NUMBER,
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
          p_SAFTEY_ZONE    NUMBER,
          p_DISTANCE    NUMBER,
          p_DISTANCE_UOM    VARCHAR2)

 IS
   CURSOR C2 IS SELECT CSP_CARRIER_DELIVERY_TIMES_S1.nextval FROM sys.dual;
BEGIN
   If (px_RELATION_SHIP_ID IS NULL) OR (px_RELATION_SHIP_ID = FND_API.G_MISS_NUM) then
       OPEN C2;
       FETCH C2 INTO px_RELATION_SHIP_ID;
       CLOSE C2;
   End If;

   INSERT INTO CSP_CARRIER_DELIVERY_TIMES(
           RELATION_SHIP_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           ORGANIZATION_ID,
           SUBINVENTORY_CODE,
           LOCATION_ID,
           SHIPPING_METHOD,
           LEAD_TIME,
           LEAD_TIME_UOM,
           DELIVERY_TIME,
           CUTOFF_TIME,
           TIMEZONE_ID,
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
           SAFETY_ZONE,
           DISTANCE,
           DISTANCE_UOM
          ) VALUES (
           px_RELATION_SHIP_ID,
           decode( p_CREATED_BY, FND_API.G_MISS_NUM, NULL, p_CREATED_BY),
           decode( p_CREATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_CREATION_DATE),
           decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATED_BY),
           decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_LAST_UPDATE_DATE),
           decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATE_LOGIN),
           decode( p_ORGANIZATION_ID, FND_API.G_MISS_NUM, NULL, p_ORGANIZATION_ID),
           decode( p_SUBINVENTORY_CODE, FND_API.G_MISS_CHAR, NULL, p_SUBINVENTORY_CODE),
           decode( p_LOCATION_ID, FND_API.G_MISS_NUM, NULL, p_LOCATION_ID),
           decode( p_SHIPPING_METHODE, FND_API.G_MISS_CHAR, NULL, p_SHIPPING_METHODE),
           decode( p_LEAD_TIME, FND_API.G_MISS_NUM, NULL, p_LEAD_TIME),
           decode( p_LEAD_TIME_UOM, FND_API.G_MISS_CHAR, NULL, p_LEAD_TIME_UOM),
           decode( p_DELIVERY_TIME, FND_API.G_MISS_DATE, TO_DATE(NULL), p_DELIVERY_TIME),
           decode( p_CUTOFF_TIME, FND_API.G_MISS_DATE, TO_DATE(NULL), p_CUTOFF_TIME),
           decode( p_TIMEZONE_ID, FND_API.G_MISS_NUM, NULL, p_TIMEZONE_ID),
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
           decode( p_SAFTEY_ZONE, FND_API.G_MISS_NUM, NULL, p_SAFTEY_ZONE),
           decode( p_DISTANCE, FND_API.G_MISS_NUM, NULL, p_DISTANCE),
           decode( p_DISTANCE_UOM, FND_API.G_MISS_CHAR, NULL, p_DISTANCE_UOM));

End Insert_Row;

PROCEDURE Update_Row(
          p_RELATION_SHIP_ID    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_ORGANIZATION_ID    NUMBER,
          p_SUBINVENTORY_CODE    VARCHAR2,
          p_SHIPPING_METHODE    VARCHAR2,
          p_LEAD_TIME    NUMBER,
          p_LEAD_TIME_UOM    VARCHAR2,
          p_DELIVERY_TIME    DATE,
          p_CUTOFF_TIME    DATE,
          p_TIMEZONE_ID    NUMBER,
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
          p_SAFTEY_ZONE    NUMBER,
          p_DISTANCE    NUMBER,
          p_DISTANCE_UOM    VARCHAR2)

 IS
 BEGIN
    Update CSP_CARRIER_DELIVERY_TIMES
    SET
              CREATED_BY = decode( p_CREATED_BY, FND_API.G_MISS_NUM, CREATED_BY, p_CREATED_BY),
              CREATION_DATE = decode( p_CREATION_DATE, FND_API.G_MISS_DATE, CREATION_DATE, p_CREATION_DATE),
              LAST_UPDATED_BY = decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, LAST_UPDATED_BY, p_LAST_UPDATED_BY),
              LAST_UPDATE_DATE = decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, LAST_UPDATE_DATE, p_LAST_UPDATE_DATE),
              LAST_UPDATE_LOGIN = decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, LAST_UPDATE_LOGIN, p_LAST_UPDATE_LOGIN),
              ORGANIZATION_ID = decode( p_ORGANIZATION_ID, FND_API.G_MISS_NUM, ORGANIZATION_ID, p_ORGANIZATION_ID),
              SUBINVENTORY_CODE = decode( p_SUBINVENTORY_CODE, FND_API.G_MISS_CHAR, SUBINVENTORY_CODE, p_SUBINVENTORY_CODE),
              SHIPPING_METHOD = decode( p_SHIPPING_METHODE, FND_API.G_MISS_CHAR, SHIPPING_METHOD, p_SHIPPING_METHODE),
              LEAD_TIME = decode( p_LEAD_TIME, FND_API.G_MISS_NUM, LEAD_TIME, p_LEAD_TIME),
              LEAD_TIME_UOM = decode( p_LEAD_TIME_UOM, FND_API.G_MISS_CHAR, LEAD_TIME_UOM, p_LEAD_TIME_UOM),
              DELIVERY_TIME = decode( p_DELIVERY_TIME, FND_API.G_MISS_DATE, DELIVERY_TIME, p_DELIVERY_TIME),
              CUTOFF_TIME = decode( p_CUTOFF_TIME, FND_API.G_MISS_DATE, CUTOFF_TIME, p_CUTOFF_TIME),
              TIMEZONE_ID = decode( p_TIMEZONE_ID, FND_API.G_MISS_NUM, TIMEZONE_ID, p_TIMEZONE_ID),
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
              SAFETY_ZONE = decode( p_SAFTEY_ZONE, FND_API.G_MISS_NUM, SAFETY_ZONE, p_SAFTEY_ZONE),
              DISTANCE = decode( p_DISTANCE, FND_API.G_MISS_NUM, DISTANCE, p_DISTANCE),
              DISTANCE_UOM = decode( p_DISTANCE_UOM, FND_API.G_MISS_CHAR, DISTANCE_UOM, p_DISTANCE_UOM)
    where RELATION_SHIP_ID = p_RELATION_SHIP_ID;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
END Update_Row;

PROCEDURE Delete_Row(
    p_RELATION_SHIP_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM CSP_CARRIER_DELIVERY_TIMES
    WHERE RELATION_SHIP_ID = p_RELATION_SHIP_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;

PROCEDURE Lock_Row(
          p_RELATION_SHIP_ID    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_ORGANIZATION_ID    NUMBER,
          p_SUBINVENTORY_CODE    VARCHAR2,
          p_SHIPPING_METHODE    VARCHAR2,
          p_LEAD_TIME    NUMBER,
          p_LEAD_TIME_UOM    VARCHAR2,
          p_DELIVERY_TIME    DATE,
          p_CUTOFF_TIME    DATE,
          p_TIMEZONE_ID    NUMBER,
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
          p_SAFTEY_ZONE    NUMBER,
          p_DISTANCE    NUMBER,
          p_DISTANCE_UOM    VARCHAR2)

 IS
   CURSOR C IS
        SELECT *
         FROM CSP_CARRIER_DELIVERY_TIMES
        WHERE RELATION_SHIP_ID =  p_RELATION_SHIP_ID
        FOR UPDATE of RELATION_SHIP_ID NOWAIT;
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
           (      Recinfo.RELATION_SHIP_ID = p_RELATION_SHIP_ID)
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
       AND (    ( Recinfo.SHIPPING_METHOD = p_SHIPPING_METHODE)
            OR (    ( Recinfo.SHIPPING_METHOD IS NULL )
                AND (  p_SHIPPING_METHODE IS NULL )))
       AND (    ( Recinfo.LEAD_TIME = p_LEAD_TIME)
            OR (    ( Recinfo.LEAD_TIME IS NULL )
                AND (  p_LEAD_TIME IS NULL )))
       AND (    ( Recinfo.LEAD_TIME_UOM = p_LEAD_TIME_UOM)
            OR (    ( Recinfo.LEAD_TIME_UOM IS NULL )
                AND (  p_LEAD_TIME_UOM IS NULL )))
       AND (    ( Recinfo.DELIVERY_TIME = p_DELIVERY_TIME)
            OR (    ( Recinfo.DELIVERY_TIME IS NULL )
                AND (  p_DELIVERY_TIME IS NULL )))
       AND (    ( Recinfo.CUTOFF_TIME = p_CUTOFF_TIME)
            OR (    ( Recinfo.CUTOFF_TIME IS NULL )
                AND (  p_CUTOFF_TIME IS NULL )))
       AND (    ( Recinfo.TIMEZONE_ID = p_TIMEZONE_ID)
            OR (    ( Recinfo.TIMEZONE_ID IS NULL )
                AND (  p_TIMEZONE_ID IS NULL )))
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
       AND (    ( Recinfo.SAFETY_ZONE = p_SAFTEY_ZONE)
            OR (    ( Recinfo.SAFETY_ZONE IS NULL )
                AND (  p_SAFTEY_ZONE IS NULL )))
       AND (    ( Recinfo.DISTANCE = p_DISTANCE)
            OR (    ( Recinfo.DISTANCE IS NULL )
                AND (  p_DISTANCE IS NULL )))
       AND (    ( Recinfo.DISTANCE_UOM = p_DISTANCE_UOM)
            OR (    ( Recinfo.DISTANCE_UOM IS NULL )
                AND (  p_DISTANCE_UOM IS NULL )))
       ) then
       return;
   else
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   End If;
END Lock_Row;

End CSP_CARRIER_DELIVERY_TIMES_PKG;

/
