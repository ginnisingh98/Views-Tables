--------------------------------------------------------
--  DDL for Package Body IEX_DISPUTES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_DISPUTES_PKG" AS
/* $Header: iextdisb.pls 120.0 2004/01/24 03:21:51 appldev noship $ */

/* Insert_Row procedure */
PG_DEBUG NUMBER(2) := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));

PROCEDURE Insert_Row(x_rowid              IN OUT NOCOPY VARCHAR2
                    ,p_DISPUTE_ID         NUMBER
                    ,p_LAST_UPDATE_DATE   DATE
                    ,p_LAST_UPDATED_BY    NUMBER
                    ,p_CREATION_DATE      DATE
                    ,p_CREATED_BY         NUMBER
                    ,p_LAST_UPDATE_LOGIN  NUMBER
                    ,p_REQUEST_ID         NUMBER
                    ,p_PROGRAM_APPLICATION_ID   NUMBER
                    ,p_PROGRAM_ID               NUMBER
                    ,p_PROGRAM_UPDATE_DATE      DATE
                    ,p_CM_REQUEST_ID            NUMBER
                    ,p_DISPUTE_SECTION          VARCHAR2
                    ,p_CAMPAIGN_SCHED_ID        NUMBER
                    ,p_ATTRIBUTE_CATEGORY       VARCHAR2
                    ,p_ATTRIBUTE1       VARCHAR2
                    ,p_ATTRIBUTE2       VARCHAR2
                    ,p_ATTRIBUTE3       VARCHAR2
                    ,p_ATTRIBUTE4       VARCHAR2
                    ,p_ATTRIBUTE5       VARCHAR2
                    ,p_ATTRIBUTE6       VARCHAR2
                    ,p_ATTRIBUTE7       VARCHAR2
                    ,p_ATTRIBUTE8       VARCHAR2
                    ,p_ATTRIBUTE9       VARCHAR2
                    ,p_ATTRIBUTE10      VARCHAR2
                    ,p_ATTRIBUTE11      VARCHAR2
                    ,p_ATTRIBUTE12      VARCHAR2
                    ,p_ATTRIBUTE13      VARCHAR2
                    ,p_ATTRIBUTE14      VARCHAR2
                    ,p_ATTRIBUTE15      VARCHAR2
                    ,p_DELINQUENCY_ID   NUMBER
            ) IS
	CURSOR C IS SELECT ROWID FROM IEX_DISPUTES
		WHERE DISPUTE_ID = p_DISPUTE_ID;

BEGIN
	INSERT INTO IEX_DISPUTES
	(
		DISPUTE_ID
		,LAST_UPDATE_DATE
		,LAST_UPDATED_BY
		,CREATION_DATE
		,CREATED_BY
		,LAST_UPDATE_LOGIN
		,REQUEST_ID
		,PROGRAM_APPLICATION_ID
		,PROGRAM_ID
		,PROGRAM_UPDATE_DATE
		,CM_REQUEST_ID
		,DISPUTE_SECTION
		,CAMPAIGN_SCHED_ID
		,ATTRIBUTE_CATEGORY
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
		,DELINQUENCY_ID
	) VALUES (
		p_DISPUTE_ID
		,p_LAST_UPDATE_DATE
		,p_LAST_UPDATED_BY
		,p_CREATION_DATE
		,p_CREATED_BY
		,p_LAST_UPDATE_LOGIN
		,p_REQUEST_ID
		,p_PROGRAM_APPLICATION_ID
		,p_PROGRAM_ID
		,p_PROGRAM_UPDATE_DATE
		,p_CM_REQUEST_ID
		,p_DISPUTE_SECTION
		,p_CAMPAIGN_SCHED_ID
		,p_ATTRIBUTE_CATEGORY
		,p_ATTRIBUTE1
		,p_ATTRIBUTE2
		,p_ATTRIBUTE3
		,p_ATTRIBUTE4
		,p_ATTRIBUTE5
		,p_ATTRIBUTE6
		,p_ATTRIBUTE7
		,p_ATTRIBUTE8
		,p_ATTRIBUTE9
		,p_ATTRIBUTE10
		,p_ATTRIBUTE11
		,p_ATTRIBUTE12
		,p_ATTRIBUTE13
		,p_ATTRIBUTE14
		,p_ATTRIBUTE15
		,p_DELINQUENCY_ID
	);

	OPEN C;
	FETCH C INTO x_rowid;
	IF (C%NOTFOUND) THEN
		CLOSE C;
		RAISE NO_DATA_FOUND;
	END IF;
	CLOSE C;
END Insert_Row;

