--------------------------------------------------------
--  DDL for Package Body CSP_MOVEORDER_HEADERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_MOVEORDER_HEADERS_PKG" AS
/* $Header: cspttmhb.pls 115.17 2002/11/26 07:47:54 hhaugeru ship $ */
-- Start of Comments
-- Package name     : CSP_MOVEORDER_HEADERS_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSP_MOVEORDER_HEADERS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'cspttmhb.pls';

PROCEDURE Insert_Row(
          p_HEADER_ID   NUMBER,    -- change IN-OUT px_HEADER_ID to an IN parameter only. 12/06/99 VL
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_CARRIER    VARCHAR2,
          p_SHIPMENT_METHOD    VARCHAR2,
          p_AUTORECEIPT_FLAG    VARCHAR2,
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
          -- changed phegde 02/28
          p_location_id     NUMBER,
          -- changed phegde 12/07/2000
          p_party_site_id   NUMBER

          )

 IS
-- Removed by VL, 12/06/99
--  CURSOR C2 IS SELECT CSP_MOVEORDER_HEADERS_S.nextval FROM sys.dual;

BEGIN
/*   If (px_HEADER_ID IS NULL) OR (px_HEADER_ID = FND_API.G_MISS_NUM) then
       OPEN C2;
       FETCH C2 INTO px_HEADER_ID;
       CLOSE C2;
   End If;*/

   INSERT INTO CSP_MOVEORDER_HEADERS(
           HEADER_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           CARRIER,
           SHIPMENT_METHOD,
           AUTORECEIPT_FLAG,
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
-- changed phegde 02/28
           LOCATION_ID,
-- changed Arul 12/07
           PARTY_SITE_ID
           --ADDRESS1,
           --ADDRESS2,
           --ADDRESS3,
           --ADDRESS4,
           --CITY,
           --POSTAL_CODE,
           --STATE,
           --PROVINCE,
           --COUNTRY
          ) VALUES (
           p_HEADER_ID,
           decode( p_CREATED_BY, FND_API.G_MISS_NUM, NULL, p_CREATED_BY),
           decode( nvl(p_creation_date, fnd_api.g_miss_date),fnd_api.g_miss_date,sysdate,p_creation_date),
           decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATED_BY),
           decode( nvl(p_LAST_UPDATE_DATE, fnd_api.g_miss_date),fnd_api.g_miss_date,sysdate,p_last_update_date),
           decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATE_LOGIN),
           decode( p_CARRIER, FND_API.G_MISS_CHAR, NULL, p_CARRIER),
           decode( p_SHIPMENT_METHOD, FND_API.G_MISS_CHAR, NULL, p_SHIPMENT_METHOD),
           decode( p_AUTORECEIPT_FLAG, FND_API.G_MISS_CHAR, NULL, p_AUTORECEIPT_FLAG),
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
           --changed phegde 02/28
           decode( p_LOCATION_ID, FND_API.G_MISS_NUM, NULL, p_LOCATION_ID),
-- changed Arul 12/07
           decode( p_PARTY_SITE_ID, FND_API.G_MISS_NUM, NULL, p_PARTY_SITE_ID)
           /*decode( p_ADDRESS1, FND_API.G_MISS_CHAR, NULL, p_ADDRESS1),
           decode( p_ADDRESS2, FND_API.G_MISS_CHAR, NULL, p_ADDRESS2),
           decode( p_ADDRESS3, FND_API.G_MISS_CHAR, NULL, p_ADDRESS3),
           decode( p_ADDRESS4, FND_API.G_MISS_CHAR, NULL, p_ADDRESS4),
           decode( p_CITY, FND_API.G_MISS_CHAR, NULL, p_CITY),
           decode( p_POSTAL_CODE, FND_API.G_MISS_CHAR, NULL, p_POSTAL_CODE),
           decode( p_STATE, FND_API.G_MISS_CHAR, NULL, p_STATE),
           decode( p_PROVINCE, FND_API.G_MISS_CHAR, NULL, p_PROVINCE),
           decode( p_COUNTRY, FND_API.G_MISS_CHAR, NULL, p_COUNTRY) */
           );

End Insert_Row;

