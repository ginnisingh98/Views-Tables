--------------------------------------------------------
--  DDL for Package Body IEX_DELINQUENCIES_ALL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_DELINQUENCIES_ALL_PKG" AS
/* $Header: iextdelb.pls 120.0 2004/01/24 03:21:48 appldev noship $ */

/* Insert_Row procedure */
PG_DEBUG NUMBER(2) := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));

PROCEDURE Insert_Row(x_rowid	IN OUT NOCOPY VARCHAR2
                    ,p_DELINQUENCY_ID           NUMBER
                    ,p_LAST_UPDATE_DATE         DATE
                    ,p_LAST_UPDATED_BY          NUMBER
                    ,p_LAST_UPDATE_LOGIN        NUMBER
                    ,p_CREATION_DATE            DATE
                    ,p_CREATED_BY               NUMBER
                    ,p_PROGRAM_ID               NUMBER
                    ,p_OBJECT_VERSION_NUMBER    NUMBER
                    ,p_PARTY_CUST_ID            NUMBER
                    ,p_PARTY_CLIENT_ID          NUMBER
                    ,p_CUST_ACCOUNT_ID          NUMBER
                    ,p_TRANSACTION_ID           NUMBER
                    ,p_PAYMENT_SCHEDULE_ID      NUMBER
                    ,p_AGING_BUCKET_LINE_ID     NUMBER
                    ,p_CASE_ID                  NUMBER
                    ,p_RESOURCE_ID              NUMBER
                    ,p_DUNN_YN                  VARCHAR2
                    ,p_AUTOASSIGN_YN            VARCHAR2
                    ,p_STATUS                   VARCHAR2
                    ,p_CAMPAIGN_SCHED_ID        NUMBER
                    ,p_ORG_ID                   NUMBER
                    ,p_REQUEST_ID               NUMBER
                    ,p_PROGRAM_APPLICATION_ID   NUMBER
                    ,p_PROGRAM_UPDATE_DATE      DATE
                    ,p_SECURITY_GROUP_ID        NUMBER
                    ,p_UNPAID_REASON_CODE       VARCHAR2
                    --,p_STRATEGY_ID              NUMBER
) IS
	CURSOR C IS SELECT ROWID FROM IEX_DELINQUENCIES_ALL
		WHERE DELINQUENCY_ID = p_DELINQUENCY_ID;