/* Update_Row procedure */
PROCEDURE Update_Row(x_rowid            VARCHAR2
                    ,p_DISPUTE_ID       NUMBER
                    ,p_LAST_UPDATE_DATE DATE
                    ,p_LAST_UPDATED_BY  NUMBER
                    ,p_CREATION_DATE    DATE
                    ,p_CREATED_BY       NUMBER
                    ,p_LAST_UPDATE_LOGIN        NUMBER
                    ,p_REQUEST_ID               NUMBER
                    ,p_PROGRAM_APPLICATION_ID   NUMBER
                    ,p_PROGRAM_ID               NUMBER
                    ,p_PROGRAM_UPDATE_DATE      DATE
                    ,p_CM_REQUEST_ID            NUMBER
                    ,p_DISPUTE_SECTION          VARCHAR2
                    ,p_CAMPAIGN_SCHED_ID        NUMBER
                    ,p_ATTRIBUTE_CATEGORY       VARCHAR2
                    ,p_ATTRIBUTE1       VARCHAR2
                    ,p_ATTRIBUTE2       VARCHAR2
                    ,p_ATTRIBUTE3       VARCHAR2
                    ,p_ATTRIBUTE4       VARCHAR2
                    ,p_ATTRIBUTE5       VARCHAR2
                    ,p_ATTRIBUTE6       VARCHAR2
                    ,p_ATTRIBUTE7       VARCHAR2
                    ,p_ATTRIBUTE8       VARCHAR2
                    ,p_ATTRIBUTE9       VARCHAR2
                    ,p_ATTRIBUTE10      VARCHAR2
                    ,p_ATTRIBUTE11      VARCHAR2
                    ,p_ATTRIBUTE12      VARCHAR2
                    ,p_ATTRIBUTE13      VARCHAR2
                    ,p_ATTRIBUTE14      VARCHAR2
                    ,p_ATTRIBUTE15      VARCHAR2
                    ,p_DELINQUENCY_ID       NUMBER
                ) IS
BEGIN
	UPDATE IEX_DISPUTES SET
		DISPUTE_ID = p_DISPUTE_ID
		,LAST_UPDATE_DATE = p_LAST_UPDATE_DATE
		,LAST_UPDATED_BY = p_LAST_UPDATED_BY
		,CREATION_DATE = p_CREATION_DATE
		,CREATED_BY = p_CREATED_BY
		,LAST_UPDATE_LOGIN = p_LAST_UPDATE_LOGIN
		,REQUEST_ID = p_REQUEST_ID
		,PROGRAM_APPLICATION_ID = p_PROGRAM_APPLICATION_ID
		,PROGRAM_ID = p_PROGRAM_ID
		,PROGRAM_UPDATE_DATE = p_PROGRAM_UPDATE_DATE
		,CM_REQUEST_ID = p_CM_REQUEST_ID
		,DISPUTE_SECTION = p_DISPUTE_SECTION
		,CAMPAIGN_SCHED_ID = p_CAMPAIGN_SCHED_ID
		,ATTRIBUTE_CATEGORY = p_ATTRIBUTE_CATEGORY
		,ATTRIBUTE1 = p_ATTRIBUTE1
		,ATTRIBUTE2 = p_ATTRIBUTE2
		,ATTRIBUTE3 = p_ATTRIBUTE3
		,ATTRIBUTE4 = p_ATTRIBUTE4
		,ATTRIBUTE5 = p_ATTRIBUTE5
		,ATTRIBUTE6 = p_ATTRIBUTE6
		,ATTRIBUTE7 = p_ATTRIBUTE7
		,ATTRIBUTE8 = p_ATTRIBUTE8
		,ATTRIBUTE9 = p_ATTRIBUTE9
		,ATTRIBUTE10 = p_ATTRIBUTE10
		,ATTRIBUTE11 = p_ATTRIBUTE11
		,ATTRIBUTE12 = p_ATTRIBUTE12
		,ATTRIBUTE13 = p_ATTRIBUTE13
		,ATTRIBUTE14 = p_ATTRIBUTE14
		,ATTRIBUTE15 = p_ATTRIBUTE15
		,DELINQUENCY_ID = p_DELINQUENCY_ID
	 WHERE rowid = x_rowid;

	if (sql%notfound) then
		raise no_data_found;
	end if;
END Update_Row;

/* Delete_Row procedure */
PROCEDURE Delete_Row(x_rowid VARCHAR2) IS
BEGIN
	DELETE FROM IEX_DISPUTES
		WHERE rowid = x_rowid;

	if (sql%notfound) then
		raise no_data_found;
	end if;
END Delete_Row;

