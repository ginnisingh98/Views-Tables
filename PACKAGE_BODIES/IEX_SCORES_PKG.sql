--------------------------------------------------------
--  DDL for Package Body IEX_SCORES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_SCORES_PKG" AS
/* $Header: iextscob.pls 120.3 2004/10/28 17:51:46 clchang ship $ */

/* Insert_Row procedure */
PG_DEBUG NUMBER(2) ;

PROCEDURE Insert_Row(x_rowid                    IN OUT NOCOPY   VARCHAR2
                    ,p_SCORE_ID                 NUMBER
                    ,p_SCORE_NAME               VARCHAR2
                    ,p_SECURITY_GROUP_ID        NUMBER
                    ,p_SCORE_DESCRIPTION        VARCHAR2
                    ,p_ENABLED_FLAG             VARCHAR2
                    ,p_VALID_FROM_DT            DATE
                    ,p_VALID_TO_DT              DATE
                    ,p_CAMPAIGN_SCHED_ID        NUMBER
                    ,p_JTF_OBJECT_CODE          VARCHAR2
                    ,p_CONCURRENT_PROG_NAME     VARCHAR2
                    ,p_LAST_UPDATE_DATE         DATE
                    ,p_LAST_UPDATED_BY          NUMBER
                    ,p_CREATION_DATE            DATE
                    ,p_CREATED_BY               NUMBER
                    ,p_LAST_UPDATE_LOGIN        NUMBER
                    ,p_REQUEST_ID               NUMBER
                    ,p_PROGRAM_APPLICATION_ID   NUMBER
                    ,p_PROGRAM_ID               NUMBER
                    ,p_PROGRAM_UPDATE_DATE      DATE
                    ,p_STATUS_DETERMINATION     VARCHAR2
                    ,p_WEIGHT_REQUIRED          VARCHAR2
                    ,p_SCORE_RANGE_LOW          VARCHAR2
                    ,p_SCORE_RANGE_HIGH         VARCHAR2
                    ,p_OUT_OF_RANGE_RULE        VARCHAR2
) IS
	CURSOR C IS SELECT ROWID FROM IEX_SCORES
		WHERE SCORE_ID = p_SCORE_ID;

  l_status_determination varchar2(1);
  l_weight_required varchar2(3);
  l_score_range_low varchar2(1000);
  l_score_range_high varchar2(1000);
  l_out_of_range_rule varchar2(20);

