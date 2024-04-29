--------------------------------------------------------
--  DDL for Package Body IEX_SCORE_COMPONENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_SCORE_COMPONENTS_PKG" AS
/* $Header: iextscpb.pls 120.0 2004/01/24 03:22:47 appldev noship $ */

/* Insert_Row procedure */
PG_DEBUG NUMBER(2) := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));

PROCEDURE Insert_Row(x_rowid                    IN OUT NOCOPY VARCHAR2
                    ,p_SCORE_COMPONENT_ID       NUMBER
                    ,p_SCORE_COMP_WEIGHT        NUMBER
                    ,p_SCORE_ID                 NUMBER
                    ,p_ENABLED_FLAG             VARCHAR2
                    ,p_LAST_UPDATE_DATE         DATE
                    ,p_LAST_UPDATED_BY          NUMBER
                    ,p_CREATION_DATE            DATE
                    ,p_CREATED_BY               NUMBER
                    ,p_LAST_UPDATE_LOGIN        NUMBER
                    ,p_REQUEST_ID               NUMBER
                    ,p_PROGRAM_APPLICATION_ID   NUMBER
                    ,p_PROGRAM_ID               NUMBER
                    ,p_PROGRAM_UPDATE_DATE      DATE
                    ,p_SCORE_COMP_TYPE_ID       NUMBER
                ) IS
	CURSOR C IS SELECT ROWID FROM IEX_SCORE_COMPONENTS
		WHERE SCORE_COMPONENT_ID = p_SCORE_COMPONENT_ID;

BEGIN
	INSERT INTO IEX_SCORE_COMPONENTS
	(
		SCORE_COMPONENT_ID
		,SCORE_COMP_WEIGHT
		,SCORE_ID
		,ENABLED_FLAG
		,LAST_UPDATE_DATE
		,LAST_UPDATED_BY
		,CREATION_DATE
		,CREATED_BY
		,LAST_UPDATE_LOGIN
		,REQUEST_ID
		,PROGRAM_APPLICATION_ID
		,PROGRAM_ID
		,PROGRAM_UPDATE_DATE
		,SCORE_COMP_TYPE_ID
	) VALUES (
		p_SCORE_COMPONENT_ID
		,p_SCORE_COMP_WEIGHT
		,p_SCORE_ID
		,p_ENABLED_FLAG
		,p_LAST_UPDATE_DATE
		,p_LAST_UPDATED_BY
		,p_CREATION_DATE
		,p_CREATED_BY
		,p_LAST_UPDATE_LOGIN
		,p_REQUEST_ID
		,p_PROGRAM_APPLICATION_ID
		,p_PROGRAM_ID
		,p_PROGRAM_UPDATE_DATE
		,p_SCORE_COMP_TYPE_ID
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
                    ,p_SCORE_COMPONENT_ID       NUMBER
                    ,p_SCORE_COMP_WEIGHT        NUMBER
                    ,p_SCORE_ID                 NUMBER
                    ,p_ENABLED_FLAG             VARCHAR2
                    ,p_LAST_UPDATE_DATE         DATE
                    ,p_LAST_UPDATED_BY          NUMBER
                    ,p_CREATION_DATE            DATE
                    ,p_CREATED_BY               NUMBER
                    ,p_LAST_UPDATE_LOGIN        NUMBER
                    ,p_REQUEST_ID               NUMBER
                    ,p_PROGRAM_APPLICATION_ID   NUMBER
                    ,p_PROGRAM_ID               NUMBER
                    ,p_PROGRAM_UPDATE_DATE      DATE
                    ,p_SCORE_COMP_TYPE_ID       NUMBER
                ) IS
BEGIN
	UPDATE IEX_SCORE_COMPONENTS SET
		SCORE_COMPONENT_ID = p_SCORE_COMPONENT_ID
		,SCORE_COMP_WEIGHT = p_SCORE_COMP_WEIGHT
		,SCORE_ID = p_SCORE_ID
		,ENABLED_FLAG = p_ENABLED_FLAG
		,LAST_UPDATE_DATE = p_LAST_UPDATE_DATE
		,LAST_UPDATED_BY = p_LAST_UPDATED_BY
		,CREATION_DATE = p_CREATION_DATE
		,CREATED_BY = p_CREATED_BY
		,LAST_UPDATE_LOGIN = p_LAST_UPDATE_LOGIN
		,REQUEST_ID = p_REQUEST_ID
		,PROGRAM_APPLICATION_ID = p_PROGRAM_APPLICATION_ID
		,PROGRAM_ID = p_PROGRAM_ID
		,PROGRAM_UPDATE_DATE = p_PROGRAM_UPDATE_DATE
		,SCORE_COMP_TYPE_ID = p_SCORE_COMP_TYPE_ID
	 WHERE rowid = x_rowid;

	if (sql%notfound) then
		raise no_data_found;
	end if;
END Update_Row;

/* Delete_Row procedure */
PROCEDURE Delete_Row(x_rowid VARCHAR2) IS
BEGIN
	DELETE FROM IEX_SCORE_COMPONENTS
		WHERE rowid = x_rowid;

	if (sql%notfound) then
		raise no_data_found;
	end if;
END Delete_Row;

/* Lock_Row procedure */
PROCEDURE Lock_Row(x_rowid                     VARCHAR2
                   ,p_SCORE_COMPONENT_ID       NUMBER
                   ,p_SCORE_COMP_WEIGHT        NUMBER
                   ,p_SCORE_ID                 NUMBER
                   ,p_ENABLED_FLAG             VARCHAR2
                   ,p_LAST_UPDATE_DATE         DATE
                   ,p_LAST_UPDATED_BY          NUMBER
                   ,p_CREATION_DATE            DATE
                   ,p_CREATED_BY               NUMBER
                   ,p_LAST_UPDATE_LOGIN        NUMBER
                   ,p_REQUEST_ID               NUMBER
                   ,p_PROGRAM_APPLICATION_ID   NUMBER
                   ,p_PROGRAM_ID               NUMBER
                   ,p_PROGRAM_UPDATE_DATE      DATE
                   ,p_SCORE_COMP_TYPE_ID       NUMBER
                ) IS
	CURSOR C IS SELECT * FROM IEX_SCORE_COMPONENTS
		WHERE rowid = x_rowid
		FOR UPDATE of SCORE_COMPONENT_ID NOWAIT;
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
		(Recinfo.SCORE_COMPONENT_ID = p_SCORE_COMPONENT_ID)
		AND ( (Recinfo.SCORE_COMP_WEIGHT = p_SCORE_COMP_WEIGHT)
			OR ( (Recinfo.SCORE_COMP_WEIGHT IS NULL)
				AND (p_SCORE_COMP_WEIGHT IS NULL)))
		AND ( (Recinfo.SCORE_ID = p_SCORE_ID)
			OR ( (Recinfo.SCORE_ID IS NULL)
				AND (p_SCORE_ID IS NULL)))
		AND ( (Recinfo.ENABLED_FLAG = p_ENABLED_FLAG)
			OR ( (Recinfo.ENABLED_FLAG IS NULL)
				AND (p_ENABLED_FLAG IS NULL)))
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
		AND ( (Recinfo.SCORE_COMP_TYPE_ID = p_SCORE_COMP_TYPE_ID)
			OR ( (Recinfo.SCORE_COMP_TYPE_ID IS NULL)
				AND (p_SCORE_COMP_TYPE_ID IS NULL)))
	   ) THEN
		return;
	ELSE
		FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
		APP_EXCEPTION.Raise_Exception;
	END IF;
END Lock_Row;
END;


/
