--------------------------------------------------------
--  DDL for Package Body PSP_GENERAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_GENERAL" AS
/* $Header: PSPGENEB.pls 120.13.12010000.4 2008/12/04 08:56:28 amakrish ship $  */
g_ws_option	VARCHAR2(1);

FUNCTION good_time_format ( p_time IN VARCHAR2 ) RETURN BOOLEAN IS
--
BEGIN
  --
  IF p_time IS NOT NULL THEN
    --
    IF NOT (SUBSTR(p_time,1,2) BETWEEN '00' AND '23' AND
            SUBSTR(p_time,4,2) BETWEEN '00' AND '59' AND
            SUBSTR(p_time,3,1) = ':' AND
            LENGTH(p_time) = 5) THEN
      RETURN FALSE;
    ELSE
      RETURN TRUE;
    END IF;
    --
  ELSE
    RETURN FALSE;
  END IF;
  --
EXCEPTION
  --
  WHEN OTHERS THEN
    RETURN FALSE;
  --
END good_time_format;

PROCEDURE calc_sch_based_dur ( p_days_or_hours IN VARCHAR2,
                               p_date_start    IN DATE,
                               p_date_end      IN DATE,
                               p_time_start    IN VARCHAR2,
                               p_time_end      IN VARCHAR2,
                               p_assignment_id IN NUMBER,
                               p_duration      IN OUT NOCOPY NUMBER
                             ) IS
  --
  p_start_duration  NUMBER;
  p_end_duration    NUMBER;
  l_idx             NUMBER;
  l_ref_date        DATE;
  l_first_band      BOOLEAN;
  l_day_start_time  VARCHAR2(5);
  l_day_end_time    VARCHAR2(5);
  l_start_time      VARCHAR2(5);
  l_end_time        VARCHAR2(5);
  --
  l_start_date      DATE;
  l_end_date        DATE;
  l_schedule        cac_avlblty_time_varray;
  l_schedule_source VARCHAR2(10);
  l_return_status   VARCHAR2(1);
  l_return_message  VARCHAR2(2000);
  --
  l_time_start      VARCHAR2(5);
  l_time_end        VARCHAR2(5);
  --
  e_bad_time_format EXCEPTION;
  --
BEGIN
  hr_utility.set_location('Entering psp_general.calc_sch_based_dur',10);
  p_duration := 0;
  l_time_start := p_time_start;
  l_time_end := p_time_end;
  --
  IF l_time_start IS NULL THEN
    l_time_start := '00:00';
  ELSE
    IF NOT good_time_format(l_time_start) THEN
      RAISE e_bad_time_format;
    END IF;
  END IF;
  IF l_time_end IS NULL THEN
    l_time_end := '00:00';
  ELSE
    IF NOT good_time_format(l_time_end) THEN
      RAISE e_bad_time_format;
    END IF;
  END IF;
  IF p_days_or_hours = 'D' THEN
    l_time_end := '23:59';
  END IF;
  l_start_date := TO_DATE(TO_CHAR(p_date_start,'DD-MM-YYYY')||' '||l_time_start,'DD-MM-YYYY HH24:MI');
  l_end_date := TO_DATE(TO_CHAR(p_date_end,'DD-MM-YYYY')||' '||l_time_end,'DD-MM-YYYY HH24:MI');

  hr_utility.trace('p_assignment_id '  ||p_assignment_id);
  hr_utility.trace('l_start_date '  ||l_start_date);
  hr_utility.trace('l_end_date '  ||l_end_date);
  hr_utility.trace('p_time_start '  ||p_time_start);
  hr_utility.trace('p_time_end   '  ||p_time_end);
  hr_utility.trace('p_days_or_hours   '  ||p_days_or_hours);

  --
  -- Fetch the work schedule
  --
  hr_wrk_sch_pkg.get_per_asg_schedule
  ( p_person_assignment_id => p_assignment_id
  , p_period_start_date    => l_start_date
  , p_period_end_date      => l_end_date
  , p_schedule_category    => NULL
  , p_include_exceptions   => 'N'-- for bug 5102813 'Y'
  , p_busy_tentative_as    => 'FREE'
  , x_schedule_source      => l_schedule_source
  , x_schedule             => l_schedule
  , x_return_status        => l_return_status
  , x_return_message       => l_return_message
  );
  --

  hr_utility.trace('l_return_status '  ||l_return_status);
  IF l_return_status = '0' THEN
    --
    -- Calculate duration
    --
    l_idx := l_schedule.first;
    hr_utility.trace('l_idx ' || l_idx);
    hr_utility.trace('Schedule Counts ' ||l_schedule.count);
     --
    IF p_days_or_hours = 'D' THEN
      --
      l_first_band := TRUE;
      l_ref_date := NULL;
      WHILE l_idx IS NOT NULL
      LOOP
        IF l_schedule(l_idx).FREE_BUSY_TYPE IS NOT NULL THEN
          IF l_schedule(l_idx).FREE_BUSY_TYPE = 'FREE' THEN
            IF l_first_band THEN
              l_first_band := FALSE;
              l_ref_date := TRUNC(l_schedule(l_idx).START_DATE_TIME);
              p_duration := p_duration + (TRUNC(l_schedule(l_idx).END_DATE_TIME) - TRUNC(l_schedule(l_idx).START_DATE_TIME) + 1);
            ELSE -- not first time
              IF TRUNC(l_schedule(l_idx).START_DATE_TIME) = l_ref_date THEN
                p_duration := p_duration + (TRUNC(l_schedule(l_idx).END_DATE_TIME) - TRUNC(l_schedule(l_idx).START_DATE_TIME));
              ELSE
                l_ref_date := TRUNC(l_schedule(l_idx).END_DATE_TIME);
                p_duration := p_duration + (TRUNC(l_schedule(l_idx).END_DATE_TIME) - TRUNC(l_schedule(l_idx).START_DATE_TIME) + 1);
              END IF;
            END IF;
          END IF;
        END IF;
        l_idx := l_schedule(l_idx).NEXT_OBJECT_INDEX;
      END LOOP;
      --
    ELSE -- p_days_or_hours is 'H'
      --
      l_day_start_time := '00:00';
      l_day_end_time := '23:59';
      WHILE l_idx IS NOT NULL
      LOOP
        hr_utility.trace('l_schedule(l_idx).FREE_BUSY_TYPE  ' || l_schedule(l_idx).FREE_BUSY_TYPE );
        hr_utility.trace('l_schedule(l_idx).END_DATE_TIME ' || l_schedule(l_idx).END_DATE_TIME );
        hr_utility.trace('l_schedule(l_idx).START_DATE_TIME ' || l_schedule(l_idx).START_DATE_TIME );

        IF l_schedule(l_idx).FREE_BUSY_TYPE IS NOT NULL THEN
                hr_utility.trace('l_schedule(l_idx).FREE_BUSY_TYPE is not null ' || l_schedule(l_idx).FREE_BUSY_TYPE );
          IF l_schedule(l_idx).FREE_BUSY_TYPE = 'FREE' THEN
                  hr_utility.trace('l_schedule(l_idx).FREE_BUSY_TYPE  is FREE ' || l_schedule(l_idx).FREE_BUSY_TYPE );
                  hr_utility.trace('l_schedule(l_idx).END_DATE_TIME ' || l_schedule(l_idx).END_DATE_TIME );
                  hr_utility.trace('l_schedule(l_idx).START_DATE_TIME ' || l_schedule(l_idx).START_DATE_TIME );
            IF l_schedule(l_idx).END_DATE_TIME < l_schedule(l_idx).START_DATE_TIME THEN
              -- Skip this invalid slot which ends before it starts
              NULL;
            ELSE
              IF TRUNC(l_schedule(l_idx).END_DATE_TIME) > TRUNC(l_schedule(l_idx).START_DATE_TIME) THEN
                -- Start and End on different days
                --
                -- Get first day hours
                l_start_time := TO_CHAR(l_schedule(l_idx).START_DATE_TIME,'HH24:MI');
                hr_utility.trace('l_start_time ' || l_start_time);

                SELECT p_duration + (((SUBSTR(l_day_end_time,1,2)*60 + SUBSTR(l_day_end_time,4,2)) -
                                      (SUBSTR(l_start_time,1,2)*60 + SUBSTR(l_start_time,4,2)))/60)
                INTO p_duration
                FROM DUAL;
             --  hr_utility.trace('p_start_duration ' || p_start_duration);
                hr_utility.trace('Start p_duration ' || p_duration);

                --
                -- Get last day hours
                l_end_time := TO_CHAR(l_schedule(l_idx).END_DATE_TIME,'HH24:MI');
                hr_utility.trace('l_end_time ' || l_end_time);
                SELECT p_duration + (((SUBSTR(l_end_time,1,2)*60 + SUBSTR(l_end_time,4,2)) -
                                      (SUBSTR(l_day_start_time,1,2)*60 + SUBSTR(l_day_start_time,4,2)) + 1)/60)
                INTO p_duration
                FROM DUAL;
                --hr_utility.trace('p_end_duration ' || p_end_duration);
                hr_utility.trace('End p_duration ' || p_duration);
                --
                -- Get between full day hours
                SELECT p_duration + ((TRUNC(l_schedule(l_idx).END_DATE_TIME) - TRUNC(l_schedule(l_idx).START_DATE_TIME) - 1) * 24)
                INTO p_duration
                FROM DUAL;
              ELSE
                -- Start and End on same day
                l_start_time := TO_CHAR(l_schedule(l_idx).START_DATE_TIME,'HH24:MI');
                l_end_time := TO_CHAR(l_schedule(l_idx).END_DATE_TIME,'HH24:MI');

                hr_utility.trace('l_start_time ' || l_start_time);
                hr_utility.trace('l_end_time ' || l_end_time);

                SELECT p_duration + (((SUBSTR(l_end_time,1,2)*60 + SUBSTR(l_end_time,4,2)) -
                                      (SUBSTR(l_start_time,1,2)*60 + SUBSTR(l_start_time,4,2)))/60)
                INTO p_duration
                FROM DUAL;
                hr_utility.trace('duration l_idx '||l_idx||' ' ||p_duration);

              END IF;
            END IF;
          END IF;
        END IF;
        l_idx := l_schedule(l_idx).NEXT_OBJECT_INDEX;
      END LOOP;
      hr_utility.trace('duration ' ||p_duration);

      p_duration := ROUND(p_duration,2);
      --
    END IF;
  END IF;
  --
  hr_utility.set_location('Leaving psp_general.calc_sch_based_dur',20);
EXCEPTION
  --
  WHEN e_bad_time_format THEN
    hr_utility.set_location('Leaving psp_general.calc_sch_based_dur',30);
    hr_utility.set_location(SQLERRM,35);
    RAISE;
  WHEN OTHERS THEN
    hr_utility.set_location('Leaving psp_general.calc_sch_based_dur',40);
    hr_utility.set_location(SQLERRM,45);
    RAISE;
END calc_sch_based_dur;

FUNCTION p_org_exists(organization_id1 IN NUMBER)
RETURN NUMBER IS
   l_dummy   CHAR(1);
BEGIN
   BEGIN
      SELECT 'x'
      INTO l_dummy
      FROM HR_ORGANIZATION_UNITS
      WHERE organization_id = organization_id1 AND
            ROWNUM = 1;
      RETURN(0);
   EXCEPTION
      WHEN OTHERS THEN
         RETURN(-1);
   END;
END;
---

  PROCEDURE get_annual_salary (p_assignment_id in number,
                               p_session_date  in date,
                               p_annual_salary out NOCOPY number) is
/*****	Modified teh following cursor for R12 peformance fixes (bug 4507892)
   CURSOR get_salary is
   select ppp.proposed_salary,
          ppb.pay_basis
   from   per_pay_proposals ppp,
          per_assignments_f paf,
          per_pay_bases     ppb
   where  paf.assignment_id = p_assignment_id and
          ppp.assignment_id = paf.assignment_id and
          paf.pay_basis_id  = ppb.pay_basis_id and
          ppb.pay_basis in ('ANNUAL', 'MONTHLY') and
          ppp.change_date = (select max(change_date) from per_pay_proposals ppp1
                          where ppp1.assignment_id = paf.assignment_id and
                          ppp1.approved = 'Y' and ppp1.change_date <= p_session_date);
	End of comment for R12 performance fixes (bug 4507892)	*****/

--	New cursor definition for bug fix 4507892
CURSOR	get_salary IS
SELECT	ppp.proposed_salary,
	ppb.pay_basis
FROM	per_pay_proposals ppp,
	per_assignments_f paf,
	per_pay_bases	   ppb
WHERE	paf.assignment_id = p_assignment_id
AND	 ppp.assignment_id = paf.assignment_id
AND	 paf.pay_basis_id  = ppb.pay_basis_id
AND	 ppb.pay_basis IN ('ANNUAL', 'MONTHLY')
AND	 ppp.change_date =	(SELECT	MAX(change_date)
				FROM	per_pay_proposals ppp1
				WHERE	ppp1.assignment_id = p_assignment_id
				AND	ppp1.approved = 'Y'
				AND	ppp1.change_date <= p_session_date);


   l_annual_salary  number(22) := 0;
   l_pay_basis      varchar2(30)	:= NULL;
   BEGIN
     OPEN get_salary;
     fetch get_salary into l_annual_salary, l_pay_basis;

     if get_salary%NOTFOUND then
        p_annual_salary := 0;
     else
       begin
         if l_pay_basis = 'ANNUAL' then
            p_annual_salary	:= l_annual_salary;
         elsif
            l_pay_basis = 'MONTHLY' then
              l_annual_salary 	:= l_annual_salary * 12;
              p_annual_salary	:= l_annual_salary;
         else
              p_annual_salary	:= 0;
         end if;
        end;
     end if;

     EXCEPTION
       WHEN NO_DATA_FOUND then
            p_annual_salary	:= 0;
       WHEN TOO_MANY_ROWS then
            p_annual_salary	:= 0;
       WHEN OTHERS then
            p_annual_salary	:= 0;
     END;
