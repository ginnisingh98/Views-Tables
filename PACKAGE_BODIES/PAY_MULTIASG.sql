--------------------------------------------------------
--  DDL for Package Body PAY_MULTIASG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_MULTIASG" AS
/* $Header: pycaearn.pkb 120.5 2007/01/07 17:33:48 ssouresr noship $ */
/*
+======================================================================+
|                Copyright (c) 1994 Oracle Corporation                 |
|                   Redwood Shores, California, USA                    |
|                        All rights reserved.                          |
+======================================================================+

    Name        : pay_multiasg
    Filename	: pycaearn.pkb
    Change List
    -----------
    Date        Name          	Vers    Bug No	Description
    ----        ----          	----	------	-----------
    09-MAR-2002  ssouresr               2250370   Created
    01-NOV-2005  mmukherj               4715972   Added some more parameters
                                                  to call convert_period_type
                                                  and calculate_period_earnings
                                                  since those functions have
                                                  been changed to support core
                                                  work pattern functionality.
   14-DEC-2006  ssouresr                          modified custom element section
                                                  to remove prorating functions
*/
--
-- **********************************************************************
-- PRORATION_REGULAR
-- Description: This function performs proration for the startup elements Regular Salary AND
-- Regular Wages.  Proration occurs in the following scenarios: 1. Change of assignment status to
-- a status which is unpaid - ie. unpaid leave, termination; 2. Change of regular rate of pay
-- ie. could be a change in annual salary or hourly rate.
-- This function also calculates AND returns the actual hours worked in the period, vacation pay, sick
-- pay, vacation hours, AND sick hours. These calculations are done for all assignments of a person.


FUNCTION Multi_Asg_Proration_Regular (
			p_bus_grp_id		IN NUMBER,
			p_asst_id		IN NUMBER,
			p_payroll_id		IN NUMBER,
			p_ele_entry_id		IN NUMBER,
			p_tax_unit_id		IN NUMBER,
			p_date_earned		IN DATE,
			p_period_start 		IN DATE,
			p_period_end 		IN DATE,
                        p_run_type              IN VARCHAR2)
RETURN NUMBER IS
--
v_assignment_id        	  NUMBER(10,0);
v_salary_element          VARCHAR2(80);
v_freq_code               VARCHAR2(30);
v_asg_hours               NUMBER(22,3);
v_salary_basis_code       VARCHAR2(30);
v_work_schedule 	  VARCHAR2(60);
v_periodic_salary         NUMBER(27,7);
v_hours                   NUMBER(27,7);
v_rate                    NUMBER(27,7);
v_rate_code               VARCHAR2(60);
v_asg_salary              NUMBER(27,7);

regular_earnings          NUMBER(27,7);
actual_hours_worked       NUMBER(27,7);
hourly_rate               NUMBER(27,7);
chk_hourly_rate           NUMBER(27,7);
total_earnings            NUMBER(27,7)  :=0;

l_input_value_name        VARCHAR2(200);
l_element_type            VARCHAR2(200);
l_regular_aggregate       VARCHAR2(2);
l_value                   NUMBER;
l_dummy_value             NUMBER;

CURSOR regular_aggregate IS
SELECT nvl(prl_information5, 'N')
FROM pay_all_payrolls_f
WHERE  payroll_id    = p_payroll_id
AND    p_date_earned BETWEEN effective_start_date
                         AND effective_end_date;

CURSOR 	other_assignments IS
SELECT  DISTINCT ASG1.assignment_id
FROM    per_assignments_f               ASG1,
        per_assignments_f               ASG,
        hr_soft_coding_keyflex          SK
WHERE   ASG.assignment_id             = p_asst_id
AND     ASG.payroll_id                = p_payroll_id
AND     ASG.person_id                 = ASG1.person_id
AND     ASG.payroll_id                = ASG1.payroll_id
AND     ASG1.soft_coding_keyflex_id   = SK.soft_coding_keyflex_id
AND     SK.segment1                   = to_char(p_tax_unit_id)
AND     p_date_earned       BETWEEN  ASG.effective_start_date
                                AND  ASG.effective_end_date
