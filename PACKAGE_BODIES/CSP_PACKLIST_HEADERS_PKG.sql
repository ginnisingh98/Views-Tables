--------------------------------------------------------
--  DDL for Package Body CSP_PACKLIST_HEADERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_PACKLIST_HEADERS_PKG" as
/* $Header: cspttahb.pls 115.6 2002/12/12 20:31:02 hhaugeru ship $ */
-- Start of Comments
-- Package name     : CSP_PACKLIST_HEADERS_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSP_PACKLIST_HEADERS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csptpplb.pls';

PROCEDURE Insert_Row(
          px_PACKLIST_HEADER_ID   IN OUT NOCOPY NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_ORGANIZATION_ID    NUMBER,
          p_PACKLIST_NUMBER    VARCHAR2,
          p_SUBINVENTORY_CODE    VARCHAR2,
          p_PACKLIST_STATUS    VARCHAR2,
          p_DATE_CREATED    DATE,
          p_DATE_PACKED    DATE,
          p_DATE_SHIPPED    DATE,
          p_DATE_RECEIVED    DATE,
          p_CARRIER    VARCHAR2,
          p_SHIPMENT_METHOD    VARCHAR2,
          p_WAYBILL    VARCHAR2,
          p_COMMENTS    VARCHAR2,
          p_LOCATION_ID	NUMBER,
          p_PARTY_SITE_ID NUMBER ,
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
   CURSOR C2 IS SELECT CSP_PACKLIST_HEADERS_S1.nextval FROM sys.dual;
BEGIN
   If (px_PACKLIST_HEADER_ID IS NULL) OR (px_PACKLIST_HEADER_ID = FND_API.G_MISS_NUM) then
       OPEN C2;
       FETCH C2 INTO px_PACKLIST_HEADER_ID;
       CLOSE C2;
   End If;
   INSERT INTO CSP_PACKLIST_HEADERS(
           PACKLIST_HEADER_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           ORGANIZATION_ID,
           PACKLIST_NUMBER,
           SUBINVENTORY_CODE,
           PACKLIST_STATUS,
           DATE_CREATED,
           DATE_PACKED,
           DATE_SHIPPED,
           DATE_RECEIVED,
           CARRIER,
           SHIPMENT_METHOD,
           WAYBILL,
           COMMENTS,
           LOCATION_ID,
           PARTY_SITE_ID,
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
           px_PACKLIST_HEADER_ID,
           decode( p_CREATED_BY, FND_API.G_MISS_NUM, NULL, p_CREATED_BY),
           decode(p_CREATION_DATE,fnd_api.g_miss_date,to_date(null),p_creation_date),
           decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATED_BY),
           decode(p_LAST_UPDATE_DATE,fnd_api.g_miss_date,to_date(null),p_last_update_date),
           decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATE_LOGIN),
           decode( p_ORGANIZATION_ID, FND_API.G_MISS_NUM, NULL, p_ORGANIZATION_ID),
           px_PACKLIST_HEADER_ID,
           decode( p_SUBINVENTORY_CODE, FND_API.G_MISS_CHAR, NULL, p_SUBINVENTORY_CODE),
           decode( p_PACKLIST_STATUS, FND_API.G_MISS_CHAR, NULL, p_PACKLIST_STATUS),
           decode(p_DATE_CREATED,fnd_api.g_miss_date,to_date(null),p_date_created),
           decode( p_DATE_PACKED, FND_API.G_MISS_DATE, to_date(NULL), p_DATE_PACKED),
           decode( p_DATE_SHIPPED, FND_API.G_MISS_DATE, to_date(null), p_DATE_SHIPPED),
           decode( p_DATE_RECEIVED, FND_API.G_MISS_DATE, to_date(null), p_DATE_RECEIVED),
           decode( p_CARRIER, FND_API.G_MISS_CHAR, NULL, p_CARRIER),
           decode( p_SHIPMENT_METHOD, FND_API.G_MISS_CHAR, NULL, p_SHIPMENT_METHOD),
           decode( p_WAYBILL, FND_API.G_MISS_CHAR, NULL, p_WAYBILL),
           decode( p_COMMENTS, FND_API.G_MISS_CHAR, NULL, p_COMMENTS),
           decode( p_LOCATION_ID, FND_API.G_MISS_NUM, NULL, p_LOCATION_ID),
           decode( p_PARTY_SITE_ID, FND_API.G_MISS_NUM, NULL, p_PARTY_SITE_ID),
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
End Insert_Row;

