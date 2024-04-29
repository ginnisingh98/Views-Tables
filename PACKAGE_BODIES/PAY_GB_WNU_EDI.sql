--------------------------------------------------------
--  DDL for Package Body PAY_GB_WNU_EDI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_GB_WNU_EDI" as
/* $Header: pygbwnu2.pkb 120.7.12010000.3 2010/01/11 14:21:21 namgoyal ship $ */
/*===========================================================================+
|               Copyright (c) 1993 Oracle Corporation                       |
|                  Redwood Shores, California, USA                          |
|                       All rights reserved.                                |
+============================================================================
 Name
    PAY_GB_WNU_EDI
  Purpose
    Package to control archiver process in the creation of assignment actions
    and the creation of EDI Message files uing the magtape process for EDI
    Message Types : WNU
    This is a UK Specific payroll package.
  Notes

  History
  01-NOV-2000  ILeath     115.0  Date Created.
  19-JUN-2001  S.Robinson 115.1  Change to cursor c_state to ensure
                                 assignments only selected once and
                                 character validation is enforced.
  06-AUG-2002  A.Mills    115.2  2473608. Added join to periods_of_service
                                 from per_all_assignments_f.
  07-AUG-2002  A.Mills    115.4  Enabled package for Aggregated PAYE.
  02-DEC-2002  G.Butler   115.7  nocopy qualifier added to range_cursor
  18-DEC-2003   asengar   115.8  BUG 3294480 Changed code for NI update
  08-SEP-2004  K.Thampan  115.9  Revert the change for bug 2545016
  13-JAN-2005  K.Thampan  115.10 Bug 4117609 - Amended the cursor so that
                                 it will return employee regardless the
                                 NI number.
  25-MAY-2005  K.Thampan  115.11 Bug 4392220 - Amended the cursor c_state in
                                 procedure wnu_cleanse_act_creation to return
                                 assignments that does't have a record on the
                                 per_assignment_extra_info table.  This is
                                 because these assignments might have been entered
                                 using API, instead of front end (Form).
  09-FEB-2006  K.Thampan  115.12 Fixed bug 4938724. Set g_stored_asg_id to null
  16-JUN-2006  K.Thampan  115.13 Code change for EDI Rollback.
  23-JUN-2006  K.Thampan  115.14 Update deinitilization procedure.
  27-JUN-2006  K.Thampan  115.15 Added code to clear down data for aggregated
                                 assignments
  29-JUN-2006  K.Thampan  115.16 Fixed GSCC error
  28-JUL-2006  tukumar    115.13 Enhancement 5398360 : wnu 3.0
  01-SEP-2006  tukumar    115.14 Performance fix bug 5504855
  13-MAR-2006  K.Thampan  115.19 Bug fix 5929268
  05-Jan-2010  namgoyal   115.20 Bug 9186359. Added code in procedure
                                 deinitialization_code to spawn the eText
				 based BI Publisher CP for WNU3.0.
				 This code would only be called for
				 release 12.1.3.
==============================================================================*/
--
--
TYPE act_info_rec IS RECORD
     ( assignment_id          number(20)
      ,effective_date         date
      ,action_info_category   varchar2(50)
      ,act_info1              varchar2(300)
      ,act_info2              varchar2(300)
      ,act_info3              varchar2(300)
      ,act_info4              varchar2(300)
      ,act_info5              varchar2(300)
      ,act_info6              varchar2(300)
      ,act_info7              varchar2(300)
      ,act_info8              varchar2(300)
      ,act_info9              varchar2(300)
      ,act_info10             varchar2(300)
      ,act_info11             varchar2(300)
      ,act_info12             varchar2(300)
      ,act_info13             varchar2(300)
      ,act_info14             varchar2(300)
      ,act_info15             varchar2(300)
      ,act_info16             varchar2(300)
      ,act_info17             varchar2(300)
      ,act_info18             varchar2(300)
      ,act_info19             varchar2(300)
      ,act_info20             varchar2(300)
      ,act_info21             varchar2(300)
      ,act_info22             varchar2(300)
      ,act_info23             varchar2(300)
      ,act_info24             varchar2(300)
      ,act_info25             varchar2(300)
      ,act_info26             varchar2(300)
      ,act_info27             varchar2(300)
      ,act_info28             varchar2(300)
      ,act_info29             varchar2(300)
      ,act_info30             varchar2(300)
     );

TYPE action_info_table IS TABLE OF
     act_info_rec INDEX BY BINARY_INTEGER;