AND     p_date_earned       BETWEEN  ASG1.effective_start_date
                                AND  ASG1.effective_end_date;

CURSOR periodic_salary (p_assign_id NUMBER) IS
SELECT MIN (fffunc.cn(decode(decode(INPUTV.uom,'M','N','N','N','I','N',null),'N',
            decode(INPUTV.hot_default_flag,'Y',nvl(EEV.screen_entry_value,
            nvl(LIV.default_value,INPUTV.default_value)),'N',EEV.screen_entry_value),null)))
FROM
        pay_element_entry_values_f               EEV,
        pay_element_entries_f                    EE,
        pay_link_input_values_f                  LIV,
        pay_input_values_f                       INPUTV,
        pay_element_types_f                      E

WHERE   p_date_earned    BETWEEN INPUTV.effective_start_date
                             AND INPUTV.effective_end_date
AND     INPUTV.element_type_id + 0             = E.element_type_id
AND     LIV.input_value_id                     = INPUTV.input_value_id
AND     p_date_earned BETWEEN LIV.effective_start_date
                             AND LIV.effective_end_date
AND     EEV.input_value_id + 0                 = INPUTV.input_value_id
AND     EEV.element_entry_id                   = EE.element_entry_id
AND     EEV.effective_start_date               = EE.effective_start_date
AND     EEV.effective_end_date                 = EE.effective_end_date
AND     EE.element_link_id                     = LIV.element_link_id
AND     EE.assignment_id                       = p_assign_id
AND     p_date_earned BETWEEN EE.effective_start_date
                             AND EE.effective_end_date
AND     nvl(EE.ENTRY_TYPE, 'E')              = 'E'
AND     E.element_name                       = 'Regular Salary'
AND     E.legislation_code                   = 'CA'
AND     p_date_earned BETWEEN E.effective_start_date
                          AND E.effective_end_date
AND     INPUTV.name                          = 'Periodic Salary'
AND     INPUTV.legislation_code              = 'CA';


/*CURSOR pay_earned_start_date IS
SELECT PTP.start_date
FROM
            per_time_periods ptp,
            pay_payroll_actions ppa
WHERE ppa.date_earned BETWEEN ptp.START_DATE
AND                           ptp.END_DATE
AND   ppa.payroll_action_id = p_payroll_action_id
AND   ptp.payroll_id        = ppa.payroll_id;


CURSOR pay_earned_end_date IS
SELECT PTP.end_date
FROM
            per_time_periods ptp,
            pay_payroll_actions ppa
WHERE ppa.date_earned BETWEEN ptp.START_DATE
AND                           ptp.END_DATE
AND   ppa.payroll_action_id = p_payroll_action_id
AND   ptp.payroll_id        = ppa.payroll_id;
*/

CURSOR work_schedule (p_assign_id NUMBER) IS
SELECT target.SEGMENT4
FROM
       hr_soft_coding_keyflex                 target,
       per_assignments_f                      ASSIGN
WHERE  p_date_earned BETWEEN ASSIGN.effective_start_date
                         AND ASSIGN.effective_end_date
AND    ASSIGN.assignment_id                  = p_assign_id
AND    target.soft_coding_keyflex_id         = ASSIGN.soft_coding_keyflex_id
AND    target.enabled_flag                   = 'Y'
AND    target.id_flex_num                    = 15;


CURSOR hours (p_assign_id NUMBER) IS
SELECT sum(decode(INPUTV.hot_default_flag,
                  'Y',nvl(EEV.screen_entry_value,nvl(LIV.default_value,INPUTV.default_value)),
                  'N',EEV.screen_entry_value))
FROM
        pay_element_entry_values_f               EEV,
        pay_element_entries_f                    EE,
        pay_link_input_values_f                  LIV,
        pay_input_values_f                       INPUTV,
        pay_element_types_f                      E

WHERE   p_date_earned BETWEEN INPUTV.effective_start_date
                          AND INPUTV.effective_end_date
