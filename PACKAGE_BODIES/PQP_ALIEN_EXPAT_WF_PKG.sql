--------------------------------------------------------
--  DDL for Package Body PQP_ALIEN_EXPAT_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_ALIEN_EXPAT_WF_PKG" AS
/* $Header: pqpalntf.pkb 115.6 2003/02/14 19:19:54 tmehra noship $ */
--
-- Procedure
--	StartAlienExpatWFProcess
--
-- Description
--	Start the Alien/ Expat workflow process for the given p_process_event_id
--
procedure StartAlienExpatWFProcess (
                                 p_process_event_id in number
                                ,p_tran_type        in varchar2
                                ,p_tran_date        in date
                                ,p_itemtype         in varchar2
                                ,p_alien_transaction_id in number
                                ,p_assignment_id    in number
                                ,p_process_name     in varchar2  ) IS
--
--
l_contact_source             varchar2(50);
l_assignment_id              per_all_assignments_f.assignment_id%type;
l_description                pay_process_events.description%type;
l_error_indicator            pqp_alien_transaction_data.error_indicator%type;
l_error_text                 pqp_alien_transaction_data.error_text%type;
l_person_id                  per_all_people_f.person_id%type;
l_next_contact_person_id     per_all_people_f.person_id%type;
l_contact_user_name          wf_users.name%type;
l_emp_username               wf_users.name%type;
l_emp_disp_name              wf_users.display_name%type;
l_emp_full_name              per_all_people_f.full_name%type;
l_item_key                   wf_items.item_key%type;
l_income_code                pqp_alien_transaction_data.income_code%type;
l_income_desc                hr_lookups.meaning%type;
--
--
--
cursor csr_getpayprcdet is
     SELECT assignment_id, description
     FROM  pay_process_events
     WHERE process_event_id = p_process_event_id;
--
cursor csr_getaliendet is
    SELECT ptd.error_indicator, ptd.error_text, ptd.income_code, hrl.meaning
    FROM   pqp_alien_transaction_data ptd, hr_lookups hrl
    WHERE  alien_transaction_id = p_alien_transaction_id
      AND  ptd.income_code      = hrl.lookup_code
      AND  hrl.lookup_type      = 'PQP_US_ALIEN_INCOME_BALANCE';
--
cursor csr_getperid is
     SELECT person_id
     FROM  per_all_assignments_f paf
     WHERE assignment_id = l_assignment_id
           and   trunc(p_tran_date) between
                    paf.effective_start_date and
                    paf.effective_end_date;
--
cursor csr_getperdet is
     SELECT full_name
     FROM  per_all_people_f pap
     WHERE person_id = l_person_id
           and   trunc(p_tran_date) between
                    pap.effective_start_date and
                    pap.effective_end_date;

-- Get HR/ Payroll Contact User Name
 cursor csr_payroll_contact is
        select  prl.prl_information1
        from    pay_payrolls_f prl
                ,per_assignments_f paf
        where   prl.payroll_id = paf.payroll_id
                and prl.prl_information_category = 'US'
                and paf.assignment_id = l_assignment_id
                and trunc(p_tran_date) between prl.effective_start_date
                       and  prl.effective_end_date;
-- Get HR/ Payroll contact from GRE
        cursor csr_gre_contact is
        select org.org_information1
        from   hr_organization_information org
        where  org.org_information_context = 'Contact Information'
          and  org.organization_id = (
               select hsc.segment1
               from   per_assignments_f paf
                     ,hr_soft_coding_keyflex hsc
               where  hsc.soft_coding_keyflex_id = paf.soft_coding_keyflex_id
                 and  paf.assignment_id = l_assignment_id
                 and  trunc(p_tran_date) between paf.effective_start_date and
                      paf.effective_end_date);
