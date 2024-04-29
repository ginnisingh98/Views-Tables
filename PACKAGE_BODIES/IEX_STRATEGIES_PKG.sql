--------------------------------------------------------
--  DDL for Package Body IEX_STRATEGIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_STRATEGIES_PKG" as
/* $Header: iextstrb.pls 120.0.12010000.3 2008/08/13 10:51:47 pnaveenk ship $ */
G_PKG_NAME CONSTANT VARCHAR2(30):= 'IEX_STRATEGIES_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'iextstrb.pls';

--PG_DEBUG NUMBER(2) := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));
PG_DEBUG NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

PROCEDURE Insert_Row(
          X_ROWID                 IN OUT NOCOPY VARCHAR2
          ,X_STRATEGY_ID          IN  NUMBER
         ,X_STATUS_CODE           IN VARCHAR2
         ,X_STRATEGY_TEMPLATE_ID  IN  NUMBER
         ,X_DELINQUENCY_ID        IN  NUMBER
         ,X_OBJECT_TYPE           IN VARCHAR2
         ,X_OBJECT_ID             IN  NUMBER
         ,X_CUST_ACCOUNT_ID       IN  NUMBER
         ,X_PARTY_ID              IN  NUMBER
         ,X_SCORE_VALUE           IN  NUMBER
         ,X_NEXT_WORK_ITEM_ID     IN  NUMBER
         ,X_USER_WORK_ITEM_YN     IN VARCHAR2,
          X_OBJECT_VERSION_NUMBER in NUMBER,
          X_CREATION_DATE         in DATE,
          X_CREATED_BY            in NUMBER,
          X_LAST_UPDATE_DATE      in DATE,
          X_LAST_UPDATED_BY       in NUMBER,
          X_LAST_UPDATE_LOGIN     in NUMBER,
          X_REQUEST_ID            in  NUMBER,
          X_PROGRAM_APPLICATION_ID in  NUMBER,
          X_PROGRAM_ID              in  NUMBER,
          X_PROGRAM_UPDATE_DATE     in  DATE,
		X_CHECKLIST_STRATEGY_ID   IN  NUMBER,
		X_CHECKLIST_YN            IN VARCHAR2,
        X_STRATEGY_LEVEL          IN  NUMBER,
        X_JTF_OBJECT_TYPE            IN  VARCHAR2,
        X_JTF_OBJECT_ID          IN  NUMBER,
         X_CUSTOMER_SITE_USE_ID          IN  NUMBER,
	 X_ORG_ID                  IN  NUMBER)   -- Bug#6870773 Naveen
 IS
    cursor C is select ROWID from IEX_STRATEGIES
    where  STRATEGY_ID = X_STRATEGY_ID   ;

