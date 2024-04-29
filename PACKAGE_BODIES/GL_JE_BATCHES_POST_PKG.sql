--------------------------------------------------------
--  DDL for Package Body GL_JE_BATCHES_POST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_JE_BATCHES_POST_PKG" as
/* $Header: glijebpb.pls 120.5 2005/09/19 18:39:19 kvora ship $ */

  PROCEDURE set_access_set_id ( X_access_set_id   NUMBER) IS
  BEGIN
    gl_je_batches_post_pkg.access_set_id := X_access_set_id;
  END set_access_set_id;

  FUNCTION get_access_set_id RETURN NUMBER IS
  BEGIN
    RETURN gl_je_batches_post_pkg.access_set_id;
  END get_access_set_id;

  FUNCTION get_unique_id RETURN NUMBER IS
    CURSOR get_new_id IS
      SELECT gl_je_posting_s.NEXTVAL
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
      fnd_message.set_token('SEQUENCE', 'GL_JE_POSTING_S');
      app_exception.raise_exception;
    END IF;
  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE', 'gl_je_batches_post_pkg.get_unique_id');
      RAISE;
  END get_unique_id;


  FUNCTION check_budget_status( X_je_batch_id   NUMBER,
				X_period_year   NUMBER ) RETURN VARCHAR2 IS
    CURSOR check_frozen IS
      SELECT
	      'BF'
      FROM
	      dual
      WHERE   EXISTS
	      (  SELECT  'Frozen budget'
	         FROM    GL_BUDGET_VERSIONS BV,
		         GL_JE_HEADERS JH
	         WHERE   BV.status in ('I', 'F')
	         AND     BV.budget_version_id = JH.budget_version_id
	         AND     JH.je_batch_id = X_je_batch_id );

    CURSOR check_unopened_year IS
      SELECT
	      'BU'
      FROM
	      dual
      WHERE   EXISTS
	      (  SELECT  'Unopened budget year'
	         FROM    GL_BUDGETS GB,
			 GL_BUDGET_VERSIONS BV,
		         GL_JE_HEADERS JH
	         WHERE   GB.budget_name = BV.budget_name
		 AND	 GB.budget_type = BV.budget_type
		 AND     (   GB.latest_opened_year IS NULL
			  OR GB.latest_opened_year < X_period_year )
	         AND     BV.budget_version_id = JH.budget_version_id
	         AND     JH.je_batch_id = X_je_batch_id );

    batch_status	VARCHAR2(2);
  BEGIN
    OPEN check_frozen;
    FETCH check_frozen INTO batch_status;
    IF check_frozen%FOUND THEN
      CLOSE check_frozen;
      RETURN( batch_status );
    ELSE
      CLOSE check_frozen;
      OPEN check_unopened_year;
      FETCH check_unopened_year INTO batch_status;
      IF check_unopened_year%FOUND THEN
        CLOSE check_unopened_year;
        RETURN( batch_status );
      ELSE
        CLOSE check_unopened_year;
	RETURN( 'OK' );
      END IF;
    END IF;
  END check_budget_status;


FUNCTION check_unbal_monetary_headers (X_je_batch_id NUMBER) RETURN BOOLEAN IS
  CURSOR chk_unbal_monetary_headers IS
    SELECT 'Out of Balance'
    FROM   SYS.DUAL
    WHERE  EXISTS
	    ( SELECT 'x'
	      FROM   GL_JE_HEADERS
	      WHERE  je_batch_id = X_je_batch_id
              AND    nvl(display_alc_journal_flag, 'Y') = 'Y'
	      AND    currency_code <> 'STAT'
	      AND    nvl(running_total_dr, 0) <> nvl(running_total_cr, 0));
  dummy VARCHAR2(100);
BEGIN
  OPEN chk_unbal_monetary_headers;
  FETCH chk_unbal_monetary_headers INTO dummy;

  IF chk_unbal_monetary_headers%FOUND THEN
    CLOSE chk_unbal_monetary_headers;
    return (TRUE);
  ELSE
    CLOSE chk_unbal_monetary_headers;
    return (FALSE);
  END IF;
END check_unbal_monetary_headers;


FUNCTION check_untax_monetary_headers (X_je_batch_id NUMBER) RETURN BOOLEAN IS
  CURSOR chk_untax_monetary_headers IS
    SELECT 'Untaxed'
    FROM   SYS.DUAL
    WHERE  EXISTS
	    ( SELECT 'x'
	      FROM   GL_JE_HEADERS
	      WHERE  je_batch_id = X_je_batch_id
              AND    nvl(display_alc_journal_flag, 'Y') = 'Y'
	      AND    currency_code <> 'STAT'
	      AND    tax_status_code = 'R');
  dummy VARCHAR2(100);
BEGIN
  OPEN chk_untax_monetary_headers;
  FETCH chk_untax_monetary_headers INTO dummy;

  IF chk_untax_monetary_headers%FOUND THEN
    CLOSE chk_untax_monetary_headers;
    return (TRUE);

  ELSE
    CLOSE chk_untax_monetary_headers;
    return (FALSE);
  END IF;
END check_untax_monetary_headers;