g_package    CONSTANT VARCHAR2(20):= 'PAY_GB_WNU_EDI.';
/****************** PRIVATE PROCEDURE  ***********************/
--
PROCEDURE internal_act_creation(pactid    in number,
                                stperson  in number,
                                endperson in number,
                                chunk     in number,
                                p_mode    in varchar2) IS

     l_proc  CONSTANT VARCHAR2(50):= g_package||'internal_act_creation';
     l_payroll_id        number;
     l_business_group_id number;
     l_tax_ref           varchar2(20);
     l_effective_date    date;
     l_stored_asg_id     number;
     l_stored_per_id     number;
     l_locking_act_id    number;

     cursor csr_parameter_info is
     select to_number(pay_gb_eoy_archive.get_parameter(legislative_parameters,
                                        'PAYROLL_ID')) payroll_id,
            substr(pay_gb_eoy_archive.get_parameter(legislative_parameters,
                                        'TAX_REF'),1,20) tax_ref,
            effective_date,
            business_group_id
     from   pay_payroll_actions
     where  payroll_action_id = pactid;

     cursor asg_act is
     select /*+ ORDERED */
            asg.assignment_id assignment_id,
            decode(pap.per_information10,'Y','Y',NULL) agg_paye_flag,
            pap.person_id
     from   per_all_people_f          pap,
            per_assignments_f         asg,
            per_periods_of_service    serv,
            pay_all_payrolls_f        pay,
            per_assignment_extra_info aei,
            hr_soft_coding_keyflex    sck
     where  pap.person_id between stperson and endperson
     and    asg.business_group_id = l_business_group_id
     and    asg.person_id = pap.person_id
     and    asg.period_of_service_id = serv.period_of_service_id
     and    asg.payroll_id = pay.payroll_id
     and    pay.soft_coding_keyflex_id = sck.soft_coding_keyflex_id
     and    upper(l_tax_ref) = upper(sck.segment1)
     and    (l_payroll_id IS NULL
             or
             l_payroll_id = pay.payroll_id)
     and    pap.current_employee_flag = 'Y'
     and    l_effective_date between asg.effective_start_date and asg.effective_end_date
     and    l_effective_date between pap.effective_start_date and pap.effective_end_date
     and    l_effective_date between pay.effective_start_date and pay.effective_end_date
     and    l_effective_date between serv.date_start and nvl(serv.actual_termination_date,hr_general.end_of_time)
     and    aei.assignment_id(+) = asg.assignment_id
     and    aei.information_type(+) = 'GB_WNU'
     and    nvl(aei.aei_information2,'N') <> 'Y'
     and    (p_mode = 'FULL'
             or
             (    p_mode = 'UPDATE'
              and (aei.aei_information1 is not null or aei.aei_information3 = 'Y')))
     order by pap.person_id;
BEGIN
     hr_utility.set_location('Entering: '||l_proc,1);
     open csr_parameter_info;
     fetch csr_parameter_info into l_payroll_id,
                                   l_tax_ref,
                                   l_effective_date,
                                   l_business_group_id;
     close csr_parameter_info;

     l_stored_asg_id := null;
     hr_utility.set_location('Before ASG_ACT cursor',10);
     for asg_rec in asg_act loop
         hr_utility.set_location('Person ID/Assignment ID: '||
                                  asg_rec.person_id || '/' || asg_rec.assignment_id,20);
         -- First person in the loop, store the details and fetch next.
         if l_stored_asg_id is null then
            l_stored_asg_id := asg_rec.assignment_id;
            l_stored_per_id := asg_rec.person_id;
         else
            -- If this is the same person and is aggregated,
            -- save the assignment with the lowest ID
            if (l_stored_per_id = asg_rec.person_id and
                asg_rec.agg_paye_flag = 'Y') then
                if asg_rec.assignment_id < nvl(l_stored_asg_id,999999999) THEN
                   l_stored_asg_id := asg_rec.assignment_id;
                end if;
            else
                select pay_assignment_actions_s.nextval
                into   l_locking_act_id
                from   dual;

                hr_nonrun_asact.insact(l_locking_act_id,
                                       l_stored_asg_id,
                                       pactid,
                                       chunk,
                                       null);
                l_stored_asg_id := asg_rec.assignment_id;
                l_stored_per_id := asg_rec.person_id;
            end if;
         end if;
     end loop;

     if l_stored_asg_id is not null then
        hr_utility.set_location('Person ID/Assignment ID: '||
                                l_stored_per_id || '/' || l_stored_asg_id,20);
        select pay_assignment_actions_s.nextval
        into   l_locking_act_id
        from   dual;

        hr_nonrun_asact.insact(l_locking_act_id,
                               l_stored_asg_id,
                               pactid,
                               chunk,
                               null);
     end if;
     hr_utility.set_location('Leaving: '||l_proc,999);
END internal_act_creation;
--
--
FUNCTION validate_data(p_value  in varchar2,
                        p_name  in varchar2,
                        p_mode  in varchar2) return boolean IS
     l_proc  CONSTANT VARCHAR2(50):= g_package||'validate_data';
BEGIN
     hr_utility.set_location('Entering: '||l_proc,1);
     if pay_gb_eoy_magtape.validate_input(UPPER(p_value),p_mode) > 0 then
        hr_utility.set_location('Name/Value : ' || p_name || '/' || p_value ,10);
        pay_core_utils.push_message(800, 'HR_78057_GB_MAGTAPE_VAILDATION', 'F');
        pay_core_utils.push_token('INPUT_NAME', p_name);
        pay_core_utils.push_token('INPUT_VALUE', p_value);
        return false;
     end if;
     hr_utility.set_location('Leaving: '||l_proc,999);
     return true;