BEGIN
--   IF PG_DEBUG < 10  THEN
   IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      IEX_DEBUG_PUB.LogMessage ('********* Start of Procedure =>IEX_STRATEGIES_PKG.INSERT_ROW ******** ');
   END IF;
     INSERT INTO IEX_STRATEGIES(
           STRATEGY_ID
          ,STATUS_CODE
          ,STRATEGY_TEMPLATE_ID
          ,DELINQUENCY_ID
          ,OBJECT_TYPE
          ,OBJECT_ID
          ,CUST_ACCOUNT_ID
          ,PARTY_ID
          ,SCORE_VALUE
          ,NEXT_WORK_ITEM_ID
          ,USER_WORK_ITEM_YN
          ,LAST_UPDATE_DATE
          ,LAST_UPDATED_BY
          ,LAST_UPDATE_LOGIN
          ,CREATION_DATE
          ,CREATED_BY
          ,OBJECT_VERSION_NUMBER
          ,REQUEST_ID
          ,PROGRAM_APPLICATION_ID
          ,PROGRAM_ID
           ,PROGRAM_UPDATE_DATE
		 ,CHECKLIST_STRATEGY_ID
		 ,CHECKLIST_YN
         ,STRATEGY_LEVEL
         ,JTF_OBJECT_TYPE
         ,JTF_OBJECT_ID
         ,CUSTOMER_SITE_USE_ID
	 ,ORG_ID   --Bug#6870773 Naveen
          ) VALUES (
           x_STRATEGY_ID
          ,decode( x_STATUS_CODE, FND_API.G_MISS_CHAR, NULL, x_STATUS_CODE)
          ,decode( x_STRATEGY_TEMPLATE_ID, FND_API.G_MISS_NUM, NULL, x_STRATEGY_TEMPLATE_ID)
          ,x_DELINQUENCY_ID
          ,decode( x_OBJECT_TYPE, FND_API.G_MISS_CHAR, NULL, x_OBJECT_TYPE)
          ,decode( x_OBJECT_ID, FND_API.G_MISS_NUM, NULL, x_OBJECT_ID)
          ,decode( x_CUST_ACCOUNT_ID, FND_API.G_MISS_NUM, NULL, x_CUST_ACCOUNT_ID)
          ,decode( x_PARTY_ID, FND_API.G_MISS_NUM, NULL, x_PARTY_ID)
          ,decode( x_SCORE_VALUE, FND_API.G_MISS_NUM, NULL, x_SCORE_VALUE)
          ,decode( x_NEXT_WORK_ITEM_ID, FND_API.G_MISS_NUM, NULL, x_NEXT_WORK_ITEM_ID)
          ,decode( x_USER_WORK_ITEM_YN, FND_API.G_MISS_CHAR, NULL, x_USER_WORK_ITEM_YN)
          ,decode( x_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), x_LAST_UPDATE_DATE)
          ,decode( x_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, x_LAST_UPDATED_BY)
          ,decode( x_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, x_LAST_UPDATE_LOGIN)
          ,decode( x_CREATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), x_CREATION_DATE)
          ,decode( x_CREATED_BY, FND_API.G_MISS_NUM, NULL, x_CREATED_BY)
          ,decode( x_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, NULL, x_OBJECT_VERSION_NUMBER)
          ,decode( x_REQUEST_ID, FND_API.G_MISS_NUM, NULL, x_REQUEST_ID)
          ,decode( x_PROGRAM_APPLICATION_ID, FND_API.G_MISS_NUM, NULL, x_PROGRAM_APPLICATION_ID)
          ,decode( x_PROGRAM_ID, FND_API.G_MISS_NUM, NULL, x_PROGRAM_ID)
          ,decode( x_PROGRAM_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), x_PROGRAM_UPDATE_DATE)
          ,decode( x_CHECKLIST_STRATEGY_ID, FND_API.G_MISS_NUM, NULL, x_CHECKLIST_STRATEGY_ID)
		,decode( x_CHECKLIST_YN, FND_API.G_MISS_CHAR, NULL, x_CHECKLIST_YN)
          ,decode( X_STRATEGY_LEVEL, FND_API.G_MISS_NUM, NULL, X_STRATEGY_LEVEL)
         ,decode( x_jtf_OBJECT_TYPE, FND_API.G_MISS_CHAR, NULL, x_jtf_OBJECT_TYPE)
          ,decode( x_jtf_OBJECT_ID, FND_API.G_MISS_NUM, NULL, x_jtf_OBJECT_ID)
           ,decode( x_CUSTOMER_SITE_USE_ID, FND_API.G_MISS_NUM, NULL,  x_CUSTOMER_SITE_USE_ID)
	    ,decode( X_ORG_ID, FND_API.G_MISS_NUM, NULL,  X_ORG_ID) --Bug# 6870773
         );
  open c;
  fetch c into X_ROWID;
--  IF PG_DEBUG < 10  THEN
  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
     IEX_DEBUG_PUB.LogMessage ('Insert_Row: ' || 'Value of ROWID = '||X_ROWID);
  END IF;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;
--IF PG_DEBUG < 10  THEN
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
   IEX_DEBUG_PUB.LogMessage ('********* End of Procedure =>IEX_STRATEGIES_PKG.INSERT_ROW ******** ');
END IF;

End Insert_Row;

PROCEDURE Update_Row(
          X_STRATEGY_ID          IN  NUMBER
         ,X_STATUS_CODE           IN VARCHAR2
         ,X_STRATEGY_TEMPLATE_ID  IN  NUMBER
         ,X_DELINQUENCY_ID        IN  NUMBER
         ,X_OBJECT_TYPE           IN VARCHAR2
         ,X_OBJECT_ID             IN  NUMBER
         ,X_CUST_ACCOUNT_ID       IN  NUMBER
         ,X_PARTY_ID              IN  NUMBER
         ,X_SCORE_VALUE           IN  NUMBER
         ,X_NEXT_WORK_ITEM_ID     IN  NUMBER
         ,X_USER_WORK_ITEM_YN     IN VARCHAR2,
          X_OBJECT_VERSION_NUMBER in NUMBER,
          X_LAST_UPDATE_DATE      in DATE,
          X_LAST_UPDATED_BY       in NUMBER,
          X_LAST_UPDATE_LOGIN     in NUMBER,
          X_REQUEST_ID            in  NUMBER,
          X_PROGRAM_APPLICATION_ID in  NUMBER,
          X_PROGRAM_ID              in  NUMBER,
          X_PROGRAM_UPDATE_DATE     in  DATE,
		X_CHECKLIST_STRATEGY_ID   IN  NUMBER,
		X_CHECKLIST_YN            IN VARCHAR2,
        X_STRATEGY_LEVEL          IN  NUMBER,
        X_JTF_OBJECT_TYPE            IN  VARCHAR2,
        X_JTF_OBJECT_ID          IN  NUMBER,
        X_CUSTOMER_SITE_USE_ID         IN  NUMBER,
	X_ORG_ID                       IN NUMBER ) --Bug# 6870773
