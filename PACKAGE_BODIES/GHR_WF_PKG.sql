--------------------------------------------------------
--  DDL for Package Body GHR_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_WF_PKG" AS
/* $Header: ghwfpkg.pkb 120.1.12010000.5 2009/06/16 10:14:28 vmididho ship $ */
--
-- Procedure
--	StartSF52Process
--
-- Description
--	Start the SF-52 workflow process for the given p_pa_request_id
--
PROCEDURE StartSF52Process
(	p_pa_request_id in number,
	p_forward_to_name in varchar2,
      p_error_msg in varchar2 default null
) is
--
l_ItemType 				varchar2(30) := 'GHR_SF52';
l_ItemKey  				varchar2(30) := p_pa_request_id;
l_forward_from_display_name	varchar2(100);
l_load_form				varchar2(200); --Bug# 6923642 modifier length 100 to 200
l_load_prh				varchar2(100);
l_subject			varchar2(500);
l_line1			varchar2(500);
l_line2			varchar2(500);
l_line3			varchar2(500);
l_line4			varchar2(500);
l_line5			varchar2(500);
l_line5a			varchar2(500);
l_line6			varchar2(500);
l_line7			varchar2(500);
l_line8			varchar2(500);
l_line9			varchar2(500);
--
begin

	-- Creates a new runtime process for an application item (SF-52)
	--
 hr_utility.set_location('l_proc',1);
	wf_engine.createProcess( ItemType => l_ItemType,
					 ItemKey  => l_ItemKey,
					 process  => 'SF52_APPROVAL_PROCESS' );
	--
	--
 hr_utility.set_location('l_proc',2);
	wf_engine.SetItemAttrNumber ( itemtype	=> l_ItemType,
			      		itemkey  	=> l_Itemkey,
  		 	      		aname 	=> 'PA_REQUEST_ID',
			      		avalue	=> p_pa_request_id );
 hr_utility.set_location('l_proc',3);
	wf_engine.SetItemAttrText(  	itemtype => l_itemtype,
				     		itemkey  => l_itemkey,
				     		aname    => 'FORWARD_TO_NAME',
				     		avalue   => p_forward_to_name );

 hr_utility.set_location('l_proc',4);
 hr_utility.set_location('l_proc',5);
	wf_engine.SetItemAttrText(  	itemtype => l_itemtype,
			     			itemkey  => l_itemkey,
			     			aname    => 'FORWARD_FROM_DISPLAY_NAME',
			     			avalue   =>  FND_GLOBAL.USER_NAME() );
   -- Bug # 8597583 modified parameters to pass with out double quotes

 hr_utility.set_location('l_proc',6);
	l_load_form := 'GHRWS52L:p_pa_request_id=' || l_Itemkey
                     || ' p_inbox_query_only=NO' || ' WORKFLOW_NAME=GHR_US_PA_REQUEST'
                     || ' p_wf_notification_id=&#NID';--Bug# 6923642
	wf_engine.SetItemAttrText(  	itemtype => l_itemtype,
			     			itemkey  => l_itemkey,
			     			aname    => 'LOAD_SF52',
			     			avalue   => l_load_form
					 );
	l_load_prh := 'GHRWSPRH:p_pa_request_id=' || l_Itemkey;
	wf_engine.SetItemAttrText(  	itemtype => l_itemtype,
			     			itemkey  => l_itemkey,
			     			aname    => 'LOAD_PRH',
			     			avalue   => l_load_prh
					 );
--
 hr_utility.set_location('l_proc',7);
		ghr_wf_pkg.SetDestinationDetails (  p_pa_request_id  => l_itemkey,
								p_subject => l_subject,
								p_line1 => l_line1,
								p_line2 => l_line2,
								p_line3 => l_line3,
								p_line4 => l_line4,
								p_line5 => l_line5,
								p_line6 => l_line6,
								p_line7 => l_line7,
								p_line8 => l_line8,
								p_line9 => l_line9
					    		   );
--
--
--
		wf_engine.SetItemAttrText(  	itemtype => l_itemtype,
			     			itemkey  => l_itemkey,
			     			aname    => 'SUBJECT_HDR',
			     			avalue   => l_subject
						 );
		wf_engine.SetItemAttrText(  	itemtype => l_itemtype,
			     			itemkey  => l_itemkey,
			     			aname    => 'LINE1',
			     			avalue   => l_line1
						 );
		wf_engine.SetItemAttrText(  	itemtype => l_itemtype,
			     			itemkey  => l_itemkey,
			     			aname    => 'LINE2',
			     			avalue   => l_line2
						 );
/*
		wf_engine.SetItemAttrText(  	itemtype => l_itemtype,
			     			itemkey  => l_itemkey,
			     			aname    => 'PROPOSED_EFF_DATE',
			     			avalue   => l_line2a
						 );
*/
		wf_engine.SetItemAttrText(  	itemtype => l_itemtype,
			     			itemkey  => l_itemkey,
			     			aname    => 'LINE3',
			     			avalue   => l_line3
						 );
		wf_engine.SetItemAttrText(  	itemtype => l_itemtype,
			     			itemkey  => l_itemkey,
			     			aname    => 'LINE4',
			     			avalue   => l_line4
					 );
		wf_engine.SetItemAttrText(  	itemtype => l_itemtype,
			     			itemkey  => l_itemkey,
			     			aname    => 'LINE5',
			     			avalue   => l_line5
					 );
/*
		wf_engine.SetItemAttrText(  	itemtype => l_itemtype,
			     			itemkey  => l_itemkey,
			     			aname    => 'DATE_INITIATED',
			     			avalue   => l_line5a
					 );
*/
		wf_engine.SetItemAttrText(  	itemtype => l_itemtype,
			     			itemkey  => l_itemkey,
			     			aname    => 'LINE6',
			     			avalue   => l_line6
					 );
		wf_engine.SetItemAttrText(  	itemtype => l_itemtype,
			     			itemkey  => l_itemkey,
			     			aname    => 'LINE7',
			     			avalue   => l_line7
					 );
		wf_engine.SetItemAttrText(  	itemtype => l_itemtype,
			     			itemkey  => l_itemkey,
			     			aname    => 'LINE8',
			     			avalue   => l_line8
					 );
      if ( CheckItemAttribute ( p_name => 'LINE9',
                                p_itemtype => l_itemtype,
                                p_itemkey => l_itemkey ) ) then
		wf_engine.SetItemAttrText(  	itemtype => l_itemtype,
			     			itemkey  => l_itemkey,
			     			aname    => 'LINE9',
			     			avalue   => l_line9
					 );
      end if;
		-- Added for Future Action process
		if p_error_msg Is Not Null then
			wf_engine.SetItemAttrText(
						itemtype => l_itemtype,
			     			itemkey  => l_itemkey,
			     			aname    => 'LINE_ERROR',
			     			avalue   => 'Update HR Error : '
                                            || substr(p_error_msg,1,1000)
					  );
		end if;
	-- Start the SF-52 workflow process for SF52_APPROVAL_PROCESS
	--
	wf_engine.StartProcess ( ItemType => l_ItemType,
					 ItemKey  => l_ItemKey );
	--
	--
 hr_utility.set_location('l_proc',10);
