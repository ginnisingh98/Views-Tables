--------------------------------------------------------
--  DDL for Package Body HXT_TIME_CLOCK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXT_TIME_CLOCK" AS
/* $Header: hxttclk.pkb 120.0 2005/05/29 05:58:03 appldev noship $ */

FUNCTION get_time_period(i_payroll_id IN NUMBER,
			i_date_worked IN DATE,
			o_time_period OUT NOCOPY NUMBER,
			o_start_date OUT NOCOPY DATE,
			o_end_date OUT NOCOPY DATE)RETURN NUMBER;
FUNCTION check_for_timecard(i_person_id IN NUMBER,
			    i_time_period_id IN NUMBER,
			    o_timecard_id OUT NOCOPY NUMBER,
			    o_auto_gen_flag OUT NOCOPY VARCHAR2)RETURN NUMBER;
FUNCTION create_timecard(i_person_id IN NUMBER,
			i_assignment_id IN NUMBER,
			i_payroll_id IN NUMBER,
			i_time_period_id IN NUMBER,
			o_timecard_id OUT NOCOPY NUMBER)RETURN NUMBER;
FUNCTION create_batch(	i_source IN VARCHAR2,
		 	i_payroll_id IN NUMBER,
			i_time_period_id IN NUMBER,
			i_assignment_id IN NUMBER,
			i_person_id IN NUMBER,
			o_batch_id OUT NOCOPY NUMBER) RETURN NUMBER;
--BEGIN SIR343
--FUNCTION find_existing_batch(o_batch_id OUT NUMBER)RETURN NUMBER;
FUNCTION find_existing_batch(i_payroll_id IN NUMBER,
                             i_time_period_id IN NUMBER,
                             o_batch_id OUT NOCOPY NUMBER)RETURN NUMBER;
--END SIR343
FUNCTION create_holiday_hours(	i_person_id IN NUMBER,
				i_hcl_id IN NUMBER,
				i_hxt_rotation_plan IN NUMBER,  --SIR344
				i_start_date IN DATE,
				i_end_date IN DATE,
				i_timecard_id IN NUMBER,
				i_assignment_id IN NUMBER)RETURN NUMBER;
FUNCTION record_hours_worked( 	b_generate_holiday IN BOOLEAN,
				i_timecard_id IN NUMBER,
				i_assignment_id IN NUMBER,
				i_person_id IN NUMBER,
				i_date_worked IN DATE,
				i_element_id IN NUMBER,
				i_hours IN NUMBER,
				i_start_time IN DATE,
				i_end_time IN DATE,
				i_start_date IN DATE)RETURN NUMBER;
PROCEDURE record_time( 	employee_number IN VARCHAR2,
			assignment_id IN NUMBER,
			start_time IN DATE,
			end_time IN DATE,
			ret_code OUT NOCOPY NUMBER,
			err_buf OUT NOCOPY VARCHAR2)IS
l_person_id		per_people_f.person_id%TYPE		DEFAULT NULL;
l_last_name		per_people_f.last_name%TYPE		DEFAULT NULL;
l_first_name		per_people_f.first_name%TYPE		DEFAULT NULL;
l_bus_grp_id            per_assignments_f.business_group_id%TYPE DEFAULT NULL;
l_timecard_id		hxt_timecards.id%TYPE			DEFAULT NULL;
l_date_worked		DATE					DEFAULT NULL;
l_time_period_id	per_time_periods.time_period_id%TYPE	DEFAULT NULL;
l_start_date		DATE					DEFAULT NULL;
l_end_date		DATE					DEFAULT NULL;
l_auto_gen_flag		hxt_timecards.auto_gen_flag%TYPE		DEFAULT NULL;
l_timecard_exists	BOOLEAN					DEFAULT TRUE;
l_hours			NUMBER					DEFAULT NULL;
l_person_id_data_err	EXCEPTION;
l_person_id_sys_err	EXCEPTION;
l_assign_id_data_err	EXCEPTION;
l_assign_id_sys_err	EXCEPTION;
l_pay_date_data_err	EXCEPTION;
l_pay_date_sys_err	EXCEPTION;
l_time_per_data_err	EXCEPTION;
l_time_per_sys_err	EXCEPTION;
l_istimecard_sys_err	EXCEPTION;
l_make_card_data_err	EXCEPTION;
l_make_card_sys_err	EXCEPTION;
l_make_hol_data_err	EXCEPTION;
l_make_hol_sys_err	EXCEPTION;
l_autogen_error		EXCEPTION;
l_rec_hours_data_err	EXCEPTION;
l_rec_hours_sys_err	EXCEPTION;
l_retcode		NUMBER					DEFAULT 0;
l_error_text		VARCHAR2(240)				DEFAULT NULL;
l_exists		VARCHAR2(1);
CURSOR l_employee_cur(c_person_id NUMBER) IS
  SELECT asm.payroll_id,
	 asm.assignment_id,
	 asm.business_group_id,   --GLOBAL
         asm.effective_start_date,
         asm.effective_end_date,
         aeiv.hxt_rotation_plan,  --SIR344
         egp.hcl_id
    FROM hxt_earning_policies egp,
--ORACLE         per_assignments_f_dfv asmv,
         hxt_per_aei_ddf_v aeiv,--ORACLE
         per_assignment_status_types ast,
         per_assignments_f asm
   WHERE c_person_id = asm.person_id
     AND ast.assignment_status_type_id = asm.assignment_status_type_id
     AND ast.pay_system_status = 'P'	-- Check payroll status
--ORACLE     AND asmv.row_id = asm.rowid
     AND aeiv.assignment_id = asm.assignment_id  --ORACLE
     AND l_date_worked BETWEEN aeiv.effective_start_date     /* GLOBAL */
                           AND aeiv.effective_end_date       /* GLOBAL */
/*GLOBAL     AND aeiv.information_type = 'HXT_ASS_INFO'  --ORACLE */
--ORACLE     AND egp.id(+) = asmv.hxt_earning_policy;
     AND egp.id(+) = aeiv.hxt_earning_policy;    --ORACLE
l_emp_rec l_employee_cur%ROWTYPE;
--
-- Fassadi 25/OCT/00  Get the Bug_id for the get_person_id procedure.
--
Cursor  l_bus_grp_cur ( p_asg_id NUMBER ) is
  select business_group_id
  from per_assignments_f asm
  where asm.assignment_id = p_asg_id;

--this to fix bug 756293
--
cursor C_session_exists is
select 'Y'
from  fnd_sessions
where session_id = userenv('sessionid')
and   trunc(effective_date) = trunc(sysdate);
--
--
BEGIN
  /*Obtain date worked from user exit*/

-- Before anything insert a row in fdn_sessions.
-- fix for bug 756293
open  C_session_exists;
 fetch C_session_exists into l_exists;
 if C_session_exists%notfound then
    insert into fnd_sessions
  (effective_date, session_id)
  values (sysdate, userenv('sessionid'));
 HXT_UTIL.DEBUG('Inserted a row in fnd session '); --HXT115
 end if;
 close C_session_exists;
 --
 -- End of fix for bug 756293

--
  l_retcode := hxt_clock_user_edits.determine_pay_date(	start_time,
							end_time,
							l_person_id,
							l_date_worked);
  HXT_UTIL.DEBUG('determine_pay_date returns: '|| fnd_date.date_to_chardate(l_date_worked));--DEBUG ONLY --FORMS60 --HXT115
  IF l_retcode = 1 THEN
    RAISE l_pay_date_data_err;
  ELSIF l_retcode = 2 THEN
    RAISE l_pay_date_sys_err;
  END IF;
--
--  Get the bus_grp_id to pass it to the get_person_id procedure.
--
  BEGIN
    OPEN l_bus_grp_cur ( assignment_id );
    FETCH l_bus_grp_cur INTO l_bus_grp_id;
    CLOSE l_bus_grp_cur;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
         l_retcode := 1;
         RAISE l_assign_id_data_err;
      WHEN OTHERS THEN
         l_retcode := 2;
         RAISE l_assign_id_sys_err;
  END;
