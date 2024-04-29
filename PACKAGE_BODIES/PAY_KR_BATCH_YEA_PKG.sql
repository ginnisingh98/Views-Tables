--------------------------------------------------------
--  DDL for Package Body PAY_KR_BATCH_YEA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_KR_BATCH_YEA_PKG" as
/* $Header: pykrbyea.pkb 120.2 2006/06/12 09:08:17 ssutar noship $ */
--
-- Constants
--
  -- Bug 4442484: Include 'S'kipped assacts in c_range_code
  c_range_cursor	constant varchar2(32767) :=
  'select
             distinct pds.person_id
     from    per_periods_of_service     pds,
             per_assignments_f          asg,
             pay_payroll_actions        ppa
    where    ppa.payroll_action_id = :payroll_action_id
      and    asg.payroll_id = to_number(pay_kr_ff_functions_pkg.get_legislative_parameter(ppa.payroll_action_id, ''PAYROLL_ID'', null))
      and    ppa.effective_date between asg.effective_start_date and asg.effective_end_date
      and    pds.period_of_service_id = asg.period_of_service_id
      and    ppa.effective_date between pds.date_start and nvl(pds.final_process_date, ppa.effective_date)
      and    exists
                   ( select paa.assignment_id
                       from pay_assignment_actions paa
                      where paa.payroll_action_id = to_number(pay_kr_ff_functions_pkg.get_legislative_parameter(ppa.payroll_action_id, ''BAL_ADJ_ACTION_ID'', null))
                        and paa.assignment_id     = asg.assignment_id
                        and paa.action_status     in (''C'', ''S'')
                   )
    order by pds.person_id';
--
-- Global Variables
--
  g_package varchar2(31) := '  pay_kr_batch_yea_pkg.';

  type t_pact is record(
	payroll_action_id	number,
	report_type		pay_payroll_actions.report_type%TYPE,
	report_qualifier	pay_payroll_actions.report_qualifier%TYPE,
	report_category		pay_payroll_actions.report_category%TYPE,
	business_group_id	number,
	effective_date		date,
	payroll_id		number,
	consolidation_set_id	number,
        bal_adj_action_id       number);

  g_pact	t_pact;

  g_debug       boolean  := hr_utility.debug_enabled;
--------------------------------------------------------------------------------
procedure range_code(
		p_payroll_action_id	in number,
		p_sqlstr		out NOCOPY varchar2)
--------------------------------------------------------------------------------
is
begin
	initialization_code(p_payroll_action_id);

	update	pay_payroll_actions
           set  payroll_id           = g_pact.payroll_id
               ,consolidation_set_id = g_pact.consolidation_set_id
	where	payroll_action_id = p_payroll_action_id;

	p_sqlstr := c_range_cursor;

end range_code;
--------------------------------------------------------------------------------
procedure initialization_code(p_payroll_action_id in number)
--------------------------------------------------------------------------------
is
begin
	IF    g_pact.payroll_action_id is null
	   or g_pact.payroll_action_id <> p_payroll_action_id
        THEN
           BEGIN
	        select	ppa.payroll_action_id,
			ppa.report_type,
			ppa.report_qualifier,
			ppa.report_category,
			ppa.business_group_id,
			ppa.effective_date,
			to_number(pay_kr_ff_functions_pkg.get_legislative_parameter(ppa.payroll_action_id, 'BAL_ADJ_ACTION_ID', null))		bal_adj_action_id,
			to_number(pay_kr_ff_functions_pkg.get_legislative_parameter(ppa.payroll_action_id, 'PAYROLL_ID', null))			payroll_id,
			to_number(pay_kr_ff_functions_pkg.get_legislative_parameter(ppa.payroll_action_id, 'CONSOLIDATION_SET_ID', null))	consolidation_set_id
                  --
                into    g_pact.payroll_action_id
                       ,g_pact.report_type
                       ,g_pact.report_qualifier
                       ,g_pact.report_category
                       ,g_pact.business_group_id
                       ,g_pact.effective_date
                       ,g_pact.bal_adj_action_id
                       ,g_pact.payroll_id
                       ,g_pact.consolidation_set_id
                  --
		from	pay_payroll_actions	ppa
		where	ppa.payroll_action_id = p_payroll_action_id;
           END;

	END IF;
