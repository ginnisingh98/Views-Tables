--------------------------------------------------------
--  DDL for Package Body HR_OFFER_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_OFFER_WF" as
/* $Header: hrofwrwf.pkb 115.3 2002/12/12 07:19:49 hjonnala ship $ */
--
  g_owa2        varchar2(2000);
  g_url         varchar2(2000);
-- ------------------------------------------------------------------------
-- |----------------------< Start_Hroffer_Process>-------------------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--    Initial the HR offer Workflow process
--
--
--
procedure Start_Hroffer_Process (p_hiring_mgr_id           in number
                                ,p_candidate_assignment_id in number
                                ,p_process                 in varchar2
                                ,p_read_parameters         in varchar2) is
--
l_ItemType	wf_items.item_type%TYPE	:= 'HR_OFFER';
l_ItemKey	wf_items.item_key%TYPE	:= p_candidate_assignment_id;
l_resubmit_offer_start_point wf_process_activities.instance_label%type;
--


--
begin
	--
        -- 04/14/97 Change Begins
        IF p_read_parameters = 'R' THEN
        --
           l_resubmit_offer_start_point
             := wf_engine.GetItemAttrText
                       (itemtype  => l_ItemType,
                        itemkey   => l_ItemKey,
                        aname     => 'HR_RESUBMIT_OFFER_SAVEPOINT');
        --
           wf_engine.HandleError(itemtype    => l_ItemType
                                ,itemkey     => l_ItemKey
                                ,activity    => l_resubmit_offer_start_point
                                ,command     => 'RETRY');

           goto process_end;

        ELSIF p_read_parameters = 'B' THEN
              g_bypass_next_apprvr := 'Y';
           ELSE
              g_bypass_next_apprvr := 'N';
        END IF;
        --
        -- 04/14/97 Change Ends
        --
	wf_engine.CreateProcess ( ItemType => l_ItemType,
				  ItemKey  => l_ItemKey,
				  process  => p_process );
	--
	wf_engine.SetItemAttrNumber ( 	itemtype	=> l_ItemType,
			      		itemkey  	=> l_ItemKey,
  		 	      		aname 		=> 'CANDIDATE_ASSIGNMENT_ID',
			      		avalue 		=> p_candidate_assignment_id );
	--
	wf_engine.SetItemAttrNumber ( 	itemtype	=> l_ItemType,
			      		itemkey  	=> l_ItemKey,
  		 	      		aname 		=> 'HIRING_MGR_ID',
			      		avalue 		=> p_hiring_mgr_id );
	--
	wf_engine.StartProcess ( ItemType => l_ItemType,
				 ItemKey  => l_ItemKey );
	--
        -- 04/14/97 Change begins
        <<process_end>>
        null;
        -- 04/14/97 Change ends

end Start_Hroffer_Process;
--
-- ------------------------------------------------------------------------
-- |------------------------< Initialize >---------------------------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--	Initialize Workflow Item Attributes
--
--
procedure Initialize( 	itemtype	in varchar2,
			itemkey  	in varchar2,
			actid		in number,
			funmode		in varchar2,
			result	 out nocopy varchar2	) is
