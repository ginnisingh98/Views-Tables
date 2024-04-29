--------------------------------------------------------
--  DDL for Package Body GL_JE_BATCHES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_JE_BATCHES_PKG" AS
/* $Header: glijebab.pls 120.16.12000000.2 2007/07/25 17:20:31 aktelang ship $ */

--
-- PUBLIC FUNCTIONS
--

  PROCEDURE check_unique(batch_name VARCHAR2,
                         period_name VARCHAR2,
                         coa_id NUMBER,
                         cal_name VARCHAR2,
                         per_type VARCHAR2,
                         row_id VARCHAR2) IS
    CURSOR chk_duplicates is
      SELECT 'Duplicate'
        FROM  GL_JE_BATCHES jeb
       WHERE  jeb.name = batch_name
         AND  jeb.default_period_name = period_name
         AND  jeb.chart_of_accounts_id = coa_id
         AND  jeb.period_set_name = cal_name
         AND  jeb.accounted_period_type = per_type
           AND    (   row_id is null
                   OR jeb.rowid <> row_id);
    dummy VARCHAR2(100);
  BEGIN
    OPEN chk_duplicates;
    FETCH chk_duplicates INTO dummy;

    IF chk_duplicates%FOUND THEN
      CLOSE chk_duplicates;
      fnd_message.set_name('SQLGL', 'GL_DUPLICATE_JE_BATCH_NAME');
      app_exception.raise_exception;
    END IF;

    CLOSE chk_duplicates;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE', 'gl_je_batches_pkg.check_unique');
      RAISE;
  END check_unique;

  FUNCTION get_unique_id RETURN NUMBER IS
    CURSOR get_new_id IS
      SELECT gl_je_batches_s.NEXTVAL
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
      fnd_message.set_token('SEQUENCE', 'GL_JE_BATCHES_S');
      app_exception.raise_exception;
    END IF;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE', 'gl_je_batches_pkg.get_unique_id');
      RAISE;
  END get_unique_id;


  FUNCTION has_lines(batch_id NUMBER) RETURN BOOLEAN IS
    CURSOR chk_batch IS
      SELECT 'Has Lines'
      FROM dual
      WHERE EXISTS (SELECT 'Found Line'
                    FROM   gl_je_headers jeh, gl_je_lines jel
                    WHERE  jeh.je_batch_id = batch_id
                    AND    jel.je_header_id = jeh.je_header_id);
    dummy VARCHAR2(100);
  BEGIN
    OPEN chk_batch;
    FETCH chk_batch INTO dummy;

    IF chk_batch%FOUND THEN
      CLOSE chk_batch;
      return(TRUE);
    ELSE
      CLOSE chk_batch;
      return(FALSE);
    END IF;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE', 'gl_je_batches_pkg.has_lines');
      RAISE;
  END has_lines;


  FUNCTION needs_approval(batch_id NUMBER) RETURN BOOLEAN IS
    CURSOR needs_apprvl IS
      SELECT 'Needs Approval'
      FROM dual
      WHERE EXISTS (SELECT 'Needs Approval'
                    FROM   gl_je_headers jeh, gl_ledgers lgr,
                           gl_je_sources src
                    WHERE  jeh.je_batch_id = batch_id
                    AND    lgr.ledger_id = jeh.ledger_id
                    AND    lgr.enable_je_approval_flag = 'Y'
                    AND    src.je_source_name = jeh.je_source
                    AND    src.journal_approval_flag = 'Y');
    dummy VARCHAR2(100);
  BEGIN
    OPEN needs_apprvl;
    FETCH needs_apprvl INTO dummy;

    IF needs_apprvl%FOUND THEN
      CLOSE needs_apprvl;
      return(TRUE);
    ELSE
      CLOSE needs_apprvl;
      return(FALSE);
    END IF;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE', 'gl_je_batches_pkg.needs_approval');
      RAISE;
  END needs_approval;

  FUNCTION needs_tax(batch_id NUMBER) RETURN BOOLEAN IS
    CURSOR needstx IS
      SELECT 'Needs Tax'
      FROM dual
      WHERE EXISTS (SELECT 'Needs Tax'
                    FROM   gl_je_headers jeh, gl_ledgers lgr
                    WHERE  jeh.je_batch_id = batch_id
                    AND    jeh.tax_status_code = 'R'
                    AND    lgr.ledger_id = jeh.ledger_id
                    AND    lgr.enable_automatic_tax_flag = 'Y');
    dummy VARCHAR2(100);
  BEGIN
    OPEN needstx;
    FETCH needstx INTO dummy;

    IF needstx%FOUND THEN
      CLOSE needstx;
      return(TRUE);
    ELSE
      CLOSE needstx;
      return(FALSE);
    END IF;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE', 'gl_je_batches_pkg.needs_tax');
      RAISE;
  END needs_tax;


  FUNCTION all_stat_headers( X_je_batch_id  NUMBER ) RETURN BOOLEAN IS
    CURSOR chk_all_stat_headers IS
      SELECT
	     decode(count(*),
	       sum(decode(JH.currency_code, 'STAT', 1, 0)), 'All STAT',
	       'Not all STAT')
      FROM
	     GL_JE_HEADERS JH
      WHERE
	     JH.je_batch_id = X_je_batch_id
      AND    (JH.display_alc_journal_flag is null or JH.display_alc_journal_flag = 'Y');
    dummy VARCHAR2(100);
  BEGIN
    OPEN chk_all_stat_headers;
    FETCH chk_all_stat_headers INTO dummy;

    IF ( chk_all_stat_headers%FOUND ) THEN
      CLOSE chk_all_stat_headers;
      RETURN( dummy = 'All STAT' );
    ELSE
      CLOSE chk_all_stat_headers;
      return(FALSE);
    END IF;
  END all_stat_headers;

  FUNCTION bc_ledger( X_je_batch_id  NUMBER ) RETURN NUMBER IS
    CURSOR get_ledger_id IS
      SELECT
	     DISTINCT JH.ledger_id
      FROM
	     GL_JE_HEADERS JH, GL_LEDGERS LGR
      WHERE
	     JH.je_batch_id = X_je_batch_id
      AND    (JH.display_alc_journal_flag is null
              or JH.display_alc_journal_flag = 'Y')
      AND    LGR.ledger_id = JH.ledger_id
      AND    LGR.ledger_category_code IN ('PRIMARY', 'SECONDARY')
      AND    LGR.enable_budgetary_control_flag = 'Y';
    lgr_id NUMBER;
  BEGIN
    OPEN get_ledger_id;
    FETCH get_ledger_id INTO lgr_id;

    IF ( get_ledger_id%FOUND ) THEN
      -- Found one ledger, so lets check for two
      FETCH get_ledger_id INTO lgr_id;

      IF (get_ledger_id%FOUND) THEN
        -- Two ledgers with budgetary control on.  Return -2 to indicate
        -- an error
        CLOSE get_ledger_id;
        RETURN (-2);
      ELSE
        -- Only one ledger.  Good case.
        CLOSE get_ledger_id;
        RETURN(lgr_id);
      END IF;
    ELSE
      -- No valid ledgers.  Return -1 to indicate an error
      CLOSE get_ledger_id;
      return(-1);
    END IF;
  END bc_ledger;

  PROCEDURE populate_fields(x_je_batch_id				NUMBER,
			   x_je_source_name		IN OUT NOCOPY	VARCHAR2,
			   frozen_source_flag		IN OUT NOCOPY	VARCHAR2,
			   one_of_ledgers_in_batch	IN OUT NOCOPY	NUMBER,
			   reversal_flag		IN OUT NOCOPY   VARCHAR2) IS
 BEGIN
   SELECT max(ledger_id), nvl(max(je_source), 'Manual'),
          nvl(max(decode(reversed_je_header_id, NULL, NULL, 'Y')),'N')
   INTO one_of_ledgers_in_batch, x_je_source_name, reversal_flag
   FROM gl_je_headers
   WHERE je_batch_id = x_je_batch_id
   AND rownum = 1;

   SELECT override_edits_flag
   INTO frozen_source_flag
   FROM gl_je_sources
   WHERE je_source_name = x_je_source_name;
 END;


