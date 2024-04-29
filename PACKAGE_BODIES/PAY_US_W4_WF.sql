--------------------------------------------------------
--  DDL for Package Body PAY_US_W4_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_W4_WF" 
/* $Header: pyusw4wf.pkb 120.3.12010000.1 2008/07/27 23:59:55 appldev ship $ *
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 2000 Oracle Corporation.                        *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation,         *
   *  500 Oracle Parkway, Redwood City, CA, 94065.                  *
   *                                                                *
   ******************************************************************

    Name        : pay_us_w4_wf

    Description : Contains workflow code the W4 Notifications Workflow

    Uses        :

    Change List
    -----------
    Date        Name    Vers   Description
    ----        ----    ----   -----------
    28-SEP-2000 dscully  115.0  Created.
    14-MAY-2001 meshah   115.1  Changed init_tax_notifications procedure
                                cursor c_transaction,c_state_list,
                                check_final_notifier procedure
                                cursor c_payroll_contact,c_gre_contact
                                procedure get_next_notifier
                                cursor c_payroll_contact and c_gre_contact
                                to work with new SS.
    27-AUG-2001 meshah   115.2  Copy of pyustxwf.pkb
    28-AUG-2001 meshah   115.3  Now we are conditionally displaying
                                the message in workflow. Added a call
                                to PAY_W4_WF_STATE_MSG.
    18-OCT-2001 meshah   115.4  setting CURRENT_ASSIGNMENT_ID in
                                init_tax_notifications.
                                Also changed the checking for assignment_id
                                from > to =.
    23-JUL-2002 meshah   115.3  changed the cursor c_gre_contact to avoid
                                getting a invalid number error.
                                bug# 2477654.
    26-JUL-2002 meshah   115.4  included a check for pta.transaction_parent_id
                                is null in cursor c_gre_contact. This will
                                get us only one row.
    08-SEP-2003 irgonzal 115.5  Bug fix 3132854. Modified c_gre_contact
                                cursor: removed reference to 'apps' schema.
    24-Nov-2003 meshah   115.6  changed the cursor c_state_list and added a
                                new cursor c_state_exempt_list. We will
                                append only those states that are affected
                                by the W4 change. Bug 3151569
    13-Jan-2004 rsethupa 115.7  Bug fix 3362223.
                                11.5.10 Performance changes
    26-SEP-2005 jgoswami 115.8  Bug 4599982    modified call from
                                hr_util_web.rtn_msg_txt to
                                hr_util_misc_web.return_msg_text for R12 changes
    11-aug-2006 jgoswami 115.9  Bug 5198005 - Suppress W4 Notifications for the
                                W4 forms that are exempt or at a level above 10
                                allowances as IRS does not require Employer to
                                Send it. Based on the value of the DFF the
                                Notification will be sent or suppressed. Default
                                the Notification will be Suppressed.
                                Similarly Information message on Review page is
                                also suppressed.
    21-aug-2006 vaprakas 115.10 Included the item attribute text with
				aname=PERFORMER.

  *******************************************************************/
  AS

  /******************************************************************
  ** private package global declarations
  ******************************************************************/
  gv_package               VARCHAR2(50) := 'pay_us_w4_wf';


  PROCEDURE set_custom_wf_globals(p_itemtype in varchar2
  				 ,p_itemkey  in varchar2)
 /******************************************************************
  **
  ** Description:
  **     initializes package variables of the custom approval package
  **
  ** Access Status:
  **     Private
  **
  ******************************************************************/
  IS

  BEGIN
	  hr_approval_custom.g_itemtype := p_itemtype;
	  hr_approval_custom.g_itemkey  := p_itemkey;

  end set_custom_wf_globals;


  PROCEDURE start_wf(p_transaction_id IN pay_stat_trans_audit.stat_trans_audit_id%TYPE,
		    p_process IN VARCHAR2
		   )
 /******************************************************************
  **
  ** Description:
  **     initializes and starts workflow process
  **
  ** Access Status:
  **     Public
  **
  ******************************************************************/
  IS
	lv_itemkey	VARCHAR2(100);
	l_proc		VARCHAR2(80) := gv_package || '.start_wf';
  BEGIN

	hr_utility.set_location('Entering: ' || l_proc,5);

	lv_itemkey := to_char(p_transaction_id);

	wf_engine.createProcess(itemtype => gv_itemtype
				,itemkey => lv_itemkey
				,process => p_process
				);

	wf_engine.SetItemAttrNumber(itemtype => gv_itemtype
				   ,itemkey => lv_itemkey
				   ,aname => 'TRANSACTION_ID'
				   ,avalue => p_transaction_id
				   );

	wf_engine.startProcess(itemtype => gv_itemtype
			      ,itemkey => lv_itemkey
			      );

	hr_utility.set_location('Leaving: ' || l_proc,20);
  END start_wf;


 PROCEDURE init_tax_notifications(itemtype in varchar2
	 	  		,itemkey in varchar2
		  		,actid in number
		  		,funcmode in varchar2
		  		,result out nocopy varchar2
				)
 /******************************************************************
  **
  ** Description:
  **	Initializes the item attributes as appropriate.
  **
  ** Access Status:
  **     Public
  **
  ******************************************************************/
  IS
	ln_transaction_id	NUMBER(15);
	lv_status_code		VARCHAR2(30);

	CURSOR c_transaction IS
		select 	*
		from 	pay_stat_trans_audit
		where	source4_type = 'TRANSACTION_ID'
                and     source4 = ln_transaction_id;


	CURSOR c_state_list IS
		select pus.state_name
		from	pay_stat_trans_audit pta
			,pay_us_states pus
		where	pta.source4 = ln_transaction_id
		  and	pus.state_code = substr(pta.source1,1,2)
		  and exists(select 'x' from pay_us_state_tax_info_f stif
			     where stif.state_code = pus.state_code
			       and stif.sta_information7 = 'Y'
			       and stif.sta_information9 = 'Y'
			       and pta.transaction_effective_date between
					stif.effective_start_date and
					stif.effective_end_date);


        CURSOR c_exempt_state_list IS
                select pus.state_name
                from    pay_stat_trans_audit pta
                        ,pay_us_states pus
                where   pta.source4 = ln_transaction_id
                  and   pus.state_code = substr(pta.source1,1,2)
                  and exists(select 'x' from pay_us_state_tax_info_f stif
                             where stif.state_code = pus.state_code
                               and stif.sta_information7 = 'Y'
                               and stif.sta_information9 is null
                               and pta.transaction_effective_date between
                                        stif.effective_start_date and
                                        stif.effective_end_date);

	CURSOR c_fed_filing_status_code IS
		select 	meaning
		from	hr_lookups
		where	lookup_type = 'US_FIT_FILING_STATUS'
		  and	lookup_code = lv_status_code;



	r_trans_rec		c_transaction%ROWTYPE;
	lv_state_list		VARCHAR2(10000);
	lv_state_name		VARCHAR2(50);
	lv_status		hr_lookups.meaning%TYPE;
	lv_username		VARCHAR2(80);
	lv_disp_name		VARCHAR2(80);
	l_proc			VARCHAR2(80) := gv_package || '.init_tax_notifications';

        lv_state_msg            fnd_new_messages.message_text%TYPE;

	lv_exempt_state_list	VARCHAR2(10000);
	lv_exempt_state_name	VARCHAR2(50);
        lv_exempt_state_msg     fnd_new_messages.message_text%TYPE;
  BEGIN
    hr_utility.set_location('Entering: ' || l_proc,5);

    if funcmode = 'RUN' then
	-- get the transaction

	ln_transaction_id := wf_engine.GetItemAttrNumber(
				itemtype => itemtype
				,itemkey => itemkey
				,aname => 'TRANSACTION_ID'
				);