--
l_hiring_mgr_id			per_people_f.person_id%type;
l_hiring_mgr_username		wf_users.name%type;
l_hiring_mgr_disp_name		wf_users.display_name%type;
l_candidate_assignment_id	per_assignments_f.assignment_id%type;
l_candidate_person_id		per_people_f.person_id%type;
l_candidate_disp_name		wf_users.display_name%type;
l_candidate_appl_number		per_people_f.applicant_number%type;
l_fwd_from_username 		wf_users.name%type;
l_fwd_from_disp_name		wf_users.display_name%type;
l_resubmit_offer_savepoint      wf_process_activities.instance_label%type;
--
--
begin
--
if ( funmode = 'RUN' ) then
        -- 03/07/97 We need to set the Bypass
        --          attribute for later on processing to bypass the next
        --          approver.
        --

        wf_engine.SetItemAttrText (itemtype     => itemtype,
                                    itemkey     => itemkey,
                                    aname       => 'BYPASS',
                                    avalue      => g_bypass_next_apprvr);
        -- 03/07/97 Change ends
	--
	-- Get hring manager details and store in item attrributes
	--
	l_hiring_mgr_id	:= wf_engine.GetItemAttrNumber
          (itemtype  	=> itemtype,
	   itemkey   	=> itemkey,
	   aname  		=> 'HIRING_MGR_ID' );
	--
        -- 03/07/97 Change ends

        -- 04/14/97 Change begins
        -- -----------------------------------------------------------
        -- Need to save the instance label name for this activity.
        -- The instance label name will be used for rollback all
        -- workflow processes which have been completed from this
        -- point when resubmit an offer.
        -- -----------------------------------------------------------
        l_resubmit_offer_savepoint :=
          hr_workflow_utility.get_activity_instance_label (p_actid   => actid);

	--
	wf_engine.SetItemAttrText (itemtype  => itemtype,
	      			   itemkey   => itemkey,
  	      			   aname     => 'HR_RESUBMIT_OFFER_SAVEPOINT',
				   avalue    => l_resubmit_offer_savepoint);
	--
        -- 04/14/97 Change ends
        --

	wf_directory.GetUserName(p_orig_system 	  => 'PER',
				 p_orig_system_id => l_hiring_mgr_id,
				 p_name		  => l_hiring_mgr_username,
				 p_display_name	  => l_hiring_mgr_disp_name );
	--
	wf_engine.SetItemAttrText (itemtype	=> itemtype,
	      			   itemkey  	=> itemkey,
  	      			   aname 	=> 'HIRING_MGR_USERNAME',
			       	   avalue	=> l_hiring_mgr_username );
	--
	wf_engine.SetItemAttrText (itemtype	=> itemtype,
	      			   itemkey  	=> itemkey,
  	      			   aname 	=> 'HIRING_MGR_DISP_NAME',
				   avalue	=> l_hiring_mgr_disp_name );
	--
	-- Set fwd to = hiring manager in case this is the only person in
        -- approval chain.
	--
	--
	wf_engine.SetItemAttrText (	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'FWD_TO_USERNAME',
					avalue		=> l_hiring_mgr_username );
	--
	wf_engine.SetItemAttrText (	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'FWD_TO_DISP_NAME',
					avalue		=> l_hiring_mgr_disp_name );
	--
	wf_engine.SetItemAttrNumber (	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'FWD_TO_ID',
					avalue		=>  l_hiring_mgr_id) ;
	--
	-- Set fwd from = hiring manager.  If this hiring manager has no
      -- supervisor, we won't ever call get_next_approver, so we have to
      -- set all the variables for 'fwd from'.
	--
	wf_engine.SetItemAttrNumber (	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'FWD_FROM_ID',
					avalue		=>  l_hiring_mgr_id) ;

	wf_directory.GetUserName(	p_orig_system 		=> 'PER',
					p_orig_system_id 	=> l_hiring_mgr_id,
					p_name			=> l_fwd_from_username,
					p_display_name		=> l_fwd_from_disp_name) ;
	--
	wf_engine.SetItemAttrText(  	itemtype => itemtype,
			     		itemkey  => itemkey,
			     		aname 	 => 'FWD_FROM_USERNAME',
			     		avalue 	 => l_fwd_from_username );
	--
	wf_engine.SetItemAttrText( 	itemtype => itemtype,
				     	itemkey  => itemkey,
				     	aname 	 => 'FWD_FROM_DISP_NAME',
			     		avalue 	 => l_fwd_from_disp_name );
	--
	-- Get candidate details and store in item attributess
	--
	l_candidate_assignment_id :=
         wf_engine.GetItemAttrNumber(itemtype  	=> itemtype,
	                             itemkey   	=> itemkey,
			    	     aname	=> 'CANDIDATE_ASSIGNMENT_ID' );
	--
	hr_offer_custom.get_candidate_details
          (p_candidate_assignment_id => l_candidate_assignment_id,
	   p_candidate_person_id     => l_candidate_person_id,
	   p_candidate_disp_name     => l_candidate_disp_name,
	   p_applicant_number	     => l_candidate_appl_number);
	--
	wf_engine.SetItemAttrNumber (	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname	=> 'CANDIDATE_PERSON_ID',
					avalue	=>  l_candidate_person_id);
	--

	wf_engine.SetItemAttrText (	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname	=> 'CANDIDATE_DISP_NAME',
					avalue	=> l_candidate_disp_name );
	--
	--
	wf_engine.SetItemAttrText (	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 	=> 'CANDIDATE_APPL_NUMBER',
					avalue	=> l_candidate_appl_number );
	--
elsif ( funmode = 'CANCEL' ) then
	--
	null;
	--
end if;
--
end initialize;
--
-- ------------------------------------------------------------------------
-- |------------------------< Get_next_approver >-------------------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--	Get a persons manager
--
--
procedure Get_Next_Approver ( 	itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funmode		in varchar2,
				result	 out nocopy varchar2	 ) is
--
l_hiring_mgr_id			per_people_f.person_id%type;
l_fwd_from_id			per_people_f.person_id%type;
l_fwd_from_username 		wf_users.name%type;
l_fwd_from_disp_name		wf_users.display_name%type;
l_fwd_to_id			per_people_f.person_id%type;
l_fwd_to_username		wf_users.name%type;
l_fwd_to_disp_name		wf_users.display_name%type;

