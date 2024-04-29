--------------------------------------------------------
--  DDL for Package Body BEN_CWB_MASS_NOTIFN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CWB_MASS_NOTIFN_PKG" as
/* $Header: bencwbnf.pkb 120.10.12010000.3 2008/09/18 07:31:00 sgnanama ship $ */

 TYPE pid IS RECORD (
  person_id ben_per_in_ler.person_id%type);

 TYPE person_info IS RECORD (
  full_name ben_cwb_person_info.full_name%type
 ,name per_business_groups_perf.name%type
 ,employee_number ben_cwb_person_info.employee_number%type
 ,person_id ben_per_in_ler.person_id%type
 ,per_in_ler_id ben_per_in_ler.per_in_ler_id%type);

 TYPE the_users IS REF CURSOR;

 TYPE g_person_sel_table_type IS TABLE OF pid;

 TYPE g_users_t IS TABLE OF fnd_user.user_name%type;

 g_actn                 VARCHAR2 (2000);
 g_proc                 VARCHAR2 (80);
 g_package              VARCHAR2 (80) := 'BEN_CWB_MASS_NOTIFN_PKG';
 g_selected_persons     g_person_sel_table_type := g_person_sel_table_type();
 g_sent_total           NUMBER;
 g_unsent_total         NUMBER;

 CURSOR c_found(
    v_user_name          IN VARCHAR2
   ,v_plan_id            IN NUMBER
   ,v_lf_evt_orcd_date   IN DATE
   ,v_messg_txt_body     IN VARCHAR2
   )
   IS
     SELECT txn.transaction_id
     FROM   ben_transaction txn
     WHERE  txn.transaction_type = 'CWBMASSNOTIF'
     AND    txn.attribute1 = v_user_name
     AND    txn.attribute2 = v_plan_id||','||to_char(v_lf_evt_orcd_date,'yyyy/mm/dd')
     AND    txn.attribute3 = v_messg_txt_body;

 CURSOR c_person_all
  IS
    SELECT ppf.full_name
          ,bg.name
          ,ppf.employee_number
          ,ppf.person_id
          ,null
	  ,ppf.business_group_id
    FROM   per_all_people_f ppf
         , per_person_types ppt
         , per_assignments_f paf
         , per_business_groups_perf bg
    WHERE  ppf.person_id=paf.person_id
    AND    sysdate BETWEEN ppf.effective_start_date AND ppf.effective_end_date
    AND    paf.primary_flag = 'Y'
    AND    paf.business_group_id = ppf.business_group_id
    AND    paf.person_id = ppf.person_id
    AND    sysdate BETWEEN paf.effective_start_date AND paf.effective_end_date
    AND    ppt.person_type_id=ppf.person_type_id
    AND    ppt.system_person_type = 'EMP'
    AND    bg.business_group_id = ppf.business_group_id;
/*
   SELECT ppf.full_name
         ,bg.name
         ,ppf.employee_number
         ,ppf.person_id
         ,null
	 ,ppf.business_group_id
         ,cursor ( select user_name from fnd_user usr
                   where usr.employee_id = ppf.person_id )
   FROM per_all_people_f ppf
       ,per_business_groups_perf bg
   WHERE sysdate BETWEEN NVL(EFFECTIVE_START_DATE,sysdate)
                 AND NVL(EFFECTIVE_END_DATE,sysdate)
   AND ppf.business_group_id = bg.business_group_id;
*/
CURSOR c_user_selection (
    v_person_id                 IN NUMBER
    )
  IS
   SELECT user_name
   FROM fnd_user usr
   WHERE usr.employee_id = v_person_id;

