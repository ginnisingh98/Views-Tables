--------------------------------------------------------
--  DDL for Package Body HR_DYNAMIC_APPROVAL_WEB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_DYNAMIC_APPROVAL_WEB" AS
/* $Header: hrdynapr.pkb 120.3.12010000.4 2009/09/21 10:23:42 ckondapi ship $ */

-- |---------------------------------------------------------------------------|
-- |-- < TIPS Begin > ---------------------------------------------------------|
-- |---------------------------------------------------------------------------|
--
-- TIP INSTRUCTION1                 HR_DYNAMIC_APPROVERS_WEB
-- TIP INSTRUCTION2                 HR_DYNAMIC_APPROVERS_WEB
-- TIP P_APPROVER_NAME              HR_DYNAMIC_APPROVERS_WEB
-- TIP P_NOTIFIER_NAME              HR_DYNAMIC_APPROVERS_WEB
--
-- |---------------------------------------------------------------------------|
-- |-- < TIPS End >------------------------------------------------------------|
-- |---------------------------------------------------------------------------|

gv_package                  CONSTANT VARCHAR2(100)
                                    DEFAULT 'hr_dynamic_approval_web';
gv_dynappr_js_file          CONSTANT VARCHAR2(100) DEFAULT 'hrdynapr.js';
gv_form_name                CONSTANT VARCHAR2(100) DEFAULT 'approvalsForm';
gv_tip_test_mode            BOOLEAN DEFAULT FALSE;
gv_user_date_format         VARCHAR2(2000);
gn_person_id                per_people_f.person_id%TYPE;
gn_assignment_id            per_all_assignments_f.assignment_id%TYPE;
gv_error_table              hr_dynamic_approval_web.t_person_table;
grt_wf_attributes_rec       hr_dynamic_approval_web.grt_wf_attributes;

gv_current_row              NUMBER DEFAULT 1;
gv_mode                     VARCHAR2(25) DEFAULT 'RUN';
gv_job_type                 hr_suit_match_utility_web.g_job_type%TYPE;

-- variables for ak data
gv_region_code              CONSTANT VARCHAR2(100)
                                     DEFAULT 'HR_DYNAMIC_APPROVALS_WEB';
gv_nav_region_code          CONSTANT VARCHAR2(100)
                                     DEFAULT 'HR_BUTTON_LABELS_WEB';
gn_region_application_id    CONSTANT integer := 601;
gv_browser_title            hr_util_misc_web.g_title%TYPE;
gtt_prompts                 hr_util_misc_web.g_prompts%TYPE;
gv_language_code            VARCHAR2(200) DEFAULT NULL;
gv_approvals_mode           wf_activity_attr_values.text_value%TYPE;
gv_update_mode              wf_activity_attr_values.text_value%TYPE
                                     DEFAULT 'OFF';
gv_effective_date           wf_item_attribute_values.text_value%TYPE;
gv_APPROVALS_ACTIVITY_NAME  CONSTANT
                            wf_item_activity_statuses_v.activity_name%TYPE
                                     DEFAULT 'HR_DYNAMIC_APPROVALS';
gv_process_name             wf_process_activities.process_name%TYPE
                                     DEFAULT 'HR_HRSSA_DYNA_APPROVAL_PRC' ;

grt_person_details            hr_dynamic_approval_web.person_details;
grt_person_details_rec_table  hr_dynamic_approval_web.t_person_table;
grt_approver_details_table    hr_dynamic_approval_web.t_person_table;
gn_approver_index             NUMBER DEFAULT 1;
gv_additional_approvers       VARCHAR2(10) DEFAULT 'NO';
gn_additional_approvers       NUMBER DEFAULT 0;
gv_item_name                  VARCHAR2(100) DEFAULT 'ADDITIONAL_APPROVER_';
gv_notifier_name              VARCHAR2(100) DEFAULT 'NOTIFIER_';
gn_notifiers                  NUMBER DEFAULT 0;
grt_notifier_details_table    hr_dynamic_approval_web.notifier_rec_table;
grt_notifier_error_table      hr_dynamic_approval_web.notifier_rec_table;
gv_cross_business_group     VARCHAR2(10) ;
g_package                  CONSTANT VARCHAR2(100):='hr_dynamic_approval_web';


-- exceptions
gv_invalid_person              EXCEPTION;
gv_no_default_approver         EXCEPTION;
-- Cursors for the Name, Job Title

-- CURSOR FOR FULL_NAME
CURSOR gc_full_name (
    p_person  IN per_people_f.person_id%TYPE
  )
  IS
  SELECT peo.full_name
  FROM   per_people_f peo
  WHERE  peo.person_id = p_person;

-- curosr for Person_id
CURSOR lc_approver ( p_full_name VARCHAR2)
     IS
     SELECT person_id
     FROM per_all_people_f
     WHERE full_name = p_full_name ;

-- assignment id for the approver
CURSOR gc_assignment_id (p_person_id   IN per_people_f.person_id%TYPE,
					p_effective_date  IN DATE
		 ) IS
      SELECT paf.assignment_id
      FROM
            per_all_assignments_f paf,
            per_all_people_f peo
      WHERE
            peo.person_id = paf.person_id
      AND   peo.person_id = p_person_id
      AND   p_effective_date BETWEEN paf.effective_start_date
                             AND NVL(paf.effective_end_date, TRUNC(SYSDATE))
      ORDER BY paf.effective_start_date DESC;



-- CURSOR FOR JOB TITLE
CURSOR gc_job_details (
             p_assignment_id   IN per_assignments_f.assignment_id%TYPE,
             p_effective_date  IN DATE
           ) IS
    SELECT pj.name
    FROM   per_jobs_vl pj,
           per_assignments_f paf
    WHERE  paf.assignment_id     = p_assignment_id
      AND  paf.job_id            = pj.job_id
      AND  paf.primary_flag      = 'Y'
      AND  paf.business_group_id+0 = pj.business_group_id+0
      AND  p_effective_date BETWEEN paf.effective_start_date
                                AND NVL(paf.effective_end_date, TRUNC(SYSDATE))
    ORDER BY paf.effective_start_date DESC;

-- cursor for JOB ID
CURSOR gc_job_id (
             p_assignment_id   IN per_assignments_f.assignment_id%TYPE,
             p_effective_date  IN DATE
           ) IS
    SELECT pj.job_id
    FROM   per_jobs pj,
           per_assignments_f paf
    WHERE  paf.assignment_id     = p_assignment_id
      AND  paf.job_id            = pj.job_id
      AND  paf.primary_flag      = 'Y'
      AND  paf.business_group_id+0 = pj.business_group_id+0
      AND  p_effective_date BETWEEN paf.effective_start_date
                                AND NVL(paf.effective_end_date, TRUNC(SYSDATE))
    ORDER BY paf.effective_start_date DESC;


-- cursor determines if an attribute exists
  cursor csr_wiav (p_item_type in     varchar2
                  ,p_item_key  in     varchar2
                  ,p_name      in     varchar2)
    IS
    select 1
    from   wf_item_attribute_values wiav
    where  wiav.item_type = p_item_type
    and    wiav.item_key  = p_item_key
    and    wiav.name      = p_name;

 -- cursor determines if an acitivity attribute exists
  cursor csr_wfaav (p_name      in     varchar2
                  , p_id        in     varchar2
                   )
    IS
    select 1
    from   WF_ACTIVITY_ATTR_VALUES wfaav
    where  wfaav.name               =  p_name
    and    wfaav.PROCESS_ACTIVITY_ID = p_id;






-- ---------------------------------------------------------------------------
-- private procedure declarations
-- ---------------------------------------------------------------------------
--
-- ---------------------------------------------------------------------------
-- |------------------------------< set_custom_wf_globals >-------------------|
-- ---------------------------------------------------------------------------
--
-- This procedure sets the customized global variables with the standard wf
-- values
--
PROCEDURE SET_CUSTOM_WF_GLOBALS
  (p_itemtype in varchar2
  ,p_itemkey  in varchar2)
IS
-- Local Variables
l_proc constant varchar2(100) := g_package || ' SET_CUSTOM_WF_GLOBALS';
BEGIN
  hr_utility.set_location('Entering: '|| l_proc,5);
  hr_approval_custom.g_itemtype := p_itemtype;
  hr_approval_custom.g_itemkey  := p_itemkey;
  hr_utility.set_location('Leaving: '|| l_proc,10);
END SET_CUSTOM_WF_GLOBALS;
--


-- ---------------------------------------------------------------------------
-- private procedure declarations
-- ---------------------------------------------------------------------------
--


-- ---------------------------------------------------------------------------
-- private Function declarations
-- ---------------------------------------------------------------------------
--
-- ----------------------------------------------------------------------------
-- |------------------------------< get_job_details >-------------------|
-- ----------------------------------------------------------------------------
--
-- This function will return the job title for the person id passed
--

  FUNCTION  get_job_details (p_person_id IN NUMBER,
                             p_assignment_id IN NUMBER DEFAULT NULL,
                             p_effective_date IN DATE  DEFAULT SYSDATE
                             )
  RETURN VARCHAR2
  IS
  -- Local Variables
   lv_job_title     VARCHAR2(1000);
   ln_job_id   NUMBER;
   l_curr_org_name VARCHAR2(100);
   l_curr_loc_name VARCHAR2(100);
   ln_assignment_id NUMBER;
   lrt_assignment_details               hr_misc_web.grt_assignment_details;
l_proc constant varchar2(100) := g_package || ' get_job_details';

  BEGIN
     hr_utility.set_location('Entering: '|| l_proc,5);
    IF p_person_id IS NOT NULL THEN
     hr_utility.trace('In ( IF p_person_id IS NOT NULL): '|| l_proc);
     -- check assignment id
       IF p_assignment_id IS NULL THEN
         -- get assignment id for the person_id
           lrt_assignment_details := hr_misc_web.get_assignment_id (
                                              p_person_id =>p_person_id);
           ln_assignment_id := lrt_assignment_details.assignment_id;
       ELSE
         ln_assignment_id := p_assignment_id;
       END IF;
       -- get the job details from the assignment record
          lrt_assignment_details := hr_misc_web.get_assignment_details(
                                        p_assignment_id => ln_assignment_id,
                                        p_effective_date =>p_effective_date
                                        );
          ln_job_id := lrt_assignment_details.job_id;

       -- get the job title from flexfields
          hr_suit_match_utility_web.get_job_info
                   (p_search_type   => gv_job_type,
                    p_id            => ln_job_id,
                    p_name          => lv_job_title,
                    p_org_name      => l_curr_org_name,
                    p_location_code => l_curr_loc_name);

    END IF;

   lv_job_title := NVL(lv_job_title,lrt_assignment_details.job_name);
   hr_utility.set_location('Leaving: '|| l_proc,15);
   return lv_job_title;

  EXCEPTION WHEN OTHERS THEN
      hr_utility.set_location('EXCEPTION: '|| l_proc,555);
      raise;

  END get_job_details;

