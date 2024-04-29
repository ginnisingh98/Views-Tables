--------------------------------------------------------
--  DDL for Package Body PAY_IE_P35
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_IE_P35" AS
   /* $Header: pyiep35x.pkb 120.33.12010000.18 2010/02/20 10:21:08 rsahai ship $ */

--
-- Constants
--
   l_package                  VARCHAR2 (31) := 'pay_ie_p35.';
--
-- Global Variables
--
  -- Bug c_context_name - PRSI Context Balance Design Change
   l_assignment_action_id     pay_assignment_actions.assignment_action_id%TYPE;
   l_context_id               ff_contexts.context_id%TYPE;
   l_defined_balance_id       pay_defined_balances.defined_balance_id%TYPE;
   p_person_id_global         per_people_f.person_id%TYPE; -- to store the person_id in a package level variable to be used in c_context_name cursor
   l_class_count              NUMBER (4);
   l_weeks_at_initial_class   NUMBER (4);
   l_weeks_at_second_class    NUMBER (4);
   l_weeks_at_third_class     NUMBER (4);
   l_weeks_at_fourth_class    NUMBER (4);
   l_weeks_at_fifth_class     NUMBER (4);
   l_initial_class            pay_run_result_values.result_value%TYPE;
   l_second_class             pay_run_result_values.result_value%TYPE;
   l_third_class              pay_run_result_values.result_value%TYPE;
   l_fourth_class             pay_run_result_values.result_value%TYPE;
   l_fifth_class              pay_run_result_values.result_value%TYPE;
   l_context_value_counter    NUMBER (2) := 0;
   l_start_date               DATE;
   l_end_date                 DATE;
   l_bg_id                    NUMBER;
   l_segment4                 hr_soft_coding_keyflex.segment4%TYPE;
   l_assignment_set_id	      hr_assignment_sets.assignment_set_id%TYPE;
   l_payroll_id		      pay_all_payrolls_f.payroll_id%TYPE;


   -- declaring the pl/sql table for storing the first 5 contribution class values
   TYPE type_context_value_tab IS TABLE OF pay_run_result_values.result_value%TYPE
   INDEX BY BINARY_INTEGER;

   -- For 5 PRSI classes
   TYPE prsi_class is record
			(prsi_class pay_run_result_values.result_value%TYPE,
                   prsi_class_bal NUMBER(4));

   TYPE prsi_class_tab IS TABLE OF prsi_class INDEX BY BINARY_INTEGER;

   l_prsi_class_tab	prsi_class_tab;
   l_prsi_class_bal	prsi_class_tab;
   l_prsi_class_tab1	prsi_class_tab;  --8259095
   l_prsi_class_temp	prsi_class_tab; -- For making other tables empty

  -- declaring a pl/sql table for storing the the max assignment action ids against assignments for a person.
  -- Bug fix4004470
   TYPE asg_action_ids_tab IS TABLE OF pay_assignment_actions.assignment_action_id%TYPE
   INDEX BY BINARY_INTEGER;

   t_context_value            type_context_value_tab;
   t_empty_table              type_context_value_tab; -- for emptying the t_context_value pl/sql table

  -- t_asg_action_id               asg_action_ids_tab;  --Bug fix 4004470
  -- t_empty_asg_table             asg_action_ids_tab; -- for emptying the t_asg_action_id pl/sql table( Bug fix 4023794)
  t_asg_action_id			pay_assignment_actions.assignment_action_id%TYPE;


-- Bug 3460687 Temporary tables to hold Class Names
   t_context_value_balinit    type_context_value_tab;
   t_context_value_tmp        type_context_value_tab;
   p_start_date               DATE;
   p_end_date                 DATE;

--8259095
TYPE supp_wk_tab is table of number INDEX BY pay_run_result_values.result_value%TYPE;
l_supp_wk_tab supp_wk_tab;
l_supp_wk_tab_empty supp_wk_tab; --9080372
--8259095

--6633719
/* Function to check the override ppsn */
FUNCTION OVERRIDE_PPSN(asg_id NUMBER)
RETURN VARCHAR2
IS

CURSOR csr_ppsn_override(p_asg_id NUMBER)
IS
SELECT aei_information1 PPSN_OVERRIDE
FROM per_assignment_extra_info
WHERE assignment_id = p_asg_id
AND aei_information_category = 'IE_ASG_OVERRIDE';

l_ppsn_override varchar2(100);

BEGIN

  OPEN csr_ppsn_override(asg_id);
  FETCH csr_ppsn_override INTO l_ppsn_override;
  CLOSE csr_ppsn_override;
  RETURN l_ppsn_override;

END override_ppsn;
--6633719

   /*Added to check multiple assignments*/
FUNCTION check_multiple_assignments(p_assignment_id number
				   ,p_start_date date
				   ,p_end_date date
				   ,p_bg_id number)
RETURN NUMBER AS
l_person_id	per_people_f.person_id%TYPE;
l_actid	pay_assignment_actions.assignment_action_id%TYPE;

cursor csr_check_multiple_asg IS
	select paaf.person_id
	from  per_assignments_f paaf, per_assignments_f paaf1
	where paaf.assignment_id= p_assignment_id
	and   paaf.business_group_id = p_bg_id
	and   paaf.business_group_id =paaf1.business_group_id
	and   paaf.person_id = paaf1.person_id
	and   paaf1.primary_flag <> 'Y'
	and   paaf1.effective_end_date >= p_start_date
	and   paaf1.effective_start_date <= p_end_date;

cursor csr_get_max_assact is
SELECT MAX(paa.assignment_action_id)
	FROM per_assignments_f paf,
	      pay_assignment_actions paa,
	      pay_payroll_actions ppa,
	      per_time_periods ptp
	WHERE paf.person_id = l_person_id
	  AND paf.assignment_id = paa.assignment_id
	  AND paa.action_status = 'C'
	  AND ppa.payroll_action_id = paa.payroll_action_id
	  AND ppa.action_type in ('R','Q','I','B','V')
	  --AND ppa.time_period_id = ptp.time_period_id
	  --AND ptp.end_date BETWEEN p_start_date AND p_end_date
	  AND ppa.payroll_id = ptp.payroll_id                                       -- Bug 5070091 Offset payroll change
	  AND ppa.date_earned between ptp.start_date and ptp.end_date
	  AND ppa.effective_date between p_start_date and p_end_date
	  AND paf.effective_start_date <= p_end_date
	  AND paf.effective_end_date >= p_start_date;



   BEGIN

	open csr_check_multiple_asg;
	fetch csr_check_multiple_asg into l_person_id;
	CLOSE csr_check_multiple_asg;

	if l_person_id is not null then
		open csr_get_max_assact ;
		fetch csr_get_max_assact into l_actid;
		close csr_get_max_assact ;

		if l_actid is not null then
			return l_actid;
		else return -1;
		end if;
	else
		return -1;
	end if;
   END check_multiple_assignments;

--------------------------------------------------------------------------------
--  Added new procedure for P60 changes to PRSI section - 5657992
--  This function returns the IE PRSI Insurable weeks for this employment
--------------------------------------------------------------------------------
Function get_p60_prsi_weeks(p_prsi_class		varchar2,
				    l_segment4		number,
				    p_max_action_id	number,
				    p_assignment_action_id number) return number as
l_p60_weeks number;
BEGIN

	 l_p60_weeks := pay_balance_pkg.get_value (
					get_defined_balance_id ('_PER_PAYE_REF_PRSI_YTD', 'IE PRSI Insurable Weeks'),
		         		p_max_action_id,
					l_segment4,
		                  NULL,
				      l_context_id,
		                  p_prsi_class,
		                  NULL,
				      NULL
		               )
				   -
				   pay_balance_pkg.get_value (
					get_defined_balance_id ('_PER_PAYE_REF_PRSI_YTD', 'IE PRSI Insurable Weeks'),
		         		p_assignment_action_id,
					l_segment4,
		                  NULL,
				      l_context_id,
		                  p_prsi_class,
		                  NULL,
				      NULL
		               );
return l_p60_weeks;
END get_p60_prsi_weeks;


