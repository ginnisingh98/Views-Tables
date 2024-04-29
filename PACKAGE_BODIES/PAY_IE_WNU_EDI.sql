--------------------------------------------------------
--  DDL for Package Body PAY_IE_WNU_EDI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_IE_WNU_EDI" as
/* $Header: pyiewnue.pkb 120.0 2005/05/29 05:48:24 appldev noship $ */
--
-- Globals
g_package    CONSTANT VARCHAR2(20):= 'PAY_IE_WNU_EDI.';
--
 /* Procedure wnu_update_extra_info calls apis to insert/update records in
 PER_EXTRA_ASSIGNMENT_INFO */
 --
PROCEDURE wnu_update_extra_info
  (p_assignment_id               in    number,
   p_effective_date              in    date,
   p_include_in_wnu              in    varchar2 default null
  ) IS
--
l_ass_extra_info_id      number(9):= null;
l_ass_extra_info_id_out  number(9);
l_proc                   varchar2(72) := 'wnu_update_extra_info';
l_current_employee       varchar2(30) := null;
l_assignment_id          number(15):= null;
l_include_in_wnu         varchar2(30);
l_ovn_out                number(15);
l_ovn                    number(15);
--
cursor csr_employee is
       select upper(apf.current_employee_flag)
       from   per_all_people_f apf,
              per_all_assignments_f aaf
       where  aaf.person_id = apf.person_id
       and    aaf.assignment_id = p_assignment_id
       and    p_effective_date between
              apf.effective_start_date and apf.effective_end_date
       and    p_effective_date between
              aaf.effective_start_date and aaf.effective_end_date;
--
cursor csr_extra_info is
       select aei.assignment_extra_info_id ,
              object_version_number
       from   per_assignment_extra_info aei
       where  aei.assignment_id = p_assignment_id
       and    information_type = 'IE_WNU';
--
begin
--
hr_utility.set_location('Entering:'|| g_package||l_proc, 10);
--
-- Assign Variables
--
l_assignment_id :=   p_assignment_id;
l_include_in_wnu :=  p_include_in_wnu;
--
-- check for updation of records
--
-- Will only update Current Employee Records
--
  open csr_employee;
  fetch csr_employee into l_current_employee ;
  close csr_employee;
--
  if l_current_employee = 'Y' then
--
    --
         -- check to see if assignment extra info
         -- exists for this assignemnt_id
         --
         open csr_extra_info;
         fetch csr_extra_info into l_ass_extra_info_id, l_ovn;
         if csr_extra_info%notfound then
           --
           hr_utility.set_location(l_proc, 20);
           --
           --
           if l_include_in_wnu = 'Y' THEN
           -- Create an entry for WNU only when flag is set to Yes
           -- Check included so that unnecessary records with flag No aren't created when running in FULL Mode
           --
            hr_utility.set_location(l_proc, 30);
           hr_assignment_extra_info_api.create_assignment_extra_info
            (p_validate                       => false,
             p_assignment_id                  => l_assignment_id,
             p_information_type               => 'IE_WNU',
             p_aei_information_category       => 'IE_WNU',
             p_aei_information1               => l_include_in_wnu,
             p_object_version_number          => l_ovn_out,
             p_assignment_extra_info_id       => l_ass_extra_info_id_out
            );
             hr_utility.trace('Created flag');
             hr_utility.set_location(l_proc, 40);
             end if;

            close csr_extra_info;

          else
             --
             hr_utility.set_location(l_proc, 30);
             --
             -- Update Existing Entry for WNU
             --
             hr_assignment_extra_info_api.update_assignment_extra_info
            (p_validate                       => false,
             p_object_version_number          => l_ovn,
             p_assignment_extra_info_id       => l_ass_extra_info_id,
             p_aei_information_category       => 'IE_WNU',
             p_aei_information1               => l_include_in_wnu
            );
            hr_utility.trace('Updated flag');
            --
            close csr_extra_info;
         --
           end if ; -- Extra Info cursor
         --
     --
     end if; -- Current Employee
     --
--
hr_utility.set_location('Leaving:'|| l_proc, 100);
--
end wnu_update_extra_info;
--
--

--
PROCEDURE range_cursor (pactid IN NUMBER,
                        sqlstr OUT nocopy VARCHAR2)
IS
  l_proc             CONSTANT VARCHAR2(60):= g_package||'range_cursor';
BEGIN
  --
  hr_utility.set_location('Entering: '||l_proc,1);
  --
  -- Note: There must be one and only one entry of :payroll_action_id in
  -- the string, and the statement must be, order by person_id
  --
  sqlstr := 'select distinct person_id '||
            'from per_people_f ppf, '||
            'pay_payroll_actions ppa '||
            'where ppa.payroll_action_id = :payroll_action_id '||
            'and ppa.business_group_id = ppf.business_group_id '||
            'order by ppf.person_id';
  --
  hr_utility.set_location(' Leaving: '||l_proc,100);
