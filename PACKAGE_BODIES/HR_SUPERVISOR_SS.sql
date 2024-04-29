--------------------------------------------------------
--  DDL for Package Body HR_SUPERVISOR_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_SUPERVISOR_SS" 
/* $Header: hrsupwrs.pkb 120.4.12010000.9 2010/01/29 10:00:34 gpurohit ship $*/
AS
 gv_activity_name  constant varchar2(50) := 'HR_CHANGE_MANAGER';
 gv_date_format    constant varchar2(10) :='RRRR-MM-DD';
 gv_package        constant varchar2(30) := 'HR_SUPERVISOR_SS';
 g_package        constant varchar2(30) := 'HR_SUPERVISOR_SS';
 g_applicant_hire boolean := false;

  /*
  ||===========================================================================
  || FUNCTION: update_object_version
  || DESCRIPTION: Update the object version number in the transaction step
  ||              to pass the invalid object api error for Save for Later.
  ||=======================================================================
  */
  PROCEDURE update_object_version
  (p_transaction_step_id in     number
  ,p_login_person_id in number) IS

   l_proc constant varchar2(100) := g_package || ' update_object_version';
  BEGIN
    hr_utility.set_location('Entering'|| l_proc,5);
    -- We don't need to have specific code to update the object version
    -- number for SAVE_FOR_LATER because in update_supervisor procedure, it
    -- always gets the object version number at run time every time.  Therefore,
    -- no specific code is required here.  We just need to have dummy stub
    -- for SAVE_FOR_LATER to resolve the call.
    null;
 hr_utility.set_location('Leaving'|| l_proc,10);
  END update_object_version;

  /*
  ||===========================================================================
  || PROCEDURE: branch_on_cost_center_mgr
  || DESCRIPTION:
  ||        This procedure will read the CURRENT_PERSON_ID item level
  ||        attribute value and then find out nocopy if the employee to be terminated
  ||        is a cost center manager or not.  If yes, it will set the WF item
  ||        attribute HR_TERM_COST_CENTER_MGR_FLAG to 'Y' and the WF result code
  ||        will be set to "Y".  In doing so,  workflow will transition to the
  ||        Cost Center page accordingly.
  ||        This procedure will set the wf transition code as follows:
  ||          (Y/N)
  ||          For 'Y'    => branch to Cost Center page
  ||              'N'    => do not branch to Cost Center page
  ||=======================================================================
  */
PROCEDURE branch_on_cost_center_mgr
 (itemtype     in     varchar2
  ,itemkey     in     varchar2
  ,actid       in     number
  ,funcmode    in     varchar2
  ,resultout   out nocopy varchar2)
IS

  ld_effective_date        date default trunc(sysdate);
  ln_person_id             number default null;
  ln_creator_person_id     number default null;
  lv_high_end_date         constant  varchar2(12) := '4712/12/31';
  lv_term_sup_flag         varchar2(30) default null;
  l_proc                   varchar2(100) :=g_package || ' branch_on_cost_center_mgr';
  ln_assignment_id	number default null;
  dummy		varchar2(2);
  l_term_sec_asg	varchar2(2);
  l_vol_term		varchar2(6);
  dummy_2 		varchar2(2);
  -- This cursor is copied from the Cost Center Manager Relationship Module,
  -- see $PER_TOP/java/selfservice/ccmgr/server/HRCCMgrRelationshipsVO.java.
  -- However, it has removed security check in the where clause because we want
  -- to issue a notification when the login person does not have access to both
  -- the organziation and the cost center manager.  So, only this removal of
  -- security check is different from the java HRCCMgrRelationshipsVO.java
  -- VO.
  -- For any problem, please consult the owner of that module.
  -- A given person (the selected person) can be assigned as a cost center
  -- manager in more than one cost centers.
  -- The has_update_access (='Y') column signifies that the person has access
  -- to both the Organization and the Manager in the cost center
  -- relationship(s)
  -- Security Check:
  --  Where clause: fetch all relationships that are current or future dated
  --  that the person has access to either Organization Or Manager.

  CURSOR  csr_update_access_check  IS
  SELECT  hao.organization_id
         ,fnd_date.canonical_to_date(cost_center.ORG_INFORMATION3) start_date
         ,fnd_date.canonical_to_date(cost_center.ORG_INFORMATION4) end_date
         ,decode(
                (decode(decode(HR_SECURITY.VIEW_ALL ,'Y' , 'TRUE'
                              ,HR_SECURITY.SHOW_RECORD
                                   ('HR_ALL_ORGANIZATION_UNITS'
                                   ,HAO.ORGANIZATION_ID
                                   )
                              ),'TRUE',0,1
                        ) +
                 decode(decode(hr_general.get_xbg_profile
                              ,'Y', hao.business_group_id
                              ,hr_general.get_business_group_id
                              )
                       ,hao.business_group_id,0,1
                       ) +
                 decode(decode(HR_SECURITY.VIEW_ALL ,'Y' , 'TRUE'
                              ,HR_SECURITY.SHOW_RECORD
                                    ('PER_ALL_PEOPLE_F'
                                    ,PAP.PERSON_ID
                                    ,PAP.PERSON_TYPE_ID
                                    ,PAP.EMPLOYEE_NUMBER
                                    ,PAP.APPLICANT_NUMBER
                                    )
                              )
                        ,'TRUE',0,1
                       ) +
                decode(decode(hr_general.get_xbg_profile
                             ,'Y',pap.business_group_id
                             ,hr_general.get_business_group_id
                             )
                      ,pap.business_group_id,0,1
                      )
                ),0,'Y','N'
              ) has_update_access
  FROM   hr_organization_information cost_center
        ,per_all_people_f pap, hr_all_organization_units hao
  WHERE  cost_center.ORG_INFORMATION2 = to_char(pap.person_id)
  AND cost_center.org_information_context = 'Organization Name Alias'
  AND pap.person_id = ln_person_id
  AND (pap.current_employee_flag = 'Y' or pap.current_npw_flag = 'Y')
  AND hao.organization_id = cost_center.organization_id
  AND trunc(sysdate) between hao.date_from and nvl(hao.date_to,trunc(sysdate))
  AND trunc(sysdate) between pap.effective_start_date and pap.effective_end_date
/* Excluding pending approvals */
  AND not exists (select 'e' from hr_api_transaction_steps s, hr_api_transactions t
                 where s.api_name = 'HR_CCMGR_SS.PROCESS_API'
                 --Bug 3034218: Exclude current process, include v5 pending status RO, ROS and YS
                 and s.transaction_id = t.transaction_id and status IN ('YS', 'Y','RO','ROS')
                 and t.item_key       <> itemKey
                 --BUG 3648732
                 and exists
                 (
                   SELECT NULL FROM hr_api_transaction_values v
                   WHERE s.transaction_step_id+0 = v.transaction_step_id
                   AND v.name = 'P_ORGANIZATION_ID'
                   AND v.number_value = hao.organization_id
                 )
                 and rownum < 2)
  AND exists (select 'e' from hr_organization_information class, hr_org_info_types_by_class ctype
	            where ctype.org_information_type = 'Organization Name Alias'
	            and ctype.org_classification = class.org_information1
	            and class.org_information_context = 'CLASS'
	            and class.org_information2 = 'Y'
	            and class.organization_id = cost_center.organization_id)
  AND (nvl(fnd_date.canonical_to_date(cost_center.ORG_INFORMATION4),ld_effective_date) >= ld_effective_date
       Or (fnd_date.canonical_to_date(cost_center.ORG_INFORMATION4) <= ld_effective_date
           and fnd_date.canonical_to_date(cost_center.ORG_INFORMATION3)
                           = (select max(fnd_date.canonical_to_date(oi.ORG_INFORMATION3))
                             from hr_organization_information oi
                             where oi.org_information_context = 'Organization Name Alias'
                             and oi.organization_id = cost_center.organization_id)));  -- 2476134

  -- NOTE: We need to use the primary assignment because we're trying to
  --       derive the manager id of the login person, not the action employee.
  CURSOR csr_get_mgr_id_of_login IS
  SELECT paf.supervisor_id
  FROM   per_all_assignments_f   paf
        ,per_all_people_f ppf
  WHERE ppf.person_id = ln_creator_person_id
  and    paf.person_id = ppf.person_id
  and    ld_effective_date between ppf.effective_start_date
                               and ppf.effective_end_date
  and    ld_effective_date between paf.effective_start_date
                               and paf.effective_end_date
  and    (paf.assignment_type = 'E' and ppf.current_employee_flag = 'Y'
       or paf.assignment_type = 'C' and ppf.current_npw_flag = 'Y')
  and    paf.primary_flag = 'Y';

  ln_manager_id           number default null;
  lv_no_access_to_some_cc varchar2(1) default null;

cursor csr_attr_value(actid in number, name in varchar2) is
	SELECT WAAV.TEXT_VALUE Value
	FROM WF_ACTIVITY_ATTR_VALUES WAAV
	WHERE WAAV.PROCESS_ACTIVITY_ID = actid
	AND WAAV.NAME = name;

