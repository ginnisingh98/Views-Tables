--------------------------------------------------------
--  DDL for Package Body PAY_KW_PIFSS_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_KW_PIFSS_REPORT" AS
/* $Header: pykwpifn.pkb 120.6.12000000.3 2007/02/21 05:38:39 spendhar noship $ */
--------------------
FUNCTION get_def_bal_id (p_bal_name in varchar2) return number is
	l_def_bal_id number;
	cursor get_bal_id (l_bal_name varchar2) IS
	select  u.creator_id
	from    ff_user_entities  u,
		ff_database_items d
	where   d.user_name = l_bal_name
	and     u.user_entity_id = d.user_entity_id
	and     u.legislation_code = 'KW'
	and     u.business_group_id is null
        and     u.creator_type = 'B';
begin
	open get_bal_id (p_bal_name);
	fetch get_bal_id into l_def_bal_id;
	close get_bal_id;
	return  l_def_bal_id;
end get_def_bal_id;
--------------------
FUNCTION  get_new_count (
          p_employer  in number
         ,p_month     in varchar2
         ,p_year      in varchar2
         ,p_nationality in varchar2) RETURN number IS
	l_temp_effective_date date;
	l_new_count number;
	l_temp_pid number;
    CURSOR csr_get_new_emp (l_employer_id number,l_effective_date date , l_nationality varchar2) IS
    SELECT distinct asg.person_id
    FROM   per_assignments_f asg
           ,pay_assignment_actions paa
           ,pay_payroll_actions ppa
           ,hr_soft_coding_keyflex hscl
           ,per_periods_of_service pos
           ,per_people_f pef
    WHERE  asg.assignment_id = paa.assignment_id
    AND    paa.payroll_action_id = ppa.payroll_action_id
    AND    pos.period_of_service_id = asg.period_of_service_id
    AND    ppa.action_type in ('R','Q')
    AND    ppa.action_status = 'C'
    AND    paa.action_status = 'C'
    AND    trunc(ppa.date_earned,'MM') = TRUNC(l_effective_date, 'MM')
    AND    trunc(NVL(pos.actual_termination_date, to_date('31-12-4712','DD-MM-YYYY')),'MM') <> TRUNC(l_effective_date, 'MM')
    AND    trunc(pos.date_start, 'MM') = trunc(l_effective_date, 'MM')
    AND    trunc(l_effective_date, 'MM') between trunc(asg.effective_start_date,'MM') and asg.effective_end_date
    AND    trunc(l_effective_date, 'MM') between trunc(pef.effective_start_date,'MM') and pef.effective_end_date
    AND    hscl.soft_coding_keyflex_id = asg.soft_coding_keyflex_id
    AND    hscl.segment1 = to_char(l_employer_id)
    AND    pef.person_id = asg.person_id
    AND    pef.nationality = l_nationality;
begin
	l_temp_effective_date := to_date('01'||'-'||p_month||'-'||p_year,'dd-mm-yyyy');
	vNEWCtr := 1;
	l_new_count := 0;
	open csr_get_new_emp(p_employer,l_temp_effective_date,p_nationality);
	fetch csr_get_new_emp into l_temp_pid;
	IF csr_get_new_emp % FOUND THEN
		close csr_get_new_emp;
		open csr_get_new_emp(p_employer,l_temp_effective_date,p_nationality);
		LOOP
			fetch csr_get_new_emp into vNEWTable(vNEWCtr).person_id;
		EXIT WHEN csr_get_new_emp % NOTFOUND;
			vNEWCtr := vNEWCtr + 1;
			l_new_count := l_new_count + 1;
		END LOOP;
	ELSE
		l_new_count := 0;
	END IF;
	close csr_get_new_emp;
	return l_new_count;