AND     INPUTV.element_type_id + 0             = E.element_type_id
AND     LIV.input_value_id                     = INPUTV.input_value_id
AND     p_date_earned BETWEEN LIV.effective_start_date
                          AND LIV.effective_end_date
AND     EEV.input_value_id + 0                 = INPUTV.input_value_id
AND     EEV.element_entry_id                   = EE.element_entry_id
AND     EEV.effective_start_date               = EE.effective_start_date
AND     EEV.effective_end_date                 = EE.effective_end_date
AND     EE.element_link_id                     = LIV.element_link_id
AND     EE.assignment_id                       = p_assign_id
AND     p_date_earned BETWEEN EE.effective_start_date
                          AND EE.effective_end_date
AND     nvl(EE.ENTRY_TYPE, 'E')              = 'E'
AND     E.element_name                       = 'Time Entry Wages'
AND     E.legislation_code                   = 'CA'
AND     p_date_earned BETWEEN E.effective_start_date
                          AND E.effective_end_date
AND     INPUTV.name                          = 'Hours'
AND     INPUTV.legislation_code              = 'CA';


CURSOR rate (p_assign_id NUMBER) IS
SELECT min (fffunc.cn(decode(
    decode(INPUTV.uom,'M','N','N','N','I','N',null),'N',decode(INPUTV.hot_default_flag,'Y',nvl(EEV.screen_entry_value,nvl(LIV.default_value,INPUTV.default_value)),'N',EEV.screen_entry_value),null)))
FROM
        pay_element_entry_values_f               EEV,
        pay_element_entries_f                    EE,
        pay_link_input_values_f                  LIV,
        pay_input_values_f                       INPUTV,
        pay_element_types_f                      E

WHERE   p_date_earned BETWEEN INPUTV.effective_start_date
                          AND INPUTV.effective_end_date
AND     INPUTV.element_type_id + 0             = E.element_type_id
AND     LIV.input_value_id                     = INPUTV.input_value_id
AND     p_date_earned BETWEEN LIV.effective_start_date
                          AND LIV.effective_end_date
AND     EEV.input_value_id + 0                 = INPUTV.input_value_id
AND     EEV.element_entry_id                   = EE.element_entry_id
AND     EEV.effective_start_date               = EE.effective_start_date
AND     EEV.effective_end_date                 = EE.effective_end_date
AND     EE.element_link_id                     = LIV.element_link_id
AND     EE.assignment_id                       = p_assign_id
AND     p_date_earned BETWEEN EE.effective_start_date
                          AND EE.effective_end_date
AND     nvl(EE.ENTRY_TYPE, 'E')              = 'E'
AND     E.element_name                       = 'Regular Wages'
AND     E.legislation_code                   = 'CA'
AND     p_date_earned BETWEEN E.effective_start_date
                          AND E.effective_end_date
AND     INPUTV.name                          = 'Rate'
AND     INPUTV.legislation_code              = 'CA';


CURSOR rate_code (p_assign_id NUMBER) IS
SELECT min (decode(INPUTV.hot_default_flag,'Y',nvl(EEV.screen_entry_value,
nvl(LIV.default_value,INPUTV.default_value)),'N',EEV.screen_entry_value))
FROM
        pay_element_entry_values_f               EEV,
        pay_element_entries_f                    EE,
        pay_link_input_values_f                  LIV,
        pay_input_values_f                       INPUTV,
        pay_element_types_f                      E

WHERE   p_date_earned BETWEEN INPUTV.effective_start_date
                          AND INPUTV.effective_end_date
AND     INPUTV.element_type_id + 0             = E.element_type_id
AND     LIV.input_value_id                     = INPUTV.input_value_id
AND     p_date_earned BETWEEN LIV.effective_start_date
                          AND LIV.effective_end_date
AND     EEV.input_value_id + 0                 = INPUTV.input_value_id
AND     EEV.element_entry_id                   = EE.element_entry_id
AND     EEV.effective_start_date               = EE.effective_start_date
AND     EEV.effective_end_date                 = EE.effective_end_date
AND     EE.element_link_id                     = LIV.element_link_id
AND     EE.assignment_id                       = p_assign_id
AND     p_date_earned BETWEEN EE.effective_start_date
                          AND EE.effective_end_date