BEGIN
  --
  -- Get the action person id, ie. selected person id
  hr_utility.set_location('Entering '|| l_proc,5);
  ln_person_id := wf_engine.GetItemAttrNumber
                       (itemtype => itemtype
                       ,itemkey  => itemkey
                       ,aname    => 'CURRENT_PERSON_ID');

  ln_assignment_id := wf_engine.GetItemAttrNumber (
                    itemtype => itemtype,
                    itemkey  => itemkey,
                    aname    => 'CURRENT_ASSIGNMENT_ID');

  -- Get the login person id
  ln_creator_person_id := wf_engine.GetItemAttrNumber
                       (itemtype => itemtype
                       ,itemkey  => itemkey
                       ,aname    => 'CREATOR_PERSON_ID');


  -- The termination effective date was stored in the wf item attribute
  -- CURRENT_EFFECTIVE_DATE as a date data type.
  ld_effective_date := wf_engine.GetItemAttrDate
                       (itemtype => itemtype
                       ,itemkey  => itemkey
                       ,aname    => 'CURRENT_EFFECTIVE_DATE');

  -- Need to get the wf item attribute HR_TERM_SUP_FLAG so that the Supervisor
  -- page knows whether the caller is from Termination or not.
  lv_term_sup_flag  := wf_engine.GetItemAttrText
                        (itemtype => itemtype
                        ,itemkey  => itemkey
                        ,aname    => 'HR_TERM_SUP_FLAG');

  -- We will set the result code to 'Y' only if the item attribute
  -- HR_TERM_SUP_FLAG is set to 'Y', that means the caller is from Termination.
  -- Otherwise, we don't need to branch to the Cost Center Manager module.
  IF lv_term_sup_flag = 'Y' THEN
  hr_utility.trace('In (if lv_term_sup_flag = Y)'|| l_proc);
     	resultout := 'COMPLETE:'|| 'N';
        lv_no_access_to_some_cc := 'N';

        select primary_flag into dummy from per_all_assignments_f where
        assignment_id=ln_assignment_id and ld_effective_date between
        effective_start_date and effective_end_date;

         l_term_sec_asg := wf_engine.getitemattrtext(itemtype, itemkey,
                                                		'HR_TERM_SEC_ASG',true);

        -- We need to run the update_access_check cursor to see if the
        -- login person has the security access to select another manager
        -- for the cost centers that the terminated employee is responsible
        -- for.  If the login person has access to some cost centers and not
        -- all of them, we need to construct the WF item_attribute
        -- hr_mgr_id_of_login_person to contain the login person's manager's
        -- person_id.  Later on after the Confirmation page, a notification
        -- will be sent to the login person's supervisor to explain to them
        -- him that the manager of a cost center has been terminated and a new
        -- one needs to be assigned.  If the login person does not have a
        -- supervisor, per CM Beach on 02/18/2002, a notification will be sent
        -- to the login person himself so that he can forward the email to
        -- whomever appropriate to reassign a new cost center manager.
        --
      if (l_term_sec_asg is null OR l_term_sec_asg <> 'Y' OR dummy = 'Y') then
        FOR get_update_access in csr_update_access_check LOOP
           IF get_update_access.has_update_access = 'Y' THEN
              resultout := 'COMPLETE:'|| 'Y';
           ELSE
              lv_no_access_to_some_cc := 'Y';
           END IF;
        END LOOP;
      end if;

     if (ln_person_id = fnd_global.employee_id) then
        l_vol_term := wf_engine.getitemattrtext(itemtype, itemkey,
                                                  		'HR_VOL_TERM_SS',true);
        if (l_vol_term is not null) then
           open csr_attr_value(actid,'BYPASS_ORG_MGR');
           fetch csr_attr_value into dummy_2;
           close  csr_attr_value;
        end if;
     end if;

     if (dummy_2 = 'Y' and resultout = 'COMPLETE:Y') then
          resultout := 'COMPLETE:'|| 'N';
          if (l_vol_term = 'SUP') then
             wf_engine.setitemattrtext(itemtype,itemkey,'HR_VOL_TERM_SS','BOTH');
          elsif (l_vol_term = 'Y') then
             wf_engine.setitemattrtext(itemtype,itemkey,'HR_VOL_TERM_SS','CCMGR');
          end if;
     end if;

        -- We need to get the login person's manager id and set the WF item
        -- attribute hr_mgr_id_of_login_person if the resultout is 'Y' and
        -- the lv_no_access_to_some_cc is 'Y' also.  That means there
        -- is some cost centers that the login person cannot access and the
        -- person terminated is a cost center manager.

        IF lv_no_access_to_some_cc = 'Y' THEN
          hr_utility.trace('In (if lv_no_access_to_some_cc = Y)'|| l_proc);
           OPEN csr_get_mgr_id_of_login;
           FETCH csr_get_mgr_id_of_login into ln_manager_id;
           IF csr_get_mgr_id_of_login%NOTFOUND THEN
              -- set the WF item attribute hr_mgr_id_of_login_person to the
              -- login person himself if he does not have a manager to report
              -- to.  This is concurred by C. Beach on 02/18/2002.  The reason
              -- is that the login person can forward the notification to
              -- someone else.

              wf_engine.SetItemAttrNumber
                (itemtype => itemtype
                ,itemkey  => itemkey
                ,aname    => 'HR_MGR_ID_OF_LOGIN_PERSON'
                ,avalue   => ln_creator_person_id);
           ELSE
                wf_engine.SetItemAttrNumber
                (itemtype => itemtype
                ,itemkey  => itemkey
                ,aname    => 'HR_MGR_ID_OF_LOGIN_PERSON'
                ,avalue   => ln_manager_id);
           END IF;

           CLOSE csr_get_mgr_id_of_login;
        END IF;
  END IF;     -- lv_term_sup_flag = 'Y'
hr_utility.set_location('Leaving'|| l_proc,20);
EXCEPTION
  WHEN OTHERS THEN
    hr_utility.set_location('EXCEPTION'|| l_proc,555);
    WF_CORE.CONTEXT(gv_package
                   ,'BRANCH_ON_COST_CENTER_MGR'
                   ,itemtype
                   ,itemkey
                   ,to_char(actid)
                   ,funcmode);
    RAISE;

END branch_on_cost_center_mgr;

/*
  ||===========================================================================
  || PROCEDURE: create_transaction
  || DESCRIPTION: Create transaction and transaction steps.
  ||===========================================================================
  */

  PROCEDURE  Create_transaction(
     p_item_type               IN WF_ITEMS.ITEM_TYPE%TYPE ,
     p_item_key  	       IN WF_ITEMS.ITEM_KEY%TYPE ,
     p_act_id    	       IN NUMBER ,
     p_transaction_id          IN OUT NOCOPY NUMBER ,
     p_transaction_step_id     IN OUT NOCOPY NUMBER,
     p_login_person_id         IN NUMBER ,
     p_review_proc_call        IN VARCHAR2 ,
     p_no_of_direct_reports    IN NUMBER DEFAULT 0,
     p_no_of_emps              IN NUMBER DEFAULT 0 ,
     p_selected_emp_name       IN VARCHAR2 DEFAULT NULL,
     p_single_supervisor_name  IN VARCHAR2 DEFAULT NULL ,
     p_single_effective_date   IN DATE DEFAULT NULL,
     p_term_flag               IN VARCHAR2,
     p_selected_emp_id         IN NUMBER,
     p_rptg_grp_id             IN VARCHAR2 DEFAULT NULL,
     p_plan_id                 IN VARCHAR2 DEFAULT NULL,
     p_effective_date_option   IN VARCHAR2  DEFAULT NULL )  IS
   --p_selected_emp_id is the new attribute added on jan 8th raj

  ln_transaction_id      NUMBER ;
  ln_transaction_step_id NUMBER ;
  lv_result  VARCHAR2(100) ;
  ltt_trans_obj_vers_num  hr_util_web.g_varchar2_tab_type;
  lv_activity_name        wf_item_activity_statuses_v.activity_name%TYPE;
  ln_trans_step_rows      number  default 0;
  ltt_trans_step_ids      hr_util_web.g_varchar2_tab_type;
  ln_ovn                  hr_api_transaction_steps.object_version_number%TYPE;
  ln_term_flag            BOOLEAN DEFAULT FALSE;
  l_proc constant varchar2(1000) := g_package || ' Create_transaction';
  BEGIN
    hr_utility.set_location('Entering'|| l_proc,5);
    ln_transaction_id := hr_transaction_ss.get_transaction_id
      (p_Item_Type => p_item_type
      ,p_Item_Key  => p_item_key);

    IF ln_transaction_id IS NULL

     THEN
 hr_utility.trace('In ( IF ln_transaction_id IS NULL)'|| l_proc);
      hr_transaction_ss.start_transaction
      ( itemtype                => p_item_type
       ,itemkey                 => p_item_key
       ,actid                   => p_act_id
       ,funmode                 => 'RUN'
       ,p_login_person_id       => p_login_person_id
       ,result                  => lv_result
       ,p_plan_id               => p_plan_id
       ,p_rptg_grp_id           => p_rptg_grp_id
       ,p_effective_date_option => p_effective_date_option );

       ln_transaction_id := hr_transaction_ss.get_transaction_id
                              (p_item_type => p_item_type
                               ,p_item_key => p_item_key);

    END IF;     -- now we have a valid txn id , let's find out txn steps

    hr_transaction_api.get_transaction_step_info
        (p_Item_Type     => p_item_type
        ,p_Item_Key      => p_item_key
        ,p_activity_id   => to_number(p_act_id)
        ,p_transaction_step_id => ltt_trans_step_ids
        ,p_object_version_number => ltt_trans_obj_vers_num
        ,p_rows                  => ln_trans_step_rows);

    IF ln_trans_step_rows < 1 THEN
  hr_utility.trace('In (if ln_trans_step_rows < 1)'|| l_proc);
       --There is no transaction step for this transaction.
       --Create a step within this new transaction

       hr_transaction_api.create_transaction_step(
        p_validate => false
  	   ,p_creator_person_id => p_login_person_id
	   ,p_transaction_id => ln_transaction_id
	   ,p_api_name => 'HR_SUPERVISOR_SS.PROCESS_API'
	   ,p_Item_Type => p_item_type
	   ,p_Item_Key => p_item_key
	   ,p_activity_id => p_act_id
	   ,p_transaction_step_id => ln_transaction_step_id
       ,p_object_version_number =>ln_ovn ) ;


    ELSE
         hr_utility.trace('In else of (If ln_trans_step_rows < 1)'|| l_proc);
	 --There are transaction steps for this transaction.
     --Get the Transaction Step ID for this activity.
      ln_transaction_step_id :=
       hr_transaction_ss.get_activity_trans_step_id(
           p_activity_name     => gv_activity_name
	  ,p_trans_step_id_tbl => ltt_trans_step_ids);

    END IF;

    -- write  activity name  to txn table
    hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>ln_transaction_step_id,
        p_person_id => p_login_person_id ,
        p_name => 'p_activity_name' ,
        p_value => gv_activity_name ) ;

    hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>ln_transaction_step_id,
        p_person_id => p_login_person_id ,
        p_name => 'P_REVIEW_PROC_CALL' ,
        p_value => p_review_proc_call ) ;

    hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>ln_transaction_step_id,
        p_person_id => p_login_person_id ,
        p_name => 'P_REVIEW_ACTID' ,
        p_value => p_act_id ) ;

    hr_transaction_api.set_number_value (
        p_transaction_step_id =>ln_transaction_step_id,
        p_person_id => p_login_person_id ,
        p_name => 'p_no_of_reports' ,
        p_value => p_no_of_direct_reports ) ;

    hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>ln_transaction_step_id,
        p_person_id => p_login_person_id ,
        p_name => 'p_selected_emp_name' ,
        p_value =>p_selected_emp_name ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>ln_transaction_step_id,
        p_person_id => p_login_person_id ,
        p_name => 'p_single_supervisor_name' ,
        p_value =>p_single_supervisor_name ) ;

     hr_transaction_api.set_date_value (
        p_transaction_step_id =>ln_transaction_step_id,
        p_person_id => p_login_person_id ,
        p_name => 'p_single_effective_date' ,
        p_value => p_single_effective_date ) ;

    hr_transaction_api.set_number_value (
        p_transaction_step_id =>ln_transaction_step_id,
        p_person_id => p_login_person_id ,
        p_name => 'p_no_of_emp' ,
        p_value => p_no_of_emps ) ;

      hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>ln_transaction_step_id,
        p_person_id => p_login_person_id ,
        p_name => 'p_term_flag' ,
        p_value => p_term_flag ) ;

   --this is the new thing which is added to
      hr_transaction_api.set_number_value (
        p_transaction_step_id =>ln_transaction_step_id,
        p_person_id => p_login_person_id ,
        p_name => 'p_selected_emp_id' ,
        p_value => p_selected_emp_id) ;



    p_transaction_id := ln_transaction_id ;
    p_transaction_step_id := ln_transaction_step_id ;
    hr_utility.set_location('Leaving'|| l_proc,25);

  EXCEPTION
   WHEN OTHERS THEN
