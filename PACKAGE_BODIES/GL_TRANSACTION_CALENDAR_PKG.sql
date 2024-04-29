--------------------------------------------------------
--  DDL for Package Body GL_TRANSACTION_CALENDAR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_TRANSACTION_CALENDAR_PKG" AS
/* $Header: glitrclb.pls 120.5 2003/12/05 18:56:24 cma ship $ */

--
-- PUBLIC FUNCTIONS
--

  PROCEDURE check_unique(x_name VARCHAR2, row_id VARCHAR2) IS
    CURSOR chk_duplicates is
      SELECT 'Duplicate'
      FROM   GL_TRANSACTION_CALENDAR gps
      WHERE  gps.name = x_name
      AND    (   row_id is null
              OR gps.rowid <> row_id);
    dummy VARCHAR2(100);
  BEGIN
    OPEN chk_duplicates;
    FETCH chk_duplicates INTO dummy;

    IF chk_duplicates%FOUND THEN
      CLOSE chk_duplicates;
      fnd_message.set_name('SQLGL', 'GL_DUPLICATE_CALENDAR_NAME');
      app_exception.raise_exception;
    END IF;

    CLOSE chk_duplicates;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE', 'gl_transaction_calendar_pkg.check_unique');
      RAISE;
  END check_unique;

/* Added for Definition Access Sets Project */
PROCEDURE lock_row
       (X_Rowid                   	IN OUT NOCOPY VARCHAR2,
        x_transaction_calendar_id	NUMBER,
 	x_name				VARCHAR2,
 	x_sun_business_day_flag		VARCHAR2,
 	x_mon_business_day_flag		VARCHAR2,
 	x_tue_business_day_flag		VARCHAR2,
 	x_wed_business_day_flag		VARCHAR2,
 	x_thu_business_day_flag		VARCHAR2,
 	x_fri_business_day_flag		VARCHAR2,
 	x_sat_business_day_flag		VARCHAR2,
 	x_security_flag                 VARCHAR2,
 	x_description			VARCHAR2,
 	x_context			VARCHAR2,
 	x_attribute1			VARCHAR2,
 	x_attribute2			VARCHAR2,
 	x_attribute3			VARCHAR2,
 	x_attribute4			VARCHAR2,
 	x_attribute5			VARCHAR2,
 	x_attribute6			VARCHAR2,
 	x_attribute7			VARCHAR2,
 	x_attribute8			VARCHAR2,
 	x_attribute9			VARCHAR2,
 	x_attribute10			VARCHAR2,
 	x_attribute11			VARCHAR2,
 	x_attribute12			VARCHAR2,
 	x_attribute13			VARCHAR2,
 	x_attribute14			VARCHAR2,
 	x_attribute15			VARCHAR2
 	) IS
  CURSOR C IS SELECT
	transaction_calendar_id,
 	name,
 	sun_business_day_flag,
 	mon_business_day_flag,
 	tue_business_day_flag,
 	wed_business_day_flag,
 	thu_business_day_flag,
 	fri_business_day_flag,
 	sat_business_day_flag,
 	security_flag,
 	description,
 	context,
 	attribute1,
 	attribute2,
 	attribute3,
 	attribute4,
 	attribute5,
 	attribute6,
 	attribute7,
 	attribute8,
 	attribute9,
 	attribute10,
 	attribute11,
 	attribute12,
 	attribute13,
 	attribute14,
 	attribute15
    FROM gl_transaction_calendar
    WHERE ROWID = X_Rowid
    FOR UPDATE OF transaction_calendar_id NOWAIT;
  recinfo C%ROWTYPE;