AND     nvl(EE.ENTRY_TYPE, 'E')              = 'E'
AND     E.element_name                       = 'Regular Wages'
AND     E.legislation_code                   = 'CA'
AND     p_date_earned BETWEEN E.effective_start_date
                          AND E.effective_end_date
AND     INPUTV.name                          = 'Rate Code'
AND     INPUTV.legislation_code              = 'CA';


CURSOR asg_hours (p_assign_id NUMBER) IS
SELECT ASSIGN.normal_hours
FROM
        per_all_assignments_f         ASSIGN,
        hr_lookups                    HR3
WHERE   p_date_earned BETWEEN ASSIGN.effective_start_date
                          AND ASSIGN.effective_end_date
AND     ASSIGN.assignment_id                = p_assign_id
AND     HR3.application_id               (+)= 800
AND     HR3.lookup_code                  (+)= ASSIGN.frequency
AND     HR3.lookup_type                  (+)= 'FREQUENCY';

CURSOR salary_basis_code (p_assign_id NUMBER) IS
SELECT BASES.pay_basis
FROM
        per_assignments_f                      ASSIGN
,       per_pay_bases                          BASES
,       pay_input_values_f                     INPUTV
,       pay_element_types_f                    ETYPE
,       pay_rates                              RATE
,       hr_lookups                             HR1
,       hr_lookups                             HR2
WHERE   p_date_earned BETWEEN ASSIGN.effective_start_date
                          AND ASSIGN.effective_end_date
AND     ASSIGN.assignment_id                 = p_assign_id
AND     BASES.pay_basis_id                (+)= ASSIGN.pay_basis_id
AND     INPUTV.input_value_id             (+)= BASES.input_value_id
AND     p_date_earned BETWEEN nvl (INPUTV.effective_start_date, p_date_earned)
                          AND nvl (INPUTV.effective_end_date, p_date_earned)
AND     ETYPE.element_type_id             (+)= INPUTV.element_type_id
AND     p_date_earned BETWEEN nvl (ETYPE.effective_start_date, p_date_earned)
                          AND nvl (ETYPE.effective_end_date, p_date_earned)
AND     RATE.rate_id                      (+)= BASES.rate_id
AND     HR1.lookup_code                   (+)= BASES.pay_basis
AND     HR1.lookup_type                   (+)= 'PAY_BASIS'
AND     HR1.application_id                (+)= 800
AND     HR2.lookup_code                   (+)= BASES.rate_basis
AND     HR2.application_id                (+)= 800
AND     HR2.lookup_type                   (+)= 'PAY_BASIS';

CURSOR freq_code (p_assign_id NUMBER) IS
SELECT HR3.lookup_code
FROM
        per_all_assignments_f         ASSIGN,
        hr_lookups                    HR3
WHERE   p_date_earned BETWEEN ASSIGN.effective_start_date
                          AND ASSIGN.effective_end_date
AND     ASSIGN.assignment_id                = p_assign_id
AND     HR3.application_id               (+)= 800
AND     HR3.lookup_code                  (+)= ASSIGN.frequency
AND     HR3.lookup_type                  (+)= 'FREQUENCY';

CURSOR salary_element (p_assign_id NUMBER) IS
SELECT ETYPE.element_name
FROM
        per_assignments_f                      ASSIGN
,       per_pay_bases                          BASES
,       pay_input_values_f                     INPUTV
,       pay_element_types_f                    ETYPE
,       pay_rates                              RATE
,       hr_lookups                             HR1
,       hr_lookups                             HR2
WHERE   p_date_earned BETWEEN ASSIGN.effective_start_date
                          AND ASSIGN.effective_end_date
