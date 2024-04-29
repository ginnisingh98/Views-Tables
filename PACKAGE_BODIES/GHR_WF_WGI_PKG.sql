--------------------------------------------------------
--  DDL for Package Body GHR_WF_WGI_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_WF_WGI_PKG" AS
/* $Header: ghwfwgi.pkb 120.3 2006/05/05 04:12:20 vnarasim noship $ */
--
-- Procedure
--	StartWGIProcess
--
-- Description
--	Start the WGI workflow process for the given p_pa_request_id
--
PROCEDURE StartWGIProcess
			(	p_pa_request_id	in number,
				p_full_name		in varchar2
			) is
	--
	l_ItemType 				varchar2(30) := 'WGI';
	l_ItemKey  				varchar2(30) := p_pa_request_id;
	--
begin
	-- Added for testing
	--
	-- Creates a new runtime process for an application item (SF-52 for WGI)
	--
	wf_engine.createProcess( ItemType => l_ItemType,
					 ItemKey  => l_ItemKey,
					 process  => 'AWGI' );
	--
	--
	wf_engine.SetItemAttrText ( itemtype	=> l_ItemType,
			      		itemkey  	=> l_Itemkey,
  		 	      		aname 	=> 'PA_REQUEST_ID',
			      		avalue	=> p_pa_request_id );
	wf_engine.SetItemAttrText ( itemtype	=> l_ItemType,
			      		itemkey  	=> l_Itemkey,
  		 	      		aname 	=> 'EMP_FULL_NAME',
			      		avalue	=> p_full_name );
	--
	--
	-- Start the WGI process for the SF52 created
	--
	wf_engine.StartProcess ( ItemType => l_ItemType,
					 ItemKey  => l_ItemKey );
	--
	--
end StartWGIProcess;
--
--
procedure FindDestination( 	itemtype	in varchar2,
					itemkey  	in varchar2,
					actid		in number,
					funcmode	in varchar2,
					result	in out nocopy  varchar2	) is
--
--
--
l_user_name        		ghr_pa_routing_history.user_name%TYPE;
l_person_id				ghr_pa_requests.person_id%TYPE;
l_position_id			ghr_pa_requests.from_position_id%TYPE;
l_effective_date			ghr_pa_requests.effective_date%TYPE;
l_routing_group_id		ghr_pa_requests.routing_group_id%TYPE;
l_assignment_id			ghr_pa_requests.employee_assignment_id%TYPE;
l_full_name				per_people_f.full_name%TYPE;
l_routing_group_name		ghr_routing_groups.name%TYPE;
l_routing_group_desc		ghr_routing_groups.description%TYPE;
l_supervisor_name			ghr_pa_routing_history.user_name%TYPE;
l_groupbox_id			ghr_groupboxes.groupbox_id%TYPE;
l_groupbox_name			ghr_groupboxes.name%TYPE;
l_groupbox_desc			ghr_groupboxes.description%TYPE;
l_office_symbol_name		hr_lookups.meaning%TYPE;
l_wgi_due_date			date;
l_rating				varchar2(30);
l_multi_error_flag		boolean;
l_valid_user			boolean;
l_valid_grpbox			boolean;
l_line1				varchar2(500);
l_line2				varchar2(500);
l_line3				varchar2(500);
l_line4				varchar2(500);
l_line5				varchar2(500);
l_line6				varchar2(500);
l_line7				varchar2(500);
l_wgi_error_note		varchar2(500);
l_personnel_office_id			ghr_pa_requests.personnel_office_id%TYPE;
l_gbx_user_id                       ghr_pois.person_id%TYPE;
l_routing_group               varchar2(500);
-- NOCOPY Changes
l_result            varchar2(250);
--
--
   Cursor c_user_full_name is
     Select      ppf.full_name
     from        per_people_f ppf
     where       ppf.person_id =
        (select  employee_id
         from    fnd_user
         where   user_name = l_user_name
         )
      and        l_effective_date
      between    ppf.effective_start_date and ppf.effective_end_date;
begin
-- NOCOPY Changes
l_result := result;
--
if funcmode = 'RUN' then
      wf_engine.SetItemAttrText (itemtype	=> ItemType,
	      			itemkey  	=> Itemkey,
	 	      		aname 	=> 'ERROR_MSG',
		      		avalue	=> '' );
      --
      --	Get Person ID and effective date from PA requests table
	get_par_details	 (
						 p_pa_request_id  => itemkey
				   		,p_person_id      => l_person_id
				   		,p_effective_date => l_effective_date
		   				,p_position_id    => l_position_id
		   	    	);
 	--Find supervisor name of WF user
	l_user_name := get_next_approver (
						 	 p_person_id      => l_person_id
							,p_effective_date => l_effective_date
						   );
	-- Set item attributes
	if l_user_name Is Not Null then
         -- Get Full Name of the user
           for full_name_rec in c_user_full_name loop
             l_full_name := full_name_rec.full_name;
           end loop;

	   wf_engine.SetItemAttrText	(  	itemtype => Itemtype,
					     		itemkey  => Itemkey,
					     		aname    => 'FWD_SUP_NAME',
					     		avalue   => l_user_name || ' - ' || l_full_name
						);
	else
  	   wf_engine.SetItemAttrText ( itemtype	=> ItemType,
		      			itemkey  	=> Itemkey,
  		 	      		aname 	=> 'ERROR_MSG',
			      		avalue	=> 'Supervisor does not exist or is invalid for this Employee. ');
	end if;
	-- Get employees personnel groupbox
	if l_position_id Is not Null then
	   Get_emp_personnel_groupbox   (  p_position_id		=> l_position_id
						    ,p_effective_date		=> l_effective_date
                 			          ,p_groupbox_name		=> l_groupbox_name
						    ,p_personnel_office_id    => l_personnel_office_id
                                        ,p_gbx_user_id            => l_gbx_user_id
						   );
  	   wf_engine.SetItemAttrText ( itemtype	=> ItemType,
		      			itemkey  	=> Itemkey,
  		 	      		aname 	=> 'POI',
			      		avalue	=> l_personnel_office_id);
	else
	   wf_engine.SetItemAttrText ( itemtype	=> ItemType,
			      			itemkey  	=> Itemkey,
	  		 	      		aname 	=> 'ERROR_MSG',
				      		avalue	=> 'Position ID does not exist for this Employee. '
						 );
	   result := 'COMPLETE:NO';
	   return;
	end if;
	-- Verify whether valid workflow user
      l_valid_user	:=	VerifyValidWFUser	(
						 		p_user_name	=>	l_user_name
								);
	-- Verify whether valid groupbox
      l_valid_grpbox	:=	VerifyValidWFUser	(
						 		p_user_name	=>	l_groupbox_name
								);
	if l_groupbox_name Is Not Null then
	   wf_engine.SetItemAttrText	(
	 						itemtype => Itemtype,
					     		itemkey  => Itemkey,
					     		aname    => 'PERSONNEL_OFFICE_GBX',
					     		avalue   => l_groupbox_name
						  );
      l_wgi_error_note     := 'Please process the WGI Request for Personnel Action manually
                                which has been routed to your Personnel office  Groupbox :' || l_groupbox_name;
      end if;
	if l_valid_grpbox then
	   GetRoutingGroupDetails (
					   p_groupbox_name      => l_groupbox_name
					  ,p_groupbox_id        => l_groupbox_id
					  ,p_routing_group_id   => l_routing_group_id
					  ,p_groupbox_desc      => l_groupbox_desc
                                ,p_routing_group_name => l_routing_group_name
                                ,p_routing_group_desc => l_routing_group_desc
					  );
      else
	   wf_engine.SetItemAttrText( itemtype	=> ItemType,
			      		itemkey  	=> Itemkey,
	  		 	      	aname 	=> 'ERROR_MSG',
				      	avalue	=> 'Groupbox is not valid or invalid for this Employee. ' );
	end if;
      if l_routing_group_id is not null then
         update_sf52_action_taken(p_pa_request_id  	=> itemkey,
					    p_routing_group_id	=> l_routing_group_id,
					    p_groupbox_id		=> l_groupbox_id,
					    p_action_taken	=> 'NOT_ROUTED',
                                  p_gbx_user_id       => l_gbx_user_id);
      else
  	  wf_engine.SetItemAttrText ( itemtype	=> ItemType,
		      			itemkey  	=> Itemkey,
  		 	      		aname 	=> 'ERROR_MSG',
			      		avalue	=> 'Routing group does not exist for this Employee. ' );
      end if;
      SetDestination(	 p_request_id		=>	itemkey
				,p_person_id		=>	l_person_id
				,p_position_id		=>	l_position_id
				,p_effective_date 	=>	l_effective_date
				,p_office_symbol_name	=>	l_office_symbol_name
				,p_line1			=>	l_line1
				,p_line2			=>	l_line2
				,p_line3			=>	l_line3
				,p_line4			=>	l_line4
				,p_line5			=>	l_line5
				,p_line6			=>	l_line6
				,p_line7			=>	l_line7
                        ,p_routing_group        =>    l_routing_group
			);
	wf_engine.SetItemAttrText	(
	 						itemtype => Itemtype,
					     		itemkey  => Itemkey,
					     		aname    => 'LINE1',
					     		avalue   => l_line1
						  );
	wf_engine.SetItemAttrText	(
	 						itemtype => Itemtype,
					     		itemkey  => Itemkey,
					     		aname    => 'LINE2',
					     		avalue   => l_line2
						  );
	wf_engine.SetItemAttrText	(
	 						itemtype => Itemtype,
					     		itemkey  => Itemkey,
					     		aname    => 'LINE3',
					     		avalue   => l_line3
						  );
	wf_engine.SetItemAttrText	(
	 						itemtype => Itemtype,
					     		itemkey  => Itemkey,
					     		aname    => 'LINE4',
					     		avalue   => l_line4
						  );
      wf_engine.SetItemAttrText	(
	 						itemtype => Itemtype,
					     		itemkey  => Itemkey,
					     		aname    => 'LINE5',
					     		avalue   => l_line5
						  );
      wf_engine.SetItemAttrText	(
	 						itemtype => Itemtype,
					     		itemkey  => Itemkey,
					     		aname    => 'LINE6',
					     		avalue   => l_line6
						  );
      wf_engine.SetItemAttrText	(
	 						itemtype => Itemtype,
					     		itemkey  => Itemkey,
					     		aname    => 'LINE7',
					     		avalue   => l_line7
						  );

      wf_engine.SetItemAttrText	(
	 						itemtype => Itemtype,
					     		itemkey  => Itemkey,
					     		aname    => 'WGI_ERROR_NOTE',
					     		avalue   => l_wgi_error_note
						  );
      wf_engine.SetItemAttrText(      itemtype => Itemtype,
                                      itemkey  => Itemkey,
                                      aname    => 'FROM_NAME',
                                      avalue   =>  FND_GLOBAL.USER_NAME() );
      wf_engine.SetItemAttrText	(
							itemtype => Itemtype,
							itemkey  => Itemkey,
			   		  		aname    => 'OFFICE_SYMBOL',
			 				avalue   => l_office_symbol_name
						  );
      wf_engine.SetItemAttrText	(
							itemtype => Itemtype,
							itemkey  => Itemkey,
			   		  		aname    => 'ROUTING_GROUP',
			 				avalue   => l_routing_group
						  );
      if ((l_valid_user ) and (l_valid_grpbox)) then
 	   result := 'COMPLETE:YES';
	   return;
	elsif ((NOT l_valid_user) and (NOT l_valid_grpbox)) then
         wf_engine.SetItemAttrText	(  	itemtype => Itemtype,
					     		itemkey  => Itemkey,
					     		aname    => 'ERROR_MSG',
					     		avalue   => 'Supervisor and Groupbox for the employee are invalid. ');
	   result := 'COMPLETE:NO';
	   return;
      else
	   result := 'COMPLETE:NO';
	   return;
      end if;
--
--
--
elsif ( funcmode = 'CANCEL' ) then
		result := 'COMPLETE:NO';
		return;
--
--
end if;
--
  result := '';
  return;
--
--
exception
  when others then
    -- NOCOPY Changes
    result := l_result;
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('WGI', 'ghr_wf_wgi_pkg.FindDestination',itemtype, itemkey, to_char(actid), funcmode);
    raise;
--
end FindDestination;
--
--
procedure approval_required( 	itemtype	in varchar2,
					itemkey  	in varchar2,
					actid		in number,
					funcmode	in varchar2,
					result	in out nocopy  varchar2	) is
--
l_text	varchar2(30);
l_result varchar2(250);
--
--
begin
-- NOCOPY Changes
   l_result := result;
--
   if funcmode = 'RUN' then
	   l_text	:=  wf_engine.GetItemAttrText(	itemtype => Itemtype,
								  	itemkey  => Itemkey,
								  	aname    => 'APPROVAL_REQUIRED');
	   if l_text = 'NO' then
		result := 'COMPLETE:NO';
		return;
	   else
		result := 'COMPLETE:YES';
		return;
	   end if;
   end if;
--
  result := '';
  return;
--
--
exception
  when others then
    -- NOCOPY Changes
    result := l_result;
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('WGI', 'ghr_wf_wgi_pkg.approval_required',itemtype, itemkey, to_char(actid), funcmode);
    raise;
--
--
end approval_required;
--
--
--
PROCEDURE GetRoutingGroupDetails (
					  p_groupbox_name		IN  varchar2,
					  p_groupbox_id		    out nocopy  number,
					  p_routing_group_id	out nocopy  number,
					  p_groupbox_desc 	    out nocopy  varchar2,
                      p_routing_group_name	out nocopy  varchar2,
                      p_routing_group_desc	out nocopy  varchar2
					  ) IS
