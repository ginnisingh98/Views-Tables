--------------------------------------------------------
--  DDL for Package Body GL_ELIMINATION_SETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_ELIMINATION_SETS_PKG" As
/* $Header: gliesetb.pls 120.6 2005/05/05 01:07:26 kvora ship $ */

  ---
  --- PRIVATE VARIABLES
  ---

  --- Position of the balancing segment
  company_seg_num	NUMBER := null;


  -- Function
  --   get_unique_id
  -- Purpose
  --   Returns nextval from gl_elimination_sets_s
  -- Parameters
  --   None
  -- History
  --   11-06-1998  W Wong    Created
  -- Notes
  --   Raises GL_ERROR_GETTING_UNIQUE_ID on failure
  --
  FUNCTION get_unique_id RETURN NUMBER IS

    CURSOR get_new_id IS
      SELECT gl_elimination_sets_s.NEXTVAL
      FROM dual;
    new_id number;

  BEGIN
    OPEN get_new_id;
    FETCH get_new_id INTO new_id;

    IF get_new_id%FOUND THEN
      CLOSE get_new_id;
      return(new_id);
    ELSE
      CLOSE get_new_id;
      fnd_message.set_name('SQLGL', 'GL_ERROR_GETTING_UNIQUE_ID');
      fnd_message.set_token('SEQUENCE', 'GL_ELIMINATION_SETS_S');
      app_exception.raise_exception;
    END IF;

  EXCEPTION

    WHEN app_exceptions.application_exception THEN
      RAISE;

    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token(
          'PROCEDURE',
          'gl_elimination_sets_pkg.get_unique_id');
      RAISE;
  END get_unique_id;

  --
  -- Procedure
  --   get_company_description
  -- Purpose
  --   Gets the description for the elimination company value
  -- History
  --   05-Nov-98  W Wong 	Created
  -- Parameters
  --   x_coa_id 		ID of the current chart of accounts
  --   x_company_val		Elimination company value
  -- Notes
  --   None
  --
  FUNCTION get_company_description(
	      x_coa_id					NUMBER,
	      x_company_val				VARCHAR2
	   ) RETURN VARCHAR2 IS
  BEGIN
    IF (company_seg_num IS NULL) THEN
      IF (NOT fnd_flex_apis.get_qualifier_segnum(
                appl_id 		=> 101,
                key_flex_code		=> 'GL#',
      	        structure_number	=> x_coa_id,
	        flex_qual_name		=> 'GL_BALANCING',
	        segment_number		=> company_seg_num)
          ) THEN
        app_exception.raise_exception;
      END IF;
    END IF;

    -- Get the description
    IF (fnd_flex_keyval.validate_segs(
          operation => 'CHECK_SEGMENTS',
          appl_short_name => 'SQLGL',
          key_flex_code => 'GL#',
          structure_number => x_coa_id,
          concat_segments => x_company_val,
          displayable => 'GL_BALANCING',
          allow_nulls => TRUE,
          allow_orphans => TRUE)) THEN
      null;
    END IF;

    RETURN(fnd_flex_keyval.segment_description(company_seg_num));
  END get_company_description;


  --
  -- Procedure
  --   Check_unique_name
  -- Purpose
  --   Unique check for name
  -- History
  --   05-Nov-98  W Wong 	Created
  --   31-OCT-02  J Huang	sobid-->ledgerid
  -- Parameters
  --   x_rowid		Rowid
  --   x_ledgerid	Ledger ID
  --   x_name  		Name of elimination set
  --
  -- Notes
  --   None
  --
  PROCEDURE check_unique_name(X_rowid VARCHAR2,
			      X_ledgerid NUMBER,
                              X_name VARCHAR2) IS
    counter NUMBER;

    CURSOR name_count IS
       SELECT 1
       FROM DUAL
       WHERE EXISTS (SELECT 1
                   FROM  gl_elimination_sets
                   WHERE name = X_name
		   AND   ledger_id = X_ledgerid
                   AND   ((X_rowid IS NULL) OR (rowid <> X_rowid)));
  BEGIN

    OPEN name_count;
    FETCH name_count INTO counter;

    IF name_count%FOUND THEN
      CLOSE name_count;
      FND_MESSAGE.set_name('SQLGL', 'GL_DUPLICATE_NAME');
      APP_EXCEPTION.raise_exception;

    ELSE
      CLOSE name_count;
    END IF;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token(
          'PROCEDURE',
          'gl_elimination_sets_pkg.check_unique_name');
      RAISE;
  END check_unique_name;

  --
  -- Function
  --   Allow_delete_record
  -- Purpose
  --   Check if we can allow deletion of the record.
  --   Deletion is not allowed if an elimination set is marked for tracking
  --   and it has generated at least once.
  -- History
  --   05-Nov-98  W Wong 	Created
  -- Parameters
  --   x_setid          Elimination Set ID
  --
  -- Notes
  --   None
  --
  FUNCTION allow_delete_record( X_setid NUMBER ) RETURN BOOLEAN IS

    counter NUMBER;

    CURSOR set_count IS
       SELECT 1
       FROM DUAL
       WHERE EXISTS (SELECT 1
                     FROM  gl_elimination_sets
                     WHERE elimination_set_id = X_setid
  		     AND   track_elimination_status_flag = 'Y'
		     AND   last_executed_period IS NOT NULL);
  BEGIN

    OPEN set_count;
    FETCH set_count INTO counter;

    IF set_count%FOUND THEN
      CLOSE set_count;
      return( FALSE );

    ELSE
      CLOSE set_count;
      return( TRUE );
    END IF;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token(
          'PROCEDURE',
          'gl_elimination_sets_pkg.allow_delete_record');
      RAISE;
  END allow_delete_record;

  --
  -- Procedure
  --   lock_row
  -- Purpose
  --   Locks a row in GL_ELIMINATION_SETS table.
  -- History
  --   10-SEP-03  P Sahay 	Created (For Definition Access Set Project)
  -- Parameters
  --   All the columns of GL_ELIMINATION_SETS table
  --   (except WHO columns)
  --
  -- Notes
  --   None
  --