END validate_data;
--
--
PROCEDURE update_aggregate_asg(p_assact_id in number)
IS
     l_payroll_id        number;
     l_business_group_id number;
     l_tax_ref           varchar2(20);
     l_effective_date    date;
     l_person_id         number;
     l_assignment_id     number;
     l_wnu_id            number;
     l_ovn               number;

     cursor csr_parameter_info is
     select to_number(pay_gb_eoy_archive.get_parameter(legislative_parameters,
                                        'PAYROLL_ID')) payroll_id,
            substr(pay_gb_eoy_archive.get_parameter(legislative_parameters,
                                        'TAX_REF'),1,20) tax_ref,
            effective_date,
            business_group_id
     from   pay_assignment_actions paa,
            pay_payroll_actions    pay
     where  paa.assignment_action_id = p_assact_id
     and    pay.payroll_action_id = paa.payroll_action_id;

     cursor csr_person_id is
     select person_id,
            paa.assignment_id
     from   pay_assignment_actions paa,
            per_all_assignments_f  paf
     where  paa.assignment_action_id = p_assact_id
     and    paa.assignment_id = paf.assignment_id;

     -- 5504855
     cursor csr_wnu(p_asg_id number) is
     select aei.assignment_extra_info_id
     from   per_assignment_extra_info aei
     where  aei.assignment_id = p_asg_id
     and    aei.information_type = 'GB_WNU';

     cursor asg_act is
     select /*+ ORDERED */
            asg.assignment_id assignment_id
     from   per_all_people_f          pap,
            per_assignments_f         asg,
            per_periods_of_service    serv,
            pay_all_payrolls_f        pay,
            per_assignment_extra_info aei,
            hr_soft_coding_keyflex    sck
     where  pap.person_id = l_person_id
     and    asg.business_group_id = l_business_group_id
     and    asg.person_id = pap.person_id
     and    asg.period_of_service_id = serv.period_of_service_id
     and    asg.payroll_id = pay.payroll_id
     and    pay.soft_coding_keyflex_id = sck.soft_coding_keyflex_id
     and    upper(l_tax_ref) = upper(sck.segment1)
     and    (l_payroll_id IS NULL
             or
             l_payroll_id = pay.payroll_id)
     and    pap.current_employee_flag = 'Y'
     and    pap.per_information10 = 'Y'
     and    l_effective_date between asg.effective_start_date and asg.effective_end_date
     and    l_effective_date between pap.effective_start_date and pap.effective_end_date
     and    l_effective_date between pay.effective_start_date and pay.effective_end_date
     and    l_effective_date between serv.date_start and nvl(serv.actual_termination_date,hr_general.end_of_time)
     and    aei.assignment_id = asg.assignment_id
     and    aei.information_type = 'GB_WNU'
     and    nvl(aei.aei_information2,'N') <> 'Y'
     and    (aei.aei_information1 is not null or aei.aei_information3 = 'Y')
     order by pap.person_id;
BEGIN
     open csr_parameter_info;
     fetch csr_parameter_info into l_payroll_id,
                                   l_tax_ref,
                                   l_effective_date,
                                   l_business_group_id;
     close csr_parameter_info;

     open csr_person_id;
     fetch csr_person_id into l_person_id, l_assignment_id;
     close csr_person_id;

     for all_aggregated in asg_act loop
         if all_aggregated.assignment_id <> l_assignment_id then
            l_wnu_id := null;
            open csr_wnu(all_aggregated.assignment_id);
            fetch csr_wnu into l_wnu_id;
            close csr_wnu;

            if l_wnu_id is not null then
               hr_assignment_extra_info_api.update_assignment_extra_info
                  (p_validate                       => false,
                   p_object_version_number          => l_ovn,
                   p_assignment_extra_info_id       => l_wnu_id,
                   p_aei_information_category       => 'GB_WNU',
                   p_aei_information1               => null,
                   p_aei_information2               => 'N',
                   p_aei_information3               => 'N');
             end if;
         end if;
     end loop;
END update_aggregate_asg;
--
--
FUNCTION fetch_person_rec(p_assactid        IN NUMBER,
                           p_effective_date IN DATE,
                           p_person_rec     OUT nocopy act_info_rec) return boolean IS

     l_proc  CONSTANT VARCHAR2(50):= g_package||'fetch_person_rec';
     l_person_id      number;
     l_ret            boolean;

     cursor csr_person_details is
     select /*+ ORDERED */
            pap.title,
            pap.first_name,
            pap.middle_names,
            pap.last_name,
            paa.ASSIGNMENT_NUMBER,
            pap.national_identifier,
            paa.assignment_id
     from   pay_assignment_actions pact,
            per_assignments_f  paa,
            per_people_f       pap
     where  pact.assignment_action_id = p_assactid
     and    pact.assignment_id = paa.assignment_id
     and    paa.person_id = pap.person_id
     and    p_effective_date between paa.effective_start_date and paa.effective_end_date
     and    p_effective_date between pap.effective_start_date and pap.effective_end_date;

     l_person_rec  csr_person_details%rowtype;
