--------------------------------------------------------
--  DDL for Package Body PAY_NL_LSS_FUNCTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_NL_LSS_FUNCTIONS" AS
/* $Header: pynllssf.pkb 120.3 2007/04/19 09:53:44 rsahai noship $ */


--
-- ----------------------------------------------------------------------------
-- |---------------------< Get_Day_of_Week >--------------------------|
-- ----------------------------------------------------------------------------
--
FUNCTION  Get_Day_of_Week(p_date DATE) RETURN NUMBER IS
        l_reference_date date:=to_date('01/01/1984','DD/MM/YYYY');
        v_index number;
 BEGIN
        hr_utility.set_location('Inside Get_Day_of_Week Function', 1110);
        v_index:=abs(p_date - l_reference_date);
        v_index:=mod(v_index,7);
        hr_utility.set_location('v_index: '||v_index, 1120);
        RETURN v_index+1;
END Get_Day_of_Week;

-- ----------------------------------------------------------------------------
-- |-------------------------< Get_Wage_Days >-------------------------------|
-- ----------------------------------------------------------------------------
--
FUNCTION Get_Wage_Days(p_start_date DATE,
                       p_end_date DATE) RETURN NUMBER IS
    v_st_date date := p_start_date;
    v_en_date date := p_end_date;
    v_beg_of_week date;
    v_end_of_week date;
    v_days number := 0;
   BEGIN

                hr_utility.set_location('Inside Get_Wage_Days Function', 1130);
                hr_utility.set_location('p_start_date: '||p_start_date, 1140);
                hr_utility.set_location('p_end_date: '||p_end_date, 1150);

                IF p_start_date > p_end_date THEN
                      RETURN v_days;
                END IF;
               --Determine the Beginning of Week Date for Start Date
               --and End of Week Date for End Date
                v_beg_of_week := v_st_date - (get_day_of_week(v_st_date)-1);
                v_end_of_week  := v_en_date;

                hr_utility.set_location('v_beg_of_week: '||v_beg_of_week, 1160);


                IF get_day_of_week(v_en_date) NOT IN('1') THEN
                      v_end_of_week := v_en_date + (7- get_day_of_week(v_en_date)+1);
                END IF;

                hr_utility.set_location('v_end_of_week: '||v_end_of_week, 1170);

                --Calculate the Total Week Days @ of 5 per week
                v_days := ((v_end_of_week-v_beg_of_week)/7)*5;

                --Adjust the Total Week Days by subtracting
                --No of Days before the Start Date
                IF (v_st_date > (v_beg_of_week+1)) THEN
                       v_days := v_days - (v_st_date - (v_beg_of_week+1)) ;
                END IF;
                IF v_end_of_week <> v_en_date THEN
                     v_end_of_week := v_end_of_week -2;
                ELSE
                       IF v_st_date = v_en_date THEN
                             v_days := 0;
                       END IF;
                END IF;
                hr_utility.set_location('v_days: '||v_days, 1180);

                --Adjust the Total Week Days by subtracting
                --No of Days After the End Date
                IF (v_end_of_week - v_en_date) >= 0 THEN
                         v_days := v_days - (v_end_of_week - v_en_date) ;
                END IF;
                RETURN (v_days);
                hr_utility.set_location('Final v_days: '||v_days, 1190);
   END Get_Wage_Days;

-- ----------------------------------------------------------------------------
-- |--------------------------< Get_Prorate_Amount >--------------------------------|
-- ----------------------------------------------------------------------------
--
Function Get_Prorate_Amount(p_assignment_id        IN NUMBER
                           ,p_business_group       IN NUMBER
                           ,p_application_date     IN DATE
                           ,p_period_start_date    IN DATE
                           ,p_period_end_date      IN DATE
                           ,p_pay_periods_per_year IN NUMBER
                           ,p_amount               IN OUT NOCOPY NUMBER)
RETURN NUMBER IS

        l_error_flag number := 1; /* 0 means success, 1 means error */
        l_prorated_amount number := 0;
        l_proration_start_date date;
        l_proration_end_date date;
        l_assignment_start_date date;
        l_assignment_end_date date;
        l_total_wage_days_per_period number := 0;
/* Number of wage days in a pay period */
        l_prorated_wage_days_temp number:= 0;
        l_prorated_wage_days number:= 0;
/* Number of prorated wage days */
        l_count number := 0;

