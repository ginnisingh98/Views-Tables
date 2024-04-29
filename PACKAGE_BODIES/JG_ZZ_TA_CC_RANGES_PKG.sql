--------------------------------------------------------
--  DDL for Package Body JG_ZZ_TA_CC_RANGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JG_ZZ_TA_CC_RANGES_PKG" AS
/* $Header: jgzztacb.pls 115.1 2002/11/15 17:08:18 arimai ship $ */
--
-- PUBLIC FUNCTIONS
--
PROCEDURE Overlap(X_Rowid                     VARCHAR2,
                  X_rule_set_id		      NUMBER,
                  X_cc_range_low	      VARCHAR2,
                  X_cc_range_high             VARCHAR2 ) IS
CURSOR C1 IS  SELECT 'Overlaps'
    FROM JG_ZZ_TA_CC_RANGES CCS
    WHERE RULE_SET_ID = X_rule_set_id
    AND  ((CCS.cc_range_low between
           X_cc_range_low and X_cc_range_high)
          OR
           (CCS.cc_range_high between
           X_cc_range_low and X_cc_range_high)
          OR
           (X_cc_range_low between
           CCS.cc_range_low and CCS.cc_range_high)
          OR
           (X_cc_range_high between
           CCS.cc_range_low and CCS.cc_range_high))
     AND ROWIDTOCHAR(CCS.rowid) <> nvl(X_rowid, 'x');

 V1   VARCHAR2(21);
BEGIN
    OPEN C1;
    FETCH C1 INTO V1;
    IF (C1%FOUND) THEN
      CLOSE C1;
      fnd_message.set_name('JG', 'JG_ZZ_TA_CCS_RANGE_OVERLAP');
      app_exception.raise_exception;
    END IF;
    CLOSE C1;
END Overlap;