BEGIN
     hr_utility.set_location('Entering: '||l_proc,1);
     l_ret := false;

     open csr_person_details;
     fetch csr_person_details into l_person_rec;
     close csr_person_details;

     if validate_data(l_person_rec.first_name,'Full Name','EDI_SURNAME')  and
        validate_data(l_person_rec.last_name,'Last Name','EDI_SURNAME') and
        validate_data(l_person_rec.middle_names,'Middle Name','EDI_SURNAME') and
        validate_data(l_person_rec.national_identifier,'NI Number','FULL_EDI') and
        validate_data(l_person_rec.assignment_number,'Assignment Number','FULL_EDI') then
        l_ret := true;
     end if;
     p_person_rec.assignment_id := l_person_rec.assignment_id;
     p_person_rec.effective_date := p_effective_date;
     p_person_rec.action_info_category := 'GB EMPLOYEE DETAILS';
     p_person_rec.act_info6  := l_person_rec.first_name;
     p_person_rec.act_info7  := l_person_rec.middle_names;
     p_person_rec.act_info8  := l_person_rec.last_name;
     p_person_rec.act_info11 := l_person_rec.assignment_number;
     p_person_rec.act_info12 := l_person_rec.national_identifier;
     p_person_rec.act_info14 := l_person_rec.title;

     hr_utility.set_location('Leaving: '||l_proc,999);
     return l_ret;
END fetch_person_rec;
--
--
FUNCTION fetch_wnu_rec(p_assactid        IN NUMBER,
                        p_effective_date IN DATE,
                        p_wnu_rec        OUT nocopy act_info_rec) return boolean IS

     l_proc  CONSTANT VARCHAR2(50):= g_package||'fetch_person_rec';
     l_assignment_id  number;
     l_ovn            number;
     l_ret            boolean;

     cursor csr_wnu_details is
     select aei.assignment_extra_info_id,
            aei.aei_information1 old_asg_number,
            aei.aei_information2 not_flag,
            aei.aei_information3 ni_update,
            aei.object_version_number,
            paa.assignment_id
     from   pay_assignment_actions paa,
            per_assignment_extra_info aei
     where  paa.assignment_action_id = p_assactid
     and    paa.assignment_id = aei.assignment_id
     and    aei.information_type = 'GB_WNU';

     l_wnu_rec  csr_wnu_details%rowtype;
BEGIN
     hr_utility.set_location('Entering: '||l_proc,1);
     l_ret := true;

     open csr_wnu_details;
     fetch csr_wnu_details into l_wnu_rec;

     if csr_wnu_details%FOUND then
        hr_utility.set_location('Data found',20);
        l_ret := validate_data(l_wnu_rec.old_asg_number,'Old Assignment Number','FULL_EDI');

        l_ovn := l_wnu_rec.object_version_number;

        hr_utility.set_location('Clear Flag',30);

        if l_ret then
           hr_assignment_extra_info_api.update_assignment_extra_info
              (p_validate                       => false,
               p_object_version_number          => l_ovn,
               p_assignment_extra_info_id       => l_wnu_rec.assignment_extra_info_id,
               p_aei_information_category       => 'GB_WNU',
               p_aei_information1               => null,
               p_aei_information2               => 'N',
               p_aei_information3               => 'N');

           update_aggregate_asg(p_assactid);
        end if;

        p_wnu_rec.assignment_id := l_wnu_rec.assignment_id;
        p_wnu_rec.effective_date := p_effective_date;
        p_wnu_rec.action_info_category := 'GB WNU EDI';
        p_wnu_rec.act_info1 := l_ovn;
        p_wnu_rec.act_info2 := l_wnu_rec.old_asg_number;
        p_wnu_rec.act_info3 := l_wnu_rec.not_flag;
        p_wnu_rec.act_info4 := l_wnu_rec.ni_update;
     end if;

     close csr_wnu_details;
     hr_utility.set_location('Leaving: '||l_proc,999);

     return l_ret;
END fetch_wnu_rec;
--
--
PROCEDURE insert_archive_row(p_assactid       IN NUMBER,
                             p_effective_date IN DATE,
                             p_tab_rec_data   IN action_info_table) IS
     l_proc  CONSTANT VARCHAR2(50):= g_package||'insert_archive_row';
     l_ovn       number;
     l_action_id number;
