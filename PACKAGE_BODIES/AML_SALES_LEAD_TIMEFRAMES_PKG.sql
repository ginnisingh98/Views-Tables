--------------------------------------------------------
--  DDL for Package Body AML_SALES_LEAD_TIMEFRAMES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AML_SALES_LEAD_TIMEFRAMES_PKG" as
/* $Header: amlttfrb.pls 115.6 2003/01/03 23:45:26 ckapoor noship $ */
-- Start of Comments
-- Package name     : AML_SALES_LEAD_TIMEFRAMES_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AML_SALES_LEAD_TIMEFRAMES_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amlttfrb.pls';

AS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);
AS_DEBUG_ERROR_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_ERROR);

PROCEDURE Insert_Row(
          px_TIMEFRAME_ID   IN OUT NOCOPY NUMBER
         ,p_DECISION_TIMEFRAME_CODE    VARCHAR2
         ,p_TIMEFRAME_DAYS    NUMBER
         ,p_CREATION_DATE in DATE
  	 ,p_CREATED_BY in NUMBER
  	 ,p_LAST_UPDATE_DATE in DATE
  	 ,p_LAST_UPDATED_BY in NUMBER
  	 ,p_LAST_UPDATE_LOGIN in NUMBER
  	 ,p_ENABLED_FLAG in VARCHAR2)

 IS
   CURSOR C2 IS SELECT AML_SALES_LEAD_TIMEFRAMES_S.nextval FROM sys.dual;
BEGIN
   If (px_TIMEFRAME_ID IS NULL) OR (px_TIMEFRAME_ID = FND_API.G_MISS_NUM) then
       OPEN C2;
       FETCH C2 INTO px_TIMEFRAME_ID;
       CLOSE C2;
   End If;
   INSERT INTO AML_SALES_LEAD_TIMEFRAMES(
           TIMEFRAME_ID
          ,DECISION_TIMEFRAME_CODE
           ,TIMEFRAME_DAYS
           ,CREATION_DATE
	    ,CREATED_BY
	    ,LAST_UPDATE_DATE
	    ,LAST_UPDATED_BY
    	    ,LAST_UPDATE_LOGIN
    	    , ENABLED_FLAG
          ) VALUES (
           px_TIMEFRAME_ID
          ,decode( p_DECISION_TIMEFRAME_CODE, FND_API.G_MISS_CHAR, NULL, p_DECISION_TIMEFRAME_CODE)
          ,decode( p_TIMEFRAME_DAYS, FND_API.G_MISS_NUM, NULL, p_TIMEFRAME_DAYS)
          , DECODE(p_creation_date,FND_API.G_MISS_DATE,TO_DATE(NULL),p_creation_date)
	  , DECODE(p_created_by,FND_API.G_MISS_NUM,NULL,p_created_by)
          , DECODE(p_last_update_date,FND_API.G_MISS_DATE,TO_DATE(NULL),p_last_update_date)
	  , DECODE(p_last_updated_by,FND_API.G_MISS_NUM,NULL,p_last_updated_by)
          , DECODE(p_last_update_login,FND_API.G_MISS_NUM,NULL,p_last_update_login)
          , DECODE(p_enabled_flag, FND_API.G_MISS_CHAR, 'N', p_enabled_flag));

End Insert_Row;

PROCEDURE Update_Row(
          p_TIMEFRAME_ID    NUMBER
         ,p_DECISION_TIMEFRAME_CODE    VARCHAR2
         ,p_TIMEFRAME_DAYS    NUMBER
         ,p_CREATION_DATE in DATE
  	 ,p_CREATED_BY in NUMBER
  	 ,p_LAST_UPDATE_DATE in DATE
  	 ,p_LAST_UPDATED_BY in NUMBER
  	 ,p_LAST_UPDATE_LOGIN in NUMBER
  	 ,p_ENABLED_FLAG in VARCHAR2)

IS
BEGIN
    Update AML_SALES_LEAD_TIMEFRAMES
    SET
        DECISION_TIMEFRAME_CODE = decode( p_DECISION_TIMEFRAME_CODE, FND_API.G_MISS_CHAR, DECISION_TIMEFRAME_CODE, p_DECISION_TIMEFRAME_CODE)
       ,TIMEFRAME_DAYS = decode( p_TIMEFRAME_DAYS, FND_API.G_MISS_NUM, TIMEFRAME_DAYS, p_TIMEFRAME_DAYS)
       , creation_date     = DECODE(p_creation_date,FND_API.G_MISS_DATE,CREATION_DATE,p_creation_date)
       , created_by        = DECODE(p_created_by,FND_API.G_MISS_NUM,CREATED_BY,p_created_by)
       , last_update_date  = DECODE(p_last_update_date,FND_API.G_MISS_DATE,LAST_UPDATE_DATE,p_last_update_date)
       , last_updated_by   = DECODE(p_last_updated_by,FND_API.G_MISS_NUM,LAST_UPDATED_BY,p_last_updated_by)
       , last_update_login = DECODE(p_last_update_login,FND_API.G_MISS_NUM,LAST_UPDATE_LOGIN,p_last_update_login)
	, enabled_flag = DECODE(p_enabled_flag,FND_API.G_MISS_CHAR,ENABLED_FLAG, p_enabled_flag)


    where TIMEFRAME_ID = p_TIMEFRAME_ID;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
END Update_Row;

PROCEDURE Delete_Row(
    p_TIMEFRAME_ID  NUMBER)