/* Lock_Row procedure */
PROCEDURE Lock_Row(x_rowid	VARCHAR2
                   ,p_DISPUTE_ID           NUMBER
                   ,p_LAST_UPDATE_DATE     DATE
                   ,p_LAST_UPDATED_BY      NUMBER
                   ,p_CREATION_DATE        DATE
                   ,p_CREATED_BY           NUMBER
                   ,p_LAST_UPDATE_LOGIN    NUMBER
                   ,p_REQUEST_ID           NUMBER
                   ,p_PROGRAM_APPLICATION_ID       NUMBER
                   ,p_PROGRAM_ID                   NUMBER
                   ,p_PROGRAM_UPDATE_DATE          DATE
                   ,p_CM_REQUEST_ID                NUMBER
                   ,p_DISPUTE_SECTION              VARCHAR2
                   ,p_CAMPAIGN_SCHED_ID            NUMBER
                   ,p_ATTRIBUTE_CATEGORY           VARCHAR2
                   ,p_ATTRIBUTE1       VARCHAR2
                   ,p_ATTRIBUTE2       VARCHAR2
                   ,p_ATTRIBUTE3       VARCHAR2
                   ,p_ATTRIBUTE4       VARCHAR2
                   ,p_ATTRIBUTE5       VARCHAR2
                   ,p_ATTRIBUTE6       VARCHAR2
                   ,p_ATTRIBUTE7       VARCHAR2
                   ,p_ATTRIBUTE8       VARCHAR2
                   ,p_ATTRIBUTE9       VARCHAR2
                   ,p_ATTRIBUTE10      VARCHAR2
                   ,p_ATTRIBUTE11      VARCHAR2
                   ,p_ATTRIBUTE12      VARCHAR2
                   ,p_ATTRIBUTE13      VARCHAR2
                   ,p_ATTRIBUTE14      VARCHAR2
                   ,p_ATTRIBUTE15      VARCHAR2
                   ,p_DELINQUENCY_ID       NUMBER
                ) IS
	CURSOR C IS SELECT * FROM IEX_DISPUTES
		WHERE rowid = x_rowid
		FOR UPDATE of DISPUTE_ID NOWAIT;
	Recinfo C%ROWTYPE;