BEGIN
    OPEN C;
    FETCH C INTO recinfo;
    IF (C%NOTFOUND) THEN
      CLOSE C;
      fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      app_exception.raise_exception;
    END IF;
    CLOSE C;

    IF (
        (recinfo.transaction_calendar_id = x_transaction_calendar_id)
        AND (recinfo.name = x_name)
        AND (recinfo.sun_business_day_flag = x_sun_business_day_flag)
        AND (recinfo.mon_business_day_flag = x_mon_business_day_flag)
        AND (recinfo.tue_business_day_flag = x_tue_business_day_flag)
        AND (recinfo.wed_business_day_flag = x_wed_business_day_flag)
        AND (recinfo.thu_business_day_flag = x_thu_business_day_flag)
        AND (recinfo.fri_business_day_flag = x_fri_business_day_flag)
        AND (recinfo.sat_business_day_flag = x_sat_business_day_flag)
        AND (recinfo.security_flag = x_security_flag)


        AND ((recinfo.description = x_description)
             OR ((recinfo.description is null)
                 AND (x_description is null)))

        AND ((recinfo.context = x_context)
             OR ((recinfo.context is null)
                 AND (x_context is null)))

        AND ((recinfo.attribute1 = x_attribute1)
             OR ((recinfo.attribute1 is null)
                 AND (x_attribute1 is null)))

        AND ((recinfo.attribute2 = x_attribute2)
             OR ((recinfo.attribute2 is null)
                 AND (x_attribute2 is null)))

        AND ((recinfo.attribute3 = x_attribute3)
             OR ((recinfo.attribute3 is null)
                 AND (x_attribute3 is null)))

        AND ((recinfo.attribute4 = x_attribute4)
             OR ((recinfo.attribute4 is null)
                 AND (x_attribute4 is null)))

        AND ((recinfo.attribute5 = x_attribute5)
             OR ((recinfo.attribute5 is null)
                 AND (x_attribute5 is null)))

        AND ((recinfo.attribute6 = x_attribute6)
             OR ((recinfo.attribute6 is null)
                 AND (x_attribute6 is null)))

        AND ((recinfo.attribute7 = x_attribute7)
             OR ((recinfo.attribute7 is null)
                 AND (x_attribute7 is null)))

        AND ((recinfo.attribute8 = x_attribute8)
             OR ((recinfo.attribute8 is null)
                 AND (x_attribute8 is null)))

        AND ((recinfo.attribute9 = x_attribute9)
             OR ((recinfo.attribute9 is null)
                 AND (x_attribute9 is null)))

        AND ((recinfo.attribute10 = x_attribute10)
             OR ((recinfo.attribute10 is null)
                 AND (x_attribute10 is null)))

        AND ((recinfo.attribute11 = x_attribute11)
             OR ((recinfo.attribute11 is null)
                 AND (x_attribute11 is null)))

        AND ((recinfo.attribute12 = x_attribute12)
             OR ((recinfo.attribute12 is null)
                 AND (x_attribute12 is null)))

        AND ((recinfo.attribute13 = x_attribute13)
             OR ((recinfo.attribute13 is null)
                 AND (x_attribute13 is null)))

        AND ((recinfo.attribute14 = x_attribute14)
             OR ((recinfo.attribute14 is null)
                 AND (x_attribute14 is null)))

        AND ((recinfo.attribute15 = x_attribute15)
             OR ((recinfo.attribute15 is null)
                 AND (x_attribute15 is null)))
    ) THEN
        return;
    ELSE
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      app_exception.raise_exception;
    END IF;

END lock_row;

/* Added x_security_flag for Definition Access Sets Project */
PROCEDURE insert_row
  	(X_Rowid                   	IN OUT NOCOPY VARCHAR2,
  	x_transaction_calendar_id	IN OUT NOCOPY NUMBER,
 	x_name				VARCHAR2,
 	x_sun_business_day_flag		VARCHAR2,
 	x_mon_business_day_flag		VARCHAR2,
 	x_tue_business_day_flag		VARCHAR2,
 	x_wed_business_day_flag		VARCHAR2,
 	x_thu_business_day_flag		VARCHAR2,
 	x_fri_business_day_flag		VARCHAR2,
 	x_sat_business_day_flag		VARCHAR2,
 	x_security_flag                 VARCHAR2,
 	x_creation_date			DATE,
 	x_created_by			NUMBER,
 	x_last_update_date		DATE,
 	x_last_updated_by		NUMBER,
 	x_last_update_login		NUMBER,
 	x_description			VARCHAR2,
 	x_context			VARCHAR2,
 	x_attribute1			VARCHAR2,
 	x_attribute2			VARCHAR2,
 	x_attribute3			VARCHAR2,
 	x_attribute4			VARCHAR2,
 	x_attribute5			VARCHAR2,
 	x_attribute6			VARCHAR2,
 	x_attribute7			VARCHAR2,
 	x_attribute8			VARCHAR2,
 	x_attribute9			VARCHAR2,
 	x_attribute10			VARCHAR2,
 	x_attribute11			VARCHAR2,
 	x_attribute12			VARCHAR2,
 	x_attribute13			VARCHAR2,
 	x_attribute14			VARCHAR2,
 	x_attribute15			VARCHAR2
 	) IS
   CURSOR C_ROWID IS SELECT rowid FROM gl_transaction_calendar
                 WHERE transaction_calendar_id = x_transaction_calendar_id;