-- open this cursor with transaction_step_id
	OPEN c_transaction;
	FETCH c_transaction into r_trans_rec;
	CLOSE c_transaction;
    	hr_utility.set_location(l_proc,10);

    	wf_directory.GetUserName(p_orig_system    => 'PER',
                    		 p_orig_system_id => r_trans_rec.person_id,
                    		 p_name           => lv_username,
                    		 p_display_name   => lv_disp_name );

	wf_engine.SetItemAttrText(itemtype => itemtype
				 ,itemkey  => itemkey
				 ,aname    => 'EMPLOYEE_USERNAME'
				 ,avalue   => lv_username );

        wf_engine.SetItemAttrText(itemtype => itemtype -- added by vaprakas bug 5673790
                                  ,itemkey  => itemkey
                                  ,aname    => 'PERFORMER'
                                  ,avalue   => lv_username );

	wf_engine.SetItemAttrNumber(itemtype => itemtype
				   ,itemkey  => itemkey
				   ,aname    => 'EMPLOYEE_PERSON_ID'
				   ,avalue   => r_trans_rec.person_id);

	wf_engine.SetItemAttrText(itemtype => itemtype
				 ,itemkey  => itemkey
				 ,aname    => 'EMPLOYEE_DISPLAY_NAME'
				 ,avalue   => lv_disp_name);

	wf_engine.SetItemAttrNumber(itemtype => itemtype
				   ,itemkey  => itemkey
				   ,aname    => 'CURRENT_ASSIGNMENT_ID'
				   ,avalue   => r_trans_rec.assignment_id );

	wf_engine.SetItemAttrText(itemtype => itemtype
				 ,itemkey  => itemkey
				 ,aname    => 'TRANSACTION_SOURCE'
				 ,avalue   => r_trans_rec.source3 );

	wf_engine.SetItemAttrDate(itemtype => itemtype
				 ,itemkey  => itemkey
				 ,aname    => 'TRANSACTION_DATE'
				 ,avalue   => r_trans_rec.transaction_date );

	-- build the submission details
	if r_trans_rec.transaction_subtype = 'W4' then

		if r_trans_rec.source1 = '00-000-0000' then
		    	hr_utility.set_location(l_proc,20);

			lv_status_code := r_trans_rec.audit_information1;
			open c_fed_filing_status_code;
			fetch c_fed_filing_status_code into lv_status;
			if c_fed_filing_status_code%NOTFOUND then
	  			lv_status := lv_status_code;
			end if;
			close c_fed_filing_status_code;

			wf_engine.SetItemAttrText(
				 itemtype => itemtype
				 ,itemkey => itemkey
				 ,aname => 'FILING_STATUS_LABEL'
				 ,avalue => lv_status
				 );

			wf_engine.SetItemAttrText(
				 itemtype => itemtype
				 ,itemkey => itemkey
				 ,aname => 'ALLOWANCES'
				 ,avalue => r_trans_rec.audit_information2
				 );

			wf_engine.SetItemAttrText(
				 itemtype => itemtype
				 ,itemkey => itemkey
				 ,aname => 'ADDITIONAL_TAX'
				 ,avalue => r_trans_rec.audit_information3
				 );

			wf_engine.SetItemAttrText(
				 itemtype => itemtype
				 ,itemkey => itemkey
				 ,aname => 'FIT_EXEMPT'
				 ,avalue => r_trans_rec.audit_information4
				 );

			-- build the state list
			open c_state_list;
			fetch c_state_list into lv_state_name;

			while c_state_list%FOUND LOOP
			   if nvl(instr(lv_state_list,lv_state_name),0) = 0 then
				   lv_state_list := lv_state_list || '  ' || lv_state_name;
			   end if;
			   fetch c_state_list into lv_state_name;
			end loop;

                        if lv_state_list is not null then

                           lv_state_msg := hr_util_misc_web.return_msg_text('PAY_W4_WF_STATE_MSG','PAY');
                           lv_state_list := lv_state_msg ||' '|| lv_state_list;

                        end if;

                        open c_exempt_state_list;
                        fetch c_exempt_state_list into lv_exempt_state_name;

                        while c_exempt_state_list%FOUND LOOP
                           if nvl(instr(lv_state_list,lv_exempt_state_name),0) = 0 then
                              lv_state_list := lv_state_list || '  ' || lv_exempt_state_name;
                           end if;
                           fetch c_exempt_state_list into lv_exempt_state_name;
                        end loop;

			-- put the state list details in
			wf_engine.SetItemAttrText(itemtype => itemtype
						 ,itemkey => itemkey
						 ,aname => 'STATE_LIST'
				 		 ,avalue => lv_state_list
				 		);
		    	hr_utility.set_location(l_proc,30);

	    	end if; -- Federal jurisdiction
	end if;		-- W4 transaction subtype
     end if; -- funcmode = RUN

  hr_utility.set_location('Leaving: ' || l_proc, 100);

  end init_tax_notifications;

