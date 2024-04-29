--------------------------------------------------------
--  DDL for Package Body IEX_COSTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_COSTS_PKG" as
/* $Header: iextcosb.pls 120.0 2004/01/24 03:21:30 appldev noship $ */
-- Start of Comments
-- Package name     : IEX_COSTS_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'IEX_COSTS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'iextcosb.pls';

--PG_DEBUG NUMBER(2) := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));
PG_DEBUG NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

PROCEDURE Insert_Row(
          X_ROWID                   in out NOCOPY VARCHAR2,
          p_COST_ID                 IN NUMBER,
          p_CASE_ID                 IN NUMBER,
          p_DELINQUENCY_ID          IN NUMBER,
          p_COST_TYPE_CODE          IN VARCHAR2,
          p_COST_ITEM_TYPE_CODE     IN VARCHAR2,
          p_COST_ITEM_TYPE_DESC     IN VARCHAR2,
          p_COST_ITEM_AMOUNT        IN NUMBER,
          p_COST_ITEM_CURRENCY_CODE IN VARCHAR2,
          p_COST_ITEM_QTY           IN NUMBER,
          p_COST_ITEM_DATE          IN DATE,
          p_FUNCTIONAL_AMOUNT       IN NUMBER,
          p_EXCHANGE_TYPE           IN VARCHAR2,
          p_EXCHANGE_RATE           IN NUMBER,
          p_EXCHANGE_DATE           IN DATE,
          p_OBJECT_VERSION_NUMBER   IN NUMBER,
          P_COST_ITEM_APPROVED      IN VARCHAR2,
          p_active_flag             IN VARCHAR2,
          p_REQUEST_ID              IN NUMBER,
          p_PROGRAM_APPLICATION_ID  IN NUMBER,
          p_PROGRAM_ID              IN NUMBER,
          p_PROGRAM_UPDATE_DATE     IN DATE,
          p_ATTRIBUTE_CATEGORY      IN VARCHAR2,
          p_ATTRIBUTE1              IN VARCHAR2,
          p_ATTRIBUTE2              IN VARCHAR2,
          p_ATTRIBUTE3              IN VARCHAR2,
          p_ATTRIBUTE4              IN VARCHAR2,
          p_ATTRIBUTE5              IN VARCHAR2,
          p_ATTRIBUTE6              IN VARCHAR2,
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
          p_LAST_UPDATE_LOGIN      IN NUMBER
)

 IS
   cursor C is select ROWID from IEX_COSTS
    where  cost_id = p_cost_id;

BEGIN
--  IF PG_DEBUG < 10  THEN
  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
     IEX_DEBUG_PUB.LogMessage ('********* Start of Procedure =>IEX_COSTS_PKG.INSERT_ROW ******** ');
  END IF;

   INSERT INTO IEX_COSTS(
           COST_ID,
           CASE_ID,
           DELINQUENCY_ID,
           COST_TYPE_CODE,
           COST_ITEM_TYPE_CODE,
           COST_ITEM_TYPE_DESC,
           COST_ITEM_AMOUNT,
           COST_ITEM_CURRENCY_CODE,
           COST_ITEM_QTY,
           COST_ITEM_DATE,
           FUNCTIONAL_AMOUNT,
           EXCHANGE_TYPE,
           EXCHANGE_RATE,
           EXCHANGE_DATE,
           COST_ITEM_APPROVED,
           ACTIVE_FLAG,
           OBJECT_VERSION_NUMBER,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
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
           LAST_UPDATE_LOGIN
          ) VALUES (
           p_COST_ID,
           decode( p_CASE_ID, FND_API.G_MISS_NUM, NULL, p_CASE_ID),
           decode( p_DELINQUENCY_ID, FND_API.G_MISS_NUM, NULL, p_DELINQUENCY_ID),
           p_COST_TYPE_CODE,
           p_COST_ITEM_TYPE_CODE,
           decode( p_COST_ITEM_TYPE_DESC, FND_API.G_MISS_CHAR, NULL, p_COST_ITEM_TYPE_DESC),
           decode( p_COST_ITEM_AMOUNT, FND_API.G_MISS_NUM, NULL, p_COST_ITEM_AMOUNT),
           decode( p_COST_ITEM_CURRENCY_CODE, FND_API.G_MISS_CHAR, NULL, p_COST_ITEM_CURRENCY_CODE),
           decode( p_COST_ITEM_QTY, FND_API.G_MISS_NUM, NULL, p_COST_ITEM_QTY),
           decode( p_COST_ITEM_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_COST_ITEM_DATE),
           decode( p_FUNCTIONAL_AMOUNT, FND_API.G_MISS_NUM, NULL,  p_FUNCTIONAL_AMOUNT),
           decode( p_EXCHANGE_TYPE, FND_API.G_MISS_CHAR, NULL, p_EXCHANGE_TYPE),
           decode( p_EXCHANGE_RATE, FND_API.G_MISS_NUM, NULL,  p_EXCHANGE_RATE),
           decode( p_EXCHANGE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_EXCHANGE_DATE),
           P_COST_ITEM_APPROVED,
           p_ACTIVE_FLAG,
           p_OBJECT_VERSION_NUMBER,
           decode( p_CREATED_BY, FND_API.G_MISS_NUM, NULL, p_CREATED_BY),
           decode( p_CREATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_CREATION_DATE),
           decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATED_BY),
           decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_LAST_UPDATE_DATE),
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
           decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATE_LOGIN));
           open c;
           fetch c into X_ROWID;
