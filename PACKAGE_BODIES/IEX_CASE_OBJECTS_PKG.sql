--------------------------------------------------------
--  DDL for Package Body IEX_CASE_OBJECTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_CASE_OBJECTS_PKG" as
/* $Header: iextcobb.pls 120.0 2004/01/24 03:21:23 appldev noship $ */
--PG_DEBUG NUMBER(2) := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));
PG_DEBUG NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

procedure INSERT_ROW (
 X_ROWID                   in out NOCOPY VARCHAR2,
 X_CASE_OBJECT_ID          in NUMBER,
 X_object_id               in NUMBER,
 X_CAS_ID                  in NUMBER,
 X_OBJECT_CODE             in VARCHAR2,
 X_ACTIVE_FLAG             in VARCHAR2,
 X_OBJECT_VERSION_NUMBER   in NUMBER,
 X_REQUEST_ID              in  NUMBER,
 X_PROGRAM_APPLICATION_ID  in  NUMBER,
 X_PROGRAM_ID              in  NUMBER,
 X_PROGRAM_UPDATE_DATE     in  DATE,
 X_ATTRIBUTE_CATEGORY      in VARCHAR2,
 X_ATTRIBUTE1              in VARCHAR2,
 X_ATTRIBUTE2              in VARCHAR2,
 X_ATTRIBUTE3              in VARCHAR2,
 X_ATTRIBUTE4              in VARCHAR2,
 X_ATTRIBUTE5              in VARCHAR2,
 X_ATTRIBUTE6              in VARCHAR2,
 X_ATTRIBUTE7              in VARCHAR2,
 X_ATTRIBUTE8              in VARCHAR2,
 X_ATTRIBUTE9              in VARCHAR2,
 X_ATTRIBUTE10             in VARCHAR2,
 X_ATTRIBUTE11             in VARCHAR2,
 X_ATTRIBUTE12             in VARCHAR2,
 X_ATTRIBUTE13             in VARCHAR2,
 X_ATTRIBUTE14             in VARCHAR2,
 X_ATTRIBUTE15             in VARCHAR2,
 X_CREATION_DATE           in DATE,
 X_CREATED_BY              in NUMBER,
 X_LAST_UPDATE_DATE        in DATE,
 X_LAST_UPDATED_BY         in NUMBER,
 X_LAST_UPDATE_LOGIN       in NUMBER
) is
  cursor C is select ROWID from IEX_CASE_OBJECTS
    where  CASE_OBJECT_ID = X_CASE_OBJECT_ID   ;