-- Local variables
l_groupbox_id			ghr_groupboxes.groupbox_id%TYPE;
l_groupbox_name			ghr_groupboxes.name%TYPE;
l_groupbox_desc			ghr_groupboxes.name%TYPE;
l_routing_group_id		ghr_groupboxes.routing_group_id%TYPE;
l_routing_group_name		ghr_routing_groups.name%TYPE;
l_routing_group_desc		ghr_routing_groups.description%TYPE;
--
--
  cursor csr_gbx is
    select  gbx.groupbox_id, gbx.routing_group_id, gbx.name, rgp.name , rgp.description
    from    ghr_groupboxes gbx, ghr_routing_groups rgp
    where   gbx.name = l_groupbox_name
	      and gbx.routing_group_id = rgp.routing_group_id;
--
begin
--
--
	l_groupbox_name := p_groupbox_name;
	open csr_gbx;
  -- fetch the candidate details
  fetch csr_gbx into l_groupbox_id, l_routing_group_id, l_groupbox_name, l_routing_group_name, l_routing_group_desc;
  if csr_gbx%notfound then
    -- if the cursor does not return a row then we must set the out
    -- parameter to null
    p_routing_group_id := null;
    p_routing_group_name := null;
    p_routing_group_desc := null;
    p_groupbox_desc := null;
    p_groupbox_id := null;
  else
    p_routing_group_id := l_routing_group_id;
    p_routing_group_name := l_routing_group_name;
    p_routing_group_desc := l_routing_group_desc;
    p_groupbox_desc := l_groupbox_desc;
    p_groupbox_id := l_groupbox_id;
  end if;
  -- close the cursor
  close csr_gbx;
exception
	when others then
    p_routing_group_id := null;
    p_routing_group_name := null;
    p_routing_group_desc := null;
    p_groupbox_desc := null;
    p_groupbox_id := null;
    raise;
end GetRoutingGroupDetails;
--
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< get_next_approver >------------------------|
-- ----------------------------------------------------------------------------
function get_next_approver
           (p_person_id in per_people_f.person_id%type,
		p_effective_date in ghr_pa_requests.effective_date%TYPE
		)
	          return ghr_pa_routing_history.user_name%TYPE  is
--
l_in_person_id			ghr_pa_requests.person_id%TYPE;
l_effective_date			ghr_pa_requests.effective_date%TYPE;
l_out_person_name 		ghr_pa_routing_history.user_name%TYPE;
--
  cursor csr_pa is
    select  substr(usr.user_name,1,30) user_name
    from    per_assignments_f paf
           ,per_people_f      ppf
	     ,fnd_user	      usr
    where   paf.person_id             = l_in_person_id
    and     paf.primary_flag          = 'Y'
    and     p_effective_date
    between paf.effective_start_date
    and     paf.effective_end_date
    and     ppf.person_id             = paf.supervisor_id
    and     ppf.current_employee_flag = 'Y'
    and     p_effective_date
    between ppf.effective_start_date
    and     ppf.effective_end_date
    and     ppf.person_id = usr.employee_id;
--
--
--
begin
  -- [CUSTOMIZE]
  -- open the candidate select cursor
  l_in_person_id := p_person_id;
  l_effective_date := p_effective_date;
  open csr_pa;
  -- fetch the candidate details
  fetch csr_pa into l_out_person_name;
  if csr_pa%notfound then
    -- if the cursor does not return a row then we must set the out
    -- parameter to null
    l_out_person_name := null;
  end if;
  -- close the cursor
  close csr_pa;
  return(l_out_person_name);
end get_next_approver;
--
--
PROCEDURE Get_emp_personnel_groupbox (
					  p_position_id   	IN  number,
					  p_effective_date      IN date,
                      p_groupbox_name 	out nocopy  varchar2,
					  p_personnel_office_id out nocopy  ghr_pa_requests.personnel_office_id%TYPE,
                      p_gbx_user_id         out nocopy  ghr_pois.person_id%TYPE
					  ) IS
--
-- Local variables
--
l_groupbox_name				ghr_groupboxes.name%TYPE;
--
l_flsa_category                     ghr_pa_requests.flsa_category%TYPE;
l_bargaining_unit_status            ghr_pa_requests.bargaining_unit_status%TYPE;
l_work_schedule				ghr_pa_requests.work_schedule%TYPE;
l_functional_class                  ghr_pa_requests.functional_class%TYPE;
l_supervisory_status      		ghr_pa_requests.supervisory_status%TYPE;
l_position_occupied			ghr_pa_requests.position_occupied%TYPE;
l_appropriation_code1			ghr_pa_requests.appropriation_code1%TYPE;
l_appropriation_code2  			ghr_pa_requests.appropriation_code2%TYPE;
l_personnel_office_id			ghr_pa_requests.personnel_office_id%TYPE;
l_from_office_symbol			ghr_pa_requests.from_office_symbol%TYPE;
l_part_time_hours        		ghr_pa_requests.part_time_hours%TYPE;
l_gbx_user_id                       ghr_pois.person_id%TYPE;
--
--
cursor csr_poi_code is
      SELECT gbx.name ,poi.person_id
      from ghr_groupboxes gbx, ghr_pois poi
      WHERE gbx.groupbox_id (+)  = nvl(poi.groupbox_id,-9999999)
      AND poi.personnel_office_id = nvl(l_personnel_office_id,-99999999);
--
begin
--
   ghr_pa_requests_pkg.get_SF52_pos_ddf_details
    						(p_position_id            =>  p_position_id
						,p_date_effective		  =>  trunc(p_effective_date)
     						,p_flsa_category          =>  l_flsa_category
					      ,p_bargaining_unit_status =>  l_bargaining_unit_status
    				    	      ,p_work_schedule          =>  l_work_schedule
				  	      ,p_functional_class       =>  l_functional_class
 				   	      ,p_supervisory_status     =>  l_supervisory_status
			     		      ,p_position_occupied      =>  l_position_occupied
			     	      	,p_appropriation_code1    =>  l_appropriation_code1
	 			     	      ,p_appropriation_code2    =>  l_appropriation_code2
						,p_personnel_office_id    =>  l_personnel_office_id
						,p_office_symbol		  =>  l_from_office_symbol
				     	      ,p_part_time_hours        =>  l_part_time_hours);
--
  if l_personnel_office_id Is Null then
	  p_groupbox_name  := null;
	  p_personnel_office_id  := null;
  else
	open csr_poi_code;
      fetch csr_poi_code into l_groupbox_name, l_gbx_user_id;
	if csr_poi_code%notfound then
	    p_groupbox_name := null;
	else
	    p_groupbox_name := l_groupbox_name;
	end if;
      p_personnel_office_id  := l_personnel_office_id;
      p_gbx_user_id := l_gbx_user_id;
	close csr_poi_code;
  end if;
--
exception
    WHEN OTHERS THEN
      p_groupbox_name  := null;
	  p_personnel_office_id  := null;
      p_gbx_user_id := null;
      raise;
end Get_emp_personnel_groupbox;
--
--
--
PROCEDURE Get_par_details (
				    p_pa_request_id	in  number
				   ,p_person_id		out nocopy  number
				   ,p_effective_date	out nocopy  date
				   ,p_position_id		out nocopy  number
				   ) IS
--
-- Local variables
--
l_pa_request_id		ghr_pa_requests.pa_request_id%TYPE;
l_person_id			ghr_pa_requests.person_id%TYPE;
l_effective_date		ghr_pa_requests.effective_date%TYPE;
l_position_id		ghr_pa_requests.from_position_id%TYPE;
--
  cursor csr_par is
    select  person_id, effective_date, from_position_id
    from    ghr_pa_requests par
    where   par.pa_request_id = l_pa_request_id;
--
begin
--
--
	l_pa_request_id := p_pa_request_id;
	open csr_par;
  -- fetch the position extra info details
  fetch csr_par into l_person_id , l_effective_date, l_position_id;
  if csr_par%notfound then
    -- if the cursor does not return a row then we must set the out
    -- parameter to null
    p_person_id  := null;
    p_effective_date  := null;
    p_position_id := null;
  else
    p_person_id  := l_person_id;
    p_effective_date  := l_effective_date;
    p_position_id := l_position_id;
  end if;
  close csr_par;
-- NOCOPY Changes. Added exception.
EXCEPTION
    WHEN OTHERS THEN
        p_person_id		 := NULL;
		p_effective_date := NULL;
		p_position_id	 := NULL;
        raise;
end Get_par_details;
--
--
PROCEDURE PersonnelGrpBoxExists	(itemtype	in varchar2,
						itemkey  	in varchar2,
						actid		in number,
						funcmode	in varchar2,
						result	in out nocopy  varchar2
						) is
   l_text	varchar2(80);
   l_result VARCHAR2(250);
Begin
    -- NOCOPY Changes
    l_result := result;
if funcmode = 'RUN' then
   l_text	:=  wf_engine.GetItemAttrText(	itemtype => Itemtype,
							  	itemkey  => Itemkey,
							  	aname    => 'PERSONNEL_OFFICE_GBX');
   if l_text is NULL then
      ghr_wgi_pkg.create_ghr_errorlog(
				p_program_name  =>  'PersonnelGrpBoxExists',
                  	p_log_text      =>  'Itemtype: '||itemtype||' Itemkey: '||itemkey||'Group Box Id does not exist',
	                  p_message_name  =>  null,
	                  p_log_date      =>  sysdate );
      result := 'COMPLETE:NO';
      return;
   else
      result := 'COMPLETE:YES';
      return;
   end if;
end if;
  --
  -- Other execution modes may be created in the future.
  -- Activity indicates that it does not implement a mode
  -- by returning null
  --
  result := '';
  return;
--
exception
  when others then
    -- NOCOPY Changes
       result := l_result;
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('WGI', 'ghr_wf_pd_pkg.PersonnelGrpBoxExists',itemtype, itemkey, to_char(actid), funcmode);
    raise;
--
--
End PersonnelGrpBoxExists;
--
--
Procedure StartSF52Process(	itemtype	in varchar2,
					itemkey  	in varchar2,
					actid		in number,
					funcmode	in varchar2,
					result	in out nocopy  varchar2
				  ) is
l_grpbox_name        		ghr_pa_routing_history.user_name%TYPE;
l_error_msg  varchar2(1000);
l_result     VARCHAR2(250);
 Begin
   l_result := result;
   if funcmode = 'RUN' then
	   l_error_msg := wf_engine.GetItemAttrText (
							itemtype => Itemtype,
					     		itemkey  => Itemkey,
					     		aname    => 'ERROR_MSG'
						          );
	    ghr_api.call_workflow	(
					 P_PA_REQUEST_ID		=> 	itemkey,
					 P_ACTION_TAKEN         =>	'CONTINUE',
					 P_OLD_ACTION_TAKEN     =>    NULL,
					 P_ERROR                =>    l_error_msg
					);
	    result	:= 'COMPLETE:YES';
            return;
   end if;
  --
  -- Other execution modes may be created in the future.
  -- Activity indicates that it does not implement a mode
  -- by returning null
  --
  result := '';
  return;
--
exception
  when others then
    -- NOCOPY Changes
    result := l_result;
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('WGI', 'ghr_wf_pd_pkg.StartSF52Process',itemtype, itemkey, to_char(actid), funcmode);
    raise;
--
End StartSF52Process;
--
--
Procedure CancelSF52Process(	itemtype	in  varchar2,
					itemkey  	in  varchar2,
					actid		in  number,
					funcmode	in  varchar2,
					result	in out nocopy  varchar2
				  ) is
	cursor c1 is
		select object_version_number
		from   ghr_pa_requests
		where  pa_request_id = itemkey;
		l_ovn	ghr_pa_requests.object_version_number%type;
    l_result     VARCHAR2(250);

Begin
   l_result := result;
   if funcmode = 'RUN' then
	   open c1;
	   fetch c1 into l_ovn;
	   close c1;
	   ghr_sf52_api.end_sf52	(	p_pa_request_id			=> itemkey,
 						p_action_taken			=> 'CANCELED',
						p_par_object_version_number	=> l_ovn
					);
	   result	:= 'COMPLETE:YES';
   end if;
--
  --
  -- Other execution modes may be created in the future.
  -- Activity indicates that it does not implement a mode
  -- by returning null
  --
  result := '';
  return;
--
exception
  when others then
    -- NOCOPY Changes
    result := l_result;
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('WGI', 'ghr_wf_pd_pkg.CancelSF52Process',itemtype, itemkey, to_char(actid), funcmode);
    raise;
--
End CancelSF52Process;
--
--
Function VerifyValidWFUser	(p_user_name	in	varchar2)
				return boolean is
   l_temp	char;
   cursor	c1(p_user_name varchar2) is
		select  'X'
		from    wf_roles
		where   name = p_user_name;
begin
   open c1(p_user_name);
   fetch c1 into l_temp;
   if c1%NOTFOUND then
      close c1;
      return(FALSE);
   else
      close c1;
      return(TRUE);
   end if;