PROCEDURE Insert_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                     X_Je_Batch_Id                  IN OUT NOCOPY NUMBER,
                     X_Name                                VARCHAR2,
                     X_Chart_of_Accounts_ID		   NUMBER,
		     X_Period_Set_Name		           VARCHAR2,
		     X_Accounted_Period_Type		   VARCHAR2,
                     X_Status                              VARCHAR2,
                     X_Budgetary_Control_Status            VARCHAR2,
                     X_Approval_Status_Code                VARCHAR2,
                     X_Status_Verified                     VARCHAR2,
                     X_Actual_Flag                         VARCHAR2,
                     X_Default_Period_Name                 VARCHAR2,
                     X_Default_Effective_Date              DATE,
                     X_Posted_Date                         DATE,
                     X_Date_Created                        DATE,
		     X_Control_Total                       IN OUT NOCOPY NUMBER,
                     X_Running_Total_Dr                    IN OUT NOCOPY NUMBER,
                     X_Running_Total_Cr                    IN OUT NOCOPY NUMBER,
                     X_Running_Total_Accounted_Dr          NUMBER,
                     X_Running_Total_Accounted_Cr          NUMBER,
                     X_Average_Journal_Flag                VARCHAR2,
                     X_Org_Id				   NUMBER,
                     X_Posting_Run_Id                      NUMBER,
		     X_Request_Id			   NUMBER,
                     X_Packet_Id                           NUMBER,
                     X_Unreservation_Packet_Id             NUMBER,
                     X_Creation_Date                       DATE,
                     X_Created_By                          NUMBER,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Last_Update_Login                   NUMBER
 ) IS

   CURSOR C IS SELECT rowid FROM GL_JE_BATCHES
               WHERE je_batch_id = X_Je_Batch_Id;

   has_je VARCHAR2(1);
BEGIN

  -- Make sure all batches have at least one journal.
  has_je := 'N';
  IF (X_Je_Batch_Id IS NOT NULL) THEN
  BEGIN
    SELECT 'Y'
    INTO has_je
    FROM gl_je_headers
    WHERE je_batch_id = X_Je_Batch_Id
    AND rownum = 1;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      has_je := 'N';
  END;
  END IF;

  IF (has_je = 'N') THEN
    fnd_message.set_name('SQLGL', 'GL_JE_BATCH_W_NO_JOURNALS');
    app_exception.raise_exception;
  END IF;

  INSERT INTO GL_JE_BATCHES(
          je_batch_id,
          name,
          chart_of_accounts_id,
          period_set_name,
          accounted_period_type,
          status,
          budgetary_control_status,
          approval_status_code,
          status_verified,
          actual_flag,
          default_period_name,
          default_effective_date,
          posted_date,
          date_created,
          posting_run_id,
	  request_id,
          packet_id,
          unreservation_packet_id,
          running_total_dr,
          running_total_cr,
          running_total_accounted_dr,
          running_total_accounted_cr,
          average_journal_flag,
          org_id,
          creation_date,
          created_by,
          last_update_date,
          last_updated_by,
          last_update_login
         ) VALUES (
          X_Je_Batch_Id,
          X_Name,
          X_chart_of_accounts_id,
          X_period_set_name,
          X_accounted_period_type,
          X_Status,
          X_Budgetary_Control_Status,
	  X_Approval_Status_Code,
          X_Status_Verified,
          X_Actual_Flag,
          X_Default_Period_Name,
          X_Default_Effective_Date,
          X_Posted_Date,
          X_Date_Created,
          X_Posting_Run_Id,
	  X_Request_Id,
          X_Packet_Id,
          X_Unreservation_Packet_Id,
          X_Running_Total_Dr,
          X_Running_Total_Cr,
          X_Running_Total_Accounted_Dr,
          X_Running_Total_Accounted_Cr,
          X_Average_Journal_Flag,
	  X_Org_Id,
          X_Creation_Date,
          X_Created_By,
          X_Last_Update_Date,
          X_Last_Updated_By,
          X_Last_Update_Login
  );

  OPEN C;
  FETCH C INTO X_Rowid;
  if (C%NOTFOUND) then
    CLOSE C;
    RAISE NO_DATA_FOUND;
  end if;
  CLOSE C;
END Insert_Row;


PROCEDURE Lock_Row(X_Rowid                                 VARCHAR2,
                   X_Je_Batch_Id                           NUMBER,
                   X_Name                                  VARCHAR2,
                   X_Chart_of_Accounts_ID		   NUMBER,
		   X_Period_Set_Name			   VARCHAR2,
		   X_Accounted_Period_Type		   VARCHAR2,
                   X_Status                                VARCHAR2,
		   X_Budgetary_Control_Status		   VARCHAR2,
                   X_Approval_Status_Code                  VARCHAR2,
                   X_Status_Verified                       VARCHAR2,
                   X_Actual_Flag                           VARCHAR2,
                   X_Default_Period_Name                   VARCHAR2,
                   X_Default_Effective_Date                DATE,
                   X_Posted_Date                           DATE,
                   X_Date_Created                          DATE,
		   X_Control_Total                         NUMBER,
                   X_Running_Total_Dr                      NUMBER,
                   X_Running_Total_Cr                      NUMBER,
                   X_Average_Journal_Flag                  VARCHAR2,
                   X_Posting_Run_Id                        NUMBER,
		   X_Request_Id			  	   NUMBER,
                   X_Packet_Id                             NUMBER,
                   X_Unreservation_Packet_Id               NUMBER,
		   X_Verify_Request_Completed		   VARCHAR2
) IS
  CURSOR C IS
      SELECT *
      FROM   GL_JE_BATCHES
      WHERE  rowid = X_Rowid
      FOR UPDATE of Je_Batch_Id NOWAIT;
  Recinfo 	    C%ROWTYPE;
  dev_request_phase VARCHAR2(30);
