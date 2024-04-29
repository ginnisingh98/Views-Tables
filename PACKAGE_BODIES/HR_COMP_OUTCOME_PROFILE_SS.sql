--------------------------------------------------------
--  DDL for Package Body HR_COMP_OUTCOME_PROFILE_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_COMP_OUTCOME_PROFILE_SS" AS
/* $Header: hrcorwrs.pkb 120.0 2005/05/30 23:23:03 appldev noship $ */
--
-- Private globals
  g_package         constant   varchar2(30) := 'HR_COMP_OUTCOME_PROFILE_SS';
  g_person_id          per_all_people_f.person_id%type;
  g_business_group_id  per_all_people_f.business_group_id%type;
  g_language_code      varchar2(5) default null;
--
  g_invalid_entry      exception;
  g_invalid_outcome exception;
--
  --
  cursor g_csr_get_preupd_cmpocm_rec(p_comp_element_outcome_id  in number) is
  select cvl.name
        ,cmpe.COMP_ELEMENT_OUTCOME_ID
        ,cmpe.object_version_number
        ,cmpe.COMPETENCE_ELEMENT_ID
        ,cmpe.OUTCOME_ID
        ,cmpe.date_from
        ,cmpe.date_to
 from   per_comp_element_outcomes  cmpe
        ,per_competence_outcomes_VL  cvl
  where  cmpe.comp_element_outcome_id = p_comp_element_outcome_id
  and    cmpe.outcome_id = cvl.outcome_id
  and    trunc(sysdate) between nvl(cmpe.date_from, trunc(sysdate))
         and nvl(cmpe.date_to, trunc(sysdate));
 cursor get_out_name(p_outcome_id in number) is
     select name
     from per_competence_outcomes_vl
     where outcome_id = p_outcome_id;
 cursor get_prev_start_date(p_comp_element_outcome_id in number) is
     select date_from
     from per_comp_element_outcomes
     where comp_element_outcome_id = p_comp_element_outcome_id;
 cursor get_mode(p_transaction_step_id in number) is
    select varchar2_value
    from hr_api_transaction_values
    where transaction_step_id = p_transaction_step_id and name = 'P_CHANGE_MODE';
--
--
-- ------------------------------------------------------------------------
-- ---------------------<api_validate_compout_record>-------------------
-- ------------------------------------------------------------------------
-- Purpose: This private signature will validate data entered by calling api's
--
Procedure api_validate_compout_record
          (p_validate                  in boolean default null
          ,p_competence_element_id     in number  DEFAULT null
          ,p_competence_id             IN NUMBER DEFAULT null
          ,p_outcome_id                in number default null
          ,p_change_mode               in varchar2 default null
          ,p_comp_element_outcome_id   in number default null
          ,p_preupd_obj_vers_num       in number default null
          ,p_date_from                 in varchar2 default null
          ,p_date_to                   in varchar2 default null
          ,p_date_from_date_type      out nocopy date
          ,p_date_to_date_type        out nocopy date
          ,p_person_id                IN number
          ,p_error_message                out nocopy long);
--
--
-------------------<check_delete_rec>----------------------------
-- purpose: This will delete the delete mark rec in case it is
-- selected afterwords--
Procedure check_delete_rec(p_item_type  IN varchar2
                ,p_item_key   IN varchar2
                ,p_actid      IN varchar2
                ,p_person_id  IN number
                ,p_outcome_id IN number);
-- Purpose
--
Procedure process_upd_api
           (p_comp_element_outcome_id   IN number
           ,p_to_date                 IN DATE
           ,p_object_version_number  IN number
           ) ;
-- ------------------------------------------------------------------------
-- ---------------------<check_if_cmptnce_rec_changed>---------------------
-- ------------------------------------------------------------------------
-- Purpose: This private signature will compare the values of the rec with the
--          values before update.
--          The caller has made sure that this procedure is called only on an
--          update or upgrade to new proficiency level mode.
--          IF the proficiency level is the same as pre-update value, it
--          will set an output parm to true if the p_change_mode is
--          upgrade a proficiency level.
-- ------------------------------------------------------------------------
Procedure check_if_cmpocm_rec_changed
          (p_comp_element_outcome_id   in number
          ,p_competence_element_id   in number default null
          ,p_competence_id           in number default null
          ,p_outcome_id              in number
          ,p_date_from           in date default null
          ,p_date_to             in date default null
          ,p_change_mode             in varchar2
          ,p_ignore_warning          in varchar2 default null
          ,p_rec_changed             out nocopy boolean);
--
-- ---------------------------------------------------------------------------
--
--
-- ---------------------------- < writeTo_transTbl > -----------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This private procedure to write into trans table
--          the transaction step is created if one doesn't exits
-- ---------------------------------------------------------------------------
--
Procedure writeTo_transTbl(
                 p_item_type                 IN wf_items.item_type%type
                 ,p_item_key                 IN wf_items.item_key%type
                 ,p_actid                    IN Number
                 ,p_login_person_id          IN Number
                 ,p_trans_id                 IN Number
                 ,p_trans_step_id            IN OUT NOCOPY Number
                 ,p_api_name                 IN Varchar2
                 ,p_comp_element_outcome_id  IN Number Default Null
                 ,p_ovn                      IN Number Default Null
                 ,p_date_from                IN Varchar2 Default Null
                 ,p_date_to                  IN Varchar2 Default Null
                 ,p_comp_element_id          IN Number Default Null
                 ,p_outcome_id               IN Varchar2 Default Null
                 ,p_outcome_name             IN Varchar2 Default Null
                 ,p_change_mode              IN Varchar2 Default Null
                 ,p_person_id                IN VARCHAR2 DEFAULT null
                 ,p_sys_generated            IN Varchar2 DEFAULT null
                 ,p_upg_from_rec_id          IN Number Default 'N'
                 ,p_competence_id            IN NUMBER DEFAULT null) is
--
l_trans_tbl transaction_table1;
l_count Number:=0;
x_trans_ovn Number;
l_review_region Varchar2(200);
l_comp_element_outcome_id    per_comp_element_outcomes.comp_element_outcome_id%type;
l_proc varchar2(200);
Begin
l_proc := g_package || 'writeTo_transTbl';
hr_utility.set_location(' Entering:' || l_proc,5);
--
IF (p_comp_element_outcome_id = -1) Then
hr_utility.set_location(' Entering:' || l_proc,10);
   l_comp_element_outcome_id := null;
else
hr_utility.set_location(' Entering:' || l_proc,15);
   l_comp_element_outcome_id := p_comp_element_outcome_id;
END if;
hr_utility.set_location(l_proc,20);
--
        If p_trans_step_id is null then
           hr_utility.set_location(l_proc,25);
                hr_transaction_api.create_transaction_step
                      (p_validate => false
                      ,p_creator_person_id => p_login_person_id
                      ,p_transaction_id => p_trans_id
                      ,p_api_name => p_api_name
                      ,p_item_type => p_item_type
                      ,p_item_key => p_item_key
                      ,p_activity_id => p_actid
                      ,p_transaction_step_id => p_trans_step_id
                  ,p_object_version_number => x_trans_ovn);
--
    End if;
        hr_utility.set_location(l_proc,30);
        l_count := 1;
        l_trans_tbl(l_count).param_name := 'P_COMP_ELEMENT_OUTCOME_ID';
        l_trans_tbl(l_count).param_value := l_comp_element_outcome_id;
        l_trans_tbl(l_count).param_data_type := 'NUMBER';
--
        l_count := l_count + 1;
        l_trans_tbl(l_count).param_name := 'P_OBJECT_VERSION_NUMBER';
        l_trans_tbl(l_count).param_value := p_ovn;
        l_trans_tbl(l_count).param_data_type := 'NUMBER';
--
        l_count := l_count + 1;
        l_trans_tbl(l_count).param_name := 'P_DATE_FROM';
        l_trans_tbl(l_count).param_value := p_date_from;
        l_trans_tbl(l_count).param_data_type := 'DATE';
--
        l_count := l_count + 1;
        l_trans_tbl(l_count).param_name := 'P_OUTCOME_ID';
        l_trans_tbl(l_count).param_value := p_outcome_id;
        l_trans_tbl(l_count).param_data_type := 'NUMBER';
--
        l_count := l_count + 1;
        l_trans_tbl(l_count).param_name := 'P_OUTCOME_NAME';
        l_trans_tbl(l_count).param_value := p_outcome_name;
        l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
--
        l_count := l_count + 1;
        l_trans_tbl(l_count).param_name := 'P_COMPETENCE_ELEMENT_ID';
        l_trans_tbl(l_count).param_value := p_comp_element_id;
        l_trans_tbl(l_count).param_data_type := 'NUMBER';
--
        l_count := l_count + 1;
        l_trans_tbl(l_count).param_name := 'P_DATE_TO';
        l_trans_tbl(l_count).param_value := p_date_to;
        l_trans_tbl(l_count).param_data_type := 'DATE';
--
        l_count := l_count + 1;
        l_trans_tbl(l_count).param_name := 'P_SYSTEM_GENERATED';
        l_trans_tbl(l_count).param_value := p_sys_generated;
        l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
--
        l_count := l_count + 1;
        l_trans_tbl(l_count).param_name := 'P_PERSON_ID';
        l_trans_tbl(l_count).param_value := p_person_id;
        l_trans_tbl(l_count).param_data_type := 'NUMBER';
--
        l_count := l_count + 1;
        l_trans_tbl(l_count).param_name := 'P_COMPETENCE_ID';
        l_trans_tbl(l_count).param_value := p_competence_id;
        l_trans_tbl(l_count).param_data_type := 'NUMBER';
--
   If p_upg_from_rec_id <> -1 then
        hr_utility.set_location(l_proc,35);
        l_count := l_count + 1;
        l_trans_tbl(l_count).param_name := 'P_UPGRADED_FROM_REC_ID';
        l_trans_tbl(l_count).param_value := p_upg_from_rec_id;
        l_trans_tbl(l_count).param_data_type := 'NUMBER';
   End if;
--
    l_count := l_count + 1;
        l_trans_tbl(l_count).param_name := 'P_REVIEW_ACTID';
        l_trans_tbl(l_count).param_value := p_actid;
        l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
--
      l_review_region := wf_engine.GetActivityAttrText
                                            (itemtype => p_item_type
                                            ,itemkey => p_item_key
                                            ,actid   => p_actid
                                            ,aname   => 'HR_REVIEW_REGION_ITEM'
                                            ,ignore_notfound => true);
--
    l_count := l_count + 1;
        l_trans_tbl(l_count).param_name := 'P_REVIEW_PROC_CALL';
        l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
        l_trans_tbl(l_count).param_value := l_review_region;
        hr_utility.set_location(l_proc,40);
        save_transaction_step(p_item_type => p_item_type
                    ,p_item_key => p_item_key
                ,p_actid => p_actid
                ,p_login_person_id => p_login_person_id
                ,p_transaction_step_id => p_trans_step_id
                ,p_api_name => p_api_name
                ,p_transaction_data => l_trans_tbl);
