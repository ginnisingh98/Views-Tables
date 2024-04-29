--------------------------------------------------------
--  DDL for Package Body HXT_RETRO_PA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXT_RETRO_PA" AS
/* $Header: hxtrpa.pkb 120.0.12010000.2 2008/08/19 14:01:11 asrajago ship $ */
l_hours_per_year  	NUMBER(22,5) := TO_NUMBER(fnd_profile.Value('HXT_HOURS_PER_YEAR'));

PROCEDURE retro_pa_process(o_err_buf OUT NOCOPY VARCHAR2,
                           o_ret_code OUT NOCOPY NUMBER,
                           i_payroll_id IN NUMBER,
                           i_time_period_id IN NUMBER)IS

l_retcode       NUMBER        DEFAULT 0;
l_error_text	VARCHAR2(240) DEFAULT NULL;
l_system_text	VARCHAR2(120) DEFAULT NULL;
l_location      VARCHAR2(120) DEFAULT NULL;
l_sum_start_date    hxt_sum_hours_worked_f.effective_start_date%TYPE;
l_sum_end_date      hxt_sum_hours_worked_f.effective_end_date%TYPE;
l_sum_id            hxt_sum_hours_worked_f.id%TYPE;
l_ewr_error         EXCEPTION;
l_non_ewr_error	  	EXCEPTION;
l_conc_error		EXCEPTION;
l_no_timecards  	EXCEPTION;
l_no_details	  	EXCEPTION;
l_batch_state		EXCEPTION;

l_conc_error_flag   BOOLEAN      DEFAULT FALSE;
l_any_timecards	    BOOLEAN      DEFAULT FALSE;

/****************************************
  Cursor to select each timecard within
  the payroll/time-period requested
****************************************/

CURSOR l_timecard_cur(c_payroll_id NUMBER, c_time_period_id NUMBER)IS
SELECT tim.id,
       tim.batch_id,
       tim.time_period_id,
       tim.rowid,
       tim.effective_start_date,
       tim.effective_end_date,
       ptp.end_date,
       ptpt.number_per_fiscal_year,
       ppbh.batch_status,
       ppf.employee_number
  FROM hxt_timecards_x tim,
       per_time_periods ptp,
       per_time_period_types ptpt,
       pay_batch_headers ppbh,
       per_people_f ppf
   WHERE tim.payroll_id = c_payroll_id
     AND ptp.time_period_id BETWEEN NVL(c_time_period_id,1) AND NVL(c_time_period_id,999999999)
     AND tim.time_period_id = ptp.time_period_id
     AND ptp.period_type = ptpt.period_type
     AND tim.batch_id = ppbh.batch_id
     AND ppbh.batch_status <> 'U'
     AND ppf.person_id = tim.for_person_id
     AND ppf.effective_start_date =
             (select MAX (ppf2.effective_start_date)  -- to handle mid pay period changes
              from per_people_f ppf2
              where ppf2.person_id = tim.for_person_id
              and ppf2.effective_end_date >= ptp.START_date
              and ppf2.effective_start_date <= ptp.END_date)
     AND EXISTS (SELECT 'Y'
                   FROM hxt_det_hours_worked_x det
		   WHERE det.tim_id = tim.id
		            AND det.pa_status = 'R') ;
BEGIN
  -- select each timecard within the payroll/time-period
  FOR l_timecard_rec IN l_timecard_cur( i_payroll_id, i_time_period_id) LOOP
    g_batch_err_id := l_timecard_rec.batch_id;
    g_err_effective_start := l_timecard_rec.effective_start_date;
    g_err_effective_end := l_timecard_rec.effective_end_date;
    HXT_UTIL.DEBUG('.'); --DEBUG ONLY --HXT115
    HXT_UTIL.DEBUG('l_timecard_rec.id = ' || TO_CHAR(l_timecard_rec.id));
    HXT_UTIL.DEBUG('l_timecard_rec.batch_id = ' || TO_CHAR(l_timecard_rec.batch_id));
    HXT_UTIL.DEBUG('l_timecard_rec.time_period_id = ' || TO_CHAR(l_timecard_rec.time_period_id));
    HXT_UTIL.DEBUG('l_timecard_rec.end_date = ' ||
                      fnd_date.date_to_chardate(l_timecard_rec.end_date));

    BEGIN --timecard error block

      l_any_timecards := TRUE;
      -- set id's related to each timecard for error messaging
      g_timecard_err_id := l_timecard_rec.id;
      g_time_period_err_id := l_timecard_rec.time_period_id;

      HXT_UTIL.DEBUG('l_timecard_rec.id = ' || TO_CHAR(l_timecard_rec.id));

      -- Clean up existing transfer to PA errors for this payroll/period
      DELETE
        FROM hxt_errors_f errf
       WHERE errf.tim_id = l_timecard_rec.id
         AND (errf.location LIKE 'hxt_retro_pa%'
            OR errf.location LIKE 'hxt_pa_user_exits.p_a_%');

      COMMIT;

     /*************************************************
      -- Effective Wage Rate Not Currently Implemented
      --
      -- Call the logic to calculate effective
      -- wage and transfer retro effective wage
      -- time details to Project Accounting.
      --
      -- l_retcode := hxt_ewr_pa.retro_effective_wage_rate(l_timecard_rec.id,
      --                                                  l_timecard_rec.end_date,
      --                                                  l_timecard_rec.number_per_fiscal_year,
      --                                                  'Y',
      --                                                  l_timecard_rec.employee_number,
      --                                                  l_sum_start_date,
      --                                                  l_sum_end_date,
      --                                                  l_sum_id,
      --                                                  l_location,
      --                                                  l_error_text,
      --                                                  l_system_text);
      --
      -- Report any errors for EWR and ROLLBACK
      -- IF l_retcode = 1 THEN
      --   g_err_effective_start := l_sum_start_date;
      --   g_err_effective_end := l_sum_end_date;
      --   g_sum_hours_err_id := l_sum_id;
      --   RAISE l_ewr_error;
      -- END IF;
     ***********************************************************************************/


      --  Call the logic to transfer retro time
      --  details to Project Accounting that were not
      --  included in Effective Wage Rate processing.

      l_retcode := retro_non_ewr_transfer(l_timecard_rec.id,
                                          l_timecard_rec.end_date,
                                          l_timecard_rec.number_per_fiscal_year,
                                          l_timecard_rec.employee_number,
                                          l_location,
                                          l_error_text,
                                          l_system_text);

      -- Report any errors for non-EWR and ROLLBACK
      IF l_retcode = 1 THEN
        RAISE l_non_ewr_error;
      END IF;

      g_err_effective_start := l_timecard_rec.effective_start_date;
      g_err_effective_end := l_timecard_rec.effective_end_date;

      -- Update all retro rows processed to show completed
      UPDATE hxt_det_hours_worked_f
        SET pa_status = 'C'
      WHERE rowid IN (SELECT d.rowid
		      FROM hxt_det_hours_worked_x d
                     WHERE d.pa_status = 'R'
                       AND d.tim_id = l_timecard_rec.id);

      COMMIT; -- commit data for this timecard

    EXCEPTION
      -- Effective Wage Rate Errors
      WHEN l_ewr_error THEN
        ROLLBACK;
        l_retcode := log_transfer_errors(l_location, l_error_text, l_system_text);
        l_conc_error_flag := TRUE;
      -- Non Effective Wage Rate Errors
      WHEN l_non_ewr_error THEN
        ROLLBACK;
        l_retcode := log_transfer_errors(l_location, l_error_text, l_system_text);
        l_conc_error_flag := TRUE;
      -- Other errors
      WHEN OTHERS THEN
        ROLLBACK;
        l_location := 'hxt_retro_pa.retro_pa_process';
        FND_MESSAGE.SET_NAME('HXT','HXT_39454_PA_XFER_ERROR');
        l_error_text := FND_MESSAGE.GET;
        FND_MESSAGE.CLEAR;
        l_system_text := SQLERRM;
        l_retcode := log_transfer_errors(l_location, l_error_text, l_system_text);
        l_conc_error_flag := TRUE;
    END; -- timecard error block
  END LOOP; -- timecard loop

  -- Return an error if any timecards had a problem
  IF l_conc_error_flag = TRUE THEN
    RAISE l_conc_error;
  END IF;

  -- Return an error if NO timecards exist for this payroll/period
  IF l_any_timecards = FALSE THEN
    RAISE l_no_timecards;
  END IF;

  o_ret_code := 0;
  HXT_UTIL.DEBUG('Retro details successfully transferred!');

