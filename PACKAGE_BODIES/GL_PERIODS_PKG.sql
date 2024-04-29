--------------------------------------------------------
--  DDL for Package Body GL_PERIODS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_PERIODS_PKG" AS
/* $Header: gliprdeb.pls 120.8 2006/12/06 06:44:34 spala ship $ */

--
-- PRIVATE FUNCTIONS
--

  PROCEDURE fix_max_len(call_mode	VARCHAR2,
			per_type	VARCHAR2,
			row_id		VARCHAR2,
			old_len		NUMBER,
			new_len		NUMBER) IS
    CURSOR get_max IS
      SELECT nvl(max_regular_period_length,0)
      FROM   ar_period_types
      WHERE  period_type = per_type;
    max_len  NUMBER;
    tmp_len  NUMBER;

    does_exist VARCHAR2(100);
  BEGIN
    -- If this is an update and the size of the period did not
    -- change, then just return
    IF (    (call_mode = 'U')
        AND (old_len = new_len)) THEN
      RETURN;
    END IF;

    OPEN get_max;
    FETCH get_max INTO max_len;

    -- Check if this is the first period ever of this type
    IF get_max%NOTFOUND THEN
      CLOSE get_max;

      max_len := new_len;
      INSERT into ar_period_types
        (period_type, max_regular_period_length)
        VALUES (per_type, max_len);

    -- Not the first period
    ELSE
      CLOSE get_max;

      -- Check if this period is larger than any earlier period
      IF (    (call_mode IN ('I', 'U'))
          AND (max_len < new_len)) THEN

	max_len := new_len;
        UPDATE ar_period_types
	SET max_regular_period_length = max_len
	WHERE period_type = per_type;
      END IF;

      -- Check if this period was the maximum one
      IF (    (call_mode IN ('D', 'U'))
          AND (max_len = old_len)) THEN

	-- Normally there will be many periods with the same
        -- maximum length.  Thus, first we do an exists
        -- check, since in general that will be faster.
	BEGIN
	  SELECT 'still max'
	  INTO does_exist
	  FROM dual
	  WHERE EXISTS
	    (SELECT 'still max'
	     FROM gl_periods
	     WHERE period_type = per_type
	     AND   adjustment_period_flag = 'N'
	     AND   end_date - start_date + 1 = max_len
	     AND   rowid <> row_id);

	EXCEPTION
	  WHEN NO_DATA_FOUND THEN

	    -- No other periods with this maximum length.
	    -- Thus, we give up and search for the new maximum
	    -- Note that if there are no other periods, the max
	    -- will be set to null
	    UPDATE ar_period_types pt
	    SET pt.max_regular_period_length =
	      (SELECT decode(call_mode,
			'D',max(end_date - start_date) + 1,
			'U',greatest(new_len, nvl(max(end_date-start_date)+1,0)))
	       FROM gl_periods per
	       WHERE per.adjustment_period_flag = 'N'
	       AND   per.period_type = per_type
	       AND   per.rowid <> row_id)
            WHERE pt.period_type = per_type;
        END;
      END IF;
    END IF;
  END fix_max_len;


  PROCEDURE fix_ar_periods(call_mode		VARCHAR2,
	    		   cal_name		VARCHAR2,
			   per_type		VARCHAR2,
		   	   new_start_date	DATE,
			   new_end_date		DATE,
			   new_per_name		VARCHAR2,
			   old_per_name		VARCHAR2,
			   old_start_date	DATE) IS
    CURSOR get_new_pos IS
      SELECT nvl(max(new_period_num + 1), 1)
      FROM   ar_periods
      WHERE  period_set_name = cal_name
      AND    period_type = per_type
      AND    start_date < new_start_date;

    CURSOR get_old_pos IS
      SELECT new_period_num
      FROM   ar_periods
      WHERE  period_set_name = cal_name
      AND    period_type = per_type
      AND    period_name = old_per_name;

    new_pos  NUMBER;
    old_pos  NUMBER;
  BEGIN
    IF (call_mode = 'I') THEN

      -- Find where this period goes
      OPEN get_new_pos;
      FETCH get_new_pos INTO new_pos;
      IF get_new_pos%NOTFOUND THEN
	new_pos := 1;
      END IF;
      CLOSE get_new_pos;

      -- Increase the AR period number of all
      -- periods after it
      UPDATE ar_periods
      SET new_period_num = new_period_num + 1
      WHERE period_set_name = cal_name
      AND   period_type = per_type
      AND   new_period_num >= new_pos;

      -- Insert the new period
      INSERT INTO ar_periods
	(period_set_name, period_type, start_date, end_date,
	 new_period_num, period_name)
      VALUES
        (cal_name, per_type, new_start_date, new_end_date,
         new_pos, new_per_name);

    ELSIF (call_mode = 'U') THEN

      new_pos := 1;
      old_pos := new_pos;

      -- If the start date has changed, then the AR period number
      -- may have changed also.  Get the old and new AR period
      -- numbers in this case.
      IF (new_start_date <> old_start_date) THEN
        -- Find where this period was
        OPEN get_old_pos;
        FETCH get_old_pos INTO old_pos;
        IF get_old_pos%NOTFOUND THEN
	  CLOSE get_old_pos;
	  RAISE NO_DATA_FOUND;
        ELSE
	  CLOSE get_old_pos;
        END IF;

        -- Find where this period goes
        OPEN get_new_pos;
        FETCH get_new_pos INTO new_pos;
        IF get_new_pos%NOTFOUND THEN
	  new_pos := 1;
        END IF;
        CLOSE get_new_pos;
      END IF;

      -- If we are moving the period later, then
      -- everything is going to be moved earlier
      -- anyway, so the new position is actually
      -- one period earlier
      IF (old_pos < new_pos) THEN
        new_pos := new_pos - 1;
      END IF;

      -- Check if we have changed position.  This is an unusual case.
      -- Normally, the customer will just be moving the start date a couple
      -- of days one way or another, not moving the entire period
      IF (old_pos <> new_pos) THEN

        -- Update the changed periods AR period number to null, so that
        -- we can change the AR period number of the other periods
 	UPDATE ar_periods
	SET new_period_num = NULL
        WHERE period_set_name = cal_name
        AND   period_type = per_type
        AND   period_name = old_per_name;

        IF (new_pos < old_pos) THEN
	  -- Moving the period earlier
          UPDATE ar_periods
	  SET new_period_num = new_period_num + 1
          WHERE period_set_name = cal_name
          AND   period_type = per_type
          AND   new_period_num BETWEEN new_pos AND old_pos;

        ELSE
	  -- Moving the period later
          UPDATE ar_periods
	  SET new_period_num = new_period_num - 1
          WHERE period_set_name = cal_name
          AND   period_type = per_type
          AND   new_period_num BETWEEN old_pos AND new_pos;
        END IF;

	-- Move the period to its new position.  Also fix everything
        -- else
        UPDATE ar_periods
        SET start_date = new_start_date,
            end_date = new_end_date,
            period_name = new_per_name,
	    new_period_num = new_pos
        WHERE period_set_name = cal_name
        AND   period_type = per_type
        AND   period_name = old_per_name;

      ELSE
	-- The AR period number isn't changing, but fix everything else
        UPDATE ar_periods
        SET start_date = new_start_date,
            end_date = new_end_date,
            period_name = new_per_name
        WHERE period_set_name = cal_name
        AND   period_type = per_type
        AND   period_name = old_per_name;
      END IF;

    ELSIF (call_mode = 'D') THEN

      -- Find where this period was
      OPEN get_old_pos;
      FETCH get_old_pos INTO old_pos;
      IF get_old_pos%NOTFOUND THEN
	CLOSE get_old_pos;
	RAISE NO_DATA_FOUND;
      ELSE
	CLOSE get_old_pos;
      END IF;

      -- Delete the old period
      DELETE ar_periods
      WHERE  period_set_name = cal_name
      AND    period_type = per_type
      AND    period_name = old_per_name;

      -- Decrease the AR period number of all
      -- periods after it
      UPDATE ar_periods
      SET new_period_num = new_period_num - 1
      WHERE period_set_name = cal_name
      AND   period_type = per_type
      AND   new_period_num > old_pos;

    END IF;

  END fix_ar_periods;