end initialization_code;

--------------------------------------------------------------------------------
procedure assignment_action_code(
		p_payroll_action_id	in number,
		p_start_person_id	in number,
		p_end_person_id		in number,
		p_chunk_number		in number)
--------------------------------------------------------------------------------
is
	l_process		boolean;
	l_locking_action_id	number;
        l_locked_action_id      number;
        l_tax_unit_id           number;
	--
	cursor csr_asg(p_payroll_id number)
        IS
		select
                        asg.assignment_id
                    --
		  from	per_assignments_f	 asg,
			per_periods_of_service	 pds,
			pay_payroll_actions	 ppa
                   --
		where	ppa.payroll_action_id    = p_payroll_action_id
		  and	pds.person_id            between p_start_person_id and p_end_person_id
		  and	pds.business_group_id    = ppa.business_group_id
		  and	asg.period_of_service_id = pds.period_of_service_id
		  and	ppa.effective_date       between asg.effective_start_date and asg.effective_end_date
		  and	asg.payroll_id           = p_payroll_id
		--
		-- Exclude if incomplete assacts exist
		--
		  and	not exists(
         	          select  /*+
         	                       ordered
                                       use_nl(ppa2)
                                  */   null
                            from     pay_assignment_actions          paa2,
                                     pay_payroll_actions             ppa2,
                                     pay_action_classifications      pac
                            where	paa2.assignment_id = asg.assignment_id
				and	paa2.action_status not in ('C', 'S') -- Bug 4442484: 'S'kipped assact is not an errored one
				and	paa2.source_action_id is null
				and	ppa2.payroll_action_id = paa2.payroll_action_id
				and	ppa2.effective_date <= ppa.effective_date
				and	pac.action_type = ppa2.action_type
				and	pac.classification_name = 'SEQUENCED')
		--
		-- Exclude if Archival has already been processed.
		--
		and	not exists(
				select	null
				from	pay_payroll_actions	ppa4,
					pay_assignment_actions	paa4
				where	paa4.assignment_id = asg.assignment_id
				and	paa4.source_action_id is null
				and	ppa4.payroll_action_id = paa4.payroll_action_id
				and	ppa4.action_type IN ('X','B')
				and	ppa4.report_type = 'YEA'
				and	ppa4.report_qualifier = 'KR'
				and	ppa4.report_category in ('N', 'I')
				and	trunc(ppa4.effective_date, 'YYYY') = trunc(ppa.effective_date, 'YYYY'))
		--
		-- Include if BA has been processed
		--
	        and    exists (
	        	     select null
			     from   pay_assignment_actions paa6
			     where  paa6.payroll_action_id = to_number(pay_kr_ff_functions_pkg.get_legislative_parameter(ppa.payroll_action_id, 'BAL_ADJ_ACTION_ID', null))
			     and    paa6.assignment_id     = asg.assignment_id
			     and    paa6.action_status     in ('C', 'S')) -- Bug 4442484: Include 'S'kipped assacts
                --
		for update of pds.period_of_service_id, asg.assignment_id;
                -----------------------------------------------------------------------------------
                Cursor csr_bal_asg(p_bal_adj_action_id   number,
                                   p_assignment_id       number  )
                IS
                    Select   asg.assignment_action_id
                            ,asg.tax_unit_id
                      from   pay_assignment_actions asg
                     where   asg.payroll_action_id = p_bal_adj_action_id
                       and   asg.assignment_id     = p_assignment_id
                       and   asg.action_status     in ('C', 'S') ; -- Bug 4442484: Include 'S'kipped assacts
                ------------------------------------------------------------------------------------

begin
   initialization_code(p_payroll_action_id);
   --
   for l_asg in csr_asg(g_pact.payroll_id)
   loop
	select	pay_assignment_actions_s.nextval
	into	l_locking_action_id
	from	dual;
	--
        open csr_bal_asg(g_pact.bal_adj_action_id, l_asg.assignment_id);
        fetch csr_bal_asg  into  l_locked_action_id, l_tax_unit_id;
        close csr_bal_asg;
        --
        IF l_locked_action_id is null THEN
           fnd_message.set_name('PAY', 'PAY_KR_INCOMP_ASSACT_EXISTS');
           fnd_message.raise_error;
        END IF;

	hr_nonrun_asact.insact(l_locking_action_id,
	                       l_asg.assignment_id,
	                       p_payroll_action_id,
	                       p_chunk_number,
	                       l_tax_unit_id);

        hr_nonrun_asact.insint( LOCKINGACTID => l_locking_action_id,
                                LOCKEDACTID  => l_locked_action_id  );

   end loop;