end StartSF52Process;
--
--
PROCEDURE UpdateRHistoryProcess( itemtype	in varchar2,
					   itemkey  in varchar2,
					   actid	in number,
					   funcmode	in varchar2,
					   result	in out nocopy varchar2) is
--
--
--
l_result varchar2(4000);
begin
l_result := result;
--
--

	if funcmode = 'RUN' then
		ghr_prh_api.upd_date_notif_sent (p_pa_request_id => itemkey,
							   p_date_notification_sent => sysdate);
      result := ' ';
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
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('GHR_SF52', 'ghr_wf_pkg.UpdateRHistoryProcess',itemtype, itemkey, to_char(actid), funcmode);
          --
          -- Reset IN OUT parameters and set OUT parameters
          --
        result := l_result;

    raise;
--
end UpdateRHistoryProcess;
--
--
--
--
PROCEDURE UpdateFinalFYIWFUsers  ( itemtype	in varchar2,
					   itemkey  in varchar2,
					   actid	in number,
					   funcmode	in varchar2,
					   result	in out nocopy varchar2) is
--
--
--
cursor csr_get_approver_name is
            SELECT user_name from  ghr_pa_routing_history
            where pa_request_id = itemkey
                  and approval_status = 'APPROVE'
            order by  pa_routing_history_id desc;
--
cursor csr_get_upd_hr_user_name is
            SELECT user_name from  ghr_pa_routing_history
            where pa_request_id = itemkey
                  and action_taken in ('UPDATE_HR_COMPLETE','ENDED')
            order by  pa_routing_history_id desc;
--
l_approver_name        		 ghr_pa_routing_history.user_name%TYPE;
l_upd_hr_user_name        	 ghr_pa_routing_history.user_name%TYPE;
l_line3			       varchar2(500);
l_load_form				 varchar2(200); --Bug# 7312949
l_result                       varchar2(4000);
--
--
begin
--
l_result := result;
--
	if funcmode = 'RUN' then
	  open csr_get_approver_name;
	  fetch csr_get_approver_name  into l_approver_name;
	  if csr_get_approver_name%notfound then
		null;
	      --  ?? Check with ****
		--		hr_utility.set_message(8301,'GHR_38211_NOA_FAMILY_NOTFOUND');
		--          hr_utility.raise_error;
	  end if;
        close csr_get_approver_name;
        --
        --
	  open csr_get_upd_hr_user_name;
	  fetch csr_get_upd_hr_user_name  into l_upd_hr_user_name;
	  if csr_get_upd_hr_user_name%notfound then
		null;
	      --  ?? Check with ****
		--		hr_utility.set_message(8301,'GHR_38211_NOA_FAMILY_NOTFOUND');
		--          hr_utility.raise_error;
	  end if;
        close csr_get_upd_hr_user_name;
        --
        if l_approver_name Is Null then
            l_approver_name := l_upd_hr_user_name;
        end if;
        if l_upd_hr_user_name Is Null then
            l_upd_hr_user_name := l_approver_name;
        end if;
        --
        if ( CheckItemAttribute ( p_name => 'APPROVER_NAME',
                                p_itemtype => itemtype,
                                p_itemkey => itemkey ) and (l_approver_name Is Not Null) ) then
  	    wf_engine.SetItemAttrText(  itemtype => itemtype,
			     			itemkey  => itemkey,
			     			aname    => 'APPROVER_NAME',
			     			avalue   => l_approver_name
	 				   );
       end if;
       if ( CheckItemAttribute ( p_name => 'PERSON_UPDATE_HR',
                                p_itemtype => itemtype,
                                p_itemkey => itemkey ) and (l_upd_hr_user_name Is Not Null) ) then
          wf_engine.SetItemAttrText(  itemtype => itemtype,
			     			itemkey  => itemkey,
			     			aname    => 'PERSON_UPDATE_HR',
			     			avalue   => l_upd_hr_user_name
	 				 );
       end if;
	-- Third line of message
           --	l_line3         := 'Current Status                 : ' || 'UPDATE_HR_COMPLETE';
           --	wf_engine.SetItemAttrText(  	itemtype => itemtype,
           --			     			itemkey  => itemkey,
           --			     			aname    => 'LINE3',
           --			     			avalue   => l_line3
           --					 );
      end if;

     if ( CheckItemAttribute (  p_name => 'PA_REQUEST_RO',
                                p_itemtype => itemtype,
                                p_itemkey => itemkey ) ) then
   -- Bug # 8597583 modified parameters to pass with out double quotes

	 l_load_form := 'GHRWS52L:p_pa_request_id=' || Itemkey
                      || ' p_inbox_query_only=YES' || ' WORKFLOW_NAME=GHR_US_PA_REQUEST'
                      || ' p_wf_notification_id=&#NID' ;--Bug# 6923642
	 wf_engine.SetItemAttrText(  	itemtype => itemtype,
			     			itemkey  => itemkey,
			     			aname    => 'PA_REQUEST_RO',
			     			avalue   => l_load_form
					 );
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
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('GHR_SF52', 'ghr_wf_pkg.UpdateFinalFYIWFUsers',itemtype, itemkey, to_char(actid), funcmode);
          --
          -- Reset IN OUT parameters and set OUT parameters
          --
        result := l_result;
    raise;
--
end UpdateFinalFYIWFUsers ;
--
--
--
--
PROCEDURE CheckIFSameFYIUsers( itemtype	in varchar2,
					   itemkey  in varchar2,
					   actid	in number,
					   funcmode	in varchar2,
					   result	in out nocopy varchar2) is
--
--
l_approver_name        		 ghr_pa_routing_history.user_name%TYPE;
l_upd_hr_user_name        	 ghr_pa_routing_history.user_name%TYPE;
--
l_result varchar2(4000);
begin
l_result := result;
--
--
	if funcmode = 'RUN' then
        if ( CheckItemAttribute ( p_name => 'APPROVER_NAME',
                                 p_itemtype => itemtype,
	                           p_itemkey => itemkey ) ) then
        --
	               l_approver_name := wf_engine.GetItemAttrText
			                  	(itemtype => itemtype,
                    			       itemkey  => itemkey,
	     		                     	 aname    => 'APPROVER_NAME'
                                           );
        end if;
        --
        if ( CheckItemAttribute ( p_name => 'PERSON_UPDATE_HR',
                                 p_itemtype => itemtype,
	                           p_itemkey => itemkey )  ) then
        --
	               l_upd_hr_user_name := wf_engine.GetItemAttrText
			                  	(itemtype => itemtype,
                    			       itemkey  => itemkey,
	     		                     	 aname    => 'PERSON_UPDATE_HR'
                                           );
        end if;

        if l_approver_name = l_upd_hr_user_name then
                   result := 'COMPLETE:YES';
	  		return;
        else
                  result := 'COMPLETE:NO';
			return;
        end if;