BEGIN
	INSERT INTO IEX_DELINQUENCIES_ALL
	(
		DELINQUENCY_ID
		,LAST_UPDATE_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_LOGIN
		,CREATION_DATE
		,CREATED_BY
		,PROGRAM_ID
		,OBJECT_VERSION_NUMBER
		,PARTY_CUST_ID
		,PARTY_CLIENT_ID
		,CUST_ACCOUNT_ID
		,TRANSACTION_ID
		,PAYMENT_SCHEDULE_ID
		,AGING_BUCKET_LINE_ID
		,CASE_ID
		,RESOURCE_ID
		,DUNN_YN
		,AUTOASSIGN_YN
		,STATUS
		,CAMPAIGN_SCHED_ID
		,ORG_ID
		,REQUEST_ID
		,PROGRAM_APPLICATION_ID
		,PROGRAM_UPDATE_DATE
		,SECURITY_GROUP_ID
		,UNPAID_REASON_CODE
		--,STRATEGY_ID
	) VALUES (
		p_DELINQUENCY_ID
		,p_LAST_UPDATE_DATE
		,p_LAST_UPDATED_BY
		,p_LAST_UPDATE_LOGIN
		,p_CREATION_DATE
		,p_CREATED_BY
		,p_PROGRAM_ID
		,p_OBJECT_VERSION_NUMBER
		,p_PARTY_CUST_ID
		,p_PARTY_CLIENT_ID
		,p_CUST_ACCOUNT_ID
		,p_TRANSACTION_ID
		,p_PAYMENT_SCHEDULE_ID
		,p_AGING_BUCKET_LINE_ID
		,p_CASE_ID
		,p_RESOURCE_ID
		,p_DUNN_YN
		,p_AUTOASSIGN_YN
		,p_STATUS
		,p_CAMPAIGN_SCHED_ID
		,p_ORG_ID
		,p_REQUEST_ID
		,p_PROGRAM_APPLICATION_ID
		,p_PROGRAM_UPDATE_DATE
		,p_SECURITY_GROUP_ID
		,p_UNPAID_REASON_CODE
		--,p_STRATEGY_ID
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
PROCEDURE Update_Row(x_rowid	VARCHAR2
                    ,p_DELINQUENCY_ID           NUMBER
                    ,p_LAST_UPDATE_DATE         DATE
                    ,p_LAST_UPDATED_BY          NUMBER
                    ,p_LAST_UPDATE_LOGIN        NUMBER
                    ,p_CREATION_DATE            DATE
                    ,p_CREATED_BY               NUMBER
                    ,p_PROGRAM_ID               NUMBER
                    ,p_OBJECT_VERSION_NUMBER    NUMBER
                    ,p_PARTY_CUST_ID            NUMBER
                    ,p_PARTY_CLIENT_ID          NUMBER
                    ,p_CUST_ACCOUNT_ID          NUMBER
                    ,p_TRANSACTION_ID           NUMBER
                    ,p_PAYMENT_SCHEDULE_ID      NUMBER
                    ,p_AGING_BUCKET_LINE_ID     NUMBER
                    ,p_CASE_ID                  NUMBER
                    ,p_RESOURCE_ID              NUMBER
                    ,p_DUNN_YN                  VARCHAR2
                    ,p_AUTOASSIGN_YN            VARCHAR2
                    ,p_STATUS                   VARCHAR2
                    ,p_CAMPAIGN_SCHED_ID        NUMBER
                    ,p_ORG_ID                   NUMBER
                    ,p_REQUEST_ID               NUMBER
                    ,p_PROGRAM_APPLICATION_ID   NUMBER
                    ,p_PROGRAM_UPDATE_DATE      DATE
                    ,p_SECURITY_GROUP_ID        NUMBER
                    ,p_UNPAID_REASON_CODE       VARCHAR2
                    --,p_STRATEGY_ID              NUMBER
) IS
BEGIN
	UPDATE IEX_DELINQUENCIES_ALL SET
		DELINQUENCY_ID = p_DELINQUENCY_ID
		,LAST_UPDATE_DATE = p_LAST_UPDATE_DATE
		,LAST_UPDATED_BY = p_LAST_UPDATED_BY
		,LAST_UPDATE_LOGIN = p_LAST_UPDATE_LOGIN
		,CREATION_DATE = p_CREATION_DATE
		,CREATED_BY = p_CREATED_BY
		,PROGRAM_ID = p_PROGRAM_ID
		,OBJECT_VERSION_NUMBER = p_OBJECT_VERSION_NUMBER
		,PARTY_CUST_ID = p_PARTY_CUST_ID
		,PARTY_CLIENT_ID = p_PARTY_CLIENT_ID
		,CUST_ACCOUNT_ID = p_CUST_ACCOUNT_ID
		,TRANSACTION_ID = p_TRANSACTION_ID
		,PAYMENT_SCHEDULE_ID = p_PAYMENT_SCHEDULE_ID
		,AGING_BUCKET_LINE_ID = p_AGING_BUCKET_LINE_ID
		,CASE_ID = p_CASE_ID
		,RESOURCE_ID = p_RESOURCE_ID
		,DUNN_YN = p_DUNN_YN
		,AUTOASSIGN_YN = p_AUTOASSIGN_YN
		,STATUS = p_STATUS
		,CAMPAIGN_SCHED_ID = p_CAMPAIGN_SCHED_ID
		,ORG_ID = p_ORG_ID
		,REQUEST_ID = p_REQUEST_ID
		,PROGRAM_APPLICATION_ID = p_PROGRAM_APPLICATION_ID
		,PROGRAM_UPDATE_DATE = p_PROGRAM_UPDATE_DATE
		,SECURITY_GROUP_ID = p_SECURITY_GROUP_ID
		,UNPAID_REASON_CODE = p_UNPAID_REASON_CODE
		--,STRATEGY_ID = p_STRATEGY_ID
	 WHERE rowid = x_rowid;

	if (sql%notfound) then
		raise no_data_found;
	end if;
END Update_Row;

/* Delete_Row procedure */
PROCEDURE Delete_Row(x_rowid VARCHAR2) IS
BEGIN
	DELETE FROM IEX_DELINQUENCIES_ALL
		WHERE rowid = x_rowid;

	if (sql%notfound) then
		raise no_data_found;
	end if;
END Delete_Row;

/* Lock_Row procedure */
PROCEDURE Lock_Row(x_rowid	VARCHAR2
                    ,p_DELINQUENCY_ID           NUMBER
                    ,p_LAST_UPDATE_DATE         DATE
                    ,p_LAST_UPDATED_BY          NUMBER
                    ,p_LAST_UPDATE_LOGIN        NUMBER
                    ,p_CREATION_DATE            DATE
                    ,p_CREATED_BY               NUMBER
                    ,p_PROGRAM_ID               NUMBER
                    ,p_OBJECT_VERSION_NUMBER    NUMBER
                    ,p_PARTY_CUST_ID            NUMBER
                    ,p_PARTY_CLIENT_ID          NUMBER
                    ,p_CUST_ACCOUNT_ID          NUMBER
                    ,p_TRANSACTION_ID           NUMBER
                    ,p_PAYMENT_SCHEDULE_ID      NUMBER
                    ,p_AGING_BUCKET_LINE_ID     NUMBER
                    ,p_CASE_ID                  NUMBER
                    ,p_RESOURCE_ID              NUMBER
                    ,p_DUNN_YN                  VARCHAR2
                    ,p_AUTOASSIGN_YN            VARCHAR2
                    ,p_STATUS                   VARCHAR2
                    ,p_CAMPAIGN_SCHED_ID        NUMBER
                    ,p_ORG_ID                   NUMBER
                    ,p_REQUEST_ID               NUMBER
                    ,p_PROGRAM_APPLICATION_ID   NUMBER
                    ,p_PROGRAM_UPDATE_DATE      DATE
                    ,p_SECURITY_GROUP_ID        NUMBER
                    ,p_UNPAID_REASON_CODE       VARCHAR2
                    --,p_STRATEGY_ID              NUMBER
) IS
	CURSOR C IS SELECT * FROM IEX_DELINQUENCIES_ALL
		WHERE rowid = x_rowid
		FOR UPDATE of DELINQUENCY_ID NOWAIT;
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
		(Recinfo.DELINQUENCY_ID = p_DELINQUENCY_ID)
		AND ( (Recinfo.LAST_UPDATE_DATE = p_LAST_UPDATE_DATE)
			OR ( (Recinfo.LAST_UPDATE_DATE IS NULL)
				AND (p_LAST_UPDATE_DATE IS NULL)))
		AND ( (Recinfo.LAST_UPDATED_BY = p_LAST_UPDATED_BY)
			OR ( (Recinfo.LAST_UPDATED_BY IS NULL)
				AND (p_LAST_UPDATED_BY IS NULL)))
		AND ( (Recinfo.LAST_UPDATE_LOGIN = p_LAST_UPDATE_LOGIN)
			OR ( (Recinfo.LAST_UPDATE_LOGIN IS NULL)
				AND (p_LAST_UPDATE_LOGIN IS NULL)))
		AND ( (Recinfo.CREATION_DATE = p_CREATION_DATE)
			OR ( (Recinfo.CREATION_DATE IS NULL)
				AND (p_CREATION_DATE IS NULL)))
		AND ( (Recinfo.CREATED_BY = p_CREATED_BY)
			OR ( (Recinfo.CREATED_BY IS NULL)
				AND (p_CREATED_BY IS NULL)))
		AND ( (Recinfo.PROGRAM_ID = p_PROGRAM_ID)
			OR ( (Recinfo.PROGRAM_ID IS NULL)
				AND (p_PROGRAM_ID IS NULL)))
		AND ( (Recinfo.OBJECT_VERSION_NUMBER = p_OBJECT_VERSION_NUMBER)
			OR ( (Recinfo.OBJECT_VERSION_NUMBER IS NULL)
				AND (p_OBJECT_VERSION_NUMBER IS NULL)))
		AND ( (Recinfo.PARTY_CUST_ID = p_PARTY_CUST_ID)
			OR ( (Recinfo.PARTY_CUST_ID IS NULL)
				AND (p_PARTY_CUST_ID IS NULL)))
		AND ( (Recinfo.PARTY_CLIENT_ID = p_PARTY_CLIENT_ID)
			OR ( (Recinfo.PARTY_CLIENT_ID IS NULL)
				AND (p_PARTY_CLIENT_ID IS NULL)))
		AND ( (Recinfo.CUST_ACCOUNT_ID = p_CUST_ACCOUNT_ID)
			OR ( (Recinfo.CUST_ACCOUNT_ID IS NULL)
				AND (p_CUST_ACCOUNT_ID IS NULL)))
		AND ( (Recinfo.TRANSACTION_ID = p_TRANSACTION_ID)
			OR ( (Recinfo.TRANSACTION_ID IS NULL)
				AND (p_TRANSACTION_ID IS NULL)))
		AND ( (Recinfo.PAYMENT_SCHEDULE_ID = p_PAYMENT_SCHEDULE_ID)
			OR ( (Recinfo.PAYMENT_SCHEDULE_ID IS NULL)
				AND (p_PAYMENT_SCHEDULE_ID IS NULL)))
		AND ( (Recinfo.AGING_BUCKET_LINE_ID = p_AGING_BUCKET_LINE_ID)
			OR ( (Recinfo.AGING_BUCKET_LINE_ID IS NULL)
				AND (p_AGING_BUCKET_LINE_ID IS NULL)))
		AND ( (Recinfo.CASE_ID = p_CASE_ID)
			OR ( (Recinfo.CASE_ID IS NULL)
				AND (p_CASE_ID IS NULL)))
		AND ( (Recinfo.RESOURCE_ID = p_RESOURCE_ID)
			OR ( (Recinfo.RESOURCE_ID IS NULL)
				AND (p_RESOURCE_ID IS NULL)))
		AND ( (Recinfo.DUNN_YN = p_DUNN_YN)
			OR ( (Recinfo.DUNN_YN IS NULL)
				AND (p_DUNN_YN IS NULL)))
		AND ( (Recinfo.AUTOASSIGN_YN = p_AUTOASSIGN_YN)
			OR ( (Recinfo.AUTOASSIGN_YN IS NULL)
				AND (p_AUTOASSIGN_YN IS NULL)))
		AND ( (Recinfo.STATUS = p_STATUS)
			OR ( (Recinfo.STATUS IS NULL)
				AND (p_STATUS IS NULL)))
		AND ( (Recinfo.CAMPAIGN_SCHED_ID = p_CAMPAIGN_SCHED_ID)
			OR ( (Recinfo.CAMPAIGN_SCHED_ID IS NULL)
				AND (p_CAMPAIGN_SCHED_ID IS NULL)))
		AND ( (Recinfo.ORG_ID = p_ORG_ID)
			OR ( (Recinfo.ORG_ID IS NULL)
				AND (p_ORG_ID IS NULL)))
		AND ( (Recinfo.REQUEST_ID = p_REQUEST_ID)
			OR ( (Recinfo.REQUEST_ID IS NULL)
				AND (p_REQUEST_ID IS NULL)))
		AND ( (Recinfo.PROGRAM_APPLICATION_ID = p_PROGRAM_APPLICATION_ID)
			OR ( (Recinfo.PROGRAM_APPLICATION_ID IS NULL)
				AND (p_PROGRAM_APPLICATION_ID IS NULL)))
		AND ( (Recinfo.PROGRAM_UPDATE_DATE = p_PROGRAM_UPDATE_DATE)
			OR ( (Recinfo.PROGRAM_UPDATE_DATE IS NULL)
				AND (p_PROGRAM_UPDATE_DATE IS NULL)))
		AND ( (Recinfo.SECURITY_GROUP_ID = p_SECURITY_GROUP_ID)
			OR ( (Recinfo.SECURITY_GROUP_ID IS NULL)
				AND (p_SECURITY_GROUP_ID IS NULL)))
		AND ( (Recinfo.UNPAID_REASON_CODE = p_UNPAID_REASON_CODE)
			OR ( (Recinfo.UNPAID_REASON_CODE IS NULL)
				AND (p_UNPAID_REASON_CODE IS NULL)))
		--AND ( (Recinfo.STRATEGY_ID = p_STRATEGY_ID)
			--OR ( (Recinfo.STRATEGY_ID IS NULL)
				--AND (p_STRATEGY_ID IS NULL)))
	   ) THEN
		return;
	ELSE
		FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
		APP_EXCEPTION.Raise_Exception;
	END IF;
END Lock_Row;
END;


/