hr_utility.set_location('EXCEPTION'|| l_proc,555);
     raise ;

  END create_transaction ;

/*
  ||===========================================================================
  || PROCEDURE:  update_supervisor
  || DESCRIPTION: This changes the per_all_assignments_f.supervisor_id attribute
  ||              to the value of the passed in parm p_supervisor_id.
  ||===========================================================================
  */

   PROCEDURE update_supervisor (
     p_effective_date DATE ,
     p_attribute_update_mode VARCHAR2,
     p_assignment_id          NUMBER,
     p_supervisor_id          NUMBER,
     --Assignment Security
     p_supervisor_assignment_id   NUMBER,

     p_validate               BOOLEAN )
   IS

   -- Bug 2130066 Fix Begins: 01/11/2002
   -- Changed from per_assignments_f to per_all_assignments_f.  This is
   -- necessary because when a Supervisor Security profile restrict to 1 level,
   -- we cannot get data for 2 levels down or beyond.  This will happen when
   -- the 1st level employee is terminated, we need to change all his direct
   -- reports to another employee.  In this case, the direct reports of the
   -- terminating employee will not be returned because the Supervisor Security
   -- profile is restricted to 1 level.
   CURSOR lc_object_version_no IS
   SELECT object_version_number,
          assignment_type
   FROM   per_all_assignments_f           -- Bug 2130066 fix
   WHERE assignment_id = p_assignment_id
   AND   (p_effective_date BETWEEN
            NVL ( effective_start_date , p_effective_date)
            AND NVL ( effective_end_date , p_effective_date )) ;

   ln_object_version_no     NUMBER ;
   ln_assignment_type       per_all_assignments_f.assignment_type%type;
   ln_comment_id            NUMBER ;
   ld_effective_start_date  DATE;
   ld_effective_end_date    DATE;
   lb_no_managers_warning  BOOLEAN ;
   lb_other_manager_warning BOOLEAN ;
   lv_message_number        VARCHAR2(80);

   -- Assignment Security
   l_supervisor_assignment_id      number ;
   l_assignment_security_profile varchar(30) := hr_general2.supervisor_assignments_in_use ;
   l_proc constant varchar2(100) := g_package || ' update_supervisor';
   BEGIN
 hr_utility.set_location('Entering'|| l_proc,5);
     OPEN lc_object_version_no ;
     FETCH lc_object_version_no into ln_object_version_no, ln_assignment_type ;
     CLOSE lc_object_version_no ;

/*
    hr_java_script_web.alert ( 'asg id  ' || p_assignment_id ) ;
    hr_java_script_web.alert ( 'ovn is ' || ln_object_version_no ) ;
*/

        -- Assignment Security
        IF(l_assignment_security_profile <> 'TRUE') then
          l_supervisor_assignment_id := hr_api.g_number;
        ELSE
          l_supervisor_assignment_id
                          := p_supervisor_assignment_id;
        END IF;
        -- End of Assignment Security code



    -- call api here
    hr_assignment_att.update_asg(
      p_validate=>p_validate,
      p_effective_date=>p_effective_date  ,
      p_attribute_update_mode=>p_attribute_update_mode ,
      p_assignment_id=>p_assignment_id ,
      p_assignment_type => ln_assignment_type,
      p_object_version_number =>ln_object_version_no ,
      p_supervisor_id => p_supervisor_id ,
      -- Assignment Security
      p_supervisor_assignment_id => l_supervisor_assignment_id ,

      p_comment_id => ln_comment_id ,
      p_effective_start_date=>ld_effective_start_date,
      p_effective_end_date=>ld_effective_end_date,
      p_no_managers_warning=>lb_no_managers_warning,
      p_other_manager_warning=>lb_other_manager_warning ) ;
   hr_utility.set_location('Leaving'|| l_proc,10);

   EXCEPTION
   /*WHEN hr_utility.hr_error THEN
     hr_message.provide_error;
       lv_message_number := hr_message.last_message_number;
       hr_errors_api.addErrorToTable(
         p_errormsg => hr_message.get_message_text,
         p_errorcode => lv_message_number
         );*/

     WHEN OTHERS THEN
        hr_utility.set_location('EXCEPTION'|| l_proc,555);
	raise ;

   END update_supervisor ;


/*
  ||===========================================================================
  || PROCEDURE:  validate_api
  || DESCRIPTION:
  ||
  ||===========================================================================
  */

  PROCEDURE validate_api (
     p_selected_emp_id  NUMBER ,
     p_selected_person_sup_id  NUMBER ,
     p_selected_person_old_sup_id  NUMBER ,

     -- Assignment Security
     p_selected_person_sup_asg_id  NUMBER ,
     p_sel_person_old_sup_asg_id  NUMBER ,

     p_passed_effective_date DATE ,
     p_passed_assignment_id NUMBER ,
     p_direct_reports       ltt_direct_reports ,
     p_validate             BOOLEAN ,
     p_from_term            BOOLEAN DEFAULT FALSE ,
     p_emp_asg_id           hr_util_misc_web.g_varchar2_tab_type,
     p_emp_effective_date   hr_util_misc_web.g_varchar2_tab_type,
     -- Assignment Security
     p_emp_sup_asg_id           hr_util_misc_web.g_varchar2_tab_type,

     p_term_flag        VARCHAR2)

   IS
     lv_message_number   VARCHAR2(80);
     ln_count number ;
     l_proc constant varchar2(100) := g_package || 'validate_api';


   BEGIN
   hr_utility.set_location('Entering'|| l_proc,5);
   SAVEPOINT update_supervisor ;
   -- if not invoked from termination , update the
   -- selected employee's supervisor
   -- we need to check here if the supervisor is changed and
   -- then only do the update






   -- remove the comments and the update_supervisor
   -- RAJ just to test IF p_from_term = FALSE TO p_term_flag="N"
   IF p_term_flag = 'N'
       THEN
       hr_utility.trace('In (if p_term_flag = N)'|| l_proc);
     IF (
        ( p_selected_person_sup_id IS NOT NULL AND
          p_selected_person_old_sup_id IS NULL ) OR
        ( p_selected_person_sup_id IS NULL AND
          p_selected_person_old_sup_id IS NOT NULL) OR
        (p_selected_person_sup_id <> p_selected_person_old_sup_id) OR
        ( hr_general2.supervisor_assignments_in_use = 'TRUE'
          AND (p_selected_person_sup_asg_id is not NULL and
                  p_sel_person_old_sup_asg_id is NULL)
         ) OR
        ( hr_general2.supervisor_assignments_in_use = 'TRUE'
          AND (p_selected_person_sup_asg_id is NULL and
                  p_sel_person_old_sup_asg_id is not NULL)
        ) OR
        ( hr_general2.supervisor_assignments_in_use = 'TRUE'
          AND p_selected_person_sup_asg_id <> p_sel_person_old_sup_asg_id)
        )
     THEN


       update_supervisor(
         p_passed_effective_date ,
         'ATTRIBUTE_UPDATE' ,
         p_passed_assignment_id ,
         p_selected_person_sup_id,
         -- Assignment Security
         p_selected_person_sup_asg_id,

         p_validate) ;
     END IF ;


   END IF ;




   -- if direct reports exists , update their supervisor
   -- update direct reports' supervisor

       ln_count := p_direct_reports.count ;




   FOR i in 1..p_direct_reports.count
   LOOP
     -- check if supervisor is changed for this direct report
     -- if so update the supervisor

     IF ((p_direct_reports(i).supervisor_id <> p_selected_emp_id) or
         (p_direct_reports(i).supervisor_id is Null) or
         (hr_general2.supervisor_assignments_in_use = 'TRUE' AND
            p_direct_reports(i).supervisor_assignment_id <>
                                                   p_passed_assignment_id)
        or (hr_general2.supervisor_assignments_in_use = 'TRUE' AND
            p_direct_reports(i).supervisor_assignment_id is NULL)
       )
     THEN
       update_supervisor(
         p_direct_reports(i).effective_date ,
         'ATTRIBUTE_UPDATE' ,
         p_direct_reports(i).assignment_id ,
         p_direct_reports(i).supervisor_id ,
         -- Assignment Security
         p_direct_reports(i).supervisor_assignment_id ,

         p_validate);

     END IF ;


   END LOOP ;
   --comented out this part fort testing the Direct Reports  Raj

   -- add new direct reports
   FOR i in 1..p_emp_asg_id.count
   LOOP
     update_supervisor(
       p_emp_effective_date(i) ,
       'ATTRIBUTE_UPDATE' ,
        p_emp_asg_id(i) ,
        p_selected_emp_id,

        p_emp_sup_asg_id(i) ,

        p_validate);

   END LOOP ;
   IF p_validate
   THEN
     ROLLBACK to update_supervisor ;
   END IF ;
        hr_utility.set_location('Leaving'|| l_proc,15);
   EXCEPTION
   -- add api error
   /*WHEN hr_utility.hr_error THEN
     hr_message.provide_error;
     lv_message_number := hr_message.last_message_number;
     hr_errors_api.addErrorToTable(
         p_errormsg => hr_message.get_message_text,
         p_errorcode => lv_message_number
         );*/

   WHEN OTHERS THEN