procedure check_final_notifier( itemtype    in varchar2,
                		itemkey     in varchar2,
               			actid       in number,
               			funcmode    in varchar2,
               			result      out nocopy varchar2     ) is

 /******************************************************************
  **
  ** Description:
  **	Determines if this is the last person in the payroll notification chain
  **
  ** Access Status:
  **     Public
  **
  ******************************************************************/

  l_proc	             	varchar2(80) := gv_package||'check_final_notifier';
  lv_contact_source		VARCHAR2(50);
  ln_transaction_id		pay_stat_trans_audit.stat_trans_audit_id%TYPE;
  ln_current_assignment_id	per_assignments_f.assignment_id%TYPE;
  lv_contact_user_name		VARCHAR2(150);
  ln_contact_person_id		per_people_f.person_id%TYPE;
  ln_employee_person_id		per_people_f.person_id%TYPE;

-- get the payroll contact

  CURSOR c_payroll_contact IS
	select 	/*+ ordered */ prl.prl_information1   --Bug 3362223
	from 	pay_stat_trans_audit pta
		,per_assignments_f paf
		,pay_payrolls_f prl
	where 	prl.payroll_id = paf.payroll_id
		and prl.prl_information_category = 'US'
		and paf.assignment_id = pta.assignment_id
		and pta.source4 = ln_transaction_id
                and pta.source4_type = 'TRANSACTION_ID'
		and pta.assignment_id = ln_current_assignment_id
