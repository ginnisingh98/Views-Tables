--------------------------------------------------------
--  DDL for Package Body PAY_NL_WW_ADJUSTMENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_NL_WW_ADJUSTMENTS" AS
/* $Header: pynlsicp.pkb 120.3.12010000.2 2008/08/06 08:01:32 ubhat ship $ */

--------------------------------------------------------------
--Function for getting Basis Calculation Rule
--------------------------------------------------------------

FUNCTION Get_Basis_calc_Rule
	( p_source_text IN VARCHAR2,
	  p_source_text2 IN VARCHAR2,
	  p_date_earned IN DATE)
RETURN NUMBER  IS

--Cursor for getting Basis Calc Rule

CURSOR csr_basis_calc_rule(c_si_type VARCHAR2, c_si_provider VARCHAR2, c_date DATE) IS

SELECT hoi.org_information5 basis_calc_rule
FROM hr_organization_information hoi
WHERE
	Hoi.Organization_id = c_si_provider
AND	hoi.org_information_context = 'NL_SIT'
AND	hoi.org_information4 = c_si_type
AND	c_date between fnd_date.canonical_to_date(hoi.org_information1) AND nvl(fnd_date.canonical_to_date(hoi.org_information2),hr_general.end_of_time);


l_basis_calc_rule csr_basis_calc_rule%ROWTYPE;

BEGIN
hr_utility.set_location('Entering Get_Basis_calc_Rule ',2300);

OPEN csr_basis_calc_rule(p_source_text,p_source_text2,p_date_earned);
FETCH csr_basis_calc_rule into l_basis_calc_rule;
CLOSE csr_basis_calc_rule;

RETURN to_number(l_basis_calc_rule.basis_calc_rule);

END;


--------------------------------------------------------------
--Function for getting Whether EE cont. is Gross or Net
--------------------------------------------------------------

FUNCTION Get_EE_Cont_Gross_Net
	( p_source_text IN VARCHAR2,
	p_source_text2 IN VARCHAR2,
	p_date_earned IN DATE)
RETURN VARCHAR2  IS

--Cursor for getting Whether EE cont. is Gross or Net

CURSOR csr_gross_net(c_si_type VARCHAR2, c_si_provider VARCHAR2, c_date DATE) IS

SELECT hoi.org_information14 gross_net
FROM hr_organization_information hoi
WHERE
	Hoi.Organization_id = c_si_provider
AND	hoi.org_information_context = 'NL_SIT'
AND	hoi.org_information4 = c_si_type
AND	c_date between fnd_date.canonical_to_date(hoi.org_information1) AND NVL(fnd_date.canonical_to_date(hoi.org_information2),hr_general.end_of_time);


l_gross_net csr_gross_net%ROWTYPE;

BEGIN

hr_utility.set_location('Entering Get_Basis_calc_Rule ',2370);

OPEN csr_gross_net(p_source_text,p_source_text2,p_date_earned);
FETCH csr_gross_net  into l_gross_net;
CLOSE csr_gross_net;

RETURN l_gross_net.gross_net;

END;


--------------------------------------------------------------
-- Function for getting contribution percentages. Returns
-- SI Provider for next execution of Adjustment formula
--------------------------------------------------------------

FUNCTION Get_Adjustment_details (p_assignment_action_id IN NUMBER,
				    p_date_earned IN DATE,
				    p_source_text IN VARCHAR2,
				    p_source_text2 IN VARCHAR2,
				    p_age IN NUMBER,
				    p_ee_cont_perc IN OUT NOCOPY NUMBER,
                                    p_er_cont_perc  IN OUT NOCOPY NUMBER,
                                    p_si_type_name OUT NOCOPY VARCHAR2)
RETURN VARCHAR2 IS

-- Cursor to return contribution_percentages
CURSOR csr_get_cont_perc(c_si_type VARCHAR2, c_si_provider VARCHAR2, c_date_earned DATE) IS
SELECT    fnd_number.canonical_to_number(hoi.org_information6) ee_perc,
	      fnd_number.canonical_to_number(hoi.org_information7) er_perc,
	      fnd_number.canonical_to_number(hoi.org_information17) sr_ee_perc,
	      fnd_number.canonical_to_number(hoi.org_information18) sr_er_perc,
	      hoi.org_information3 si_type_name
FROM
	hr_organization_information hoi
WHERE
	hoi.org_information4 = c_si_type
