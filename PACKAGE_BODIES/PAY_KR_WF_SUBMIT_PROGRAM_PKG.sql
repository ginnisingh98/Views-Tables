--------------------------------------------------------
--  DDL for Package Body PAY_KR_WF_SUBMIT_PROGRAM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_KR_WF_SUBMIT_PROGRAM_PKG" AS
/* $Header: pykrwfsp.pkb 120.2 2006/02/17 01:14:25 mmark noship $ */

	g_debug					constant 	boolean := hr_utility.debug_enabled ;
	procedure submit_program (
		itemtype			in		varchar2,	-- the name of the item type
		itemkey				in		varchar2,	-- the unique item key
		actid				in		number,		-- the activity id
		funcmode			in		varchar2,	-- mode
		resultout			in out nocopy	varchar2	-- the output
	) is
	--
	-- Bug 4859652
	cursor csr_payroll_action_id(
		p_prepayments_req_id		in		number,
		p_business_group_id		in		pay_payroll_actions.business_group_id%type,
		p_payroll_id			in		pay_payroll_actions.payroll_id%type
	) is
		select		payroll_action_id
		from 		pay_payroll_actions
		where 		request_id = p_prepayments_req_id
				and business_group_id = p_business_group_id
				and payroll_id = p_payroll_id
				and action_type = 'P' ;
	-- End of 4859652
	--
	cursor csr_run_type_period_name(p_run_type_period   in   number) is
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
	l_prepayments_req_id		pay_payroll_actions.request_id%TYPE ;
	l_business_group_id		pay_payroll_actions.business_group_id%type ; -- Bug 4859652
	l_payroll_id			pay_payroll_actions.payroll_id%type ; -- Bug 4859652
	--
	begin
		--
		if g_debug then
			hr_utility.trace('Into submit_program.') ;
		end if ;
		--
		if 	wf_engine.getActivityAttrText(itemtype, itemkey, actid, 'PROGRAM') = 'PAYKRSOE'
		   and 	wf_engine.getItemAttrText(itemtype, itemkey, 'TO_RUN_PREPAYMENTS') = 'Y'
		   and 	wf_engine.getItemAttrText(itemtype, itemkey, 'RUNTYPEPERIODID')    is null
		then
			--
			if g_debug then
				hr_utility.trace('Getting payroll action id from PrePayments to run Payslip (Korea)');
			end if ;
			--
			-- Get payroll action id from PrePayments to run Payslip (Korea)
			--
			l_prepayments_req_id := wf_engine.getItemAttrNumber(itemtype, itemkey, 'PREPAYMENTS_REQ_ID_NUM');
			-- Bug 4859652
			l_business_group_id := wf_engine.getItemAttrNumber(itemtype, itemkey, 'BUSINESS_GROUP_NUMBER') ;
			l_payroll_id := wf_engine.getItemAttrNumber(itemtype, itemkey, 'PAYROLL_ID') ;
			-- End of 4859652
			--
			if g_debug then
				hr_utility.trace('Got PrePayments request id = ' || l_prepayments_req_id );
			end if ;
			--
			for rec in csr_payroll_action_id(
				p_prepayments_req_id 	=> l_prepayments_req_id,
				p_business_group_id 	=> l_business_group_id, -- Bug 4859652
				p_payroll_id 		=> l_payroll_id -- Bug 4859652
			) loop
				--
				if g_debug then
					hr_utility.trace('Set run type period id in workflow = payroll action id = ' || to_char(rec.payroll_action_id) ) ;
				end if ;
				--
				-- set the payroll action id as the run type period in workflow
				--
				wf_engine.setItemAttrText(itemtype, itemkey, 'RUNTYPEPERIODID', to_char(rec.payroll_action_id));
				--
				for rec1 in csr_run_type_period_name(rec.payroll_action_id) loop
					wf_engine.setItemAttrText(itemtype, itemkey, 'RUN_TYPE_PERIOD_NAME_DISP', rec1.run_type_period_name);
				end loop;
			end loop ;
		--
		end if ;
		--
		if g_debug then
			hr_utility.trace('Now calling fnd_wf_standard.executeconcprogram for program ' || wf_engine.getActivityAttrText(itemtype, itemkey, actid, 'PROGRAM') ) ;
		end if ;
		--
		fnd_wf_standard.executeconcprogram(itemtype, itemkey, actid, funcmode, resultout) ;
		--
		if g_debug then
			hr_utility.trace('Called fnd_wf_standard.executeconcprogram. Quiting submit_program.') ;
		end if ;
		--
	exception
		when others then
			if g_debug then
				hr_utility.trace(sqlerrm);
			end if ;
			resultout := 'ERROR:';
	end submit_program ;
