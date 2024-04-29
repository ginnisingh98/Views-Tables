--------------------------------------------------------
--  DDL for Package Body PAY_JP_PRE_TAX_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_JP_PRE_TAX_ARCHIVE" AS
/* $Header: pyjppretaxarch.pkb 120.3 2006/09/13 17:18:38 sgottipa noship $ */
--
-- Constants
--
c_package		constant varchar2(31) := 'pay_jp_pre_tax_archive.';
--
-- Global Variables
--
g_payroll_action_id     pay_payroll_actions.payroll_action_id%TYPE;
g_business_group_id     pay_payroll_actions.business_group_id%TYPE;
g_start_date            pay_payroll_actions.effective_date%TYPE;
g_effective_date        pay_payroll_actions.effective_date%TYPE;
g_payroll_id            pay_payroll_actions.payroll_id%TYPE;
g_consolidation_set_id  pay_payroll_actions.consolidation_set_id%TYPE;
g_legislation_code      per_business_groups.legislation_code%TYPE;
--
-- |-------------------------------------------------------------------|
-- |-----------------------< remove_interlocks >-----------------------|
-- |-------------------------------------------------------------------|
procedure remove_interlocks(p_payroll_action_id in pay_payroll_actions.payroll_action_id%type)
is
--
begin
--
  delete pay_action_interlocks
  where locking_action_id in (
    select assignment_action_id
    from   pay_assignment_actions
    where  payroll_action_id = p_payroll_action_id);
--
end remove_interlocks;
--
-- Procedures for ARCHIVE process
--
-- |-------------------------------------------------------------------|
-- |----------------------< initialization_code >----------------------|
-- |-------------------------------------------------------------------|
procedure initialization_code(p_payroll_action_id in pay_payroll_actions.payroll_action_id%TYPE)
is
        c_proc     constant varchar2(61) := c_package || 'initialization_code';
        cursor csr is
                select  business_group_id,
                        start_date,
                        effective_date,
                        legislative_parameters
                from    pay_payroll_actions
                where   payroll_action_id = p_payroll_action_id;
        l_rec   csr%rowtype;
begin
        hr_utility.set_location('Entering: ' || c_proc, 10);
        --
        if g_payroll_action_id is null
        or g_payroll_action_id <> p_payroll_action_id then
                hr_utility.trace('cache not available');
                --
                open csr;
                fetch csr into l_rec;
                if csr%notfound then
                  close csr;
                  fnd_message.set_name('PAY', 'PAY_34985_INVALID_PAY_ACTION');
                  fnd_message.raise_error;
                end if;
                close csr;
                --
                g_payroll_action_id    := p_payroll_action_id;
                g_business_group_id    := l_rec.business_group_id;

                g_legislation_code     := hr_jp_id_pkg.legislation_code(g_business_group_id);
                if (g_legislation_code is NULL) then
                  fnd_message.set_name(800,'HR_51255_PYP_INVALID_BUS_GROUP');
                  fnd_message.raise_error;
                end if;

                g_start_date           := l_rec.start_date;
                g_effective_date       := l_rec.effective_date;
                g_payroll_id           := fnd_number.canonical_to_number(pay_core_utils.get_parameter('PAYROLL_ID', l_rec.legislative_parameters));
                g_consolidation_set_id := fnd_number.canonical_to_number(pay_core_utils.get_parameter('CONSOLIDATION_SET_ID', l_rec.legislative_parameters));
                --
        end if;
        --
        hr_utility.trace('payroll_action_id    : ' || g_payroll_action_id);
        hr_utility.trace('business_group_id    : ' || g_business_group_id);
        hr_utility.trace('start_date           : ' || g_start_date);
        hr_utility.trace('effective_date       : ' || g_effective_date);
        hr_utility.trace('payroll_id           : ' || g_payroll_id);
        hr_utility.trace('consolidation_set_id : ' || g_consolidation_set_id);
        --
        hr_utility.set_location('Leaving: ' || c_proc, 20);
end initialization_code;
-- |-------------------------------------------------------------------|
-- |--------------------------< range_code >---------------------------|
-- |-------------------------------------------------------------------|
procedure range_code(
        p_payroll_action_id  in  pay_payroll_actions.payroll_action_id%TYPE,
        p_sqlstr             out nocopy varchar2)