BEGIN
  -- insert the record
  INSERT INTO gl_transaction_calendar
	(
  	transaction_calendar_id,
 	name,
 	sun_business_day_flag,
 	mon_business_day_flag,
 	tue_business_day_flag,
 	wed_business_day_flag,
 	thu_business_day_flag,
 	fri_business_day_flag,
 	sat_business_day_flag,
 	security_flag,
 	creation_date,
 	created_by,
 	last_update_date,
 	last_updated_by,
 	last_update_login,
 	description,
 	context,
 	attribute1,
 	attribute2,
 	attribute3,
 	attribute4,
 	attribute5,
 	attribute6,
 	attribute7,
 	attribute8,
 	attribute9,
 	attribute10,
 	attribute11,
 	attribute12,
 	attribute13,
 	attribute14,
 	attribute15
 	)
 	VALUES
 	(
  	x_transaction_calendar_id,
 	x_name,
 	x_sun_business_day_flag,
 	x_mon_business_day_flag,
 	x_tue_business_day_flag,
 	x_wed_business_day_flag,
 	x_thu_business_day_flag,
 	x_fri_business_day_flag,
 	x_sat_business_day_flag,
 	x_security_flag,
  	x_creation_date,
 	x_created_by,
 	x_last_update_date,
 	x_last_updated_by,
 	x_last_update_login,
 	x_description,
 	x_context,
 	x_attribute1,
 	x_attribute2,
 	x_attribute3,
 	x_attribute4,
 	x_attribute5,
 	x_attribute6,
 	x_attribute7,
 	x_attribute8,
 	x_attribute9,
 	x_attribute10,
 	x_attribute11,
 	x_attribute12,
 	x_attribute13,
 	x_attribute14,
 	x_attribute15
 	);

   -- get rowid to return it back
   OPEN C_ROWID;
   FETCH C_ROWID INTO X_Rowid;
   IF (C_ROWID%NOTFOUND) THEN
      CLOSE C_ROWID;
      Raise NO_DATA_FOUND;
   END IF;
   CLOSE C_ROWID;

END insert_row;

PROCEDURE Delete_Row(x_transaction_calendar_id	NUMBER) IS
  CURSOR check_ledger IS
	SELECT '1'
    FROM dual
	WHERE EXISTS
		(SELECT 'Used by ledger'
		FROM	GL_LEDGERS
		WHERE
			transaction_calendar_id = x_transaction_calendar_id
		);
  dummy 	VARCHAR2(1000);
BEGIN
  -- make sure that this transaction calendar is not being used by any
  -- of the ledgers
    OPEN check_ledger;
    FETCH check_ledger INTO dummy;
    IF (check_ledger%NOTFOUND) THEN
      CLOSE check_ledger;
    ELSE
      -- it is being used by some ledger, exit
      CLOSE check_ledger;
      fnd_message.set_name('SQLGL', 'GL_AB_TR_CAL_IS_USED');
      app_exception.raise_exception;
    END IF;

  -- delete from gl_transaction_calendar
  DELETE FROM GL_TRANSACTION_CALENDAR
  WHERE transaction_calendar_id = x_transaction_calendar_id;

  -- delete from gl_transaction_dates
  DELETE FROM GL_TRANSACTION_DATES
  WHERE transaction_calendar_id = x_transaction_calendar_id;

END Delete_Row;

PROCEDURE check_calendar(x_transaction_calendar_id	NUMBER) IS
  CURSOR check_ledger IS
	SELECT '1'
    FROM dual
	WHERE EXISTS
		(SELECT 'Used by ledger'
		FROM	GL_LEDGERS
		WHERE
			transaction_calendar_id = x_transaction_calendar_id
		);
  dummy 	VARCHAR2(1000);
BEGIN
  -- make sure that this transaction calendar is not being used by any
  -- of the ledgers
    OPEN check_ledger;
    FETCH check_ledger INTO dummy;
    IF (check_ledger%NOTFOUND) THEN
      CLOSE check_ledger;
    ELSE
      -- it is being used by some ledger, exit
      CLOSE check_ledger;
      fnd_message.set_name('SQLGL', 'GL_AB_TR_CAL_IS_USED');
      app_exception.raise_exception;
    END IF;

END check_calendar;
END GL_TRANSACTION_CALENDAR_PKG;

/