/* Cursor for getting start and end dates for an assignment. Returns multiple rows if the assignment is upadted
   is suspended for multiple times in the given pay_period. */
        CURSOR csr_asg_dates (p_other_assignment_id NUMBER) IS
          SELECT asg.effective_start_date asg_start_date
          ,asg.effective_end_date asg_end_date
          FROM PER_ALL_ASSIGNMENTS_F asg
               ,PER_ASSIGNMENT_STATUS_TYPES past
          WHERE asg.assignment_id = p_other_assignment_id
          AND   past.per_system_status = 'ACTIVE_ASSIGN'
          AND   asg.assignment_status_type_id = past.assignment_status_type_id
      --  AND   asg.business_group_id    =  p_business_group
          AND   asg.effective_start_date <= p_period_end_date
          AND   NVL(asg.effective_end_date,p_period_end_date) >= p_period_start_date;


/* Cursor to access Global vlaues for Wage days in a pay_period depanding on Payroll Type. */
         CURSOR csr_globals_nl_average_days IS
          SELECT global_name g_name, global_value g_val FROM FF_GLOBALS_F
          WHERE legislation_code = 'NL' AND
                global_name in ('NL_AVERAGE_DAYS_WEEKLY', 'NL_AVERAGE_DAYS_4WEEKLY', 'NL_AVERAGE_DAYS_MONTHLY',
               'NL_AVERAGE_DAYS_QUARTERLY') AND
               (EFFECTIVE_START_DATE <= p_application_date and EFFECTIVE_END_DATE >= p_application_date);

        BEGIN

           hr_utility.set_location('Inside Get_Prorate_Amount Function ' , 1200);

	/* This loop checks for Assignment Suspension of a given assignment in a given pay period.
	   l_count = 1 means no suspension.  */
                FOR csr_asg_dates_rec in csr_asg_dates(p_assignment_id) LOOP
                        l_assignment_start_date := csr_asg_dates_rec.asg_start_date;
                        l_assignment_end_date := csr_asg_dates_rec.asg_end_date;
                        l_proration_start_date := Greatest(p_period_start_date, l_assignment_start_date);
                        l_proration_end_date   := Least(p_period_end_date, l_assignment_end_date);
                        l_prorated_wage_days_temp := Get_Wage_Days(l_proration_start_date, l_proration_end_date);
                        l_prorated_wage_days := l_prorated_wage_days + l_prorated_wage_days_temp;

                        hr_utility.set_location('l_assignment_start_date: '||l_assignment_start_date, 1210);
                        hr_utility.set_location('l_assignment_end_date: '||l_assignment_end_date, 1220);
                        hr_utility.set_location('l_proration_start_date: '||l_proration_start_date, 1230);
                        hr_utility.set_location('l_proration_end_date: '||l_proration_end_date, 1240);
                        hr_utility.set_location('l_prorated_wage_days_temp: '||l_prorated_wage_days_temp , 1250);
                        hr_utility.set_location('l_prorated_wage_days: '||l_prorated_wage_days, 1260);

                        l_count := l_count+1;

                END LOOP;

                hr_utility.set_location('l_count: '||l_count, 1270);
                hr_utility.set_location('l_prorated_wage_days outside loop: '||l_prorated_wage_days, 1280);

        /* This loop fetches number of Wage Days in a pay period using Globals */
                FOR crs_rec_globals in csr_globals_nl_average_days
                LOOP
                        IF (p_pay_periods_per_year = 52 and crs_rec_globals.g_name = 'NL_AVERAGE_DAYS_WEEKLY') THEN
                            l_total_wage_days_per_period := crs_rec_globals.g_val;
                        END IF;
                        IF (p_pay_periods_per_year = 13 and crs_rec_globals.g_name = 'NL_AVERAGE_DAYS_4WEEKLY') THEN
                            l_total_wage_days_per_period := crs_rec_globals.g_val;
                        END IF;
                        IF (p_pay_periods_per_year = 12 and crs_rec_globals.g_name = 'NL_AVERAGE_DAYS_MONTHLY') THEN
                            l_total_wage_days_per_period := crs_rec_globals.g_val;
                        END IF;
                        IF (p_pay_periods_per_year = 4 and crs_rec_globals.g_name = 'NL_AVERAGE_DAYS_QUARTERLY') THEN
                            l_total_wage_days_per_period := crs_rec_globals.g_val;
                        END IF;
                 END LOOP;

                 hr_utility.set_location('l_total_wage_days_per_period: '||l_total_wage_days_per_period, 1290);

