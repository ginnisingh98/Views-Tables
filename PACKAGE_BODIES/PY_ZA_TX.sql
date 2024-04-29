--------------------------------------------------------
--  DDL for Package Body PY_ZA_TX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PY_ZA_TX" AS
/* $Header: pyzatax.pkb 120.2 2005/06/28 00:11:26 kapalani noship $ */

/* Function: tax_as_per_table calculates tax on a given amount according to the ZA Tax table */
  FUNCTION calc_tax_on_table(
    payroll_action_id NUMBER,
    p_taxable_amount NUMBER,
    p_tax_rebate  NUMBER
  ) RETURN NUMBER

  AS

    l_effective_date DATE;
    l_user_table_id pay_user_tables.user_table_id%TYPE;
    l_fixed_column_id pay_user_columns.user_column_id%TYPE;
    l_limit_column_id pay_user_columns.user_column_id%TYPE;
    l_percentage_column_id pay_user_columns.user_column_id%TYPE;
    l_bracket_row pay_user_rows_f.user_row_id%TYPE;
    l_fixed pay_user_column_instances_f.value%TYPE;
    l_limit pay_user_column_instances_f.value%TYPE;
    l_percentage pay_user_column_instances_f.value%TYPE;
    tax_liability NUMBER;
    l_id NUMBER;


  BEGIN

  /* Done for jion */
    l_id := payroll_action_id;

  /* this selects the effective date for the payroll_run*/
    select ppa.effective_date
      into l_effective_date
      from pay_payroll_actions ppa
      where ppa.payroll_action_id = l_id;

  /* Selects to get the relevant id's */
    select user_table_id
      into l_user_table_id
      from pay_user_tables
      where user_table_name = 'ZA_TAX_TABLE';

    select user_column_id
      into l_fixed_column_id
      from pay_user_columns
      where user_table_id = l_user_table_id
      and user_column_name = 'Fixed';

    select user_column_id
      into l_limit_column_id
      from pay_user_columns
      where user_table_id = l_user_table_id
      and user_column_name = 'Limit';

    select user_column_id
      into l_percentage_column_id
      from pay_user_columns
      where user_table_id = l_user_table_id
      and user_column_name = 'Percentage';

    select purf.user_row_id
      into l_bracket_row
      from pay_user_rows_f purf
      where purf.user_table_id = l_user_table_id
      and (l_effective_date >= purf.effective_start_date
      and l_effective_date <= purf.effective_end_date)
      and (p_taxable_amount >= purf.row_low_range_or_name
      and p_taxable_amount <= purf.row_high_range);

  /* Selects to get the actual values */
    select pucif.value
      into l_fixed
      from pay_user_column_instances_f pucif
      where pucif.user_row_id = l_bracket_row
      and (l_effective_date >= pucif.effective_start_date
      and l_effective_date <= pucif.effective_end_date)
      and pucif.user_column_id = l_fixed_column_id;

    select pucif.value
      into l_limit
      from pay_user_column_instances_f pucif
      where pucif.user_row_id = l_bracket_row
      and (l_effective_date >= pucif.effective_start_date
      and l_effective_date <= pucif.effective_end_date)
      and pucif.user_column_id = l_limit_column_id;

    select pucif.value
      into l_percentage
      from pay_user_column_instances_f pucif
      where pucif.user_row_id = l_bracket_row
      and (l_effective_date >= pucif.effective_start_date
      and l_effective_date <= pucif.effective_end_date)
      and pucif.user_column_id = l_percentage_column_id;


    tax_liability := (l_fixed + ((p_taxable_amount - l_limit) * (l_percentage / 100))) -  p_tax_rebate;

    RETURN tax_liability;

  END calc_tax_on_table;