hr_utility.set_location('EXCEPTION'|| l_proc,555);
     raise ;

   END validate_api;

/*
  ||===========================================================================
  || PROCEDURE: validate_emp_assignments
  || DESCRIPTION:
  ||
  ||===========================================================================
  */

   PROCEDURE validate_emp_assignments (
     p_emp_id     hr_util_misc_web.g_varchar2_tab_type DEFAULT
                       hr_util_misc_web.g_varchar2_tab_default  ,
     p_emp_asg_id IN OUT NOCOPY hr_util_misc_web.g_varchar2_tab_type ,
     p_emp_effective_date  hr_util_misc_web.g_varchar2_tab_type DEFAULT
                       hr_util_misc_web.g_varchar2_tab_default,
     p_error_flag IN OUT NOCOPY BOOLEAN )

   IS

     -- Bug 2130066 Fix Begins: 01/11/2002
     -- Changed from per_assignments_f to per_all_assignments_f.  This is
     -- necessary because when a Supervisor Security profile restrict to 1 level
     -- ,we cannot get data for 2 levels down or beyond.  This will happen when
     -- the 1st level employee is terminated, we need to change all his direct
     -- reports to another employee.  In this case, the direct reports of the
     -- terminating employee will not be returned because the Supervisor
     -- Security profile is restricted to 1 level.
     --
     cursor lc_assignment_id ( p_person_id NUMBER, p_effective_date date)  is
     SELECT distinct paf.assignment_id
     FROM   per_all_assignments_f paf,     -- Bug 2130066 fix
            per_all_people_f ppf
     WHERE  ppf.person_id = p_person_id
     AND    p_effective_date BETWEEN
            ppf.effective_start_date AND ppf.effective_end_date
     AND    paf.person_id = ppf.person_id
     AND    paf.primary_flag = 'Y'
     AND    p_effective_date BETWEEN
            paf.effective_start_date AND paf.effective_end_date
     AND    ((paf.assignment_type = 'E' and ppf.current_employee_flag = 'Y')
          OR (paf.assignment_type = 'C' and ppf.current_npw_flag = 'Y'));

     ln_assignment_id NUMBER ;
     l_proc constant varchar2(100) := g_package || 'validate_emp_assignments';

   BEGIN
   hr_utility.set_location('Entering'|| l_proc,5);
     p_error_flag := FALSE ;

     FOR i in 1..p_emp_id.count
     LOOP



       open lc_assignment_id ( p_emp_id(i), p_emp_effective_date(i));
       FETCH lc_assignment_id INTO ln_assignment_id ;

       IF lc_assignment_id%NOTFOUND THEN

         p_error_flag := TRUE ;
       END IF ;

       p_emp_asg_id(i):= ln_assignment_id ;



       close lc_assignment_id ;

     END LOOP ;
hr_utility.set_location('Leaving'|| l_proc,10);

   EXCEPTION
   WHEN OTHERS THEN

hr_utility.set_location('EXCEPTION'|| l_proc,555);
     raise ;


   END ;


/*
  ||===========================================================================
  || PROCEDURE: get_txn_details
  || DESCRIPTION:
  ||
  ||===========================================================================
  */

  PROCEDURE get_txn_details (
     p_item_type       IN wf_items.item_type%type ,
     p_item_key        IN wf_items.item_key%TYPE ,
     p_act_id          IN NUMBER,
     p_selected_emp_id IN OUT NOCOPY NUMBER ,
     p_passed_assignment_id IN OUT NOCOPY NUMBER ,
     p_sup_id          OUT NOCOPY NUMBER,
     p_old_sup_id      OUT NOCOPY NUMBER ,
-- Assignment Security
     p_sup_asg_id          OUT NOCOPY NUMBER,
     p_old_sup_asg_id      OUT NOCOPY NUMBER ,

     p_sup_name        OUT NOCOPY VARCHAR2 ,
     p_old_sup_name    OUT NOCOPY VARCHAR2,
     p_passed_effective_date OUT NOCOPY DATE ,
     p_direct_reports   IN OUT NOCOPY ltt_direct_reports,
     p_emp_name           IN OUT NOCOPY  hr_util_misc_web.g_varchar2_tab_type,
     p_emp_id           IN OUT NOCOPY  hr_util_misc_web.g_varchar2_tab_type,
     p_emp_asg_id       IN OUT NOCOPY  hr_util_misc_web.g_varchar2_tab_type,
     p_emp_date           IN OUT NOCOPY  hr_util_misc_web.g_varchar2_tab_type ,
     p_emp_sup_asg_id       IN OUT NOCOPY  hr_util_misc_web.g_varchar2_tab_type,
     p_single_supervisor_name IN OUT NOCOPY VARCHAR2,
     p_single_effective_date  IN OUT NOCOPY DATE,
     p_term_flag              IN OUT NOCOPY VARCHAR2)

   IS

    ln_transaction_step_id NUMBER;
    ln_transaction_id      hr_api_transactions.transaction_id%TYPE;
    ltt_trans_step_ids     hr_util_web.g_varchar2_tab_type;
    ltt_trans_obj_vers_num hr_util_web.g_varchar2_tab_type;
    ln_trans_step_rows     NUMBER  ;
    lv_activity_name       wf_item_activity_statuses_v.activity_name%type ;
    ln_no_of_reports       NUMBER ;
    ln_selected_person_id  NUMBER ;
    ln_selected_emp_id       NUMBER ;
    ln_passed_assignment_id  NUMBER ;
    lv_selected_emp_name     VARCHAR2(250);
    ln_no_of_emp             NUMBER ;
    lv_selected_emp        BOOLEAN;
    lv_direct_reports      BOOLEAN;
    lv_new_reports         BOOLEAN;
    l_proc constant varchar2(100) := g_package || 'get_txn_details';
--    ld_passed_effective_date DATE ;

   BEGIN
     hr_utility.set_location('Entering'|| l_proc,5);
     ln_transaction_id := hr_transaction_ss.get_transaction_id
                             (p_Item_Type   => p_item_type,
                              p_Item_Key    => p_item_key);


      IF ln_transaction_id IS NOT NULL
      THEN
      hr_utility.trace('In if ln_transaction_id IS NOT NULL '|| l_proc);
        hr_transaction_api.get_transaction_step_info
                   (p_Item_Type   => p_item_type,
                    p_Item_Key    => p_item_key,
                    p_activity_id =>p_act_id,
                    p_transaction_step_id => ltt_trans_step_ids,
                    p_object_version_number => ltt_trans_obj_vers_num,
                    p_rows                  => ln_trans_step_rows);


        -- if no transaction steps are found , return
        IF ln_trans_step_rows < 1
         THEN
       hr_utility.set_location('Leaving'|| l_proc,15);
          RETURN ;

        ELSE

          ln_transaction_step_id  :=
          hr_transaction_ss.get_activity_trans_step_id
          (p_activity_name     =>  gv_activity_name
          ,p_trans_step_id_tbl => ltt_trans_step_ids);

     -- now get the which region is changed
     -- catch the exception as one or more regions may be changed
        BEGIN
          lv_selected_emp :=
          hr_transaction_api.get_boolean_value
          (p_transaction_step_id => ln_transaction_step_id,
          p_name =>'p_selected_emp');
        EXCEPTION
	  WHEN OTHERS THEN
	  hr_utility.set_location('EXCEPTION'|| l_proc,555);
	    lv_selected_emp := false;
	END;

        BEGIN
         lv_direct_reports :=
          hr_transaction_api.get_boolean_value
          (p_transaction_step_id => ln_transaction_step_id,
          p_name =>'p_direct_reports');
        EXCEPTION
          WHEN OTHERS THEN
          hr_utility.set_location('EXCEPTION'|| l_proc,560);
            lv_direct_reports := false;
        END;

        BEGIN
         lv_new_reports :=
          hr_transaction_api.get_boolean_value
          (p_transaction_step_id => ln_transaction_step_id,
          p_name =>'p_new_reports');
        EXCEPTION
          WHEN OTHERS THEN
          hr_utility.set_location('EXCEPTION'|| l_proc,565);
            lv_new_reports := false;
        END;

          -- now get the individual txn  data

          p_term_flag :=
          hr_transaction_api.get_varchar2_value
          (p_transaction_step_id => ln_transaction_step_id,
          p_name =>'p_term_flag');


          p_selected_emp_id :=
          hr_transaction_api.get_number_value
                           (p_transaction_step_id => ln_transaction_step_id,
                            p_name =>'p_selected_emp_id');
          ln_no_of_emp :=
          hr_transaction_api.get_number_value
                           (p_transaction_step_id => ln_transaction_step_id,
                            p_name =>'p_no_of_emp');

          p_single_supervisor_name :=
          hr_transaction_api.get_VARCHAR2_value
                           (p_transaction_step_id => ln_transaction_step_id,
                            p_name =>'p_single_supervisor_name');

          p_single_effective_date :=
          hr_transaction_api.get_date_value
                           (p_transaction_step_id => ln_transaction_step_id,
                           p_name =>'p_single_effective_date');

         if p_term_flag='N'  Then
         hr_utility.trace('In (if  p_term_flag=N) '|| l_proc);
          if  lv_selected_emp then
             hr_utility.trace('In (if lv_selected_emp) '|| l_proc);
           p_passed_assignment_id :=
           hr_transaction_api.get_number_value
                           (p_transaction_step_id => ln_transaction_step_id,
                            p_name =>'p_passed_assignment_id');

           p_sup_id :=
           hr_transaction_api.get_number_value
                           (p_transaction_step_id => ln_transaction_step_id,
                            p_name =>'p_selected_person_sup_id');


           p_old_sup_id :=
           hr_transaction_api.get_number_value
                           (p_transaction_step_id => ln_transaction_step_id,
                            p_name =>'p_selected_person_old_sup_id');

           -- Assignment Security
           p_sup_asg_id :=
           hr_transaction_api.get_number_value
                           (p_transaction_step_id => ln_transaction_step_id,
                            p_name =>'p_selected_person_sup_asg_id');


           p_old_sup_asg_id :=
           hr_transaction_api.get_number_value
                           (p_transaction_step_id => ln_transaction_step_id,
                            p_name =>'p_sel_person_old_sup_asg_id');


           lv_selected_emp_name :=
           hr_transaction_api.get_varchar2_value
                           (p_transaction_step_id => ln_transaction_step_id,
                            p_name =>'p_selected_emp_name');

           p_sup_name :=
           hr_transaction_api.get_varchar2_value
                           (p_transaction_step_id => ln_transaction_step_id,
                            p_name =>'p_selected_person_sup_name');


           p_old_sup_name :=
           hr_transaction_api.get_varchar2_value
                           (p_transaction_step_id => ln_transaction_step_id,
                            p_name =>'p_selected_person_old_sup_name');

           p_passed_effective_date :=
           hr_transaction_api.get_date_value
                           (p_transaction_step_id => ln_transaction_step_id,
                            p_name =>'p_passed_effective_date');
          end if; -- end selected emp

         IF lv_new_reports THEN
          hr_utility.trace('In (if lv_new_reports) '|| l_proc);

          FOR i in 1 ..ln_no_of_emp
          LOOP

             p_emp_name(i) :=
            hr_transaction_api.get_varchar2_value
                           (p_transaction_step_id => ln_transaction_step_id,
                            p_name =>'p_emp_name'||i);

            p_emp_id(i) :=
            hr_transaction_api.get_number_value
                           (p_transaction_step_id => ln_transaction_step_id,
                            p_name =>'p_emp_id'||i);

            p_emp_asg_id(i) :=
            hr_transaction_api.get_number_value
                           (p_transaction_step_id => ln_transaction_step_id,
                            p_name =>'p_emp_asg_id'||i);

            p_emp_date(i):=
            hr_transaction_api.get_date_value
                           (p_transaction_step_id => ln_transaction_step_id,
                            p_name =>'p_emp_date'||i);

            p_emp_sup_asg_id(i):=
            hr_transaction_api.get_number_value
                           (p_transaction_step_id => ln_transaction_step_id,
                            p_name =>'p_emp_sup_asg_id'||i);


          END LOOP ;
         END IF; -- end new emp
        end If; -- end termination flag

       ln_no_of_reports :=
       hr_transaction_api.get_number_value
                           (p_transaction_step_id => ln_transaction_step_id,
                            p_name =>'p_no_of_reports');

       IF lv_direct_reports THEN
       hr_utility.trace('In (if lv_direct_reports) '|| l_proc);
          -- now get all the direct reports info
          FOR i in 1..ln_no_of_reports
          LOOP

            p_direct_reports(i).full_name :=
            hr_transaction_api.get_varchar2_value
                           (p_transaction_step_id => ln_transaction_step_id,
                            p_name =>'p_full_name'||i);

            p_direct_reports(i).supervisor_id :=
            hr_transaction_api.get_number_value
                           (p_transaction_step_id => ln_transaction_step_id,
                            p_name =>'p_supervisor_id'||i);

            -- Assignment Security
            p_direct_reports(i).supervisor_assignment_id :=
            hr_transaction_api.get_number_value
                           (p_transaction_step_id => ln_transaction_step_id,
                            p_name =>'p_supervisor_assignment_id'||i);


            p_direct_reports(i).supervisor_name :=
            hr_transaction_api.get_varchar2_value
                           (p_transaction_step_id => ln_transaction_step_id,
                            p_name =>'p_supervisor_name'||i);



            p_direct_reports(i).effective_date:=
            hr_transaction_api.get_date_value
                           (p_transaction_step_id => ln_transaction_step_id,
                            p_name =>'p_effective_date'||i);

           p_direct_reports(i).assignment_id:=
            hr_transaction_api.get_number_value
                           (p_transaction_step_id => ln_transaction_step_id,
                            p_name =>'p_assignment_id'||i);

          END LOOP ;
        END IF;
       END IF; -- end Direct reports
     END IF ;
         hr_utility.set_location('Leaving'|| l_proc,40);
   EXCEPTION
   WHEN OTHERS THEN
   hr_utility.set_location('EXCEPTION'|| l_proc,570);
    raise ;

   END ;


