--------------------------------------------------------
--  DDL for Package Body CSD_MRO_SERIAL_NUMBERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_MRO_SERIAL_NUMBERS_PKG" as
/* $Header: csdtsrlb.pls 115.7 2002/11/14 02:03:30 swai noship $ */


G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSD_MRO_SERIAL_NUMBERS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csdtsrlb.pls';
l_debug        NUMBER := csd_gen_utility_pvt.g_debug_level;

PROCEDURE Insert_Row(
          px_MRO_SERIAL_NUMBER_ID   IN OUT NOCOPY NUMBER
         ,p_REPAIR_GROUP_ID    NUMBER
         ,p_SERIAL_NUMBER    VARCHAR2
         ,p_VALIDATE_LEVEL    VARCHAR2
         ,p_CREATED_BY    NUMBER
         ,p_CREATION_DATE    DATE
         ,p_LAST_UPDATED_BY    NUMBER
         ,p_LAST_UPDATE_DATE    DATE
         ,p_LAST_UPDATE_LOGIN    NUMBER
         ,p_CONTEXT    VARCHAR2
         ,p_ATTRIBUTE1    VARCHAR2
         ,p_ATTRIBUTE2    VARCHAR2
         ,p_ATTRIBUTE3    VARCHAR2
         ,p_ATTRIBUTE4    VARCHAR2
         ,p_ATTRIBUTE5    VARCHAR2
         ,p_ATTRIBUTE6    VARCHAR2
         ,p_ATTRIBUTE7    VARCHAR2
         ,p_ATTRIBUTE8    VARCHAR2
         ,p_ATTRIBUTE9    VARCHAR2
         ,p_ATTRIBUTE10    VARCHAR2
         ,p_ATTRIBUTE11    VARCHAR2
         ,p_ATTRIBUTE12    VARCHAR2
         ,p_ATTRIBUTE13    VARCHAR2
         ,p_ATTRIBUTE14    VARCHAR2
         ,p_ATTRIBUTE15    VARCHAR2
         ,p_OBJECT_VERSION_NUMBER    NUMBER
         ,p_CUSTOMER_PRODUCT_ID     NUMBER
         ,p_REFERENCE_NUMBER VARCHAR2)

 IS
   CURSOR C2 IS SELECT CSD_MRO_SERIAL_NUMBERS_S1.nextval FROM sys.dual;
BEGIN
   If (px_MRO_SERIAL_NUMBER_ID IS NULL) OR (px_MRO_SERIAL_NUMBER_ID = FND_API.G_MISS_NUM) then
       OPEN C2;
       FETCH C2 INTO px_MRO_SERIAL_NUMBER_ID;
       CLOSE C2;
   End If;
   INSERT INTO CSD_MRO_SERIAL_NUMBERS(
           MRO_SERIAL_NUMBER_ID
          ,REPAIR_GROUP_ID
          ,SERIAL_NUMBER
          ,validate_level
          ,CREATED_BY
          ,CREATION_DATE
          ,LAST_UPDATED_BY
          ,LAST_UPDATE_DATE
          ,LAST_UPDATE_LOGIN
          ,CONTEXT
          ,ATTRIBUTE1
          ,ATTRIBUTE2
          ,ATTRIBUTE3
          ,ATTRIBUTE4
          ,ATTRIBUTE5
          ,ATTRIBUTE6
          ,ATTRIBUTE7
          ,ATTRIBUTE8
          ,ATTRIBUTE9
          ,ATTRIBUTE10
          ,ATTRIBUTE11
          ,ATTRIBUTE12
          ,ATTRIBUTE13
          ,ATTRIBUTE14
          ,ATTRIBUTE15
          ,OBJECT_VERSION_NUMBER
          ,CUSTOMER_PRODUCT_ID
          ,REFERENCE_NUMBER
          ) VALUES (
           px_MRO_SERIAL_NUMBER_ID
          ,decode( p_REPAIR_GROUP_ID, FND_API.G_MISS_NUM, NULL, p_REPAIR_GROUP_ID)
          ,decode( p_SERIAL_NUMBER, FND_API.G_MISS_CHAR, NULL, p_SERIAL_NUMBER)
          ,decode( p_VALIDATE_LEVEL, FND_API.G_MISS_CHAR, NULL, p_VALIDATE_LEVEL)
          ,decode( p_CREATED_BY, FND_API.G_MISS_NUM, NULL, p_CREATED_BY)
          ,decode( p_CREATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_CREATION_DATE)
          ,decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATED_BY)
          ,decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_LAST_UPDATE_DATE)
          ,decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATE_LOGIN)
          ,decode( p_CONTEXT, FND_API.G_MISS_CHAR, NULL, p_CONTEXT)
          ,decode( p_ATTRIBUTE1, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE1)
          ,decode( p_ATTRIBUTE2, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE2)
          ,decode( p_ATTRIBUTE3, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE3)
          ,decode( p_ATTRIBUTE4, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE4)
          ,decode( p_ATTRIBUTE5, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE5)
          ,decode( p_ATTRIBUTE6, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE6)
          ,decode( p_ATTRIBUTE7, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE7)
          ,decode( p_ATTRIBUTE8, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE8)
          ,decode( p_ATTRIBUTE9, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE9)
          ,decode( p_ATTRIBUTE10, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE10)
          ,decode( p_ATTRIBUTE11, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE11)
          ,decode( p_ATTRIBUTE12, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE12)
          ,decode( p_ATTRIBUTE13, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE13)
          ,decode( p_ATTRIBUTE14, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE14)
          ,decode( p_ATTRIBUTE15, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE15)
          ,decode( p_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, NULL, p_OBJECT_VERSION_NUMBER)
          ,decode( p_CUSTOMER_PRODUCT_ID, FND_API.G_MISS_NUM, NULL, p_CUSTOMER_PRODUCT_ID)
          ,decode( p_REFERENCE_NUMBER, FND_API.G_MISS_CHAR, NULL, p_REFERENCE_NUMBER));