EXCEPTION
  WHEN l_conc_error THEN
    FND_MESSAGE.SET_NAME('HXT','HXT_39456_CHK_TCARD_ERRS');
    o_err_buf := FND_MESSAGE.GET;
    FND_MESSAGE.CLEAR;
    o_ret_code := 2;
    HXT_UTIL.DEBUG('Check timecards for errors or run timecard report.');
    RETURN;
  WHEN l_no_timecards THEN
    FND_MESSAGE.SET_NAME('HXT','HXT_39457_NO_TCARD_4_PAY_PRD');
    o_err_buf := FND_MESSAGE.GET;
    FND_MESSAGE.CLEAR;
    o_ret_code := 2;
    HXT_UTIL.DEBUG('No timecards located for this payroll');
    RETURN;
  WHEN l_no_details THEN
    FND_MESSAGE.SET_NAME('HXT','HXT_39458_NO_TCARD_DET_XFER');
    o_err_buf := FND_MESSAGE.GET;
    FND_MESSAGE.CLEAR;
    o_ret_code := 0;
    HXT_UTIL.DEBUG('No timecard details transferable');
    RETURN;
  WHEN g_error_log_error THEN
    FND_MESSAGE.SET_NAME('HXT','HXT_39460_HXTRPA_ERR');
    o_err_buf := FND_MESSAGE.GET;
    FND_MESSAGE.CLEAR;
    HXT_UTIL.DEBUG('Error in hxt_retro_pa.log_transfer_errors.');
    o_ret_code := 2;
    RETURN;
  WHEN OTHERS THEN
    l_location := 'hxt_retro_pa';
    FND_MESSAGE.SET_NAME('HXT','HXT_39454_PA_XFER_ERROR');
    l_error_text := FND_MESSAGE.GET;
    FND_MESSAGE.CLEAR;
    l_system_text := SQLERRM;
    l_retcode := log_transfer_errors(l_location, l_error_text, l_system_text);
    o_ret_code := 2;
    FND_MESSAGE.SET_NAME('HXT','HXT_39460_HXTRPA_ERR');
    o_err_buf := FND_MESSAGE.GET;
    FND_MESSAGE.CLEAR;
    HXT_UTIL.DEBUG('Error processing timecard for PA Transfer');
    RETURN;
END retro_pa_process;
/************************************************************************************************
  non_eff_wage_rate_transfer()
  Processing of transfer to Project Accounting for all Time details not
  processed as a part of the Effective Wage Rate Logic.

  Values in the pa_status column on the hxt_det_hours_worked_f (details) table
  should be interpreted as follows:

  P - pending:    this row has not yet been successfully processed by any transfer Logic

  C - completed:  this row has been successfully processed by transfer or retro Project Accounting

  R - retro:      this row represents a new detail change and is ready for Retro processing
                  note: retro rows that have been updated with new retro rows by the user
                  will remain in a retro status permenantly becacuse of the effective_end_date

  A - adjusted:   this row had an adjusting entry sent to Project Accounting.
                  The adjustment was an hours or amount change only, representing
                  the difference between this previously sent detail/PA row and the new changes

  B - backed out: the details related to this row that were previously sent to
                  Project Accouning had to be backed out nocopy (Insert negative hours to PA interface).
                  PA rows are backed out nocopy when newer (retro) entries have invalidated
                  them through changes to data vital to Project Accounting.

  D - dead row:   this row has been replaced by a newer(retro) detail row with identical information.
                  This can happen when the retro explosion process creates rows where data has not
                  changed. These newer retro rows are not sent to PA because an entry
                  already exists there representing the amount.

**************************************************************************************************/
FUNCTION retro_non_ewr_transfer(i_timecard_id IN NUMBER,
			     	i_ending_date IN DATE,
			        i_annual_pay_periods IN NUMBER,
                                i_employee_number IN VARCHAR2,
			        o_location OUT NOCOPY VARCHAR2,
			        o_error_text OUT NOCOPY VARCHAR2,
			        o_system_text OUT NOCOPY VARCHAR2) RETURN NUMBER IS

