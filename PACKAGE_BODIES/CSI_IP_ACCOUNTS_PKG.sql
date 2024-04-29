--------------------------------------------------------
--  DDL for Package Body CSI_IP_ACCOUNTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_IP_ACCOUNTS_PKG" as
/* $Header: csitaccb.pls 115.14 2003/09/04 00:12:28 sguthiva ship $ */


G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSI_IP_ACCOUNTS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csitaccb.pls';

PROCEDURE Insert_Row(
          px_IP_ACCOUNT_ID   IN OUT NOCOPY NUMBER,
          p_INSTANCE_PARTY_ID    NUMBER,
          p_PARTY_ACCOUNT_ID    NUMBER,
          p_RELATIONSHIP_TYPE_CODE    VARCHAR2,
          p_ACTIVE_START_DATE    DATE,
          p_ACTIVE_END_DATE    DATE,
          p_CONTEXT    VARCHAR2,
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
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_OBJECT_VERSION_NUMBER    NUMBER,
          p_BILL_TO_ADDRESS    NUMBER,
          p_SHIP_TO_ADDRESS    NUMBER,
          p_request_id                  NUMBER  ,
          p_program_application_id      NUMBER  ,
          p_program_id                  NUMBER  ,
          p_program_update_date         DATE
          )

 IS
   CURSOR C2 IS SELECT CSI_IP_ACCOUNTS_S.nextval FROM sys.dual;
BEGIN
   If (px_IP_ACCOUNT_ID IS NULL) OR (px_IP_ACCOUNT_ID = FND_API.G_MISS_NUM) then
       OPEN C2;
       FETCH C2 INTO px_IP_ACCOUNT_ID;
       CLOSE C2;
   End If;
   INSERT INTO CSI_IP_ACCOUNTS(
           IP_ACCOUNT_ID,
           INSTANCE_PARTY_ID,
           PARTY_ACCOUNT_ID,
           RELATIONSHIP_TYPE_CODE,
           ACTIVE_START_DATE,
           ACTIVE_END_DATE,
           CONTEXT,
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
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           OBJECT_VERSION_NUMBER,
           BILL_TO_ADDRESS,
           SHIP_TO_ADDRESS,
           request_id,
           program_application_id,
           program_id,
           program_update_date
          ) VALUES (
           px_IP_ACCOUNT_ID,
           decode( p_INSTANCE_PARTY_ID, FND_API.G_MISS_NUM, NULL, p_INSTANCE_PARTY_ID),
           decode( p_PARTY_ACCOUNT_ID, FND_API.G_MISS_NUM, NULL, p_PARTY_ACCOUNT_ID),
           decode( p_RELATIONSHIP_TYPE_CODE, FND_API.G_MISS_CHAR, NULL, p_RELATIONSHIP_TYPE_CODE),
           decode( p_ACTIVE_START_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_ACTIVE_START_DATE),
           decode( p_ACTIVE_END_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_ACTIVE_END_DATE),
           decode( p_CONTEXT, FND_API.G_MISS_CHAR, NULL, p_CONTEXT),
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
           decode( p_CREATED_BY, FND_API.G_MISS_NUM, NULL, p_CREATED_BY),
           decode( p_CREATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_CREATION_DATE),
           decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATED_BY),
           decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_LAST_UPDATE_DATE),
           decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATE_LOGIN),
           decode( p_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, NULL, p_OBJECT_VERSION_NUMBER),
           decode( p_BILL_TO_ADDRESS, FND_API.G_MISS_NUM, NULL, p_BILL_TO_ADDRESS),
           decode( p_SHIP_TO_ADDRESS, FND_API.G_MISS_NUM, NULL, p_SHIP_TO_ADDRESS),
           decode( p_request_id, fnd_api.g_miss_num, NULL, p_request_id),
           decode( p_program_application_id, fnd_api.g_miss_num, NULL, p_program_application_id),
           decode( p_program_id, fnd_api.g_miss_num, NULL, p_program_id),
           decode( p_program_update_date, fnd_api.g_miss_date, to_date(NULL), p_program_update_date)
           );
End Insert_Row;