--
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
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('GHR_SF52', 'ghr_wf_pkg.CheckIFSameFYIUsers',itemtype, itemkey, to_char(actid), funcmode);
          --
          -- Reset IN OUT parameters and set OUT parameters
          --
          result := l_result;
    raise;
--
end CheckIFSameFYIUsers;
--
--
--
--
procedure FindDestination( 	itemtype	in varchar2,
					itemkey  	in varchar2,
					actid		in number,
					funcmode	in varchar2,
					result	in out nocopy varchar2	) is
--
--
l_user_name        		 ghr_pa_routing_history.user_name%TYPE;
l_action_taken			 ghr_pa_routing_history.action_taken%TYPE;
l_groupbox_name        		 ghr_groupboxes.name%TYPE;
l_subject			varchar2(500);
l_line1			varchar2(500);
l_line2			varchar2(500);
l_line3			varchar2(500);
l_line4			varchar2(500);
l_line5			varchar2(500);
l_line6			varchar2(500);
l_line7			varchar2(500);
l_line8			varchar2(500);
l_line9			varchar2(500);
--
--
l_result varchar2(4000);
begin
l_result := result;
--
if funcmode = 'RUN' then
--
		ghr_wf_pkg.SetDestinationDetails (  p_pa_request_id  => itemkey,
								p_subject => l_subject,
								p_line1 => l_line1,
								p_line2 => l_line2,
								p_line3 => l_line3,
								p_line4 => l_line4,
								p_line5 => l_line5,
								p_line6 => l_line6,
								p_line7 => l_line7,
								p_line8 => l_line8,
								p_line9 => l_line9
					    		   );
		wf_engine.SetItemAttrText(  	itemtype => itemtype,
			     			itemkey  => itemkey,
			     			aname    => 'SUBJECT_HDR',
			     			avalue   => l_subject
						 );
		wf_engine.SetItemAttrText(  	itemtype => itemtype,
			     			itemkey  => itemkey,
			     			aname    => 'LINE1',
			     			avalue   => l_line1
						 );
		wf_engine.SetItemAttrText(  	itemtype => itemtype,
			     			itemkey  => itemkey,
			     			aname    => 'LINE2',
			     			avalue   => l_line2
						 );
/*
		wf_engine.SetItemAttrText(  	itemtype => itemtype,
			     			itemkey  => itemkey,
			     			aname    => 'PROPOSED_EFF_DATE',
			     			avalue   => l_line2a
						 );
*/
		wf_engine.SetItemAttrText(  	itemtype => itemtype,
			     			itemkey  => itemkey,
			     			aname    => 'LINE3',
			     			avalue   => l_line3
						 );
		wf_engine.SetItemAttrText(  	itemtype => itemtype,
			     			itemkey  => itemkey,
			     			aname    => 'LINE4',
			     			avalue   => l_line4
					 );
		wf_engine.SetItemAttrText(  	itemtype => itemtype,
			     			itemkey  => itemkey,
			     			aname    => 'LINE5',
			     			avalue   => l_line5
					 );
/*
		wf_engine.SetItemAttrText(  	itemtype => itemtype,
			     			itemkey  => itemkey,
			     			aname    => 'DATE_INITIATED',
			     			avalue   => l_line5a
					 );
*/
		wf_engine.SetItemAttrText(  	itemtype => itemtype,
			     			itemkey  => itemkey,
			     			aname    => 'LINE6',
			     			avalue   => l_line6
					 );
		wf_engine.SetItemAttrText(  	itemtype => itemtype,
			     			itemkey  => itemkey,
			     			aname    => 'LINE7',
			     			avalue   => l_line7
					 );
		wf_engine.SetItemAttrText(  	itemtype => itemtype,
			     			itemkey  => itemkey,
			     			aname    => 'LINE8',
			     			avalue   => l_line8
					 );
if ( CheckItemAttribute ( p_name => 'LINE9',
                                p_itemtype => itemtype,
                                p_itemkey => itemkey ) ) then
		wf_engine.SetItemAttrText(  	itemtype => itemtype,
			     			itemkey  => itemkey,
			     			aname    => 'LINE9',
			     			avalue   => l_line9
					 );
 end if;
--
--
		ghr_wf_pkg.GetDestinationDetails (  p_pa_request_id  => itemkey,
							  	p_action_taken => l_action_taken,
                        		       	p_user_name => l_user_name,
							  	p_groupbox_name => l_groupbox_name
					    		   );
		if l_action_taken in ('CANCELED') then
			result := 'COMPLETE:CANCELED';
			return;
		elsif l_action_taken in ('UPDATE_HR_COMPLETE','ENDED') then
			result := 'COMPLETE:UPDATE_HR_COMPLETE';
			return;
		elsif l_action_taken in ('FUTURE_ACTION') then
			result := 'COMPLETE:FUTURE_ACTION';
			return;
		else
			--
			if l_user_name Is Not Null then
--
				wf_engine.SetItemAttrText(  	itemtype => Itemtype,
							     		itemkey  => Itemkey,
							     		aname    => 'FORWARD_TO_NAME',
							     		avalue   => l_user_name );
				result := 'COMPLETE:CONTINUE';
				return;
			else

				wf_engine.SetItemAttrText(  	itemtype => Itemtype,
							     		itemkey  => Itemkey,
							     		aname    => 'FORWARD_TO_NAME',
							     		avalue   => l_groupbox_name );
				result := 'COMPLETE:CONTINUE';
				return;
			end if;
			--
		end if;
--
--

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
--
exception
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('GHR_SF52', 'ghr_wf_pkg.FindDestination',itemtype, itemkey, to_char(actid), funcmode);
          --
          -- Reset IN OUT parameters and set OUT parameters
          --
          result := l_result;
    raise;
--
--
end FindDestination;
--
--
PROCEDURE GetDestinationDetails (
					  p_pa_request_id  in NUMBER,
					  p_action_taken OUT nocopy varchar2,
                                p_user_name OUT nocopy varchar2,
					  p_groupbox_name OUT nocopy varchar2
					  ) IS

-- Local variables
l_pa_routing_history_id        ghr_pa_routing_history.pa_routing_history_id%TYPE;
l_user_name        		 ghr_pa_routing_history.user_name%TYPE;
l_groupbox_id        		 ghr_pa_routing_history.groupbox_id%TYPE;
l_action_taken			 ghr_pa_routing_history.action_taken%TYPE;
l_groupbox_name        		 ghr_groupboxes.name%TYPE;
--
--
 cursor csr_pa_routing_history is
        SELECT  max(pa_routing_history_id)
        FROM    ghr_pa_routing_history
        WHERE   pa_request_id = p_pa_request_id;
--
 cursor csr_pah_details is
	  SELECT action_taken, user_name, groupbox_id
        FROM   ghr_pa_routing_history
        WHERE  pa_routing_history_id = l_pa_routing_history_id;
--
 cursor csr_gbx_details is
			SELECT name
			FROM GHR_GROUPBOXES
			WHERE GROUPBOX_ID = l_groupbox_id;
