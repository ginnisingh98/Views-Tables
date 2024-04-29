--------------------------------------------------------
--  DDL for Package Body XTR_HEDGE_PRO_TESTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XTR_HEDGE_PRO_TESTS_PKG" as
/* $Header: xtrhprob.pls 120.1 2005/06/29 08:27:31 badiredd noship $ */

PROCEDURE INSERT_ROW(
		X_ROWID IN OUT NOCOPY VARCHAR2,
                X_HEDGE_PRO_TEST_ID NUMBER,
                X_HEDGE_ATTRIBUTE_ID NUMBER,
                X_COMPANY_CODE VARCHAR2,
                X_RESULT_CODE VARCHAR2,
                X_RESULT_DATE DATE,
                X_LAST_TEST_DATE DATE,
                X_PERFORMED_BY NUMBER,
                X_COMMENTS VARCHAR2,
		X_ATTRIBUTE_CATEGORY VARCHAR2,
		X_ATTRIBUTE1 VARCHAR2,
		X_ATTRIBUTE2 VARCHAR2,
		X_ATTRIBUTE3 VARCHAR2,
		X_ATTRIBUTE4 VARCHAR2,
		X_ATTRIBUTE5 VARCHAR2,
		X_ATTRIBUTE6 VARCHAR2,
		X_ATTRIBUTE7 VARCHAR2,
		X_ATTRIBUTE8 VARCHAR2,
		X_ATTRIBUTE9 VARCHAR2,
		X_ATTRIBUTE10 VARCHAR2,
		X_ATTRIBUTE11 VARCHAR2,
		X_ATTRIBUTE12 VARCHAR2,
		X_ATTRIBUTE13 VARCHAR2,
		X_ATTRIBUTE14 VARCHAR2,
		X_ATTRIBUTE15 VARCHAR2,
		X_CREATED_BY NUMBER,
		X_CREATION_DATE DATE,
		X_LAST_UPDATED_BY NUMBER,
		X_LAST_UPDATE_DATE DATE,
		X_LAST_UPDATE_LOGIN NUMBER) IS
    cursor C is select ROWID from XTR_HEDGE_PRO_TESTS
    where HEDGE_PRO_TEST_ID = X_HEDGE_PRO_TEST_ID;

BEGIN
  INSERT INTO XTR_HEDGE_PRO_TESTS(
        HEDGE_PRO_TEST_ID,
        HEDGE_ATTRIBUTE_ID,
        COMPANY_CODE,
        RESULT_CODE,
        RESULT_DATE,
        LAST_TEST_DATE,
        PERFORMED_BY,
        COMMENTS,
 	ATTRIBUTE_CATEGORY,
	ATTRIBUTE1,
	ATTRIBUTE2,
	ATTRIBUTE3,
	ATTRIBUTE4,
	ATTRIBUTE5,
	ATTRIBUTE6,
	ATTRIBUTE7,
	ATTRIBUTE8,
	ATTRIBUTE9,
	ATTRIBUTE10,
	ATTRIBUTE11,
	ATTRIBUTE12,
	ATTRIBUTE13,
	ATTRIBUTE14,
	ATTRIBUTE15,
	CREATED_BY,
	CREATION_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATE_LOGIN)
  VALUES (X_HEDGE_PRO_TEST_ID,
        X_HEDGE_ATTRIBUTE_ID,
        X_COMPANY_CODE,
        X_RESULT_CODE,
        X_RESULT_DATE,
        X_LAST_TEST_DATE,
        X_PERFORMED_BY,
        X_COMMENTS,
	X_ATTRIBUTE_CATEGORY,
	X_ATTRIBUTE1,
	X_ATTRIBUTE2,
	X_ATTRIBUTE3,
	X_ATTRIBUTE4,
	X_ATTRIBUTE5,
	X_ATTRIBUTE6,
	X_ATTRIBUTE7,
	X_ATTRIBUTE8,
	X_ATTRIBUTE9,
	X_ATTRIBUTE10,
	X_ATTRIBUTE11,
	X_ATTRIBUTE12,
	X_ATTRIBUTE13,
	X_ATTRIBUTE14,
	X_ATTRIBUTE15,
	X_CREATED_BY,
	X_CREATION_DATE,
	X_LAST_UPDATED_BY,
	X_LAST_UPDATE_DATE,
	X_LAST_UPDATE_LOGIN);

	OPEN C;
	FETCH C INTO X_ROWID;
	IF (C%NOTFOUND) THEN
		CLOSE C;
		RAISE NO_DATA_FOUND;
	END IF;
	CLOSE C;