--                and pta.transaction_parent_id is null
		and pta.transaction_effective_date between prl.effective_start_date and
							   prl.effective_end_date
		and pta.transaction_effective_date between paf.effective_start_date and
							    paf.effective_end_date
	order by pta.assignment_id asc;

-- get the GRE contact

  CURSOR c_gre_contact IS
        select org.org_information1
        from hr_organization_information org
        where org.org_information_context || '' = 'Contact Information'
          and org.organization_id =
                            (select /*+ ordered */ hsc.segment1  --Bug 3362223
                             from pay_stat_trans_audit pta
                                 ,per_assignments_f paf
                                 ,hr_soft_coding_keyflex hsc
                             where hsc.soft_coding_keyflex_id = paf.soft_coding_keyflex_id
                               and paf.assignment_id = pta.assignment_id
                               and pta.source4 = ln_transaction_id
                               and pta.source4_type = 'TRANSACTION_ID'
                               and pta.transaction_parent_id is null
                               and paf.assignment_id = ln_current_assignment_id
                               and pta.transaction_effective_date between paf.effective_start_date
                                                                      and paf.effective_end_date);
/*
	select 	org.org_information1
	from	hr_organization_information org
		,per_assignments_f paf
		,pay_stat_trans_audit pta
		,hr_soft_coding_keyflex hsc
	where	org.organization_id = hsc.segment1
	  and	hsc.soft_coding_keyflex_id = paf.soft_coding_keyflex_id
	  and	paf.assignment_id = pta.assignment_id
	  and   pta.source4 = ln_transaction_id
          and   pta.source4_type = 'TRANSACTION_ID'
	  and	org.org_information_context = 'Contact Information'
	  and	pta.assignment_id = ln_current_assignment_id
	  and	pta.transaction_effective_date between paf.effective_start_date and
		 					paf.effective_end_date
	order by pta.assignment_id asc;
*/