--
begin
--
if ( funmode = 'RUN' ) then
	--
	l_fwd_from_id :=  wf_engine.GetItemAttrNumber
           (itemtype  	=> itemtype,
	    itemkey   	=> itemkey,
	    aname  		=> 'FWD_FROM_ID' );
	--
	-- if null this must be the first time in
	--
	if ( l_fwd_from_id is null ) then
		--
		l_fwd_from_id :=  wf_engine.GetItemAttrNumber
                  (itemtype  	=> itemtype,
		   itemkey   	=> itemkey,
		   aname  		=> 'HIRING_MGR_ID' );
		--
		wf_engine.SetItemAttrNumber(	itemtype => itemtype,
			     			itemkey  => itemkey,
			     			aname 	 => 'FWD_FROM_ID',
						avalue 	 => l_fwd_from_id );
		--
	end if;
	--
	-- Get the username and display name for forward from person and
        -- save to item attributes
	--
	wf_directory.GetUserName(p_orig_system 	  => 'PER',
				 p_orig_system_id => l_fwd_from_id,
				 p_name		  => l_fwd_from_username,
				 p_display_name   => l_fwd_from_disp_name) ;
	--
	wf_engine.SetItemAttrText(  	itemtype => itemtype,
			     		itemkey  => itemkey,
			     		aname 	 => 'FWD_FROM_USERNAME',
			     		avalue 	 => l_fwd_from_username );
	--
	wf_engine.SetItemAttrText( 	itemtype => itemtype,
				     	itemkey  => itemkey,
				     	aname 	 => 'FWD_FROM_DISP_NAME',
			     		avalue 	 => l_fwd_from_disp_name );
	--
	-- Get manager
	--
	l_fwd_to_id := hr_offer_custom.Get_Next_Approver
                         (p_person_id => l_fwd_from_id);
	--
	if ( l_fwd_to_id is null ) then
		--
		result := 'F';
		--
	else
		--
		wf_directory.GetUserName( 	p_orig_system 		=> 'PER',
						p_orig_system_id 	=> l_fwd_to_id,
						p_name			=> l_fwd_to_username,
						p_display_name		=> l_fwd_to_disp_name) ;
		--
		wf_engine.SetItemAttrNumber( 	itemtype 	=> itemtype,
				     		itemkey 	=> itemkey,
				     		aname 		=> 'FWD_TO_ID',
				     		avalue 		=> l_fwd_to_id );
		--
		wf_engine.SetItemAttrText(  	itemtype => itemtype,
				     		itemkey  => itemkey,
				     		aname 	 => 'FWD_TO_USERNAME',
				     		avalue 	 => l_fwd_to_username );


		Wf_engine.SetItemAttrText(  	itemtype => itemtype,
				     		itemkey  => itemkey,
				     		aname 	 => 'FWD_TO_DISP_NAME',
			     			avalue 	 => l_fwd_to_disp_name );
		--
		-- set forward from = to foward to
		--
		wf_engine.SetItemAttrNumber( 	itemtype 	=> itemtype,
				     		itemkey 	=> itemkey,
				     		aname 		=> 'FWD_FROM_ID',
				     		avalue 		=> l_fwd_to_id );
		--
		--
		result := 'T';
		--
	end if;
	--
elsif ( funmode = 'CANCEL' ) then
	--
	null;
	--
end if;
--
end Get_next_approver;
--
-- ------------------------------------------------------------------------
-- |----------------------< Check_Final_Approver >-------------------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--	Determine if this person is the final manager in the approval chain
--
--
procedure Check_Final_Approver( itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funmode		in varchar2,
				result	 out nocopy varchar2	 ) is
--
l_hiring_mgr_id		  per_people_f.person_id%type;
l_fwd_to_id	 	        per_people_f.person_id%type;
l_candidate_assignment_id per_assignments_f.assignment_id%type;
--
begin
--
if ( funmode = 'RUN' ) then
	--
	--
	l_hiring_mgr_id	:= wf_engine.GetItemAttrNumber
           (itemtype  	=> itemtype,
	    itemkey   	=> itemkey,
	    aname 	=> 'HIRING_MGR_ID' );
	--
	l_fwd_to_id := wf_engine.GetItemAttrNumber
           (itemtype  	=> itemtype,
	    itemkey   	=> itemkey,
	    aname	=> 'FWD_TO_ID' );
	--
	l_candidate_assignment_id := wf_engine.GetItemAttrNumber
           (itemtype  	=> itemtype,
	    itemkey   	=> itemkey,
	    aname  	=> 'CANDIDATE_ASSIGNMENT_ID' );
      --
      -- check final approver returns a 'Y', 'N' or 'E' for error
      --
      result :=  ( hr_offer_custom.Check_Final_approver
             (p_candidate_assignment_id => l_candidate_assignment_id,
	        p_fwd_to_mgr_id           => l_fwd_to_id,
              p_person_id               => l_hiring_mgr_id ) );
	--