--
--
End writeTo_transTbl;
--
-- ---------------------------------------------------------------------------
-- ---------------------------- < comp_not_exists > --------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This function is being used for filtering current session changes
--          and pending approval changes
-- ---------------------------------------------------------------------------
-- ---------------------------------------------------------------------------
-- ---------------------------- < process_save > -----------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This private procedure saves the competence outcome record either
--          to the database or to the transaction table depending on the
--          workflow setting.
-- ---------------------------------------------------------------------------
--
Procedure process_save
          (p_item_type                in wf_items.item_type%type
          ,p_item_key                 in wf_items.item_key%type
          ,p_actid                    in varchar2
          ,p_change_mode              in varchar2  default null
          ,p_comp_element_outcome_id  in number default -1
          ,p_competence_id            IN NUMBER DEFAULT null
          ,p_competence_element_id    in number default null
          ,p_preupd_obj_vers_num      in number default null
          ,p_outcome_id               in number default null
          ,p_outcome_name             in varchar2 default null
          ,p_date_from                in varchar2 default null
          ,p_date_to                  in varchar2 default null
          ,p_prev_start_date          in varchar2 default null
          ,p_ignore_warning           in varchar2 default null
          ,p_transaction_step_id      in out nocopy number
          ,p_person_id                IN number DEFAULT null
          ,p_error_message          out nocopy long) is
CURSOR getobjno (p_comp_element_outcome_id IN number) is
       SELECT object_version_number FROM per_comp_element_outcomes
       WHERE comp_element_outcome_id = p_comp_element_outcome_id;
  --
  l_transaction_id                  number default null;
  l_transaction_step_id             number default null;
  l_result                          varchar2(100) default null;
  l_user_date_format                varchar2(200) default null;
  x_date_from                       date default null;
  x_date_to                         date default null;
  l_preupd_cmpocm_row               g_csr_get_preupd_cmpocm_rec%rowtype;
--
  l_date_from                       date default null;
  l_obj_ver_num                     number default null;
 l_comp_element_outcome_id per_comp_element_outcomes.comp_element_outcome_id%type;
l_trans_obj_vers_num                NUMBER DEFAULT null;
l_proc varchar2(200) ;
--
----------------------------------
Begin
    l_obj_ver_num := 1;
    l_proc := g_package || 'process_save';
    hr_utility.set_location(' Entering:' || l_proc,5);
    l_user_date_format := g_date_format ;
    l_date_from := to_date(p_date_from,l_user_date_format);
    l_obj_ver_num := p_preupd_obj_vers_num;
--
IF p_comp_element_outcome_id IS NULL then
    hr_utility.set_location(' Entering:' || l_proc,10);
   l_comp_element_outcome_id := -1;
Else
  l_comp_element_outcome_id := p_comp_element_outcome_id;
  IF p_preupd_obj_vers_num IS NULL then
  FOR ovn IN getobjno (p_comp_element_outcome_id => p_comp_element_outcome_id)
  loop
      l_obj_ver_num := ovn.object_version_number;
  END loop;
  END if;
END if;
    hr_utility.set_location(' Entering:' || l_proc,20);
    api_validate_compout_record
          (p_validate                  => TRUE
          ,p_competence_element_id     => p_competence_element_id
          ,p_outcome_id                => p_outcome_id
          ,p_change_mode               => p_change_mode
          ,p_comp_element_outcome_id   => l_comp_element_outcome_id
          ,p_preupd_obj_vers_num       => l_obj_ver_num
          ,p_date_from                 => p_date_from
          ,p_date_to                   => p_date_to
          ,p_date_from_date_type         => x_date_from
          ,p_date_to_date_type           => x_date_to
          ,p_person_id                   => p_person_id
          ,p_error_message               =>  p_error_message);
        if p_error_message is not null then
            Return;
        end if;
    hr_utility.set_location(' Entering:' || l_proc,25);
    l_transaction_id := hr_transaction_ss.get_transaction_id(p_item_type   => p_item_type
                                                            ,p_item_key    => p_item_key);
--
    IF l_transaction_id is null THEN
       hr_utility.set_location(' Entering:' || l_proc,30);
       -- Start a Transaction
        hr_transaction_ss.start_transaction
           (itemtype   => p_item_type
           ,itemkey    => p_item_key
           ,actid      => to_number(p_actid)
           ,funmode    => 'RUN'
           ,p_login_person_id => fnd_global.employee_id
           ,result     => l_result);
       hr_utility.set_location(' Entering:' || l_proc,40);
        l_transaction_id := hr_transaction_ss.get_transaction_id
            (p_item_type   => p_item_type
            ,p_item_key    => p_item_key);
    END IF;
--
    IF p_transaction_step_id IS NULL then
      hr_utility.set_location(' Entering:' || l_proc,50);
      hr_transaction_api.create_transaction_step
     (p_validate              => false
     ,p_creator_person_id     => fnd_global.employee_id
     ,p_transaction_id        => l_transaction_id
     ,p_api_name              => g_api_name
     ,p_item_type             => p_item_type
     ,p_item_key              => p_item_key
     ,p_activity_id           => to_number(p_actid)
     ,p_transaction_step_id   => p_transaction_step_id
     ,p_object_version_number => l_trans_obj_vers_num);
   end if;
--
        hr_utility.set_location(' Entering:' || l_proc,60);
               writeTo_transTbl (
                         p_item_type                 => p_item_type
                        ,p_item_key                 =>  p_item_key
                        ,p_actid                    =>  To_Number(p_actid)
                        ,p_login_person_id          =>  fnd_global.employee_id
                        ,p_trans_id                 =>  l_transaction_id
                        ,p_trans_step_id            =>  p_transaction_step_id
                        ,p_api_name                 =>  g_api_name
                        ,p_comp_element_outcome_id  =>  l_comp_element_outcome_id
                        ,p_competence_id            =>  p_competence_id
                        ,p_ovn                      =>  l_obj_ver_num
                        ,p_date_from                =>  p_date_from
                        ,p_date_to                  =>  p_date_to
                        ,p_comp_element_id          =>  p_competence_element_id
                        ,p_outcome_id               =>  p_outcome_id
                        ,p_outcome_name             =>  p_outcome_name
                        ,p_change_mode              =>  p_change_mode
                        ,p_person_id                =>  p_person_id
                        ,p_sys_generated            => 'N'
                        ,p_upg_from_rec_id          => l_comp_element_outcome_id);
--
  EXCEPTION
    When g_invalid_entry then
    hr_utility.set_location(' Entering:' || l_proc,70);
      raise g_invalid_entry;
--
    WHEN hr_comp_outcome_profile_ss.g_data_err THEN
      hr_utility.set_location(' Entering:' || l_proc,80);
      raise hr_utility.hr_error;
--
    WHEN hr_comp_outcome_profile_ss.g_access_violation_err THEN
      hr_utility.set_location(' Entering:' || l_proc,90);
      raise hr_utility.hr_error;
--
    When others THEN
      hr_utility.set_location(' Entering:' || l_proc,100);
      raise g_invalid_entry ;
End process_save;
--
-- ---------------------------------------------------------------------------
--
Procedure call_process_api (
          p_validate               in boolean  default false
          ,p_competence_element_id IN number
          ,p_new_competence_element_id IN number
          ,p_competence_id         IN number
          ,p_item_type             IN hr_api_transaction_steps.item_type%type
          ,p_item_key              IN hr_api_transaction_steps.item_key%type
          ,p_activity_id           IN hr_api_transaction_steps.ACTIVITY_ID%type
          ,p_person_id             IN Number
          ,p_effective_date        IN Date DEFAULT trunc(sysdate)) is
--
l_transaction_step_id    hr_api_transaction_steps.transaction_step_id%type;
--
CURSOR get_txn_step_id (p_comp_id IN number, p_comp_ele_id IN number,
        p_eff_date IN DATE DEFAULT null, p_person_id IN number) is
Select ts.transaction_step_id
FROM hr_api_transaction_steps ts,
     hr_api_transaction_values tv,
     hr_api_transaction_values tv1,
     hr_api_transaction_values tv2,
     hr_api_transaction_values tv3,
     hr_api_transaction_values tv4
Where ts.transaction_step_id = tv.transaction_step_id
AND ts.item_type = p_item_type
AND ts.item_key = p_item_key
AND ts.activity_id = p_activity_id
AND ts.API_NAME = 'HR_COMP_OUTCOME_PROFILE_SS.PROCESS_API'
And tv4.transaction_step_id = ts.transaction_step_id
And tv4.NAME = 'P_PERSON_ID'
AND tv4.Number_Value = p_person_id
AND tv1.transaction_step_id(+) = ts.transaction_step_id
AND tv.NAME = 'P_COMPETENCE_ID'
AND tv.number_value = p_comp_id
AND tv1.NAME(+) = 'P_COMPETENCE_ELEMENT_ID'
AND tv1.number_value(+) = p_comp_ele_id
AND tv2.transaction_step_id = ts.transaction_step_id
AND tv2.NAME = 'P_DATE_FROM'
AND tv3.transaction_step_id = ts.transaction_step_id
AND tv3.NAME = 'P_DATE_TO';
-- AND nvl(p_eff_date,sysdate) BETWEEN tv2.date_value AND nvl(tv3.date_value,sysdate);
---
Cursor get_enddate_outcome_ids(p_comp_ele_id IN number) is
      Select ceo.comp_element_outcome_id ,ts.transaction_step_id,ceo.object_version_number
      FROM
             per_comp_element_outcomes ceo,
             hr_api_transaction_steps ts,
             hr_api_transaction_values tv
      where
            ceo.competence_element_id = p_comp_ele_id
        AND ts.item_type = p_item_type
        AND ts.item_key = p_item_key
        AND ts.activity_id = p_activity_id
        AND ts.transaction_step_id = tv.transaction_step_id
        AND tv.NAME = 'P_COMP_ELEMENT_OUTCOME_ID'
        AND ts.API_NAME = 'HR_COMP_OUTCOME_PROFILE_SS.DELETE'
        AND tv.number_value = ceo.COMP_ELEMENT_OUTCOME_ID;
--
Cursor get_unchngd_outcomes(p_comp_ele_id IN NUMBER ) is
Select co.outcome_id
       ,ceo.DATE_FROM
       ,ceo.DATE_TO
       ,ceo.object_version_number
  From per_Competence_Outcomes co
       ,Per_comp_element_outcomes ceo
Where ceo.COMPETENCE_ELEMENT_ID = p_comp_ele_id
      AND co.outcome_id = ceo.outcome_id
      AND NOT EXISTS (Select 1 FROM hr_api_transaction_values tv1,
                               hr_api_transaction_values tv2,
                               hr_api_transaction_values tv3,
                               hr_api_transaction_values tv4,
                               hr_api_transaction_steps s
                  WHERE tv1.transaction_step_id = s.transaction_step_id
                                  and  s.item_type = p_item_type
                  and s.item_key = p_item_key
                  and s.activity_id = nvl(to_number(p_activity_id),s.activity_id)
                  and s.api_name = 'HR_COMP_OUTCOME_PROFILE_SS.PROCESS_API'
                  And tv2.transaction_step_id = s.transaction_step_id
                  And tv3.transaction_step_id = s.transaction_step_id
                  AND tv4.transaction_step_id = s.transaction_step_id
                  AND tv4.NAME = 'P_PERSON_ID'
                  AND tv4.number_value = p_person_id
                  AND tv1.name = 'P_OUTCOME_ID'
                  AND tv1.number_value = co.OUTCOME_ID
                  AND tv2.name = 'P_DATE_FROM'
                                  AND tv3.name = 'P_DATE_TO'
                  AND tv2.date_Value >= co.date_from
     AND nvl(tv3.date_Value,trunc(sysdate)) <= nvl(co.date_to,nvl(tv3.date_Value,trunc(sysdate)))
and not exists (
Select 1 from per_comp_element_outcomes pco
         Where pco.competence_element_id = ceo.COMPETENCE_ELEMENT_ID
		 and pco.outcome_id = co.OUTCOME_ID
		 and pco.date_from = tv2.date_value
		 and nvl(pco.date_to,to_date('01-01-1001','DD-MM-YYYY')) = nvl(tv3.
		 date_value,to_date('01-01-1001','DD-MM-YYYY')))
	 )
     And NOT EXISTS (SELECT 1
      FROM hr_api_transaction_steps S1,
            hr_api_transaction_values C
     Where  s1.item_type = p_item_type
     and s1.item_key = p_item_key
     and s1.activity_id = nvl((p_activity_id),s1.activity_id)
     and s1.api_name = 'HR_COMP_OUTCOME_PROFILE_SS.DELETE'
          and c.transaction_step_id = s1.transaction_step_id
          AND C.NAME = 'P_COMP_ELEMENT_OUTCOME_ID'
          AND ceo.comp_element_outcome_id = C.number_value);