CURSOR c_person_selection (
    v_group_pl_id               IN   NUMBER
  , v_lf_evt_orcd_date          IN   DATE
  , v_target_pop                IN   VARCHAR2
  , v_req_acc_lvl               IN   VARCHAR2
  )
  IS
   SELECT DISTINCT max(DECODE (ben_cwb_utils.get_profile ('BEN_DISPLAY_EMPLOYEE_NAME'),
                  'BN', per.brief_name,
                  'CN', per.custom_name,
                  per.full_name)) full_name
                  ,max(bg.name)
                  ,max(per.employee_number)
                  ,max(pil.person_id)
                  ,max(pil.per_in_ler_id)
   FROM ben_cwb_person_info per
       ,ben_per_in_ler pil
       ,ben_cwb_group_hrchy hrchy
       ,hr_all_organization_units bg
       WHERE per.group_pl_id = v_group_pl_id
         AND per.lf_evt_ocrd_dt = v_lf_evt_orcd_date
         AND pil.per_in_ler_id = per.group_per_in_ler_id
         AND bg.organization_id (+) = per.business_group_id
         AND hrchy.emp_per_in_ler_id = pil.per_in_ler_id
         AND (((v_target_pop IS NOT NULL)
              AND (
                   ((v_target_pop = 'ELI')
                   AND EXISTS( select person_rates.elig_flag from ben_cwb_person_rates person_rates
                               where person_rates.group_per_in_ler_id = pil.per_in_ler_id
                               and person_rates.group_pl_id = pil.group_pl_id
                               AND person_rates.elig_flag = 'Y')
                   AND (hrchy.lvl_num = (SELECT MAX (lvl_num)
                                         FROM ben_cwb_group_hrchy hr
                                         WHERE hr.emp_per_in_ler_id = hrchy.emp_per_in_ler_id)))
                   OR
                    ((v_target_pop = 'EPO')
                   AND EXISTS( select * from ben_cwb_person_rates person_rates
                               where person_rates.group_per_in_ler_id = pil.per_in_ler_id
                               and person_rates.group_pl_id = pil.group_pl_id
                               and ((person_rates.pay_proposal_id is not null)
                                    or (person_rates.element_entry_value_id is not null)))
                   AND (hrchy.lvl_num = (SELECT MAX (lvl_num)
                                         FROM ben_cwb_group_hrchy hr
                                         WHERE hr.emp_per_in_ler_id = hrchy.emp_per_in_ler_id)))
                   OR
                    ((v_target_pop = 'MAN')
                   AND (hrchy.lvl_num = 0))
                   OR
                    ((v_target_pop = 'MFU')
                   AND (hrchy.lvl_num = 0)
                   AND (pil.per_in_ler_stat_cd = 'PROCD'))
                   OR
                    ((v_target_pop = 'MNS')
                   AND (hrchy.lvl_num = 0)
                   AND EXISTS(select groups.submit_cd
                              from ben_cwb_person_groups groups
                              where groups.group_per_in_ler_id = pil.per_in_ler_id
                              and groups.group_pl_id = pil.group_pl_id
                              and groups.group_oipl_id = -1
                              and groups.submit_cd = 'NS'))
                   OR
                    ((v_target_pop = 'MOB')
                   AND (hrchy.lvl_num = 0)
                   AND EXISTS(select groups.submit_cd
                              from ben_cwb_person_groups groups
                              where groups.group_per_in_ler_id = pil.per_in_ler_id
                              and groups.group_pl_id = pil.group_pl_id
                              and groups.group_oipl_id = -1
                              and groups.submit_cd = 'SU'
                              and groups.approval_cd = 'AP'))
                   OR
                    ((v_target_pop = 'MWA')
                   AND (hrchy.lvl_num = 0)
                   AND EXISTS(select groups.approval_cd
                              from ben_cwb_person_groups groups
                              where groups.group_per_in_ler_id = pil.per_in_ler_id
                              and groups.group_pl_id = pil.group_pl_id
                              and groups.group_oipl_id = -1
                              and nvl(groups.approval_cd,'NULL') <> 'AP'))
                   OR
                    ((v_target_pop = 'MWB')
                   AND (hrchy.lvl_num = 0)
                   AND EXISTS(select groups.submit_cd
                              from ben_cwb_person_groups groups
                              where groups.group_per_in_ler_id = pil.per_in_ler_id
                              and groups.group_pl_id = pil.group_pl_id
                              and groups.group_oipl_id = -1
                              and (groups.dist_bdgt_val is not null
                                   or groups.ws_bdgt_val is not null)))
                   OR
                    ((v_target_pop = 'MFX')
                   AND (hrchy.lvl_num = 0)
                   AND EXISTS (select ler.per_in_ler_stat_cd
                               from ben_per_in_ler ler
                                   ,ben_cwb_group_hrchy hier
                               where hier.mgr_per_in_ler_id = pil.per_in_ler_id
                               and ler.per_in_ler_id = hier.emp_per_in_ler_id
                               and ler.per_in_ler_stat_cd = 'PROCD'))
                   OR
                    ((v_target_pop = 'MEL')
                   AND (hrchy.lvl_num = 0)
                   AND EXISTS (select rts.elig_flag
                               from ben_cwb_person_rates rts
                                    ,ben_cwb_group_hrchy hier
                               where hier.mgr_per_in_ler_id = hrchy.mgr_per_in_ler_id
                               and rts.group_per_in_ler_id = hier.emp_per_in_ler_id
                               and rts.elig_flag = 'Y'
			       and hier.lvl_num <> 0))
                   OR
                    ((v_target_pop = 'MWT')
                   AND (hrchy.lvl_num = 0)
                   AND NOT EXISTS (select tsk.task_id
                                   from ben_cwb_person_tasks tsk
                                   where tsk.group_per_in_ler_id = hrchy.mgr_per_in_ler_id
                                   and tsk.status_cd in ('IP','NA','CO'))
			)
                   )
                   )
         OR
         ((v_target_pop IS NULL)
              AND (hrchy.lvl_num = (SELECT MAX (lvl_num)
                           FROM ben_cwb_group_hrchy hr
                           WHERE hr.emp_per_in_ler_id = hrchy.emp_per_in_ler_id)))
         )
         AND (((v_req_acc_lvl IS NOT NULL)
                  AND
                  (
                   ((v_req_acc_lvl = 'AL')
                     AND EXISTS (select gr.access_cd
                                 from ben_cwb_person_groups gr
                                 	, ben_cwb_group_hrchy hr
                                 where hr.emp_per_in_ler_id = pil.per_in_ler_id
                                 and hr.lvl_num = 0
								 and gr.group_per_in_ler_id = hr.emp_per_in_ler_id
                                 and gr.group_pl_id = pil.group_pl_id
                                 and gr.group_oipl_id = -1
                                 and gr.access_cd IN ('UP','RO','NA')))
                   OR
                   ((v_req_acc_lvl = 'FR')
                     AND EXISTS (select gr.access_cd
                                 from ben_cwb_person_groups gr
                                 	, ben_cwb_group_hrchy hr
                                 where hr.emp_per_in_ler_id = pil.per_in_ler_id
                                 and hr.lvl_num = 0
                                 and gr.group_per_in_ler_id = pil.per_in_ler_id
                                 and gr.group_pl_id = pil.group_pl_id
                                 and gr.group_oipl_id = -1
                                 and gr.access_cd IN ('UP','RO')))
                   OR
                   ((v_req_acc_lvl = 'FU')
                     AND EXISTS (select gr.access_cd
                                 from ben_cwb_person_groups gr
                                 	, ben_cwb_group_hrchy hr
                                 where hr.emp_per_in_ler_id = pil.per_in_ler_id
                                 and hr.lvl_num = 0
                                 and gr.group_per_in_ler_id = hrchy.emp_per_in_ler_id
                                 and gr.group_pl_id = pil.group_pl_id
                                 and gr.group_oipl_id = -1
                                 and gr.access_cd IN ('UP')))
                   OR
                   ((v_req_acc_lvl = 'NA')
                     AND EXISTS (select gr.access_cd
                                 from ben_cwb_person_groups gr
                                 	, ben_cwb_group_hrchy hr
                                 where hr.emp_per_in_ler_id = pil.per_in_ler_id
                                 and hr.lvl_num = 0
                                 and gr.group_per_in_ler_id = hrchy.emp_per_in_ler_id
                                 and gr.group_pl_id = pil.group_pl_id
                                 and gr.group_oipl_id = -1
                                 and gr.access_cd IN ('NA')))
                   OR
                   ((v_req_acc_lvl = 'RO')
                     AND EXISTS (select gr.access_cd
                                 from ben_cwb_person_groups gr
                                 	, ben_cwb_group_hrchy hr
                                 where hr.emp_per_in_ler_id = pil.per_in_ler_id
                                 and hr.lvl_num = 0
                                 and gr.group_per_in_ler_id = hrchy.emp_per_in_ler_id
                                 and gr.group_pl_id = pil.group_pl_id
                                 and gr.group_oipl_id = -1
                                 and gr.access_cd IN ('RO')))
                   )
                   )
             OR (v_req_acc_lvl IS NULL))
	 group by per.person_id;