end assignment_action_code;
--------------------------------------------------------------------------------
procedure reyea_assignment_action_code(
		p_payroll_action_id	in number,
		p_start_person_id	in number,
		p_end_person_id		in number,
		p_chunk_number		in number)
--------------------------------------------------------------------------------
is
	l_process		boolean;
	l_locking_action_id	number;
        l_locked_action_id      number;
        l_tax_unit_id           number;
	--
	cursor csr_asg(p_payroll_id number)
        IS
		select
			asg.assignment_id
                    --
		  from	per_assignments_f		asg,
			per_periods_of_service		pds,
			pay_payroll_actions		ppa
                   --
		where	ppa.payroll_action_id     =        p_payroll_action_id
		  and	pds.person_id             between  p_start_person_id and p_end_person_id
		  and	pds.business_group_id     =        ppa.business_group_id
		  and	asg.period_of_service_id  =        pds.period_of_service_id
		  and	ppa.effective_date        between  asg.effective_start_date and asg.effective_end_date
		  and	asg.payroll_id            =        p_payroll_id
		--
		-- Exclude if incomplete assacts exist
		--
		and	not exists(
				select  /*+
         	                       ordered
                                       use_nl(ppa2)
                                  */   null
                            from     pay_assignment_actions          paa2,
                                     pay_payroll_actions             ppa2,
                                     pay_action_classifications      pac
				where	paa2.assignment_id = asg.assignment_id
				and	paa2.action_status not in ('C', 'S') -- Bug 4442484: 'S'kipped assact is not an errored one
				and	paa2.source_action_id is null
				and	ppa2.payroll_action_id = paa2.payroll_action_id
				and	ppa2.effective_date <= ppa.effective_date
				and	pac.action_type = ppa2.action_type
				and	pac.classification_name = 'SEQUENCED')
		--
		-- Include if Normal / Interim archive has been processed.
		--
		and	exists(
				select	null
				from	pay_payroll_actions	ppa4,
					pay_assignment_actions	paa4
				where	paa4.assignment_id = asg.assignment_id
				and	paa4.source_action_id is null
				and	ppa4.payroll_action_id = paa4.payroll_action_id
				and	ppa4.action_type IN ('X','B')
				and	ppa4.report_type = 'YEA'
				and	ppa4.report_qualifier = 'KR'
				and	ppa4.report_category in ('N', 'I')
				and	trunc(ppa4.effective_date, 'YYYY') = trunc(ppa.effective_date, 'YYYY'))
		--
		-- Exclude if future YEA in the same calendar year exists.
		--
		and	not exists(
				select	null
				from	pay_payroll_actions	ppa3,
					pay_assignment_actions	paa3
				where	paa3.assignment_id     =  asg.assignment_id
				and	paa3.source_action_id  is null
				and	ppa3.payroll_action_id =  paa3.payroll_action_id
				and	ppa3.effective_date    >  ppa.effective_date
				and	ppa3.effective_date    <  add_months(trunc(ppa.effective_date, 'YYYY'), 12)
				and	ppa3.action_type       IN ('X','B')
				and	ppa3.report_type       =  'YEA'
				and	ppa3.report_qualifier  =  'KR')
		--
		-- Include if BA has been processed
		--
	        and    exists (
	        	     select null
			     from   pay_assignment_actions paa6
			     where  paa6.payroll_action_id = to_number(pay_kr_ff_functions_pkg.get_legislative_parameter(ppa.payroll_action_id, 'BAL_ADJ_ACTION_ID', null))
			     and    paa6.assignment_id     = asg.assignment_id
			     and    paa6.action_status     in ('C', 'S')) -- Bug 4442484: Include 'S'kipped assacts
                --
		for update of pds.period_of_service_id, asg.assignment_id;

                Cursor csr_bal_asg(p_bal_adj_action_id   number,
                                   p_assignment_id       number  )
                IS
                    Select asg.assignment_action_id
                          ,asg.tax_unit_id
                      from pay_assignment_actions asg
                     where asg.payroll_action_id = p_bal_adj_action_id
                       and asg.assignment_id     = p_assignment_id
                       and asg.action_status     in ('C', 'S'); -- Bug 4442484: Include 'S'kipped assacts

