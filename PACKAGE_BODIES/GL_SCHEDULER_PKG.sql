--------------------------------------------------------
--  DDL for Package Body GL_SCHEDULER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_SCHEDULER_PKG" AS
/* $Header: gluschib.pls 120.2 2005/05/05 01:43:17 kvora ship $ */

FUNCTION  create_schedule( sched_name       IN VARCHAR2,
			   calendar_name    IN VARCHAR2,
                           period_type_name IN VARCHAR2,
			   run_day	    IN NUMBER,
	                   run_time         IN VARCHAR2,
	                   create_flag	    IN BOOLEAN )
RETURN NUMBER IS
	  result_code     NUMBER;
	  period_name	  VARCHAR2(15);
	  gl_period_type  VARCHAR2(15);
	  start_date	  DATE;
	  end_date	  DATE;
          aol_start_date  DATE;
	  aol_end_date    DATE;
	  temp            VARCHAR2(100);
          conc_period     VARCHAR2(20);
          conc_disj       VARCHAR2(20);
	  curr_seq_val    VARCHAR2(15);
	  table_name	  VARCHAR2(30);
          msgbuf          VARCHAR2(2000);
          lang_code	  VARCHAR2(4);

	  CURSOR period_cursor ( p_period_set_name IN VARCHAR2,
		                 p_period_type     IN VARCHAR2 ) IS
		SELECT	PER.period_name,
			PER.start_date,
			PER.end_date
		FROM 	gl_periods PER
		WHERE	PER.period_set_name = p_period_set_name
		AND	PER.period_type = p_period_type
		AND     TRUNC( PER.end_date ) >= TRUNC( SYSDATE )
		AND     PER.adjustment_period_flag = 'N';

BEGIN
        -- initialize period type for further use in the routine
        gl_period_type := period_type_name;

        -- initialize language code for the user environment
        SELECT userenv( 'LANG' )
        INTO   lang_code
        FROM   sys.dual;

        -- initialize message buffer to hold the description which
        -- will be used while registering periods, disjunctions and classes.
        msgbuf := fnd_message.get_string( 'SQLGL', 'GL_SCH_DESC_MESSAGE' );
        msgbuf := SUBSTRB( msgbuf, 1, 80 );

	-- if create_flag is TRUE, then
	-- register the concurrent release class, if it doesn't exist.
	-- if it exists, exit with error.
	-- if create_flag is FALSE, then don't register the class.

	IF create_flag = TRUE THEN
	  IF FNDCP_SCH.Class_Exists( 'SQLGL', sched_name ) = TRUE
          THEN
	    RETURN (-1);
	  --  -1 = a schedule by this name already exists
	  ELSE
	    FNDCP_SCH.Class( 'SQLGL', sched_name, sched_name,
		             msgbuf, lang_code  );
	    FNDCP_SCH.Set_Class_Resub( 'SQLGL', sched_name, 1, 'SMART',
                                       'START');
	    -- Set_Class_Resub sets the resubmission parameters for the
            -- schedule. When it is called with the 'SMART' mode, the
            -- scheduler detects the start time of the next period and
            -- schedules the spawned request accordingly.

	  END IF;
	END IF;

	-- open cursor;
	OPEN period_cursor( calendar_name, gl_period_type );

	LOOP

	  -- fetch rows;
	  FETCH period_cursor INTO period_name, start_date, end_date;
	  EXIT WHEN period_cursor%NOTFOUND;

	  -- determine start date, time and stop date, time
          aol_start_date := start_date + ( run_day - 1 );
	  IF aol_start_date > end_date THEN
	    aol_start_date := end_date;
	  END IF;

	  temp := CONCAT( TO_CHAR( aol_start_date, 'YYYY/MM/DD' ), run_time);
	  aol_start_date := TO_DATE( temp, 'YYYY/MM/DD HH24:MI:SS' );

	  -- add 12 hours to the start date to determine the end time
	  aol_end_date := aol_start_date + 0.5;

	  -- select unique number from sequence to name the new period and
	  -- the disjunction associated with it
	  SELECT TO_CHAR( gl_concurrent_schedules_s.NEXTVAL )
	  INTO   curr_seq_val
	  FROM   SYS.dual;

	  -- register new concurrent release period
	  conc_period := CONCAT( curr_seq_val, '_P' );
	  IF FNDCP_SCH.Period_Exists( 'SQLGL', conc_period ) = TRUE THEN
	    CLOSE period_cursor;
	    RETURN( -2 );
	    -- -2 : period already exists
          ELSE
	    FNDCP_SCH.Period( 'SQLGL', conc_period, conc_period,
                              msgbuf, 'M',
                              999,
                              aol_start_date,
                              aol_end_date,
                              lang_code );
	  END IF;

          -- register new concurrent release disjunction
	  conc_disj := CONCAT( curr_seq_val, '_D' );

	  IF FNDCP_SCH.Disjunction_Exists( 'SQLGL', conc_disj ) = TRUE THEN
	    CLOSE period_cursor;
	    RETURN( -3 );
	    -- -3 : disjunction already exists
	  ELSE
	    FNDCP_SCH.Disjunction( 'SQLGL', conc_disj, conc_disj,
                                   msgbuf,
                                   lang_code );
          END IF;

          -- add newly created period to newly created disjunction
          IF FNDCP_SCH.Disj_Member_Exists( 'SQLGL', conc_disj,
                                           'SQLGL', conc_period,
                                           'P' ) = TRUE THEN
            CLOSE period_cursor;
	    RETURN( -4 );
	    -- -4 : period already exists in disjunction
	  ELSE
            FNDCP_SCH.Disj_Member_P( 'SQLGL', conc_disj,
                                     'SQLGL', conc_period,
                                     'N' );
          END IF;

          -- add newly created disjunction to the class
          IF FNDCP_SCH.Class_Member_Exists( 'SQLGL', sched_name,
                                            'SQLGL', conc_disj ) = TRUE
          THEN
            CLOSE period_cursor;
            RETURN( -5 );
	    -- -5 : disjunction already exists in class
          ELSE
            FNDCP_SCH.Class_Member( 'SQLGL', sched_name,
                                    'SQLGL', conc_disj );
          END IF;

        END LOOP;
        CLOSE period_cursor;
        FNDCP_SCH.Commit_Changes;
	RETURN( 0 );

