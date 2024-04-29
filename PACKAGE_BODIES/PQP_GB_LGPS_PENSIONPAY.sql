--------------------------------------------------------
--  DDL for Package Body PQP_GB_LGPS_PENSIONPAY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_GB_LGPS_PENSIONPAY" AS
/* $Header: pqgblgps.pkb 120.9.12010000.11 2009/05/14 11:05:58 pbalu ship $ */
--
g_package                 VARCHAR2(31) := 'PQP_GB_LGPS_PENSIONPAY.';

--6666135 Begin
Type Formula_Element is RECORD
(
Element_name varchar2(150),
Formula_name varchar2(150),
formula_id   Number(9)
);
Type Formula_Element_Tab_typ is table of Formula_Element index by Binary_integer;
Formula_Element_Tab Formula_Element_Tab_typ;
Type Formula_Tab_typ is table of varchar2(150) index by Binary_integer;
Formula_Tab Formula_Tab_typ;
Formula_Tab_new Formula_Tab_typ;

j_formula_count number;
k_aasgn_form_count number;
l_warning_msg  varchar2(200);
--6666135 End

/* Bug Fix for 8238736 Start
--Added p_historic_value number argument to the function.
Function RUN_USER_FORMULA(p_assignment_id NUMBER
                         ,p_effective_date DATE
                         ,p_business_group_id NUMBER
                         ,p_payroll_id NUMBER
                         ,Formula_Tab Formula_Tab_typ
			 ,p_assignment_number VARCHAR2)
return number is
*/
Function RUN_USER_FORMULA(p_assignment_id NUMBER
                         ,p_effective_date DATE
                         ,p_business_group_id NUMBER
                         ,p_payroll_id NUMBER
                         ,Formula_Tab Formula_Tab_typ
			 ,p_assignment_number VARCHAR2
                         ,p_historic_value number)
return number is
-- Bug Fix for 8238736 End

--6666135 Begin
cursor c_pqp_formula_id(P_FORMULA_NAME VARCHAR2)
is
  select ffff.formula_id
    From FF_FORMULAS_F ffff
   where UPPER(ffff.FORMULA_NAME) = UPPER(P_FORMULA_NAME)
     and ffff.business_group_id = p_business_group_id
     and p_effective_date between ffff.EFFECTIVE_START_DATE and ffff.EFFECTIVE_END_DATE;
--6666135 End

--This cursor will fetch the seeded element details.
cursor c_additional_pension(p_assignment_id NUMBER
                            ,p_effective_date date)
is
   SELECT peevf.element_entry_id
         ,peevf.input_value_id
     FROM pay_element_types_f petf
         ,pay_element_entries_f peef
         ,pay_element_entry_values_f peevf
    where petf.element_name = 'PQP LGPS Additional Pensionable Pay'
      and petf.legislation_code = 'GB'
--      and petf.business_group_id = p_business_group_id  6652351
      and petf.element_type_id  = peef.element_type_id
      and peef.element_entry_id = peevf.element_entry_id
      and peef.assignment_id = p_assignment_id
    --and p_effective_date between petf.EFFECTIVE_START_DATE and petf.EFFECTIVE_END_DATE  --6666135
      and p_effective_date between peef.EFFECTIVE_START_DATE and peef.EFFECTIVE_END_DATE
      and p_effective_date between peevf.EFFECTIVE_START_DATE and peevf.EFFECTIVE_END_DATE;

--6666135 Begin
cursor c_seeded_element_det
is
    select pelf.element_link_id,plivf.input_value_id
    from pay_element_links_f pelf
        ,pay_link_input_values_f plivf
        ,pay_element_types_f petf
    where petf.element_name = 'PQP LGPS Additional Pensionable Pay'
      and petf.legislation_code = 'GB'
      and petf.element_type_id  = pelf.element_type_id
      and pelf.ELEMENT_LINK_ID = plivf.ELEMENT_LINK_ID
      and pelf.business_group_id = p_business_group_id
      and pelf.LINK_TO_ALL_PAYROLLS_FLAG = 'Y'
      and p_effective_date between pelf.EFFECTIVE_START_DATE and pelf.EFFECTIVE_END_DATE;
--6666135 End

cursor c_action_ids(p_assignment_id NUMBER
                   ,p_effective_date date)
is
   SELECT max(paa.assignment_action_id) ASSIGNMENT_ACTION_ID
         ,max(ppa.payroll_action_id) PAYROLL_ACTION_ID
     FROM pay_payroll_actions ppa,
          pay_assignment_actions paa
    WHERE ppa.action_type in ('Q','R')
      AND paa.action_status = 'C'
      AND ppa.business_group_id = p_business_group_id
      AND paa.assignment_id = p_assignment_id
      AND ppa.payroll_action_id = paa.payroll_action_id
      AND effective_date <= p_effective_date;

c_additional_pension_row c_additional_pension%rowtype;
l_inputs     ff_exec.inputs_t;
p_inputs     ff_exec.inputs_t;
l_outputs    ff_exec.outputs_t;
c_action_ids_row c_action_ids%rowtype;
n_sum_formula_val number :=0;
--6666135 Begin
c_seeded_element_det_row c_seeded_element_det%rowtype;
v_formula_id  number(9);
Skip_formula Exception;
v_eff_start_date date;
v_eff_end_date date;
v_element_entry_id pay_element_entry_values_f.element_entry_value_id%type;
--6666135 End
BEGIN
   -- setting the contexts
   p_inputs(1).name   := 'ASSIGNMENT_ID';
   p_inputs(1).value  := p_assignment_id;
   p_inputs(2).name   := 'DATE_EARNED';
   p_inputs(2).value  := fnd_date.date_to_canonical(p_effective_date);
   p_inputs(3).name   := 'BUSINESS_GROUP_ID';
   p_inputs(3).value  := p_business_group_id;
   p_inputs(4).name   := 'PAYROLL_ID';
   p_inputs(4).value  := p_payroll_id;
   OPEN c_action_ids(p_assignment_id, p_effective_date);
   FETCH c_action_ids into c_action_ids_row;
   IF c_action_ids_row.ASSIGNMENT_ACTION_ID is not null
   THEN
      p_inputs(5).name   := 'PAYROLL_ACTION_ID';
      p_inputs(5).value  := c_action_ids_row.PAYROLL_ACTION_ID;
      p_inputs(6).name   := 'ASSIGNMENT_ACTION_ID';
      p_inputs(6).value  := c_action_ids_row.ASSIGNMENT_ACTION_ID;
   END IF;
   CLOSE c_action_ids;
   hr_utility.trace(' PAYROLL_ACTION_ID '|| c_action_ids_row.PAYROLL_ACTION_ID);
   hr_utility.trace(' ASSIGNMENT_ACTION_ID '||c_action_ids_row.ASSIGNMENT_ACTION_ID);
   hr_utility.trace(' p_assignment_id '||p_assignment_id);
   hr_utility.trace('**Date earned '|| fnd_date.date_to_canonical(p_effective_date));
   hr_utility.trace(' p_payroll_id '||p_payroll_id);