/*
  ||===========================================================================
  || PROCEDURE: process_api
  || DESCRIPTION:
  ||
  ||===========================================================================
  */

   PROCEDURE process_api (
     p_transaction_step_id IN
     hr_api_transaction_steps.transaction_step_id%type,
     p_validate BOOLEAN default FALSE,
     p_effective_date IN varchar2 default null) IS

     lv_item_type     VARCHAR2(100);
     lv_item_key      VARCHAR2(100);
     ln_act_id        NUMBER ;
     ln_sup_id               NUMBER ;
     ln_old_sup_id           NUMBER ;
     -- Assignment Security
     ln_sup_asg_id               NUMBER ;
     ln_old_sup_asg_id           NUMBER ;

     lv_sup_name             VARCHAR2(250);
     lv_old_sup_name         VARCHAR2(250);
     ld_passed_effective_date DATE ;
     ltt_reports             ltt_direct_reports;
     ltt_emp_name            hr_util_misc_web.g_varchar2_tab_type ;
     ltt_emp_id              hr_util_misc_web.g_varchar2_tab_type ;
     ltt_emp_asg_id          hr_util_misc_web.g_varchar2_tab_type ;
     ltt_emp_date            hr_util_misc_web.g_varchar2_tab_type ;
     -- Assignment Security
     ltt_emp_sup_asg_id      hr_util_misc_web.g_varchar2_tab_type ;

     ltt_reports_supervisor_id  hr_util_misc_web.g_varchar2_tab_type;
     ltt_reports_supervisor_name hr_util_misc_web.g_varchar2_tab_type ;
     ltt_reports_effective_date hr_util_misc_web.g_varchar2_tab_type ;
     lv_result_code            VARCHAR2(250);
     lv_single_supervisor_name VARCHAR2(250);
     ld_single_effective_date  DATE ;
     ln_selected_emp_id        NUMBER ;
     ln_passed_assignment_id   NUMBER ;
     lb_emp_asg_flag           BOOLEAN ;
     ld_term_flag           varchar2(1) ;

     -- For SAVE_FOR_LATER
    ld_effective_date             date default null;
    l_proc constant varchar2(100) := g_package || 'process_api';
   BEGIN

 hr_utility.set_location('Entering'|| l_proc,5);
     hr_transaction_api.get_transaction_step_info(
        p_transaction_step_id => p_transaction_step_id
       ,p_item_type => lv_item_type
       ,p_item_key => lv_item_key
       ,p_activity_id => ln_act_id);


    -- get supervisor data from txn tables
    get_txn_details (
      p_item_type=>lv_item_type,
      p_item_key=>lv_item_key,
      p_act_id=>ln_act_id,
      p_selected_emp_id=>ln_selected_emp_id ,
      p_passed_assignment_id=>ln_passed_assignment_id,
      p_sup_id=>ln_sup_id ,
      p_old_sup_id=>ln_old_sup_id ,

      -- Assignment Security
      p_sup_asg_id=>ln_sup_asg_id ,
      p_old_sup_asg_id=>ln_old_sup_asg_id ,


      p_sup_name=>lv_sup_name ,
      p_old_sup_name=>lv_old_sup_name ,
      p_passed_effective_date=>ld_passed_effective_date,
      p_direct_reports=>ltt_reports,
      p_emp_name=>ltt_emp_name ,
      p_emp_id=>ltt_emp_id ,
      p_emp_asg_id=>ltt_emp_asg_id ,
      p_emp_date=>ltt_emp_date ,
      -- Assignment Security
      p_emp_sup_asg_id =>ltt_emp_sup_asg_id ,
      p_single_supervisor_name=>lv_single_supervisor_name,
      p_single_effective_date=>ld_single_effective_date,
      p_term_flag=>ld_term_flag) ;

    -- SAVE_FOR_LATER Changes Begin:
    -- The following is for SAVE_FOR_LATER code change.
    -- 1)When the Action page re-launch a suspended workflow process, it does
    --   a validation by calling the process_api with the new user entered
    --   effective date.  Added a new parameter p_effective_date to this proc.
    --   If p_effective_date is not null, then use it as the effective date for
    --   api validation.
    -- 2)When the Action page re-launch a suspended workflow process, it
    --   allows user to enter a new effective date. We should not use the
    --   effective date that we saved in the transaction table.
    --   In process_api, if the p_effective_date parameter is null then use
    --   the workflow attribute P_EFFECTIVE_DATE as the effective date for api
    --   validation.
    --
    IF (p_effective_date is not null) THEN
       ld_effective_date:= to_date(p_effective_date, gv_date_format);
    ELSE
       ld_effective_date:= to_date(
       hr_transaction_ss.get_wf_effective_date
          (p_transaction_step_id => p_transaction_step_id), gv_date_format);
    END IF;

    -- SAVE_FOR_LATER Changes End

-- start newhire
-- If its a new hire flow than the assignmentId which is coming from transaction table
-- will not be valid because the person has just been created by the process_api of the
-- hr_process_person_ss.process_api we can get that person Id and assignment id by making a call
-- to the global parameters but we need to branch out the code.
-- We also need the latest Object version Number not the one on transaction tables

-- adding the session id check to avoid connection pooling problems.
--  if (hr_process_person_ss.g_assignment_id is not null) then
  if (( hr_process_person_ss.g_assignment_id is not null) and
     (hr_process_person_ss.g_session_id= ICX_SEC.G_SESSION_ID)) then
    ln_selected_emp_id := hr_process_person_ss.g_person_id;
    ln_passed_assignment_id := hr_process_person_ss.g_assignment_id;
 end if;

-- end newhire

/*
    if  ld_term_flag='N' then

    validate_emp_assignments (
       p_emp_id=>ltt_emp_id ,
       p_emp_asg_id =>ltt_emp_asg_id,
       p_emp_effective_date => ltt_emp_date,
       p_error_flag =>lb_emp_asg_flag ) ;

    end if;
*/

    -- call  api here
    validate_api(
      p_selected_emp_id=>ln_selected_emp_id ,
      p_selected_person_sup_id=>ln_sup_id,
      p_selected_person_old_sup_id=>ln_old_sup_id ,
      -- Assignment Security
      p_selected_person_sup_asg_id=>ln_sup_asg_id,
      p_sel_person_old_sup_asg_id=>ln_old_sup_asg_id ,


      p_passed_effective_date=>ld_passed_effective_date ,
      p_passed_assignment_id=>ln_passed_assignment_id,
      p_direct_reports=>ltt_reports,
      p_validate=>p_validate ,
      p_emp_asg_id=>ltt_emp_asg_id ,
      p_emp_effective_date=>ltt_emp_date,
      -- Assignment Security
      p_emp_sup_asg_id=>ltt_emp_sup_asg_id ,

      p_term_flag=>ld_term_flag )  ;


