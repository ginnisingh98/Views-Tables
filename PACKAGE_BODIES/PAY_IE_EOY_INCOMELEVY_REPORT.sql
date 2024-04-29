--------------------------------------------------------
--  DDL for Package Body PAY_IE_EOY_INCOMELEVY_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_IE_EOY_INCOMELEVY_REPORT" as
/* $Header: pyieeoyc.pkb 120.0.12010000.7 2010/02/11 05:55:18 knadhan noship $ */
vCtr  NUMBER;

/*6876894*/
TYPE t_asg_set_amnds IS TABLE OF hr_assignment_set_amendments.include_or_exclude%TYPE
      INDEX BY BINARY_INTEGER;
l_tab_asg_set_amnds   t_asg_set_amnds;


--
/*6876894*/
/*
This procedure returns formulae id for the assignment set criteria and
if its assignment set ammendents, then it retrives and stores those assignments
in p_tab_asg_set_amnds
*/

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

PROCEDURE get_asg_set_details(
      p_assignment_set_id   IN              NUMBER
     ,p_formula_id          OUT NOCOPY      NUMBER
     ,p_tab_asg_set_amnds   OUT NOCOPY      t_asg_set_amnds
   )
   IS
--
-- Cursor to get information about assignment set
      CURSOR csr_get_asg_set_info(c_asg_set_id NUMBER)
      IS
         SELECT formula_id
           FROM hr_assignment_sets ags
          WHERE assignment_set_id = c_asg_set_id
            AND EXISTS(SELECT 1
                         FROM hr_assignment_set_criteria agsc
                        WHERE agsc.assignment_set_id = ags.assignment_set_id);
-- Cursor to get assignment ids from asg set amendments
      CURSOR csr_get_asg_amnd(c_asg_set_id NUMBER)
      IS
         SELECT assignment_id, NVL(include_or_exclude
                                  ,'I') include_or_exclude
           FROM hr_assignment_set_amendments
          WHERE assignment_set_id = c_asg_set_id;
      l_proc_step           NUMBER(38, 10)             := 0;
      l_asg_set_amnds       csr_get_asg_amnd%ROWTYPE;
      l_tab_asg_set_amnds   t_asg_set_amnds;
      l_formula_id          NUMBER;

--
   BEGIN
--
      fnd_file.put_line(fnd_file.LOG,'Entering get_asg_set_details');
-- Check whether the assignment set id has a criteria
-- if a formula id is attached or check whether this
-- is an amendments only
      l_formula_id           := NULL;
      OPEN csr_get_asg_set_info(p_assignment_set_id);
      FETCH csr_get_asg_set_info INTO l_formula_id;
      fnd_file.put_line(fnd_file.LOG,' after csr_get_asg_set_info ');
      fnd_file.put_line(fnd_file.LOG,' l_formula_id '|| l_formula_id);
      IF csr_get_asg_set_info%FOUND
      THEN
         -- Criteria exists check for formula id
         IF l_formula_id IS NULL
         THEN
            -- Raise error as the criteria is not generated
            CLOSE csr_get_asg_set_info;
            hr_utility.raise_error;
         END IF; -- End if of formula id is null check ...
      END IF; -- End if of asg criteria row found check ...
      CLOSE csr_get_asg_set_info;
      fnd_file.put_line(fnd_file.LOG,' before csr_get_asg_amd ');
      OPEN csr_get_asg_amnd(p_assignment_set_id);
      LOOP
         FETCH csr_get_asg_amnd INTO l_asg_set_amnds;
         EXIT WHEN csr_get_asg_amnd%NOTFOUND;
         l_tab_asg_set_amnds(l_asg_set_amnds.assignment_id)    :=
                                           l_asg_set_amnds.include_or_exclude;
       fnd_file.put_line(fnd_file.LOG,' l_asg_set_amnds.assignment_id '|| l_asg_set_amnds.assignment_id);
       fnd_file.put_line(fnd_file.LOG,' l_asg_set_amnds.include_or_exclude '|| l_asg_set_amnds.include_or_exclude);
       END LOOP;
      CLOSE csr_get_asg_amnd;
      p_formula_id           := l_formula_id;
      p_tab_asg_set_amnds    := l_tab_asg_set_amnds;
   EXCEPTION
      WHEN OTHERS
      THEN
      fnd_file.put_line(fnd_file.LOG,'..'||'SQL-ERRM :'||SQLERRM);
   END get_asg_set_details;



/*6876894*/
/*
firstly it checks whether the assignment is present in assinment set ammendments else
 it executes the formulae if its not null for a particular assignment , returns whether
 included or not.

 */

FUNCTION chk_is_asg_in_asg_set(
      p_assignment_id       IN   NUMBER
     ,p_formula_id          IN   NUMBER
     ,p_tab_asg_set_amnds   IN   t_asg_set_amnds
     ,p_effective_date      IN   DATE
   )
      RETURN VARCHAR2
   IS
      l_session_date        DATE;
      l_include_flag        VARCHAR2(10);
      l_tab_asg_set_amnds   t_asg_set_amnds;
      l_inputs              ff_exec.inputs_t;
      l_outputs             ff_exec.outputs_t;
--
   BEGIN