--------------------------------------------------------------------------------
-- Added new procedure for P60 changes to PRSI section - 5657992
-- This procedure calculates, this employment figures for
-- 1. IE PRSI Employee Contribution.
-- 2. IE PRSI Total Contribution (Employee + Employer
-- 3. IE PRSI Insurable weeks.
-- 4. IE PRSI contribution classes(initial and second class) and
-- insurable weeks for second class.
--------------------------------------------------------------------------------
PROCEDURE get_p60_prsi_details(p_assignment_action_id number,
					 p_max_action_id		number,
					 p_person_id		number,
					 p_segment4			hr_soft_coding_keyflex.segment4%TYPE,
					 p_tot_insurable_weeks	number,
					 p_prsi_employee_cont   number,
					 p_prsi_tot_cont		number,
					 p_insurable_weeks	out nocopy varchar2,
					 p_this_emp_prsi_cont   out nocopy varchar2,
					 p_this_tot_prsi		out nocopy varchar2,
					 p_this_initial_class	out nocopy varchar2,
					 p_this_sec_class		out nocopy varchar2,
					 p_this_weeks_at_sec_class out nocopy varchar2,
					 p_Act_Context_id  number default NULL,  --6633719
					 p_Act_Context_value varchar2 default NULL, --6633719
					 p_dimension_name varchar2 default '_PER_PAYE_REF_YTD',  --6633719
					 p_ppsn_override VARCHAR2 default NULL --6633719
                     ) is


l_child_assignemnt_action	pay_assignment_actions.assignment_action_id%TYPE;
l_p60_prsi				prsi_class_tab;

-- cursor to get child action
cursor c1 is
select assignment_action_id from pay_assignment_actions
where source_action_id = p_max_action_id;

-- This fetch all prsi classes from run-results where assignment action id
-- lies between child of p_max_action_id and p_assignment_action_id(last period max action id)
CURSOR get_prsi_classes is
SELECT   /*+ ordered */
                  asg.business_group_id business_group_id,
                  asg.person_id person_id, per.full_name full_name,
                  per.original_date_of_hire original_hire_date,
                  MIN (ptp.end_date) minimum_effective_date,
			asg.primary_flag,
			paa.assignment_action_id,
                  trim(rrv1.result_value) result_value
             FROM per_people_f per,
                  per_assignments_f asg,
                  pay_assignment_actions paa,
                  pay_payroll_actions ppa,
                  per_time_periods ptp,
                  pay_run_results prr,
                  pay_element_types_f pet,
                  pay_input_values_f piv1,
                  pay_run_result_values rrv1
            WHERE per.person_id = p_person_id
              AND per.current_employee_flag = 'Y'
              AND per.effective_start_date =
                        (SELECT MIN (per2.effective_start_date)
                           FROM per_people_f per2
             			      , per_periods_of_service pos2
                            WHERE per2.person_id = per.person_id
                            AND per2.effective_start_date <= p_end_date
			                AND pos2.person_id = per2.person_id
			                AND pos2.date_start between per2.effective_start_date and per2.effective_end_date
             			    AND NVL (pos2.final_process_date, p_end_date) >= p_start_date
             			    AND per2.current_employee_flag = 'Y'  )
              AND asg.person_id = per.person_id
              AND asg.effective_start_date =
                        (SELECT MIN (asg2.effective_start_date)
                           FROM per_assignments_f asg2,
			                    per_assignment_status_types ast
                            WHERE asg2.assignment_id = asg.assignment_id
                            AND asg2.effective_start_date <= p_end_date
                            AND NVL (asg2.effective_end_date, p_end_date) >= p_start_date
            			    AND asg2.assignment_type = 'E'
                            AND asg2.assignment_status_type_id = ast.assignment_status_type_id )
              AND asg.assignment_type = 'E'
              AND paa.assignment_id = asg.assignment_id
              AND paa.action_status = 'C'
              and paa.assignment_action_id > p_assignment_action_id
		  -- used nvl because for action_type='B' l_child_assignemnt_action will be null
              and paa.assignment_action_id <= nvl(l_child_assignemnt_action,p_max_action_id)
    		  AND paa.tax_unit_id = to_number(p_segment4)
              AND ppa.payroll_action_id = paa.payroll_action_id
              AND ppa.action_type IN ('Q', 'R', 'B')
              AND ppa.payroll_id = ptp.payroll_id
              AND ppa.date_earned between ptp.start_date and ptp.end_date
    		  and ppa.effective_date between p_start_date AND p_end_date
              AND pet.element_name = 'IE PRSI Contribution Class'
              AND pet.legislation_code = 'IE'
              AND pet.element_type_id = piv1.element_type_id
              AND piv1.NAME = 'Contribution_Class'
              AND piv1.legislation_code = 'IE'
              AND prr.assignment_action_id = paa.assignment_action_id
              AND prr.element_type_id = pet.element_type_id
              AND rrv1.input_value_id = piv1.input_value_id
              AND rrv1.run_result_id = prr.run_result_id
         GROUP BY asg.business_group_id,
                  asg.person_id,
                  per.full_name,
                  per.original_date_of_hire,
                  asg.primary_flag,
		      paa.assignment_action_id,
                  trim(rrv1.result_value)
         ORDER BY asg.primary_flag desc,minimum_effective_date,paa.assignment_action_id;
temp_flag    NUMBER (2);
l_counter    NUMBER (2) := 0;
l_p60_prsi_classes            type_context_value_tab;
l_p60_all_classes			prsi_class_tab;
l_p60_prsi_class_bal		prsi_class_tab;
l_cnt					number;
BEGIN

-- get the total insurable weeks for the last period max action id

hr_utility.set_location('Period action id..'||p_assignment_action_id,101);
hr_utility.set_location('Max action id..'|| p_max_action_id,101);

OPEN c1;
FETCH c1 into l_child_assignemnt_action;
CLOSE c1;

	p_insurable_weeks := to_char(p_tot_insurable_weeks - NVL (
		   pay_ie_p35.get_total_insurable_weeks (p_person_id
									,to_number(l_segment4)
									,p_assignment_action_id
									,p_Act_Context_id  --6633719
									,p_Act_Context_value --6633719
									,p_dimension_name  --6633719
                                    ,p_ppsn_override), --6633719
		   0
		));
hr_utility.set_location('p_tot_insurable_weeks..'|| p_tot_insurable_weeks,103);
hr_utility.set_location('p_insurable_weeks..'|| p_insurable_weeks,104);
	-- get the employee and total PRSI contribution till the last period max action id
	p_this_emp_prsi_cont :=    to_char(p_prsi_employee_cont -
					   	ROUND (
						     NVL (
							  pay_balance_pkg.get_value (
							     pay_ie_p35.get_defined_balance_id (
								  p_dimension_name,   --'_PER_PAYE_REF_YTD',  --6633719
								  'IE PRSI Employee'
							     ),
							     p_assignment_action_id,
							    l_segment4, -- paye reference value
							    null,
							    p_Act_Context_id,  --null,  -6633719
							    p_Act_Context_value,  --null,  --6633719
							    null,
							    null,
							    null,
							    'TRUE'
							  ),
							  0
						     )
						   + NVL (
							  pay_balance_pkg.get_value (
							     pay_ie_p35.get_defined_balance_id (
								  p_dimension_name,  --'_PER_PAYE_REF_YTD',  --6633719
								  'IE PRSI K Employee Lump Sum'
							     ),
							     p_assignment_action_id,
							     l_segment4, -- paye reference value
							    null,
							    p_Act_Context_id,  --null,  --6633719
							    p_Act_Context_value,  --null,  --6633719
							    null,
							    null,
							    null,
							    'TRUE'
							  ),
							  0
						     )
						   + NVL (
							  pay_balance_pkg.get_value (
							     pay_ie_p35.get_defined_balance_id (
								  '_PER_YTD',
								  'IE PRSI M Employee Lump Sum'
							     ),
							     p_assignment_action_id,
							     l_segment4, -- paye reference value
							    null,
							    null,
							    null,
							    null,
							    null,
							    null,
							    'TRUE'
							  ),
							  0
						     ),
						   2
						));
				   hr_utility.set_location ('p_prsi_employee_cont'|| p_this_emp_prsi_cont,105);
				   hr_utility.set_location ('p_this_emp_prsi_cont'|| p_this_emp_prsi_cont,106);

				   p_this_tot_prsi := to_char(p_prsi_tot_cont -
						ROUND (
						     NVL (
							  pay_balance_pkg.get_value (
							     pay_ie_p35.get_defined_balance_id (
								  p_dimension_name,  --'_PER_PAYE_REF_YTD',  --6633719
								  'IE PRSI Employee'
							     ),
							     p_assignment_action_id,
							     l_segment4, -- paye reference value
							    null,
							    p_Act_Context_id,  --null,  --6633719
							    p_Act_Context_value,  --null,  --6633719
							    null,
							    null,
							    null,
							    'TRUE'
							  ),
							  0
						     )
						   + NVL (
							  pay_balance_pkg.get_value (
							     pay_ie_p35.get_defined_balance_id (
								  p_dimension_name,  --'_PER_PAYE_REF_YTD',  --6633719
								  'IE PRSI Employer'
							     ),
							     p_assignment_action_id,
							     l_segment4, -- paye reference value
							    null,
							    p_Act_Context_id,  --null,  --6633719
							    p_Act_Context_value,  --null,  --6633719
							    null,
							    null,
							    null,
							    'TRUE'
							  ),
							  0
						     )
						   + NVL (
							  pay_balance_pkg.get_value (
							     pay_ie_p35.get_defined_balance_id (
								  p_dimension_name,  --'_PER_PAYE_REF_YTD',  --6633719
								  'IE PRSI K Employee Lump Sum'
							     ),
							     p_assignment_action_id,
							   l_segment4, -- paye reference value
							    null,
							    p_Act_Context_id,  --null,  --6633719
							    p_Act_Context_value,  --null,  --6633719
							    null,
							    null,
							    null,
							    'TRUE'
							  ),
							  0
						     )
						   + NVL (
							  pay_balance_pkg.get_value (
							     pay_ie_p35.get_defined_balance_id (
								  p_dimension_name,  --'_PER_PAYE_REF_YTD',  --6633719
								  'IE PRSI M Employee Lump Sum'
							     ),
							     p_assignment_action_id,
							     l_segment4, -- paye reference value
							    null,
							    p_Act_Context_id,  --null,  --6633719
							    p_Act_Context_value,  --null,  --6633719
							    null,
							    null,
							    null,
							    'TRUE'
							  ),
							  0
						     )
						   + NVL (
							  pay_balance_pkg.get_value (
							     pay_ie_p35.get_defined_balance_id (
								  p_dimension_name,  --'_PER_PAYE_REF_YTD',  --6633719
								  'IE PRSI K Employer Lump Sum'
							     ),
							     p_assignment_action_id,
							     l_segment4, -- paye reference value
							    null,
							    p_Act_Context_id,  --null,  --6633719
							    p_Act_Context_value,  --null,  --6633719
							    null,
							    null,
							    null,
							    'TRUE'
							  ),
							  0
						     )
						   + NVL (
							  pay_balance_pkg.get_value (
							     pay_ie_p35.get_defined_balance_id (
								  p_dimension_name,  --'_PER_PAYE_REF_YTD',  --6633719
								  'IE PRSI M Employer Lump Sum'
							     ),
							     p_assignment_action_id,
							     l_segment4, -- paye reference value
							    null,
							    p_Act_Context_id,  --null,  --6633719
							    p_Act_Context_value,  --null,  --6633719
							    null,
							    null,
							    null,
							    'TRUE'
							  ),
							  0
						     ),
						   2
						));
				hr_utility.set_location ('p_this_tot_prsi'|| p_this_tot_prsi,105);
				hr_utility.set_location ('p_prsi_tot_cont'|| p_prsi_tot_cont,106);
FOR i IN get_prsi_classes
LOOP
	IF l_counter = 0 THEN
		l_counter := l_counter + 1;
		l_p60_prsi_classes(l_counter) := i.result_value;
		hr_utility.set_location ('Initial Class Value is :'|| l_p60_prsi_classes(l_counter), 16);
	ELSE
		FOR k IN 1 .. l_counter
		loop
			IF l_p60_prsi_classes(k) = i.result_value THEN
				temp_flag :=1;
				exit;
			ELSE
				temp_flag :=0;
			END IF;
		END LOOP;
		IF temp_flag = 0 AND l_counter <=9 THEN
			l_counter := l_counter + 1;
			l_p60_prsi_classes(l_counter) := i.result_value;
			hr_utility.set_location ('Subsequent Class Value is :'|| l_p60_prsi_classes(l_counter), 17);
		END IF;
		temp_flag := null;
	END IF;
END LOOP;

FOR i in 1..l_p60_prsi_classes.COUNT
LOOP
	l_p60_all_classes(i).prsi_class := substr(l_p60_prsi_classes(i),4,2);
	l_p60_all_classes(i).prsi_class_bal := get_p60_prsi_weeks(l_p60_prsi_classes(i),
							                      to_number(l_segment4),
										    p_max_action_id,
										    p_assignment_action_id);
END LOOP;

--Collect all PRSI classes with non-zero PRSI weeks in a separate PL/SQL table
l_cnt :=0;
FOR i in 1..l_p60_all_classes.COUNT
LOOP
	IF l_p60_all_classes(i).prsi_class_bal<>0 then
		l_cnt := l_cnt + 1;
		l_p60_prsi_class_bal(l_cnt).prsi_class := l_p60_all_classes(i).prsi_class;
		l_p60_prsi_class_bal(l_cnt).prsi_class_bal := l_p60_all_classes(i).prsi_class_bal;
	END IF;
END LOOP;

-- get the initial and second from the non zero
-- plsql table.Sine the req is to display only non zero clases
IF l_cnt >=1 then
	if l_p60_prsi_class_bal(1).prsi_class is not null then
		p_this_initial_class	     := l_p60_prsi_class_bal(1).prsi_class;
	end if;
END IF;


IF l_cnt >1 then
	if l_p60_prsi_class_bal(2).prsi_class is not null then
		p_this_sec_class	       := l_p60_prsi_class_bal(2).prsi_class;
		p_this_weeks_at_sec_class := l_p60_prsi_class_bal(2).prsi_class_bal;
	end if;
END IF;

-- empty the pl/sql tables.
l_p60_prsi_class_bal := l_prsi_class_temp;
l_p60_prsi_class_bal := l_prsi_class_temp;

END get_p60_prsi_details;

--------------------------------------------------------------------------------+
--
--------------------------------------------------------------------------------+

   FUNCTION get_parameter (
      p_payroll_action_id   IN   NUMBER,
      p_token_name          IN   VARCHAR2
   )
      RETURN VARCHAR2
   AS
      CURSOR csr_parameter_info (p_pact_id NUMBER, p_token CHAR)
      IS
         SELECT SUBSTR (
                   legislative_parameters,
                     INSTR (legislative_parameters, p_token)
                   + (  LENGTH (p_token)
                      + 1
                     ),
                     INSTR (
                        legislative_parameters,
                        ' ',
                        INSTR (legislative_parameters, p_token)
                     )
                   - (  INSTR (legislative_parameters, p_token)
                      + LENGTH (p_token)
                     )
                ),
                business_group_id bg_id
           FROM pay_payroll_actions
          WHERE payroll_action_id = p_pact_id;

      l_business_group_id   NUMBER;
      l_token_value         VARCHAR2 (50);
   BEGIN
      hr_utility.set_location (   'p_token_name = '
                               || p_token_name, 20);
      OPEN csr_parameter_info (p_payroll_action_id, p_token_name);
      FETCH csr_parameter_info INTO l_token_value, l_business_group_id;
      CLOSE csr_parameter_info;

      IF p_token_name = 'BG_ID'
      THEN
         l_token_value := TO_CHAR (l_business_group_id);
      ELSE
         l_token_value := TRIM (l_token_value);
      END IF;

      hr_utility.set_location (   'l_token_value = '
                               || l_token_value, 20);
      hr_utility.set_location (   'Leaving         '
                               || 'get_parameters', 30);
      RETURN l_token_value;
   END get_parameter;

   FUNCTION get_defined_balance_id (
      p_dimension_name   VARCHAR2,
      p_balance_name     VARCHAR2
   )
      RETURN NUMBER
   AS
      CURSOR csr_defined_balance_id
      IS
         SELECT pdb.defined_balance_id
           FROM pay_balance_dimensions pbd,
                pay_balance_types pbt,
                pay_defined_balances pdb
          WHERE pbd.dimension_name = p_dimension_name
            AND pbd.business_group_id IS NULL
            AND pbd.legislation_code = 'IE'
            AND pbt.balance_name = p_balance_name
            AND pbt.business_group_id IS NULL
            AND pbt.legislation_code = 'IE'
            AND pdb.balance_type_id = pbt.balance_type_id
            AND pdb.balance_dimension_id = pbd.balance_dimension_id
            AND pdb.business_group_id IS NULL
            AND pdb.legislation_code = 'IE';

      l_defined_balance_id   pay_defined_balances.defined_balance_id%TYPE;
   BEGIN
      OPEN csr_defined_balance_id;
      FETCH csr_defined_balance_id INTO l_defined_balance_id;
      CLOSE csr_defined_balance_id;
      RETURN l_defined_balance_id;
   END;


--------------------------------------------------------------------------------+
 -- Range cursor returns the ids of the assignments to be archived
 --------------------------------------------------------------------------------+
   PROCEDURE range_code (
      p_payroll_action_id   IN              NUMBER,
      sqlstr              OUT NOCOPY      VARCHAR2
   )
   IS
      l_proc_name                VARCHAR2 (100) :=    l_package|| 'range_code';
      l_dummy                    NUMBER;
      p30_error                  EXCEPTION;
      l_payroll_action_message   VARCHAR2 (255);
      l_start_date               DATE;
      l_end_date                 DATE;
      l_bg_id                    NUMBER;
	l_out_var               VARCHAR2 (30);
      --
CURSOR csr_p30_process
      IS
         SELECT NVL (MIN (ppa.payroll_action_id), 0)
           FROM pay_payroll_actions ppa
          WHERE ppa.report_type = 'IEP30_PRGLOCK'
            AND ppa.action_status = 'C'
            AND TO_DATE (
                   pay_ie_p35.get_parameter (
                      ppa.payroll_action_id,
                      'END_DATE'
                   ),
                   'YYYY/MM/DD'
                ) between l_start_date and l_end_date
            AND ppa.business_group_id = l_bg_id;
vik_str varchar2(2000);
   BEGIN
	--hr_utility.trace_on(null,'vikp35');

      hr_utility.set_location (l_proc_name, 1);
	l_out_var := pay_ie_p35.get_parameter (
					p_payroll_action_id=> p_payroll_action_id,
					p_token_name=> 'END_DATE'
					);
      l_end_date := TO_DATE (l_out_var, 'YYYY/MM/DD');
      l_out_var := pay_ie_p35.get_parameter (
					p_payroll_action_id=> p_payroll_action_id,
			            p_token_name=> 'START_DATE'
					);
      l_start_date := TO_DATE (l_out_var, 'YYYY/MM/DD');
      l_out_var := pay_ie_p35.get_parameter (
					p_payroll_action_id=> p_payroll_action_id,
			            p_token_name=> 'BG_ID'
					);
      l_bg_id := TO_NUMBER (l_out_var);

     /* hr_utility.set_location ('Start Date '||to_char(l_start_date), 2);
	hr_utility.set_location ('End Date '|| to_char(l_end_date), 3);
	hr_utility.set_location ('Business Group id '|| to_char(l_bg_id), 4);*/

      -- Check to make sure there is a p30 process run
      -- existing for business group, otherwise fail
hr_utility.set_location ('End Date 1',22);
      OPEN csr_p30_process;
      FETCH csr_p30_process INTO l_dummy;
hr_utility.set_location ('End Date 2',22);
      IF l_dummy = 0
      THEN
         CLOSE csr_p30_process;
         RAISE p30_error;
      END IF;

      CLOSE csr_p30_process;
      --
  hr_utility.set_location ('End Date 3',22);
      sqlstr := 'select distinct asg.person_id
                   from per_periods_of_service pos,
                        per_assignments_f      asg,
                        pay_payroll_actions    ppa
                  where ppa.payroll_action_id = :payroll_action_id
                    and pos.person_id         = asg.person_id
                    and pos.period_of_service_id = asg.period_of_service_id
                    and pos.business_group_id = ppa.business_group_id
                    and asg.business_group_id = ppa.business_group_id
                  order by asg.person_id';
  hr_utility.set_location ('End Date 4',22);

EXCEPTION
      WHEN p30_error
      THEN
         -- Write to the conc logfile, and try to archive err msg.
         hr_utility.set_location (
               ' Leaving with EXCEPTION: '
            || l_proc_name,
            100
         );
         l_payroll_action_message :=
               SUBSTR (
                  'P35 Report Process Failed: No P30 Process exists for the Business Group as on the specified end date.',
                  1,
                  240
               );
         fnd_file.put_line (fnd_file.LOG, l_payroll_action_message);

   END range_code;


--------------------------------------------------------------------------------+
-- Creates assignment action id for all the valid person id's in
-- the range selected by the Range code.
-- Locks the max assignment action(can be from P30, Prepayment for run-result
-- for a given assignment.
--------------------------------------------------------------------------------+
   PROCEDURE action_creation (
      pactid      IN   NUMBER,
      stperson    IN   NUMBER,
      endperson   IN   NUMBER,
      CHUNK       IN   NUMBER
      ) IS

l_proc_name             VARCHAR2 (100) := l_package|| 'assignment_action_code';
l_actid                 NUMBER;
l_locked_action         NUMBER;
l_out_var               VARCHAR2 (30);
l_aact_id			pay_assignment_actions.assignment_action_id%TYPE;
l_set_flag			hr_assignment_set_amendments.include_or_exclude%TYPE ;
l_temp_person_id		per_people_f.person_id%TYPE :=0;
l_start_date		date;
l_end_date			date;
l_bg_id			number;

CURSOR csr_get_flag_from_set
IS
	SELECT DISTINCT hasa.include_or_exclude FROM
		hr_assignment_set_amendments hasa,
		hr_assignment_sets has
	WHERE hasa.assignment_set_id = has.assignment_set_id
	AND	has.business_group_id  = l_bg_id
	AND	has.assignment_set_id  = l_assignment_set_id;

CURSOR csr_locked_asgs
IS
	SELECT /*+ ORDERED USE_NL(asg, paa, ppa, ptp, flex) push_subq */
		asg.person_id,
		paa.assignment_id,
		fnd_number.canonical_to_number(substr(max(lpad(paa.action_sequence,15,'0')||paa.assignment_action_id),16)) aa -- Bug 4672715
		,fnd_number.canonical_to_number(substr(min(lpad(paa.action_sequence,15,'0')||paa.assignment_action_id),16)) aamin -- 8322991
	FROM  per_assignments_f asg,
		pay_assignment_actions paa,
		pay_payroll_actions ppa,
		pay_all_payrolls_f pap,
		per_time_periods ptp,
		hr_soft_coding_keyflex flex
	WHERE paa.source_action_id IS NULL
	  AND paa.payroll_action_id = ppa.payroll_action_id
	  --Added for date track updates of payroll with diff pay ref no
	  AND ppa.payroll_id = pap.payroll_id
	  /* For time period impact */
	  -- AND ppa.time_period_id = ptp.time_period_id                          -- Bug 5070091 Offset payroll change
	  AND ppa.payroll_id = ptp.payroll_id
	  AND ppa.date_earned between ptp.start_date and ptp.end_date
	  --AND ptp.end_date BETWEEN l_start_date AND l_end_date
	  AND ppa.effective_date between l_start_date AND l_end_date
	  ---
	  AND paa.action_status = 'C'
	  AND ppa.action_type IN ('R','Q','I','B','V') --Bug Fix 3747646
	  AND ppa.business_group_id = l_bg_id
	  AND paa.assignment_id = asg.assignment_id
	  AND asg.effective_start_date <= l_end_date
	  AND asg.effective_end_date >= l_start_date
	  --AND asg.primary_flag = 'Y'
	  AND asg.business_group_id = ppa.business_group_id
	  AND asg.person_id BETWEEN stperson AND endperson
	  --decode added to pick the previous assignments also in case of ReHire having diff overrides.
	  AND asg.effective_end_date = DECODE(OVERRIDE_PPSN(asg.assignment_id),NULL, --6633719
		     (SELECT MAX (paf.effective_end_date)
			   FROM per_assignments_f paf,
				  pay_assignment_actions paa1, --Bug fix 4130665
				  pay_payroll_actions ppa1,
				  per_time_periods ptp1      --Tar 15081088.6
                         ,pay_all_payrolls_f pay
				 ,hr_soft_coding_keyflex flex1
			   WHERE paf.person_id = asg.person_id
	    --            AND paf.primary_flag = 'Y'
			    --Added for bug fix 4130665
			    AND paf.assignment_id = paa1.assignment_id
			    AND paa1.action_status = 'C'
			    AND ppa1.payroll_action_id = paa1.payroll_action_id
			    AND ppa1.action_type in ('R','Q','I','B','V')
			    /* For time period impact */
			    --AND ppa1.time_period_id = ptp1.time_period_id          --Tar 15081088.6
			    AND ppa1.payroll_id = ptp1.payroll_id
                      AND ppa1.date_earned between ptp1.start_date and ptp1.end_date
			    AND ppa1.effective_date between l_start_date AND l_end_date
			    ---------
			    --AND ptp.end_date BETWEEN l_start_date AND l_end_date   --Tar 15081088.6      -- Bug 5070091 Offset payroll change
			    and pay.payroll_id = paf.payroll_id
			    and pay.soft_coding_keyflex_id = flex1.soft_coding_keyflex_id
			    and flex1.segment4 = l_segment4
			    AND ((paf.payroll_id = asg.payroll_id AND
				    paf.assignment_id =asg.assignment_id)
				  OR paf.assignment_id <> asg.assignment_id)    -- Fix for duplicate records in Rehire case
			    AND paf.effective_start_date <= l_end_date
			    AND paf.effective_end_date >= l_start_date
			    AND pay.effective_start_date <= l_end_date
			    AND pay.effective_end_date >= l_start_date)	-- Bug 4867657
			    ,asg.effective_end_date) --6633719
	  --Added for bug fix 3567562,to restrict the assignments to the PAYE reference selected as parameter.
	  AND pap.payroll_id = asg.payroll_id
	  AND flex.soft_coding_keyflex_id = pap.soft_coding_keyflex_id
	  -- Bug 4142582
	  AND flex.segment4 = l_segment4
	  AND pap.effective_start_date <= l_end_date
	  AND pap.effective_end_date >= l_start_date
	  AND (pap.payroll_id in (select b.payroll_id from per_assignments_f a,per_assignments_f b
					  where a.payroll_id = l_payroll_id
					  and a.person_id = b.person_id
					  and a.person_id = asg.person_id
					  --bug 6642916
					  and a.effective_start_date<= l_end_date
					and a.effective_end_date>= l_start_date)
					or l_payroll_id is null)  -- Vik Added for payroll
	--and check_assignment_in_set(asg.assignment_id,l_assignment_set_id,l_bg_id)=1
	  AND ((l_assignment_set_id is not null
	     AND (l_set_flag ='I' AND EXISTS(SELECT 1
						    FROM  hr_assignment_set_amendments hasa
							 ,  hr_assignment_sets has
							 ,  per_assignments_f paf
						--	 ,  pay_all_payrolls_f pay
						--	 ,  hr_soft_coding_keyflex hflex
					  WHERE has.assignment_set_id = hasa.assignment_set_id
					  AND   has.business_group_id = l_bg_id
					  AND   has.assignment_set_id = l_assignment_set_id
					  AND   hasa.assignment_id    = paf.assignment_id
					  AND   paf.person_id         = asg.person_id)
					  --AND   paf.payroll_id        = pay.payroll_id
					  --AND   pay.soft_coding_keyflex_id = hflex.soft_coding_keyflex_id
					  --AND   hflex.segment4 = l_segment4)
		OR l_set_flag = 'E' AND NOT EXISTS(SELECT 1
						    FROM  hr_assignment_set_amendments hasa
							 ,  hr_assignment_sets has
							 ,  per_assignments_f paf
						--	 ,  pay_all_payrolls_f pay
						--	 ,  hr_soft_coding_keyflex hflex
					  WHERE has.assignment_set_id = hasa.assignment_set_id
					  AND   has.business_group_id = l_bg_id
					  AND   has.assignment_set_id = l_assignment_set_id
					  AND   hasa.assignment_id    = paf.assignment_id
					  AND   paf.person_id         = asg.person_id
					  --AND   paf.payroll_id        = pay.payroll_id
					  --AND   pay.soft_coding_keyflex_id = hflex.soft_coding_keyflex_id
					  --AND   hflex.segment4 = l_segment4
					  )))
	  OR l_assignment_set_id IS NULL)
	  AND NOT EXISTS (
			SELECT 1
			  FROM pay_assignment_actions paa_p35,
				 pay_payroll_actions ppa_p35,
				 per_assignments_f paaf_p35,
				 pay_all_payrolls_f ppf_p35,
				hr_soft_coding_keyflex flex_p35,
				pay_action_interlocks plock
			 WHERE ppa_p35.report_type = 'IEP35'
			   AND paa_p35.action_status = 'C'
			   AND TO_CHAR ( TO_DATE (
				    pay_ie_p35.get_parameter (
					 ppa_p35.payroll_action_id,
					 'END_DATE'
				    ),'YYYY/MM/DD'),'YYYY') = TO_CHAR(l_end_date,'YYYY')               --4641756
			   AND ppa_p35.payroll_action_id = paa_p35.payroll_action_id
			   --AND paa_p35.assignment_id = asg.assignment_id
			   AND paa_p35.assignment_id = paaf_p35.assignment_id
			   AND paaf_p35.person_id = asg.person_id
			   and paa_p35.assignment_action_id = plock.locking_action_id
			   and plock.locked_action_id in (select assignment_action_id from pay_assignment_actions
			                                  where assignment_id=asg.assignment_id)
			   AND paaf_p35.payroll_id = ppf_p35.payroll_id
			   AND ppf_p35.soft_coding_keyflex_id = flex_p35.soft_coding_keyflex_id
			   AND flex_p35.segment4 = l_segment4)
	GROUP BY asg.person_id,paa.assignment_id
	ORDER BY asg.person_id,
	fnd_number.canonical_to_number(substr(max(lpad(paa.action_sequence,15,'0')||paa.assignment_action_id),16)) desc, -- Bug 4672715
	paa.assignment_id desc;

--6633719
cursor csr_ppsn_override(p_asg_id number)
is
select aei_information1 PPSN_OVERRIDE
from per_assignment_extra_info
where assignment_id = p_asg_id
and aei_information_category = 'IE_ASG_OVERRIDE';

l_ppsn_override per_assignment_extra_info.aei_information1%type;

cursor csr_ppsn_max_asg(p_ppsn_override varchar2, p_person_id number)
is
select MAX(paei.assignment_id) ovrride_asg
from per_assignment_extra_info paei
where paei.information_type = 'IE_ASG_OVERRIDE'
and paei.aei_information1 = p_ppsn_override
and exists
(select 1 from per_all_assignments_f paaf
  where paaf.assignment_id = paei.assignment_id
  and paaf.person_id  = p_person_id)
GROUP BY paei.aei_information1;

l_ppsn_override_asg per_assignment_extra_info.assignment_id%type;

--6633719

/*  --8322991
-- Dont create action if the latest tax basis is exclusion 5867343
CURSOR csr_exclusion (p_action_id NUMBER) IS
SELECT 'Y', ppa.action_type
  FROM pay_run_result_values prrv,
       pay_run_results prr,
       pay_input_values_f pivf,
       pay_element_types_f pet,
       pay_assignment_actions paa,
	 pay_payroll_actions ppa
 WHERE ppa.payroll_action_id= paa.payroll_action_id
   AND ((paa.source_action_id= p_action_id
   AND prr.assignment_action_id = paa.assignment_action_id )
      OR (paa.assignment_action_id = p_action_id AND prr.assignment_action_id = paa.assignment_action_id ))
   AND prr.element_type_id = pet.element_type_id
   AND pet.element_name = 'IE PAYE details'
   AND prrv.run_result_id = prr.run_result_id
   AND prrv.input_value_id = pivf.input_value_id
   AND pivf.name = 'Tax Basis'
   and result_value = 'IE_EXCLUDE';
*/ --8322991

--8322991
-- Dont create action if the tax basis is exclusion for whole year(Tax Period).
CURSOR csr_exclusion_year (p_action_id_min NUMBER, p_action_id_max NUMBER, p_asg_id NUMBER) IS
SELECT count(1) cnt
  FROM pay_run_result_values prrv,
       pay_run_results prr,
       pay_input_values_f pivf,
       pay_element_types_f pet,
       pay_assignment_actions paa,
	 pay_payroll_actions ppa
 WHERE ppa.payroll_action_id= paa.payroll_action_id
   AND paa.assignment_id = p_asg_id
   AND ((paa.source_action_id between p_action_id_min AND p_action_id_max
   AND prr.assignment_action_id = paa.assignment_action_id )
      OR (paa.assignment_action_id between p_action_id_min AND p_action_id_max AND prr.assignment_action_id = paa.assignment_action_id ))
   AND prr.element_type_id = pet.element_type_id
   AND pet.element_name = 'IE PAYE details'
   AND prrv.run_result_id = prr.run_result_id
   AND prrv.input_value_id = pivf.input_value_id
   AND pivf.name = 'Tax Basis'
   and result_value <> 'IE_EXCLUDE';

l_count NUMBER := 0;
--8322991

--8874161
CURSOR csr_inc_levy(p_action_id_max NUMBER, p_asg_id NUMBER)
IS
SELECT
pay_balance_pkg.get_value (
pay_ie_p35.get_defined_balance_id (
DECODE(PAY_IE_P35.OVERRIDE_PPSN(p_asg_id),NULL,'_PER_PAYE_REF_YTD','_PER_PAYE_REF_PPSN_YTD'),
'IE Income Tax Levy'),
p_action_id_max,
l_segment4,
null,
null,
null,
null,
null,
null,
'TRUE'
)
FROM DUAL;

l_levi_amount number := 0;
--8874161

CURSOR csr_action_type (p_assignment_id NUMBER) IS
SELECT fnd_number.canonical_to_number(substr(max(lpad(paa.action_sequence,15,'0')||paa.assignment_action_id),16)) asg_action_id
  FROM pay_assignment_actions paa,
	 pay_payroll_actions ppa
 WHERE ppa.payroll_action_id = paa.payroll_action_id
   and paa.assignment_id = p_assignment_id
   and ppa.action_type in ('R','Q')
   and paa.source_action_id is null
   AND ppa.effective_date between l_start_date AND l_end_date;


l_flag_exclusion	varchar2(1) := 'N';
l_flag_action_type	pay_payroll_actions.action_type%TYPE;
l_flag_action_id		pay_assignment_actions.assignment_action_id%TYPE;
BEGIN

	--
	l_segment4 := pay_ie_p35.get_parameter( p_payroll_action_id=> pactid,
							    p_token_name=> 'EMP_NO');
	l_out_var := pay_ie_p35.get_parameter (
			    p_payroll_action_id=> pactid,
			    p_token_name=> 'ASSIGNMENT_SET_ID'
			 );
	l_assignment_set_id := to_number(l_out_var);

	l_out_var := pay_ie_p35.get_parameter (
			    p_payroll_action_id=> pactid,
			    p_token_name=> 'PAYROLL'
			 );
	l_payroll_id := to_number(l_out_var);

	l_out_var := pay_ie_p35.get_parameter (
					p_payroll_action_id=> pactid,
					p_token_name=> 'END_DATE'
					);
      l_end_date := TO_DATE (l_out_var, 'YYYY/MM/DD');
      l_out_var := pay_ie_p35.get_parameter (
					p_payroll_action_id=> pactid,
			            p_token_name=> 'START_DATE'
					);
      l_start_date := TO_DATE (l_out_var, 'YYYY/MM/DD');
      l_out_var := pay_ie_p35.get_parameter (
					p_payroll_action_id=> pactid,
			            p_token_name=> 'BG_ID'
					);
      l_bg_id := TO_NUMBER (l_out_var);

	hr_utility.set_location ('l_segment4 ' ||l_segment4, 12);
	hr_utility.set_location ('l_assignment_set_id ' || to_char(l_assignment_set_id), 12);
	hr_utility.set_location ('l_payroll_id ' || to_char(l_payroll_id), 13);
	hr_utility.set_location ('stperson ' || to_char(stperson), 14);
	hr_utility.set_location ('endperson ' || to_char(endperson), 15);
	hr_utility.set_location ('l_bg_id ' || to_char(l_bg_id), 16);
	hr_utility.set_location ('pactid ' || to_char(pactid), 16);

	--
	OPEN csr_get_flag_from_set;
	FETCH csr_get_flag_from_set into l_set_flag;
	CLOSE csr_get_flag_from_set;
	--
	l_temp_person_id := 0;
--6633719QA
	l_ppsn_override := NULL;
	l_ppsn_override_asg := NULL;
--6633719QA

	FOR csr_select_asg_rec IN csr_locked_asgs
	LOOP
	hr_utility.set_location('Person id..'||to_char(csr_select_asg_rec.person_id),17);
	hr_utility.set_location('Temp Person id..'||to_char(l_temp_person_id),18);
	hr_utility.set_location('csr_select_asg_rec.assignment_id'||to_char(csr_select_asg_rec.assignment_id),18);
--6633719QA
--Reinitailising the variables as person changes.
    IF l_temp_person_id <> csr_select_asg_rec.person_id
    THEN
    l_ppsn_override := NULL;
    l_ppsn_override_asg := NULL;
    END IF;
--6633719QA
	--
	--6633719
            OPEN csr_ppsn_override(csr_select_asg_rec.assignment_id);
            FETCH csr_ppsn_override INTO l_ppsn_override;
--6633719QA
            IF csr_ppsn_override%NOTFOUND THEN
            l_ppsn_override := NULL;
            END IF;
--6633719QA
            CLOSE csr_ppsn_override;

	hr_utility.set_location('l_ppsn_override'||to_char(l_ppsn_override),19);
            IF l_ppsn_override IS NOT NULL   --6633719QA
            THEN
			OPEN csr_ppsn_max_asg(l_ppsn_override,csr_select_asg_rec.person_id);
			FETCH csr_ppsn_max_asg INTO l_ppsn_override_asg;
			CLOSE csr_ppsn_max_asg;
            END IF;  --6633719QA
	hr_utility.set_location('l_ppsn_override_asg'||to_char(l_ppsn_override_asg),20);

		-- Create assignment action per person
        IF ((l_temp_person_id <> csr_select_asg_rec.person_id
            and l_ppsn_override IS NULL)
            OR
            (l_ppsn_override_asg = csr_select_asg_rec.assignment_id
            and l_ppsn_override IS NOT NULL)
            )
        THEN
    --6633719
			--8322991
			l_count := 0;
			l_levi_amount := 0; --8874161
hr_utility.set_location('csr_select_asg_rec.aamin '||to_char(csr_select_asg_rec.aamin),18);
hr_utility.set_location('csr_select_asg_rec.aa '||to_char(csr_select_asg_rec.aa),18);
hr_utility.set_location('csr_select_asg_rec.assignment_id '||to_char(csr_select_asg_rec.assignment_id),18);

			OPEN  csr_exclusion_year(csr_select_asg_rec.aamin, csr_select_asg_rec.aa, csr_select_asg_rec.assignment_id);
			FETCH csr_exclusion_year INTO l_count;
			CLOSE csr_exclusion_year;

			--8874161
			OPEN csr_inc_levy(csr_select_asg_rec.aa, csr_select_asg_rec.assignment_id);
			FETCH csr_inc_levy INTO l_levi_amount;
			CLOSE csr_inc_levy;

			IF l_count <> 0 OR  l_levi_amount <> 0 THEN  --8874161
					SELECT pay_assignment_actions_s.NEXTVAL
					INTO l_actid
					FROM DUAL;

hr_utility.set_location('INSIDE IF',18);
hr_utility.set_location('Insert asg actions asg_id '||to_char(csr_select_asg_rec.assignment_id),18);
hr_utility.set_location('Insert asg actions l_actid '||to_char(l_actid),18);
hr_utility.set_location('Insert asg actions pactid '||to_char(pactid),18);

					hr_nonrun_asact.insact (l_actid,
									csr_select_asg_rec.assignment_id,
									pactid,
									CHUNK,
									to_number(l_segment4)
									);
			END IF;
			--8322991

/* --8322991  Commented the code
		      -- 5867343
			l_flag_exclusion := 'N';
			OPEN csr_exclusion(csr_select_asg_rec.aa);
			FETCH csr_exclusion into l_flag_exclusion, l_flag_action_type;
			CLOSE csr_exclusion;

			IF l_flag_exclusion <> 'Y' then
				IF l_flag_action_type not in ('I','B','V') then
					SELECT pay_assignment_actions_s.NEXTVAL
					INTO l_actid
					FROM DUAL;

hr_utility.set_location('INSIDE IF',18);
hr_utility.set_location('Insert asg actions asg_id '||to_char(csr_select_asg_rec.assignment_id),18);
hr_utility.set_location('Insert asg actions l_actid '||to_char(l_actid),18);
hr_utility.set_location('Insert asg actions pactid '||to_char(pactid),18);

					hr_nonrun_asact.insact (l_actid,
									csr_select_asg_rec.assignment_id,
									pactid,
									CHUNK,
									to_number(l_segment4)
									);
				ELSE
					-- get the last run
					OPEN csr_action_type(csr_select_asg_rec.assignment_id);
					FETCH csr_action_type into l_flag_action_id;
					CLOSE csr_action_type;

					OPEN csr_exclusion(l_flag_action_id);
					FETCH csr_exclusion into l_flag_exclusion, l_flag_action_type;
					CLOSE csr_exclusion;

					IF l_flag_exclusion <> 'Y' then
						SELECT pay_assignment_actions_s.NEXTVAL
						INTO l_actid
						FROM DUAL;
hr_utility.set_location('INSIDE ELSE',18);
hr_utility.set_location('Insert asg actions asg_id '||to_char(csr_select_asg_rec.assignment_id),18);
hr_utility.set_location('Insert asg actions l_actid '||to_char(l_actid),18);
hr_utility.set_location('Insert asg actions pactid '||to_char(pactid),18);
						hr_nonrun_asact.insact (l_actid,
									csr_select_asg_rec.assignment_id,
									pactid,
									CHUNK,
									to_number(l_segment4)
									);
					END IF;
				END IF;
			END IF;
*/ --8322991

		END IF;
		--
		-- Lock all the run-result assignment actions for a person per assignment.
		-- IF l_flag_exclusion <> 'Y' then  --8322991
		IF l_count <> 0 OR l_levi_amount <> 0 THEN  --8874161

hr_utility.set_location('Insert asg action Intlks l_actid'||to_char(l_actid),18);
hr_utility.set_location('Insert asg action Intlks  csr_select_asg_rec.aa'||to_char(csr_select_asg_rec.aa),18);
			hr_nonrun_asact.insint (l_actid,csr_select_asg_rec.aa);
		END IF;
		l_temp_person_id := csr_select_asg_rec.person_id;
	--
	END LOOP;

hr_utility.set_location ('Leaving action_creation', 18);
END action_creation;


Procedure archive_code  (p_assactid       IN NUMBER
				,p_effective_date IN DATE) is


	l_proc_name                      VARCHAR2 (100) := l_package|| 'archive_code';
      l_actid                          NUMBER;
      l_locked_action                  NUMBER;
      l_out_var                        VARCHAR2 (30);
      l_effective_date                 DATE;
      l_arch_ppsn                      pay_action_information.action_information4%TYPE;
      l_arch_works_number              pay_action_information.action_information14%TYPE
                                                                   DEFAULT ' '; --BUG 3306202 Added default value
	l_segment4				   hr_soft_coding_keyflex.segment4%TYPE;
      l_arch_person_id                 per_assignments_f.person_id%TYPE;
      l_arch_assignment_id             pay_assignment_actions.assignment_id%TYPE;
      l_arch_assmt_action_id_bal       pay_assignment_actions.assignment_action_id%TYPE;
      l_arch_tax_deduction_basis       pay_action_information.action_information17%TYPE;
      l_arch_surname                   pay_action_information.action_information29%TYPE;
      l_arch_first_name                pay_action_information.action_information28%TYPE;
      l_arch_dob                       pay_action_information.action_information25%TYPE;
      l_arch_address_line1             pay_action_information.action_information5%TYPE;
      l_arch_address_line2             pay_action_information.action_information6%TYPE;
      l_arch_address_line3             pay_action_information.action_information7%TYPE; -- BUG 4066315
      l_arch_address_line4             pay_action_information.action_information9%TYPE; -- BUG 4066315
      l_length_address_line2           NUMBER; -- BUG 4066315
      l_available_space                NUMBER; -- BUG 4066315
      l_arch_hire_date                 pay_action_information.action_information24%TYPE;
      l_arch_payroll_action_id         pay_assignment_actions.payroll_action_id%TYPE;
      l_arch_annual_tax_credit         pay_action_information.action_information26%TYPE;
      l_arch_term_date                 pay_action_information.action_information25%TYPE;
      l_arch_mothers_name              per_people_f.per_information1%TYPE;
      l_arch_totwks_insurble_emplmnt   pay_run_result_values.result_value%TYPE;
      l_arch_initial_class             pay_run_result_values.result_value%TYPE;
      l_arch_second_class              pay_run_result_values.result_value%TYPE;
      l_arch_third_class               pay_run_result_values.result_value%TYPE;
      l_arch_fourth_class              pay_run_result_values.result_value%TYPE;
      l_arch_fifth_class               pay_run_result_values.result_value%TYPE;
	l_arch_weeks_at_initial_class	   pay_run_result_values.result_value%TYPE;
      l_arch_weeks_at_second_class     pay_run_result_values.result_value%TYPE;
      l_arch_weeks_at_third_class      pay_run_result_values.result_value%TYPE;
      l_arch_weeks_at_fourth_class     pay_run_result_values.result_value%TYPE;
	l_arch_weeks_at_fifth_class      pay_run_result_values.result_value%TYPE;
      l_arch_net_tax                   pay_action_information.action_information4%TYPE;
      l_arch_tax_or_refund             pay_action_information.action_information4%TYPE;
      l_arch_employees_prsi_cont       pay_action_information.action_information4%TYPE;
      l_arch_total_prsi_cont           pay_action_information.action_information4%TYPE;
      l_arch_employer_prsi_cont        pay_action_information.action_information4%TYPE;
      l_arch_pay                       pay_action_information.action_information4%TYPE;
      l_arch_non_tax_pay               pay_action_information.action_information4%TYPE; --Bug 4063502
      l_arch_prev_pay                  pay_action_information.action_information4%TYPE;
      l_arch_prev_tax                  pay_action_information.action_information4%TYPE;
      l_arch_ovn                       pay_action_information.object_version_number%TYPE;
      l_arch_previous_emp_pay          pay_action_information.action_information28%TYPE;
      l_arch_previous_emp_tax          pay_action_information.action_information29%TYPE;
      l_arch_pr_indicator              pay_action_information.action_information30%TYPE;
      l_arch_action_info_id            NUMBER;
      l_arch_total_notional_pay        pay_action_information.action_information4%TYPE;
	l_period_type		         pay_all_payrolls_f.period_type%TYPE; --Bug 4154171
-- Temporary variable to hold values when Class K or M exists
      l_temp_prsi_cont                 pay_action_information.action_information4%TYPE := NULL;
      l_oth_arch_ovn		         pay_action_information.object_version_number%TYPE;
      l_pds_id			         per_periods_of_service.period_of_service_id%TYPE;
      l_asg_id			         per_assignments_f.assignment_id%TYPE;
      l_aact_id			         pay_assignment_actions.assignment_action_id%TYPE;
      l_max_act_for_bal 	         pay_assignment_actions.assignment_action_id%TYPE;
      l_set_flag				   hr_assignment_set_amendments.include_or_exclude%TYPE ;
	l_arch_primary_flag		   per_assignments_f.primary_flag%TYPE;
	v_primary_flag			   per_assignments_f.primary_flag%TYPE;
	-- pension variables
	l_arch_pen_emp_rbs		   pay_action_information.action_information30%TYPE;
	l_arch_pen_empr_rbs		   pay_action_information.action_information30%TYPE;
	l_arch_pen_emp_prsa		   pay_action_information.action_information30%TYPE;
	l_arch_pen_empr_prsa		   pay_action_information.action_information30%TYPE;
	l_arch_pen_emp_rac		   pay_action_information.action_information30%TYPE;
	-- P60 enhancement changes. bug

	-- bik medical insurance 5867343
	l_medical_insurance		   pay_action_information.action_information30%TYPE;
	l_arch_gross_pay                   pay_action_information.action_information4%TYPE; /* 8520684 */
        l_arch_income_levy                 pay_action_information.action_information4%TYPE;
        l_arch_income_levy_first           pay_action_information.action_information4%TYPE;
	l_arch_income_levy_second          pay_action_information.action_information4%TYPE;
        l_arch_income_levy_third           pay_action_information.action_information4%TYPE;
	l_arch_parking_levy                pay_action_information.action_information4%TYPE;
	l_temp_gross_pay                   pay_action_information.action_information4%TYPE := NULL;
	l_temp_income_levy                 pay_action_information.action_information4%TYPE := NULL;

	/* 8978805 */

	l_arch_total_this_gross_pay   pay_action_information.action_information4%TYPE;
        l_arch_prev_gross_pay        pay_action_information.action_information4%TYPE;
        l_arch_prev_gross_pay_adjust pay_action_information.action_information4%TYPE;
        l_arch_prev_gross_pay_BIK    pay_action_information.action_information4%TYPE;
        l_arch_this_income_levy       pay_action_information.action_information4%TYPE;
--6633719
l_dimension_name VARCHAR2(100):= '_PER_PAYE_REF_YTD';

CURSOR get_actid_from_interlocks IS
	SELECT * from pay_action_interlocks
	where locking_action_id = p_assactid
	order by locking_action_id,locked_action_id desc;

-- Cursor to get action type, so that we can identify whether a assignment action
-- is from P30, prepayments or run-results

CURSOR get_action_type(p_action_id number)
IS
	SELECT paa.assignment_action_id,ppa.action_type
	FROM pay_action_interlocks pal,
	    pay_assignment_actions paa,
	    pay_payroll_actions ppa
	WHERE pal.locked_action_id = p_action_id
	AND pal.locking_action_id = paa.assignment_action_id
	AND ppa.payroll_action_id = paa.payroll_action_id
	AND paa.action_status = 'C'
	AND (ppa.action_type IN ('P', 'U')
	OR (ppa.action_type='X' and ppa.report_type = 'IEPS'
	   and paa.source_action_id IS NULL
	   and exists (select 1 from pay_action_information pai
			   where pai.action_information_category = 'IE EMPLOYEE DETAILS'
			   AND pai.action_context_type='AAP'
			   AND pai.action_context_id=paa.assignment_action_id)))
	ORDER BY paa.assignment_action_id DESC;

/*CURSOR get_action_type(p_action_id number) is
	select ppa.action_type, ppa.report_type
	from	 pay_payroll_actions ppa,
		 pay_assignment_actions paa
	where  ppa.payroll_action_id = paa.payroll_action_id
	and    paa.source_action_id IS NULL
	and	 paa.assignment_action_id = p_action_id;*/

-- Cursor to check if P30 exists
-- p_asg_act_id is run-result action id

/*CURSOR csr_latest_p30_action (p_asg_act_id NUMBER)
IS
   SELECT   paa.assignment_action_id
	 FROM pay_action_interlocks pal,
		pay_assignment_actions paa,
		pay_payroll_actions ppa,
		pay_action_information pai
	WHERE pal.locked_action_id = p_asg_act_id
	  AND pal.locking_action_id = paa.assignment_action_id
	  AND paa.source_action_id IS NULL
	  AND ppa.payroll_action_id = paa.payroll_action_id
	  AND paa.action_status = 'C'
	  AND ppa.report_type = 'IEPS'
	  AND pai.action_information_category = 'IE EMPLOYEE DETAILS'
	  AND pai.action_context_type='AAP'
	  AND pai.action_context_id=paa.assignment_action_id
   ORDER BY 1 DESC;

-- Cursor to check if Prepayments exists
-- p_asg_act_id is run-result action id

CURSOR csr_latest_prepay_action (p_asg_act_id NUMBER)
IS
   SELECT paa.assignment_action_id
     FROM pay_action_interlocks pal,
	    pay_assignment_actions paa,
	    pay_payroll_actions ppa
    WHERE pal.locked_action_id = p_asg_act_id
	AND pal.locking_action_id = paa.assignment_action_id
	AND ppa.payroll_action_id = paa.payroll_action_id
	AND paa.action_status = 'C'
	AND ppa.action_type IN ('P', 'U');*/


-- Cursor to get the balance values from P30
-- p_locked_action_id is P30s assignment action id
CURSOR csr_p30_bal_value (p_locked_action_id   NUMBER,
			              p_balance_name       VARCHAR2,  --6633719
                          p_dimension_name VARCHAR2) IS  --6633719
	SELECT SUBSTR (pai1.action_information4, 1, 30) bval
	FROM pay_action_information pai1,
	    pay_balance_types pbt,
	    pay_balance_dimensions pbd,
	    pay_defined_balances pdb
	WHERE pdb.balance_type_id = pbt.balance_type_id
	AND pbt.legislation_code = 'IE'
	AND UPPER (pbt.balance_name) = p_balance_name
	AND pbd.legislation_code = 'IE'
	AND pbd.dimension_name = p_dimension_name  -- 6633719 '_PER_PAYE_REF_YTD' -- changes made
	AND pdb.balance_dimension_id = pbd.balance_dimension_id
	AND pai1.action_context_type = 'AAP'
	AND pai1.action_information_category = 'EMEA BALANCES'
	AND pai1.action_information1 = pdb.defined_balance_id
	AND pai1.action_context_id = p_locked_action_id;

--6633719
CURSOR csr_rehire_ppsn_arch(p_locked_action_id   NUMBER)
    IS
    SELECT NVL(action_information20,'N') PPSN_BAL_ARCHIVED
    FROM pay_action_information pai
    WHERE
	pai.action_context_type = 'AAP'
	AND pai.action_information_category = 'IE EMPLOYEE DETAILS'
	AND pai.action_context_id = p_locked_action_id;

-- N = Not Archived by Leg Generator PPSN Balances , Y = Archived PPSN Balances by Leg Generator.
l_ppsn_bal_archived varchar2(1) := 'N';
--6633719

-- Cursor to get employee and address details from P30 legislative archive
-- p_locked_action_id is P30s assignment action id
-- p_rr_action is Payroll Run assignment action id 4672715
CURSOR csr_p30_found (p_locked_action NUMBER,
                      p_arch_net_tax VARCHAR2,
                      p_rr_action NUMBER) IS
	SELECT NVL (pact_edi.action_information4, ' '), --PPSN number
	    NVL (pact_edi.action_information14, ' '), -- WORKS_NUMBER
	    paf.person_id,
	    paf.primary_flag,    -- changes made
	    paf.assignment_id,
	    NVL (TRIM (RPAD (pact_iedi.action_information29, 20)), ' '), -- SURNAME
	    NVL (TRIM (RPAD (pact_iedi.action_information28, 20)), ' '), -- FIRST_NAME
	    NVL (TRIM (pact_iedi.action_information25), '31-12-4712'), -- DOB
	    NVL (TRIM (RPAD (pact_ad.action_information5, 30)), ' '), -- ADDRESS_LINE1
	    NVL (TRIM (pact_ad.action_information6), ' '),            -- ADDRESS_LINE2
	    NVL (TRIM ( pact_ad.action_information7), ' '),          -- ADDRESS_LINE3   BUG 4066315
	    NVL (
		 TRIM (
			    hr_general.decode_lookup (
				 'IE_COUNTY',
				 TRIM (pact_ad.action_information9)
			    )
		    ||' '||
			    hr_general.decode_lookup (
				 'IE_POSTAL_CODE',
				 TRIM (pact_ad.action_information12)
			    )
		 ),
		 ' '
	    ), --ADDRESS LINE 4


	    NVL (TO_CHAR (pps.date_start, 'dd-mm-yyyy'), '31-12-4712'), -- HIRE_DATE
	/*Bug 4154171*/
	ptp.period_type, --PERIOD_TYPE
	    DECODE (
		 TO_CHAR (
		    NVL (
			 pps.actual_termination_date,
			 TO_DATE ('31-12-4712', 'DD-MM-YYYY')
		    ),
		    'YYYY'
		 ),
		 TO_CHAR (pay_ie_p35.get_end_date, 'RRRR') --Bug fix 3745861
	   , TO_CHAR (pps.actual_termination_date, 'dd-mm-yyyy'),
		 '31-12-4712'
	    ), -- TERM_DATE
	    NVL (TRIM (RPAD (ppf.per_information1, 30)), ' '), -- MOTHERS_NAME
	    DECODE (SIGN (TO_NUMBER (p_arch_net_tax)), -1, 'H9', 1, 'J7'), --Q1_PR_Indicator
	    NVL (
		 ROUND (
		    TO_NUMBER (
			 pay_balance_pkg.get_value (
			    pay_ie_p35.get_defined_balance_id (
				 '_ASG_YTD',
				 'IE P45 Pay'
			    ),
			    p_rr_action
			 )
		    ),
		    2
		 ),
		 0
	    ), -- Q1_Previous_Emp_Pay
	    NVL (
		 ROUND (
		    TO_NUMBER (
			 pay_balance_pkg.get_value (
			    pay_ie_p35.get_defined_balance_id (
				 '_ASG_YTD',
				 'IE P45 Tax Deducted'
			    ),
			    p_rr_action
			 )
		    ),
		    2
		 ),
		 0
	    ) -- Q1_Previous_Emp_Tax
	FROM pay_action_information pact_edi,
	    pay_action_information pact_iedi,
	    pay_action_information pact_ad,
	    per_assignments_f paf,
	    per_periods_of_service pps,
	   -- pay_ie_paye_details_f payef,
	    per_time_periods ptp,
	    per_people_f ppf
	WHERE pact_iedi.action_information_category = 'IE EMPLOYEE DETAILS'
	AND pact_iedi.action_context_type = 'AAP'
	AND pact_iedi.action_context_id = p_locked_action
	AND pact_edi.action_information_category = 'EMPLOYEE DETAILS'
	AND pact_edi.action_context_type = 'AAP'
	AND pact_edi.action_context_id = p_locked_action
	AND pact_ad.action_information_category = 'ADDRESS DETAILS'
	AND pact_ad.action_context_type = 'AAP'
	AND pact_ad.action_information14 = 'Employee Address'
	AND pact_ad.action_context_id = p_locked_action
	AND ptp.time_period_id =
					TO_NUMBER (pact_edi.action_information16)
	AND paf.assignment_id = pact_ad.assignment_id
	--AND paf.primary_flag = 'Y'
	AND paf.effective_end_date =
		    (SELECT MAX (asg.effective_end_date)
			 FROM per_assignments_f asg
			WHERE asg.assignment_id = paf.assignment_id
			  AND asg.effective_start_date <=
					  l_end_date --pay_ie_p35.get_start_date()
			  AND asg.effective_end_date >=
					 l_start_date -- pay_ie_p35.get_end_date()
							 )
	AND paf.period_of_service_id = pps.period_of_service_id
	AND paf.person_id = pps.person_id
	AND ppf.person_id = paf.person_id
	AND ppf.effective_end_date =
		    (SELECT MAX (per.effective_end_date)
			 FROM per_people_f per
			WHERE per.person_id = ppf.person_id
			  AND per.effective_start_date <=
					  l_end_date --pay_ie_p35.get_start_date()
			  AND per.effective_end_date >=
					  l_start_date --pay_ie_p35.get_end_date()
							  );

-- Prepayment cursor
-- p_locked_action is pre-payments locked action.
-- p_rr_action is Payroll Run assignment action id 4672715
CURSOR csr_prepay_found (p_locked_action NUMBER,
                         p_rr_action NUMBER,
                         p_dimension_name VARCHAR2,   --6633719  3new pmtr added
                         p_context_id number,
                         p_context_value pay_action_contexts.CONTEXT_VALUE%type ) IS
	SELECT NVL (SUBSTR (ppf.national_identifier, 1, 9), ' '), -- PPSN
	    -- for bug 5301598, increased the size to 12
	    NVL (SUBSTR (paf.assignment_number, 1, 12), ' '), --WORKS NUMBER
	    paf.person_id, -- FOR CALCULATION
	    paf.primary_flag,  -- changes made
	    paf.assignment_id, -- FOR CALCULATION
	    paa.assignment_action_id, -- FOR CALCULATION
	    DECODE (
		 SIGN (
		    NVL (
			 pay_balance_pkg.get_value (
			    pay_ie_p35.get_defined_balance_id (
				 p_dimension_name,  --'_PER_PAYE_REF_YTD', -- changes made --6633719
				 'IE Net Tax'
			    ),
			         p_rr_action, -- paa.assignment_action_id,
				   l_segment4, -- paye reference value
				   null,
				   p_context_id,  --null,
				   p_context_value, --null,
				   null,
				   null,
				   null,
				   'TRUE'

			 ),
			 0
		    )
		 ),
		 -1, '1',
		 1, '0',
		 '0'
	    ), --TAX OR REFUND
	  /*Bug 4154171*/
	/*DECODE (
		 payef.tax_basis,
		 'IE_EMERGENCY', '2',
		 NULL, '2',
		 DECODE (payef.info_source, 'IE_P45', '1', '0')
	    ), --TAX_DEDUCTION_BASIS*/

	    TRIM (RPAD (ppf.last_name, 20)), --SURNAME
	    /* Bug 4560952*/
	    NVL (TRIM (RPAD (ppf.first_name||' '||ppf.middle_names, 20)), ' '), --FIRST_NAME
	    TO_CHAR (ppf.date_of_birth, 'dd-mm-yyyy'), --DOB
	    NVL (TRIM (RPAD (pad.address_line1, 30)), ' '), --ADDRESS_LINE1
	    NVL (TRIM (pad.address_line2), ' '), --ADDRESS_LINE2
	    NVL (TRIM (pad.address_line3), ' '), --ADDRESS_LINE3
	    NVL (TRIM (hr_general.decode_lookup ('IE_COUNTY',
				 TRIM (pad.region_1)
			    )
		    ||' '||  (
			    hr_general.decode_lookup (
				 'IE_POSTAL_CODE',
				 TRIM (pad.postal_code)
			    )
			 )
		 ),
		 ' '
	    ), --ADDRESS_LINE4

	    TO_CHAR (pps.date_start, 'dd-mm-yyyy'), --HIRE_DATE
	    DECODE (
		 TO_CHAR (
		    NVL (
			 pps.actual_termination_date,
			 TO_DATE ('31-12-4712', 'DD-MM-YYYY')
		    ),
		    'YYYY'
		 ),
		 TO_CHAR (l_end_date, 'YYYY'), TO_CHAR (
							    pps.actual_termination_date,
							    'dd-mm-yyyy'
							 ),
		 '31-12-4712'
	    ), --TERM_DATE
	    papf.period_type, --PERIOD_TYPE
	/*Bug 4154171*/
	/*TO_CHAR (
		 NVL (
		    DECODE (
			 papf.period_type,
			 'Lunar Month', ROUND (
						 (payef.weekly_tax_credit * 52),
						 2
					    ),
			 DECODE (
			    INSTR (papf.period_type, 'Week'),
			    0, ROUND (
				    (payef.monthly_tax_credit * 12),
				    2
				 ),
			    ROUND (
				 (payef.weekly_tax_credit * 52),
				 2
			    )
			 )
		    ),
		    0
		 )
	    ), --ANNUAL_TAX_CREDIT*/

	    NVL (TRIM (RPAD (ppf.per_information1, 30)), ' '), --MOTHERS_NAME
	    DECODE (
		 SIGN (
		  pay_balance_pkg.get_value (
			    pay_ie_p35.get_defined_balance_id (
				  p_dimension_name,  --'_PER_PAYE_REF_YTD', -- changes made--6633719
				 'IE Net Tax'
			    ),
			    p_rr_action, --paa.assignment_action_id,
			    l_segment4, -- paye reference value
				  null,
				   p_context_id,  --null,
				   p_context_value,  --null,
				   null,
				   null,
				   null,
				  'TRUE'
			 )
		 ),
		 -1, 'H9',
		 1, 'J7'
	    ), --Q1_PR_Indicator
	    NVL (
		 ROUND (
		    TO_NUMBER (
			 pay_balance_pkg.get_value (
			    pay_ie_p35.get_defined_balance_id (
				 '_ASG_YTD',
				 'IE P45 Pay'
			    ),
			    p_rr_action
			 )
		    ),
		    2
		 ),
		 0
	    ), -- Q1_Previous_Emp_Pay
	    NVL (
		 ROUND (
		    TO_NUMBER (
			 pay_balance_pkg.get_value (
			    pay_ie_p35.get_defined_balance_id (
				 '_ASG_YTD',
				 'IE P45 Tax Deducted'
			    ),
			    p_rr_action
			 )
		    ),
		    2
		 ),
		 0
	    ) -- Q1_Previous_Emp_Tax
	FROM pay_action_interlocks pai,
	    pay_assignment_actions paa,
	    per_people_f ppf,
	    per_periods_of_service pps,
	    per_assignments_f paf,
	    per_addresses pad,
	   -- pay_ie_paye_details_f payef, --Bug 4154171
	    pay_all_payrolls_f papf,
	    pay_payroll_actions ppa
	WHERE pai.locking_action_id = p_locked_action
	AND paa.assignment_action_id = pai.locked_action_id
	-- Added for bug 5874653
	AND ppa.payroll_action_id = paa.payroll_action_id
	AND ppa.effective_date BETWEEN nvl(pad.date_from,ppa.effective_date) AND nvl(pad.date_to,ppa.effective_date)
	-- end bug 5874653
	AND paa.source_action_id IS NULL
	AND paf.assignment_id = paa.assignment_id
	--AND paf.primary_flag = 'Y'
	AND ppf.person_id = paf.person_id
	AND pad.person_id(+) = paf.person_id
	AND NVL (pad.primary_flag, 'Y') = 'Y'
	AND paf.effective_end_date =
		    (SELECT MAX (asg.effective_end_date)
			 FROM per_assignments_f asg
			WHERE asg.assignment_id = paf.assignment_id
			  AND asg.effective_start_date <= l_end_date
			  AND asg.effective_end_date >= l_start_date)
	AND ppf.effective_end_date =
		    (SELECT MAX (per.effective_end_date)
			 FROM per_people_f per
			WHERE per.person_id = ppf.person_id
			  AND per.effective_start_date <= l_end_date
			  AND per.effective_end_date >= l_start_date)
	AND paf.period_of_service_id = pps.period_of_service_id
	AND paf.person_id = pps.person_id
	AND papf.payroll_id = paf.payroll_id
	AND papf.effective_end_date =
		    (SELECT MAX (papf1.effective_end_date)
			 FROM pay_all_payrolls_f papf1
			WHERE papf1.payroll_id = papf.payroll_id
			  AND papf1.effective_start_date <= l_end_date
			  AND papf1.effective_end_date >= l_start_date);

/* cursor for payroll run results data */
      CURSOR csr_run_results_found (p_locked_action NUMBER,
                                    p_dimension_name VARCHAR2,  --6633719 3new pmtr added
                                    p_context_id number,
                                    p_context_value pay_action_contexts.CONTEXT_VALUE%type )
      IS
         SELECT NVL (SUBSTR (ppf.national_identifier, 1, 9), ' '), --PPSN
	          -- for bug 5301598, increased the size to 12
                NVL (SUBSTR (paf.assignment_number, 1, 12), ' '), -- WORKS NUMBER
                paf.person_id, -- FOR CALCULATION
                paf.primary_flag,    -- changes made
		    paa.assignment_id, -- FOR CALCULATION
		    paa.assignment_action_id, -- FOR CALCULATION
		    DECODE (
                   SIGN (
                      NVL (
                         pay_balance_pkg.get_value (
                            pay_ie_p35.get_defined_balance_id (
                               p_dimension_name,  --'_PER_PAYE_REF_YTD', -- changes made--6633719
                               'IE Net Tax'
                            ),
                            paa.assignment_action_id,
                                l_segment4, -- paye reference value
					  null,
					   p_context_id,  --null,
					   p_context_value, --null,
					   null,
					   null,
					   null,
					   'TRUE'
                         ),
                         0
                      )
                   ),
                   -1, '1',
                   1, '0',
                   '0'
                ),  --TAX_OR_REFUND
		/*Bug 4154171*/
             /*   DECODE (
                   payef.tax_basis,
                   'IE_EMERGENCY', '2',
                   NULL, '2',
                   DECODE (payef.info_source, 'IE_P45', '1', '0')
                ), --TAX_DEDUCTION_BASIS*/

                TRIM (RPAD (ppf.last_name, 20)), --SURNAME
		    /*Bug 4560952*/
                NVL (TRIM (RPAD (ppf.first_name||' '||ppf.middle_names, 20)), ' '), --FIRST_NAME
                TO_CHAR (ppf.date_of_birth, 'dd-mm-yyyy'), -- DOB
                NVL (TRIM (RPAD (pad.address_line1, 30)), ' '), -- ADDRESS_LINE1
		    NVL (TRIM  (pad.address_line2), ' '), -- ADDRESS_LINE2
                NVL (TRIM (pad.address_line3), ' '), -- ADDRESS_LINE3
                NVL (
                   TRIM (
                            hr_general.decode_lookup (
                               'IE_COUNTY',
                               TRIM (pad.region_1)
                            )
                      ||' '||
                            hr_general.decode_lookup (
                               'IE_POSTAL_CODE',
                               TRIM (pad.postal_code)
                            )
                   ),
                   ' '
                ), -- ADDRESS_LINE4

                TO_CHAR (pps.date_start, 'dd-mm-yyyy'), -- HIRE_DATE
                DECODE (
                   TO_CHAR (
                      NVL (
                         pps.actual_termination_date,
                         TO_DATE ('31-12-4712', 'DD-MM-YYYY')
                      ),
                      'YYYY'
                   ),
                   TO_CHAR (l_end_date, 'YYYY'), TO_CHAR (
                                                    pps.actual_termination_date,
                                                    'dd-mm-yyyy'
                                                 ),
                   '31-12-4712'
                ), -- TERM_DATE
               papf.period_type, --PERIOD_TYPE
	       /*Bug 4154171*/
	       /* TO_CHAR (
                   NVL (
                      DECODE (
                         papf.period_type,
                         'Lunar Month', ROUND (
                                           (payef.weekly_tax_credit * 52),
                                           2
                                        ),
                         DECODE (
                            INSTR (papf.period_type, 'Week'),
                            0, ROUND (
                                  (payef.monthly_tax_credit * 12),
                                  2
                               ),
                            ROUND (
                               (payef.weekly_tax_credit * 52),
                               2
                            )
                         )
                      ),
                      0
                   )
                ), -- ANNUAL_TAX_CREDIT*/

                NVL (TRIM (RPAD (ppf.per_information1, 30)), ' '), --  MOTHERS_NAME
                DECODE (
                   SIGN (
                      pay_balance_pkg.get_value (
                            pay_ie_p35.get_defined_balance_id (
                               p_dimension_name,  ---'_PER_PAYE_REF_YTD', -- changes made--6633719
                               'IE Net Tax'
                            ),
                            paa.assignment_action_id,
                            l_segment4, -- paye reference value
				    null,
				    p_context_id,  --null,
				    p_context_value,  --null,
				    null,
				    null,
				    null,
				    'TRUE'
                         )
                   ),
                   -1, 'H9',
                   1, 'J7'
                ), --Q1_PR_Indicator
                NVL (
                   ROUND (
                      TO_NUMBER (
                         pay_balance_pkg.get_value (
                            pay_ie_p35.get_defined_balance_id (
                               '_ASG_YTD',
                               'IE P45 Pay'
                            ),
                            p_locked_action
                         )
                      ),
                      2
                   ),
                   0
                ), -- Q1_Previous_Emp_Pay
                NVL (
                   ROUND (
                      TO_NUMBER (
                         pay_balance_pkg.get_value (
                            pay_ie_p35.get_defined_balance_id (
                               '_ASG_YTD',
                               'IE P45 Tax Deducted'
                            ),
                            p_locked_action
                         )
                      ),
                      2
                   ),
                   0
                ) -- Q1_Previous_Emp_Tax
           FROM pay_assignment_actions paa,
                per_people_f ppf,
                per_periods_of_service pps,
                per_assignments_f paf,
                per_addresses pad,
               -- pay_ie_paye_details_f payef,
                pay_all_payrolls_f papf,
		    pay_payroll_actions ppa
          WHERE paa.assignment_action_id = p_locked_action
	      -- Added for bug 5874653
		AND ppa.payroll_action_id = paa.payroll_action_id
		AND ppa.effective_date BETWEEN nvl(pad.date_from,ppa.effective_date) AND nvl(pad.date_to,ppa.effective_date)
		-- end bug 5874653
            AND paf.assignment_id = paa.assignment_id
            --AND paf.primary_flag = 'Y'
            AND ppf.person_id = paf.person_id
            AND pad.person_id(+) = paf.person_id
            AND NVL (pad.primary_flag, 'Y') = 'Y'
            AND paf.effective_end_date =
                      (SELECT MAX (asg.effective_end_date)
                         FROM per_assignments_f asg
                        WHERE asg.assignment_id = paf.assignment_id
                          AND asg.effective_start_date <= l_end_date
                          AND asg.effective_end_date >= l_start_date)
            AND ppf.effective_end_date =
                      (SELECT MAX (per.effective_end_date)
                         FROM per_people_f per
                        WHERE per.person_id = ppf.person_id
                          AND per.effective_start_date <= l_end_date
                          AND per.effective_end_date >= l_start_date)
            AND paf.period_of_service_id = pps.period_of_service_id
            AND paf.person_id = pps.person_id
           /* AND payef.assignment_id(+) = paa.assignment_id
            AND (   payef.effective_end_date =
                          (SELECT MAX (paye.effective_end_date)
                             FROM pay_ie_paye_details_f paye
                            WHERE paye.assignment_id = paf.assignment_id
                              AND paye.effective_start_date <= l_end_date
                              AND paye.effective_end_date >= l_start_date)
                 OR payef.effective_end_date IS NULL
                )*/
            AND papf.payroll_id = paf.payroll_id
            AND papf.effective_end_date =
                      (SELECT MAX (papf1.effective_end_date)
                         FROM pay_all_payrolls_f papf1
                        WHERE papf1.payroll_id = papf.payroll_id
                          AND papf1.effective_start_date <= l_end_date
                          AND papf1.effective_end_date >= l_start_date);


 /* Bug 4049920*/
CURSOR csr_annual_tax_credit(p_assignment_id NUMBER, p_term_date DATE) IS
SELECT  DECODE (
		 paye.tax_basis,
		 'IE_WEEK1_MONTH1' , '1',		--7710479
		 'IE_EXEMPT_WEEK_MONTH' , '1',	--7710479
		 'IE_EMERGENCY', '2',
		 NULL, '2',
		 DECODE (paye.info_source, 'IE_P45', '1', '0')
	    ), --TAX_DEDUCTION_BASIS
     NVL ( DECODE (
			 ptp.period_type,
			 'Lunar Month', ROUND (
						 (paye.weekly_tax_credit * 52),
						 2
					    ),
			 DECODE (
			    INSTR (ptp.period_type, 'Week'),
			    0, ROUND (
				    (paye.monthly_tax_credit * 12),
				    2
				 ),
			    ROUND (
				 (paye.weekly_tax_credit * 52),
				 2
			    )
			 )
		    ),
		    0)    --Bug 4111753
/*( NVL(paye.weekly_tax_credit,0) +
	  NVL(paye.Monthly_tax_credit,0)) * ptp.period_num */
FROM   per_assignments_f paf,
	 per_time_periods ptp,
	 pay_ie_paye_details_f paye
WHERE  paf.assignment_id = p_assignment_id
AND    paye.assignment_id=paf.assignment_id
AND    p_term_date between paf.effective_start_date
			 and paf.effective_end_date
-- Bug 6774415 changed effective date to certificate date
AND    p_term_date between paye.certificate_start_date
			 and NVL(paye.certificate_end_date,to_date('31/12/4712','DD/MM/YYYY'))
AND    paf.payroll_id = ptp.payroll_id
AND    p_term_date between ptp.start_date and ptp.end_date
-- Bug 6774415 order by eff date to handle overlapping certificates
ORDER BY paye.effective_start_date DESC;

 /*Bug 4154171*/
 /*Cursor to fetch paye details for non terminated employees*/
 CURSOR csr_paye_details(p_assignment_id  NUMBER, p_period_type VARCHAR2)
 IS
 SELECT DECODE (
                   payef.tax_basis,
			'IE_WEEK1_MONTH1' , '1',		--7710479
			'IE_EXEMPT_WEEK_MONTH' , '1',		--7710479
                   'IE_EMERGENCY', '2',
                   NULL, '2',
                   DECODE (payef.info_source, 'IE_P45', '1', '0')
                ), --TAX_DEDUCTION_BASIS
	 TO_CHAR (
                   NVL (
                      DECODE (
                         p_period_type,
                         'Lunar Month', ROUND (
                                           (payef.weekly_tax_credit * 52),
                                           2
                                        ),
                         DECODE (
                            INSTR (p_period_type, 'Week'),
                            0, ROUND (
                                  (payef.monthly_tax_credit * 12),
                                  2
                               ),
                            ROUND (
                               (payef.weekly_tax_credit * 52),
                               2
                            )
                         )
                      ),
                      0
                   )
                ) -- ANNUAL_TAX_CREDIT
   FROM	  pay_ie_paye_details_f payef
   WHERE  payef.assignment_id=p_assignment_id
-- Bug 6774415 changed effective date to certificate date
   AND payef.certificate_start_date <= l_end_date
   AND NVL(payef.certificate_end_date,to_date('31/12/4712','DD/MM/YYYY')) >= l_start_date
   ORDER BY payef.effective_end_date desc;

CURSOR get_assignment_id is
	select payroll_action_id,assignment_id,chunk_number
	from  pay_assignment_actions
	where assignment_action_id = p_assactid;

/*** Cursors for Previous employment balances */
CURSOR c_get_periods_of_service(v_person_id NUMBER,
					  v_assignment_id NUMBER) IS
	/*SELECT period_of_service_id
	FROM   per_periods_of_service pps
	WHERE  person_id = v_person_id
	AND    actual_termination_date is not NULL
	AND    actual_termination_date between l_start_date
					   and l_end_date
	ORDER BY  actual_termination_date desc;   */
SELECT max(pps.period_of_service_id)
	FROM   per_periods_of_service pps
	      ,per_assignments_f asg
	      ,pay_all_payrolls_f pay
	      ,hr_soft_coding_keyflex flex
	WHERE  pps.person_id = v_person_id
	AND    pps.person_id = asg.person_id
	AND    asg.period_of_service_id <> pps.period_of_service_id
	AND    asg.assignment_id = v_assignment_id
	AND    asg.payroll_id = pay.payroll_id
	AND    pay.soft_coding_keyflex_id = flex.soft_coding_keyflex_id
	AND    flex.segment4 = l_segment4
	AND    actual_termination_date IS NOT NULL
	AND    actual_termination_date BETWEEN l_start_date
					   AND l_end_date;

/*CURSOR c_get_terminated_asg(p_pds_id NUMBER) IS
	SELECT assignment_id
	FROM   per_assignments_f
	WHERE  period_of_service_id = p_pds_id
	AND    primary_flag = 'Y';*/

/*
CURSOR c_get_max_aact(p_pds_id NUMBER) IS
	SELECT max(paa.assignment_action_id)
	FROM   pay_assignment_Actions paa,
	       pay_payroll_actions ppa
	--       ,per_time_periods ptp    -- removed to improve performance 4771780
	WHERE  paa.assignment_id in (SELECT assignment_id
						FROM   per_assignments_f
						WHERE  period_of_service_id = p_pds_id)
	AND    paa.payroll_action_id = ppa.payroll_action_id
	AND    ppa.action_type IN ('R','Q','I','B','V')
	AND    paa.action_status = 'C' */
	/* Impact of time period */
	--	AND    ptp.time_period_id = ppa.time_period_id
      --  Removed ptp to improve the performance 4771780
      --  AND    ppa.payroll_id  = ptp.payroll_id
      --  AND    ppa.date_earned between ptp.start_date and ptp.end_date
      --  AND    ptp.end_Date BETWEEN l_start_date
      --			 AND l_end_date


      CURSOR c_get_max_aact(p_pds_id NUMBER,
                       c_ppsn varchar2,
		       c_person_id NUMBER) IS
	SELECT fnd_number.canonical_to_number(substr(max(lpad(paa.action_sequence,15,'0')||
               paa.assignment_action_id),16))
	FROM   pay_assignment_Actions paa,
	       pay_payroll_actions ppa

	WHERE ( (c_ppsn is null and paa.assignment_id in (SELECT paf.assignment_id
						FROM   per_assignments_f paf
						WHERE  paf.period_of_service_id = p_pds_id
						  AND  paf.person_id=c_person_id))
               OR
               (c_ppsn is not null and paa.assignment_id in (SELECT paf.assignment_id
						FROM   per_assignments_f paf, per_assignment_extra_info paei
						WHERE  paf.period_of_service_id = p_pds_id
						  AND  paf.person_id=c_person_id
						  AND  paf.assignment_id=paei.assignment_id
						  AND  paei.information_type = 'IE_ASG_OVERRIDE'
						  AND  paei.aei_information1 = c_ppsn
						  ))

             )
	AND    paa.payroll_action_id = ppa.payroll_action_id
	AND    ppa.action_type IN ('R','Q','I','B','V')
	AND    paa.action_status = 'C'
        AND paa.source_action_id is null
	  AND    ppa.effective_date between l_start_date and l_end_date;

	  /**  End Cursors for Previous employment balances **/

/* Cursor to fetch primary flag for terminated assignments*/
CURSOR csr_get_primary_flag(p_action_id number) is
      -- for bug 5301598, increased the size to 12
	select NVL (SUBSTR (paf.assignment_number, 1, 12), ' '), -- WORKS NUMBER
		 paf.primary_flag,
		 paf.assignment_id
	from per_assignments_f paf,
	     pay_assignment_actions paa
	where paf.assignment_id = paa.assignment_id
	and   paa.assignment_action_id = p_action_id
	and paf.effective_start_date <= l_end_date
	and paf.effective_end_date   >= l_start_date;


/* Cursor to fetch primary flag for active assignments*/
CURSOR csr_get_primary_flag_active(p_action_id number) is
      -- for bug 5301598, increased the size to 12
	select NVL (SUBSTR (paf.assignment_number, 1, 12), ' '), -- WORKS NUMBER
		 paf.primary_flag,
		 paf.assignment_id,
		 max(effective_end_date) end_date
	from per_assignments_f paf,
	     pay_assignment_actions paa
	where paf.assignment_id = paa.assignment_id
	and   paa.assignment_action_id = p_action_id
	and paf.effective_start_date <= l_end_date
	and paf.effective_end_date   >= l_start_date
	group by NVL (SUBSTR (paf.assignment_number, 1, 12), ' '), paf.primary_flag, paf.assignment_id
	having max(effective_end_date) >= l_end_date;

--6633719
/* Cursor to fetch primary flag for terminated assignments for PPSN OVERRIDE case*/
CURSOR csr_get_primary_flag1(p_ppsn_override varchar2) is
	select NVL (SUBSTR (paf.assignment_number, 1, 12), ' ') -- WORKS NUMBER
	from per_assignments_f paf, per_assignment_extra_info paei
	where paf.assignment_id = paei.assignment_id
	and aei_information1 = p_ppsn_override
    and paf.effective_start_date <= l_end_date
	and paf.effective_end_date   >= l_start_date
	and primary_flag = 'Y'
	group by NVL (SUBSTR (paf.assignment_number, 1, 12), ' ');

/* Cursor to fetch primary flag for active assignments PPSN OVERRIDE case*/
CURSOR csr_get_primary_flag_active1(p_ppsn_override varchar2) is
	select NVL (SUBSTR (paf.assignment_number, 1, 12), ' ') -- WORKS NUMBER
	from per_assignments_f paf,
	     per_assignment_extra_info paei
	where paf.assignment_id = paei.assignment_id
    and aei_information1 = p_ppsn_override
	and paf.effective_start_date <= l_end_date
	and paf.effective_end_date   >= l_start_date
	and primary_flag = 'Y'
	group by NVL (SUBSTR (paf.assignment_number, 1, 12), ' ')
	having max(effective_end_date) >= l_end_date;

--6633719

cnt			number;
v_action_type	pay_payroll_actions.action_type%TYPE;
v_report_type	pay_payroll_actions.report_type%TYPE;
v_work_number	per_assignments_f.assignment_number%TYPE;
v_assignment_id	pay_assignment_actions.assignment_id%TYPE;
v_action_id		pay_assignment_actions.assignment_action_id%TYPE;
v_payroll_action_id pay_payroll_actions.payroll_action_id%TYPE;
v_chunk		pay_assignment_actions.chunk_number%TYPE;
l_max_assignment_id per_assignments_f.assignment_id%TYPE;
v_date		date;
asg_assignment_id	per_assignments_f.assignment_id%TYPE;
l_max_action_id	pay_assignment_actions.assignment_action_id%TYPE;
l_cnt		number;
l_pl_cnt    number; --8259095
-- for P60 enhancement.
l_prev_pay		pay_action_information.action_information4%TYPE;
l_this_pay		pay_action_information.action_information4%TYPE;
l_prev_tax		pay_action_information.action_information4%TYPE;
l_this_tax		pay_action_information.action_information4%TYPE;
l_temp_pay		pay_action_information.action_information4%TYPE;
l_temp_tax		pay_action_information.action_information4%TYPE;

-- end P60
-- For P60 changes to PRSI section
l_this_insurable_weeks	pay_run_result_values.result_value%TYPE;
l_this_emp_prsi_cont	pay_run_result_values.result_value%TYPE;
l_this_tot_prsi		pay_run_result_values.result_value%TYPE;
l_this_initial_class	pay_run_result_values.result_value%TYPE;
l_this_sec_class		pay_run_result_values.result_value%TYPE;
l_this_weeks_at_sec_class	pay_run_result_values.result_value%TYPE;
-- end P60 changes to PRSI section

--6633719
l_ppsn_override per_assignment_extra_info.aei_information1%type;

cursor csr_ppsn_override(p_asg_id number)
is
select aei_information1 PPSN_OVERRIDE
from per_assignment_extra_info
where assignment_id = p_asg_id
and aei_information_category = 'IE_ASG_OVERRIDE';

l_child_assignment_action_id pay_assignment_actions.assignment_action_id%type;

CURSOR csr_child_actions(p_asg_id number) IS
SELECT paa.assignment_action_id child_assignment_action_id
       --,prt.run_method run_type
FROM   pay_assignment_actions paa,
       pay_run_types_f prt
WHERE  paa.run_type_id = prt.run_type_id
AND    prt.run_method IN ('N','P')
AND    p_effective_date BETWEEN prt.effective_start_date AND prt.effective_end_date
AND    paa.assignment_action_id = (SELECT /*+ USE_NL(paa, ppa) */
				          fnd_number.canonical_to_number(substr(max(lpad(paa.action_sequence,15,'0')||
				          paa.assignment_action_id),16)) child_assignment_action_id
				   FROM   pay_assignment_actions paa,
					  pay_payroll_actions    ppa
				   WHERE  paa.assignment_id = p_asg_id
				   AND    ppa.payroll_action_id = paa.payroll_action_id
				   AND    (paa.source_action_id is not null or ppa.action_type in ('I','V'))
				   AND    ppa.effective_date between trunc(p_effective_date,'Y') and p_effective_date
				   AND    ppa.action_type in ('R', 'Q', 'I', 'V')
				   AND    paa.action_status = 'C');


CURSOR Cur_Act_Contexts(p_source_id number) IS
SELECT pac.context_id, pac.context_value
FROM pay_action_contexts pac, ff_contexts ffc
WHERE pac.assignment_action_id = p_source_id
AND ffc.context_name = 'SOURCE_TEXT'
AND ffc.context_id = pac.context_id;

l_Act_Context_id pay_action_contexts.context_id%type;
l_Act_Context_value pay_action_contexts.context_value%type;

--6633719

BEGIN
	v_payroll_action_id := 0;
	v_assignment_id	:= 0;
	v_chunk		:= 0;
	--6633719
      l_ppsn_override := NULL;
	l_child_assignment_action_id := NULL;
	l_Act_Context_id := NULL;
	l_Act_Context_value := NULL;
    --6633719
    hr_utility.set_location('p_assactid ..'||p_assactid,1000);
    hr_utility.set_location('p_effective_date..'||p_effective_date,1000);


	OPEN get_assignment_id;
	FETCH get_assignment_id into v_payroll_action_id,v_assignment_id,v_chunk;
	CLOSE get_assignment_id;

    hr_utility.set_location('v_payroll_action_id..'||v_payroll_action_id,1000);
    hr_utility.set_location('v_assignment_id..'||v_assignment_id,1000);
    hr_utility.set_location('v_chunk..'||v_chunk,1000);
	--6633719
	OPEN csr_ppsn_override(v_assignment_id);
	FETCH csr_ppsn_override INTO l_ppsn_override;
	CLOSE csr_ppsn_override;
    hr_utility.set_location('l_ppsn_override..'||l_ppsn_override,1000);

    IF l_ppsn_override IS NOT NULL THEN
        l_dimension_name := '_PER_PAYE_REF_PPSN_YTD';
    ELSE
        l_dimension_name := '_PER_PAYE_REF_YTD';
    END IF;

    hr_utility.set_location('l_dimension_name..'||l_dimension_name,1000);

/* -- commented as new dimension ('_PER_PAYE_REF_PPSN_YTD') does not require contexes.
    IF l_ppsn_override IS NOT NULL THEN
	OPEN csr_child_actions(v_assignment_id);
	FETCH csr_child_actions INTO l_child_assignment_action_id;
	CLOSE csr_child_actions;
    hr_utility.set_location('l_child_assignment_action_id..'||l_child_assignment_action_id,1000);

    IF l_child_assignment_action_id IS NOT NULL THEN
    OPEN Cur_Act_Contexts(l_child_assignment_action_id);
    FETCH Cur_Act_Contexts INTO l_Act_Context_id,l_Act_Context_value;
    CLOSE Cur_Act_Contexts;
    hr_utility.set_location('l_Act_Context_id..'||l_Act_Context_id,1000);
    hr_utility.set_location('l_Act_Context_value..'||l_Act_Context_value,1000);
    END IF;

    END IF;
*/
	--6633719

	l_out_var :=
            pay_ie_p35.get_parameter (
               p_payroll_action_id=> v_payroll_action_id,
               p_token_name=> 'END_DATE'
            );
      l_end_date := TO_DATE (l_out_var, 'YYYY/MM/DD');
      l_out_var :=
            pay_ie_p35.get_parameter (
               p_payroll_action_id=> v_payroll_action_id,
               p_token_name=> 'START_DATE'
            );
      l_start_date := TO_DATE (l_out_var, 'YYYY/MM/DD');
      l_out_var :=
            pay_ie_p35.get_parameter (
               p_payroll_action_id=> v_payroll_action_id,
               p_token_name=> 'BG_ID'
            );
      l_bg_id := TO_NUMBER (l_out_var);

	l_segment4 := pay_ie_p35.get_parameter( p_payroll_action_id=> v_payroll_action_id,
							    p_token_name=> 'EMP_NO');
	l_out_var := pay_ie_p35.get_parameter (
			    p_payroll_action_id=> v_payroll_action_id,
			    p_token_name=> 'ASSIGNMENT_SET_ID'
			 );
	l_assignment_set_id := to_number(l_out_var);

	l_out_var := pay_ie_p35.get_parameter (
			    p_payroll_action_id=> v_payroll_action_id,
			    p_token_name=> 'PAYROLL'
			 );
	l_payroll_id := to_number(l_out_var);

	cnt := 0;
	-- Bug 3550403 : Flushing the variables for every assignment
	l_arch_pay := '0';
	l_arch_non_tax_pay := '0';
	l_arch_net_tax := '0';
	l_arch_employees_prsi_cont := '0';
	l_temp_prsi_cont := '0';
	l_arch_employer_prsi_cont := '0';
	l_arch_total_prsi_cont := '0';
	-- Tar 4061469.99 Flushing variables
	l_arch_second_class := ' ';
	l_arch_third_class := ' ';
	l_arch_third_class := ' ';
	l_arch_fourth_class := ' ';
	l_arch_fifth_class := ' ';

	l_arch_weeks_at_initial_class := 0;
	l_arch_weeks_at_second_class := 0;
	l_arch_weeks_at_third_class := 0;
	l_arch_weeks_at_fourth_class := 0;
	l_arch_weeks_at_fifth_class := 0;
	/*Bug 4023751- Flushing the variables for every assignment*/
	l_arch_ppsn:=' ';
	l_arch_works_number:=' ';
	l_arch_person_id:=null;
	l_arch_assignment_id:=null;
	l_max_assignment_id :=null;

	l_arch_assmt_action_id_bal:=null;
	l_arch_tax_or_refund:=0;
	/*Bug 4154171*/
	l_arch_tax_deduction_basis:='2';
	l_period_type := null;

	l_arch_surname:=null;
	l_arch_first_name:=null;
	l_arch_dob:=null;
	l_arch_address_line1:=null;
	l_arch_address_line2:=null;
	l_arch_address_line3:=null;
	l_arch_address_line4:=null; -- BUG 4066315
	l_arch_hire_date:=null;
	l_arch_term_date:=null;
	l_arch_annual_tax_credit:=0;
	l_arch_mothers_name:=null;
	l_arch_pr_indicator:=null;
	l_arch_previous_emp_pay:=0;
	l_arch_previous_emp_tax:=0;
	l_arch_total_notional_pay:=0;
	-- pension balances
	l_arch_pen_emp_rbs   := '0';
	l_arch_pen_empr_rbs  := '0';
	l_arch_pen_emp_prsa  := '0';
	l_arch_pen_empr_prsa := '0';
	l_arch_pen_emp_rac   := '0';

	l_arch_gross_pay     := '0'; /* 8520684 */
	l_arch_income_levy   := '0';
	l_arch_income_levy_first  := '0';
	l_arch_income_levy_second := '0';
	l_arch_income_levy_third  := '0';
	l_arch_parking_levy  := '0';
	l_temp_gross_pay     := '0';
	l_temp_income_levy   := '0';

	cnt := 0;
	--hr_utility.trace_on(null,'P35');
	hr_utility.set_location('In archive code..'||to_char(cnt),1001);
	FOR csr_interlocks IN get_actid_from_interlocks
	LOOP
		v_action_id := csr_interlocks.locked_action_id;
		hr_utility.set_location('csr_interlocks.locked_action_id ..'||csr_interlocks.locked_action_id,1002);


		-- v_action_id is either prepay or P30 action id
		OPEN get_action_type(csr_interlocks.locked_action_id);
		FETCH get_action_type into v_action_id,v_action_type;
		CLOSE get_action_type;

			hr_utility.set_location('Inside the loop ..',1002);
			hr_utility.set_location('Action Type ..'||v_action_type,1003);
			hr_utility.set_location('v_action_id ..'||v_action_id,1003);
--6633719
        IF l_ppsn_override IS NOT NULL THEN
         OPEN csr_rehire_ppsn_arch(v_action_id);
         FETCH csr_rehire_ppsn_arch INTO l_ppsn_bal_archived;
--6633719QA
         IF csr_rehire_ppsn_arch%NOTFOUND
         THEN
         l_ppsn_bal_archived := 'N';
         END IF;
--6633719QA
         CLOSE csr_rehire_ppsn_arch;

		 hr_utility.set_location('l_ppsn_bal_archived ..'||l_ppsn_bal_archived,1004);
		END IF;
--6633719
		IF cnt = 0 then
		-- This part to executed only once for each locking action id to fetch balances for max assignment actionid
		--
			--l_actid := csr_interlocks.locking_action_id;
			IF v_action_type = 'X' then

				l_max_action_id := csr_interlocks.locked_action_id;

			    hr_utility.set_location('l_max_action_id ..'||l_max_action_id,1005);
			    hr_utility.set_location('Inside IEPS ..'||to_char(l_actid),1005);

			    OPEN csr_p30_bal_value (v_action_id, 'IE TAXABLE PAY',l_dimension_name);
			    FETCH csr_p30_bal_value INTO l_arch_pay;
			--6633719 if condition added for the scenarios where employee is rehired
			--and have different PPSN OVERRIDES and for terminated (previous assignments)
			--the PPSN dimension balances not archived.
			--e.g terminated in JUL and rehired in DEC with different PPSN OVERRIDE.
                 IF csr_p30_bal_value%NOTFOUND AND l_ppsn_bal_archived = 'N' THEN

			        l_arch_pay :=
				   TO_CHAR (
					ROUND (
					   NVL (
						pay_balance_pkg.get_value (
						   pay_ie_p35.get_defined_balance_id (
							l_dimension_name,
							'IE Taxable Pay'
						   ),
						   csr_interlocks.locked_action_id,
						   l_segment4, -- paye reference value
						    null,
						    null,
						    null,
						    null,
						    null,
						    null,
						    'TRUE'
						),
						0
					   ),
					   2
					)
				   );

                hr_utility.set_location('l_arch_pay not archived ..'||l_arch_pay,1004);

			     END IF;
			--6633719
                CLOSE csr_p30_bal_value;
			    hr_utility.set_location('l_arch_pay..'||l_arch_pay,1005);

			    OPEN csr_p30_bal_value (v_action_id, 'IE NET TAX',l_dimension_name);
			    FETCH csr_p30_bal_value INTO l_arch_net_tax;
			--6633719
                 IF csr_p30_bal_value%NOTFOUND AND l_ppsn_bal_archived = 'N' THEN

			        l_arch_net_tax :=
				   TO_CHAR (
					ROUND (
					   NVL (
						pay_balance_pkg.get_value (
						   pay_ie_p35.get_defined_balance_id (
							l_dimension_name,
							'IE Net Tax'
						   ),
						   csr_interlocks.locked_action_id,
						   l_segment4, -- paye reference value
						    null,
						    null,
						    null,
						    null,
						    null,
						    null,
						    'TRUE'
						),
						0
					   ),
					   2
					)
				   );

                hr_utility.set_location('l_arch_net_tax not archived ..'||l_arch_net_tax,1004);

			     END IF;
			--6633719
                CLOSE csr_p30_bal_value;
			    hr_utility.set_location('l_arch_net_tax..'||l_arch_net_tax,1005);

			    OPEN csr_p30_bal_value (v_action_id, 'IE PRSI EMPLOYEE',l_dimension_name);
			    FETCH csr_p30_bal_value INTO l_arch_employees_prsi_cont;
			--6633719
                 IF csr_p30_bal_value%NOTFOUND AND l_ppsn_bal_archived = 'N' THEN

			        l_arch_employees_prsi_cont :=
				   TO_CHAR (
					ROUND (
					   NVL (
						pay_balance_pkg.get_value (
						   pay_ie_p35.get_defined_balance_id (
							l_dimension_name,
							'IE PRSI Employee'
						   ),
						   csr_interlocks.locked_action_id,
						   l_segment4, -- paye reference value
						    null,
						    null,
						    null,
						    null,
						    null,
						    null,
						    'TRUE'
						),
						0
					   ),
					   2
					)
				   );

                hr_utility.set_location('l_arch_employees_prsi_cont not archived ..'||l_arch_employees_prsi_cont,1004);

			     END IF;
			--6633719
                CLOSE csr_p30_bal_value;
			    hr_utility.set_location('l_arch_employees_prsi_cont..'||l_arch_employees_prsi_cont,1005);

			    --Bug 4553755
			    /*OPEN csr_p30_bal_value (v_action_id, 'IE BIK TAXABLE AND PRSIABLE PAY');
			    FETCH csr_p30_bal_value INTO l_arch_total_notional_pay;
			    CLOSE csr_p30_bal_value;*/

			    -- Added K and M Employee figures in case of severance payment
			    OPEN csr_p30_bal_value (v_action_id,'IE PRSI K EMPLOYEE LUMP SUM',l_dimension_name);
			    FETCH csr_p30_bal_value INTO l_temp_prsi_cont;
			--6633719
                 IF csr_p30_bal_value%NOTFOUND AND l_ppsn_bal_archived = 'N' THEN

			        l_temp_prsi_cont :=
				   TO_CHAR (
					ROUND (
					   NVL (
						pay_balance_pkg.get_value (
						   pay_ie_p35.get_defined_balance_id (
							l_dimension_name,
							'IE PRSI K Employee Lump Sum'
						   ),
						   csr_interlocks.locked_action_id,
						   l_segment4, -- paye reference value
						    null,
						    null,
						    null,
						    null,
						    null,
						    null,
						    'TRUE'
						),
						0
					   ),
					   2
					)
				   );

                hr_utility.set_location('l_temp_prsi_cont not archived ..'||l_temp_prsi_cont,1004);

			     END IF;
			--6633719
			    CLOSE csr_p30_bal_value;
			    hr_utility.set_location('IE PRSI K EMPLOYEE LUMP SUM l_temp_prsi_cont..'||l_temp_prsi_cont,1005);

			    l_arch_employees_prsi_cont :=
				  TO_CHAR (
					 TO_NUMBER (l_arch_employees_prsi_cont)
				     + TO_NUMBER (NVL (l_temp_prsi_cont, '0'))
				  );
			    l_temp_prsi_cont := NULL;
hr_utility.set_location('IE PRSI K EMPLOYEE LUMP SUM l_arch_employees_prsi_cont..'||l_arch_employees_prsi_cont,1005);

                OPEN csr_p30_bal_value (v_action_id,'IE PRSI M EMPLOYEE LUMP SUM',l_dimension_name);
			    FETCH csr_p30_bal_value INTO l_temp_prsi_cont;
			--6633719
                 IF csr_p30_bal_value%NOTFOUND AND l_ppsn_bal_archived = 'N' THEN

			        l_temp_prsi_cont :=
				   TO_CHAR (
					ROUND (
					   NVL (
						pay_balance_pkg.get_value (
						   pay_ie_p35.get_defined_balance_id (
							l_dimension_name,
							'IE PRSI M Employee Lump Sum'
						   ),
						   csr_interlocks.locked_action_id,
						   l_segment4, -- paye reference value
						    null,
						    null,
						    null,
						    null,
						    null,
						    null,
						    'TRUE'
						),
						0
					   ),
					   2
					)
				   );

                hr_utility.set_location('l_temp_prsi_cont not archived ..'||l_temp_prsi_cont,1004);

			     END IF;
			--6633719
                CLOSE csr_p30_bal_value;
			    hr_utility.set_location('IE PRSI M EMPLOYEE LUMP SUM l_temp_prsi_cont..'||l_temp_prsi_cont,1005);

                l_arch_employees_prsi_cont :=
				  TO_CHAR (
					 TO_NUMBER (l_arch_employees_prsi_cont)
				     + TO_NUMBER (NVL (l_temp_prsi_cont, '0'))
				  );
			    l_temp_prsi_cont := NULL;
hr_utility.set_location('E PRSI M EMPLOYEE LUMP SUM l_arch_employees_prsi_cont..'||l_arch_employees_prsi_cont,1005);

			    OPEN csr_p30_bal_value (v_action_id, 'IE PRSI EMPLOYER',l_dimension_name);
			    FETCH csr_p30_bal_value INTO l_arch_employer_prsi_cont;
			--6633719
                 IF csr_p30_bal_value%NOTFOUND AND l_ppsn_bal_archived = 'N' THEN

			        l_arch_employer_prsi_cont :=
				   TO_CHAR (
					ROUND (
					   NVL (
						pay_balance_pkg.get_value (
						   pay_ie_p35.get_defined_balance_id (
							l_dimension_name,
							'IE PRSI Employer'
						   ),
						   csr_interlocks.locked_action_id,
						   l_segment4, -- paye reference value
						    null,
						    null,
						    null,
						    null,
						    null,
						    null,
						    'TRUE'
						),
						0
					   ),
					   2
					)
				   );

                hr_utility.set_location('l_arch_employer_prsi_cont not archived ..'||l_arch_employer_prsi_cont,1004);

			     END IF;
			--6633719
			    CLOSE csr_p30_bal_value;
			    hr_utility.set_location('IE PRSI EMPLOYER l_arch_employer_prsi_cont..'||l_arch_employer_prsi_cont,1005);

		-- Added K and M Employer figuresin case of severance payment
			    OPEN csr_p30_bal_value (v_action_id,'IE PRSI K EMPLOYER LUMP SUM',l_dimension_name);
			    FETCH csr_p30_bal_value INTO l_temp_prsi_cont;
			--6633719
                 IF csr_p30_bal_value%NOTFOUND AND l_ppsn_bal_archived = 'N' THEN

			        l_temp_prsi_cont :=
				   TO_CHAR (
					ROUND (
					   NVL (
						pay_balance_pkg.get_value (
						   pay_ie_p35.get_defined_balance_id (
							l_dimension_name,
							'IE PRSI K Employer Lump Sum'
						   ),
						   csr_interlocks.locked_action_id,
						   l_segment4, -- paye reference value
						    null,
						    null,
						    null,
						    null,
						    null,
						    null,
						    'TRUE'
						),
						0
					   ),
					   2
					)
				   );

                hr_utility.set_location('l_temp_prsi_cont not archived ..'||l_temp_prsi_cont,1004);

			     END IF;
			--6633719
			    CLOSE csr_p30_bal_value;
			    hr_utility.set_location('IE PRSI K EMPLOYER LUMP SUM l_temp_prsi_cont..'||l_temp_prsi_cont,1005);

                l_arch_employer_prsi_cont :=
				  TO_CHAR (
					 TO_NUMBER (l_arch_employer_prsi_cont)
				     + TO_NUMBER (NVL (l_temp_prsi_cont, '0'))
				  );
			    l_temp_prsi_cont := NULL;
			    hr_utility.set_location('IE PRSI K EMPLOYER LUMP SUM l_arch_employer_prsi_cont..'||l_arch_employer_prsi_cont,1005);

                OPEN csr_p30_bal_value (v_action_id,'IE PRSI M EMPLOYER LUMP SUM',l_dimension_name);
			    FETCH csr_p30_bal_value INTO l_temp_prsi_cont;
			--6633719
                 IF csr_p30_bal_value%NOTFOUND AND l_ppsn_bal_archived = 'N' THEN

			        l_temp_prsi_cont :=
				   TO_CHAR (
					ROUND (
					   NVL (
						pay_balance_pkg.get_value (
						   pay_ie_p35.get_defined_balance_id (
							l_dimension_name,
							'IE PRSI M Employer Lump Sum'
						   ),
						   csr_interlocks.locked_action_id,
						   l_segment4, -- paye reference value
						    null,
						    null,
						    null,
						    null,
						    null,
						    null,
						    'TRUE'
						),
						0
					   ),
					   2
					)
				   );

                hr_utility.set_location('l_temp_prsi_cont not archived ..'||l_temp_prsi_cont,1004);

			     END IF;
			--6633719
                CLOSE csr_p30_bal_value;
			    hr_utility.set_location('IE PRSI M EMPLOYER LUMP SUM l_temp_prsi_cont..'||l_temp_prsi_cont,1005);

                l_arch_employer_prsi_cont :=
				  TO_CHAR (
					 TO_NUMBER (l_arch_employer_prsi_cont)
				     + TO_NUMBER (NVL (l_temp_prsi_cont, '0'))
				  );
			    l_temp_prsi_cont := NULL;
			    l_arch_total_prsi_cont :=
				  TO_CHAR (
					 TO_NUMBER (NVL (l_arch_employees_prsi_cont, 0))
				     + TO_NUMBER (NVL (l_arch_employer_prsi_cont, 0))
				  );
			    hr_utility.set_location('l_arch_total_prsi_cont..'||l_arch_total_prsi_cont,1005);
                       --Bug 4553755
   -- Passed Payroll Run assignment action id csr_interlocks.locked_action_id 4672715

			     l_arch_total_notional_pay :=
				   TO_CHAR (
					ROUND (
					   NVL (
						pay_balance_pkg.get_value (
						   pay_ie_p35.get_defined_balance_id (
							l_dimension_name, --'_PER_PAYE_REF_YTD',--6633719
							'IE BIK Taxable and PRSIable Pay'
						   ),
						   csr_interlocks.locked_action_id, --l_arch_assmt_action_id_bal,
						   l_segment4, -- paye reference value
						    null,
						    l_Act_Context_id,  --null,
						    l_Act_Context_value,  --null,
						    null,
						    null,
						    null,
						    'TRUE'
						),
						0
					   ),
					   2
					)
				   );
			    hr_utility.set_location('l_arch_total_notional_pay..'||l_arch_total_notional_pay,1005);
   -- Passed Payroll Run assignment action id csr_interlocks.locked_action_id 4672715
			    /* Start Pension Balances */
			    l_arch_pen_emp_rbs :=
				   TO_CHAR (
					ROUND (
					   NVL (
						pay_balance_pkg.get_value (
						   pay_ie_p35.get_defined_balance_id (
							l_dimension_name,  --'_PER_PAYE_REF_YTD',--6633719
							'IE RBS EE Contribution'
						   ),
						   csr_interlocks.locked_action_id, --l_arch_assmt_action_id_bal,
						   l_segment4, -- paye reference value
						    null,
						    l_Act_Context_id, --null,
						    l_Act_Context_value, --null,
						    null,
						    null,
						    null,
						    'TRUE'
						),
						0
					   ),
					   2
					)
					+
					ROUND (
					   NVL (
						pay_balance_pkg.get_value (
						   pay_ie_p35.get_defined_balance_id (
							l_dimension_name,  --'_PER_PAYE_REF_YTD', --6633719
							'IE RBS EE AVC Contribution'
						   ),
						   csr_interlocks.locked_action_id, --l_arch_assmt_action_id_bal,
						   l_segment4, -- paye reference value
						    null,
						    l_Act_Context_id,  --null,
						    l_Act_Context_value,  --null,
						    null,
						    null,
						    null,
						    'TRUE'
						),
						0
					   ),
					   2
					)
				   );
			    hr_utility.set_location('l_arch_pen_emp_rbs..'||l_arch_pen_emp_rbs,1005);
				l_arch_pen_empr_rbs :=
				   TO_CHAR (
					ROUND (
					   NVL (
						pay_balance_pkg.get_value (
						   pay_ie_p35.get_defined_balance_id (
							l_dimension_name,   --'_PER_PAYE_REF_YTD',--6633719
							'IE RBS ER Contribution'
						   ),
						   csr_interlocks.locked_action_id, --l_arch_assmt_action_id_bal,
						   l_segment4, -- paye reference value
						    null,
						    l_Act_Context_id,  --null,
						    l_Act_Context_value,  --null,
						    null,
						    null,
						    null,
						    'TRUE'
						),
						0
					   ),
					   2
					)
				     );
			    hr_utility.set_location('l_arch_pen_empr_rbs..'||l_arch_pen_empr_rbs,1005);
				l_arch_pen_emp_prsa :=
					   TO_CHAR (
						ROUND (
						   NVL (
							pay_balance_pkg.get_value (
							   pay_ie_p35.get_defined_balance_id (
								l_dimension_name,   ---'_PER_PAYE_REF_YTD',--6633719
								'IE PRSA EE Contribution'
							   ),
							   csr_interlocks.locked_action_id, --l_arch_assmt_action_id_bal,
							  l_segment4, -- paye reference value
							    null,
							    l_Act_Context_id,  --null,
							    l_Act_Context_value,  --null,
							    null,
							    null,
							    null,
							    'TRUE'
							),
							0
						   ),
						   2
						)
						+
						ROUND (
						   NVL (
							pay_balance_pkg.get_value (
							   pay_ie_p35.get_defined_balance_id (
								l_dimension_name,  ---'_PER_PAYE_REF_YTD',--6633719
								'IE PRSA EE AVC Contribution'
							   ),
							   csr_interlocks.locked_action_id, --l_arch_assmt_action_id_bal,
							   l_segment4, -- paye reference value
							    null,
							    l_Act_Context_id,  --null,
							    l_Act_Context_value,  --null,
							    null,
							    null,
							    null,
							    'TRUE'
							),
							0
						   ),
						   2
						)
					   );
			    hr_utility.set_location('l_arch_pen_emp_prsa..'||l_arch_pen_emp_prsa,1005);
				l_arch_pen_empr_prsa :=
				   TO_CHAR (
					ROUND (
					   NVL (
						pay_balance_pkg.get_value (
						   pay_ie_p35.get_defined_balance_id (
							l_dimension_name,   ---'_PER_PAYE_REF_YTD',--6633719
							'IE PRSA ER Contribution'
						   ),
						   csr_interlocks.locked_action_id, --l_arch_assmt_action_id_bal,
						  l_segment4, -- paye reference value
						    null,
						    l_Act_Context_id,  --null,
						    l_Act_Context_value,  --null,
						    null,
						    null,
						    null,
						    'TRUE'
						),
						0
					   ),
					   2
					)
				     );
			    hr_utility.set_location('l_arch_pen_empr_prsa..'||l_arch_pen_empr_prsa,1005);
				l_arch_pen_emp_rac :=
				   TO_CHAR (
					ROUND (
					   NVL (
						pay_balance_pkg.get_value (
						   pay_ie_p35.get_defined_balance_id (
							l_dimension_name,   ---'_PER_PAYE_REF_YTD',--6633719
							'IE RAC EE Contribution'
						   ),
						   csr_interlocks.locked_action_id, --l_arch_assmt_action_id_bal,
						  l_segment4, -- paye reference value
						    null,
						    l_Act_Context_id,  --null,
						    l_Act_Context_value,  --null,
						    null,
						    null,
						    null,
						    'TRUE'
						),
						0
					   ),
					   2
					)
				     );
			/* End Pension Balances */
			    hr_utility.set_location('l_arch_pen_emp_rac..'||l_arch_pen_emp_rac,1005);
			    /* start of gross pay balances */
                            OPEN csr_p30_bal_value (v_action_id, 'IE GROSS INCOME ADJUSTMENT',l_dimension_name); /* 8520684 */
			    FETCH csr_p30_bal_value INTO l_temp_gross_pay;
			--6633719
                 IF csr_p30_bal_value%NOTFOUND AND l_ppsn_bal_archived = 'N' THEN

			        l_temp_gross_pay :=
				   TO_CHAR (
					ROUND (
					   NVL (
						pay_balance_pkg.get_value (
						   pay_ie_p35.get_defined_balance_id (
							l_dimension_name,
							'IE Gross Income Adjustment'
						   ),
						   csr_interlocks.locked_action_id,
						   l_segment4, -- paye reference value
						    null,
						    null,
						    null,
						    null,
						    null,
						    null,
						    'TRUE'
						),
						0
					   ),
					   2
					)
				   );
                     hr_utility.set_location('l_temp_gross_pay not archived ..'|| l_temp_gross_pay,1004);
                 END IF;
                            CLOSE csr_p30_bal_value;
hr_utility.set_location('IE Gross Income Adjustment l_temp_gross_pay..'||l_temp_gross_pay,1005);

			    l_arch_gross_pay :=
				  TO_CHAR (
					 TO_NUMBER (l_arch_gross_pay)
				     + TO_NUMBER (NVL (l_temp_gross_pay, '0'))
				  );
			    l_temp_gross_pay := NULL;
hr_utility.set_location('IE Gross Income Adjustment l_arch_gross_pay..'||l_arch_gross_pay,1005);

                            OPEN csr_p30_bal_value (v_action_id, 'IE GROSS INCOME',l_dimension_name);
			    FETCH csr_p30_bal_value INTO l_temp_gross_pay;
			--6633719
                 IF csr_p30_bal_value%NOTFOUND AND l_ppsn_bal_archived = 'N' THEN

			        l_temp_gross_pay :=
				   TO_CHAR (
					ROUND (
					   NVL (
						pay_balance_pkg.get_value (
						   pay_ie_p35.get_defined_balance_id (
							l_dimension_name,
							'IE Gross Income'
						   ),
						   csr_interlocks.locked_action_id,
						   l_segment4, -- paye reference value
						    null,
						    null,
						    null,
						    null,
						    null,
						    null,
						    'TRUE'
						),
						0
					   ),
					   2
					)
				   );
                     hr_utility.set_location('l_temp_gross_pay not archived ..'|| l_temp_gross_pay,1004);
                 END IF;
                            CLOSE csr_p30_bal_value;
hr_utility.set_location('IE Gross Income l_temp_gross_pay..'||l_temp_gross_pay,1005);

			    l_arch_gross_pay :=
				  TO_CHAR (
					 TO_NUMBER (l_arch_gross_pay)
				     + TO_NUMBER (NVL (l_temp_gross_pay, '0'))
				  );
			    l_temp_gross_pay := NULL;
hr_utility.set_location('IE Gross Income l_arch_gross_pay..'||l_arch_gross_pay,1005);

                            OPEN csr_p30_bal_value (v_action_id, 'IE BIK TAXABLE AND PRSIABLE PAY',l_dimension_name);
			    FETCH csr_p30_bal_value INTO l_temp_gross_pay;
			--6633719
                 IF csr_p30_bal_value%NOTFOUND AND l_ppsn_bal_archived = 'N' THEN

			        l_temp_gross_pay :=
				   TO_CHAR (
					ROUND (
					   NVL (
						pay_balance_pkg.get_value (
						   pay_ie_p35.get_defined_balance_id (
							l_dimension_name,
							'IE BIK Taxable and PRSIable Pay'
						   ),
						   csr_interlocks.locked_action_id,
						   l_segment4, -- paye reference value
						    null,
						    null,
						    null,
						    null,
						    null,
						    null,
						    'TRUE'
						),
						0
					   ),
					   2
					)
				   );
                     hr_utility.set_location('l_temp_gross_pay not archived ..'|| l_temp_gross_pay,1004);
                 END IF;
                            CLOSE csr_p30_bal_value;
hr_utility.set_location('IE BIK Taxable and PRSIable Pay l_temp_gross_pay..'||l_temp_gross_pay,1005);

			    l_arch_gross_pay :=
				  TO_CHAR (
					 TO_NUMBER (l_arch_gross_pay)
				     + TO_NUMBER (NVL (l_temp_gross_pay, '0'))
				  );
			    l_temp_gross_pay := NULL;
hr_utility.set_location('IE BIK Taxable and PRSIable Pay l_arch_gross_pay..'||l_arch_gross_pay,1005);

                            /*  income tax levy  balances */
                            OPEN csr_p30_bal_value (v_action_id, 'IE INCOME TAX LEVY',l_dimension_name); /* 8520684 */
			    FETCH csr_p30_bal_value INTO l_temp_income_levy;
			--6633719
                 IF csr_p30_bal_value%NOTFOUND AND l_ppsn_bal_archived = 'N' THEN

			        l_temp_income_levy :=
				   TO_CHAR (
					ROUND (
					   NVL (
						pay_balance_pkg.get_value (
						   pay_ie_p35.get_defined_balance_id (
							l_dimension_name,
							'IE Income Tax Levy'
						   ),
						   csr_interlocks.locked_action_id,
						   l_segment4, -- paye reference value
						    null,
						    null,
						    null,
						    null,
						    null,
						    null,
						    'TRUE'
						),
						0
					   ),
					   2
					)
				   );
                     hr_utility.set_location('l_temp_income_levy not archived ..'|| l_temp_income_levy,1004);
                 END IF;
                            CLOSE csr_p30_bal_value;
hr_utility.set_location('IE Income Tax Levy l_temp_income_levy..'||l_temp_income_levy,1005);

			    l_arch_income_levy :=
				  TO_CHAR (
					 TO_NUMBER (l_arch_income_levy)
				     + TO_NUMBER (NVL (l_temp_income_levy, '0'))
				  );
			    l_temp_income_levy := NULL;
hr_utility.set_location('IE Income Tax Levy l_arch_income_levy..'||l_arch_income_levy,1005);

                        /* 8978805 */
			/*
                            OPEN csr_p30_bal_value (v_action_id, 'IE INCOME TAX LEVY REFUND AMOUNT',l_dimension_name);
			    FETCH csr_p30_bal_value INTO l_temp_income_levy;
			--6633719
                 IF csr_p30_bal_value%NOTFOUND AND l_ppsn_bal_archived = 'N' THEN

			        l_temp_income_levy :=
				   TO_CHAR (
					ROUND (
					   NVL (
						pay_balance_pkg.get_value (
						   pay_ie_p35.get_defined_balance_id (
							l_dimension_name,
							'IE Income Tax Levy Refund Amount'
						   ),
						   csr_interlocks.locked_action_id,
						   l_segment4, -- paye reference value
						    null,
						    null,
						    null,
						    null,
						    null,
						    null,
						    'TRUE'
						),
						0
					   ),
					   2
					)
				   );
                     hr_utility.set_location('l_temp_income_levy not archived ..'|| l_temp_income_levy,1004);
                 END IF;
CLOSE csr_p30_bal_value;
hr_utility.set_location('IE Income Tax Levy Refund Amount l_temp_income_levy..'||l_temp_income_levy,1005);	*/

			    l_arch_income_levy :=
				  TO_CHAR (
					 TO_NUMBER (l_arch_income_levy)
				     + TO_NUMBER (NVL (l_temp_income_levy, '0'))
				  );
			    l_temp_income_levy := NULL;
hr_utility.set_location('IE Income Tax Levy Refund Amount l_arch_income_levy..'||l_arch_income_levy,1005);

                            /* first band */
                            OPEN csr_p30_bal_value (v_action_id, 'IE INCOME TAX LEVY FIRST BAND',l_dimension_name); /* 8520684 */
			    FETCH csr_p30_bal_value INTO l_arch_income_levy_first;
			--6633719
                 IF csr_p30_bal_value%NOTFOUND AND l_ppsn_bal_archived = 'N' THEN

			        l_arch_income_levy_first :=
				   TO_CHAR (
					ROUND (
					   NVL (
						pay_balance_pkg.get_value (
						   pay_ie_p35.get_defined_balance_id (
							l_dimension_name,
							'IE Income Tax Levy First Band'
						   ),
						   csr_interlocks.locked_action_id,
						   l_segment4, -- paye reference value
						    null,
						    null,
						    null,
						    null,
						    null,
						    null,
						    'TRUE'
						),
						0
					   ),
					   2
					)
				   );

                hr_utility.set_location('l_arch_income_levy_first not archived ..'||l_arch_income_levy_first,1004);

			     END IF;
			--6633719
                CLOSE csr_p30_bal_value;
			    hr_utility.set_location('l_arch_income_levy_first..'||l_arch_income_levy_first,1005);

                            /* second band  */
                            OPEN csr_p30_bal_value (v_action_id, 'IE INCOME TAX LEVY SECOND BAND',l_dimension_name); /* 8520684 */
			    FETCH csr_p30_bal_value INTO l_arch_income_levy_second;
			--6633719
                 IF csr_p30_bal_value%NOTFOUND AND l_ppsn_bal_archived = 'N' THEN

			        l_arch_income_levy_second :=
				   TO_CHAR (
					ROUND (
					   NVL (
						pay_balance_pkg.get_value (
						   pay_ie_p35.get_defined_balance_id (
							l_dimension_name,
							'IE Income Tax Levy Second Band'
						   ),
						   csr_interlocks.locked_action_id,
						   l_segment4, -- paye reference value
						    null,
						    null,
						    null,
						    null,
						    null,
						    null,
						    'TRUE'
						),
						0
					   ),
					   2
					)
				   );

                hr_utility.set_location('l_arch_income_levy_second not archived ..'||l_arch_income_levy_second,1004);

			     END IF;
			--6633719
                CLOSE csr_p30_bal_value;
			    hr_utility.set_location('l_arch_income_levy_second..'||l_arch_income_levy_second,1005);


                            /* Third band  */
                            OPEN csr_p30_bal_value (v_action_id, 'IE INCOME TAX LEVY THIRD BAND',l_dimension_name); /* 8520684 */
			    FETCH csr_p30_bal_value INTO l_arch_income_levy_third;
			--6633719
                 IF csr_p30_bal_value%NOTFOUND AND l_ppsn_bal_archived = 'N' THEN

			        l_arch_income_levy_third :=
				   TO_CHAR (
					ROUND (
					   NVL (
						pay_balance_pkg.get_value (
						   pay_ie_p35.get_defined_balance_id (
							l_dimension_name,
							'IE Income Tax Levy Third Band'
						   ),
						   csr_interlocks.locked_action_id,
						   l_segment4, -- paye reference value
						    null,
						    null,
						    null,
						    null,
						    null,
						    null,
						    'TRUE'
						),
						0
					   ),
					   2
					)
				   );

                hr_utility.set_location('l_arch_income_levy_third not archived ..'||l_arch_income_levy_third,1004);

			     END IF;
			--6633719
                CLOSE csr_p30_bal_value;
			    hr_utility.set_location('l_arch_income_levy_third..'||l_arch_income_levy_third,1005);

			    /* Parking Levy   */
                            OPEN csr_p30_bal_value (v_action_id, 'IE PARKING LEVY',l_dimension_name); /* 8520684 */
			    FETCH csr_p30_bal_value INTO l_arch_parking_levy;
			--6633719
                 IF csr_p30_bal_value%NOTFOUND AND l_ppsn_bal_archived = 'N' THEN

			        l_arch_parking_levy :=
				   TO_CHAR (
					ROUND (
					   NVL (
						pay_balance_pkg.get_value (
						   pay_ie_p35.get_defined_balance_id (
							l_dimension_name,
							'IE Parking Levy'
						   ),
						   csr_interlocks.locked_action_id,
						   l_segment4, -- paye reference value
						    null,
						    null,
						    null,
						    null,
						    null,
						    null,
						    'TRUE'
						),
						0
					   ),
					   2
					)
				   );

                hr_utility.set_location('l_arch_parking_levy not archived ..'||l_arch_parking_levy,1004);

			     END IF;
			--6633719
                CLOSE csr_p30_bal_value;
			    hr_utility.set_location('l_arch_parking_levy..'||l_arch_parking_levy,1005);


			-- BIK Medical insurance 5867343
			l_medical_insurance :=
				   TO_CHAR (
					ROUND (
					   NVL (
						pay_balance_pkg.get_value (
						   pay_ie_p35.get_defined_balance_id (
							l_dimension_name,  ---'_PER_PAYE_REF_YTD',--6633719
							'IE BIK Medical Insurance'
						   ),
						   csr_interlocks.locked_action_id, --l_arch_assmt_action_id_bal,
						  l_segment4, -- paye reference value
						    null,
						    l_Act_Context_id,  --null,
						    l_Act_Context_value,  --null,
						    null,
						    null,
						    null,
						    'TRUE'
						),
						0
					   ),
					   2
					)
				     );
			    hr_utility.set_location('l_medical_insurance..'||l_medical_insurance,1005);
			    /*Bug No. 4063502*/
			     IF nvl(l_arch_pay,0) = 0 THEN -- if IE TAXABLE PAY is 0
			    hr_utility.set_location('Inside If l_arch_non_tax_pay..'||l_arch_non_tax_pay,1005);
				l_arch_non_tax_pay :=
					 TO_CHAR (
					    ROUND (
						 NVL (
						  pay_balance_pkg.get_value (
						     pay_ie_p35.get_defined_balance_id (
							l_dimension_name,   ---'_PER_PAYE_REF_YTD',--6633719
							'Total Pay'
						     ),
						     csr_interlocks.locked_action_id,
						   l_segment4, -- paye reference value
						    null,
						    l_Act_Context_id,  --null,
						    l_Act_Context_value,  --null,
						    null,
						    null,
						    null,
						    'TRUE'
						  ),
						  0
						 ),
						 2
					    )
					 );
			    hr_utility.set_location('l_arch_non_tax_pay..'||l_arch_non_tax_pay,1005);
			     END IF;


			    SELECT DECODE (
					SIGN (TO_NUMBER (NVL (l_arch_net_tax, 0))),
					-1, '1',
					1, '0',
					'0'
				   )
				INTO l_arch_tax_or_refund
				FROM DUAL;


		   hr_utility.set_location('l_arch_tax_or_refund..'||l_arch_tax_or_refund,1005);
           hr_utility.set_location('b4  cursor csr_p30_found..',1005);

				   --
			-- BUG 3306202 Added cursor CSR_P30_PERSON
			OPEN csr_p30_found (v_action_id, l_arch_net_tax,csr_interlocks.locked_action_id);
			/*Shifted this cursor for bug 4023751*/
			FETCH csr_p30_found INTO l_arch_ppsn,
							    l_arch_works_number,
							    l_arch_person_id,
							    l_arch_primary_flag,
							    l_arch_assignment_id,
							--    l_arch_tax_deduction_basis,
							    l_arch_surname,
							    l_arch_first_name,
							    l_arch_dob,
							    l_arch_address_line1,
							    l_arch_address_line2,
							    l_arch_address_line3,
							    l_arch_address_line4,
							    l_arch_hire_date,
							    l_period_type,
							--    l_arch_annual_tax_credit,
							    l_arch_term_date,
							    l_arch_mothers_name,
							    l_arch_pr_indicator,
							    l_arch_previous_emp_pay,
							    l_arch_previous_emp_tax;
			CLOSE csr_p30_found;
			/* lock this v_action_id*/
           hr_utility.set_location('after  cursor csr_p30_found..',1005);
		   hr_utility.set_location('l_arch_works_number..'||l_arch_works_number,1005);
		   hr_utility.set_location('l_arch_ppsn..'||l_arch_ppsn,1005);
		   hr_utility.set_location('l_arch_primary_flag..'||l_arch_primary_flag,1005);
		   hr_utility.set_location('l_arch_assignment_id..'||l_arch_assignment_id,1005);

		ELSIF v_action_type in ('P','U') THEN
			hr_utility.set_location('Inside P,U ..'||to_char(l_actid),1006);
			l_max_action_id := csr_interlocks.locked_action_id;
			hr_utility.set_location('l_max_action_id..'||l_max_action_id,1006);
			hr_utility.set_location('v_action_id..'||v_action_id,1006);
			hr_utility.set_location('B4 cursor csr_prepay_found..',1006);

			OPEN csr_prepay_found (v_action_id,
                                   csr_interlocks.locked_action_id,
                                   l_dimension_name,
                                   l_Act_Context_id,
                                   l_Act_Context_value);
			FETCH csr_prepay_found INTO l_arch_ppsn,
								 l_arch_works_number,
								 l_arch_person_id,
								 l_arch_primary_flag,
								 l_arch_assignment_id,
								 l_arch_assmt_action_id_bal,
								 l_arch_tax_or_refund,
							   --    l_arch_tax_deduction_basis,
								 l_arch_surname,
								 l_arch_first_name,
								 l_arch_dob,
								 l_arch_address_line1,
								 l_arch_address_line2,
								 l_arch_address_line3,
								 l_arch_address_line4, -- BUG 4066315
								 l_arch_hire_date,
								 l_arch_term_date,
								 l_period_type,
							   --    l_arch_annual_tax_credit,
								 l_arch_mothers_name,
								 l_arch_pr_indicator,
								 l_arch_previous_emp_pay,
								 l_arch_previous_emp_tax;
			   CLOSE csr_prepay_found;
			hr_utility.set_location('After cursor csr_prepay_found..',1006);
		   hr_utility.set_location('l_arch_works_number..'||l_arch_works_number,1006);
		   hr_utility.set_location('l_arch_ppsn..'||l_arch_ppsn,1006);
		   hr_utility.set_location('l_arch_primary_flag..'||l_arch_primary_flag,1006);
		   hr_utility.set_location('l_arch_assignment_id..'||l_arch_assignment_id,1006);


			    /* if data found in the prepayment cursor then call the below functions to retrieve the remaining data for archiving */
			   -- Added K and M Employee and Employer figures for severance payment to variables l_arch_employees_prsi_cont and l_arch_total_prsi_cont
                           -- Passed Payroll Run assignment action id csr_interlocks.locked_action_id 4672715
			   l_arch_net_tax :=
				   TO_CHAR (
					ROUND (
					   NVL (
						pay_balance_pkg.get_value (
						   pay_ie_p35.get_defined_balance_id (
							l_dimension_name,  --'_PER_PAYE_REF_YTD',--6633719
							'IE Net Tax'
						   ),
						   csr_interlocks.locked_action_id,
						   l_segment4, -- paye reference value
						    null,
						    l_Act_Context_id,  --null,
						    l_Act_Context_value,  --null,
						    null,
						    null,
						    null,
						    'TRUE'
						),
						0
					   ),
					   2
					)
				   );
			hr_utility.set_location('l_arch_net_tax..'||l_arch_net_tax,1006);
			   l_arch_employees_prsi_cont :=
				   TO_CHAR (
					ROUND (
					     NVL (
						  pay_balance_pkg.get_value (
						     pay_ie_p35.get_defined_balance_id (
							  l_dimension_name,  --'_PER_PAYE_REF_YTD',--6633719
							  'IE PRSI Employee'
						     ),
						     csr_interlocks.locked_action_id,
						  l_segment4, -- paye reference value
						    null,
						    l_Act_Context_id,  --null,
						    l_Act_Context_value,  --null,
						    null,
						    null,
						    null,
						    'TRUE'
						  ),
						  0
					     )
					   + NVL (
						  pay_balance_pkg.get_value (
						     pay_ie_p35.get_defined_balance_id (
							  l_dimension_name, --'_PER_PAYE_REF_YTD',--6633719
							  'IE PRSI K Employee Lump Sum'
						     ),
						     csr_interlocks.locked_action_id,
						   l_segment4, -- paye reference value
						    null,
						    l_Act_Context_id,  --null,
						    l_Act_Context_value, --null,
						    null,
						    null,
						    null,
						    'TRUE'
						  ),
						  0
					     )
					   + NVL (
						  pay_balance_pkg.get_value (
						     pay_ie_p35.get_defined_balance_id (
							  l_dimension_name,  --'_PER_PAYE_REF_YTD',--6633719
							  'IE PRSI M Employee Lump Sum'
						     ),
						     csr_interlocks.locked_action_id,
						  l_segment4, -- paye reference value
						    null,
						    l_Act_Context_id,  --null,
						    l_Act_Context_value, --null,
						    null,
						    null,
						    null,
						    'TRUE'
						  ),
						  0
					     ),
					   2
					)
				   );
			hr_utility.set_location('l_arch_employees_prsi_cont..'||l_arch_employees_prsi_cont,1006);
				l_arch_total_prsi_cont :=
				   TO_CHAR (
					ROUND (
					     NVL (
						  pay_balance_pkg.get_value (
						     pay_ie_p35.get_defined_balance_id (
							  l_dimension_name,  --'_PER_PAYE_REF_YTD',--6633719
							  'IE PRSI Employee'
						     ),
						     csr_interlocks.locked_action_id,
						  l_segment4, -- paye reference value
						    null,
						    l_Act_Context_id,  --null,
						    l_Act_Context_value, --null,
						    null,
						    null,
						    null,
						    'TRUE'
						  ),
						  0
					     )
					   + NVL (
						  pay_balance_pkg.get_value (
						     pay_ie_p35.get_defined_balance_id (
							  l_dimension_name,  --'_PER_PAYE_REF_YTD',--6633719
							  'IE PRSI Employer'
						     ),
						     csr_interlocks.locked_action_id,
						  l_segment4, -- paye reference value
						    null,
						    l_Act_Context_id,  --null,
						    l_Act_Context_value,  --null,
						    null,
						    null,
						    null,
						    'TRUE'
						  ),
						  0
					     )
					   + NVL (
						  pay_balance_pkg.get_value (
						     pay_ie_p35.get_defined_balance_id (
							  l_dimension_name,  --'_PER_PAYE_REF_YTD',--6633719
							  'IE PRSI K Employee Lump Sum'
						     ),
						     csr_interlocks.locked_action_id, --l_arch_assmt_action_id_bal,
						 l_segment4, -- paye reference value
						    null,
						    l_Act_Context_id,  --null,
						    l_Act_Context_value,  --null,
						    null,
						    null,
						    null,
						    'TRUE'
						  ),
						  0
					     )
					   + NVL (
						  pay_balance_pkg.get_value (
						     pay_ie_p35.get_defined_balance_id (
							  l_dimension_name,  --'_PER_PAYE_REF_YTD',--6633719
							  'IE PRSI M Employee Lump Sum'
						     ),
						     csr_interlocks.locked_action_id, --l_arch_assmt_action_id_bal,
						  l_segment4, -- paye reference value
						    null,
						    l_Act_Context_id,  --null,
						    l_Act_Context_value,  --null,
						    null,
						    null,
						    null,
						    'TRUE'
						  ),
						  0
					     )
					   + NVL (
						  pay_balance_pkg.get_value (
						     pay_ie_p35.get_defined_balance_id (
							  l_dimension_name,  --'_PER_PAYE_REF_YTD',--6633719
							  'IE PRSI K Employer Lump Sum'
						     ),
						     csr_interlocks.locked_action_id, --l_arch_assmt_action_id_bal,
						   l_segment4, -- paye reference value
						    null,
						    l_Act_Context_id,  --null,
						    l_Act_Context_value,  --null,
						    null,
						    null,
						    null,
						    'TRUE'
						  ),
						  0
					     )
					   + NVL (
						  pay_balance_pkg.get_value (
						     pay_ie_p35.get_defined_balance_id (
							  l_dimension_name,  --'_PER_PAYE_REF_YTD',--6633719
							  'IE PRSI M Employer Lump Sum'
						     ),
						     csr_interlocks.locked_action_id, --l_arch_assmt_action_id_bal,
						     l_segment4, -- paye reference value
						    null,
						    l_Act_Context_id, --null,
						    l_Act_Context_value, --null,
						    null,
						    null,
						    null,
						    'TRUE'
						  ),
						  0
					     ),
					   2
					)
				   );
			hr_utility.set_location('l_arch_total_prsi_cont..'||l_arch_total_prsi_cont,1006);
				l_arch_pay :=
				   TO_CHAR (
					ROUND (
					   NVL (
						pay_balance_pkg.get_value (
						   pay_ie_p35.get_defined_balance_id (
							l_dimension_name,  --'_PER_PAYE_REF_YTD',--6633719
							'IE Taxable Pay'
						   ),
						   csr_interlocks.locked_action_id, --l_arch_assmt_action_id_bal,
						   l_segment4, -- paye reference value
						    null,
						    l_Act_Context_id,  --null,
						    l_Act_Context_value,  --null,
						    null,
						    null,
						    null,
						    'TRUE'
						),
						0
					   ),
					   2
					)
				   );
			hr_utility.set_location('l_arch_pay..'||l_arch_pay,1006);
				l_arch_total_notional_pay :=
				   TO_CHAR (
					ROUND (
					   NVL (
						pay_balance_pkg.get_value (
						   pay_ie_p35.get_defined_balance_id (
							l_dimension_name,  --'_PER_PAYE_REF_YTD',--6633719
							'IE BIK Taxable and PRSIable Pay'
						   ),
						   csr_interlocks.locked_action_id, --l_arch_assmt_action_id_bal,
						   l_segment4, -- paye reference value
						    null,
						    l_Act_Context_id,  --null,
						    l_Act_Context_value,  --null,
						    null,
						    null,
						    null,
						    'TRUE'
						),
						0
					   ),
					   2
					)
				   );
			hr_utility.set_location('l_arch_total_notional_pay..'||l_arch_total_notional_pay,1006);
			/* Start Pension Balances */
				l_arch_pen_emp_rbs :=
				   TO_CHAR (
					ROUND (
					   NVL (
						pay_balance_pkg.get_value (
						   pay_ie_p35.get_defined_balance_id (
							l_dimension_name,  --'_PER_PAYE_REF_YTD',--6633719
							'IE RBS EE Contribution'
						   ),
						   csr_interlocks.locked_action_id, --l_arch_assmt_action_id_bal,
						   l_segment4, -- paye reference value
						    null,
						    l_Act_Context_id,  --null,
						    l_Act_Context_value,  --null,
						    null,
						    null,
						    null,
						    'TRUE'
						),
						0
					   ),
					   2
					)
					+
					ROUND (
					   NVL (
						pay_balance_pkg.get_value (
						   pay_ie_p35.get_defined_balance_id (
							l_dimension_name,  --'_PER_PAYE_REF_YTD',--6633719
							'IE RBS EE AVC Contribution'
						   ),
						   csr_interlocks.locked_action_id, --l_arch_assmt_action_id_bal,
						   l_segment4, -- paye reference value
						    null,
						    l_Act_Context_id,  --null,
						    l_Act_Context_value,  --null,
						    null,
						    null,
						    null,
						    'TRUE'
						),
						0
					   ),
					   2
					)
				   );
			hr_utility.set_location('l_arch_pen_emp_rbs..'||l_arch_pen_emp_rbs,1006);
			  l_arch_pen_empr_rbs :=
			   TO_CHAR (
				ROUND (
				   NVL (
					pay_balance_pkg.get_value (
					   pay_ie_p35.get_defined_balance_id (
						l_dimension_name,  --'_PER_PAYE_REF_YTD',--6633719
						'IE RBS ER Contribution'
					   ),
					   csr_interlocks.locked_action_id, --l_arch_assmt_action_id_bal,
					   l_segment4, -- paye reference value
					    null,
					    l_Act_Context_id,  --null,
					    l_Act_Context_value,  --null,
					    null,
					    null,
					    null,
					    'TRUE'
					),
					0
				   ),
				   2
				)
			     );
			hr_utility.set_location('l_arch_pen_empr_rbs..'||l_arch_pen_empr_rbs,1006);
			l_arch_pen_emp_prsa :=
				   TO_CHAR (
					ROUND (
					   NVL (
						pay_balance_pkg.get_value (
						   pay_ie_p35.get_defined_balance_id (
							l_dimension_name,  --'_PER_PAYE_REF_YTD',--6633719
							'IE PRSA EE Contribution'
						   ),
						   csr_interlocks.locked_action_id, --l_arch_assmt_action_id_bal,
						  l_segment4, -- paye reference value
						    null,
						    l_Act_Context_id,  --null,
						    l_Act_Context_value,  --null,
						    null,
						    null,
						    null,
						    'TRUE'
						),
						0
					   ),
					   2
					)
					+
					ROUND (
					   NVL (
						pay_balance_pkg.get_value (
						   pay_ie_p35.get_defined_balance_id (
							l_dimension_name,  --'_PER_PAYE_REF_YTD',--6633719
							'IE PRSA EE AVC Contribution'
						   ),
						   csr_interlocks.locked_action_id, --l_arch_assmt_action_id_bal,
						  l_segment4, -- paye reference value
						    null,
						    l_Act_Context_id, --null,
						    l_Act_Context_value,  --null,
						    null,
						    null,
						    null,
						    'TRUE'
						),
						0
					   ),
					   2
					)
				   );
			hr_utility.set_location('l_arch_pen_emp_prsa..'||l_arch_pen_emp_prsa,1006);
			  l_arch_pen_empr_prsa :=
			   TO_CHAR (
				ROUND (
				   NVL (
					pay_balance_pkg.get_value (
					   pay_ie_p35.get_defined_balance_id (
						l_dimension_name,  --'_PER_PAYE_REF_YTD',--6633719
						'IE PRSA ER Contribution'
					   ),
					   csr_interlocks.locked_action_id, --l_arch_assmt_action_id_bal,
					  l_segment4, -- paye reference value
					    null,
					    l_Act_Context_id, --null,
					    l_Act_Context_value, --null,
					    null,
					    null,
					    null,
					    'TRUE'
					),
					0
				   ),
				   2
				)
			     );
			hr_utility.set_location('l_arch_pen_empr_prsa..'||l_arch_pen_empr_prsa,1006);
			l_arch_pen_emp_rac :=
			   TO_CHAR (
				ROUND (
				   NVL (
					pay_balance_pkg.get_value (
					   pay_ie_p35.get_defined_balance_id (
						l_dimension_name,  --'_PER_PAYE_REF_YTD',--6633719
						'IE RAC EE Contribution'
					   ),
					   csr_interlocks.locked_action_id, --l_arch_assmt_action_id_bal,
					   l_segment4, -- paye reference value
					    null,
					    l_Act_Context_id, --null,
					    l_Act_Context_value, --null,
					    null,
					    null,
					    null,
					    'TRUE'
					),
					0
				   ),
				   2
				)
			     );
			hr_utility.set_location('l_arch_pen_emp_rac..'||l_arch_pen_emp_rac,1006);
			/* End Pension Balances */

			/* 8520684 */
                        /* gross pay balances */
                        l_arch_gross_pay :=
				   TO_CHAR (
					ROUND (
					   NVL (
						pay_balance_pkg.get_value (
						   pay_ie_p35.get_defined_balance_id (
							l_dimension_name,
							'IE Gross Income Adjustment'
						   ),
						   csr_interlocks.locked_action_id,
						   l_segment4, -- paye reference value
						    null,
						    null,
						    null,
						    null,
						    null,
						    null,
						    'TRUE'
						),
						0
					   ),
					   2
					)
				   )

			          +

				  TO_CHAR (
					ROUND (
					   NVL (
						pay_balance_pkg.get_value (
						   pay_ie_p35.get_defined_balance_id (
							l_dimension_name,
							'IE Gross Income'
						   ),
						   csr_interlocks.locked_action_id,
						   l_segment4, -- paye reference value
						    null,
						    null,
						    null,
						    null,
						    null,
						    null,
						    'TRUE'
						),
						0
					   ),
					   2
					)
				   )
				   +
				   TO_CHAR (
					ROUND (
					   NVL (
						pay_balance_pkg.get_value (
						   pay_ie_p35.get_defined_balance_id (
							l_dimension_name,
							'IE BIK Taxable and PRSIable Pay'
						   ),
						   csr_interlocks.locked_action_id,
						   l_segment4, -- paye reference value
						    null,
						    null,
						    null,
						    null,
						    null,
						    null,
						    'TRUE'
						),
						0
					   ),
					   2
					)
				   );

                        /* 8520684 */
                        /* income levy balances */
                        l_arch_income_levy :=
				   TO_CHAR (
					ROUND (
					   NVL (
						pay_balance_pkg.get_value (
						   pay_ie_p35.get_defined_balance_id (
							l_dimension_name,
							'IE Income Tax Levy'
						   ),
						   csr_interlocks.locked_action_id,
						   l_segment4, -- paye reference value
						    null,
						    null,
						    null,
						    null,
						    null,
						    null,
						    'TRUE'
						),
						0
					   ),
					   2
					)
				   )
				  /* 8978805 */
				  /*
				   +
				   TO_CHAR (
					ROUND (
					   NVL (
						pay_balance_pkg.get_value (
						   pay_ie_p35.get_defined_balance_id (
							l_dimension_name,
							'IE Income Tax Levy Refund Amount'
						   ),
						   csr_interlocks.locked_action_id,
						   l_segment4, -- paye reference value
						    null,
						    null,
						    null,
						    null,
						    null,
						    null,
						    'TRUE'
						),
						0
					   ),
					   2
					)
				   ) */
				   ;
                        /* 8520684 */
                        /* income levy first band */
                        l_arch_income_levy_first :=
				   TO_CHAR (
					ROUND (
					   NVL (
						pay_balance_pkg.get_value (
						   pay_ie_p35.get_defined_balance_id (
							l_dimension_name,
							'IE Income Tax Levy First Band'
						   ),
						   csr_interlocks.locked_action_id,
						   l_segment4, -- paye reference value
						    null,
						    null,
						    null,
						    null,
						    null,
						    null,
						    'TRUE'
						),
						0
					   ),
					   2
					)
				   );
                        /* 8520684 */
                        /* income Levy second band balances */
                        l_arch_income_levy_second :=
				   TO_CHAR (
					ROUND (
					   NVL (
						pay_balance_pkg.get_value (
						   pay_ie_p35.get_defined_balance_id (
							l_dimension_name,
							'IE Income Tax Levy Second Band'
						   ),
						   csr_interlocks.locked_action_id,
						   l_segment4, -- paye reference value
						    null,
						    null,
						    null,
						    null,
						    null,
						    null,
						    'TRUE'
						),
						0
					   ),
					   2
					)
				   );
                        /* 8520684 */
                        /* income levy third band balances */
                        l_arch_income_levy_third :=
				   TO_CHAR (
					ROUND (
					   NVL (
						pay_balance_pkg.get_value (
						   pay_ie_p35.get_defined_balance_id (
							l_dimension_name,
							'IE Income Tax Levy Third Band'
						   ),
						   csr_interlocks.locked_action_id,
						   l_segment4, -- paye reference value
						    null,
						    null,
						    null,
						    null,
						    null,
						    null,
						    'TRUE'
						),
						0
					   ),
					   2
					)
				   );
                           /* 8520684 */
			   /* Parking Levy balances */
		           l_arch_parking_levy :=
				   TO_CHAR (
					ROUND (
					   NVL (
						pay_balance_pkg.get_value (
						   pay_ie_p35.get_defined_balance_id (
							l_dimension_name,
							'IE Parking Levy'
						   ),
						   csr_interlocks.locked_action_id,
						   l_segment4, -- paye reference value
						    null,
						    null,
						    null,
						    null,
						    null,
						    null,
						    'TRUE'
						),
						0
					   ),
					   2
					)
				   );
			-- BIK Medical insurance 5867343
			l_medical_insurance :=
				   TO_CHAR (
					ROUND (
					   NVL (
						pay_balance_pkg.get_value (
						   pay_ie_p35.get_defined_balance_id (
							l_dimension_name,  --'_PER_PAYE_REF_YTD',--6633719
							'IE BIK Medical Insurance'
						   ),
						   csr_interlocks.locked_action_id, --l_arch_assmt_action_id_bal,
						   l_segment4, -- paye reference value
						    null,
						    l_Act_Context_id,  --null,
						    l_Act_Context_value, --null,
						    null,
						    null,
						    null,
						    'TRUE'
						),
						0
					   ),
					   2
					)
				     );
			hr_utility.set_location('l_medical_insurance..'||l_medical_insurance,1006);
		     /*Bug No. 4063502*/
		    --
		     IF nvl(l_arch_pay,0) = 0 THEN
			    l_arch_non_tax_pay :=
					 TO_CHAR (
					    ROUND (
						 NVL (
						    pay_balance_pkg.get_value (
							 pay_ie_p35.get_defined_balance_id (
							    l_dimension_name,  --'_PER_PAYE_REF_YTD',--6633719
							    'Total Pay'
							 ),
							 csr_interlocks.locked_action_id, --l_arch_assmt_action_id_bal,
							 l_segment4, -- paye reference value
							    null,
							    l_Act_Context_id, --null,
							    l_Act_Context_value,  --null,
							    null,
							    null,
							    null,
							    'TRUE'
						    ),
						    0
						 ),
						 2
					    )
					 );
			hr_utility.set_location('l_arch_non_tax_pay..'||l_arch_non_tax_pay,1006);
			 END IF;
			/* lock this v_action_id*/
			--
			ELSE --v_action_type in ('R','Q','I','B','V') THEN
				hr_utility.set_location('Inside R,Q ..'||to_char(l_actid),1007);
				-- get data from run-reults
				hr_utility.set_location('csr_interlocks.locked_action_id..'||csr_interlocks.locked_action_id,1007);

				OPEN csr_run_results_found (csr_interlocks.locked_action_id,
                                            l_dimension_name,
                                            l_Act_Context_id,
                                            l_Act_Context_value);
				FETCH csr_run_results_found INTO l_arch_ppsn,
										l_arch_works_number,
										l_arch_person_id,
										l_arch_primary_flag,
										l_arch_assignment_id,
										l_arch_assmt_action_id_bal,
										l_arch_tax_or_refund,
									--      l_arch_tax_deduction_basis,
										l_arch_surname,
										l_arch_first_name,
										l_arch_dob,
										l_arch_address_line1,
										l_arch_address_line2,
										l_arch_address_line3,
										l_arch_address_line4,
										l_arch_hire_date,
										l_arch_term_date,
										l_period_type,
									--      l_arch_annual_tax_credit,
										l_arch_mothers_name,
										l_arch_pr_indicator,
										l_arch_previous_emp_pay,
										l_arch_previous_emp_tax;
				CLOSE csr_run_results_found;

           hr_utility.set_location('After csr_run_results_found..',5001);
		   hr_utility.set_location('l_arch_works_number..'||l_arch_works_number,5001);
		   hr_utility.set_location('l_arch_ppsn..'||l_arch_ppsn,5001);
		   hr_utility.set_location('l_arch_primary_flag..'||l_arch_primary_flag,5001);
		   hr_utility.set_location('l_arch_assignment_id..'||l_arch_assignment_id,5001);

           hr_utility.set_location('l_arch_previous_emp_pay..'||l_arch_previous_emp_pay,5001);
                  /* if data is found in the payroll run results cursor, then calculate the remaining values required for archiving */
				   -- Added K and M Employee and Employer figures for severance payment to variables l_arch_employees_prsi_cont and l_arch_total_prsi_cont
				   hr_utility.set_location ('B4 Arch Net Tax getval'|| l_arch_assmt_action_id_bal,996);
				   l_arch_net_tax :=
					   TO_CHAR (
						ROUND (
						   NVL (
							pay_balance_pkg.get_value (
							   pay_ie_p35.get_defined_balance_id (
								l_dimension_name,  --'_PER_PAYE_REF_YTD',--6633719
								'IE Net Tax'
							   ),
							   l_arch_assmt_action_id_bal,
							   l_segment4, -- paye reference value
							    null,
							    l_Act_Context_id,  --null,
							    l_Act_Context_value, --null,
							    null,
							    null,
							    null,
							    'TRUE'
							),
							0
						   ),
						   2
						)
					   );
                    hr_utility.set_location ('l_arch_net_tax'|| l_arch_net_tax,997);
				   l_arch_employees_prsi_cont :=
					   TO_CHAR (
						ROUND (
						     NVL (
							  pay_balance_pkg.get_value (
							     pay_ie_p35.get_defined_balance_id (
								  l_dimension_name,  --'_PER_PAYE_REF_YTD',--6633719
								  'IE PRSI Employee'
							     ),
							     l_arch_assmt_action_id_bal,
							    l_segment4, -- paye reference value
							    null,
							    l_Act_Context_id,  --null,
							    l_Act_Context_value,  --null,
							    null,
							    null,
							    null,
							    'TRUE'
							  ),
							  0
						     )
						   + NVL (
							  pay_balance_pkg.get_value (
							     pay_ie_p35.get_defined_balance_id (
								  l_dimension_name,  --'_PER_PAYE_REF_YTD',--6633719
								  'IE PRSI K Employee Lump Sum'
							     ),
							     l_arch_assmt_action_id_bal,
							     l_segment4, -- paye reference value
							    null,
							    l_Act_Context_id, --null,
							    l_Act_Context_value,  --null
							    null,
							    null,
							    null,
							    'TRUE'
							  ),
							  0
						     )
						   + NVL (
							  pay_balance_pkg.get_value (
							     pay_ie_p35.get_defined_balance_id (
								  '_PER_YTD',
								  'IE PRSI M Employee Lump Sum'
							     ),
							     l_arch_assmt_action_id_bal,
							     l_segment4, -- paye reference value
							    null,
							    null,
							    null,
							    null,
							    null,
							    null,
							    'TRUE'
							  ),
							  0
						     ),
						   2
						)
					   );
hr_utility.set_location ('l_arch_employees_prsi_cont'|| l_arch_employees_prsi_cont,997);

				   l_arch_total_prsi_cont :=
					   TO_CHAR (
						ROUND (
						     NVL (
							  pay_balance_pkg.get_value (
							     pay_ie_p35.get_defined_balance_id (
								  l_dimension_name,  --'_PER_PAYE_REF_YTD',--6633719
								  'IE PRSI Employee'
							     ),
							     l_arch_assmt_action_id_bal,
							     l_segment4, -- paye reference value
							    null,
							    l_Act_Context_id,  --null,
							    l_Act_Context_value,  --null,
							    null,
							    null,
							    null,
							    'TRUE'
							  ),
							  0
						     )
						   + NVL (
							  pay_balance_pkg.get_value (
							     pay_ie_p35.get_defined_balance_id (
								  l_dimension_name,  --'_PER_PAYE_REF_YTD',--6633719
								  'IE PRSI Employer'
							     ),
							     l_arch_assmt_action_id_bal,
							     l_segment4, -- paye reference value
							    null,
							    l_Act_Context_id,  --null,
							    l_Act_Context_value,  --null,
							    null,
							    null,
							    null,
							    'TRUE'
							  ),
							  0
						     )
						   + NVL (
							  pay_balance_pkg.get_value (
							     pay_ie_p35.get_defined_balance_id (
								  l_dimension_name,  --'_PER_PAYE_REF_YTD',--6633719
								  'IE PRSI K Employee Lump Sum'
							     ),
							     l_arch_assmt_action_id_bal,
							   l_segment4, -- paye reference value
							    null,
							    l_Act_Context_id,  --null,
							    l_Act_Context_value,  --null,
							    null,
							    null,
							    null,
							    'TRUE'
							  ),
							  0
						     )
						   + NVL (
							  pay_balance_pkg.get_value (
							     pay_ie_p35.get_defined_balance_id (
								  l_dimension_name,  --'_PER_PAYE_REF_YTD',--6633719
								  'IE PRSI M Employee Lump Sum'
							     ),
							     l_arch_assmt_action_id_bal,
							     l_segment4, -- paye reference value
							    null,
							    l_Act_Context_id,  --null,
							    l_Act_Context_value,  --null,
							    null,
							    null,
							    null,
							    'TRUE'
							  ),
							  0
						     )
						   + NVL (
							  pay_balance_pkg.get_value (
							     pay_ie_p35.get_defined_balance_id (
								  l_dimension_name,  --'_PER_PAYE_REF_YTD',--6633719
								  'IE PRSI K Employer Lump Sum'
							     ),
							     l_arch_assmt_action_id_bal,
							     l_segment4, -- paye reference value
							    null,
							    l_Act_Context_id,  --null,
							    l_Act_Context_value,  --null,
							    null,
							    null,
							    null,
							    'TRUE'
							  ),
							  0
						     )
						   + NVL (
							  pay_balance_pkg.get_value (
							     pay_ie_p35.get_defined_balance_id (
								  l_dimension_name,  --'_PER_PAYE_REF_YTD',--6633719
								  'IE PRSI M Employer Lump Sum'
							     ),
							     l_arch_assmt_action_id_bal,
							     l_segment4, -- paye reference value
							    null,
							    l_Act_Context_id,  --null,
							    l_Act_Context_value,  --null,
							    null,
							    null,
							    null,
							    'TRUE'
							  ),
							  0
						     ),
						   2
						)
					   );
hr_utility.set_location ('l_arch_total_prsi_cont'|| l_arch_total_prsi_cont,998);
				   l_arch_pay :=
					   TO_CHAR (
						ROUND (
						   NVL (
							pay_balance_pkg.get_value (
							   pay_ie_p35.get_defined_balance_id (
								l_dimension_name,  --'_PER_PAYE_REF_YTD',--6633719
								'IE Taxable Pay'
							   ),
							   l_arch_assmt_action_id_bal,
							   l_segment4, -- paye reference value
							    null,
							    l_Act_Context_id,  --null,
							    l_Act_Context_value,  --null,
							    null,
							    null,
							    null,
							    'TRUE'
							),
							0
						   ),
						   2
						)
					   );
				 hr_utility.set_location ('vik l_arch_assmt_action_id_bal '|| l_arch_assmt_action_id_bal,999);
				 hr_utility.set_location ('vik l_segment4 '|| l_segment4,999);
				 hr_utility.set_location ('vik l_arch_pay '|| l_arch_pay,999);

				 hr_utility.set_location ('l_arch_total_notional_pay'|| l_arch_assmt_action_id_bal,1990);
				 l_arch_total_notional_pay :=
					   TO_CHAR (
						ROUND (
						   NVL (
							pay_balance_pkg.get_value (
							   pay_ie_p35.get_defined_balance_id (
								l_dimension_name,  ---'_PER_PAYE_REF_YTD',--6633719
								'IE BIK Taxable and PRSIable Pay'
							   ),
							   l_arch_assmt_action_id_bal,
							   l_segment4, -- paye reference value
							    null,
							    l_Act_Context_id, --null,
							    l_Act_Context_value, --null,
							    null,
							    null,
							    null,
							    'TRUE'
							),
							0
						   ),
						   2
						)
					   );
				 hr_utility.set_location ('l_arch_total_notional_pay'|| l_arch_total_notional_pay,1990);
			/* Start Pension Balances */
				l_arch_pen_emp_rbs :=
				   TO_CHAR (
					ROUND (
					   NVL (
						pay_balance_pkg.get_value (
						   pay_ie_p35.get_defined_balance_id (
							l_dimension_name,  --'_PER_PAYE_REF_YTD',--6633719
							'IE RBS EE Contribution'
						   ),
						   csr_interlocks.locked_action_id, --l_arch_assmt_action_id_bal,
						   l_segment4, -- paye reference value
						    null,
						    l_Act_Context_id,  --null,
						    l_Act_Context_value,  --null,
						    null,
						    null,
						    null,
						    'TRUE'
						),
						0
					   ),
					   2
					)
					+
					ROUND (
					   NVL (
						pay_balance_pkg.get_value (
						   pay_ie_p35.get_defined_balance_id (
							l_dimension_name,  --'_PER_PAYE_REF_YTD',--6633719
							'IE RBS EE AVC Contribution'
						   ),
						   csr_interlocks.locked_action_id, --l_arch_assmt_action_id_bal,
						   l_segment4, -- paye reference value
						    null,
						    l_Act_Context_id,  --null,
						    l_Act_Context_value,  --null,
						    null,
						    null,
						    null,
						    'TRUE'
						),
						0
					   ),
					   2
					)
				   );
				 hr_utility.set_location ('l_arch_pen_emp_rbs'|| l_arch_pen_emp_rbs,1990);
				l_arch_pen_empr_rbs :=
				   TO_CHAR (
					ROUND (
					   NVL (
						pay_balance_pkg.get_value (
						   pay_ie_p35.get_defined_balance_id (
							l_dimension_name,  --'_PER_PAYE_REF_YTD',--6633719
							'IE RBS ER Contribution'
						   ),
						   csr_interlocks.locked_action_id, --l_arch_assmt_action_id_bal,
						   l_segment4, -- paye reference value
						    null,
						    l_Act_Context_id,  --null,
						    l_Act_Context_value,   --null,
						    null,
						    null,
						    null,
						    'TRUE'
						),
						0
					   ),
					   2
					)
				     );
				 hr_utility.set_location ('l_arch_pen_empr_rbs'|| l_arch_pen_empr_rbs,1990);
				l_arch_pen_emp_prsa :=
					   TO_CHAR (
						ROUND (
						   NVL (
							pay_balance_pkg.get_value (
							   pay_ie_p35.get_defined_balance_id (
								l_dimension_name,  --'_PER_PAYE_REF_YTD',--6633719
								'IE PRSA EE Contribution'
							   ),
							   csr_interlocks.locked_action_id, --l_arch_assmt_action_id_bal,
							   l_segment4, -- paye reference value
							    null,
							    l_Act_Context_id,  --null,
							    l_Act_Context_value,  --null,
							    null,
							    null,
							    null,
							    'TRUE'
							),
							0
						   ),
						   2
						)
						+
						ROUND (
						   NVL (
							pay_balance_pkg.get_value (
							   pay_ie_p35.get_defined_balance_id (
								l_dimension_name,  --'_PER_PAYE_REF_YTD',--6633719
								'IE PRSA EE AVC Contribution'
							   ),
							   csr_interlocks.locked_action_id, --l_arch_assmt_action_id_bal,
							  l_segment4, -- paye reference value
							    null,
							    l_Act_Context_id,  --null,
							    l_Act_Context_value,  --null,
							    null,
							    null,
							    null,
							    'TRUE'
							),
							0
						   ),
						   2
						)
					   );
				 hr_utility.set_location ('l_arch_pen_emp_prsa'|| l_arch_pen_emp_prsa,1990);
				l_arch_pen_empr_prsa :=
				   TO_CHAR (
					ROUND (
					   NVL (
						pay_balance_pkg.get_value (
						   pay_ie_p35.get_defined_balance_id (
							l_dimension_name,  --'_PER_PAYE_REF_YTD',--6633719
							'IE PRSA ER Contribution'
						   ),
						   csr_interlocks.locked_action_id, --l_arch_assmt_action_id_bal,
						   l_segment4, -- paye reference value
							    null,
							    l_Act_Context_id,  --null,
							    l_Act_Context_value,  --null,
							    null,
							    null,
							    null,
							    'TRUE'
						),
						0
					   ),
					   2
					)
				     );
				 hr_utility.set_location ('l_arch_pen_empr_prsa'|| l_arch_pen_empr_prsa,1990);
				l_arch_pen_emp_rac :=
				   TO_CHAR (
					ROUND (
					   NVL (
						pay_balance_pkg.get_value (
						   pay_ie_p35.get_defined_balance_id (
							l_dimension_name,  --'_PER_PAYE_REF_YTD',--6633719
							'IE RAC EE Contribution'
						   ),
						   csr_interlocks.locked_action_id, --l_arch_assmt_action_id_bal,
						  l_segment4, -- paye reference value
							    null,
							    l_Act_Context_id, --null,
							    l_Act_Context_value,  --null,
							    null,
							    null,
							    null,
							    'TRUE'
						),
						0
					   ),
					   2
					)
				     );
				 hr_utility.set_location ('l_arch_pen_emp_rac'|| l_arch_pen_emp_rac,1990);
			/* End Pension Balances */

			/* 8520684 */
                        /* gross pay balances */
                        l_arch_gross_pay :=
				   TO_CHAR (
					ROUND (
					   NVL (
						pay_balance_pkg.get_value (
						   pay_ie_p35.get_defined_balance_id (
							l_dimension_name,
							'IE Gross Income Adjustment'
						   ),
						   csr_interlocks.locked_action_id,
						   l_segment4, -- paye reference value
						    null,
						    null,
						    null,
						    null,
						    null,
						    null,
						    'TRUE'
						),
						0
					   ),
					   2
					)
				   )

			          +

				  TO_CHAR (
					ROUND (
					   NVL (
						pay_balance_pkg.get_value (
						   pay_ie_p35.get_defined_balance_id (
							l_dimension_name,
							'IE Gross Income'
						   ),
						   csr_interlocks.locked_action_id,
						   l_segment4, -- paye reference value
						    null,
						    null,
						    null,
						    null,
						    null,
						    null,
						    'TRUE'
						),
						0
					   ),
					   2
					)
				   )
				   +
				   TO_CHAR (
					ROUND (
					   NVL (
						pay_balance_pkg.get_value (
						   pay_ie_p35.get_defined_balance_id (
							l_dimension_name,
							'IE BIK Taxable and PRSIable Pay'
						   ),
						   csr_interlocks.locked_action_id,
						   l_segment4, -- paye reference value
						    null,
						    null,
						    null,
						    null,
						    null,
						    null,
						    'TRUE'
						),
						0
					   ),
					   2
					)
				   );

                        /* 8520684 */
                        /* income levy balances */
                        l_arch_income_levy :=
				   TO_CHAR (
					ROUND (
					   NVL (
						pay_balance_pkg.get_value (
						   pay_ie_p35.get_defined_balance_id (
							l_dimension_name,
							'IE Income Tax Levy'
						   ),
						   csr_interlocks.locked_action_id,
						   l_segment4, -- paye reference value
						    null,
						    null,
						    null,
						    null,
						    null,
						    null,
						    'TRUE'
						),
						0
					   ),
					   2
					)
				   )
				   /* 8978805 */
				   /*
				   +
				   TO_CHAR (
					ROUND (
					   NVL (
						pay_balance_pkg.get_value (
						   pay_ie_p35.get_defined_balance_id (
							l_dimension_name,
							'IE Income Tax Levy Refund Amount'
						   ),
						   csr_interlocks.locked_action_id,
						   l_segment4, -- paye reference value
						    null,
						    null,
						    null,
						    null,
						    null,
						    null,
						    'TRUE'
						),
						0
					   ),
					   2
					)
				   )*/
				   ;
                        /* 8520684 */
                        /* income levy first band */
                        l_arch_income_levy_first :=
				   TO_CHAR (
					ROUND (
					   NVL (
						pay_balance_pkg.get_value (
						   pay_ie_p35.get_defined_balance_id (
							l_dimension_name,
							'IE Income Tax Levy First Band'
						   ),
						   csr_interlocks.locked_action_id,
						   l_segment4, -- paye reference value
						    null,
						    null,
						    null,
						    null,
						    null,
						    null,
						    'TRUE'
						),
						0
					   ),
					   2
					)
				   );
                        /* 8520684 */
                        /* income Levy second band balances */
                        l_arch_income_levy_second :=
				   TO_CHAR (
					ROUND (
					   NVL (
						pay_balance_pkg.get_value (
						   pay_ie_p35.get_defined_balance_id (
							l_dimension_name,
							'IE Income Tax Levy Second Band'
						   ),
						   csr_interlocks.locked_action_id,
						   l_segment4, -- paye reference value
						    null,
						    null,
						    null,
						    null,
						    null,
						    null,
						    'TRUE'
						),
						0
					   ),
					   2
					)
				   );
                        /* 8520684 */
                        /* income levy third band balances */
                        l_arch_income_levy_third :=
				   TO_CHAR (
					ROUND (
					   NVL (
						pay_balance_pkg.get_value (
						   pay_ie_p35.get_defined_balance_id (
							l_dimension_name,
							'IE Income Tax Levy Third Band'
						   ),
						   csr_interlocks.locked_action_id,
						   l_segment4, -- paye reference value
						    null,
						    null,
						    null,
						    null,
						    null,
						    null,
						    'TRUE'
						),
						0
					   ),
					   2
					)
				   );
                           /* 8520684 */
			   /* Parking Levy balances */
		           l_arch_parking_levy :=
				   TO_CHAR (
					ROUND (
					   NVL (
						pay_balance_pkg.get_value (
						   pay_ie_p35.get_defined_balance_id (
							l_dimension_name,
							'IE Parking Levy'
						   ),
						   csr_interlocks.locked_action_id,
						   l_segment4, -- paye reference value
						    null,
						    null,
						    null,
						    null,
						    null,
						    null,
						    'TRUE'
						),
						0
					   ),
					   2
					)
				   );
			-- BIK Medical insurance
			l_medical_insurance :=
				   TO_CHAR (
					ROUND (
					   NVL (
						pay_balance_pkg.get_value (
						   pay_ie_p35.get_defined_balance_id (
							l_dimension_name,  --'_PER_PAYE_REF_YTD',--6633719
							'IE BIK Medical Insurance'
						   ),
						   csr_interlocks.locked_action_id, --l_arch_assmt_action_id_bal,
						   l_segment4, -- paye reference value
						    null,
						    l_Act_Context_id,  --null,
						    l_Act_Context_value,  --null,
						    null,
						    null,
						    null,
						    'TRUE'
						),
						0
					   ),
					   2
					)
				     );
				 hr_utility.set_location ('l_medical_insurance'|| l_medical_insurance,1990);
				/*Bug No. 4063502*/
				IF nvl(l_arch_pay,0) = 0 THEN
				   hr_utility.set_location ('l_arch_non_tax_pay'|| l_arch_assmt_action_id_bal,1991);
				    l_arch_non_tax_pay :=
						 TO_CHAR (
						    ROUND (
							 NVL (
							    pay_balance_pkg.get_value (
								 pay_ie_p35.get_defined_balance_id (
								    l_dimension_name,  --'_PER_PAYE_REF_YTD',--6633719
								    'Total Pay'
								 ),
								 l_arch_assmt_action_id_bal,
								 l_segment4, -- paye reference value
							    null,
							    l_Act_Context_id,  --null,
							    l_Act_Context_value,  --null,
							    null,
							    null,
							    null,
							    'TRUE'
							    ),
							    0
							 ),
							 2
						    )
						 );
				END IF;
				 hr_utility.set_location ('l_arch_non_tax_pay'|| l_arch_non_tax_pay,1990);
		     END IF;
		    --setting the assignment id to fetch PRSI values
                l_max_assignment_id := l_arch_assignment_id;
		    l_max_action_id	:= csr_interlocks.locked_action_id;
	     END IF;
	     cnt := cnt +1;

		hr_utility.set_location('before csr_get_primary_flag_active.'||v_action_id,1991);
		hr_utility.set_location('l_arch_previous_emp_pay.'||l_arch_previous_emp_pay,5001);

		OPEN csr_get_primary_flag_active(v_action_id);
		FETCH csr_get_primary_flag_active into v_work_number,v_primary_flag,asg_assignment_id,v_date;
		IF csr_get_primary_flag_active%NOTFOUND then
			hr_utility.set_location('Inside csr_get_primary_flag_active.'||v_action_id,1992);
			OPEN csr_get_primary_flag(v_action_id);
			FETCH csr_get_primary_flag into v_work_number,v_primary_flag,asg_assignment_id;
			CLOSE csr_get_primary_flag;
			hr_utility.set_location('Inside csr_get_primary_flag_active.'||v_action_id,1993);
		END IF;
		hr_utility.set_location('CLOSE csr_get_primary_flag_active.'||v_action_id,1994);
		CLOSE csr_get_primary_flag_active;

		hr_utility.set_location('v_primary_flag ..'||v_primary_flag,1008);
		hr_utility.set_location('l_arch_works_number ..'||l_arch_works_number,1008);
		hr_utility.set_location('v_work_number ..'||v_work_number,1008);

		IF v_primary_flag = 'Y' then
		     IF l_ppsn_override IS NULL THEN  --6633719
			 l_arch_works_number := v_work_number;
			 END IF;
			l_arch_previous_emp_pay := NVL (
			 ROUND (
			    TO_NUMBER (
				 pay_balance_pkg.get_value (
				    pay_ie_p35.get_defined_balance_id (
					 '_ASG_YTD',
					 'IE P45 Pay'
				    ),
				    csr_interlocks.locked_action_id
				 )
			    ),
			    2
			 ),
			 0
		    );
hr_utility.set_location('l_arch_previous_emp_pay.'||l_arch_previous_emp_pay,5001);
		    l_arch_previous_emp_tax :=  NVL (
			 ROUND (
			    TO_NUMBER (
				 pay_balance_pkg.get_value (
				    pay_ie_p35.get_defined_balance_id (
					 '_ASG_YTD',
					 'IE P45 Tax Deducted'
				    ),
				    csr_interlocks.locked_action_id
				 )
			    ),
			    2
			 ),
			 0
		    );
hr_utility.set_location('l_arch_previous_emp_tax.'||l_arch_previous_emp_tax,5001);
			--EXIT;
			--setting the assignment id to fetch PRSI values
			--6633719
			IF asg_assignment_id <> l_max_assignment_id AND l_ppsn_override IS NULL THEN
				l_max_assignment_id := asg_assignment_id;
			END IF;
		END IF;
		 --
	      hr_utility.set_location('l_arch_previous_emp_pay.'||l_arch_previous_emp_pay,5002);
	      --
	      IF (	v_action_type not in ('P','U','X') or v_action_type is null) then
			v_action_id := csr_interlocks.locked_action_id;
			hr_utility.set_location('Inside if ..'||v_action_id,2001);
		ELSE
		/* create a child assignment action and lock the P30 or prepayment
		   action. The need for having child assignment action for
		   retry of pay_payroll action.
		 */
			hr_utility.set_location('Inside Else ..',2002);
			SELECT pay_assignment_actions_s.NEXTVAL
			INTO l_actid
			FROM DUAL;
			OPEN get_assignment_id;
			FETCH get_assignment_id into v_payroll_action_id,v_assignment_id,v_chunk;
			CLOSE get_assignment_id;
			hr_nonrun_asact.insact (l_actid,
							v_assignment_id,
							v_payroll_action_id,
							v_chunk,
							to_number(l_segment4),
							status       => 'C',
							source_act => p_assactid
							);
			hr_utility.set_location('Inside Else ..'||v_action_id,2003);
			hr_nonrun_asact.insint (l_actid,v_action_id);
		END IF;
	END LOOP;
	-- Calculate values common for the three
	--6633719
	/* picking the works number of primary assignment for PPSN OVERRIDE*/
	IF l_ppsn_override IS NOT NULL THEN

        hr_utility.set_location('before l_arch_works_number ..'||l_arch_works_number,1008);
        hr_utility.set_location('before l_ppsn_override ..'||l_ppsn_override,1008);

    	OPEN csr_get_primary_flag_active1(l_ppsn_override);
		FETCH csr_get_primary_flag_active1 into l_arch_works_number;
		hr_utility.set_location('Inside csr_get_primary_flag_active1.'||v_assignment_id,1992);
		IF csr_get_primary_flag_active1%NOTFOUND then
			OPEN csr_get_primary_flag1(l_ppsn_override);
			FETCH csr_get_primary_flag1 into l_arch_works_number;
			CLOSE csr_get_primary_flag1;
			hr_utility.set_location('Inside csr_get_primary_flag1.'||v_assignment_id,1993);
		END IF;
		hr_utility.set_location('CLOSE csr_get_primary_flag_active1.',1994);
		CLOSE csr_get_primary_flag_active1;
		hr_utility.set_location('after l_arch_works_number ..'||l_arch_works_number,1008);
	END IF;
	--6633719

	hr_utility.set_location ('Starting on other common values', 10);
	l_arch_totwks_insurble_emplmnt :=
	   TO_CHAR (
		NVL (
		   pay_ie_p35.get_total_insurable_weeks (l_arch_person_id
									,to_number(l_segment4)
									,l_max_action_id
									,l_Act_Context_id   --6633719
									,l_Act_Context_value  --6633719
									,l_dimension_name  --6633719
                                    ,l_ppsn_override),  --6633719
		   0
		)
	   );
hr_utility.set_location('l_arch_totwks_insurble_emplmnt.'||l_arch_totwks_insurble_emplmnt,5001);
--

	l_arch_initial_class :=
	     NVL (pay_ie_p35.get_initial_class (l_max_action_id,to_number(l_segment4),l_ppsn_override), ' '); --6633719
	   -- class A is displayed when PRSIable pay is zero.
	   -- Eliminate class A.
	   IF l_arch_pay = 0 or l_arch_initial_class = 'A' THEN
		l_arch_initial_class := NULL;
	   END if;
	/*Bug fix 4049920*/
	IF l_arch_term_date <> '31-12-4712' THEN
		hr_utility.set_location (   'Actual Termination date  -'
				    || l_arch_term_date, 15);
		OPEN csr_annual_tax_credit(l_max_assignment_id,TO_DATE(l_arch_term_date,'dd-mm-yyyy'));
		FETCH csr_annual_tax_credit INTO l_arch_tax_deduction_basis,l_arch_annual_tax_credit;
		CLOSE csr_annual_tax_credit;
	ELSE
		OPEN csr_paye_details(l_max_assignment_id,l_period_type);
		FETCH csr_paye_details INTO l_arch_tax_deduction_basis,l_arch_annual_tax_credit;
		CLOSE csr_paye_details;

	END IF;
	hr_utility.set_location ('Termination date  -'|| l_arch_term_date, 15);

	hr_utility.set_location('Before initial Class',101);
	hr_utility.set_location('initial Class..'||nvl(l_arch_initial_class,'A'),101);

-- diaplay classes only if the total pay has value.
	IF l_arch_pay <> 0  THEN
		--l_prsi_class_tab(1).prsi_class := l_arch_initial_class;
		--l_prsi_class_tab(1).prsi_class_bal := get_prsi_weeks(t_context_value(1),
		--									     to_number(l_segment4)); -- some dummy value
		hr_utility.set_location('vik t_context_value.COUNT..'||t_context_value.COUNT,100);
		FOR j in 1..t_context_value.COUNT
		LOOP
			l_prsi_class_tab(j).prsi_class := substr(t_context_value(j),4,2);
			l_prsi_class_tab(j).prsi_class_bal := get_prsi_weeks(t_context_value(j),
											     to_number(l_segment4));
		END LOOP;
	END IF;
hr_utility.set_location('l_arch_previous_emp_pay..'||l_arch_previous_emp_pay,5002.4);
hr_utility.set_location('initial Class..'||nvl(l_arch_initial_class,'B'),102);

--8259095
hr_utility.set_location('l_supp_wk_tab.COUNT:'||l_supp_wk_tab.COUNT,102);
IF l_supp_wk_tab.COUNT > 0 THEN  --9394859
          FOR j in 1..l_prsi_class_tab.COUNT LOOP
             IF l_supp_wk_tab.EXISTS(l_prsi_class_tab(j).prsi_class) THEN
hr_utility.set_location('l_supp_wk_tab() Value:'||l_supp_wk_tab(l_prsi_class_tab(j).prsi_class),102);
                 l_prsi_class_tab(j).prsi_class_bal := l_prsi_class_tab(j).prsi_class_bal + l_supp_wk_tab(l_prsi_class_tab(j).prsi_class);
             END IF;
          END LOOP;

          IF l_prsi_class_tab.COUNT > 0 Then
          FOR i IN 1..l_prsi_class_tab.COUNT LOOP
             If l_prsi_class_tab(i).prsi_class_bal = 0 Then
                l_prsi_class_tab.DELETE(i);
             End If;
          END LOOP;
          End If;

l_cnt := 0;
l_pl_cnt := l_prsi_class_tab.FIRST;
 LOOP
    EXIT WHEN l_pl_cnt IS NULL;
    l_cnt := l_cnt + 1;
    l_prsi_class_tab1(l_cnt) := l_prsi_class_tab(l_pl_cnt);
    l_pl_cnt := l_prsi_class_tab.NEXT (l_pl_cnt);
 END LOOP;

 l_prsi_class_tab := l_prsi_class_tab1;
END IF; --9394859

--8259095

/* if for eg second class and third class exists but weeks at second class is zero
   then third class will become the second class ie it is promoted */
hr_utility.set_location('Before initial Class',101);
hr_utility.set_location('initial Class..'||nvl(l_arch_initial_class,'Y'),101);
hr_utility.set_location('vik l_prsi_class_tab.COUNT..'||l_prsi_class_tab.COUNT,102);

--Collect all PRSI classes with non-zero PRSI weeks in a separate PL/SQL table
l_cnt :=0;
FOR i in 1..l_prsi_class_tab.COUNT
LOOP
	-- Bug 5864713, added check l_arch_total_prsi_cont > 0
	IF (l_prsi_class_tab(i).prsi_class_bal<>0  or l_arch_total_prsi_cont > 0) and l_prsi_class_tab(i).prsi_class <> 'A' then
		l_cnt := l_cnt + 1;
		l_prsi_class_bal(l_cnt).prsi_class := l_prsi_class_tab(i).prsi_class;
		l_prsi_class_bal(l_cnt).prsi_class_bal := l_prsi_class_tab(i).prsi_class_bal;
		hr_utility.set_location('l_prsi_class_tab.COUNT'||l_prsi_class_tab.COUNT,101);
		hr_utility.set_location('l_prsi_class_bal'||l_cnt||l_prsi_class_tab(i).prsi_class,101);
		hr_utility.set_location('l_prsi_class_bal'||l_cnt||l_prsi_class_tab(i).prsi_class_bal,102);
	END IF;
END LOOP;

hr_utility.set_location('l_arch_previous_emp_pay..'||l_arch_previous_emp_pay,5002.5);

-- get the initial ,first , second, third, fourth and fifth from the non zero
-- plsql table.Sine the req is to display only non zero clases
IF l_cnt >=1 then
	if l_prsi_class_bal(1).prsi_class is not null then
		l_arch_initial_class	     := l_prsi_class_bal(1).prsi_class;
		l_arch_weeks_at_initial_class := l_prsi_class_bal(1).prsi_class_bal;
	end if;
END IF;


IF l_cnt >1 then
	if l_prsi_class_bal(2).prsi_class is not null then
		l_arch_second_class	     := l_prsi_class_bal(2).prsi_class;
		l_arch_weeks_at_second_class := l_prsi_class_bal(2).prsi_class_bal;
	end if;
END IF;
hr_utility.set_location('Hi',104);
IF l_cnt >2 then
	if l_prsi_class_bal(3).prsi_class is not null then
		l_arch_third_class	     := l_prsi_class_bal(3).prsi_class;
		l_arch_weeks_at_third_class  := l_prsi_class_bal(3).prsi_class_bal;
	end if;
END IF;

IF l_cnt >3 then
	if l_prsi_class_bal(4).prsi_class is not null then
		l_arch_fourth_class	     := l_prsi_class_bal(4).prsi_class;
		l_arch_weeks_at_fourth_class := l_prsi_class_bal(4).prsi_class_bal;
	end if;
END IF;
IF l_cnt >4 then
	if l_prsi_class_bal(5).prsi_class is not null then
		l_arch_fifth_class:= l_prsi_class_bal(5).prsi_class||'-'||l_prsi_class_bal(5).prsi_class_bal;
		l_arch_initial_class := l_arch_initial_class||'-'||l_arch_weeks_at_initial_class;
	end if;
END IF;

	 l_arch_weeks_at_initial_class       := NVL(l_arch_weeks_at_second_class,0);
	 l_arch_weeks_at_second_class       := NVL(l_arch_weeks_at_second_class,0);
	 l_arch_weeks_at_third_class		:= NVL(l_arch_weeks_at_third_class,0);
	 l_arch_weeks_at_fourth_class		:= NVL(l_arch_weeks_at_fourth_class,0);
	 l_arch_weeks_at_fifth_class		:= NVL(l_arch_weeks_at_fifth_class,0);
	 l_arch_initial_class			:= NVL(l_arch_initial_class,' ');
	 l_arch_second_class			:= NVL(l_arch_second_class,' ');
	 l_arch_third_class			:= NVL(l_arch_third_class,' ');
	 l_arch_fourth_class			:= NVL(l_arch_fourth_class,' ');

	   /* Date will be locked now. */
	 hr_utility.set_location ('b4 INSINT Locking ID' ||L_ACTID,994);
	 hr_utility.set_location ('b4 INSACT Locked ID ' ||l_locked_action,995);


	hr_utility.set_location ('Asg ID  -'|| l_max_assignment_id,14);
	hr_utility.set_location (   'Asg Act ID  -'|| l_locked_action, 15);

	-- For BUG Fix 4066315
	-- Concatination of employee address line 2 with line 3 and remaining line 3 with line 4
	if (l_arch_address_line3 is not null) then
		l_length_address_line2 := LENGTH(l_arch_address_line2);
		l_available_space := 29 - l_length_address_line2; -- -1 for including the space
		if l_available_space < 0 then
			l_available_space := 0;
		end if;
		l_arch_address_line2:=l_arch_address_line2||' '||SUBSTR(l_arch_address_line3,1,l_available_space);
		l_arch_address_line3:=(SUBSTR(l_arch_address_line3,l_available_space+1,14))||' '||l_arch_address_line4;
	else
		l_arch_address_line3:=l_arch_address_line4;
	end if;

	/***** Open curosrs for previous employment balances ****/
	-- removed the condition l_arch_previous_emp_pay for 5435931.
	-- as case can come where person is rehired but not P45 is entered.
	-- so in this l_arch_previous_emp_pay will be zero. So to handle this
	-- case removed the check for l_arch_previous_emp_pay <> 0.
	--IF l_arch_previous_emp_pay <> 0 THEN
		OPEN c_get_periods_of_service(l_arch_person_id,l_max_assignment_id);
		FETCH c_get_periods_of_service into l_pds_id;
		CLOSE c_get_periods_of_service;
		hr_utility.set_location('Period of Service id..'||to_char(l_pds_id),3002);
		IF l_pds_id IS NOT NULL THEN
			/*OPEN c_get_terminated_asg(l_pds_id);
			FETCH c_get_terminated_asg into l_asg_id;
			CLOSE c_get_terminated_asg;

			IF l_asg_id IS NOT NULL THEN*/
				OPEN c_get_max_aact(l_pds_id,l_ppsn_override,l_arch_person_id);
				FETCH c_get_max_aact INTO l_aact_id;
				CLOSE c_get_max_aact;
				hr_utility.set_location('l_aact_id..'||to_char(l_aact_id),3003);
		END IF;
		hr_utility.set_location('l_arch_previous_emp_pay..'||l_arch_previous_emp_pay,5004);
		hr_utility.set_location('l_arch_pay..'||l_arch_pay,5004);
		hr_utility.set_location('l_aact_id..'||l_aact_id,5004);
		IF l_aact_id IS NOT NULL THEN
			-- for bug 5435931.
			l_this_pay := l_arch_pay - pay_balance_pkg.get_value (
							 pay_ie_p35.get_defined_balance_id (
							    l_dimension_name,  --'_PER_PAYE_REF_YTD',--6633719
							    'IE Taxable Pay'
							 ),
							 l_aact_id,
							 l_segment4, -- paye reference value
							 null,
							 l_Act_Context_id,  --null,
							 l_Act_Context_value,  --null,
							 null,
							 null,
							 null,
							 'TRUE'

							);
			hr_utility.set_location('l_this_pay..'||l_this_pay,5004);
			l_this_tax := l_arch_net_tax - pay_balance_pkg.get_value (
							 pay_ie_p35.get_defined_balance_id (
							    l_dimension_name,  --'_PER_PAYE_REF_YTD',--6633719
							    'IE Net Tax'
							 ),
							 l_aact_id,
							 l_segment4, -- paye reference value
							 null,
							 l_Act_Context_id,  --null,
							 l_Act_Context_value,  --null,
							 null,
							 null,
							 null,
							 'TRUE'

							);
			hr_utility.set_location('l_this_tax..'||l_this_tax,5004);
			/* 8978805 */
			l_arch_prev_gross_pay :=  pay_balance_pkg.get_value (
							 pay_ie_p35.get_defined_balance_id (
							    l_dimension_name,  --'_PER_PAYE_REF_YTD',--6633719
							    'IE Gross Income'
							 ),
							 l_aact_id,
							 l_segment4, -- paye reference value
							 null,
							 l_Act_Context_id,  --null,
							 l_Act_Context_value,  --null,
							 null,
							 null,
							 null,
							 'TRUE'

							);
                         hr_utility.set_location('prev gross pay..'|| l_arch_prev_gross_pay,5004);
                         l_arch_prev_gross_pay_adjust := pay_balance_pkg.get_value (
							 pay_ie_p35.get_defined_balance_id (
							    l_dimension_name,  --'_PER_PAYE_REF_YTD',--6633719
							    'IE Gross Income Adjustment'
							 ),
							 l_aact_id,
							 l_segment4, -- paye reference value
							 null,
							 l_Act_Context_id,  --null,
							 l_Act_Context_value,  --null,
							 null,
							 null,
							 null,
							 'TRUE'

							);
                       hr_utility.set_location('prev gross pay adjust..'|| l_arch_prev_gross_pay_adjust,5004);
                       l_arch_prev_gross_pay_BIK :=  pay_balance_pkg.get_value (
							 pay_ie_p35.get_defined_balance_id (
							    l_dimension_name,  --'_PER_PAYE_REF_YTD',--6633719
							    'IE BIK Taxable and PRSIable Pay'
							 ),
							 l_aact_id,
							 l_segment4, -- paye reference value
							 null,
							 l_Act_Context_id,  --null,
							 l_Act_Context_value,  --null,
							 null,
							 null,
							 null,
							 'TRUE'

							);
                         hr_utility.set_location('prev BIK..'|| l_arch_prev_gross_pay_BIK,5004);
                         l_arch_prev_gross_pay:=NVL(l_arch_prev_gross_pay,0) + NVL(l_arch_prev_gross_pay_adjust,0) + NVL(l_arch_prev_gross_pay_BIK,0);
			 hr_utility.set_location('l_arch_prev_gross_pay '|| l_arch_prev_gross_pay,5004);
			 l_arch_total_this_gross_pay:=l_arch_gross_pay - l_arch_prev_gross_pay;
                          hr_utility.set_location('actual this gross pay..'|| l_arch_total_this_gross_pay,5004);
			l_arch_this_income_levy :=l_arch_income_levy - pay_balance_pkg.get_value (
							 pay_ie_p35.get_defined_balance_id (
							    l_dimension_name,  --'_PER_PAYE_REF_YTD',--6633719
							    'IE Income Tax Levy'
							 ),
							 l_aact_id,
							 l_segment4, -- paye reference value
							 null,
							 l_Act_Context_id,  --null,
							 l_Act_Context_value,  --null,
							 null,
							 null,
							 null,
							 'TRUE'

							);
                         hr_utility.set_location('l_arch_this_income_levy '|| l_arch_this_income_levy,5004);
			-- For P60 changes, PRSI this employment Section C.
			get_p60_prsi_details(p_assignment_action_id => l_aact_id,
		     				 p_max_action_id		=> l_max_action_id,
						 p_person_id		=> l_arch_person_id,
						 p_segment4			=> l_segment4,
						 p_tot_insurable_weeks  => to_number(l_arch_totwks_insurble_emplmnt),
						 p_prsi_employee_cont   => to_number(l_arch_employees_prsi_cont),
						 p_prsi_tot_cont		=> to_number(l_arch_total_prsi_cont),
						 p_insurable_weeks	=> l_this_insurable_weeks,
						 p_this_emp_prsi_cont   => l_this_emp_prsi_cont,
						 p_this_tot_prsi		=> l_this_tot_prsi,
						 p_this_initial_class	=> l_this_initial_class,
						 p_this_sec_class		=> l_this_sec_class,
						 p_this_weeks_at_sec_class => l_this_weeks_at_sec_class,
						 p_Act_Context_id		=> l_Act_Context_id,    --6633719
						 p_Act_Context_value	=> l_Act_Context_value,  --6633719
						 p_dimension_name		=> l_dimension_name,  --6633719
						 p_ppsn_override   => l_ppsn_override  --6633719
                         );

			hr_utility.set_location('After get_p60_prsi_details call',5004);

		ELSE
		     -- this case will come say employee joins on 2-jan-2006.
		     -- Enter P45 details. So in this case pervious emp pay is <> 0
		     -- but does not have previous period of service. So in this case
		     -- thispay should be total taxable pay _PER_PAYE_REF_YTD
			l_this_pay := l_arch_pay;
			l_this_tax := l_arch_net_tax;
			l_this_insurable_weeks := l_arch_totwks_insurble_emplmnt;
			l_this_emp_prsi_cont := l_arch_employees_prsi_cont;
			l_this_tot_prsi := l_arch_total_prsi_cont ;
			l_this_initial_class := l_arch_initial_class;
			l_this_sec_class := l_arch_second_class;
			l_this_weeks_at_sec_class := l_arch_weeks_at_second_class;

			/* 8978805 */
			l_arch_total_this_gross_pay:=l_arch_gross_pay;
                        l_arch_this_income_levy :=l_arch_income_levy;
		END IF; --l_aactid is not null

	/*ELSE
		-- this case will if there is no previous employment. So in this
		-- thispay should be total taxable pay _PER_PAYE_REF_YTD
		l_this_pay := l_arch_pay;
		l_this_tax := l_arch_net_tax;
	-- end bug 5435931
	END IF;*/-- l_arch_previous_emp_pay <> 0
	hr_utility.set_location('l_arch_previous_emp_pay..'||l_arch_previous_emp_pay,5004);
	hr_utility.set_location('Before Update',1009);
	/* update assignment actions */

	IF v_assignment_id <> l_max_assignment_id THEN
		UPDATE pay_assignment_actions SET assignment_id = l_max_assignment_id
		WHERE  assignment_action_id = p_assactid
		AND    payroll_action_id= v_payroll_action_id;

		UPDATE pay_assignment_actions SET assignment_id = l_max_assignment_id
		WHERE  source_action_id = p_assactid
		AND    payroll_action_id = v_payroll_action_id;
	END IF;

	hr_utility.set_location('After Update',1009);

	  -- print the hiredate only it falls in the current tax year.
        IF to_char(to_date(l_arch_hire_date,'DD-MM-YYYY'),'YYYY') <> to_char(l_start_date,'YYYY') THEN
              l_arch_hire_date := null;
        END IF;

	  -- if have - in initial class bug 5864661
        IF instr(l_this_initial_class,'-',1) > 0 THEN
		l_this_initial_class := substr(l_this_initial_class,1,instr(l_this_initial_class,'-',1)-1);
	  END IF;

hr_utility.set_location('Before create_action_information IE P35 DETAIL',1009);

	IF l_arch_pay >= 1 OR l_arch_income_levy > 0  --OR l_arch_non_tax_pay > 0 --6620003  --8874161  --8987577
	THEN

        hr_utility.set_location('l_arch_works_number..'||l_arch_works_number,1009);
		hr_utility.set_location('l_ppsn_override..'||l_ppsn_override,1009);
		hr_utility.set_location('l_arch_ppsn..'||l_arch_ppsn,1009);
		hr_utility.set_location('l_max_assignment_id..'||l_max_assignment_id,1009);

hr_utility.set_location('Outside l_arch_initial_class:'||l_arch_initial_class,1009);
--9080372
        IF NVL(l_arch_total_prsi_cont,0) = 0 THEN
          l_arch_initial_class := NVL(TRIM(l_arch_initial_class),'M');
hr_utility.set_location('Inside l_arch_initial_class:'||l_arch_initial_class,1009);
        END IF;
--9080372

	         pay_action_information_api.create_action_information (
	            p_action_context_id=> p_assactid,
	            p_action_context_type=> 'AAP',
	            p_action_information_category=> 'IE P35 DETAIL',
	            p_assignment_id	   => l_max_assignment_id,
	            p_action_information1=> NVL(l_ppsn_override,l_arch_ppsn),  --6633719
	            p_action_information2=> l_arch_works_number,
	            p_action_information3=> l_arch_totwks_insurble_emplmnt,
	            p_action_information4=> l_arch_initial_class,
	            p_action_information5=> l_arch_second_class,
	            p_action_information6=> l_arch_weeks_at_second_class,
	            p_action_information7=> l_arch_third_class,
	            p_action_information8=> l_arch_weeks_at_third_class,
	            p_action_information9=> l_arch_fourth_class,
	            p_action_information10=> l_arch_weeks_at_fourth_class,
	            p_action_information11=> l_arch_fifth_class,
	            p_action_information12=> l_arch_net_tax,
	            p_action_information13=> l_arch_tax_or_refund,
	            p_action_information14=> l_arch_employees_prsi_cont,
	            p_action_information15=> l_arch_total_prsi_cont,
	            p_action_information16=> l_arch_pay,
	            p_action_information17=> l_arch_tax_deduction_basis,
	            p_action_information18=> l_arch_surname,
	            p_action_information19=> l_arch_first_name,
	            p_action_information20=> l_arch_dob,
	            p_action_information21=> substr(l_arch_address_line1,1,30), -- bug 5869390
	            p_action_information22=> substr(l_arch_address_line2,1,30), -- bug 5869390
	            p_action_information23=> substr(l_arch_address_line3,1,30), -- bug 5869390
	            p_action_information24=> l_arch_hire_date,
	            p_action_information25=> l_arch_term_date,
	            p_action_information26=> l_arch_annual_tax_credit,
	            p_action_information27=> l_arch_mothers_name,
			-- for bug 5435931
	            p_action_information28=> l_arch_previous_emp_pay||'|'||l_this_pay,
	            p_action_information29=> l_arch_previous_emp_tax||'|'||l_this_tax,
			-- end for bug 5435931
	            p_action_information30=> l_arch_pr_indicator,
	            p_action_information_id=> l_arch_action_info_id,
	            p_object_version_number=> l_arch_ovn);

        hr_utility.set_location('Before create_action_information IE P35 ADDITIONAL DETAILS',1009);

	         pay_action_information_api.create_action_information (
	            p_action_context_id=> p_assactid,
	            p_action_context_type=> 'AAP',
	            p_action_information_category=> 'IE P35 ADDITIONAL DETAILS',
	            p_assignment_id=> l_max_assignment_id,
	            p_action_information1=> l_arch_total_notional_pay,
	            p_action_information2=> l_arch_pen_emp_rbs,
			p_action_information3=> l_arch_pen_empr_rbs,
			p_action_information4=> l_arch_pen_emp_prsa,
			p_action_information5=> l_arch_pen_empr_prsa,
			p_action_information6=> l_arch_pen_emp_rac,
			p_action_information11=> l_this_emp_prsi_cont,
			p_action_information12=> l_this_tot_prsi,
			p_action_information13=> l_this_insurable_weeks,
			p_action_information14=> l_this_initial_class,
			p_action_information15=> l_this_sec_class,
			p_action_information16=> l_this_weeks_at_sec_class,
			p_action_information17=> to_char(floor(to_number(l_medical_insurance))), -- 5867343,6502227
			p_action_information18=> l_arch_gross_pay,             -- gross pay  /* 8520684 */
			p_action_information19=> l_arch_income_levy,           -- income levy
			p_action_information20=> l_arch_income_levy_first,     -- income levy first band
			p_action_information21=> l_arch_income_levy_second,    -- income levy second band
			p_action_information22=> l_arch_income_levy_third,     -- income levy third band
			p_action_information23=> l_arch_parking_levy,           -- parking levy
			p_action_information24=> l_arch_total_this_gross_pay,    -- This employement gross pay
			p_action_information25=> l_arch_this_income_levy,        -- this employmement incoem elvy
	            p_action_information_id=> l_arch_action_info_id,
	            p_object_version_number=> l_oth_arch_ovn
	         );
hr_utility.set_location('After create_action_information IE P35 ADDITIONAL DETAILS',1009);

		END IF;
-- Empty the pl/sql tables
l_prsi_class_bal := l_prsi_class_temp;
l_prsi_class_tab := l_prsi_class_temp;
l_prsi_class_tab1:= l_prsi_class_temp;  --9080372
END archive_code;

Procedure deinit_code (p_payroll_action_id IN NUMBER) is

l_proc			CONSTANT VARCHAR2(50):= l_package||'deinit_code';
l_archived		      NUMBER(1);
l_out_var               VARCHAR2 (30);
l_ovn                   NUMBER;
l_action_info_id        NUMBER;
l_employer_number       VARCHAR2 (240);
l_employer_address1     VARCHAR2 (240);
l_employer_address2     VARCHAR2 (240);
l_employer_address3     VARCHAR2 (240);
l_employer_name         VARCHAR2 (240);
l_contact_name          VARCHAR2 (240);
l_contact_number        VARCHAR2 (240);
/*Added for bug fix 3815830*/
l_trade_name            VARCHAR2 (240);
l_fax_number            VARCHAR2 (240);
l_bg_id                    NUMBER;


CURSOR csr_check_payroll_action IS
  SELECT 1
  FROM   DUAL
  WHERE EXISTS (SELECT NULL
  		FROM pay_action_information pai
  		WHERE pai.action_context_id = p_payroll_action_id
  		AND   pai.action_context_type = 'PA'
  		AND   rownum = 1
  	       );

      /* Added the cursor for BUG 2987230 */
CURSOR csr_p35_header_info
IS
SELECT hoi2.org_information2, -- 'EMPLOYER_NUMBER
                --nvl(trim(rpad(hou.name,30)),' '), -- ('EMPLOYER_NAME=P'),
                --Added for bug fix 3567562,Modifed source of Employer Name
                NVL (TRIM (RPAD (hou.name, 30)), ' '), -- ('EMPLOYER_NAME=P'),
                NVL (TRIM (RPAD (hoi2.org_information3, 30)), ' '), -- ('TRADE_NAME=P'), /*Added for bug fix 3815830*/
                NVL (TRIM (RPAD (hl.ADDRESS_LINE_1, 30)), ' '), -- ('EMPLOYER_ADDRESS1=P'),
                NVL (TRIM (RPAD (hl.ADDRESS_LINE_2, 30)), ' '), -- ('EMPLOYER_ADDRESS2=P'),
                NVL (TRIM (RPAD (hl.ADDRESS_LINE_3, 30)), ' '), -- ('EMPLOYER_ADDRESS3=P'),
                NVL (TRIM (RPAD (hoi2.org_information4, 20)), ' '), -- ('CONTACT_NAME=P'),
                NVL (TRIM (RPAD (hl.TELEPHONE_NUMBER_1, 12)), ' ' ), -- ('CONTACT_NUMBER=P'),
	          NVL (TRIM (RPAD (hl.TELEPHONE_NUMBER_2, 12)), ' ') --('FAX_NO=P') /*Added for bug fix 3815830*/
           FROM hr_all_organization_units hou,
	          hr_locations hl,
		    pay_payroll_actions ppa,
		    hr_organization_information hoi1,
		    hr_organization_information hoi2
          WHERE ppa.payroll_action_id = p_payroll_action_id
            AND hou.business_group_id = ppa.business_group_id
            AND hou.organization_id = pay_ie_p35.get_parameter (ppa.payroll_action_id, 'EMP_NO')
		AND hl.location_id(+) = hou.location_id
		AND hou.organization_id=hoi1.organization_id
		AND hoi2.organization_id(+)= hoi1.organization_id
		AND hoi1.org_information_context='CLASS'
		AND hoi1.org_information1='HR_LEGAL_EMPLOYER'
		AND hoi1.org_information2='Y'
		AND hoi2.org_information_context (+) ='IE_EMPLOYER_INFO';
BEGIN

l_archived := 0;
OPEN csr_check_payroll_action;
FETCH csr_check_payroll_action into l_archived;
CLOSE csr_check_payroll_action;
IF l_archived = 0 THEN
	l_out_var := pay_ie_p35.get_parameter (
					p_payroll_action_id=> p_payroll_action_id,
					p_token_name=> 'END_DATE'
					);
      l_end_date := TO_DATE (l_out_var, 'YYYY/MM/DD');
      l_out_var := pay_ie_p35.get_parameter (
					p_payroll_action_id=> p_payroll_action_id,
			            p_token_name=> 'START_DATE'
					);
      l_start_date := TO_DATE (l_out_var, 'YYYY/MM/DD');
      l_out_var := pay_ie_p35.get_parameter (
					p_payroll_action_id=> p_payroll_action_id,
			            p_token_name=> 'BG_ID'
					);
      l_bg_id := TO_NUMBER (l_out_var);

	/* Added code for BUG 2987230 */
      -- Collect header deatils
      OPEN csr_p35_header_info;
      --Modified sequence of variables fetched for bug no 3567562
      FETCH csr_p35_header_info INTO l_employer_number,
                                     l_employer_name,
						 l_trade_name, /*Added for bug fix 3815830*/
                                     l_employer_address1,
                                     l_employer_address2,
                                     l_employer_address3,
                                     l_contact_name,
                                     l_contact_number,
						 l_fax_number; /*Added for bug fix 3815830*/
      CLOSE csr_p35_header_info;
      -- Archive header info
      pay_action_information_api.create_action_information (
         p_action_information_id=> l_action_info_id,
         p_action_context_id=> p_payroll_action_id,
         p_action_context_type=> 'PA',
         p_object_version_number=> l_ovn,
         p_action_information_category=> 'ADDRESS DETAILS',
         p_action_information1=> l_employer_number,
	   p_action_information9=> l_trade_name, /*Added for bug fix 3815830*/
         p_action_information5=> l_employer_address1,
         p_action_information6=> l_employer_address2,
         p_action_information7=> l_employer_address3,
         p_action_information26=> l_employer_name,
         p_action_information27=> l_contact_name,
         p_action_information28=> l_contact_number,
	 p_action_information10=> l_fax_number  /*Added for bug fix 3815830*/
      );
END IF;

END deinit_code;



   FUNCTION get_initial_class (p_max_action_id IN NUMBER,
					 l_segment4 IN NUMBER,
                     p_ppsn_override IN VARCHAR2)  --6633719
      RETURN VARCHAR2
   AS
      -- Bug 2979713 - PRSI Context Balance Design Change

      -- cursor to retrive the context_id - to be used in get_total_insurable_weeks function
      CURSOR c_context_id
      IS
         SELECT context_id
           FROM ff_contexts
          WHERE context_name = 'SOURCE_TEXT';

      -- get the latest assignment_action_id to calculate the balances for the calculating the
      -- total insurable weeks, weeks at first class etc.
      -- Bug 3381002 : Added the condition paa.action_status='C', removed ppa.action_status='C' and added
      -- the action type 'I'

      /*CURSOR c_assignment_action_id (
         p_person_id    NUMBER,
         p_start_date   DATE,
         p_end_date     DATE
      )
      IS
         SELECT   /*+ ORDERED USE_NL(paa, ppa, ptp)
                  fnd_number.canonical_to_number(substr(max(lpad(paa.action_sequence,15,'0')||
                  paa.assignment_action_id),16)) assignment_action_id  --bug fix 4004470
             FROM per_people_f ppf,
                  per_assignments_f paf,
                  pay_assignment_actions paa,
                  pay_payroll_actions ppa,
                  per_time_periods ptp
            WHERE
		   ppf.person_id = p_person_id
		  AND paf.assignment_id = p_assignment_id -- vik added code for getting values for given assignment
              AND ppf.current_employee_flag = 'Y'
              AND paf.person_id = ppf.person_id
              --AND paf.primary_flag = 'Y' -- removed join
              AND paf.assignment_type = 'E'
              AND paf.assignment_status_type_id =
	      --Added for bug fix 3828506
	                          (SELECT ast.assignment_status_type_id
	                           FROM   per_assignment_status_types ast
				   WHERE  ast.per_system_status = 'ACTIVE_ASSIGN'
				   AND    ast.assignment_status_type_id =  paf.assignment_status_type_id)
              AND paa.assignment_id = paf.assignment_id
              AND paa.action_status = 'C'
              AND ppa.payroll_action_id = paa.payroll_action_id
              AND ppa.action_type IN ('R', 'Q', 'I', 'B')
              AND ptp.time_period_id = ppa.time_period_id
              AND ptp.end_date BETWEEN p_start_date AND p_end_date
	      group by paa.assignment_id;*/
        /* ORDER BY paa.action_sequence DESC;*/



      -- cursor for retrieving the context values
      -- Bug 3460687 : Changed ppa.action_status to paa.action_status
       CURSOR c_context_name (
         p_person_id    NUMBER,
         p_start_date   DATE,
         p_end_date     DATE,
	   p_date         DATE  --8259095
      )
      IS
         SELECT   /*+ ordered */
                  asg.business_group_id business_group_id,
                  asg.person_id person_id, per.full_name full_name,
                  per.original_date_of_hire original_hire_date,
                  MIN (ptp.end_date) minimum_effective_date,
			asg.primary_flag,
			paa.assignment_action_id,
                  trim(rrv1.result_value) result_value
             FROM per_people_f per,
                  per_assignments_f asg,
                  pay_assignment_actions paa,
                  pay_payroll_actions ppa,
                  per_time_periods ptp,
                  pay_run_results prr,
                  pay_element_types_f pet,
                  pay_input_values_f piv1,
                  pay_run_result_values rrv1,
                  per_assignment_extra_info paei  --6633719
            WHERE per.person_id = p_person_id
            --6633719 these condition added to fetch the contexes having similar PPSN OVERRIDE if given
              AND paei.assignment_id(+) = asg.assignment_id
              AND paei.aei_information_category(+) = 'IE_ASG_OVERRIDE'
              AND nvl(paei.aei_information1,'X') =  nvl(p_ppsn_override,'X')
            --6633719
		  --AND asg.assignment_id = p_assignment_id -- vik added code for getting values for given assignment
              AND per.current_employee_flag = 'Y'
              AND per.effective_start_date =
                        (SELECT MIN (per2.effective_start_date)
                           FROM per_people_f per2
			    -- Bug Fix 4004384
			    , per_periods_of_service pos2
                            WHERE per2.person_id = per.person_id
                            AND per2.effective_start_date <= p_end_date
			    AND pos2.person_id = per2.person_id
			    AND pos2.date_start between per2.effective_start_date and per2.effective_end_date
			    AND NVL (pos2.final_process_date, p_end_date) >=p_start_date
                         -- AND NVL (per2.effective_end_date, p_end_date) >=p_start_date
			    --Added for bug fix 3828506
			    AND per2.current_employee_flag = 'Y'  )
              AND asg.person_id = per.person_id
              AND asg.effective_start_date =
                        (SELECT MIN (asg2.effective_start_date)
                           FROM per_assignments_f asg2,
			        per_assignment_status_types ast --Bug fix 3828506
                            WHERE asg2.assignment_id = asg.assignment_id
                            AND asg2.effective_start_date <= p_end_date
                            AND NVL (asg2.effective_end_date, p_end_date) >= p_start_date
			    --Added for bug fix 3828506
			    --AND asg2.primary_flag = 'Y' ---- removed join
			    AND asg2.assignment_type = 'E'
                            AND asg2.assignment_status_type_id = ast.assignment_status_type_id )
			    -- Bug Fix 4004384
			  --  AND ast.pay_system_status ='P') -- Bug Fix 4025532
	                 -- AND ast.per_system_status ='ACTIVE_ASSIGN')
              --AND asg.primary_flag = 'Y' -- removed join
              AND asg.assignment_type = 'E'
	      --Bug Fix 3828506
              AND paa.assignment_id = asg.assignment_id
              AND paa.action_status = 'C'
		  AND paa.tax_unit_id = l_segment4
              AND ppa.payroll_action_id = paa.payroll_action_id
              AND ppa.action_type IN ('Q', 'R', 'B')
		  /* impact of tim period */
             -- AND ppa.time_period_id = ptp.time_period_id
              AND ppa.payroll_id = ptp.payroll_id
              AND ppa.date_earned between ptp.start_date and ptp.end_date
		  and ppa.effective_date between p_start_date and p_end_date
		  --
              --AND ptp.end_date BETWEEN p_start_date AND p_end_date                    -- Bug 5070091 Offset payroll change
              AND pet.element_name IN ('IE PRSI Contribution Class','Setup PRSI Context Element') /* 5763147 */
              AND pet.legislation_code = 'IE'