--  end if;

hr_utility.set_location('Leaving'|| l_proc,10);

  EXCEPTION
   WHEN OTHERS THEN
   hr_utility.set_location('EXCEPTION'|| l_proc,555);
     raise ;

   END PROCESS_API;

/*
  ||===========================================================================
  || PROCEDURE: write_transaction
  || DESCRIPTION:
  ||
  ||===========================================================================
  */

  PROCEDURE write_transaction (
    p_old_sup_id      NUMBER  default NULL,
    p_old_sup_asg_id  NUMBER  default NULL,
    p_new_sup_id      NUMBER  default NULL,
    p_new_sup_asg_id  NUMBER  default NULL,
    p_old_sup_name    per_people_f.full_name%type default NULL,
    p_new_sup_name    per_people_f.full_name%type,
    p_emp_name        per_people_f.full_name%type,
    p_emp_id          per_people_f.person_id%type default NULL,
    p_effective_date  Date ,
    p_assignment_id   NUMBER ,
    p_section_code    IN VARCHAR2,
    p_row_num         NUMBER DEFAULT 0,
    p_transaction_step_id  NUMBER,
    p_login_person_id     IN  NUMBER) IS
    l_proc constant varchar2(100) := g_package || ' write_transaction';

  BEGIN

   hr_utility.set_location('Entering'|| l_proc,5);

    -- write data for selected employee
    IF p_section_code = 'NEW_MANAGER'
    THEN

hr_utility.trace('In (IF p_section_code = NEW_MANAGER)'|| l_proc);

 -- Store the p_selected_emp to be used in process_Api
    hr_transaction_api.set_boolean_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => p_login_person_id ,
        p_name => 'p_selected_emp' ,
        p_value => TRUE ) ;

      -- we are in the top region for the supervisor page
      -- write selected person's employee id


      hr_transaction_api.set_number_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => p_login_person_id ,
        p_name => 'p_selected_emp_id' ,
        p_value =>p_emp_id ) ;


     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => p_login_person_id ,
        p_name => 'p_selected_emp_name' ,
        p_value =>p_emp_name ) ;


      hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => p_login_person_id ,
        p_name => 'p_selected_person_sup_name' ,
        p_value =>p_new_sup_name ) ;

      hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => p_login_person_id ,
        p_name => 'p_selected_person_old_sup_name' ,
        p_value =>p_old_sup_name ) ;


      hr_transaction_api.set_number_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => p_login_person_id ,
        p_name => 'p_selected_person_old_sup_id' ,
        p_value =>p_old_sup_id ) ;


        -- Assignment Security
        hr_transaction_api.set_number_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => p_login_person_id ,
        p_name => 'p_sel_person_old_sup_asg_id' ,
        p_value => p_old_sup_asg_id ) ;


       hr_transaction_api.set_number_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => p_login_person_id ,
        p_name => 'p_selected_person_sup_id' ,
        p_value =>p_new_sup_id ) ;



        -- Assignment Security
       hr_transaction_api.set_number_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => p_login_person_id ,
        p_name => 'p_selected_person_sup_asg_id' ,
        p_value =>p_new_sup_asg_id ) ;


      hr_transaction_api.set_date_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => p_login_person_id ,
        p_name => 'p_passed_effective_date' ,
        p_value =>p_effective_date) ;

     hr_transaction_api.set_number_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => p_login_person_id ,
        p_name => 'p_passed_assignment_id' ,
        p_value =>p_assignment_id ) ;


    END IF ;


    -- write transaction data for direct reports section
    IF p_section_code = 'DIR_REPORTS'
    THEN
hr_utility.trace('In (IF p_section_code = DIR_REPORTS)'|| l_proc);
 -- Store the p_selected_emp to be used in process_Api
    hr_transaction_api.set_boolean_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => p_login_person_id ,
        p_name => 'p_direct_reports' ,
        p_value => TRUE ) ;

      -- write the name of the direct report

      hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => p_login_person_id ,
        p_name => 'p_full_name'||p_row_num ,
        p_value =>p_emp_name ) ;


      -- Write the person id of the direct reports
      -- This is done as a part of Global Name format changes
      -- Bug 5130368 also raises this issue.
      hr_transaction_api.set_number_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => p_login_person_id ,
        p_name => 'p_dir_rep_emp_id'||p_row_num ,
        p_value =>p_emp_id ) ;


      -- write the assignment  id of the direct report
      hr_transaction_api.set_number_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => p_login_person_id ,
        p_name => 'p_assignment_id'||p_row_num ,
        p_value =>p_assignment_id ) ;

     -- write the new supervisor id and new supervisor name
     -- we do not write the old supervisor details as that has
     -- been written already as selected person's detail

      hr_transaction_api.set_number_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => p_login_person_id ,
        p_name => 'p_supervisor_id'||p_row_num ,
        p_value =>p_new_sup_id ) ;

      -- Assignment Security
      hr_transaction_api.set_number_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => p_login_person_id ,
        p_name => 'p_supervisor_assignment_id'||p_row_num ,
        p_value =>p_new_sup_asg_id ) ;


      hr_transaction_api.set_number_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => p_login_person_id ,
        p_name => 'p_old_supervisor_asg_id'||p_row_num ,
        p_value =>p_old_sup_asg_id ) ;


      hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => p_login_person_id ,
        p_name => 'p_supervisor_name'||p_row_num ,
        p_value =>p_new_sup_name ) ;

      hr_transaction_api.set_date_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => p_login_person_id ,
        p_name => 'p_effective_date'||p_row_num ,
        p_value =>p_effective_date ) ;


    END IF ;


    -- write data  for new direct reports
    IF p_section_code = 'NEW_REPORTS'
    THEN
    hr_utility.trace('In (IF p_section_code = NEW_REPORTS)'|| l_proc);
 -- Store the p_selected_emp to be used in process_Api
    hr_transaction_api.set_boolean_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => p_login_person_id ,
        p_name => 'p_new_reports' ,
        p_value => TRUE ) ;

      hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => p_login_person_id ,
        p_name => 'p_emp_name'||p_row_num ,
        p_value =>p_emp_name ) ;

      hr_transaction_api.set_number_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => p_login_person_id ,
        p_name => 'p_emp_id'||p_row_num ,
        p_value =>p_emp_id  ) ;

      hr_transaction_api.set_date_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => p_login_person_id ,
        p_name => 'p_emp_date'||p_row_num ,
        p_value =>p_effective_date  ) ;

      -- write the assignment  id of the new direct report
      hr_transaction_api.set_number_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => p_login_person_id ,
        p_name => 'p_emp_asg_id'||p_row_num ,
        p_value =>p_assignment_id ) ;

      -- write the supervisor assignment id of the new direct report
      hr_transaction_api.set_number_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => p_login_person_id ,
        p_name => 'p_emp_sup_asg_id'||p_row_num ,
        p_value =>p_new_sup_asg_id ) ;


    END IF ;
   hr_utility.set_location('Leaving'|| l_proc,25);
  EXCEPTION
  WHEN OTHERS THEN
  hr_utility.trace(' HR_SUPERVISOR_SS.write_transaction: ' || SQLERRM );
  hr_utility.set_location('EXCEPTION'|| l_proc,555);
    raise ;

  END WRITE_TRANSACTION ;

/*
  ||===========================================================================
  || PROCEDURE: update_asg
  || DESCRIPTION:
  ||
  ||===========================================================================
  */
  PROCEDURE update_asg
  (p_validate                     in     number default 0
  ,p_attribute_update_mode        in     varchar2
  ,p_manager_details_tab          in out nocopy SSHR_MANAGER_DETAILS_TAB_TYP
  ,p_item_type                    in     varchar2 default null
  ,p_item_key                     in     varchar2 default null
  ,p_actid                        in     varchar2 default null
  ,p_rptg_grp_id                  in     varchar2 default null
  ,p_plan_id                      in     varchar2 default null
  ,p_effective_date_option	  in     varchar2 default null
  ,p_num_of_direct_reports        in     number default 0
  ,p_num_of_new_direct_reports    in     number default 0
  ,p_selected_person_id           in     number
  ,p_selected_person_name         in     varchar2
  ,p_term_sup_flag                in     varchar2
  ,p_login_person_id              in     number
  ,p_save_for_later               in     varchar2 default 'SAVE'
  ,p_transaction_step_id          in out nocopy number
  )
  IS

  l_transaction_id      number ;
  l_transaction_step_id number ;
  l_error_found boolean := false;
  -- Assignment Security
  l_supervisor_assignment_id      number ;
  l_old_supervisor_assignment_id      number ;

  l_assignment_security_profile varchar(30) := hr_general2.supervisor_assignments_in_use ;
  l_proc constant varchar2(100) := g_package || 'update_asg';

  BEGIN