--
--
begin
-- This function will select from routing history table based User/ Groupbox Name which happens.
-- to be the next destination.
--
--
-- Get the last Routing History record
--
	  open csr_pa_routing_history;
	  fetch csr_pa_routing_history into l_pa_routing_history_id;
	  if csr_pa_routing_history%notfound then
		null;
	      --  ?? Check with ****
		--		hr_utility.set_message(8301,'GHR_38211_NOA_FAMILY_NOTFOUND');
		--          hr_utility.raise_error;
	  end if;
        close csr_pa_routing_history;
--
-- Get the routing history details
--
	  open csr_pah_details;
	  fetch csr_pah_details into l_action_taken, l_user_name, l_groupbox_id;
	  if csr_pah_details%notfound then
		null;
	      --  ?? Check with ****
		--		hr_utility.set_message(8301,'GHR_38211_NOA_FAMILY_NOTFOUND');
		--          hr_utility.raise_error;
	  end if;
        close csr_pah_details;
--
--
    	  if l_action_taken not in ('CANCELED','UPDATE_HR_COMPLETE','FUTURE_ACTION','ENDED') or l_action_taken is Null then
	  	if l_user_name is not null then
			p_user_name	   := l_user_name;
		else
			--
		      open csr_gbx_details;
		      fetch csr_gbx_details into l_groupbox_name;
		      if csr_gbx_details%notfound then
				null;
	      		--  ?? Check with ****
				--		hr_utility.set_message(8301,'GHR_38211_NOA_FAMILY_NOTFOUND');
				--          hr_utility.raise_error;
			else
				p_groupbox_name  := l_groupbox_name;
			end if;
		      close csr_gbx_details;
			--
		end if;
	  elsif l_action_taken in ('CANCELED','FUTURE_ACTION','UPDATE_HR_COMPLETE','ENDED') then
			p_action_taken := l_action_taken;
	  else
			p_action_taken := null;
	  end if;
--
 Exception when others then
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
       p_action_taken  := null;
       p_user_name  := null;
       p_groupbox_name  := null;
       raise;
END GetDestinationDetails;

-- Sets the Message lines
PROCEDURE SetDestinationDetails (
					  p_pa_request_id  in NUMBER,
					  p_subject OUT nocopy varchar2,
					  p_line1 OUT nocopy varchar2,
					  p_line2 OUT nocopy varchar2,
					  p_line3 OUT nocopy varchar2,
					  p_line4 OUT nocopy varchar2,
					  p_line5 OUT nocopy varchar2,
					  p_line6 OUT nocopy varchar2,
					  p_line7 OUT nocopy varchar2,
					  p_line8 OUT nocopy varchar2,
					  p_line9 OUT nocopy varchar2
					  ) is

-- Local variables
l_subject			varchar2(500);
l_line1			varchar2(500);
l_line2			varchar2(500);
l_line3			varchar2(500);
l_line4			varchar2(500);
l_line5			varchar2(500);
l_line6			varchar2(500);
l_line7			varchar2(500);
l_line8			varchar2(500);
l_line9			varchar2(500);
l_request_number        ghr_pa_requests.request_number%TYPE;
l_noa_family_code       ghr_pa_requests.noa_family_code%TYPE;
l_employee_first_name	ghr_pa_requests.employee_first_name%TYPE;
l_employee_last_name	ghr_pa_requests.employee_last_name%TYPE;
l_employee_middle_names	ghr_pa_requests.employee_middle_names%TYPE;
l_first_noa_desc		ghr_pa_requests.first_noa_desc%TYPE;
l_second_noa_desc		ghr_pa_requests.first_noa_desc%TYPE;
l_proposed_effective_date	ghr_pa_requests.proposed_effective_date%TYPE;
l_effective_date	       ghr_pa_requests.effective_date%TYPE;
l_requested_by_person_id ghr_pa_requests.requested_by_person_id%TYPE;
l_routing_group_id	ghr_pa_requests.routing_group_id%TYPE;
l_first_noa_code        ghr_pa_requests.first_noa_code%TYPE;
l_second_noa_code       ghr_pa_requests.second_noa_code%TYPE;
l_routing_group_name	ghr_routing_groups.name%TYPE;
l_description		ghr_routing_groups.description%TYPE;
l_to_organization_id    ghr_pa_requests.to_organization_id%TYPE;
l_to_organization_name  hr_organization_units.name%TYPE;
l_from_organization_name  hr_organization_units.name%TYPE;
l_noa_fam_desc          ghr_families.name%TYPE;
l_error_msg			varchar2(1200);
l_action_taken1		ghr_pa_routing_history.action_taken%TYPE;
l_creation_date		ghr_pa_routing_history.creation_date%TYPE;
l_date_notification_sent ghr_pa_routing_history.date_notification_sent%TYPE;
l_from_position_id      ghr_pa_requests.from_position_id%TYPE;
l_to_position_id        ghr_pa_requests.to_position_id%TYPE;
--
l_personnel_office_id   ghr_pa_requests.personnel_office_id%TYPE;
l_status                ghr_pa_requests.status%TYPE;
l_pos_ei_data           per_position_extra_info%rowtype;
--
cursor csr_par_details is
	SELECT noa_family_code, request_number,
		 employee_first_name, employee_last_name, employee_middle_names,
		 proposed_effective_date, effective_date, requested_by_person_id,
		 routing_group_id, to_organization_id, first_noa_desc, second_noa_desc,
             first_noa_code, second_noa_code, from_position_id, personnel_office_id,
             status, to_position_id
	FROM ghr_pa_requests
	WHERE pa_request_id = p_pa_request_id;
--
cursor csr_ghr_families is
	SELECT name
		FROM ghr_families
		WHERE noa_family_code = l_noa_family_code;
--
cursor csr_routing_groups is
		SELECT name, description
		FROM ghr_routing_groups
		WHERE routing_group_id = l_routing_group_id;
--
cursor csr_org_details is
		SELECT name
		FROM hr_organization_units
		WHERE organization_id = l_to_organization_id ;
--
cursor csr_get_routing_details is
            SELECT action_taken from  ghr_pa_routing_history
            where pa_request_id = p_pa_request_id
            order by  pa_routing_history_id desc;
--
cursor csr_get_initiated_date is
            SELECT date_notification_sent, creation_date FROM ghr_pa_routing_history
            WHERE pa_request_id = p_pa_request_id
            order by 1 asc;
--
cursor csr_from_org_details is
            SELECT hru.name
            FROM hr_organization_units hru,
                 hr_all_positions_f    hpf
            WHERE hpf.position_id = nvl(l_from_position_id,-9999)
            and   nvl(l_effective_date,sysdate)
            between hpf.effective_start_date
            and     hpf.effective_end_date
            and     hpf.organization_id = hru.organization_id;