elsif ( funmode = 'CANCEL' ) then
	--
	null;
	--
end if;
--
end Check_Final_Approver;
--
-- ------------------------------------------------------------------------
-- |----------------------< Set_Status_To_Offer >-------------------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--	Set the status of a candidates application to offer
--
--
procedure Set_Status_To_offer( 	itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funmode		in varchar2,
				result	 out nocopy varchar2	) is
--
l_candidate_assignment_id	per_assignments_f.assignment_id%type;
--
begin
--
if ( funmode = 'RUN' ) then
	--
	l_candidate_assignment_id := wf_engine.GetItemAttrNumber
          (itemtype  	=> itemtype,
	   itemkey   	=> itemkey,
	   aname  	=> 'CANDIDATE_ASSIGNMENT_ID' );
	--
	hr_offer_custom.set_status_to_offer
          (p_candidate_assignment_id => l_candidate_assignment_id);
	--
elsif ( funmode = 'CANCEL' ) then
	--
	null;
	--
end if;
--
end Set_Status_To_offer;
--
-- ------------------------------------------------------------------------
-- |----------------------< Set_Status_To_Sent >---------------------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--	Set the status of a candidates application to offer sent
--
--
procedure Set_Status_To_Sent( 	itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funmode		in varchar2,
				result	 out nocopy varchar2	) is
--
l_candidate_assignment_id	per_assignments_f.assignment_id%type;
--
begin
--
if ( funmode = 'RUN' ) then
	--
	l_candidate_assignment_id := wf_engine.GetItemAttrNumber
           (itemtype  	=> itemtype,
	    itemkey   	=> itemkey,
	    aname  	=> 'CANDIDATE_ASSIGNMENT_ID' );
	--
	hr_offer_custom.set_status_to_sent
          (p_candidate_assignment_id => l_candidate_assignment_id);
	--
elsif ( funmode = 'CANCEL' ) then
	--
	null;
	--
end if;
--
end Set_Status_To_Sent;
--
-- ------------------------------------------------------------------------
-- |----------------------< Reset_Approval_Chain >-------------------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--	Set the approval chain back to the hiring manager
--
--
procedure Reset_Approval_chain( itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funmode		in varchar2,
				result	 out nocopy varchar2	) is
--
l_hiring_mgr_id		per_people_f.person_id%type;
l_fwd_from_id	per_people_f.person_id%type;
--
begin
--
if ( funmode = 'RUN' ) then
	--
	l_hiring_mgr_id	:= wf_engine.GetItemAttrNumber
          (itemtype  	=> itemtype,
	   itemkey   	=> itemkey,
	   aname  		=> 'HIRING_MGR_ID' );
	--
	wf_engine.SetItemAttrNumber(itemtype 	=> itemtype,
			     	    itemkey 	=> itemkey,
			     	    aname 		=> 'FWD_FROM_ID',
			     	    avalue 		=> l_hiring_mgr_id );
	--
elsif ( funmode = 'CANCEL' ) then
	--
	null;
	--
end if;
--
end Reset_Approval_chain;
--
-- ------------------------------------------------------------------------
-- |----------------------< Get_summary_URL >------------------------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--	This function will return the URL for the approval managers to
--    navigate to a display-only version of the offer information.
--   	The highlights form is one of the 'tab' forms whose
--    setup procedure is in hr_offer_resume_web.setup.
--
--
procedure Get_Summary_URL( 	itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funmode		in varchar2,
				result	 out nocopy varchar2	) is