--
  /* Obtain person id from user exit */
  l_retcode := hxt_clock_user_edits.get_person_id(employee_number,
					        l_bus_grp_id,
                                                l_date_worked,
						l_person_id,
						l_last_name,
						l_first_name);
  HXT_UTIL.DEBUG('get_person_id returns: '|| TO_CHAR(l_retcode));--DEBUG ONLY --HXT115
  IF l_retcode = 1 THEN
    RAISE l_person_id_data_err;
  ELSIF l_retcode = 2 THEN
    RAISE l_person_id_sys_err;
  END IF;
  --
  /* Obtain vital employee information*/
  BEGIN
    HXT_UTIL.DEBUG('Opening Cursor');--DEBUG ONLY --HXT115
    OPEN l_employee_cur(l_person_id);
    HXT_UTIL.DEBUG('Fetching Cursor');--DEBUG ONLY --HXT115
    FETCH l_employee_cur
     INTO l_emp_rec;
    HXT_UTIL.DEBUG('Closing Cursor');--DEBUG ONLY --HXT115
    CLOSE l_employee_cur;
    g_bus_group_id := l_emp_rec.business_group_id;  --GLOBAL
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
         l_retcode := 1;
         RAISE l_assign_id_data_err;
      WHEN OTHERS THEN
         l_retcode := 2;
         RAISE l_assign_id_sys_err;
  END;
  --DEBUG ONLY BEGIN
  HXT_UTIL.DEBUG('Payroll id :               '||TO_CHAR(l_emp_rec.payroll_id)); --HXT115
  HXT_UTIL.DEBUG('Assignment id:             '||TO_CHAR(l_emp_rec.assignment_id)); --HXT115
  HXT_UTIL.DEBUG('Business Group id:         '||TO_CHAR(l_emp_rec.business_group_id)); --GLOBAL
  HXT_UTIL.DEBUG('Effective Start Date:      '||fnd_date.date_to_chardate(l_emp_rec.effective_start_date)); --FORMS60 --HXT115
  HXT_UTIL.DEBUG('Effective End Date:        '||fnd_date.date_to_chardate(l_emp_rec.effective_end_date)); --FORMS60 --HXT115
  HXT_UTIL.DEBUG('hcl_id:                    '||TO_CHAR(l_emp_rec.hcl_id)); --HXT115
  HXT_UTIL.DEBUG('hxt_rotation_plan:         '||l_emp_rec.hxt_rotation_plan);  --SIR344 --HXT115
  --DEBUG ONLY END
  --
   /*Obtain the current time period id for this payroll and date*/
  l_retcode := get_time_period(	l_emp_rec.payroll_id,
				l_date_worked,
				l_time_period_id,
				l_start_date,
				l_end_date);
  HXT_UTIL.DEBUG('get_time_period returns period: '|| --HXT115
			TO_CHAR(l_time_period_id)|| ' start date: '||
			fnd_date.date_to_chardate(l_start_date)|| ' end date: '|| -- FORMS60
			fnd_date.date_to_chardate(l_end_date));--DEBUG ONLY --FORMS60
  IF l_retcode = 1 THEN
    RAISE l_time_per_data_err;
  ELSIF l_retcode = 2 THEN
     RAISE l_time_per_data_err;
  END IF;
  g_time_period_err_id := l_time_period_id;
  --
   /*Determine effective start date*/
  IF l_emp_rec.effective_start_date > l_start_date THEN
    l_start_date := l_emp_rec.effective_start_date;
  END IF;
  IF l_emp_rec.effective_end_date < l_end_date THEN
    l_end_date := l_emp_rec.effective_end_date;
  END IF;
  --
  /*Check for an existing timecard */
  l_retcode := check_for_timecard(l_person_id, l_time_period_id, l_timecard_id, l_auto_gen_flag);
  HXT_UTIL.DEBUG('check_for_timecard returns timecard id: '|| TO_CHAR(l_timecard_id));--DEBUG ONLY --HXT115
  --
  IF l_retcode = 0 THEN
     g_timecard_err_id := l_timecard_id;
  ELSIF l_retcode = 1 THEN
     /*Create a timecard when none exists*/
     l_retcode := create_timecard(l_person_id,
				l_emp_rec.assignment_id,
				l_emp_rec.payroll_id,
				l_time_period_id,
				l_timecard_id);
     IF l_retcode = 1 THEN
       RAISE l_make_card_data_err;
     ELSIF l_retcode = 2 THEN
       RAISE l_make_card_sys_err;
     END IF;
     g_timecard_err_id := l_timecard_id;
     /*Create holiday hours on the new timecard*/
     HXT_UTIL.DEBUG('Now generating holidays'); --HXT115
     l_retcode := create_holiday_hours(l_person_id,
					l_emp_rec.hcl_id,
					l_emp_rec.hxt_rotation_plan,  --SIR344
					l_start_date,
					l_end_date,
					l_timecard_id,
					l_emp_rec.assignment_id);
     IF l_retcode = 1 THEN
       RAISE l_make_hol_data_err;
     ELSIF l_retcode = 2 THEN
       RAISE l_make_hol_sys_err;
     END IF;
  ELSIF l_retcode = 2 THEN
    RAISE l_istimecard_sys_err;
  END IF;
  HXT_UTIL.DEBUG('Hours will be charged to Timecard id: '||TO_CHAR(l_timecard_id));--DEBUG ONLY --HXT115
  --
  /*Check to see if pre-existing timecards were autogened*/
  IF l_auto_gen_flag = 'A' THEN
    RAISE l_autogen_error;
  END IF;
  --
  /*Calculate the hours worked*/
  l_hours := 24 * (TRUNC(end_time,'MI') - TRUNC(start_time,'MI'));
  HXT_UTIL.DEBUG('Hours worked: '||TO_CHAR(l_hours));--DEBUG ONLY --HXT115
  /*Insert hours to the hxt_hours_worked table and call generate details*/
  l_retcode := record_hours_worked( FALSE,
				l_timecard_id,
				l_emp_rec.assignment_id,
				l_person_id,
				l_date_worked,
				NULL,
				l_hours,
				start_time,
				end_time,
				l_start_date);
  IF l_retcode = 1 THEN
    RAISE l_rec_hours_data_err;
  ELSIF l_retcode = 2 THEN
    RAISE l_rec_hours_sys_err;
  END IF;
  ret_code := 0;
  --HXT11err_buf := 'Successful Completion. Time has posted.';
  FND_MESSAGE.SET_NAME('HXT','HXT_39400_TIME_POSTED');  -- HXT11
  err_buf := FND_MESSAGE.GET; -- HXT11
  FND_MESSAGE.CLEAR;     -- HXT11

  RETURN;
 EXCEPTION
  WHEN l_person_id_data_err THEN
    ret_code := l_retcode;
    --HXT11err_buf := 'Data Error: Query Error Form for ACLOCK';
    FND_MESSAGE.SET_NAME('HXT','HXT_39401_QRY_ERR_DATA');  -- HXT11
    err_buf := FND_MESSAGE.GET; -- HXT11
    FND_MESSAGE.CLEAR;     -- HXT11

    --HXT11l_error_text  := 'No Employee was located for Employee Number ' || employee_number;
    FND_MESSAGE.SET_NAME('HXT','HXT_39308_EMPLYEE_NF');  -- HXT11
    FND_MESSAGE.SET_TOKEN('EMP_NUMBER', employee_number); --HXT11
    l_retcode := log_clock_errors(FALSE, NULL,'EMPL', NULL);
    RETURN;

  WHEN l_person_id_sys_err THEN
    ret_code := l_retcode;
    --HXT11err_buf := 'Sys. Error: Query Error Form for ACLOCK';
    FND_MESSAGE.SET_NAME('HXT','HXT_39402_QRY_ERR_SYS');  -- HXT11
    err_buf := FND_MESSAGE.GET; -- HXT11
    FND_MESSAGE.CLEAR;     -- HXT11

    --HXT11l_error_text  := 'System Error occurred while attempting to access Employee Data.' ||
                     --HXT11'Employee Number ' || employee_number ||
                     --HXT11'Function hxt_clock_user_edits.get_person_id';
    FND_MESSAGE.SET_NAME('HXT','HXT_39308_EMPLYEE_NF');  -- HXT11
    FND_MESSAGE.SET_TOKEN('EMP_NUMBER', employee_number); --HXT11
    l_retcode := log_clock_errors(FALSE, NULL,'EMPL', SQLERRM);
    RETURN;

  WHEN l_assign_id_data_err THEN
    ret_code := l_retcode;
    --HXT11err_buf := 'Data Error: Query Error Form for ACLOCK';
    FND_MESSAGE.SET_NAME('HXT','HXT_39401_QRY_ERR_DATA');  -- HXT11
    err_buf := FND_MESSAGE.GET; -- HXT11
    FND_MESSAGE.CLEAR;     -- HXT11

    --HXT11l_error_text  := 'No Assignment was located for '||l_first_name||' '||l_last_name||
          --HXT11           '(Employee Number: '|| employee_number ||').';
    FND_MESSAGE.SET_NAME('HXT','HXT_39306_ASSIGN_NF');  -- HXT11
    FND_MESSAGE.SET_TOKEN('FIRST_NAME', l_first_name); --HXT11
    FND_MESSAGE.SET_TOKEN('LAST_NAME', l_last_name); --HXT11
    FND_MESSAGE.SET_TOKEN('EMP_NUMBER', employee_number); --HXT11
    l_retcode := log_clock_errors(FALSE, NULL,'EMPL', NULL);
    RETURN;

  WHEN l_assign_id_sys_err THEN
    ret_code := l_retcode;
    --HXT11err_buf := 'Sys. Error: Query Error Form for ACLOCK';
    FND_MESSAGE.SET_NAME('HXT','HXT_39402_QRY_ERR_SYS');  -- HXT11
    err_buf := FND_MESSAGE.GET; -- HXT11
    FND_MESSAGE.CLEAR;     -- HXT11

    --HXT11l_error_text  := 'System Error occurred atempting to Fetch Assignment.';
    FND_MESSAGE.SET_NAME('HXT','HXT_39319_ERR_GET_ASSIGN');  -- HXT11
    l_retcode := log_clock_errors(FALSE, NULL,'EMPL', SQLERRM);
    RETURN;

  WHEN l_pay_date_data_err THEN
    ret_code := l_retcode;
    --HXT11err_buf := 'Data Error: Query Error Form for ACLOCK';
    FND_MESSAGE.SET_NAME('HXT','HXT_39401_QRY_ERR_DATA');  -- HXT11
    err_buf := FND_MESSAGE.GET; -- HXT11
    FND_MESSAGE.CLEAR;     -- HXT11

    --HXT11l_error_text  := 'Unable to determine date worked from user exit. Start time: ' || TO_CHAR(start_time);
    FND_MESSAGE.SET_NAME('HXT','HXT_39331_CANT_CALC_DAT_WRKED');  -- HXT11
    FND_MESSAGE.SET_TOKEN('START_TIME', TO_CHAR(start_time)); --HXT11
    l_retcode := log_clock_errors(FALSE, NULL,'EMPL', NULL);
    RETURN;

  WHEN l_pay_date_sys_err THEN
    ret_code := l_retcode;
    --HXT11err_buf := 'Sys. Error: Query Error Form for ACLOCK';
    FND_MESSAGE.SET_NAME('HXT','HXT_39402_QRY_ERR_SYS');  -- HXT11
    err_buf := FND_MESSAGE.GET; -- HXT11
    FND_MESSAGE.CLEAR;     -- HXT11

    --HXT11l_error_text  := 'System error occurred while attempting to determine date worked.';
    FND_MESSAGE.SET_NAME('HXT','HXT_39323_ERR_DATE_WRKED');  -- HXT11
    l_retcode := log_clock_errors(FALSE, NULL,'EMPL', SQLERRM);
    RETURN;

  WHEN l_time_per_data_err THEN
    ret_code := l_retcode;
    --HXT11err_buf := 'Data Error: Query Error Form for ACLOCK';
    FND_MESSAGE.SET_NAME('HXT','HXT_39401_QRY_ERR_DATA');  -- HXT11
    err_buf := FND_MESSAGE.GET; -- HXT11
    FND_MESSAGE.CLEAR;     -- HXT11

    --HXT11l_error_text  := 'Unable to determine a time period for date worked of: '||TO_CHAR(l_date_worked)||
			--HXT11' Payroll: '|| TO_CHAR(l_emp_rec.payroll_id);
    FND_MESSAGE.SET_NAME('HXT','HXT_39330_CANT_CALC_TIM_PER');  -- HXT11
    FND_MESSAGE.SET_TOKEN('DATE_WORKED', fnd_date.date_to_chardate(l_date_worked)); --HXT11 --FORMS60
    FND_MESSAGE.SET_TOKEN('PAYROLL', TO_CHAR(l_emp_rec.payroll_id)); --HXT11
    l_retcode := log_clock_errors(FALSE, NULL,'EMPL', NULL);
    RETURN;

  WHEN l_time_per_sys_err THEN
    ret_code := l_retcode;
    --HXT11err_buf := 'Sys. Error: Query Error Form for ACLOCK';
    FND_MESSAGE.SET_NAME('HXT','HXT_39402_QRY_ERR_SYS');  -- HXT11
    err_buf := FND_MESSAGE.GET; -- HXT11
    FND_MESSAGE.CLEAR;     -- HXT11

    --HXT11l_error_text  := 'System error occurred while attempting to obtain time period. ' || SQLERRM;
    FND_MESSAGE.SET_NAME('HXT','HXT_39324_ERR_TIME_PERIOD');  -- HXT11
    FND_MESSAGE.SET_TOKEN('SQLERR', SQLERRM); --HXT11
    l_retcode := log_clock_errors(FALSE, NULL,'EMPL', NULL);
    RETURN;

  WHEN l_istimecard_sys_err THEN
    ret_code := l_retcode;
    --HXT11err_buf := 'Sys. Error: Query Error Form for ACLOCK';
    FND_MESSAGE.SET_NAME('HXT','HXT_39402_QRY_ERR_SYS');  -- HXT11
    err_buf := FND_MESSAGE.GET; -- HXT11
    FND_MESSAGE.CLEAR;     -- HXT11

    --HXT11l_error_text  := 'Error occurred while checking for an existing timecard. ';
    FND_MESSAGE.SET_NAME('HXT','HXT_39298_ERR_GET_TIMCARD');  -- HXT11
    l_retcode := log_clock_errors(FALSE, NULL,'TIM', SQLERRM);
    RETURN;

  WHEN l_autogen_error THEN
    ret_code := l_retcode;
    --HXT11err_buf := 'Data Error: Query Error Form for ACLOCK';
    FND_MESSAGE.SET_NAME('HXT','HXT_39401_QRY_ERR_DATA');  -- HXT11
    err_buf := FND_MESSAGE.GET; -- HXT11
    FND_MESSAGE.CLEAR;     -- HXT11

    --HXT11l_error_text  := 'An autogen timecard exists for '||l_first_name||' '||l_last_name||
	  --HXT11' (Employee: '|| employee_number ||').'||
          --HXT11' Autogen timecards may not accept time from a timeclock.';
    FND_MESSAGE.SET_NAME('HXT','HXT_39267_AG_TCARD_EXISTS');  -- HXT11
    FND_MESSAGE.SET_TOKEN('FIRST_NAME', l_first_name); --HXT11
    FND_MESSAGE.SET_TOKEN('LAST_NAME', l_last_name); --HXT11
    FND_MESSAGE.SET_TOKEN('EMP_NUMBER', employee_number); --HXT11
    l_retcode := log_clock_errors(TRUE, NULL,'TIM', NULL);
    RETURN;

  WHEN l_make_card_data_err THEN
    ret_code := l_retcode;
    --HXT11err_buf := 'Data Error: Query Error Form for ACLOCK';
    FND_MESSAGE.SET_NAME('HXT','HXT_39401_QRY_ERR_DATA');  -- HXT11
    err_buf := FND_MESSAGE.GET; -- HXT11
    FND_MESSAGE.CLEAR;     -- HXT11

    --HXT11l_error_text  := 'Data Error during create timecard processing for '||
          --HXT11l_first_name||' '||l_last_name||' (Employee: '|| employee_number ||').';
    FND_MESSAGE.SET_NAME('HXT','HXT_39291_CRT_TCARD_ERR');  -- HXT11
    FND_MESSAGE.SET_TOKEN('FIRST_NAME', l_first_name); --HXT11
    FND_MESSAGE.SET_TOKEN('LAST_NAME', l_last_name); --HXT11
    FND_MESSAGE.SET_TOKEN('EMP_NUMBER', employee_number); --HXT11
    l_retcode := log_clock_errors(FALSE, NULL,'TIM', NULL);
    RETURN;

  WHEN l_make_card_sys_err THEN
    ret_code := l_retcode;
    --HXT11err_buf := 'Sys. Error: Query Error Form for ACLOCK';
    FND_MESSAGE.SET_NAME('HXT','HXT_39402_QRY_ERR_SYS');  -- HXT11
    err_buf := FND_MESSAGE.GET; -- HXT11
    FND_MESSAGE.CLEAR;     -- HXT11

    --HXT11l_error_text  := 'System error during create timecard processing for '||
          --HXT11           l_first_name||' '||l_last_name||' (Employee: '|| employee_number ||').';
    FND_MESSAGE.SET_NAME('HXT','HXT_39318_ERR_CREAT_TCARD');  -- HXT11
    FND_MESSAGE.SET_TOKEN('FIRST_NAME', l_first_name); --HXT11
    FND_MESSAGE.SET_TOKEN('LAST_NAME', l_last_name); --HXT11
    FND_MESSAGE.SET_TOKEN('EMP_NUMBER', employee_number); --HXT11
    l_retcode := log_clock_errors(FALSE, NULL,'TIM', SQLERRM);
    RETURN;

  WHEN l_make_hol_data_err THEN
    ret_code := l_retcode;
    --HXT11err_buf := 'Data Error: Query timecard for'|| TO_CHAR(l_date_worked); --SIR149
    FND_MESSAGE.SET_NAME('HXT','HXT_39404_QRY_DAT_TOK');  -- HXT11
    FND_MESSAGE.SET_TOKEN('1', fnd_date.date_to_chardate(l_date_worked)); --HXT11 --SIR149 --FORMS60
    err_buf := FND_MESSAGE.GET; -- HXT11
    FND_MESSAGE.CLEAR;     -- HXT11

    --HXT11l_error_text  := 'Data error occurred during create holiday hours processing for '||
          --HXT11           l_first_name||' '||l_last_name||' (Employee: '|| employee_number ||').';
    FND_MESSAGE.SET_NAME('HXT','HXT_39292_CRT_HOL_HRS');  -- HXT11
    FND_MESSAGE.SET_TOKEN('FIRST_NAME', l_first_name); --HXT11
    FND_MESSAGE.SET_TOKEN('LAST_NAME', l_last_name); --HXT11
    FND_MESSAGE.SET_TOKEN('EMP_NUMBER', employee_number); --HXT11
    l_retcode := log_clock_errors(TRUE, NULL,'HOL', NULL);
    RETURN;

  WHEN l_make_hol_sys_err THEN
    ret_code := l_retcode;
    --HXT11err_buf := 'Sys. Error: Query timecard for'|| TO_CHAR(l_date_worked); --SIR149
    FND_MESSAGE.SET_NAME('HXT','HXT_39405_QRY_SYS_TOK');  -- HXT11
    FND_MESSAGE.SET_TOKEN('1', fnd_date.date_to_chardate(l_date_worked)); --HXT11 --SIR149 --FORMS60
    err_buf := FND_MESSAGE.GET; -- HXT11
    FND_MESSAGE.CLEAR;     -- HXT11

    --HXT11l_error_text  := 'System error occurred during create holiday hours processing for '||
         --HXT11	l_first_name||' '||l_last_name||' (Employee: '|| employee_number ||').';
    FND_MESSAGE.SET_NAME('HXT','HXT_39320_ERR_CREAT_HOL');  -- HXT11
    FND_MESSAGE.SET_TOKEN('FIRST_NAME', l_first_name); --HXT11
    FND_MESSAGE.SET_TOKEN('LAST_NAME', l_last_name); --HXT11
    FND_MESSAGE.SET_TOKEN('EMP_NUMBER', employee_number); --HXT11
    l_retcode := log_clock_errors(TRUE, NULL,'HOL', SQLERRM);
    RETURN;

  WHEN l_rec_hours_data_err THEN
    ret_code := l_retcode;
    --HXT11err_buf := 'Data Error: Query timecard for'|| TO_CHAR(l_date_worked); --SIR149
    FND_MESSAGE.SET_NAME('HXT','HXT_39404_QRY_DAT_TOK');  -- HXT11
    FND_MESSAGE.SET_TOKEN('1', fnd_date.date_to_chardate(l_date_worked)); --HXT11 --SIR149 --FORMS60
    err_buf := FND_MESSAGE.GET; -- HXT11
    FND_MESSAGE.CLEAR;     -- HXT11

    --HXT11l_error_text  := 'Data Error occurred in the record hours functionality';
    FND_MESSAGE.SET_NAME('HXT','HXT_39293_REC_HRS_ERR');  -- HXT11
    l_retcode := log_clock_errors(TRUE, NULL,'RECHRS', NULL);
    RETURN;

  WHEN l_rec_hours_sys_err THEN
    ret_code := l_retcode;
    --HXT11err_buf := 'Sys. Error: Query timecard for'|| TO_CHAR(l_date_worked); --SIR149
    FND_MESSAGE.SET_NAME('HXT','HXT_39405_QRY_SYS_TOK');  -- HXT11
    FND_MESSAGE.SET_TOKEN('1', fnd_date.date_to_chardate(l_date_worked)); --HXT11 --SIR149 --FORMS60
    err_buf := FND_MESSAGE.GET; -- HXT11
    FND_MESSAGE.CLEAR;     -- HXT11

    --HXT11l_error_text  := 'System error occurred in the record hours functionality';
    FND_MESSAGE.SET_NAME('HXT','HXT_39321_ERR_REC_HRS');  -- HXT11
    l_retcode := log_clock_errors(TRUE, NULL,'RECHRS', SQLERRM);
    RETURN;

  WHEN g_error_log_error THEN
    --HXT11err_buf := 'Error in hxt_time_clock.log_clock_errors';
    FND_MESSAGE.SET_NAME('HXT','HXT_39403_LOG_ERR_ERR');  -- HXT11
    err_buf := FND_MESSAGE.GET; -- HXT11
    FND_MESSAGE.CLEAR;     -- HXT11

    HXT_UTIL.DEBUG('Error in hxt_time_clock.log_clock_errors'); --DEBUG ONLY --HXT115
    ret_code := 2;
    RETURN;

  WHEN OTHERS THEN
    --HXT11err_buf := 'Sys. Error: Query timecard for'|| TO_CHAR(l_date_worked); --SIR149
    FND_MESSAGE.SET_NAME('HXT','HXT_39405_QRY_SYS_TOK');  -- HXT11
    FND_MESSAGE.SET_TOKEN('1', fnd_date.date_to_chardate(l_date_worked)); --HXT11 --SIR149 --FORMS60
    err_buf := FND_MESSAGE.GET; -- HXT11
    FND_MESSAGE.CLEAR;     -- HXT11

    ret_code := 2;
    FND_MESSAGE.SET_NAME('HXT','HXT_39406_EXCP_REC_TIME');  -- HXT11
    l_retcode := log_clock_errors(FALSE, NULL,'TIMEXCP', SQLERRM);
    RETURN;
