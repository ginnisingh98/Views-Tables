--------------------------------------------------------
--  DDL for Package Body PAY_IE_P30LOCK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_IE_P30LOCK" AS
/* $Header: pyiep30p.pkb 120.8.12010000.2 2009/03/19 06:37:48 knadhan ship $ */

g_package                CONSTANT VARCHAR2(30) := 'Pay_ie_P30lock';


FUNCTION get_parameter(
    p_parameter_string  in varchar2
         ,p_token             in varchar2
         ,p_segment_number    in number ) RETURN varchar2
IS
  l_parameter  pay_payroll_actions.legislative_parameters%TYPE:=NULL;
  l_start_pos  NUMBER;
  l_delimiter  varchar2(1):=' ';
  l_proc VARCHAR2(160):= g_package||'.get parameter ';
BEGIN
  hr_utility.set_location('Entering ' || l_proc, 20);
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
                          l_delimiter,l_start_pos)
                          - l_start_pos);
    IF p_segment_number IS NOT NULL THEN
      l_parameter := ':'||l_parameter||':';
      l_parameter := substr(l_parameter,
                            instr(l_parameter,':',1,p_segment_number)+1,
                            instr(l_parameter,':',1,p_segment_number+1) -1
                            - instr(l_parameter,':',1,p_segment_number));
    END IF;
  END IF;
  hr_utility.set_location('Leaving ' || l_proc, 100);
  RETURN l_parameter;

END get_parameter;


PROCEDURE get_all_parameters (   p_payroll_action_id       in number
        ,p_token       in varchar2
        ,p_business_group_id       out NOCOPY  number
        ,p_token_value       out NOCOPY VARCHAR2 ) IS

  CURSOR csr_parameter_info(p_payroll_action_id IN NUMBER) IS
  SELECT pay_ie_p30lock.get_parameter(legislative_parameters, p_token)
        ,business_group_id
  FROM  pay_payroll_actions
  WHERE payroll_action_id = p_payroll_action_id;
  l_proc VARCHAR2(160):= g_package||'.get_all_parameters ';

BEGIN

  hr_utility.set_location('Entering ' || l_proc, 20);

  OPEN  csr_parameter_info (p_payroll_action_id);
  FETCH csr_parameter_info INTO p_token_value,
                                p_business_group_id;
  CLOSE csr_parameter_info;

  hr_utility.set_location('Leaving ' || l_proc, 100);

END get_all_parameters;


-- First Lock Process to lock the PRG data

PROCEDURE range_code (pactid IN NUMBER,
                        sqlstr OUT NOCOPY VARCHAR2)
-- public procedure which archives the payroll information, then returns a
-- varchar2 defining a SQL statement to select all the people that may be
-- eligible for payslip reports.
-- The archiver uses this cursor to split the people into chunks for parallel
-- processing.
IS
  --
l_proc          CONSTANT VARCHAR2(150):= g_package||'.range_code';
l_business_group_id           NUMBER;
l_canonical_end_date            DATE;
l_end_date                      VARCHAR2(20);

BEGIN

hr_utility.set_location('Entering ' || l_proc,10);

  pay_ie_p30lock.get_all_parameters
  (p_payroll_action_id => pactid,
   p_token => 'END_DATE',
   p_business_group_id => l_business_group_id,
   p_token_value => l_end_date);


  hr_utility.set_location('Step ' || l_proc,20);
  hr_utility.set_location('l_end_date   = ' || l_end_date,20);

  l_canonical_end_date   := TO_DATE(l_end_date,'yyyy/mm/dd');
  hr_utility.set_location('l_canonical_end_date   = ' || l_canonical_end_date,20);

-- Used per_people_f  4555600
-- Changed the cursor to reduce the cost (5042843)
  sqlstr := 'SELECT distinct asg.person_id
              FROM per_periods_of_service pos,
                   per_assignments_f      asg,
                   pay_payroll_actions    ppa
             WHERE ppa.payroll_action_id = :payroll_action_id
               AND pos.person_id         = asg.person_id
               AND pos.period_of_service_id = asg.period_of_service_id
               AND pos.business_group_id = ppa.business_group_id
               AND asg.business_group_id = ppa.business_group_id
             ORDER BY asg.person_id';

  hr_utility.set_location('Leaving ' || l_proc,40);

 EXCEPTION
   WHEN OTHERS THEN
       hr_utility.set_location(' Leaving with EXCEPTION: '||l_proc,100);
       -- Return cursor that selects no rows
       sqlstr := sqlerrm;
END range_code;

PROCEDURE prg_assignment_action_code(pactid in number,
                           stperson in number,
                           endperson in number,
                           chunk in number) is

l_actid                           NUMBER;
l_canonical_end_date              DATE;
l_end_date                        VARCHAR2(20);
l_business_group_id               NUMBER;
l_consolidation_set               pay_all_payrolls_f.consolidation_set_id%type;
l_proc VARCHAR2(150) := g_package||'.prg_assignment_action_code';
l_arch_action_id number := 0;

--Bug 4557715
CURSOR csr_assact is
select  /*+ ORDERED USE_NL(pp1 asg)
            INDEX(ppa PAY_PAYROLL_ACTIONS_PK)*/ paa.assignment_action_id,
  paa.assignment_id,
  paa.payroll_action_id,
  ppa.date_earned,
  paa_run.tax_unit_id
from  per_assignments_f asg,
      pay_payroll_actions pp1,
      pay_assignment_actions paa,
      pay_payroll_actions ppa,
      pay_action_interlocks pai_pre,
      pay_assignment_actions paa_run,
      pay_payroll_actions   ppa_run,
      pay_all_payrolls_f pap