-- 6666135 Begin
FOR I in 1..Formula_Tab.COUNT
LOOP
   v_formula_id := Null;
   hr_utility.trace(' For Formula_Tab '||Formula_Tab(I));
   OPEN c_pqp_formula_id(Formula_Tab(I));
   Fetch c_pqp_formula_id into v_formula_id;
   if c_pqp_formula_id%NOTFOUND then
         hr_utility.set_location('Formula -'||Formula_Tab(I)||'- Not Present/effective in Table',11);
         l_warning_msg := 'Formula -'||Formula_Tab(I)||'- Not Present or effective for Assignment '||p_assignment_number||' On '||p_effective_date;
         fnd_file.put_line (fnd_file.LOG, l_warning_msg);
	 fnd_file.put_line(FND_FILE.OUTPUT, l_warning_msg);
         raise_application_error(-20001,' Invalid Formula ');
   end if;
   Close c_pqp_formula_id;
   if v_formula_id is not null then
   hr_utility.trace(' Inside RUN_USER_FORMULA '||Formula_Tab(I));
   ff_exec.init_formula(v_formula_id, p_effective_date , l_inputs, l_outputs);
--6666135 End
   --Assigning the contexts to the input variables
   IF l_inputs.count > 0 and p_inputs.count > 0
   THEN
      FOR i IN l_inputs.first..l_inputs.last
      LOOP
         FOR j IN p_inputs.first..p_inputs.last
         LOOP
            IF l_inputs(i).name = p_inputs(j).name
            THEN
               l_inputs(i).value := p_inputs(j).value;
            exit;
            END IF;
         END LOOP;
      END LOOP;
   END IF;
      FOR i IN l_inputs.first..l_inputs.last
      LOOP
         hr_utility.trace(' i= '||i||' name '||l_inputs(i).name ||' value '||l_inputs(i).value);
      END LOOP;
   --executing the formula
   ff_exec.run_formula(l_inputs,l_outputs);
   hr_utility.trace(' calculated value from User formula '||l_outputs(1).value);
   fnd_file.put_line(FND_FILE.OUTPUT,' ------ Formula '||Formula_Tab(I)||' value '||l_outputs(1).value);
   n_sum_formula_val := n_sum_formula_val+ nvl(l_outputs(1).value,0);
   End if; --formula id not null check 6666135
END LOOP;
   hr_utility.trace(' Total value from all User formulas '||n_sum_formula_val);
   --IF n_sum_formula_val > 0
   IF (n_sum_formula_val + p_historic_value) >= 0 --For BugFix 8238736
   THEN  --if the formula returns value greater than 0 6666135
   OPEN c_additional_pension(p_assignment_id
                            ,p_effective_date);
   FETCH c_additional_pension INTO c_additional_pension_row;
    IF c_additional_pension%NOTFOUND then
      hr_utility.trace(' Inserting seeded element with value'||n_sum_formula_val);
        OPEN c_seeded_element_det;
        FETCH c_seeded_element_det into c_seeded_element_det_row;
	      if c_seeded_element_det%NOTFOUND then
                hr_utility.set_location(' Seeded Element is not linked ',11);
                l_warning_msg := 'Seeded Element is not linked to the Payroll of Assignment '||p_assignment_number||' On '||p_effective_date;
                fnd_file.put_line (fnd_file.LOG, l_warning_msg);
		Raise Skip_formula;
	      end if;
        CLOSE c_seeded_element_det;
        v_eff_start_date := p_effective_date;

        hr_entry_api.insert_element_entry(
          p_effective_start_date    => v_eff_start_date,
          p_effective_end_date      => v_eff_end_date,
          p_element_entry_id        => v_element_entry_id,
          p_assignment_id           => p_assignment_id,
          p_element_link_id         => c_seeded_element_det_row.element_link_id,
          p_creator_type            => 'F',
          p_entry_type              => 'E',
          p_date_earned             => v_eff_start_date,
          p_input_value_id1         => c_seeded_element_det_row.input_value_id,
          p_entry_value1            => to_char(n_sum_formula_val)
          );
      ELSE
        hr_utility.trace(' calling for correction of seeded element '||n_sum_formula_val);
   --6666135 End
      hr_entry_api.update_element_entry (p_dt_update_mode         =>'CORRECTION',
                                         p_session_date           => p_effective_date,
                                         p_check_for_update       =>'N',
                                         p_creator_type           => 'F',
                                         p_element_entry_id       => c_additional_pension_row.element_entry_id,
                                         p_input_value_id1        => c_additional_pension_row.input_value_id,
                                         p_entry_value1           => n_sum_formula_val --n_pen_value 6666135
                                        );

    END IF;  --Seeded element present or not
    CLOSE c_additional_pension;
   END IF; -- formula returned value greater than zero
   hr_utility.trace(' formula completed');
   return n_sum_formula_val;
Exception
 When Skip_formula then
 --seeded element is not linked to Payroll so skipping
 Null;
 When others then
 hr_utility.trace(sqlerrm);
 Raise;
--6666135 End
END RUN_USER_FORMULA;

PROCEDURE DERIVE_PENSIONABLE_PAY(errbuf out nocopy varchar2,
                                 retcode out nocopy number,
                                 p_effective_start_dt IN varchar2,
                                 p_effective_end_dt IN varchar2,
                                 p_payroll_id IN NUMBER,
                                 p_assignment_set_id IN NUMBER,
                                 p_assignment_number IN varchar2,
                                 p_employee_no IN varchar2,
                                 p_business_group_id IN NUMBER,
                                 p_mode in varchar2 )
IS
--
v_eff_end_date date;
v_given_end_date date;
v_eff_end_date_corr date;
v_eff_start_date_corr date;
v_eff_start_date date;
v_max_date       date;
v_assignment_eff_date   date;
max_future_date  date;
l_mode       varchar2(20);
l_proc       VARCHAR2(61) := g_package || 'DERIVE_PENSIONABLE_PAY';
n_object_version_no number;
l_eff_start_date_op  date;
l_eff_end_date_op    date;
n_prev_assignment_id per_all_assignments_f.assignment_id%type;
l_ELEMENT_NAME  pay_element_types_f.ELEMENT_NAME%TYPE;

-- This cursor will fetch assignment ids
-- based on the payroll id or assignment id or employee number or assignment set id whichever entered by the user