CURSOR c_check_termination (
    v_person_id                 IN NUMBER
  )
  IS
   SELECT ppt.system_person_type
   FROM per_person_types ppt
       ,per_all_people_f ppf
   WHERE ppf.person_id = v_person_id
   AND sysdate BETWEEN ppf.effective_start_date AND ppf.effective_end_date
   AND ppt.person_type_id = ppf.person_type_id;

 CURSOR c_check_assignment (
    v_group_per_in_ler_id       IN NUMBER
    )
    IS
     SELECT info.assignment_id
     FROM ben_cwb_person_info info
         ,per_assignments_f paf
     WHERE info.group_per_in_ler_id = v_group_per_in_ler_id
     AND paf.assignment_id = info.assignment_id
     AND sysdate BETWEEN paf.effective_start_date AND paf.effective_end_date;

-- --------------------------------------------------------------------------
-- |-----------------------------< WRITE >----------------------------------|
-- --------------------------------------------------------------------------
--
 PROCEDURE WRITE (p_string IN VARCHAR2)
  IS
 BEGIN
    ben_batch_utils.WRITE (p_string);
 END;

-- --------------------------------------------------------------------------
-- |---------------------< check_selection_rule >----------------------------|
-- --------------------------------------------------------------------------
--
-- Description
--	This procedure checks for person selection rule.
--

  FUNCTION check_selection_rule(
    p_person_selection_rule_id IN NUMBER
   ,p_person_id                IN NUMBER
   ,p_business_group_id        IN NUMBER
   ,p_effective_date           IN DATE
   ,p_input1                   in  varchar2 default null    -- Bug 5331889
   ,p_input1_value             in  varchar2 default null)
    RETURN BOOLEAN IS
    --
    l_outputs       ff_exec.outputs_t;
    l_assignment_id NUMBER;
    l_package       VARCHAR2(80)      := g_package || '.check_selection_rule';
    value_exception  exception ;
  --
  BEGIN
    --
    IF p_person_selection_rule_id IS NULL THEN
      --
      RETURN TRUE;
    --
    ELSE
      --
      l_assignment_id  :=
        benutils.get_assignment_id(p_person_id         => p_person_id
                                  ,p_business_group_id => p_business_group_id
                                  ,p_effective_date    => p_effective_date);
      --
      if l_assignment_id is null
      then
          raise ben_batch_utils.g_record_error;
      end if ;
      --
      l_outputs        :=
        benutils.formula(p_formula_id => p_person_selection_rule_id
         ,p_effective_date            => p_effective_date
         ,p_business_group_id         => p_business_group_id
         ,p_assignment_id             => l_assignment_id
         ,p_param1                    => 'BEN_IV_PERSON_ID'          -- Bug 5331889
         ,p_param1_value              => to_char(p_person_id)
         ,p_param2                    => p_input1
         ,p_param2_value              => p_input1_value);
      --
      IF l_outputs(l_outputs.FIRST).VALUE = 'Y' THEN
        --
        RETURN TRUE;
      --
      ELSIF l_outputs(l_outputs.FIRST).VALUE = 'N' THEN
        --
        RETURN FALSE;
      --
      ELSIF upper(l_outputs(l_outputs.FIRST).VALUE) not in ('Y', 'N')  THEN
        --
        RAISE value_exception;
      --
      END IF;
    --
    END IF;
  --
  EXCEPTION
    --
    When ben_batch_utils.g_record_error then
         hr_utility.set_location(l_package ,10);
         fnd_message.set_name('BEN','BEN_91698_NO_ASSIGNMENT_FND');
         fnd_message.set_token('ID' ,to_char(p_person_id) );
         fnd_message.set_token('PROC',l_package ) ;
    	 Ben_batch_utils.write(p_text => '<< Person id : '||to_char(p_person_id)||' failed.'||
	          		         ' Reason : '|| fnd_message.get ||' >>' );
	 RETURN FALSE;
    When value_exception then
         hr_utility.set_location(l_package ,20);
         fnd_message.set_name('BEN','BEN_91329_FORMULA_RETURN');
         fnd_message.set_token('RL','person_selection_rule_id :'||p_person_selection_rule_id);
         fnd_message.set_token('PROC',l_package  ) ;
    	 Ben_batch_utils.write(p_text => '<< Person id : '||to_char(p_person_id)||' failed.'||
	          		         ' Reason : '|| fnd_message.get ||' >>' );
	 RETURN FALSE;
    WHEN OTHERS THEN
         hr_utility.set_location(l_package ,30);
         Ben_batch_utils.write(p_text => '<< Person id : '||to_char(p_person_id)||' failed.'||
	          		         ' Reason : '|| SQLERRM ||' >>' );
         RETURN FALSE;
  --
  END check_selection_rule;