where   pp1.payroll_action_id = pactid
 and    asg.business_group_id = pp1.business_group_id
 and    asg.person_id between stperson and endperson
 and    asg.assignment_id = paa.assignment_id
 and  paa.source_action_id is null
 and  paa.payroll_action_id = ppa.payroll_action_id
 and  ppa_run.effective_date between asg.effective_start_date and asg.effective_end_date
 and    ppa_run.effective_date between to_date(substr(l_end_date,1,4)||'/01/01','YYYY/MM/DD')
          and to_date(l_end_date,'YYYY/MM/DD')
 and  paa.action_status = 'C'
 and  ppa.action_type = 'X'
 and  ppa.report_type = 'IEPS'
 and  ppa.report_category = 'ARCHIVE'
 and  pai_pre.locking_action_id = paa.assignment_action_id
 and  pai_pre.locked_action_id  = paa_run.assignment_action_id
 and  paa_run.action_status = 'C'
 and  paa_run.payroll_action_id = ppa_run.payroll_action_id
 and  paa_run.source_action_id IS NULL
 and  ppa_run.action_type in ('Q','R')
 and  not exists (select /*+ INDEX(payact PAY_PAYROLL_ACTIONS_PK) */ null
       from pay_action_interlocks alock,
         pay_assignment_actions assact,
         pay_payroll_actions payact
       where alock.locked_action_id = paa.assignment_action_id
      and assact.assignment_action_id = alock.locking_action_id
      and assact.payroll_action_id = payact.payroll_action_id
      and payact.action_type = 'X'
      and payact.report_type = 'IEP30_PRGLOCK'
      and payact.report_category = 'ARCHIVE'
-- 4317512
/* Added to check whether the archiver is locked by a P30 datalock whose effective date is greater than effective date of payroll
   run locked by archiver */
      and to_date(substr(payact.legislative_parameters,instr(payact.legislative_parameters,'END_DATE=')+9,10),'YYYY/MM/DD') >= ppa_run.effective_date)
 --Added for bug fix 3567562, to restrict assignments to the consoliation set selected.
 and asg.payroll_id = pap.payroll_id
 and ppa_run.effective_date between pap.effective_start_date and pap.effective_end_date
 and (pap.consolidation_set_id = l_consolidation_set or l_consolidation_set is null)
 ORDER BY paa.assignment_id,
          paa.assignment_action_id;


BEGIN
   hr_utility.set_location('Entering ' || l_proc,10);
   pay_ie_p30lock.get_all_parameters
  (p_payroll_action_id => pactid,
   p_token => 'END_DATE',
   p_business_group_id => l_business_group_id,
   p_token_value       => l_end_date);

    --Added for bug fix 3567562,to get the consolidation set parameter
    pay_ie_p30lock.get_all_parameters (
    p_payroll_action_id => pactid
  , p_token             => 'CONSOLIDATION'
  , p_business_group_id => l_business_group_id
  , p_token_value       => l_consolidation_set);

   hr_utility.set_location('Step ' || l_proc,20);
   hr_utility.set_location('l_end_date   = ' || l_end_date,20);
   l_canonical_end_date   := TO_DATE(l_end_date,'yyyy/mm/dd');
  FOR csr_rec IN csr_assact
  LOOP
  IF l_arch_action_id <> csr_rec.assignment_action_id THEN
   hr_utility.set_location('inside loop ' || l_proc,12);
   hr_utility.set_location('-----------------------------------------',13);
   hr_utility.set_location('Assignment_action_id ' || csr_rec.assignment_action_id,14);
   hr_utility.set_location('pactid_id ' || pactid,15);
   hr_utility.set_location('Payroll_action_id ' || csr_rec.payroll_action_id,15);
   hr_utility.set_location('-----------------------------------------',17);
    SELECT pay_assignment_actions_s.NEXTVAL
    INTO   l_actid
    FROM   dual;
       hr_nonrun_asact.insact(l_actid,csr_rec.assignment_id,pactid,chunk,csr_rec.tax_unit_id);
       hr_utility.set_location('created pay_ass_act ' || l_actid || ' to ' || pactid,20);
       hr_nonrun_asact.insint(l_actid, csr_rec.assignment_action_id);
       hr_utility.set_location('created interlocks ' || l_actid || ' to ' || csr_rec.assignment_action_id,20);
       l_arch_action_id := csr_rec.assignment_action_id;
  END IF;
  END LOOP;

  hr_utility.set_location('Leaving ' || l_proc,20);

END prg_assignment_action_code;


-- Second Lock Process for p30 Report Lock process

PROCEDURE rep_assignment_action_code(pactid in number,
                           stperson in number,
                           endperson in number,
                           chunk in number) is

l_actid                           NUMBER;
l_canonical_end_date              DATE;
l_pay_action_id                   VARCHAR2(20);
l_business_group_id               NUMBER;
l_proc VARCHAR2(150) := g_package||'.rep_assignment_action_code';


CURSOR csr_assact is
  select  paa.assignment_action_id,
     paa.assignment_id,
     paa.payroll_action_id,
     ppa.date_earned,
     paa.tax_unit_id
  from pay_payroll_actions ppa,
     pay_assignment_actions paa
     -- per_assignments_f asg				-- Bug Fix 4260031
  where   ppa.payroll_action_id = l_pay_action_id
   -- and    asg.business_group_id = ppa.business_group_id	-- Bug Fix 4260031
   -- and    asg.person_id between stperson and endperson
   -- and    asg.assignment_id = paa.assignment_id
   and       paa.source_action_id is null
   and       paa.payroll_action_id = ppa.payroll_action_id
   -- and       ppa.date_earned between asg.effective_start_date and asg.effective_end_date
   and	     paa.assignment_id in (select asg.assignment_id	-- Bug Fix 4260031
				   from per_assignments_f asg
				   where asg.business_group_id = ppa.business_group_id
				   and asg.person_id between stperson and endperson)
   and       ppa.action_status = 'C'
   and       ppa.action_type = 'X'
   and       ppa.report_type = 'IEP30_PRGLOCK'
   and       ppa.report_category = 'ARCHIVE'
   -- bug fix 5371061, added ordered join to remove merge join cartesian.
   and       not exists (select /*+ ORDERED */ null
                         from  pay_payroll_actions payact,
					 pay_assignment_actions assact,
					 pay_action_interlocks alock
		          where   alock.locked_action_id = paa.assignment_action_id
		            and   assact.assignment_action_id = alock.locking_action_id
		            and   assact.payroll_action_id = payact.payroll_action_id
		            and   payact.action_type = 'X'
		            and   payact.report_type = 'IEP30_REPLOCK'
		            and   payact.report_category = 'ARCHIVE')
			   ORDER BY paa.assignment_id;