Cursor get_new_compele_dtls( p_new_comp_ele_id IN number) is
       Select ce.Effective_date_From,ce.Effective_date_to
       From per_competence_elements ce
       Where ce.COMPETENCE_ELEMENT_ID = p_new_comp_ele_id;
/*      Select ceo.outcome_id,ceo.date_from,ceo.date_to,
             ce.Effective_date_From,ce.Effective_date_to, ceo.object_version_number
             From per_comp_element_outcomes ceo,
                  per_competence_elements ce
             Where ceo.competence_element_id = p_comp_ele_id
             AND   ce.competence_element_id = p_new_comp_ele_id;*/
--
TYPE new_compele_dtl_rec is RECORD (
        Effective_date_From per_competence_elements.Effective_date_From%TYPE,
        Effective_date_to   per_competence_elements.Effective_date_to%TYPE
    );
new_compele_dtl_record new_compele_dtl_rec;
l_count number;
l_Start_Date per_Comp_Element_Outcomes.Date_from%type;
l_End_Date per_Comp_Element_Outcomes.Date_to%type;
l_comp_ele_outcome_id per_Comp_Element_Outcomes.comp_Element_Outcome_id%type;
l_obj_ver_no number;
l_proc varchar2(200) ;
begin
-- hr_utility.trace_on(null,'COMPQUAL');
l_proc := g_package || ' call_process_api';
hr_utility.set_location(' Entering:' || l_proc,10);
--hr_utility.set_location(' p_validate:' || to_char(p_validate),10);
hr_utility.set_location(' p_competence_element_id:' || p_competence_element_id,10);
hr_utility.set_location(' p_new_competence_element_id:' || p_new_competence_element_id,10);
hr_utility.set_location(' p_competence_id:' || p_competence_id,10);
hr_utility.set_location(' p_item_type:' || p_item_type,10);
hr_utility.set_location(' p_item_key:' || p_item_key,10);
hr_utility.set_location(' p_activity_id:' || p_activity_id,10);
hr_utility.set_location(' p_person_id:' || p_person_id,10);
hr_utility.set_location(' p_effective_date:' || to_char(p_effective_date,'DD-MON-YYYY'),10);
savepoint save_comp_element_outcome;
l_count := 0;
--
FOR outids IN get_enddate_outcome_ids(p_competence_element_id)
    loop
       l_count := l_count +1;
       process_upd_api(p_comp_element_outcome_id => outids.comp_element_outcome_id
                       ,p_to_date => trunc(sysdate)
                       ,p_object_version_number => outids.object_version_number );
       delete_transaction_step_id(outids.transaction_step_id);
    END loop;
hr_utility.set_location(' Entering:' || l_proc,20);
--
FOR txnids IN get_txn_step_id(
                       p_comp_id     => p_competence_id
                      ,p_comp_ele_id => p_competence_element_id
                      ,p_person_id   => p_person_id
                      ,p_eff_date    => p_effective_date)
loop
hr_utility.set_location(' Entering:' || l_proc,30);
hr_utility.set_location(' p_new_competence_element_id:' || p_new_competence_element_id,30);
hr_utility.set_location(' p_effective_date:' || l_proc,30);
hr_utility.set_location(' p_transaction_step_id: ' || txnids.transaction_step_id,30);
 HR_COMP_OUTCOME_PROFILE_SS.process_api(
                      p_validate               => p_validate
                     ,p_competence_element_id => p_new_competence_element_id
                     ,p_effective_date        => p_effective_date
                     ,p_transaction_step_id   => txnids.transaction_step_id);
END loop;
hr_utility.set_location(' Entering:' || l_proc,40);
hr_utility.set_location(' p_competence_element_id: ' || p_competence_element_id,40);
hr_utility.set_location(' p_new_competence_element_id: ' || p_new_competence_element_id,40);
hr_utility.set_location(' l_count :' || l_count,40);
--
l_count := 0;
IF p_competence_element_id <> p_new_competence_element_id then
   FOR unchangedRec IN get_unchngd_outcomes(p_competence_element_id)
   loop
       IF l_count = 0 then
          l_count := 1;
          OPEN get_new_compele_dtls(p_new_competence_element_id);
          FETCH get_new_compele_dtls INTO new_compele_dtl_record;
          IF get_new_compele_dtls%NOTFOUND then
             CLOSE get_new_compele_dtls;
             RAISE hr_comp_outcome_profile_ss.g_data_err;
          else
              CLOSE get_new_compele_dtls;
          END if;
       END if;
--       IF new_compele_dtl_record.Effective_date_From > unchangedRec.date_From Then
           l_start_date := unchangedRec.date_From;
--       else
--           l_start_date := new_compele_dtl_record.Effective_date_From;
--       End if;
--       IF new_compele_dtl_record.Effective_date_TO IS NOT NULL Then
--          IF unchangedRec.date_to IS NOT NULL Then
--              IF new_compele_dtl_record.Effective_date_to > unchangedRec.date_to then
--                 l_End_Date := unchangedRec.date_to;
--              Else
--                 l_End_Date := new_compele_dtl_record.Effective_date_to;
--              End if;
--          Else
--              l_End_Date := new_compele_dtl_record.Effective_date_to;
--          End if;
--       Else
--          IF unchangedRec.date_to IS NOT NULL Then
             l_End_Date := unchangedRec.date_to;
--          End if;
--       End if;
--
       hr_utility.set_location(' Entering l_comp_ele_outcome_id:' || l_comp_ele_outcome_id,50);
       hr_utility.set_location(' Entering p_new_competence_element_id:' || p_new_competence_element_id,50);
       hr_utility.set_location(' Entering l_obj_ver_no:' || l_obj_ver_no,50);
       hr_utility.set_location(' Entering unchangedRec.outcome_id:' || unchangedRec.outcome_id,50);
       hr_utility.set_location(' Entering l_Start_Date:' || l_Start_Date,50);
       hr_utility.set_location(' Entering l_End_Date:' || l_End_Date,50);
       hr_utility.set_location(' Entering unchangedRec.date_From:' || unchangedRec.date_From,50);
       hr_utility.set_location(' Entering unchangedRec.date_to:' || unchangedRec.date_to,50);
       hr_utility.set_location(' Entering trunc(sysdate) :' || trunc(sysdate),50);
       per_ceo_ins.ins(
        p_comp_element_outcome_id => l_comp_ele_outcome_id
       ,p_competence_element_id   => p_new_competence_element_id
       ,p_object_version_number   => l_obj_ver_no
       ,p_outcome_id              => unchangedRec.outcome_id
       ,p_date_from               => unchangedRec.date_From
       ,p_date_to                 => unchangedRec.date_to
       ,p_effective_date          => trunc(sysdate));
--
   END loop;
hr_utility.set_location(' Entering:' || l_proc,80);
END if;
-- hr_utility.trace_off;
--
    EXCEPTION
    WHEN hr_comp_outcome_profile_ss.g_data_err THEN
      hr_utility.set_location(' Entering:' || l_proc,90);
      raise hr_utility.hr_error;
    --
    WHEN hr_comp_outcome_profile_ss.g_access_violation_err THEN
      hr_utility.set_location(' Entering:' || l_proc,100);
      raise hr_utility.hr_error;
    --
    When others THEN
      hr_utility.set_location(' Entering:' || l_proc,110);
      raise hr_utility.hr_error;
--
END call_process_api;
-- ---------------------------- < process_api > ------------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure reads the data from transaction table and saves it
--    to the database.
--    This procedure is called called from HR_COMP_PROFILE_SS.PROCESS_API
--
-- ---------------------------------------------------------------------------
Procedure process_api(p_validate               in boolean default false
                     ,p_transaction_step_id    in NUMBER
                     ,p_competence_element_id  IN number
                     ,p_effective_date         in varchar2 default null) is
  --
  Cursor getoldrec(p_comp_element_outcome_id IN number) is
         Select COMPETENCE_ELEMENT_ID ,
                OUTCOME_ID,
                DATE_FROM,
                DATE_TO
         FROM per_comp_element_outcomes
         Where comp_element_outcome_id = p_comp_element_outcome_id;
  l_cmpout_element_rec             per_comp_element_outcomes%rowtype;
  l_system_generated            varchar2(1) default null;
  l_upgraded_from_rec_id        number DEFAULT Null;
  l_preupd_proficy_lvl_id       number default NULL;
  l_outcome_name                per_competence_outcomes_vl.name%type;
  l_txn_step_id                 hr_api_transaction_steps.transaction_step_id%type;
  l_count                       number;
  l_proc varchar2(200) ;
  --
Begin
  --
l_proc := g_package || 'process_api';
hr_utility.set_location(' p_transaction_step_id:' || p_transaction_step_id,10);
hr_utility.set_location(' p_competence_element_id:' || p_competence_element_id,10);
hr_utility.set_location(' Entering:' || l_proc,10);
hr_utility.set_location(' Entering:' || l_proc,10);
hr_utility.set_location(' Entering:' || l_proc,10);
hr_utility.set_location(' Entering:' || l_proc,10);
l_count := 0;
 l_cmpout_element_rec.comp_element_outcome_id :=
    hr_transaction_api.get_number_value
       (p_transaction_step_id => p_transaction_step_id
       ,p_name                => 'P_COMP_ELEMENT_OUTCOME_ID');
  --
  l_cmpout_element_rec.competence_element_id :=
    hr_transaction_api.get_number_value
       (p_transaction_step_id => p_transaction_step_id
       ,p_name                => 'P_COMPETENCE_ELEMENT_ID');
  --
  l_cmpout_element_rec.object_version_number :=
    hr_transaction_api.get_number_value
       (p_transaction_step_id => p_transaction_step_id
       ,p_name                => 'P_OBJECT_VERSION_NUMBER');
  --
  l_cmpout_element_rec.outcome_id :=
    hr_transaction_api.get_number_value
       (p_transaction_step_id => p_transaction_step_id
       ,p_name                => 'P_OUTCOME_ID');
--
  l_outcome_name :=
    hr_transaction_api.get_varchar2_value
       (p_transaction_step_id => p_transaction_step_id
       ,p_name                => 'P_OUTCOME_NAME');
--
  l_cmpout_element_rec.date_from :=
    hr_transaction_api.get_date_value
       (p_transaction_step_id => p_transaction_step_id
       ,p_name                => 'P_DATE_FROM');
  --
  l_cmpout_element_rec.date_to :=
    hr_transaction_api.get_date_value
       (p_transaction_step_id => p_transaction_step_id
       ,p_name                => 'P_DATE_TO');
  --
  l_upgraded_from_rec_id := NULL;
  l_upgraded_from_rec_id :=
    hr_transaction_api.get_number_value
       (p_transaction_step_id => p_transaction_step_id
       ,p_name                => 'P_UPGRADED_FROM_REC_ID');
