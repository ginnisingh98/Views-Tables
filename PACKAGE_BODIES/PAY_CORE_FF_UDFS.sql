--------------------------------------------------------
--  DDL for Package Body PAY_CORE_FF_UDFS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CORE_FF_UDFS" as
/* $Header: paycoreffudfs.pkb 120.7.12010000.13 2010/03/17 19:29:35 tclewis ship $ */
/*
+======================================================================+
|                Copyright (c) 1994 Oracle Corporation                 |
|                   Redwood Shores, California, USA                    |
|                        All rights reserved.                          |
+======================================================================+

    Name        : pay_core_ff_udfs
    Filename	: paycoreffudfs.sql
    Change List
    ---------------	-----------
    01-May-2005 sodhingr        115.0           Defines user defined function
                                                used by international payroll
    14-JUN-2005  sodhingr       115.1           Added the function get_hourly_rate,
                                                that returns the hourly rate based on
                                                Salary Basis. also added the function
                                                calculate_actual_hours_worked that
                                                calculates the hours worked based on
                                                ATG/workschedule/Std hrs
    07-OCT-2005 sodhingr        115.2           Changed the function calculate_Actual_hours_worked
                                                to use the CORE HR API to calculate work_schedule
                                                and changed the procedure convert_period_type
                                                to use the lookup_code instead of meaning to avoid
                                                translation issue.
   07-FEB-2005  sodhingr        115.3           added convert_period_type and calculate_period_earnings
                                                that can be used by the localization team and take care
                                                of proration if core proration is not enabled.

  30-MAR-2005  sodhingr         115.4           change variable v_hrs_per_range
                                                to v_hours_in_range in convert_period_type
                                                Also, changed to exclude the exception
                                                This is for bug 5127891, 5102813
 20-JUN-2006  sodhingr          115.5 5161241   changed get_hourly_rate to get
                                                the salary as of the termination
                                                date if the salary is null.

 21-AUG-2007  sodhingr         115.6  6163428   Changed the procedure, Conver_Period_Type to uncomment
                                                the code to check the payroll calculation rule defined at the payroll level.
                                                Also, moved the variable name l_normal_hours to global variable as this
                                                will be used by the uncommented code to get the standard hours.
 08-Jan-2008  sudedas          115.7  6718164   Added new Function term_skip_rule_rwage
 21-Jan-2008  sudedas          115.8            Corrected Logic for Term Rule LSPD
                                                Used Cursor csr_lspprocd_min_dtearned.
 22-May-2008  sudedas          115.9  6163428   Changed Convert_Period_Type to Create an
                                                Exception for Regular Salary that Always uses
                                                Annualized Method irrespective of Payroll
                                                Calculation Method. Created Function
                                                get_wrk_sch_std_hrs to Calculate Standard
                                                Hours per Week From Work Schedule.
 25-Aug-2008  sudedas          115.10 5895804   Added Functions hours_between, calc_reduced_reg
                                      3556204   calc_vacation_pay, calc_sick_pay
                                   ER 3855241
 17-Oct-2008  sudedas          115.12  7458563  Added the provision to enter Extra Element Information
 12-Dec-2008  sudedas          115.13  7602381  Corrected logic introduced for Bug 7458563
 15-Apr-2009  sudedas          115.14  8414024  Modified dynamic function call and logic for
                                                calculate_actual_hours_worked and hours_between.
 02-May-2009  sudedas          115.16  8475124  Changed functions calc_sick_pay abd calc_vacation_pay
 22-Jun-2009  sudedas          115.17           Added function get_asg_status_typ.
 06-Jul-2009  sudedas          115.18  8637053  Added context element_type_id to function
                                                get_num_period_curr_year.
 15-MAR-2010  tclewis          115.19  9386700  Removed code checking for Active
                                                Assignment in
convert_period_type
                                                as if the payroll type is
                                                process we should process the
                                                payroll.
 17-MAR-2010 tclewis           115.20 9386700   Continue of this bug if the
                                                proration upgrade has been
                                                performed We will not check
                                                assignment status.  the function
                                                get_asg_status_typ will always
                                                return 'Y'.  I have searched the
                                                code tree and believe this code
                                                is only used in fast formulas.

Contexxt
=========

BUSINESS_GROUP_ID
ASSIGNMENT_ID
PAYROLL_ID
ELEMENT_ENTRY_ID
DATE_EARNED
ASSIGNMENT_ACTION_ID

parameters
===========
p_period_start_date
p_period_end_date
p_schedule_category
p_include_exceptions
p_busy_tentative_as
p_legislation_code
p_schedule_source
p_schedule
p_return_status
p_return_message
*/


-- **********************************************************************

--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := ' pay_core_ff_udfs.';  -- Global package name
g_legislation_code      VARCHAR2(10);
l_normal_hours             NUMBER := 0;


-- Intrduced for Bug# 6163428
-- Introducing NEW Function for Calculating Standard Hours From Work Schedule
-- Assuming Work Schedule Always defines Number of Standard Hours
-- in Each Week Day i.e. User Table Structure has Rows Days of the Week

FUNCTION get_wrk_sch_std_hrs(p_assignment_action_id  IN number
                            ,p_assignment_id         IN number
                            ,p_bg_id	             IN NUMBER
                            ,p_element_entry_id      IN number
                            ,p_date_earned           IN DATE
                            ,p_period_start	     IN DATE
 	                    ,p_period_end            IN DATE)
RETURN NUMBER IS

  CURSOR get_id_flex_num IS
    SELECT rule_mode
      FROM pay_legislation_rules
     WHERE legislation_code = 'US'
       and rule_type = 'S';

  Cursor get_ws_name (p_id_flex_num number,
                      p_date_earned date,
                      p_assignment_id number) IS
    SELECT target.SEGMENT4
      FROM /* route for SCL keyflex - assignment level */
           hr_soft_coding_keyflex target,
           per_all_assignments_f  ASSIGN
     WHERE p_date_earned BETWEEN ASSIGN.effective_start_date
                             AND ASSIGN.effective_end_date
       AND ASSIGN.assignment_id           = p_assignment_id
       AND target.soft_coding_keyflex_id  = ASSIGN.soft_coding_keyflex_id
       AND target.enabled_flag            = 'Y'
       AND target.id_flex_num             = p_id_flex_num;

   CURSOR get_user_table(p_business_grp_id NUMBER) IS
    select put.user_table_id
          ,put.user_table_name
      from hr_organization_information hoi
          ,pay_user_tables put
     where  hoi.organization_id = p_bg_id
        and hoi.org_information_context ='Work Schedule'
        and hoi.org_information1 = put.user_table_id ;

   CURSOR get_user_cols(p_user_table_id NUMBER
                       ,p_user_col_id   NUMBER
                       ,p_bg_id         NUMBER) IS
       select PUC.user_column_id
             ,PUC.user_column_name
        from  pay_user_tables PUT,
              pay_user_columns PUC
        where PUC.USER_COLUMN_ID = p_user_col_id
          and NVL(PUC.business_group_id, p_bg_id) = p_bg_id
          and NVL(PUC.legislation_code,'US') = 'US'
          and PUC.user_table_id = PUT.user_table_id
          and PUT.user_table_id = p_user_table_id;

   CURSOR get_user_rows(p_user_table_id NUMBER
                       ,p_date_earned   DATE) IS
        select user_row_id
          from pay_user_rows_f
         where user_table_id = p_user_table_id
           and p_date_earned between effective_start_date and effective_end_date ;

   CURSOR get_user_col_values(p_user_row_id  NUMBER
                             ,p_user_col_id  NUMBER
                             ,p_bg_id        NUMBER
                             ,p_date_earned  DATE)  IS
      select value
        from pay_user_column_instances_f
       where user_row_id = p_user_row_id
         and user_column_id = p_user_col_id
         and NVL(business_group_id, p_bg_id) = p_bg_id
         and NVL(legislation_code, 'US') = 'US'
         and p_date_earned between effective_start_date and effective_end_date;

  -- Local Variables
  ln_id_flex_num      NUMBER;
  ln_user_col_id      NUMBER;
  ln_user_table_id    NUMBER;
  lv_user_table_name  VARCHAR2(100);
  lv_user_col_name    VARCHAR2(100);
  ln_std_hrs_wrksch   NUMBER;
  ln_user_row_id      NUMBER;
  ln_value            VARCHAR2(100);

BEGIN
    hr_utility.trace('Entering into get_wrk_sch_std_hrs');
    hr_utility.trace('Parameters Passed..');
    hr_utility.trace('p_assignment_action_id := ' || p_assignment_action_id);
    hr_utility.trace('p_assignment_id := ' || p_assignment_id);
    hr_utility.trace('p_bg_id := ' || p_bg_id);
    hr_utility.trace('p_element_entry_id := ' || p_element_entry_id);
    hr_utility.trace('p_date_earned := ' || TO_CHAR(p_date_earned));
    hr_utility.trace('p_period_start := ' || TO_CHAR(p_period_start));
    hr_utility.trace('p_period_end := ' || TO_CHAR(p_period_end));

    OPEN get_id_flex_num;
    FETCH get_id_flex_num INTO ln_id_flex_num;
    CLOSE get_id_flex_num;

    hr_utility.trace('ln_id_flex_num := ' || ln_id_flex_num);

    OPEN get_ws_name(p_id_flex_num => ln_id_flex_num
                    ,p_date_earned => p_date_earned
                    ,p_assignment_id => p_assignment_id);
    FETCH get_ws_name INTO ln_user_col_id;
    CLOSE get_ws_name;

    hr_utility.trace('ln_user_col_id := ' || ln_user_col_id);

    OPEN get_user_table(p_business_grp_id => p_bg_id);
    FETCH get_user_table INTO ln_user_table_id
                             ,lv_user_table_name;
    CLOSE get_user_table;

    hr_utility.trace('ln_user_table_id := ' || ln_user_table_id);
    hr_utility.trace('lv_user_table_name := ' || lv_user_table_name);

    OPEN get_user_cols(p_user_table_id => ln_user_table_id
                      ,p_user_col_id => ln_user_col_id
                      ,p_bg_id => p_bg_id);
    FETCH get_user_cols INTO ln_user_col_id
                            ,lv_user_col_name;
    CLOSE get_user_cols;

    hr_utility.trace('ln_user_col_id := ' || ln_user_col_id);
    hr_utility.trace('lv_user_col_name := ' || lv_user_col_name);

    ln_std_hrs_wrksch := 0;
    hr_utility.trace('ln_std_hrs_wrksch := ' || ln_std_hrs_wrksch);
    OPEN get_user_rows(p_user_table_id => ln_user_table_id
                      ,p_date_earned => p_date_earned);
    LOOP
        FETCH get_user_rows INTO ln_user_row_id;

        hr_utility.trace('ln_user_row_id := ' || ln_user_row_id);

        EXIT WHEN get_user_rows%NOTFOUND;
        OPEN get_user_col_values(p_user_row_id => ln_user_row_id
                                ,p_user_col_id => ln_user_col_id
                                ,p_bg_id => p_bg_id
                                ,p_date_earned => p_date_earned);
        FETCH get_user_col_values INTO ln_value;
        ln_std_hrs_wrksch := ln_std_hrs_wrksch + fnd_number.canonical_to_number(ln_value);
        CLOSE get_user_col_values;

     END LOOP;
     CLOSE get_user_rows;
     hr_utility.trace('Returning ln_std_hrs_wrksch := ' || ln_std_hrs_wrksch);
     RETURN ln_std_hrs_wrksch;

END get_wrk_sch_std_hrs;

-- End of NEW Function for Calculating Standard Hours From Work Schedule

--- Functions
FUNCTION get_legislation_code(p_business_group_id NUMBER)
RETURN VARCHAR2 IS
    CURSOR c_get_legislation_code(p_business_group_id VARCHAR2) IS
       select legislation_code
       from per_business_groups_perf
       where business_group_id = p_business_group_id;

BEGIN
       OPEN c_get_legislation_code(p_business_group_id);
       FETCH c_get_legislation_code INTO g_legislation_code;
       CLOSE c_get_legislation_code;
       return g_legislation_code;
END;

FUNCTION Convert_Period_Type(
    	 p_bg		            in NUMBER -- context
        ,p_assignment_id        in NUMBER -- context
    	,p_payroll_id		    in NUMBER -- context
        ,p_element_entry_id     in NUMBER -- context
        ,p_date_earned          in DATE -- context
        ,p_assignment_action_id in NUMBER -- context
        ,p_period_start_date    IN DATE
        ,p_period_end_date      IN DATE
        /*,p_schedule_category    IN varchar2  --Optional
        ,p_include_exceptions   IN varchar2  --Optional
        ,p_busy_tentative_as    IN varchar2   --Optional
        ,p_schedule_source      IN varchar2
        ,p_schedule             IN varchar2*/
    	,p_figure	            in NUMBER
    	,p_from_freq		    in VARCHAR2
    	,p_to_freq		        in VARCHAR2
        ,p_asst_std_freq		in VARCHAR2
        ,p_rate_calc_override    in VARCHAR2)
RETURN NUMBER IS

-- local vars
v_calc_type                  VARCHAR2(50);
v_from_stnd_factor           NUMBER(30,7);
v_stnd_start_date            DATE;

v_converted_figure           NUMBER(27,7);
v_from_annualizing_factor    NUMBER(30,7);
v_to_annualizing_factor	     NUMBER(30,7);
v_return_status              NUMBER;
v_return_message             VARCHAR2(500);
v_from_freq                VARCHAR2(200);
v_to_freq                  VARCHAR2(200);
v_rate_calc_override       VARCHAR2(200);
v_schedule_source          varchar2(100);
v_schedule                 varchar2(200);
ln_regsal_ele_entry_id     number;
lv_frequency               varchar2(100);
lv_ele_xtra_info           PAY_ELEMENT_TYPE_EXTRA_INFO.eei_information10%TYPE;
ln_bg_id                   pay_element_types_f.business_group_id%TYPE;
lv_leg_code                pay_element_types_f.legislation_code%TYPE;
lv_class_name              pay_element_classifications.classification_name%TYPE;
lb_regular_salary          boolean;


   CURSOR get_RegSal_ele_entry_id(cp_leg_code IN VARCHAR2
                                ,cp_assignment_id IN NUMBER) IS
   SELECT peef.element_entry_id
    FROM pay_element_entries_f peef
        ,pay_element_types_f pet
   where peef.element_type_id = pet.element_type_id
     and peef.assignment_id = cp_assignment_id
     and pet.element_name = 'Regular Salary'
     and pet.legislation_code = cp_leg_code
     and pet.business_group_id IS NULL;

   -- Added for Bug# 7458563

   CURSOR get_earning_xtra_ele_info(cp_element_entry_id IN NUMBER
                                   ,cp_assignment_id IN NUMBER
                                   ,cp_bg_id IN NUMBER) IS
   SELECT petei.eei_information10
    FROM pay_element_entries_f peef
        ,pay_element_types_f pet
        ,pay_element_type_extra_info petei
   where peef.element_entry_id = cp_element_entry_id
     and peef.assignment_id = cp_assignment_id
     and peef.element_type_id = pet.element_type_id
     and pet.business_group_id = cp_bg_id
     and pet.legislation_code IS NULL
     and pet.element_type_id = petei.element_type_id
     and petei.information_type = 'US_EARNINGS'
     and petei.eei_information_category = 'US_EARNINGS';

    -- Added for Bug# 7602381

    CURSOR get_earnings_dtls(cp_element_entry_id IN NUMBER
                            ,cp_assignment_id IN NUMBER
                            ,cp_leg_code IN VARCHAR2) IS
    SELECT pet.business_group_id
          ,pet.legislation_code
          ,pec.classification_name
      FROM pay_element_entries_f peef
          ,pay_element_types_f pet
          ,pay_element_classifications pec
   WHERE peef.element_entry_id = cp_element_entry_id
     and peef.assignment_id = cp_assignment_id
     and peef.element_type_id = pet.element_type_id
     and peef.effective_start_date >= pet.effective_start_date
     and peef.effective_end_date <= pet.effective_end_date
     and pet.classification_id = pec.classification_id
     and pec.legislation_code = cp_leg_code
     and pec.business_group_id IS NULL;

    CURSOR get_asg_hours_freq(cp_date_earned date,
                              cp_assignment_id number) IS
        SELECT hr_general.decode_lookup('FREQUENCY', ASSIGN.frequency)
              ,ASSIGN.normal_hours
        FROM  per_all_assignments_f         ASSIGN
        where cp_date_earned
            BETWEEN ASSIGN.effective_start_date
        AND ASSIGN.effective_end_date
        and ASSIGN.assignment_id = cp_assignment_id
        and UPPER(ASSIGN.frequency) = 'W';



-- local fun

FUNCTION Get_Annualizing_Factor
                ( p_bg            IN number  	    -- context
                 ,p_assignment_id IN number         -- context
                 ,p_payroll_id       IN number  		-- context
                 ,p_element_entry_id IN number      -- context
                 ,p_date_earned    IN date          -- context
                 ,p_assignment_action_id IN number  -- context
                 ,p_period_start_date   IN DATE
                 ,p_period_end_date     IN DATE
                 ,p_freq               IN varchar2)