end VerifyValidWFUser;
--
--
PROCEDURE SetDestination(	 p_request_id		in	varchar2
					,p_person_id		in	varchar2
					,p_position_id		in	varchar2
					,p_effective_date 	in	date
					,p_office_symbol_name	out nocopy 	varchar2
					,p_line1			out nocopy    varchar2
					,p_line2			out nocopy    varchar2
					,p_line3			out nocopy    varchar2
					,p_line4			out nocopy    varchar2
					,p_line5			out nocopy    varchar2
					,p_line6			out nocopy    varchar2
					,p_line7			out nocopy    varchar2
                    ,p_routing_group    out nocopy    varchar2
					) is

   l_line1			varchar2(500);
   l_line2			varchar2(500);
   l_line3			varchar2(500);
   l_line4			varchar2(500);
   l_line5			varchar2(500);
   l_line6			varchar2(500);
   l_line7			varchar2(500);
   l_office_symbol_id	varchar2(30);
   l_office_symbol_name	varchar2(80);
   l_retained_grade_rec	ghr_pay_calc.retained_grade_rec_type;
   l_ret_grade		ghr_pa_requests.from_grade_or_level%type;
   l_cur_grade		ghr_pa_requests.from_grade_or_level%type;
   l_ret_pay_plan		varchar2(30);
   l_cur_pay_plan		varchar2(30);
   l_cur_step_rate	ghr_pa_requests.from_step_or_rate%type;
   l_ret_step_rate	ghr_pa_requests.from_step_or_rate%type;
   l_rating_id		per_analysis_criteria.segment2%type;
   l_rating			ghr_pa_request_extra_info.rei_information3%type;
   l_rating_date		varchar2(30);
   l_wgi_date		varchar2(30);
   l_new_step		ghr_pa_requests.to_step_or_rate%type;
   l_new_sal		ghr_pa_requests.to_total_salary%type;
   l_positionei_rec	per_position_extra_info%rowtype;
   l_special_info		ghr_api.special_information_type;
   l_routing_group_id	ghr_pa_requests.routing_group_id%TYPE;
   l_routing_group_name	ghr_routing_groups.name%TYPE;
   l_rgp_description    ghr_routing_groups.description%TYPE;
--
--
  cursor csr_lkp_code(	l_type	in	varchar2,
				l_code	in	varchar2) is
    select  fcl.meaning
    from    hr_lookups fcl
    where   fcl.lookup_type         = l_type
    and     fcl.lookup_code         = l_code
    and     fcl.enabled_flag        = 'Y'
    and     nvl(p_effective_date,trunc(sysdate))
    	between nvl(fcl.start_date_active,nvl(p_effective_date,trunc(sysdate)))
      and     nvl(fcl.end_date_active,  nvl(p_effective_date,trunc(sysdate)));
 --
  cursor    cur_pay_plan is
    select  from_pay_plan,
 		from_grade_or_level,
		from_step_or_rate,
		to_step_or_rate,
		to_total_salary
    from    ghr_pa_requests
    where   pa_request_id	= p_request_id;
--
  cursor    cur_par_extra is
    select  rei_information3,
            rei_information9
    from    ghr_pa_request_extra_info
    where   pa_request_id = p_request_id
            and information_type = 'GHR_US_PAR_PERF_APPRAISAL';
--
--
cursor csr_rgp is
     SELECT rgp.name, rgp.description
     FROM ghr_routing_groups rgp, ghr_pa_requests par
     WHERE par.pa_request_id = p_request_id
     and   par.routing_group_id = rgp.routing_group_id;
--
Begin
   ghr_history_fetch.fetch_positionei(	p_position_id		=> p_position_id,
							p_information_type 	=> 'GHR_US_POS_GRP1',
							p_date_effective		=> p_effective_date,
							p_pos_ei_data		=> l_positionei_rec
						  );
   l_office_symbol_id := l_positionei_rec.poei_information3;

   if l_office_symbol_id is not null then
      open csr_lkp_code('GHR_US_OFFICE_SYMBOL', l_office_symbol_id);
      fetch csr_lkp_code into l_office_symbol_name;
      if csr_lkp_code%FOUND then
         p_office_symbol_name	:= 'Office Symbol : ' || l_office_symbol_name;
	end if;
      close csr_lkp_code;
   end if;
   --
   -- get retained details
   --
   begin
	l_retained_grade_rec	:= ghr_pc_basic_pay.get_retained_grade_details
	               				(p_person_id      => p_person_id
				      		,p_effective_date => p_effective_date);
      exception
         When ghr_pay_calc.pay_calc_message then
         null;
   end;
   --
   -- Get Performance ratings
   --
   --  Get it from GHR_US_PAR_PERF_APPRAISAL
      open cur_par_extra;
      fetch cur_par_extra into l_rating_id,l_rating_date;
      close cur_par_extra;
   --
   if l_rating_id is not null then
      open csr_lkp_code('GHR_US_RATING_OF_RECORD', l_rating_id);
      fetch csr_lkp_code into l_rating;
      close csr_lkp_code;
   end if;
   --
   open csr_rgp;
   fetch csr_rgp  into
            l_routing_group_name,
            l_rgp_description;
   close csr_rgp;
   --

   open cur_pay_plan;
   fetch cur_pay_plan into
			l_cur_pay_plan,
			l_cur_grade,
			l_cur_step_rate,
			l_new_step,
			l_new_sal;
   close cur_pay_plan;

   l_wgi_date		:= to_char(p_effective_date, 'YYYY/MM/DD');
/*
   l_cur_pay_plan 	:= rpad(nvl(l_cur_pay_plan,' '), 5, ' ');
   l_cur_grade  		:= rpad(nvl(l_cur_grade, ' '), 5, ' ');
   l_cur_step_rate	:= rpad(nvl(l_cur_step_rate,' '), 5, ' ');
*/
   -- WF Changes  ADDED THE FOLLOWING IF CONDITION.
   IF l_retained_grade_rec.pay_plan IS NULL  AND
      l_retained_grade_rec.grade_or_level IS NULL AND
      l_retained_grade_rec.pay_plan  IS NULL  AND
      l_retained_grade_rec.grade_or_level IS NULL  AND
      l_retained_grade_rec.step_or_rate   IS NULL  AND
      l_retained_grade_rec.pay_basis      IS NULL  AND
      l_retained_grade_rec.user_table_id  IS NULL  AND
      l_retained_grade_rec.locality_percent IS NULL  THEN


      l_line1 :=  l_cur_pay_plan || '-' || l_cur_grade;-- WF Changes
      l_line7 :=  l_new_step;
   ELSE
	l_line1 := l_retained_grade_rec.pay_plan || '-' || l_retained_grade_rec.grade_or_level;
	IF l_retained_grade_rec.temp_step IS NOT NULL THEN
	   l_line7 := l_retained_grade_rec.temp_step;
	ELSE
	   l_line7 := l_retained_grade_rec.step_or_RATE;
	END IF;
   END IF;

--   l_line1 :=  l_cur_pay_plan || '-' || l_cur_grade || '-' || l_cur_step_rate;-- WF Changes
   l_line2 :=  l_retained_grade_rec.pay_plan || '-' || l_retained_grade_rec.grade_or_level || '-' || l_retained_grade_rec.step_or_rate ;
   l_line3 :=  l_rating; -- Performance Rating
   l_line4 :=  fnd_date.date_to_displaydate(fnd_date.canonical_to_date(l_rating_date)); -- Date Effective
   l_line5  := fnd_date.date_to_displaydate(fnd_date.canonical_to_date(l_wgi_date));  -- WGI Pay Date
   l_line6  := l_new_sal;  -- New Salary
  --WF changes Change this line7 to pick temp step/reteained step/step in position.
  -- l_line7  := l_new_step;  -- New Step

   p_line1   		:= l_line1;
   p_line2   		:= l_line2;
   p_line3   		:= l_line3;
   p_line4   		:= l_line4;
   p_line5   		:= l_line5;
   p_line6   		:= l_line6;
   p_line7   		:= l_line7;
   p_routing_group      := l_routing_group_name || ' - ' || l_rgp_description;
   --
Exception
    -- NOCOPY Changes.
    WHEN OTHERS THEN
        p_office_symbol_name	:= NULL;
		p_line1			:= NULL;
		p_line2			:= NULL;
		p_line3			:= NULL;
		p_line4			:= NULL;
		p_line5			:= NULL;
		p_line6			:= NULL;
		p_line7			:= NULL;
        p_routing_group := NULL;
        raise;
End SetDestination;
--
--
--
PROCEDURE UpdateRoutingHistory( itemtype	in varchar2,
					  itemkey  	in varchar2,
					  actid	in number,
					  funcmode	in varchar2,
					  result	in out nocopy  varchar2) is
Begin
   NULL;
End UpdateRoutingHistory;
--
--
--
PROCEDURE CallUpdateToHR( itemtype	in varchar2,
				  itemkey  	in varchar2,
				  actid	in number,
				  funcmode	in varchar2,
				  result	in out nocopy  varchar2) is
-- NOCOPY Changes
l_result VARCHAR2(250);
begin
    -- NOCOPY Changes
    l_result := result;
	if funcmode = 'RUN' then
	   --Submit to Update to HR
         update_sf52_action_taken(p_pa_request_id	=> itemkey,
					    p_routing_group_id	=> '',
					    p_groupbox_id		=> '',
					    p_action_taken	=> 'UPDATE_HR',
                                  p_gbx_user_id       => '');
	   result := 'COMPLETE:YES';
	   return;
      end if;
--
  result := '';
  return;
--
	exception
	   when others then
         -- NOCOPY Changes
         result := l_result;
	  	  wf_engine.SetItemAttrText ( itemtype	=> ItemType,
			      			itemkey  	=> Itemkey,
	  		 	      		aname 	=> 'ERROR_MSG',
				      		avalue	=> 'Update to HR failed. ' || substr(sqlerrm,1,1000) );
        result := 'COMPLETE:NO';
--
end CallUpdateToHR;
--
--
PROCEDURE EndWGIProcess( itemtype	in  varchar2,
				  itemkey  	in  varchar2,
				  actid	in  number,
				  funcmode	in  varchar2,
				  result	in out nocopy  varchar2) is
    -- NOCOPY Changes
    l_result VARCHAR2(250);
begin
-- NOCOPY Changes
l_result := result;
if funcmode = 'RUN' then
    result := 'COMPLETE:COMPLETED';
    return;
end if;
  --
  --
  -- Other execution modes may be created in the future.
  -- Activity indicates that it does not implement a mode
  -- by returning null
  --
  result := '';
  return;
--
exception
  when others then
    -- NOCOPY Changes
    result := l_result;
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('WGI', 'ghr_wf_pd_pkg.EndWGIProcess',itemtype, itemkey, to_char(actid), funcmode);
    raise;
--
end EndWGIProcess;
--
--
procedure update_sf52_action_taken(p_pa_request_id	in  ghr_pa_requests.pa_request_id%TYPE
					    ,p_routing_group_id in  ghr_pa_requests.routing_group_id%type
					    ,p_groupbox_id	in  ghr_pa_routing_history.groupbox_id%type
					    ,p_action_taken	in  ghr_pa_routing_history.action_taken%TYPE
                                  ,p_gbx_user_id      in  ghr_pois.person_id%TYPE)
 is
--
    Cursor c_fnd_sessions is
       Select 1
       From   fnd_sessions
       where  session_id = userenv('sessionid');