--
/*  IF l_system_generated = 'N' AND
        l_upgraded_from_rec_id is not null THEN
        hr_utility.set_location(' Entering:' || l_proc,20);
        l_cmpout_element_rec.comp_element_outcome_id := null;
  END IF;*/
  --
  -- set a savepoint before calling api
 --
 IF (l_cmpout_element_rec.comp_element_outcome_id IS NULL OR l_cmpout_element_rec.comp_element_outcome_id = -1) then
  hr_utility.set_location(' Entering: Inserting new record' || l_proc,30);
        hr_utility.set_location(' l_cmpout_element_rec.comp_element_outcome_id:' || l_cmpout_element_rec.comp_element_outcome_id,30);
      hr_utility.set_location(' l_cmpout_element_rec.object_version_number:' || l_cmpout_element_rec.object_version_number,30);
      hr_utility.set_location(' l_cmpout_element_rec.date_to:' ||to_char(l_cmpout_element_rec.date_to,'DD-MON-YYYY'),30);
      hr_utility.set_location(' l_cmpout_element_rec.outcome_id :' || l_cmpout_element_rec.outcome_id ,30);
      hr_utility.set_location(' l_cmpout_element_rec.date_from :' || l_cmpout_element_rec.date_from ,30);
      hr_utility.set_location(' l_cmpout_element_rec.date_to :' || l_cmpout_element_rec.date_to ,30);
      hr_utility.set_location(' l_upgraded_from_rec_id :' || l_upgraded_from_rec_id ,30);
      per_ceo_ins.ins(
        p_comp_element_outcome_id => l_cmpout_element_rec.comp_element_outcome_id
       ,p_competence_element_id   => p_competence_element_id
       ,p_object_version_number   => l_cmpout_element_rec.object_version_number
       ,p_outcome_id              => l_cmpout_element_rec.outcome_id
       ,p_date_from               => l_cmpout_element_rec.date_from
       ,p_date_to                 => l_cmpout_element_rec.date_to
       ,p_effective_date          => trunc(sysdate));
 else
  FOR rec IN getoldrec( p_comp_element_outcome_id =>  l_cmpout_element_rec.comp_element_outcome_id)
  loop
  IF rec.COMPETENCE_ELEMENT_ID= l_cmpout_element_rec.competence_element_id AND
     rec.OUTCOME_ID  = l_cmpout_element_rec.outcome_id and
     rec.DATE_FROM   = l_cmpout_element_rec.date_from and
     ((rec.DATE_TO IS NULL AND l_cmpout_element_rec.date_to IS null) or
      (rec.DATE_TO = l_cmpout_element_rec.date_to)) then
 hr_utility.set_location(' Entering: in if record is same' || l_proc,30);
  else
  IF l_system_generated = 'Y' AND
     l_cmpout_element_rec.competence_element_id = p_competence_element_id      THEN
      hr_utility.set_location(' Entering:' || l_proc,30);
      hr_utility.set_location(' l_cmpout_element_rec.comp_element_outcome_id:' || l_cmpout_element_rec.comp_element_outcome_id,30);
      hr_utility.set_location(' l_cmpout_element_rec.object_version_number:' || l_cmpout_element_rec.object_version_number,30);
      hr_utility.set_location(' l_cmpout_element_rec.date_to:' ||to_char(l_cmpout_element_rec.date_to,'DD-MON-YYYY'),30);
      hr_utility.set_location(' l_upgraded_from_rec_id :' || l_upgraded_from_rec_id ,30);
--     IF rec.DATE_FROM   < l_cmpout_element_rec.date_from then
       process_upd_api(p_comp_element_outcome_id => l_cmpout_element_rec.comp_element_outcome_id
                      ,p_to_date => trunc(sysdate)
                      ,p_object_version_number => l_cmpout_element_rec.object_version_number);
       per_ceo_ins.ins(
        p_comp_element_outcome_id => l_cmpout_element_rec.comp_element_outcome_id
       ,p_competence_element_id   => p_competence_element_id
       ,p_object_version_number   => l_cmpout_element_rec.object_version_number
       ,p_outcome_id              => l_cmpout_element_rec.outcome_id
       ,p_date_from               => l_cmpout_element_rec.date_from
       ,p_date_to                 => l_cmpout_element_rec.date_to
       ,p_effective_date          => trunc(sysdate));
/*     else
     per_ceo_upd.upd (
        p_comp_element_outcome_id => l_cmpout_element_rec.comp_element_outcome_id
       ,p_object_version_number   => l_upgraded_from_rec_id
       ,p_date_from               => l_cmpout_element_rec.date_from
       ,p_date_to                 => l_cmpout_element_rec.date_to
       ,p_effective_date          => trunc(sysdate));
     END if;
     --*/
     ELSIF l_cmpout_element_rec.competence_element_id = p_competence_element_id THEN
      hr_utility.set_location(' Entering:' || l_proc,40);
      hr_utility.set_location(' l_cmpout_element_rec.comp_element_outcome_id:' || l_cmpout_element_rec.comp_element_outcome_id,30);
      hr_utility.set_location(' l_cmpout_element_rec.object_version_number:' || l_cmpout_element_rec.object_version_number,30);
      hr_utility.set_location(' l_cmpout_element_rec.date_to:' ||to_char(l_cmpout_element_rec.date_to,'DD-MON-YYYY'),30);
      hr_utility.set_location(' l_cmpout_element_rec.date_from:' || l_cmpout_element_rec.date_from,30);
      hr_utility.set_location(' l_upgraded_from_rec_id:' || l_upgraded_from_rec_id,30);
      hr_utility.set_location(' rec.DATE_FROM' || rec.DATE_FROM,40);
      hr_utility.set_location(' l_cmpout_element_rec.date_from' || l_cmpout_element_rec.date_from,40);
--     IF rec.DATE_FROM   < l_cmpout_element_rec.date_from then
       process_upd_api(p_comp_element_outcome_id => l_cmpout_element_rec.comp_element_outcome_id
                      ,p_to_date => trunc(sysdate)
                      ,p_object_version_number => l_cmpout_element_rec.object_version_number);
       per_ceo_ins.ins(
        p_comp_element_outcome_id => l_cmpout_element_rec.comp_element_outcome_id
       ,p_competence_element_id   => p_competence_element_id
       ,p_object_version_number   => l_cmpout_element_rec.object_version_number
       ,p_outcome_id              => l_cmpout_element_rec.outcome_id
       ,p_date_from               => l_cmpout_element_rec.date_from
       ,p_date_to                 => l_cmpout_element_rec.date_to
       ,p_effective_date          => trunc(sysdate));
/*     else
      per_ceo_upd.upd
       (p_comp_element_outcome_id => l_cmpout_element_rec.comp_element_outcome_id
       ,p_object_version_number   => l_cmpout_element_rec.object_version_number
       ,p_date_from               => l_cmpout_element_rec.date_from
       ,p_date_to                 => l_cmpout_element_rec.date_to
       ,p_effective_date          => trunc(sysdate));
     END if;*/
     --
    ELSE
       hr_utility.set_location(' Entering:' || l_proc,50);
       per_ceo_ins.ins(
        p_comp_element_outcome_id => l_cmpout_element_rec.comp_element_outcome_id
       ,p_competence_element_id   => p_competence_element_id
       ,p_object_version_number   => l_cmpout_element_rec.object_version_number
       ,p_outcome_id              => l_cmpout_element_rec.outcome_id
       ,p_date_from               => l_cmpout_element_rec.date_from
       ,p_date_to                 => l_cmpout_element_rec.date_to
       ,p_effective_date          => trunc(sysdate));
  END IF;
  END if;
  END loop;
  END if;
  --
  --
  Exception
    When hr_utility.hr_error THEN
      hr_utility.set_location(' Entering:' || l_proc,60);
      rollback to save_comp_element_outcome;
      IF NOT (l_upgraded_from_rec_id IS NOT NULL AND
         hr_message.last_message_name = 'HR_51648_CEL_PER_DATES_OVLAP') THEN
         hr_utility.set_location(' Entering:' || l_proc,70);
        raise;
      END IF;
    --
    When others THEN
      hr_utility.set_location(' Entering:' || l_proc,80);
      raise;
--
End process_api;
--
/* new Procedure for for updatng the old outcomes */
--
Procedure process_upd_api
           (p_comp_element_outcome_id   IN number
           ,p_to_date                 IN DATE
           ,p_object_version_number   IN number
           ) IS
--
   l_object_version_number  number;
   x_to_date date;
   l_proc varchar2(200) ;
begin
    l_proc := g_package || 'process_upd_api';
   hr_utility.set_location(' Entering:' || l_proc,10);
   l_object_version_number := p_object_version_number;
   IF p_to_date IS NULL then
      x_to_date := trunc(sysdate);
   else
     x_to_date := p_to_date;
   END if;
   per_ceo_del.del (
        p_comp_element_outcome_id => p_comp_element_outcome_id
       ,p_object_version_number   => l_object_version_number
 );
--
END process_upd_api;
-----------new procedure for validating and saving record into transaction tables --------------------------
------------------------------------------------------------------------------------------------------------
Procedure api_validate_com_out_rec_ss
          (p_item_type                in VARCHAR2
          ,p_item_key                 in VARCHAR2
          ,p_activity_id              in varchar2
          ,p_validate                 in varchar2
          ,p_change_mode              in varchar2 default null
          ,p_comp_element_outcome_id  in varchar2 default null
          ,p_competence_element_id    in varchar2 default null
          ,p_competence_id            in varchar2 default null
          ,p_preupd_obj_vers_num      in number default null
          ,p_outcome_id               in number default null
          ,p_date_from                in varchar2 default null
          ,p_date_to                  in varchar2 default null
          ,p_transaction_step_id      in out nocopy varchar2
          ,p_comp_from_date           IN VARCHAR2 DEFAULT null
          ,p_comp_to_date             IN VARCHAR2 DEFAULT null
          ,p_person_id                IN VARCHAR2 DEFAULT null
          ,p_error_message            out nocopy long) is
  --
  l_user_date_format           varchar2(200) default null;
  l_user_date_format_length    number default null;
  l_sample_date                varchar2(200) default null;
  l_date_char                  varchar2(200) default null;
  l_rec_changed                boolean default null;
  l_date_error                 boolean default null;
  l_msg_text                   varchar2(2000) default null;
  l_date_from                  date default null;
  l_date_to                    date default null;
  l_preupd_date_to             date default null;
  l_new_comp_ele_outcome_id    number default null;
  l_new_obj_vers_num           number default null;
  l_object_version_number      number default null;
  l_validate                   boolean  default null;
  --
  o_name                       varchar2(200) default null;
  p_outcome_name            varchar2(200) default null;
  l_prev_date                  date;
  l_prev_start_date            date;
  l_changed                    boolean default false;
  l_warning_exists             boolean default false;
  l_mode_fetch                 varchar2(20) default null;
  l_mode                       varchar2(20) default null;
  x_comp_ele_out_id            number default null;
  x_comp_ele_id                number default null;
  x_comp_id                    number default null;
  x_count                      number;
--
  Cursor get_out_dates ( p_outcome_id IN Number )is
    select date_to end_date,
           date_from start_date
    from   per_competence_outcomes_vl
    where  outcome_id = p_outcome_id;
--
  l_out_dates_cur get_out_dates%RowType;
  l_proc varchar2(200);