BEGIN
     hr_utility.set_location('Entering: '||l_proc,1);
     if p_tab_rec_data.count > 0 then
        for i in p_tab_rec_data.first .. p_tab_rec_data.last loop
            hr_utility.trace('Defining category '|| p_tab_rec_data(i).action_info_category);
            hr_utility.trace('action_context_id = '|| p_assactid);
            if p_tab_rec_data(i).action_info_category is not null then
               pay_action_information_api.create_action_information(
                p_action_information_id => l_action_id,
                p_object_version_number => l_ovn,
                p_action_information_category => p_tab_rec_data(i).action_info_category,
                p_action_context_id    => p_assactid,
                p_action_context_type  => 'AAP',
                p_assignment_id        => p_tab_rec_data(i).assignment_id,
                p_effective_date       => p_effective_date,
                p_action_information1  => p_tab_rec_data(i).act_info1,
                p_action_information2  => p_tab_rec_data(i).act_info2,
                p_action_information3  => p_tab_rec_data(i).act_info3,
                p_action_information4  => p_tab_rec_data(i).act_info4,
                p_action_information5  => p_tab_rec_data(i).act_info5,
                p_action_information6  => p_tab_rec_data(i).act_info6,
                p_action_information7  => p_tab_rec_data(i).act_info7,
                p_action_information8  => p_tab_rec_data(i).act_info8,
                p_action_information9  => p_tab_rec_data(i).act_info9,
                p_action_information10 => p_tab_rec_data(i).act_info10,
                p_action_information11 => p_tab_rec_data(i).act_info11,
                p_action_information12 => p_tab_rec_data(i).act_info12,
                p_action_information13 => p_tab_rec_data(i).act_info13,
                p_action_information14 => p_tab_rec_data(i).act_info14,
                p_action_information15 => p_tab_rec_data(i).act_info15,
                p_action_information16 => p_tab_rec_data(i).act_info16,
                p_action_information17 => p_tab_rec_data(i).act_info17,
                p_action_information18 => p_tab_rec_data(i).act_info18,
                p_action_information19 => p_tab_rec_data(i).act_info19,
                p_action_information20 => p_tab_rec_data(i).act_info20,
                p_action_information21 => p_tab_rec_data(i).act_info21,
                p_action_information22 => p_tab_rec_data(i).act_info22,
                p_action_information23 => p_tab_rec_data(i).act_info23,
                p_action_information24 => p_tab_rec_data(i).act_info24,
                p_action_information25 => p_tab_rec_data(i).act_info25,
                p_action_information26 => p_tab_rec_data(i).act_info26,
                p_action_information27 => p_tab_rec_data(i).act_info27,
                p_action_information28 => p_tab_rec_data(i).act_info28,
                p_action_information29 => p_tab_rec_data(i).act_info29,
                p_action_information30 => p_tab_rec_data(i).act_info30
                );
            end if;
        end loop;
     end if;
     hr_utility.set_location('Leaving: '||l_proc,999);
END insert_archive_row;
--
--
/****************** PUBLIC PROCEDURE  ***********************/
--
--
PROCEDURE archinit(p_payroll_action_id IN NUMBER)
IS
     l_proc      CONSTANT VARCHAR2(50) := g_package || ' archinit';
     l_sender_id VARCHAR2(30);
     l_tax_ref   VARCHAR2(30);
     l_err       EXCEPTION;

     cursor csr_sender_id is
     select hoi.org_information11,
            hoi.org_information1
     from   pay_payroll_actions pact,
            hr_organization_information hoi
     where  pact.payroll_action_id = p_payroll_action_id
     and    pact.business_group_id = hoi.organization_id
     and    hoi.org_information_context = 'Tax Details References'
     and    (hoi.org_information10 is null
             OR
             hoi.org_information10 = 'UK')
     and    hoi.org_information1 =
            substr(pact.legislative_parameters,
                   instr(pact.legislative_parameters,'TAX_REF=') + 8,
                   instr(pact.legislative_parameters||' ',' ',
                   instr(pact.legislative_parameters,'TAX_REF=')+8)
                 - instr(pact.legislative_parameters,'TAX_REF=') - 8);
BEGIN
     hr_utility.set_location('Entering '|| l_proc, 10);
     open csr_sender_id;
     fetch csr_sender_id into l_sender_id, l_tax_ref;
     close csr_sender_id;

     if l_sender_id is null then
        pay_core_utils.push_message(800, 'HR_78087_EDI_SENDER_ID_MISSING', 'F');
        pay_core_utils.push_token('TAX_REF', l_tax_ref);
        raise l_err;
     else
        if (not validate_data(l_sender_id,'Sender ID','FULL_EDI')) then
           raise l_err;
        end if;
     end if;

     hr_utility.set_location('Leaving '|| l_proc, 10);
EXCEPTION
     when others then
          hr_utility.raise_error;
END archinit;
--
--
PROCEDURE range_cursor (pactid IN NUMBER,
                        sqlstr OUT nocopy VARCHAR2) IS
     l_proc  CONSTANT VARCHAR2(35):= g_package||'range_cursor';
