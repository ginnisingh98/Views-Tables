--------------------------------------------------------
--  DDL for Package Body IEX_CASE_CONTACTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_CASE_CONTACTS_PKG" as
/* $Header: iextconb.pls 120.0 2004/01/24 03:21:26 appldev noship $ */
-- Start of Comments
-- Package name     : IEX_CASE_CONTACTS_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'IEX_CASE_CONTACTS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'iextconb.pls';

--PG_DEBUG NUMBER(2) := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));
PG_DEBUG NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

PROCEDURE Insert_Row(
          X_ROWID                  in out NOCOPY VARCHAR2,
          p_CAS_CONTACT_ID         IN  NUMBER,
          p_CAS_ID                 IN NUMBER,
          p_CONTACT_PARTY_ID       IN NUMBER,
          p_OBJECT_VERSION_NUMBER  IN NUMBER,
          p_address_id             IN NUMBER,
          p_phone_id               IN NUMBER,
          p_active_flag            IN VARCHAR2,
          p_REQUEST_ID             IN NUMBER,
          p_PROGRAM_APPLICATION_ID IN NUMBER,
          p_PROGRAM_ID             IN NUMBER,
          p_PROGRAM_UPDATE_DATE    IN DATE,
          p_ATTRIBUTE_CATEGORY     IN VARCHAR2,
          p_ATTRIBUTE1             IN VARCHAR2,
          p_ATTRIBUTE2             IN VARCHAR2,
          p_ATTRIBUTE3             IN VARCHAR2,
          p_ATTRIBUTE4             IN VARCHAR2,
          p_ATTRIBUTE5             IN VARCHAR2,
          p_ATTRIBUTE6             IN VARCHAR2,
          p_ATTRIBUTE7             IN VARCHAR2,
          p_ATTRIBUTE8             IN VARCHAR2,
          p_ATTRIBUTE9             IN VARCHAR2,
          p_ATTRIBUTE10            IN VARCHAR2,
          p_ATTRIBUTE11            IN VARCHAR2,
          p_ATTRIBUTE12            IN VARCHAR2,
          p_ATTRIBUTE13            IN VARCHAR2,
          p_ATTRIBUTE14            IN VARCHAR2,
          p_ATTRIBUTE15            IN VARCHAR2,
          p_CREATED_BY             IN VARCHAR2,
          p_CREATION_DATE          IN DATE,
          p_LAST_UPDATED_BY        IN NUMBER,
          p_LAST_UPDATE_DATE       IN DATE,
          p_LAST_UPDATE_LOGIN      IN NUMBER,
          P_PRIMARY_FLAG           IN VARCHAR2 )

 IS
    cursor C is select ROWID from IEX_CASE_CONTACTS
    where  cas_contact_id = p_cas_contact_id   ;

BEGIN
--  IF PG_DEBUG < 10  THEN
  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
     IEX_DEBUG_PUB.LogMessage ('********* Start of Procedure =>IEX_CASE_CONTACTS_PKG.INSERT_ROW ******** ');
  END IF;
   INSERT INTO IEX_CASE_CONTACTS(
           CAS_CONTACT_ID,
           CAS_ID,
           CONTACT_PARTY_ID,
           OBJECT_VERSION_NUMBER,
           active_flag,
           ADDRESS_ID,
           PHONE_ID,
           REQUEST_ID,
           PROGRAM_APPLICATION_ID,
           PROGRAM_ID,
           PROGRAM_UPDATE_DATE,
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
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           PRIMARY_FLAG
          ) VALUES (
           p_CAS_CONTACT_ID,
           p_cas_id,
           p_contact_party_id,
           p_object_version_number,
           p_active_flag,
           decode( p_address_ID, FND_API.G_MISS_NUM, NULL, p_address_ID),
           decode( p_PHONE_ID, FND_API.G_MISS_NUM, NULL, p_PHONE_ID),
           decode( p_REQUEST_ID, FND_API.G_MISS_NUM, NULL, p_REQUEST_ID),
           decode( p_PROGRAM_APPLICATION_ID, FND_API.G_MISS_NUM, NULL, p_PROGRAM_APPLICATION_ID),
           decode( p_PROGRAM_ID, FND_API.G_MISS_NUM, NULL, p_PROGRAM_ID),
           decode( p_PROGRAM_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_PROGRAM_UPDATE_DATE),
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
           decode( p_CREATED_BY, FND_API.G_MISS_NUM, NULL, p_CREATED_BY),
           decode( p_CREATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_CREATION_DATE),
           decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATED_BY),
           decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_LAST_UPDATE_DATE),
           decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATE_LOGIN),
           p_primary_flag);
   open c;
   fetch c into X_ROWID;