is
        c_proc      constant varchar2(61) := c_package || 'range_code';
begin
        hr_utility.set_location('Entering: ' || c_proc, 10);
	--
        -- This needs to be called for the case of single-threaded.
        --
        initialization_code(p_payroll_action_id);
        --
        p_sqlstr :=
'select	distinct per.person_id
from	per_all_people_f	per,
        pay_payroll_actions	ppa
where	ppa.payroll_action_id = :payroll_action_id
and  ppa.business_group_id + 0 = per.business_group_id
order by per.person_id';
        --
        hr_utility.set_location('Leaving: ' || c_proc, 20);
end range_code;
-- |-------------------------------------------------------------------|
-- |--------------------< assignment_action_code >---------------------|
-- |-------------------------------------------------------------------|
procedure assignment_action_code(
	p_payroll_action_id  in pay_payroll_actions.payroll_action_id%TYPE,
        p_start_person_id    in number,
        p_end_person_id      in number,
        p_chunk_number       in pay_assignment_actions.chunk_number%TYPE)
is
        c_proc               constant varchar2(61) := c_package || 'assignment_action_code';
	l_locking_action_id  number;
	l_assignment_id      number;
        --
        cursor csr_assact(
          p_business_group_id     pay_payroll_actions.business_group_id%TYPE,
          p_consolidation_set_id  pay_payroll_actions.consolidation_set_id%TYPE,
          p_start_date            pay_payroll_actions.effective_date%TYPE,
          p_effective_date        pay_payroll_actions.effective_date%TYPE,
          p_payroll_id            pay_payroll_actions.payroll_id%TYPE) is

          select  /* Removed the hint as per Bug# 4767118 */
                  paa.assignment_id,
                  paa.assignment_action_id
          from	(
                  select  /* Removed the hint as per Bug# 4767118 */
                          distinct asg.assignment_id
                  from    per_periods_of_service  pds,
                          per_all_assignments_f   asg
                  where   pds.person_id
                                 between p_start_person_id and p_end_person_id
                  and     pds.business_group_id + 0 = p_business_group_id
                  and     asg.period_of_service_id = pds.period_of_service_id
                ) v,
                pay_assignment_actions  paa,
                pay_payroll_actions     ppa
          where paa.assignment_id = v.assignment_id
          and   paa.action_status = 'C'
          and   ppa.payroll_action_id = paa.payroll_action_id
          and   (ppa.consolidation_set_id = p_consolidation_set_id or p_consolidation_set_id is null)
          and   ppa.effective_date
                   between nvl(p_start_date, ppa.effective_date) and p_effective_date
          and   (ppa.payroll_id = p_payroll_id or p_payroll_id is null)
          and   ppa.action_type in ('R', 'Q', 'B', 'I')
          and   not exists(
                   select  /*+ ORDERED
                               USE_NL(PAAA PPAA)
                               INDEX(XPAI PAY_ACTION_INTERLOCKS_FK2)
                               INDEX(XPAA PAY_ASSIGNMENT_ACTIONS_PK)
                               INDEX(XPPA PAY_PAYROLL_ACTIONS_PK) */
                           null
                   from    pay_action_interlocks  xpai,
                           pay_assignment_actions xpaa,
                           pay_payroll_actions    xppa
                   where   xpai.locked_action_id = paa.assignment_action_id
                   and     xpaa.assignment_action_id = xpai.locking_action_id
                   and     xppa.payroll_action_id = xpaa.payroll_action_id
                   and     xppa.action_type = 'X'
                   and     xppa.report_type = 'PRT'
                   and     xppa.report_qualifier = 'JP')
                   and not exists(
                           select  null
                           from    pay_action_information pai
                           where   (pai.action_information_category='JP_PRE_TAX_1')
                           and     pai.action_context_type='AAP'
                           and     pai.action_information1=paa.assignment_action_id
                           and     pai.assignment_id=paa.assignment_id)
                order by paa.assignment_id
                for update of paa.assignment_action_id nowait;
