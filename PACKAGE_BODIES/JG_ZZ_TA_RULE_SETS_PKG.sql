--------------------------------------------------------
--  DDL for Package Body JG_ZZ_TA_RULE_SETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JG_ZZ_TA_RULE_SETS_PKG" AS
/* $Header: jgzztarb.pls 115.2 2002/11/18 14:19:09 arimai ship $ */
--
-- PUBLIC FUNCTIONS
--
PROCEDURE Insert_Row( 	 X_rowid		IN OUT NOCOPY	VARCHAR2
			,X_rule_set_id		IN OUT NOCOPY	NUMBER
			,X_name				VARCHAR2
			,X_chart_of_accounts_id		NUMBER
			,X_partial_allocation		VARCHAR2
			,X_enabled_flag			VARCHAR2
			,X_account_type			VARCHAR2
			,X_creation_date		DATE
			,X_created_by			NUMBER
			,X_last_updated_by		NUMBER
			,X_last_update_date		DATE
			,X_last_update_login		NUMBER
			,X_Context			VARCHAR2
			,X_attribute1			VARCHAR2
			,X_attribute2			VARCHAR2
			,X_attribute3			VARCHAR2
			,X_attribute4			VARCHAR2
			,X_attribute5			VARCHAR2
			,X_attribute6			VARCHAR2
			,X_attribute7			VARCHAR2
			,X_attribute8			VARCHAR2
			,X_attribute9			VARCHAR2
			,X_attribute10			VARCHAR2
			,X_attribute11			VARCHAR2
			,X_attribute12			VARCHAR2
			,X_attribute13			VARCHAR2
			,X_attribute14			VARCHAR2
			,X_attribute15			VARCHAR2 )
		IS

	CURSOR C IS 	SELECT rowid
			FROM JG_ZZ_TA_RULE_SETS
			WHERE rule_set_id = X_rule_set_id;
	CURSOR C2 IS	SELECT JG_ZZ_TA_RULE_SETS_S.nextval FROM sys.dual;
	BEGIN
	--
	-- Check if user has defined duplicate name
	--
		IF (X_rule_set_id IS NULL) THEN
			OPEN C2;
			FETCH C2 INTO X_rule_set_id;
			CLOSE C2;
		END IF;
		INSERT INTO JG_ZZ_TA_RULE_SETS
			(
			 	rule_set_id
				,name
				,chart_of_accounts_id
				,partial_allocation
				,enabled_flag
				,account_type
				,creation_date
				,created_by
				,last_updated_by
				,last_update_date
				,last_update_login
				,context
				,attribute1
				,attribute2
				,attribute3
				,attribute4
				,attribute5
				,attribute6
				,attribute7
				,attribute8
				,attribute9
				,attribute10
				,attribute11
				,attribute12
				,attribute13
				,attribute14
				,attribute15
			)
			VALUES
			(
				 X_rule_set_id
				,X_name
				,X_chart_of_accounts_id
				,X_partial_allocation
				,X_enabled_flag
				,X_account_type
				,X_creation_date
				,X_created_by
				,X_last_updated_by
				,X_last_update_date
				,X_last_update_login
				,X_context
				,X_attribute1
				,X_attribute2
				,X_attribute3
				,X_attribute4
				,X_attribute5
				,X_attribute6
				,X_attribute7
				,X_attribute8
				,X_attribute9
				,X_attribute10
				,X_attribute11
				,X_attribute12
				,X_attribute13
				,X_attribute14
				,X_attribute15
			);
	OPEN C;
	FETCH C INTO X_rowid;
	IF (C%NOTFOUND) THEN
		CLOSE C;
		raise NO_DATA_FOUND;
	END IF;
	CLOSE C;
END insert_row;


