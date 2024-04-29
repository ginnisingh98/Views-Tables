--------------------------------------------------------
--  DDL for Package Body AS_SALES_LEAD_CONTACTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_SALES_LEAD_CONTACTS_PKG" as
/* $Header: asxtslcb.pls 115.7 2004/04/14 20:39:48 chchandr ship $ */
-- Start of Comments
-- Package name     : AS_SALES_LEAD_CONTACTS_PKG
-- Purpose          : Sales lead contacts table handlers
-- NOTE             :
-- History          : 04/09/2001 FFANG   Created.
--
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AS_SALES_LEAD_CONTACTS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'asxtslcb.pls';


AS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);
AS_DEBUG_ERROR_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_ERROR);

PROCEDURE SALES_LEAD_CONTACTS_Insert_Row(
          px_LEAD_CONTACT_ID   IN OUT NOCOPY NUMBER,
          p_SALES_LEAD_ID    NUMBER,
          p_CONTACT_ID    NUMBER,
          p_CONTACT_PARTY_ID    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_REQUEST_ID    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_ENABLED_FLAG    VARCHAR2,
          p_RANK    VARCHAR2,
          p_CUSTOMER_ID    NUMBER,
          p_ADDRESS_ID    NUMBER,
          p_PHONE_ID    NUMBER,
          p_CONTACT_ROLE_CODE    VARCHAR2,
          p_PRIMARY_CONTACT_FLAG    VARCHAR2,
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
--        p_SECURITY_GROUP_ID     NUMBER)

 IS
   CURSOR C2 IS SELECT AS_SALES_LEAD_CONTACTS_S.nextval FROM sys.dual;
BEGIN
   If (px_LEAD_CONTACT_ID IS NULL) OR (px_LEAD_CONTACT_ID = FND_API.G_MISS_NUM) then
       OPEN C2;
       FETCH C2 INTO px_LEAD_CONTACT_ID;
       CLOSE C2;
   End If;
   INSERT INTO AS_SALES_LEAD_CONTACTS(
           LEAD_CONTACT_ID,
           SALES_LEAD_ID,
           CONTACT_ID,
           CONTACT_PARTY_ID,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_LOGIN,
           REQUEST_ID,
           PROGRAM_APPLICATION_ID,
           PROGRAM_ID,
           PROGRAM_UPDATE_DATE,
           ENABLED_FLAG,
           RANK,
           CUSTOMER_ID,
           ADDRESS_ID,
           PHONE_ID,
           CONTACT_ROLE_CODE,
           PRIMARY_CONTACT_FLAG,
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
--         SECURITY_GROUP_ID
          ) VALUES (
           px_LEAD_CONTACT_ID,
           decode( p_SALES_LEAD_ID, FND_API.G_MISS_NUM, NULL, p_SALES_LEAD_ID),
           decode( p_CONTACT_ID, FND_API.G_MISS_NUM, NULL, p_CONTACT_ID),
           decode( p_CONTACT_PARTY_ID, FND_API.G_MISS_NUM, NULL,
                   p_CONTACT_PARTY_ID),
           decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL),
                   p_LAST_UPDATE_DATE),
           decode( p_LAST_UPDATED_BY,FND_API.G_MISS_NUM,NULL,p_LAST_UPDATED_BY),
           decode( p_CREATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL),
                   p_CREATION_DATE),
           decode( p_CREATED_BY, FND_API.G_MISS_NUM, NULL, p_CREATED_BY),
           decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL,
                   p_LAST_UPDATE_LOGIN),
           decode( p_REQUEST_ID, FND_API.G_MISS_NUM, NULL, p_REQUEST_ID),
           decode( p_PROGRAM_APPLICATION_ID, FND_API.G_MISS_NUM, NULL,
                   p_PROGRAM_APPLICATION_ID),
           decode( p_PROGRAM_ID, FND_API.G_MISS_NUM, NULL, p_PROGRAM_ID),
           decode( p_PROGRAM_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL),
                   p_PROGRAM_UPDATE_DATE),
           decode( p_ENABLED_FLAG, FND_API.G_MISS_CHAR, NULL, p_ENABLED_FLAG),
           decode( p_RANK, FND_API.G_MISS_CHAR, NULL, p_RANK),
           decode( p_CUSTOMER_ID, FND_API.G_MISS_NUM, NULL, p_CUSTOMER_ID),
           decode( p_ADDRESS_ID, FND_API.G_MISS_NUM, NULL, p_ADDRESS_ID),
           decode( p_PHONE_ID, FND_API.G_MISS_NUM, NULL, p_PHONE_ID),
           decode( p_CONTACT_ROLE_CODE, FND_API.G_MISS_CHAR, NULL,
                   p_CONTACT_ROLE_CODE),
           decode( p_PRIMARY_CONTACT_FLAG, FND_API.G_MISS_CHAR, NULL,
                   p_PRIMARY_CONTACT_FLAG),
           decode( p_ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR, NULL,
                   p_ATTRIBUTE_CATEGORY),
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
--         decode( p_SECURITY_GROUP_ID, FND_API.G_MISS_NUM, NULL,
--                 p_SECURITY_GROUP_ID));
End SALES_LEAD_CONTACTS_Insert_Row;