--
      fnd_file.put_line(fnd_file.LOG,'Entering chk_is_asg_in_asg_set');
      l_include_flag         := 'N';
      l_tab_asg_set_amnds    := p_tab_asg_set_amnds;
      -- Check whether the assignment exists in the collection
      -- first as the static assignment set overrides the
      -- criteria one
      IF l_tab_asg_set_amnds.EXISTS(p_assignment_id)
      THEN
       fnd_file.put_line(fnd_file.LOG,'Entered assignment ammendents if block');
         -- Check whether to include or exclude
         IF l_tab_asg_set_amnds(p_assignment_id) = 'I'
         THEN
            l_include_flag    := 'Y';
         ELSIF l_tab_asg_set_amnds(p_assignment_id) = 'E'
         THEN
            l_include_flag    := 'N';
         END IF; -- End if of include or exclude flag check ...
      ELSIF p_formula_id IS NOT NULL
      THEN
         -- assignment does not exist in assignment set amendments
         -- check whether a formula criteria exists for this
         -- assignment set
         -- Initialize the formula
          fnd_file.put_line(fnd_file.LOG,'Entered assignment criteria   block');
         ff_exec.init_formula(p_formula_id          => p_formula_id
                             ,p_effective_date      => p_effective_date
                             ,p_inputs              => l_inputs
                             ,p_outputs             => l_outputs
                             );
          fnd_file.put_line(fnd_file.LOG,'formula initialized');
         -- Set the inputs first
         -- Loop through them to set the contexts
         FOR i IN l_inputs.FIRST .. l_inputs.LAST
         LOOP
            IF l_inputs(i).NAME = 'ASSIGNMENT_ID'
            THEN
               l_inputs(i).VALUE    := p_assignment_id;
           ELSIF l_inputs(i).NAME = 'DATE_EARNED'
            THEN
               l_inputs(i).VALUE    := fnd_date.date_to_canonical(p_effective_date);
            END IF;
         END LOOP;
         -- Run the formula
	  fnd_file.put_line(fnd_file.LOG,' before formaula run');


         ff_exec.run_formula(l_inputs, l_outputs);


         fnd_file.put_line(fnd_file.LOG,' aftre formaula run');
         -- Check whether the assignment has to be included
         -- by checking the output flag


	  fnd_file.put_line(fnd_file.LOG,' before outputs for run');
         FOR i IN l_outputs.FIRST .. l_outputs.LAST
         LOOP
            IF l_outputs(i).NAME = 'INCLUDE_FLAG'
            THEN
               IF l_outputs(i).VALUE = 'Y'
               THEN
                  l_include_flag    := 'Y';
               ELSIF l_outputs(i).VALUE = 'N'
               THEN
                  l_include_flag    := 'N';
             END IF;
    fnd_file.put_line(fnd_file.LOG,'p_assignment_id'||p_assignment_id);
    fnd_file.put_line(fnd_file.LOG,'l_include_flag'||l_include_flag);
               EXIT;
            END IF;

         END LOOP;
      END IF; -- End if of assignment exists in amendments check ...

      RETURN l_include_flag;
   EXCEPTION
      WHEN OTHERS
      THEN
       fnd_file.put_line(fnd_file.LOG,'..'||'SQL-ERRM :'||SQLERRM);
   END chk_is_asg_in_asg_set;




	procedure get_eoy_income_details(cp_start_date in date,
				  cp_effective_date in date,
				  cp_end_date in date,
				  p_business_group_id in number,
				  p_assignment_set_id in number,
				  p_payroll_id in number,
				  p_consolidation_set_id in number,
				  p_sort_order in varchar2)
