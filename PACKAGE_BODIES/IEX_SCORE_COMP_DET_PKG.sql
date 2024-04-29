--------------------------------------------------------
--  DDL for Package Body IEX_SCORE_COMP_DET_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_SCORE_COMP_DET_PKG" AS
/* $Header: iextscdb.pls 120.2 2004/10/28 16:06:46 clchang ship $ */

/* Insert_Row procedure */
PG_DEBUG NUMBER(2) ;

/* clchang updated 09/20/2004
 * in 11i.IEX.H, the data type of VALUE updated to VARCHAR2(2000);
 ******************************************************************/

PROCEDURE Insert_Row(x_rowid	IN OUT NOCOPY VARCHAR2
                    ,p_SCORE_COMP_DET_ID        NUMBER
                    ,p_OBJECT_VERSION_NUMBER    NUMBER
                    ,p_PROGRAM_ID               NUMBER
                    ,p_LAST_UPDATE_DATE         DATE
                    ,p_LAST_UPDATED_BY          NUMBER
                    ,p_LAST_UPDATE_LOGIN        NUMBER
                    ,p_CREATION_DATE            DATE
                    ,p_CREATED_BY               NUMBER
                    ,p_VALUE                    NUMBER
                    ,p_NEW_VALUE                VARCHAR2
                    ,p_RANGE_LOW                NUMBER
                    ,p_RANGE_HIGH               NUMBER
                    ,p_SCORE_COMPONENT_ID       NUMBER
) IS
	CURSOR C IS SELECT ROWID FROM IEX_SCORE_COMP_DET
		WHERE SCORE_COMP_DET_ID = p_SCORE_COMP_DET_ID;

BEGIN
	INSERT INTO IEX_SCORE_COMP_DET
	(
		SCORE_COMP_DET_ID
		,OBJECT_VERSION_NUMBER
		,PROGRAM_ID
		,LAST_UPDATE_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_LOGIN
		,CREATION_DATE
		,CREATED_BY
		,VALUE
		,NEW_VALUE
		,RANGE_LOW
		,RANGE_HIGH
		,SCORE_COMPONENT_ID
	) VALUES (
		p_SCORE_COMP_DET_ID
		,p_OBJECT_VERSION_NUMBER
		,p_PROGRAM_ID
		,p_LAST_UPDATE_DATE
		,p_LAST_UPDATED_BY
		,p_LAST_UPDATE_LOGIN
		,p_CREATION_DATE
		,p_CREATED_BY
		,p_VALUE
		,p_NEW_VALUE
		,p_RANGE_LOW
		,p_RANGE_HIGH
		,p_SCORE_COMPONENT_ID
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
PROCEDURE Update_Row(x_rowid    VARCHAR2
                    ,p_SCORE_COMP_DET_ID        NUMBER
                    ,p_OBJECT_VERSION_NUMBER    NUMBER
                    ,p_PROGRAM_ID               NUMBER
                    ,p_LAST_UPDATE_DATE         DATE
                    ,p_LAST_UPDATED_BY          NUMBER
                    ,p_LAST_UPDATE_LOGIN        NUMBER
                    ,p_CREATION_DATE            DATE
                    ,p_CREATED_BY               NUMBER
                    ,p_VALUE                    NUMBER
                    ,p_NEW_VALUE                VARCHAR2
                    ,p_RANGE_LOW                NUMBER
                    ,p_RANGE_HIGH               NUMBER
                    ,p_SCORE_COMPONENT_ID       NUMBER
) IS
BEGIN
	UPDATE IEX_SCORE_COMP_DET SET
		SCORE_COMP_DET_ID = p_SCORE_COMP_DET_ID
		,OBJECT_VERSION_NUMBER = p_OBJECT_VERSION_NUMBER
		,PROGRAM_ID = p_PROGRAM_ID
		,LAST_UPDATE_DATE = p_LAST_UPDATE_DATE
		,LAST_UPDATED_BY = p_LAST_UPDATED_BY
		,LAST_UPDATE_LOGIN = p_LAST_UPDATE_LOGIN
		,CREATION_DATE = p_CREATION_DATE
		,CREATED_BY = p_CREATED_BY
		,VALUE = p_VALUE
		,NEW_VALUE = p_NEW_VALUE
		,RANGE_LOW = p_RANGE_LOW
		,RANGE_HIGH = p_RANGE_HIGH
		,SCORE_COMPONENT_ID = p_SCORE_COMPONENT_ID
	 WHERE rowid = x_rowid;

	if (sql%notfound) then
		raise no_data_found;
	end if;
END Update_Row;

/* Delete_Row procedure */
PROCEDURE Delete_Row(x_rowid VARCHAR2) IS
BEGIN
	DELETE FROM IEX_SCORE_COMP_DET
		WHERE rowid = x_rowid;

	if (sql%notfound) then
        raise no_data_found;
    end if;
END Delete_Row;

/* Lock_Row procedure */
PROCEDURE Lock_Row(x_rowid  VARCHAR2
                    ,p_SCORE_COMP_DET_ID        NUMBER
                    ,p_OBJECT_VERSION_NUMBER    NUMBER
                    ,p_PROGRAM_ID               NUMBER
                    ,p_LAST_UPDATE_DATE         DATE
                    ,p_LAST_UPDATED_BY          NUMBER
                    ,p_LAST_UPDATE_LOGIN        NUMBER
                    ,p_CREATION_DATE            DATE
                    ,p_CREATED_BY               NUMBER
                    ,p_VALUE                    NUMBER
                    ,p_NEW_VALUE                VARCHAR2
                    ,p_RANGE_LOW                NUMBER
                    ,p_RANGE_HIGH               NUMBER
                    ,p_SCORE_COMPONENT_ID       NUMBER
) IS
	CURSOR C IS SELECT * FROM IEX_SCORE_COMP_DET
		WHERE rowid = x_rowid
		FOR UPDATE of SCORE_COMP_DET_ID NOWAIT;
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
		(Recinfo.SCORE_COMP_DET_ID = p_SCORE_COMP_DET_ID)
		AND ( (Recinfo.OBJECT_VERSION_NUMBER = p_OBJECT_VERSION_NUMBER)
			OR ( (Recinfo.OBJECT_VERSION_NUMBER IS NULL)
				AND (p_OBJECT_VERSION_NUMBER IS NULL)))
		AND ( (Recinfo.PROGRAM_ID = p_PROGRAM_ID)
			OR ( (Recinfo.PROGRAM_ID IS NULL)
				AND (p_PROGRAM_ID IS NULL)))
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
		AND ( (Recinfo.VALUE = p_VALUE)
			OR ( (Recinfo.VALUE IS NULL)
				AND (p_VALUE IS NULL)))
		AND ( (Recinfo.NEW_VALUE = p_NEW_VALUE)
			OR ( (Recinfo.NEW_VALUE IS NULL)
				AND (p_NEW_VALUE IS NULL)))
		AND ( (Recinfo.RANGE_LOW = p_RANGE_LOW)
			OR ( (Recinfo.RANGE_LOW IS NULL)
				AND (p_RANGE_LOW IS NULL)))
		AND ( (Recinfo.RANGE_HIGH = p_RANGE_HIGH)
			OR ( (Recinfo.RANGE_HIGH IS NULL)
				AND (p_RANGE_HIGH IS NULL)))
		AND ( (Recinfo.SCORE_COMPONENT_ID = p_SCORE_COMPONENT_ID)
			OR ( (Recinfo.SCORE_COMPONENT_ID IS NULL)
				AND (p_SCORE_COMPONENT_ID IS NULL)))
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