PROCEDURE Update_Row( 	 X_rowid			VARCHAR2
			,X_rule_set_id			NUMBER
			,X_name				VARCHAR2
			,X_chart_of_accounts_id		NUMBER
			,X_partial_allocation		VARCHAR2
			,X_enabled_flag			VARCHAR2
			,X_account_type			VARCHAR2
			,X_creation_date		DATE
			,X_created_by			NUMBER
			,X_last_updated_by		NUMBER
			,X_last_update_date		DATE
			,X_last_update_login		NUMBER
			,X_Context			VARCHAR2
			,X_attribute1			VARCHAR2
			,X_attribute2			VARCHAR2
			,X_attribute3			VARCHAR2
			,X_attribute4			VARCHAR2
			,X_attribute5			VARCHAR2
			,X_attribute6			VARCHAR2
			,X_attribute7			VARCHAR2
			,X_attribute8			VARCHAR2
			,X_attribute9			VARCHAR2
			,X_attribute10			VARCHAR2
			,X_attribute11			VARCHAR2
			,X_attribute12			VARCHAR2
			,X_attribute13			VARCHAR2
			,X_attribute14			VARCHAR2
			,X_attribute15			VARCHAR2 )
		IS
	BEGIN
	--
	-- Standard ON-UPDATE routine
	--
	UPDATE JG_ZZ_TA_RULE_SETS
	SET
		 rule_set_id		=	X_rule_set_id
		,name			=	X_name
		,chart_of_accounts_id	=	X_chart_of_accounts_id
		,partial_allocation	=	X_partial_allocation
		,enabled_flag		=	X_enabled_flag
		,account_type		=	X_account_type
		,creation_date		=	X_creation_date
		,created_by		=	X_created_by
		,last_updated_by	=	X_last_updated_by
		,last_update_date	=	X_last_update_date
		,last_update_login	=	X_last_update_login
		,context		=	X_context
		,attribute1		=	X_attribute1
		,attribute2		=	X_attribute2
		,attribute3		=	X_attribute3
		,attribute4		=	X_attribute4
		,attribute5	 	=	X_attribute5
		,attribute6		=	X_attribute6
		,attribute7		=	X_attribute7
		,attribute8		=	X_attribute8
		,attribute9		=	X_attribute9
		,attribute10		=	X_attribute10
		,attribute11		=	X_attribute11
		,attribute12		=	X_attribute12
		,attribute13		=	X_attribute13
		,attribute14		=	X_attribute14
		,attribute15		=	X_attribute15
	WHERE
		rowid			=	X_rowid;
	IF (SQL%NOTFOUND) THEN
		RAISE NO_DATA_FOUND;
	END IF;
END Update_Row;

PROCEDURE Delete_Row(	X_rowid VARCHAR2	) IS
-- ITHEODOR CHANGE START
CURSOR Get_Children(P_rowid VARCHAR2) IS
        SELECT Row_Id
        FROM   JG_ZZ_TA_CC_RANGES_V C
        WHERE  C.RULE_SET_ID = (SELECT P.RULE_SET_ID
                                FROM   JG_ZZ_TA_RULE_SETS P
                                WHERE  P.ROWID  = P_rowid);
-- ITHEODOR CHANGE END

	BEGIN
-- ITHEODOR CHANGE START
-- Cascade Delete Implementation
        FOR Rec IN Get_Children(X_rowid) LOOP
                JG_ZZ_TA_CC_RANGES_PKG.Delete_Row( Rec.Row_id );
        END LOOP;
-- ITHEODOR CHANGE END

		DELETE FROM JG_ZZ_TA_RULE_SETS
	WHERE
		ROWID = X_rowid;
	IF (SQL%NOTFOUND) THEN
		RAISE NO_DATA_FOUND;
	END IF;
END Delete_Row;