is
		cursor c_p60_records(cp_start_date  date,
				  cp_effective_date  date,
				  cp_end_date  date,
				  p_business_group_id number,
				  p_assignment_set_id  number,
				  p_payroll_id  number,
				  p_consolidation_set_id  number,
				  p_sort_order  varchar2) IS
		  select
		  /* 9081004 */
                  upper(SUBSTR(trim(pai.action_information18),1,30)) surname
                 ,upper(SUBSTR(trim(pai.action_information19),1,30)) first_name
		 ,upper(pai.action_information1) ppsn
		 ,lpad(upper(pai.action_information2), 9, ' ') works_num
		 ,decode(sign(to_date(pai.action_information24,'DD-MM-YYYY')- cp_start_date),-1,Null,to_char(to_date(pai.action_information24,'DD-MM-YYYY'),'DDMMRR')) hire_date
		 ,nvl(pai_prsi.action_information24,0) total_gross_pay
		 ,nvl(pai_prsi.action_information25,0) total_income_levy
		 ,upper(nvl(rtrim(pact_ade.action_information26),'')) Employer_name
		 ,upper(substr(trim(pact_ade.action_information5),1,30))  address_line1
		 ,upper(substr(trim(pact_ade.action_information6),1,30))  address_line2
		 ,upper(substr(trim(pact_ade.action_information7),1,30))  address_line3
                 ,lpad(translate(pact_ade.action_information28,'1()-', '1'), 11, ' ') Phone_number
                 ,lpad(upper(nvl(rtrim(pact_ade.action_information1),'')), 8, ' ')  Employer_number
		 ,paf.assignment_number     assignment_number
		 ,paf.person_id Person_Id
		 ,paf.assignment_id assignment_id /*6876894*/
		 ,substr(trim(pai.action_information21),1,30)  emp_Address1 /* 9160076 */
		 ,substr(trim(pai.action_information22),1,30)  emp_Address2
		 ,rpad(substr(trim(pai.action_information23),1,30) ,30,' ') emp_County
		FROM   pay_action_information       pai /*Employee Details Info*/
			,pay_action_information       pai_prsi /* prsi Details  5657992 */
		      ,pay_action_information       pact_ade /*Address Details - for Employer Name -IE Employer Tax Address*/
		      ,pay_payroll_actions          ppa35
		      ,pay_assignment_actions       paa
		      ,per_assignments_f		paf
		      ,per_periods_of_service		pps
		      ,pay_ie_paye_details_f        payef
		      ,pay_ie_prsi_details_f        prsif
		      ,pay_all_payrolls_f		PAPF
	       WHERE
		  NVl('N','N') = 'N'
		  and to_date(pay_ie_p35.get_parameter(ppa35.payroll_action_id,'END_DATE'),'YYYY/MM/DD') between cp_start_date and cp_end_date
		--  and cp_start_date <= to_date(pay_ie_p35.get_parameter(ppa35.payroll_action_id,'END_DATE'),'YYYY/MM/DD') /*4641756*/
		  and   ppa35.report_type       = 'IEP35'
		  and   ppa35.business_group_id = p_business_group_id /* p_business_group_id */
		  and paa.payroll_action_id = ppa35.payroll_action_id
		  and paa.assignment_id = paf.assignment_id
		  and   paa.action_status     = 'C'
		  and paa.assignment_action_id = pai.action_context_id
		  and paf.period_of_service_id = pps.period_of_service_id
		  and paf.person_id= pps.person_id
		  and paf.business_group_id + 0 = p_business_group_id /*4483028*/
		-- Bug 3446744 Checking if the employee has been terminated before issuing the P60
		and (pps.actual_termination_date is null or pps.actual_termination_date > cp_end_date)
		  and paf.effective_start_date = (select max(asg2.effective_start_date)
		                                                       from    per_all_assignments_f asg2
		                                                       where  asg2.assignment_id = paf.assignment_id
		                                                       and      asg2.effective_start_date <= cp_end_date
		                                                       and      nvl(asg2.effective_end_date, to_date('31-12-4712','DD-MM-RRRR')) >= cp_start_date)
		                                                                         /*bug 3595646*/
		  and payef.assignment_id(+)= paa.assignment_id
		  -- For SR 5108858.993
		  -- 6774415 Changed eff dates to cert dates
		  and (payef.certificate_start_date is null or payef.certificate_start_date <= cp_end_date) --8229764
              and (payef.certificate_end_date IS NULL OR payef.certificate_end_date >= cp_start_date)
		  --
		  and (payef.effective_end_date    = (select max(paye.effective_end_date)
		                                             from   pay_ie_paye_details_f paye
		                                             where  paye.assignment_id = paa.assignment_id
		                                             --6774415 Changed eff dates to cert dates, nvl for 8229764
		                                             and    nvl(paye.certificate_start_date, to_date('01/01/0001','DD/MM/YYYY')) <= cp_end_date
		                                             and    nvl(paye.certificate_end_date,to_date('31/12/4712','DD/MM/YYYY')) >= cp_start_date
		                                        )
		             or
		             payef.effective_end_date IS NULL
		             )
		  and prsif.assignment_id(+)= paa.assignment_id
		  -- For SR - 5108858.993, similar changes were made to PRSI as
		  -- made for PAYE
		  and prsif.effective_start_date(+) <= cp_end_date /*to_date(pay_ie_p35.get_parameter(ppa35.payroll_action_id,'END_DATE'),'YYYY/MM/DD')*/
              and prsif.effective_end_date(+) >= cp_start_date /*to_date(pay_ie_p35.get_parameter(ppa35.payroll_action_id,'START_DATE'),'YYYY/MM/DD')*/
		  --
		  and (prsif.effective_end_date    = (select max(prsi.effective_end_date)
		                                             from   pay_ie_prsi_details_f prsi
		                                             where  prsi.assignment_id = paa.assignment_id
		                                             and    prsi.effective_start_date <= cp_end_date /*to_date(pay_ie_p35.get_parameter(ppa35.payroll_action_id,'END_DATE'),'YYYY/MM/DD')*/
		                                             and    prsi.effective_end_date >= cp_start_date /*to_date(pay_ie_p35.get_parameter(ppa35.payroll_action_id,'START_DATE'),'YYYY/MM/DD')*/
		                                        )
		             or
		             prsif.effective_end_date IS NULL
		             )
		-- Bug 3446744 Removed the check of a P45 existence
		/*  and not exists (select 1 from pay_assignment_actions          paax
		                             ,pay_payroll_actions             ppax
		                             WHERE
		                                paax.assignment_id              = paa.assignment_id
		                                and ppax.payroll_action_id     = paax.payroll_action_id
		                                and ppax.report_type            = 'P45'
		                                and ppax.business_group_id      = ppa35.business_group_id
		                                and ppax.action_status          = 'C') */
		/*6876894*/
		/* removing the check with the assignment set ammendments and checking later for both ammendment set criteria
		and ammendments for a particular assignment set id*/
		/* AND  (p_assignment_set_id IS NULL OR EXISTS (SELECT '  '
					                           FROM HR_ASSIGNMENT_SET_AMENDMENTS HR_ASG
								    WHERE  HR_ASG.ASSIGNMENT_SET_ID=NVL(p_assignment_set_id, HR_ASG.ASSIGNMENT_SET_ID)
					                            AND     HR_ASG.ASSIGNMENT_ID=PAA.ASSIGNMENT_ID ))
		*/
		          and PAPF.payroll_id = paf.payroll_id
		          and PAPF.business_group_id + 0 = p_business_group_id /*4483028*/
		          and   PAPF.payroll_id                        = nvl(p_payroll_id,papf.payroll_id)
		          and   papf.consolidation_set_id              =nvl(p_consolidation_set_id,PAPF.consolidation_set_id)
		          and PAPF.effective_end_date = (select max(PAPF1.effective_end_date)
		                                        from   pay_all_payrolls_f PAPF1
		                                        where  PAPF1.payroll_id = PAPF.payroll_id
		                                        and    PAPF1.effective_start_date <= cp_end_date --to_date(pay_ie_p35.get_parameter(ppa35.payroll_action_id,'END_DATE'),'YYYY/MM/DD')
		                                        and    PAPF1.effective_end_date >= cp_start_date --to_date(pay_ie_p35.get_parameter(ppa35.payroll_action_id,'START_DATE'),'YYYY/MM/DD')
		                                      )
		  AND   pact_ade.action_information_category    = 'ADDRESS DETAILS'
		  AND   pact_ade.action_context_type            = 'PA'
		  AND   pai.action_information_category         = 'IE P35 DETAIL'
		  -- added for PRSI section changes 5657992
		  AND   pai_prsi.action_information_category    = 'IE P35 ADDITIONAL DETAILS'
		  AND   pai.action_context_id                   = pai_prsi.action_context_id
		  -- end 5657992
		  AND   pact_ade.ACTION_CONTEXT_ID              = paa.payroll_action_id
		  and paf.period_of_service_id = pps.period_of_service_id
		  and paf.person_id= pps.person_id
		  order by decode(p_sort_order,'Last Name',SUBSTR(trim(pai.action_information18||','|| pai.action_information19),1,30),
		                               'Address Line1',substr(trim(pai.action_information21),1,30),
		                               'Address Line2',substr(trim(pai.action_information22),1,30),
		                               'County',rpad(substr(trim(pai.action_information23),1,30) ,30,' '),
		                               'Assignment Number',paf.assignment_number,
		                               'National Identifier',nvl(pai.action_information1,' '),
		                               SUBSTR(trim(pai.action_information18||','|| pai.action_information19),1,30));

       /*
       CURSOR cur_assignment_action_till_apr(c_ppsn varchar2
                                           ,c_assignment_id per_all_assignments.assignment_id%type
					   ,c_person_id per_all_people_f.person_id%type) is
        SELECT fnd_number.canonical_to_number(substr(max(lpad(paa.action_sequence,15,'0')||
               paa.assignment_action_id),16))
        FROM pay_assignment_actions paa,pay_payroll_actions ppa
        WHERE ((c_ppsn is null and paa.assignment_id=c_assignment_id)
	OR(c_ppsn is not null and paa.assignment_id in (select paaf.assignment_id
                                                        from per_all_assignments_f paaf, per_assignment_extra_info paei
							where paaf.person_id = c_person_id
                                              		  and paaf.assignment_id=paei.assignment_id
			                                  and paei.information_type = 'IE_ASG_OVERRIDE'
			                                  and paei.aei_information1 = c_ppsn     --'314678745T'
			                                )))
       AND paa.payroll_action_id=ppa.payroll_action_id
       AND ppa.action_type in ('Q','B','R','I','V')
       AND ppa.action_status ='C'
       AND paa.source_action_id is null
       AND ppa.effective_date<= to_date('30/04'||'/'||to_char(cp_end_date,'yyyy'),'dd/mm/yyyy');
       */

       CURSOR cur_assignment_action_till_apr(c_assignment_id per_all_assignments.assignment_id%type
					   ) is
       SELECT fnd_number.canonical_to_number(substr(max(lpad(paa.action_sequence,15,'0')||
               paa.assignment_action_id),16))
       FROM pay_assignment_actions paa
           ,pay_payroll_actions ppa
       WHERE paa.assignment_id=c_assignment_id
         AND paa.payroll_action_id=ppa.payroll_action_id
         AND ppa.action_type in ('Q','B','R','I','V')
         AND ppa.action_status ='C'
         AND paa.source_action_id is null
         AND ppa.effective_date<= to_date('30/04'||'/'||to_char(cp_end_date,'yyyy'),'dd/mm/yyyy');

       CURSOR cur_assignment_action(c_assignment_id per_all_assignments.assignment_id%type
					   ) is
       SELECT fnd_number.canonical_to_number(substr(max(lpad(paa.action_sequence,15,'0')||
               paa.assignment_action_id),16))
       FROM pay_assignment_actions paa
           ,pay_payroll_actions ppa
       WHERE paa.assignment_id=c_assignment_id
         AND paa.payroll_action_id=ppa.payroll_action_id
         AND ppa.action_type in ('Q','B','R','I','V')
         AND ppa.action_status ='C'
         AND paa.source_action_id is null
         AND ppa.effective_date between cp_start_date and cp_end_date;

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

	  CURSOR cur_paye_ref(c_assignment_id per_all_assignments.assignment_id%type
					   ,c_person_id per_all_people_f.person_id%type)  IS
          SELECT scl.segment4 paye_ref
          FROM  per_all_assignments_f paaf,
                pay_all_payrolls_f papf,
                hr_soft_coding_keyflex scl
          WHERE paaf.person_id = c_person_id
	    AND paaf.assignment_id=c_assignment_id
            AND paaf.payroll_id = papf.payroll_id
	    /* 9255733 */
	    AND papf.effective_end_date = (select max(PAPF1.effective_end_date)
		                                        from   pay_all_payrolls_f PAPF1
		                                        where  PAPF1.payroll_id = papf.payroll_id
		                                        and    PAPF1.effective_start_date <= cp_end_date
		                                        and    PAPF1.effective_end_date >= cp_start_date
		                                      )
            AND papf.soft_coding_keyflex_id = scl.soft_coding_keyflex_id;

         CURSOR csr_ppsn_override(p_asg_id NUMBER) IS
          SELECT aei_information1 PPSN_OVERRIDE
            FROM per_assignment_extra_info
           WHERE assignment_id = p_asg_id
             AND aei_information_category = 'IE_ASG_OVERRIDE';

       CURSOR csr_get_org_email(l_paye_ref    number
                                  ) IS
    SELECT
       org_info1.org_information3 email    /* knadhan */

    FROM  hr_organization_information org_info1
    WHERE
    org_info1.org_information_context   = 'ORG_CONTACT_DETAILS'
    AND    org_info1.org_information1   ='EMAIL'
    AND    org_info1.organization_id = l_paye_ref
    ;

     CURSOR c_get_periods_of_service(v_person_id NUMBER,
				  v_assignment_id NUMBER,
				  v_paye_ref      NUMBER) IS

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
	AND    flex.segment4 = v_paye_ref
	AND    actual_termination_date IS NOT NULL
	AND    actual_termination_date BETWEEN cp_start_date
					   AND cp_end_date;

     /* CURSOR c_get_max_aact(p_pds_id NUMBER) IS
	SELECT fnd_number.canonical_to_number(substr(max(lpad(paa.action_sequence,15,'0')||
               paa.assignment_action_id),16))
	FROM   pay_assignment_Actions paa,
	       pay_payroll_actions ppa

	WHERE  paa.assignment_id in (SELECT assignment_id
						FROM   per_assignments_f
						WHERE  period_of_service_id = p_pds_id)
	AND    paa.payroll_action_id = ppa.payroll_action_id
	AND    ppa.action_type IN ('R','Q','I','B','V')
	AND    paa.action_status = 'C'
        AND paa.source_action_id is null
         AND ppa.effective_date<= to_date('30/04'||'/'||to_char(cp_end_date,'yyyy'),'dd/mm/yyyy'); */

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
         AND ppa.effective_date<= to_date('30/04'||'/'||to_char(cp_end_date,'yyyy'),'dd/mm/yyyy');

        l_ppsn_override per_assignment_extra_info.aei_information1%type:=null;
        /*6876894*/
	l_formula_id          NUMBER;
        l_include_flag        VARCHAR2(10);
	l_email VARCHAR2(100):=null;
	skip_assignment       Exception;
	l_flag                VARCHAR2(2);
	l_assignment_action_till_apr  number;
	l_assignment_action   number; /* knadhan */
	l_paye_ref number;
	l_defined_balance_id pay_defined_balances.defined_balance_id%type;

	l_gross_pay_till_apr            number;
        l_gross_pay_adjust_till_apr     number;
        l_bik_prsi_taxable_till_apr     number;
        l_income_levy_till_apr          number;
        l_gross_pay_total_till_apr      number;
	l_balance_value_till_apr        NUMBER:=0;
	l_pre_bal_value_till_apr        NUMBER:=0;

	l_gross_pay_frm_may            number;
        l_gross_pay_adjust_frm_may     number;
        l_bik_prsi_taxable_frm_may     number;
        l_income_levy_frm_may          number;
        l_gross_pay_total_frm_may      number;

	l_prev_period_service_id       NUMBER;
        l_prev_asg_action_till_apr     NUMBER;