--           IF PG_DEBUG < 10  THEN
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
     IEX_DEBUG_PUB.LogMessage ('********* End of Procedure =>IEX_COSTS_PKG.INSERT_ROW ******** ');
  END IF;
End Insert_Row;

PROCEDURE Update_Row(
          p_COST_ID                 IN NUMBER,
          p_CASE_ID                 IN NUMBER,
          p_DELINQUENCY_ID          IN NUMBER,
          p_COST_TYPE_CODE          IN VARCHAR2,
          p_COST_ITEM_TYPE_CODE     IN VARCHAR2,
          p_COST_ITEM_TYPE_DESC     IN VARCHAR2,
          p_COST_ITEM_AMOUNT        IN NUMBER,
          p_COST_ITEM_CURRENCY_CODE IN VARCHAR2,
          p_COST_ITEM_QTY           IN NUMBER,
          p_COST_ITEM_DATE          IN DATE,
          p_FUNCTIONAL_AMOUNT       IN NUMBER,
          p_EXCHANGE_TYPE           IN VARCHAR2,
          p_EXCHANGE_RATE           IN NUMBER,
          p_EXCHANGE_DATE           IN DATE,
          p_OBJECT_VERSION_NUMBER   IN NUMBER,
          P_COST_ITEM_APPROVED      IN VARCHAR2,
          p_active_flag             IN VARCHAR2,
          p_REQUEST_ID              IN NUMBER,
          p_PROGRAM_APPLICATION_ID  IN NUMBER,
          p_PROGRAM_ID              IN NUMBER,
          p_PROGRAM_UPDATE_DATE     IN DATE,
          p_ATTRIBUTE_CATEGORY      IN VARCHAR2,
          p_ATTRIBUTE1              IN VARCHAR2,
          p_ATTRIBUTE2              IN VARCHAR2,
          p_ATTRIBUTE3              IN VARCHAR2,
          p_ATTRIBUTE4              IN VARCHAR2,
          p_ATTRIBUTE5              IN VARCHAR2,
          p_ATTRIBUTE6              IN VARCHAR2,
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
          p_LAST_UPDATE_LOGIN      IN NUMBER
)

 IS
 BEGIN