begin
   initialization_code(p_payroll_action_id);
   --
   for l_asg in csr_asg(g_pact.payroll_id) loop
        select	pay_assignment_actions_s.nextval
	into	l_locking_action_id
	from	dual;
	--
        open csr_bal_asg(g_pact.bal_adj_action_id, l_asg.assignment_id);
        fetch csr_bal_asg  into  l_locked_action_id, l_tax_unit_id;
        close csr_bal_asg;

        IF l_locked_action_id is null THEN
           fnd_message.set_name('PAY', 'PAY_KR_INCOMP_ASSACT_EXISTS');
           fnd_message.raise_error;
        END IF;

	hr_nonrun_asact.insact(l_locking_action_id,
	                       l_asg.assignment_id,
	                       p_payroll_action_id,
	                       p_chunk_number,
	                       l_tax_unit_id);

        hr_nonrun_asact.insint( LOCKINGACTID => l_locking_action_id,
                                LOCKEDACTID  => l_locked_action_id  );

   end loop;
end reyea_assignment_action_code;
--------------------------------------------------------------------------------
procedure archive_code(
		p_assignment_action_id	in number,
		p_effective_date	in date)
--------------------------------------------------------------------------------
is
	l_proc_name		varchar2(61) := 'archive_code';
	l_assignment_id		number;
	l_bal_adj_asg_action_id number;
        l_archive_type_used     varchar2(10); -- Bug 5225198

        Cursor csr_bal_asg(p_bal_adj_action_id   	number,
                           p_assignment_action_id       number  )
        IS
          Select   asg_b.assignment_action_id
                  ,asg_b.assignment_id
            from   pay_assignment_actions asg
                  ,pay_assignment_actions asg_b
           where   asg_b.payroll_action_id  = p_bal_adj_action_id
             and   asg_b.assignment_id      = asg.assignment_id
             and   asg.assignment_action_id = p_assignment_action_id
             and   asg_b.action_status      in ('C', 'S') ; -- Bug 4442484: Include 'S'kipped assacts
begin
	--
	if g_debug then
	   hr_utility.set_location(l_proc_name, 10);
	end if;
	--
	open csr_bal_asg(g_pact.bal_adj_action_id, p_assignment_action_id);
	fetch csr_bal_asg  into  l_bal_adj_asg_action_id, l_assignment_id;
        close csr_bal_asg;
	--
	if g_debug then
	   hr_utility.set_location(l_proc_name, 20);
	   hr_utility.trace('Assignment Id : '||to_char(l_assignment_id));
	   hr_utility.trace('Balance Adjustment Assignment Action Id : '||to_char(l_bal_adj_asg_action_id));
	end if;
	--
        -- Bug 5225198
        l_archive_type_used := pay_kr_ff_functions_pkg.get_legislative_parameter(
                                         g_pact.payroll_action_id, 'ARCHIVE_TYPE', 'AAC');

	pay_kr_yea_pkg.process_assignment(
		p_validate		=> false,
		p_business_group_id	=> g_pact.business_group_id,
		p_assignment_id		=> l_assignment_id,
		p_assignment_action_id	=> p_assignment_action_id,
		p_bal_asg_action_id	=> l_bal_adj_asg_action_id,
		p_report_type		=> g_pact.report_type,
		p_report_qualifier	=> g_pact.report_qualifier,
		p_report_category	=> g_pact.report_category,
		p_effective_date	=> g_pact.effective_date,
		p_payroll_id		=> g_pact.payroll_id,
		p_consolidation_set_id	=> g_pact.consolidation_set_id,
                p_archive_type_used     => l_archive_type_used);  -- Bug 5036734
	--
	if g_debug then
	   hr_utility.set_location(l_proc_name, 30);
	end if;
	--
end archive_code;
--
end pay_kr_batch_yea_pkg;

/