begin
	hr_utility.set_location('Entering get_eoy_income_details',10);
	vCtr := 0;
	vXMLTable(vCtr).xmlstring := '<?xml version="1.0" encoding="UTF-8"?>';
	vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<ROOT>';
	vCtr := vCtr +1;


	/*6876894*/
	get_asg_set_details(p_assignment_set_id      => p_assignment_set_id
                            ,p_formula_id             => l_formula_id
                            ,p_tab_asg_set_amnds      => l_tab_asg_set_amnds

                            );
        fnd_file.put_line(fnd_file.LOG,'after get_asg_set_details' );


        fnd_file.put_line(fnd_file.LOG,'till date ' || to_date('30/04'||'/'||to_char(cp_end_date,'yyyy'),'dd/mm/yyyy') );
	for p60 in c_p60_records( cp_start_date,
				  cp_effective_date,
				  cp_end_date,
				  p_business_group_id,
				  p_assignment_set_id,
				  p_payroll_id,
				  p_consolidation_set_id,
				  p_sort_order) LOOP


        /*6876894*/
        fnd_file.put_line(fnd_file.LOG,'assignment_id'||p60.assignment_id);
	l_gross_pay_till_apr           :=0;
        l_gross_pay_adjust_till_apr    :=0;
        l_bik_prsi_taxable_till_apr    :=0;
        l_income_levy_till_apr         :=0;
        l_gross_pay_total_till_apr     :=0;
	l_balance_value_till_apr       :=0;

	l_pre_bal_value_till_apr       :=0;

	l_gross_pay_frm_may           :=0;
        l_gross_pay_adjust_frm_may    :=0;
        l_bik_prsi_taxable_frm_may    :=0;
        l_income_levy_frm_may         :=0;
        l_gross_pay_total_frm_may     :=0;
	l_flag:='Y';
	If p_assignment_set_id is not null then
		l_include_flag  :=  chk_is_asg_in_asg_set(p_assignment_id     => p60.assignment_id
		                                    ,p_formula_id             => l_formula_id
						    ,p_tab_asg_set_amnds      => l_tab_asg_set_amnds
						    ,p_effective_date         => cp_effective_date
                                    );
                  fnd_file.put_line(fnd_file.LOG,'l_include_flag'||l_include_flag);
			if l_include_flag = 'N' then
				l_flag:='N';
			end if;
	 end if;

        fnd_file.put_line(fnd_file.LOG,'p60.ppsn' || p60.ppsn);
        fnd_file.put_line(fnd_file.LOG,'p60.assignment_id' || p60.assignment_id);
	fnd_file.put_line(fnd_file.LOG,'p60.person_id' || p60.person_id);
	OPEN cur_assignment_action_till_apr(p60.assignment_id);
	FETCH cur_assignment_action_till_apr into l_assignment_action_till_apr;
	CLOSE cur_assignment_action_till_apr;

         fnd_file.put_line(fnd_file.LOG,'l_assignment_action_till_apr'|| l_assignment_action_till_apr);

	OPEN cur_assignment_action(p60.assignment_id);
	FETCH cur_assignment_action into l_assignment_action;
	CLOSE cur_assignment_action;

         fnd_file.put_line(fnd_file.LOG,'l_assignment_action'|| l_assignment_action);
	OPEN cur_paye_ref(p60.assignment_id,p60.person_id);
	FETCH cur_paye_ref INTO l_paye_ref;
	CLOSE cur_paye_ref;

	 fnd_file.put_line(fnd_file.LOG,'l_paye_ref'|| l_paye_ref);

	 OPEN csr_get_org_email(l_paye_ref);
	 FETCH csr_get_org_email INTO l_email;
	 CLOSE csr_get_org_email;

	 fnd_file.put_line(fnd_file.LOG,'l_email'|| l_email);
         l_ppsn_override:=null;
	 OPEN csr_ppsn_override(p60.assignment_id);
         FETCH csr_ppsn_override INTO l_ppsn_override;
         IF csr_ppsn_override%NOTFOUND THEN
            l_ppsn_override:=null;
         END IF;
         CLOSE csr_ppsn_override;

        fnd_file.put_line(fnd_file.LOG,'l_ppsn_override'|| l_ppsn_override);

	 OPEN c_get_periods_of_service(p60.person_id,p60.assignment_id,l_paye_ref);
	 FETCH c_get_periods_of_service INTO l_prev_period_service_id;
	 CLOSE c_get_periods_of_service;

	  fnd_file.put_line(fnd_file.LOG,'l_prev_period_service_id'|| l_prev_period_service_id);
	 OPEN c_get_max_aact(l_prev_period_service_id,l_ppsn_override,p60.person_id);
	 FETCH c_get_max_aact INTO l_prev_asg_action_till_apr;
	 CLOSE c_get_max_aact;

         fnd_file.put_line(fnd_file.LOG,'l_prev_asg_action_till_apr'|| l_prev_asg_action_till_apr);

	IF l_ppsn_override is null THEN
          OPEN cur_defined_balance_id('IE Gross Income','_PER_PAYE_REF_YTD');

        ELSE
          OPEN cur_defined_balance_id('IE Gross Income','_PER_PAYE_REF_PPSN_YTD');
        END IF;

        FETCH cur_defined_balance_id INTO l_defined_balance_id;
        CLOSE cur_defined_balance_id;

	IF l_assignment_action_till_apr is not null THEN
        l_balance_value_till_apr := PAY_BALANCE_PKG.GET_VALUE(l_defined_balance_id,
    			                 l_assignment_action_till_apr,
                                   l_paye_ref,
                                   null,
                                   null,
                                   null,
                                   null,
                                   null);
        ELSE
	l_balance_value_till_apr:=0;
        END IF;

	fnd_file.put_line(fnd_file.LOG,'l_balance_value_till_apr'|| l_balance_value_till_apr);
	IF l_prev_asg_action_till_apr is not null and l_assignment_action_till_apr is not null THEN
        l_pre_bal_value_till_apr := PAY_BALANCE_PKG.GET_VALUE(l_defined_balance_id,
    			                 l_prev_asg_action_till_apr,
                                   l_paye_ref,
                                   null,
                                   null,
                                   null,
                                   null,
                                   null);
       END IF;
       fnd_file.put_line(fnd_file.LOG,'l_pre_bal_value_till_apr'|| l_pre_bal_value_till_apr);
        l_balance_value_till_apr:=l_balance_value_till_apr-l_pre_bal_value_till_apr;
	fnd_file.put_line(fnd_file.LOG,'l_balance_value_till_apr'|| l_balance_value_till_apr);
	l_gross_pay_till_apr:=l_balance_value_till_apr;
	fnd_file.put_line(fnd_file.LOG,'l_gross_pay_till_apr'|| l_gross_pay_till_apr);
        l_defined_balance_id:=null;
        l_balance_value_till_apr:=0;

	IF l_ppsn_override is null THEN
          OPEN cur_defined_balance_id('IE Gross Income Adjustment','_PER_PAYE_REF_YTD');

        ELSE
          OPEN cur_defined_balance_id('IE Gross Income Adjustment','_PER_PAYE_REF_PPSN_YTD');
        END IF;

        FETCH cur_defined_balance_id INTO l_defined_balance_id;
        CLOSE cur_defined_balance_id;

	IF l_assignment_action_till_apr is not null THEN
        l_balance_value_till_apr := PAY_BALANCE_PKG.GET_VALUE(l_defined_balance_id,
    			                 l_assignment_action_till_apr,
                                   l_paye_ref,
                                   null,
                                   null,
                                   null,
                                   null,
                                   null);
        ELSE
	l_balance_value_till_apr:=0;
        END IF;

	fnd_file.put_line(fnd_file.LOG,'l_balance_value_till_apr'|| l_balance_value_till_apr);

	IF l_prev_asg_action_till_apr is not null and l_assignment_action_till_apr is not null THEN
        l_pre_bal_value_till_apr := PAY_BALANCE_PKG.GET_VALUE(l_defined_balance_id,
    			                 l_prev_asg_action_till_apr,
                                   l_paye_ref,
                                   null,
                                   null,
                                   null,
                                   null,
                                   null);
        END IF;
        fnd_file.put_line(fnd_file.LOG,'l_pre_bal_value_till_apr'|| l_pre_bal_value_till_apr);
        l_balance_value_till_apr:=l_balance_value_till_apr-l_pre_bal_value_till_apr;
        fnd_file.put_line(fnd_file.LOG,'l_balance_value_till_apr'|| l_balance_value_till_apr);

	l_gross_pay_adjust_till_apr:=l_balance_value_till_apr;
	fnd_file.put_line(fnd_file.LOG,'l_gross_pay_adjust_till_apr'|| l_gross_pay_adjust_till_apr);
        l_defined_balance_id:=null;
        l_balance_value_till_apr:=0;

        IF l_ppsn_override is null THEN
          OPEN cur_defined_balance_id('IE BIK Taxable and PRSIable Pay','_PER_PAYE_REF_YTD');

        ELSE
          OPEN cur_defined_balance_id('IE BIK Taxable and PRSIable Pay','_PER_PAYE_REF_PPSN_YTD');
        END IF;

        FETCH cur_defined_balance_id INTO l_defined_balance_id;
        CLOSE cur_defined_balance_id;

	IF l_assignment_action_till_apr is not null THEN
        l_balance_value_till_apr := PAY_BALANCE_PKG.GET_VALUE(l_defined_balance_id, /* 9123413 replaced l_bik_prsi_taxable_till_apr with l_balance_value_till_apr */
    			                 l_assignment_action_till_apr,
                                   l_paye_ref,
                                   null,
                                   null,
                                   null,
                                   null,
                                   null);
        ELSE
	l_balance_value_till_apr:=0;
        END IF;

	fnd_file.put_line(fnd_file.LOG,'l_balance_value_till_apr'|| l_balance_value_till_apr);

	IF l_prev_asg_action_till_apr is not null and l_assignment_action_till_apr is not null THEN
        l_pre_bal_value_till_apr := PAY_BALANCE_PKG.GET_VALUE(l_defined_balance_id,
    			                 l_prev_asg_action_till_apr,
                                   l_paye_ref,
                                   null,
                                   null,
                                   null,
                                   null,
                                   null);
        END IF;
        fnd_file.put_line(fnd_file.LOG,'l_pre_bal_value_till_apr'|| l_pre_bal_value_till_apr);
        l_balance_value_till_apr:=l_balance_value_till_apr-l_pre_bal_value_till_apr;
        fnd_file.put_line(fnd_file.LOG,'l_balance_value_till_apr'|| l_balance_value_till_apr);

	l_bik_prsi_taxable_till_apr:=l_balance_value_till_apr;
	fnd_file.put_line(fnd_file.LOG,'l_bik_prsi_taxable_till_apr'|| l_bik_prsi_taxable_till_apr);
        l_defined_balance_id:=null;
        l_balance_value_till_apr:=0;

        IF l_ppsn_override is null THEN
          OPEN cur_defined_balance_id('IE Income Tax Levy','_PER_PAYE_REF_YTD');

        ELSE
          OPEN cur_defined_balance_id('IE Income Tax Levy','_PER_PAYE_REF_PPSN_YTD');
        END IF;

        FETCH cur_defined_balance_id INTO l_defined_balance_id;
        CLOSE cur_defined_balance_id;

	IF l_assignment_action_till_apr is not null THEN
        l_balance_value_till_apr := PAY_BALANCE_PKG.GET_VALUE(l_defined_balance_id,
    			                 l_assignment_action_till_apr,
                                   l_paye_ref,
                                   null,
                                   null,
                                   null,
                                   null,
                                   null);
        ELSE
	l_balance_value_till_apr:=0;
        END IF;

	fnd_file.put_line(fnd_file.LOG,'l_balance_value_till_apr'|| l_balance_value_till_apr);

	IF l_prev_asg_action_till_apr is not null and l_assignment_action_till_apr is not null THEN
        l_pre_bal_value_till_apr := PAY_BALANCE_PKG.GET_VALUE(l_defined_balance_id,
    			                 l_prev_asg_action_till_apr,
                                   l_paye_ref,
                                   null,
                                   null,
                                   null,
                                   null,
                                   null);
        END IF;
        fnd_file.put_line(fnd_file.LOG,'l_pre_bal_value_till_apr'|| l_pre_bal_value_till_apr);
        l_balance_value_till_apr:=l_balance_value_till_apr-l_pre_bal_value_till_apr;
        fnd_file.put_line(fnd_file.LOG,'l_balance_value_till_apr'|| l_balance_value_till_apr);

	l_income_levy_till_apr:=l_balance_value_till_apr;
	fnd_file.put_line(fnd_file.LOG,'l_income_levy_till_apr'|| l_income_levy_till_apr);
        l_defined_balance_id:=null;
        l_balance_value_till_apr:=0;

	/* knadhan the assignment action passed is the till end of year as recaluclated balance is fed in 53 week calculation*/
	IF l_ppsn_override is null THEN
          OPEN cur_defined_balance_id('IE Recalculated Levy','_PER_PAYE_REF_YTD');

        ELSE
          OPEN cur_defined_balance_id('IE Recalculated Levy','_PER_PAYE_REF_PPSN_YTD');
        END IF;

        FETCH cur_defined_balance_id INTO l_defined_balance_id;
        CLOSE cur_defined_balance_id;

	IF l_assignment_action_till_apr is not null THEN
        l_balance_value_till_apr := PAY_BALANCE_PKG.GET_VALUE(l_defined_balance_id,
    			                 l_assignment_action,
                                   l_paye_ref,
                                   null,
                                   null,
                                   null,
                                   null,
                                   null);
        ELSE
	l_balance_value_till_apr:=0;
        END IF;

	fnd_file.put_line(fnd_file.LOG,'l_balance_value_till_apr'|| l_balance_value_till_apr);

	IF l_prev_asg_action_till_apr is not null and l_assignment_action_till_apr is not null THEN
        l_pre_bal_value_till_apr := PAY_BALANCE_PKG.GET_VALUE(l_defined_balance_id,
    			                 l_prev_asg_action_till_apr,
                                   l_paye_ref,
                                   null,
                                   null,
                                   null,
                                   null,
                                   null);
        END IF;
        fnd_file.put_line(fnd_file.LOG,'l_pre_bal_value_till_apr'|| l_pre_bal_value_till_apr);
        l_balance_value_till_apr:=l_balance_value_till_apr-l_pre_bal_value_till_apr;
        fnd_file.put_line(fnd_file.LOG,'l_balance_value_till_apr'|| l_balance_value_till_apr);
        l_income_levy_till_apr:=l_income_levy_till_apr+l_balance_value_till_apr;

        l_gross_pay_total_till_apr :=l_gross_pay_till_apr + l_gross_pay_adjust_till_apr + l_bik_prsi_taxable_till_apr;

        l_gross_pay_frm_may := p60.total_gross_pay - l_gross_pay_total_till_apr;
        l_income_levy_frm_may := p60.total_income_levy - l_income_levy_till_apr;
        fnd_file.put_line(fnd_file.LOG,'l_income_levy_till_apr'|| l_income_levy_till_apr);

      	fnd_file.put_line(fnd_file.LOG,'p60.total_gross_pay'|| p60.total_gross_pay);
	fnd_file.put_line(fnd_file.LOG,'l_gross_pay_total_till_apr'|| l_gross_pay_total_till_apr);
	fnd_file.put_line(fnd_file.LOG,'l_gross_pay_frm_may'|| l_gross_pay_frm_may);

        fnd_file.put_line(fnd_file.LOG,'p60.total_income_levy'|| p60.total_income_levy);
	fnd_file.put_line(fnd_file.LOG,'l_income_levy_till_apr'|| l_income_levy_till_apr);
	fnd_file.put_line(fnd_file.LOG,'l_income_levy_frm_may'|| l_income_levy_frm_may);


	       IF(l_flag='Y') THEN


		vXMLTable(vCtr).xmlstring := '<EMPLOYEE>';
		vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<SURNAME>'|| test_XML(p60.surname) ||'</SURNAME>';
		vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<FIRST_NAME>'|| test_XML(p60.first_name) ||'</FIRST_NAME>';
		vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<PPSN>'|| p60.ppsn ||'</PPSN>';
		vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<WORKS_NUM>'|| p60.works_num ||'</WORKS_NUM>';
		vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<HIRE_DATE>'|| p60.hire_date ||'</HIRE_DATE>';
		vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<GROSS_INCOME>'|| lpad(trim(to_char(fnd_number.canonical_to_number(nvl(p60.total_gross_pay,0)) ,'99999990.99')),10,' ') ||'</GROSS_INCOME>';
		vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<LEVY>'|| lpad(trim(to_char(fnd_number.canonical_to_number(nvl( p60.total_income_levy ,0)) ,'99999990.99')),10,' ') ||'</LEVY>';
		vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<GROSS_INCOME_TILL_APR>'|| lpad(trim(to_char(fnd_number.canonical_to_number(nvl(l_gross_pay_total_till_apr,0)) ,'9999999')),7,' ')  ||'</GROSS_INCOME_TILL_APR>';
		vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<LEVY_TILL_APR>'|| lpad(trim(to_char(fnd_number.canonical_to_number(nvl(l_income_levy_till_apr,0)) ,'999990.99')),8,' ') ||'</LEVY_TILL_APR>';
		vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<GROSS_INCOME_FRM_MAY>'|| lpad(trim(to_char(fnd_number.canonical_to_number(nvl(l_gross_pay_frm_may,0)) ,'9999999')),7,' ') ||'</GROSS_INCOME_FRM_MAY>';
		vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<LEVY_FRM_MAY>'|| lpad(trim(to_char(fnd_number.canonical_to_number(nvl(l_income_levy_frm_may,0)) ,'999990.99')),8,' ') ||'</LEVY_FRM_MAY>';
		vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<ER_NAME>'|| test_XML(p60.Employer_name) ||'</ER_NAME>';
		vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<ADDR_LINE1>'|| test_XML(p60.address_line1) ||'</ADDR_LINE1>';
		vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<ADDR_LINE2>'|| test_XML(p60.address_line2) ||'</ADDR_LINE2>';
		vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<ADDR_LINE3>'|| test_XML(p60.address_line3) ||'</ADDR_LINE3>';

		vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<EE_ADDR_LINE1>'|| test_XML(p60.emp_Address1) ||'</EE_ADDR_LINE1>'; /* 9160076  9323591*/
		vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<EE_ADDR_LINE2>'|| test_XML(p60.emp_Address2) ||'</EE_ADDR_LINE2>'; /* 9323591 */
		vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<EE_ADDR_LINE3>'|| test_XML(p60.emp_County) ||'</EE_ADDR_LINE3>'; /* 9323591 */

		vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<EMAIL>'||NVL( l_email,'') ||'</EMAIL>';
		vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<ER_NUM>'|| p60.Employer_number ||'</ER_NUM>';
		vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<ER_PHONE>'|| p60.Phone_number ||'</ER_PHONE>';


		vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '</EMPLOYEE>';
		vCtr := vCtr + 1;
            END IF;
	END LOOP;
	vXMLTable(vCtr).xmlstring := '</ROOT>';
	end get_eoy_income_details;
	procedure populate_eoy_income_details(P_START_DATE IN VARCHAR2 DEFAULT NULL
				      ,CP_EFFECTIVE_DATE IN VARCHAR2 DEFAULT NULL
				      ,P_END_DATE IN VARCHAR2 DEFAULT NULL
				      ,P_BUSINESS_GROUP_ID IN VARCHAR2 DEFAULT NULL
				      ,P_ASSIGNMENT_SET_ID IN VARCHAR2 DEFAULT NULL
				      ,P_PAYROLL_ID IN VARCHAR2 DEFAULT NULL
				      ,P_CONSOLIDATION_SET_ID IN VARCHAR2 DEFAULT NULL
				      ,P_SORT_ORDER IN VARCHAR2 DEFAULT NULL
				      ,P_TEMPLATE_NAME IN VARCHAR2
				      ,P_XML OUT NOCOPY CLOB
				      ) IS
		cp_start_date date;
		p_effective_date date;
		cp_end_date date;
		cp_business_group_id number := to_number(p_business_group_id);
		cp_assignment_set_id number := to_number(p_assignment_set_id);
		cp_payroll_id        number := to_number(p_payroll_id);
		cp_consolidation_set_id number := to_number(p_consolidation_set_id);

	begin

		cp_start_date := fnd_date.canonical_to_date(p_start_date);
		p_effective_date := fnd_date.canonical_to_date(cp_effective_date);
		cp_end_date := fnd_date.canonical_to_date(p_end_date);
		get_eoy_income_details(cp_start_date,p_effective_date,cp_end_date,
				cp_business_group_id,cp_assignment_set_id,cp_payroll_id,
				cp_consolidation_set_id,p_sort_order);
		WritetoCLOB(p_xml);