-- ---------------------------------------------------------------------------
-- private Function declarations
-- ---------------------------------------------------------------------------
--
-- ----------------------------------------------------------------------------
-- |------------------------------< build_where_clause >-------------------|
-- ----------------------------------------------------------------------------
--
-- This function will build the where clause for approvers and notifiers based
--  on context passed.
--

  FUNCTION build_where_clause(
                    p_where_for IN VARCHAR2,
                    p_Approvers_list  hr_util_misc_web.g_varchar2_tab_type
                              DEFAULT hr_util_misc_web.g_varchar2_tab_default,
                    p_Notifiers_list  hr_util_misc_web.g_varchar2_tab_type
                              DEFAULT hr_util_misc_web.g_varchar2_tab_default,
                    p_effective_date IN DATE DEFAULT SYSDATE,
                    p_business_group_id IN NUMBER DEFAULT 0

                   )
  RETURN LONG
  IS
    lv_where LONG ;
    lv_person_id_list hr_util_misc_web.g_varchar2_tab_type
                              DEFAULT hr_util_misc_web.g_varchar2_tab_default;
    lv_error_flag boolean;
    ln_count      NUMBER DEFAULT 0;
    ld_effective_date DATE DEFAULT SYSDATE;
    lv_search  VARCHAR2(1000);
    l_proc constant varchar2(100) := g_package || ' build_where_clause';
  BEGIN

    -- get the global supervisor profile value
    -- if profile value is 'Y' , we do not check for business
    -- group, otherwise we will check for business group id in
    -- all the cursors etc.
    hr_utility.set_location('Entering: '|| l_proc,5);
    gv_cross_business_group :=
        fnd_profile.value ( 'HR_CROSS_BUSINESS_GROUP');


   IF p_where_for='APPROVERS' THEN
    hr_utility.trace('In (IF p_where_for=APPROVERS): '|| l_proc);
      lv_where := 'PERSON_ID NOT IN(';
      ln_count := 0;
          hr_utility.trace('Going into ( FOR I IN 1..grt_approver_details_table.count): '|| l_proc);
      FOR I IN 1..grt_approver_details_table.count
      LOOP
         IF grt_approver_details_table(I).person_id IS NOT NULL THEN
              ln_count := ln_count + 1;
               IF ln_count < 2 THEN
                lv_where :=lv_where ||to_char(grt_approver_details_table(I).person_id);
               ELSE
                 lv_where :=lv_where ||','||to_char(grt_approver_details_table(I).person_id);
              END IF;

          END IF;
     END LOOP;
       hr_utility.trace('Out of  ( FOR I IN 1..grt_approver_details_table.count): '|| l_proc);

  IF gv_cross_business_group = 'Y'
  THEN
  hr_utility.trace('In (IF gv_cross_business_group = Y): '|| l_proc);
   lv_where := lv_where ||') '||' AND business_group_id = business_group_id '||
                 ' AND to_date(''' || ld_effective_date || ''',''' ||
              gv_user_date_format || ''') between effective_start_date and '||
              ' nvl(effective_end_date, (to_date(''' || ld_effective_date ||
              ''',''' || gv_user_date_format || ''') +1 ) )';
  ELSE
    hr_utility.trace('In else of  (IF gv_cross_business_group = Y): '|| l_proc);
   lv_where := lv_where ||') '||' AND business_group_id = '||p_business_group_id||
                 ' AND to_date(''' || ld_effective_date || ''',''' ||
              gv_user_date_format || ''') between effective_start_date and '||
              ' nvl(effective_end_date, (to_date(''' || ld_effective_date ||
              ''',''' || gv_user_date_format || ''') +1 ) )';
  END IF;

-- Added check for effective_start_date and effective_end_date of assingments table
   lv_where := lv_where ||' AND to_date(''' || ld_effective_date || ''',''' ||
              gv_user_date_format || ''') between asn_effective_start_date and '||
              ' nvl(asn_effective_end_date, (to_date(''' || ld_effective_date ||
              ''',''' || gv_user_date_format || ''') +1 ) )';



   END IF;

   IF p_where_for='NOTIFIERS' THEN
    hr_utility.trace('In (IF p_where_for=NOTIFIERS): '|| l_proc);
     -- lv_search
     -- build string for the person_id's in approvers list
     -- we do not want notifiers and approvers to be same;
      -- avoid duplicate notifications

    IF grt_approver_details_table.count < 1 THEN
     hr_utility.trace('In (IF grt_approver_details_table.count < 1 ): '|| l_proc);
      -- no approvers currently
       lv_search := '';
    ELSE
    hr_utility.trace('In else(IF grt_approver_details_table.count < 1 ): '|| l_proc);
     ln_count := 0;
     hr_utility.trace('Going into ( FOR I IN 1..grt_approver_details_table.count): '|| l_proc);
     FOR I IN 1..grt_approver_details_table.count
     LOOP
       IF grt_approver_details_table(I).person_id IS NOT NULL THEN
         ln_count := ln_count + 1;
         lv_search := lv_search ||'|'
                 ||to_char(grt_approver_details_table(I).person_id);

       END IF;
     END LOOP;
          hr_utility.trace('Going into ( FOR I IN 1..grt_approver_details_table.count): '|| l_proc);
    END IF;



-- build the where clause
IF grt_approver_details_table.count< 1 THEN
    hr_utility.trace('In (IF grt_approver_details_table.count < 1 ): '|| l_proc);
   lv_where := ' to_date(''' || ld_effective_date || ''',''' ||
              gv_user_date_format || ''') between effective_start_date and '||
              ' nvl(effective_end_date, (to_date(''' || ld_effective_date ||
              ''',''' || gv_user_date_format || ''') +1 ) )';
-- Added check for effective_start_date and effective_end_date of assingments table
   lv_where := lv_where ||' AND to_date(''' || ld_effective_date || ''',''' ||
              gv_user_date_format || ''') between asn_effective_start_date and '||
              ' nvl(asn_effective_end_date, (to_date(''' || ld_effective_date ||
              ''',''' || gv_user_date_format || ''') +1 ) )';

ELSE
    hr_utility.trace('In else(IF grt_approver_details_table.count < 1 ): '|| l_proc);
lv_where := 'PERSON_ID NOT IN(';
ln_count := 0;
    hr_utility.trace('Going into (FOR I IN 1..grt_approver_details_table.count ): '|| l_proc);
-- first exclude the person_id's from  approvers list
FOR I IN 1..grt_approver_details_table.count
LOOP

  IF grt_approver_details_table(I).person_id IS NOT NULL THEN
       ln_count := ln_count + 1;
       IF ln_count < 2 THEN
     lv_where :=lv_where ||to_char(grt_approver_details_table(I).person_id);
      ELSE
      lv_where :=lv_where ||','||to_char(grt_approver_details_table(I).person_id);
      END IF;

 END IF;
END LOOP;
    hr_utility.trace('Out of  (FOR I IN 1..grt_approver_details_table.count ): '|| l_proc);
 -- exclude person_id's from notifiers list
 IF grt_notifier_details_table.count>0 THEN
    hr_utility.trace('In (IF grt_notifier_details_table.count>0 ): '|| l_proc);
        hr_utility.trace('Going into (FOR I IN 1..grt_notifier_details_table.count): '|| l_proc);
         FOR I IN 1..grt_notifier_details_table.count
         LOOP
         IF INSTR(lv_search,
                   to_char(grt_notifier_details_table(I).person_id)) = 0
         THEN
          lv_where :=lv_where ||','||
                   to_char(grt_notifier_details_table(I).person_id);
         END IF;
          END LOOP;
        hr_utility.trace('Out of  (FOR I IN 1..grt_notifier_details_table.count): '|| l_proc);
  END IF;


  IF gv_cross_business_group = 'Y'
  THEN
    hr_utility.trace('In (IF  IF gv_cross_business_group = Y ): '|| l_proc);
   lv_where := lv_where ||') '||' AND business_group_id = business_group_id '||
                 ' AND to_date(''' || ld_effective_date || ''',''' ||
              gv_user_date_format || ''') between effective_start_date and '||
              ' nvl(effective_end_date, (to_date(''' || ld_effective_date ||
              ''',''' || gv_user_date_format || ''') +1 ) )';
  ELSE
      hr_utility.trace('In else  (IF  IF gv_cross_business_group = Y ): '|| l_proc);
   lv_where := lv_where ||') '||' AND business_group_id = '||p_business_group_id||
                 ' AND to_date(''' || ld_effective_date || ''',''' ||
              gv_user_date_format || ''') between effective_start_date and '||
              ' nvl(effective_end_date, (to_date(''' || ld_effective_date ||
              ''',''' || gv_user_date_format || ''') +1 ) )';
  END IF;

-- Added check for effective_start_date and effective_end_date of assingments table
   lv_where := lv_where ||' AND to_date(''' || ld_effective_date || ''',''' ||
              gv_user_date_format || ''') between asn_effective_start_date and '||
              ' nvl(asn_effective_end_date, (to_date(''' || ld_effective_date ||
              ''',''' || gv_user_date_format || ''') +1 ) )';


END IF; -- for grt_approver_details_table.count < 1

END IF; -- for p_where_for='NOTIFIERS'

hr_utility.set_location('Leaving: '|| l_proc,85);

   return lv_where;
  EXCEPTION WHEN OTHERS THEN
  hr_utility.set_location('EXCEPTION: '|| l_proc,555);
  raise;
  END build_where_clause;
-- ---------------------------------------------------------------------------
-- private Procedure declarations
-- ---------------------------------------------------------------------------
--
-- ----------------------------------------------------------------------------
-- |------------------------------< update_ame_approvers_list>-------------------|
-- ----------------------------------------------------------------------------
--
-- This procedure will write the additional approvers added to the AME tables.
-- ----------------------------------------------------------------------------

PROCEDURE update_ame_approvers_list(
           p_item_type 	IN WF_ITEMS.ITEM_TYPE%TYPE ,
           p_item_key  	IN WF_ITEMS.ITEM_KEY%TYPE ,
           p_act_id    	IN NUMBER ,
           p_approver_name  hr_util_misc_web.g_varchar2_tab_type
                        DEFAULT hr_util_misc_web.g_varchar2_tab_default,
           p_approver_flag  hr_util_misc_web.g_varchar2_tab_type
                        DEFAULT  hr_util_misc_web.g_varchar2_tab_default)

 IS
 -- Local variables
   ln_person_id        per_people_f.person_id%TYPE;
   lv_exists           VARCHAR2(10);
   lv_dummy            VARCHAR2(100);
   lv_item_name        VARCHAR2(100) DEFAULT 'ADDITIONAL_APPROVER_';
   ln_addntl_approvers NUMBER DEFAULT 0;
   lv_notify           VARCHAR2(10);
   ln_notifiers        NUMBER DEFAULT 0;
   ln_approval_level   NUMBER DEFAULT NULL;
 l_proc constant varchar2(100) := g_package || '   update_ame_approvers_list';
-- Variables required for AME API
c_application_id integer;
c_transaction_id varchar2(25);
c_transaction_type varchar2(25);
c_next_approver_rec ame_util.approverRecord;
c_additional_approver_order ame_util.orderRecord;
c_additional_approver_rec ame_util.approversTable;

v_next_approver_rec ame_util.approverRecord2;
v_additional_approver_order ame_util.insertionRecord2;

  -------------------------------BEGIN-------------------------------------------
BEGIN
 hr_utility.set_location('Entering: '|| l_proc,5);
  -- validate the session
  hr_util_misc_web.validate_session(p_person_id => gn_person_id);


  -- get AME related WF attribute values
  c_application_id :=wf_engine.GetItemAttrNumber(itemtype => p_item_type ,
                                                 itemkey  => p_item_key,
                                                 aname => 'HR_AME_APP_ID_ATTR');

  c_application_id := nvl(c_application_id,800);


  c_transaction_id := wf_engine.GetItemAttrNumber(itemtype => p_item_type ,
                                                  itemkey  => p_item_key,
                                                  aname => 'TRANSACTION_ID');



  c_transaction_type := wf_engine.GetItemAttrText(itemtype => p_item_type ,
                                               itemkey  => p_item_key,
                                               aname => 'HR_AME_TRAN_TYPE_ATTR');

 hr_utility.trace('Going into (FOR I IN 1..p_approver_name.count LOOP): '|| l_proc);
  -- get person id for the given full name.
    FOR I IN 1..p_approver_name.count LOOP
    -- get the person_id for this person_name
    OPEN  lc_approver ( p_full_name=>p_approver_name(I));
     hr_utility.trace('Going into Fetch after ( OPEN  lc_approver ( p_full_name=>p_approver_name(I)) ): '|| l_proc);
    FETCH lc_approver INTO ln_person_id;
      IF lc_approver%NOTFOUND THEN
        lv_exists := 'N';
        raise  gv_invalid_person;
      ELSE
        lv_exists:= 'Y';
      END IF ;
    CLOSE lc_approver;

    c_additional_approver_rec(i).person_id:=ln_person_id;

  end loop;
hr_utility.trace('Out of (FOR I IN 1..p_approver_name.count LOOP): '|| l_proc);
  -- clear all the insertions into AME . Need to perform this step ONLY after we get the person id .
  -- other wise it would clear the insertions made in the previous pass.
/*  ame_api.clearInsertions(applicationIdIn =>c_application_id ,
                          transactionIdIn =>c_transaction_id,
                          transactionTypeIn=>c_transaction_type);*/

  AME_API3.clearInsertions(applicationIdIn =>c_application_id ,
                            transactionTypeIn =>c_transaction_type,
                            transactionIdIn =>c_transaction_id);


  if(c_transaction_type is not null) then
    -- update AME list
 hr_utility.trace('In(  if(c_transaction_type is not null) ): '|| l_proc);
hr_utility.trace('Going into (for i in 1..c_additional_approver_rec.count): '|| l_proc);
    for i in 1..c_additional_approver_rec.count loop
      -- check for the default approver flag
      if(p_approver_flag(I)='N') then
        -- details for the record insertion into AME
        c_next_approver_rec.person_id:=c_additional_approver_rec(i).person_id;
        c_next_approver_rec.api_insertion:= ame_util.apiInsertion;
        c_next_approver_rec.authority:=ame_util.authorityApprover;


	 ame_util.apprRecordToApprRecord2(approverRecordIn => c_next_approver_rec,
                              itemIdIn => c_transaction_id,
                              approverRecord2Out =>v_next_approver_rec);

        -- details for the insertion order for the AME record.
        c_additional_approver_order.order_type:=ame_util.absoluteOrder;
        c_additional_approver_order.parameter:=I;
        c_additional_approver_order.description:=p_approver_name(I);

 ame_util.ordRecordToInsRecord2(orderRecordIn =>c_additional_approver_order,
                            transactionIdIn => c_transaction_id,
                            approverIn => c_next_approver_rec,
                            insertionRecord2Out => v_additional_approver_order);

      v_next_approver_rec.action_type_id := v_additional_approver_order.action_type_id;
      v_next_approver_rec.group_or_chain_id  := v_additional_approver_order.group_or_chain_id ;


	AME_API3.insertApprover(applicationIdIn =>c_application_id,
                            transactionTypeIn =>c_transaction_type,
                            transactionIdIn =>c_transaction_id,
                            approverIn =>v_next_approver_rec,
                            positionIn =>I,
                            insertionIn =>v_additional_approver_order);





     /*   ame_api.insertApprover(applicationIdIn =>c_application_id,
                               transactionIdIn =>c_transaction_id,
                               approverIn =>c_next_approver_rec,
                               positionIn =>I,
                               orderIn =>c_additional_approver_order,
                               transactionTypeIn=>c_transaction_type );*/


      end if;
    end loop;
    hr_utility.trace('Out of  (for i in 1..c_additional_approver_rec.count): '|| l_proc);
  end if; -- end updating AME list
hr_utility.set_location('Leaving: '|| l_proc,40);
EXCEPTION
   WHEN gv_invalid_person THEN
   hr_utility.set_location('EXCEPTION: '|| l_proc,555);
	if lc_approver%isopen then
	  close lc_approver;
	end if;
       raise;
   WHEN OTHERS THEN
   hr_utility.set_location('EXCEPTION: '|| l_proc,560);
	if lc_approver%isopen then
	  close lc_approver;
	end if;
     raise;
END update_ame_approvers_list;



-- ---------------------------------------------------------------------------
-- private Procedure declarations
-- ---------------------------------------------------------------------------
--
-- ----------------------------------------------------------------------------
-- |------------------------------< COMMIT_DATA>-------------------|
-- ----------------------------------------------------------------------------
--
-- This procedure will write the approvers and notifiers data to the
-- wf_item_attribute_values table and creates other item_attributes if not exist.
--
 PROCEDURE COMMIT_DATA(
           p_item_type 	IN WF_ITEMS.ITEM_TYPE%TYPE ,
           p_item_key  	IN WF_ITEMS.ITEM_KEY%TYPE ,
           p_act_id    	IN NUMBER ,
           p_approver_name  hr_util_misc_web.g_varchar2_tab_type
                        DEFAULT hr_util_misc_web.g_varchar2_tab_default,
           p_approver_flag  hr_util_misc_web.g_varchar2_tab_type
                        DEFAULT  hr_util_misc_web.g_varchar2_tab_default,
           p_notifier_name hr_util_misc_web.g_varchar2_tab_type
                        DEFAULT hr_util_misc_web.g_varchar2_tab_default,
           p_notify_onsubmit_flag hr_util_misc_web.g_varchar2_tab_type
                        DEFAULT hr_util_misc_web.g_varchar2_tab_default,
           p_notify_onapproval_flag hr_util_misc_web.g_varchar2_tab_type
                        DEFAULT hr_util_misc_web.g_varchar2_tab_default,
           p_mode       IN VARCHAR2
                       )
 IS
 -- Local variables
   ln_person_id        per_people_f.person_id%TYPE;
   lv_exists           VARCHAR2(10);
   lv_dummy            VARCHAR2(100);
   lv_item_name        VARCHAR2(100) DEFAULT 'ADDITIONAL_APPROVER_';
   ln_addntl_approvers NUMBER DEFAULT 0;
   lv_notify           VARCHAR2(10);
   ln_notifiers        NUMBER DEFAULT 0;
   ln_approval_level   NUMBER DEFAULT NULL;
   l_proc constant varchar2(100) := g_package || ' COMMIT_DATA';

-- for AME
c_transaction_type varchar2(25);

  -------------------------------------------------------------------------------
  -------------------------------BEGIN-------------------------------------------
   BEGIN

 hr_utility.set_location('Entering: '|| l_proc,5);
-- validate the session
  hr_util_misc_web.validate_session(p_person_id => gn_person_id);

-- get user date format
  gv_user_date_format := hr_util_misc_web.get_user_date_format;


-- get session language code
  gv_language_code := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);

-- check if we need to call AME
-- get the AME transaction type value from WF item attributes
c_transaction_type := wf_engine.GetItemAttrText(itemtype => p_item_type ,
                                               itemkey  => p_item_key,
                                               aname => 'HR_AME_TRAN_TYPE_ATTR');


if (c_transaction_type is not null) then
 hr_utility.trace('In (if (c_transaction_type is not null)): '|| l_proc);
  update_ame_approvers_list(
           p_item_type  =>p_item_type,
           p_item_key   =>p_item_key,
           p_act_id     =>p_act_id,
           p_approver_name =>p_approver_name,
           p_approver_flag=>p_approver_flag);

else
 hr_utility.trace('In esle of (if (c_transaction_type is not null)): '|| l_proc);
-- fix for bug # 1570998
-- set all the current wf item attributes for additional approvers to deleted state.
-- The attributes would be updated later in the code
 hr_utility.trace('Going into(  for i in 1..p_approver_name.count): '|| l_proc);
  for i in 1..p_approver_name.count loop
    lv_item_name    := gv_item_name || to_char(I);
         OPEN csr_wiav(p_item_type,p_item_key,lv_item_name);
         hr_utility.trace('Going into Fetch after ( OPEN csr_wiav(p_item_type,p_item_key,lv_item_name)): '|| l_proc);
         FETCH csr_wiav into lv_dummy;
         IF csr_wiav%notfound then
           null;
         ELSE
           -- set the item attribute text value to DELETED
           wf_engine.SetItemAttrText
                            (itemtype    => p_item_type,
                             itemkey     => p_item_key,
                             aname       => lv_item_name,
                             avalue      => 'DELETED');
         END IF; -- for  csr_wiav%notfound
        CLOSE csr_wiav;
  end loop;
 hr_utility.trace('Out of (  for i in 1..p_approver_name.count): '|| l_proc);
-- end fix for bug # 1570998

-- update approvers data
 hr_utility.trace('Going into(  FOR I IN 1..p_approver_name.count): '|| l_proc);
  FOR I IN 1..p_approver_name.count
  LOOP
      IF p_approver_flag(I)='N' THEN
         ln_addntl_approvers := ln_addntl_approvers + 1;
        -- get the person_id for this person_name
         OPEN  lc_approver ( p_full_name=>p_approver_name(I));
         hr_utility.trace('Going into Fetch after (OPEN  lc_approver ( p_full_name=>p_approver_name(I))): '|| l_proc);
         FETCH lc_approver INTO ln_person_id;
         IF lc_approver%NOTFOUND
         THEN
            lv_exists := 'N';
            raise  gv_invalid_person;
         ELSE
            lv_exists:= 'Y';
         END IF ;
         CLOSE lc_approver;

        -- create the item attribute if it does not exist and update the value
         lv_item_name    := gv_item_name || to_char(I);

         OPEN csr_wiav(p_item_type,p_item_key,lv_item_name);
        hr_utility.trace('Going into Fetch after (OPEN csr_wiav(p_item_type,p_item_key,lv_item_name)): '|| l_proc);
         FETCH csr_wiav into lv_dummy;
         IF csr_wiav%notfound then
         -- item attribute does not exist so create it
            hr_approval_wf.create_item_attrib_if_notexist
                (p_item_type  => p_item_type,
                 p_item_key   => p_item_key,
                 p_name       => lv_item_name);
             wf_engine.SetItemAttrNumber
                            (itemtype    => p_item_type,
                             itemkey     => p_item_key,
                             aname       => lv_item_name,
                             avalue      => ln_person_id);
            wf_engine.SetItemAttrText
                            (itemtype    => p_item_type,
                             itemkey     => p_item_key,
                             aname       => lv_item_name,
                             avalue      => 'VALID');
         ELSE
           wf_engine.SetItemAttrNumber
                            (itemtype    => p_item_type,
                             itemkey     => p_item_key,
                             aname       => lv_item_name,
                             avalue      => ln_person_id);
           wf_engine.SetItemAttrText
                            (itemtype    => p_item_type,
                             itemkey     => p_item_key,
                             aname       => lv_item_name,
                             avalue      => 'VALID');

         END IF; -- for  csr_wiav%notfound
        CLOSE csr_wiav;


      END IF;-- p_approver_flag(I)='N'
  END LOOP;
 hr_utility.trace('Out of (  FOR I IN 1..p_approver_name.count): '|| l_proc);

-- update the number of additional approvers in the system

 OPEN csr_wiav(p_item_type,p_item_key,'ADDITIONAL_APPROVERS_NUMBER');
 hr_utility.trace('Going into Fetch after (OPEN csr_wiav(p_item_type,p_item_key,ADDITIONAL_APPROVERS_NUMBER)): '|| l_proc);
     FETCH csr_wiav into lv_dummy;
        IF csr_wiav%notfound THEN
 -- create new wf_item_attribute_value to hold the additional approvers number
         hr_approval_wf.create_item_attrib_if_notexist
                               (p_item_type  => p_item_type
                               ,p_item_key   => p_item_key
                               ,p_name   => 'ADDITIONAL_APPROVERS_NUMBER');

         wf_engine.SetItemAttrNumber
                    (itemtype    => p_item_type,
                     itemkey     => p_item_key,
                     aname       => 'ADDITIONAL_APPROVERS_NUMBER',
                     avalue      => ln_addntl_approvers );
        ELSE
         wf_engine.SetItemAttrNumber
                    (itemtype    => p_item_type,
                     itemkey     => p_item_key,
                     aname       => 'ADDITIONAL_APPROVERS_NUMBER',
                     avalue      => ln_addntl_approvers );
        END IF;
   CLOSE csr_wiav;

end if ; -- end if for AME check

-- update the data for the notifiers
--gv_notifier_name
 hr_utility.trace('Going into(  FOR I IN 1..p_notifier_name.count): '|| l_proc);
FOR I IN 1..p_notifier_name.count
LOOP
 -- get the person_id for this person_name
  OPEN  lc_approver ( p_full_name=>p_notifier_name(I));
  hr_utility.trace('Going into Fetch after (OPEN  lc_approver ( p_full_name=>p_notifier_name(I))): '|| l_proc);
  FETCH lc_approver INTO ln_person_id;
    IF lc_approver%NOTFOUND
    THEN
      lv_exists := 'N';
      raise  gv_invalid_person;
    ELSE
      lv_exists:= 'Y';
   END IF ;
 CLOSE lc_approver;

 -- create the item attribute if it does not exist and update the value
         lv_item_name    := gv_notifier_name || to_char(I);
         ln_notifiers    := ln_notifiers + 1;
         OPEN csr_wiav(p_item_type,p_item_key,lv_item_name);
         hr_utility.trace('Going into Fetch after (OPEN csr_wiav(p_item_type,p_item_key,lv_item_name)): '|| l_proc);
         FETCH csr_wiav into lv_dummy;
         IF csr_wiav%notfound then
         -- item attribute does not exist so create it
            hr_approval_wf.create_item_attrib_if_notexist
                (p_item_type  => p_item_type,
                 p_item_key   => p_item_key,
                 p_name       => lv_item_name);
             wf_engine.SetItemAttrNumber
                            (itemtype    => p_item_type,
                             itemkey     => p_item_key,
                             aname       => lv_item_name,
                             avalue      => ln_person_id);

         ELSE
           wf_engine.SetItemAttrNumber
                            (itemtype    => p_item_type,
                             itemkey     => p_item_key,
                             aname       => lv_item_name,
                             avalue      => ln_person_id);

         END IF; -- for  csr_wiav%notfound
        CLOSE csr_wiav;

 -- fetch if this notifier is onsubmittal
     --loop to check if the user has checked this index
     lv_exists := 'N';
      hr_utility.trace('Going into( FOR J IN 1..p_notify_onsubmit_flag.count): '|| l_proc);
     FOR J IN 1..p_notify_onsubmit_flag.count
     LOOP
        IF p_notify_onsubmit_flag(J)=I THEN
         lv_exists := 'Y';
         exit;
        ELSE
          lv_exists := 'N';
        END IF;
     END LOOP;
           hr_utility.trace('Out of ( FOR J IN 1..p_notify_onsubmit_flag.count): '|| l_proc);
     lv_notify:=lv_exists ||'|';

    lv_exists := 'N';
    hr_utility.trace('Going into(  FOR K IN 1..p_notify_onapproval_flag.count): '|| l_proc);
    FOR K IN 1..p_notify_onapproval_flag.count
    LOOP
        IF p_notify_onapproval_flag(K)=I THEN
        hr_utility.trace('In(  IF p_notify_onapproval_flag(K)=I): '|| l_proc);
         lv_exists := 'Y';
         exit;
        ELSE
          lv_exists := 'N';
        END IF;

    END LOOP;
    hr_utility.trace('Out of (  FOR K IN 1..p_notify_onapproval_flag.count): '|| l_proc);
    lv_notify:= lv_notify||lv_exists;

 -- set the notification flag for this notifier
   wf_engine.SetItemAttrText
                            (itemtype    => p_item_type,
                             itemkey     => p_item_key,
                             aname       => lv_item_name,
                             avalue      => lv_notify);

END LOOP;
hr_utility.trace('Out of (  FOR I IN 1..p_notifier_name.count): '|| l_proc);

 -- set the value for the number of notifiers
 -- ln_notifiers

 OPEN csr_wiav(p_item_type,p_item_key,'NOTIFIERS_NUMBER');
 hr_utility.trace('Going into Fetch after ( OPEN csr_wiav(p_item_type,p_item_key,NOTIFIERS_NUMBER) ): '|| l_proc);
     FETCH csr_wiav into lv_dummy;
        IF csr_wiav%notfound THEN
 -- create new wf_item_attribute_value to hold the additional approvers number
         hr_approval_wf.create_item_attrib_if_notexist
                               (p_item_type  => p_item_type
                               ,p_item_key   => p_item_key
                               ,p_name   => 'NOTIFIERS_NUMBER');

         wf_engine.SetItemAttrNumber
                    (itemtype    => p_item_type,
                     itemkey     => p_item_key,
                     aname       => 'NOTIFIERS_NUMBER',
                     avalue      => ln_notifiers );
        ELSE
         wf_engine.SetItemAttrNumber
                    (itemtype    => p_item_type,
                     itemkey     => p_item_key,
                     aname       => 'NOTIFIERS_NUMBER',
                     avalue      => ln_notifiers );
        END IF;
   CLOSE csr_wiav;

 -- set the gv_mode as re-enter
   OPEN csr_wiav(p_item_type,p_item_key,'APPROVAL_ENTRY_MODE');
    hr_utility.trace('Going into Fetch after ( OPEN csr_wiav(p_item_type,p_item_key,APPROVAL_ENTRY_MODE) ): '|| l_proc);
     FETCH csr_wiav into lv_dummy;
        IF csr_wiav%notfound THEN
     -- create new wf_item_attribute_value to hold
           hr_approval_wf.create_item_attrib_if_notexist
                               (p_item_type  => p_item_type
                               ,p_item_key   => p_item_key
                               ,p_name   => 'APPROVAL_ENTRY_MODE');

          wf_engine.SetItemAttrText
                    (itemtype    => p_item_type,
                     itemkey     => p_item_key,
                     aname       => 'APPROVAL_ENTRY_MODE',
                     avalue      => 'RE-ENTER');
         ELSE
         wf_engine.SetItemAttrText
                    (itemtype    => p_item_type,
                     itemkey     => p_item_key,
                     aname       => 'APPROVAL_ENTRY_MODE',
                     avalue      => 'RE-ENTER');
        END IF;
   CLOSE csr_wiav;

-- create new attributes for the transaction work flow process.
--  These will be accessed
-- from the workflow functions for dyanamic approval and notifications process.

-- attribute to hold the last_default approver from the heirarchy tree.
  OPEN csr_wiav(p_item_type,p_item_key,'LAST_DEFAULT_APPROVER');
 hr_utility.trace('Going into Fetch after ( OPEN csr_wiav(p_item_type,p_item_key,LAST_DEFAULT_APPROVER)): '|| l_proc);
     FETCH csr_wiav into lv_dummy;
        IF csr_wiav%notfound THEN
     -- create new wf_item_attribute_value to hold
           hr_approval_wf.create_item_attrib_if_notexist
                               (p_item_type  => p_item_type
                               ,p_item_key   => p_item_key
                               ,p_name   => 'LAST_DEFAULT_APPROVER');

          wf_engine.SetItemAttrNumber
                    (itemtype    => p_item_type,
                     itemkey     => p_item_key,
                     aname       => 'LAST_DEFAULT_APPROVER',
                     avalue      => NULL);
         ELSE
         wf_engine.SetItemAttrNumber
                    (itemtype    => p_item_type,
                     itemkey     => p_item_key,
                     aname       => 'LAST_DEFAULT_APPROVER',
                     avalue      => NULL);
        END IF;
   CLOSE csr_wiav;

-- Fix for the Bug #1255826
/*
-- check if the acitvity attribute for approval level exists
  OPEN csr_wfaav('HR_DYNA_APPR_LEVEL_ATR',p_act_id);
     FETCH csr_wfaav into lv_dummy;
        IF csr_wfaav%notfound THEN
         ln_approval_level :=NULL;
        ELSE
          ln_approval_level :=
                 wf_engine.GetActivityAttrNumber(
                               itemtype => p_item_type,
                               itemkey => p_item_key,
                               actid  => p_act_id,
                               aname => 'HR_DYNA_APPR_LEVEL_ATR');

        END IF;
   CLOSE csr_wfaav;

 -- attribute to hold the approval levels for confguration.
  OPEN csr_wiav(p_item_type,p_item_key,'APPROVAL_LEVEL');
     FETCH csr_wiav into lv_dummy;
        IF csr_wiav%notfound THEN
     -- create new wf_item_attribute_value to hold
           hr_approval_wf.create_item_attrib_if_notexist
                               (p_item_type  => p_item_type
                               ,p_item_key   => p_item_key
                               ,p_name   => 'APPROVAL_LEVEL');

        END IF;
   CLOSE csr_wiav;
  -- set the process level approval level
  IF ln_approval_level IS NOT NULL THEN
  wf_engine.SetItemAttrNumber
                    (itemtype    => p_item_type,
                     itemkey     => p_item_key,
                     aname       => 'APPROVAL_LEVEL',
                     avalue      => ln_approval_level);
  END IF;



-- attribute to hold the current default approver index .
  OPEN csr_wiav(p_item_type,p_item_key,'CURRENT_DEF_APPR_INDEX');
     FETCH csr_wiav into lv_dummy;
        IF csr_wiav%notfound THEN
     -- create new wf_item_attribute_value to hold
           hr_approval_wf.create_item_attrib_if_notexist
                               (p_item_type  => p_item_type
                               ,p_item_key   => p_item_key
                               ,p_name   => 'CURRENT_DEF_APPR_INDEX');

          wf_engine.SetItemAttrNumber
                    (itemtype    => p_item_type,
                     itemkey     => p_item_key,
                     aname       => 'CURRENT_DEF_APPR_INDEX',
                     avalue      => 0);
         ELSE
         wf_engine.SetItemAttrNumber
                    (itemtype    => p_item_type,
                     itemkey     => p_item_key,
                     aname       => 'CURRENT_DEF_APPR_INDEX',
                     avalue      => 0);
        END IF;
   CLOSE csr_wiav;

*/


 -- attribute to hold the current approver index .
  OPEN csr_wiav(p_item_type,p_item_key,'CURRENT_APPROVER_INDEX');
  hr_utility.trace('Going into Fetch after (OPEN csr_wiav(p_item_type,p_item_key,CURRENT_APPROVER_INDEX) ): '|| l_proc);
     FETCH csr_wiav into lv_dummy;
        IF csr_wiav%notfound THEN
     -- create new wf_item_attribute_value to hold
           hr_approval_wf.create_item_attrib_if_notexist
                               (p_item_type  => p_item_type
                               ,p_item_key   => p_item_key
                               ,p_name   => 'CURRENT_APPROVER_INDEX');

          wf_engine.SetItemAttrNumber
                    (itemtype    => p_item_type,
                     itemkey     => p_item_key,
                     aname       => 'CURRENT_APPROVER_INDEX',
                     avalue      => 0);
         ELSE
         wf_engine.SetItemAttrNumber
                    (itemtype    => p_item_type,
                     itemkey     => p_item_key,
                     aname       => 'CURRENT_APPROVER_INDEX',
                     avalue      => 0);
        END IF;
   CLOSE csr_wiav;

 -- attribute to hold the current onsubmit notifier index .
  OPEN csr_wiav(p_item_type,p_item_key,'CURRENT_ONSUBMIT_INDEX');
    hr_utility.trace('Going into Fetch after ( OPEN csr_wiav(p_item_type,p_item_key,CURRENT_ONSUBMIT_INDEX) ): '|| l_proc);
     FETCH csr_wiav into lv_dummy;
        IF csr_wiav%notfound THEN
     -- create new wf_item_attribute_value to hold
           hr_approval_wf.create_item_attrib_if_notexist
                               (p_item_type  => p_item_type
                               ,p_item_key   => p_item_key
                               ,p_name   => 'CURRENT_ONSUBMIT_INDEX');

          wf_engine.SetItemAttrNumber
                    (itemtype    => p_item_type,
                     itemkey     => p_item_key,
                     aname       => 'CURRENT_ONSUBMIT_INDEX',
                     avalue      => 0);
         ELSE
         wf_engine.SetItemAttrNumber
                    (itemtype    => p_item_type,
                     itemkey     => p_item_key,
                     aname       => 'CURRENT_ONSUBMIT_INDEX',
                     avalue      => 0);
        END IF;
   CLOSE csr_wiav;

-- attribute to hold the current onapproval notifier index .
  OPEN csr_wiav(p_item_type,p_item_key,'CURRENT_ONAPPROVAL_INDEX');
    hr_utility.trace('Going into Fetch after (  OPEN csr_wiav(p_item_type,p_item_key,CURRENT_ONAPPROVAL_INDEX) ): '|| l_proc);
     FETCH csr_wiav into lv_dummy;
        IF csr_wiav%notfound THEN
     -- create new wf_item_attribute_value to hold
           hr_approval_wf.create_item_attrib_if_notexist
                               (p_item_type  => p_item_type
                               ,p_item_key   => p_item_key
                               ,p_name   => 'CURRENT_ONAPPROVAL_INDEX');

          wf_engine.SetItemAttrNumber
                    (itemtype    => p_item_type,
                     itemkey     => p_item_key,
                     aname       => 'CURRENT_ONAPPROVAL_INDEX',
                     avalue      => 0);
         ELSE
         wf_engine.SetItemAttrNumber
                    (itemtype    => p_item_type,
                     itemkey     => p_item_key,
                     aname       => 'CURRENT_ONAPPROVAL_INDEX',
                     avalue      => 0);
        END IF;
   CLOSE csr_wiav;

hr_utility.set_location('Leaving: '|| l_proc,130);
EXCEPTION
   WHEN gv_invalid_person THEN
   hr_utility.set_location('EXCEPTION: '|| l_proc,555);
	if lc_approver%isopen then
	  close lc_approver;
	end if;
	if csr_wiav%isopen then
	  close csr_wiav;
	end if;
        raise;
   WHEN OTHERS THEN
   hr_utility.set_location('EXCEPTION: '|| l_proc,560);
     if lc_approver%isopen then
      close lc_approver;
     end if;
     if csr_wiav%isopen then
      close csr_wiav;
     end if;
     raise;
END COMMIT_DATA;





-- ---------------------------------------------------------------------------
-- public Procedure declarations
-- ---------------------------------------------------------------------------
--
-- ----------------------------------------------------------------------------
-- |------------------------------< validate_approvers>-------------------|
-- ----------------------------------------------------------------------------
--
-- This procedure validates the full_name against the person_id's for the given
-- effective date of the transaction.
--
PROCEDURE validate_approvers(
             p_item_type in varchar2,
             p_item_key  in varchar2,
             p_approvers_name   IN hr_util_misc_web.g_varchar2_tab_type,
             p_approver_flag    IN hr_util_misc_web.g_varchar2_tab_type,
             p_error_flag       OUT NOCOPY BOOLEAN )
 IS
   -- Local variables
   ln_approver_id per_people_f.person_id%TYPE DEFAULT NULL;
   lv_job_title   VARCHAR2(1000) DEFAULT NULL;
   ln_assignment_id NUMBER;
   ld_effective_date DATE;
   lv_exists      VARCHAR2(10) DEFAULT 'N';
   ln_job_id   NUMBER;
   l_curr_org_name VARCHAR2(100);
   l_curr_loc_name VARCHAR2(100);
   l_proc constant varchar2(100) := g_package || ' validate_approvers';

--
BEGIN
hr_utility.set_location('Entering: '|| l_proc,5);
-- validate the session
  hr_util_misc_web.validate_session(p_person_id => gn_person_id);

-- get user date format
  gv_user_date_format := hr_util_misc_web.get_user_date_format;


-- get session language code
  gv_language_code := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);

-- get effective date from Workflow Item Attribute
  gv_effective_date := wf_engine.getItemAttrText(
    itemtype  => p_item_type,
    itemkey   => p_item_key,
    aname     => 'CURRENT_EFFECTIVE_DATE');

  ld_effective_date := to_date(gv_effective_date, gv_user_date_format);


 -- first validate if selected person is  valid
 p_error_flag := FALSE ;


-- Loop through the names entered to see if we have a valid person_id
-- for each name
hr_utility.trace('Going into(FOR I IN 1..p_approvers_name.count): '|| l_proc);
     FOR I IN 1..p_approvers_name.count
     LOOP
        lv_job_title := NULL;
        OPEN lc_approver(p_approvers_name(I));
         hr_utility.trace('Going into Fetch after (OPEN lc_approver(p_approvers_name(I)) ): '|| l_proc);
         FETCH lc_approver INTO ln_approver_id ;
         IF lc_approver%NOTFOUND
         THEN
           p_error_flag := TRUE ;
           lv_exists := 'Y';

         ELSE
            gv_error_table(I).full_name := p_approvers_name(I);
            gv_error_table(I).person_id := ln_approver_id;
            gv_error_table(I).job_title := '';
            gv_error_table(I).error_exists := 'N';
            gv_error_table(I).default_approver:= p_approver_flag(I);
            lv_exists := 'N';
         END IF ;
         CLOSE lc_approver;

--     IF p_error_flag AND lv_exists = 'Y' THEN
            IF lv_exists = 'Y' THEN
             hr_utility.trace('In(IF lv_exist = Y): '|| l_proc);
        gv_error_table(I).full_name := p_approvers_name(I);
           gv_error_table(I).person_id := NULL;
           gv_error_table(I).job_title := NULL;
           gv_error_table(I).error_exists := 'Y';
           gv_error_table(I).default_approver:= p_approver_flag(I);
            -- add a row level error here
            hr_errors_api.addErrorToTable (
            p_rownumber  => i,
            p_errorMsg=>hr_util_misc_web.return_msg_text
                (p_message_name => 'HR_DA_MESG05_WEB'
                ,p_application_id => 'PER'));
      ELSE
                   hr_utility.trace('In else of (IF lv_exist = Y): '|| l_proc);
            gv_error_table(I).full_name := p_approvers_name(I);
            gv_error_table(I).person_id := ln_approver_id;
            gv_error_table(I).error_exists := 'N';
            gv_error_table(I).default_approver:= p_approver_flag(I);
             -- get the assignment id for this person
             OPEN gc_assignment_id (p_person_id=>ln_approver_id,
                                    p_effective_date=>ld_effective_date);
             hr_utility.trace('Going into Fetch after (OPEN gc_assignment_id (p_person_id...,p_effective_date..)): '|| l_proc);
             FETCH gc_assignment_id INTO ln_assignment_id;
             IF gc_assignment_id%NOTFOUND
             THEN
                 lv_job_title := NULL;
                 ln_assignment_id:= NULL;
             END IF;
             CLOSE  gc_assignment_id;

             -- get the job title for this assignment_id
             /*OPEN gc_job_details (p_assignment_id=>ln_assignment_id,
                                  p_effective_date=>ld_effective_date);
             FETCH gc_job_details INTO  lv_job_title;
             IF  gc_job_details%NOTFOUND
             THEN
                 lv_job_title := NULL;
                 ln_assignment_id:= NULL;
             END IF;
             CLOSE  gc_job_details;
           */
       -- get job id  gc_job_id
            OPEN gc_job_id (p_assignment_id=>ln_assignment_id,
                                  p_effective_date=>ld_effective_date);
 hr_utility.trace('Going into Fetch after ( OPEN gc_job_id (p_assignment_id.., p_effective_date) ): '|| l_proc);
             FETCH gc_job_id INTO  ln_job_id;
             IF  gc_job_id%NOTFOUND
             THEN
                 ln_job_id := NULL;
                 ln_assignment_id:= NULL;
             END IF;
             CLOSE  gc_job_id;


      hr_suit_match_utility_web.get_job_info
      (p_search_type   => gv_job_type,
       p_id            => ln_job_id,
       p_name          => lv_job_title,
       p_org_name      => l_curr_org_name,
       p_location_code => l_curr_loc_name);


             -- update the row record with proper job title
             gv_error_table(I).job_title := lv_job_title;
      END IF;

     END LOOP;


grt_approver_details_table := gv_error_table;
hr_utility.set_location('Leaving: '|| l_proc,35);
EXCEPTION
   WHEN OTHERS THEN
   hr_utility.set_location('EXCEPTION: '|| l_proc,555);
     if lc_approver%isopen then
      close lc_approver;
     end if;
     if csr_wiav%isopen then
      close csr_wiav;
     end if;
     if gc_assignment_id%isopen then
	close gc_assignment_id;
     end if;
     if gc_job_details%isopen then
	close gc_job_details;
     end if;
      if gc_job_id%isopen then
	close gc_job_id;
     end if;
     raise;
END validate_approvers;


-- ---------------------------------------------------------------------------
-- public Procedure declarations
-- ---------------------------------------------------------------------------
--
-- ----------------------------------------------------------------------------
-- |------------------------------< validate_notifiers>-------------------|
-- ----------------------------------------------------------------------------
--
-- This procedure validates the full_name against the person_id's for the given
-- effective date of the transaction.
--
PROCEDURE validate_notifiers(
             p_item_type in varchar2,
             p_item_key  in varchar2,
             p_notifier_name   IN hr_util_misc_web.g_varchar2_tab_type,
             p_notify_onsubmit_flag hr_util_misc_web.g_varchar2_tab_type
                             DEFAULT hr_util_misc_web.g_varchar2_tab_default,
             p_notify_onapproval_flag hr_util_misc_web.g_varchar2_tab_type
                             DEFAULT hr_util_misc_web.g_varchar2_tab_default,
             p_error_flag       OUT NOCOPY BOOLEAN )
 IS
   -- Local variables
   ln_notifier_id per_people_f.person_id%TYPE DEFAULT NULL;
   lv_job_title   VARCHAR2(1000) DEFAULT NULL;
   ln_assignment_id NUMBER;
   ld_effective_date DATE;
   lv_exists      VARCHAR2(10) DEFAULT 'N';
   ln_job_id   NUMBER;
   l_curr_org_name VARCHAR2(100);
   l_curr_loc_name VARCHAR2(100);
   l_proc constant varchar2(100) := g_package || ' validate_notifiers';

--
BEGIN

hr_utility.set_location('Entering: '|| l_proc,5);
-- validate the session
  hr_util_misc_web.validate_session(p_person_id => gn_person_id);

-- get user date format
  gv_user_date_format := hr_util_misc_web.get_user_date_format;


-- get session language code
  gv_language_code := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);

-- get effective date from Workflow Item Attribute
  gv_effective_date := wf_engine.getItemAttrText(
    itemtype  => p_item_type,
    itemkey   => p_item_key,
    aname     => 'CURRENT_EFFECTIVE_DATE');

  ld_effective_date := to_date(gv_effective_date, gv_user_date_format);


 -- first validate if selected person is  valid
 p_error_flag := FALSE ;


-- Loop through the names entered to see if we have a valid person_id
-- for each name
hr_utility.trace('Going into (FOR I IN 1..p_notifier_name.count): '|| l_proc);

     FOR I IN 1..p_notifier_name.count
     LOOP
         lv_job_title := NULL;
        OPEN lc_approver(p_notifier_name(I));
         hr_utility.trace('Going into Fetch after ( OPEN lc_approver(p_notifier_name(I))): '|| l_proc);
         FETCH lc_approver INTO ln_notifier_id ;
         IF lc_approver%NOTFOUND
         THEN
           p_error_flag := TRUE ;
           lv_exists := 'Y';

         ELSE
            grt_notifier_error_table(I).full_name := p_notifier_name(I);
            grt_notifier_error_table(I).person_id := ln_notifier_id;
            grt_notifier_error_table(I).job_title := '';
            grt_notifier_error_table(I).error_exists := 'N';
            -- fix for bug # 1570998
            --grt_notifier_error_table(I).on_submit:= p_notify_onsubmit_flag (I);
            lv_exists := 'N';
         END IF ;
         CLOSE lc_approver;

--     IF p_error_flag AND lv_exists = 'Y' THEN
            IF lv_exists = 'Y' THEN
             hr_utility.trace('In(IF lv_exists = Y): '|| l_proc);
        grt_notifier_error_table(I).full_name := p_notifier_name(I);
           grt_notifier_error_table(I).person_id := NULL;
           grt_notifier_error_table(I).job_title := NULL;
           grt_notifier_error_table(I).error_exists := 'Y';
           -- fix for bug # 1570998
           --grt_notifier_error_table(I).on_submit:= p_notify_onsubmit_flag (I);
            -- add a row level error here
            hr_errors_api.addErrorToTable (
            p_rownumber  => (100+i),
            p_errorMsg=>hr_util_misc_web.return_msg_text
                (p_message_name => 'HR_DA_MESG06_WEB'
                ,p_application_id => 'PER'));
      ELSE
                   hr_utility.trace('In else of (IF lv_exists = Y): '|| l_proc);
            grt_notifier_error_table(I).full_name := p_notifier_name(I);
            grt_notifier_error_table(I).person_id := ln_notifier_id;
            grt_notifier_error_table(I).error_exists := 'N';
            -- fix for bug # 1570998
            --grt_notifier_error_table(I).on_submit:= p_notify_onsubmit_flag (I);
lv_job_title := hr_dynamic_approval_web.get_job_details
                     (p_person_id =>ln_notifier_id,
                      p_assignment_id=>ln_assignment_id,
                      p_effective_date=>ld_effective_date
                      );

             -- update the row record with proper job title
             grt_notifier_error_table(I).job_title := lv_job_title;
      END IF;

     END LOOP;
hr_utility.trace('Out of (FOR I IN 1..p_notifier_name.count): '|| l_proc);
hr_utility.set_location('Leaving: '|| l_proc,30);
grt_notifier_details_table := grt_notifier_error_table;

EXCEPTION
   WHEN OTHERS THEN
   hr_utility.set_location('EXCEPTION: '|| l_proc,555);
     if lc_approver%isopen then
        close lc_approver;
     end if;
   raise;
END validate_notifiers;






/*
||==========================================================================
|| PROCEDURE: get_wf_attributes
||--------------------------------------------------------------------------
||
|| Description:
||
||
|| Access Status:
||     Public.
||
||==========================================================================
*/





PROCEDURE get_wf_attributes (
             p_item_type  in wf_items.item_type%TYPE
            ,p_item_key   in wf_items.item_key%TYPE
            ,p_actid      in number
          )
 AS
   lv_dynamic_approval_mode        VARCHAR2(100) DEFAULT 'HR_DYNA_APPROVAL_ATR';
   ln_approval_level               VARCHAR2(100) DEFAULT 'HR_DYNA_APPR_LEVEL_ATR';
   lv_dummy                        VARCHAR2(10);
 --local variables
l_proc constant varchar2(100) := g_package || ' get_wf_attributes';
 BEGIN

hr_utility.set_location('Entering: '|| l_proc,5);
   IF hr_mee_workflow_service.check_web_page_code(
     p_item_type => p_item_type,
     p_item_key  => p_item_key,
     p_actid     => p_actid,
     p_web_page_section_code => lv_dynamic_approval_mode)
  THEN
     grt_wf_attributes_rec.dynamic_approval_mode :=
        hr_mee_workflow_service.get_web_page_code(
          p_item_type => p_item_type,
          p_item_key  => p_item_key,
          p_actID     => p_actid,
          p_web_page_section_code => lv_dynamic_approval_mode
        );
  END IF;

  IF hr_mee_workflow_service.check_web_page_code(
     p_item_type => p_item_type,
     p_item_key  => p_item_key,
     p_actid     => p_actid,
     p_web_page_section_code => ln_approval_level)
  THEN
     grt_wf_attributes_rec.approval_level :=
        hr_mee_workflow_service.get_web_page_code(
          p_item_type => p_item_type,
          p_item_key  => p_item_key,
          p_actID     => p_actid,
          p_web_page_section_code => ln_approval_level
        );
  END IF;
-- The   hr_mee_workflow_service.get_web_page_code is not returning values
-- need to invesitgate further and debug. Making a direct call to wf_engine
-- package.
-- check if the acitvity attribute for approval level exists
  OPEN csr_wfaav(ln_approval_level,p_actid );
   hr_utility.trace('Going into Fetch after ( OPEN csr_wfaav(ln_approval_level,p_actid ) ): '|| l_proc);
     FETCH csr_wfaav into lv_dummy;
        IF csr_wfaav%notfound THEN
         grt_wf_attributes_rec.approval_level :=NULL;
        ELSE
          grt_wf_attributes_rec.approval_level :=
                 wf_engine.GetActivityAttrNumber(
                               itemtype => p_item_type,
                               itemkey => p_item_key,
                               actid  => p_actid,
                               aname => ln_approval_level);

        END IF;
   CLOSE csr_wfaav;

hr_utility.set_location('Leaving: '|| l_proc,15);


  EXCEPTION
    WHEN OTHERS THEN
    hr_utility.set_location('EXCEPTION: '|| l_proc,555);
     if csr_wfaav%isopen then
      close csr_wfaav;
     end if;
    raise;

 END get_wf_attributes;
-- Methods calling AME
/*-----------------------------------------------------------------------

|| PROCEDURE         : get_ame_default_approvers
||
||
||-----------------------------------------------------------------------*/

PROCEDURE get_ame_default_approvers(
    p_approver_name OUT NOCOPY hr_util_misc_web.g_varchar2_tab_type,
    p_approver_flag OUT NOCOPY hr_util_misc_web.g_varchar2_tab_type,
    p_item_type     IN wf_items.item_type%TYPE,
    p_item_key      IN wf_items.item_key%TYPE)

AS

--local variables
lrt_person_details_rec_table         hr_dynamic_approval_web.t_person_table;
lv_creator_person_id                 per_people_f.person_id%TYPE ;
lv_forward_from_id                   per_people_f.person_id%TYPE DEFAULT NULL;
lv_forward_to_id                     per_people_f.person_id%TYPE DEFAULT NULL;
lv_current_forward_to_id             per_people_f.person_id%TYPE ;
lv_current_forward_from_id           per_people_f.person_id%TYPE ;
lv_result                            VARCHAR2(20) DEFAULT 'N';
ln_approver_index                    NUMBER DEFAULT 1;
lv_full_name                         per_people_f.full_name%TYPE;
lv_job_title                         per_jobs.name%TYPE;
ln_assignment_id                      per_assignments_f.ASSIGNMENT_ID%TYPE;
ld_effective_date                     per_assignments_f.EFFECTIVE_START_DATE%TYPE;
lrt_assignment_details               hr_misc_web.grt_assignment_details;
l_proc constant varchar2(100) := g_package || ' get_ame_default_approvers';
--my new variables
lv_approver_name                 hr_util_misc_web.g_varchar2_tab_type   DEFAULT
                                               hr_util_misc_web.g_varchar2_tab_default;
lv_approver_flag                 hr_util_misc_web.g_varchar2_tab_type   DEFAULT
                                               hr_util_misc_web.g_varchar2_tab_default;
ln_job_id   NUMBER;
l_curr_org_name VARCHAR2(100);
l_curr_loc_name VARCHAR2(100);

--bug #1964924
ln_approval_level number;

-- Variables for AME API
c_application_id integer;
c_transaction_id varchar2(25);
c_transaction_type varchar2(25);
c_next_approver_rec ame_util.approverRecord;
c_default_approvers ame_util.approversTable;

v_approvalProcessCompleteYNOut varchar2(10);
v_default_approvers ame_util.approversTable2;


BEGIN
hr_utility.set_location('Entering: '|| l_proc,5);

  gn_person_id := wf_engine.GetItemAttrNumber
                         (itemtype      => p_item_type
                         ,itemkey       => p_item_key
                         ,aname         => 'CREATOR_PERSON_ID');

  -- Get AME related data from WF attributes
  -- get the AME transaction type and app id
  c_application_id :=wf_engine.GetItemAttrNumber(itemtype => p_item_type ,
                                               itemkey  => p_item_key,
                                               aname => 'HR_AME_APP_ID_ATTR');


  c_application_id := nvl(c_application_id,800);

  c_transaction_id := wf_engine.GetItemAttrNumber(itemtype => p_item_type ,
                                               itemkey  => p_item_key,
                                               aname => 'TRANSACTION_ID');



  c_transaction_type := wf_engine.GetItemAttrText(itemtype => p_item_type ,
                                               itemkey  => p_item_key,
                                               aname => 'HR_AME_TRAN_TYPE_ATTR');


  -- check if we need to call AME for default approvers.

  if(c_transaction_type is not  null) then
/*    ame_api.getAllApprovers(applicationIdIn =>c_application_id,
                            transactionIdIn=>c_transaction_id,
                            transactionTypeIn =>c_transaction_type,
                            approversOut=>c_default_approvers);*/

   ame_api2.getAllApprovers7(applicationIdIn =>c_application_id,
                             transactionTypeIn=>c_transaction_type,
                             transactionIdIn =>c_transaction_id,
                             approvalProcessCompleteYNOut=>v_approvalProcessCompleteYNOut ,
                             approversOut=>v_default_approvers );

	ame_util.apprTable2ToApprTable(approversTable2In => v_default_approvers,
                       approversTableOut => c_default_approvers);


  end if;


  -- reset the gn_approver_index each time this procedure is called
  gn_approver_index := 1;
hr_utility.trace('Going into( for i in 1..c_default_approvers.count): '|| l_proc);
  for i in 1..c_default_approvers.count  LOOP
    lv_job_title:=NULL;
    -- get the next approver from the list
    -- Check if the AME approver is authority approver
    if(c_default_approvers(i).api_insertion <> ame_util.apiInsertion) then
      lv_forward_to_id := c_default_approvers(i).person_id;
      -- get assignment id for the approver
      lrt_assignment_details := hr_misc_web.get_assignment_id (p_person_id =>lv_forward_to_id);
      ln_assignment_id := lrt_assignment_details.assignment_id;
      -- get name and job title for this person id
      lrt_assignment_details := hr_misc_web.get_assignment_details(p_assignment_id => ln_assignment_id,
                                                                   p_effective_date =>ld_effective_date);

      lv_full_name := lrt_assignment_details.person_full_name;

      lv_job_title := hr_dynamic_approval_web.get_job_details(p_person_id =>lv_forward_to_id,
                                                              p_assignment_id=>ln_assignment_id,
                                                              p_effective_date=>ld_effective_date);
      -- Insert the data into the person_details_rec_table
      grt_person_details_rec_table(gn_approver_index).person_id       := lv_forward_to_id ;
      grt_person_details_rec_table(gn_approver_index).full_name       := lv_full_name;
      grt_person_details_rec_table(gn_approver_index).job_title       := lv_job_title;
      grt_person_details_rec_table(gn_approver_index).default_approver:= 'Y';

       gn_approver_index  := gn_approver_index + 1;
    END IF;
  END LOOP;
hr_utility.trace('Out of ( for i in 1..c_default_approvers.count): '|| l_proc);
  -- for the out parameters
hr_utility.trace('Going into( FOR I IN 1..grt_person_details_rec_table.count ): '|| l_proc);
  FOR I IN 1..grt_person_details_rec_table.count  LOOP
    p_approver_name(I) := grt_person_details_rec_table(I).full_name;
    p_approver_flag(I) := grt_person_details_rec_table(I).default_approver;
  END LOOP;
hr_utility.trace('Out of ( FOR I IN 1..grt_person_details_rec_table.count ): '|| l_proc);
  grt_approver_details_table := grt_person_details_rec_table;
hr_utility.set_location('Leaving: '|| l_proc,30);
EXCEPTION
  WHEN OTHERS THEN
  hr_utility.set_location('EXCEPTION: '|| l_proc,555);
    raise;
END get_ame_default_approvers;

-- get_all_ame_approvers

/*-----------------------------------------------------------------------

|| PROCEDURE         : get_all_ame_approvers
||
||
||-----------------------------------------------------------------------*/

PROCEDURE get_all_ame_approvers(p_approver_name  hr_util_misc_web.g_varchar2_tab_type
                                  DEFAULT hr_util_misc_web.g_varchar2_tab_default,
                            p_approver_flag  hr_util_misc_web.g_varchar2_tab_type
                                  DEFAULT  hr_util_misc_web.g_varchar2_tab_default,
                            p_item_type IN wf_items.item_type%TYPE,
                            p_item_key         IN wf_items.item_key%TYPE,
                            p_effective_date   IN DATE DEFAULT SYSDATE)

AS

--local variables
ln_approver_index           NUMBER DEFAULT 1;
ln_approver_list_index      NUMBER DEFAULT 0;
ln_num_of_add_apprs         NUMBER DEFAULT 0;
lv_item_name                VARCHAR2(100) DEFAULT 'ADDITIONAL_APPROVER_';
l_dummy                     VARCHAR2(100);
ln_def_app_index            NUMBER DEFAULT 1;
ln_person_id                per_people_f.person_id%TYPE;
ln_assignment_id            per_assignments_f.assignment_id%TYPE;
lrt_assignment_details      hr_misc_web.grt_assignment_details;
lv_approver_deleted         VARCHAR2(100) DEFAULT NULL;
lv_default_approver         VARCHAR2(100) DEFAULT 'NO';
ln_error_count              NUMBER DEFAULT 1;
lv_job_title                VARCHAR2(1000);
lv_approver_name            hr_util_misc_web.g_varchar2_tab_type
                              DEFAULT hr_util_misc_web.g_varchar2_tab_default;
lv_approver_flag            hr_util_misc_web.g_varchar2_tab_type
                                  DEFAULT  hr_util_misc_web.g_varchar2_tab_default;
ln_job_id   NUMBER;
l_curr_org_name VARCHAR2(100);
l_curr_loc_name VARCHAR2(100);
l_proc constant varchar2(100) := g_package || ' et_all_ame_approvers';
-- Variables for AME API
c_application_id integer;
c_transaction_id varchar2(25);
c_transaction_type varchar2(25);
c_next_approver_rec ame_util.approverRecord;
c_all_approvers ame_util.approversTable;


v_approvalProcessCompleteYNOut varchar2(10);
v_all_approvers ame_util.approversTable2;



BEGIN
hr_utility.set_location('Entering: '|| l_proc,5);

IF gv_mode='RE-ENTER' THEN
hr_utility.trace('In (IF gv_mode=RE-ENTER): '|| l_proc);

    -- Get AME related data from WF attributes
    -- get the AME transaction type and app id
    c_application_id :=wf_engine.GetItemAttrNumber(itemtype => p_item_type ,
                                                   itemkey  => p_item_key,
                                                   aname => 'HR_AME_APP_ID_ATTR');


    c_application_id := nvl(c_application_id,800);

    c_transaction_id := wf_engine.GetItemAttrNumber(itemtype => p_item_type ,
                                               itemkey  => p_item_key,
                                               aname => 'TRANSACTION_ID');



    c_transaction_type := wf_engine.GetItemAttrText(itemtype => p_item_type ,
                                               itemkey  => p_item_key,
                                               aname => 'HR_AME_TRAN_TYPE_ATTR');


    -- check if we need to call AME for default approvers.

    if(c_transaction_type is not  null) then
     /* ame_api.getAllApprovers(applicationIdIn =>c_application_id,
                              transactionIdIn=>c_transaction_id,
                              transactionTypeIn =>c_transaction_type,
                              approversOut=>c_all_approvers);*/
  ame_api2.getAllApprovers7(applicationIdIn =>c_application_id,
                             transactionTypeIn=>c_transaction_type,
                             transactionIdIn =>c_transaction_id,
                             approvalProcessCompleteYNOut=>v_approvalProcessCompleteYNOut ,
                             approversOut=>v_all_approvers );

	ame_util.apprTable2ToApprTable(approversTable2In => v_all_approvers,
                       approversTableOut => c_all_approvers);

    end if;

    ln_approver_index := c_all_approvers.count;
      hr_utility.trace('Going into (FOR I IN 1..ln_approver_index ): '|| l_proc);
    FOR I IN 1..ln_approver_index  LOOP
     -- 11510 specific changes, bug 3841261
     if(nvl(c_all_approvers(i).approval_status,'NULL') not in(ame_util.suppressedStatus,ame_util.repeatedStatus)) then
       ln_approver_list_index:= ln_approver_list_index + 1;
       lv_job_title := NULL;
       ln_person_id := c_all_approvers(i).person_id;

       -- get the assignment id
       lrt_assignment_details := hr_misc_web.get_assignment_id(p_person_id => ln_person_id);
       ln_assignment_id       := lrt_assignment_details.assignment_id;
       -- get name and job title for this person id
        lrt_assignment_details := hr_misc_web.get_assignment_details(p_assignment_id => ln_assignment_id,
                                                                    p_effective_date =>p_effective_date);

       grt_approver_details_table(ln_approver_list_index).full_name  := lrt_assignment_details.person_full_name;
       grt_approver_details_table(ln_approver_list_index).person_id  :=ln_person_id;
       grt_approver_details_table(ln_approver_list_index).job_title  :=hr_dynamic_approval_web.get_job_details
                                                             (p_person_id =>ln_person_id,
                                                              p_assignment_id=>ln_assignment_id,
                                                              p_effective_date=>p_effective_date);


        if(c_all_approvers(i).api_insertion <> ame_util.apiInsertion) then
          grt_approver_details_table(ln_approver_list_index).default_approver := 'Y';
        ELSE
          grt_approver_details_table(ln_approver_list_index).default_approver := 'N';
        END IF;  -- for lv_default_approver
      end if;
    END LOOP;
hr_utility.trace('Out of  (FOR I IN 1..ln_approver_index ): '|| l_proc);
--//grt_person_details_rec_table :=  grt_approver_details_table;

END IF;  -- for the p_mode

hr_utility.trace('Going into (FOR I IN 1..ln_approver_name.count ): '|| l_proc);
FOR I IN 1..p_approver_name.count  LOOP
    lv_job_title := NULL;
    IF hr_errors_api.errorExists  THEN
      grt_approver_details_table(I).full_name  := gv_error_table(ln_error_count).full_name;
      grt_approver_details_table(I).person_id  := gv_error_table(ln_error_count).person_id;
      grt_approver_details_table(I).job_title  := gv_error_table(ln_error_count).job_title;
      grt_approver_details_table(I).error_exists:= gv_error_table(ln_error_count).error_exists;
      grt_approver_details_table(I).default_approver := gv_error_table(ln_error_count).default_approver;
      ln_error_count := ln_error_count + 1;
    ELSE
      -- get the person id for this person
      OPEN lc_approver ( p_full_name=>p_approver_name(I));
       hr_utility.trace('Going into Fetch after ( OPEN lc_approver ( p_full_name=>p_approver_name(I)) ): '|| l_proc);
      FETCH lc_approver INTO ln_person_id ;
        IF lc_approver%NOTFOUND THEN
          lv_job_title := NULL;
          ln_assignment_id:= NULL;
        END IF;
      CLOSE  lc_approver;

    lrt_assignment_details := hr_misc_web.get_assignment_id(p_person_id => ln_person_id);
    ln_assignment_id       := lrt_assignment_details.assignment_id;
    -- get name and job title for this person id
    lrt_assignment_details := hr_misc_web.get_assignment_details(
                                       p_assignment_id => ln_assignment_id,
                                       p_effective_date =>p_effective_date);

    lv_job_title := hr_dynamic_approval_web.get_job_details
                     (p_person_id =>ln_person_id,
                      p_assignment_id=>ln_assignment_id,
                      p_effective_date=>p_effective_date
                      );

    grt_approver_details_table(I).person_id := ln_person_id;
    grt_approver_details_table(I).full_name  := p_approver_name(I);
    grt_approver_details_table(I).job_title  :=lv_job_title;
    grt_approver_details_table(I).default_approver := p_approver_flag(I);
 END IF; -- for hr_errors_api.errorExists
END LOOP;
hr_utility.trace('Out of  (FOR I IN 1..ln_approver_name.count ): '|| l_proc);
hr_utility.set_location('Leaving: '|| l_proc,40);

EXCEPTION
    WHEN OTHERS THEN
    hr_utility.set_location('EXCEPTION: '|| l_proc,555);
    if 	lc_approver%isopen then
	close lc_approver;
    end if;
    raise;
END get_all_ame_approvers;





/*-----------------------------------------------------------------------

|| PROCEDURE         : get_default_approvers_list
||
|| This is a wrapper procedure to get_default_approvers to return
|| the list of default approvers to a java oracle.sql.ARRAY object
||
||
||
||-----------------------------------------------------------------------*/

PROCEDURE get_default_approvers_list(
    p_item_type     IN wf_items.item_type%TYPE,
    p_item_key      IN wf_items.item_key%TYPE,
    p_default_approvers_list OUT NOCOPY hr_dynamic_approver_list_ss)

AS

--local variables
l_approver_name                 hr_util_misc_web.g_varchar2_tab_type;
l_approver_flag                 hr_util_misc_web.g_varchar2_tab_type;
l_default_approvers_list        hr_dynamic_approver_list_ss := hr_dynamic_approver_list_ss();
l_default_approver              hr_dynamic_approver_ss;
l_proc constant varchar2(100) := g_package || ' get_default_approvers_list';
BEGIN
 hr_utility.set_location('Entering: '|| l_proc,5);
  -- remove all rows from person details table

  grt_person_details_rec_table.DELETE;
  grt_approver_details_table.DELETE;

 -- set the gv_mode as this is needed for pl/sql compatibility
   gv_mode:='RE-ENTER';

  -- repopulate the table

  hr_dynamic_approval_web.get_all_approvers(
    p_approver_name =>l_approver_name,
    p_approver_flag=>l_approver_flag,
    p_item_type    =>p_item_type,
    p_item_key     =>p_item_key
        );

  grt_person_details_rec_table:= grt_approver_details_table;

  -- copy parameters into l_default_approvers_list

hr_utility.trace('Going into (FOR I IN 1..grt_person_details_rec_table.count): '|| l_proc);
 FOR I IN 1..grt_person_details_rec_table.count
 LOOP

  l_default_approver := hr_dynamic_approver_ss(
                                       grt_person_details_rec_table(I).full_name,
                                       grt_person_details_rec_table(I).person_id,
                                       grt_person_details_rec_table(I).job_title,
                                       grt_person_details_rec_table(I).default_approver,
                                       grt_person_details_rec_table(I).error_exists);

  -- add new row to list
  l_default_approvers_list.EXTEND;

  -- add to list
  l_default_approvers_list(I) := l_default_approver;

 END LOOP;
hr_utility.trace('Out of  (FOR I IN 1..grt_person_details_rec_table.count): '|| l_proc);
 -- set out parameter
 p_default_approvers_list := l_default_approvers_list;
 hr_utility.set_location('Leaving: '|| l_proc,20);

exception
when others then
hr_utility.set_location('EXCEPTION: '|| l_proc,555);
 raise;

END get_default_approvers_list;




PROCEDURE get_default_approvers_list(
    p_item_type     IN wf_items.item_type%TYPE,
    p_item_key      IN wf_items.item_key%TYPE,
    p_default_approvers_list OUT NOCOPY hr_dynamic_approver_list_ss,
    p_error_message OUT NOCOPY varchar)

AS

--local variables
l_approver_name                 hr_util_misc_web.g_varchar2_tab_type;
l_approver_flag                 hr_util_misc_web.g_varchar2_tab_type;
l_default_approvers_list        hr_dynamic_approver_list_ss := hr_dynamic_approver_list_ss();
l_default_approver              hr_dynamic_approver_ss;
l_proc constant varchar2(100) := g_package || ' get_default_approvers_list_extra';
l_error_message long default null;
BEGIN
 hr_utility.set_location('Entering: '|| l_proc,5);
  -- remove all rows from person details table

  grt_person_details_rec_table.DELETE;
  grt_approver_details_table.DELETE;

 -- set the gv_mode as this is needed for pl/sql compatibility
   gv_mode:='RE-ENTER';

  -- repopulate the table

  hr_dynamic_approval_web.get_all_approvers(
    p_approver_name =>l_approver_name,
    p_approver_flag=>l_approver_flag,
    p_item_type    =>p_item_type,
    p_item_key     =>p_item_key
        );

  grt_person_details_rec_table:= grt_approver_details_table;

  -- copy parameters into l_default_approvers_list

hr_utility.trace('Going into (FOR I IN 1..grt_person_details_rec_table.count): '|| l_proc);
 FOR I IN 1..grt_person_details_rec_table.count
 LOOP

  l_default_approver := hr_dynamic_approver_ss(
                                       grt_person_details_rec_table(I).full_name,
                                       grt_person_details_rec_table(I).person_id,
                                       grt_person_details_rec_table(I).job_title,
                                       grt_person_details_rec_table(I).default_approver,
                                       grt_person_details_rec_table(I).error_exists);

  -- add new row to list
  l_default_approvers_list.EXTEND;

  -- add to list
  l_default_approvers_list(I) := l_default_approver;

 END LOOP;
hr_utility.trace('Out of  (FOR I IN 1..grt_person_details_rec_table.count): '|| l_proc);
 -- set out parameter
 p_default_approvers_list := l_default_approvers_list;
 hr_utility.set_location('Leaving: '|| l_proc,20);

exception
when others then
hr_utility.set_location('EXCEPTION: '|| l_proc,555);
 -- set error message
l_error_message := hr_utility.get_message;

IF (l_error_message IS NOT NULL) THEN
 p_error_message := l_error_message;
END IF;
END get_default_approvers_list;


/*-----------------------------------------------------------------------

|| PROCEDURE         : get_default_approvers
||
||
||-----------------------------------------------------------------------*/

PROCEDURE get_default_approvers(
    p_approver_name OUT NOCOPY hr_util_misc_web.g_varchar2_tab_type,
    p_approver_flag OUT NOCOPY hr_util_misc_web.g_varchar2_tab_type,
    p_item_type     IN wf_items.item_type%TYPE,
    p_item_key      IN wf_items.item_key%TYPE)

AS

--local variables
lrt_person_details_rec_table         hr_dynamic_approval_web.t_person_table;
lv_creator_person_id                 per_people_f.person_id%TYPE ;
lv_forward_from_id                   per_people_f.person_id%TYPE DEFAULT NULL;
lv_forward_to_id                     per_people_f.person_id%TYPE DEFAULT NULL;
lv_current_forward_to_id             per_people_f.person_id%TYPE ;
lv_current_forward_from_id           per_people_f.person_id%TYPE ;
lv_result                            VARCHAR2(20) DEFAULT 'N';
ln_approver_index                    NUMBER DEFAULT 1;
lv_full_name                         per_people_f.full_name%TYPE;
lv_job_title                         per_jobs.name%TYPE;
ln_assignment_id                      per_assignments_f.ASSIGNMENT_ID%TYPE;
ld_effective_date                     per_assignments_f.EFFECTIVE_START_DATE%TYPE;
lrt_assignment_details               hr_misc_web.grt_assignment_details;
l_proc constant varchar2(100) := g_package || ' get_default_approvers';
--my new variables
lv_approver_name                 hr_util_misc_web.g_varchar2_tab_type   DEFAULT
                                               hr_util_misc_web.g_varchar2_tab_default;
lv_approver_flag                 hr_util_misc_web.g_varchar2_tab_type   DEFAULT
                                               hr_util_misc_web.g_varchar2_tab_default;
ln_job_id   NUMBER;
l_curr_org_name VARCHAR2(100);
l_curr_loc_name VARCHAR2(100);

--bug #1964924
ln_approval_level number;

-- Variables for AME API
c_application_id integer;
c_transaction_id varchar2(25);
c_transaction_type varchar2(25);
c_next_approver_rec ame_util.approverRecord;
--c_default_approvers ame_util.approversTable;

v_approvalProcessCompleteYNOut varchar2(10);
v_default_approvers  ame_util.approversTable2;

BEGIN
hr_utility.set_location('Entering: '|| l_proc,5);
-- validate the session
-- ******************************************************************************
-- commented out for v 4 by pzwalker - replaced with GetItemAttrNumber call
--  hr_util_misc_web.validate_session(p_person_id => gn_person_id);
    gn_person_id := wf_engine.GetItemAttrNumber
                         (itemtype      => p_item_type
                         ,itemkey       => p_item_key
                         ,aname         => 'CREATOR_PERSON_ID');


-- Get AME related data from WF attributes
-- get the AME transaction type and app id
c_application_id :=wf_engine.GetItemAttrNumber(itemtype => p_item_type ,
                                               itemkey  => p_item_key,
                                               aname => 'HR_AME_APP_ID_ATTR');


c_application_id := nvl(c_application_id,800);

c_transaction_id := wf_engine.GetItemAttrNumber(itemtype => p_item_type ,
                                               itemkey  => p_item_key,
                                               aname => 'TRANSACTION_ID');



c_transaction_type := wf_engine.GetItemAttrText(itemtype => p_item_type ,
                                               itemkey  => p_item_key,
                                               aname => 'HR_AME_TRAN_TYPE_ATTR');


-- check if we need to call AME for default approvers.

if(c_transaction_type is not  null) then
  /*
    ame_api.getAllApprovers(applicationIdIn =>c_application_id,
                            transactionIdIn=>c_transaction_id,
                            transactionTypeIn =>c_transaction_type,
                            approversOut=>c_default_approvers);
     */

    ame_api2.getAllApprovers7(applicationIdIn =>c_application_id,
                             transactionTypeIn=>c_transaction_type,
                             transactionIdIn =>c_transaction_id,
                             approvalProcessCompleteYNOut=>v_approvalProcessCompleteYNOut ,
                             approversOut=>v_default_approvers );

end if;

-- bug # 1964924
ln_approval_level:= wf_engine.GetItemAttrNumber
                         (itemtype      => p_item_type
                         ,itemkey       => p_item_key
                         ,aname         => 'APPROVAL_LEVEL');

-- reset the gn_approver_index each time this procedure is called
    gn_approver_index := 1;
-- get assignment id and effective date

hr_mee_workflow_service.get_assignment_details(
      p_item_type => p_item_type
      ,p_item_key => p_item_key
      ,p_assignment_id => ln_assignment_id
      ,p_effective_date => ld_effective_date);

-- intialise startup details
  lv_creator_person_id := gn_person_id;
  lv_current_forward_from_id := lv_creator_person_id;
  lv_current_forward_to_id   := lv_creator_person_id;

    -- -----------------------------------------------------------------------
    -- expose the wf control variables to the custom package
    -- -----------------------------------------------------------------------
    set_custom_wf_globals
      (p_itemtype => p_item_type
      ,p_itemkey  => p_item_key);

-- Get all the approvers from the Custom Approval Package.
hr_utility.trace('Going into(WHILE lv_result <> Y): '|| l_proc);
WHILE lv_result <> 'Y'
 LOOP
   lv_job_title:=NULL;
 -- Check for final approver
   BEGIN
   lv_result := hr_approval_custom.Check_Final_approver
                  (p_forward_to_person_id       => lv_forward_to_id
                  ,p_person_id                  => lv_creator_person_id );
   EXCEPTION WHEN OTHERS THEN
   hr_utility.set_location('EXCEPTION: '|| l_proc,555);
    raise;
   END;

  -- Check if there is any error
  IF lv_result='E' THEN
  -- Add Error to the Error Table
  NULL;
  END IF;

   IF lv_result='Y' THEN
   hr_utility.trace('In (IF lv_result=Y): '|| l_proc);
       EXIT;
   END IF;

 -- get the next approver from the custom package

    lv_forward_to_id := hr_approval_custom.Get_Next_Approver
        (p_person_id => lv_current_forward_to_id);



 -- Check if the person id returned is NULL
 IF lv_forward_to_id IS NULL THEN
    hr_utility.trace('In ( IF lv_forward_to_id IS NULL): '|| l_proc);
    lv_result:='Y';
 ELSE
     hr_utility.trace('In else of  ( IF lv_forward_to_id IS NULL): '|| l_proc);
    -- set forward from to old forward to
 lv_current_forward_to_id := lv_forward_to_id;

-- get assignment id for the approver
    lrt_assignment_details := hr_misc_web.get_assignment_id (
                                              p_person_id =>lv_forward_to_id);
ln_assignment_id := lrt_assignment_details.assignment_id;
-- get name and job title for this person id
lrt_assignment_details := hr_misc_web.get_assignment_details(
                                        p_assignment_id => ln_assignment_id,
                                        p_effective_date =>ld_effective_date
                                        );

lv_full_name := lrt_assignment_details.person_full_name;
lv_job_title := hr_dynamic_approval_web.get_job_details
                     (p_person_id =>lv_forward_to_id,
                      p_assignment_id=>ln_assignment_id,
                      p_effective_date=>ld_effective_date
                      );
 -- Insert the data into the person_details_rec_table
    grt_person_details_rec_table(gn_approver_index).person_id       := lv_forward_to_id ;
    grt_person_details_rec_table(gn_approver_index).full_name       := lv_full_name;
    grt_person_details_rec_table(gn_approver_index).job_title       := lv_job_title;
    grt_person_details_rec_table(gn_approver_index).default_approver:= 'Y';

-- bug # 1964924
 if(ln_approval_level>0 and ln_approval_level=grt_person_details_rec_table.count) then
 hr_utility.trace('In (if(ln_approval_level>0 and ln_approval_level=grt_person_details_rec_table.count)): '|| l_proc);
 exit;
 end if;

    -- Increment approver Index
  --  ln_approver_index := ln_approver_index + 1;
   gn_approver_index  := gn_approver_index + 1;
  END IF;


 END LOOP;
hr_utility.trace('Out of (WHILE lv_result <> Y): '|| l_proc);
 -- for the out parameters
 hr_utility.trace('Going into (FOR I IN 1..grt_person_details_rec_table.count): '|| l_proc);
 FOR I IN 1..grt_person_details_rec_table.count
 LOOP
  p_approver_name(I) := grt_person_details_rec_table(I).full_name;
  p_approver_flag(I) := grt_person_details_rec_table(I).default_approver;

 END LOOP;
 hr_utility.trace('Out of (FOR I IN 1..grt_person_details_rec_table.count): '|| l_proc);
grt_approver_details_table := grt_person_details_rec_table;
hr_utility.set_location('Leaving: '|| l_proc,45);

EXCEPTION
    WHEN OTHERS THEN
    hr_utility.set_location('EXCEPTION: '|| l_proc,555);
    raise;
  END get_default_approvers;


-- get_all_approvers

/*-----------------------------------------------------------------------

|| PROCEDURE         : get_all_approvers
||
||
||-----------------------------------------------------------------------*/

PROCEDURE get_all_approvers(p_approver_name  hr_util_misc_web.g_varchar2_tab_type
                                  DEFAULT hr_util_misc_web.g_varchar2_tab_default,
                            p_approver_flag  hr_util_misc_web.g_varchar2_tab_type
                                  DEFAULT  hr_util_misc_web.g_varchar2_tab_default,
                            p_item_type IN wf_items.item_type%TYPE,
                            p_item_key         IN wf_items.item_key%TYPE,
                            p_effective_date   IN DATE DEFAULT SYSDATE)

AS

--local variables
ln_approver_index           NUMBER DEFAULT 1;
ln_num_of_add_apprs         NUMBER DEFAULT 0;
lv_item_name                VARCHAR2(100) DEFAULT 'ADDITIONAL_APPROVER_';
l_dummy                     VARCHAR2(100);
ln_def_app_index            NUMBER DEFAULT 1;
ln_person_id                per_people_f.person_id%TYPE;
ln_assignment_id            per_assignments_f.assignment_id%TYPE;
lrt_assignment_details      hr_misc_web.grt_assignment_details;
lv_approver_deleted         VARCHAR2(100) DEFAULT NULL;
lv_default_approver         VARCHAR2(100) DEFAULT 'NO';
ln_error_count              NUMBER DEFAULT 1;
lv_job_title                VARCHAR2(1000);
lv_approver_name            hr_util_misc_web.g_varchar2_tab_type
                              DEFAULT hr_util_misc_web.g_varchar2_tab_default;
lv_approver_flag            hr_util_misc_web.g_varchar2_tab_type
                                  DEFAULT  hr_util_misc_web.g_varchar2_tab_default;
ln_job_id   NUMBER;
l_curr_org_name VARCHAR2(100);
l_curr_loc_name VARCHAR2(100);
l_proc constant varchar2(100) := g_package || ' get_all_approvers';
-- for AME
c_transaction_type varchar2(25);

BEGIN

 hr_utility.set_location('Entering: '|| l_proc,5);
IF gv_mode='RE-ENTER' THEN
 hr_utility.trace('In (IF gv_mode=RE-ENTER): '|| l_proc);
-- check if we need to call AME
-- get the AME transaction type value from WF item attributes
c_transaction_type := wf_engine.GetItemAttrText(itemtype => p_item_type ,
                                               itemkey  => p_item_key,
                                               aname => 'HR_AME_TRAN_TYPE_ATTR');


if (c_transaction_type is not null) then
hr_utility.trace('In (if (c_transaction_type is not null)): '|| l_proc);
get_all_ame_approvers(p_approver_name  =>p_approver_name,
                      p_approver_flag  =>p_approver_flag,
                      p_item_type =>p_item_type,
                      p_item_key  =>p_item_key ,
                      p_effective_date=>p_effective_date);
hr_utility.set_location('Leaving: '|| l_proc,20);

return;
end if;


-- get the default approvers in the system
  hr_dynamic_approval_web.get_default_approvers(
    p_approver_name =>lv_approver_name,
    p_approver_flag=>lv_approver_flag,
    p_item_type    =>p_item_type,
    p_item_key     =>p_item_key
        );

  -- get the number of additional approvers in the system
  -- check if the item attribute exists
  if hr_workflow_utility.item_attribute_exists
         (p_item_type => p_item_type
         ,p_item_key  => p_item_key
         ,p_name      => 'ADDITIONAL_APPROVERS_NUMBER') then
     -- get the attribute value
     ln_num_of_add_apprs := wf_engine.GetItemAttrNumber
                                        (itemtype   => p_item_type,
                                        itemkey    => p_item_key,
                                        aname      => 'ADDITIONAL_APPROVERS_NUMBER');

 else
   wf_engine.additemattr
      (itemtype => p_item_type
      ,itemkey  => p_item_key
      ,aname    => 'ADDITIONAL_APPROVERS_NUMBER');

     wf_engine.SetItemAttrNumber       (itemtype   => p_item_type,
                                        itemkey    => p_item_key,
                                        aname      => 'ADDITIONAL_APPROVERS_NUMBER',
                                        avalue     => 0);
 end if;



ln_approver_index := lv_approver_name.count + ln_num_of_add_apprs;
hr_utility.trace('Going into( FOR I IN 1..ln_approver_index): '|| l_proc);
 FOR I IN 1..ln_approver_index
 LOOP
  lv_job_title := NULL;
  lv_item_name := gv_item_name || to_char(I);
 -- open the cursor to determine if the item exists
  OPEN csr_wiav(p_item_type,p_item_key,lv_item_name);
  hr_utility.trace('Going into Fetch after (  OPEN csr_wiav(p_item_type,p_item_key,lv_item_name)): '|| l_proc);
  FETCH csr_wiav into l_dummy;
  IF csr_wiav%notfound THEN
     lv_default_approver := 'Y';
  ELSE
     lv_default_approver := 'N';
 -- check if this additional index has been removed by the user
    lv_approver_deleted := wf_engine.GetItemAttrText
                                  (itemtype   => p_item_type,
                                   itemkey    => p_item_key,
                                   aname      => lv_item_name);
    lv_approver_deleted := NVL(lv_approver_deleted,' ');

  END IF; -- for csr_wiav%notfound
 CLOSE csr_wiav;

 -- insert proper record.
  IF lv_default_approver <> 'Y'  AND lv_approver_deleted <>'DELETED' THEN

 -- check if an error exists for this additional approver index
     IF hr_errors_api.errorExists  THEN
       grt_approver_details_table(I).full_name  := gv_error_table(ln_error_count).full_name;
       grt_approver_details_table(I).person_id  := gv_error_table(ln_error_count).person_id;
       grt_approver_details_table(I).job_title  := gv_error_table(ln_error_count).job_title;
       grt_approver_details_table(I).error_exists:= gv_error_table(ln_error_count).error_exists;
       ln_error_count := ln_error_count + 1;
     ELSE
      ln_person_id := wf_engine.GetItemAttrNumber
                           (itemtype   => p_item_type,
                            itemkey    => p_item_key,
                            aname      => lv_item_name);

       -- get the assignment id
       lrt_assignment_details := hr_misc_web.get_assignment_id(p_person_id => ln_person_id);
       ln_assignment_id       := lrt_assignment_details.assignment_id;
    -- get name and job title for this person id
       lrt_assignment_details := hr_misc_web.get_assignment_details(
                                       p_assignment_id => ln_assignment_id,
                                       p_effective_date =>p_effective_date
                                        );
       grt_approver_details_table(I).full_name  :=
                        lrt_assignment_details.person_full_name;
       grt_approver_details_table(I).person_id  :=ln_person_id;
       grt_approver_details_table(I).job_title  :=
                    hr_dynamic_approval_web.get_job_details
                     (p_person_id =>ln_person_id,
                      p_assignment_id=>ln_assignment_id,
                      p_effective_date=>p_effective_date
                      );


       grt_approver_details_table(I).default_approver := lv_default_approver;
    END IF; -- for the hr_errors_api.errorExists
   ELSE
    grt_approver_details_table(I).full_name  :=
                   grt_person_details_rec_table(ln_def_app_index).full_name ;
    grt_approver_details_table(I).person_id :=
                   grt_person_details_rec_table(ln_def_app_index).person_id;
          ln_person_id :=   grt_person_details_rec_table(ln_def_app_index).person_id;
          lrt_assignment_details := hr_misc_web.get_assignment_id(p_person_id => ln_person_id);
          ln_assignment_id       := lrt_assignment_details.assignment_id;

    grt_approver_details_table(I).job_title :=
                       hr_dynamic_approval_web.get_job_details
                              (p_person_id =>ln_person_id,
                               p_assignment_id=>ln_assignment_id,
                               p_effective_date=>p_effective_date
                              );


    grt_approver_details_table(I).default_approver := 'Y';
    ln_def_app_index := ln_def_app_index + 1;
    END IF;  -- for lv_default_approver <> 'Y'  AND lv_approver_deleted <>'DELETED'
 END LOOP;
hr_utility.trace('Going into( FOR I IN 1..ln_approver_index): '|| l_proc);
hr_utility.set_location('Leaving: '|| l_proc,40);
   return;
END IF;  -- for the p_mode
hr_utility.trace('Going into(FOR I IN 1..p_approver_name.count): '|| l_proc);

FOR I IN 1..p_approver_name.count
LOOP
   lv_job_title := NULL;
   IF hr_errors_api.errorExists  THEN
       grt_approver_details_table(I).full_name  := gv_error_table(ln_error_count).full_name;
       grt_approver_details_table(I).person_id  := gv_error_table(ln_error_count).person_id;
       grt_approver_details_table(I).job_title  := gv_error_table(ln_error_count).job_title;
       grt_approver_details_table(I).error_exists:= gv_error_table(ln_error_count).error_exists;
       grt_approver_details_table(I).default_approver := gv_error_table(ln_error_count).default_approver;
       ln_error_count := ln_error_count + 1;
     ELSE

   -- get the person id for this person
   OPEN lc_approver ( p_full_name=>p_approver_name(I));
   hr_utility.trace('Going into Fetch after (OPEN lc_approver ( p_full_name=>p_approver_name(I)) ): '|| l_proc);
   FETCH lc_approver INTO ln_person_id ;
   IF lc_approver%NOTFOUND
   THEN
         lv_job_title := NULL;
         ln_assignment_id:= NULL;
   END IF;
   CLOSE  lc_approver;

   lrt_assignment_details := hr_misc_web.get_assignment_id(p_person_id => ln_person_id);
   ln_assignment_id       := lrt_assignment_details.assignment_id;
  -- get name and job title for this person id
   lrt_assignment_details := hr_misc_web.get_assignment_details(
                                       p_assignment_id => ln_assignment_id,
                                        p_effective_date =>p_effective_date
                                        );

  lv_job_title := hr_dynamic_approval_web.get_job_details
                     (p_person_id =>ln_person_id,
                      p_assignment_id=>ln_assignment_id,
                      p_effective_date=>p_effective_date
                      );

  grt_approver_details_table(I).person_id := ln_person_id;
  grt_approver_details_table(I).full_name  := p_approver_name(I);
  grt_approver_details_table(I).job_title  :=
                               -- lrt_assignment_details.job_name;
                                 lv_job_title;
  grt_approver_details_table(I).default_approver := p_approver_flag(I);

  END IF; -- for hr_errors_api.errorExists
END LOOP;
hr_utility.trace('Out of (FOR I IN 1..p_approver_name.count): '|| l_proc);
hr_utility.set_location('Leaving: '|| l_proc,60);


EXCEPTION
    WHEN OTHERS THEN
    hr_utility.set_location('EXCEPTION: '|| l_proc,555);
    if lc_approver%isopen then
      close lc_approver;
    end if;
    if csr_wiav%isopen then
      close csr_wiav;
    end if;
    raise;
  END get_all_approvers;



/* ---------------------------------------
|| FUNCTION: build_ddl
||
||
||---------------------------------------*/

FUNCTION  build_ddl(p_approver_name  hr_util_misc_web.g_varchar2_tab_type
                        DEFAULT hr_util_misc_web.g_varchar2_tab_default,
                    p_approver_flag  hr_util_misc_web.g_varchar2_tab_type
                        DEFAULT  hr_util_misc_web.g_varchar2_tab_default,
                    p_item_type        IN wf_items.item_type%TYPE,
                    p_item_key         IN wf_items.item_key%TYPE ,
                    p_variable_name       in varchar2,
                    p_variable_value      in varchar2 DEFAULT NULL
  		           ,p_attributes IN VARCHAR2 DEFAULT NULL)   RETURN LONG  IS

	l_ddl_data hr_dynamic_approval_web.ddl_data;
    l_lov LONG;
	l_count INTEGER;
    l_checked VARCHAR2(25);
    lv_variable_name   VARCHAR2(200) DEFAULT 'p_person_id';
    ln_number_of_approvers  NUMBER ;
    l_dummy   VARCHAR2(100);
    lv_item_name        VARCHAR2(100) DEFAULT 'ADDITIONAL_APPROVER_';
    ln_def_app_index NUMBER DEFAULT 1;
    ln_person_id        per_people_f.person_id%TYPE;
    ln_full_name        per_people_f.full_name%TYPE;
    lv_index            NUMBER;
-- local variable
l_proc constant varchar2(100) := g_package || ' build_ddl';
	BEGIN
hr_utility.set_location('Entering: '|| l_proc,5);
   IF p_approver_name.count=1 THEN
      lv_index := p_approver_name.count;
   ELSE
       lv_index := p_approver_name.count -1;
   END IF;
hr_utility.trace('Going into(  FOR I IN 1..lv_index): '|| l_proc);


       FOR I IN 1..lv_index
        LOOP
            l_ddl_data(I).label      := p_approver_name(I) ;
          --  l_ddl_data(I).code       := grt_approver_details_table(I).person_id;
            l_ddl_data(I).code       := I;
            l_ddl_data(I).code_index := I;

        END LOOP;

hr_utility.trace('Out of (  FOR I IN 1..lv_index): '|| l_proc);
  		l_lov
			:= hr_util_misc_web.g_new_line || htf.formselectopen
				(cname => upper(p_variable_name)
				,nsize => 1
				,cattributes => p_attributes) ||
                                       hr_util_misc_web.g_new_line ;

hr_utility.trace('Going into(FOR i  IN 1..lv_index LOOP): '|| l_proc);
  		FOR i  IN 1..lv_index LOOP
			IF p_variable_value IS NOT NULL THEN
    				IF l_ddl_data(i).code = p_variable_value THEN
      					l_checked := 'SELECTED';
    				ELSE
      					l_checked := null;
    				END IF;
			ELSE
      				l_checked := null;
			END IF;
    			l_lov := l_lov || htf.formselectoption
      				(cvalue      => l_ddl_data(i).label
      				,cselected   => l_checked
      				,cattributes => 'VALUE="'|| l_ddl_data(i).code
                                   ||'"' ||'INDEX="'|| l_ddl_data(i).code_index
                                   ||'"' ) ;--|| hr_util_misc_web.g_new_line;
  		END LOOP;
hr_utility.trace('Out of (FOR i  IN 1..lv_index LOOP): '|| l_proc);
  		l_lov := l_lov || htf.formselectclose || hr_util_misc_web.g_new_line;

hr_utility.set_location('Leaving: '|| l_proc,30);

		RETURN l_lov;

        EXCEPTION  WHEN OTHERS THEN
        hr_utility.set_location('EXCEPTION: '|| l_proc,555);
        raise;


	END build_ddl;


-- ---------------------------------------------------------------------------
-- Public procedure declarations
-- ---------------------------------------------------------------------------
--
-- ----------------------------------------------------------------------------
-- |------------------------------< add_approver >-------------------|
-- ----------------------------------------------------------------------------
--
-- This procedure will add a new approver to the list passed at index
-- and passes the new list back.
--


PROCEDURE add_approver(p_approver_name  IN OUT NOCOPY hr_util_misc_web.g_varchar2_tab_type,
                       p_approver_flag  IN OUT NOCOPY hr_util_misc_web.g_varchar2_tab_type,
                       p_item_type IN wf_items.item_type%TYPE,
                       p_item_key IN wf_items.item_key%TYPE,
                       p_approver_index IN NUMBER DEFAULT 0)
AS
-- Local Variables
    ln_number_of_approvers  NUMBER ;
    ln_additional_approvers NUMBER DEFAULT 0;
    lv_item_name            VARCHAR2(100) DEFAULT 'ADDITIONAL_APPROVER_';
    l_dummy                 NUMBER(1);
    lv_item_name_from       VARCHAR2(100) DEFAULT 'ADDITIONAL_APPROVER_';
    lv_item_name_to         VARCHAR2(100) DEFAULT 'ADDITIONAL_APPROVER_';
    ln_from_index_id        per_people_f.person_id%TYPE;
    ln_to_index_id          per_people_f.person_id%TYPE;
    ln_start_index          NUMBER ;
    ln_end_index            NUMBER ;
    ln_loop_index           NUMBER;
    lv_exist                VARCHAR2(10) DEFAULT 'NO';
    l_proc constant varchar2(100) := g_package || ' add_approver';
    --new variables
    lv_approver_name  hr_util_misc_web.g_varchar2_tab_type
                     DEFAULT hr_util_misc_web.g_varchar2_tab_default;
    lv_approver_flag  hr_util_misc_web.g_varchar2_tab_type
                     DEFAULT  hr_util_misc_web.g_varchar2_tab_default;
BEGIN
hr_utility.set_location('Entering: '|| l_proc,5);
-- validate the session
  hr_util_misc_web.validate_session(p_person_id => gn_person_id);

-- set the package global variables
  gv_mode := 'ADD';
-- new code

  ln_loop_index := 1;
  hr_utility.trace('Going into(FOR I IN 1..(p_approver_name.count + 1)): '|| l_proc);
  FOR I IN 1..(p_approver_name.count + 1)
  LOOP
     IF I=(p_approver_index+1) THEN
        lv_approver_name(I) := NULL;
        lv_approver_flag(I) := 'N';

     ELSIF I>p_approver_index THEN
         lv_approver_name(I) := p_approver_name(I-1);
         lv_approver_flag(I) := p_approver_flag(I-1);
      ELSE
         lv_approver_name(I) := p_approver_name(I);
         lv_approver_flag(I) := p_approver_flag(I);
      END IF;
  END LOOP;
    hr_utility.trace('Out of (FOR I IN 1..(p_approver_name.count + 1)): '|| l_proc);
p_approver_name := lv_approver_name;
p_approver_flag := lv_approver_flag;
hr_utility.set_location('Leaving: '|| l_proc,20);

    EXCEPTION  WHEN OTHERS THEN
    hr_utility.set_location('EXCEPTION: '|| l_proc,555);
    raise;

END add_approver;




-- ---------------------------------------------------------------------------
-- Public procedure declarations
-- ---------------------------------------------------------------------------
--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_approver >-------------------|
-- ----------------------------------------------------------------------------
--
-- This procedure will delete a approver from the list passed at index
-- and passes the new list back.
--


PROCEDURE delete_approver(p_approver_name  IN OUT NOCOPY hr_util_misc_web.g_varchar2_tab_type,
                       p_approver_flag  IN OUT NOCOPY hr_util_misc_web.g_varchar2_tab_type,
                       p_item_type IN wf_items.item_type%TYPE,
                       p_item_key IN wf_items.item_key%TYPE,
                       p_approver_index IN NUMBER DEFAULT 1)
AS
-- Local Variables
    ln_number_of_approvers  NUMBER ;
    ln_additional_approvers NUMBER DEFAULT 0;
    lrt_approver_details_table    hr_dynamic_approval_web.approver_rec_table;
    lv_item_name            VARCHAR2(100) DEFAULT 'ADDITIONAL_APPROVER_';
    l_dummy                 NUMBER(1);
    lv_item_name_from       VARCHAR2(100) DEFAULT 'ADDITIONAL_APPROVER_';
    lv_item_name_to         VARCHAR2(100) DEFAULT 'ADDITIONAL_APPROVER_';
    ln_from_index_id        per_people_f.person_id%TYPE;
    ln_to_index_id          per_people_f.person_id%TYPE;
    ln_start_index          NUMBER ;
    ln_end_index            NUMBER ;
    ln_loop_index           NUMBER;
    lv_exist                VARCHAR2(10) DEFAULT 'NO';
    ln_current_index        NUMBER;
    ln_current_person_id    per_people_f.person_id%TYPE;
    ln_change_to_index      NUMBER;
    ln_change_to_person_id  per_people_f.person_id%TYPE;
    ln_curr_add_appr_index  NUMBER DEFAULT 0;
    lv_last_addnl_approver  VARCHAR2(10) DEFAULT 'NO';
    lv_valid_approver       VARCHAR2(100) DEFAULT 'VALID';
    l_proc constant varchar2(100) := g_package || ' delete_approver';
    -- new variables
    lv_approver_name  hr_util_misc_web.g_varchar2_tab_type
                      DEFAULT hr_util_misc_web.g_varchar2_tab_default;
    lv_approver_flag  hr_util_misc_web.g_varchar2_tab_type
                       DEFAULT  hr_util_misc_web.g_varchar2_tab_default;

BEGIN
    hr_utility.set_location('Entering: '|| l_proc,5);
-- validate the session
  hr_util_misc_web.validate_session(p_person_id => gn_person_id);


 -- get all the additional approvers
  -- get number of additional approvers
     gn_additional_approvers :=
             wf_engine.GetItemAttrNumber(itemtype   => p_item_type,
                                         itemkey    => p_item_key,
                                         aname      => 'ADDITIONAL_APPROVERS_NUMBER');



ln_number_of_approvers := (gn_approver_index -1) + gn_additional_approvers ;

  ln_curr_add_appr_index := 0;

-- fix for bug #1570998
/*
FOR I IN  REVERSE p_approver_index..ln_number_of_approvers
 LOOP
    lv_item_name := gv_item_name ||to_char(I);
     OPEN csr_wiav(p_item_type,p_item_key,lv_item_name);
     FETCH csr_wiav into l_dummy;
        IF csr_wiav%notfound THEN
           lv_exist := 'N';
        ELSE
           lv_exist := 'Y';
           ln_curr_add_appr_index := ln_curr_add_appr_index + 1;
        END IF;
     CLOSE csr_wiav;



-- Find the last approver , get his ID and update the flag to DELETED

     IF ln_curr_add_appr_index=1 AND lv_exist = 'Y' THEN
          -- get the status of this approver index
           lv_valid_approver :=  wf_engine.GetItemAttrText
                               (itemtype   => p_item_type,
                                itemkey    => p_item_key,
                                aname      => lv_item_name);

           IF lv_valid_approver<>'DELETED' THEN
       -- get the person_id for this index
           ln_from_index_id := wf_engine.GetItemAttrNumber
                               (itemtype   => p_item_type,
                                itemkey    => p_item_key,
                                aname      => lv_item_name);

        -- set the flag to DELETED and person_id to NULL
           wf_engine.SetItemAttrNumber
                    (itemtype    => p_item_type,
                     itemkey     => p_item_key,
                     aname       => lv_item_name,
                     avalue      => NULL);
                wf_engine.SetItemAttrText
                    (itemtype    => p_item_type,
                     itemkey     => p_item_key,
                     aname       => lv_item_name,
                     avalue      => 'DELETED');

       --  set the to and from as equal
           ln_to_index_id   := ln_from_index_id;
            ELSE
                ln_curr_add_appr_index := 0;
            END IF;
     ELSIF ln_curr_add_appr_index>1 AND lv_exist = 'Y'  THEN
   -- get the person_id for this index
      ln_from_index_id := wf_engine.GetItemAttrNumber
                               (itemtype   => p_item_type,
                                itemkey    => p_item_key,
                                aname      => lv_item_name);
  --  reset it with the new value
      wf_engine.SetItemAttrNumber
                    (itemtype    => p_item_type,
                     itemkey     => p_item_key,
                     aname       => lv_item_name,
                     avalue      => ln_to_index_id);
-- reset the 'to' id
      ln_to_index_id   := ln_from_index_id;
END IF;

END LOOP;

-- reset the index for the number of additional approvers
    gn_additional_approvers := (gn_additional_approvers -1);
    wf_engine.SetItemAttrNumber
                    (itemtype    => p_item_type,
                     itemkey     => p_item_key,
                     aname       => 'ADDITIONAL_APPROVERS_NUMBER',
                     avalue      => gn_additional_approvers);

*/

 -- new code
gn_additional_approvers := 0;

hr_utility.trace('Going into( FOR I IN 1..p_approver_name.count): '|| l_proc);
 FOR I IN 1..p_approver_name.count
 LOOP
     IF I=p_approver_index THEN
        NULL;
     ELSIF I>p_approver_index THEN
        lv_approver_name(I-1) := p_approver_name(I);
        lv_approver_flag(I-1) := p_approver_flag(I);
     ELSE
        lv_approver_name(I) := p_approver_name(I);
        lv_approver_flag(I) := p_approver_flag(I);
     END IF;

    if p_approver_flag(I)='Y' then
     gn_additional_approvers := gn_additional_approvers + 1;
     end if;

 END LOOP;
hr_utility.trace('Out of ( FOR I IN 1..p_approver_name.count): '|| l_proc);
wf_engine.SetItemAttrNumber
                    (itemtype    => p_item_type,
                     itemkey     => p_item_key,
                     aname       => 'ADDITIONAL_APPROVERS_NUMBER',
                     avalue      => gn_additional_approvers);



   p_approver_name := lv_approver_name;
   p_approver_flag := lv_approver_flag;

hr_utility.set_location('Leaving: '|| l_proc,20);

EXCEPTION  WHEN OTHERS THEN
hr_utility.set_location('EXCEPTION: '|| l_proc,555);
	if csr_wiav%isopen then
	  close csr_wiav;
	end if;
   raise;

END delete_approver;


-- ---------------------------------------------------------------------------
-- Public procedure declarations
-- ---------------------------------------------------------------------------
--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_notifier >-------------------|
-- ----------------------------------------------------------------------------
--
-- This procedure will delete a approver from the list passed at index
-- and passes the new list back.
--


PROCEDURE delete_notifier(p_notifier_name  IN OUT NOCOPY hr_util_misc_web.g_varchar2_tab_type,
                          p_notify_onsubmit_flag  IN OUT NOCOPY hr_util_misc_web.g_varchar2_tab_type,
                          p_notify_onapproval_flag  IN OUT NOCOPY hr_util_misc_web.g_varchar2_tab_type,
                          p_item_type IN wf_items.item_type%TYPE,
                          p_item_key IN wf_items.item_key%TYPE,
                          p_notifier_index IN NUMBER DEFAULT 1)
AS
-- Local Variables
lv_notifier_name           hr_util_misc_web.g_varchar2_tab_type;
lv_notify_onsubmit_flag    hr_util_misc_web.g_varchar2_tab_type;
lv_notify_onapproval_flag  hr_util_misc_web.g_varchar2_tab_type;
lv_exist                   VARCHAR2(10);
l_proc constant varchar2(100) := g_package || ' delete_notifier';
BEGIN
hr_utility.set_location('Entering: '|| l_proc,5);hr_utility.set_location('Going into(FOR I IN 1..p_notifier_name.count): '|| l_proc,10);


 FOR I IN 1..p_notifier_name.count
 LOOP
     IF I=p_notifier_index THEN
     hr_utility.trace('In(IF I=p_notifier_index): '|| l_proc);
        NULL;
     ELSIF I>p_notifier_index THEN
          hr_utility.trace('In(ELSIF I>p_notifier_index ): '|| l_proc);
        lv_notifier_name(I-1) := p_notifier_name(I);
        --loop to check if the user has checked this index
         lv_exist := 'N';
         FOR J IN 1..p_notify_onsubmit_flag.count
         LOOP
           IF p_notify_onsubmit_flag(J)=I THEN
            lv_exist := 'Y';
             exit;
           ELSE
            lv_exist := 'N';
           END IF;
         END LOOP;
        IF lv_exist='Y' THEN
        lv_notify_onsubmit_flag(I-1)  := (I-1) ;
        ELSE
        lv_notify_onsubmit_flag(I-1)  := NULL ;
        END IF;

    lv_exist := 'N';
        FOR K IN 1..p_notify_onapproval_flag.count
        LOOP
          IF p_notify_onapproval_flag(K)=I THEN
           lv_exist := 'Y';
           exit;
           ELSE
            lv_exist := 'N';
          END IF;

        END LOOP;
        IF lv_exist='Y' THEN
         lv_notify_onapproval_flag(I-1)  := (I-1) ;
        ELSE
         lv_notify_onapproval_flag(I-1)  := NULL ;
        END IF;



  ELSE
     hr_utility.trace('In else of (IF I=p_notifier_index): '|| l_proc);
        lv_notifier_name(I) := p_notifier_name(I);
        --loop to check if the user has checked this index
         lv_exist := 'N';
         FOR J IN 1..p_notify_onsubmit_flag.count
         LOOP
           IF p_notify_onsubmit_flag(J)=I THEN
            lv_exist := 'Y';
             exit;
           ELSE
            lv_exist := 'N';
           END IF;
         END LOOP;
        IF lv_exist='Y' THEN
        lv_notify_onsubmit_flag(I)  := I ;
        ELSE
        lv_notify_onsubmit_flag(I)  := NULL ;
        END IF;

    lv_exist := 'N';
        FOR K IN 1..p_notify_onapproval_flag.count
        LOOP
          IF p_notify_onapproval_flag(K)=I THEN
           lv_exist := 'Y';
           exit;
           ELSE
            lv_exist := 'N';
          END IF;

        END LOOP;
        IF lv_exist='Y' THEN
         lv_notify_onapproval_flag(I)  := I ;
        ELSE
         lv_notify_onapproval_flag(I)  := NULL ;
        END IF;



     END IF;
 END LOOP;
hr_utility.trace('Out (FOR I IN 1..p_notifier_name.count): '|| l_proc);
   p_notifier_name := lv_notifier_name;
   p_notify_onsubmit_flag:= lv_notify_onsubmit_flag;
   p_notify_onapproval_flag := lv_notify_onapproval_flag;

hr_utility.set_location('Leaving: '|| l_proc,25);

EXCEPTION  WHEN OTHERS THEN
hr_utility.set_location('EXCEPTION: '|| l_proc,555);
raise;

END delete_notifier;


-- ---------------------------------------------------------------------------
-- Public procedure declarations
-- ---------------------------------------------------------------------------
--

-- ---------------------------------------------------------------------------
-- public Procedure declarations
-- ---------------------------------------------------------------------------
--
-- ----------------------------------------------------------------------------
-- |------------------------------< add_notifier>-------------------|
-- ----------------------------------------------------------------------------
--
-- This procedure adds a new notifier to the list with onsubmit and onapproval as
-- default flags.
--


PROCEDURE add_notifier(p_notifier_name  IN OUT NOCOPY hr_util_misc_web.g_varchar2_tab_type,
                       p_notify_onsubmit_flag  IN OUT NOCOPY hr_util_misc_web.g_varchar2_tab_type,
                       p_notify_onapproval_flag  IN OUT NOCOPY hr_util_misc_web.g_varchar2_tab_type,
                       p_item_type IN wf_items.item_type%TYPE
                       ,p_item_key IN wf_items.item_key%TYPE
                       ,P_PERSON_NAME IN per_all_people_f.full_name%TYPE
                       ,p_person_id IN per_all_people_f.person_id%TYPE
                      )
AS
-- Local Variables
lv_exist        VARCHAR2(10) DEFAULT 'N';
l_dummy         VARCHAR2(100) ;
lv_item_name    VARCHAR2(100);
l_proc constant varchar2(100) := g_package || ' add_notifier';
-- new variables
lv_notifier_name hr_util_misc_web.g_varchar2_tab_type
                        DEFAULT hr_util_misc_web.g_varchar2_tab_default;
lv_notify_onsubmit_flag hr_util_misc_web.g_varchar2_tab_type
                        DEFAULT hr_util_misc_web.g_varchar2_tab_default;
lv_notify_onapproval_flag hr_util_misc_web.g_varchar2_tab_type
                        DEFAULT hr_util_misc_web.g_varchar2_tab_default;
BEGIN

hr_utility.set_location('Entering: '|| l_proc,5);
lv_notifier_name := p_notifier_name;
lv_notify_onsubmit_flag := p_notify_onsubmit_flag ;
lv_notify_onapproval_flag := p_notify_onapproval_flag;

lv_notifier_name(p_notifier_name.count +1) := P_PERSON_NAME;
lv_notify_onsubmit_flag(p_notify_onsubmit_flag.count +1) := to_char((p_notifier_name.count +1));
lv_notify_onapproval_flag(p_notify_onapproval_flag.count+1) := to_char((p_notifier_name.count +1));

p_notifier_name := lv_notifier_name;
p_notify_onsubmit_flag := lv_notify_onsubmit_flag;
p_notify_onapproval_flag := lv_notify_onapproval_flag;
hr_utility.set_location('Leaving: '|| l_proc,10);


EXCEPTION  WHEN OTHERS THEN
        hr_utility.set_location('EXCEPTION: '|| l_proc,555);
        raise;
END add_notifier;

--
-- ------------------------------------------------------------------------
-- |------------------------< Get_all_notifiers >-------------------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--  Get all the notifiers for the process
--
--
PROCEDURE Get_all_notifiers(
                       p_notifier_name  IN  hr_util_misc_web.g_varchar2_tab_type,
                       p_notify_onsubmit_flag  IN  hr_util_misc_web.g_varchar2_tab_type,
                       p_notify_onapproval_flag  IN  hr_util_misc_web.g_varchar2_tab_type,
                       p_item_type IN wf_items.item_type%TYPE,
                       p_item_key IN wf_items.item_key%TYPE,
                       p_effective_date IN DATE
                  )
AS
-- Local Variables
lv_exist        VARCHAR2(10) DEFAULT 'N';
l_dummy         VARCHAR2(100) ;
lv_item_name    VARCHAR2(100);
lrt_notifier_details_table    hr_dynamic_approval_web.notifier_rec_table;
ln_person_id    per_people_f.person_id%TYPE;
lv_full_name    per_people_f.person_id%TYPE;
lv_job_title    VARCHAR2(1000);
lv_on_submit    VARCHAR2(10);
lv_on_approval  VARCHAR2(10);
lv_notify       VARCHAR2(10);
ln_assignment_id NUMBER ;
lrt_assignment_details      hr_misc_web.grt_assignment_details;
ln_loop_index   NUMBER;
ln_job_id   NUMBER;
l_curr_org_name VARCHAR2(100);
l_curr_loc_name VARCHAR2(100);
ln_error_count              NUMBER DEFAULT 1;
l_proc constant varchar2(100) := g_package || ' Get_all_notifiers';
BEGIN
 hr_utility.set_location('Entering: '|| l_proc,5);

IF gv_mode='RE-ENTER' THEN
 hr_utility.trace('In (IF gv_mode=RE-ENTER): '|| l_proc);
   -- get the number of notifiers in the system
  OPEN csr_wiav(p_item_type,p_item_key,'NOTIFIERS_NUMBER');
   hr_utility.trace('Going into Fetch after ( OPEN csr_wiav(p_item_type,p_item_key,NOTIFIERS_NUMBER) ):'|| l_proc);
  FETCH csr_wiav into l_dummy;
   IF csr_wiav%notfound THEN
       gn_notifiers := 0;
   ELSE
       gn_notifiers :=
            wf_engine.GetItemAttrNumber(itemtype   => p_item_type,
                                         itemkey    => p_item_key,
                                         aname      => 'NOTIFIERS_NUMBER');
   END IF;
  CLOSE csr_wiav;

  IF gn_notifiers > 0 THEN
     hr_utility.trace('In( IF gn_notifiers > 0 ): '|| l_proc);
     --loop througthe counter and get all the notifiers
     hr_utility.trace('Going into( FOR I IN 1..gn_notifiers ): '|| l_proc);
     FOR I IN 1..gn_notifiers
     LOOP
        lv_job_title := NULL;
        lv_item_name := gv_notifier_name||to_char(I);
        OPEN csr_wiav(p_item_type,p_item_key,lv_item_name);
             hr_utility.trace('Going into( FETCH csr_wiav into l_dummy; ): '|| l_proc);
        FETCH csr_wiav into l_dummy;
        IF csr_wiav%notfound THEN
         lv_exist := 'N';
       ELSE
           lv_exist := 'Y';
           ln_person_id:= wf_engine.GetItemAttrNumber
                    (itemtype    => p_item_type,
                     itemkey     => p_item_key,
                     aname       => lv_item_name
                     );
          lv_notify := wf_engine.GetItemAttrText
                    (itemtype    => p_item_type,
                     itemkey     => p_item_key,
                     aname       => lv_item_name
                     );
         END IF; -- for csr_wiav%notfound
        CLOSE csr_wiav;

IF lv_exist = 'Y' THEN
 hr_utility.trace('In(IF lv_exist = Y): '|| l_proc);
 -- get the person and assignment details for this person_id
   -- get the assignment id
     lrt_assignment_details := hr_misc_web.get_assignment_id(p_person_id => ln_person_id);
     ln_assignment_id       := lrt_assignment_details.assignment_id;
 -- get name and job title for this person id
     lrt_assignment_details := hr_misc_web.get_assignment_details(
                                     p_assignment_id => ln_assignment_id,
                                      p_effective_date =>p_effective_date
                                        );

  -- populate the notifiers rec table
  lrt_notifier_details_table(I).person_id := ln_person_id;
  lrt_notifier_details_table(I).full_name := lrt_assignment_details.person_full_name;

  lv_job_title := hr_dynamic_approval_web.get_job_details
                     (p_person_id =>ln_person_id,
                      p_assignment_id=>ln_assignment_id,
                      p_effective_date=>p_effective_date
                      );
lrt_notifier_details_table(I).job_title := lv_job_title;

  -- parse the lv_notify for these values
  lrt_notifier_details_table(I).on_submit := SUBSTR(lv_notify,1,1);
  lrt_notifier_details_table(I).on_approval := SUBSTR(lv_notify,3,3);
 END IF; -- for lv_exist = 'Y'

END LOOP;
     hr_utility.trace('Out of ( FOR I IN 1..gn_notifiers ): '|| l_proc);
END IF; -- for gn_notifiers > 0

grt_notifier_details_table := lrt_notifier_details_table;

hr_utility.set_location('Leaving: '|| l_proc,45);
RETURN;
END IF; -- for gv_mode
     hr_utility.trace('Going into( FOR I IN 1..p_notifier_name.count ): '|| l_proc);

FOR I IN 1..p_notifier_name.count
LOOP
   lv_job_title := NULL;
    IF hr_errors_api.errorExists  THEN
       lrt_notifier_details_table(I).full_name  := grt_notifier_error_table(ln_error_count).full_name;
       lrt_notifier_details_table(I).error_exists:= grt_notifier_error_table(ln_error_count).error_exists;
       ln_error_count := ln_error_count + 1;
    ELSE
     lrt_notifier_details_table(I).full_name := p_notifier_name(I);
    END IF;

   --loop to check if the user has checked this index
     lv_exist := 'N';
     FOR J IN 1..p_notify_onsubmit_flag.count
     LOOP
        IF p_notify_onsubmit_flag(J)=I THEN
         lv_exist := 'Y';
         exit;
        ELSE
          lv_exist := 'N';
        END IF;
     END LOOP;
     lrt_notifier_details_table(I).on_submit:=lv_exist ;

    lv_exist := 'N';
    FOR K IN 1..p_notify_onapproval_flag.count
    LOOP
        IF p_notify_onapproval_flag(K)=I THEN
         lv_exist := 'Y';
         exit;
        ELSE
          lv_exist := 'N';
        END IF;

    END LOOP;
lrt_notifier_details_table(I).on_approval:= lv_exist ;


-- get the person id for this person
   OPEN lc_approver ( p_full_name=>p_notifier_name(I));
    hr_utility.trace('Going into Fetch after (OPEN lc_approver ( p_full_name=>p_notifier_name(I)) ): '|| l_proc);
   FETCH lc_approver INTO ln_person_id ;
   IF lc_approver%NOTFOUND
   THEN
         lv_job_title := NULL;
         ln_assignment_id:= NULL;
   END IF;
   CLOSE  lc_approver;

   IF hr_errors_api.errorExists  THEN
    lrt_notifier_details_table(I).person_id := NULL;
   ELSE
   lrt_notifier_details_table(I).person_id := ln_person_id;
   END IF;
   lrt_assignment_details := hr_misc_web.get_assignment_id(p_person_id => ln_person_id);
     ln_assignment_id       := lrt_assignment_details.assignment_id;

 -- get name and job title for this person id
     lrt_assignment_details := hr_misc_web.get_assignment_details(
                                     p_assignment_id => ln_assignment_id,
                                      p_effective_date =>p_effective_date
                                      );

lv_job_title := hr_dynamic_approval_web.get_job_details
                     (p_person_id =>ln_person_id,
                      p_assignment_id=>ln_assignment_id,
                      p_effective_date=>p_effective_date
                      );

lrt_notifier_details_table(I).job_title :=lv_job_title;


END LOOP;
 hr_utility.trace('out of ( FOR I IN 1..p_notifier_name.count ): '|| l_proc);

grt_notifier_details_table := lrt_notifier_details_table;
hr_utility.set_location('Leaving: '|| l_proc,65);

EXCEPTION  WHEN OTHERS THEN
hr_utility.set_location('EXCEPTION: '|| l_proc,555);
       if lc_approver%isopen then
          close lc_approver;
        end if;
        if csr_wiav%isopen then
          close csr_wiav;
        end if;
        raise;

END Get_all_notifiers;

-- ---------------------------------------------------------------------------
-- public Procedure declarations
-- ---------------------------------------------------------------------------
--
-- ----------------------------------------------------------------------------
-- |------------------------------< update_notifiers>-------------------|
-- ----------------------------------------------------------------------------
--
-- This procedure updates the notifiers list with proper flags as selected.
--
--


PROCEDURE update_notifiers(
          p_item_type 	     IN WF_ITEMS.ITEM_TYPE%TYPE ,
          p_item_key  	     IN WF_ITEMS.ITEM_KEY%TYPE ,
          p_act_id    	     IN NUMBER ,
          p_notifiers_num    IN NUMBER DEFAULT 0,
          p_Notify_On_Submit  hr_util_misc_web.g_varchar2_tab_type   DEFAULT
                       hr_util_misc_web.g_varchar2_tab_default,
          p_Notify_On_Approval  hr_util_misc_web.g_varchar2_tab_type   DEFAULT
                       hr_util_misc_web.g_varchar2_tab_default

              )
AS
-- Local Variables
lv_error_flag BOOLEAN DEFAULT FALSE;
ln_approver_index  NUMBER DEFAULT 0;
lv_item_name       VARCHAR2(1000);
lv_default_approver VARCHAR2(10);
ln_count           NUMBER DEFAULT 1;
l_dummy            VARCHAR2(1000);
lv_approver_deleted VARCHAR2(100);
ln_approver_id     NUMBER;
lv_response        VARCHAR2(10);
l_proc constant varchar2(100) := g_package || ' update_notifiers';
BEGIN
hr_utility.set_location('Entering: '|| l_proc,5);

hr_utility.trace('Going into (FOR I IN 1..p_Notify_On_Submit.count ): '|| l_proc);

FOR I IN 1..p_Notify_On_Submit.count
LOOP
  IF p_Notify_On_Submit(I) = 'Y' THEN
     lv_response := 'Y|';
  ELSE
      lv_response := 'N|';
  END IF;

  IF p_Notify_On_Approval(I) = 'Y' THEN
    lv_response := lv_response ||'Y';
  ELSE
    lv_response := lv_response ||'N';
  END IF;


  -- update the wf_item_attributes with new response
 lv_item_name := gv_notifier_name||to_char(I);

        OPEN csr_wiav(p_item_type,p_item_key,lv_item_name);
        hr_utility.trace('Going into Fetch after ( OPEN csr_wiav(p_item_type,p_item_key,lv_item_name)): '|| l_proc);
        FETCH csr_wiav into l_dummy;
        IF csr_wiav%notfound THEN
          NULL;
        ELSE
          wf_engine.SetItemAttrText
                    (itemtype    => p_item_type,
                     itemkey     => p_item_key,
                     aname       => lv_item_name,
                     avalue      => lv_response
                    );
         END IF; -- for csr_wiav%notfound
        CLOSE csr_wiav;



END LOOP;

hr_utility.trace('Out of  (FOR I IN 1..p_Notify_On_Submit.count ): '|| l_proc);
hr_utility.set_location('Leaving: '|| l_proc,25);

EXCEPTION  WHEN OTHERS THEN
hr_utility.set_location('EXCEPTION: '|| l_proc,555);
        if csr_wiav%isopen then
          close csr_wiav;
        end if;
        raise;

END update_notifiers;

--
-- ------------------------------------------------------------------------
-- |------------------------< clean_invalid_data >-------------------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--  Flag the invalid data as deleted for the additional approvers
--
--

PROCEDURE clean_invalid_data( p_item_type 	     IN WF_ITEMS.ITEM_TYPE%TYPE ,
          p_item_key  	     IN WF_ITEMS.ITEM_KEY%TYPE ,
          p_act_id    	     IN NUMBER ,
          p_approvers_name   IN hr_util_misc_web.g_varchar2_tab_type
          )
AS
-- Local Varaibles
   ln_approver_id per_people_f.person_id%TYPE ;
   lv_job_title   VARCHAR2(1000) DEFAULT NULL;
   ln_assignment_id NUMBER;
   ld_effective_date DATE;
   lv_exists      VARCHAR2(10) DEFAULT 'N';
   p_error_flag   BOOLEAN;
   lv_item_name            VARCHAR2(100) DEFAULT 'ADDITIONAL_APPROVER_';
   ln_approver_index NUMBER;
   ln_num_of_add_apprs NUMBER;
   l_dummy VARCHAR2(100);
   lv_default_approver VARCHAR2(10);
   lv_approver_deleted VARCHAR2(20);
   ln_person_id    NUMBER;
l_proc constant varchar2(100) := g_package || ' clean_invalid_data';
BEGIN
hr_utility.set_location('Entering: '|| l_proc,5);
    ln_approver_index  := gn_approver_index - 1;
  -- get the additional approvers number
    ln_num_of_add_apprs := wf_engine.GetItemAttrNumber
                                        (itemtype   => p_item_type,
                                        itemkey    => p_item_key,
                                        aname      => 'ADDITIONAL_APPROVERS_NUMBER');


    ln_approver_index := ln_approver_index +   ln_num_of_add_apprs;
    IF  ln_num_of_add_apprs > 0 THEN
    hr_utility.trace('In( IF  ln_num_of_add_apprs > 0 ): '|| l_proc);
    hr_utility.trace('Going into(  FOR I IN 1..ln_approver_index): '|| l_proc);
          FOR I IN 1..ln_approver_index
                 LOOP
                    -- check if an additional approver exists by this index

                        lv_item_name := gv_item_name ||to_char(I);
                    -- open the cursor to determine if the item exists
                        OPEN csr_wiav(p_item_type
                            ,p_item_key
                            ,lv_item_name);
                        hr_utility.trace('Going intoFetch after (OPEN csr_wiav(p_item_type,p_item_key,lv_item_name)): '|| l_proc);
                        FETCH csr_wiav into l_dummy;
                        IF csr_wiav%notfound THEN
                          lv_default_approver := 'Y';
                        ELSE
                          lv_default_approver := 'N';
                        -- check if this additional index has been removed by the user

                            lv_approver_deleted := wf_engine.GetItemAttrText
                                                                 (itemtype   => p_item_type,
                                                                  itemkey    => p_item_key,
                                                                  aname      => lv_item_name);
                             lv_approver_deleted := NVL(lv_approver_deleted,' ');

                     END IF; -- for csr_wiav%notfound
                    CLOSE csr_wiav;

 -- delete proper record.
       IF lv_default_approver <> 'Y'  AND lv_approver_deleted <>'DELETED' THEN
             -- get the approver ID for this index
              ln_person_id := wf_engine.GetItemAttrNumber
                                    (itemtype   => p_item_type,
                                     itemkey    => p_item_key,
                                     aname      => lv_item_name);
            IF ln_person_id IS NULL THEN
               /* hr_dynamic_approval_web.delete_approver(p_item_type=>p_item_type,
                                           p_item_key=>p_item_key,
                                           p_approver_index=>I);
               */
               NULL;
           END IF;  -- forln_person_id IS NULL

  END IF;  -- for lv_default_approver <> 'Y'  AND lv_approver_deleted <>'DELETED'

  END LOOP;
      hr_utility.trace('Out of (  FOR I IN 1..ln_approver_index): '|| l_proc);
  END IF;  -- for ln_num_of_add_apprs


hr_utility.set_location('Leaving: '|| l_proc,30);

EXCEPTION  WHEN OTHERS THEN
hr_utility.set_location('EXCEPTION: '|| l_proc,555);
    if csr_wiav%isopen then
       close csr_wiav;
    end if;
    raise;

END clean_invalid_data;



--
-- ------------------------------------------------------------------------
-- |------------------------< Get_next_approver >-------------------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--  Get the next approver in the chain
--
--
procedure Get_Next_Approver (   itemtype    in varchar2,
                itemkey     in varchar2,
                actid       in number,
                funmode     in varchar2,
                result      out nocopy varchar2     )
AS

-- -------------------------------------------------------------------------
  -- local variables
  -- -------------------------------------------------------------------------
  l_creator_person_id     per_people_f.person_id%type;
  l_forward_from_person_id    per_people_f.person_id%type;
  l_forward_from_username     wf_users.name%type;
  l_forward_from_disp_name    wf_users.display_name%type;
  l_forward_to_person_id      per_people_f.person_id%type;
  l_forward_to_username       wf_users.name%type;
  l_forward_to_disp_name      wf_users.display_name%type;
  l_proc                      varchar2(61) := gv_package||' get_next_approver';
  l_current_forward_to_id     per_people_f.person_id%type;
  l_current_forward_from_id   per_people_f.person_id%type;
  lv_last_approver_def        VARCHAR2(10) DEFAULT 'Y';
  ln_current_approver_index   NUMBER ;
  ln_curr_def_appr_index      NUMBER;
  ln_last_default_approver_id per_people_f.person_id%type;
  ln_addntl_approver_id       per_people_f.person_id%type;
  lv_item_name                hr_dynamic_approval_web.gv_item_name%type;
  ln_addntl_approvers         NUMBER;
  lv_exists                   VARCHAR2(10);
  lv_dummy                    VARCHAR2(20);
  lv_isvalid                  VARCHAR2(10);

  -- Variables for AME API
  c_application_id integer;
  c_transaction_id varchar2(25);
  c_transaction_type varchar2(25);
  c_next_approver_rec ame_util.approverRecord;

--
v_approvalprocesscompleteynout varchar2(5);
v_next_approver_rec ame_util.approverstable2;

BEGIN
hr_utility.set_location('Entering: '|| l_proc,5);
--

if ( funmode = 'RUN' ) then
hr_utility.trace('In (if ( funmode = RUN )):'|| l_proc);

    -- get the current forward from person
    l_current_forward_from_id :=
      nvl(wf_engine.GetItemAttrNumber
            (itemtype   => itemtype
            ,itemkey    => itemkey
            ,aname      => 'FORWARD_FROM_PERSON_ID'),
          wf_engine.GetItemAttrNumber
            (itemtype   => itemtype
            ,itemkey    => itemkey
            ,aname      => 'CREATOR_PERSON_ID'));
    -- get the current forward to person
    l_current_forward_to_id :=
      nvl(wf_engine.GetItemAttrNumber
            (itemtype => itemtype
            ,itemkey  => itemkey
            ,aname    => 'FORWARD_TO_PERSON_ID'),
          wf_engine.GetItemAttrNumber
            (itemtype   => itemtype
            ,itemkey    => itemkey
            ,aname      => 'CREATOR_PERSON_ID'));


-- get the AME transaction type and app id
c_application_id :=wf_engine.GetItemAttrNumber(itemtype => itemtype ,
                                               itemkey  => itemkey,
                                               aname => 'HR_AME_APP_ID_ATTR');


c_application_id := nvl(c_application_id,800);

c_transaction_id := wf_engine.GetItemAttrNumber(itemtype => itemtype ,
                                               itemkey  => itemkey,
                                               aname => 'TRANSACTION_ID');



c_transaction_type := wf_engine.GetItemAttrText(itemtype => itemtype ,
                                               itemkey  => itemkey,
                                               aname => 'HR_AME_TRAN_TYPE_ATTR');



-- check if we need to call AME for default approvers.

if(c_transaction_type is null) then
hr_utility.trace('In (if(c_transaction_type is null) )):'|| l_proc);
    -- -----------------------------------------------------------------------
-- expose the wf control variables to the custom package
    -- -----------------------------------------------------------------------
    set_custom_wf_globals
      (p_itemtype => itemtype
      ,p_itemkey  => itemkey);
    --
    -- set the next forward to
    --


    -- get the total number of additional approvers for this transaction
        ln_addntl_approvers := NVL(wf_engine.GetItemAttrNumber
                              (itemtype   => itemtype
                              ,itemkey    => itemkey
                              ,aname      => 'ADDITIONAL_APPROVERS_NUMBER'),
                              0);

-- fix for the bug # 1252070

-- attribute to hold the last_default approver from the heirarchy tree.
  OPEN csr_wiav(itemtype,itemkey,'CURRENT_APPROVER_INDEX');
  hr_utility.trace('Going into Fetch after (OPEN csr_wiav(itemtype,itemkey,CURRENT_APPROVER_INDEX)):'|| l_proc);
     FETCH csr_wiav into lv_dummy;
        IF csr_wiav%notfound THEN
     -- create new wf_item_attribute_value to hold
           hr_approval_wf.create_item_attrib_if_notexist
                               (p_item_type  => itemtype
                               ,p_item_key   => itemkey
                               ,p_name   => 'CURRENT_APPROVER_INDEX');

          wf_engine.SetItemAttrNumber
                    (itemtype    => itemtype,
                     itemkey     => itemkey,
                     aname       => 'CURRENT_APPROVER_INDEX',
                     avalue      => NULL);

        END IF;
   CLOSE csr_wiav;





  -- get the current_approver_index
       ln_current_approver_index := NVL(wf_engine.GetItemAttrNumber
                              (itemtype   => itemtype
                              ,itemkey    => itemkey
                              ,aname      => 'CURRENT_APPROVER_INDEX'),
                              0);
  -- set the item name
      lv_item_name := gv_item_name || to_char(ln_current_approver_index + 1);

  -- check if we have additional approver for the next index.
 -- Fix for the bug # 1255826
  IF ln_current_approver_index <= ln_addntl_approvers
  THEN
    hr_utility.trace('In ( IF ln_current_approver_index <= ln_addntl_approvers):'|| l_proc);
    OPEN csr_wiav(itemtype,itemkey,lv_item_name);
      hr_utility.trace('Going into FETCH after(OPEN csr_wiav(itemtype,itemkey,lv_item_name)):'|| l_proc);
     FETCH csr_wiav into lv_dummy;
        IF csr_wiav%notfound THEN
            lv_exists := 'N';
         ELSE
            lv_exists := 'Y';
            lv_isvalid := wf_engine.GetItemAttrText
                                 (itemtype   => itemtype,
                                  itemkey    => itemkey,
                                  aname      => lv_item_name);
            lv_isvalid := NVL(lv_isvalid,' ');

         END IF;
   CLOSE csr_wiav;
 ELSE
  hr_utility.trace('In else of ( IF ln_current_approver_index <= ln_addntl_approvers):'|| l_proc);
    lv_exists := 'N';
 END IF;


 IF lv_exists <>'N' AND lv_isvalid <>'DELETED' THEN
  hr_utility.trace('In (  IF lv_exists <>N AND lv_isvalid <>DELETED):'|| l_proc);
    l_forward_to_person_id :=
          wf_engine.GetItemAttrNumber
                       (itemtype    => itemtype,
                        itemkey     => itemkey,
                        aname       => lv_item_name
                        );

 ELSE
   hr_utility.trace('In  else of (  IF lv_exists <>N AND lv_isvalid <>DELETED):'|| l_proc);
 -- get the last default approver index

    ln_last_default_approver_id := wf_engine.GetItemAttrNumber
                    (itemtype    => itemtype,
                     itemkey     => itemkey,
                     aname       => 'LAST_DEFAULT_APPROVER');



-- get the next approver from the heirarchy tree.
-- fix for bug #2087458
-- the l_current_forward_to_id resetting was removed for default approver.
-- now the from column will show the last approver approved.
   l_forward_to_person_id :=
        hr_approval_custom.Get_Next_Approver
          (p_person_id =>  NVL(ln_last_default_approver_id,
                                   wf_engine.GetItemAttrNumber
                                       (itemtype   => itemtype
                                       ,itemkey    => itemkey
                                       ,aname      => 'CREATOR_PERSON_ID')));
    -- set the last default approver id
 -- 'LAST_DEFAULT_APPROVER'
   wf_engine.SetItemAttrNumber
                    (itemtype    => itemtype,
                     itemkey     => itemkey,
                     aname       => 'LAST_DEFAULT_APPROVER',
                     avalue      => l_forward_to_person_id);
-- set cuurent approval levels reached
  OPEN csr_wiav(itemtype,itemkey,'CURRENT_DEF_APPR_INDEX');
     hr_utility.trace('Going into FETCH  after(OPEN csr_wiav(itemtype,itemkey,CURRENT_DEF_APPR_INDEX)):'|| l_proc);
     FETCH csr_wiav into lv_dummy;
        IF csr_wiav%notfound THEN
     -- create new wf_item_attribute_value to hold
           hr_approval_wf.create_item_attrib_if_notexist
                               (p_item_type  => itemtype
                               ,p_item_key   => itemkey
                               ,p_name   => 'CURRENT_DEF_APPR_INDEX');

          wf_engine.SetItemAttrNumber
                    (itemtype    => itemtype,
                     itemkey     => itemkey,
                     aname       => 'CURRENT_DEF_APPR_INDEX',
                     avalue      => 0);
         ELSE
         ln_curr_def_appr_index  :=
                     wf_engine.GetItemAttrNumber
                    (itemtype    => itemtype,
                     itemkey     => itemkey,
                     aname       => 'CURRENT_DEF_APPR_INDEX'
                     );
       -- increment it and update the item attribute value
           ln_curr_def_appr_index  := ln_curr_def_appr_index + 1;
         wf_engine.SetItemAttrNumber
                    (itemtype    => itemtype,
                     itemkey     => itemkey,
                     aname       => 'CURRENT_DEF_APPR_INDEX',
                     avalue      => ln_curr_def_appr_index);
        END IF;
   CLOSE csr_wiav;

 END IF;

-- set the current_approver_index
 wf_engine.SetItemAttrNumber (itemtype   => itemtype
                              ,itemkey    => itemkey
                              ,aname      => 'CURRENT_APPROVER_INDEX'
                              ,avalue     => (ln_current_approver_index + 1));

else

hr_utility.trace('In else of (if(c_transaction_type is null) )):'|| l_proc);
/*
ame_api.getNextApprover(applicationIdIn =>c_application_id,
                        transactionIdIn =>c_transaction_id,
                        transactionTypeIn =>c_transaction_type,
                        nextApproverOut =>c_next_approver_rec); */

ame_api2.getNextApprovers4
	    (applicationIdIn  => c_application_id
	    ,transactionTypeIn => c_transaction_type
	    ,transactionIdIn => c_transaction_id
	    ,flagApproversAsNotifiedIn=>ame_util.booleanFalse
	    ,approvalProcessCompleteYNOut => v_approvalprocesscompleteynout
	    ,nextApproversOut => v_next_approver_rec);

--l_forward_to_person_id :=c_next_approver_rec.person_id;
if(v_approvalprocesscompleteynout<>'Y') then
  l_forward_to_person_id := v_next_approver_rec(1).orig_system_id;
end if;
end if;  -- check for AME usage

    if ( l_forward_to_person_id is null ) then
        --
        result := 'COMPLETE:F';
        --
    else
        --
        wf_directory.GetUserName
          (p_orig_system    => 'PER'
          ,p_orig_system_id => l_forward_to_person_id
          ,p_name           => l_forward_to_username
          ,p_display_name   => l_forward_to_disp_name);

--
        wf_engine.SetItemAttrNumber
          (itemtype    => itemtype
          ,itemkey     => itemkey
          ,aname       => 'FORWARD_TO_PERSON_ID'
          ,avalue      => l_forward_to_person_id);
        --
        wf_engine.SetItemAttrText
          (itemtype => itemtype
          ,itemkey  => itemkey
          ,aname    => 'FORWARD_TO_USERNAME'
          ,avalue   => l_forward_to_username);
        --
        Wf_engine.SetItemAttrText
          (itemtype => itemtype
          ,itemkey  => itemkey
          ,aname    => 'FORWARD_TO_DISPLAY_NAME'
          ,avalue   => l_forward_to_disp_name);
        --
        -- set forward from to old forward to
        --
        wf_engine.SetItemAttrNumber
          (itemtype    => itemtype
           ,itemkey     => itemkey
          ,aname       => 'FORWARD_FROM_PERSON_ID'
          ,avalue      => l_current_forward_to_id);
       --
       -- Get the username and display name for forward from person
       -- and save to item attributes
       --
       wf_directory.GetUserName
         (p_orig_system       => 'PER'
         ,p_orig_system_id    => l_current_forward_to_id
         ,p_name              => l_forward_from_username
         ,p_display_name      => l_forward_from_disp_name);
      --
      wf_engine.SetItemAttrText
        (itemtype => itemtype
        ,itemkey  => itemkey
        ,aname    => 'FORWARD_FROM_USERNAME'
        ,avalue   => l_forward_from_username);
      --
      wf_engine.SetItemAttrText
        (itemtype => itemtype
        ,itemkey  => itemkey
        ,aname    => 'FORWARD_FROM_DISPLAY_NAME'
,avalue   => l_forward_from_disp_name);
        --
        result := 'COMPLETE:T';
        --
    end if;
    --
elsif ( funmode = 'CANCEL' ) then
hr_utility.trace('In (if ( funmode = CANCEL )):'|| l_proc);    --
    null;
    --
end if;
--
hr_utility.set_location('Leaving: '|| l_proc,45);
EXCEPTION
   WHEN OTHERS THEN
   hr_utility.set_location('EXCEPTION: '|| l_proc,555);
  if csr_wiav%isopen then
      close csr_wiav;
    end if;
END  Get_Next_Approver;


-- ------------------------------------------------------------------------
-- |----------------------< Check_Final_Approver >-------------------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--  Determine if this person is the final manager in the approval chain
--
--
procedure Check_Final_Approver( p_item_type    in varchar2,
                p_item_key     in varchar2,
                p_act_id       in number,
                funmode     in varchar2,
                result      out nocopy varchar2     )
AS
-- Local Variables
l_proc          varchar2(61) := gv_package||'check_final_approver';
l_creator_person_id       per_people_f.person_id%type;
l_forward_to_person_id              per_people_f.person_id%type;
l_current_forward_to_id per_people_f.person_id%type;
ln_addntl_approvers NUMBER  DEFAULT 0;
ln_approval_level       NUMBER DEFAULT 0;
ln_curr_def_appr_index   NUMBER DEFAULT 1;
ln_last_def_approver       NUMBER;
l_dummy                  VARCHAR2(100);
lv_exists               VARCHAR2(10);
lv_isvalid              VARCHAR2(10);
lv_response             VARCHAR2(10);


-- Variables required for AME API
c_application_id integer;
c_transaction_id varchar2(25);
c_transaction_type varchar2(25);
--c_next_approver_rec ame_util.approverRecord;

--
l_current_forward_to_username   wf_users.name%type;
v_approvalprocesscompleteynout varchar2(5);
v_next_approver_rec ame_util.approverstable2;

BEGIN
hr_utility.set_location('Entering: '|| l_proc,5);
--
if ( funmode = 'RUN' ) then
hr_utility.trace('In(if ( funmode = RUN )): '|| l_proc);
    --
    --
    l_creator_person_id := wf_engine.GetItemAttrNumber
                     (itemtype      => p_item_type
                         ,itemkey       => p_item_key
                         ,aname         => 'CREATOR_PERSON_ID');
    --
    l_forward_to_person_id := wf_engine.GetItemAttrNumber
                    (itemtype       => p_item_type
                        ,itemkey        => p_item_key
                        ,aname          =>'FORWARD_TO_PERSON_ID');

-- get the current forward to person
    l_current_forward_to_id :=
      nvl(wf_engine.GetItemAttrNumber
            (itemtype => p_item_type
            ,itemkey  => p_item_key
            ,aname    => 'FORWARD_TO_PERSON_ID'),
          wf_engine.GetItemAttrNumber
            (itemtype   => p_item_type
            ,itemkey    => p_item_key
            ,aname      => 'CREATOR_PERSON_ID'));



c_application_id :=wf_engine.GetItemAttrNumber(itemtype => p_item_type ,
                                               itemkey  => p_item_key,
                                               aname => 'HR_AME_APP_ID_ATTR');


c_application_id := nvl(c_application_id,800);
c_transaction_id := wf_engine.GetItemAttrNumber(itemtype => p_item_type ,
                                               itemkey  => p_item_key,
                                               aname => 'TRANSACTION_ID');



c_transaction_type := wf_engine.GetItemAttrText(itemtype => p_item_type ,
                                               itemkey  => p_item_key,
                                               aname => 'HR_AME_TRAN_TYPE_ATTR');

if(c_transaction_type is not null) then
hr_utility.trace('In(if ( if(c_transaction_type is not null))): '|| l_proc);
l_current_forward_to_username:=   Wf_engine.GetItemAttrText(itemtype => p_item_type
                                                                     ,itemkey  => p_item_key
                                                                     ,aname    => 'FORWARD_TO_USERNAME');
l_current_forward_to_username := nvl(l_current_forward_to_username,wf_engine.GetItemAttrText(itemtype => p_item_type ,
                                               itemkey => p_item_key,
                                               aname   => 'RETURN_TO_USERNAME'));
  -- fix for bug#2677648
  if(l_forward_to_person_id is not null) then
   -- call AME update approval status as approved
   /*
    ame_api.updateApprovalStatus2(applicationIdIn =>c_application_id,
                                  transactionIdIn =>c_transaction_id,
                                  approvalStatusIn =>ame_util.approvedStatus,
                                  approverPersonIdIn =>l_forward_to_person_id,
                                  approverUserIdIn =>null,
                                  transactionTypeIn =>c_transaction_type,
                                  forwardeeIn  =>null); */

    ame_api2.updateApprovalStatus2(applicationIdIn=>c_application_id,
	transactionTypeIn =>c_transaction_type,
	transactionIdIn=>c_transaction_id,
	approvalStatusIn =>ame_util.approvedStatus,
	approverNameIn =>l_current_forward_to_username,
	itemClassIn => null,
	itemIdIn =>null,
	actionTypeIdIn=> null,
	groupOrChainIdIn =>null,
	occurrenceIn =>null,
	forwardeeIn =>ame_util.emptyApproverRecord2,
	updateItemIn =>false);
  end if; -- call for AME update status

     -- call AME to get next approver
     /*
      ame_api.getNextApprover(applicationIdIn =>c_application_id,
                              transactionIdIn =>c_transaction_id,
                            transactionTypeIn =>c_transaction_type,
                              nextApproverOut =>c_next_approver_rec); */

      ame_api2.getNextApprovers4
	    (applicationIdIn  => c_application_id
	    ,transactionTypeIn => c_transaction_type
	    ,transactionIdIn => c_transaction_id
	    ,flagApproversAsNotifiedIn=>ame_util.booleanFalse
	    ,approvalProcessCompleteYNOut => v_approvalprocesscompleteynout
	    ,nextApproversOut => v_next_approver_rec);

      -- check if the person_id of the next approver is null
           IF(v_approvalprocesscompleteynout = 'Y') THEN
           result := 'COMPLETE:'||'Y';
           ELSE
           result := 'COMPLETE:'||'N';
           END IF;


else
  hr_utility.trace('In else of ( if(c_transaction_type is not null))): '|| l_proc);
  l_forward_to_person_id := NVL(l_forward_to_person_id,l_current_forward_to_id);



-- fix for the bug #1252070

-- attribute to hold the last_default approver from the heirarchy tree.
  OPEN csr_wiav(p_item_type,p_item_key,'LAST_DEFAULT_APPROVER');
    hr_utility.trace('Going into FETCH  after(OPEN csr_wiav(p_item_type,p_item_key,LAST_DEFAULT_APPROVER)): '|| l_proc);
     FETCH csr_wiav into l_dummy;
        IF csr_wiav%notfound THEN
     -- create new wf_item_attribute_value to hold
           hr_approval_wf.create_item_attrib_if_notexist
                               (p_item_type  => p_item_type
                               ,p_item_key   => p_item_key
                               ,p_name   => 'LAST_DEFAULT_APPROVER');

          wf_engine.SetItemAttrNumber
                    (itemtype    => p_item_type,
                     itemkey     => p_item_key,
                     aname       => 'LAST_DEFAULT_APPROVER',
                     avalue      => NULL);

        END IF;
   CLOSE csr_wiav;


 -- 'LAST_DEFAULT_APPROVER'
  ln_last_def_approver:=  wf_engine.GetItemAttrNumber
                    (itemtype    => p_item_type,
                     itemkey     => p_item_key,
                     aname       => 'LAST_DEFAULT_APPROVER'
                     );

ln_last_def_approver:= NVL(ln_last_def_approver,l_forward_to_person_id);

    -- -----------------------------------------------------------------------
    -- expose the wf control variables to the custom package
    -- -----------------------------------------------------------------------
    set_custom_wf_globals
      (p_itemtype => p_item_type
      ,p_itemkey  => p_item_key);


-- check if we have default approvers
lv_response := hr_approval_custom.Check_Final_approver
                  (p_forward_to_person_id       => ln_last_def_approver
                  ,p_person_id                  => l_creator_person_id );

IF lv_response <>'N' THEN
 result := 'COMPLETE:'||
                hr_approval_custom.Check_Final_approver
                  (p_forward_to_person_id       => ln_last_def_approver
                  ,p_person_id                  => l_creator_person_id );
hr_utility.set_location('Leaving: '|| l_proc,25);
 return;

END IF;

      -- check if we have reached the max limit on the approvers level
      -- the level is based on the heirarchy tree.
      -- get the approval level as conifgured by the HR Rep or Sys Admin
    OPEN csr_wiav(p_item_type
                 ,p_item_key
                 ,'APPROVAL_LEVEL');
                 hr_utility.trace('Going into FETCH  after (OPEN csr_wiav(p_item_type,p_item_key,APPROVAL_LEVEL)):'|| l_proc);
    FETCH csr_wiav into l_dummy;
      IF csr_wiav%notfound  THEN
         ln_approval_level := 0;
      ELSE
         ln_approval_level := wf_engine.GetItemAttrNumber
                                  (itemtype   => p_item_type,
                                   itemkey    => p_item_key,
                                   aname      => 'APPROVAL_LEVEL');
      END IF; -- for    csr_wiav%notfound
   CLOSE  csr_wiav;

  IF  ln_approval_level > 0 THEN
        -- get the current approval level reached
      -- first check if the attribute exists
         hr_utility.trace('In ( IF  ln_approval_level > 0 THEN):'|| l_proc);
    OPEN csr_wiav(p_item_type
                 ,p_item_key
                 ,'CURRENT_DEF_APPR_INDEX');
   hr_utility.trace('Going into FETCH  after( csr_wiav(p_item_type,p_item_key,CURRENT_DEF_APPR_INDEX)):'|| l_proc);
    FETCH csr_wiav into l_dummy;
      IF csr_wiav%notfound  THEN
         NULL;
      ELSE
        ln_curr_def_appr_index := wf_engine.GetItemAttrNumber
                                        (itemtype   => p_item_type,
                                        itemkey    => p_item_key,
                                        aname      => 'CURRENT_DEF_APPR_INDEX');
      END IF;-- for    csr_wiav%notfound
   CLOSE  csr_wiav;

END IF; -- for   ln_num_of_add_apprs > 0


-- Fix for the Bug # 1255826
IF (ln_approval_level> 0)

 THEN
  hr_utility.trace('In ( IF  ln_approval_level > 0 THEN):'|| l_proc);
          IF(  ln_curr_def_appr_index < ln_approval_level)
           THEN

           -- we have not reached the approval level as configured
           result := 'COMPLETE:'||'N';
           ELSE
           result := 'COMPLETE:'||'Y';
           END IF;
 ELSE
   hr_utility.trace('In Eelse of  ( IF  ln_approval_level > 0 THEN):'|| l_proc);
 	   result := 'COMPLETE:'||
                         hr_approval_custom.Check_Final_approver
                           (p_forward_to_person_id       => ln_last_def_approver
                           ,p_person_id                  => l_creator_person_id );
END IF;

end if ; -- check for AME

elsif ( funmode = 'CANCEL' ) then
hr_utility.trace('In(if ( funmode = CANCEL )): '|| l_proc);

    --
    null;
    --
end if;
hr_utility.set_location('Leaving: '|| l_proc,50);


EXCEPTION
   WHEN OTHERS THEN
   hr_utility.set_location('EXCEPTION: '|| l_proc,555);
  if csr_wiav%isopen then
      close csr_wiav;
    end if;
END Check_Final_Approver ;

-- ---------------------------------------------------------------------------------
-- |----------------------< Check_Final_OnSubmit_Notifier >-------------------------|
-- ---------------------------------------------------------------------------------
--
-- Description
--
--  Determine if this person is the final manager in the approval chain
--
--
procedure Check_OnSubmit_Notifier( itemtype    in varchar2,
                itemkey     in varchar2,
                actid       in number,
                funmode     in varchar2,
                result      out nocopy varchar2     )
AS
-- Local Variables
ln_current_index             NUMBER;
ln_number_of_notifiers       NUMBER;
lv_dummy                     VARCHAR2(10);
lv_exists                     VARCHAR2(10);
lv_status                    VARCHAR2(10);
lv_item_name                 hr_dynamic_approval_web.gv_notifier_name%type;
lv_notify                    VARCHAR2(10);
lv_submit                    VARCHAR2(10);
l_proc constant varchar2(100) := g_package || ' Check_OnSubmit_Notifier';
BEGIN
 hr_utility.set_location('Entering: '|| l_proc,5);
--
if ( funmode = 'RUN' ) then
 hr_utility.trace('In (if ( funmode = RUN )): '|| l_proc);
    --
    --
-- get the total number of notifiers for the trnsaction
   OPEN csr_wiav(itemtype,itemkey,'NOTIFIERS_NUMBER');
   hr_utility.trace('Going into FETCH  after( OPEN csr_wiav(itemtype,itemkey,NOTIFIERS_NUMBER)):'|| l_proc);
   FETCH csr_wiav into lv_dummy;
   IF csr_wiav%notfound THEN
    ln_number_of_notifiers := 0;
   ELSE
    ln_number_of_notifiers:=
                  wf_engine.GetItemAttrNumber
                        (itemtype    => itemtype,
                         itemkey     => itemkey,
                         aname       => 'NOTIFIERS_NUMBER'
                         );
   END IF;
   CLOSE csr_wiav;

-- get the current index of the onapproval notifier

     OPEN csr_wiav(itemtype,itemkey,'CURRENT_ONSUBMIT_INDEX');
      hr_utility.trace('Going into  FETCH  after( OPEN csr_wiav(itemtype,itemkey,CURRENT_ONSUBMIT_INDEX)):'|| l_proc);
     FETCH csr_wiav into lv_dummy;
        IF csr_wiav%notfound THEN
          lv_exists := 'N';
          ln_current_index := 1;

         ELSE
         ln_current_index:=
                        NVL( wf_engine.GetItemAttrNumber
                            (itemtype    => itemtype,
                             itemkey     => itemkey,
                             aname       => 'CURRENT_ONSUBMIT_INDEX')
                           ,0);
        END IF;
    CLOSE csr_wiav;

ln_current_index := ln_current_index +1;
-- check if there are any notifiers

IF ln_number_of_notifiers > 0 THEN
      hr_utility.trace('In(IF ln_number_of_notifiers > 0 ):'|| l_proc);
   IF ln_current_index <= ln_number_of_notifiers THEN
         hr_utility.trace('In( IF ln_current_index <= ln_number_of_notifiers ):'|| l_proc);
   -- loop through all the notifiers to check status
            hr_utility.trace('Going into(  FOR I in ln_current_index..ln_number_of_notifiers ):'|| l_proc);
      FOR I in ln_current_index..ln_number_of_notifiers
      LOOP
         lv_item_name := gv_notifier_name||to_char(I);

         OPEN csr_wiav(itemtype,itemkey,lv_item_name);
            hr_utility.trace('Going into FETCH  after (OPEN csr_wiav(itemtype,itemkey,lv_item_name)):'|| l_proc);
        FETCH csr_wiav into lv_dummy;
        IF csr_wiav%notfound THEN
         lv_exists := 'N';
       ELSE
           lv_exists := 'Y';
           lv_notify := wf_engine.GetItemAttrText
                    (itemtype    => itemtype,
                     itemkey     => itemkey,
                     aname       => lv_item_name
                     );
         END IF; -- for csr_wiav%notfound
        CLOSE csr_wiav;
       IF lv_exists = 'Y' THEN
          lv_submit:= SUBSTR(lv_notify,1,1);
       END IF; -- for lv_exists = 'Y'
       IF lv_submit='Y' THEN
          result := 'COMPLETE:'||'N';
          return;
       ELSE
          result := 'COMPLETE:'||'Y';
       END IF;

      END LOOP;
     hr_utility.trace('Out of (  FOR I in ln_current_index..ln_number_of_notifiers ):'|| l_proc);
 ELSE
          hr_utility.trace('In else of ( IF ln_current_index <= ln_number_of_notifiers ):'|| l_proc);
      result := 'COMPLETE:'||'Y';
 END IF; -- for ln_current_index < ln_number_of_notifiers


ELSE
      hr_utility.trace('In else of (IF ln_number_of_notifiers > 0 ):'|| l_proc);
   result := 'COMPLETE:'||'Y';
END IF; -- for ln_number_of_notifiers > 0

--
elsif ( funmode = 'CANCEL' ) then

 hr_utility.trace('In elsif ( funmode = CANCEL ) then): '|| l_proc);
    --
    null;
    --
end if;

hr_utility.set_location('Leaving: '|| l_proc,50);
EXCEPTION
   WHEN OTHERS THEN
   hr_utility.set_location('EXCEPTION: '|| l_proc,555);
  if csr_wiav%isopen then
      close csr_wiav;
    end if;

END  Check_OnSubmit_Notifier ;

-- ---------------------------------------------------------------------------------
-- |----------------------< Check_OnApproval_Notifier >-------------------------|
-- ---------------------------------------------------------------------------------
--
-- Description
--
--  Determine if this person is the final manager in the approval chain
--
--
procedure  Check_OnApproval_Notifier( itemtype    in varchar2,
                itemkey     in varchar2,
                actid       in number,
                funmode     in varchar2,
                result      out nocopy varchar2     )
AS
-- Local Variables
ln_current_index             NUMBER;
ln_number_of_notifiers       NUMBER;
lv_dummy                     VARCHAR2(10);
lv_exists                    VARCHAR2(10);
lv_status                    VARCHAR2(10);
lv_item_name                 hr_dynamic_approval_web.gv_notifier_name%type;
lv_notify                    VARCHAR2(10);
lv_onapproval                VARCHAR2(10);
l_proc constant varchar2(100) := g_package || ' Check_OnApproval_Notifier';
BEGIN
hr_utility.set_location('Entering: '|| l_proc,5);
--
if ( funmode = 'RUN' ) then
    --
    --
hr_utility.trace('In (if ( funmode = RUN )): '|| l_proc);
-- get the total number of notifiers for the trnsaction
   OPEN csr_wiav(itemtype,itemkey,'NOTIFIERS_NUMBER');
    hr_utility.trace('Going into (  FETCH csr_wiav into lv_dummy;):'|| l_proc);
   FETCH csr_wiav into lv_dummy;
   IF csr_wiav%notfound THEN
    ln_number_of_notifiers := 0;
   ELSE
    ln_number_of_notifiers:=
                  wf_engine.GetItemAttrNumber
                        (itemtype    => itemtype,
                         itemkey     => itemkey,
                         aname       => 'NOTIFIERS_NUMBER'
                         );
   END IF;
   CLOSE csr_wiav;

-- get the current index of the onapproval notifier

     OPEN csr_wiav(itemtype,itemkey,'CURRENT_ONAPPROVAL_INDEX');
  hr_utility.trace('Going into (  FETCH  after OPEN csr_wiav(itemtype,itemkey,CURRENT_ONAPPROVAL_INDEX):'|| l_proc);
     FETCH csr_wiav into lv_dummy;
        IF csr_wiav%notfound THEN
          lv_exists := 'N';
          ln_current_index := 1;

         ELSE
         ln_current_index:=
                         NVL(wf_engine.GetItemAttrNumber
                            (itemtype    => itemtype,
                             itemkey     => itemkey,
                             aname       => 'CURRENT_ONAPPROVAL_INDEX'
                           ),0);
        END IF;
    CLOSE csr_wiav;

ln_current_index := ln_current_index +1;

-- check if there are any notifiers

IF ln_number_of_notifiers > 0 THEN
hr_utility.trace('In ( IF ln_number_of_notifiers > 0): '|| l_proc);
   IF ln_current_index <= ln_number_of_notifiers THEN
   hr_utility.trace('In (IF ln_current_index <= ln_number_of_notifiers): '|| l_proc);
   -- loop through all the notifiers to check status
 hr_utility.trace('Going into (  FOR I in ln_current_index..ln_number_of_notifiers): '|| l_proc);
      FOR I in ln_current_index..ln_number_of_notifiers
      LOOP
         lv_item_name := gv_notifier_name||to_char(I);

         OPEN csr_wiav(itemtype,itemkey,lv_item_name);
 hr_utility.trace('Going Fetch after (OPEN csr_wiav(itemtype,itemkey,lv_item_name);): '|| l_proc);
        FETCH csr_wiav into lv_dummy;
        IF csr_wiav%notfound THEN


         lv_exists := 'N';
       ELSE
           lv_exists := 'Y';
           lv_notify := wf_engine.GetItemAttrText
                    (itemtype    => itemtype,
                     itemkey     => itemkey,
                     aname       => lv_item_name
                     );
         END IF; -- for csr_wiav%notfound
        CLOSE csr_wiav;
       IF lv_exists = 'Y' THEN
          lv_onapproval:= SUBSTR(lv_notify,3,3);
       END IF; -- for lv_exists = 'Y'
       IF lv_onapproval='Y' THEN
          result := 'COMPLETE:'||'N';
          hr_utility.set_location('Leaving: '|| l_proc,45);
          return;
       ELSE
          result := 'COMPLETE:'||'Y';
       END IF;

      END LOOP;
 hr_utility.trace('Out of (  FOR I in ln_current_index..ln_number_of_notifiers): '|| l_proc);
 ELSE
    hr_utility.trace('In else of (IF ln_current_index <= ln_number_of_notifiers): '|| l_proc);
      result := 'COMPLETE:'||'Y';
 END IF; -- for ln_current_index < ln_number_of_notifiers


ELSE
hr_utility.trace('In else of  ( IF ln_number_of_notifiers > 0): '|| l_proc);
   result := 'COMPLETE:'||'Y';
END IF; -- for ln_number_of_notifiers > 0

--

elsif ( funmode = 'CANCEL' ) then
hr_utility.trace('In (elsif ( funmode = CANCEL )): '|| l_proc);
    --
    null;
    --
end if;

hr_utility.set_location('Leaving: '|| l_proc,55);
--

EXCEPTION
   WHEN OTHERS THEN
   hr_utility.set_location('EXCEPTION: '|| l_proc,555);
  if csr_wiav%isopen then
      close csr_wiav;
    end if;

END  Check_OnApproval_Notifier ;

-- ------------------------------------------------------------------------
-- |------------------------< Get_OnSubmit_notifier >-------------------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--  Get the next notifier in the chain
--
--
procedure Get_OnSubmit_Notifier (   itemtype    in varchar2,
                itemkey     in varchar2,
                actid       in number,
                funmode     in varchar2,
                result      out nocopy varchar2     )
AS

-- Local Variables
  l_creator_person_id     per_people_f.person_id%type;
  l_forward_from_person_id    per_people_f.person_id%type;
  l_forward_from_username     wf_users.name%type;
  l_forward_from_disp_name    wf_users.display_name%type;
  l_forward_to_person_id      per_people_f.person_id%type;
  l_forward_to_username       wf_users.name%type;
  l_forward_to_disp_name      wf_users.display_name%type;
  l_proc                      varchar2(61) := gv_package||'get_next_approver';
  l_current_forward_to_id     per_people_f.person_id%type;
  l_current_forward_from_id   per_people_f.person_id%type;
  lv_last_approver_def        VARCHAR2(10) DEFAULT 'Y';
  ln_current_approver_index   NUMBER ;
  ln_curr_def_appr_index      NUMBER;
  ln_last_default_approver_id per_people_f.person_id%type;
  ln_addntl_approver_id       per_people_f.person_id%type;
  ln_addntl_approvers         NUMBER;
  lv_exists                   VARCHAR2(10);
  lv_dummy                    VARCHAR2(20);
  lv_isvalid                  VARCHAR2(10);
  ln_notifiers                NUMBER DEFAULT 0;
  ln_current_onsubmit_index   NUMBER ;
  ln_person_id                per_people_f.person_id%type DEFAULT NULL;
  lv_notify                   VARCHAR2(10);
  lv_onsubmit                 VARCHAR2(10);
  lv_item_name                VARCHAR2(25);
  ln_start_index              NUMBER;

BEGIN
hr_utility.set_location('Entering: '|| l_proc,5);
if ( funmode = 'RUN' ) then
hr_utility.trace('In (if ( funmode = RUN )): '|| l_proc);
  -- get the total number ofnotifiers
   ln_notifiers :=  wf_engine.GetItemAttrNumber
                    (itemtype    => itemtype,
                     itemkey     => itemkey,
                     aname       => 'NOTIFIERS_NUMBER'
                     );
  IF ln_notifiers > 0 THEN
  -- get the current index
      ln_current_onsubmit_index :=
             NVL(wf_engine.GetItemAttrNumber
                 (itemtype   => itemtype
                 ,itemkey    => itemkey
                 ,aname      => 'CURRENT_ONSUBMIT_INDEX'),0);

  ELSE
  hr_utility.set_location('Leaving: '|| l_proc,15);
   result := 'COMPLETE:F';
  return;
  END IF;


    -- -----------------------------------------------------------------------
-- expose the wf control variables to the custom package
    -- -----------------------------------------------------------------------
    set_custom_wf_globals
      (p_itemtype => itemtype
      ,p_itemkey  => itemkey);


   -- loop through and get next notifier
     hr_utility.trace('Going into ( FOR I in (ln_current_onsubmit_index + 1)..ln_notifiers): '|| l_proc);
    FOR I in (ln_current_onsubmit_index + 1)..ln_notifiers
    LOOP
       lv_item_name := gv_notifier_name||to_char(I);
        OPEN csr_wiav(itemtype,itemkey,lv_item_name);
     hr_utility.trace('In Fetch after (  OPEN csr_wiav(itemtype,itemkey,lv_item_name)): '|| l_proc);
        FETCH csr_wiav into lv_dummy;
        IF csr_wiav%notfound THEN
         lv_exists := 'N';
       ELSE
           lv_exists := 'Y';
           ln_person_id:= wf_engine.GetItemAttrNumber
                    (itemtype    => itemtype,
                     itemkey     => itemkey,
                     aname       => lv_item_name
                     );
          lv_notify := wf_engine.GetItemAttrText
                    (itemtype    => itemtype,
                     itemkey     => itemkey,
                     aname       => lv_item_name
                     );
         END IF; -- for csr_wiav%notfound
        CLOSE csr_wiav;

        IF lv_exists = 'Y' THEN
             hr_utility.trace('In  (  IF lv_exists = Y): '|| l_proc);
           lv_onsubmit := SUBSTR(lv_notify,1,1);
           IF lv_onsubmit= 'Y' THEN
              wf_engine.SetItemAttrNumber
                    (itemtype    => itemtype,
                     itemkey     => itemkey,
                     aname       => 'CURRENT_ONSUBMIT_INDEX',
                     avalue      => I
                        );
            l_forward_to_person_id := ln_person_id;
            EXIT;
           ELSE
                 l_forward_to_person_id := NULL;
                  result := 'COMPLETE:F';

            END IF;
       ELSE
            hr_utility.trace('In else of (  IF lv_exists = Y): '|| l_proc);
            l_forward_to_person_id := NULL;
            result := 'COMPLETE:F';

       END IF;

    END LOOP;
     hr_utility.trace('Out of ( FOR I in (ln_current_onsubmit_index + 1)..ln_notifiers): '|| l_proc);
    --
    -- set the next forward to
    --

    IF (l_forward_to_person_id is null) THEN
        result := 'COMPLETE:F';
        --
    else
        --
        wf_directory.GetUserName
          (p_orig_system    => 'PER'
          ,p_orig_system_id => l_forward_to_person_id
          ,p_name           => l_forward_to_username
          ,p_display_name   => l_forward_to_disp_name);

--
       hr_approval_wf.create_item_attrib_if_notexist
          (p_item_type    => itemtype
          ,p_item_key     => itemkey
          ,p_name       => 'ONSUB_FWD_TO_PERSON_ID');

        wf_engine.SetItemAttrNumber
          (itemtype    => itemtype
          ,itemkey     => itemkey
          ,aname       => 'ONSUB_FWD_TO_PERSON_ID'
          ,avalue      => l_forward_to_person_id);
        --
       hr_approval_wf.create_item_attrib_if_notexist
          (p_item_type    => itemtype
          ,p_item_key     => itemkey
          ,p_name       => 'ONSUB_FWD_TO_USERNAME');

        wf_engine.SetItemAttrText
          (itemtype => itemtype
          ,itemkey  => itemkey
          ,aname    => 'ONSUB_FWD_TO_USERNAME'
          ,avalue   => l_forward_to_username);
        --

        hr_approval_wf.create_item_attrib_if_notexist
          (p_item_type    => itemtype
          ,p_item_key     => itemkey
          ,p_name       => 'ONSUB_FWD_TO_DISPLAY_NAME');
        wf_engine.SetItemAttrText
          (itemtype => itemtype
          ,itemkey  => itemkey
          ,aname    => 'ONSUB_FWD_TO_DISPLAY_NAME'
          ,avalue   => l_forward_to_disp_name);

        --
        result := 'COMPLETE:T';
        --
    end if;
    --
elsif ( funmode = 'CANCEL' ) then
hr_utility.trace('In elsif ( funmode = CANCEL )): '|| l_proc);
    --
    null;
    --
end if;
hr_utility.set_location('Leaving: '|| l_proc,40);

--

EXCEPTION
   WHEN OTHERS THEN
   hr_utility.set_location('EXCEPTION: '|| l_proc,555);
  if csr_wiav%isopen then
      close csr_wiav;
    end if;
END Get_OnSubmit_Notifier;

--
-- ------------------------------------------------------------------------
-- |------------------------< Get_OnApproval_notifier >-------------------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--  Get the next notifier in the chain
--
--
procedure Get_OnApproval_Notifier (   itemtype    in varchar2,
                itemkey     in varchar2,
                actid       in number,
                funmode     in varchar2,
                result      out nocopy varchar2     )
AS

-- Local Variables
  l_creator_person_id     per_people_f.person_id%type;
  l_forward_from_person_id    per_people_f.person_id%type;
  l_forward_from_username     wf_users.name%type;
  l_forward_from_disp_name    wf_users.display_name%type;
  l_forward_to_person_id      per_people_f.person_id%type DEFAULT NULL;
  l_forward_to_username       wf_users.name%type;
  l_forward_to_disp_name      wf_users.display_name%type;
  l_proc                      varchar2(61) := g_package||'get_next_approver';
  l_current_forward_to_id     per_people_f.person_id%type;
  l_current_forward_from_id   per_people_f.person_id%type;
  lv_last_approver_def        VARCHAR2(10) DEFAULT 'Y';
  ln_current_approver_index   NUMBER ;
  ln_curr_def_appr_index      NUMBER;
  ln_last_default_approver_id per_people_f.person_id%type;
  ln_addntl_approver_id       per_people_f.person_id%type;
  ln_addntl_approvers         NUMBER;
  lv_exists                   VARCHAR2(10);
  lv_dummy                    VARCHAR2(20);
  lv_isvalid                  VARCHAR2(10);
  ln_notifiers                NUMBER DEFAULT 0;
  ln_current_onapproval_index   NUMBER ;
  ln_person_id                per_people_f.person_id%type DEFAULT NULL;
  lv_notify                   VARCHAR2(10);
  lv_onapproval               VARCHAR2(10);
  lv_item_name                VARCHAR2(25);
  ln_start_index              NUMBER;

BEGIN
 hr_utility.set_location('Entering: '|| l_proc,5);

if ( funmode = 'RUN' ) then
 hr_utility.trace('In (if ( funmode = RUN) ): '|| l_proc);

  -- get the total number ofnotifiers
   ln_notifiers :=  wf_engine.GetItemAttrNumber
                    (itemtype    => itemtype,
                     itemkey     => itemkey,
                     aname       => 'NOTIFIERS_NUMBER'
                     );
  IF ln_notifiers > 0 THEN

  -- get the current index
      ln_current_onapproval_index :=
             NVL(wf_engine.GetItemAttrNumber
                 (itemtype   => itemtype
                 ,itemkey    => itemkey
                 ,aname      => 'CURRENT_ONAPPROVAL_INDEX'),0);

  ELSE
   result := 'COMPLETE:F';
   hr_utility.set_location('Leaving: '|| l_proc,15);
  return;
  END IF;


    -- -----------------------------------------------------------------------
-- expose the wf control variables to the custom package
    -- -----------------------------------------------------------------------
    set_custom_wf_globals
      (p_itemtype => itemtype
      ,p_itemkey  => itemkey);


   -- loop through and get next notifier
   hr_utility.trace('Going into (   FOR I in (ln_current_onapproval_index + 1)..ln_notifiers): '|| l_proc);

    FOR I in (ln_current_onapproval_index + 1)..ln_notifiers
    LOOP
       lv_item_name := gv_notifier_name||to_char(I);
        OPEN csr_wiav(itemtype,itemkey,lv_item_name);
         hr_utility.trace('Going into Fetch after  ( OPEN csr_wiav(itemtype,itemkey,lv_item_name)): '|| l_proc);
        FETCH csr_wiav into lv_dummy;
        IF csr_wiav%notfound THEN
         lv_exists := 'N';
       ELSE
           lv_exists := 'Y';
           ln_person_id:= wf_engine.GetItemAttrNumber
                    (itemtype    => itemtype,
                     itemkey     => itemkey,
                     aname       => lv_item_name
                     );
          lv_notify := wf_engine.GetItemAttrText
                    (itemtype    => itemtype,
                     itemkey     => itemkey,
                     aname       => lv_item_name
                     );
         END IF; -- for csr_wiav%notfound
        CLOSE csr_wiav;

        IF lv_exists = 'Y' THEN
           hr_utility.trace('In (IF lv_exists = Y): '|| l_proc);
           lv_onapproval := SUBSTR(lv_notify,3,3);
           IF lv_onapproval= 'Y' THEN
                      hr_utility.trace('In (IF lv_onapproval = Y): '|| l_proc);
              wf_engine.SetItemAttrNumber
                    (itemtype    => itemtype,
                     itemkey     => itemkey,
                     aname       => 'CURRENT_ONAPPROVAL_INDEX',
                     avalue      => I
                        );
            l_forward_to_person_id := ln_person_id;
            EXIT;
        ELSE
            hr_utility.trace('In else of  (IF lv_exists = Y): '|| l_proc);
            l_forward_to_person_id := NULL;
            result := 'COMPLETE:F';

            END IF;
      ELSE
         l_forward_to_person_id := NULL;
         result := 'COMPLETE:F';

       END IF;

    END LOOP;
   hr_utility.trace('Out of (FOR I in (ln_current_onapproval_index + 1)..ln_notifiers): '|| l_proc);
    --
    -- set the next forward to
    --

    IF (l_forward_to_person_id is null) THEN
        result := 'COMPLETE:F';
        --
    else
        --
        wf_directory.GetUserName
          (p_orig_system    => 'PER'
          ,p_orig_system_id => l_forward_to_person_id
          ,p_name           => l_forward_to_username
          ,p_display_name   => l_forward_to_disp_name);

--
       hr_approval_wf.create_item_attrib_if_notexist
          (p_item_type    => itemtype
          ,p_item_key     => itemkey
          ,p_name       => 'ONAPPR_FWD_TO_PERSON_ID');
        wf_engine.SetItemAttrNumber
          (itemtype    => itemtype
          ,itemkey     => itemkey
          ,aname       => 'ONAPPR_FWD_TO_PERSON_ID'
          ,avalue      => l_forward_to_person_id);
        --
       hr_approval_wf.create_item_attrib_if_notexist
          (p_item_type    => itemtype
          ,p_item_key     => itemkey
          ,p_name       => 'ONAPPR_FWD_TO_USERNAME');
        wf_engine.SetItemAttrText
          (itemtype => itemtype
          ,itemkey  => itemkey
          ,aname    => 'ONAPPR_FWD_TO_USERNAME'
          ,avalue   => l_forward_to_username);
        --
        hr_approval_wf.create_item_attrib_if_notexist
          (p_item_type    => itemtype
          ,p_item_key     => itemkey
          ,p_name       => 'ONAPPR_FWD_TO_DISPLAY_NAME');
        wf_engine.SetItemAttrText
          (itemtype => itemtype
          ,itemkey  => itemkey
          ,aname    => 'ONAPPR_FWD_TO_DISPLAY_NAME'
          ,avalue   => l_forward_to_disp_name);
        --
        -- set forward from to old forward to
        --
        wf_engine.SetItemAttrNumber
          (itemtype    => itemtype
           ,itemkey     => itemkey
          ,aname       => 'ONAPPR_FWD_FROM_PERSON_ID'
          ,avalue      => l_current_forward_to_id);

        --
        result := 'COMPLETE:T';
        --
    end if;
    --
elsif ( funmode = 'CANCEL' ) then
 hr_utility.trace('In (elsif ( funmode = CANCEL ) ): '|| l_proc);
    --
    null;
    --
end if;
hr_utility.set_location('Leaving: '|| l_proc,45);

EXCEPTION
   WHEN OTHERS THEN
   hr_utility.set_location('EXCEPTION: '|| l_proc,555);
  if csr_wiav%isopen then
      close csr_wiav;
    end if;
END Get_OnApproval_Notifier;



-- ---------------------------------------------------------------------------
-- |-------------------------< set_first_onsubmit_person>----------------|
-- ---------------------------------------------------------------------------
procedure set_first_onsubmit_person
  (itemtype in     varchar2
  ,itemkey  in     varchar2
  ,actid    in     number
  ,funmode  in     varchar2
  ,result      out nocopy varchar2) is
  -- -------------------------------------------------------------------------
  -- local variables
  -- -------------------------------------------------------------------------


ln_notifiers           NUMBER;
l_dummy		       VARCHAR2(10);
lv_exist               VARCHAR2(10);
ln_person_id           NUMBER;
lv_notify              VARCHAR2(10);
lv_onsubmit            VARCHAR2(10);
lv_item_name           VARCHAR2(25);
l_proc constant varchar2(100) := g_package || ' set_first_onsubmit_person';
--
begin
  -- check the workflow funmode value
  hr_utility.set_location('Entering: '|| l_proc,5);
  if funmode = 'RUN' then
  hr_utility.trace('In( if funmode = RUN): '|| l_proc);
    -- workflow is RUNing this procedure
    --
        --
      -- get the total number of notifiers
         ln_notifiers :=
            wf_engine.GetItemAttrNumber(itemtype   => itemtype,
                                         itemkey    => itemkey,
                                         aname      => 'NOTIFIERS_NUMBER');
     -- loop through the notifiers to get the first on submit notifier
     hr_utility.trace('Going into(  FOR I IN 1..ln_notifiers): '|| l_proc);
        FOR I IN 1..ln_notifiers
     LOOP
        lv_item_name := gv_notifier_name||to_char(I);
        OPEN csr_wiav(itemtype,itemkey,lv_item_name);
        hr_utility.trace('Going into Fetch after (  OPEN csr_wiav(itemtype,itemkey,lv_item_name);): '|| l_proc);
        FETCH csr_wiav into l_dummy;
        IF csr_wiav%notfound THEN
         lv_exist := 'N';
       ELSE
           lv_exist := 'Y';
           ln_person_id:= wf_engine.GetItemAttrNumber
                    (itemtype    => itemtype,
                     itemkey     => itemkey,
                     aname       => lv_item_name
                     );
          lv_notify := wf_engine.GetItemAttrText
                    (itemtype    => itemtype,
                     itemkey     => itemkey,
                     aname       => lv_item_name
                     );
         END IF; -- for csr_wiav%notfound
        CLOSE csr_wiav;
        IF lv_exist = 'Y' THEN
          hr_utility.trace('In ( IF lv_exist = Y): '|| l_proc);
          lv_onsubmit := SUBSTR(lv_notify,1,1);
           IF lv_onsubmit= 'Y' THEN
            hr_utility.trace('In (IF lv_onsubmit= Y): '|| l_proc);
         -- set the person id and start index
            wf_engine.SetItemAttrNumber
                    (itemtype    => itemtype,
                     itemkey     => itemkey,
                     aname       => 'ONSUBMIT_START_INDEX',
                     avalue      => I
                     );

            wf_engine.SetItemAttrNumber
                    (itemtype    => itemtype,
                     itemkey     => itemkey,
                     aname       => 'ONSUBMIT_START_PERSON_ID',
                     avalue      => ln_person_id
                     );
           result := 'COMPLETE:SUCCESS';
            EXIT;
            END IF;
      END IF;
   END LOOP;
     hr_utility.trace('Out of (  FOR I IN 1..ln_notifiers): '|| l_proc);
  elsif funmode = 'CANCEL' then
    -- workflow is calling in cancel mode (performing a loop reset) so ignore
    hr_utility.trace('In( elsif funmode = CANCEL): '|| l_proc);
    null;
  end if;
  hr_utility.set_location('Leaving: '|| l_proc,40);


  EXCEPTION
   WHEN OTHERS THEN
   hr_utility.set_location('EXCEPTION: '|| l_proc,555);
  if csr_wiav%isopen then
      close csr_wiav;
    end if;
end set_first_onsubmit_person;


-- ---------------------------------------------------------------------------
-- |-------------------------< set_first_onapproval_person>----------------|
-- ---------------------------------------------------------------------------
procedure set_first_onapproval_person
  (itemtype in     varchar2
  ,itemkey  in     varchar2
  ,actid    in     number
  ,funmode  in     varchar2
  ,result      out nocopy varchar2) is
  -- -------------------------------------------------------------------------
  -- local variables
  -- -------------------------------------------------------------------------


ln_notifiers           NUMBER;
l_dummy		       VARCHAR2(10);
lv_exist               VARCHAR2(10);
ln_person_id           NUMBER;
lv_notify              VARCHAR2(10);
lv_onsubmit            VARCHAR2(10);
lv_item_name           VARCHAR2(25);
l_proc constant varchar2(100) := g_package || ' set_first_onapproval_person';
--
begin
  hr_utility.set_location('Entering: '|| l_proc,5);
  -- check the workflow funmode value
  if funmode = 'RUN' then
hr_utility.trace('In( if funmode = RUN): '|| l_proc);
    -- workflow is RUNing this procedure
    --
        --
      -- get the total number of notifiers
         ln_notifiers :=
            wf_engine.GetItemAttrNumber(itemtype   => itemtype,
                                         itemkey    => itemkey,
                                         aname      => 'NOTIFIERS_NUMBER');
     -- loop through the notifiers to get the first on submit notifier
hr_utility.trace('Going into (FOR I IN 1..ln_notifiers): '|| l_proc);
        FOR I IN 1..ln_notifiers
     LOOP
        lv_item_name := gv_notifier_name||to_char(I);
        OPEN csr_wiav(itemtype,itemkey,lv_item_name);
        hr_utility.trace('Going into Fetch after ( FETCH csr_wiav into l_dummy;): '|| l_proc);
        FETCH csr_wiav into l_dummy;
        IF csr_wiav%notfound THEN
         lv_exist := 'N';
       ELSE
           lv_exist := 'Y';
           ln_person_id:= wf_engine.GetItemAttrNumber
                    (itemtype    => itemtype,
                     itemkey     => itemkey,
                     aname       => lv_item_name
                     );
          lv_notify := wf_engine.GetItemAttrText
                    (itemtype    => itemtype,
                     itemkey     => itemkey,
                     aname       => lv_item_name
                     );
         END IF; -- for csr_wiav%notfound
        CLOSE csr_wiav;

        IF lv_exist = 'Y' THEN
        hr_utility.trace('In(IF lv_exist = Y): '|| l_proc);
          lv_onsubmit :=SUBSTR(lv_notify,3,3);
           IF lv_onsubmit= 'Y' THEN
              hr_utility.trace('In(IF lv_onsubmit = Y): '|| l_proc);
         -- set the person id and start index
            wf_engine.SetItemAttrNumber
                    (itemtype    => itemtype,
                     itemkey     => itemkey,
                     aname       => 'ONAPPROVAL_START_INDEX',
                     avalue      => I
                     );

             wf_engine.SetItemAttrNumber
                    (itemtype    => itemtype,
                     itemkey     => itemkey,
                     aname       => 'ONAPPROVAL_START_PERSON_ID',
                     avalue      => ln_person_id
                    );
              result := 'COMPLETE:SUCCESS';
             EXIT;
            END IF;
      END IF;
   END LOOP;
hr_utility.trace('Out of (FOR I IN 1..ln_notifiers): '|| l_proc);
  elsif funmode = 'CANCEL' then
    -- workflow is calling in cancel mode (performing a loop reset) so ignore
     hr_utility.trace('In( elsif funmode = CANCEL): '|| l_proc);
    null;
  end if;
  hr_utility.set_location('Leaving: '|| l_proc,45);

  EXCEPTION
   WHEN OTHERS THEN
   hr_utility.set_location('EXCEPTION: '|| l_proc,555);
  if csr_wiav%isopen then
      close csr_wiav;
    end if;
  END set_first_onapproval_person;


-- ---------------------------------------------------------------------------
-- public Procedure declarations
-- ---------------------------------------------------------------------------
--
-- ----------------------------------------------------------------------------
-- |------------------------------< initialize_item_attributes>-------------------|
-- ----------------------------------------------------------------------------
--
-- This procedure initializes item attributes for the onsubmit and onapproval process.
-- The procedure sets the start index for onsubmit notifier and onapproval notifier.
--


procedure initialize_item_attributes
  (itemtype in     varchar2
  ,itemkey  in     varchar2
  ,actid    in     number
  ,funmode  in     varchar2
,result      out nocopy varchar2)
AS
-- Local Variables
l_dummy                 VARCHAR2(100);
l_proc constant varchar2(100) := g_package || ' initialize_item_attributes';
BEGIN
hr_utility.set_location('Entering: '|| l_proc,5);
-- check the workflow funmode value

  if funmode = 'RUN' then
hr_utility.trace('In( if funmode = RUN): '|| l_proc);
    -- workflow is RUNing this procedure
    --
    --
    -- Test that all  new attributes exist and if they don't create them

    -- create new wf_item_attribute_value to hold the additional approvers number
           hr_approval_wf.create_item_attrib_if_notexist
                               (p_item_type  => itemtype
                               ,p_item_key   => itemkey
                               ,p_name   => 'ADDITIONAL_APPROVERS_NUMBER');



 -- attribute to hold the approval levels for confguration.
  OPEN csr_wiav(itemtype,itemkey,'APPROVAL_LEVEL');
 hr_utility.trace('Going into Fetch after ( OPEN csr_wiav(itemtype,itemkey,APPROVAL_LEVEL)): '|| l_proc);
     FETCH csr_wiav into l_dummy;
        IF csr_wiav%notfound THEN
     -- create new wf_item_attribute_value to hold
           hr_approval_wf.create_item_attrib_if_notexist
                               (p_item_type  => itemtype
                               ,p_item_key   => itemkey
                               ,p_name   => 'APPROVAL_LEVEL');

        END IF;
   CLOSE csr_wiav;


-- attribute to hold the current default approver index .
  OPEN csr_wiav(itemtype,itemkey,'CURRENT_DEF_APPR_INDEX');
   hr_utility.trace('Going into Fetch after ( OPEN csr_wiav(itemtype,itemkey,CURRENT_DEF_APPR_INDEX)): '|| l_proc);
     FETCH csr_wiav into l_dummy;
        IF csr_wiav%notfound THEN
     -- create new wf_item_attribute_value to hold
           hr_approval_wf.create_item_attrib_if_notexist
                               (p_item_type  => itemtype
                               ,p_item_key   => itemkey
                               ,p_name   => 'CURRENT_DEF_APPR_INDEX');

          wf_engine.SetItemAttrNumber
                    (itemtype    => itemtype,
                     itemkey     => itemkey,
                     aname       => 'CURRENT_DEF_APPR_INDEX',
                     avalue      => 0);
         ELSE
         wf_engine.SetItemAttrNumber
                    (itemtype    => itemtype,
                     itemkey     => itemkey,
                     aname       => 'CURRENT_DEF_APPR_INDEX',
                     avalue      => 0);
        END IF;
   CLOSE csr_wiav;




    --
    -- These attributes are for the new notification process ,
    -- onsubmit and onapproval

    -- attributes for the onsubmit notification process
    -- CURRENT_ONSUBMIT_INDEX
     hr_approval_wf.create_item_attrib_if_notexist
      (p_item_type  => itemtype
      ,p_item_key   => itemkey
      ,p_name   => 'CURRENT_ONSUBMIT_INDEX');

-- ONSUBMIT_START_INDEX
    hr_approval_wf.create_item_attrib_if_notexist
      (p_item_type  => itemtype
      ,p_item_key   => itemkey
      ,p_name   => 'ONSUBMIT_START_INDEX');

 -- ONSUBMIT_START_PERSON_ID
     hr_approval_wf.create_item_attrib_if_notexist
      (p_item_type  => itemtype
      ,p_item_key   => itemkey
      ,p_name   => 'ONSUBMIT_START_PERSON_ID');

    -- ONSUBMIT_FORWARD_FROM_USERNAME
    hr_approval_wf.create_item_attrib_if_notexist
      (p_item_type  => itemtype
      ,p_item_key   => itemkey
      ,p_name   => 'ONSUB_FWD_FROM_USERNAME');
    --
        -- ONSUBMIT_FORWARD_FROM_PERSON_ID
    hr_approval_wf.create_item_attrib_if_notexist
      (p_item_type  => itemtype
      ,p_item_key   => itemkey
      ,p_name   => 'ONSUB_FWD_FROM_PERSON_ID');
    --
        -- ONSUBMIT_FORWARD_FROM_DISPLAY_NAME
    hr_approval_wf.create_item_attrib_if_notexist
      (p_item_type  => itemtype
      ,p_item_key   => itemkey
      ,p_name   => 'ONSUB_FWD_FROM_DISPLAY_NAME');
    --
        -- ONSUBMIT_FORWARD_TO_USERNAME
    hr_approval_wf.create_item_attrib_if_notexist
      (p_item_type  => itemtype
      ,p_item_key   => itemkey
      ,p_name   => 'ONSUB_FWD_TO_USERNAME');
    --
        -- FORWARD_TO_PERSON_ID
    hr_approval_wf.create_item_attrib_if_notexist
      (p_item_type  => itemtype
      ,p_item_key   => itemkey
      ,p_name   => 'ONSUB_FWD_TO_PERSON_ID');
    --
        -- FORWARD_TO_DISPLAY_NAME
    hr_approval_wf.create_item_attrib_if_notexist
      (p_item_type  => itemtype
      ,p_item_key   => itemkey
      ,p_name   => 'ONSUB_FWD_TO_DISPLAY_NAME');
    --
   -- for onapproval notification process

       -- CURRENT_ONAPPROVAL_INDEX
    hr_approval_wf.create_item_attrib_if_notexist
      (p_item_type  => itemtype
      ,p_item_key   => itemkey
      ,p_name   => 'CURRENT_ONAPPROVAL_INDEX');

-- ONAPPROVAL_START_INDEX
    hr_approval_wf.create_item_attrib_if_notexist
      (p_item_type  => itemtype
      ,p_item_key   => itemkey
      ,p_name   => 'ONAPPROVAL_START_INDEX');
-- ONAPPROVAL_START_PERSON_ID
     hr_approval_wf.create_item_attrib_if_notexist
      (p_item_type  => itemtype
      ,p_item_key   => itemkey
      ,p_name   => 'ONAPPROVAL_START_PERSON_ID');

    -- ONAPPROVAL_FORWARD_FROM_USERNAME
    hr_approval_wf.create_item_attrib_if_notexist
      (p_item_type  => itemtype
      ,p_item_key   => itemkey
      ,p_name   => 'ONAPPR_FWD_FROM_USERNAME');
    --
        -- ONAPPROVAL_FORWARD_FROM_PERSON_ID
    hr_approval_wf.create_item_attrib_if_notexist
      (p_item_type  => itemtype
      ,p_item_key   => itemkey
      ,p_name   => 'ONAPPR_FWD_FROM_PERSON_ID');
    --
        -- ONAPPROVAL_FORWARD_FROM_DISPLAY_NAME
    hr_approval_wf.create_item_attrib_if_notexist
      (p_item_type  => itemtype
      ,p_item_key   => itemkey
      ,p_name   => 'ONAPPR_FWD_FROM_DISPLAY_NAME');
    --
        -- ONAPPROVAL_FORWARD_TO_USERNAME
    hr_approval_wf.create_item_attrib_if_notexist
      (p_item_type  => itemtype
      ,p_item_key   => itemkey
      ,p_name   => 'ONAPPR_FWD_TO_USERNAME');
    --
        -- ONAPPROVAL_FORWARD_TO_PERSON_ID
    hr_approval_wf.create_item_attrib_if_notexist
      (p_item_type  => itemtype
      ,p_item_key   => itemkey
      ,p_name   => 'ONAPPR_FWD_TO_PERSON_ID');
    --
        -- ONAPPROVAL_FORWARD_TO_DISPLAY_NAME
    hr_approval_wf.create_item_attrib_if_notexist
      (p_item_type  => itemtype
      ,p_item_key   => itemkey
      ,p_name   => 'ONAPPR_FWD_TO_DISPLAY_NAME');
    --

    --
    -- -----------------------------------------------------------------------
    -- set workflow activity to the SUCCESS state to end workflow
    -- -----------------------------------------------------------------------
    --result := 'COMPLETE:SUCCESS';
    --
  elsif funmode = 'CANCEL' then
      -- workflow is calling in cancel mode (performing a loop reset) so ignore
   hr_utility.trace('In( elsif funmode = CANCEL): '|| l_proc);
    null;
  end if;
hr_utility.set_location('Leaving: '|| l_proc,25);


EXCEPTION
   WHEN OTHERS THEN
   hr_utility.set_location('EXCEPTION: '|| l_proc,555);
  if csr_wiav%isopen then
        close csr_wiav;
    end if;
END initialize_item_attributes;





procedure set_ame_attributes(itemtype in     varchar2
                            ,itemkey  in     varchar2
                            ,actid    in     number)
AS
-- local variables
l_proc constant varchar2(100) := g_package || ' set_ame_attributes';
begin
 hr_utility.set_location('Entering: '|| l_proc,5);
wf_engine.SetItemAttrNumber(itemtype => itemtype ,
                            itemkey  => itemkey,
                            aname => 'HR_AME_APP_ID_ATTR',
                            avalue=>800);


wf_engine.SetItemAttrText(itemtype => itemtype ,
                          itemkey  => itemkey,
                          aname => 'HR_AME_TRAN_TYPE_ATTR',
                          avalue=> 'SSHRMS');

hr_utility.set_location('Leaving: '|| l_proc,10);
end set_ame_attributes;


-- ---------------------------------------------------------------------------
-- public Procedure declarations
-- ---------------------------------------------------------------------------
--
-- ----------------------------------------------------------------------------
-- |------------------------------< Notify>-------------------|
-- ----------------------------------------------------------------------------
--
-- This procedure is a public wrapper to engine notification call
-- This reads the activity attributes and sends notification to the ROLE defined
-- in the activity attribute PERFORMER with the message conigured in the activity
-- attribute MESSAGE. And also can send to group if configured through the activity
-- attribute EXPANDROLES.
--
procedure Notify(itemtype   in varchar2,
		  itemkey    in varchar2,
      		  actid      in number,
		  funcmode   in varchar2,
		  resultout  in out nocopy varchar2)
is
    msg varchar2(30);
    msgtype varchar2(8);
    prole    wf_users.name%type;
    expand_role varchar2(1);

    colon pls_integer;
    avalue varchar2(240);
    -- local variable
   l_proc constant varchar2(100) := g_package || '  Notify';

begin
 hr_utility.set_location('Entering: '|| l_proc,5);


   -- Do nothing in cancel or timeout mode
   if (funcmode <> wf_engine.eng_run) then
     resultout := wf_engine.eng_null;
     hr_utility.set_location('Leaving: '|| l_proc,10);
     return;
   end if;


--PERFORMER
prole := wf_engine.GetActivityAttrText(
                               itemtype => itemtype,
                               itemkey => itemkey,
                               actid  => actid,
                               aname => 'PERFORMER');


if prole is null then
    Wf_Core.Token('TYPE', itemtype);
    Wf_Core.Token('ACTID', to_char(actid));
    Wf_Core.Raise('WFENG_NOTIFICATION_PERFORMER');
   end if;

-- message name and expand roles will be null. Get these from attributes
   avalue := upper(Wf_Engine.GetActivityAttrText(itemtype, itemkey,
                 actid, 'MESSAGE'));

   -- let notification_send catch a missing message name.
   expand_role := nvl(Wf_Engine.GetActivityAttrText(itemtype, itemkey,
                 actid, 'EXPANDROLES'),'N');

   -- parse out the message type if given
   colon := instr(avalue, ':');
   if colon = 0   then
      msgtype := itemtype;
      msg := avalue;
   else
     msgtype := substr(avalue, 1, colon - 1);
     msg := substr(avalue, colon + 1);
   end if;

   -- Actually send the notification
Wf_Engine_Util.Notification_Send(itemtype, itemkey, actid,
                       msg, msgtype, prole, expand_role,
                       resultout);


   --resultout is determined by Notification_Send as either
   --NULL                  if notification is FYI
   --NOTIFIED:notid:role   if notification requires responce

--resultout := null;
hr_utility.set_location('Leaving: '|| l_proc,15);
exception
  when others then
  hr_utility.set_location('EXCEPTION: '|| l_proc,555);
    Wf_Core.Context('Wf_Standard', 'Notify', itemtype,
                    itemkey, to_char(actid), funcmode);
    raise;
end Notify;



/*-----------------------------------------------------------------------

|| PROCEDURE         : get_ame_approvers_list
||
|| This is a wrapper procedure to get_all_ame_approvers to return
|| the list of default approvers to a java oracle.sql.ARRAY object
||
||
||
||-----------------------------------------------------------------------*/

PROCEDURE get_ame_approvers_list(
    p_item_type     IN wf_items.item_type%TYPE,
    p_item_key      IN wf_items.item_key%TYPE,
    p_default_approvers_list OUT NOCOPY hr_dynamic_approver_list_ss)

AS

--local variables
l_approver_name                 hr_util_misc_web.g_varchar2_tab_type;
l_approver_flag                 hr_util_misc_web.g_varchar2_tab_type;
l_default_approvers_list        hr_dynamic_approver_list_ss := hr_dynamic_approver_list_ss();
l_default_approver              hr_dynamic_approver_ss;
lv_number                       varchar2(10);
ln_creator_person_id            number;
l_no_approvers_list             hr_dynamic_approver_list_ss := hr_dynamic_approver_list_ss();
ln_transaction_id               hr_api_transactions.transaction_id%type;
l_proc constant varchar2(100) := g_package || ' get_ame_approvers_list';
BEGIN
hr_utility.set_location('Entering: '|| l_proc,5);

  -- remove all rows from person details table

  grt_approver_details_table.DELETE;

-- set the gv_mode as this is needed for pl/sql compatibility
   gv_mode:='RE-ENTER';

  -- repopulate the table
hr_utility.trace('calling get_all_ame_approvers ');

   get_all_ame_approvers(p_approver_name  =>l_approver_name,
                            p_approver_flag  =>l_approver_flag,
                            p_item_type =>p_item_type,
                            p_item_key  =>p_item_key);



  -- copy parameters into l_default_approvers_list
  lv_number := grt_approver_details_table.count;

hr_utility.trace('approver count retuned from get_all_ame_approvers :'||nvl(lv_number,0));
hr_utility.trace('Going into ( FOR I IN 1..grt_approver_details_table.count 	): '|| l_proc);
 FOR I IN 1..grt_approver_details_table.count
 LOOP
  hr_utility.trace('building approvers out nocopy list using  hr_dynamic_approver_ss');
  hr_utility.trace(' Adding approver :'||grt_approver_details_table(I).person_id||' to the list');
  l_default_approver := hr_dynamic_approver_ss(
                                       grt_approver_details_table(I).full_name,
                                       grt_approver_details_table(I).person_id,
                                       grt_approver_details_table(I).job_title,
                                       grt_approver_details_table(I).default_approver,
                                       grt_approver_details_table(I).error_exists);

  -- add new row to list
  l_default_approvers_list.EXTEND;

  -- add to list
  l_default_approvers_list(I) := l_default_approver;

 END LOOP;
hr_utility.trace('Out of  ( FOR I IN 1..grt_approver_details_table.count 	): '|| l_proc);
 -- set out parameter
 hr_utility.trace('setting the out nocopy parameter p_default_approvers_list');
 p_default_approvers_list := l_default_approvers_list;

if(grt_approver_details_table.count=1) then
hr_utility.trace('In( if(grt_approver_details_table.count=1) ): '|| l_proc);
hr_utility.trace('only approver in the list');
/*
 -- Work around for the bug#2345264
 -- Remove this check once the AME fixes the issue with ALLOW_REQUESTOR_APPROVAL
 -- attribute.
 -- ame_api.getAllApprovers returns the creator too as the approver
 -- when ALLOW_REQUESTOR_APPROVAL is true.
 -- Needed this for fixing bug# 2337022
*/
 -- get the creator person id
hr_utility.trace('getting the creator person id from WF attr');
/*ln_creator_person_id := wf_engine.GetItemAttrNumber(itemtype => p_item_type ,
                                               itemkey  => p_item_key,
                                               aname => 'CREATOR_PERSON_ID');
*/
 ln_transaction_id :=  wf_engine.GetItemAttrNumber(itemtype => p_item_type ,
                                               itemkey  => p_item_key,
                                               aname => 'TRANSACTION_ID');

ln_creator_person_id := hr_workflow_ss.getApprStartingPointPersonId(ln_transaction_id);

  -- check if the approver id matches the creator
  if( ln_creator_person_id=grt_approver_details_table(1).person_id) then
   hr_utility.trace('creator person id matches the approverid resetting out nocopy param to null ');
   p_default_approvers_list :=l_no_approvers_list;
  end if;
end if;

hr_utility.set_location('Leaving: '|| l_proc,40);

 EXCEPTION
    WHEN OTHERS THEN
    hr_utility.set_location('EXCEPTION: '|| l_proc,555);
    hr_utility.trace(' exception in  '||gv_package||'.get_ame_approvers_list : ' || sqlerrm);
    Wf_Core.Context(gv_package, 'get_ame_approvers_list', p_item_type, p_item_key);
    raise;

END get_ame_approvers_list;

/*-----------------------------------------------------------------------

|| PROCEDURE         : set_ame_approvers_list
||
|| This is a wrapper procedure to get_all_ame_approvers to return
|| the list of default approvers to a java oracle.sql.ARRAY object
||
||
||
||-----------------------------------------------------------------------*/

PROCEDURE set_ame_approvers_list(
    p_item_type     IN wf_items.item_type%TYPE,
    p_item_key      IN wf_items.item_key%TYPE,
    p_default_approvers_list IN hr_dynamic_approver_list_ss)

AS

--local variables
l_approver_name                 hr_util_misc_web.g_varchar2_tab_type;
l_approver_flag                 hr_util_misc_web.g_varchar2_tab_type;
l_default_approvers_list        hr_dynamic_approver_list_ss := hr_dynamic_approver_list_ss();
l_default_approver              hr_dynamic_approver_ss;
l_approvers_list                hr_dynamic_approver_list_ss;
lv_number                       varchar2(10);
l_proc constant varchar2(100) := g_package || ' set_ame_approvers_list';
-- Variables required for AME API
c_application_id integer;
c_transaction_id varchar2(25);
c_transaction_type varchar2(25);
c_next_approver_rec ame_util.approverRecord;
c_additional_approver_order ame_util.orderRecord;
c_additional_approver_rec ame_util.approversTable;

v_next_approver_rec ame_util.approverRecord2;
v_additional_approver_order ame_util.insertionRecord2;


BEGIN
hr_utility.set_location('Entering: '|| l_proc,5);
-- get AME related WF attribute values
  c_application_id :=wf_engine.GetItemAttrNumber(itemtype => p_item_type ,
                                                 itemkey  => p_item_key,
                                                 aname => 'HR_AME_APP_ID_ATTR');

  c_application_id := nvl(c_application_id,800);


  c_transaction_id := wf_engine.GetItemAttrNumber(itemtype => p_item_type ,
                                                  itemkey  => p_item_key,
                                                  aname => 'TRANSACTION_ID');



  c_transaction_type := wf_engine.GetItemAttrText(itemtype => p_item_type ,
                                               itemkey  => p_item_key,
                                               aname => 'HR_AME_TRAN_TYPE_ATTR');



-- call AME to update additional approvers,

 -- clear all the insertions into AME . Need to perform this step ONLY after we get the person id .
  -- other wise it would clear the insertions made in the previous pass.
  /*ame_api.clearInsertions(applicationIdIn =>c_application_id ,
                          transactionIdIn =>c_transaction_id,
                          transactionTypeIn=>c_transaction_type);*/

  AME_API3.clearInsertions(applicationIdIn =>c_application_id ,
                            transactionTypeIn =>c_transaction_type,
                            transactionIdIn =>c_transaction_id);


  if(c_transaction_type is not null) then
  hr_utility.trace('In(  if(c_transaction_type is not null)): '|| l_proc);
    -- update AME list
   hr_utility.trace('Going into ( for i in 1..p_default_approvers_list.count): '|| l_proc);
    for i in 1..p_default_approvers_list.count loop
      -- check for the default approver flag
      if(p_default_approvers_list(i).default_approver='N') then
        -- details for the record insertion into AME
         c_next_approver_rec.person_id:=p_default_approvers_list(i).person_id;
        c_next_approver_rec.api_insertion:= ame_util.apiInsertion;
        c_next_approver_rec.authority:=ame_util.authorityApprover;


	 ame_util.apprRecordToApprRecord2(approverRecordIn => c_next_approver_rec,
                              itemIdIn => c_transaction_id,
                              approverRecord2Out =>v_next_approver_rec);

        -- details for the insertion order for the AME record.
        c_additional_approver_order.order_type:=ame_util.absoluteOrder;
        c_additional_approver_order.parameter:=I;
        c_additional_approver_order.description:=null;
 ame_util.ordRecordToInsRecord2(orderRecordIn =>c_additional_approver_order,
                            transactionIdIn => c_transaction_id,
                            approverIn => c_next_approver_rec,
                            insertionRecord2Out => v_additional_approver_order);

      v_next_approver_rec.action_type_id := v_additional_approver_order.action_type_id;
      v_next_approver_rec.group_or_chain_id  := v_additional_approver_order.group_or_chain_id ;


	AME_API3.insertApprover(applicationIdIn =>c_application_id,
                            transactionTypeIn =>c_transaction_type,
                            transactionIdIn =>c_transaction_id,
                            approverIn =>v_next_approver_rec,
                            positionIn =>I,
                            insertionIn =>v_additional_approver_order);





     /*   ame_api.insertApprover(applicationIdIn =>c_application_id,
                               transactionIdIn =>c_transaction_id,
                               approverIn =>c_next_approver_rec,
                               positionIn =>I,
                               orderIn =>c_additional_approver_order,
                               transactionTypeIn=>c_transaction_type );*/
      end if;
    end loop;
       hr_utility.trace('Out of ( for i in 1..p_default_approvers_list.count): '|| l_proc);
  end if; -- end updating AME list
hr_utility.set_location('Leaving: '|| l_proc,25);

 EXCEPTION
    WHEN OTHERS THEN

    hr_utility.set_location('EXCEPTION: '|| l_proc,555);
    raise;

END set_ame_approvers_list;
/*-----------------------------------------------------------------------

|| PROCEDURE         : get_additional_notifiers_list
||
|| This is a wrapper procedure to get_default_approvers to return
|| the list of default approvers to a java oracle.sql.ARRAY object
||
||
||
||-----------------------------------------------------------------------*/

PROCEDURE get_additional_notifiers_list(
    p_item_type     IN wf_items.item_type%TYPE,
    p_item_key      IN wf_items.item_key%TYPE,
    p_additional_notifiers_list OUT NOCOPY hr_dynamic_approver_list_ss)

AS

--local variables
l_approver_name                 hr_util_misc_web.g_varchar2_tab_type;
l_approver_flag                 hr_util_misc_web.g_varchar2_tab_type;
l_additional_notifiers_list     hr_dynamic_approver_list_ss := hr_dynamic_approver_list_ss();
l_notifier_rec                  hr_dynamic_approver_ss;
lv_number                       varchar2(10);
lv_exist                        VARCHAR2(10) DEFAULT 'N';
l_dummy                         VARCHAR2(100) ;
lv_item_name                    VARCHAR2(100);
lrt_notifier_details_table      hr_dynamic_approval_web.notifier_rec_table;
ln_person_id                    per_people_f.person_id%TYPE;
lv_full_name                    per_people_f.person_id%TYPE;
lv_job_title                    VARCHAR2(1000);
lv_on_submit                    VARCHAR2(10);
lv_on_approval                  VARCHAR2(10);
lv_notify                       VARCHAR2(10);
ln_assignment_id                NUMBER ;
lrt_assignment_details          hr_misc_web.grt_assignment_details;
ln_loop_index                   NUMBER;
ln_job_id                       NUMBER;
l_curr_org_name                 VARCHAR2(100);
l_curr_loc_name                 VARCHAR2(100);
ln_error_count                  NUMBER DEFAULT 1;
l_proc constant varchar2(100) := g_package || ' get_additional_notifiers_list';

BEGIN
hr_utility.set_location('Entering: '|| l_proc,5);
  -- remove all rows from notifiers details table
  grt_notifier_details_table.DELETE;
  -- get the number of notifiers in the system
  OPEN csr_wiav(p_item_type,p_item_key,'NOTIFIERS_NUMBER');
   hr_utility.trace('Going into Fetch after ( OPEN csr_wiav(p_item_type,p_item_key,NOTIFIERS_NUMBER) ): '|| l_proc);
  FETCH csr_wiav into l_dummy;
   IF csr_wiav%notfound THEN
       gn_notifiers := 0;
   ELSE
       gn_notifiers :=
            wf_engine.GetItemAttrNumber(itemtype   => p_item_type,
                                         itemkey    => p_item_key,
                                         aname      => 'NOTIFIERS_NUMBER');
   END IF;
  CLOSE csr_wiav;

  IF gn_notifiers > 0 THEN
  hr_utility.trace('In( IF gn_notifiers > 0): '|| l_proc);
     --loop througthe counter and get all the notifiers

hr_utility.trace('Going into (FOR I IN 1..gn_notifiers): '|| l_proc);
     FOR I IN 1..gn_notifiers
     LOOP
        lv_job_title := NULL;
        lv_item_name := gv_notifier_name||to_char(I);
        OPEN csr_wiav(p_item_type,p_item_key,lv_item_name);
  hr_utility.trace('Going into Fetch after ( OPEN csr_wiav(p_item_type,p_item_key,lv_item_name)): '|| l_proc);
        FETCH csr_wiav into l_dummy;
        IF csr_wiav%notfound THEN
         lv_exist := 'N';
       ELSE
           lv_exist := 'Y';
           ln_person_id:= wf_engine.GetItemAttrNumber
                    (itemtype    => p_item_type,
                     itemkey     => p_item_key,
                     aname       => lv_item_name
                     );
          lv_notify := wf_engine.GetItemAttrText
                    (itemtype    => p_item_type,
                     itemkey     => p_item_key,
                     aname       => lv_item_name
                     );
         END IF; -- for csr_wiav%notfound
        CLOSE csr_wiav;

IF lv_exist = 'Y' THEN
 -- get the person and assignment details for this person_id
   -- get the assignment id
     lrt_assignment_details := hr_misc_web.get_assignment_id(p_person_id => ln_person_id);
     ln_assignment_id       := lrt_assignment_details.assignment_id;
 -- get name and job title for this person id
     lrt_assignment_details := hr_misc_web.get_assignment_details(
                                     p_assignment_id => ln_assignment_id,
                                      p_effective_date =>trunc(sysdate)
                                        );

  -- populate the notifiers rec table
  lrt_notifier_details_table(I).person_id := ln_person_id;
  lrt_notifier_details_table(I).full_name := lrt_assignment_details.person_full_name;

  lv_job_title := hr_dynamic_approval_web.get_job_details
                     (p_person_id =>ln_person_id,
                      p_assignment_id=>ln_assignment_id,
                      p_effective_date=>trunc(sysdate)
                      );
lrt_notifier_details_table(I).job_title := lv_job_title;

  -- parse the lv_notify for these values
  lrt_notifier_details_table(I).on_submit := SUBSTR(lv_notify,1,1);
  lrt_notifier_details_table(I).on_approval := SUBSTR(lv_notify,3,3);

    l_notifier_rec := hr_dynamic_approver_ss(
                                       lrt_notifier_details_table(I).full_name,
                                       lrt_notifier_details_table(I).person_id,
                                       lrt_notifier_details_table(I).job_title ,
                                       lv_notify,
                                       'FALSE');

  -- add new row to list
  l_additional_notifiers_list.EXTEND;

  -- add to list
  l_additional_notifiers_list(I) := l_notifier_rec;



 END IF; -- for lv_exist = 'Y'

END LOOP;
hr_utility.trace('Out of (FOR I IN 1..gn_notifiers): '|| l_proc);
END IF; -- for gn_notifiers > 0

 p_additional_notifiers_list:=l_additional_notifiers_list;
hr_utility.set_location('Leaving: '|| l_proc,35);
 EXCEPTION
    WHEN OTHERS THEN
    hr_utility.set_location('EXCEPTION: '|| l_proc,555);
    if csr_wiav%isopen then
      close csr_wiav;
    end if;
    raise;

END get_additional_notifiers_list;





end hr_dynamic_approval_web;

/