begin
--   IF PG_DEBUG < 10  THEN
   IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      IEX_DEBUG_PUB.LogMessage ('********* Start of Procedure =>IEX_CASE_OBJECTS_PKG.INSERT_ROW ******** ');
   END IF;
   INSERT INTO IEX_CASE_OBJECTS(
           CASE_OBJECT_ID,
           object_id,
           OBJECT_CODE,
           ACTIVE_FLAG,
           OBJECT_VERSION_NUMBER,
           CAS_ID,
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
           LAST_UPDATE_LOGIN
          ) VALUES (
           X_CASE_OBJECT_ID,
           X_object_id,
           X_OBJECT_CODE,
           X_ACTIVE_FLAG,
           X_OBJECT_VERSION_NUMBER,
           X_CAS_ID,
           decode( x_REQUEST_ID, FND_API.G_MISS_NUM, NULL, x_REQUEST_ID),
           decode( x_PROGRAM_APPLICATION_ID, FND_API.G_MISS_NUM, NULL, x_PROGRAM_APPLICATION_ID),
           decode( x_PROGRAM_ID, FND_API.G_MISS_NUM, NULL, x_PROGRAM_ID),
           decode( x_PROGRAM_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), x_PROGRAM_UPDATE_DATE),
           decode( x_ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR, NULL, x_ATTRIBUTE_CATEGORY),
           decode( x_ATTRIBUTE1, FND_API.G_MISS_CHAR, NULL, x_ATTRIBUTE1),
           decode( x_ATTRIBUTE2, FND_API.G_MISS_CHAR, NULL, x_ATTRIBUTE2),
           decode( x_ATTRIBUTE3, FND_API.G_MISS_CHAR, NULL, x_ATTRIBUTE3),
           decode( x_ATTRIBUTE4, FND_API.G_MISS_CHAR, NULL, x_ATTRIBUTE4),
           decode( x_ATTRIBUTE5, FND_API.G_MISS_CHAR, NULL, x_ATTRIBUTE5),
           decode( x_ATTRIBUTE6, FND_API.G_MISS_CHAR, NULL, x_ATTRIBUTE6),
           decode( x_ATTRIBUTE7, FND_API.G_MISS_CHAR, NULL, x_ATTRIBUTE7),
           decode( x_ATTRIBUTE8, FND_API.G_MISS_CHAR, NULL, x_ATTRIBUTE8),
           decode( x_ATTRIBUTE9, FND_API.G_MISS_CHAR, NULL, x_ATTRIBUTE9),
           decode( x_ATTRIBUTE10, FND_API.G_MISS_CHAR, NULL, x_ATTRIBUTE10),
           decode( x_ATTRIBUTE11, FND_API.G_MISS_CHAR, NULL, x_ATTRIBUTE11),
           decode( x_ATTRIBUTE12, FND_API.G_MISS_CHAR, NULL, x_ATTRIBUTE12),
           decode( x_ATTRIBUTE13, FND_API.G_MISS_CHAR, NULL, x_ATTRIBUTE13),
           decode( x_ATTRIBUTE14, FND_API.G_MISS_CHAR, NULL, x_ATTRIBUTE14),
           decode( x_ATTRIBUTE15, FND_API.G_MISS_CHAR, NULL, x_ATTRIBUTE15),
           decode( x_CREATED_BY, FND_API.G_MISS_NUM, NULL, x_CREATED_BY),
           decode( x_CREATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), x_CREATION_DATE),
           decode( x_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, x_LAST_UPDATED_BY),
           decode( x_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), x_LAST_UPDATE_DATE),
           decode( x_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, x_LAST_UPDATE_LOGIN));


  open c;
  fetch c into X_ROWID;
--  IF PG_DEBUG < 10  THEN
  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
     IEX_DEBUG_PUB.LogMessage ('INSERT_ROW: ' || 'Value of ROWID = '||X_ROWID);
  END IF;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;
--  IF PG_DEBUG < 10  THEN
  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
     IEX_DEBUG_PUB.LogMessage ('********* End of Procedure =>IEX_CASE_OBJECTS_PKG.INSERT_ROW ******** ');
  END IF;
End Insert_Row;

PROCEDURE Update_Row(
 X_CASE_OBJECT_ID          in NUMBER,
 X_object_id               in NUMBER,
 X_CAS_ID                  in NUMBER,
 X_OBJECT_CODE             in VARCHAR2,
 X_ACTIVE_FLAG             in VARCHAR2,
 X_OBJECT_VERSION_NUMBER   in NUMBER,
 X_REQUEST_ID              in  NUMBER,
 X_PROGRAM_APPLICATION_ID  in  NUMBER,
 X_PROGRAM_ID              in  NUMBER,
 X_PROGRAM_UPDATE_DATE     in  DATE,
 X_ATTRIBUTE_CATEGORY      in VARCHAR2,
 X_ATTRIBUTE1              in VARCHAR2,
 X_ATTRIBUTE2              in VARCHAR2,
 X_ATTRIBUTE3              in VARCHAR2,
 X_ATTRIBUTE4              in VARCHAR2,
 X_ATTRIBUTE5              in VARCHAR2,
 X_ATTRIBUTE6              in VARCHAR2,
 X_ATTRIBUTE7              in VARCHAR2,
 X_ATTRIBUTE8              in VARCHAR2,
 X_ATTRIBUTE9              in VARCHAR2,
 X_ATTRIBUTE10             in VARCHAR2,
 X_ATTRIBUTE11             in VARCHAR2,
 X_ATTRIBUTE12             in VARCHAR2,
 X_ATTRIBUTE13             in VARCHAR2,
 X_ATTRIBUTE14             in VARCHAR2,
 X_ATTRIBUTE15             in VARCHAR2,
 X_LAST_UPDATE_DATE        in DATE,
 X_LAST_UPDATED_BY         in NUMBER,
 X_LAST_UPDATE_LOGIN       in NUMBER) is
 BEGIN