CURSOR c_all_valid_assignment
IS
   SELECT paaf.assignment_id, paaf.assignment_number,
          paaf.payroll_id, MIN(paaf.EFFECTIVE_START_DATE) EFFECTIVE_START_DATE
     FROM per_all_assignments_f paaf,
          per_all_people_f papf,
	  per_assignment_status_types past
    WHERE paaf.business_group_id = p_business_group_id
      AND paaf.payroll_id= nvl(p_payroll_id, paaf.payroll_id)
--      AND paaf.assignment_id = nvl(p_assignment_id, paaf.assignment_id)
      AND paaf.assignment_number = nvl(p_assignment_number, paaf.assignment_number)
      AND paaf.EFFECTIVE_START_DATE <= v_given_end_date
      AND paaf.EFFECTIVE_END_DATE >= v_eff_start_date   --8306612 fetching record which eff end date is = to v_eff_start_date
      AND paaf.person_id = papf.person_id
      AND papf.employee_number = nvl(p_employee_no, papf.employee_number)
      AND past.ASSIGNMENT_STATUS_TYPE_ID = paaf.ASSIGNMENT_STATUS_TYPE_ID
      AND past.PER_SYSTEM_STATUS in ('ACTIVE_ASSIGN','SUSP_ASSIGN', 'TERM_ASSIGN')-- 'TERM_ASSIGN' added for bug 6868115
      --6813970 begin
      /*    Moving Assignment set check from here, so that both types of Assignment set can be processed.
      AND (p_assignment_set_id IS NULL -- don't check for assignment set in this case
      OR EXISTS (SELECT 1 FROM hr_assignment_sets has1
                  WHERE has1.assignment_set_id = p_assignment_set_id
                    AND has1.business_group_id = paaf.business_group_id
                    AND nvl(has1.payroll_id, paaf.payroll_id) = paaf.payroll_id
                    AND (NOT EXISTS (SELECT 1 -- chk no amendmts
                                     FROM hr_assignment_set_amendments hasa1
                                     WHERE hasa1.assignment_set_id =
                                               has1.assignment_set_id)
                         OR EXISTS (SELECT 1 -- chk include amendmts
                                    FROM hr_assignment_set_amendments hasa2
                                    WHERE hasa2.assignment_set_id =
                                               has1.assignment_set_id
                                    AND hasa2.assignment_id = paaf.assignment_id
                                    AND nvl(hasa2.include_or_exclude,'I') = 'I')
                         OR (NOT EXISTS (SELECT 1 --chk no exlude amendmts
                                    FROM hr_assignment_set_amendments hasa3
                                    WHERE hasa3.assignment_set_id =
                                               has1.assignment_set_id
                                    AND hasa3.assignment_id = paaf.assignment_id
                                    AND nvl(hasa3.include_or_exclude,'I') = 'E')
                             AND NOT EXISTS (SELECT 1 --and chk no Inc amendmts
                                    FROM hr_assignment_set_amendments hasa4
                                    WHERE hasa4.assignment_set_id =
                                               has1.assignment_set_id
                                    AND nvl(hasa4.include_or_exclude,'I') = 'I')   ) -- end checking exclude amendmts
                         ) -- done checking amendments
                    ) -- done asg set check when not null
           ) -- end of asg set check
       6813970 end */
        GROUP BY assignment_id, assignment_number, payroll_id
	ORDER BY assignment_id, EFFECTIVE_START_DATE;

--6666135 Begin
--This cursor will fetch the formual and element details from the Configuration value
cursor c_pqp_formula_element_det
is
  select distinct PCV_INFORMATION1
    From pqp_configuration_values
   where pcv_information_category = 'PQP_GB_LGPS_FF_INFO'
   AND business_group_id=p_business_group_id; --New business group specific Condition is added in this cursor for bug 6856733

--6666135 End

--This cursor will check for the presence of assignments in pqp_assignment_attributes_f table
CURSOR c_pqp_assignment(n_assignment_id NUMBER)
IS
   SELECT pqpaaf.lgps_process_flag,
          pqpaaf.assignment_attribute_id,
          pqpaaf.EFFECTIVE_START_DATE,
          pqpaaf.object_version_number
     FROM pqp_assignment_attributes_f pqpaaf
    WHERE pqpaaf.assignment_id = n_assignment_id
      AND pqpaaf.business_group_id = p_business_group_id
      AND nvl(pqpaaf.lgps_process_flag,'Nul') = nvl(l_mode,nvl(pqpaaf.lgps_process_flag,'Nul'))  --l_mode will have value only in case of Incomplete and reprocess
      AND ( v_assignment_eff_date between pqpaaf.EFFECTIVE_START_DATE and pqpaaf.EFFECTIVE_END_DATE
            OR pqpaaf.EFFECTIVE_START_DATE = (select min(EFFECTIVE_START_DATE) from pqp_assignment_attributes_f where assignment_id = n_assignment_id
	      AND lgps_process_flag = nvl(l_mode,lgps_process_flag) AND business_group_id = p_business_group_id
              AND EFFECTIVE_START_DATE BETWEEN v_assignment_eff_date AND v_eff_end_date));

--This cursor will fetch the all elements for the assigment
CURSOR c1_all_element(n_assignment_id NUMBER)
IS
   SELECT peef.ELEMENT_TYPE_ID,petf.ELEMENT_NAME
     FROM pay_element_entries_f peef, pay_element_types_f petf
    WHERE peef.ASSIGNMENT_ID=n_assignment_id
    AND peef.ELEMENT_TYPE_ID = petf.ELEMENT_TYPE_ID
    AND petf.business_group_id = p_business_group_id
    AND v_assignment_eff_date between peef.EFFECTIVE_START_DATE and peef.EFFECTIVE_END_DATE
    AND v_assignment_eff_date between petf.EFFECTIVE_START_DATE and petf.EFFECTIVE_END_DATE;
--6666135 End

--For the element to get processed by pqp_rates_history_calc.get_historic_rate two rows should be present
--One row with data PQP_UK_RATE_TYPE and PQP_LGPS_PENSION_PAY
--and second row with PQP_UK_ELEMENT_ATTRIBUTION and Pay Value.
-- --7369484 Begin Cursor including Scottish LGPS Rate Type
CURSOR c2_PQP_UK_RATE_TYPE(n_element_type_id NUMBER)
IS
  SELECT pet.EEI_INFORMATION1
    FROM pay_element_type_extra_info pet
   WHERE pet.element_type_id = n_element_type_id
     AND pet.INFORMATION_TYPE = 'PQP_UK_RATE_TYPE'
 --    AND pet.EEI_INFORMATION1 = 'PQP_LGPS_PENSION_PAY';
     AND pet.EEI_INFORMATION1 in ('PQP_LGPS_SCOTLAND_PENSION_PAY','PQP_LGPS_PENSION_PAY');
 -- --7369484 End