/*              AND pet.effective_start_date =
                        (SELECT MAX (pet2.effective_start_date)
                           FROM pay_element_types_f pet2
                          WHERE pet.element_type_id = pet2.element_type_id
                            AND pet2.effective_start_date <= p_end_date
                            AND NVL (pet2.effective_end_date, p_end_date) >=
                                                                 p_start_date)*/
              AND pet.element_type_id = piv1.element_type_id
              AND piv1.NAME IN ('Contribution_Class','Context Contribution Class') /* 5763147 */
              AND piv1.legislation_code = 'IE'

/*              AND piv1.effective_start_date =
                        (SELECT MAX (piv1a.effective_start_date)
                           FROM pay_input_values_f piv1a
                          WHERE piv1.input_value_id = piv1a.input_value_id
                            AND piv1a.effective_start_date <= p_end_date
                            AND NVL (piv1a.effective_end_date, p_end_date) >=
                                                                 p_start_date)*/
              AND prr.assignment_action_id = paa.assignment_action_id
              AND prr.element_type_id = pet.element_type_id
              AND rrv1.input_value_id = piv1.input_value_id
              AND rrv1.run_result_id = prr.run_result_id
		  AND trim(rrv1.result_value) IS NOT NULL  --8247074
		  HAVING MIN(ptp.end_date) = p_date	  --8259095
         GROUP BY asg.business_group_id,
                  asg.person_id,
                  per.full_name,
                  per.original_date_of_hire,
			asg.primary_flag,
			paa.assignment_action_id,
                  trim(rrv1.result_value)
         ORDER BY asg.primary_flag desc,minimum_effective_date,paa.assignment_action_id;