END INSERT_ROW;

PROCEDURE DELETE_ROW (X_HEDGE_PRO_TEST_ID NUMBER) IS

BEGIN
	-- DELETE THE ROW, SINCE NOT USED ANYWHERE ELSE
	DELETE FROM XTR_HEDGE_PRO_TESTS
	WHERE HEDGE_PRO_TEST_ID = X_HEDGE_PRO_TEST_ID;
		IF (SQL%NOTFOUND) THEN
			RAISE NO_DATA_FOUND;
		END IF;
END DELETE_ROW;


PROCEDURE UPDATE_ROW(
		X_ROWID VARCHAR2,
                X_HEDGE_PRO_TEST_ID NUMBER,
                X_HEDGE_ATTRIBUTE_ID NUMBER,
                X_COMPANY_CODE VARCHAR2,
                X_RESULT_CODE VARCHAR2,
                X_RESULT_DATE DATE,
                X_LAST_TEST_DATE DATE,
                X_PERFORMED_BY NUMBER,
                X_COMMENTS VARCHAR2,
		X_ATTRIBUTE_CATEGORY VARCHAR2,
		X_ATTRIBUTE1 VARCHAR2,
		X_ATTRIBUTE2 VARCHAR2,
		X_ATTRIBUTE3 VARCHAR2,
		X_ATTRIBUTE4 VARCHAR2,
		X_ATTRIBUTE5 VARCHAR2,
		X_ATTRIBUTE6 VARCHAR2,
		X_ATTRIBUTE7 VARCHAR2,
		X_ATTRIBUTE8 VARCHAR2,
		X_ATTRIBUTE9 VARCHAR2,
		X_ATTRIBUTE10 VARCHAR2,
		X_ATTRIBUTE11 VARCHAR2,
		X_ATTRIBUTE12 VARCHAR2,
		X_ATTRIBUTE13 VARCHAR2,
		X_ATTRIBUTE14 VARCHAR2,
		X_ATTRIBUTE15 VARCHAR2,
		X_LAST_UPDATED_BY NUMBER,
		X_LAST_UPDATE_DATE DATE,
		X_LAST_UPDATE_LOGIN NUMBER) IS
BEGIN
	UPDATE XTR_HEDGE_PRO_TESTS
	SET
                HEDGE_PRO_TEST_ID       = X_HEDGE_PRO_TEST_ID,
                HEDGE_ATTRIBUTE_ID      = X_HEDGE_ATTRIBUTE_ID,
                COMPANY_CODE		= X_COMPANY_CODE,
                RESULT_CODE		= X_RESULT_CODE,
                RESULT_DATE 		= X_RESULT_DATE,
                LAST_TEST_DATE		= X_LAST_TEST_DATE,
                PERFORMED_BY		= X_PERFORMED_BY,
                COMMENTS		= X_COMMENTS,
		ATTRIBUTE_CATEGORY	= X_ATTRIBUTE_CATEGORY,
		ATTRIBUTE1	=	X_ATTRIBUTE1,
		ATTRIBUTE2	=	X_ATTRIBUTE2,
		ATTRIBUTE3	=	X_ATTRIBUTE3,
		ATTRIBUTE4	=	X_ATTRIBUTE4,
		ATTRIBUTE5	=	X_ATTRIBUTE5,
		ATTRIBUTE6	=	X_ATTRIBUTE6,
		ATTRIBUTE7	=	X_ATTRIBUTE7,
		ATTRIBUTE8	=	X_ATTRIBUTE8,
		ATTRIBUTE9	=	X_ATTRIBUTE9,
		ATTRIBUTE10	=	X_ATTRIBUTE10,
		ATTRIBUTE11	=	X_ATTRIBUTE11,
		ATTRIBUTE12	=	X_ATTRIBUTE12,
		ATTRIBUTE13	=	X_ATTRIBUTE13,
		ATTRIBUTE14	=	X_ATTRIBUTE14,
		ATTRIBUTE15	=	X_ATTRIBUTE15,
		LAST_UPDATED_BY	=	X_LAST_UPDATED_BY,
		LAST_UPDATE_DATE	=	X_LAST_UPDATE_DATE,
		LAST_UPDATE_LOGIN	=	X_LAST_UPDATE_LOGIN
	WHERE HEDGE_PRO_TEST_ID = X_HEDGE_PRO_TEST_ID;

	IF (SQL%NOTFOUND) THEN
		RAISE NO_DATA_FOUND;
	END IF;