/* Function: arr_pen_mon_check calculates the monthly arrear pension fund abatement
             and, once a year, the arrear excess that should be taken over to the
             next year.
*/

  FUNCTION arr_pen_mon_check(
    p_tax_status  IN VARCHAR2,
    p_start_site IN VARCHAR2,
    p_site_factor IN NUMBER,
    p_pen_ind IN VARCHAR2,
    p_apf_ptd_bal IN NUMBER,
    p_apf_ytd_bal IN NUMBER,
    p_apf_exces_bal IN NUMBER,
    p_periods_left IN NUMBER,
    p_period_factor IN NUMBER,
    p_possible_periods_left IN NUMBER,
    p_max_abate IN NUMBER,
    p_exces_itd_upd OUT NOCOPY NUMBER
    ) RETURN NUMBER

  AS
    l_contribution  NUMBER;
    l_abatement  NUMBER;
    l_contr_ptd_fact  NUMBER;
    l_apf_yearly_fig  NUMBER;
    l_exces_should_be  NUMBER;

  BEGIN
  -- Assign default to p_exces_itd_upd
  --
    p_exces_itd_upd := 0;

    IF p_tax_status = 'G'
    THEN
      l_contribution := (p_apf_ptd_bal * p_site_factor);

      IF l_contribution > p_max_abate
      THEN
        l_abatement := p_max_abate;
      ELSE
        l_abatement := l_contribution;
      END IF;

    ELSE -- Tax status 'A' or 'B'

      l_apf_yearly_fig := p_apf_ytd_bal + p_apf_exces_bal; -- YTD plus EXCESS ITD

      IF p_start_site = 'N'
      THEN
        IF p_pen_ind = 'M' --Monthly Contribution
        THEN
          l_contr_ptd_fact := p_apf_ptd_bal / p_period_factor;

          l_contribution := (((p_apf_ptd_bal / p_period_factor) * p_periods_left)
                      + (l_apf_yearly_fig - l_contr_ptd_fact)) * p_possible_periods_left;

          IF l_contribution > p_max_abate
          THEN
            l_abatement := p_max_abate;
          ELSE
            l_abatement := l_contribution;
          END IF;

        ELSE -- i.e. Yearly Contribution
          IF l_apf_yearly_fig > p_max_abate
          THEN
            l_abatement := p_max_abate;
          ELSE
            l_abatement := l_apf_yearly_fig;
          END IF;

        END IF;
      ELSE -- End of year SITE calculation
        IF p_pen_ind = 'M' --Monthly Contribution
        THEN
          l_contribution := (l_apf_yearly_fig * p_site_factor);

          IF l_contribution > p_max_abate
          THEN
            l_abatement := p_max_abate;
          ELSE
            l_abatement := l_contribution;
          END IF;

        ELSE -- i.e. Yearly Contribution
          IF l_apf_yearly_fig > p_max_abate
          THEN
            l_abatement := p_max_abate;
          ELSE
            l_abatement := l_apf_yearly_fig;
          END IF;

        END IF; -- end monthly or yearly

      -- Excess calculation
      --
        l_exces_should_be := l_apf_yearly_fig - l_abatement;
        p_exces_itd_upd := l_exces_should_be - p_apf_exces_bal; -- Return the Excess update figure.

      END IF; -- end SITE or No SITE
    END IF; -- end Tax status
  RETURN l_abatement;
--
exception
   when others then
p_exces_itd_upd := null;
  END arr_pen_mon_check;