PROCEDURE Update_Row(
          p_PACKLIST_HEADER_ID    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_ORGANIZATION_ID    NUMBER,
          p_PACKLIST_NUMBER    VARCHAR2,
          p_SUBINVENTORY_CODE    VARCHAR2,
          p_PACKLIST_STATUS    VARCHAR2,
          p_DATE_CREATED    DATE,
          p_DATE_PACKED    DATE,
          p_DATE_SHIPPED    DATE,
          p_DATE_RECEIVED    DATE,
          p_CARRIER    VARCHAR2,
          p_SHIPMENT_METHOD    VARCHAR2,
          p_WAYBILL    VARCHAR2,
          p_COMMENTS    VARCHAR2,
          p_LOCATION_ID NUMBER,
          p_PARTY_SITE_ID NUMBER ,
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
    Update CSP_PACKLIST_HEADERS
    SET
              CREATED_BY = decode( p_CREATED_BY, FND_API.G_MISS_NUM, CREATED_BY, p_CREATED_BY),
              CREATION_DATE = decode(p_CREATION_DATE,fnd_api.g_miss_date,creation_date,p_creation_date),
              LAST_UPDATED_BY = decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, LAST_UPDATED_BY, p_LAST_UPDATED_BY),
              LAST_UPDATE_DATE = decode(p_LAST_UPDATE_DATE,fnd_api.g_miss_date,last_update_date,p_last_update_date),
              LAST_UPDATE_LOGIN = decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, LAST_UPDATE_LOGIN, p_LAST_UPDATE_LOGIN),
              ORGANIZATION_ID = decode( p_ORGANIZATION_ID, FND_API.G_MISS_NUM, ORGANIZATION_ID, p_ORGANIZATION_ID),
              PACKLIST_NUMBER = decode( p_PACKLIST_NUMBER, FND_API.G_MISS_CHAR, PACKLIST_NUMBER, p_PACKLIST_NUMBER),
              SUBINVENTORY_CODE = decode( p_SUBINVENTORY_CODE, FND_API.G_MISS_CHAR, SUBINVENTORY_CODE, p_SUBINVENTORY_CODE),
              PACKLIST_STATUS = decode( p_PACKLIST_STATUS, FND_API.G_MISS_CHAR, PACKLIST_STATUS, p_PACKLIST_STATUS),
              DATE_CREATED = decode(p_DATE_CREATED,fnd_api.g_miss_date,date_created,p_date_created),
              DATE_PACKED = decode( p_DATE_PACKED, FND_API.G_MISS_DATE, DATE_PACKED, p_DATE_PACKED),
              DATE_SHIPPED = decode( p_DATE_SHIPPED, FND_API.G_MISS_DATE, DATE_SHIPPED, p_DATE_SHIPPED),
              DATE_RECEIVED = decode( p_DATE_RECEIVED, FND_API.G_MISS_DATE, DATE_RECEIVED, p_DATE_RECEIVED),
              CARRIER = decode( p_CARRIER, FND_API.G_MISS_CHAR, CARRIER, p_CARRIER),
              SHIPMENT_METHOD = decode( p_SHIPMENT_METHOD, FND_API.G_MISS_CHAR, SHIPMENT_METHOD, p_SHIPMENT_METHOD),
              WAYBILL = decode( p_WAYBILL, FND_API.G_MISS_CHAR, WAYBILL, p_WAYBILL),
              COMMENTS = decode( p_COMMENTS, FND_API.G_MISS_CHAR, COMMENTS, p_COMMENTS),
              LOCATION_ID = decode( p_LOCATION_ID, FND_API.G_MISS_NUM, NULL, p_LOCATION_ID),
              PARTY_SITE_ID = decode( p_PARTY_SITE_ID, FND_API.G_MISS_NUM, NULL, p_PARTY_SITE_ID),
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
    where PACKLIST_HEADER_ID = p_PACKLIST_HEADER_ID;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
END Update_Row;