end populate_eoy_income_details;

 -- Fucntion to Convert to Local Caharacter set
   -- Bug 4705094
    FUNCTION TO_UTF8(str in varchar2 )RETURN VARCHAR2
    AS
    db_charset varchar2(30);
    BEGIN
    select value into db_charset
    from nls_database_parameters
    where parameter = 'NLS_CHARACTERSET';
    return convert(str,'UTF8',db_charset);
    END;

PROCEDURE WritetoCLOB (p_xml out nocopy clob) IS
l_xfdf_string clob;
l_str1 varchar2(6000);
begin
hr_utility.set_location('Entered Procedure Write to clob ',100);
	dbms_lob.createtemporary(p_xml,FALSE,DBMS_LOB.CALL);
	dbms_lob.open(p_xml,dbms_lob.lob_readwrite);
	if vXMLTable.count > 0 then
        	FOR ctr_table IN vXMLTable.FIRST .. vXMLTable.LAST LOOP
		  -- Bug 4705094
		  l_str1 := TO_UTF8(vXMLTable(ctr_table).xmlString);
		  dbms_lob.writeAppend( p_xml, length(l_str1), l_str1 );
		END LOOP;
	end if;
	--DBMS_LOB.CREATETEMPORARY(p_xml,TRUE);
	--clob_to_blob(l_xfdf_string,p_xml);
	hr_utility.set_location('Finished Procedure Write to CLOB ,Before clob to blob ',110);
	EXCEPTION
		WHEN OTHERS then
	        HR_UTILITY.TRACE('sqleerm ' || SQLERRM);
	        HR_UTILITY.RAISE_ERROR;
END WritetoCLOB;
end pay_ie_eoy_incomelevy_report;

/