RETURN NUMBER IS

       CURSOR c_get_lookupcode_freq IS
             SELECT  lookup_code
            FROM    hr_lookups lkp
            WHERE   lkp.application_id = 800
            AND     lkp.lookup_type    = 'PAY_BASIS'
            AND     lkp.lookup_code    = p_freq;

       CURSOR c_get_lookupmeaning_freq IS
             SELECT  lookup_code
            FROM    hr_lookups lkp
            WHERE   lkp.application_id = 800
            AND     lkp.lookup_type    = 'PAY_BASIS'
            AND     lkp.meaning = p_freq;

       -- local constants

       c_weeks_per_year       NUMBER(3);
       c_days_per_year        NUMBER(3);
       c_months_per_year      NUMBER(3);

      -- local vars

       v_annualizing_factor       NUMBER(30,7);
       v_periods_per_fiscal_yr    NUMBER(5);
       v_hrs_per_wk               NUMBER(15,7);
       v_hrs_per_range            NUMBER(15,7);
       v_days_per_range           NUMBER(15,7);
       v_use_pay_basis            NUMBER(1);
       v_pay_basis                VARCHAR2(80);
       v_range_start              DATE;
       v_range_end                DATE;
       v_work_sched_name          VARCHAR2(80);
       v_ws_id                    NUMBER(9);
       v_period_hours             BOOLEAN;

       lv_period_type             varchar2(150);

     BEGIN -- Get_Annualizing_Factor

       /* Init */

       c_weeks_per_year   := 52;
       c_days_per_year    := 200;
       c_months_per_year  := 12;
       v_use_pay_basis    := 0;

       --
       -- Check for use of salary admin (ie. pay basis) as frequency.
       -- Selecting "count" because we want to continue processing even if
       -- the from_freq is not a pay basis.
       --

        hr_utility.trace('  Entered  Get_Annualizing_Factor ');

        BEGIN        -- Is Freq pay basis?

          --
          -- Decode pay basis and set v_annualizing_factor accordingly.
          -- PAY_BASIS "Meaning" is passed from FF !
          --

          hr_utility.trace('  Getting lookup code for lookup_type = PAY_BASIS');
          hr_utility.trace('  p_freq = '||p_freq);


       IF p_freq IS NULL THEN
             v_use_pay_basis := 0;
       ELSE
          v_use_pay_basis := 1;

          OPEN c_get_lookupcode_freq;
          FETCH c_get_lookupcode_freq INTO v_pay_basis;
          CLOSE c_get_lookupcode_freq;

          IF v_pay_basis IS NULL THEN
             OPEN c_get_lookupmeaning_freq;
             FETCH c_get_lookupmeaning_freq INTO v_pay_basis;
             CLOSE c_get_lookupmeaning_freq;
          END IF;

          --v_pay_basis := p_freq;

          hr_utility.trace('  Lookup_code ie v_pay_basis ='||v_pay_basis);

          IF v_pay_basis = 'MONTHLY' THEN

             hr_utility.trace('  Entered for MONTHLY v_pay_basis');

             v_annualizing_factor := 12;

             hr_utility.trace(' v_annualizing_factor = 12 ');

          ELSIF v_pay_basis = 'HOURLY' THEN

             hr_utility.trace('  Entered for HOURLY v_pay_basis');

             IF p_period_start_date IS NOT NULL THEN

                hr_utility.trace('  p_period_start_date IS NOT NULL ' ||
                                 '  v_period_hours=T');

                v_range_start      := p_period_start_date;
                v_range_end        := p_period_end_date;
                v_period_hours     := TRUE;

             ELSE

                hr_utility.trace('  p_period_start_date IS NULL');

                v_range_start      := sysdate;
                v_range_end        := sysdate + 6;
                v_period_hours     := FALSE;

             END IF;

                /* Use new function to calculate hours */
               v_hrs_per_range := calculate_actual_hours_worked
                                 ( p_assignment_action_id
                                  ,p_assignment_id
                                  ,p_bg
                                  ,p_element_entry_id
                                  ,p_date_earned
                                  ,p_period_start_date
                                  ,p_period_end_date
                                  ,NULL
                                  ,'N'
                                  ,'BUSY'
                                  ,''--p_legislation_code
                                  ,v_schedule_source
                                  ,v_schedule
                                  ,v_return_status
                                  ,v_return_message);

             IF v_period_hours THEN

                hr_utility.trace('  v_period_hours is TRUE');

                SELECT TPT.number_per_fiscal_year
                INTO   v_periods_per_fiscal_yr
                FROM   pay_payrolls_f  PPF,
                       per_time_period_types TPT,
                       fnd_sessions fs
                WHERE  PPF.payroll_id = p_payroll_id
                AND    fs.session_id  = USERENV('SESSIONID')
                AND    fs.effective_date between PPF.effective_start_date
                                             and PPF.effective_end_date
                AND    TPT.period_type = PPF.period_type;

                v_annualizing_factor :=
                           v_hrs_per_range * v_periods_per_fiscal_yr;

             ELSE

                v_annualizing_factor := v_hrs_per_range * c_weeks_per_year;

             END IF;

         ELSIF v_pay_basis = 'PERIOD' THEN

            hr_utility.trace('  v_pay_basis = PERIOD');

            SELECT  TPT.number_per_fiscal_year
            INTO    v_annualizing_factor
            FROM    pay_payrolls_f          PRL,
                    per_time_period_types   TPT,
                    fnd_sessions            fs
            WHERE   TPT.period_type             = PRL.period_type
            and     fs.session_id               = USERENV('SESSIONID')
            and     fs.effective_date  BETWEEN PRL.effective_start_date
                                           AND PRL.effective_end_date
            AND     PRL.payroll_id              = p_payroll_id
            AND     PRL.business_group_id + 0   = p_bg;


         ELSIF v_pay_basis = 'ANNUAL' THEN


            hr_utility.trace('  v_pay_basis = ANNUAL');

            v_annualizing_factor := 1;

         ELSE

            -- Did not recognize "pay basis", return -999 as annualizing factor.
            -- Remember this for debugging when zeroes come out as results!!!

            hr_utility.trace('  Did not recognize pay basis');

            v_annualizing_factor := 0;

            RETURN v_annualizing_factor;

         END IF;
       END IF;

       EXCEPTION

         WHEN NO_DATA_FOUND THEN

           hr_utility.trace('  When no data found' );
           v_use_pay_basis := 0;

       END; /* SELECT LOOKUP CODE */


        IF v_use_pay_basis = 0 THEN

           hr_utility.trace('  Not using pay basis as frequency');

           -- Not using pay basis as frequency...

           IF (p_freq IS NULL)                  OR
              (UPPER(p_freq) = 'PERIOD')        OR
              (UPPER(p_freq) = 'NOT ENTERED')
           THEN

              -- Get "annuallizing factor" from period type of the payroll.

              hr_utility.trace('Get annuallizing factor from period '||
                               'type of the payroll');

               SELECT  TPT.number_per_fiscal_year
               INTO    v_annualizing_factor
               FROM    pay_payrolls_f          PRL,
                       per_time_period_types   TPT,
                       fnd_sessions            fs
               WHERE   TPT.period_type         = PRL.period_type
               AND     fs.session_id = USERENV('SESSIONID')
               AND     fs.effective_date  BETWEEN PRL.effective_start_date
                                              AND PRL.effective_end_date
               AND     PRL.payroll_id          = p_payroll_id
               AND     PRL.business_group_id + 0   = p_bg;

               hr_utility.trace('v_annualizing_factor ='||
                                to_number(v_annualizing_factor));


           ELSIF UPPER(p_freq) = 'HOURLY' THEN  -- Hourly employee...

               hr_utility.trace('  Hourly Employee');

               IF p_period_start_date IS NOT NULL THEN
                  v_range_start      := p_period_start_date;
                  v_range_end        := p_period_end_date;
                  v_period_hours     := TRUE;
               ELSE
                  v_range_start      := sysdate;
                  v_range_end        := sysdate + 6;
                  v_period_hours     := FALSE;
               END IF;

                /* Use new function to calculate hours */
               v_hrs_per_range := calculate_actual_hours_worked
                                 ( p_assignment_action_id
                                  ,p_assignment_id
                                  ,p_bg
                                  ,p_element_entry_id
                                  ,p_date_earned
                                  ,p_period_start_date
                                  ,p_period_end_date
                                  ,NULL
                                  ,'N'
                                  ,'BUSY'
                                  ,''--p_legislation_code
                                  ,v_schedule_source
                                  ,v_schedule
                                  ,v_return_status
                                  ,v_return_message);

                  hr_utility.trace('v_hrs_per_range ='||v_hrs_per_range);
               IF v_period_hours THEN

                  hr_utility.trace('v_period_hours = TRUE');

                  SELECT TPT.number_per_fiscal_year
                  INTO   v_periods_per_fiscal_yr
                  FROM   pay_payrolls_f        ppf,
                         per_time_period_types tpt,
                         fnd_sessions          fs
                  WHERE  ppf.payroll_id    = p_payroll_id
                  AND    fs.session_id     = USERENV('SESSIONID')
                  AND    fs.effective_date BETWEEN ppf.effective_start_date
                                           AND ppf.effective_end_date
                  AND    tpt.period_type = ppf.period_type;

                  v_annualizing_factor :=
                                v_hrs_per_range * v_periods_per_fiscal_yr;

                  hr_utility.trace('v_hrs_per_range ='||
                                          to_number(v_hrs_per_range));
                  hr_utility.trace('v_periods_per_fiscal_yr ='||
                                          to_number(v_periods_per_fiscal_yr));
                  hr_utility.trace('v_annualizing_factor ='||
                                          to_number(v_annualizing_factor));

               ELSE

                  hr_utility.trace('v_period_hours = FALSE');

                  v_annualizing_factor := v_hrs_per_range * c_weeks_per_year;

                  hr_utility.trace('v_hrs_per_range ='||
                                          to_number(v_hrs_per_range));
                  hr_utility.trace('c_weeks_per_year ='||
                                          to_number(c_weeks_per_year));
                  hr_utility.trace('v_annualizing_factor ='||
                                          to_number(v_annualizing_factor));

               END IF;

           ELSE

                -- Not hourly, an actual time period type!

                hr_utility.trace('Not hourly - an actual time period type');

                BEGIN

                  hr_utility.trace(' selecting from per_time_period_types');

                  SELECT PT.number_per_fiscal_year
                  INTO   v_annualizing_factor
                  FROM   per_time_period_types PT
                  WHERE  UPPER(PT.period_type) = UPPER(p_freq);

                  hr_utility.trace('v_annualizing_factor ='||
                                    to_number(v_annualizing_factor));

                  EXCEPTION WHEN no_data_found THEN

                    -- Added as part of SALLY CLEANUP.
                    -- Could have been passed in an ASG_FREQ dbi which
                    -- might have the values of
                    -- 'Day' or 'Month' which do not map to a time period type.
                    -- So we'll do these by hand.

                    IF UPPER(p_freq) = 'DAY' THEN
                       hr_utility.trace('  p_freq = DAY');
                       v_annualizing_factor := c_days_per_year;
                    ELSIF UPPER(p_freq) = 'MONTH' THEN
                       v_annualizing_factor := c_months_per_year;
                       hr_utility.trace('  p_freq = MONTH');
                    END IF;

                END;

           END IF;

        END IF;        -- (v_use_pay_basis = 0)


        hr_utility.trace('  Getting out of Get_Annualizing_Factor for '||
                                           v_pay_basis);
        RETURN v_annualizing_factor;

END Get_Annualizing_Factor;

BEGIN		 -- Convert Figure
--begin_convert_period_type

   --hr_utility.trace_on(null,'pay_core_ff_udfs');

     IF p_from_freq IS NULL THEN
        v_from_freq := 'NOT ENTERED';
     END IF;

     IF p_to_freq IS NULL THEN
        v_to_freq := 'NOT ENTERED';
     END IF;

    /* IF p_rate_calc_override IS NULL THEN
        v_rate_calc_override := 'NOT ENTERED';
     END IF;
    */
     hr_utility.trace('COREUDFS Entered Convert_Period_Type');

     hr_utility.trace('assignment_action_id=' || p_assignment_action_id);
     hr_utility.trace('assignment_id='        || p_assignment_id);
     hr_utility.trace('business_group_id='    || p_bg);
     hr_utility.trace('element_entry_id='     || p_element_entry_id);
     hr_utility.trace( 'p-date_earned '||p_date_earned);
     hr_utility.trace('  p_payroll_id: '||p_payroll_id);
     hr_utility.trace('  p_figure: '||p_figure);
     hr_utility.trace('p_period_start_date='  || p_period_start_date);
     hr_utility.trace('p_period_end_date='    || p_period_end_date);
     /*hr_utility.trace('p_schedule_category='  || p_schedule_category);
     hr_utility.trace('p_schedule_source='    || p_schedule_source);
     hr_utility.trace('p_include_exceptions=' || p_include_exceptions);
     hr_utility.trace('p_busy_tentative_as='  || p_busy_tentative_as);
     hr_utility.trace('p_schedule='     || p_schedule);*/

     hr_utility.trace('  p_from_freq : '||p_from_freq);
     hr_utility.trace('  p_to_freq: '||p_to_freq);
     hr_utility.trace('  p_asst_std_freq: '||p_asst_std_freq);


     IF g_legislation_code IS NULL THEN
       hr_utility.trace('g_legislation_code is null ');
       g_legislation_code :=  get_legislation_code(p_bg);
     END IF;

     hr_utility.trace('  p_asst_std_freq: '||p_asst_std_freq);


  --
  -- If From_Freq and To_Freq are the same, then we're done.
  --

  IF NVL(p_from_freq, 'NOT ENTERED') = NVL(p_to_freq, 'NOT ENTERED') THEN

    RETURN p_figure;

  END IF;
  hr_utility.trace('Calling Get_Annualizing_Factor for FROM case');
  v_from_annualizing_factor := Get_Annualizing_Factor
                ( p_bg
                 ,p_assignment_id
                 ,p_payroll_id
                 ,p_element_entry_id
                 ,p_date_earned
                 ,p_assignment_action_id
                 ,p_period_start_date
                 ,p_period_end_date
                 ,p_from_freq);




  hr_utility.trace('Calling Get_Annualizing_Factor for TO case');

  v_to_annualizing_factor := Get_Annualizing_Factor(
                                p_bg		   -- context
                               ,p_assignment_id        -- context
                               ,p_payroll_id  	   -- context
                               ,p_element_entry_id     -- context
                               ,p_date_earned          -- context
                               ,p_assignment_action_id -- context
                               ,p_period_start_date
                               ,p_period_END_date
                               ,p_to_freq);
                               --,p_asst_std_freq);

  --
  -- Annualize "Figure" and convert to To_Freq.
  --
 hr_utility.trace('v_from_annualizing_factor ='||to_char(v_from_annualizing_factor));
 hr_utility.trace('v_to_annualizing_factor ='||to_char(v_to_annualizing_factor));

  IF v_to_annualizing_factor = 0 	OR
         v_to_annualizing_factor = -999	OR
     v_from_annualizing_factor = -999	THEN

    hr_utility.trace(' v_to_ann =0 or -999 or v_from = -999');

    v_converted_figure := 0;
    RETURN v_converted_figure;

  ELSE

    hr_utility.trace(' v_to_ann NOT 0 or -999 or v_from = -999');

    hr_utility.trace('p_figure Monthly Salary = '||p_figure);
    hr_utility.trace('v_from_annualizing_factor = '||v_from_annualizing_factor);
    hr_utility.trace('v_to_annualizing_factor   = '||v_to_annualizing_factor);

    v_converted_figure := (p_figure * v_from_annualizing_factor) / v_to_annualizing_factor;
    hr_utility.trace('conv figure is monthly_sal * ann_from div by ann to');

    hr_utility.trace('CORE UDFS v_converted_figure := '||v_converted_figure);

  END IF;

-- Done

  /***********************************************************
   The is wrapper is added to check the caluclation rule given
   at the payroll level. Depending upon the Rule we  will the
   Get_Annualizing_Factor fun calls. If the rule is
   standard it goes to Standard Caluclation type. If the rule
   is Annual then it goes to ANNU rule
  **************************************************************/
  IF p_period_start_date IS  NULL THEN
     v_stnd_start_date := sysdate;
  ELSE
     v_stnd_start_date := p_period_start_date ;
  END IF;

  begin
       select nvl(ppf.prl_information2,'NOT ENTERED')
         into v_calc_type
         from pay_payrolls_f ppf
        where payroll_id = p_payroll_id
          and v_stnd_start_date between ppf.effective_start_date
                                    and ppf.effective_end_Date;
  exception
    when others then
       v_calc_type := null;
  end;

  -- Start Changes for Bug# 6163428

  open get_RegSal_ele_entry_id(g_legislation_code
                              ,p_assignment_id);
  fetch get_regsal_ele_entry_id into ln_regsal_ele_entry_id;
  close get_regsal_ele_entry_id;

  IF ln_regsal_ele_entry_id = p_element_entry_id THEN
     lb_regular_salary := TRUE;
  ELSE
     lb_regular_salary := FALSE;
  END IF;

  -- Changes for Bug# 7602381

  OPEN get_earnings_dtls(p_element_entry_id
                        ,p_assignment_id
                        ,g_legislation_code);
  FETCH get_earnings_dtls INTO ln_bg_id
                              ,lv_leg_code
                              ,lv_class_name;
  CLOSE get_earnings_dtls;

  hr_utility.trace('ln_bg_id := ' || ln_bg_id);
  hr_utility.trace('lv_leg_code := ' || lv_leg_code);
  hr_utility.trace('lv_class_name := ' || lv_class_name);

  -- Changes for Bug# 7458563

  open get_earning_xtra_ele_info(p_element_entry_id
                             ,p_assignment_id
                             ,p_bg);
  fetch get_earning_xtra_ele_info into lv_ele_xtra_info;
  close get_earning_xtra_ele_info;

  hr_utility.trace('g_legislation_code := ' || g_legislation_code);
  hr_utility.trace('ln_regsal_ele_entry_id := ' || ln_regsal_ele_entry_id);
  hr_utility.trace('p_element_entry_id := ' || p_element_entry_id);
  hr_utility.trace('lv_ele_xtra_info := ' || lv_ele_xtra_info);

-- This will Affect for Both US And Canada
-- depending on g_legislation_code

-- Changing IF condition for Bug# 7602381
-- ( User-created element + SHOULD NOT behave
--   like seeded 'Regular Salary' )
-- OR ( Oracle seeded elememnt + NOT 'Regular Salary' )

IF ((ln_bg_id IS NOT NULL
     and lv_leg_code IS NULL
     and lv_class_name like '%Earnings%'
     and NVL(lv_ele_xtra_info, 'N') = 'N')
    OR
    (ln_bg_id IS NULL
     and lv_leg_code IS NOT NULL
     and lv_class_name like '%Earnings%'
     and NOT(lb_regular_salary))) THEN
  IF
    (v_calc_type = 'STND'  and p_to_freq <> 'NOT ENTERED'
     and p_rate_calc_override = 'FIXED') OR
    (v_calc_type = 'NOT ENTERED' and p_to_freq <> 'NOT ENTERED'
     and p_rate_calc_override = 'FIXED') OR
    (v_calc_type = 'STND' and p_to_freq <> 'NOT ENTERED'
     and p_rate_calc_override = 'NOT ENTERED') OR
    (v_calc_type = 'ANNU' and p_to_freq <> 'NOT ENTERED'
     and p_rate_calc_override = 'FIXED')
  THEN

     v_from_stnd_factor := Get_Annualizing_Factor
                          ( p_bg
                           ,p_assignment_id
                           ,p_payroll_id
                           ,p_element_entry_id
                           ,p_date_earned
                           ,p_assignment_action_id
                           ,p_period_start_date
                           ,p_period_end_date
                           ,p_from_freq);

     -- Calling Function to get Standard Hours Worked
     -- As per the Work Schedule Entered.
     -- Assuming Work Schedule Always defines Number of Standard Hours in Each Day

     l_normal_hours := get_wrk_sch_std_hrs(
                             p_assignment_action_id => p_assignment_action_id
                            ,p_assignment_id  => p_assignment_id
                            ,p_bg_id => p_bg
                            ,p_element_entry_id => p_element_entry_id
                            ,p_date_earned => p_date_earned
                            ,p_period_start => p_period_start_date
                            ,p_period_end => p_period_start_date);

     hr_utility.trace('From Work Schedule l_normal_hours := '||l_normal_hours);

     -- In case Work Schedule is NOT defined
     -- If Assignment Frequency is Week
     -- Standard Condition will give Number of Hours per Week
     -- (I am NOT Considering any Frequency other than Week)

     IF NVL(l_normal_hours, 0) = 0 THEN
        open get_asg_hours_freq(p_date_earned
                            ,p_assignment_id);
        fetch get_asg_hours_freq into lv_frequency
                                  ,l_normal_hours;
        close get_asg_hours_freq;
     END IF;

     hr_utility.trace('From Standard Condition l_normal_hours := '||l_normal_hours);

     hr_utility.trace('p_figure := '||p_figure);
     hr_utility.trace('v_from_stnd_factor := '||v_from_stnd_factor);

     -- Following Condition will Arrive If NO Work Schedule Defined
     -- Or, Work Schedule User Table does NOT have
     -- "Days of the Week / Standard Hours Worked" Structure
     -- Or, Standard Condition Specifies Frequency Other than Week
     -- like Day / Month / Year etc.

     -- Defaulting it to 40 hours / Week to Avoid
     -- Divide by Zero Condition but Calculation Might be Wrong

     IF NVL(l_normal_hours, 0) = 0 THEN
        l_normal_hours := 40;
     END IF;

     v_converted_figure :=(p_figure * v_from_stnd_factor/(52 * l_normal_hours ));

     hr_utility.trace('v_converted_figure := '||v_converted_figure);
  END IF;
END IF;

-- End Changes for Bug# 6163428

RETURN v_converted_figure;

END Convert_Period_Type;
--
-- **********************************************************************
--

FUNCTION Calculate_Period_Earnings (
			p_bus_grp_id		in NUMBER,
			p_asst_id		in NUMBER,
			p_payroll_id		in NUMBER,
			p_ele_entry_id		in NUMBER,
			p_tax_unit_id		in NUMBER,
			p_date_earned		in DATE,
			p_assignment_action_id  in NUMBER,
			p_pay_basis 		in VARCHAR2,
			p_inpval_name		in VARCHAR2,
			p_ass_hrly_figure	in NUMBER,
			p_period_start 		in DATE,
			p_period_end 		in DATE,
			--p_work_schedule	    in VARCHAR2,
			--p_asst_std_hrs		in NUMBER,
			p_actual_hours_worked	in out nocopy NUMBER,
			p_vac_hours_worked   	in out nocopy NUMBER,
			p_vac_pay		        in out nocopy NUMBER,
			p_sick_hours_worked	    in out nocopy NUMBER,
			p_sick_pay		        in out nocopy NUMBER,
			p_prorate 		        in VARCHAR2,
			p_asst_std_freq		    in VARCHAR2)
RETURN NUMBER IS