PROCEDURE Lock_Row  ( 	 X_rowid		      	VARCHAR2
			,X_rule_set_id		      	NUMBER
			,X_name				VARCHAR2
			,X_chart_of_accounts_id		NUMBER
			,X_partial_allocation		VARCHAR2
			,X_enabled_flag			VARCHAR2
			,X_account_type			VARCHAR2
			,X_creation_date		DATE
			,X_created_by			NUMBER
			,X_last_updated_by		NUMBER
			,X_last_update_date		DATE
			,X_last_update_login		NUMBER
			,X_Context			VARCHAR2
			,X_attribute1			VARCHAR2
			,X_attribute2			VARCHAR2
			,X_attribute3			VARCHAR2
			,X_attribute4			VARCHAR2
			,X_attribute5			VARCHAR2
			,X_attribute6			VARCHAR2
			,X_attribute7			VARCHAR2
			,X_attribute8			VARCHAR2
			,X_attribute9			VARCHAR2
			,X_attribute10			VARCHAR2
			,X_attribute11			VARCHAR2
			,X_attribute12			VARCHAR2
			,X_attribute13			VARCHAR2
			,X_attribute14			VARCHAR2
			,X_attribute15			VARCHAR2 )
		IS
	CURSOR C IS
		SELECT *
		FROM	JG_ZZ_TA_RULE_SETS
		WHERE	rowid = X_Rowid
		FOR UPDATE of rule_set_id NOWAIT;
	Recinfo	C%ROWTYPE;
	BEGIN
		OPEN C;
		FETCH C INTO Recinfo;
		IF (C%NOTFOUND)	THEN
			CLOSE C;
			FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
			APP_EXCEPTION.raise_exception;
		END IF;
		CLOSE C;
     IF (
      (    (   (Recinfo.rule_set_id = X_rule_set_id )
        OR (    (Recinfo.rule_set_id IS NULL)
            AND (X_rule_set_id IS NULL))))
       AND (    (   (Recinfo.chart_of_accounts_id = X_chart_of_accounts_id )
        OR (    (Recinfo.chart_of_accounts_id IS NULL)
            AND (X_chart_of_accounts_id IS NULL))))
       AND (    (   (Recinfo.partial_allocation = X_partial_allocation )
        OR (    (Recinfo.partial_allocation IS NULL)
            AND (X_partial_allocation IS NULL))))
       AND (    (   (Recinfo.enabled_flag = X_enabled_flag )
        OR (    (Recinfo.enabled_flag IS NULL)
            AND (X_enabled_flag IS NULL))))
       AND (    (   (Recinfo.account_type = X_account_type )
        OR (    (Recinfo.account_type IS NULL)
            AND (X_account_type IS NULL))))
       AND (    (   (Recinfo.name = X_name )
        OR (    (Recinfo.name IS NULL)
            AND (X_name IS NULL))))
       AND (    (   (Recinfo.context = X_context )
        OR (    (Recinfo.context IS NULL)
            AND (X_context IS NULL))))
       AND (    (   (Recinfo.attribute1 = X_attribute1 )
        OR (    (Recinfo.attribute1 IS NULL)
            AND (X_attribute1 IS NULL))))
       AND (    (   (Recinfo.attribute2 = X_attribute2 )
        OR (    (Recinfo.attribute2 IS NULL)
            AND (X_attribute2 IS NULL))))
       AND (    (   (Recinfo.attribute3 = X_attribute3 )
        OR (    (Recinfo.attribute3 IS NULL)
            AND (X_attribute3 IS NULL))))
       AND (    (   (Recinfo.attribute4 = X_attribute4 )
        OR (    (Recinfo.attribute4 IS NULL)
            AND (X_attribute4 IS NULL))))
       AND (    (   (Recinfo.attribute5 = X_attribute5 )
        OR (    (Recinfo.attribute5 IS NULL)
            AND (X_attribute5 IS NULL))))
       AND (    (   (Recinfo.attribute6 = X_attribute6 )
        OR (    (Recinfo.attribute6 IS NULL)
            AND (X_attribute6 IS NULL))))
       AND (    (   (Recinfo.attribute7 = X_attribute7 )
        OR (    (Recinfo.attribute7 IS NULL)
            AND (X_attribute7 IS NULL))))
       AND (    (   (Recinfo.attribute8 = X_attribute8 )
        OR (    (Recinfo.attribute8 IS NULL)
            AND (X_attribute8 IS NULL))))
       AND (    (   (Recinfo.attribute9 = X_attribute9 )
        OR (    (Recinfo.attribute9 IS NULL)
            AND (X_attribute9 IS NULL))))
       AND (    (   (Recinfo.attribute10 = X_attribute10 )
        OR (    (Recinfo.attribute10 IS NULL)
            AND (X_attribute10 IS NULL))))
       AND (    (   (Recinfo.attribute11 = X_attribute11 )
        OR (    (Recinfo.attribute11 IS NULL)
            AND (X_attribute11 IS NULL))))
       AND (    (   (Recinfo.attribute12 = X_attribute12 )
        OR (    (Recinfo.attribute12 IS NULL)
            AND (X_attribute12 IS NULL))))
       AND (   (    (Recinfo.attribute13 = X_attribute13 )
        OR (    (Recinfo.attribute13 IS NULL)
            AND (X_attribute13 IS NULL))))
       AND (    (   (Recinfo.attribute14 = X_attribute14 )
        OR (    (Recinfo.attribute14 IS NULL)
           AND (X_attribute14 IS NULL))))
       AND (    (   (Recinfo.attribute15 = X_attribute15 )
        OR (    (Recinfo.attribute15 IS NULL)
           AND (X_attribute15 IS NULL))))
	) THEN
       return;
    ELSE
       FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
  END Lock_Row;
END JG_ZZ_TA_RULE_SETS_PKG;

/