begin
   --hr_utility.trace_on(null,'oracle');

   hr_utility.set_location('Entering: ' || l_proc || ':' || funcmode, 5);

if ( funcmode = 'RUN' ) then
    lv_contact_source := fnd_profile.value('HR_PAYROLL_CONTACT_SOURCE');

    ln_transaction_id := wf_engine.GetItemAttrNumber
				(itemtype => itemtype
				,itemkey => itemkey
				,aname => 'TRANSACTION_ID'
				);

    ln_current_assignment_id := wf_engine.GetItemAttrNumber
				(itemtype => itemtype
				,itemkey => itemkey
				,aname => 'CURRENT_ASSIGNMENT_ID'
				);

    ln_contact_person_id := wf_engine.GetItemAttrNumber
				(itemtype => itemtype
				,itemkey => itemkey
				,aname => 'CONTACT_PERSON_ID'
				);

    ln_employee_person_id := wf_engine.GetItemAttrNumber
				(itemtype => itemtype
				,itemkey => itemkey
				,aname => 'EMPLOYEE_PERSON_ID'
				);
    hr_utility.trace('Profile Value is : '|| lv_contact_source);
    hr_utility.trace('Transaction Id is : '|| ln_transaction_id);
    hr_utility.trace('Assignment Id is : '|| ln_current_assignment_id);
    hr_utility.trace('Contact Person Id is : '|| ln_contact_person_id);
    hr_utility.trace('Employee Id is : '|| ln_employee_person_id);

    -- -----------------------------------------------------------------------
    -- expose the wf control variables to the custom package
    -- -----------------------------------------------------------------------
    if lv_contact_source = 'CUSTOM' then
	    set_custom_wf_globals
	      (p_itemtype => itemtype
	      ,p_itemkey  => itemkey);

      	    -- call a custom check final notifier. Returns a 'Yes', 'No' or 'Error'

	     result := 'COMPLETE:'||
                hr_approval_custom.check_final_payroll_notifier
                  (p_forward_to_person_id       => ln_contact_person_id
                  ,p_person_id                  => ln_employee_person_id );


    elsif lv_contact_source = 'PAYROLL' then
	open c_payroll_contact;
	fetch c_payroll_contact into lv_contact_user_name;
        hr_utility.trace('Contact User is : '|| lv_contact_user_name);
	if c_payroll_contact%FOUND then
		result := 'COMPLETE:N';
	else
		result := 'COMPLETE:Y';
	end if;

	close c_payroll_contact;

        hr_utility.trace('Result is : '|| result);

    elsif lv_contact_source = 'GRE' then
	open c_gre_contact;
	fetch c_gre_contact into lv_contact_user_name;
	if c_gre_contact%FOUND then
		result := 'COMPLETE:N';
	else
		result := 'COMPLETE:Y';
	end if;

	close c_gre_contact;

    else -- some other source we don't understand yet
	result := 'ERROR:UNKNOWN_CONTACT_SOURCE';
    end if;


elsif ( funcmode = 'CANCEL' ) then
	null;

end if;

  hr_utility.set_location('Leaving: ' || l_proc, 100);