--
-- PUBLIC FUNCTIONS
--

  PROCEDURE check_unique_num(calendar_name VARCHAR2,
                             period_type   VARCHAR2,
                             period_year   NUMBER,
                             period_num    NUMBER,
                             row_id        VARCHAR2) IS
    CURSOR chk_duplicates IS
      SELECT 'Duplicate'
      FROM   GL_PERIODS gp
      WHERE  gp.period_set_name =
               check_unique_num.calendar_name
      AND    gp.period_type = check_unique_num.period_type
      AND    gp.period_year = check_unique_num.period_year
      AND    gp.period_num = check_unique_num.period_num

      AND    (   row_id is NULL
              OR gp.rowid <> row_id);
    dummy VARCHAR2(100);
  BEGIN
    OPEN chk_duplicates;
    FETCH chk_duplicates INTO dummy;

    IF chk_duplicates%FOUND THEN
      CLOSE chk_duplicates;
      fnd_message.set_name('SQLGL', 'GL_DUPLICATE_PERIOD_NUMBER');
      app_exception.raise_exception;
    END IF;

    CLOSE chk_duplicates;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE', 'PERIODS.check_unique_num');
      RAISE;
  END check_unique_num;


  PROCEDURE check_unique_name(calendar_name VARCHAR2,
                              period_name VARCHAR2,
                              row_id VARCHAR2) IS
    CURSOR chk_duplicates IS
      SELECT 'Duplicate'
      FROM   GL_PERIODS gp
      WHERE  gp.period_name = check_unique_name.period_name
      AND    gp.period_set_name =
               check_unique_name.calendar_name
      AND    (   row_id IS NULL
              OR gp.rowid <> row_id);
    dummy VARCHAR2(100);
  BEGIN
    OPEN chk_duplicates;
    FETCH chk_duplicates INTO dummy;

    IF (chk_duplicates%FOUND) THEN
      CLOSE chk_duplicates;
      fnd_message.set_name('SQLGL', 'GL_DUPLICATE_PERIOD_NAME');
      app_exception.raise_exception;
    END IF;

    CLOSE chk_duplicates;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
        RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE', 'PERIODS.check_unique_name');
      RAISE;
  END check_unique_name;


  FUNCTION check_period_used(row_id VARCHAR2) RETURN BOOLEAN IS
    dummy VARCHAR2(100);
    calendar_name VARCHAR2(15);
    period_type   VARCHAR2(15);
    period_name   VARCHAR2(15);
    period_year   NUMBER;
  BEGIN

    DECLARE
      CURSOR get_data IS
        SELECT per.period_set_name, per.period_type,
               per.period_name, per.period_year
        FROM gl_periods per
        WHERE per.rowid = row_id;
    BEGIN
      OPEN get_data;
      FETCH get_data INTO calendar_name, period_type, period_name, period_year;

      IF (get_data%NOTFOUND) THEN
        CLOSE get_data;
        RAISE NO_DATA_FOUND;
      END IF;

      CLOSE get_data;

    EXCEPTION
      WHEN OTHERS THEN
        fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
        fnd_message.set_token('PROCEDURE', 'PERIODS.check_period_used');
        fnd_message.set_token('EVENT', 'Getting data');
        RAISE;
    END;

    -- Check for use with actuals
    DECLARE
      CURSOR chk_actual IS
        SELECT 'Opened'
        FROM gl_period_statuses ps,
             gl_ledgers led
        WHERE ps.application_id IN (101, 275, 283)
        AND   ps.period_name = check_period_used.period_name
        AND   ps.closing_status <> 'N'
        AND   ps.ledger_id = led.ledger_id+0
        AND   ps.period_type = check_period_used.period_type
        AND   led.period_set_name =
                check_period_used.calendar_name;
    BEGIN
      OPEN chk_actual;
      FETCH chk_actual INTO dummy;

      IF (chk_actual%FOUND) THEN
        CLOSE chk_actual;
        RETURN(TRUE);
      END IF;

      CLOSE chk_actual;

    EXCEPTION
      WHEN app_exceptions.application_exception THEN
        RAISE;
      WHEN OTHERS THEN
        fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
        fnd_message.set_token('PROCEDURE', 'PERIODS.check_period_used');
        fnd_message.set_token('EVENT', 'Checking Actuals');
        RAISE;
    END;

    -- Check for use with budgets
    DECLARE
      CURSOR chk_budget is
        SELECT 'Used for budgets'
        FROM gl_budgets b,
             gl_budget_versions bv,
             gl_budget_period_ranges bpr,
             gl_ledgers led
        WHERE bv.budget_name = b.budget_name
        AND   bv.budget_type = b.budget_type
        AND   bpr.budget_version_id = bv.budget_version_id
        AND   bpr.period_year =
                check_period_used.period_year
        AND   led.ledger_id = b.ledger_id
        AND   led.period_set_name =
                check_period_used.calendar_name
        AND   led.accounted_period_type = check_period_used.period_type;
    BEGIN
      OPEN chk_budget;
      FETCH chk_budget INTO dummy;

      IF (chk_budget%FOUND) THEN
        CLOSE chk_budget;
        RETURN(TRUE);
      END IF;

      CLOSE chk_budget;

    EXCEPTION
      WHEN app_exceptions.application_exception THEN
        RAISE;
      WHEN OTHERS THEN
        fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
        fnd_message.set_token('PROCEDURE', 'PERIODS.check_period_used');
        fnd_message.set_token('EVENT', 'Checking Budgets');
        RAISE;
    END;

    -- Check for use with encumbrances
    DECLARE
      CURSOR chk_encumbrance IS
        SELECT 'Used for encumbrances'
        FROM gl_ledgers led
        WHERE led.period_set_name =
                check_period_used.calendar_name
        AND   led.accounted_period_type = check_period_used.period_type
        AND   led.latest_encumbrance_year >=
                check_period_used.period_year;
    BEGIN
      OPEN chk_encumbrance;
      FETCH chk_encumbrance INTO dummy;

      IF (chk_encumbrance%FOUND) THEN
        CLOSE chk_encumbrance;
        RETURN(TRUE);
      END IF;

      CLOSE chk_encumbrance;

    EXCEPTION
      WHEN app_exceptions.application_exception THEN
        RAISE;
      WHEN OTHERS THEN
        fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
        fnd_message.set_token('PROCEDURE', 'PERIODS.check_period_used');
        fnd_message.set_token('EVENT', 'Checking Encumbrances');
        RAISE;
    END;

    -- Check period used by projects
    IF (pa_periods_pkg.check_gl_period_used_in_pa(period_name, calendar_name)
          = 'Y') THEN
      RETURN(TRUE);
    END IF;

    RETURN(FALSE);
  END check_period_used;

  FUNCTION period_changed(X_Rowid                                 VARCHAR2,
                          X_Period_Set_Name                       VARCHAR2,
                          X_Period_Name                           VARCHAR2,
                          X_Start_Date                            DATE,
                          X_End_Date                              DATE,
                          X_Period_Type                           VARCHAR2,
                          X_Period_Year                           NUMBER,
                          X_Period_Num                            NUMBER,
                          X_Quarter_Num                           NUMBER,
                          X_Entered_Period_Name                   VARCHAR2,
                          X_Description                           VARCHAR2
  ) RETURN BOOLEAN IS
    CURSOR C IS
        SELECT *
        FROM   GL_PERIODS
        WHERE  rowid = X_Rowid
        FOR UPDATE of Period_Set_Name NOWAIT;
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
            (   (Recinfo.period_set_name = X_Period_Set_Name)
             OR (    (Recinfo.period_set_name IS NULL)
                 AND (X_Period_Set_Name IS NULL)))
        AND (   (Recinfo.period_name = X_Period_Name)
             OR (    (Recinfo.period_name IS NULL)
                 AND (X_Period_Name IS NULL)))
        AND (   (Recinfo.start_date = X_Start_Date)
             OR (    (Recinfo.start_date IS NULL)
                 AND (X_Start_Date IS NULL)))
        AND (   (Recinfo.end_date = X_End_Date)
             OR (    (Recinfo.end_date IS NULL)
                 AND (X_End_Date IS NULL)))
        AND (   (Recinfo.period_type = X_Period_Type)
             OR (    (Recinfo.period_type IS NULL)
                 AND (X_Period_Type IS NULL)))
        AND (   (Recinfo.period_year = X_Period_Year)
             OR (    (Recinfo.period_year IS NULL)
                 AND (X_Period_Year IS NULL)))
        AND (   (Recinfo.period_num = X_Period_Num)
             OR (    (Recinfo.period_num IS NULL)
                 AND (X_Period_Num IS NULL)))
        AND (   (Recinfo.quarter_num = X_Quarter_Num)
             OR (    (Recinfo.quarter_num IS NULL)
                 AND (X_Quarter_Num IS NULL)))
        AND (   (Recinfo.entered_period_name = X_Entered_Period_Name)
             OR (    (Recinfo.entered_period_name IS NULL)
                 AND (X_Entered_Period_Name IS NULL)))
        AND (   (Recinfo.description = X_Description)
             OR (    (Recinfo.description IS NULL)
                 AND (X_Description IS NULL)))
       ) then
       RETURN(FALSE);
     else
       RETURN(TRUE);
    end if;
  END period_changed;

  FUNCTION overlapping_period(x_period_set_name VARCHAR2,
			      x_period_type     VARCHAR2,
			      x_start_date      DATE,
			      x_end_date        DATE,
			      row_id            VARCHAR2
  ) RETURN BOOLEAN IS
    CURSOR check_overlaps IS
        SELECT 'Overlapping'
        FROM   GL_PERIODS
        WHERE  period_set_name         = x_period_set_name
	AND    period_type             = x_period_type
        AND    start_date             <= x_end_date
        AND    end_date               >= x_start_date
	AND    adjustment_period_flag  = 'N'
        AND    (   row_id is NULL
                OR rowid <> row_id);

    dummy VARCHAR2(100);
  BEGIN
    OPEN check_overlaps;
    FETCH check_overlaps INTO dummy;
    if (check_overlaps%NOTFOUND) then
      CLOSE check_overlaps;
      RETURN(FALSE);
    else
      CLOSE check_overlaps;
      RETURN(TRUE);
    end if;
  END overlapping_period;