-- --------------------------------------------------------------------------
-- |---------------------< inc_home_link >--------------------------------|
-- --------------------------------------------------------------------------
--
-- Description
--	This procedure checks if link for Compensation Workbench has to be
-- included in the Notification. This preference is set in the concurrent
-- process.
--
procedure inc_home_link
       (itemtype                         in varchar2
      , itemkey                          in varchar2
      , actid                            in number
      , funcmode                         in varchar2
      , result                   out nocopy varchar2)
    is
    	l_include_link varchar2(240);
    	l_package varchar2(80) := g_package||'.inc_home_link';
    	l_error varchar2(5000);
    begin
    	hr_utility.set_location('Entering '||l_package ,30);
    	l_include_link := wf_engine.GetItemAttrText(itemtype => itemtype,
	    					    itemkey   => itemkey,
	    					    aname    => 'MASS_NTF_LINK');
	 if ( l_include_link  = 'Y') then
	 		result:= 'COMPLETE:' ||'Y';
	 else
	 		result:= 'COMPLETE:' ||'N';
	 end if;
	 hr_utility.set_location('Leaving '||l_package ,30);
    EXCEPTION
		when others then
		l_error:=sqlerrm;
		hr_utility.set_location ('exception is'||l_error , 300);
		Wf_Core.Context('BEN_CWB_MASS_NOTIFN_PKG' ,  'inc_home_link',l_error);
		raise;

end inc_home_link;
-- --------------------------------------------------------------------------
-- |---------------------< mass_ntf_cleanup >--------------------------------|
-- --------------------------------------------------------------------------
--
-- Description
--	This procedure has cleanup code for the workflow engine.
--
procedure mass_ntf_cleanup
       (itemtype                         in varchar2
      , itemkey                          in varchar2
      , actid                            in number
      , funcmode                         in varchar2
      , result                   out nocopy varchar2)
    is
        --users WF_DIRECTORY.UserTable;
    	l_package varchar2(80) := g_package||'.mass_ntf_cleanup';
    	l_error varchar2(5000);

    begin
    	hr_utility.set_location('Entering '||l_package ,30);
	/* removed dynamic role based messaging
        WF_DIRECTORY.GetRoleUsers('CWB_MASS_NTF_ROLE_TEMP1',users);
	if users.first is not null  then
         for i in users.first..users.last
         loop
	 null;
	 WF_DIRECTORY.RemoveUsersFromAdHocRole('CWB_MASS_NTF_ROLE_TEMP1',null);
	 end loop;
	end if;
	*/
	result:= 'COMPLETE:';
        hr_utility.set_location('Leaving '||l_package ,40);
    EXCEPTION
		when others then
		l_error:=sqlerrm;
		hr_utility.set_location ('exception is'||l_error , 300);
		Wf_Core.Context('BEN_CWB_MASS_NOTIFN_PKG' ,  'mass_ntf_cleanup',l_error);
		raise;

end mass_ntf_cleanup;

-- --------------------------------------------------------------------------
-- |---------------------< get_item_attribute >--------------------------------|
-- --------------------------------------------------------------------------
--
-- Description
--	This procedure returns the attribute text
--
function get_item_attribute
       (itemtype                         in  varchar2
      , itemkey                          in  varchar2
      , aname                            in  varchar2)
    return varchar2
    is
    	l_package varchar2(80) := g_package||'.get_item_attribute';
    	l_error varchar2(5000);
        l_value varchar2(1000);
    begin
    	hr_utility.set_location('Entering '||l_package ,30);
	l_value := WF_ENGINE.GetItemAttrText(itemtype => itemtype
	                                  ,itemkey  => itemkey
					  ,aname    => aname);
        hr_utility.set_location('Leaving '||l_package ,40);
	return l_value;
    EXCEPTION
		when others then
		l_error:=sqlerrm;
		hr_utility.set_location ('exception is'||l_error , 300);
		raise;

end get_item_attribute;


-- --------------------------------------------------------------------------
-- |---------------------< create_workflow >--------------------------------|
-- --------------------------------------------------------------------------
--
--
 PROCEDURE create_workflow(
                  v_users                    IN g_users_t
		 ,v_people                   IN person_info
	         ,p_pl_id                    in number
		 ,p_lf_evt_ocrd_dt           in date
		 ,p_messg_txt_title          in varchar2 default null
		 ,p_messg_txt_body           in varchar2 default null
		 ,p_include_cwb_link         in varchar2 default 'N'
		 ,p_resend_if_prev_sent      in varchar2 default 'N'
		 ,p_mail_to_user             in varchar2 default null
		 ,p_withhold_notifn          in varchar2 default 'N'
                          )
  IS
    l_plan_name varchar2(240);
    l_yr_perd_start_dt date;
    l_yr_perd_end_dt date;
    l_wthn_yr_start_dt date;
    l_wthn_yr_end_dt date;
    l_notify boolean;
    l_transaction_id number;
    l_wf_key number;
    l_transaction_key number;
    l_trans_rec ben_transaction%rowtype;
    l_user_name varchar2(100);
    l_reject_reason varchar2(30);
    l_system_person_type per_person_types.system_person_type%type;
    l_assignment_id ben_cwb_person_info.assignment_id%type;
 BEGIN

 if(v_people.per_in_ler_id is not null) then

  OPEN c_check_termination(v_people.person_id);
  FETCH c_check_termination
  INTO l_system_person_type;
  CLOSE c_check_termination;

  OPEN c_check_assignment(v_people.per_in_ler_id);
  FETCH c_check_assignment
  INTO l_assignment_id;
  CLOSE c_check_assignment;

  if(l_assignment_id is null) then
   l_reject_reason := 'ASSIGNMENT ENDED';
  end if;

  if(l_system_person_type = 'EX_EMP') then
   l_reject_reason := 'EMPLOYEE TERMINATED';
  end if;

 else
  l_system_person_type := 'DEFAULT';
  l_assignment_id := -1;
 end if;

