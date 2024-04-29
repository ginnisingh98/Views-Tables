--------------------------------------------------------
--  DDL for Package Body HXT_TRAN_PA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXT_TRAN_PA" AS
/* $Header: hxtpa.pkb 120.3 2005/12/23 15:48:45 mhanda noship $ */
l_hours_per_year  	NUMBER(22,5) := TO_NUMBER(fnd_profile.Value('HXT_HOURS_PER_YEAR'));
g_debug boolean := hr_utility.debug_enabled;
PROCEDURE transfer_timecards( o_err_buf OUT NOCOPY VARCHAR2,
                              o_ret_code OUT NOCOPY NUMBER,
                              i_payroll_id IN NUMBER,
                              i_time_period_id IN NUMBER)IS
l_retcode           NUMBER        DEFAULT 0;
l_error_text        VARCHAR2(240) DEFAULT NULL;
l_system_text       VARCHAR2(120) DEFAULT NULL;
l_location          VARCHAR2(120) DEFAULT NULL;
l_ewr_error         EXCEPTION;
l_non_ewr_error     EXCEPTION;
l_conc_error        EXCEPTION;
l_no_timecards      EXCEPTION;
l_no_details        EXCEPTION;
l_batch_state       EXCEPTION;
l_conc_error_flag   BOOLEAN       DEFAULT FALSE;
l_any_timecards     BOOLEAN       DEFAULT FALSE;
l_sum_start_date    hxt_sum_hours_worked_f.effective_start_date%TYPE;
l_sum_end_date      hxt_sum_hours_worked_f.effective_end_date%TYPE;
l_sum_id            hxt_sum_hours_worked_f.id%TYPE;


--  Cursor to select each timecard within
--  the payroll/time-period requested

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
     AND ptp.time_period_id BETWEEN NVL(c_time_period_id,1)
                AND NVL(c_time_period_id,999999999)
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
		            AND det.pa_status = 'P');
--SIR420 START Don't skip rows with errors because errors are deleted in cursor below
--     AND NOT EXISTS (SELECT 'X'
--	               FROM hxt_errors_x err
--	              WHERE err.tim_id = tim.id
--                        AND err_type = 'ERR'              --HXT11i1
--	                AND err.hrw_id IS NOT NULL
--                    AND err.location NOT LIKE 'hxt_tran%'
--                    AND err.location NOT LIKE 'hxt_pa_user_exits.p_a_%');
--SIR420 END