end check_final_notifier;


 PROCEDURE get_next_notifier(itemtype in varchar2
		   	    ,itemkey in varchar2
		   	    ,actid in number
		   	    ,funcmode in varchar2
		   	    ,result out nocopy varchar2
		   	     )
 /******************************************************************
  **
  ** Description:
  **     Gets the next payroll rep who needs to be notified and sets
  ** 	 the forward from/to item attributes as proper.
  **
  **
  ** Access Status:
  **     Public
  **
  ******************************************************************/
  IS

  l_proc                 	varchar2(61) := gv_package||'get_next_payroll_notifer';
  ln_transaction_id		pay_stat_trans_audit.stat_trans_audit_id%TYPE;
  ln_current_assignment_id	per_assignments_f.assignment_id%TYPE;
  lv_contact_source		VARCHAR2(50);
  lv_curr_contact_user		VARCHAR2(100);
  lv_next_contact_user		VARCHAR2(100);
  lv_dummy			VARCHAR2(100);
  ln_curr_contact_person_id	per_people_f.person_id%TYPE;
  ln_next_contact_person_id	per_people_f.person_id%TYPE;

  CURSOR c_payroll_contact IS
	select 	/*+ ordered */ usr.employee_id    --Bug 3362223
		,pta.assignment_id
	from 	pay_stat_trans_audit pta
		,per_assignments_f paf
		,pay_payrolls_f prl
		,fnd_user usr
	where 	prl.payroll_id = paf.payroll_id
		and usr.user_name = prl.prl_information1
		and prl.prl_information_category = 'US'
		and paf.assignment_id = pta.assignment_id
	        and pta.source4 = ln_transaction_id
                and pta.source4_type = 'TRANSACTION_ID'
		and pta.assignment_id = ln_current_assignment_id
 --               and pta.transaction_parent_id is null
		and pta.transaction_effective_date between prl.effective_start_date and
							   prl.effective_end_date
		and pta.transaction_effective_date between paf.effective_start_date and
							    paf.effective_end_date
	order by pta.assignment_id asc;

  CURSOR c_gre_contact IS
        select  usr.employee_id
                ,pta.assignment_id
        from    hr_organization_information org
                ,pay_stat_trans_audit pta
                ,fnd_user usr
        where   usr.user_name = org.org_information1
          and   pta.assignment_id = ln_current_assignment_id
          and   pta.source4 = ln_transaction_id
          and   pta.source4_type = 'TRANSACTION_ID'
          and   pta.transaction_parent_id is null
          and   org.org_information_context ||'' = 'Contact Information'
          and   org.organization_id = (select hsc.segment1
                                         from per_assignments_f paf
                                             ,hr_soft_coding_keyflex hsc
                                        where paf.assignment_id = ln_current_assignment_id
                                          and hsc.soft_coding_keyflex_id = paf.soft_coding_keyflex_id
                                          and pta.transaction_effective_date
                                                         between paf.effective_start_date
                                                             and paf.effective_end_date
                                       );


begin

  hr_utility.set_location('Entering: ' || l_proc || ':'|| funcmode,5);