if((l_system_person_type <> 'EX_EMP')and(l_assignment_id is not null)) then

 SELECT user_name
 INTO l_user_name
 FROM fnd_user
 WHERE user_id = fnd_global.user_id;
 SELECT name
       ,yr_perd_start_dt
       ,yr_perd_end_dt
       ,wthn_yr_start_dt
       ,wthn_yr_end_dt
 INTO l_plan_name
     ,l_yr_perd_start_dt
     ,l_yr_perd_end_dt
     ,l_wthn_yr_start_dt
     ,l_wthn_yr_end_dt
 FROM ben_cwb_pl_dsgn
 WHERE pl_id = p_pl_id
 AND oipl_id = -1
 AND lf_evt_ocrd_dt = p_lf_evt_ocrd_dt;

  if(v_users.COUNT=0) then
     WRITE('NOT SENT' ||' - '|| 'NO USER ATTACHED' ||' - '|| v_people.full_name
      ||' - '|| v_people.name ||' - '|| v_people.employee_number
      ||' - '|| v_people.person_id||' - '|| v_people.per_in_ler_id);
      g_unsent_total := g_unsent_total + 1;
  end if;

  FOR element IN 1..v_users.COUNT
  LOOP
   if(v_users.exists(element)) then
     --testing phase omission
    l_notify := TRUE;
    if(p_resend_if_prev_sent='N') then
      OPEN c_found(v_users(element)
                  ,p_pl_id
		  ,p_lf_evt_ocrd_dt
	          ,p_messg_txt_body
                            );
      FETCH c_found
      INTO l_transaction_id;
      if(l_transaction_id is not null) then
       l_notify := FALSE;
      end if;
      CLOSE c_found;
    end if;
    if(l_notify = TRUE) then
     if(p_withhold_notifn = 'N') then

     select BEN_CWB_WF_NTF_S.NEXTVAL into l_wf_key from dual;
     wf_engine.createProcess (ItemType => 'BENCWBFY',
                              ItemKey  => l_wf_key,
                              process  => 'MASS_NOTIFICATION_PROC');
     -----------------------------------------------------------------

     wf_engine.setitemattrtext (itemtype => 'BENCWBFY',
                                itemkey  => l_wf_key,
                                aname    => 'MASS_NTF_KEY',
                                avalue   => l_wf_key);

     wf_engine.setitemattrtext (itemtype => 'BENCWBFY',
                                itemkey  => l_wf_key,
                                aname    => 'MASS_NTF_TITLE',
                                avalue   => p_messg_txt_title);
     wf_engine.setitemattrtext (itemtype => 'BENCWBFY',
                                itemkey  => l_wf_key,
                                aname    => 'MASS_NTF_MSG',
                                avalue   => p_messg_txt_body);
     wf_engine.setitemattrtext (itemtype => 'BENCWBFY',
                                itemkey  => l_wf_key,
                                aname    => 'MASS_NTF_SUB',
                                avalue   => '');
     wf_engine.setitemattrtext (itemtype => 'BENCWBFY',
                                itemkey  => l_wf_key,
                                aname    => 'MASS_NTF_LINK',
                                avalue   => p_include_cwb_link);
     ----------------------------------------------------------------
     wf_engine.setitemattrtext (itemtype => 'BENCWBFY',
                                itemkey  => l_wf_key,
                                aname    => 'FROM_ROLE',
                                avalue   => l_user_name);
     wf_engine.setitemattrtext (itemtype => 'BENCWBFY',
                                itemkey  => l_wf_key,
                                aname    => 'MASS_NTF_HDR_PLAN',
                                avalue   => l_plan_name);
     wf_engine.setitemattrtext (itemtype => 'BENCWBFY',
                                itemkey  => l_wf_key,
                                aname    => 'MASS_NTF_HDR_PERIOD',
                                avalue   => l_yr_perd_start_dt
			            ||' - '||l_yr_perd_end_dt);
     ------------------------------------------------------------
     wf_engine.setitemattrtext (itemtype => 'BENCWBFY',
                                itemkey  => l_wf_key,
                                aname    => 'MASS_NTF_RCVR',
                                avalue   => v_users(element));
     wf_engine.StartProcess (ItemType => 'BENCWBFY',
                             ItemKey  => l_wf_key);
     ------------------------------------------------------------
     /* commenting out - sending indiv threads
    WF_DIRECTORY.AddUsersToAdHocRole(adhocRole,v_users(element));
    */
     --insert into nt values (v_users(element));

     select BEN_TRANSACTION_S.NEXTVAL into l_transaction_key from dual;
     l_trans_rec.attribute1 := v_users(element);
     l_trans_rec.attribute2 := p_pl_id ||','|| to_char(p_lf_evt_ocrd_dt,'yyyy/mm/dd');
     l_trans_rec.attribute3 := p_messg_txt_body;
     l_trans_rec.attribute4 := sysdate;
     insert into ben_transaction
        (transaction_id ,transaction_type
        ,attribute1 ,attribute2
        ,attribute3 ,attribute4
        ,attribute5 ,attribute6
        ,attribute7 ,attribute8
        ,attribute9 ,attribute10
        ,attribute11 ,attribute12
        ,attribute13 ,attribute14
        ,attribute15 ,attribute16
        ,attribute17 ,attribute18
        ,attribute19 ,attribute20
        ,attribute21 ,attribute22
        ,attribute23 ,attribute24
        ,attribute25 ,attribute26
        ,attribute27 ,attribute28
        ,attribute29 ,attribute30
        ,attribute31 ,attribute32
        ,attribute33 ,attribute34
        ,attribute35 ,attribute36
        ,attribute37 ,attribute38
        ,attribute39 ,attribute40)
    values
       (l_transaction_key ,'CWBMASSNOTIF'
       ,l_trans_rec.attribute1 ,l_trans_rec.attribute2
       ,l_trans_rec.attribute3 ,l_trans_rec.attribute4
       ,l_trans_rec.attribute5 ,l_trans_rec.attribute6
       ,l_trans_rec.attribute7 ,l_trans_rec.attribute8
       ,l_trans_rec.attribute9 ,l_trans_rec.attribute10
       ,l_trans_rec.attribute11 ,l_trans_rec.attribute12
       ,l_trans_rec.attribute13 ,l_trans_rec.attribute14
       ,l_trans_rec.attribute15 ,l_trans_rec.attribute16
       ,l_trans_rec.attribute17 ,l_trans_rec.attribute18
       ,l_trans_rec.attribute19 ,l_trans_rec.attribute20
       ,l_trans_rec.attribute21 ,l_trans_rec.attribute22
       ,l_trans_rec.attribute23 ,l_trans_rec.attribute24
       ,l_trans_rec.attribute25 ,l_trans_rec.attribute26
       ,l_trans_rec.attribute27 ,l_trans_rec.attribute28
       ,l_trans_rec.attribute29 ,l_trans_rec.attribute30
       ,l_trans_rec.attribute31 ,l_trans_rec.attribute32
       ,l_trans_rec.attribute33 ,l_trans_rec.attribute34
       ,l_trans_rec.attribute35 ,l_trans_rec.attribute36
       ,l_trans_rec.attribute37 ,l_trans_rec.attribute38
       ,l_trans_rec.attribute39 ,l_trans_rec.attribute40);
    end if;