BEGIN
  g_debug :=hr_utility.debug_enabled;
  if g_debug then
  	hr_utility.set_location('HXT_TRAN_PA.transfer_timecards',10);
  end if;

  HXT_UTIL.DEBUG('Selecting Cursor'); --DEBUG ONLY --HXT115

  -- select each timecard within the payroll/time-period

  FOR l_timecard_rec IN l_timecard_cur( i_payroll_id, i_time_period_id) LOOP

    if g_debug then
    	  hr_utility.set_location('HXT_TRAN_PA.transfer_timecards',20);
    end if;

    g_err_effective_start := l_timecard_rec.effective_start_date;
    g_err_effective_end := l_timecard_rec.effective_end_date;
    g_batch_err_id := l_timecard_rec.batch_id;

    BEGIN --timecard error block

      if g_debug then
      	    hr_utility.set_location('HXT_TRAN_PA.transfer_timecards',30);
      end if;

      l_any_timecards := TRUE;

   -- set id's related to each timecard for error messaging
      g_timecard_err_id := l_timecard_rec.id;
      g_time_period_err_id := l_timecard_rec.time_period_id;

      if g_debug then
      	    hr_utility.trace('l_timecard_rec.id = ' || TO_CHAR(l_timecard_rec.id));
            hr_utility.trace('l_timecard_rec.batch_id = ' || TO_CHAR(l_timecard_rec.batch_id));
            hr_utility.trace('l_timecard_rec.time_period_id = ' || TO_CHAR(l_timecard_rec.time_period_id));
            hr_utility.trace('l_timecard_rec.end_date = ' || TO_CHAR(l_timecard_rec.end_date));
      end if;

      HXT_UTIL.DEBUG('.'); --DEBUG ONLY
      HXT_UTIL.DEBUG('l_timecard_rec.id = ' ||
                        TO_CHAR(l_timecard_rec.id)); --DEBUG ONLY
      HXT_UTIL.DEBUG('l_timecard_rec.batch_id = '
                  || TO_CHAR(l_timecard_rec.batch_id)); --DEBUG ONLY
      HXT_UTIL.DEBUG('l_timecard_rec.time_period_id = '
                   || TO_CHAR(l_timecard_rec.time_period_id)); --DEBUG ONLY
      HXT_UTIL.DEBUG('l_timecard_rec.end_date = '
                  || fnd_date.date_to_chardate(l_timecard_rec.end_date)); --DEBUG ONLY

   -- Clean up existing transfer to PA errors for this payroll/period
      DELETE
        FROM hxt_errors_f errf
       WHERE errf.tim_id = l_timecard_rec.id
         AND (errf.location LIKE 'hxt_tran%'
            OR errf.location LIKE 'hxt_pa_user_exits.p_a_%');
      COMMIT;

      /*************************************************
      -- Effective Wage Rate Not Currently Implemented
      --
      --  Call the logic to calculate effective
      --  wage and transfer effective wage time
      --  details to Project Accounting.
      --
      --  g_sum_hours_err_id := NULL;
      --  l_retcode := hxt_ewr_pa.calc_effective_wage_rate(l_timecard_rec.id,
      --                                                  l_timecard_rec.end_date,
      --                                                  l_timecard_rec.number_per_fiscal_year,
      --                                                 'Y',
      --                                                  l_timecard_rec.employee_number,
      --                                                  l_sum_start_date,
      --                                                  l_sum_end_date,
      --                                                  l_sum_id,
      --                                                  l_location,
      --                                                  l_error_text,
      --                                                  l_system_text);
      -- Report any errors for EWR and ROLLBACK
      -- IF l_retcode = 1 THEN
      --   g_err_effective_start := l_sum_start_date;
      --   g_err_effective_end := l_sum_end_date;
      --   g_sum_hours_err_id := l_sum_id;
      --   RAISE l_ewr_error;
      -- END IF;
      ****************************************************/

      -- Call the logic to transfer time
      -- details to Project Accounting that
      -- were not included in Effective
      -- Wage Rate processing.

      if g_debug then
      	    hr_utility.set_location('HXT_TRAN_PA.transfer_timecards',40);
      end if;

      l_retcode := non_eff_wage_rate_transfer(l_timecard_rec.id,
                                              l_timecard_rec.end_date,
                                              l_timecard_rec.number_per_fiscal_year,
                                              l_timecard_rec.employee_number,
                                              l_location,
                                              l_error_text,
                                              l_system_text);

      -- Report any errors for non-EWR and ROLLBACK
      IF l_retcode = 1 THEN
        if g_debug then
              hr_utility.set_location('HXT_TRAN_PA.transfer_timecards',50);
        end if;
        RAISE l_non_ewr_error;
      END IF;
      if g_debug then
      	    hr_utility.set_location('HXT_TRAN_PA.transfer_timecards',60);
      end if;
      COMMIT; -- commit data for this timecard

      EXCEPTION
        -- Effective Wage Rate Errors
        WHEN l_ewr_error THEN
          if g_debug then
          	hr_utility.set_location('HXT_TRAN_PA.transfer_timecards',70);
          end if;
          ROLLBACK;
          l_retcode := log_transfer_errors(l_location, l_error_text, l_system_text);
          l_conc_error_flag := TRUE;
        -- Non Effective Wage Rate Errors
        WHEN l_non_ewr_error THEN
          if g_debug then
          	hr_utility.set_location('HXT_TRAN_PA.transfer_timecards',80);
          end if;
          ROLLBACK;
          l_retcode := log_transfer_errors(l_location, l_error_text, l_system_text);
          l_conc_error_flag := TRUE;
        -- Other errors
        WHEN OTHERS THEN
          if g_debug then
          	hr_utility.set_location('HXT_TRAN_PA.transfer_timecards',90);
          end if;
          ROLLBACK;
          l_location := 'hxt_tran_pa.transfer_timecards';
          FND_MESSAGE.SET_NAME('HXT','HXT_39454_PA_XFER_ERROR');
          l_error_text := FND_MESSAGE.GET;
          FND_MESSAGE.CLEAR;
          l_system_text := SQLERRM;
          l_retcode := log_transfer_errors(l_location, l_error_text, l_system_text);
          l_conc_error_flag := TRUE;
    END; -- timecard error block
    if g_debug then
    	  hr_utility.set_location('HXT_TRAN_PA.transfer_timecards',100);
    end if;
  END LOOP; -- timecard loop

  -- Return an error if any timecards had a problem
  IF l_conc_error_flag = TRUE THEN
    if g_debug then
    	  hr_utility.set_location('HXT_TRAN_PA.transfer_timecards',110);
    end if;
    RAISE l_conc_error;
  END IF;

  -- Return an error if NO timecards exist for this payroll/period
  IF l_any_timecards = FALSE THEN
    if g_debug then
    	  hr_utility.set_location('HXT_TRAN_PA.transfer_timecards',120);
    end if;
    RAISE l_no_timecards;
  END IF;
  o_ret_code := 0;
  FND_MESSAGE.SET_NAME('HXT','HXT_39455_DET_XFER_SUCCESS');
  o_err_buf := FND_MESSAGE.GET;
  FND_MESSAGE.CLEAR;
  HXT_UTIL.DEBUG('Time details successfully transferred!');