PROCEDURE Update_Row(
          p_HEADER_ID    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_CARRIER    VARCHAR2,
          p_SHIPMENT_METHOD    VARCHAR2,
          p_AUTORECEIPT_FLAG    VARCHAR2,
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
          -- changed phegde 02/28
          p_location_id     NUMBER,
-- changed Arul 12/07
          P_PARTY_SITE_ID  NUMBER
          )

 IS
 BEGIN
    Update CSP_MOVEORDER_HEADERS
    SET
              CREATED_BY = decode( p_CREATED_BY, FND_API.G_MISS_NUM, CREATED_BY, p_CREATED_BY),
              CREATION_DATE = decode(p_CREATION_DATE,fnd_api.g_miss_date,creation_date,p_creation_date),
              LAST_UPDATED_BY = decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, LAST_UPDATED_BY, p_LAST_UPDATED_BY),
              LAST_UPDATE_DATE = decode(p_LAST_UPDATE_DATE,fnd_api.g_miss_date,last_update_date,p_last_update_date),
              LAST_UPDATE_LOGIN = decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, LAST_UPDATE_LOGIN, p_LAST_UPDATE_LOGIN),
              CARRIER = decode( p_CARRIER, FND_API.G_MISS_CHAR, CARRIER, p_CARRIER),
              SHIPMENT_METHOD = decode( p_SHIPMENT_METHOD, FND_API.G_MISS_CHAR, SHIPMENT_METHOD, p_SHIPMENT_METHOD),
              AUTORECEIPT_FLAG = decode( p_AUTORECEIPT_FLAG, FND_API.G_MISS_CHAR, AUTORECEIPT_FLAG, p_AUTORECEIPT_FLAG),
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
              -- changed phegde 02/28
              LOCATION_ID = decode( p_LOCATION_ID, FND_API.G_MISS_NUM, LOCATION_ID, p_LOCATION_ID),
-- changed Arul 12/07
              PARTY_SITE_ID = decode( p_PARTY_SITE_ID, FND_API.G_MISS_NUM, PARTY_SITE_ID, p_PARTY_SITE_ID)

              /* ADDRESS1 = decode( p_ADDRESS1, FND_API.G_MISS_CHAR, ADDRESS1, p_ADDRESS1),
              ADDRESS2 = decode( p_ADDRESS2, FND_API.G_MISS_CHAR, ADDRESS2, p_ADDRESS2),
              ADDRESS3 = decode( p_ADDRESS3, FND_API.G_MISS_CHAR, ADDRESS3, p_ADDRESS3),
              ADDRESS4 = decode( p_ADDRESS4, FND_API.G_MISS_CHAR, ADDRESS4, p_ADDRESS4),
              CITY = decode( p_CITY, FND_API.G_MISS_CHAR, CITY, p_CITY),
              POSTAL_CODE = decode( p_POSTAL_CODE, FND_API.G_MISS_CHAR, POSTAL_CODE, p_POSTAL_CODE),
              STATE = decode( p_STATE, FND_API.G_MISS_CHAR, STATE, p_STATE),
              PROVINCE = decode( p_PROVINCE, FND_API.G_MISS_CHAR, PROVINCE, p_PROVINCE),
              COUNTRY = decode( p_COUNTRY, FND_API.G_MISS_CHAR, COUNTRY, p_COUNTRY) */
    where HEADER_ID = p_HEADER_ID;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
END Update_Row;

PROCEDURE Delete_Row(
    p_HEADER_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM CSP_MOVEORDER_HEADERS
    WHERE HEADER_ID = p_HEADER_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;

PROCEDURE Lock_Row(
          p_HEADER_ID    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_CARRIER    VARCHAR2,
          p_SHIPMENT_METHOD    VARCHAR2,
          p_AUTORECEIPT_FLAG    VARCHAR2,
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
          -- changed phegde 02/28
          p_LOCATION_ID     NUMBER,
-- changed Arul 12/07
          P_PARTY_SITE_ID  NUMBER
          )

 IS
   CURSOR C IS
        SELECT *
         FROM CSP_MOVEORDER_HEADERS
        WHERE HEADER_ID =  p_HEADER_ID
        FOR UPDATE of HEADER_ID NOWAIT;
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
           (      Recinfo.HEADER_ID = p_HEADER_ID)
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
       AND (    ( Recinfo.CARRIER = p_CARRIER)
            OR (    ( Recinfo.CARRIER IS NULL )
                AND (  p_CARRIER IS NULL )))
       AND (    ( Recinfo.SHIPMENT_METHOD = p_SHIPMENT_METHOD)
            OR (    ( Recinfo.SHIPMENT_METHOD IS NULL )
                AND (  p_SHIPMENT_METHOD IS NULL )))
       AND (    ( Recinfo.AUTORECEIPT_FLAG = p_AUTORECEIPT_FLAG)
            OR (    ( Recinfo.AUTORECEIPT_FLAG IS NULL )
                AND (  p_AUTORECEIPT_FLAG IS NULL )))
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
       -- changed phegde 02/28
       AND (    ( Recinfo.LOCATION_ID = p_LOCATION_ID)
            OR (    ( Recinfo.LOCATION_ID IS NULL )
                AND (  p_LOCATION_ID IS NULL )))
-- changed Arul 12/07
       AND (    ( Recinfo.PARTY_SITE_ID = p_PARTY_SITE_ID)
            OR (    ( Recinfo.PARTY_SITE_ID IS NULL )
                AND (  p_PARTY_SITE_ID IS NULL )))
       ) then
       return;
   else
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   End If;
END Lock_Row;

End CSP_MOVEORDER_HEADERS_PKG;

/