CURSOR c3_pqp_lgps_pension_pay(n_element_type_id NUMBER)
IS
  SELECT 1
    FROM pay_element_type_extra_info pet
   WHERE pet.element_type_id = n_element_type_id
     AND pet.INFORMATION_TYPE = 'PQP_UK_ELEMENT_ATTRIBUTION';


--This cursor to check the future date track records in pqp_assignment_attributes_f
CURSOR c_future_date(n_assignment_id NUMBER)
IS
  SELECT max(EFFECTIVE_START_DATE)
    FROM pqp_assignment_attributes_f pqpaaf
   WHERE pqpaaf.assignment_id = n_assignment_id
   AND pqpaaf.business_group_id = p_business_group_id;
--
--This cursor to correct the entries till the end date
CURSOR c_correct_pqp(n_assignment_id NUMBER)
IS
  SELECT ASSIGNMENT_ATTRIBUTE_ID, EFFECTIVE_START_DATE, EFFECTIVE_END_DATE, object_version_number
    FROM pqp_assignment_attributes_f pqpaaf
   WHERE pqpaaf.assignment_id = n_assignment_id
   and pqpaaf.business_group_id = p_business_group_id
   and pqpaaf.EFFECTIVE_START_DATE > v_max_date
--   and pqpaaf.EFFECTIVE_START_DATE between v_eff_start_date and v_eff_end_date_corr;
   and pqpaaf.EFFECTIVE_START_DATE between v_assignment_eff_date and v_eff_end_date_corr;

--

c1_all_element_data c1_all_element%rowtype;
c2_PQP_UK_RATE_TYPE_data c2_PQP_UK_RATE_TYPE%rowtype;
c3_pqp_lgps_pension_pay_data c3_pqp_lgps_pension_pay%rowtype;
--c_formula_pension_value pay_element_entry_values_f.SCREEN_ENTRY_VALUE%type;
c_formula_pension_value number;
v_mode         varchar2(30);
N_start_year   NUMBER;
n_present      number;
b_rate_type           boolean;
b_element_present     boolean;
b_input_value_present boolean;
l_lgps_process_flag      pqp_assignment_attributes_f.lgps_process_flag%type;
--l_lgps_pensionable_pay   pqp_assignment_attributes_f.lgps_pensionable_pay%type;
l_lgps_pensionable_pay number;
b_pqp_assignment_found boolean;
b_pqp_found           boolean;
c_pqp_assignment_row c_pqp_assignment%rowtype;
skip_assignment       Exception;
skip_element          Exception;
l_assignment_attribute_id number;
--7369484 Begin
b_scot_rate	          boolean;
b_eng_rate		    boolean;
--7369484 End
--6813970 begin

l_formula_id          NUMBER;
l_tab_asg_set_amnds   pqp_budget_maintenance.t_asg_set_amnds;
l_include_flag        VARCHAR2(10);

--6813970 end

-- main
BEGIN
--   hr_utility.trace_on(null,'gag');
   hr_utility.set_location('Entering: ' || l_proc, 10);
  BEGIN
     insert into fnd_sessions (SESSION_ID, EFFECTIVE_DATE)
     values(userenv('sessionid'), trunc(SYSDATE));
   EXCEPTION
    WHEN others THEN
    hr_utility.trace('SESSION ALREADY EXISTS :'|| sqlerrm);
    Raise;
   END;
   v_eff_start_date := fnd_date.canonical_to_date(p_effective_start_dt);
     --calculation of pension end date for the year
      N_start_year := TO_NUMBER(TO_CHAR(v_eff_start_date,'YYYY'));
      IF trunc(v_eff_start_date) > TO_DATE('31-03-'||N_start_year,'DD-MM-YYYY')
      THEN
         N_start_year := N_start_year+1;
      END IF;
      v_eff_end_date := TO_DATE('31-03-'||N_start_year,'DD-MM-YYYY');
   v_given_end_date := v_eff_end_date;
   IF p_effective_end_dt IS not NULL --to date entered by the user.
   THEN
      v_given_end_date := fnd_date.canonical_to_date(p_effective_end_dt);
      --To check the given dates falls in the same pension year
      IF ((v_eff_start_date BETWEEN to_date('01/04/'||to_char(v_eff_start_date,'YYYY'),'dd/mm/yyyy')
         AND to_date('31/12/'||to_char(v_eff_start_date,'YYYY'),'dd/mm/yyyy'))
         AND (v_eff_end_date BETWEEN to_date('01/04/'||to_char(v_eff_start_date,'YYYY'),'dd/mm/yyyy')
         AND to_date('31/03/'||to_char(to_number(to_char(v_eff_start_date,'YYYY'))+1),'dd/mm/yyyy')))
      OR ((v_eff_start_date BETWEEN to_date('01/01/'||to_char(v_eff_start_date,'YYYY'),'dd/mm/yyyy')
         AND to_date('31/03/'||to_char(v_eff_start_date,'YYYY'),'dd/mm/yyyy'))
         AND (v_eff_end_date BETWEEN to_date('01/01/'||to_char(v_eff_start_date,'YYYY'),'dd/mm/yyyy')
         AND to_date('31/03/'||to_char(v_eff_start_date,'YYYY'),'dd/mm/yyyy')))
      THEN
         hr_utility.set_location('Start date and End date are in the same pension year ',6);
      ELSE
         fnd_file.put_line (fnd_file.LOG, 'Start date and End date should fall in the same pension year.');
         hr_utility.set_location('Start date and End date should fall in the same tax year',8);
         v_eff_start_date := Null; -- to exit the program
      END IF;
   END IF;
--6813970 begin
--Check for Assignment set
  If p_assignment_set_id is not null then
	 pqp_budget_maintenance.get_asg_set_details(p_assignment_set_id      => p_assignment_set_id
                            ,p_formula_id             => l_formula_id
                            ,p_tab_asg_set_amnds      => l_tab_asg_set_amnds
                            );
         If l_formula_id is null and l_tab_asg_set_amnds.count = 0 then
         fnd_file.put_line (fnd_file.LOG, ' Assignment set id entered '||p_assignment_set_id||' is not valid');
	 v_eff_start_date := Null; -- to exit the program
	 end if;
  End if;