/****************************************************************
    Summary cursor to select each summmary row associated
    with the timecard being processed.
****************************************************************/
CURSOR l_sum_cur(c_timecard_id NUMBER) IS
SELECT id,
       effective_start_date,
       effective_end_date
  FROM hxt_sum_hours_worked_x
 WHERE tim_id = c_timecard_id;
--TA36 not needed. declared in FOR loop.l_sum_rec l_sum_cur%ROWTYPE;

/********************************************************************
    Cursor to select all detail rows associated with the timecard
    that are not associated with Effective Wage Rate calculations.
    Each retro detail row will be passed to Project Accounting.
*********************************************************************/
CURSOR l_non_cur(c_summary_id NUMBER)IS
 SELECT   NVL(pro.proposed_salary_N,0) proposed_salary,
          ppb.pay_basis,
          fcl2.meaning emp_cat_description,
          payd.hxt_earning_category,
          payd.hxt_premium_type,
          NVL(payd.hxt_premium_amount,0) hxt_premium_amount,
          det.id,
          det.hours,
          det.amount,
          det.date_worked,
          det.effective_start_date det_effective_start,
          det.effective_end_date det_effective_end,
          det.hourly_rate,
          det.rate_multiple,
          det.ffv_cost_center_id,
          det.job_id,
          det.tas_id,
          det.project_id,
          prj.name project_name,
          prj.segment1,
          task.task_number,
          task.task_name,
          org.name,
          payt.element_name,
          asg.organization_id,
          asg.assignment_id,
          asg.assignment_number,
          det.parent_id,
          det.element_type_id
     FROM hxt_det_hours_worked_x det,
          per_pay_proposals pro,
          per_pay_bases ppb,
          hr_lookups fcl,
          hr_lookups fcl2,
          per_assignments_f asg,
          hr_organization_units_v org,
          pay_element_types_f pay,
          pay_element_types_f_tl payt,
          hxt_pay_element_types_f_ddf_v payd,
          pa_projects_all prj,
          pa_tasks task
    WHERE det.parent_id = c_summary_id
      AND det.pa_status = 'R'
      AND det.assignment_id = asg.assignment_id
      AND det.date_worked BETWEEN asg.effective_start_date AND asg.effective_end_date
      AND asg.pay_basis_id = ppb.pay_basis_id
      AND asg.organization_id = org.organization_id
      AND det.assignment_id = pro.assignment_id
      AND pro.approved = 'Y'
      AND pro.change_date = (SELECT MAX(pro2.change_date)
                            FROM per_pay_proposals pro2
                           WHERE pro2.assignment_id = det.assignment_id
                             AND pro2.approved = 'Y'
                             AND det.date_worked >= pro2.change_date)
      AND det.element_type_id = pay.element_type_id
      AND payt.element_type_id = pay.element_type_id
      AND payt.language = userenv('LANG')
      AND pay.element_type_id = payd.element_type_id
      AND det.date_worked BETWEEN payd.effective_start_date
                              AND payd.effective_end_date
      AND det.date_worked BETWEEN pay.effective_start_date
                              AND pay.effective_end_date
      AND payd.hxt_earning_category = fcl.lookup_code
      AND fcl.lookup_type = 'HXT_EARNING_CATEGORY'
      AND fcl.application_id = 808
      AND asg.employment_category = fcl2.lookup_code
      AND fcl2.lookup_type = 'EMP_CAT'
      AND fcl2.application_id = 800
      AND det.project_id = prj.project_id
      AND det.tas_id = task.task_id(+);


/************************************************************************
    Cursor to select any expired rows where only the hours have changed.
*************************************************************************/
CURSOR l_expired_cur(c_parent_id NUMBER,
                     c_project_id NUMBER,
                     c_task_id NUMBER,
                     c_element_type_id NUMBER,
                     c_hourly_rate NUMBER,
                     c_amount NUMBER,
                     c_ffv_cost_center_id NUMBER,
                     c_job_id NUMBER)IS
  SELECT detf.hours,
         detf.id,
         detf.rowid row_id
    FROM hxt_det_hours_worked_f detf
   WHERE detf.parent_id = c_parent_id
     AND detf.project_id = c_project_id
     AND NVL(detf.tas_id,-1) = NVL(c_task_id,-1)
     AND detf.element_type_id = c_element_type_id
     AND NVL(detf.hourly_rate,-1) = NVL(c_hourly_rate,-1)
     AND NVL(detf.amount,-1) = NVL(c_amount,  -1)
     AND detf.pa_status = 'C'
     AND NVL(detf.ffv_cost_center_id,-1) = NVL(c_ffv_cost_center_id, -1)
     AND NVL(detf.job_id,-1) = NVL(c_job_id, -1);
l_expired_rec l_expired_cur%ROWTYPE;