--
--
begin
-- This function will set the Workflow notification message attributes at each hop
--
	-- Get Error message
	l_error_msg := wf_engine.GetItemAttrText
			    	(itemtype => 'GHR_SF52',
			       itemkey  => p_pa_request_id,
	     			 aname    => 'LINE_ERROR'
                        );
	-- Get from the PA request the NOA CODE
	  open csr_par_details;
	  fetch csr_par_details into  l_noa_family_code, l_request_number,
	    					l_employee_first_name,l_employee_last_name,
						l_employee_middle_names, l_proposed_effective_date, l_effective_date,
						l_requested_by_person_id,l_routing_group_id,
						l_to_organization_id, l_first_noa_desc, l_second_noa_desc,
                                    l_first_noa_code, l_second_noa_code, l_from_position_id,
                                   l_personnel_office_id, l_status, l_to_position_id;
	  if csr_par_details%notfound then
		null;
	      --  ?? Check with ****
		--		hr_utility.set_message(8301,'GHR_38211_NOA_FAMILY_NOTFOUND');
		--          hr_utility.raise_error;
	  end if;
        close csr_par_details;
        --
        -- Fetch POI from history
        if l_to_position_id Is Not Null then
                ghr_history_fetch.fetch_positionei
                     (  p_position_id      => l_to_position_id
                       ,p_date_effective   => nvl(l_effective_date,trunc(sysdate
))
                       ,p_information_type => 'GHR_US_POS_GRP1'
                       ,p_pos_ei_data      => l_pos_ei_data
                     );
                l_personnel_office_id  :=  l_pos_ei_data.poei_information3;
                l_pos_ei_data := null;
       elsif l_from_position_id Is Not Null then
                ghr_history_fetch.fetch_positionei
                     (  p_position_id      => l_to_position_id
                       ,p_date_effective   => nvl(l_effective_date,trunc(sysdate
))
                       ,p_information_type => 'GHR_US_POS_GRP1'
                       ,p_pos_ei_data      => l_pos_ei_data
                     );
               l_personnel_office_id  :=  l_pos_ei_data.poei_information3;
        end if;
        --
        --
	  open csr_ghr_families;
	  fetch csr_ghr_families into l_noa_fam_desc;
	  if csr_ghr_families%notfound then
		null;
	     	--  ?? Check with ****
		--		hr_utility.set_message(8301,'GHR_38211_NOA_FAMILY_NOTFOUND');
		--          hr_utility.raise_error;
	  end if;
        close csr_ghr_families;
	  if l_noa_fam_desc is Null then
		l_noa_fam_desc := l_noa_family_code;
	  end if;
        --
 	  if l_first_noa_desc Is Null then
          if l_noa_fam_desc is Null then
	      l_first_noa_desc := l_noa_family_code;
	    else
	      l_first_noa_desc := l_noa_fam_desc;
          end if;
	  end if;
      --
      --
	-- Get routing group name and description
	if l_routing_group_id Is Not Null then
		  open csr_routing_groups;
		  fetch csr_routing_groups into l_routing_group_name, l_description;
		  if csr_routing_groups%notfound then
			null;
	      	--  ?? Check with ****
			--		hr_utility.set_message(8301,'GHR_38211_NOA_FAMILY_NOTFOUND');
			--          hr_utility.raise_error;
		  end if;
      	  close csr_routing_groups;
	else
		l_routing_group_name := ' ';
	end if;
      --  Get Action taken
      open csr_get_routing_details;
      fetch csr_get_routing_details into l_action_taken1;
		  if csr_get_routing_details%notfound then
			null;
			--		hr_utility.set_message(8301,'GHR_38211_NOA_FAMILY_NOTFOUND');
			--          hr_utility.raise_error;
		  end if;
 	close csr_get_routing_details;
      --
      open  csr_get_initiated_date;
      fetch csr_get_initiated_date into l_date_notification_sent, l_creation_date;
      if csr_get_initiated_date%notfound then
		  null;
	   	  --		hr_utility.set_message(8301,'GHR_38211_NOA_FAMILY_NOTFOUND');
		  --          hr_utility.raise_error;
      end if;
      close csr_get_initiated_date;
--
	if l_request_number is Null then
		l_request_number := ' ';
	end if;
--
	if l_employee_last_name is Null then
		l_employee_last_name := ' ';
	end if;
--
	if l_employee_first_name is Null then
		l_employee_first_name := ' ';
	end if;
--
	if l_employee_middle_names is Null then
		l_employee_middle_names := ' ';
	end if;
      --
	if l_to_organization_id  is Null then
              -- Get FRom Org details if to Org ID is Null
		  l_to_organization_name  := ' ';
		  open csr_from_org_details;
		  fetch csr_from_org_details into l_from_organization_name;
		  if csr_from_org_details%notfound then
			null;
	      	--  ?? Check with ****
			--		hr_utility.set_message(8301,'GHR_38211_NOA_FAMILY_NOTFOUND');
			--          hr_utility.raise_error;
		  end if;
      	  close csr_from_org_details;
      else
		  open csr_org_details;
		  fetch csr_org_details into l_to_organization_name;
		  if csr_org_details%notfound then
			null;
	      	--  ?? Check with ****
			--		hr_utility.set_message(8301,'GHR_38211_NOA_FAMILY_NOTFOUND');
			--          hr_utility.raise_error;
		  end if;
      	  close csr_org_details;
      end if;
      --
	-- Subject line of message
	if l_error_msg is Not Null then
		l_subject :=  'Personnel Action : Error :' || l_first_noa_desc || ' : Req# ' || l_request_number;
	elsif l_action_taken1 in ('ENDED') then
		l_subject := 'Personnel Action : FYI: Ended : ' || l_first_noa_desc  || ' : Req# ' || l_request_number;
     	elsif l_action_taken1 in ('UPDATE_HR_COMPLETE') then
		l_subject := 'Personnel Action : Update HR Complete : ' || l_first_noa_desc || ' : Req# ' || l_request_number;
      else
		l_subject := 'Personnel Action : ' || l_first_noa_desc || ' : Req# ' || l_request_number;
	end if;
	p_subject := l_subject;
      --
      --
	-- First line of the message body
	if l_employee_last_name = ' ' and l_employee_first_name = ' ' and  l_personnel_office_id Is Null then