--
Begin
-- hr_utility.trace_on(null,'OUTCOME');
l_proc  := g_package || 'api_validate_com_out_rec_ss';
  hr_utility.set_location(' Entering:' || l_proc, 5);
  IF (p_transaction_step_id = -1 ) then
        hr_utility.set_location(' Entering:' || l_proc, 10);
    p_transaction_step_id := Null;
  ENd IF;
--
  IF p_comp_element_outcome_id  IS not null then
      hr_utility.set_location(' Entering:' || l_proc,15);
     x_comp_ele_out_Id := to_number(p_comp_element_outcome_id);
  END if;
--
  if p_competence_element_id IS not NULL then
      hr_utility.set_location(' Entering:' || l_proc,20);
     x_comp_ele_id := to_number(p_competence_element_id);
  END if;
--
  if p_competence_id IS not NULL then
      hr_utility.set_location(' Entering:' || l_proc,25);
     x_comp_id := to_number(p_competence_id);
  End if;
l_mode := p_change_mode;
  IF (p_comp_element_outcome_id is not NULL) THEN
      hr_utility.set_location(' Entering:' || l_proc,30);
      hr_comp_outcome_profile_ss.check_if_cmpocm_rec_changed
      (p_comp_element_outcome_id            => x_comp_ele_out_Id
      ,p_competence_element_id              => x_comp_ele_id
      ,p_competence_id                      => x_comp_id
      ,p_outcome_id                         => p_outcome_id
      ,p_date_from                          => to_date(p_date_from,g_date_format)
      ,p_date_to                            => to_date(p_date_to,g_date_format)
      ,p_change_mode                        => p_change_mode
      ,p_rec_changed                        => l_changed);
--
    if l_changed = false THEN
          hr_utility.set_location(' Entering:' || l_proc,35);
      IF (p_transaction_step_id IS NOT Null) THEN
          hr_utility.set_location(' Entering:' || l_proc,40);
        delete_transaction_step_id(p_transaction_step_id);
      END IF;
      return; -- added on 17-Nov-2004
    end if;
  l_mode := HR_COMP_OUTCOME_PROFILE_SS.OUTCOME_CHANGED;
--
  END IF;
--
IF ( p_date_from IS NULL OR to_date(p_date_from,g_date_format) IS null ) then
        hr_utility.set_location(' Entering:' || l_proc,45);
        p_error_message := 'HR_OUT_ELMT_DATE_INVL';
--
          RETURN;
--
END if;
    hr_utility.set_location(' Entering:' || l_proc,50);
IF ( to_date(p_date_from,g_date_format) > trunc(sysdate) ) then
        hr_utility.set_location(' Entering:' || l_proc,55);
        p_error_message := 'HR_OUT_DT_ACHVD_INVL';
--
          RETURN;
--
END if;
--
  OPEN get_out_dates(p_outcome_id => p_outcome_id);
  FETCH get_out_dates into l_out_dates_cur;
  IF get_out_dates%NOTFOUND THEN
         hr_utility.set_location(' Entering:' || l_proc,60);
     l_date_to := p_date_to;
  ELSE
         hr_utility.set_location(' Entering:' || l_proc,65);
     IF (l_out_dates_cur.start_date IS NOT NULL AND
         l_out_dates_cur.start_date > to_date(p_date_from, g_date_format) ) THEN
         hr_utility.set_location(' Entering:' || l_proc,70);
         p_error_message :=  'HR_OUT_DATE_INVL';
          CLOSE get_out_dates;
          RETURN;
      END IF;
      IF p_date_to IS NULL THEN
          hr_utility.set_location(' Entering:' || l_proc,75);
          l_date_to := l_out_dates_cur.end_date;
      ELSIF (l_out_dates_cur.end_Date IS NOT NULL AND
             l_out_dates_cur.end_date < to_date(p_date_to, g_date_format) ) THEN
           p_error_message := 'HR_OUT_DATE_INVL';
           CLOSE get_out_dates;
           RETURN;
      ELSE
          hr_utility.set_location(' Entering:' || l_proc,80);
          l_date_to := to_date(p_date_to, g_date_format);
      END IF;
  END IF ;
  IF  p_comp_from_date IS NOT NULL  then
           hr_utility.set_location(' Entering:' || l_proc,85);
      IF to_date(p_date_from,g_date_format) < to_date(p_comp_from_date,g_date_format) Then
               hr_utility.set_location(' Entering:' || l_proc,90);
           p_error_message := 'HR_OUT_ACHVD_DT_INVL';
           RETURN;
      END if;
--
  END if;
--
  IF  p_comp_to_date IS NOT NULL OR trim(p_comp_to_date) <> ''  then
         hr_utility.set_location(' Entering:' || l_proc,95);
      IF to_date(p_date_to,g_date_format) > to_date(p_comp_to_date,g_date_format) Then
               hr_utility.set_location(' Entering:' || l_proc,100);
           p_error_message :=  'HR_OUT_ACHVD_DT_INVL';
           RETURN;
      END if;
--
  END if;
--
  IF get_out_dates%ISOPEN then
  CLOSE get_out_dates;
  END if;
  hr_utility.set_location(' Entering:' || l_proc,105);
  hr_utility.set_location(' Entering x_comp_ele_id :' || x_comp_ele_id,105);
  hr_utility.set_location(' Entering p_outcome_id :' || p_outcome_id,105);
  hr_utility.set_location(' Entering  l_date_to :' || l_date_to,105);
  hr_utility.set_location(' Entering  g_date_format :' || g_date_format,105);
  hr_utility.set_location(' Entering  p_date_from:' || p_date_from,105);
  x_count :=0;
  IF x_comp_ele_out_id IS NULL then
     Select count(*) INTO x_count
       from per_comp_element_outcomes ceo
       where competence_element_id = x_comp_ele_id
             and outcome_id = p_outcome_id and
             ceo.date_from <= to_date(p_date_from,g_date_format) and
             nvl(ceo.date_to,trunc(sysdate)) >= to_date(p_date_from,g_date_format)
             AND NOT exists(
             Select 1 FROM
             hr_api_transaction_steps S, hr_api_transaction_values C
                Where  s.item_type = p_item_type
                and s.item_key = p_item_key
                and s.activity_id = nvl(to_number(p_activity_id),s.activity_id)
                and s.api_name = 'HR_COMP_OUTCOME_PROFILE_SS.DELETE'
                and c.transaction_step_id = s.transaction_step_id
                AND C.NAME = 'P_COMP_ELEMENT_OUTCOME_ID'
                AND C.NUMBER_VALUE = CEO.COMP_ELEMENT_OUTCOME_ID);
      hr_utility.set_location(' Entering x_count:' || x_count,107);
     IF x_count > 0 then
      hr_utility.set_location(' Entering:' || l_proc,107);
-- changed for 4188407
        p_error_message := 'HR_449132_QUA_FWK_OUTCM_EXISTS';
--End changes for 4188407
        return;
     END if;
    IF l_date_to IS NULL then
  Select count(*) INTO x_count
  from per_comp_element_outcomes ceo
  where competence_element_id = x_comp_ele_id
        and outcome_id = p_outcome_id and
        ceo.date_from >= to_date(p_date_from,g_date_format)
             AND NOT exists(
             Select 1 FROM
             hr_api_transaction_steps S, hr_api_transaction_values C
                Where  s.item_type = p_item_type
                and s.item_key = p_item_key
                and s.activity_id = nvl(to_number(p_activity_id),s.activity_id)
                and s.api_name = 'HR_COMP_OUTCOME_PROFILE_SS.DELETE'
                and c.transaction_step_id = s.transaction_step_id
                AND C.NAME = 'P_COMP_ELEMENT_OUTCOME_ID'
                AND C.NUMBER_VALUE = CEO.COMP_ELEMENT_OUTCOME_ID);
      hr_utility.set_location(' Entering x_count:' || x_count,108);
    else
  Select count(*) INTO x_count
  from per_comp_element_outcomes ceo
  where competence_element_id = x_comp_ele_id
        and outcome_id = p_outcome_id and
        ceo.date_from >= to_date(p_date_from,g_date_format)
        AND ceo.date_from <= to_date(p_date_to,g_date_format)
             AND NOT exists(
             Select 1 FROM
             hr_api_transaction_steps S, hr_api_transaction_values C
                Where  s.item_type = p_item_type
                and s.item_key = p_item_key
                and s.activity_id = nvl(to_number(p_activity_id),s.activity_id)
                and s.api_name = 'HR_COMP_OUTCOME_PROFILE_SS.DELETE'
                and c.transaction_step_id = s.transaction_step_id
                AND C.NAME = 'P_COMP_ELEMENT_OUTCOME_ID'
                AND C.NUMBER_VALUE = CEO.COMP_ELEMENT_OUTCOME_ID);
      hr_utility.set_location(' Entering x_count:' || x_count,109);
    END if; -- l_date_to IS NULL
    IF x_count > 0 then
     hr_utility.set_location(' Entering:' || l_proc,107);
       p_error_message := 'HR_OUT_DATE_INVL';
       return;
    END if;
END IF; -- x_comp_ele_out_id IS NULL
--
  if x_comp_ele_out_Id is not null then
          hr_utility.set_location(' Entering:' || l_proc,110);
    OPEN get_prev_start_date(x_comp_ele_out_Id);
    FETCH get_prev_start_date into l_prev_date;
--    IF get_prev_start_date%notfound THEN
--          raise hr_comp_outcome_profile_ss.g_fatal_error;
--    END IF;
    close get_prev_start_date;
    l_prev_start_date := l_prev_date;
--
end if;
if  p_transaction_step_id is not null then
         hr_utility.set_location(' Entering:' || l_proc,120);
   delete_transaction_step_id(p_transaction_step_id);
   p_transaction_step_id := null;
end if;
         hr_utility.set_location(' Entering:' || l_proc,130);
process_save(p_item_type => p_item_type
            ,p_item_key => p_item_key
            ,p_actid    => p_activity_id
            ,p_change_mode => l_mode
            ,p_comp_element_outcome_id => x_comp_ele_out_id
            ,p_competence_element_id => x_comp_ele_id
            ,p_competence_id         => x_comp_id
            ,p_preupd_obj_vers_num => p_preupd_obj_vers_num
            ,p_outcome_id => p_outcome_id
            ,p_outcome_name => p_outcome_name
            ,p_date_from => p_date_from
            ,p_date_to => to_char(l_date_to,g_date_format)
            ,p_prev_start_date => to_char(l_prev_start_date,g_date_format)
            ,p_transaction_step_id => p_transaction_step_id
            ,p_person_id           => p_person_id
           ,p_error_message     => p_error_message);
         hr_utility.set_location(' Entering:' || l_proc,140);
check_delete_rec(p_item_type => p_item_type
                ,p_item_key => p_item_key
                ,p_actid    => p_activity_id
                ,p_person_id => p_person_id
                ,p_outcome_id => p_outcome_id);
--
Exception
 when g_invalid_entry then
         hr_utility.set_location(' Entering:' || l_proc,150);
   null;
 when others then
         hr_utility.set_location(' Entering:' || l_proc,160);
   raise g_invalid_entry;