/***********************************************************
   Cursor to select details rows for backout transactions.
   Select all unprocessed rows 'C' that have been expired.
***********************************************************/
CURSOR l_backout_cur(c_summary_id NUMBER)IS
  SELECT  NVL(pro.proposed_salary_N,0) proposed_salary,
          ppb.pay_basis,
          fcl2.meaning emp_cat_description,
          payd.hxt_earning_category,
          payd.hxt_premium_type,
          NVL(payd.hxt_premium_amount,0) hxt_premium_amount,
          det.rowid row_id,
          det.id,
          det.hours,
          det.amount,
          det.date_worked,
          det.effective_start_date det_effective_start,
          det.effective_end_date det_effective_end,
          det.hourly_rate,
          det.rate_multiple,
          det.tas_id,
          det.ffv_cost_center_id,
          det.job_id,
          det.project_id,
          prj.name project_name,
          prj.segment1,
          task.task_number,
          task.task_name,
          org.name,
          payt.element_name,  --FORMS60
          asg.organization_id,
          det.element_type_id,  --SIR162
          asg.assignment_id,
          asg.assignment_number
     FROM hxt_det_hours_worked_f det,
          per_pay_proposals pro,
          per_pay_bases ppb,
          hr_lookups fcl,   --FORMS60
          hr_lookups fcl2,  --FORMS60
          per_assignments_f asg,
          hr_organization_units_v org,
          pay_element_types_f pay,
          pay_element_types_f_tl payt,  --FORMS60
          hxt_pay_element_types_f_ddf_v payd,
          pa_projects_all prj,
          pa_tasks task
    WHERE det.parent_id = c_summary_id
      AND det.pa_status = 'C'
      AND det.assignment_id = asg.assignment_id
      AND det.date_worked BETWEEN asg.effective_start_date AND asg.effective_end_date
      AND asg.pay_basis_id = ppb.pay_basis_id
      AND asg.organization_id = org.organization_id
      AND asg.assignment_id = pro.assignment_id
      AND pro.approved = 'Y'
      AND pro.change_date = (SELECT MAX(pro2.change_date)
                             FROM per_pay_proposals pro2
                             WHERE pro2.assignment_id = det.assignment_id
                             AND pro2.approved = 'Y'
                             AND det.date_worked >= pro2.change_date)
      AND payt.element_type_id = pay.element_type_id
      AND payt.language = userenv('LANG')
      AND pay.element_type_id = payd.element_type_id
      AND payd.element_type_id = det.element_type_id
      AND det.date_worked BETWEEN payd.effective_start_date
                              AND payd.effective_end_date
      AND det.date_worked BETWEEN pay.effective_start_date
                              AND pay.effective_end_date
      AND payd.hxt_earning_category = fcl.lookup_code
      AND fcl.lookup_type = 'HXT_EARNING_CATEGORY'
      AND fcl.application_id = 808
      AND asg.employment_category = fcl2.lookup_code
      AND fcl2.lookup_type = 'EMP_CAT'
      AND fcl2.application_id = 800
      AND det.project_id = prj.project_id
      AND det.tas_id = task.task_id(+)
      AND det.effective_end_date < hr_general.end_of_time;

--TA36 not needed. declared in FOR loop.l_backout_rec l_backout_cur%ROWTYPE;

l_retcode	      NUMBER DEFAULT 0;
l_message	      VARCHAR2(240) DEFAULT NULL;
l_premium_amount  NUMBER(22,5) DEFAULT 0.00000;
l_rate		  NUMBER(22,5) DEFAULT 0.00000;
l_standard_rate	  NUMBER(22,5) DEFAULT 0.00000;
l_premium_hours   NUMBER(22,5) DEFAULT NULL;

l_backout_hours   NUMBER(22,5) DEFAULT NULL;
l_backout_amount  NUMBER(22,5) DEFAULT NULL;

l_transfer_error  EXCEPTION;
l_adjusting_error EXCEPTION;
l_backout_error   EXCEPTION;
l_retro_error     EXCEPTION;