END record_time;
/***********************************
 get_time_period()
 Obtain the time period identifier
 for this particular pay date
************************************/
FUNCTION get_time_period(i_payroll_id IN NUMBER,
			i_date_worked IN DATE,
			o_time_period OUT NOCOPY NUMBER,
			o_start_date OUT NOCOPY DATE,
			o_end_date OUT NOCOPY DATE)RETURN NUMBER IS
BEGIN
  SELECT time_period_id,
         start_date,
         end_date
    INTO o_time_period,
         o_start_date,
         o_end_date
    FROM per_time_periods
   WHERE payroll_id = i_payroll_id
     AND TRUNC(i_date_worked) BETWEEN TRUNC(start_date) AND TRUNC(end_date);
  RETURN 0;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
       RETURN 1;
    WHEN OTHERS THEN
       RETURN 2;
END get_time_period;
/****************************************************
 check_for_timecard()
 Check the HXT_TIMECARDS table to see if a timecard
 already exists for the person punching the clock
****************************************************/
FUNCTION check_for_timecard(	i_person_id IN NUMBER,
				i_time_period_id IN NUMBER,
				o_timecard_id OUT NOCOPY NUMBER,
				o_auto_gen_flag OUT NOCOPY VARCHAR2)RETURN NUMBER IS