--6813970 end
--6666135  Begin
--Fetching formula details
    j_formula_count := 0;
    For I in c_pqp_formula_element_det
    loop
     j_formula_count := j_formula_count+1;
    Formula_Element_Tab(j_formula_count).Element_name := substr(I.PCV_INFORMATION1,1,instr(I.PCV_INFORMATION1,'|')-1);
    Formula_Element_Tab(j_formula_count).Formula_name := substr(I.PCV_INFORMATION1,instr(I.PCV_INFORMATION1,'|')+1);
    hr_utility.trace(' Element_name '||j_formula_count|| Formula_Element_Tab(j_formula_count).Element_name);
    hr_utility.trace(' Formula_name '||j_formula_count|| Formula_Element_Tab(j_formula_count).Formula_name);
    end loop;
--6666135  End

  v_eff_end_date_corr := v_eff_end_date;
   hr_utility.set_location('Effective Start Date: ' || p_effective_start_dt,1);
   hr_utility.set_location('Effective End Date: ' || p_effective_end_dt,2);
   hr_utility.set_location('Calculated End Date: ' || v_eff_end_date_corr, 3);
   hr_utility.set_location('Calculated Start Date: ' || v_eff_start_date,   3);
   hr_utility.set_location('p_assignment_set_id: ' || p_assignment_set_id, 3);
   hr_utility.set_location('p_assignment_number: ' || p_assignment_number, 3);
   hr_utility.set_location('p_employee_no: ' || p_employee_no, 3);
   hr_utility.set_location('p_payroll_id: ' || p_payroll_id, 3);
   hr_utility.set_location('p_business_group_id: ' || p_business_group_id, 3);
   hr_utility.set_location('p_mode: ' || p_mode, 3);
   IF p_mode = 'Reprocess'
   THEN
      l_mode := 'Y';
   ELSIF p_mode = 'Incomplete'
   THEN
      l_mode := 'I';
   END IF;
   --
   hr_utility.set_location('l_mode: ' || l_mode, 3);
   FOR c_all_assignments in c_all_valid_assignment
   LOOP
   Begin
      hr_utility.set_location('Inside valid Assignments'||c_all_assignments.assignment_id,20);

      if  nvl(n_prev_assignment_id,'0.000') = c_all_assignments.assignment_id then
	      raise skip_assignment;
      end if;



      n_prev_assignment_id	 := c_all_assignments.assignment_id;
      l_lgps_pensionable_pay     := NULL;
      c_formula_pension_value    := NULL;
      b_element_present          := FALSE;
      b_rate_type                := FALSE;
	--7369484 Begin
	b_scot_rate		         := FALSE;
	b_eng_rate			   := FALSE;
	--7369484 End
      b_input_value_present      := FALSE;
      b_pqp_found                := NULL;
      b_pqp_assignment_found     := NULL;
      c_pqp_assignment_row       := NULL;
      v_assignment_eff_date      := NULL;
      max_future_date            := NULL;
      Formula_Tab                := Formula_Tab_new;  --6666135
      k_aasgn_form_count         := 0;		      --6666135

     v_assignment_eff_date := Greatest(c_all_assignments.EFFECTIVE_START_DATE,v_eff_start_date);

      --6813970 begin
       l_include_flag := 'N';
	 If p_assignment_set_id is not null then
		l_include_flag  :=  pqp_budget_maintenance.chk_is_asg_in_asg_set(p_assignment_id               => c_all_assignments.assignment_id
		                                    ,p_formula_id             => l_formula_id
						    ,p_tab_asg_set_amnds      => l_tab_asg_set_amnds
						    ,p_effective_date         => v_assignment_eff_date
                                    );
			if l_include_flag = 'N' then
				raise skip_assignment;
			end if;

	 end if;
      --6813970 end

    OPEN c_future_date(c_all_assignments.assignment_id);
    FETCH c_future_date into max_future_date;
    IF max_future_date is not NULL THEN
    b_pqp_found := TRUE;
    END IF;
    CLOSE c_future_date;

    IF b_pqp_found THEN
        OPEN c_pqp_assignment(c_all_assignments.assignment_id);
        FETCH c_pqp_assignment INTO c_pqp_assignment_row;
        IF c_pqp_assignment%found
        then
            b_pqp_assignment_found := TRUE;
        END IF;
        CLOSE c_pqp_assignment;
        IF b_pqp_assignment_found THEN
	  IF ((p_mode = 'Start of the Year' and nvl(c_pqp_assignment_row.lgps_process_flag,'Y') in ('Y','P','I','U'))
                or l_mode in ('Y','I')
		or nvl(c_pqp_assignment_row.lgps_process_flag,'New Hires') = p_mode) THEN
          v_max_date                 := Greatest(c_pqp_assignment_row.EFFECTIVE_START_DATE, v_eff_start_date);
          n_object_version_no        := c_pqp_assignment_row.object_version_number;
	  ElSE
             Raise skip_assignment;
          END IF;

       v_assignment_eff_date      := Greatest(c_pqp_assignment_row.EFFECTIVE_START_DATE, v_assignment_eff_date);
       END IF;
     END IF;

    IF b_pqp_assignment_found is NULL AND l_mode is not null THEN
      --No records in PQP_ASSIGNMENT_ATTRIBUTES_F table matching mode - reprocess or incomplete.
      raise skip_assignment;
    END IF;

      OPEN c1_all_element(c_all_assignments.assignment_id);
      LOOP
         BEGIN
            hr_utility.set_location('Inside valid Elements for the Assignment'||c_all_assignments.assignment_id,20);
            FETCH c1_all_element into c1_all_element_data;
            IF c1_all_element%NOTFOUND
            THEN
               CLOSE c1_all_element;
               EXIT;
            END IF;
            hr_utility.set_location('Checking for Historic rate type',25);
            b_element_present := TRUE;

	    l_ELEMENT_NAME := null;

	    --6666135 Begin
                FOR F in 1..j_formula_count
                loop
                 if Formula_Element_Tab(F).Element_name = c1_all_element_data.Element_name then
                    k_aasgn_form_count := k_aasgn_form_count+1;
                    Formula_Tab(k_aasgn_form_count) := Formula_Element_Tab(F).Formula_name;
		    l_ELEMENT_NAME := c1_all_element_data.Element_name;
                 End if;
                End loop;
            --6666135 End

            --To Check the values PQP_UK_RATE_TYPE, PQP_LGPS_PENSION_PAY, INPUT_VALUE AND PAY VALUE in pay_element_type_extra_info
            OPEN c2_PQP_UK_RATE_TYPE(c1_all_element_data.element_type_id);
            FETCH c2_PQP_UK_RATE_TYPE INTO c2_PQP_UK_RATE_TYPE_data;
            IF c2_PQP_UK_RATE_TYPE%NOTFOUND
            THEN
              CLOSE c2_PQP_UK_RATE_TYPE;
              RAISE skip_element;
            END IF;
		-- 7369484 Begin
		IF c2_PQP_UK_RATE_TYPE_data.EEI_INFORMATION1 = 'PQP_LGPS_SCOTLAND_PENSION_PAY'
            THEN
	      b_scot_rate := TRUE;
		IF b_eng_rate = TRUE
		THEN
		fnd_file.put_line (fnd_file.LOG,'Assignment can not have both Types of RATE TYPE attached. Assignment Number : '||c_all_assignments.assignment_number);
            CLOSE c1_all_element;
		CLOSE c2_PQP_UK_RATE_TYPE;
		RAISE skip_assignment;
		END IF;
            ELSIF c2_PQP_UK_RATE_TYPE_data.EEI_INFORMATION1 = 'PQP_LGPS_PENSION_PAY'
           THEN
	      --7369484 End
           hr_utility.set_location('Historic Rate Type present for Element '||c1_all_element_data.element_type_id,26);
	     -- 7369484 Begin
           b_rate_type := TRUE;
	     b_eng_rate  := TRUE;
	     IF b_scot_rate = TRUE
	     THEN
              fnd_file.put_line (fnd_file.LOG,'Assignment can not have both Types of RATE TYPE attached. Assignment Number : '||c_all_assignments.assignment_number);
              CLOSE c1_all_element;
		  CLOSE c2_PQP_UK_RATE_TYPE;
		  RAISE skip_assignment;
	     END IF;
	    END IF; -- 7369484 end if rate type id =  Scottish rate type
           OPEN c3_pqp_lgps_pension_pay(c1_all_element_data.element_type_id);
           FETCH c3_pqp_lgps_pension_pay INTO c3_pqp_lgps_pension_pay_data;
           IF c3_pqp_lgps_pension_pay%NOTFOUND
           THEN
              hr_utility.set_location('Pay Value Not Present',27);
	      IF l_ELEMENT_NAME IS NULL THEN
              l_warning_msg := 'PQP_LGPS_MISSING_HISTORIC_RATE_INFO: Historic Rate - Element Attribution information missing for Element  '||c1_all_element_data.Element_name||' in Assignment '||c_all_assignments.assignment_number;
              fnd_file.put_line (fnd_file.LOG, l_warning_msg);
	      END IF;
           ELSE
              b_input_value_present := TRUE;
              hr_utility.set_location('Pay Value Present',28);
           END IF;
          CLOSE c2_PQP_UK_RATE_TYPE;
          CLOSE c3_pqp_lgps_pension_pay;
          EXCEPTION
          WHEN skip_element THEN
          NULL;
        END;
    END LOOP; --loop for all elements in a assignment

  IF b_scot_rate = TRUE
  THEN
   raise skip_assignment;
  END IF;

    IF b_pqp_found THEN
        IF b_pqp_assignment_found THEN
          IF c_pqp_assignment_row.EFFECTIVE_START_DATE = v_assignment_eff_date
          THEN
          v_mode := 'CORRECTION';
          ELSIF v_max_date < max_future_date
          THEN
          v_mode := 'UPDATE_CHANGE_INSERT';
          ELSE
          v_mode := 'UPDATE';
          END IF;
          hr_utility.set_location('Mode for update v_mode: ' || v_mode, 3);