hr_utility.set_location('Entering'|| l_proc,5);
    -- first call update_asg if not save for later
    IF (p_save_for_later = 'SAVE') THEN
    hr_utility.trace('IN (if p_save_for_later = SAVE)'|| l_proc);
      FOR I IN 1 ..p_manager_details_tab.count LOOP
        -- Assignment Security
        IF(l_assignment_security_profile <> 'TRUE') then
          l_supervisor_assignment_id := hr_api.g_number;
        ELSE
          l_supervisor_assignment_id
                          := p_manager_details_tab(I).supervisor_assignment_id;
        END IF;
        -- End of Assignment Security code
        update_asg(p_validate => p_validate,
                   p_attribute_update_mode => p_attribute_update_mode,
                   p_item_type => p_item_type,
    		   p_item_key => p_item_key,
  		   p_actid => p_actid,
		   p_assignment_id => p_manager_details_tab(I).assignment_id,
		   p_object_version_number => p_manager_details_tab(I).object_ver_number,
		   p_supervisor_id => p_manager_details_tab(I).supervisor_id,
		   p_supervisor_assignment_id => l_supervisor_assignment_id,
		   p_effective_date => p_manager_details_tab(I).effective_date,
		   p_comment_id => p_manager_details_tab(I).comment_id,
		   p_effective_start_date => p_manager_details_tab(I).effective_start_date,
                   p_effective_end_date => p_manager_details_tab(I).effective_end_date,
                   p_no_managers_warning => p_manager_details_tab(I).no_managers_warning,
		   p_other_manager_warning => p_manager_details_tab(I).other_manager_warning,
		   p_error_message_appl => p_manager_details_tab(I).error_message_appl,
		   p_error_message_name => p_manager_details_tab(I).error_message_name,
		   p_error_message => p_manager_details_tab(I).error_message);
        IF (p_manager_details_tab(I).error_message is not null) THEN
           l_error_found := true;
        END IF;
      END LOOP;
    END IF;
    hr_utility.trace('end of checking in update_asg');

    IF (NOT l_error_found) THEN
     hr_utility.trace('IN if (NOT l_error_found)'|| l_proc);

   -- second call create transaction to start transaction
       create_transaction(p_item_type => p_item_type,
	                  p_item_key => p_item_key,
		          p_act_id => p_actid,
                          p_transaction_id => l_transaction_id,
			  p_transaction_step_id => l_transaction_step_id,
                          p_login_person_id => p_login_person_id,
			  p_review_proc_call => wf_engine.GetActivityAttrText(itemtype  => p_item_type,
                                                  itemkey   => p_item_key,
                                                  actid     => p_actid,
                                                  aname     => 'HR_REVIEW_REGION_ITEM'),
			  p_selected_emp_id => p_selected_person_id,
                          p_selected_emp_name => p_selected_person_name,
                          p_no_of_direct_reports => p_num_of_direct_reports,
                          p_no_of_emps => p_num_of_new_direct_reports,
                          p_term_flag => p_term_sup_flag,
			  p_rptg_grp_id => p_rptg_grp_id,
			  p_plan_id => p_plan_id,
			  p_effective_date_option => p_effective_date_option);
    hr_utility.trace('bdefore writing Txn in update_asg');
    hr_utility.trace('p_manager_details_tab.count=' || p_manager_details_tab.count);
   -- third call write transactions to write to transaction tables
       FOR I IN 1 ..p_manager_details_tab.count LOOP

        -- Assignment Security
        IF(l_assignment_security_profile <> 'TRUE') then

          l_supervisor_assignment_id := -1;
          l_old_supervisor_assignment_id := -1;
        ELSE
          l_supervisor_assignment_id
                          := p_manager_details_tab(I).supervisor_assignment_id;
          l_old_supervisor_assignment_id
                          := p_manager_details_tab(I).old_supervisor_assignment_id;
        END IF;
        -- End of Assignment Security code


	write_transaction(p_old_sup_id => p_manager_details_tab(I).old_supervisor_id,
                      p_old_sup_asg_id => l_old_supervisor_assignment_id,
                          p_new_sup_id => p_manager_details_tab(I).supervisor_id,
                      p_new_sup_asg_id => l_supervisor_assignment_id,

	                  p_old_sup_name => p_manager_details_tab(I).old_supervisor_name,
			  p_new_sup_name => p_manager_details_tab(I).supervisor_name,
                          p_emp_name => p_manager_details_tab(I).person_name,
                          p_emp_id => p_manager_details_tab(I).person_id,
			  p_effective_date => p_manager_details_tab(I).effective_date,
                          p_assignment_id => p_manager_details_tab(I).assignment_id,
			  p_section_code => p_manager_details_tab(I).region,
			  p_row_num => p_manager_details_tab(I).rownumber,
			  p_transaction_step_id => l_transaction_step_id,
			  p_login_person_id => p_login_person_id);
      END LOOP;
   -- now commit the transaction table data
      commit;
    END IF;
    p_transaction_step_id := l_transaction_step_id;
hr_utility.set_location('Leaving'|| l_proc,15);
  EXCEPTION
     WHEN OTHERS THEN
     hr_utility.set_location('EXCEPTION'|| l_proc,555);

       hr_utility.set_message('PER', SQLERRM ||' '||to_char(SQLCODE));
       hr_utility.raise_error;
       hr_utility.set_location('Leaving'|| l_proc,10);
  END update_asg;


/*
  ||===========================================================================
  || PROCEDURE: update_asg
  || DESCRIPTION:
  ||
  ||===========================================================================
  */

  procedure update_asg
  (p_validate                     in     NUMBER default 0
  ,p_effective_date               in     date
  ,p_attribute_update_mode        in     varchar2
  ,p_assignment_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_supervisor_id                in     number   default null
  ,p_supervisor_assignment_id     in     number   default null
  ,p_assignment_number            in     varchar2 default null
  ,p_change_reason                in     varchar2 default null
  ,p_comments                     in     varchar2 default null
  ,p_date_probation_end           in     date     default null
  ,p_default_code_comb_id         in     number   default null
  ,p_frequency                    in     varchar2 default null
  ,p_internal_address_line        in     varchar2 default null
  ,p_manager_flag                 in     varchar2 default null
  ,p_normal_hours                 in     number   default null
  ,p_perf_review_period           in     number   default null
  ,p_perf_review_period_frequency in     varchar2 default null
  ,p_probation_period             in     number   default null
  ,p_probation_unit               in     varchar2 default null
  ,p_sal_review_period            in     number   default null
  ,p_sal_review_period_frequency  in     varchar2 default null
  ,p_set_of_books_id              in     number   default null
  ,p_source_type                  in     varchar2 default null
  ,p_time_normal_finish           in     varchar2 default null
  ,p_time_normal_start            in     varchar2 default null
  ,p_ass_attribute_category       in     varchar2 default null
  ,p_title                        in     varchar2 default null
  ,p_comment_id                      out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_no_managers_warning             out nocopy Number
  ,p_other_manager_warning           out nocopy NUMBER
  ,p_item_type                    in     varchar2 default null
  ,p_item_key                     in     varchar2 default null
  ,p_actid                        in     varchar2 default null
  ,p_error_message_appl              out nocopy varchar2
  ,p_error_message_name              out nocopy varchar2
  ,p_error_message                out nocopy    long
  )
IS

  ln_supervisor_id number ;
  lb_no_managers_warn boolean;
  lb_other_manager_warn boolean;
  lb_validate BOOLEAN ;

   -- Bug 2130066 Fix Begins: 01/11/2002
   -- Changed from per_assignments_f to per_all_assignments_f.  This is
   -- necessary because when a Supervisor Security profile restrict to 1 level
   -- ,we cannot get data for 2 levels down or beyond.  This will happen when
   -- the 1st level employee is terminated, we need to change all his direct
   -- reports to another employee.  In this case, the direct reports of the
   -- terminating employee will not be returned because the Supervisor
   -- Security profile is restricted to 1 level.
   --

   CURSOR lc_object_version_no(l_assignment_id number) IS
   SELECT object_version_number, assignment_type
   FROM   per_all_assignments_f        -- Bug 2130066 fix
   WHERE assignment_id = l_assignment_id
   AND   (p_effective_date BETWEEN
            NVL ( effective_start_date , p_effective_date)
            AND NVL ( effective_end_date , p_effective_date )) ;



  ln_object_version_no     NUMBER ;

-- variables and cursor for applicant_hire
l_object_version_number number;
l_assignment_type  per_all_assignments_f.assignment_type%type;
l_per_object_version_number number;
l_employee_number varchar2(30);
l_person_id number;
l_assignment_id number;
l_appl_assignment_type per_all_assignments_f.assignment_type%type;
l_per_effective_start_date date;
l_per_effective_end_date date;
l_unaccepted_asg_del_warning boolean;
l_assign_payroll_warning boolean;
l_attribute_update_mode varchar2(50);
isApplicantSubordinate boolean := true;

-- cursor to get the applicant object_version_number from
-- per_all_people_f
cursor per_applicant_rec(p_appl_person_id in number,
                         p_appl_effective_date in date) is
select object_version_number
from per_all_people_f
where person_id = p_appl_person_id
and p_appl_effective_date between effective_start_date
and effective_end_date;

-- cursor to get the applicant object_version_number,person_id
-- assignment_type from per_all_assignments_f, for assinging
-- a new manager
cursor asg_appl_rec_assign_manager(p_appl_assign_id in number,
                         p_appl_effective_date in date) is
select object_version_number,
       assignment_type,
       person_id
from per_all_assignments_f
where assignment_id = p_appl_assign_id
and p_appl_effective_date between effective_start_date
and effective_end_date;

-- cursor to get the applicant object_version_number
-- assignment_type from per_all_assignments_f, for assigning
-- a new direct reports
cursor asg_appl_rec_assign_directs(p_appl_person_id in number,
                         p_appl_effective_date in date) is
select object_version_number,
       assignment_type
from per_all_assignments_f
where person_id = p_appl_person_id
and p_appl_effective_date between effective_start_date
and effective_end_date;


cursor csr_assignment is
select assignment_id
from per_all_assignments_f
where assignment_id = p_assignment_id;

-- Bug Fix 3041328
cursor csr_person is
select person_id
from per_all_people_f
where person_id = p_supervisor_id;

CURSOR lc_get_current_applicant_flag
         (p_person_id      in number
         ,p_eff_date       in date default trunc(sysdate))
  IS
  SELECT   per.current_applicant_flag,
           per.current_employee_flag,
           per.current_npw_flag
  FROM     per_all_people_f   per
  WHERE  per.person_id = p_person_id
  AND    p_eff_date BETWEEN per.effective_start_date and per.effective_end_date;

 l_current_applicant_flag  per_all_people_f.current_applicant_flag%type;
 l_current_employee_flag  per_all_people_f.current_employee_flag%type;
 l_current_npw_flag  per_all_people_f.current_npw_flag%type;
 l_applicant_person_id    per_all_people_f.person_id%type;
 l_applicant_assignment_id per_all_assignments_f.assignment_id%type;
 l_applicant_effective_date per_all_people_f.effective_start_date%type;

 -- Bug Fix 3041328
 l_supervisor_id per_all_people_F.person_id%type;