--
l_candidate_assignment_id 	per_assignments_f.assignment_id%type;
l_candidate_person_id		per_people_f.person_id%type;
begin
--
if ( funmode = 'RUN' ) then
	--
	l_candidate_assignment_id := wf_engine.GetItemAttrNumber
          (itemtype  	=> itemtype,
	   itemkey   	=> itemkey,
	   aname  	=> 'CANDIDATE_ASSIGNMENT_ID' );
	--
	l_candidate_person_id	:= wf_engine.GetItemAttrNumber
          (itemtype  	=> itemtype,
	   itemkey   	=> itemkey,
	   aname  	=> 'CANDIDATE_PERSON_ID' );
	--
        g_owa2 := null;     -- 10/29/97 Changed
        --
	g_owa2 := hr_offer_custom.get_url_string;
        --
        -- 10/29/97 Change Begins
        IF g_owa2 is null THEN
           null;
        ELSE
           IF substr(g_owa2, length(g_owa2),1) = '/' THEN
              -- the user has entered a trailing slash, we don't need to append
              -- one.
              null;
           ELSE
              g_owa2 := g_owa2 || '/';
           END IF;
        END IF;
        --
	g_url := g_owa2||'hr_offer_resume_web.setup?'||
                 hr_util_web.prepare_parameter
                   (p_name   => 'p_effective_date'
                   ,p_value  => hr_date.date_to_canonical(sysdate)
                   ,p_prefix => false)||
                 hr_util_web.prepare_parameter
                   (p_name   => 'p_applicant_person_id'
                   ,p_value  => l_candidate_person_id)||
                 hr_util_web.prepare_parameter
                   (p_name   => 'p_assignment_id'
                   ,p_value  => l_candidate_assignment_id)||
                 hr_util_web.prepare_parameter
                   (p_name   => 'p_tab'
                   ,p_value  => 2);
        --
        -- 10/29/97 Change Ends
	wf_engine.SetItemAttrText( 	itemtype 	=> itemtype,
			     		itemkey     	=> itemkey,
			     		aname 		=> 'SUMMARY_URL',
			     		avalue 		=> g_url );
	--
elsif ( funmode = 'CANCEL' ) then
	--
	null;
	--
end if;
--
end  Get_Summary_URL;
--
-- ------------------------------------------------------------------------
-- |------------------------< Get_Offer_URL >------------------------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--	This function will return the URL for the hiring manager to navigate to
--   	the offer page.
--
--
procedure Get_Offer_URL( 	itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funmode		in varchar2,
				result	 out nocopy varchar2	) is
--
l_candidate_assignment_id 	per_assignments_f.assignment_id%type;
l_candidate_person_id		per_people_f.person_id%type;
l_host				      varchar2(200);
--
--
begin
--
if ( funmode = 'RUN' ) then
	--
	l_candidate_assignment_id := wf_engine.GetItemAttrNumber
          (itemtype  	=> itemtype,
	   itemkey   	=> itemkey,
	   aname  	=> 'CANDIDATE_ASSIGNMENT_ID' );
	--
	l_candidate_person_id	:= wf_engine.GetItemAttrNumber
          (itemtype  	=> itemtype,
	   itemkey   	=> itemkey,
	   aname  	=> 'CANDIDATE_PERSON_ID' );
	--
        g_owa2 := null;          -- 10/29/97 Changed
        --
     	g_owa2 := hr_offer_custom.get_url_string;
        --
        -- 10/29/97 Change Begins
        IF g_owa2 is null THEN
           null;
        ELSE
           IF substr(g_owa2, length(g_owa2),1) = '/' THEN
              -- the user has entered a trailing slash, we don't need to append
              -- one.
              null;
           ELSE
              g_owa2 := g_owa2 || '/';
           END IF;
        END IF;
        -- 10/29/97 Change Ends
        --
        g_url := g_owa2||'hr_offer_form_web.setup?'||
                 hr_util_web.prepare_parameter
                   (p_name   => 'p_effective_date'
                   ,p_value  => hr_date.date_to_chardate(SYSDATE)
                   ,p_prefix => false)||
                 hr_util_web.prepare_parameter
                   (p_name   => 'p_applicant_person_id'
                   ,p_value  => l_candidate_person_id)||
                 hr_util_web.prepare_parameter
                   (p_name   => 'p_assignment_id'
                   ,p_value  => l_candidate_assignment_id);
	--
	wf_engine.SetItemAttrText( 	itemtype 	=> itemtype,
			     		itemkey 	=> itemkey,
			     		aname 		=> 'OFFER_URL',
			     		avalue 		=> g_url );
	--
elsif ( funmode = 'CANCEL' ) then
	--
	null;
	--
end if;
--
end  Get_Offer_URL;
--
-- ------------------------------------------------------------------------
-- |------------------------< Get_Letter_URL >-----------------------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--	This function will return the URL for the hiring manager to navigate to
--   	the offer page.  The letter form is one of the 'tab' forms whose setup
--    procedure is in hr_offer_resume_web.setup.
--
--
procedure Get_Letter_URL( 	itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funmode		in varchar2,
				result	 out nocopy varchar2	) is