END UPDATE_ROW;

PROCEDURE LOCK_ROW (
		X_ROWID VARCHAR2,
                X_HEDGE_PRO_TEST_ID NUMBER,
                X_HEDGE_ATTRIBUTE_ID NUMBER,
                X_COMPANY_CODE VARCHAR2,
                X_RESULT_CODE VARCHAR2,
                X_RESULT_DATE DATE,
                X_LAST_TEST_DATE DATE,
                X_PERFORMED_BY NUMBER,
                X_COMMENTS VARCHAR2,
		X_ATTRIBUTE_CATEGORY VARCHAR2,
		X_ATTRIBUTE1 VARCHAR2,
		X_ATTRIBUTE2 VARCHAR2,
		X_ATTRIBUTE3 VARCHAR2,
		X_ATTRIBUTE4 VARCHAR2,
		X_ATTRIBUTE5 VARCHAR2,
		X_ATTRIBUTE6 VARCHAR2,
		X_ATTRIBUTE7 VARCHAR2,
		X_ATTRIBUTE8 VARCHAR2,
		X_ATTRIBUTE9 VARCHAR2,
		X_ATTRIBUTE10 VARCHAR2,
		X_ATTRIBUTE11 VARCHAR2,
		X_ATTRIBUTE12 VARCHAR2,
		X_ATTRIBUTE13 VARCHAR2,
		X_ATTRIBUTE14 VARCHAR2,
		X_ATTRIBUTE15 VARCHAR2) IS

	CURSOR C IS
		SELECT *
		FROM XTR_HEDGE_PRO_TESTS
		WHERE HEDGE_PRO_TEST_ID = X_HEDGE_PRO_TEST_ID
		FOR UPDATE OF RESULT_CODE NOWAIT;
	RECINFO C%ROWTYPE;