-- Local variables
--
        l_exists                                        boolean := false;
	l_validate	   				boolean := false;
	l_noa_family_code	   			ghr_pa_requests.noa_family_code%TYPE;
	l_routing_group_id	   		ghr_pa_requests.routing_group_id%TYPE;
	l_par_object_version_number	   	ghr_pa_requests.object_version_number%TYPE;
	l_proposed_effective_asap_flag 	ghr_pa_requests.proposed_effective_asap_flag%TYPE;
	l_academic_discipline	   		ghr_pa_requests.academic_discipline%TYPE;
	l_additional_info_person_id	   	ghr_pa_requests.additional_info_person_id%TYPE;
	l_additional_info_tel_number  	ghr_pa_requests.additional_info_tel_number%TYPE;
	l_altered_pa_request_id	   		ghr_pa_requests.altered_pa_request_id%TYPE;
	l_annuitant_indicator	   		ghr_pa_requests.annuitant_indicator%TYPE;
	l_annuitant_indicator_desc	   	ghr_pa_requests.annuitant_indicator_desc%TYPE;
	l_appropriation_code1	   		ghr_pa_requests.appropriation_code1%TYPE;
	l_appropriation_code2	   		ghr_pa_requests.appropriation_code2%TYPE;
	l_authorized_by_person_id	   	ghr_pa_requests.authorized_by_person_id%TYPE;
	l_authorized_by_title	   		ghr_pa_requests.authorized_by_title%TYPE;
	l_award_amount	   			ghr_pa_requests.award_amount%TYPE;
	l_award_uom	   				ghr_pa_requests.award_uom%TYPE;
  	l_bargaining_unit_status	   	ghr_pa_requests.bargaining_unit_status%TYPE;
  	l_citizenship	   			ghr_pa_requests.citizenship%TYPE;
	l_concurrence_date	   		ghr_pa_requests.concurrence_date%TYPE;
      l_custom_pay_calc_flag      		ghr_pa_requests.custom_pay_calc_flag%TYPE;
	l_duty_station_code	   		ghr_pa_requests.duty_station_code%TYPE;
	l_duty_station_desc	   		ghr_pa_requests.duty_station_desc%TYPE;
	l_duty_station_id	   			ghr_pa_requests.duty_station_id%TYPE;
	l_duty_station_location_id	   	ghr_pa_requests.duty_station_location_id%TYPE;
	l_education_level	   			ghr_pa_requests.education_level%TYPE;
  	l_effective_date	   			ghr_pa_requests.effective_date%TYPE;
  	l_employee_assignment_id	   	ghr_pa_requests.employee_assignment_id%TYPE;
 	l_employee_date_of_birth	   	ghr_pa_requests.employee_date_of_birth%TYPE;
	l_employee_first_name	   		ghr_pa_requests.employee_first_name%TYPE;
  	l_employee_last_name	   		ghr_pa_requests.employee_last_name%TYPE;
  	l_employee_middle_names	   		ghr_pa_requests.employee_middle_names%TYPE;
 	l_employee_national_identifier 	ghr_pa_requests.employee_national_identifier%TYPE;
	l_fegli	   				ghr_pa_requests.fegli%TYPE;
	l_fegli_desc	   			ghr_pa_requests.fegli_desc%TYPE;
      l_first_action_la_code1			ghr_pa_requests.first_action_la_code1%TYPE;
      l_first_action_la_code2    		ghr_pa_requests.first_action_la_code2%TYPE;
      l_first_action_la_desc1			ghr_pa_requests.first_action_la_desc1%TYPE;
      l_first_action_la_desc2			ghr_pa_requests.first_action_la_desc2%TYPE;
	l_first_noa_cancel_or_correct 	ghr_pa_requests.first_noa_cancel_or_correct%TYPE;
      l_first_noa_code				ghr_pa_requests.first_noa_code%TYPE;
      l_first_noa_desc				ghr_pa_requests.first_noa_desc%TYPE;
	l_first_noa_id	   			ghr_pa_requests.first_noa_id%TYPE;
	l_first_noa_pa_request_id	   	ghr_pa_requests.first_noa_pa_request_id%TYPE;
	l_flsa_category	   			ghr_pa_requests.flsa_category%TYPE;
	l_forwarding_address_line1	   	ghr_pa_requests.forwarding_address_line1%TYPE;
	l_forwarding_address_line2	   	ghr_pa_requests.forwarding_address_line2%TYPE;
	l_forwarding_address_line3	   	ghr_pa_requests.forwarding_address_line3%TYPE;
	l_forwarding_country	   		ghr_pa_requests.forwarding_country%TYPE;
	l_forwarding_postal_code	   	ghr_pa_requests.forwarding_postal_code%TYPE;
	l_forwarding_region_2	   		ghr_pa_requests.forwarding_region_2%TYPE;
	l_forwarding_town_or_city	   	ghr_pa_requests.forwarding_town_or_city%TYPE;
	l_from_adj_basic_pay	   		ghr_pa_requests.from_adj_basic_pay%TYPE;
	l_from_basic_pay	   			ghr_pa_requests.from_basic_pay%TYPE;
	l_from_grade_or_level	   		ghr_pa_requests.from_grade_or_level%TYPE;
	l_from_locality_adj	   		ghr_pa_requests.from_locality_adj%TYPE;
	l_from_occ_code	   			ghr_pa_requests.from_occ_code%TYPE;
	l_from_other_pay_amount	   		ghr_pa_requests.from_other_pay_amount%TYPE;
	l_from_pay_basis	   			ghr_pa_requests.from_pay_basis%TYPE;
	l_from_pay_plan	   			ghr_pa_requests.from_pay_plan%TYPE;
    -- FWFA Changes Bug#4444609
    l_input_pay_rate_determinant    ghr_pa_requests.input_pay_rate_determinant%TYPE;
    l_from_pay_table_identifier     ghr_pa_requests.from_pay_table_identifier%TYPE;
    -- FWFA Changes
 	l_from_position_id	   		ghr_pa_requests.from_position_id%TYPE;
	l_from_position_org_line1   		ghr_pa_requests.from_position_org_line1%TYPE;
	l_from_position_org_line2	   	ghr_pa_requests.from_position_org_line2%TYPE;
	l_from_position_org_line3		ghr_pa_requests.from_position_org_line3%TYPE;
	l_from_position_org_line4		ghr_pa_requests.from_position_org_line4%TYPE;
	l_from_position_org_line5		ghr_pa_requests.from_position_org_line5%TYPE;
	l_from_position_org_line6		ghr_pa_requests.from_position_org_line6%TYPE;
	l_from_position_number	   		ghr_pa_requests.from_position_number%TYPE;
	l_from_position_seq_no	   		ghr_pa_requests.from_position_seq_no%TYPE;
	l_from_position_title	   		ghr_pa_requests.from_position_title%TYPE;
	l_from_step_or_rate	   		ghr_pa_requests.from_step_or_rate%TYPE;
	l_from_total_salary	   		ghr_pa_requests.from_total_salary%TYPE;
	l_functional_class	   		ghr_pa_requests.functional_class%TYPE;
	l_notepad	   				ghr_pa_requests.notepad%TYPE;
	l_part_time_hours	   			ghr_pa_requests.part_time_hours%TYPE;
	l_pay_rate_determinant	   		ghr_pa_requests.pay_rate_determinant%TYPE;
	l_person_id	   				ghr_pa_requests.person_id%TYPE;
	l_position_occupied	   		ghr_pa_requests.position_occupied%TYPE;
  	l_proposed_effective_date	   	ghr_pa_requests.proposed_effective_date%TYPE;
	l_requested_by_person_id	   	ghr_pa_requests.requested_by_person_id%TYPE;
	l_requested_by_title	   		ghr_pa_requests.requested_by_title%TYPE;
	l_requested_date	   			ghr_pa_requests.requested_date%TYPE;
	l_requesting_office_remarks_de 	ghr_pa_requests.requesting_office_remarks_desc%TYPE;
	l_requesting_office_remarks_fl 	ghr_pa_requests.requesting_office_remarks_flag%TYPE;
 	l_request_number	   			ghr_pa_requests.request_number%TYPE;
	l_resign_and_retire_reason_des 	ghr_pa_requests.resign_and_retire_reason_desc%TYPE;
	l_retirement_plan	   			ghr_pa_requests.retirement_plan%TYPE;
	l_retirement_plan_desc	   		ghr_pa_requests.retirement_plan_desc%TYPE;
      l_second_action_la_code1		ghr_pa_requests.second_action_la_code1%TYPE;
      l_second_action_la_code2		ghr_pa_requests.second_action_la_code2%TYPE;
      l_second_action_la_desc1 		ghr_pa_requests.second_action_la_desc1%TYPE;
	l_second_action_la_desc2		ghr_pa_requests.second_action_la_desc2%TYPE;
	l_second_noa_cancel_or_correct	ghr_pa_requests.second_noa_cancel_or_correct%TYPE;
      l_second_noa_code                   ghr_pa_requests.second_noa_code%TYPE;
	l_second_noa_desc     			ghr_pa_requests.second_noa_desc%TYPE;
	l_second_noa_id                	ghr_pa_requests.second_noa_id%TYPE;
	l_second_noa_pa_request_id		ghr_pa_requests.second_noa_pa_request_id%TYPE;
	l_service_comp_date	   		ghr_pa_requests.service_comp_date%TYPE;
	l_supervisory_status	   		ghr_pa_requests.supervisory_status%TYPE;
  	l_tenure	   				ghr_pa_requests.tenure%TYPE;
  	l_to_adj_basic_pay	   		ghr_pa_requests.to_adj_basic_pay%TYPE;
  	l_to_basic_pay	   			ghr_pa_requests.to_basic_pay%TYPE;
  	l_to_grade_id	   			ghr_pa_requests.to_grade_id%TYPE;
  	l_to_grade_or_level	   		ghr_pa_requests.to_grade_or_level%TYPE;
  	l_to_job_id	   				ghr_pa_requests.to_job_id%TYPE;
  	l_to_locality_adj	   			ghr_pa_requests.to_locality_adj%TYPE;
  	l_to_occ_code	   			ghr_pa_requests.to_occ_code%TYPE;
  	l_to_organization_id	   		ghr_pa_requests.to_organization_id%TYPE;
  	l_to_other_pay_amount	   		ghr_pa_requests.to_other_pay_amount%TYPE;
	l_to_au_overtime               	ghr_pa_requests.to_au_overtime%TYPE;
	l_to_auo_premium_pay_indicator	ghr_pa_requests.to_auo_premium_pay_indicator%TYPE;
	l_to_availability_pay          	ghr_pa_requests.to_availability_pay%TYPE;
	l_to_ap_premium_pay_indicator   	ghr_pa_requests.to_ap_premium_pay_indicator%TYPE;
	l_to_retention_allowance       	ghr_pa_requests.to_retention_allowance%TYPE;
	l_to_supervisory_differential  	ghr_pa_requests.to_supervisory_differential%TYPE;
	l_to_staffing_differential     	ghr_pa_requests.to_staffing_differential%TYPE;
  	l_to_pay_basis	   			ghr_pa_requests.to_pay_basis%TYPE;
  	l_to_pay_plan	   			ghr_pa_requests.to_pay_plan%TYPE;
    -- FWFA Changes Bug 4444609
    l_to_pay_table_identifier       ghr_pa_requests.to_pay_table_identifier%TYPE;
    -- FWFA Changes
	l_to_position_id	   			ghr_pa_requests.to_position_id%TYPE;
	l_to_position_org_line1			ghr_pa_requests.to_position_org_line1%TYPE;
	l_to_position_org_line2			ghr_pa_requests.to_position_org_line2%TYPE;
	l_to_position_org_line3			ghr_pa_requests.to_position_org_line3%TYPE;
	l_to_position_org_line4			ghr_pa_requests.to_position_org_line4%TYPE;
	l_to_position_org_line5			ghr_pa_requests.to_position_org_line5%TYPE;
	l_to_position_org_line6			ghr_pa_requests.to_position_org_line6%TYPE;
  	l_to_position_number	   		ghr_pa_requests.to_position_number%TYPE;
  	l_to_position_seq_no	   		ghr_pa_requests.to_position_seq_no%TYPE;
  	l_to_position_title	   		ghr_pa_requests.to_position_title%TYPE;
  	l_to_step_or_rate	   			ghr_pa_requests.to_step_or_rate%TYPE;
  	l_to_total_salary	   			ghr_pa_requests.to_total_salary%TYPE;
 	l_veterans_preference	   		ghr_pa_requests.veterans_preference%TYPE;
	l_veterans_pref_for_rif	   		ghr_pa_requests.veterans_pref_for_rif%TYPE;
	l_veterans_status	   			ghr_pa_requests.veterans_status%TYPE;
	l_work_schedule	   			ghr_pa_requests.work_schedule%TYPE;
	l_work_schedule_desc	   		ghr_pa_requests.work_schedule_desc%TYPE;
	l_year_degree_attained	   		ghr_pa_requests.year_degree_attained%TYPE;
	l_first_noa_information1	   	ghr_pa_requests.first_noa_information1%TYPE;
	l_first_noa_information2	   	ghr_pa_requests.first_noa_information2%TYPE;
	l_first_noa_information3	   	ghr_pa_requests.first_noa_information3%TYPE;
	l_first_noa_information4	   	ghr_pa_requests.first_noa_information4%TYPE;
	l_first_noa_information5	   	ghr_pa_requests.first_noa_information5%TYPE;
	l_second_lac1_information1		ghr_pa_requests.second_lac1_information1%TYPE;
	l_second_lac1_information2		ghr_pa_requests.second_lac1_information2%TYPE;
	l_second_lac1_information3		ghr_pa_requests.second_lac1_information3%TYPE;
	l_second_lac1_information4		ghr_pa_requests.second_lac1_information4%TYPE;
	l_second_lac1_information5		ghr_pa_requests.second_lac1_information5%TYPE;
	l_second_lac2_information1		ghr_pa_requests.second_lac2_information1%TYPE;
	l_second_lac2_information2		ghr_pa_requests.second_lac2_information2%TYPE;
	l_second_lac2_information3		ghr_pa_requests.second_lac2_information3%TYPE;
	l_second_lac2_information4		ghr_pa_requests.second_lac2_information4%TYPE;
	l_second_lac2_information5		ghr_pa_requests.second_lac2_information5%TYPE;
	l_second_noa_information1      	ghr_pa_requests.second_noa_information1%TYPE;
	l_second_noa_information2      	ghr_pa_requests.second_noa_information2%TYPE;
	l_second_noa_information3      	ghr_pa_requests.second_noa_information3%TYPE;
	l_second_noa_information4      	ghr_pa_requests.second_noa_information4%TYPE;
	l_second_noa_information5      	ghr_pa_requests.second_noa_information5%TYPE;
	l_first_lac1_information1      	ghr_pa_requests.first_lac1_information1%TYPE;
	l_first_lac1_information2        	ghr_pa_requests.first_lac1_information2%TYPE;
	l_first_lac1_information3      	ghr_pa_requests.first_lac1_information3%TYPE;
	l_first_lac1_information4      	ghr_pa_requests.first_lac1_information4%TYPE;
	l_first_lac1_information5      	ghr_pa_requests.first_lac1_information5%TYPE;
	l_first_lac2_information1      	ghr_pa_requests.first_lac2_information1%TYPE;
	l_first_lac2_information2      	ghr_pa_requests.first_lac2_information2%TYPE;
	l_first_lac2_information3      	ghr_pa_requests.first_lac2_information3%TYPE;
	l_first_lac2_information4      	ghr_pa_requests.first_lac2_information4%TYPE;
	l_first_lac2_information5      	ghr_pa_requests.first_lac2_information5%TYPE;
	l_u_attachment_modified_flag		varchar2(30);
	l_u_approved_flag	   			varchar2(30);
 	l_u_user_name_acted_on	   		ghr_pa_routing_history.user_name%TYPE;
  	l_i_user_name_routed_to	   		ghr_pa_routing_history.user_name%TYPE;
  	l_i_groupbox_id	   			ghr_pa_routing_history.groupbox_id%TYPE;
  	l_i_routing_list_id	   		number;
  	l_i_routing_seq_number	   		ghr_pa_routing_history.routing_seq_number%TYPE;
 	l_u_prh_object_version_number  	number;
 	l_i_pa_routing_history_id	   	number;
 	l_i_prh_object_version_number  	number;
      l_u_approval_status                 ghr_pa_routing_history.approval_status%TYPE;
      l_approving_official_full_name      ghr_pa_requests.approving_official_full_name%TYPE;
      l_approving_official_work_titl      ghr_pa_requests.approving_official_work_title%TYPE;
      l_approval_date                     ghr_pa_requests.approval_date%TYPE;
      --
      l_to_retention_allow_percentag	  ghr_pa_requests.to_retention_allow_percentage%TYPE;
      l_to_supervisory_diff_percenta      ghr_pa_requests.to_supervisory_diff_percentage%TYPE;
      l_to_staffing_diff_percentage       ghr_pa_requests.to_staffing_diff_percentage%TYPE;
      l_award_percentage                  ghr_pa_requests.award_percentage%TYPE;
      l_commit                            number;