--
l_candidate_assignment_id 	per_assignments_f.assignment_id%type;
l_candidate_person_id		per_people_f.person_id%type;
--
--
begin
--
if ( funmode = 'RUN' ) then
	--
	l_candidate_assignment_id := wf_engine.GetItemAttrNumber
           (itemtype  	=> itemtype,
	    itemkey   	=> itemkey,
	    aname  	=> 'CANDIDATE_ASSIGNMENT_ID' );
	--
	l_candidate_person_id	:= wf_engine.GetItemAttrNumber
          (itemtype  	=> itemtype,
	   itemkey   	=> itemkey,
	   aname  	=> 'CANDIDATE_PERSON_ID' );
	--
        g_owa2 := null;
        --
   	g_owa2 := hr_offer_custom.get_url_string;
        --
        -- 10/29/97 Change Begins
        IF g_owa2 is null THEN
           null;
        ELSE
           IF substr(g_owa2, length(g_owa2),1) = '/' THEN
              -- the user has entered a trailing slash, we don't need to append
              -- one.
              null;
           ELSE
              g_owa2 := g_owa2 || '/';
           END IF;
        END IF;

	g_url := g_owa2||'hr_offer_resume_web.setup?'||
                 hr_util_web.prepare_parameter
                   (p_name   => 'p_effective_date'
                   ,p_value  => hr_date.date_to_canonical(sysdate)
                   ,p_prefix => false)||
                 hr_util_web.prepare_parameter
                  (p_name   => 'p_applicant_person_id'
                  ,p_value  => l_candidate_person_id)||
                 hr_util_web.prepare_parameter
                   (p_name   => 'p_assignment_id'
                   ,p_value  => l_candidate_assignment_id)||
                 hr_util_web.prepare_parameter
                   (p_name   => 'p_tab'
                   ,p_value  => 3);
	--
        -- 10/29/97 Change Ends
        --
	wf_engine.SetItemAttrText( 	itemtype 	=> itemtype,
			     		itemkey 	=> itemkey,
			     		aname 		=> 'LETTER_URL',
			     		avalue 		=> g_url );
	--
elsif ( funmode = 'CANCEL' ) then
	--
	null;
	--
end if;
--
end  Get_Letter_URL;
--
-- ------------------------------------------------------------------------
-- |------------------------< Get_HR_Routing_Details >---------------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--	This function sets the valuse of 3 HR roles.  These roles can be used
--	as performers of notification activities.
--
procedure Get_HR_Routing_Details( 	itemtype	in varchar2,
					itemkey  	in varchar2,
					actid		in number,
					funmode		in varchar2,
					result	 out nocopy varchar2	) is

l_hiring_mgr_id  		per_people_f.person_id%type;
l_hr_routing_id 		per_people_f.person_id%type;
l_hr_routing_username		wf_users.name%type;
l_hr_routing_disp_name	wf_users.display_name%type;
--
begin
--
if ( funmode = 'RUN' ) then
	--
	l_hiring_mgr_id	:= wf_engine.GetItemAttrNumber
          (itemtype  	=> itemtype,
	   itemkey   	=> itemkey,
	   aname  		=> 'HIRING_MGR_ID' );
        --
        -- set the routing id 1
        --
	l_hr_routing_id := hr_offer_custom.get_hr_routing1
                             (p_person_id => l_hiring_mgr_id );
	--
	wf_directory.GetUserName(	p_orig_system  	 => 'PER',
					p_orig_system_id => l_hr_routing_id,
					p_name		 => l_hr_routing_username,
					p_display_name	 => l_hr_routing_disp_name );
	--
	wf_engine.SetItemAttrNumber (	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'HR_ROUTING_ID1',
					avalue		=> l_hr_routing_id ) ;


	wf_engine.SetItemAttrText (	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'HR_ROUTING_USERNAME1',
					avalue		=> l_hr_routing_username );
	--
	wf_engine.SetItemAttrText (	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'HR_ROUTING_DISP_NAME1',
					avalue		=> l_hr_routing_disp_name );
        --
        -- set the routing id 2
        --
        l_hr_routing_id := hr_offer_custom.get_hr_routing2
                             (p_person_id => l_hiring_mgr_id );


	wf_directory.GetUserName(	p_orig_system  	 => 'PER',
					p_orig_system_id => l_hr_routing_id,
					p_name		 => l_hr_routing_username,
					p_display_name	 => l_hr_routing_disp_name );
	--
	wf_engine.SetItemAttrNumber (	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'HR_ROUTING_ID2',
					avalue		=> l_hr_routing_id ) ;

	wf_engine.SetItemAttrText (	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'HR_ROUTING_USERNAME2',
					avalue		=> l_hr_routing_username );
	--
	wf_engine.SetItemAttrText (	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'HR_ROUTING_DISP_NAME2',
					avalue		=> l_hr_routing_disp_name );

        --
        -- set the routing id 3
        --
        l_hr_routing_id := hr_offer_custom.get_hr_routing3
                             (p_person_id => l_hiring_mgr_id );

	wf_directory.GetUserName(	p_orig_system  	 => 'PER',
					p_orig_system_id => l_hr_routing_id,
					p_name		 => l_hr_routing_username,
					p_display_name	 => l_hr_routing_disp_name );
	--
	wf_engine.SetItemAttrNumber (	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'HR_ROUTING_ID3',
					avalue		=> l_hr_routing_id ) ;


	wf_engine.SetItemAttrText (	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'HR_ROUTING_USERNAME3',
					avalue		=> l_hr_routing_username );
	--
	wf_engine.SetItemAttrText (	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'HR_ROUTING_DISP_NAME3',
					avalue		=> l_hr_routing_disp_name );
	--