--
begin
      --
      --
      -- Get the next item key from the sequence
     select pqp_alntf_wf_item_key_s.nextval
     into   l_item_key
     from   sys.dual;

      --
        if p_tran_type = 'READ' then
  	        open csr_getpayprcdet;
              -- Get Assignment ID, Error Message

   	        fetch csr_getpayprcdet  into l_assignment_id, l_description;
	        if csr_getpayprcdet%notfound then
		      null;
   	            --  ?? Check with **** Error Message
		      --		hr_utility.set_message(XXX,'XXX');
		      --          hr_utility.raise_error;
	        end if;
              close csr_getpayprcdet;
        else
              l_assignment_id := p_assignment_id;
              open csr_getaliendet;
              -- Get Assignment ID, Error Message
   	        fetch csr_getaliendet  into
                      l_error_indicator, l_error_text, l_income_code, l_income_desc;
	        if csr_getaliendet%notfound then
		      null;
   	            --  ?? Check with **** Error Message
		      --		hr_utility.set_message(XXX,'XXX');
		      --          hr_utility.raise_error;
	        end if;
              close csr_getaliendet;
        end if;
        --
        -- Get Employee ID
	  open csr_getperid;
	  fetch csr_getperid  into l_person_id;
	  if csr_getperid%notfound then
		null;
	      --  ?? Check with **** Error Message
		--		hr_utility.set_message(XXX,'XXX');
		--          hr_utility.raise_error;
	  end if;
        close csr_getperid;
        --
        -- Get FND profile value
        l_contact_source := fnd_profile.value('HR_PAYROLL_CONTACT_SOURCE');
        -- expose the wf control variables to the custom package
        --
        if l_contact_source = 'CUSTOM' then
             -- call a custom notifier hook
                     l_next_contact_person_id :=
                       hr_approval_custom.Get_Next_Payroll_Notifier
                             (p_person_id => l_person_id);
        elsif l_contact_source = 'PAYROLL' then
            open csr_payroll_contact;
            fetch csr_payroll_contact into l_contact_user_name;
            close csr_payroll_contact;
        elsif l_contact_source = 'GRE' then
            open csr_gre_contact;
            fetch csr_gre_contact into l_contact_user_name;
            close csr_gre_contact;
--      else -- some other source we don't understand yet
--            result := 'ERROR:UNKNOWN_CONTACT_SOURCE';
        end if;

	-- Creates a new runtime process for the WF Item Type passed)
	--
	wf_engine.createProcess( ItemType => p_ItemType,
					 ItemKey  => l_item_key,
					 process  => p_process_name );
	--
	--
	wf_engine.SetItemAttrDate ( itemtype	=> p_itemtype,
			      		itemkey  => l_item_key,
  		 	      		aname 	=> 'ERR_DATE',
			      		avalue	=> p_tran_date );
      --
	wf_engine.SetItemAttrText   ( itemtype	=> p_itemtype,
			      		itemkey  => l_item_key,
  		 	      		aname 	=> 'TRAN_TYPE',
			      		avalue	=> p_tran_type );
      --
	wf_engine.SetItemAttrNumber ( itemtype	=> p_itemtype,
			      		itemkey  => l_item_key,
  		 	      		aname 	=> 'CURRENT_ASSIGNMENT_ID',
			      		avalue	=> l_assignment_id );
      --
      if p_tran_type = 'READ' then
        	wf_engine.SetItemAttrNumber   ( itemtype	=> p_itemtype,
	 		      	 	itemkey  	=> l_item_key,
  		 	      		aname 	=> 'PROCESS_EVENT_ID',
			      		avalue	=> p_process_event_id );
      	wf_engine.SetItemAttrText   ( itemtype	=> p_itemtype,
	 		      	 	itemkey => l_item_key,
  		 	      		aname 	=> 'ERR_MSG',
			      		avalue	=> l_description );
      else
            wf_engine.SetItemAttrText   ( itemtype=> p_itemtype,
	 		             	itemkey => l_item_key,
 		 	      		aname 	=> 'ERROR_INDICATOR',
			      		avalue	=> l_error_indicator );
            wf_engine.SetItemAttrText   ( itemtype=> p_itemtype,
	 		      		itemkey => l_item_key,
  		 	      		aname 	=> 'ERROR_TEXT',
			      		avalue	=> l_error_text );
            wf_engine.SetItemAttrNumber   ( itemtype	=> p_itemtype,
	 		      	 	itemkey  	=> l_item_key,
  		 	      		aname 	=> 'ALIEN_TRANSACTION_ID',
			      		avalue	=> p_alien_transaction_id );

            wf_engine.SetItemAttrText   ( itemtype=> p_itemtype,
	 		      		itemkey => l_item_key,
  		 	      		aname 	=> 'INCOME_CODE',
			      		avalue	=> l_income_code ||' ('||
                                                   l_income_desc||')' );
            --
            if l_error_indicator = 'WARNING : RETRO LOSS' then
                 wf_engine.SetItemAttrText(
                                        itemtype=> p_itemtype,
	 		      		itemkey => l_item_key,
  		 	      		aname 	=> 'IS_RETRO',
			      		avalue	=> 'Y' );
                 --
            elsif l_error_indicator = 'WARNING : CHANGED INCOME CODE' then
                 wf_engine.SetItemAttrText(
                                        itemtype=> p_itemtype,
	 		      		itemkey => l_item_key,
  		 	      		aname 	=> 'INCOME_CODE_CHANGED',
			      		avalue	=> 'Y' );

                 wf_engine.SetItemAttrText   ( itemtype=> p_itemtype,
	 		      		itemkey => l_item_key,
  		 	      		aname 	=> 'ERROR_TEXT',
			      		avalue	=> ' is the analyzed employment income code.'||
                                                    ' Please attach this earnings element for ');

            elsif l_error_indicator = 'WARNING : INVALID INCOME CODE' then
                 wf_engine.SetItemAttrText(
                                        itemtype=> p_itemtype,
	 		      		itemkey => l_item_key,
  		 	      		aname 	=> 'INCOME_CODE_CHANGED',
			      		avalue	=> 'Y' );

                 wf_engine.SetItemAttrText   ( itemtype=> p_itemtype,
	 		      		itemkey => l_item_key,
  		 	      		aname 	=> 'ERROR_TEXT',
			      		avalue	=> ' is no longer a valid employment income'||
                                                    ' code for ');
            end if;

      end if;

      --
      -- Get Employee details from the WF Dir Services
      if l_contact_source = 'CUSTOM' then
          wf_directory.GetUserName(   p_orig_system    => 'PER',
                                      p_orig_system_id => l_next_contact_person_id,
                                      p_name           => l_emp_username,
                                      p_display_name   => l_emp_disp_name );
          l_contact_user_name := l_emp_username;
      else
          wf_directory.GetUserName(   p_orig_system    => 'PER',
                                      p_orig_system_id => l_person_id,
                                      p_name           => l_emp_username,
                                      p_display_name   => l_emp_disp_name );
      end if;
      --
      --
      wf_engine.SetItemAttrNumber   ( itemtype	=> p_itemtype,
			      		itemkey  	=> l_item_key,
  		 	      		aname 	=> 'PERSON_ID',
			      		avalue	=> l_person_id );
      --

      -- If Emp Name is not in WF Dir services then get from PER_ALL_PEOPLE_F
      if l_emp_disp_name Is Null then
            open csr_getperdet;
            fetch csr_getperdet into l_emp_full_name;
            close csr_getperdet;
            l_emp_disp_name := l_emp_full_name;
      end if;
      --
      wf_engine.SetItemAttrText   (     itemtype	=> p_itemtype,
	  		      	          itemkey  	=> l_item_key,
  		 	      		    aname     	=> 'EMP_USERNAME',
			      		    avalue	      => l_emp_username );
      --
      wf_engine.SetItemAttrText   ( itemtype	=> p_itemtype,
			      		itemkey  	=> l_item_key,
  		 	      		aname 	=> 'PERSON_DISPLAY_NAME',
			      		avalue	=> l_emp_disp_name );

      --
      -- Set  HR/ Payroll Contact User Name for Notification
      --
      wf_engine.SetItemAttrText   ( itemtype	=> p_itemtype,
			      		itemkey  	=> l_item_key,
  		 	      		aname 	=> 'CONTACT_USERNAME',
			      		avalue	=> l_contact_user_name );
      --
	--
	wf_engine.StartProcess ( ItemType => p_itemtype,
					 ItemKey  => l_item_key );
	--
	--