-- Bug 3460687 Added cursor to fetch Balance Initialization Class Values and Class Names
      CURSOR c_context_name_bal_init (
         p_person_id    NUMBER,
         p_start_date   DATE,
         p_end_date     DATE
      )
      IS
         SELECT   /*+ ordered */
                  TO_NUMBER (
                     MAX (
                        DECODE (
                           piv1.NAME,
                           'Insurable Weeks', rrv1.result_value,
                           '0'
                        )
                     )
                  ) weeks,
                  MAX (
                     DECODE (
                        piv1.NAME,
                        'Context Contribution Class', rrv1.result_value,
                        '0'
                     )
                  ) class_name
             FROM per_people_f per,
                  per_assignments_f asg,
                  pay_assignment_actions paa,
                  pay_payroll_actions ppa,
                  per_time_periods ptp,
                  pay_run_results prr,
                  pay_element_types_f pet,
                  pay_input_values_f piv1,
                  pay_run_result_values rrv1
            WHERE per.person_id = p_person_id
		  --ANd asg.assignment_id = p_assignment_id -- vik added code for getting values for given assignment
              AND per.effective_start_date =
                        (SELECT MIN (per2.effective_start_date)
                           FROM per_people_f per2
                          WHERE per.person_id = per2.person_id
                            AND per2.effective_start_date <= p_end_date
                            AND NVL (per2.effective_end_date, p_end_date) >=
                                                                 p_start_date
			    --Added for bug fix 3828506
			    AND per2.current_employee_flag = 'Y')
              AND per.current_employee_flag = 'Y'
              AND asg.person_id = per.person_id
              --AND asg.primary_flag = 'Y' -- removed join
              AND asg.assignment_type = 'E'
              AND asg.assignment_status_type_id =
                        ( SELECT ast.assignment_status_type_id
                          FROM   per_assignment_status_types ast
                          WHERE  ast.per_system_status ='ACTIVE_ASSIGN'
			  AND    ast.assignment_status_type_id = asg.assignment_status_type_id)
              AND asg.effective_start_date =
                        (SELECT MIN (asg2.effective_start_date)
                           FROM per_assignments_f asg2,
			        per_assignment_status_types ast --For bug fix 3828506
                          WHERE asg2.assignment_id = asg.assignment_id
                            AND asg2.effective_start_date <= p_end_date
                            AND NVL (asg2.effective_end_date, p_end_date) >= p_start_date
			    --Added for bug fix 3828506
			    --AND asg2.primary_flag = 'Y' -- removed join
			    AND asg2.assignment_type = 'E'
                            AND asg2.assignment_status_type_id = ast.assignment_status_type_id
			    AND ast.per_system_status ='ACTIVE_ASSIGN')
              AND paa.assignment_id = asg.assignment_id
              AND paa.action_status = 'C'
              AND ppa.payroll_action_id = paa.payroll_action_id
              AND ppa.action_type = 'I'
		  /* time period impact */
              --  AND ppa.time_period_id = ptp.time_period_id
              AND ppa.payroll_id = ptp.payroll_id
              AND ppa.date_earned between ptp.start_date and ptp.end_date
		  AND ppa.effective_date between p_start_date and p_end_date
		  --
              --AND ptp.end_date BETWEEN p_start_date AND p_end_date                  -- Bug 5070091 Offset payroll change
              AND paa.assignment_action_id = prr.assignment_action_id
              AND pet.element_name = 'Setup PRSI Context Element'
              AND pet.legislation_code = 'IE'