--   IF PG_DEBUG < 10  THEN
   IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      IEX_DEBUG_PUB.LogMessage ('Insert_Row: ' || 'Value of ROWID = '||X_ROWID);
   END IF;
   if (c%notfound) then
       close c;
   raise no_data_found;
   end if;
   close c;
--  IF PG_DEBUG < 10  THEN
  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
     IEX_DEBUG_PUB.LogMessage ('********* End of Procedure =>IEX_CASE_CONTACTS_PKG.INSERT_ROW ******** ');
  END IF;

End Insert_Row;

PROCEDURE Update_Row(
          p_CAS_CONTACT_ID         IN NUMBER,
          p_CAS_ID                 IN NUMBER,
          p_CONTACT_PARTY_ID       IN NUMBER,
          p_OBJECT_VERSION_NUMBER  IN NUMBER,
          p_address_id             IN NUMBER,
          p_phone_id               IN NUMBER,
          p_active_flag            IN VARCHAR2,
          p_REQUEST_ID             IN NUMBER,
          p_PROGRAM_APPLICATION_ID IN NUMBER,
          p_PROGRAM_ID             IN NUMBER,
          p_PROGRAM_UPDATE_DATE    IN DATE,
          p_ATTRIBUTE_CATEGORY     IN VARCHAR2,
          p_ATTRIBUTE1             IN VARCHAR2,
          p_ATTRIBUTE2             IN VARCHAR2,
          p_ATTRIBUTE3             IN VARCHAR2,
          p_ATTRIBUTE4             IN VARCHAR2,
          p_ATTRIBUTE5             IN VARCHAR2,
          p_ATTRIBUTE6             IN VARCHAR2,
          p_ATTRIBUTE7             IN VARCHAR2,
          p_ATTRIBUTE8             IN VARCHAR2,
          p_ATTRIBUTE9             IN VARCHAR2,
          p_ATTRIBUTE10            IN VARCHAR2,
          p_ATTRIBUTE11            IN VARCHAR2,
          p_ATTRIBUTE12            IN VARCHAR2,
          p_ATTRIBUTE13            IN VARCHAR2,
          p_ATTRIBUTE14            IN VARCHAR2,
          p_ATTRIBUTE15            IN VARCHAR2,
          p_LAST_UPDATED_BY        IN NUMBER,
          p_LAST_UPDATE_DATE       IN DATE,
          p_LAST_UPDATE_LOGIN      IN NUMBER,
          P_PRIMARY_FLAG           IN VARCHAR2 )

 IS
 BEGIN
--   IF PG_DEBUG < 10  THEN
   IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      IEX_DEBUG_PUB.LogMessage ('********* Start of Procedure =>IEX_CASE_CONTACTS_PKG.UPDATE_ROW ******** ');
   END IF;
    Update IEX_CASE_CONTACTS
    SET
              CAS_ID = decode( p_CAS_ID, FND_API.G_MISS_NUM, CAS_ID, p_CAS_ID),
              CONTACT_PARTY_ID = decode( p_CONTACT_PARTY_ID, FND_API.G_MISS_NUM, CONTACT_PARTY_ID, p_CONTACT_PARTY_ID),
              OBJECT_VERSION_NUMBER = decode( p_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, OBJECT_VERSION_NUMBER, p_OBJECT_VERSION_NUMBER),
              active_flag = decode( p_active_flag, FND_API.G_MISS_CHAR, active_flag, p_active_flag),
              ADDRESS_ID = decode( p_ADDRESS_ID, FND_API.G_MISS_NUM, ADDRESS_ID, p_ADDRESS_ID),
              PHONE_ID = decode( p_PHONE_ID, FND_API.G_MISS_NUM, PHONE_ID, p_PHONE_ID),
              REQUEST_ID = decode( p_REQUEST_ID, FND_API.G_MISS_NUM, REQUEST_ID, p_REQUEST_ID),
              PROGRAM_APPLICATION_ID = decode( p_PROGRAM_APPLICATION_ID, FND_API.G_MISS_NUM, PROGRAM_APPLICATION_ID, p_PROGRAM_APPLICATION_ID),
              PROGRAM_ID = decode( p_PROGRAM_ID, FND_API.G_MISS_NUM, PROGRAM_ID, p_PROGRAM_ID),
              PROGRAM_UPDATE_DATE = decode( p_PROGRAM_UPDATE_DATE, FND_API.G_MISS_DATE, PROGRAM_UPDATE_DATE, p_PROGRAM_UPDATE_DATE),
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
              LAST_UPDATED_BY = decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, LAST_UPDATED_BY, p_LAST_UPDATED_BY),
              LAST_UPDATE_DATE = decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, LAST_UPDATE_DATE, p_LAST_UPDATE_DATE),
              LAST_UPDATE_LOGIN = decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, LAST_UPDATE_LOGIN, p_LAST_UPDATE_LOGIN),
              primary_flag = decode( p_primary_flag, FND_API.G_MISS_CHAR, primary_flag, p_primary_flag)
    where CAS_CONTACT_ID = p_CAS_CONTACT_ID;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       IEX_DEBUG_PUB.LogMessage ('********* End of Procedure =>IEX_CASE_CONTACTS_PKG.UPDATE_ROW ******** ');
    END IF;