--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       IEX_DEBUG_PUB.LogMessage ('********* Start of Procedure =>IEX_CASE_OBJECTS_PKG.UPDATE_ROW ******** ');
    END IF;
    Update IEX_CASE_OBJECTS
    SET
              object_id = decode( x_object_id, FND_API.G_MISS_NUM, object_id, x_object_id),
              OBJECT_CODE = decode( x_OBJECT_CODE, FND_API.G_MISS_CHAR, OBJECT_CODE, x_OBJECT_CODE),
              ACTIVE_FLAG = decode( x_ACTIVE_FLAG, FND_API.G_MISS_CHAR, ACTIVE_FLAG, x_ACTIVE_FLAG),
              OBJECT_VERSION_NUMBER = decode( x_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, OBJECT_VERSION_NUMBER, x_OBJECT_VERSION_NUMBER),
              CAS_ID = decode( x_CAS_ID, FND_API.G_MISS_NUM, CAS_ID, x_CAS_ID),
              REQUEST_ID = decode( x_REQUEST_ID, FND_API.G_MISS_NUM, REQUEST_ID, x_REQUEST_ID),
              PROGRAM_APPLICATION_ID = decode( x_PROGRAM_APPLICATION_ID, FND_API.G_MISS_NUM, PROGRAM_APPLICATION_ID, x_PROGRAM_APPLICATION_ID),
              PROGRAM_ID = decode( x_PROGRAM_ID, FND_API.G_MISS_NUM, PROGRAM_ID, x_PROGRAM_ID),
              PROGRAM_UPDATE_DATE = decode( x_PROGRAM_UPDATE_DATE, FND_API.G_MISS_DATE, PROGRAM_UPDATE_DATE, x_PROGRAM_UPDATE_DATE),
              ATTRIBUTE_CATEGORY = decode( x_ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR, ATTRIBUTE_CATEGORY, x_ATTRIBUTE_CATEGORY),
              ATTRIBUTE1 = decode( x_ATTRIBUTE1, FND_API.G_MISS_CHAR, ATTRIBUTE1, x_ATTRIBUTE1),
              ATTRIBUTE2 = decode( x_ATTRIBUTE2, FND_API.G_MISS_CHAR, ATTRIBUTE2, x_ATTRIBUTE2),
              ATTRIBUTE3 = decode( x_ATTRIBUTE3, FND_API.G_MISS_CHAR, ATTRIBUTE3, x_ATTRIBUTE3),
              ATTRIBUTE4 = decode( x_ATTRIBUTE4, FND_API.G_MISS_CHAR, ATTRIBUTE4, x_ATTRIBUTE4),
              ATTRIBUTE5 = decode( x_ATTRIBUTE5, FND_API.G_MISS_CHAR, ATTRIBUTE5, x_ATTRIBUTE5),
              ATTRIBUTE6 = decode( x_ATTRIBUTE6, FND_API.G_MISS_CHAR, ATTRIBUTE6, x_ATTRIBUTE6),
              ATTRIBUTE7 = decode( x_ATTRIBUTE7, FND_API.G_MISS_CHAR, ATTRIBUTE7, x_ATTRIBUTE7),
              ATTRIBUTE8 = decode( x_ATTRIBUTE8, FND_API.G_MISS_CHAR, ATTRIBUTE8, x_ATTRIBUTE8),
              ATTRIBUTE9 = decode( x_ATTRIBUTE9, FND_API.G_MISS_CHAR, ATTRIBUTE9, x_ATTRIBUTE9),
              ATTRIBUTE10 = decode( x_ATTRIBUTE10, FND_API.G_MISS_CHAR, ATTRIBUTE10, x_ATTRIBUTE10),
              ATTRIBUTE11 = decode( x_ATTRIBUTE11, FND_API.G_MISS_CHAR, ATTRIBUTE11, x_ATTRIBUTE11),
              ATTRIBUTE12 = decode( x_ATTRIBUTE12, FND_API.G_MISS_CHAR, ATTRIBUTE12, x_ATTRIBUTE12),
              ATTRIBUTE13 = decode( x_ATTRIBUTE13, FND_API.G_MISS_CHAR, ATTRIBUTE13, x_ATTRIBUTE13),
              ATTRIBUTE14 = decode( x_ATTRIBUTE14, FND_API.G_MISS_CHAR, ATTRIBUTE14, x_ATTRIBUTE14),
              ATTRIBUTE15 = decode( x_ATTRIBUTE15, FND_API.G_MISS_CHAR, ATTRIBUTE15, x_ATTRIBUTE15),
              LAST_UPDATED_BY = decode( x_LAST_UPDATED_BY, FND_API.G_MISS_NUM, LAST_UPDATED_BY, x_LAST_UPDATED_BY),
              LAST_UPDATE_DATE = decode( x_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, LAST_UPDATE_DATE, x_LAST_UPDATE_DATE),
              LAST_UPDATE_LOGIN = decode( x_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, LAST_UPDATE_LOGIN, x_LAST_UPDATE_LOGIN)
    where CASE_OBJECT_ID = x_CASE_OBJECT_ID;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       IEX_DEBUG_PUB.LogMessage ('Update_Row: ' || '********* End of Procedure =>IEX_CASE_OBJECTS_PKG.INSERT_ROW ******** ');
    END IF;