BEGIN

 hr_utility.set_location('Entering ' || l_proc,10);

  pay_ie_p30lock.get_all_parameters
  (p_payroll_action_id => pactid,
   p_token => 'PAYROLL_ACTION_ID',
   p_business_group_id => l_business_group_id,
   p_token_value       => l_pay_action_id);


  hr_utility.set_location('Step ' || l_proc,20);
  hr_utility.set_location('l_pay_action_id   = ' || l_pay_action_id,20);

  FOR csr_rec IN csr_assact
  LOOP
   hr_utility.set_location('inside loop ' || l_proc,12);
   hr_utility.set_location('-----------------------------------------',13);
   hr_utility.set_location('Assignment_action_id ' || csr_rec.assignment_action_id,14);
   hr_utility.set_location('Pact_id ' || pactid,15);
   hr_utility.set_location('Payroll_action_id ' || csr_rec.payroll_action_id,15);
   hr_utility.set_location('-----------------------------------------',17);
    SELECT pay_assignment_actions_s.NEXTVAL
    INTO   l_actid
    FROM   dual;
       hr_nonrun_asact.insact(l_actid,csr_rec.assignment_id,pactid,chunk,csr_rec.tax_unit_id);
       hr_utility.set_location('created pay_ass_act ' || l_actid || ' to ' || pactid,20);
       hr_nonrun_asact.insint(l_actid, csr_rec.assignment_action_id);
       hr_utility.set_location('created interlocks ' || l_actid || ' to ' || csr_rec.assignment_action_id,20);

  END LOOP;

  hr_utility.set_location('Leaving ' || l_proc,20);

END rep_assignment_action_code;

---------------------------------------------------------------------
-- Procedure generate_xml - Generates P30 XML Output File
---------------------------------------------------------------------
PROCEDURE generate_xml(
           errbuf                   out NOCOPY  varchar2
          ,retcode                  out NOCOPY  varchar2
          ,p_p30_data_lock_process    in number
          ,p_supplementary_run  in varchar2
	    ,p_period_type in varchar2) IS


CURSOR cur_employer_info(
         c_p30_data_lock_process pay_payroll_actions.payroll_action_id%TYPE) IS
  SELECT ppa_p30.payroll_action_id report_id,
         paa_p30.assignment_id assignment_id,
         pact_er.action_information5  employer_paye_number
  FROM   pay_payroll_actions ppa_p30,
         pay_assignment_actions paa_p30,
         pay_action_interlocks pai_p30,
         pay_assignment_actions paa_arc,
         pay_action_interlocks pai_arc,
         pay_assignment_actions paa_prepay,
         pay_action_interlocks pai_prepay,
         pay_action_information pact_er,
         pay_action_information pact_ee
--	 pay_pre_payments ppp                 -- Bug Fix 3725003
  WHERE  ppa_p30.payroll_action_id            = c_p30_data_lock_process
  AND    ppa_p30.payroll_action_id            = paa_p30.payroll_action_id
  AND    paa_p30.assignment_action_id         = pai_p30.locking_action_id
  AND    paa_arc.assignment_action_id         = pai_p30.locked_action_id
  AND    paa_arc.assignment_action_id         = pai_arc.locking_action_id
  AND    paa_prepay.assignment_action_id      = pai_arc.locked_action_id
  AND    paa_prepay.assignment_action_id      = pai_prepay.locking_action_id
  AND    pact_er.action_context_type          = 'PA'
  AND    pact_er.action_information_category  = 'EMEA PAYROLL INFO'
  AND    pact_er.action_context_id            = paa_arc.payroll_action_id
  AND    pact_er.action_information1          = paa_prepay.payroll_action_id
  AND    pact_ee.action_information_category  = 'EMPLOYEE DETAILS'
  AND    pact_ee.action_context_id            = paa_arc.assignment_action_id
  --Added for Bug fix : 3725003