End api_validate_com_out_rec_ss;
--
-------------------------------------------------------------------------------
/*Procedure get_pending_addition_ids
          (p_item_type IN varchar2
          ,p_item_key  IN varchar2
          ,p_step_values  out nocopy varchar2
          ,p_rows         out nocopy number) is
cursor get_add_ids (p_transaction_id number) is
  select step.transaction_step_id
  from hr_api_transaction_steps step, hr_api_transaction_values val
  where step.transaction_id = p_transaction_id
    and val.transaction_step_id = step.transaction_step_id
    and val.varchar2_value = 'ADD';
l_index number;
l_transaction_id number;
begin
  l_transaction_id:=hr_transaction_ss.get_transaction_id
                      (p_item_type   =>   p_item_type
                      ,p_item_key    =>   p_item_key);
  l_index := 0;
  for l_step_values in get_add_ids(p_transaction_id => l_transaction_id) loop
    p_step_values  := p_step_values || l_step_values.transaction_step_id  || '?';
    l_index := l_index + 1;
  end loop ;
  p_rows := l_index;
end get_pending_addition_ids;
*/
--------------DELETE  PENDING CURRENT UPDATE IDS ----------------------------------------------
/*Procedure del_pen_currupd_ids(p_item_type IN varchar2
                             ,p_item_key  IN varchar2) is
cursor get_upd_ids(p_transaction_id number) is
  select steps.transaction_step_id
    from hr_api_transaction_values val, hr_api_transaction_steps steps
   where steps.transaction_id = p_transaction_id
     and steps.transaction_step_id = val.transaction_step_id
     and val.name = 'P_CHANGE_MODE'
     and val.varchar2_value  IN ('UPDATE_APPLY','UPDATE_HIST');
l_step_values   number ;
l_transaction_id number;
begin
  l_transaction_id:=hr_transaction_ss.get_transaction_id
                      (p_item_type   =>   p_item_type
                      ,p_item_key    =>   p_item_key);
  for I in get_upd_ids(l_transaction_id) loop
       delete from hr_api_transaction_values
        where transaction_step_id = I.transaction_step_id;
       delete from hr_api_transaction_steps
        where transaction_step_id = I.transaction_step_id;
  end loop;
  del_add_ids(p_item_type, p_item_key);
  commit;
end del_pen_currupd_ids; */
----------------------------------------------------------------------------------------------------
/*Procedure del_add_ids(p_item_type IN varchar2
                     ,p_item_key  IN varchar2) is
cursor get_add_ids(p_transaction_id number) is
  select steps.transaction_step_id
    from hr_api_transaction_values val, hr_api_transaction_steps steps
   where steps.transaction_id = p_transaction_id
     and steps.transaction_step_id = val.transaction_step_id
     and val.varchar2_value = 'ADD';
l_step_values   number ;
l_transaction_id number;
begin
  l_transaction_id:=hr_transaction_ss.get_transaction_id
                      (p_item_type   =>   p_item_type
                      ,p_item_key    =>   p_item_key);
  for I in get_add_ids(l_transaction_id) loop
       delete from hr_api_transaction_values
        where transaction_step_id = I.transaction_step_id;
       delete from hr_api_transaction_steps
        where transaction_id = l_transaction_id
          and transaction_step_id = I.transaction_step_id;
  end loop ;
end del_add_ids; */
/*------------------------------------------------------------------------------
|
|       Name           : save_transaction_step
|
|       Purpose        :
|
|       Saves the records into Transaction Tables.
|       Created as hr_transaction_ss.save_transaction_step fails when
|       value is passed in NULL
|
+-----------------------------------------------------------------------------*/
PROCEDURE save_transaction_step
                (p_item_type           IN VARCHAR2
                ,p_item_key            IN VARCHAR2
                ,p_actid               IN NUMBER
                ,p_login_person_id     IN NUMBER
                ,p_transaction_step_id IN OUT NOCOPY NUMBER
                ,p_api_name            IN VARCHAR2  default null
                ,p_api_display_name    IN VARCHAR2 DEFAULT NULL
                ,p_transaction_data    IN TRANSACTION_TABLE1) AS
l_count Number:=0;
  l_proc varchar2(200);
BEGIN
  l_proc  := g_package || 'save_transaction_step';
  hr_utility.set_location(' Entering:' || l_proc,10);
  l_count := p_transaction_data.COUNT;
  FOR i IN 1..l_count LOOP
    BEGIN
        IF p_transaction_data(i).param_data_type = 'DATE' THEN
             hr_transaction_api.set_date_value(p_transaction_step_id => p_transaction_step_id
                        ,p_person_id => p_login_person_id
                        ,p_name  => p_transaction_data(i).param_name
                        ,p_value => to_date(ltrim(rtrim(p_transaction_data(i).param_value)),g_date_format));
        ELSIF p_transaction_data(i).param_data_type = 'NUMBER' THEN
                            hr_transaction_api.set_number_value(p_transaction_step_id => p_transaction_step_id
                            ,p_person_id => p_login_person_id
                            ,p_name => p_transaction_data(i).param_name
                            ,p_value => to_number(ltrim(rtrim(p_transaction_data(i).param_value))));
        ELSIF p_transaction_data(i).param_data_type = 'VARCHAR2' THEN
                        hr_transaction_api.set_varchar2_value(p_transaction_step_id => p_transaction_step_id
                        ,p_person_id => p_login_person_id
                        ,p_name => p_transaction_data(i).param_name
                        ,p_value => p_transaction_data(i).param_value);
        END IF;
--
   Exception When others then
   hr_utility.set_location(' Entering:' || l_proc,100);
    RAISE hr_utility.hr_error;
   END;
  END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
    hr_utility.set_location(' Entering:' || l_proc,110);
         hr_utility.trace('EXCEPTION SAVE_TRANSACTION_STEP'||'STS#');
      raise hr_utility.hr_error;
END save_transaction_step;
--
-----------------------------------
PROCEDURE delete_all_ids
          (p_item_type in varchar2
          ,p_item_key  in varchar2) is
cursor get_all_ids (p_transaction_id number) is
 select transaction_step_id
   from hr_api_transaction_steps
  where transaction_id = p_transaction_id;
--
l_result           number ;
l_transaction_id   number ;
begin
--
  l_transaction_id:=hr_transaction_ss.get_transaction_id
                      (p_item_type   =>   p_item_type
                      ,p_item_key    =>   p_item_key);
--
  for l_result in get_all_ids(p_transaction_id => l_transaction_id) loop
       delete from hr_api_transaction_values
        where transaction_step_id = l_result.transaction_step_id;
--
       delete from hr_api_transaction_steps
        where transaction_id = l_transaction_id
          and transaction_step_id = l_result.transaction_step_id;
  end loop ;
  commit;
--
end delete_all_ids;
--
------------------------------------------------
PROCEDURE delete_transaction_step_id
          (p_transaction_step_id IN number) is
l_transaction_step_id  number;
l_txid                 number;
--
l_mode                      varchar2(20) default null;
l_comp_element_outcome_id     number default null;
l_transaction_id number;
CURSOR get_txn_step_id IS  select transaction_id
    from hr_api_transaction_steps
    where transaction_step_id = p_transaction_step_id
    and rownum = 1;
BEGIN
    l_transaction_step_id := p_transaction_step_id;
--
    FOR rec IN  get_txn_step_id
    loop
        delete from hr_api_transaction_values where transaction_step_id = l_transaction_step_id ;
        delete from hr_api_transaction_steps  where transaction_step_id = l_transaction_step_id ;
    END loop;
--
END delete_transaction_step_id;
--
----------------------------------------------------------------------------
---------------------------------------------------
-- for saving fields from the update details page to tx tables
procedure save_update_details
          (p_item_type                  in varchar2
          ,p_item_key                   in varchar2
          ,p_activity_id                in varchar2
          ,p_outcome_id                 in number
          ,p_competence_element_id      in number default null
          ,p_comp_element_outcome_id    in number default null
          ,p_date_from                  in varchar2 default null
          ,p_date_to                    in varchar2 default null
          ,p_preupd_obj_vers_num        in number default null
          ,p_transaction_step_id        in number
          ,p_prev_date_from         in varchar2 default null
          ,p_pre_date_to            in varchar2 default null
          ,p_person_id              IN VARCHAR2 DEFAULT null
          ,p_error_message              out nocopy long) is
--
--
l_user_date_format      varchar2(20) ;
l_date_from         date default null;
l_date_to           date default null;
l_prev_date             date;
l_prev_start_date       date;
l_date_error            boolean default null;
l_transaction_step_id   number;
--
--------------
l_object_version_number      number default null;
l_trans_tbl                  hr_comp_outcome_profile_ss.transaction_table1;
l_count                      number default 0;
l_action_person_id           number default null;
l_proc varchar2(200) ;
-------------
begin
    l_proc := g_package || 'save_update_details';
    hr_utility.set_location(' Entering:' || l_proc,10);
    l_user_date_format      := g_date_format;
    l_transaction_step_id   := p_transaction_step_id;
--
    OPEN get_prev_start_date(p_comp_element_outcome_id => p_comp_element_outcome_id);
        FETCH get_prev_start_date into l_prev_date;
        IF get_prev_start_date%notfound THEN
            hr_utility.set_location(' Entering:' || l_proc,20);
            close get_out_name;
            raise hr_comp_outcome_profile_ss.g_fatal_error;
        ELSE
        hr_utility.set_location(' Entering:' || l_proc,30);
          CLOSE get_prev_start_date;
        END IF;
--
    l_prev_start_date := l_prev_date;
--
hr_utility.set_location(' Entering:' || l_proc,40);
api_validate_compout_record
          (p_validate                  => true
          ,p_competence_element_id     => p_competence_element_id
          ,p_outcome_id                => p_outcome_id
          ,p_change_mode               => 'UPGRADE'
          ,p_comp_element_outcome_id   => p_comp_element_outcome_id
          ,p_preupd_obj_vers_num       => p_preupd_obj_vers_num
          ,p_date_from                 => p_date_from
          ,p_date_to                   => p_date_to
          ,p_date_from_date_type       => l_date_from
          ,p_date_to_date_type         => l_date_to
          ,p_person_id                 => p_person_id
          ,p_error_message             => p_error_message);
--
    IF p_error_message is not null then
    hr_utility.set_location(' Entering:' || l_proc,50);
        Return;
    END IF;
hr_utility.set_location(' Entering:' || l_proc,60);
     --
     l_count := l_count + 1;
     l_trans_tbl(l_count).param_name := 'P_PREV_START_DATE';
     l_trans_tbl(l_count).param_value := to_char(l_prev_start_date,g_date_format);
     l_trans_tbl(l_count).param_data_type := 'DATE';
--
     l_count := l_count + 1;
     l_trans_tbl(l_count).param_name := 'P_DATE_FROM';
     l_trans_tbl(l_count).param_value := p_date_from;
     l_trans_tbl(l_count).param_data_type := 'DATE';
     --
     l_count := l_count + 1;
     l_trans_tbl(l_count).param_name := 'P_DATE_TO';
     l_trans_tbl(l_count).param_value := p_date_to;
     l_trans_tbl(l_count).param_data_type := 'DATE';
     --
--
-- added for comp Qual enhancement RPahune
     l_count := l_count + 1;
     l_trans_tbl(l_count).param_name := 'P_COMPETENCE_ELEMENT_ID';
     l_trans_tbl(l_count).param_value := p_competence_element_id;
     l_trans_tbl(l_count).param_data_type := 'NUMBER';
--
     l_count := l_count + 1;
     l_trans_tbl(l_count).param_name := 'P_COMP_ELEMENT_OUTCOME_ID';
     l_trans_tbl(l_count).param_value := p_comp_element_outcome_id;
     l_trans_tbl(l_count).param_data_type := 'NUMBER';
--
     l_count := l_count + 1;
     l_trans_tbl(l_count).param_name := 'P_OUTCOME_ID';
     l_trans_tbl(l_count).param_value := p_outcome_id;
     l_trans_tbl(l_count).param_data_type := 'NUMBER';