AND     ASSIGN.assignment_id                 = p_assign_id
AND     BASES.pay_basis_id                (+)= ASSIGN.pay_basis_id
AND     INPUTV.input_value_id             (+)= BASES.input_value_id
AND     p_date_earned BETWEEN nvl (INPUTV.effective_start_date, p_date_earned)
                          AND nvl (INPUTV.effective_end_date, p_date_earned)
AND     ETYPE.element_type_id             (+)= INPUTV.element_type_id
AND     p_date_earned BETWEEN nvl (ETYPE.effective_start_date, p_date_earned)
                          AND nvl (ETYPE.effective_end_date, p_date_earned)
AND     RATE.rate_id                      (+)= BASES.rate_id
AND     HR1.lookup_code                   (+)= BASES.pay_basis
AND     HR1.lookup_type                   (+)= 'PAY_BASIS'
AND     HR1.application_id                (+)= 800
AND     HR2.lookup_code                   (+)= BASES.rate_basis
AND     HR2.application_id                (+)= 800
AND     HR2.lookup_type                   (+)= 'PAY_BASIS';

CURSOR asg_salary (p_assign_id NUMBER) IS
SELECT fnd_number.canonical_to_number (EEV.screen_entry_value)
FROM
        per_assignments_f                      ASSIGN
,       per_pay_bases                          BASES
,       pay_element_entries_f                  EE
,       pay_element_entry_values_f             EEV
WHERE   p_date_earned BETWEEN ASSIGN.effective_start_date
                          AND ASSIGN.effective_end_date
AND     ASSIGN.assignment_id                 = p_assign_id
AND     BASES.pay_basis_id                +0 = ASSIGN.pay_basis_id
AND     EEV.input_value_id                   = BASES.input_value_id
AND     p_date_earned BETWEEN EEV.effective_start_date
                          AND EEV.effective_end_date
AND     EE.assignment_id                     = ASSIGN.assignment_id
AND     EE.entry_type = 'E'
AND     p_date_earned BETWEEN EE.effective_start_date
                          AND EE.effective_end_date
AND     EEV.element_entry_id                 = EE.element_entry_id;

--
BEGIN

OPEN regular_aggregate;
FETCH regular_aggregate INTO l_regular_aggregate;
CLOSE regular_aggregate;

OPEN other_assignments;

hr_utility.trace('Entered Loop');

LOOP

    FETCH other_assignments
    INTO  v_assignment_id;
    EXIT WHEN other_assignments%NOTFOUND;

    hr_utility.trace('Fetched from other assignments');

    IF (p_run_type = 'L' OR
        l_regular_aggregate = 'N') THEN
       v_assignment_id :=  p_asst_id;
    END IF;

    OPEN salary_element (v_assignment_id);
    OPEN freq_code (v_assignment_id);
    OPEN asg_hours (v_assignment_id);
    OPEN salary_basis_code (v_assignment_id);
    OPEN periodic_salary (v_assignment_id);
    OPEN work_schedule (v_assignment_id);
    OPEN rate (v_assignment_id);
    OPEN rate_code (v_assignment_id);
    OPEN hours (v_assignment_id);
    OPEN asg_salary (v_assignment_id);


    FETCH salary_element
    INTO  v_salary_element;

    hr_utility.trace('Fetched from salary element');

    IF (salary_element%NOTFOUND) THEN

         regular_earnings := 0;

    ELSIF  v_salary_element = 'Regular Salary' THEN

         hr_utility.trace('Element is Regular Salary');
         FETCH freq_code
         INTO  v_freq_code;

         FETCH asg_hours
         INTO  v_asg_hours;

         hr_utility.trace('Fetched from feq_code and asg_hours');

         FETCH salary_basis_code
         INTO  v_salary_basis_code;

         FETCH periodic_salary
         INTO  v_periodic_salary;

         FETCH work_schedule
         INTO  v_work_schedule;

         hr_utility.trace('Going to call Convertr_Period_Type');

         hourly_rate := hr_ca_ff_udfs.Convert_Period_Type(p_bus_grp_id,
                                                          p_payroll_id,
                                                          NULL,
                                                          p_asst_id,
                                                          p_ele_entry_id,
                                                          p_date_earned,
                                                          v_work_schedule,
                                                          v_asg_hours,
                                                          v_periodic_salary,
                                                          v_salary_basis_code,
                                                          'HOURLY',
                                                          p_period_start,
                                                          p_period_end,
                                                          v_freq_code);

         hr_utility.trace('Returned from call to Convert_Period_Type');

         actual_hours_worked := 0;