AND	hoi.organization_id = to_number(c_si_provider)
AND	hoi.org_information_context = 'NL_SIT'
AND	c_date_earned BETWEEN fnd_date.canonical_to_date(hoi.org_information1) AND nvl(fnd_date.canonical_to_date(hoi.org_information2),hr_general.end_of_time);
 l_cont_perc csr_get_cont_perc%ROWTYPE;

l_delete VARCHAR2(15) := 'Y';
BEGIN

/*Version 115.1 change start*/

--hr_utility.trace_on(NULL,'ADJUSTMENT');

IF last_asg_action_id IS NULL THEN
	last_asg_action_id := -1;
END IF;
IF last_asg_action_id <> p_assignment_action_id THEN
	t1.delete;
	last_asg_action_id := p_assignment_action_id;
END IF;
/* Version 115.1 change end */

hr_utility.set_location('Inside Get_Adjustment_details : NEntering',1800);

-- Populate PL/SQL table
populate_pl_sql_table(p_assignment_action_id, p_date_earned, p_source_text, p_source_text2) ;


hr_utility.set_location('Inside Get_Adjustment_details : after populate_pl_sql_table',1805);

BEGIN
	hr_utility.set_location('Inside Get_Adjustment_details : p_source_text = '||p_source_text||'  p_source_text2'||p_source_text2,1806);

	OPEN csr_get_cont_perc(c_si_type => p_source_text,c_si_provider => p_source_text2,c_date_earned=> p_date_earned);
	FETCH csr_get_cont_perc INTO l_cont_perc;

	IF csr_get_cont_perc%FOUND THEN
	 	hr_utility.set_location('Inside Get_Adjustment_details : Data found for cursor csr_get_cont_perc',1806);

		IF p_age > pay_nl_general.get_global_value(p_date_earned, 'NL_SI_SENIOR_PERCENTAGE_AGE') THEN
			p_ee_cont_perc := l_cont_perc.sr_ee_perc;
			p_er_cont_perc := l_cont_perc.sr_er_perc;
			p_si_type_name := l_cont_perc.si_type_name;
		ELSE
			p_ee_cont_perc := l_cont_perc.ee_perc;
			p_er_cont_perc := l_cont_perc.er_perc;
			p_si_type_name := l_cont_perc.si_type_name;
		END IF;

	ELSE
		p_ee_cont_perc := 0;
		p_er_cont_perc := 0;
		p_si_type_name := ' ';
		hr_utility.set_location('Inside Get_Adjustment_details : No data for cursor csr_get_cont_perc',1810);

	END IF;

	CLOSE csr_get_cont_perc;

	-- Check out the next SIP for the current SI
	FOR i in t1.FIRST..t1.LAST LOOP
		hr_utility.set_location('Ins Get_Adjstment_s : T1 LOOP: SIP'||t1(i).si_provider_id||'SIT '||t1(i).si_type||' Flag ='||t1(i).processed_flag,1810);
		IF t1(i).processed_flag = 'N' AND t1(i).si_provider_id <> p_source_text2 AND t1(i).si_type = p_source_text AND t1(i).asg_act_id = p_assignment_action_id THEN
			hr_utility.set_location('Ins Get_Adjstment_s : T1 LOOP: SELECTED SIP'||t1(i).si_provider_id||'SIT '||p_source_text,1816);
			t1(i).processed_flag := 'Y';
			RETURN t1(i).si_provider_id;
		END IF;
	END LOOP;

	-- Delete entries for the SI type after all SIPs are processed
	FOR i in t1.FIRST..t1.LAST LOOP
		IF t1(i).processed_flag = 'Y' AND t1(i).si_type = p_source_text AND t1(i).asg_act_id = p_assignment_action_id THEN
			hr_utility.set_location('Deleted row'||' : SIP'||t1(i).si_provider_id||'SIT '||t1(i).si_type||' Flag ='||t1(i).processed_flag, 1878);
			t1.delete(i);
		END IF;
	END LOOP;


	RETURN '-1';

EXCEPTION
	WHEN OTHERS THEN
		hr_utility.set_location('Exception :' ||SQLERRM(SQLCODE),1899);
	RAISE;
END;
END ;

--------------------------------------------------------------
-- Procedure to Populate PL/SQL table
--------------------------------------------------------------

PROCEDURE populate_pl_sql_table
	(p_assignment_action_id IN NUMBER,
	p_date_earned IN DATE,
	p_si_type IN VARCHAR2,
	p_si_provider IN VARCHAR2)  IS

--Cursor for getting all SI providers for the given SI type for that person