BEGIN
	OPEN C;
	FETCH C INTO RECINFO;
	IF (C%NOTFOUND) THEN
		CLOSE C;
		FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
		APP_EXCEPTION.RAISE_EXCEPTION;
	END IF;
	CLOSE C;

	IF (
			(RECINFO.HEDGE_PRO_TEST_ID = X_HEDGE_PRO_TEST_ID)
		AND     (RECINFO.HEDGE_ATTRIBUTE_ID= X_HEDGE_ATTRIBUTE_ID)
		AND     (RECINFO.COMPANY_CODE	   = X_COMPANY_CODE)
		AND	(	(RECINFO.RESULT_CODE = X_RESULT_CODE)
			OR	(	(RECINFO.RESULT_CODE IS NULL)
				AND 	(X_RESULT_CODE IS NULL)))
		AND	(	(RECINFO.RESULT_DATE = X_RESULT_DATE)
			OR	(	(RECINFO.RESULT_DATE IS NULL)
				AND	(X_RESULT_DATE IS NULL)))
                AND     (       (RECINFO.LAST_TEST_DATE = X_LAST_TEST_DATE)
                        OR      (       (RECINFO.LAST_TEST_DATE IS NULL)
                                AND     (X_LAST_TEST_DATE IS NULL)))
                AND     (       (RECINFO.PERFORMED_BY = X_PERFORMED_BY)
                        OR      (       (RECINFO.PERFORMED_BY IS NULL)
                                AND     (X_PERFORMED_BY IS NULL)))
                AND     (       (RECINFO.COMMENTS = X_COMMENTS)
                        OR      (       (RECINFO.COMMENTS IS NULL)
                                AND     (X_COMMENTS IS NULL)))
		AND	(	(RECINFO.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
			OR	(	(RECINFO.ATTRIBUTE_CATEGORY IS NULL)
				AND 	(X_ATTRIBUTE_CATEGORY IS NULL)))
		AND	(	(RECINFO.ATTRIBUTE1 = X_ATTRIBUTE1)
			OR	(	(RECINFO.ATTRIBUTE1 IS NULL)
				AND	(X_ATTRIBUTE1 IS NULL)))
		AND	(	(RECINFO.ATTRIBUTE2 = X_ATTRIBUTE2)
			OR	(	(RECINFO.ATTRIBUTE2 IS NULL)
				AND	(X_ATTRIBUTE2 IS NULL)))
		AND	(	(RECINFO.ATTRIBUTE3 = X_ATTRIBUTE3)
			OR	(	(RECINFO.ATTRIBUTE3 IS NULL)
				AND	(X_ATTRIBUTE3 IS NULL)))
		AND	(	(RECINFO.ATTRIBUTE4 = X_ATTRIBUTE4)
			OR	(	(RECINFO.ATTRIBUTE4 IS NULL)
				AND	(X_ATTRIBUTE4 IS NULL)))
		AND	(	(RECINFO.ATTRIBUTE5 = X_ATTRIBUTE5)
			OR	(	(RECINFO.ATTRIBUTE5 IS NULL)
				AND	(X_ATTRIBUTE5 IS NULL)))
		AND	(	(RECINFO.ATTRIBUTE6 = X_ATTRIBUTE6)
			OR	(	(RECINFO.ATTRIBUTE6 IS NULL)
				AND	(X_ATTRIBUTE6 IS NULL)))
		AND	(	(RECINFO.ATTRIBUTE7 = X_ATTRIBUTE7)
			OR	(	(RECINFO.ATTRIBUTE7 IS NULL)
				AND	(X_ATTRIBUTE7 IS NULL)))
		AND	(	(RECINFO.ATTRIBUTE8 = X_ATTRIBUTE8)
			OR	(	(RECINFO.ATTRIBUTE8 IS NULL)
				AND	(X_ATTRIBUTE8 IS NULL)))
		AND	(	(RECINFO.ATTRIBUTE9 = X_ATTRIBUTE9)
			OR	(	(RECINFO.ATTRIBUTE9 IS NULL)
				AND	(X_ATTRIBUTE9 IS NULL)))
		AND	(	(RECINFO.ATTRIBUTE10 = X_ATTRIBUTE10)
			OR	(	(RECINFO.ATTRIBUTE10 IS NULL)
				AND	(X_ATTRIBUTE10 IS NULL)))
		AND	(	(RECINFO.ATTRIBUTE11 = X_ATTRIBUTE11)
			OR	(	(RECINFO.ATTRIBUTE11 IS NULL)
				AND	(X_ATTRIBUTE11 IS NULL)))
		AND	(	(RECINFO.ATTRIBUTE12 = X_ATTRIBUTE12)
			OR	(	(RECINFO.ATTRIBUTE12 IS NULL)
				AND	(X_ATTRIBUTE12 IS NULL)))
		AND	(	(RECINFO.ATTRIBUTE13 = X_ATTRIBUTE13)
			OR	(	(RECINFO.ATTRIBUTE13 IS NULL)
				AND	(X_ATTRIBUTE13 IS NULL)))
		AND	(	(RECINFO.ATTRIBUTE14 = X_ATTRIBUTE14)
			OR	(	(RECINFO.ATTRIBUTE14 IS NULL)
				AND	(X_ATTRIBUTE14 IS NULL)))
		AND	(	(RECINFO.ATTRIBUTE15 = X_ATTRIBUTE15)
			OR	(	(RECINFO.ATTRIBUTE15 IS NULL)
				AND	(X_ATTRIBUTE15 IS NULL)))

		) THEN
		RETURN;
	ELSE
		FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
		APP_EXCEPTION.RAISE_EXCEPTION;
	END IF;
END LOCK_ROW;

END XTR_HEDGE_PRO_TESTS_PKG;


/