--  IF ASG_SALARY_BASIS_CODE WAS DEFAULTED THEN
--    mesg = ''Pay Basis MUST be entered for Regular Salary calculation.''

  regular_earnings := hr_ca_ff_udfs.Calculate_Period_Earnings(p_bus_grp_id,
                                                              p_asst_id,
                                                              null,
                                                              p_payroll_id,
                                                              p_ele_entry_id,
                                                              p_tax_unit_id,
                                                              p_date_earned,
                                                           v_salary_basis_code,
                                                          'MONTHLY SALARY',
                                                           hourly_rate,
                                                           p_period_start,
                                                           p_period_end,
                                                           v_work_schedule,
                                                           v_asg_hours,
                                                           actual_hours_worked,
                                                           'Y',
                                                            v_freq_code);

         hr_utility.trace('Calulate_Period_Earnings returns:  '|| to_char(regular_earnings));
    ELSIF  v_salary_element = 'Regular Wages' THEN

         FETCH rate
         INTO  v_rate;

         hr_utility.trace('Salary element is Regular Wages');
         IF (rate%FOUND) THEN

              hourly_rate := v_rate;
              actual_hours_worked := 0;

              FETCH freq_code
              INTO  v_freq_code;

              hr_utility.trace('Fetched from freq_code');
              FETCH asg_hours
              INTO  v_asg_hours;

              FETCH salary_basis_code
              INTO  v_salary_basis_code;

              FETCH work_schedule
              INTO  v_work_schedule;

              hr_utility.trace('Going to call Calculate_Period_Earnings');

   regular_earnings := hr_ca_ff_udfs.Calculate_Period_Earnings(p_bus_grp_id,
                                                               p_asst_id,
                                                               null,
                                                               p_payroll_id,
                                                               p_ele_entry_id,
                                                               p_tax_unit_id,
                                                               p_date_earned,
                                                        v_salary_basis_code,
                                                       'RATE',
                                                        hourly_rate,
                                                        p_period_start,
                                                        p_period_end,
                                                        v_work_schedule,
                                                        v_asg_hours,
                                                        actual_hours_worked,
                                                        'Y',
                                                        v_freq_code);

              hr_utility.trace('Calulate_Period_Earnings returns:  '|| to_char(regular_earnings));
         ELSE
               FETCH rate_code
               INTO  v_rate_code;

               IF (rate_code%FOUND) THEN

                    FETCH freq_code
                    INTO  v_freq_code;

                    FETCH asg_hours
                    INTO  v_asg_hours;

                    FETCH work_schedule
                    INTO  v_work_schedule;

         hourly_rate := to_number (hruserdt.get_table_value (p_bus_grp_id,
                                                            'WAGE RATES',
                                                            'Wage Rate',
                                                            v_rate_code));
                    actual_hours_worked := 0;

    regular_earnings := hr_ca_ff_udfs.Calculate_Period_Earnings(p_bus_grp_id,
                                                                p_asst_id,
                                                                null,
                                                                p_payroll_id,
                                                                p_ele_entry_id,
                                                                p_tax_unit_id,
                                                                p_date_earned,
                                                               'HOURLY',
                                                               'RATE CODE',
                                                                hourly_rate,
                                                                p_period_start,
                                                                p_period_end,
                                                               v_work_schedule,
                                                               v_asg_hours,
                                                           actual_hours_worked,
                                                              'Y',
                                                               v_freq_code);

               ELSE
                   regular_earnings := 0;
               END IF;
         END IF;

    ELSIF  v_salary_element = 'Time Entry Wages' THEN

         FETCH rate_code
         INTO  v_rate_code;

         IF (rate_code%FOUND) THEN

              chk_hourly_rate := to_number (hruserdt.get_table_value (p_bus_grp_id,
                                                                      'WAGE RATES',
                                                                      'Wage Rate',
                                                                      v_rate_code));
              IF (chk_hourly_rate <> 0) THEN

                   FETCH hours
                   INTO v_hours;

                   regular_earnings := fffunc.round_up ( (chk_hourly_rate * to_number(v_hours)),2);