/* Function: arr_ra_mon_check calculates the monthly arrear retirement annuity abatement */

  FUNCTION arr_ra_mon_check(
    p_tax_status  In VARCHAR2,
    p_start_site  VARCHAR2,
    p_site_factor  NUMBER,
    p_ra_ind  VARCHAR2,
    p_ara_ptd_bal  NUMBER,
    p_ara_ytd_bal  NUMBER,
    p_ara_exces_bal  NUMBER,
    p_periods_left  NUMBER,
    p_period_factor  NUMBER,
    p_possible_periods_left  NUMBER,
    p_max_abate  NUMBER,
    p_exces_itd_upd OUT NOCOPY NUMBER
    ) RETURN NUMBER

  AS
    l_contribution  NUMBER;
    l_abatement  NUMBER;
    l_contr_ptd_fact  NUMBER;
    l_ara_yearly_fig  NUMBER;
    l_exces_should_be  NUMBER;

  BEGIN

  -- Assign default to p_exces_itd_upd
  --
    p_exces_itd_upd := 0;
  --
    IF p_tax_status = 'G'
    THEN
      l_contribution := (p_ara_ptd_bal * p_site_factor);

      IF l_contribution > p_max_abate
      THEN
        l_abatement := p_max_abate;
      ELSE
        l_abatement := l_contribution;
      END IF;

    ELSE  -- tax status A/B

      l_ara_yearly_fig := p_ara_ytd_bal + p_ara_exces_bal; -- YTD plus EXCESS ITD

      IF p_start_site = 'N'
      THEN
        IF p_ra_ind = 'M' --Monthly Contribution
        THEN
          l_contr_ptd_fact := p_ara_ptd_bal / p_period_factor;

          l_contribution := (((p_ara_ptd_bal / p_period_factor) * p_periods_left)
                          + (l_ara_yearly_fig - l_contr_ptd_fact)) * p_possible_periods_left;

          IF l_contribution > p_max_abate
          THEN
            l_abatement := p_max_abate;
          ELSE
            l_abatement := l_contribution;
          END IF;

        ELSE -- i.e. Yearly Contribution
          IF l_ara_yearly_fig > p_max_abate
          THEN
            l_abatement := p_max_abate;
          ELSE
            l_abatement := l_ara_yearly_fig;
          END IF;

        END IF; -- end monthly or yearly

      ELSE -- End of year SITE calculation
        IF p_ra_ind = 'M' --Monthly Contribution
        THEN
          l_contribution := (l_ara_yearly_fig * p_site_factor);

          IF l_contribution > p_max_abate
          THEN
            l_abatement := p_max_abate;
          ELSE
            l_abatement := l_contribution;
          END IF;

        ELSE -- i.e. Yearly Contribution
          IF l_ara_yearly_fig > p_max_abate
          THEN
            l_abatement := p_max_abate;
          ELSE
            l_abatement := l_ara_yearly_fig;
          END IF;

        END IF; -- end monthly or yearly

      -- Excess calculation
      --
        l_exces_should_be := l_ara_yearly_fig - l_abatement;
        p_exces_itd_upd := l_exces_should_be - p_ara_exces_bal; -- Return the Excess update figure.

      END IF; -- end SITE or No SITE
    END IF; -- Tax Status
  RETURN l_abatement;
--
exception
   when others then
   p_exces_itd_upd := null;
--
  END arr_ra_mon_check;


/* Function: za_site_paye_split to calculate the split between site and paye */
  FUNCTION site_paye_split(
    p_total_tax  IN NUMBER,
    p_tax_on_travel  IN NUMBER,
    p_tax_on_pub_off  IN NUMBER,
    p_site_lim  IN NUMBER,
    p_qual  IN VARCHAR2
    ) RETURN NUMBER
  AS
    l_temp_site  NUMBER;
    l_site  NUMBER;
    l_paye  NUMBER;
    l_value  NUMBER;

  BEGIN
    l_temp_site := p_total_tax - (p_tax_on_travel + p_tax_on_pub_off);

    IF l_temp_site <= p_site_lim
    THEN
      l_site := l_temp_site;
    ELSE
      l_site := p_site_lim;
    END IF;

    l_paye := p_total_tax - l_site;

    IF p_qual = 'S'
    THEN
      l_value := l_site;
    ELSE
      l_value := l_paye;
    END IF;

  RETURN l_value;

  END site_paye_split;