--
-- Added cursor to select object version number and routing history id
  cursor csr_get_parh_info is
      select pa_routing_history_id, object_version_number
        from ghr_pa_routing_history
      where pa_request_id = p_pa_request_id;
--
  cursor csr_par_details is
	select
		noa_family_code,
		routing_group_id,
            object_version_number,
		proposed_effective_asap_flag,
		academic_discipline,
		additional_info_person_id,
		additional_info_tel_number,
		altered_pa_request_id,
		annuitant_indicator,
		annuitant_indicator_desc,
		appropriation_code1,
		appropriation_code2,
		authorized_by_person_id,
		authorized_by_title,
		award_amount,
		award_uom,
	  	bargaining_unit_status,
	  	citizenship,
		concurrence_date,
	      custom_pay_calc_flag,
		duty_station_code,
		duty_station_desc,
		duty_station_id,
		duty_station_location_id,
		education_level,
	  	effective_date,
	  	employee_assignment_id,
	 	employee_date_of_birth,
		employee_first_name,
	  	employee_last_name,
	  	employee_middle_names,
	 	employee_national_identifier,
		fegli,
		fegli_desc,
	      first_action_la_code1,
	      first_action_la_code2,
   	      first_action_la_desc1,
	      first_action_la_desc2,
		first_noa_cancel_or_correct,
	      first_noa_code,
   	      first_noa_desc,
		first_noa_id,
		first_noa_pa_request_id,
		flsa_category,
		forwarding_address_line1,
		forwarding_address_line2,
		forwarding_address_line3,
		forwarding_country,
		forwarding_postal_code,
		forwarding_region_2,
		forwarding_town_or_city,
		from_adj_basic_pay,
		from_basic_pay,
		from_grade_or_level,
		from_locality_adj,
		from_occ_code,
		from_other_pay_amount,
		from_pay_basis,
		from_pay_plan,
        -- FWFA Changes Bug#4444609
        input_pay_rate_determinant,
        from_pay_table_identifier,
        -- FWFA Changes
	 	from_position_id,
		from_position_org_line1,
		from_position_org_line2,
		from_position_org_line3,
		from_position_org_line4,
		from_position_org_line5,
		from_position_org_line6,
		from_position_number,
		from_position_seq_no,
		from_position_title,
		from_step_or_rate,
		from_total_salary,
		functional_class,
		notepad,
		part_time_hours,
		pay_rate_determinant,
		person_id,
		position_occupied,
	  	proposed_effective_date,
		requested_by_person_id,
		requested_by_title,
		requested_date,
		requesting_office_remarks_desc,
		requesting_office_remarks_flag,
	 	request_number,
		resign_and_retire_reason_desc,
		retirement_plan,
		retirement_plan_desc,
	      second_action_la_code1,
	      second_action_la_code2,
	      second_action_la_desc1,
		second_action_la_desc2,
		second_noa_cancel_or_correct,
	      second_noa_code,
  		second_noa_desc,
		second_noa_id,
		second_noa_pa_request_id,
		service_comp_date,
		supervisory_status,
	  	tenure,
	  	to_adj_basic_pay,
	  	to_basic_pay,
	  	to_grade_id,
	  	to_grade_or_level,
	  	to_job_id,
	  	to_locality_adj,
	  	to_occ_code,
	  	to_organization_id,
	  	to_other_pay_amount,
		to_au_overtime,
		to_auo_premium_pay_indicator,
		to_availability_pay,
		to_ap_premium_pay_indicator,
		to_retention_allowance,
		to_supervisory_differential,
		to_staffing_differential,
	  	to_pay_basis,
	  	to_pay_plan,
        -- FWFA Changes Bug#4444609
        to_pay_table_identifier,
        -- FWFA Changes
		to_position_id,
		to_position_org_line1,
		to_position_org_line2,
		to_position_org_line3,
		to_position_org_line4,
		to_position_org_line5,
		to_position_org_line6,
	  	to_position_number,
	  	to_position_seq_no,
	  	to_position_title,
	  	to_step_or_rate,
	  	to_total_salary,
	 	veterans_preference,
		veterans_pref_for_rif,
		veterans_status,
		work_schedule,
		work_schedule_desc,
		year_degree_attained,
		first_noa_information1,
		first_noa_information2,
		first_noa_information3,
		first_noa_information4,
		first_noa_information5,
		second_lac1_information1,
		second_lac1_information2,
		second_lac1_information3,
		second_lac1_information4,
		second_lac1_information5,
		second_lac2_information1,
		second_lac2_information2,
		second_lac2_information3,
		second_lac2_information4,
		second_lac2_information5,
		second_noa_information1,
		second_noa_information2,
		second_noa_information3,
		second_noa_information4,
		second_noa_information5,
		first_lac1_information1,
		first_lac1_information2,
		first_lac1_information3,
		first_lac1_information4,
		first_lac1_information5,
		first_lac2_information1,
		first_lac2_information2,
		first_lac2_information3,
		first_lac2_information4,
		first_lac2_information5,
            approval_date,
            approving_official_full_name,
            approving_official_work_title,
            to_retention_allow_percentage,
            to_supervisory_diff_percentage,
            to_staffing_diff_percentage,
            award_percentage
-- 		u_attachment_modified_flag,
--	  	u_approved_flag,
--	  	u_user_name_acted_on,
--	  	u_user_name_acted_on,
--	  	u_action_taken,
--	  	i_user_name_routed_to,
--	  	i_groupbox_id
--	  	i_routing_list_id,
--	  	i_routing_seq_number
	from ghr_pa_requests
      where pa_request_id = p_pa_request_id;
--
begin
-- Replacing the insert dml  with a call to the dt_fndate.change_ses_date  procedure .

    dt_fndate.change_ses_date(p_ses_date => trunc(sysdate),
                             p_commit   => l_commit
                            );
-- The previous code did not perform a commit after writing to fnd_sessions
-- Hence not issuing  a Commit based on the value of the l_commit out variable




      open  csr_par_details ;
      fetch  csr_par_details  into
		l_noa_family_code,
		l_routing_group_id,
		l_par_object_version_number,
		l_proposed_effective_asap_flag,
		l_academic_discipline,
		l_additional_info_person_id,
		l_additional_info_tel_number,
		l_altered_pa_request_id,
		l_annuitant_indicator,
		l_annuitant_indicator_desc,
		l_appropriation_code1,
		l_appropriation_code2,
		l_authorized_by_person_id,
		l_authorized_by_title,
		l_award_amount,
		l_award_uom,
	  	l_bargaining_unit_status,
	  	l_citizenship,
		l_concurrence_date,
	      l_custom_pay_calc_flag,
		l_duty_station_code,
		l_duty_station_desc,
		l_duty_station_id,
		l_duty_station_location_id,
		l_education_level,
	  	l_effective_date,
	  	l_employee_assignment_id,
	 	l_employee_date_of_birth,
		l_employee_first_name,
	  	l_employee_last_name,
	  	l_employee_middle_names,
	 	l_employee_national_identifier,
		l_fegli,
		l_fegli_desc,
	      l_first_action_la_code1,
	      l_first_action_la_code2,
	      l_first_action_la_desc1,
	      l_first_action_la_desc2,
		l_first_noa_cancel_or_correct,
	      l_first_noa_code,
	      l_first_noa_desc,
		l_first_noa_id,
		l_first_noa_pa_request_id,
		l_flsa_category,
		l_forwarding_address_line1,
		l_forwarding_address_line2,
		l_forwarding_address_line3,
		l_forwarding_country,
		l_forwarding_postal_code,
		l_forwarding_region_2,
		l_forwarding_town_or_city,
		l_from_adj_basic_pay,
		l_from_basic_pay,
		l_from_grade_or_level,
		l_from_locality_adj,
		l_from_occ_code,
		l_from_other_pay_amount,
		l_from_pay_basis,
		l_from_pay_plan,
        -- FWFA Changes Bug#4444609
        l_input_pay_rate_determinant,
        l_from_pay_table_identifier,
        -- FWFA Changes
	 	l_from_position_id,
		l_from_position_org_line1,
		l_from_position_org_line2,
		l_from_position_org_line3,
		l_from_position_org_line4,
		l_from_position_org_line5,
		l_from_position_org_line6,
		l_from_position_number,
		l_from_position_seq_no,
		l_from_position_title,
		l_from_step_or_rate,
		l_from_total_salary,
		l_functional_class,
		l_notepad,
		l_part_time_hours,
		l_pay_rate_determinant,
		l_person_id,
		l_position_occupied,
	  	l_proposed_effective_date,
		l_requested_by_person_id,
		l_requested_by_title,
		l_requested_date,
		l_requesting_office_remarks_de,
		l_requesting_office_remarks_fl ,
	 	l_request_number,
		l_resign_and_retire_reason_des,
		l_retirement_plan,
		l_retirement_plan_desc,
      	l_second_action_la_code1,
	      l_second_action_la_code2,
	      l_second_action_la_desc1,
		l_second_action_la_desc2,
		l_second_noa_cancel_or_correct,
	      l_second_noa_code,
		l_second_noa_desc,
		l_second_noa_id,
		l_second_noa_pa_request_id,
		l_service_comp_date,
		l_supervisory_status,
	  	l_tenure,
	  	l_to_adj_basic_pay,
	  	l_to_basic_pay,
	  	l_to_grade_id,
	  	l_to_grade_or_level,
	  	l_to_job_id,
	  	l_to_locality_adj,
	  	l_to_occ_code,
	  	l_to_organization_id,
	  	l_to_other_pay_amount,
		l_to_au_overtime,
		l_to_auo_premium_pay_indicator,
		l_to_availability_pay,
		l_to_ap_premium_pay_indicator,
		l_to_retention_allowance,
		l_to_supervisory_differential,
		l_to_staffing_differential,
	  	l_to_pay_basis,
	  	l_to_pay_plan,
        -- FWFA Changes Bug#4444609
        l_to_pay_Table_identifier,
        -- FWFA Changes
		l_to_position_id,
		l_to_position_org_line1,
		l_to_position_org_line2,
		l_to_position_org_line3,
		l_to_position_org_line4,
		l_to_position_org_line5,
		l_to_position_org_line6,
	  	l_to_position_number,
	  	l_to_position_seq_no,
	  	l_to_position_title,
	  	l_to_step_or_rate,
	  	l_to_total_salary,
	 	l_veterans_preference,
		l_veterans_pref_for_rif,
		l_veterans_status,
		l_work_schedule,
		l_work_schedule_desc,
		l_year_degree_attained,
		l_first_noa_information1,
		l_first_noa_information2,
		l_first_noa_information3,
		l_first_noa_information4,
		l_first_noa_information5,
		l_second_lac1_information1,
		l_second_lac1_information2,
		l_second_lac1_information3,
		l_second_lac1_information4,
		l_second_lac1_information5,
		l_second_lac2_information1,
		l_second_lac2_information2,
		l_second_lac2_information3,
		l_second_lac2_information4,
		l_second_lac2_information5,
		l_second_noa_information1,
		l_second_noa_information2,
		l_second_noa_information3,
		l_second_noa_information4,
		l_second_noa_information5,
		l_first_lac1_information1,
		l_first_lac1_information2,
		l_first_lac1_information3,
		l_first_lac1_information4,
		l_first_lac1_information5,
		l_first_lac2_information1,
		l_first_lac2_information2,
		l_first_lac2_information3,
		l_first_lac2_information4,
		l_first_lac2_information5,
            l_approval_date,
            l_approving_official_full_name,
            l_approving_official_work_titl,
            l_to_retention_allow_percentag,
            l_to_supervisory_diff_percenta,
            l_to_staffing_diff_percentage,
            l_award_percentage;