--  AND    ppp.assignment_action_id             = pai_arc.locked_action_id
  GROUP BY ppa_p30.payroll_action_id
          ,paa_p30.assignment_id
          ,pact_er.action_information5
  ORDER BY ppa_p30.payroll_action_id;
  --
  CURSOR  cur_get_archive_pactid(
          c_p30_data_lock_process pay_payroll_actions.payroll_action_id%TYPE) IS
  SELECT  max(ppa_arc.payroll_action_id) archive_pactid
  FROM  pay_assignment_actions paa_p30,
    pay_action_interlocks  pai_p30,
    pay_assignment_actions paa_arc,
    pay_payroll_actions    ppa_arc
  WHERE   paa_p30.payroll_Action_id    = c_p30_data_lock_process
  AND paa_p30.assignment_action_id = pai_p30.locking_action_id
  AND   paa_arc.assignment_action_id = pai_p30.locked_action_id
  AND   ppa_arc.payroll_action_id    = paa_arc.payroll_action_id;
  --
  CURSOR  cur_p30_start_date(
          c_p30_data_lock_process pay_payroll_actions.payroll_action_id%TYPE) IS
  SELECT  to_char(MIN(ppa_arc.start_date),'DD/MM/RRRR') start_date
  FROM  pay_assignment_actions paa_p30,
    pay_action_interlocks  pai_p30,
    pay_assignment_actions paa_arc,
    pay_payroll_actions    ppa_arc
  WHERE   paa_p30.payroll_Action_id    = c_p30_data_lock_process
  AND paa_p30.assignment_action_id = pai_p30.locking_action_id
  AND   paa_arc.assignment_action_id = pai_p30.locked_action_id
  AND   ppa_arc.payroll_action_id    = paa_arc.payroll_action_id;
  --
  CURSOR  cur_employer_address(
          c_payroll_action_id pay_payroll_actions.payroll_action_id%TYPE) IS
  SELECT  substr(pai.action_information5,1,30)  employer_tax_addr1
         ,substr(pai.action_information6,1,30)  employer_tax_addr2
         ,substr(pai.action_information7,1,30)  employer_tax_addr3
         ,substr(pai.action_information26,1,30) employer_tax_contact
         ,substr(pai.action_information27,1,12) employer_tax_ref_phone
         ,substr(pai.action_information28,1,30) employer_tax_rep_name
  FROM    pay_action_information pai
  WHERE   pai.action_context_id    =  c_payroll_action_id
  AND   pai.action_context_type    = 'PA'
  AND   pai.action_information_category  = 'ADDRESS DETAILS'
  AND   pai.action_information14   = 'IE Employer Tax Address';
  --
  -- 4317512
  /* YTD_Balances fill fetch that balance value whose source ids effective date is less than effective date
     of P30 datalock */
  CURSOR YTD_Balances (vp_Payroll_Action_Id Pay_Payroll_Actions.Payroll_Action_ID%TYPE,
                       vp_Assignment_Id     Pay_Assignment_Actions.Assignment_Action_ID%TYPE,
                       vp_Balance_Name      Pay_Balance_Types.Balance_Name%TYPE,
                       vp_Dimension_Name    varchar2,
		       vp_action_context_id number,
                       vp_effective_date    date)IS     -- SR 17318286.6 rbhardwa
  SELECT pact_ytdbal.action_information4 Balance_Value
  FROM   pay_assignment_actions paa_p30,
         pay_action_interlocks pai_p30,
         pay_assignment_actions paa_arc,
         pay_action_information pact_ytdbal,
         pay_defined_balances pdb_ytdbal,
         pay_balance_types pbt_ytdbal,
         pay_balance_dimensions pbd_ytdbal,
         pay_assignment_actions paa_src,
         pay_payroll_actions  ppa_src
  WHERE  paa_p30.payroll_action_id              = vp_Payroll_Action_Id
  AND    paa_p30.assignment_id                  = vp_Assignment_Id
  AND    paa_p30.assignment_action_id           = pai_p30.locking_action_id
  AND    paa_arc.assignment_action_id           = pai_p30.locked_action_id
  AND    pact_ytdbal.action_information_category= 'EMEA BALANCES'
  AND 	 pact_ytdbal.ACTION_CONTEXT_ID 		= vp_action_context_id --SR 17318286.6 rbhardwa
  AND    pact_ytdbal.ACTION_CONTEXT_ID          = paa_arc.assignment_action_id
  AND    pact_ytdbal.ACTION_CONTEXT_TYPE        = 'AAP'
  AND    pdb_ytdbal.defined_balance_id          = pact_ytdbal.action_information1
  AND    pdb_ytdbal.balance_type_id             = pbt_ytdbal.balance_type_id
  AND    pbt_ytdbal.balance_name                = vp_Balance_Name
  AND    pbd_ytdbal.dimension_name              = vp_Dimension_Name
  AND    pbd_ytdbal.balance_dimension_id        = pdb_ytdbal.balance_dimension_id
  AND    pbt_ytdbal.legislation_code            = 'IE'
  AND    pact_ytdbal.action_context_type        = 'AAP'
  AND    paa_src.assignment_action_id           = pact_ytdbal.source_id
  AND    paa_src.payroll_action_id              = ppa_src.payroll_action_id
  AND    ppa_src.effective_date                <= vp_effective_date
  ORDER  BY  pact_ytdbal.effective_date DESC         	-- Fix Tar 4033038.994
            ,pact_ytdbal.ACTION_CONTEXT_ID DESC
            ,nvl(pact_ytdbal.action_information5,0) DESC;
  --
  CURSOR cur_get_prev_p30_lock_id (vp_payroll_action_id pay_payroll_actions.payroll_action_id%TYPE
                                  ,vp_assignment_id     pay_assignment_actions.assignment_action_id%TYPE
                                  ,vp_tax_start_date    date
                                  ,vp_report_end_date   date) IS
  SELECT ppa.payroll_action_id prev_data_lock_id,
         to_date(substr(ppa.legislative_parameters,instr(ppa.legislative_parameters,'END_DATE=')+9,10),'YYYY/MM/DD')
  FROM   pay_payroll_actions      ppa
        ,pay_assignment_actions   paa
  WHERE  ppa.payroll_action_id    = paa.payroll_action_id
  AND    ppa.report_type          = 'IEP30_PRGLOCK'
  AND    paa.assignment_id        = vp_assignment_id
  AND    paa.assignment_action_id = (
         SELECT to_number(substr(max(lpad(paa2.action_sequence,15,'0')||
                 paa2.assignment_action_id),16))--Bug No 3318509
         FROM   pay_payroll_actions     ppa2
               ,pay_assignment_actions  paa2
         WHERE  ppa2.payroll_action_id  = paa2.payroll_action_id
         AND    ppa2.report_type        = 'IEP30_PRGLOCK'
         AND    paa2.assignment_id      = vp_assignment_id
         AND    ppa2.payroll_action_id  <> vp_payroll_action_id
         AND    to_date(substr(ppa2.legislative_parameters ,instr(ppa2.legislative_parameters,'END_DATE=')+9,10),'YYYY/MM/DD')
         BETWEEN vp_tax_start_date   AND   vp_report_end_date)
  ORDER  BY ppa.payroll_action_id DESC;

  -- Report End Date
  CURSOR cur_end_date(vp_payroll_action_id pay_payroll_actions.payroll_action_id%TYPE) IS
  SELECT to_date(substr(ppa_p30.legislative_parameters,instr(ppa_p30.legislative_parameters,'END_DATE=')+9,10),'YYYY/MM/DD') end_date
  FROM   pay_payroll_actions ppa_p30
  WHERE  ppa_p30.payroll_action_id=vp_payroll_action_id;

  -- Start date of Tax Year
  CURSOR cur_get_start_date (vp_report_end_date date) IS
  SELECT to_date(rule_mode || '/' || to_char(vp_report_end_date,'YYYY'),'dd/mm/yyyy')
  FROM   pay_legislation_rules
  WHERE  legislation_code   = 'IE'
  AND    rule_type          = 'L';