if ( funcmode = 'RUN' ) then

    lv_contact_source := fnd_profile.value('HR_PAYROLL_CONTACT_SOURCE');

    ln_transaction_id := wf_engine.GetItemAttrNumber
				(itemtype => itemtype
				,itemkey  => itemkey
				,aname    => 'TRANSACTION_ID');

    ln_current_assignment_id := wf_engine.GetItemAttrNumber
				(itemtype => itemtype
				,itemkey  => itemkey
				,aname    => 'CURRENT_ASSIGNMENT_ID');

    lv_curr_contact_user := wf_engine.GetItemAttrText
				(itemtype => itemtype
				,itemkey  => itemkey
				,aname    => 'CONTACT_USERNAME');

    ln_curr_contact_person_id := wf_engine.GetItemAttrNumber
				(itemtype => itemtype
				,itemkey  => itemkey
				,aname    => 'CONTACT_PERSON_ID');

    if lv_contact_source = 'CUSTOM' then
	    -- -----------------------------------------------------------------------
	    -- expose the wf control variables to the custom package
	    -- -----------------------------------------------------------------------
	    set_custom_wf_globals
	      (p_itemtype => itemtype
	      ,p_itemkey  => itemkey);

	    -- set the next forward to

	    ln_next_contact_person_id :=
	      hr_approval_custom.Get_Next_Payroll_Notifier
	        (p_person_id => ln_curr_contact_person_id);

    elsif lv_contact_source = 'PAYROLL' then
	open c_payroll_contact;
	fetch c_payroll_contact into ln_next_contact_person_id,ln_current_assignment_id;
	close c_payroll_contact;

    elsif lv_contact_source = 'GRE' then
	open c_gre_contact;
	fetch c_gre_contact into ln_next_contact_person_id,ln_current_assignment_id;
	close c_gre_contact;

    else
	result := 'ERROR:UNKNOWN_CONTACT_SOURCE';
	return;
    end if;

    if ( ln_next_contact_person_id is null ) then
        result := 'COMPLETE:F';

    else
        wf_directory.GetUserName
	          (p_orig_system    => 'PER'
	          ,p_orig_system_id => ln_next_contact_person_id
	          ,p_name           => lv_next_contact_user
	          ,p_display_name   => lv_dummy);

        wf_engine.SetItemAttrNumber
	          (itemtype    => itemtype
	          ,itemkey     => itemkey
	          ,aname       => 'CONTACT_PERSON_ID'
	          ,avalue      => ln_next_contact_person_id);

        wf_engine.SetItemAttrNumber
	          (itemtype    => itemtype
	          ,itemkey     => itemkey
	          ,aname       => 'CURRENT_ASSIGNMENT_ID'
	          ,avalue      => ln_current_assignment_id);

        wf_engine.SetItemAttrText
	          (itemtype => itemtype
	          ,itemkey  => itemkey
	          ,aname    => 'CONTACT_USERNAME'
	          ,avalue   => lv_next_contact_user);

   hr_utility.set_location('Leaving: ' || l_proc,100);
        result := 'COMPLETE:T';

    end if;

elsif ( funcmode = 'CANCEL' ) then
    null;

end if;
--
end get_next_notifier;


 PROCEDURE check_for_notification(itemtype in varchar2
				,itemkey in varchar2
				,actid in number
				,funcmode in varchar2
				,result out nocopy varchar2
				)
 /******************************************************************
  **
  ** Description:
  **	Checks the submitted form for conditions that require
  **	notification to be sent to a Payroll manager.
  **
  ** Access Status:
  **     Public
  **
  ******************************************************************/
  IS
	ln_transaction_id	NUMBER(15);

	CURSOR c_transaction is
		select	transaction_subtype
			,business_group_id
			,person_id
			,assignment_id
			,transaction_effective_date
			,source1
			,source1_type
			,source2
			,source2_type
			,audit_information2
			,audit_information4
		from	pay_stat_trans_audit
                where   source4_type = 'TRANSACTION_ID'
                and     source4 = ln_transaction_id;

	CURSOR c_fed_allowance_limit is
		select 	fed_information1
		from	pay_us_federal_tax_info_f
		where	fed_information_category = 'ALLOWANCES LIMIT'
		and	trunc(sysdate) between effective_start_date
                                           and effective_end_date;


	lv_exception_reason	VARCHAR2(10000);
        lv_context              VARCHAR2(50);
        lv_level                VARCHAR2(50);
        lv_notify               VARCHAR2(100);
	lr_trans_rec		c_transaction%ROWTYPE;
	lr_fed_rec		c_fed_allowance_limit%ROWTYPE;
	l_proc			VARCHAR2(80) := gv_package || '.check_for_notification';

  BEGIN
   hr_utility.set_location('Entering: ' || l_proc || ':' || funcmode,5);
    if (funcmode = 'RUN') then
	ln_transaction_id := wf_engine.GetItemAttrNumber(itemtype => itemtype
							,itemkey => itemkey
							,aname => 'TRANSACTION_ID');

        hr_utility.trace('Transaction Id is : '|| to_char(ln_transaction_id));