--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       IEX_DEBUG_PUB.LogMessage ('********* Start of Procedure =>IEX_COSTS_PKG.UPDATE_ROW ******** ');
    END IF;
    Update IEX_COSTS
    SET
              CASE_ID = decode( p_CASE_ID, FND_API.G_MISS_NUM, CASE_ID, p_CASE_ID),
              DELINQUENCY_ID = decode( p_DELINQUENCY_ID, FND_API.G_MISS_NUM, DELINQUENCY_ID, p_DELINQUENCY_ID),
              COST_TYPE_CODE = decode( p_COST_TYPE_CODE, FND_API.G_MISS_CHAR, COST_TYPE_CODE, p_COST_TYPE_CODE),
              COST_ITEM_TYPE_CODE = decode( p_COST_ITEM_TYPE_CODE, FND_API.G_MISS_CHAR, COST_ITEM_TYPE_CODE, p_COST_ITEM_TYPE_CODE),
              COST_ITEM_TYPE_DESC = decode( p_COST_ITEM_TYPE_DESC, FND_API.G_MISS_CHAR, COST_ITEM_TYPE_DESC, p_COST_ITEM_TYPE_DESC),
              COST_ITEM_AMOUNT = decode( p_COST_ITEM_AMOUNT, FND_API.G_MISS_NUM, COST_ITEM_AMOUNT, p_COST_ITEM_AMOUNT),
              COST_ITEM_CURRENCY_CODE = decode( p_COST_ITEM_CURRENCY_CODE, FND_API.G_MISS_CHAR, COST_ITEM_CURRENCY_CODE, p_COST_ITEM_CURRENCY_CODE),
              COST_ITEM_QTY = decode( p_COST_ITEM_QTY, FND_API.G_MISS_NUM, COST_ITEM_QTY, p_COST_ITEM_QTY),
              COST_ITEM_DATE = decode( p_COST_ITEM_DATE, FND_API.G_MISS_DATE, COST_ITEM_DATE, p_COST_ITEM_DATE),
              FUNCTIONAL_AMOUNT = decode( p_FUNCTIONAL_AMOUNT, FND_API.G_MISS_NUM, FUNCTIONAL_AMOUNT, p_FUNCTIONAL_AMOUNT),
              EXCHANGE_TYPE = decode( p_EXCHANGE_TYPE, FND_API.G_MISS_CHAR, EXCHANGE_TYPE, p_EXCHANGE_TYPE),
              EXCHANGE_RATE = decode( p_EXCHANGE_RATE, FND_API.G_MISS_NUM, EXCHANGE_RATE, p_EXCHANGE_RATE),
              EXCHANGE_DATE = decode( p_EXCHANGE_DATE, FND_API.G_MISS_DATE, EXCHANGE_DATE, p_EXCHANGE_DATE),
              COST_ITEM_APPROVED = decode( p_COST_ITEM_APPROVED, FND_API.G_MISS_CHAR, COST_ITEM_APPROVED, p_COST_ITEM_APPROVED),
              ACTIVE_FLAG = decode( p_ACTIVE_FLAG, FND_API.G_MISS_CHAR, ACTIVE_FLAG, p_ACTIVE_FLAG),
              OBJECT_VERSION_NUMBER = decode( p_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, OBJECT_VERSION_NUMBER, p_OBJECT_VERSION_NUMBER),
              LAST_UPDATED_BY = decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, LAST_UPDATED_BY, p_LAST_UPDATED_BY),
              LAST_UPDATE_DATE = decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, LAST_UPDATE_DATE, p_LAST_UPDATE_DATE),
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
              LAST_UPDATE_LOGIN = decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, LAST_UPDATE_LOGIN, p_LAST_UPDATE_LOGIN)
    where COST_ID = p_COST_ID;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           IEX_DEBUG_PUB.LogMessage ('********* End of Procedure =>IEX_COSTS_PKG.UPDATE_ROW ******** ');
        END IF;
END Update_Row;