end get_new_count;
--------------------
FUNCTION  get_total_count (
          p_employer  in number
         ,p_month     in varchar2
         ,p_year      in varchar2
         ,p_nationality in varchar2) RETURN number IS
	l_temp_effective_date date;
	l_total_count number;
	l_temp_pid number;
    CURSOR csr_get_tot_emp (l_employer_id number,l_effective_date date , l_nationality varchar2) IS
    SELECT distinct asg.person_id
    FROM   per_assignments_f asg
           ,pay_assignment_actions paa
           ,pay_payroll_actions ppa
           ,hr_soft_coding_keyflex hscl
           ,per_people_f pef
    WHERE  asg.assignment_id = paa.assignment_id
    AND    paa.payroll_action_id = ppa.payroll_action_id
    AND    ppa.action_type in ('R','Q')
    AND    ppa.action_status = 'C'
    AND    paa.action_status = 'C'
    AND    trunc(ppa.date_earned,'MM') = TRUNC(l_effective_date, 'MM')
    AND    trunc(l_effective_date, 'MM') between trunc(asg.effective_start_date,'MM') and asg.effective_end_date
    AND    trunc(l_effective_date, 'MM') between trunc(pef.effective_start_date,'MM') and pef.effective_end_date
    AND    hscl.soft_coding_keyflex_id = asg.soft_coding_keyflex_id
    AND    hscl.segment1 = to_char(l_employer_id)
    AND    pef.person_id = asg.person_id
    AND    pef.nationality = l_nationality;
begin
	l_temp_effective_date := to_date('01'||'-'||p_month||'-'||p_year,'dd-mm-yyyy');
	vTOTCtr := 1;
	l_total_count := 0;
	open csr_get_tot_emp(p_employer,l_temp_effective_date,p_nationality);
	fetch csr_get_tot_emp into l_temp_pid;
	IF csr_get_tot_emp % FOUND THEN
		close csr_get_tot_emp;
		open csr_get_tot_emp(p_employer,l_temp_effective_date,p_nationality);
		LOOP
			fetch csr_get_tot_emp into vTOTTable(vTOTCtr).person_id;
		EXIT WHEN csr_get_tot_emp % NOTFOUND;
			vTOTCtr := vTOTCtr + 1;
			l_total_count := l_total_count + 1;
		END LOOP;
	ELSE
		l_total_count := 0;
	END IF;
	close csr_get_tot_emp;
	return l_total_count;
end get_total_count;
--------------------
FUNCTION  get_change_count (
          p_employer  in number
         ,p_month     in varchar2
         ,p_year      in varchar2
         ,p_nationality in varchar2) RETURN number IS
	l_temp_effective_date date;
	l_temp_prev_effective_date  date;
	l_change_count number;
	l_temp_pid number;
	l_defined_balance_id_net_asg number;
	l_cur_asact_id number;
	l_prev_asact_id number;
	j	number;
    l_n_c number;
-- Cursor to get person ids of employees neither new nor terminated.
    CURSOR csr_get_change_emp(l_employer_id number, l_effective_date date , l_nationality varchar2)  IS
    SELECT distinct asg.person_id
    FROM   per_assignments_f asg
           ,pay_assignment_actions paa
           ,pay_payroll_actions ppa
           ,hr_soft_coding_keyflex hscl
           ,per_periods_of_service pos
           ,per_people_f pef
    WHERE  asg.assignment_id = paa.assignment_id
    AND    paa.payroll_action_id = ppa.payroll_action_id
    AND    pos.period_of_service_id = asg.period_of_service_id
    AND    ppa.action_type in ('R','Q')
    AND    ppa.action_status = 'C'
    AND    paa.action_status = 'C'
    AND    trunc(ppa.date_earned,'MM') = TRUNC(l_effective_date, 'MM')
    AND    trunc(pos.date_start, 'MM') <> trunc(l_effective_date, 'MM')
    AND    trunc(NVL(pos.actual_termination_date, to_date('31-12-4712','DD-MM-YYYY')),'MM') <> TRUNC(l_effective_date, 'MM')
    AND    trunc(l_effective_date, 'MM') between trunc(asg.effective_start_date,'MM') and asg.effective_end_date
    AND    trunc(l_effective_date, 'MM') between trunc(pef.effective_start_date,'MM') and pef.effective_end_date
    AND    hscl.soft_coding_keyflex_id = asg.soft_coding_keyflex_id
    AND    hscl.segment1 = to_char(l_employer_id)
    AND    pef.person_id = asg.person_id
    AND    pef.nationality = l_nationality;