BEGIN
	OPEN C;
	FETCH C INTO Recinfo;
	IF (C%NOTFOUND) THEN
		CLOSE C;
		FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
		APP_EXCEPTION.Raise_Exception;
	END IF;
	CLOSE C;

	IF (
		(Recinfo.DISPUTE_ID = p_DISPUTE_ID)
		AND ( (Recinfo.LAST_UPDATE_DATE = p_LAST_UPDATE_DATE)
			OR ( (Recinfo.LAST_UPDATE_DATE IS NULL)
				AND (p_LAST_UPDATE_DATE IS NULL)))
		AND ( (Recinfo.LAST_UPDATED_BY = p_LAST_UPDATED_BY)
			OR ( (Recinfo.LAST_UPDATED_BY IS NULL)
				AND (p_LAST_UPDATED_BY IS NULL)))
		AND ( (Recinfo.CREATION_DATE = p_CREATION_DATE)
			OR ( (Recinfo.CREATION_DATE IS NULL)
				AND (p_CREATION_DATE IS NULL)))
		AND ( (Recinfo.CREATED_BY = p_CREATED_BY)
			OR ( (Recinfo.CREATED_BY IS NULL)
				AND (p_CREATED_BY IS NULL)))
		AND ( (Recinfo.LAST_UPDATE_LOGIN = p_LAST_UPDATE_LOGIN)
			OR ( (Recinfo.LAST_UPDATE_LOGIN IS NULL)
				AND (p_LAST_UPDATE_LOGIN IS NULL)))
		AND ( (Recinfo.REQUEST_ID = p_REQUEST_ID)
			OR ( (Recinfo.REQUEST_ID IS NULL)
				AND (p_REQUEST_ID IS NULL)))
		AND ( (Recinfo.PROGRAM_APPLICATION_ID = p_PROGRAM_APPLICATION_ID)
			OR ( (Recinfo.PROGRAM_APPLICATION_ID IS NULL)
				AND (p_PROGRAM_APPLICATION_ID IS NULL)))
		AND ( (Recinfo.PROGRAM_ID = p_PROGRAM_ID)
			OR ( (Recinfo.PROGRAM_ID IS NULL)
				AND (p_PROGRAM_ID IS NULL)))
		AND ( (Recinfo.PROGRAM_UPDATE_DATE = p_PROGRAM_UPDATE_DATE)
			OR ( (Recinfo.PROGRAM_UPDATE_DATE IS NULL)
				AND (p_PROGRAM_UPDATE_DATE IS NULL)))
		AND ( (Recinfo.CM_REQUEST_ID = p_CM_REQUEST_ID)
			OR ( (Recinfo.CM_REQUEST_ID IS NULL)
				AND (p_CM_REQUEST_ID IS NULL)))
		AND ( (Recinfo.DISPUTE_SECTION = p_DISPUTE_SECTION)
			OR ( (Recinfo.DISPUTE_SECTION IS NULL)
				AND (p_DISPUTE_SECTION IS NULL)))
		AND ( (Recinfo.CAMPAIGN_SCHED_ID = p_CAMPAIGN_SCHED_ID)
			OR ( (Recinfo.CAMPAIGN_SCHED_ID IS NULL)
				AND (p_CAMPAIGN_SCHED_ID IS NULL)))
		AND ( (Recinfo.ATTRIBUTE_CATEGORY = p_ATTRIBUTE_CATEGORY)
			OR ( (Recinfo.ATTRIBUTE_CATEGORY IS NULL)
				AND (p_ATTRIBUTE_CATEGORY IS NULL)))
		AND ( (Recinfo.ATTRIBUTE1 = p_ATTRIBUTE1)
			OR ( (Recinfo.ATTRIBUTE1 IS NULL)
				AND (p_ATTRIBUTE1 IS NULL)))
		AND ( (Recinfo.ATTRIBUTE2 = p_ATTRIBUTE2)
			OR ( (Recinfo.ATTRIBUTE2 IS NULL)
				AND (p_ATTRIBUTE2 IS NULL)))
		AND ( (Recinfo.ATTRIBUTE3 = p_ATTRIBUTE3)
			OR ( (Recinfo.ATTRIBUTE3 IS NULL)
				AND (p_ATTRIBUTE3 IS NULL)))
		AND ( (Recinfo.ATTRIBUTE4 = p_ATTRIBUTE4)
			OR ( (Recinfo.ATTRIBUTE4 IS NULL)
				AND (p_ATTRIBUTE4 IS NULL)))
		AND ( (Recinfo.ATTRIBUTE5 = p_ATTRIBUTE5)
			OR ( (Recinfo.ATTRIBUTE5 IS NULL)
				AND (p_ATTRIBUTE5 IS NULL)))
		AND ( (Recinfo.ATTRIBUTE6 = p_ATTRIBUTE6)
			OR ( (Recinfo.ATTRIBUTE6 IS NULL)
				AND (p_ATTRIBUTE6 IS NULL)))
		AND ( (Recinfo.ATTRIBUTE7 = p_ATTRIBUTE7)
			OR ( (Recinfo.ATTRIBUTE7 IS NULL)
				AND (p_ATTRIBUTE7 IS NULL)))
		AND ( (Recinfo.ATTRIBUTE8 = p_ATTRIBUTE8)
			OR ( (Recinfo.ATTRIBUTE8 IS NULL)
				AND (p_ATTRIBUTE8 IS NULL)))
		AND ( (Recinfo.ATTRIBUTE9 = p_ATTRIBUTE9)
			OR ( (Recinfo.ATTRIBUTE9 IS NULL)
				AND (p_ATTRIBUTE9 IS NULL)))
		AND ( (Recinfo.ATTRIBUTE10 = p_ATTRIBUTE10)
			OR ( (Recinfo.ATTRIBUTE10 IS NULL)
				AND (p_ATTRIBUTE10 IS NULL)))
		AND ( (Recinfo.ATTRIBUTE11 = p_ATTRIBUTE11)
			OR ( (Recinfo.ATTRIBUTE11 IS NULL)
				AND (p_ATTRIBUTE11 IS NULL)))
		AND ( (Recinfo.ATTRIBUTE12 = p_ATTRIBUTE12)
			OR ( (Recinfo.ATTRIBUTE12 IS NULL)
				AND (p_ATTRIBUTE12 IS NULL)))
		AND ( (Recinfo.ATTRIBUTE13 = p_ATTRIBUTE13)
			OR ( (Recinfo.ATTRIBUTE13 IS NULL)
				AND (p_ATTRIBUTE13 IS NULL)))
		AND ( (Recinfo.ATTRIBUTE14 = p_ATTRIBUTE14)
			OR ( (Recinfo.ATTRIBUTE14 IS NULL)
				AND (p_ATTRIBUTE14 IS NULL)))
		AND ( (Recinfo.ATTRIBUTE15 = p_ATTRIBUTE15)
			OR ( (Recinfo.ATTRIBUTE15 IS NULL)
				AND (p_ATTRIBUTE15 IS NULL)))
		AND ( (Recinfo.DELINQUENCY_ID = p_DELINQUENCY_ID)
			OR ( (Recinfo.DELINQUENCY_ID IS NULL)
				AND (p_DELINQUENCY_ID IS NULL)))
	   ) THEN
		return;
	ELSE
		FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
		APP_EXCEPTION.Raise_Exception;
	END IF;
END Lock_Row;
END;


/