PROCEDURE lock_row  (X_Rowid                  IN OUT NOCOPY    VARCHAR2,
                     X_Elimination_Set_Id     IN OUT NOCOPY    NUMBER,
                     X_Name                                VARCHAR2,
                     X_Ledger_Id                           NUMBER,
                     X_Track_Elimination_Status            VARCHAR2,
                     X_Start_Date_Active                   DATE,
                     X_End_Date_Active                     DATE,
                     X_Elimination_Company                 VARCHAR2,
                     X_Last_Executed_Period                VARCHAR2,
                     X_Description                         VARCHAR2,
                     X_Attribute1                          VARCHAR2,
                     X_Attribute2                          VARCHAR2,
                     X_Attribute3                          VARCHAR2,
                     X_Attribute4                          VARCHAR2,
                     X_Attribute5                          VARCHAR2,
                     X_Attribute6                          VARCHAR2,
                     X_Attribute7                          VARCHAR2,
                     X_Attribute8                          VARCHAR2,
                     X_Attribute9                          VARCHAR2,
                     X_Attribute10                         VARCHAR2,
                     X_Attribute11                         VARCHAR2,
                     X_Attribute12                         VARCHAR2,
                     X_Attribute13                         VARCHAR2,
                     X_Attribute14                         VARCHAR2,
                     X_Attribute15                         VARCHAR2,
                     X_Context                             VARCHAR2,
                     X_Security_Flag                       VARCHAR2) IS
  CURSOR C IS SELECT
	        elimination_set_id,
		name,
		ledger_id,
		track_elimination_status_flag,
		start_date_active,
		end_date_active,
		elimination_company,
		last_executed_period,
		description,
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
		attribute15,
		context,
		security_flag
    FROM GL_ELIMINATION_SETS
    WHERE ROWID = X_Rowid
    FOR UPDATE OF elimination_set_id NOWAIT;
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
        (recinfo.elimination_set_id = x_elimination_set_id)
        AND (recinfo.name = x_name)
        AND (recinfo.ledger_id = x_ledger_id)
        AND (recinfo.track_elimination_status_flag = x_track_elimination_status)
        AND (recinfo.security_flag = x_security_flag)

	AND ((recinfo.start_date_active = x_start_date_active)
             OR ((recinfo.start_date_active is null)
                 AND (x_start_date_active is null)))

        AND ((recinfo.end_date_active = x_end_date_active)
             OR ((recinfo.end_date_active is null)
                 AND (x_end_date_active is null)))

        AND ((recinfo.elimination_company = x_elimination_company)
             OR ((recinfo.elimination_company is null)
                 AND (x_elimination_company is null)))

        AND ((recinfo.last_executed_period = x_last_executed_period)
             OR ((recinfo.last_executed_period is null)
                 AND (x_last_executed_period is null)))

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

End gl_elimination_sets_pkg;

/