--		l_u_attachment_modified_flag,
--		l_u_approved_flag,
--	 	l_u_user_name_acted_on,
--	  	l_u_action_taken,
--	  	l_i_user_name_routed_to,
--	  	l_i_groupbox_id
--	  	l_i_routing_list_id,
--	  	l_i_routing_seq_number
     if  csr_par_details%notfound then
	     -- if the cursor does not return a row then we must set the out
	     -- parameter to null
	     null;
     end if;
     -- close the cursor
     close  csr_par_details;
     if p_routing_group_id is not NULL then
         l_routing_group_id := p_routing_group_id;
     end if;
     l_u_approval_status := '';
     if p_groupbox_id is not NULL then
         l_i_groupbox_id := p_groupbox_id;
         -- Get the Electronic Auth. values
         l_u_approval_status := 'APPROVE';
         l_approval_date := sysdate;
         l_approving_official_full_name := ghr_pa_requests_pkg.get_full_name_fml (p_gbx_user_id);
         l_approving_official_work_titl :=
             ghr_pa_requests_pkg.get_position_work_title (p_person_id => TO_CHAR(p_gbx_user_id));
     end if;
     -- Set Request Number
     l_request_number := 'WGI:' || p_pa_request_id;
     ghr_sf52_api.update_sf52(
		p_validate	   				=> l_validate,
		p_pa_request_id	   			=> p_pa_request_id,
		p_noa_family_code	   			=> l_noa_family_code,
		p_routing_group_id	   		=> l_routing_group_id,
		p_par_object_version_number	   	=> l_par_object_version_number,
		p_proposed_effective_asap_flag 	=> l_proposed_effective_asap_flag,
		p_academic_discipline	   		=> l_academic_discipline,
		p_additional_info_person_id	   	=> l_additional_info_person_id,
		p_additional_info_tel_number  	=> l_additional_info_tel_number,
		p_altered_pa_request_id	   		=> l_altered_pa_request_id,
		p_annuitant_indicator	   		=> l_annuitant_indicator,
		p_annuitant_indicator_desc	   	=> l_annuitant_indicator_desc,
		p_appropriation_code1	   		=> l_appropriation_code1,
		p_appropriation_code2	   		=> l_appropriation_code2,
		p_authorized_by_person_id	   	=> l_authorized_by_person_id,
		p_authorized_by_title	   		=> l_authorized_by_title,
		p_award_amount	   			=> l_award_amount,
		p_award_uom	   				=> l_award_uom,
	  	p_bargaining_unit_status	   	=> l_bargaining_unit_status,
	  	p_citizenship	   			=> l_citizenship,
		p_concurrence_date	   		=> l_concurrence_date,
	      p_custom_pay_calc_flag      		=> l_custom_pay_calc_flag,
		p_duty_station_code	   		=> l_duty_station_code,
		p_duty_station_desc	   		=> l_duty_station_desc,
		p_duty_station_id	   			=> l_duty_station_id,
		p_duty_station_location_id	   	=> l_duty_station_location_id,
		p_education_level	   			=> l_education_level,
	  	p_effective_date	   			=> l_effective_date,
	  	p_employee_assignment_id	   	=> l_employee_assignment_id,
	 	p_employee_date_of_birth	   	=> l_employee_date_of_birth,
		p_employee_first_name	   		=> l_employee_first_name,
	  	p_employee_last_name	   		=> l_employee_last_name,
	  	p_employee_middle_names	   		=> l_employee_middle_names,
	 	p_employee_national_identifier 	=> l_employee_national_identifier,
		p_fegli	   				=> l_fegli,
		p_fegli_desc	   			=> l_fegli_desc,
	      p_first_action_la_code1			=> l_first_action_la_code1,
	      p_first_action_la_code2    		=> l_first_action_la_code2,
	      p_first_action_la_desc1			=> l_first_action_la_desc1,
	      p_first_action_la_desc2			=> l_first_action_la_desc2,
		p_first_noa_cancel_or_correct 	=> l_first_noa_cancel_or_correct,
	      p_first_noa_code				=> l_first_noa_code,
	      p_first_noa_desc				=> l_first_noa_desc,
		p_first_noa_id	   			=> l_first_noa_id,
		p_first_noa_pa_request_id	   	=> l_first_noa_pa_request_id,
		p_flsa_category	   			=> l_flsa_category,
		p_forwarding_address_line1	   	=> l_forwarding_address_line1,
		p_forwarding_address_line2	   	=> l_forwarding_address_line2,
		p_forwarding_address_line3	   	=> l_forwarding_address_line3,
		p_forwarding_country	   		=> l_forwarding_country,
		p_forwarding_postal_code	   	=> l_forwarding_postal_code,
		p_forwarding_region_2	   		=> l_forwarding_region_2,
		p_forwarding_town_or_city	   	=> l_forwarding_town_or_city,
		p_from_adj_basic_pay	   		=> l_from_adj_basic_pay,
		p_from_basic_pay	   			=> l_from_basic_pay,
		p_from_grade_or_level	   		=> l_from_grade_or_level,
		p_from_locality_adj	   		=> l_from_locality_adj,
		p_from_occ_code	   			=> l_from_occ_code,
		p_from_other_pay_amount	   		=> l_from_other_pay_amount,
		p_from_pay_basis	   			=> l_from_pay_basis,
		p_from_pay_plan	   			=> l_from_pay_plan,
        -- FWFA Changes Bug#4444609
        p_input_pay_rate_determinant  => l_input_pay_rate_determinant,
        p_from_pay_table_identifier   => l_from_pay_table_identifier,
        -- FWFA Changes
	 	p_from_position_id	   		=> l_from_position_id,
		p_from_position_org_line1   		=> l_from_position_org_line1,
		p_from_position_org_line2	   	=> l_from_position_org_line2,
		p_from_position_org_line3		=> l_from_position_org_line3,
		p_from_position_org_line4		=> l_from_position_org_line4,
		p_from_position_org_line5		=> l_from_position_org_line5,
		p_from_position_org_line6		=> l_from_position_org_line6,
		p_from_position_number	   		=> l_from_position_number,
		p_from_position_seq_no	   		=> l_from_position_seq_no,
		p_from_position_title	   		=> l_from_position_title,
		p_from_step_or_rate	   		=> l_from_step_or_rate,
		p_from_total_salary	   		=> l_from_total_salary,
		p_functional_class	   		=> l_functional_class,
		p_notepad	   				=> l_notepad,
		p_part_time_hours	   			=> l_part_time_hours,
		p_pay_rate_determinant	   		=> l_pay_rate_determinant,
		p_person_id	   				=> l_person_id,
		p_position_occupied	   		=> l_position_occupied,
	  	p_proposed_effective_date	   	=> l_proposed_effective_date,
		p_requested_by_person_id	   	=> l_requested_by_person_id,
		p_requested_by_title	   		=> l_requested_by_title,
		p_requested_date	   			=> l_requested_date,
		p_requesting_office_remarks_de 	=> l_requesting_office_remarks_de,
		p_requesting_office_remarks_fl 	=> l_requesting_office_remarks_fl,
	 	p_request_number	   			=> l_request_number,
		p_resign_and_retire_reason_des 	=> l_resign_and_retire_reason_des,
		p_retirement_plan	   			=> l_retirement_plan,
		p_retirement_plan_desc	   		=> l_retirement_plan_desc,
	      p_second_action_la_code1		=> l_second_action_la_code1,
	      p_second_action_la_code2		=> l_second_action_la_code2,
	      p_second_action_la_desc1 		=> l_second_action_la_desc1,
		p_second_action_la_desc2		=> l_second_action_la_desc2,
		p_second_noa_cancel_or_correct	=> l_second_noa_cancel_or_correct,
	      p_second_noa_code                   => l_second_noa_code,
		p_second_noa_desc     			=> l_second_noa_desc,
		p_second_noa_id                	=> l_second_noa_id,
		p_second_noa_pa_request_id		=> l_second_noa_pa_request_id,
		p_service_comp_date	   		=> l_service_comp_date,
		p_supervisory_status	   		=> l_supervisory_status,
	  	p_tenure	   				=> l_tenure,
	  	p_to_adj_basic_pay	   		=> l_to_adj_basic_pay,
	  	p_to_basic_pay	   			=> l_to_basic_pay,
	  	p_to_grade_id	   			=> l_to_grade_id,
	  	p_to_grade_or_level	   		=> l_to_grade_or_level,
	  	p_to_job_id	   				=> l_to_job_id,
	  	p_to_locality_adj	   			=> l_to_locality_adj,
	  	p_to_occ_code	   			=> l_to_occ_code,
	  	p_to_organization_id	   		=> l_to_organization_id,
	  	p_to_other_pay_amount	   		=> l_to_other_pay_amount,
		p_to_au_overtime               	=> l_to_au_overtime,
		p_to_auo_premium_pay_indicator	=> l_to_auo_premium_pay_indicator,
		p_to_availability_pay          	=> l_to_availability_pay,
		p_to_ap_premium_pay_indicator   	=> l_to_ap_premium_pay_indicator,
		p_to_retention_allowance       	=> l_to_retention_allowance,
		p_to_supervisory_differential  	=> l_to_supervisory_differential,
		p_to_staffing_differential     	=> l_to_staffing_differential,
	  	p_to_pay_basis	   			=> l_to_pay_basis,
	  	p_to_pay_plan	   			=> l_to_pay_plan,
        -- FWFA Changes Bug#4444609
        p_to_pay_table_identifier   => l_to_pay_table_identifier,
        -- FWFA Changes
		p_to_position_id	   			=> l_to_position_id,
		p_to_position_org_line1			=> l_to_position_org_line1,
		p_to_position_org_line2			=> l_to_position_org_line2,
		p_to_position_org_line3			=> l_to_position_org_line3,
		p_to_position_org_line4			=> l_to_position_org_line4,
		p_to_position_org_line5			=> l_to_position_org_line5,
		p_to_position_org_line6			=> l_to_position_org_line6,
	  	p_to_position_number	   		=> l_to_position_number,
	  	p_to_position_seq_no	   		=> l_to_position_seq_no,
	  	p_to_position_title	   		=> l_to_position_title,
	  	p_to_step_or_rate	   			=> l_to_step_or_rate,
	  	p_to_total_salary	   			=> l_to_total_salary,
	 	p_veterans_preference	   		=> l_veterans_preference,
		p_veterans_pref_for_rif	   		=> l_veterans_pref_for_rif,
		p_veterans_status	   			=> l_veterans_status,
		p_work_schedule	   			=> l_work_schedule,
		p_work_schedule_desc	   		=> l_work_schedule_desc,
		p_year_degree_attained	   		=> l_year_degree_attained,
		p_first_noa_information1	   	=> l_first_noa_information1,
		p_first_noa_information2	   	=> l_first_noa_information2,
		p_first_noa_information3	   	=> l_first_noa_information3,
		p_first_noa_information4	   	=> l_first_noa_information4,
		p_first_noa_information5	   	=> l_first_noa_information5,
		p_second_lac1_information1		=> l_second_lac1_information1,
		p_second_lac1_information2		=> l_second_lac1_information2,
		p_second_lac1_information3		=> l_second_lac1_information3,
		p_second_lac1_information4		=> l_second_lac1_information4,
		p_second_lac1_information5		=> l_second_lac1_information5,
		p_second_lac2_information1		=> l_second_lac2_information1,
		p_second_lac2_information2		=> l_second_lac2_information2,
		p_second_lac2_information3		=> l_second_lac2_information3,
		p_second_lac2_information4		=> l_second_lac2_information4,
		p_second_lac2_information5		=> l_second_lac2_information5,
		p_second_noa_information1      	=> l_second_noa_information1,
		p_second_noa_information2      	=> l_second_noa_information2,
		p_second_noa_information3      	=> l_second_noa_information3,
		p_second_noa_information4      	=> l_second_noa_information4,
		p_second_noa_information5      	=> l_second_noa_information5,
		p_first_lac1_information1      	=> l_first_lac1_information1,
		p_first_lac1_information2        	=> l_first_lac1_information2,
		p_first_lac1_information3      	=> l_first_lac1_information3,
		p_first_lac1_information4      	=> l_first_lac1_information4,
		p_first_lac1_information5      	=> l_first_lac1_information5,
		p_first_lac2_information1      	=> l_first_lac2_information1,
		p_first_lac2_information2      	=> l_first_lac2_information2,
		p_first_lac2_information3      	=> l_first_lac2_information3,
		p_first_lac2_information4      	=> l_first_lac2_information4,
		p_first_lac2_information5      	=> l_first_lac2_information5,
-- Added for sf52_from_data_elements
            p_to_retention_allow_percentag      => l_to_retention_allow_percentag,
            p_to_supervisory_diff_percenta      => l_to_supervisory_diff_percenta,
            p_to_staffing_diff_percentage       => l_to_staffing_diff_percentage,
            p_award_percentage                  => l_award_percentage,
-- Added for Elect Auth.
            p_u_approval_status                 => l_u_approval_status,
            p_approval_date                     => l_approval_date,
            p_approving_official_full_name      => l_approving_official_full_name,
            p_approving_official_work_titl      => l_approving_official_work_titl,
--		p_u_attachment_modified_flag		=> l_u_attachment_modified_flag,
--	  	p_u_approved_flag	   			=> l_u_approved_flag,
--	  	p_u_user_name_acted_on	   		=> l_u_user_name_acted_on,
	  	p_u_action_taken	   			=> p_action_taken,
--	  	p_i_user_name_routed_to	   		=> l_i_user_name_routed_to,
--	  	p_i_groupbox_id	   			=> l_i_groupbox_id,
--	  	p_i_routing_list_id	   		=> l_i_routing_list_id,
--	  	p_i_routing_seq_number	   		=> l_i_routing_seq_number,
	 	p_u_prh_object_version_number  	=> l_u_prh_object_version_number,
	 	p_i_pa_routing_history_id	   	=> l_i_pa_routing_history_id,
	 	p_i_prh_object_version_number  	=> l_i_prh_object_version_number
		);
-- Added to update Groupbox ID using the row handler
--
		-- open cursor
 		open csr_get_parh_info;
	      fetch csr_get_parh_info into l_i_pa_routing_history_id, l_i_prh_object_version_number;
		if csr_get_parh_info%notfound then
			l_i_pa_routing_history_id  := null;
			l_i_prh_object_version_number := null;
		end if;
		close csr_get_parh_info ;