BEGIN
  OPEN C;
  FETCH C INTO Recinfo;
  if (C%NOTFOUND) then
    CLOSE C;
    FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
  CLOSE C;

  if (
          (   (Recinfo.je_batch_id = X_Je_Batch_Id)
           OR (    (Recinfo.je_batch_id IS NULL)
               AND (X_Je_Batch_Id IS NULL)))
      AND (   (Recinfo.name = X_Name)
           OR (    (Recinfo.name IS NULL)
               AND (X_Name IS NULL)))
      AND (Recinfo.chart_of_accounts_id = X_Chart_of_Accounts_id)
      AND (Recinfo.period_set_name = X_Period_Set_Name)
      AND (Recinfo.accounted_period_type = X_Accounted_Period_Type)
      AND (   (Recinfo.status = X_Status)
           OR (    (Recinfo.status IS NULL)
               AND (X_Status IS NULL)))
      AND (   (Recinfo.budgetary_control_status = X_Budgetary_Control_Status)
           OR (    (Recinfo.budgetary_control_status IS NULL)
               AND (X_Budgetary_Control_Status IS NULL)))
      AND (   (Recinfo.approval_status_code = X_Approval_Status_Code)
           OR (    (Recinfo.approval_status_code IS NULL)
               AND (X_Approval_Status_Code IS NULL)))
      AND (   (Recinfo.status_verified = X_Status_Verified)
           OR (    (Recinfo.status_verified IS NULL)
               AND (X_Status_Verified IS NULL)))
      AND (   (Recinfo.actual_flag = X_Actual_Flag)
           OR (    (Recinfo.actual_flag IS NULL)
               AND (X_Actual_Flag IS NULL)))
      AND (   (Recinfo.default_period_name = X_Default_Period_Name)
           OR (    (Recinfo.default_period_name IS NULL)
               AND (X_Default_Period_Name IS NULL)))
      AND (   (Recinfo.default_effective_date = X_Default_Effective_Date)
           OR (    (Recinfo.default_effective_date IS NULL)
               AND (X_Default_Effective_Date IS NULL)))
      AND (   (trunc(Recinfo.posted_date) = trunc(X_Posted_Date))
           OR (    (Recinfo.posted_date IS NULL)
               AND (X_Posted_Date IS NULL)))
      AND (   (trunc(Recinfo.date_created) = trunc(X_Date_Created))
           OR (    (Recinfo.date_created IS NULL)
               AND (X_Date_Created IS NULL)))
      AND (   (Recinfo.control_total = X_Control_Total)
           OR (    (Recinfo.control_total IS NULL)
               AND (X_Control_Total IS NULL)))
      AND (   (Recinfo.running_total_dr = X_Running_Total_Dr)
           OR (    (Recinfo.running_total_dr IS NULL)
               AND (X_Running_Total_Dr IS NULL)))
      AND (   (Recinfo.running_total_cr = X_Running_Total_Cr)
           OR (    (Recinfo.running_total_cr IS NULL)
               AND (X_Running_Total_Cr IS NULL)))
      AND (   (Recinfo.average_journal_flag = X_Average_Journal_Flag)
           OR (    (Recinfo.average_journal_flag IS NULL)
               AND (X_Average_Journal_Flag IS NULL)))
      AND (   (Recinfo.posting_run_id = X_Posting_Run_Id)
           OR (    (Recinfo.posting_run_id IS NULL)
               AND (X_Posting_Run_Id IS NULL)))
      AND (   (Recinfo.request_id = X_Request_Id)
           OR (    (Recinfo.request_id IS NULL)
               AND (X_Request_Id IS NULL)))
      AND (   (Recinfo.packet_id = X_Packet_Id)
           OR (    (Recinfo.packet_id IS NULL)
               AND (X_Packet_Id IS NULL)))
      AND (   (Recinfo.unreservation_packet_id = X_Unreservation_Packet_Id)
           OR (    (Recinfo.unreservation_packet_id IS NULL)
               AND (X_Unreservation_Packet_Id IS NULL)))
          ) then

    -- If the batch status indicates that it is being processed,
    -- check to verify that it is actually still being processed.
    IF (X_Status IN ('I', 'S')) THEN
      -- If the user has already attempted to post this batch,
      -- then get information about the results
      IF (X_Request_Id IS NOT NULL) THEN
        DECLARE
          call_status		BOOLEAN;
          request_phase		VARCHAR2(30);
          request_status	VARCHAR2(30);
          dev_request_status	VARCHAR2(30);
          request_status_mesg	VARCHAR2(255);
          request_id		NUMBER;
        BEGIN
          request_id := X_Request_Id;
          call_status :=
  	    fnd_concurrent.get_request_status(
	      request_id,
	      'SQLGL',
	      'GLPPOS',
	      request_phase,
	      request_status,
	      dev_request_phase,
	      dev_request_status,
	      request_status_mesg );
        END;
      END IF;
      IF (nvl(dev_request_phase, 'COMPLETE') <> 'COMPLETE') THEN
	FND_MESSAGE.set_name('SQLGL', 'GL_MJE_BATCH_BEING_PROCESSED');
        app_exception.raise_exception;
      END IF;
    END IF;
  else
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
END Lock_Row;

PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Je_Batch_Id                         NUMBER,
                     X_Name                                VARCHAR2,
                     X_Chart_of_Accounts_ID		   NUMBER,
		     X_Period_Set_Name		           VARCHAR2,
		     X_Accounted_Period_Type		   VARCHAR2,
                     X_Status                              VARCHAR2,
                     X_Budgetary_Control_Status            VARCHAR2,
                     X_Approval_Status_Code                IN OUT NOCOPY VARCHAR2,
                     X_Status_Verified                     VARCHAR2,
                     X_Actual_Flag                         VARCHAR2,
                     X_Default_Period_Name                 VARCHAR2,
                     X_Default_Effective_Date              DATE,
                     X_Posted_Date                         DATE,
                     X_Date_Created                        DATE,
		     X_Control_Total            	   IN OUT NOCOPY NUMBER,
		     X_Running_Total_Dr	  		   IN OUT NOCOPY NUMBER,
		     X_Running_Total_Cr	  		   IN OUT NOCOPY NUMBER,
                     X_Average_Journal_Flag                VARCHAR2,
                     X_Posting_Run_Id                      NUMBER,
		     X_Request_Id			   NUMBER,
                     X_Packet_Id                           NUMBER,
                     X_Unreservation_Packet_Id             NUMBER,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Last_Update_Login                   NUMBER,
                     Update_Effective_Date_Flag		   VARCHAR2,
		     Update_Approval_Stat_Flag             VARCHAR2
) IS
  X_Running_Total_Accounted_Dr 	NUMBER;
  X_Running_Total_Accounted_Cr 	NUMBER;
  has_je                        VARCHAR2(1);