PROCEDURE Load_Row(X_Period_Set_Name                        VARCHAR2,
                     X_Period_Name                          VARCHAR2,
		     X_Owner				    VARCHAR2,
                     X_Start_Date                           VARCHAR2,
                     X_End_Date                             VARCHAR2,
                     X_Period_Type                          VARCHAR2,
                     X_Period_Year                          NUMBER,
                     X_Period_Num                           NUMBER,
                     X_Quarter_Num                          NUMBER,
                     X_Entered_Period_Name                  VARCHAR2,
                     X_Description                          VARCHAR2,
                     X_Attribute1                           VARCHAR2,
                     X_Attribute2                           VARCHAR2,
                     X_Attribute3                           VARCHAR2,
                     X_Attribute4                           VARCHAR2,
                     X_Attribute5                           VARCHAR2,
                     X_Attribute6                           VARCHAR2,
                     X_Attribute7                           VARCHAR2,
                     X_Attribute8                           VARCHAR2,
                     X_Context                              VARCHAR2,
                     X_Adjustment_Period_Flag               VARCHAR2
  ) AS
 user_id             number := 0;
 v_creation_date     date;
 v_rowid             rowid := null;
BEGIN
         -- validate input parameters
    if ( X_Period_Set_Name is null) then

      fnd_message.set_name('SQLGL', 'GL_LOAD_ROW_NO_DATA');
      app_exception.raise_exception;
    end if;

    if (X_OWNER = 'SEED') then
      user_id := 1;
    end if;

    BEGIN

        SELECT creation_date, rowid
	INTO   v_creation_date, v_rowid
	FROM   GL_PERIODS
	WHERE  period_set_name = X_Period_Set_Name
        AND    period_name = X_Period_Name;

        IF ( X_OWNER = 'SEED' ) THEN
	   gl_periods_pkg.Update_Row (
	             X_Rowid                    =>        v_rowid ,
                     X_Period_Set_Name          =>        X_Period_Set_Name,
                     X_Period_Name              =>        X_Period_Name,
                     X_Last_Update_Date         =>        sysdate,
                     X_Last_Updated_By          =>        user_id,
                     X_Start_Date               =>        to_date(X_Start_Date,'YYYY/MM/DD'),
                     X_End_Date                 =>        to_date(X_End_Date,'YYYY/MM/DD'),
                     X_Period_Type              =>        X_Period_Type,
                     X_Period_Year              =>        X_Period_Year,
                     X_Period_Num               =>        X_Period_Num,
                     X_Quarter_Num              =>        X_Quarter_Num,
                     X_Entered_Period_Name      =>        X_Entered_Period_Name,
                     X_Last_Update_Login        =>        0,
                     X_Description              =>        X_Description,
                     X_Attribute1               =>        X_Attribute1,
                     X_Attribute2               =>        X_Attribute2,
                     X_Attribute3               =>        X_Attribute3,
                     X_Attribute4               =>        X_Attribute4,
                     X_Attribute5               =>        X_Attribute5,
                     X_Attribute6               =>        X_Attribute6,
                     X_Attribute7               =>        X_Attribute7,
                     X_Attribute8               =>        X_Attribute8,
                     X_Context                  =>        X_Context,
                     X_Adjustment_Period_Flag   =>        X_Adjustment_Period_Flag
		     );
        END IF;

	EXCEPTION
	     WHEN NO_DATA_FOUND THEN

	       gl_periods_pkg.Insert_Row (
	                 X_Rowid                    =>        v_rowid ,
                         X_Period_Set_Name          =>        X_Period_Set_Name,
                         X_Period_Name              =>        X_Period_Name,
                         X_Last_Update_Date         =>        sysdate,
                         X_Last_Updated_By          =>        user_id,
		         X_Creation_date            =>	      sysdate,
			 X_Created_By	            =>        user_id,
                         X_Start_Date               =>        to_date(X_Start_Date,'YYYY/MM/DD'),
                         X_End_Date                 =>        to_date(X_End_Date,'YYYY/MM/DD'),
                         X_Period_Type              =>        X_Period_Type,
                         X_Period_Year              =>        X_Period_Year,
                         X_Period_Num               =>        X_Period_Num,
                         X_Quarter_Num              =>        X_Quarter_Num,
                         X_Entered_Period_Name      =>        X_Entered_Period_Name,
                         X_Last_Update_Login        =>        0,
                         X_Description              =>        X_Description,
                         X_Attribute1               =>        X_Attribute1,
                         X_Attribute2               =>        X_Attribute2,
                         X_Attribute3               =>        X_Attribute3,
                         X_Attribute4               =>        X_Attribute4,
                         X_Attribute5               =>        X_Attribute5,
                         X_Attribute6               =>        X_Attribute6,
                         X_Attribute7               =>        X_Attribute7,
                         X_Attribute8               =>        X_Attribute8,
                         X_Context                  =>        X_Context,
                         X_Adjustment_Period_Flag   =>        X_Adjustment_Period_Flag
	        	     );

        END;
 END Load_Row;



PROCEDURE Insert_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                     X_Period_Set_Name                     VARCHAR2,
                     X_Period_Name                         VARCHAR2,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Start_Date                          DATE,
                     X_End_Date                            DATE,
                     X_Period_Type                         VARCHAR2,
                     X_Period_Year                         NUMBER,
                     X_Period_Num                          NUMBER,
                     X_Quarter_Num                         NUMBER,
                     X_Entered_Period_Name                 VARCHAR2,
                     X_Creation_Date                       DATE,
                     X_Created_By                          NUMBER,
                     X_Last_Update_Login                   NUMBER,
                     X_Description                         VARCHAR2,
                     X_Attribute1                          VARCHAR2,
                     X_Attribute2                          VARCHAR2,
                     X_Attribute3                          VARCHAR2,
                     X_Attribute4                          VARCHAR2,
                     X_Attribute5                          VARCHAR2,
                     X_Attribute6                          VARCHAR2,
                     X_Attribute7                          VARCHAR2,
                     X_Attribute8                          VARCHAR2,
                     X_Context                             VARCHAR2,
                     X_Adjustment_Period_Flag              VARCHAR2
 ) IS
   CURSOR C IS SELECT rowid FROM GL_PERIODS
             WHERE period_set_name = X_Period_Set_Name
             AND   period_name = X_Period_Name;


  x_quarter_start_date	DATE;
  x_year_start_date     DATE;