/*   WRITE('Notification issued to : '||v_users(element)); */
     WRITE('SENT' ||' - '|| v_users(element) ||' - '|| v_people.full_name
      ||' - '|| v_people.name ||' - '|| v_people.employee_number
      ||' - '|| v_people.person_id||' - '|| v_people.per_in_ler_id);
      g_sent_total := g_sent_total + 1;
    else if(l_notify <> TRUE) then
     WRITE('NOT RESENT' ||' - '|| v_users(element) ||' - '|| v_people.full_name
      ||' - '|| v_people.name ||' - '|| v_people.employee_number
      ||' - '|| v_people.person_id||' - '|| v_people.per_in_ler_id);
     g_unsent_total := g_unsent_total + 1;
    end if;
   end if;
   end if;

  END LOOP;
  else
  WRITE('NOT SENT' ||' - '|| l_reject_reason ||' - '|| v_people.full_name
         ||' - '|| v_people.name ||' - '|| v_people.employee_number
         ||' - '|| v_people.person_id||' - '|| v_people.per_in_ler_id);
  g_unsent_total := g_unsent_total + 1;
  end if;
  END create_workflow;
-- --------------------------------------------------------------------------
-- |------------------------------< notify >--------------------------------|
-- --------------------------------------------------------------------------
-- Description
--	This procedure contains calls for sending mass notifications via
-- Oracle Workflow. This will be called by a concurent process.
--
procedure notify( errbuf                     out  nocopy  varchar2
                 ,retcode                    out  nocopy  number
                 ,p_pl_id                    in number
		 ,p_lf_evt_ocrd_dt           in varchar2
		 ,p_messg_txt_title          in varchar2 default null
		 ,p_messg_txt_body           in varchar2 default null
		 ,p_target_pop               in varchar2 default null
		 ,p_req_acc_lvl              in varchar2 default null
		 ,p_person_selection_rule_id in number   default null
		 ,p_include_cwb_link         in varchar2 default 'N'
		 ,p_resend_if_prev_sent      in varchar2 default 'N'
		 ,p_mail_to_user             in varchar2 default null
		 ,p_withhold_notifn          in varchar2 default 'N'
                 )
is

    ps_rec person_info;
    l_pid pid;
    users the_users;
    v_users g_users_t := g_users_t();
    --adhocRole varchar2(50):='CWB_MASS_NTF_ROLE_TEMP1';
    --adhocDRole varchar2(50):='Placeholder Role';
    display_name varchar2(240);
    email_id varchar2(240);
    notif_pref varchar2(240);
    lang varchar2(240);
    terr varchar2(240);
    --adHocUsers WF_DIRECTORY.UserTable;
    l_error varchar2(5000);
    l_business_group_id number;
    l_emp_processed number;
    l_emp_with_user number;
    l_emp_with_no_user number;
    l_effective_date date;
    l_commit number;
    l_can_date date;
    l_var_date varchar2(50);
    l_lf_evt_ocrd_dt date;
    l_benefit_action_id number;
    l_object_version_number number;
BEGIN

begin
 l_can_date := fnd_date.canonical_to_date(p_lf_evt_ocrd_dt);
 l_var_date := fnd_date.date_to_canonical(l_can_date);
 if(l_var_date = p_lf_evt_ocrd_dt) then
    l_lf_evt_ocrd_dt := l_can_date;
 else
    l_lf_evt_ocrd_dt := fnd_date.canonical_to_date(p_lf_evt_ocrd_dt);
 end if;
exception
 when others then
  l_lf_evt_ocrd_dt := fnd_date.canonical_to_date(p_lf_evt_ocrd_dt);