/* Function: calc_tax_on_perc to calculate tax on a percentage according to tax status */
  FUNCTION calc_tax_on_perc(
    p_amount  IN NUMBER,
    p_tax_status  IN VARCHAR2,
    p_tax_directive_value  IN NUMBER,
    p_cc_tax_perc  IN NUMBER,
    p_temp_tax_perc  IN NUMBER
    )  RETURN NUMBER

  AS
    l_tax NUMBER;

  BEGIN
    IF p_tax_status = 'D'
    THEN
      l_tax := (p_amount * p_tax_directive_value) / 100;
    ELSE
      IF p_tax_status = 'E'
      THEN
        l_tax := (p_amount * p_cc_tax_perc) / 100;
      ELSE
        IF p_tax_status = 'F'
        THEN
          l_tax := (p_amount * p_temp_tax_perc) / 100;
        ELSE
          NULL;
        END IF;
      END IF;
    END IF;

   RETURN l_tax;
  END calc_tax_on_perc;


/* Function: tax_period_factor calculates the period factor for the person,
   i.e. did the person work a full period or a half or even one and a half.
*/
  FUNCTION tax_period_factor(
    p_tax_year_start_date  IN DATE,
    p_asg_start_date  IN DATE,
    p_cur_period_start_date  IN DATE,
    p_cur_period_end_date  IN DATE,
    p_total_inc_ytd  IN NUMBER,
    p_total_inc_ptd  IN NUMBER
    )  RETURN NUMBER
  AS
    l_period_factor  NUMBER;

  BEGIN
    IF p_tax_year_start_date < p_asg_start_date
    THEN

      IF p_total_inc_ytd = p_total_inc_ptd  /* i.e. first pay for the person */
      THEN
        l_period_factor := (p_cur_period_end_date - p_asg_start_date + 1) /
                            (p_cur_period_end_date - p_cur_period_start_date + 1);
      ELSE
        l_period_factor := 1;
      END IF;

    ELSE
      l_period_factor := 1;
    END IF;
    RETURN l_period_factor;
  END tax_period_factor;



/* Function: pp_factor calculates the possible days the person could work in the year as a factor*/
  FUNCTION tax_pp_factor(
    p_tax_year_start_date  IN DATE,
    p_tax_year_end_date  IN DATE,
    p_asg_start_date  IN DATE,
    p_days_in_year  IN NUMBER
    )  RETURN NUMBER
  AS
    l_pp_factor  NUMBER;

  BEGIN
    IF p_tax_year_start_date >= p_asg_start_date
    THEN
      l_pp_factor := 1;
    ELSE
      l_pp_factor := p_days_in_year / (p_tax_year_end_date - p_asg_start_date + 1);
    END IF;
    RETURN l_pp_factor;
  END tax_pp_factor;


/* Function: annualise is used to annualise an amount */
  FUNCTION annualise(
    p_ytd_income  IN NUMBER,
    p_ptd_income  IN NUMBER,
    p_period_left  IN NUMBER,
    p_pp_factor  IN NUMBER,
    p_period_factor  IN NUMBER
    ) RETURN NUMBER
  AS
    l_annual_fig  NUMBER;
    l_ptd_fact  NUMBER;

  BEGIN
    l_ptd_fact := p_ptd_income / p_period_factor;

    IF p_period_factor < 1
    THEN
      l_annual_fig := ((l_ptd_fact * p_period_left) + (p_ytd_income - p_ptd_income)) * p_pp_factor;
    ELSE
      l_annual_fig := ((l_ptd_fact * p_period_left) + (p_ytd_income - l_ptd_fact)) * p_pp_factor;
    END IF;
  RETURN l_annual_fig;
  END annualise;


/* Function to determine if employee has been terminated */
  FUNCTION za_emp_terminated(
    p_ee_date_to IN DATE,
    p_cps_date IN DATE,
    p_cpe_date IN DATE
    ) RETURN VARCHAR2
  AS
  l_terminated VARCHAR2(5);

  BEGIN
    IF p_ee_date_to BETWEEN p_cps_date AND p_cpe_date
    THEN
      l_terminated := 'TRUE';
    ELSE
      l_terminated := 'FALSE';
    END IF;

    RETURN l_terminated;

  END za_emp_terminated;