BEGIN
     hr_utility.set_location('Entering: '||l_proc,1);
     sqlstr := 'select distinct person_id '||
               'from per_people_f ppf, '||
               'pay_payroll_actions ppa '||
               'where ppa.payroll_action_id = :payroll_action_id '||
               'and ppa.business_group_id = ppf.business_group_id '||
               'order by ppf.person_id';
     hr_utility.set_location('Leaving: '||l_proc,999);
END range_cursor;
--
--
PROCEDURE wnu_cleanse_act_creation(pactid    in number,
                                   stperson  in number,
                                   endperson in number,
                                   chunk     in number) IS
BEGIN
     internal_act_creation(pactid, stperson, endperson, chunk, 'FULL');
END wnu_cleanse_act_creation;
--
--
PROCEDURE wnu_update_action_creation(pactid    in number,
                                     stperson  in number,
                                     endperson in number,
                                     chunk     in number) IS
BEGIN
     internal_act_creation(pactid, stperson, endperson, chunk, 'UPDATE');
END wnu_update_action_creation;
--
--
PROCEDURE archive_code(p_assactid       IN NUMBER,
                       p_effective_date IN DATE) IS
     l_proc  CONSTANT VARCHAR2(35):= g_package||'archive_code';
     error_found      EXCEPTION;
     l_archive_tab    action_info_table;
     l_archive_person boolean;
     l_archive_wnu    boolean;

BEGIN
     hr_utility.set_location('Entering: '||l_proc,1);

     hr_utility.set_location('Fetching person details ',10);
     l_archive_person := fetch_person_rec(p_assactid, p_effective_date, l_archive_tab(0));

	 hr_utility.set_location('Fetching wnu details ',20);
     l_archive_wnu := fetch_wnu_rec(p_assactid, p_effective_date, l_archive_tab(1));

     if l_archive_person and l_archive_wnu then
         insert_archive_row(p_assactid, p_effective_date, l_archive_tab);
     else
         raise error_found;
     end if;
     hr_utility.set_location('Leaving: '||l_proc,999);
EXCEPTION
     when error_found then
          hr_utility.raise_error;