PROCEDURE Insert_Row( 	 X_rowid		IN OUT NOCOPY	VARCHAR2
			,X_cc_range_id		IN OUT NOCOPY	NUMBER
			,X_rule_set_id		IN OUT NOCOPY  NUMBER
			,X_cc_range_low			VARCHAR2
			,X_cc_range_high		VARCHAR2
			,X_creation_date		DATE
			,X_created_by			NUMBER
			,X_last_updated_by		NUMBER
			,X_last_update_date		DATE
			,X_last_update_login		NUMBER
			,X_description			VARCHAR2
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
			,X_attribute15			VARCHAR2 ) IS
	CURSOR C IS 	SELECT rowid
			FROM JG_ZZ_TA_CC_RANGES
			WHERE CC_RANGE_ID = X_cc_range_id;
	CURSOR C2 IS	SELECT JG_ZZ_TA_CC_RANGES_S.nextval FROM sys.dual;
	CURSOR C4 IS	SELECT JG_ZZ_TA_RULE_SETS_S.nextval FROM sys.dual;
	CURSOR C3 IS	SELECT 'FOUND'
			FROM 	JG_ZZ_TA_CC_RANGES
			WHERE RULE_SET_ID = X_rule_set_id
			AND CC_RANGE_LOW  = X_cc_range_low
			AND CC_RANGE_HIGH = X_cc_range_high;
	l_found		varchar2(5);
	BEGIN
		IF (X_cc_range_id IS NULL) THEN
			OPEN C2;
			FETCH C2 INTO X_cc_range_id;
			CLOSE C2;
		END IF;
		IF (X_rule_set_id IS NULL) THEN
			OPEN C4;
			FETCH C4 INTO X_rule_set_id;
			CLOSE C4;
		END IF;

		--
		-- Insert Row
		--
			INSERT INTO JG_ZZ_TA_CC_RANGES
				(
				 	 rule_set_id
					,cc_range_id
					,cc_range_low
					,cc_range_high
					,creation_date
					,created_by
					,last_updated_by
					,last_update_date
					,last_update_login
					,description
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
					,X_cc_range_id
					,X_cc_range_low
					,X_cc_range_high
					,X_creation_date
					,X_created_by
					,X_last_updated_by
					,X_last_update_date
					,X_last_update_login
					,X_description
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


PROCEDURE Update_Row( 	 X_rowid		       VARCHAR2
			,X_cc_range_id		      	NUMBER
			,X_rule_set_id		        NUMBER
			,X_cc_range_low			VARCHAR2
			,X_cc_range_high		VARCHAR2
			,X_creation_date		DATE
			,X_created_by			NUMBER
			,X_last_updated_by		NUMBER
			,X_last_update_date		DATE
			,X_last_update_login		NUMBER
			,X_description			VARCHAR2
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
			,X_attribute15			VARCHAR2 ) IS
	BEGIN
	--
	-- Standard ON-UPDATE routine
	--
	UPDATE JG_ZZ_TA_CC_RANGES
	SET
		 rule_set_id		=	X_rule_set_id
		,cc_range_id		=	X_cc_range_id		/* ??????? */
		,cc_range_low		=	X_cc_range_low
		,cc_range_high		=	X_cc_range_high
		,creation_date		=	X_creation_date
		,created_by		=	X_created_by
		,last_updated_by	=	X_last_updated_by
		,last_update_date	=	X_last_update_date
		,last_update_login	=	X_last_update_login
		,description		=	X_description
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
        FROM   JG_ZZ_TA_ACCOUNT_RANGES_V C
        WHERE  C.CC_RANGE_ID = (SELECT P.CC_RANGE_ID
                                FROM   JG_ZZ_TA_CC_RANGES P
                                WHERE  P.ROWID  = P_rowid);
-- ITHEODOR CHANGE END

	BEGIN
-- ITHEODOR CHANGE START
-- Cascade Delete Implementation
        FOR Rec IN Get_Children(X_rowid) LOOP
                JG_ZZ_TA_ACCOUNT_RANGES_PKG.Delete_Row( Rec.Row_id );
        END LOOP;
-- ITHEODOR CHANGE END

		DELETE FROM JG_ZZ_TA_CC_RANGES
	WHERE
		ROWID = X_rowid;
	IF (SQL%NOTFOUND) THEN
		RAISE NO_DATA_FOUND;
	END IF;
END Delete_Row;

PROCEDURE Lock_Row( 	 X_rowid		        VARCHAR2
			,X_cc_range_id		      	NUMBER
			,X_rule_set_id		        NUMBER
			,X_cc_range_low			VARCHAR2
			,X_cc_range_high		VARCHAR2
			,X_creation_date		DATE
			,X_created_by			NUMBER
			,X_last_updated_by		NUMBER
			,X_last_update_date		DATE
			,X_last_update_login		NUMBER
			,X_description			VARCHAR2
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
			,X_attribute15			VARCHAR2 ) IS
	CURSOR C IS
		SELECT *
		FROM	JG_ZZ_TA_CC_RANGES
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
       AND (    (   (Recinfo.cc_range_id = X_cc_range_id )
        OR (    (Recinfo.cc_range_id IS NULL)
            AND (X_cc_range_id IS NULL))))
       AND (    (   (Recinfo.cc_range_low = X_cc_range_low )
        OR (    (Recinfo.cc_range_low IS NULL)
            AND (X_cc_range_high IS NULL))))
       AND (    (   (Recinfo.cc_range_high = X_cc_range_high )
        OR (    (Recinfo.cc_range_high IS NULL)
            AND (X_cc_range_high IS NULL))))
       AND (    (   (Recinfo.context = X_context )
        OR (    (Recinfo.context IS NULL)
            AND (X_context IS NULL))))
       AND (    (   (Recinfo.description = X_description )
        OR (    (Recinfo.description IS NULL)
            AND (X_description IS NULL))))
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
END JG_ZZ_TA_CC_RANGES_PKG;

/