end;

 g_sent_total := 0;
 g_unsent_total := 0;
 if(p_withhold_notifn = 'Y') then
  WRITE('==========================++ !NOTE! ++====================================');
  WRITE('NOTIFICATIONS ARE WITHHELD AS THIS IS JUST A TEST RUN.');
  WRITE('ONLY LOG FILE IS GENERATED!');
  WRITE ('===========================================================================');
 end if;
 WRITE('==============================START========================================');
 g_actn := 'Compensation Workbench Mass Notification initialised...';
 WRITE ('Time '||to_char(sysdate,'yyyy/mm/dd:hh:mi:ssam'));
 WRITE (g_actn);
 g_proc := g_package || '.notify';
 WRITE ('=============================NOTIFY========================================');
 WRITE ('|Parameter               Value            ');
 --WRITE ('||p_effective_dates -    ' || p_effective_date);
 --WRITE ('||p_validate -           ' || p_validate);
 WRITE ('|p_pl_id -                ' || p_pl_id);
 WRITE ('|p_lf_evt_ocrd_dt -       ' || l_lf_evt_ocrd_dt);
 WRITE ('|p_messg_txt_title -      ' || p_messg_txt_title);
 WRITE ('|p_messg_txt_body -       ' || p_messg_txt_body);
 WRITE ('|p_target_pop -           ' || p_target_pop);
 WRITE ('|p_req_acc_lvl -          ' || p_req_acc_lvl);
 WRITE ('p_person_selection_rule_id - ' || p_person_selection_rule_id);
 WRITE ('|p_include_cwb_link -     ' || p_include_cwb_link);
 WRITE ('|p_resend_if_prev_sent -  ' || p_resend_if_prev_sent);
 WRITE ('|p_mail_to_user -         ' || p_mail_to_user);
 WRITE ('|p_withhold_notifn -      ' || p_withhold_notifn);
 --WRITE ('||p_is_multi_thread -    ' || p_is_multi_thread);
 WRITE ('===========================================================================');

 l_effective_date := trunc(fnd_date.canonical_to_date(sysdate));
 --
 -- Put row in fnd_sessions
 --
 dt_fndate.change_ses_date
        (p_ses_date => l_effective_date,
         p_commit   => l_commit);
 WRITE ('Changing Session Date: '||l_effective_date);
 WRITE ('Commit on date       : '||l_commit);
 WRITE ('===========================================================================');

    g_actn := 'Calling ben_batch_utils.ini...';
    WRITE (g_actn);
    write ('ben_batch_utils.ini with PROC_INFO');
    ben_batch_utils.ini (p_actn_cd => 'PROC_INFO');/*
    g_actn := 'Calling benutils.get_parameter...';
    WRITE (g_actn);
    write_h ('benutils.get_parameter with ' || p_bg_id || ' ' || 'BENCWBMN' || ' '
             || g_max_errors_allowed
            );
    benutils.get_parameter (p_business_group_id     => p_bg_id
                          , p_batch_exe_cd          => 'BENCWBPP'
                          , p_threads               => l_threads
                          , p_chunk_size            => l_chunk_size
                          , p_max_errors            => g_max_errors_allowed
                           );
    write_h ('Values of l_threads is ' || l_threads || ' and l_chunk_size is ' || l_chunk_size);*/
    benutils.g_thread_id := 99;                            -- need to investigate why this is needed
    g_actn := 'Creating benefit actions...';
    WRITE (g_actn);
    WRITE ('Time'||to_char(sysdate,'yyyy/mm/dd:hh:mi:ssam'));
    write ('=====================Benefit Actions=======================');
    write ('||Parameter                  value                         ');
    write ('||p_request_id-             ' || fnd_global.conc_request_id);
    write ('||p_program_application_id- ' || fnd_global.prog_appl_id);
    write ('||p_program_id-             ' || fnd_global.conc_program_id);
    write ('==========================================================');
    ben_benefit_actions_api.create_perf_benefit_actions
                                               (p_benefit_action_id          => l_benefit_action_id
                                              , p_process_date               => l_effective_date
                                              , p_mode_cd                    => 'W'
                                              , p_derivable_factors_flag     => 'NONE'
                                              , p_validate_flag              => 'N'
                                              , p_debug_messages_flag        => 'N'
                                              , p_business_group_id          => benutils.get_profile('PER_BUSINESS_GROUP_ID')
                                              , p_no_programs_flag           => 'N'
                                              , p_no_plans_flag              => 'N'
                                              , p_audit_log_flag             => 'N'
                                              , p_pl_id                      => p_pl_id
                                              , p_pgm_id                     => -9999
                                              , p_lf_evt_ocrd_dt             => l_lf_evt_ocrd_dt
                                              --, p_person_id                  => p_person_id
                                              --, p_grant_price_val            => p_grant_price_val
                                              , p_object_version_number      => l_object_version_number
                                              , p_effective_date             => l_effective_date
                                              , p_request_id                 => fnd_global.conc_request_id
                                              , p_program_application_id     => fnd_global.prog_appl_id
                                              , p_program_id                 => fnd_global.conc_program_id
                                              , p_program_update_date        => SYSDATE/*
                                              , p_bft_attribute1             => l_process_compents
                                              , p_bft_attribute3             => p_employees_in_bg
                                              , p_bft_attribute4             => p_manager_id*/
					      , p_bft_attribute30            => 'N'
                                               );
    write ('Benefit Action Id is ' || l_benefit_action_id);
    benutils.g_benefit_action_id := l_benefit_action_id;


 l_emp_processed := 0;
 l_emp_with_user := 0;
 l_emp_with_no_user := 0;

	/*WF_DIRECTORY.GetRoleUsers('CWB_MASS_NTF_ROLE_TEMP1',adHocUsers);
	if adHocUsers.first is not null  then
         for i in adHocUsers.first..adHocUsers.last
         loop
          WF_DIRECTORY.RemoveUsersFromAdHocRole('CWB_MASS_NTF_ROLE_TEMP1',adHocUsers(i));
         end loop;
	end if;*/
	/*
     wf_directory.GetRoleInfo(adhocRole
                             ,display_name
			     ,email_id
			     ,notif_pref
			     ,lang
			     ,terr
                             );
     if(display_name is null) then
      wf_directory.CreateAdHocRole(adhocRole,adhocDRole);
     end if;
     */

if(p_mail_to_user is not null) then
       WRITE('Mailing Notification');
       WRITE('STATUS - USERNAME -  -  -  -  -');
       v_users.extend;
       v_users(v_users.last) := p_mail_to_user;
       /*WRITE(v_users.COUNT||' users attached');*/
       create_workflow ( v_users     => v_users
                 ,v_people                   => ps_rec
	         ,p_pl_id                    => p_pl_id
		 ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
		 ,p_messg_txt_title          => p_messg_txt_title
		 ,p_messg_txt_body           => p_messg_txt_body
		 ,p_include_cwb_link         => p_include_cwb_link
		 ,p_resend_if_prev_sent      => p_resend_if_prev_sent
		 ,p_mail_to_user             => p_mail_to_user
		 ,p_withhold_notifn          => p_withhold_notifn);
      l_emp_processed := l_emp_processed + 1;
      l_emp_with_user := l_emp_with_user + 1;