PROCEDURE Update_Row(
          p_IP_ACCOUNT_ID    NUMBER,
          p_INSTANCE_PARTY_ID    NUMBER,
          p_PARTY_ACCOUNT_ID    NUMBER,
          p_RELATIONSHIP_TYPE_CODE    VARCHAR2,
          p_ACTIVE_START_DATE    DATE,
          p_ACTIVE_END_DATE    DATE,
          p_CONTEXT    VARCHAR2,
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
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_OBJECT_VERSION_NUMBER    NUMBER,
          p_BILL_TO_ADDRESS    NUMBER,
          p_SHIP_TO_ADDRESS    NUMBER,
          p_request_id                  NUMBER      ,
          p_program_application_id      NUMBER      ,
          p_program_id                  NUMBER      ,
          p_program_update_date         DATE
          )

 IS
 BEGIN
    Update CSI_IP_ACCOUNTS
    SET
              INSTANCE_PARTY_ID = decode( p_INSTANCE_PARTY_ID, FND_API.G_MISS_NUM, INSTANCE_PARTY_ID, p_INSTANCE_PARTY_ID),
              PARTY_ACCOUNT_ID = decode( p_PARTY_ACCOUNT_ID, FND_API.G_MISS_NUM, PARTY_ACCOUNT_ID, p_PARTY_ACCOUNT_ID),
              RELATIONSHIP_TYPE_CODE = decode( p_RELATIONSHIP_TYPE_CODE, FND_API.G_MISS_CHAR, RELATIONSHIP_TYPE_CODE, p_RELATIONSHIP_TYPE_CODE),
              ACTIVE_START_DATE = decode( p_ACTIVE_START_DATE, FND_API.G_MISS_DATE, ACTIVE_START_DATE, p_ACTIVE_START_DATE),
              ACTIVE_END_DATE = decode( p_ACTIVE_END_DATE, FND_API.G_MISS_DATE, ACTIVE_END_DATE, p_ACTIVE_END_DATE),
              CONTEXT = decode( p_CONTEXT, FND_API.G_MISS_CHAR, CONTEXT, p_CONTEXT),
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
              CREATED_BY = decode( p_CREATED_BY, FND_API.G_MISS_NUM, CREATED_BY, p_CREATED_BY),
              CREATION_DATE = decode( p_CREATION_DATE, FND_API.G_MISS_DATE, CREATION_DATE, p_CREATION_DATE),
              LAST_UPDATED_BY = decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, LAST_UPDATED_BY, p_LAST_UPDATED_BY),
              LAST_UPDATE_DATE = decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, LAST_UPDATE_DATE, p_LAST_UPDATE_DATE),
              LAST_UPDATE_LOGIN = decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, LAST_UPDATE_LOGIN, p_LAST_UPDATE_LOGIN),
              OBJECT_VERSION_NUMBER = decode( p_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, OBJECT_VERSION_NUMBER, p_OBJECT_VERSION_NUMBER),
              BILL_TO_ADDRESS = decode( p_BILL_TO_ADDRESS, FND_API.G_MISS_NUM, BILL_TO_ADDRESS, p_BILL_TO_ADDRESS),
              SHIP_TO_ADDRESS = decode( p_SHIP_TO_ADDRESS, FND_API.G_MISS_NUM, SHIP_TO_ADDRESS, p_SHIP_TO_ADDRESS),
              request_id = decode(p_request_id,fnd_api.g_miss_num,request_id,p_request_id),
              program_application_id = decode(p_program_application_id,fnd_api.g_miss_num,program_application_id,p_program_application_id),
              program_id = decode(p_program_id,fnd_api.g_miss_num,program_id,p_program_id),
              program_update_date = decode( p_program_update_date, fnd_api.g_miss_date, program_update_date, p_program_update_date)
    where IP_ACCOUNT_ID = p_IP_ACCOUNT_ID;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
END Update_Row;

PROCEDURE Delete_Row(
    p_IP_ACCOUNT_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM CSI_IP_ACCOUNTS
    WHERE IP_ACCOUNT_ID = p_IP_ACCOUNT_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;

PROCEDURE Lock_Row(
          p_IP_ACCOUNT_ID    NUMBER,
          p_INSTANCE_PARTY_ID    NUMBER,
          p_PARTY_ACCOUNT_ID    NUMBER,
          p_RELATIONSHIP_TYPE_CODE    VARCHAR2,
          p_ACTIVE_START_DATE    DATE,
          p_ACTIVE_END_DATE    DATE,
          p_CONTEXT    VARCHAR2,
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
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_OBJECT_VERSION_NUMBER    NUMBER,
          p_BILL_TO_ADDRESS    NUMBER,
          p_SHIP_TO_ADDRESS    NUMBER)

 IS
   CURSOR C IS
        SELECT *
         FROM CSI_IP_ACCOUNTS
        WHERE IP_ACCOUNT_ID =  p_IP_ACCOUNT_ID
        FOR UPDATE of IP_ACCOUNT_ID NOWAIT;
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
           (      Recinfo.IP_ACCOUNT_ID = p_IP_ACCOUNT_ID)
       AND (    ( Recinfo.INSTANCE_PARTY_ID = p_INSTANCE_PARTY_ID)
            OR (    ( Recinfo.INSTANCE_PARTY_ID IS NULL )
                AND (  p_INSTANCE_PARTY_ID IS NULL )))
       AND (    ( Recinfo.PARTY_ACCOUNT_ID = p_PARTY_ACCOUNT_ID)
            OR (    ( Recinfo.PARTY_ACCOUNT_ID IS NULL )
                AND (  p_PARTY_ACCOUNT_ID IS NULL )))
       AND (    ( Recinfo.RELATIONSHIP_TYPE_CODE = p_RELATIONSHIP_TYPE_CODE)
            OR (    ( Recinfo.RELATIONSHIP_TYPE_CODE IS NULL )
                AND (  p_RELATIONSHIP_TYPE_CODE IS NULL )))
       AND (    ( Recinfo.ACTIVE_START_DATE = p_ACTIVE_START_DATE)
            OR (    ( Recinfo.ACTIVE_START_DATE IS NULL )
                AND (  p_ACTIVE_START_DATE IS NULL )))
       AND (    ( Recinfo.ACTIVE_END_DATE = p_ACTIVE_END_DATE)
            OR (    ( Recinfo.ACTIVE_END_DATE IS NULL )
                AND (  p_ACTIVE_END_DATE IS NULL )))
       AND (    ( Recinfo.CONTEXT = p_CONTEXT)
            OR (    ( Recinfo.CONTEXT IS NULL )
                AND (  p_CONTEXT IS NULL )))
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
       AND (    ( Recinfo.BILL_TO_ADDRESS = p_BILL_TO_ADDRESS)
            OR (    ( Recinfo.BILL_TO_ADDRESS IS NULL )
                AND (  p_BILL_TO_ADDRESS IS NULL )))
       AND (    ( Recinfo.SHIP_TO_ADDRESS = p_SHIP_TO_ADDRESS)
            OR (    ( Recinfo.SHIP_TO_ADDRESS IS NULL )
                AND (  p_SHIP_TO_ADDRESS IS NULL )))
       ) then
       return;
   else
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   End If;
END Lock_Row;

End CSI_IP_ACCOUNTS_PKG;


/