PROCEDURE SALES_LEAD_CONTACTS_Update_Row(
          p_LEAD_CONTACT_ID    NUMBER,
          p_SALES_LEAD_ID    NUMBER,
          p_CONTACT_ID    NUMBER,
          p_CONTACT_PARTY_ID    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_REQUEST_ID    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_ENABLED_FLAG    VARCHAR2,
          p_RANK    VARCHAR2,
          p_CUSTOMER_ID    NUMBER,
          p_ADDRESS_ID    NUMBER,
          p_PHONE_ID    NUMBER,
          p_CONTACT_ROLE_CODE    VARCHAR2,
          p_PRIMARY_CONTACT_FLAG    VARCHAR2,
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
--        p_SECURITY_GROUP_ID  NUMBER)

 IS

/* l_obj_verno         number;

 cursor  c_obj_verno is
  select object_version_number
  from    AS_SALES_LEAD_CONTACTS
  where  LEAD_CONTACT_ID =  p_LEAD_CONTACT_ID;
*/
 BEGIN
    Update AS_SALES_LEAD_CONTACTS
    SET
       SALES_LEAD_ID = decode( p_SALES_LEAD_ID, FND_API.G_MISS_NUM,
                               SALES_LEAD_ID, p_SALES_LEAD_ID),
       CONTACT_ID = decode( p_CONTACT_ID, FND_API.G_MISS_NUM, CONTACT_ID,
                            p_CONTACT_ID),
       CONTACT_PARTY_ID = decode( p_CONTACT_PARTY_ID, FND_API.G_MISS_NUM,
                                  CONTACT_PARTY_ID, p_CONTACT_PARTY_ID),
       LAST_UPDATE_DATE = decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE,
                                  LAST_UPDATE_DATE, p_LAST_UPDATE_DATE),
       LAST_UPDATED_BY = decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM,
                                 LAST_UPDATED_BY, p_LAST_UPDATED_BY),
       CREATION_DATE = decode( p_CREATION_DATE, FND_API.G_MISS_DATE,
                               CREATION_DATE, p_CREATION_DATE),
       CREATED_BY = decode( p_CREATED_BY, FND_API.G_MISS_NUM, CREATED_BY,
                            p_CREATED_BY),
       LAST_UPDATE_LOGIN = decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM,
                                   LAST_UPDATE_LOGIN, p_LAST_UPDATE_LOGIN),
       REQUEST_ID = decode( p_REQUEST_ID, FND_API.G_MISS_NUM, REQUEST_ID,
                            p_REQUEST_ID),
       PROGRAM_APPLICATION_ID = decode( p_PROGRAM_APPLICATION_ID,
                                        FND_API.G_MISS_NUM,
                                        PROGRAM_APPLICATION_ID,
                                        p_PROGRAM_APPLICATION_ID),
       PROGRAM_ID = decode( p_PROGRAM_ID, FND_API.G_MISS_NUM, PROGRAM_ID,
                            p_PROGRAM_ID),
       PROGRAM_UPDATE_DATE = decode( p_PROGRAM_UPDATE_DATE, FND_API.G_MISS_DATE,
                                     PROGRAM_UPDATE_DATE,p_PROGRAM_UPDATE_DATE),
       ENABLED_FLAG = decode( p_ENABLED_FLAG, FND_API.G_MISS_CHAR, ENABLED_FLAG,
                              p_ENABLED_FLAG),
       RANK = decode( p_RANK, FND_API.G_MISS_CHAR, RANK, p_RANK),
       CUSTOMER_ID = decode( p_CUSTOMER_ID, FND_API.G_MISS_NUM, CUSTOMER_ID,
                             p_CUSTOMER_ID),
       ADDRESS_ID = decode( p_ADDRESS_ID, FND_API.G_MISS_NUM, ADDRESS_ID,
                            p_ADDRESS_ID),
       PHONE_ID = decode( p_PHONE_ID, FND_API.G_MISS_NUM, PHONE_ID, p_PHONE_ID),
       CONTACT_ROLE_CODE = decode( p_CONTACT_ROLE_CODE, FND_API.G_MISS_CHAR,
                                   CONTACT_ROLE_CODE, p_CONTACT_ROLE_CODE),
       PRIMARY_CONTACT_FLAG = decode(p_PRIMARY_CONTACT_FLAG,FND_API.G_MISS_CHAR,
                                   PRIMARY_CONTACT_FLAG,p_PRIMARY_CONTACT_FLAG),
       ATTRIBUTE_CATEGORY = decode( p_ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR,
                                    ATTRIBUTE_CATEGORY, p_ATTRIBUTE_CATEGORY),
       ATTRIBUTE1 = decode( p_ATTRIBUTE1, FND_API.G_MISS_CHAR, ATTRIBUTE1,
                            p_ATTRIBUTE1),
       ATTRIBUTE2 = decode( p_ATTRIBUTE2, FND_API.G_MISS_CHAR, ATTRIBUTE2,
                            p_ATTRIBUTE2),
       ATTRIBUTE3 = decode( p_ATTRIBUTE3, FND_API.G_MISS_CHAR, ATTRIBUTE3,
                            p_ATTRIBUTE3),
       ATTRIBUTE4 = decode( p_ATTRIBUTE4, FND_API.G_MISS_CHAR, ATTRIBUTE4,
                            p_ATTRIBUTE4),
       ATTRIBUTE5 = decode( p_ATTRIBUTE5, FND_API.G_MISS_CHAR, ATTRIBUTE5,
                            p_ATTRIBUTE5),
       ATTRIBUTE6 = decode( p_ATTRIBUTE6, FND_API.G_MISS_CHAR, ATTRIBUTE6,
                            p_ATTRIBUTE6),
       ATTRIBUTE7 = decode( p_ATTRIBUTE7, FND_API.G_MISS_CHAR, ATTRIBUTE7,
                            p_ATTRIBUTE7),
       ATTRIBUTE8 = decode( p_ATTRIBUTE8, FND_API.G_MISS_CHAR, ATTRIBUTE8,
                            p_ATTRIBUTE8),
       ATTRIBUTE9 = decode( p_ATTRIBUTE9, FND_API.G_MISS_CHAR, ATTRIBUTE9,
                            p_ATTRIBUTE9),
       ATTRIBUTE10 = decode( p_ATTRIBUTE10, FND_API.G_MISS_CHAR, ATTRIBUTE10,
                             p_ATTRIBUTE10),
       ATTRIBUTE11 = decode( p_ATTRIBUTE11, FND_API.G_MISS_CHAR, ATTRIBUTE11,
                             p_ATTRIBUTE11),
       ATTRIBUTE12 = decode( p_ATTRIBUTE12, FND_API.G_MISS_CHAR, ATTRIBUTE12,
                             p_ATTRIBUTE12),
       ATTRIBUTE13 = decode( p_ATTRIBUTE13, FND_API.G_MISS_CHAR, ATTRIBUTE13,
                             p_ATTRIBUTE13),
       ATTRIBUTE14 = decode( p_ATTRIBUTE14, FND_API.G_MISS_CHAR, ATTRIBUTE14,
                             p_ATTRIBUTE14),
       ATTRIBUTE15 = decode( p_ATTRIBUTE15, FND_API.G_MISS_CHAR, ATTRIBUTE15,
                             p_ATTRIBUTE15),
       object_version_number = decode(object_version_number, null, 1, object_version_number+1)