BEGIN
  SELECT id,
         auto_gen_flag,
	 batch_id
    INTO o_timecard_id,
         o_auto_gen_flag,
         g_batch_err_id
    FROM hxt_timecards
   WHERE for_person_id = i_person_id
     AND time_period_id = i_time_period_id;
  RETURN 0;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
       RETURN 1;
    WHEN OTHERS THEN
       RETURN 2;
END check_for_timecard;
/********************************************************
   create_timecard()
   Creates a timecard for the person punching the clock
   for this particular time period based on the payroll
   for this person.
*********************************************************/
FUNCTION create_timecard(i_person_id IN NUMBER,
			i_assignment_id IN NUMBER,
			i_payroll_id IN NUMBER,
			i_time_period_id IN NUMBER,
			o_timecard_id OUT NOCOPY NUMBER)RETURN NUMBER IS
  l_retcode               NUMBER                               DEFAULT 0;
  l_batch_creation_error  EXCEPTION;
  l_batch_location_error  EXCEPTION;
  l_tim_id_creation_error EXCEPTION;
--BEGIN GLOBAL
--  l_batch_id	          pay_pdt_batch_headers.batch_id%TYPE      DEFAULT NULL;
  l_batch_id	          pay_batch_headers.batch_id%TYPE          DEFAULT NULL;
--END GLOBAL
  l_timecard_id	          hxt_timecards.id%TYPE                     DEFAULT NULL;
BEGIN
  /* Obtain a batch id for the new timecard */
--BEGIN SIR343
--  l_retcode := find_existing_batch(l_batch_id);
  l_retcode := find_existing_batch(i_payroll_id,
                                   i_time_period_id,
                                   l_batch_id);
--END SIR343
  /* If Not Found */
  IF l_retcode = 1 THEN
    /* Create a batch id for the new timecard */
    HXT_UTIL.DEBUG('Creating new batch');	--DEBUG ONLY --HXT115
    l_retcode := create_batch(	'C',		--source is timeclock
			 	i_payroll_id,
				i_time_period_id,
				i_assignment_id,
				i_person_id,
				l_batch_id);
    IF l_retcode <> 0 THEN
      RAISE l_batch_creation_error;
    END IF;
  ELSIF l_retcode = 2 THEN
    RAISE l_batch_location_error;
  END IF;
  g_batch_err_id := l_batch_id;
  HXT_UTIL.DEBUG('Batch id is: '||TO_CHAR(l_batch_id));--DEBUG ONLY --HXT115
  /* Generate a unique timecard id for the new timecard */
  l_timecard_id := hxt_time_gen.Get_HXT_Seqno;
  IF l_timecard_id = NULL THEN
    RAISE l_tim_id_creation_error;
  END IF;
  HXT_UTIL.DEBUG('Timecard id is: '||TO_CHAR(l_timecard_id));--DEBUG ONLY --HXT115
  /* Insert new timecard info to hxt_timecards */
