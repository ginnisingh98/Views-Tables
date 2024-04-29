--------------------------------------------------------
--  DDL for Package Body PAY_US_W2_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_W2_WF" 
/* $Header: pyusw2wf.pkb 115.5 2002/12/04 21:06:13 meshah noship $ *
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

    Name        : pay_us_w2_wf

    Description : Contains workflow code the W2 Notifications Workflow

    Uses        :

    Change List
    -----------
    Date        Name    Vers   Description
    ----        ----    ----   -----------
    22-MAR-2002 meshah  115.0  Created.
    26-MAR-2002 meshah  115.1  Added dbdrv command.
    17-MAY-2002 fusman  115.2  Added set verify off.
    19-AUG-2002 fusman  115.3  Added whenever OS error command.
    24-SEP-2002 fusman  115.4  Fix for Bug:2479954. Changed c_gre_contact
    04-DEC-2002 meshah  115.5  nocopy.
  *******************************************************************/
  AS

  /******************************************************************
  ** private package global declarations
  ******************************************************************/
  gv_package               VARCHAR2(50) := 'pay_us_w2_wf';


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


 PROCEDURE get_w2_notifier(itemtype in varchar2,
	   	           itemkey  in varchar2,
		   	   actid    in number,
		   	   funcmode in varchar2,
		   	   result   out nocopy varchar2
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

  l_proc                 	varchar2(61) := gv_package||'get_w2_notifier';
  ln_current_assignment_id	per_assignments_f.assignment_id%TYPE;
  lv_contact_source		VARCHAR2(50);
  lv_curr_contact_user		VARCHAR2(100);
  lv_next_contact_user		VARCHAR2(100);
  lv_dummy			VARCHAR2(100);
  ln_curr_contact_person_id	per_people_f.person_id%TYPE;
  ln_next_contact_person_id	per_people_f.person_id%TYPE;

  CURSOR c_payroll_contact IS
	select 	usr.employee_id,
	        paf.assignment_id
	from 	pay_payrolls_f prl,
	        per_assignments_f paf,
		fnd_user usr
	where 	prl.payroll_id = paf.payroll_id
	    and usr.user_name = prl.prl_information1
	    and prl.prl_information_category = 'US'
	    and paf.assignment_id = ln_current_assignment_id
	    and sysdate between prl.effective_start_date and prl.effective_end_date
	    and sysdate between paf.effective_start_date and paf.effective_end_date
	order by paf.assignment_id asc;

  CURSOR c_gre_contact IS
	select 	usr.employee_id,
	        paf.assignment_id
	from	hr_organization_information org,
	        per_assignments_f paf,
	        fnd_user usr
	where	org.organization_id = (select hsc.segment1
                                       from hr_soft_coding_keyflex hsc
                                       where hsc.soft_coding_keyflex_id = paf.soft_coding_keyflex_id)
	  and	usr.user_name = org.org_information1
	  and	paf.assignment_id = ln_current_assignment_id
	  and	org.org_information_context = 'Contact Information'
	  and	sysdate between paf.effective_start_date and paf.effective_end_date
	order by paf.assignment_id asc;

begin
  --hr_utility.trace_on(null,'oracle');
  hr_utility.set_location('Entering: ' || l_proc || ':'|| funcmode,5);

if ( funcmode = 'RUN' ) then

    lv_contact_source := fnd_profile.value('HR_PAYROLL_CONTACT_SOURCE');

    hr_utility.trace('Profile Option value is : '|| lv_contact_source);

    ln_current_assignment_id := wf_engine.GetItemAttrNumber
				(itemtype => itemtype
				,itemkey  => itemkey
				,aname    => 'CURRENT_ASSIGNMENT_ID');

    hr_utility.trace('Assignment Id is : '|| to_char(ln_current_assignment_id));

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
	fetch c_payroll_contact into ln_next_contact_person_id,
                                     ln_current_assignment_id;
	close c_payroll_contact;

    elsif lv_contact_source = 'GRE' then
	open c_gre_contact;
	fetch c_gre_contact into ln_next_contact_person_id,
                                 ln_current_assignment_id;
	close c_gre_contact;

    else
        hr_utility.trace('If this prints then this is bad ');
	result := 'ERROR:UNKNOWN_CONTACT_SOURCE';
	return;
    end if;

        hr_utility.trace('Contact is ' || to_char(ln_next_contact_person_id));
        hr_utility.trace('Assignment is ' || to_char(ln_current_assignment_id));

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
end get_w2_notifier;

END pay_us_w2_wf;

/