--
-- End add
hr_utility.set_location(' Entering:' || l_proc,70);
     save_transaction_step
        (p_item_type      => p_item_type
        ,p_item_key       => p_item_key
        ,p_actid          => to_number(p_activity_id)
        ,p_login_person_id => fnd_global.employee_id
        ,p_transaction_step_id => l_transaction_step_id
        ,p_transaction_data    => l_trans_tbl);
------------------
EXCEPTION
    when g_invalid_entry then
    hr_utility.set_location(' Entering:' || l_proc,80);
         raise g_invalid_entry;
--
    when others then
    hr_utility.set_location(' Entering:' || l_proc,90);
        raise  g_invalid_entry;
--
end save_update_details;
--
--------------------------------------------------------------------
--
------------------------------------------------
Procedure delete_add_page
          (p_transaction_step_id in number) is
--
CURSOR get_step_ids (txn_step_id IN number) is
   Select outcome.transaction_step_id
      FROM hr_api_transaction_steps outcome,
          hr_api_transaction_values ocomp,
          hr_api_transaction_values operson,
          hr_api_transaction_values ofrom_dt,
          hr_api_transaction_values oto_dt,
          hr_api_transaction_steps competence,
          hr_api_transaction_values ccomp,
          hr_api_transaction_values cperson,
          hr_api_transaction_values cfrom_dt,
          hr_api_transaction_values cto_dt
Where competence.transaction_step_id = txn_step_id
      AND ccomp.transaction_step_id = competence.transaction_step_id
      AND cperson.transaction_step_id = competence.transaction_step_id
      AND cfrom_dt.transaction_step_id = competence.transaction_step_id
      AND cto_dt.transaction_step_id = competence.transaction_step_id
      AND ccomp.NAME = 'P_COMPETENCE_ID'
      AND cperson.NAME = 'P_PERSON_ID'
      AND cfrom_dt.NAME = 'P_EFF_DATE_FROM'
      AND cto_dt.NAME = 'P_EFF_DATE_TO'
      And outcome.item_key = competence.item_key
      And outcome.item_type = competence.item_type
      And outcome.activity_id = competence.activity_id
      And outcome.api_name = HR_COMP_OUTCOME_PROFILE_SS.g_api_name
      AND ocomp.transaction_step_id = competence.transaction_step_id
      AND operson.transaction_step_id = competence.transaction_step_id
      AND ofrom_dt.transaction_step_id = competence.transaction_step_id
      AND oto_dt.transaction_step_id = competence.transaction_step_id
      AND ocomp.NAME = 'P_COMPETENCE_ID'
      AND operson.NAME = 'P_PERSON_ID'
      AND ofrom_dt.NAME = 'P_EFF_DATE_FROM'
      AND oto_dt.NAME = 'P_EFF_DATE_TO'
      And ocomp.number_value = ccomp.number_value
      And operson.number_value = cperson.number_value
      AND ofrom_dt.date_value >= cfrom_dt.date_value
      AND nvl(oto_dt.date_value,trunc(sysdate)) <= nvl(cto_dt.date_value,trunc(sysdate));
--
  l_proc varchar2(200);
begin
--
l_proc  := g_package || 'delete_add_page';
hr_utility.set_location(' Entering:' || l_proc,10);
FOR txnStepIds IN get_step_ids(p_transaction_step_id) loop
--
--
  delete from hr_api_transaction_values where transaction_step_id = txnStepIds.transaction_step_id;
  delete from hr_api_transaction_steps where transaction_step_id = txnStepIds.transaction_step_id;
end loop;
--
commit;
--
end delete_add_page;
---------------------------------------------------------------
--
--
--
--====================================================================================
Procedure api_validate_compout_record(
           p_validate                  in boolean default null
          ,p_competence_element_id     in NUMBER DEFAULT null
          ,p_competence_id             IN NUMBER DEFAULT null
          ,p_outcome_id                in number default null
          ,p_change_mode               in varchar2 default null
          ,p_comp_element_outcome_id   in number default null
          ,p_preupd_obj_vers_num       in number default null
          ,p_date_from                 in varchar2 default null
          ,p_date_to                   in varchar2 default null
          ,p_date_from_date_type      out nocopy date
          ,p_date_to_date_type        out nocopy date
          ,p_person_id                IN number
          ,p_error_message                out nocopy long) is
--
  l_user_date_format             varchar2(200);
  l_date_error                   boolean default false;
  l_date_from                    date default null;
  l_date_to                      date default null;
  l_new_comp_element_outcome_id  number default null;
  l_new_obj_vers_num             number default null;
  l_object_version_number        number default null;
  l_proc varchar2(200);
  --
Begin
--
l_proc  := g_package || 'api_validate_compout_record';
l_user_date_format :=g_date_format;
 Begin
hr_utility.set_location(' Entering:' || l_proc,10);
    IF p_date_from is not null THEN
    hr_utility.set_location(' Entering:' || l_proc,20);
       l_date_from := to_date(p_date_from, l_user_date_format);
    END IF;
---
    IF l_date_from > trunc(sysdate) THEN
    hr_utility.set_location(' Entering:' || l_proc,30);
          p_error_message := 'HR_WEB_DISALLOW_FUTURE_STARTDT';
          l_date_error := true;
    END IF;
--
    EXCEPTION
      When others then
          hr_utility.set_location(' Entering:' || l_proc,40);
          p_error_message := hr_java_conv_util_ss.get_formatted_error_message
                             (p_error_message => p_error_message,
                              p_attr_name     => 'DateFrom',
                              p_app_short_name => 'PER',
                              P_SINGLE_ERROR_MESSAGE  => SQLERRM ||' '||to_char(SQLCODE));
          l_date_error := true;
  END;
--
  Begin
--
    IF p_date_to is not null THEN
        hr_utility.set_location(' Entering:' || l_proc,50);
       l_date_to := to_date(p_date_to, l_user_date_format);
    END IF;
--
    IF l_date_from is not null then
        hr_utility.set_location(' Entering:' || l_proc,60);
       IF l_date_to < l_date_from THEN
           hr_utility.set_location(' Entering:' || l_proc,70);
          p_error_message :=  'HR_WEB_CEL_DATES_INVL';
          l_date_error := true;
       END IF;
    End IF;
--
    EXCEPTION
      When others then
          hr_utility.set_location(' Entering:' || l_proc,80);
         p_error_message := hr_java_conv_util_ss.get_formatted_error_message
                            (p_error_message => p_error_message,
                             p_attr_name     => 'EndDate',
                             p_app_short_name => 'PER',
                             P_SINGLE_ERROR_MESSAGE      => SQLERRM ||' '||to_char(SQLCODE));
         l_date_error := true;
  END;
--
  --
  --------------------------------------------------------------------
  -- Now, if no date format error, we proceed to call api for cross
  -- validations.
  --------------------------------------------------------------------
--
  savepoint validate_output_rec;
--
   IF l_date_error THEN
       hr_utility.set_location(' Entering:' || l_proc,90);
     goto finish_processing;
   END IF;
  --
 -- UPGRADE
IF p_comp_element_outcome_id IS NOT null THEN
    hr_utility.set_location(' Entering:' || l_proc,100);
      l_object_version_number := p_preupd_obj_vers_num;
      per_ceo_upd.upd(p_comp_element_outcome_id  => p_comp_element_outcome_id
                    ,p_competence_element_id    => p_competence_element_id
                    ,p_outcome_id               => p_outcome_id
                    ,p_object_version_number    => l_object_version_number
                    ,p_date_from                => l_date_from
                    ,p_date_to                  => l_date_to
                    ,p_effective_date           => trunc(sysdate));
--
ELSE -- Add New Record Mode
    hr_utility.set_location(' Entering:' || l_proc,110);
     per_ceo_ins.ins(p_comp_element_outcome_id  => l_new_comp_element_outcome_id
                    ,p_competence_element_id    => p_competence_element_id
                    ,p_object_version_number    => l_new_obj_vers_num
                    ,p_outcome_id               => p_outcome_id
                    ,p_date_from                => l_date_from
                    ,p_date_to                  => l_date_to
                    ,p_effective_date         => trunc(sysdate));
  END IF;
  --
  IF p_validate = true THEN
      hr_utility.set_location(' Entering:' || l_proc,120);
     rollback to validate_output_rec;
  END IF;
  --
  --
  <<finish_processing>>
  --
  if l_date_error then
      hr_utility.set_location(' Entering:' || l_proc,130);
    rollback to validate_output_rec;
  end if;
--
  p_date_from_date_type  := l_date_from;
  p_date_to_date_type    := l_date_to;
  --
  EXCEPTION
    When g_invalid_entry then
        hr_utility.set_location(' Entering:' || l_proc,140);
         rollback to validate_output_rec;
    When others then
    hr_utility.set_location(' Entering:' || l_proc,150);
      rollback to validate_output_rec;
--
End api_validate_compout_record;
--
-- ------------------------------------------------------------------------
-- ---------------------<check_if_cmpocm_rec_changed>---------------------
-- ------------------------------------------------------------------------
-- Purpose: This procedure will compare the values of the rec with the
--          values before update.
--          The caller has made sure that this procedure is called only on an
--          IF the from date/ date to is changed, it
--          will set an output parm to true if the p_change_mode is
-- ------------------------------------------------------------------------
Procedure check_if_cmpocm_rec_changed (
           p_comp_element_outcome_id   in number
          ,p_competence_element_id      in number default null
          ,p_competence_id              in number default null
          ,p_outcome_id                 in number
          ,p_date_from                  in date default null
          ,p_date_to                    in date default null
          ,p_change_mode                in varchar2
          ,p_ignore_warning             in varchar2 default null
          ,p_rec_changed                out nocopy boolean)  is
--
 --
  cursor csr_get_preupd_cmpocm_rec is
  SELECT comp_element_outcome_id
        ,competence_element_id
        ,outcome_id
        ,date_from
        ,date_to
  from  per_comp_element_outcomes
  where comp_element_outcome_id = p_comp_element_outcome_id;
  --
  l_changed             boolean default null;
    l_proc varchar2(200);
  --
  --
Begin
  l_proc  := g_package || 'check_if_cmpocm_rec_changed';
  hr_utility.set_location(' Entering:' || l_proc,10);
  l_changed := false;
--
  --
  FOR l_preupd_rec IN csr_get_preupd_cmpocm_rec LOOP
  hr_utility.set_location(' Entering:' || l_proc || ' in loop for ',20);
      IF l_preupd_rec.outcome_id = p_outcome_id AND l_preupd_rec.competence_element_id = p_competence_element_id THEN
         null;
      ELSE
         raise hr_comp_outcome_profile_ss.g_fatal_error;
      END IF;
      --
--
      IF l_preupd_rec.date_from is not null THEN
         IF l_preupd_rec.date_from = p_date_from THEN
            null;
         ELSE
            l_changed := true;
         END IF;
      ELSE  -- pre-update is null
         IF p_date_from is not null THEN
            l_changed := true;
         END IF;
      END IF;
      --
      IF l_preupd_rec.date_to is not null THEN
         ---------------------------------------------------------------------
         -- Only issue a warning if the new eff_date_to is different and is
         -- not null.
         ---------------------------------------------------------------------
         IF l_preupd_rec.date_to = p_date_to THEN
            null;
         ELSE
            l_changed := true;
            --
         END IF;
      ELSE  -- pre-update is null
         IF p_date_to is not null THEN
            l_changed := true;
            --
         END IF;
      END IF;
      --
--
   END LOOP;
     hr_utility.set_location(' Entering:' || l_proc || ' out of loop ',90);
   --
   p_rec_changed := l_changed;