/*              AND pet.effective_start_date =
                        (SELECT MAX (pet2.effective_start_date)
                           FROM pay_element_types_f pet2
                          WHERE pet.element_type_id = pet2.element_type_id
                            AND pet2.effective_start_date <= p_end_date
                            AND NVL (pet2.effective_end_date, p_end_date) >=
                                                                 p_start_date)
*/
              AND pet.element_type_id = piv1.element_type_id
              AND piv1.NAME IN
                            ('Insurable Weeks', 'Context Contribution Class')
              AND piv1.legislation_code = 'IE'

/*              AND piv1.effective_start_date =
                        (SELECT MAX (piv1a.effective_start_date)
                           FROM pay_input_values_f piv1a
                          WHERE piv1.input_value_id = piv1a.input_value_id
                            AND piv1a.effective_start_date <= p_end_date
                            AND NVL (piv1a.effective_end_date, p_end_date) >=
                                                                 p_start_date)*/
              AND prr.element_type_id = pet.element_type_id
              AND rrv1.run_result_id = prr.run_result_id
              AND rrv1.input_value_id = piv1.input_value_id
         GROUP BY prr.run_result_id
           HAVING MAX (
                     DECODE (
                        piv1.NAME,
                        'Context Contribution Class', rrv1.result_value,
                        '0'
                     )
                  ) <> '0'
         ORDER BY weeks DESC;