END Update_Row;

PROCEDURE Delete_Row(
    p_CAS_CONTACT_ID  IN NUMBER)
 IS
 BEGIN
   DELETE FROM IEX_CASE_CONTACTS
    WHERE CAS_CONTACT_ID = p_CAS_CONTACT_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;

procedure LOCK_ROW (
  p_cas_contact_id in NUMBER,
  p_OBJECT_VERSION_NUMBER in NUMBER
) is
  cursor c is select OBJECT_VERSION_NUMBER
    from IEX_CASE_CONTACTS
    where cas_contact_id = p_cas_contact_id
    and OBJECT_VERSION_NUMBER = p_OBJECT_VERSION_NUMBER
    for update of cas_contact_id nowait;
  recinfo c%rowtype;


begin
-- IF PG_DEBUG < 10  THEN
 IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    IEX_DEBUG_PUB.LogMessage ('********* Start of Procedure =>IEX_CASE_CONTACTS_PKG.LOCK_ROW ******** ');
 END IF;
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;

  close c;

  if recinfo.OBJECT_VERSION_NUMBER = p_OBJECT_VERSION_NUMBER then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
--IF PG_DEBUG < 10  THEN
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
   IEX_DEBUG_PUB.LogMessage ('********* End of Procedure =>IEX_CASE_CONTACTS_PKG.LOCK_ROW ******** ');
END IF;
end LOCK_ROW;

/*PROCEDURE Lock_Row(
          p_CAS_CONTACT_ID    NUMBER,
          p_CAS_ID    NUMBER,
          p_CONTACT_PARTY_ID    NUMBER,
          p_OBJECT_VERSION_NUMBER    NUMBER,
          p_CONTACT_SEQUENCE    NUMBER,
          p_REQUEST_ID    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_UPDATE_DATE    DATE,
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
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN      IN NUMBER,
          P_PRIMARY_FLAG           IN VARCHAR2 )

 IS
   CURSOR C IS
        SELECT *
         FROM IEX_CASE_CONTACTS
        WHERE CAS_CONTACT_ID =  p_CAS_CONTACT_ID
        FOR UPDATE of CAS_CONTACT_ID NOWAIT;
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
           (      Recinfo.CAS_CONTACT_ID = p_CAS_CONTACT_ID)
       AND (    ( Recinfo.CAS_ID = p_CAS_ID)
            OR (    ( Recinfo.CAS_ID IS NULL )
                AND (  p_CAS_ID IS NULL )))
       AND (    ( Recinfo.CONTACT_PARTY_ID = p_CONTACT_PARTY_ID)
            OR (    ( Recinfo.CONTACT_PARTY_ID IS NULL )
                AND (  p_CONTACT_PARTY_ID IS NULL )))
       AND (    ( Recinfo.OBJECT_VERSION_NUMBER = p_OBJECT_VERSION_NUMBER)
            OR (    ( Recinfo.OBJECT_VERSION_NUMBER IS NULL )
                AND (  p_OBJECT_VERSION_NUMBER IS NULL )))
       AND (    ( Recinfo.active_flag = p_active_flag)
            OR (    ( Recinfo.active_flag IS NULL )
                AND (  p_active_flag IS NULL )))
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
       AND (    ( Recinfo.primary_flag = p_primary_flag)
            OR (    ( Recinfo.primary_flag IS NULL )
                AND (  p_primary_flag IS NULL )))

       ) then
       return;
   else
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   End If;
END Lock_Row;
*/

End IEX_CASE_CONTACTS_PKG;

/
