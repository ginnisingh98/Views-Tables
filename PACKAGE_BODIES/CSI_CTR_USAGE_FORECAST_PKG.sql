--------------------------------------------------------
--  DDL for Package Body CSI_CTR_USAGE_FORECAST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_CTR_USAGE_FORECAST_PKG" as
/* $Header: csitcufb.pls 120.0 2005/06/10 14:17:24 rktow noship $*/

G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSI_CTR_USAGE_FORECAST_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csitcufb.pls';

PROCEDURE Insert_Row(
	px_INSTANCE_FORECAST_ID            IN OUT NOCOPY NUMBER
	,p_COUNTER_ID                      NUMBER
 	,p_USAGE_RATE                      NUMBER
 	,p_USE_PAST_READING                NUMBER
 	,p_ACTIVE_START_DATE               DATE
 	,p_ACTIVE_END_DATE                 DATE
 	,p_OBJECT_VERSION_NUMBER           NUMBER
 	,p_LAST_UPDATE_DATE                DATE
 	,p_LAST_UPDATED_BY                  NUMBER
 	,p_CREATION_DATE                   DATE
 	,p_CREATED_BY                      NUMBER
 	,p_LAST_UPDATE_LOGIN               NUMBER
		) IS

	CURSOR C1 IS
	SELECT CSI_COUNTER_USAGE_FORECAST_S.nextval
	FROM dual;
BEGIN
	IF (px_INSTANCE_FORECAST_ID IS NULL) OR (px_INSTANCE_FORECAST_ID = FND_API.G_MISS_NUM) THEN
		OPEN C1;
		FETCH C1 INTO px_INSTANCE_FORECAST_ID;
		CLOSE C1;
	END IF;

	INSERT INTO CSI_COUNTER_USAGE_FORECAST(
		INSTANCE_FORECAST_ID
		,COUNTER_ID
 		,USAGE_RATE
 		,USE_PAST_READING
 		,ACTIVE_START_DATE
 		,ACTIVE_END_DATE
 		,OBJECT_VERSION_NUMBER
 		,LAST_UPDATE_DATE
 		,LAST_UPDATED_BY
 		,CREATION_DATE
 		,CREATED_BY
 		,LAST_UPDATE_LOGIN
	)
	VALUES(
		px_INSTANCE_FORECAST_ID
		,decode(p_COUNTER_ID, FND_API.G_MISS_NUM, NULL, p_COUNTER_ID)
 		,decode(p_USAGE_RATE, FND_API.G_MISS_NUM, NULL, p_USAGE_RATE)
 		,decode(p_USE_PAST_READING, FND_API.G_MISS_NUM, NULL, p_USE_PAST_READING)
 		,decode(p_ACTIVE_START_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_ACTIVE_START_DATE)
 		,decode(p_ACTIVE_END_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_ACTIVE_END_DATE)
 		,decode(p_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, NULL, p_OBJECT_VERSION_NUMBER)
 		,decode(p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_LAST_UPDATE_DATE)
 		,decode(p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATED_BY)
 		,decode(p_CREATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_CREATION_DATE)
 		,decode(p_CREATED_BY, FND_API.G_MISS_NUM, NULL, p_CREATED_BY)
 		,decode(p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATE_LOGIN)
	);
END	Insert_Row;

PROCEDURE Update_Row(
   p_INSTANCE_FORECAST_ID             NUMBER
   ,p_COUNTER_ID                      NUMBER
   ,p_USAGE_RATE                      NUMBER
   ,p_USE_PAST_READING                NUMBER
   ,p_ACTIVE_START_DATE               DATE
   ,p_ACTIVE_END_DATE                 DATE
   ,p_OBJECT_VERSION_NUMBER           NUMBER
   ,p_LAST_UPDATE_DATE                DATE
   ,p_LAST_UPDATED_BY                  NUMBER
   ,p_CREATION_DATE                   DATE
   ,p_CREATED_BY                      NUMBER
   ,p_LAST_UPDATE_LOGIN               NUMBER
   ) IS
BEGIN
   UPDATE CSI_COUNTER_USAGE_FORECAST
   SET
      COUNTER_ID = decode(p_COUNTER_ID, NULL, COUNTER_ID, FND_API.G_MISS_NUM, NULL, p_COUNTER_ID)
      ,USAGE_RATE = decode(p_USAGE_RATE, NULL, USAGE_RATE, FND_API.G_MISS_NUM, NULL, p_USAGE_RATE)
      ,USE_PAST_READING = decode(p_USE_PAST_READING, NULL, USE_PAST_READING, FND_API.G_MISS_NUM, NULL, p_USE_PAST_READING)
      ,ACTIVE_START_DATE = decode(p_ACTIVE_START_DATE, NULL, ACTIVE_START_DATE, FND_API.G_MISS_DATE, NULL, p_ACTIVE_START_DATE)
      ,ACTIVE_END_DATE = decode(p_ACTIVE_END_DATE, NULL, ACTIVE_END_DATE, FND_API.G_MISS_DATE, NULL, p_ACTIVE_END_DATE)
      ,OBJECT_VERSION_NUMBER = decode(p_OBJECT_VERSION_NUMBER, NULL, OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, NULL, p_OBJECT_VERSION_NUMBER)
      ,LAST_UPDATE_DATE = decode(p_LAST_UPDATE_DATE, NULL, LAST_UPDATE_DATE, FND_API.G_MISS_DATE, NULL, p_LAST_UPDATE_DATE)
      ,LAST_UPDATED_BY = decode(p_LAST_UPDATED_BY, NULL, LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATED_BY)
      ,CREATION_DATE = decode(p_CREATION_DATE, NULL, CREATION_DATE, FND_API.G_MISS_DATE, NULL, p_CREATION_DATE)
      ,CREATED_BY = decode(p_CREATED_BY, NULL, CREATED_BY, FND_API.G_MISS_NUM, NULL, p_CREATED_BY)
      ,LAST_UPDATE_LOGIN = decode(p_LAST_UPDATE_LOGIN, NULL, LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATE_LOGIN)
   WHERE INSTANCE_FORECAST_ID = p_INSTANCE_FORECAST_ID;

   If (SQL%NOTFOUND) then
      RAISE NO_DATA_FOUND;
   End If;