End Insert_Row;

PROCEDURE Update_Row(
          p_MRO_SERIAL_NUMBER_ID    NUMBER
         ,p_REPAIR_GROUP_ID    NUMBER
         ,p_SERIAL_NUMBER    VARCHAR2
         ,p_VALIDATE_LEVEL    VARCHAR2
         ,p_CREATED_BY    NUMBER
         ,p_CREATION_DATE    DATE
         ,p_LAST_UPDATED_BY    NUMBER
         ,p_LAST_UPDATE_DATE    DATE
         ,p_LAST_UPDATE_LOGIN    NUMBER
         ,p_CONTEXT    VARCHAR2
         ,p_ATTRIBUTE1    VARCHAR2
         ,p_ATTRIBUTE2    VARCHAR2
         ,p_ATTRIBUTE3    VARCHAR2
         ,p_ATTRIBUTE4    VARCHAR2
         ,p_ATTRIBUTE5    VARCHAR2
         ,p_ATTRIBUTE6    VARCHAR2
         ,p_ATTRIBUTE7    VARCHAR2
         ,p_ATTRIBUTE8    VARCHAR2
         ,p_ATTRIBUTE9    VARCHAR2
         ,p_ATTRIBUTE10    VARCHAR2
         ,p_ATTRIBUTE11    VARCHAR2
         ,p_ATTRIBUTE12    VARCHAR2
         ,p_ATTRIBUTE13    VARCHAR2
         ,p_ATTRIBUTE14    VARCHAR2
         ,p_ATTRIBUTE15    VARCHAR2
         ,p_OBJECT_VERSION_NUMBER    NUMBER
         ,p_CUSTOMER_PRODUCT_ID     NUMBER
         ,p_REFERENCE_NUMBER VARCHAR2)