BEGIN

  -- Make sure all batches have at least one journal.
  has_je := 'N';
  IF (X_Je_Batch_Id IS NOT NULL) THEN
  BEGIN
    SELECT 'Y'
    INTO has_je
    FROM gl_je_headers
    WHERE je_batch_id = X_Je_Batch_Id
    AND rownum = 1;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      has_je := 'N';
  END;
  END IF;

  IF (has_je = 'N') THEN
    fnd_message.set_name('SQLGL', 'GL_JE_BATCH_W_NO_JOURNALS');
    app_exception.raise_exception;
  END IF;

  -- If the user changes the average journal flag to 'Y', then
  -- we need to reinitialize all of the journals effective dates.
  IF (Update_Effective_Date_Flag = 'Y') THEN
    GL_JE_HEADERS_PKG.change_effective_date(X_Je_Batch_Id,
					    X_Default_Effective_Date);
  END IF;

  -- If the user starts the approval process, then we need to
  -- refetch the approval status
  IF (Update_Approval_Stat_Flag = 'Y') THEN
    SELECT approval_status_code
    INTO   X_Approval_Status_Code
    FROM gl_je_batches
    WHERE rowid = X_RowId;

  -- If a journal has been deleted, we may need to reset the
  -- approval required flag.  Check.
  ELSIF (Update_Approval_Stat_Flag = 'D') THEN
    -- If a journal was deleted, the batch shouldn't have been
    -- posted or approved, but check anyway.
    IF (    (X_status <> 'P')
        AND (X_Approval_Status_Code <> 'A')
       ) THEN
      IF (gl_je_batches_pkg.needs_approval(X_Je_Batch_Id)) THEN
        IF (X_Approval_Status_Code = 'Z') THEN
          X_Approval_Status_Code := 'R';
        END IF;
      ELSE
        X_Approval_Status_Code := 'Z';
      END IF;
    END IF;
  END IF;

  -- Recalculate the running totals
  gl_je_headers_pkg.calculate_totals(
    X_Je_Batch_Id,
    X_Running_Total_Dr,
    X_Running_Total_Cr,
    X_Running_Total_Accounted_Dr,
    X_Running_Total_Accounted_Cr);


  -- To prevent conflicts where the same user is updating multiple headers
  -- from the same batch, only update the status verified if you are
  -- updating it to 'N'.
  UPDATE GL_JE_BATCHES
  SET
    je_batch_id                               =    X_Je_Batch_Id,
    name                                      =    X_Name,
    chart_of_accounts_id                      =    X_Chart_of_Accounts_id,
    period_set_name                           =    X_Period_Set_Name,
    accounted_period_type                     =    X_Accounted_Period_Type,
    status                                    =    X_Status,
    budgetary_control_status                  =    X_Budgetary_Control_Status,
    approval_status_code                      =    X_Approval_Status_Code,
    status_verified                           =    decode(X_Status_Verified,
							  'Y', status_verified,
							  X_Status_Verified),
    actual_flag                               =    X_Actual_Flag,
    default_period_name                       =    X_Default_Period_Name,
    default_effective_date                    =    X_Default_Effective_Date,
    date_created                              =    X_Date_Created,
    posting_run_id                            =    X_Posting_Run_Id,
    request_id				      =    X_Request_Id,
    packet_id                                 =    X_Packet_Id,
    unreservation_packet_id                   =    X_Unreservation_Packet_Id,
    control_total			      =    X_Control_Total,
    running_total_dr			      =    X_Running_Total_Dr,
    running_total_cr			      =    X_Running_Total_Cr,
    running_total_accounted_dr		      =    X_Running_Total_Accounted_Dr,
    running_total_accounted_cr		      =    X_Running_Total_Accounted_Cr,
    average_journal_flag                      =    X_Average_Journal_Flag,
    last_update_date                          =    X_Last_Update_Date,
    last_updated_by                           =    X_Last_Updated_By,
    last_update_login                         =    X_Last_Update_Login
  WHERE rowid = X_rowid;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;

END Update_Row;

PROCEDURE Insert_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                     X_Je_Batch_Id                  IN OUT NOCOPY NUMBER,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Name                                VARCHAR2,
                     X_Chart_of_Accounts_ID		   NUMBER,
		     X_Period_Set_Name		           VARCHAR2,
		     X_Accounted_Period_Type		   VARCHAR2,
                     X_Status                              VARCHAR2,
                     X_Status_Verified                     VARCHAR2,
                     X_Actual_Flag                         VARCHAR2,
                     X_Default_Effective_Date              DATE,
                     X_Creation_Date                       DATE,
                     X_Created_By                          NUMBER,
                     X_Last_Update_Login                   NUMBER,
                     X_Status_Reset_Flag                   VARCHAR2,
                     X_Default_Period_Name                 VARCHAR2,
                     X_Unique_Date                         VARCHAR2,
                     X_Earliest_Postable_Date              DATE,
                     X_Posted_Date                         DATE,
                     X_Date_Created                        DATE,
                     X_Description                         VARCHAR2,
                     X_Control_Total                       NUMBER,
                     X_Running_Total_Dr                    NUMBER,
                     X_Running_Total_Cr                    NUMBER,
                     X_Running_Total_Accounted_Dr          NUMBER,
                     X_Running_Total_Accounted_Cr          NUMBER,
                     X_Average_Journal_Flag                VARCHAR2,
                     X_Org_Id				   NUMBER,
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
                     X_Context                             VARCHAR2,
                     X_Budgetary_Control_Status            VARCHAR2,
                     X_Approval_Status_Code                VARCHAR2,
                     X_Posting_Run_Id                      NUMBER,
		     X_Request_Id			   NUMBER,
                     X_Packet_Id                           NUMBER,
                     X_Ussgl_Transaction_Code              VARCHAR2,
                     X_Context2                            VARCHAR2,
                     X_Unreservation_Packet_Id             NUMBER,
                     X_Global_Attribute_Category           VARCHAR2,
                     X_Global_Attribute1                   VARCHAR2,
                     X_Global_Attribute2                   VARCHAR2,
                     X_Global_Attribute3                   VARCHAR2,
                     X_Global_Attribute4                   VARCHAR2,
                     X_Global_Attribute5                   VARCHAR2,
                     X_Global_Attribute6                   VARCHAR2,
                     X_Global_Attribute7                   VARCHAR2,
                     X_Global_Attribute8                   VARCHAR2,
                     X_Global_Attribute9                   VARCHAR2,
                     X_Global_Attribute10                  VARCHAR2,
                     X_Global_Attribute11                  VARCHAR2,
                     X_Global_Attribute12                  VARCHAR2,
                     X_Global_Attribute13                  VARCHAR2,
                     X_Global_Attribute14                  VARCHAR2,
                     X_Global_Attribute15                  VARCHAR2,
                     X_Global_Attribute16                  VARCHAR2,
                     X_Global_Attribute17                  VARCHAR2,
                     X_Global_Attribute18                  VARCHAR2,
                     X_Global_Attribute19                  VARCHAR2,
                     X_Global_Attribute20                  VARCHAR2
 ) IS
   CURSOR C IS SELECT rowid FROM GL_JE_BATCHES

             WHERE je_batch_id = X_Je_Batch_Id;
   has_je VARCHAR2(1);
BEGIN

  -- Make sure all batches have at least one journal.
  has_je := 'N';
  IF (X_Je_Batch_Id IS NOT NULL) THEN
  BEGIN

    SELECT 'Y'
    INTO has_je
    FROM gl_je_headers
    WHERE je_batch_id = X_Je_Batch_Id
    AND rownum = 1;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      has_je := 'N';
  END;
  END IF;

  IF (has_je = 'N') THEN
    fnd_message.set_name('SQLGL', 'GL_JE_BATCH_W_NO_JOURNALS');
    app_exception.raise_exception;
  END IF;

  INSERT INTO GL_JE_BATCHES(
          je_batch_id,
          last_update_date,
          last_updated_by,
          name,
          chart_of_accounts_id,
          period_set_name,
          accounted_period_type,
          status,
          status_verified,
          actual_flag,
          default_effective_date,
          creation_date,
          created_by,
          last_update_login,
          status_reset_flag,
          default_period_name,
          unique_date,
          earliest_postable_date,
          posted_date,
          date_created,
          description,
          control_total,
          running_total_dr,
          running_total_cr,
          running_total_accounted_dr,
          running_total_accounted_cr,
          average_journal_flag,
	  org_id,
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
          context,
          budgetary_control_status,
          approval_status_code,
          posting_run_id,
	  request_id,
          packet_id,
          ussgl_transaction_code,
          context2,
          unreservation_packet_id,
	  Global_Attribute_Category,
	  Global_Attribute1,
	  Global_Attribute2,
	  Global_Attribute3,
	  Global_Attribute4,
	  Global_Attribute5,
	  Global_Attribute6,
	  Global_Attribute7,
	  Global_Attribute8,
	  Global_Attribute9,
	  Global_Attribute10,
	  Global_Attribute11,
	  Global_Attribute12,
	  Global_Attribute13,
	  Global_Attribute14,
	  Global_Attribute15,
	  Global_Attribute16,
	  Global_Attribute17,
	  Global_Attribute18,
	  Global_Attribute19,
	  Global_Attribute20
         ) VALUES (
          X_Je_Batch_Id,
          X_Last_Update_Date,
          X_Last_Updated_By,
          X_Name,
          X_chart_of_accounts_id,
          X_period_set_name,
          X_accounted_period_type,
          X_Status,
          X_Status_Verified,
          X_Actual_Flag,
          X_Default_Effective_Date,
          X_Creation_Date,
          X_Created_By,
          X_Last_Update_Login,
          X_Status_Reset_Flag,
          X_Default_Period_Name,
          X_Unique_Date,
          X_Earliest_Postable_Date,
          X_Posted_Date,
          X_Date_Created,
          X_Description,
          X_Control_Total,
          X_Running_Total_Dr,
          X_Running_Total_Cr,
          X_Running_Total_Accounted_Dr,
          X_Running_Total_Accounted_Cr,
          X_Average_Journal_Flag,
	  X_Org_Id,
          X_Attribute1,
          X_Attribute2,
          X_Attribute3,
          X_Attribute4,
          X_Attribute5,
          X_Attribute6,
          X_Attribute7,
          X_Attribute8,
          X_Attribute9,
          X_Attribute10,
          X_Context,
          X_Budgetary_Control_Status,
          X_Approval_Status_Code,
          X_Posting_Run_Id,
	  X_Request_Id,
          X_Packet_Id,
          X_Ussgl_Transaction_Code,
          X_Context2,
          X_Unreservation_Packet_Id,
	  X_Global_Attribute_Category,
	  X_Global_Attribute1,
	  X_Global_Attribute2,
	  X_Global_Attribute3,
	  X_Global_Attribute4,
	  X_Global_Attribute5,
	  X_Global_Attribute6,
	  X_Global_Attribute7,
	  X_Global_Attribute8,
	  X_Global_Attribute9,
	  X_Global_Attribute10,
	  X_Global_Attribute11,
	  X_Global_Attribute12,
	  X_Global_Attribute13,
	  X_Global_Attribute14,
	  X_Global_Attribute15,
	  X_Global_Attribute16,
	  X_Global_Attribute17,
	  X_Global_Attribute18,
	  X_Global_Attribute19,
	  X_Global_Attribute20
  );

  OPEN C;
  FETCH C INTO X_Rowid;
  if (C%NOTFOUND) then
    CLOSE C;
    RAISE NO_DATA_FOUND;
  end if;
  CLOSE C;