end StartAlienExpatWFProcess;
--
--
PROCEDURE check_req_ntf        ( itemtype	in varchar2,
                 		   itemkey  in varchar2,
					   actid	in number,
					   funcmode	in varchar2,
					   result	in out nocopy varchar2) is
--
--
--
begin
--
--
	if funcmode = 'RUN' then
		if  Upper(wf_engine.GetItemAttrText
			    	(itemtype => itemtype,
			       itemkey  => itemkey  ,
	     			 aname    => 'REQ_NTF'
                        )) = 'Y' then
                result := 'COMPLETE:Y';
                return;
           else
                result := 'COMPLETE:N';
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
    wf_core.context('PQPALNTF', 'PQP_ALIEN_EXPAT_WF_PKG.check_req_ntf',itemtype, itemkey, to_char(actid), funcmode);
    raise;
  result := '';
  return;
--
--
end check_req_ntf;
--
--
PROCEDURE find_ntfr            ( itemtype	in varchar2,
					   itemkey  in varchar2,
					   actid	in number,
					   funcmode	in varchar2,
					   result	in out nocopy varchar2) is
--
--
--
begin
--
--
	if funcmode = 'RUN' then
		if wf_engine.GetItemAttrText
			    	(itemtype => itemtype,
			       itemkey  => itemkey  ,
	     			 aname    => 'CONTACT_USERNAME'
                        ) Is Null then
                 	wf_engine.SetItemAttrText   (
                                    itemtype	=> itemtype,
			      	 	itemkey  	=> itemkey,
  		 	      		aname 	=> 'CONTACT_USERNAME',
			      		avalue	=> 'SYSADMIN' );
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
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('PQPALNTF', 'PQP_ALIEN_EXPAT_WF_PKG.find_ntfr',itemtype, itemkey, to_char(actid), funcmode);
    raise;
  result := '';
  return;