/* Function to determine if pay period is a site period or not */
  FUNCTION za_site_period(
    p_pay_periods_left IN NUMBER,
    p_asg_date_to IN DATE,
    p_current_period_start_date IN DATE,
    p_current_period_end_date IN DATE
    ) RETURN VARCHAR2
  AS
    l_do_SITE VARCHAR2(5);
    l_ee_status VARCHAR2(5);

  BEGIN
    l_ee_status :=
    py_za_tx.za_emp_terminated(
      p_asg_date_to,
      p_current_period_start_date,
      p_current_period_end_date
      );

    IF p_pay_periods_left > 1 AND
       l_ee_status = 'FALSE'
    THEN
      l_do_SITE := 'FALSE';
    ELSE
      l_do_SITE := 'TRUE';
    END IF;

    RETURN l_do_SITE;

  END za_site_period;


/* Function to determine number of days worked in a year, including weekends and holidays*/
  FUNCTION za_days_worked(
    p_asg_date_from IN DATE,
    p_asg_date_to IN DATE,
    p_za_tax_year_from IN DATE,
    p_za_tax_year_to IN DATE
    ) RETURN NUMBER
  AS
    l_year_start_date date;
    l_year_end_date date;
    l_ee_days_worked number;

  BEGIN
    IF p_asg_date_from > p_za_tax_year_from
    THEN
      l_year_start_date := p_asg_date_from;
    ELSE
      l_year_start_date := p_za_tax_year_from;
    END IF;

    IF p_asg_date_to < p_za_tax_year_to
    THEN
      l_year_end_date := p_asg_date_to;
    ELSE
      l_year_end_date := p_za_tax_year_to;
    END IF;

    l_ee_days_worked := fnd_number.canonical_to_number((l_year_end_date + 1) - l_year_start_date);

    RETURN l_ee_days_worked;

  END za_days_worked;


/* Function ytd_days_worked calculates the number of days worked up to the present date */
  FUNCTION ytd_days_worked(
    p_tax_year_start  IN DATE,
    p_asg_date_from  IN DATE,
    p_cur_period_start  IN DATE
    ) RETURN NUMBER

  AS
    l_days_wk  NUMBER;

  BEGIN
    IF p_asg_date_from > p_tax_year_start
    THEN
      l_days_wk := p_cur_period_start - p_asg_date_from;
    ELSE
      l_days_wk := p_cur_period_start - p_tax_year_start;
    END IF;
    RETURN l_days_wk;
  END ytd_days_worked;


/* Function cal_days_worked calculates the number of days worked from 01 JAN to tax year start*/
  FUNCTION cal_days_worked(
    p_tax_year_start  IN DATE,
    p_asg_date_from  IN DATE
    ) RETURN NUMBER

  AS
    l_cal_y_start_date DATE;
    l_days_wk NUMBER;

  BEGIN
    l_cal_y_start_date := fnd_date.canonical_to_date('01-JAN-'||to_char(sysdate, 'YYYY'));

    IF p_asg_date_from > l_cal_y_start_date
    THEN
      l_days_wk := p_tax_year_start - p_asg_date_from;
    ELSE
      l_days_wk := p_tax_year_start - l_cal_y_start_date;
    END IF;
    RETURN l_days_wk;
  END cal_days_worked;