END Insert_Row;


PROCEDURE Lock_Row(X_Rowid                                 VARCHAR2,

                   X_Je_Batch_Id                           NUMBER,
                   X_Name                                  VARCHAR2,
                   X_Chart_of_Accounts_ID		   NUMBER,
		   X_Period_Set_Name		           VARCHAR2,
		   X_Accounted_Period_Type		   VARCHAR2,
                   X_Status                                VARCHAR2,
                   X_Status_Verified                       VARCHAR2,
                   X_Actual_Flag                           VARCHAR2,
                   X_Default_Effective_Date                DATE,
                   X_Status_Reset_Flag                     VARCHAR2,
                   X_Default_Period_Name                   VARCHAR2,
                   X_Unique_Date                           VARCHAR2,
                   X_Earliest_Postable_Date                DATE,
                   X_Posted_Date                           DATE,
                   X_Date_Created                          DATE,
                   X_Description                           VARCHAR2,
                   X_Control_Total                         NUMBER,
                   X_Running_Total_Dr                      NUMBER,
                   X_Running_Total_Cr                      NUMBER,
                   X_Running_Total_Accounted_Dr            NUMBER,
                   X_Running_Total_Accounted_Cr            NUMBER,
                   X_Average_Journal_Flag                  VARCHAR2,
                   X_Attribute1                            VARCHAR2,
                   X_Attribute2                            VARCHAR2,
                   X_Attribute3                            VARCHAR2,
                   X_Attribute4                            VARCHAR2,
                   X_Attribute5                            VARCHAR2,
                   X_Attribute6                            VARCHAR2,
                   X_Attribute7                            VARCHAR2,
                   X_Attribute8                            VARCHAR2,
                   X_Attribute9                            VARCHAR2,
                   X_Attribute10                           VARCHAR2,
                   X_Context                               VARCHAR2,
                   X_Budgetary_Control_Status              VARCHAR2,
                   X_Approval_Status_Code                  VARCHAR2,
                   X_Posting_Run_Id                        NUMBER,
		   X_Request_Id			  	   NUMBER,
                   X_Packet_Id                             NUMBER,
                   X_Ussgl_Transaction_Code                VARCHAR2,
                   X_Context2                              VARCHAR2,
                   X_Unreservation_Packet_Id               NUMBER,
		   X_Verify_Request_Completed		   VARCHAR2,
                   X_Global_Attribute_Category             VARCHAR2,
                   X_Global_Attribute1                     VARCHAR2,
                   X_Global_Attribute2                     VARCHAR2,
                   X_Global_Attribute3                     VARCHAR2,
                   X_Global_Attribute4                     VARCHAR2,
                   X_Global_Attribute5                     VARCHAR2,
                   X_Global_Attribute6                     VARCHAR2,
                   X_Global_Attribute7                     VARCHAR2,
                   X_Global_Attribute8                     VARCHAR2,
                   X_Global_Attribute9                     VARCHAR2,
                   X_Global_Attribute10                    VARCHAR2,
                   X_Global_Attribute11                    VARCHAR2,
                   X_Global_Attribute12                    VARCHAR2,
                   X_Global_Attribute13                    VARCHAR2,
                   X_Global_Attribute14                    VARCHAR2,
                   X_Global_Attribute15                    VARCHAR2,
                   X_Global_Attribute16                    VARCHAR2,
                   X_Global_Attribute17                    VARCHAR2,
                   X_Global_Attribute18                    VARCHAR2,
                   X_Global_Attribute19                    VARCHAR2,
                   X_Global_Attribute20                    VARCHAR2
) IS
  CURSOR C IS
      SELECT *
      FROM   GL_JE_BATCHES
      WHERE  rowid = X_Rowid
      FOR UPDATE of Je_Batch_Id NOWAIT;
  Recinfo           C%ROWTYPE;
  dev_request_phase VARCHAR2(30);