PROCEDURE Delete_Row(
    p_PACKLIST_HEADER_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM CSP_PACKLIST_HEADERS
    WHERE PACKLIST_HEADER_ID = p_PACKLIST_HEADER_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;

PROCEDURE Lock_Row(
          p_PACKLIST_HEADER_ID    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_ORGANIZATION_ID    NUMBER,
          p_PACKLIST_NUMBER    VARCHAR2,
          p_SUBINVENTORY_CODE    VARCHAR2,
          p_PACKLIST_STATUS    VARCHAR2,
          p_DATE_CREATED    DATE,
          p_DATE_PACKED    DATE,
          p_DATE_SHIPPED    DATE,
          p_DATE_RECEIVED    DATE,
          p_CARRIER    VARCHAR2,
          p_SHIPMENT_METHOD    VARCHAR2,
          p_WAYBILL    VARCHAR2,
          p_COMMENTS    VARCHAR2,
          p_LOCATION_ID NUMBER,
          p_PARTY_SITE_ID NUMBER ,
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
         FROM CSP_PACKLIST_HEADERS
        WHERE PACKLIST_HEADER_ID =  p_PACKLIST_HEADER_ID
        FOR UPDATE of PACKLIST_HEADER_ID NOWAIT;
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
           (      Recinfo.PACKLIST_HEADER_ID = p_PACKLIST_HEADER_ID)
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
       AND (    ( Recinfo.PACKLIST_NUMBER = p_PACKLIST_NUMBER)
            OR (    ( Recinfo.PACKLIST_NUMBER IS NULL )
                AND (  p_PACKLIST_NUMBER IS NULL )))
       AND (    ( Recinfo.SUBINVENTORY_CODE = p_SUBINVENTORY_CODE)
            OR (    ( Recinfo.SUBINVENTORY_CODE IS NULL )
                AND (  p_SUBINVENTORY_CODE IS NULL )))
       AND (    ( Recinfo.PACKLIST_STATUS = p_PACKLIST_STATUS)
            OR (    ( Recinfo.PACKLIST_STATUS IS NULL )
                AND (  p_PACKLIST_STATUS IS NULL )))
       AND (    ( Recinfo.DATE_CREATED = p_DATE_CREATED)
            OR (    ( Recinfo.DATE_CREATED IS NULL )
                AND (  p_DATE_CREATED IS NULL )))
       AND (    ( Recinfo.DATE_PACKED = p_DATE_PACKED)
            OR (    ( Recinfo.DATE_PACKED IS NULL )
                AND (  p_DATE_PACKED IS NULL )))
       AND (    ( Recinfo.DATE_SHIPPED = p_DATE_SHIPPED)
            OR (    ( Recinfo.DATE_SHIPPED IS NULL )
                AND (  p_DATE_SHIPPED IS NULL )))
       AND (    ( Recinfo.DATE_RECEIVED = p_DATE_RECEIVED)
            OR (    ( Recinfo.DATE_RECEIVED IS NULL )
                AND (  p_DATE_RECEIVED IS NULL )))
       AND (    ( Recinfo.CARRIER = p_CARRIER)
            OR (    ( Recinfo.CARRIER IS NULL )
                AND (  p_CARRIER IS NULL )))
       AND (    ( Recinfo.SHIPMENT_METHOD = p_SHIPMENT_METHOD)
            OR (    ( Recinfo.SHIPMENT_METHOD IS NULL )
                AND (  p_SHIPMENT_METHOD IS NULL )))
       AND (    ( Recinfo.WAYBILL = p_WAYBILL)
            OR (    ( Recinfo.WAYBILL IS NULL )
                AND (  p_WAYBILL IS NULL )))
       AND (    ( Recinfo.COMMENTS = p_COMMENTS)
            OR (    ( Recinfo.COMMENTS IS NULL )
                AND (  p_COMMENTS IS NULL )))
       AND (    ( Recinfo.LOCATION_ID = p_LOCATION_ID)
            OR (    ( Recinfo.LOCATION_ID IS NULL )
                AND (  p_LOCATION_ID IS NULL )))
       AND (    ( Recinfo.PARTY_SITE_ID = p_PARTY_SITE_ID)
            OR (    ( Recinfo.PARTY_SITE_ID IS NULL )
                AND (  p_PARTY_SITE_ID IS NULL )))
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

End CSP_PACKLIST_HEADERS_PKG;

/