--		l_line1 := 'Name / POI                    : ' ;
null;
	elsif l_personnel_office_id Is Null then
		l_line1 := l_employee_last_name || ', ' || l_employee_first_name || ' ' ||
                      l_employee_middle_names;
      else
		l_line1 :=
                      l_employee_last_name || ', ' || l_employee_first_name || ' ' ||
                      l_employee_middle_names || ' / ' || l_personnel_office_id;
	end if;
	p_line1 := l_line1;
	-- Second line of message
            IF l_proposed_effective_date is null then
            l_line2   := fnd_date.date_to_displaydate(l_effective_date) || ' / ASAP';
            ELSE
            l_line2   := fnd_date.date_to_displaydate(l_effective_date) || ' / '|| fnd_date.date_to_displaydate(l_proposed_effective_date);
            END IF;
	p_line2 := l_line2;
	-- Third line of message
	l_line3  := l_status;
	p_line3 := l_line3;
	-- 4th line of message
	l_line4       := l_routing_group_name || ' - ' || l_description;
	p_line4 := l_line4;
	-- 5th line of message
      if l_date_notification_sent Is Null then
	 l_line5      := fnd_date.date_to_displaydate(sysdate) || ' / ' || fnd_date.date_to_displaydate(l_creation_date);
      else
	 l_line5      :=  fnd_date.date_to_displaydate(sysdate) || ' / ' || fnd_date.date_to_displaydate(l_date_notification_sent);
      end if;
      p_line5 := l_line5;
	-- 6th of message
      if l_to_organization_name Is Not Null then
	   l_line6    :=  l_to_organization_name;
      else
         l_line6      :=  l_from_organization_name;
      end if;
      p_line6 := l_line6;
	-- 7th line of message
	l_line7       :=   l_noa_fam_desc;
	p_line7 := l_line7;
	-- 8th line of message
	l_line8       :=  l_first_noa_code || ' - ' || l_first_noa_desc;
	p_line8 := l_line8;
	-- 9th line of message
      if l_second_noa_desc Is Not Null then
	 l_line9        :=  l_line9 || l_second_noa_code || ' - ' || l_second_noa_desc;
      end if;
       p_line9 := l_line9;
--
--
 Exception when others then
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
       p_subject := null;
       p_line1  := null;
       p_line2 := null;
       p_line3 := null;
       p_line4 := null;
       p_line5 := null;
       p_line6 := null;
       p_line7 := null;
       p_line8 := null;
       p_line9 := null;
       raise;

END SetDestinationDetails;
--
--
procedure CompleteBlockingOfPArequest ( p_pa_request_id in Number,
					          p_error_msg in varchar2 default null
						  ) is
begin
	-- Added for Future Action process
         if p_error_msg Is Null then
			wf_engine.SetItemAttrText(
						itemtype => 'GHR_SF52',
			     			itemkey  => p_pa_request_id,
			     			aname    => 'LINE_ERROR',
			     			avalue   => ''
					  );
         else
			wf_engine.SetItemAttrText(
						itemtype => 'GHR_SF52',
			     			itemkey  => p_pa_request_id,
			     			aname    => 'LINE_ERROR',
			     			avalue   => 'Update HR Error : '
                                            || substr(p_error_msg,1,1000)
					  );
         end if;
	wf_engine.CompleteActivity('GHR_SF52', p_pa_request_id, 'GH_NOTIFY_SF52','COMPLETE');
end;
--
--
--
--
procedure CompleteBlockingOfFutureAction ( p_pa_request_id in Number,
						       p_action_taken in varchar2,
						       p_error_msg in varchar2 default null
						     ) is
begin
       if p_error_msg Is Null then
			wf_engine.SetItemAttrText(
						itemtype => 'GHR_SF52',
			     			itemkey  => p_pa_request_id,
			     			aname    => 'LINE_ERROR',
			     			avalue   => ''
					  );
       else
			wf_engine.SetItemAttrText(
						itemtype => 'GHR_SF52',
			     			itemkey  => p_pa_request_id,
			     			aname    => 'LINE_ERROR',
			     			avalue   => 'Update HR Error : '
                                            || substr(p_error_msg,1,1000)
					  );
      end if;
      --
	if p_action_taken = 'UPDATE_HR_COMPLETE' then
		wf_engine.CompleteActivity('GHR_SF52', p_pa_request_id, 'BLOCK_FUTURE_ACTION','UPDATE_HR_COMPLETE');
	else
		wf_engine.CompleteActivity('GHR_SF52', p_pa_request_id, 'BLOCK_FUTURE_ACTION','CONTINUE');
	end if;
--
--
end CompleteBlockingOfFutureAction ;
--
--
function CheckItemAttribute
                (p_name in   wf_item_attribute_values.name%TYPE,
                 p_itemtype  in varchar2,
  		     p_itemkey  	in varchar2
                )    return boolean IS
--
 l_name  wf_item_attribute_values.name%TYPE;
--
 cursor csr_get_item_attr is
        select   name
        from     wf_item_attribute_values
        where    item_type = upper(p_itemtype)
        and      item_key  = nvl(p_itemkey,'-9999')
        and      name = nvl(p_name,'-9999');
begin
    open csr_get_item_attr;
    fetch csr_get_item_attr into l_name;
    if csr_get_item_attr%notfound then
       close csr_get_item_attr;
       return false;
    else
       close csr_get_item_attr;
       return true;
    end if;
end CheckItemAttribute;
--
PROCEDURE CheckIfPARWfEnd ( itemtype in varchar2,
				  itemkey  	 in varchar2,
				  actid	 in number,
				  funcmode	 in varchar2,
				  result	 in out nocopy varchar2) is
--
l_action_taken      ghr_pa_routing_history.action_taken%TYPE;
l_load_form				 varchar2(200);--Bug# 7312949
--
 cursor csr_parh is
        SELECT  action_taken
        FROM    ghr_pa_routing_history
        WHERE   pa_request_id = itemkey
        order by  pa_routing_history_id desc;
--

l_result varchar2(4000);
begin
l_result := result;
if funcmode = 'RUN' then
    open csr_parh;
	  fetch csr_parh into l_action_taken;
	  if csr_parh%notfound then
		hr_utility.set_message(8301,'GHR_38154_INVALID_PRIMARY_KEY');
		hr_utility.raise_error;
	  end if;
        close csr_parh;
        --
	  if l_action_taken in ('ENDED','UPDATE_HR_COMPLETE') then
                if ( CheckItemAttribute (  p_name => 'PA_REQUEST_RO',
                                p_itemtype => itemtype,
                                p_itemkey => itemkey ) ) then
   -- Bug # 8597583 modified parameters to pass with out double quotes

                    l_load_form := 'GHRWS52L:p_pa_request_id=' || Itemkey
                          || ' p_inbox_query_only=YES' || ' WORKFLOW_NAME=GHR_US_PA_REQUEST'
                          || ' p_wf_notification_id=&#NID';--Bug# 6923642
                    wf_engine.SetItemAttrText(  	itemtype => itemtype,
			     			itemkey  => itemkey,
			     			aname    => 'PA_REQUEST_RO',
			     			avalue   => l_load_form
                                     );
                 end if;
		     result  := 'COMPLETE:YES';
		     return;
        else
			result  := 'COMPLETE:NO';
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
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('GHR_SF52', 'ghr_wf_pkg.CheckIfPARWfEnd',itemtype, itemkey, to_char(actid), funcmode);
          --
          -- Reset IN OUT parameters and set OUT parameters
          --
          result := l_result;
    raise;
--
end CheckIfPARWfEnd ;
--
--
procedure VerifyIfNtfyUpdHRUsr(	itemtype	in varchar2,
					itemkey  	in varchar2,
					actid		in number,
					funcmode	in varchar2,
					result	in out nocopy varchar2	) is