/* SR 17318286.6 rbhardwa changes start here */
  --Bug Fix 4032212 This cursor is added to get the max action_context_id against the P30 Data Lock id
  -- Changed to fetch correct action context if Archiver is run for Period 2 first and then for period1
  CURSOR get_action_context (vp_Payroll_Action_Id Pay_Payroll_Actions.Payroll_Action_ID%TYPE,
  		       vp_Assignment_Id     Pay_Assignment_Actions.Assignment_Action_ID%TYPE) IS
  SELECT fnd_number.canonical_to_number(substr(max(lpad(paa_run.action_sequence,15,'0')||pact_ytdbal.ACTION_CONTEXT_ID),16))
  FROM   pay_assignment_actions paa_p30,
	 pay_action_interlocks pai_p30,
	 pay_assignment_actions paa_arc,
	 pay_action_information pact_ytdbal,
	 pay_action_interlocks pai_arc,
	 pay_assignment_actions paa_run,
	 pay_payroll_actions ppa_run
--	,pay_pre_payments ppp  			--Bug Fix 4049831 Added join with pay_pre_payments table
  WHERE  paa_p30.payroll_action_id					= vp_Payroll_Action_Id
  AND 	 paa_p30.assignment_id						= vp_Assignment_Id
  AND 	 paa_p30.assignment_action_id 					= pai_p30.locking_action_id
  AND 	 paa_arc.assignment_action_id 					= pai_p30.locked_action_id
  AND    paa_arc.assignment_action_id                   		= pai_arc.locking_action_id
  AND 	 pact_ytdbal.ACTION_CONTEXT_ID 					= paa_arc.assignment_action_id
  AND    paa_run.assignment_action_id                       		= pai_arc.locked_action_id
  AND 	 pact_ytdbal.action_context_type 				= 'AAP'
  AND    paa_run.source_action_id IS NULL
  AND    paa_run.payroll_action_id                                      = ppa_run.payroll_action_id
  AND    ppa_run.action_type in ('R','Q');

/* SR 17318286.6 rbhardwa changes end here */

  v_prev_data_lock_id number;
  v_pre_date_eff_date date;
  v_cur_employer_info cur_employer_info%ROWTYPE;
  v_Curr_YTD_Balances YTD_Balances%ROWTYPE;
  v_Prev_YTD_Balances YTD_Balances%ROWTYPE;

  v_action_context_id Number(15,0); --SR 17318286.6 rbhardwa

  --
  l_report_end_date date;
  l_tax_start_date  date;
  --
  l_PAYE_PTD     number:=0;
  l_EE_PRSI_PTD  number:=0;
  l_ER_PRSI_PTD  number:=0;
  --
  l_PAYE_YTD     number:=0;
  l_EE_PRSI_YTD  number:=0;
  l_ER_PRSI_YTD  number:=0;
  --
  l_root_start_tag  varchar2(200);
  l_root_end_tag    varchar2(50);
  --
  l_employer_start_tag  varchar2(20);
  l_employer_end_tag  varchar2(20);
  --
  l_p30_start_tag   varchar2(20);
  l_p30_end_tag     varchar2(20);
  --
  l_archive_pactid        pay_payroll_actions.payroll_action_id%TYPE;
  --
  l_employer_paye_number  varchar2(80);
  l_employer_number varchar2(10);
  l_employer_name   varchar2(30);
  l_employer_add1   varchar2(30);
  l_employer_add2   varchar2(30);
  l_employer_add3   varchar2(30);
  l_employer_contact  varchar2(20);
  l_employer_phone  varchar2(12);
  --
  l_p30_start   varchar2(10);
  l_p30_paye    number:=0;
  l_p30_prsi    number:=0;
  l_p30_type    varchar2(1);
  l_period_type varchar2(1); -- For bug 5119350