IS
BEGIN
    Update CSD_MRO_SERIAL_NUMBERS
    SET
        REPAIR_GROUP_ID = decode( p_REPAIR_GROUP_ID, FND_API.G_MISS_NUM, NULL, NULL, REPAIR_GROUP_ID, p_REPAIR_GROUP_ID)
       ,SERIAL_NUMBER = decode( p_SERIAL_NUMBER, FND_API.G_MISS_CHAR, NULL, NULL, SERIAL_NUMBER, p_SERIAL_NUMBER)
       ,validate_level = decode( p_VALIDATE_LEVEL, FND_API.G_MISS_CHAR, NULL, NULL, validate_level, p_VALIDATE_LEVEL)
       ,CREATED_BY = decode( p_CREATED_BY, FND_API.G_MISS_NUM, NULL, NULL, CREATED_BY, p_CREATED_BY)
       ,CREATION_DATE = decode( p_CREATION_DATE, FND_API.G_MISS_DATE, NULL, NULL, CREATION_DATE, p_CREATION_DATE)
       ,LAST_UPDATED_BY = decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, NULL, LAST_UPDATED_BY, p_LAST_UPDATED_BY)
       ,LAST_UPDATE_DATE = decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, NULL, NULL, LAST_UPDATE_DATE, p_LAST_UPDATE_DATE)
       ,LAST_UPDATE_LOGIN = decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, NULL, LAST_UPDATE_LOGIN, p_LAST_UPDATE_LOGIN)
       ,CONTEXT = decode( p_CONTEXT, FND_API.G_MISS_CHAR, NULL, NULL, CONTEXT, p_CONTEXT)
       ,ATTRIBUTE1 = decode( p_ATTRIBUTE1, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE1, p_ATTRIBUTE1)
       ,ATTRIBUTE2 = decode( p_ATTRIBUTE2, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE2, p_ATTRIBUTE2)
       ,ATTRIBUTE3 = decode( p_ATTRIBUTE3, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE3, p_ATTRIBUTE3)
       ,ATTRIBUTE4 = decode( p_ATTRIBUTE4, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE4, p_ATTRIBUTE4)
       ,ATTRIBUTE5 = decode( p_ATTRIBUTE5, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE5, p_ATTRIBUTE5)
       ,ATTRIBUTE6 = decode( p_ATTRIBUTE6, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE6, p_ATTRIBUTE6)
       ,ATTRIBUTE7 = decode( p_ATTRIBUTE7, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE7, p_ATTRIBUTE7)
       ,ATTRIBUTE8 = decode( p_ATTRIBUTE8, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE8, p_ATTRIBUTE8)
       ,ATTRIBUTE9 = decode( p_ATTRIBUTE9, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE9, p_ATTRIBUTE9)
       ,ATTRIBUTE10 = decode( p_ATTRIBUTE10, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE10, p_ATTRIBUTE10)
       ,ATTRIBUTE11 = decode( p_ATTRIBUTE11, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE11, p_ATTRIBUTE11)
       ,ATTRIBUTE12 = decode( p_ATTRIBUTE12, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE12, p_ATTRIBUTE12)
       ,ATTRIBUTE13 = decode( p_ATTRIBUTE13, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE13, p_ATTRIBUTE13)
       ,ATTRIBUTE14 = decode( p_ATTRIBUTE14, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE14, p_ATTRIBUTE14)
       ,ATTRIBUTE15 = decode( p_ATTRIBUTE15, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE15, p_ATTRIBUTE15)
       ,OBJECT_VERSION_NUMBER = decode( p_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, NULL, NULL, OBJECT_VERSION_NUMBER, p_OBJECT_VERSION_NUMBER)
       ,CUSTOMER_PRODUCT_ID = decode( p_CUSTOMER_PRODUCT_ID, FND_API.G_MISS_NUM, NULL, NULL, CUSTOMER_PRODUCT_ID, p_CUSTOMER_PRODUCT_ID)
       ,REFERENCE_NUMBER = decode( p_REFERENCE_NUMBER, FND_API.G_MISS_CHAR, NULL, NULL, REFERENCE_NUMBER, p_REFERENCE_NUMBER)
    where MRO_SERIAL_NUMBER_ID = p_MRO_SERIAL_NUMBER_ID;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
END Update_Row;

PROCEDURE Delete_Row(
    p_MRO_SERIAL_NUMBER_ID  NUMBER)
IS
BEGIN
    DELETE FROM CSD_MRO_SERIAL_NUMBERS
    WHERE MRO_SERIAL_NUMBER_ID = p_MRO_SERIAL_NUMBER_ID;
    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
END Delete_Row;

PROCEDURE Lock_Row(
          p_MRO_SERIAL_NUMBER_ID    NUMBER
         ,p_OBJECT_VERSION_NUMBER    NUMBER)

 IS
   CURSOR C IS
       SELECT *
       FROM CSD_MRO_SERIAL_NUMBERS
       WHERE MRO_SERIAL_NUMBER_ID =  p_MRO_SERIAL_NUMBER_ID
       FOR UPDATE of MRO_SERIAL_NUMBER_ID NOWAIT;
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

    IF (recinfo.object_version_number = p_OBJECT_VERSION_NUMBER) THEN
       NULL;
    ELSE
        fnd_message.set_name ('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;


END Lock_Row;

End CSD_MRO_SERIAL_NUMBERS_PKG;

/