--Cursor to get assignment_action_id of total employees
 cursor get_assact_id_tot (p_org_id number,p_date date,p_person_id number , l_nationality varchar2) is
 select  paa.assignment_action_id from per_assignments_f asg
          ,pay_assignment_actions paa
          ,pay_payroll_actions ppa
          ,hr_soft_coding_keyflex hscl
          ,per_periods_of_service pos
          ,per_people_f pef
   where rownum < 2
   and   asg.assignment_id = paa.assignment_id
   and   asg.person_id = p_person_id
   and    paa.payroll_action_id = ppa.payroll_action_id
   and    ppa.action_type in ('R','Q')
   and    ppa.action_status = 'C'
   and    paa.action_status = 'C'
   and    trunc(ppa.date_earned,'MM') = trunc(p_date, 'MM')
   and    trunc(p_date,'MM') between trunc(asg.effective_start_date,'MM') and asg.effective_end_date
   and    trunc(p_date,'MM') between trunc(pef.effective_start_date,'MM') and pef.effective_end_date
   and    hscl.soft_coding_keyflex_id = asg.soft_coding_keyflex_id
   and    hscl.segment1 = to_char(p_org_id)
   and    pef.person_id = asg.person_id
   and    pef.nationality = l_nationality
   order by asg.person_id;
--Cursor to get assignment_action_id of employees' previous month
  cursor get_assact_id_tot_prev_month (p_org_id number,p_prev_month_date date,p_person_id number , l_nationality varchar2) is
  select  paa.assignment_action_id from per_assignments_f asg
           ,pay_assignment_actions paa
           ,pay_payroll_actions ppa
           ,hr_soft_coding_keyflex hscl
           ,per_periods_of_service pos
           ,per_people_f pef
    where rownum < 2
    and   asg.assignment_id = paa.assignment_id
    and   asg.person_id = p_person_id
    and    paa.payroll_action_id = ppa.payroll_action_id
    and    ppa.action_type in ('R','Q')
    and    ppa.action_status = 'C'
    and    paa.action_status = 'C'
    and    trunc(ppa.date_earned,'MM') = trunc(p_prev_month_date, 'MM')
    and    trunc(p_prev_month_date,'MM') between trunc(asg.effective_start_date,'MM') and asg.effective_end_date
    and    trunc(p_prev_month_date,'MM') between trunc(pef.effective_start_date,'MM') and pef.effective_end_date
    and    hscl.soft_coding_keyflex_id = asg.soft_coding_keyflex_id
    and    hscl.segment1 = to_char(p_org_id)
    and    pef.person_id = asg.person_id
    and    pef.nationality = l_nationality
   order by asg.person_id;