BEGIN

  -- Loop to process all summary records for this assignment
  HXT_UTIL.DEBUG('Processing NON-EWR time'); --HXT115
  FOR l_sum_rec IN l_sum_cur(i_timecard_id) LOOP

    g_err_effective_start := l_sum_rec.effective_start_date;
    g_err_effective_end := l_sum_rec.effective_end_date;
    g_sum_hours_err_id := l_sum_rec.id;

    -- Process all eligible time detail rows for this summary
    FOR l_non_rec IN l_non_cur(l_sum_rec.id) LOOP

      -- Calculate an houly rate for the salary basis
      IF l_non_rec.pay_basis = 'ANNUAL' THEN
        l_rate := l_non_rec.proposed_salary / l_hours_per_year;
      ELSIF l_non_rec.pay_basis = 'MONTHLY' THEN
        l_rate := (l_non_rec.proposed_salary * 12) / l_hours_per_year;
      ELSIF l_non_rec.pay_basis = 'PERIOD' THEN
        l_rate := (l_non_rec.proposed_salary * i_annual_pay_periods) / l_hours_per_year;
      ELSE -- 'HOURLY'
        l_rate := l_non_rec.proposed_salary;
      END IF;
      l_standard_rate := l_rate;

      HXT_UTIL.DEBUG('Employee '||i_employee_number||
                           ' timecard '||TO_CHAR(i_timecard_id) ||' assignment id of '||
                           TO_CHAR(l_non_rec.assignment_id));
      HXT_UTIL.DEBUG('Normal Hourly Rate for '||i_employee_number||' is: '
            ||TO_CHAR(l_rate));

      -- Take the override rate when one exists
      IF l_non_rec.hourly_rate IS NOT NULL THEN
        l_rate := l_non_rec.hourly_rate;
        HXT_UTIL.DEBUG('Using Override Hourly Rate of '||TO_CHAR(l_rate));
      END IF;

      -- Process Base Hours
    IF l_non_rec.hxt_earning_category IN ('ABS','OVT','REG') THEN
        -- BEGIN SIR#5
        -- Handle Flat Amounts on Base Hours Types
        IF l_non_rec.amount IS NOT NULL THEN
            l_premium_amount := l_non_rec.amount;
            HXT_UTIL.DEBUG('Sending Premium Flat amount entered on timecard, amount:'
              ||TO_CHAR(l_premium_amount)||
          ' '||l_non_rec.element_name||','||' hours:'||TO_CHAR(l_non_rec.hours));
        ELSE
          l_premium_amount := NULL;
          -- Calculate rate per hour for overtime using the available premium types
          IF l_non_rec.hxt_earning_category = 'OVT' THEN
            IF l_non_rec.hxt_premium_type = 'FACTOR' THEN
              -- Use the manually entered multiple when one exists
              -- else, use the multiple from the element descriptive flex
              IF l_non_rec.rate_multiple IS NOT NULL THEN
                l_rate := l_rate * l_non_rec.rate_multiple;
                HXT_UTIL.DEBUG(TO_CHAR(l_non_rec.rate_multiple)
                 ||'Sending Overtime FACTOR/manual multiple rate:'||
                 TO_CHAR(l_rate)||' '||l_non_rec.element_name||','
                 ||' hours:'||TO_CHAR(l_non_rec.hours));
              ELSE
                l_rate := l_rate * l_non_rec.hxt_premium_amount;
                HXT_UTIL.DEBUG(TO_CHAR(l_non_rec.hxt_premium_amount)
                 ||'Sending Overtime FACTOR/element premium rate:'||
                 TO_CHAR(l_rate)||' '||l_non_rec.element_name||','||' hours:'
                 ||TO_CHAR(l_non_rec.hours));
              END IF;
            ELSIF l_non_rec.hxt_premium_type = 'RATE' THEN
              l_rate := l_non_rec.hxt_premium_amount;
              HXT_UTIL.DEBUG('Sending Overtime RATE/element premium rate:'
                       ||TO_CHAR(l_rate)||
                    ' '||l_non_rec.element_name||','||' hours:'
                        ||TO_CHAR(l_non_rec.hours));
            ELSE -- FIXED amount per day
              l_rate := l_non_rec.hxt_premium_amount / l_non_rec.hours;
              HXT_UTIL.DEBUG('Sending Overtime Flat/element premium rate:'
               ||TO_CHAR(l_rate)||
               ' '||l_non_rec.element_name||','||' hours:'||TO_CHAR(l_non_rec.hours));
            END IF;
          ELSIF l_non_rec.hxt_earning_category = 'ABS' THEN
             HXT_UTIL.DEBUG('Sending Time at: rate:'||TO_CHAR(l_rate)||
          ' '||l_non_rec.element_name||','||' hours:'||TO_CHAR(l_non_rec.hours));
          ELSE
             HXT_UTIL.DEBUG('Sending Time at: rate:'||TO_CHAR(l_rate)||
           ' '||l_non_rec.element_name||','||' hours:'||TO_CHAR(l_non_rec.hours));
          END IF; -- ABS,OVT,REG
        END IF; -- IS amount NULL ?

        -- Select any rows where only the hours have changed
        OPEN l_expired_cur(l_non_rec.parent_id,
                           l_non_rec.project_id,
                           l_non_rec.tas_id,
                           l_non_rec.element_type_id,
                           l_non_rec.hourly_rate,
                           l_non_rec.amount,
                           l_non_rec.ffv_cost_center_id,
                           l_non_rec.job_id);


        FETCH l_expired_cur INTO l_expired_rec;

        -- Send adjusting enties to Project Accounting when only the hours have changed
        IF l_expired_cur%FOUND THEN
          -- Ignore identical entries, set these to 'D' for dead
          IF l_non_rec.hours <> l_expired_rec.hours THEN
            HXT_UTIL.DEBUG('This transaction is an adjustment for '
            ||TO_CHAR(l_non_rec.hours - l_expired_rec.hours)||' hours');
            l_retcode := hxt_pa_user_exits.p_a_interface
				(l_non_rec.hours - l_expired_rec.hours,
                                 l_rate,
                                 l_premium_amount,  --SIR#5
    			         l_non_rec.hxt_earning_category||l_non_rec.hxt_premium_type,
			         i_ending_date,
                                 i_employee_number,
                                 l_non_rec.emp_cat_description,
        			 l_non_rec.element_type_id, --SIR162
                                 l_non_rec.name,
                                 l_non_rec.organization_id,
                                 l_non_rec.date_worked,
                                 l_non_rec.det_effective_start,
                                 l_non_rec.det_effective_end,
                                 l_non_rec.element_name,
                                 l_non_rec.pay_basis,
                                 l_non_rec.id,
                                 l_non_rec.hxt_earning_category,
                                 TRUE,
                                 l_standard_rate,
                                 l_non_rec.project_id,
                                 l_non_rec.tas_id,
                                 l_non_rec.segment1,
                                 l_non_rec.task_number,
                                 l_non_rec.project_name,
                                 l_non_rec.task_name,
                                 l_non_rec.assignment_id,
                                 l_non_rec.ffv_cost_center_id,
                                 l_non_rec.job_id,
                                 o_location,
                                 o_error_text,
                                 o_system_text);
            IF l_retcode = 1 THEN
              CLOSE l_expired_cur;
              RAISE l_adjusting_error;
            END IF;

            -- Update the expired (now adjusted) row so we don't pick it up again.
            UPDATE hxt_det_hours_worked_f
               SET pa_status   = 'A'
             WHERE rowid  = l_expired_rec.row_id;

          ELSE

            -- Update expired rows matching exactly to 'D' for dead
            -- No new identical PA transaction will be sent because one already exists in PA
            -- The retro detail row replacing this one will be set to 'C' complete outside of the loops

            UPDATE hxt_det_hours_worked_f
               SET pa_status   = 'D'
             WHERE rowid  = l_expired_rec.row_id;

          END IF; -- identical entry

          CLOSE l_expired_cur;

        -- Send a new retro transaction to Project Accounting because vital data has changed
        ELSE

          CLOSE l_expired_cur;
          -- Pass a normal entry to Project Accounting for the retro rows

          HXT_UTIL.DEBUG('New transaction '||TO_CHAR(l_non_rec.hours)||' hours'); --HXT115
            l_retcode := hxt_pa_user_exits.p_a_interface
				(l_non_rec.hours,
                                 l_rate,
                                 l_premium_amount,  --SIR#5
    			         l_non_rec.hxt_earning_category||l_non_rec.hxt_premium_type,
			         i_ending_date,
                                 i_employee_number,
                                 l_non_rec.emp_cat_description,
			         l_non_rec.element_type_id, --SIR162
                                 l_non_rec.name,
                                 l_non_rec.organization_id,
                                 l_non_rec.date_worked,
                                 l_non_rec.det_effective_start,
                                 l_non_rec.det_effective_end,
                                 l_non_rec.element_name,
                                 l_non_rec.pay_basis,
                                 l_non_rec.id,
                                 l_non_rec.hxt_earning_category,
                                 TRUE,
                                 l_standard_rate,
                                 l_non_rec.project_id,
                                 l_non_rec.tas_id,
                                 l_non_rec.segment1,
                                 l_non_rec.task_number,
                                 l_non_rec.project_name,
                                 l_non_rec.task_name,
                                 l_non_rec.assignment_id,
                                 l_non_rec.ffv_cost_center_id,
                                 l_non_rec.job_id,
                                 o_location,
                                 o_error_text,
                                 o_system_text);
          IF l_retcode = 1 THEN
            RAISE l_retro_error;
          END IF;
        END IF; -- Adjusing entry or correcting entry
      -- End Base Hours Processing
      ELSE
        IF l_non_rec.hxt_premium_type = 'FACTOR' THEN
          -- Use the manually entered multiple when one exists
          -- else, use the multiple from the element descriptive flex
          IF l_non_rec.rate_multiple IS NOT NULL THEN
             l_rate := l_rate * l_non_rec.rate_multiple;
             HXT_UTIL.DEBUG(TO_CHAR(l_non_rec.rate_multiple)
                ||'Sending Premium FACTOR/manual multiple rate:'||
                                  TO_CHAR(l_rate)||' '||l_non_rec.element_name
                 ||','||' hours:'||TO_CHAR(l_non_rec.hours));
          ELSE
            -- When the element flex value is used,
            -- Factor premiums are calculated by multiplying the (rate x (premium - 1) x hours)
            l_rate := l_rate * (l_non_rec.hxt_premium_amount - 1);
            HXT_UTIL.DEBUG(TO_CHAR(l_non_rec.hxt_premium_amount)
              ||'Sending Premium FACTOR/element premium rate:'||
                                 TO_CHAR(l_rate)||' '||l_non_rec.element_name||','
              ||' hours:'||TO_CHAR(l_non_rec.hours));
          END IF;
          l_premium_hours := l_non_rec.hours;
          l_premium_amount := NULL;
        -- Rate per hour premiums are the (rate x hours)
        ELSIF l_non_rec.hxt_premium_type = 'RATE' THEN
          -- Use the Hourly Rate(override rate) entered by the user,
          -- if one has been entered
          IF l_non_rec.hourly_rate IS NOT NULL THEN
            l_rate := l_non_rec.hourly_rate;
            HXT_UTIL.DEBUG('Sending Premium RATE/element premium rate:'
             ||TO_CHAR(l_rate)||
            ' '||l_non_rec.element_name||','||' hours:'||TO_CHAR(l_non_rec.hours));
          -- Use the rate entered on the Pay Element flex segment
          ELSE
            l_rate := l_non_rec.hxt_premium_amount;
            HXT_UTIL.DEBUG('Sending Premium /element premium rate:'||TO_CHAR(l_rate)||
                   ' '||l_non_rec.element_name||','||' hours:'||TO_CHAR(l_non_rec.hours));
          END IF;
          l_premium_hours := l_non_rec.hours;
          l_premium_amount := NULL;
        -- FIXED amount premium
        ELSE
          -- If no amount was entered, Assign the premium attached to the Pay Element
          IF l_non_rec.amount IS NULL THEN
            l_premium_amount := l_non_rec.hxt_premium_amount;
            HXT_UTIL.DEBUG('Sending Premium Flat/element premium amount:'
           ||TO_CHAR(l_premium_amount)||
          ' '||l_non_rec.element_name||','||' hours:'||TO_CHAR(l_non_rec.hours));

          --Else, take the override premium amount entered on the timecard
          ELSE
            l_premium_amount := l_non_rec.amount;
            HXT_UTIL.DEBUG('Sending Premium Flat amount entered on timecard, amount:'
            ||TO_CHAR(l_premium_amount)||
            ' '||l_non_rec.element_name||','||' hours:'||TO_CHAR(l_non_rec.hours));

          END IF;
          l_premium_hours := NULL;
          l_rate := NULL;
        END IF; -- premium calculations

        --Select any rows where only the hours have changed
        OPEN l_expired_cur(l_non_rec.parent_id,
                           l_non_rec.project_id,
                           l_non_rec.tas_id,
                           l_non_rec.element_type_id,
                           l_non_rec.hourly_rate,
                           l_non_rec.amount,
                           l_non_rec.ffv_cost_center_id,
                           l_non_rec.job_id);

        FETCH l_expired_cur INTO l_expired_rec;

        --Send adjusting enties to Project Accounting
        IF l_expired_cur%FOUND THEN
          -- pickup changed hours entries
          IF NVL(l_non_rec.hours,-1) <> NVL(l_expired_rec.hours,-1) THEN

            HXT_UTIL.DEBUG('This is an adjusting entry for '
            ||to_char(l_non_rec.hours - l_expired_rec.hours)||' hours');
            l_retcode := hxt_pa_user_exits.p_a_interface
				(l_non_rec.hours - l_expired_rec.hours,
                                 l_rate,
                                 l_premium_amount,
    			         l_non_rec.hxt_earning_category||l_non_rec.hxt_premium_type,
				 i_ending_date,
                                 i_employee_number,
                                 l_non_rec.emp_cat_description,
				 l_non_rec.element_type_id, --SIR162
                                 l_non_rec.name,
                                 l_non_rec.organization_id,
                                 l_non_rec.date_worked,
                                 l_non_rec.det_effective_start,
                                 l_non_rec.det_effective_end,
                                 l_non_rec.element_name,
                                 l_non_rec.pay_basis,
                                 l_non_rec.id,
                                 l_non_rec.hxt_earning_category,
                                 TRUE,
                                 l_standard_rate,
                                 l_non_rec.project_id,
                                 l_non_rec.tas_id,
                                 l_non_rec.segment1,
                                 l_non_rec.task_number,
                                 l_non_rec.project_name,
                                 l_non_rec.task_name,
                                 l_non_rec.assignment_id,
                                 l_non_rec.ffv_cost_center_id,
                                 l_non_rec.job_id,
                                 o_location,
                                 o_error_text,
                                 o_system_text);
            IF l_retcode = 1 THEN
              CLOSE l_expired_cur;
              RAISE l_adjusting_error;
            END IF;

            -- Update the expired (now adjusted) row so we don't pick it up again.
            UPDATE hxt_det_hours_worked_f
               SET pa_status   = 'A'
             WHERE rowid  = l_expired_rec.row_id;

          ELSE
            -- Update expired rows matching exactly to 'D' for dead
            -- No new PA transaction will be sent because one already exists
            -- The retro detail row replacing this one will be set to 'C' outside of the loops

            UPDATE hxt_det_hours_worked_f
               SET pa_status   = 'D'
             WHERE rowid  = l_expired_rec.row_id;

          END IF; -- identical hours entry

          CLOSE l_expired_cur;

        --Send a new retro transaction to Project Accounting because vital data has changed
        ELSE

          CLOSE l_expired_cur;
          HXT_UTIL.DEBUG('New transaction '||TO_CHAR(l_non_rec.hours)||' hours');
          l_retcode := hxt_pa_user_exits.p_a_interface
				(l_premium_hours,
                                 l_rate,
                                 l_premium_amount,
                                 l_non_rec.hxt_earning_category||l_non_rec.hxt_premium_type,
                                 i_ending_date,
                                 i_employee_number,
                                 l_non_rec.emp_cat_description,
				 l_non_rec.element_type_id, --SIR162
                                 l_non_rec.name,
                                 l_non_rec.organization_id,
                                 l_non_rec.date_worked,
                                 l_non_rec.det_effective_start,
                                 l_non_rec.det_effective_end,
                                 l_non_rec.element_name,
                                 l_non_rec.pay_basis,
                                 l_non_rec.id,
                                 l_non_rec.hxt_earning_category,
                                 TRUE,
                                 l_standard_rate,
                                 l_non_rec.project_id,
                                 l_non_rec.tas_id,
                                 l_non_rec.segment1,
                                 l_non_rec.task_number,
                                 l_non_rec.project_name,
                                 l_non_rec.task_name,
                                 l_non_rec.assignment_id,
                                 l_non_rec.ffv_cost_center_id,
                                 l_non_rec.job_id,
                                 o_location,
                                 o_error_text,
                                 o_system_text);

          IF l_retcode = 1 THEN
            RAISE l_retro_error;
          END IF;

        END IF; -- adjust existing or add new retro row
      END IF;  -- end base or premium hours transfer
    END LOOP; -- detail loop

    -- Loop to pickup any detail rows still in a Complete Status (pa_status = 'C')
    -- Send a backout tranaction to Project Accounting (- hours) for these rows
    -- A new row representing the changes to these was inserted above as a retro row
    -- The backed out rows will have their status set to 'B' to prevent any future processing.
    -- Base hours and Premium hours are processed separately

    FOR l_backout_rec IN l_backout_cur(l_sum_rec.id) LOOP

      -- Calculate an houly rate for the salary basis
      IF l_backout_rec.pay_basis = 'ANNUAL' THEN
        l_rate := l_backout_rec.proposed_salary / l_hours_per_year;
      ELSIF l_backout_rec.pay_basis = 'MONTHLY' THEN
        l_rate := (l_backout_rec.proposed_salary * 12) / l_hours_per_year;
      ELSIF l_backout_rec.pay_basis = 'PERIOD' THEN
        l_rate := (l_backout_rec.proposed_salary * i_annual_pay_periods) / l_hours_per_year;
      ELSE -- 'HOURLY'
        l_rate := l_backout_rec.proposed_salary;
      END IF;
      l_standard_rate := l_rate;

      -- Take the override rate when one exists
      IF l_backout_rec.hourly_rate IS NOT NULL THEN
        l_rate := l_backout_rec.hourly_rate;
      END IF;

      -- Process Base Hours
      IF l_backout_rec.hxt_earning_category IN ('ABS','OVT','REG') THEN
        -- BEGIN SIR#5
        -- Handle Flat Amounts on Base Hours Types
        IF l_backout_rec.amount IS NOT NULL THEN
            l_backout_amount := l_backout_rec.amount * -1;
            HXT_UTIL.DEBUG('Sending backout for amount entered on timecard, amount:'
             ||TO_CHAR(l_backout_amount)||
             ' '||l_backout_rec.element_name||','||' hours:'||TO_CHAR(l_backout_rec.hours));
        ELSE
          l_backout_amount := NULL;
          -- Calculate rate per hour for overtime using the available premium types
          IF l_backout_rec.hxt_earning_category = 'OVT' THEN
            IF l_backout_rec.hxt_premium_type = 'FACTOR' THEN
              -- Use the manually entered multiple when one exists
              -- else, use the multiple from the element descriptive flex
              IF l_backout_rec.rate_multiple IS NOT NULL THEN
                l_rate := l_rate * l_backout_rec.rate_multiple;
              ELSE
                l_rate := l_rate * l_backout_rec.hxt_premium_amount;
              END IF;
            ELSIF l_backout_rec.hxt_premium_type = 'RATE' THEN
               l_rate := l_backout_rec.hxt_premium_amount;
            ELSE -- FIXED amount per day
              l_rate := l_backout_rec.hxt_premium_amount / l_backout_rec.hours;
            END IF;
          END IF;
          HXT_UTIL.DEBUG('Sending backout for '||TO_CHAR(l_backout_rec.hours)||' hours');
        END IF; -- IS AMOUNT NULL? SIR#5

        l_retcode := hxt_pa_user_exits.p_a_interface
			(l_backout_rec.hours * -1,
                         l_rate,
                         l_backout_amount, --SIR#5
                         l_backout_rec.hxt_earning_category||l_backout_rec.hxt_premium_type,
                         i_ending_date,
                         i_employee_number,
                         l_backout_rec.emp_cat_description,
			 l_backout_rec.element_type_id, --SIR162
                         l_backout_rec.name,
                         l_backout_rec.organization_id,
                         l_backout_rec.date_worked,
                         l_backout_rec.det_effective_start,
                         l_backout_rec.det_effective_end,
                         l_backout_rec.element_name,
                         l_backout_rec.pay_basis,
                         l_backout_rec.id,
                         l_backout_rec.hxt_earning_category,
                         TRUE,
                         l_standard_rate,
                         l_backout_rec.project_id,
                         l_backout_rec.tas_id,
                         l_backout_rec.segment1,
                         l_backout_rec.task_number,
                         l_backout_rec.project_name,
                         l_backout_rec.task_name,
                         l_backout_rec.assignment_id,
                         l_backout_rec.ffv_cost_center_id,
                         l_backout_rec.job_id,
                         o_location,
                         o_error_text,
                         o_system_text);
        IF l_retcode = 1 THEN
          RAISE l_backout_error;
        END IF;
      ELSE --process premium hours
        IF l_backout_rec.hxt_premium_type = 'FACTOR' THEN
          -- Use the manually entered multiple when one exists
          -- else, use the multiple from the element descriptive flex
          IF l_backout_rec.rate_multiple IS NOT NULL THEN
            l_rate := l_rate * l_backout_rec.rate_multiple;
          ELSE
            -- When the element flex value is used,
            -- Factor premiums are calculated by multiplying the (rate x (premium - 1) x hours)
            l_rate := l_rate * (l_backout_rec.hxt_premium_amount - 1);
          END IF;
          l_backout_hours := (l_backout_rec.hours * -1);
          l_backout_amount := NULL;
        -- Rate per hour premiums are the (rate x hours)
        ELSIF l_backout_rec.hxt_premium_type = 'RATE' THEN
          -- Use the Hourly Rate(override rate) entered by the user, if one has been entered
          IF l_backout_rec.hourly_rate IS NOT NULL THEN
            l_rate := l_backout_rec.hourly_rate;
          -- Use the rate entered on the Pay Element flex segment
          ELSE
            l_rate := l_backout_rec.hxt_premium_amount;
          END IF;
          l_backout_hours := (l_backout_rec.hours * -1);
          l_backout_amount := NULL;
        -- FIXED amount premium
        ELSE
          --If no amount was entered, Assign the premium attached to the Pay Element
          IF l_backout_rec.amount IS NULL THEN
            l_backout_amount := l_backout_rec.hxt_premium_amount;
          -- Else, take the override premium amount entered on the timecard
          ELSE
            l_backout_amount := (l_backout_rec.amount * -1);

          END IF;
          l_backout_hours := NULL;
          l_rate := NULL;
        END IF; -- premium calculations

        HXT_UTIL.DEBUG('Sending backout for '||TO_CHAR(l_backout_hours)||' hours');
        HXT_UTIL.DEBUG('Sending backout for '||TO_CHAR(l_backout_amount)||' amount');
        l_retcode := hxt_pa_user_exits.p_a_interface
			(l_backout_hours,
                         l_rate,
                         l_backout_amount,
                         l_backout_rec.hxt_earning_category||l_backout_rec.hxt_premium_type,
                         i_ending_date,
                         i_employee_number,
                         l_backout_rec.emp_cat_description,
			 l_backout_rec.element_type_id, --SIR162
                         l_backout_rec.name,
                         l_backout_rec.organization_id,
                         l_backout_rec.date_worked,
                         l_backout_rec.det_effective_start,
                         l_backout_rec.det_effective_end,
                         l_backout_rec.element_name,
                         l_backout_rec.pay_basis,
                         l_backout_rec.id,
                         l_backout_rec.hxt_earning_category,
                         TRUE,
                         l_standard_rate,
                         l_backout_rec.project_id,
                         l_backout_rec.tas_id,
                         l_backout_rec.segment1,
                         l_backout_rec.task_number,
                         l_backout_rec.project_name,
                         l_backout_rec.task_name,
                         l_backout_rec.assignment_id,
                         l_backout_rec.ffv_cost_center_id,
                         l_backout_rec.job_id,
                         o_location,
                         o_error_text,
                         o_system_text);
        IF l_retcode = 1 THEN
          RAISE l_backout_error;
        END IF;
      END IF; -- base or premium hours

      UPDATE hxt_det_hours_worked_f
         SET pa_status   = 'B'
       WHERE rowid = l_backout_rec.row_id;

    END LOOP; -- backout transactions
  END LOOP; -- summary loop
  RETURN 0;