IS
BEGIN
--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       IEX_DEBUG_PUB.LogMessage ('********* Start of Procedure =>IEX_STRATEGIES_PKG.UPDATE_ROW ******** ');
    END IF;
    Update IEX_STRATEGIES
    SET
        STATUS_CODE = decode( x_STATUS_CODE, FND_API.G_MISS_CHAR, null,
                              null, status_code, x_STATUS_CODE)
       ,STRATEGY_TEMPLATE_ID = decode( x_STRATEGY_TEMPLATE_ID, FND_API.G_MISS_NUM,
                              null, null, STRATEGY_TEMPLATE_ID, x_STRATEGY_TEMPLATE_ID)
       ,DELINQUENCY_ID = decode( x_DELINQUENCY_ID, FND_API.G_MISS_NUM,
                              null, null, DELINQUENCY_ID, x_DELINQUENCY_ID)
       ,OBJECT_TYPE = decode( x_OBJECT_TYPE, FND_API.G_MISS_CHAR,
                              null, null, OBJECT_TYPE, x_OBJECT_TYPE)
       ,OBJECT_ID = decode( x_OBJECT_ID, FND_API.G_MISS_NUM,
                              null, null,  OBJECT_ID, x_OBJECT_ID)
       ,CUST_ACCOUNT_ID = decode( x_CUST_ACCOUNT_ID, FND_API.G_MISS_NUM,
                              null, null,  CUST_ACCOUNT_ID, x_CUST_ACCOUNT_ID)
       ,PARTY_ID = decode( x_PARTY_ID, FND_API.G_MISS_NUM,
                              null, null,  PARTY_ID, x_PARTY_ID)
       ,SCORE_VALUE = decode( x_SCORE_VALUE, FND_API.G_MISS_NUM,
                              null, null,  SCORE_VALUE, x_SCORE_VALUE)
       ,NEXT_WORK_ITEM_ID = decode( x_NEXT_WORK_ITEM_ID, FND_API.G_MISS_NUM,
                              null, null,  NEXT_WORK_ITEM_ID, x_NEXT_WORK_ITEM_ID)
       ,USER_WORK_ITEM_YN = decode( x_USER_WORK_ITEM_YN, FND_API.G_MISS_CHAR,
                              null, null,  USER_WORK_ITEM_YN, x_USER_WORK_ITEM_YN)
       ,LAST_UPDATE_DATE = decode( x_LAST_UPDATE_DATE, FND_API.G_MISS_DATE,
                              null, null,  LAST_UPDATE_DATE, x_LAST_UPDATE_DATE)
       ,LAST_UPDATED_BY = decode( x_LAST_UPDATED_BY, FND_API.G_MISS_NUM,
                              null, null,  LAST_UPDATED_BY, x_LAST_UPDATED_BY)
       ,LAST_UPDATE_LOGIN = decode( x_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM,
                              null, null,  LAST_UPDATE_LOGIN, x_LAST_UPDATE_LOGIN)
       ,OBJECT_VERSION_NUMBER = decode( x_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM,
                              null, null,  OBJECT_VERSION_NUMBER, x_OBJECT_VERSION_NUMBER)
       ,REQUEST_ID = decode( x_REQUEST_ID, FND_API.G_MISS_NUM,
                              null, null,  REQUEST_ID, x_REQUEST_ID)
       ,PROGRAM_APPLICATION_ID = decode( x_PROGRAM_APPLICATION_ID, FND_API.G_MISS_NUM,
                              null, null,  PROGRAM_APPLICATION_ID, x_PROGRAM_APPLICATION_ID)
       ,PROGRAM_ID = decode( x_PROGRAM_ID, FND_API.G_MISS_NUM, PROGRAM_ID,
                              null, null,  x_PROGRAM_ID)
       ,PROGRAM_UPDATE_DATE = decode( x_PROGRAM_UPDATE_DATE, FND_API.G_MISS_DATE,
                              null, null,  PROGRAM_UPDATE_DATE, x_PROGRAM_UPDATE_DATE)
       ,CHECKLIST_STRATEGY_ID = decode( x_CHECKLIST_STRATEGY_ID, FND_API.G_MISS_NUM,
                              null, null,  CHECKLIST_STRATEGY_ID, x_CHECKLIST_STRATEGY_ID)
       ,CHECKLIST_YN = decode( x_CHECKLIST_YN, FND_API.G_MISS_CHAR,
                              null, null,  CHECKLIST_YN, x_CHECKLIST_YN)
       ,STRATEGY_LEVEL = decode( x_STRATEGY_LEVEL, FND_API.G_MISS_NUM,
                              null, null,  STRATEGY_LEVEL, x_STRATEGY_LEVEL)
       ,JTF_OBJECT_TYPE = decode( x_JTF_OBJECT_TYPE, FND_API.G_MISS_CHAR,
                              null, null,  JTF_OBJECT_TYPE, x_JTF_OBJECT_TYPE)
       ,JTF_OBJECT_ID = decode( x_JTF_OBJECT_ID, FND_API.G_MISS_NUM,
                              null, null,  JTF_OBJECT_ID, x_JTF_OBJECT_ID)
       ,CUSTOMER_SITE_USE_ID = decode( x_CUSTOMER_SITE_USE_ID, FND_API.G_MISS_NUM,
                              null, null,  CUSTOMER_SITE_USE_ID, x_CUSTOMER_SITE_USE_ID)
        ,ORG_ID = decode( X_ORG_ID, FND_API.G_MISS_NUM, NULL,NULL,ORG_ID,  X_ORG_ID)   --Bug# 6870773 Naveen
    where STRATEGY_ID = X_STRATEGY_ID;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.LogMessage ('********* End of Procedure =>IEX_STRATEGIES_PKG.UPDATE_ROW ******** ');
     END IF;