begin
	l_temp_effective_date := to_date('01'||'-'||p_month||'-'||p_year,'dd-mm-yyyy');
	l_temp_prev_effective_date := add_months(l_temp_effective_date,-1);
	vCHANGECtr := 1;
	l_change_count := 0;
	j := 1;
    l_n_c := 0 ;
	pay_balance_pkg.set_context('TAX_UNIT_ID',p_employer);
      pay_balance_pkg.set_context('DATE_EARNED',FND_DATE.DATE_TO_CANONICAL(l_temp_effective_date));
	l_defined_balance_id_net_asg := get_def_bal_id('SUBJECT_TO_SOCIAL_INSURANCE_ASG_RUN');
	if csr_get_change_emp % ISOPEN then
		close csr_get_change_emp;
		open csr_get_change_emp(p_employer,l_temp_effective_date,p_nationality);
	else
		open csr_get_change_emp(p_employer,l_temp_effective_date,p_nationality);
	end if;
	fetch csr_get_change_emp into l_temp_pid;
	IF csr_get_change_emp % FOUND THEN
		if csr_get_change_emp % ISOPEN then
			close csr_get_change_emp;
			open csr_get_change_emp(p_employer,l_temp_effective_date,p_nationality);
		else
			open csr_get_change_emp(p_employer,l_temp_effective_date,p_nationality);
		end if;
		LOOP
			fetch csr_get_change_emp into vCHANGETable(vCHANGECtr).person_id;
		EXIT WHEN csr_get_change_emp % NOTFOUND;
			vCHANGECtr := vCHANGECtr + 1;
		END LOOP;
	END IF;
	if csr_get_change_emp%ISOPEN then
		close csr_get_change_emp;
	end if;
	IF vCHANGETable.count <> 0 then
		FOR i in vCHANGETable.first..vCHANGETable.last
		LOOP
			open get_assact_id_tot(p_employer , l_temp_effective_date , vCHANGETable(i).person_id,p_nationality);
			fetch get_assact_id_tot into l_cur_asact_id;
			if get_assact_id_tot % notfound then
				l_cur_asact_id := 0;
			end if;
			close get_assact_id_tot;
			open get_assact_id_tot_prev_month(p_employer , l_temp_prev_effective_date , vCHANGETable(i).person_id,p_nationality);
			fetch get_assact_id_tot_prev_month into l_prev_asact_id;
			if get_assact_id_tot_prev_month % notfound then
				l_prev_asact_id := 0;
                l_n_c := 1 ;
			end if;
			close get_assact_id_tot_prev_month;
			IF l_n_c <> 1 and pay_balance_pkg.get_value(l_defined_balance_id_net_asg,l_cur_asact_id) <> pay_balance_pkg.get_value(l_defined_balance_id_net_asg,l_prev_asact_id) THEN
					l_change_count := l_change_count + 1;
					vCHANGE_FINALTable(j).person_id := vCHANGETable(i).person_id;
					j := j + 1;
			END IF;
            l_n_c := 0 ;
		END LOOP;
	END IF;
	return l_change_count;
end get_change_count;
--------------------
FUNCTION  get_term_count (
          p_employer  in number
         ,p_month     in varchar2
         ,p_year      in varchar2
         ,p_nationality in varchar2) RETURN number IS
	l_temp_effective_date date;
	l_term_count number;
	l_temp_pid number;
    CURSOR csr_get_term_emp(l_employer_id number,l_effective_date date , l_nationality varchar2) IS
    SELECT distinct asg.person_id
    FROM   per_assignments_f asg
           ,pay_assignment_actions paa
           ,pay_payroll_actions ppa
           ,hr_soft_coding_keyflex hscl
           ,per_periods_of_service pos
           ,per_people_f pef
    WHERE  asg.assignment_id = paa.assignment_id
    AND    paa.payroll_action_id = ppa.payroll_action_id
    AND    pos.period_of_service_id = asg.period_of_service_id
    AND    ppa.action_type in ('R','Q')
    AND    ppa.action_status = 'C'
    AND    paa.action_status = 'C'
    AND    trunc(ppa.date_earned,'MM') = TRUNC(l_effective_date, 'MM')
    AND    trunc(NVL(pos.actual_termination_date, to_date('31-12-4712','DD-MM-YYYY')),'MM') = TRUNC(l_effective_date, 'MM')
    AND    trunc(l_effective_date, 'MM') between trunc(asg.effective_start_date,'MM') and asg.effective_end_date
    AND    trunc(l_effective_date, 'MM') between trunc(pef.effective_start_date,'MM') and pef.effective_end_date
    AND    hscl.soft_coding_keyflex_id = asg.soft_coding_keyflex_id
    AND    hscl.segment1 = to_char(l_employer_id)
    AND    pef.person_id = asg.person_id
    AND    pef.nationality = l_nationality;
begin
	l_temp_effective_date := to_date('01'||'-'||p_month||'-'||p_year,'dd-mm-yyyy');
	vTERMCtr := 1;
	l_term_count := 0;
	open csr_get_term_emp(p_employer,l_temp_effective_date,p_nationality);
	fetch csr_get_term_emp into l_temp_pid;
	IF csr_get_term_emp % FOUND THEN
		close csr_get_term_emp;
		open csr_get_term_emp(p_employer,l_temp_effective_date,p_nationality);
		LOOP
			fetch csr_get_term_emp into vTERMTable(vTERMCtr).person_id;
		EXIT WHEN csr_get_term_emp % NOTFOUND;
			vTERMCtr := vTERMCtr + 1;
			l_term_count := l_term_count + 1;
		END LOOP;
	ELSE
		l_term_count := 0;
	END IF;
	close csr_get_term_emp;
	return l_term_count;