BEGIN


  IF (instr(X_period_name, '''') <> 0) THEN
    fnd_message.set_name('SQLGL', 'GL_CALENDAR_PERIOD_WITH_QUOTE');
    app_exception.raise_exception;
  END IF;

  IF (instr(X_entered_period_name, '''') <> 0) THEN
    fnd_message.set_name('SQLGL', 'GL_CALENDAR_PERIOD_WITH_QUOTE');
    app_exception.raise_exception;
  END IF;

  IF (X_Adjustment_Period_Flag = 'N') THEN
    -- If this is not an adjusting period, then verify that this period
    -- does not overlap with any other periods
    IF (overlapping_period(X_Period_Set_Name,
			   X_Period_Type,
			   X_Start_Date,
			   X_End_Date,
			   null)
       ) THEN
      fnd_message.set_name('SQLGL', 'GL_CALENDAR_OVERLAP_PERIODS');
      app_exception.raise_exception;
    END IF;

    -- Reset the maximum length, if necessary
    fix_max_len('I', X_Period_Type, NULL, NULL, X_End_Date - X_Start_Date + 1);

    -- Insert the new row into ar_periods
    fix_ar_periods('I', X_Period_Set_Name, X_Period_Type, X_Start_Date,
                   X_End_Date, X_Period_Name, NULL, NULL);

  END IF;

  -- call AB procedure which maintains all AB data
  maintain_AB_data	(
			'INSERT',
			X_Period_Set_Name,
			X_Period_Type,
			X_Adjustment_Period_Flag,
			X_Start_Date+1, -- to make old and new date different
			X_Start_Date,
			X_End_Date,
			X_Period_Name,
			X_Period_Year,
			X_Period_Year,
			X_Quarter_Num,
			X_Quarter_Num,
			x_quarter_start_date,
			x_year_start_date,
			X_Creation_Date,
                     	X_Created_By,
			X_Last_Update_Date,
			X_Last_Updated_By,
			X_Last_Update_Login
			);

  INSERT INTO GL_PERIODS(
          period_set_name,
          period_name,
          last_update_date,
          last_updated_by,
          start_date,
          end_date,
          period_type,
          period_year,
          period_num,
          quarter_num,
          entered_period_name,
          creation_date,
          created_by,
          last_update_login,
          description,
          attribute1,
          attribute2,
          attribute3,
          attribute4,
          attribute5,
          attribute6,
          attribute7,
          attribute8,
          context,
          adjustment_period_flag,
          quarter_start_date,
	  year_start_date
         ) VALUES (
          X_Period_Set_Name,
          X_Period_Name,
          X_Last_Update_Date,
          X_Last_Updated_By,
          X_Start_Date,
          X_End_Date,
          X_Period_Type,
          X_Period_Year,
          X_Period_Num,
          X_Quarter_Num,
          X_Entered_Period_Name,
          X_Creation_Date,
          X_Created_By,
          X_Last_Update_Login,
          X_Description,
          X_Attribute1,
          X_Attribute2,
          X_Attribute3,
          X_Attribute4,
          X_Attribute5,
          X_Attribute6,
          X_Attribute7,
          X_Attribute8,
          X_Context,
          X_Adjustment_Period_Flag,
          x_quarter_start_date,
	  x_year_start_date
  );

  OPEN C;
  FETCH C INTO X_Rowid;
  if (C%NOTFOUND) then
    CLOSE C;
    RAISE NO_DATA_FOUND;
  end if;
  CLOSE C;

  -- Insert rows in gl_period_statuses for this period
  gl_period_statuses_pkg.insert_period(
      X_period_set_name,
      X_period_name,
      X_start_date,
      X_end_date,
      X_period_type,
      X_period_year,
      X_period_num,
      X_quarter_num,
      X_adjustment_period_flag,
      X_last_updated_by,
      X_last_update_login,
      x_quarter_start_date,
      x_year_start_date);

END Insert_Row;

PROCEDURE Lock_Row(X_Rowid                                 VARCHAR2,

                   X_Period_Set_Name                       VARCHAR2,
                   X_Period_Name                           VARCHAR2,
                   X_Start_Date                            DATE,
                   X_End_Date                              DATE,
                   X_Period_Type                           VARCHAR2,
                   X_Period_Year                           NUMBER,
                   X_Period_Num                            NUMBER,
                   X_Quarter_Num                           NUMBER,
                   X_Entered_Period_Name                   VARCHAR2,
                   X_Description                           VARCHAR2,
                   X_Attribute1                            VARCHAR2,
                   X_Attribute2                            VARCHAR2,
                   X_Attribute3                            VARCHAR2,
                   X_Attribute4                            VARCHAR2,
                   X_Attribute5                            VARCHAR2,
                   X_Attribute6                            VARCHAR2,
                   X_Attribute7                            VARCHAR2,
                   X_Attribute8                            VARCHAR2,
                   X_Context                               VARCHAR2,
                   X_Adjustment_Period_Flag                VARCHAR2
) IS
  CURSOR C IS
      SELECT *
      FROM   GL_PERIODS
      WHERE  rowid = X_Rowid
      FOR UPDATE of Period_Set_Name NOWAIT;
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
          (   (Recinfo.period_set_name = X_Period_Set_Name)
           OR (    (Recinfo.period_set_name IS NULL)
               AND (X_Period_Set_Name IS NULL)))
      AND (   (Recinfo.period_name = X_Period_Name)
           OR (    (Recinfo.period_name IS NULL)
               AND (X_Period_Name IS NULL)))
      AND (   (Recinfo.start_date = X_Start_Date)
           OR (    (Recinfo.start_date IS NULL)
               AND (X_Start_Date IS NULL)))
      AND (   (Recinfo.end_date = X_End_Date)
           OR (    (Recinfo.end_date IS NULL)
               AND (X_End_Date IS NULL)))
      AND (   (Recinfo.period_type = X_Period_Type)
           OR (    (Recinfo.period_type IS NULL)
               AND (X_Period_Type IS NULL)))
      AND (   (Recinfo.period_year = X_Period_Year)
           OR (    (Recinfo.period_year IS NULL)
               AND (X_Period_Year IS NULL)))
      AND (   (Recinfo.period_num = X_Period_Num)
           OR (    (Recinfo.period_num IS NULL)
               AND (X_Period_Num IS NULL)))
      AND (   (Recinfo.quarter_num = X_Quarter_Num)
           OR (    (Recinfo.quarter_num IS NULL)
               AND (X_Quarter_Num IS NULL)))
      AND (   (Recinfo.entered_period_name = X_Entered_Period_Name)
           OR (    (Recinfo.entered_period_name IS NULL)
               AND (X_Entered_Period_Name IS NULL)))
      AND (   (Recinfo.description = X_Description)
           OR (    (Recinfo.description IS NULL)
               AND (X_Description IS NULL)))
      AND (   (Recinfo.attribute1 = X_Attribute1)
           OR (    (Recinfo.attribute1 IS NULL)
               AND (X_Attribute1 IS NULL)))
      AND (   (Recinfo.attribute2 = X_Attribute2)
           OR (    (Recinfo.attribute2 IS NULL)
               AND (X_Attribute2 IS NULL)))
      AND (   (Recinfo.attribute3 = X_Attribute3)
           OR (    (Recinfo.attribute3 IS NULL)
               AND (X_Attribute3 IS NULL)))
      AND (   (Recinfo.attribute4 = X_Attribute4)
           OR (    (Recinfo.attribute4 IS NULL)
               AND (X_Attribute4 IS NULL)))
      AND (   (Recinfo.attribute5 = X_Attribute5)
           OR (    (Recinfo.attribute5 IS NULL)
               AND (X_Attribute5 IS NULL)))
      AND (   (Recinfo.attribute6 = X_Attribute6)
           OR (    (Recinfo.attribute6 IS NULL)
               AND (X_Attribute6 IS NULL)))
      AND (   (Recinfo.attribute7 = X_Attribute7)
           OR (    (Recinfo.attribute7 IS NULL)
               AND (X_Attribute7 IS NULL)))
      AND (   (Recinfo.attribute8 = X_Attribute8)
           OR (    (Recinfo.attribute8 IS NULL)
               AND (X_Attribute8 IS NULL)))
      AND (   (Recinfo.context = X_Context)
           OR (    (Recinfo.context IS NULL)
               AND (X_Context IS NULL)))
      AND (   (Recinfo.adjustment_period_flag = X_Adjustment_Period_Flag)
           OR (    (Recinfo.adjustment_period_flag IS NULL)
               AND (X_Adjustment_Period_Flag IS NULL)))
          ) then
    return;
  else
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
END Lock_Row;

PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Period_Set_Name                     VARCHAR2,
                     X_Period_Name                         VARCHAR2,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Start_Date                          DATE,
                     X_End_Date                            DATE,
                     X_Period_Type                         VARCHAR2,
                     X_Period_Year                         NUMBER,
                     X_Period_Num                          NUMBER,
                     X_Quarter_Num                         NUMBER,
                     X_Entered_Period_Name                 VARCHAR2,
                     X_Last_Update_Login                   NUMBER,
                     X_Description                         VARCHAR2,
                     X_Attribute1                          VARCHAR2,
                     X_Attribute2                          VARCHAR2,
                     X_Attribute3                          VARCHAR2,
                     X_Attribute4                          VARCHAR2,
                     X_Attribute5                          VARCHAR2,
                     X_Attribute6                          VARCHAR2,
                     X_Attribute7                          VARCHAR2,
                     X_Attribute8                          VARCHAR2,
                     X_Context                             VARCHAR2,
                     X_Adjustment_Period_Flag              VARCHAR2
) IS
  CURSOR get_old_name IS
    SELECT period_name, start_date, end_date, period_year, quarter_num,
	   adjustment_period_flag
    FROM gl_periods
    WHERE rowid = X_rowid;

  X_period_name_old 	VARCHAR2(15);
  x_start_date_old	DATE;
  x_end_date_old	DATE;
  x_period_year_old	NUMBER;
  x_quarter_num_old	NUMBER;
  x_adj_flag_old        VARCHAR2(1);
  x_quarter_start_date	DATE;
  x_year_start_date     DATE;

