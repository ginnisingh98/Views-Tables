--------------------------------------------------------
--  DDL for Package Body PAY_KR_PROCESS_NAV_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_KR_PROCESS_NAV_PKG" AS
/* $Header: pykrpnav.pkb 120.0 2005/05/29 06:27:58 appldev noship $ */
	g_item_type				constant varchar2(10)  := 'KRPAYNAV' ;
	g_item_key				varchar2(20) ;
	g_process_name				varchar2(20) ;
	g_debug					constant boolean := hr_utility.debug_enabled;
	procedure submit_workflow (
		-- The usual, first two parameters
		p_errbuf			out nocopy	varchar2,
		p_retcode			out nocopy	number,
		--
		-- The parameters for actual workflow
		p_business_place_id_notifier	in		number,		-- the business place to be notified
		p_payroll_id			in		number,		-- the payroll id
		p_consolidation_set_id		in		number,		-- the consolidation set id
		--
		-- For BEE
		p_run_bee			in		varchar2,	-- To run BEE ('Y'), or not ('N)
		p_batch_id			in		number, 	-- the batch id
		--
		-- For Retro-Notifications
		p_run_retro_notf		in		varchar2,	-- To run Retro-Notifications ('Y'), or not ('N)
		p_effective_date_retro_notf	in		varchar2,	-- effective date for retro-notifications
		p_event_group			in		varchar2,	-- event group
		p_gen_assignment_set_name	in		varchar2,	-- the generated assignment set name
		--
		-- For RetroPay
		p_run_retro			in		varchar2,	-- To run RetroPay ('Y'), or not ('N')
		p_retro_assignment_set_id	in		number,		-- the assignment set id for retro pay
		p_retro_element_set_id		in		number, 	-- the element set id for retro pay
		p_retro_start_date		in		varchar2,	-- the start date for retro pay
		p_retro_effective_date		in		varchar2,	-- the end date for retro pay
		--
		-- For Monthly/Bonus Payroll
		p_run_monthly_bonus		in		varchar2,	-- To run Monthly Payroll/Bonus ('Y'), or not ('N')
		p_date_earned			in		varchar2,	-- the date earned
		p_date_paid			in		varchar2,	-- the paid date
		p_element_set_id		in		number,		-- the element set id
		p_assignment_set_id		in		number,		-- the assignment set id
		p_run_type_id			in		number,		-- the run type id
		p_bonus_start_date		in		varchar2,	-- the bonus period start date
		p_additional_tax_rate		in		number,		-- additional tax rate for bonus pay
		p_overriding_tax_rate		in		number,		-- overriding tax rate for bonus pay
		p_payout_date			in		varchar2,	-- the payout date
		--
		-- For Prepayments
		p_run_prepayment		in		varchar2,	-- To run prepayments ('Y'), or not ('N')
		p_prepayment_start_date		in		varchar2,	-- the start date for prepayment run
		p_prepayment_end_date		in		varchar2,	-- the end date for prepayment run
		p_payment_method_override	in		number,		-- the override payment method
		--
		-- For Bank Transfer
		p_run_bank_transfer		in		varchar2,	-- To run bank transfer ('Y'), or not ('N')
		p_direct_deposit_start_date	in		varchar2,	-- the start date for bank transfer
		p_direct_deposit_end_date	in		varchar2,	-- the end date for bank transfer
		p_direct_deposit_date		in		varchar2,	-- the date for direct deposit
		p_payment_method		in		number,		-- the payment method
		p_characterset			in		varchar2,	-- the characterset
		--
		-- For Payslip Archive
		p_run_payslip_archive		in		varchar2,	-- To run payslip archive ('Y'), or not ('N')
		p_archive_start_date		in		varchar2, 	-- the start date for payslip archive
		p_archive_end_date		in		varchar2,	-- the end date for payslip archive
		--
		-- For payslip report
		p_run_payslip_report		in		varchar2,	-- To run payslip report ('Y'), or not ('N')
		p_run_type_period		in		varchar2,	-- the run_type or period
		p_business_place_id		in		number,		-- the business place id
                p_sort_order1                   in              varchar2,       -- Sort Order 1 for Payslip Report
                p_sort_order2                   in              varchar2,       -- Sort Order 2 for Payslip Report		-- For costing
		p_run_costing			in		varchar2,	-- To run payslip report ('Y'), or not ('N')
		p_costing_start_date		in		varchar2,	-- the start date for costing run
		p_costing_end_date		in		varchar2,	-- the end date for costing run
		--
		-- Parameters that are not displayed
		p_act_param_group_id		in		number		-- action parameter group id
	) is
--
		l_payment_type_id		pay_payment_types.payment_type_id%TYPE ;
		l_business_group_id		per_business_groups.business_group_id%TYPE ;
		l_run_type_name			pay_run_types_f_tl.run_type_name%TYPE ;
		l_bonus_start_date_hd		varchar2(200) ;	-- the bonus period start date (hidden)
		l_additional_tax_rate_hd	varchar2(200) ;	-- additional tax rate for bonus pay (hidden)
		l_overriding_tax_rate_hd	varchar2(200) ;	-- overriding tax rate for bonus pay (hidden)
		l_payout_date_hd		varchar2(200) ;	-- the payout date (hidden)
		l_characterset_hd		varchar2(200) ;	-- the characterset (hidden)
		l_payroll_retro_notf_hd		varchar2(200) ; -- for retro-notifications
		l_retro_notf_start_date_dmy	varchar2(200) ; -- dummy start date for retro-notifications
		l_gen_assignment_set_name_dmy	varchar2(200) ; -- dummy assignment set name for retro-notifications
		l_payroll_hd			varchar2(200) ;	-- legislative, for payslip archive
		l_consolidation_set_hd		varchar2(200) ;	-- legislative, for payslip archive
		l_archive_start_date_hd		varchar2(200) ;	-- legislative, for payslip archive
		l_archive_end_date_hd		varchar2(200) ;	-- legislative, for payslip archive
		l_business_group_hd		varchar2(200) ;	-- legislative, for payslip archive
		l_hr_payroll_contact_source	varchar2(80)  ; -- has either GRE/PAYROLL/CUSTOM, depending on which we look for the performer
		l_performer_name		fnd_user.user_name%TYPE ;
		l_payroll_name			pay_all_payrolls_f.payroll_name%TYPE;
		l_consolidation_set_name	pay_consolidation_sets.consolidation_set_name%TYPE ;
		l_retro_assignment_set_name	hr_assignment_sets.assignment_set_name%TYPE ;
		l_retro_element_set_name	pay_element_sets.element_set_name%TYPE ;
		l_element_set_name		pay_element_sets.element_set_name%TYPE ;
		l_assignment_set_name		hr_assignment_sets.assignment_set_name%TYPE ;
		l_payment_method_override_name	PAY_ORG_PAYMENT_METHODS_F.org_payment_method_name%TYPE ;
		l_payment_method_name		PAY_ORG_PAYMENT_METHODS_F.org_payment_method_name%TYPE ;
		l_business_place_name		hr_all_organization_units.name%TYPE ;
		l_retro_notf_event_group_name	pay_event_groups.event_group_name%TYPE ;
		l_sort_order1_disp		hr_lookups.meaning%TYPE ;
		l_sort_order2_disp		hr_lookups.meaning%TYPE ;
		l_eff_date_retro_notf_disp	varchar2(200) ;
		l_run_type_period_name_disp	varchar2(400) ;
		--
		TYPE char80_table 		IS TABLE OF VARCHAR2(80) INDEX BY BINARY_INTEGER ;
		l_conc_prog_name_tbl		char80_table ;
		l_cur_process_tbl		char80_table ;
		--
		l_num_var_name_tbl		wf_engine.NameTabTyp ;
		l_text_var_name_tbl		wf_engine.NameTabTyp ;
		l_num_var_value_tbl		wf_engine.NumTabTyp ;
		l_text_var_value_tbl		wf_engine.TextTabTyp ;
		--
		n				number(3) := 1 ;
		i				number(3) := 1 ;
		--
		l_prc_list			VARCHAR2(3200) ;
		l_message_text1			VARCHAR2(3200) ;
		l_message_html2			VARCHAR2(3200) ;
		l_cur_time			varchar2(25) ;
		--
		cursor csr_gre_performer is
			select		org_information2
			from		hr_organization_information
			where		organization_id = p_business_place_id
			and		org_information_context = 'KR_BP_PAYROLL_PARAMETERS';
		--
		cursor csr_payroll_performer is
			select		prl_information8
			from		pay_payrolls_f
			where		payroll_id = p_payroll_id
			and		prl_information_category = 'KR'
			and 		sysdate between effective_start_date and effective_end_date ;
		--
		cursor csr_payment_type is
			select		payment_type_id
			from		pay_payment_types
			where		payment_type_name = 'KR Direct Deposit' ;
		--
		cursor csr_payroll_name is
			select 		payroll_name
			from 		pay_all_payrolls_f
			where 		payroll_id = p_payroll_id
			and		rownum = 1 ;
		--
		cursor csr_consolidation_set_name is
			select 		consolidation_set_name
			from 		pay_consolidation_sets
			where		consolidation_set_id = p_consolidation_set_id ;
		--
		cursor csr_assignment_set_name(p_asg_set_id   in   number) is
			select 		assignment_set_name
			from 		hr_assignment_sets
			where 		assignment_set_id = p_asg_set_id ;
		--
		cursor csr_element_set_name(p_ele_set_id   in   number) is
			select 		element_set_name
			from 		pay_element_sets
			where 		element_set_id = p_ele_set_id ;
		--
		cursor csr_run_type_name_tl is
			select		run_type_name
			from 		pay_run_types_f_tl
			where 		run_type_id = p_run_type_id
			and		language = userenv('LANG') ;
		--
		cursor csr_run_type_name is
			select		run_type_name
			from 		pay_run_types_f
			where 		run_type_id = p_run_type_id;
		--
		cursor csr_payment_method (p_pay_method   in   number) is
			select 		org_payment_method_name
			from 		pay_org_payment_methods_f_tl
			where		org_payment_method_id = p_pay_method
			and		language = userenv('LANG') ;
		--
		cursor csr_business_place_name is
			select 		org_information1 business_place_name
			from 		hr_organization_information
			where 		org_information_context = 'KR_BUSINESS_PLACE_REGISTRATION'
			and		organization_id = p_business_place_id ;
		--
		cursor csr_bonus_start_date is
			select		'BONUS_PERIOD_START_DATE=' ||
					 fnd_date.date_to_canonical(
						greatest(fnd_date.canonical_to_date(p_bonus_start_date),
						         trunc(fnd_date.canonical_to_date(p_date_earned), 'YYYY')
					                )
				         ) a_bonus_start_date_hd
			from		dual;
		--
		cursor csr_prog_name(short_name 	in 	varchar2) is
			select		user_concurrent_program_name
			from		fnd_concurrent_programs_tl
			where		concurrent_program_id =
					(
						select	concurrent_program_id
						from	fnd_concurrent_programs
						where	concurrent_program_name = short_name
						and	application_id in (800, 801)
					)
			and		language = userenv('LANG') ;
		--
		cursor csr_event_group_name is
			select 		event_group_name
			from 		pay_event_groups
			where		event_group_id = to_number(substr(p_event_group, 12)) ;
		--
		cursor csr_run_type_period_name is
			select 		run_type_name||'-'||ptp.period_name||'-'||ppa.payroll_action_id	run_type_period_name
			from 		pay_payroll_actions 	ppa,
					pay_payroll_actions     rppa,
					pay_assignment_actions  paa,
					pay_assignment_actions  rpaa,
					pay_action_interlocks   pai,
					pay_run_types_f 	prt,
					per_time_periods 	ptp
			where 		ppa.payroll_action_id = p_run_type_period
			and		paa.payroll_action_id = ppa.payroll_action_id
			and		ppa.action_type in ('P','U')
			and		ppa.action_status = 'C'
			and		rppa.action_type in ('Q','R')
			and		rppa.action_status = 'C'
			and		rpaa.payroll_action_id = rppa.payroll_action_id
			and		rpaa.assignment_id = paa.assignment_id
			and		pai.locking_action_id = paa.assignment_action_id
			and		pai.locked_action_id  = rpaa.assignment_action_id
			and		ppa.effective_date >= rppa.effective_date
			and 		rpaa.run_type_id       = prt.run_type_id
			and 		rppa.time_period_id    = ptp.time_period_id
			and             ppa.payroll_action_id = paa.payroll_action_id
			and             rpaa.assignment_action_id = (select max(paa_locked.assignment_action_id)
								    from   pay_assignment_actions paa_locked,
									   pay_action_interlocks  pai_locking
								    where  pai_locking.locking_action_id =
										(select max(paa1.assignment_action_id)
										   from pay_assignment_actions paa1
										  where paa1.payroll_action_id = ppa.payroll_action_Id)
								      and  paa_locked.assignment_action_id = pai_locking.locked_action_id)
			and		ppa.effective_date between prt.effective_start_date and prt.effective_end_date
			and		rppa.effective_date between ptp.start_date and ptp.end_date;
		--
		cursor csr_sort_names(p_lookup_code in varchar2) is
			select		meaning
			from		hr_lookups
			where		lookup_code = p_lookup_code
			and		lookup_type = 'KR_SOE_SORT_BY';
--
begin
		--
		if g_debug then
			hr_utility.trace('Getting into submit_workflow') ;
		end if ;
		--
		-- initialise current time
		l_cur_time := to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS') ;
		--
		--
		if g_debug then
			hr_utility.trace('Current date and time is ' || l_cur_time ) ;
		end if ;
		--
		l_performer_name := '' ;
		--
		-- Initialize item key value.
		--
		select		to_char(sysdate, 'YYYYMMDD-HH24MISS')
		into		g_item_key
		from		dual ;
		--
		if g_debug then
			hr_utility.trace('Initialized item type and item key') ;
		end if ;
		--
		-- Initialize process name
		--
		g_process_name 	:= 'KR_PAY_PROCESS' ;
	        --
		-- Initialize concurrent programs list
		--
		for cur in csr_prog_name('PAYLINK(TRANSFER)') loop
			l_conc_prog_name_tbl(1) := cur.user_concurrent_program_name;
		end loop ;
		for cur in csr_prog_name('PAYRPRNP') loop
			l_conc_prog_name_tbl(2) := cur.user_concurrent_program_name;
		end loop ;
		for cur in csr_prog_name('RETROELE') loop
			l_conc_prog_name_tbl(3) := cur.user_concurrent_program_name;
		end loop ;
		for cur in csr_prog_name('PAYKRMTH') loop
			l_conc_prog_name_tbl(4) := cur.user_concurrent_program_name;
		end loop ;
		for cur in csr_prog_name('PAYKRBON') loop
			l_conc_prog_name_tbl(5) := cur.user_concurrent_program_name;
		end loop ;
		for cur in csr_prog_name('PREPAY') loop
			l_conc_prog_name_tbl(6) := cur.user_concurrent_program_name;
		end loop ;
		for cur in csr_prog_name('PAYKRMAG') loop
			l_conc_prog_name_tbl(7) := cur.user_concurrent_program_name;
		end loop ;
		for cur in csr_prog_name('PYKRPSAC') loop
			l_conc_prog_name_tbl(8) := cur.user_concurrent_program_name;
		end loop ;
		for cur in csr_prog_name('PAYKRSOE') loop
			l_conc_prog_name_tbl(9) := cur.user_concurrent_program_name;
		end loop ;
		for cur in csr_prog_name('COSTING') loop
			l_conc_prog_name_tbl(10) := cur.user_concurrent_program_name;
		end loop ;
		--
		if g_debug then
			hr_utility.trace('Initialised concurrent program list. Now creating workflow...') ;
		end if ;
		--
		-- Create the workflow process
		--
		wf_engine.createprocess(
			ITEMTYPE	=>	g_item_type,
			ITEMKEY		=>	g_item_key,
			PROCESS		=>	g_process_name
		) ;
		--
		if g_debug then
			hr_utility.trace('Created workflow, itemtype '|| g_item_type || ', itemkey ' || g_item_key || ', process ' || g_process_name) ;
		end if ;
		--
		-- initialize the security
		--
		hr_signon.initialize_hr_security ;
		--
		-- Set the performer
		--
		if p_business_place_id_notifier is not null then -- look into Org Developer DF for the performer
			open  		csr_gre_performer ;
			fetch 		csr_gre_performer into l_performer_name ;
			close 		csr_gre_performer ;
			--
			if g_debug then
				hr_utility.trace('Got performer ' || l_performer_name || ' from Org Developer DF flex') ;
			end if ;
			--
		else  -- look into Further Payroll Information DFF for the performer
			open  		csr_payroll_performer ;
			fetch 		csr_payroll_performer into l_performer_name ;
			close 		csr_payroll_performer ;
			--
			if g_debug then
				hr_utility.trace('Got performer ' || l_performer_name || ' from Further Payroll Information flex') ;
			end if ;
			--
		end if ;

		-- Default to SYSADMIN

		if l_performer_name is null then
			l_performer_name := 'SYSADMIN' ;
			--
			if g_debug then
				hr_utility.trace('Got performer ' || l_performer_name || ' as default') ;
			end if ;
			--
		end if ;

		/*
		 * Check for parameters required by specific processes. If they are not all provided, set the to_run flag
		 * for that process to 'N'.
		 */
		-- Initialize to 'Y'
		wf_engine.setItemAttrText(g_item_type, g_item_key, 'TO_RUN_BEE', 'Y') ;
		wf_engine.setItemAttrText(g_item_type, g_item_key, 'TO_RUN_RETRO', 'Y') ;
		wf_engine.setItemAttrText(g_item_type, g_item_key, 'TO_RUN_MONTHLY_PAYROLL', 'Y') ;
		wf_engine.setItemAttrText(g_item_type, g_item_key, 'TO_RUN_BONUS', 'Y') ;
		wf_engine.setItemAttrText(g_item_type, g_item_key, 'TO_RUN_PREPAYMENTS', 'Y') ;
		wf_engine.setItemAttrText(g_item_type, g_item_key, 'TO_RUN_BANK_TRANSFER', 'Y') ;
		wf_engine.setItemAttrText(g_item_type, g_item_key, 'TO_RUN_PAYSLIP_ARCHIVE', 'Y') ;
		wf_engine.setItemAttrText(g_item_type, g_item_key, 'TO_RUN_COSTING', 'Y') ;
		wf_engine.setItemAttrText(g_item_type, g_item_key, 'TO_RUN_PAYSLIP', 'Y') ;
		wf_engine.setItemAttrText(g_item_type, g_item_key, 'TO_RUN_RETRO_NOTF', 'Y') ;
		--
		l_message_html2 := 'WF_NOTIFICATION(ATTRS';
		--
		-- Setting flags for concurrent processes to be run
		-- Check for BEE
		--
		if p_run_bee <> 'Y' OR p_batch_id is NULL then
			wf_engine.setItemAttrText(g_item_type, g_item_key, 'TO_RUN_BEE', 'N') ;
		else
			--
			if g_debug then
				hr_utility.trace('Will run BEE') ;
			end if ;
			--
			l_prc_list           := l_prc_list||l_conc_prog_name_tbl(1)||wf_core.newline;
			l_cur_process_tbl(n) := l_conc_prog_name_tbl(1);
			l_message_html2 := l_message_html2||',MSG_ATTR'||to_char(n);
			n := n + 1;
		end if ;
		--
		-- Check for Retro-Notifications
		--
		if p_run_retro_notf <> 'Y' OR trim(p_effective_date_retro_notf) is NULL OR trim(p_event_group) is NULL OR trim(p_gen_assignment_set_name) is NULL then
			wf_engine.setItemAttrText(g_item_type, g_item_key, 'TO_RUN_RETRO_NOTF', 'N') ;
		else
			--
			if g_debug then
				hr_utility.trace('Will run Retro-Notifications') ;
			end if ;
			--
			for rec in csr_event_group_name loop
				l_retro_notf_event_group_name := rec.event_group_name ;
			end loop ;
			l_eff_date_retro_notf_disp := substr(p_effective_date_retro_notf, 10) ;
			l_prc_list           := l_prc_list||l_conc_prog_name_tbl(2)||wf_core.newline;
			l_cur_process_tbl(n) := l_conc_prog_name_tbl(2);
			l_message_html2 := l_message_html2||',MSG_ATTR'||to_char(n);
			n := n + 1;
		end if ;
		--
		-- Check for RetroPay
		--
		if p_run_retro <> 'Y' OR trim(p_retro_effective_date) is NULL OR p_retro_assignment_set_id is NULL then
			wf_engine.setItemAttrText(g_item_type, g_item_key, 'TO_RUN_RETRO', 'N') ;
		else
			--
			if g_debug then
				hr_utility.trace('Will run RetroPay') ;
			end if ;
			--
			for rec in csr_assignment_set_name(p_retro_assignment_set_id) loop
				l_retro_assignment_set_name := rec.assignment_set_name ;
			end loop ;
			--
			for rec in csr_element_set_name(p_retro_element_set_id) loop
				l_retro_element_set_name := rec.element_set_name ;
			end loop ;
			--
			l_prc_list           := l_prc_list||l_conc_prog_name_tbl(3)||wf_core.newline;
			l_cur_process_tbl(n) := l_conc_prog_name_tbl(3);
			l_message_html2 := l_message_html2||',MSG_ATTR'||to_char(n);
			n := n + 1;
		end if ;
		--
		-- Check for Monthly/Bonus Payroll
		--
		if p_run_monthly_bonus <> 'Y' OR p_payroll_id is NULL OR p_consolidation_set_id is NULL OR trim(p_date_earned) is NULL OR trim(p_date_paid) is NULL OR p_run_type_id is NULL then
		   	wf_engine.setItemAttrText(g_item_type, g_item_key, 'TO_RUN_MONTHLY_PAYROLL', 'N') ;
			wf_engine.setItemAttrText(g_item_type, g_item_key, 'TO_RUN_BONUS', 'N') ;
		else
			--
			for rec in csr_assignment_set_name(p_assignment_set_id) loop
				l_assignment_set_name := rec.assignment_set_name ;
			end loop ;
			--
			for rec in csr_element_set_name(p_element_set_id) loop
				l_element_set_name := rec.element_set_name ;
			end loop ;
			--
			-- Decide between monthly payroll process and bonus payroll process.
		 	--
			open csr_run_type_name;
			fetch csr_run_type_name into l_run_type_name;
			close csr_run_type_name;
			--
			if l_run_type_name like 'BON%' then
				--
				if g_debug then
					hr_utility.trace('Will run Bonus') ;
				end if ;
				--
				for rec in csr_bonus_start_date loop
					l_bonus_start_date_hd := rec.a_bonus_start_date_hd ;
				end loop ;
				wf_engine.setItemAttrText(g_item_type, g_item_key, 'TO_RUN_MONTHLY_PAYROLL', 'N') ;
				--
				l_prc_list           := l_prc_list||l_conc_prog_name_tbl(5)||wf_core.newline;
				l_cur_process_tbl(n) := l_conc_prog_name_tbl(5);
				l_message_html2 := l_message_html2||',MSG_ATTR'||to_char(n);
				n := n + 1;

			elsif l_run_type_name = 'MTH' then
				--
				if g_debug then
					hr_utility.trace('Will run Monthly Payroll') ;
				end if ;
				--
				wf_engine.setItemAttrText(g_item_type, g_item_key, 'TO_RUN_BONUS', 'N') ;
				--
				l_prc_list           := l_prc_list||l_conc_prog_name_tbl(4)||wf_core.newline;
				l_cur_process_tbl(n) := l_conc_prog_name_tbl(4);
				l_message_html2 := l_message_html2||',MSG_ATTR'||to_char(n);
				n := n + 1;

			end if ;
			--
			-- fill in the translated value in run type
			for rec in csr_run_type_name_tl loop
				l_run_type_name := rec.run_type_name ;
			end loop ;
			--
		end if ;
		--
		-- Check for Prepayments
		--
		if p_run_prepayment <> 'Y' OR p_payroll_id is NULL OR p_consolidation_set_id is NULL OR trim(p_prepayment_end_date) is NULL then
			wf_engine.setItemAttrText(g_item_type, g_item_key, 'TO_RUN_PREPAYMENTS', 'N') ;
		else
			--
			if g_debug then
				hr_utility.trace('Will run PrePayments') ;
			end if ;
			--
			for rec in csr_payment_method(p_payment_method_override) loop
				l_payment_method_override_name := rec.org_payment_method_name ;
			end loop ;
			--
			l_prc_list           := l_prc_list||l_conc_prog_name_tbl(6)||wf_core.newline;
			l_cur_process_tbl(n) := l_conc_prog_name_tbl(6);
			l_message_html2 := l_message_html2||',MSG_ATTR'||to_char(n);
			n := n + 1;
		end if ;
		--
		-- Check for KR Bank Transfer
		--
		if p_run_bank_transfer <> 'Y' OR p_consolidation_set_id is NULL OR trim(p_direct_deposit_start_date) is NULL OR trim(p_direct_deposit_end_date) is NULL OR trim(p_direct_deposit_date) is NULL OR trim(p_characterset) is NULL then
		 	wf_engine.setItemAttrText(g_item_type, g_item_key, 'TO_RUN_BANK_TRANSFER', 'N') ;
		else
			--
			if g_debug then
				hr_utility.trace('Will run Bank Transfer') ;
			end if ;
			--
			for rec in csr_payment_method(p_payment_method) loop
				l_payment_method_name := rec.org_payment_method_name ;
			end loop ;
			--

			l_prc_list           := l_prc_list||l_conc_prog_name_tbl(7)||wf_core.newline;
			l_cur_process_tbl(n) := l_conc_prog_name_tbl(7);
			l_message_html2 := l_message_html2||',MSG_ATTR'||to_char(n);
			n := n + 1;
		end if ;
		--
		-- Check for Payslip Archive
		--
		if p_run_payslip_archive <> 'Y' OR p_payroll_id is NULL OR p_consolidation_set_id is NULL OR trim(p_archive_start_date) is NULL OR trim(p_archive_end_date) is NULL then
		  	wf_engine.setItemAttrText(g_item_type, g_item_key, 'TO_RUN_PAYSLIP_ARCHIVE', 'N') ;
		else
			--
			if g_debug then
				hr_utility.trace('Will run Payslip Archive') ;
			end if ;
			--
			l_prc_list           := l_prc_list||l_conc_prog_name_tbl(8)||wf_core.newline;
			l_cur_process_tbl(n) := l_conc_prog_name_tbl(8);
			l_message_html2 := l_message_html2||',MSG_ATTR'||to_char(n);
			n := n + 1;
		end if ;
		--
		-- Check for Payslip Report
		--
		if p_run_payslip_report <> 'Y' OR p_business_place_id is NULL then
		  	wf_engine.setItemAttrText(g_item_type, g_item_key, 'TO_RUN_PAYSLIP', 'N') ;
			--
		elsif trim(p_run_type_period) is NULL and wf_engine.getItemAttrText(g_item_type, g_item_key, 'TO_RUN_PREPAYMENTS') = 'N' then
			wf_engine.setItemAttrText(g_item_type, g_item_key, 'TO_RUN_PAYSLIP', 'N') ;
			--
		else
			--
			if g_debug then
				hr_utility.trace('Will run Payslip Report') ;
			end if ;
			--
			if trim(p_run_type_period) is not NULL then
				--
				if g_debug then
					hr_utility.trace('Got Payslip Runtype Payroll Action Id = '||p_run_type_period || ' from parameter Run Type/Period');
				end if ;
				--
				for rec in csr_run_type_period_name loop
					l_run_type_period_name_disp := rec.run_type_period_name ;
				end loop ;
				--
				if g_debug then
					hr_utility.trace('Run Type/Period : '||l_run_type_period_name_disp);
				end if;
				--
			end if ;
			--
			if trim(p_sort_order1) is not null then
				for rec in csr_sort_names(p_sort_order1) loop
					l_sort_order1_disp := rec.meaning ;
				end loop ;
			end if ;
			--
			if trim(p_sort_order2) is not null then
				for rec in csr_sort_names(p_sort_order2) loop
					l_sort_order2_disp := rec.meaning ;
				end loop ;
			end if ;
			--
			l_prc_list           := l_prc_list||l_conc_prog_name_tbl(9)||wf_core.newline;
			l_cur_process_tbl(n) := l_conc_prog_name_tbl(9);
			l_message_html2 := l_message_html2||',MSG_ATTR'||to_char(n);
			n := n + 1;
		end if ;
		--
		-- Check for Costing
		--
		if p_run_costing <> 'Y' OR p_consolidation_set_id is NULL OR trim(p_costing_end_date) is NULL then
			wf_engine.setItemAttrText(g_item_type, g_item_key, 'TO_RUN_COSTING', 'N') ;
		else
			--
			if g_debug then
				hr_utility.trace('Will run Costing') ;
			end if ;
			--
			l_prc_list           := l_prc_list||l_conc_prog_name_tbl(10)||wf_core.newline;
			l_cur_process_tbl(n) := l_conc_prog_name_tbl(10);
			l_message_html2 := l_message_html2||',MSG_ATTR'||to_char(n);
			n := n + 1;
		end if ;
		--
		for j in n..10 loop
			l_cur_process_tbl(j) := null;
		end loop;
		--
	        l_message_text1 := l_prc_list;
		l_message_html2 := l_message_html2||')';
		--
		-- Get a few local variables
		--
		l_business_group_id := fnd_profile.value('PER_BUSINESS_GROUP_ID') ;
		--
		for rec in csr_payment_type loop
			l_payment_type_id := rec.payment_type_id;
		end loop ;
		--
		for rec in csr_payroll_name loop
			l_payroll_name := rec.payroll_name ;
		end loop ;
		--
		for rec in csr_consolidation_set_name loop
			l_consolidation_set_name := rec.consolidation_set_name ;
		end loop ;
		--
		for rec in csr_business_place_name loop
			l_business_place_name := rec.business_place_name ;
		end loop ;
		--
		--
		l_additional_tax_rate_hd 	:= 'BONUS_ADDITIONAL_TAX_RATE=' 	|| to_char(p_additional_tax_rate) ;
		l_overriding_tax_rate_hd 	:= 'BONUS_OVERRIDING_TAX_RATE=' 	|| to_char(p_overriding_tax_rate) ;
		l_payout_date_hd 		:= 'PAYOUTDATE=' 			|| p_payout_date ;
		l_characterset_hd 		:= 'CHARACTERSET=' 			|| p_characterset ;
		l_payroll_hd 			:= 'PAYROLL=' 				|| to_char(p_payroll_id) ;
		l_consolidation_set_hd 		:= 'CONSOLIDATION=' 			|| to_char(p_consolidation_set_id) ;
		l_archive_start_date_hd 	:= 'START_DATE=' 			|| p_archive_start_date ;
		l_archive_end_date_hd 		:= 'END_DATE=' 				|| p_archive_end_date ;
		l_business_group_hd 		:= 'BG_ID=' 				|| l_business_group_id ;
		l_payroll_retro_notf_hd 	:=  'PAYROLL_ID='			|| to_char(p_payroll_id) ;
		l_retro_notf_start_date_dmy 	:= 'START_DATE=1900/01/01 00:00:00' ;
		l_gen_assignment_set_name_dmy	:= 'ASG_SET='				|| p_gen_assignment_set_name ;
		--
		-- initialize the item attributes in workflow
		-- first initialize the variable name and value tables
		--
		if g_debug then
			hr_utility.trace('Starting initalization of number attributes array') ;
		end if ;
		--
		l_num_var_name_tbl(i) 	:= 'BATCH_ID' ;
		l_num_var_value_tbl(i) 	:= p_batch_id ;
		i := i + 1 ;
		l_num_var_name_tbl(i) 	:= 'ASSIGNMENT_SET_ID' ;
		l_num_var_value_tbl(i) 	:= p_assignment_set_id ;
		i := i + 1 ;
		l_num_var_name_tbl(i) 	:= 'PAYMENT_METHOD' ;
		l_num_var_value_tbl(i) 	:= p_payment_method ;
		i := i + 1 ;
		l_num_var_name_tbl(i) 	:= 'ELEMENT_SET_ID' ;
		l_num_var_value_tbl(i) 	:= p_element_set_id ;
		i := i + 1 ;
		l_num_var_name_tbl(i) 	:= 'PAYROLL_ID' ;
		l_num_var_value_tbl(i) 	:= p_payroll_id ;
		i := i + 1 ;
		l_num_var_name_tbl(i) 	:= 'RETRO_ASSIGNMENT_SET_ID' ;
		l_num_var_value_tbl(i) 	:= p_retro_assignment_set_id ;
		i := i + 1 ;
		l_num_var_name_tbl(i) 	:= 'RETRO_ELEMENT_SET_ID' ;
		l_num_var_value_tbl(i) 	:= p_retro_element_set_id ;
		i := i + 1 ;
		l_num_var_name_tbl(i) 	:= 'CONSOLIDATION_SET_ID' ;
		l_num_var_value_tbl(i) 	:= p_consolidation_set_id ;
		i := i + 1 ;
		l_num_var_name_tbl(i) 	:= 'PAYMENT_METHOD_OVERRIDE' ;
		l_num_var_value_tbl(i) 	:= p_payment_method_override ;
		i := i + 1 ;
		l_num_var_name_tbl(i) 	:= 'ACT_PARAM_GROUP_ID' ;
		l_num_var_value_tbl(i) 	:= p_act_param_group_id ;
		i := i + 1 ;
		l_num_var_name_tbl(i) 	:= 'PAYMENT_TYPE' ;
		l_num_var_value_tbl(i) 	:= l_payment_type_id ;
		i := i + 1 ;
		l_num_var_name_tbl(i) 	:= 'RUN_TYPE_ID' ;
		l_num_var_value_tbl(i) 	:= p_run_type_id ;
		i := i + 1 ;
		l_num_var_name_tbl(i) 	:= 'BUSINESS_GROUP_NUMBER' ;
		l_num_var_value_tbl(i) 	:= l_business_group_id ;
		i := i + 1 ;
		l_num_var_name_tbl(i) 	:= 'BUSINESS_PLACE_ID' ;
		l_num_var_value_tbl(i) 	:= p_business_place_id ;
		i := i + 1 ;
		l_num_var_name_tbl(i) 	:= 'BONUS_ADDITIONAL_TAX_RATE' ;
		l_num_var_value_tbl(i) 	:= p_additional_tax_rate ;
		i := i + 1 ;
		l_num_var_name_tbl(i) 	:= 'BONUS_OVERRIDING_TAX_RATE' ;
		l_num_var_value_tbl(i) 	:= p_overriding_tax_rate ;
		--
		-- text values
		--
		if g_debug then
			hr_utility.trace('Starting initalization of text attributes array') ;
		end if ;
		--
		i := 1 ;
		l_text_var_name_tbl(i) 		:= 'DATE_TIME' ;
		l_text_var_value_tbl(i) 	:= l_cur_time ;
		i := i + 1 ;
		l_text_var_name_tbl(i) 		:= 'CHARACTERSET' ;
		l_text_var_value_tbl(i) 	:= p_characterset ;
		i := i + 1 ;
		l_text_var_name_tbl(i) 		:= 'CHARACTERSET_HD' ;
		l_text_var_value_tbl(i) 	:= l_characterset_hd ;
		i := i + 1 ;
		l_text_var_name_tbl(i) 		:= 'EARNED_DATE' ;
		l_text_var_value_tbl(i) 	:= p_date_earned ;
		i := i + 1 ;
		l_text_var_name_tbl(i) 		:= 'PAID_DATE' ;
		l_text_var_value_tbl(i) 	:= p_date_paid ;
		i := i + 1 ;
		l_text_var_name_tbl(i) 		:= 'PAYOUT_DATE' ;
		l_text_var_value_tbl(i) 	:= p_payout_date ;
		i := i + 1 ;
		l_text_var_name_tbl(i) 		:= 'PAYOUT_DATE_HD' ;
		l_text_var_value_tbl(i) 	:= l_payout_date_hd ;
		i := i + 1 ;
		l_text_var_name_tbl(i) 		:= 'RETRO_START_DATE' ;
		l_text_var_value_tbl(i) 	:= p_retro_start_date ;
		i := i + 1 ;
		l_text_var_name_tbl(i) 		:= 'BONUS_START_DATE' ;
		l_text_var_value_tbl(i) 	:= p_bonus_start_date ;
		i := i + 1 ;
		l_text_var_name_tbl(i) 		:= 'DIRECT_DEPOSIT_DATE' ;
		l_text_var_value_tbl(i) 	:= p_direct_deposit_date ;
		i := i + 1 ;
		l_text_var_name_tbl(i) 		:= 'DIRECT_DEPOSIT_START_DATE' ;
		l_text_var_value_tbl(i) 	:= p_direct_deposit_start_date ;
		i := i + 1 ;
		l_text_var_name_tbl(i) 		:= 'DIRECT_DEPOSIT_END_DATE' ;
		l_text_var_value_tbl(i) 	:= p_direct_deposit_end_date ;
		i := i + 1 ;
		l_text_var_name_tbl(i) 		:= 'COSTING_START_DATE' ;
		l_text_var_value_tbl(i) 	:= p_costing_start_date ;
		i := i + 1 ;
		l_text_var_name_tbl(i) 		:= 'COSTING_END_DATE' ;
		l_text_var_value_tbl(i) 	:= p_costing_end_date ;
		i := i + 1 ;
		l_text_var_name_tbl(i) 		:= 'PREPAYMENTS_START_DATE' ;
		l_text_var_value_tbl(i) 	:= p_prepayment_start_date ;
		i := i + 1 ;
		l_text_var_name_tbl(i) 		:= 'PREPAYMENTS_END_DATE' ;
		l_text_var_value_tbl(i) 	:= p_prepayment_end_date ;
		i := i + 1 ;
		l_text_var_name_tbl(i) 		:= 'PAYROLL_NUMBER_HD' ;
		l_text_var_value_tbl(i) 	:= l_payroll_hd ;
		i := i + 1 ;
		l_text_var_name_tbl(i) 		:= 'CONSOLIDATION_SET_HIDDEN' ;
		l_text_var_value_tbl(i) 	:= l_consolidation_set_hd ;
		i := i + 1 ;
		l_text_var_name_tbl(i) 		:= 'ARCHIVE_START_DATE' ;
		l_text_var_value_tbl(i) 	:= p_archive_start_date ;
		i := i + 1 ;
		l_text_var_name_tbl(i) 		:= 'ARCHIVE_END_DATE' ;
		l_text_var_value_tbl(i) 	:= p_archive_end_date ;
		i := i + 1 ;
		l_text_var_name_tbl(i) 		:= 'ARCHIVE_START_DATE_HIDDEN' ;
		l_text_var_value_tbl(i) 	:= l_archive_start_date_hd ;
		i := i + 1 ;
		l_text_var_name_tbl(i) 		:= 'ARCHIVE_END_DATE_HIDDEN' ;
		l_text_var_value_tbl(i) 	:= l_archive_end_date_hd ;
		i := i + 1 ;
		l_text_var_name_tbl(i) 		:= 'BUSINESS_GROUP_HIDDEN' ;
		l_text_var_value_tbl(i) 	:= l_business_group_hd ;
		i := i + 1 ;
		l_text_var_name_tbl(i) 		:= 'RETROPAY_EFFECTIVE_DATE' ;
		l_text_var_value_tbl(i) 	:= p_retro_effective_date ;
		i := i + 1 ;
		l_text_var_name_tbl(i) 		:= 'BONUS_ADDITIONAL_TAX_RATE_HD' ;
		l_text_var_value_tbl(i) 	:= l_additional_tax_rate_hd ;
		i := i + 1 ;
		l_text_var_name_tbl(i) 		:= 'BONUS_OVERRIDING_TAX_RATE_HD' ;
		l_text_var_value_tbl(i) 	:= l_overriding_tax_rate_hd ;
		i := i + 1 ;
		l_text_var_name_tbl(i) 		:= 'BONUS_START_DATE_HD' ;
		l_text_var_value_tbl(i) 	:= l_bonus_start_date_hd ;
		i := i + 1 ;
		l_text_var_name_tbl(i) 		:= 'RUNTYPEPERIODID' ;
		l_text_var_value_tbl(i) 	:= p_run_type_period ;
		i := i + 1 ;
		l_text_var_name_tbl(i) 		:= 'PAYROLL_ID_RETRO_NOTF_HD' ;
		l_text_var_value_tbl(i) 	:= l_payroll_retro_notf_hd ;
		i := i + 1 ;
		l_text_var_name_tbl(i) 		:= 'START_DATE_RETRO_NOTF_DMY' ;
		l_text_var_value_tbl(i) 	:= l_retro_notf_start_date_dmy ;
		i := i + 1 ;
		l_text_var_name_tbl(i) 		:= 'RETRO_NOTF_EFFECTIVE_DATE' ;
		l_text_var_value_tbl(i) 	:= p_effective_date_retro_notf ;
		i := i + 1 ;
		l_text_var_name_tbl(i) 		:= 'EFF_DATE_RETRO_NOTF_DISP' ;
		l_text_var_value_tbl(i) 	:= l_eff_date_retro_notf_disp ;
		i := i + 1 ;
		l_text_var_name_tbl(i) 		:= 'EVENT_GROUP_ID_TOKEN' ;
		l_text_var_value_tbl(i) 	:= p_event_group ;
		i := i + 1 ;
		l_text_var_name_tbl(i) 		:= 'ASSIGNMENT_SET_NAME_RETRO_NOTF' ;
		l_text_var_value_tbl(i) 	:= p_gen_assignment_set_name ;
		i := i + 1 ;
		l_text_var_name_tbl(i) 		:= 'ASSIGN_SET_NAME_RETRO_NOTF_DMY' ;
		l_text_var_value_tbl(i) 	:= l_gen_assignment_set_name_dmy ;
		i := i + 1 ;
		l_text_var_name_tbl(i) 		:= 'PERFORMER_NAME' ;
		l_text_var_value_tbl(i) 	:= l_performer_name ;
		i := i + 1 ;
		l_text_var_name_tbl(i) 		:= 'PAYROLL_NAME' ;
		l_text_var_value_tbl(i) 	:= l_payroll_name ;
		i := i + 1 ;
		l_text_var_name_tbl(i) 		:= 'CONSOLIDATION_SET_NAME' ;
		l_text_var_value_tbl(i) 	:= l_consolidation_set_name ;
		i := i + 1 ;
		l_text_var_name_tbl(i) 		:= 'RETRO_NOTF_EVENT_GROUP_NAME' ;
		l_text_var_value_tbl(i) 	:= l_retro_notf_event_group_name ;
		i := i + 1 ;
		l_text_var_name_tbl(i) 		:= 'RETRO_PAY_ASSIGNMENT_SET_NAME' ;
		l_text_var_value_tbl(i) 	:= l_retro_assignment_set_name ;
		i := i + 1 ;
		l_text_var_name_tbl(i) 		:= 'RETRO_PAY_ELEMENT_SET_NAME' ;
		l_text_var_value_tbl(i) 	:= l_retro_element_set_name ;
		i := i + 1 ;
		l_text_var_name_tbl(i) 		:= 'ELEMENT_SET_NAME' ;
		l_text_var_value_tbl(i) 	:= l_element_set_name ;
		i := i + 1 ;
		l_text_var_name_tbl(i) 		:= 'RUN_TYPE_PERIOD_NAME_DISP' ;
		l_text_var_value_tbl(i) 	:= l_run_type_period_name_disp ;
		i := i + 1 ;
		l_text_var_name_tbl(i) 		:= 'ASSIGNMENT_SET_NAME' ;
		l_text_var_value_tbl(i) 	:= l_assignment_set_name ;
		i := i + 1 ;
		l_text_var_name_tbl(i) 		:= 'RUN_TYPE_NAME' ;
		l_text_var_value_tbl(i) 	:= l_run_type_name ;
		i := i + 1 ;
		l_text_var_name_tbl(i) 		:= 'PAYMENT_METHOD_OVERRIDE_NAME' ;
		l_text_var_value_tbl(i) 	:= l_payment_method_override_name ;
		i := i + 1 ;
		l_text_var_name_tbl(i) 		:= 'PAYMENT_METHOD_NAME' ;
		l_text_var_value_tbl(i) 	:= l_payment_method_name ;
		i := i + 1 ;
		l_text_var_name_tbl(i) 		:= 'BUSINESS_PLACE_NAME' ;
		l_text_var_value_tbl(i) 	:= l_business_place_name ;
		i := i + 1 ;
		l_text_var_name_tbl(i) 		:= 'BANK_TRANSFER_CONC_PROG_NAME' ;
		l_text_var_value_tbl(i) 	:= l_conc_prog_name_tbl(7);
		i := i + 1 ;
		l_text_var_name_tbl(i) 		:= 'BEE_CONC_PROG_NAME' ;
		l_text_var_value_tbl(i) 	:= l_conc_prog_name_tbl(1);
		i := i + 1 ;
		l_text_var_name_tbl(i) 		:= 'RETRO_NOTF_CONC_PROG_NAME' ;
		l_text_var_value_tbl(i) 	:= l_conc_prog_name_tbl(2);
		i := i + 1 ;
		l_text_var_name_tbl(i) 		:= 'RETRO_PAY_CONC_PROG_NAME' ;
		l_text_var_value_tbl(i) 	:= l_conc_prog_name_tbl(3);
		i := i + 1 ;
		l_text_var_name_tbl(i) 		:= 'MONTHLY_PAYROLL_CONC_PROG_NAME' ;
		l_text_var_value_tbl(i) 	:= l_conc_prog_name_tbl(4);
		i := i + 1 ;
		l_text_var_name_tbl(i) 		:= 'BONUS_PAYROLL_CONC_PROG_NAME' ;
		l_text_var_value_tbl(i) 	:= l_conc_prog_name_tbl(5);
		i := i + 1 ;
		l_text_var_name_tbl(i) 		:= 'PREPAYMENTS_CONC_PROG_NAME' ;
		l_text_var_value_tbl(i) 	:= l_conc_prog_name_tbl(6);
		i := i + 1 ;
		l_text_var_name_tbl(i) 		:= 'PAYSLIP_ARCHIVE_CONC_PROG_NAME' ;
		l_text_var_value_tbl(i) 	:= l_conc_prog_name_tbl(8);
		i := i + 1 ;
		l_text_var_name_tbl(i) 		:= 'PAYSLIP_REPORT_CONC_PROG_NAME' ;
		l_text_var_value_tbl(i) 	:= l_conc_prog_name_tbl(9);
		i := i + 1 ;
		l_text_var_name_tbl(i) 		:= 'COSTING_CONC_PROG_NAME' ;
		l_text_var_value_tbl(i) 	:= l_conc_prog_name_tbl(10);
		i := i + 1 ;
		l_text_var_name_tbl(i) 		:= 'MESSAGE_TEXT_1' ;
		l_text_var_value_tbl(i) 	:= l_message_text1 ;
		i := i + 1 ;
		l_text_var_name_tbl(i) 		:= 'MESSAGE_HTML_TEXT_2' ;
		l_text_var_value_tbl(i) 	:= l_message_html2 ;
		i := i + 1 ;
		l_text_var_name_tbl(i) 		:= 'PROCESS_1' ;
		l_text_var_value_tbl(i) 	:= l_cur_process_tbl(1) ;
		i := i + 1 ;
		l_text_var_name_tbl(i) 		:= 'PROCESS_2' ;
		l_text_var_value_tbl(i) 	:= l_cur_process_tbl(2) ;
		i := i + 1 ;
		l_text_var_name_tbl(i) 		:= 'PROCESS_3' ;
		l_text_var_value_tbl(i) 	:= l_cur_process_tbl(3) ;
		i := i + 1 ;
		l_text_var_name_tbl(i) 		:= 'PROCESS_4' ;
		l_text_var_value_tbl(i) 	:= l_cur_process_tbl(4) ;
		i := i + 1 ;
		l_text_var_name_tbl(i) 		:= 'PROCESS_5' ;
		l_text_var_value_tbl(i) 	:= l_cur_process_tbl(5) ;
		i := i + 1 ;
		l_text_var_name_tbl(i) 		:= 'PROCESS_6' ;
		l_text_var_value_tbl(i) 	:= l_cur_process_tbl(6) ;
		i := i + 1 ;
		l_text_var_name_tbl(i) 		:= 'PROCESS_7' ;
		l_text_var_value_tbl(i) 	:= l_cur_process_tbl(7) ;
		i := i + 1 ;
		l_text_var_name_tbl(i) 		:= 'PROCESS_8' ;
		l_text_var_value_tbl(i) 	:= l_cur_process_tbl(8) ;
		i := i + 1 ;
		l_text_var_name_tbl(i) 		:= 'PROCESS_9' ;
		l_text_var_value_tbl(i) 	:= l_cur_process_tbl(9) ;
		i := i + 1 ;
		l_text_var_name_tbl(i) 		:= 'PROCESS_10' ;
		l_text_var_value_tbl(i) 	:= l_cur_process_tbl(10) ;
		i := i + 1 ;
		l_text_var_name_tbl(i) 		:= 'SORT_ORDER_1' ;
		l_text_var_value_tbl(i) 	:= p_sort_order1 ;
		i := i + 1 ;
		l_text_var_name_tbl(i) 		:= 'SORT_ORDER_2' ;
		l_text_var_value_tbl(i) 	:= p_sort_order2 ;
		i := i + 1 ;
		l_text_var_name_tbl(i) 		:= 'SORT_ORDER_1_DISP' ;
		l_text_var_value_tbl(i) 	:= l_sort_order1_disp ;
		i := i + 1 ;
		l_text_var_name_tbl(i) 		:= 'SORT_ORDER_2_DISP' ;
		l_text_var_value_tbl(i) 	:= l_sort_order2_disp ;
		i := i + 1 ;
		--
		if g_debug then
			hr_utility.trace('Finished initialising attributes array') ;
		end if ;
		--
		-- now initialize, using the wf_engine API
		--
		wf_engine.setItemAttrNumberArray(g_item_type, g_item_key, l_num_var_name_tbl, l_num_var_value_tbl);
		--
		if g_debug then
			hr_utility.trace('Actually initalized number attributes by calling wf_engine.setItemAttrNumberArray') ;
		end if ;
		--
		wf_engine.setItemAttrTextArray(g_item_type, g_item_key, l_text_var_name_tbl, l_text_var_value_tbl);
		--
		if g_debug then
			hr_utility.trace('Actually initalized of text attributes by calling wf_engine.setItemAttrTextArray') ;
		end if ;
		--
		if g_debug then
			hr_utility.trace('Starting workflow') ;
		end if ;
		--
		-- Start the workflow
		--
		wf_engine.startprocess(
			ITEMTYPE	=>	g_item_type,
			ITEMKEY		=>	g_item_key
		) ;
		--
		if g_debug then
			hr_utility.trace('Workflow started. Quiting submit_workflow') ;
		end if ;
		--
		p_retcode := 0;
		--
	exception
		when others then
			if g_debug then
				hr_utility.trace(sqlerrm);
				p_retcode := 2;
			end if ;
	end submit_workflow ;
----------------------------------------------------------------------------------------------------------------------------
end pay_kr_process_nav_pkg ;

/