end get_term_count;
--------------------
FUNCTION get_change_indicator(  p_person_id in number) RETURN varchar2 IS
	l_indicator varchar2(1);
	i number;
begin
	if vTERMTable.count <> 0 then
		FOR i in vTERMTable.first..vTERMTable.last
		LOOP
			if vTERMTable(i).person_id = p_person_id then
				l_indicator := 'T';
				exit;
			end if;
		END LOOP;
	end if;
		if l_indicator is not null then
			null;
		else
			if vNEWTable.count <> 0 then
				FOR i in vNEWTable.first..vNEWTable.last
				LOOP
					if vNEWTable(i).person_id = p_person_id then
						l_indicator := 'N';
						exit;
					end if;
				END LOOP;
			end if;
		end if;
		if l_indicator is not null then
			null;
		else
			if vCHANGE_FINALTable.count <> 0 then
				FOR i in vCHANGE_FINALTable.first..vCHANGE_FINALTable.last
				LOOP
					if vCHANGE_FINALTable(i).person_id = p_person_id then
						l_indicator  := 'C';
						exit;
					end if;
				END LOOP;
			end if;
		end if;
	return l_indicator;
end get_change_indicator;
--------------------
FUNCTION get_parameter(
                 p_parameter_string  IN VARCHAR2
                ,p_token             IN VARCHAR2
                ,p_segment_number    IN NUMBER DEFAULT NULL ) RETURN VARCHAR2
 IS
   l_parameter  pay_payroll_actions.legislative_parameters%TYPE:=NULL;
   l_start_pos  NUMBER;
   l_delimiter  varchar2(1);
BEGIN
  l_delimiter :=' ';
   l_start_pos := instr(' '||p_parameter_string,l_delimiter||p_token||'=');
   IF l_start_pos = 0 THEN
     l_delimiter := '|';
     l_start_pos := instr(' '||p_parameter_string,l_delimiter||p_token||'=');
   end if;
   IF l_start_pos <> 0 THEN
     l_start_pos := l_start_pos + length(p_token||'=');
     l_parameter := substr(p_parameter_string,
                           l_start_pos,
                           instr(p_parameter_string||' ',
                           ',',l_start_pos)
                           - l_start_pos);
     IF p_segment_number IS NOT NULL THEN
       l_parameter := ':'||l_parameter||':';
       l_parameter := substr(l_parameter,
                             instr(l_parameter,':',1,p_segment_number)+1,
                             instr(l_parameter,':',1,p_segment_number+1) -1
                             - instr(l_parameter,':',1,p_segment_number));
     END IF;
   END IF;
   RETURN l_parameter;
 END get_parameter;