END range_cursor;
--
/* PROCEDURE wnu_full_action_creation:
This PROC creates assignment actions when running the process in FULL Mode  */
--
Procedure wnu_full_action_creation (pactid    in number,
                                 stperson  in number,
                                 endperson in number,
                                 chunk     in number)
IS
--
-- Bug Number : 4369280
-- commented hr_organization_information as the new legal employer classification is now
-- attached because of which we dont need the tax reference and the paye reference rather
-- we pass the employee reference. This change comes in effect due to a new legal employer
-- classification being used.

cursor csr_state(p_payroll_id NUMBER,  p_emp_ref VARCHAR2,  p_assignment_set_id NUMBER) IS
        select   asg.assignment_id assignment_id,
                 ppa.effective_date effective_date
            from     per_all_assignments_f asg,
                     pay_payroll_actions ppa,
                     per_all_people_f pap,
                     per_periods_of_service serv,
            --         hr_organization_information hoi,
                     pay_all_payrolls_f pay,
                     hr_soft_coding_keyflex sck
            where    ppa.payroll_action_id = pactid
            --and      hoi.organization_id = ppa.business_group_id
            and      sck.segment4 = p_emp_ref
            and      asg.business_group_id = ppa.business_group_id
            and      asg.PRIMARY_FLAG = 'Y'
            and      asg.payroll_id = pay.payroll_id
            and      pay.soft_coding_keyflex_id = sck.soft_coding_keyflex_id
            --and      upper(p_tax_ref) = upper(sck.segment1)
	    -- For bug Fix 3567562 added condition to filter records based on PAYE Reference specified as parameter.
	    --and      upper(sck.segment3) = upper(hoi.org_information2)
	    --and      upper(p_paye_ref)  =  upper(sck.segment3)
            --and      upper(sck.segment1) = upper(hoi.org_information1)
            and      pay.payroll_id = NVL(p_payroll_id,pay.payroll_id)
            and     (p_assignment_set_id is null
                        OR exists
                           ( select 1
                            from HR_ASSIGNMENT_SET_AMENDMENTS amend,
                                 hr_assignment_sets           aset
 where
 ( P_ASSIGNMENT_SET_ID IS NOT NULL and
aset.assignment_set_id =  P_ASSIGNMENT_SET_ID
-- Bug2856413 To handle payroll in Assgt sets
and nvl(aset.payroll_id,pay.payroll_id) = pay.payroll_id
and amend.assignment_set_id(+)= aset.assignment_set_id
and
(
(amend.include_or_exclude is not null AND
((amend.include_or_exclude='I' and amend.assignment_id  = asg.assignment_id)
OR
(amend.include_or_exclude='E' and amend.assignment_id  <> asg.assignment_id)))
 OR
 amend.include_or_exclude is null)
)
)
)
            and     asg.person_id = pap.person_id
            and     serv.person_id = pap.person_id
            and     serv.period_of_service_id = asg.period_of_service_id
            and     serv.date_start = (select max(s.date_start)
                           from   per_periods_of_service s
                                 where  s.person_id = pap.person_id
                                 and    ppa.effective_date >= s.date_start)
            and      pap.current_employee_flag = 'Y'
            and      asg.person_id between
                     stperson and endperson
            and     ppa.effective_date between
                    asg.effective_start_date and asg.effective_end_date
            and    ppa.effective_date between
                    pap.effective_start_date and pap.effective_end_date
            and     ppa.effective_date between
                    pay.effective_start_date and pay.effective_end_date
            order by asg.assignment_id;
--

--
lockingactid             number;
l_proc                   CONSTANT VARCHAR2(60):= g_package||'wnu_full_action_creation';
l_payroll_id             number(15):= null;
--l_tax_ref                varchar2(20):=null;
l_assignment_set_id      number(15) :=null;
l_stored_asg_id          NUMBER;
l_effective_date        date;
--Added for bug fix 3567562
--l_paye_ref               varchar2(20):=null;
l_emp_ref               varchar2(20):=null;
--
begin
--
  hr_utility.set_location('Entering: '||l_proc,1);
--