END Update_Row;

PROCEDURE Delete_Row(
    X_STRATEGY_ID  NUMBER)
IS
BEGIN
-- IF PG_DEBUG < 10  THEN
 IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    IEX_DEBUG_PUB.LogMessage ('********* Start of Procedure =>IEX_STRATEGY_PKG.DELETE_ROW ******** ');
 END IF;
    DELETE FROM IEX_STRATEGIES
    WHERE STRATEGY_ID = X_STRATEGY_ID;
    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       IEX_DEBUG_PUB.LogMessage ('********* End of Procedure =>IEX_STRATEGY_PKG.DELETE_ROW ******** ');
    END IF;
END Delete_Row;


procedure LOCK_ROW (
  X_STRATEGY_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER
) is
  cursor c is select OBJECT_VERSION_NUMBER
    from IEX_STRATEGIES
    where STRATEGY_ID = X_STRATEGY_ID
    and OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER
    for update of STRATEGY_ID nowait;
  recinfo c%rowtype;


begin
-- IF PG_DEBUG < 10  THEN
 IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    IEX_DEBUG_PUB.LogMessage ('********* Start of Procedure =>IEX_STRATEGIES_PKG.LOCK_ROW ******** ');
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
--IF PG_DEBUG < 10  THEN
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
   IEX_DEBUG_PUB.LogMessage ('********* End of Procedure =>IEX_STRATEGIES_PKG.LOCK_ROW ******** ');
END IF;
end LOCK_ROW;