l_asg_info_changes	NUMBER(1);
l_eev_info_changes	NUMBER(1);
v_earnings_entry		NUMBER(27,7);
v_inpval_id		NUMBER(9);
v_pay_basis		VARCHAR2(80);
v_pay_periods_per_year	NUMBER(3);
v_period_earn		NUMBER(27,7) ; -- Pay Period earnings.
v_hourly_earn		NUMBER(27,7);	-- Hourly Rate (earnings).
v_prorated_earnings	NUMBER(27,7) ; -- Calc'd thru proration loops.
v_curr_day		    VARCHAR2(3);	-- Currday while summing hrs for range of dates.
v_hrs_per_wk		NUMBER(15,7);
v_hrs_per_range	    NUMBER(15,7);
v_asst_std_hrs		NUMBER(15,7);
v_asst_std_freq		VARCHAR2(30);
v_asg_status		VARCHAR2(30);
v_hours_in_range	NUMBER(15,7);
v_curr_hrly_rate	NUMBER(27,7) ;
v_range_start		DATE;		-- range start of ASST rec
v_range_end		    DATE;		-- range end of ASST rec
v_entry_start		DATE;		-- start date of ELE ENTRY rec
v_entry_end		    DATE;		-- end date of ELE ENTRY rec
v_entrange_start	DATE;		-- max of entry or asst range start
v_entrange_end		DATE;		-- min of entry or asst range end
v_work_schedule		VARCHAR2(60);	-- Work Schedule ID (stored as varchar2
					--  in HR_SOFT_CODING_KEYFLEX; convert
					--  fnd_number.canonical_to_number when calling wshours fn.
v_work_sched_name	VARCHAR2(80);
v_ws_id			    NUMBER(9);

b_entries_done		BOOLEAN;	-- flags no more entry changes in paypd
b_asst_changed		BOOLEAN;	-- flags if asst changes at least once.
b_on_work_schedule	BOOLEAN;	-- use wrk scheds or std hours
l_mid_period_asg_change BOOLEAN ;

v_return_status              NUMBER;
v_return_message             VARCHAR2(500);
v_schedule_source            varchar2(100);
v_schedule                   varchar2(200);
v_total_hours	             NUMBER(15,7) 	;

/*
-- ************************************************************************
--
-- The following cursor "get_asst_chgs" looks for *changes* to or from
-- 'ACTIVE' per_assignment
-- records within the supplied range of dates, *WITHIN THE SAME TAX UNIT*
-- (ie. the tax unit as of the end of the period specified).
-- If no "changes" are found, then assignment information is consistent
-- over entire period specified.
-- Before calling this cursor, will need to select tax_unit_name
-- according to p_tax_unit_id.
--
-- ************************************************************************
*/

--
-- This cursor finds ALL ASG records that are WITHIN Period Start and End Dates
-- including Period End Date - NOT BETWEEN since the ASG record existing across
-- Period Start date has already been retrieved in SELECT (ASG1).
-- Work Schedule segment is segment4 on assignment DDF
--

CURSOR 	get_asst_chgs IS
SELECT	ASG.effective_start_date,
	ASG.effective_end_date,
	NVL(ASG.normal_hours, 0),
	NVL(HRL.meaning, 'NOT ENTERED'),
	NVL(SCL.segment4, 'NOT ENTERED')
FROM	per_assignments_f 		ASG,
	per_assignment_status_types 	AST,
	hr_soft_coding_keyflex		SCL,
	hr_lookups			HRL
WHERE	ASG.assignment_id	= p_asst_id
AND	ASG.business_group_id + 0	= p_bus_grp_id
AND  	ASG.effective_start_date        	> p_period_start
AND   	ASG.effective_end_date 	<= p_period_end
AND	AST.assignment_status_type_id = ASG.assignment_status_type_id
AND	AST.per_system_status 	= 'ACTIVE_ASSIGN'
AND	SCL.soft_coding_keyflex_id	= ASG.soft_coding_keyflex_id
AND	SCL.segment1			= TO_CHAR(p_tax_unit_id)
AND	SCL.enabled_flag		= 'Y'
AND	HRL.lookup_code(+)		= ASG.frequency
AND	HRL.lookup_type(+)		= 'FREQUENCY';

FUNCTION Prorate_Earnings (
		p_bg_id			IN NUMBER,
		p_asg_hrly_rate		IN NUMBER,
	--	p_wsched		IN VARCHAR2 DEFAULT 'NOT ENTERED',
	--	p_asg_std_hours		IN NUMBER,
	--	p_asg_std_freq		IN VARCHAR2,
		p_range_start_date	IN DATE,
		p_range_end_date	IN DATE,
		p_act_hrs_worked	IN OUT nocopy NUMBER) RETURN NUMBER IS

v_prorated_earn	NUMBER(27,7)	; -- RETURN var
v_hours_in_range	NUMBER(15,7);
v_ws_id		NUMBER(9);
v_ws_name		VARCHAR2(80);

BEGIN

  /* Init */

 --p_wsched := 'NOT ENTERED';
 v_prorated_earn := 0;

  hr_utility.trace('UDFS Entered Prorate Earnings');
  hr_utility.trace('p_bg_id ='||to_char(p_bg_id));
  hr_utility.trace('p_asg_hrly_rate ='||to_char(p_asg_hrly_rate));
 -- hr_utility.trace('p_wsched ='||p_wsched);
 -- hr_utility.trace('p_asg_std_hours ='||to_char(p_asg_std_hours));
 -- hr_utility.trace('p_asg_std_freq ='||p_asg_std_freq);
  hr_utility.trace('UDFS p_range_start_date ='||to_char(p_range_start_date));
  hr_utility.trace('UDFS p_range_end_date ='||to_char(p_range_end_date));
  hr_utility.trace('p_act_hrs_worked ='||to_char(p_act_hrs_worked));

  -- Prorate using hourly rate passed in as param:

/*
  IF UPPER(p_wsched) = 'NOT ENTERED' THEN

    hr_utility.set_location('Prorate_Earnings', 7);
    hr_utility.trace('p_wsched NOT ENTERED');
    hr_utility.trace('Calling Standard Hours Worked');

    v_hours_in_range := Standard_Hours_Worked(		p_asg_std_hours,
							p_range_start_date,
							p_range_end_date,
							p_asg_std_freq);

    -- Keep running total of ACTUAL hours worked.
    hr_utility.set_location('Prorate_Earnings', 11);

    hr_utility.trace('Keep running total of ACTUAL hours worked');

    hr_utility.trace('actual_hours_worked before call= '||
                      to_char(p_act_hrs_worked));
    hr_utility.trace('v_hours_in_range in current call= '||
                      to_char(v_hours_in_range));

    p_act_hrs_worked := p_act_hrs_worked + v_hours_in_range;

    hr_utility.trace('UDFS actual_hours_worked after call = '||
                      to_char(p_act_hrs_worked));

  ELSE

    hr_utility.set_location('Prorate_Earnings', 17);
    hr_utility.trace('Entered WORK SCHEDULE');

    hr_utility.trace('Getting WORK SCHEDULE Name');

    -- Get work schedule name:

    v_ws_id := fnd_number.canonical_to_number(p_wsched);

    hr_utility.trace('v_ws_id ='||to_char(v_ws_id));

    SELECT	user_column_name
    INTO	v_ws_name
    FROM	pay_user_columns
    WHERE	user_column_id 			= v_ws_id
    AND		NVL(business_group_id, p_bg_id) = p_bg_id
    AND         NVL(legislation_code,'US')      = 'US';

    hr_utility.trace('v_ws_name ='||v_ws_name );
    hr_utility.trace('Calling Work_Schedule_Total_Hours');

    v_hours_in_range := Work_Schedule_Total_Hours(
				p_bg_id,
				v_ws_name,
				p_range_start_date,
				p_range_end_date);

    p_act_hrs_worked := p_act_hrs_worked + v_hours_in_range;
    hr_utility.trace('v_hours_in_range = '||to_char(v_hours_in_range));

  END IF; -- Hours in date range via work schedule or std hours.
*/


   hr_utility.trace('calling PAY_CORE_FF_UDFS.calculate_actual_hours_worked');
   v_hours_in_range := pay_core_ff_udfs.calculate_actual_hours_worked (
                                   null
                                  ,p_asst_id
                                  ,p_bus_grp_id
                                  ,p_ele_entry_id
                                  ,p_date_earned
                                  ,p_range_start_date
                                  ,p_range_end_date
                                  ,NULL
                                  ,'Y'
                                  ,'BUSY'
                                  ,''--p_legislation_code
                                  ,v_schedule_source
                                  ,v_schedule
                                  ,v_return_status
                                  ,v_return_message);

  p_act_hrs_worked := p_act_hrs_worked + v_hours_in_range;
  hr_utility.trace('v_hours_in_range = '||to_char(v_hours_in_range));


  hr_utility.trace('v_prorated_earnings = p_asg_hrly_rate * v_hours_in_range');


  hr_utility.trace('v_prorated_earnings = p_asg_hrly_rate * v_hours_in_range');

  v_prorated_earn := v_prorated_earn + (p_asg_hrly_rate * v_hours_in_range);

  hr_utility.trace('UDFS final v_prorated_earnings = '||to_char(v_prorated_earn));
  hr_utility.set_location('Prorate_Earnings', 97);
  p_act_hrs_worked := ROUND(p_act_hrs_worked, 3);
  hr_utility.trace('p_act_hrs_worked ='||to_char(p_act_hrs_worked));
  hr_utility.trace('UDFS Leaving Prorated Earnings');

  RETURN v_prorated_earn;

END Prorate_Earnings;

FUNCTION Prorate_EEV (	p_bus_group_id		IN NUMBER,
			p_pay_id	    	IN NUMBER,
			--p_work_sched	    IN VARCHAR2 DEFAULT 'NOT ENTERED',
			--p_asg_std_hrs		IN NUMBER,
			--p_asg_std_freq		IN VARCHAR2,
			p_pay_basis		    IN VARCHAR2,
			p_hrly_rate 		IN OUT nocopy NUMBER,
			p_range_start_date	IN DATE,
			p_range_end_date	IN DATE,
			p_actual_hrs_worked	IN OUT nocopy NUMBER,
			p_element_entry_id	IN NUMBER,
			p_inpval_id	    	IN NUMBER) RETURN NUMBER IS
--
-- local vars
--
v_eev_prorated_earnings	NUMBER(27,7) ; -- Calc'd thru proration loops.
v_earnings_entry		VARCHAR2(60);
v_entry_start		DATE;
v_entry_end		DATE;
v_hours_in_range	NUMBER(15,7);
v_curr_hrly_rate		NUMBER(27,7);
v_ws_id			NUMBER(9);
v_ws_name		VARCHAR2(80);
--
-- Select for ALL records that are WITHIN Range Start and End Dates
-- including Range End Date - NOT BETWEEN since the EEV record existing across
-- Range Start date has already been retrieved and dealt with in SELECT (EEV1).
-- A new EEV record results in a change of the current hourly rate being used
-- in proration calculation.
--
CURSOR	get_entry_chgs (	p_range_start 	date,
				p_range_end	date) IS
SELECT	EEV.screen_entry_value,
	EEV.effective_start_date,
	EEV.effective_end_date
FROM	pay_element_entry_values_f	EEV
WHERE	EEV.element_entry_id 		= p_element_entry_id
AND 	EEV.input_value_id 		= p_inpval_id
AND	EEV.effective_start_date		> p_range_start
AND  	EEV.effective_end_date 	       	<= p_range_end
ORDER BY EEV.effective_start_date;
--
BEGIN


 /* Init */
 --p_work_sched := 'NOT ENTERED';
 v_eev_prorated_earnings := 0;


  hr_utility.trace('UDFS Entering PRORATE_EEV');
  hr_utility.trace('p_bus_group_id ='||to_char(p_bus_group_id));
  hr_utility.trace('p_pay_id ='||to_char(p_pay_id));
 -- hr_utility.trace('p_work_sched ='||p_work_sched);
  --hr_utility.trace('p_asg_std_hrs ='||to_char(p_asg_std_hrs));
 -- hr_utility.trace('p_asg_std_freq ='||p_asg_std_freq);
  hr_utility.trace('p_pay_basis ='||p_pay_basis);
  hr_utility.trace('p_hrly_rate ='||to_char(p_hrly_rate));
  hr_utility.trace('UDFS p_range_start_date ='||to_char(p_range_start_date));
  hr_utility.trace('UDFS p_range_end_date ='||to_char(p_range_end_date));
  hr_utility.trace('p_actual_hrs_worked ='||to_char(p_actual_hrs_worked));
  hr_utility.trace('p_element_entry_id ='||to_char(p_element_entry_id));
  hr_utility.trace('p_inpval_id ='||to_char(p_inpval_id));
  --
  -- Find all EEV changes, calculate new hourly rate, prorate:
  -- SELECT (EEV1):
  -- Select for SINGLE record that includes Period Start Date but does not
  -- span entire period.
  -- We know this select will return a row, otherwise there would be no
  -- EEV changes to detect.
  --
  hr_utility.set_location('Prorate_EEV', 103);
  SELECT	EEV.screen_entry_value,
		GREATEST(EEV.effective_start_date, p_range_start_date),
		EEV.effective_end_date
  INTO		v_earnings_entry,
		v_entry_start,
		v_entry_end
  FROM		pay_element_entry_values_f	EEV
  WHERE	EEV.element_entry_id 		= p_element_entry_id
  AND 		EEV.input_value_id 		= p_inpval_id
  AND		EEV.effective_start_date       <= p_range_start_date
  AND  		EEV.effective_end_date 	       >= p_range_start_date
  AND  		EEV.effective_end_date 	        < p_range_end_date;


  hr_utility.trace('screen_entry_value ='||v_earnings_entry);
  hr_utility.trace('v_entry_start ='||to_char(v_entry_start));
  hr_utility.trace('v_entry_end ='||to_char(v_entry_end));
  hr_utility.trace('Calling Convert_Period_Type ');
  hr_utility.set_location('Prorate_EEV', 105);

  v_curr_hrly_rate := Convert_Period_Type(p_bus_grp_id
        ,p_asst_id
	    ,p_payroll_id
        ,p_ele_entry_id
        ,p_date_earned
        ,p_assignment_action_id
        ,p_period_start  -- period start date
        ,p_period_end    -- period end date
        ,v_earnings_entry          -- p_figure, salary amount
        ,p_pay_basis        -- p_from freq, salary basis
        ,'HOURLY');            -- p_to_freq


  /*get_hourly_rate(
	     p_bus_grp_id
        ,p_asst_id
   	    ,p_payroll_id
        ,p_ele_entry_id
        ,p_date_earned
        ,p_assignment_action_id );
    */
        /*Convert_Period_Type(	p_bus_group_id,
						p_pay_id,
						p_work_sched,
						p_asg_std_hrs,
						v_earnings_entry,
						p_pay_basis,
						'HOURLY',
       	                p_period_start,
		                p_period_end,
						p_asg_std_freq); */
  hr_utility.trace('v_curr_hrly_rate ='||to_char(v_curr_hrly_rate));
  hr_utility.set_location('Prorate_EEV', 107);

  v_eev_prorated_earnings := v_eev_prorated_earnings +
			     Prorate_Earnings (
				p_bg_id			=> p_bus_group_id,
				p_asg_hrly_rate 	=> v_curr_hrly_rate,
				p_range_start_date	=> v_entry_start,
				p_range_end_date	=> v_entry_end,
				p_act_hrs_worked       	=> p_actual_hrs_worked);

  hr_utility.trace('v_eev_prorated_earnings ='||
                      to_char(v_eev_prorated_earnings));
  -- SELECT (EEV2):
  hr_utility.trace('Opening get_entry_chgs cursor EEV2');

  OPEN get_entry_chgs (p_range_start_date, p_range_end_date);
    LOOP
    --
    FETCH get_entry_chgs
    INTO  v_earnings_entry,
	  v_entry_start,
	  v_entry_end;
    EXIT WHEN get_entry_chgs%NOTFOUND;
    --
  hr_utility.trace('v_earnings_entry ='||v_earnings_entry);
  hr_utility.trace('v_entry_start ='||to_char(v_entry_start));
  hr_utility.trace('v_entry_end ='||to_char(v_entry_end));
  hr_utility.set_location('Prorate_EEV', 115);
    --
    -- For each range of dates found, add to running prorated earnings total.
    --
  hr_utility.trace('Calling Convert_Period_Type ');

    v_curr_hrly_rate := Convert_Period_Type(p_bus_grp_id
                                        ,p_asst_id
                                	    ,p_payroll_id
                                        ,p_ele_entry_id
                                        ,p_date_earned
                                        ,p_assignment_action_id
                                        ,p_period_start  -- period start date
                                        ,p_period_end    -- period end date
                                        ,v_earnings_entry          -- p_figure, salary amount
                                        ,p_pay_basis        -- p_from freq, salary basis
                                        ,'HOURLY');            -- p_to_freq

        /*Convert_Period_Type(	p_bus_group_id,
						p_pay_id,
						p_work_sched,
						p_asg_std_hrs,
						v_earnings_entry,
						p_pay_basis,
						'HOURLY',
       	                p_period_start,
  	                    p_period_end,
						p_asg_std_freq); */


  hr_utility.trace('v_curr_hrly_rate ='||to_char(v_curr_hrly_rate));
    hr_utility.set_location('Prorate_EEV', 119);
    v_eev_prorated_earnings := v_eev_prorated_earnings +
			     Prorate_Earnings (
				p_bg_id			=> p_bus_group_id,
				p_asg_hrly_rate 	=> v_curr_hrly_rate,
				p_range_start_date	=> v_entry_start,
				p_range_end_date	=> v_entry_end,
				p_act_hrs_worked       	=> p_actual_hrs_worked);

  hr_utility.trace('v_eev_prorated_earnings ='||to_char(v_eev_prorated_earnings));

  END LOOP;
  --
  CLOSE get_entry_chgs;
  --
  -- SELECT (EEV3)
  -- Select for SINGLE record that exists across Period End Date:
  -- NOTE: Will only return a row if select (2) does not return a row where
  -- 	   Effective End Date = Period End Date !

 hr_utility.trace('Select EEV3');
  hr_utility.set_location('Prorate_EEV', 141);
  SELECT	EEV.screen_entry_value,
		EEV.effective_start_date,
		LEAST(EEV.effective_end_date, p_range_end_date)
  INTO		v_earnings_entry,
		v_entry_start,
		v_entry_end
  FROM		pay_element_entry_values_f	EEV
  WHERE		EEV.element_entry_id 		= p_element_entry_id
  AND 		EEV.input_value_id 		= p_inpval_id
  AND		EEV.effective_start_date        > p_range_start_date
  AND		EEV.effective_start_date       <= p_range_end_date
  AND  		EEV.effective_end_date 	        > p_range_end_date;
  hr_utility.set_location('Prorate_EEV', 147);
  hr_utility.trace('screen_entry_value ='||v_earnings_entry);
  hr_utility.trace('v_entry_start ='||to_char(v_entry_start));
  hr_utility.trace('v_entry_end ='||to_char(v_entry_end));

  hr_utility.trace('Calling Convert_Period_Type ');

  v_curr_hrly_rate := Convert_Period_Type(p_bus_grp_id
                                        ,p_asst_id
                                	    ,p_payroll_id
                                        ,p_ele_entry_id
                                        ,p_date_earned
                                        ,p_assignment_action_id
                                        ,p_period_start  -- period start date
                                        ,p_period_end    -- period end date
                                        ,v_earnings_entry   -- p_figure, salary amount
                                        ,p_pay_basis        -- p_from freq, salary basis
                                        ,'HOURLY');         -- p_to_freq
    /*Convert_Period_Type(	p_bus_group_id,
						p_pay_id,
						p_work_sched,
						p_asg_std_hrs,
						v_earnings_entry,
						p_pay_basis,
						'HOURLY',
          	                p_period_start,
				                p_period_end,
						p_asg_std_freq);
	*/
  hr_utility.set_location('Prorate_EEV', 151);
  hr_utility.trace('After Call v_curr_hrly_rate ='||to_char(v_curr_hrly_rate));

  v_eev_prorated_earnings := v_eev_prorated_earnings +
			     Prorate_Earnings (
				p_bg_id			=> p_bus_group_id,
				p_asg_hrly_rate 	=> v_curr_hrly_rate,
				p_range_start_date	=> v_entry_start,
				p_range_end_date	=> v_entry_end,
				p_act_hrs_worked       	=> p_actual_hrs_worked);

  -- We're Done!
     hr_utility.trace('v_eev_prorated_earnings ='||
     to_char(v_eev_prorated_earnings));
  hr_utility.set_location('Prorate_EEV', 167);
  p_actual_hrs_worked := ROUND(p_actual_hrs_worked, 3);
  p_hrly_rate := v_curr_hrly_rate;

  hr_utility.trace('p_actual_hrs_worked ='||to_char(p_actual_hrs_worked));
  hr_utility.trace('p_hrly_rate ='||to_char(p_hrly_rate));

  hr_utility.trace('UDFS Leaving Prorated EEV');

  RETURN v_eev_prorated_earnings;

EXCEPTION WHEN NO_DATA_FOUND THEN
  hr_utility.set_location('Prorate_EEV', 177);
  hr_utility.trace('Into exception of Prorate_EEV');

  p_actual_hrs_worked := ROUND(p_actual_hrs_worked, 3);
  p_hrly_rate := v_curr_hrly_rate;

  hr_utility.trace('p_actual_hrs_worked ='||to_char(p_actual_hrs_worked));
  hr_utility.trace('p_hrly_rate ='||to_char(p_hrly_rate));

  RETURN v_eev_prorated_earnings;

END Prorate_EEV;

FUNCTION	vacation_pay (	p_vac_hours 	IN OUT nocopy NUMBER,
				p_asg_id 	IN NUMBER,
				p_eff_date	IN DATE,
				p_curr_rate	IN NUMBER) RETURN NUMBER IS

l_vac_pay	NUMBER(27,7) ;
l_vac_hours	NUMBER(10,7);

CURSOR get_vac_hours (	v_asg_id NUMBER,
			v_eff_date DATE) IS
select	fnd_number.canonical_to_number(pev.screen_entry_value)
from	per_absence_attendance_types 	abt,
	pay_element_entries_f 		pee,
	pay_element_entry_values_f	pev
where   pev.input_value_id	= abt.input_value_id
and     abt.absence_category    = 'V'
and	v_eff_date		between pev.effective_start_date
			    	    and pev.effective_end_date
and	pee.element_entry_id	= pev.element_entry_id
and	pee.assignment_id	= v_asg_id
and	v_eff_date		between pee.effective_start_date
			    	    and pee.effective_end_date;

-- The "vacation_pay" fn looks for hours entered against absence types
-- in the current period.  The number of hours are summed and multiplied by
-- the current rate of Regular Pay..
-- Return immediately when no vacation time has been taken.
-- Need to loop thru all "Vacation Plans" and check for entries in the current
-- period for this assignment.

BEGIN

  /* Init */
  l_vac_pay := 0;

  hr_utility.set_location('get_vac_pay', 11);
  hr_utility.trace('Entered Vacation Pay');

OPEN get_vac_hours (p_asg_id, p_eff_date);
LOOP

  hr_utility.set_location('get_vac_pay', 13);
  hr_utility.trace('Opened get_vac_hours');

  FETCH get_vac_hours
  INTO	l_vac_hours;
  EXIT WHEN get_vac_hours%NOTFOUND;

  p_vac_hours := p_vac_hours + l_vac_hours;

END LOOP;
CLOSE get_vac_hours;

hr_utility.set_location('get_vac_pay', 15);

IF p_vac_hours <> 0 THEN

  l_vac_pay := p_vac_hours * p_curr_rate;

END IF;

  hr_utility.trace('Leaving Vacation Pay');
RETURN l_vac_pay;

END vacation_pay;

FUNCTION	sick_pay (	p_sick_hours 	IN OUT nocopy NUMBER,
				p_asg_id 	IN NUMBER,
				p_eff_date	IN DATE,
				p_curr_rate	IN NUMBER) RETURN NUMBER IS

l_sick_pay	NUMBER(27,7)	;
l_sick_hours	NUMBER(10,7);

CURSOR get_sick_hours (	v_asg_id NUMBER,
			v_eff_date DATE) IS
select	fnd_number.canonical_to_number(pev.screen_entry_value)
from	per_absence_attendance_types	abt,
	pay_element_entries_f 		pee,
	pay_element_entry_values_f	pev
where	pev.input_value_id	= abt.input_value_id
and     abt.absence_category    = 'S'
and	v_eff_date		between pev.effective_start_date
			    	    and pev.effective_end_date
and	pee.element_entry_id	= pev.element_entry_id
and	pee.assignment_id	= v_asg_id
and	v_eff_date		between pee.effective_start_date
			    	    and pee.effective_end_date;

-- The "sick_pay" looks for hours entered against Sick absence types in
-- the current period.  The number of hours are summed and multiplied by the
-- current rate of Regular Pay.
-- Return immediately when no sick time has been taken.

BEGIN

  /* Init */
  l_sick_pay :=0;

  hr_utility.set_location('get_sick_pay', 11);
  hr_utility.trace('Entered Sick Pay');

OPEN get_sick_hours (p_asg_id, p_eff_date);
LOOP

  hr_utility.trace('get_sick_pay');
  hr_utility.set_location('get_sick_pay', 13);

  FETCH get_sick_hours
  INTO	l_sick_hours;
  EXIT WHEN get_sick_hours%NOTFOUND;

  p_sick_hours := p_sick_hours + l_sick_hours;

END LOOP;
CLOSE get_sick_hours;

  hr_utility.set_location('get_sick_pay', 15);
  hr_utility.trace('get_sick_pay');

IF p_sick_hours <> 0 THEN

  l_sick_pay := p_sick_hours * p_curr_rate;

END IF;

  hr_utility.trace('Leaving get_sick_pay');
RETURN l_sick_pay;

END sick_pay;

BEGIN	-- Calculate_Period_Earnings
        --BEGINCALC

 /* Init */
v_period_earn           := 0;
v_prorated_earnings     := 0;
v_curr_hrly_rate        := 0;
l_mid_period_asg_change := FALSE;

-- hr_utility.trace_on(null,'coreff');

 hr_utility.trace('UDFS Entered Calculate_Period_Earnings');
 hr_utility.trace('p_asst_id ='||to_char(p_asst_id));
 hr_utility.trace('p_payroll_id ='||to_char(p_payroll_id));
 hr_utility.trace('p_ele_entry_id ='||to_char(p_ele_entry_id));
 hr_utility.trace('p_tax_unit_id ='||to_char(p_tax_unit_id));
 hr_utility.trace('p_date_earned ='||to_char(p_date_earned));
 hr_utility.trace('p_pay_basis ='||p_pay_basis);
 hr_utility.trace('p_inpval_name ='||p_inpval_name);
 hr_utility.trace('p_ass_hrly_figure ='||to_char(p_ass_hrly_figure));
 hr_utility.trace('UDFS p_period_start ='||to_char(p_period_start));
 hr_utility.trace('UDFS p_period_end ='||to_char(p_period_end));
 --hr_utility.trace('p_work_schedule ='||p_work_schedule);
 --hr_utility.trace('p_asst_std_hrs ='||to_char(p_asst_std_hrs));
 hr_utility.trace('p_actual_hours_worked ='||to_char(p_actual_hours_worked));
 hr_utility.trace('p_vac_hours_worked ='||to_char(p_vac_hours_worked));
 hr_utility.trace('p_vac_pay ='||to_char(p_vac_pay));
 hr_utility.trace('p_sick_hours_worked ='||to_char(p_sick_hours_worked));
 hr_utility.trace('p_sick_pay ='||to_char(p_sick_pay));
 hr_utility.trace('UDFS p_prorate ='||p_prorate);
 hr_utility.trace('p_asst_std_freq ='||p_asst_std_freq);

 hr_utility.trace('Find earnings element input value id');

p_actual_hours_worked := 0;

-- Step (1): Find earnings element input value.
-- Get input value and pay basis according to salary admin (if exists).
-- If not using salary admin, then get "Rate", "Rate Code", or "Monthly Salary"
-- input value id as appropriate (according to ele name).
IF g_legislation_code IS NULL THEN
   g_legislation_code :=  get_legislation_code(p_bus_grp_id);
END IF;
IF p_pay_basis IS NOT NULL THEN

  BEGIN

  hr_utility.trace('  p_pay_basis IS NOT NULL');
  hr_utility.set_location('calculate_period_earnings', 10);

  SELECT	PYB.input_value_id,
  		FCL.meaning
  INTO	v_inpval_id,
 		v_pay_basis
  FROM	per_assignments_f	ASG,
		per_pay_bases 		PYB,
		hr_lookups		FCL
  WHERE	FCL.lookup_code	= PYB.pay_basis
  AND	FCL.lookup_type 	= 'PAY_BASIS'
  AND	FCL.application_id	= 800
  AND	PYB.pay_basis_id 	= ASG.pay_basis_id
  AND	ASG.assignment_id 	= p_asst_id
  AND	p_date_earned  BETWEEN ASG.effective_start_date
				AND ASG.effective_end_date;

  EXCEPTION WHEN NO_DATA_FOUND THEN
    hr_utility.set_location('calculate_period_earnings', 11);
    hr_utility.trace(' In EXCEPTION p_pay_basis IS NOT NULL');

    v_period_earn := 0;
    p_actual_hours_worked := ROUND(p_actual_hours_worked, 3);

    hr_utility.trace('p_actual_hours_worked ='||to_char(p_actual_hours_worked));

    RETURN  v_period_earn;


  END;

hr_utility.trace('p_inpval_name = '||p_inpval_name);

ELSIF UPPER(p_inpval_name) = 'RATE' THEN

   hr_utility.trace('  p_pay_basis IS NULL');
   hr_utility.trace('In p_inpval_name = RATE');
/* Changed the element_name and name to init case and added
   the date join for pay_element_types_f */

  begin
       SELECT 	IPV.input_value_id
           INTO v_inpval_id
       FROM	pay_input_values_f	IPV,
		pay_element_types_f	ELT
       WHERE	ELT.element_name = 'Regular Wages'
            and p_period_start    BETWEEN ELT.effective_start_date
                                      AND ELT.effective_end_date
            and ELT.element_type_id = IPV.element_type_id
            and	p_period_start	  BETWEEN IPV.effective_start_date
				      AND IPV.effective_end_date
            and	IPV.name = 'Rate'
            and ELT.legislation_code = g_legislation_code;
  --
       v_pay_basis := 'HOURLY';
  --
  EXCEPTION WHEN NO_DATA_FOUND THEN

    hr_utility.trace('Exception of RATE ');

    v_period_earn := 0;
    p_actual_hours_worked := ROUND(p_actual_hours_worked, 3);

    hr_utility.trace('p_actual_hours_worked ='||to_char(p_actual_hours_worked));

    RETURN  v_period_earn;
  end;
  --
ELSIF UPPER(p_inpval_name) = 'RATE CODE' THEN
    /* Changed the element_name and name to init case and added
       the date join for pay_element_types_f */

  begin
        hr_utility.trace('In RATE CODE');

       SELECT 	IPV.input_value_id
           INTO	v_inpval_id
       FROM	pay_input_values_f	IPV,
		pay_element_types_f	ELT
       WHERE	ELT.element_name = 'Regular Wages'
            and p_period_start    BETWEEN ELT.effective_start_date
                                      AND ELT.effective_end_date
            and	ELT.element_type_id = IPV.element_type_id
            and	p_period_start	  BETWEEN IPV.effective_start_date
				      AND IPV.effective_end_date
            and	IPV.name = 'Rate Code'
            and ELT.legislation_code = g_legislation_code;
  --
       v_pay_basis := 'HOURLY';
  --
  EXCEPTION WHEN NO_DATA_FOUND THEN
    hr_utility.trace('Exception of Rate Code');

    v_period_earn := 0;
    p_actual_hours_worked := ROUND(p_actual_hours_worked, 3);

    hr_utility.trace('p_actual_hours_worked ='||to_char(p_actual_hours_worked));

    RETURN  v_period_earn;

  end;
  --
ELSIF UPPER(p_inpval_name) = 'MONTHLY SALARY' THEN

  /* Changed the element_name and name to init case and added
   the date join for pay_element_types_f */

  begin
       hr_utility.trace('in MONTHLY SALARY');

       SELECT	IPV.input_value_id
           INTO	v_inpval_id
       FROM	pay_input_values_f	IPV,
		pay_element_types_f	ELT
       WHERE	ELT.element_name = 'Regular Salary'
            and p_period_start    BETWEEN ELT.effective_start_date
                                      AND ELT.effective_end_date
            and	ELT.element_type_id = IPV.element_type_id
            and	p_period_start	  BETWEEN IPV.effective_start_date
				      AND IPV.effective_end_date
            and	IPV.name = 'Monthly Salary'
            and ELT.legislation_code = g_legislation_code;

       v_pay_basis := 'MONTHLY';

  EXCEPTION WHEN NO_DATA_FOUND THEN
    hr_utility.set_location('calculate_period_earnings', 18);
    v_period_earn := 0;
    p_actual_hours_worked := ROUND(p_actual_hours_worked, 3);
    hr_utility.trace('p_actual_hours_worked ='||to_char(p_actual_hours_worked));
    RETURN  v_period_earn;
  END;

END IF;

hr_utility.trace('Now know the pay basis for this assignment');
hr_utility.trace('v_inpval_id ='||to_char(v_inpval_id));
hr_utility.trace('v_pay_basis ='||v_pay_basis);
/*
-- Now know the pay basis for this assignment (v_pay_basis).
-- Want to convert entered earnings to pay period earnings.
-- For pay basis of Annual, Monthly, Bi-Weekly, Semi-Monthly,
-- or Period (ie. anything
-- other than Hourly):
-- Annualize entered earnings according to pay basis;
-- then divide by number of payroll periods per fiscal
-- yr for pay period earnings.
-- 02 Dec 1993:
-- Actually, passing in an "Hourly" figure from formula alleviates
-- having to convert in here --> we have Convert_Period_Type fn
-- available to formulae, so a Monthly Salary can be converted before
-- calling this fn.  Then we just find the hours scheduled for current period as
-- per the Hourly pay basis algorithm below.
--
-- For Hourly pay basis:
-- 	Get hours scheduled for the current period either from:
--	1. ASG work schedule
--	2. ORG default work schedule
--	3. ASG standard hours and frequency
--	Multiply the hours scheduled for period by normal Hourly Rate (ie. from
--	pre-defined earnings, REGULAR_WAGES_RATE) pay period earnings.
--
-- In either case, need to find the payroll period type, let's do it upfront:
--	Assignment.payroll_id --> Payroll.period_type
--	--> Per_time_period_types.number_per_fiscal_year.
-- Actually, the number per fiscal year could be found in more than one way:
--	Could also go to per_time_period_rules, but would mean decoding the
--	payroll period type to an appropriate proc_period_type code.
--
*/

-- Find # of payroll period types per fiscal year:

begin

hr_utility.trace('Find # of payroll period types per fiscal year');
hr_utility.set_location('calculate_period_earnings', 40);

SELECT 	TPT.number_per_fiscal_year
INTO		v_pay_periods_per_year
FROM		pay_payrolls_f 		PRL,
		per_time_period_types 	TPT
WHERE	TPT.period_type 		= PRL.period_type
AND		p_period_end      between PRL.effective_start_date
				      and PRL.effective_end_date
AND		PRL.payroll_id			= p_payroll_id
AND		PRL.business_group_id + 0	= p_bus_grp_id;

hr_utility.trace('v_pay_periods_per_year ='||to_char(v_pay_periods_per_year));

exception when NO_DATA_FOUND then

  hr_utility.set_location('calculate_period_earnings', 41);
  hr_utility.trace('Exception Find # of payroll period');
  v_period_earn := 0;
  p_actual_hours_worked := ROUND(p_actual_hours_worked, 3);
  hr_utility.trace('p_actual_hours_worked ='||to_char(p_actual_hours_worked));

  RETURN  v_period_earn;

end;

/*
     -- Pay basis is hourly,
     -- 	Get hours scheduled for the current period either from:
     --	1. ASG work schedule
     --	2. ORG default work schedule
     --	3. ASG standard hours and frequency
     -- Do we pass in Work Schedule from asst scl db item?  Yes
     -- 10-JAN-1996 hparicha : We no longer assume "standard hours" represent
     -- a weekly figure.  We also no longer use a week as
     -- the basis for annualization,
     -- even when using work schedule - ie. need to find ACTUAL
     -- scheduled hours, not
     -- actual hours for a week, converted to a period figure.
*/
--
hr_utility.set_location('calculate_period_earnings', 45);
hr_utility.trace('Get hours scheduled for the current period');

/*IF p_work_schedule <> 'NOT ENTERED' THEN
  --
  -- Find hours worked between period start and end dates.
  --
  hr_utility.trace('Asg has Work Schedule');
  hr_utility.trace('p_work_schedule ='||p_work_schedule);

  v_ws_id := fnd_number.canonical_to_number(p_work_schedule);
  hr_utility.trace('v_ws_id ='||to_char(v_ws_id));
  --
  SELECT	user_column_name
  INTO		v_work_sched_name
  FROM		pay_user_columns
  WHERE		user_column_id 				= v_ws_id
  AND		NVL(business_group_id, p_bus_grp_id)	= p_bus_grp_id
  AND         	NVL(legislation_code,'US')      	= 'US';

  hr_utility.trace('v_work_sched_name ='||v_work_sched_name);
  hr_utility.trace('Calling Work_Schedule_Total_Hours');

  v_hrs_per_range := Work_Schedule_Total_Hours(	p_bus_grp_id,
							v_work_sched_name,
							p_period_start,
							p_period_end);
  hr_utility.trace('v_hrs_per_range ='||to_char(v_hrs_per_range));
ELSE

  hr_utility.trace('Asg has No Work Schedule');
  hr_utility.trace('Calling  Standard_Hours_Worked');

   v_hrs_per_range := Standard_Hours_Worked(	p_asst_std_hrs,
						p_period_start,
						p_period_end,
						p_asst_std_freq);
  hr_utility.trace('v_hrs_per_range ='||to_char(v_hrs_per_range));

END IF;
*/

v_hrs_per_range  := pay_core_ff_udfs.calculate_actual_hours_worked (
                                   null
                                  ,p_asst_id
                                  ,p_bus_grp_id
                                  ,p_ele_entry_id
                                  ,p_date_earned
                                  ,p_period_start
                                  ,p_period_end
                                  ,NULL
                                  ,'Y'
                                  ,'BUSY'
                                  ,''--p_legislation_code
                                  ,v_schedule_source
                                  ,v_schedule
                                  ,v_return_status
                                  ,v_return_message);
 hr_utility.trace('v_hrs_per_range ='||to_char(v_hrs_per_range));

hr_utility.trace('Compute earnings and actual hours');
hr_utility.trace('calling convert_period_type from calculate_period_earnings');
hr_utility.set_location('calculate_period_earnings', 46);

v_period_earn := Convert_Period_Type(p_bus_grp_id
                                        ,p_asst_id
                                	    ,p_payroll_id
                                        ,p_ele_entry_id
                                        ,p_date_earned
                                        ,p_assignment_action_id
                                        ,p_period_start  -- period start date
                                        ,p_period_end    -- period end date
                                        ,p_ass_hrly_figure   -- p_figure, salary amount
                                        ,'HOURLY'        -- p_from freq, salary basis
                                        ,NULL);         -- p_to_freq

            /*Convert_Period_Type(	p_bus_grp_id,
					p_payroll_id,
					p_work_schedule,
					p_asst_std_hrs,
					p_ass_hrly_figure,
					'HOURLY',
					NULL,
					p_period_start,
					p_period_end,
					p_asst_std_freq); */

hr_utility.trace('v_period_earn ='||to_char(v_period_earn));
hr_utility.set_location('calculate_period_earnings', 47);

p_actual_hours_worked := v_hrs_per_range;

hr_utility.trace('p_actual_hours_worked ='||to_char(p_actual_hours_worked));

IF p_prorate = 'N' THEN

  hr_utility.trace('No proration');
  hr_utility.trace('Calling p_vac_pay');
  hr_utility.set_location('calculate_period_earnings', 49);

  p_vac_pay := vacation_pay(	p_vac_hours	=> p_vac_hours_worked,
				p_asg_id	=> p_asst_id,
				p_eff_date	=> p_period_end,
				p_curr_rate	=> p_ass_hrly_figure);

  hr_utility.trace('p_vac_pay ='||to_char(p_vac_pay));

  hr_utility.trace('Calling sick Pay');
  p_sick_pay := sick_pay(	p_sick_hours	=> p_sick_hours_worked,
				p_asg_id	=> p_asst_id,
				p_eff_date	=> p_period_end,
				p_curr_rate	=> p_ass_hrly_figure);


  hr_utility.trace('p_sick_pay ='||to_char(p_sick_pay));

  p_actual_hours_worked := ROUND(p_actual_hours_worked, 3);

  hr_utility.trace('p_actual_hours_worked ='||to_char(p_actual_hours_worked));
  hr_utility.trace('UDFS v_period_earn ='||to_char(v_period_earn));

  RETURN v_period_earn;

END IF; /* IF  p_prorate = 'N' */


hr_utility.trace('UDFS check for ASGMPE changes');
hr_utility.set_location('calculate_period_earnings', 51);
/* ************************************************************** */

BEGIN /* Check ASGMPE */

  select 1 INTO l_asg_info_changes
    from dual
  where exists (
  SELECT	1
  FROM		per_assignments_f 		ASG,
		per_assignment_status_types 	AST,
		hr_soft_coding_keyflex		SCL
  WHERE		ASG.assignment_id		= p_asst_id
  AND  		ASG.effective_start_date       <= p_period_start
  AND   	ASG.effective_end_date 	       >= p_period_start
  AND   	ASG.effective_end_date 		< p_period_end
  AND		AST.assignment_status_type_id 	= ASG.assignment_status_type_id
  AND		AST.per_system_status 		= 'ACTIVE_ASSIGN'
  AND		SCL.soft_coding_keyflex_id	= ASG.soft_coding_keyflex_id
  AND		SCL.segment1			= TO_CHAR(p_tax_unit_id)
  AND		SCL.enabled_flag		= 'Y' );

     hr_utility.trace('ASGMPE Changes found');
     hr_utility.trace('Need to prorate b/c of ASGMPE');
     hr_utility.trace('Set l_mid_period_asg_change to TRUE I');

     l_mid_period_asg_change := TRUE;

     hr_utility.set_location('calculate_period_earnings', 56);
     hr_utility.trace('Look for EEVMPE changes');

  BEGIN /* EEVMPE check - maybe pick*/

  select 1 INTO l_eev_info_changes
    from dual
   where exists (
    SELECT	1
    FROM	pay_element_entry_values_f	EEV
    WHERE	EEV.element_entry_id 		= p_ele_entry_id
    AND 	EEV.input_value_id+0 		= v_inpval_id
    AND ( ( 	EEV.effective_start_date       <= p_period_start
        AND 	EEV.effective_end_date 	       >= p_period_start
        AND 	EEV.effective_end_date 	        < p_period_end)
    OR (   EEV.effective_start_date between p_period_start and p_period_end)
    ) );



     hr_utility.trace('EEVMPE changes found after ASGMPE');

  EXCEPTION

    WHEN NO_DATA_FOUND THEN
      l_eev_info_changes := 0;

     hr_utility.trace('From EXCEPTION  ASGMPE changes found No EEVMPE changes');

  END; /* EEV1 check*/

EXCEPTION

  WHEN NO_DATA_FOUND THEN

    l_asg_info_changes := 0;
    hr_utility.trace('From EXCEPTION No ASGMPE changes, nor EEVMPE changes');

END;  /* ASGMPE check*/

/* ************************************************ */

IF l_asg_info_changes = 0 THEN /* Check ASGMPS */

  hr_utility.trace(' Into l_asg_info_changes = 0');
  hr_utility.trace('UDFS looking for ASGMPS changes');
  hr_utility.set_location('calculate_period_earnings', 56);

  BEGIN /*  ASGMPS changes */

   select 1 INTO l_asg_info_changes
     from dual
    where exists (
    SELECT	1
    FROM	per_assignments_f 		ASG,
		per_assignment_status_types 	AST,
		hr_soft_coding_keyflex		SCL
    WHERE	ASG.assignment_id		= p_asst_id
    AND 	ASG.effective_start_date        > p_period_start
    AND   	ASG.effective_start_date       <= p_period_end
    AND		AST.assignment_status_type_id 	= ASG.assignment_status_type_id
    AND		AST.per_system_status 		= 'ACTIVE_ASSIGN'
    AND		SCL.soft_coding_keyflex_id	= ASG.soft_coding_keyflex_id
    AND		SCL.segment1			= TO_CHAR(p_tax_unit_id)
    AND		SCL.enabled_flag		= 'Y');

    l_mid_period_asg_change := TRUE;

    hr_utility.trace('Need to prorate for ASGMPS changes');
    hr_utility.set_location('calculate_period_earnings', 57);

    BEGIN /* EEVMPE changes ASGMPS */

  select 1 INTO l_eev_info_changes
    from dual
   where exists (
    SELECT      1
    FROM        pay_element_entry_values_f      EEV
    WHERE       EEV.element_entry_id            = p_ele_entry_id
    AND         EEV.input_value_id+0            = v_inpval_id
    AND ( (     EEV.effective_start_date       <= p_period_start
        AND     EEV.effective_end_date         >= p_period_start
        AND     EEV.effective_end_date          < p_period_end)
    --OR (   EEV.effective_start_date between p_period_start and p_period_end)
     ) );


       hr_utility.trace('Need to prorate EEVMPS changes after ASGMPS ');

    EXCEPTION

      WHEN NO_DATA_FOUND THEN

        l_eev_info_changes := 0;

        hr_utility.trace('From EXCEPTIION No EEVMPE changes');

    END; /* EEVMPE changes */

  EXCEPTION

    WHEN NO_DATA_FOUND THEN

      l_asg_info_changes := 0;

      hr_utility.trace('From EXCEPTION no changes due to ASGMPS or EEVMPE');

  END; /* ASGMPS changes */

END IF; /* Check ASGMPS */

/* *************************************************** */

IF l_asg_info_changes = 0 THEN  /* ASGMPE=0 and ASGMPS=0 */

  BEGIN /* Check for EEVMPE changes */

    hr_utility.set_location('calculate_period_earnings', 58);
    hr_utility.trace('Check for EEVMPE changes nevertheless');

   select 1 INTO l_eev_info_changes
     from dual
    where exists (
      SELECT	1
      FROM	pay_element_entry_values_f	EEV
      WHERE	EEV.element_entry_id 		= p_ele_entry_id
      AND	EEV.input_value_id+0 		= v_inpval_id
      AND	EEV.effective_start_date       <= p_period_start
      AND	EEV.effective_end_date 	       >= p_period_start
      AND	EEV.effective_end_date 	        < p_period_end);

     hr_utility.trace('Proration due to  EEVMPE changes');


  EXCEPTION

    WHEN NO_DATA_FOUND THEN

         hr_utility.trace('ASG AND EEV changes DO NOT EXIST EXCEPT ');

/* Bug 9386700
      -- Either there are no changes to an Active Assignment OR
      -- the assignment was not active at all this period.
      -- Check assignment status of current asg record.

     hr_utility.trace(' Check assignment status of current asg record');

      SELECT	AST.per_system_status
      INTO	v_asg_status
      FROM	per_assignments_f 		ASG,
		per_assignment_status_types 	AST,
		hr_soft_coding_keyflex		SCL
      WHERE	ASG.assignment_id		= p_asst_id
      AND  	p_period_start		BETWEEN ASG.effective_start_date
      					AND   	ASG.effective_end_date
      AND	AST.assignment_status_type_id 	= ASG.assignment_status_type_id
      AND	SCL.soft_coding_keyflex_id	= ASG.soft_coding_keyflex_id
      AND	SCL.segment1			= TO_CHAR(p_tax_unit_id)
      AND	SCL.enabled_flag		= 'Y';

      IF v_asg_status <> 'ACTIVE_ASSIGN' THEN

        hr_utility.trace(' Asg not active');
        v_period_earn := 0;
        p_actual_hours_worked := 0;

      END IF;

End Bug 9386700  */

       hr_utility.trace('Chk for vac pay since no ASG EEV changes to prorate' );

       p_vac_pay := vacation_pay(p_vac_hours	=> p_vac_hours_worked,
				p_asg_id	=> p_asst_id,
				p_eff_date	=> p_period_end,
				p_curr_rate	=> p_ass_hrly_figure);

       hr_utility.trace('p_vac_pay ='||p_vac_pay);
       p_sick_pay := sick_pay(	p_sick_hours	=> p_sick_hours_worked,
				p_asg_id	=> p_asst_id,
				p_eff_date	=> p_period_end,
				p_curr_rate	=> p_ass_hrly_figure);


      hr_utility.trace('p_sick_pay ='||p_sick_pay);

      p_actual_hours_worked := ROUND(p_actual_hours_worked, 3);
      RETURN v_period_earn;

  END;  /* Check for EEVMPE changes */

END IF; /* ASGMPE=0 ASGMPS =0 */

/* **************************************************************
 If code reaches here, then we're prorating for one reason or the other.
***************************************************************** */


IF (l_asg_info_changes > 0) AND (l_eev_info_changes = 0) THEN /*ASG =1 EEV =0*/


/* ************** ONLY ASG CHANGES START ****  */

  p_actual_hours_worked := 0;
  hr_utility.set_location('calculate_period_earnings', 70);
  hr_utility.trace('UDFS ONLY ASG CHANGES START');

  BEGIN /* Get Asg Details ASGMPE */

    hr_utility.trace('Get Asg details - ASGMPE');
    hr_utility.set_location('calculate_period_earnings', 71);

    SELECT	GREATEST(ASG.effective_start_date, p_period_start),
		ASG.effective_end_date,
		NVL(ASG.NORMAL_HOURS, 0),
		NVL(HRL.meaning, 'NOT ENTERED'),
		NVL(SCL.segment4, 'NOT ENTERED')
    INTO	v_range_start,
		v_range_end,
		v_asst_std_hrs,
		v_asst_std_freq,
		v_work_schedule
    FROM	per_assignments_f 		ASG,
		per_assignment_status_types 	AST,
		hr_soft_coding_keyflex		SCL,
		hr_lookups			HRL
    WHERE	ASG.assignment_id		= p_asst_id
    AND		ASG.business_group_id + 0	= p_bus_grp_id
    AND  	ASG.effective_start_date       <= p_period_start
    AND   	ASG.effective_end_date 	       >= p_period_start
    AND   	ASG.effective_end_date 		< p_period_end
    AND		AST.assignment_status_type_id 	= ASG.assignment_status_type_id
    AND		AST.per_system_status 		= 'ACTIVE_ASSIGN'
    AND		SCL.soft_coding_keyflex_id	= ASG.soft_coding_keyflex_id
    AND		SCL.segment1			= TO_CHAR(p_tax_unit_id)
    AND		SCL.enabled_flag		= 'Y'
    AND		HRL.lookup_code(+)		= ASG.frequency
    AND		HRL.lookup_type(+)		= 'FREQUENCY';


    hr_utility.trace('If ASGMPE Details succ. then Calling Prorate_Earnings');
    hr_utility.set_location('calculate_period_earnings', 72);
    v_prorated_earnings := v_prorated_earnings +
			    Prorate_Earnings (
				p_bg_id			    => p_bus_grp_id,
				p_asg_hrly_rate 	=> p_ass_hrly_figure,
				p_range_start_date	=> v_range_start,
				p_range_end_date	=> v_range_end,
				p_act_hrs_worked    => p_actual_hours_worked);

    hr_utility.trace('After Calling Prorate_Earnings');

  EXCEPTION WHEN NO_DATA_FOUND THEN

    NULL;

  END; /* Get Asg Details */


  hr_utility.trace('ONLY ASG , select MULTIASG');
  hr_utility.set_location('calculate_period_earnings', 77);

  OPEN get_asst_chgs;	-- SELECT (ASG2 MULTIASG)
  LOOP

    FETCH get_asst_chgs
    INTO  v_range_start,
	  v_range_end,
	  v_asst_std_hrs,
	  v_asst_std_freq,
	  v_work_schedule;
    EXIT WHEN get_asst_chgs%NOTFOUND;
    hr_utility.set_location('calculate_period_earnings', 79);


    hr_utility.trace('ONLY ASG Calling Prorate_Earning as MULTIASG successful');

    v_prorated_earnings := v_prorated_earnings +
			     Prorate_Earnings (
				p_bg_id			=> p_bus_grp_id,
				p_asg_hrly_rate	 	=> p_ass_hrly_figure,
				p_range_start_date	=> v_range_start,
				p_range_end_date	=> v_range_end,
         		        p_act_hrs_worked     => p_actual_hours_worked);


    hr_utility.trace('After calling  Prorate_Earnings from MULTIASG');

  END LOOP;

  CLOSE get_asst_chgs;

  BEGIN /* END_SPAN_RECORD */

  hr_utility.set_location('calculate_period_earnings', 89);
  hr_utility.trace('ONLY ASG , select END_SPAN_RECORD');

  SELECT	ASG.effective_start_date,
 		LEAST(ASG.effective_end_date, p_period_end),
		NVL(ASG.normal_hours, 0),
		NVL(HRL.meaning, 'NOT ENTERED'),
		NVL(SCL.segment4, 'NOT ENTERED')
  INTO		v_range_start,
		v_range_end,
		v_asst_std_hrs,
		v_asst_std_freq,
		v_work_schedule
  FROM		hr_soft_coding_keyflex		SCL,
		per_assignment_status_types 	AST,
		per_assignments_f 		ASG,
		hr_lookups			HRL
  WHERE		ASG.assignment_id		= p_asst_id
  AND		ASG.business_group_id + 0	= p_bus_grp_id
  AND  		ASG.effective_start_date 	> p_period_start
  AND  		ASG.effective_start_date       <= p_period_end
  AND   	ASG.effective_end_date 		> p_period_end
  AND		AST.assignment_status_type_id	= ASG.assignment_status_type_id
  AND		AST.per_system_status 		= 'ACTIVE_ASSIGN'
  AND		SCL.soft_coding_keyflex_id	= ASG.soft_coding_keyflex_id
  AND		SCL.segment1			= TO_CHAR(p_tax_unit_id)
  AND		SCL.enabled_flag		= 'Y'
  AND		HRL.lookup_code(+)		= ASG.frequency
  AND		HRL.lookup_type(+)		= 'FREQUENCY';

  hr_utility.trace('Calling Prorate_Earnings for ONLY ASG END_SPAN_RECORD');
  hr_utility.set_location('calculate_period_earnings', 91);
  v_prorated_earnings := v_prorated_earnings +
			     Prorate_Earnings (
				p_bg_id			=> p_bus_grp_id,
				p_asg_hrly_rate 	=> p_ass_hrly_figure,
				p_range_start_date	=> v_range_start,
				p_range_end_date	=> v_range_end,
				p_act_hrs_worked     => p_actual_hours_worked);


  hr_utility.trace('Calling Vacation Pay as END_SPAN succ');
  hr_utility.set_location('calculate_period_earnings', 101);

  p_vac_pay := vacation_pay(	p_vac_hours	=> p_vac_hours_worked,
				p_asg_id	=> p_asst_id,
				p_eff_date	=> p_period_end,
				p_curr_rate	=> p_ass_hrly_figure);

  hr_utility.trace('Calling Sick Pay as ASG3 succ');

  p_sick_pay := sick_pay(	p_sick_hours	=> p_sick_hours_worked,
				p_asg_id	=> p_asst_id,
				p_eff_date	=> p_period_end,
				p_curr_rate	=> p_ass_hrly_figure);


  p_actual_hours_worked := ROUND(p_actual_hours_worked, 3);
  RETURN v_prorated_earnings;

  EXCEPTION WHEN NO_DATA_FOUND THEN
    hr_utility.set_location('calculate_period_earnings', 102);
    hr_utility.trace('Exception of ASG_MID_START_LAST_SPAN_END_DT');

    p_vac_pay := vacation_pay(	p_vac_hours	=> p_vac_hours_worked,
				p_asg_id	=> p_asst_id,
				p_eff_date	=> p_period_end,
				p_curr_rate	=> p_ass_hrly_figure);

    hr_utility.trace('Calling Sick Pay as ASG3 not succ');
    p_sick_pay := sick_pay(	p_sick_hours	=> p_sick_hours_worked,
				p_asg_id	=> p_asst_id,
				p_eff_date	=> p_period_end,
				p_curr_rate	=> p_ass_hrly_figure);


    p_actual_hours_worked := ROUND(p_actual_hours_worked, 3);
    RETURN v_prorated_earnings;

  END; /* ASG_MID_START_LAST_SPAN_END_DT */

/* ************** ONLY ASG CHANGES END  ****  */


ELSIF (l_asg_info_changes = 0) AND (l_eev_info_changes > 0) THEN

/* ******************* ONLY EEV CHANGES START ****** */

  hr_utility.trace(' Only EEV changes exist');
  hr_utility.set_location('calculate_period_earnings', 103);
  p_actual_hours_worked := 0;


  hr_utility.trace('Calling Prorate_EEV');

  v_prorated_earnings := v_prorated_earnings +
		         Prorate_EEV (
				p_bus_group_id		=> p_bus_grp_id,
				p_pay_id		=> p_payroll_id,
				p_pay_basis		=> p_pay_basis,
				p_hrly_rate 		=> v_curr_hrly_rate,
				p_range_start_date  	=> p_period_start,
				p_range_end_date    	=> p_period_end,
				p_actual_hrs_worked => p_actual_hours_worked,
				p_element_entry_id  => p_ele_entry_id,
				p_inpval_id	    => v_inpval_id);

  hr_utility.trace('After Calling Prorate_EEV');
  hr_utility.set_location('calculate_period_earnings', 127);

  hr_utility.trace('Calling vacation_pay');

  p_vac_pay := vacation_pay(	p_vac_hours	=> p_vac_hours_worked,
				p_asg_id	=> p_asst_id,
				p_eff_date	=> p_period_end,
				p_curr_rate	=> p_ass_hrly_figure);

  hr_utility.trace('Calling sick_pay');

  p_sick_pay := sick_pay(	p_sick_hours	=> p_sick_hours_worked,
				p_asg_id	=> p_asst_id,
				p_eff_date	=> p_period_end,
				p_curr_rate	=> p_ass_hrly_figure);


  p_actual_hours_worked := ROUND(p_actual_hours_worked, 3);
  RETURN v_prorated_earnings;

/* ******************* ONLY EEV CHANGES END ****** */

ELSE  /*BOTH ASG AND EEV CHANGES =0*/

/* ******************* BOTH ASG AND EEV CHANGES START ************ */


  hr_utility.trace('UDFS BOTH ASG and EEV chages exist');


  p_actual_hours_worked := 0;


 BEGIN /* Latest Screen Entry Value */

    hr_utility.trace('BOTH ASG Get latest screen entry value for EEVMPE');
    hr_utility.set_location('calculate_period_earnings', 128);

  SELECT	fnd_number.canonical_to_number(EEV.screen_entry_value)
  INTO		v_earnings_entry
  FROM		pay_element_entry_values_f	EEV
  WHERE		EEV.element_entry_id 		= p_ele_entry_id
  AND 		EEV.input_value_id 		= v_inpval_id
  AND		p_period_start between EEV.effective_start_date
                               AND EEV.effective_end_date;
/*4750302
  AND		EEV.effective_start_date       <= p_period_start
  AND  		EEV.effective_end_date 	       >  p_period_start;
*/
  --AND 	EEV.effective_end_date 	      <  p_period_end

  hr_utility.trace('BOTH ASG Get ASGMPE ');

  SELECT	GREATEST(ASG.effective_start_date, p_period_start),
		ASG.effective_end_date,
		NVL(ASG.NORMAL_HOURS, 0),
		NVL(HRL.meaning, 'NOT ENTERED'),
		NVL(SCL.segment4, 'NOT ENTERED')
  INTO		v_range_start,
		v_range_end,
		v_asst_std_hrs,
		v_asst_std_freq,
		v_work_schedule
  FROM		per_assignments_f 		ASG,
		per_assignment_status_types 	AST,
		hr_soft_coding_keyflex		SCL,
		hr_lookups			HRL
  WHERE	ASG.assignment_id		= p_asst_id
  AND		ASG.business_group_id + 0	= p_bus_grp_id
  AND  		ASG.effective_start_date       	<= p_period_start
    AND   	ASG.effective_end_date 	       	>= p_period_start
    AND   	ASG.effective_end_date 		< p_period_end
    AND		AST.assignment_status_type_id 	= ASG.assignment_status_type_id
    AND		AST.per_system_status 		= 'ACTIVE_ASSIGN'
    AND		SCL.soft_coding_keyflex_id	= ASG.soft_coding_keyflex_id
    AND		SCL.segment1			= TO_CHAR(p_tax_unit_id)
    AND		SCL.enabled_flag		= 'Y'
    AND		HRL.lookup_code(+)		= ASG.frequency
    AND		HRL.lookup_type(+)		= 'FREQUENCY';

  hr_utility.trace('Calling Convert_Period_Type from ASGMPE');
  hr_utility.set_location('v_earnings_entry='||v_earnings_entry, 129);

  v_curr_hrly_rate := Convert_Period_Type(p_bus_grp_id
                                        ,p_asst_id
                                	    ,p_payroll_id
                                        ,p_ele_entry_id
                                        ,p_date_earned
                                        ,p_assignment_action_id
                                        ,p_period_start  -- period start date
                                        ,p_period_end    -- period end date
                                        ,v_earnings_entry   -- p_figure, salary amount
                                        ,v_pay_basis        -- p_from freq, salary basis
                                        ,'HOURLY');         -- p_to_freq
                 /*Convert_Period_Type(	p_bus_grp_id,
						p_payroll_id,
						v_work_schedule,
						v_asst_std_hrs,
						v_earnings_entry,
						v_pay_basis,
						'HOURLY',
						p_period_start,
						p_period_end,
						v_asst_std_freq);*/

    hr_utility.trace('Select app. EEVMPE again after range is determined');
    hr_utility.set_location('calculate_period_earnings', 130);

    SELECT	COUNT(EEV.element_entry_value_id)
    INTO	l_eev_info_changes
    FROM	pay_element_entry_values_f	EEV
    WHERE	EEV.element_entry_id 		= p_ele_entry_id
    AND		EEV.input_value_id 		= v_inpval_id
    AND		EEV.effective_start_date       <= v_range_start
    AND		EEV.effective_end_date 	       >= v_range_start
    AND		EEV.effective_end_date 	        < v_range_end;

    IF l_eev_info_changes = 0 THEN


      hr_utility.trace('NO EEVMPE changes');
      hr_utility.set_location('calculate_period_earnings', 132);

      SELECT		fnd_number.canonical_to_number(EEV.screen_entry_value)
      INTO		v_earnings_entry
      FROM		pay_element_entry_values_f	EEV
      WHERE		EEV.element_entry_id 		= p_ele_entry_id
      AND 		EEV.input_value_id 		= v_inpval_id
      AND		v_range_end 	BETWEEN EEV.effective_start_date
					    AND EEV.effective_end_date;

      hr_utility.trace('Calling Convert_Period_Type');
      hr_utility.set_location('calculate_period_earnings', 134);

      v_curr_hrly_rate := Convert_Period_Type(p_bus_grp_id
                                        ,p_asst_id
                                	    ,p_payroll_id
                                        ,p_ele_entry_id
                                        ,p_date_earned
                                        ,p_assignment_action_id
                                        ,p_period_start  -- period start date
                                        ,p_period_end    -- period end date
                                        ,v_earnings_entry   -- p_figure, salary amount
                                        ,v_pay_basis        -- p_from freq, salary basis
                                        ,'HOURLY');         -- p_to_freq
      /*Convert_Period_Type(	p_bus_grp_id,
						p_payroll_id,
						v_work_schedule,
						v_asst_std_hrs,
						v_earnings_entry,
						v_pay_basis,
						'HOURLY',
						p_period_start,
						p_period_end,
						v_asst_std_freq);*/

      hr_utility.trace('Calling Prorate_Earnings');
      hr_utility.set_location('calculate_period_earnings', 135);

      v_prorated_earnings := v_prorated_earnings +
			     Prorate_Earnings (
				p_bg_id			=> p_bus_grp_id,
				p_asg_hrly_rate 	=> v_curr_hrly_rate,
				p_range_start_date	=> v_range_start,
				p_range_end_date	=> v_range_end,
				p_act_hrs_worked      	=> p_actual_hours_worked);

    hr_utility.set_location('calculate_period_earnings', 137);

    ELSE
      -- Do proration for this ASG range by EEV !

      hr_utility.trace('EEVMPE True');
      hr_utility.trace('Do proration for this ASG range by EEV');
      hr_utility.set_location('calculate_period_earnings', 139);

      hr_utility.trace('Calling Prorate_EEV');

      v_prorated_earnings := v_prorated_earnings +
			   Prorate_EEV (
				p_bus_group_id		=> p_bus_grp_id,
				p_pay_id		=> p_payroll_id,
				p_pay_basis		=> v_pay_basis,
				p_hrly_rate 		=> v_curr_hrly_rate,
				p_range_start_date  	=> v_range_start,
				p_range_end_date    	=> v_range_end,
				p_actual_hrs_worked => p_actual_hours_worked,
				p_element_entry_id  => p_ele_entry_id,
				p_inpval_id	    => v_inpval_id);
     hr_utility.set_location('calculate_period_earnings', 140);

    END IF; -- EEV info changes

  EXCEPTION WHEN NO_DATA_FOUND THEN
    NULL;

 END; /* Latest Screen Entry Value */

  hr_utility.trace(' BOTH ASG - SELECT ASG_MULTI_WITHIN');
  hr_utility.set_location('calculate_period_earnings', 141);

  OPEN get_asst_chgs;	-- SELECT ( ASG_MULTI_WITHIN)
  LOOP

    FETCH get_asst_chgs
    INTO  v_range_start,
	  v_range_end,
	  v_asst_std_hrs,
	  v_asst_std_freq,
	  v_work_schedule;
    EXIT WHEN get_asst_chgs%NOTFOUND;

    --EEV_BEFORE_RANGE_END
    hr_utility.trace('BOTH ASG MULTI select app. EEVMPE again after range det.');
    hr_utility.set_location('calculate_period_earnings', 145);

    SELECT	COUNT(EEV.element_entry_value_id)
    INTO	l_eev_info_changes
    FROM	pay_element_entry_values_f	EEV
    WHERE	EEV.element_entry_id 		= p_ele_entry_id
    AND 	EEV.input_value_id 		= v_inpval_id
    AND		EEV.effective_start_date       <= v_range_start
    AND  	EEV.effective_end_date 	       >= v_range_start
    AND  	EEV.effective_end_date 	        < v_range_end;

    IF l_eev_info_changes = 0 THEN /* IF l_eev_info_changes = 0 */

      -- EEV_FOR_CURR_RANGE_END

      hr_utility.trace('BOTH ASG - EEV false');
      SELECT		fnd_number.canonical_to_number(EEV.screen_entry_value)
      INTO		v_earnings_entry
      FROM		pay_element_entry_values_f	EEV
      WHERE		EEV.element_entry_id 		= p_ele_entry_id
      AND 		EEV.input_value_id 		= v_inpval_id
      AND		v_range_end 	BETWEEN EEV.effective_start_date
					    AND EEV.effective_end_date;
      hr_utility.set_location('calculate_period_earnings', 150);
      v_curr_hrly_rate := Convert_Period_Type(p_bus_grp_id
                                        ,p_asst_id
                                	    ,p_payroll_id
                                        ,p_ele_entry_id
                                        ,p_date_earned
                                        ,p_assignment_action_id
                                        ,p_period_start  -- period start date
                                        ,p_period_end    -- period end date
                                        ,v_earnings_entry   -- p_figure, salary amount
                                        ,v_pay_basis        -- p_from freq, salary basis
                                        ,'HOURLY');         -- p_to_freq
       /*Convert_Period_Type(	p_bus_grp_id,
						p_payroll_id,
						v_work_schedule,
						v_asst_std_hrs,
						v_earnings_entry,
						v_pay_basis,
						'HOURLY',
						p_period_start,
						p_period_end,
						v_asst_std_freq);*/

      v_prorated_earnings := v_prorated_earnings +
			     Prorate_Earnings (
				p_bg_id			=> p_bus_grp_id,
				p_asg_hrly_rate 	=> v_curr_hrly_rate,
				p_range_start_date	=> v_range_start,
				p_range_end_date	=> v_range_end,
				p_act_hrs_worked       	=> p_actual_hours_worked);

     hr_utility.set_location('calculate_period_earnings', 155);
    ELSE
      hr_utility.trace('BOTH ASG - EEV true');
      v_prorated_earnings := v_prorated_earnings +
	  		     Prorate_EEV (
				p_bus_group_id		=> p_bus_grp_id,
				p_pay_id		=> p_payroll_id,
				p_pay_basis		=> v_pay_basis,
				p_hrly_rate 		=> v_curr_hrly_rate,
				p_range_start_date  	=> v_range_start,
				p_range_end_date    	=> v_range_end,
				p_actual_hrs_worked => p_actual_hours_worked,
				p_element_entry_id  => p_ele_entry_id,
				p_inpval_id	    => v_inpval_id);

    END IF; /* IF l_eev_info_changes = 0 */

  END LOOP;

  CLOSE get_asst_chgs;


  BEGIN /*  SPAN_RECORD */

  hr_utility.trace('BOTH ASG SELECT END_SPAN_RECORD');
  hr_utility.set_location('calculate_period_earnings', 160);

  SELECT	ASG.effective_start_date,
 		LEAST(ASG.effective_end_date, p_period_end),
		NVL(ASG.normal_hours, 0),
		NVL(HRL.meaning, 'NOT ENTERED'),
		NVL(SCL.segment4, 'NOT ENTERED')
  INTO		v_range_start,
		v_range_end,
		v_asst_std_hrs,
		v_asst_std_freq,
		v_work_schedule
  FROM		hr_soft_coding_keyflex		SCL,
		per_assignment_status_types 	AST,
		per_assignments_f 		ASG,
		hr_lookups			HRL
  WHERE	ASG.assignment_id		= p_asst_id
  AND		ASG.business_group_id + 0	= p_bus_grp_id
  AND  		ASG.effective_start_date 	> p_period_start
  AND  		ASG.effective_start_date	<= p_period_end
  AND   		ASG.effective_end_date 	> p_period_end
  AND		AST.assignment_status_type_id	= ASG.assignment_status_type_id
  AND		AST.per_system_status 	= 'ACTIVE_ASSIGN'
  AND		SCL.soft_coding_keyflex_id	= ASG.soft_coding_keyflex_id
  AND		SCL.segment1			= TO_CHAR(p_tax_unit_id)
  AND		SCL.enabled_flag		= 'Y'
  AND		HRL.lookup_code(+)		= ASG.frequency
  AND		HRL.lookup_type(+)		= 'FREQUENCY';



  hr_utility.trace('SELECT EEVMPE');

  SELECT	COUNT(EEV.element_entry_value_id)
  INTO		l_eev_info_changes
  FROM		pay_element_entry_values_f	EEV
  WHERE		EEV.element_entry_id 		= p_ele_entry_id
  AND 		EEV.input_value_id 		= v_inpval_id
  AND		EEV.effective_start_date       <= v_range_start
  AND  		EEV.effective_end_date 	       >= v_range_start
  AND  		EEV.effective_end_date 	        < v_range_end;

  IF l_eev_info_changes = 0 THEN

     hr_utility.trace('BOTH ASG SPAN - SELECT EEV_FOR_CURR_RANGE_END');
     hr_utility.set_location('calculate_period_earnings', 165);

    SELECT	fnd_number.canonical_to_number(EEV.screen_entry_value)
    INTO	v_earnings_entry
    FROM	pay_element_entry_values_f	EEV
    WHERE	EEV.element_entry_id 		= p_ele_entry_id
    AND 	EEV.input_value_id 		= v_inpval_id
    AND		v_range_end BETWEEN EEV.effective_start_date
			        AND EEV.effective_end_date;

    v_curr_hrly_rate := Convert_Period_Type(p_bus_grp_id
                                        ,p_asst_id
                                	    ,p_payroll_id
                                        ,p_ele_entry_id
                                        ,p_date_earned
                                        ,p_assignment_action_id
                                        ,p_period_start  -- period start date
                                        ,p_period_end    -- period end date
                                        ,v_earnings_entry   -- p_figure, salary amount
                                        ,v_pay_basis        -- p_from freq, salary basis
                                        ,'HOURLY');         -- p_to_freq
      /*Convert_Period_Type(	p_bus_grp_id,
						p_payroll_id,
						p_work_schedule,
						p_asst_std_hrs,
						v_earnings_entry,
						v_pay_basis,
						'HOURLY',
						p_period_start,
						p_period_end,
						v_asst_std_freq);*/

    v_prorated_earnings := v_prorated_earnings +
			     Prorate_Earnings (
				p_bg_id			=> p_bus_grp_id,
				p_asg_hrly_rate 	=> v_curr_hrly_rate,
				p_range_start_date	=> v_range_start,
				p_range_end_date	=> v_range_end,
				p_act_hrs_worked       	=> p_actual_hours_worked);

  hr_utility.set_location('calculate_period_earnings', 170);
  ELSE /* EEV succ */

    hr_utility.trace('BOTH ASG END_SPAN - EEV true');
    v_prorated_earnings := v_prorated_earnings +
	  		     Prorate_EEV (
				p_bus_group_id		=> p_bus_grp_id,
				p_pay_id		=> p_payroll_id,
				p_pay_basis		=> v_pay_basis,
				p_hrly_rate 		=> v_curr_hrly_rate,
				p_range_start_date  	=> v_range_start,
				p_range_end_date    	=> v_range_end,
				p_actual_hrs_worked => p_actual_hours_worked,
				p_element_entry_id  => p_ele_entry_id,
				p_inpval_id	    => v_inpval_id);
  hr_utility.set_location('calculate_period_earnings', 175);
  END IF;


  p_vac_pay := vacation_pay(	p_vac_hours	=> p_vac_hours_worked,
				p_asg_id	=> p_asst_id,
				p_eff_date	=> p_period_end,
				p_curr_rate	=> p_ass_hrly_figure);
  hr_utility.set_location('calculate_period_earnings', 180);

  p_sick_pay := sick_pay(	p_sick_hours	=> p_sick_hours_worked,
				p_asg_id	=> p_asst_id,
				p_eff_date	=> p_period_end,
				p_curr_rate	=> p_ass_hrly_figure);
  hr_utility.set_location('calculate_period_earnings', 185);

  p_actual_hours_worked := ROUND(p_actual_hours_worked, 3);
  RETURN v_prorated_earnings;

  EXCEPTION WHEN NO_DATA_FOUND THEN

    p_vac_pay := vacation_pay(	p_vac_hours	=> p_vac_hours_worked,
				p_asg_id	=> p_asst_id,
				p_eff_date	=> p_period_end,
				p_curr_rate	=> p_ass_hrly_figure);

    p_sick_pay := sick_pay(	p_sick_hours	=> p_sick_hours_worked,
				p_asg_id	=> p_asst_id,
				p_eff_date	=> p_period_end,
				p_curr_rate	=> p_ass_hrly_figure);

    p_actual_hours_worked := ROUND(p_actual_hours_worked, 3);
    RETURN v_prorated_earnings;

  END;


/* ******************* BOTH ASG AND EEV CHANGES ENDS ************ */

END IF; /*END IF OF BOTH ASG AND EEV CHANGES */

EXCEPTION
  WHEN NO_DATA_FOUND THEN

    p_vac_pay := vacation_pay(	p_vac_hours	=> p_vac_hours_worked,
				p_asg_id	=> p_asst_id,
				p_eff_date	=> p_period_end,
				p_curr_rate	=> p_ass_hrly_figure);

    p_sick_pay := sick_pay(	p_sick_hours	=> p_sick_hours_worked,
				p_asg_id	=> p_asst_id,
				p_eff_date	=> p_period_end,
				p_curr_rate	=> p_ass_hrly_figure);


    p_actual_hours_worked := ROUND(p_actual_hours_worked, 3);

    RETURN v_prorated_earnings;

END Calculate_Period_Earnings;

-- **********************************************************************

-- **********************************************************************
-- converts the amount from one salary basis to another e.g. montly to hourly

-- Calculates hourly rate
FUNCTION get_hourly_rate(
	 p_bg		            IN NUMBER -- context
        ,p_assignment_id        IN NUMBER -- context
   	,p_payroll_id		    IN NUMBER -- context
        ,p_element_entry_id     IN NUMBER -- context
        ,p_date_earned          IN DATE -- context
        ,p_assignment_action_id IN NUMBER )-- context
RETURN NUMBER IS

CURSOR get_period_dates (l_date_earned date,
                         l_payroll_id number) IS
   select start_date, end_date
   from per_time_periods   pt
   where  payroll_id = l_payroll_id
   and l_date_earned between start_date and end_date;

CURSOR get_salary_basis(l_date_earned date,
                        l_assignment_id number) IS
   /* using lookup_code to avoid the translation issue*/

   select /*hr_general.decode_lookup('PAY_BASIS',BASES.pay_basis)*/
            BASES.pay_basis
          , INPUTV.input_value_id
   from
           per_all_assignments_f                  ASSIGN
   ,       per_pay_bases                          BASES
   ,       pay_input_values_f                     INPUTV
   ,       pay_element_types_f                    ETYPE
   ,       pay_rates                              RATE
   where   l_date_earned BETWEEN ASSIGN.effective_start_date
                      AND ASSIGN.effective_end_date
   and     ASSIGN.assignment_id                 = l_assignment_id
   and     BASES.pay_basis_id                (+)= ASSIGN.pay_basis_id
   and     INPUTV.input_value_id             (+)= BASES.input_value_id
   and     l_date_earned  between nvl (INPUTV.effective_start_date, l_date_earned)
                 and nvl (INPUTV.effective_end_date, l_date_earned)
   and     ETYPE.element_type_id             (+)= INPUTV.element_type_id
   and     RATE.rate_id                      (+)= BASES.rate_id
   and     l_date_earned  between nvl (ETYPE.effective_start_date, l_date_earned)
                 and nvl (ETYPE.effective_end_date, l_date_earned)  ;

CURSOR get_salary (l_date_earned date,
                   l_assignment_id number,
                   l_input_value_id number) IS
select fnd_number.canonical_to_number (EEV.screen_entry_value)
from    pay_element_entries_f                  EE
,       pay_element_entry_values_f             EEV
where   EEV.input_value_id                   = l_input_value_id
and     l_date_earned  BETWEEN EEV.effective_start_date
                       AND EEV.effective_end_date
and     EE.assignment_id                     = l_assignment_id
and     EE.entry_type = 'E'
and     l_date_earned BETWEEN EE.effective_start_date
                 AND EE.effective_end_date
and     EEV.element_entry_id                 = EE.element_entry_id;


CURSOR get_termination_date(l_date_earned date,
                            l_assignment_id number) IS
       select actual_termination_date
       from   per_assignments_f      paf,
              per_periods_of_service pps
       where  paf.assignment_id        = l_assignment_id
       and    l_date_earned between paf.effective_start_date and
                                         paf.effective_end_date
       and    paf.PERIOD_OF_SERVICE_ID = pps.period_of_service_id;

l_period_start_date date;
l_period_end_date   date;
l_salary_basis      VARCHAR2(200);
l_input_value_id    NUMBER;
l_asg_salary        NUMBER;
l_hourly_rate       NUMBER;
l_date_used         date;
l_termination_date  date;


BEGIN

     hr_utility.trace('  Entered  get_hourly_rate ');
     --hr_utility.trace_on(null,'wrkschd');


     hr_utility.trace('assignment_action_id=' || p_assignment_action_id);
     hr_utility.trace('assignment_id='        || p_assignment_id);
     hr_utility.trace('business_group_id='    || p_bg);
     hr_utility.trace('element_entry_id='     || p_element_entry_id);
     hr_utility.trace('p_date_earned '||p_date_earned);
     hr_utility.trace('p_payroll_id: '||p_payroll_id);

    l_hourly_rate := 0;

    OPEN get_period_dates(p_date_earned,p_payroll_id);
    FETCH get_period_dates INTO l_period_start_date,l_period_end_date;
    CLOSE  get_period_dates;


    hr_utility.trace('l_period_start_date ='  || l_period_start_date);
    hr_utility.trace('l_period_end_date ='    || l_period_end_date);

    OPEN get_salary_basis(p_date_earned, p_assignment_id);
    FETCH get_salary_basis INTO l_salary_basis, l_input_value_id;
    CLOSE get_salary_basis;

    hr_utility.trace('l_salary_basis ='  || l_salary_basis);
    hr_utility.trace('l_input_value_id ='    || l_input_value_id);

    OPEN get_salary(p_date_earned, p_assignment_id,l_input_value_id);
    FETCH get_salary INTO l_asg_salary;
    CLOSE get_salary;

    IF l_asg_salary IS NULL THEN

         OPEN get_termination_date(p_date_earned, p_assignment_id);
         FETCH get_termination_date INTO l_termination_date;
         CLOSE get_termination_date;

         hr_utility.trace('l_termination_date ='  || l_termination_date);

         OPEN get_salary(l_termination_date,
                       p_assignment_id,l_input_value_id);
         FETCH get_salary INTO l_asg_salary;
         CLOSE get_salary;
         l_date_used := nvl(l_termination_date,p_date_earned);
    END IF;

    hr_utility.trace('l_asg_salary ='  || l_asg_salary);

    l_hourly_rate := Convert_Period_Type(p_bg
        ,p_assignment_id
    	,p_payroll_id
        ,p_element_entry_id
        ,p_date_earned
        ,p_assignment_action_id
        ,l_period_start_date  -- period start date
        ,l_period_end_date    -- period end date
        ,l_asg_salary          -- p_figure, salary amount
        ,l_salary_basis        -- p_from freq, salary basis
        ,'HOURLY');            -- p_to_freq

    return l_hourly_rate;

END get_hourly_rate;


FUNCTION standard_hours_worked(
				p_std_hrs	in NUMBER,
				p_range_start	in DATE,
				p_range_end	in DATE,
				p_std_freq	in VARCHAR2) RETURN NUMBER IS

c_wkdays_per_week	NUMBER(5,2)		;
c_wkdays_per_month	NUMBER(5,2)		;
c_wkdays_per_year	NUMBER(5,2)		;

/* 353434, 368242 : Fixed number width for total hours */
v_total_hours	NUMBER(15,7)	;
v_wrkday_hours	NUMBER(15,7) 	;	 -- std hrs/wk divided by 5 workdays/wk
v_curr_date	DATE;
v_curr_day	VARCHAR2(3); -- 3 char abbrev for day of wk.
v_day_no        NUMBER;

BEGIN -- standard_hours_worked

 /* Init */
c_wkdays_per_week := 5;
c_wkdays_per_month := 20;
c_wkdays_per_year := 250;
v_total_hours := 0;
v_wrkday_hours :=0;
v_curr_date := NULL;
v_curr_day :=NULL;

-- Check for valid range
hr_utility.trace('Entered standard_hours_worked');

IF p_range_start > p_range_end THEN
  hr_utility.trace('p_range_start greater than p_range_end');
  RETURN v_total_hours;
--  hr_utility.set_message(801,'PAY_xxxx_INVALID_DATE_RANGE');
--  hr_utility.raise_error;
END IF;
--

IF UPPER(p_std_freq) = 'WEEK' THEN
  hr_utility.trace('p_std_freq = WEEK ');

  v_wrkday_hours := p_std_hrs / c_wkdays_per_week;

 hr_utility.trace('p_std_hrs ='||to_number(p_std_hrs));
 hr_utility.trace('c_wkdays_per_week ='||to_number(c_wkdays_per_week));
 hr_utility.trace('v_wrkday_hours ='||to_number(v_wrkday_hours));

ELSIF UPPER(p_std_freq) = 'MONTH' THEN

  hr_utility.trace('p_std_freq = MONTH ');

  v_wrkday_hours := p_std_hrs / c_wkdays_per_month;


 hr_utility.trace('p_std_hrs ='||to_number(p_std_hrs));
 hr_utility.trace('c_wkdays_per_month ='||to_number(c_wkdays_per_month));
 hr_utility.trace('v_wrkday_hours ='||to_number(v_wrkday_hours));

ELSIF UPPER(p_std_freq) = 'YEAR' THEN

  hr_utility.trace('p_std_freq = YEAR ');
  v_wrkday_hours := p_std_hrs / c_wkdays_per_year;

 hr_utility.trace('p_std_hrs ='||to_number(p_std_hrs));
 hr_utility.trace('c_wkdays_per_year ='||to_number(c_wkdays_per_year));
 hr_utility.trace('v_wrkday_hours ='||to_number(v_wrkday_hours));

ELSE
hr_utility.trace('p_std_freq in ELSE ');
  v_wrkday_hours := p_std_hrs;
END IF;

v_curr_date := p_range_start;

hr_utility.trace('v_curr_date is range start'||to_char(v_curr_date));


LOOP

  v_day_no := TO_CHAR(v_curr_date, 'D');


  IF v_day_no > 1 and v_day_no < 7 then


    v_total_hours := nvl(v_total_hours,0) + v_wrkday_hours;

   hr_utility.trace('  v_day_no  = '||to_char(v_day_no));
   hr_utility.trace('  v_total_hours  = '||to_char(v_total_hours));
  END IF;

  v_curr_date := v_curr_date + 1;
  EXIT WHEN v_curr_date > p_range_end;
END LOOP;
hr_utility.trace('  Final v_total_hours  = '||to_char(v_total_hours));
hr_utility.trace('  Leaving standard_hours_worked' );
--
RETURN v_total_hours;
--
END standard_hours_worked;

--  +-------------------------------------------------------------------------+
--  |-----------------<      good_time_format       >-------------------------|
--  +-------------------------------------------------------------------------+
--  Description:
--    Tests CHAR values for valid time.
--
--  Pre-conditions:
--    None.
--
--  In Arguments:
--    p_time VARCHAR2
--
--  Out Arguments:
--    BOOLEAN
--
--  Post Success:
--    Returns TRUE or FALSE depending on valid time or not.
--
--  Post Failure:
--    Returns FALSE for invalid time.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
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
--

--
--  +-------------------------------------------------------------------------+
--  |-----------------<     calc_sch_based_dur      >-------------------------|
--  +-------------------------------------------------------------------------+
--  Description:
--    Calculate the  duration in hours/days based on the work schedule.
--
--  Pre-conditions:
--    None.
--
--  In Arguments:
--    p_days_or_hours VARCHAR2
--    p_date_start    DATE
--    p_date_end      DATE
--    p_time_start    VARCHAR2
--    p_time_end      VARCHAR2
--    p_assignment_id NUMBER
--
--  Out Arguments:
--    p_duration NUMBER
--
--  Post Success:
--    Value returned for duration.
--
--  Post Failure:
--    If a failure occurs, an application error is raised and
--    processing terminates.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
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
  hr_utility.set_location('Entering '||g_package||'.calc_sch_based_dur',10);
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
  hr_utility.set_location('Leaving '||g_package||'.calc_sch_based_dur',20);
EXCEPTION
  --
  WHEN e_bad_time_format THEN
    hr_utility.set_location('Leaving '||g_package||'.calc_sch_based_dur',30);
    hr_utility.set_location(SQLERRM,35);
    RAISE;
  --
  WHEN OTHERS THEN
    hr_utility.set_location('Leaving '||g_package||'.calc_sch_based_dur',40);
    hr_utility.set_location(SQLERRM,45);
    RAISE;
  --
END calc_sch_based_dur;


FUNCTION calculate_actual_hours_worked
          (assignment_action_id   IN number   --Context
           ,assignment_id         IN number   --Context
           ,business_group_id     IN number   --Context
           ,element_entry_id      IN number   --Context
           ,date_earned           IN date     --Context
           ,p_period_start_date   IN date
           ,p_period_end_date     IN date
           ,p_schedule_category   IN varchar2  --Optional
           ,p_include_exceptions  IN varchar2  --Optional
           ,p_busy_tentative_as   IN varchar2   --Optional
           ,p_legislation_code    IN varchar2  -- Optional
           ,p_schedule_source     IN OUT nocopy varchar2 --OPtional
           ,p_schedule            IN OUT nocopy varchar2-- Optional
           ,p_return_status       OUT nocopy number -- Optional
           ,p_return_message      OUT nocopy varchar2 -- Optional
           ,p_days_or_hours       IN VARCHAR2 default 'H')
RETURN NUMBER IS
    l_work_schedule_found   BOOLEAN;
    l_total_hours           NUMBER;
    l_asg_frequency         VARCHAR2(20);
    l_duration              NUMBER;
   -- l_legislation_code      VARCHAR2(10);
    lv_wk_sch_found         VARCHAR2(20);

    CURSOR get_asg_hours_freq(p_date_earned date,
                              p_assignment_id number)IS
        SELECT hr_general.decode_lookup('FREQUENCY', ASSIGN.frequency)
               ,ASSIGN.normal_hours
        FROM  per_all_assignments_f         ASSIGN
        where date_earned
            BETWEEN ASSIGN.effective_start_date
        AND ASSIGN.effective_end_date
        and     ASSIGN.assignment_id = p_assignment_id;


BEGIN
   l_work_schedule_found := FALSE;
   l_total_hours  := 0;
--     hr_utility.trace_on(NULL, 'PAY_CALC_HOURS_WORKED');
   hr_utility.trace( 'Assignment Id '||assignment_id);
   hr_utility.trace( 'date_earned '||date_earned);
   hr_utility.trace( 'p_days_or_hours '||p_days_or_hours);
   hr_utility.trace( 'p_period_start_date '||p_period_start_date);
   hr_utility.trace( 'p_period_end_date '||p_period_end_date);
   hr_utility.trace( 'p_legislation_code '||p_legislation_code);

   IF (p_legislation_code) IS NULL or (p_legislation_code ='') or
      (g_legislation_code IS NULL) THEN
       g_legislation_code := get_legislation_code(business_group_id);
   ELSE
       g_legislation_code :=  nvl(g_legislation_code,p_legislation_code);
   END IF;

   hr_utility.trace( 'Legislation code : g_legislation_code '||g_legislation_code);

  /* Calculate hours worked based on ATG work schedule information using
     API :  HR_WRK_SCH_PKG.GET_PER_ASG_SCHEDULE ()
     This part will be coded later once this API is available from HR
        IF p_include_exceptions IS NULL THEN
         use  p_include_exceptions = 'Y';

   */
    hr_utility.trace( 'getting work schedule from ATG ');

    calc_sch_based_dur ( p_days_or_hours,
                         p_period_start_date,
                         p_period_end_date+1,
                         null,
                         null,
                         assignment_id,
                         l_duration
                        );


   IF (l_duration > 0) THEN
       l_work_schedule_found := true;
       hr_utility.trace( 'Got work schedule from ATG,duration : '||l_duration);

       return l_duration;
   END IF;

   IF NOT l_work_schedule_found THEN
     BEGIN
       hr_utility.trace( 'getting work schedule from SCL ');
       lv_wk_sch_found := 'FALSE';
       EXECUTE IMMEDIATE 'BEGIN :1 := PAY_'||g_legislation_code||
                    '_RULES.Work_Schedule_Total_Hours(:2,:3,:4,:5,:6,:7,:8,:9); END;'
       USING OUT l_total_hours,
       IN assignment_action_id,IN assignment_id,IN business_group_id,IN element_entry_id
      ,IN date_earned,IN p_period_start_date,IN p_period_end_date,IN OUT lv_wk_sch_found;
       /*
       IF l_total_hours > 0 THEN
          hr_utility.trace( 'work schedule found from SCL ');
          l_work_schedule_found := TRUE;
          return l_total_hours;
       END IF;
       */
       -- Changing above logic for Bug# 8414024
       -- "0" total hours returned by the function does not necessarily
       -- mean Work Schedule is NOT found. In case of FLSA / Proration,
       -- total hours returned by work schedule may be zero for the FLSA
       -- or pro ration period.

       IF lv_wk_sch_found = 'TRUE' THEN
          hr_utility.trace( 'work schedule found from SCL ');
          l_work_schedule_found := TRUE;
          return l_total_hours;
       END IF;

     EXCEPTION
        WHEN OTHERS THEN
          NULL;
     END;
  END IF;



  /* Calculate hours worked based on standard conditions if the actual hours
     worked are not available from either ATG work schedule or work schedule
     at assignment/org level */

  IF NOT l_work_schedule_found THEN
     hr_utility.trace('Calculating hours based on Standard conditions ');
     hr_utility.trace( 'Assignment Id '||assignment_id);
     hr_utility.trace( 'date_earned '||date_earned);
     OPEN get_asg_hours_freq(date_earned,assignment_id);
     FETCH get_asg_hours_freq
     INTO l_asg_frequency, l_normal_hours;
     CLOSE get_asg_hours_freq;

     hr_utility.trace( 'l_asg_frequency '||l_asg_frequency);
     hr_utility.trace( 'l_normal_hours '||l_normal_hours);

     IF l_asg_frequency IS NOT NULL and l_normal_hours IS NOT NULL THEN
       	l_total_hours := standard_hours_worked(l_normal_hours
                       			   ,p_period_start_date
		                           ,p_period_end_date
				           ,l_asg_frequency);
        return l_total_hours;
     END IF;

  END IF;
  return 0;
--  hr_utility.trace_off;
END calculate_actual_hours_worked;

-- Added For Skip Rule for "Regular Wages" Element, "REGULAR_PAY"

FUNCTION term_skip_rule_rwage(ctx_payroll_id             NUMBER
			     ,ctx_assignment_id          NUMBER
			     ,ctx_date_earned            DATE
			     ,p_user_entered_time        VARCHAR2
			     ,p_final_pay_processed      VARCHAR2
			     ,p_lspd_pay_processed       VARCHAR2
			     ,p_payroll_termination_type VARCHAR2
			     ,p_bg_termination_type      VARCHAR2
			     ,p_already_processed        VARCHAR2)
RETURN VARCHAR2 is

-- Get Current Pay Period Start and End Date

CURSOR csr_pay_period(p_date_earned date
                     ,p_payroll_id number) is
select ptp.start_date
      ,ptp.end_date
from per_time_periods ptp
where ptp.payroll_id = p_payroll_id
and   p_date_earned between ptp.start_date and ptp.end_date;

-- Get ATD, LSPD, FPD for the Terminated EE

CURSOR csr_term_dates(p_date_earned date
                     ,p_assignment_id number) is
select pds.actual_termination_date
      ,pds.last_standard_process_date
      ,pds.final_process_date
from   per_periods_of_service		PDS,
       per_assignments_f		ASS
WHERE	PDS.actual_termination_date <= p_date_earned
AND	PDS.period_of_service_id = ASS.period_of_service_id
AND	p_date_earned    BETWEEN ASS.effective_start_date
                                 AND ASS.effective_end_date
AND	ASS.primary_flag = 'Y'
AND	ASS.assignment_id = p_assignment_id;

-- Get the Min Date Earned after ATD

CURSOR csr_fpprocd_min_dtearned(p_atd DATE
                              ,p_assignment_id NUMBER) IS
SELECT min(ppa_run.date_earned)
  FROM pay_payroll_actions ppa_run,
       pay_assignment_actions paa_run
 WHERE ppa_run.date_earned >= p_atd
   AND ppa_run.action_status = 'C'
   AND ppa_run.action_type in ('Q','R','B','I')
   AND ((nvl(paa_run.run_type_id, ppa_run.run_type_id) is null and
	 paa_run.source_action_id is null) or
	(nvl(paa_run.run_type_id, ppa_run.run_type_id) is not null and
	 paa_run.source_action_id is not null))
   AND ppa_run.payroll_action_id = paa_run.payroll_action_id
   AND paa_run.action_status = 'C'
   AND paa_run.assignment_id = p_assignment_id
   AND NOT EXISTS (
	 SELECT 1
	   FROM pay_payroll_actions ppa_rev,
		pay_assignment_actions paa_rev,
		pay_action_interlocks pai
	  WHERE pai.locked_Action_id = paa_run.assignment_action_id
	    AND pai.locking_action_id = paa_rev.assignment_action_id
	    AND ppa_rev.payroll_action_id = paa_rev.payroll_action_id
	    AND ppa_rev.action_type = 'V');

-- Get the Min Date Earned after LSPD

CURSOR csr_lspprocd_min_dtearned(p_lspd DATE
                               ,p_assignment_id NUMBER) IS
SELECT min(ppa_run.date_earned)
  FROM pay_payroll_actions ppa_run,
       pay_assignment_actions paa_run
 WHERE ppa_run.date_earned >= p_lspd
   AND ppa_run.action_status = 'C'
   AND ppa_run.action_type in ('Q','R','B','I')
   AND ((nvl(paa_run.run_type_id, ppa_run.run_type_id) is null and
	 paa_run.source_action_id is null) or
	(nvl(paa_run.run_type_id, ppa_run.run_type_id) is not null and
	 paa_run.source_action_id is not null))
   AND ppa_run.payroll_action_id = paa_run.payroll_action_id
   AND paa_run.action_status = 'C'
   AND paa_run.assignment_id = p_assignment_id
   AND NOT EXISTS (
	 SELECT 1
	   FROM pay_payroll_actions ppa_rev,
		pay_assignment_actions paa_rev,
		pay_action_interlocks pai
	  WHERE pai.locked_Action_id = paa_run.assignment_action_id
	    AND pai.locking_action_id = paa_rev.assignment_action_id
	    AND ppa_rev.payroll_action_id = paa_rev.payroll_action_id
	    AND ppa_rev.action_type = 'V');

lv_term_typ        varchar2(1);
ld_pay_start_date  date;
ld_pay_end_date    date;
ld_atd             date;
ld_lspd            date;
ld_fpd             date;
ld_fp_dt_earned    date;
ld_lsp_dt_earned   date;

begin

hr_utility.trace('ctx_date_earned := '|| to_char(ctx_date_earned));
hr_utility.trace('ctx_payroll_id := '|| ctx_payroll_id);
hr_utility.trace('ctx_assignment_id := '|| ctx_assignment_id);
hr_utility.trace('p_user_entered_time := '|| p_user_entered_time);
hr_utility.trace('p_final_pay_processed := '|| p_final_pay_processed);
hr_utility.trace('p_lspd_pay_processed := '|| p_lspd_pay_processed);
hr_utility.trace('p_payroll_termination_type := '|| p_payroll_termination_type);
hr_utility.trace('p_bg_termination_type := '|| p_bg_termination_type);
hr_utility.trace('p_already_processed := '|| p_already_processed);

OPEN csr_pay_period(ctx_date_earned
                   ,ctx_payroll_id) ;
FETCH csr_pay_period INTO ld_pay_start_date
                         ,ld_pay_end_date;
CLOSE csr_pay_period;

OPEN csr_term_dates(ctx_date_earned
                   ,ctx_assignment_id) ;
FETCH csr_term_dates INTO ld_atd
                         ,ld_lspd
			 ,ld_fpd;
CLOSE csr_term_dates;

IF p_payroll_termination_type = 'A' THEN
   lv_term_typ := 'A';
ELSIF p_payroll_termination_type = 'L' THEN
   lv_term_typ := 'L';
ELSE
   IF p_bg_termination_type = 'A' THEN
      lv_term_typ := 'A';
   ELSIF p_bg_termination_type = 'L' THEN
      lv_term_typ := 'L';
   ELSE
      lv_term_typ := 'L';
   END IF;
END IF;

hr_utility.trace('ld_pay_start_date := '|| to_char(ld_pay_start_date));
hr_utility.trace('ld_pay_end_date := '|| to_char(ld_pay_end_date));
hr_utility.trace('ld_atd := '|| to_char(ld_atd));
hr_utility.trace('ld_lspd := '|| to_char(ld_lspd));
hr_utility.trace('ld_fpd := '|| to_char(ld_fpd));
hr_utility.trace('lv_term_typ := '|| lv_term_typ);

IF lv_term_typ = 'A' THEN -- Termination Rule 'First Pay After Term Date'
      IF ld_atd <= ctx_date_earned THEN
         IF p_final_pay_processed = 'Y' THEN
            OPEN csr_fpprocd_min_dtearned(ld_atd
                                         ,ctx_assignment_id);
            FETCH csr_fpprocd_min_dtearned INTO ld_fp_dt_earned;
	    CLOSE csr_fpprocd_min_dtearned;

	    hr_utility.trace('ld_fp_dt_earned := '|| TO_CHAR(ld_fp_dt_earned));

	    IF ctx_date_earned > ld_fp_dt_earned THEN
	       return 'Y';
	    ELSE
	        IF p_already_processed <> 'Y' THEN
	           IF p_user_entered_time = 'Y' THEN
	              return 'Y';
	           ELSE
	              return 'N';
		   END IF;
                ELSIF p_already_processed = 'Y' THEN
                   return 'Y';
                END IF;
	    END IF; -- Current PayPeriod Date Earned > Date Earned of Final Pay Processed
         ELSE
	     IF p_already_processed <> 'Y' THEN
	        IF p_user_entered_time = 'Y' THEN
	           return 'Y';
	        ELSE
	           return 'N';
		END IF;
             ELSIF p_already_processed = 'Y' THEN
                return 'Y';
             END IF;
	 END IF; -- Final Pay Processed = 'Y'
      ELSE
          IF p_already_processed <> 'Y' THEN
               IF p_user_entered_time = 'Y' THEN
                   return 'Y';
               ELSE
                  return 'N';
               END IF;
          ELSIF p_already_processed = 'Y' THEN
                return 'Y';
          END IF;
      END IF; -- ATD <= Current Pay Period Date Earned

ELSIF lv_term_typ = 'L' THEN -- Term Rule 'Last Standard Process Date'
      IF ((ld_atd <= ctx_date_earned
          AND ld_lspd <= ctx_date_earned) OR
         (ld_atd <= ctx_date_earned
          AND ld_lspd > ctx_date_earned)) THEN

	IF p_lspd_pay_processed = 'Y' THEN

            OPEN csr_lspprocd_min_dtearned(ld_lspd
                                         ,ctx_assignment_id);
            FETCH csr_lspprocd_min_dtearned INTO ld_lsp_dt_earned;
	    CLOSE csr_lspprocd_min_dtearned;

	    hr_utility.trace('ld_fp_dt_earned := '|| TO_CHAR(ld_lsp_dt_earned));

	    IF ctx_date_earned > ld_lsp_dt_earned THEN
	       return 'Y';
	    ELSE
	        IF p_already_processed <> 'Y' THEN
	           IF p_user_entered_time = 'Y' THEN
	              return 'Y';
	           ELSE
	              return 'N';
		   END IF;
                ELSIF p_already_processed = 'Y' THEN
                   return 'Y';
                END IF;
	    END IF; -- -- Current PayPeriod Date Earned > Date Earned of LSPD Pay Processed
         ELSE
	     IF p_already_processed <> 'Y' THEN
	        IF p_user_entered_time = 'Y' THEN
	           return 'Y';
	        ELSE
	           return 'N';
		END IF;
             ELSIF p_already_processed = 'Y' THEN
                return 'Y';
             END IF;
	 END IF; -- LSPD Pay Processed = 'Y'
      ELSE
          IF p_already_processed <> 'Y' THEN
               IF p_user_entered_time = 'Y' THEN
                   return 'Y';
               ELSE
                  return 'N';
               END IF;
          ELSIF p_already_processed = 'Y' THEN
                return 'Y';
          END IF;
      END IF; -- ATD <= Current Pay Period Date Earned AND LSPD <= OR > Current Pay Period Date Earned
ELSE
   return 'N';
END IF; -- Term Rule Neither 'A' nor 'L'

END term_skip_rule_rwage;

--
-- Introduced for Enabling Core Proration Functionality into
-- "Regular Salary", "Regular Wages" elements
-- Called by Formula Function HOURS_BETWEEN
--
Function hours_between( business_group_id     IN number   --Context
           ,assignment_id         IN number   --Context
           ,assignment_action_id   IN number   --Context
           ,date_earned           IN date     --Context
           ,element_entry_id      IN number   --Context

           ,p_period_start_date   IN date
           ,p_period_end_date     IN date
           ,p_schedule_category   IN varchar2  default 'WORK'-- 'WORK'/'PAGER'
           ,p_include_exceptions  IN varchar2  default ''
           ,p_busy_tentative_as   IN varchar2  default 'FREE'-- 'BUSY'/FREE/NULL
           ,p_legislation_code    IN varchar2  default ''
           ,p_schedule_source     IN OUT nocopy varchar2 -- 'PER_ASG' for asg
           ,p_schedule            IN OUT nocopy varchar2 -- schedule
           ,p_return_status       OUT nocopy number
           ,p_return_message      OUT nocopy varchar2
           ,p_days_or_hours       IN VARCHAR2 default 'H' -- 'D' for days, 'H' for hours
	   ) RETURN NUMBER is
    l_work_schedule_found   BOOLEAN;
    l_total_hours           NUMBER;
    l_asg_frequency         VARCHAR2(20);
    l_duration              NUMBER;
    l_normal_hours          NUMBER;
   -- l_legislation_code      VARCHAR2(10);
    lv_wk_sch_found         VARCHAR2(20);

    CURSOR get_asg_hours_freq(p_date_earned date,
                              p_assignment_id number)IS
        SELECT hr_general.decode_lookup('FREQUENCY', ASSIGN.frequency)
               ,ASSIGN.normal_hours
        FROM  per_all_assignments_f         ASSIGN
        where date_earned
            BETWEEN ASSIGN.effective_start_date
        AND ASSIGN.effective_end_date
        and     ASSIGN.assignment_id = p_assignment_id;


BEGIN
   hr_utility.trace('Entering Into hours_between.');
   l_work_schedule_found := FALSE;
   l_total_hours  := 0;

   hr_utility.trace( 'Assignment Id '||assignment_id);
   hr_utility.trace( 'date_earned '||date_earned);
   hr_utility.trace( 'p_days_or_hours '||p_days_or_hours);
   hr_utility.trace( 'p_period_start_date '||p_period_start_date);
   hr_utility.trace( 'p_period_end_date '||p_period_end_date);
   hr_utility.trace( 'p_legislation_code '||p_legislation_code);

   IF (p_legislation_code) IS NULL or (p_legislation_code ='') or
      (g_legislation_code IS NULL) THEN
       g_legislation_code := get_legislation_code(business_group_id);
   ELSE
       g_legislation_code :=  nvl(g_legislation_code,p_legislation_code);
   END IF;

   hr_utility.trace( 'Legislation code : g_legislation_code '||g_legislation_code);

  /* Calculate hours worked based on ATG work schedule information using
     API :  HR_WRK_SCH_PKG.GET_PER_ASG_SCHEDULE ()
     This part will be coded later once this API is available from HR
        IF p_include_exceptions IS NULL THEN
         use  p_include_exceptions = 'Y';

   */

    hr_utility.trace( 'getting work schedule from ATG ');

    calc_sch_based_dur ( p_days_or_hours,
                         p_period_start_date,
                         p_period_end_date+1,
                         null,
                         null,
                         assignment_id,
                         l_duration
                        );


   IF (l_duration > 0) THEN
       l_work_schedule_found := true;
       hr_utility.trace( 'Got work schedule from ATG,duration : '||l_duration);
       pay_core_ff_udfs.g_normal_hours := l_duration;
       return l_duration;
   END IF;

   IF NOT l_work_schedule_found THEN
     BEGIN
       hr_utility.trace( 'getting work schedule from SCL ');
       lv_wk_sch_found := 'FALSE';
       EXECUTE IMMEDIATE 'BEGIN :1 := PAY_'||g_legislation_code||
                    '_RULES.Work_Schedule_Total_Hours(:2,:3,:4,:5,:6,:7,:8,:9); END;'
       USING OUT l_total_hours,
       IN assignment_action_id,IN assignment_id,IN business_group_id,IN element_entry_id
      ,IN date_earned,IN p_period_start_date,IN p_period_end_date,IN OUT lv_wk_sch_found;

       IF lv_wk_sch_found = 'TRUE' THEN
          hr_utility.trace( 'work schedule found from SCL ');
          l_work_schedule_found := TRUE;
          pay_core_ff_udfs.g_normal_hours := l_total_hours;
          return l_total_hours;
       END IF;

     EXCEPTION
        WHEN OTHERS THEN
          null;
     END;
  END IF;


  /* Calculate hours worked based on standard conditions if the actual hours
     worked are not available from either ATG work schedule or work schedule
     at assignment/org level */

  IF NOT l_work_schedule_found THEN
     hr_utility.trace('Calculating hours based on Standard conditions ');
     hr_utility.trace( 'Assignment Id '||assignment_id);
     hr_utility.trace( 'date_earned '||date_earned);
     OPEN get_asg_hours_freq(date_earned,assignment_id);
     FETCH get_asg_hours_freq
     INTO l_asg_frequency, l_normal_hours;
     CLOSE get_asg_hours_freq;

     hr_utility.trace( 'l_asg_frequency '||l_asg_frequency);
     hr_utility.trace( 'l_normal_hours '||l_normal_hours);

     IF l_asg_frequency IS NOT NULL and pay_core_ff_udfs.g_normal_hours IS NOT NULL THEN
       	l_total_hours := standard_hours_worked(l_normal_hours
                       			   ,p_period_start_date
		                           ,p_period_end_date
				               ,l_asg_frequency);
        return l_total_hours;
     END IF;

  END IF;
  return 0;
--  hr_utility.trace_off;
END hours_between;

--
-- Introduced for Enabling Core Proration Functionality into
-- "Regular Salary", "Regular Wages" elements
-- Called by Formula Function CALC_SICK_PAY
--
FUNCTION  calc_sick_pay (ctx_asg_id 	IN NUMBER
                        ,p_period_end_dt IN DATE
                        ,p_prorate_start_dt IN DATE
                        ,p_prorate_end_dt IN DATE
			      ,p_curr_rate	IN NUMBER
                        ,p_sick_hours 	IN OUT NOCOPY NUMBER)
RETURN NUMBER IS

l_sick_pay	 NUMBER;
l_sick_hours NUMBER;
p_sick_pay   NUMBER;

/*
CURSOR get_sick_hours (	v_asg_id NUMBER,
			      v_eff_date DATE) IS
select fnd_number.canonical_to_number(pev.screen_entry_value)
from	per_absence_attendance_types	abt,
	pay_element_entries_f 		pee,
	pay_element_entry_values_f	pev
where	pev.input_value_id	= abt.input_value_id
and   abt.absence_category    = 'S'
and	v_eff_date		between pev.effective_start_date
			    	    and pev.effective_end_date
and	pee.element_entry_id	= pev.element_entry_id
and	pee.assignment_id	= v_asg_id
and	v_eff_date		between pee.effective_start_date
			    	    and pee.effective_end_date;
*/

CURSOR get_sick_hours (	v_asg_id NUMBER,
                        v_st_date DATE,
			      v_eff_date DATE) IS
select distinct pee.element_entry_id
               ,abs.absence_attendance_id
               ,abs.date_start
               ,abs.date_end
               ,fnd_number.canonical_to_number(peev.screen_entry_value)
from per_absence_attendance_types abt
    ,per_absence_attendances abs
    ,pay_element_entries_f pee
    ,pay_element_entry_values_f peev
where abt.input_value_id = peev.input_value_id
  and abt.absence_category = 'S'
  and abt.absence_attendance_type_id = abs.absence_attendance_type_id
  and peev.element_entry_id = pee.element_entry_id
  and pee.creator_id = abs.absence_attendance_id
  and pee.creator_type = 'A'
  and abs.date_start between v_st_date and v_eff_date
  and pee.assignment_id = v_asg_id
  and v_eff_date between peev.effective_start_date and peev.effective_end_date
  and v_eff_date between pee.effective_start_date and pee.effective_end_date;

ln_ele_entry_id    pay_element_entries_f.element_entry_id%TYPE;
ln_abs_att_id      per_absence_attendances.absence_attendance_id%TYPE;
ld_start_date      per_absence_attendances.date_start%TYPE;
ld_end_date        per_absence_attendances.date_end%TYPE;

-- The "sick_pay" looks for hours entered against Sick absence types in
-- the current period.  The number of hours are summed and multiplied by the
-- current rate of Regular Pay.
-- Return immediately when no sick time has been taken.

BEGIN

  hr_utility.trace('Entered calc_sick_pay');
  hr_utility.trace('Passed ctx_asg_id := ' || ctx_asg_id);
  hr_utility.trace('Passed p_period_end_dt := ' || TO_CHAR(p_period_end_dt));
  hr_utility.trace('Passed p_prorate_start_dt := ' || TO_CHAR(p_prorate_start_dt));
  hr_utility.trace('Passed p_prorate_end_dt := ' || TO_CHAR(p_prorate_end_dt));
  hr_utility.trace('Passed p_curr_rate := ' || p_curr_rate);
  hr_utility.trace('Passed p_sick_hours := ' || p_sick_hours);

  /* Init */
  l_sick_pay :=0;
  l_sick_hours := 0;
  p_sick_hours := 0;
  p_sick_pay := 0;

  /*IF p_period_end_dt BETWEEN p_prorate_start_dt AND p_prorate_end_dt THEN
  */

     OPEN get_sick_hours (ctx_asg_id, /*p_period_end_dt*/ p_prorate_start_dt, p_prorate_end_dt);
     LOOP

       hr_utility.trace('calc_sick_pay');
       hr_utility.set_location('calc_sick_pay', 13);

       FETCH get_sick_hours
       INTO	ln_ele_entry_id
          ,ln_abs_att_id
          ,ld_start_date
          ,ld_end_date
          ,l_sick_hours;
       EXIT WHEN get_sick_hours%NOTFOUND;

       hr_utility.trace('ln_ele_entry_id := ' || ln_ele_entry_id);
       hr_utility.trace('ln_abs_att_id := ' || ln_abs_att_id);
       hr_utility.trace('ld_start_date := ' || to_char(ld_start_date));
       hr_utility.trace('ld_end_date := ' || to_char(ld_end_date));
       hr_utility.trace('l_sick_hours := ' || l_sick_hours);

       p_sick_hours := p_sick_hours + l_sick_hours;
     END LOOP;
     CLOSE get_sick_hours;

     IF p_sick_hours <> 0 THEN
        l_sick_pay := p_sick_hours * p_curr_rate;
        p_sick_pay := l_sick_pay;
     END IF;

  /*
  ELSE
     l_sick_hours := 0;
     l_sick_pay := 0;

     p_sick_hours := l_sick_hours;
     p_sick_pay := l_sick_pay;

  END IF;
  */

  hr_utility.trace('Returned p_sick_hours := ' || p_sick_hours);
  hr_utility.trace('Returned p_sick_pay := ' || p_sick_pay);

  RETURN p_sick_pay;

END calc_sick_pay;

--
-- Introduced for Enabling Core Proration Functionality into
-- "Regular Salary", "Regular Wages" elements
-- Called by Formula Function CALC_VAC_PAY
--
FUNCTION calc_vacation_pay (ctx_asg_id 	IN NUMBER
                           ,p_period_end_dt IN DATE
                           ,p_prorate_start_dt IN DATE
                           ,p_prorate_end_dt IN DATE
			         ,p_curr_rate	IN NUMBER
                           ,p_vac_hours	IN OUT NOCOPY NUMBER)
RETURN NUMBER IS

l_vac_pay	NUMBER;
l_vac_hours	NUMBER;
p_vac_pay   NUMBER;

/*
CURSOR get_vac_hours (	v_asg_id NUMBER,
			      v_eff_date DATE) IS
select fnd_number.canonical_to_number(pev.screen_entry_value)
from	per_absence_attendance_types 	abt,
	pay_element_entries_f 		pee,
	pay_element_entry_values_f	pev
where pev.input_value_id	= abt.input_value_id
and   abt.absence_category    = 'V'
and	v_eff_date		between pev.effective_start_date
			    	    and pev.effective_end_date
and	pee.element_entry_id	= pev.element_entry_id
and	pee.assignment_id	= v_asg_id
and	v_eff_date		between pee.effective_start_date
			    	    and pee.effective_end_date;
*/

CURSOR get_vac_hours (	v_asg_id NUMBER,
                        v_st_date DATE,
			      v_eff_date DATE) IS
select distinct pee.element_entry_id
               ,abs.absence_attendance_id
               ,abs.date_start
               ,abs.date_end
               ,fnd_number.canonical_to_number(peev.screen_entry_value)
from per_absence_attendance_types abt
    ,per_absence_attendances abs
    ,pay_element_entries_f pee
    ,pay_element_entry_values_f peev
where abt.input_value_id = peev.input_value_id
  and abt.absence_category = 'V'
  and abt.absence_attendance_type_id = abs.absence_attendance_type_id
  and peev.element_entry_id = pee.element_entry_id
  and pee.creator_id = abs.absence_attendance_id
  and pee.creator_type = 'A'
  and abs.date_start between v_st_date and v_eff_date
  and pee.assignment_id = v_asg_id
  and v_eff_date between peev.effective_start_date and peev.effective_end_date
  and v_eff_date between pee.effective_start_date and pee.effective_end_date;

ln_ele_entry_id    pay_element_entries_f.element_entry_id%TYPE;
ln_abs_att_id      per_absence_attendances.absence_attendance_id%TYPE;
ld_start_date      per_absence_attendances.date_start%TYPE;
ld_end_date        per_absence_attendances.date_end%TYPE;

-- The "vacation_pay" fn looks for hours entered against absence types
-- in the current period.  The number of hours are summed and multiplied by
-- the current rate of Regular Pay..
-- Return immediately when no vacation time has been taken.
-- Need to loop thru all "Vacation Plans" and check for entries in the current
-- period for this assignment.

BEGIN
  hr_utility.trace('Entered calc_vacation_pay');
  hr_utility.trace('Passed ctx_asg_id := ' || ctx_asg_id);
  hr_utility.trace('Passed p_period_end_dt := ' || TO_CHAR(p_period_end_dt));
  hr_utility.trace('Passed p_prorate_start_dt := ' || TO_CHAR(p_prorate_start_dt));
  hr_utility.trace('Passed p_prorate_end_dt := ' || TO_CHAR(p_prorate_end_dt));
  hr_utility.trace('Passed p_curr_rate := ' || p_curr_rate);
  hr_utility.trace('Passed p_vac_hours := ' || p_vac_hours);

  /* Init */
  l_vac_pay := 0;
  l_vac_hours := 0;
  p_vac_hours := 0;
  p_vac_pay := 0;

  /*IF p_period_end_dt BETWEEN p_prorate_start_dt AND p_prorate_end_dt THEN
  */
     OPEN get_vac_hours (ctx_asg_id, /*p_period_end_dt*/ p_prorate_start_dt, p_prorate_end_dt);
     LOOP

     hr_utility.set_location('calc_vacation_pay', 13);
     hr_utility.trace('Opened get_vac_hours');

     FETCH get_vac_hours
     INTO  ln_ele_entry_id
          ,ln_abs_att_id
          ,ld_start_date
          ,ld_end_date
          ,l_vac_hours;
     EXIT WHEN get_vac_hours%NOTFOUND;

     hr_utility.trace('ln_ele_entry_id := ' || ln_ele_entry_id);
     hr_utility.trace('ln_abs_att_id := ' || ln_abs_att_id);
     hr_utility.trace('ld_start_date := ' || to_char(ld_start_date));
     hr_utility.trace('ld_end_date := ' || to_char(ld_end_date));
     hr_utility.trace('l_vac_hours := ' || l_vac_hours);

     p_vac_hours := p_vac_hours + l_vac_hours;

     END LOOP;
     CLOSE get_vac_hours;
     IF p_vac_hours <> 0 THEN
        l_vac_pay := p_vac_hours * p_curr_rate;
        p_vac_pay := l_vac_pay;
     END IF;

   /*
   ELSE
     l_vac_hours := 0;
     l_vac_pay := 0;

     p_vac_hours := l_vac_hours;
     p_vac_pay := l_vac_pay;
  END IF;
  */

  hr_utility.trace('Returned p_vac_hours := ' || p_vac_hours);
  hr_utility.trace('Returned p_vac_pay := ' || p_vac_pay);

  RETURN p_vac_pay;

END calc_vacation_pay;

--
-- Introduced for Enabling Core Proration Functionality into
-- "Regular Salary", "Regular Wages" elements
-- Called by Formula Function REDUCED_REGULAR_CALC
--
FUNCTION calc_reduced_reg(ctx_assignment_id IN NUMBER
                         ,ctx_assignment_action_id IN NUMBER
                         ,p_period_end_dt IN DATE
                         ,p_prorate_start_dt IN DATE
                         ,p_prorate_end_dt IN DATE
                         ,p_red_reg_earn  IN OUT NOCOPY NUMBER
                         ,p_red_reg_hrs IN OUT NOCOPY NUMBER
                         )
RETURN VARCHAR2 IS
ln_red_regular_earn   NUMBER;
ln_red_regular_hrs    NUMBER;
BEGIN
hr_utility.trace('Entered into pay_core_ff_udfs.calc_reduced_reg');
hr_utility.trace('ctx_assignment_id := ' || ctx_assignment_id);
hr_utility.trace('ctx_assignment_action_id := ' || ctx_assignment_action_id);
hr_utility.trace('p_period_end_dt := ' || TO_CHAR(p_period_end_dt));
hr_utility.trace('p_prorate_start_dt := ' || p_prorate_start_dt);
hr_utility.trace('p_prorate_end_dt := ' || p_prorate_end_dt);
hr_utility.trace('p_red_reg_earn := ' || p_red_reg_earn);
hr_utility.trace('p_red_reg_hrs := ' || p_red_reg_hrs);

IF p_period_end_dt BETWEEN p_prorate_start_dt AND p_prorate_end_dt THEN
   ln_red_regular_earn := (-1) * p_red_reg_earn;
   ln_red_regular_hrs := (-1) * p_red_reg_hrs;

   p_red_reg_earn := ln_red_regular_earn;
   p_red_reg_hrs := ln_red_regular_hrs;

ELSE
   p_red_reg_earn := 0;
   p_red_reg_hrs := 0;
END IF;

hr_utility.trace('Returned p_red_reg_earn := ' || p_red_reg_earn);
hr_utility.trace('Returned p_red_reg_hrs := ' || p_red_reg_hrs);

RETURN 'TRUE';

END calc_reduced_reg;

FUNCTION get_upgrade_flag(ctx_ele_typ_id IN NUMBER)
RETURN VARCHAR2 IS
BEGIN

   RETURN pay_us_rsrw_upgrev.get_upgrade_flag(p_ctx_ele_typ_id => ctx_ele_typ_id);

END get_upgrade_flag;

FUNCTION get_num_period_curr_year(ctx_bg_id in NUMBER
                                 ,ctx_payroll_id in NUMBER
                                 ,ctx_ele_type_id in NUMBER
                                 ,period_end_date in DATE)
RETURN NUMBER IS
BEGIN
   RETURN pay_us_rsrw_upgrev.get_payprd_per_fiscal_yr(p_ctx_bg_id => ctx_bg_id
                                                     ,p_ctx_payroll_id => ctx_payroll_id
                                                     ,p_eletyp_ctx_id => ctx_ele_type_id
                                                     ,p_period_end_date => period_end_date);

END get_num_period_curr_year;

FUNCTION get_asg_status_typ(ctx_asg_id IN NUMBER
                           ,prorate_end_dt IN DATE)
RETURN VARCHAR2 IS
BEGIN

/* bug 9386700  technicall if the payroll status = Process then we shold
 * run the fast formula.   The Human Resourse status should not be checked
 * and effect the output of the formual.  IT was decided to have this
 * function rturn Y instead of changing the formula templates / seeded
 * formulas etc.
 */

/*
    IF pay_us_rsrw_upgrev.get_assignment_status(p_ctx_asg_id => ctx_asg_id
                                               ,p_prorate_end_dt => prorate_end_dt) = 'ACTIVE_ASSIGN' THEN

      hr_utility.trace('Assignment status is ACTIVE_ASSIGN.');
      RETURN 'Y';
    ELSE
      hr_utility.trace('Assignment status is NOT ACTIVE_ASSIGN.');
      RETURN 'N';
    END IF;
*/

      RETURN 'Y';

END get_asg_status_typ;

END pay_core_ff_udfs ;

/
