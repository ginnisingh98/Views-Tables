--------------------------------------------------------
--  DDL for Package Body GHR_PROCESS_SF52
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_PROCESS_SF52" as
/* $Header: ghproc52.pkb 120.13.12010000.19 2009/09/22 10:52:55 utokachi ship $ */
-- |--------------------------< <Ghr_Process_SF52 >--------------------------|
-- Declaring package global variables

	g_futr_proc_name	varchar2(30):='GHR_Proc_Futr_Act';

-- Declaring local procedures and functions
Function  get_information_type(p_noa_id in number) return varchar2;
Procedure Route_Errorerd_SF52(
	p_sf52  in out nocopy ghr_pa_requests%rowtype,
	p_error	in varchar2,
	p_result   out nocopy varchar2);

Procedure Single_Action_SF52(p_sf52_data  in out nocopy ghr_pa_requests%rowtype,
			     p_process_type in	varchar2 default 'CURRENT',
                             p_capped_other_pay    in number default null);
Procedure Dual_Action_SF52(p_sf52_data in out nocopy ghr_pa_requests%rowtype,
			   p_process_type in varchar2 default 'CURRENT');

procedure create_ghr_errorlog(
      p_program_name           in     ghr_process_log.program_name%type,
      p_log_text               in     ghr_process_log.log_text%type,
      p_message_name           in     ghr_process_log.message_name%type,
      p_log_date               in     ghr_process_log.log_date%type
      );

Procedure Update_shadow_row ( p_shadow_data in	ghr_pa_request_shadow%rowtype,
		              p_result	out nocopy Boolean);

/*Procedure fetch_update_routing_details
(p_pa_request_id           in         ghr_pa_requests.pa_request_id%type,
 p_object_version_number   in out     ghr_pa_requests.object_version_number%type,
 p_position_id             in         ghr_pa_requests.to_position_id%type,
 p_effective_date          in         ghr_pa_requests.effective_date%type,
 p_retcode                 out        number,
 p_route_flag              out        boolean
);
*/

--6850492
procedure Dual_Cancel_sf52(p_sf52_data in out nocopy ghr_pa_requests%rowtype
                          ,p_first_noa_code  in varchar2
                       	  ,p_second_noa_code in varchar2
                	  ,p_pa_request_id   in number
                          ,p_ovn             in number
                	  ,p_first_noa_id    in number
                      	  ,p_second_noa_id   in number
                 	  ,p_row_id          in varchar2);
--6850492

--- End declaration Local Procedures
-- declare global variables
--Begin Bug# 5634990
 -- e_refresh exception is declared in package header.
--e_refresh EXCEPTION;
--End Bug# 5634990
-- |--------------------------< process_sf52>---------------------------------|
-- Description:
--   This procedure is the generic procedure for processing an sf52. This procedure
--   determines what type of sf52 is being processed and calls the appropriate
--   procedure to handle it.
--
-- Pre-Requisities:
--   	None.
--
-- In Parameters:
--	p_sf52_data	->	ghr_pa_requests record of the sf52.
--	p_process_type	->	either current action or future action.
--	p_validate	->	flag to indicate if this is validate only mode.
--      p_capped_other_pay ->   Capped Other Pay amount due to Update 34 changes
--
-- Post Success:
-- 	The sf52 will have been processed.
--
-- Post Failure:
--   Exception will have been raised with message explaining what the problem is.
--
-- Developer Implementation Notes:
--   None
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
Procedure Process_SF52 (
	p_sf52_data	in out	nocopy ghr_pa_requests%rowtype,
	p_process_type	in	varchar2	default 'CURRENT',
	p_validate	in	Boolean 	default FALSE,
        p_capped_other_pay in number default NULL) is

	l_noa_code			varchar2(4);
	l_noa_family_code		varchar2(30);
	l_proc				varchar2(30):='process_sf52';
	l_sf52_data			ghr_pa_requests%rowtype;

--6850492
l_dual_cancel         varchar2(1);
l_dual_first_noa_code    ghr_pa_requests.first_noa_code%type;
l_dual_second_noa_code   ghr_pa_requests.second_noa_code%type;
l_dual_pa_request_id     ghr_pa_requests.pa_request_id%type;
l_dual_ovn               ghr_pa_requests.object_version_number%type;
l_dual_first_noa_id      ghr_pa_requests.first_noa_id%type;
l_dual_second_noa_id      ghr_pa_requests.second_noa_id%type;
l_dual_row_id            varchar2(100);
--6850492   /*Base Action is dual action*/

  Cursor Chk_Dual_Cancel
      is
      select rowid,pa_request_id,first_noa_code,second_noa_code,
	     object_version_number,first_noa_id,second_noa_id
      from   ghr_pa_requests
      where  pa_request_id = p_sf52_data.altered_pa_request_id
      and    first_noa_code not in ('001','002')
      and    second_noa_code is not null
      and    pa_notification_id is not null;
      -- Bug # 8283074 removed the below validation as the
      -- concept of breaking dual relationship is removed
      /*and    not exists (select 1
                         from  ghr_pa_requests
                         where nvl(rpa_type,'-1') <> 'DUAL'
			 and   mass_action_id is null
                         and   first_noa_code in ('002')
                         and   pa_notification_id is not null
                         start with pa_request_id = p_sf52_data.altered_pa_request_id
                         and   altered_pa_request_id is null
                         connect by altered_pa_request_id = prior pa_request_id);*/
--end of 6850492
Begin

        l_sf52_data   := p_sf52_data ; --NOCOPY Changes

	hr_utility.set_location(' Entering : ' || l_proc, 10);
	hr_utility.set_location(' Payment Option ' || p_sf52_data.pa_incentive_payment_option, 15);

	-- set global to disable checks that disallow changes to core data.
	-- This is also set back to false when exiting this procedure.
	ghr_api.g_api_dml	:= TRUE;
        -- Start Bug 3256085
        g_prd := NULL;
        g_step_or_rate :=  NULL;
        -- End Bug 3256085
	-- issue Savepoint
	savepoint process_SF52;

	if p_sf52_data.first_noa_code = '001' then
		-- Cancellation
	  hr_utility.set_location('First LAC CODE is : ' ||p_sf52_data.first_action_la_code1, 11);
          if p_sf52_data.first_action_la_code1 is null then
            hr_utility.set_message(8301 , 'GHR_38031_FIRST_LAC_NOT_EXIST');
            hr_utility.raise_error;
          end if;
          --6850492
	  l_dual_cancel := 'N';
	  for Chk_Dual_Cancel_Rec in Chk_Dual_Cancel
	  loop
	     l_dual_cancel :='Y';
	     l_dual_first_noa_code := Chk_Dual_Cancel_Rec.first_noa_code;
	     l_dual_second_noa_code := Chk_Dual_Cancel_Rec.second_noa_code;
	     l_dual_pa_request_id := Chk_Dual_Cancel_Rec.pa_request_id;
	     l_dual_ovn := Chk_Dual_Cancel_Rec.object_version_number;
	     l_dual_first_noa_id :=  Chk_Dual_Cancel_Rec.first_noa_id;
	     l_dual_second_noa_id :=  Chk_Dual_Cancel_Rec.second_noa_id;
	     l_dual_row_id :=  Chk_Dual_Cancel_Rec.rowid;
	  end loop;
	  If l_dual_cancel = 'N' then
             ghr_corr_canc_sf52.cancel_routine(p_sf52_data);
	  elsif l_dual_cancel = 'Y' then
	     Dual_Cancel_sf52(p_sf52_data => p_sf52_data
              	             ,p_first_noa_code  => l_dual_first_noa_code
	                     ,p_second_noa_code => l_dual_second_noa_code
			     ,p_pa_request_id   => l_dual_pa_request_id
			     ,p_ovn             => l_dual_ovn
			     ,p_first_noa_id    => l_dual_first_noa_id
			     ,p_second_noa_id   => l_dual_second_noa_id
			     ,p_row_id          => l_dual_row_id);
	  end if;
	  --6850492


	elsif p_sf52_data.first_noa_code = '002' then
		-- Correction
		ghr_corr_canc_sf52.correction_sf52 ( p_sf52_data        => p_sf52_data,
					   	     p_process_type     => p_process_type,
                                                     p_capped_other_pay => p_capped_other_pay);
	elsif p_sf52_data.first_noa_code is not null and
		p_sf52_data.second_noa_code is not null then
		-- dual Action
		--added for 8267598
		ghr_process_sf52.reinit_dual_var;
		dual_action_sf52 ( p_sf52_data,
	         		           p_process_type => p_process_type);
                --added for 8267598
	         ghr_process_sf52.reinit_dual_var;
	elsif p_sf52_data.first_noa_code is not null and
		p_sf52_data.second_noa_code is null then
		-- Single action
		hr_utility.set_location('Bef call single action Payment Option ' || p_sf52_data.pa_incentive_payment_option, 20);
		Single_action_SF52 ( p_sf52_data => p_sf52_data,
					   p_process_type => p_process_type,
                                           p_capped_other_pay => p_capped_other_pay);
	else
	      hr_utility.set_message(8301,'GHR_38222_UNKNOWN_NOA');
		ghr_api.g_api_dml	:= FALSE;
	      hr_utility.raise_error;
		-- raise error.
	end if;
	-- if validate only mode, then rollback.
	if p_validate then
		rollback to process_sf52;
	end if;

	if p_process_type = 'CURRENT' then
		Route_Intervn_Future_Actions(
			p_person_id		=>	p_sf52_data.person_id,
			p_effective_date	=>	p_sf52_data.effective_date
                  );
	end if;
      If p_process_type = 'FUTURE' then
         Route_Intervn_Act_pend_today(
			p_person_id		=>	p_sf52_data.person_id,
			p_effective_date	=>	p_sf52_data.effective_date
                  );
      End if;

	ghr_history_api.reinit_g_session_var;
	ghr_api.g_api_dml	:= FALSE;
	hr_utility.set_location(' Leaving : ' || l_proc, 200);

EXCEPTION
  WHEN others THEN
     -- Reset IN OUT parameters and set OUT parameters

        p_sf52_data   := l_sf52_data ;

   hr_utility.set_location('Leaving  ' || l_proc,60);
   RAISE;
End;

-- |--------------------------< single_action_sf52>---------------------------|
-- Description:
--   	This procedure handles the 'normal' case of a single,
--	non-correction/cancellation sf52.
-- Pre-Requisities:
--   	None.
-- In Parameters:
--	p_sf52_data		->		ghr_pa_requests record of the sf52.
--
-- Post Success:
-- 	The sf52 will have been processed.
--
-- Post Failure:
--   Exception will have been raised with message explaining what the problem is.
-- Developer Implementation Notes:
--   None
-- Access Status:
--   Internal Development Use Only.
-- ---------------------------------------------------------------------------

Procedure Single_Action_SF52 ( p_sf52_data	  in out nocopy	ghr_pa_requests%rowtype,
       			       p_process_type     in		varchar2 default 'CURRENT',
                               p_capped_other_pay in number    default null ) is

	l_today		date:=sysdate;
	l_session_var	ghr_history_api.g_session_var_type;
	l_result		varchar2(30);
	l_sf52_ei_data	ghr_pa_request_extra_info%rowtype;
	l_agency_ei_data	ghr_pa_request_extra_info%rowtype;
	l_sf52_shadow	ghr_pa_requests%rowtype;
	l_shadow_data	ghr_pa_request_shadow%rowtype;
	l_sf52_data		ghr_pa_requests%rowtype;
	l_proc		varchar2(30):='single_action_sf52';
        l_capped_other_pay number;

Begin
        l_sf52_data   := p_sf52_data ; --NOCOPY Changes
	hr_utility.set_location(' Entering : ' || l_proc, 10);
        hr_utility.set_location('Inside single action Payment Option ' || p_sf52_data.pa_incentive_payment_option, 20);
	-- reinitialise session variables
	ghr_history_api.reinit_g_session_var;
	-- set values of session variables
	l_session_var.pa_request_id 	:= p_sf52_data.pa_request_id;
	l_session_var.noa_id		:= p_sf52_data.first_noa_id;
	l_session_var.fire_trigger	:= 'Y';
	l_session_var.date_Effective	:= p_sf52_data.effective_date;
	l_session_var.person_id		:= p_sf52_data.person_id;
	l_session_var.program_name	:= 'sf50';
	l_session_var.altered_pa_request_id	:= p_sf52_data.altered_pa_request_id;
	l_session_var.assignment_id	:= p_sf52_data.employee_assignment_id;
	ghr_history_api.set_g_session_var(l_session_var);


	l_sf52_data := p_sf52_data;

	refresh_req_shadow (
		p_sf52_data	    => l_sf52_data,
		p_shadow_data   => l_shadow_data,
		p_process_type  => p_process_type);
        l_capped_other_pay := p_capped_other_pay;
	redo_pay_calc( p_Sf52_rec => l_sf52_data,
                       p_capped_other_pay => l_capped_other_pay );

	print_sf52('Before Update to HR Single Action : ' , l_sf52_data);

	ghr_non_sf52_extra_info.populate_noa_spec_extra_info(
		p_pa_request_id	=>	l_sf52_data.pa_request_id,
		p_first_noa_id	=>	l_sf52_data.first_noa_id,
		p_second_noa_id	=>	l_sf52_data.second_noa_id,
		p_person_id		=>	l_sf52_data.person_id,
		p_assignment_id	=>	l_sf52_data.employee_assignment_id,
		p_position_id	=>	nvl(l_sf52_data.to_position_id, l_sf52_data.from_position_id),
		p_effective_date	=>	l_sf52_data.effective_date,
		p_refresh_flag	=>	'Y'
	);

	ghr_non_sf52_extra_info.fetch_generic_extra_info(
		p_pa_request_id	=>	l_sf52_data.pa_request_id,
		p_person_id		=>	l_sf52_data.person_id,
		p_assignment_id	=>	l_sf52_data.employee_assignment_id,
		p_effective_date	=>	l_sf52_data.effective_date,
		p_refresh_flag	=>	'Y'
	);

	-- get sf52 extra info.
	Fetch_extra_info( p_pa_request_id 	=> p_sf52_data.pa_request_id,
				p_noa_id   		=> p_sf52_data.first_noa_id,
				p_sf52_ei_data 	=> l_sf52_ei_data,
				p_result		=> l_result);

	-- get agency specific sf52 extra info.
	Fetch_extra_info( p_pa_request_id 	=> p_sf52_data.pa_request_id,
				p_noa_id   		=> p_sf52_data.first_noa_id,
				p_agency_ei		=> TRUE,
				p_sf52_ei_data 	=> l_agency_ei_data,
				p_result		=> l_result);

	print_sf52('SINGLE_ACTION BEFORE UPDATE : ' , l_sf52_data);
	-- check for future action
	if l_session_var.date_effective > l_today then
		-- issue savepoint
		savepoint single_Action_sf52;
        -- Check if atleast the min. required items exist in the pa_request
        ghr_sf52_validn_pkg.prelim_req_chk_for_update_hr
        (p_pa_request_rec       =>  p_sf52_data
        );
		hr_utility.set_location('Bef call main Payment Option ' || l_sf52_data.pa_incentive_payment_option, 20);
		ghr_sf52_update.main( 	p_pa_request_rec    	=> l_sf52_data,
				        p_pa_request_ei_rec 	=> l_sf52_ei_data,
				        p_generic_ei_rec        => l_agency_ei_data,
                                        p_capped_other_pay      => l_capped_other_pay);
		-- rollback to savepoint
		rollback to single_action_sf52;
	else
        -- Check if atleast the min. required items exist in the pa_request
        ghr_sf52_validn_pkg.prelim_req_chk_for_update_hr
        (p_pa_request_rec       =>  p_sf52_data
        );
		ghr_sf52_update.main( 	p_pa_request_rec    	=> l_sf52_data,
					p_pa_request_ei_rec 	=> l_sf52_ei_data,
					p_generic_ei_rec       => l_agency_ei_data,
                                        p_capped_other_pay      => l_capped_other_pay);
	hr_utility.set_location( 'Before Call to Post_sf52_process ' || l_proc , 90);


		ghr_sf52_post_update.Post_sf52_process(
			p_pa_request_id		=> l_sf52_data.pa_request_id,
			p_effective_date		=> l_session_var.date_effective,
			p_object_version_number	=> l_sf52_data.object_version_number,
			p_from_position_id	=> l_sf52_data.from_position_id,
			p_to_position_id		=> l_sf52_data.to_position_id,
			p_agency_code		=> l_sf52_data.agency_code,
                        p_sf52_data_result      => l_sf52_data
		);
	hr_utility.set_location( 'After Call to Post_sf52_process ' || l_proc , 90);

	end if;

	Update_rfrs_values( p_sf52_data   => l_sf52_data,
				  p_shadow_data => l_shadow_data);
	hr_utility.set_location( 'Leaving : ' || l_proc , 100);

EXCEPTION
  WHEN others THEN
     -- Reset IN OUT parameters and set OUT parameters

        p_sf52_data   := l_sf52_data ;

   hr_utility.set_location('Leaving  ' || l_proc,60);
   RAISE;

End Single_Action_SF52;

-- |--------------------------< dual_action_sf52>-----------------------------|
-- Description:
--   	This procedure handles the case of a dual action.
-- Pre-Requisities:
--   	None.
-- In Parameters:
--	p_sf52_data		->		ghr_pa_requests record of the sf52.
-- Post Success:
-- 	The sf52 will have been processed.
-- Post Failure:
--   Exception will have been raised with message explaining what the problem is.
-- Developer Implementation Notes:
--   None
-- Access Status:
--   Internal Development Use Only.
-- ---------------------------------------------------------------------------

Procedure Dual_Action_SF52( p_sf52_data		in out	nocopy ghr_pa_requests%rowtype,
			    p_process_type	in		varchar2 default 'CURRENT') is

	l_today		date:=sysdate;
	l_sf52_data		ghr_pa_requests%rowtype;
	l_sf52_data_save  ghr_pa_requests%rowtype;
	l_sf52_ei_data	ghr_pa_request_extra_info%rowtype;
	l_agency_ei_data	ghr_pa_request_extra_info%rowtype;
	l_shadow_data	ghr_pa_request_shadow%rowtype;
	l_session_var	ghr_history_api.g_session_var_type;
	l_result		varchar2(30);
	l_proc		varchar2(30):='dual_action_sf52';
        l_new_assignment_id per_all_assignments_f.assignment_id%type;
        l_capped_other_pay number;

Begin

        l_sf52_data   := p_sf52_data ; --NOCOPY Changes

	hr_utility.set_location(' Entering : ' || l_proc, 10);
	-- reinitialise session variables
	ghr_history_api.reinit_g_session_var;
	-- set values of session variables
	l_session_var.pa_request_id 	:= p_sf52_data.pa_request_id;
	l_session_var.noa_id		:= p_sf52_data.first_noa_id;
	l_session_var.fire_trigger	:= 'Y';
	l_session_var.date_Effective	:= p_sf52_data.effective_date;
	l_session_var.person_id		:= p_sf52_data.person_id;
	l_session_var.program_name	:= 'sf50';
	l_session_var.assignment_id	:= p_sf52_data.employee_assignment_id;
	ghr_history_api.set_g_session_var(l_session_var);
	ghr_process_sf52.g_dual_action_yn := 'Y';
	ghr_process_sf52.g_dual_first_noac := p_sf52_data.first_noa_code;
     	ghr_process_sf52.g_dual_second_noac := p_sf52_data.second_noa_code;

	l_sf52_data := p_sf52_data;

	refresh_req_shadow (
		p_sf52_data	    => l_sf52_data,
		p_shadow_data   => l_shadow_data,
		p_process_type  => p_process_type);
	redo_pay_calc( p_Sf52_rec => l_sf52_data,
                       p_capped_other_pay => l_capped_other_pay);
	-- refresh SF52 DDF.
	ghr_non_sf52_extra_info.populate_noa_spec_extra_info(
		p_pa_request_id	=>	l_sf52_data.pa_request_id,
		p_first_noa_id	=>	l_sf52_data.first_noa_id,
		p_second_noa_id	=>	l_sf52_data.second_noa_id,
		p_person_id		=>	l_sf52_data.person_id,
		p_assignment_id	=>	l_sf52_data.employee_assignment_id,
		p_position_id	=>	nvl(l_sf52_data.to_position_id, l_sf52_data.from_position_id),
		p_effective_date	=>	l_sf52_data.effective_date,
		p_refresh_flag	=>	'Y'
	);
	ghr_non_sf52_extra_info.fetch_generic_extra_info(
		p_pa_request_id	=>	l_sf52_data.pa_request_id,
		p_person_id		=>	l_sf52_data.person_id,
		p_assignment_id	=>	l_sf52_data.employee_assignment_id,
		p_effective_date	=>	l_sf52_data.effective_date,
		p_refresh_flag	=>	'Y'
	);
	l_sf52_data_save := l_sf52_data;

	--8753859  Modified to not to call assign_new_rg for return to duty as the latest position is considered
	-- during the processing of first action itself. For Return to Duty the changes made for the
	--second action of dual action will be considered in the first action itself so assign_new_rg is not call
	-- for return to duty.

	if  l_sf52_data.noa_family_code <> 'RETURN_TO_DUTY' then
   	    assign_new_rg( p_action_num => 1,
			   p_pa_req     => l_sf52_data);
        else
	    null_2ndNoa_cols(l_sf52_data);
        end if;
	if (p_sf52_data.first_noa_code = '893') then --Bug# 8926400
		-- In case of dual action we may want to derive from, to column values
		-- Will be implemented once we have the business rules requirement.
		--	generate_from_to_colm( l_sf52_data);
		derive_to_columns(p_sf52_data	=>	l_sf52_data);
	end if;

	-- get sf52 extra info.
	Fetch_extra_info( p_pa_request_id 	=> p_sf52_data.pa_request_id,
				p_noa_id   		=> p_sf52_data.first_noa_id,
				p_sf52_ei_data 	=> l_sf52_ei_data,
				p_result		=> l_result);
	-- get agency specific sf52 extra info.
	Fetch_extra_info( p_pa_request_id 	=> p_sf52_data.pa_request_id,
				p_noa_id   		=> p_sf52_data.first_noa_id,
				p_agency_ei		=> TRUE,
				p_sf52_ei_data 	=> l_agency_ei_data,
				p_result		=> l_result);
	-- issue savepoint
	savepoint dual_Action_sf52;
        -- Check if atleast the min. required items exist in the pa_request
        ghr_sf52_validn_pkg.prelim_req_chk_for_update_hr
        (p_pa_request_rec       =>  p_sf52_data
        );

	ghr_sf52_update.main(
				p_pa_request_rec    	=> l_sf52_data,
				p_pa_request_ei_rec	=> l_sf52_ei_data,
				p_generic_ei_rec		=> l_agency_ei_data,
                                p_capped_other_pay      => l_capped_other_pay);

	hr_utility.set_location(' l_sf52_data.employee_assignment_id is : ' || l_sf52_data.employee_assignment_id, 11);
	-- Process 2nd NOA
        l_new_assignment_id := l_sf52_data.employee_assignment_id;
	l_sf52_data := p_sf52_data;
-- Bug# 1234846-- Venkat --
-- Above statement copies employee_assignment_id  to that of first action.
-- Below statement corrects it
-- ??? We have to research on above blanket copy once fix up patch over..
        l_sf52_data.employee_assignment_id := l_new_assignment_id;

        --6850492 added fetching of noa_family_code as family code will change for
	--second noa code
	get_Family_code(p_noa_id		=> l_sf52_data.second_noa_id,
		        p_noa_family_code	=> l_sf52_data.noa_family_code
   		        );



	assign_new_rg( p_action_num => 2,
			   p_pa_req     => l_sf52_data);


	-- refresh from values here.
	if (p_sf52_data.first_noa_code = '893') then--Bug# 8926400
		refresh_pa_request(p_person_id	=> 	l_sf52_data.person_id,
					 p_effective_date	=>	l_sf52_data.effective_date,
					 p_from_only	=>	TRUE,
					 p_sf52_data	=>	l_sf52_data);
	end if;

	-- reinitialise session variables
	ghr_history_api.reinit_g_session_var;
	-- set values of session variables
	l_session_var.pa_request_id 	:= p_sf52_data.pa_request_id;
	l_session_var.noa_id		:= p_sf52_data.second_noa_id;
	l_session_var.fire_trigger	:= 'Y';
	l_session_var.date_Effective	:= p_sf52_data.effective_date;
	l_session_var.person_id		:= p_sf52_data.person_id;
	l_session_var.program_name	:= 'sf50';
	l_session_var.assignment_id	:= l_sf52_data.employee_assignment_id;
	ghr_history_api.set_g_session_var(l_session_var);

	-- get sf52 extra info.
	Fetch_extra_info( p_pa_request_id 	=> p_sf52_data.pa_request_id,
			  	p_noa_id   		=> p_sf52_data.second_noa_id,
			  	p_sf52_ei_data 	=> l_sf52_ei_data,
			  	p_result		=> l_result);

	hr_utility.set_location(l_proc, 30);

        -- Check if atleast the min. required items exist in the pa_request
        ghr_sf52_validn_pkg.prelim_req_chk_for_update_hr
        (p_pa_request_rec       =>  p_sf52_data
        );
	ghr_sf52_update.main(
		p_pa_request_rec    	=> l_sf52_data,
		p_pa_request_ei_rec	=> l_sf52_ei_data,
		p_generic_ei_rec        => l_agency_ei_data,
                p_capped_other_pay      => l_capped_other_pay);

	hr_utility.set_location( l_proc , 60);
	if l_session_var.date_effective > l_today then
		rollback to dual_action_sf52;
	else
		hr_utility.set_location( l_proc , 60);
		ghr_sf52_post_update.Post_sf52_process(
			p_pa_request_id		=> p_sf52_data.pa_request_id,
			p_effective_date		=> l_session_var.date_effective,
			p_object_version_number	=> p_sf52_data.object_version_number,
			p_from_position_id	=> p_sf52_data.from_position_id,
			p_to_position_id		=> p_sf52_data.to_position_id,
			p_agency_code		=> p_sf52_data.agency_code,
                        p_sf52_data_result      => l_sf52_data);
	end if;
	hr_utility.set_location( l_proc, 125);

	Update_rfrs_values( p_sf52_data   => l_sf52_data_save,
				  p_shadow_data => l_shadow_data);

	hr_utility.set_location( 'Leaving : ' || l_proc , 100);

EXCEPTION
  WHEN others THEN
     -- Reset IN OUT parameters and set OUT parameters

        p_sf52_data   := l_sf52_data ;

   hr_utility.set_location('Leaving  ' || l_proc,60);
   RAISE;

end;

-- |--------------------------< get_information_type>-------------------------|
-- Description:
--   	This function returns the information_type given the noa_id.
-- Pre-Requisities:
--   	None.
-- In Parameters:
--	p_noa_id	->	nature of action id to retrieve
--				information_type for.
-- Post Success:
-- 	The inforation_type will have been returned.
-- Post Failure:
--   No failure conditions.
-- Developer Implementation Notes:
--   None
-- Access Status:
--   Internal Development Use Only.
-- ---------------------------------------------------------------------------
Function  get_information_type(p_noa_id 	in number) return varchar2
is
	l_information_type   ghr_pa_request_info_types.information_type%type;
	l_proc               varchar2(72) := 'get_information_type';
	Cursor cur_info_type IS
	Select pit.information_type
	from  ghr_pa_request_info_types  pit,
		ghr_noa_families           nfa,
		ghr_families               fam
	where  nfa.nature_of_action_id  = p_noa_id
	and    nfa.noa_family_code      = fam.noa_family_code
	and    fam.pa_info_type_flag    = 'Y'
	and    pit.noa_family_code      = fam.noa_family_code
	and    pit.information_type    <> 'GHR_US_PAR_GEN_AGENCY_DATA'
	and 	 pit.information_type	 like 'GHR_US%';
-- Bug No 570303 added restriction to only look at 'our' info types
Begin
	hr_utility.set_location(l_proc,10);
	l_information_type := null;
	for info_type in cur_info_type
	loop
		l_information_type :=  info_type.information_type;
	end loop;
	return l_information_type;
End get_information_type;
-- |--------------------------< fetch_extra_info>-----------------------------|
-- Description:
--   	This function fetches the sf52 extra info for a given pa_request.
-- Pre-Requisities:
--   	None.
-- In Parameters:
--	p_pa_request_id	->	pa_request_id to fetch the extra info for.
--	p_noa_id	->	nature of action id to fetch the extra info for.
--	p_agency_ei	->	boolean to indicate if this is agency specific ei.
--	p_sf52_ei_data	->	fetched extra info data returned here.
--	p_result	->	return code.
-- Post Success:
-- 	The inforation_type will have been returned.
-- Post Failure:
--   p_result will be set to 'not_found' if the extra information was not found.
-- Developer Implementation Notes:
--   None
-- Access Status:
--   Internal Development Use Only.
-- ---------------------------------------------------------------------------
Procedure Fetch_Extra_Info( 	p_pa_request_id	in	number,
				p_noa_id	in	number,
				p_agency_ei	in	boolean	default False,
				p_sf52_ei_data	out nocopy	ghr_pa_request_extra_info%rowtype,
				p_result	out nocopy	varchar2) is
	l_info_type 	ghr_pa_request_info_types.information_type%type;
	-- this cursor fetches the extra info data given the information_type and pa_request_id
	cursor c_req_ei ( cp_pa_request_id 	number,
				cp_info_type	ghr_pa_request_info_types.information_type%type) is
		select *
		from ghr_pa_request_extra_info
		where pa_request_id = cp_pa_request_id and
			information_type = cp_info_type;

	l_proc		varchar2(30):='fetch_Extra_info';
Begin
	hr_utility.set_location('entering : ' || l_proc, 10);
	if NOT p_agency_ei then
		l_info_type := get_information_type(p_noa_id => p_noa_id);
	else
		l_info_type := 'GHR_US_PAR_GEN_AGENCY_DATA';
	end if;

	if l_info_type is not null then
		open c_req_ei( p_pa_request_id, l_info_type);
		fetch c_req_ei into p_sf52_ei_data;
		if c_req_ei%notfound then
			p_result := 'not_found';
		end if;
		close c_req_ei;
	end if;

	hr_utility.set_location( 'Leaving : ' || l_proc, 50);

EXCEPTION
  WHEN others THEN
     -- Reset IN OUT parameters and set OUT parameters

        p_sf52_ei_data   := NULL ;
	p_result         := NULL ;

   hr_utility.set_location('Leaving  ' || l_proc,60);
   RAISE;
End;

-- |--------------------------< assign_new_rg>--------------------------------|
-- Description:
--   	This procedure nulls out or populates the unneeded columns in p_pa_req according to the
--	following two criteria:
--	1) If this the second or first action of a dual action.
--	2) Which fields are in pa_data_fields for this noa.
-- 	If p_action_num is 2 (We are building this from the second noa of a dual action),
--	then copy all second noa columns to the first noa columns and null out
--	the second noa columns.
--	Then, for each of the fields, copy them to the pa_request record we are building
--	according to the criteria listed in the function (Some fields are copied regardless
--	of noa, soem fields are noa specific, some fields are never copied and must be populated
--	by other means). Note that copy_to_new_rg will null out fields that are not found to
--	be needed for the given noa.
-- Pre-Requisities:
--   	None.
-- In Parameters:
--	p_action_num	->	number that indicates if this is the first or second action.
--	p_pa_req	->	pa_request record is passed here. It is also returned here after
--				it has been modified.
-- Post Success:
-- 	All the fields in p_pa_req will have been populated or nulled as needed for the given NOA.
-- Post Failure:
--   No Failure conditions.
-- Developer Implementation Notes:
--   A lot of thought was given to which fields should be copied, which should be always copied, which
--	should only be copied if they are in proc_methods, etc. This comment needs to be revisited to reflect
--	the reasons behind this.
-- Access Status:
--   Internal Development Use Only.
-- ---------------------------------------------------------------------------
PROCEDURE assign_new_rg (
	p_action_num       in  number,
	p_pa_req 	   in out nocopy ghr_pa_requests%rowtype) IS

   TYPE fields_type	is	record
	(form_field_name		ghr_pa_data_fields.form_field_name%TYPE,
	 process_method_code	ghr_noa_fam_proc_methods.process_method_code%TYPE
	);
	CURSOR get_root_pa_hist_id(	cp_pa_request_id	in	number,
						cp_noa_id		in	number) IS
		SELECT 	min(pa_history_id)
		FROM		ghr_pa_history ghrpah_1
		WHERE 	ghrpah_1.pa_request_id =
				(SELECT 	min(pa_request_id)
				FROM 		ghr_pa_requests
				CONNECT BY 	pa_request_id 	= prior altered_pa_request_id
				START WITH 	pa_request_id 	= cp_pa_request_id)
		AND		ghrpah_1.nature_of_action_id = cp_noa_id;

	CURSOR get_dual_family(	p_first_noa_id	in	ghr_dual_actions.first_noa_id%type,
					p_second_noa_id	in	ghr_dual_actions.second_noa_id%type) IS
		SELECT 	noa_family_code
		FROM		ghr_dual_actions
		WHERE 	first_noa_id = p_first_noa_id
			AND   second_noa_id = p_second_noa_id;
	CURSOR get_dual_action(	p_noa_family_code	in	ghr_dual_actions.noa_family_code%type,
					p_form_field_name	in	ghr_dual_actions.noa_family_code%type) IS
		SELECT	*
		FROM		ghr_dual_proc_methods
		WHERE		LOWER(noa_family_code) = LOWER(p_noa_family_code)
			AND	LOWER(form_field_name) = LOWER(p_form_field_name);
   TYPE fld_names_typ   is TABLE of fields_type
			INDEX BY BINARY_INTEGER;
   l_fld_names_tab1	fld_names_typ;
   l_fld_names_tab2	fld_names_typ;
   l_pa_req		ghr_pa_requests%rowtype;
   l_column_count		number := 0;
   l_column_count1	number := 0;
   l_column_count2	number := 0;
   l_refresh_called	boolean:= false;
   l_non_from_called	boolean:= false;
   l_non_from_pa_req	ghr_pa_requests%rowtype;
   l_correction			boolean:= null;
   l_pa_req_ref		ghr_pa_requests%rowtype;
   l_pa_req_ref2		ghr_pa_requests%rowtype;
   l_noa_family_code		ghr_dual_actions.noa_family_code%type := null;
   tmp_varchar		varchar2(150);

   l_proc	varchar2(30):='assign_new_rg';

   PROCEDURE initialize_fld_names_table (	p_noa_id 	in		number,
						p_fld_names_tab	in out nocopy fld_names_typ) IS
   -- initializes the local pl/sql table with the field names from ghr_pa_data_fields table.
	-- this cursor fetches the form_field_names for the noa_id specified.
	CURSOR cur_flds(p_noa_id number) IS
		SELECT	fld.form_field_name,
				met.process_method_code
		FROM
			ghr_families			ghrf,
			ghr_noa_fam_proc_methods	met,
			ghr_pa_data_fields		fld,
			ghr_noa_families			fam
		WHERE
			    fam.noa_family_code		= met.noa_family_code
			AND ghrf.noa_family_code	= met.noa_family_code
			AND ghrf.update_hr_flag		= 'Y'
			AND met.process_method_code in ('AP', 'APUE', 'UE')
			AND met.pa_data_field_id	= fld.pa_data_field_id
			AND fam.nature_of_action_id	= p_noa_id;
	l_proc	varchar2(30):='initialize_fld_names_table';
	l_fld_names_tab	 fld_names_typ;
   BEGIN
        l_fld_names_tab := p_fld_names_tab;
	l_column_count := 0;
	hr_utility.set_location('Entering:'|| l_proc, 5);
	-- populate the local table with the form_field_names for this noa.
      FOR curflds_rec in cur_flds(p_noa_id) LOOP
          l_column_count := l_column_count + 1;
          p_fld_names_tab(l_column_count) := curflds_rec;
      END LOOP;
	hr_utility.set_location('Leaving:'|| l_proc, 10);
   EXCEPTION
     WHEN OTHERS THEN
     -- NOCOPY CHANGES
        p_fld_names_tab := l_fld_names_tab;
   END initialize_fld_names_table;

FUNCTION to_from_info(p_field_name	IN varchar2) return varchar2 IS
	l_proc	varchar2(30):='to_from_info';
	ret_value	varchar2(1) := 'N';
BEGIN
	if (LOWER(SUBSTR(p_field_name, 0, 5)) = 'from_') then
		ret_value := 'F';
	elsif (LOWER(SUBSTR(p_field_name, 0, 3)) = 'to_') then
		ret_value := 'T';
	end if;
	return ret_value;
END;

FUNCTION	get_field_info(	p_field_name	IN VARCHAR2,
					p_sf52_data		IN ghr_pa_requests%rowtype) RETURN varchar2 IS
	l_proc	varchar2(30):='get_field_info';
	l_ret_value	varchar2(2000);
BEGIN
	hr_utility.set_location('Entering: ' ||l_proc, 10);
	if (lower(p_field_name) = 'pa_request_id') then
		l_ret_value := p_sf52_data.pa_request_id;

	elsif (lower(p_field_name) = 'pa_notification_id') then
		l_ret_value := p_sf52_data.pa_notification_id;

	elsif (lower(p_field_name) = 'noa_family_code') then
		l_ret_value := p_sf52_data.noa_family_code;

	elsif (lower(p_field_name) = 'routing_group_id') then
		l_ret_value := p_sf52_data.routing_group_id;

	elsif (lower(p_field_name) = 'academic_discipline') then
		l_ret_value := p_sf52_data.academic_discipline;

	elsif (lower(p_field_name) = 'additional_info_person_id') then
		l_ret_value := p_sf52_data.additional_info_person_id;

	elsif (lower(p_field_name) = 'additional_info_tel_number') then
		l_ret_value := p_sf52_data.additional_info_tel_number;

	elsif ((lower(p_field_name) = 'agency_code') or (lower(p_field_name) = 'to_agency_code')) then
		l_ret_value := p_sf52_data.agency_code;

	elsif (lower(p_field_name) = 'altered_pa_request_id') then
		l_ret_value := p_sf52_data.altered_pa_request_id;

	elsif (lower(p_field_name) = 'annuitant_indicator') then
		l_ret_value := p_sf52_data.annuitant_indicator;

	elsif (lower(p_field_name) = 'annuitant_indicator_desc') then
		l_ret_value := p_sf52_data.annuitant_indicator_desc;

	elsif (lower(p_field_name) = 'appropriation_code1') then
		l_ret_value := p_sf52_data.appropriation_code1;

	elsif (lower(p_field_name) = 'appropriation_code2') then
		l_ret_value := p_sf52_data.appropriation_code2;

	elsif (lower(p_field_name) = 'approval_date') then
		l_ret_value := to_char(p_sf52_data.approval_date,'DDMMYYYY');

	elsif (lower(p_field_name) = 'approving_official_work_title') then
		l_ret_value := p_sf52_data.approving_official_work_title;

	elsif (lower(p_field_name) = 'authorized_by_person_id') then
		l_ret_value := p_sf52_data.authorized_by_person_id;

	elsif (lower(p_field_name) = 'authorized_by_title') then
		l_ret_value := p_sf52_data.authorized_by_title;

	elsif (lower(p_field_name) = 'award_amount') then
		l_ret_value := p_sf52_data.award_amount;

	elsif (lower(p_field_name) = 'award_uom') then
		l_ret_value := p_sf52_data.award_uom;

	elsif (lower(p_field_name) = 'bargaining_unit_status') then
		l_ret_value := p_sf52_data.bargaining_unit_status;

	elsif (lower(p_field_name) = 'citizenship') then
		l_ret_value := p_sf52_data.citizenship;

	elsif (lower(p_field_name) = 'concurrence_date') then
		l_ret_value := to_char(p_sf52_data.concurrence_date,'DDMMYYYY');

	elsif (lower(p_field_name) = 'custom_pay_calc_flag') then
		l_ret_value := p_sf52_data.custom_pay_calc_flag;

	elsif (lower(p_field_name) = 'duty_station_code') then
		l_ret_value := p_sf52_data.duty_station_code;

	elsif (lower(p_field_name) = 'duty_station_desc') then
		l_ret_value := p_sf52_data.duty_station_desc;

	elsif (lower(p_field_name) = 'duty_station_id') then
		l_ret_value := to_char(p_sf52_data.duty_station_id);

	elsif (lower(p_field_name) = 'duty_station_location_id') then
		l_ret_value := to_char(p_sf52_data.duty_station_location_id);

	elsif (lower(p_field_name) = 'education_level') then
		l_ret_value := p_sf52_data.education_level;

	elsif (lower(p_field_name) = 'effective_date') then
		l_ret_value := to_char(p_sf52_data.effective_date,'DDMMYYYY');

	elsif (lower(p_field_name) = 'employee_assignment_id') then
		l_ret_value := p_sf52_data.employee_assignment_id;

	elsif (lower(p_field_name) = 'employee_date_of_birth') then
		-- must specify conversion in order to avoid Y2000 problems
		l_ret_value := to_char(p_sf52_data.employee_date_of_birth,'DDMMYYYY');

	elsif (lower(p_field_name) = 'employee_dept_or_agency') then
		l_ret_value := p_sf52_data.employee_dept_or_agency;

	elsif (lower(p_field_name) = 'employee_first_name') then
		l_ret_value := p_sf52_data.employee_first_name;

	elsif (lower(p_field_name) = 'employee_last_name') then
		l_ret_value := p_sf52_data.employee_last_name;

	elsif (lower(p_field_name) = 'employee_middle_names') then
		l_ret_value := p_sf52_data.employee_middle_names;

	elsif (lower(p_field_name) = 'employee_national_identifier') then
		l_ret_value := p_sf52_data.employee_national_identifier;

	elsif (lower(p_field_name) = 'fegli') then
		l_ret_value := p_sf52_data.fegli;

	elsif (lower(p_field_name) = 'fegli_desc') then
		l_ret_value := p_sf52_data.fegli_desc;

	elsif (lower(p_field_name) = 'first_action_la_code1') then
		l_ret_value := p_sf52_data.first_action_la_code1;

	elsif (lower(p_field_name) = 'first_action_la_code2') then
		l_ret_value := p_sf52_data.first_action_la_code2;

	elsif (lower(p_field_name) = 'first_action_la_desc1') then
		l_ret_value := p_sf52_data.first_action_la_desc1;

	elsif (lower(p_field_name) = 'first_action_la_desc2') then
		l_ret_value := p_sf52_data.first_action_la_desc2;

	elsif (lower(p_field_name) = 'first_noa_cancel_or_correct') then
		l_ret_value := p_sf52_data.first_noa_cancel_or_correct;

	elsif (lower(p_field_name) = 'first_noa_code') then
		l_ret_value := p_sf52_data.first_noa_code;

	elsif (lower(p_field_name) = 'first_noa_desc') then
		l_ret_value := p_sf52_data.first_noa_desc;

	elsif (lower(p_field_name) = 'first_noa_id') then
		l_ret_value := p_sf52_data.first_noa_id;

	elsif (lower(p_field_name) = 'first_noa_pa_request_id') then
		l_ret_value := p_sf52_data.first_noa_pa_request_id;

	elsif (lower(p_field_name) = 'flsa_category') then
		l_ret_value := p_sf52_data.flsa_category;

	elsif (lower(p_field_name) = 'forwarding_address_line1') then
		l_ret_value := p_sf52_data.forwarding_address_line1;

	elsif (lower(p_field_name) = 'forwarding_address_line2') then
		l_ret_value := p_sf52_data.forwarding_address_line2;

	elsif (lower(p_field_name) = 'forwarding_address_line3') then
		l_ret_value := p_sf52_data.forwarding_address_line3;

	elsif (lower(p_field_name) = 'forwarding_country') then
		l_ret_value := p_sf52_data.forwarding_country;

	elsif (lower(p_field_name) = 'forwarding_country_short_name') then
		l_ret_value := p_sf52_data.forwarding_country_short_name;

	elsif (lower(p_field_name) = 'forwarding_postal_code') then
		l_ret_value := p_sf52_data.forwarding_postal_code;

	elsif (lower(p_field_name) = 'forwarding_region_2') then
		l_ret_value := p_sf52_data.forwarding_region_2;

	elsif (lower(p_field_name) = 'forwarding_town_or_city') then
		l_ret_value := p_sf52_data.forwarding_town_or_city;

	elsif (lower(p_field_name) = 'from_adj_basic_pay') then
		l_ret_value := p_sf52_data.from_adj_basic_pay;

	elsif (lower(p_field_name) = 'from_agency_code') then
		l_ret_value := p_sf52_data.from_agency_code;

	elsif (lower(p_field_name) = 'from_agency_desc') then
		l_ret_value := p_sf52_data.from_agency_desc;

	elsif (lower(p_field_name) = 'from_ap_premium_pay_indicator') then
		if (not l_non_from_called) then
			refresh_pa_request(
						p_person_id		=>	p_sf52_data.person_id,
						p_effective_date	=>	p_sf52_data.effective_date,
						p_derive_to_cols	=>	TRUE,
						p_sf52_data		=>	l_non_from_pa_req);
		end if;
		l_ret_value := l_non_from_pa_req.to_ap_premium_pay_indicator;

	elsif (lower(p_field_name) = 'from_auo_premium_pay_indicator') then
		if (not l_non_from_called) then
			refresh_pa_request(
						p_person_id		=>	p_sf52_data.person_id,
						p_effective_date	=>	p_sf52_data.effective_date,
						p_derive_to_cols	=>	TRUE,
						p_sf52_data		=>	l_non_from_pa_req);
		end if;
		l_ret_value := l_non_from_pa_req.to_auo_premium_pay_indicator;

	elsif (lower(p_field_name) = 'from_au_overtime') then
		if (not l_non_from_called) then
			refresh_pa_request(
						p_person_id		=>	p_sf52_data.person_id,
						p_effective_date	=>	p_sf52_data.effective_date,
						p_derive_to_cols	=>	TRUE,
						p_sf52_data		=>	l_non_from_pa_req);
		end if;
		l_ret_value := l_non_from_pa_req.to_au_overtime;

	elsif (lower(p_field_name) = 'from_availability_pay') then
		if (not l_non_from_called) then
			refresh_pa_request(
						p_person_id		=>	p_sf52_data.person_id,
						p_effective_date	=>	p_sf52_data.effective_date,
						p_derive_to_cols	=>	TRUE,
						p_sf52_data		=>	l_non_from_pa_req);
		end if;
		l_ret_value := l_non_from_pa_req.to_availability_pay;

	elsif (lower(p_field_name) = 'from_retention_allowance') then
		if (not l_non_from_called) then
			refresh_pa_request(
						p_person_id		=>	p_sf52_data.person_id,
						p_effective_date	=>	p_sf52_data.effective_date,
						p_derive_to_cols	=>	TRUE,
						p_sf52_data		=>	l_non_from_pa_req);
		end if;
		l_ret_value := l_non_from_pa_req.to_retention_allowance;

	elsif (lower(p_field_name) = 'from_retention_allow_percentage') then
		if (not l_non_from_called) then
			refresh_pa_request(
						p_person_id		=>	p_sf52_data.person_id,
						p_effective_date	=>	p_sf52_data.effective_date,
						p_derive_to_cols	=>	TRUE,
						p_sf52_data		=>	l_non_from_pa_req);
		end if;
		l_ret_value := l_non_from_pa_req.to_retention_allow_percentage;

	elsif (lower(p_field_name) = 'from_staffing_differential') then
		if (not l_non_from_called) then
			refresh_pa_request(
						p_person_id		=>	p_sf52_data.person_id,
						p_effective_date	=>	p_sf52_data.effective_date,
						p_derive_to_cols	=>	TRUE,
						p_sf52_data		=>	l_non_from_pa_req);
		end if;
		l_ret_value := l_non_from_pa_req.to_staffing_differential;

	elsif (lower(p_field_name) = 'from_staffing_diff_percentage') then
		if (not l_non_from_called) then
			refresh_pa_request(
						p_person_id		=>	p_sf52_data.person_id,
						p_effective_date	=>	p_sf52_data.effective_date,
						p_derive_to_cols	=>	TRUE,
						p_sf52_data		=>	l_non_from_pa_req);
		end if;
		l_ret_value := l_non_from_pa_req.to_staffing_diff_percentage;

	elsif (lower(p_field_name) = 'from_supervisory_differential') then
		if (not l_non_from_called) then
			refresh_pa_request(
						p_person_id		=>	p_sf52_data.person_id,
						p_effective_date	=>	p_sf52_data.effective_date,
						p_derive_to_cols	=>	TRUE,
						p_sf52_data		=>	l_non_from_pa_req);
		end if;
		l_ret_value := l_non_from_pa_req.to_supervisory_differential;

	elsif (lower(p_field_name) = 'from_supervisory_diff_percentage') then
		if (not l_non_from_called) then
			refresh_pa_request(
						p_person_id		=>	p_sf52_data.person_id,
						p_effective_date	=>	p_sf52_data.effective_date,
						p_derive_to_cols	=>	TRUE,
						p_sf52_data		=>	l_non_from_pa_req);
		end if;
		l_ret_value := l_non_from_pa_req.to_supervisory_diff_percentage;

	elsif (lower(p_field_name) = 'from_organization_id') then
		if (not l_non_from_called) then
			refresh_pa_request(
						p_person_id		=>	p_sf52_data.person_id,
						p_effective_date	=>	p_sf52_data.effective_date,
						p_derive_to_cols	=>	TRUE,
						p_sf52_data		=>	l_non_from_pa_req);
		end if;
		l_ret_value := l_non_from_pa_req.to_organization_id;

	elsif (lower(p_field_name) = 'from_job_id') then
		if (not l_non_from_called) then
			refresh_pa_request(
						p_person_id		=>	p_sf52_data.person_id,
						p_effective_date	=>	p_sf52_data.effective_date,
						p_derive_to_cols	=>	TRUE,
						p_sf52_data		=>	l_non_from_pa_req);
		end if;
		l_ret_value := l_non_from_pa_req.to_job_id;

	elsif (lower(p_field_name) = 'from_grade_id') then
		if (not l_non_from_called) then
			refresh_pa_request(
						p_person_id		=>	p_sf52_data.person_id,
						p_effective_date	=>	p_sf52_data.effective_date,
						p_derive_to_cols	=>	TRUE,
						p_sf52_data		=>	l_non_from_pa_req);
		end if;
		l_ret_value := l_non_from_pa_req.to_grade_id;

	elsif (lower(p_field_name) = 'from_basic_pay') then
		l_ret_value := p_sf52_data.from_basic_pay;

	elsif (lower(p_field_name) = 'from_grade_or_level') then
		l_ret_value := p_sf52_data.from_grade_or_level;

	elsif (lower(p_field_name) = 'from_locality_adj') then
		l_ret_value := p_sf52_data.from_locality_adj;

	elsif (lower(p_field_name) = 'from_occ_code') then
		l_ret_value := p_sf52_data.from_occ_code;

	elsif (lower(p_field_name) = 'from_office_symbol') then
		l_ret_value := p_sf52_data.from_office_symbol;

	elsif (lower(p_field_name) = 'from_other_pay_amount') then
		l_ret_value := p_sf52_data.from_other_pay_amount;

	elsif (lower(p_field_name) = 'from_pay_basis') then
		l_ret_value := p_sf52_data.from_pay_basis;

	elsif (lower(p_field_name) = 'from_pay_plan') then
		l_ret_value := p_sf52_data.from_pay_plan;

	elsif (lower(p_field_name) = 'from_position_id') then
		l_ret_value := p_sf52_data.from_position_id;

	elsif (lower(p_field_name) = 'from_position_org_line1') then
		l_ret_value := p_sf52_data.from_position_org_line1;

	elsif (lower(p_field_name) = 'from_position_org_line2') then
		l_ret_value := p_sf52_data.from_position_org_line2;

	elsif (lower(p_field_name) = 'from_position_org_line3') then
		l_ret_value := p_sf52_data.from_position_org_line3;

	elsif (lower(p_field_name) = 'from_position_org_line4') then
		l_ret_value := p_sf52_data.from_position_org_line4;

	elsif (lower(p_field_name) = 'from_position_org_line5') then
		l_ret_value := p_sf52_data.from_position_org_line5;

	elsif (lower(p_field_name) = 'from_position_org_line6') then
		l_ret_value := p_sf52_data.from_position_org_line6;

	elsif (lower(p_field_name) = 'from_position_number') then
		l_ret_value := p_sf52_data.from_position_number;

	elsif (lower(p_field_name) = 'from_position_seq_no') then
		l_ret_value := p_sf52_data.from_position_seq_no;

	elsif (lower(p_field_name) = 'from_position_title') then
		l_ret_value := p_sf52_data.from_position_title;

	elsif (lower(p_field_name) = 'from_step_or_rate') then
		l_ret_value := p_sf52_data.from_step_or_rate;

	elsif (lower(p_field_name) = 'from_total_salary') then
		l_ret_value := p_sf52_data.from_total_salary;

	elsif (lower(p_field_name) = 'functional_class') then
		l_ret_value := p_sf52_data.functional_class;

	elsif (lower(p_field_name) = 'part_time_hours') then
		l_ret_value := p_sf52_data.part_time_hours;

	elsif (lower(p_field_name) = 'pay_rate_determinant') then
		l_ret_value := p_sf52_data.pay_rate_determinant;

	elsif (lower(p_field_name) = 'personnel_office_id') then
		l_ret_value := p_sf52_data.personnel_office_id;

	elsif (lower(p_field_name) = 'person_id') then
		l_ret_value := p_sf52_data.person_id;

	elsif (lower(p_field_name) = 'position_occupied') then
		l_ret_value := p_sf52_data.position_occupied;

	elsif (lower(p_field_name) = 'proposed_effective_asap_flag') then
		l_ret_value := p_sf52_data.proposed_effective_asap_flag;

	elsif (lower(p_field_name) = 'proposed_effective_date') then
		l_ret_value := to_char(p_sf52_data.proposed_effective_date,'DDMMYYYY');

	elsif (lower(p_field_name) = 'requested_by_person_id') then
		l_ret_value := p_sf52_data.requested_by_person_id;

	elsif (lower(p_field_name) = 'requested_by_title') then
		l_ret_value := p_sf52_data.requested_by_title;

	elsif (lower(p_field_name) = 'requested_date') then
		l_ret_value := to_char(p_sf52_data.requested_date,'DDMMYYYY');

	elsif (lower(p_field_name) = 'requesting_office_remarks_desc') then
		l_ret_value := p_sf52_data.requesting_office_remarks_desc;

	elsif (lower(p_field_name) = 'requesting_office_remarks_flag') then
		l_ret_value := p_sf52_data.requesting_office_remarks_flag;

	elsif (lower(p_field_name) = 'request_number') then
		l_ret_value := p_sf52_data.request_number;

	elsif (lower(p_field_name) = 'resign_and_retire_reason_desc') then
		l_ret_value := p_sf52_data.resign_and_retire_reason_desc;

	elsif (lower(p_field_name) = 'retirement_plan') then
		l_ret_value := p_sf52_data.retirement_plan;

	elsif (lower(p_field_name) = 'retirement_plan_desc') then
		l_ret_value := p_sf52_data.retirement_plan_desc;

	elsif (lower(p_field_name) = 'second_action_la_code1') then
		l_ret_value := p_sf52_data.second_action_la_code1;

	elsif (lower(p_field_name) = 'second_action_la_code2') then
		l_ret_value := p_sf52_data.second_action_la_code2;

	elsif (lower(p_field_name) = 'second_action_la_desc1') then
		l_ret_value := p_sf52_data.second_action_la_desc1;

	elsif (lower(p_field_name) = 'second_action_la_desc2') then
		l_ret_value := p_sf52_data.second_action_la_desc2;

	elsif (lower(p_field_name) = 'second_noa_cancel_or_correct') then
		l_ret_value := p_sf52_data.second_noa_cancel_or_correct;

	elsif (lower(p_field_name) = 'second_noa_code') then
		l_ret_value := p_sf52_data.second_noa_code;

	elsif (lower(p_field_name) = 'second_noa_desc') then
		l_ret_value := p_sf52_data.second_noa_desc;

	elsif (lower(p_field_name) = 'second_noa_id') then
		l_ret_value := p_sf52_data.second_noa_id;

	elsif (lower(p_field_name) = 'second_noa_pa_request_id') then
		l_ret_value := p_sf52_data.second_noa_pa_request_id;

	elsif (lower(p_field_name) = 'service_comp_date') then
		-- must specify conversion in order to avoid Y2000 problems
		--l_ret_value := fnd_date.date_to_canonical(p_sf52_data.service_comp_date);
                -- Venkat,Bug 1809513,7/5/01 -- We do not need any date_to_canonical conversion here
                -- because  we are not dealing with DDF/element related date here
                --
		l_ret_value := to_char(p_sf52_data.service_comp_date,'DDMMYYYY');

	elsif (lower(p_field_name) = 'supervisory_status') then
		l_ret_value := p_sf52_data.supervisory_status;

	elsif (lower(p_field_name) = 'tenure') then
		l_ret_value := p_sf52_data.tenure;

	elsif (lower(p_field_name) = 'to_adj_basic_pay') then
		l_ret_value := p_sf52_data.to_adj_basic_pay;

	elsif (lower(p_field_name) = 'to_ap_premium_pay_indicator') then
		l_ret_value := p_sf52_data.to_ap_premium_pay_indicator;

	elsif (lower(p_field_name) = 'to_auo_premium_pay_indicator') then
		l_ret_value := p_sf52_data.to_auo_premium_pay_indicator;

	elsif (lower(p_field_name) = 'to_au_overtime') then
		l_ret_value := p_sf52_data.to_au_overtime;

	elsif (lower(p_field_name) = 'to_availability_pay') then
		l_ret_value := p_sf52_data.to_availability_pay;

	elsif (lower(p_field_name) = 'to_basic_pay') then
		l_ret_value := p_sf52_data.to_basic_pay;

	elsif (lower(p_field_name) = 'to_grade_id') then
		l_ret_value := p_sf52_data.to_grade_id;

	elsif (lower(p_field_name) = 'to_grade_or_level') then
		l_ret_value := p_sf52_data.to_grade_or_level;

	elsif (lower(p_field_name) = 'to_job_id') then
		l_ret_value := p_sf52_data.to_job_id;

	elsif (lower(p_field_name) = 'to_locality_adj') then
		l_ret_value := p_sf52_data.to_locality_adj;

	elsif (lower(p_field_name) = 'to_occ_code') then
		l_ret_value := p_sf52_data.to_occ_code;

	elsif (lower(p_field_name) = 'to_office_symbol') then
		l_ret_value := p_sf52_data.to_office_symbol;

	elsif (lower(p_field_name) = 'to_organization_id') then
		l_ret_value := p_sf52_data.to_organization_id;

	elsif (lower(p_field_name) = 'to_other_pay_amount') then
		l_ret_value := p_sf52_data.to_other_pay_amount;

	elsif (lower(p_field_name) = 'to_pay_basis') then
		l_ret_value := p_sf52_data.to_pay_basis;

	elsif (lower(p_field_name) = 'to_pay_plan') then
		l_ret_value := p_sf52_data.to_pay_plan;

	elsif (lower(p_field_name) = 'to_position_id') then
		l_ret_value := p_sf52_data.to_position_id;

	elsif (lower(p_field_name) = 'to_position_org_line1') then
		l_ret_value := p_sf52_data.to_position_org_line1;

	elsif (lower(p_field_name) = 'to_position_org_line2') then
		l_ret_value := p_sf52_data.to_position_org_line2;

	elsif (lower(p_field_name) = 'to_position_org_line3') then
		l_ret_value := p_sf52_data.to_position_org_line3;

	elsif (lower(p_field_name) = 'to_position_org_line4') then
		l_ret_value := p_sf52_data.to_position_org_line4;

	elsif (lower(p_field_name) = 'to_position_org_line5') then
		l_ret_value := p_sf52_data.to_position_org_line5;

	elsif (lower(p_field_name) = 'to_position_org_line6') then
		l_ret_value := p_sf52_data.to_position_org_line6;

	elsif (lower(p_field_name) = 'to_position_number') then
		l_ret_value := p_sf52_data.to_position_number;

	elsif (lower(p_field_name) = 'to_position_seq_no') then
		l_ret_value := p_sf52_data.to_position_seq_no;

	elsif (lower(p_field_name) = 'to_position_title') then
		l_ret_value := p_sf52_data.to_position_title;

	elsif (lower(p_field_name) = 'to_retention_allowance') then
		l_ret_value := p_sf52_data.to_retention_allowance;

	elsif (lower(p_field_name) = 'to_retention_allow_percentage') then
		l_ret_value := p_sf52_data.to_retention_allow_percentage;

	elsif (lower(p_field_name) = 'to_staffing_differential') then
		l_ret_value := p_sf52_data.to_staffing_differential;

	elsif (lower(p_field_name) = 'to_staffing_diff_percentage') then
		l_ret_value := p_sf52_data.to_staffing_diff_percentage;

	elsif (lower(p_field_name) = 'to_step_or_rate') then
		l_ret_value := p_sf52_data.to_step_or_rate;

	elsif (lower(p_field_name) = 'to_supervisory_differential') then
		l_ret_value := p_sf52_data.to_supervisory_differential;

	elsif (lower(p_field_name) = 'to_supervisory_diff_percentage') then
		l_ret_value := p_sf52_data.to_supervisory_diff_percentage;

	elsif (lower(p_field_name) = 'to_total_salary') then
		l_ret_value := p_sf52_data.to_total_salary;

	elsif (lower(p_field_name) = 'veterans_preference') then
		l_ret_value := p_sf52_data.veterans_preference;

	elsif (lower(p_field_name) = 'veterans_pref_for_rif') then
		l_ret_value := p_sf52_data.veterans_pref_for_rif;

	elsif (lower(p_field_name) = 'veterans_status') then
		l_ret_value := p_sf52_data.veterans_status;

	elsif (lower(p_field_name) = 'work_schedule') then
		l_ret_value := p_sf52_data.work_schedule;

	elsif (lower(p_field_name) = 'work_schedule_desc') then
		l_ret_value := p_sf52_data.work_schedule_desc;

	elsif (lower(p_field_name) = 'year_degree_attained') then
		l_ret_value := p_sf52_data.year_degree_attained;

	elsif (lower(p_field_name) = 'first_noa_information1') then
		l_ret_value := p_sf52_data.first_noa_information1;

	elsif (lower(p_field_name) = 'first_noa_information2') then
		l_ret_value := p_sf52_data.first_noa_information2;

	elsif (lower(p_field_name) = 'first_noa_information3') then
		l_ret_value := p_sf52_data.first_noa_information3;

	elsif (lower(p_field_name) = 'first_noa_information4') then
		l_ret_value := p_sf52_data.first_noa_information4;

	elsif (lower(p_field_name) = 'first_noa_information5') then
		l_ret_value := p_sf52_data.first_noa_information5;

	elsif (lower(p_field_name) = 'second_lac1_information1') then
		l_ret_value := p_sf52_data.second_lac1_information1;

	elsif (lower(p_field_name) = 'second_lac1_information2') then
		l_ret_value := p_sf52_data.second_lac1_information2;

	elsif (lower(p_field_name) = 'second_lac1_information3') then
		l_ret_value := p_sf52_data.second_lac1_information3;

	elsif (lower(p_field_name) = 'second_lac1_information4') then
		l_ret_value := p_sf52_data.second_lac1_information4;

	elsif (lower(p_field_name) = 'second_lac1_information5') then
		l_ret_value := p_sf52_data.second_lac1_information5;

	elsif (lower(p_field_name) = 'second_lac2_information1') then
		l_ret_value := p_sf52_data.second_lac2_information1;

	elsif (lower(p_field_name) = 'second_lac2_information2') then
		l_ret_value := p_sf52_data.second_lac2_information2;

	elsif (lower(p_field_name) = 'second_lac2_information3') then
		l_ret_value := p_sf52_data.second_lac2_information3;

	elsif (lower(p_field_name) = 'second_lac2_information4') then
		l_ret_value := p_sf52_data.second_lac2_information4;

	elsif (lower(p_field_name) = 'second_lac2_information5') then
		l_ret_value := p_sf52_data.second_lac2_information5;

	elsif (lower(p_field_name) = 'second_noa_information1') then
		l_ret_value := p_sf52_data.second_noa_information1;

	elsif (lower(p_field_name) = 'second_noa_information2') then
		l_ret_value := p_sf52_data.second_noa_information2;

	elsif (lower(p_field_name) = 'second_noa_information3') then
		l_ret_value := p_sf52_data.second_noa_information3;

	elsif (lower(p_field_name) = 'second_noa_information4') then
		l_ret_value := p_sf52_data.second_noa_information4;

	elsif (lower(p_field_name) = 'second_noa_information5') then
		l_ret_value := p_sf52_data.second_noa_information5;

	elsif (lower(p_field_name) = 'first_lac1_information1') then
		l_ret_value := p_sf52_data.first_lac1_information1;

	elsif (lower(p_field_name) = 'first_lac1_information2') then
		l_ret_value := p_sf52_data.first_lac1_information2;

	elsif (lower(p_field_name) = 'first_lac1_information3') then
		l_ret_value := p_sf52_data.first_lac1_information3;

	elsif (lower(p_field_name) = 'first_lac1_information4') then
		l_ret_value := p_sf52_data.first_lac1_information4;

	elsif (lower(p_field_name) = 'first_lac1_information5') then
		l_ret_value := p_sf52_data.first_lac1_information5;

	elsif (lower(p_field_name) = 'first_lac2_information1') then
		l_ret_value := p_sf52_data.first_lac2_information1;

	elsif (lower(p_field_name) = 'first_lac2_information2') then
		l_ret_value := p_sf52_data.first_lac2_information2;

	elsif (lower(p_field_name) = 'first_lac2_information3') then
		l_ret_value := p_sf52_data.first_lac2_information3;

	elsif (lower(p_field_name) = 'first_lac2_information4') then
		l_ret_value := p_sf52_data.first_lac2_information4;

	elsif (lower(p_field_name) = 'first_lac2_information5') then
		l_ret_value := p_sf52_data.first_lac2_information5;

	elsif (lower(p_field_name) = 'attribute_category') then
		l_ret_value := p_sf52_data.attribute_category;

	elsif (lower(p_field_name) = 'attribute1') then
		l_ret_value := p_sf52_data.attribute1;

	elsif (lower(p_field_name) = 'attribute2') then
		l_ret_value := p_sf52_data.attribute2;

	elsif (lower(p_field_name) = 'attribute3') then
		l_ret_value := p_sf52_data.attribute3;

	elsif (lower(p_field_name) = 'attribute4') then
		l_ret_value := p_sf52_data.attribute4;

	elsif (lower(p_field_name) = 'attribute5') then
		l_ret_value := p_sf52_data.attribute5;

	elsif (lower(p_field_name) = 'attribute6') then
		l_ret_value := p_sf52_data.attribute6;

	elsif (lower(p_field_name) = 'attribute7') then
		l_ret_value := p_sf52_data.attribute7;

	elsif (lower(p_field_name) = 'attribute8') then
		l_ret_value := p_sf52_data.attribute8;

	elsif (lower(p_field_name) = 'attribute9') then
		l_ret_value := p_sf52_data.attribute9;

	elsif (lower(p_field_name) = 'attribute10') then
		l_ret_value := p_sf52_data.attribute10;

	elsif (lower(p_field_name) = 'attribute11') then
		l_ret_value := p_sf52_data.attribute11;

	elsif (lower(p_field_name) = 'attribute12') then
		l_ret_value := p_sf52_data.attribute12;

	elsif (lower(p_field_name) = 'attribute13') then
		l_ret_value := p_sf52_data.attribute13;

	elsif (lower(p_field_name) = 'attribute14') then
		l_ret_value := p_sf52_data.attribute14;

	elsif (lower(p_field_name) = 'attribute15') then
		l_ret_value := p_sf52_data.attribute15;

	elsif (lower(p_field_name) = 'attribute16') then
		l_ret_value := p_sf52_data.attribute16;

	elsif (lower(p_field_name) = 'attribute17') then
		l_ret_value := p_sf52_data.attribute17;

	elsif (lower(p_field_name) = 'attribute18') then
		l_ret_value := p_sf52_data.attribute18;

	elsif (lower(p_field_name) = 'attribute19') then
		l_ret_value := p_sf52_data.attribute19;

	elsif (lower(p_field_name) = 'attribute20') then
		l_ret_value := p_sf52_data.attribute20;
      end if;
	hr_utility.set_location('Leaving: ' ||l_proc, 20);
	return l_ret_value;
END;

   Procedure copy_to_new_rg_shared(
				p_action_num	IN NUMBER,
				p_field_name	IN VARCHAR2,
				p_from_field	IN VARCHAR2,
				p_to_field	IN OUT NOCOPY VARCHAR2,
				p_fld_nm_copy_from IN VARCHAR2 default null) IS

	l_found1		boolean:=false;
	l_found2		boolean:=false;
	l_count1		number :=0;
	l_count2		number :=0;
	l_from_to		varchar2(1) ;
	l_field_name	varchar2(150);
	l_to_field_name	varchar2(150);
	l_dual_actions	ghr_dual_proc_methods%rowtype;
	l_session_var	ghr_history_api.g_session_var_type;
	l_pa_history_id	ghr_pa_history.pa_history_id%type;
	l_to_field		varchar2(2000);
	l_proc		varchar2(30):='copy_to_new_rg_shared';

   Begin

        l_to_field := p_to_field; --NOCOPY Changes

 	hr_utility.set_location('Entering:'|| l_proc, 5);
	-- initialize l_fld_names_tab1 with proc_methods for first noa.
      FOR l_count IN 1..l_column_count1 LOOP
          if p_field_name = l_fld_names_tab1(l_count).form_field_name then
		l_count1 := l_count;
		l_found1 := TRUE;
	      exit;
          end if;
      END LOOP;
	-- initialize l_fld_names_tab2 with proc_methods for second noa.
      FOR l_count IN 1..l_column_count2 LOOP
          if p_field_name = l_fld_names_tab2(l_count).form_field_name then
		l_count2 := l_count;
		l_found2 := TRUE;
	      exit;
          end if;
      END LOOP;

	if (p_action_num = 1) then
		if (not l_found1) then
			-- field is 'NE' for this action. Null it out.
			p_to_field := null;
		elsif (not l_found2) then
			-- field is 'NE' for second action. But not 'NE' for first action. So, pass it along as is.
			null;
		elsif ((l_fld_names_tab1(l_count1).process_method_code = 'UE' or
			l_fld_names_tab1(l_count1).process_method_code = 'APUE')  and
			(l_fld_names_tab2(l_count2).process_method_code = 'UE' or
			l_fld_names_tab2(l_count2).process_method_code = 'APUE')) then
			-- this covers the case where the user can enter data for both actions.
			-- i.e. - APUE/UE first action with a APUE/UE second action.
			if (p_pa_req.first_noa_code = '893') then--Bug# 8926400
				-- this is a WGI first action, and requires special handling of UE/APUE-UE/APUE cases.
				if (LOWER(SUBSTR(p_field_name,0,3)) = 'to_') then
					-- this is to information for the first action, do nothing with this field as it is
					-- derived by calling procedure. (i.e. - it doesn't matter if we pass it along as is
					-- bacause calling procedure is going to overwrite this information anyway.
					null;
				else
					-- this is non-to information, go ahead and refresh it for the first action.
					-- according to the requirement, the only fields touched by a WGI first action
					-- are to fields. To fields are derived by calling procedure. All other fields
					-- are refreshed from db here.
					if (not l_refresh_called) then
						-- call refresh with to_position = from-position, since to_position never changes
						-- for a WGI first action (any position change will go to the second action).
						l_pa_req_ref.from_position_id       := p_pa_req.from_position_id;
						l_pa_req_ref.to_position_id         := p_pa_req.from_position_id;
						l_pa_req_ref.effective_date         := p_pa_req.effective_date;
						l_pa_req_ref.employee_assignment_id := p_pa_req.employee_assignment_id;
						--6850492
				                l_pa_req_ref.pa_request_id := p_pa_req.pa_request_id;
                    				--6850492

						refresh_pa_request(p_person_id	       => p_pa_req.person_id,
									 p_effective_date	       => p_pa_req.effective_date,
									 p_sf52_data	       => l_pa_req_ref);

						l_refresh_called := TRUE;
					end if;
					p_to_field := get_field_info(	p_field_name 	=> NVL(p_fld_nm_copy_from,p_field_name),
										p_sf52_data		=> l_pa_req_ref);
				end if;
			else
				-- non-WGI first action.
				-- here's the handling for the new table:
				if (l_noa_family_code is null) then
					open get_dual_family(	p_first_noa_id 	=>	p_pa_req.first_noa_id,
									p_second_noa_id	=>	p_pa_req.second_noa_id);
					fetch get_dual_family into l_noa_family_code;
					close get_dual_family;
				end if;
				if (LOWER(SUBSTR(p_field_name,0,3)) = 'to_') then
					open get_dual_action(	p_noa_family_code	=>	l_noa_family_code,
									p_form_field_name	=>	'TO_INFO');
					fetch get_dual_action into l_dual_actions;
					if (LOWER(l_dual_actions.first_noa_proc_method) = 'uf') then
						-- copy corresponding 'from' value into 'to' value
						-- Right now, all the calls wil have null in p_fld_nm_copy_from
						-- or if p_field_name is 'TO_...' and p_fld_nm_copy_from has a value
						-- then it will also be 'TO_....'
						l_field_name := nvl(p_fld_nm_copy_from, p_field_name);
						l_to_field_name := REPLACE(l_field_name, 'TO_','FROM_');
						p_to_field := get_field_info(	p_field_name	=>	l_to_field_name,
											p_sf52_data		=>	p_pa_req);
					elsif (LOWER(l_dual_actions.first_noa_proc_method) = 'ue') then
						NULL;
					else
						close get_dual_action;
						hr_utility.set_message(8301, 'GHR_38414_UNSUPPORTED_ACT_TYP');
						hr_utility.set_message_token('ACTION_TYPE', l_dual_actions.first_noa_proc_method);
						hr_utility.raise_error;
					end if;
					close get_dual_action;
				else
					open get_dual_action(	p_noa_family_code	=>	l_noa_family_code,
									p_form_field_name	=>	p_field_name);
					fetch get_dual_action into l_dual_actions;
					if (LOWER(l_dual_actions.first_noa_proc_method) = 'rp') then
						if (not l_refresh_called) then

							l_pa_req_ref.from_position_id       := l_pa_req.from_position_id;
							-- if this is a return_to_duty first action, then set to_position = from_position
							-- for refresh call. return_to_duty first actions always put to_position info
							-- with the 2nd action.
							/*if (p_pa_req.noa_family_code = 'RETURN_TO_DUTY') then
								l_pa_req_ref.to_position_id         := l_pa_req.from_position_id;
							else*/
								l_pa_req_ref.to_position_id         := l_pa_req.to_position_id;
							--end if;

							l_pa_req_ref.effective_date         := p_pa_req.effective_date;
							l_pa_req_ref.employee_assignment_id := p_pa_req.employee_assignment_id;
							-- 8288066 Modified to assign step or rate as step or rate is getting
							-- assigned with the from value
							if p_pa_req.noa_family_code = 'RETURN_TO_DUTY' then
                        				    l_pa_req_ref.to_step_or_rate := p_pa_req.to_step_or_rate;
			                         	end if;

							refresh_pa_request(p_person_id	       => p_pa_req.person_id,
										 p_effective_date	       => p_pa_req.effective_date,
										 p_sf52_data	       => l_pa_req_ref);
							l_refresh_called := TRUE;
						end if;
						p_to_field := get_field_info(	p_field_name 	=> nvl(p_fld_nm_copy_from,p_field_name),
											p_sf52_data		=> l_pa_req_ref);
					elsif (LOWER(l_dual_actions.first_noa_proc_method) = 'ue') then
						-- do nothing, pass it along as is.
						null;
					else
						-- unsupported type. Throw error.
						close get_dual_action;
						hr_utility.set_message(8301, 'GHR_38498_UNSUPPORTED_ACT_TYP');
						hr_utility.set_message_token('ACTION_TYPE', l_dual_actions.first_noa_proc_method);
						hr_utility.raise_error;
					end if;
					close get_dual_action;
				end if;
			end if;
		elsif (l_fld_names_tab1(l_count1).process_method_code = 'AP' and
			l_fld_names_tab2(l_count2).process_method_code = 'AP') or
			((l_fld_names_tab1(l_count1).process_method_code = 'APUE' or
			(l_fld_names_tab1(l_count1).process_method_code = 'UE') and
			l_fld_names_tab2(l_count2).process_method_code = 'AP')) then
			-- Either it is 'AP' for both actions, pass the value along as is. Or
			-- first action is 'APUE'/'AP' and second action is 'AP', so pass the value
			-- along as is.
			null;
		elsif (l_fld_names_tab1(l_count1).process_method_code = 'AP' and
			(l_fld_names_tab2(l_count2).process_method_code = 'APUE' or
				l_fld_names_tab2(l_count2).process_method_code = 'UE')) then
			-- first action is 'AP', second action is 'APUE'/'UE'. So, repopulate the field from the database,
			-- as there may be changes to it that have to do with the second action, and not the first.
			if (not l_refresh_called) then
				l_pa_req_ref.from_position_id       := l_pa_req.from_position_id;
				-- if this is a return_to_duty first action, then set to_position = from_position
				-- for refresh call. return_to_duty first actions always put to_position info
				-- with the 2nd action.
				hr_utility.set_location('noa_family_code: ' || l_noa_family_code, 99999);
				/*if (p_pa_req.noa_family_code = 'RETURN_TO_DUTY') then
					l_pa_req_ref.to_position_id         := l_pa_req.from_position_id;
					--This has been added to fetch PRD from the Parent Action
					--While processing for Return to Duty
					l_pa_req_ref.pa_request_id          := l_pa_req.pa_request_id;
				else */
					l_pa_req_ref.to_position_id         := l_pa_req.to_position_id;
				--end if;
				-- 8288066 Modified to assign step or rate as step or rate is getting
							-- assigned with the from value
				if p_pa_req.noa_family_code = 'RETURN_TO_DUTY' then
				    l_pa_req_ref.to_step_or_rate := p_pa_req.to_step_or_rate;
				end if;

				l_pa_req_ref.effective_date         := p_pa_req.effective_date;
				l_pa_req_ref.employee_assignment_id := p_pa_req.employee_assignment_id;

				refresh_pa_request(p_person_id	       => p_pa_req.person_id,
							 p_effective_date	       => p_pa_req.effective_date,
							 p_sf52_data	       => l_pa_req_ref);
				l_refresh_called := TRUE;
			end if;
			p_to_field := get_field_info(	p_field_name 	=> nvl(p_fld_nm_copy_from,p_field_name),
								p_sf52_data		=> l_pa_req_ref);
		else
			-- Any other Proc_Method like NE/NE or NE/AP etc. need not be catered to.
			null;
		end if;
	elsif (p_action_num = 2) then
		if (not l_found2) then
			-- field is 'NE' for this action. Null it out.
			p_to_field := null;
		elsif (not l_found1) then
			-- field is 'NE' for first action. But not 'NE' for second action. So, pass it along as is.
			null;
		elsif ((l_fld_names_tab1(l_count1).process_method_code = 'UE' or
			l_fld_names_tab1(l_count1).process_method_code = 'APUE')  and
			(l_fld_names_tab2(l_count2).process_method_code = 'UE' or
			l_fld_names_tab2(l_count2).process_method_code = 'APUE')) then
			-- this covers the case where the user can enter data for both actions.
			-- i.e. - APUE/UE first action with a APUE/UE second action.
			if (p_pa_req.first_noa_code = '893') then--Bug# 8926400
				-- this is a WGI first action, and requires special handling of UE/APUE-UE/APUE cases.
				-- when processing the second action of a dual action with WGI as the first action,
				-- we will always pass the field along as is. The reasons for this are as follows:
				-- 1) If the form field is a to field, then it is automatically associated with the second action.
				-- 2) Non-to field information, is also passed along as is. The requirement specifies that
				--    all information on the form is associated with the second action. The only exception to this
				--	is from information, which is refreshed from the database by the calling procedure whenever
				--	there is a WGI first action.
				null;
			else
				-- non-WGI first action
				-- Here's the functionality to access the new table:
				if (l_noa_family_code is null) then
					open get_dual_family(	p_first_noa_id 	=>	p_pa_req.first_noa_id,
									p_second_noa_id	=>	p_pa_req.second_noa_id);
					fetch get_dual_family into l_noa_family_code;
					close get_dual_family;
				end if;
				if (LOWER(SUBSTR(p_field_name,0,3)) = 'to_') then
					open get_dual_action(	p_noa_family_code	=>	l_noa_family_code,
									p_form_field_name	=>	'TO_INFO');
					fetch get_dual_action into l_dual_actions;
					if (LOWER(l_dual_actions.second_noa_proc_method) = 'ue') then
						-- do nothing, pass it along as is.
						null;
					else
						close get_dual_action;
						hr_utility.set_message(8301, 'GHR_38418_UNSUPPORTED_ACT_TYP');
						hr_utility.set_message_token('ACTION_TYPE', l_dual_actions.second_noa_proc_method);
						hr_utility.raise_error;
					end if;
					close get_dual_action;
				else
					open get_dual_action(	p_noa_family_code	=>	l_noa_family_code,
									p_form_field_name	=>	p_field_name);
					fetch get_dual_action into l_dual_actions;
					if (LOWER(l_dual_actions.second_noa_proc_method) = 'ue' ) then
						-- do nothing, pass it along as is.
						null;
					else
						-- unsupported type. Throw error.
						close get_dual_action;
						hr_utility.set_message(8301, 'GHR_38418_UNSUPPORTED_ACT_TYP');
						hr_utility.set_message_token('ACTION_TYPE', l_dual_actions.second_noa_proc_method);
						hr_utility.raise_error;
					end if;
					close get_dual_action;
				end if;
			end if;
		elsif ((l_fld_names_tab1(l_count1).process_method_code = 'UE' or
			l_fld_names_tab1(l_count1).process_method_code = 'APUE' or
			l_fld_names_tab1(l_count1).process_method_code = 'AP' ) and
			 (l_fld_names_tab2(l_count2).process_method_code = 'AP')) then
			if ((LOWER(SUBSTR(p_field_name, 0, 5))) = 'from_') then
				-- if this is a separation/separation incentive dual
				-- action, then take the from info from the first action as
				-- the from info for the second action. This is necessary because
				-- the separation first action has no to info.
				if (	(p_pa_req.first_noa_code in ('302','303','304','312','317') and --Bug# 8926400
					p_pa_req.second_noa_code = '825') or p_pa_req.first_noa_code
					in ('280','292','893')) then
					null;
				else
					if (l_correction is null) then
						--determine if this is a correction of the 2nd action and act accordingly. i.e. -
						-- only refresh if this is a correction.
					--	ghr_history_api.get_g_session_var(l_session_var);
						open get_root_pa_hist_id(cp_pa_request_id	=>	p_pa_req.pa_request_id,
										cp_noa_id		=>	p_pa_req.second_noa_id);
						fetch get_root_pa_hist_id into l_pa_history_id;
						close get_root_pa_hist_id;

						-- if this cursor returned a null, then this means that this if the first time this
						-- dual action is being processed. i.e. - this is not a correction of the dual action.
						if l_pa_history_id is not null and p_pa_req.first_noa_code in ('002') then
							-- successfully found the root. Call refresh with this pa_history_id.
							l_correction := true;
							ghr_history_api.get_g_session_var(l_session_var);
							l_session_var.pa_history_id := l_pa_history_id;
							ghr_history_api.set_g_session_var(l_session_var);
							-- note that the following references to l_pa_req an p_pa_req are referencing definitions
							-- in assign_new_rg.
							l_pa_req_ref2.from_position_id       := l_pa_req.from_position_id;
							l_pa_req_ref2.to_position_id         := l_pa_req.to_position_id;
							l_pa_req_ref2.effective_date         := p_pa_req.effective_date;
							l_pa_req_ref2.employee_assignment_id := p_pa_req.employee_assignment_id;


							refresh_pa_request(p_person_id	       => p_pa_req.person_id,
										 p_effective_date	       => p_pa_req.effective_date,
										 p_sf52_data	       => l_pa_req_ref2);

							l_session_var.pa_history_id := null;
							ghr_history_api.set_g_session_var(l_session_var);
						else
							l_correction := false;
						end if;
					end if;

					if (l_correction = true) then
						l_to_field := get_field_info(	p_field_name 	=> nvl(p_fld_nm_copy_from,p_field_name),
											p_sf52_data		=> l_pa_req_ref2);
						-- only assign to p_to_field if it is not null. If it is null, then refresh didn't populate
						-- it, so we need to retain the original value.
						if (l_to_field is not null) then
							p_to_field := l_to_field;
						end if;
					else
						-- this branch covers the following case:
						-- We are processing the second action. The first action is 'APUE'/'UE' and
						-- the second action is 'AP'. This field is a from information field.
						-- in this case, we want to copy the from info from the corresponding to info.

						l_field_name := nvl(p_fld_nm_copy_from, p_field_name);
						l_to_field_name := REPLACE(l_field_name, 'FROM','TO');
						p_to_field := get_field_info(	p_field_name	=>	l_to_field_name,
										p_sf52_data		=>	p_pa_req);

					end if;
				end if;
			else
				-- if this is 'AP'/'AP' and is not from info, simply pass the value along as is.
				if ((l_fld_names_tab1(l_count1).process_method_code = 'AP') and
			 		(l_fld_names_tab2(l_count2).process_method_code = 'AP')) then
					null;
				else
					if (l_correction is null) then
						--determine if this is a correction of the 2nd action and act accordingly. i.e. -
						-- only refresh if this is a correction.
					--	ghr_history_api.get_g_session_var(l_session_var);
						open get_root_pa_hist_id(cp_pa_request_id	=>	p_pa_req.pa_request_id,
										cp_noa_id		=>	p_pa_req.second_noa_id);
						fetch get_root_pa_hist_id into l_pa_history_id;
						close get_root_pa_hist_id;
						-- if this cursor returned a null, then this means that this if the first time this
						-- dual action is being processed. i.e. - this is not a correction of the dual action.
						if l_pa_history_id is not null then
							-- successfully found the root. Call refresh with this pa_history_id.
							l_correction := true;
							ghr_history_api.get_g_session_var(l_session_var);
							l_session_var.pa_history_id := l_pa_history_id;
							ghr_history_api.set_g_session_var(l_session_var);
							-- note that the following references to l_pa_req an p_pa_req are referencing definitions
							-- in assign_new_rg.
							l_pa_req_ref2.from_position_id       := l_pa_req.from_position_id;
							l_pa_req_ref2.to_position_id         := l_pa_req.to_position_id;
							l_pa_req_ref2.effective_date         := p_pa_req.effective_date;
							l_pa_req_ref2.employee_assignment_id := p_pa_req.employee_assignment_id;

							refresh_pa_request(p_person_id	       => p_pa_req.person_id,
										 p_effective_date	       => p_pa_req.effective_date,
										 p_sf52_data	       => l_pa_req_ref2);
							l_session_var.pa_history_id := null;
							ghr_history_api.set_g_session_var(l_session_var);
						else
							l_correction := false;
						end if;
					end if;

					if (l_correction = true) then
						hr_utility.set_location('l_refresh_called_2' || l_proc,9165);
						l_to_field := get_field_info(	p_field_name 	=> nvl(p_fld_nm_copy_from,p_field_name),
											p_sf52_data		=> l_pa_req_ref2);
						-- only assign to p_to_field if it is not null. If it is null, then refresh didn't populate
						-- it, so we need to retain the original value.
						if (l_to_field is not null) then
							p_to_field := l_to_field;
						end if;
					end if;
				end if;
			end if;
		elsif (l_fld_names_tab1(l_count1).process_method_code = 'AP' and
			l_fld_names_tab2(l_count2).process_method_code = 'AP') or
		 	((l_fld_names_tab1(l_count1).process_method_code = 'AP' and
			(l_fld_names_tab2(l_count2).process_method_code = 'APUE' or
				l_fld_names_tab2(l_count2).process_method_code = 'UE'))) then
			-- This branch covers the following cases:
			-- 1) It is 'AP' for both actions, pass the value along as is.
			-- 2) First action is 'APUE'/'AP' and second action is 'AP', so pass the value
			-- 	along as is.
			-- 3) First action is 'AP', second action is 'APUE'/'UE'. So, pass the value along as is.
			null;
		else
			-- Any other Proc_Method like NE/NE or NE/AP etc. need not be catered to.
			null;
		end if;
	end if;

	hr_utility.set_location(' Return Value :' || p_to_field || '+++', 199);
	hr_utility.set_location('Leaving:'|| l_proc, 200);

EXCEPTION
  WHEN others THEN
     -- Reset IN OUT parameters and set OUT parameters

      p_to_field := l_to_field;

   hr_utility.set_location('Leaving  ' || l_proc,55);
   RAISE;

END copy_to_new_rg_shared;

   Procedure copy_to_new_rg(
				p_action_num	IN NUMBER,
				p_field_name	IN VARCHAR2,
				p_from_field	IN DATE,
				p_to_field	IN OUT NOCOPY DATE,
				p_fld_nm_copy_from IN VARCHAR2 default null) IS
	l_proc	varchar2(30):= 'copy_to_new_rg(date)';
	l_from_char varchar2(100);
	l_to_char	varchar2(100);
	l_to_field   Date;

BEGIN
	l_to_field := p_to_field; --NOCOPY Changes

	hr_utility.set_location('Entering: ' || l_proc, 5);
	l_from_char := to_char(p_from_field,'DDMMYYYY');
	l_to_char := to_char(p_to_field,'DDMMYYYY');
	copy_to_new_rg_shared(	p_action_num		=> p_action_num,
				p_field_name		=> p_field_name,
				p_from_field		=> l_from_char,
				p_to_field		=> l_to_char,
				p_fld_nm_copy_from	=> p_fld_nm_copy_from);

	p_to_field	:= to_date(l_to_char,'DDMMYYYY');
	hr_utility.set_location('Leaving: ' || l_proc, 35);


EXCEPTION
  WHEN others THEN
     -- Reset IN OUT parameters and set OUT parameters

      p_to_field := l_to_field;

   hr_utility.set_location('Leaving  ' || l_proc,50);
   RAISE;

END;

   Procedure copy_to_new_rg(
				p_action_num	IN NUMBER,
				p_field_name	IN VARCHAR2,
				p_from_field	IN VARCHAR2,
				p_to_field	IN OUT NOCOPY VARCHAR2,
				p_fld_nm_copy_from IN VARCHAR2 default null) IS

	l_proc	varchar2(30):= 'copy_to_new_rg(char)';
	l_to_field	VARCHAR2(2000);
BEGIN
	l_to_field := p_to_field; --NOCOPY Changes
	hr_utility.set_location('Entering: ' || l_proc, 5);
	copy_to_new_rg_shared(	p_action_num		=> p_action_num,
				p_field_name		=> p_field_name,
				p_from_field		=> p_from_field,
				p_to_field		=> p_to_field,
				p_fld_nm_copy_from	=> p_fld_nm_copy_from);

	hr_utility.set_location('Leaving: ' || l_proc, 10);

EXCEPTION
  WHEN others THEN
     -- Reset IN OUT parameters and set OUT parameters

      p_to_field := l_to_field;

   hr_utility.set_location('Leaving  ' || l_proc,55);
   RAISE;

END;

   Procedure copy_to_new_rg(
				p_action_num	IN NUMBER,
				p_field_name	IN VARCHAR2,
				p_from_field	IN NUMBER,
				p_to_field	IN OUT NOCOPY NUMBER,
				p_fld_nm_copy_from IN VARCHAR2 default null) IS
	l_proc	varchar2(30):= 'copy_to_new_rg(number)';
	l_from_char varchar2(100);
	l_to_char	varchar2(100);
	l_to_field	NUMBER;
BEGIN
        l_to_field := p_to_field; --NOCOPY Changes
	hr_utility.set_location('Entering: ' || l_proc, 5);
	l_from_char := to_char(p_from_field);
	l_to_char := to_char(p_to_field);
	copy_to_new_rg_shared(	p_action_num		=> p_action_num,
					p_field_name		=> p_field_name,
					p_from_field		=> l_from_char,
					p_to_field			=> l_to_char,
					p_fld_nm_copy_from	=> p_fld_nm_copy_from);
	p_to_field	:= to_number(l_to_char);

	hr_utility.set_location('Leaving: ' || l_proc, 35);

EXCEPTION
  WHEN others THEN
     -- Reset IN OUT parameters and set OUT parameters

      p_to_field := l_to_field;

   hr_utility.set_location('Leaving  ' || l_proc,56);
   RAISE;
END;


BEGIN
	l_pa_req :=p_pa_req ; ---NOCOPY Changes

 	hr_utility.set_location('Entering:'|| l_proc, 5);
	hr_utility.set_location(' no. of rows in table rg ' || to_char(l_column_count), 11);
	-- get list of all columns needed for the noa we are correcting.
   	initialize_fld_names_table(	p_noa_id  		=> p_pa_req.first_noa_id,
						p_fld_names_tab	=> l_fld_names_tab1);
	l_column_count1	:= l_column_count;
   	initialize_fld_names_table(	p_noa_id  		=> p_pa_req.second_noa_id,
						p_fld_names_tab	=> l_fld_names_tab2);
	l_column_count2	:= l_column_count;

	l_pa_req := p_pa_req;
	-- for all columns, set to null if not needed for the noa we are processing

-- Lines whih are commented meanss that this column value must be passed irrespective
-- of if it has been defined in proc_methods or not.
-- LINES WITH --? must be revisited. Not sure if we should be ignoring them or what.
-- LINES WITH --* means that column does not have any value. If this sf52 has not been processed
-- LINES WITH --** means that this column must be fetched by this processs before sending it to
-- update to database.
--	be sure to process all from fields first. assign_new_rg depends on these being done before all
--	other columns.

	copy_to_new_rg(p_action_num,'FROM_BASIC_PAY',p_pa_req.from_basic_pay,l_pa_req.from_basic_pay);
	copy_to_new_rg(p_action_num,'FROM_GRADE_OR_LEVEL',p_pa_req.from_grade_or_level,l_pa_req.from_grade_or_level);
	copy_to_new_rg(p_action_num,'FROM_LOCALITY_ADJ',p_pa_req.from_locality_adj,l_pa_req.from_locality_adj);
	copy_to_new_rg(p_action_num,'FROM_OCC_CODE',p_pa_req.from_occ_code,l_pa_req.from_occ_code);
--*	copy_to_new_rg(p_action_num,'FROM_OFFICE_SYMBOL',p_pa_req.from_office_symbol,l_pa_req.from_office_symbol);

	copy_to_new_rg(p_action_num,'FROM_OTHER_PAY_AMOUNT',p_pa_req.from_other_pay_amount,l_pa_req.from_other_pay_amount);

	copy_to_new_rg(p_action_num,'FROM_PAY_BASIS_DESC',p_pa_req.from_pay_basis,l_pa_req.from_pay_basis, 'FROM_PAY_BASIS');

	copy_to_new_rg(p_action_num,'FROM_PAY_PLAN',p_pa_req.from_pay_plan,l_pa_req.from_pay_plan);

	copy_to_new_rg(p_action_num,'FROM_POSITION_TITLE',p_pa_req.from_position_title,l_pa_req.from_position_title);
	copy_to_new_rg(p_action_num,'FROM_POSITION_TITLE',p_pa_req.from_position_id,l_pa_req.from_position_id,'FROM_POSITION_ID');

	copy_to_new_rg(p_action_num,'FROM_POSITION_ORG_LINE1',p_pa_req.from_position_org_line1,l_pa_req.from_position_org_line1);
	copy_to_new_rg(p_action_num,'FROM_POSITION_ORG_LINE2',p_pa_req.from_position_org_line2,l_pa_req.from_position_org_line2);
	copy_to_new_rg(p_action_num,'FROM_POSITION_ORG_LINE3',p_pa_req.from_position_org_line3,l_pa_req.from_position_org_line3);
	copy_to_new_rg(p_action_num,'FROM_POSITION_ORG_LINE4',p_pa_req.from_position_org_line4,l_pa_req.from_position_org_line4);
	copy_to_new_rg(p_action_num,'FROM_POSITION_ORG_LINE5',p_pa_req.from_position_org_line5,l_pa_req.from_position_org_line5);
	copy_to_new_rg(p_action_num,'FROM_POSITION_ORG_LINE6',p_pa_req.from_position_org_line6,l_pa_req.from_position_org_line6);
--	copy_to_new_rg(p_action_num,'FROM_POSITION_LOC3',p_pa_req.from_position_loc3,l_pa_req.from_position_loc3);

	copy_to_new_rg(p_action_num,'FROM_POSITION_NUMBER',p_pa_req.from_position_number,l_pa_req.from_position_number);
	copy_to_new_rg(p_action_num,'FROM_POSITION_SEQ_NO',p_pa_req.from_position_seq_no,l_pa_req.from_position_seq_no);
	copy_to_new_rg(p_action_num,'FROM_STEP_OR_RATE',p_pa_req.from_step_or_rate,l_pa_req.from_step_or_rate);
	copy_to_new_rg(p_action_num,'FROM_TOTAL_SALARY',p_pa_req.from_total_salary,l_pa_req.from_total_salary);
	copy_to_new_rg(p_action_num,'FROM_ADJ_BASIC_PAY',p_pa_req.from_adj_basic_pay,l_pa_req.from_adj_basic_pay);
--*	copy_to_new_rg(p_action_num,'FROM_AGENCY_CODE',p_pa_req.from_agency_code,l_pa_req.from_agency_code);
--*	copy_to_new_rg(p_action_num,'FROM_AGENCY_DESC',p_pa_req.from_agency_desc,l_pa_req.from_agency_desc);


--	copy_to_new_rg(p_action_num,'PA_REQUEST_ID',p_pa_req.pa_request_id,l_pa_req.pa_request_id);
--*	copy_to_new_rg(p_action_num,'PA_NOTIFICATION_ID',p_pa_req.pa_notification_id,l_pa_req.pa_notification_id);
--**	copy_to_new_rg(p_action_num,'NOA_FAMILY_CODE',p_pa_req.noa_family_code,l_pa_req.noa_family_code);
--	copy_to_new_rg(p_action_num,'ROUTING_GROUP_ID',p_pa_req.routing_group_id,l_pa_req.routing_group_id);
--	copy_to_new_rg(p_action_num,'PROPOSED_EFFECTIVE_ASAP_FLAG',p_pa_req.proposed_effective_asap_flag,l_pa_req.proposed_effective_asap_flag);
	copy_to_new_rg(p_action_num,'ACADEMIC_DISCIPLINE',p_pa_req.academic_discipline,l_pa_req.academic_discipline);
--	copy_to_new_rg(p_action_num,'ADDITIONAL_INFO_PERSON_ID',p_pa_req.additional_info_person_id,l_pa_req.additional_info_person_id);
--	copy_to_new_rg(p_action_num,'ADDITIONAL_INFO_TEL_NUMBER',p_pa_req.additional_info_tel_number,l_pa_req.additional_info_tel_number);
--*	copy_to_new_rg(p_action_num,'AGENCY_CODE',p_pa_req.agency_code,l_pa_req.agency_code);
--	copy_to_new_rg(p_action_num,'ALTERED_PA_REQUEST_ID',p_pa_req.altered_pa_request_id,l_pa_req.altered_pa_request_id);
	copy_to_new_rg(p_action_num,'ANNUITANT_INDICATOR',p_pa_req.annuitant_indicator,l_pa_req.annuitant_indicator);
	copy_to_new_rg(p_action_num,'ANNUITANT_INDICATOR_DESC',p_pa_req.annuitant_indicator_desc,l_pa_req.annuitant_indicator_desc);
	copy_to_new_rg(p_action_num,'APPROPRIATION_CODE1',p_pa_req.appropriation_code1,l_pa_req.appropriation_code1);
	copy_to_new_rg(p_action_num,'APPROPRIATION_CODE2',p_pa_req.appropriation_code2,l_pa_req.appropriation_code2);
--*	copy_to_new_rg(p_action_num,'APPROVAL_DATE',p_pa_req.approval_date,l_pa_req.approval_date);
--*	copy_to_new_rg(p_action_num,'APPROVING_OFFICIAL_WORK_TITLE',p_pa_req.approving_official_work_title,l_pa_req.approving_official_work_title);

--	copy_to_new_rg(p_action_num,'AUTHORIZED_BY_PERSON_ID',p_pa_req.authorized_by_person_id,l_pa_req.authorized_by_person_id);
--	copy_to_new_rg(p_action_num,'AUTHORIZED_BY_TITLE',p_pa_req.authorized_by_title,l_pa_req.authorized_by_title);
	copy_to_new_rg(p_action_num,'AWARD_AMOUNT',p_pa_req.award_amount,l_pa_req.award_amount);
	copy_to_new_rg(p_action_num,'AWARD_UOM',p_pa_req.award_uom,l_pa_req.award_uom);
	copy_to_new_rg(p_action_num,'BARGAINING_UNIT_STATUS',p_pa_req.bargaining_unit_status,l_pa_req.bargaining_unit_status);
	copy_to_new_rg(p_action_num,'CITIZENSHIP',p_pa_req.citizenship,l_pa_req.citizenship);
--	copy_to_new_rg(p_action_num,'CONCURRENCE_DATE',p_pa_req.concurrence_date,l_pa_req.concurrence_date);
	copy_to_new_rg(p_action_num,'DUTY_STATION_CODE',p_pa_req.duty_station_code,l_pa_req.duty_station_code);
	copy_to_new_rg(p_action_num,'DUTY_STATION_DESC',p_pa_req.duty_station_desc,l_pa_req.duty_station_desc);
	-- Copied on the basis of DUTY_STATION_DESC
	copy_to_new_rg(p_action_num,'DUTY_STATION_DESC',p_pa_req.duty_station_id,l_pa_req.duty_station_id,'DUTY_STATION_ID');
	copy_to_new_rg(p_action_num,'DUTY_STATION_DESC',p_pa_req.duty_station_location_id,l_pa_req.duty_station_location_id,'DUTY_STATION_LOCATION_ID');
	copy_to_new_rg(p_action_num,'EDUCATION_LEVEL',p_pa_req.education_level,l_pa_req.education_level);

--	copy_to_new_rg(p_action_num,'EFFECTIVE_DATE',p_pa_req.effective_date,l_pa_req.effective_date);
--	copy_to_new_rg(p_action_num,'EMPLOYEE_ASSIGNMENT_ID',p_pa_req.employee_assignment_id,l_pa_req.employee_assignment_id)

	copy_to_new_rg(p_action_num,'EMPLOYEE_DATE_OF_BIRTH',p_pa_req.employee_date_of_birth,l_pa_req.employee_date_of_birth);
--*	copy_to_new_rg(p_action_num,'EMPLOYEE_DEPT_OR_AGENCY',p_pa_req.employee_dept_or_agency,l_pa_req.employee_dept_or_agency);
	copy_to_new_rg(p_action_num,'EMPLOYEE_FIRST_NAME',p_pa_req.employee_first_name,l_pa_req.employee_first_name);
--	copy_to_new_rg(p_action_num,'EMPLOYEE_LAST_NAME',p_pa_req.employee_last_name,l_pa_req.employee_last_name);
	copy_to_new_rg(p_action_num,'EMPLOYEE_MIDDLE_NAMES',p_pa_req.employee_middle_names,l_pa_req.employee_middle_names);
--	copy_to_new_rg(p_action_num,'EMPLOYEE_NATIONAL_IDENTIFIER',p_pa_req.employee_national_identifier,l_pa_req.employee_national_identifier);
	copy_to_new_rg(p_action_num,'FEGLI',p_pa_req.fegli,l_pa_req.fegli);
	copy_to_new_rg(p_action_num,'FEGLI_DESC',p_pa_req.fegli_desc,l_pa_req.fegli_desc);
	copy_to_new_rg(p_action_num,'FLSA_CATEGORY',p_pa_req.flsa_category,l_pa_req.flsa_category);
-- Can modify the code to copy all the address lines if address_line1 is copied
	copy_to_new_rg(p_action_num,'FORWARDING_ADDRESS_LINE1',p_pa_req.forwarding_address_line1,l_pa_req.forwarding_address_line1);
	copy_to_new_rg(p_action_num,'FORWARDING_ADDRESS_LINE2',p_pa_req.forwarding_address_line2,l_pa_req.forwarding_address_line2);
	copy_to_new_rg(p_action_num,'FORWARDING_ADDRESS_LINE3',p_pa_req.forwarding_address_line3,l_pa_req.forwarding_address_line3);

	copy_to_new_rg(p_action_num,'FORWARDING_COUNTRY_SHORT_NAME',p_pa_req.forwarding_country,l_pa_req.forwarding_country,'FORWARDING_COUNTRY');
	copy_to_new_rg(p_action_num,'FORWARDING_COUNTRY_SHORT_NAME',p_pa_req.forwarding_country_short_name,l_pa_req.forwarding_country_short_name);
	copy_to_new_rg(p_action_num,'FORWARDING_POSTAL_CODE',p_pa_req.forwarding_postal_code,l_pa_req.forwarding_postal_code);
	copy_to_new_rg(p_action_num,'FORWARDING_REGION_2',p_pa_req.forwarding_region_2,l_pa_req.forwarding_region_2);
	copy_to_new_rg(p_action_num,'FORWARDING_TOWN_OR_CITY',p_pa_req.forwarding_town_or_city,l_pa_req.forwarding_town_or_city);

	copy_to_new_rg(p_action_num,'FUNCTIONAL_CLASS',p_pa_req.functional_class,l_pa_req.functional_class);
--	copy_to_new_rg(p_action_num,'NOTEPAD',p_pa_req.notepad,l_pa_req.notepad);
	copy_to_new_rg(p_action_num,'PART_TIME_HOURS',p_pa_req.part_time_hours,l_pa_req.part_time_hours);
	copy_to_new_rg(p_action_num,'PAY_RATE_DETERMINANT',p_pa_req.pay_rate_determinant,l_pa_req.pay_rate_determinant);
--*	copy_to_new_rg(p_action_num,'PERSONNEL_OFFICE_ID',p_pa_req.personnel_office_id,l_pa_req.personnel_office_id);
--	copy_to_new_rg(p_action_num,'PERSON_ID',p_pa_req.person_id,l_pa_req.person_id);
	copy_to_new_rg(p_action_num,'POSITION_OCCUPIED',p_pa_req.position_occupied,l_pa_req.position_occupied);
--	copy_to_new_rg(p_action_num,'PROPOSED_EFFECTIVE_DATE',p_pa_req.proposed_effective_date,l_pa_req.proposed_effective_date);

--	copy_to_new_rg(p_action_num,'REQUESTED_BY_PERSON_ID',p_pa_req.requested_by_person_id,l_pa_req.requested_by_person_id);

--	copy_to_new_rg(p_action_num,'REQUESTED_BY_TITLE',p_pa_req.requested_by_title,l_pa_req.requested_by_title);

--	copy_to_new_rg(p_action_num,'REQUESTED_DATE',p_pa_req.requested_date,l_pa_req.requested_date);

--	copy_to_new_rg(p_action_num,'REQUESTING_OFFICE_REMARKS_DESC',p_pa_req.requesting_office_remarks_desc,l_pa_req.requesting_office_remarks_desc);

	copy_to_new_rg(p_action_num,'REQUESTING_OFFICE_REMARKS_FLAG',p_pa_req.requesting_office_remarks_flag,l_pa_req.requesting_office_remarks_flag);
--	copy_to_new_rg(p_action_num,'REQUEST_NUMBER',p_pa_req.request_number,l_pa_req.request_number);

	copy_to_new_rg(p_action_num,'RESIGN_AND_RETIRE_REASON_DESC',p_pa_req.resign_and_retire_reason_desc,l_pa_req.resign_and_retire_reason_desc);
	copy_to_new_rg(p_action_num,'RETIREMENT_PLAN',p_pa_req.retirement_plan,l_pa_req.retirement_plan);

	copy_to_new_rg(p_action_num,'RETIREMENT_PLAN_DESC',p_pa_req.retirement_plan_desc,l_pa_req.retirement_plan_desc);

	copy_to_new_rg(p_action_num,'SERVICE_COMP_DATE',p_pa_req.service_comp_date,l_pa_req.service_comp_date);

	copy_to_new_rg(p_action_num,'SUPERVISORY_STATUS',p_pa_req.supervisory_status,l_pa_req.supervisory_status);

	copy_to_new_rg(p_action_num,'TENURE',p_pa_req.tenure,l_pa_req.tenure);
	copy_to_new_rg(p_action_num,'TO_POSITION_TITLE',p_pa_req.to_adj_basic_pay,l_pa_req.to_adj_basic_pay, 'TO_ADJ_BASIC_PAY');

	copy_to_new_rg(p_action_num,'TO_POSITION_TITLE',p_pa_req.to_basic_pay,l_pa_req.to_basic_pay,'TO_BASIC_PAY');
	copy_to_new_rg(p_action_num,'TO_POSITION_TITLE',p_pa_req.to_locality_adj,l_pa_req.to_locality_adj,'TO_LOCALITY_ADJ');

	copy_to_new_rg(p_action_num,'TO_POSITION_TITLE',p_pa_req.to_occ_code,l_pa_req.to_occ_code,'TO_OCC_CODE');
--*	copy_to_new_rg(p_action_num,'TO_OFFICE_SYMBOL',p_pa_req.to_office_symbol,l_pa_req.to_office_symbol);

--	copy_to_new_rg(p_action_num,'TO_ORGANIZATION_NAME',p_pa_req.to_organization_id,l_pa_req.to_organization_id);
	copy_to_new_rg(p_action_num,'TO_POSITION_TITLE',p_pa_req.to_position_org_line1,l_pa_req.to_position_org_line1,'TO_POSITION_ORG_LINE1');
	copy_to_new_rg(p_action_num,'TO_POSITION_TITLE',p_pa_req.to_position_org_line2,l_pa_req.to_position_org_line2,'TO_POSITION_ORG_LINE2');
	copy_to_new_rg(p_action_num,'TO_POSITION_TITLE',p_pa_req.to_position_org_line3,l_pa_req.to_position_org_line3,'TO_POSITION_ORG_LINE3');
	copy_to_new_rg(p_action_num,'TO_POSITION_TITLE',p_pa_req.to_position_org_line4,l_pa_req.to_position_org_line4,'TO_POSITION_ORG_LINE4');
	copy_to_new_rg(p_action_num,'TO_POSITION_TITLE',p_pa_req.to_position_org_line5,l_pa_req.to_position_org_line5,'TO_POSITION_ORG_LINE5');
	copy_to_new_rg(p_action_num,'TO_POSITION_TITLE',p_pa_req.to_position_org_line6,l_pa_req.to_position_org_line6,'TO_POSITION_ORG_LINE6');

	copy_to_new_rg(p_action_num,'TO_POSITION_TITLE',p_pa_req.to_pay_basis,l_pa_req.to_pay_basis, 'TO_PAY_BASIS');

	copy_to_new_rg(p_action_num,'TO_POSITION_TITLE',p_pa_req.to_pay_plan,l_pa_req.to_pay_plan,'TO_PAY_PLAN');
	/* if TO_POSITION_TITLE exists, then the following fields should be copied */
	copy_to_new_rg(p_action_num,'TO_POSITION_TITLE',p_pa_req.to_position_title,l_pa_req.to_position_title);
	copy_to_new_rg(p_action_num,'TO_POSITION_TITLE',p_pa_req.to_position_id,l_pa_req.to_position_id,'TO_POSITION_ID');
	copy_to_new_rg(p_action_num,'TO_POSITION_TITLE',p_pa_req.to_grade_id,l_pa_req.to_grade_id,'TO_GRADE_ID');
	copy_to_new_rg(p_action_num,'TO_POSITION_TITLE',p_pa_req.to_job_id,l_pa_req.to_job_id,'TO_JOB_ID');
	copy_to_new_rg(p_action_num,'TO_POSITION_TITLE',p_pa_req.to_organization_id,l_pa_req.to_organization_id,'TO_ORGANIZATION_ID');
--	copy_to_new_rg(p_action_num,'TO_POSITION_TITLE',p_pa_req.to_location_id,l_pa_req.to_location_id,'TO_LOCATION_ID');
	/* end of fields dependent on TO_POSITION_TITLE */

	copy_to_new_rg(p_action_num,'TO_POSITION_TITLE',p_pa_req.to_grade_or_level,l_pa_req.to_grade_or_level,'TO_GRADE_OR_LEVEL');
	copy_to_new_rg(p_action_num,'TO_POSITION_TITLE',p_pa_req.to_position_number,l_pa_req.to_position_number,'TO_POSITION_NUMBER');
	copy_to_new_rg(p_action_num,'TO_POSITION_TITLE',p_pa_req.to_position_seq_no,l_pa_req.to_position_seq_no,'TO_POSITION_SEQ_NO');
	copy_to_new_rg(p_action_num,'TO_STEP_OR_RATE',p_pa_req.to_step_or_rate,l_pa_req.to_step_or_rate);
	copy_to_new_rg(p_action_num,'TO_POSITION_TITLE',p_pa_req.to_total_salary,l_pa_req.to_total_salary,'TO_TOTAL_SALARY');

	copy_to_new_rg(p_action_num,'VETERANS_PREFERENCE',p_pa_req.veterans_preference,l_pa_req.veterans_preference);

	copy_to_new_rg(p_action_num,'VETERANS_PREF_FOR_RIF_DESC',p_pa_req.veterans_pref_for_rif,l_pa_req.veterans_pref_for_rif,'VETERANS_PREF_FOR_RIF');
	copy_to_new_rg(p_action_num,'VETERANS_STATUS',p_pa_req.veterans_status,l_pa_req.veterans_status);
	copy_to_new_rg(p_action_num,'WORK_SCHEDULE',p_pa_req.work_schedule,l_pa_req.work_schedule);
 	copy_to_new_rg(p_action_num,'WORK_SCHEDULE_DESC',p_pa_req.work_schedule_desc,l_pa_req.work_schedule_desc);
	copy_to_new_rg(p_action_num,'YEAR_DEGREE_ATTAINED',p_pa_req.year_degree_attained,l_pa_req.year_degree_attained);
/*	All of the follwing will be passed irrespective of NOA.

	copy_to_new_rg(p_action_num,'ATTRIBUTE_CATEGORY',p_pa_req.attribute_category,l_pa_req.attribute_category);
	copy_to_new_rg(p_action_num,'ATTRIBUTE1',p_pa_req.attribute1,l_pa_req.attribute1);
	copy_to_new_rg(p_action_num,'ATTRIBUTE2',p_pa_req.attribute2,l_pa_req.attribute2);
	copy_to_new_rg(p_action_num,'ATTRIBUTE3',p_pa_req.attribute3,l_pa_req.attribute3);
	copy_to_new_rg(p_action_num,'ATTRIBUTE4',p_pa_req.attribute4,l_pa_req.attribute4);
	copy_to_new_rg(p_action_num,'ATTRIBUTE5',p_pa_req.attribute5,l_pa_req.attribute5);
	copy_to_new_rg(p_action_num,'ATTRIBUTE6',p_pa_req.attribute6,l_pa_req.attribute6);
	copy_to_new_rg(p_action_num,'ATTRIBUTE7',p_pa_req.attribute7,l_pa_req.attribute7);
	copy_to_new_rg(p_action_num,'ATTRIBUTE8',p_pa_req.attribute8,l_pa_req.attribute8);
	copy_to_new_rg(p_action_num,'ATTRIBUTE9',p_pa_req.attribute9,l_pa_req.attribute9);
	copy_to_new_rg(p_action_num,'ATTRIBUTE10',p_pa_req.attribute10,l_pa_req.attribute10);
	copy_to_new_rg(p_action_num,'ATTRIBUTE11',p_pa_req.attribute11,l_pa_req.attribute11);
	copy_to_new_rg(p_action_num,'ATTRIBUTE12',p_pa_req.attribute12,l_pa_req.attribute12);
	copy_to_new_rg(p_action_num,'ATTRIBUTE13',p_pa_req.attribute13,l_pa_req.attribute13);
	copy_to_new_rg(p_action_num,'ATTRIBUTE14',p_pa_req.attribute14,l_pa_req.attribute14);
	copy_to_new_rg(p_action_num,'ATTRIBUTE15',p_pa_req.attribute15,l_pa_req.attribute15);
	copy_to_new_rg(p_action_num,'ATTRIBUTE16',p_pa_req.attribute16,l_pa_req.attribute16);
	copy_to_new_rg(p_action_num,'ATTRIBUTE17',p_pa_req.attribute17,l_pa_req.attribute17);
	copy_to_new_rg(p_action_num,'ATTRIBUTE18',p_pa_req.attribute18,l_pa_req.attribute18);
	copy_to_new_rg(p_action_num,'ATTRIBUTE19',p_pa_req.attribute19,l_pa_req.attribute19);
	copy_to_new_rg(p_action_num,'ATTRIBUTE20',p_pa_req.attribute20,l_pa_req.attribute20);
*/
	-- all the following fields should be based on to_other_pay_amount field.
	copy_to_new_rg(p_action_num,'TO_OTHER_PAY_AMOUNT',p_pa_req.to_other_pay_amount,l_pa_req.to_other_pay_amount);
	copy_to_new_rg(p_action_num,'TO_OTHER_PAY_AMOUNT',p_pa_req.to_au_overtime,l_pa_req.to_au_overtime,'TO_AU_OVERTIME');
	copy_to_new_rg(p_action_num,'TO_OTHER_PAY_AMOUNT',p_pa_req.to_auo_premium_pay_indicator,l_pa_req.to_auo_premium_pay_indicator,'TO_AUO_PREMIUM_PAY_INDICATOR');
	copy_to_new_rg(p_action_num,'TO_OTHER_PAY_AMOUNT',p_pa_req.to_availability_pay,l_pa_req.to_availability_pay,'TO_AVAILABILITY_PAY');
	copy_to_new_rg(p_action_num,'TO_OTHER_PAY_AMOUNT',p_pa_req.to_ap_premium_pay_indicator,l_pa_req.to_ap_premium_pay_indicator,'TO_AP_PREMIUM_PAY_INDICATOR');
	copy_to_new_rg(p_action_num,'TO_OTHER_PAY_AMOUNT',p_pa_req.to_retention_allowance,l_pa_req.to_retention_allowance,'TO_RETENTION_ALLOWANCE');
	copy_to_new_rg(p_action_num,'TO_OTHER_PAY_AMOUNT',p_pa_req.to_retention_allow_percentage,l_pa_req.to_retention_allow_percentage,'TO_RETENTION_ALLOW_PERCENTAGE');
	copy_to_new_rg(p_action_num,'TO_OTHER_PAY_AMOUNT',p_pa_req.to_supervisory_differential,l_pa_req.to_supervisory_differential,'TO_SUPERVISORY_DIFFERENTIAL');
	copy_to_new_rg(p_action_num,'TO_OTHER_PAY_AMOUNT',p_pa_req.to_supervisory_diff_percentage,l_pa_req.to_supervisory_diff_percentage,'TO_SUPERVISORY_DIFF_PERCENTAGE');
	copy_to_new_rg(p_action_num,'TO_OTHER_PAY_AMOUNT',p_pa_req.to_staffing_differential,l_pa_req.to_staffing_differential,'TO_STAFFING_DIFFERENTIAL');
	copy_to_new_rg(p_action_num,'TO_OTHER_PAY_AMOUNT',p_pa_req.to_staffing_diff_percentage,l_pa_req.to_staffing_diff_PERCENTAGE,'TO_STAFFING_DIFF_PERCENTAGE');


--	copy_to_new_rg(p_action_num,'CUSTOM_PAY_CALC_FLAG',p_pa_req.custom_pay_calc_flag,l_pa_req.custom_pay_calc_flag);
	if (p_action_num = 2) then
		hr_utility.set_location('Correcting second action'|| l_proc, 10);
		-- if we are correcting the second action of a dual action, then copy all second noa columns into
		-- corresponding first noa columns
		copy_2ndNoa_to_1stNoa(l_pa_req);
	end if;
	-- null out second noa columns
	null_2ndNoa_cols(l_pa_req);
	p_pa_req := l_pa_req;

	hr_utility.set_location('Leaving:'|| l_proc, 15);

EXCEPTION
  WHEN others THEN
     -- Reset IN OUT parameters and set OUT parameters

      p_pa_req := l_pa_req;

   hr_utility.set_location('Leaving  ' || l_proc,60);
   RAISE;

END assign_new_rg;

-- ---------------------------------------------------------------------------
-- |--------------------------< copy_2ndNoa_to_1stNoa>------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--	Copies second noa columns to first noa columns. This is needed to facilitate
--	the design of always processing both actions of a dual action as if
--	each is the first action (i.e. - we pass it to update to database as if
--	it is the first action, regardless of whether or not it is the first or second
--	action).
--
-- Pre-Requisities:
--   	None.
--
-- In Parameters:
--	p_pa_req		->		pa_request record is passed here. It is also returned here after
--						it has been modified.
--
-- Post Success:
-- 	All the second noa columns will have been copied to the corresponding first noa columns.
--
-- Post Failure:
--   No Failure conditions.
--
-- Developer Implementation Notes:
--	None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------

PROCEDURE copy_2ndNoa_to_1stNoa (p_pa_req		in out 	nocopy ghr_pa_requests%rowtype) IS
	l_proc	varchar2(30):='copy_2ndNoa_to_1stNoa';
	l_pa_req	ghr_pa_requests%rowtype;

BEGIN
	l_pa_req :=p_pa_req ; ---NOCOPY Changes

	hr_utility.set_location('Entering:'|| l_proc, 5);
	p_pa_req.first_action_la_code1 	:= p_pa_req.second_action_la_code1;
	p_pa_req.first_action_la_code2	:= p_pa_req.second_action_la_code2;
	p_pa_req.first_action_la_desc1	:= p_pa_req.second_action_la_desc1;
	p_pa_req.first_action_la_desc2	:= p_pa_req.second_action_la_desc2;
	p_pa_req.first_noa_cancel_or_correct:= p_pa_req.second_noa_cancel_or_correct;
	p_pa_req.first_noa_code			:= p_pa_req.second_noa_code;
	p_pa_req.first_noa_desc			:= p_pa_req.second_noa_desc;
	p_pa_req.first_noa_id			:= p_pa_req.second_noa_id;
	p_pa_req.first_noa_pa_request_id	:= p_pa_req.second_noa_pa_request_id;
	p_pa_req.first_noa_information1	:= p_pa_req.second_noa_information1;
	p_pa_req.first_noa_information2	:= p_pa_req.second_noa_information2;
	p_pa_req.first_noa_information3	:= p_pa_req.second_noa_information3;
	p_pa_req.first_noa_information4	:= p_pa_req.second_noa_information4;
	p_pa_req.first_noa_information5	:= p_pa_req.second_noa_information5;
	p_pa_req.first_lac1_information1	:= p_pa_req.second_lac1_information1;
	p_pa_req.first_lac1_information2	:= p_pa_req.second_lac1_information2;
	p_pa_req.first_lac1_information3	:= p_pa_req.second_lac1_information3;
	p_pa_req.first_lac1_information4	:= p_pa_req.second_lac1_information4;
	p_pa_req.first_lac1_information5	:= p_pa_req.second_lac1_information5;
	p_pa_req.first_lac2_information1	:= p_pa_req.second_lac2_information1;
	p_pa_req.first_lac2_information2	:= p_pa_req.second_lac2_information2;
	p_pa_req.first_lac2_information3	:= p_pa_req.second_lac2_information3;
	p_pa_req.first_lac2_information4	:= p_pa_req.second_lac2_information4;
	p_pa_req.first_lac2_information5	:= p_pa_req.second_lac2_information5;
	hr_utility.set_location('Leaving:'|| l_proc, 10);

EXCEPTION
  WHEN others THEN
     -- Reset IN OUT parameters and set OUT parameters

      p_pa_req := l_pa_req;

   hr_utility.set_location('Leaving  ' || l_proc,65);
   RAISE;
END copy_2ndNoa_to_1stNoa;

-- ---------------------------------------------------------------------------
-- |--------------------------< null_2ndNoa_cols>-----------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--	Nulls out second noa columns.
--
-- Pre-Requisities:
--   	None.
--
-- In Parameters:
--	p_pa_req		->		pa_request record is passed here. It is also returned here after
--						it has been modified.
--
-- Post Success:
-- 	All the second noa columns will have been nulled.
--
-- Post Failure:
--   No Failure conditions.
--
-- Developer Implementation Notes:
--	None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------

PROCEDURE	null_2ndNoa_cols(p_pa_req	in out	nocopy ghr_pa_requests%rowtype) IS
	l_proc	varchar2(30):='null_2ndNoa_cols';
	l_pa_req	ghr_pa_requests%rowtype;

BEGIN
	l_pa_req :=p_pa_req ; ---NOCOPY Changes

	hr_utility.set_location('Entering:'|| l_proc, 5);
	-- set all second noa columns to null.
	p_pa_req.second_action_la_code1		:= null;
 	p_pa_req.second_action_la_code2		:= null;
	p_pa_req.second_action_la_desc1		:= null;
	p_pa_req.second_action_la_desc2		:= null;
	p_pa_req.second_noa_cancel_or_correct	:= null;
	p_pa_req.second_noa_code			:= null;
	p_pa_req.second_noa_desc			:= null;
	p_pa_req.second_noa_id				:= null;
	p_pa_req.second_noa_pa_request_id		:= null;
	p_pa_req.second_noa_information1		:= null;
	p_pa_req.second_noa_information2		:= null;
	p_pa_req.second_noa_information3		:= null;
	p_pa_req.second_noa_information4		:= null;
	p_pa_req.second_noa_information5		:= null;
	p_pa_req.second_lac1_information1		:= null;
	p_pa_req.second_lac1_information2		:= null;
	p_pa_req.second_lac1_information3		:= null;
	p_pa_req.second_lac1_information4		:= null;
	p_pa_req.second_lac1_information5		:= null;
	p_pa_req.second_lac2_information1		:= null;
	p_pa_req.second_lac2_information2		:= null;
	p_pa_req.second_lac2_information3		:= null;
	p_pa_req.second_lac2_information4		:= null;
	p_pa_req.second_lac2_information5		:= null;
	hr_utility.set_location('Leaving:'|| l_proc, 10);

EXCEPTION
  WHEN others THEN
     -- Reset IN OUT parameters and set OUT parameters

      p_pa_req := l_pa_req;

   hr_utility.set_location('Leaving  ' || l_proc,70);
   RAISE;

END null_2ndNoa_cols;

-- ---------------------------------------------------------------------------
-- |--------------------------< get_family_code>------------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--	gets the noa_family_code for the noa_id passed.
--
-- Pre-Requisities:
--   	None.
--
-- In Parameters:
--	p_noa_id		->		noa_id to get noa_family_code for.
--	p_noa_family_code	->		noa_family_code returned here.
--
-- Post Success:
-- 	the noa_family_code will have been populated into p_noa_family_code.
--
-- Post Failure:
--   No Failure conditions.
--
-- Developer Implementation Notes:
--	None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
Procedure get_Family_code (
		p_noa_id		in 	number,
		p_noa_family_code	out	nocopy varchar2
		) is

	cursor c_fam (c_noa_id number) is
	select
		fams.noa_family_code
	from  ghr_noa_families noafam,
		ghr_families     fams
	where noafam.nature_of_action_id = c_noa_id               and
		noafam.enabled_flag        = 'Y'                    and
		fams.noa_family_code 	   = noafam.noa_family_code and
		fams.enabled_flag          = 'Y'                    and
		fams.update_hr_flag = 'Y';

	l_proc	varchar2(30):='get_family_code';
Begin

	hr_utility.set_location( 'entering : ' || l_proc, 10);
	open c_fam (p_noa_id);
	fetch c_fam into p_noa_family_code;
	close c_fam;
	hr_utility.set_location( 'leaving : ' || l_proc, 20);

EXCEPTION
  WHEN others THEN
     -- Reset IN OUT parameters and set OUT parameters

      p_noa_family_code := NULL;

   hr_utility.set_location('Leaving  ' || l_proc,75);
   RAISE;

End;

-- ---------------------------------------------------------------------------
-- |--------------------------< proc_futr_act>--------------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--	gets the noa_family_code for the noa_id passed.
--
-- Pre-Requisities:
--   	None.
--
-- In Parameters:
--	errbuf		->		noa_id to get noa_family_code for.
--	p_noa_family_code	->		noa_family_code returned here.
--
-- Post Success:
-- 	the noa_family_code will have been populated into p_noa_family_code.
--
-- Post Failure:
--   No Failure conditions.
--
-- Developer Implementation Notes:
--	None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
-- Added a new parameter POI as of 17-FEB-03.
-- ---------------------------------------------------------------------------

Procedure Proc_Futr_Act(
       errbuf         out  nocopy   varchar2,
       retcode        out  nocopy   number,
       p_poi          in ghr_pois.personnel_office_id%type) is

   l_log_text	varchar2(2000);
   l_error	varchar2(512); --512
   l_req	varchar2(10);
   l_sf52_rec	ghr_pa_requests%rowtype;
   l_result	varchar2(30);

   l_retcode		Number;
   l_calculated		Boolean;
   l_error_message	Varchar2(2000);
   l_proc		varchar2(30):='Proc_Futr_Act';
   l_route_flag         boolean := TRUE;
   l_person_id          Number;
   l_effective_date     Date;
   l_pa_request_id      Number;
   l_new_line           varchar2(1) := substr('',1,1);




----If p_poi is passed then use the following modified SQL.

       cursor  c_par_pend_per_poi is
       select  person_id,effective_date
       from    ghr_pa_requests a, ghr_pa_routing_history b
       where   effective_date <= sysdate
       and     pa_notification_id is null
       and     approval_date is not null
       and     a.pa_request_id = b.pa_request_id
       and     p_poi   =
               (select POEI_INFORMATION3 from per_position_extra_info
                where information_type = 'GHR_US_POS_GRP1'
                and   position_id = nvl(a.to_position_id,a.from_position_id))
       and     action_taken    = 'FUTURE_ACTION'
         and     exists
                (select 1
                 from per_people_f per
                 where per.person_id = a.person_id
                 and a.effective_date between
                 per.effective_start_date and per.effective_end_date )
      and     b.pa_routing_history_id = (select max(pa_routing_history_id)
                                          from ghr_pa_routing_history
                                          where pa_request_id = a.pa_request_id)
       group by person_id,effective_date
       order by 2,1;


----If p_poi is null then use the following original SQL.

       cursor  c_par_pend_per is
---------Added as part of fix for the bug 2180343
       select  person_id,effective_date
       from    ghr_pa_requests a, ghr_pa_routing_history b
       where   effective_date <= sysdate
       and     pa_notification_id is null
       and     approval_date is not null
       and     a.pa_request_id = b.pa_request_id
       and     action_taken    = 'FUTURE_ACTION'
         and     exists
                (select 1
                 from per_people_f per
                 where per.person_id = a.person_id
                 and a.effective_date between
                 per.effective_start_date and per.effective_end_date )
      and     b.pa_routing_history_id = (select max(pa_routing_history_id)
                                          from ghr_pa_routing_history
                                          where pa_request_id = a.pa_request_id)
       group by person_id,effective_date
       order by 2,1;

/*********** Commented out as part of fix 2180343  ***** AVR
       select  distinct person_id,effective_date
       from ghr_pa_requests a
       where effective_date <=  sysdate and
                pa_notification_id is null and
                approval_date is not null and
                exists  (select 'exists'
                         from ghr_pa_routing_history
                         where pa_routing_history_id = (select max(pa_routing_history_id)
                                                        from ghr_pa_routing_history
                                                        where pa_request_id = a.pa_request_id)
                                                        and action_taken in ('FUTURE_ACTION'))
        order by 2,1;

	cursor	c_get_par_id is
	select  pa_request_id ,noa.order_of_processing
	from   ghr_pa_requests a, ghr_nature_of_actions noa
	where  person_id      =  l_person_id
      and    effective_date =  l_effective_date
      and    pa_notification_id is null
      and    approval_date is not null
      and    noa.code  = a.first_noa_code
      and    exists	(select 'exists'
				from ghr_pa_routing_history
				where pa_routing_history_id = (select max(pa_routing_history_id)
									from ghr_pa_routing_history
									where pa_request_id = a.pa_request_id)
					and action_taken in ('FUTURE_ACTION'))
	order by 2 asc;


      Cursor  get_req is
        select * from ghr_pa_requests
        where  pa_request_id = l_pa_request_id;
***********/


      Cursor cur_sessionid is
        select userenv('sessionid') sesid  from dual;

      l_sid           number;
----
---- Inserted a new procedure sub_proc_futr_sf52.
----

---Local Procedure.
 PROCEDURE  sub_proc_futr_sf52 is
   cursor   c_get_par_id is
   select  pa_request_id ,noa.order_of_processing
   from   ghr_pa_requests a, ghr_nature_of_actions noa
   where  person_id      =  l_person_id
   and    effective_date =  l_effective_date
   and    pa_notification_id is null
   and    approval_date is not null
   and    noa.code  = a.first_noa_code
   and    exists  (select 'exists'
          from ghr_pa_routing_history
          where pa_routing_history_id = (select max(pa_routing_history_id)
                                         from ghr_pa_routing_history
                                         where pa_request_id = a.pa_request_id)
   and action_taken in ('FUTURE_ACTION'))
   order by 2 asc;


   Cursor  get_req is
   select * from ghr_pa_requests
   where  pa_request_id = l_pa_request_id;

   l_rec             get_req%rowtype;

 -- Start of Bug 3602261

   l_object_version_number      ghr_pa_requests.object_version_number%type;

   Cursor c_ovn (p_pa_request_id ghr_pa_requests.pa_request_id%type)  is        -- 3769917
     select par.object_version_number
     from   ghr_pa_requests par
     where  par.pa_request_id = p_pa_request_id;           -- 3769917

-- End of Bug 3602261


 BEGIN
        for get_par_id in c_get_par_id loop
          l_pa_request_id  :=  get_par_id.pa_request_id ;
          hr_utility.set_location('par id ' || l_pa_request_id,3);

        for get_request in get_req loop
            hr_utility.set_location('par_id ' || l_pa_request_id,2);
          l_rec :=  get_request;
            hr_utility.set_location('l_rec ' || l_rec.first_noa_code,3);

		    l_sf52_rec := l_rec;

		Begin
			--  Bug 2639698 Sundar Enhancement - If To Pay is less than From Pay, no need to process. Just route it to inbox.

			IF ( UPPER(SUBSTR(l_sf52_rec.request_number,1,3)) = 'MSL' AND l_sf52_rec.first_noa_code = '894')
				AND (l_sf52_rec.to_basic_pay < l_sf52_rec.from_basic_pay) THEN
				l_log_text := 'Request Number : ' || l_sf52_rec.request_number || l_new_line ||
						'PA_REQUEST_ID : ' || to_char(l_sf52_rec.pa_request_id) || l_new_line ||
						'Employee Name : ' || l_sf52_rec.employee_last_name || ' ,'
									  || l_sf52_rec.employee_first_name || l_new_line ||
						'SSN           : ' || l_sf52_rec.employee_national_identifier || l_new_line ||
						'First NOA Code: ' || l_sf52_rec.first_noa_code || l_new_line ||
						'Second NOA Code: ' || l_sf52_rec.second_noa_code || l_new_line ||
						'Error: The From Side Basic Pay exceeds the To Side Basic Pay. ' ||  l_new_line ||
						'Cause: The Personnel Action attempted to update the employee''s salary with a ' || l_new_line ||
						'decreased amount of Basic Pay. ' || l_new_line ||
						'Action: Please review the personnel action to verify the Grade and Step, Pay Table amounts,' || l_new_line ||
						'and Pay Rate Determinant code for this employee.' ;    -- Bug 3320086 Changed error message.

				hr_utility.set_location(l_log_text,1511);
				create_ghr_errorlog(
					p_program_name	=> g_futr_proc_name,
					p_log_text		=> l_log_text,
					p_message_name	=> 'SF52 Routed to Inbox',
					p_log_date		=> sysdate
					);
				Route_Errorerd_SF52(
	               p_sf52   => l_sf52_rec,
		           p_error  => l_log_text,
			       p_result => l_result
				 );
				 l_retcode := 5; /* Error - but route to inbox */
			-- Bug 2639698
			ELSE
				savepoint future_Action;
				Process_SF52(
					p_sf52_data		=> l_sf52_rec,
					p_process_type	=> 'FUTURE');

--  Start of Bug 3602261
                                ghr_sf52_post_update.get_notification_details
				  (p_pa_request_id                  =>  l_sf52_rec.pa_request_id,
				   p_effective_date                 =>  l_sf52_rec.effective_date,
				   p_from_position_id               =>  l_sf52_rec.from_position_id,
				   p_to_position_id                 =>  l_sf52_rec.to_position_id,
				   p_agency_code                    =>  l_sf52_rec.agency_code,
				   p_from_agency_code               =>  l_sf52_rec.from_agency_code,
				   p_from_agency_desc               =>  l_sf52_rec.from_agency_desc,
				   p_from_office_symbol             =>  l_sf52_rec.from_office_symbol,
				   p_personnel_office_id            =>  l_sf52_rec.personnel_office_id,
				   p_employee_dept_or_agency        =>  l_sf52_rec.employee_dept_or_agency,
				   p_to_office_symbol               =>  l_sf52_rec.to_office_symbol
				   );
				 FOR ovn_rec IN c_ovn (l_sf52_rec.pa_request_id) LOOP
				     l_object_version_number := ovn_rec.object_version_number;
				 END LOOP;
				 ghr_par_upd.upd
				   (p_pa_request_id                  =>  l_sf52_rec.pa_request_id,
				    p_object_version_number          =>  l_object_version_number,
				    p_from_position_id               =>  l_sf52_rec.from_position_id,
				    p_to_position_id                 =>  l_sf52_rec.to_position_id,
				    p_agency_code                    =>  l_sf52_rec.agency_code,
				    p_from_agency_code               =>  l_sf52_rec.from_agency_code,
				    p_from_agency_desc               =>  l_sf52_rec.from_agency_desc,
				    p_from_office_symbol             =>  l_sf52_rec.from_office_symbol,
				    p_personnel_office_id            =>  l_sf52_rec.personnel_office_id,
				    p_employee_dept_or_agency        =>  l_sf52_rec.employee_dept_or_agency,
				    p_to_office_symbol               =>  l_sf52_rec.to_office_symbol
				   );
-- End of Bug 3602261

				l_log_text := 'Request Number : ' || l_sf52_rec.request_number || l_new_line ||
						'PA_REQUEST_ID : ' || to_char(l_sf52_rec.pa_request_id) || l_new_line ||
						'Employee Name : ' || l_sf52_rec.employee_last_name || ' ,'
									  || l_sf52_rec.employee_first_name || l_new_line ||
						'SSN           : ' || l_sf52_rec.employee_national_identifier || l_new_line ||
						'First NOA Code: ' || l_sf52_rec.first_noa_code || l_new_line ||
						'Second NOA Code: ' || l_sf52_rec.second_noa_code || l_new_line ||
						'Processed Successfully';

				create_ghr_errorlog(
					p_program_name	=> g_futr_proc_name,
					p_log_text		=> l_log_text,
					p_message_name	=> 'SF52 Processed Successfully',
					p_log_date		=> sysdate
					);
			 END IF;
			 commit;
		Exception
		when e_refresh then
			begin
				rollback to future_Action;
     	      	      l_route_flag := TRUE;
				if nvl(l_retcode, 0) <> 2 then
					l_retcode := 1; /* warning */
				end if;
				-- Enter a record in process log
				l_log_text := substr(
						'Request Number : ' || l_sf52_rec.request_number || l_new_line ||
						'PA_REQUEST_ID : ' || to_char(l_sf52_rec.pa_request_id) || l_new_line ||
						'Employee Name : ' || l_sf52_rec.employee_last_name || ' ,' ||
                                                                            l_sf52_rec.employee_first_name || l_new_line ||
						'SSN           : ' || l_sf52_rec.employee_national_identifier || l_new_line  ||
						'First NOA Code: ' || l_sf52_rec.first_noa_code || l_new_line ||
						'Second NOA Code: ' || l_sf52_rec.second_noa_code || l_new_line ||
						'Action: RPA related information has changed. Retrieve the RPA from the groupbox to review the refreshed information, make necessary changes, and update HR',1,2000);
				create_ghr_errorlog(
					p_program_name	=> g_futr_proc_name,
					p_log_text		=> l_log_text,
					p_message_name	=> 'Future SF52 Routed to Inbox',--Bug#5634990
					p_log_date		=> sysdate
			        );
            l_error_message := substr(sqlerrm(sqlcode), 1, 512);
            Route_Errorerd_SF52(
               p_sf52   => l_sf52_rec,
               p_error  => substr(l_error_message,1 ,512),
               p_result => l_result
             );
				commit;
			end;
		when others then
			Begin
				if sqlcode = -6508 then
					-- Program Unit not found
					-- This usually happens and the only solution know so far is
					-- to re-start the conc. manager. So all the SF52's are routed unnecessarily
					l_retcode := 2; /* Error*/
					errbuf := ' Program raised Error - Program Unit not Found. Details in Process Log.';
					l_log_text := substr('Initiate Process Future Dated SF52 Due For Processing Terminated due to following error :  ' || Sqlerrm(sqlcode), 1, 2000);

					rollback to future_Action;
					create_ghr_errorlog(
						p_program_name	=> g_futr_proc_name,
						p_log_text		=> l_log_text,
						p_message_name	=> 'Process Terminated',
						p_log_date		=> sysdate
					);
					commit;
					return;
				end if;

				rollback to future_Action;
            	      l_route_flag := TRUE;
				if nvl(l_retcode, 0) <> 2 then
					l_retcode := 1; /* warning */
				end if;

				hr_utility.set_location( l_proc || ' ' || substr(sqlerrm,1,20), 40);
				-- Enter a record in process log
				l_log_text := substr(
						'Request Number : ' || l_sf52_rec.request_number || l_new_line ||
						'PA_REQUEST_ID : ' || to_char(l_sf52_rec.pa_request_id) || l_new_line ||
						'Employee Name : ' || l_sf52_rec.employee_last_name || ' ,' ||
                                        l_sf52_rec.employee_first_name || l_new_line ||
						'SSN           : ' || l_sf52_rec.employee_national_identifier || l_new_line ||
						'First NOA Code: ' || l_sf52_rec.first_noa_code || l_new_line ||
						'Second NOA Code: ' || l_sf52_rec.second_noa_code || l_new_line ||
						'Error : ' || sqlerrm(sqlcode) , 1, 2000);
				create_ghr_errorlog(
					p_program_name	=> g_futr_proc_name,
					p_log_text		=> l_log_text,
					p_message_name	=> 'SF52 Errored Out',
					p_log_date		=> sysdate
			        );

				commit;
			Exception
			When Others then
				hr_utility.set_location(' Error While creating Procees Log' || l_proc, 200);
				-- Error
				l_retcode := 2;
				errbuf  := 'Process was errored out while creating Error Log. Error: ' || substr(sqlerrm(sqlcode), 1, 50);
				return;
			End;
                l_error_message := substr(sqlerrm(sqlcode), 1, 512);
                Route_Errorerd_SF52(
                  p_sf52   => l_sf52_rec,
                  p_error  => substr(l_error_message,1 ,512),
                  p_result => l_result
                  );
                if l_result = '2' then
                  l_retcode := 2;
                end if;
                commit;
              End; --Bug 1266718
	    End loop;
          exit;
        End loop;
 END sub_proc_futr_sf52;
----
---- End of  new procedure sub_proc_futr_sf52.
----

Begin

   for s_id in cur_sessionid
   loop
     l_sid  := s_id.sesid;
   exit;
   end loop;

  begin
      update fnd_sessions set SESSION_ID = l_sid
      where  SESSION_ID = l_sid;
      if sql%notfound then
         INSERT INTO fnd_sessions
            (SESSION_ID,EFFECTIVE_DATE)
         VALUES
            (l_sid,sysdate);
      end if;
  end;

	hr_utility.set_location(' Entering : ' || l_proc, 10);
	-- Get concurent Request_id
	g_futr_proc_name	:='GHR_Proc_Futr_Act';
	l_req	:= Fnd_profile.value('CONC_REQUEST_ID');

	if l_req is not null then
		g_futr_proc_name := g_futr_proc_name || '_' || l_req;
	else
		-- if it fails for any reason. concat date time with program name
		g_futr_proc_name := g_futr_proc_name || '_' || to_char(sysdate, 'ddmmyyhhmiss');
	end if;

----New Logic for a Passed POI parameter.

    IF p_poi is not null then
      for par_pend_for_per_poi in c_par_pend_per_poi loop
        l_person_id       :=  par_pend_for_per_poi.person_id;
        l_effective_date  :=  par_pend_for_per_poi.effective_date;
        hr_utility.set_location( 'Person id ' || l_person_id,1);
        hr_utility.set_location(' Eff. Date ' || l_effective_date,2);
        sub_proc_futr_sf52;
      end loop;
    ELSE
      for par_pend_for_per in c_par_pend_per loop
        l_person_id       :=  par_pend_for_per.person_id;
        l_effective_date  :=  par_pend_for_per.effective_date;
        hr_utility.set_location( 'Person id ' || l_person_id,1);
        hr_utility.set_location(' Eff. Date ' || l_effective_date,2);
        sub_proc_futr_sf52;
      end loop;
    END IF;
     if l_retcode = 2 then
		retcode := 2;
            hr_utility.set_location('Ret code ' || to_char(l_retcode),1);
 		errbuf  := 'There were errors in SF52''s which could NOT be routed to approver''s Inbox. Detail in GHR_PROCESS_LOG';
    -- Bug 2639698 Sundar
	elsif l_retcode = 5 then
		retcode := 2;
            hr_utility.set_location('Ret code ' || to_char(l_retcode),1);
 		errbuf  := 'There were errors in SF52''s which were routed to approver''s Inbox. Detail in GHR_PROCESS_LOG';
    -- End Bug 2639698 Sundar
     elsif l_retcode is not NULL then
		-- Warning
		retcode := 1;
		errbuf  := 'There were errors in SF52''s which were routed to approver''s Inbox. Detail in GHR_PROCESS_LOG' ;
     elsif l_retcode is null then
		retcode := 0;
     end if;
     hr_utility.set_location( 'Leaving : ' || l_proc, 20);
     hr_utility.set_location('Ret code ' || to_char(l_retcode), 21);
Exception
when others then
	hr_utility.set_location(l_proc, 60);
	-- Error
	retcode := 2;
	errbuf  := 'Process Terminated due to Unhandled Errors.' || l_new_line
             || 'Error : ' || substr(sqlerrm(sqlcode), 1, 20);
End Proc_Futr_Act;

--
--
Procedure Route_Errorerd_SF52(
				p_sf52   in out nocopy ghr_pa_requests%rowtype,
				p_error	 in varchar2,
				p_result out nocopy varchar2) is

	l_u_prh_object_version_number		number;
	l_i_pa_routing_history_id	     	number;
	l_i_prh_object_version_number		number;

	l_log_text				varchar2(2000);
--	l_prog_name				varchar2(30):='GHR Process Future SF52';
	l_proc					varchar2(30):='Route_Errerd_SF52';
        l_new_line				varchar2(1) := substr('',1,1);
	l_sf52					ghr_pa_requests%rowtype ;

Begin
	l_sf52 :=p_sf52; --NOCOPY Changes
	hr_utility.set_location( 'Entering : ' || l_proc, 10);
	savepoint route_errored_sf52;
/*
	l_log_text := 'Request Number : ' || p_sf52.request_number || l_new_line ||
			  'PA_REQUEST_ID : ' || to_char(p_sf52.pa_request_id) ||
                    ' has errors.' || l_new_line ||
                    'Error :         ' || p_error || l_new_line  ||
                    'Errored while resetting approval date ';
*/
	hr_utility.set_location( l_proc, 20);
	l_log_text := 'Request Number : ' || p_sf52.request_number || l_new_line ||
			  'PA_REQUEST_ID : ' || to_char(p_sf52.pa_request_id) ||
                    ' has errors.' || l_new_line ||
                    'Error :         ' || p_error || l_new_line ||
                    'Errored while routing it to the approver''s Inbox ';

	ghr_api.call_workflow(
		p_pa_request_id	=>	p_sf52.pa_request_id,
		p_action_taken	=>	'CONTINUE',
		p_error		=>	p_error);
	hr_utility.set_location( 'Leaving : ' || l_proc, 20);
Exception
when others then
	hr_utility.set_location(l_proc || ' workflow errored out', 30);
	rollback to route_errored_sf52;
	p_result := '0';
	l_log_text := substr(
			'Request Number : ' || p_sf52.request_number || l_new_line ||
			'PA_REQUEST_ID : ' || to_char(p_sf52.pa_request_id) || l_new_line ||
			'Employee Name : ' || p_SF52.employee_last_name || ' ,' || p_sf52.employee_first_name || l_new_line ||
			'SSN           : ' || p_sf52.employee_national_identifier || l_new_line ||
			'First NOA Code: ' || p_sf52.first_noa_code || l_new_line ||
			'Second NOA Code: ' || p_sf52.second_noa_code || l_new_line ||
			'Errored while routing it to the approver''s Inbox '  || l_new_line ||
			'Error : ' || sqlerrm(sqlcode), 1, 2000);
	create_ghr_errorlog(
		p_program_name	=> g_futr_proc_name,
		p_log_text		=> l_log_text,
		p_message_name	=> 'Routing Error',
		p_log_date		=> sysdate
	);
	hr_utility.set_location(l_proc , 40);
	p_result := '2';
	p_sf52 := l_sf52; --Added for nocopy changes

End Route_Errorerd_SF52;

/*--Added by Rohini

Procedure fetch_update_routing_details
(p_pa_request_id           in         ghr_pa_requests.pa_request_id%type,
 p_object_version_number   in out     ghr_pa_requests.object_version_number%type,
 p_position_id             in         ghr_pa_requests.to_position_id%type,
 p_effective_date          in         ghr_pa_requests.effective_date%type,
 p_retcode                 out     nocopy   number,
 p_route_flag              out     nocopy   boolean
 )

 is

 l_groupbox_id                ghr_groupboxes.groupbox_id%type;
 l_routing_group_id           ghr_pa_requests.routing_group_id%type;
 l_proc     			varchar2(72)  :=  ' ghr_process_sf52.' || 'update_routing_details';
 l_pa_routing_history_id      ghr_pa_routing_history.pa_routing_history_id%type;
 l_pa_object_version_number   ghr_pa_routing_history.object_version_number%type;
 l_user_name           varchar2(30);
 l_log_text            varchar2(2000);




 Cursor c_rout_history is
   select pa_routing_history_id,
          object_version_number,
          user_name,
          groupbox_id
   from   ghr_pa_routing_history
   where  pa_request_id = p_pa_request_id
   order  by 1 desc;


Procedure get_personnel_off_groupbox
(p_position_id         in       per_positions.position_id%type,
 p_effective_date      in       date default trunc(sysdate),
 p_groupbox_id         out      ghr_groupboxes.groupbox_id%type,
 p_routing_group_id    out      ghr_routing_groups.routing_group_id%type,
 p_retcode             out      number
)
is

  l_proc            	varchar2(72) :=  'fetch_update_rout_details '  || 'get_personnel_off_groupbox';
  l_pos_ei_data     	per_position_extra_info%type;
  l_groupbox_name   	ghr_groupboxes.name%type;
  l_groupbox_id     	ghr_groupboxes.groupbox_id%type;
  l_routing_group_id 	ghr_routing_groups.routing_group_id%type;
  l_personnel_office_id ghr_pa_requests.personnel_office_id%type;
  l_log_text            varchar2(2000);

  Cursor  c_gpboxname is
    select  substr(hl.description,1,30) description
    from    hr_lookups hl
    where   hl.application_id      = 800
    and     hl.lookup_type         = 'GHR_US_PERSONNEL_OFFICE_ID'
    and     hl.lookup_code         = l_personnel_office_id
    and     hl.enabled_flag        = 'Y'
    and     nvl(p_effective_date,trunc(sysdate))
    between nvl(hl.start_date_active,nvl(p_effective_date,trunc(sysdate)))
    and     nvl(hl.end_date_active,nvl(p_effective_date,trunc(sysdate)));

  Cursor c_gbx is
    select  gbx.groupbox_id gpid, gbx.routing_group_id rgpid
           --gbx.name, rgp.name
    from    ghr_groupboxes gbx,
            ghr_routing_groups rgp
    where   gbx.name = l_groupbox_name
    and     gbx.routing_group_id = rgp.routing_group_id;



begin
  savepoint get_personnel_off_groupbox;
  hr_utility.set_location('Entering   ' || l_proc,5);
  p_retcode      :=  null;

 -- Find the groupbox of the personnelist, update ghr_pa_routing_history and then call work_flow

  If p_position_id is not null then

    l_log_text := 'Error while getting the groupbox of the personnel';

   -- get the personnel offfice id
    ghr_history_fetch.fetch_positionei
    (p_position_id                 =>   p_position_id    	               ,
     p_information_type            =>   'GHR_US_POS_GRP1'		         ,
     p_date_effective              =>   trunc(nvl(p_effective_date,sysdate)),
     p_pos_ei_data                 =>   l_pos_ei_data
    );

    l_personnel_office_id          :=  l_pos_ei_data.poei_information3;
    l_pos_ei_data                  :=  null;

     -- get groupbox name
    for gpboxname in c_gpboxname loop
      l_groupbox_name             :=   gpboxname.description;
    end loop;


  --
  -- validate groupbox  (name exists in wf_roles ) -- Should I do this or will workflow take care of it
  -- fetch groupbox_id as well as other routing group details

    if l_groupbox_name is not null then
      for rout_det in c_gbx loop
        l_groupbox_id             :=  rout_det.gpid;
        l_routing_group_id        :=  rout_det.rgpid;

      end loop;
    end if;
  end if;
  p_groupbox_id       :=  l_groupbox_id;
  p_routing_group_id  := l_routing_group_id;

Exception
  when others then
    rollback to get_personnel_off_groupbox;
    hr_utility.set_location(l_proc,50);

    p_retcode          :=  2;
    create_ghr_errorlog
    (p_program_name		=> g_futr_proc_name,
     p_log_text		=> l_log_text,
     p_message_name	=> NULL,
     p_log_date		=> sysdate
    );
    commit;
end get_personnel_off_groupbox;

begin

  hr_utility.set_location('Entering   '  || l_proc ,5);
  savepoint fetch_update_routing_details;

  l_user_name   :=  null;
  l_groupbox_id :=  null;
  p_retcode     :=  null;
  p_route_flag  :=  FALSE;

  For rout_hist in c_rout_history loop
    l_user_name                 :=   rout_hist.user_name;
    l_groupbox_id               :=   rout_hist.groupbox_id;
    l_pa_routing_history_id     :=   rout_hist.pa_routing_history_id;
    l_pa_object_version_number  :=   rout_hist.object_version_number;
    exit;
  End loop;

  If l_user_name is null and l_groupbox_id is null then
    get_personnel_off_groupbox
    (p_position_id          =>   p_position_id,
     p_effective_date       =>   p_effective_date  ,
     p_groupbox_id          =>   l_groupbox_id,
     p_routing_group_id     =>   l_routing_group_id,
     p_retcode              =>   p_retcode
    );

    If l_groupbox_id is null then
      p_route_flag := FALSE;
      rollback to fetch_update_routing_details;
      l_log_text := 'No groupbox associated with this personnel office';
      create_ghr_errorlog
      (p_program_name	=> g_futr_proc_name,
       p_log_text		=> l_log_text,
       p_message_name	=> NULL,
       p_log_date		=> sysdate
      );
      commit;
    Else
      p_route_flag  := TRUE;
      l_log_text := 'Error while updating routing_group_id to ghr_pa_requests table';
      ghr_par_upd.upd
      (p_pa_request_id           =>    p_pa_request_id,
       p_object_version_number   =>    p_object_version_number,
       p_routing_group_id        =>    l_routing_group_id
      );
      hr_utility.set_location(l_proc ,10);


      l_log_text := 'Error while updating groupbox to ghr_pa_routing_history table';
      for rout_hist in c_rout_history loop
        hr_utility.set_location(l_proc ,15);
        l_pa_routing_history_id         :=   rout_hist.pa_routing_history_id;
        l_pa_object_version_number      :=   rout_hist.object_version_number;
      end loop;

      hr_utility.set_location(l_proc ,20);
      ghr_prh_upd.upd
      (p_pa_routing_history_id         =>   l_pa_routing_history_id,
       p_object_version_number         =>   l_pa_object_version_number,
       p_groupbox_id                   =>   l_groupbox_id
       );
       hr_utility.set_location('Leaving  '|| l_proc ,30);
    End if;
  Else
    p_route_flag := TRUE;
  End if;

 Exception
   when others then
    rollback to fetch_update_routing_details;
    create_ghr_errorlog
    (p_program_name		=> g_futr_proc_name,
     p_log_text		=> l_log_text,
     p_message_name	=> NULL,
     p_log_date		=> sysdate
    );
    p_retcode  := 2;
    commit;
 end fetch_update_routing_details;

-- Rohini
*/

-- Route Future Action

Procedure Route_Intervn_Future_Actions( p_person_id		in	number,
					p_effective_date	in	date
                                        ) is

	cursor get_req (
			cp_person_id		number,
			cp_date_Effective	date
                       ) is

	select *
	from ghr_pa_requests a
	where person_id 	   =  cp_person_id	and
		effective_date > cp_date_effective      and
                pa_notification_id is null 		and
		approval_date is not null		and
		exists 	(select 'exists'
				from ghr_pa_routing_history
				where pa_routing_history_id = (select max(pa_routing_history_id)
									from ghr_pa_routing_history
									where pa_request_id = a.pa_request_id)
					and action_taken in ('FUTURE_ACTION')) ;
	l_error	varchar2(512):='Routed because of intervening RPA approval';
	l_rec		get_req%rowtype;
	l_proc	varchar2(30):='Route_Intervn_Future_Actions';

Begin
	hr_utility.set_location(' Entering : ' || l_proc, 10);
	open get_req (p_person_id, p_effective_date);
	While TRUE
	loop
		fetch get_req into l_rec;
		exit when get_req%notfound;
		Begin
			savepoint future_Action;

			ghr_api.call_workflow(	p_pa_request_id	=>	l_rec.pa_request_id,
						p_action_taken	=>	'CONTINUE',
						p_error		=>	l_error);
		Exception
		when others then
			l_error := Sqlerrm(sqlcode);
			rollback to future_Action;
			Raise;
		End;
		hr_utility.set_location(' Entering : ' || l_proc, 100);
	End loop;
	hr_utility.set_location( 'Leaving : ' || l_proc, 20);
End Route_Intervn_Future_Actions;



Procedure Route_Intervn_act_pend_today( p_person_id		in	number,
					p_effective_date	in	date
                                        ) is

	cursor get_req (
			cp_person_id		number,
			cp_date_Effective	date
                    ) is
	select *
	from ghr_pa_requests a
	where person_id 	=  cp_person_id 	and
		effective_date = cp_date_effective      and
            pa_notification_id is null 		        and
		approval_date is not null		and
		exists 	(select 'exists'
				from ghr_pa_routing_history
				where pa_routing_history_id = (select max(pa_routing_history_id)
									from ghr_pa_routing_history
									where pa_request_id = a.pa_request_id)
					and action_taken in ('FUTURE_ACTION')) ;
	l_error	varchar2(512):='Routed because of intervening RPA approval';
	l_rec		get_req%rowtype;
	l_proc	varchar2(30):='Route_Intervn_pend_Actions';

Begin
	hr_utility.set_location(' Entering : ' || l_proc, 10);
	open get_req (p_person_id, p_effective_date);
	While TRUE
	loop
		fetch get_req into l_rec;
		exit when get_req%notfound;
		Begin
			savepoint route_pending_Actions;

			ghr_api.call_workflow(	p_pa_request_id	=>	l_rec.pa_request_id,
						p_action_taken	=>	'CONTINUE',
						p_error		=>	l_error);
		Exception
		when others then
			l_error := Sqlerrm(sqlcode);
			rollback to route_pending_Actions;
			Raise;
		End;
		hr_utility.set_location(' Entering : ' || l_proc, 100);
	End loop;
	hr_utility.set_location( 'Leaving : ' || l_proc, 20);
End Route_Intervn_act_pend_today;



procedure create_ghr_errorlog(
        p_program_name           in     ghr_process_log.program_name%type,
        p_log_text               in     ghr_process_log.log_text%type,
        p_message_name           in     ghr_process_log.message_name%type,
        p_log_date               in     ghr_process_log.log_date%type
        ) is

	l_proc		varchar2(30):='create_ghr_errorlog';
Begin
	hr_utility.set_location( 'Entering : ' || l_proc, 10);
     insert into ghr_process_log
	(process_log_id
      ,program_name
      ,log_text
      ,message_name
      ,log_date
      )
     values
	(ghr_process_log_s.nextval
      ,p_program_name
      ,p_log_text
      ,p_message_name
      ,p_log_date
     );
	hr_utility.set_location( 'Leaving : ' || l_proc, 20);

End create_ghr_errorlog;

-- ---------------------------------------------------------------------------
-- |--------------------------< refresh_pa_request>---------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--	Refreshes all data having to do with a given pa_request.
--
-- Pre-Requisities:
--   	None.
--
-- In Parameters:
--	p_person_id		->		person_id to get pa_request info for.
--	p_effective_date	->		date to refresh from.
--	p_sf52_data		->		Retrieved values returned here.
--	p_from_only		->		input flag to indicate if only from info is needed.
--	p_
--
-- Post Success:
-- 	the requested information will have been returned.
--
-- Post Failure:
--   No Failure conditions.
--
-- Developer Implementation Notes:
--	None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------

PROCEDURE refresh_pa_request(
		p_person_id			in	per_people_f.person_id%type,
		p_effective_date		in	date,
		p_from_only			in	boolean	default	FALSE,
		p_derive_to_cols		in	boolean	default	FALSE,
		p_sf52_data			in out 	nocopy ghr_pa_requests%rowtype) IS

	l_agency_code			ghr_pa_requests.agency_code%type;
	l_assignment_id       		NUMBER(9);
	l_duty_station_id		NUMBER(9);
	l_duty_station_desc		ghr_pa_requests.duty_station_desc%type;
	l_duty_station_code		ghr_pa_requests.duty_station_code%type;
	l_national_identifier		ghr_pa_requests.employee_national_identifier%type;
	l_date_of_birth			ghr_pa_requests.employee_date_of_birth%type;
	l_employee_last_name		ghr_pa_requests.employee_last_name%type;
	l_employee_first_name		ghr_pa_requests.employee_first_name%type;
	l_employee_middle_names		ghr_pa_requests.employee_middle_names%type;
	l_personnel_office_id		ghr_pa_requests.personnel_office_id%type;
	l_office_symbol			ghr_pa_requests.from_office_symbol%type;
	l_position_id         		hr_all_positions_f.position_id%type;
	l_from_position_id              hr_all_positions_f.position_id%type;
	l_from_position_title           hr_all_positions_f.name%type;
	l_location_id         		NUMBER(15);
	l_position_title      		VARCHAR2(150);
	l_position_number     		VARCHAR2(150);
	l_position_seq_no     		NUMBER(15);
	l_pay_plan            		VARCHAR2(150);
	l_job_id              		NUMBER(15);
	l_occ_code            		VARCHAR2(150);
	l_grade_id            		NUMBER(15);
	l_grade_or_level      		VARCHAR2(150);
	l_step_or_rate        		VARCHAR2(150);
	--6850492
        l_step_or_rate1        		VARCHAR2(150);
	l_total_salary        		NUMBER;
	l_pay_basis           		VARCHAR2(150);
	-- FWFA Changes Bug#4444609
	l_pay_table_identifier          NUMBER;
	-- FWFA Changes
	l_basic_pay           		NUMBER;
	l_locality_adj        		NUMBER;
	l_adj_basic_pay       		NUMBER;
	l_other_pay           		NUMBER;
	l_capped_other_pay              NUMBER;
	l_au_overtime			NUMBER;
	l_auo_premium_pay_indicator 	VARCHAR2(30);
	l_availability_pay          	NUMBER;
	l_ap_premium_pay_indicator  	VARCHAR2(30);
	l_retention_allowance       	NUMBER;
	l_supervisory_differential  	NUMBER;
	l_staffing_differential     	NUMBER;
	l_organization_id     		NUMBER(15);
	l_position_org_line1  		VARCHAR2(150);
	l_position_org_line2  		VARCHAR2(150);
	l_position_org_line3  		VARCHAR2(150);
	l_position_org_line4  		VARCHAR2(150);
	l_position_org_line5  		VARCHAR2(150);
	l_position_org_line6  		VARCHAR2(150);
	l_dummy_varchar       		VARCHAR2(150);
	l_citizenship           	VARCHAR2(150);
	l_veterans_preference  		VARCHAR2(150);
	l_veterans_pref_for_rif 	VARCHAR2(150);
	l_veterans_status       	VARCHAR2(150);
	l_service_comp_date     	VARCHAR2(150);
	l_education_level      		VARCHAR2(60);
	l_year_degree_attained 		VARCHAR2(60);
	l_academic_discipline  		VARCHAR2(60);
        l_forwarding_address_line1      per_addresses.address_line1%type;
        l_forwarding_address_line2      per_addresses.address_line2%type;
        l_forwarding_address_line3      per_addresses.address_line3%type;
        l_forwarding_town_or_city       per_addresses.town_or_city%type;
        l_forwarding_region_2           per_addresses.region_2%type;
        l_forwarding_postal_code        per_addresses.postal_code%type;
        l_forwarding_country            per_addresses.country%type;
	l_forwarding_country_short_na   fnd_territories_tl.territory_short_name%type;

	l_tenure                 	VARCHAR2(150);
	l_annuitant_indicator    	VARCHAR2(150);
	l_pay_rate_determinant   	VARCHAR2(150);
	l_fegli                  	VARCHAR2(150);
	l_retirement_plan        	VARCHAR2(150);
	l_multiple_error_flag    	BOOLEAN;
	l_flsa_category          	VARCHAR2(150);
	l_bargaining_unit_status 	VARCHAR2(150);
	l_work_schedule          	VARCHAR2(150);
	l_functional_class       	VARCHAR2(150);
	l_supervisory_status     	VARCHAR2(150);
	l_position_occupied      	VARCHAR2(150);
	l_appropriation_code1    	VARCHAR2(150);
	l_appropriation_code2    	VARCHAR2(150);
	l_part_time_hours        	NUMBER(5,2);
	l_business_group_id		NUMBER(9);
	l_proc				VARCHAR2(30):= 'refresh_pa_request';
--	p_from_location_id		hr_locations.location_id%type;
	l_alt_pa_req_id			NUMBER;
	l_people_data			per_all_people_f%rowtype;
	l_result_code			varchar2(30);
        l_retention_allow_percentage    ghr_pa_requests.to_retention_allow_percentage%type;
        l_supervisory_diff_percentage   ghr_pa_requests.to_supervisory_diff_percentage%type;
        l_staffing_diff_percentage      ghr_pa_requests.to_staffing_diff_percentage%type;
	l_session_var	            ghr_history_api.g_session_var_type;
	l_noa_family_code			ghr_pa_requests.noa_family_code%type;
	l_first_noa_id			ghr_pa_requests.first_noa_id%type;
	l_first_noa_code			ghr_pa_requests.first_noa_code%type;
	l_second_noa_id			ghr_pa_requests.second_noa_id%type;
	l_second_noa_code			ghr_pa_requests.second_noa_code%type;
        l_per_type                      per_person_types.system_person_type%type := hr_api.g_varchar2;
        l_prd                          varchar2(30);
	l_prd1                         varchar2(30);
        l_person_id                    ghr_pa_requests.person_id%type;
        l_temp_to_position_id          ghr_pa_requests.to_position_id%type;
        l_pm                          varchar2(50);

        l_pos_ei_grade_data           per_position_extra_info%rowtype;
	l_sf52_data		      ghr_pa_requests%rowtype;



CURSOR cur_per IS
  SELECT 	per.national_identifier
        	,per.date_of_birth
		,per.first_name
		,per.last_name
		,per.middle_names
  FROM   per_people_f per
  WHERE  per.person_id = p_person_id
  AND    NVL(p_effective_date,TRUNC(sysdate))  between per.effective_start_date and per.effective_end_date;

Cursor get_pos_bg ( c_position_id in number) IS
	select
		business_group_id
	from hr_all_positions_f pos  -- Venkat -- Position DT
	where pos.position_id = c_position_id
         and p_effective_date between pos.effective_start_date
                and pos.effective_end_date;
-- FWFA Changes Commented the input_pay_rate_determinant.
-- FWFA Changes Bug#4444609 Added input_pay_rate_determinant field in the cursor
-- 6850492 Added NVL While refreshing the column for Dual Action,p_sf52_data.pa_request_id is null consider session variable
Cursor get_noa_info IS
	select
		noa_family_code, first_noa_code, first_noa_id,
        second_noa_code, second_noa_id
	, pay_rate_determinant
        /* input_pay_rate_determinant*/
	from ghr_pa_requests
	where pa_request_id = nvl(p_sf52_data.pa_request_id,l_session_var.pa_request_id);
-- FWFA Changes
-- Bug # 1239688 --
cursor get_person_type is
          select ppt.system_person_type
          from   per_people_f ppf,
                 per_person_types ppt
          where   ppf.person_id = p_person_id
          and     p_effective_date
          between ppf.effective_start_date
          and     ppf.effective_end_date
          and     ppt.person_type_id = ppf.person_type_id;

-- JH Get To Position Title PM for Noa Code being updated.
Cursor get_to_posn_title_pm(p_noa_id in number) is
         select  fpm.process_method_code
         from    ghr_noa_families         nof
                 ,ghr_families             fam
                 ,ghr_noa_fam_proc_methods fpm
                 ,ghr_pa_data_fields       pdf
         where   nof.nature_of_action_id = p_noa_id
         and     nof.noa_family_code     = fam.noa_family_code
         and     nof.enabled_flag = 'Y'
         and     p_effective_date between nvl(nof.start_date_active,p_effective_date) and nvl(nof.end_date_active,p_effective_date)
         and     fam.proc_method_flag = 'Y'
         and     fam.enabled_flag = 'Y'
         and     p_effective_date between nvl(fam.start_date_active,p_effective_date) and nvl(fam.end_date_active,p_effective_date)
         and     fam.noa_family_code = fpm.noa_family_code
         and     fpm.pa_data_field_id = pdf.pa_data_field_id
         and     fpm.enabled_flag = 'Y'
         and     p_effective_date between nvl(fpm.start_date_active,p_effective_date) and nvl(fpm.end_date_active,p_effective_date)
         and     pdf.form_field_name = 'TO_POSITION_TITLE'
         and     pdf.enabled_flag = 'Y'
         and     p_effective_date between nvl(pdf.date_from,p_effective_date) and nvl(pdf.date_to,p_effective_date);
	-- Bug 2112935
   l_orig_pa_request_id	  ghr_pa_requests.pa_request_id%type;
   l_orig_pa_notification_id ghr_pa_requests.pa_notification_id%type;
   l_orig_person_id ghr_pa_requests.person_id%type;
   l_orig_effective_date ghr_pa_requests.effective_date%type;
   l_effective_date   ghr_pa_requests.effective_date%type;
   l_retro_first_noa   ghr_nature_of_actions.code%type;
   l_retro_second_noa   ghr_nature_of_actions.code%type;
   l_retro_pa_request_id   ghr_pa_requests.pa_request_id%type;
   l_orig_first_noa   ghr_pa_requests.first_noa_code%type;
   l_orig_second_noa  ghr_pa_requests.second_noa_code%type;

CURSOR c_orig_rec(c_pa_request_id ghr_pa_requests.pa_request_id%type) IS
   SELECT *
   FROM ghr_pa_requests par
   WHERE par.pa_request_id =
							(SELECT min(par1.pa_request_id)
								FROM ghr_pa_requests par1
									start with pa_request_id = c_pa_request_id
									connect by  pa_request_id = prior altered_pa_request_id);

-- 8303159 Dual Actions
cursor get_740_prd
    is
    select pay_rate_determinant
    from   ghr_pa_requests
    where  pa_request_id = (select max(pa_request_id)
                            from   ghr_pa_requests
                            where  pa_notification_id is not null
			    and (first_noa_code = '740' or second_noa_code = '740')
                            start with pa_request_id = (select mass_action_id
                                                        from   ghr_pa_requests
                                                        where  pa_request_id = l_session_var.pa_request_id)
                            connect by  pa_request_id = prior altered_pa_request_id);

cursor chk_sec_corr
    is
    select 1
    from   ghr_pa_requests
    where  pa_request_id =  (SELECT min(par1.pa_request_id)
 			     FROM ghr_pa_requests par1
			     start with pa_request_id = l_session_var.altered_pa_request_id
			     connect by  pa_request_id = prior altered_pa_request_id)
    and    second_noa_id  =l_session_var.noa_id_correct;
-- 8303159 Dual Actions

-- Procedure to get step or rate
PROCEDURE get_asg_step_or_rate(p_position_id IN ghr_pa_requests.to_position_id%type,
								p_effective_date IN ghr_pa_requests.effective_date%type,
								p_step_or_rate OUT NOCOPY ghr_pa_requests.to_step_or_rate%type,
								p_prd OUT NOCOPY ghr_pa_requests.pay_rate_determinant%type ) IS

CURSOR cur_ass_id(c_position_id ghr_pa_requests.to_position_id%type, c_effective_date IN ghr_pa_requests.effective_date%type) IS
  SELECT assignment_id, person_id
  FROM  per_all_assignments_f
  WHERE position_id = c_position_id
  AND   assignment_type <> 'B'
  AND   primary_flag = 'Y'
  AND   c_effective_date
        between effective_start_date and effective_end_date;

l_assignment_id per_all_assignments_f.assignment_id%type;
l_asgei_data    per_assignment_extra_info%rowtype;
l_session ghr_history_api.g_session_var_type;



BEGIN
	-- Get the Assignment ID from the position ID.
	FOR cur_ass_id_rec  IN cur_ass_id(p_position_id,p_effective_date)  LOOP
		l_assignment_id     := cur_ass_id_rec.assignment_id;
	    l_person_id         := cur_ass_id_rec.person_id;
		EXIT;
	END LOOP;
	-- From history fetch the Assignment Information Details for the effective date
	hr_utility.set_location('Eff. date in get_asg_step_or_rate ' || p_effective_date,25);
	IF l_assignment_id IS NOT NULL THEN
		ghr_history_fetch.fetch_asgei (
			p_assignment_id     => l_assignment_id,
			p_information_type  => 'GHR_US_ASG_SF52',
			p_date_effective    => p_effective_date,
			p_asg_ei_data       => l_asgei_data) ;
		IF (l_asgei_data.assignment_extra_info_id IS NOT NULL) THEN
			p_step_or_rate := l_asgei_data.aei_information3;

		ELSE
				ghr_history_api.get_g_session_var(l_session);
			   Ghr_History_Fetch.Fetch_ASGEI_prior_root_sf50
			   (
				p_assignment_id         => l_assignment_id,
				p_information_type      => 'GHR_US_ASG_SF52',
				p_date_effective        => p_effective_date,
				p_altered_pa_request_id => l_session.altered_pa_request_id,
				p_noa_id_corrected      => l_session.noa_id_correct,
				p_get_ovn_flag          => 'Y',
				p_asgei_data            => l_asgei_data
			   );
				p_step_or_rate := l_asgei_data.aei_information3;
		END IF;
		IF l_asgei_data.aei_information6 = '5' then
				p_prd  := '6';
		ELSIF l_asgei_data.aei_information6 = '7' then
			    p_prd  := '0';
		ELSE
			      p_prd  := l_asgei_data.aei_information6;
				  hr_utility.set_location('Sun p_pay_rate_determinant' || p_prd,250);
	    END IF;
	END IF;

END get_asg_step_or_rate;

begin

      l_sf52_data := p_sf52_data ; --NOCOPY Changes

      hr_utility.set_location('Entering: ' || l_proc, 10);
      hr_utility.set_location('pay  Rate in the  beginning of Ref '|| p_sf52_data.pay_rate_determinant,11);
      hr_utility.set_location('To Pay Basis '|| p_sf52_data.to_pay_basis,11);
      hr_utility.set_location('Noa Family Code '|| p_sf52_data.noa_family_code,11);

	ghr_history_api.get_g_session_var( l_session_var);
	for c_rec in get_noa_info LOOP
		l_first_noa_id 	:= c_rec.first_noa_id;
		l_first_noa_code 	:= c_rec.first_noa_code;
		l_noa_family_code := c_rec.noa_family_code;
        l_second_noa_id         := c_rec.second_noa_id;
        l_second_noa_code       := c_rec.second_noa_code;
        -- Reverted FWFA Changes Bug#4444609 Consider input PRD if not null
        l_prd             := c_rec.pay_rate_determinant;
        -- FWFA Changes
  end LOOP;
-- Bug 2568188
-- Fetch the process method for Position Title
      IF l_noa_family_code = 'CORRECT' THEN
        FOR pm_rec in get_to_posn_title_pm(l_second_noa_id) LOOP
          l_pm := pm_rec.process_method_code;
        END Loop;
      ELSE
        FOR pm_rec in get_to_posn_title_pm(l_first_noa_id) LOOP
          l_pm := pm_rec.process_method_code;
        END Loop;
      END IF;


	l_from_position_id := p_sf52_data.from_position_id;
	l_from_position_title := p_sf52_data.from_position_title;

	l_assignment_id := p_sf52_data.employee_assignment_id;
        If l_noa_family_code <> 'APP' THEN
	    GHR_API.sf52_from_data_elements(
		     p_person_id         => p_person_id
            ,p_assignment_id     => l_assignment_id
            ,p_effective_date    => nvl(p_effective_date, trunc(sysdate))
            ,p_altered_pa_request_id => l_session_var.altered_pa_request_id
            ,p_noa_id_corrected  => l_session_var.noa_id_correct
		    ,p_pa_history_id     => l_session_var.pa_history_id
            ,p_position_id       => l_position_id
            ,p_position_title    => l_position_title
            ,p_position_number   => l_position_number
            ,p_position_seq_no   => l_position_seq_no
            ,p_pay_plan          => l_pay_plan
            ,p_job_id            => l_job_id
            ,p_occ_code          => l_occ_code
            ,p_grade_id          => l_grade_id
            ,p_grade_or_level    => l_grade_or_level
            ,p_step_or_rate      => l_step_or_rate
            ,p_total_salary      => l_total_salary
            ,p_pay_basis         => l_pay_basis
	    -- FWFA Changes Bug#4444609
	       ,p_pay_table_identifier => l_pay_table_identifier
	    -- FWFA Changes
            ,p_basic_pay         => l_basic_pay
            ,p_locality_adj      => l_locality_adj
            ,p_adj_basic_pay     => l_adj_basic_pay
            ,p_other_pay         => l_other_pay
            ,p_au_overtime                 => l_au_overtime
            ,p_auo_premium_pay_indicator   => l_auo_premium_pay_indicator
            ,p_availability_pay            => l_availability_pay
            ,p_ap_premium_pay_indicator    => l_ap_premium_pay_indicator
            ,p_retention_allowance         => l_retention_allowance
            ,p_retention_allow_percentage  => l_retention_allow_percentage
            ,p_supervisory_differential    => l_supervisory_differential
            ,p_supervisory_diff_percentage => l_supervisory_diff_percentage
            ,p_staffing_differential       => l_staffing_differential
            ,p_staffing_diff_percentage  => l_staffing_diff_percentage
            ,p_organization_id           => l_organization_id
            ,p_position_org_line1        => l_position_org_line1
            ,p_position_org_line2        => l_position_org_line2
            ,p_position_org_line3        => l_position_org_line3
            ,p_position_org_line4        => l_position_org_line4
            ,p_position_org_line5        => l_position_org_line5
            ,p_position_org_line6        => l_position_org_line6
            ,p_duty_station_location_id  => l_location_id
            ,p_pay_rate_determinant      => l_dummy_varchar
            ,p_work_schedule             => l_dummy_varchar

	);

        l_capped_other_pay := ghr_pa_requests_pkg2.get_cop(l_assignment_id,
                                                          nvl(p_effective_date, trunc(sysdate)));

	if (p_derive_to_cols) then
		p_sf52_data.to_organization_id		:= 	l_organization_id;
		p_sf52_data.to_grade_id				:= 	l_grade_id;
		p_sf52_data.to_job_id				:=	l_job_id;
		p_sf52_data.to_ap_premium_pay_indicator	:= 	l_ap_premium_pay_indicator;
		p_sf52_data.to_auo_premium_pay_indicator	:= 	l_auo_premium_pay_indicator;
		p_sf52_data.to_au_overtime			:= 	l_au_overtime;
		p_sf52_data.to_availability_pay		:= 	l_availability_pay;
		p_sf52_data.to_supervisory_differential	:= 	l_supervisory_differential;
		p_sf52_data.to_supervisory_diff_percentage	:= 	l_supervisory_diff_percentage;
		p_sf52_data.to_staffing_differential	:= 	l_staffing_differential;
		p_sf52_data.to_staffing_diff_percentage:= 	l_staffing_diff_percentage;
		p_sf52_data.to_retention_allowance		:= 	l_retention_allowance;
		p_sf52_data.to_retention_allow_percentage		:= 	l_retention_allow_percentage;
		return;
	end if;
--      p_from_location_id     		     := l_location_id;
      p_sf52_data.duty_station_location_id    := l_location_id;
      p_sf52_data.from_position_title    := l_position_title;
      p_sf52_data.from_position_number   := l_position_number;
      p_sf52_data.from_position_id   	:= l_position_id;
      p_sf52_data.from_position_seq_no   := l_position_seq_no;
      p_sf52_data.from_pay_plan          := l_pay_plan;
      p_sf52_data.employee_assignment_id := l_assignment_id;
      p_sf52_data.from_occ_code          := l_occ_code;
      p_sf52_data.from_grade_or_level    := l_grade_or_level;
      p_sf52_data.from_step_or_rate      := l_step_or_rate;
      p_sf52_data.from_total_salary      := l_total_salary;
      p_sf52_data.from_pay_basis         := l_pay_basis;
      -- FWFA Changes Bug#4444609
      p_sf52_data.from_pay_table_identifier := l_pay_table_identifier;
      -- FWFA Changes
      p_sf52_data.from_basic_pay         := l_basic_pay;
      p_sf52_data.from_locality_adj      := l_locality_adj;
      p_sf52_data.from_adj_basic_pay     := l_adj_basic_pay;
      p_sf52_data.from_other_pay_amount  := nvl(l_capped_other_pay,l_other_pay);
-- Following commented items are not pa_request fields.
--      p_sf52_data.from_job_id            := l_job_id;
--      p_sf52_data.from_grade_id          := l_grade_id;
--      p_sf52_data.from_au_overtime               := l_au_overtime;
--      p_sf52_data.from_auo_premium_pay_indicator := l_auo_premium_pay_indicator;
--      p_sf52_data.from_availability_pay          := l_availability_pay;
--      p_sf52_data.from_ap_premium_pay_indicator  := l_ap_premium_pay_indicator;
--      p_sf52_data.from_retention_allowance       := l_retention_allowance;
--      p_sf52_data.from_retention_allow_percentage := l_retention_allow_percentage;
--      p_sf52_data.from_supervisory_differential  := l_supervisory_differential;
--      p_sf52_data.from_supervisory_diff_percentage  := l_supervisory_diff_percentage;
--      p_sf52_data.from_staffing_differential     := l_staffing_differential;
--      p_sf52_data.from_staffing_diff_percentage     := l_staffing_diff_percentage;
--      p_sf52_data.from_organization_id    := l_organization_id;
     END IF;
      if (l_noa_family_code = 'APP') then
		p_sf52_data.from_position_org_line1 := ghr_pa_requests_pkg2.get_agency_code_from(
									p_pa_request_id	=>	p_sf52_data.pa_request_id,
									p_noa_id		=>    l_first_noa_id);
	else
      	p_sf52_data.from_position_org_line1 := l_position_org_line1;
	end if;
      p_sf52_data.from_position_org_line2 := l_position_org_line2;
      p_sf52_data.from_position_org_line3 := l_position_org_line3;
      p_sf52_data.from_position_org_line4 := l_position_org_line4;
      p_sf52_data.from_position_org_line5 := l_position_org_line5;
      p_sf52_data.from_position_org_line6 := l_position_org_line6;


	l_agency_code := ghr_api.get_position_agency_code(
				p_person_id		=>	p_person_id,
				p_assignment_id	=>	l_assignment_id,
				p_effective_date	=>	p_effective_date);
	p_sf52_data.from_agency_desc := ghr_pa_requests_pkg.get_lookup_meaning(800
                                             ,'GHR_US_AGENCY_CODE'
                                             ,l_agency_code);
	p_sf52_data.agency_code			:= l_agency_code;
	-- ????? is this the right from agency code?
	p_sf52_data.from_agency_code		:= l_agency_code;
	p_sf52_data.from_office_symbol	:=	l_office_symbol;

	if p_from_only then
		return;
	end if;
	if (l_first_noa_code = '352') then
		p_sf52_data.to_position_org_line1 :=
                   ghr_pa_requests_pkg2.get_agency_code_to(
			p_pa_request_id	=> p_sf52_data.pa_request_id,
			p_noa_id	=> l_first_noa_id);
        -- Added by ENUNEZ (23-FEB-2000 bug# 756335)
        elsif (l_first_noa_code = '002' and l_second_noa_code = '352') then
		p_sf52_data.to_position_org_line1 :=
                   ghr_pa_requests_pkg2.get_agency_code_to(
			p_pa_request_id	=> p_sf52_data.pa_request_id,
			p_noa_id	=> l_second_noa_id);
	end if;

	if (p_from_only = FALSE) then

		-- Following other_pay related fields are copied into to_.. fields
		-- because pay_calc is not performed for other_pay family. So by using from
		-- values we can place refreshed values into to_other...fields.
                -- Venkat 04/04/00
                -- Bug # 1239688
                -- Initialization of all the varibles related to Other Pay in the case of Conversion of Ex Employee
                FOR per_type  in get_person_type  LOOP
                  l_per_type := per_type.system_person_type;
                END LOOP;
                IF l_noa_family_code = 'CONV_APP' and nvl(l_per_type,hr_api.g_varchar2) = 'EX_EMP' then
		  p_sf52_data.to_retention_allowance		:= NULL;
		  p_sf52_data.to_retention_allow_percentage	:= NULL;
		  p_sf52_data.to_staffing_differential	:= NULL;
		  p_sf52_data.to_staffing_diff_percentage	:= NULL;
		  p_sf52_data.to_supervisory_differential	:= NULL;
		  p_sf52_data.to_supervisory_diff_percentage:= NULL;
		  p_sf52_data.to_ap_premium_pay_indicator   := NULL;
		  p_sf52_data.to_auo_premium_pay_indicator  := NULL;
		  p_sf52_data.to_au_overtime                :=NULL;
		  p_sf52_data.to_availability_pay           := NULL;
		  p_sf52_data.to_other_pay_amount           := NULL;
                ELSE
		  p_sf52_data.to_retention_allowance		:= l_retention_allowance;
		  p_sf52_data.to_retention_allow_percentage	:= l_retention_allow_percentage;
		  p_sf52_data.to_staffing_differential	:= l_staffing_differential;
		  p_sf52_data.to_staffing_diff_percentage	:= l_staffing_diff_percentage;

		  ----------------------- modified as part of bug #2347244
		   IF (p_sf52_data.first_noa_code  not in ('892','893')) then
                     p_sf52_data.to_supervisory_differential	:= l_supervisory_differential;
		  END IF;

		   p_sf52_data.to_supervisory_diff_percentage:= l_supervisory_diff_percentage;
		  p_sf52_data.to_ap_premium_pay_indicator   := l_ap_premium_pay_indicator;
		  p_sf52_data.to_auo_premium_pay_indicator  := l_auo_premium_pay_indicator;
		  p_sf52_data.to_au_overtime                := l_au_overtime;
		  p_sf52_data.to_availability_pay           := l_availability_pay ;
		  p_sf52_data.to_other_pay_amount           := l_other_pay;
                END IF;
	        hr_utility.set_location('l_from_position_id is  ' ||l_from_position_id, 11);
	        hr_utility.set_location('from_position_id is  ' ||p_sf52_data.from_position_id, 12);
	        hr_utility.set_location('to_position_id is  ' ||p_sf52_data.to_position_id, 13);
	        hr_utility.set_location('to_basic_pay is  ' ||p_sf52_data.to_basic_pay, 14);
		if (nvl(l_from_position_id, -1) <> nvl(p_sf52_data.from_position_id, -1) and
                    nvl(l_from_position_id, -1)  = nvl(p_sf52_data.to_position_id, -2))  then
		-- ie from and to position were same and
                -- from position has been changed because of refresh.

                -- Reverting changes made in Bug # 757932
		-- if nvl(l_from_position_id, -1) = nvl(p_sf52_data.to_position_id, -2)   then
		-- from and to position were same.

	        hr_utility.set_location('Case 1 ', 15);

			p_sf52_data.to_adj_basic_pay              := l_adj_basic_pay;
			p_sf52_data.to_basic_pay                  := l_basic_pay;
			p_sf52_data.to_grade_id                   := l_grade_id;
			p_sf52_data.to_grade_or_level             := l_grade_or_level;
			p_sf52_data.to_job_id                     := l_job_id;
			p_sf52_data.to_locality_adj               := l_locality_adj;
			p_sf52_data.to_occ_code                   := l_occ_code;
			p_sf52_data.to_office_symbol              := l_office_symbol;
			p_sf52_data.to_organization_id            := l_organization_id;
			p_sf52_data.to_pay_basis                  := l_pay_basis;
			p_sf52_data.to_pay_plan                   := l_pay_plan;
			if (l_first_noa_code = '352') then
                	  p_sf52_data.to_position_org_line1 :=
                             ghr_pa_requests_pkg2.get_agency_code_to(
               		       p_pa_request_id => p_sf52_data.pa_request_id,
                	       p_noa_id	=> l_first_noa_id);
                        -- Added by ENUNEZ (23-FEB-2000 bug# 756335)
                        elsif (l_first_noa_code = '002' and l_second_noa_code = '352') then
                	  p_sf52_data.to_position_org_line1 :=
                             ghr_pa_requests_pkg2.get_agency_code_to(
               		       p_pa_request_id => p_sf52_data.pa_request_id,
                	       p_noa_id	=> l_second_noa_id);
			else
				p_sf52_data.to_position_org_line1         := l_position_org_line1;
			end if;
			p_sf52_data.to_position_org_line2      := l_position_org_line2;
			p_sf52_data.to_position_org_line3      := l_position_org_line3;
			p_sf52_data.to_position_org_line4      := l_position_org_line4;
			p_sf52_data.to_position_org_line5      := l_position_org_line5;
			p_sf52_data.to_position_org_line6      := l_position_org_line6;
			p_sf52_data.to_position_number         := l_position_number;
			p_sf52_data.to_position_seq_no	       := l_position_seq_no;
			p_sf52_data.to_position_title	       := l_position_title;
			p_sf52_data.to_step_or_rate	       := l_step_or_rate;
			p_sf52_data.to_total_salary	       := l_total_salary;
                        IF l_pm in ('AP') then
                          p_sf52_data.to_position_id           := l_from_position_id;
                          p_sf52_data.to_position_title        := l_from_position_title;
                        ELSE
                          p_sf52_data.to_position_id           := p_sf52_data.from_position_id;
                          p_sf52_data.to_position_title        := p_sf52_data.from_position_title
;
                        END IF;
                -- Start Bug 1310894
		elsif nvl(l_from_position_id, -1) = nvl(p_sf52_data.to_position_id, -2)
                      and l_noa_family_code = 'OTHER_PAY'   then
	        hr_utility.set_location('Case 2 ', 15);
			-- Other Pay action and From and To Position were same.
			p_sf52_data.to_adj_basic_pay            := l_adj_basic_pay;
			p_sf52_data.to_basic_pay                := l_basic_pay;
			p_sf52_data.to_grade_id                 := l_grade_id;
			p_sf52_data.to_grade_or_level           := l_grade_or_level;
			p_sf52_data.to_job_id                   := l_job_id;
			p_sf52_data.to_locality_adj             := l_locality_adj;
			p_sf52_data.to_occ_code                 := l_occ_code;
			p_sf52_data.to_office_symbol            := l_office_symbol;
			p_sf52_data.to_organization_id          := l_organization_id;
			p_sf52_data.to_pay_basis                := l_pay_basis;
			p_sf52_data.to_pay_plan                 := l_pay_plan;
			p_sf52_data.to_position_org_line1       := l_position_org_line1;
			p_sf52_data.to_position_org_line2       := l_position_org_line2;
			p_sf52_data.to_position_org_line3       := l_position_org_line3;
			p_sf52_data.to_position_org_line4       := l_position_org_line4;
			p_sf52_data.to_position_org_line5       := l_position_org_line5;
			p_sf52_data.to_position_org_line6       := l_position_org_line6;
			p_sf52_data.to_position_number          := l_position_number;
			p_sf52_data.to_position_seq_no		:= l_position_seq_no;
			p_sf52_data.to_position_title		:= l_position_title;
			p_sf52_data.to_step_or_rate		:= l_step_or_rate;
			--p_sf52_data.to_total_salary		:= l_total_salary;
			p_sf52_data.to_position_id 		:= p_sf52_data.from_position_id;
			p_sf52_data.to_position_title		:= p_sf52_data.from_position_title;
                -- End Bug 1310894
		elsif p_sf52_data.to_position_id is not NULL then
			-- User has entered to_position
                	hr_utility.set_location('Case 3 ', 15);
			l_position_id := p_sf52_data.to_position_id;

			-- get to_position columns
				-- Bug 2112935 Sundar
				-- For Retro 866 and 740, need to pass initial PRD as null.
				-- Call determine_ia to Find out Retro NOAs.
				hr_utility.set_location('l_session_var.altered_pa_request_id ' || l_session_var.altered_pa_request_id ,15);

					FOR l_orig_rec IN c_orig_rec(l_session_var.altered_pa_request_id) LOOP
					   l_orig_pa_request_id := l_orig_rec.pa_request_id;
					   l_orig_pa_notification_id := l_orig_rec.pa_notification_id;
					   l_orig_person_id := l_orig_rec.person_id;
					   l_orig_effective_date := l_orig_rec.effective_date;
					   --Bug # 8303159 added for dual actions
					   l_orig_first_noa := l_orig_rec.first_noa_code;
					   l_orig_second_noa := l_orig_rec.second_noa_code;
					END LOOP;
	      			    --BUG #7216635 added the parameter p_noa_id_correct
					GHR_APPROVED_PA_REQUESTS.determine_ia(
								 p_pa_request_id => l_orig_pa_request_id,
								 p_pa_notification_id => l_orig_pa_notification_id,
								 p_person_id      => l_orig_person_id,
								 p_effective_date => nvl(l_orig_effective_date, trunc(sysdate)),
								 p_noa_id_correct => l_session_var.noa_id_correct,
								 p_retro_eff_date => l_effective_date,
								 p_retro_pa_request_id => l_retro_pa_request_id,
								 p_retro_first_noa => l_retro_first_noa,
								 p_retro_second_noa => l_retro_second_noa);
					hr_utility.set_location('Retro 1st NOA ' || l_retro_first_noa ,15);
					hr_utility.set_location('Retro 2nd NOA ' || l_retro_second_noa ,15);

                                        -- 8303159 For dual actions with 740 combination if first noa code is 740 need to
					-- consider it is as retro NOA
				       IF l_session_var.altered_pa_request_id is not null and l_orig_second_noa is not null
					   and l_orig_first_noa = '740' then
					  for rec_chk_corr in chk_sec_corr
					  loop
					   l_retro_first_noa := '740';
					   for rec_prd in get_740_prd
					   loop
					      p_sf52_data.pay_rate_determinant := rec_prd.pay_rate_determinant;
					   end loop;
					  end loop;
					END IF;


					IF ((l_retro_first_noa = '866' OR l_retro_second_noa = '866') OR
						(l_retro_first_noa = '740' OR l_retro_second_noa = '740')) THEN
							NULL;
					ELSE
					         hr_utility.set_location('FWFA prd :'||l_prd,80);
						hr_utility.set_location('FWFA refresh prd :'||p_sf52_data.pay_rate_determinant,90);
						 IF l_prd IS NOT NULL AND
							l_prd <>  nvl(p_sf52_data.pay_rate_determinant,hr_api.g_varchar2) then
							p_sf52_data.pay_rate_determinant := l_prd;
						 END IF;
						 hr_utility.set_location('p_sf52_data.to_position_id'||p_sf52_data.to_position_id,10);
        					 hr_utility.set_location('p_sf52_data.from_position_id'||p_sf52_data.from_position_id,11);
  					         --6850492
   					           get_asg_step_or_rate(p_sf52_data.to_position_id,p_sf52_data.effective_date,l_step_or_rate1,l_prd1);
					         --6850492
					         hr_utility.set_location('l_prd1'||l_prd,10);
     					         hr_utility.set_location('l_step_or_rate1'||l_step_or_rate1,12);

					        -- Added to compare step or rate with '00' for dual actions
					         IF l_step_or_rate1 IS NOT NULL AND
						    l_step_or_rate1 <>  nvl(p_sf52_data.to_step_or_rate,hr_api.g_varchar2) AND
						    p_sf52_data.to_step_or_rate <> '00' then
						   p_sf52_data.to_step_or_rate := l_step_or_rate1;
        				         END IF;

						 --For Dual combination with Return to Duty PRD need to be considered prior to root sf50
						 IF (p_sf52_data.pay_rate_determinant IS NULL)  THEN
				                    p_sf52_data.pay_rate_determinant := l_prd1;
		                  		 END IF;
					         -- end if;

					         --6850492
					END IF;
             hr_utility.set_location('bef  call to to_data PRD ' || p_sf52_data.pay_rate_determinant ,15);
             hr_utility.set_location('bef  call to to_data pay BAsis ' || p_sf52_data.to_pay_basis ,15);
			ghr_pa_requests_pkg.get_sf52_to_data_elements
                      (p_position_id               => p_sf52_data.to_position_id
                      ,p_effective_date            => p_sf52_data.effective_date
                      ,p_prd                       => p_sf52_data.pay_rate_determinant
                      ,p_grade_id                  => l_grade_id
                      ,p_job_id                    => l_job_id
                      ,p_location_id               => l_location_id
                      ,p_organization_id           => l_organization_id
                      ,p_pay_plan                  => l_pay_plan
                      ,p_occ_code                  => l_occ_code
                      ,p_grade_or_level            => l_grade_or_level
                      ,p_pay_basis                 => l_pay_basis
                      ,p_position_org_line1        => l_position_org_line1
                      ,p_position_org_line2        => l_position_org_line2
                      ,p_position_org_line3        => l_position_org_line3
                      ,p_position_org_line4        => l_position_org_line4
                      ,p_position_org_line5        => l_position_org_line5
                      ,p_position_org_line6        => l_position_org_line6
                      ,p_duty_station_id           => l_duty_station_id
                      );
             hr_utility.set_location('After  call to to_data PRD ' || p_sf52_data.pay_rate_determinant ,15);


                       --Added 855 for bug 3617311
		       --6850492 added 713 to compare for dual actions as 713 can be performed as a second action
		       --Bug# 7690029 added NVL to l_second_noa_code
                      IF ( l_first_noa_code <> '713' and  NVL(l_second_noa_code,'$$$') <> '713'  AND l_first_noa_code <> '855'
		          AND NVL(l_second_noa_code,'$$$') <> '855' ) THEN
			p_sf52_data.to_grade_id                   := l_grade_id;
			p_sf52_data.to_grade_or_level             := l_grade_or_level;
			p_sf52_data.to_pay_plan                   := l_pay_plan;
                      END IF;
			p_sf52_data.to_job_id                    	:= l_job_id;
			p_sf52_data.to_occ_code                   := l_occ_code;
			p_sf52_data.to_organization_id            := l_organization_id;
--			p_sf52_data.to_other_pay_amount           := l_other_pay;
			p_sf52_data.to_pay_basis                  := l_pay_basis;
			-- vsm : commented following stmt. May have an impact. Need to test refresh
			-- dkk : put following statement back in. See BUG # 741064.
			IF ((l_retro_first_noa = '866' OR l_retro_second_noa = '866') OR
						(l_retro_first_noa = '740' OR l_retro_second_noa = '740')) THEN

			       --6973711
			       IF l_session_var.noa_id_correct is not null and l_noa_family_code = 'RETURN_TO_DUTY' then
 			          IF (p_sf52_data.pay_rate_determinant IS NULL) THEN
    				    p_sf52_data.pay_rate_determinant := l_prd;
				  END IF;
			       END IF;
			       --6973711
				-- Get PRD, Step or rate from Asg DDF.
				get_asg_step_or_rate(p_sf52_data.to_position_id,p_sf52_data.effective_date,l_step_or_rate,l_prd);
				IF (p_sf52_data.to_step_or_rate IS NULL) THEN
					p_sf52_data.to_step_or_rate	:= l_step_or_rate;
				END IF;
				IF (p_sf52_data.pay_rate_determinant IS NULL) THEN
					p_sf52_data.pay_rate_determinant := l_prd;
				END IF;
			ELSE
			-- Bug 2112935
				IF (p_sf52_data.to_step_or_rate IS NULL) THEN
  			            p_sf52_data.to_step_or_rate			:= l_step_or_rate;
  			        END IF;
			END IF;

              hr_utility.set_location('aft  call to to_data pay BAsis ' || p_sf52_data.to_pay_basis ,16);
              if nvl(p_sf52_data.pay_rate_determinant,hr_api.g_varchar2) in  ('A','B','E','F','U','V') then

----Temp Promo Changes by AVR 03-JUN-2000--Start---

                 if nvl(p_sf52_data.pay_rate_determinant,hr_api.g_varchar2) in  ('A','B','E','F') AND
                    ghr_pa_requests_pkg.temp_step_true(p_sf52_data.pa_request_id) THEN
                         ghr_history_fetch.fetch_positionei(
                              p_position_id      => p_sf52_data.to_position_id,
                              p_information_type => 'GHR_US_POS_VALID_GRADE',
                              p_date_effective   => p_sf52_data.effective_date,
                              p_pos_ei_data      => l_pos_ei_grade_data);

                    p_sf52_data.to_pay_basis := l_pos_ei_grade_data.poei_information6;
                 else
----Temp Promo Changes by AVR 03-JUN-2000--End---

                     p_sf52_data.to_pay_basis  := ghr_pa_requests_pkg.get_upd34_pay_basis
                            (p_person_id  =>  p_person_id,
                            p_position_id =>  p_sf52_data.to_position_id,
                            p_prd         =>  p_sf52_data.pay_rate_determinant,
                            p_pa_request_id =>  p_sf52_data.pa_request_id,
                            p_effective_date =>  p_sf52_data.effective_date);
                 end if;
              hr_utility.set_location('aft  call to upda 34 pay BAsis ' || p_sf52_data.to_pay_basis ,1);
              end  if;
              hr_utility.set_location('aft  call to upda 34 pay BAsis outside if '
                                                                 || p_sf52_data.to_pay_basis ,1);

			if (l_first_noa_code = '352') then
                	  p_sf52_data.to_position_org_line1 :=
                             ghr_pa_requests_pkg2.get_agency_code_to(
                	       p_pa_request_id	=> p_sf52_data.pa_request_id,
                	       p_noa_id	=> l_first_noa_id);
                        -- Added by ENUNEZ (23-FEB-2000 bug# 756335)
                        elsif (l_first_noa_code = '002' and l_second_noa_code = '352') then
                	  p_sf52_data.to_position_org_line1 :=
                             ghr_pa_requests_pkg2.get_agency_code_to(
                	       p_pa_request_id	=> p_sf52_data.pa_request_id,
                	       p_noa_id	=> l_second_noa_id);
			else
				p_sf52_data.to_position_org_line1         := l_position_org_line1;
			end if;
			p_sf52_data.to_position_org_line1         := l_position_org_line1;
			p_sf52_data.to_position_org_line2         := l_position_org_line2;
			p_sf52_data.to_position_org_line3         := l_position_org_line3;
			p_sf52_data.to_position_org_line4         := l_position_org_line4;
			p_sf52_data.to_position_org_line5         := l_position_org_line5;
			p_sf52_data.to_position_org_line6         := l_position_org_line6;
/*
			p_sf52_data.to_position_number            := l_position_number;
			p_sf52_data.to_position_seq_no		:= l_position_seq_no;
			p_sf52_data.to_position_title			:= l_position_title;
			p_sf52_data.to_retention_allowance		:= l_retention_allowance;
			p_sf52_data.to_retention_allow_percentage	:= l_retention_allow_percentage;
			p_sf52_data.to_staffing_differential	:= l_staffing_differential;
			p_sf52_data.to_staffing_diff_percentage	:= l_staffing_diff_percentage;
			p_sf52_data.to_supervisory_differential	:= l_supervisory_differential;
			p_sf52_data.to_supervisory_diff_percentage:= l_supervisory_diff_percentage;
*/
			open get_pos_bg ( P_sf52_data.to_position_id);
			fetch get_pos_bg into l_business_group_id;
			if get_pos_bg%notfound then
				close get_pos_bg;
				hr_utility.set_location ( l_proc || 'get_pos_bg not found ', 100);
			      hr_utility.set_message(8301 , 'GHR_38415_BUSN_GRP_NOT_FOUND');
			      hr_utility.raise_error;
			else
				close get_pos_bg;
			end if;

			p_sf52_data.to_position_number := ghr_api.get_position_desc_no_pos
				(p_position_id         => p_sf52_data.to_position_id
				,p_business_group_id   => l_business_group_id
                                ,p_effective_date      => p_effective_date);

			p_sf52_data.to_position_seq_no := ghr_api.get_position_sequence_no_pos
				(p_position_id       => p_sf52_data.to_position_id
				,p_business_group_id => l_business_group_id
                                ,p_effective_date      => p_effective_date);

			p_sf52_data.to_position_title := ghr_api.get_position_title_pos
				(p_position_id       => p_sf52_data.to_position_id
				,p_business_group_id => l_business_group_id
                                ,p_effective_date      => p_effective_date);

-- JH DS starts populated from ASG.  Populate using To Position if To Posn PM is UE, or APUE and
-- to_posn <> from posn.
--
                  hr_utility.set_location('To Posn ID ' || p_sf52_data.to_position_id ,20);
                  IF p_sf52_data.to_position_id IS NOT NULL THEN
/* l_pm value determined above
	              FOR pm_rec in get_to_posn_title_pm LOOP
                      l_pm := pm_rec.process_method_code;
                    END Loop;
*/
                    hr_utility.set_location('To Posn PM ' || l_pm ,20);
                    IF l_pm = 'UE' THEN
			    p_sf52_data.duty_station_location_id	:= l_location_id;
			    p_sf52_data.duty_station_id           := l_duty_station_id;
                    ELSIF l_pm = 'APUE' and nvl(p_sf52_data.to_position_id,hr_api.g_number)
                      <> nvl(p_sf52_data.from_position_id,hr_api.g_number) THEN
			    p_sf52_data.duty_station_location_id	:= l_location_id;
			    p_sf52_data.duty_station_id           := l_duty_station_id;
                    END IF;
			END IF;

		end if;
	end if;
	-- If the refresh is for realignment then refresh position org. lines using the procedure
	-- ghr_pa_requests_pkg.get_rei_org_lines
	if p_sf52_data.first_noa_code = '790' or
	   p_sf52_data.second_noa_code = '790' then
		hr_utility.set_location('Realignment NOA: ' || l_proc, 410);
		ghr_pa_requests_pkg.get_rei_org_lines(
			P_PA_REQUEST_ID		=>	p_sf52_data.pa_request_id,
			P_ORGANIZATION_ID		=>	l_organization_id,
			P_POSITION_ORG_LINE1	=>	l_position_org_line1,
			P_POSITION_ORG_LINE2	=>	l_position_org_line2,
			P_POSITION_ORG_LINE3	=>	l_position_org_line3,
			P_POSITION_ORG_LINE4	=>	l_position_org_line4,
			P_POSITION_ORG_LINE5	=>	l_position_org_line5,
			P_POSITION_ORG_LINE6	=>	l_position_org_line6
		);
		if l_organization_id is not NULL then
			hr_utility.set_location('Realignment NOA Refreshed: ' || l_proc, 420);
		      p_sf52_data.to_position_org_line1 := l_position_org_line1;
		      p_sf52_data.to_position_org_line2 := l_position_org_line2;
		      p_sf52_data.to_position_org_line3 := l_position_org_line3;
		      p_sf52_data.to_position_org_line4 := l_position_org_line4;
		      p_sf52_data.to_position_org_line5 := l_position_org_line5;
		      p_sf52_data.to_position_org_line6 := l_position_org_line6;
		else
			hr_utility.set_location('Realignment NOA NOT Refreshed:  ' || l_proc, 430);
		end if;
	end if;

	ghr_pa_requests_pkg.get_SF52_loc_ddf_details
     	               (p_location_id      => p_sf52_data.duty_station_location_id
           	         ,p_duty_station_id  => l_duty_station_id);

	p_sf52_data.duty_station_id			:= l_duty_station_id;

       ghr_pa_requests_pkg.get_duty_station_details
      	        (p_duty_station_id	=> l_duty_station_id
			  ,p_effective_date	=> p_sf52_data.effective_date
            	  ,p_duty_station_code	=> l_duty_station_code
	              ,p_duty_station_desc	=> l_duty_station_desc);
--    p_sf52_data.duty_station_location_id    := l_location_id;
--	p_sf52_data.duty_station_id		:=	l_duty_station_id;
	p_sf52_data.duty_station_code		:=	l_duty_station_code;
	p_sf52_data.duty_station_desc		:=	l_duty_station_desc;

	ghr_pa_requests_pkg.get_SF52_pos_ddf_details
	     	            (p_position_id            => l_position_id
            	      ,p_date_effective         => p_effective_date
	                  ,p_flsa_category          => l_flsa_category
      	            ,p_bargaining_unit_status => l_bargaining_unit_status
            	      ,p_work_schedule          => l_work_schedule
                  	,p_functional_class       => l_functional_class
	                  ,p_supervisory_status     => l_supervisory_status
      	            ,p_position_occupied      => l_position_occupied
            	    	,p_appropriation_code1    => l_appropriation_code1
          	      	,p_appropriation_code2    => l_appropriation_code2
			   	,p_personnel_office_id    => l_personnel_office_id
			   	,p_office_symbol	     	  => l_office_symbol
      	     	      ,p_part_time_hours        => l_part_time_hours);

	        hr_utility.set_location('l_work_schedule is  ' || l_work_schedule, 11);
	if (not p_from_only) then
	        hr_utility.set_location('l_work_schedule is  ' || l_work_schedule, 12);
			p_sf52_data.flsa_category	 	:=	l_flsa_category  ;
			p_sf52_data.bargaining_unit_status	:=	l_bargaining_unit_status;
			p_sf52_data.work_schedule		:=	l_work_schedule;
			p_sf52_data.functional_class	 	:=	l_functional_class  ;
			p_sf52_data.supervisory_status 	:=	l_supervisory_status ;
			p_sf52_data.position_occupied		:=	l_position_occupied;
			p_sf52_data.appropriation_code1	:=	l_appropriation_code1;
			p_sf52_data.appropriation_code2	:=	l_appropriation_code2;
			p_sf52_data.personnel_office_id	:=	l_personnel_office_id;
			p_sf52_data.part_time_hours		:=	l_part_time_hours;

			p_sf52_data.work_schedule_desc := ghr_pa_requests_pkg.get_lookup_meaning(800
	      	                                       ,'GHR_US_WORK_SCHEDULE'
		                                             ,l_work_schedule);
	end if;
	        hr_utility.set_location('l_work_schedule_desc is  ' || p_sf52_data.work_schedule_desc, 13);
	if (p_from_only = FALSE) then
		ghr_history_fetch.fetch_people(
			p_person_id				=> p_person_id,
			p_date_effective			=> p_effective_date,
			p_altered_pa_request_id		=> l_session_var.altered_pa_request_id,
			p_noa_id_corrected		=> l_session_var.noa_id_correct,
			p_pa_history_id			=> l_session_var.pa_history_id,
			p_people_data			=> l_people_data,
			p_result_code			=> l_result_code
		);
		if (l_result_code is not null) then
			hr_utility.set_location(l_proc || 'non-null result_code', 910);
		end if;

		p_sf52_data.employee_national_identifier	:=	l_people_data.national_identifier;
		p_sf52_data.employee_date_of_birth	:=	l_people_data.date_of_birth;
		p_sf52_data.employee_first_name	:=	l_people_data.first_name;
		p_sf52_data.employee_last_name	:=	l_people_data.last_name;
		p_sf52_data.employee_middle_names	:=	l_people_data.middle_names;

/*
	  	FOR cur_per_rec IN cur_per LOOP
    			l_national_identifier := cur_per_rec.national_identifier;
    			l_date_of_birth       := cur_per_rec.date_of_birth;
			l_employee_first_name := cur_per_rec.first_name;
			l_employee_last_name  := cur_per_rec.last_name;
			l_employee_middle_names:= cur_per_rec.middle_names;
	  	END LOOP;
		p_sf52_data.employee_national_identifier	:=	l_national_identifier;
		p_sf52_data.employee_date_of_birth	:=	l_date_of_birth;
		p_sf52_data.employee_first_name	:=	l_employee_first_name;
		p_sf52_data.employee_last_name	:=	l_employee_last_name;
		p_sf52_data.employee_middle_names	:=	l_employee_middle_names;
*/
	    	ghr_pa_requests_pkg.get_SF52_person_ddf_details
     	                (p_person_id             => p_person_id
     	                ,p_date_effective        => p_effective_date
     	                ,p_citizenship           => l_citizenship
     	                ,p_veterans_preference   => l_veterans_preference
     	                ,p_veterans_pref_for_rif => l_veterans_pref_for_rif
     	                ,p_veterans_status       => l_veterans_status
     	                ,p_scd_leave             => l_service_comp_date);

		p_sf52_data.citizenship			:=	l_citizenship;
		p_sf52_data.veterans_preference	        :=	l_veterans_preference;
		p_sf52_data.veterans_pref_for_rif	:=	l_veterans_pref_for_rif;
		p_sf52_data.veterans_status		:=	l_veterans_status;
		p_sf52_data.service_comp_date		:=	fnd_date.canonical_to_date(l_service_comp_date);
--, 'YYYY/MM/DD HH24:MI:SS');

		ghr_api.return_education_details(
			p_person_id            => p_person_id
                 ,p_effective_date       => p_effective_date
                 ,p_education_level      => l_education_level
                 ,p_academic_discipline  => l_academic_discipline
                 ,p_year_degree_attained => l_year_degree_attained);
		p_sf52_data.education_level		:=	l_education_level;
		p_sf52_data.academic_discipline	:=	l_academic_discipline;
		p_sf52_data.year_degree_attained	:=	l_year_degree_attained;

	      ghr_pa_requests_pkg.get_address_details
                       (p_person_id            => p_person_id
                       ,p_effective_date       => p_effective_date
                       ,p_address_line1        => l_forwarding_address_line1
                       ,p_address_line2        => l_forwarding_address_line2
                       ,p_address_line3        => l_forwarding_address_line3
                       ,p_town_or_city         => l_forwarding_town_or_city
                       ,p_region_2             => l_forwarding_region_2
                       ,p_postal_code          => l_forwarding_postal_code
                       ,p_country              => l_forwarding_country
                       ,p_territory_short_name => l_forwarding_country_short_na);

		p_sf52_data.forwarding_address_line1:=	l_forwarding_address_line1;
		p_sf52_data.forwarding_address_line2:=	l_forwarding_address_line2;
		p_sf52_data.forwarding_address_line3:=	l_forwarding_address_line3;
		p_sf52_data.forwarding_town_or_city	:=	l_forwarding_town_or_city;
		p_sf52_data.forwarding_region_2	:=	l_forwarding_region_2;
		p_sf52_data.forwarding_postal_code 	:=	l_forwarding_postal_code ;
		p_sf52_data.forwarding_country	:=	l_forwarding_country;
		p_sf52_data.forwarding_country_short_name	:=	l_forwarding_country_short_na;

-- JH altered to return WS/PTH directly to p_sf52_data.
	   	ghr_pa_requests_pkg.get_SF52_asg_ddf_details
	                     (p_assignment_id         => l_assignment_id
	                     ,p_date_effective        => p_effective_date
	                     ,p_tenure                => l_tenure
	                     ,p_annuitant_indicator   => l_annuitant_indicator
	                     ,p_pay_rate_determinant  => l_pay_rate_determinant
                           ,p_work_schedule         => p_sf52_data.work_schedule
                           ,p_part_time_hours       => p_sf52_data.part_time_hours);

		p_sf52_data.tenure		 	:=	l_tenure ;
		p_sf52_data.annuitant_indicator	:=	l_annuitant_indicator;
------Bug 3038095
                IF p_sf52_data.first_noa_code = '866'
                   AND l_session_var.noa_id_correct is not NULL THEN
                   Null;
                ELSE
                  -- FWFA Changes Bug#4444609 Modified the prd as In_prd.
		          p_sf52_data.input_pay_rate_determinant	:=	l_pay_rate_determinant;
                END IF;
------Bug 3038095 End

-- JH Asg WS/PTH is populated by default, then overwritten by To Position WS/PTH
-- If the To Position Process Method is UE, or APUE and To Posn <> From Posn.
            IF p_sf52_data.to_position_id IS NOT NULL THEN
/* l_pm value determined above
	        FOR pm_rec in get_to_posn_title_pm LOOP
                l_pm := pm_rec.process_method_code;
              END Loop;
*/
              IF l_pm = 'UE' THEN
                p_sf52_data.work_schedule           :=    l_work_schedule;
                p_sf52_data.part_time_hours         :=    l_part_time_hours;
              ELSIF l_pm = 'APUE' AND nvl(p_sf52_data.to_position_id,hr_api.g_number)
                <> nvl(p_sf52_data.from_position_id,hr_api.g_number) THEN
                p_sf52_data.work_schedule           :=    l_work_schedule;
                p_sf52_data.part_time_hours         :=    l_part_time_hours;
              END IF;
            END IF;
-- JH

	    	ghr_api.retrieve_element_entry_value
	                     (p_element_name        => 'FEGLI'
	                     ,p_input_value_name    => 'FEGLI'
	                     ,p_assignment_id       => l_assignment_id
	                     ,p_effective_date      => p_effective_date
	                     ,p_value               => l_fegli
	                     ,p_multiple_error_flag => l_multiple_error_flag);

		/*
		if (l_multiple_error_flag) then
	    		hr_utility.set_message(8301 , 'GHR_99999_MULT_ERR_FLAG');
			hr_utility.raise_error;
		end if;
		*/

		p_sf52_data.fegli		 	:=	l_fegli ;
		p_sf52_data.fegli_desc := ghr_pa_requests_pkg.get_lookup_meaning(800
 	                                            ,'GHR_US_FEGLI'
	                                             ,l_fegli);

	    	ghr_api.retrieve_element_entry_value
	                     (p_element_name        => 'Retirement Plan'
	                     ,p_input_value_name    => 'Plan'
	                     ,p_assignment_id       => l_assignment_id
	     	               ,p_effective_date      => p_effective_date
	     	               ,p_value               => l_retirement_plan
		               ,p_multiple_error_flag => l_multiple_error_flag);
		/*
		if (l_multiple_error_flag) then
    			hr_utility.set_message(8301 , 'GHR_99999_MULT_ERR_FLAG2');
			hr_utility.raise_error;
		end if;
		*/

		p_sf52_data.retirement_plan		 	:=	l_retirement_plan ;
		p_sf52_data.retirement_plan_desc := ghr_pa_requests_pkg.get_lookup_meaning(800
     	                                        ,'GHR_US_RETIREMENT_PLAN'
	                                             ,l_retirement_plan);

	end if;

--- Code for converting the pay values per Retain Grade Pay Basis
--  if employee is on retain grade
  hr_utility.set_location('PRD is '|| p_sf52_data.pay_rate_determinant,1 );
  hr_utility.set_location('Eff Date is '|| p_sf52_data.effective_date,1 );
  hr_utility.set_location('PER ID '|| p_person_id,1 );
  hr_utility.set_location('POS ID '|| p_sf52_data.to_position_id,1 );
  hr_utility.set_location('from_basic_pay is '|| p_sf52_data.from_basic_pay,1 );
  hr_utility.set_location('from_locality_adj is '|| p_sf52_data.from_locality_adj,1 );
  hr_utility.set_location('from_adj_basic_pay is '|| p_sf52_data.from_adj_basic_pay,1 );
  hr_utility.set_location('from_total_salary is '|| p_sf52_data.from_total_salary,1 );
IF p_sf52_data.pay_rate_determinant IN ('A','B','E','F','U','V') THEN
  IF l_from_position_id = p_sf52_data.to_position_id  and
     l_session_var.noa_id_correct is not NULL and
     l_pm = 'AP' THEN
----Temp Promo Changes by AVR 03-JUN-2000--Start---

                 if p_sf52_data.pay_rate_determinant in  ('A','B','E','F') AND
                    ghr_pa_requests_pkg.temp_step_true(p_sf52_data.pa_request_id) THEN
                         ghr_history_fetch.fetch_positionei(
                              p_position_id      => p_sf52_data.to_position_id,
                              p_information_type => 'GHR_US_POS_VALID_GRADE',
                              p_date_effective   => p_sf52_data.effective_date,
                              p_pos_ei_data      => l_pos_ei_grade_data);

                    p_sf52_data.to_pay_basis := l_pos_ei_grade_data.poei_information6;
                 else
----Temp Promo Changes by AVR 03-JUN-2000--End---

     p_sf52_data.to_pay_basis      :=
                   ghr_pa_requests_pkg.get_upd34_pay_basis
                     (p_person_id      => p_person_id
                     ,p_position_id    => p_sf52_data.to_position_id
                     ,p_prd            => p_sf52_data.pay_rate_determinant
                     ,p_pa_request_id  =>  p_sf52_data.pa_request_id
                     ,p_effective_date => nvl(p_sf52_data.effective_date,trunc(sysdate)));
                 end if;
    IF NOT ghr_pa_requests_pkg.temp_step_true(p_sf52_data.pa_request_id) THEN
    IF p_sf52_data.from_pay_basis <> p_sf52_data.to_pay_basis THEN
      p_sf52_data.to_basic_pay    := ghr_pay_calc.convert_amount(p_sf52_data.from_basic_pay
                                       ,p_sf52_data.from_pay_basis
                                       ,p_sf52_data.to_pay_basis);
      p_sf52_data.to_locality_adj := ghr_pay_calc.convert_amount(p_sf52_data.from_locality_adj
                                       ,p_sf52_data.from_pay_basis
                                       ,p_sf52_data.to_pay_basis);
      p_sf52_data.to_adj_basic_pay := ghr_pay_calc.convert_amount(p_sf52_data.from_adj_basic_pay
                                       ,p_sf52_data.from_pay_basis
                                       ,p_sf52_data.to_pay_basis);
      p_sf52_data.to_total_salary := ghr_pay_calc.convert_amount(p_sf52_data.from_total_salary
                                       ,p_sf52_data.from_pay_basis
                                       ,p_sf52_data.to_pay_basis);
    END IF;
    END IF;
  END IF;
END IF;
	-- display all values retrieved
	print_sf52('Retrieved by refresh: ', p_sf52_data);

	hr_utility.set_location('Leaving: ' || l_proc, 100);

EXCEPTION
  WHEN others THEN
     -- Reset IN OUT parameters and set OUT parameters

      p_sf52_data := l_sf52_data ;

   hr_utility.set_location('Leaving  ' || l_proc,80);
   RAISE;

end refresh_pa_request;

-- ---------------------------------------------------------------------------
-- |--------------------------< get_par_ap_apue_fields>-----------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   	This procedure copies the AP/APUE fields from p_pa_req_in to p_pa_req_out
--
-- Pre-Requisities:
--   	None.
--
-- In Parameters:
--	p_pa_req_in		->	pa_request record is passed here. This should contain
--					values for all fields that need to be considered for
--					copying into p_pa_req_out.
--	p_pa_req_out	->	This will contain all the AP/APUE fields contained in
--					p_pa_req_in.
--
-- Post Success:
-- 	All the fields in p_pa_req_out will have been populated according to process methods.
--
-- Post Failure:
--   No Failure conditions.
--
-- Developer Implementation Notes:
--	None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------

PROCEDURE get_par_ap_apue_fields (p_pa_req_in		in ghr_pa_requests%rowtype,
				  p_first_noa_id	in ghr_pa_requests.first_noa_id%type,
				  p_second_noa_id	in ghr_pa_requests.second_noa_id%type,
				  p_pa_req_out		out nocopy ghr_pa_requests%rowtype) IS

   TYPE fields_type	is	record
	(form_field_name		ghr_pa_data_fields.form_field_name%TYPE	);

   TYPE fld_names_typ   is TABLE of fields_type
			INDEX BY BINARY_INTEGER;
   l_fld_names_tab	fld_names_typ;
   l_pa_req		ghr_pa_requests%rowtype;
   l_column_count	number := 0;
   l_proc	varchar2(30):='get_par_ap_apue_fields';

--
   PROCEDURE initialize_fld_names_table (p_1st_noa_id  		in	number,
					p_2nd_noa_id		in	number default null,
					p_fld_names_tab		in out 	nocopy  fld_names_typ) IS
   --
   -- initializes the local pl/sql table with the field names from ghr_pa_data_fields table.
   --
--
	-- this cursor fetches the form_field_names for the 1st_noa_id and 2nd_noa_id specified.
	CURSOR cur_flds2(	p_1st_noa_id number,
				p_2nd_noa_id number) IS
		SELECT	fld.form_field_name
		FROM
			ghr_families			ghrf,
			ghr_noa_fam_proc_methods	met,
			ghr_pa_data_fields		fld,
			ghr_noa_families			fam
		WHERE
			    fam.noa_family_code		= met.noa_family_code
			AND ghrf.noa_family_code	= met.noa_family_code
			AND ghrf.update_hr_flag		= 'Y'
			AND met.process_method_code in ('AP', 'APUE')
			AND met.pa_data_field_id	= fld.pa_data_field_id
			AND fam.nature_of_action_id	= p_1st_noa_id
		UNION
			SELECT	fld2.form_field_name
			FROM
				ghr_families			ghrf2,
				ghr_noa_fam_proc_methods	met2,
				ghr_pa_data_fields		fld2,
				ghr_noa_families			fam2
			WHERE
				    fam2.noa_family_code	= met2.noa_family_code
				AND ghrf2.noa_family_code	= met2.noa_family_code
				AND ghrf2.update_hr_flag	= 'Y'
				AND met2.process_method_code in ('AP', 'APUE')
				AND met2.pa_data_field_id	= fld2.pa_data_field_id
				AND fam2.nature_of_action_id	= p_2nd_noa_id;

	CURSOR cur_flds1(	p_1st_noa_id number) IS
		SELECT	fld.form_field_name
		FROM
			ghr_families			ghrf,
			ghr_noa_fam_proc_methods	met,
			ghr_pa_data_fields		fld,
			ghr_noa_families			fam
		WHERE
			    fam.noa_family_code		= met.noa_family_code
			AND ghrf.noa_family_code	= met.noa_family_code
			AND ghrf.update_hr_flag		= 'Y'
			AND met.process_method_code in ('AP', 'APUE')
			AND met.pa_data_field_id	= fld.pa_data_field_id
			AND fam.nature_of_action_id	= p_1st_noa_id;

	CURSOR cur_pos_title1(	p_1st_noa_id number) IS
		SELECT	fld.form_field_name
		FROM
			ghr_families			ghrf,
			ghr_noa_fam_proc_methods	met,
			ghr_pa_data_fields		fld,
			ghr_noa_families			fam
		WHERE
			    fam.noa_family_code		= met.noa_family_code
			AND ghrf.noa_family_code	= met.noa_family_code
			AND ghrf.update_hr_flag		= 'Y'
			AND met.pa_data_field_id	= fld.pa_data_field_id
			AND met.process_method_code 	= 'UE'
			AND fld.form_field_name		= 'TO_POSITION_TITLE'
			AND fam.nature_of_action_id	= p_1st_noa_id;

	CURSOR cur_pos_title2(	p_1st_noa_id number, p_2nd_noa_id number ) IS
		SELECT	fld.form_field_name
		FROM
			ghr_families			ghrf,
			ghr_noa_fam_proc_methods	met,
			ghr_pa_data_fields		fld,
			ghr_noa_families			fam
		WHERE
			    fam.noa_family_code		= met.noa_family_code
			AND ghrf.noa_family_code	= met.noa_family_code
			AND ghrf.update_hr_flag		= 'Y'
			AND met.pa_data_field_id	= fld.pa_data_field_id
			AND met.process_method_code 	= 'UE'
			AND fld.form_field_name		= 'TO_POSITION_TITLE'
			AND (fam.nature_of_action_id	= p_1st_noa_id
				OR fam.nature_of_action_id	= p_2nd_noa_id);

	l_proc	varchar2(30):='initialize_fld_names_table';
	l_fld_names_tab   fld_names_typ;

   BEGIN
         l_fld_names_tab := p_fld_names_tab; --NOCOPY Changes
	hr_utility.set_location('Entering:'|| l_proc, 5);

	-- populate the local table with the form_field_names for this noa.
	if (p_2nd_noa_id is not null) then
	    hr_utility.set_location( l_proc || 'dual action', 7);
	      FOR curflds_rec in cur_flds2(p_1st_noa_id, p_2nd_noa_id) LOOP
	          l_column_count := l_column_count + 1;
	          p_fld_names_tab(l_column_count) := curflds_rec;
	      END LOOP;
		FOR cur_postitle_rec in cur_pos_title2(p_1st_noa_id,p_2nd_noa_id) LOOP
			l_column_count := l_column_count +1;
			p_fld_names_tab(l_column_count) := cur_postitle_rec;
		end LOOP;
	else
	    hr_utility.set_location( l_proc || 'single action', 9);
	      FOR curflds_rec in cur_flds1(p_1st_noa_id) LOOP
	          l_column_count := l_column_count + 1;
	          p_fld_names_tab(l_column_count) := curflds_rec;
	      END LOOP;
		FOR cur_postitle_rec in cur_pos_title1(p_1st_noa_id) LOOP
			l_column_count := l_column_count +1;
			p_fld_names_tab(l_column_count) := cur_postitle_rec;
		end LOOP;
	end if;
	hr_utility.set_location('Leaving:'|| l_proc, 10);

    EXCEPTION
      WHEN others THEN
     -- Reset IN OUT parameters and set OUT parameters

         p_fld_names_tab  :=l_fld_names_tab;

      hr_utility.set_location('Leaving  ' || l_proc,60);
     RAISE;
   END initialize_fld_names_table;

--
   PROCEDURE copy_to_new_rg	(p_field_name	IN VARCHAR2,
				 p_from_field	IN VARCHAR2,
				 p_to_field	IN OUT NOCOPY VARCHAR2) IS
   --
   -- copies the passed rg value to the new rg only if the field name is present
   -- in the temp table
   --
	l_proc	varchar2(30):='copy_to_new_rg';
	l_found	boolean:=false;
	l_to_field VARCHAR2(2000);

   BEGIN
	l_to_field := p_to_field; --NOCOPY Changes
 	hr_utility.set_location('Entering:'|| l_proc, 5);
      FOR l_count IN 1..l_column_count LOOP
          if p_field_name = l_fld_names_tab(l_count).form_field_name then
				l_found := TRUE;
				p_to_field := p_from_field; -- Sundar 2112935 Copying source to the target.
	      exit;
          end if;
      END LOOP;
	if not l_found then
		p_to_field := null;
	end if;

 	hr_utility.set_location('Leaving:'|| l_proc, 10);

   EXCEPTION
     WHEN others THEN
     -- Reset IN OUT parameters and set OUT parameters

         p_to_field  :=l_to_field;

      hr_utility.set_location('Leaving  ' || l_proc,60);
     RAISE;
   END copy_to_new_rg;

BEGIN
 	hr_utility.set_location('Entering:'|| l_proc, 5);
	hr_utility.set_location(' no. of rows in table rg ' || to_char(l_column_count), 11);
	-- get list of all columns needed for the noa we are correcting.
   	initialize_fld_names_table(	p_1st_noa_id  		=> p_first_noa_id,
					p_2nd_noa_id  		=> p_second_noa_id,
					p_fld_names_tab		=> l_fld_names_tab);

	l_pa_req := p_pa_req_in;
	-- for all columns, set to null if not needed for the noa we are processing

-- Lines whih are commented meanss that this column value must be passed irrespective
-- of if it has been defined in proc_methods or not.
-- LINES WITH --* means that this value was not fetched by refresh_pa_request
-- LINES WITH --** means that this column was fetched by refresh_pa_request and it is not a form
-- LINES WITH --? must be revisited. Not sure what to do with these.
-- field but it should always be copied.
--*	copy_to_new_rg('PA_REQUEST_ID',p_pa_req_in.pa_request_id,l_pa_req.pa_request_id);
--*	copy_to_new_rg('PA_NOTIFICATION_ID',p_pa_req_in.pa_notification_id,l_pa_req.pa_notification_id);
--*	copy_to_new_rg('NOA_FAMILY_CODE',p_pa_req_in.noa_family_code,l_pa_req.noa_family_code);
--*	copy_to_new_rg('ROUTING_GROUP_ID',p_pa_req_in.routing_group_id,l_pa_req.routing_group_id);
--*	copy_to_new_rg('PROPOSED_EFFECTIVE_ASAP_FLAG',p_pa_req_in.proposed_effective_asap_flag,l_pa_req.proposed_effective_asap_flag);
	copy_to_new_rg('ACADEMIC_DISCIPLINE',p_pa_req_in.academic_discipline,l_pa_req.academic_discipline);
--*	copy_to_new_rg('ADDITIONAL_INFO_PERSON_ID',p_pa_req_in.additional_info_person_id,l_pa_req.additional_info_person_id);
--*	copy_to_new_rg('ADDITIONAL_INFO_TEL_NUMBER',p_pa_req_in.additional_info_tel_number,l_pa_req.additional_info_tel_number);
	copy_to_new_rg('AGENCY_CODE',p_pa_req_in.agency_code,l_pa_req.agency_code);
--*	copy_to_new_rg('ALTERED_PA_REQUEST_ID',p_pa_req_in.altered_pa_request_id,l_pa_req.altered_pa_request_id);
	copy_to_new_rg('ANNUITANT_INDICATOR',p_pa_req_in.annuitant_indicator,l_pa_req.annuitant_indicator);
	copy_to_new_rg('ANNUITANT_INDICATOR_DESC',p_pa_req_in.annuitant_indicator_desc,l_pa_req.annuitant_indicator_desc);
	copy_to_new_rg('APPROPRIATION_CODE1',p_pa_req_in.appropriation_code1,l_pa_req.appropriation_code1);
	copy_to_new_rg('APPROPRIATION_CODE2',p_pa_req_in.appropriation_code2,l_pa_req.appropriation_code2);
--*	copy_to_new_rg('APPROVAL_DATE',p_pa_req_in.approval_date,l_pa_req.approval_date);
--*	copy_to_new_rg('APPROVING_OFFICIAL_WORK_TITLE',p_pa_req_in.approving_official_work_title,l_pa_req.approving_official_work_title);

--*	copy_to_new_rg('AUTHORIZED_BY_PERSON_ID',p_pa_req_in.authorized_by_person_id,l_pa_req.authorized_by_person_id);
--*	copy_to_new_rg('AUTHORIZED_BY_TITLE',p_pa_req_in.authorized_by_title,l_pa_req.authorized_by_title);
	copy_to_new_rg('AWARD_AMOUNT',p_pa_req_in.award_amount,l_pa_req.award_amount);
	copy_to_new_rg('AWARD_UOM',p_pa_req_in.award_uom,l_pa_req.award_uom);
	copy_to_new_rg('BARGAINING_UNIT_STATUS',p_pa_req_in.bargaining_unit_status,l_pa_req.bargaining_unit_status);
	copy_to_new_rg('CITIZENSHIP',p_pa_req_in.citizenship,l_pa_req.citizenship);
--	copy_to_new_rg('CONCURRENCE_DATE',p_pa_req_in.concurrence_date,l_pa_req.concurrence_date);
	copy_to_new_rg('DUTY_STATION_CODE',p_pa_req_in.duty_station_code,l_pa_req.duty_station_code);
	copy_to_new_rg('DUTY_STATION_DESC',p_pa_req_in.duty_station_desc,l_pa_req.duty_station_desc);
	-- Copied on the basis of DUTY_STATION_DESC
	copy_to_new_rg('DUTY_STATION_DESC',p_pa_req_in.duty_station_id,l_pa_req.duty_station_id);
	copy_to_new_rg('DUTY_STATION_DESC',p_pa_req_in.duty_station_location_id,l_pa_req.duty_station_location_id);
	copy_to_new_rg('EDUCATION_LEVEL',p_pa_req_in.education_level,l_pa_req.education_level);
--*	copy_to_new_rg('EFFECTIVE_DATE',p_pa_req_in.effective_date,l_pa_req.effective_date);
--**	copy_to_new_rg('EMPLOYEE_ASSIGNMENT_ID',p_pa_req_in.employee_assignment_id,l_pa_req.employee_assignment_id);
--	copy_to_new_rg('EMPLOYEE_DATE_OF_BIRTH',p_pa_req_in.employee_date_of_birth,l_pa_req.employee_date_of_birth);
--*	copy_to_new_rg('EMPLOYEE_DEPT_OR_AGENCY',p_pa_req_in.employee_dept_or_agency,l_pa_req.employee_dept_or_agency);
--	copy_to_new_rg('EMPLOYEE_FIRST_NAME',p_pa_req_in.employee_first_name,l_pa_req.employee_first_name);
--	copy_to_new_rg('EMPLOYEE_LAST_NAME',p_pa_req_in.employee_last_name,l_pa_req.employee_last_name);
--	copy_to_new_rg('EMPLOYEE_MIDDLE_NAMES',p_pa_req_in.employee_middle_names,l_pa_req.employee_middle_names);
--	copy_to_new_rg('EMPLOYEE_NATIONAL_IDENTIFIER',p_pa_req_in.employee_national_identifier,l_pa_req.employee_national_identifier);
	copy_to_new_rg('FEGLI',p_pa_req_in.fegli,l_pa_req.fegli);
	copy_to_new_rg('FEGLI_DESC',p_pa_req_in.fegli_desc,l_pa_req.fegli_desc);
	copy_to_new_rg('FLSA_CATEGORY',p_pa_req_in.flsa_category,l_pa_req.flsa_category);
-- Can modify the code to copy all the address lines if address_line1 is copied
	copy_to_new_rg('FORWARDING_ADDRESS_LINE1',p_pa_req_in.forwarding_address_line1,l_pa_req.forwarding_address_line1);
	copy_to_new_rg('FORWARDING_ADDRESS_LINE2',p_pa_req_in.forwarding_address_line2,l_pa_req.forwarding_address_line2);
	copy_to_new_rg('FORWARDING_ADDRESS_LINE3',p_pa_req_in.forwarding_address_line3,l_pa_req.forwarding_address_line3);

	copy_to_new_rg('FORWARDING_COUNTRY_SHORT_NAME',p_pa_req_in.forwarding_country,l_pa_req.forwarding_country);
	copy_to_new_rg('FORWARDING_COUNTRY_SHORT_NAME',p_pa_req_in.forwarding_country_short_name,l_pa_req.forwarding_country_short_name);
	copy_to_new_rg('FORWARDING_POSTAL_CODE',p_pa_req_in.forwarding_postal_code,l_pa_req.forwarding_postal_code);
	copy_to_new_rg('FORWARDING_REGION_2',p_pa_req_in.forwarding_region_2,l_pa_req.forwarding_region_2);
	copy_to_new_rg('FORWARDING_TOWN_OR_CITY',p_pa_req_in.forwarding_town_or_city,l_pa_req.forwarding_town_or_city);
	copy_to_new_rg('FROM_ADJ_BASIC_PAY',p_pa_req_in.from_adj_basic_pay,l_pa_req.from_adj_basic_pay);
	copy_to_new_rg('FROM_AGENCY_CODE',p_pa_req_in.from_agency_code,l_pa_req.from_agency_code);
	copy_to_new_rg('FROM_AGENCY_DESC',p_pa_req_in.from_agency_desc,l_pa_req.from_agency_desc);

	copy_to_new_rg('FROM_BASIC_PAY',p_pa_req_in.from_basic_pay,l_pa_req.from_basic_pay);
	copy_to_new_rg('FROM_GRADE_OR_LEVEL',p_pa_req_in.from_grade_or_level,l_pa_req.from_grade_or_level);
	copy_to_new_rg('FROM_LOCALITY_ADJ',p_pa_req_in.from_locality_adj,l_pa_req.from_locality_adj);
	copy_to_new_rg('FROM_OCC_CODE',p_pa_req_in.from_occ_code,l_pa_req.from_occ_code);
	copy_to_new_rg('FROM_OFFICE_SYMBOL',p_pa_req_in.from_office_symbol,l_pa_req.from_office_symbol);
	copy_to_new_rg('FROM_OTHER_PAY_AMOUNT',p_pa_req_in.from_other_pay_amount,l_pa_req.from_other_pay_amount);
	copy_to_new_rg('FROM_PAY_BASIS_DESC',p_pa_req_in.from_pay_basis,l_pa_req.from_pay_basis);
	copy_to_new_rg('FROM_PAY_PLAN',p_pa_req_in.from_pay_plan,l_pa_req.from_pay_plan);

	copy_to_new_rg('FROM_POSITION_TITLE',p_pa_req_in.from_position_title,l_pa_req.from_position_title);
	copy_to_new_rg('FROM_POSITION_TITLE',p_pa_req_in.from_position_id,l_pa_req.from_position_id);

	copy_to_new_rg('FROM_POSITION_ORG_LINE1',p_pa_req_in.from_position_org_line1,l_pa_req.from_position_org_line1);
	copy_to_new_rg('FROM_POSITION_ORG_LINE2',p_pa_req_in.from_position_org_line2,l_pa_req.from_position_org_line2);
	copy_to_new_rg('FROM_POSITION_ORG_LINE3',p_pa_req_in.from_position_org_line3,l_pa_req.from_position_org_line3);
	copy_to_new_rg('FROM_POSITION_ORG_LINE4',p_pa_req_in.from_position_org_line4,l_pa_req.from_position_org_line4);
	copy_to_new_rg('FROM_POSITION_ORG_LINE5',p_pa_req_in.from_position_org_line5,l_pa_req.from_position_org_line5);
	copy_to_new_rg('FROM_POSITION_ORG_LINE6',p_pa_req_in.from_position_org_line6,l_pa_req.from_position_org_line6);

	copy_to_new_rg('FROM_POSITION_NUMBER',p_pa_req_in.from_position_number,l_pa_req.from_position_number);
	copy_to_new_rg('FROM_POSITION_SEQ_NO',p_pa_req_in.from_position_seq_no,l_pa_req.from_position_seq_no);
	copy_to_new_rg('FROM_STEP_OR_RATE',p_pa_req_in.from_step_or_rate,l_pa_req.from_step_or_rate);
	copy_to_new_rg('FROM_TOTAL_SALARY',p_pa_req_in.from_total_salary,l_pa_req.from_total_salary);
	copy_to_new_rg('FUNCTIONAL_CLASS',p_pa_req_in.functional_class,l_pa_req.functional_class);
--*	copy_to_new_rg('NOTEPAD',p_pa_req_in.notepad,l_pa_req.notepad);
	copy_to_new_rg('PART_TIME_HOURS',p_pa_req_in.part_time_hours,l_pa_req.part_time_hours);
    copy_to_new_rg('PAY_RATE_DETERMINANT',p_pa_req_in.pay_rate_determinant,l_pa_req.pay_rate_determinant);
--*	copy_to_new_rg('PERSONNEL_OFFICE_ID',p_pa_req_in.personnel_office_id,l_pa_req.personnel_office_id);
--	copy_to_new_rg('PERSON_ID',p_pa_req_in.person_id,l_pa_req.person_id);
	copy_to_new_rg('POSITION_OCCUPIED',p_pa_req_in.position_occupied,l_pa_req.position_occupied);
	copy_to_new_rg('PROPOSED_EFFECTIVE_DATE',p_pa_req_in.proposed_effective_date,l_pa_req.proposed_effective_date);

--*	copy_to_new_rg('REQUESTED_BY_PERSON_ID',p_pa_req_in.requested_by_person_id,l_pa_req.requested_by_person_id);
--*	copy_to_new_rg('REQUESTED_BY_TITLE',p_pa_req_in.requested_by_title,l_pa_req.requested_by_title);
--*	copy_to_new_rg('REQUESTED_DATE',p_pa_req_in.requested_date,l_pa_req.requested_date);
--*	copy_to_new_rg('REQUESTING_OFFICE_REMARKS_DESC',p_pa_req_in.requesting_office_remarks_desc,l_pa_req.requesting_office_remarks_desc);
--*	copy_to_new_rg('REQUESTING_OFFICE_REMARKS_FLAG',p_pa_req_in.requesting_office_remarks_flag,l_pa_req.requesting_office_remarks_flag);
--*	copy_to_new_rg('REQUEST_NUMBER',p_pa_req_in.request_number,l_pa_req.request_number);
	copy_to_new_rg('RESIGN_AND_RETIRE_REASON_DESC',p_pa_req_in.resign_and_retire_reason_desc,l_pa_req.resign_and_retire_reason_desc);
	copy_to_new_rg('RETIREMENT_PLAN',p_pa_req_in.retirement_plan,l_pa_req.retirement_plan);
	copy_to_new_rg('RETIREMENT_PLAN_DESC',p_pa_req_in.retirement_plan_desc,l_pa_req.retirement_plan_desc);
	copy_to_new_rg('SERVICE_COMP_DATE',p_pa_req_in.service_comp_date,l_pa_req.service_comp_date);
	copy_to_new_rg('SUPERVISORY_STATUS',p_pa_req_in.supervisory_status,l_pa_req.supervisory_status);
	copy_to_new_rg('TENURE',p_pa_req_in.tenure,l_pa_req.tenure);
	copy_to_new_rg('TO_ADJ_BASIC_PAY',p_pa_req_in.to_adj_basic_pay,l_pa_req.to_adj_basic_pay);
	copy_to_new_rg('TO_BASIC_PAY',p_pa_req_in.to_basic_pay,l_pa_req.to_basic_pay);
	copy_to_new_rg('TO_LOCALITY_ADJ',p_pa_req_in.to_locality_adj,l_pa_req.to_locality_adj);

	copy_to_new_rg('TO_OCC_CODE',p_pa_req_in.to_occ_code,l_pa_req.to_occ_code);
	copy_to_new_rg('TO_OFFICE_SYMBOL',p_pa_req_in.to_office_symbol,l_pa_req.to_office_symbol);

--	copy_to_new_rg('TO_ORGANIZATION_NAME',p_pa_req_in.to_organization_id,l_pa_req.to_organization_id);
--	copy_to_new_rg('TO_POSITION_ORG_LINE1',p_pa_req_in.to_position_org_line1,l_pa_req.to_position_org_line1);
--	copy_to_new_rg('TO_POSITION_ORG_LINE2',p_pa_req_in.to_position_org_line2,l_pa_req.to_position_org_line2);
--	copy_to_new_rg('To_POSITION_ORG_LINE3',p_pa_req_in.to_position_org_line3,l_pa_req.to_position_org_line3);
--	copy_to_new_rg('To_POSITION_ORG_LINE4',p_pa_req_in.to_position_org_line4,l_pa_req.to_position_org_line4);
--	copy_to_new_rg('To_POSITION_ORG_LINE5',p_pa_req_in.to_position_org_line5,l_pa_req.to_position_org_line5);
--	copy_to_new_rg('To_POSITION_ORG_LINE6',p_pa_req_in.to_position_org_line6,l_pa_req.to_position_org_line6);

	copy_to_new_rg('TO_PAY_BASIS_DESC',p_pa_req_in.to_pay_basis,l_pa_req.to_pay_basis);

	copy_to_new_rg('TO_PAY_PLAN',p_pa_req_in.to_pay_plan,l_pa_req.to_pay_plan);
	/* if TO_POSITION_TITLE exists, then the following fields should be copied */
	copy_to_new_rg('TO_POSITION_TITLE',p_pa_req_in.to_position_title,l_pa_req.to_position_title);
	--
	-- Position_id is already been taken care of in refresh_pa_req.
	-- It must not be nullified even if it is 'UE'
	-- copy_to_new_rg('TO_POSITION_TITLE',p_pa_req_in.to_position_id,l_pa_req.to_position_id);
	copy_to_new_rg('TO_POSITION_TITLE',p_pa_req_in.to_grade_id,l_pa_req.to_grade_id);
	copy_to_new_rg('TO_POSITION_TITLE',p_pa_req_in.to_job_id,l_pa_req.to_job_id);
	copy_to_new_rg('TO_POSITION_TITLE',p_pa_req_in.to_organization_id,l_pa_req.to_organization_id);

	/* end of fields dependent on TO_POSITION_TITLE */

	copy_to_new_rg('TO_GRADE_OR_LEVEL',p_pa_req_in.to_grade_or_level,l_pa_req.to_grade_or_level);
	copy_to_new_rg('TO_POSITION_NUMBER',p_pa_req_in.to_position_number,l_pa_req.to_position_number);
	copy_to_new_rg('TO_POSITION_SEQ_NO',p_pa_req_in.to_position_seq_no,l_pa_req.to_position_seq_no);
	copy_to_new_rg('TO_STEP_OR_RATE',p_pa_req_in.to_step_or_rate,l_pa_req.to_step_or_rate);
	copy_to_new_rg('TO_TOTAL_SALARY',p_pa_req_in.to_total_salary,l_pa_req.to_total_salary);
	copy_to_new_rg('VETERANS_PREFERENCE',p_pa_req_in.veterans_preference,l_pa_req.veterans_preference);

	copy_to_new_rg('VETERANS_PREF_FOR_RIF_DESC',p_pa_req_in.veterans_pref_for_rif,l_pa_req.veterans_pref_for_rif);
	copy_to_new_rg('VETERANS_STATUS',p_pa_req_in.veterans_status,l_pa_req.veterans_status);
	copy_to_new_rg('WORK_SCHEDULE',p_pa_req_in.work_schedule,l_pa_req.work_schedule);
 	copy_to_new_rg('WORK_SCHEDULE_DESC',p_pa_req_in.work_schedule_desc,l_pa_req.work_schedule_desc);
	copy_to_new_rg('YEAR_DEGREE_ATTAINED',p_pa_req_in.year_degree_attained,l_pa_req.year_degree_attained);

/*	All of the follwing will be passed irrespective of NOA.

	copy_to_new_rg('ATTRIBUTE_CATEGORY',p_pa_req_in.attribute_category,l_pa_req.attribute_category);
	copy_to_new_rg('ATTRIBUTE1',p_pa_req_in.attribute1,l_pa_req.attribute1);
	copy_to_new_rg('ATTRIBUTE2',p_pa_req_in.attribute2,l_pa_req.attribute2);
	copy_to_new_rg('ATTRIBUTE3',p_pa_req_in.attribute3,l_pa_req.attribute3);
	copy_to_new_rg('ATTRIBUTE4',p_pa_req_in.attribute4,l_pa_req.attribute4);
	copy_to_new_rg('ATTRIBUTE5',p_pa_req_in.attribute5,l_pa_req.attribute5);
	copy_to_new_rg('ATTRIBUTE6',p_pa_req_in.attribute6,l_pa_req.attribute6);
	copy_to_new_rg('ATTRIBUTE7',p_pa_req_in.attribute7,l_pa_req.attribute7);
	copy_to_new_rg('ATTRIBUTE8',p_pa_req_in.attribute8,l_pa_req.attribute8);
	copy_to_new_rg('ATTRIBUTE9',p_pa_req_in.attribute9,l_pa_req.attribute9);
	copy_to_new_rg('ATTRIBUTE10',p_pa_req_in.attribute10,l_pa_req.attribute10);
	copy_to_new_rg('ATTRIBUTE11',p_pa_req_in.attribute11,l_pa_req.attribute11);
	copy_to_new_rg('ATTRIBUTE12',p_pa_req_in.attribute12,l_pa_req.attribute12);
	copy_to_new_rg('ATTRIBUTE13',p_pa_req_in.attribute13,l_pa_req.attribute13);
	copy_to_new_rg('ATTRIBUTE14',p_pa_req_in.attribute14,l_pa_req.attribute14);
	copy_to_new_rg('ATTRIBUTE15',p_pa_req_in.attribute15,l_pa_req.attribute15);
	copy_to_new_rg('ATTRIBUTE16',p_pa_req_in.attribute16,l_pa_req.attribute16);
	copy_to_new_rg('ATTRIBUTE17',p_pa_req_in.attribute17,l_pa_req.attribute17);
	copy_to_new_rg('ATTRIBUTE18',p_pa_req_in.attribute18,l_pa_req.attribute18);
	copy_to_new_rg('ATTRIBUTE19',p_pa_req_in.attribute19,l_pa_req.attribute19);
	copy_to_new_rg('ATTRIBUTE20',p_pa_req_in.attribute20,l_pa_req.attribute20);
*/
	-- all the following fields should be based on to_other_pay_amount
	copy_to_new_rg('TO_OTHER_PAY_AMOUNT',p_pa_req_in.to_other_pay_amount,l_pa_req.to_other_pay_amount);
	copy_to_new_rg('TO_OTHER_PAY_AMOUNT',p_pa_req_in.to_au_overtime,l_pa_req.to_au_overtime);
	copy_to_new_rg('TO_OTHER_PAY_AMOUNT',p_pa_req_in.to_auo_premium_pay_indicator,l_pa_req.to_auo_premium_pay_indicator);
	copy_to_new_rg('TO_OTHER_PAY_AMOUNT',p_pa_req_in.to_availability_pay,l_pa_req.to_availability_pay);
	copy_to_new_rg('TO_OTHER_PAY_AMOUNT',p_pa_req_in.to_ap_premium_pay_indicator,l_pa_req.to_ap_premium_pay_indicator);
	copy_to_new_rg('TO_OTHER_PAY_AMOUNT',p_pa_req_in.to_retention_allowance,l_pa_req.to_retention_allowance);
	copy_to_new_rg('TO_OTHER_PAY_AMOUNT',p_pa_req_in.to_retention_allow_percentage,l_pa_req.to_retention_allow_percentage);
	copy_to_new_rg('TO_OTHER_PAY_AMOUNT',p_pa_req_in.to_supervisory_differential,l_pa_req.to_supervisory_differential);
	copy_to_new_rg('TO_OTHER_PAY_AMOUNT',p_pa_req_in.to_supervisory_diff_percentage,l_pa_req.to_supervisory_diff_percentage);
	copy_to_new_rg('TO_OTHER_PAY_AMOUNT',p_pa_req_in.to_staffing_differential,l_pa_req.to_staffing_differential);
	copy_to_new_rg('TO_OTHER_PAY_AMOUNT',p_pa_req_in.to_staffing_diff_percentage,l_pa_req.to_staffing_diff_percentage);


--	copy_to_new_rg('CUSTOM_PAY_CALC_FLAG',p_pa_req_in.custom_pay_calc_flag,l_pa_req.custom_pay_calc_flag);
	p_pa_req_out := l_pa_req;

	hr_utility.set_location('Leaving:'|| l_proc, 15);

EXCEPTION
  WHEN others THEN
     -- Reset IN OUT parameters and set OUT parameters

       p_pa_req_out  :=NULL;

   hr_utility.set_location('Leaving  ' || l_proc,60);
   RAISE;

END get_par_ap_apue_fields;


-- ---------------------------------------------------------------------------
-- |--------------------------< derive_to_columns>----------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   	This procedure derives the to column values for the given ghr_pa_request
--	record. This is meant to be called for the first action in a dual action where
--	the first action is a WGI.
--
-- Pre-Requisities:
--   	None.
--
-- In Parameters:
--	p_sf52_data		in out	ghr_pa_request record to be populated with derived
--						to column values. Also contains input information for
--						the pa_request record.
--
-- Post Success:
-- 	The to values will have been derived from the from values in p_sf52_data. The results
--	will have been put into the corresponding to value columns in p_sf52_data.
--
-- Post Failure:
--   Exception will have been raised with error message explaining the problem.
--
-- Developer Implementation Notes:
--   None
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------

PROCEDURE derive_to_columns(p_sf52_data	in out	nocopy ghr_pa_requests%rowtype) IS

	l_proc	varchar2(30):='derive_to_columns';
	l_basic_pay        NUMBER;
	l_locality_adj     NUMBER;
	l_adj_basic_pay    NUMBER;
	l_total_salary     NUMBER;
	l_other_pay_amount NUMBER;
	l_au_overtime      NUMBER;
	l_availability_pay NUMBER;
	l_out_step_or_rate VARCHAR2(30);
	l_message_set      BOOLEAN;
	l_calculated       BOOLEAN;
	l_sf52_data	  ghr_pa_requests%rowtype;
	l_message          VARCHAR2(2000);
	l_out_pay_rate_determinant	NUMBER;
        l_out_to_grade_id   NUMBER;
        l_out_to_pay_plan   VARCHAR2(2);
        l_out_to_grade_or_level VARCHAR2(30);
	l_pt_eff_start_date DATE;

        l_open_pay_fields  BOOLEAN;
        l_open_basicpay_field  BOOLEAN;
	--Bug5132113
	l_open_localityadj_field BOOLEAN;
        --Bug5132113
        l_open_range_out_basic_pay NUMBER;
	l_open_out_locality_adj    NUMBER;

	-- FWFA Changes
	l_calc_pay_table_id NUMBER;
	l_pay_table_id      NUMBER;
	-- FWFA Changes

	l_to_ret_allowance NUMBER;
    l_ret_allow_perc_out NUMBER;
BEGIN
        l_sf52_data :=p_sf52_data ; --NOCOPY Changes

	hr_utility.set_location('Entering:'|| l_proc, 5);
	p_sf52_data.to_adj_basic_pay	:= p_sf52_data.from_adj_basic_pay;
	p_sf52_data.agency_code			:= p_sf52_data.from_agency_code;

    l_open_range_out_basic_pay      := p_sf52_data.to_basic_pay;
    l_open_out_locality_adj         := p_sf52_data.to_locality_adj;

	p_sf52_data.to_basic_pay		:= p_sf52_data.from_basic_pay;
	p_sf52_data.to_grade_or_level	:= p_sf52_data.from_grade_or_level;
	p_sf52_data.to_locality_adj		:= p_sf52_data.from_locality_adj;
	p_sf52_data.to_occ_code			:= p_sf52_data.from_occ_code;
	p_sf52_data.to_office_symbol	:= p_sf52_data.from_office_symbol;
	p_sf52_data.to_other_pay_amount	:= p_sf52_data.from_other_pay_amount;
	p_sf52_data.to_pay_basis		:= p_sf52_data.from_pay_basis;
	p_sf52_data.to_pay_plan			:= p_sf52_data.from_pay_plan;
	p_sf52_data.to_position_id		:= p_sf52_data.from_position_id;
	p_sf52_data.to_position_org_line1	:= p_sf52_data.from_position_org_line1;
	p_sf52_data.to_position_org_line2	:= p_sf52_data.from_position_org_line2;
	p_sf52_data.to_position_org_line3	:= p_sf52_data.from_position_org_line3;
	p_sf52_data.to_position_org_line4	:= p_sf52_data.from_position_org_line4;
	p_sf52_data.to_position_org_line5	:= p_sf52_data.from_position_org_line5;
	p_sf52_data.to_position_org_line6	:= p_sf52_data.from_position_org_line6;
	p_sf52_data.to_position_number	:= p_sf52_data.from_position_number;
	p_sf52_data.to_position_seq_no	:= p_sf52_data.from_position_seq_no;
	p_sf52_data.to_position_title		:= p_sf52_data.from_position_title;
	p_sf52_data.to_step_or_rate		:= p_sf52_data.from_step_or_rate;
	p_sf52_data.to_total_salary		:= p_sf52_data.from_total_salary;
	p_sf52_data.to_office_symbol		:= p_sf52_data.from_office_symbol;
	p_sf52_data.to_other_pay_amount	:= p_sf52_data.from_other_pay_amount;
	p_sf52_data.to_pay_basis		:= p_sf52_data.from_pay_basis;

	refresh_pa_request(
				p_person_id		=>	p_sf52_data.person_id,
				p_effective_date 	=>	p_sf52_data.effective_date,
				p_derive_to_cols	=>	TRUE,
				p_sf52_data		=>	l_sf52_data);

	p_sf52_data.to_organization_id		:= l_sf52_data.to_organization_id;
	p_sf52_data.to_job_id				:= l_sf52_data.to_job_id;
	p_sf52_data.to_grade_id				:= l_sf52_data.to_grade_id;
	p_sf52_data.to_supervisory_differential	:= l_sf52_data.to_supervisory_differential;
	p_sf52_data.to_supervisory_diff_percentage:= l_sf52_data.to_supervisory_diff_percentage;
	p_sf52_data.to_staffing_differential	:= l_sf52_data.to_staffing_differential;
	p_sf52_data.to_staffing_diff_percentage	:= l_sf52_data.to_staffing_diff_percentage;
	p_sf52_data.to_au_overtime			:= l_sf52_data.to_au_overtime;
	p_sf52_data.to_availability_pay		:= l_sf52_data.to_availability_pay;
	p_sf52_data.to_ap_premium_pay_indicator	:= l_sf52_data.to_ap_premium_pay_indicator;
	p_sf52_data.to_auo_premium_pay_indicator	:= l_sf52_data.to_auo_premium_pay_indicator;
	p_sf52_data.to_retention_allowance		:= l_sf52_data.to_retention_allowance;
	p_sf52_data.to_retention_allow_percentage	:= l_sf52_data.to_retention_allow_percentage;
	hr_utility.set_location(l_proc ||' to_organization_id: ' || p_sf52_data.to_organization_id, 12);
	hr_utility.set_location(l_proc ||' to_job_id: ' || p_sf52_data.to_job_id, 13);
	hr_utility.set_location(l_proc ||' to_grade_id: ' || p_sf52_data.to_grade_id, 14);
	hr_utility.set_location(l_proc ||' to_supervisory_differential: ' || p_sf52_data.to_supervisory_differential, 15);
	hr_utility.set_location(l_proc ||' to_staffing_differential: ' || p_sf52_data.to_staffing_differential, 16);
	hr_utility.set_location(l_proc ||' to_au_overtime: ' || p_sf52_data.to_au_overtime, 17);
	hr_utility.set_location(l_proc ||' to_availability_pay: ' || p_sf52_data.to_availability_pay, 18);
	hr_utility.set_location(l_proc ||' to_ap_premium_pay_indicator: ' || p_sf52_data.to_ap_premium_pay_indicator, 19);
	hr_utility.set_location(l_proc ||' to_auo_premium_pay_indicator: ' || p_sf52_data.to_auo_premium_pay_indicator, 21);
	hr_utility.set_location(l_proc ||' to_retention_allowance: ' || p_sf52_data.to_retention_allowance, 22);

		ghr_pay_calc.main_pay_calc    (
            p_person_id        => p_sf52_data.person_id
           ,p_position_id      => p_sf52_data.to_position_id
           ,p_noa_family_code  => p_sf52_data.noa_family_code
           ,p_noa_code         => p_sf52_data.first_noa_code
           ,p_second_noa_code  => null
           ,p_first_action_la_code1 => p_sf52_data.first_action_la_code1
           ,p_effective_date   => p_sf52_data.effective_date
	       -- FWFA Changes Bug#4444609 Modified the passed PRD parameter with input_pay_rate_determinant.
           ,p_pay_rate_determinant => NVL(p_sf52_data.input_pay_rate_determinant,NVL(p_sf52_data.pay_rate_determinant,'0'))
	       -- FWFA Changes
	       ,p_pay_plan         => p_sf52_data.to_pay_plan
           ,p_grade_or_level   => p_sf52_data.to_grade_or_level
           ,p_step_or_rate     => p_sf52_data.to_step_or_rate
           ,p_pay_basis        => p_sf52_data.to_pay_basis
           ,p_user_table_id    => null
           ,p_duty_station_id  => p_sf52_data.duty_station_id
           ,p_auo_premium_pay_indicator => p_sf52_data.to_auo_premium_pay_indicator
           ,p_ap_premium_pay_indicator  => p_sf52_data.to_ap_premium_pay_indicator
           ,p_retention_allowance       => p_sf52_data.to_retention_allowance
           ,p_to_ret_allow_percentage   => p_sf52_data.to_retention_allow_percentage
           ,p_supervisory_differential  => p_sf52_data.to_supervisory_differential
           ,p_staffing_differential     => p_sf52_data.to_staffing_differential
           ,p_current_basic_pay         => p_sf52_data.from_basic_pay
           ,p_current_adj_basic_pay     => p_sf52_data.from_adj_basic_pay
           ,p_current_step_or_rate      => p_sf52_data.from_step_or_rate
           ,p_pa_request_id    => p_sf52_data.pa_request_id
           ,p_open_range_out_basic_pay  => l_open_range_out_basic_pay
	   ,p_open_out_locality_adj     => l_open_out_locality_adj
           ,p_basic_pay        => l_basic_pay
           ,p_locality_adj     => l_locality_adj
           ,p_adj_basic_pay    => l_adj_basic_pay
           ,p_total_salary     => l_total_salary
           ,p_other_pay_amount => l_other_pay_amount
           ,p_to_retention_allowance => l_to_ret_allowance
           ,p_ret_allow_perc_out => l_ret_allow_perc_out
           ,p_au_overtime      => l_au_overtime
           ,p_availability_pay => l_availability_pay
            -- FWFA Changes
            ,p_calc_pay_table_id => l_calc_pay_table_id
            ,p_pay_table_id	  => l_pay_table_id
            -- FWFA Changes
           ,p_out_step_or_rate => l_out_step_or_rate
           ,p_out_pay_rate_determinant => l_out_pay_rate_determinant
           ,p_out_to_grade_id          => l_out_to_grade_id
           ,p_out_to_pay_plan          => l_out_to_pay_plan
           ,p_out_to_grade_or_level    => l_out_to_grade_or_level
           ,p_pt_eff_start_date        => l_pt_eff_start_date
           ,p_open_basicpay_field  => l_open_basicpay_field
           ,p_open_pay_fields  => l_open_pay_fields
           ,p_message_set      => l_message_set
           ,p_calculated       => l_calculated
	   ,p_open_localityadj_field => l_open_localityadj_field
          );

		-- Check if we had any warning messages
		-- Calculation not done.
		IF l_message_set THEN
			hr_utility.set_location( l_proc, 80);
			hr_utility.set_message( 8301, 'GHR_38416_PC_FAILED');
			hr_utility.raise_error;
		END IF;

		IF l_calculated THEN
			hr_utility.set_location( l_proc, 50);
			-- FWFA Changes Bug#4444609
			p_sf52_data.pay_rate_determinant := NVL(l_out_pay_rate_determinant,p_sf52_data.input_pay_rate_determinant);
			p_sf52_data.to_pay_table_identifier := l_calc_pay_table_id;
			-- FWFA Changes
			p_sf52_data.to_basic_pay     := l_basic_pay;
			p_sf52_data.to_locality_adj  := l_locality_adj;
			p_sf52_data.to_adj_basic_pay := l_adj_basic_pay;
			p_sf52_data.to_total_salary  := l_total_salary;

			-- don't bother with other pay stuff since this never gets used for dual actions where
			-- WGI is the first action (that is the only time this procedure will have been called).
			/*
			-- Be careful with setting 'other' pay if it is 'NE'
			IF get_other_pay_amount_pm <> 'NE' THEN
				-- Populate these values if required
				hr_utility.set_location( l_proc, 60);
				p_sf52_data.to_other_pay_amount := l_other_pay_amount;
				p_sf52_data.to_au_overtime  := l_au_overtime;
				p_sf52_data.to_au_overtime  := l_au_overtime;
			END IF;
			*/
			IF l_out_step_or_rate IS NOT NULL THEN
				hr_utility.set_location( l_proc, 70);
				p_sf52_data.to_step_or_rate := l_out_step_or_rate;
			END IF;
			-- should this check be here?? This is not the same as the future action case
			-- where the pay calc is being run for the second time.
/*
			IF p_sf52_data.duty_station_id IS NULL      or
                     p_sf52_data.pay_rate_determinant IS NULL then
				-- GHR_99999_MANDT_COLM_NULL
				-- this must never be the case as this SF52 must have been
				-- validated at the time future action was saved.
				-- raise error
				hr_utility.set_location( l_proc, 80);
				hr_utility.set_message( 8301, 'GHR_99999_MANDT_COLM_NULL');
				hr_utility.raise_error;
				null;
			END IF;
*/
		ELSE
			-- GHR_99999_PC_FAILED
			-- ie  Pay calc failed
			-- raise error. As values can not be entered interactively
			hr_utility.set_location( l_proc, 100);
			hr_utility.set_message( 8301, 'GHR_38416_PC_FAILED');
			hr_utility.raise_error;
			null;
		END IF;

EXCEPTION
  WHEN others THEN
     -- Reset IN OUT parameters and set OUT parameters

        p_sf52_data := l_sf52_data ;

   hr_utility.set_location('Leaving  ' || l_proc,60);
   RAISE;

end derive_to_columns;

-- This procedure can be used for refresh before update to database and for correction.
--
Procedure refresh_req_shadow (
	p_sf52_data	    in out nocopy ghr_pa_requests%rowtype,
	p_shadow_data       out nocopy ghr_pa_request_shadow%rowtype,
	p_process_type	in	varchar2 default 'CURRENT'
	) is

	l_sf52_shadow	      ghr_pa_requests%rowtype;
	l_shadow_data		ghr_pa_request_shadow%rowtype;
	l_sf52_refresh_data	ghr_pa_requests%rowtype;
	l_changed			boolean := FALSE;
	l_proc			varchar2(30):='refresh_req_shadow';
        l_bef_basic_pay        number;
        l_retention_allowance   number;
        l_ret_calc_perc         number;
        l_supervisory_differential number;
        l_staffing_differential number;
        l_multi_error_flag    boolean;
        l_capped_other_pay  number;
	l_sf52_data   ghr_pa_requests%rowtype;

	cursor c_sf52_shadow (c_pa_request_id in number) is
	select *
	from ghr_pa_request_shadow
	where pa_request_id = c_pa_request_id ;

	-- Sundar 2112935 Added the variables below for Output
	l_sf52_out_shadow ghr_pa_requests%rowtype;
	l_sf52_refresh_out_data	ghr_pa_requests%rowtype;
Begin
        l_sf52_data := p_sf52_data ;--NOCOPY Changes

	print_sf52('Initial Data: ', p_sf52_data);

	-- fetch Shadow sf52 of original/root SF52;
	hr_utility.set_location('Entering ' || l_proc, 100);
	open c_sf52_shadow (p_sf52_data.pa_request_id);
	fetch c_sf52_shadow into l_shadow_data;
	if c_sf52_shadow%notfound then
		hr_utility.set_location(' Error, Shadow not found ' || l_proc, 101);
		close c_sf52_shadow;
	      hr_utility.set_message(8301,'GHR_38417_SHADOW_SF52_NOTFOUND');
	      hr_utility.raise_error;
	else
		close c_sf52_shadow ;
	end if;
	-- convert shadow rg to SF52 format
	hr_utility.set_location('Call Convert_shadoe_to_sf52 ' || l_proc, 110);
	ghr_history_conv_rg.convert_shadow_to_sf52 (
		p_shadow	 => l_shadow_data,
		p_sf52	 => l_sf52_shadow);

	print_sf52('shadow record before get_par: ', l_sf52_shadow);
	get_par_ap_apue_fields(	p_pa_req_in		=>	l_sf52_shadow,
					p_first_noa_id	=>	p_sf52_data.first_noa_id,
					p_second_noa_id	=>	p_sf52_data.second_noa_id,
					p_pa_req_out	=>	l_sf52_out_shadow); -- Sundar 2112935
	l_sf52_shadow := l_sf52_out_shadow;
	-- Sundar 2112935. Seperate variable added for out parameter above as
    -- it was not retrieving the value properly if original is passed.

	l_sf52_refresh_data.pa_request_id		:= p_sf52_data.pa_request_id;
	l_sf52_refresh_data.from_position_id	:= p_sf52_data.from_position_id;
	l_sf52_refresh_data.from_position_title	:= p_sf52_data.from_position_title;
	l_sf52_refresh_data.to_position_id		:= p_sf52_data.to_position_id;
	l_sf52_refresh_data.effective_date		:= p_sf52_data.effective_date;
	l_sf52_refresh_data.employee_assignment_id := p_sf52_data.employee_assignment_id;
	l_sf52_refresh_data.first_noa_code		:= p_sf52_data.first_noa_code;
	l_sf52_refresh_data.second_noa_code		:= p_sf52_data.second_noa_code;
    --6850492 added 713 to compare for dual actions as 713 can be performed as a second action
    IF p_sf52_data.first_noa_code = '713' or p_sf52_data.second_noa_code = '713' THEN
	  l_sf52_refresh_data.to_grade_id		:= p_sf52_data.to_grade_id;
	  l_sf52_refresh_data.to_grade_or_level		:= p_sf52_data.to_grade_or_level;
	  l_sf52_refresh_data.to_pay_plan		:= p_sf52_data.to_pay_plan;
    END IF;

-- vsm
	hr_utility.set_location(l_proc, 120);
        -- Start Bug 1310894
    l_bef_basic_pay := p_sf52_data.from_basic_pay;
	hr_utility.set_location('l_bef_basic_pay is '||l_bef_basic_pay, 135);
        -- End Bug 1310894

	refresh_pa_request
		(p_person_id	       => p_sf52_data.person_id,
		 p_effective_date	       => p_sf52_data.effective_date,
		 p_sf52_data	       => l_sf52_refresh_data);
	hr_utility.set_location(l_proc, 130);
	print_sf52('refresh record before get_par: ', l_sf52_refresh_data);

	-- Call procedure to nullify NE/UE columns.
	get_par_ap_apue_fields(	p_pa_req_in		=>	l_sf52_refresh_data,
					p_first_noa_id	=>	p_sf52_data.first_noa_id,
					p_second_noa_id	=>	p_sf52_data.second_noa_id,
					p_pa_req_out	=>	l_sf52_refresh_out_data);
    l_sf52_refresh_data := l_sf52_refresh_out_data;
	-- Sundar 2112935. Seperate variable added for out parameter above as
    -- it was not retrieving the value properly if original is passed.

	print_sf52('refresh record after get_par: ', l_sf52_refresh_data);

	-- Cascade AP and APUE fields not changed by the user.
	-- l_sf52_refresh will have the result which should be processed
	print_sf52('sf52 record before cascade: ', p_sf52_data);
	print_sf52('shadow record before cascade: ', l_sf52_shadow);
	print_sf52('refresh record before cascade: ', l_sf52_refresh_data);

	ghr_history_cascade.cascade_pa_req(
		p_rfrsh_rec	      => l_sf52_refresh_data,
		p_shadow_rec      => l_sf52_shadow,
		p_sf52_rec		=> p_sf52_data,
		p_changed		=> l_changed);
	if (l_changed) then
		hr_utility.set_location('REFRESH CHANGED SF52.' , 11999);
	end if;
	if (l_changed and p_process_type = 'FUTURE') then
		raise e_refresh;
	end if;
    -- Bug#4709111 Reverted the fix done for 4680047. Commented the following code.
    -- Bug#4680047
/*    IF p_sf52_data.input_pay_rate_determinant <> l_sf52_refresh_data.pay_rate_determinant THEN
       hr_utility.set_location('FWFA RPA Input PRD: '||p_sf52_data.input_pay_rate_determinant,12000);
       hr_utility.set_location('FWFA Refresh  PRD: '||l_sf52_refresh_data.pay_rate_determinant,13000);
       p_sf52_data.input_pay_rate_determinant := l_sf52_refresh_data.pay_rate_determinant;
       p_sf52_data.pay_rate_determinant := l_sf52_refresh_data.pay_rate_determinant;
    END IF; */
	print_sf52('sf52 record after cascade: ', p_sf52_data);
	print_sf52('shadow record after cascade: ', l_sf52_shadow);
	print_sf52('refresh record after cascade: ', l_sf52_refresh_data);
	hr_utility.set_location(l_proc, 150);
        -- Bug 3704438 - PTH Issue - Start
        IF p_sf52_data.work_schedule in ('F', 'G', 'B', 'I', 'J')
         and p_sf52_data.part_time_hours is not null then
          p_sf52_data.part_time_hours  := null;
        END IF;
        -- Bug 3704438 - PTH Issue - End
          --Calculating Other Pay Components
           --Get the retention allowance on that date
          ghr_api.retrieve_element_entry_value (p_element_name    => 'Retention Allowance'
                               ,p_input_value_name      => 'Amount'
                               ,p_assignment_id         => p_sf52_data.employee_assignment_id
                               ,p_effective_date        => p_sf52_data.effective_date
                               ,p_value                 => l_retention_allowance
                               ,p_multiple_error_flag   => l_multi_error_flag);
          hr_utility.set_location('Retention Allowance on Eff Date'||l_retention_allowance, 164);
          ghr_api.retrieve_element_entry_value (p_element_name    => 'Supervisory Differential'
                               ,p_input_value_name      => 'Amount'
                               ,p_assignment_id         => p_sf52_data.employee_assignment_id
                               ,p_effective_date        => p_sf52_data.effective_date
                               ,p_value                 => l_supervisory_differential
                               ,p_multiple_error_flag   => l_multi_error_flag);
          hr_utility.set_location('Supervisory Differential on Eff Date'||l_supervisory_differential, 165);
          ghr_api.retrieve_element_entry_value (p_element_name    => 'Staffing Differential'
                               ,p_input_value_name      => 'Amount'
                               ,p_assignment_id         => p_sf52_data.employee_assignment_id
                               ,p_effective_date        => p_sf52_data.effective_date
                               ,p_value                 => l_staffing_differential
                               ,p_multiple_error_flag   => l_multi_error_flag);
          hr_utility.set_location('Staffing Differential on Eff Date'||l_staffing_differential, 166);

          -- Start Bug 2633367
          IF p_sf52_data.first_noa_code in ('810') THEN
	    hr_utility.set_location('l_bef_basic_pay is '||l_bef_basic_pay, 160);
	    hr_utility.set_location('to_basic_pay is '||p_sf52_data.to_basic_pay, 161);
	    hr_utility.set_location('from_basic_pay is '||p_sf52_data.from_basic_pay, 162);
            IF nvl(p_sf52_data.from_basic_pay,0) <> nvl(l_bef_basic_pay,0) then
              IF p_sf52_data.to_retention_allow_percentage is not null then

   -- Changed For FWS
                  IF p_sf52_data.to_pay_basis = 'PH' THEN
   		     p_sf52_data.to_retention_allowance :=
                            TRUNC(p_sf52_data.to_basic_pay * p_sf52_data.to_retention_allow_percentage/100,2);
                  ELSE
		       p_sf52_data.to_retention_allowance :=
        		       TRUNC(p_sf52_data.to_basic_pay * p_sf52_data.to_retention_allow_percentage/100,0);
                  END IF;
                   l_sf52_shadow.to_retention_allowance := p_sf52_data.to_retention_allowance;
              END IF;
              IF p_sf52_data.to_supervisory_diff_percentage is not null then
	            p_sf52_data.to_supervisory_differential :=
		            ROUND(ghr_pay_calc.convert_amount(p_sf52_data.to_basic_pay,
			                                      p_sf52_data.to_pay_basis,'PA')
                                                               * p_sf52_data.to_supervisory_diff_percentage/100,0);
		   l_sf52_shadow.to_supervisory_differential := p_sf52_data.to_supervisory_differential;
              END IF;
            END IF;
          ELSE
            IF l_retention_allowance is NULL then
              p_sf52_data.to_retention_allowance          :=  NULL;
              p_sf52_data.to_retention_allow_percentage   :=  NULL;
              l_sf52_shadow.to_retention_allowance        :=  NULL;
              l_sf52_shadow.to_retention_allow_percentage :=  NULL;
            END IF;
            IF l_supervisory_differential is NULL then
              p_sf52_data.to_supervisory_differential     :=  NULL;
              l_sf52_shadow.to_supervisory_differential   :=  NULL;
              p_sf52_data.to_supervisory_diff_percentage  :=  NULL;
              l_sf52_shadow.to_supervisory_diff_percentage  :=  NULL;
            END IF;
            IF l_staffing_differential is NULL then
              p_sf52_data.to_staffing_differential      := NULL;
              l_sf52_shadow.to_staffing_differential    := NULL;
              p_sf52_data.to_staffing_diff_percentage   := NULL;
              l_sf52_shadow.to_staffing_diff_percentage := NULL;
            END IF;
          END IF;
          p_sf52_data.to_other_pay_amount := nvl(p_sf52_data.to_au_overtime,0) +
                                               nvl(p_sf52_data.to_availability_pay,0) +
                                               nvl(p_sf52_data.to_retention_allowance,0) +
                                               nvl(p_sf52_data.to_supervisory_differential,0) +
                                               nvl(p_sf52_data.to_staffing_differential,0);
          hr_utility.set_location('Recalculated Other Pay is '||p_sf52_data.to_other_pay_amount, 166);
          if p_sf52_data.to_other_pay_amount = 0 then
                p_sf52_data.to_other_pay_amount := null;
          end if;
          -- End Bug 2633367

        -- Start Bug 1457792
/* Commenting this portion of code because recalculation of
retention allowance included in ghr_pay_calc.main_pay_calc
        if nvl(p_sf52_data.from_basic_pay,0) <> nvl(p_sf52_data.to_basic_pay,0) and
          p_sf52_data.first_noa_code not in ('810','818','819') then
	  hr_utility.set_location('Change in Basic Pay and Non Other Pay Action', 163);
          --Get the retention allowance and supervisory differential on that date
          ghr_api.retrieve_element_entry_value (p_element_name    => 'Retention Allowance'
                               ,p_input_value_name      => 'Amount'
                               ,p_assignment_id         => p_sf52_data.employee_assignment_id
                               ,p_effective_date        => p_sf52_data.effective_date
                               ,p_value                 => l_retention_allowance
                               ,p_multiple_error_flag   => l_multi_error_flag);
	  hr_utility.set_location('Retention Allowance on Eff Date'||l_retention_allowance, 164);
          ghr_api.retrieve_element_entry_value (p_element_name    => 'Supervisory Differential'
                               ,p_input_value_name      => 'Amount'
                               ,p_assignment_id         => p_sf52_data.employee_assignment_id
                               ,p_effective_date        => p_sf52_data.effective_date
                               ,p_value                 => l_supervisory_differential
                               ,p_multiple_error_flag   => l_multi_error_flag);
	  hr_utility.set_location('Supervisory Differential on Eff Date'||l_supervisory_differential, 165);
          if l_retention_allowance is null  then
            p_sf52_data.to_retention_allowance := null;
            p_sf52_data.to_other_pay_amount := nvl(p_sf52_data.to_au_overtime,0) +
                                               nvl(p_sf52_data.to_availability_pay,0) +
                                               nvl(p_sf52_data.to_retention_allowance,0) +
                                               nvl(p_sf52_data.to_supervisory_differential,0) +
                                               nvl(p_sf52_data.to_staffing_differential,0);
	    hr_utility.set_location('Recalculated Other Pay is '||p_sf52_data.to_other_pay_amount, 166);
          end if;
          if l_supervisory_differential is null  then
            p_sf52_data.to_supervisory_differential := null;
            p_sf52_data.to_other_pay_amount := nvl(p_sf52_data.to_au_overtime,0) +
                                               nvl(p_sf52_data.to_availability_pay,0) +
                                               nvl(p_sf52_data.to_retention_allowance,0) +
                                               nvl(p_sf52_data.to_supervisory_differential,0) +
                                               nvl(p_sf52_data.to_staffing_differential,0);
            hr_utility.set_location('Recalculated Other Pay is '||p_sf52_data.to_other_pay_amount, 167);
          end if;
          if p_sf52_data.to_other_pay_amount = 0 then
            p_sf52_data.to_other_pay_amount := null;
          end if;
        end if;
*/
        -- End Bug 1457792
	-- Redo Pay Calc
	-- Bug#3228557 Don't process redo_pay_calc for NPA Report

	IF NVL(p_process_type,hr_api.g_varchar2) <> 'NPA' THEN
	   redo_Pay_calc ( p_sf52_rec => p_sf52_data,
                        p_capped_other_pay => l_capped_other_pay);
	END IF;

	hr_utility.set_location(l_proc, 170);
	ghr_history_conv_rg.convert_sf52_to_shadow (
		p_shadow	 => p_shadow_data,
		p_sf52	 => l_sf52_shadow);

	hr_utility.set_location('Leaving : ' || l_proc, 180);

EXCEPTION
  WHEN others THEN
     -- Reset IN OUT parameters and set OUT parameters

        p_sf52_data := l_sf52_data ;
	p_shadow_data :=NULL ;

   hr_utility.set_location('Leaving  ' || l_proc,160);
   RAISE;

End refresh_req_shadow ;


Procedure Redo_Pay_calc ( p_sf52_rec	in out	nocopy ghr_pa_requests%rowtype,
                          p_capped_other_pay in out nocopy number ) is

	l_pay_calc_in_rec	ghr_pay_calc.pay_calc_in_rec_type;
	l_pay_calc_out_rec	ghr_pay_calc.pay_calc_out_rec_type;
	l_message_set		BOOLEAN;
	l_calculated		BOOLEAN;
	l_proc			varchar2(30):='Redo Pay Calc';
        l_open_pay_fields_caps  BOOLEAN;
        l_message_set_caps      BOOLEAN;
        l_entitled_other_pay    number;
        l_total_pc              number;

        l_adj_basic_message     BOOLEAN;
        l_pay_cap_message       BOOLEAN;
        l_temp_retention_allowance NUMBER;
	l_session_var	ghr_history_api.g_session_var_type;
        l_multi_error_flag    boolean;
	l_sf52_rec    ghr_pa_requests%rowtype;
	l_capped_other_pay   Number;

	--Pradeep for Bug 3306515
	l_temp_ret_allo_percentage NUMBER;

Begin
	l_capped_other_pay := p_capped_other_pay; --NOCOPY Changes
	l_sf52_rec         := p_sf52_rec ;

	hr_utility.set_location( 'Entering : ' || l_proc,10);

	print_sf52('Before redo_pay : ' , p_sf52_rec);

	 If nvl(p_sf52_rec.noa_family_code,hr_api.g_varchar2)
	   in ('APP', 'CHG_DUTY_STATION', 'CONV_APP', 'POS_CHG',
 	       'REASSIGNMENT') or
		(nvl(p_sf52_rec.noa_family_code,hr_api.g_varchar2) like 'GHR_SAL%')
	 then
	     -- and (p_sf52_rec.first_noa_code <> '899') and
             -- not (p_sf52_rec.first_noa_code = '002' and
             --	p_sf52_rec.second_noa_code = '899')
            hr_utility.set_location('Valid Family ' || l_proc, 11);
            If nvl(p_sf52_rec.custom_pay_calc_flag,hr_api.g_varchar2) <> 'Y' then
                hr_utility.set_location('Custom Pay Calc is NOT Y ' || l_proc, 12);
        	hr_utility.set_location('Input PRD : '||p_sf52_rec.input_pay_rate_determinant, 14);
        	hr_utility.set_location('PRD : '||p_sf52_rec.pay_rate_determinant, 14);
		l_pay_calc_in_rec.pa_request_id                 :=  p_sf52_rec.pa_request_id;
		l_pay_calc_in_rec.person_id           	      :=  p_sf52_rec.person_id;
		l_pay_calc_in_rec.position_id          		:=  p_sf52_rec.to_position_id;
		l_pay_calc_in_rec.noa_family_code      		:=  p_sf52_rec.noa_family_code;
		l_pay_calc_in_rec.noa_code                      :=  p_sf52_rec.first_noa_code;
		l_pay_calc_in_rec.second_noa_code      		:=  p_sf52_rec.second_noa_code;
		l_pay_calc_in_rec.first_action_la_code1         :=  p_sf52_rec.first_action_la_code1;
		l_pay_calc_in_rec.effective_date       		:=  p_sf52_rec.effective_date;
        -- FWFA Changes Bug#4444609 Modified the passed parameter as input_pay_rate_determinant.
		l_pay_calc_in_rec.pay_rate_determinant 		:=  NVL(p_sf52_rec.input_pay_rate_determinant,
                                                            p_sf52_rec.pay_rate_determinant);
        -- FWFA Changes
		l_pay_calc_in_rec.pay_plan             		:=  p_sf52_rec.to_pay_plan;
		l_pay_calc_in_rec.grade_or_level       		:=  p_sf52_rec.to_grade_or_level;
		l_pay_calc_in_rec.step_or_rate         		:=  p_sf52_rec.to_step_or_rate;
		l_pay_calc_in_rec.pay_basis           	 	:=  p_sf52_rec.to_pay_basis;
		l_pay_calc_in_rec.user_table_id        		:=  NULL;
		l_pay_calc_in_rec.duty_station_id      	   	:=  p_sf52_rec.duty_station_id;
		l_pay_calc_in_rec.auo_premium_pay_indicator 	:=  p_sf52_rec.to_auo_premium_pay_indicator;
		l_pay_calc_in_rec.ap_premium_pay_indicator      :=  p_sf52_rec.to_ap_premium_pay_indicator;

		--Open Pay Range Basic Pay assigning to in basic.
			if ghr_pay_calc.get_open_pay_range ( p_sf52_rec.to_position_id
								  , p_sf52_rec.person_id
								  , p_sf52_rec.pay_rate_determinant
								  , p_sf52_rec.pa_request_id
								  , NVL(p_sf52_rec.effective_date,TRUNC(sysdate)) ) then
			   if p_sf52_rec.to_basic_pay is not null then
				  l_pay_calc_in_rec.open_range_out_basic_pay := p_sf52_rec.to_basic_pay;
			   end if;
			end if;
		--Open Pay Range Code end.

		--Bug#5132113
		  l_pay_calc_in_rec.open_out_locality_adj := p_sf52_rec.to_locality_adj;
		--Bug#5132113

		-- Changes for RA re-calc using ghr_pay_calc
		-- Bug 2633367
		-- Here the sql_main_pay_calc wants the retention allowance in the DB
		-- Since redo_pay_calc will be called number of times during the Update HR
		-- and we can not use the p_sf52_rec.retention_allowance  as this value
		-- might be a re-computed value in the earlier call to sql_main_pay_calc
		--  That's why we are fetching the retention_allowance from DB
                IF p_sf52_rec.employee_assignment_id is not null and
                   p_sf52_rec.effective_date is not null
				   THEN
						-- Bug 4689374 - If FWFA then, dont take from element entry.
						IF p_sf52_rec.noa_family_code like 'GHR_SAL%' AND
							p_sf52_rec.pay_rate_determinant IN ('3','4','J','K','U','V') AND
							p_sf52_rec.effective_date >= to_date('01/05/2005','dd/mm/yyyy') THEN
								l_pay_calc_in_rec.retention_allowance :=  p_sf52_rec.to_retention_allowance;
								hr_utility.set_location('setting retention - fwfa ' || p_sf52_rec.to_retention_allowance,120);
						ELSE
							ghr_api.retrieve_element_entry_value
								   (p_element_name          => 'Retention Allowance'
								   ,p_input_value_name      => 'Amount'
								   ,p_assignment_id         => p_sf52_rec.employee_assignment_id
								   ,p_effective_date        => p_sf52_rec.effective_date
								   ,p_value                 => l_pay_calc_in_rec.retention_allowance
								   ,p_multiple_error_flag   => l_multi_error_flag);
						END IF;-- IF p_sf52_rec.noa_family_code like 'GHR_S
						-- End Bug 4689374
                ELSE
	                l_pay_calc_in_rec.retention_allowance           :=  p_sf52_rec.to_retention_allowance;
                END IF;
                --  Start 2588150
                l_pay_calc_in_rec.to_ret_allow_percentage       :=  p_sf52_rec.to_retention_allow_percentage;
                --  End 2588150
				l_pay_calc_in_rec.supervisory_differential   	:=  p_sf52_rec.to_supervisory_differential;
				l_pay_calc_in_rec.staffing_differential  	:=  p_sf52_rec.to_staffing_differential;
				l_pay_calc_in_rec.current_basic_pay  		:=  p_sf52_rec.from_basic_pay;
				l_pay_calc_in_rec.current_adj_basic_pay   	:=  p_sf52_rec.from_adj_basic_pay;
				l_pay_calc_in_rec.current_step_or_rate          :=  p_sf52_rec.from_step_or_rate;

						hr_utility.set_location('Before Main Pay Calc  ' || l_proc, 13);
				hr_utility.set_location('Pay Calc In PRD : '||l_pay_calc_in_rec.pay_rate_determinant, 14);

				ghr_pay_calc.sql_main_pay_calc
				( p_pay_calc_data        =>  l_pay_calc_in_rec,
				  p_pay_calc_out_data	 =>  l_pay_calc_out_rec,
				  p_message_set          =>  l_message_set,
				  p_calculated           =>  l_calculated
				 );

                hr_utility.set_location('After Main Pay Calc  ' || l_proc, 13);
                if l_calculated then
                   hr_utility.set_location('l_Calculated is TRUE  ' || l_proc, 13);
                else
                   hr_utility.set_location('l_Calculated is FASLE  ' || l_proc, 13);
                end if;
         If not nvl(l_pay_calc_out_rec.open_pay_fields, FALSE) then
              hr_utility.set_location('pay fields not open',1);

              If l_calculated  then
                  -- assign
                hr_utility.set_location( ' Not Custom Pay Calc : ' || l_proc,12);

                p_sf52_rec.custom_pay_calc_flag         := 'N';
                -- FWFA Changes Bug#4444609
                p_sf52_rec.from_pay_table_identifier    := l_pay_calc_out_rec.pay_table_id;
                p_sf52_rec.to_pay_table_identifier	:= l_pay_calc_out_rec.calculation_pay_table_id;
                -- FWFA Changes
                p_sf52_rec.to_basic_pay                 := l_pay_calc_out_rec.basic_pay;
                p_sf52_rec.to_locality_adj              := l_pay_calc_out_rec.locality_adj;
                p_sf52_rec.to_adj_basic_pay             := l_pay_calc_out_rec.adj_basic_pay;
                p_sf52_rec.to_total_salary              := l_pay_calc_out_rec.total_salary;
                p_sf52_rec.to_retention_allowance       := l_pay_calc_out_rec.retention_allowance;
                p_sf52_rec.to_other_pay_amount          := l_pay_calc_out_rec.other_pay_amount;
                p_sf52_rec.to_au_overtime               := l_pay_calc_out_rec.au_overtime;
                p_sf52_rec.to_availability_pay          := l_pay_calc_out_rec.availability_pay;
                -- Start Processing for bug 2684176
                IF p_sf52_rec.first_noa_code = '894' THEN
                    g_prd := l_pay_calc_out_rec.out_pay_rate_determinant;
                    g_step_or_rate := l_pay_calc_out_rec.out_step_or_rate;
                    IF g_prd is NOT NULL THEN
                       IF l_pay_calc_out_rec.out_step_or_rate IS NOT NULL THEN
                          IF nvl(g_prd,'0') not in ('A','B','E','F','U','V') THEN
			    hr_utility.set_location('Inside G_prd condition',10);
                            p_sf52_rec.to_step_or_rate  :=
                                NVL(l_pay_calc_out_rec.out_step_or_rate, p_sf52_rec.to_step_or_rate);
----Bug 2914406 fix start
                            p_sf52_rec.pay_rate_determinant :=
                                  NVL(l_pay_calc_out_rec.out_pay_rate_determinant, p_sf52_rec.pay_rate_determinant);
----Bug 2914406 fix End
                          END IF;
		               ELSE
              			    hr_utility.set_location('Inside G_prd condition and g_step null',10);
                           p_sf52_rec.pay_rate_determinant :=
                                  NVL(l_pay_calc_out_rec.out_pay_rate_determinant, p_sf52_rec.pay_rate_determinant);
                       END IF;
                   ELSE
  		        hr_utility.set_location('Inside G_prd NULL condition',10);
                        -- FWFA Changes Bug#4444609 Modified the value of PRD.
                        p_sf52_rec.pay_rate_determinant :=
                                      NVL(p_sf52_rec.input_pay_rate_determinant, p_sf52_rec.pay_rate_determinant);
                        -- FWFA Changes
                        p_sf52_rec.to_step_or_rate  :=
                                      NVL(l_pay_calc_out_rec.out_step_or_rate, p_sf52_rec.to_step_or_rate);
                   END IF;
                ELSE
                  -- FWFA Changes Bug#4444609 Modified the value of PRD
		  hr_utility.set_location('inside NON 894 Actions ',20);
                  p_sf52_rec.pay_rate_determinant :=
                                NVL(l_pay_calc_out_rec.out_pay_rate_determinant,
                                    NVL(p_sf52_rec.input_pay_rate_determinant,p_sf52_rec.pay_rate_determinant)
                                    );
                  -- FWFA Changes
                  p_sf52_rec.to_step_or_rate  :=
                                NVL(l_pay_calc_out_rec.out_step_or_rate, p_sf52_rec.to_step_or_rate);
                END IF;
                            -- End Processing for bug 2684176
              End if;
         Elsif l_pay_calc_out_rec.open_pay_fields then
                  hr_utility.set_location('open pay fields',1);
  	            hr_utility.set_location( 'Error - Pay Calc failed ' || l_proc, 90);
	            hr_utility.set_message(8301,'GHR_38401_OPEN_PAY');
                  hr_utility.raise_error;
			--     error; -- send back to user

         End if;
      End if;
	 Elsif nvl(p_sf52_rec.noa_family_code,hr_api.g_varchar2) = 'OTHER_PAY'
		then
	    -- and  (p_sf52_rec.first_noa_code <> '899') and not (p_sf52_rec.first_noa_code = '002' and
             --	p_sf52_rec.second_noa_code = '899')
		hr_utility.set_location( 'Other Pay Calculation ' || l_proc, 95);
		-- fOR OTHER PAY family calculate other_pay_amount and total_pay_amount
		p_sf52_rec.to_other_pay_amount :=	nvl(p_sf52_rec.to_au_overtime             , 0) +
								nvl(p_sf52_rec.to_availability_pay        , 0) +
								nvl(p_sf52_rec.to_retention_allowance     , 0) +
								nvl(p_sf52_rec.to_supervisory_differential, 0) +
								nvl(p_sf52_rec.to_staffing_differential   , 0);
                -- FWS Changes
		p_sf52_rec.to_total_salary := p_sf52_rec.to_adj_basic_pay +
                                              NVL(p_sf52_rec.to_other_pay_amount,0);

	End if;
	-- VSM temp call
        -- Begin Update 34 - Validation Logic
	  hr_utility.set_location( 'Before calling do_pay_caps_main noa_family_code is ' ||p_sf52_rec.noa_family_code, 95);
          ghr_history_api.get_g_session_var( l_session_var);
          -- Bug#4486823 RRR Changes. Added GHR_INCENTIVE Family also.
	  IF not (p_sf52_rec.noa_family_code in
                     ('POS_REVIEW',
                      'RECRUIT_FILL',
                      'NON_PAY_DUTY_STATUS',
                      'POS_ESTABLISH',
                      'AWARD',
		      'GHR_INCENTIVE',
                      'SEPARATION',
                      'POS_ABOLISH')
/*BUG 7186053 Commented the below line as it is not required. Code in the if clause should not run for
all the NOA Families mentioned in the condition. */
                 -- AND  l_session_var.noa_id_correct is not NULL) THEN
			) THEN
	  hr_utility.set_location( 'Before calling do_pay_caps_main ' ||p_capped_other_pay , 95);
	  hr_utility.set_location( 'p_sf52_rec.to_total_salary is ' || p_sf52_rec.to_total_salary, 95);
        IF p_capped_other_pay <> hr_api.g_number OR
           p_capped_other_pay is NULL THEN
	  hr_utility.set_location( 'p_sf52_rec.to_total_salary is ' || p_sf52_rec.to_total_salary, 95);

          ghr_pay_caps.do_pay_caps_main (
           p_pa_request_id        =>    p_sf52_rec.pa_request_id,
           p_effective_date       =>    NVL(p_sf52_rec.effective_date,TRUNC(sysdate)) ,
           p_pay_rate_determinant =>    p_sf52_rec.pay_rate_determinant ,
           p_pay_plan             =>    p_sf52_rec.to_pay_plan ,
           p_to_position_id       =>    p_sf52_rec.to_position_id ,
           p_pay_basis            =>    p_sf52_rec.to_pay_basis ,
           p_person_id            =>    p_sf52_rec.person_id ,
           p_noa_code             =>    p_sf52_rec.first_noa_code ,
           p_basic_pay            =>    p_sf52_rec.to_basic_pay ,
           p_locality_adj         =>    p_sf52_rec.to_locality_adj ,
           p_adj_basic_pay        =>    p_sf52_rec.to_adj_basic_pay
           ,p_total_salary         =>    p_sf52_rec.to_total_salary
           ,p_other_pay_amount     =>    p_sf52_rec.to_other_pay_amount
           ,p_capped_other_pay     =>    p_capped_other_pay
           ,p_retention_allowance  =>    p_sf52_rec.to_retention_allowance
           ,p_retention_allow_percentage  =>    p_sf52_rec.to_retention_allow_percentage
           ,p_supervisory_allowance =>   p_sf52_rec.to_supervisory_differential
           ,p_staffing_differential =>   p_sf52_rec.to_staffing_differential
           ,p_au_overtime          =>    p_sf52_rec.to_au_overtime
           ,p_availability_pay     =>    p_sf52_rec.to_availability_pay
                   ,p_adj_basic_message    =>    l_adj_basic_message
                   ,p_pay_cap_message      =>    l_pay_cap_message
                   ,p_pay_cap_adj          =>    l_temp_retention_allowance
           ,p_open_pay_fields      =>    l_open_pay_fields_caps
           ,p_message_set          =>    l_message_set_caps
           ,p_total_pay_check      =>    g_total_pay_check);



           p_sf52_rec.to_other_pay_amount := nvl(p_capped_other_pay,p_sf52_rec.to_other_pay_amount);

           l_temp_ret_allo_percentage := trunc((l_temp_retention_allowance/p_sf52_rec.to_basic_pay)*100,2);

           if l_pay_cap_message then
				hr_utility.raise_error;
				-- This would show the error message with tokens passed with
				-- the values from the sub-program called above - do_pay_caps_main.
				-- So no need to explicitly again initiate the error message
				-- and set of the tokens seperately. Earlier 38893 message was called here.
				-- 4085704
			end if;

       END IF;
       END IF;


        -- End Update 34 - Validation Logic
	print_sf52('After redo_pay : ' , p_sf52_rec);

	hr_utility.set_location( 'Leaving :  ' || l_proc,100);

EXCEPTION
  WHEN others THEN
     -- Reset IN OUT parameters and set OUT parameters

        p_capped_other_pay := l_capped_other_pay;
	p_sf52_rec         := l_sf52_rec ;

   hr_utility.set_location('Leaving  ' || l_proc,101);
   RAISE;

End redo_pay_calc;


Procedure Update_rfrs_values( p_sf52_data   in out nocopy ghr_pa_requests%rowtype,
			                  p_shadow_data in     ghr_pa_request_shadow%rowtype) is
	cursor get_par_ovn is
	select
		object_version_number
	from ghr_pa_requests
	where pa_request_id = p_Sf52_data.pa_request_id;

        cursor get_person_type is
          select ppt.system_person_type
          from   per_people_f ppf,
                 per_person_types ppt
          where   ppf.person_id = p_sf52_data.person_id
          and     p_sf52_data.effective_date
          between ppf.effective_start_date
          and     ppf.effective_end_date
          and     ppt.person_type_id = ppf.person_type_id;


	l_result	Boolean;
	l_ovn		ghr_pa_requests.object_version_number%type;
        l_per_type      per_person_types.system_person_type%type;
	l_sf52_data     ghr_pa_requests%rowtype;


Begin

        l_sf52_data := p_sf52_data ; --NOCOPY Changes

	open get_par_ovn;
	fetch get_par_ovn into l_ovn;
	close get_par_ovn;

-- Update SF52
-- If future Action and rehire of an ex_employee, then
-- no assignment will exist for the person, as we have rolled back the changes
-- that would have generated an assignment_id. Hence it is required to make sure
-- that the assignment_id on the SF52 does not get refreshed with any new value.

      If trunc(p_sf52_data.effective_date) >  trunc(sysdate) then
        for per_type  in get_person_type  loop
          l_per_type := per_type.system_person_type;
        end loop;
        If nvl(l_per_type,hr_api.g_varchar2) = 'EX_EMP' then
            p_sf52_data.employee_assignment_id := Null;
        End if;
      End if;

-- Note : Ver 10.53 fix
--  Commented out all the columns that are specific to notification
-- Bug 1304629 uncommented p_agency_code, p_employee_dept_or_agency
	ghr_par_upd.upd
		(p_pa_request_id                 =>  p_sf52_data.pa_request_id
		,p_academic_discipline           =>  p_sf52_data.academic_discipline
		,p_agency_code                   =>  p_sf52_data.agency_code
		,p_annuitant_indicator           =>  p_sf52_data.annuitant_indicator
		,p_annuitant_indicator_desc      =>  p_sf52_data.annuitant_indicator_desc
		,p_appropriation_code1           =>  p_sf52_data.appropriation_code1
		,p_appropriation_code2           =>  p_sf52_data.appropriation_code2
		,p_award_amount                  =>  p_sf52_data.award_amount
		,p_award_uom                     =>  p_sf52_data.award_uom
		,p_bargaining_unit_status        =>  p_sf52_data.bargaining_unit_status
		,p_citizenship                   =>  p_sf52_data.citizenship
		,p_custom_pay_calc_flag          =>  p_sf52_data.custom_pay_calc_flag
		,p_duty_station_code             =>  p_sf52_data.duty_station_code
		,p_duty_station_desc             =>  p_sf52_data.duty_station_desc
		,p_duty_station_id               =>  p_sf52_data.duty_station_id
		,p_duty_station_location_id      =>  p_sf52_data.duty_station_location_id
		,p_education_level               =>  p_sf52_data.education_level
		,p_employee_assignment_id        =>  p_sf52_data.employee_assignment_id
		,p_employee_date_of_birth        =>  p_sf52_data.employee_date_of_birth
		,p_employee_dept_or_agency       =>  p_sf52_data.employee_dept_or_agency
		,p_employee_first_name           =>  p_sf52_data.employee_first_name
		,p_employee_last_name            =>  p_sf52_data.employee_last_name
		,p_employee_middle_names         =>  p_sf52_data.employee_middle_names
		,p_employee_national_identifier  =>  p_sf52_data.employee_national_identifier
		,p_fegli                         =>  p_sf52_data.fegli
		,p_fegli_desc                    =>  p_sf52_data.fegli_desc
		,p_flsa_category                 =>  p_sf52_data.flsa_category
		,p_forwarding_address_line1      =>  p_sf52_data.forwarding_address_line1
		,p_forwarding_address_line2      =>  p_sf52_data.forwarding_address_line2
		,p_forwarding_address_line3      =>  p_sf52_data.forwarding_address_line3
		,p_forwarding_country            =>  p_sf52_data.forwarding_country
		,p_forwarding_country_short_nam  =>  p_sf52_data.forwarding_country_short_name
		,p_forwarding_postal_code        =>  p_sf52_data.forwarding_postal_code
		,p_forwarding_region_2           =>  p_sf52_data.forwarding_region_2
		,p_forwarding_town_or_city       =>  p_sf52_data.forwarding_town_or_city
		,p_from_adj_basic_pay            =>  p_sf52_data.from_adj_basic_pay
--		,p_from_agency_code              =>  p_sf52_data.from_agency_code
--		,p_from_agency_desc              =>  p_sf52_data.from_agency_desc
		,p_from_basic_pay                =>  p_sf52_data.from_basic_pay
		,p_from_grade_or_level           =>  p_sf52_data.from_grade_or_level
		,p_from_locality_adj             =>  p_sf52_data.from_locality_adj
		,p_from_occ_code                 =>  p_sf52_data.from_occ_code
--		,p_from_office_symbol            =>  p_sf52_data.from_office_symbol
		,p_from_other_pay_amount         =>  p_sf52_data.from_other_pay_amount
		,p_from_pay_basis                =>  p_sf52_data.from_pay_basis
		,p_from_pay_plan                 =>  p_sf52_data.from_pay_plan
        -- FWFA Changes Bug#4444609
        ,p_input_pay_rate_determinant    =>  p_sf52_data.input_pay_rate_determinant
        ,p_from_pay_table_identifier     =>  p_sf52_data.from_pay_table_identifier
        -- FWFA Changes
		,p_from_position_id              =>  p_sf52_data.from_position_id
		,p_from_position_org_line1       =>  p_sf52_data.from_position_org_line1
		,p_from_position_org_line2       =>  p_sf52_data.from_position_org_line2
		,p_from_position_org_line3       =>  p_sf52_data.from_position_org_line3
		,p_from_position_org_line4       =>  p_sf52_data.from_position_org_line4
		,p_from_position_org_line5       =>  p_sf52_data.from_position_org_line5
		,p_from_position_org_line6       =>  p_sf52_data.from_position_org_line6
		,p_from_position_number          =>  p_sf52_data.from_position_number
		,p_from_position_seq_no          =>  p_sf52_data.from_position_seq_no
		,p_from_position_title           =>  p_sf52_data.from_position_title
		,p_from_step_or_rate             =>  p_sf52_data.from_step_or_rate
		,p_from_total_salary             =>  p_sf52_data.from_total_salary
		,p_functional_class              =>  p_sf52_data.functional_class
		,p_notepad                       =>  p_sf52_data.notepad
		,p_part_time_hours               =>  p_sf52_data.part_time_hours
		,p_pay_rate_determinant          =>  p_sf52_data.pay_rate_determinant
--		,p_personnel_office_id           =>  p_sf52_data.personnel_office_id
		,p_person_id                     =>  p_sf52_data.person_id
		,p_position_occupied             =>  p_sf52_data.position_occupied
		,p_requesting_office_remarks_de  =>  p_sf52_data.requesting_office_remarks_desc
		,p_requesting_office_remarks_fl  =>  p_sf52_data.requesting_office_remarks_flag
		,p_resign_and_retire_reason_des  =>  p_sf52_data.resign_and_retire_reason_desc
		,p_retirement_plan               =>  p_sf52_data.retirement_plan
		,p_retirement_plan_desc          =>  p_sf52_data.retirement_plan_desc
		,p_service_comp_date             =>  p_sf52_data.service_comp_date
		,p_supervisory_status            =>  p_sf52_data.supervisory_status
		,p_tenure                        =>  p_sf52_data.tenure
		,p_to_adj_basic_pay              =>  p_sf52_data.to_adj_basic_pay
		,p_to_basic_pay                  =>  p_sf52_data.to_basic_pay
		,p_to_grade_id                   =>  p_sf52_data.to_grade_id
		,p_to_grade_or_level             =>  p_sf52_data.to_grade_or_level
		,p_to_job_id                     =>  p_sf52_data.to_job_id
		,p_to_locality_adj               =>  p_sf52_data.to_locality_adj
		,p_to_occ_code                   =>  p_sf52_data.to_occ_code
	--	,p_to_office_symbol              =>  p_sf52_data.to_office_symbol
	        ,p_to_organization_id            =>  p_sf52_data.to_organization_id
		,p_to_other_pay_amount           =>  p_sf52_data.to_other_pay_amount
		,p_to_au_overtime                =>  p_sf52_data.to_au_overtime
		,p_to_auo_premium_pay_indicator  =>  p_sf52_data.to_auo_premium_pay_indicator
		,p_to_availability_pay           =>  p_sf52_data.to_availability_pay
		,p_to_ap_premium_pay_indicator   =>  p_sf52_data.to_ap_premium_pay_indicator
		,p_to_retention_allowance        =>  p_sf52_data.to_retention_allowance
		,p_to_retention_allow_percentag =>  p_sf52_data.to_retention_allow_percentage
		,p_to_supervisory_differential   =>  p_sf52_data.to_supervisory_differential
		,p_to_supervisory_diff_percenta=>  p_sf52_data.to_supervisory_diff_percentage
		,p_to_staffing_differential      =>  p_sf52_data.to_staffing_differential
		,p_to_staffing_diff_percentage   =>  p_sf52_data.to_staffing_diff_percentage
		,p_to_pay_basis                  =>  p_sf52_data.to_pay_basis
		,p_to_pay_plan                   =>  p_sf52_data.to_pay_plan
        -- FWFA Changes Bug#4444609
        ,p_to_pay_table_identifier       =>  p_sf52_data.to_pay_table_identifier
        -- FWFA Changes
		,p_to_position_id                =>  p_sf52_data.to_position_id
		,p_to_position_org_line1         =>  p_sf52_data.to_position_org_line1
		,p_to_position_org_line2         =>  p_sf52_data.to_position_org_line2
		,p_to_position_org_line3         =>  p_sf52_data.to_position_org_line3
		,p_to_position_org_line4         =>  p_sf52_data.to_position_org_line4
		,p_to_position_org_line5         =>  p_sf52_data.to_position_org_line5
		,p_to_position_org_line6         =>  p_sf52_data.to_position_org_line6
		,p_to_position_number            =>  p_sf52_data.to_position_number
		,p_to_position_seq_no            =>  p_sf52_data.to_position_seq_no
		,p_to_position_title             =>  p_sf52_data.to_position_title
		,p_to_step_or_rate               =>  p_sf52_data.to_step_or_rate
		,p_to_total_salary               =>  p_sf52_data.to_total_salary
		,p_veterans_preference           =>  p_sf52_data.veterans_preference
		,p_veterans_pref_for_rif         =>  p_sf52_data.veterans_pref_for_rif
		,p_veterans_status               =>  p_sf52_data.veterans_status
		,p_work_schedule                 =>  p_sf52_data.work_schedule
		,p_work_schedule_desc            =>  p_sf52_data.work_schedule_desc
		,p_year_degree_attained          =>  p_sf52_data.year_degree_attained
		,p_attribute_category            =>  p_sf52_data.attribute_category
		,p_attribute1                    =>  p_sf52_data.attribute1
		,p_attribute2                    =>  p_sf52_data.attribute2
		,p_attribute3                    =>  p_sf52_data.attribute3
		,p_attribute4                    =>  p_sf52_data.attribute4
		,p_attribute5                    =>  p_sf52_data.attribute5
		,p_attribute6                    =>  p_sf52_data.attribute6
		,p_attribute7                    =>  p_sf52_data.attribute7
		,p_attribute8                    =>  p_sf52_data.attribute8
		,p_attribute9                    =>  p_sf52_data.attribute9
		,p_attribute10                   =>  p_sf52_data.attribute10
		,p_attribute11                   =>  p_sf52_data.attribute11
		,p_attribute12                   =>  p_sf52_data.attribute12
		,p_attribute13                   =>  p_sf52_data.attribute13
		,p_attribute14                   =>  p_sf52_data.attribute14
		,p_attribute15                   =>  p_sf52_data.attribute15
		,p_attribute16                   =>  p_sf52_data.attribute16
		,p_attribute17                   =>  p_sf52_data.attribute17
		,p_attribute18                   =>  p_sf52_data.attribute18
		,p_attribute19                   =>  p_sf52_data.attribute19
		,p_attribute20                   =>  p_sf52_data.attribute20
		,p_object_version_number         =>  l_ovn);

		p_sf52_data.object_version_number := l_ovn;

-- Following commented columns need not be refreshed as theses are entered by the user or are generated
-- at the time notification is created.
-- p_pa_notification_id            =>  p_sf52_data.pa_notification_id
-- p_noa_family_code               =>  p_sf52_data.noa_family_code
-- p_routing_group_id              =>  p_sf52_data.routing_grou  =>  p_sf52_data.id
-- p_proposed_effective_asap_flag  =>  p_sf52_data.proposed_effective_asap_sf52_
-- p_additional_info_person_id     =>  p_sf52_data.additional_info_person_id
-- p_additional_info_tel_number    =>  p_sf52_data.additional_info_tel_number
-- p_altered_pa_request_id         =>  p_sf52_data.altered_pa_request_id
-- p_approval_date                 =>  p_sf52_data.approval_date
-- p_approving_official_work_titl  =>  p_sf52_data.approving_official_work_title
-- p_authorized_by_person_id       =>  p_sf52_data.authorized_by_person_id
-- p_authorized_by_title           =>  p_sf52_data.authorized_by_title
-- p_concurrence_date              =>  p_sf52_data.concurrence_date
-- p_effective_date                =>  p_sf52_data.effective_date
-- p_first_action_la_code1         =>  p_sf52_data.first_action_la_code1
-- p_first_action_la_code2         =>  p_sf52_data.first_action_la_code2
-- p_first_action_la_desc1         =>  p_sf52_data.first_action_la_desc1
-- p_first_action_la_desc2         =>  p_sf52_data.first_action_la_desc2
-- p_first_noa_cancel_or_correct   =>  p_sf52_data.first_noa_cancel_or_correct
-- p_first_noa_code                =>  p_sf52_data.first_noa_code
-- p_first_noa_desc                =>  p_sf52_data.first_noa_desc
-- p_first_noa_id                  =>  p_sf52_data.first_noa_id
-- p_first_noa_pa_request_id       =>  p_sf52_data.first_noa_pa_request_id
-- p_proposed_effective_date       =>  p_sf52_data.proposed_effective_date
-- p_requested_by_person_id        =>  p_sf52_data.requested_by_person_id
-- p_requested_by_title            =>  p_sf52_data.requested_by_title
-- p_requested_date                =>  p_sf52_data.requested_date
-- p_request_number                =>  p_sf52_data.request_number
-- p_second_action_la_code1        =>  p_sf52_data.second_action_la_code1
-- p_second_action_la_code2        =>  p_sf52_data.second_action_la_code2
-- p_second_action_la_desc1        =>  p_sf52_data.second_action_la_desc1
-- p_second_action_la_desc2        =>  p_sf52_data.second_action_la_desc2
-- p_second_noa_cancel_or_correct  =>  p_sf52_data.second_noa_cancel_or_correct
-- p_second_noa_code               =>  p_sf52_data.second_noa_code
-- p_second_noa_desc               =>  p_sf52_data.second_noa_desc
-- p_second_noa_id                 =>  p_sf52_data.second_noa_id
-- p_second_noa_pa_request_id      =>  p_sf52_data.second_noa_pa_request_id
-- p_first_noa_information1        =>  p_sf52_data.first_noa_information1
-- p_first_noa_information2        =>  p_sf52_data.first_noa_information2
-- p_first_noa_information3        =>  p_sf52_data.first_noa_information3
-- p_first_noa_information4        =>  p_sf52_data.first_noa_information4
-- p_first_noa_information5        =>  p_sf52_data.first_noa_information5
-- p_second_lac1_information1      =>  p_sf52_data.second_lac1_information1
-- p_second_lac1_information2      =>  p_sf52_data.second_lac1_information2
-- p_second_lac1_information3      =>  p_sf52_data.second_lac1_information3
-- p_second_lac1_information4      =>  p_sf52_data.second_lac1_information4
-- p_second_lac1_information5      =>  p_sf52_data.second_lac1_information5
-- p_second_lac2_information1      =>  p_sf52_data.second_lac2_information1
-- p_second_lac2_information2      =>  p_sf52_data.second_lac2_information2
-- p_second_lac2_information3      =>  p_sf52_data.second_lac2_information3
-- p_second_lac2_information4      =>  p_sf52_data.second_lac2_information4
-- p_second_lac2_information5      =>  p_sf52_data.second_lac2_information5
-- p_second_noa_information1       =>  p_sf52_data.second_noa_information1
-- p_second_noa_information2       =>  p_sf52_data.second_noa_information2
-- p_second_noa_information3       =>  p_sf52_data.second_noa_information3
-- p_second_noa_information4       =>  p_sf52_data.second_noa_information4
-- p_second_noa_information5       =>  p_sf52_data.second_noa_information5
-- p_first_lac1_information1       =>  p_sf52_data.first_lac1_information1
-- p_first_lac1_information2       =>  p_sf52_data.first_lac1_information2
-- p_first_lac1_information3       =>  p_sf52_data.first_lac1_information3
-- p_first_lac1_information4       =>  p_sf52_data.first_lac1_information4
-- p_first_lac1_information5       =>  p_sf52_data.first_lac1_information5
-- p_first_lac2_information1       =>  p_sf52_data.first_lac2_information1
-- p_first_lac2_information2       =>  p_sf52_data.first_lac2_information2
-- p_first_lac2_information3       =>  p_sf52_data.first_lac2_information3
-- p_first_lac2_information4       =>  p_sf52_data.first_lac2_information4
-- p_first_lac2_information5       =>  p_sf52_data.first_lac2_information5

	update_shadow_row ( p_shadow_data => p_shadow_data,
				  p_result      => l_result);
	if NOT l_result then
		NULL;
		-- raise error;
	end if;
EXCEPTION
  WHEN others THEN
     -- Reset IN OUT parameters and set OUT parameters

        p_sf52_data := l_sf52_data ;

   hr_utility.set_location('Leaving Update_rfrs_values ' ,160);
   RAISE;

End Update_rfrs_values;

Procedure create_shadow_row ( p_shadow_data	in	ghr_pa_request_shadow%rowtype) is
Begin
	Insert into ghr_pa_request_shadow
	(pa_request_id
	,academic_discipline
	,annuitant_indicator
	,appropriation_code1
	,appropriation_code2
	,bargaining_unit_status
	,citizenship
	,duty_station_id
	,duty_station_location_id
	,education_level
	,fegli
	,flsa_category
	,forwarding_address_line1
	,forwarding_address_line2
	,forwarding_address_line3
	,forwarding_country_short_name
	,forwarding_postal_code
	,forwarding_region_2
	,forwarding_town_or_city
	,functional_class
	,part_time_hours
	,pay_rate_determinant
	,position_occupied
	,retirement_plan
	,service_comp_date
	,supervisory_status
	,tenure
	,to_ap_premium_pay_indicator
	,to_auo_premium_pay_indicator
	,to_occ_code
	,to_position_id
	,to_retention_allowance
	,to_retention_allow_percentage
	,to_staffing_differential
	,to_staffing_diff_percentage
	,to_step_or_rate
	,to_supervisory_differential
	,to_supervisory_diff_percentage
	,veterans_preference
	,veterans_pref_for_rif
	,veterans_status
	,work_schedule
	,year_degree_attained          )
	values
	(p_shadow_data.pa_request_id
	,p_shadow_data.academic_discipline
	,p_shadow_data.annuitant_indicator
	,p_shadow_data.appropriation_code1
	,p_shadow_data.appropriation_code2
	,p_shadow_data.bargaining_unit_status
	,p_shadow_data.citizenship
	,p_shadow_data.duty_station_id
	,p_shadow_data.duty_station_location_id
	,p_shadow_data.education_level
	,p_shadow_data.fegli
	,p_shadow_data.flsa_category
	,p_shadow_data.forwarding_address_line1
	,p_shadow_data.forwarding_address_line2
	,p_shadow_data.forwarding_address_line3
	,p_shadow_data.forwarding_country_short_name
	,p_shadow_data.forwarding_postal_code
	,p_shadow_data.forwarding_region_2
	,p_shadow_data.forwarding_town_or_city
	,p_shadow_data.functional_class
	,p_shadow_data.part_time_hours
	,p_shadow_data.pay_rate_determinant
	,p_shadow_data.position_occupied
	,p_shadow_data.retirement_plan
	,p_shadow_data.service_comp_date
	,p_shadow_data.supervisory_status
	,p_shadow_data.tenure
	,p_shadow_data.to_ap_premium_pay_indicator
	,p_shadow_data.to_auo_premium_pay_indicator
	,p_shadow_data.to_occ_code
	,p_shadow_data.to_position_id
	,p_shadow_data.to_retention_allowance
	,p_shadow_data.to_retention_allow_percentage
	,p_shadow_data.to_staffing_differential
	,p_shadow_data.to_staffing_diff_percentage
	,p_shadow_data.to_step_or_rate
	,p_shadow_data.to_supervisory_differential
	,p_shadow_data.to_supervisory_diff_percentage
	,p_shadow_data.veterans_preference
	,p_shadow_data.veterans_pref_for_rif
	,p_shadow_data.veterans_status
	,p_shadow_data.work_schedule
	,p_shadow_data.year_degree_attained
	);
end create_shadow_row;

Procedure create_shadow_row ( p_sf52_data	in	ghr_pa_requests%rowtype) is
Begin
	Insert into ghr_pa_request_shadow
	(pa_request_id
	,academic_discipline
	,annuitant_indicator
	,appropriation_code1
	,appropriation_code2
	,bargaining_unit_status
	,citizenship
	,duty_station_id
	,duty_station_location_id
	,education_level
	,fegli
	,flsa_category
	,forwarding_address_line1
	,forwarding_address_line2
	,forwarding_address_line3
	,forwarding_country_short_name
	,forwarding_postal_code
	,forwarding_region_2
	,forwarding_town_or_city
	,functional_class
	,part_time_hours
	,pay_rate_determinant
	,position_occupied
	,retirement_plan
	,service_comp_date
	,supervisory_status
	,tenure
	,to_ap_premium_pay_indicator
	,to_auo_premium_pay_indicator
	,to_occ_code
	,to_position_id
	,to_retention_allowance
	,to_retention_allow_percentage
	,to_staffing_differential
	,to_staffing_diff_percentage
	,to_step_or_rate
	,to_supervisory_differential
	,to_supervisory_diff_percentage
	,veterans_preference
	,veterans_pref_for_rif
	,veterans_status
	,work_schedule
	,year_degree_attained          )
	values
	(p_sf52_data.pa_request_id
	,p_sf52_data.academic_discipline
	,p_sf52_data.annuitant_indicator
	,p_sf52_data.appropriation_code1
	,p_sf52_data.appropriation_code2
	,p_sf52_data.bargaining_unit_status
	,p_sf52_data.citizenship
	,p_sf52_data.duty_station_id
	,p_sf52_data.duty_station_location_id
	,p_sf52_data.education_level
	,p_sf52_data.fegli
	,p_sf52_data.flsa_category
	,p_sf52_data.forwarding_address_line1
	,p_sf52_data.forwarding_address_line2
	,p_sf52_data.forwarding_address_line3
	,p_sf52_data.forwarding_country_short_name
	,p_sf52_data.forwarding_postal_code
	,p_sf52_data.forwarding_region_2
	,p_sf52_data.forwarding_town_or_city
	,p_sf52_data.functional_class
	,p_sf52_data.part_time_hours
	,p_sf52_data.pay_rate_determinant
	,p_sf52_data.position_occupied
	,p_sf52_data.retirement_plan
	,p_sf52_data.service_comp_date
	,p_sf52_data.supervisory_status
	,p_sf52_data.tenure
	,p_sf52_data.to_ap_premium_pay_indicator
	,p_sf52_data.to_auo_premium_pay_indicator
	,p_sf52_data.to_occ_code
	,p_sf52_data.to_position_id
	,p_sf52_data.to_retention_allowance
	,p_sf52_data.to_retention_allow_percentage
	,p_sf52_data.to_staffing_differential
	,p_sf52_data.to_staffing_diff_percentage
	,p_sf52_data.to_step_or_rate
	,p_sf52_data.to_supervisory_differential
	,p_sf52_data.to_supervisory_diff_percentage
	,p_sf52_data.veterans_preference
	,p_sf52_data.veterans_pref_for_rif
	,p_sf52_data.veterans_status
	,p_sf52_data.work_schedule
	,p_sf52_data.year_degree_attained
	);
end create_shadow_row;

Procedure Update_shadow_row ( p_shadow_data	 in	ghr_pa_request_shadow%rowtype,
			      p_result		out nocopy	Boolean) is
Begin
	Update ghr_pa_request_shadow
	Set
	 pa_request_id                 	= p_shadow_data.pa_request_id
	,academic_discipline           	= p_shadow_data.academic_discipline
	,annuitant_indicator           	= p_shadow_data.annuitant_indicator
	,appropriation_code1           	= p_shadow_data.appropriation_code1
	,appropriation_code2           	= p_shadow_data.appropriation_code2
	,bargaining_unit_status        	= p_shadow_data.bargaining_unit_status
	,citizenship                   	= p_shadow_data.citizenship
	,duty_station_id               	= p_shadow_data.duty_station_id
	,duty_station_location_id      	= p_shadow_data.duty_station_location_id
	,education_level               	= p_shadow_data.education_level
	,fegli                         	= p_shadow_data.fegli
	,flsa_category                 	= p_shadow_data.flsa_category
	,forwarding_address_line1      	= p_shadow_data.forwarding_address_line1
	,forwarding_address_line2      	= p_shadow_data.forwarding_address_line2
	,forwarding_address_line3      	= p_shadow_data.forwarding_address_line3
	,forwarding_country_short_name 	= p_shadow_data.forwarding_country_short_name
	,forwarding_postal_code        	= p_shadow_data.forwarding_postal_code
	,forwarding_region_2           	= p_shadow_data.forwarding_region_2
	,forwarding_town_or_city       	= p_shadow_data.forwarding_town_or_city
	,functional_class              	= p_shadow_data.functional_class
	,part_time_hours               	= p_shadow_data.part_time_hours
	,pay_rate_determinant          	= p_shadow_data.pay_rate_determinant
	,position_occupied             	= p_shadow_data.position_occupied
	,retirement_plan               	= p_shadow_data.retirement_plan
	,service_comp_date             	= p_shadow_data.service_comp_date
	,supervisory_status            	= p_shadow_data.supervisory_status
	,tenure                        	= p_shadow_data.tenure
	,to_ap_premium_pay_indicator   	= p_shadow_data.to_ap_premium_pay_indicator
	,to_auo_premium_pay_indicator  	= p_shadow_data.to_auo_premium_pay_indicator
	,to_occ_code                   	= p_shadow_data.to_occ_code
	,to_position_id                	= p_shadow_data.to_position_id
	,to_retention_allowance        	= p_shadow_data.to_retention_allowance
	,to_retention_allow_percentage    	= p_shadow_data.to_retention_allow_percentage
	,to_staffing_differential      	= p_shadow_data.to_staffing_differential
	,to_staffing_diff_percentage      	= p_shadow_data.to_staffing_diff_percentage
	,to_step_or_rate               	= p_shadow_data.to_step_or_rate
	,to_supervisory_differential   	= p_shadow_data.to_supervisory_differential
	,to_supervisory_diff_percentage   	= p_shadow_data.to_supervisory_diff_percentage
	,veterans_preference           	= p_shadow_data.veterans_preference
	,veterans_pref_for_rif         	= p_shadow_data.veterans_pref_for_rif
	,veterans_status               	= p_shadow_data.veterans_status
	,work_schedule                 	= p_shadow_data.work_schedule
	,year_degree_attained          	= p_shadow_data.year_degree_attained
where pa_request_id = p_shadow_data.pa_request_id;

if sql%notfound then
		p_result := FALSE;
else
	p_result := TRUE;
end if;

EXCEPTION
  WHEN others THEN
     -- Reset IN OUT parameters and set OUT parameters

       p_result := NULL;

   hr_utility.set_location('Leaving Update_Shadow_row ' ,100);
   RAISE;

end update_shadow_row;

procedure print_sf52(p_proc VARCHAR2, p_pa_request_rec GHR_PA_REQUESTS%ROWTYPE)
IS
BEGIN
   hr_utility.set_location ('-----------------------------------------------', 10);
   hr_utility.set_location (p_proc, 20);
   hr_utility.set_location ('-----------------------------------------------', 30);
   hr_utility.set_location(p_proc||'.pa_request_id '||p_pa_request_rec.pa_request_id
               , 40);
   hr_utility.set_location(p_proc||'.pa_notification_id '||p_pa_request_rec.pa_notification_id
               , 50);
   hr_utility.set_location(p_proc||'.noa_family_code '||p_pa_request_rec.noa_family_code
               , 60);
   hr_utility.set_location(p_proc||'.routing_group_id '||p_pa_request_rec.routing_group_id
               , 70);
   hr_utility.set_location(p_proc||'.academic_discipline '||p_pa_request_rec.academic_discipline
               , 90);
   hr_utility.set_location(p_proc||'.additional_info_person_id '||p_pa_request_rec.additional_info_person_id
               , 100);
   hr_utility.set_location(p_proc||'.additional_info_tel_number '||SUBSTR(p_pa_request_rec.additional_info_tel_number,1,40)
               , 110);
   hr_utility.set_location(p_proc||'.agency_code '||p_pa_request_rec.agency_code
               , 120);
   hr_utility.set_location(p_proc||'.altered_pa_request_id '||p_pa_request_rec.altered_pa_request_id
               , 130);
   hr_utility.set_location(p_proc||'.annuitant_indicator '||p_pa_request_rec.annuitant_indicator
               , 140);
   hr_utility.set_location(p_proc||'.annuitant_indicator_desc '||substr(p_pa_request_rec.annuitant_indicator_desc,1,40)
               , 150);
   hr_utility.set_location(p_proc||'.appropriation_code1 '||p_pa_request_rec.appropriation_code1
               , 160);
   hr_utility.set_location(p_proc||'.appropriation_code2 '||p_pa_request_rec.appropriation_code2
               , 170);
   hr_utility.set_location(p_proc||'.approval_date '||p_pa_request_rec.approval_date
               , 180);
   hr_utility.set_location(p_proc||'.approving_official_work_title '||substr(p_pa_request_rec.approving_official_work_title,1,40)
               , 190);
   hr_utility.set_location(p_proc||'.authorized_by_person_id '||p_pa_request_rec.authorized_by_person_id
               , 200);
   hr_utility.set_location(p_proc||'.authorized_by_title '||substr(p_pa_request_rec.authorized_by_title,1,40)
               , 210);
   hr_utility.set_location(p_proc||'.award_amount '||p_pa_request_rec.award_amount
               , 220);
   hr_utility.set_location(p_proc||'.award_uom '||p_pa_request_rec.award_uom
               , 230);
   hr_utility.set_location(p_proc||'.bargaining_unit_status '||p_pa_request_rec.bargaining_unit_status
               , 240);
   hr_utility.set_location(p_proc||'.citizenship '||p_pa_request_rec.citizenship
               , 250);
   hr_utility.set_location(p_proc||'.concurrence_date '||p_pa_request_rec.concurrence_date
               , 260);
   hr_utility.set_location(p_proc||'.custom_pay_calc_flag '||p_pa_request_rec.custom_pay_calc_flag
               , 270);
   hr_utility.set_location(p_proc||'.duty_station_code '||p_pa_request_rec.duty_station_code
               , 280);
   hr_utility.set_location(p_proc||'.duty_station_desc '||substr(p_pa_request_rec.duty_station_desc,1,40)
               , 290);
   hr_utility.set_location(p_proc||'.duty_station_id '||p_pa_request_rec.duty_station_id
               , 300);
   hr_utility.set_location(p_proc||'.duty_station_location_id '||p_pa_request_rec.duty_station_location_id
               , 310);
   hr_utility.set_location(p_proc||'.education_level '||p_pa_request_rec.education_level
               , 320);
   hr_utility.set_location(p_proc||'.effective_date '||p_pa_request_rec.effective_date
               , 330);
   hr_utility.set_location(p_proc||'.employee_assignment_id '||p_pa_request_rec.employee_assignment_id
               , 340);
   hr_utility.set_location(p_proc||'.employee_date_of_birth '||p_pa_request_rec.employee_date_of_birth
               , 350);
   hr_utility.set_location(p_proc||'.employee_dept_or_agency '||substr(p_pa_request_rec.employee_dept_or_agency,1,40)
               , 360);
   hr_utility.set_location(p_proc||'.employee_first_name '||substr(p_pa_request_rec.employee_first_name,1,40)
               , 370);
   hr_utility.set_location(p_proc||'.employee_last_name '||substr(p_pa_request_rec.employee_last_name,1,40)
               , 380);
   hr_utility.set_location(p_proc||'.employee_middle_names '||substr(p_pa_request_rec.employee_middle_names,1,40)
               , 390);
   hr_utility.set_location(p_proc||'.employee_national_identifier '||p_pa_request_rec.employee_national_identifier
               , 400);
   hr_utility.set_location(p_proc||'.fegli '||p_pa_request_rec.fegli
               , 410);
   hr_utility.set_location(p_proc||'.fegli_desc '||substr(p_pa_request_rec.fegli_desc,1,40)
               , 420);
   hr_utility.set_location(p_proc||'.first_action_la_code1 '||p_pa_request_rec.first_action_la_code1
               , 430);
   hr_utility.set_location(p_proc||'.first_action_la_code2 '||p_pa_request_rec.first_action_la_code2
               , 440);
   hr_utility.set_location(p_proc||'.first_action_la_desc1 '||substr(p_pa_request_rec.first_action_la_desc1,1,40)
               , 450);
   hr_utility.set_location(p_proc||'.first_action_la_desc2 '||substr(p_pa_request_rec.first_action_la_desc2,1,40)
               , 460);
   hr_utility.set_location(p_proc||'.first_noa_cancel_or_correct '||p_pa_request_rec.first_noa_cancel_or_correct
               , 470);
   hr_utility.set_location(p_proc||'.first_noa_code '||p_pa_request_rec.first_noa_code
               , 480);
   hr_utility.set_location(p_proc||'.first_noa_desc '||substr(p_pa_request_rec.first_noa_desc,1,40)
               , 490);
   hr_utility.set_location(p_proc||'.first_noa_id '||p_pa_request_rec.first_noa_id
               , 500);
   hr_utility.set_location(p_proc||'.first_noa_pa_request_id '||p_pa_request_rec.first_noa_pa_request_id
               , 510);
   hr_utility.set_location(p_proc||'.flsa_category '||p_pa_request_rec.flsa_category
               , 520);
   hr_utility.set_location(p_proc||'.forwarding_address_line1 '||substr(p_pa_request_rec.forwarding_address_line1,1,40)
               , 530);
   hr_utility.set_location(p_proc||'.forwarding_address_line2 '||substr(p_pa_request_rec.forwarding_address_line2,1,40)
               , 540);
   hr_utility.set_location(p_proc||'.forwarding_address_line3 '||substr(p_pa_request_rec.forwarding_address_line3,1,40)
               , 550);
   hr_utility.set_location(p_proc||'.forwarding_country '||substr(p_pa_request_rec.forwarding_country,1,40)
               , 560);
   hr_utility.set_location(p_proc||'.forwarding_country_short_name '||substr(p_pa_request_rec.forwarding_country_short_name,1,40)
               , 570);
   hr_utility.set_location(p_proc||'.forwarding_postal_code '||p_pa_request_rec.forwarding_postal_code
               , 580);
   hr_utility.set_location(p_proc||'.forwarding_region_2 '||substr(p_pa_request_rec.forwarding_region_2,1,40)
               , 590);
   hr_utility.set_location(p_proc||'.forwarding_town_or_city '||p_pa_request_rec.forwarding_town_or_city
               , 600);
   hr_utility.set_location(p_proc||'.from_adj_basic_pay '||p_pa_request_rec.from_adj_basic_pay
               , 610);
   hr_utility.set_location(p_proc||'.from_agency_code '||p_pa_request_rec.from_agency_code
               , 610);
   hr_utility.set_location(p_proc||'.from_agency_desc '||substr(p_pa_request_rec.from_agency_desc,1,40)
               , 610);
   hr_utility.set_location(p_proc||'.from_basic_pay '||p_pa_request_rec.from_basic_pay
               , 610);
   hr_utility.set_location(p_proc||'.from_grade_or_level '||p_pa_request_rec.from_grade_or_level
               , 610);
   hr_utility.set_location(p_proc||'.from_locality_adj '||p_pa_request_rec.from_locality_adj
               , 610);
   hr_utility.set_location(p_proc||'.from_occ_code '||substr(p_pa_request_rec.from_occ_code,1,40)
               , 610);
   hr_utility.set_location(p_proc||'.from_office_symbol '||p_pa_request_rec.from_office_symbol
               , 610);
   hr_utility.set_location(p_proc||'.from_other_pay_amount '||p_pa_request_rec.from_other_pay_amount
               , 610);
   hr_utility.set_location(p_proc||'.from_pay_basis '||p_pa_request_rec.from_pay_basis
               , 710);
   hr_utility.set_location(p_proc||'.from_pay_plan '||p_pa_request_rec.from_pay_plan
               , 710);
   --hr_utility.set_location(p_proc||'.from_pay_table_id '||to_char(p_pa_request_rec.from_pay_table_identifier)
               --, 710);
   hr_utility.set_location(p_proc||'.from_position_id '||p_pa_request_rec.from_position_id
               , 710);
   hr_utility.set_location(p_proc||'.from_position_org_line1 '||p_pa_request_rec.from_position_org_line1
               , 710);
   hr_utility.set_location(p_proc||'.from_position_org_line2 '||p_pa_request_rec.from_position_org_line2
               , 710);
   hr_utility.set_location(p_proc||'.from_position_org_line3 '||p_pa_request_rec.from_position_org_line3
               , 710);
   hr_utility.set_location(p_proc||'.from_position_org_line4 '||p_pa_request_rec.from_position_org_line4
               , 710);
   hr_utility.set_location(p_proc||'.from_position_org_line5 '||p_pa_request_rec.from_position_org_line5
               , 710);
   hr_utility.set_location(p_proc||'.from_position_org_line6 '||p_pa_request_rec.from_position_org_line6
               , 710);
   hr_utility.set_location(p_proc||'.from_position_number '||p_pa_request_rec.from_position_number
               , 710);
   hr_utility.set_location(p_proc||'.from_position_seq_no '||p_pa_request_rec.from_position_seq_no
               , 710);
   hr_utility.set_location(p_proc||'.from_position_title '||substr(p_pa_request_rec.from_position_title,1,40)
               , 810);
   hr_utility.set_location(p_proc||'.from_step_or_rate '||p_pa_request_rec.from_step_or_rate
               , 810);
   hr_utility.set_location(p_proc||'.from_total_salary '||p_pa_request_rec.from_total_salary
               , 810);
   hr_utility.set_location(p_proc||'.functional_class '||p_pa_request_rec.functional_class
               , 810);
   hr_utility.set_location(p_proc||'.notepad '||SUBSTR(p_pa_request_rec.notepad,1,40)
               , 810); -- Bug 3659193 Added Substr for Notepad.
   hr_utility.set_location(p_proc||'.part_time_hours '||p_pa_request_rec.part_time_hours
               , 810);
   hr_utility.set_location(p_proc||'.input_pay_rate_determinant '||p_pa_request_rec.input_pay_rate_determinant
               , 810);
   hr_utility.set_location(p_proc||'.pay_rate_determinant '||p_pa_request_rec.pay_rate_determinant
               , 810);
   hr_utility.set_location(p_proc||'.personnel_office_id '||p_pa_request_rec.personnel_office_id
               , 810);
   hr_utility.set_location(p_proc||'.person_id '||p_pa_request_rec.person_id
               , 810);
   hr_utility.set_location(p_proc||'.position_occupied '||p_pa_request_rec.position_occupied
               , 810);
   hr_utility.set_location(p_proc||'.proposed_effective_asap_flag '||p_pa_request_rec.proposed_effective_asap_flag
               , 810);
   hr_utility.set_location(p_proc||'.proposed_effective_date '||p_pa_request_rec.proposed_effective_date
               , 810);
   hr_utility.set_location(p_proc||'.requested_by_person_id '||p_pa_request_rec.requested_by_person_id
               , 910);
   hr_utility.set_location(p_proc||'.requested_by_title '||substr(p_pa_request_rec.requested_by_title,1,40)
               , 910);
   hr_utility.set_location(p_proc||'.requested_date '||p_pa_request_rec.requested_date
               , 910);
   hr_utility.set_location(p_proc||'.requesting_office_remarks_desc '||substr(p_pa_request_rec.requesting_office_remarks_desc,1,40)
               , 910); -- Bug 3381432 added 'substr'
   hr_utility.set_location(p_proc||'.requesting_office_remarks_flag '||p_pa_request_rec.requesting_office_remarks_flag
               , 910);
   hr_utility.set_location(p_proc||'.request_number '||p_pa_request_rec.request_number
               , 910);
   hr_utility.set_location(p_proc||'.resign_and_retire_reason_desc '||substr(p_pa_request_rec.resign_and_retire_reason_desc,1,40)
               , 910); -- Bug 3381432 added 'substr'
   hr_utility.set_location(p_proc||'.retirement_plan '||p_pa_request_rec.retirement_plan
               , 910);
   hr_utility.set_location(p_proc||'.retirement_plan_desc '||substr(p_pa_request_rec.retirement_plan_desc,1,40)
               , 910); -- Bug 3381432 added 'substr'
   hr_utility.set_location(p_proc||'.second_action_la_code1 '||p_pa_request_rec.second_action_la_code1
               , 910);
   hr_utility.set_location(p_proc||'.second_action_la_code2 '||p_pa_request_rec.second_action_la_code2
               , 910);
   hr_utility.set_location(p_proc||'.second_action_la_desc1 '||substr(p_pa_request_rec.second_action_la_desc1,1,40)
               , 1010);
   hr_utility.set_location(p_proc||'.second_action_la_desc2 '||substr(p_pa_request_rec.second_action_la_desc2,1,40)
               , 1010);
   hr_utility.set_location(p_proc||'.second_noa_cancel_or_correct '||p_pa_request_rec.second_noa_cancel_or_correct
               , 1010);
   hr_utility.set_location(p_proc||'.second_noa_code '||p_pa_request_rec.second_noa_code
               , 1010);
   hr_utility.set_location(p_proc||'.second_noa_desc '||substr(p_pa_request_rec.second_noa_desc,1,40)
               , 1010);
   hr_utility.set_location(p_proc||'.second_noa_id '||p_pa_request_rec.second_noa_id
               , 1010);
   hr_utility.set_location(p_proc||'.second_noa_pa_request_id '||p_pa_request_rec.second_noa_pa_request_id
               , 1010);
   hr_utility.set_location(p_proc||'.service_comp_date '||p_pa_request_rec.service_comp_date
               , 1010);
   hr_utility.set_location(p_proc||'.supervisory_status '||p_pa_request_rec.supervisory_status
               , 1010);
   hr_utility.set_location(p_proc||'.tenure '||p_pa_request_rec.tenure
               , 1010);
   hr_utility.set_location(p_proc||'.to_adj_basic_pay '||p_pa_request_rec.to_adj_basic_pay
               , 1010);
   hr_utility.set_location(p_proc||'.to_ap_premium_pay_indicator '||p_pa_request_rec.to_ap_premium_pay_indicator
               , 1010);
   hr_utility.set_location(p_proc||'.to_auo_premium_pay_indicator '||p_pa_request_rec.to_auo_premium_pay_indicator
               , 1010);
   hr_utility.set_location(p_proc||'.to_au_overtime '||p_pa_request_rec.to_au_overtime
               , 1010);
   hr_utility.set_location(p_proc||'.to_availability_pay '||p_pa_request_rec.to_availability_pay
               , 1010);
   hr_utility.set_location(p_proc||'.to_basic_pay '||p_pa_request_rec.to_basic_pay
               , 1010);
   hr_utility.set_location(p_proc||'.to_grade_id '||p_pa_request_rec.to_grade_id
               , 1010);
   hr_utility.set_location(p_proc||'.to_grade_or_level '||p_pa_request_rec.to_grade_or_level
               , 1010);
   hr_utility.set_location(p_proc||'.to_job_id '||p_pa_request_rec.to_job_id
               , 1010);
   hr_utility.set_location(p_proc||'.to_locality_adj '||p_pa_request_rec.to_locality_adj
               , 1010);
   hr_utility.set_location(p_proc||'.to_occ_code '||substr(p_pa_request_rec.to_occ_code,1,40)
               , 1010);
   hr_utility.set_location(p_proc||'.to_office_symbol '||p_pa_request_rec.to_office_symbol
               , 1010);
   hr_utility.set_location(p_proc||'.to_organization_id '||p_pa_request_rec.to_organization_id
               , 1010);
   hr_utility.set_location(p_proc||'.to_other_pay_amount '||p_pa_request_rec.to_other_pay_amount
               , 1010);
   hr_utility.set_location(p_proc||'.to_pay_basis '||p_pa_request_rec.to_pay_basis
               , 1010);
   hr_utility.set_location(p_proc||'.to_pay_plan '||p_pa_request_rec.to_pay_plan
               , 1010);
   --hr_utility.set_location(p_proc||'.to_prd '||p_pa_request_rec.to_pay_rate_determinant
               --, 1010);
   --hr_utility.set_location(p_proc||'.to_pay_table_id '||to_char(p_pa_request_rec.to_pay_table_identifier)
               --, 1010);
   hr_utility.set_location(p_proc||'.to_position_id '||p_pa_request_rec.to_position_id
               , 1010);
   hr_utility.set_location(p_proc||'.to_position_org_line1 '||p_pa_request_rec.to_position_org_line1
               , 1010);
   hr_utility.set_location(p_proc||'.to_position_org_line2 '||p_pa_request_rec.to_position_org_line2
               , 1010);
   hr_utility.set_location(p_proc||'.to_position_org_line3 '||p_pa_request_rec.to_position_org_line3
               , 1010);
   hr_utility.set_location(p_proc||'.to_position_org_line4 '||p_pa_request_rec.to_position_org_line4
               , 1010);
   hr_utility.set_location(p_proc||'.to_position_org_line5 '||p_pa_request_rec.to_position_org_line5
               , 1010);
   hr_utility.set_location(p_proc||'.to_position_org_line6 '||p_pa_request_rec.to_position_org_line6
               , 1010);
   hr_utility.set_location(p_proc||'.to_position_number '||p_pa_request_rec.to_position_number
               , 1010);
   hr_utility.set_location(p_proc||'.to_position_seq_no '||p_pa_request_rec.to_position_seq_no
               , 1010);
   hr_utility.set_location(p_proc||'.to_position_title '||substr(p_pa_request_rec.to_position_title,1,40)
               , 1010);
   hr_utility.set_location(p_proc||'.to_retention_allowance '||p_pa_request_rec.to_retention_allowance
               , 1010);
   hr_utility.set_location(p_proc||'.to_retention_allow_percentage '||p_pa_request_rec.to_retention_allow_percentage
               , 1010);
   hr_utility.set_location(p_proc||'.to_staffing_differential '||p_pa_request_rec.to_staffing_differential
               , 1010);
   hr_utility.set_location(p_proc||'.to_staffing_diff_percentage '||p_pa_request_rec.to_staffing_diff_percentage
               , 1010);
   hr_utility.set_location(p_proc||'.to_step_or_rate '||p_pa_request_rec.to_step_or_rate
               , 1010);
   hr_utility.set_location(p_proc||'.to_supervisory_differential '||p_pa_request_rec.to_supervisory_differential
               , 1010);
   hr_utility.set_location(p_proc||'.to_supervisory_diff_percentage '||p_pa_request_rec.to_supervisory_diff_percentage
               , 1010);
   hr_utility.set_location(p_proc||'.to_total_salary '||p_pa_request_rec.to_total_salary
               , 1010);
   hr_utility.set_location(p_proc||'.veterans_preference '||p_pa_request_rec.veterans_preference
               , 1010);
   hr_utility.set_location(p_proc||'.veterans_pref_for_rif '||p_pa_request_rec.veterans_pref_for_rif
               , 1010);
   hr_utility.set_location(p_proc||'.veterans_status '||p_pa_request_rec.veterans_status
               , 1010);
   hr_utility.set_location(p_proc||'.work_schedule '||p_pa_request_rec.work_schedule
               , 1010);
   hr_utility.set_location(p_proc||'.work_schedule_desc '||substr(p_pa_request_rec.work_schedule_desc,1,40)
               , 1010);
   hr_utility.set_location(p_proc||'.year_degree_attained '||p_pa_request_rec.year_degree_attained
               , 1010);
   hr_utility.set_location(p_proc||'.from_pay_table_identifier '||p_pa_request_rec.from_pay_table_identifier
               , 1010);
   hr_utility.set_location(p_proc||'.to_pay_table_identifier '||p_pa_request_rec.to_pay_table_identifier
               , 1010);
  hr_utility.set_location(p_proc||'.payment option:  '||p_pa_request_rec.pa_incentive_payment_option
               , 1010);
   hr_utility.set_location(p_proc||'.award salary '||p_pa_request_rec.award_salary
               , 1010);

END print_sf52;

--6850492
procedure Dual_Cancel_sf52(p_sf52_data in out nocopy ghr_pa_requests%rowtype
                          ,p_first_noa_code  in varchar2
     	                  ,p_second_noa_code in varchar2
                 	  ,p_pa_request_id   in number
                          ,p_ovn             in number
                	  ,p_first_noa_id    in number
                      	  ,p_second_noa_id   in number
                 	  ,p_row_id          in varchar2) is

l_which_noa           varchar2(1);
l_dual_noa_id         ghr_pa_requests.first_noa_id%type;
l_pa_request_id       ghr_pa_requests.pa_request_id%type;
l_sf52_dual_sec_rec   ghr_pa_requests%rowtype;
l_sf52_dual_first_rec ghr_pa_requests%rowtype;
l_ovn                 ghr_pa_requests.object_version_number%type;
l_pa_remark_id        ghr_pa_remarks.pa_remark_id%type;
l_object_version_number  ghr_pa_remarks.object_version_number%type;
--8737212
l_u_pa_routing_history_id     ghr_pa_routing_history.pa_routing_history_id%TYPE;
l_u_prh_object_version_number ghr_pa_routing_history.object_version_number%TYPE;

cursor c_dual_cancel
     is
     select *
     from   ghr_pa_requests
     where  pa_request_id = l_pa_request_id;


cursor c_dual_first
     is
     select *
     from   ghr_pa_requests
     where  pa_request_id = p_sf52_data.pa_request_id;

cursor get_ovn(p_pa_request_id in number)
    is
    select object_version_number
    from   ghr_pa_requests
    where  pa_request_id = p_pa_request_id;
--8272695
cursor c_get_remarks
    is
    select parem.remark_id,
    	   parem.description,
	   parem.remark_code_information1,
	   parem.remark_code_information2,
	   parem.remark_code_information3,
	   parem.remark_code_information4,
	   parem.remark_code_information5
    from ghr_pa_remarks parem, ghr_remarks rem
    where parem.pa_request_id = p_sf52_data.pa_request_id
    and   parem.remark_id  = rem.remark_id
    and   substr(rem.code,1,1) = 'C';
-- 8272695

--8737212
cursor 	C_routing_history_id
    is
    SELECT   prh.pa_routing_history_id,
             prh.object_version_number
    FROM     ghr_pa_routing_history prh
    WHERE    prh.pa_request_id = l_sf52_dual_sec_rec.pa_request_id
    ORDER by prh.pa_routing_history_id desc;

cursor c_first_routing_det
    is
    select *
    from   ghr_pa_routing_history prh
    where  prh.pa_request_id = p_sf52_data.pa_request_id
    and    ACTION_TAKEN = 'UPDATE_HR'
    and    APPROVAL_STATUS = 'APPROVE';
--8737212


BEGIN
    if p_sf52_data.second_noa_code =  p_first_noa_code then
      l_which_noa := 2;
      l_dual_noa_id :=  p_second_noa_id;
   elsif p_sf52_data.second_noa_code =  p_second_noa_code then
      l_which_noa := 1;
      l_dual_noa_id :=  p_first_noa_id;
   end if;
      l_ovn := p_ovn;
     hr_utility.set_location('l_ovn'||l_ovn,1);
      l_pa_request_id := ghr_approved_pa_requests.ghr_cancel_sf52(
                                    p_pa_request_id              => p_pa_request_id
                                  , p_par_object_version_number  => l_ovn
                                  , p_noa_id                     => l_dual_noa_id
                                  , p_which_noa                  => l_which_noa
                                  , p_row_id                     => p_row_id
                                  , p_username                   => fnd_profile.value('USERNAME')
                                  , p_which_action               => 'ORIGINAL'
                                  , p_cancel_legal_authority     => null
                                   );

      if c_dual_cancel%isopen then
        close c_dual_cancel;
     end if;

     open c_dual_cancel;
     fetch c_dual_cancel into l_sf52_dual_sec_rec;
     close c_dual_cancel;

     -- population of remarks 8272695
    for rec_remarks in c_get_remarks
    loop

       ghr_pa_remarks_api.create_pa_remarks
                       (p_validate                 => false
                       ,p_pa_request_id            => l_pa_request_id
                       ,p_remark_id                => rec_remarks.remark_id
                       ,p_description              => rec_remarks.description
                       ,p_remark_code_information1 => rec_remarks.remark_code_information1
                       ,p_remark_code_information2 => rec_remarks.remark_code_information2
                       ,p_remark_code_information3 => rec_remarks.remark_code_information3
                       ,p_remark_code_information4 => rec_remarks.remark_code_information4
                       ,p_remark_code_information5 => rec_remarks.remark_code_information5
                       ,p_pa_remark_id             => l_pa_remark_id
                       ,p_object_version_number    => l_object_version_number
                      );
    end loop;
  --8272695
--lac codes
    l_sf52_dual_sec_rec.first_action_la_code1 :=  p_sf52_data.first_action_la_code1;
    l_sf52_dual_sec_rec.first_action_la_code2 :=  p_sf52_data.first_action_la_code2;
    l_sf52_dual_sec_rec.first_action_la_desc1 :=  p_sf52_data.first_action_la_desc1;
    l_sf52_dual_sec_rec.first_action_la_desc2 :=  p_sf52_data.first_action_la_desc2;

     -- 8737212 Updating Routing History
     for cur_routing_history_id in C_routing_history_id loop
       l_u_pa_routing_history_id     :=  cur_routing_history_id.pa_routing_history_id;
       l_u_prh_object_version_number :=  cur_routing_history_id.object_version_number;
       exit;
     end loop;

     for rec_hist_det in c_first_routing_det
     loop
       ghr_prh_upd.upd
       (
     p_pa_routing_history_id      => l_u_pa_routing_history_id,
     p_attachment_modified_flag   => nvl(rec_hist_det.attachment_modified_flag,'N'),
     p_initiator_flag             => nvl(rec_hist_det.initiator_flag,'N'),
     p_approver_flag              => nvl(rec_hist_det.approver_flag,'N'),
     p_reviewer_flag              => nvl(rec_hist_det.reviewer_flag,'N'),
     p_requester_flag             => nvl(rec_hist_det.requester_flag,'N'),
     p_authorizer_flag            => nvl(rec_hist_det.authorizer_flag,'N'),
     p_personnelist_flag          => nvl(rec_hist_det.personnelist_flag,'N'),
     p_approved_flag              => nvl(rec_hist_det.approved_flag,'N'),
     p_user_name                  => rec_hist_det.user_name,
     p_user_name_employee_id      => rec_hist_det.user_name_employee_id,
     p_user_name_emp_first_name   => rec_hist_det.user_name_emp_first_name,
     p_user_name_emp_last_name    => rec_hist_det.user_name_emp_last_name,
     p_user_name_emp_middle_names => rec_hist_det.user_name_emp_middle_names,
     p_notepad                    => rec_hist_det.notepad,
     p_action_taken               => rec_hist_det.action_taken,
     p_noa_family_code            => l_sf52_dual_sec_rec.noa_family_code,
     p_nature_of_action_id        => l_sf52_dual_sec_rec.first_noa_id,
     p_second_nature_of_action_id => l_sf52_dual_sec_rec.second_noa_id,
     p_approval_status            => rec_hist_det.approval_status,
     p_object_version_number      => l_u_prh_object_version_number
--     p_validate                 => p_validate
     );
     exit;
     end loop;
    -- 8737212 Updating Routing History


    if  p_sf52_data.second_noa_code =  p_second_noa_code then
    hr_utility.set_location('before first process',1000);
         ghr_corr_canc_sf52.cancel_routine(p_sf52_data);
	     hr_utility.set_location('before sec process'||l_sf52_dual_sec_rec.first_noa_id,1001);
   	     hr_utility.set_location('before sec process'||l_sf52_dual_sec_rec.second_noa_id,1002);
         ghr_corr_canc_sf52.cancel_routine(l_sf52_dual_sec_rec);
    elsif p_sf52_data.second_noa_code  =  p_first_noa_code then
         ghr_corr_canc_sf52.cancel_routine(l_sf52_dual_sec_rec);
         ghr_corr_canc_sf52.cancel_routine(p_sf52_data);
    end if;

      if c_dual_first%isopen then
        close c_dual_first;
     end if;

     open c_dual_first;
     fetch c_dual_first into l_sf52_dual_first_rec;
     close c_dual_first;

     ghr_history_api.reinit_g_session_var;

       hr_utility.set_location('l_sf52_dual_sec_rec.from_position_id'||l_sf52_dual_sec_rec.from_position_id,10);
        hr_utility.set_location('l_sf52_dual_sec_rec.to_position_id'||l_sf52_dual_sec_rec.to_position_id,11);
     ghr_sf52_post_update.get_notification_details
  (p_pa_request_id                  =>  l_sf52_dual_sec_rec.pa_request_id,
   p_effective_date                 =>  l_sf52_dual_sec_rec.effective_date,
--   p_object_version_number          =>  p_imm_pa_request_rec.object_version_number,
   p_from_position_id               =>  l_sf52_dual_sec_rec.from_position_id,
   p_to_position_id                 =>  l_sf52_dual_sec_rec.to_position_id,
   p_agency_code                    =>  l_sf52_dual_sec_rec.agency_code,
   p_from_agency_code               =>  l_sf52_dual_sec_rec.from_agency_code,
   p_from_agency_desc               =>  l_sf52_dual_sec_rec.from_agency_desc,
   p_from_office_symbol             =>  l_sf52_dual_sec_rec.from_office_symbol,
   p_personnel_office_id            =>  l_sf52_dual_sec_rec.personnel_office_id,
   p_employee_dept_or_agency        =>  l_sf52_dual_sec_rec.employee_dept_or_agency,
   p_to_office_symbol               =>  l_sf52_dual_sec_rec.to_office_symbol
   );

    for c_get_ovn in get_ovn(p_pa_request_id =>  l_sf52_dual_sec_rec.pa_request_id)
    loop
       l_sf52_dual_sec_rec.object_version_number :=  c_get_ovn.object_version_number;
    end loop;

    ghr_par_upd.upd(p_pa_request_id                   => l_sf52_dual_sec_rec.pa_request_id
	    	    ,p_object_version_number          => l_sf52_dual_sec_rec.object_version_number
		    ,p_from_position_id               => l_sf52_dual_sec_rec.from_position_id
                    ,p_to_position_id                 => l_sf52_dual_sec_rec.to_position_id
                    ,p_agency_code                    => l_sf52_dual_sec_rec.agency_code
                    ,p_from_agency_code               => l_sf52_dual_sec_rec.from_agency_code
                    ,p_from_agency_desc               => l_sf52_dual_sec_rec.from_agency_desc
                    ,p_from_office_symbol             => l_sf52_dual_sec_rec.from_office_symbol
                    ,p_personnel_office_id            => l_sf52_dual_sec_rec.personnel_office_id
                    ,p_employee_dept_or_agency        => l_sf52_dual_sec_rec.employee_dept_or_agency
                    ,p_to_office_symbol               => l_sf52_dual_sec_rec.to_office_symbol
		    ,p_first_action_la_code1          => l_sf52_dual_sec_rec.first_action_la_code1
      		    ,p_first_action_la_desc1          => l_sf52_dual_sec_rec.first_action_la_desc1
		    ,p_first_action_la_code2          => l_sf52_dual_sec_rec.first_action_la_code2
                    ,p_first_action_la_desc2          => l_sf52_dual_sec_rec.first_action_la_desc2
		    ,p_approval_date                  => l_sf52_dual_first_rec.approval_date
		    ,p_approving_official_work_titl   => l_sf52_dual_first_rec.approving_official_work_title
		    ,p_approving_official_full_name   => l_sf52_dual_first_rec.approving_official_full_name
		    ,p_sf50_approval_date             => l_sf52_dual_first_rec.sf50_approval_date
		    ,p_sf50_approving_ofcl_full_nam   => l_sf52_dual_first_rec.sf50_approving_ofcl_full_name
		    ,p_sf50_approving_ofcl_work_tit   => l_sf52_dual_first_rec.sf50_approving_ofcl_work_title
                  );
   /*For dual cancellation also Maintaining RPA_TYPE and Mass action id rpa_type will be DUAL and mass action id will
     be referring other dual cancellation record*/
   GHR_APPROVED_PA_REQUESTS.Update_Dual_Id(p_parent_pa_request_id  => p_pa_request_id,
                              p_first_dual_action_id  => p_sf52_data.pa_request_id,
		    	      p_second_dual_action_id => l_pa_request_id);


END Dual_Cancel_sf52;
--6850492

--8267598
procedure reinit_dual_var is
begin
  g_dual_prior_ws := null;
  --8264475
  g_dual_first_noac := null;
  g_dual_second_noac := null;
  g_dual_action_yn := 'N';
  g_dual_prior_prd := NULL; --8268353
  --8264475

end;
--8267598

end GHR_PROCESS_SF52;


/