---------------
FUNCTION get_deduction_detail(p_report_type in varchar2,
				p_assignment_action_id	in number,
				p_assignment_id 	in number,
				p_date 			in date) RETURN varchar2 IS
	l_ded_detail_string varchar2(2000) := null;
	l_seq_num number := 1;
	l_install_num number := 1;
	l_temp_amount number(9,3) :=0;
	l_temp_ded_type varchar2(100);
	l_temp_start_date date;
	l_temp_end_date date;
	l_element_type_id number;
	l_setup_ded number;
	l_ded_type varchar2(100);

	l_ele_start_date date;

	CURSOR csr_get_ded_details (l_assignment_id number , l_assignment_action_id number, l_effective_date date) IS
    SELECT rrv.RESULT_VALUE val,pee.entry_information3 type,fnd_date.canonical_to_date(pee.entry_information5) start_d
           ,fnd_date.canonical_to_date(pee.entry_information6) end_d ,pet.element_type_id , pet.effective_start_date
    FROM 	pay_element_types_f 	pet,
    		pay_element_entries_f 	pee,
    		pay_run_results		prr,
    		pay_run_result_values	rrv,
		pay_input_values_f      piv
    WHERE  	rrv.RUN_RESULT_ID = prr.RUN_RESULT_ID
	    	AND prr.assignment_action_id = l_assignment_action_id
    	   	AND prr.ELEMENT_ENTRY_ID = pee.ELEMENT_ENTRY_ID
                AND piv.element_type_id = pet.element_type_id
                AND piv.name = 'Pay Value'
                AND rrv.input_value_id = piv.input_value_id
    	   	AND pee.assignment_id = l_assignment_id
    	   	AND TRUNC(l_effective_date,'MM')  between trunc(pee.effective_start_date,'MM') and nvl(pee.effective_end_date,to_date('31-12-4712','DD-MM-YYYY'))
                AND TRUNC(l_effective_date,'MM')  between trunc(piv.effective_start_date,'MM') and nvl(piv.effective_end_date,to_date('31-12-4712','DD-MM-YYYY'))
    	   	AND pee.element_type_id = pet.element_type_id
		AND pee.entry_information3 is not null
    	        AND rrv.result_value is not null
    	        AND TRUNC(l_effective_date,'MM')  between trunc(pet.effective_start_date,'MM') and nvl(pet.effective_end_date,to_date('31-12-4712','DD-MM-YYYY'));

	CURSOR csr_get_install_number (l_assignment_id number , l_type_id number, l_start_date date) IS
	select 	pev.screen_entry_value
	from 	pay_element_types_f 	pet,
		pay_element_entries_f 	pee,
		pay_element_entry_values_f pev
	where	    pet.element_type_id = l_type_id
		AND trunc(pet.effective_start_date,'MM') = trunc(l_start_date,'MM')
		AND pee.element_type_id = pet.element_type_id
		AND pee.assignment_id = l_assignment_id
		AND trunc(l_start_date,'MM') between pee.effective_start_date and pee.effective_end_date
		AND pee.element_entry_id = pev.element_entry_id
		AND trunc(l_start_date,'MM') between pev.effective_start_date and pev.effective_end_date;

	CURSOR csr_get_ded_table(p_row varchar2,l_date date) IS
		SELECT i.value
		FROM   pay_user_column_instances_f i,
			   pay_user_rows_f r,
			   pay_user_columns c,
			   pay_user_tables t
		WHERE  UPPER(t.user_table_name) = UPPER('KW_DEDUCTION_MAPPING')
		AND	   t.legislation_code = 'KW'
		AND    t.user_table_id = r.user_table_id
        	AND    t.user_table_id = c.user_table_id
		AND	   UPPER(c.user_column_name) = UPPER('DEDUCTION_TYPE')
		AND	   c.legislation_code = 'KW'
		AND	   r.row_low_range_or_name = p_row
		AND	   r.user_row_id = i.user_row_id
		AND	   c.user_column_id = i.user_column_id
		AND    l_date BETWEEN r.effective_start_date AND r.effective_end_date
        	AND    l_date  BETWEEN i.effective_start_date AND i.effective_end_date;

begin
	open csr_get_ded_details (p_assignment_id,p_assignment_action_id,p_date);
	fetch csr_get_ded_details into l_temp_amount,l_temp_ded_type,l_temp_start_date,l_temp_end_date,l_element_type_id,l_ele_start_date;
    if csr_get_ded_details % found then
		close csr_get_ded_details;
		open csr_get_ded_details (p_assignment_id,p_assignment_action_id,p_date);
		LOOP
			fetch csr_get_ded_details into l_temp_amount,l_temp_ded_type,l_temp_start_date,l_temp_end_date,l_element_type_id,l_ele_start_date;
            exit when csr_get_ded_details %  notfound;
            open csr_get_install_number(p_assignment_id , l_element_type_id , l_ele_start_date);
            fetch csr_get_install_number into l_setup_ded;
            close csr_get_install_number;
            if l_setup_ded is not null then
            	l_install_num := round(l_temp_amount/l_setup_ded);
            else
            	l_install_num := 1;
            end if;

		l_ded_type := null;