--
--
end find_ntfr;
--
--
PROCEDURE check_tran_type       ( itemtype in varchar2,
					    itemkey   in varchar2,
					    actid	in number,
					    funcmode	in varchar2,
					    result	in out nocopy varchar2) is
--
--
--
begin
--
--
	if funcmode = 'RUN' then
		if wf_engine.GetItemAttrText
			    	(itemtype => itemtype,
			       itemkey  => itemkey  ,
	     			 aname    => 'TRAN_TYPE'
                        ) = 'READ' then
                --
                result := 'COMPLETE:READ';
                return;
           else
                result := 'COMPLETE:WRITE';
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
    wf_core.context('PQPALNTF', 'PQP_ALIEN_EXPAT_WF_PKG.check_tran_type',itemtype, itemkey, to_char(actid), funcmode);
    raise;
  result := '';
  return;
--
--
end check_tran_type;
--
 procedure reset_read_api_retry
                                ( itemtype in varchar2
                                 ,itemkey in varchar2
                                 ,actid in number
                                 ,funcmode in varchar2
  					   ,result	in out nocopy varchar2) is
--
--
--
begin
--
--
	if funcmode = 'RUN' then
                -- Call Reset Read API
                -- Get Process Event ID
                pqp_alien_expat_taxation_pkg.ResetForReadAPI
                         (p_process_event_id =>  wf_engine.GetItemAttrNumber
			    	                          (itemtype => itemtype,
                               		         itemkey  => itemkey  ,
	     			                           aname    => 'PROCESS_EVENT_ID'
                                                  )
                         );
                --
                result := 'COMPLETE:SUCCESS';
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
    wf_core.context('PQPALNTF', 'PQP_ALIEN_EXPAT_WF_PKG.reset_read_api_retry',itemtype, itemkey, to_char(actid), funcmode);
    raise;
  result := '';
  return;
--
--
end reset_read_api_retry;
--
 procedure abort_read_api_retry
                                ( itemtype in varchar2
                                 ,itemkey in varchar2
                                 ,actid in number
                                 ,funcmode in varchar2
  					   ,result	in out nocopy varchar2) is
--
--
--
begin
--
--
	if funcmode = 'RUN' then
                -- Call Abort Read API
                --
                pqp_alien_expat_taxation_pkg.AbortReadAPI
                         (p_process_event_id =>  wf_engine.GetItemAttrNumber
			    	                          (itemtype => itemtype,
                               		         itemkey  => itemkey  ,
	     			                           aname    => 'PROCESS_EVENT_ID'
                                                  )
                          );
                result := 'COMPLETE:';
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
    wf_core.context('PQPALNTF', 'PQP_ALIEN_EXPAT_WF_PKG.abort_read_api_retry',itemtype, itemkey, to_char(actid), funcmode);
    raise;
  result := '';
  return;
end abort_read_api_retry;
--
--
PROCEDURE check_if_retro_loss    ( itemtype	in varchar2,
					   itemkey  in varchar2,
					   actid	in number,
					   funcmode	in varchar2,
					   result	in out nocopy varchar2) is
--
--
--
begin
--
--
	if funcmode = 'RUN' then
		if  Upper(wf_engine.GetItemAttrText
			    	(itemtype => itemtype,
			       itemkey  => itemkey  ,
	     			 aname    => 'IS_RETRO'
                        )) = 'Y' then
                result := 'COMPLETE:Y';
                return;
           else
                result := 'COMPLETE:N';
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
    wf_core.context('PQPALNTF', 'PQP_ALIEN_EXPAT_WF_PKG.check_if_retro_loss',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;
  result := '';
  return;
--
--
end check_if_retro_loss;
--

PROCEDURE check_income_code_change( itemtype  in varchar2,
                                    itemkey   in varchar2,
                                    actid     in number,
                                    funcmode  in varchar2,
                                    result    in out nocopy varchar2) is
--
begin
--
   if funcmode = 'RUN' then
      if Upper(wf_engine.GetItemAttrText(
                         itemtype => itemtype,
                         itemkey  => itemkey  ,
                         aname    => 'INCOME_CODE_CHANGED')) = 'Y' then
         result := 'COMPLETE:Y';
         return;
      else
         result := 'COMPLETE:N';
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
      wf_core.context('PQPALNTF',
                      'PQP_ALIEN_EXPAT_WF_PKG.check_if_retro_loss',
                       itemtype,
                       itemkey,
                       to_char(actid),
                       funcmode);
      raise;
      result := '';
      return;
--
--
end check_income_code_change;
--

end PQP_ALIEN_EXPAT_WF_PKG;

/