--6813970 begin
--        IF (not b_element_present) or (not b_rate_type)
--	  THEN
--        l_warning_msg := 'PQP_LGPS_MISSING_RATE_INFO: Historic Rate - Rate Type "LGPS Pensionable Pay" not set for elements against Assignment '||c_all_assignments.assignment_number;
          IF ((not b_element_present) or (not b_rate_type)) and k_aasgn_form_count = 0
          THEN
	   l_warning_msg := 'PQP_LGPS_MISSING_RATE_INFO: Neither Historic Rate - Rate Type "LGPS Pensionable Pay" nor User defined formula set for elements against Assignment '||c_all_assignments.assignment_number;
--6813970 end
           fnd_file.put_line (fnd_file.LOG, l_warning_msg);
           l_lgps_process_flag := 'I';
           hr_utility.set_location('Calling API to update LGPS Process Flag I',35);
           pqp_aat_api.update_assignment_attribute
             (p_validate                 => false
             ,p_effective_date           => v_assignment_eff_date  --v_eff_start_date
             ,p_datetrack_mode           => v_mode
             ,p_assignment_attribute_id  => c_pqp_assignment_row.assignment_attribute_id
             ,p_business_group_id        => p_business_group_id
             ,p_effective_start_date     => v_max_date
             ,p_effective_end_date       => v_eff_end_date
             ,p_assignment_id            => c_all_assignments.assignment_id
             ,p_object_version_number    => n_object_version_no
             ,p_lgps_process_flag       => l_lgps_process_flag
             );
             ---******************
             FOR K IN c_correct_pqp(c_all_assignments.assignment_id)
             LOOP
             n_object_version_no := K.object_version_number;
             v_eff_start_date_corr := K.EFFECTIVE_START_DATE;
              pqp_aat_api.update_assignment_attribute
                (p_validate                 => false
                ,p_effective_date           => v_eff_start_date_corr
                ,p_datetrack_mode           => 'CORRECTION'
                ,p_assignment_attribute_id  => K.assignment_attribute_id
                ,p_business_group_id        => p_business_group_id
                ,p_effective_start_date     => K.EFFECTIVE_START_DATE
                ,p_effective_end_date       => K.EFFECTIVE_END_DATE
                ,p_assignment_id            => c_all_assignments.assignment_id
                ,p_object_version_number    => n_object_version_no
                ,p_lgps_process_flag       => l_lgps_process_flag
                );
               END LOOP;
             raise skip_assignment;
          END IF;
          ----------
        ELSE
	    IF l_mode is null then
	        l_warning_msg := 'Cannot process Assignment : '||c_all_assignments.assignment_number||' Future changes present in table pqp_assignment_attributes_f ';
	        fnd_file.put_line (fnd_file.LOG, l_warning_msg);
	    END IF;
        raise skip_assignment;
        END IF; --b_pqp_assignment_found

      ELSIF p_mode = 'New Hires' then --insert
      --NO CURRENT RECORD IN pqp SO INSERT A RECORD WITH CP START DATE
--6813970 begin
--       IF (not b_element_present) or (not b_rate_type)
--        THEN
--        l_warning_msg := 'PQP_LGPS_MISSING_RATE_INFO: Historic Rate - Rate Type "LGPS Pensionable Pay" not set for elements against Assignment '||c_all_assignments.assignment_number;

        IF ((not b_element_present) or (not b_rate_type)) and k_aasgn_form_count = 0
        THEN
        l_warning_msg := 'PQP_LGPS_MISSING_RATE_INFO: Neither Historic Rate - Rate Type "LGPS Pensionable Pay" nor User defined formula set for elements against Assignment '||c_all_assignments.assignment_number;