-- Bug 3460687 Temporary variables to use when swapping classes when both Balance Initialization and
-- Payrolls exist

      temp_flag                     NUMBER (2);
      l_context_value_counter_bal   NUMBER (2) := 0;
      l_context_value_counter_tmp   NUMBER (2) := 0;
      l_index NUMBER(10);

--8259095
       CURSOR c_main_supp_week (
         p_person_id    NUMBER,
         p_start_date   DATE,
         p_end_date     DATE
      )
      IS
         SELECT   /*+ ordered */
                  asg.business_group_id bg_id,
                  asg.person_id per_id,
                  MIN (ptp.end_date) min_eff_date,
			      ptp.time_period_id
             FROM per_people_f per,
                  per_assignments_f asg,
                  pay_assignment_actions paa,
                  pay_payroll_actions ppa,
                  per_time_periods ptp,
                  pay_run_results prr,
                  pay_element_types_f pet,
                  pay_input_values_f piv1,
                  pay_run_result_values rrv1,
                  per_assignment_extra_info paei
            WHERE per.person_id = p_person_id
              AND paei.assignment_id(+) = asg.assignment_id
              AND paei.aei_information_category(+) = 'IE_ASG_OVERRIDE'
              AND nvl(paei.aei_information1,'X') =  nvl(p_ppsn_override,'X')
              AND per.current_employee_flag = 'Y'
              AND per.effective_start_date =
                        (SELECT MIN (per2.effective_start_date)
                           FROM per_people_f per2
			    , per_periods_of_service pos2
                            WHERE per2.person_id = per.person_id
                            AND per2.effective_start_date <= p_end_date
			    AND pos2.person_id = per2.person_id
			    AND pos2.date_start between per2.effective_start_date and per2.effective_end_date
			    AND NVL (pos2.final_process_date, p_end_date) >=p_start_date
			    AND per2.current_employee_flag = 'Y'  )
              AND asg.person_id = per.person_id
              AND asg.effective_start_date =
                        (SELECT MIN (asg2.effective_start_date)
                           FROM per_assignments_f asg2,
			        per_assignment_status_types ast --Bug fix 3828506
                            WHERE asg2.assignment_id = asg.assignment_id
                            AND asg2.effective_start_date <= p_end_date
                            AND NVL (asg2.effective_end_date, p_end_date) >= p_start_date
			    AND asg2.assignment_type = 'E'
                            AND asg2.assignment_status_type_id = ast.assignment_status_type_id )
              AND asg.assignment_type = 'E'
              AND paa.assignment_id = asg.assignment_id
              AND paa.action_status = 'C'
		  AND paa.tax_unit_id = l_segment4
              AND ppa.payroll_action_id = paa.payroll_action_id
              AND ppa.action_type IN ('Q', 'R', 'B')
              AND ppa.payroll_id = ptp.payroll_id
              AND ppa.date_earned between ptp.start_date and ptp.end_date
		  and ppa.effective_date between p_start_date and p_end_date
              AND pet.element_name IN ('IE PRSI Contribution Class','Setup PRSI Context Element') /* 5763147 */
              AND pet.legislation_code = 'IE'
              AND pet.element_type_id = piv1.element_type_id
              AND piv1.NAME IN ('Contribution_Class','Context Contribution Class') /* 5763147 */
              AND piv1.legislation_code = 'IE'
              AND prr.assignment_action_id = paa.assignment_action_id
              AND prr.element_type_id = pet.element_type_id
              AND rrv1.input_value_id = piv1.input_value_id
              AND rrv1.run_result_id = prr.run_result_id
		  AND trim(rrv1.result_value) IS NOT NULL
          GROUP BY asg.business_group_id,
                  asg.person_id,
                  ptp.time_period_id
          ORDER BY min_eff_date;