PROCEDURE get_gl_ccid  (p_payroll_id      in number,
                        p_set_of_books_id in number,
		  	p_cost_keyflex_id in number,
                        x_gl_ccid out NOCOPY number) is
CURSOR get_segment_maps_csr is
SELECT gl_account_segment,payroll_cost_segment
FROM   PAY_PAYROLL_GL_FLEX_MAPS
WHERE  payroll_id 	  = p_payroll_id and
       gl_set_of_books_id = p_set_of_books_id;

CURSOR get_chart_of_accounts_csr IS
SELECT chart_of_accounts_id
  FROM GL_SETS_OF_BOOKS
WHERE  set_of_books_id = p_set_of_books_id;

l_chart_of_accounts_id 	number	:= 0;
l_gl_segment		varchar2(30)	:= NULL;
l_cost_segment		varchar2(30)	:= NULL;
l_sql_string		varchar2(2000)	:= NULL;
l_cursor		INTEGER;
l_cost_value		varchar2(22);
l_gl_ccid		number(15);
l_rows			INTEGER;

BEGIN
  open get_segment_maps_csr;
  LOOP
    fetch get_segment_maps_csr into l_gl_segment, l_cost_segment;
    EXIT WHEN get_segment_maps_csr%NOTFOUND;
   --DBMS_OUTPUT.PUT_LINE(' DEBUG  -- l_cost_segment ' || l_cost_segment);
   --DBMS_OUTPUT.PUT_LINE(' DEBUG  -- l_gl_segment ' || l_gl_segment);
    l_rows		:= 0;
    l_cost_value	:= 0;
   --DBMS_OUTPUT.PUT_LINE(' DEBUG  -- p_cost_keyflex_id ' || to_char(p_cost_keyflex_id));
    l_cursor	:= dbms_sql.open_cursor;
    dbms_sql.parse(l_cursor,'select ' || l_cost_segment || ' from pay_cost_allocation_keyflex where  cost_allocation_keyflex_id = :p_cost_keyflex_id',dbms_sql.V7);
    dbms_sql.bind_variable(l_cursor,'p_cost_keyflex_id',p_cost_keyflex_id);
    dbms_sql.define_column(l_cursor,1,l_cost_value,22);
    l_rows	:= dbms_sql.execute_and_fetch(l_cursor);
    dbms_sql.column_value(l_cursor,1,l_cost_value);
   --DBMS_OUTPUT.PUT_LINE(' DEBUG  -- l_cost_value ' || l_cost_value);
    dbms_sql.close_cursor(l_cursor);

    l_sql_string	:= l_sql_string || ' and ' || l_gl_segment || ' = ''' || l_cost_value || '''';

   --DBMS_OUTPUT.PUT_LINE(' DEBUG  -- l_sql_string ' || l_sql_string);
  END LOOP;
  --dbms_output.put_line('DEBUG.....Crossed First Loop');
  OPEN get_chart_of_accounts_csr;
  fetch get_chart_of_accounts_csr into l_chart_of_accounts_id;
  --dbms_output.put_line('DEBUG.....Crossed Fetch');
  if get_chart_of_accounts_csr%NOTFOUND then
  --dbms_output.put_line('DEBUG.....NotFound');
     l_chart_of_accounts_id	:= 0;
  end if;
  --dbms_output.put_line('DEBUG.....NotFound');
  --dbms_output.put_line('DEBUG.....Chart of accounts ' || to_char(l_chart_of_accounts_id));
  --dbms_output.put_line('DEBUG.....Set of Books ' || to_char(p_set_of_books_id));
 if l_chart_of_accounts_id <> 0 then
     l_cursor	:=dbms_sql.open_cursor;
     dbms_sql.parse(l_cursor,'select code_combination_id from gl_code_combinations where chart_of_accounts_id = :p_chart_of_accounts_id ' || l_sql_string,dbms_sql.V7);
     dbms_sql.bind_variable(l_cursor,'p_chart_of_accounts_id',l_chart_of_accounts_id);
     dbms_sql.define_column(l_cursor,1,l_gl_ccid);
     l_rows	:= dbms_sql.execute_and_fetch(l_cursor);
     dbms_sql.column_value(l_cursor,1,l_gl_ccid);
     if l_gl_ccid > 0 then
        x_gl_ccid	:= l_gl_ccid;
     else
        x_gl_ccid	:= 0;
     end if;

   --DBMS_OUTPUT.PUT_LINE(' DEBUG  -- l_gl_ccid ' || to_char(l_gl_ccid));
     dbms_sql.close_cursor(l_cursor);
   end if;

END;

FUNCTION business_days (low_date date,
                        high_date date,
			p_assignment_id NUMBER DEFAULT NULL) return number is
l_no_of_days      integer := 0;
curr_date date    := trunc(low_date);
--	Introduced the following cursor for bug fix 5077073
/*Bug 5557724: to_char(some_date,'D') returns a number indicating the weekday. However, for a given date, this number
returned varies with NLS_TERRITORY. So replaced it with to_char(some_date,'DY') that gives the abbreviated day. */
CURSOR	business_days_cur (p_low_date	IN	DATE,
			p_high_date	IN	DATE) IS
SELECT  SUM(DECODE(TO_CHAR(p_low_date+ (ROWNUM-1), 'DY', 'nls_date_language=english'), 'SUN', 0, 'SAT', 0, 1))
FROM    DUAL
CONNECT BY 1=1
AND	ROWNUM <= (p_high_date + 1) - p_low_date;

-- Added the following cursor to find whether a particular day is a working day or not when
-- working schedules is not enabled, Bug 6779790

CURSOR	business_days2_cur (p_date	IN	DATE) IS
SELECT  DECODE(TO_CHAR(p_date+ (ROWNUM-1), 'DY', 'nls_date_language=english'), 'SUN', 0, 'SAT', 0, 1)
FROM    DUAL;

--	Introduced the following cursors for work schedules enh.
l_schedule_source	VARCHAR2(100);
l_schedule		VARCHAR2(100);
l_business_day		NUMBER;
l_return_status		NUMBER;
l_return_message	VARCHAR2(100);
l_wrk_sch_exists	NUMBER;
l_business_group_id	NUMBER(15);
l_legislation_code	VARCHAR2(10);
l_ws_table_name		VARCHAR2(100);
l_work_schedule		VARCHAR2(100);
l_effective_start_date	DATE;
l_effective_end_date	DATE;
l_no_of_days_in_chunk	NUMBER;

CURSOR	business_days_ws_cur (p_low_date	IN	DATE,
				p_high_date	IN	DATE) IS
SELECT  SUM(DECODE(hruserdt.get_table_value(l_business_group_id, l_ws_table_name, l_work_schedule,
TO_CHAR(p_low_date+ (ROWNUM-1), 'DY', 'nls_date_language=english'), p_low_date+ (ROWNUM-1)), 0, 0, 1))
FROM    DUAL
CONNECT BY 1=1
AND	ROWNUM <= (p_high_date + 1) - p_low_date;

CURSOR	workschedule_config_cur IS
SELECT	pcv_information1 work_schedules
FROM	pqp_configuration_values
WHERE	pcv_information_category = 'PSP_ENABLE_WORK_SCHEDULES'
AND	legislation_code IS NULL
AND	NVL(business_group_id, l_business_group_id) = l_business_group_id;

CURSOR	business_group_id_cur IS
SELECT	business_group_id
FROM	per_assignments_f
WHERE	assignment_id = p_assignment_id
AND	effective_start_date <= high_date
AND	effective_end_date >= low_date;

CURSOR	legislation_code_cur IS
SELECT	legislation_code
FROM	per_business_groups_perf
WHERE	business_group_id = l_business_group_id;

CURSOR	wrk_sch_exists_cur IS
SELECT	put.user_table_name,
	puc.user_column_name,
	GREATEST(assign.effective_start_date, low_date),
	LEAST(assign.effective_end_date, high_date)
FROM	pay_user_tables PUT,
	pay_user_columns PUC,
	hr_soft_coding_keyflex target,
	per_all_assignments_f  ASSIGN
WHERE	PUC.USER_COLUMN_ID (+) = target.SEGMENT4
AND	high_date >= ASSIGN.effective_start_date
AND	low_date <= ASSIGN.effective_end_date
AND	ASSIGN.assignment_id = p_assignment_id
AND	target.soft_coding_keyflex_id = ASSIGN.soft_coding_keyflex_id
AND	target.enabled_flag = 'Y'
AND	target.id_flex_num = (SELECT	rule_mode
				FROM	pay_legislation_rules
				WHERE	legislation_code = l_legislation_code
				AND	rule_type = 'S')
AND	NVL(PUC.business_group_id, l_business_group_id) = l_business_group_id
AND	NVL(PUC.legislation_code, l_legislation_code) = l_legislation_code
AND	PUC.user_table_id = PUT.user_table_id (+)
AND	(	PUT.user_table_id IS NULL
	OR	PUT.user_table_name = (SELECT	put.user_table_name
			FROM	hr_organization_information hoi,
				pay_user_tables put
			WHERE	hoi.organization_id = l_business_group_id
			AND	hoi.org_information_context ='Work Schedule'
			AND	hoi.org_information1 = put.user_table_id));
--	end of changes for work schedules enh.

begin
/*****	Commented for bug fix 5077073
  while curr_date <= trunc(high_date) loop
    if to_char(curr_date, 'D') NOT IN (1, 7) then
      l_no_of_days := l_no_of_days + 1;
    end if;
    curr_date := curr_date + 1;
  end loop;
	End of comment for bug fix 5077073	*****/


	IF (high_date < low_date) THEN
		RETURN 0;
	END IF;

       OPEN business_group_id_cur;
	FETCH business_group_id_cur INTO l_business_group_id;

	OPEN legislation_code_cur;
	FETCH legislation_code_cur INTO l_legislation_code;
	CLOSE legislation_code_cur;

	IF (p_assignment_id IS NULL) THEN
		g_ws_option := NULL;
	END IF;

	IF (g_ws_option IS NULL) THEN
		OPEN workschedule_config_cur;
		FETCH workschedule_config_cur INTO g_ws_option;
		CLOSE workschedule_config_cur;
	END IF;

	IF (g_ws_option = 'Y') THEN
		calc_sch_based_dur('D', low_date, high_date, NULL, NULL, p_assignment_id, l_no_of_days);
		/*curr_date := low_date;
		l_no_of_days := 0;
		LOOP
			EXIT WHEN curr_date > high_date;
			l_business_day := pay_core_ff_udfs.calculate_actual_hours_worked
				(NULL,
				p_assignment_id,
				l_business_group_id,
				NULL,
				curr_date,
				curr_date,
				curr_date,
				NULL,
				NULL,
				NULL,
				NULL,
				l_schedule_source,
				l_schedule,
				l_return_status,
				l_return_message,
				'D');

			IF (l_business_day > 0) THEN
				l_no_of_days := l_no_of_days + 1;
			END IF;
			curr_date := curr_date + 1;
		END LOOP;*/

		IF (l_no_of_days = 0) THEN
			OPEN wrk_sch_exists_cur;
			LOOP
				FETCH wrk_sch_exists_cur INTO l_ws_table_name, l_work_schedule, l_effective_start_date, l_effective_end_date;
				EXIT WHEN wrk_sch_exists_cur%NOTFOUND;

				IF (l_work_schedule IS NULL) THEN
					OPEN business_days_cur(l_effective_start_date, l_effective_end_date);
					FETCH business_days_cur INTO l_no_of_days_in_chunk;
					CLOSE business_days_cur;
				ELSE
					OPEN business_days_ws_cur(l_effective_start_date, l_effective_end_date);
					FETCH business_days_ws_cur INTO l_no_of_days_in_chunk;
					CLOSE business_days_ws_cur;
				END IF;
				l_no_of_days := l_no_of_days + l_no_of_days_in_chunk;
			END LOOP;
			CLOSE wrk_sch_exists_cur;
		END IF;
	ELSE
		IF (low_date = high_date) THEN
	        	  OPEN business_days2_cur(low_date);
			  FETCH business_days2_cur INTO l_no_of_days;
			  CLOSE business_days2_cur;
		ELSE
			  OPEN business_days_cur(low_date, high_date);
			  FETCH business_days_cur INTO l_no_of_days;
			  CLOSE business_days_cur;
		END IF;
	END IF;
	CLOSE business_group_id_cur;

  return l_no_of_days;
END business_days;

FUNCTION last_working_date (last_date date  )
                        return date is
  curr_date date    := last_date;
begin
  loop
/*Bug 5557724: to_char(some_date,'D') returns a number indicating the weekday. However, for a given date, this number
returned varies with NLS_TERRITORY. So replaced it with to_char(some_date,'DY') that gives the abbreviated day. */
     if to_char(curr_date, 'DY', 'nls_date_language=english')  in ('SUN','SAT')
     then
        curr_date := curr_date - 1;
     else
        exit;
     end if;
  end loop;
  return curr_date;
end last_working_date;

FUNCTION get_gl_description(p_set_of_books_id  IN  NUMBER,
			    a_code_combination_id IN NUMBER) RETURN VARCHAR2 IS
---------------------------------------------------History-----------------------------------------------------------
--DATE		MODIFIED BY	DESCRIPTION
  --------	-----------	-----------
--02/10/99	Shu Lei		Fix Bug #819605: undefined segments.
---------------------------------------------------------------------------------------------------------------------
      t_nc                    NUMBER(3);
      t_desc                  VARCHAR2(1000);
      nc		      NUMBER;
      x_chart_of_accts	      VARCHAR2(20);

      FUNCTION t_glccid_exists(code_combination_id1 IN NUMBER,chart_of_accounts_id1 IN NUMBER)
      RETURN NUMBER IS
         t_dummy  CHAR(1);
      BEGIN
         IF code_combination_id1 IS NULL THEN
            RETURN(-1);
         END IF;
         ---
         SELECT 'x'
         INTO t_dummy
         FROM gl_code_combinations
         WHERE code_combination_id = code_combination_id1 AND
               chart_of_accounts_id = chart_of_accounts_id1 AND
               ROWNUM = 1;
         RETURN(0);
      EXCEPTION
         WHEN OTHERS THEN
            RETURN(-2);
      END;

BEGIN
      nc := find_chart_of_accts(p_set_of_books_id,x_chart_of_accts);
      IF nc = -1 THEN
         RETURN('** Chart Of Accts Failed **');
      END IF;
      ---
      t_nc := t_glccid_exists(a_code_combination_id,to_number(x_chart_of_accts));
      IF t_nc = -1 THEN
         RETURN(NULL);
      ELSIF t_nc = -2 THEN
         RETURN('**  Invalid GL CCID '||to_char(a_code_combination_id)||' :: No Such Code Exists  **');
      END IF;
      ---

      /*-------Fix bug #819605: use AOL package to obtain segment descriptions-------*/
      /*-------Note: if the output concatenated segment descriptions are truncated, modify the values in column concatenation_description_len of -----------*/
      /*-------table fnd_id_flex_segments. The column determines how long the segment descriptions FND_FLEX_KEYVAL.concated_description will take.---------*/
      IF FND_FLEX_KEYVAL.validate_ccid('SQLGL', 'GL#', x_chart_of_accts, a_code_combination_id ) THEN
         t_desc := substr(FND_FLEX_KEYVAL.concatenated_descriptions, 1, 1000);
         return(t_desc);
      END IF;
END get_gl_description;

FUNCTION find_global_suspense(p_start_date_active IN DATE, -- DEFAULT NULL,Commented for bug fix 2635110
			      p_business_group_id IN NUMBER,
			      p_set_of_books_id   IN NUMBER,
                              p_organization_account_id OUT NOCOPY NUMBER)
---   Valid return codes are
---   PROFILE_VAL_DATE_MATCHES       Profile and Value and Date matching 'G'
---   NO_PROFILE_EXISTS              No Profile
---   NO_VAL_DATE_MATCHES    Profile and Either Value/date do not match with 'G'
---   NO_GLOBAL_ACCT_EXISTS          No 'G' exists
RETURN VARCHAR2 IS
--Modified the cursor for bug 2056877,Removed nvl from end_date check.
   CURSOR global_susp_exists IS
      SELECT organization_id, organization_account_id,rownum
      FROM psp_organization_accounts
      WHERE account_type_code = 'G' AND
	    business_group_id = p_business_group_id AND
	    set_of_books_id = p_set_of_books_id AND
            (p_start_date_active IS NULL OR
             p_start_date_active BETWEEN start_date_active AND end_date_active);


   l_organization_id          NUMBER(15);
   l_count                    NUMBER(2) := 0;
   l_global_susp_acct         VARCHAR2(100);
   l_organization_account_id  NUMBER(9);
BEGIN
   p_organization_account_id := -1;
   l_global_susp_acct := psp_general.get_specific_profile('PSP_GLOBAL_SUSP_ACC_ORG');
   IF l_global_susp_acct IS NULL THEN
      -- --dbms_output.put_line('NO_PROFILE_EXISTS');
      RETURN('NO_PROFILE_EXISTS');
   END IF;
   -- --dbms_output.put_line(l_global_susp_acct);
   OPEN global_susp_exists;
      LOOP
         FETCH global_susp_exists INTO
               l_organization_id,l_organization_account_id,l_count;
         EXIT WHEN global_susp_exists%NOTFOUND;
         ---
         IF p_org_exists(l_organization_id) = 0 THEN
        	 /* Followin code is added for bug 2056877,Validating the global suspense account to be
        	    same as profile value,If it is not then returning 'NO_VAL_DATE_MATCHES' */
         	IF 	to_number(l_global_susp_acct) =	l_organization_id THEN
	     	            --dbms_output.put_line('PROFILE_VAL_DATE_MATCHES');
        	        p_organization_account_id := l_organization_account_id;
	          	RETURN('PROFILE_VAL_DATE_MATCHES');
	        ELSE
	        	RETURN('NO_VAL_DATE_MATCHES');

	        END IF;	    --Bug 2056877.
         END IF;
      END LOOP;
   CLOSE global_susp_exists;
   ---
   IF l_count = 0 THEN
      --dbms_output.put_line(l_count||'NO_GLOBAL_ACCT_EXISTS');
      RETURN('NO_GLOBAL_ACCT_EXISTS');
   END IF;
   ---
   --dbms_output.put_line('NO_VAL_DATE_MATCHES');
   RETURN('NO_VAL_DATE_MATCHES');
END;
----
FUNCTION find_chart_of_accts(p_set_of_books_id IN NUMBER,
			     p_chart_of_accts OUT NOCOPY VARCHAR2)
RETURN NUMBER
IS
   t_set_of_books_id        NUMBER(15) := p_set_of_books_id;
   t_chart_of_accounts_id   NUMBER(15) := NULL;
   CURSOR C1 (c_set_of_books_id NUMBER) IS
     SELECT chart_of_accounts_id
     FROM gl_sets_of_books
     WHERE set_of_books_id = c_set_of_books_id;
BEGIN
   ---
   OPEN C1(t_set_of_books_id);
      FETCH C1 INTO t_chart_of_accounts_id;
   CLOSE C1;
   ---
   IF t_chart_of_accounts_id IS NULL THEN
      p_chart_of_accts := NULL;
      RETURN(-1);
   END IF;
   ---
   p_chart_of_accts := to_char(t_chart_of_accounts_id);
   RETURN(0);
END;
----
PROCEDURE TRANSACTION_CHANGE_PURGEBLE IS
   v_flag pa_transaction_sources.purgeable_flag%TYPE;

BEGIN
     --  2431917: changed OLD to GOLD, introduced GOLDE
     BEGIN
      SELECT purgeable_flag INTO v_flag
      FROM pa_transaction_sources
      WHERE transaction_source = 'GOLDE'
      FOR UPDATE OF purgeable_flag ;

      IF v_flag='Y' THEN
          --v_flag :='N';
          UPDATE pa_transaction_sources
          SET   purgeable_flag = 'N' --- v_flag
          WHERE transaction_source = 'GOLDE';
          COMMIT;
      END IF;
      EXCEPTION
       WHEN NO_DATA_FOUND THEN
           NULL;
      END;

      SELECT purgeable_flag INTO v_flag
      FROM pa_transaction_sources
      WHERE transaction_source = 'GOLD'
      FOR UPDATE OF purgeable_flag ;

      IF v_flag='Y' THEN
          ---v_flag :='N';
          UPDATE pa_transaction_sources
          SET   purgeable_flag = 'N' ---v_flag
          WHERE transaction_source = 'GOLD';
          COMMIT;
      END IF;
EXCEPTION
       WHEN NO_DATA_FOUND THEN
	   NULL;

END TRANSACTION_CHANGE_PURGEBLE;

--------------- P O E T A  E F F E C T I V E  D A T E ---------------------------------
-- When GMS is installed
PROCEDURE poeta_effective_date(p_payroll_end_date IN  DATE,
                               p_project_id       IN  NUMBER,
                               p_award_id         IN  NUMBER,
                               p_task_id          IN  NUMBER,
                               p_effective_date   OUT NOCOPY DATE,
                               p_return_status    OUT NOCOPY VARCHAR2) IS
 l_project_end_date     DATE;
 l_award_end_date       DATE;
 l_completion_date      DATE;
 l_msg_id       	number(9);
 l_poeta_effective_date    DATE;
BEGIN
  ----dbms_output.put_line('starting poeta_effective_date');
  --insert_into_psp_stout( 'starting poeta_effective_date');

  SELECT  nvl(completion_date,p_payroll_end_date)
  INTO    l_project_end_date
  FROM    pa_projects_all
  WHERE   project_id = p_project_id;

  SELECT  nvl(end_date_active,p_payroll_end_date)
  INTO    l_award_end_date
  FROM    gms_awards_all   -- Bug 6908158
  WHERE   award_id = p_award_id;

  SELECT  nvl(completion_date,p_payroll_end_date)
   INTO   l_completion_date
   FROM   pa_tasks
  WHERE   task_id = p_task_id;

  SELECT least(p_payroll_end_date,l_project_end_date,l_award_end_date,l_completion_date)
  INTO l_poeta_effective_date
  FROM dual;

IF (l_poeta_effective_date  < p_payroll_end_date ) THEN
    p_effective_date :=  p_payroll_end_date  ;
  ELSE
    p_effective_date  := l_poeta_effective_date ;
  END IF;
  p_return_status := fnd_api.g_ret_sts_success;
EXCEPTION
  WHEN OTHERS THEN
     fnd_msg_pub.add_exc_msg('PSP_SUM_TRANS','POETA_EFFECTIVE_DATE');
     p_return_status := fnd_api.g_ret_sts_unexp_error;
 END poeta_effective_date;

--------------- P O E T A  E F F E C T I V E  D A T E ---------------------------------
-- When GMS is not installed
PROCEDURE poeta_effective_date(p_payroll_end_date IN  DATE,
                               p_project_id       IN  NUMBER,
                               p_task_id          IN  NUMBER,
                               p_effective_date   OUT NOCOPY DATE,
                               p_return_status    OUT NOCOPY VARCHAR2) IS
 l_project_end_date     DATE;
 l_completion_date      DATE;
 l_msg_id       	number(9);
 l_poeta_effective_date    DATE;
BEGIN
  ----dbms_output.put_line('starting poeta_effective_date');
  --insert_into_psp_stout( 'starting poeta_effective_date');

  SELECT  nvl(completion_date,p_payroll_end_date)
  INTO    l_project_end_date
  FROM    pa_projects_all
  WHERE   project_id = p_project_id;


  SELECT  nvl(completion_date,p_payroll_end_date)
   INTO   l_completion_date
   FROM   pa_tasks
  WHERE   task_id = p_task_id;

  SELECT least(p_payroll_end_date,l_project_end_date,l_completion_date)
  INTO l_poeta_effective_date
  FROM dual;

IF (l_poeta_effective_date  < p_payroll_end_date ) THEN
    p_effective_date :=  p_payroll_end_date  ;
  ELSE
    p_effective_date  := l_poeta_effective_date ;
  END IF;
  p_return_status := fnd_api.g_ret_sts_success;
EXCEPTION
  WHEN OTHERS THEN
     fnd_msg_pub.add_exc_msg('PSP_SUM_TRANS','POETA_EFFECTIVE_DATE');
     p_return_status := fnd_api.g_ret_sts_unexp_error;
 END poeta_effective_date;



 --------------- G E T  G M S  E F F E C T I V E  D A T E ---------------------------------
/**********************************************************
Created By:skotwal

Date Created By:14-SEP-2001

Purpose:
  This procedure "get_gms_effective_date" returns the effective end date of the last
  active primary assignment for the period_id passed with respect to effective date
  passed to it. For bug 1994421

Know limitations, enhancements or remarks

Change History

Who		When 		What
skotwal         14-SEP-2001     Created
lveerubh        18-OCT-2001     Bug 2039161 : Introduced the period_of_service_id check
				to ignore the new record created each time a employee is terminated
venkat          25-jun-2002     Bug 2426343: Return NULL if primary assignment was never active wrt eff date.
***************************************************************/

    PROCEDURE get_gms_effective_date(p_person_id in number, p_effective_date in out NOCOPY date)
    IS
        l_effective_date DATE;
        l_count number:= 0;

        CURSOR	active_assign_cur
        IS
        SELECT 	count(*)
        FROM 	per_all_assignments_f ainner,
		per_assignment_status_types binner
	WHERE 	ainner.person_id		=	p_person_id
	AND 	ainner.primary_flag		=	'Y'
	AND 	ainner.assignment_status_type_id=	binner.assignment_status_type_id
	AND 	binner.per_system_status	=	'ACTIVE_ASSIGN'
	AND 	p_effective_date between ainner.effective_start_date and ainner.effective_end_date
	AND 	ainner.period_of_service_id	IS NOT NULL;

    	CURSOR 	effective_date_cur
    	IS
    	SELECT  max(a.effective_end_date)
	FROM 	per_all_assignments_f a,
		per_assignment_status_types b
	WHERE 	a.person_id		     =	p_person_id
	AND 	a.primary_flag		     =	'Y'
	AND 	a.assignment_status_type_id  =	b.assignment_status_type_id
	AND 	b.per_system_status	     =	'ACTIVE_ASSIGN'
	AND	a.period_of_service_id       IS NOT NULL  -- Included for the Bug fix 2039161
	AND	(trunc(a.effective_end_date) <= trunc(p_effective_date));

    BEGIN
		OPEN  active_assign_cur;
                FETCH active_assign_cur INTO l_count;
                CLOSE active_assign_cur;

                IF (l_count = 0) THEN
--              If Assignment is not active for p_effective date then return max(effective_date) before p_effective_date
                        OPEN effective_date_cur;
                        FETCH effective_date_cur INTO l_effective_date;
                        if effective_date_cur%NOTFOUND then -- introduced for bug  2426343.
                          p_Effective_date := NULL;
                        else
                          p_effective_date:=l_effective_date;
                        end if;
                        CLOSE effective_date_cur;
                END IF;
       END get_gms_effective_date ;


PROCEDURE MULTIORG_CLIENT_INFO(
		     p_gl_set_of_bks_id 	OUT NOCOPY	NUMBER,
		     p_business_group_id        OUT NOCOPY     NUMBER,
		     p_operating_unit           OUT NOCOPY     NUMBER,
		     p_pa_gms_install_options	OUT NOCOPY	VARCHAR2) IS

	l_pa_install 		NUMBER := 0;
	l_gms_install 		NUMBER := 0;

begin
	fnd_profile.get('GL_SET_OF_BKS_ID', p_gl_set_of_bks_id);

	fnd_profile.get('PER_BUSINESS_GROUP_ID', p_business_group_id);

	fnd_profile.get('ORG_ID',p_operating_unit);

--	--dbms_output.put_line('bg is ' || to_char(p_business_group_id));
--	--dbms_output.put_line('sob is ' || to_char(p_gl_set_of_bks_id));
--	--dbms_output.put_line('mo is ' || to_char(p_operating_unit));

-- Check whether Multi-Org is implemented for the BG, SOB and ORG_ID combination.

	-- initialize multiorg setup
	init_moac;

	select count(*)
	  into l_pa_install
	  from pa_implementations_all p
	 where business_group_id  = p_business_group_id
	   and set_of_books_id = p_gl_set_of_bks_id
--         Commented for Bug 5498280: MOAC changes
--	   and nvl(org_id,-999) = nvl(p_operating_unit,-999);
           -- Added nvl by Neerav for Bug 1538262
           and ((mo_global.get_current_org_id is NULL and mo_global.check_access(p.org_id) = 'Y')
	        or ( mo_global.get_current_org_id is NOT NULL and p.org_id = mo_global.get_current_org_id ));
--	--dbms_output.put_line('l_pa_install is ' || to_char(l_pa_install));

	if (l_pa_install > 0) then
--	  if (gms_install.site_enabled)  then

--         Commented for Bug 5498280: MOAC changes
/*
-- Check if Multi-Org is implemented for the ORG_ID..
	  -- If p_operating_unit added by Neerav for Bug 1538262
           if p_operating_unit is NOT NULL then

	     if (gms_install.enabled(p_operating_unit))  then
	  	l_gms_install := 1;
	     else
		l_gms_install := 0;
	     end if;

	   else
*/
             if (gms_install.enabled)  then
	  	l_gms_install := 1;
	     else
		l_gms_install := 0;
	     end if;
--           end if;


	end if;

--	--dbms_output.put_line('l_gms_install is ' || to_char(l_gms_install));

	if (l_pa_install > 0) and (l_gms_install > 0) then
	   p_pa_gms_install_options := 'PA_GMS';
	elsif (l_pa_install > 0) and (l_gms_install = 0) then
	   p_pa_gms_install_options := 'PA_ONLY';
	else
	   p_pa_gms_install_options := 'NO_PA_GMS';
	end if;

exception
  WHEN OTHERS THEN
     fnd_msg_pub.add_exc_msg('PSP_GENERAL',SQLERRM);
     raise_application_error(SQLCODE, SQLERRM);
end;

FUNCTION get_specific_profile(
		     p_profile_name 		IN	VARCHAR2)
		return VARCHAR2 IS

	l_profile_value		VARCHAR2(80);
BEGIN
	fnd_profile.get(p_profile_name, l_profile_value);

	if l_profile_value is not null
	then
		return l_profile_value;
	else
		return NULL;
	end if;

END;

-- Wrapper function for checking whether LD is implemented..used by PSB

FUNCTION IS_LD_ENABLED (P_BUSINESS_GROUP_ID IN NUMBER) RETURN VARCHAR2 IS

-- The following function is used to check presence of a clearing account

FUNCTION CHECK_CLEARING_ACCT (P_BUSINESS_GROUP_ID IN NUMBER) RETURN BOOLEAN IS

   l_clearing_account	NUMBER;
   BEGIN

     SELECT count(*)
       INTO l_clearing_account
       FROM psp_clearing_account
      WHERE business_group_id = p_business_group_id;

    IF l_clearing_account > 0 THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;

   EXCEPTION
   WHEN OTHERS THEN
     RETURN FALSE;
   END;

-- The following function is used to check presence of a generic suspense account

FUNCTION CHECK_GENERIC_SUSP_ACCT (P_BUSINESS_GROUP_ID IN NUMBER) RETURN BOOLEAN IS
  l_gen_susp_acct	NUMBER;
  BEGIN
    SELECT count(*)
      INTO l_gen_susp_acct
      FROM psp_organization_accounts
     WHERE business_group_id = p_business_group_id;

     IF l_gen_susp_acct > 0 then
       return TRUE;
     ELSE
       return FALSE;
     END IF;

  EXCEPTION
  WHEN OTHERS THEN
    RETURN FALSE;
  END;

  BEGIN

  IF (CHECK_CLEARING_ACCT(P_BUSINESS_GROUP_ID) AND CHECK_GENERIC_SUSP_ACCT(P_BUSINESS_GROUP_ID))
  THEN
    RETURN FND_API.G_TRUE ;
  ELSE
    RETURN FND_API.G_FALSE;
  END IF;

  EXCEPTION
  WHEN OTHERS THEN
    RETURN FND_API.G_FALSE;
  END;

-- The following function is used to perform an Award Date Validation
FUNCTION AWARD_DATE_VALIDATION(P_AWARD_ID 		IN	NUMBER,
                               P_START_DATE 		IN	DATE,
                               P_END_DATE 		IN	DATE) RETURN BOOLEAN IS
	x_award_start_date DATE;
	x_award_end_date  DATE;
BEGIN
	select nvl(preaward_date,start_date_active), end_date_active
	into
	       x_award_start_date, x_award_end_date
	from   gms_awards_all --Bug 6908158
   	where  award_id = p_award_id;

	IF (p_start_date NOT BETWEEN x_award_start_date AND
		NVL(x_award_end_date, fnd_date.canonical_to_date('4712/12/31'))) OR
	   (NVL(p_end_date, fnd_date.canonical_to_date('4712/12/31')) NOT BETWEEN x_award_start_date AND
		NVL(x_award_end_date, fnd_date.canonical_to_date('4712/12/31'))) THEN
		return(FALSE);
	ELSE
		return(TRUE);
	END IF;
EXCEPTION
	WHEN OTHERS
	THEN
		return (FALSE);

END AWARD_DATE_VALIDATION;

/**********************************************************
Created By : lveerubh

Date Created By : 04-OCT-2001

Purpose : This function returns concatenated gl segment values . This is introduced to be used in reports
	  to display the  segment values rather than gl description.

Know limitations, enhancements or remarks

Change History

Who			   When 		   	  What
Lveerubh	 	 04-OCT-2001		  Created the function


**********************************************/

FUNCTION get_gl_values(p_set_of_books_id  IN  NUMBER,
                            a_code_combination_id IN NUMBER) RETURN VARCHAR2 IS
---------------------------------------------------History-----------------------------------------------------------
--DATE          MODIFIED BY     DESCRIPTION
  --------      -----------     -----------
--02/10/99      Shu Lei         Fix Bug #819605: undefined segments.
---------------------------------------------------------------------------------------------------------------------
      t_nc                    NUMBER(3);
      t_values                  VARCHAR2(1000);
      nc                      NUMBER;
      x_chart_of_accts        VARCHAR2(20);

      FUNCTION t_glccid_exists(code_combination_id1 IN NUMBER,chart_of_accounts_id1 IN NUMBER)
      RETURN NUMBER IS
         t_dummy  CHAR(1);
      BEGIN
         IF code_combination_id1 IS NULL THEN
            RETURN(-1);
         END IF;
         ---
         SELECT 'x'
         INTO t_dummy
         FROM gl_code_combinations
         WHERE code_combination_id = code_combination_id1 AND
               chart_of_accounts_id = chart_of_accounts_id1 AND
               ROWNUM = 1;
         RETURN(0);
      EXCEPTION
         WHEN OTHERS THEN
            RETURN(-2);
      END;
BEGIN
      nc := find_chart_of_accts(p_set_of_books_id,x_chart_of_accts);
      IF nc = -1 THEN
         RETURN('** Chart Of Accts Failed **');
      END IF;
      ---
      t_nc := t_glccid_exists(a_code_combination_id,to_number(x_chart_of_accts));
      IF t_nc = -1 THEN
         RETURN(NULL);
      ELSIF t_nc = -2 THEN
         RETURN('**  Invalid GL CCID '||to_char(a_code_combination_id)||' :: No Such Code Exists  **');
      END IF;
      ---
      IF FND_FLEX_KEYVAL.validate_ccid('SQLGL', 'GL#', x_chart_of_accts, a_code_combination_id ) THEN
         t_values := FND_FLEX_KEYVAL.concatenated_values;
         return(t_values);
      END IF;
END get_gl_values;

-- Following functions added by Ritesh on 14-NOV-2001 for Bug:2103460
--*************************************
----  FUNCTION get_person_name
--*************************************
-- This function returns the full_name of the person. If there are multiple
-- records it will get the name which is valid on the effective/distribution date. If person_id
-- or effective/distribution date is invalid, it will return an error message.
-- This function is called from psp_payroll_interface_v and psp_distribution_interface_v

  FUNCTION get_person_name
	   (p_person_id      IN NUMBER,
	    p_effective_date IN DATE)
            RETURN VARCHAR2  IS

    CURSOR c1 IS
	SELECT full_name
       	FROM   per_all_people_f ppf
       	WHERE  ppf.person_id = p_person_id
       	AND    p_effective_date BETWEEN effective_start_date AND effective_end_date;

	v_name VARCHAR2(240);
BEGIN
	  OPEN c1;
	    FETCH c1 INTO v_name;

	    IF c1%NOTFOUND
	    THEN
	         CLOSE c1;
	         -- RETURN ('Person Name Not Found on Effective Date');
		 RETURN(FND_MESSAGE.GET_STRING('PSP','PSP_NON_PERSON_NOT_FOUND'));
            END IF;

	  CLOSE c1;

   	  RETURN(v_name);

  END get_person_name;

--*************************************
----  FUNCTION get_assignment_num
--*************************************
-- This function returns assignment number for the given assignment_id and effective_date/distribution_date.
-- If no row exists for the given parameter, it will return an error message.
-- This function is called from psp_payroll_interface_v and psp_distribution_interface_v

  FUNCTION get_assignment_num
           (p_assignment_id  IN NUMBER,
            p_effective_date IN DATE)
            RETURN VARCHAR2  IS

    CURSOR c1 IS
       SELECT assignment_number
       FROM   per_all_assignments_f paf
       WHERE  paf.assignment_id = p_assignment_id
       AND    p_effective_date BETWEEN effective_start_date AND effective_end_date
       AND    period_of_service_id IS NOT NULL;

     v_name VARCHAR2(30);

  BEGIN
	  OPEN c1;
	    FETCH c1 INTO v_name;

	    IF c1%NOTFOUND
	    THEN
		CLOSE c1;
		-- RETURN ('Assg Num Not Found on Eff Date');
		RETURN(FND_MESSAGE.GET_STRING('PSP','PSP_NON_ASSIGNMENT_NOT_FOUND'));
	    END IF;

	  CLOSE c1;

 	  RETURN(v_name);

  END get_assignment_num;

--*************************************
----  FUNCTION get_payroll_name
--*************************************
-- This function returns the payroll name for the given payroll_id and effective_date/distribution_date.
-- If no row exists for the given parameters, an error message is returned.
-- This function is called from psp_payroll_interface_v and psp_distribution_interface_v


  FUNCTION get_payroll_name
	   (p_payroll_id     IN NUMBER,
	    p_effective_date IN DATE)
            RETURN VARCHAR2 IS

     CURSOR c1 IS
        SELECT payroll_name
        FROM   pay_all_payrolls_f pap
        WHERE  pap.payroll_id = p_payroll_id
	AND    p_effective_date BETWEEN effective_start_date AND effective_end_date;

     v_name VARCHAR2(80);

  BEGIN
     OPEN c1;
       FETCH c1 INTO v_name;

	IF c1%NOTFOUND
	THEN
	     CLOSE c1;
   	     -- RETURN ('Payroll Name Not Found on Effective Date');
	     RETURN(FND_MESSAGE.GET_STRING('PSP','PSP_NON_PAYROLL_NOT_FOUND'));
	END IF;

     CLOSE c1;

     RETURN(v_name);

  END get_payroll_name;

-- End additions for Bug:2103460
--------------------------------------------------------------

/*	Commented the following procedure for bug fix 2397883
--	Introduced the following procedure for bug 2209483 for IGW LD Integration
PROCEDURE	igw_percent_effort	(p_person_id		IN	NUMBER,
					p_award_id		IN	NUMBER,
					p_effective_date	IN	DATE,
					p_percent_effort	OUT NOCOPY	NUMBER,
					p_msg_data		OUT NOCOPY	VARCHAR2,
					p_return_status		OUT NOCOPY	VARCHAR2)
IS
	CURSOR percent_effort_cur IS
	SELECT NVL(SUM(schedule_percent), 0)
	FROM	per_assignments_f paf,
		psp_schedule_hierarchy psh,
		psp_schedule_lines psl
	WHERE	paf.person_id = p_person_id
	AND	TRUNC(p_effective_date) BETWEEN paf.effective_start_date AND paf.effective_end_date
	AND	psh.assignment_id = paf.assignment_id
	AND	psl.schedule_hierarchy_id = psh.schedule_hierarchy_id
	AND	psl.award_id = p_award_id
	AND	TRUNC(p_effective_date) BETWEEN psl.schedule_begin_date AND psl.schedule_end_date;

	l_msg_count	NUMBER;

BEGIN
	OPEN percent_effort_cur;
	FETCH percent_effort_cur INTO p_percent_effort;
	CLOSE percent_effort_cur;
	p_return_status := fnd_api.g_ret_sts_success;
EXCEPTION
	WHEN OTHERS THEN
		p_return_status := fnd_api.g_ret_sts_unexp_error;
		fnd_msg_pub.add_exc_msg
			(p_pkg_name		=>	'PSP_GENERAL',
			p_procedure_name	=>	'IGW_PERCENT_EFFORT');
		fnd_msg_pub.count_and_get
			(p_count	=>	l_msg_count,
			p_data		=>	p_msg_data);
END igw_percent_effort;

	End of bug fix 2397883	*/

--	Introduced the following for bug fix 2635110
	FUNCTION get_project_number	(p_project_id	IN	NUMBER) RETURN VARCHAR2 IS
		CURSOR	project_number_cur IS
		SELECT	segment1
		FROM	pa_projects_all
		WHERE	project_id = p_project_id;

		l_project_number	VARCHAR2(200);

	BEGIN
		OPEN project_number_cur;
		FETCH project_number_cur INTO l_project_number;
		IF (project_number_cur%NOTFOUND) THEN
			fnd_message.set_name('PSP', 'PSP_PROJECT_NOT_FOUND');
			l_project_number := fnd_message.get;
		END IF;
		CLOSE project_number_cur;
		RETURN l_project_number;
	END get_project_number;

	FUNCTION get_task_number	(p_task_id	IN	NUMBER) RETURN VARCHAR2 IS
		CURSOR	task_number_cur IS
		SELECT	task_number
		FROM	pa_tasks
		WHERE	task_id = p_task_id;

		l_task_number	VARCHAR2(200);

	BEGIN
		OPEN task_number_cur;
		FETCH task_number_cur INTO l_task_number;
		IF (task_number_cur%NOTFOUND) THEN
			fnd_message.set_name('PSP', 'PSP_TASK_NOT_FOUND');
			l_task_number := fnd_message.get;
		END IF;
		CLOSE task_number_cur;
		RETURN l_task_number;
	END get_task_number;

        FUNCTION get_award_number       (p_award_id     IN      NUMBER) RETURN VARCHAR2 IS
                CURSOR  award_number_cur IS
                SELECT  award_number
                FROM    gms_awards_all
                WHERE   award_id = p_award_id;

                l_award_number  VARCHAR2(200);

                cursor default_award_cur is     ---- for pregen form for bug 5643110/5742525
                 select default_dist_award_number
                   from gms_implementations
                  where award_distribution_option = 'Y'
                    and default_dist_award_id = p_award_id;
        BEGIN
                OPEN award_number_cur;
                FETCH award_number_cur INTO l_award_number;
                IF (award_number_cur%NOTFOUND) THEN
                   open default_Award_cur;
                   fetch default_Award_cur into l_Award_number;
                   if default_Award_cur%notfound then
                        fnd_message.set_name('PSP', 'PSP_AWARD_NOT_FOUND');
                        l_award_number := fnd_message.get;
                   end if;
                   close default_award_cur;
                END IF;
                CLOSE award_number_cur;
                RETURN l_award_number;
        END get_award_number;


	FUNCTION get_org_name	(p_org_id	IN	NUMBER) RETURN VARCHAR2 IS
		CURSOR	org_name_cur IS
		SELECT	name
		FROM	hr_all_organization_units
		WHERE	organization_id = p_org_id;

		l_org_name	hr_all_organization_units.name%TYPE;

	BEGIN
		OPEN org_name_cur;
		FETCH org_name_cur INTO l_org_name;
		IF (org_name_cur%NOTFOUND) THEN
			fnd_message.set_name('PSP', 'PSP_ORG_NOT_FOUND');
			l_org_name := fnd_message.get;
		END IF;
		CLOSE org_name_cur;
		RETURN l_org_name;
	END get_org_name;

	FUNCTION get_period_name	(p_period_id	IN	NUMBER) RETURN VARCHAR2 IS
		CURSOR	period_name_cur IS
		SELECT	period_name
		FROM	per_time_periods
		WHERE	time_period_id = p_period_id;

		l_period_name	per_time_periods.period_name%TYPE;

	BEGIN
		OPEN period_name_cur;
		FETCH period_name_cur INTO l_period_name;
		IF (period_name_cur%NOTFOUND) THEN
			fnd_message.set_name('PSP', 'PSP_PERIOD_NOT_FOUND');
			l_period_name := fnd_message.get;
		END IF;
		CLOSE period_name_cur;
		RETURN l_period_name;
	END get_period_name;

	FUNCTION get_element_name	(p_element_type_id	IN	NUMBER,
					p_effective_date	IN	DATE) RETURN VARCHAR2 IS
		CURSOR	element_name_cur IS
		SELECT	element_name
		FROM	pay_element_types_f
		WHERE	element_type_id = p_element_type_id
		AND	p_effective_date BETWEEN effective_start_date AND effective_end_date;

		l_element_name	pay_element_types_f.element_name%TYPE;

	BEGIN
		OPEN element_name_cur;
		FETCH element_name_cur INTO l_element_name;
		IF (element_name_cur%NOTFOUND) THEN
			fnd_message.set_name('PSP', 'PSP_ELEMENT_NOT_FOUND');
			l_element_name := fnd_message.get;
		END IF;
		CLOSE element_name_cur;
		RETURN l_element_name;
	END get_element_name;

--	Introduced the following for bug fix 4189270
	FUNCTION get_element_name	(p_element_type_id	IN	NUMBER) RETURN VARCHAR2 IS
		CURSOR	element_name_cur IS
		SELECT	element_name
		FROM	pay_element_types_f
		WHERE	element_type_id = p_element_type_id
		AND	(	(TRUNC(SYSDATE) BETWEEN effective_start_date AND effective_end_date)
			OR	(effective_start_date =	(SELECT	MIN(effective_start_date)
						FROM	pay_element_types_f petf2
						WHERE	petf2.element_type_id = p_element_type_id)));

		l_element_name	pay_element_types_f.element_name%TYPE;

	BEGIN
		OPEN element_name_cur;
		FETCH element_name_cur INTO l_element_name;
		CLOSE element_name_cur;

		RETURN l_element_name;
	END get_element_name;
--	End of bug fix 4189270

	FUNCTION get_source_type	(p_source_type	IN	VARCHAR2,
					p_source_code	IN	VARCHAR2) RETURN VARCHAR2 IS
		CURSOR	source_type_cur IS
		SELECT	description
		FROM	psp_payroll_sources
		WHERE	source_type = p_source_type
		AND	source_code = p_source_code;

		l_source_type	psp_payroll_sources.description%TYPE;

	BEGIN
		OPEN source_type_cur;
		FETCH source_type_cur INTO l_source_type;
		IF (source_type_cur%NOTFOUND) THEN
			fnd_message.set_name('PSP', 'PSP_SOURCE_TYPE_NOT_FOUND');
			l_source_type := fnd_message.get;
		END IF;
		CLOSE source_type_cur;
		RETURN l_source_type;
	END get_source_type;

	FUNCTION get_status_description	(p_status_code	IN	VARCHAR2) RETURN VARCHAR2 IS
/*****	Modified the following cursor for R12 performance fixes (bug 4507892)
		CURSOR	status_description_cur IS
		SELECT	MEANING
		FROM	PSP_LOOKUPS
		WHERE	lookup_code = p_status_code
		AND	lookup_type = 'PSP_STATUS';
	End of comment for R12 performance fixes (bug 4507892)	*****/
--	New cursor defn. for bug fix 4507892
		CURSOR	status_description_cur IS
		SELECT	meaning
		FROM	FND_LOOKUP_VALUES FLV
		WHERE	lookup_type = 'PSP_STATUS'
		AND	lookup_code = p_status_code
		AND	language = USERENV('LANG');

		l_status_description	psp_lookups.meaning%TYPE;

	BEGIN
		OPEN status_description_cur;
		FETCH status_description_cur INTO l_status_description;
		IF (status_description_cur%NOTFOUND) THEN
			fnd_message.set_name('PSP', 'PSP_STATUS_DESCR_NOT_FOUND');
			l_status_description := fnd_message.get;
		END IF;
		CLOSE status_description_cur;
		RETURN l_status_description;
	END get_status_description;

	FUNCTION get_error_description	(p_error_code	IN	VARCHAR2) RETURN VARCHAR2 IS
/*****	Modified the following cursor for R12 performance fixes (bug 4507892)
		CURSOR	error_description_cur IS
		SELECT	MEANING
		FROM	PSP_LOOKUPS
		WHERE	lookup_code = p_error_code
		AND	lookup_type = 'PSP_ERROR_CODE';
	End of comment for R12 performace fixes	(bug 4507892)	*****/

--	New cursor defn for bug fix 4507892
		CURSOR	error_description_cur IS
		SELECT	meaning
		FROM	FND_LOOKUP_VALUES FLV
		WHERE	lookup_type = 'PSP_ERROR_CODE'
		AND	lookup_code = p_error_code
		AND	language = USERENV('LANG');

		l_error_description	psp_lookups.meaning%TYPE;

	BEGIN
		OPEN error_description_cur;
		FETCH error_description_cur INTO l_error_description;
		IF (error_description_cur%NOTFOUND) THEN
			l_error_description := p_error_code;
		END IF;
		CLOSE error_description_cur;
		RETURN l_error_description;
	END get_error_description;
--	End of bug fix 2635110


-- For Qubec fixes by tbalacha---
--Bug no 2478000 ---
/***************************************************************************************
   Funtion added for Qubec
   Description : This code returns the Currency code associated with a business_group_id
   Purpose     : To remove Hardcoded USD from Labor Distribution Forms and reports
   Creation date:25-APR-2003
*****************************************************************************************/
   FUNCTION get_currency_code(p_business_group_id IN NUMBER ) RETURN VARCHAR2 IS
   l_curr_code VARCHAR2(15);

   CURSOR get_curr_for_bg is SELECT  currency_code from per_business_groups where
   business_group_id=p_business_group_id;


  BEGIN
     OPEN get_curr_for_bg;
     FETCH get_curr_for_bg into l_curr_code;

     IF get_curr_for_bg%NOTFOUND THEN

       FND_MESSAGE.SET_NAME('PSP' , 'PSP_HR_CUR_NOT_SET_UP');
       CLOSE get_curr_for_bg;
       RAISE fnd_api.g_exc_unexpected_error;

     ELSE

       CLOSE get_curr_for_bg;
       RETURN (l_curr_code);

     END IF;
  END get_currency_code;

-- End of code for Bug no 2478000

--	Introduced the following for bug 2916848
PROCEDURE get_currency_precision
		(p_currency_code	IN	VARCHAR2,
		p_precision		OUT NOCOPY	NUMBER,
		p_ext_precision		OUT NOCOPY	NUMBER) IS
l_min_acct_unit	NUMBER;
BEGIN
	fnd_currency.get_info	(currency_code	=>	p_currency_code,
				precision	=>	p_precision,
				ext_precision	=>	p_ext_precision,
				min_acct_unit	=>	l_min_acct_unit);
	p_ext_precision := NVL(p_ext_precision, 6);
END get_currency_precision;

/*****	Commented the following function for bug fix 3146167
FUNCTION get_payroll_currency (p_payroll_control_id IN NUMBER) RETURN VARCHAR2 IS
CURSOR	currency_code_cur IS
SELECT	currency_code
FROM	psp_payroll_controls ppc
WHERE	ppc.payroll_control_id = p_payroll_control_id;

l_currency_code		psp_payroll_controls.currency_code%TYPE;
BEGIN
	OPEN currency_code_cur;
	FETCH currency_code_cur INTO l_currency_code;
	CLOSE currency_code_cur;

	RETURN l_currency_code;
END get_payroll_currency;
	End of comment for bug fix 3146167	*****/
--	End of bug fix 2916848

/*************************************************************************************************
Description: This function call would replace call to profile option
                PSP: Enable Update Encumbrance, as the profile,
                PSP: Enable Update Encumbrance will be obsoleted by end dating it to '01-jan-2003'.
                The call to the profile PSP: Enable Update Encumbrance , in all the files except
                GMS.pll will be removed and this  new function START_CAPTURING_UPDATES will
                instead called in its place
  Date of Creation: 23-Jul-2003
  Bug :3075435 Dynamic trigger IMplementation.
**********************************************************************************************/
FUNCTION START_CAPTURING_UPDATES(p_business_group_id IN NUMBER) RETURN VARCHAR2 IS

CURSOR update_enc_cur  IS
SELECT	'Y'
FROM	psp_enc_end_dates
WHERE	default_org_flag = 'Y'
AND	business_group_id = p_business_group_id
AND	prev_enc_end_date IS NOT NULL;


l_start_capturing_updates  VARCHAR2(2);

BEGIN
	OPEN	update_enc_cur;
	FETCH   update_enc_cur INTO l_start_capturing_updates;
        IF (update_enc_cur%NOTFOUND) THEN
		l_start_capturing_updates := 'N';
	END IF;
	CLOSE   update_enc_cur;

	RETURN l_start_capturing_updates;

End START_CAPTURING_UPDATES;


/***********************************************************************************
 Decription 	: This procedure was created for the Ads bug 2935850
 Purpose    	: PA transaction import when kicks off ,it reports
		  pa_too_many_employees error
 Creation Date	: 23-Aug-2003
***********************************************************************************/
 FUNCTION PERSON_BUSINESS_GROUP_ID_EXIST  RETURN BOOLEAN IS

 CURSOR chk_insert(p_table_owner varchar2) IS
 SELECT 1
 FROM 	all_tab_columns
 WHERE	table_name = 'PA_TRANSACTION_INTERFACE_ALL'
 AND	column_name = 'PERSON_BUSINESS_GROUP_ID'
 AND    owner = p_table_owner; -- bug 3871687

 l_pa_bg_id 	 Number;
 l_return_status Boolean;
 p_status        Varchar2(100);
 p_industry      Varchar2(100);
 p_table_owner   Varchar2(100);


 BEGIN

   l_return_status := FND_INSTALLATION.GET_APP_INFO(application_short_name => 'PA',
   status => p_status, industry => p_industry, oracle_schema => p_table_owner);

   OPEN   chk_insert(p_table_owner);
   FETCH  chk_insert into l_pa_bg_id;
   IF chk_insert%NOTFOUND THEN
    CLOSE chk_insert;
    RETURN FALSE;
   END IF;
   CLOSE chk_insert;
   RETURN TRUE;


 END PERSON_BUSINESS_GROUP_ID_EXIST;



/*****************************************************************************
 Function name :  VALIDATE_PROC_FOR_HR_UPG
 Creation date :  21-Apr-2004
 Purpose       :  This procedure returns true when Labor Distribtion Product
                  is Installed.
*****************************************************************************/
PROCEDURE VALIDATE_PROC_FOR_HR_UPG(do_upg OUT NOCOPY VARCHAR2)
is

     PSP_APPLICATION_ID constant   number:=8403;
     PSP_STATUS_INSTALLED constant varchar2(2):='I';

     l_installed fnd_product_installations.status%type;

     cursor csr_psp_installed is
     select status
     from fnd_product_installations
     where application_id = PSP_APPLICATION_ID;

     l_do_submit varchar2(10) := 'FALSE';

begin

    open csr_psp_installed;
    fetch csr_psp_installed into l_installed;
    if ( l_installed =PSP_STATUS_INSTALLED ) then
      l_do_submit := 'TRUE';
    end if;
    close csr_psp_installed;

    do_upg  := l_do_submit;

END validate_proc_for_hr_upg;

--	Introduced the following for bug fix 2908859/2907203
FUNCTION get_act_dff_grouping_option (p_business_group_id IN NUMBER)
RETURN VARCHAR2 IS
CURSOR	grouping_option_cur IS
SELECT	1 hierarchy, PCV_INFORMATION1
FROM	pqp_configuration_values pcv
WHERE	pcv.business_group_id = p_business_group_id
AND	pcv_information_category = 'PSP_ACT_DFF_GROUPING'
UNION ALL
SELECT	2 hierarchy, PCV_INFORMATION1
FROM	pqp_configuration_values pcv
WHERE	pcv.business_group_id IS NULL
AND	pcv_information_category = 'PSP_ACT_DFF_GROUPING'
ORDER BY 1;

l_grouping_option	CHAR(1);
l_hierarchy		NUMBER;
BEGIN
	OPEN grouping_option_cur;
	FETCH grouping_option_cur INTO l_hierarchy, l_grouping_option;
	CLOSE grouping_option_cur;
	l_grouping_option := NVL(l_grouping_option, 'N');

	RETURN l_grouping_option;
END get_act_dff_grouping_option;

FUNCTION get_enc_dff_grouping_option (p_business_group_id IN NUMBER)
RETURN VARCHAR2 IS
CURSOR	grouping_option_cur IS
SELECT	1 hierarchy, PCV_INFORMATION1
FROM	pqp_configuration_values pcv
WHERE	pcv.business_group_id = p_business_group_id
AND	pcv_information_category = 'PSP_ENC_DFF_GROUPING'
UNION ALL
SELECT	2 hierarchy, PCV_INFORMATION1
FROM	pqp_configuration_values pcv
WHERE	pcv.business_group_id IS NULL
AND	pcv_information_category = 'PSP_ENC_DFF_GROUPING'
ORDER BY 1;

l_grouping_option	CHAR(1);
l_hierarchy		NUMBER;
BEGIN
	OPEN grouping_option_cur;
	FETCH grouping_option_cur INTO l_hierarchy, l_grouping_option;
	CLOSE grouping_option_cur;
	l_grouping_option := NVL(l_grouping_option, 'N');

	RETURN l_grouping_option;
END get_enc_dff_grouping_option;

FUNCTION get_sponsored_flag (p_project_id IN NUMBER) RETURN VARCHAR2 IS
CURSOR	sponsored_flag_cur IS
SELECT	sponsored_flag
FROM	pa_projects_all ppa,
	gms_project_types gpt				-- Changed from gms_project_types_all for P1 bug 4078481
WHERE	gpt.project_type = ppa.project_type
AND	ppa.project_type <> 'AWARD_PROJECT'
AND	ppa.project_id = p_project_id;

l_sponsored_flag	CHAR(1);
BEGIN
	OPEN sponsored_flag_cur;
	FETCH sponsored_flag_cur INTO l_sponsored_flag;
	CLOSE sponsored_flag_cur;

	RETURN NVL(l_sponsored_flag, 'N');
END get_sponsored_flag;
--	End of changes for bug fix 2908859/2907203

-- Changes for Effort Reporting Self service Page

FUNCTION get_person_name_er(p_person_id IN VARCHAR2, p_effective_date IN DATE) RETURN VARCHAR2 IS
cursor eff_dates is
select max(ppf.effective_end_date),min(ppf.effective_start_date)
from   per_people_f ppf
where  ppf.current_employee_flag = 'Y'
and    ppf.person_id =  p_person_id
group by ppf.person_id ;

cursor c1(p_calculated_date date)
is
select full_name from per_people_f
where person_id = p_person_id
and  p_calculated_date between effective_start_date and effective_end_date;

l_person_name varchar2(240);
max_eff_end_date date;
min_eff_start_date date;

begin


 l_person_name :=  psp_general.get_person_name(p_person_id,p_effective_date);
 If (l_person_name = FND_MESSAGE.GET_STRING('PSP','PSP_NON_PERSON_NOT_FOUND') ) Then
   open  eff_dates;
   fetch eff_dates into max_eff_end_date,min_eff_start_date;
   close eff_dates;

     If ( p_effective_date < min_eff_start_date ) Then

        open c1(min_eff_start_date);
        fetch c1 into l_person_name;
          IF c1%NOTFOUND THEN
	         CLOSE c1;
	         -- RETURN ('Person Name Not Found on Effective Date');
		      RETURN(FND_MESSAGE.GET_STRING('PSP','PSP_NON_PERSON_NOT_FOUND'));
           END IF;


     Else

         open c1(max_eff_end_date);
         fetch c1 into l_person_name;
         IF c1%NOTFOUND THEN
	        CLOSE c1;
	         -- RETURN ('Person Name Not Found on Effective Date');
		 RETURN(FND_MESSAGE.GET_STRING('PSP','PSP_NON_PERSON_NOT_FOUND'));
         END IF;

     End if  ;

     If c1%ISOPEN then
        Close c1;
     End if;
 End If;

 return l_person_name ;

END get_person_name_er;

FUNCTION chk_person_validity(p_person_id IN VARCHAR2,p_effective_date IN DATE) RETURN VARCHAR2
IS

cursor eff_dates is
select max(ppf.effective_end_date),min(ppf.effective_start_date)
from   per_people_f ppf
where  ppf.current_employee_flag = 'Y'
and    ppf.person_id =  p_person_id
group by ppf.person_id ;

max_eff_end_date date;
min_eff_start_date date;

BEGIN

   open  eff_dates;
   fetch eff_dates into max_eff_end_date,min_eff_start_date;
   close eff_dates;

   If ((min_eff_start_date <= p_effective_date) and ( p_effective_date <= max_eff_end_date)) then

    return 'Y';

   Else

    return 'N';

   End if;


END chk_person_validity;

FUNCTION chk_payroll_validity(p_payroll_id     IN NUMBER, p_effective_date IN DATE) RETURN VARCHAR2
IS

cursor eff_dates is
select max(papf.effective_end_date),min(papf.effective_start_date)
from pay_all_payrolls_f papf
WHERE  papf.payroll_id = p_payroll_id;

max_eff_end_date date;
min_eff_start_date date;

BEGIN

   open  eff_dates;
   fetch eff_dates into max_eff_end_date,min_eff_start_date;
   close eff_dates;

   If ((min_eff_start_date <= p_effective_date) and ( p_effective_date <= max_eff_end_date)) then

    return 'Y';

   Else

    return 'N';

   End if;


END chk_payroll_validity;

FUNCTION get_payroll_name_er(p_payroll_id     IN NUMBER, p_effective_date IN DATE) RETURN VARCHAR2 IS
cursor eff_dates is
select max(papf.effective_end_date),min(papf.effective_start_date)
from pay_all_payrolls_f papf
WHERE  papf.payroll_id = p_payroll_id;

cursor c1(p_calculated_date date)
is
select payroll_name
from pay_all_payrolls_f papf
WHERE  papf.payroll_id = p_payroll_id
and  p_calculated_date between papf.effective_start_date and papf.effective_end_date;

l_payroll_name varchar2(240);
max_eff_end_date date;
min_eff_start_date date;

begin


 l_payroll_name :=  psp_general.get_payroll_name(p_payroll_id,p_effective_date);
 If (l_payroll_name = FND_MESSAGE.GET_STRING('PSP','PSP_NON_PAYROLL_NOT_FOUND') ) Then
   open  eff_dates;
   fetch eff_dates into max_eff_end_date,min_eff_start_date;
   close eff_dates;

     If ( p_effective_date < min_eff_start_date ) Then

        open c1(min_eff_start_date);
        fetch c1 into l_payroll_name;
          IF c1%NOTFOUND THEN
	         CLOSE c1;
	         RETURN(FND_MESSAGE.GET_STRING('PSP','PSP_NON_PAYROLL_NOT_FOUND'));
           END IF;


     Else

         open c1(max_eff_end_date);
         fetch c1 into l_payroll_name;
         IF c1%NOTFOUND THEN
	        CLOSE c1;
	        RETURN(FND_MESSAGE.GET_STRING('PSP','PSP_NON_PAYROLL_NOT_FOUND'));
         END IF;

     End if  ;

     If c1%ISOPEN then
        Close c1;
     End if;

 End If;

 return l_payroll_name ;

END get_payroll_name_er;

FUNCTION chk_position_validity(p_position_id     IN NUMBER, p_effective_date IN DATE) RETURN VARCHAR2
IS

cursor eff_dates is
select max(hpf.effective_end_date),min(hpf.effective_start_date)
from hr_positions_f hpf
WHERE  hpf.position_id = p_position_id;

max_eff_end_date date;
min_eff_start_date date;

BEGIN

   open  eff_dates;
   fetch eff_dates into max_eff_end_date,min_eff_start_date;
   close eff_dates;

   If ((min_eff_start_date <= p_effective_date) and ( p_effective_date <= max_eff_end_date)) then

    return 'Y';

   Else

    return 'N';

   End if;


END chk_position_validity;




FUNCTION get_position_name_er(p_position_id   IN NUMBER, p_effective_date IN DATE) RETURN VARCHAR2 IS

cursor eff_dates is
select max(hpf.effective_end_date),min(hpf.effective_start_date)
from hr_positions_f hpf
WHERE  hpf.position_id = p_position_id ;

cursor c1(p_calculated_date date)
is
select name
from hr_positions_f hpf
WHERE  hpf.position_id = p_position_id
and  p_calculated_date between hpf.effective_start_date and hpf.effective_end_date;

l_position_name varchar2(240);
max_eff_end_date date;
min_eff_start_date date;

begin



   open  eff_dates;
   fetch eff_dates into max_eff_end_date,min_eff_start_date;
   close eff_dates;

     If ( p_effective_date < min_eff_start_date ) Then

        open c1(min_eff_start_date);
        fetch c1 into l_position_name;
          IF c1%NOTFOUND THEN
	         CLOSE c1;
	  END IF;


     Else

         open c1(max_eff_end_date);
         fetch c1 into l_position_name;
         IF c1%NOTFOUND THEN
	        CLOSE c1;
	 END IF;

     End if  ;

     If c1%ISOPEN then
        Close c1;
     End if;

 return l_position_name ;

END get_position_name_er;

FUNCTION chk_fastformula_validity(p_formula_id     IN NUMBER, p_effective_date IN DATE) RETURN VARCHAR2
IS

cursor eff_dates is
select max(ff.effective_end_date),min(ff.effective_start_date)
from ff_formulas_f ff
WHERE  ff.formula_id = p_formula_id;

max_eff_end_date date;
min_eff_start_date date;

BEGIN

   open  eff_dates;
   fetch eff_dates into max_eff_end_date,min_eff_start_date;
   close eff_dates;

   If ((min_eff_start_date <= p_effective_date) and ( p_effective_date <= max_eff_end_date)) then

    return 'Y';

   Else

    return 'N';

   End if;


END chk_fastformula_validity;




FUNCTION get_fastformula_name_er(p_formula_id   IN NUMBER, p_effective_date IN DATE) RETURN VARCHAR2 IS

cursor eff_dates is
select max(ff.effective_end_date),min(ff.effective_start_date)
from ff_formulas_f ff
WHERE  ff.formula_id = p_formula_id;

cursor c1(p_calculated_date date)
is
select formula_name
from ff_formulas_f ff
WHERE  ff.formula_id = p_formula_id
and  p_calculated_date between ff.effective_start_date and ff.effective_end_date;

l_formula_name varchar2(240);
max_eff_end_date date;
min_eff_start_date date;

begin



   open  eff_dates;
   fetch eff_dates into max_eff_end_date,min_eff_start_date;
   close eff_dates;

     If ( p_effective_date < min_eff_start_date ) Then

        open c1(min_eff_start_date);
        fetch c1 into l_formula_name;
          IF c1%NOTFOUND THEN
	         CLOSE c1;
	  END IF;


     Else

         open c1(max_eff_end_date);
         fetch c1 into l_formula_name;
         IF c1%NOTFOUND THEN
	        CLOSE c1;
	 END IF;

     End if  ;


     If c1%ISOPEN then
        Close c1;
     End if;


 return l_formula_name ;

END get_fastformula_name_er;

FUNCTION get_fastformula_desc_er(p_formula_id   IN NUMBER, p_effective_date IN DATE) RETURN VARCHAR2 IS
cursor eff_date is
select max(ff.effective_end_date),min(ff.effective_start_date)
from ff_formulas_f ff
WHERE  ff.formula_id = p_formula_id;

cursor c1(p_calculated_date date)
is
select description
from ff_formulas_f ff
WHERE  ff.formula_id = p_formula_id
and  p_calculated_date between ff.effective_start_date and ff.effective_end_date;

l_formula_desc ff_formulas_f.description%type;
max_eff_end_date date;
min_eff_start_date date;

begin



   open  eff_date;
   fetch eff_date into max_eff_end_date,min_eff_start_date;
   close eff_date;

     If ( p_effective_date < min_eff_start_date ) Then

        open c1(min_eff_start_date);
        fetch c1 into l_formula_desc;
          IF c1%NOTFOUND THEN
	         CLOSE c1;
	  END IF;


     Else

         open c1(max_eff_end_date);
         fetch c1 into l_formula_desc;
         IF c1%NOTFOUND THEN
	        CLOSE c1;
	 END IF;

     End if  ;


     If c1%ISOPEN then
        Close c1;
     End if;


 return l_formula_desc ;

End get_fastformula_desc_er;

FUNCTION chk_job_validity(p_job_id     IN NUMBER, p_effective_date IN DATE) RETURN VARCHAR2 IS

cursor eff_dates is
select max(nvl(pjv.date_to,to_date('31/12/4712','DD/MM/RRRR'))),min(pjv.date_from)
from per_jobs_v pjv
WHERE  pjv.job_id = p_job_id;

max_eff_end_date date;
min_eff_start_date date;

BEGIN

   open  eff_dates;
   fetch eff_dates into max_eff_end_date,min_eff_start_date;
   close eff_dates;

   If ((min_eff_start_date <= p_effective_date) and ( p_effective_date <= max_eff_end_date)) then

    return 'Y';

   Else

    return 'N';

   End if;


END chk_job_validity;




FUNCTION get_job_name_er(p_job_id   IN NUMBER, p_effective_date IN DATE) RETURN VARCHAR2 IS

cursor eff_dates is
select max(nvl(pjv.date_to,to_date('31/12/4712','DD/MM/RRRR'))),min(pjv.date_from)
from per_jobs_v pjv
WHERE  pjv.job_id = p_job_id;

cursor c1(p_calculated_date date)
is
select name
from per_jobs_v pjv
WHERE  pjv.job_id = p_job_id
and  p_calculated_date between  pjv.date_from and trunc(nvl(pjv.date_to,to_date('31/12/4712','DD/MM/RRRR')));

l_job_name varchar2(240);
max_eff_end_date date;
min_eff_start_date date;

begin



   open  eff_dates;
   fetch eff_dates into max_eff_end_date,min_eff_start_date;
   close eff_dates;

     If ( p_effective_date < min_eff_start_date ) Then

        open c1(min_eff_start_date);
        fetch c1 into l_job_name;
          IF c1%NOTFOUND THEN
	         CLOSE c1;
	  END IF;


     Else

         open c1(max_eff_end_date);
         fetch c1 into l_job_name;
         IF c1%NOTFOUND THEN
	        CLOSE c1;
	 END IF;

     End if  ;


     if c1%ISOPEN then
        Close c1;
     End if;


 return l_job_name ;

END get_job_name_er;

FUNCTION chk_org_validity(p_org_id     IN NUMBER, p_effective_date IN DATE) RETURN VARCHAR2 IS

cursor eff_dates is
select max(nvl(hou.date_to,to_date('31/12/4712','DD/MM/RRRR'))),min(hou.date_from)
from hr_organization_units hou
WHERE  hou.organization_id = p_org_id;

max_eff_end_date date;
min_eff_start_date date;

BEGIN

   open  eff_dates;
   fetch eff_dates into max_eff_end_date,min_eff_start_date;
   close eff_dates;

   If ((min_eff_start_date <= p_effective_date) and ( p_effective_date <= max_eff_end_date)) then

    return 'Y';

   Else

    return 'N';

   End if;

END chk_org_validity;


FUNCTION get_org_name_er(p_org_id   IN NUMBER, p_effective_date IN DATE) RETURN VARCHAR2 IS

cursor eff_dates is
select max(nvl(hou.date_to,to_date('31/12/4712','DD/MM/RRRR'))),min(hou.date_from)
from hr_organization_units hou
WHERE  hou.organization_id = p_org_id;

cursor c1(p_calculated_date date)
is
select name
from hr_organization_units hou
WHERE  hou.organization_id = p_org_id
and  p_calculated_date between  hou.date_from and trunc(nvl(hou.date_to,to_date('31/12/4712','DD/MM/RRRR')));

l_organization_name varchar2(240);
max_eff_end_date date;
min_eff_start_date date;

begin


   open  eff_dates;
   fetch eff_dates into max_eff_end_date,min_eff_start_date;
   close eff_dates;

     If ( p_effective_date < min_eff_start_date ) Then

        open c1(min_eff_start_date);
        fetch c1 into l_organization_name;
          IF c1%NOTFOUND THEN
	         CLOSE c1;
		  RETURN(FND_MESSAGE.GET_STRING('PSP','PSP_ORG_NOT_FOUND'));
	  END IF;


     Else

         open c1(max_eff_end_date);
         fetch c1 into l_organization_name;
         IF c1%NOTFOUND THEN
	        CLOSE c1;
		 RETURN(FND_MESSAGE.GET_STRING('PSP','PSP_ORG_NOT_FOUND'));
	 END IF;

     End if  ;


     if c1%ISOPEN then
        Close c1;
     End if;

 return l_organization_name ;

END get_org_name_er;



-- End of changes for Self service Page
/*
 * --- Following section has Functions that are called from AME
 *
 * Format of the AME Transaction_Id:
 * ================================
 *
 * For Seeded Approvals:
 *  1-20  Approval Type(incomming types will be tagged, eg. SEED-EMP)
 * 21-35  Person_id /  Project_id /  Task_id /  Award_id
 * 36-50  Effort_report_id/Effort_report_Detail_id
 *
 * For Custom Approval:
 *  1-30  Approval Type
 * 36-50  Effort_report_id/Effort_report_Detail_id
 *
 */

function get_approval_type(txn_id varchar2) return varchar2 is
begin
 if txn_id like 'SEED%' then
  return trim(substr(txn_id,6,15));
 else
  return trim(substr(txn_id,1,30));
 end if;
end;

function get_person_id(txn_id varchar2) return number is
cursor get_person_id is
select person_id
from psp_eff_reports
where effort_report_id in
    (select effort_report_id
       from psp_eff_report_details
     where effort_report_detail_id = substr(txn_id, 36,15));
l_person_id number;
begin
 if txn_id like  'SEED-EMP%' or
    txn_id like 'SEED-ESU%' or
    txn_id like 'SEED-SUP%' then
   l_person_id := to_number(substr(txn_id,21,15));
 elsif txn_id not like 'SEED%' then
  open get_person_id;
  fetch get_person_id into l_person_id;
  close get_person_id;
 else
    l_person_id := null;
 end if;
 return l_person_id;
exception
when others then
  return null;
end;

function get_eff_Report_detail_id(txn_id varchar2) return number is
begin
 return to_number(substr(txn_id,36,15));
end;

function get_task_id(txn_id varchar2) return number is
begin
 if txn_id like 'SEED-TMG%' then
   return to_number(substr(txn_id,21,15));
 else
   return -999;
 end if;
end;

function get_project_id(txn_id varchar2) return number is
begin
 if txn_id like 'SEED-PMG%' then
   return to_number(substr(txn_id,21,15));
 else
   return -999;
 end if;
end;

function get_emp_term_flag(txn_id varchar2) return varchar2 is
  term_flag varchar2(1);
  cursor term_cur is
    select nvl(current_employee_flag,'N')
     from per_all_people_f
    where person_id = get_person_id(txn_id)
      and sysdate between effective_start_date and effective_end_date;
begin
  open term_cur;
  fetch term_cur into term_flag;
  if term_cur%notfound then
       term_flag := 'N';
  end if;
  close term_cur;
  return term_flag;
end;

/*Added for Bug 6786413*/
function get_user_id_flag(txn_id varchar2) return varchar2 is
  userid_flag varchar2(1);
  userid_count number;
begin
  select count(*) into userid_count
       from fnd_user
      where employee_id = get_person_id(txn_id)
      and trunc(sysdate) between start_date and nvl(end_date,sysdate);

  if (userid_count > 0) then
      userid_flag := 'Y';
  else
      userid_flag := 'N';
  end if;
  return userid_flag;
end;

 ----- ===== End of AME functions

--	Introduced the following for bug fix 3867234
PROCEDURE	add_report_error(p_request_id		IN		NUMBER,
				p_message_level		IN		VARCHAR2,
				p_source_id		IN		NUMBER,
				p_error_message		IN		VARCHAR2,
				p_payroll_action_id	IN		NUMBER,
				p_return_status		OUT	NOCOPY	VARCHAR2,
				p_source_name		IN		VARCHAR2	DEFAULT NULL,
				p_parent_source_id	IN		NUMBER		DEFAULT NULL,
				p_parent_source_name	IN		VARCHAR2	DEFAULT NULL,
				p_value1		IN		NUMBER		DEFAULT NULL,
				p_value2		IN		NUMBER		DEFAULT NULL,
				p_value3		IN		NUMBER		DEFAULT NULL,
				p_value4		IN		NUMBER		DEFAULT NULL,
				p_value5		IN		NUMBER		DEFAULT NULL,
				p_value6		IN		NUMBER		DEFAULT NULL,
				p_value7		IN		NUMBER		DEFAULT NULL,
				p_value8		IN		NUMBER		DEFAULT NULL,
				p_value9		IN		NUMBER		DEFAULT NULL,
				p_value10		IN		NUMBER		DEFAULT NULL,
				p_information1		IN		VARCHAR2	DEFAULT NULL,
				p_information2		IN		VARCHAR2	DEFAULT NULL,
				p_information3		IN		VARCHAR2	DEFAULT NULL,
				p_information4		IN		VARCHAR2	DEFAULT NULL,
				p_information5		IN		VARCHAR2	DEFAULT NULL,
				p_information6		IN		VARCHAR2	DEFAULT NULL,
				p_information7		IN		VARCHAR2	DEFAULT NULL,
				p_information8		IN		VARCHAR2	DEFAULT NULL,
				p_information9		IN		VARCHAR2	DEFAULT NULL,
				p_information10		IN		VARCHAR2	DEFAULT NULL) IS
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
	INSERT INTO psp_report_errors
		(error_sequence_id,		request_id,		message_level,
		source_id,			error_message,		payroll_action_id,
		source_name,			parent_source_id,	parent_source_name,
		value1,		value2,		value3,		value4,		value5,
		value6,		value7,		value8,		value9,		value10,
		information1,	information2,	information3,	information4,	information5,
		information6,	information7,	information8,	information9,	information10)
	VALUES
		(psp_report_errors_s.NEXTVAL,	p_request_id,		p_message_level,
		p_source_id,			p_error_message,	p_payroll_action_id,
		p_source_name,			p_parent_source_id,	p_parent_source_name,
		p_value1,	p_value2,	p_value3,	p_value4,	p_value5,
		p_value6,	p_value7,	p_value8,	p_value9,	p_value10,
		p_information1,	p_information2,	p_information3,	p_information4,	p_information5,
		p_information6,	p_information7,	p_information8,	p_information9,	p_information10);

	COMMIT;

	p_return_status := 'S';
EXCEPTION
	WHEN OTHERS THEN
		p_return_status := 'E';
END;

PROCEDURE	add_report_error(p_request_id	IN		NUMBER,
				p_message_level	IN		VARCHAR2,
				p_source_id	IN		NUMBER,
				p_retry_request_id	IN		NUMBER,
				p_pdf_request_id	IN		NUMBER,
				p_error_message	IN		VARCHAR2,
				p_return_status	OUT	NOCOPY	VARCHAR2) IS
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
	INSERT INTO psp_report_errors
		(error_sequence_id,		request_id,			message_level,	source_id,
		retry_request_id,		pdf_request_id,		error_message)
	VALUES
		(psp_report_errors_s.NEXTVAL,	p_request_id,	p_message_level,	p_source_id,
		p_retry_request_id,		p_pdf_request_id,	p_error_message);

	COMMIT;

	p_return_status := 'S';
EXCEPTION
	WHEN OTHERS THEN
		p_return_status := 'E';
END;
--	End of changes for bug fix 3867234

-- Introduced the following for bug fix 4022334
FUNCTION IS_EFFORT_REPORT_MIGRATED
RETURN BOOLEAN
IS
  l_curr_er_phase NUMBER;
  er_flag BOOLEAN;
BEGIN
  SELECT NVL(MAX(PHASE),0) INTO l_curr_er_phase FROM PSP_UPGRADE_115 WHERE STATUS ='R' ;
  IF  l_curr_er_phase = 10000 THEN
     er_flag := TRUE;
  ELSE
     er_flag := FALSE;
  END IF;
  RETURN er_flag;
END IS_EFFORT_REPORT_MIGRATED;
-- End of changes for bug fix 4022334

-- Start of Bug 7137755
FUNCTION GET_PRE_APP_EMP_LIST(P_REQUEST_ID IN NUMBER)
RETURN VARCHAR2
IS
  l_emp_list  VARCHAR2(4000) ;
  l_full_name VARCHAR2(50);
  i           NUMBER := 0;

  CURSOR get_emp_cur IS
    SELECT distinct full_name FROM psp_eff_reports
    WHERE request_id = p_request_id;

BEGIN
   l_emp_list := NULL;
   open get_emp_cur;
   LOOP
      fetch get_emp_cur into l_full_name;
      EXIT WHEN get_emp_cur%NOTFOUND;

      i := i + 1;
       l_emp_list := l_emp_list || ' (' || i || ') ' || l_full_name ;

   END LOOP;
   close get_emp_cur;
   return l_emp_list;
END;


FUNCTION GET_APP_REJ_EMP_LIST(P_WF_ITEM_KEY IN VARCHAR2)
RETURN VARCHAR2
IS
  l_emp_list  VARCHAR2(4000) ;
  l_full_name VARCHAR2(50);
  i           NUMBER := 0;

  -- Modified cursor for Bug 7524262
  CURSOR get_emp_cur IS
    SELECT DISTINCT per.full_name
    FROM psp_eff_reports per,
      psp_eff_report_details perd,
      psp_eff_report_approvals pera
    WHERE pera.wf_item_key = p_wf_item_key
     AND pera.effort_report_detail_id = perd.effort_report_detail_id
     AND perd.effort_report_id = per.effort_report_id;

BEGIN
   l_emp_list := NULL;
   open get_emp_cur;
   LOOP
      fetch get_emp_cur into l_full_name;
      EXIT WHEN get_emp_cur%NOTFOUND;

      i := i + 1;
       l_emp_list := l_emp_list || ' (' || i || ') ' || l_full_name ;

   END LOOP;
   close get_emp_cur;
   return l_emp_list;
END;

-- End of Bug 7137755

-- Start BUG 4244924YALE ENHANCEMENTS. Added additional paramater for Salary cap
function GET_CONFIGURATION_OPTION_VALUE(p_business_group_id IN NUMBER,
                                        p_pcv_information_category in varchar2,
                                        p_pcv_information1 in varchar2 default null) return varchar2 IS
    Cursor get_CONFIGURATION_OPTION_CSR IS
    select 1 hierarchy, PCV_INFORMATION1 , pcv_information2
    from pqp_configuration_values
    where PCV_INFORMATION_CATEGORY = p_PCV_INFORMATION_CATEGORY
    and BUSINESS_GROUP_ID = p_business_group_id
    and (p_pcv_information1 is null
      or p_pcv_information1 =  pcv_information1)
    UNION ALL
    select 2 hierarchy, PCV_INFORMATION1 , pcv_information2
    from pqp_configuration_values
    where PCV_INFORMATION_CATEGORY = p_PCV_INFORMATION_CATEGORY
    and BUSINESS_GROUP_ID IS NULL
    and (p_pcv_information1 is null
      or p_pcv_information1 =  pcv_information1)
    ORDER BY 1;

    l_PCV_INFORMATION1 varchar2(30);
    l_PCV_INFORMATION2 varchar2(30);
    l_hierarchy Number;

BEGIN
    Open get_CONFIGURATION_OPTION_CSR;
        fetch get_CONFIGURATION_OPTION_CSR into l_hierarchy,l_PCV_INFORMATION1 ,
                                                            l_pcv_information2;
    close get_CONFIGURATION_OPTION_CSR ;
    if p_pcv_information_category not in ( 'PSP_CAP_ELEMENT_SET_ID', 'PSP_GENERIC_EXCESS_ACCT_ORG') then
      l_PCV_INFORMATION1 := NVL(l_PCV_INFORMATION1,'N');
    end if;
    if p_pcv_information1 is null then
      return l_PCV_INFORMATION1;
    else
      return l_PCV_INFORMATION2;
    end if;
END;

Procedure GET_GL_PTAOE_MAPPING(p_business_group_id IN NUMBER,
                                              p_proj_segment OUT NOCOPY varchar2, p_tsk_segment OUT NOCOPY varchar2,
                                              p_awd_sgement OUT NOCOPY varchar2, p_exp_org_segment OUT NOCOPY varchar2,
                                              p_exp_type_segment OUT NOCOPY varchar2) is

    Cursor get_GL_APTOE_MAPPING_CSR(p_business_group_id IN NUMBER) IS
    select 1 hierarchy, PCV_INFORMATION1,PCV_INFORMATION2,PCV_INFORMATION3,PCV_INFORMATION4,PCV_INFORMATION5
    from pqp_configuration_values
    where PCV_INFORMATION_CATEGORY = 'PSP_GL_PTAOE_MAPPING'
    and BUSINESS_GROUP_ID = p_business_group_id
    UNION ALL
    select 2 hierarchy, PCV_INFORMATION1,PCV_INFORMATION2,PCV_INFORMATION3,PCV_INFORMATION4,PCV_INFORMATION5
    from pqp_configuration_values
    where PCV_INFORMATION_CATEGORY = 'PSP_GL_PTAOE_MAPPING'
    and BUSINESS_GROUP_ID is null
    ORDER BY 1;

    l_hierarchy Number;
Begin
        open get_GL_APTOE_MAPPING_CSR(p_business_group_id);
            fetch get_GL_APTOE_MAPPING_CSR into l_hierarchy, p_proj_segment, p_tsk_segment, p_awd_sgement, p_exp_org_segment, p_exp_type_segment;
        Close get_GL_APTOE_MAPPING_CSR;
--        if  p_proj_segment is null or p_tsk_segment is null or p_awd_sgement is null
--        or p_exp_org_segment is null or  p_exp_type_segment is null then
--        Raise;
--        end if;
EXCEPTION
      WHEN OTHERS THEN
        raise;
END GET_GL_PTAOE_MAPPING;

-- END BUG 4244924 YALE ENHANCEMENTS

--Bug 4334816:Function added for Effort Report Status Monitor
FUNCTION Is_eff_Report_status_changed (p_status_code IN Varchar2, p_wf_itrm_key IN Number)
return varchar2 IS
    Cursor Is_eff_Report_superseded_csr(p_status_code IN Varchar2, p_wf_itrm_key IN Number) IS
    select 'Y'
    from psp_eff_reports per,
    psp_eff_report_details perd,
    psp_eff_report_approvals pera
    where per.EFFORT_REPORT_ID = perd.EFFORT_REPORT_ID
    and perd.EFFORT_REPORT_DETAIL_ID = pera.EFFORT_REPORT_DETAIL_ID
    AND per.STATUS_CODE = p_status_code
    and WF_ITEM_KEY = p_wf_itrm_key;

    Cursor Is_new_eff_Report_created_csr(p_status_code IN Varchar2, p_wf_itrm_key IN Number) IS
    select 'Y'
    from psp_eff_reports per,
    (select person_id ,STATUS_CODE, per.Start_date,per.end_date,per.EFFORT_REPORT_ID
    from psp_eff_reports per,
    psp_eff_report_details perd,
    psp_eff_report_approvals pera
    where per.EFFORT_REPORT_ID = perd.EFFORT_REPORT_ID
    and     perd.EFFORT_REPORT_DETAIL_ID = pera.EFFORT_REPORT_DETAIL_ID
    AND per.STATUS_CODE = p_status_code
    and pera.WF_ITEM_KEY = p_wf_itrm_key) temp
    where per.person_id = temp.person_id
    and per.start_date = temp.start_date
    and per.end_date = temp.end_date
    AND per.EFFORT_REPORT_ID > temp.EFFORT_REPORT_ID;

    l_data_Exist_flag varchar2(1) ;
BEGIN
    IF p_status_code = 'S' THEN
        open Is_eff_Report_superseded_csr(p_status_code,p_wf_itrm_key);
            fetch Is_eff_Report_superseded_csr into l_data_Exist_flag;
        close  Is_eff_Report_superseded_csr;
        l_data_Exist_flag := NVL(l_data_Exist_flag,'N');
    ELSE
        open Is_new_eff_Report_created_csr(p_status_code,p_wf_itrm_key);
            fetch Is_new_eff_Report_created_csr into  l_data_Exist_flag;
        close Is_new_eff_Report_created_csr;
        l_data_Exist_flag := NVL(l_data_Exist_flag,'N');
    END IF;
    return l_data_Exist_flag;
END;

-- New function to display assignment_status in labor schedules
-- bug 3887531 ,2889182
FUNCTION get_assignment_status( P_ASSIGNMENT_ID IN NUMBER ,
                                 P_EFFECTIVE_DATE IN DATE )
RETURN VARCHAR2 IS


cursor eff_dates_csr is
select max(paf.effective_end_date)
from   per_assignments_f paf
where  paf.assignment_id =  p_assignment_id;


l_date  date ;
l_effective_date date;

 cursor fetch_asg_status_csr(P_ASSIGNMENT_ID IN NUMBER,P_EFFECTIVE_DATE IN DATE )is
 select past.USER_STATUS
 from   per_assignment_status_types past ,
        per_assignments_f  paf
 where  paf.assignment_id = p_assignment_id
 and    past.ASSIGNMENT_STATUS_TYPE_ID = paf.ASSIGNMENT_STATUS_TYPE_ID
 and    p_effective_date  between paf.effective_start_date and paf.effective_end_date;

 L_USER_STATUS per_assignment_status_types. USER_STATUS%TYPE;

begin

 open eff_dates_csr;
 fetch eff_dates_csr into l_date ;
 close eff_dates_csr ;

  if (l_date < P_EFFECTIVE_DATE )
  then
   L_USER_STATUS := 'End' ;
  else
  l_EFFECTIVE_DATE := p_effective_date ;
   OPEN fetch_asg_status_csr(P_ASSIGNMENT_ID,l_EFFECTIVE_DATE) ;
   FETCH fetch_asg_status_csr INTO L_USER_STATUS;
   CLOSE fetch_asg_status_csr;
  end if ;



 RETURN L_USER_STATUS ;

END ;

--R12 MOAC Uptake

PROCEDURE INIT_MOAC IS
BEGIN
        mo_global.init ('PSP');
        mo_global.set_policy_context('M', null);
END INIT_MOAC;


FUNCTION Get_transaction_org_id (p_project_id Number,p_expenditure_organization_id Number)
RETURN NUMBER IS

        l_org_id Number(15);
BEGIN
        IF (p_project_id = G_PREV_PROJ_ID) THEN
        l_org_id := G_PREV_ORG_ID;
        ELSE
/*
        If PA_UTILS.IsCrossChargeable(p_project_id) Then
        -- get the org_id for the Expenditure Org..
        BEGIN
            SELECT org_id
            INTO   l_org_id
            FROM   PA_ALL_ORGANIZATIONS
            WHERE  PA_ORG_USE_TYPE = 'EXPENDITURES'
            AND    organization_id = p_expenditure_organization_id
            AND    rownum=1;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END;
        Else
*/
        -- get the org_id for the project..
        BEGIN
            SELECT org_id
            INTO   l_org_id
            FROM   pa_projects_all
            WHERE  project_id = p_project_Id;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END;
--      END IF;
        G_PREV_PROJ_ID := p_project_id;
        G_PREV_ORG_ID := l_org_id;
        END IF;

        Return l_org_id;
END Get_transaction_org_id;


END psp_general;

/