--SIR012  INSERT into hxt_timecards
  INSERT into hxt_timecards_f                                                        --SIR012
   ( id,
     for_person_id,
     payroll_id,
     time_period_id,
     batch_id,
     auto_gen_flag,
     created_by,
     creation_date
     , effective_start_date                                                          --SIR012
     , effective_end_date)                                                           --SIR012
  VALUES
   ( l_timecard_id,
     i_person_id,
     i_payroll_id,
     i_time_period_id,
     l_batch_id,
     'T',
     g_user_id,
     g_sysdate
     , g_sysdate                                                                     --SIR012
     ,hr_general.end_of_time);                                --SIR149 --FORMS60
   COMMIT;
   o_timecard_id := l_timecard_id;
   RETURN 0;
  EXCEPTION
    WHEN l_batch_creation_error THEN
       RETURN l_retcode;
    WHEN l_batch_location_error THEN
       RETURN l_retcode;
    WHEN l_tim_id_creation_error THEN
       FND_MESSAGE.SET_NAME('HXT','HXT_39407_CREATE_TIM');  -- HXT11
       l_retcode := log_clock_errors(FALSE, NULL,'TIMCRT', NULL);
       --HXT11l_retcode := log_clock_errors(FALSE, 'Error creating timecard id in hxt_time_gen.Get_HXT_Seqno','Timecard Creation', NULL);
       RETURN 2;
    WHEN OTHERS THEN
       FND_MESSAGE.SET_NAME('HXT','HXT_39408_CREATE_TIM_FUNC');  -- HXT11
       l_retcode := log_clock_errors(FALSE, NULL,'Timecard Creation', SQLERRM);
       --HXT11l_retcode := log_clock_errors(FALSE, 'Error in function create_timecard','Timecard Creation', SQLERRM);
       RETURN 2;
END create_timecard;
/******************************************************************
  create_batch()
  Obtains an existing clock batch id for this particular timecard.
  If no clock batch id with less than 50 timecards exists.
  Creates a new batch id for this particular timecard.
******************************************************************/
FUNCTION create_batch(	i_source IN VARCHAR2,
		 	i_payroll_id IN NUMBER,
			i_time_period_id IN NUMBER,
			i_assignment_id IN NUMBER,
			i_person_id IN NUMBER,
			o_batch_id OUT NOCOPY NUMBER) RETURN NUMBER IS
--BEGIN GLOBAL
--  l_batch_id	        pay_pdt_batch_headers.batch_id%TYPE 	 DEFAULT NULL;
--  l_reference_num        pay_pdt_batch_headers.reference_num%TYPE DEFAULT NULL;
  l_batch_id	        pay_batch_headers.batch_id%TYPE 	 DEFAULT NULL;
  l_reference_num       pay_batch_headers.batch_reference%TYPE   DEFAULT NULL;
  l_batch_name          pay_batch_headers.batch_name%TYPE        DEFAULT NULL;
  l_batch_name_error    EXCEPTION;
--END GLOBAL
  l_error_text          VARCHAR2(128)                            DEFAULT NULL;
  l_batch_id_error      EXCEPTION;
  l_reference_num_error EXCEPTION;
  l_retcode             NUMBER					 DEFAULT 0;
  l_object_version_number pay_batch_headers.object_version_number%TYPE;
BEGIN
     hxt_user_exits.Define_Reference_Number(i_payroll_id,
					i_time_period_id,
					i_assignment_id,
					i_person_id,
					g_user_name,
					i_source,
					l_reference_num,
					l_error_text);
     IF l_error_text <> NULL THEN
       RAISE l_reference_num_error;
     END IF;
      -- create a batch first
      pay_batch_element_entry_api.create_batch_header (
         p_session_date=> g_sysdate,
         p_batch_name=> to_char(sysdate, 'DD-MM-RRRR HH24:MI:SS'),
         p_batch_status=> 'U',
         p_business_group_id=> g_bus_group_id,
         p_action_if_exists=> 'I',
         p_batch_reference=> l_reference_num,
         p_batch_source=> 'OTM',
         p_purge_after_transfer=> 'N',
         p_reject_if_future_changes=> 'N',
         p_batch_id=> l_batch_id,
         p_object_version_number=> l_object_version_number
      );

      -- from the batch id, get the batch name
	 hxt_user_exits.define_batch_name (
         l_batch_id,
         l_batch_name,
         l_error_text
      );

	IF l_error_text <> NULL
	THEN
	   RAISE l_batch_name_error;
	END IF;

      --update the batch name
    pay_batch_element_entry_api.update_batch_header (
         p_session_date => g_sysdate,
         p_batch_id=> l_batch_id,
         p_object_version_number=> l_object_version_number,
         p_batch_name=> l_batch_name
    );


--END GLOBAL
  COMMIT;
  o_batch_id := l_batch_id;
  return 0;
EXCEPTION
  WHEN l_batch_id_error THEN
    FND_MESSAGE.SET_NAME('HXT','HXT_39409_CREATE_BATCH');  -- HXT11
    l_retcode := log_clock_errors(FALSE, NULL,'TIMCRT', SQLERRM);
    --HXT11l_retcode := log_clock_errors(FALSE, 'Error creating batch id in hxt_time_gen.Get_Next_Batch_Id','Timecard Creation', SQLERRM);
    RETURN 2;

  WHEN l_reference_num_error THEN
    FND_MESSAGE.SET_NAME('HXT','HXT_39410_CREATE_REF_FUNC');  -- HXT11
    l_retcode := log_clock_errors(FALSE, NULL,'Timecard Creation', SQLERRM);
    --HXT11l_retcode := log_clock_errors(FALSE, 'Error creating reference number in hxt_user_exits.Define_Reference_Number','Timecard Creation', SQLERRM);
    RETURN l_retcode;

--BEGIN GLOBAL
  WHEN l_batch_name_error THEN
    FND_MESSAGE.SET_NAME('HXT','HXT_39484_CREATE_BATCH_NAME');
    l_retcode := log_clock_errors(FALSE, NULL,'Timecard Creation', SQLERRM);
    RETURN l_retcode;
--END GLOBAL

  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('HXT','HXT_39411_CREATE_BATCH_FUNC');  -- HXT11
    l_retcode := log_clock_errors(FALSE, NULL,'TIMCRT', SQLERRM);
    --HXT11l_retcode := log_clock_errors(FALSE, 'Error in function create_batch','Timecard Creation', SQLERRM);
    RETURN 2;
END create_batch;
/********************************************************************
  find_existing_batch()
  Examine the pay_pdt_batch_headers and the hxt_timeclocks
  tables for existing unprocessed timeclock batches. The
  batches must be in a hold status (batch_status = 'H')
  and have less than the max amount of timecards allowed per batch.
********************************************************************/
--BEGIN SIR343
--FUNCTION find_existing_batch(o_batch_id OUT NUMBER)RETURN NUMBER IS
FUNCTION find_existing_batch(i_payroll_id IN NUMBER,
                             i_time_period_id IN NUMBER,
                             o_batch_id OUT NOCOPY NUMBER)RETURN NUMBER IS
--END SIR343
  l_max_batches NUMBER := fnd_profile.Value('HXT_BATCH_SIZE');
  l_retcode     NUMBER DEFAULT 0;
BEGIN
--BEGIN GLOBAL
--  SELECT bat.batch_id
--    INTO o_batch_id
--    FROM pay_pdt_batch_headers bat
--   WHERE bat.reference_num like 'C_%'
--     AND bat.batch_id = (SELECT MAX(bat2.batch_id)
--                           FROM pay_pdt_batch_headers bat2
--                          WHERE bat2.batch_status = 'H')
--     AND l_max_batches > (SELECT COUNT(tim.id)
--		            FROM hxt_timecards tim
--                           WHERE tim.batch_id = bat.batch_id);
--BEGIN SIR343
--  SELECT bat.batch_id
--    INTO o_batch_id
--    FROM pay_batch_headers bat
--   WHERE bat.batch_reference like 'C_%'
--     AND bat.batch_id = (SELECT MAX(bat2.batch_id)
--                           FROM pay_batch_headers bat2
--                          WHERE bat2.batch_status = 'U')
--     AND l_max_batches > (SELECT COUNT(tim.id)
--		            FROM hxt_timecards tim
--                           WHERE tim.batch_id = bat.batch_id);
  SELECT MAX(bat.batch_id)
    INTO o_batch_id
    FROM pay_batch_headers bat
   WHERE bat.batch_status = 'U'
     AND bat.batch_reference like 'C_%'
     AND not exists (SELECT 'x'
                       FROM hxt_timecards tim
                      WHERE tim.batch_id = bat.batch_id
                        AND (tim.time_period_id <> i_time_period_id
                          OR tim.payroll_id <> i_payroll_id))
     AND l_max_batches > (SELECT COUNT(tim2.id)
                            FROM hxt_timecards tim2
                           WHERE tim2.batch_id = bat.batch_id);
