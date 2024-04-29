--------------------------------------------------------
--  DDL for Package HXT_TIME_CLOCK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXT_TIME_CLOCK" AUTHID CURRENT_USER AS
/* $Header: hxttclk.pkh 120.0 2005/05/29 05:58:18 appldev noship $ */

  g_user_id	        fnd_user.user_id%TYPE := FND_GLOBAL.User_Id;
  g_user_name		fnd_user.user_name%TYPE := 'TimeClock';
  g_sysdate		DATE := trunc(SYSDATE);
  g_bus_group_id	hr_organization_units.business_group_id%TYPE :=
				FND_PROFILE.Value( 'PER_BUSINESS_GROUP_ID' );
  g_batch_err_id	hxt_errors.ppb_id%TYPE DEFAULT NULL;
  g_timecard_err_id	hxt_errors.tim_id%TYPE DEFAULT NULL;
  g_hours_worked_err_id hxt_errors.hrw_id%TYPE DEFAULT NULL;
  g_time_period_err_id  hxt_errors.ptp_id%TYPE DEFAULT NULL;
  g_error_log_error     EXCEPTION;

-----------------------------< record_time >-------------------------------
--
-- Description:
--   This API provides a means for importing time entry data into the OTM
--   system.  It will create a new OTM Timecard for a given employee/time
--   period if one does not already exist, or else add time to an employee's
--   existing OTM Timecard (only if the Timecard was not automatically
--   generated).  The API is intended to log blocks of time worked by an
--   employee and should be called repetitively to log separate blocks of
--   time.  For example, if this API were being interfaced with a mechanical
--   time clock, it would be called on each employee's PUNCH-OUT activity
--   with both the PUNCH-IN and PUNCH-OUT times being passed as parameters.
--
-- Prerequisites:
--   1.  employee_number must identify a unique (considering date effectivity)
--       person in the PER_PEOPLE_F table.
--   2.  assignment_id is currently NOT USED.  Value passed may be NULL.
--       Assignment to be used for employee will be the first applicable
--       assignment to be queried from the PER_ASSIGNMENTS_F table.
--   3.  start_time will be used as the date worked for the block of time
--       being logged.  No consideration will be given to the possibility
--       that a block of time worked may span into another day.
--   4.  If adding time data to an already existing OTM Timecard, the
--       Timecard must NOT have been generated automatically by OTM (ie,
--       HXT_TIMECARDS.AUTO_GEN_FLAG must NOT equal 'A').
--   5.  The system profile, HXT_BATCH_SIZE, defines the number of OTM
--       Timecards that will be created with like BATCH_ID.  If no BATCH_ID
--       is found with fewer than HXT_BATCH_SIZE Timecards, a new BATCH_ID
--       will be created.
--
-- In Parameters:
--   NAME               REQD   TYPE        DESCRIPTION
--   ---------------    ----   --------    --------------------------------
--   employee_number    YES    VARCHAR2    Identifies the employee for whom
--                                         time data is being logged. Verified
--                                         via query of PER_PEOPLE_F table.
--   assignment_id      NO     NUMBER      Identifies for which of the emp's
--                                         assignments the time data is being
--                                         logged. Currently NOT USED; emp's
--                                         first applicable assignment will
--                                         be queried from PER_ASSIGNMENTS_F
--                                         table. Value passed may be NULL.
--   start_time         YES    DATE        Identifies the start date and time
--                                         for the time data being logged. This
--                                         value will become the date worked
--                                         for the time data being logged.
--   end_time           YES    DATE        Identifies the stop date and time
--                                         for the time data being logged.
--
-- Post success:
--   If an OTM Timecard did not previously exist for the given employee
--   during the time period covering the start time provided, one is created.
--   Otherwise, the time data is added to the appropriate existing OTM
--   Timecard, provided that Timecard was not automatically generated.  The
--   folowing OUT parameters will be set:
--
--   NAME               TYPE        DESCRIPTION
--   ---------------    --------    ---------------------------------------
--   ret_code           NUMBER      Return code from OTM processing. Value
--                                  will be 0 to indicate success.
--
-- Post failure:
--   An OTM Timecard may or may not be created or updated depending on the
--   failure circumstance.  Errors will be logged in the table HXT_ERRORS_F
--   and will be viewable on the OTM Timecard Errors form regardless of
--   whether the Timecard was created or previously existed.  The following
--   OUT Parameters will be set to indicate the cause of the failure:
--
--   NAME               TYPE        DESCRIPTION
--   ---------------    --------    ---------------------------------------
--   ret_code           NUMBER      Return code from OTM processing. Value
--                                  will be 1 to indicate a data related
--                                  error or 2 to indicate a system error.
--   err_buf            VARCHAR2    Short description of the error that has
--                                  occurred.
--
-- Access Status:
--   Public
--
---------------------------------------------------------------------------
 PROCEDURE record_time( employee_number IN VARCHAR2,
              	       assignment_id IN NUMBER,
                       start_time IN DATE,
		       end_time IN DATE,
		       ret_code OUT NOCOPY NUMBER,
                       err_buf OUT NOCOPY VARCHAR2);

 FUNCTION log_clock_errors(i_timecard_available IN BOOLEAN,
			  i_error_text IN VARCHAR2,
			  i_error_location IN VARCHAR2,
			  i_sql_message IN VARCHAR2)RETURN NUMBER;


END HXT_TIME_CLOCK;

 

/