elsif (p_person_selection_rule_id is not null) then
 WRITE('STATUS - USERNAME - NAME - BUSINESS GROUP - EMP.NO. - PERSON ID - PER IN LER ID');
 OPEN c_person_all;
    LOOP
      FETCH c_person_all
       INTO ps_rec.full_name,
            ps_rec.name,
            ps_rec.employee_number,
            ps_rec.person_id,
            ps_rec.per_in_ler_id,
	    l_business_group_id;
	    /*
	    ,
            users;
	    */
      EXIT WHEN c_person_all%NOTFOUND;

      BEGIN
      IF (check_selection_rule(p_person_selection_rule_id => p_person_selection_rule_id
                              ,p_person_id                => ps_rec.person_id
                              ,p_business_group_id        => l_business_group_id
                              ,p_effective_date           => sysdate)) then

       /*WRITE('===========================================================================');
       WRITE(ps_rec.full_name||' - '||ps_rec.name||' - '||ps_rec.employee_number
             ||' - '||ps_rec.person_id||' - '||ps_rec.per_in_ler_id);*/
       l_emp_processed := l_emp_processed + 1;
       OPEN c_user_selection (ps_rec.person_id);
       FETCH c_user_selection bulk collect into v_users;
       CLOSE c_user_selection;
       /*FETCH users bulk collect into v_users;*/

       create_workflow ( v_users             => v_users
                 ,v_people                   => ps_rec
	         ,p_pl_id                    => p_pl_id
		 ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
		 ,p_messg_txt_title          => p_messg_txt_title
		 ,p_messg_txt_body           => p_messg_txt_body
		 ,p_include_cwb_link         => p_include_cwb_link
		 ,p_resend_if_prev_sent      => p_resend_if_prev_sent
		 ,p_mail_to_user             => p_mail_to_user
		 ,p_withhold_notifn          => p_withhold_notifn
                          );

       if(v_users.COUNT > 0) then
        l_emp_with_user := l_emp_with_user + 1;
       else
        l_emp_with_no_user := l_emp_with_no_user +1;
       end if;
       /*WRITE(v_users.COUNT||' users attached');*/
      ELSE
       v_users.delete;
      END IF;
      EXCEPTION
      WHEN others THEN
      WRITE('PERSON ID ERRORED :'||ps_rec.person_id);
      END;
    END LOOP;
    CLOSE c_person_all;
 else
 WRITE('STATUS - USERNAME - NAME - BUSINESS GROUP - EMP.NO. - PERSON ID - PER IN LER ID');
 OPEN c_person_selection (p_pl_id
                         ,l_lf_evt_ocrd_dt
                         ,p_target_pop
			 ,p_req_acc_lvl
                            );

    LOOP
      FETCH c_person_selection
       INTO ps_rec.full_name,
            ps_rec.name,
            ps_rec.employee_number,
            ps_rec.person_id,
            ps_rec.per_in_ler_id;
	    /*
	    ,
            users;
	    */

      EXIT WHEN c_person_selection%NOTFOUND;

       --l_pid.person_id := ps_rec.person_id;
       --g_selected_persons.extend;
       --g_selected_persons(g_selected_persons.last) := l_pid;

--WRITE('Person identified');
 /*WRITE('===========================================================================');
 WRITE(ps_rec.full_name||' - '||ps_rec.name||' - '||ps_rec.employee_number
      ||' - '||ps_rec.person_id||' - '||ps_rec.per_in_ler_id);*/
 l_emp_processed := l_emp_processed + 1;
 OPEN c_user_selection (ps_rec.person_id);
 FETCH c_user_selection bulk collect into v_users;

 --if v_users is not null then
/*
 for indx in v_users.first .. v_users.last
 loop
 insert into nt values (v_users(indx));
 end loop;
 */
 --end if;
 /*WRITE(v_users.COUNT||' users attached');*/
       if(v_users.COUNT > 0) then
        l_emp_with_user := l_emp_with_user + 1;
       else
        l_emp_with_no_user := l_emp_with_no_user +1;
       end if;
 --end if;
 create_workflow ( v_users             => v_users
                 ,v_people                   => ps_rec
	         ,p_pl_id                    => p_pl_id
		 ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
		 ,p_messg_txt_title          => p_messg_txt_title
		 ,p_messg_txt_body           => p_messg_txt_body
		 ,p_include_cwb_link         => p_include_cwb_link
		 ,p_resend_if_prev_sent      => p_resend_if_prev_sent
		 ,p_mail_to_user             => p_mail_to_user
		 ,p_withhold_notifn          => p_withhold_notifn
                          );
    CLOSE c_user_selection;
    END LOOP;
    CLOSE c_person_selection;
    end if;
    /* commenting out - sending indiv processes
     ------------------------------------------------------------
     wf_engine.setitemattrtext (itemtype => 'BENCWBFY',
                                itemkey  => l_wf_key,
                                aname    => 'MASS_NTF_RCVR',
                                avalue   => adhocRole);
     wf_engine.StartProcess (ItemType => 'BENCWBFY',
                             ItemKey  => l_wf_key);
     ------------------------------------------------------------
     */
  WRITE ('=============================================================================');
  WRITE ('Employees processed                         : '|| l_emp_processed);
  WRITE ('Employees with users defined in FND_USER    : '|| l_emp_with_user);
  WRITE ('Employees with no users defined in FND_USER : '|| l_emp_with_no_user);
  WRITE ('Note: Notifications issued only to employee with defined user(s)');
  WRITE ('      and satisfying criteria as provided in the concurrent request.');
  WRITE ('=============================================================================');
  WRITE ('Notifications sent                          : '|| g_sent_total);
  WRITE ('Notifications not sent                      : '|| g_unsent_total);
  WRITE ('Note: Sum of sent and unsent notifications is the number of defined users,');
  WRITE ('      which may be greater than the employees processed, if there are multiple');
  WRITE ('      users defined for employees.');
  WRITE ('=============================================================================');
 if(p_withhold_notifn = 'Y') then
  WRITE('=========================++ !NOTE! ++========================================');
  WRITE('NOTIFICATIONS ARE WITHHELD AS THIS IS JUST A TEST RUN.');
  WRITE('ONLY LOG FILE IS GENERATED!');
  WRITE('=============================================================================');
 end if;

 WRITE('=============================================================================');
 WRITE ('Time '||to_char(sysdate,'yyyy/mm/dd:hh:mi:ssam'));
 WRITE('===============================END===========================================');
EXCEPTION
 when others then
 l_error:=sqlerrm;
 hr_utility.set_location ('exception is'||l_error , 300);
 Wf_Core.Context('BEN_CWB_MASS_NOTIFN_PKG', 'notify',l_error);
 WRITE('ERROR! '||l_error);
 --raise;
END;

end BEN_CWB_MASS_NOTIFN_PKG;

/
