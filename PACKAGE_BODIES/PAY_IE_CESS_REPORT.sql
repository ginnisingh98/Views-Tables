--------------------------------------------------------
--  DDL for Package Body PAY_IE_CESS_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_IE_CESS_REPORT" as
/* $Header: pyiecess.pkb 120.0.12010000.7 2010/02/03 11:29:06 knadhan noship $ */
g_package                CONSTANT VARCHAR2(30) := 'pay_ie_cess_report.';
EOL		VARCHAR2(5)   := fnd_global.local_chr(10);
g_archive_pact                    NUMBER;
g_archive_effective_date          DATE;
g_archive_start_date		    DATE;
g_archive_end_date		    DATE;

g_paye_ref                        NUMBER;

FUNCTION test_XML(P_STRING VARCHAR2) RETURN VARCHAR2 AS
	l_string varchar2(1000);

	FUNCTION replace_xml_symbols(pp_string IN VARCHAR2)
	RETURN VARCHAR2
	AS

	ll_string   VARCHAR2(1000);

	BEGIN


	ll_string :=  pp_string;

	ll_string := replace(ll_string, '&', '&amp;');
	ll_string := replace(ll_string, '<', '&#60;');
	ll_string := replace(ll_string, '>', '&#62;');
	ll_string := replace(ll_string, '''','&apos;');
	ll_string := replace(ll_string, '"', '&quot;');

	RETURN ll_string;
	EXCEPTION when no_data_found then
	null;
	END replace_xml_symbols;

begin
	l_string := p_string;
	l_string := replace_xml_symbols(l_string);

	l_string := pay_ie_p35_magtape.test_XML(l_string);

RETURN l_string;
END ;

FUNCTION c2b( c IN CLOB ) RETURN BLOB
-- typecasts CLOB to BLOB (binary conversion)
IS
pos PLS_INTEGER := 1;
buffer RAW( 32767 );
res BLOB;
lob_len PLS_INTEGER := DBMS_LOB.getLength( c );
BEGIN
Hr_Utility.set_location('Entering: pay_ie_cess_report.c2b',260);
DBMS_LOB.createTemporary( res, TRUE );
DBMS_LOB.OPEN( res, DBMS_LOB.LOB_ReadWrite );


LOOP
buffer := UTL_RAW.cast_to_raw( DBMS_LOB.SUBSTR( c, 16000, pos ) );

IF UTL_RAW.LENGTH( buffer ) > 0 THEN
DBMS_LOB.writeAppend( res, UTL_RAW.LENGTH( buffer ), buffer );
END IF;

pos := pos + 16000;
EXIT WHEN pos > lob_len;
END LOOP;

Hr_Utility.set_location('Leaving: pay_ie_cess_report.c2b',265);
RETURN res; -- res is OPEN here
END c2b;

PROCEDURE get_parameters(p_payroll_action_id IN  NUMBER,
                         p_token_name        IN  VARCHAR2,
                         p_token_value       OUT nocopy VARCHAR2) IS

CURSOR csr_parameter_info(p_pact_id NUMBER,
                          p_token   CHAR) IS
SELECT SUBSTR(legislative_parameters,
               INSTR(legislative_parameters,p_token)+(LENGTH(p_token)+1),
                INSTR(legislative_parameters,' ',
                       INSTR(legislative_parameters,p_token))
                 - (INSTR(legislative_parameters,p_token)+LENGTH(p_token))),
       business_group_id
FROM   pay_payroll_actions
WHERE  payroll_action_id = p_pact_id;

l_business_group_id               VARCHAR2(20);
l_token_value                     VARCHAR2(50);

l_proc                            VARCHAR2(50) := g_package || 'get_parameters';

BEGIN

  hr_utility.set_location('Entering ' || l_proc,10);

  hr_utility.set_location('Step ' || l_proc,20);
  hr_utility.set_location('p_token_name = ' || p_token_name,20);

  OPEN csr_parameter_info(p_payroll_action_id,
                          p_token_name);

  FETCH csr_parameter_info INTO l_token_value,
                                l_business_group_id;

  CLOSE csr_parameter_info;

  IF p_token_name = 'BG_ID'

  THEN

     p_token_value := l_business_group_id;

  ELSE

     p_token_value := l_token_value;

  END IF;

  hr_utility.set_location('l_token_value = ' || l_token_value,20);
  hr_utility.set_location('Leaving         ' || l_proc,30);

END get_parameters;



PROCEDURE get_termination_date (p_action_context_id       IN  NUMBER,
                                p_assignment_id           IN  NUMBER,
                                p_person_id               IN NUMBER,
				p_date_earned		  IN DATE,
			        p_termination_date        OUT NOCOPY DATE,
				p_supp_pymt_date	  OUT NOCOPY DATE,
			        p_supp_flag		  OUT NOCOPY VARCHAR2,
			        p_deceased_flag           OUT NOCOPY VARCHAR2
			       ) is

CURSOR cur_service_leave IS
  select decode(ppos.leaving_reason, 'D','Y','N'),
        ppos.actual_termination_date
  from  per_periods_of_service ppos
  where ppos.person_id = p_person_id
  and   ppos.period_of_service_id = (select max(paf.period_of_service_id)
                                        from per_all_assignments_f paf,
                                             pay_assignment_actions paa,
  					               pay_action_interlocks pai
  	                               where   pai.locking_action_id = p_action_context_id
  				                 and pai.locked_action_id  = paa.assignment_action_id
                                         and paa.action_status = 'C'
                                         and paa.assignment_id = paf.assignment_id
                                     );

CURSOR cur_max_end_date IS
SELECT max(paaf.effective_end_date)
FROM  per_all_assignments_f paaf,
      pay_all_payrolls_f papf,
      hr_soft_coding_keyflex scl
WHERE paaf.person_id = p_person_id
  AND paaf.payroll_id = papf.payroll_id
  AND papf.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
  AND scl.segment4 = to_char(g_paye_ref)
  AND paaf.assignment_status_type_id in
			   (SELECT ast.assignment_status_type_id
			      FROM per_assignment_status_types ast
			     WHERE  ast.per_system_status in ('ACTIVE_ASSIGN','SUSP_ASSIGN')
			   )
  AND paaf.effective_end_date between g_archive_start_date and g_archive_end_date;

CURSOR cur_get_asg_end_date IS
SELECT max(effective_end_date)
FROM per_all_assignments_f paaf
WHERE paaf.assignment_id = p_assignment_id
  AND paaf.assignment_status_type_id in
			   (SELECT ast.assignment_status_type_id
			      FROM per_assignment_status_types ast
			     WHERE  ast.per_system_status in ('ACTIVE_ASSIGN','SUSP_ASSIGN')
			   );



cursor cur_supp_run is
select fnd_date.canonical_to_date(act_inf.action_information3)
 from  pay_assignment_actions paa_run,
       pay_action_interlocks pai,
       pay_assignment_actions paa,
       pay_payroll_actions ppa,
       pay_action_information act_inf
 where ppa.payroll_action_id = paa.payroll_action_id
  and  ppa.report_type = 'IE_CESSATION'
  and  ppa.report_qualifier = 'IE'
  and  ppa.action_type = 'X'
  and  paa.assignment_action_id = act_inf.action_context_id
  and  act_inf.action_information_category = 'IE CESS INFORMATION'
  and  act_inf.action_context_type = 'AAP'
  and  ppa.payroll_action_id <> g_archive_pact
  and  paa.assignment_action_id = pai.locking_action_id
  and  paa.source_action_id is NULL
  and  pai.locked_action_id = paa_run.assignment_action_id
  and  paa_run.assignment_id = p_assignment_id
  and  paa_run.action_status = 'C'
  and  paa.action_status = 'C';


l_proc             CONSTANT VARCHAR2(50):= g_package||'get_termination_date';
l_deceased_flg              VARCHAR2(1);
l_termination_date          DATE;
l_start_date                DATE;
l_end_date                  DATE;
l_asg_end_date              DATE;
l_last_end_date             DATE;

BEGIN
     hr_utility.set_location('Entering ' || l_proc,20);
    hr_utility.set_location('Step ' || l_proc,20);
    hr_utility.set_location('p_action_context_id  = ' || p_action_context_id,20);
    hr_utility.set_location('p_assignment_id      = ' || p_assignment_id,20);
    hr_utility.set_location('p_person_id          = ' || p_person_id,20);
    hr_utility.set_location('g_paye_ref           = ' || g_paye_ref,20);
    hr_utility.set_location('p_termination_date           = ' || p_termination_date,20);



  -- get deceased flag, date of leaving
  OPEN cur_service_leave;
  FETCH cur_service_leave INTO l_deceased_flg,l_termination_date;
  CLOSE cur_service_leave;


  p_deceased_flag := l_deceased_flg;

  l_asg_end_date := l_termination_date;
  hr_utility.set_location('l_termination_date           = ' || l_termination_date,21);

  /* If employee is not terminated using end employment check for asg end date */
  IF l_termination_date IS NULL   THEN
  /* Get End Date of Employement with Employer */
	  OPEN cur_max_end_date;
	  FETCH cur_max_end_date INTO l_termination_date;
	  CLOSE cur_max_end_date;
  /* Get End Date of Assignment */
	  OPEN cur_get_asg_end_date;
	  FETCH cur_get_asg_end_date INTO l_asg_end_date;
	  CLOSE cur_get_asg_end_date;
  END IF;
 hr_utility.set_location('l_termination_date           = ' || l_termination_date,22);
 p_termination_date := l_termination_date;
 OPEN cur_supp_run;
  FETCH cur_supp_run INTO l_last_end_date;
  hr_utility.set_location('l_last_end_date = '|| l_last_end_date,20);
  IF l_last_end_date IS NOT NULL THEN
     p_supp_pymt_date := p_date_earned;
     p_supp_flag:= 'Y';
     p_termination_date := l_last_end_date;
    ELSE
     p_supp_flag:= 'N';
     p_supp_pymt_date :=null;
  END IF;
END get_termination_date;


 PROCEDURE archive_cess_info(p_action_context_id       IN  NUMBER,
                             p_assignment_id           IN  NUMBER,
                             p_payroll_id              IN  NUMBER,
                             p_date_earned             IN  DATE,
                             p_child_run_ass_act_id    IN  NUMBER,
			     p_supp_flag               IN VARCHAR2, -- 5383808
			     p_person_id               IN NUMBER,
			     p_termination_date        in DATE, -- 5383808
			     p_child_pay_action        IN NUMBER,
			  --   p_source_id               IN NUMBER,
			     p_supp_pymt_date	       IN DATE,
			     p_deceased_flag           IN VARCHAR2,
                              p_last_cess_action         IN NUMBER,
			      p_prev_src_id       IN NUMBER
				     ) -- 5383808
  IS
  l_action_info_id            NUMBER(15);
  l_proc             CONSTANT VARCHAR2(50):= g_package||'archive_cess_info';
  l_ovn                       NUMBER;
  l_deceased_flg              VARCHAR2(1);
  l_termination_date          DATE;
  l_supp_flg                  VARCHAR2(1);
  l_supp_pymt_date            DATE;


cursor cur_defined_balance_id (c_balance_name pay_balance_types.balance_name%type
                              ,c_dimension_name pay_balance_dimensions.database_item_suffix%type) is
select pdb.defined_balance_id

from pay_defined_balances    pdb
    ,pay_balance_dimensions  pbd
    ,pay_balance_types       pbt

WHERE pbt.balance_name=c_balance_name
  AND pbt.balance_type_id=pdb.balance_type_id
  and pbd.database_item_suffix=c_dimension_name
  and pbd.balance_dimension_id=pdb.balance_dimension_id
  and pbt.legislation_code='IE'
  and pdb.legislation_code='IE';

 /* CURSOR get_last_source_id is
select source_id from
	pay_action_information pai,
	pay_assignment_actions paa,
	pay_payroll_actions ppa,
        pay_assignment_actions paa1
where paa.assignment_action_id = p_last_cess_action
  and ppa.payroll_action_id=paa.payroll_action_id
  and ppa.payroll_action_id=paa1.payroll_action_id
  and paa1.assignment_id=p_assignment_id
  and paa1.assignment_action_id = pai.action_context_id
  and pai.action_information_category='IE CESS INFORMATION'
  --order by source_id desc
  ;
  */
/*8615992 */
  CURSOR get_last_source_id is
select source_id from
	pay_action_information pai,
	pay_assignment_actions paa
where paa.assignment_action_id = p_last_cess_action
  and paa.assignment_action_id = pai.action_context_id
  and pai.action_information_category='IE CESS INFORMATION'
  and pai.action_context_type = 'AAP'
  ;

  /* CURSOR get_last_source_id_apr_09 is
select source_id , ppa.effective_date from
	pay_action_information pai,
	pay_assignment_actions paa,
	pay_payroll_actions ppa,
        pay_assignment_actions paa1
where paa.assignment_action_id = p_last_cess_action
  and ppa.payroll_action_id=paa.payroll_action_id
  and ppa.payroll_action_id=paa1.payroll_action_id
  and paa1.assignment_id=p_assignment_id
  and paa1.assignment_action_id = pai.action_context_id
  and pai.action_information_category='IE CESS INFORMATION';
   */
   /*8615992 */
CURSOR get_last_source_id_apr_09 is
select source_id , ppa.effective_date from
	pay_action_information pai,
	pay_assignment_actions paa,
	pay_payroll_actions ppa
where paa.assignment_action_id = p_last_cess_action
  and ppa.payroll_action_id=paa.payroll_action_id
  and paa.assignment_action_id = pai.action_context_id
  and pai.action_information_category='IE CESS INFORMATION'
  and pai.action_context_type = 'AAP';


   CURSOR get_asg_action_eff_date(c_assignment_action_id pay_assignment_actions.assignment_action_id%type) is
   select ppa.effective_date
   from pay_assignment_actions paa,
        pay_payroll_actions ppa
   where paa.assignment_action_id=c_assignment_action_id
    and ppa.payroll_action_id=paa.payroll_action_id;


cursor c_employee_details(cp_assignment_id in number
                            , cp_curr_eff_date in date
                             ) is
      select ppf.last_name surname,
             ppf.first_name first_name,
	     ppf.national_identifier PPSN,
             paf.assignment_number works_no,
	     pps.date_start hire_date
      from per_assignments_f paf,
             per_all_people_f ppf,
             per_periods_of_service pps
       where paf.person_id = ppf.person_id
         and paf.assignment_id = cp_assignment_id
         and cp_curr_eff_date between paf.effective_start_date
                                  and paf.effective_end_date
         and cp_curr_eff_date between ppf.effective_start_date
                                  and ppf.effective_end_date
         and pps.person_id = ppf.person_id
         and pps.date_start = (select max(pps1.date_start)
                                 from per_periods_of_service pps1
                                where pps1.person_id = paf.person_id
                                  and pps1.date_start <= cp_curr_eff_date);

c_employee_details_rec c_employee_details%ROWTYPE;
/*8615992 */
CURSOR cur_assignment_action_apr_09(c_ppsn varchar2) is
SELECT fnd_number.canonical_to_number(substr(max(lpad(paa.action_sequence,15,'0')||
      paa.assignment_action_id),16))
FROM pay_assignment_actions paa
    ,pay_payroll_actions ppa
 --   ,pay_assignment_actions paa1
WHERE ((c_ppsn is null and paa.assignment_id=p_assignment_id) OR(c_ppsn is not null
                                                               and paa.assignment_id in (select paaf.assignment_id
                                                                                         from per_all_assignments_f paaf, per_assignment_extra_info paei
								         	         where paaf.person_id = p_person_id
                                              			                           and paaf.assignment_id=paei.assignment_id
			                                                                   and paei.information_type = 'IE_ASG_OVERRIDE'
			                                                                   and paei.aei_information1 = c_ppsn     --'314678745T'
			                                                                  ))) /* knadhan12 */
  AND paa.payroll_action_id=ppa.payroll_action_id
  AND ppa.action_type in ('Q','B','R','I','V')
  AND ppa.action_status ='C'
  AND paa.source_action_id is null
  AND ppa.effective_date<= to_date('30/04/2009','dd/mm/yyyy');
l_defined_balance_id pay_defined_balances.defined_balance_id%type;
l_balance_value                  NUMBER:=0;
l_balance_value1                 NUMBER:=0;
/* 8615992 */
l_assignment_action_apr_09 pay_assignment_actions.assignment_action_id%type;
l_balance_value_apr_09           NUMBER:=0;
l_balance_value1_apr_09          NUMBER:=0;
l_cess_last_bal_value		 NUMBER :=0;
l_cess_last_bal_value_apr_09	 NUMBER :=0;
l_prev_source_id_apr_09  	 number;
l_payroll_effective_date         date;
l_action_effective_date          date;
l_child_action_eff_date          date;

l_gross_pay         number:=0;
l_gross_pay_adjust         number:=0;
l_bik_prsi_taxable          number:=0;
l_income_levy        number:=0;
l_gross_pay_total         number:=0;

l_gross_pay_apr_09            number:=0;
l_gross_pay_adjust_apr_09     number:=0;
l_bik_prsi_taxable_apr_09     number:=0;
l_income_levy_apr_09          number:=0;
l_gross_pay_total_apr_09      number:=0;
l_prev_source_id			 number;

CURSOR csr_get_org_tax_address(g_paye_ref    number
                                  ) IS
  SELECT
           hrl.address_line_1        employer_tax_addr1,
           hrl.address_line_2        employer_tax_addr2,
           hrl.address_line_3        employer_tax_addr3,
	   org_info.org_information2 employer_no,
           hrl.telephone_number_1    employer_tax_ref_phone,
           org_all.name              employer_tax_rep_name,
	   org_info1.org_information3 email    /* knadhan */


    FROM   hr_all_organization_units   org_all
          ,hr_organization_information org_info
          ,hr_locations_all hrl
	  ,hr_organization_information org_info1

    WHERE  org_info.organization_id  = org_all.organization_id
    AND    org_info.org_information_context  = 'IE_EMPLOYER_INFO' --for migration changes 4369280
    AND    org_all.location_id = hrl.location_id (+)
    AND    org_info1.org_information_context (+)  = 'ORG_CONTACT_DETAILS'
    AND    org_info1.org_information1 (+)  ='EMAIL'
    AND    org_info.organization_id = g_paye_ref
    AND    org_all.organization_id = org_info1.organization_id (+)
    ;

csr_get_org_tax_address_rec csr_get_org_tax_address%ROWTYPE;
 /* knadhan */

cursor csr_ppsn_override(p_asg_id number)
is
select aei_information1 PPSN_OVERRIDE
from per_assignment_extra_info
where assignment_id = p_asg_id
and aei_information_category = 'IE_ASG_OVERRIDE';

l_ppsn_override per_assignment_extra_info.aei_information1%type:=null;


BEGIN
  --
     hr_utility.set_location('Entering ' || l_proc,20);
    hr_utility.set_location('Step ' || l_proc,20);
    hr_utility.set_location('p_action_context_id  = ' || p_action_context_id,20);
    hr_utility.set_location('p_assignment_id      = ' || p_assignment_id,20);
    hr_utility.set_location('p_payroll_id      = ' || p_payroll_id,20);
    hr_utility.set_location('p_date_earned      = ' || p_date_earned,20);
    hr_utility.set_location('p_child_run_ass_act_id      = ' || p_child_run_ass_act_id,20);
    hr_utility.set_location('p_supp_flag      = ' || p_supp_flag,20);
    hr_utility.set_location('p_person_id          = ' || p_person_id,20);
    hr_utility.set_location('p_termination_date           = ' || p_termination_date,20);
    hr_utility.set_location('p_child_pay_action           = ' || p_child_pay_action,20);
    hr_utility.set_location('p_supp_pymt_date           = ' || p_supp_pymt_date,20);
    hr_utility.set_location('p_deceased_flag           = ' || p_deceased_flag,20);
    hr_utility.set_location('p_last_cess_action           = ' || p_last_cess_action,20);
    hr_utility.set_location('p_prev_src_id           = ' || p_prev_src_id,20);
    hr_utility.set_location('g_paye_ref           = ' || g_paye_ref,20);

 hr_utility.set_location('before PPSN cursor   l_ppsn_override         = ' || l_ppsn_override,20);
   OPEN csr_ppsn_override(p_assignment_id);
   FETCH csr_ppsn_override INTO l_ppsn_override;
   IF csr_ppsn_override%NOTFOUND THEN
   l_ppsn_override:=null;
   END IF;

   CLOSE csr_ppsn_override;
   hr_utility.set_location('after PPSN cursor   l_ppsn_override         = ' || l_ppsn_override,20);


  l_supp_flg := p_supp_flag;
  l_supp_pymt_date := p_supp_pymt_date;
  l_termination_date := p_termination_date;
  hr_utility.set_location('supplementary flag = '||l_supp_flg,20);
  hr_utility.set_location('supplementary date = '||l_supp_pymt_date,20);

IF l_ppsn_override is null THEN
OPEN cur_defined_balance_id('IE Gross Income','_PER_PAYE_REF_YTD');
hr_utility.set_location(' balance type  _PER_PAYE_REF_YTD' ,30);

ELSE
OPEN cur_defined_balance_id('IE Gross Income','_PER_PAYE_REF_PPSN_YTD');
hr_utility.set_location(' balance type  _PER_PAYE_REF_PPSN_YTD' ,30);
END IF;

FETCH cur_defined_balance_id INTO l_defined_balance_id;
CLOSE cur_defined_balance_id;

hr_utility.set_location(' l_defined_balance_id' || l_defined_balance_id,30);
hr_utility.set_location(' l_balance_value' || l_balance_value,30);
IF (p_child_run_ass_act_id IS NOT NULL) THEN /* 8615992 */
l_balance_value := PAY_BALANCE_PKG.GET_VALUE(l_defined_balance_id,
    			                 p_child_run_ass_act_id,
                                   g_paye_ref,
                                   null,
                                   null,
                                   null,
                                   null,
                                   null);
ELSE
l_balance_value:=0;
END IF;
hr_utility.set_location(' l_balance_value' || l_balance_value,30);
IF (nvl(p_supp_flag,'N') = 'N') AND (p_last_cess_action IS NOT NULL) THEN
l_cess_last_bal_value := PAY_BALANCE_PKG.GET_VALUE(l_defined_balance_id,
    			                           p_prev_src_id,
					           g_paye_ref,
						   null,
						   null,
						   null,
						   null,
						   null);
hr_utility.set_location(' l_cess_last_bal_value' || l_cess_last_bal_value,30);
l_balance_value:=l_balance_value - l_cess_last_bal_value;
END IF;

IF p_supp_flag ='Y' THEN

OPEN get_last_source_id;
FETCH get_last_source_id into l_prev_source_id;
CLOSE get_last_source_id;

hr_utility.set_location(' l_prev_source_id' || l_prev_source_id,30);
IF l_prev_source_id IS NOT NULL THEN /* 9337590 */
l_balance_value1 := PAY_BALANCE_PKG.GET_VALUE(l_defined_balance_id,
						     l_prev_source_id,
						     g_paye_ref,
						     null,
						     null,
						     null,
						     null,
						     null);
hr_utility.set_location(' l_balance_value1' || l_balance_value1,30);
END IF;
ELSE
l_balance_value1:=0;
hr_utility.set_location(' l_balance_value1' || l_balance_value1,30);
END IF;
l_gross_pay := l_balance_value - l_balance_value1;

hr_utility.set_location(' l_gross_pay' || l_gross_pay,30);

l_defined_balance_id:=null;
l_balance_value:=0;
l_balance_value1:=0;


IF l_ppsn_override is null THEN
OPEN cur_defined_balance_id('IE Gross Income Adjustment','_PER_PAYE_REF_YTD');
hr_utility.set_location(' balance type  _PER_PAYE_REF_YTD' ,30);

ELSE
OPEN cur_defined_balance_id('IE Gross Income Adjustment','_PER_PAYE_REF_PPSN_YTD');
hr_utility.set_location(' balance type  _PER_PAYE_REF_PPSN_YTD' ,30);
END IF;


FETCH cur_defined_balance_id INTO l_defined_balance_id;
CLOSE cur_defined_balance_id;

hr_utility.set_location(' l_balance_value' || l_balance_value,40);
IF (p_child_run_ass_act_id IS NOT NULL) THEN
l_balance_value := PAY_BALANCE_PKG.GET_VALUE(l_defined_balance_id,
    			                 p_child_run_ass_act_id,
                                   g_paye_ref,
                                   null,
                                   null,
                                   null,
                                   null,
                                   null);
ELSE
l_balance_value:=0;
END IF;
hr_utility.set_location(' l_balance_value' || l_balance_value,40);
IF (nvl(p_supp_flag,'N') = 'N') AND (p_last_cess_action IS NOT NULL) THEN
l_cess_last_bal_value := PAY_BALANCE_PKG.GET_VALUE(l_defined_balance_id,
    			                           p_prev_src_id,
					           g_paye_ref,
						   null,
						   null,
						   null,
						   null,
						   null);
hr_utility.set_location(' l_cess_last_bal_value' || l_cess_last_bal_value,40);
l_balance_value:=l_balance_value - l_cess_last_bal_value;
END IF;

IF p_supp_flag ='Y' THEN

OPEN get_last_source_id;
FETCH get_last_source_id into l_prev_source_id;
CLOSE get_last_source_id;
hr_utility.set_location(' l_prev_source_id' || l_prev_source_id,40);
IF l_prev_source_id IS NOT NULL THEN /* 9337590 */
l_balance_value1 := PAY_BALANCE_PKG.GET_VALUE(l_defined_balance_id,
						     l_prev_source_id,
						     g_paye_ref,
						     null,
						     null,
						     null,
						     null,
						     null);
hr_utility.set_location(' l_balance_value1' || l_balance_value1,40);
END IF;
ELSE
l_balance_value1:=0;
hr_utility.set_location(' l_balance_value1' || l_balance_value1,40);
END IF;
l_gross_pay_adjust := l_balance_value - l_balance_value1;

hr_utility.set_location(' l_gross_pay_adjust' || l_gross_pay_adjust,30);
l_defined_balance_id:=null;
l_balance_value:=0;
l_balance_value1:=0;


l_defined_balance_id:=null;

IF l_ppsn_override is null THEN
OPEN cur_defined_balance_id('IE BIK Taxable and PRSIable Pay','_PER_PAYE_REF_YTD');
hr_utility.set_location(' balance type  _PER_PAYE_REF_YTD' ,30);

ELSE
OPEN cur_defined_balance_id('IE BIK Taxable and PRSIable Pay','_PER_PAYE_REF_PPSN_YTD');
hr_utility.set_location(' balance type  _PER_PAYE_REF_PPSN_YTD' ,30);
END IF;


FETCH cur_defined_balance_id INTO l_defined_balance_id;
CLOSE cur_defined_balance_id;
hr_utility.set_location(' l_balance_value' || l_balance_value,50);
IF (p_child_run_ass_act_id IS NOT NULL) THEN
l_balance_value := PAY_BALANCE_PKG.GET_VALUE(l_defined_balance_id,
    			                 p_child_run_ass_act_id,
                                   g_paye_ref,
                                   null,
                                   null,
                                   null,
                                   null,
                                   null);
ELSE
l_balance_value:=0;
END IF;
hr_utility.set_location(' l_balance_value' || l_balance_value,50);
IF (nvl(p_supp_flag,'N') = 'N') AND (p_last_cess_action IS NOT NULL) THEN
l_cess_last_bal_value := PAY_BALANCE_PKG.GET_VALUE(l_defined_balance_id,
    			                           p_prev_src_id,
					           g_paye_ref,
						   null,
						   null,
						   null,
						   null,
						   null);
hr_utility.set_location(' l_cess_last_bal_value' || l_cess_last_bal_value,50);
l_balance_value:=l_balance_value - l_cess_last_bal_value;
END IF;

IF p_supp_flag ='Y' THEN

OPEN get_last_source_id;
FETCH get_last_source_id into l_prev_source_id;
CLOSE get_last_source_id;
hr_utility.set_location(' l_prev_source_id' || l_prev_source_id,50);
IF l_prev_source_id IS NOT NULL THEN /* 9337590 */
l_balance_value1 := PAY_BALANCE_PKG.GET_VALUE(l_defined_balance_id,
						     l_prev_source_id,
						     g_paye_ref,
						     null,
						     null,
						     null,
						     null,
						     null);
hr_utility.set_location(' l_balance_value1' || l_balance_value1,50);
END IF;
ELSE
l_balance_value1:=0;
hr_utility.set_location(' l_balance_value1' || l_balance_value1,50);
END IF;
l_bik_prsi_taxable := l_balance_value - l_balance_value1;

hr_utility.set_location(' l_bik_prsi_taxable' || l_bik_prsi_taxable,50);

l_defined_balance_id:=null;
l_balance_value:=0;
l_balance_value1:=0;

l_defined_balance_id:=null;

IF l_ppsn_override is null THEN
OPEN cur_defined_balance_id('IE Income Tax Levy','_PER_PAYE_REF_YTD');

hr_utility.set_location(' balance type  _PER_PAYE_REF_YTD' ,30);

ELSE
OPEN cur_defined_balance_id('IE Income Tax Levy','_PER_PAYE_REF_PPSN_YTD');
hr_utility.set_location(' balance type  _PER_PAYE_REF_PPSN_YTD' ,30);
END IF;


FETCH cur_defined_balance_id INTO l_defined_balance_id;
CLOSE cur_defined_balance_id;

hr_utility.set_location(' l_balance_value' || l_balance_value,60);
IF (p_child_run_ass_act_id IS NOT NULL) THEN
 l_balance_value := PAY_BALANCE_PKG.GET_VALUE(l_defined_balance_id,
    			                 p_child_run_ass_act_id,
                                   g_paye_ref,
                                   null,
                                   null,
                                   null,
                                   null,
                                   null);
ELSE
l_balance_value:=0;
END IF;
hr_utility.set_location(' l_balance_value' || l_balance_value,60);
IF (nvl(p_supp_flag,'N') = 'N') AND (p_last_cess_action IS NOT NULL) THEN
l_cess_last_bal_value := PAY_BALANCE_PKG.GET_VALUE(l_defined_balance_id,
    			                           p_prev_src_id,
					           g_paye_ref,
						   null,
						   null,
						   null,
						   null,
						   null);
hr_utility.set_location(' l_cess_last_bal_value' || l_cess_last_bal_value,60);
l_balance_value:=l_balance_value - l_cess_last_bal_value;
END IF;

IF p_supp_flag ='Y' THEN

OPEN get_last_source_id;
FETCH get_last_source_id into l_prev_source_id;
CLOSE get_last_source_id;
hr_utility.set_location(' l_prev_source_id' || l_prev_source_id,60);
IF l_prev_source_id IS NOT NULL THEN /* 9337590 */
l_balance_value1 := PAY_BALANCE_PKG.GET_VALUE(l_defined_balance_id,
						     l_prev_source_id,
						     g_paye_ref,
						     null,
						     null,
						     null,
						     null,
						     null);
hr_utility.set_location(' l_balance_value1' || l_balance_value1,60);
END IF;
ELSE
l_balance_value1:=0;
hr_utility.set_location(' l_balance_value1' || l_balance_value1,60);
END IF;
l_income_levy := l_balance_value - l_balance_value1;
hr_utility.set_location(' l_income_levy' || l_income_levy,30);
/* ---------------------------------------------------------------------------------------- */
/* 8615992 fetch the till april balance and make the split accordingly */

OPEN  get_asg_action_eff_date(p_child_run_ass_act_id);
FETCH get_asg_action_eff_date INTO l_child_action_eff_date;
CLOSE get_asg_action_eff_date;
hr_utility.set_location(' l_child_action_eff_date' || l_child_action_eff_date,60);
IF l_child_action_eff_date is not null and (to_char(l_child_action_eff_date,'yyyy') = '2009')
THEN
   OPEN  cur_assignment_action_apr_09(l_ppsn_override);
   FETCH cur_assignment_action_apr_09 into l_assignment_action_apr_09;
   CLOSE cur_assignment_action_apr_09;

   hr_utility.set_location(' l_assignment_action_apr_09 '||l_assignment_action_apr_09 ,30);

 /* gross pay */
  IF l_ppsn_override is null THEN
    OPEN cur_defined_balance_id('IE Gross Income','_PER_PAYE_REF_YTD');
    hr_utility.set_location(' balance type  _PER_PAYE_REF_YTD' ,30);
  ELSE
    OPEN cur_defined_balance_id('IE Gross Income','_PER_PAYE_REF_PPSN_YTD');
    hr_utility.set_location(' balance type  _PER_PAYE_REF_PPSN_YTD' ,30);
  END IF;

  FETCH cur_defined_balance_id INTO l_defined_balance_id;
  CLOSE cur_defined_balance_id;

  hr_utility.set_location(' l_defined_balance_id' || l_defined_balance_id,30);
  hr_utility.set_location(' l_balance_value_apr_09' || l_balance_value_apr_09,30);
  IF l_assignment_action_apr_09 is not null THEN
  l_balance_value_apr_09 := PAY_BALANCE_PKG.GET_VALUE(l_defined_balance_id,
    			                 l_assignment_action_apr_09,
                                   g_paye_ref,
                                   null,
                                   null,
                                   null,
                                   null,
                                   null);
   END IF;
  hr_utility.set_location(' l_balance_value_apr_09' || l_balance_value_apr_09,30);
  IF (nvl(p_supp_flag,'N') = 'N') AND (p_last_cess_action IS NOT NULL) and l_assignment_action_apr_09 is not NULL THEN
      OPEN  get_asg_action_eff_date(p_prev_src_id);
      FETCH get_asg_action_eff_date INTO l_action_effective_date;
      CLOSE get_asg_action_eff_date;
      hr_utility.set_location('l_action_effective_date = ' || l_action_effective_date,40);
      IF l_action_effective_date is not null and  l_action_effective_date <= to_date('30/04/2009','dd/mm/yyyy') THEN
      l_cess_last_bal_value_apr_09 := PAY_BALANCE_PKG.GET_VALUE(l_defined_balance_id,
    			                           p_prev_src_id,
					           g_paye_ref,
						   null,
						   null,
						   null,
						   null,
						   null);
       hr_utility.set_location(' l_cess_last_bal_value_apr_09' || l_cess_last_bal_value_apr_09,30);
       ELSE
       l_cess_last_bal_value_apr_09 :=0;
       END IF;
      l_balance_value_apr_09:=l_balance_value_apr_09 - l_cess_last_bal_value_apr_09;
END IF;
  IF p_supp_flag ='Y' THEN


      OPEN get_last_source_id_apr_09;
      FETCH get_last_source_id_apr_09 into l_prev_source_id_apr_09,l_payroll_effective_date;
      CLOSE get_last_source_id_apr_09;

      hr_utility.set_location(' l_prev_source_id_apr_09' || l_prev_source_id_apr_09,40);
      hr_utility.set_location('l_payroll_effective_date = ' || l_payroll_effective_date,40);
      IF l_prev_source_id_apr_09 is not null and l_assignment_action_apr_09 is not null  and l_payroll_effective_date <= to_date('30/04/2009','dd/mm/yyyy') THEN
      l_balance_value1_apr_09 := PAY_BALANCE_PKG.GET_VALUE(l_defined_balance_id,
						     l_prev_source_id_apr_09,
						     g_paye_ref,
						     null,
						     null,
						     null,
						     null,
						     null);

      hr_utility.set_location(' l_balance_value1_apr_09' || l_balance_value1_apr_09,40);

      ELSE
      l_balance_value_apr_09:=0;
      l_balance_value1_apr_09:=0;
      END IF;

      ELSE
        l_balance_value1_apr_09:=0;
      hr_utility.set_location(' l_balance_value1_apr_09' || l_balance_value1_apr_09,40);
  END IF;

hr_utility.set_location(' l_balance_value_apr_09' || l_balance_value_apr_09,100);
hr_utility.set_location(' l_balance_value1_apr_09' || l_balance_value1_apr_09,100);

l_gross_pay_apr_09 := nvl(l_balance_value_apr_09,0) - nvl(l_balance_value1_apr_09,0);
hr_utility.set_location(' l_gross_pay' || l_gross_pay,40);
hr_utility.set_location(' l_gross_pay_apr_09' || l_gross_pay_apr_09,40);
l_gross_pay := l_gross_pay - l_gross_pay_apr_09;
hr_utility.set_location(' l_gross_pay from may 2009 ' || l_gross_pay,40);
l_defined_balance_id:=null;
l_balance_value_apr_09:=0;
l_balance_value1_apr_09:=0;


/* gross pay adjust */
  IF l_ppsn_override is null THEN
    OPEN cur_defined_balance_id('IE Gross Income Adjustment','_PER_PAYE_REF_YTD');
    hr_utility.set_location(' balance type  _PER_PAYE_REF_YTD' ,30);
  ELSE
    OPEN cur_defined_balance_id('IE Gross Income Adjustment','_PER_PAYE_REF_PPSN_YTD');
    hr_utility.set_location(' balance type  _PER_PAYE_REF_PPSN_YTD' ,30);
  END IF;

  FETCH cur_defined_balance_id INTO l_defined_balance_id;
  CLOSE cur_defined_balance_id;

  hr_utility.set_location(' l_defined_balance_id' || l_defined_balance_id,30);
  hr_utility.set_location(' l_balance_value_apr_09' || l_balance_value_apr_09,30);
  IF l_assignment_action_apr_09 is not null THEN
  l_balance_value_apr_09 := PAY_BALANCE_PKG.GET_VALUE(l_defined_balance_id,
    			                 l_assignment_action_apr_09,
                                   g_paye_ref,
                                   null,
                                   null,
                                   null,
                                   null,
                                   null);
   END IF;
  hr_utility.set_location(' l_balance_value_apr_09' || l_balance_value_apr_09,30);
  IF (nvl(p_supp_flag,'N') = 'N') AND (p_last_cess_action IS NOT NULL) and l_assignment_action_apr_09 is not NULL THEN
      OPEN  get_asg_action_eff_date(p_prev_src_id);
      FETCH get_asg_action_eff_date INTO l_action_effective_date;
      CLOSE get_asg_action_eff_date;
      hr_utility.set_location('l_action_effective_date = ' || l_action_effective_date,40);
      IF l_action_effective_date is not null and  l_action_effective_date <= to_date('30/04/2009','dd/mm/yyyy') THEN
      l_cess_last_bal_value_apr_09 := PAY_BALANCE_PKG.GET_VALUE(l_defined_balance_id,
    			                           p_prev_src_id,
					           g_paye_ref,
						   null,
						   null,
						   null,
						   null,
						   null);
       hr_utility.set_location(' l_cess_last_bal_value_apr_09' || l_cess_last_bal_value_apr_09,30);
       ELSE
       l_cess_last_bal_value_apr_09 :=0;
       END IF;
      l_balance_value_apr_09:=l_balance_value_apr_09 - l_cess_last_bal_value_apr_09;
  END IF;
  IF p_supp_flag ='Y' THEN

      OPEN get_last_source_id_apr_09;
      FETCH get_last_source_id_apr_09 into l_prev_source_id_apr_09,l_payroll_effective_date;
      CLOSE get_last_source_id_apr_09;

      hr_utility.set_location(' l_prev_source_id_apr_09' || l_prev_source_id_apr_09,40);
      hr_utility.set_location('l_payroll_effective_date = ' || l_payroll_effective_date,40);
      IF l_prev_source_id_apr_09 is not null and l_assignment_action_apr_09 is not null  and l_payroll_effective_date <= to_date('30/04/2009','dd/mm/yyyy') THEN
      l_balance_value1_apr_09 := PAY_BALANCE_PKG.GET_VALUE(l_defined_balance_id,
						     l_prev_source_id_apr_09,
						     g_paye_ref,
						     null,
						     null,
						     null,
						     null,
						     null);

      hr_utility.set_location(' l_balance_value1_apr_09' || l_balance_value1_apr_09,40);

      ELSE
      l_balance_value_apr_09:=0;
      l_balance_value1_apr_09:=0;
      END IF;

      ELSE
        l_balance_value1_apr_09:=0;
      hr_utility.set_location(' l_balance_value1_apr_09' || l_balance_value1_apr_09,40);
  END IF;

hr_utility.set_location(' l_balance_value_apr_09' || l_balance_value_apr_09,100);
hr_utility.set_location(' l_balance_value1_apr_09' || l_balance_value1_apr_09,100);

l_gross_pay_adjust_apr_09 := nvl(l_balance_value_apr_09,0) - nvl(l_balance_value1_apr_09,0);
hr_utility.set_location(' l_gross_pay_adjust' || l_gross_pay_adjust,40);
hr_utility.set_location(' l_gross_pay_adjust_apr_09' || l_gross_pay_adjust_apr_09,40);
l_gross_pay_adjust := l_gross_pay_adjust - l_gross_pay_adjust_apr_09;
hr_utility.set_location(' l_gross_pay_adjust from may 2009 ' || l_gross_pay_adjust,40);
l_defined_balance_id:=null;
l_balance_value_apr_09:=0;
l_balance_value1_apr_09:=0;


/* IE BIK PRSIable and Taxanel pay */
  IF l_ppsn_override is null THEN
    OPEN cur_defined_balance_id('IE BIK Taxable and PRSIable Pay','_PER_PAYE_REF_YTD');
    hr_utility.set_location(' balance type  _PER_PAYE_REF_YTD' ,30);
  ELSE
    OPEN cur_defined_balance_id('IE BIK Taxable and PRSIable Pay','_PER_PAYE_REF_PPSN_YTD');
    hr_utility.set_location(' balance type  _PER_PAYE_REF_PPSN_YTD' ,30);
  END IF;

  FETCH cur_defined_balance_id INTO l_defined_balance_id;
  CLOSE cur_defined_balance_id;

  hr_utility.set_location(' l_defined_balance_id' || l_defined_balance_id,30);
  hr_utility.set_location(' l_balance_value_apr_09' || l_balance_value_apr_09,30);
  IF l_assignment_action_apr_09 is not null THEN
  l_balance_value_apr_09 := PAY_BALANCE_PKG.GET_VALUE(l_defined_balance_id,
    			                 l_assignment_action_apr_09,
                                   g_paye_ref,
                                   null,
                                   null,
                                   null,
                                   null,
                                   null);
   END IF;
  hr_utility.set_location(' l_balance_value_apr_09' || l_balance_value_apr_09,30);

  IF (nvl(p_supp_flag,'N') = 'N') AND (p_last_cess_action IS NOT NULL) and l_assignment_action_apr_09 is not NULL THEN
      OPEN  get_asg_action_eff_date(p_prev_src_id);
      FETCH get_asg_action_eff_date INTO l_action_effective_date;
      CLOSE get_asg_action_eff_date;
      hr_utility.set_location('l_action_effective_date = ' || l_action_effective_date,40);
      IF l_action_effective_date is not null and  l_action_effective_date <= to_date('30/04/2009','dd/mm/yyyy') THEN
      l_cess_last_bal_value_apr_09 := PAY_BALANCE_PKG.GET_VALUE(l_defined_balance_id,
    			                           p_prev_src_id,
					           g_paye_ref,
						   null,
						   null,
						   null,
						   null,
						   null);
       hr_utility.set_location(' l_cess_last_bal_value_apr_09' || l_cess_last_bal_value_apr_09,30);
       ELSE
       l_cess_last_bal_value_apr_09 :=0;
       END IF;
      l_balance_value_apr_09:=l_balance_value_apr_09 - l_cess_last_bal_value_apr_09;
  END IF;
  IF p_supp_flag ='Y' THEN

      OPEN get_last_source_id_apr_09;
      FETCH get_last_source_id_apr_09 into l_prev_source_id_apr_09,l_payroll_effective_date;
      CLOSE get_last_source_id_apr_09;

      hr_utility.set_location(' l_prev_source_id_apr_09' || l_prev_source_id_apr_09,40);
      hr_utility.set_location('l_payroll_effective_date = ' || l_payroll_effective_date,40);
      IF l_prev_source_id_apr_09 is not null and l_assignment_action_apr_09 is not null  and l_payroll_effective_date <= to_date('30/04/2009','dd/mm/yyyy') THEN
      l_balance_value1_apr_09 := PAY_BALANCE_PKG.GET_VALUE(l_defined_balance_id,
						     l_prev_source_id_apr_09,
						     g_paye_ref,
						     null,
						     null,
						     null,
						     null,
						     null);

      hr_utility.set_location(' l_balance_value1_apr_09' || l_balance_value1_apr_09,40);

      ELSE
      l_balance_value_apr_09:=0;
      l_balance_value1_apr_09:=0;
      END IF;

      ELSE
        l_balance_value1_apr_09:=0;
      hr_utility.set_location(' l_balance_value1_apr_09' || l_balance_value1_apr_09,40);
  END IF;
hr_utility.set_location(' l_balance_value_apr_09' || l_balance_value_apr_09,100);
hr_utility.set_location(' l_balance_value1_apr_09' || l_balance_value1_apr_09,100);

l_bik_prsi_taxable_apr_09 := nvl(l_balance_value_apr_09,0) - nvl(l_balance_value1_apr_09,0);
hr_utility.set_location(' l_bik_prsi_taxable' || l_bik_prsi_taxable,40);
hr_utility.set_location(' l_bik_prsi_taxable_apr_09' || l_bik_prsi_taxable_apr_09,40);
l_bik_prsi_taxable := l_bik_prsi_taxable - l_bik_prsi_taxable_apr_09;
hr_utility.set_location(' l_bik_prsi_taxable from may 2009 ' || l_bik_prsi_taxable,40);
l_defined_balance_id:=null;
l_balance_value_apr_09:=0;
l_balance_value1_apr_09:=0;


/* IE Incoem Levy */
  IF l_ppsn_override is null THEN
    OPEN cur_defined_balance_id('IE Income Tax Levy','_PER_PAYE_REF_YTD');
    hr_utility.set_location(' balance type  _PER_PAYE_REF_YTD' ,30);
  ELSE
    OPEN cur_defined_balance_id('IE Income Tax Levy','_PER_PAYE_REF_PPSN_YTD');
    hr_utility.set_location(' balance type  _PER_PAYE_REF_PPSN_YTD' ,30);
  END IF;

  FETCH cur_defined_balance_id INTO l_defined_balance_id;
  CLOSE cur_defined_balance_id;

  hr_utility.set_location(' l_defined_balance_id' || l_defined_balance_id,30);
  hr_utility.set_location(' l_balance_value_apr_09' || l_balance_value_apr_09,30);
  IF l_assignment_action_apr_09 is not null THEN
  l_balance_value_apr_09 := PAY_BALANCE_PKG.GET_VALUE(l_defined_balance_id,
    			                 l_assignment_action_apr_09,
                                   g_paye_ref,
                                   null,
                                   null,
                                   null,
                                   null,
                                   null);
   END IF;
  hr_utility.set_location(' l_balance_value_apr_09' || l_balance_value_apr_09,30);
  IF (nvl(p_supp_flag,'N') = 'N') AND (p_last_cess_action IS NOT NULL) and l_assignment_action_apr_09 is not NULL THEN
      OPEN  get_asg_action_eff_date(p_prev_src_id);
      FETCH get_asg_action_eff_date INTO l_action_effective_date;
      CLOSE get_asg_action_eff_date;
      hr_utility.set_location('l_action_effective_date = ' || l_action_effective_date,40);
      IF l_action_effective_date is not null and  l_action_effective_date <= to_date('30/04/2009','dd/mm/yyyy') THEN
      l_cess_last_bal_value_apr_09 := PAY_BALANCE_PKG.GET_VALUE(l_defined_balance_id,
    			                           p_prev_src_id,
					           g_paye_ref,
						   null,
						   null,
						   null,
						   null,
						   null);
       hr_utility.set_location(' l_cess_last_bal_value_apr_09' || l_cess_last_bal_value_apr_09,30);
       ELSE
       l_cess_last_bal_value_apr_09 :=0;
       END IF;
      l_balance_value_apr_09:=l_balance_value_apr_09 - l_cess_last_bal_value_apr_09;
   END IF;
  IF p_supp_flag ='Y' THEN

      OPEN get_last_source_id_apr_09;
      FETCH get_last_source_id_apr_09 into l_prev_source_id_apr_09,l_payroll_effective_date;
      CLOSE get_last_source_id_apr_09;

      hr_utility.set_location(' l_prev_source_id_apr_09' || l_prev_source_id_apr_09,40);
      hr_utility.set_location('l_payroll_effective_date = ' || l_payroll_effective_date,40);
      IF l_prev_source_id_apr_09 is not null and l_assignment_action_apr_09 is not null  and l_payroll_effective_date <= to_date('30/04/2009','dd/mm/yyyy') THEN
      l_balance_value1_apr_09 := PAY_BALANCE_PKG.GET_VALUE(l_defined_balance_id,
						     l_prev_source_id_apr_09,
						     g_paye_ref,
						     null,
						     null,
						     null,
						     null,
						     null);

      hr_utility.set_location(' l_balance_value1_apr_09' || l_balance_value1_apr_09,40);
      ELSE
      l_balance_value_apr_09:=0;
      l_balance_value1_apr_09:=0;
      END IF;

      ELSE
        l_balance_value1_apr_09:=0;
      hr_utility.set_location(' l_balance_value1_apr_09' || l_balance_value1_apr_09,40);
  END IF;
hr_utility.set_location(' l_balance_value_apr_09' || l_balance_value_apr_09,100);
hr_utility.set_location(' l_balance_value1_apr_09' || l_balance_value1_apr_09,100);

l_income_levy_apr_09 := nvl(l_balance_value_apr_09,0) - nvl(l_balance_value1_apr_09,0);
hr_utility.set_location(' l_income_levy' || l_income_levy,40);
hr_utility.set_location(' l_income_levy_apr_09' || l_income_levy_apr_09,40);
l_income_levy := l_income_levy - l_income_levy_apr_09;
hr_utility.set_location(' l_income_levy from may 2009 ' || l_income_levy,40);
l_defined_balance_id:=null;
l_balance_value_apr_09:=0;
l_balance_value1_apr_09:=0;

l_gross_pay_total_apr_09 :=l_gross_pay_apr_09+l_gross_pay_adjust_apr_09+l_bik_prsi_taxable_apr_09;
 END IF;
/* ---------------------------------------------------------------------------------------------- */
l_gross_pay_total :=l_gross_pay+l_gross_pay_adjust+l_bik_prsi_taxable;

hr_utility.set_location(' l_gross_pay_total' || l_gross_pay_total,30);

OPEN c_employee_details(p_assignment_id,p_date_earned);
FETCH c_employee_details INTO c_employee_details_rec;
CLOSE c_employee_details;
  -- CLOSE cur_cal_option;
OPEN csr_get_org_tax_address(g_paye_ref);
FETCH csr_get_org_tax_address INTO csr_get_org_tax_address_rec;
CLOSE csr_get_org_tax_address;
   --
   -- archive the details
    pay_action_information_api.create_action_information (
         p_action_information_id        =>  l_action_info_id
       , p_action_context_id            =>  p_action_context_id
       , p_action_context_type          =>  'AAP'
       , p_object_version_number        =>  l_ovn
       , p_effective_date               =>  g_archive_effective_date
       , p_source_id                    =>  p_child_run_ass_act_id
       , p_source_text                  =>  NULL
       , p_action_information_category  =>  'IE CESS INFORMATION'
      -- , p_action_information1          =>  p_deceased_flag   /* knadhan */
       , p_action_information2          =>  l_supp_flg
       , p_action_information3          =>  fnd_date.date_to_canonical(l_termination_date)
       , p_action_information7          =>  l_supp_pymt_date
       , p_action_information8          =>  p_person_id
       , p_action_information9          =>  fnd_date.date_to_canonical(p_date_earned)
       , p_action_information10         =>  upper(csr_get_org_tax_address_rec.employer_tax_rep_name)
       , p_action_information11         =>  upper(csr_get_org_tax_address_rec.employer_tax_addr1)
       , p_action_information12         =>  upper(csr_get_org_tax_address_rec.employer_tax_addr2)
       , p_action_information13         =>  upper(csr_get_org_tax_address_rec.employer_tax_addr3)
       , p_action_information14         =>  lpad(upper(csr_get_org_tax_address_rec.employer_no), 8, ' ')
       , p_action_information15         =>  lpad(translate(csr_get_org_tax_address_rec.employer_tax_ref_phone,'1()-', '1'), 11, ' ')
       , p_action_information16         =>  upper(csr_get_org_tax_address_rec.email)  /* knadhan */
       , p_action_information20          => upper(c_employee_details_rec.surname)  -- surname
       , p_action_information21          => upper(c_employee_details_rec.first_name)  -- first_name
       , p_action_information22          => upper(nvl(l_ppsn_override,c_employee_details_rec.PPSN))  -- PPSN
       , p_action_information23          => lpad(upper(c_employee_details_rec.works_no), 9, ' ') -- works_no
       , p_action_information24          => fnd_date.date_to_canonical(c_employee_details_rec.hire_date)

     /* 8615992 */
       , p_action_information25          => lpad(trim(to_char(fnd_number.canonical_to_number(nvl(l_gross_pay_total_apr_09+l_gross_pay_total,0)) ,'9999999')),7,' ') -- lpad(l_gross_pay_total,10,' ') /* 9337590 */
       , p_action_information26          => lpad(trim(to_char(fnd_number.canonical_to_number(nvl(l_income_levy_apr_09+l_income_levy,0)) ,'999990.99')),8,' ') -- lpad(l_income_levy,10,' ')    /* 9337590 */
       , p_action_information27          => lpad(trim(to_char(fnd_number.canonical_to_number(nvl(l_gross_pay_total_apr_09,0)) ,'9999999')),7,' ') -- lpad(l_gross_pay_total,10,' ') /* knadhan */
       , p_action_information28          => lpad(trim(to_char(fnd_number.canonical_to_number(nvl(l_income_levy_apr_09,0)) ,'999990.99')),8,' ') -- lpad(l_income_levy,10,' ')    /* knadhan */
       , p_action_information29          => lpad(trim(to_char(fnd_number.canonical_to_number(nvl(l_gross_pay_total,0)) ,'9999999')),7,' ') -- lpad(l_gross_pay_total,10,' ') /* knadhan */
       , p_action_information30          => lpad(trim(to_char(fnd_number.canonical_to_number(nvl(l_income_levy,0)) ,'999990.99')),8,' ') -- lpad(l_income_levy,10,' ')    /* knadhan */


      );
  --
  hr_utility.set_location('Leaving '||l_proc,20);
  END archive_cess_info;



  /* Range Cursor */

PROCEDURE range_code (pactid IN NUMBER,
                          sqlstr OUT nocopy VARCHAR2)
  -- public procedure which archives the payroll information, then returns a
  -- varchar2 defining a SQL statement to select all the people that may be
  -- eligible for payslip reports.
  -- The archiver uses this cursor to split the people into chunks for parallel
  -- processing.
  IS
  --
  l_proc    CONSTANT VARCHAR2(50):= g_package||'range_code';
    -- vars for constructing the sqlstr

  l_bg_id                           NUMBER;
  l_end_date                        VARCHAR2(30);
  l_start_date                      VARCHAR2(30);
  l_employer                        NUMBER;

  BEGIN
  -- hr_utility.trace_on(null,'cess');
    hr_utility.set_location('Entering ' || l_proc,10);

    pay_ie_cess_report.get_parameters (
      p_payroll_action_id => pactid
    , p_token_name        => 'END_DATE'
    , p_token_value       => l_end_date);

    pay_ie_cess_report.get_parameters (
      p_payroll_action_id => pactid
    , p_token_name        => 'BG_ID'
    , p_token_value       => l_bg_id);

    pay_ie_cess_report.get_parameters (
      p_payroll_action_id => pactid
    , p_token_name        => 'EMPLOYER'
    , p_token_value       => l_employer);

    pay_ie_cess_report.get_parameters (
      p_payroll_action_id => pactid
    , p_token_name        => 'START_DATE'
    , p_token_value       => l_start_date);

    hr_utility.set_location('Step ' || l_proc,20);

   hr_utility.set_location('l_start_date = ' || l_start_date,20);
   hr_utility.set_location('l_end_date   = ' || l_end_date,20);
   hr_utility.set_location('l_employer = ' || l_employer,20);
   hr_utility.set_location('l_bg_id = ' || l_bg_id,20);

    sqlstr := 'SELECT DISTINCT person_id
               FROM   per_people_f ppf,
                      pay_payroll_actions ppa
               WHERE  ppa.payroll_action_id = :payroll_action_id
               AND    ppa.business_group_id +0= ppf.business_group_id
               ORDER BY ppf.person_id';

   hr_utility.set_location('After sqlstr formed ' || l_proc,30);

    hr_utility.set_location('Leaving ' || l_proc,40);

  Exception
  when others then
   hr_utility.set_location('Leaving via exception section ' || l_proc,40);
   sqlstr:='select 1 from dual where to_char(:payroll_action_id) = dummy';
  END range_code;


/* Action Creation */

  PROCEDURE assignment_action_code (pactid in number,
                             stperson in number,
                             endperson in number,
                             chunk in number) is
  --
  CURSOR csr_prepaid_assignments(p_pact_id          NUMBER,
                                 stperson           NUMBER,
                                 endperson          NUMBER,
                                 p_paye_ref         NUMBER,
				 l_payroll_id       NUMBER,
				 l_person_id        NUMBER
                                 ) IS
  SELECT as1.person_id person_id,
	 act.assignment_id assignment_id,
         act.assignment_action_id run_action_id,
         act1.assignment_action_id prepaid_action_id,
	 as1.assignment_number works_number,
	 as1.period_of_service_id period_of_service_id
  FROM   --per_periods_of_service ppos,
         per_all_assignments_f as1,
         pay_assignment_actions act,
         pay_payroll_actions appa,
         pay_action_interlocks pai,
         pay_assignment_actions act1,
         pay_payroll_actions appa2
  WHERE  /*appa.consolidation_set_id = p_consolidation_id*/
         act.tax_unit_id = p_paye_ref
  AND    appa.effective_date BETWEEN g_archive_start_date AND g_archive_end_date
  AND    as1.person_id BETWEEN stperson AND endperson

  AND    as1.effective_end_date between g_archive_start_date AND g_archive_end_date
  AND  (as1.effective_end_date = (select max(effective_end_date)
                                    from  per_all_assignments_f paf1
                                   where paf1.assignment_id = as1.assignment_id

                                     and   paf1.assignment_status_type_id in
                                           (SELECT ast.assignment_status_type_id
                                              FROM per_assignment_status_types ast
  					     WHERE  ast.per_system_status in ('ACTIVE_ASSIGN','SUSP_ASSIGN')
  					   )
			         )
        AND    as1.effective_end_date <> to_date('31-12-4712','DD-MM-YYYY')
       )
  AND (as1.payroll_id in (select b.payroll_id
                            from per_assignments_f a,per_assignments_f b
			   where a.payroll_id = l_payroll_id
			     and a.person_id = b.person_id
			     and a.period_of_Service_id = b.period_of_Service_id
			     and a.period_of_Service_id = as1.period_of_Service_id
			     and a.person_id  = as1.person_id
                             and a.effective_start_date <= g_archive_end_date


			     and a.effective_end_date = (select max(effective_end_date)
                                                           from  per_all_assignments_f paf1
                                                          where paf1.assignment_id = a.assignment_id
                                                            and   paf1.assignment_status_type_id in
                                           (SELECT ast.assignment_status_type_id
                                              FROM per_assignment_status_types ast
  					     WHERE  ast.per_system_status in ('ACTIVE_ASSIGN','SUSP_ASSIGN')
  					   )
					                 )
			 )
       OR l_payroll_id is null)

  --
  AND    appa.action_type IN ('R','Q')                             -- Payroll Run or Quickpay Run
  AND    act.payroll_action_id = appa.payroll_action_id
  AND    act.source_action_id IS NULL
  AND    as1.assignment_id = act.assignment_id
  AND    act.action_status = 'C'
  AND    act.assignment_action_id = pai.locked_action_id
  AND    act1.assignment_action_id = pai.locking_action_id
  AND    act1.action_status = 'C'
  AND    act1.payroll_action_id = appa2.payroll_action_id
  AND    appa2.action_type IN ('P','U') -- Prepayments or Quickpay Prepayments
  AND    appa2.payroll_action_id = (SELECT /*+ USE_NL(ACT2 APPA4)*/
                                        max(appa4.payroll_action_id)
                                  FROM  /*pay_pre_payments ppp, --Bug 4193738 --Bug 4468864*/
					pay_assignment_actions act2,
                                        pay_payroll_actions appa4
                                  WHERE /*ppp.assignment_action_id=act2.assignment_action_id
				  AND*/ act2.assignment_id = act.assignment_id
 				  AND   act2.action_status = 'C'
                                  AND   appa4.payroll_action_id = act2.payroll_action_id
                                  AND   appa4.action_type in ('P','U')
                                  AND appa4.effective_date BETWEEN g_archive_start_date AND g_archive_end_date)
  -- bug 5597735, change the not exists clause.
  -- refer bug 5233518 for more details.
  AND    NOT EXISTS (SELECT /*+ ORDERED use_nl(appa3)*/ null
                      from   pay_assignment_actions act3,
                             pay_payroll_actions appa3,
                             pay_action_interlocks pai, --bug 4208273
                             pay_assignment_actions act2, --bug 4208273
                             pay_payroll_actions appa4 --bug 4208273
                      where  pai.locked_action_id= act3.assignment_action_id
                      and pai.locking_action_id=act2.assignment_action_id
        and    act3.action_sequence  >= act1.action_sequence  --bug 4193738
        and    act3.assignment_id in (select distinct paaf.assignment_id
                                      from  per_all_assignments_f paaf
                                      where paaf.person_id = as1.person_id
                                     )
        and    act3.tax_unit_id = act1.tax_unit_id
        and    act3.action_status = 'C'
        and    act2.action_status = 'C'
        and    act3.payroll_action_id=appa4.payroll_action_id
        and    appa4.action_type in ('P','U')
        and    act2.payroll_action_id = appa3.payroll_action_id
                      and    appa3.action_type = 'X'
                      and    appa3.report_type = 'IE_CESSATION')
   /* check person does not hold employment with the employer between start of year and archive end date */
   AND       NOT EXISTS (
				SELECT MIN(paf.effective_start_date),MAX(paf.effective_end_date)
				FROM per_all_assignments_f paf,
				     pay_all_payrolls_f papf,
				     hr_soft_coding_keyflex scl
				WHERE paf.person_id = as1.person_id
				AND paf.payroll_id = papf.payroll_id
/* changed the cursor to handle case where 2 user defined assignment status exist mapping to
   same per_system_status (5073577) */
				AND paf.assignment_status_type_id in
		                                           (SELECT ast.assignment_status_type_id
                                                              FROM per_assignment_status_types ast
  					                     WHERE  ast.per_system_status in ('ACTIVE_ASSIGN','SUSP_ASSIGN')
  					                   )
				AND  g_archive_end_date  between papf.effective_start_date and papf.effective_end_date
				AND papf.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
				AND scl.segment4 = to_char(p_paye_ref)
				group by paf.assignment_id
				having min(paf.effective_start_date) <= g_archive_end_date
				and    max(paf.effective_end_date) > g_archive_end_date
			  )
  AND as1.person_id =nvl(l_person_id,as1.person_id)  /* knadhan */
  ORDER BY as1.person_id,as1.assignment_number,act.assignment_id
  FOR UPDATE OF as1.assignment_id;



cursor csr_ppsn_override(p_asg_id number)
is
select aei_information1 PPSN_OVERRIDE
from per_assignment_extra_info
where assignment_id = p_asg_id
and aei_information_category = 'IE_ASG_OVERRIDE';

l_ppsn_override per_assignment_extra_info.aei_information1%type;

/*
cursor csr_ppsn_min_asg(p_ppsn_override varchar2, p_person_id number)
is
select MIN(paei.assignment_id) ovrride_asg
from per_assignment_extra_info paei
where paei.information_type = 'IE_ASG_OVERRIDE'
and paei.aei_information1 = p_ppsn_override
and exists
(select 1 from per_all_assignments_f paaf
  where paaf.assignment_id = paei.assignment_id
  and paaf.person_id  = p_person_id)
GROUP BY paei.aei_information1; */
/* 8615992 */
cursor csr_ppsn_min_asg(p_ppsn_override varchar2, p_person_id number,c_period_of_service_id number)
is
select MIN(paei.assignment_id) ovrride_asg
from per_assignment_extra_info paei,per_all_assignments_f paaf
where paei.information_type = 'IE_ASG_OVERRIDE'
and paei.aei_information1 = p_ppsn_override
and paaf.assignment_id = paei.assignment_id
and paaf.person_id  = p_person_id
and paaf.period_of_service_id=c_period_of_service_id
GROUP BY paei.aei_information1;


l_ppsn_override_asg per_assignment_extra_info.assignment_id%type;
l_temp_person_id		per_people_f.person_id%TYPE :=0;


  l_actid                           NUMBER;
  l_canonical_end_date              DATE;
  l_canonical_start_date            DATE;
  l_consolidation_set               VARCHAR2(30);
  l_end_date                        VARCHAR2(20);
  l_payroll_id                      NUMBER;
  l_employee_person_id              NUMBER;
  l_prepay_action_id                NUMBER;
  l_start_date                      VARCHAR2(20);
  l_person_id                       NUMBER;
  l_assignment_id                   NUMBER;
  l_error                           varchar2(1) ;
  l_period_of_service_id            NUMBER;
  l_bg_id                           NUMBER;
 --
  l_proc VARCHAR2(50) := g_package||'assignment_action_code';
  BEGIN

    --hr_utility.trace_on(null,'cess');
    hr_utility.set_location('Entering ' || l_proc,10);
    pay_ie_cess_report.get_parameters (
      p_payroll_action_id => pactid
    , p_token_name        => 'EMPLOYER'
    , p_token_value       => g_paye_ref);

    pay_ie_cess_report.get_parameters (
      p_payroll_action_id => pactid
    , p_token_name        => 'END_DATE'
    , p_token_value       => l_end_date);

    pay_ie_cess_report.get_parameters (
    p_payroll_action_id => pactid
  , p_token_name        => 'BG_ID'
  , p_token_value       => l_bg_id);

      pay_ie_cess_report.get_parameters (
      p_payroll_action_id => pactid
    , p_token_name        => 'START_DATE'
    , p_token_value       => l_start_date);

    pay_ie_cess_report.get_parameters (
      p_payroll_action_id => pactid
    , p_token_name        => 'PAYROLL'
    , p_token_value       => l_payroll_id);

   pay_ie_cess_report.get_parameters (
      p_payroll_action_id => pactid
    , p_token_name        => 'EMPLOYEE'
    , p_token_value       => l_employee_person_id); /* knadhan */

    hr_utility.set_location('Step ' || l_proc,20);
    hr_utility.set_location('g_paye_ref = ' || g_paye_ref,20);
    hr_utility.set_location('l_end_date   = ' || l_end_date,20);
    hr_utility.set_location('l_start_date   = ' || l_start_date,20);
    hr_utility.set_location('l_payroll_id   = ' || l_payroll_id,20);
    hr_utility.set_location('l_employee_person_id   = ' || l_employee_person_id,20);
    hr_utility.set_location('l_bg_id   = ' || l_bg_id,20);

    l_canonical_start_date := TO_DATE(l_start_date,'yyyy/mm/dd');
    l_canonical_end_date   := TO_DATE(l_end_date,'yyyy/mm/dd');
    g_archive_start_date   := l_canonical_start_date;
    g_archive_end_date     := TO_DATE(l_end_date,'yyyy/mm/dd');


    l_prepay_action_id := 0;
    l_person_id := 0;
    l_assignment_id:=0;
    l_period_of_service_id := 0;

    hr_utility.set_location('l_canonical_start_date = ' || l_canonical_start_date,20);
    hr_utility.set_location('l_canonical_end_date = ' || l_canonical_end_date,20);

    hr_utility.set_location('Before csr_prepaid_assignments',21);

    l_ppsn_override := NULL;
    l_ppsn_override_asg := NULL;

    FOR csr_rec IN csr_prepaid_assignments(pactid,
                                           stperson,
                                           endperson,
                                           g_paye_ref,
					   l_payroll_id,
					   l_employee_person_id)
    LOOP

    hr_utility.set_location('Person id..'||to_char(csr_rec.person_id),21-1);
    hr_utility.set_location('assignment_id..'||to_char(csr_rec.assignment_id),21-1);
    hr_utility.set_location('run_action_id..'||to_char(csr_rec.run_action_id),21-1);
    hr_utility.set_location('prepaid_action_id.'||to_char(csr_rec.prepaid_action_id),21-1);
    hr_utility.set_location('works_number..'||to_char(csr_rec.works_number),21-1);
    hr_utility.set_location('period_of_service_id..'||to_char(csr_rec.period_of_service_id),21-1);

    hr_utility.set_location('Person id..'||to_char(csr_rec.person_id),21-1);
    hr_utility.set_location('Temp Person id..'||to_char(l_person_id),21-2);

	     l_ppsn_override := NULL;
             l_ppsn_override_asg := NULL;
	     hr_utility.set_location('before fetch l_ppsn_override'||to_char(l_ppsn_override),21-3);
	     hr_utility.set_location(' before fetch l_ppsn_override_asg'||to_char(l_ppsn_override_asg),21-3);

            OPEN csr_ppsn_override(csr_rec.assignment_id);
            FETCH csr_ppsn_override INTO l_ppsn_override;
            CLOSE csr_ppsn_override;

	hr_utility.set_location('l_ppsn_override'||to_char(l_ppsn_override),21-3);

           IF l_ppsn_override IS NOT NULL THEN
		OPEN csr_ppsn_min_asg(l_ppsn_override,csr_rec.person_id,csr_rec.period_of_service_id);
	        FETCH csr_ppsn_min_asg INTO l_ppsn_override_asg;
		CLOSE csr_ppsn_min_asg;
		hr_utility.set_location('l_ppsn_override_asg'||to_char(l_ppsn_override_asg),21-4);
	   END IF;



	hr_utility.set_location('csr_rec.assignment_id'||csr_rec.assignment_id,21-4);

       IF (l_person_id <> csr_rec.person_id and l_ppsn_override IS NULL )
       OR  /* knadhan */
       ((l_person_id <> csr_rec.person_id and l_ppsn_override IS NOT NULL) OR (l_ppsn_override_asg=csr_rec.assignment_id and l_ppsn_override IS NOT NULL))
       THEN

      hr_utility.set_location('Different Person '|| csr_rec.person_id ,22);

      SELECT pay_assignment_actions_s.NEXTVAL
      INTO   l_actid
      FROM   dual;

      -- CREATE THE ARCHIVE ASSIGNMENT ACTION FOR THE MASTER ASSIGNMENT ACTION
      hr_utility.set_location('ASSIGNMENT ID : ' || csr_rec.assignment_id,23);
      hr_utility.trace('ASSIGNMENT ID : ' || csr_rec.assignment_id);

      hr_nonrun_asact.insact(l_actid,csr_rec.assignment_id,pactid,chunk,g_paye_ref);
      -- CREATE THE ARCHIVE TO PAYROLL MASTER ASSIGNMENT ACTION INTERLOCK AND
      -- THE ARCHIVE TO PREPAYMENT ASSIGNMENT ACTION INTERLOCK
      -- hr_utility.set_location('creating lock1 ' || l_actid || ' to ' || csr_rec.run_action_id,20);
      -- hr_utility.set_location('creating lock2 ' || l_actid || ' to ' || csr_rec.prepaid_action_id,20);
     END IF; --
      hr_utility.set_location('l_prepay_action_id : ' || l_prepay_action_id,100);
	hr_utility.set_location('csr_rec.prepaid_action_id : ' || csr_rec.prepaid_action_id,101);
	hr_utility.set_location('l_actid : ' || l_actid,102);

      IF l_prepay_action_id <> csr_rec.prepaid_action_id THEN
      hr_utility.set_location('locked id : ' || csr_rec.prepaid_action_id,23);
       hr_nonrun_asact.insint(l_actid,csr_rec.prepaid_action_id);
      END IF;

      hr_nonrun_asact.insint(l_actid,csr_rec.run_action_id);

      l_prepay_action_id := csr_rec.prepaid_action_id;
      l_person_id := csr_rec.person_id;
      l_period_of_service_id := csr_rec.period_of_service_id;

    END LOOP;

    hr_utility.set_location('Leaving ' || l_proc,20);
  END assignment_action_code;




/* arch init */
  PROCEDURE archive_init (p_payroll_action_id IN NUMBER)
IS

 CURSOR  csr_archive_effective_date(pactid NUMBER) IS
  SELECT effective_date
  FROM   pay_payroll_actions
  WHERE  payroll_action_id = pactid;

  CURSOR csr_input_value_id(p_element_name CHAR,
                            p_value_name   CHAR) IS
  SELECT pet.element_type_id,
         piv.input_value_id
  FROM   pay_input_values_f piv,
         pay_element_types_f pet
  WHERE  piv.element_type_id = pet.element_type_id
  AND    pet.legislation_code = 'IE'
  AND    pet.element_name = p_element_name
  AND    piv.name = p_value_name;

  l_proc                            VARCHAR2(50) := g_package || 'archive_init';
  l_assignment_set_id               NUMBER;
  l_bg_id                           NUMBER;
  l_canonical_end_date              DATE;
  l_canonical_start_date            DATE;
  l_consolidation_set               NUMBER;
  l_end_date                        VARCHAR2(30);
  l_payroll_id                      NUMBER;
  l_start_date                      VARCHAR2(30);
  l_dummy                           VARCHAR2(2);
  l_error                           varchar2(1) ;
BEGIN


hr_utility.set_location('Entering ' || l_proc,10);

  g_archive_pact := p_payroll_action_id;

  OPEN csr_archive_effective_date(p_payroll_action_id);
  FETCH csr_archive_effective_date
  INTO  g_archive_effective_date;
  CLOSE csr_archive_effective_date;

  pay_ie_cess_report.get_parameters (
    p_payroll_action_id => p_payroll_action_id
  , p_token_name        => 'EMPLOYER'
  , p_token_value       => g_paye_ref);

  pay_ie_cess_report.get_parameters (
    p_payroll_action_id => p_payroll_action_id
  , p_token_name        => 'END_DATE'
  , p_token_value       => l_end_date);

   pay_ie_cess_report.get_parameters (
    p_payroll_action_id => p_payroll_action_id
  , p_token_name        => 'START_DATE'
  , p_token_value       => l_start_date);

  pay_ie_cess_report.get_parameters (
    p_payroll_action_id => p_payroll_action_id
  , p_token_name        => 'BG_ID'
  , p_token_value       => l_bg_id);

  hr_utility.set_location('Step ' || l_proc,20);
  hr_utility.set_location('g_paye_ref = ' || g_paye_ref,20);
  hr_utility.set_location('l_end_date   = ' || l_end_date,20);
  hr_utility.set_location('l_start_date   = ' || l_start_date,20);
  hr_utility.set_location('l_bg_id   = ' || l_bg_id,20);

  l_canonical_start_date := TO_DATE(l_start_date,'yyyy/mm/dd');
  l_canonical_end_date   := TO_DATE(l_end_date,'yyyy/mm/dd');

  -- Initialized g_archive_end_date to support Retry Option
  g_archive_end_date     := TO_DATE(l_end_date,'yyyy/mm/dd');
  g_archive_start_date   := l_canonical_start_date;

  hr_utility.set_location('l_canonical_start_date = ' || l_canonical_start_date,20);



   hr_utility.set_location('stage 1',22);

   hr_utility.set_location('stage 2',23);

   hr_utility.set_location('stage 3',24);


    hr_utility.set_location('Leaving ' || l_proc,20);
  END archive_init;







/* Archive COde  */

PROCEDURE archive_data (p_assactid       in number,
                          p_effective_date in date) IS
  CURSOR csr_assignment_actions(p_locking_action_id NUMBER) IS
  SELECT pre.locked_action_id      pre_assignment_action_id,
         pay.locked_action_id      master_assignment_action_id,
         assact.assignment_id      assignment_id,
         assact.payroll_action_id  pay_payroll_action_id,
         paa.effective_date        effective_date,
         ppaa.effective_date       pre_effective_date,
         paa.date_earned           date_earned,
         ptp.time_period_id        time_period_id
  FROM   pay_action_interlocks pre,
         pay_action_interlocks pay,
         pay_payroll_actions paa,
         pay_payroll_actions ppaa,
         pay_assignment_actions assact,
         pay_assignment_actions passact,
         per_time_periods ptp  -- Added to retrieve correct time_period_id 4906850
  WHERE  pre.locked_action_id = pay.locking_action_id
  AND    pre.locking_action_id = p_locking_action_id
  AND    pre.locked_action_id = passact.assignment_action_id
  AND    passact.payroll_action_id = ppaa.payroll_action_id
  AND    ppaa.action_type IN ('P','U')
  AND    pay.locked_action_id = assact.assignment_action_id
  AND    assact.payroll_action_id = paa.payroll_action_id
  AND    assact.source_action_id IS NULL
  AND    ptp.payroll_id = paa.payroll_id
  AND    paa.date_earned between ptp.start_date and ptp.end_date
  and    paa.date_earned >= to_date('01/01/2009','dd/mm/yyyy')
  --
  ORDER BY pay.locked_action_id DESC;



/*New Cursor to fetch latest child action */
CURSOR cur_child_pay_action (p_person_id IN NUMBER,
                             p_effective_date IN DATE,
                             p_lat_act_seq IN NUMBER) is
SELECT /*+ USE_NL(paa, ppa) */
      fnd_number.canonical_to_number(substr(max(lpad(paa.action_sequence,15,'0')||
      paa.assignment_action_id),16))
FROM pay_assignment_actions paa,
     pay_payroll_actions ppa
WHERE paa.payroll_action_id = ppa.payroll_action_id
  AND paa.assignment_id in (select assignment_id
                              from per_all_assignments_f
		             where person_id = p_person_id
			   )
  AND paa.tax_unit_id = g_paye_ref
  AND  (paa.source_action_id is not null or ppa.action_type in ('I','V','B'))
    AND  ppa.effective_date between trunc(p_effective_date,'Y') and p_effective_date
  AND  paa.action_sequence > p_lat_act_seq
  AND  ppa.action_type in ('R', 'Q', 'I', 'V', 'B')
  AND  paa.action_status = 'C';

  -- cursor to find assignment action locked by latest cess child action
  CURSOR cur_get_latest_cess(p_pact_id NUMBER,
                            p_person_id NUMBER,
			    c_ppsn varchar2
			   ) IS
 SELECT max(lpad(paa_src.action_sequence,15,'0')|| paa_src.assignment_action_id)
    FROM pay_payroll_actions ppa_cess,
         pay_assignment_actions cess_src,
	 pay_action_information pai_cess,
	 pay_assignment_actions paa_src
    WHERE ppa_cess.action_type = 'X'
      AND ppa_cess.report_type = 'IE_CESSATION'
      AND ppa_cess.report_qualifier = 'IE'
      AND ppa_cess.payroll_action_id <> p_pact_id
      AND ppa_cess.payroll_action_id = cess_src.payroll_action_id
      AND cess_src.assignment_action_id = pai_cess.action_context_id
      AND pai_cess.action_context_type = 'AAP'
      AND pai_cess.action_information_category = 'IE CESS INFORMATION'
      AND pai_cess.source_id = paa_src.assignment_action_id
      AND cess_src.action_status = 'C'
      AND paa_src.tax_unit_id = g_paye_ref
      AND cess_src.tax_unit_id = g_paye_ref
      AND pai_cess.action_information8 = to_char(p_person_id)
      AND ((c_ppsn is not null and pai_cess.action_information22=c_ppsn) or (c_ppsn is null)) /* 8615992 */
   ;

 -- Cursor to fetch action context id of cess for previous period of service.

  CURSOR cur_get_last_cess(p_person_id NUMBER,p_termination_date DATE,p_pact NUMBER, c_assignment_id NUMBER,c_ppsn varchar2) IS
  SELECT fnd_number.canonical_to_number(substr(max(lpad(paa.action_sequence,15,'0')||
      paa.assignment_action_id),16))
  FROM pay_payroll_actions ppa,
       pay_assignment_actions paa,
       pay_action_information pai
  WHERE paa.assignment_action_id = pai.action_context_id
   AND  pai.action_information_category = 'IE CESS INFORMATION'
   AND  pai.action_context_type = 'AAP'
   AND  paa.tax_unit_id = g_paye_ref
   AND  fnd_date.canonical_to_date(pai.action_information3) between trunc(p_termination_date,'Y') and p_termination_date
   AND  ppa.payroll_action_id = paa.payroll_action_id
   AND  ppa.report_type = 'IE_CESSATION'
   AND  ppa.report_category = 'ARCHIVE'
   AND  ppa.report_qualifier = 'IE'
   AND  ppa.effective_date between trunc(g_archive_end_date,'Y') and g_archive_end_date
   AND  paa.payroll_action_id <> p_pact
   AND  paa.action_status = 'C'
   AND  pai.action_information8 = to_char(p_person_id)
   AND ((c_ppsn is not null and pai.action_information22=c_ppsn) or (c_ppsn is null)) /* 8615992 */
  ;


  CURSOR cur_get_cess_pact(p_cess_aact pay_assignment_actions.assignment_action_id%TYPE) IS
 SELECT paa.payroll_action_id
   FROM pay_assignment_actions paa
 WHERE  paa.assignment_action_id = p_cess_aact;

  -- cursor to retrieve payroll id
  CURSOR cur_assgn_payroll(p_assignment_id NUMBER,
                           p_date_earned DATE) IS
  SELECT payroll_id,person_id,period_of_service_id
  FROM per_all_assignments_f
  WHERE assignment_id = p_assignment_id
  AND p_date_earned
      BETWEEN effective_start_date AND effective_end_date;



cursor csr_ppsn_override(p_asg_id number)
is
select aei_information1 PPSN_OVERRIDE
from per_assignment_extra_info
where assignment_id = p_asg_id
and aei_information_category = 'IE_ASG_OVERRIDE';

l_ppsn_override per_assignment_extra_info.aei_information1%type;

CURSOR cur_child_pay_action_ppsn (p_person_id IN NUMBER,
                             p_effective_date IN DATE,
                             p_lat_act_seq IN NUMBER,
			     c_ppsn_override per_assignment_extra_info.aei_information1%type) is
SELECT /*+ USE_NL(paa, ppa) */
      fnd_number.canonical_to_number(substr(max(lpad(paa.action_sequence,15,'0')||
      paa.assignment_action_id),16))
FROM pay_assignment_actions paa,
     pay_payroll_actions ppa
WHERE paa.payroll_action_id = ppa.payroll_action_id
  AND paa.assignment_id in (select paaf.assignment_id
                              from per_all_assignments_f paaf, per_assignment_extra_info paei
		             where paaf.person_id = p_person_id
			       and paaf.assignment_id=paei.assignment_id
			       and paei.information_type = 'IE_ASG_OVERRIDE'
			       and paei.aei_information1 = c_ppsn_override     --'314678745T'
			   )
  AND paa.tax_unit_id = g_paye_ref
  AND  (paa.source_action_id is not null or ppa.action_type in ('I','V','B'))
    AND  ppa.effective_date between trunc(p_effective_date,'Y') and p_effective_date
  AND  paa.action_sequence > p_lat_act_seq
  AND  ppa.action_type in ('R', 'Q', 'I', 'V', 'B')
  AND  paa.action_status = 'C';

  l_child_pay_action_ppsn           NUMBER;

  l_actid                           NUMBER;
  l_action_context_id               NUMBER;
  l_action_info_id                  NUMBER(15);
  l_assignment_action_id            NUMBER;
  l_business_group_id               NUMBER;
  l_chunk_number                    NUMBER;
  l_assignment_id                   NUMBER;
  l_date_earned                     DATE;
  l_ovn                             NUMBER;
  l_person_id                       NUMBER;
  l_pos_id                          NUMBER;
  l_record_count                    NUMBER;
  l_salary                          VARCHAR2(10);
  l_sequence                        NUMBER;
  l_child_pay_action                NUMBER;
  l_payroll_id                      NUMBER;
  l_supp_flag                       VARCHAR2(1):='N';
  l_deceased_flag                   VARCHAR2(1):='N';
  l_proc                            VARCHAR2(50) := g_package || 'archive_data';
  l_lat_act_seq                     NUMBER;
  l_termination_date                DATE;
  l_last_cess_action                 NUMBER;
  l_max_stat_balance                NUMBER       := 19;
  l_concat_sequence                 VARCHAR2(40);
  l_prev_src_id                     NUMBER;
  l_last_cess_pact                   NUMBER;
  -- 5386432
  l_supp_pymt_date                  DATE;



  BEGIN

    l_lat_act_seq := NULL;
    hr_utility.set_location('Entering'|| l_proc,10);
    hr_utility.set_location('Step '|| l_proc,20);
    hr_utility.set_location('p_assactid = ' || p_assactid,20);

    -- retrieve the chunk number for the current assignment action
    SELECT paa.chunk_number,paa.assignment_id
    INTO   l_chunk_number,l_assignment_id
    FROM   pay_assignment_actions paa
    WHERE  paa.assignment_action_id = p_assactid;

    l_action_context_id := p_assactid;
    l_record_count := 0;

    FOR csr_rec IN csr_assignment_actions(p_assactid)
    LOOP
      hr_utility.set_location('csr_rec.master_assignment_action_id = ' || csr_rec.master_assignment_action_id,20);
      hr_utility.set_location('csr_rec.pre_assignment_action_id    = ' || csr_rec.pre_assignment_action_id,20);
      hr_utility.set_location('csr_rec.assignment_id    = ' || csr_rec.assignment_id,20);
      hr_utility.set_location('csr_rec.date_earned    = ' ||to_char( csr_rec.date_earned,'dd-mon-yyyy'),20);
      hr_utility.set_location('csr_rec.pre_effective_date    = ' ||to_char( csr_rec.pre_effective_date,'dd-mon-yyyy'),20);
      hr_utility.set_location('csr_rec.time_period_id    = ' || csr_rec.time_period_id,20);

           OPEN cur_assgn_payroll(csr_rec.assignment_id,csr_rec.date_earned);
           FETCH cur_assgn_payroll INTO l_payroll_id,l_person_id,l_pos_id;
           CLOSE cur_assgn_payroll;

           l_ppsn_override:=null;
	   open csr_ppsn_override(csr_rec.assignment_id);
	   fetch csr_ppsn_override into  l_ppsn_override;
	   close csr_ppsn_override;
           hr_utility.set_location('PPSN Override  value  = ' || l_ppsn_override,20);


      --Fetch the action sequence of latest payroll run child action locked by latest cess
      --For the assignment 4468864
      OPEN cur_get_latest_cess(g_archive_pact,l_person_id,l_ppsn_override);
      FETCH cur_get_latest_cess INTO l_concat_sequence;

	      IF cur_get_latest_cess%NOTFOUND THEN
	      hr_utility.set_location('Action Sequence notfound   = ' || l_lat_act_seq,21);
		l_lat_act_seq := 0;
		l_prev_src_id := 0;
	      END IF;

            l_lat_act_seq := nvl(substr(l_concat_sequence,1,15),0);
            l_prev_src_id := nvl(substr(l_concat_sequence,16),0);

	      hr_utility.set_location('Action Sequence  = ' || l_lat_act_seq,21);
      CLOSE cur_get_latest_cess;

      hr_utility.set_location('Action Sequence    = ' || l_lat_act_seq,21);



      l_child_pay_action_ppsn := NULL;
      OPEN cur_child_pay_action_ppsn(l_person_id,g_archive_end_date,l_lat_act_seq,l_ppsn_override);
      FETCH cur_child_pay_action_ppsn INTO l_child_pay_action_ppsn;
      hr_utility.set_location('Child Action PPSN ='||l_child_pay_action_ppsn,20);
      CLOSE cur_child_pay_action_ppsn;

      l_child_pay_action := NULL;
      OPEN cur_child_pay_action(l_person_id,g_archive_end_date,l_lat_act_seq);
      FETCH cur_child_pay_action INTO l_child_pay_action;

      if (l_child_pay_action_ppsn is null) THEN
      l_child_pay_action_ppsn:=l_child_pay_action;
      end if;
      hr_utility.set_location('Child Action PPSN after assigning ='||l_child_pay_action_ppsn,20);

    --  hr_utility.set_location('Child Action PPSN  ='|| l_child_pay_action_ppsn,24);
       hr_utility.set_location('Child Action ='||l_child_pay_action,24);

	 -------------- Moved here for bug 5386432  ----
	   get_termination_date(p_action_context_id     => p_assactid,
                            p_assignment_id           => csr_rec.assignment_id,
                            p_person_id               => l_person_id,
				    p_date_earned             => csr_rec.date_earned,
			          p_termination_date        => l_termination_date,
				    p_supp_pymt_date		=> l_supp_pymt_date,
				    p_supp_flag			=> l_supp_flag,
				    p_deceased_flag             => l_deceased_flag
			          );
	   OPEN cur_get_last_cess(l_person_id,l_termination_date,g_archive_pact,csr_rec.assignment_id,l_ppsn_override);
	   FETCH cur_get_last_cess into l_last_cess_action;
	   CLOSE cur_get_last_cess;

	   -- Fetch the Payroll action of Last cess 5005788
	   OPEN cur_get_cess_pact(l_last_cess_action);
	   FETCH cur_get_cess_pact INTO l_last_cess_pact;
	   CLOSE cur_get_cess_pact;
	   hr_utility.set_location(' l_termination_date = '||l_termination_date,30);
	   hr_utility.set_location(' l_supp_pymt_date = '||l_supp_pymt_date,30);
	   hr_utility.set_location(' l_supp_flag = '||l_supp_flag,30);
     hr_utility.set_location(' l_child_pay_action = '||l_child_pay_action,30);
     hr_utility.set_location(' l_record_count = '|| l_record_count,30);
     hr_utility.set_location(' csr_rec.assignment_id = '|| csr_rec.assignment_id,30);
     hr_utility.set_location(' l_assignment_id = '|| l_assignment_id,30);
     ------------------

    IF ((l_child_pay_action IS NULL) and l_supp_flag = 'Y' ) THEN
     NULL;
    ELSE
      IF (l_record_count = 0 AND csr_rec.assignment_id = l_assignment_id)
      THEN
       hr_utility.set_location(' entered if of else ',30);
      -- Create child cess action to lock the child payroll process child action
      -- To avoid data corruption 4468864
      SELECT pay_assignment_actions_s.NEXTVAL
      INTO   l_actid
      FROM dual;

      hr_nonrun_asact.insact(
        lockingactid => l_actid
      , assignid     => l_assignment_id
      , pactid       => g_archive_pact
      , chunk        => l_chunk_number
      , greid        => g_paye_ref
      , prepayid     => NULL
      , status       => 'C'
      , source_act   => p_assactid);

          hr_utility.set_location('creating lock4 ' || l_actid || ' to ' || l_child_pay_action,30);
          -- bug 5386432, checks l_child_pay_action is not null, since for zero
	    -- earnigns there will not child actions, so cant lock any
	    IF l_child_pay_action IS NOT NULL THEN
		hr_nonrun_asact.insint(
			lockingactid => l_actid
		    , lockedactid  => l_child_pay_action);
	    END IF;

           pay_ie_cess_report.archive_cess_info(
                    p_action_context_id    => p_assactid,
                    p_assignment_id        => csr_rec.assignment_id, -- assignment_id
                    p_payroll_id           => l_payroll_id,
                    p_date_earned          => csr_rec.effective_date, -- date earned 9337590
                    p_child_run_ass_act_id => l_child_pay_action_ppsn, /* knahdan */
                    p_supp_flag            => l_supp_flag,
		        p_person_id            => l_person_id,
		        p_termination_date     => l_termination_date,
		        p_child_pay_action     => l_child_pay_action_ppsn,   -- child payroll assignment action id
			--p_source_id            => l_child_pay_action,
			p_supp_pymt_date	 => l_supp_pymt_date,
			p_deceased_flag        => l_deceased_flag,
			 p_last_cess_action         => l_last_cess_action
			, p_prev_src_id       => l_prev_src_id);



	   hr_utility.set_location('sg Person Id ='||l_person_id,32);
	   hr_utility.set_location('sg Termination Date ='||l_termination_date,33);
           hr_utility.set_location('sg Payroll action ='||g_archive_pact,34);
            hr_utility.set_location('sg cess action ='||l_last_cess_action,35);

	   IF l_last_cess_action IS NOT NULL THEN
		hr_nonrun_asact.insint(
            lockingactid => l_actid
          , lockedactid  => l_last_cess_action);
	   END IF;

        END IF;
       END IF;
      CLOSE cur_child_pay_action;
      l_date_earned := csr_rec.date_earned;
   hr_utility.set_location('Before loop end for assignment '||csr_rec.assignment_id,80);
    END LOOP;
    hr_utility.set_location('Leaving '|| l_proc,80);
  END archive_data;


PROCEDURE gen_header_xml
IS
	l_string  varchar2(32767) := NULL;
	l_clob PAY_FILE_DETAILS.FILE_FRAGMENT%TYPE;
	l_blob PAY_FILE_DETAILS.BLOB_FILE_FRAGMENT%TYPE;

	l_proc VARCHAR2(100);
	l_payroll_action_id number;
BEGIN
	l_proc := g_package || 'gen_header_xml';
	hr_utility.set_location ('Entering '||l_proc,1500);

	l_payroll_action_id := pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID');
	hr_utility.set_location('Inside pay_ie_cess_report.gen_header_xml,l_payroll_action_id: '||l_payroll_action_id,300);




	l_string := l_string || '<ROOT>' ;

	l_clob := l_clob||l_string;
	IF l_clob IS NOT NULL THEN
	  l_blob := c2b(l_clob);
	  pay_core_files.write_to_magtape_lob(l_blob);
	END IF;

EXCEPTION
WHEN Others THEN
Hr_Utility.set_location('..'||'SQL-ERRM :'||SQLERRM,1214);

END gen_header_xml;

PROCEDURE gen_footer_xml
IS
	l_buf  VARCHAR2(2000);
	l_proc VARCHAR2(100);
begin
	l_proc := g_package || 'gen_footer_xml';
	hr_utility.set_location ('Entering '||l_proc, 1520);

	l_buf := l_buf || '</ROOT>'||EOL ;
	--
	pay_core_files.write_to_magtape_lob(l_buf);
	hr_utility.set_location ('Leaving '||l_proc, 1530);

end gen_footer_xml;


PROCEDURE gen_body_xml
  IS
 l_string  varchar2(32767) := NULL;
 l_clob PAY_FILE_DETAILS.FILE_FRAGMENT%TYPE;
 l_blob PAY_FILE_DETAILS.BLOB_FILE_FRAGMENT%TYPE;

l_payroll_action_id NUMBER;
l_asg_action_id NUMBER;

l_assignment_id  per_all_assignments_f.assignment_id%type;
CURSOR cur_assignment_id (c_assignment_action_id pay_assignment_actions.assignment_action_id%type) is
select assignment_id
from  pay_assignment_actions
where assignment_action_id=c_assignment_action_id;

l_assignment_id per_all_assignments_f.assignment_id%type;


CURSOR  cur_cess_emp_details (c_assignment_action_id pay_assignment_actions.assignment_action_id%TYPE )IS
select PAI_IEcess.ACTION_INFORMATION20 last_name,
       PAI_IEcess.ACTION_INFORMATION21 first_name,
       PAI_IEcess.ACTION_INFORMATION22 pps_no,
       PAI_IEcess.ACTION_INFORMATION23 works_no,
       PAI_IEcess.ACTION_INFORMATION24 date_of_commencement,
       PAI_IEcess.ACTION_INFORMATION2  supplementary_flag,
       PAI_IEcess.ACTION_INFORMATION3  date_of_leaving,
       PAI_IEcess.ACTION_INFORMATION29 gross_pay_total_frm_may09,
       PAI_IEcess.ACTION_INFORMATION30 income_levy_frm_may09,
       PAI_IEcess.ACTION_INFORMATION27 gross_pay_total_apr_09,
       PAI_IEcess.ACTION_INFORMATION28 income_levy_apr_09,
       PAI_IEcess.ACTION_INFORMATION25 gross_pay_total_final, /* 8615992 */
       PAI_IEcess.ACTION_INFORMATION26 income_levy_final,
       PAI_IEcess.ACTION_INFORMATION10 employer_tax_rep_name,
       PAI_IEcess.ACTION_INFORMATION11 employer_tax_addr1,
       PAI_IEcess.ACTION_INFORMATION12 employer_tax_addr2,
       PAI_IEcess.ACTION_INFORMATION13 employer_tax_addr3,
       PAI_IEcess.ACTION_INFORMATION14 employer_no,
       PAI_IEcess.ACTION_INFORMATION15 employer_tax_ref_phone,
       PAI_IEcess.ACTION_INFORMATION16 email,
       PAI_IEcess.ACTION_INFORMATION9  date_paid /* 9337590 */
from pay_action_information PAI_IEcess
where PAI_IEcess.action_context_id=c_assignment_action_id
AND PAI_IEcess.ACTION_INFORMATION_CATEGORY = 'IE CESS INFORMATION';


cur_cess_emp_details_rec cur_cess_emp_details%ROWTYPE;

l_employer_number       varchar2(10);
l_employer_name         varchar2(30);
l_employer_add1         varchar2(30);
l_employer_add2         varchar2(30);
l_employer_add3         varchar2(30);
l_employer_contact      varchar2(20);
l_employer_phone        varchar2(12);


l_gross_pay         number;
l_gross_pay_adjust         number;
l_bik_prsi_taxable          number;
l_income_levy        number;
l_gross_pay_total         number;

l_action_info_id                  NUMBER(15);
l_ovn                             NUMBER(15);



BEGIN
hr_utility.set_location(' Entering: pay_ie_cess_report.gen_body_xml: ', 270);

l_payroll_action_id := pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID');
l_asg_action_id  := pay_magtape_generic.get_parameter_value('TRANSFER_ACT_ID');


hr_utility.set_location('l_payroll_action_id '||TO_CHAR(l_payroll_action_id),275);
hr_utility.set_location('l_asg_action_id '||TO_CHAR(l_asg_action_id),280);


OPEN cur_cess_emp_details(l_asg_action_id);
      FETCH cur_cess_emp_details into cur_cess_emp_details_rec;
 CLOSE cur_cess_emp_details;

l_string := l_string ||'<EMPLOYEE>';

l_string := l_string ||'<SURNAME>'|| test_XML(cur_cess_emp_details_rec.last_name) ||'</SURNAME>';
l_string := l_string ||'<FIRST_NAME>'||test_XML( cur_cess_emp_details_rec.first_name) ||'</FIRST_NAME>';
l_string := l_string ||'<PPSN>'|| cur_cess_emp_details_rec.pps_no ||'</PPSN>';
l_string := l_string ||'<WORKS_NUM>'|| cur_cess_emp_details_rec.works_no ||'</WORKS_NUM>';
IF to_number(to_char(fnd_date.canonical_to_date(cur_cess_emp_details_rec.date_of_commencement),'rrrr'))= to_number(to_char(fnd_date.canonical_to_date(cur_cess_emp_details_rec.date_paid),'YYYY')) THEN -- greater than 2009 /* knadhan */
l_string := l_string ||'<HIRE_DATE>'|| to_char(fnd_date.canonical_to_date(cur_cess_emp_details_rec.date_of_commencement),'ddmmrr') ||'</HIRE_DATE>';
END IF;
--IF (to_number(to_char(fnd_date.canonical_to_date(cur_cess_emp_details_rec.date_of_leaving),'yyyy'))>=2009) THEN -- greater than 2009 /* knadhan */
l_string := l_string ||'<CESS_DATE>'|| to_char(fnd_date.canonical_to_date(cur_cess_emp_details_rec.date_of_leaving),'ddmmrr') ||'</CESS_DATE>';
--END IF;
/* 8615992 */
l_string := l_string ||'<SUPPLEMENTARY_FLAG>'|| cur_cess_emp_details_rec.supplementary_flag ||'</SUPPLEMENTARY_FLAG>';
l_string := l_string ||'<GROSS_INCOME>'|| cur_cess_emp_details_rec.gross_pay_total_final ||'</GROSS_INCOME>';
l_string := l_string ||'<LEVY>'|| cur_cess_emp_details_rec.income_levy_final||'</LEVY>';
l_string := l_string ||'<GROSS_INCOME_TILL_APR>'|| cur_cess_emp_details_rec.gross_pay_total_apr_09 ||'</GROSS_INCOME_TILL_APR>';
l_string := l_string ||'<LEVY_TILL_APR>'|| cur_cess_emp_details_rec.income_levy_apr_09||'</LEVY_TILL_APR>';
l_string := l_string ||'<GROSS_INCOME_FRM_MAY>'|| cur_cess_emp_details_rec.gross_pay_total_frm_may09 ||'</GROSS_INCOME_FRM_MAY>';
l_string := l_string ||'<LEVY_FRM_MAY>'|| cur_cess_emp_details_rec.income_levy_frm_may09||'</LEVY_FRM_MAY>';
l_string := l_string ||'<ER_NAME>'|| test_XML(cur_cess_emp_details_rec.employer_tax_rep_name) ||'</ER_NAME>';
l_string := l_string ||'<ADDR_LINE1>'||test_XML(cur_cess_emp_details_rec.employer_tax_addr1) ||'</ADDR_LINE1>';
l_string := l_string ||'<ADDR_LINE2>'||test_XML(cur_cess_emp_details_rec.employer_tax_addr2)||'</ADDR_LINE2>';
l_string := l_string ||'<ADDR_LINE3>'||test_XML(cur_cess_emp_details_rec.employer_tax_addr3) ||'</ADDR_LINE3>';
l_string := l_string ||'<EMAIL>'|| cur_cess_emp_details_rec.email ||'</EMAIL>'; /* knadhan */
l_string := l_string ||'<ER_NUM>'|| cur_cess_emp_details_rec.employer_no ||'</ER_NUM>';
l_string := l_string ||'<ER_PHONE>'||cur_cess_emp_details_rec.employer_tax_ref_phone||'</ER_PHONE>';
l_string := l_string ||'<PAYMENT_DATE>'||to_char(fnd_date.canonical_to_date(cur_cess_emp_details_rec.date_paid),'YYYY') ||'</PAYMENT_DATE>'; /* 9337590 */

l_string := l_string ||'</EMPLOYEE>';


hr_utility.set_location('Before leaving gen_body_xml: length(l_string) = '||length(l_string),290);
l_clob := l_clob||l_string;

IF l_clob IS NOT NULL THEN
	l_blob := c2b(l_clob);
	pay_core_files.write_to_magtape_lob(l_blob);
END IF;

EXCEPTION
WHEN Others THEN
	Hr_Utility.set_location('..'||'SQL-ERRM :'||SQLERRM,1213);
END gen_body_xml;
end;


/
