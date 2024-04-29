--------------------------------------------------------
--  DDL for Package Body IEX_STRATEGY_WORK_ITEMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_STRATEGY_WORK_ITEMS_PKG" as
/* $Header: iextswib.pls 120.0.12010000.2 2008/08/06 09:03:42 schekuri ship $ */
G_PKG_NAME CONSTANT VARCHAR2(30):= 'IEX_STRATEGY_WORK_ITEMS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'iextswib.pls';

--PG_DEBUG NUMBER(2) := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));
PG_DEBUG NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

PROCEDURE Insert_Row(
          X_ROWID                 IN OUT NOCOPY VARCHAR2
         ,x_WORK_ITEM_ID   IN  NUMBER
         ,x_STRATEGY_ID    IN NUMBER
         ,x_work_item_template_id IN NUMBER
         ,x_RESOURCE_ID    IN NUMBER
         ,x_STATUS_CODE    IN VARCHAR2
         ,x_execute_start   IN DATE
         ,x_execute_end     IN DATE
         ,x_LAST_UPDATE_LOGIN    IN NUMBER
         ,x_CREATION_DATE IN   DATE
         ,x_CREATED_BY    IN NUMBER
         ,x_LAST_UPDATE_DATE    DATE
         ,x_last_updated_by  IN NUMBER
         ,x_OBJECT_VERSION_NUMBER    IN NUMBER
         ,X_REQUEST_ID              in  NUMBER
         ,X_PROGRAM_APPLICATION_ID  in  NUMBER
         ,X_PROGRAM_ID              in  NUMBER
         ,X_PROGRAM_UPDATE_DATE     in  DATE
         ,x_schedule_start          in  DATE
         ,x_schedule_end            in  DATE
         ,x_strategy_temp_id        in NUMBER
         ,x_work_item_order         in NUMBER
	 ,x_escalated_yn in CHAR
         )


    IS
    cursor C is select ROWID from IEX_STRATEGY_WORK_ITEMS
    where  WORK_ITEM_ID = X_WORK_ITEM_ID   ;

BEGIN
-- IF PG_DEBUG < 10  THEN
 IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    IEX_DEBUG_PUB.LogMessage ('********* Start of Procedure =>IEX_STRATEGY_WORK_ITEMS_PKG.INSERT_ROW ******** ');
 END IF;

   INSERT INTO IEX_STRATEGY_WORK_ITEMS(
           WORK_ITEM_ID
          ,STRATEGY_ID
          ,RESOURCE_ID
          ,STATUS_CODE
          ,LAST_UPDATED_BY
          ,LAST_UPDATE_LOGIN
          ,CREATION_DATE
          ,CREATED_BY
          ,PROGRAM_ID
          ,OBJECT_VERSION_NUMBER
          ,REQUEST_ID
          ,LAST_UPDATE_DATE
          ,WORK_ITEM_TEMPLATE_ID
          ,PROGRAM_APPLICATION_ID
          ,PROGRAM_UPDATE_DATE
          ,execute_start
          ,execute_end
          ,schedule_start
          ,schedule_end
          ,strategy_temp_id
          ,work_item_order
	  ,escalated_yn
          )
          VALUES (
           x_WORK_ITEM_ID
          ,x_STRATEGY_ID
          ,x_RESOURCE_ID
          ,decode( x_STATUS_CODE, FND_API.G_MISS_CHAR, NULL, x_STATUS_CODE)
          ,decode( x_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, x_LAST_UPDATED_BY)
          ,decode( x_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, x_LAST_UPDATE_LOGIN)
          ,decode( x_CREATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), x_CREATION_DATE)
          ,decode( x_CREATED_BY, FND_API.G_MISS_NUM, NULL, x_CREATED_BY)
          ,decode( x_PROGRAM_ID, FND_API.G_MISS_NUM, NULL, x_PROGRAM_ID)
          ,decode( x_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, NULL, x_OBJECT_VERSION_NUMBER)
          ,decode( x_REQUEST_ID, FND_API.G_MISS_NUM, NULL, x_REQUEST_ID)
          ,decode( x_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), x_LAST_UPDATE_DATE)
          ,decode( x_WORK_ITEM_TEMPLATE_ID, FND_API.G_MISS_NUM, NULL, x_WORK_ITEM_TEMPLATE_ID)
          ,decode( x_PROGRAM_APPLICATION_ID, FND_API.G_MISS_NUM, NULL, x_PROGRAM_APPLICATION_ID)
          ,decode( x_PROGRAM_UPDATE_DATE, FND_API.G_MISS_DATE, to_date(null), x_PROGRAM_UPDATE_DATE)
          ,decode( x_execute_start, FND_API.G_MISS_DATE, to_date(null), x_execute_start)
          ,decode( x_execute_end, FND_API.G_MISS_DATE, to_date(null), x_execute_end)
          ,decode( x_schedule_start,  FND_API.G_MISS_DATE, to_date(null), x_schedule_start )
          ,decode( x_schedule_end , FND_API.G_MISS_DATE, to_date(null), x_schedule_end)
          ,decode( x_strategy_temp_id, FND_API.G_MISS_NUM, NULL, x_strategy_temp_id)
          ,decode( x_WORK_ITEM_ORDER, FND_API.G_MISS_NUM, NULL, x_WORK_ITEM_ORDER)
	  ,decode( x_escalated_yn, FND_API.G_MISS_CHAR, NULL, x_escalated_yn)
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