BEGIN
  OPEN C;
  FETCH C INTO Recinfo;
  if (C%NOTFOUND) then
    CLOSE C;
    FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
  CLOSE C;


  if (
          (   (Recinfo.je_batch_id = X_Je_Batch_Id)
           OR (    (Recinfo.je_batch_id IS NULL)
               AND (X_Je_Batch_Id IS NULL)))
      AND (   (Recinfo.name = X_Name)
           OR (    (Recinfo.name IS NULL)
               AND (X_Name IS NULL)))
      AND (Recinfo.chart_of_accounts_id = X_Chart_of_Accounts_id)
      AND (Recinfo.period_set_name = X_Period_Set_Name)
      AND (Recinfo.accounted_period_type = X_Accounted_Period_Type)
      AND (   (Recinfo.status = X_Status)
           OR (    (Recinfo.status IS NULL)
               AND (X_Status IS NULL)))
      AND (   (Recinfo.status_verified = X_Status_Verified)
           OR (    (Recinfo.status_verified IS NULL)
               AND (X_Status_Verified IS NULL)))
      AND (   (Recinfo.actual_flag = X_Actual_Flag)
           OR (    (Recinfo.actual_flag IS NULL)
               AND (X_Actual_Flag IS NULL)))
      AND (   (Recinfo.default_effective_date = X_Default_Effective_Date)
           OR (    (Recinfo.default_effective_date IS NULL)
               AND (X_Default_Effective_Date IS NULL)))
      AND (   (Recinfo.status_reset_flag = X_Status_Reset_Flag)
           OR (    (Recinfo.status_reset_flag IS NULL)
               AND (X_Status_Reset_Flag IS NULL)))
      AND (   (Recinfo.default_period_name = X_Default_Period_Name)
           OR (    (Recinfo.default_period_name IS NULL)
               AND (X_Default_Period_Name IS NULL)))
      AND (   (Recinfo.unique_date = X_Unique_Date)
           OR (    (Recinfo.unique_date IS NULL)
               AND (X_Unique_Date IS NULL)))
      AND (   (Recinfo.earliest_postable_date = X_Earliest_Postable_Date)
           OR (    (Recinfo.earliest_postable_date IS NULL)
               AND (X_Earliest_Postable_Date IS NULL)))
      AND (   (trunc(Recinfo.posted_date) = trunc(X_Posted_Date))
           OR (    (Recinfo.posted_date IS NULL)
               AND (X_Posted_Date IS NULL)))
      AND (   (trunc(Recinfo.date_created) = trunc(X_Date_Created))
           OR (    (Recinfo.date_created IS NULL)
               AND (X_Date_Created IS NULL)))
      AND (   (Recinfo.description = X_Description)
           OR (    (Recinfo.description IS NULL)
               AND (X_Description IS NULL)))
      AND (   (Recinfo.control_total = X_Control_Total)
           OR (    (Recinfo.control_total IS NULL)
               AND (X_Control_Total IS NULL)))
      AND (   (Recinfo.running_total_dr = X_Running_Total_Dr)
           OR (    (Recinfo.running_total_dr IS NULL)
               AND (X_Running_Total_Dr IS NULL)))
      AND (   (Recinfo.running_total_cr = X_Running_Total_Cr)
           OR (    (Recinfo.running_total_cr IS NULL)
               AND (X_Running_Total_Cr IS NULL)))
      AND (   (Recinfo.running_total_accounted_dr = X_Running_Total_Accounted_Dr)
           OR (    (Recinfo.running_total_accounted_dr IS NULL)
               AND (X_Running_Total_Accounted_Dr IS NULL)))
      AND (   (Recinfo.running_total_accounted_cr = X_Running_Total_Accounted_Cr)
           OR (    (Recinfo.running_total_accounted_cr IS NULL)
               AND (X_Running_Total_Accounted_Cr IS NULL)))
      AND (   (Recinfo.average_journal_flag = X_Average_Journal_Flag)
           OR (    (Recinfo.average_journal_flag IS NULL)
               AND (X_Average_Journal_Flag IS NULL)))
      AND (   (Recinfo.attribute1 = X_Attribute1)
           OR (    (rtrim(Recinfo.attribute1,' ') IS NULL)
               AND (X_Attribute1 IS NULL)))
      AND (   (Recinfo.attribute2 = X_Attribute2)
           OR (    (rtrim(Recinfo.attribute2,' ') IS NULL)
               AND (X_Attribute2 IS NULL)))
      AND (   (Recinfo.attribute3 = X_Attribute3)
           OR (    (rtrim(Recinfo.attribute3,' ') IS NULL)
               AND (X_Attribute3 IS NULL)))
      AND (   (Recinfo.attribute4 = X_Attribute4)
           OR (    (rtrim(Recinfo.attribute4,' ') IS NULL)
               AND (X_Attribute4 IS NULL)))
      AND (   (Recinfo.attribute5 = X_Attribute5)
           OR (    (rtrim(Recinfo.attribute5,' ') IS NULL)
               AND (X_Attribute5 IS NULL)))
      AND (   (Recinfo.attribute6 = X_Attribute6)
           OR (    (rtrim(Recinfo.attribute6,' ') IS NULL)
               AND (X_Attribute6 IS NULL)))
      AND (   (Recinfo.attribute7 = X_Attribute7)
           OR (    (rtrim(Recinfo.attribute7,' ') IS NULL)
               AND (X_Attribute7 IS NULL)))
      AND (   (Recinfo.attribute8 = X_Attribute8)
           OR (    (rtrim(Recinfo.attribute8,' ') IS NULL)
               AND (X_Attribute8 IS NULL)))
      AND (   (Recinfo.attribute9 = X_Attribute9)
           OR (    (rtrim(Recinfo.attribute9,' ') IS NULL)
               AND (X_Attribute9 IS NULL)))
      AND (   (Recinfo.attribute10 = X_Attribute10)
           OR (    (rtrim(Recinfo.attribute10,' ') IS NULL)
               AND (X_Attribute10 IS NULL)))
      AND (   (Recinfo.context = X_Context)
           OR (    (rtrim(Recinfo.context,' ') IS NULL)
               AND (X_Context IS NULL)))
      AND (   (Recinfo.budgetary_control_status = X_Budgetary_Control_Status)
           OR (    (Recinfo.budgetary_control_status IS NULL)
               AND (X_Budgetary_Control_Status IS NULL)))
      AND (   (Recinfo.approval_status_code = X_Approval_Status_Code)
           OR (    (Recinfo.approval_status_code IS NULL)
               AND (X_Approval_Status_Code IS NULL)))
      AND (   (Recinfo.posting_run_id = X_Posting_Run_Id)
           OR (    (Recinfo.posting_run_id IS NULL)
               AND (X_Posting_Run_Id IS NULL)))
      AND (   (Recinfo.request_id = X_Request_Id)
           OR (    (Recinfo.request_id IS NULL)
               AND (X_Request_Id IS NULL)))
      AND (   (Recinfo.packet_id = X_Packet_Id)
           OR (    (Recinfo.packet_id IS NULL)
               AND (X_Packet_Id IS NULL)))
      AND (   (Recinfo.ussgl_transaction_code = X_Ussgl_Transaction_Code)
           OR (    (Recinfo.ussgl_transaction_code IS NULL)
               AND (X_Ussgl_Transaction_Code IS NULL)))
      AND (   (Recinfo.context2 = X_Context2)
           OR (    (Recinfo.context2 IS NULL)
               AND (X_Context2 IS NULL)))
      AND (   (Recinfo.unreservation_packet_id = X_Unreservation_Packet_Id)
           OR (    (Recinfo.unreservation_packet_id IS NULL)
               AND (X_Unreservation_Packet_Id IS NULL)))
      AND (   (Recinfo.global_attribute_category = X_Global_Attribute_Category)
           OR (    (Recinfo.global_attribute_category IS NULL)
               AND (X_Global_Attribute_Category IS NULL)))
      AND (   (Recinfo.global_attribute1 = X_Global_Attribute1)
           OR (    (Recinfo.global_attribute1 IS NULL)
               AND (X_Global_Attribute1 IS NULL)))
      AND (   (Recinfo.global_attribute2 = X_Global_Attribute2)
           OR (    (Recinfo.global_attribute2 IS NULL)
               AND (X_Global_Attribute2 IS NULL)))
      AND (   (Recinfo.global_attribute3 = X_Global_Attribute3)
           OR (    (Recinfo.global_attribute3 IS NULL)
               AND (X_Global_Attribute3 IS NULL)))
      AND (   (Recinfo.global_attribute4 = X_Global_Attribute4)
           OR (    (Recinfo.global_attribute4 IS NULL)
               AND (X_Global_Attribute4 IS NULL)))
      AND (   (Recinfo.global_attribute5 = X_Global_Attribute5)
           OR (    (Recinfo.global_attribute5 IS NULL)
               AND (X_Global_Attribute5 IS NULL)))
      AND (   (Recinfo.global_attribute6 = X_Global_Attribute6)
           OR (    (Recinfo.global_attribute6 IS NULL)
               AND (X_Global_Attribute6 IS NULL)))
      AND (   (Recinfo.global_attribute7 = X_Global_Attribute7)
           OR (    (Recinfo.global_attribute7 IS NULL)
               AND (X_Global_Attribute7 IS NULL)))
      AND (   (Recinfo.global_attribute8 = X_Global_Attribute8)
           OR (    (Recinfo.global_attribute8 IS NULL)
               AND (X_Global_Attribute8 IS NULL)))
      AND (   (Recinfo.global_attribute9 = X_Global_Attribute9)
           OR (    (Recinfo.global_attribute9 IS NULL)
               AND (X_Global_Attribute9 IS NULL)))
      AND (   (Recinfo.global_attribute10 = X_Global_Attribute10)
           OR (    (Recinfo.global_attribute10 IS NULL)
               AND (X_Global_Attribute10 IS NULL)))
      AND (   (Recinfo.global_attribute11 = X_Global_Attribute11)
           OR (    (Recinfo.global_attribute11 IS NULL)
               AND (X_Global_Attribute11 IS NULL)))
      AND (   (Recinfo.global_attribute12 = X_Global_Attribute12)
           OR (    (Recinfo.global_attribute12 IS NULL)
               AND (X_Global_Attribute12 IS NULL)))
      AND (   (Recinfo.global_attribute13 = X_Global_Attribute13)
           OR (    (Recinfo.global_attribute13 IS NULL)
               AND (X_Global_Attribute13 IS NULL)))
      AND (   (Recinfo.global_attribute14 = X_Global_Attribute14)
           OR (    (Recinfo.global_attribute14 IS NULL)
               AND (X_Global_Attribute14 IS NULL)))
      AND (   (Recinfo.global_attribute15 = X_Global_Attribute15)
           OR (    (Recinfo.global_attribute15 IS NULL)
               AND (X_Global_Attribute15 IS NULL)))
      AND (   (Recinfo.global_attribute16 = X_Global_Attribute16)
           OR (    (Recinfo.global_attribute16 IS NULL)
               AND (X_Global_Attribute16 IS NULL)))
      AND (   (Recinfo.global_attribute17 = X_Global_Attribute17)
           OR (    (Recinfo.global_attribute17 IS NULL)
               AND (X_Global_Attribute17 IS NULL)))
      AND (   (Recinfo.global_attribute18 = X_Global_Attribute18)
           OR (    (Recinfo.global_attribute18 IS NULL)
               AND (X_Global_Attribute18 IS NULL)))
      AND (   (Recinfo.global_attribute19 = X_Global_Attribute19)
           OR (    (Recinfo.global_attribute19 IS NULL)
               AND (X_Global_Attribute19 IS NULL)))
      AND (   (Recinfo.global_attribute20 = X_Global_Attribute20)
           OR (    (Recinfo.global_attribute20 IS NULL)
               AND (X_Global_Attribute20 IS NULL)))
          ) then
    -- If the batch status indicates that it is being processed,
    -- check to verify that it is actually still being processed.
    IF (X_Status IN ('I', 'S')) THEN
      -- If the user has already attempted to post this batch,
      -- then get information about the results
      IF (X_Request_Id IS NOT NULL) THEN
        DECLARE
          call_status		BOOLEAN;
          request_phase		VARCHAR2(30);
          request_status	VARCHAR2(30);
          dev_request_status	VARCHAR2(30);
          request_status_mesg	VARCHAR2(255);
          request_id		NUMBER;
        BEGIN
          request_id := X_Request_id;
          call_status :=
  	    fnd_concurrent.get_request_status(
	      request_id,
	      'SQLGL',
	      'GLPPOS',
	      request_phase,
	      request_status,
	      dev_request_phase,
	      dev_request_status,
	      request_status_mesg );
        END;
      END IF;
      IF (nvl(dev_request_phase, 'COMPLETE') <> 'COMPLETE') THEN
	FND_MESSAGE.set_name('SQLGL', 'GL_MJE_BATCH_BEING_PROCESSED');
        app_exception.raise_exception;
      END IF;
    END IF;
  else
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
END Lock_Row;

PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Je_Batch_Id                         NUMBER,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Name                                VARCHAR2,
                     X_Chart_of_Accounts_ID		   NUMBER,
		     X_Period_Set_Name		           VARCHAR2,
		     X_Accounted_Period_Type		   VARCHAR2,
                     X_Status                              VARCHAR2,
                     X_Status_Verified                     VARCHAR2,
                     X_Actual_Flag                         VARCHAR2,
                     X_Default_Effective_Date              DATE,
                     X_Last_Update_Login                   NUMBER,
                     X_Status_Reset_Flag                   VARCHAR2,
                     X_Default_Period_Name                 VARCHAR2,
                     X_Unique_Date                         VARCHAR2,
                     X_Earliest_Postable_Date              DATE,
                     X_Posted_Date                         DATE,
                     X_Date_Created                        DATE,
                     X_Description                         VARCHAR2,
                     X_Control_Total                       NUMBER,
                     X_Running_Total_Dr                    NUMBER,
                     X_Running_Total_Cr                    NUMBER,
                     X_Running_Total_Accounted_Dr          NUMBER,
                     X_Running_Total_Accounted_Cr          NUMBER,
                     X_Average_Journal_Flag                VARCHAR2,
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
                     X_Context                             VARCHAR2,
                     X_Budgetary_Control_Status            VARCHAR2,
                     X_Approval_Status_Code                IN OUT NOCOPY VARCHAR2,
                     X_Posting_Run_Id                      NUMBER,
		     X_Request_Id			   NUMBER,
                     X_Packet_Id                           NUMBER,
                     X_Ussgl_Transaction_Code              VARCHAR2,
                     X_Context2                            VARCHAR2,
                     X_Unreservation_Packet_Id             NUMBER,
                     Update_Effective_Date_Flag		   VARCHAR2,
		     Update_Approval_Stat_Flag             VARCHAR2,
                     X_Global_Attribute_Category           VARCHAR2,
                     X_Global_Attribute1                   VARCHAR2,
                     X_Global_Attribute2                   VARCHAR2,
                     X_Global_Attribute3                   VARCHAR2,
                     X_Global_Attribute4                   VARCHAR2,
                     X_Global_Attribute5                   VARCHAR2,
                     X_Global_Attribute6                   VARCHAR2,
                     X_Global_Attribute7                   VARCHAR2,
                     X_Global_Attribute8                   VARCHAR2,
                     X_Global_Attribute9                   VARCHAR2,
                     X_Global_Attribute10                  VARCHAR2,
                     X_Global_Attribute11                  VARCHAR2,
                     X_Global_Attribute12                  VARCHAR2,
                     X_Global_Attribute13                  VARCHAR2,
                     X_Global_Attribute14                  VARCHAR2,
                     X_Global_Attribute15                  VARCHAR2,
                     X_Global_Attribute16                  VARCHAR2,
                     X_Global_Attribute17                  VARCHAR2,
                     X_Global_Attribute18                  VARCHAR2,
                     X_Global_Attribute19                  VARCHAR2,
                     X_Global_Attribute20                  VARCHAR2
) IS
  current_average_journal VARCHAR2(1);
  has_je VARCHAR2(1);