--END SIR343
--END GLOBAL
  RETURN 0;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN 1;
    WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('HXT','HXT_39412_FIND_BATCH_FUNC');  -- HXT11
      l_retcode := log_clock_errors(FALSE, NULL,'TIMCRT', SQLERRM);
      --HXT11l_retcode := log_clock_errors(FALSE, 'Error in function find_existing_batch','Timecard Creation', SQLERRM);
      RETURN 2;
END find_existing_batch;
/**********************************************************
  create_holiday_hours()
  Creates hours on new timecards for all holidays falling
  between the start and end dates of the pay period.
**********************************************************/
FUNCTION create_holiday_hours(	i_person_id IN NUMBER,
				i_hcl_id IN NUMBER,
				i_hxt_rotation_plan IN NUMBER,  --SIR344
				i_start_date IN DATE,
				i_end_date IN DATE,
				i_timecard_id IN NUMBER,
				i_assignment_id IN NUMBER)RETURN NUMBER IS
CURSOR l_hol_cur( c_start_date DATE, c_end_date DATE, c_hcl_id NUMBER) IS
    SELECT hcl.element_type_id,
           hdy.hours,
           hdy.holiday_date
      FROM hxt_holiday_calendars hcl,
           hxt_holiday_days hdy
     WHERE TRUNC(hdy.holiday_date,'DD') BETWEEN TRUNC(c_start_date,'DD') AND TRUNC(c_end_date,'DD')
       AND hcl.id = hdy.hcl_id
       AND hdy.holiday_date BETWEEN hcl.effective_start_date AND hcl.effective_end_date
       AND hcl.id = c_hcl_id;
-- not needed. declared in for loop     l_hol_rec            l_hol_cur%ROWTYPE;
l_retcode            NUMBER DEFAULT 0;
l_hours_worked_error EXCEPTION;
--BEGIN SIR344
l_time_in            DATE := NULL;
l_time_out           DATE := NULL;
l_hours              NUMBER;
l_work_id            NUMBER;
l_osp_id             NUMBER;
l_sdf_id             NUMBER;
l_standard_start     NUMBER;
l_standard_stop      NUMBER;
l_early_start        NUMBER;
l_late_stop          NUMBER;
--END SIR344
BEGIN
  FOR l_hol_rec IN l_hol_cur(i_start_date, i_end_date, i_hcl_id)
  LOOP
--BEGIN SIR344
    IF (fnd_profile.value('HXT_HOL_HOURS_FROM_HOL_CAL') = 'Y' OR
        fnd_profile.value('HXT_HOL_HOURS_FROM_HOL_CAL') IS NULL) THEN
      l_hours := l_hol_rec.hours;
      l_time_out := NULL;
      l_time_in := NULL;
    ELSE
      IF i_hxt_rotation_plan IS NOT NULL THEN
        HXT_UTIL.get_shift_info(l_hol_rec.holiday_date,
                                l_work_id,
                                i_hxt_rotation_plan,
                                l_osp_id,
                                l_sdf_id,
                                l_standard_start,
                                l_standard_stop,
                                l_early_start,
                                l_late_stop,
                                l_hours,
                                l_retcode);
        IF l_retcode <> 0 THEN
          RAISE l_hours_worked_error;
        END IF;
        IF l_hours IS NOT NULL THEN
          l_time_out := NULL;
          l_time_in := NULL;
        ELSE
          l_time_in  := to_date(to_char(l_hol_rec.holiday_date,'DDMMYYYY ')||
                        to_char(l_standard_start,'0009'), 'DDMMYYYY HH24MI');
          l_time_out := to_date(to_char(l_hol_rec.holiday_date,'DDMMYYYY ')||
                        to_char(l_standard_stop,'0009'), 'DDMMYYYY HH24MI');
          l_hours := 24 * (l_time_out - l_time_in);
          IF l_hours = 0 THEN
            l_time_out := NULL;
            l_time_in := NULL;
          END IF;
        END IF;
      END IF;
    END IF;
--END SIR344
      HXT_UTIL.DEBUG('The following holiday information was obtained');--DEBUG ONLY --HXT115
      HXT_UTIL.DEBUG(fnd_date.date_to_chardate(l_hol_rec.holiday_date));                 --DEBUG ONLY --FORMS60 --HXT115
      HXT_UTIL.DEBUG(TO_CHAR(l_hol_rec.element_type_id));              --DEBUG ONLY --HXT115
--BEGIN SIR344
      HXT_UTIL.DEBUG(TO_CHAR(l_hours));                                --DEBUG ONLY --HXT115
      HXT_UTIL.DEBUG(TO_CHAR(l_time_in,'MM-DD-YYYY HH24:MI'));         --DEBUG ONLY --HXT115
      HXT_UTIL.DEBUG(TO_CHAR(l_time_out,'MM-DD-YYYY HH24:MI'));        --DEBUG ONLY --HXT115
--END SIR344
      IF l_hours >= 0 THEN  --SIR344
        l_retcode := record_hours_worked( TRUE,
					i_timecard_id,
					i_assignment_id,
					i_person_id,
					l_hol_rec.holiday_date,
					l_hol_rec.element_type_id,
					l_hours,     --SIR344
					l_time_in,   --SIR344
					l_time_out,  --SIR344
					i_start_date);
      END IF;
      IF l_retcode <> 0 THEN
        RAISE l_hours_worked_error;
      END IF;
  END LOOP;
  RETURN 0;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
       RETURN 0;
    WHEN l_hours_worked_error THEN
       RETURN 1;
    WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('HXT','HXT_39413_LOC_HOL');  -- HXT11
      FND_MESSAGE.SET_TOKEN('ASG_ID',TO_CHAR(i_assignment_id));  -- HXT11
      l_retcode := log_clock_errors(TRUE,NULL, 'TIMCRT', SQLERRM);
      --HXT11l_retcode := log_clock_errors(TRUE,'Error attempting to locate holiday information'||
	--HXT11				'while creating a timecard for Assignment: '||
	--HXT11				TO_CHAR(i_assignment_id)||' in function create_holiday_hours',
	--HXT11				'Timecard Creation',
	--HXT11				SQLERRM);
       RETURN 2;
END create_holiday_hours;
/*************************************************************************
  record_hours_worked()
  Fetches additional assignment details about employees.
  Creates hours worked records on the hxt_hours_worked database table.
  Calls the hxt_time_summary.generate_details function to explode details.
**************************************************************************/
FUNCTION record_hours_worked(	b_generate_holiday IN BOOLEAN,
				i_timecard_id IN NUMBER,
				i_assignment_id IN NUMBER,
				i_person_id IN NUMBER,
				i_date_worked IN DATE,
				i_element_id IN NUMBER,
				i_hours IN NUMBER,
				i_start_time IN DATE,
				i_end_time IN DATE,
				i_start_date IN DATE)RETURN NUMBER IS
  l_hol_yn                 CHAR       DEFAULT 'N';
  l_details_error          EXCEPTION;
  l_details_system_error   EXCEPTION;
  l_hours_worked_id_error  EXCEPTION;
  l_seq_num_error          EXCEPTION;
  l_generate_details_error EXCEPTION;
  l_retcode                NUMBER     DEFAULT 0;
  l_hours_worked_id        NUMBER     DEFAULT NULL;
  l_sequence_number        NUMBER     DEFAULT NULL;
  l_rowid                  ROWID;                                   --SIR012

-- ***** Start commented code for Bug 2669059 **************
-- Commenting this cursor and adding two different cursors
--  CURSOR l_details_cur(c_assignment_id NUMBER, c_date_worked DATE) IS
--    SELECT aeiv.hxt_earning_policy, -- ORACLE
--           aeiv.hxt_shift_differential_policy, -- ORACLE
--           aeiv.hxt_hour_deduction_policy, -- ORACLE
--         egp.fcl_earn_type,
--           egp.egt_id,
--         egp.pep_id,
--           egp.pip_id,
--           wsh.off_shift_prem_id,
--           wsh.shift_diff_ovrrd_id
--      FROM hxt_earning_policies egp,
----ORACLE       per_assignments_f_dfv asmv,
--           hxt_per_aei_ddf_v aeiv,  --ORACLE
--           per_assignment_status_types ast,
--           per_assignments_f asm,
--           hxt_shifts sht,
--	   hxt_weekly_work_schedules wws,
--	   hxt_work_shifts wsh,
--           hxt_rotation_schedules rts
--     WHERE c_assignment_id = asm.assignment_id
--       AND ast.assignment_status_type_id = asm.assignment_status_type_id
--       AND ast.pay_system_status = 'P'	-- Check payroll status
--ORACLE       AND asmv.row_id = asm.rowid
--       AND aeiv.assignment_id = asm.assignment_id   --ORACLE
--       AND c_date_worked BETWEEN aeiv.effective_start_date     /* GLOBAL */
--                             AND aeiv.effective_end_date       /* GLOBAL */
--/*GLOBAL       AND aeiv.information_type = 'HXT_ASS_INFO'   --ORACLE */
----ORACLE       AND egp.id(+) = asmv.hxt_earning_policy
--       AND egp.id(+) = aeiv.hxt_earning_policy      --ORACLE
--       AND c_date_worked >= rts.start_date
--       AND wsh.week_day = to_char(c_date_worked,'DY')
--       AND wws.id = wsh.tws_id
--       AND c_date_worked between wws.date_from AND nvl(wws.date_to, c_date_worked)
--       AND wws.id = rts.tws_id
--       AND sht.id = wsh.sht_id;
-- ***** End commented code for Bug 2669059 **************

