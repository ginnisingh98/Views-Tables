--------------------------------------------------------
--  DDL for Package Body PAY_IE_P60XML
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_IE_P60XML" as
  /* $Header: pyiep60p.pkb 120.15.12010000.7 2009/11/25 12:51:26 knadhan ship $ */
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




	procedure get_p60_details(p_53_indicator in varchar2,
				  cp_start_date in date,
				  cp_effective_date in date,
				  cp_end_date in date,
				  p_business_group_id in number,
				  p_assignment_set_id in number,
				  p_payroll_id in number,
				  p_consolidation_set_id in number,
				  p_sort_order in varchar2)
is
		cursor c_p60_records(p_53_indicator  varchar2,
				  cp_start_date  date,
				  cp_effective_date  date,
				  cp_end_date  date,
				  p_business_group_id number,
				  p_assignment_set_id  number,
				  p_payroll_id  number,
				  p_consolidation_set_id  number,
				  p_sort_order  varchar2) IS
		  select
			 SUBSTR(trim(pai.action_information18||','|| pai.action_information19),1,30) Q1_Employee
			,substr(trim(pai.action_information21),1,30)  Q1_Address1
			,substr(trim(pai.action_information22),1,30)  Q1_Address2
		      ,rpad(substr(trim(pai.action_information23),1,30) ,30,' ') Q1_County
		      , to_char(cp_end_date,'YYYY')     Q1_YEAR    /*bug 3595646*/
		  	,nvl(pai.action_information1,' ') Q1_PPSN
		      ,to_char(nvl(decode(papf.period_type,'Lunar Month',round((payef.WEEKLY_TAX_CREDIT*52),2),
                               decode(instr(papf.period_type,'Week'),0,round((payef.MONTHLY_TAX_CREDIT*12),2),round((payef.WEEKLY_TAX_CREDIT*52),2))),0),'999990.00') Q1_Tax_credits
		      ,to_char(nvl(decode(papf.period_type,'Lunar Month',round((payef.WEEKLY_STD_RATE_CUT_OFF*52),2),
			                         decode(instr(papf.period_type,'Week'),0,round((payef.MONTHLY_STD_RATE_CUT_OFF*12),2),round((payef.WEEKLY_STD_RATE_CUT_OFF*52),2))),0),'999990.00') Q1_Std_Rate
		      ,decode(payef.tax_basis,'IE_WEEK1_MONTH1','W', 'IE_EXEMPT_WEEK_MONTH', 'W')  Q1_WM_Indicator
		      ,decode(payef.TAX_BASIS,
                              'IE_WEEK1_MONTH1' , '1' ,
	                      'IE_EXEMPT_WEEK_MONTH' , '1',
                              'IE_EMERGENCY','2',
					NULL, '2',  --7710479
                               decode(payef.INFO_SOURCE,'IE_P45','1')) Q1_TB_Indicator /* 6982274 */
		    --  ,decode(payef.TAX_BASIS,'IE_EMERGENCY','2',decode(payef.INFO_SOURCE,'IE_P45','1')) Q1_TB_Indicator
		      ,decode(p_53_indicator,'Y','X') Q1_53_Indicator
		      ,decode(prsif.director_flag,'Y','D') Q1_Director_Indicator
			/*4130512  Total Pay must be sum  of.       ,nvl(round(to_number(trim(pai.action_information16)),2),0) Q1_Total_Pay*/
			-- changes made for bug 5435931
			,to_char(nvl(round(to_number(substr(trim(pai.action_information28),1,instr(pai.action_information28,'|',1,1)-1)),2),0) +
                   nvl(round(to_number(substr(trim(pai.action_information28),instr(pai.action_information28,'|',1,1)+1)),2),0),'999990.00') Q1_Total_Pay
			 -- bug 5435931
		      ,to_char(nvl(round(to_number(substr(trim(pai.action_information28),1,instr(pai.action_information28,'|',1,1)-1)),2),0),'999990.00') Q1_Previous_Emp_Pay
			-- bug 5435931
		      ,to_char(nvl(round(to_number(substr(trim(pai.action_information28),instr(pai.action_information28,'|',1,1)+1)),2),0),'999990.00') Q1_Present_pay
			-- bug 5435931
		      ,to_char(nvl(round(to_number(substr(trim(pai.action_information29),1,instr(pai.action_information29,'|',1,1)-1)),2),0) +
                   nvl(round(to_number(substr(trim(pai.action_information29),instr(pai.action_information29,'|',1,1)+1)),2),0),'999990.00') Q1_Total_Tax
			 -- bug 5435931
			,to_char(nvl(round(to_number(substr(trim(pai.action_information29),1,instr(pai.action_information29,'|',1,1)-1)),2),0),'999990.00') Q1_Previous_Emp_Tax
		      ,pai.action_information30 Q1_PR_Indicator
			-- bug 5435931
			,to_char(nvl(round(to_number(substr(trim(pai.action_information29),instr(pai.action_information29,'|',1,1)+1)),2),0),'999990.00')  Q1_Present_tax
			-- Modified for bug 5657992
			,to_char(nvl(round(to_number(trim(pai_prsi.action_information11)),2),0),'999990.00') Q1_EmployeePRSI
			,to_char(nvl(round(to_number(nvl(trim(pai_prsi.action_information12),0)),2),0),'999990.00') Q1_TotalPRSI
			,to_number(trim(pai_prsi.action_information13)) Q1_Total_Weeks_Insurable
			,pai_prsi.action_information14 Q1_Initial_Contribution_Class
			,rpad(pai_prsi.action_information15,2)  Q1_Sub_Contribution_Class
		      ,nvl(to_number(trim(pai_prsi.action_information16)),0) Q1_Weeks_In_Later_CC
			-- end bug 5657992
		      ,decode(sign(to_date(pai.action_information24,'DD-MM-YYYY')- cp_start_date),-1,Null,to_char(to_date(pai.action_information24,'DD-MM-YYYY'),'DD-MON-YYYY')) Q1_Date_Of_Hire
			,nvl(rtrim(pact_ade.action_information26),'') Q1_Employer
		      ,nvl(rtrim(pact_ade.action_information1),'') Q1_Employer_RegNo
		       --Bug No: 6474486 : Employer contact no. is added
          ,nvl(rtrim(pact_ade.action_information28),'') Q1_Employer_PhoneNo
			,to_char(cp_effective_date,'DD-MON-RR') Q1_Report_date        /* bug 3595646*/
		      ,paf.assignment_number     Q1_Assignment_Number
		      ,paf.person_id Q1_Person_Id
		      ,paf.assignment_id assignment_id /*6876894*/
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


        /*6876894*/
	l_formula_id          NUMBER;
        l_include_flag        VARCHAR2(10);
	skip_assignment       Exception;
	l_flag                VARCHAR2(2);
