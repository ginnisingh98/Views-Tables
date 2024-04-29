--------------------------------------------------------
--  DDL for Package Body IEX_STATUS_RULE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_STATUS_RULE_PKG" AS
/* $Header: iextcstb.pls 120.0 2004/01/24 03:21:45 appldev noship $ */

/* Insert_Row procedure */
PG_DEBUG NUMBER(2) := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));

PROCEDURE Insert_Row(x_rowid                    IN OUT NOCOPY VARCHAR2
                    ,p_STATUS_RULE_ID                 NUMBER
                    ,p_STATUS_RULE_NAME               VARCHAR2
                    ,p_STATUS_RULE_DESCRIPTION        VARCHAR2
                    ,p_START_DATE            DATE
                    ,p_END_DATE              DATE
--                    ,p_JTF_OBJECT_CODE       VARCHAR2
                    ,p_LAST_UPDATE_DATE         DATE
                    ,p_LAST_UPDATED_BY          NUMBER
                    ,p_CREATION_DATE            DATE
                    ,p_CREATED_BY               NUMBER
                    ,p_LAST_UPDATE_LOGIN        NUMBER
                    ,p_SECURITY_GROUP_ID        NUMBER
                    ,p_PROGRAM_ID               NUMBER
					,p_OBJECT_VERSION_NUMBER    NUMBER
) IS
	CURSOR C IS SELECT ROWID FROM IEX_CUST_STATUS_RULES
		WHERE STATUS_RULE_ID = p_STATUS_RULE_ID;

BEGIN
	INSERT INTO IEX_CUST_STATUS_RULES
	(
		STATUS_RULE_ID
		,STATUS_RULE_NAME
		,STATUS_RULE_DESCRIPTION
		,START_DATE
		,END_DATE
--                ,JTF_OBJECT_CODE
		,LAST_UPDATE_DATE
		,LAST_UPDATED_BY
		,CREATION_DATE
		,CREATED_BY
		,LAST_UPDATE_LOGIN
        ,SECURITY_GROUP_ID
        ,PROGRAM_ID
		,OBJECT_VERSION_NUMBER
	) VALUES (
		p_STATUS_RULE_ID
		,p_STATUS_RULE_NAME
		,p_STATUS_RULE_DESCRIPTION
		,p_START_DATE
		,p_END_DATE
--                ,p_JTF_OBJECT_CODE
		,p_LAST_UPDATE_DATE
		,p_LAST_UPDATED_BY
		,p_CREATION_DATE
		,p_CREATED_BY
		,p_LAST_UPDATE_LOGIN
        ,p_SECURITY_GROUP_ID
        ,p_PROGRAM_ID
		,p_OBJECT_VERSION_NUMBER
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
                    ,p_STATUS_RULE_ID                 NUMBER
                    ,p_STATUS_RULE_NAME               VARCHAR2
                    ,p_STATUS_RULE_DESCRIPTION        VARCHAR2
                    ,p_START_DATE            DATE
                    ,p_END_DATE              DATE
--                    ,p_JTF_OBJECT_CODE       VARCHAR2
                    ,p_LAST_UPDATE_DATE         DATE
                    ,p_LAST_UPDATED_BY          NUMBER
                    ,p_CREATION_DATE            DATE
                    ,p_CREATED_BY               NUMBER
                    ,p_LAST_UPDATE_LOGIN        NUMBER
                    ,p_SECURITY_GROUP_ID        NUMBER
                    ,p_PROGRAM_ID               NUMBER
					,p_OBJECT_VERSION_NUMBER    NUMBER
) IS
BEGIN
	UPDATE IEX_CUST_STATUS_RULES SET
		STATUS_RULE_ID = p_STATUS_RULE_ID
		,STATUS_RULE_NAME = p_STATUS_RULE_NAME
		,STATUS_RULE_DESCRIPTION = p_STATUS_RULE_DESCRIPTION
		,START_DATE = p_START_DATE
		,END_DATE = p_END_DATE