BEGIN
  l_status_determination := p_status_determination;
  l_weight_required := p_weight_required;
  l_score_range_low := p_score_range_low;
  l_score_range_high := p_score_range_high;
  l_out_of_range_rule := p_out_of_range_rule;

  IF (l_status_determination is null) then
      l_status_determination := 'N';
  end if;
  IF (l_weight_required is null) then
      l_weight_required := '1';
  end if;
  IF (l_score_range_low is null) then
      l_score_range_low := '1';
  end if;
  IF (l_score_range_high is null) then
      l_score_range_high := '100';
  end if;
  IF (l_out_of_range_rule is null) then
      l_out_of_range_rule := 'CLOSEST';
  end if;

	INSERT INTO IEX_SCORES
	(
		SCORE_ID
		,SCORE_NAME
		,SECURITY_GROUP_ID
		,SCORE_DESCRIPTION
		,ENABLED_FLAG
		,VALID_FROM_DT
		,VALID_TO_DT
		,CAMPAIGN_SCHED_ID
		,JTF_OBJECT_CODE
    ,CONCURRENT_PROG_NAME
		,LAST_UPDATE_DATE
		,LAST_UPDATED_BY
		,CREATION_DATE
		,CREATED_BY
		,LAST_UPDATE_LOGIN
		,REQUEST_ID
		,PROGRAM_APPLICATION_ID
		,PROGRAM_ID
    ,PROGRAM_UPDATE_DATE
    ,STATUS_DETERMINATION
    ,WEIGHT_REQUIRED
    ,SCORE_RANGE_LOW
    ,SCORE_RANGE_HIGH
    ,OUT_OF_RANGE_RULE
	) VALUES (
		p_SCORE_ID
		,p_SCORE_NAME
		,p_SECURITY_GROUP_ID
		,p_SCORE_DESCRIPTION
		,p_ENABLED_FLAG
		,p_VALID_FROM_DT
		,p_VALID_TO_DT
		,p_CAMPAIGN_SCHED_ID
		,p_JTF_OBJECT_CODE
    ,p_CONCURRENT_PROG_NAME
		,p_LAST_UPDATE_DATE
		,p_LAST_UPDATED_BY
		,p_CREATION_DATE
		,p_CREATED_BY
		,p_LAST_UPDATE_LOGIN
		,p_REQUEST_ID
		,p_PROGRAM_APPLICATION_ID
		,p_PROGRAM_ID
		,p_PROGRAM_UPDATE_DATE
    ,l_STATUS_DETERMINATION
    ,l_WEIGHT_REQUIRED
    ,l_SCORE_RANGE_LOW
    ,l_SCORE_RANGE_HIGH
    ,l_OUT_OF_RANGE_RULE
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
PROCEDURE Update_Row(x_rowid                    VARCHAR2
                    ,p_SCORE_ID                 NUMBER
                    ,p_SCORE_NAME               VARCHAR2
                    ,p_SECURITY_GROUP_ID        NUMBER
                    ,p_SCORE_DESCRIPTION        VARCHAR2
                    ,p_ENABLED_FLAG             VARCHAR2
                    ,p_VALID_FROM_DT            DATE
                    ,p_VALID_TO_DT              DATE
                    ,p_CAMPAIGN_SCHED_ID        NUMBER
                    ,p_JTF_OBJECT_CODE          VARCHAR2
                    ,p_CONCURRENT_PROG_NAME     VARCHAR2
                    ,p_LAST_UPDATE_DATE         DATE
                    ,p_LAST_UPDATED_BY          NUMBER
                    ,p_CREATION_DATE            DATE
                    ,p_CREATED_BY               NUMBER
                    ,p_LAST_UPDATE_LOGIN        NUMBER
                    ,p_REQUEST_ID               NUMBER
                    ,p_PROGRAM_APPLICATION_ID   NUMBER
                    ,p_PROGRAM_ID               NUMBER
                    ,p_PROGRAM_UPDATE_DATE      DATE
                    ,p_STATUS_DETERMINATION     VARCHAR2
                    ,p_WEIGHT_REQUIRED          VARCHAR2
                    ,p_SCORE_RANGE_LOW          VARCHAR2
                    ,p_SCORE_RANGE_HIGH         VARCHAR2
                    ,p_OUT_OF_RANGE_RULE        VARCHAR2
) IS
  l_status_determination varchar2(1);
  l_weight_required varchar2(3);
  l_score_range_low varchar2(1000);
  l_score_range_high varchar2(1000);
  l_out_of_range_rule varchar2(20);
BEGIN
  l_status_determination := p_status_determination;
  l_weight_required := p_weight_required;
  l_score_range_low := p_score_range_low;
  l_score_range_high := p_score_range_high;
  l_out_of_range_rule := p_out_of_range_rule;

  IF (l_status_determination is null) then
      l_status_determination := 'N';
  end if;
  IF (l_weight_required is null) then
      l_weight_required := '1';
  end if;
  IF (l_score_range_low is null) then
      l_score_range_low := '1';
  end if;
  IF (l_score_range_high is null) then
      l_score_range_high := '100';
  end if;
  IF (l_out_of_range_rule is null) then
      l_out_of_range_rule := 'CLOSEST';
  end if;

	UPDATE IEX_SCORES SET
		SCORE_ID = p_SCORE_ID
		,SCORE_NAME = p_SCORE_NAME
		,SECURITY_GROUP_ID = p_SECURITY_GROUP_ID
		,SCORE_DESCRIPTION = p_SCORE_DESCRIPTION
		,ENABLED_FLAG = p_ENABLED_FLAG
		,VALID_FROM_DT = p_VALID_FROM_DT
		,VALID_TO_DT = p_VALID_TO_DT
		,CAMPAIGN_SCHED_ID = p_CAMPAIGN_SCHED_ID
		,JTF_OBJECT_CODE = p_JTF_OBJECT_CODE
    ,CONCURRENT_PROG_NAME = p_CONCURRENT_PROG_NAME
		,LAST_UPDATE_DATE = p_LAST_UPDATE_DATE
		,LAST_UPDATED_BY = p_LAST_UPDATED_BY
		,CREATION_DATE = p_CREATION_DATE
		,CREATED_BY = p_CREATED_BY
		,LAST_UPDATE_LOGIN = p_LAST_UPDATE_LOGIN
		,REQUEST_ID = p_REQUEST_ID
		,PROGRAM_APPLICATION_ID = p_PROGRAM_APPLICATION_ID
		,PROGRAM_ID = p_PROGRAM_ID
		,PROGRAM_UPDATE_DATE = p_PROGRAM_UPDATE_DATE
    ,STATUS_DETERMINATION    = l_STATUS_DETERMINATION
    ,WEIGHT_REQUIRED    = l_WEIGHT_REQUIRED
    ,SCORE_RANGE_LOW    = l_SCORE_RANGE_LOW
    ,SCORE_RANGE_HIGH    = l_SCORE_RANGE_HIGH
    ,OUT_OF_RANGE_RULE    = l_OUT_OF_RANGE_RULE
	 WHERE rowid = x_rowid;

	if (sql%notfound) then
		raise no_data_found;
	end if;
END Update_Row;

/* Delete_Row procedure */
PROCEDURE Delete_Row(x_rowid VARCHAR2) IS
BEGIN
	DELETE FROM IEX_SCORES
		WHERE rowid = x_rowid;

	if (sql%notfound) then
		raise no_data_found;
	end if;
END Delete_Row;

/* Lock_Row procedure */
PROCEDURE Lock_Row(x_rowid                      VARCHAR2
                   ,p_SCORE_ID                  NUMBER
                   ,p_SCORE_NAME                VARCHAR2
                   ,p_SECURITY_GROUP_ID         NUMBER
                   ,p_SCORE_DESCRIPTION         VARCHAR2
                   ,p_ENABLED_FLAG              VARCHAR2
                   ,p_VALID_FROM_DT             DATE
                   ,p_VALID_TO_DT               DATE
                   ,p_CAMPAIGN_SCHED_ID         NUMBER
                   ,p_JTF_OBJECT_CODE           VARCHAR2
                   ,p_CONCURRENT_PROG_NAME      VARCHAR2
                   ,p_LAST_UPDATE_DATE          DATE
                   ,p_LAST_UPDATED_BY           NUMBER
                   ,p_CREATION_DATE             DATE
                   ,p_CREATED_BY                NUMBER
                   ,p_LAST_UPDATE_LOGIN         NUMBER
                   ,p_REQUEST_ID                NUMBER
                   ,p_PROGRAM_APPLICATION_ID    NUMBER
                   ,p_PROGRAM_ID                NUMBER
                   ,p_PROGRAM_UPDATE_DATE       DATE
                   ,p_STATUS_DETERMINATION     VARCHAR2
                   ,p_WEIGHT_REQUIRED          VARCHAR2
                   ,p_SCORE_RANGE_LOW          VARCHAR2
                   ,p_SCORE_RANGE_HIGH         VARCHAR2
                   ,p_OUT_OF_RANGE_RULE        VARCHAR2
) IS
	CURSOR C IS SELECT * FROM IEX_SCORES
		WHERE rowid = x_rowid
		FOR UPDATE of SCORE_ID NOWAIT;
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
		(Recinfo.SCORE_ID = p_SCORE_ID)
		AND ( (Recinfo.SCORE_NAME = p_SCORE_NAME)
			OR ( (Recinfo.SCORE_NAME IS NULL)
				AND (p_SCORE_NAME IS NULL)))
		AND ( (Recinfo.SECURITY_GROUP_ID = p_SECURITY_GROUP_ID)
			OR ( (Recinfo.SECURITY_GROUP_ID IS NULL)
				AND (p_SECURITY_GROUP_ID IS NULL)))
		AND ( (Recinfo.SCORE_DESCRIPTION = p_SCORE_DESCRIPTION)
			OR ( (Recinfo.SCORE_DESCRIPTION IS NULL)
				AND (p_SCORE_DESCRIPTION IS NULL)))
		AND ( (Recinfo.ENABLED_FLAG = p_ENABLED_FLAG)
			OR ( (Recinfo.ENABLED_FLAG IS NULL)
				AND (p_ENABLED_FLAG IS NULL)))
		AND ( (Recinfo.VALID_FROM_DT = p_VALID_FROM_DT)
			OR ( (Recinfo.VALID_FROM_DT IS NULL)
				AND (p_VALID_FROM_DT IS NULL)))
		AND ( (Recinfo.VALID_TO_DT = p_VALID_TO_DT)
			OR ( (Recinfo.VALID_TO_DT IS NULL)
				AND (p_VALID_TO_DT IS NULL)))
		AND ( (Recinfo.CAMPAIGN_SCHED_ID = p_CAMPAIGN_SCHED_ID)
			OR ( (Recinfo.CAMPAIGN_SCHED_ID IS NULL)
				AND (p_CAMPAIGN_SCHED_ID IS NULL)))
		AND ( (Recinfo.JTF_OBJECT_CODE = p_JTF_OBJECT_CODE)
			OR ( (Recinfo.JTF_OBJECT_CODE IS NULL)
				AND (p_JTF_OBJECT_CODE IS NULL)))
    AND ( (Recinfo.CONCURRENT_PROG_NAME = p_CONCURRENT_PROG_NAME)
      OR ( (Recinfo.CONCURRENT_PROG_NAME IS NULL)
        AND (p_CONCURRENT_PROG_NAME IS NULL)))
    AND ( (Recinfo.WEIGHT_REQUIRED = p_WEIGHT_REQUIRED)
      OR ( (Recinfo.WEIGHT_REQUIRED IS NULL)
        AND (p_WEIGHT_REQUIRED IS NULL)))
    AND ( (Recinfo.SCORE_RANGE_LOW = p_SCORE_RANGE_LOW)
      OR ( (Recinfo.SCORE_RANGE_LOW IS NULL)
        AND (p_SCORE_RANGE_LOW IS NULL)))
    AND ( (Recinfo.SCORE_RANGE_HIGH = p_SCORE_RANGE_HIGH)
      OR ( (Recinfo.SCORE_RANGE_HIGH IS NULL)
        AND (p_SCORE_RANGE_HIGH IS NULL)))
    AND ( (Recinfo.OUT_OF_RANGE_RULE = p_OUT_OF_RANGE_RULE)
      OR ( (Recinfo.OUT_OF_RANGE_RULE IS NULL)
        AND (p_OUT_OF_RANGE_RULE IS NULL)))
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
		AND ( (Recinfo.STATUS_DETERMINATION = p_STATUS_DETERMINATION)
			OR ( (Recinfo.STATUS_DETERMINATION IS NULL)
				AND (p_STATUS_DETERMINATION IS NULL)))
		AND ( (Recinfo.PROGRAM_UPDATE_DATE = p_PROGRAM_UPDATE_DATE)
			OR ( (Recinfo.PROGRAM_UPDATE_DATE IS NULL)
				AND (p_PROGRAM_UPDATE_DATE IS NULL)))
	   ) THEN
		return;
	ELSE
		FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
		APP_EXCEPTION.Raise_Exception;
	END IF;
END Lock_Row;

BEGIN
  PG_DEBUG := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));

END;


/