EXCEPTION

	WHEN NO_DATA_FOUND THEN
	  RETURN ( -6 );
	  -- -6 : period type doesn't exist

END create_schedule;


FUNCTION cleanup_schedule( sched_name  IN VARCHAR2 )
RETURN NUMBER IS

	rel_class_id	NUMBER;
	disj_id		NUMBER;
	disj_name       VARCHAR2(20);
	per_name        VARCHAR2(20);
	table_name	VARCHAR2(30);
	return_code	NUMBER;
	my_rowid1	ROWID;
	my_rowid2	ROWID;
	NO_UPDATE	EXCEPTION;

	-- select members of the class
	CURSOR disj_cursor( p_class_id IN NUMBER ) IS
	SELECT DISJ.disjunction_id, DISJ.disjunction_name, DISJ.rowid
	FROM   fnd_conc_release_disjs DISJ,
               fnd_conc_rel_conj_members MEMB
	WHERE  DISJ.application_id = 101
	AND    MEMB.class_application_id = 101
	AND    MEMB.release_class_id = p_class_id
	AND    MEMB.disjunction_application_id = 101
	AND    MEMB.disjunction_id = DISJ.disjunction_id;


	-- select members of the disjunction
	CURSOR period_cursor( p_disj_id IN NUMBER ) IS
	SELECT PER.concurrent_period_name, PER.rowid
	FROM   fnd_conc_release_periods PER,
	       fnd_conc_rel_disj_members MEMB
	WHERE  PER.application_id = 101
	AND    MEMB.disjunction_application_id = 101
	AND    MEMB.disjunction_id = p_disj_id
	AND    MEMB.period_or_state_flag = 'P'
	AND    MEMB.period_application_id = 101
	AND    MEMB.period_id = PER.concurrent_period_id;

BEGIN
	-- select class_id given class name

	return_code := -1;
	-- -1 : schedule does not exist
        -- set return_code to -1 for no_data_found exception
        -- if the select statement succeeds, reset return_code to 0
	-- to continue normal processing.
	SELECT CLS.release_class_id
	INTO   rel_class_id
	FROM   fnd_conc_release_classes CLS
	WHERE  CLS.application_id = 101
	AND    CLS.release_class_name = sched_name;

	return_code := 0;

	-- open cursor to retrieve members of the class
	OPEN disj_cursor( rel_class_id );

	LOOP
	  FETCH disj_cursor INTO disj_id, disj_name, my_rowid1;
	  EXIT WHEN disj_cursor%NOTFOUND;

	  -- open cursor to retrieve periods of the disjunction
	  OPEN period_cursor( disj_id );

	  LOOP
	    FETCH period_cursor INTO per_name, my_rowid2;
	    EXIT WHEN period_cursor%NOTFOUND;

	    -- remove member period from the disjunction
	    FNDCP_SCH.Disj_Dismember( 'SQLGL', disj_name,
	                              'SQLGL', per_name, 'P' );

	    -- disable member period of the disjunction