PROCEDURE Delete_Row(
    p_COST_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM IEX_COSTS
    WHERE COST_ID = p_COST_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;

procedure LOCK_ROW (
  p_COST_ID               in NUMBER,
  p_OBJECT_VERSION_NUMBER in NUMBER)
  IS
    cursor c is select OBJECT_VERSION_NUMBER
    from IEX_COSTS
    where cost_id = p_cost_id
    and OBJECT_VERSION_NUMBER = p_OBJECT_VERSION_NUMBER
    for update of cost_id nowait;
  recinfo c%rowtype;
Begin
-- IF PG_DEBUG < 10  THEN
 IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    IEX_DEBUG_PUB.LogMessage ('********* Start of Procedure =>IEX_COSTS_PKG.LOCK_ROW ******** ');
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
--  IF PG_DEBUG < 10  THEN
  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
     IEX_DEBUG_PUB.LogMessage ('********* End of Procedure =>IEX_COSTS_PKG.LOCK_ROW ******** ');
  END IF;
end LOCK_ROW;




/*
PROCEDURE Lock_Row(
          p_CASE_ID                 IN NUMBER,
          p_DELINQUENCY_ID          IN NUMBER,
          p_COST_TYPE_CODE          IN VARCHAR2,
          p_COST_ITEM_TYPE_CODE     IN VARCHAR2,
          p_COST_ITEM_TYPE_DESC     IN VARCHAR2,
          p_COST_ITEM_AMOUNT        IN NUMBER,
          p_COST_ITEM_CURRENCY_CODE IN VARCHAR2,
          p_COST_ITEM_QTY           IN NUMBER,
          p_COST_ITEM_DATE          IN DATE,
          p_FUNCTIONAL_AMOUNT       IN NUMBER,
          p_EXCHANGE_TYPE           IN VARCHAR2,
          p_EXCHANGE_RATE           IN NUMBER,
          p_EXCHANGE_DATE           IN DATE,
          p_OBJECT_VERSION_NUMBER   IN NUMBER,
          p_COST_ITEM_APPROVED      IN VARCHAR2,
          p_active_flag             IN VARCHAR2,
          p_REQUEST_ID              IN NUMBER,
          p_PROGRAM_APPLICATION_ID  IN NUMBER,
          p_PROGRAM_ID              IN NUMBER,
          p_PROGRAM_UPDATE_DATE     IN DATE,
          p_ATTRIBUTE_CATEGORY      IN VARCHAR2,
          p_ATTRIBUTE1              IN VARCHAR2,
          p_ATTRIBUTE2              IN VARCHAR2,
          p_ATTRIBUTE3              IN VARCHAR2,
          p_ATTRIBUTE4              IN VARCHAR2,
          p_ATTRIBUTE5              IN VARCHAR2,
          p_ATTRIBUTE6              IN VARCHAR2,
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
          p_LAST_UPDATE_LOGIN      IN NUMBER
)

 IS
   CURSOR C IS
        SELECT *
         FROM IEX_COSTS
        WHERE COST_ID =  p_COST_ID
        FOR UPDATE of COST_ID NOWAIT;
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
           (      Recinfo.COST_ID = p_COST_ID)
       AND (    ( Recinfo.CASE_ID = p_CASE_ID)
            OR (    ( Recinfo.CASE_ID IS NULL )
                AND (  p_CASE_ID IS NULL )))
       AND (    ( Recinfo.DELINQUENCY_ID = p_DELINQUENCY_ID)
            OR (    ( Recinfo.DELINQUENCY_ID IS NULL )
                AND (  p_DELINQUENCY_ID IS NULL )))
       AND (    ( Recinfo.COST_TYPE_CODE = p_COST_TYPE_CODE)
            OR (    ( Recinfo.COST_TYPE_CODE IS NULL )
                AND (  p_COST_TYPE_CODE IS NULL )))
       AND (    ( Recinfo.COST_ITEM_TYPE_CODE = p_COST_ITEM_TYPE_CODE)
            OR (    ( Recinfo.COST_ITEM_TYPE_CODE IS NULL )
                AND (  p_COST_ITEM_TYPE_CODE IS NULL )))
       AND (    ( Recinfo.COST_ITEM_TYPE_DESC = p_COST_ITEM_TYPE_DESC)
            OR (    ( Recinfo.COST_ITEM_TYPE_DESC IS NULL )
                AND (  p_COST_ITEM_TYPE_DESC IS NULL )))
       AND (    ( Recinfo.COST_ITEM_AMOUNT = p_COST_ITEM_AMOUNT)
            OR (    ( Recinfo.COST_ITEM_AMOUNT IS NULL )
                AND (  p_COST_ITEM_AMOUNT IS NULL )))
       AND (    ( Recinfo.COST_ITEM_CURRENCY_CODE = p_COST_ITEM_CURRENCY_CODE)
            OR (    ( Recinfo.COST_ITEM_CURRENCY_CODE IS NULL )
                AND (  p_COST_ITEM_CURRENCY_CODE IS NULL )))
       AND (    ( Recinfo.COST_ITEM_QTY = p_COST_ITEM_QTY)
            OR (    ( Recinfo.COST_ITEM_QTY IS NULL )
                AND (  p_COST_ITEM_QTY IS NULL )))
       AND (    ( Recinfo.COST_ITEM_DATE = p_COST_ITEM_DATE)
            OR (    ( Recinfo.COST_ITEM_DATE IS NULL )
                AND (  p_COST_ITEM_DATE IS NULL )))
       AND (    ( Recinfo.COST_ITEM_APPROVED = p_COST_ITEM_APPROVED)
            OR (    ( Recinfo.COST_ITEM_APPROVED IS NULL )
                AND (  p_COST_ITEM_APPROVED IS NULL )))
       AND (    ( Recinfo.ACTIVE_FLAG = p_ACTIVE_FLAG)
            OR (    ( Recinfo.ACTIVE_FLAG IS NULL )
                AND (  p_ACTIVE_FLAG IS NULL )))
       AND (    ( Recinfo.OBJECT_VERSION_NUMBER = p_OBJECT_VERSION_NUMBER)
            OR (    ( Recinfo.OBJECT_VERSION_NUMBER IS NULL )
                AND (  p_OBJECT_VERSION_NUMBER IS NULL )))
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

End IEX_COSTS_PKG;

/
