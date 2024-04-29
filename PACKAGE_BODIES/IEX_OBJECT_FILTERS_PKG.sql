--------------------------------------------------------
--  DDL for Package Body IEX_OBJECT_FILTERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_OBJECT_FILTERS_PKG" AS
/* $Header: iextobfb.pls 120.0 2004/01/24 03:22:20 appldev noship $ */

/* Insert_Row procedure */
PG_DEBUG NUMBER(2) := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));

PROCEDURE Insert_Row(x_rowid                    IN OUT NOCOPY VARCHAR2
                    ,p_OBJECT_FILTER_ID         NUMBER
                    ,p_OBJECT_FILTER_TYPE       VARCHAR2
                    ,p_OBJECT_FILTER_NAME       VARCHAR2
                    ,p_OBJECT_ID                NUMBER
                    ,p_SELECT_COLUMN            VARCHAR2
                    ,p_ENTITY_NAME              VARCHAR2
                    ,p_ACTIVE_FLAG              VARCHAR2
                    ,p_OBJECT_VERSION_NUMBER    NUMBER
                    ,p_PROGRAM_ID               NUMBER  DEFAULT NULL
                    ,p_REQUEST_ID               NUMBER  DEFAULT NULL
                    ,p_PROGRAM_APPLICATION_ID   NUMBER  DEFAULT NULL
                    ,p_PROGRAM_UPDATE_DATE      DATE    DEFAULT NULL
                    ,p_CREATED_BY               NUMBER
                    ,p_CREATION_DATE            DATE
                    ,p_LAST_UPDATED_BY          NUMBER
                    ,p_LAST_UPDATE_DATE         DATE
                    ,p_LAST_UPDATE_LOGIN        NUMBER  DEFAULT NULL
) IS
	CURSOR C IS SELECT ROWID FROM IEX_OBJECT_FILTERS
		WHERE OBJECT_FILTER_ID = p_OBJECT_FILTER_ID;

BEGIN
	INSERT INTO IEX_OBJECT_FILTERS
	(
		OBJECT_FILTER_ID
		,OBJECT_FILTER_TYPE
		,OBJECT_FILTER_NAME
        ,OBJECT_ID
        ,SELECT_COLUMN
		,ENTITY_NAME
		,ACTIVE_FLAG
		,OBJECT_VERSION_NUMBER
		,PROGRAM_ID
		,REQUEST_ID
		,PROGRAM_APPLICATION_ID
		,PROGRAM_UPDATE_DATE
		,CREATED_BY
		,CREATION_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_DATE
		,LAST_UPDATE_LOGIN
	) VALUES (
		p_OBJECT_FILTER_ID
		,p_OBJECT_FILTER_TYPE
		,p_OBJECT_FILTER_NAME
        ,p_OBJECT_ID
		,p_SELECT_COLUMN
		,p_ENTITY_NAME
		,p_ACTIVE_FLAG
		,p_OBJECT_VERSION_NUMBER
		,p_PROGRAM_ID
		,p_REQUEST_ID
		,p_PROGRAM_APPLICATION_ID
		,p_PROGRAM_UPDATE_DATE
		,p_CREATED_BY
		,p_CREATION_DATE
		,p_LAST_UPDATED_BY
		,p_LAST_UPDATE_DATE
		,p_LAST_UPDATE_LOGIN
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
                    ,p_OBJECT_FILTER_ID         NUMBER
                    ,p_OBJECT_FILTER_TYPE       VARCHAR2
                    ,p_OBJECT_FILTER_NAME       VARCHAR2
                    ,p_OBJECT_ID                NUMBER
                    ,p_SELECT_COLUMN            VARCHAR2
                    ,p_ENTITY_NAME              VARCHAR2
                    ,p_ACTIVE_FLAG              VARCHAR2
                    ,p_OBJECT_VERSION_NUMBER    NUMBER
                    ,p_PROGRAM_ID               NUMBER  DEFAULT NULL
                    ,p_REQUEST_ID               NUMBER  DEFAULT NULL
                    ,p_PROGRAM_APPLICATION_ID   NUMBER  DEFAULT NULL
                    ,p_PROGRAM_UPDATE_DATE      DATE    DEFAULT NULL
                    ,p_CREATED_BY               NUMBER
                    ,p_CREATION_DATE            DATE
                    ,p_LAST_UPDATED_BY          NUMBER
                    ,p_LAST_UPDATE_DATE         DATE
                    ,p_LAST_UPDATE_LOGIN        NUMBER  DEFAULT NULL
) IS
BEGIN
	UPDATE IEX_OBJECT_FILTERS SET
		OBJECT_FILTER_ID = p_OBJECT_FILTER_ID
		,OBJECT_FILTER_TYPE = p_OBJECT_FILTER_TYPE
		,OBJECT_FILTER_NAME = p_OBJECT_FILTER_NAME
        ,OBJECT_ID = p_OBJECT_ID
		,SELECT_COLUMN = p_SELECT_COLUMN
		,ENTITY_NAME = p_ENTITY_NAME
		,ACTIVE_FLAG = p_ACTIVE_FLAG
		,OBJECT_VERSION_NUMBER = p_OBJECT_VERSION_NUMBER
		,PROGRAM_ID = p_PROGRAM_ID
		,REQUEST_ID = p_REQUEST_ID
		,PROGRAM_APPLICATION_ID = p_PROGRAM_APPLICATION_ID
		,PROGRAM_UPDATE_DATE = p_PROGRAM_UPDATE_DATE
		,CREATED_BY = p_CREATED_BY
		,CREATION_DATE = p_CREATION_DATE
		,LAST_UPDATED_BY = p_LAST_UPDATED_BY
		,LAST_UPDATE_DATE = p_LAST_UPDATE_DATE
		,LAST_UPDATE_LOGIN = p_LAST_UPDATE_LOGIN
	 WHERE rowid = x_rowid;

	if (sql%notfound) then
		raise no_data_found;
	end if;