--	    UPDATE fnd_conc_release_periods PER
--	    SET    PER.enabled_flag = 'N'
--	    WHERE  PER.rowid = my_rowid2;

--	    IF ( SQL%NOTFOUND ) THEN
	      -- -2 : Update failed on fnd_conc_release_periods
--	      return_code := -2;
--	      RAISE NO_UPDATE;
--	    END IF;

	  END LOOP;
	  CLOSE period_cursor;

	-- remove member disjunction from the class
	FNDCP_SCH.Class_Dismember( 'SQLGL', sched_name,
	                           'SQLGL', disj_name );

	-- disable member disjunction of the class
--	UPDATE fnd_conc_release_disjs DIS
--	SET    DIS.enabled_flag = 'N'
--	WHERE  DIS.rowid = my_rowid1;

--	IF ( SQL%NOTFOUND ) THEN
	  -- -3 : Update failed on fnd_conc_release_disjs
--	  return_code := -3;
--	  RAISE NO_UPDATE;
--	END IF;

	END LOOP;
	CLOSE disj_cursor;
        FNDCP_SCH.Commit_Changes;
	RETURN ( return_code );

EXCEPTION
	WHEN NO_DATA_FOUND THEN
	  RETURN ( return_code );

	WHEN NO_UPDATE THEN
	  RETURN ( return_code );

END cleanup_schedule;

FUNCTION update_schedules ( x_period_set_name IN VARCHAR2 )
RETURN NUMBER IS
    l_sched_name VARCHAR2(20);
    l_per_type   VARCHAR2(15);
    l_run_day    NUMBER;
    l_run_time   VARCHAR2(15);
    ret_code     NUMBER;

    -- this cursor selects all schedules associated with the period_set_name
    -- p_period_set_name.
    CURSOR schedule_cursor ( p_period_set_name IN VARCHAR2) IS
      SELECT SCH.schedule_name,
             SCH.period_type,
             SCH.run_day,
             TO_CHAR( SCH.run_time, 'HH24:MI:SS' )
      FROM   gl_concurrent_schedules SCH
      WHERE  SCH.period_set_name = p_period_set_name;

BEGIN

  OPEN schedule_cursor( x_period_set_name );
  LOOP
    FETCH schedule_cursor INTO l_sched_name,
                               l_per_type,
                               l_run_day,
                               l_run_time;
    EXIT WHEN schedule_cursor%NOTFOUND;

    -- call cleanup_schedule( ) to prepare the schedule for update
    ret_code := gl_scheduler_pkg.cleanup_schedule( l_sched_name );
    IF ( ret_code <> 0 ) THEN
      fnd_message.set_name( 'SQLGL', 'GL_SCH_INT_ERROR' );
      UPDATE gl_concurrent_schedules SCH
      SET    SCH.enabled_flag = 'N'
      WHERE  SCH.schedule_name = l_sched_name;

      -- ** Call FND API to disable schedule here ** --
      FNDCP_SCH.Class_Disable( 'SQLGL', l_sched_name );
      FNDCP_SCH.Commit_Changes;

      CLOSE schedule_cursor;
      RETURN( -1 );
    END IF;

    -- call create_schedule( ) to update the schedule based upon the
    -- new calendar.
    ret_code := gl_scheduler_pkg.create_schedule( l_sched_name,
                                                  x_period_set_name,
                                                  l_per_type,
                                                  l_run_day,
                                                  l_run_time,
                                                  FALSE );
    IF ( ret_code <> 0 ) THEN
      fnd_message.set_name( 'SQLGL', 'GL_SCH_INT_ERROR' );
      UPDATE gl_concurrent_schedules SCH
      SET    SCH.enabled_flag = 'N'
      WHERE  SCH.schedule_name = l_sched_name;

      -- ** Call FND API to disable schedule here ** --
      FNDCP_SCH.Class_Disable( 'SQLGL', l_sched_name );
      FNDCP_SCH.Commit_Changes;

      CLOSE schedule_cursor;
      RETURN( -2 );
    END IF;
  END LOOP;
  CLOSE schedule_cursor;
  FNDCP_SCH.Commit_Changes;
  RETURN( 0 );
END update_schedules;

END gl_scheduler_pkg;

/