/* Function get_ytd_car_allow_val calculates the travelling allowance ytd balance */
  FUNCTION get_ytd_car_allow_val (
    assignment_id NUMBER,  -- context passed from application
    p_tax_year_start_date DATE,
    p_tax_year_end_date DATE,
    p_current_period_end_date DATE,  --end date for this payroll run
    p_global_value  VARCHAR2  -- current effective value


    ) RETURN NUMBER
  AS


    -- Declare cursor statement
    --
    CURSOR c_get_eff_date (
      p_ty_sd DATE,      -- tax year start date
      p_ty_ed DATE,      -- tax year end date
      p_cur_per_ed DATE  -- current period end date
      )
    IS
    SELECT effective_end_date,
           global_value
    FROM ff_globals_f
    WHERE effective_end_date < p_ty_ed
    AND effective_end_date > p_ty_sd
    AND effective_end_date < p_cur_per_ed
    AND global_name = 'ZA_CAR_ALLOW_TAX_PERC';

    -- Declare variables statements
    --
    ytd_bal_val  NUMBER := 0;
    l_dim_id  NUMBER := 0;
    differ_bal_val  NUMBER := 0;
    bal_tot_val  NUMBER := 0;
    taxable_bal_val  NUMBER := 0;
    taxable_bal_val_tot  NUMBER := 0;

    l_effective_end_date  DATE;
    l_global_value  NUMBER;

    l_asg_start_date  DATE;
    l_asg_end_date  DATE;

    l_min_start_date  DATE;
    l_max_end_date  DATE;

    cursor c1 (c_assignment_id NUMBER) is
    SELECT per.effective_start_date, per.effective_end_date
    FROM per_assignments_f per,
         fnd_sessions fnd
    WHERE per.assignment_id = c_assignment_id
    AND fnd.effective_date BETWEEN per.effective_start_date AND per.effective_end_date
    AND fnd.session_id = USERENV('sessionid');

  BEGIN

    OPEN c1(assignment_id);
    LOOP
    FETCH c1 INTO l_asg_start_date, l_asg_end_date;
	EXIT WHEN c1%NOTFOUND;
-- --	dbms_output.put_line('l_asg_end_date = '||to_char(l_asg_end_date)); -- GSCC Error: File.Sql.18
-- --	dbms_output.put_line('l_asg_start_date = '||to_char(l_asg_start_date)); -- GSCC Error: File.Sql.18
    END LOOP;

    l_min_start_date := GREATEST(l_asg_start_date, p_tax_year_start_date);
    l_max_end_date   := LEAST(l_asg_end_date, p_tax_year_end_date);

-- --	dbms_output.put_line('l_asg_end_date = '||to_char(l_asg_end_date)); -- GSCC Error: File.Sql.18
-- --	dbms_output.put_line('l_asg_end_date = '||to_char(l_asg_end_date)); -- GSCC Error: File.Sql.18

    pay_balance_pkg.set_context ('ASSIGNMENT_ID', to_char(assignment_id));

    l_dim_id  := pay_za_payroll_action_pkg.defined_balance_id('Travelling Allowance','_ASG_TAX_YTD');



    FOR v_date IN c_get_eff_date(
      l_min_start_date,
      l_max_end_date,
      p_current_period_end_date
      )

    LOOP

      ytd_bal_val := pay_balance_pkg.get_value(l_dim_id,assignment_id,v_date.effective_end_date);
      differ_bal_val := ytd_bal_val - bal_tot_val;

      bal_tot_val := ytd_bal_val;

      taxable_bal_val := differ_bal_val * (fnd_number.canonical_to_number(v_date.global_value) / 100);

      taxable_bal_val_tot := taxable_bal_val_tot + taxable_bal_val;

    END LOOP;

    ytd_bal_val := pay_balance_pkg.get_value(l_dim_id,assignment_id,l_max_end_date);
--    ytd_bal_val := pay_balance_pkg.get_value(l_dim_id,assignment_id,p_current_period_end_date);

    differ_bal_val := ytd_bal_val - bal_tot_val;

    taxable_bal_val := differ_bal_val * (fnd_number.canonical_to_number(p_global_value) / 100);

    taxable_bal_val_tot := taxable_bal_val_tot + taxable_bal_val;


    RETURN taxable_bal_val_tot;

  END get_ytd_car_allow_val;