/* Code to pick up the user table equivalent of deduction type */
		OPEN csr_get_ded_table(l_temp_ded_type,p_date);
		FETCH csr_get_ded_table into l_ded_type;
		CLOSE csr_get_ded_table;

	IF l_ded_type is not null then
		if p_report_type ='KW_PIFSS_REPORT'  then
			l_ded_detail_string := l_ded_detail_string || LPAD(nvl(l_ded_type,'0'),2,'0') || LPAD(l_seq_num,2,'0') || LPAD(to_char(l_temp_amount*1000 ),7,'0')||LPAD(nvl(to_char(l_temp_start_date,'YYYYMMDD'),' '),8,' ') || LPAD(l_install_num,2,'0');
		else
			l_ded_detail_string := l_ded_detail_string || LPAD(nvl(l_ded_type,'0'),2,'0') ||  LPAD(to_char(l_temp_amount*1000 ),7,'0') || LPAD(l_install_num,2,'0');
		end if;
            l_seq_num := l_seq_num + 1;
	END IF;
		END LOOP;
    else
		if p_report_type='KW_PIFSS_REPORT' then
			l_ded_detail_string := LPAD(' ',21,' ');
		else
			l_ded_detail_string := LPAD(' ',11,' ');
		end if;
	end if;
	return l_ded_detail_string;
end get_deduction_detail;
-----------------------------
FUNCTION get_amount_cont (p_employer_id number, p_assact_cur_id number , p_person_id number , p_effective_date date) return varchar2 IS

	CURSOR csr_get_first_assact_id (l_employer_id number, l_date date ,l_person_id number) IS
	select  paa.assignment_action_id
	from per_assignments_f asg
           ,pay_assignment_actions paa
           ,pay_payroll_actions ppa
           ,hr_soft_coding_keyflex hscl
           ,per_periods_of_service pos
	where rownum < 2
	    and   asg.assignment_id = paa.assignment_id
	    and   asg.person_id = l_person_id
	    and    paa.payroll_action_id = ppa.payroll_action_id
	    and    ppa.action_type in ('R','Q')
	    and    ppa.action_status = 'C'
	    and    paa.action_status = 'C'
	    and    trunc(ppa.date_earned,'MM') = trunc(l_date, 'MM')
	    and    trunc(l_date,'MM') between trunc(asg.effective_start_date,'MM') and asg.effective_end_date
	    and    hscl.soft_coding_keyflex_id = asg.soft_coding_keyflex_id
	    and    hscl.segment1 = to_char(l_employer_id)
	   order by asg.person_id;

	CURSOR csr_get_start_date(l_person_id number , l_effective_date date) IS
	Select start_date
	From per_people_f
	Where person_id = l_person_id
	And l_effective_date between effective_start_date and effective_end_date;

	CURSOR csr_soc_bal_id(l_employer_id number) IS
	SELECT	ORG_INFORMATION1
	FROM    HR_ORGANIZATION_INFORMATION
	WHERE   Organization_id = l_employer_id
	AND	org_information_context = 'KW_SI_DETAILS';

	l_ret_string varchar2(2000);
	l_cont_wage_id number;
	l_subject_to_social_id number;
	l_basic_social_id number;
	l_supplementary_social_id number;
	l_additional_social_id number;
	l_first_assact_id number;
	l_temp_start_date date;
	l_act_first_date date;
	l_first_sal number(12,3);
	l_cur_sal  number(12,3);
	l_first_social number(12,3);
	l_cur_social number(12,3);
	l_test_cont_sal number(12,3);
	l_soc_bal_id number;
        l_tot_earn_id number;