-- from the transaction_id get the details

	open c_transaction;
	fetch c_transaction into lr_trans_rec;
	close c_transaction;

        hr_utility.trace('lr_trans_rec.transaction_subtype is : '|| lr_trans_rec.transaction_subtype);

	if lr_trans_rec.transaction_subtype = 'W4' then

-- check the W4 Notification Required setup at Business Group level
-- and /or Organization levle

-- Check the Organization Level and/or Business Group Level Context
--is Set for W4 Notifications.
-- Organization Level Context
   lv_context := 'US_ORG_REP_PREFERENCES';
   lv_level := 'ORG';

   lv_notify := pay_us_web_w4.get_org_context(lr_trans_rec.person_id, lv_context,lv_level);

   hr_utility.trace('ORG pay_us_web_w4.get_org_context lv_notify = '||lv_notify);
   if lv_notify = 'NOTFOUND' then
      -- Business Group Level Context
         lv_context := 'US_BG_REP_PREFERENCES';
         lv_level := 'BG';
         lv_notify := pay_us_web_w4.get_org_context(lr_trans_rec.person_id, lv_context,lv_level);
         hr_utility.trace('BG pay_us_web_w4.get_org_context lv_notify = '||lv_notify);
    end if;



          hr_utility.trace('lr_trans_rec.source1 is : '|| lr_trans_rec.source1);

        if lv_notify  = 'Y' then

	   if lr_trans_rec.source1 = '00-000-0000' then

		/* We check for two conditions for the federal W4:
                 * First we check to see if the allowance is over the allowance limit.
		 * Next, we check to see if FIT exempt = Y
		 */
		open c_fed_allowance_limit;
		fetch c_fed_allowance_limit into lr_fed_rec;
		close c_fed_allowance_limit;

                hr_utility.trace('lr_fed_rec.fed_information1 is : '||lr_fed_rec.fed_information1);
		if (lr_fed_rec.fed_information1 is not null) and
		   (to_number(lr_trans_rec.audit_information2) >
					to_number(lr_fed_rec.fed_information1)) then

                        hr_utility.trace('Inside if for allowance checking.');
			hr_utility.set_message(801,'PAY_US_OTF_W4_FED_OVERALLOW');

			wf_engine.SetItemAttrText(itemtype => itemtype
						 ,itemkey  => itemkey
						 ,aname    => 'EXCEPTION_REASON'
						 ,avalue   => hr_utility.get_message);

			result := 'COMPLETE:Y';

		elsif lr_trans_rec.audit_information4 = 'Y' then
                        hr_utility.trace('Inside elsif lr_trans_rec.audit_information4.');
			hr_utility.set_message(801,'PAY_US_OTF_FED_EXEMPTWARN');

			wf_engine.SetItemAttrText(itemtype => itemtype
						 ,itemkey  => itemkey
						 ,aname    => 'EXCEPTION_REASON'
						 ,avalue   => hr_utility.get_message);
			result := 'COMPLETE:Y';
		else
                        hr_utility.trace('failed on allowances and exempt');
			result := 'COMPLETE:N';
		end if;
	    else /* lr_trans_rec.source1 = '00-000-0000' */

                hr_utility.trace('source1 <> 00-000-0000');
		result := 'COMPLETE:N';
	    end if;
	  else /*lv_notify = 'Y' */
                hr_utility.trace('lv_notify <> Y');
		result := 'COMPLETE:N';
	  end if;
	else  /* lr_trans_rec.transaction_subtype = 'W4' */
            hr_utility.trace('transaction_subtype <> W4');
	    result := 'COMPLETE:N';
	end if;
    end if;
    hr_utility.set_location('Leaving: ' || l_proc || ':' || result,100);

  end check_for_notification;

 /* Uncomment following two lines for debug */
--    begin
--    hr_utility.trace_on(null,'pyusw4wf');

END pay_us_w4_wf;

/