CURSOR 	csr_get1(c_si_type VARCHAR2,  c_assignment_action_id NUMBER) IS
SELECT 	distinct hr_nl_org_info.GET_SI_PROVIDER_INFO(paa.organization_id, c_si_type, paa.assignment_id) si_provider_id
FROM
	per_all_assignments_f paa,
	per_all_assignments_f paa1,
	pay_assignment_actions pac
WHERE
	pac.assignment_action_id=c_assignment_action_id
AND	paa1.assignment_id = pac.assignment_id
AND	paa1.person_id	   = paa.person_id
AND 	hr_nl_org_info.GET_SI_PROVIDER_INFO(paa.organization_id, c_si_type, paa.assignment_id) <> -1;

--Local Variables
i NUMBER := 1;
v_csr_get1 csr_get1%ROWTYPE;
populate_table VARCHAR2(10) := 'Y';
k NUMBER;

BEGIN

hr_utility.set_location('Inside pop_pl/sql si_type'||p_si_type||' sip'||p_si_provider,2350);

--Check whether present si_type, assignment_action_id combination has entry in PL/SQL table
IF t1.LAST IS NOT NULL THEN

	FOR k IN t1.FIRST .. t1.LAST LOOP
		IF t1(k).asg_act_id = p_assignment_action_id AND t1(k).si_type = p_si_type THEN
			populate_table := 'N';
		END IF;

	END LOOP;
END IF;

BEGIN

i:= NVL(t1.LAST,0) +1;
IF populate_table = 'Y' THEN
	FOR v_csr_get1
	IN csr_get1(p_si_type, p_assignment_action_id)
	LOOP
		t1(i).si_provider_id := v_csr_get1.si_provider_id;
		t1(i).si_type := p_si_type;
		t1(i).asg_act_id := p_assignment_action_id;
		IF t1(i).si_provider_id = p_si_provider THEN
			t1(i).processed_flag := 'Y';
		ELSE
			t1(i).processed_flag := 'N';
		END IF;
		hr_utility.set_location('Inside  v_csr_get1: t1(i).sip'||t1(i).si_provider_id||' SIT'||t1(i).si_type||' FLAG '||t1(i).processed_flag ,2355);
		i := i+1;

	END LOOP;
END IF;

hr_utility.set_location('End pop/pl/sql: SITP=' ||p_si_type||p_si_provider||'ACT_ID'||p_assignment_action_id||'T1.LAST='||NVL(T1.LAST,0),2379);

EXCEPTION
	WHEN OTHERS THEN
		hr_utility.set_location('Exception inside v_csr_get1:' ||SQLERRM(SQLCODE),2399);
	RAISE;
END;
hr_utility.set_location('no Exception populate_pl_sql_table ',2398);
END;

FUNCTION get_si_prov_count
         (p_assignment_id IN NUMBER,
          p_assignment_action_id IN NUMBER)
RETURN NUMBER IS

l_si_prov_count NUMBER := 0;

BEGIN
select count(distinct(context_value)) into l_si_prov_count
                                      from pay_action_contexts
                                      where context_id IN (select context_id from ff_contexts
                                                          where context_name = 'SOURCE_TEXT2')
                                      and assignment_action_id in (select paa.assignment_action_id from
                                                                   per_all_assignments_f paaf,
                                                                   pay_assignment_Actions paa,
                                                                   pay_payroll_actions ppa,
                                                                   per_time_periods ptp

                                                                   where paaf.person_id = (select distinct(person_id) from per_all_assignments_f
                                                                                           where assignment_id = p_assignment_id)
                                                                   and paaf.assignment_id = paa.assignment_id
                                                                   and paa.payroll_action_id = ppa.payroll_action_id
                                                                   --  and ppa.payroll_id = ptp.payroll_id
                                                                   AND	paa.action_status='C'
                                                                   AND ppa.action_type in ('R','Q','V','B','I')
                                                                   and paa.source_action_id is NOT NULL
                                                                   -- and ptp.time_period_id = ppa.time_period_id
                                                                   and ptp.time_period_id IN (select ppa1.time_period_id
                                                                                             from pay_payroll_actions ppa1, pay_assignment_Actions paa1
                                                                                             where paa1.assignment_action_id = p_assignment_action_id
                                                                                             and paa1.payroll_action_id = ppa1.payroll_action_id)
                                                                    and ppa.date_earned between ptp.start_date and ptp.cut_off_date);
RETURN l_si_prov_count;
END get_si_prov_count;

END;

/