END Update_Row;

/* Delete_Row procedure */
PROCEDURE Delete_Row(x_rowid VARCHAR2) IS
BEGIN
	DELETE FROM IEX_OBJECT_FILTERS
		WHERE rowid = x_rowid;

	if (sql%notfound) then
		raise no_data_found;
	end if;
END Delete_Row;

/* Lock_Row procedure */
PROCEDURE Lock_Row(x_rowid                      VARCHAR2
                    ,p_OBJECT_FILTER_ID         NUMBER
                    ,p_OBJECT_FILTER_TYPE       VARCHAR2
                    ,p_OBJECT_FILTER_NAME       VARCHAR2
                    ,p_OBJECT_ID                NUMBER
                    ,p_SELECT_COLUMN            VARCHAR2
                    ,p_ENTITY_NAME              VARCHAR2
                    ,p_ACTIVE_FLAG              VARCHAR2
                    ,p_OBJECT_VERSION_NUMBER    NUMBER
                    ,p_PROGRAM_ID               NUMBER  DEFAULT NULL
                    ,p_REQUEST_ID               NUMBER  DEFAULT NULL
                    ,p_PROGRAM_APPLICATION_ID   NUMBER  DEFAULT NULL
                    ,p_PROGRAM_UPDATE_DATE      DATE    DEFAULT NULL
                    ,p_CREATED_BY               NUMBER
                    ,p_CREATION_DATE            DATE
                    ,p_LAST_UPDATED_BY          NUMBER
                    ,p_LAST_UPDATE_DATE         DATE
                    ,p_LAST_UPDATE_LOGIN        NUMBER  DEFAULT NULL
) IS
	CURSOR C IS SELECT * FROM IEX_OBJECT_FILTERS
		WHERE rowid = x_rowid
		FOR UPDATE of OBJECT_FILTER_ID NOWAIT;
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
		(Recinfo.OBJECT_FILTER_ID = p_OBJECT_FILTER_ID)
		AND ( (Recinfo.OBJECT_FILTER_TYPE = p_OBJECT_FILTER_TYPE)
			OR ( (Recinfo.OBJECT_FILTER_TYPE IS NULL)
				AND (p_OBJECT_FILTER_TYPE IS NULL)))
		AND ( (Recinfo.OBJECT_FILTER_NAME = p_OBJECT_FILTER_NAME)
			OR ( (Recinfo.OBJECT_FILTER_NAME IS NULL)
				AND (p_OBJECT_FILTER_NAME IS NULL)))
        AND ( (Recinfo.OBJECT_ID = p_OBJECT_ID)
            OR ( (Recinfo.OBJECT_ID IS NULL)
                AND (p_OBJECT_ID IS NULL)))
		AND ( (Recinfo.SELECT_COLUMN = p_SELECT_COLUMN)
			OR ( (Recinfo.SELECT_COLUMN IS NULL)
				AND (p_SELECT_COLUMN IS NULL)))
		AND ( (Recinfo.ENTITY_NAME = p_ENTITY_NAME)
			OR ( (Recinfo.ENTITY_NAME IS NULL)
				AND (p_ENTITY_NAME IS NULL)))
		AND ( (Recinfo.ACTIVE_FLAG = p_ACTIVE_FLAG)
			OR ( (Recinfo.ACTIVE_FLAG IS NULL)
				AND (p_ACTIVE_FLAG IS NULL)))
		AND ( (Recinfo.OBJECT_VERSION_NUMBER = p_OBJECT_VERSION_NUMBER)
			OR ( (Recinfo.OBJECT_VERSION_NUMBER IS NULL)
				AND (p_OBJECT_VERSION_NUMBER IS NULL)))
		AND ( (Recinfo.PROGRAM_ID = p_PROGRAM_ID)
			OR ( (Recinfo.PROGRAM_ID IS NULL)
				AND (p_PROGRAM_ID IS NULL)))
		AND ( (Recinfo.REQUEST_ID = p_REQUEST_ID)
			OR ( (Recinfo.REQUEST_ID IS NULL)
				AND (p_REQUEST_ID IS NULL)))
		AND ( (Recinfo.PROGRAM_APPLICATION_ID = p_PROGRAM_APPLICATION_ID)
			OR ( (Recinfo.PROGRAM_APPLICATION_ID IS NULL)
				AND (p_PROGRAM_APPLICATION_ID IS NULL)))
		AND ( (Recinfo.PROGRAM_UPDATE_DATE = p_PROGRAM_UPDATE_DATE)
			OR ( (Recinfo.PROGRAM_UPDATE_DATE IS NULL)
				AND (p_PROGRAM_UPDATE_DATE IS NULL)))
		AND ( (Recinfo.CREATED_BY = p_CREATED_BY)
			OR ( (Recinfo.CREATED_BY IS NULL)
				AND (p_CREATED_BY IS NULL)))
		AND ( (Recinfo.CREATION_DATE = p_CREATION_DATE)
			OR ( (Recinfo.CREATION_DATE IS NULL)
				AND (p_CREATION_DATE IS NULL)))
		AND ( (Recinfo.LAST_UPDATED_BY = p_LAST_UPDATED_BY)
			OR ( (Recinfo.LAST_UPDATED_BY IS NULL)
				AND (p_LAST_UPDATED_BY IS NULL)))
		AND ( (Recinfo.LAST_UPDATE_DATE = p_LAST_UPDATE_DATE)
			OR ( (Recinfo.LAST_UPDATE_DATE IS NULL)
				AND (p_LAST_UPDATE_DATE IS NULL)))
		AND ( (Recinfo.LAST_UPDATE_LOGIN = p_LAST_UPDATE_LOGIN)
			OR ( (Recinfo.LAST_UPDATE_LOGIN IS NULL)
				AND (p_LAST_UPDATE_LOGIN IS NULL)))
	   ) THEN
		return;
	ELSE
		FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
		APP_EXCEPTION.Raise_Exception;
	END IF;
END Lock_Row;
END;


/