END Update_Row;

PROCEDURE Lock_Row(
	p_INSTANCE_FORECAST_ID             NUMBER
	,p_COUNTER_ID                      NUMBER
 	,p_USAGE_RATE                      NUMBER
 	,p_USE_PAST_READING                NUMBER
 	,p_ACTIVE_START_DATE               DATE
 	,p_ACTIVE_END_DATE                 DATE
 	,p_OBJECT_VERSION_NUMBER           NUMBER
 	,p_LAST_UPDATE_DATE                DATE
 	,p_LAST_UPDATED_BY                  NUMBER
 	,p_CREATION_DATE                   DATE
 	,p_CREATED_BY                      NUMBER
 	,p_LAST_UPDATE_LOGIN               NUMBER
        ) IS

	CURSOR C1 IS
	SELECT *
	FROM CSI_COUNTER_USAGE_FORECAST
	WHERE INSTANCE_FORECAST_ID = p_INSTANCE_FORECAST_ID
	FOR UPDATE of INSTANCE_FORECAST_ID NOWAIT;
	Recinfo C1%ROWTYPE;
BEGIN
	OPEN C1;
	FETCH C1 INTO Recinfo;
	IF (C1%NOTFOUND) THEN
		CLOSE C1;
		FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
		APP_EXCEPTION.RAISE_EXCEPTION;
	END IF;
	CLOSE C1;

	IF (
		(Recinfo.INSTANCE_FORECAST_ID = p_INSTANCE_FORECAST_ID)
		AND ((Recinfo.COUNTER_ID = p_COUNTER_ID) OR ((Recinfo.COUNTER_ID IS NULL) AND (p_COUNTER_ID IS NULL)))
 		AND ((Recinfo.USAGE_RATE = p_USAGE_RATE) OR ((Recinfo.USAGE_RATE IS NULL) AND (p_USAGE_RATE IS NULL)))
 		AND ((Recinfo.USE_PAST_READING = p_USE_PAST_READING) OR ((Recinfo.USE_PAST_READING IS NULL) AND (p_USE_PAST_READING IS NULL)))
 		AND ((Recinfo.ACTIVE_START_DATE = p_ACTIVE_START_DATE) OR ((Recinfo.ACTIVE_START_DATE IS NULL) AND (p_ACTIVE_START_DATE IS NULL)))
 		AND ((Recinfo.ACTIVE_END_DATE = p_ACTIVE_END_DATE) OR ((Recinfo.ACTIVE_END_DATE IS NULL) AND (p_ACTIVE_END_DATE IS NULL)))
 		AND ((Recinfo.OBJECT_VERSION_NUMBER = p_OBJECT_VERSION_NUMBER) OR ((Recinfo.OBJECT_VERSION_NUMBER IS NULL) AND (p_OBJECT_VERSION_NUMBER IS NULL)))
 		AND ((Recinfo.LAST_UPDATE_DATE = p_LAST_UPDATE_DATE) OR ((Recinfo.LAST_UPDATE_DATE IS NULL) AND (p_LAST_UPDATE_DATE IS NULL)))
 		AND ((Recinfo.LAST_UPDATED_BY = p_LAST_UPDATED_BY) OR ((Recinfo.LAST_UPDATED_BY IS NULL) AND (p_LAST_UPDATED_BY IS NULL)))
 		AND ((Recinfo.CREATION_DATE = p_CREATION_DATE) OR ((Recinfo.CREATION_DATE IS NULL) AND (p_CREATION_DATE IS NULL)))
 		AND ((Recinfo.CREATED_BY = p_CREATED_BY) OR ((Recinfo.CREATED_BY IS NULL) AND (p_CREATED_BY IS NULL)))
 		AND ((Recinfo.LAST_UPDATE_LOGIN = p_LAST_UPDATE_LOGIN) OR ((Recinfo.LAST_UPDATE_LOGIN IS NULL) AND (p_LAST_UPDATE_LOGIN IS NULL)))
	) THEN
		return;
	ELSE
		FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
		APP_EXCEPTION.RAISE_EXCEPTION;
	END IF;
END	Lock_Row;

PROCEDURE Delete_Row(
	p_INSTANCE_FORECAST_ID             NUMBER
	) IS
BEGIN
	DELETE FROM CSI_COUNTER_USAGE_FORECAST
	WHERE INSTANCE_FORECAST_ID = p_INSTANCE_FORECAST_ID;
	IF (SQL%NOTFOUND) then
		RAISE NO_DATA_FOUND;
	END IF;
END	Delete_Row;

End CSI_CTR_USAGE_FORECAST_PKG;

/