elsif ( funmode = 'CANCEL' ) then
	--
	null;
	--
end if;
--
end Get_HR_Routing_Details;
--
--
-- ------------------------------------------------------------------------
-- |------------------------< copy_approval_comment >---------------------|
-- ------------------------------------------------------------------------
procedure copy_approval_comment( 	itemtype	in varchar2,
					itemkey  	in varchar2,
					actid		in number,
					funmode		in varchar2,
					result	 out nocopy varchar2	) is
begin
--
if ( funmode = 'RUN' ) then
	--
	wf_engine.SetItemAttrText (	itemtype	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 		=> 'APPROVAL_COMMENT_COPY',
					avalue		=> wf_engine.GetItemAttrText(	itemtype  	=> itemtype,
			    								itemkey   	=> itemkey,
			    								aname  		=> 'APPROVAL_COMMENT')
				   );
	--
elsif ( funmode = 'CANCEL' ) then
	--
	null;
	--
end if;
--
end copy_approval_comment;
--
--
-- ------------------------------------------------------------------------
-- |------------------------< Get_HR_Candidate_Details >---------------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--      This function sets the values of the some of candidate offer's terms
--      and condidtions.
--
procedure Get_HR_Candidate_Details(     itemtype        in varchar2,
                                        itemkey         in varchar2,
                                        actid           in number,
                                        funmode         in varchar2,
                                        result          out nocopy varchar2    ) is
-- Salary amount
CURSOR csr_salary_amount
         (p_assignment_id in per_assignments_f.assignment_id%TYPE) is
       select answer_value
       from   per_assign_proposal_answers
       where  assignment_id = p_assignment_id
       and    proposal_question_name = 'ANNUAL_SALARY';

-- Position title
CURSOR csr_position_title
         (p_assignment_id in per_assignments_f.assignment_id%TYPE) is
       select answer_value
       from   per_assign_proposal_answers
       where  assignment_id = p_assignment_id
       and    proposal_question_name = 'POSITION_TITLE';

-- Cost center/ Organization
CURSOR csr_organization
         (p_assignment_id in per_assignments_f.assignment_id%TYPE) is
       select hou.name
       from   per_assignments_x pax,
              hr_all_organization_units hou     -- 09/26/97 Changed
       where  pax.assignment_id = p_assignment_id
       and    pax.organization_id = hou.organization_id;

-- Sign-on bonus amount
CURSOR csr_sign_on_bonus_amount
         (p_assignment_id in per_assignments_f.assignment_id%TYPE) is
       select answer_value
       from   per_assign_proposal_answers
       where  assignment_id = p_assignment_id
       and    proposal_question_name = 'SIGN_ON_BONUS_AMOUNT';

-- Relocation maximum amount reimbursed
CURSOR csr_relocation_amount
         (p_assignment_id in per_assignments_f.assignment_id%TYPE) is
       select answer_value
       from   per_assign_proposal_answers
       where  assignment_id = p_assignment_id
       and    proposal_question_name = 'RELOCATION_MAXIMUM_AMOUNT_REIMBURSED';

-- Stock option shares
CURSOR csr_stock_option_shares
         (p_assignment_id in per_assignments_f.assignment_id%TYPE) is
       select answer_value
       from   per_assign_proposal_answers
       where  assignment_id = p_assignment_id
       and    proposal_question_name = 'STOCK_OPTION_SHARES';

position_title       per_assign_proposal_answers.answer_value%TYPE;
salary_amount        per_assign_proposal_answers.answer_value%TYPE;
relocation_amount    per_assign_proposal_answers.answer_value%TYPE;
sign_on_bonus_amount per_assign_proposal_answers.answer_value%TYPE;
stock_option_shares  per_assign_proposal_answers.answer_value%TYPE;
p_assignment_id      per_assignments_f.assignment_id%TYPE := to_number(itemkey);
organization         hr_organization_units.name%TYPE;