/* Checks that Prorated wage days should not cross maximum number of wage days for that pay period.
   Also checks for the pay periods in Feb month, if an assignment is active right from the beginning
    till end of the Feb pay period, then also prorate wage days may come less than the desired value,
    so it makes them equal to maximum number of wage days for that pay period */

                IF (l_prorated_wage_days > l_total_wage_days_per_period) OR (l_prorated_wage_days < l_total_wage_days_per_period AND p_period_start_date = l_proration_start_date AND p_period_end_date = l_proration_end_date AND l_count = 1)  THEN
                        l_prorated_wage_days := l_total_wage_days_per_period; /* Proration not Required */
                END IF;

                hr_utility.set_location('l_prorated_wage_days: '||l_prorated_wage_days, 1300);
                /* Total Prorated Amount */
                p_amount  := (p_amount) *
                             (l_prorated_wage_days/l_total_wage_days_per_period);
                p_amount  := round(p_amount,2);
                hr_utility.set_location('p_amount: '||p_amount, 1310);

                l_error_flag	:= 0;  /* Success Status */
                RETURN l_error_flag;
        EXCEPTION
                WHEN OTHERS THEN
                        l_error_flag := 1;  /* Reports Failure */
                        RETURN l_error_flag;

END Get_Prorate_Amount ;

-- ----------------------------------------------------------------------------
-- |---------------------------< Get_Prev_Yr_Sal >----------------------------|
-- ----------------------------------------------------------------------------
FUNCTION Get_Previous_Year_Sal (p_assignment_id        IN NUMBER,
                          p_business_group       IN NUMBER,
                          p_date_earned          IN DATE,
                          p_previous_er_column_6 IN NUMBER,
                          p_prev_year_sal        OUT NOCOPY NUMBER,
                          p_error_msg     OUT NOCOPY VARCHAR2,
                          p_opt_num_in    IN NUMBER DEFAULT 0,
                          p_opt_date_in   IN DATE DEFAULT NULL)
RETURN NUMBER
IS
l_end_date_last_yr    DATE;
l_end_date_asg        DATE;
l_end_month           VARCHAR2(20);
l_end_yr              NUMBER := 0;
l_for_last_yr         NUMBER := 0;
l_balance_amount      NUMBER := 0;
l_wage_days           NUMBER := 0;
l_bal_total_amt       NUMBER := 0;
l_min_date            DATE;
l_start_date_last_yr  DATE;
l_element_type_id     NUMBER := 0;
l_input_value_name    VARCHAR2(80);
l_asg_ytd             VARCHAR2(100) := 'Assignment Year To Date';
p_bal_total_amt       NUMBER := 0;
p_person_id           NUMBER := 0;


TYPE dim_tbl IS TABLE OF pay_defined_balances.DEFINED_BALANCE_ID%TYPE
                                    INDEX BY BINARY_INTEGER;
L_DEF_BAL_TYPE_ID      dim_tbl;
CURSOR csr_get_def_bal_type_id
(c_balance_name VARCHAR2
,c_dimension_name VARCHAR2)  IS
SELECT defined_balance_id
  FROM pay_defined_balances pdb,
       pay_balance_types pbt,
       pay_balance_dimensions pbd
 WHERE pbt.balance_name = c_balance_name
   AND pbd.legislation_code = 'NL'
   AND pbd.DIMENSION_NAME = c_dimension_name
   AND pdb.balance_type_id = pbt.balance_type_id
   AND pdb.balance_dimension_id = pbd.balance_dimension_id;

CURSOR csr_min_date (assg_id number) IS
 select min(effective_start_date) from
  per_all_assignments_f
 where assignment_id = assg_id;

--Active Assignments
--
-- Assignments that are active as of 31st of the last year.
--
CURSOR csr_active_asg(l_date IN DATE) IS
SELECT assignment_id
 FROM per_all_assignments_f
 WHERE person_id = p_person_id
 AND assignment_status_type_id IN (SELECT assignment_status_type_id
                                     FROM per_assignment_status_types
                                    WHERE per_system_status = 'ACTIVE_ASSIGN'
                                      AND active_flag = 'Y')
 AND l_date BETWEEN effective_start_date and effective_end_date
 AND payroll_id IS NOT NULL
 AND NOT EXISTS (SELECT 1 from per_all_assignments_f
                 WHERE person_id = p_person_id
                   AND assignment_status_type_id IN (SELECT assignment_status_type_id
                                                      FROM per_assignment_status_types
                                                     WHERE per_system_status = 'TERM_ASSIGN'
                                                       AND active_flag = 'Y')
                   AND l_date BETWEEN effective_start_date and effective_end_date);