--
	if l_i_groupbox_id Is Not Null then
		ghr_prh_upd.upd
		(
		p_object_version_number			=> l_i_prh_object_version_number,
		p_pa_routing_history_id			=> l_i_pa_routing_history_id,
		p_groupbox_id	   			=> l_i_groupbox_id
		);
	end if;
--
--
end update_sf52_action_taken;
--
--
procedure perofc_approval_required ( 	itemtype	in varchar2,
							itemkey  	in varchar2,
							actid		in number,
							funcmode	in varchar2,
							result	in out nocopy  varchar2	) is
--
l_text	varchar2(30);
l_result VARCHAR2(250);
--
--
begin
-- NOCOPY Changes
l_result := result;
--
   if funcmode = 'RUN' then
	   l_text	:=  wf_engine.GetItemAttrText(	itemtype => Itemtype,
								  	itemkey  => Itemkey,
								  	aname    => 'PEROFC_APRVL_REQD');
	   if l_text = 'YES' then
		result := 'COMPLETE:YES';
		return;
	   else
		result := 'COMPLETE:NO';
		return;
	   end if;
   end if;
--
  result := '';
  return;
--
--
exception
  when others then
    -- NOCOPY Changes
    result := l_result;
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('WGI', 'ghr_wf_wgi_pkg.perofc_approval_required',itemtype, itemkey, to_char(actid), funcmode);
    raise;
--
--
end perofc_approval_required;
--
--
procedure use_perofc_only ( 	itemtype	in varchar2,
					itemkey  	in varchar2,
					actid		in number,
					funcmode	in varchar2,
					result	in out nocopy  varchar2	) is
--
l_text	varchar2(30);
l_result VARCHAR2(250);
--
--
begin
-- NOCOPY Changes
l_result := result;
--
   if funcmode = 'RUN' then
	   l_text	:=  wf_engine.GetItemAttrText(	itemtype => Itemtype,
								  	itemkey  => Itemkey,
								  	aname    => 'USE_PEROFC');
	   if l_text = 'NO' then
		result := 'COMPLETE:NO';
		return;
	   else
		result := 'COMPLETE:YES';
		return;
	   end if;
   end if;
--
  result := '';
  return;
--
--
exception
  when others then
    -- NOCOPY Changes
    result := l_result;
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('WGI', 'ghr_wf_wgi_pkg.use_perofc_only',itemtype, itemkey, to_char(actid), funcmode);
    raise;
--
--
end use_perofc_only;
--
--
procedure FindDestPerOfficeGbx( 	itemtype	in varchar2,
						itemkey  	in varchar2,
						actid		in number,
						funcmode	in varchar2,
						result	in out nocopy  varchar2	) is
--
--
--
l_user_name        		ghr_pa_routing_history.user_name%TYPE;
l_person_id				ghr_pa_requests.person_id%TYPE;
l_position_id			ghr_pa_requests.from_position_id%TYPE;
l_effective_date			ghr_pa_requests.effective_date%TYPE;
l_routing_group_id		ghr_pa_requests.routing_group_id%TYPE;
l_assignment_id			ghr_pa_requests.employee_assignment_id%TYPE;
l_full_name				per_people_f.full_name%TYPE;
l_routing_group_name		ghr_routing_groups.name%TYPE;
l_routing_group_desc		ghr_routing_groups.description%TYPE;
l_supervisor_name			ghr_pa_routing_history.user_name%TYPE;
l_groupbox_id			ghr_groupboxes.groupbox_id%TYPE;
l_groupbox_name			ghr_groupboxes.name%TYPE;
l_groupbox_desc			ghr_groupboxes.description%TYPE;
l_office_symbol_name		hr_lookups.meaning%TYPE;
l_wgi_due_date			date;
l_rating				varchar2(30);
l_multi_error_flag		boolean;
l_valid_user			boolean;
l_valid_grpbox			boolean;
l_line1				varchar2(500);
l_line2				varchar2(500);
l_line3				varchar2(500);
l_line4				varchar2(500);
l_line5				varchar2(500);
l_line6				varchar2(500);
l_line7				varchar2(500);
l_personnel_office_id			ghr_pa_requests.personnel_office_id%TYPE;
l_gbx_user_id                       ghr_pois.person_id%TYPE;
l_routing_group               varchar2(500);
l_wgi_error_note              varchar2(500);
-- NOCOPY Changes
l_result              varchar2(250);
--
--
begin
--
-- NOCOPY Changes
l_result := result;

if funcmode = 'RUN' then
      wf_engine.SetItemAttrText (itemtype	=> ItemType,
	      			itemkey  	=> Itemkey,
	 	      		aname 	=> 'ERROR_MSG',
		      		avalue	=> '' );
      --
      --	Get Person ID and effective date from PA requests table
	get_par_details	 (
						 p_pa_request_id  => itemkey
				   		,p_person_id      => l_person_id
				   		,p_effective_date => l_effective_date
		   				,p_position_id    => l_position_id
		   	    	 );
	-- Get employees personnel groupbox
	if l_position_id Is not Null then
	   Get_emp_personnel_groupbox   (  p_position_id		=> l_position_id
						    ,p_effective_date		=> l_effective_date
                 			          ,p_groupbox_name		=> l_groupbox_name
						    ,p_personnel_office_id    => l_personnel_office_id
                                        ,p_gbx_user_id            => l_gbx_user_id
						   );
  	   wf_engine.SetItemAttrText ( itemtype	=> ItemType,
		      			itemkey  	=> Itemkey,
  		 	      		aname 	=> 'POI',
			      		avalue	=> l_personnel_office_id);
	else
	   wf_engine.SetItemAttrText ( itemtype	=> ItemType,
			      			itemkey  	=> Itemkey,
	  		 	      		aname 	=> 'ERROR_MSG',
				      		avalue	=> 'Position ID does not exist for this Employee. '
						 );
	   result := 'COMPLETE:NO';
	   return;
	end if;
	-- Verify whether valid groupbox
      l_valid_grpbox	:=	VerifyValidWFUser	(
						 		p_user_name	=>	l_groupbox_name
								);
	if l_groupbox_name Is Not Null then
	   wf_engine.SetItemAttrText	(
	 						itemtype => Itemtype,
					     		itemkey  => Itemkey,
					     		aname    => 'PERSONNEL_OFFICE_GBX',
					     		avalue   => l_groupbox_name
						  );
      l_wgi_error_note     := 'Please process the WGI Request for Personnel Action manually
                                which has been routed to your Personnel office  Groupbox :' || l_groupbox_name;
      end if;
	if l_valid_grpbox then
	   GetRoutingGroupDetails (
					   p_groupbox_name      => l_groupbox_name
					  ,p_groupbox_id        => l_groupbox_id
					  ,p_routing_group_id   => l_routing_group_id
					  ,p_groupbox_desc      => l_groupbox_desc
                                ,p_routing_group_name => l_routing_group_name
                                ,p_routing_group_desc => l_routing_group_desc
					  );
      else
	   wf_engine.SetItemAttrText( itemtype	=> ItemType,
			      		itemkey  	=> Itemkey,
	  		 	      	aname 	=> 'ERROR_MSG',
				      	avalue	=> 'Groupbox is not valid or invalid for this Employee. ' );
	end if;
      if l_routing_group_id is not null then
         update_sf52_action_taken(p_pa_request_id  	=> itemkey,
					    p_routing_group_id	=> l_routing_group_id,
					    p_groupbox_id		=> l_groupbox_id,
					    p_action_taken	=> 'NOT_ROUTED',
                                  p_gbx_user_id       => l_gbx_user_id);
      else
  	  wf_engine.SetItemAttrText ( itemtype	=> ItemType,
		      			itemkey  	=> Itemkey,
  		 	      		aname 	=> 'ERROR_MSG',
			      		avalue	=> 'Routing group does not exist for this Employee. ' );
      end if;
	--
      SetDestination(	 p_request_id		=>	itemkey
				,p_person_id		=>	l_person_id
				,p_position_id		=>	l_position_id
				,p_effective_date 	=>	l_effective_date
				,p_office_symbol_name	=>	l_office_symbol_name
				,p_line1			=>	l_line1
				,p_line2			=>	l_line2
				,p_line3			=>	l_line3
				,p_line4			=>	l_line4
				,p_line5			=>	l_line5
				,p_line6			=>	l_line6
				,p_line7			=>	l_line7
                        ,p_routing_group        =>    l_routing_group
			);
	wf_engine.SetItemAttrText	(
	 						itemtype => Itemtype,
					     		itemkey  => Itemkey,
					     		aname    => 'LINE1',
					     		avalue   => l_line1
						  );
	wf_engine.SetItemAttrText	(
	 						itemtype => Itemtype,
					     		itemkey  => Itemkey,
					     		aname    => 'LINE2',
					     		avalue   => l_line2
						  );
	wf_engine.SetItemAttrText	(
	 						itemtype => Itemtype,
					     		itemkey  => Itemkey,
					     		aname    => 'LINE3',
					     		avalue   => l_line3
						  );
	wf_engine.SetItemAttrText	(
	 						itemtype => Itemtype,
					     		itemkey  => Itemkey,
					     		aname    => 'LINE4',
					     		avalue   => l_line4
						  );
      wf_engine.SetItemAttrText	(
	 						itemtype => Itemtype,
					     		itemkey  => Itemkey,
					     		aname    => 'LINE5',
					     		avalue   => l_line5
						  );
      wf_engine.SetItemAttrText	(
	 						itemtype => Itemtype,
					     		itemkey  => Itemkey,
					     		aname    => 'LINE6',
					     		avalue   => l_line6
						  );
      wf_engine.SetItemAttrText	(
	 						itemtype => Itemtype,
					     		itemkey  => Itemkey,
					     		aname    => 'LINE7',
					     		avalue   => l_line7
						  );
      wf_engine.SetItemAttrText	(
	 						itemtype => Itemtype,
					     		itemkey  => Itemkey,
					     		aname    => 'WGI_ERROR_NOTE',
					     		avalue   => l_wgi_error_note
						  );
      wf_engine.SetItemAttrText(      itemtype => Itemtype,
                                      itemkey  => Itemkey,
                                      aname    => 'FROM_NAME',
                                      avalue   =>  FND_GLOBAL.USER_NAME() );
      wf_engine.SetItemAttrText	(
							itemtype => Itemtype,
							itemkey  => Itemkey,
			   		  		aname    => 'OFFICE_SYMBOL',
			 				avalue   => l_office_symbol_name
						  );
      wf_engine.SetItemAttrText	(
							itemtype => Itemtype,
							itemkey  => Itemkey,
			   		  		aname    => 'ROUTING_GROUP',
			 				avalue   => l_routing_group
						  );
      if l_valid_grpbox then
 	   result := 'COMPLETE:YES';
	   return;
      else
	   wf_engine.SetItemAttrText	(
							itemtype => Itemtype,
					     		itemkey  => Itemkey,
					     		aname    => 'ERROR_MSG',
					     		avalue   => 'Personnel Groupbox of the employee is invalid. '
							);
	   result := 'COMPLETE:NO';
	   return;
      end if;
--
end if;
--
  result := '';
  return;
--
--
exception
  when others then
    -- NOCOPY Changes
    result := l_result;
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('WGI', 'ghr_wf_wgi_pkg.FindDestPerOfficeGbx',itemtype, itemkey, to_char(actid), funcmode);
    raise;
--
end FindDestPerOfficeGbx;
--
--
--
--
procedure update_sf52_for_wgi_denial ( itemtype	in varchar2,
						  itemkey  	in varchar2,
						  actid	in number,
						  funcmode	in varchar2,
						  result	in out nocopy  varchar2) is