--6813970 end
          fnd_file.put_line (fnd_file.LOG, l_warning_msg);
          l_lgps_process_flag := 'I';
          hr_utility.set_location('Calling API to insert LGPS Process Flag I',355);
          pqp_aat_api.create_assignment_attribute
            (p_effective_date => v_assignment_eff_date
            ,p_business_group_id => p_business_group_id
            ,p_assignment_id => c_all_assignments.assignment_id
            ,p_assignment_attribute_id => l_assignment_attribute_id
            ,p_object_version_number => n_object_version_no
            ,p_effective_start_date => l_eff_start_date_op
            ,p_effective_end_date => l_eff_end_date_op
            ,p_lgps_process_flag  => l_lgps_process_flag
            );
          raise skip_assignment;
        END IF;

    END IF; --    b_pqp_found

--6813970 begin
--    IF (b_element_present and b_input_value_present)
--    THEN
    IF (b_rate_type and b_input_value_present)
    THEN
--6813970 end
	Begin
	       l_lgps_pensionable_pay:=pqp_rates_history_calc.get_historic_rate(p_assignment_id        => c_all_assignments.assignment_id
                                                                       ,p_rate_name            => 'LGPS Pensionable Pay'
                                                                       ,p_effective_date       => v_assignment_eff_date  --v_eff_start_date
                                                                       ,p_time_dimension       => 'A'
                                                                       ,p_rate_type_or_element => 'R');
	Exception
	when others then
        l_warning_msg := 'Cannot process Assignment : '||c_all_assignments.assignment_number||' Historic Rate calculations failed. Please check the error message ';
        fnd_file.put_line (fnd_file.LOG, l_warning_msg);
        fnd_file.put_line (fnd_file.LOG,'*** -ERROR- '||SQLCODE||' - '||SQLERRM);
        b_rate_type  := FALSE; --to skip processing of user defined formulae
	k_aasgn_form_count := 0; --to skip processing of user defined formulae --6813970
        b_input_value_present := FALSE; --to make the LGPS process flag as Incomplete.
	End;
    END IF;
     hr_utility.set_location('Calculated Pensionable Pay'||l_lgps_pensionable_pay,40);

---- To calculate the value from user defined formula and add it to the value from historic rates function
--6813970 begin
--    IF b_rate_type
--    THEN
    IF b_rate_type or k_aasgn_form_count > 0
    THEN  -- Rate type defined for atleast one element
--6813970 end
        IF b_input_value_present or k_aasgn_form_count > 0 then  -- if b_input_value_present is true then Historic rates funciton will return value;  if k_aasgn_form_count > 0 means user defined formula is attached
            fnd_file.put_line(FND_FILE.OUTPUT, ' Assignment  '||c_all_assignments.assignment_number ||' Historic rate value '||nvl(l_lgps_pensionable_pay,0));
        END IF;
       IF k_aasgn_form_count > 0 then

		hr_utility.set_location(' Calling RUN_USER_FORMULA ',25);
	       -- Call the formula to calculate the additional pension pay
	       /* Bug fix 8238736 Start
               c_formula_pension_value := RUN_USER_FORMULA(c_all_assignments.assignment_id , v_assignment_eff_date , p_business_group_id , c_all_assignments.payroll_id, Formula_Tab , c_all_assignments.assignment_number);
               */
               c_formula_pension_value := RUN_USER_FORMULA(c_all_assignments.assignment_id , v_assignment_eff_date , p_business_group_id , c_all_assignments.payroll_id, Formula_Tab , c_all_assignments.assignment_number, nvl(l_lgps_pensionable_pay,0));
               -- Bug fix 8238736 End
	       hr_utility.set_location(' formula returned value '||c_formula_pension_value,40);

	       --IF nvl(c_formula_pension_value,0) >= 0 -- equal to condition is added for bug 6857280
               IF ( (nvl(c_formula_pension_value,0) + NVL(l_lgps_pensionable_pay,0)) >=0 ) -- BugFix 8238736
	       THEN
	          l_lgps_pensionable_pay := NVL(l_lgps_pensionable_pay,0) + c_formula_pension_value;
	       END IF;
	       hr_utility.set_location('After adding additional Pension Value'||l_lgps_pensionable_pay,42);

      END IF;   --check for presence of formula in configuration value screen

          IF  c_formula_pension_value is not null or l_lgps_pensionable_pay is not null
          THEN
 	     l_lgps_pensionable_pay := round(l_lgps_pensionable_pay,2);
	     fnd_file.put_line(FND_FILE.OUTPUT, '-----------------------------Total value '||nvl(l_lgps_pensionable_pay,0));
             l_lgps_process_flag := 'P';
             IF b_pqp_found
	     THEN
                hr_utility.trace(' updating the Contractual pay for effective date '||v_max_date|| ' mode '||v_mode||' OVN '||n_object_version_no);
                pqp_aat_api.update_assignment_attribute
                    (p_validate            => false
                    ,p_effective_date        => v_assignment_eff_date  --v_eff_start_date
                    ,p_datetrack_mode        => v_mode
                    ,p_assignment_attribute_id    => c_pqp_assignment_row.assignment_attribute_id
                    ,p_business_group_id    => p_business_group_id
                    ,p_effective_start_date    => v_max_date
                    ,p_effective_end_date    => v_eff_end_date
                    ,p_assignment_id        => c_all_assignments.assignment_id
                    ,p_object_version_number    => n_object_version_no
                    ,p_lgps_process_flag          => l_lgps_process_flag
                    ,p_lgps_pensionable_pay       => l_lgps_pensionable_pay
                    );

                FOR K IN c_correct_pqp(c_all_assignments.assignment_id)
                LOOP
                n_object_version_no := K.object_version_number;
                v_eff_start_date_corr := K.EFFECTIVE_START_DATE;
                  pqp_aat_api.update_assignment_attribute
                    (p_validate                 => false
                    ,p_effective_date           => v_eff_start_date_corr
                    ,p_datetrack_mode           => 'CORRECTION'
                    ,p_assignment_attribute_id  => K.assignment_attribute_id
                    ,p_business_group_id        => p_business_group_id
                    ,p_effective_start_date     => K.EFFECTIVE_START_DATE
                    ,p_effective_end_date       => K.EFFECTIVE_END_DATE
                    ,p_assignment_id            => c_all_assignments.assignment_id
                    ,p_object_version_number    => n_object_version_no
                    ,p_lgps_process_flag       => l_lgps_process_flag
                    ,p_lgps_pensionable_pay       => l_lgps_pensionable_pay
                    );
                END LOOP;

             Else
                hr_utility.set_location('Inserting the Contractual pay for effective date'||v_assignment_eff_date,555);
                pqp_aat_api.create_assignment_attribute
                  (p_effective_date => v_assignment_eff_date
                  ,p_business_group_id => p_business_group_id
                  ,p_assignment_id => c_all_assignments.assignment_id
                  ,p_assignment_attribute_id => l_assignment_attribute_id
                  ,p_object_version_number => n_object_version_no
                  ,p_effective_start_date => l_eff_start_date_op
                  ,p_effective_end_date   => l_eff_end_date_op
                  ,p_lgps_process_flag    => l_lgps_process_flag
                  ,p_lgps_pensionable_pay       => l_lgps_pensionable_pay
                  );
              END IF;  --   b_pqp_found
          END IF; -- check for l_lgps_pensionable_pay
	  hr_utility.set_location('After updating Process flag to P'||c_all_assignments.assignment_id,45);
	  Raise skip_assignment;
    END IF; --rate type entered


        IF b_pqp_found THEN
            IF (not b_input_value_present)
            THEN
              l_lgps_process_flag := 'I';
              hr_utility.set_location('Calling API to update LGPS Process Flag I',30);
              pqp_aat_api.update_assignment_attribute
                (p_validate                => false
                ,p_effective_date          => v_assignment_eff_date  --v_eff_start_date
                ,p_datetrack_mode          => v_mode
                ,p_assignment_attribute_id => c_pqp_assignment_row.assignment_attribute_id
                ,p_business_group_id       => p_business_group_id
                ,p_effective_start_date    => v_max_date
                ,p_effective_end_date      => v_eff_end_date
                ,p_assignment_id           => c_all_assignments.assignment_id
                ,p_object_version_number   => n_object_version_no
                ,p_lgps_process_flag       => l_lgps_process_flag
                );

               FOR K IN c_correct_pqp(c_all_assignments.assignment_id)
                LOOP
                n_object_version_no := K.object_version_number;
                v_eff_start_date_corr :=  K.EFFECTIVE_START_DATE;
                  pqp_aat_api.update_assignment_attribute
                    (p_validate                 => false
                    ,p_effective_date           => v_eff_start_date_corr
                    ,p_datetrack_mode           => 'CORRECTION'
                    ,p_assignment_attribute_id  => K.assignment_attribute_id
                    ,p_business_group_id        => p_business_group_id
                    ,p_effective_start_date     => K.EFFECTIVE_START_DATE
                    ,p_effective_end_date       => K.EFFECTIVE_END_DATE
                    ,p_assignment_id            => c_all_assignments.assignment_id
                    ,p_object_version_number    => n_object_version_no
                    ,p_lgps_process_flag       => l_lgps_process_flag
                    );
                END LOOP;
            END IF;
        Else
          IF (not b_input_value_present)
          THEN
            l_lgps_process_flag := 'I';
            hr_utility.set_location('Calling API to insert LGPS Process Flag I',305);
            pqp_aat_api.create_assignment_attribute
              (p_effective_date => v_assignment_eff_date
              ,p_business_group_id => p_business_group_id
              ,p_assignment_id => c_all_assignments.assignment_id
              ,p_assignment_attribute_id => l_assignment_attribute_id
              ,p_object_version_number => n_object_version_no
              ,p_effective_start_date => l_eff_start_date_op
              ,p_effective_end_date   => l_eff_end_date_op
              ,p_lgps_process_flag    => l_lgps_process_flag
              );
          END IF;
        END IF;

  Exception
     when skip_assignment then
     hr_utility.set_location('Skipped Assignment'||c_all_assignments.assignment_id,45);
  END;
  END LOOP; --loop for all valid assignments