BEGIN

  l_root_start_tag  :='<P30File currency="E" formversion="1" language="E">';
  l_root_end_tag  :='</P30File>';

  l_employer_start_tag  :=' <Employer ';
  l_employer_end_tag  :=' />';

  l_p30_start_tag :=' <P30 ';
  l_p30_end_tag   :=' />';

  -- Get payroll_action_id of the legislative archive process
  OPEN cur_get_archive_pactid(p_p30_data_lock_process);
        FETCH cur_get_archive_pactid INTO l_archive_pactid;
  CLOSE cur_get_archive_pactid;

  -- Get Employer Address
  OPEN cur_employer_address(l_archive_pactid);
      FETCH cur_employer_address INTO l_employer_add1
                     ,l_employer_add2
                     ,l_employer_add3
                   ,l_employer_contact
                     ,l_employer_phone
                     ,l_employer_name;
  CLOSE cur_employer_address;



  -- Start of xml doc
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<?xml version="1.0" encoding="UTF-8"?>');

  -- P30File root ELEMENT
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_root_start_tag);

  -- Bug 2659864 - 'This Report' Figure calculation logic  changed to
  -- (Curr P30  YTD value  - Prev P30 YTD Value)

  -- Report End Date
  OPEN cur_end_date(p_p30_data_lock_process);
    FETCH cur_end_date INTO l_report_end_date;
  CLOSE cur_end_date;

  -- Get Tax Year Start Date
  OPEN cur_get_start_date(l_report_end_date);
    FETCH cur_get_start_date INTO l_tax_start_date;
  CLOSE cur_get_start_date;

  FOR v_cur_employer_info IN cur_employer_info(p_p30_data_lock_process) LOOP
      l_employer_paye_number := v_cur_employer_info.employer_paye_number;
      --
      	-- SR 17318286.6 rbhardwa changes start here
	OPEN get_action_context(v_cur_employer_info.report_id,v_cur_employer_info.assignment_id);
	FETCH get_action_context INTO v_action_context_id;
        CLOSE get_action_context;
      	-- SR 17318286.6 rbhardwa changes end here

      --Fetch Curr PAYE YTD Balance from PAY ACTION INFORMATION
      OPEN YTD_Balances(v_cur_employer_info.report_id
                       ,v_cur_employer_info.assignment_id
                       ,'IE Net Tax'
                       ,'_ASG_YTD'
		       ,v_action_context_id
                       ,l_report_end_date);
      FETCH YTD_Balances INTO v_Curr_YTD_Balances;
      CLOSE YTD_Balances;
      l_PAYE_YTD := NVL(v_Curr_YTD_Balances.Balance_Value,0);
      v_Curr_YTD_Balances.Balance_Value := NULL;
      --Fetch Curr EE PRSI YTD Balance from PAY ACTION INFORMATION
      OPEN YTD_Balances(v_cur_employer_info.report_id
                       ,v_cur_employer_info.assignment_id
                       ,'IE PRSI Employee'
                       ,'_ASG_YTD'
		       ,v_action_context_id
                       ,l_report_end_date);
      FETCH YTD_Balances INTO v_Curr_YTD_Balances;
      CLOSE YTD_Balances;
      l_EE_PRSI_YTD := NVL(v_Curr_YTD_Balances.Balance_Value,0);
      v_Curr_YTD_Balances.Balance_Value := NULL;
-- Bug 3436737 : Added code to sum up K and M figures for a severance
-- payment
      OPEN YTD_Balances(v_cur_employer_info.report_id
                       ,v_cur_employer_info.assignment_id
                       ,'IE PRSI K Employee Lump Sum'
                       ,'_ASG_YTD'
		       ,v_action_context_id
                       ,l_report_end_date);
      FETCH YTD_Balances INTO v_Curr_YTD_Balances;
      CLOSE YTD_Balances;
      l_EE_PRSI_YTD := l_EE_PRSI_YTD + NVL(v_Curr_YTD_Balances.Balance_Value,0);
      v_Curr_YTD_Balances.Balance_Value := NULL;
      OPEN YTD_Balances(v_cur_employer_info.report_id
                       ,v_cur_employer_info.assignment_id
                       ,'IE PRSI M Employee Lump Sum'
                       ,'_ASG_YTD'
		       ,v_action_context_id
                       ,l_report_end_date);
      FETCH YTD_Balances INTO v_Curr_YTD_Balances;
      CLOSE YTD_Balances;
      l_EE_PRSI_YTD := l_EE_PRSI_YTD + NVL(v_Curr_YTD_Balances.Balance_Value,0);
      v_Curr_YTD_Balances.Balance_Value := NULL;
-- Total PRSI Employee figure has been evaluated above
      --Fetch Curr ER PRSI YTD Balance from PAY ACTION INFORMATION
      OPEN YTD_Balances(v_cur_employer_info.report_id
                       ,v_cur_employer_info.assignment_id
                       ,'IE PRSI Employer'
                       ,'_ASG_YTD'
		       ,v_action_context_id
                       ,l_report_end_date);
      FETCH YTD_Balances INTO v_Curr_YTD_Balances;
      CLOSE YTD_Balances;
      l_ER_PRSI_YTD := NVL(v_Curr_YTD_Balances.Balance_Value,0);
      v_Curr_YTD_Balances.Balance_Value := NULL;
      OPEN YTD_Balances(v_cur_employer_info.report_id
                       ,v_cur_employer_info.assignment_id
                       ,'IE PRSI K Employer Lump Sum'
                       ,'_ASG_YTD'
		       ,v_action_context_id
                       ,l_report_end_date);
      FETCH YTD_Balances INTO v_Curr_YTD_Balances;
      CLOSE YTD_Balances;
      l_ER_PRSI_YTD := l_ER_PRSI_YTD + NVL(v_Curr_YTD_Balances.Balance_Value,0);
      v_Curr_YTD_Balances.Balance_Value := NULL;
      OPEN YTD_Balances(v_cur_employer_info.report_id
                       ,v_cur_employer_info.assignment_id
                       ,'IE PRSI M Employer Lump Sum'
                       ,'_ASG_YTD'
		       ,v_action_context_id
                       ,l_report_end_date);
      FETCH YTD_Balances INTO v_Curr_YTD_Balances;
      CLOSE YTD_Balances;
      l_ER_PRSI_YTD := l_ER_PRSI_YTD + NVL(v_Curr_YTD_Balances.Balance_Value,0);
      v_Curr_YTD_Balances.Balance_Value := NULL;


   /* 7691477 */


      OPEN YTD_Balances(v_cur_employer_info.report_id
                       ,v_cur_employer_info.assignment_id
                       ,'IE Income Tax Levy'
                       ,'_ASG_YTD'
		       ,v_action_context_id
                       ,l_report_end_date);
      FETCH YTD_Balances INTO v_Curr_YTD_Balances;
      CLOSE YTD_Balances;

      l_PAYE_YTD :=l_PAYE_YTD +  NVL(v_Curr_YTD_Balances.Balance_Value,0);
      v_Curr_YTD_Balances.Balance_Value := NULL;



      OPEN YTD_Balances(v_cur_employer_info.report_id
                       ,v_cur_employer_info.assignment_id
                       ,'IE Parking Levy'
                       ,'_ASG_YTD'
		       ,v_action_context_id
                       ,l_report_end_date);
      FETCH YTD_Balances INTO v_Curr_YTD_Balances;
      CLOSE YTD_Balances;
      l_EE_PRSI_YTD := l_EE_PRSI_YTD + NVL(v_Curr_YTD_Balances.Balance_Value,0);
      v_Curr_YTD_Balances.Balance_Value := NULL;