-- get parameter values from legislative parameters
l_payroll_id             := to_number(PAY_IE_ARCHIVE_DETAIL_PKG.get_parameter(pactid,'PAYROLL_ID'));
--l_tax_ref                := substr(trim(PAY_IE_ARCHIVE_DETAIL_PKG.get_parameter(pactid,'TAX_REF')),1,20);
l_assignment_set_id      := to_number(PAY_IE_ARCHIVE_DETAIL_PKG.get_parameter(pactid,'ASSIGNMENT_SET_ID')) ;
--Added for bug fix 3567562
--l_paye_ref               := substr(trim(PAY_IE_ARCHIVE_DETAIL_PKG.get_parameter(pactid,'PAYE_REF')),1,20);


--Bug 4369280
--commented the tax reference and the paye reference parameters as in the new legal employer
--classification they are not needed
--rather a new parameter is used for the legal employer reference .

l_emp_ref               := substr(trim(PAY_IE_ARCHIVE_DETAIL_PKG.get_parameter(pactid,'EMP_REF')),1,20);
--
  BEGIN

   for asgrec in csr_state(l_payroll_id, l_emp_ref, l_assignment_set_id) loop
       --
          hr_utility.set_location(l_proc,10);
          --
          --
            l_stored_asg_id := asgrec.assignment_id;
            l_effective_date := asgrec.effective_date;
          --
          -- Create the assignment_action
             --
             select pay_assignment_actions_s.nextval
             into   lockingactid
             from   dual;
             --
             -- insert into pay_assignment_actions.
             hr_utility.trace('Storing Asg: '|| to_char(l_stored_asg_id));
             --
             hr_nonrun_asact.insact(lockingactid=>      lockingactid,
                                    assignid =>l_stored_asg_id,
                                    pactid => pactid,
                                    chunk => chunk,
                                    greid =>null);

             --
              hr_utility.set_location(l_proc,20);
              --
              -- Update flag set in PER_ASSIGNMENT_EXTRA_INFO for this assignment
                hr_utility.trace('Updating AEI flag, for asg:'||to_char(l_stored_asg_id));
                PAY_IE_WNU_EDI.wnu_update_extra_info
                  (p_assignment_id                => asgrec.assignment_id,
                   p_effective_date               => l_effective_date,
                   p_include_in_wnu               => 'N');
                --
               hr_utility.trace('Succesfully updated flag');

   end loop;
    --
  EXCEPTION WHEN OTHERS THEN
    hr_utility.trace('Error in Assgt Action cursor'); RAISE;
  END;
--
  hr_utility.set_location(' Leaving: '||l_proc,100);
--
end wnu_full_action_creation;
--
--
/* PROCEDURE wnu_update_action_creation:
This PROC creates assignment actions when running the process in UPDATE Mode  */
--
Procedure wnu_update_action_creation   (pactid    in number,
                                 stperson  in number,
                                 endperson in number,
                                 chunk     in number)
IS
--
-- Bug Number : 4369280
-- commented hr_organization_information as the new legal employer classification is now
-- attached because of which we dont need the tax reference and the paye reference rather
-- we pass the employee reference. This change comes in effect due to a new legal employer
-- classification being used.

cursor csr_state(p_payroll_id NUMBER,  p_emp_ref VARCHAR2,  p_assignment_set_id NUMBER) is
            select   asg.assignment_id assignment_id,
                     ppa.effective_date effective_date
            from     per_all_assignments_f asg,
                     pay_payroll_actions ppa,
                     per_all_people_f pap,
                     per_periods_of_service serv,
                     per_assignment_extra_info aei,
            --         hr_organization_information hoi,
                     pay_all_payrolls_f pay,
                     hr_soft_coding_keyflex sck
            where    ppa.payroll_action_id = pactid
            --and      hoi.organization_id = ppa.business_group_id
            and      sck.segment4 = p_emp_ref
            and      asg.business_group_id = ppa.business_group_id
            and      asg.payroll_id = pay.payroll_id
            and      pay.soft_coding_keyflex_id = sck.soft_coding_keyflex_id
            --and      upper(p_tax_ref) = upper(sck.segment1)
            --and      upper(sck.segment1) = upper(hoi.org_information1)
	    -- For bug Fix 3567562 added condition to filter records based on PAYE Reference specified as parameter.
	    --and      upper(sck.segment3) = upper(hoi.org_information2)
	    --and      upper(p_paye_ref)  =  upper(sck.segment3)
            and      pay.payroll_id = NVL(p_payroll_id,pay.payroll_id)
            and     (p_assignment_set_id is null
                        OR exists
                           ( select 1
                            from HR_ASSIGNMENT_SET_AMENDMENTS amend,
                                 hr_assignment_sets           aset
 where
 ( P_ASSIGNMENT_SET_ID IS NOT NULL and
aset.assignment_set_id =  P_ASSIGNMENT_SET_ID
-- Bug2856413 To handle payroll in Assgt sets
and nvl(aset.payroll_id,pay.payroll_id) = pay.payroll_id
and amend.assignment_set_id(+)= aset.assignment_set_id
and
(
(amend.include_or_exclude is not null AND
((amend.include_or_exclude='I' and amend.assignment_id  = asg.assignment_id)
OR
(amend.include_or_exclude='E' and amend.assignment_id  <> asg.assignment_id)))
 OR
 amend.include_or_exclude is null)
)))
            and     asg.person_id = pap.person_id
            and     serv.person_id = pap.person_id
            and     serv.period_of_service_id = asg.period_of_service_id
            and     serv.date_start = (select max(s.date_start)
                           from   per_periods_of_service s
                                 where  s.person_id = pap.person_id
                                 and    ppa.effective_date >= s.date_start)
            and      pap.current_employee_flag = 'Y'
            and      asg.assignment_id  = aei.assignment_id
            and      asg.PRIMARY_FLAG = 'Y'
            and      aei.information_type = 'IE_WNU'
            and      aei.aei_information1 = 'Y'
            and      asg.person_id between
                     stperson and endperson
            and     ppa.effective_date between
                    asg.effective_start_date and asg.effective_end_date
            and     ppa.effective_date between
                    pap.effective_start_date and pap.effective_end_date
            and     ppa.effective_date between
                    pay.effective_start_date and pay.effective_end_date
            order by asg.assignment_id;