/* Function get_cal_car_allow_val calculates the asg_cal_ytd value for the
   TRAVELLING_ALLOWANCE balance.*/
  FUNCTION get_cal_car_allow_val (
    assignment_id NUMBER,  -- context passed from application
    p_tax_year_start_date DATE
    ) RETURN NUMBER
  AS


    -- Declare cursor statement
    --
    CURSOR c_get_eff_date (
      p_ty_sd DATE,      -- tax year start date
      p_asg_cal_max DATE -- maximum of assignment start date and Calendar year start
      )
    IS
    SELECT effective_end_date,
           global_value
    FROM ff_globals_f
    WHERE effective_end_date > p_asg_cal_max
    AND effective_end_date < (p_ty_sd - 1)
    AND global_name = 'ZA_CAR_ALLOW_TAX_PERC';


    ytd_bal_val  NUMBER;
    l_dim_id  NUMBER;
    differ_bal_val  NUMBER;
    bal_tot_val  NUMBER;
    taxable_bal_val  NUMBER;
    taxable_bal_val_tot  NUMBER;
    l_effec_date  DATE;
    l_value_at_year_st NUMBER;

    l_asg_start_date  DATE;

    l_min_start_date  DATE;

    cursor c1 (c_assignment_id NUMBER) is
    SELECT per.effective_start_date
    FROM per_assignments_f per,
         fnd_sessions fnd
    WHERE per.assignment_id = c_assignment_id
    AND fnd.effective_date BETWEEN per.effective_start_date AND per.effective_end_date
    AND fnd.session_id = USERENV('sessionid');

    l_assignment_id number;
    l_asg_cal_max DATE;

  BEGIN

    l_assignment_id := assignment_id;

    OPEN c1(assignment_id);
    LOOP
    FETCH c1 INTO l_asg_start_date;
	EXIT WHEN c1%NOTFOUND;
    END LOOP;


    l_min_start_date := GREATEST(l_asg_start_date, p_tax_year_start_date);

    pay_balance_pkg.set_context ('ASSIGNMENT_ID', to_char(assignment_id));

    l_dim_id  := pay_za_payroll_action_pkg.defined_balance_id('Travelling Allowance','_ASG_CAL_YTD');

    -- Check that the newest of the Calendar Year Start Date and the Assignment Start Date
    -- is used to get Effective End Dates for the ZA_CAR_ALLOW_TAX_PERC global in the
    -- following loop
    --
    IF to_date('01-01-'||to_char(p_tax_year_start_date,'YYYY')||''||'','DD-MM-YYYY') > l_asg_start_date THEN
      l_asg_cal_max := to_date('01-01-'||to_char(p_tax_year_start_date,'YYYY')||''||'','DD-MM-YYYY');
    ELSE
      l_asg_cal_max := l_asg_start_date;
    END IF;

    FOR v_date IN c_get_eff_date(
      l_min_start_date,
      l_asg_cal_max
      )

    LOOP -- for every record that is returned. Total the actual taxable value

      ytd_bal_val := pay_balance_pkg.get_value(l_dim_id,assignment_id,v_date.effective_end_date);

      differ_bal_val := ytd_bal_val - bal_tot_val;

      bal_tot_val := ytd_bal_val;

      taxable_bal_val := differ_bal_val * (v_date.global_value / 100);

      taxable_bal_val_tot := taxable_bal_val_tot + taxable_bal_val;

    END LOOP;

    -- Do one last run for the exact date you want the value on
    --

    IF l_min_start_date >= p_tax_year_start_date THEN
	l_effec_date := l_min_start_date;
    ELSE
	l_effec_date := (p_tax_year_start_date - 1);
    END IF;


    SELECT global_value
    INTO l_value_at_year_st
    FROM ff_globals_f glb
    WHERE l_effec_date > glb.effective_start_date
    AND l_effec_date < glb.effective_end_date
    AND global_name = 'ZA_CAR_ALLOW_TAX_PERC';


    ytd_bal_val := pay_balance_pkg.get_value(l_dim_id,assignment_id,l_effec_date);

    differ_bal_val := ytd_bal_val - bal_tot_val;

    taxable_bal_val := differ_bal_val * (l_value_at_year_st / 100);

    taxable_bal_val_tot := taxable_bal_val_tot + taxable_bal_val;


    RETURN taxable_bal_val_tot;



  END get_cal_car_allow_val;

END py_za_tx;



/