EXCEPTION
  WHEN l_conc_error THEN
    if g_debug then
    	  hr_utility.set_location('HXT_TRAN_PA.transfer_timecards',130);
    end if;
    FND_MESSAGE.SET_NAME('HXT','HXT_39456_CHK_TCARD_ERRS');
    o_err_buf := FND_MESSAGE.GET;
    FND_MESSAGE.CLEAR;
    o_ret_code := 2;
    HXT_UTIL.DEBUG('Check timecards for errors or run timecard report.');
    RETURN;
  WHEN l_no_timecards THEN
    if g_debug then
    	  hr_utility.set_location('HXT_TRAN_PA.transfer_timecards',140);
    end if;
--HXT111    o_err_buf := 'No timecards located for payroll/period';
    FND_MESSAGE.SET_NAME('HXT','HXT_39457_NO_TCARD_4_PAY_PRD');
    o_err_buf := FND_MESSAGE.GET;
    FND_MESSAGE.CLEAR;
    o_ret_code := 2;
    HXT_UTIL.DEBUG('No timecards located for this payroll');
    RETURN;
  WHEN l_no_details THEN
    if g_debug then
    	  hr_utility.set_location('HXT_TRAN_PA.transfer_timecards',150);
    end if;
--HXT111    o_err_buf := 'No timecard details transferable';
    FND_MESSAGE.SET_NAME('HXT','HXT_39458_NO_TCARD_DET_XFER');
    o_err_buf := FND_MESSAGE.GET;
    FND_MESSAGE.CLEAR;
    o_ret_code := 0;
    HXT_UTIL.DEBUG('No timecard details transferable');
    RETURN;
  WHEN g_error_log_error THEN
    if g_debug then
    	  hr_utility.set_location('HXT_TRAN_PA.transfer_timecards',160);
    end if;
    FND_MESSAGE.SET_NAME('HXT','HXT_39459_HXTPA_ERR');
    o_err_buf := FND_MESSAGE.GET;
    FND_MESSAGE.CLEAR;
    HXT_UTIL.DEBUG('Error in hxt_tran_pa.log_transfer_errors.');
    o_ret_code := 2;
    RETURN;
  WHEN OTHERS THEN
    if g_debug then
    	  hr_utility.set_location('HXT_TRAN_PA.transfer_timecards',170);
    end if;
    l_location := 'hxt_tran_pa';
    FND_MESSAGE.SET_NAME('HXT','HXT_39454_PA_XFER_ERROR');
    l_error_text := FND_MESSAGE.GET;
    FND_MESSAGE.CLEAR;
    l_system_text := SQLERRM;
    l_retcode := log_transfer_errors(l_location, l_error_text, l_system_text);
    o_ret_code := 2;
    FND_MESSAGE.SET_NAME('HXT','HXT_39459_HXTPA_ERR');
    o_err_buf := FND_MESSAGE.GET;
    FND_MESSAGE.CLEAR;
    HXT_UTIL.DEBUG('Error processing timecard for PA Transfer');
    RETURN;
END transfer_timecards;