-- ***** Start new code for Bug 2669059 **************
CURSOR l_details_cur(c_assignment_id NUMBER, c_date_worked DATE) IS

SELECT
	   aeiv.hxt_earning_policy,
           aeiv.hxt_shift_differential_policy,
           aeiv.hxt_hour_deduction_policy,
  	   aeiv.hxt_rotation_plan,
           egp.fcl_earn_type,
           egp.egt_id,
           egp.pep_id,
           egp.pip_id
FROM 	   hxt_earning_policies egp,
           hxt_per_aei_ddf_v aeiv,
		   per_assignment_status_types past,
		   per_assignments_f paf
WHERE c_assignment_id = paf.assignment_id
      AND c_date_worked BETWEEN paf.effective_start_date AND paf.effective_end_date
      AND past.assignment_status_type_id = paf.assignment_status_type_id
      AND past.pay_system_status = 'P' -- Check payroll status
      AND aeiv.assignment_id = paf.assignment_id
      AND c_date_worked BETWEEN aeiv.effective_start_date
                             AND aeiv.effective_end_date
       AND egp.id = aeiv.hxt_earning_policy
	   AND c_date_worked BETWEEN egp.effective_start_date
                             AND egp.effective_end_date;

-- ***** End new code for Bug 2669059 **************

  l_det_rec l_details_cur%ROWTYPE;

-- ***** Start new code for Bug 2669059 **************
CURSOR l_wsh_details_cur(c_hxt_rotation_plan NUMBER, c_date_worked DATE) IS
   SELECT hws.off_shift_prem_id, hws.shift_diff_ovrrd_id
     FROM hxt_rotation_plans hrp,
          hxt_rotation_schedules hrs,
          hxt_weekly_work_schedules hwws,
          hxt_work_shifts hws
    WHERE hrp.id = c_hxt_rotation_plan
      AND c_date_worked BETWEEN hrp.date_from
                           AND NVL (hrp.date_to, c_date_worked )
      AND hrs.rtp_id = hrp.id
      AND c_date_worked >= hrs.start_date
      AND hwws.id = hrs.tws_id
      AND c_date_worked BETWEEN hwws.date_from
                           AND NVL (hwws.date_to, c_date_worked)
      AND hws.tws_id = hwws.id
      AND hws.week_day = hxt_util.get_week_day(c_date_worked);

l_wsh_det_rec l_wsh_details_cur%ROWTYPE;

-- ***** End new code Bug 2669059 **************

BEGIN
  /*Fetch additional assignment details about this employee*/
  BEGIN
    HXT_UTIL.DEBUG('Opening details Cursor');--DEBUG ONLY --HXT115
    OPEN l_details_cur(i_assignment_id, i_date_worked);
    HXT_UTIL.DEBUG('Fetching details Cursor');--DEBUG ONLY --HXT115
    FETCH l_details_cur
     INTO l_det_rec;
    HXT_UTIL.DEBUG('Closing details Cursor');--DEBUG ONLY --HXT115
    CLOSE l_details_cur;
    --DEBUG ONLY BEGIN
    HXT_UTIL.DEBUG('earning policy :           '||l_det_rec.hxt_earning_policy);--HXT115
    HXT_UTIL.DEBUG('shift differential policy: '||l_det_rec.hxt_shift_differential_policy); --HXT115
    HXT_UTIL.DEBUG('hour deduction policy:     '||l_det_rec.hxt_hour_deduction_policy); --HXT115
    HXT_UTIL.DEBUG('fcl earn type:             '||l_det_rec.fcl_earn_type); --HXT115
    HXT_UTIL.DEBUG('egt id:                    '||TO_CHAR(l_det_rec.egt_id)); --HXT115
    HXT_UTIL.DEBUG('pep id:                    '||TO_CHAR(l_det_rec.pep_id)); --HXT115
    HXT_UTIL.DEBUG('pip id:                    '||TO_CHAR(l_det_rec.pip_id)); --HXT115

-- ***** Start commented code for Bug 2669059 **************
--    HXT_UTIL.DEBUG('off_shift_prem_id:         '||TO_CHAR(l_det_rec.off_shift_prem_id)); --HXT115
--    HXT_UTIL.DEBUG('shift_diff_ovrrd_id:       '||TO_CHAR(l_det_rec.shift_diff_ovrrd_id)); --HXT115
-- ***** End commented code for Bug 2669059 **************

    --DEBUG ONLY END
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RAISE l_details_error;
      WHEN OTHERS THEN
         RAISE l_details_system_error;
  END; /*end additional assignment details*/

-- ***** Start new code for Bug 2669059 **************

  IF l_det_rec.hxt_rotation_plan is not null THEN
    HXT_UTIL.DEBUG('Opening wsh details Cursor');--DEBUG ONLY --HXT115
     OPEN l_wsh_details_cur(l_det_rec.hxt_rotation_plan,i_date_worked);
     HXT_UTIL.DEBUG('Fetching wsh details Cursor');--DEBUG ONLY --HXT115
      FETCH l_wsh_details_cur
      	INTO l_wsh_det_rec;
      HXT_UTIL.DEBUG('Closing wsh details Cursor');--DEBUG ONLY --HXT115
      CLOSE l_wsh_details_cur;
    END IF;


  HXT_UTIL.DEBUG('off_shift_prem_id:         '||TO_CHAR(l_wsh_det_rec.off_shift_prem_id)); --HXT115
  HXT_UTIL.DEBUG('shift_diff_ovrrd_id:       '||TO_CHAR(l_wsh_det_rec.shift_diff_ovrrd_id)); --HXT115

-- ***** End new code for Bug 2669059 **************

  /*Flag holidays being generated*/
  IF b_generate_holiday = TRUE THEN
    l_hol_yn := 'Y';
  END IF;
  /*Obtain a unique hours worked id*/
  l_hours_worked_id := hxt_time_gen.Get_HXT_Seqno;
  IF l_hours_worked_id = NULL THEN
    RAISE l_hours_worked_id_error;
  END IF;
  g_hours_worked_err_id := l_hours_worked_id;
  /*Obtain the next sequence number for hours worked on this day*/
  l_sequence_number := hxt_util.Get_Next_Seqno( i_timecard_id, i_date_worked);
  IF l_sequence_number = NULL THEN
    RAISE l_seq_num_error;
  END IF;
  HXT_UTIL.DEBUG('Hours Worked Id is: '||TO_CHAR(l_hours_worked_id));--DEBUG ONLY --HXT115
  HXT_UTIL.DEBUG('Hours Worked Sequence Number is: '||TO_CHAR(l_sequence_number));--DEBUG ONLY --HXT115