begin

	l_subject_to_social_id := get_def_bal_id('SUBJECT_TO_SOCIAL_INSURANCE_ASG_RUN');
	l_cont_wage_id:= get_def_bal_id('CONTRIBUTORY_WAGE_ASG_YTD');
	l_basic_social_id := get_def_bal_id('EMPLOYEE_BASIC_SOCIAL_INSURANCE_ASG_RUN');
	l_supplementary_social_id := get_def_bal_id('EMPLOYEE_SUPPLEMENTARY_SOCIAL_INSURANCE_ASG_RUN');
	l_additional_social_id := get_def_bal_id('ADDITIONAL_SOCIAL_INSURANCE_ASG_RUN');
	l_tot_earn_id := get_def_bal_id('TOTAL_EARNINGS_ASG_RUN');

	OPEN csr_soc_bal_id(p_employer_id);
	FETCH csr_soc_bal_id into l_soc_bal_id;
	CLOSE csr_soc_bal_id;

	pay_balance_pkg.set_context('TAX_UNIT_ID', p_employer_id);
	pay_balance_pkg.set_context('DATE_EARNED', p_effective_date);
	open csr_get_start_date (p_person_id , p_effective_date);
	fetch csr_get_start_date into l_temp_start_date;
	close csr_get_start_date;
	If l_temp_start_date < trunc(p_effective_date,'YYYY') then
		l_act_first_date := trunc(p_effective_date,'YYYY');
        --l_cont_wage_id := l_subject_to_social_id;
	Else
		l_act_first_date := l_temp_start_date;
	End If;
	open csr_get_first_assact_id (p_employer_id ,l_act_first_date, p_person_id );
	fetch csr_get_first_assact_id into l_first_assact_id;
	close csr_get_first_assact_id ;
	l_test_cont_sal := pay_balance_pkg.get_value(l_cont_wage_id,l_first_assact_id);
	if l_test_cont_sal <= to_number(pay_kw_general.get_table_bands(p_effective_date,'Kuwait Social Insurance','MIN_LOW')) then
		l_test_cont_sal := to_number(pay_kw_general.get_table_bands(p_effective_date,'Kuwait Social Insurance','MIN_LOW'));
	elsif l_test_cont_sal >= to_number(pay_kw_general.get_table_bands(p_effective_date,'Kuwait Social Insurance','MAX_HIGH')) then
		l_test_cont_sal := to_number(pay_kw_general.get_table_bands(p_effective_date,'Kuwait Social Insurance','MAX_HIGH'));
	end if;
	l_first_sal    := l_test_cont_sal*1000;

/*
	l_cur_sal      := pay_balance_pkg.get_value(l_subject_to_social_id ,p_assact_cur_id)*1000;
*/

/*** Changed after kuwait annual report 55 ****/
	l_cur_sal      := pay_balance_pkg.get_value(l_tot_earn_id,p_assact_cur_id)*1000;

/*	l_first_social := (pay_balance_pkg.get_value(l_basic_social_id ,l_first_assact_id) +
                           pay_balance_pkg.get_value(l_supplementary_social_id ,l_first_assact_id) +
			  pay_balance_pkg.get_value(l_additional_social_id ,l_first_assact_id) ) * 1000;
*/

/*** Changed after kuwait annual report 103 ***/

	If l_soc_bal_id is not null then
		l_first_social := pay_balance_pkg.get_value(l_soc_bal_id,l_first_assact_id)*1000;
	Else
		l_first_social := 0;
	End If;

/*	l_cur_social   := (pay_balance_pkg.get_value(l_basic_social_id ,p_assact_cur_id) +
			  pay_balance_pkg.get_value(l_supplementary_social_id ,p_assact_cur_id) +
			  pay_balance_pkg.get_value(l_additional_social_id ,p_assact_cur_id)) * 1000;
*/

        If l_soc_bal_id is not null then
                l_cur_social := pay_balance_pkg.get_value(l_soc_bal_id,p_assact_cur_id)*1000;
        Else
                l_cur_social := 0;
        End If;


	l_ret_string := LPAD(to_char(nvl(l_first_sal,0)),9,'0') ||  LPAD(to_char (nvl(l_cur_sal,0)),9,'0') || LPAD(to_char(nvl(l_first_social,0)),7,'0') || LPAD( to_char(nvl(l_cur_social,0)),7,'0');
return LPAD(to_char(nvl(l_first_sal,0)),9,'0') ||  LPAD(to_char (nvl(l_cur_sal,0)),9,'0') || LPAD(to_char(nvl(l_first_social,0)),7,'0') || LPAD( to_char(nvl(l_cur_social,0)),7,'0');
--return l_ret_string ;
end get_amount_cont;
-----------------------------
END pay_kw_pifss_report;

/