--
l_text	varchar2(30);
--
--
--
l_result varchar2(4000);
begin
l_result := result;
--
   if funcmode = 'RUN' then
	   l_text	:=  wf_engine.GetItemAttrText(	itemtype => Itemtype,
								  	itemkey  => Itemkey,
								  	aname    => 'NTFY_UPD_HR_YES_NO');
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
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('WGI', 'ghr_wf_wgi_pkg.VerifyIfNtfyUpdHRUsr',itemtype, itemkey, to_char(actid), funcmode);
          --
          -- Reset IN OUT parameters and set OUT parameters
          --
          result := l_result;
    raise;
--
--
end VerifyIfNtfyUpdHRUsr;
--
--
procedure CheckIfNtfyUpdHRUsr(	itemtype	in varchar2,
					itemkey  	in varchar2,
					actid		in number,
					funcmode	in varchar2,
					result	in out nocopy varchar2	) is
--
l_text	varchar2(30);
--
--
--
l_result varchar2(4000);
begin
l_result := result;
--
   if funcmode = 'RUN' then
	   l_text	:=  wf_engine.GetItemAttrText(	itemtype => Itemtype,
								  	itemkey  => Itemkey,
								  	aname    => 'USE_UPD_HR_ONLY');
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
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('WGI', 'ghr_wf_wgi_pkg.CheckIfNtfyUpdHRUsr',itemtype, itemkey, to_char(actid), funcmode);
          --
          -- Reset IN OUT parameters and set OUT parameters
          --
          result := l_result;
    raise;
--
--
end CheckIfNtfyUpdHRUsr;
--
--
PROCEDURE EndSF52Process( itemtype	in varchar2,
				  itemkey  	in varchar2,
				  actid	in number,
				  funcmode	in varchar2,
				  result	in out nocopy varchar2) is
l_result varchar2(4000);
begin
l_result := result;
if funcmode = 'RUN' then
      result := 'COMPLETE:COMPLETED';
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
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('GHR_SF52', 'ghr_wf_pkg.EndSF52Process',itemtype, itemkey, to_char(actid), funcmode);
          --
          -- Reset IN OUT parameters and set OUT parameters
          --
          result := l_result;
    raise;
end EndSF52Process;
--
PROCEDURE norout( itemtype	in varchar2,
		       itemkey  in varchar2,
		       actid	in number,
		       funcmode	in varchar2,
		       result	in out nocopy varchar2) is
--
--
l_forward_to_name varchar2(30);
l_user_name varchar2(30);
l_prh_rec        ghr_pa_routing_history%rowtype := NULL;
l_routing_group_id ghr_routing_groups.routing_group_id%type;
l_effective_date   ghr_pa_requests.effective_date%type;
l_first_noa_id ghr_pa_requests.first_noa_id%type;
l_second_noa_id ghr_pa_requests.second_noa_id%type;
l_noa_family_code ghr_pa_requests.noa_family_code%type;
l_gbx_id          ghr_groupboxes.groupbox_id%type;
--
CURSOR chk_groupbox is
select name,groupbox_id,display_name from ghr_groupboxes
where routing_group_id = l_routing_group_id
and name =  l_forward_to_name;

CURSOR chk_groupbox_users is
select groupbox_user_id,groupbox_id,user_name,
INITIATOR_FLAG,
REQUESTER_FLAG,
AUTHORIZER_FLAG,
PERSONNELIST_FLAG,
APPROVER_FLAG,
REVIEWER_FLAG
 from ghr_groupbox_users
where groupbox_id = ( select groupbox_id from ghr_groupboxes
where routing_group_id = l_routing_group_id )
and user_name = l_forward_to_name;


CURSOR chk_pei_wf_grp(p_user_name in varchar2) IS

-- Routing Group details
  SELECT pei.pei_information3 routing_group_id
        ,pei.pei_information4 initiator_flag
        ,pei.pei_information5 requester_flag
        ,pei.pei_information6 authorizer_flag
        ,pei.pei_information7 personnelist_flag
        ,pei.pei_information8 approver_flag
        ,pei.pei_information9 reviewer_flag
        ,pei.person_id        person_id
  FROM   per_people_extra_info  pei
        ,fnd_user               use
  WHERE use.user_name = p_user_name
  AND   pei.person_id = use.employee_id
  AND   pei.information_type = 'GHR_US_PER_WF_ROUTING_GROUPS'
  AND   pei.pei_information3 = ( SELECT routing_group_id from
                               GHR_PA_REQUESTS
                               where pa_request_id = itemkey);
--
--
/* Cursor    c_user_emp_names(p_user_name in varchar2) is
    select  usr.employee_id,
            per.first_name,
            per.last_name,
            per.middle_names
    from    per_people_f per,
            fnd_user     usr
    where   upper(usr.user_name)  =  upper(p_user_name)
    and     per.person_id         =  usr.employee_id
    and     l_effective_date
    between effective_start_date
    and     effective_end_date; */
-- Bug 4863608 - Removing upper from the column name
 CURSOR    c_user_emp_names(p_user_name in varchar2) is
    SELECT  usr.employee_id,
            per.first_name,
            per.last_name,
            per.middle_names
    FROM    per_people_f per,
            fnd_user     usr
    WHERE   usr.user_name  =  upper(p_user_name)
    AND     per.person_id         =  usr.employee_id
    AND     l_effective_date
    BETWEEN effective_start_date
    AND     effective_end_date;

Cursor   C_routing_history_id is
    select   prh.pa_routing_history_id,
             prh.object_version_number
    from     ghr_pa_routing_history prh
    where    prh.pa_request_id = itemkey
    order by prh.pa_routing_history_id desc;

Cursor get_par
is
SELECT routing_group_id,nvl(effective_date,sysdate) effective_date,
first_noa_id,second_noa_id,noa_family_code
from ghr_pa_requests
where pa_request_id = itemkey;

l_valid_user varchar2(1) := 'N';
l_gbx_user_id ghr_groupbox_users.groupbox_user_id%type;
  l_initiator_flag               ghr_pa_routing_history.initiator_flag%TYPE := NULL;
  l_requester_flag               ghr_pa_routing_history.requester_flag%TYPE;
  l_reviewer_flag                ghr_pa_routing_history.reviewer_flag%TYPE;
  l_authorizer_flag              ghr_pa_routing_history.authorizer_flag%TYPE;
  l_approver_flag                ghr_pa_routing_history.approver_flag%TYPE;
  l_approved_flag                ghr_pa_routing_history.approved_flag%TYPE;
  l_personnelist_flag            ghr_pa_routing_history.personnelist_flag%TYPE;
  l_user_name_employee_id        per_people_f.person_id%TYPE;
  l_user_name_emp_first_name     per_people_f.first_name%TYPE;
  l_user_name_emp_last_name      per_people_f.last_name%TYPE;
  l_user_name_emp_middle_names   per_people_f.middle_names%TYPE;
  l_current_user_name            fnd_user.user_name%type;
  l_u_pa_routing_history_id     ghr_pa_routing_history.pa_routing_history_id%TYPE;
  l_u_prh_object_version_number ghr_pa_routing_history.object_version_number%TYPE;

