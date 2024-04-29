--------------------------------------------------------
--  DDL for Package Body PA_MISC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_MISC" AS
/* $Header: PAMISCB.pls 115.1 99/07/16 15:08:02 porting ship $ */

   --- Function get_exp_cycle_start_day_code

   --- This function returns expenditure cycle start day code
   --- A NULL is returned in case of error

   FUNCTION get_exp_cycle_start_day_code RETURN NUMBER IS
    x_exp_cycle_start_day_code NUMBER;
   BEGIN

      SELECT exp_cycle_start_day_code
      INTO   x_exp_cycle_start_day_code
      FROM   pa_implementations;

      RETURN x_exp_cycle_start_day_code;
   EXCEPTION
    WHEN  OTHERS  THEN
      RETURN NULL;
   END get_exp_cycle_start_day_code;

   ----------------------------------------------------------

   --- Function get_set_of_books_id

   --- This function returns set of books id
   --- A NULL is returned in case of error

   FUNCTION get_set_of_books_id RETURN NUMBER IS
    x_set_of_books_id NUMBER;
   BEGIN

      SELECT set_of_books_id
      INTO   x_set_of_books_id
      FROM   pa_implementations;

      RETURN x_set_of_books_id;
   EXCEPTION
    WHEN  OTHERS  THEN
      RETURN NULL;
   END get_set_of_books_id;

   ----------------------------------------------------------

   --- Function get_job_id

   --- This function returns job_id
   --- A NULL is returned in case of error or no Job_id is found

   FUNCTION get_job_id (
			x_person_id      IN NUMBER,
			x_task_id        IN NUMBER,
			x_project_id     IN NUMBER,
			x_effective_date IN DATE
		       )
                       RETURN NUMBER IS
    x_job_id NUMBER := NULL;
   BEGIN

      <<task_level_override>>
      BEGIN
      ---   get the job_id from task level overrides

        SELECT job_id
        INTO   x_job_id
        FROM   pa_job_assignment_overrides pjao
        WHERE  x_person_id = pjao.person_id
        AND    x_task_id   = pjao.task_id
        AND    x_effective_date BETWEEN pjao.start_date_active
			        AND pjao.end_date_active;

      EXCEPTION
       WHEN  NO_DATA_FOUND  THEN
	  NULL;
       WHEN  OTHERS  THEN
          RETURN NULL;
      END task_level_override;

      IF x_job_id IS NULL THEN
        <<project_level_override>>
        BEGIN
        ---   get the job_id from project level overrides

          SELECT job_id
          INTO   x_job_id
          FROM   pa_job_assignment_overrides pjao
          WHERE  x_person_id   = pjao.person_id
          AND    x_project_id  = pjao.project_id
          AND    x_effective_date BETWEEN pjao.start_date_active
			          AND pjao.end_date_active;

        EXCEPTION
         WHEN  NO_DATA_FOUND  THEN
	    NULL;
         WHEN  OTHERS  THEN
            RETURN NULL;
        END project_level_override;
      END IF;

      IF x_job_id IS NULL THEN
        <<primary_job_assignment>>
        BEGIN
        ---   get the job_id from primary job assignments

          SELECT job_id
          INTO   x_job_id
          FROM   pa_implementations imp,
                 per_assignments_f asn
          WHERE  x_person_id   = asn.person_id
          AND    asn.primary_flag = 'Y'
          AND    asn.business_group_id+0 = imp.business_group_id
          AND    x_effective_date BETWEEN asn.effective_start_date
			          AND asn.effective_end_date;
 -- tsaifee 01/30/97 Bug 442419 : 0 added to business_group_id to avoid
 -- the use of the index for performance reasons.

        EXCEPTION
         WHEN  NO_DATA_FOUND  THEN
	    NULL;
         WHEN  OTHERS  THEN
            RETURN NULL;
        END primary_job_assignment;
      END IF;

      RETURN x_job_id;
   EXCEPTION
    WHEN  OTHERS  THEN
      RETURN NULL;
   END get_job_id;

   ----------------------------------------------------------

   --- Function get_week_ending_date

   --- This function returns week_ending_date
   --- A NULL is returned in case of error

   FUNCTION get_week_ending_date (
			          x_expenditure_item_date IN DATE
		                 )
                                 RETURN DATE IS
    x_week_ending_date DATE;
   BEGIN

      SELECT pa_utils.GetWeekEnding(x_expenditure_item_date)
      INTO x_week_ending_date
      FROM SYS.DUAL;
      RETURN x_week_ending_date;
   EXCEPTION
    WHEN  OTHERS  THEN
      RETURN NULL;
   END get_week_ending_date;

   ----------------------------------------------------------

   --- Function get_month_ending_date

   --- This function returns month_ending_date
   --- A NULL is returned in case of error

   FUNCTION get_month_ending_date (
			          x_expenditure_item_date IN DATE
		                 )
                                 RETURN DATE IS
    x_month_ending_date DATE;
   BEGIN

      SELECT LAST_DAY(x_expenditure_item_date)
      INTO x_month_ending_date
      FROM SYS.DUAL;
      RETURN x_month_ending_date;
   EXCEPTION
    WHEN  OTHERS  THEN
      RETURN NULL;
   END get_month_ending_date;
   ----------------------------------------------------------

   --- Function get_pa_period

   --- This function returns pa_period
   --- A NULL is returned in case of error

   FUNCTION get_pa_period (
		          x_pa_date IN DATE
	                  )
                          RETURN VARCHAR2 IS
    x_pa_period pa_periods.period_name%TYPE;
   BEGIN

      SELECT pp.period_name
      INTO x_pa_period
      FROM pa_periods pp
      WHERE x_pa_date between pp.start_date and pp.end_date;
      RETURN x_pa_period;

   EXCEPTION
    WHEN  OTHERS  THEN
      RETURN NULL;
   END get_pa_period;

   ----------------------------------------------------------

   --- Function get_gl_period

   --- This function returns gl_period
   --- A NULL is returned in case of error

   FUNCTION get_gl_period (
		          x_gl_date IN DATE
	                  )
                          RETURN VARCHAR2 IS
    x_gl_period gl_period_statuses.period_name%TYPE;
   BEGIN

      SELECT gps.period_name
      INTO x_gl_period
      FROM gl_period_statuses gps
      WHERE x_gl_date between gps.start_date and gps.end_date
      AND   gps.application_id+0 = 101
      AND   gps.adjustment_period_flag||'' <> 'Y'
      AND   gps.set_of_books_id = pa_misc.get_set_of_books_id;

      RETURN x_gl_period;

   EXCEPTION
    WHEN  OTHERS  THEN
      RETURN NULL;
   END get_gl_period;

   --- Spread Function

   FUNCTION spread_amount (
                        x_type_of_spread    IN VARCHAR2,
                        x_start_date        IN DATE,
                        x_end_date          IN DATE,
                        x_start_pa_date     IN DATE,
                        x_end_pa_date       IN DATE,
                        x_amount            IN NUMBER)
		    RETURN NUMBER
   IS
   BEGIN

      IF x_type_of_spread = 'L' THEN

	-- Linear Spread

	IF ( x_start_date <= x_start_pa_date ) AND
	   ( x_end_date   >= x_End_pa_date ) THEN

	   -- PA_PERIOD is within or identical to other period

	   RETURN  pa_currency.round_currency_amt((x_end_pa_date - x_start_pa_date + 1) * x_amount/
		     (x_end_date - x_start_date+ 1));

	ELSIF ( x_start_pa_date <= x_start_date) AND
	      ( x_end_pa_date   <= x_End_date ) THEN

	      RETURN  pa_currency.round_currency_amt(( x_end_pa_date - x_start_date+ 1) * x_amount /
		     (x_end_date - x_start_date + 1));

	ELSIF ( x_start_pa_date >= x_start_date) AND
	      ( x_end_pa_date   >= x_End_date ) THEN

	      RETURN  pa_currency.round_currency_amt(( x_end_date - x_start_pa_date + 1) * x_amount /
		     (x_end_date - x_start_date + 1));

	ELSIF ( x_start_pa_date <= x_start_date ) AND
	      ( x_end_pa_date   >= x_End_date ) THEN

	      -- PA_PERIOD bigger or identical to other period

	      RETURN  pa_currency.round_currency_amt(x_amount);

	ELSIF ( x_end_pa_date   <= x_start_date ) OR
	      ( x_start_pa_Date >= x_end_date )   OR
	      ( x_start_pa_date  = x_end_pa_date )OR
	      ( x_start_date = x_end_date ) THEN

	      -- Non Overlapping PA period and amount periods
	      -- OR Zero Days PA period

	      RETURN 0;

	END IF;

      END IF;

      RETURN 0;
   EXCEPTION
    WHEN  OTHERS  THEN
      RETURN NULL;
   END spread_amount;

END PA_MISC;

/