/* PROCEDURE Lock_Row(
        PROCEDURE Update_Row(
          X_STRATEGY_ID          IN  NUMBER
         ,X_STATUS_CODE           IN VARCHAR2
         ,X_STRATEGY_TEMPLATE_ID  IN  NUMBER
         ,X_DELINQUENCY_ID        IN  NUMBER
         ,X_OBJECT_TYPE           IN VARCHAR2
         ,X_OBJECT_ID             IN  NUMBER
         ,X_WORK_ORDER_ID         IN  NUMBER
         ,X_CUST_ACCOUNT_ID       IN  NUMBER
         ,X_PARTY_ID              IN  NUMBER
         ,X_SCORE_VALUE           IN  NUMBER
         ,X_NEXT_WORK_ITEM_ID     IN  NUMBER
         ,X_USER_WORK_ITEM_YN     IN VARCHAR2,
          X_OBJECT_VERSION_NUMBER in NUMBER,
          X_CREATION_DATE         in DATE,
          X_CREATED_BY            in NUMBER,
          X_LAST_UPDATE_DATE      in DATE,
          X_LAST_UPDATED_BY       in NUMBER,
          X_LAST_UPDATE_LOGIN     in NUMBER,
          X_REQUEST_ID            in  NUMBER,
          X_PROGRAM_APPLICATION_ID in  NUMBER,
          X_PROGRAM_ID              in  NUMBER,
          X_PROGRAM_UPDATE_DATE     in  DATE) IS

 IS
   CURSOR C IS
       SELECT *
       FROM IEX_STRATEGIES
       WHERE STRATEGY_ID =  p_STRATEGY_ID
       FOR UPDATE of STRATEGY_ID NOWAIT;
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
           (      Recinfo.STRATEGY_ID = p_STRATEGY_ID)
       AND (    ( Recinfo.STATUS_CODE = p_STATUS_CODE)
            OR (    ( Recinfo.STATUS_CODE IS NULL )
                AND (  p_STATUS_CODE IS NULL )))
       AND (    ( Recinfo.STRATEGY_TEMPLATE_ID = p_STRATEGY_TEMPLATE_ID)
            OR (    ( Recinfo.STRATEGY_TEMPLATE_ID IS NULL )
                AND (  p_STRATEGY_TEMPLATE_ID IS NULL )))
       AND (    ( Recinfo.DELINQUENCY_ID = p_DELINQUENCY_ID)
            OR (    ( Recinfo.DELINQUENCY_ID IS NULL )
                AND (  p_DELINQUENCY_ID IS NULL )))
       AND (    ( Recinfo.OBJECT_TYPE = p_OBJECT_TYPE)
            OR (    ( Recinfo.OBJECT_TYPE IS NULL )
                AND (  p_OBJECT_TYPE IS NULL )))
       AND (    ( Recinfo.OBJECT_ID = p_OBJECT_ID)
            OR (    ( Recinfo.OBJECT_ID IS NULL )
                AND (  p_OBJECT_ID IS NULL )))
       AND (    ( Recinfo.WORK_ORDER_ID = p_WORK_ORDER_ID)
            OR (    ( Recinfo.WORK_ORDER_ID IS NULL )
                AND (  p_WORK_ORDER_ID IS NULL )))
       AND (    ( Recinfo.CUST_ACCOUNT_ID = p_CUST_ACCOUNT_ID)
            OR (    ( Recinfo.CUST_ACCOUNT_ID IS NULL )
                AND (  p_CUST_ACCOUNT_ID IS NULL )))
       AND (    ( Recinfo.PARTY_ID = p_PARTY_ID)
            OR (    ( Recinfo.PARTY_ID IS NULL )
                AND (  p_PARTY_ID IS NULL )))
       AND (    ( Recinfo.SCORE_VALUE = p_SCORE_VALUE)
            OR (    ( Recinfo.SCORE_VALUE IS NULL )
                AND (  p_SCORE_VALUE IS NULL )))
       AND (    ( Recinfo.NEXT_WORK_ITEM_ID = p_NEXT_WORK_ITEM_ID)
            OR (    ( Recinfo.NEXT_WORK_ITEM_ID IS NULL )
                AND (  p_NEXT_WORK_ITEM_ID IS NULL )))
       AND (    ( Recinfo.USER_WORK_ITEM_YN = p_USER_WORK_ITEM_YN)
            OR (    ( Recinfo.USER_WORK_ITEM_YN IS NULL )
                AND (  p_USER_WORK_ITEM_YN IS NULL )))
       AND (    ( Recinfo.LAST_UPDATED_BY = p_LAST_UPDATED_BY)
            OR (    ( Recinfo.LAST_UPDATED_BY IS NULL )
                AND (  p_LAST_UPDATED_BY IS NULL )))
       AND (    ( Recinfo.LAST_UPDATE_LOGIN = p_LAST_UPDATE_LOGIN)
            OR (    ( Recinfo.LAST_UPDATE_LOGIN IS NULL )
                AND (  p_LAST_UPDATE_LOGIN IS NULL )))
       AND (    ( Recinfo.CREATION_DATE = p_CREATION_DATE)
            OR (    ( Recinfo.CREATION_DATE IS NULL )
                AND (  p_CREATION_DATE IS NULL )))
       AND (    ( Recinfo.CREATED_BY = p_CREATED_BY)
            OR (    ( Recinfo.CREATED_BY IS NULL )
                AND (  p_CREATED_BY IS NULL )))
       AND (    ( Recinfo.OBJECT_VERSION_NUMBER = p_OBJECT_VERSION_NUMBER)
            OR (    ( Recinfo.OBJECT_VERSION_NUMBER IS NULL )
                AND (  p_OBJECT_VERSION_NUMBER IS NULL )))
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
        ) then
        return;
    else
        FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
        APP_EXCEPTION.RAISE_EXCEPTION;
    End If;
END Lock_Row;
*/
End IEX_STRATEGIES_PKG;

/