--
-- Assignments that have a Last Standard Process Date
-- Greater than the termination Date
--
-- Secondary assignments and LSP date equal to the
-- termination date ( cases where the assignment is end dated as within the year
-- AND there are no assignment records after that
CURSOR csr_term_asg(l_start_date IN DATE
                    ,l_end_date IN DATE) IS
SELECT effective_start_date - 1 term_dt
      ,assignment_id
 FROM per_all_assignments_f
 WHERE person_id = p_person_id
 AND assignment_status_type_id IN (SELECT assignment_status_type_id
                                                      FROM per_assignment_status_types
                                                     WHERE per_system_status = 'TERM_ASSIGN'
                                                       AND active_flag = 'Y')
 AND effective_start_date BETWEEN l_start_date and l_end_date
 AND payroll_id IS NOT NULL
UNION
SELECT effective_end_date ,
       assignment_id
  FROM per_all_assignments_f asg
  WHERE person_id = p_person_id
  AND effective_end_date BETWEEN l_start_date and l_end_date
  AND payroll_id IS NOT NULL
  AND NOT EXISTS( SELECT 1
                     FROM per_all_assignments_f  asg1
                    WHERE person_id = p_person_id
                      AND effective_start_date = asg.effective_end_date + 1
                      AND asg.assignment_id = asg1.assignment_id );

CURSOR csr_get_person IS
 SELECT person_id
 FROM  per_all_assignments_f
 WHERE assignment_id     = p_assignment_id
 AND   business_group_id = p_business_group;

CURSOR csr_cur_yr_col6 IS
 SELECT pet.element_type_id, piv.name
 FROM pay_element_types_f pet, pay_input_values_f piv
 WHERE pet.element_name = 'Life Savings Scheme General Information'
 AND pet.element_type_id = piv.element_type_id
 AND piv.legislation_code = 'NL'
 AND upper(piv.name) = 'CURRENT YEAR COLUMN 6';

BEGIN

 hr_utility.set_location('Inside Get_Previous_Year_Sal Function ', 1320);

-- Getting Person_id for the Assignment
OPEN csr_get_person;
FETCH csr_get_person INTO p_person_id;
CLOSE csr_get_person;

OPEN csr_cur_yr_col6;
FETCH csr_cur_yr_col6 INTO l_element_type_id,l_input_value_name;
CLOSE csr_cur_yr_col6;

hr_utility.set_location('p_person_id: '||p_person_id, 1330);
hr_utility.set_location('l_element_type_id: '||l_element_type_id, 1340);
hr_utility.set_location('l_input_value_name: '||l_input_value_name, 1350);

-- Calculation for last year's dates from current year's date.
-- Get previous year by subtracting 1 from current year
-- and then get first and last date of that year */

l_for_last_yr        := to_number(to_char(p_date_earned,'YYYY')) - 1;
l_end_date_last_yr   := to_date('31-12-'||to_char(l_for_last_yr),'DD-MM-YYYY');
l_start_date_last_yr := to_date('01-01-'||to_char(l_for_last_yr),'DD-MM-YYYY');

hr_utility.set_location('l_for_last_yr: '||l_for_last_yr, 1360);
hr_utility.set_location('l_end_date_last_yr: '||l_end_date_last_yr, 1370);
hr_utility.set_location('l_start_date_last_yr: '||l_start_date_last_yr, 1380);

-- Getting Defined_Balance_Type_Id of 12 balances required to calculate
-- Remunuration Report Col6 Value

OPEN csr_get_def_bal_type_id
('Wage In Money Standard Tax SI',l_asg_ytd);
FETCH csr_get_def_bal_type_id
INTO l_def_bal_type_id(1);
CLOSE csr_get_def_bal_type_id;

OPEN csr_get_def_bal_type_id
('Wage In Money Special Tax SI',l_asg_ytd);
FETCH csr_get_def_bal_type_id
INTO l_def_bal_type_id(2);
CLOSE csr_get_def_bal_type_id;

OPEN csr_get_def_bal_type_id
('Retro Wage In Money Standard Tax SI',l_asg_ytd);
FETCH csr_get_def_bal_type_id
INTO l_def_bal_type_id(3);
CLOSE csr_get_def_bal_type_id;

OPEN csr_get_def_bal_type_id
('Retro Wage In Money Special Tax SI',l_asg_ytd);
FETCH csr_get_def_bal_type_id
INTO l_def_bal_type_id(4);
CLOSE csr_get_def_bal_type_id;

OPEN csr_get_def_bal_type_id
('Wage In Kind Standard Tax SI',l_asg_ytd);
FETCH csr_get_def_bal_type_id
INTO l_def_bal_type_id(5);
CLOSE csr_get_def_bal_type_id;

OPEN csr_get_def_bal_type_id
('Wage In Kind Special Tax SI',l_asg_ytd);
FETCH csr_get_def_bal_type_id
INTO l_def_bal_type_id(6);
CLOSE csr_get_def_bal_type_id;

OPEN csr_get_def_bal_type_id
('Retro Wage In Kind Standard Tax SI',l_asg_ytd);
FETCH csr_get_def_bal_type_id
INTO l_def_bal_type_id(7);
CLOSE csr_get_def_bal_type_id;

OPEN csr_get_def_bal_type_id
('Retro Wage In Kind Special Tax SI',l_asg_ytd);
FETCH csr_get_def_bal_type_id
INTO l_def_bal_type_id(8);
CLOSE csr_get_def_bal_type_id;

OPEN csr_get_def_bal_type_id
('Tips and Fund Payments Standard Tax SI',l_asg_ytd);
FETCH csr_get_def_bal_type_id
INTO l_def_bal_type_id(9);
CLOSE csr_get_def_bal_type_id;

OPEN csr_get_def_bal_type_id
('Tips and Fund Payments Special Tax SI',l_asg_ytd);
FETCH csr_get_def_bal_type_id
INTO l_def_bal_type_id(10);
CLOSE csr_get_def_bal_type_id;

OPEN csr_get_def_bal_type_id
('Retro Tips and Fund Payments Standard Tax SI',l_asg_ytd);
FETCH csr_get_def_bal_type_id
INTO l_def_bal_type_id(11);
CLOSE csr_get_def_bal_type_id;

OPEN csr_get_def_bal_type_id
('Retro Tips and Fund Payments Special Tax SI',l_asg_ytd);
FETCH csr_get_def_bal_type_id
INTO l_def_bal_type_id(12);
CLOSE csr_get_def_bal_type_id;

--Get the values of ASG_YTD vlaues of
--Active assignments of each balance out
--of 12 balances and sum them up for all the
--assignments of a person in last year

For def_bal_count in 1..12 LOOP
 IF l_def_bal_type_id(def_bal_count) IS NOT NULL THEN
  --Checking for Active Assignments
  FOR act_assg in csr_active_asg(l_end_date_last_yr)
  LOOP

    l_balance_amount := Pay_Balance_Pkg.Get_Value
                     (p_defined_balance_id   => l_def_bal_type_id(def_bal_count),
                      p_assignment_id  => act_assg.assignment_id,
                      p_virtual_date   => l_end_date_last_yr );
        -- Derive Annual Value
        OPEN csr_min_date(act_assg.assignment_id);
        FETCH csr_min_date into l_min_date;
        IF (l_min_date > l_start_date_last_yr) THEN
           l_wage_days := pay_nl_lss_functions.Get_Wage_Days
                          (l_min_date, l_end_date_last_yr);
       --    l_balance_amount := l_balance_amount * (261/l_wage_days);
        END IF;
        CLOSE csr_min_date;
    hr_utility.set_location('l_balance_amount: '||l_balance_amount, 1390);
    l_bal_total_amt := l_bal_total_amt + NVL(l_balance_amount,0);

  END LOOP; -- assg
 END IF;
END LOOP;  -- def_bal_count
hr_utility.set_location('l_bal_total_amt: '||l_bal_total_amt, 1400);

-- Checking for Terminated Assignments
For def_bal_count in 1..12 LOOP
 IF l_def_bal_type_id(def_bal_count) IS NOT NULL THEN
  FOR term_assg in csr_term_asg(l_start_date_last_yr,l_end_date_last_yr)
  LOOP

    l_balance_amount := Pay_Balance_Pkg.Get_Value
                     (p_defined_balance_id   => l_def_bal_type_id(def_bal_count),
                      p_assignment_id  => term_assg.assignment_id,
                      p_virtual_date   => term_assg.term_dt);
        -- Reverse Proration
        OPEN csr_min_date(term_assg.assignment_id);
        FETCH csr_min_date into l_min_date;
        IF (l_min_date > l_start_date_last_yr) THEN
           l_wage_days := pay_nl_lss_functions.Get_Wage_Days
                          (l_min_date, l_end_date_last_yr);
        --   l_balance_amount := l_balance_amount * (261/l_wage_days);
        END IF;
        CLOSE csr_min_date;
    hr_utility.set_location('l_balance_amount: '||l_balance_amount, 1410);
    l_bal_total_amt := l_bal_total_amt + NVL(l_balance_amount,0);
  END LOOP; -- assg
 END IF;
END LOOP;  -- def_bal_count

hr_utility.set_location('l_bal_total_amt before calling ABP function: '||l_bal_total_amt, 1420);
-- Final Amount

l_bal_total_amt := l_bal_total_amt +
                   pqp_pension_functions.get_abp_entry_value(p_business_group
                      ,l_end_date_last_yr
                      ,p_assignment_id
                      ,l_element_type_id
                      ,l_input_value_name);

hr_utility.set_location('l_bal_total_amt after calling ABP function: '||l_bal_total_amt, 1430);
hr_utility.set_location('p_previous_er_column_6: '||p_previous_er_column_6, 1440);

p_bal_total_amt := round((l_bal_total_amt + p_previous_er_column_6),2);

p_prev_year_sal := p_bal_total_amt;
hr_utility.set_location('p_prev_year_sal: '||p_prev_year_sal, 1450);

Return 0;

EXCEPTION
  WHEN OTHERS THEN
     p_error_msg :='SQL-ERRM :'||SQLERRM;
     RETURN 1;
End Get_Previous_Year_Sal;

-- ----------------------------------------------------------------------------
-- |--------------------------< Get_Or_Life_Savings_Basis >-------------------|
-- ----------------------------------------------------------------------------
Function Get_Or_Life_Savings_Basis
   (p_assignment_id   IN NUMBER,
    p_business_group  IN NUMBER,
    p_date_earned     IN DATE,
    p_override_basis OUT NOCOPY NUMBER,
    p_error_message  OUT NOCOPY VARCHAR)
RETURN NUMBER IS

l_element_type_id NUMBER;

CURSOR c_ele_cur IS
SELECT element_type_id
  FROM pay_element_types_f
 WHERE element_name = 'Life Savings Scheme General Information'
   AND legislation_code = 'NL'
   AND p_date_earned BETWEEN effective_start_date AND
                             effective_end_date;
BEGIN

hr_utility.set_location('Inside Get_Or_Life_Savings_Basis function ', 1460);

-- Funtion to derive the override savings basis
-- for Life Savings. This is applicable only
-- to the basis calculation method Pre Defined Balances
-- The value can be overridden via the general information
-- element only on the 1st of Jan of each year
-- or the hire date.

--
-- Derive the element_type_id for the life savings gen info
-- element
--
OPEN c_ele_cur;
FETCH c_ele_cur INTO l_element_type_id;
IF c_ele_cur%NOTFOUND THEN
   CLOSE c_ele_cur;
   RETURN -1;
ELSE
   CLOSE c_ele_cur;
END IF;

hr_utility.set_location('l_element_type_id: '||l_element_type_id, 1470);
--
-- Derive the value of the input as of 1 Jan or the hire date
--
p_override_basis := pqp_pension_functions.get_abp_entry_value
     (p_business_group_id   => p_business_group
     ,p_date_earned         => p_date_earned
     ,p_assignment_id       => p_assignment_id
     ,p_element_type_id     => l_element_type_id
     ,p_input_value_name    => 'Override Annual Savings Basis');

hr_utility.set_location('p_override_basis: '||p_override_basis, 1480);

IF p_override_basis > 0 THEN
   -- Indicator that the override has been done and that
   -- the overriden value is > 0
   p_error_message := 'Annual Live Savings Basis Overridden';
   RETURN 0;
ELSE
   -- Indicator that the override has not been done
   RETURN -1;
END IF;

END Get_Or_Life_Savings_Basis;

-- ----------------------------------------------------------------------------
-- |--------------------------< Get_LCLD_Limit >-------------------|
-- ----------------------------------------------------------------------------

FUNCTION Get_LCLD_Limit ( p_date_earned IN DATE,
                          p_assignment_id IN NUMBER,
                          p_num_saved_yrs IN Number,
                          p_lcld_limit IN OUT NOCOPY NUMBER,
                          p_error_msg IN OUT NOCOPY VARCHAR2)
RETURN NUMBER IS

  l_current_year number := fnd_number.canonical_to_number(to_char(p_date_earned,'YYYY'));
  l_num_saved_yrs number := p_num_saved_yrs;
  l_lcld_limit number := 0;
  l_gbl_value number := 0;
  l_gbl_value_temp ff_globals_f.GLOBAL_VALUE%TYPE;
  l_balance_amount NUMBER := 0;
  l_lss_ytd number := 0;
  l_date date;
  l_per_ytd VARCHAR2(100) := 'Person Year to Date';
  l_def_bal_type_id pay_defined_balances.DEFINED_BALANCE_ID%TYPE;
  l_assignment_exists number := 0; --0 means it doesnot exist, 1 means it exists
  l_assignment_id_temp number;

  Cursor c_asg_exists_year(p_year NUMBER, p_assg_id NUMBER) IS
   select unique(assignment_id) from per_all_assignments_f paaf, PER_ASSIGNMENT_STATUS_TYPES past
   where paaf.assignment_id = p_assg_id
   AND past.per_system_status = 'ACTIVE_ASSIGN'
   AND paaf.assignment_status_type_id = past.assignment_status_type_id
   and (to_char(effective_start_date,'YYYY') = p_year
        OR to_char(effective_end_date,'YYYY') = p_year);


  Cursor c_gbl_value(p_year number) is
   select GLOBAL_VALUE from ff_globals_f
   where global_name = 'PAY_NL_MAX_LCLD_PER_YEAR'
   and legislation_code = 'NL'
   and p_year between fnd_number.canonical_to_number(to_char(EFFECTIVE_START_DATE,'YYYY'))
   and fnd_number.canonical_to_number(to_char(EFFECTIVE_END_DATE,'YYYY'));

   CURSOR csr_get_def_bal_type_id
   (c_balance_name VARCHAR2
    ,c_dimension_name VARCHAR2)  IS
   SELECT defined_balance_id
    FROM pay_defined_balances pdb,
         pay_balance_types pbt,
         pay_balance_dimensions pbd
    WHERE pbt.balance_name = c_balance_name
    AND pbd.legislation_code = 'NL'
    AND pbd.DIMENSION_NAME = c_dimension_name
    AND pdb.balance_type_id = pbt.balance_type_id
    AND pdb.balance_dimension_id = pbd.balance_dimension_id;

begin

    --hr_utility.trace_on(NULL,'NJ');
    hr_utility.set_location('Inside LCLD Function', 100);
    hr_utility.set_location('p_date_earned: '||p_date_earned, 200);
    hr_utility.set_location('p_assignment_id: '||p_assignment_id, 300);
    hr_utility.set_location('p_num_saved_yrs: '||p_num_saved_yrs, 400);
    hr_utility.set_location('p_lcld_limit: '||p_lcld_limit, 500);
    hr_utility.set_location('l_current_year: '||l_current_year, 900);

    -- Fetch the value of global in the present year and
    -- multiply it with number of years saved.
    open c_gbl_value(l_current_year);
    fetch c_gbl_value into l_gbl_value_temp;
    close c_gbl_value;

    hr_utility.set_location('l_gbl_value_temp: '||l_gbl_value_temp, 1200);

    l_gbl_value := fnd_number.canonical_to_number(l_gbl_value_temp);

    hr_utility.set_location('l_gbl_value: '||l_gbl_value, 800);

    l_lcld_limit := p_num_saved_yrs * l_gbl_value;

    -- Round off the value to 2 decimal places.
    p_lcld_limit := round(l_lcld_limit,2);

    hr_utility.set_location('p_lcld_limit: '||p_lcld_limit, 1100);
    return 0; /* 0 means success, and l_lcld_limit has to be an out variable.*/

    hr_utility.trace_off();

Exception
  WHEN OTHERS THEN
    p_error_msg :='SQL-ERRM :'||SQLERRM;
    RETURN -1;

end Get_LCLD_Limit;

END pay_nl_lss_functions;

/