/***********************************************************************************
  non_eff_wage_rate_transfer()
  Processing of transfer to Project Accounting for all Time details not
  processed as a part of the Effective Wage Rate Logic.
************************************************************************************/
FUNCTION non_eff_wage_rate_transfer(i_timecard_id IN NUMBER,
			  	   i_ending_date IN DATE,
				   i_annual_pay_periods IN NUMBER,
                                   i_employee_number IN VARCHAR2,
				   o_location OUT NOCOPY VARCHAR2,
				   o_error_text OUT NOCOPY VARCHAR2,
				   o_system_text OUT NOCOPY VARCHAR2)RETURN NUMBER IS
/********************************************************************
    Cursor to select all detail rows associated with the timecard
    that are not associated with Effective Wage Rate calculations.
    Each hourly detail row will be passed to Project Accounting.
*********************************************************************/
CURSOR l_non_cur(c_timecard_id NUMBER)IS
SELECT    NVL(pro.proposed_salary_N,0) proposed_salary,
          ppb.pay_basis,
          fcl2.meaning emp_cat_description,
          payd.hxt_earning_category,
          payd.hxt_premium_type,
          NVL(payd.hxt_premium_amount,0) hxt_premium_amount,
          shw.id sum_id,
          shw.effective_start_date,
          shw.effective_end_date,
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
          prj.project_id,
          prj.name project_name,
          prj.segment1,
          task.task_number,
          task.task_name,
          org.name,
          payt.element_name,
          asg.organization_id,
          det.element_type_id,
          asg.assignment_id,
          asg.assignment_number
     FROM hxt_det_hours_worked_x det,
          hxt_sum_hours_worked_x shw,
          per_assignments_f asg,
          per_pay_bases ppb,
          per_pay_proposals pro,
          hr_organization_units_v org,
          hr_lookups fcl,
          hr_lookups fcl2,
          pay_element_types_f pay,
          pay_element_types_f_tl payt,
          hxt_pay_element_types_f_ddf_v payd,
          pa_projects_all prj,
          pa_tasks task
    WHERE det.tim_id = c_timecard_id
      AND det.parent_id = shw.id
      AND det.pa_status = 'P'
      AND det.assignment_id = asg.assignment_id
      AND det.date_worked BETWEEN asg.effective_start_date AND asg.effective_end_date
      AND asg.pay_basis_id = ppb.pay_basis_id
      AND asg.organization_id = org.organization_id
      AND pro.assignment_id = det.assignment_id
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
      AND det.date_worked BETWEEN pay.effective_start_date
                              AND pay.effective_end_date
      AND det.date_worked BETWEEN payd.effective_start_date
                              AND payd.effective_end_date
      AND payd.hxt_earning_category = fcl.lookup_code
      AND fcl.lookup_type = 'HXT_EARNING_CATEGORY'
      AND fcl.application_id = 808
      AND asg.employment_category = fcl2.lookup_code
      AND fcl2.lookup_type = 'EMP_CAT'
      AND fcl2.application_id = 800
      AND det.project_id = prj.project_id
      AND det.tas_id = task.task_id(+);
--TA36 not needed. declared in FOR loop.l_non_rec l_non_cur%ROWTYPE;

l_retcode	      NUMBER DEFAULT 0;
l_premium_amount      NUMBER(22,5) DEFAULT 0.00000;
l_rate		      NUMBER(22,5) DEFAULT 0.00000;
l_standard_rate       NUMBER(22,5) DEFAULT 0.00000;
l_premium_hours	      NUMBER(22,5) DEFAULT NULL;
l_transfer_error      EXCEPTION;

BEGIN
  g_debug :=hr_utility.debug_enabled;
  if g_debug then
  	hr_utility.set_location('HXT_TRAN_PA.non_eff_wage_rate_transfer',10);
  end if;
  HXT_UTIL.DEBUG('Processing NON-EWR time');