-- IF PG_DEBUG < 10  THEN
 IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    IEX_DEBUG_PUB.LogMessage ('********* end of Procedure =>IEX_STRATEGY_WORK_ITEMS_PKG.INSERT_ROW ******** ');
 END IF;
End Insert_Row;

PROCEDURE Update_Row(
         x_WORK_ITEM_ID   IN  NUMBER
         ,x_STRATEGY_ID    IN NUMBER
         ,x_work_item_template_id IN NUMBER
         ,x_RESOURCE_ID    IN NUMBER
         ,x_STATUS_CODE    IN VARCHAR2
         ,x_execute_start   IN DATE
         ,x_execute_end     IN DATE
         ,x_LAST_UPDATE_LOGIN    IN NUMBER
         ,x_LAST_UPDATE_DATE    DATE
         ,x_last_updated_by  IN NUMBER
         ,x_OBJECT_VERSION_NUMBER    IN NUMBER
         ,X_REQUEST_ID              in  NUMBER
         ,X_PROGRAM_APPLICATION_ID  in  NUMBER
         ,X_PROGRAM_ID              in  NUMBER
         ,X_PROGRAM_UPDATE_DATE     in  DATE
         ,x_schedule_start          in  DATE
         ,x_schedule_end            in  DATE
         ,x_strategy_temp_id        in NUMBER
         ,x_work_item_order         in NUMBER
	 ,x_escalated_yn in CHAR
         )
  IS
BEGIN
--  IF PG_DEBUG < 10  THEN
  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
     IEX_DEBUG_PUB.LogMessage ('********* start of Procedure =>IEX_STRATEGY_WORK_ITEMS_PKG.UPDATE_ROW ******** ');
  END IF;
    Update IEX_STRATEGY_WORK_ITEMS
    SET
        STRATEGY_ID = decode( x_STRATEGY_ID, FND_API.G_MISS_NUM, STRATEGY_ID, x_STRATEGY_ID)
       ,RESOURCE_ID = decode( x_RESOURCE_ID, FND_API.G_MISS_NUM, RESOURCE_ID, x_RESOURCE_ID)
       ,STATUS_CODE = decode( x_STATUS_CODE, FND_API.G_MISS_CHAR, STATUS_CODE, x_STATUS_CODE)
       ,LAST_UPDATED_BY = decode( x_LAST_UPDATED_BY, FND_API.G_MISS_NUM, LAST_UPDATED_BY, x_LAST_UPDATED_BY)
       ,LAST_UPDATE_LOGIN = decode( x_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, LAST_UPDATE_LOGIN, x_LAST_UPDATE_LOGIN)
       ,PROGRAM_ID = decode( x_PROGRAM_ID, FND_API.G_MISS_NUM, PROGRAM_ID, x_PROGRAM_ID)
       ,OBJECT_VERSION_NUMBER = decode( x_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, OBJECT_VERSION_NUMBER, x_OBJECT_VERSION_NUMBER)
       ,REQUEST_ID = decode( x_REQUEST_ID, FND_API.G_MISS_NUM, REQUEST_ID, x_REQUEST_ID)
       ,LAST_UPDATE_DATE = decode( x_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, LAST_UPDATE_DATE, x_LAST_UPDATE_DATE)
       ,WORK_ITEM_TEMPLATE_ID = decode( x_WORK_ITEM_TEMPLATE_ID, FND_API.G_MISS_NUM, WORK_ITEM_TEMPLATE_ID, x_WORK_ITEM_TEMPLATE_ID)
       ,PROGRAM_APPLICATION_ID = decode( x_PROGRAM_APPLICATION_ID, FND_API.G_MISS_NUM, PROGRAM_APPLICATION_ID, x_PROGRAM_APPLICATION_ID)
       ,PROGRAM_UPDATE_DATE = decode( x_PROGRAM_UPDATE_DATE, FND_API.G_MISS_DATE, PROGRAM_UPDATE_DATE, x_PROGRAM_UPDATE_DATE)
       ,execute_start = decode( x_execute_start, FND_API.G_MISS_DATE, execute_start, x_execute_start)
       ,execute_end = decode( x_execute_end, FND_API.G_MISS_DATE, execute_end, x_execute_end)
       ,schedule_start =decode( x_schedule_start, FND_API.G_MISS_DATE, schedule_start, x_schedule_start)
       ,schedule_end =decode( x_schedule_end, FND_API.G_MISS_DATE, schedule_end, x_schedule_end)
       ,strategy_temp_id  = decode( x_strategy_temp_id , FND_API.G_MISS_NUM, strategy_temp_id , x_strategy_temp_id )
       ,WORK_ITEM_ORDER = decode( x_WORK_ITEM_ORDER, FND_API.G_MISS_NUM, WORK_ITEM_ORDER, x_WORK_ITEM_ORDER)
       ,escalated_yn = decode( x_escalated_yn, FND_API.G_MISS_CHAR, escalated_yn, x_escalated_yn)
    where WORK_ITEM_ID = x_WORK_ITEM_ID;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       IEX_DEBUG_PUB.LogMessage ('********* end of Procedure =>IEX_STRATEGY_WORK_ITEMS_PKG.UPDATE_ROW ******** ');
    END IF;