-- Total PRSI Employer figure has been evaluated above
      -- Fetch PAYE/PRSI  'This Report' values
      -- The 'This Report' value are calculated as (Current P30s YTD values - Previous P30s YTD values)
      OPEN cur_get_prev_p30_lock_id(v_cur_employer_info.report_id
                                   ,v_cur_employer_info.assignment_id
                                   ,l_tax_start_date
                                   ,l_report_end_date);
        FETCH cur_get_prev_p30_lock_id INTO v_prev_data_lock_id,v_pre_date_eff_date;
          IF cur_get_prev_p30_lock_id%NOTFOUND THEN
            v_prev_data_lock_id :=NULL;
            v_pre_date_eff_date := NULL;
            l_PAYE_PTD     := l_PAYE_YTD;
            l_EE_PRSI_PTD  := l_EE_PRSI_YTD;
            l_ER_PRSI_PTD  := l_ER_PRSI_YTD;
          ELSE

	--  SR 17318286.6 rbhardwa changes start here
            OPEN get_action_context(v_prev_data_lock_id,v_cur_employer_info.assignment_id);
            FETCH get_action_context INTO v_action_context_id;
	    CLOSE get_action_context;
	--  SR 17318286.6 rbhardwa changes end here


            --Fetch Prev PAYE YTD Balance from PAY ACTION INFORMATION of Prev P30 Run
            OPEN YTD_Balances(v_prev_data_lock_id,v_cur_employer_info.assignment_id,'IE Net Tax','_ASG_YTD',v_action_context_id,v_pre_date_eff_date);
            FETCH YTD_Balances INTO v_Prev_YTD_Balances;
            CLOSE YTD_Balances;
            l_PAYE_PTD := l_PAYE_YTD - NVL(v_Prev_YTD_Balances.Balance_Value,0);
            v_Prev_YTD_Balances.Balance_Value := NULL;

            --Fetch Prev EE PRSI YTD Balance from PAY ACTION INFORMATION of Prev P30 Run
            OPEN YTD_Balances(v_prev_data_lock_id,v_cur_employer_info.assignment_id,'IE PRSI Employee','_ASG_YTD',v_action_context_id,v_pre_date_eff_date);
            FETCH YTD_Balances INTO v_Prev_YTD_Balances;
            CLOSE YTD_Balances;
            l_EE_PRSI_PTD := l_EE_PRSI_YTD - NVL(v_Prev_YTD_Balances.Balance_Value,0);
            v_Prev_YTD_Balances.Balance_Value := NULL;

-- Bug 3436737 : Added code to sum up K and M Employee figures for a severance
-- payment
            OPEN YTD_Balances(v_prev_data_lock_id,v_cur_employer_info.assignment_id,'IE PRSI K Employee Lump Sum','_ASG_YTD',v_action_context_id,v_pre_date_eff_date);
            FETCH YTD_Balances INTO v_Prev_YTD_Balances;
            CLOSE YTD_Balances;
            l_EE_PRSI_PTD := l_EE_PRSI_PTD - NVL(v_Prev_YTD_Balances.Balance_Value,0);
            v_Prev_YTD_Balances.Balance_Value := NULL;

            OPEN YTD_Balances(v_prev_data_lock_id,v_cur_employer_info.assignment_id,'IE PRSI M Employee Lump Sum','_ASG_YTD',v_action_context_id,v_pre_date_eff_date);
            FETCH YTD_Balances INTO v_Prev_YTD_Balances;
            CLOSE YTD_Balances;
            l_EE_PRSI_PTD := l_EE_PRSI_PTD - NVL(v_Prev_YTD_Balances.Balance_Value,0);
            v_Prev_YTD_Balances.Balance_Value := NULL;

            --Fetch Prev ER PRSI YTD Balance from PAY ACTION INFORMATION of Prev P30
            OPEN YTD_Balances(v_prev_data_lock_id,v_cur_employer_info.assignment_id,'IE PRSI Employer','_ASG_YTD',v_action_context_id,v_pre_date_eff_date);
            FETCH YTD_Balances INTO v_Prev_YTD_Balances;
            CLOSE YTD_Balances;
            l_ER_PRSI_PTD := l_ER_PRSI_YTD - NVL(v_Prev_YTD_Balances.Balance_Value,0);
            v_Prev_YTD_Balances.Balance_Value := NULL;