--            ELSE
--                   mesg := 'Rate Code not found in WAGE RATES table';
              END IF;

         ELSE
              FETCH salary_basis_code
              INTO  v_salary_basis_code;

              FETCH asg_salary
              INTO  v_asg_salary;

              IF (v_salary_basis_code = 'Hourly Salary') THEN

                   chk_hourly_rate := v_asg_salary;

              ELSE
                   FETCH freq_code
                   INTO  v_freq_code;

                   FETCH asg_hours
                   INTO  v_asg_hours;

                   FETCH work_schedule
                   INTO  v_work_schedule;

    chk_hourly_rate := hr_ca_ff_udfs.Convert_Period_Type(p_bus_grp_id,
                                                         p_payroll_id,
                                                         NULL,
                                                         p_asst_id,
                                                         p_ele_entry_id,
                                                         v_work_schedule,
                                                         v_asg_hours,
                                                         v_asg_salary,
                                                         v_salary_basis_code,
                                                         'HOURLY',
                                                         p_period_start,
                                                         p_period_end,
                                                         v_freq_code);
              END IF;

              FETCH hours
              INTO v_hours;

              regular_earnings := fffunc.round_up ((chk_hourly_rate * to_number(v_hours)),2);

          END IF;


     ELSE /* Customer Salary Basis Element 5097793 */
--       1] Get the type of earnings element.

       FETCH salary_basis_code INTO  v_salary_basis_code;

       l_dummy_value := hr_ca_ff_udfs.get_earnings_and_type
                              ( p_bus_grp_id		=> p_bus_grp_id,
                                p_asst_id               => v_assignment_id,
                                p_assignment_action_id	=> 0,
                                p_payroll_id		=> p_payroll_id,
                                p_ele_entry_id		=> p_ele_entry_id,
                                p_tax_unit_id		=> p_tax_unit_id,
                                p_date_earned		=> p_date_earned,
                                p_pay_basis 		=> v_salary_basis_code,
				p_period_start          => p_period_start,
                                p_period_end            => p_period_end,
				p_element_type          => l_element_type,
				p_value                 => l_value,
                                p_input_value_name      => l_input_value_name);

        IF l_input_value_name = 'Amount' THEN

         hr_utility.trace('Element is Regular Salary');
         FETCH freq_code INTO  v_freq_code;

         FETCH asg_hours INTO  v_asg_hours;

         hr_utility.trace('Fetched from feq_code and asg_hours');

         FETCH periodic_salary INTO  v_periodic_salary;

         FETCH work_schedule INTO  v_work_schedule;

         hr_utility.trace('Going to call Convertr_Period_Type');

         /*Commenting out this section as custom elements in Canada
           currently do not perform any prorating, therefore the previous
           earnings should also not be prorated */
         /*
         hourly_rate := hr_ca_ff_udfs.Convert_Period_Type(p_bus_grp_id,
                                                          p_payroll_id,
                                                          NULL,
                                                          p_asst_id,
                                                          p_ele_entry_id,
                                                          p_date_earned,
                                                          v_work_schedule,
                                                          v_asg_hours,
                                                          l_value,
                                                          v_salary_basis_code,
                                                          'HOURLY',
                                                          p_period_start,
                                                          p_period_end,
                                                          v_freq_code);

         hr_utility.trace('Returned from call to Convert_Period_Type');

         actual_hours_worked := 0;

         regular_earnings := hr_ca_ff_udfs.Calculate_Period_Earnings
                                                             (p_bus_grp_id,
                                                              p_asst_id,
                                                              null,
                                                              p_payroll_id,
                                                              p_ele_entry_id,
                                                              p_tax_unit_id,
                                                              p_date_earned,
                                                              v_salary_basis_code,
                                                              l_input_value_name,
                                                              hourly_rate,
                                                              p_period_start,
                                                              p_period_end,
                                                              v_work_schedule,
                                                              v_asg_hours,
                                                              actual_hours_worked,
                                                              'Y',
                                                              v_freq_code);
        */
         regular_earnings := l_value;