BEGIN

  -- Make sure all batches have at least one journal.
  has_je := 'N';
  IF (X_Je_Batch_Id IS NOT NULL) THEN
  BEGIN

    SELECT 'Y'
    INTO has_je
    FROM gl_je_headers
    WHERE je_batch_id = X_Je_Batch_Id
    AND rownum = 1;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      has_je := 'N';
  END;
  END IF;

  IF (has_je = 'N') THEN
    fnd_message.set_name('SQLGL', 'GL_JE_BATCH_W_NO_JOURNALS');
    app_exception.raise_exception;
  END IF;

  -- If the user changes the average journal flag to 'Y', then
  -- we need to reinitialize all of the journals effective dates.
  IF (Update_Effective_Date_Flag = 'Y') THEN
    GL_JE_HEADERS_PKG.change_effective_date(X_Je_Batch_Id,
					    X_Default_Effective_Date);
  END IF;

  -- If the user starts the approval process, then we need to
  -- refetch the approval status
  IF (Update_Approval_Stat_Flag = 'Y') THEN
    SELECT approval_status_code
    INTO   X_Approval_Status_Code
    FROM gl_je_batches
    WHERE rowid = X_RowId;

  -- If a journal has been deleted, we may need to reset the
  -- approval required flag.  Check.
  ELSIF (Update_Approval_Stat_Flag = 'D') THEN
    -- If a journal was deleted, the batch shouldn't have been
    -- posted or approved, but check anyway.
    IF (    (X_status <> 'P')
        AND (X_Approval_Status_Code <> 'A')
       ) THEN
      IF (gl_je_batches_pkg.needs_approval(X_Je_Batch_Id)) THEN
        IF (X_Approval_Status_Code = 'Z') THEN
          X_Approval_Status_Code := 'R';
        END IF;
      ELSE
        X_Approval_Status_Code := 'Z';
      END IF;
    END IF;
  END IF;

  UPDATE GL_JE_BATCHES
  SET

    je_batch_id                               =    X_Je_Batch_Id,
    last_update_date                          =    X_Last_Update_Date,
    last_updated_by                           =    X_Last_Updated_By,
    name                                      =    X_Name,
    chart_of_accounts_id                      =    X_Chart_of_Accounts_id,
    period_set_name                           =    X_Period_Set_Name,
    accounted_period_type                     =    X_Accounted_Period_Type,
    status                                    =    X_Status,
    status_verified                           =    X_Status_Verified,
    actual_flag                               =    X_Actual_Flag,
    default_effective_date                    =    X_Default_Effective_Date,
    last_update_login                         =    X_Last_Update_Login,
    status_reset_flag                         =    X_Status_Reset_Flag,
    default_period_name                       =    X_Default_Period_Name,
    unique_date                               =    X_Unique_Date,
    earliest_postable_date                    =    X_Earliest_Postable_Date,
    date_created                              =    X_Date_Created,
    description                               =    X_Description,
    control_total                             =    X_Control_Total,
    running_total_dr                          =    X_Running_Total_Dr,
    running_total_cr                          =    X_Running_Total_Cr,
    running_total_accounted_dr                =    X_Running_Total_Accounted_Dr,
    running_total_accounted_cr                =    X_Running_Total_Accounted_Cr,
    average_journal_flag                      =    X_Average_Journal_Flag,
    attribute1                                =    X_Attribute1,
    attribute2                                =    X_Attribute2,
    attribute3                                =    X_Attribute3,
    attribute4                                =    X_Attribute4,
    attribute5                                =    X_Attribute5,
    attribute6                                =    X_Attribute6,
    attribute7                                =    X_Attribute7,
    attribute8                                =    X_Attribute8,
    attribute9                                =    X_Attribute9,
    attribute10                               =    X_Attribute10,
    context                                   =    X_Context,
    budgetary_control_status                  =    X_Budgetary_Control_Status,
    approval_status_code                      =    X_Approval_Status_Code,
    posting_run_id                            =    X_Posting_Run_Id,
    request_id				      =    X_Request_Id,
    packet_id                                 =    X_Packet_Id,
    ussgl_transaction_code                    =    X_Ussgl_Transaction_Code,
    context2                                  =    X_Context2,
    unreservation_packet_id                   =    X_Unreservation_Packet_Id,
    global_attribute_category                 =    X_Global_Attribute_Category,
    global_attribute1                         =    X_Global_Attribute1,
    global_attribute2                         =    X_Global_Attribute2,
    global_attribute3                         =    X_Global_Attribute3,
    global_attribute4                         =    X_Global_Attribute4,
    global_attribute5                         =    X_Global_Attribute5,
    global_attribute6                         =    X_Global_Attribute6,
    global_attribute7                         =    X_Global_Attribute7,
    global_attribute8                         =    X_Global_Attribute8,
    global_attribute9                         =    X_Global_Attribute9,
    global_attribute10                        =    X_Global_Attribute10,
    global_attribute11                        =    X_Global_Attribute11,
    global_attribute12                        =    X_Global_Attribute12,
    global_attribute13                        =    X_Global_Attribute13,
    global_attribute14                        =    X_Global_Attribute14,
    global_attribute15                        =    X_Global_Attribute15,
    global_attribute16                        =    X_Global_Attribute16,
    global_attribute17                        =    X_Global_Attribute17,
    global_attribute18                        =    X_Global_Attribute18,
    global_attribute19                        =    X_Global_Attribute19,
    global_attribute20                        =    X_Global_Attribute20
  WHERE rowid = X_rowid;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;

END Update_Row;

PROCEDURE Delete_Row(X_Rowid VARCHAR2, Je_Batch_Id NUMBER) IS
  bc_status VARCHAR2(1);
  approval_status VARCHAR2(1);
  batch_status VARCHAR2(1);
  request_id NUMBER;
  dev_request_phase VARCHAR2(30);
BEGIN
  SELECT budgetary_control_status,
         approval_status_code,
         status,
         request_id
  INTO bc_status, approval_status,
       batch_status, request_id
  FROM gl_je_batches
  WHERE rowid = X_Rowid;

  -- Check if we are in the process of reserving funds for
  -- this batch
  IF (bc_status = 'I') THEN
    RAISE GL_MJE_RESERVING_FUNDS;
  END IF;

  -- Check if we are in the process of reserving funds for
  -- this batch
  IF (bc_status = 'P') THEN
    RAISE GL_MJE_RESERVED_FUNDS;
  END IF;

  -- Check if we are in the process of approving this batch
  IF (approval_status = 'I') THEN
    RAISE GL_MJE_APPROVING;
  END IF;

  -- Check if we have posted this batch
  IF (batch_status = 'P') THEN
    RAISE GL_MJE_POSTED;
  END IF;

  -- If the batch status indicates that it is being processed,
  -- check to verify that it is actually still being processed.
  IF (batch_status IN ('I', 'S')) THEN
    -- If the user has already attempted to post this batch,
    -- then get information about the results
    IF (request_id IS NOT NULL) THEN
      DECLARE
        call_status		BOOLEAN;
        request_phase		VARCHAR2(30);
        request_status		VARCHAR2(30);
        dev_request_status	VARCHAR2(30);
        request_status_mesg	VARCHAR2(255);
        req_id			NUMBER;
      BEGIN
        req_id := request_id;
        call_status :=
  	    fnd_concurrent.get_request_status(
	      req_id,
	      'SQLGL',
	      'GLPPOS',
	      request_phase,
	      request_status,
	      dev_request_phase,
	      dev_request_status,
	      request_status_mesg );
      END;

      IF (dev_request_phase <> 'COMPLETE') THEN
        RAISE GL_MJE_POSTING;
      END IF;

    END IF;
  END IF;


  -- Delete the journals
  gl_je_headers_pkg.delete_headers(Je_Batch_Id);

  -- Delete the batches
  DELETE FROM GL_JE_BATCHES
  WHERE  rowid = X_Rowid;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    null;
END Delete_Row;

END gl_je_batches_pkg;

/