BEGIN

  -- Make sure you are allowed to change this period
  IF (gl_periods_pkg.period_changed(X_Rowid,
                                    X_Period_Set_Name,
                                    X_Period_Name,
                                    X_Start_Date,
                                    X_End_Date,
                                    X_Period_Type,
                                    X_Period_Year,
                                    X_Period_Num,
                                    X_Quarter_Num,
                                    X_Entered_Period_Name,
                                    X_Description)) THEN
    IF (gl_periods_pkg.check_period_used(X_Rowid)) THEN
      fnd_message.set_name('SQLGL', 'GL_CALENDAR_PERIOD_IN_USE');
      app_exception.raise_exception;
    END IF;
  END IF;


  IF (instr(X_period_name, '''') <> 0) THEN
    fnd_message.set_name('SQLGL', 'GL_CALENDAR_PERIOD_WITH_QUOTE');
    app_exception.raise_exception;
  END IF;

  IF (instr(X_entered_period_name, '''') <> 0) THEN
    fnd_message.set_name('SQLGL', 'GL_CALENDAR_PERIOD_WITH_QUOTE');
    app_exception.raise_exception;
  END IF;

  -- If this is not an adjusting period, then verify that this period
  -- does not overlap with any other periods
  IF (X_Adjustment_Period_Flag = 'N') THEN
    IF (overlapping_period(X_Period_Set_Name,
			   X_Period_Type,
			   X_Start_Date,
			   X_End_Date,
			   X_RowId)
       ) THEN
      fnd_message.set_name('SQLGL', 'GL_CALENDAR_OVERLAP_PERIODS');
      app_exception.raise_exception;
    END IF;
  END IF;


  -- Get the original period name, in case it has been changed
  OPEN get_old_name;
  FETCH get_old_name INTO X_period_name_old, x_start_date_old, x_end_date_old,
                          x_period_year_old, x_quarter_num_old,
			  x_adj_flag_old;
  if (get_old_name%NOTFOUND) then
    CLOSE get_old_name;
    RAISE NO_DATA_FOUND;
  end if;
  CLOSE get_old_name;

  IF (X_Adjustment_Period_Flag = 'N') THEN
    IF (x_adj_flag_old = 'N') THEN
      -- Reset the maximum length, if necessary
      fix_max_len('U', X_Period_Type, X_rowid,
		  x_end_date_old - x_start_date_old + 1,
	          X_End_Date - X_Start_Date + 1);
      -- Update the row in ar_periods
      fix_ar_periods('U', X_Period_Set_Name, X_Period_Type, X_Start_Date,
                     X_End_Date, X_Period_Name, X_period_name_old,
		     x_start_date_old);
    ELSE
      -- Reset the maximum length, if necessary
      fix_max_len('I', X_Period_Type, NULL,NULL, X_End_Date - X_Start_Date + 1);
      -- Insert the row into ar_periods
      fix_ar_periods('I', X_Period_Set_Name, X_Period_Type, X_Start_Date,
                     X_End_Date, X_Period_Name, NULL, NULL);
    END IF;
  ELSE
    IF (x_adj_flag_old = 'N') THEN
      -- Reset the maximum length, if necessary
      fix_max_len('D', X_Period_Type, X_rowid,
		  x_end_date_old - x_start_date_old + 1,
	          NULL);
      -- Delete the row from ar_periods
      fix_ar_periods('D', X_Period_Set_Name, X_Period_Type, NULL, NULL, NULL,
                     x_period_name_old, x_start_date_old);
    END IF;
  END IF;

  UPDATE GL_PERIODS
  SET

    period_set_name                           =    X_Period_Set_Name,
    period_name                               =    X_Period_Name,
    last_update_date                          =    X_Last_Update_Date,
    last_updated_by                           =    X_Last_Updated_By,
    start_date                                =    X_Start_Date,
    end_date                                  =    X_End_Date,
    period_type                               =    X_Period_Type,
    period_year                               =    X_Period_Year,
    period_num                                =    X_Period_Num,
    quarter_num                               =    X_Quarter_Num,
    entered_period_name                       =    X_Entered_Period_Name,
    last_update_login                         =    X_Last_Update_Login,
    description                               =    X_Description,
    attribute1                                =    X_Attribute1,
    attribute2                                =    X_Attribute2,
    attribute3                                =    X_Attribute3,
    attribute4                                =    X_Attribute4,
    attribute5                                =    X_Attribute5,
    attribute6                                =    X_Attribute6,
    attribute7                                =    X_Attribute7,
    attribute8                                =    X_Attribute8,
    context                                   =    X_Context,
    adjustment_period_flag                    =    X_Adjustment_Period_Flag
  WHERE rowid = X_rowid;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;

  -- Update any rows in gl_period_statuses for this period
  gl_period_statuses_pkg.update_period(
      X_period_set_name,
      X_period_name_old,
      X_period_name,
      X_start_date,
      X_end_date,
      X_period_type,
      X_period_year,
      X_period_num,
      X_quarter_num,
      X_adjustment_period_flag,
      X_last_updated_by,
      X_last_update_login);

  -- call AB proceudre which maintains all AB data
  maintain_AB_data	(
			'UPDATE',
			X_Period_Set_Name,
			X_Period_Type,
			X_Adjustment_Period_Flag,
			x_start_date_old,
			X_Start_Date,
			X_End_Date,
			X_Period_Name,
			x_period_year_old,
			X_Period_Year,
			x_quarter_num_old,
			X_Quarter_Num,
			x_quarter_start_date,
			x_year_start_date,
			sysdate,
			X_Last_Updated_By,
			X_Last_Update_Date,
			X_Last_Updated_By,
			X_Last_Update_Login
			);

END Update_Row;

PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
  CURSOR get_old_name IS
    SELECT period_name, period_set_name,
           start_date,period_year, quarter_num, period_type,
           adjustment_period_flag, end_date, period_num,
           last_updated_by,last_update_login
    FROM gl_periods
    WHERE rowid = X_rowid;

  X_period_name_old 	VARCHAR2(15);
  X_period_set_name 	VARCHAR2(15);
  X_period_type		VARCHAR2(15);
  X_adjustment_period_flag VARCHAR2(1);
  x_start_date_old	DATE;
  x_end_date_old	DATE;
  x_period_year_old	NUMBER;
  x_quarter_num_old	NUMBER;
  x_period_num_old	NUMBER;
  x_quarter_start_date	DATE;
  x_year_start_date     DATE;
  x_last_updated_by	NUMBER;
  x_last_update_login	NUMBER;
BEGIN

  -- Get the original period name, in case it has been changed
  OPEN get_old_name;
  FETCH get_old_name INTO X_period_name_old, X_period_set_name,
			  x_start_date_old,
                          x_period_year_old, x_quarter_num_old, X_period_type,
                          X_adjustment_period_flag, x_end_date_old,
                          x_period_num_old,x_last_updated_by,x_last_update_login;
  if (get_old_name%NOTFOUND) then
    CLOSE get_old_name;
    RAISE NO_DATA_FOUND;
  end if;
  CLOSE get_old_name;

  -- Make sure the period has never been used
  IF (gl_periods_pkg.check_period_used(X_Rowid)) THEN
    fnd_message.set_name('SQLGL', 'GL_CALENDAR_PERIOD_IN_USE');
    app_exception.raise_exception;
  END IF;

  IF (X_Adjustment_Period_Flag = 'N') THEN
    -- Reset the maximum length, if necessary
    fix_max_len('D', X_Period_Type, x_rowid,
	 	x_end_date_old - x_start_date_old + 1,
	        NULL);
    -- Delete the row from ar_periods
    fix_ar_periods('D', X_Period_Set_Name, X_Period_Type, NULL, NULL, NULL,
                   x_period_name_old, x_start_date_old);
  END IF;

  DELETE FROM GL_PERIODS
  WHERE  rowid = X_Rowid;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;

  -- Delete any rows in gl_period_statuses
  -- associated with this period
  gl_period_statuses_pkg.delete_period(
     X_period_set_name,
     X_period_name_old);


  -- call AB procedure which maintains all AB data
  maintain_AB_data	(
			'DELETE',
			X_Period_Set_Name,
			X_Period_Type,
			X_Adjustment_Period_Flag,
			x_start_date_old+1,
			X_start_date_old,
			x_end_date_old,
			X_period_name_old,
			x_period_year_old,
			x_period_year_old,
			x_quarter_num_old,
			x_period_num_old,
			x_quarter_start_date,
			x_year_start_date,
			sysdate,
			x_last_updated_by,
			sysdate,
			x_last_updated_by,
			x_last_update_login
			);
END Delete_Row;

  PROCEDURE maintain_quarter_start_date
			(
			x_period_set_name 	VARCHAR2,
			x_period_type     	VARCHAR2,
			x_period_year		NUMBER,
			x_quarter_num		NUMBER,
			x_start_date		DATE,
			x_operation		VARCHAR2,
			x_quarter_start_date	IN OUT NOCOPY DATE
			)  IS

	existing_quarter_start_date	DATE;
	--x_quarter_start_date		DATE;

BEGIN

   -- Maintain quarter_start_date in GL_PERIODS and GL_PERIOD_STATUSES tables
   -- in Insert_row call to this procedure should be put before actual insert in the tables
   -- in Delete_Row call to this procedure should be put after actual update/delete

   -- For quarter_start_date get existing_quarter_start_date:
   SELECT 	min(start_date)
   INTO 	existing_quarter_start_date
   FROM 	gl_periods
   WHERE
	    period_set_name = x_period_set_name
	AND period_type = x_period_type
	AND period_year = x_period_year
	AND quarter_num = x_quarter_num;

   x_quarter_start_date := NVL(existing_quarter_start_date,x_start_date);

   -- update tables if necessary
   IF (     x_operation = 'INSERT') THEN
	IF(x_start_date >= existing_quarter_start_date ) THEN
	   RETURN;
        ELSE
           x_quarter_start_date := x_start_date;
        END IF;
   END IF;


   UPDATE gl_periods
   SET quarter_start_date = x_quarter_start_date
   WHERE
		    period_set_name = x_period_set_name
		AND quarter_num = x_quarter_num
		AND period_type = x_period_type
		AND period_year = x_period_year;

   UPDATE gl_period_statuses
   SET quarter_start_date = x_quarter_start_date
   WHERE
		    quarter_num = x_quarter_num
		AND period_type = x_period_type
		AND period_year = x_period_year
		AND ledger_id IN
	         (SELECT ledger_id
		FROM gl_ledgers
		WHERE period_set_name = x_period_set_name);

END maintain_quarter_start_date;

PROCEDURE maintain_year_start_date
			(
			x_period_set_name 	VARCHAR2,
			x_period_type     	VARCHAR2,
			x_period_year		NUMBER,
			x_start_date		DATE,
			x_operation		VARCHAR2,
                        x_year_start_date       IN OUT NOCOPY DATE
			)  IS

	existing_year_start_date	DATE;
	--x_year_start_date		DATE;

BEGIN

   --Maintain year_start_date in GL_PERIODS and GL_PERIOD_STATUSES tables

   -- For year_start_date get existing_year_start_date:
   SELECT 	min(start_date)
   INTO 	existing_year_start_date
   FROM 	gl_periods
   WHERE
	    period_set_name = x_period_set_name
	AND period_type = x_period_type
	AND period_year = x_period_year;

   x_year_start_date := NVL(existing_year_start_date, x_start_date);

   -- update tables if necessary
   IF (    x_operation = 'INSERT') THEN
	IF(x_start_date >= existing_year_start_date ) THEN
	   RETURN;
        ELSE
          x_year_start_date := x_start_date;
        END IF;
   END IF;

   UPDATE gl_periods
   SET year_start_date = x_year_start_date
   WHERE
		    period_set_name = x_period_set_name
		AND period_type = x_period_type
		AND period_year = x_period_year;

   UPDATE gl_period_statuses
   SET year_start_date = x_year_start_date
   WHERE
		     period_type = x_period_type
		AND period_year = x_period_year
		AND ledger_id IN
	         (SELECT ledger_id
		FROM gl_ledgers
		WHERE period_set_name = x_period_set_name);

END maintain_year_start_date;

FUNCTION period_set_with_AB
			(
			x_period_set_name 	VARCHAR2
			)  RETURN VARCHAR2 IS
  -- check does this period_set is used by LED with AB enabled
  CURSOR check_LED IS
	SELECT '1' FROM sys.dual
	WHERE EXISTS
                (SELECT 'Calendar used in LED with Average Balancing enabled'
		FROM	gl_ledgers
		WHERE
			    period_set_name = x_period_set_name
			AND enable_average_balances_flag= 'Y'
		);
        dummy			VARCHAR2(1000);
  BEGIN
    -- check whether the current record inserts/updates with a new year
    OPEN check_LED;
    FETCH check_LED INTO dummy;
    IF (check_LED%NOTFOUND) THEN
      CLOSE check_LED;
      RETURN('NO');
    ELSE
      -- this is not a new year, exit
      CLOSE check_LED;
      RETURN('YES');
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                            'gl_periods_pkg.period_set_with_AB');
      RAISE;

END period_set_with_AB;

PROCEDURE maintain_AB_data
			(
			x_operation		VARCHAR2,
			x_period_set_name 	VARCHAR2,
			x_period_type     	VARCHAR2,
			x_adjust_period_flag	VARCHAR2,
			x_start_date_old	DATE,
			x_start_date_new	DATE,
			x_end_date		DATE,
			x_period_name		VARCHAR2,
			x_period_year_old	NUMBER,
			x_period_year_new	NUMBER,
			x_quarter_num_old	NUMBER,
			x_quarter_num_new	NUMBER,
                        x_quarter_start_date    IN OUT NOCOPY DATE,
                        x_year_start_date       IN OUT NOCOPY DATE,
			x_CREATION_DATE		DATE,
			x_CREATED_BY		NUMBER,
			x_LAST_UPDATE_DATE	DATE,
			x_LAST_UPDATED_BY	NUMBER,
			x_LAST_UPDATE_LOGIN	NUMBER
			)  IS
   entered_year		VARCHAR2(30);
BEGIN

   -- check if a period has more than 35 days
   IF(      x_start_date_new - x_end_date + 1 > 35
	AND period_set_with_AB(x_period_set_name) = 'YES') THEN
      fnd_message.set_name('SQLGL', 'GL_AB_PERIOD_LASTS_M_35');
      app_exception.raise_exception;
   END IF;

   -- populate GL_TRANSACTION_DATES table
   entered_year := TO_CHAR(x_end_date, 'YYYY');
   gl_transaction_dates_pkg.extend_transaction_calendars
			(
			x_period_set_name,
			x_period_type,
			entered_year,
			x_CREATION_DATE,
			x_CREATED_BY,
			x_LAST_UPDATE_DATE,
			x_LAST_UPDATED_BY,
			x_LAST_UPDATE_LOGIN
			);
   -- maintain GL_DATE_PERIOD_MAP table
   gl_date_period_map_pkg.maintain_date_period_map
			(
			x_period_set_name,
			x_period_type,
			x_adjust_period_flag,
			x_operation,
			x_start_date_new,
			x_end_date,
			x_period_name,
			x_CREATION_DATE,
			x_CREATED_BY,
			x_LAST_UPDATE_DATE,
			x_LAST_UPDATED_BY,
			x_LAST_UPDATE_LOGIN
			);

   -- the following is logic for maintaining the quarter_start_date
   -- and year_start_date columns in the GL_PERIODS and GL_PERIOD_STATUSES
   -- IF the year has changed:
	   -- do 1.(maintain_year_start_date) and
           --    2.(maintain_quarter_start_date) for:
		 -- new year
		 -- old year
		 -- new quarter
		 -- old quarter

   -- ELSIF the quarter has changed:
	   -- do 1.
	   -- do 2.  for:
		-- new quarter
		-- old quarter
   -- ELSIF :entered_start_date  has changed
	   -- do 1. and 2. for current quarter and year
   -- END IF
   IF (x_period_year_new <> x_period_year_old) THEN
	maintain_year_start_date
			(
			x_period_set_name,
			x_period_type,
			x_period_year_new,
			x_start_date_new,
			x_operation,
			x_year_start_date
			);
	maintain_year_start_date
			(
			x_period_set_name,
			x_period_type,
			x_period_year_old,
			x_start_date_old,
			'UPDATE',
			x_year_start_date
			);

        maintain_quarter_start_date
			(
			x_period_set_name,
			x_period_type,
			x_period_year_new,
			x_quarter_num_new,
			x_start_date_new,
			x_operation,
			x_quarter_start_date
			);

        maintain_quarter_start_date
			(
			x_period_set_name,
			x_period_type,
			x_period_year_old,
			x_quarter_num_old,
			x_start_date_old,
			x_operation,
			x_quarter_start_date
			);
   ELSIF (x_quarter_num_new <> x_quarter_num_old) THEN
	maintain_year_start_date
			(
			x_period_set_name,
			x_period_type,
			x_period_year_new,
			x_start_date_new,
			x_operation,
			x_year_start_date
			);
        maintain_quarter_start_date
			(
			x_period_set_name,
			x_period_type,
			x_period_year_new,
			x_quarter_num_new,
			x_start_date_new,
			'UPDATE',
			x_quarter_start_date
			);

        maintain_quarter_start_date
			(
			x_period_set_name,
			x_period_type,
			x_period_year_old,
			x_quarter_num_old,
			x_start_date_old,
			x_operation,
			x_quarter_start_date
			);
   ELSIF (x_start_date_new <> x_start_date_old) THEN
	maintain_year_start_date
			(
			x_period_set_name,
			x_period_type,
			x_period_year_new,
			x_start_date_new,
			x_operation,
			x_year_start_date
			);
        maintain_quarter_start_date
			(
			x_period_set_name,
			x_period_type,
			x_period_year_new,
			x_quarter_num_new,
			x_start_date_new,
			x_operation,
			x_quarter_start_date
			);
   END IF;

END maintain_AB_data;

PROCEDURE Insert_Period(Y_Rowid                         IN OUT NOCOPY VARCHAR2,
                        Y_Period_Set_Name                      VARCHAR2,
                        Y_Period_Name                          VARCHAR2,
                        Y_Last_Update_Date                     DATE,
                        Y_Last_Updated_By                      NUMBER,
                        Y_Start_Date                           DATE,
                        Y_End_Date                             DATE,
                        Y_Period_Type                          VARCHAR2,
                        Y_Period_Year                          NUMBER,
                        Y_Period_Num                           NUMBER,
                        Y_Quarter_Num                          NUMBER,
                        Y_Entered_Period_Name                  VARCHAR2,
                        Y_Creation_Date                        DATE,
                        Y_Created_By                           NUMBER,
                        Y_Last_Update_Login                    NUMBER,
                        Y_Description                          VARCHAR2,
                        Y_Attribute1                           VARCHAR2,
                        Y_Attribute2                           VARCHAR2,
                        Y_Attribute3                           VARCHAR2,
                        Y_Attribute4                           VARCHAR2,
                        Y_Attribute5                           VARCHAR2,
                        Y_Attribute6                           VARCHAR2,
                        Y_Attribute7                           VARCHAR2,
                        Y_Attribute8                           VARCHAR2,
                        Y_Context                              VARCHAR2,
                        Y_Adjustment_Period_Flag               VARCHAR2
                        ) IS

  CURSOR check_period_num IS
       SELECT number_per_fiscal_year
       FROM   GL_PERIOD_TYPES
       WHERE  period_type = Y_Period_Type;

  v_number_per_fiscal_year NUMBER;

BEGIN
  -- Check Unique Combination
  GL_PERIODS_PKG.check_unique_num(calendar_name => Y_Period_Set_Name,
                                  period_type   => Y_Period_Type,
                                  period_year   => Y_Period_Year,
                                  period_num    => Y_Period_Num,
                                  row_id        => Y_Rowid);

  -- Check if Period_Num is between 1 and the number of periods per year for the
  -- period type.
  OPEN check_period_num;
  FETCH check_period_num INTO v_number_per_fiscal_year;

  IF check_period_num%NOTFOUND THEN
    CLOSE check_period_num;
    fnd_message.set_name('SQLGL', 'GL_API_VALUE_NOT_EXIST');
    fnd_message.set_token('VALUE', Y_Period_Type);
    fnd_message.set_token('ATTRIBUTE', 'PeriodType');
    app_exception.raise_exception;
  ELSE
    CLOSE check_period_num;
  END IF;

  IF (Y_Period_Num < 1 OR Y_Period_Num > v_number_per_fiscal_year) THEN
    fnd_message.set_name('SQLGL', 'GL_PERIOD_NUMBER_LESS_THAN_MAX');
    fnd_message.set_token('MAX_NUM', v_number_per_fiscal_year);
    app_exception.raise_exception;
  END IF;

  -- Check that the Entered Period Name does not contain any spaces.
  IF (INSTR(Y_Entered_Period_Name,' ') <> 0) THEN
    fnd_message.set_name('SQLGL', 'GL_CALENDAR_NAME_NO_SPACES');
    app_exception.raise_exception;
  END IF;

  IF (instr(Y_period_name, '''') <> 0) THEN
    fnd_message.set_name('SQLGL', 'GL_CALENDAR_PERIOD_WITH_QUOTE');
    app_exception.raise_exception;
  END IF;

  IF (instr(Y_entered_period_name, '''') <> 0) THEN
    fnd_message.set_name('SQLGL', 'GL_CALENDAR_PERIOD_WITH_QUOTE');
    app_exception.raise_exception;
  END IF;

  -- Call the forms table handler.
  GL_PERIODS_PKG.Insert_Row(Y_Rowid,
                            Y_Period_Set_Name,
                            Y_Period_Name,
                            Y_Last_Update_Date,
                            Y_Last_Updated_By,
                            Y_Start_Date,
                            Y_End_Date,
                            Y_Period_Type,
                            Y_Period_Year,
                            Y_Period_Num,
                            Y_Quarter_Num,
                            Y_Entered_Period_Name,
                            Y_Creation_Date,
                            Y_Created_By,
                            Y_Last_Update_Login,
                            Y_Description,
                            Y_Attribute1,
                            Y_Attribute2,
                            Y_Attribute3,
                            Y_Attribute4,
                            Y_Attribute5,
                            Y_Attribute6,
                            Y_Attribute7,
                            Y_Attribute8,
                            Y_Context,
                            Y_Adjustment_Period_Flag
                            );

EXCEPTION
  WHEN app_exceptions.application_exception THEN
    RAISE;
  WHEN OTHERS THEN
    fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
    fnd_message.set_token('PROCEDURE', 'GL_PERIODS_PKG.Insert_Period');
    RAISE;
END Insert_Period;

PROCEDURE Update_Period(Y_Rowid                         IN OUT NOCOPY VARCHAR2,
                        Y_Period_Set_Name                      VARCHAR2,
                        Y_Period_Name                          VARCHAR2,
                        Y_Last_Update_Date                     DATE,
                        Y_Last_Updated_By                      NUMBER,
                        Y_Start_Date                           DATE,
                        Y_End_Date                             DATE,
                        Y_Period_Type                          VARCHAR2,
                        Y_Period_Year                          NUMBER,
                        Y_Period_Num                           NUMBER,
                        Y_Quarter_Num                          NUMBER,
                        Y_Entered_Period_Name                  VARCHAR2,
                        Y_Last_Update_Login                    NUMBER,
                        Y_Description                          VARCHAR2,
                        Y_Attribute1                           VARCHAR2,
                        Y_Attribute2                           VARCHAR2,
                        Y_Attribute3                           VARCHAR2,
                        Y_Attribute4                           VARCHAR2,
                        Y_Attribute5                           VARCHAR2,
                        Y_Attribute6                           VARCHAR2,
                        Y_Attribute7                           VARCHAR2,
                        Y_Attribute8                           VARCHAR2,
                        Y_Context                              VARCHAR2,
                        Y_Adjustment_Period_Flag               VARCHAR2
                        ) IS

  CURSOR current_period IS
  SELECT start_date,
         end_date,
         period_type,
         period_year,
         period_num,
         quarter_num,
         entered_period_name,
         adjustment_period_flag,
         rowid
  FROM gl_periods
  WHERE period_set_name = Y_Period_Set_Name
    AND period_name = Y_Period_Name;

  CURSOR check_period_num IS
       SELECT number_per_fiscal_year
       FROM   GL_PERIOD_TYPES
       WHERE  period_type = Y_Period_Type;

  v_period_used_flag            VARCHAR2(1);
  old_start_date                DATE;
  old_end_date                  DATE;
  old_period_type               VARCHAR2(15);
  old_period_year               NUMBER(15);
  old_period_num                NUMBER(15);
  old_quarter_num               NUMBER(15);
  old_entered_period_name       VARCHAR2(15);
  old_adjustment_period_flag    VARCHAR2(1);
  v_number_per_fiscal_year      NUMBER(15);

BEGIN
  -- Check if the fields are updateable.
  OPEN current_period;
  FETCH current_period INTO old_start_date,
                            old_end_date,
                            old_period_type,
                            old_period_year,
                            old_period_num,
                            old_quarter_num,
                            old_entered_period_name,
                            old_adjustment_period_flag,
                            Y_Rowid;
  CLOSE current_period;

  -- Check if the period has been used. If the period has been used,
  -- the period year, quarter number, period number, start date,
  -- end date, entered period name, and the adjustment flag fields
  -- cannot be updated.
  IF (GL_PERIODS_PKG.check_period_used(Y_Rowid)) THEN
    v_period_used_flag := 'Y';
  ELSE
    v_period_used_flag := 'N';
  END IF;

  -- If the period has been used, the period year, quarter number,
  -- period number, start date, end date, entered period name,
  -- and the adjustment flag fields cannot be updated.
  IF (v_period_used_flag = 'Y') THEN
    IF ((old_start_date <> Y_Start_Date) OR
        (old_end_date <> Y_End_Date) OR
        (old_period_type <> Y_Period_Type) OR
        (old_period_year <> Y_Period_Year) OR
        (old_period_num <> Y_Period_Num) OR
        (old_quarter_num <> Y_Quarter_Num) OR
        (old_entered_period_name <> Y_Entered_Period_Name) OR
        (old_adjustment_period_flag <> Y_Adjustment_Period_Flag)) THEN
      fnd_message.set_name('SQLGL', 'GL_CALENDAR_PERIOD_IN_USE');
      app_exception.raise_exception;
    END IF;
  END IF;

  -- Cannot update the period type.
  IF (old_period_type <> Y_Period_Type) THEN
    fnd_message.set_name('SQLGL', 'GL_API_UPDATE_NOT_ALLOWED');
    fnd_message.set_token('ATTRIBUTE', 'UserPeriodType');
    app_exception.raise_exception;
  END IF;

  -- Check Unique Combination.
  GL_PERIODS_PKG.check_unique_num(calendar_name => Y_Period_Set_Name,
                                  period_type   => Y_Period_Type,
                                  period_year   => Y_Period_Year,
                                  period_num    => Y_Period_Num,
                                  row_id        => Y_Rowid);

  -- Check if Period_Num is between 1 and the number of periods per year for the
  -- period type.
  OPEN check_period_num;
  FETCH check_period_num INTO v_number_per_fiscal_year;

  IF check_period_num%NOTFOUND THEN
    fnd_message.set_name('SQLGL', 'GL_API_VALUE_NOT_EXIST');
    fnd_message.set_token('VALUE', Y_Period_Type);
    fnd_message.set_token('ATTRIBUTE', 'PeriodType');
    app_exception.raise_exception;
  ELSE
    CLOSE check_period_num;
  END IF;

  IF (Y_Period_Num < 1 OR Y_Period_Num > v_number_per_fiscal_year) THEN
    fnd_message.set_name('SQLGL', 'GL_PERIOD_NUMBER_LESS_THAN_MAX');
    fnd_message.set_token('MAX_NUM', v_number_per_fiscal_year);
    app_exception.raise_exception;
  END IF;

  -- Check that the Entered Period Name does not contain any spaces.
  IF (INSTR(Y_Entered_Period_Name,' ') <> 0) THEN
    fnd_message.set_name('SQLGL', 'GL_CALENDAR_NAME_NO_SPACES');
    app_exception.raise_exception;
  END IF;

  IF (instr(Y_period_name, '''') <> 0) THEN
    fnd_message.set_name('SQLGL', 'GL_CALENDAR_PERIOD_WITH_QUOTE');
    app_exception.raise_exception;
  END IF;

  IF (instr(Y_entered_period_name, '''') <> 0) THEN
    fnd_message.set_name('SQLGL', 'GL_CALENDAR_PERIOD_WITH_QUOTE');
    app_exception.raise_exception;
  END IF;

  -- Call the forms table handler.
  GL_PERIODS_PKG.Update_Row(Y_Rowid,
                            Y_Period_Set_Name,
                            Y_Period_Name,
                            Y_Last_Update_Date,
                            Y_Last_Updated_By,
                            Y_Start_Date,
                            Y_End_Date,
                            Y_Period_Type,
                            Y_Period_Year,
                            Y_Period_Num,
                            Y_Quarter_Num,
                            Y_Entered_Period_Name,
                            Y_Last_Update_Login,
                            Y_Description,
                            Y_Attribute1,
                            Y_Attribute2,
                            Y_Attribute3,
                            Y_Attribute4,
                            Y_Attribute5,
                            Y_Attribute6,
                            Y_Attribute7,
                            Y_Attribute8,
                            Y_Context,
                            Y_Adjustment_Period_Flag
                            );

EXCEPTION
  WHEN app_exceptions.application_exception THEN
    RAISE;
  WHEN OTHERS THEN
    fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
    fnd_message.set_token('PROCEDURE', 'GL_PERIODS_PKG.Update_Period');
    RAISE;
END Update_Period;

END gl_periods_pkg;

/