--     SECURITY_GROUP_ID = decode( p_SECURITY_GROUP_ID, FND_API.G_MISS_NUM,
--                                 SECURITY_GROUP_ID, p_SECURITY_GROUP_ID)
    where LEAD_CONTACT_ID = p_LEAD_CONTACT_ID;
/*
   open c_obj_verno;
   fetch c_obj_verno into l_obj_verno;
   close c_obj_verno;

   update AS_SALES_LEAD_CONTACTS
    set object_version_number = decode(l_obj_verno, null, 1, l_obj_verno+1)
    where LEAD_CONTACT_ID = p_LEAD_CONTACT_ID;
*/
    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
END SALES_LEAD_CONTACTS_Update_Row;

PROCEDURE SALES_LEAD_CONTACTS_Delete_Row(
    p_LEAD_CONTACT_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM AS_SALES_LEAD_CONTACTS
    WHERE LEAD_CONTACT_ID = p_LEAD_CONTACT_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END SALES_LEAD_CONTACTS_Delete_Row;

PROCEDURE SALES_LEAD_CONTACTS_Lock_Row(
          p_LEAD_CONTACT_ID    NUMBER,
          p_SALES_LEAD_ID    NUMBER,
          p_CONTACT_ID    NUMBER,
          p_CONTACT_PARTY_ID    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_REQUEST_ID    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_ENABLED_FLAG    VARCHAR2,
          p_RANK    VARCHAR2,
          p_CUSTOMER_ID    NUMBER,
          p_ADDRESS_ID    NUMBER,
          p_PHONE_ID    NUMBER,
          p_CONTACT_ROLE_CODE    VARCHAR2,
          p_PRIMARY_CONTACT_FLAG    VARCHAR2,
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
--        p_SECURITY_GROUP_ID  NUMBER)

 IS
   CURSOR C IS
        SELECT *
         FROM AS_SALES_LEAD_CONTACTS
        WHERE LEAD_CONTACT_ID =  p_LEAD_CONTACT_ID
        FOR UPDATE of LEAD_CONTACT_ID NOWAIT;
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
           (      Recinfo.LEAD_CONTACT_ID = p_LEAD_CONTACT_ID)
       AND (    ( Recinfo.SALES_LEAD_ID = p_SALES_LEAD_ID)
            OR (    ( Recinfo.SALES_LEAD_ID IS NULL )
                AND (  p_SALES_LEAD_ID IS NULL )))
       AND (    ( Recinfo.CONTACT_ID = p_CONTACT_ID)
            OR (    ( Recinfo.CONTACT_ID IS NULL )
                AND (  p_CONTACT_ID IS NULL )))
       AND (    ( Recinfo.CONTACT_PARTY_ID = p_CONTACT_PARTY_ID)
            OR (    ( Recinfo.CONTACT_PARTY_ID IS NULL )
                AND (  p_CONTACT_PARTY_ID IS NULL )))
       AND (    ( Recinfo.LAST_UPDATE_DATE = p_LAST_UPDATE_DATE)
            OR (    ( Recinfo.LAST_UPDATE_DATE IS NULL )
                AND (  p_LAST_UPDATE_DATE IS NULL )))
       AND (    ( Recinfo.LAST_UPDATED_BY = p_LAST_UPDATED_BY)
            OR (    ( Recinfo.LAST_UPDATED_BY IS NULL )
                AND (  p_LAST_UPDATED_BY IS NULL )))
       AND (    ( Recinfo.CREATION_DATE = p_CREATION_DATE)
            OR (    ( Recinfo.CREATION_DATE IS NULL )
                AND (  p_CREATION_DATE IS NULL )))
       AND (    ( Recinfo.CREATED_BY = p_CREATED_BY)
            OR (    ( Recinfo.CREATED_BY IS NULL )
                AND (  p_CREATED_BY IS NULL )))
       AND (    ( Recinfo.LAST_UPDATE_LOGIN = p_LAST_UPDATE_LOGIN)
            OR (    ( Recinfo.LAST_UPDATE_LOGIN IS NULL )
                AND (  p_LAST_UPDATE_LOGIN IS NULL )))
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
       AND (    ( Recinfo.ENABLED_FLAG = p_ENABLED_FLAG)
            OR (    ( Recinfo.ENABLED_FLAG IS NULL )
                AND (  p_ENABLED_FLAG IS NULL )))
       AND (    ( Recinfo.RANK = p_RANK)
            OR (    ( Recinfo.RANK IS NULL )
                AND (  p_RANK IS NULL )))
       AND (    ( Recinfo.CUSTOMER_ID = p_CUSTOMER_ID)
            OR (    ( Recinfo.CUSTOMER_ID IS NULL )
                AND (  p_CUSTOMER_ID IS NULL )))
       AND (    ( Recinfo.ADDRESS_ID = p_ADDRESS_ID)
            OR (    ( Recinfo.ADDRESS_ID IS NULL )
                AND (  p_ADDRESS_ID IS NULL )))
       AND (    ( Recinfo.PHONE_ID = p_PHONE_ID)
            OR (    ( Recinfo.PHONE_ID IS NULL )
                AND (  p_PHONE_ID IS NULL )))
       AND (    ( Recinfo.CONTACT_ROLE_CODE = p_CONTACT_ROLE_CODE)
            OR (    ( Recinfo.CONTACT_ROLE_CODE IS NULL )
                AND (  p_CONTACT_ROLE_CODE IS NULL )))
       AND (    ( Recinfo.PRIMARY_CONTACT_FLAG = p_PRIMARY_CONTACT_FLAG)
            OR (    ( Recinfo.PRIMARY_CONTACT_FLAG IS NULL )
                AND (  p_PRIMARY_CONTACT_FLAG IS NULL )))
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
--     AND (    ( Recinfo.SECURITY_GROUP_ID = p_SECURITY_GROUP_ID)
--          OR (    ( Recinfo.SECURITY_GROUP_ID IS NULL )
--              AND (  p_SECURITY_GROUP_ID IS NULL )))
       ) then
       return;
   else
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   End If;
END SALES_LEAD_CONTACTS_Lock_Row;


End AS_SALES_LEAD_CONTACTS_PKG;

/