--	END IF; /* l_input_value_name = 'Amount' */

--        IF l_element_type = 'REGULAR_WAGES' THEN

         ELSIF l_input_value_name = 'Rate' THEN

              hourly_rate := l_value;
              actual_hours_worked := 0;

              FETCH freq_code INTO  v_freq_code;

              hr_utility.trace('Fetched from freq_code');
              FETCH asg_hours INTO  v_asg_hours;

              FETCH salary_basis_code INTO  v_salary_basis_code;

              FETCH work_schedule INTO  v_work_schedule;

              hr_utility.trace('Going to call Calculate_Period_Earnings');

              regular_earnings := hr_ca_ff_udfs.Calculate_Period_Earnings
                                                              (p_bus_grp_id,
                                                               p_asst_id,
                                                               null,
                                                               p_payroll_id,
                                                               p_ele_entry_id,
                                                               p_tax_unit_id,
                                                               p_date_earned,
                                                               v_salary_basis_code,
                                                               l_input_value_name,
                                                               hourly_rate,
                                                               p_period_start,
                                                               p_period_end,
                                                               v_work_schedule,
                                                               v_asg_hours,
                                                               actual_hours_worked,
                                                               'Y',
                                                               v_freq_code);

              hr_utility.trace('Calulate_Period_Earnings returns:  '|| to_char(regular_earnings));

	 ELSIF l_input_value_name = 'Rate Code' THEN

                    FETCH freq_code INTO  v_freq_code;

                    FETCH asg_hours INTO  v_asg_hours;

                    FETCH work_schedule INTO  v_work_schedule;

                    hourly_rate := to_number (hruserdt.get_table_value
		                                           (p_bus_grp_id,
                                                            'WAGE RATES',
                                                            'Wage Rate',
                                                            v_rate_code));
                    actual_hours_worked := 0;

                    regular_earnings := hr_ca_ff_udfs.Calculate_Period_Earnings
                                                               (p_bus_grp_id,
                                                                p_asst_id,
                                                                null,
                                                                p_payroll_id,
                                                                p_ele_entry_id,
                                                                p_tax_unit_id,
                                                                p_date_earned,
                                                                'HOURLY',
                                                                l_input_value_name,
                                                                hourly_rate,
                                                                p_period_start,
                                                                p_period_end,
                                                                v_work_schedule,
                                                                v_asg_hours,
                                                                actual_hours_worked,
                                                                'Y',
                                                                v_freq_code);

               ELSIF l_input_value_name = 'DUMMY' THEN
                   regular_earnings := 0;
               END IF; /** l_input_value_name = 'Rate'*/

     END IF;

/* Must add earnings for each assignment */

    hr_utility.trace('Adding earnings :  '|| to_char(regular_earnings) || ' to total earnings');
    total_earnings := total_earnings + regular_earnings;

    CLOSE salary_element;
    CLOSE freq_code;
    CLOSE asg_hours;
    CLOSE salary_basis_code;
    CLOSE periodic_salary;
    CLOSE work_schedule;
    CLOSE rate;
    CLOSE rate_code;
    CLOSE hours;
    CLOSE asg_salary;

    IF (p_run_type = 'L' OR
        l_regular_aggregate = 'N') THEN
       EXIT;
    END IF;

END LOOP;

CLOSE other_assignments;

hr_utility.trace('Total earnings :  '|| to_char(total_earnings));

IF total_earnings IS NULL THEN
     total_earnings := 0;
END IF;

RETURN total_earnings;

END Multi_Asg_Proration_Regular;

END pay_multiasg;

/