END Update_Row;

PROCEDURE Delete_Row(
    x_WORK_ITEM_ID  NUMBER)
IS
BEGIN
    DELETE FROM IEX_STRATEGY_WORK_ITEMS
    WHERE WORK_ITEM_ID = x_WORK_ITEM_ID;
    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
END Delete_Row;

/*
PROCEDURE Lock_Row(
         x_WORK_ITEM_ID   IN  NUMBER
         ,x_STRATEGY_ID    IN NUMBER
         ,x_work_item_template_id IN NUMBER
         ,x_RESOURCE_ID    IN NUMBER
         ,x_STATUS_CODE    IN VARCHAR2
         ,x_execute_start   IN DATE
         ,x_execute_end     IN DATE
         ,x_LAST_UPDATE_LOGIN    IN NUMBER
         ,x_CREATION_DATE IN   DATE
         ,x_CREATED_BY    IN NUMBER
         ,x_LAST_UPDATE_DATE    DATE
        ,x_last_updated_by  IN NUMBER
         ,x_OBJECT_VERSION_NUMBER    IN NUMBER
         ,X_REQUEST_ID              in  NUMBER
         ,X_PROGRAM_APPLICATION_ID  in  NUMBER
         ,X_PROGRAM_ID              in  NUMBER
         ,X_PROGRAM_UPDATE_DATE     in  DATE
         ,x_schedule_start          in  DATE
         ,x_schedule_end            in  DATE
         ,x_strategy_temp_id        in NUMBER
         ,x_work_item_order         in NUMBER
         )

 IS
   CURSOR C IS
       SELECT *
       FROM IEX_STRATEGY_WORK_ITEMS
       WHERE WORK_ITEM_ID =  x_WORK_ITEM_ID
       FOR UPDATE of WORK_ITEM_ID NOWAIT;
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
           (      Recinfo.WORK_ITEM_ID = p_WORK_ITEM_ID)
       AND (    ( Recinfo.STRATEGY_ID = p_STRATEGY_ID)
            OR (    ( Recinfo.STRATEGY_ID IS NULL )
                AND (  p_STRATEGY_ID IS NULL )))
       AND (    ( Recinfo.COMPETENCE_ID = p_COMPETENCE_ID)
            OR (    ( Recinfo.COMPETENCE_ID IS NULL )
                AND (  p_COMPETENCE_ID IS NULL )))
       AND (    ( Recinfo.CATEGORY_TYPE = p_CATEGORY_TYPE)
            OR (    ( Recinfo.CATEGORY_TYPE IS NULL )
                AND (  p_CATEGORY_TYPE IS NULL )))
       AND (    ( Recinfo.RESOURCE_ID = p_RESOURCE_ID)
            OR (    ( Recinfo.RESOURCE_ID IS NULL )
                AND (  p_RESOURCE_ID IS NULL )))
       AND (    ( Recinfo.REQUIRED_YN = p_REQUIRED_YN)
            OR (    ( Recinfo.REQUIRED_YN IS NULL )
                AND (  p_REQUIRED_YN IS NULL )))
       AND (    ( Recinfo.STATUS_CODE = p_STATUS_CODE)
            OR (    ( Recinfo.STATUS_CODE IS NULL )
                AND (  p_STATUS_CODE IS NULL )))
       AND (    ( Recinfo.PRIORITY_ID = p_PRIORITY_ID)
            OR (    ( Recinfo.PRIORITY_ID IS NULL )
                AND (  p_PRIORITY_ID IS NULL )))
       AND (    ( Recinfo.PRE_EXECUTION_WAIT = p_PRE_EXECUTION_WAIT)
            OR (    ( Recinfo.PRE_EXECUTION_WAIT IS NULL )
                AND (  p_PRE_EXECUTION_WAIT IS NULL )))
       AND (    ( Recinfo.POST_EXECUTION_WAIT = p_POST_EXECUTION_WAIT)
            OR (    ( Recinfo.POST_EXECUTION_WAIT IS NULL )
                AND (  p_POST_EXECUTION_WAIT IS NULL )))
       AND (    ( Recinfo.CLOSURE_DATE_LIMIT = p_CLOSURE_DATE_LIMIT)
            OR (    ( Recinfo.CLOSURE_DATE_LIMIT IS NULL )
                AND (  p_CLOSURE_DATE_LIMIT IS NULL )))
       AND (    ( Recinfo.EXECUTE_DATE_LIMIT = p_EXECUTE_DATE_LIMIT)
            OR (    ( Recinfo.EXECUTE_DATE_LIMIT IS NULL )
                AND (  p_EXECUTE_DATE_LIMIT IS NULL )))
       AND (    ( Recinfo.SEEDED_WORKFLOW_YN = p_SEEDED_WORKFLOW_YN)
            OR (    ( Recinfo.SEEDED_WORKFLOW_YN IS NULL )
                AND (  p_SEEDED_WORKFLOW_YN IS NULL )))
       AND (    ( Recinfo.WORKFLOW_ITEM_TYPE = p_WORKFLOW_ITEM_TYPE)
            OR (    ( Recinfo.WORKFLOW_ITEM_TYPE IS NULL )
                AND (  p_WORKFLOW_ITEM_TYPE IS NULL )))
       AND (    ( Recinfo.WORKFLOW_PROCESS_NAME = p_WORKFLOW_PROCESS_NAME)
            OR (    ( Recinfo.WORKFLOW_PROCESS_NAME IS NULL )
                AND (  p_WORKFLOW_PROCESS_NAME IS NULL )))
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
       AND (    ( Recinfo.PROGRAM_ID = p_PROGRAM_ID)
            OR (    ( Recinfo.PROGRAM_ID IS NULL )
                AND (  p_PROGRAM_ID IS NULL )))
       AND (    ( Recinfo.OBJECT_VERSION_NUMBER = p_OBJECT_VERSION_NUMBER)
            OR (    ( Recinfo.OBJECT_VERSION_NUMBER IS NULL )
                AND (  p_OBJECT_VERSION_NUMBER IS NULL )))
       AND (    ( Recinfo.REQUEST_ID = p_REQUEST_ID)
            OR (    ( Recinfo.REQUEST_ID IS NULL )
                AND (  p_REQUEST_ID IS NULL )))
       AND (    ( Recinfo.WORK_TYPE = p_WORK_TYPE)
            OR (    ( Recinfo.WORK_TYPE IS NULL )
                AND (  p_WORK_TYPE IS NULL )))
       AND (    ( Recinfo.LAST_UPDATE_DATE = p_LAST_UPDATE_DATE)
            OR (    ( Recinfo.LAST_UPDATE_DATE IS NULL )
                AND (  p_LAST_UPDATE_DATE IS NULL )))
       AND (    ( Recinfo.WORK_ITEM_TEMPLATE_ID = p_WORK_ITEM_TEMPLATE_ID)
            OR (    ( Recinfo.WORK_ITEM_TEMPLATE_ID IS NULL )
                AND (  p_WORK_ITEM_TEMPLATE_ID IS NULL )))
        ) then
        return;
    else
        FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
        APP_EXCEPTION.RAISE_EXCEPTION;
    End If;
END Lock_Row;
*/

procedure LOCK_ROW (
  x_WORK_ITEM_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER)
 is
  cursor c is select OBJECT_VERSION_NUMBER
    from IEX_STRATEGY_WORK_ITEMS
    where WORK_ITEM_ID  = X_WORK_ITEM_ID
    and OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER
    for update of WORK_ITEM_ID  nowait;
  recinfo c%rowtype;


begin
-- IF PG_DEBUG < 10  THEN
 IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    IEX_DEBUG_PUB.LogMessage ('********* Start of Procedure =>IEX_STRATEGY_WORK_ITEMS_PKG.LOCK_ROW ******** ');
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
   IEX_DEBUG_PUB.LogMessage ('********* End of Procedure =>IEX_STRATEGY_WORK_ITEMS_PKG.LOCK_ROW ******** ');
END IF;
end LOCK_ROW;

End IEX_STRATEGY_WORK_ITEMS_PKG;

/