begin
        hr_utility.set_location('Entering: ' || c_proc, 10);
        --
        -- This needs to be called for the case of single-threaded.
        --
        initialization_code(p_payroll_action_id);
        --
        for l_assact_rec in csr_assact( g_business_group_id,
                                        g_consolidation_set_id,
                                        g_start_date,
                                        g_effective_date,
                                        g_payroll_id) loop

             hr_utility.trace('assignment_id : ' || l_assact_rec.assignment_id);
             --
             select  pay_assignment_actions_s.nextval
             into    l_locking_action_id
             from    dual;
             --
             hr_utility.trace('archive assignment_action_id : ' || l_locking_action_id);
             --
             hr_nonrun_asact.insact(
                lockingactid => l_locking_action_id,
                assignid     => l_assact_rec.assignment_id,
                pactid       => p_payroll_action_id,
                chunk        => p_chunk_number,
                greid        => null);
           --
           -- Create action interlock
           --
           hr_utility.trace('run assignment_action_id : ' || l_assact_rec.assignment_action_id);
           hr_nonrun_asact.insint(
              lockingactid => l_locking_action_id,
              lockedactid  => l_assact_rec.assignment_action_id);

              --
              l_assignment_id := l_assact_rec.assignment_id;
        end loop;
        --
        hr_utility.set_location('Leaving: ' || c_proc, 20);
end assignment_action_code;
-- |-------------------------------------------------------------------|
-- |-------------------------< archive_code >--------------------------|
-- |-------------------------------------------------------------------|
procedure archive_code(
	p_assignment_action_id  in pay_assignment_actions.assignment_action_id%TYPE,
	p_effective_date        in pay_payroll_actions.effective_date%TYPE)
is
        c_proc       constant varchar2(61) := c_package || 'archive_code';
        l_errbuf     varchar2(2000);
        l_retcode    varchar2(10);
        --
        cursor csr is
          select locked_action_id
          from   pay_action_interlocks
          where  locking_action_id = p_assignment_action_id;
begin
        hr_utility.set_location('Entering: ' || c_proc, 10);
        hr_utility.trace('locking_action_id : ' || p_assignment_action_id);
        --
        for l_rec in csr loop
           hr_utility.trace('locked_action_id : ' || l_rec.locked_action_id);
           --
           pay_jp_pre_tax_pkg.run_assact(
             p_errbuf                       => l_errbuf,
             p_retcode                      => l_retcode,
             p_locked_assignment_action_id  => l_rec.locked_action_id,
             p_locking_assignment_action_id => p_assignment_action_id);
           --
           if nvl(l_retcode, '0') <> '0' then

             hr_utility.trace('Error: ' || l_errbuf);
             fnd_message.set_encoded(l_errbuf);
             fnd_message.raise_error;

           end if;

         end loop;
        --
        hr_utility.set_location('Leaving: ' || c_proc, 20);
end archive_code;
-- |-------------------------------------------------------------------|
-- |---------------------< deinitialization_code >---------------------|
-- |-------------------------------------------------------------------|
procedure deinitialization_code(p_payroll_action_id in pay_payroll_actions.payroll_action_id%TYPE)
is
        c_proc   constant varchar2(61) := c_package || 'deinitialization_code';
        l_dummy  varchar2(1);
        cursor csr_remove_actions is
          select 'Y'
          from   dual
          where	not exists(
               select  null
               from    pay_assignment_actions
               where   payroll_action_id = p_payroll_action_id
               and     action_status <> 'C');
begin
        hr_utility.set_location('Entering: ' || c_proc, 10);
        --
        -- If all assignment actions are completed without error, delete all assignment actions.
        --

        open csr_remove_actions;
        fetch csr_remove_actions into l_dummy;
        if csr_remove_actions%found then
          hr_utility.trace('Removing all assignment actions in interlocks table...');
          remove_interlocks(p_payroll_action_id);
--          pay_archive.remove_report_actions(p_payroll_action_id);
          hr_utility.trace('Removed all assignment actions in interlocks table');
        end if;
        close csr_remove_actions;

        --
        hr_utility.set_location('Leaving: ' || c_proc, 20);
end deinitialization_code;
--
END PAY_JP_PRE_TAX_ARCHIVE;

/