--SIR012  INSERT INTO hxt_sum_hours_worked --C421
  INSERT INTO hxt_sum_hours_worked_f                                                   --SIR012
  ( id,
    tim_id,
-- C421    parent_id,
    date_worked,
    seqno,
    hours,
    assignment_id,
    element_type_id,
    time_in,
    time_out,
    created_by,
    creation_date
    , earn_pol_id                                                                    --SIR012
    , effective_start_date                                                           --SIR012
    , effective_end_date)                                                            --SIR012
  VALUES
  ( l_hours_worked_id,
    i_timecard_id,
-- C421    0,
    i_date_worked,
    l_sequence_number,
    i_hours,
    i_assignment_id,
    i_element_id,
    i_start_time,
    i_end_time,
    g_user_id,
    g_sysdate
  , l_det_rec.hxt_earning_policy                                                     --SIR012
  , g_sysdate                                                                        --SIR012
  , hr_general.end_of_time);                                  --SIR149 --FORMS60
  COMMIT;
  HXT_UTIL.DEBUG('Hours Worked Successfully inserted');--DEBUG ONLY --HXT115

  select rowid                                                                       --SIR012
  into l_rowid                                                                       --SIR012
  from HXT_SUM_HOURS_WORKED                             --SIR012
  where id = l_hours_worked_id;                                                       --SIR012

  /*Generate time details*/
  l_retcode := hxt_time_summary.Generate_Details(
				l_det_rec.hxt_earning_policy,
			        l_det_rec.fcl_earn_type,
				l_det_rec.egt_id,
				l_det_rec.hxt_shift_differential_policy,
				l_det_rec.hxt_hour_deduction_policy,
				NULL,				--Holiday day id
				l_det_rec.pep_id,
				l_det_rec.pip_id,
				l_wsh_det_rec.shift_diff_ovrrd_id,
				l_wsh_det_rec.off_shift_prem_id,
				NULL,				--standard start
				NULL,				--standard stop
				NULL,				--early start
				NULL,				--late stop
				l_hol_yn,
				i_person_id,
				'hxt_time_clock',
				l_hours_worked_id,
-- C421				0,				-- parent id
				i_timecard_id,
--SIR012			NULL,				-- line status
				i_date_worked,
				i_assignment_id,
				i_hours,
				i_start_time,
				i_end_time,
				i_element_id,
				NULL,				--fcl_earn_reason_code
				NULL,				--ffv_cost_center_id
				NULL,				--ffv_labor_account_id
				NULL,				--tas_id
				NULL,				--location_id
				NULL,				--sht_id
				NULL,				--hrw_comment
				NULL,				--ffv_rate_code_id
				NULL,				--rate_multiple
				NULL,				--hourly_rate
				NULL,				--amount
				NULL,				--fcl_tax_rule_code
				NULL,				--separarate_check_flag
				l_sequence_number,
				g_user_id,
				g_sysdate,
				NULL,				--last_updated_by
				NULL,				--last_update_date
				NULL,				--last_update_login
				i_start_date,
                                l_rowid,                                             --SIR012
                                trunc(sysdate),                                      --SIR012
                                hr_general.end_of_time,       --SIR149 --FORMS60
                                NULL,                                                --SIR012
                                NULL,                                                --SIR012
                                'P',                                                 --SIR012
                                'P',                                                 --SIR012
                                NULL,                                                --SIR012
                                'C');                                                --SIR012
  IF l_retcode = 2 THEN
    RAISE l_generate_details_error;
  END IF;
  COMMIT;
  RETURN 0;

  EXCEPTION
    WHEN l_details_error THEN
      FND_MESSAGE.SET_NAME('HXT','HXT_39414_LOC_ADDL_ASG');  -- HXT11
      FND_MESSAGE.SET_TOKEN('ASG_ID',TO_CHAR(i_assignment_id));  -- HXT11
      l_retcode := log_clock_errors(TRUE, NULL,'RECHRS', NULL);
      --HXT11l_retcode := log_clock_errors(TRUE, 'Additional Assignment details not located for Assignment '||TO_CHAR(i_assignment_id),'Record Hours', NULL);
      RETURN 1;

    WHEN l_details_system_error THEN
      FND_MESSAGE.SET_NAME('HXT','HXT_39415_FETCH_ASG_DET');  -- HXT11
      FND_MESSAGE.SET_TOKEN('ASG_ID',TO_CHAR(i_assignment_id));  -- HXT11
      l_retcode := log_clock_errors(TRUE, NULL,'RECHRS', SQLERRM);
      --HXT11l_retcode := log_clock_errors(TRUE,
	--HXT11			    'System Error occurred atempting to Fetch Assignment details'||
	--HXT11			    'for Assignment '||TO_CHAR(i_assignment_id)||
	--HXT11			    ' in Function record_hours_worked.',
	--HXT11			    'Record Hours',SQLERRM);
      RETURN 2;

    WHEN l_hours_worked_id_error THEN
      FND_MESSAGE.SET_NAME('HXT','HXT_39416_GET_HRW_ID');  -- HXT11
      l_retcode := log_clock_errors(TRUE, NULL,'RECHRS', SQLERRM);
      --HXT11l_retcode := log_clock_errors(TRUE, 'Error while attempting to obtain hours worked id from hxt_time_gen.Get_HXT_Seqno.','Record Hours', SQLERRM);
      RETURN 2;

    WHEN l_generate_details_error THEN
      FND_MESSAGE.SET_NAME('HXT','HXT_39417_PROB_GEN_DET');  -- HXT11
      l_retcode := log_clock_errors(TRUE, NULL,'RECHRS', SQLERRM);
      --HXT11l_retcode := log_clock_errors(TRUE,'A problem occurred in the function hxt_time_summary.Generate_Details.','Record Hours', SQLERRM);
      RETURN 2;

    WHEN l_seq_num_error THEN
      FND_MESSAGE.SET_NAME('HXT','HXT_39418_GET_HRW_SEQ');  -- HXT11
      l_retcode := log_clock_errors(TRUE, NULL,'RECHRS', SQLERRM);
      --HXT11l_retcode := log_clock_errors(TRUE,'Error while attempting to obtain hours worked sequence number in function record_hours_worked.','Record Hours', SQLERRM);
      RETURN 2;

    WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('HXT','HXT_39419_SYSERR_RECFUNC');  -- HXT11
      l_retcode := log_clock_errors(TRUE, NULL,'RECHRS', SQLERRM);
      --HXT11l_retcode := log_clock_errors(TRUE,'System Error occurred in Function record_hours_worked','Record Hours',SQLERRM);
      RETURN 2;
END record_hours_worked;
/****************************************************
  log_clock_errors()
  Records errors for timeclock processing.
  The timecard available flag determines
  where to post the error:
  * In Phase I all errors are posted to HXT_ERRORS.
  * In Phase II errors with no timecard will be
    posted to a new table called HXT_TIMECLOCK_ERRORS.
****************************************************/
FUNCTION log_clock_errors(i_timecard_available IN BOOLEAN,
			  i_error_text IN VARCHAR2,
			  i_error_location IN VARCHAR2,
			  i_sql_message IN VARCHAR2)RETURN NUMBER IS
  l_error_seqno NUMBER DEFAULT NULL;
  l_err_buf  VARCHAR2(240); -- HXT11
BEGIN
  HXT_UTIL.DEBUG('g_batch_err_id = ' || TO_CHAR(g_batch_err_id)); --DEBUG ONLY --HXT115
  HXT_UTIL.DEBUG('g_timecard_err_id = ' || TO_CHAR(g_timecard_err_id)); --DEBUG ONLY --HXT115
  HXT_UTIL.DEBUG('g_hours_worked_err_id = ' || TO_CHAR(g_hours_worked_err_id)); --DEBUG ONLY --HXT115
  HXT_UTIL.DEBUG('g_time_period_err_id = ' || g_time_period_err_id); --DEBUG ONLY --HXT115
  HXT_UTIL.DEBUG(i_error_text || i_sql_message); --DEBUG ONLY --HXT115
--begin HXT11
  l_err_buf := FND_MESSAGE.GET;
  FND_MESSAGE.CLEAR;
--end HXT11
  IF i_timecard_available THEN
  HXT_UTIL.DEBUG('TC available. Calling hxt_util.Gen_error'); --DEBUG ONLY --HXT115
    hxt_util.Gen_Error(	g_batch_err_id,
			g_timecard_err_id,
			g_hours_worked_err_id,
			g_time_period_err_id,
  		        i_error_text,
			i_error_location,
			i_sql_message,
                        trunc(sysdate),                       --SIR012
                        hr_general.end_of_time,               --SIR149 --FORMS60
                        'ERR');                               --HXT11i1
  HXT_UTIL.DEBUG('Back from calling hxt_util.Gen_error'); --DEBUG ONLY --HXT115
  ELSE
   SELECT hxt_seqno.nextval
     INTO l_error_seqno
     FROM DUAL;
--SIR012    insert into hxt_errors(	id,
--SIR012				error_msg,
--SIR012				creation_date,
--SIR012				location,
--SIR12				created_by,
--SIR12				err_type,
--SIR12				PPB_ID,
--SIR12				TIM_ID,
--SIR12				HRW_ID,
--SIR12				PTP_ID,
--SIR12				ora_message)
--SIR12                    values(	l_error_seqno,
--SIR12				i_error_text,
--SIR12				sysdate,
--SIR12				i_error_location,
--SIR12				g_user_id,
--SIR12				'CLK',
--SIR12				g_batch_err_id,
--SIR12				g_timecard_err_id,
--SIR12				g_hours_worked_err_id,
--SIR12				g_time_period_err_id,
--SIR12				i_sql_message);

  HXT_UTIL.DEBUG('TC not available. Calling hxt_util.Gen_error'); --DEBUG ONLY --HXT115
    HXT_util.Gen_Error(	0,                                    --SIR12
			0,                                    --SIR12
			0,                                    --SIR12
			0,                                    --SIR12
  		        i_error_text,                         --SIR12
			i_error_location,                     --SIR12
			i_sql_message,                        --SIR12
                        trunc(sysdate)                        --SIR12
                        , hr_general.end_of_time,             --SIR149 --FORMS60
                        'ERR');                               --HXT11i1
    COMMIT;
  END IF;
  RETURN 0;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE g_error_log_error;
END log_clock_errors;
END hxt_time_clock;

/