END Update_Row;

PROCEDURE Delete_Row(
    X_CASE_OBJECT_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM IEX_CASE_OBJECTS
    WHERE CASE_OBJECT_ID = X_CASE_OBJECT_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;

 procedure LOCK_ROW (
  X_CASE_OBJECT_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER
) is
  cursor c is select OBJECT_VERSION_NUMBER
    from IEX_CASE_OBJECTS
    where CASE_OBJECT_ID = X_CASE_OBJECT_ID
    and OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER
    for update of CASE_OBJECT_ID nowait;
  recinfo c%rowtype;


begin
--  IF PG_DEBUG < 10  THEN
  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
     IEX_DEBUG_PUB.LogMessage ('********* Start of Procedure =>IEX_CASE_OBJECTS_PKG.LOCK_ROW ******** ');
  END IF;
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;

  close c;

  if recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
--  IF PG_DEBUG < 10  THEN
  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
     IEX_DEBUG_PUB.LogMessage ('LOCK_ROW: ' || '********* End of Procedure =>IEX_CASE_OBJECTS_PKG.INSERT_ROW ******** ');
  END IF;
end LOCK_ROW;


/*PROCEDURE Lock_Row(
          p_CASE_OBJECT_ID    NUMBER,
          p_object_id    NUMBER,
          p_OBJECT_CODE    VARCHAR2,
          p_ACTIVE_FLAG    VARCHAR2,
          p_OBJECT_VERSION_NUMBER    NUMBER,
          p_CAS_ID    NUMBER,
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
          p_LAST_UPDATE_LOGIN    NUMBER)

 IS
   CURSOR C IS
        SELECT *
         FROM IEX_CASE_OBJECTS
        WHERE CASE_OBJECT_ID =  p_CASE_OBJECT_ID
        FOR UPDATE of CASE_OBJECT_ID NOWAIT;
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
           (      Recinfo.CASE_OBJECT_ID = p_CASE_OBJECT_ID)
       AND (    ( Recinfo.object_id = p_object_id)
            OR (    ( Recinfo.object_id IS NULL )
                AND (  p_object_id IS NULL )))
       AND (    ( Recinfo.OBJECT_CODE = p_OBJECT_CODE)
            OR (    ( Recinfo.OBJECT_CODE IS NULL )
                AND (  p_OBJECT_CODE IS NULL )))
       AND (    ( Recinfo.ACTIVE_FLAG = p_ACTIVE_FLAG)
            OR (    ( Recinfo.ACTIVE_FLAG IS NULL )
                AND (  p_ACTIVE_FLAG IS NULL )))
       AND (    ( Recinfo.OBJECT_VERSION_NUMBER = p_OBJECT_VERSION_NUMBER)
            OR (    ( Recinfo.OBJECT_VERSION_NUMBER IS NULL )
                AND (  p_OBJECT_VERSION_NUMBER IS NULL )))
       AND (    ( Recinfo.CAS_ID = p_CAS_ID)
            OR (    ( Recinfo.CAS_ID IS NULL )
                AND (  p_CAS_ID IS NULL )))
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
       ) then
       return;
   else
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   End If;
END Lock_Row;
*/

End IEX_CASE_OBJECTS_PKG;

/