-- Added code to sum up K and M Employer figures for a severance payment
            OPEN YTD_Balances(v_prev_data_lock_id,v_cur_employer_info.assignment_id,'IE PRSI K Employer Lump Sum','_ASG_YTD',v_action_context_id,v_pre_date_eff_date);
            FETCH YTD_Balances INTO v_Prev_YTD_Balances;
            CLOSE YTD_Balances;
            l_ER_PRSI_PTD := l_ER_PRSI_PTD - NVL(v_Prev_YTD_Balances.Balance_Value,0);
            v_Prev_YTD_Balances.Balance_Value := NULL;

            OPEN YTD_Balances(v_prev_data_lock_id,v_cur_employer_info.assignment_id,'IE PRSI M Employer Lump Sum','_ASG_YTD',v_action_context_id,v_pre_date_eff_date);
            FETCH YTD_Balances INTO v_Prev_YTD_Balances;
            CLOSE YTD_Balances;
            l_ER_PRSI_PTD := l_ER_PRSI_PTD - NVL(v_Prev_YTD_Balances.Balance_Value,0);
            v_Prev_YTD_Balances.Balance_Value := NULL;

	    /* 7691477 */


            OPEN YTD_Balances(v_prev_data_lock_id,v_cur_employer_info.assignment_id,'IE Income Tax Levy','_ASG_YTD',v_action_context_id,v_pre_date_eff_date);
            FETCH YTD_Balances INTO v_Prev_YTD_Balances;
            CLOSE YTD_Balances;
            l_PAYE_PTD := l_PAYE_PTD - NVL(v_Prev_YTD_Balances.Balance_Value,0);
            v_Prev_YTD_Balances.Balance_Value := NULL;



            OPEN YTD_Balances(v_prev_data_lock_id,v_cur_employer_info.assignment_id,'IE Parking Levy','_ASG_YTD',v_action_context_id,v_pre_date_eff_date);
            FETCH YTD_Balances INTO v_Prev_YTD_Balances;
            CLOSE YTD_Balances;
            l_EE_PRSI_PTD := l_EE_PRSI_PTD - NVL(v_Prev_YTD_Balances.Balance_Value,0);
            v_Prev_YTD_Balances.Balance_Value := NULL;


          END IF;
        CLOSE cur_get_prev_p30_lock_id;
      l_p30_paye := l_p30_paye  + NVL(l_PAYE_PTD,0);
      l_p30_prsi := l_p30_prsi  + NVL(l_EE_PRSI_PTD,0) + NVL(l_ER_PRSI_PTD,0);

  END LOOP;

  -- Employer ELEMENT
  FND_FILE.PUT(FND_FILE.OUTPUT,l_employer_start_tag);

  FND_FILE.PUT(FND_FILE.OUTPUT,'number="' || l_employer_paye_number ||'" ');
  FND_FILE.PUT(FND_FILE.OUTPUT,'name="' || l_employer_name ||'" ');

  IF l_employer_add1 IS NOT NULL THEN
  FND_FILE.PUT(FND_FILE.OUTPUT,'address1="' || l_employer_add1    ||'" ');
  END IF;

  IF l_employer_add2 IS NOT NULL THEN
  FND_FILE.PUT(FND_FILE.OUTPUT,'address2="' || l_employer_add2    ||'" ');
  END IF;

  IF l_employer_add3 IS NOT NULL THEN
  FND_FILE.PUT(FND_FILE.OUTPUT,'address3="' || l_employer_add3    ||'" ');
  END IF;

  FND_FILE.PUT(FND_FILE.OUTPUT,'contact="'  || l_employer_contact ||'" ');

  IF l_employer_phone IS NOT NULL THEN
  FND_FILE.PUT(FND_FILE.OUTPUT,'phone="'    || replace(replace(l_employer_phone,'('),')')   ||'" ');
  END IF;



  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_employer_end_tag);

  -- P30 ELEMENT
  FND_FILE.PUT(FND_FILE.OUTPUT,l_p30_start_tag);

  -- Get Start Date
  OPEN cur_p30_start_date(p_p30_data_lock_process);
      FETCH cur_p30_start_date INTO l_p30_start;
  CLOSE cur_p30_start_date;

  IF p_supplementary_run = 'Y' THEN
    l_p30_type := '1';
  ELSE
    l_p30_type := '0';
  END IF;
-- For bug 5119350, checks if period type is monthly set it to 0 else 1.
  IF p_period_type='M' then
	l_period_type := '0';
  ELSE
	l_period_type := '1';
  END IF;

    FND_FILE.PUT(FND_FILE.OUTPUT,'period="' || l_period_type ||'" ');
-- End bug 5119350
    FND_FILE.PUT(FND_FILE.OUTPUT,'start="' || l_p30_start ||'" ');

     /* Bug 2502060 P30 XML FAILED REVENUE ON LINE VALIDATION
       Change in requirement- Totals in PAYE and PRSI element to display
       in whole Euros and with no ',' seperating the thousands.

       FND_FILE.PUT(FND_FILE.OUTPUT,'PAYE="'  || to_char(l_p30_paye,'FM999G999G999')  ||'" ');
       FND_FILE.PUT(FND_FILE.OUTPUT,'PRSI="'  || to_char(l_p30_prsi,'FM999G999G999')  ||'" ');

    */

    FND_FILE.PUT(FND_FILE.OUTPUT,'PAYE="'  || to_char(l_p30_paye,'FM999999999')  ||'" ');
    FND_FILE.PUT(FND_FILE.OUTPUT,'PRSI="'  || to_char(l_p30_prsi,'FM999999999')  ||'" ');
    FND_FILE.PUT(FND_FILE.OUTPUT,'type="'  || l_p30_type  ||'" ');

  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_p30_end_tag);

  -- End of ROOT P30File ELEMENT
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_root_end_tag);

END generate_xml;

END;

/