--
lockingactid             number;
l_proc                   CONSTANT VARCHAR2(60):= g_package||'wnu_update_action_creation';
l_payroll_id             number(15):= null;
--l_tax_ref                varchar2(20):=null;
l_assignment_set_id      number(15) :=null;
l_stored_asg_id         NUMBER;
l_effective_date        DATE;
--Added for bug fix 3567562
--l_paye_ref               varchar2(20):=null;

--Bug 4369280
--commented the tax reference and the paye reference parameters as in the new legal employer
--classification they are not needed
--rather a new parameter is used for the legal employer reference .

l_emp_ref               varchar2(20):=null;
--
begin
--
  hr_utility.set_location('Entering: '||l_proc,1);
--
-- get parameter values from legislative parameters
l_payroll_id             := to_number(PAY_IE_ARCHIVE_DETAIL_PKG.get_parameter(pactid,'PAYROLL_ID'));
--l_tax_ref                := substr(trim(PAY_IE_ARCHIVE_DETAIL_PKG.get_parameter(pactid,'TAX_REF')),1,20);
l_assignment_set_id      := to_number(PAY_IE_ARCHIVE_DETAIL_PKG.get_parameter(pactid,'ASSIGNMENT_SET_ID')) ;
--Added for Bug Fix 3567562
--l_paye_ref               := substr(trim(PAY_IE_ARCHIVE_DETAIL_PKG.get_parameter(pactid,'PAYE_REF')),1,20);
l_emp_ref               := substr(trim(PAY_IE_ARCHIVE_DETAIL_PKG.get_parameter(pactid,'EMP_REF')),1,20);
--
--
  BEGIN
   for asgrec in csr_state(l_payroll_id, l_emp_ref,l_assignment_set_id) loop
       --
          hr_utility.set_location(l_proc,10);
          --
          --
            l_stored_asg_id  := asgrec.assignment_id;
            l_effective_date := asgrec.effective_date;
          --
          -- Create the assignment_action
             --
             select pay_assignment_actions_s.nextval
             into   lockingactid
             from   dual;
             --
             -- insert into pay_assignment_actions.
             --
             hr_utility.trace('Storing Asg: '|| to_char(l_stored_asg_id));
             --
             hr_nonrun_asact.insact(lockingactid=>      lockingactid,
                                    assignid =>l_stored_asg_id,
                                    pactid => pactid,
                                    chunk => chunk,
                                    greid =>null);

            hr_utility.set_location(l_proc,20);
             --
            --
              -- Update flag set in PER_ASSIGNMENT_EXTRA_INFO for this assignment
            hr_utility.trace('Updating AEI flag, for asg:'||to_char(l_stored_asg_id));
                PAY_IE_WNU_EDI.wnu_update_extra_info
                  (p_assignment_id                => asgrec.assignment_id,
                   p_effective_date               => l_effective_date,
                   p_include_in_wnu               => 'N');
            --
               hr_utility.trace('Succesfully updated flag');
   end loop;
    --
  EXCEPTION WHEN OTHERS THEN
    hr_utility.trace('Error in Update Assgt Action cursor');
    RAISE;
  END;
--
  hr_utility.set_location(' Leaving: '||l_proc,100);
--
end wnu_update_action_creation;
--
end  PAY_IE_WNU_EDI;

/