COMMIT;
 hr_utility.set_location('Leaving: ' || l_proc, 100);
END DERIVE_PENSIONABLE_PAY;
---------------------------------------------------------------------
/* This section of code is ued by the formula functions
   which inturn will be call from the pension element fast formula  */
---------------------------------------------------------------------
-- To fetch the Transitional flag for the assignment
FUNCTION GET_PQP_LGPS_TRANSITIONAL_FLAG(p_assignment_id IN NUMBER,
                                        p_effective_date Date,
					p_business_group_id NUMBER)
RETURN VARCHAR2
IS
   v_trans_flag varchar2(30);
   CURSOR C_Transtional_Flag
   IS
     SELECT LGPS_TRANS_ARRANG_FLAG
       FROM pqp_assignment_attributes_f pqaaf
      WHERE pqaaf.assignment_id = p_assignment_id
        AND pqaaf.business_group_id = p_business_group_id
        AND p_effective_date between pqaaf.effective_start_date and pqaaf.effective_end_date;
BEGIN
   OPEN C_Transtional_Flag;
   FETCH C_Transtional_Flag INTO v_trans_flag;
   CLOSE C_Transtional_Flag;
   return v_trans_flag;
END GET_PQP_LGPS_TRANSITIONAL_FLAG;
-- To fetch the Contractual pay for the assignment
FUNCTION GET_PQP_LGPS_PENSION_PAY(p_assignment_id IN NUMBER,
                                  p_effective_date Date,
	  			  p_business_group_id NUMBER)
RETURN number
IS
   n_lgps_pension_pay pqp_assignment_attributes_f.LGPS_PENSIONABLE_PAY%type;
   CURSOR c_pension_pay
   IS
     SELECT nvl(LGPS_PENSIONABLE_PAY,-1)
       FROM pqp_assignment_attributes_f pqaaf
      WHERE pqaaf.assignment_id = p_assignment_id
        AND pqaaf.business_group_id = p_business_group_id
        AND p_effective_date between pqaaf.effective_start_date and pqaaf.effective_end_date;
BEGIN
  OPEN c_pension_pay;
  FETCH c_pension_pay INTO n_lgps_pension_pay;
  CLOSE c_pension_pay;
  RETURN n_lgps_pension_pay;
END GET_PQP_LGPS_PENSION_PAY;

-- To fetch the current Pension Financial year
FUNCTION GET_FINANCIAL_YEAR(p_effective_date Date)
RETURN NUMBER IS
n_year NUMBER;
n_date DATE;
BEGIN
IF p_effective_date between to_date('01-04-'||to_char(p_effective_date,'YYYY'),'DD-MM-YYYY') and to_date('31-12-'||to_char(p_effective_date,'YYYY'),'DD-MM-YYYY')
THEN
   n_year := to_number(to_char(p_effective_date,'yyyy'));
ELSE
   n_year := to_number(to_char(p_effective_date,'yyyy')) -1 ;
END IF;
RETURN n_year;
END GET_FINANCIAL_YEAR;
end PQP_GB_LGPS_PENSIONPAY;


/