l_supp_run_class pay_run_result_values.result_value%type;
TYPE type_context_name IS table of c_context_name%rowtype INDEX BY BINARY_INTEGER;
l_type_context_name_tab type_context_name;
--8259095

   BEGIN
      --


      l_class_count := 0;
      l_weeks_at_initial_class := 0;
      l_weeks_at_second_class := 0;
      l_weeks_at_third_class := 0;
      l_weeks_at_fourth_class := 0;
	l_weeks_at_fifth_class := 0;
      l_index := 1;
-- l_context_value_counter := 0;
      l_initial_class := NULL;
      l_second_class := NULL;
      l_third_class := NULL;
      l_fourth_class := NULL;
	l_fifth_class := NULL;
	l_supp_run_class := NULL; 	--8259095

	-- Flush the prsi_class_tab table.

      --
      -- Bug 2979713 - PRSI Context Balance Design Change


      --

     -- hr_utility.TRACE ('In procedure get_initial_class');
      -- Fetching the values of context_id, balance_dimension_id, assignment_action_id for furthur
      -- usage in the get_weeks_at_class procedures

      OPEN c_context_id;
      FETCH c_context_id INTO l_context_id;
      CLOSE c_context_id;

      l_defined_balance_id :=
           get_defined_balance_id ('_PER_PAYE_REF_PRSI_YTD', 'IE PRSI Insurable Weeks');

       --Bug fix 4004470
      /*OPEN c_assignment_action_id (
         p_person_id_global,
         p_start_date,
         p_end_date
      );
      CLOSE c_assignment_action_id;*/

      --Bug fix 4023794,  Emptying the pl/sql table
      /*  t_asg_action_id := t_empty_asg_table ;

      FOR r_asg_action_id IN c_assignment_action_id (p_person_id_global,p_start_date,p_end_date)
      LOOP
           t_asg_action_id(l_index) := r_asg_action_id.assignment_action_id;
	   l_index := l_index + 1;
      END LOOP;*/
      t_asg_action_id := p_max_action_id;

     hr_utility.set_location (   'context_id='|| l_context_id, 10);
      hr_utility.set_location (   'l_balance_dimension_id=' || l_defined_balance_id, 20      );
      hr_utility.set_location ( 'l_assignment_action_id='|| t_asg_action_id, 30);
      -- looping the c_context_name cursor and stroring the first 5 classes for the assignment_id passed into the pl/sql table
      hr_utility.set_location (  'p_person_id_global' || p_person_id_global, 31);
	hr_utility.set_location (  'p_start_date' || p_start_date, 32);
	hr_utility.set_location (  'p_end_date' || p_end_date, 33);