PROCEDURE Lock_Row(X_Rowid                                 VARCHAR2,
                   X_Je_Batch_Id                           NUMBER,
                   X_Chart_Of_Accounts_Id                  NUMBER,
                   X_Name                                  VARCHAR2,
                   X_Status                                VARCHAR2,
                   X_Status_Verified                       VARCHAR2,
                   X_Actual_Flag                           VARCHAR2,
                   X_Budgetary_Control_Status              VARCHAR2,
                   X_Default_Period_Name                   VARCHAR2,
                   X_Control_Total                         NUMBER,
                   X_Running_Total_Dr                      NUMBER,
                   X_Running_Total_Cr                      NUMBER,
                   X_Posting_Run_Id                        NUMBER,
                   X_Request_Id               		   NUMBER
) IS
  CURSOR C IS
      SELECT *
      FROM   gl_je_batches
      WHERE  rowid = X_Rowid
      FOR UPDATE of Je_Batch_Id NOWAIT;
  Recinfo C%ROWTYPE;
BEGIN
  OPEN C;
  FETCH C INTO Recinfo;
  if (C%NOTFOUND) then
    CLOSE C;
    RAISE NO_DATA_FOUND;
  end if;
  CLOSE C;
  if (
              (Recinfo.je_batch_id = X_Je_Batch_Id)
      AND     (Recinfo.chart_of_accounts_id = X_Chart_Of_Accounts_Id)
      AND     (Recinfo.name = X_Name)
      AND     (Recinfo.status = X_Status)
      AND     (Recinfo.status_verified = X_Status_Verified)
      AND     (Recinfo.actual_flag = X_Actual_Flag)
      AND     (Recinfo.budgetary_control_status = X_Budgetary_Control_Status)
      AND (   (Recinfo.default_period_name = X_Default_Period_Name)
           OR (    (Recinfo.default_period_name IS NULL)
               AND (X_Default_Period_Name IS NULL)))
      AND (   (Recinfo.control_total = X_Control_Total)
           OR (    (Recinfo.control_total IS NULL)
               AND (X_Control_Total IS NULL)))
      AND (   (Recinfo.running_total_dr = X_Running_Total_Dr)
           OR (    (Recinfo.running_total_dr IS NULL)
               AND (X_Running_Total_Dr IS NULL)))
      AND (   (Recinfo.running_total_cr = X_Running_Total_Cr)
           OR (    (Recinfo.running_total_cr IS NULL)
               AND (X_Running_Total_Cr IS NULL)))
      AND (   (Recinfo.posting_run_id = X_Posting_Run_Id)
           OR (    (Recinfo.posting_run_id IS NULL)
               AND (X_Posting_Run_Id IS NULL)))
      AND (   (Recinfo.request_id = X_Request_Id)
           OR (    (Recinfo.request_id IS NULL)
               AND (X_Request_Id IS NULL)))
          ) then
    return;
  else
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
END Lock_Row;


PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Je_Batch_Id                         NUMBER,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Chart_Of_Accounts_Id                NUMBER,
                     X_Name                                VARCHAR2,
                     X_Status                              VARCHAR2,
                     X_Status_Verified                     VARCHAR2,
                     X_Actual_Flag                         VARCHAR2,
                     X_Budgetary_Control_Status            VARCHAR2,
                     X_Last_Update_Login                   NUMBER,
                     X_Default_Period_Name                 VARCHAR2,
                     X_Control_Total                       NUMBER,
                     X_Running_Total_Dr                    NUMBER,
                     X_Running_Total_Cr                    NUMBER,
                     X_Posting_Run_Id                      NUMBER,
                     X_Request_Id             		   NUMBER
) IS
BEGIN
  UPDATE gl_je_batches
  SET
    je_batch_id                               =    X_Je_Batch_Id,
    last_update_date                          =    X_Last_Update_Date,
    last_updated_by                           =    X_Last_Updated_By,
    chart_of_accounts_id                      =    X_Chart_Of_Accounts_Id,
    name                                      =    X_Name,
    status                                    =    X_Status,
    status_verified                           =    X_Status_Verified,
    actual_flag                               =    X_Actual_Flag,
    budgetary_control_status                  =    X_Budgetary_Control_Status,
    last_update_login                         =    X_Last_Update_Login,
    default_period_name                       =    X_Default_Period_Name,
    control_total                             =    X_Control_Total,
    running_total_dr                          =    X_Running_Total_Dr,
    running_total_cr                          =    X_Running_Total_Cr,
    posting_run_id                            =    X_Posting_Run_Id,
    request_id                   	      =    X_Request_Id
  WHERE rowid = X_rowid;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;

  -- Update the status of the consolidation batch to 'PS' in
  -- gl_consolidation_history for Consolidation Workbench.
  UPDATE GL_CONSOLIDATION_HISTORY
  SET   status = 'PS',
        request_id = X_Request_Id
  WHERE je_batch_id = X_Je_Batch_Id;

  -- Update the status of the consolidation batch to 'PS' in
  -- gl_elimination_history for Consolidation Workbench.
  UPDATE GL_ELIMINATION_HISTORY
  SET   status_code = 'PS',
        request_id = X_Request_Id
  WHERE je_batch_id = X_Je_Batch_Id;

END Update_Row;



END GL_JE_BATCHES_POST_PKG;

/