EXCEPTION
  WHEN l_transfer_error THEN
    RETURN 1;
  WHEN l_adjusting_error THEN
    FND_MESSAGE.SET_NAME('HXT','HXT_39461_SEND_ADJ_TRANS');
    o_location := FND_MESSAGE.GET;
    FND_MESSAGE.CLEAR;
    o_system_text := NULL;
    RETURN 1;
  WHEN l_retro_error THEN
    FND_MESSAGE.SET_NAME('HXT','HXT_39462_SEND_RETRO_TRANS');
    o_location := FND_MESSAGE.GET;
    FND_MESSAGE.CLEAR;
    o_system_text := NULL;
    RETURN 1;
  WHEN l_backout_error THEN
    FND_MESSAGE.SET_NAME('HXT','HXT_39463_SEND_BACK_TRANS');
    o_location := FND_MESSAGE.GET;
    FND_MESSAGE.CLEAR;
    o_system_text := NULL;
    RETURN 1;
  WHEN OTHERS THEN
    o_location := 'hxt_retro_pa.retro_non_ewr_transfer' || l_message;
    o_error_text := NULL;
    o_system_text := SQLERRM;
    RETURN 1;
END retro_non_ewr_transfer;

/****************************************************
  log_transfer_errors()
  Errors are posted to HXT_ERRORS table.
****************************************************/
FUNCTION log_transfer_errors(	i_location IN VARCHAR2,
				i_error_text IN VARCHAR2,
			        i_system_text IN VARCHAR2)RETURN NUMBER IS
BEGIN

  HXT_UTIL.DEBUG('g_batch_err_id = ' || TO_CHAR(g_batch_err_id));
  HXT_UTIL.DEBUG('g_timecard_err_id = ' || TO_CHAR(g_timecard_err_id));
  HXT_UTIL.DEBUG('g_sum_hours_err_id = ' || g_sum_hours_err_id);
  HXT_UTIL.DEBUG('g_time_period_err_id = ' || TO_CHAR(g_time_period_err_id));
  HXT_UTIL.DEBUG('i_location = ' || i_location);
  HXT_UTIL.DEBUG('i_error_text = ' || i_error_text);
  HXT_UTIL.DEBUG('i_system_text = ' || i_system_text);

  hxt_util.Gen_Error(g_batch_err_id,
		    g_timecard_err_id,
		    g_sum_hours_err_id,
		    g_time_period_err_id,
  		    i_error_text,
		    i_location,
		    i_system_text,
                    g_err_effective_start,
		    g_err_effective_end,
                    'ERR');
  COMMIT;

RETURN 0;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE g_error_log_error;

END log_transfer_errors;

END HXT_RETRO_PA;

/