--8259095
    FOR r_c_main_supp_week IN c_main_supp_week(
                                 p_person_id_global,
                                 p_start_date,
                                 p_end_date
                              )
    LOOP
        l_type_context_name_tab.DELETE;
        OPEN c_context_name (
                                 p_person_id_global,
                                 p_start_date,
                                 p_end_date,
                                 r_c_main_supp_week.min_eff_date
                              );
        FETCH c_context_name bulk collect into l_type_context_name_tab;
        CLOSE c_context_name;
        l_supp_run_class := NULL;

        IF l_type_context_name_tab.COUNT > 1 THEN
        FOR p in l_type_context_name_tab.FIRST..l_type_context_name_tab.LAST
        LOOP
          l_supp_run_class := substr(l_type_context_name_tab(p).result_value,4,2);

          IF p = l_type_context_name_tab.LAST THEN
				if l_context_value_counter = 0 then
						l_context_value_counter := l_context_value_counter + 1;
						t_context_value(l_context_value_counter) := l_type_context_name_tab(p).result_value;
						hr_utility.set_location ('Initial Class Value is :'|| t_context_value (l_context_value_counter), 16);
				else
					For k in 1 .. l_context_value_counter
					loop
						if t_context_value(k) = l_type_context_name_tab(p).result_value then
							temp_flag :=1;
							exit;
						else
							temp_flag :=0;
						end if;
					END LOOP;
					if temp_flag = 0 and l_context_value_counter <=9 then
						l_context_value_counter := l_context_value_counter + 1;
						t_context_value(l_context_value_counter) := l_type_context_name_tab(p).result_value;
						hr_utility.set_location ('Subsequent Class Value is :'|| t_context_value (l_context_value_counter), 17);
					END IF;
					temp_flag := null;
				END IF;
             IF l_supp_wk_tab.EXISTS(l_supp_run_class) THEN
                l_supp_wk_tab(l_supp_run_class) := l_supp_wk_tab(l_supp_run_class) +
				pay_balance_pkg.get_value (
							get_defined_balance_id ('_ASG_PTD', 'IE PRSI Insurable Weeks'),
							l_type_context_name_tab(p).assignment_action_id,
							l_segment4,
							NULL,
							NULL,
							NULL,
							NULL,
							NULL
							);
	        Else
	           l_supp_wk_tab(l_supp_run_class) :=   pay_balance_pkg.get_value (
							                            get_defined_balance_id ('_ASG_PTD', 'IE PRSI Insurable Weeks'),
							                            l_type_context_name_tab(p).assignment_action_id,
							                            l_segment4,
						                                NULL,
							                            NULL,
							                            NULL,
						                                NULL,
							                            NULL
						                                );
	        End If;
          ELSE
            IF l_supp_wk_tab.EXISTS(l_supp_run_class) THEN
                l_supp_wk_tab(l_supp_run_class) := l_supp_wk_tab(l_supp_run_class) -
				pay_balance_pkg.get_value (
							get_defined_balance_id ('_ASG_RUN', 'IE PRSI Insurable Weeks'),
							l_type_context_name_tab(p).assignment_action_id,
							l_segment4,
							NULL,
							NULL,
							NULL,
							NULL,
							NULL
							);
	        Else
	            l_supp_wk_tab(l_supp_run_class) := - (pay_balance_pkg.get_value (
							                            get_defined_balance_id ('_ASG_RUN', 'IE PRSI Insurable Weeks'),
							                            l_type_context_name_tab(p).assignment_action_id,
							                            l_segment4,
						                                NULL,
							                            NULL,
							                            NULL,
						                                NULL,
							                            NULL
						                                ));
	        End If;
          END IF;
          END LOOP;
        ELSIF l_type_context_name_tab.COUNT = 1 THEN
			FOR q in l_type_context_name_tab.FIRST..l_type_context_name_tab.LAST
			LOOP
				if l_context_value_counter = 0 then
						l_context_value_counter := l_context_value_counter + 1;
						t_context_value(l_context_value_counter) := l_type_context_name_tab(q).result_value;
						hr_utility.set_location ('Initial Class Value is :'|| t_context_value (l_context_value_counter), 18);
				else
					For k in 1 .. l_context_value_counter
					loop
						if t_context_value(k) = l_type_context_name_tab(q).result_value then
							temp_flag :=1;
							exit;
						else
							temp_flag :=0;
						end if;
					END LOOP;
					if temp_flag = 0 and l_context_value_counter <=9 then
						l_context_value_counter := l_context_value_counter + 1;
						t_context_value(l_context_value_counter) := l_type_context_name_tab(q).result_value;
						hr_utility.set_location ('Subsequent Class Value is :'|| t_context_value (l_context_value_counter), 19);
					END IF;
					temp_flag := null;
				END IF;
			END LOOP;
        END IF;
    END LOOP;
--8259095

/* -- 8259095 commented the old logic to get the Ins Weeks, same logic used in new code with supp classes.
      FOR r_c_context_name IN c_context_name (
                                 p_person_id_global,
                                 p_start_date,
                                 p_end_date
                              )
      LOOP

	hr_utility.set_location('Inside c_context_name cursor..',203);
	hr_utility.set_location('Inside c_context_name cursor..',203);
	if l_context_value_counter = 0 then
		l_context_value_counter := l_context_value_counter + 1;
		t_context_value(l_context_value_counter) := r_c_context_name.result_value;
		hr_utility.set_location ('Initial Class Value is :'|| t_context_value (l_context_value_counter), 16);
	else
		--For j in 1 .. 1
		--LOOP
			For k in 1 .. l_context_value_counter
			loop
				if t_context_value(k) = r_c_context_name.result_value then
					temp_flag :=1;
					exit;
				else
					temp_flag :=0;
				end if;
			END LOOP;
			if temp_flag = 0 and l_context_value_counter <=9 then
				l_context_value_counter := l_context_value_counter + 1;
				t_context_value(l_context_value_counter) := r_c_context_name.result_value;
				hr_utility.set_location ('Subsequent Class Value is :'|| t_context_value (l_context_value_counter), 17);
				--temp := null;
				--exit;
			END IF;
			temp_flag := null;
		--END LOOP;
	END IF;
	END LOOP;
*/ --8259095


/*           For i IN 1 .. l_context_value_counter
	     LOOP
			IF r_c_context_name.result_value <> t_context_value (i) THEN
				t_context_value (l_context_value_counter) := r_c_context_name.result_value;
				l_context_value_counter :=   l_context_value_counter + 1;
		            hr_utility.set_location ('Class Value is :'|| t_context_value (l_context_value_counter), 16);
			ELSE
				EXIT;
			END IF;
		END LOOP;
      END LOOP;*/


-- Bug 3460687 Fetching all Balance Initialization classes into a pl/sql table
      FOR bal_context_name IN c_context_name_bal_init (
                                 p_person_id_global,
                                 p_start_date,
                                 p_end_date
                              )
      LOOP
         IF l_context_value_counter_bal <= 10
         THEN
            l_context_value_counter_bal :=   l_context_value_counter_bal
                                           + 1;
            t_context_value_balinit (l_context_value_counter_bal) :=
                                                  bal_context_name.class_name;
            hr_utility.set_location (
                  'Class Value for Balance Initialization is :'
               || t_context_value_balinit (l_context_value_counter_bal),
               16
            );
         END IF;
      END LOOP;


-- Bug 3460687 In case of only Balance Initialization and no Payrolls
-- Putting all Classes into the global t_context_value table
      IF  t_context_value_balinit.COUNT <> 0 AND t_context_value.COUNT = 0
      THEN
         t_context_value := t_context_value_balinit;
         l_context_value_counter := l_context_value_counter_bal;
      END IF;


-- Bug 3460687 In case of both Balance Initialization and Payrolls

      IF  t_context_value_balinit.COUNT <> 0 AND t_context_value.COUNT <> 0
      THEN
         t_context_value_tmp := t_context_value_balinit;
         l_context_value_counter_tmp := l_context_value_counter_bal;

         FOR i IN 1 .. l_context_value_counter
         LOOP
            FOR j IN 1 .. l_context_value_counter_bal
            LOOP
               IF t_context_value (i) = t_context_value_balinit (j)
               THEN
                  temp_flag := 1;
                  EXIT;
               ELSE
                  temp_flag := 0;
               END IF;
            END LOOP;

            IF  temp_flag = 0 AND l_context_value_counter_tmp <= 10
            THEN
               l_context_value_counter_tmp :=
                                              l_context_value_counter_tmp
                                            + 1;
               t_context_value_tmp (l_context_value_counter_tmp) :=
                                                          t_context_value (i);
               /*hr_utility.TRACE (
                  'A Payroll class unmatched with Balance Initialization found'
               );*/
            END IF;

            temp_flag := NULL;
         END LOOP;

         t_context_value := t_context_value_tmp;
         l_context_value_counter := l_context_value_counter_tmp;
      END IF;

      -- fetching the first class value
           -- Bug 2993535 - ERRORING IN CASE OF A PERSON WITHOUT A PAYROLL
           -- The below if clause has been added to fix the issue.
      IF l_context_value_counter <> 0
      THEN
         l_initial_class := NVL (t_context_value (1), NULL);
         hr_utility.set_location (   'l_initial_class' || l_initial_class, 50);
         --hr_utility.TRACE ('About to leave initial class');
      END IF;

      RETURN SUBSTR (l_initial_class, 4, 2);
   EXCEPTION
      WHEN OTHERS
      THEN
         -- Bug 2993535 - ERRORING IN CASE OF A PERSON WITHOUT A PAYROLL
         -- The below if clause has been added to fix the issue.
         -- close c_context_id;
         -- close c_assignment_action_id;
         t_context_value := t_empty_table;
         hr_utility.set_location ('Error in get_total_insurable_weeks', 200);
         RAISE;
   END get_initial_class;


--
   FUNCTION get_second_class (p_assignment_id IN NUMBER)
      RETURN VARCHAR2
   AS
   BEGIN
      --
           -- Bug 2979713 - PRSI Context Balance Design Change
      --
      -- fetching the second class value

     -- hr_utility.TRACE ('In procedure get second class');
      hr_utility.set_location (   't_context_value '
                               || p_assignment_id, 20);

      IF l_context_value_counter >= 2
      THEN
         l_second_class := NVL (t_context_value (2), NULL);
      ELSE
         l_second_class := NULL;
      END IF;

    --  hr_utility.TRACE ('About to leave get second class');
      RETURN SUBSTR (l_second_class, 4, 2);
   END get_second_class;


--
   FUNCTION get_p60_second_class (p_assignment_id IN NUMBER)
      RETURN VARCHAR2
   AS

--
      CURSOR c_p60_second_class
      IS
         SELECT SUBSTR (piw.combined_class, 1, 2),
                NVL (piw.insurable_weeks, 0)
           FROM pay_ie_p35_insurable_weeks_v piw
          WHERE piw.person_id =
                      (SELECT asg.person_id
                         FROM per_assignments_f asg
                        WHERE asg.assignment_id = p_assignment_id
                          AND asg.effective_start_date =
                                    (SELECT MIN (asg2.effective_start_date)
                                       FROM per_assignments_f asg2
                                      WHERE asg.assignment_id =
                                                           asg2.assignment_id))
            AND piw.insurable_weeks =
                      (SELECT MAX (piw2.insurable_weeks)
                         FROM pay_ie_p35_insurable_weeks_v piw2
                        WHERE piw2.person_id = piw.person_id
                          AND SUBSTR (piw2.combined_class, 1, 2) <>
                                                    RPAD (l_initial_class, 2))
            AND piw.minimum_effective_date =
                      (SELECT MIN (piw3.minimum_effective_date)
                         FROM pay_ie_p35_insurable_weeks_v piw3
                        WHERE piw3.person_id = piw.person_id
                          AND piw3.insurable_weeks = piw.insurable_weeks
                          AND SUBSTR (piw3.combined_class, 1, 2) <>
                                                    RPAD (l_initial_class, 2));
   --
   BEGIN
  --    hr_utility.TRACE ('In get P60 second class');
      /*hr_utility.TRACE (   'p_assignment_id : '
                        || TO_CHAR (p_assignment_id));
      hr_utility.TRACE (
            'l_class_count_at_second_class : '
         || TO_CHAR (l_class_count)
      );
*/
      IF l_class_count >= 2
      THEN
         OPEN c_p60_second_class;
         FETCH c_p60_second_class INTO l_second_class, l_weeks_at_second_class;
         CLOSE c_p60_second_class;
      ELSE
         l_second_class := ' ';
      END IF;

      /*hr_utility.TRACE (   'l_second_class : '
                        || l_second_class);
      hr_utility.TRACE (
            'l_weeks_at_second_class : '
         || TO_CHAR (l_weeks_at_second_class)
      );
      hr_utility.TRACE (   'l_initial_class : '
                        || l_initial_class);
      hr_utility.TRACE ('Leaving get_second_class');*/
      RETURN l_second_class;
   END get_p60_second_class;


--
   FUNCTION get_third_class (p_assignment_id IN NUMBER)
      RETURN VARCHAR2
   AS
   BEGIN
           -- Bug 2979713 - PRSI Context Balance Design Change
      -- fetching the third class value

      --hr_utility.TRACE ('IN Procedure get third class');

      IF l_context_value_counter >= 3
      THEN
         l_third_class := NVL (t_context_value (3), NULL);
      ELSE
         l_third_class := NULL;
      END IF;

      --hr_utility.TRACE ('About to leave get third class');
      RETURN SUBSTR (l_third_class, 4, 2);
   END get_third_class;


--
   FUNCTION get_fourth_class (p_assignment_id IN NUMBER)
      RETURN VARCHAR2
   AS
   BEGIN
           --
           -- Bug 2979713 - PRSI Context Balance Design Change
      --
      -- fetching the forth class value

     -- hr_utility.TRACE ('In procedure get fourth class');

      IF l_context_value_counter >= 4
      THEN
         l_fourth_class := NVL (t_context_value (4), NULL);
      ELSE
         l_fourth_class := NULL;
      END IF;

    --  hr_utility.TRACE ('About to leave get fourth class');
      RETURN SUBSTR (l_fourth_class, 4, 2);
   END get_fourth_class;


--
   FUNCTION get_fifth_class (p_assignment_id IN NUMBER)
      RETURN VARCHAR2
   AS
   BEGIN
           --
      -- Bug 2979713 - PRSI Context Balance Design Change
      --
      -- fetching the fifth class value

      --hr_utility.TRACE ('In procedure get fifith class');

      IF l_context_value_counter >= 5
      THEN
         l_fifth_class := NVL (t_context_value (5), NULL);
      ELSE
         l_fifth_class := NULL;
      END IF;

   --   hr_utility.TRACE ('About to leave get fifith class');
      RETURN SUBSTR (l_fifth_class, 4, 2);
   END get_fifth_class;


--
/* new function */

FUNCTION get_prsi_weeks (l_class IN varchar2,
				 l_segment4  in number)
      RETURN NUMBER

   AS
	l_weeks	number:=0;
   BEGIN
hr_utility.set_location('l_class..'||l_class,11);
hr_utility.set_location('l_defined_balance_id..'||l_defined_balance_id,11);
hr_utility.set_location('t_asg_action_id..'||t_asg_action_id,11);
hr_utility.set_location('l_segment4..'||l_segment4,11);
hr_utility.set_location('l_class..'||l_class,11);
hr_utility.set_location('l_context_id..'||l_context_id,11);
hr_utility.set_location('l_class..'||l_class,11);
hr_utility.set_location('l_class..'||l_class,11);


      l_weeks := 0;

	   l_weeks := l_weeks +
               pay_balance_pkg.get_value (
                  l_defined_balance_id,
         		t_asg_action_id,
			l_segment4,
                  NULL,
                  l_context_id,
                  l_class,
                  NULL,
                  NULL
               );
hr_utility.set_location('l_weeks..'||l_weeks,11);
      RETURN l_weeks;
END get_prsi_weeks;
/* End of new function */

   FUNCTION weeks_at_initial_class (p_assignment_id IN NUMBER,
						l_segment4  in number)
      RETURN NUMBER
   AS
      l_initial_weeks   NUMBER (4);
   BEGIN
      --
      -- Bug 2979713 - PRSI Context Balance Design Change
      --
    --  hr_utility.TRACE ('In procedure weeks_at_initial_class');

      IF l_initial_class IS NOT NULL
      THEN
      --Bug fix 4023794, flusing of variables
      l_initial_weeks := 0;
      --FOR csr_action_rec IN 1..t_asg_action_id.count
      --LOOP  -- Bug fix 4004470
          l_initial_weeks :=  l_initial_weeks +
	                       pay_balance_pkg.get_value (
                               l_defined_balance_id,
                               t_asg_action_id,
					 l_segment4,
                               NULL,
                               l_context_id,
                               l_initial_class,
                               NULL,
                               NULL
                            );
         hr_utility.set_location (   'l_initial_weeks'
                                  || l_initial_weeks, 40);
       --END LOOP;
      ELSE
         l_initial_weeks := 0;
      END IF;


     -- hr_utility.TRACE ('Leaving weeks_at_initial_class');
      RETURN l_initial_weeks;
   END weeks_at_initial_class;


--
   FUNCTION weeks_at_second_class (p_assignment_id IN NUMBER,
					     l_segment4  in number)
      RETURN NUMBER
   AS
   BEGIN
      --
      -- Bug 2979713 - PRSI Context Balance Design Change
      --
     -- hr_utility.TRACE ('In proceduer weeks_at_second_class');

      IF l_second_class IS NOT NULL
      THEN -- Bug fix 4004470
      l_weeks_at_second_class := 0;   --Bug fix 4023794, flusing of variables
      --FOR csr_action_rec IN 1..t_asg_action_id.count
      --LOOP
         l_weeks_at_second_class := l_weeks_at_second_class +
               pay_balance_pkg.get_value (
                  l_defined_balance_id,
                  -- l_assignment_action_id,
			t_asg_action_id,
			l_segment4,
                  NULL,
                  l_context_id,
                  l_second_class,
                  NULL,
                  NULL
               );
	--END LOOP;
      ELSE
         l_weeks_at_second_class := 0;
      END IF;
   --   hr_utility.TRACE ('Leaving proceduer weeks_at_second_class');
      RETURN l_weeks_at_second_class;
   END weeks_at_second_class;


--
   FUNCTION weeks_at_third_class (p_assignment_id IN NUMBER,
					    l_segment4  in number)
      RETURN NUMBER
   AS
   BEGIN
      --
      -- Bug 2979713 - PRSI Context Balance Design Change
      --
     -- hr_utility.TRACE ('In procedure weeks_at_third_class');
      IF l_third_class IS NOT NULL
      THEN     -- Bug fix 4004470
              l_weeks_at_third_class := 0; --Bug fix 4023794, flusing of variables
	      --FOR csr_action_rec IN 1..t_asg_action_id.count
	      --LOOP
		 l_weeks_at_third_class := l_weeks_at_third_class +
		       pay_balance_pkg.get_value (
			  l_defined_balance_id,
			  --l_assignment_action_id,
			  t_asg_action_id,
			  l_segment4,
			  NULL,
			  l_context_id,
			  l_third_class,
			  NULL,
			  NULL
		       );
	      --END LOOP;
      ELSE
         l_weeks_at_third_class := 0;
      END IF;
    --  hr_utility.TRACE ('Leaving procedure weeks_at_third_class');
      RETURN l_weeks_at_third_class;
   END weeks_at_third_class;


--
   FUNCTION weeks_at_fourth_class (p_assignment_id IN NUMBER,
					     l_segment4  in number)
      RETURN NUMBER
   AS
   BEGIN
      -- Bug 2979713 - PRSI Context Balance Design Change

    -- hr_utility.TRACE ('In procedure weeks_at_fourth_class');
      IF l_fourth_class IS NOT NULL
      THEN    -- Bug fix 4004470
             l_weeks_at_fourth_class := 0; --Bug fix 4023794, flusing of variables
	      --FOR csr_action_rec IN 1..t_asg_action_id.count
	      --LOOP
		 l_weeks_at_fourth_class := l_weeks_at_fourth_class +
		       pay_balance_pkg.get_value (
			  l_defined_balance_id,
			  -- l_assignment_action_id,
			  t_asg_action_id,
			  l_segment4,
			  NULL,
			  l_context_id,
			  l_fourth_class,
			  NULL,
			  NULL
		       );
	     -- END LOOP;
      ELSE
         l_weeks_at_fourth_class := 0;
      END IF;

--hr_utility.TRACE ('Ieaving weeks_at_fourth_class');
      RETURN l_weeks_at_fourth_class;
      --hr_utility.TRACE ('About to leave get weeks at fourth class');
   END weeks_at_fourth_class;


/* Added for fifth class by vik */

  FUNCTION weeks_at_fifth_class (p_assignment_id IN NUMBER,
					     l_segment4  in number)
      RETURN NUMBER
   AS
   BEGIN
      -- Bug 2979713 - PRSI Context Balance Design Change

    -- hr_utility.TRACE ('In procedure weeks_at_fourth_class');
      IF l_fifth_class IS NOT NULL
      THEN
             l_weeks_at_fifth_class := 0;
		 l_weeks_at_fifth_class := l_weeks_at_fifth_class +
		       pay_balance_pkg.get_value (
			  l_defined_balance_id,
			  t_asg_action_id,
			  l_segment4,
			  NULL,
			  l_context_id,
			  l_fifth_class,
			  NULL,
			  NULL
		       );
      ELSE
         l_weeks_at_fifth_class := 0;
      END IF;

      RETURN l_weeks_at_fifth_class;
   END weeks_at_fifth_class;

/* End of weeks_at_fifth class */

--

   FUNCTION get_total_insurable_weeks (p_person_id IN NUMBER
						,p_tax_unit_id IN NUMBER
						,p_assignment_action_id IN NUMBER
						,p_Act_Context_id  number default NULL  --6633719
						,p_Act_Context_value varchar2 default NULL --6633719
						,p_dimension_name varchar2 default '_PER_PAYE_REF_YTD' --6633719
                        ,p_ppsn_override VARCHAR2 default NULL) --6633719
      RETURN NUMBER
   AS

      l_total_weeks                NUMBER (4) := 0; --Bug No 4555227
      l_get_assignment_action_id   pay_assignment_actions.assignment_action_id%TYPE;
   --
   --

   BEGIN
       --
	 hr_utility.set_location('In Insurable Weeks.',201);
	 hr_utility.set_location('In Insurable Weeks.'||to_char(p_assignment_action_id),202);

	p_start_date := get_start_date ();
      p_end_date := get_end_date ();

	IF p_person_id <> p_person_id_global OR p_ppsn_override IS NOT NULL  --6633719
      THEN
         t_context_value := t_empty_table;
         l_context_value_counter := 0;
         t_context_value_balinit := t_empty_table;
         t_context_value_tmp := t_empty_table;
         l_supp_wk_tab := l_supp_wk_tab_empty;  --9080372
      END IF;

	p_person_id_global := p_person_id;

	 l_total_weeks := 0;
	  --Bug fix 4004470
         l_total_weeks :=l_total_weeks +
                 nvl(pay_balance_pkg.get_value (
			    pay_ie_p35.get_defined_balance_id (
				 p_dimension_name,  --'_PER_PAYE_REF_YTD', -- changes made  --6633719
				 'IE PRSI Insurable Weeks'
			    ),
			    p_assignment_action_id, --paa.assignment_action_id,
			    p_tax_unit_id, -- paye reference value
				  null,
				   p_Act_Context_id,  --null,  --6633719
				   p_Act_Context_value,  --null,  --6633719
				   null,
				   null,
				   null,
				  'TRUE'
			 ),0)
		   +
		   nvl(pay_balance_pkg.get_value (
			    pay_ie_p35.get_defined_balance_id (
				 p_dimension_name,  --'_PER_PAYE_REF_YTD', -- changes made  --6633719
				 'IE PRSI K Term Insurable Weeks'
			    ),
			    p_assignment_action_id, --paa.assignment_action_id,
			    p_tax_unit_id, -- paye reference value
				  null,
				   p_Act_Context_id,  --null,  --6633719
				   p_Act_Context_value,  --null,  --6633719
				   null,
				   null,
				   null,
				  'TRUE'
			 ),0)
                  + nvl(pay_balance_pkg.get_value (
			    pay_ie_p35.get_defined_balance_id (
				 p_dimension_name,  --'_PER_PAYE_REF_YTD', -- changes made  --6633719
				 'IE PRSI M Term Insurable Weeks'
			    ),
			    p_assignment_action_id, --paa.assignment_action_id,
			    p_tax_unit_id, -- paye reference value
				  null,
				   p_Act_Context_id,  --null,  --6633719
				   p_Act_Context_value,  --null,  --6633719
				   null,
				   null,
				   null,
				  'TRUE'
			 ),0) ;



     /* CLOSE c_get_assignment_action_id;*/
        --hr_utility.TRACE ('Else l_total_weeks='|| l_total_weeks);
      RETURN l_total_weeks;
   EXCEPTION
      WHEN OTHERS
      THEN
         --CLOSE c_get_assignment_action_id;
         t_context_value := t_empty_table;
         t_context_value_balinit := t_empty_table;
         t_context_value_tmp := t_empty_table;
         hr_utility.set_location ('Error in get_total_insurable_weeks', 200);
         RAISE;
   END get_total_insurable_weeks;


--
   FUNCTION get_start_date
      RETURN DATE
   AS
      l_start_date   DATE;
   BEGIN
      SELECT fnd_date.canonical_to_date (
                   SUBSTR (fpov.profile_option_value, 1, 4)
                || '01/01 00:00:00'
             )
        INTO l_start_date
        FROM fnd_profile_option_values fpov, fnd_profile_options fpo
       WHERE fpo.profile_option_id = fpov.profile_option_id
         AND fpo.application_id = fpov.application_id
         AND fpo.profile_option_name = 'PAY_IE_P35_REPORTING_YEAR'
         AND fpov.level_id = 10001
         AND fpov.level_value = 0;

      RETURN l_start_date;
   END get_start_date;


--
   FUNCTION get_end_date
      RETURN DATE
   AS
      l_end_date   DATE;
   BEGIN
      SELECT fnd_date.canonical_to_date (
                   SUBSTR (fpov.profile_option_value, 1, 4)
                || '12/31 23:59:59'
             )
        INTO l_end_date
        FROM fnd_profile_option_values fpov, fnd_profile_options fpo
       WHERE fpo.profile_option_id = fpov.profile_option_id
         AND fpo.application_id = fpov.application_id
         AND fpo.profile_option_name = 'PAY_IE_P35_REPORTING_YEAR'
         AND fpov.level_id = 10001
         AND fpov.level_value = 0;

      RETURN l_end_date;
   END get_end_date;

Function check_assignment_in_set(
 				 p_assignment_id per_assignments_f.assignment_id%TYPE,
				 p_assignment_set_id hr_assignment_sets.assignment_set_id%TYPE,
				 p_business_group per_assignments_f.business_group_id%TYPE
				) return NUMBER
		AS
	CURSOR csr_locked_asg_sets
	is
        select hasa.include_or_exclude from hr_assignment_set_amendments hasa, hr_assignment_sets has
	                               where hasa.assignment_set_id = has.assignment_set_id
				       and has.business_group_id = p_business_group
				       and has.assignment_set_id = p_assignment_set_id
				       and hasa.assignment_id = p_assignment_id;
	CURSOR csr_get_flag_from_set
	is
	select distinct hasa.include_or_exclude from hr_assignment_set_amendments hasa, hr_assignment_sets has
	                               where hasa.assignment_set_id = has.assignment_set_id
				       and has.business_group_id = p_business_group
				       and has.assignment_set_id = p_assignment_set_id;
	l_set_flag Varchar2(30) :=null;
	l_flag Varchar2(30) :=null;
	BEGIN
		IF p_assignment_set_id is null THEN
		 return 1;
		ELSE
			OPEN csr_locked_asg_sets;
			FETCH csr_locked_asg_sets into l_set_flag;
			CLOSE csr_locked_asg_sets;
			IF (l_set_flag IS NOT NULL) THEN
				IF l_set_flag ='E' THEN
				   return 0;
				ELSIF l_set_flag ='I' THEN
				   return 1;
				END IF;
			ELSE --l_set_flag is null
				OPEN csr_get_flag_from_set;
				FETCH csr_get_flag_from_set into l_flag;
				CLOSE csr_get_flag_from_set ;
				IF l_flag IS NULL THEN
					return 0; -- Assignment set is empty
				ELSIF l_flag ='I' THEN
					return 0; --Present assignment is not present is Inclusion set
				ELSIF l_flag ='E' THEN
					return 1; --Present assignment is not present is Exclusion set
				END IF;
			END IF;
		END IF;
END check_assignment_in_set;

   /*Added for bug fix 3815830*/
   FUNCTION replace_xml_symbols(p_string IN VARCHAR2)
      RETURN VARCHAR2
   AS

      l_string   VARCHAR2(300);

   BEGIN


	l_string :=  p_string;

	l_string := replace(l_string, '&', '&amp;');
	l_string := replace(l_string, '<', '&#60;');
	l_string := replace(l_string, '>', '&#62;');
      l_string := replace(l_string, '''','&apos;');
	l_string := replace(l_string, '"', '&quot;');
	-- bug 6275544, called
	l_string := pay_ie_p35_magtape.test_XML(l_string);
	-- bug 5867343, special characters.
	/*l_string := replace(l_string, fnd_global.local_chr(193),'&#193;');
	l_string := replace(l_string, fnd_global.local_chr(201),'&#201;');
	l_string := replace(l_string, fnd_global.local_chr(205),'&#205;');
	l_string := replace(l_string, fnd_global.local_chr(211),'&#211;');
	l_string := replace(l_string, fnd_global.local_chr(218),'&#218;');
	l_string := replace(l_string, fnd_global.local_chr(225),'&#225;');
	l_string := replace(l_string, fnd_global.local_chr(233),'&#233;');
	l_string := replace(l_string, fnd_global.local_chr(237),'&#237;');
	l_string := replace(l_string, fnd_global.local_chr(243),'&#243;');
	l_string := replace(l_string, fnd_global.local_chr(250),'&#250;');*/




   RETURN l_string;
   EXCEPTION when no_data_found then
     null;
   END replace_xml_symbols;

 END pay_ie_p35;

/