----------------------------------------------------------------------------------------------------------------------------------------
	procedure check_run_flags
	(
		p_itemtype 			in  		varchar2,
		p_itemkey  			in  		varchar2,
		p_actid    			in  		number,
		p_funcmode 			in  		varchar2,
		p_result   			in out nocopy 	varchar2
	)
	is
		l_user_id		number ;
		l_resp_id		number ;
		l_resp_appl_id		number ;
		l_org_id		number ;
		l_resultout		varchar2(80) ;
		l_security_group_id	number ;
		l_per_security_id	number ;

	begin
		if g_debug then
			hr_utility.trace('In check_run_flags') ;
		end if ;

		if (p_funcmode = 'RUN') then
			wf_standard.compare(
				p_itemtype,
				p_itemkey,
				p_actid,
				p_funcmode,
				l_resultout
			 ) ;

			if (l_resultout = 'COMPLETE:EQ') then
				p_result := 'COMPLETE:RUN';
			elsif ((l_resultout = 'COMPLETE:LT') or
			 (l_resultout = 'COMPLETE:GT') or
        	         (l_resultout  = 'COMPLETE:NULL'))
                	 then
				p_result := 'COMPLETE:SKIP';
			end if ;

			return ;

		else
			p_result := 'COMPLETE:SKIP';
			return ;
	 	end if ;
	exception
		when others then
			null ;
			if g_debug then
				wf_core.context('pay_kr_wf_submit_program_pkg', 'check_run_flags', p_itemtype, p_itemkey, p_actid, p_funcmode) ;
			end if ;
			p_result := 'ERROR:';
	end  check_run_flags ;
----------------------------------------------------------------------------------------------------------------------------------------
	procedure get_assignment_count(
                p_itemtype                      in              varchar2,
                p_itemkey                       in              varchar2,
                p_actid                         in              number,
                p_funcmode                      in              varchar2,
                p_result                        in out nocopy   varchar2
        ) is
	ln_req_id		number(9) ;
	ln_complete 		number(9);
	ln_error 		number(9);
	ln_unprocessed 		number(9);
	lb_to_get_counts	boolean ;
	l_payroll_id		pay_payroll_actions.payroll_id%type ; -- Bug 5042942
	l_action_completed	boolean;
	--
	cursor asg_info_cur
			is
			select 		count(paa.assignment_action_id) ASG_COUNT,
					paa.action_status ASG_STATUS
			from 		pay_assignment_actions paa,
					pay_payroll_actions ppa,
					per_business_groups pbg
			where		paa.payroll_action_id  = ppa.payroll_action_id
			and 		ppa.request_id =  ln_req_id
			and 		ppa.business_group_id = pbg.business_group_id
			and 		ppa.payroll_id = l_payroll_id -- Bug 5042942
			and 		ppa.effective_date between pbg.date_from and nvl(pbg.date_to, ppa.effective_date) -- Bug 5042942
                        and             ppa.action_type = 'R' -- Bug 5042942
			and 		paa.source_action_id is null
			and 		paa.run_type_id is null
			group by 	pbg.name, paa.action_status;
	--

	begin

		/*
		 * Get the request ids if we are running the monthly or bonus payroll processes, and
		 * use the request ids to get the number of assignments processed
		 */
		lb_to_get_counts := false ; -- initialize to false
		if wf_engine.getActivityAttrText(p_itemtype, p_itemkey, p_actid, 'PROGRAM') = 'PAYKRMTH' then -- we're running monthly
			ln_req_id := wf_engine.getItemAttrNumber(p_itemtype, p_itemkey, 'MONTHLY_PAYROLL_REQ_ID_NUM');
			--
			if g_debug then
				hr_utility.trace('Got Monthly Payroll request id = ' || ln_req_id );
			end if ;
			--
			lb_to_get_counts := true ; -- will need to get assignment count information
		elsif wf_engine.getActivityAttrText(p_itemtype, p_itemkey, p_actid, 'PROGRAM') = 'PAYKRBON' then -- we're running bonus
			ln_req_id := wf_engine.getItemAttrNumber(p_itemtype, p_itemkey, 'BONUS_PAYROLL_REQ_ID_NUM');
			--
			if g_debug then
				hr_utility.trace('Got Bonus Payroll request id = ' || ln_req_id );
			end if ;
			--
			lb_to_get_counts := true ; -- will need to get assignment count information

		end if ;
		-- now actually get the assignment counts, if running monthly/bonus
		if lb_to_get_counts = true then
			-- initialize counters
			ln_complete := 0;
			ln_error := 0;
			ln_unprocessed := 0;
                        l_payroll_id := wf_engine.getItemAttrNumber(p_itemtype, p_itemkey, 'PAYROLL_ID') ; -- Bug 5042942
			for asg_info_rec in asg_info_cur loop
				if asg_info_rec.ASG_STATUS = 'C' then
					ln_complete := asg_info_rec.ASG_COUNT;
				elsif asg_info_rec.ASG_STATUS = 'E' then
					ln_error := asg_info_rec.ASG_COUNT;
				elsif asg_info_rec.ASG_STATUS = 'U' then
					ln_unprocessed := asg_info_rec.ASG_COUNT;
				end if;
			end loop ;

			-- set corresponding item attributes
			wf_engine.setItemAttrNumber(p_itemtype, p_itemkey, 'SUCCESSFULLY_PROCESSED_COUNT', ln_complete) ;
			wf_engine.setItemAttrNumber(p_itemtype, p_itemkey, 'ERRORED_PROCESSED_COUNT', ln_error) ;
			wf_engine.setItemAttrNumber(p_itemtype, p_itemkey, 'UN_PROCESSED_COUNT', ln_unprocessed) ;
		end if ;
		--
		p_result := 'COMPLETE' ;
		--
	exception
		when others then
			if g_debug then
				hr_utility.trace(sqlerrm);
			end if ;
			p_result := 'ERROR:';
	end get_assignment_count ;

end pay_kr_wf_submit_program_pkg ;

/