--
--
 	l_u_prh_object_version_number  	number;
 	l_i_pa_routing_history_id	   	number;
 	l_i_prh_object_version_number  	number;
	l_par_object_version_number	   	ghr_pa_requests.object_version_number%TYPE;
        l_person_id                         ghr_pa_requests.person_id%TYPE;
	l_effective_date				ghr_pa_requests.effective_date%TYPE;
        l_pay_rate_determinant    	      ghr_pa_requests.pay_rate_determinant%TYPE;
	l_first_noa_code				ghr_pa_requests.first_noa_code%TYPE;
	l_first_noa_id				ghr_pa_requests.first_noa_id%TYPE;
	l_first_noa_desc				ghr_pa_requests.first_noa_desc%TYPE;
        l_first_action_la_code1			ghr_pa_requests.first_action_la_code1%TYPE;
        l_first_action_la_desc1			ghr_pa_requests.first_action_la_desc1%TYPE;
        l_first_action_la_code2			ghr_pa_requests.first_action_la_code2%TYPE;
        l_first_action_la_desc2			ghr_pa_requests.first_action_la_desc2%TYPE;
	l_validate	   				boolean := false;
	l_from_adj_basic_pay	   		ghr_pa_requests.from_adj_basic_pay%TYPE;
	l_from_basic_pay	   			ghr_pa_requests.from_basic_pay%TYPE;
	l_from_grade_or_level	   		ghr_pa_requests.from_grade_or_level%TYPE;
	l_from_locality_adj	   		ghr_pa_requests.from_locality_adj%TYPE;
	l_from_occ_code	   			ghr_pa_requests.from_occ_code%TYPE;
	l_from_other_pay_amount	   		ghr_pa_requests.from_other_pay_amount%TYPE;
	l_from_pay_basis	   			ghr_pa_requests.from_pay_basis%TYPE;
	l_from_pay_plan	   			ghr_pa_requests.from_pay_plan%TYPE;
 	l_from_position_id	   		ghr_pa_requests.from_position_id%TYPE;
	l_from_position_org_line1   		ghr_pa_requests.from_position_org_line1%TYPE;
	l_from_position_org_line2	   	ghr_pa_requests.from_position_org_line2%TYPE;
	l_from_position_org_line3		ghr_pa_requests.from_position_org_line3%TYPE;
	l_from_position_org_line4		ghr_pa_requests.from_position_org_line4%TYPE;
	l_from_position_org_line5		ghr_pa_requests.from_position_org_line5%TYPE;
	l_from_position_org_line6		ghr_pa_requests.from_position_org_line6%TYPE;
	l_from_position_number	   		ghr_pa_requests.from_position_number%TYPE;
	l_from_position_seq_no	   		ghr_pa_requests.from_position_seq_no%TYPE;
	l_from_position_title	   		ghr_pa_requests.from_position_title%TYPE;
	l_from_step_or_rate	   		ghr_pa_requests.from_step_or_rate%TYPE;
	l_from_total_salary	   		ghr_pa_requests.from_total_salary%TYPE;
        l_retained_grade_rec                  ghr_pay_calc.retained_grade_rec_type;
       -- Remarks
        l_pa_remark_id                         ghr_pa_remarks.pa_remark_id%TYPE;
        l_pre_object_version_number            ghr_pa_remarks.object_version_number%TYPE;
        l_remark_id1                           ghr_pa_remarks.remark_id%TYPE                := Null;
     l_remark_desc1                         ghr_pa_remarks.description%type              := Null;
     l_remark1_info1                        ghr_pa_remarks.remark_code_information1%TYPE := Null;
     l_remark1_info2                        ghr_pa_remarks.remark_code_information2%TYPE := Null;
     l_remark1_info3                        ghr_pa_remarks.remark_code_information3%TYPE := Null;
     l_remark_id2                           ghr_pa_remarks.remark_id%TYPE                := Null;
     l_remark_desc2                         ghr_pa_remarks.description%type              := Null;
     l_remark2_info1                        ghr_pa_remarks.remark_code_information1%TYPE := Null;
     l_remark2_info2                        ghr_pa_remarks.remark_code_information2%TYPE := Null;
     l_remark2_info3                        ghr_pa_remarks.remark_code_information3%TYPE := Null;
     --NOCOPY Changes
     l_result                         VARCHAR2(250);
--
-- Fetch PA request details
  cursor csr_get_par_info is
	select
            object_version_number,
            person_id,
	      effective_date,
		pay_rate_determinant,
	      first_action_la_code1,
	      first_action_la_desc1,
	      first_noa_code,
  	      first_noa_desc,
		first_noa_id,
		from_adj_basic_pay,
		from_basic_pay,
		from_grade_or_level,
		from_locality_adj,
		from_occ_code,
		from_other_pay_amount,
		from_pay_basis,
		from_pay_plan,
	 	from_position_id,
		from_position_org_line1,
		from_position_org_line2,
		from_position_org_line3,
		from_position_org_line4,
		from_position_org_line5,
		from_position_org_line6,
		from_position_number,
		from_position_seq_no,
		from_position_title,
		from_step_or_rate,
		from_total_salary
	from ghr_pa_requests
      where pa_request_id = to_number(itemkey);
--
--
begin
    -- NOCOPY Changes
    l_result := result;
if funcmode = 'RUN' then
	-- Open cursor csr_get_par_info
      open csr_get_par_info;
      fetch csr_get_par_info into
		l_par_object_version_number,l_person_id,l_effective_date, l_pay_rate_determinant,
		l_first_action_la_code1,  l_first_action_la_desc1, l_first_noa_code,
            l_first_noa_desc, l_first_noa_id, l_from_adj_basic_pay,
            l_from_basic_pay, l_from_grade_or_level, l_from_locality_adj,
            l_from_occ_code, l_from_other_pay_amount, l_from_pay_basis,
            l_from_pay_plan, l_from_position_id,l_from_position_org_line1,
            l_from_position_org_line2, l_from_position_org_line3, l_from_position_org_line4,
            l_from_position_org_line5, l_from_position_org_line6, l_from_position_number,
            l_from_position_seq_no,	l_from_position_title, l_from_step_or_rate,
            l_from_total_salary;
  if csr_get_par_info%notfound then
     -- if the cursor does not return a row then we must set the out
     -- parameter to null
     null;
 end if;
-- close the cursor
close csr_get_par_info;
	-- Set values of the to side
	--
	l_first_noa_code := 888;
	--
      ghr_wgi_pkg.get_noa_code_desc ( p_code => l_first_noa_code,
                          p_effective_date  => l_effective_date,
				  p_nature_of_action_id  => l_first_noa_id,
				  p_description => l_first_noa_desc
			       );
      begin
          l_retained_grade_rec  := ghr_pc_basic_pay.get_retained_grade_details
                                                (p_person_id      => l_person_id
                                                ,p_effective_date => l_effective_date);
      exception
         When ghr_pay_calc.pay_calc_message then
         null;
      end;

      --
      -- Get Legal Authority Description
      --
       ghr_wgi_pkg.derive_legal_auth_cd_remarks (
                               p_first_noa_code          => l_first_noa_code,
                               p_pay_rate_determinant    => l_pay_rate_determinant,
                               p_from_pay_plan           => l_from_pay_plan,
                               p_grade_or_level          => l_from_grade_or_level,
                               p_step_or_rate            => l_from_step_or_rate,
                               p_retained_pay_plan       => l_retained_grade_rec.pay_plan,
                               p_retained_grade_or_level => l_retained_grade_rec.grade_or_level,
                               p_retained_step_or_rate   => l_retained_grade_rec.step_or_rate,
                               -- Bug#5204589 Added p_temp_step parameter.
                               p_temp_step               => l_retained_grade_rec.temp_step,
                               p_effective_date          => l_effective_date,
                               p_first_action_la_code1   => l_first_action_la_code1,
                               p_first_action_la_desc1   => l_first_action_la_desc1,
                               p_first_action_la_code2   => l_first_action_la_code2,
                               p_first_action_la_desc2   => l_first_action_la_desc2,
                               p_remark_id1              => l_remark_id1,
                               p_remark_desc1            => l_remark_desc1,
                               p_remark1_info1           => l_remark1_info1,
                               p_remark1_info2           => l_remark1_info2,
                               p_remark1_info3           => l_remark1_info3,
                               p_remark_id2              => l_remark_id2,
                               p_remark_desc2            => l_remark_desc2,
                               p_remark2_info1           => l_remark2_info1,
                               p_remark2_info2           => l_remark2_info2,
                               p_remark2_info3           => l_remark2_info3
                             );

	--
	--
      ghr_sf52_api.update_sf52(
		p_validate	   				=> l_validate,
		p_pa_request_id	   			=> to_number(itemkey),
		p_par_object_version_number	   	=> l_par_object_version_number,
	      p_first_action_la_code1			=> l_first_action_la_code1,
	      p_first_action_la_desc1			=> l_first_action_la_desc1,
	      p_first_action_la_code2			=> l_first_action_la_code2,
	      p_first_action_la_desc2			=> l_first_action_la_desc2,
	      p_first_noa_code				=> l_first_noa_code,
	      p_first_noa_desc				=> l_first_noa_desc,
		p_first_noa_id	   			=> l_first_noa_id,
	  	p_to_grade_id	   			=> null,
	  	p_to_job_id	   				=> null,
		p_to_au_overtime               	=> null,
		p_to_auo_premium_pay_indicator	=> null,
		p_to_availability_pay          	=> null,
		p_to_ap_premium_pay_indicator   	=> null,
		p_to_retention_allowance       	=> null,
		p_to_supervisory_differential  	=> null,
		p_to_staffing_differential     	=> null,
	  	p_to_adj_basic_pay	   		=> l_from_adj_basic_pay,
	  	p_to_basic_pay	   			=> l_from_basic_pay,
	  	p_to_grade_or_level	   		=> l_from_grade_or_level,
	  	p_to_locality_adj	   			=> l_from_locality_adj,
	  	p_to_occ_code	   			=> l_from_occ_code,
	  	p_to_other_pay_amount	   		=> l_from_other_pay_amount,
	  	p_to_pay_basis	   			=> l_from_pay_basis,
	  	p_to_pay_plan	   			=> l_from_pay_plan,
		p_to_position_id	   			=> l_from_position_id,
		p_to_position_org_line1			=> l_from_position_org_line1,
		p_to_position_org_line2			=> l_from_position_org_line2,
		p_to_position_org_line3			=> l_from_position_org_line3,
		p_to_position_org_line4			=> l_from_position_org_line4,
		p_to_position_org_line5			=> l_from_position_org_line5,
		p_to_position_org_line6			=> l_from_position_org_line6,
	  	p_to_position_number	   		=> l_from_position_number,
	  	p_to_position_seq_no	   		=> l_from_position_seq_no,
	  	p_to_position_title	   		=> l_from_position_title,
	  	p_to_step_or_rate	   			=> l_from_step_or_rate,
	  	p_to_total_salary	   			=> l_from_total_salary,
	  	p_u_action_taken	   			=> 'NOT_ROUTED',
	 	p_u_prh_object_version_number  	=> l_u_prh_object_version_number,
	 	p_i_pa_routing_history_id	   	=> l_i_pa_routing_history_id,
	 	p_i_prh_object_version_number  	=> l_i_prh_object_version_number
		);

            -- Create remarks if any, derived from above .
            If l_remark_id1 is not null then
              ghr_pa_remarks_api.create_pa_remarks
              (p_pa_request_id               =>    to_number(itemkey),
               p_remark_id                   =>    l_remark_id1,
               p_description                 =>    l_remark_desc1,
               p_remark_code_information1    =>    l_remark1_info1,
               p_remark_code_information2    =>    l_remark1_info2,
               p_remark_code_information3    =>    l_remark1_info3,
               p_pa_remark_id                =>    l_pa_remark_id,
               p_object_version_number       =>    l_pre_object_version_number
               );
            End if;
            If l_remark_id2 is not null then
              ghr_pa_remarks_api.create_pa_remarks
              (p_pa_request_id               =>    to_number(itemkey),
               p_remark_id                   =>    l_remark_id2,
               p_description                 =>    l_remark_desc2,
               p_remark_code_information1    =>    l_remark2_info1,
               p_remark_code_information2    =>    l_remark2_info2,
               p_remark_code_information3    =>    l_remark2_info3,
               p_pa_remark_id                =>    l_pa_remark_id,
               p_object_version_number       =>    l_pre_object_version_number
               );
             End if;

	result := 'COMPLETE:';
	return;
end if;
--
  result := '';
  return;
--
exception
  when others then
    -- NOCOPY Changes
    result := l_result;
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('WGI', 'ghr_wf_wgi_pkg.update_sf52_for_wgi_denial',itemtype, itemkey, to_char(actid), funcmode);
    raise;
--
end update_sf52_for_wgi_denial;
--
--
--
--
procedure CheckNtfyPOI ( 	itemtype	in varchar2,
					itemkey  	in varchar2,
					actid		in number,
					funcmode	in varchar2,
					result	in out nocopy  varchar2	) is
--
l_text	varchar2(30);
l_result      VARCHAR2(250);
--
--
begin
--
--
   -- NOCOPY Changes
   l_result := result;
   if funcmode = 'RUN' then
	   l_text	:=  wf_engine.GetItemAttrText(	itemtype => Itemtype,
								  	itemkey  => Itemkey,
								  	aname    => 'NTFY_PEROFC_OF_APRVL');
	   if l_text = 'NO' then
		result := 'COMPLETE:NO';
		return;
	   else
		result := 'COMPLETE:YES';
		return;
	   end if;
   end if;
--
  result := '';
  return;
--
--
exception
  when others then
    -- NOCOPY Changes
    result := l_result;
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('WGI', 'ghr_wf_wgi_pkg.CheckNtfyPOI',itemtype, itemkey, to_char(actid), funcmode);
    raise;
--
--
end CheckNtfyPOI;
--
--
procedure populate_shadow( itemtype	in varchar2,
						  itemkey  	in varchar2,
						  actid	in number,
						  funcmode	in varchar2,
						  result	in out nocopy  varchar2) is
--
--
-- Fetch PA request details
  cursor csr_par_info is
	select *
	from ghr_pa_requests
      where pa_request_id = to_number(itemkey);
  cursor csr_check_par is
	select count(*)
	from ghr_pa_requests
      where pa_request_id = to_number(itemkey);
--
l_sf52_data_in_rec  ghr_pa_requests%rowtype;
l_count		  number;
l_result      VARCHAR2(250);
--
--
begin
-- NOCOPY Changes
l_result := result;
if funcmode = 'RUN' then
	-- Open cursor csr_get_par_info
      open csr_par_info;
      fetch csr_par_info into l_sf52_data_in_rec;
  if csr_par_info%notfound then
     -- if the cursor does not return a row then we must set the out
     -- parameter to null
     null;
  else
	-- Check if PA Request ID exists
	open csr_check_par;
      fetch csr_check_par into l_count;
      if l_count = 1 then
		GHR_PROCESS_SF52.create_shadow_row ( p_sf52_data => l_sf52_data_in_rec);
      else
	     -- if the cursor does not return a row then we must set the out
	     -- parameter to null
     	     null;
	end if;
      close csr_check_par;
  end if;
  -- close the cursor
  close csr_par_info;

  result := 'COMPLETE:';
  return;
end if;
--
  result := '';
  return;
--
exception
  when others then
    -- NOCOPY Changes
    result := l_result;
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('WGI', 'ghr_wf_wgi_pkg.populate_shadow',itemtype, itemkey, to_char(actid), funcmode);
    raise;
--
end populate_shadow;
--
--
end ghr_wf_wgi_pkg;

/