l_result  varchar2(4000);
l_exp number;
BEGIN
l_exp := 0;
l_result := result;
--
--
IF itemtype = 'GHR_SF52' THEN
  IF (funcmode in ('FORWARD','TRANSFER')) then
    -- Get the current user name
    l_current_user_name := FND_GLOBAL.USER_NAME();
    -- Get the Forward To Information
    l_forward_to_name := WF_ENGINE.context_text;
    -- Validate the username
    -- a) Get the routing group id
    FOR rg_rec in get_par LOOP
      l_routing_group_id    := rg_rec.routing_group_id;
      l_effective_date      := rg_rec.effective_date;
      l_first_noa_id        := rg_rec.first_noa_id;
      l_second_noa_id       := rg_rec.second_noa_id;
      l_noa_family_code     := rg_rec.noa_family_code;
      exit;
    END LOOP;
    l_gbx_id := NULL;
    l_valid_user := NULL;
    -- b) Check against the list of groupboxes,users under the routing group
    FOR gb_rec IN chk_groupbox LOOP
      l_gbx_id     := gb_rec.groupbox_id;
      l_user_name  := NULL;
      l_valid_user := 'Y';
    END LOOP;
    IF l_gbx_id is NULL THEN
      FOR pei_rec IN chk_pei_wf_grp(l_forward_to_name) LOOP
        l_initiator_flag    := pei_rec.initiator_flag;
        l_requester_flag    := pei_rec.requester_flag;
        l_reviewer_flag     := pei_rec.reviewer_flag;
        l_authorizer_flag   := pei_rec.authorizer_flag;
        l_approver_flag     := pei_rec.approver_flag;
        l_personnelist_flag := pei_rec.personnelist_flag;
        l_user_name         := l_forward_to_name;
        l_valid_user        := 'Y';
      END LOOP;
    END IF;
    -- Create Routing History Information for the Reassignment
    IF l_valid_user = 'Y' THEN
      -- Update the current routing history record
      -- a) Get the current routing history details
      for cur_routing_history_id in C_routing_history_id loop
        l_u_pa_routing_history_id     :=  cur_routing_history_id.pa_routing_history_id;
        l_u_prh_object_version_number :=  cur_routing_history_id.object_version_number;
        exit;
      end loop;
      -- b) Get the current user details
      for user_emp_names in c_user_emp_names(l_current_user_name) loop
        l_user_name_employee_id      := user_emp_names.employee_id;
        l_user_name_emp_first_name   := user_emp_names.first_name;
        l_user_name_emp_last_name    := user_emp_names.last_name;
        l_user_name_emp_middle_names := user_emp_names.middle_names;
        exit;
      end loop;
      --  c) Get the current user privileges
      FOR pei_rec IN chk_pei_wf_grp(l_current_user_name) LOOP
        l_initiator_flag    := pei_rec.initiator_flag;
        l_requester_flag    := pei_rec.requester_flag;
        l_reviewer_flag     := pei_rec.reviewer_flag;
        l_authorizer_flag   := pei_rec.authorizer_flag;
        l_approver_flag     := pei_rec.approver_flag;
        l_personnelist_flag  := pei_rec.personnelist_flag;
      END LOOP;
      -- d) Call the row handler
      ghr_prh_upd.upd
      (
      p_pa_routing_history_id      => l_u_pa_routing_history_id,
      p_attachment_modified_flag   => 'N',
      p_initiator_flag             => nvl(l_initiator_flag,'N'),
      p_approver_flag              => nvl(l_approver_flag,'N'),
      p_reviewer_flag              => nvl(l_reviewer_flag,'N'),
      p_requester_flag             => nvl(l_requester_flag,'N'),
      p_authorizer_flag            => nvl(l_authorizer_flag,'N'),
      p_personnelist_flag          => nvl(l_personnelist_flag,'N'),
      p_approved_flag              => 'N',
      p_user_name                  => l_current_user_name,
      p_user_name_employee_id      => l_user_name_employee_id,
      p_user_name_emp_first_name   => l_user_name_emp_first_name,
      p_user_name_emp_last_name    => l_user_name_emp_last_name,
      p_user_name_emp_middle_names => l_user_name_emp_middle_names,
      p_action_taken             => 'REASSIGNED',
      p_noa_family_code            => l_noa_family_code,
      p_nature_of_action_id        => l_first_noa_id,
      p_second_nature_of_action_id => l_second_noa_id,
      p_object_version_number      => l_u_prh_object_version_number
      );

      -- Create new record
      -- a) Get the user details
      l_user_name_employee_id      := NULL;
      l_user_name_emp_first_name   := NULL;
      l_user_name_emp_last_name    := NULL;
      l_user_name_emp_middle_names := NULL;
      -- b) Call the row handler to create a new routing history record
      ghr_prh_ins.ins
      (
      p_pa_routing_history_id    => l_prh_rec.pa_routing_history_id,
      p_pa_request_id            => itemkey,
      p_attachment_modified_flag => nvl(l_prh_rec.attachment_modified_flag,'N') ,
      p_initiator_flag           => 'N',
      p_approver_flag            => 'N',
      p_reviewer_flag            => 'N',
      p_requester_flag           => 'N',
      p_authorizer_flag          => 'N',
      p_personnelist_flag        => 'N',
      p_approved_flag            => 'N',
      p_user_name                => l_user_name,
      p_user_name_employee_id    => l_user_name_employee_id,
      p_user_name_emp_first_name => l_user_name_emp_first_name,
      p_user_name_emp_last_name  => l_user_name_emp_last_name ,
      p_user_name_emp_middle_names=> l_user_name_emp_middle_names,
      p_groupbox_id             => l_gbx_id,
      p_routing_seq_number      => l_prh_rec.routing_seq_number,
      p_routing_list_id         => l_prh_rec.routing_list_id,
      p_notepad                 => l_prh_rec.notepad,
      p_nature_of_action_id     => l_first_noa_id,
      p_second_nature_of_action_id=> l_second_noa_id,
      p_noa_family_code           => l_noa_family_code,
      p_object_version_number     => l_prh_rec.object_version_number
      );
      result := 'COMPLETE:YES';
    ELSE
      l_exp := 1;
      app_exception.raise_exception;
    END IF;
  ELSE
    result := null;
  END IF;
ELSIF (itemtype = 'OF8') THEN
  IF funcmode in ('FORWARD','TRANSFER') THEN
    l_exp := 2;
    app_exception.raise_exception;
  END IF;
  result := null;
END IF;
return;
EXCEPTION WHEN OTHERS THEN
  --
  -- Reset IN OUT parameters and set OUT parameters
  --
  result := l_result;
  IF l_exp = 1 then
    result := wf_engine.eng_completed||':'||wf_engine.eng_null;
    fnd_message.set_name('GHR', 'GHR_38815_WF_INVALID_USER');
    app_exception.raise_exception;
  ELSIF l_exp = 2 then
    result := wf_engine.eng_completed||':'||wf_engine.eng_null;
    fnd_message.set_name('GHR', 'GHR_38674_NO_REASSIGN');
    app_exception.raise_exception;
  END IF;
END norout;
--
END ghr_wf_pkg;

/