IS
BEGIN
    DELETE FROM AML_SALES_LEAD_TIMEFRAMES
    WHERE TIMEFRAME_ID = p_TIMEFRAME_ID;
    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
END Delete_Row;

PROCEDURE Lock_Row(
          p_TIMEFRAME_ID    NUMBER
         ,p_DECISION_TIMEFRAME_CODE    VARCHAR2
         ,p_TIMEFRAME_DAYS    NUMBER
         ,p_CREATION_DATE in DATE
  	 ,p_CREATED_BY in NUMBER
  	 ,p_LAST_UPDATE_DATE in DATE
  	 ,p_LAST_UPDATED_BY in NUMBER
  	 ,p_LAST_UPDATE_LOGIN in NUMBER
  	 ,p_ENABLED_FLAG in VARCHAR2)

 IS
   CURSOR C IS
       SELECT *
       FROM AML_SALES_LEAD_TIMEFRAMES
       WHERE TIMEFRAME_ID =  p_TIMEFRAME_ID
       FOR UPDATE of TIMEFRAME_ID NOWAIT;
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
           (      Recinfo.TIMEFRAME_ID = p_TIMEFRAME_ID)
       AND (    ( Recinfo.DECISION_TIMEFRAME_CODE = p_DECISION_TIMEFRAME_CODE)
            OR (    ( Recinfo.DECISION_TIMEFRAME_CODE IS NULL )
                AND (  p_DECISION_TIMEFRAME_CODE IS NULL )))
       AND (    ( Recinfo.TIMEFRAME_DAYS = p_TIMEFRAME_DAYS)
            OR (    ( Recinfo.TIMEFRAME_DAYS IS NULL )
                AND (  p_TIMEFRAME_DAYS IS NULL )))
	  AND           ((Recinfo.creation_date = p_creation_date)
	    OR ((Recinfo.creation_date IS NULL)
		AND ( p_creation_date IS NULL)))
	  AND           ((Recinfo.created_by = p_created_by)
	    OR ((Recinfo.created_by IS NULL)
		AND ( p_created_by IS NULL)))
	  AND           ((Recinfo.last_update_date = p_last_update_date)
	    OR ((Recinfo.last_update_date IS NULL)
		AND ( p_last_update_date IS NULL)))
	  AND           ((Recinfo.last_updated_by = p_last_updated_by)
	    OR ((Recinfo.last_updated_by IS NULL)
		AND ( p_last_updated_by IS NULL)))
	  AND           ((Recinfo.last_update_login = p_last_update_login)
	    OR ((Recinfo.last_update_login IS NULL)
		AND ( p_last_update_login IS NULL)))
	  AND           ((Recinfo.enabled_flag = p_enabled_flag)
	    OR ((Recinfo.enabled_flag IS NULL)
		AND ( p_enabled_flag IS NULL)))

        ) then
        return;
    else
        FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
        APP_EXCEPTION.RAISE_EXCEPTION;
    End If;
END Lock_Row;


PROCEDURE Load_Row (
        X_timeframe_ID in OUT NOCOPY NUMBER,
        X_DECISION_TIMEFRAME_CODE in VARCHAR2,
        X_TIMEFRAME_DAYS in NUMBER,
        X_OWNER in VARCHAR2,
        X_ENABLED_FLAG in VARCHAR2)
IS
    user_id            number := 0;
    row_id             varchar2(64);


    CURSOR c_get_last_updated (c_rank_id NUMBER) IS
        SELECT last_updated_by
        FROM AML_SALES_LEAD_TIMEFRAMES
        WHERE timeframe_id = x_timeframe_id;
    l_last_updated_by  NUMBER;


BEGIN

    -- If last_updated_by is not 1, means this record has been updated by
    -- customer, we should not overwrite it.
    OPEN c_get_last_updated (x_TIMEFRAME_ID);
    FETCH c_get_last_updated INTO l_last_updated_by;
    CLOSE c_get_last_updated;

    IF nvl(l_last_updated_by, 1) = 1
    THEN
        if (X_OWNER = 'SEED') then
            user_id := 1;
        end if;

        Update_Row(p_TIMEFRAME_ID            => x_TIMEFRAME_ID,
                   p_DECISION_TIMEFRAME_CODE          => x_DECISION_TIMEFRAME_CODE,
                   p_TIMEFRAME_DAYS          => x_TIMEFRAME_DAYS,
                   p_CREATION_DATE      =>  FND_API.G_MISS_DATE,
                   p_CREATED_BY          => FND_API.G_MISS_NUM,
                   p_LAST_UPDATE_DATE   => sysdate,
                   p_LAST_UPDATED_BY    => user_id,
                   p_LAST_UPDATE_LOGIN  => 0,
                   p_ENABLED_FLAG	=> x_ENABLED_FLAG
                   );



    END IF;

    EXCEPTION
        when no_data_found then
            Insert_Row(px_TIMEFRAME_ID            => x_TIMEFRAME_ID,
                       p_DECISION_TIMEFRAME_CODE          => x_DECISION_TIMEFRAME_CODE,
                       p_TIMEFRAME_DAYS          => x_TIMEFRAME_DAYS,
                       p_creation_date      => sysdate,
                       p_created_by         => 0,
                       p_LAST_UPDATE_DATE   => sysdate,
                       p_LAST_UPDATED_BY    => user_id,
                       p_LAST_UPDATE_LOGIN  => 0,
                       p_ENABLED_FLAG	    => x_ENABLED_FLAG
                       );



END load_row;



End AML_SALES_LEAD_TIMEFRAMES_PKG;

/