-- 05/08/97 Change Begins
--
l_candidate_person_id           per_people_f.person_id%type;
l_candidate_disp_name           wf_users.display_name%type;
l_candidate_appl_number         per_people_f.applicant_number%type;
--
-- 05/08/97 Change Ends
--
begin
   OPEN csr_position_title(p_assignment_id);
   FETCH csr_position_title into position_title;
   CLOSE csr_position_title;

   OPEN csr_organization(p_assignment_id);
   FETCH csr_organization into organization;
   CLOSE csr_organization;


   OPEN csr_salary_amount(p_assignment_id);
   FETCH csr_salary_amount into salary_amount;
   CLOSE csr_salary_amount;

   OPEN csr_sign_on_bonus_amount(p_assignment_id);
   FETCH csr_sign_on_bonus_amount into sign_on_bonus_amount;
   CLOSE csr_sign_on_bonus_amount;

   OPEN csr_relocation_amount(p_assignment_id);
   FETCH csr_relocation_amount into
         relocation_amount;
   CLOSE csr_relocation_amount;

   OPEN csr_stock_option_shares(p_assignment_id);
   FETCH csr_stock_option_shares into stock_option_shares;
   CLOSE csr_stock_option_shares;


--
if ( funmode = 'RUN' ) then
        --
        --
        wf_engine.SetItemAttrText (     itemtype        => itemtype,
                                        itemkey         => itemkey,
                                        aname           => 'SALARY_AMOUNT',
                                        avalue          => salary_amount ) ;

        wf_engine.SetItemAttrText (     itemtype        => itemtype,
                                        itemkey         => itemkey,
                                        aname           => 'POSITION_TITLE',
                                        avalue          => position_title);

        --
        wf_engine.SetItemAttrText (     itemtype        => itemtype,
                                        itemkey         => itemkey,
                                        aname           => 'ORGANIZATION',
                                        avalue          => organization);

        wf_engine.SetItemAttrText (     itemtype        => itemtype,
                                        itemkey         => itemkey,
                                        aname           => 'BONUS_AMOUNT',
                                        avalue          => sign_on_bonus_amount)
;
        --
        wf_engine.SetItemAttrText (     itemtype        => itemtype,
                                        itemkey         => itemkey,
                                        aname           => 'STOCK_OPTION',
                                        avalue          => stock_option_shares);

        --
        wf_engine.SetItemAttrText (     itemtype        => itemtype,
                                        itemkey         => itemkey,
                                        aname           => 'RELOCATION',
                                        avalue          => relocation_amount);

        --
        -- 05/08/97 Change Begins
        hr_offer_custom.get_candidate_details
          (p_candidate_assignment_id => p_assignment_id,
           p_candidate_person_id     => l_candidate_person_id,
           p_candidate_disp_name     => l_candidate_disp_name,
           p_applicant_number        => l_candidate_appl_number);
        --
        --
        wf_engine.SetItemAttrText (     itemtype        => itemtype,
                                        itemkey         => itemkey,
                                        aname           => 'CANDIDATE_DISP_NAME'
,
                                        avalue          => l_candidate_disp_name
 );
        --
        -- 05/08/97 Change Ends
        --
elsif ( funmode = 'CANCEL' ) then
        --
        null;
        --
end if;
--
exception
     when others then
       null;

end Get_HR_Candidate_Details;

--

-- ------------------------------------------------------------------------
-- ------------------------------------------------------------------------
-- |------------------------< check_if_bypass >---------------------|
-- ------------------------------------------------------------------------
        procedure check_if_bypass      (itemtype        in varchar2,
                                        itemkey         in varchar2,
                                        actid           in number,
                                        funmode         in varchar2,
                                        result          out nocopy varchar2    ) is
bypass varchar2(10);

begin
--
if ( funmode = 'RUN' ) then
        --
        result := wf_engine.GetItemAttrText (   itemtype        => itemtype,
                                                itemkey         => itemkey,
                                                aname           => 'BYPASS');
        --
elsif ( funmode = 'CANCEL' ) then
        --
        null;
        --
end if;
--
end check_if_bypass;

--
--
-- ------------------------------------------------------------------------
-- |----------------------< Set_Bypass_To_No >---------------------------|
-- ------------------------------------------------------------------------
        procedure Set_Bypass_To_No ( itemtype in varchar2,
                                     itemkey  in varchar2,
                                     actid    in number,
                                     funmode  in varchar2,
                                     result   out nocopy varchar2    ) is
begin
--
if ( funmode = 'RUN' ) then
        --
        wf_engine.SetItemAttrText ( itemtype        => itemtype,
                                    itemkey         => itemkey,
                                    aname           => 'BYPASS',
                                    avalue          => 'N');
        --
        wf_engine.SetItemAttrText ( itemtype        => itemtype,
                                    itemkey         => itemkey,
                                    aname           => 'APPROVAL_COMMENT_COPY',
                                    avalue          => '');
        --
elsif ( funmode = 'CANCEL' ) then
        --
        null;
        --
end if;
--
end Set_Bypass_To_No;
--
--
end  hr_offer_wf;

/