--Process all eligible time detail rows for this timecard
  FOR l_non_rec IN l_non_cur(i_timecard_id) LOOP
    if g_debug then
    	  hr_utility.set_location('HXT_TRAN_PA.non_eff_wage_rate_transfer',20);
    end if;
    HXT_UTIL.DEBUG('  in the loop');
    g_err_effective_start := l_non_rec.effective_start_date;
    g_err_effective_end := l_non_rec.effective_end_date;
    g_sum_hours_err_id := l_non_rec.sum_id;

    if g_debug then
       	  hr_utility.trace('l_non_rec.sum_id = ' || TO_CHAR(l_non_rec.sum_id));
    	  hr_utility.trace('l_non_rec.effective_start_date = '||fnd_date.date_to_chardate(l_non_rec.effective_start_date));
    	  hr_utility.trace('l_non_rec.effective_end_date = '||fnd_date.date_to_chardate(l_non_rec.effective_end_date));
    end if;
    -- Calculate an houly rate for the salary basis
    IF l_non_rec.pay_basis = 'ANNUAL' THEN
      if g_debug then
      	    hr_utility.set_location('HXT_TRAN_PA.non_eff_wage_rate_transfer',30);
      end if;
      l_rate := l_non_rec.proposed_salary / l_hours_per_year;
    ELSIF l_non_rec.pay_basis = 'MONTHLY' THEN
      if g_debug then
      	    hr_utility.set_location('HXT_TRAN_PA.non_eff_wage_rate_transfer',40);
      end if;
      l_rate := (l_non_rec.proposed_salary * 12) / l_hours_per_year;
    ELSIF l_non_rec.pay_basis = 'PERIOD' THEN
      if g_debug then
      	    hr_utility.set_location('HXT_TRAN_PA.non_eff_wage_rate_transfer',50);
      end if;
      l_rate := (l_non_rec.proposed_salary * i_annual_pay_periods) / l_hours_per_year;
    ELSE -- 'HOURLY'
      if g_debug then
      	    hr_utility.set_location('HXT_TRAN_PA.non_eff_wage_rate_transfer',60);
      end if;
      l_rate := l_non_rec.proposed_salary;
    END IF;
    l_standard_rate := l_rate;

    HXT_UTIL.DEBUG('Employee '||i_employee_number|| --HXT115
                         ' timecard '||TO_CHAR(i_timecard_id) ||' assignment id of '||
                         TO_CHAR(l_non_rec.assignment_id));
    HXT_UTIL.DEBUG('Normal Hourly Rate for '||i_employee_number||' is: '
                   ||TO_CHAR(l_rate));
    -- Take the override rate when one exists
    IF l_non_rec.hourly_rate IS NOT NULL THEN
      if g_debug then
      	    hr_utility.set_location('HXT_TRAN_PA.non_eff_wage_rate_transfer',70);
      end if;
      l_rate := l_non_rec.hourly_rate;
      HXT_UTIL.DEBUG('Using Override Hourly Rate of '||TO_CHAR(l_rate));
    END IF;

    -- Process Base Hours
    IF l_non_rec.hxt_earning_category IN ('ABS','OVT','REG') THEN
      if g_debug then
      	    hr_utility.set_location('HXT_TRAN_PA.non_eff_wage_rate_transfer',80);
      end if;
   -- Handle Flat Amounts on Base Hours Types
      IF l_non_rec.amount IS NOT NULL THEN
        if g_debug then
              hr_utility.set_location('HXT_TRAN_PA.non_eff_wage_rate_transfer',90);
        end if;
        l_premium_amount := l_non_rec.amount;
        HXT_UTIL.DEBUG('Sending Premium Flat amount entered on timecard, amount:'
               ||TO_CHAR(l_premium_amount)||
             ' '||l_non_rec.element_name||','||' hours:'||TO_CHAR(l_non_rec.hours));
      ELSE
        if g_debug then
              hr_utility.set_location('HXT_TRAN_PA.non_eff_wage_rate_transfer',100);
        end if;
        l_premium_amount := NULL;
     -- Calculate rate per hour for overtime using the available premium types
        IF l_non_rec.hxt_earning_category = 'OVT' THEN
          if g_debug then
          	hr_utility.set_location('HXT_TRAN_PA.non_eff_wage_rate_transfer',110);
          end if;
          IF l_non_rec.hxt_premium_type = 'FACTOR' THEN
             if g_debug then
             	   hr_utility.set_location('HXT_TRAN_PA.non_eff_wage_rate_transfer',120);
             end if;
            -- Use the manually entered multiple when one exists
            -- else, use the multiple from the element descriptive flex
            IF l_non_rec.rate_multiple IS NOT NULL THEN
              if g_debug then
              	    hr_utility.set_location('HXT_TRAN_PA.non_eff_wage_rate_transfer',130);
              end if;
              l_rate := l_rate * l_non_rec.rate_multiple;
              HXT_UTIL.DEBUG(TO_CHAR(l_non_rec.rate_multiple)
               ||'Sending Overtime FACTOR/manual multiple rate:'|| TO_CHAR(l_rate)
               ||' '||l_non_rec.element_name||','||' hours:'||TO_CHAR(l_non_rec.hours));
            ELSE
              if g_debug then
              	    hr_utility.set_location('HXT_TRAN_PA.non_eff_wage_rate_transfer',140);
              end if;
              l_rate := l_rate * l_non_rec.hxt_premium_amount;
              HXT_UTIL.DEBUG(TO_CHAR(l_non_rec.hxt_premium_amount)
                            ||'Sending Overtime FACTOR/element premium rate:'||
                            TO_CHAR(l_rate)||' '||l_non_rec.element_name||','||' hours:'
                            ||TO_CHAR(l_non_rec.hours));
            END IF;
          ELSIF l_non_rec.hxt_premium_type = 'RATE' THEN
            if g_debug then
            	  hr_utility.set_location('HXT_TRAN_PA.non_eff_wage_rate_transfer',150);
            end if;
            l_rate := l_non_rec.hxt_premium_amount;
            HXT_UTIL.DEBUG('Sending Overtime RATE/element premium rate:'||TO_CHAR(l_rate)||
                   ' '||l_non_rec.element_name||','||' hours:'||TO_CHAR(l_non_rec.hours));
          ELSE -- FIXED amount per day
            if g_debug then
            	  hr_utility.set_location('HXT_TRAN_PA.non_eff_wage_rate_transfer',160);
            end if;
            l_rate := l_non_rec.hxt_premium_amount / l_non_rec.hours;
            HXT_UTIL.DEBUG('Sending Overtime Flat/element premium rate:'||TO_CHAR(l_rate)||
                      ' '||l_non_rec.element_name||','||' hours:'||TO_CHAR(l_non_rec.hours));
          END IF;
        ELSIF l_non_rec.hxt_earning_category = 'ABS' THEN
           if g_debug then
           	 hr_utility.set_location('HXT_TRAN_PA.non_eff_wage_rate_transfer',170);
           end if;
           HXT_UTIL.DEBUG('Sending Time at: rate:'||TO_CHAR(l_rate)||
             ' '||l_non_rec.element_name||','||' hours:'||TO_CHAR(l_non_rec.hours));
        ELSE
           if g_debug then
           	 hr_utility.set_location('HXT_TRAN_PA.non_eff_wage_rate_transfer',180);
           end if;
           HXT_UTIL.DEBUG('Sending Time at: rate:'||TO_CHAR(l_rate)|| --HXT115
             ' '||l_non_rec.element_name||','||' hours:'||TO_CHAR(l_non_rec.hours));
        END IF;
      END IF; --End Amount NULL? SIR#5

      if g_debug then
      	    hr_utility.set_location('HXT_TRAN_PA.non_eff_wage_rate_transfer',190);
      end if;
      l_retcode := hxt_pa_user_exits.p_a_interface
			       (l_non_rec.hours,
				l_rate,
                                l_premium_amount,
				l_non_rec.hxt_earning_category||l_non_rec.hxt_premium_type,
				i_ending_date,
                                i_employee_number,
				l_non_rec.emp_cat_description,
				l_non_rec.element_type_id,
				l_non_rec.name,
                                l_non_rec.organization_id,
				l_non_rec.date_worked,
				l_non_rec.det_effective_start,
				l_non_rec.det_effective_end,
				l_non_rec.element_name,
				l_non_rec.pay_basis,
				l_non_rec.id,
			        l_non_rec.hxt_earning_category,
				FALSE,
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
          if g_debug then
          	hr_utility.set_location('HXT_TRAN_PA.non_eff_wage_rate_transfer',200);
          end if;
          RAISE l_transfer_error;
        END IF;
    -- End Base Hours Processing
    ELSE
        if g_debug then
              hr_utility.set_location('HXT_TRAN_PA.non_eff_wage_rate_transfer',210);
        end if;
        IF l_non_rec.hxt_premium_type = 'FACTOR' THEN
          if g_debug then
          	hr_utility.set_location('HXT_TRAN_PA.non_eff_wage_rate_transfer',220);
          end if;
       -- Use the manually entered multiple when one exists
       -- else, use the multiple from the element descriptive flex
          IF l_non_rec.rate_multiple IS NOT NULL THEN
            if g_debug then
            	  hr_utility.set_location('HXT_TRAN_PA.non_eff_wage_rate_transfer',230);
            end if;
            l_rate := l_rate * l_non_rec.rate_multiple;
            HXT_UTIL.DEBUG(TO_CHAR(l_non_rec.rate_multiple)
                            ||'Sending Premium FACTOR/manual multiple rate:'||
                                 TO_CHAR(l_rate)||' '||l_non_rec.element_name
                            ||','||' hours:'||TO_CHAR(l_non_rec.hours));
          ELSE
            if g_debug then
               	  hr_utility.set_location('HXT_TRAN_PA.non_eff_wage_rate_transfer',240);
            end if;
         -- When the element flex value is used,
         -- Factor premiums are calculated by multiplying the (rate x (premium - 1) x hours)
            l_rate := l_rate * (l_non_rec.hxt_premium_amount - 1);
            HXT_UTIL.DEBUG(TO_CHAR(l_non_rec.hxt_premium_amount)||
                           'Sending Premium FACTOR/element premium rate:'||
                            TO_CHAR(l_rate)||' '||l_non_rec.element_name||','||' hours:'
                            ||TO_CHAR(l_non_rec.hours));
          END IF;
        -- Rate per hour premiums are the (rate x hours)
        ELSIF l_non_rec.hxt_premium_type = 'RATE' THEN
            if g_debug then
            	  hr_utility.set_location('HXT_TRAN_PA.non_eff_wage_rate_transfer',250);
            end if;
         -- Use the Hourly Rate(override rate) entered by the user, if one has been entered
          IF l_non_rec.hourly_rate IS NOT NULL THEN
            if g_debug then
            	  hr_utility.set_location('HXT_TRAN_PA.non_eff_wage_rate_transfer',260);
            end if;
            l_rate := l_non_rec.hourly_rate;
            HXT_UTIL.DEBUG('Sending Premium RATE/element premium rate:'||TO_CHAR(l_rate)||
                      ' '||l_non_rec.element_name||','||' hours:'||TO_CHAR(l_non_rec.hours));
          -- Use the rate entered on the Pay Element flex segment
          ELSE
            if g_debug then
            	  hr_utility.set_location('HXT_TRAN_PA.non_eff_wage_rate_transfer',270);
            end if;
            l_rate := l_non_rec.hxt_premium_amount;
            HXT_UTIL.DEBUG('Sending Premium Flat/element premium rate:'||TO_CHAR(l_rate)||
                      ' '||l_non_rec.element_name||','||' hours:'||TO_CHAR(l_non_rec.hours));
          END IF;
        -- FIXED amount premium
        ELSE
            if g_debug then
            	  hr_utility.set_location('HXT_TRAN_PA.non_eff_wage_rate_transfer',280);
            end if;
          -- If no amount was entered, Assign the premium attached to the Pay Element
          IF l_non_rec.amount IS NULL THEN
            if g_debug then
            	  hr_utility.set_location('HXT_TRAN_PA.non_eff_wage_rate_transfer',290);
            end if;
            l_premium_amount := l_non_rec.hxt_premium_amount;
            HXT_UTIL.DEBUG('Sending Premium Flat/element premium amount:'||TO_CHAR(l_premium_amount)
                           || ' '||l_non_rec.element_name||','||' hours:'||TO_CHAR(l_non_rec.hours));
          -- Else, take the override premium amount entered on the timecard
          ELSE
            if g_debug then
            	  hr_utility.set_location('HXT_TRAN_PA.non_eff_wage_rate_transfer',300);
            end if;
            l_premium_amount := l_non_rec.amount;
            HXT_UTIL.DEBUG('Sending Premium Flat amount entered on timecard, amount:'
                           ||TO_CHAR(l_premium_amount)||
                        ' '||l_non_rec.element_name||','||' hours:'||TO_CHAR(l_non_rec.hours));
          END IF;
          if g_debug then
          	hr_utility.set_location('HXT_TRAN_PA.non_eff_wage_rate_transfer',310);
          end if;
        END IF; -- premium calculations

      if g_debug then
      	    hr_utility.set_location('HXT_TRAN_PA.non_eff_wage_rate_transfer',320);
      end if;
      l_retcode := hxt_pa_user_exits.p_a_interface
			       (l_non_rec.hours,
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
				FALSE,
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
         if g_debug then
         	hr_utility.set_location('HXT_TRAN_PA.non_eff_wage_rate_transfer',330);
         end if;
         RAISE l_transfer_error;
       END IF;
    END IF; -- end premium hours transfer

 -- Update the detail rows to a completed status
    if g_debug then
    	  hr_utility.set_location('HXT_TRAN_PA.non_eff_wage_rate_transfer',340);
    end if;
    UPDATE hxt_det_hours_worked_f detf
       SET detf.pa_status = 'C'
     WHERE detf.rowid = (SELECT det2.rowid
			   FROM hxt_det_hours_worked_x det2
			  WHERE l_non_rec.id = det2.id);
  END LOOP;
  if g_debug then
  	hr_utility.set_location('HXT_TRAN_PA.non_eff_wage_rate_transfer',350);
  end if;
  RETURN 0;
EXCEPTION
  WHEN l_transfer_error THEN
    if g_debug then
    	  hr_utility.set_location('HXT_TRAN_PA.non_eff_wage_rate_transfer',360);
    end if;
    RETURN 1;
  WHEN OTHERS THEN
    if g_debug then
    	  hr_utility.set_location('HXT_TRAN_PA.non_eff_wage_rate_transfer',370);
    end if;
    HXT_UTIL.DEBUG('exception in non_eff_wage: '||SQLERRM);
    o_location := 'hxt_tran_pa.non_eff_wage_rate_transfer';
    o_error_text := NULL;
    o_system_text := SQLERRM;
    RETURN 1;
END non_eff_wage_rate_transfer;
/****************************************************
  log_transfer_errors()
  Errors are posted to HXT_ERRORS table.
****************************************************/
FUNCTION log_transfer_errors(i_location IN VARCHAR2,
                             i_error_text IN VARCHAR2,
                             i_system_text IN VARCHAR2)RETURN NUMBER IS
BEGIN
  g_debug :=hr_utility.debug_enabled;
  if g_debug then
  	hr_utility.set_location('HXT_TRAN_PA.log_transfer_errors',10);
  end if;
  HXT_UTIL.DEBUG('g_batch_err_id = ' || TO_CHAR(g_batch_err_id)); --DEBUG ONLY
  HXT_UTIL.DEBUG('g_timecard_err_id = ' || TO_CHAR(g_timecard_err_id)); --DEBUG ONLY
  HXT_UTIL.DEBUG('g_sum_hours_err_id = ' || g_sum_hours_err_id); --DEBUG ONLY
  HXT_UTIL.DEBUG('g_time_period_err_id = ' || TO_CHAR(g_time_period_err_id)); --DEBUG ONLY
  HXT_UTIL.DEBUG('i_location = ' || i_location); --DEBUG ONLY
  HXT_UTIL.DEBUG('i_error_text = ' || i_error_text); --DEBUG ONLY
  HXT_UTIL.DEBUG('i_system_text = ' || i_system_text); --DEBUG ONLY
  hxt_util.Gen_Error(g_batch_err_id,
                    g_timecard_err_id,
                    g_sum_hours_err_id,
                    g_time_period_err_id,
                    i_error_text,
                    i_location,
                    i_system_text,
                    g_err_effective_start,
                    g_err_effective_end,
                    'ERR');                     --HXT11i1
   COMMIT;
   if g_debug then
   	 hr_utility.set_location('HXT_TRAN_PA.log_transfer_errors',20);
   end if;

RETURN 0;
  EXCEPTION
    WHEN OTHERS THEN
      if g_debug then
      	    hr_utility.set_location('HXT_TRAN_PA.log_transfer_errors',30);
      end if;
      RAISE g_error_log_error;
END log_transfer_errors;

--begin


END HXT_TRAN_PA;

/