begin
	hr_utility.set_location('Entering get_p60_details',10);
	vCtr := 0;
	vXMLTable(vCtr).xmlstring := '<?xml version="1.0" encoding="UTF-8"?>';
	vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<start>';
	vCtr := vCtr +1;


	/*6876894*/
	get_asg_set_details(p_assignment_set_id      => p_assignment_set_id
                            ,p_formula_id             => l_formula_id
                            ,p_tab_asg_set_amnds      => l_tab_asg_set_amnds

                            );
        fnd_file.put_line(fnd_file.LOG,'after get_asg_set_details' );


	for p60 in c_p60_records(p_53_indicator,
				  cp_start_date,
				  cp_effective_date,
				  cp_end_date,
				  p_business_group_id,
				  p_assignment_set_id,
				  p_payroll_id,
				  p_consolidation_set_id,
				  p_sort_order) LOOP


        /*6876894*/
        fnd_file.put_line(fnd_file.LOG,'assignment_id'||p60.assignment_id);
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
	       IF(l_flag='Y') THEN

		vXMLTable(vCtr).xmlstring := '<G_Q1_YEAR>';
		vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring ||'<Q1_YEAR>'||p60.Q1_YEAR||'</Q1_YEAR>';
		vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<Q1_Employee>'||'<![CDATA[ '||p60.Q1_Employee||' ]]>'||'</Q1_Employee>';
		vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<Q1_Tax_credits>'||p60.Q1_Tax_credits||'</Q1_Tax_credits>';
		vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<Q1_Std_Rate>'||p60.Q1_Std_Rate||'</Q1_Std_Rate>';
		vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<Q1_Address1>'||'<![CDATA['||p60.Q1_Address1||']]>'|| '</Q1_Address1>';
		vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<Q1_Address2>'||'<![CDATA['||p60.Q1_Address2||']]>'||'</Q1_Address2>';
		vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<Q1_County>'|| p60.Q1_County ||'</Q1_County>'; /* knadhan */
		vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<Q1_TB_Indicator>'||p60.Q1_TB_Indicator||'</Q1_TB_Indicator>';
		vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<Q1_PPSN>'||p60.Q1_PPSN||'</Q1_PPSN>';
		vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<Q1_53_Indicator>'||p60.Q1_53_Indicator||'</Q1_53_Indicator>';
		vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<Q1_WM_Indicator>'||p60.Q1_WM_Indicator||'</Q1_WM_Indicator>';
		vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<Q1_Director_Indicator>'||p60.Q1_Director_Indicator||'</Q1_Director_Indicator>';
		vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<Q1_Total_Pay>'||p60.Q1_Total_Pay||'</Q1_Total_Pay>';
		vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<Q1_EmployeePRSI>'||p60.Q1_EmployeePRSI||'</Q1_EmployeePRSI>';
		vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<Q1_Previous_Emp_Pay>'||p60.Q1_Previous_Emp_Pay||'</Q1_Previous_Emp_Pay>';
		vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<Q1_TotalPRSI>'||p60.Q1_TotalPRSI||'</Q1_TotalPRSI>';
		vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<Q1_Present_pay>'||p60.Q1_Present_pay||'</Q1_Present_pay>';
		vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<Q1_Total_Weeks_Insurable>'||p60.Q1_Total_Weeks_Insurable||'</Q1_Total_Weeks_Insurable>';
		vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<Q1_Initial_Contribution_Class>'||p60.Q1_Initial_Contribution_Class||'</Q1_Initial_Contribution_Class>';
		vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<Q1_Total_Tax>'||p60.Q1_Total_Tax||'</Q1_Total_Tax>';
		vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<Q1_Sub_Contribution_Class>'||p60.Q1_Sub_Contribution_Class||'</Q1_Sub_Contribution_Class>';
		vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<Q1_Previous_Emp_Tax>'||p60.Q1_Previous_Emp_Tax||'</Q1_Previous_Emp_Tax>';
		vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<Q1_Weeks_In_Later_CC>'||p60.Q1_Weeks_In_Later_CC||'</Q1_Weeks_In_Later_CC>';
		vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<Q1_PR_Indicator>'||p60.Q1_PR_Indicator||'</Q1_PR_Indicator>';
		vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<Q1_Present_tax>'||p60.Q1_Present_tax||'</Q1_Present_tax>';
		vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<Q1_Date_Of_Hire>'||p60.Q1_Date_Of_Hire||'</Q1_Date_Of_Hire>';
		vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<Q1_Employer>'||'<![CDATA[ '||p60.Q1_Employer||' ]]>'||'</Q1_Employer>';
		vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<Q1_Employer_RegNo>'||p60.Q1_Employer_RegNo||'</Q1_Employer_RegNo>';
		-- Bug No: 6474486 : New tag Q1_Employer_PhoneNo is added to the RTF template.
    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<Q1_Employer_PhoneNo>'||p60.Q1_Employer_PhoneNo||'</Q1_Employer_PhoneNo>';
		vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<Q1_Report_date>'||p60.Q1_Report_date||'</Q1_Report_date>';
		vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<Q1_Assignment_Number>'||p60.Q1_Assignment_Number||'</Q1_Assignment_Number>'; -- 5467291
		vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring ||'</G_Q1_YEAR>';
		vCtr := vCtr + 1;
            END IF;
	END LOOP;
	vXMLTable(vCtr).xmlstring := '</start>';
	end get_p60_details;
	procedure populate_p60_details(P_53_INDICATOR IN VARCHAR2 DEFAULT NULL
				      ,P_START_DATE IN VARCHAR2 DEFAULT NULL
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
		get_p60_details(p_53_indicator,cp_start_date,p_effective_date,cp_end_date,
				cp_business_group_id,cp_assignment_set_id,cp_payroll_id,
				cp_consolidation_set_id,p_sort_order);
		WritetoCLOB(p_xml);
end populate_p60_details;

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

Procedure  clob_to_blob(p_clob clob
			,p_blob IN OUT NOCOPY blob)
  is
    l_length_clob number;
    l_offset integer;
    l_varchar_buffer varchar2(32000);
    l_raw_buffer raw(32000);
    l_buffer_len number:= 32000;
    l_chunk_len number;
    l_blob blob;
  begin
  	hr_utility.set_location('Entered Procedure clob to blob',120);
  	l_length_clob := dbms_lob.getlength(p_clob);
	l_offset := 1;
	while l_length_clob > 0 loop
		hr_utility.trace('l_length_clob '|| l_length_clob);
		if l_length_clob < l_buffer_len then
			l_chunk_len := l_length_clob;
		else
                        l_chunk_len := l_buffer_len;
		end if;
		DBMS_LOB.READ(p_clob,l_chunk_len,l_offset,l_varchar_buffer);
        	l_raw_buffer := utl_raw.cast_to_raw(l_varchar_buffer);
        	hr_utility.trace('l_varchar_buffer '|| l_varchar_buffer);
            dbms_lob.writeappend(p_blob,l_chunk_len,l_raw_buffer);
            l_offset := l_offset + l_chunk_len;
            l_length_clob := l_length_clob - l_chunk_len;
            hr_utility.trace('l_length_blob '|| dbms_lob.getlength(p_blob));
	end loop;
	hr_utility.set_location('Finished Procedure clob to blob ',130);
  end clob_to_blob;

Procedure fetch_rtf_blob (p_template_id number
			 ,p_rtf_blob OUT NOCOPY blob) IS
BEGIN
	Select file_data Into p_rtf_blob
	From fnd_lobs
	Where file_id = p_template_id;
	EXCEPTION
        	when no_data_found then
              	null;
END fetch_rtf_blob;
end;

/