END archive_code;
--
--
PROCEDURE deinitialization_code(pactid IN NUMBER)
IS
     cursor csr_get_wnu_version is
	  select   substr(pact.legislative_parameters,
                instr(pact.legislative_parameters,'VERSION=') + 8,
                    instr(pact.legislative_parameters||' ',' ',instr(pact.legislative_parameters,'VERSION=')+8)
             - instr(pact.legislative_parameters,'VERSION=') - 8) version
	  from pay_payroll_actions pact where pact.payroll_action_id = pactid;

   --Bug 9186359:WNU eText report
   --This piece of code is relevent only for release 12.1.3
     Cursor csr_is_etext_report IS
     Select report_type
     From pay_payroll_actions pact
     Where pact.payroll_action_id = pactid;

     l_is_etext_report      varchar2(50);
     l_request_id           fnd_concurrent_requests.request_id%TYPE;
     xml_layout             boolean;
   --Bug 9186359:End

     l_proc  CONSTANT VARCHAR2(50) := g_package || 'deinitialization_code';
     l_counter number;
     l_wnu_version VARCHAR2(4);


     procedure write_header( p_wnu_version in VARCHAR2) is
         l_token   varchar2(255);
         l_addr1   varchar2(255);
         l_addr2   varchar2(255);
         l_addr3   varchar2(255);
         l_addr4   varchar2(255);
         l_form    varchar2(40);
         l_tax_ref varchar2(20);
         l_urgent  varchar2(2);
         l_test    varchar2(2);
         l_temp    number;

         cursor csr_leg_param is
         select legislative_parameters para,
                fnd_number.number_to_canonical(request_id) control_id,
                report_type,
                business_group_id
         from   pay_payroll_actions
         where  payroll_action_id = pactid;

         cursor csr_header_det(p_bus_id  number,
                               p_tax_ref varchar2) is
         select nvl(hoi.org_information11,' ')       sender_id,
                nvl(upper(hoi.org_information2),' ') hrmc_office,
                nvl(upper(hoi.org_information4),' ') er_addr,
                nvl(upper(hoi.org_information3),' ') er_name
         from   hr_organization_information hoi
         where  hoi.organization_id = p_bus_id
         and    hoi.org_information_context = 'Tax Details References'
         and    nvl(hoi.org_information10,'UK') = 'UK'
         and    upper(hoi.org_information1) = upper(p_tax_ref);

         l_param csr_leg_param%rowtype;
         l_det   csr_header_det%rowtype;

     begin
         open csr_leg_param;
         fetch csr_leg_param into l_param;
         close csr_leg_param;

         l_token   := 'TAX_REF';
         l_temp    := instr(l_param.para,l_token);
         l_tax_ref := substr(l_param.para, l_temp + length(l_token) + 1,
                      instr(l_param.para||' ',' ',l_temp) - (l_temp + length(l_token) + 1));
         l_token  := 'URGENT';
         l_temp   := instr(l_param.para,l_token);
         l_urgent := substr(l_param.para, l_temp + length(l_token) + 1,
                     instr(l_param.para||' ',' ',l_temp) - (l_temp + length(l_token) + 1));
         l_token := 'TEST';
         l_temp  := instr(l_param.para,l_token);
         l_test  := substr(l_param.para, l_temp + length(l_token) + 1,
                    instr(l_param.para||' ',' ',l_temp) - (l_temp + length(l_token) + 1));

         open csr_header_det(l_param.business_group_id, l_tax_ref);
         fetch csr_header_det into l_det;
         close csr_header_det;

         l_addr1 := l_det.er_addr;
         if length(l_addr1) > 35 then
            l_temp := instr(l_addr1, ',', 34 - length(l_addr1));
            if l_temp = 0 then
               l_temp := 35;
            end if;
            l_addr2 := ltrim(substr(l_addr1, 1 + l_temp),' ,');
            l_addr1 := substr(l_addr1,1,l_temp);
         end if;
         if length(l_addr2) > 35 then
            l_temp := instr(l_addr2, ',', 34 - length(l_addr2));
            if l_temp = 0 then
               l_temp := 35;
            end if;
            l_addr3 := ltrim(substr(l_addr2, 1 + l_temp),' ,');
            l_addr2 := substr(l_addr2,1,l_temp);
         end if;
         if length(l_addr3) > 35 then
            l_temp := instr(l_addr3, ',', 34 - length(l_addr3));
            if l_temp = 0 then
               l_temp := 35;
            end if;
            l_addr3 := ltrim(substr(l_addr3, 1 + l_temp),' ,');
            l_addr4 := substr(l_addr3,1,l_temp);
         end if;

         l_form := 'WNU ( WNU '||p_wnu_version||' )';

         fnd_file.put_line(fnd_file.output,'EDI Transmission Report:');
         fnd_file.put_line(fnd_file.output,' ');
         fnd_file.put_line(fnd_file.output,rpad('Form Type : ',32) || l_form );
         fnd_file.put_line(fnd_file.output,rpad('Sender : ',32)    || l_det.sender_id);
         fnd_file.put_line(fnd_file.output,rpad('Date : ',32)      || to_char(sysdate, 'DD/MM/YYYY HH24:MI:SS'));
         fnd_file.put_line(fnd_file.output,rpad('Interchange Control Reference : ',32) || l_param.control_id);
         fnd_file.put_line(fnd_file.output,rpad('Test Transmission : ',32) || l_test);
         fnd_file.put_line(fnd_file.output,rpad('Urgent : ',32)    || l_urgent);
         fnd_file.put_line(fnd_file.output,rpad('-',80,'-'));
         fnd_file.put_line(fnd_file.output,rpad('Employers PAYE Reference : ',32) || l_tax_ref);
         fnd_file.put_line(fnd_file.output,rpad('HRMC Office : ',32)   || l_det.hrmc_office);
         fnd_file.put_line(fnd_file.output,rpad('Employer Name : ',32) || l_det.er_name);
         fnd_file.put_line(fnd_file.output,rpad('Employer Address : ',32) || l_addr1);
         if length(l_addr2) > 0 then
            fnd_file.put_line(fnd_file.output,rpad(' ',32) || l_addr2);
         end if;
         if length(l_addr3) > 0 then
            fnd_file.put_line(fnd_file.output,rpad(' ',32) || l_addr3);
         end if;
         if length(l_addr4) > 0 then
            fnd_file.put_line(fnd_file.output,rpad(' ',32) || l_addr4);
         end if;
     end write_header;

     procedure write_sub_header(p_type varchar2 , p_wnu_version VARCHAR2) is

     begin
         fnd_file.put_line(fnd_file.output,null);
         if p_type = 'E' then
            fnd_file.put_line(fnd_file.output,'The following assignments have completed with error');
         else
            fnd_file.put_line(fnd_file.output,'The following assignments have completed successfully');
         end if;
	 -- Bug 5398360

	 IF p_wnu_version = '1.0' THEN
	        fnd_file.put_line(fnd_file.output,rpad('Assignment Number',19) ||
                                           rpad('NI Number',11) ||
                                           rpad('Employee Name', 50));
		 fnd_file.put_line(fnd_file.output,rpad('-',18,'-') || ' ' ||
                                           rpad('-',10,'-') || ' ' ||
                                           rpad('-',50,'-'));
	 ELSE
		 fnd_file.put_line(fnd_file.output,rpad('Works Number',19) ||
                                           rpad('NI Number',11) ||
                                           rpad('Employee Name', 51)||
					   rpad('Old Works Number',18) ) ;
		 fnd_file.put_line(fnd_file.output,rpad('-',18,'-') || ' ' ||
                                           rpad('-',10,'-') || ' ' ||
                                           rpad('-',50,'-')|| ' ' ||
					   rpad('-',18,'-') );

	 END IF;

     end write_sub_header;

     procedure write_body(p_type varchar2 , p_wnu_version varchar2) is
         l_count number;
         l_temp  varchar2(255);
         l_ni    varchar2(20);
         cursor csr_asg is
         select /*+ ORDERED */
                peo.first_name          f_name ,
                peo.middle_names        m_name,
                peo.last_name           l_name,
                peo.title               title,
                paf.assignment_number   emp_no,
                peo.national_identifier ni_no ,
		pai.action_information2 old_works_number
         from   pay_payroll_actions    pay,
                pay_assignment_actions paa,
                per_all_assignments_f  paf,
                per_all_people_f       peo,
		pay_action_information pai
         where  pay.payroll_action_id = pactid
         and    paa.payroll_action_id = pay.payroll_action_id
         and    paa.action_status = p_type
	 and    pai.action_context_id(+) = paa.assignment_action_id
         and    pai.action_context_type(+) = 'AAP'
         and    pai.action_information_category(+) = 'GB WNU EDI'
         and    paf.assignment_id = paa.assignment_id
         and    peo.person_id = paf.person_id
         and    pay.effective_date between paf.effective_start_date and paf.effective_end_date
         and    pay.effective_date between peo.effective_start_date and peo.effective_end_date;
     begin
         l_count := 0;
         if p_wnu_version = '1.0' then
		 for asg_rec in csr_asg loop
		     l_temp := asg_rec.l_name || ', '|| asg_rec.title || ' ' ||
			       asg_rec.f_name || ' ' || asg_rec.m_name;
	             l_ni := asg_rec.ni_no;
		     if l_ni is null then
			l_ni := '-MISSING-';
	             end if;
		     fnd_file.put_line(fnd_file.output,rpad(asg_rec.emp_no, 18) || ' ' ||
			                               rpad(l_ni  ,10) || ' ' ||
				                       rpad(l_temp,50));
	             l_count := l_count + 1;
		 end loop;
         ELSE
		 for asg_rec in csr_asg loop
		     l_temp := asg_rec.l_name || ', '|| asg_rec.title || ' ' ||
			       asg_rec.f_name || ' ' || asg_rec.m_name;
	             l_ni := asg_rec.ni_no;
		     if l_ni is null then
			l_ni := '-MISSING-';
	             end if;
		     fnd_file.put_line(fnd_file.output,rpad(asg_rec.emp_no, 18) || ' ' ||
			                               rpad(l_ni  ,10) || ' ' ||
				                       rpad(l_temp,50) || ' ' ||
						       rpad(asg_rec.old_works_number,17)); -- 5398360
	             l_count := l_count + 1;
		 end loop;
          END IF;



         fnd_file.put_line(fnd_file.output,null);
         if p_type = 'E' then
            fnd_file.put_line(fnd_file.output,'Total Number of assignments completed with error : ' || l_count);
         else
            fnd_file.put_line(fnd_file.output,'Total Number of assignments completed successfully :' || l_count);
         end if;
         l_counter := l_counter + l_count;
     end write_body;

     procedure write_footer is
     begin
          fnd_file.put_line(fnd_file.output,null);
          fnd_file.put_line(fnd_file.output,'Total Number Of Records : ' || l_counter);
     end write_footer;