--   p_warning_exists := l_warning_exists;
   --
   Exception
     When others then
  hr_utility.set_location(' Entering:' || l_proc ,100);
       raise;
   --
End check_if_cmpocm_rec_changed;
----------------
----------------
PROCEDURE mark_for_delete
          (p_item_type                in varchar2
          ,p_item_key                  in varchar2
          ,p_activity_id              in varchar2
          ,p_comp_element_outcome_id  in number
          ,p_transaction_step_id      in varchar2 default null
          ,p_error_message            OUT nocopy long ) IS
l_transaction_id NUMBER DEFAULT null;
x_trans_ovn      NUMBER DEFAULT null;
l_count          number;
l_trans_tbl      transaction_table1;
l_result         varchar2(100);
l_transaction_step_id Number DEFAULT null;
l_proc varchar2(200);
begin
  l_proc  := g_package || 'mark_for_delete';
  hr_utility.set_location(' Entering:' || l_proc ,10);
    l_transaction_id := hr_transaction_ss.get_transaction_id(p_item_type   => p_item_type
                                                            ,p_item_key    => p_item_key);
--
    IF l_transaction_id is null THEN
    hr_utility.set_location(' Entering:' || l_proc ,20);
       -- Start a Transaction
        hr_transaction_ss.start_transaction
           (itemtype   => p_item_type
           ,itemkey    => p_item_key
           ,actid      => to_number(p_activity_id)
           ,funmode    => 'RUN'
           ,p_login_person_id => fnd_global.employee_id
           ,result     => l_result);
hr_utility.set_location(' Entering:' || l_proc ,30);
        l_transaction_id := hr_transaction_ss.get_transaction_id
            (p_item_type   => p_item_type
                ,p_item_key    => p_item_key);
    END IF;
        If p_transaction_step_id is NULL OR p_transaction_step_id = '-1' then
        hr_utility.set_location(' Entering:' || l_proc ,40);
                hr_transaction_api.create_transaction_step
                      (p_validate => false
                  ,p_creator_person_id => fnd_global.employee_id
                  ,p_transaction_id => l_transaction_id
                  ,p_api_name => 'HR_COMP_OUTCOME_PROFILE_SS.DELETE'
                  ,p_item_type => p_item_type
                  ,p_item_key => p_item_key
                      ,p_activity_id => p_activity_id
                      ,p_transaction_step_id => l_transaction_step_id
                  ,p_object_version_number => x_trans_ovn);
         else
         hr_utility.set_location(' Entering:' || l_proc ,50);
             l_transaction_step_id := p_transaction_step_id;
    End if;
hr_utility.set_location(' Entering:' || l_proc ,60);
        l_count := 1;
        l_trans_tbl(l_count).param_name := 'P_COMP_ELEMENT_OUTCOME_ID';
        l_trans_tbl(l_count).param_value := p_comp_element_outcome_id;
        l_trans_tbl(l_count).param_data_type := 'NUMBER';
save_transaction_step(p_item_type => p_item_type
                    ,p_item_key => p_item_key
                ,p_actid => p_activity_id
                ,p_login_person_id => fnd_global.employee_id
                ,p_transaction_step_id => l_transaction_step_id
                ,p_api_name => 'HR_COMP_OUTCOME_PROFILE_SS.DELETE'
                ,p_transaction_data => l_trans_tbl);
END mark_for_delete;
----------------------
---------------------
----------------------
PROCEDURE check_delete_rec
                ( p_item_type IN varchar2
                ,p_item_key IN varchar2
                ,p_actid    IN varchar2
                ,p_person_id IN number
                ,p_outcome_id IN number) IS
l_txn_step_id   hr_api_transaction_steps.transaction_step_id%type;
l_proc varchar2(200);
begin
l_proc  := g_package || 'check_delete_rec';
hr_utility.set_location(' Entering:' || l_proc ,10);
SELECT s.transaction_step_id INTO l_txn_step_id
       FROM hr_api_transaction_steps S,
            hr_api_transaction_values C,
            per_comp_element_outcomes ceo,
            per_competence_elements pce
                   Where  s.item_type = p_item_type
     and s.item_key = p_item_key
     and s.activity_id = nvl((p_actid),s.activity_id)
     and s.api_name = 'HR_COMP_OUTCOME_PROFILE_SS.DELETE'
          and c.transaction_step_id = s.transaction_step_id
          AND C.NAME = 'P_COMP_ELEMENT_OUTCOME_ID'
          AND ceo.outcome_id = p_outcome_id
          AND ceo.Competence_Element_id = pce.competence_element_id
          AND pce.PERSON_ID = p_person_id
          AND ceo.comp_element_outcome_id = C.number_value;
IF l_txn_step_id IS NOT NULL then
hr_utility.set_location(' Entering:' || l_proc ,20);
delete_transaction_step_id(l_txn_step_id);
END if;
--
  EXCEPTION
    When NO_DATA_FOUND then
    hr_utility.set_location(' Entering:' || l_proc ,30);
      null;
    When OTHERS then
    hr_utility.set_location(' Entering:' || l_proc ,40);
    raise;
/**
--
*/
--
End check_delete_rec;
-- Added on 17-Nov-2004
Procedure check_if_cmptnce_rec_changed
          (p_item_type             IN varchar2
          ,p_item_key              IN varchar2
          ,p_activity_id           IN varchar2
          ,p_pid                   in number
          ,p_competence_element_id in number
          ,p_competence_id         in number
          ,p_rec_changed           out nocopy boolean) is
l_count   number;
l_proc varchar2(200);
Begin
p_rec_changed := false;
l_proc := g_package || 'check_if_cmptnce_rec_changed';
hr_utility.set_location(' Entering:' || l_proc ,10);
hr_utility.set_location(' Entering p_item_type :' || p_item_type ,10);
hr_utility.set_location(' Entering p_item_key :' || p_item_key ,10);
hr_utility.set_location(' Entering p_activity_id :' || p_activity_id ,10);
hr_utility.set_location(' Entering p_pid :' || p_pid ,10);
hr_utility.set_location(' Entering p_competence_element_id :' || p_competence_element_id ,10);
hr_utility.set_location(' Entering p_competence_id :' || p_competence_id ,10);
Select Count(*) INTO l_count
  FROM hr_api_transaction_steps s, per_competence_outcomes_vl co,
      hr_api_transaction_values a, hr_api_transaction_values b,
      hr_api_transaction_values c, hr_api_transaction_values p
      Where  s.item_type = p_item_type
     and s.item_key = p_item_key
     and s.activity_id = nvl(p_activity_id,s.activity_id)
     and s.api_name = 'HR_COMP_OUTCOME_PROFILE_SS.PROCESS_API'
     and c.transaction_step_id = s.transaction_step_id
     AND CO.COMPETENCE_ID =p_competence_id
     AND co.date_from <= trunc(sysdate)
     AND nvl(co.date_to,trunc(sysdate)) >= trunc(sysdate)
     AND b.date_value >= co.date_from
     AND nvl(c.date_Value,trunc(sysdate)) <= nvl(co.date_to, nvl(c.date_Value,trunc(sysdate)))
and a.name = 'P_OUTCOME_ID'
and a.transaction_step_id = s.transaction_step_id
and a.number_value= co.outcome_id
and b.name = 'P_DATE_FROM'
and b.transaction_step_id = s.transaction_step_id
and c.name = 'P_DATE_TO'
and p.transaction_step_id = s.transaction_step_id
and p.name = 'P_PERSON_ID'
and p.Number_Value = p_pid;
IF l_count > 0 then
hr_utility.set_location(' Entering:' || l_proc ,20);
  p_rec_changed := true;
END if;
hr_utility.set_location(' Entering:' || l_proc ,30);
SELECT COUNT(*) INTO l_count
       FROM hr_api_transaction_steps S,
            hr_api_transaction_values C,
            per_comp_element_outcomes ceo
     Where  s.item_type = p_item_type
     and s.item_key = p_item_key
     and s.activity_id = nvl((p_activity_id),s.activity_id)
     and s.api_name = 'HR_COMP_OUTCOME_PROFILE_SS.DELETE'
          and c.transaction_step_id = s.transaction_step_id
          AND C.NAME = 'P_COMP_ELEMENT_OUTCOME_ID'
          AND ceo.Competence_Element_id = p_competence_element_id
          AND ceo.comp_element_outcome_id = C.number_value;
IF l_count > 0 then
hr_utility.set_location(' Entering:' || l_proc ,40);
  p_rec_changed := true;
END if;
--
  EXCEPTION
    When OTHERS then
    hr_utility.set_location(' Entering:' || l_proc ,50);
    raise;
END check_if_cmptnce_rec_changed;
Procedure delete(p_validate            in boolean default false
                     ,p_transaction_step_id in number
                     ,p_effective_date        in varchar2 default null) is
begin
null;
end;
--
--
Procedure process_api(
           p_validate              in boolean  default false
          ,p_transaction_step_id   in number
          ,p_effective_date        in varchar2 default null) IS
begin
null;
end;

Procedure del_correct_rec(
           p_item_type             IN varchar2
          ,p_item_key              IN varchar2
          ,p_activity_id           IN varchar2
          ,p_competence_element_id in number) is

CURSOR get_del_tsid is
     Select DISTINCT s.transaction_step_id
     FROM hr_api_transaction_steps S,
          hr_api_transaction_values C,
          per_comp_element_outcomes ceo
     Where  s.item_type = p_item_type
     and s.item_key = p_item_key
     and s.activity_id = nvl((p_activity_id),s.activity_id)
     and s.api_name = 'HR_COMP_OUTCOME_PROFILE_SS.DELETE'
          and c.transaction_step_id = s.transaction_step_id
          AND C.NAME = 'P_COMP_ELEMENT_OUTCOME_ID'
          AND c.number_value = ceo.comp_element_outcome_id
          AND ceo.competence_element_id = p_competence_element_id;

Cursor get_comp_sid is
   Select DISTINCT s.transaction_step_id
     FROM hr_api_transaction_steps S,
          hr_api_transaction_values C
     Where s.item_type = p_item_type
     and s.item_key = p_item_key
     and s.activity_id = nvl((p_activity_id),s.activity_id)
     and s.api_name = 'HR_COMP_PROFILE_SS.PROCESS_API'
     AND c.transaction_step_id = s.transaction_step_id
     AND c.NAME = 'P_COMPETENCE_ELEMENT_ID'
     AND c.number_value = p_competence_element_id;

 Cursor get_out_sid is
   Select DISTINCT s.transaction_step_id
     FROM hr_api_transaction_steps S,
          hr_api_transaction_values C
     Where s.item_type = p_item_type
     and s.item_key = p_item_key
     and s.activity_id = nvl((p_activity_id),s.activity_id)
     and s.api_name = 'HR_COMP_OUTCOME_PROFILE_SS.PROCESS_API'
     AND c.transaction_step_id = s.transaction_step_id
     AND c.NAME = 'P_COMPETENCE_ELEMENT_ID'
     AND c.number_value = p_competence_element_id;
begin
FOR sid_cur IN get_del_tsid
loop
delete_transaction_step_id(sid_cur.transaction_step_id);
END loop;

FOR sid_comp_cur IN get_comp_sid
loop
delete_transaction_step_id(sid_comp_cur.transaction_step_id);
END loop;
FOR sid_out_cur IN get_out_sid
loop
delete_transaction_step_id(sid_out_cur.transaction_step_id);
END loop;
end;
End hr_comp_outcome_profile_ss;

/