--                ,JTF_OBJECT_CODE = p_JTF_OBJECT_CODE
		,LAST_UPDATE_DATE = p_LAST_UPDATE_DATE
		,LAST_UPDATED_BY = p_LAST_UPDATED_BY
		,CREATION_DATE = p_CREATION_DATE
		,CREATED_BY = p_CREATED_BY
		,LAST_UPDATE_LOGIN = p_LAST_UPDATE_LOGIN
        ,SECURITY_GROUP_ID = p_SECURITY_GROUP_ID
        ,PROGRAM_ID = p_PROGRAM_ID
		,OBJECT_VERSION_NUMBER = p_OBJECT_VERSION_NUMBER
	 WHERE rowid = x_rowid;

	if (sql%notfound) then
		raise no_data_found;
	end if;
END Update_Row;

/* Delete_Row procedure */
PROCEDURE Delete_Row(x_rowid VARCHAR2) IS
BEGIN
	DELETE FROM IEX_CUST_STATUS_RULES
		WHERE rowid = x_rowid;

	if (sql%notfound) then
		raise no_data_found;
	end if;
END Delete_Row;

/* Lock_Row procedure */
PROCEDURE Lock_Row(x_rowid                      VARCHAR2
                   ,p_STATUS_RULE_ID                  NUMBER
                   ,p_STATUS_RULE_NAME                VARCHAR2
                   ,p_STATUS_RULE_DESCRIPTION         VARCHAR2
                   ,p_START_DATE             DATE
                   ,p_END_DATE               DATE
--                   ,p_JTF_OBJECT_CODE        VARCHAR2
                   ,p_LAST_UPDATE_DATE          DATE
                   ,p_LAST_UPDATED_BY           NUMBER
                   ,p_CREATION_DATE             DATE
                   ,p_CREATED_BY                NUMBER
                   ,p_LAST_UPDATE_LOGIN         NUMBER
                   ,p_PROGRAM_ID               NUMBER
                   ,p_SECURITY_GROUP_ID        NUMBER
				   ,p_OBJECT_VERSION_NUMBER    NUMBER
) IS
	CURSOR C IS SELECT * FROM IEX_CUST_STATUS_RULES
		WHERE rowid = x_rowid
		FOR UPDATE of STATUS_RULE_ID NOWAIT;
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
		(Recinfo.STATUS_RULE_ID = p_STATUS_RULE_ID)
		AND ( (Recinfo.STATUS_RULE_NAME = p_STATUS_RULE_NAME)
			OR ( (Recinfo.STATUS_RULE_NAME IS NULL)
				AND (p_STATUS_RULE_NAME IS NULL)))
		AND ( (Recinfo.STATUS_RULE_DESCRIPTION = p_STATUS_RULE_DESCRIPTION)
			OR ( (Recinfo.STATUS_RULE_DESCRIPTION IS NULL)
				AND (p_STATUS_RULE_DESCRIPTION IS NULL)))
		AND ( (Recinfo.START_DATE = p_START_DATE)
			OR ( (Recinfo.START_DATE IS NULL)
				AND (p_START_DATE IS NULL)))
		AND ( (Recinfo.END_DATE = p_END_DATE)
			OR ( (Recinfo.END_DATE IS NULL)
				AND (p_END_DATE IS NULL)))
		-- AND ( (Recinfo.JTF_OBJECT_CODE = p_JTF_OBJECT_CODE)
			-- OR ( (Recinfo.JTF_OBJECT_CODE IS NULL)
				-- AND (p_JTF_OBJECT_CODE IS NULL)))
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
		AND ( (Recinfo.PROGRAM_ID = p_PROGRAM_ID)
			OR ( (Recinfo.PROGRAM_ID IS NULL)
				AND (p_PROGRAM_ID IS NULL)))
		AND ( (Recinfo.SECURITY_GROUP_ID = p_SECURITY_GROUP_ID)
			OR ( (Recinfo.SECURITY_GROUP_ID IS NULL)
				AND (p_SECURITY_GROUP_ID IS NULL)))
		AND ( (Recinfo.OBJECT_VERSION_NUMBER = p_OBJECT_VERSION_NUMBER)
			OR ( (Recinfo.OBJECT_VERSION_NUMBER IS NULL)
				AND (p_OBJECT_VERSION_NUMBER IS NULL)))
	   ) THEN
		return;
	ELSE
		FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
		APP_EXCEPTION.Raise_Exception;
	END IF;
END Lock_Row;
END;


/