BEGIN
     hr_utility.set_location('Entering: '||l_proc,1);
     l_counter := 0;
     	 OPEN csr_get_wnu_version ;
	 FETCH  csr_get_wnu_version  INTO l_wnu_version;
	 CLOSE csr_get_wnu_version ;

     write_header(l_wnu_version);
     write_sub_header('C',l_wnu_version);
     write_body('C',l_wnu_version);
     write_sub_header('E',l_wnu_version);
     write_body('E',l_wnu_version);
     write_footer;

   --Bug 9186359:WNU eText report
   --This piece of code is relevent only for release 12.1.3
   --Spawn the BI Publisher process if it is eText report
     OPEN csr_is_etext_report;
     FETCH  csr_is_etext_report  INTO l_is_etext_report;
     CLOSE csr_is_etext_report;

     IF l_is_etext_report = 'WNU 3.0E'
     THEN
        --this is a eText report, Spawn the BI Publisher process
        hr_utility.set_location('This is a eText report, Spawn the BI Publisher process',1);

        xml_layout := FND_REQUEST.ADD_LAYOUT('PAY','PYGBWNUETO','en','US','ETEXT');

        IF xml_layout = true
        THEN
            l_request_id := fnd_request.submit_request
                                (application => 'PAY'
                                ,program     => 'PYGBWNUETO'
                                ,argument1   => pactid
                                );
            Commit;

            --check for process submit error
            IF l_request_id = 0
            THEN
                hr_utility.set_location('Error spawning new process',1);
            END IF;
        END IF;
     END IF;
   --Bug 9186359:End

     hr_utility.set_location('Leaving: '||l_proc,999);
END deinitialization_code;
--
--
END PAY_GB_WNU_EDI;

/