-- l_supervisor_assign_id per_all_assignments_f.assignment_id%type;
 l_supervisor_assignment_id per_all_assignments_f.supervisor_assignment_id%type;

 l_re_hire_flow varchar2(25) default null;
 l_error_message varchar2(500);
 l_ex_emp varchar2(10) default null;
 CURSOR chk_ex_emp(l_person_id in number, l_effective_date in Date) is
  select ppt.SYSTEM_PERSON_TYPE from per_all_people_f paf, per_person_types ppt where person_id = l_person_id
  and paf.PERSON_TYPE_ID = ppt.PERSON_TYPE_ID
  and l_effective_date between effective_start_date and effective_end_date;

 l_proc constant varchar2(100) := g_package || ' update_asg';
  BEGIN
  hr_utility.set_location('Entering'|| l_proc,5);
    SAVEPOINT sup_update_asg;
    l_attribute_update_mode := p_attribute_update_mode;
    l_assignment_id := p_assignment_id;

    --Validate the p_assignment_id
    open csr_assignment;
    fetch csr_assignment into l_assignment_id;
    if csr_assignment%notfound then
      hr_new_user_reg_ss.processNewUserTransaction
                             (WfItemType => p_item_type
                              ,WfItemKey => p_item_key
                               ,PersonId => l_person_id
                           ,AssignmentId => l_assignment_id);
    end if;
    close csr_assignment;

    -- Bug Fix 3041328
    l_supervisor_id := p_supervisor_id;
    l_supervisor_assignment_id := p_supervisor_assignment_id;
    --Validate the p_supervisor_id
    if l_supervisor_id is not null then
    	hr_utility.trace('In ( if l_supervisor_id is not null )'|| l_proc);
    	l_re_hire_flow := wf_engine.GetItemAttrText(p_item_type,p_item_key,'HR_FLOW_IDENTIFIER',true);
    	open chk_ex_emp(l_supervisor_id, p_effective_date);
   	fetch chk_ex_emp into l_ex_emp;
   	close chk_ex_emp;

    	if nvl(l_re_hire_flow,'N') = 'EX_EMP' and nvl(l_ex_emp,'N') = 'EX_EMP' then
    		hr_new_user_reg_ss.processExEmpTransaction
                             (WfItemType => p_item_type
                               ,WfItemKey => p_item_key
                               ,PersonId => l_supervisor_id
                               ,AssignmentId => l_supervisor_assignment_id
                               ,p_error_message => l_error_message);
    	else
    		open csr_person;
        	fetch csr_person into l_supervisor_id;
    		if csr_person%notfound then
    	 		hr_utility.trace('In ( if csr_person%notfound )'|| l_proc);
        		hr_new_user_reg_ss.processNewUserTransaction
                             (WfItemType => p_item_type
                               ,WfItemKey => p_item_key
                               ,PersonId => l_supervisor_id
                               ,AssignmentId => l_supervisor_assignment_id);
    		end if;
    		close csr_person;
    	-- end of Bug Fix 3041328
     	end if;
    end if;
    -- To support applicant hire in New Hire process, we need to convert the applicant
    -- to employee then update the assignment and rollback the employee to applicant

    -- If we are assigning a new manager to the applicant record, then we need
    -- hire the applicant and assign a manager

    -- If we are assigning new direct reports to the applicant record, then we
    -- need to hire the applicant and assign new directs
    -- First get the assignment_type using the assingmet id, if its an applicant
    -- then we are assigning a new manager to the applicant
    /*

     Check the mode we are entering to update

     case 1: update the current employee assignment record with applicant person id
           Create a  employee record with applicant person id
     case 2: update the applicant assignment record with existing employee person id.
           Create a  employee record with applicant assignment record details.
     case 3: update the current employee assignment record with existing employee person id
            No need to create a dummy employee record.

   */


    -- Checking  case 1:
    open lc_get_current_applicant_flag(p_supervisor_id, p_effective_date);
    fetch lc_get_current_applicant_flag into l_current_applicant_flag, l_current_employee_flag, l_current_npw_flag;
    close lc_get_current_applicant_flag;

    if (l_current_applicant_flag = 'Y' AND
        nvl(l_current_employee_flag, 'N') <>  'Y' AND
        nvl(l_current_npw_flag, 'N') <> 'Y') then
         hr_utility.trace('In ( if of checking Case1 mode )'|| l_proc);
      g_applicant_hire := true;
      isApplicantSubordinate := false;
      l_applicant_person_id := p_supervisor_id;
      -- Get the assignment_id for the applicant from workflow
      l_applicant_assignment_id := wf_engine.getItemAttrText(
                                               itemtype  => p_item_type,
                                               itemkey   => p_item_key,
                                               aname     => 'CURRENT_ASSIGNMENT_ID');
      l_applicant_effective_date := wf_engine.getItemAttrDate(
                                               itemtype  => p_item_type,
                                               itemkey   => p_item_key,
                                               aname     => 'CURRENT_EFFECTIVE_DATE');
      -- Get the object version number
      open asg_appl_rec_assign_directs(p_supervisor_id, p_effective_date);
      fetch asg_appl_rec_assign_directs into l_object_version_number
                                            ,l_appl_assignment_type;
      close asg_appl_rec_assign_directs;

      -- call the API to hire this person.
      -- reset the g_applicant_hire to false.
    end if;

    -- Checking case 2 :
    open asg_appl_rec_assign_manager(p_assignment_id, p_effective_date);
    fetch asg_appl_rec_assign_manager into l_object_version_number
                                          ,l_appl_assignment_type
                                          ,l_person_id;
    close asg_appl_rec_assign_manager;

    if(l_appl_assignment_type = 'A') then
    hr_utility.trace('In ( if (l_appl_assignment_type = A )'|| l_proc);
      g_applicant_hire := true;
      isApplicantSubordinate := false;
      -- Get the person_id from assignment record.
      l_applicant_person_id := l_person_id;
      l_applicant_assignment_id := p_assignment_id;
      l_applicant_effective_date := wf_engine.getItemAttrDate(
                                               itemtype  => p_item_type,
                                               itemkey   => p_item_key,
                                               aname     => 'CURRENT_EFFECTIVE_DATE');
      -- first get the object_version_number for the applicant from
      -- per_all_people_f

      open per_applicant_rec(l_person_id, l_applicant_effective_date);
      fetch per_applicant_rec into l_per_object_version_number;
      close per_applicant_rec;
    end if;

    if (g_applicant_hire) then
    hr_utility.trace('In ( if of g_applicant_hire )'|| l_proc);
     -- SAVEPOINT applicant_hire;

      -- get the employee number from Basic Details Step
      /*hr_person_info_util_ss.get_trns_employee_number(
                        p_item_type => p_item_type
                       ,p_item_key => p_item_key
                       ,p_employee_number => l_employee_number);
      -- first get the object_version_number for the applicant from
      -- per_all_people_f

      open per_applicant_rec(l_applicant_person_id, l_applicant_effective_date);
      fetch per_applicant_rec into l_per_object_version_number;
      close per_applicant_rec;

      --call the hr_applicant_api.hire_applicant
      hr_applicant_api.hire_applicant(
                          p_validate                  => false
                         ,p_hire_date                 => l_applicant_effective_date
                         ,p_person_id                 => l_applicant_person_id
                         ,p_per_object_version_number => l_per_object_version_number
                         ,p_assignment_id             => l_applicant_assignment_id
                         ,p_employee_number           => l_employee_number
                         ,p_per_effective_start_date  => l_per_effective_start_date
                         ,p_per_effective_end_date    => l_per_effective_end_date
                         ,p_unaccepted_asg_del_warning=> l_unaccepted_asg_del_warning
                         ,p_assign_payroll_warning    => l_assign_payroll_warning
,p_source => true); */

                hr_new_user_reg_ss.process_selected_transaction(p_item_type => p_item_type,
                                                   p_item_key => p_item_key
                         ,p_api_name => 'HR_PROCESS_PERSON_SS.PROCESS_API');

     end if;

    if p_validate  = 1 THEN
      lb_validate := true ;
    else
      lb_validate := false ;
    end if ;


    OPEN lc_object_version_no(l_assignment_id) ;
    FETCH lc_object_version_no into ln_object_version_no,l_assignment_type;
    CLOSE lc_object_version_no ;

    -- Call the actual API.
    hr_assignment_att.update_asg(
                        p_validate              =>lb_validate,
                        p_effective_date        =>p_effective_date  ,
                        p_attribute_update_mode =>p_attribute_update_mode ,
                        p_assignment_id         =>l_assignment_id ,
                        p_assignment_type       =>l_assignment_type,
                        p_object_version_number =>ln_object_version_no ,
                        p_supervisor_id         => l_supervisor_id ,
                        -- Assignment Security
                        p_supervisor_assignment_id =>l_supervisor_assignment_id,
                        p_comment_id            => p_comment_id ,
                        p_effective_start_date  =>p_effective_start_date,
                        p_effective_end_date    =>p_effective_end_date,
                        p_no_managers_warning   =>lb_no_managers_warn,
                        p_other_manager_warning =>lb_other_manager_warn ) ;

    -- applicant_hire
    if (g_applicant_hire) then
      g_applicant_hire := false;
      --rollback to applicant_hire;
    end if;
 hr_utility.set_location('Leaving'|| l_proc,40);
    ROLLBACK TO sup_update_asg;

    EXCEPTION
      WHEN hr_utility.hr_error THEN
      hr_utility.set_location('EXCEPTION'|| l_proc,555);
      	-- -------------------------------------------
   	    -- an application error has been raised so we must
      	-- redisplay the web form to display the error
   	    -- --------------------------------------------
        ROLLBACK TO sup_update_asg;
        hr_message.provide_error;
	p_error_message_appl := hr_message.last_message_app;
	p_error_message_name := hr_message.last_message_name;
        p_error_message := null;

      WHEN OTHERS THEN
      hr_utility.set_location('EXCEPTION'|| l_proc,555);
        -- applicant_hire
        if (g_applicant_hire) then
          g_applicant_hire := false;
         -- rollback to applicant_hire;
        end if;
        IF (hr_utility.get_message IS NOT NULL) THEN
           p_error_message := 'ORA' || hr_utility.hr_error_number || ' '||
                             hr_utility.get_message;
        ELSE
           p_error_message := hr_message.get_message_text;
        END IF;
	p_error_message_appl := null;
	p_error_message_name := null;
        ROLLBACK TO sup_update_asg;


END update_asg;


END HR_SUPERVISOR_SS;

/
