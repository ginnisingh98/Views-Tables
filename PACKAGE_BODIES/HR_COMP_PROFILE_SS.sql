--------------------------------------------------------
--  DDL for Package Body HR_COMP_PROFILE_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_COMP_PROFILE_SS" AS
/* $Header: hrcprwrs.pkb 120.2.12010000.4 2008/10/08 09:14:52 psugumar ship $ */
--
-- Private globals
  g_package            varchar2(30) := 'HR_COMP_PROFILE_SS';
  g_person_id          per_all_people_f.person_id%type;
  g_business_group_id  per_all_people_f.business_group_id%type;
  g_language_code      varchar2(5) default null;
  g_invalid_entry      exception;
  g_invalid_competence exception;
  --
  cursor g_csr_get_preupd_cmptnce_rec(p_competence_element_id  in number) is
  select cvl.name
        ,cmpe.competence_element_id
        ,cmpe.object_version_number
        ,cmpe.competence_id
        ,cmpe.proficiency_level_id
        ,ratl.step_value
        ,cmpe.effective_date_from
        ,cmpe.effective_date_to
        ,cmpe.certification_date
        ,cmpe.certification_method
        ,hr_general.decode_lookup ('CERTIFICATION_METHOD' ,cmpe.certification_method)  certification_method_desc
        ,cmpe.next_certification_date
        ,cmpe.source_of_proficiency_level
        ,hr_general.decode_lookup ('PROFICIENCY_SOURCE' ,cmpe.source_of_proficiency_level) src_proficiency_lvl_desc
        ,cmpe.comments
        ,cvl.competence_alias
        ,cmpe.status  -- added for Competnce Qualification link enahncement
  from   per_rating_levels  ratl
        ,per_competence_elements  cmpe
        ,per_competences_vl  cvl
  where  cmpe.competence_element_id = p_competence_element_id
  and    cmpe.competence_id = cvl.competence_id
  and    cmpe.proficiency_level_id = ratl.rating_level_id (+)
  and    trunc(sysdate) between nvl(cmpe.effective_date_from, trunc(sysdate))
         and nvl(cmpe.effective_date_to, trunc(sysdate));
 cursor get_curr_step_value(p_proficiency_level_id in number) is
 select step_value from per_rating_levels
 where rating_level_id = p_proficiency_level_id;
 cursor get_previous_step_value(p_competence_element_id in number) is
    select a.step_value
    from per_rating_levels a,per_competence_elements b
    where b.proficiency_level_id = a.rating_level_id(+)
    and b.competence_element_id = p_competence_element_id;
 cursor get_prev_prof_lvl_id(p_competence_element_id in number) is
     select proficiency_level_id
     from per_competence_elements
     where competence_element_id = p_competence_element_id;
 cursor get_comp_name(p_competence_id in number) is
     select name
     from per_competences_vl
     where competence_id = p_competence_id;
 cursor get_prev_start_date(p_competence_element_id in number) is
     select effective_date_from
     from per_competence_elements
     where competence_element_id = p_competence_element_id;
 cursor get_comp_alias(p_competence_id in number) is
     select competence_alias
     from per_competences_vl
     where competence_id = p_competence_id;
 cursor get_mode(p_transaction_step_id in number) is
    select varchar2_value
    from hr_api_transaction_values
    where transaction_step_id = p_transaction_step_id and name = 'P_CHANGE_MODE';
CURSOR get_prev_status(p_competence_element_id IN number) is
    SELECT status
    FROM per_competence_elements
    WHERE competence_element_id = p_competence_element_id;
--
-- ------------------------------------------------------------------------
-- ---------------------<api_validate_competence_record>-------------------
-- ------------------------------------------------------------------------
-- Purpose: This private signature will validate data entered by calling api's
--
Procedure api_validate_competence_record
          (p_validate              in boolean default null
          ,p_person_id             in number
          ,p_business_group_id     in number default null
          ,p_change_mode           in varchar2 default null
          ,p_competence_element_id in number default null
          ,p_preupd_obj_vers_num   in number default null
          ,p_competence_id         in number default null
          ,p_proficiency_level_id  in number default null
          ,p_eff_date_from         in varchar2 default null
          ,p_eff_date_to           in varchar2 default null
          ,p_proficy_lvl_source    in varchar2 default null
          ,p_certification_mthd    in varchar2 default null
          ,p_certification_date    in varchar2 default null
          ,p_next_certifctn_date   in varchar2 default null
          ,p_competence_status     IN VARCHAR2 DEFAULT NULL -- Competence Qualification Link Enh.
          ,p_eff_date_from_date_type  out nocopy date
          ,p_eff_date_to_date_type    out nocopy date
          ,p_certifctn_date_type      out nocopy date
          ,p_next_certifctn_date_type out nocopy date
          ,p_error_message            out nocopy long);
--
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
--          It will also check for any outcome changes are there.
-- ------------------------------------------------------------------------
Procedure check_if_cmptnce_rec_changed
          (p_competence_element_id   in number
          ,p_competence_id           in number
          ,p_proficiency_level_id    in number default null
          ,p_eff_date_from           in date default null
          ,p_eff_date_to             in date default null
          ,p_proficy_lvl_source      in varchar2 default null
          ,p_certification_mthd      in varchar2 default null
          ,p_certification_date      in date default null
          ,p_next_certifctn_date     in date default null
          ,p_change_mode             in varchar2
          ,p_ignore_warning          in varchar2 default null
          ,p_comments                in varchar2 default null
          ,p_competence_status       in varchar2 default NULL -- Competence Qualification link
          ,p_rec_changed             out nocopy boolean);
-- ---------------------------------------------------------------------------
-- ---------------------------- < writeTo_transTbl > -----------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This private procedure to write into trans table
--          the transaction step is created if one doesn't exits
-- ---------------------------------------------------------------------------
Procedure writeTo_transTbl(p_item_type IN wf_items.item_type%type
                  ,p_item_key IN wf_items.item_key%type
                  ,p_actid IN Number
                  ,p_login_person_id IN Number
                  ,p_trans_id IN Number
                  ,p_trans_step_id IN OUT NOCOPY Number
                  ,p_api_name IN Varchar2
                  ,p_person_id IN Number Default Null
                  ,p_business_group_id IN Number Default Null
                  ,p_comp_element_id IN Number Default Null
                  ,p_ovn IN Number Default Null
                  ,p_eff_date_from IN Varchar2 Default Null
                  ,p_eff_date_to IN Varchar2 Default Null
                  ,p_comp_id IN Number Default Null
                  ,p_comp_name IN Varchar2 Default Null
                  ,p_comp_alias IN Varchar2 Default Null
                  ,p_profy_level_id IN Number Default Null
                  ,p_profy_level_source IN Varchar2 Default Null
                  ,p_step_value IN Number Default Null
                  ,p_comments IN Varchar2 Default Null
                  ,p_cert_date IN Varchar2 Default Null
                  ,p_cert_method IN Varchar2 Default Null
                  ,p_next_cert_date IN Varchar2 Default Null
                  ,p_prev_start_date IN Varchar2 Default Null
                  ,p_prev_step_value IN Number Default Null
                  ,p_prev_profy_level_id IN Number Default Null
                  ,p_change_mode IN Varchar2 Default Null
                  ,p_status      IN VARCHAR2 DEFAULT NULL -- added for competence Qualification
                  ,p_prev_status IN VARCHAR2 DEFAULT NULL -- added for competence Qualification
                  ,p_sys_generated IN Varchar2 Default 'N'
                  ,p_upg_from_rec_id IN Number Default -1) is
l_proc varchar2(200) := g_package || 'writeTo_transTbl';
l_trans_tbl transaction_table1;
l_count Number:=0;
x_trans_ovn Number;
l_review_region Varchar2(200);
Begin
        hr_utility.set_location(' Entering:' || l_proc,5);
        If p_trans_step_id is null then
                hr_utility.set_location(l_proc,10);
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
    End if;
        hr_utility.set_location(l_proc,15);
        l_count := 1;
        l_trans_tbl(l_count).param_name := 'P_PERSON_ID';
        l_trans_tbl(l_count).param_value := p_person_id;
        l_trans_tbl(l_count).param_data_type := 'NUMBER';
        l_count := l_count + 1;
        l_trans_tbl(l_count).param_name := 'P_BUSINESS_GROUP_ID';
        l_trans_tbl(l_count).param_value := p_business_group_id;
        l_trans_tbl(l_count).param_data_type := 'NUMBER';
        l_count := l_count + 1;
        l_trans_tbl(l_count).param_name := 'P_COMPETENCE_ELEMENT_ID';
        l_trans_tbl(l_count).param_value := p_comp_element_id;
        l_trans_tbl(l_count).param_data_type := 'NUMBER';
        l_count := l_count + 1;
        l_trans_tbl(l_count).param_name := 'P_OBJECT_VERSION_NUMBER';
        l_trans_tbl(l_count).param_value := p_ovn;
        l_trans_tbl(l_count).param_data_type := 'NUMBER';
        l_count := l_count + 1;
        l_trans_tbl(l_count).param_name := 'P_EFF_DATE_FROM';
        l_trans_tbl(l_count).param_value := p_eff_date_from;
        l_trans_tbl(l_count).param_data_type := 'DATE';
        l_count := l_count + 1;
        l_trans_tbl(l_count).param_name := 'P_COMPETENCE_ID';
        l_trans_tbl(l_count).param_value := p_comp_id;
        l_trans_tbl(l_count).param_data_type := 'NUMBER';
        l_count := l_count + 1;
        l_trans_tbl(l_count).param_name := 'P_COMPETENCE_NAME';
        l_trans_tbl(l_count).param_value := p_comp_name;
        l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
        l_count := l_count + 1;
        l_trans_tbl(l_count).param_name := 'P_COMPETENCE_ALIAS';
        l_trans_tbl(l_count).param_value := p_comp_alias;
        l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
        l_count := l_count + 1;
        l_trans_tbl(l_count).param_name := 'P_PROFICIENCY_LEVEL_ID';
        l_trans_tbl(l_count).param_value := p_profy_level_id;
        l_trans_tbl(l_count).param_data_type := 'NUMBER';
        l_count := l_count + 1;
        l_trans_tbl(l_count).param_name := 'P_PROFICY_LVL_SOURCE';
        l_trans_tbl(l_count).param_value := p_profy_level_source;
        l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
        l_count := l_count + 1;
        l_trans_tbl(l_count).param_name := 'P_STEP_VALUE';
        l_trans_tbl(l_count).param_value := p_step_value;
        l_trans_tbl(l_count).param_data_type := 'NUMBER';
        l_count := l_count + 1;
        l_trans_tbl(l_count).param_name := 'P_EFF_DATE_TO';
        l_trans_tbl(l_count).param_value := p_eff_date_to;
        l_trans_tbl(l_count).param_data_type := 'DATE';
        l_count := l_count + 1;
        l_trans_tbl(l_count).param_name := 'P_COMMENTS';
        l_trans_tbl(l_count).param_value := p_comments;
        l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
        l_count := l_count + 1;
        l_trans_tbl(l_count).param_name := 'P_CERTIFICATION_DATE';
        l_trans_tbl(l_count).param_value := p_cert_date;
        l_trans_tbl(l_count).param_data_type := 'DATE';
        l_count := l_count + 1;
        l_trans_tbl(l_count).param_name := 'P_CERTIFICATION_MTHD';
        l_trans_tbl(l_count).param_value := p_cert_method;
        l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
        l_count := l_count + 1;
        l_trans_tbl(l_count).param_name := 'P_NEXT_CERTIFCTN_DATE';
        l_trans_tbl(l_count).param_value := p_next_cert_date;
        l_trans_tbl(l_count).param_data_type := 'DATE';
        l_count := l_count + 1;
        l_trans_tbl(l_count).param_name := 'P_PREV_START_DATE';
        l_trans_tbl(l_count).param_value := p_prev_start_date;
        l_trans_tbl(l_count).param_data_type := 'DATE';
        l_count := l_count + 1;
        l_trans_tbl(l_count).param_name := 'P_PREV_STEP_VALUE';
        l_trans_tbl(l_count).param_value := p_prev_step_value;
        l_trans_tbl(l_count).param_data_type := 'NUMBER';
        l_count := l_count + 1;
        l_trans_tbl(l_count).param_name := 'P_PREUPD_PROFICY_LVL_ID';
        l_trans_tbl(l_count).param_value := p_prev_profy_level_id;
        l_trans_tbl(l_count).param_data_type := 'NUMBER';
        l_count := l_count + 1;
        l_trans_tbl(l_count).param_name := 'P_CHANGE_MODE';
        l_trans_tbl(l_count).param_value := p_change_mode;
        l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
        l_count := l_count + 1;
        l_trans_tbl(l_count).param_name := 'P_SYSTEM_GENERATED';
        l_trans_tbl(l_count).param_value := p_sys_generated;
        l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
   If p_upg_from_rec_id <> -1 then
        hr_utility.set_location(l_proc,20);
        l_count := l_count + 1;
        l_trans_tbl(l_count).param_name := 'P_UPGRADED_FROM_REC_ID';
        l_trans_tbl(l_count).param_value := p_upg_from_rec_id;
        l_trans_tbl(l_count).param_data_type := 'NUMBER';
   End if;
    hr_utility.set_location(l_proc,25);
    l_count := l_count + 1;
        l_trans_tbl(l_count).param_name := 'P_REVIEW_ACTID';
        l_trans_tbl(l_count).param_value := p_actid;
        l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
/* start code for competence Qualification link enhancement */
    hr_utility.set_location(l_proc,26);
    l_count := l_count + 1;
        l_trans_tbl(l_count).param_name := 'P_STATUS';
        l_trans_tbl(l_count).param_value := p_status;
        l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
    hr_utility.set_location(l_proc,27);
    l_count := l_count + 1;
        l_trans_tbl(l_count).param_name := 'P_PREV_STATUS';
        l_trans_tbl(l_count).param_value := p_prev_status;
        l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
/* end code for competence Qualification link enhancement */
      l_review_region := wf_engine.GetActivityAttrText
                                            (itemtype => p_item_type
                                            ,itemkey => p_item_key
                                            ,actid   => p_actid
                                            ,aname   => 'HR_REVIEW_REGION_ITEM'
                                            ,ignore_notfound => true);
        hr_utility.set_location(l_proc,30);
    l_count := l_count + 1;
        l_trans_tbl(l_count).param_name := 'P_REVIEW_PROC_CALL';
        l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
        l_trans_tbl(l_count).param_value := l_review_region;
        save_transaction_step(p_item_type => p_item_type
                    ,p_item_key => p_item_key
                ,p_actid => p_actid
                ,p_login_person_id => p_login_person_id
                ,p_transaction_step_id => p_trans_step_id
                ,p_api_name => p_api_name
                ,p_transaction_data => l_trans_tbl);
       hr_utility.set_location(' Leaving:' || l_proc,35);
End writeTo_transTbl;
-- ***** Start new code for bug 2743410 **************
-- ---------------------------------------------------------------------------
-- ---------------------------- < comp_not_exists > --------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This function is being used for filtering current session changes
--          and pending approval changes
-- ---------------------------------------------------------------------------
Function comp_not_exists
    (p_item_type in varchar2
    ,p_item_key in varchar2
    ,p_person_id in number
    ,p_competence_id in number
    ) Return varchar2 is
l_proc varchar2(200) := g_package || 'comp_not_exists';
l_retStatus varchar2(1) := 'T';
cursor c1 is
    select 'F' status
    from hr_api_transaction_steps s, hr_api_transaction_values a,
         hr_api_transaction_values b
    Where s.item_type = p_item_type
    and s.item_key  = p_item_key
    and s.transaction_step_id = a.transaction_step_id
    and s.transaction_step_id = b.transaction_step_id
    and a.name = 'P_COMPETENCE_ID' and a.number_value = p_competence_id
    and b.name = 'P_PERSON_ID' and b.number_value = p_person_id
    union
    select 'F' status from hr_api_transaction_steps ts, hr_api_transactions t
    where ts.api_name = 'HR_COMP_PROFILE_SS.PROCESS_API'
    and ts.transaction_id = t.transaction_id
    and t.selected_person_id = p_person_id and t.status = 'Y'
    and exists (Select 'e' From hr_api_transaction_values c
                Where c.transaction_step_id = ts.transaction_step_id
                and c.name = 'P_COMPETENCE_ID'
                and c.number_value = p_competence_id);
begin
    hr_utility.set_location(' Entering:' || l_proc,5);
    For I in c1 Loop
       hr_utility.set_location( l_proc,10);
       If (I.status = 'F') then
            l_retStatus := I.status;
            hr_utility.set_location(' Leaving:' || l_proc,15);
            Exit;
       End If;
    End Loop;
    hr_utility.set_location(' Leaving:' || l_proc,20);
    return l_retStatus;
    Exception when others then
        hr_utility.set_location(' Leaving:' || l_proc,555);
        return 'T';
end comp_not_exists;
-- ***** End new code for bug 2743410 **************
-- ---------------------------------------------------------------------------
-- ---------------------------- < process_save > -----------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This private procedure saves the competence profile record either to the
--          database or to the transaction table depending on the workflow
--          setting.
-- ---------------------------------------------------------------------------
Procedure process_save
          (p_item_type              in wf_items.item_type%type
          ,p_item_key               in wf_items.item_key%type
          ,p_actid                  in varchar2
          ,p_person_id              in number
          ,p_change_mode            in varchar2  default null
          ,p_competence_element_id  in number default null
          ,p_preupd_obj_vers_num    in number default null
          ,p_competence_id          in number default null
          ,p_competence_name        in varchar2 default null
          ,p_competence_alias       in varchar2 default null
          ,p_proficiency_level_id   in number default null
          ,p_step_value             in number default null
          ,p_preupd_proficy_lvl_id  in number default null
          ,p_certification_mthd     in varchar2 default null
          ,p_proficy_lvl_source     in varchar2 default null
          ,p_eff_date_from          in varchar2 default null
          ,p_eff_date_to            in varchar2 default null
          ,p_certification_date     in varchar2 default null
          ,p_next_certifctn_date    in varchar2 default null
          ,p_comments               in varchar2 default null
          ,p_prev_step_value        in number   default null
          ,p_prev_start_date        in varchar2 default null
          ,p_ignore_warning         in varchar2 default null
          ,p_competence_status      IN VARCHAR2 DEFAULT NULL --Competence Qualification link
          ,p_transaction_step_id    in out nocopy number
          ,p_error_message          out nocopy long) is
  --
  l_proc varchar2(200) := g_package || 'process_save';
  l_transaction_id             number default null;
  l_transaction_step_id             number default null;
  l_result                     varchar2(100) default null;
  l_user_date_format           varchar2(200) default null;
  x_eff_date_from              date default null;
  x_eff_date_to                date default null;
  x_certification_date         date default null;
  x_next_certifctn_date        date default null;
  l_preupd_cmptnce_row         g_csr_get_preupd_cmptnce_rec%rowtype;
-- when upgraded record updated from current session changes
  l_eff_date_from       date default null;
  l_competence_element_id   number default null;
  l_obj_ver_num     number default null;
  l_mode_value      varchar2(20) default null;
----------------------------------
Begin
    hr_utility.set_location(' Entering:' || l_proc,5);
    l_user_date_format := g_date_format ;
    g_business_group_id := hr_util_misc_web.get_business_group_id(p_person_id    => p_person_id);
    l_mode_value := p_change_mode;
    l_eff_date_from := to_date(p_eff_date_from,l_user_date_format);
    l_competence_element_id := p_competence_element_id;
    l_obj_ver_num := p_preupd_obj_vers_num;
    if p_transaction_step_id is not null then
        hr_utility.set_location(l_proc,10);
        select varchar2_value into l_mode_value
        from hr_api_transaction_values
        where transaction_step_id = p_transaction_step_id and name = 'P_CHANGE_MODE';
    end if;
    hr_utility.set_location(l_proc,15);
    If l_mode_value = 'UPGRADE' and p_transaction_step_id is not null then
            hr_utility.set_location(l_proc,20);
            select max(effective_date_from)
            into l_eff_date_from
            from per_competence_elements
            where person_id = to_number(p_person_id)
            and competence_id = p_competence_id group by competence_id;
            select competence_element_id, object_version_number
              into l_competence_element_id, l_obj_ver_num
            from per_competence_elements
            where person_id = to_number(p_person_id)
            and effective_date_from = l_eff_date_from
            and competence_id = p_competence_id;
    End If;
        hr_utility.set_location(l_proc,25);
        api_validate_competence_record
         (p_validate               => true
         ,p_person_id              => p_person_id
         ,p_business_group_id      => g_business_group_id
         ,p_change_mode            => l_mode_value
         ,p_competence_element_id  => l_competence_element_id
         ,p_preupd_obj_vers_num    => l_obj_ver_num
         ,p_competence_id          => p_competence_id
         ,p_proficiency_level_id   => p_proficiency_level_id
         ,p_eff_date_from          => p_eff_date_from
         ,p_eff_date_to            => p_eff_date_to
         ,p_proficy_lvl_source     => p_proficy_lvl_source
         ,p_certification_mthd     => p_certification_mthd
         ,p_certification_date     => p_certification_date
         ,p_next_certifctn_date    => p_next_certifctn_date
         ,p_competence_status      => p_competence_status
         ,p_eff_date_from_date_type  => x_eff_date_from
         ,p_eff_date_to_date_type    => x_eff_date_to
         ,p_certifctn_date_type      => x_certification_date
         ,p_next_certifctn_date_type => x_next_certifctn_date
         ,p_error_message            => p_error_message);
        hr_utility.set_location(l_proc,30);
        if p_error_message is not null then
            hr_utility.set_location(' Leaving:' || l_proc,35);
            Return;
        end if;
        hr_utility.set_location(l_proc,40);
    l_transaction_id := hr_transaction_ss.get_transaction_id(p_item_type   => p_item_type
                                                            ,p_item_key    => p_item_key);
    IF l_transaction_id is null THEN
       hr_utility.set_location(l_proc,45);
       -- Start a Transaction
        hr_transaction_ss.start_transaction
           (itemtype   => p_item_type
           ,itemkey    => p_item_key
           ,actid      => to_number(p_actid)
           ,funmode    => 'RUN'
           ,p_login_person_id => fnd_global.employee_id
           ,result     => l_result);
        l_transaction_id := hr_transaction_ss.get_transaction_id
            (p_item_type   => p_item_type
                ,p_item_key    => p_item_key);
    END IF;
    hr_utility.set_location(l_proc,50);
    IF p_change_mode = 'UPGRADE' THEN
        hr_utility.set_location(l_proc,55);
        open g_csr_get_preupd_cmptnce_rec(p_competence_element_id);
        Fetch g_csr_get_preupd_cmptnce_rec into l_preupd_cmptnce_row;
        IF g_csr_get_preupd_cmptnce_rec%notfound THEN
            close g_csr_get_preupd_cmptnce_rec;
            raise hr_comp_profile_ss.g_fatal_error;
        END IF;
       hr_utility.set_location(l_proc,60);
        close g_csr_get_preupd_cmptnce_rec;
        writeTo_transTbl(p_item_type => p_item_type
                        ,p_item_key => p_item_key
                        ,p_actid => to_number(p_actid)
                        ,p_login_person_id => fnd_global.employee_id
                        ,p_trans_id => l_transaction_id
                        ,p_trans_step_id => p_transaction_step_id
                        ,p_api_name => g_api_name
                        ,p_person_id => p_person_id
                        ,p_business_group_id => g_business_group_id
                        ,p_comp_element_id => p_competence_element_id
                        ,p_ovn => l_preupd_cmptnce_row.object_version_number
                        ,p_eff_date_from => to_char(l_preupd_cmptnce_row.effective_date_from,l_user_date_format)
                        ,p_eff_date_to => to_char(x_eff_date_from-1,l_user_date_format)
                        ,p_comp_id => l_preupd_cmptnce_row.competence_id
                        ,p_comp_name => l_preupd_cmptnce_row.name
                        ,p_comp_alias => l_preupd_cmptnce_row.competence_alias
                        ,p_profy_level_id => l_preupd_cmptnce_row.proficiency_level_id
                        ,p_profy_level_source => l_preupd_cmptnce_row.source_of_proficiency_level
                        ,p_step_value => l_preupd_cmptnce_row.step_value
                        ,p_comments => l_preupd_cmptnce_row.comments
                        ,p_cert_date => to_char(l_preupd_cmptnce_row.certification_date,l_user_date_format)
                        ,p_cert_method => l_preupd_cmptnce_row.certification_method
                        ,p_next_cert_date => to_char(l_preupd_cmptnce_row.next_certification_date,l_user_date_format)
                        ,p_prev_start_date => Null
                        ,p_prev_step_value => Null
                        ,p_prev_profy_level_id => Null
                        ,p_change_mode => p_change_mode
                        ,p_sys_generated => 'Y'
                        ,p_upg_from_rec_id => -1
                        ,p_prev_status          => l_preupd_cmptnce_row.status
                        ,p_status               => p_competence_status);
        l_transaction_step_id := Null;
        hr_utility.set_location(l_proc,65);
        writeTo_transTbl(p_item_type => p_item_type
                        ,p_item_key => p_item_key
                        ,p_actid => to_number(p_actid)
                        ,p_login_person_id => fnd_global.employee_id
                        ,p_trans_id => l_transaction_id
                        ,p_trans_step_id => l_transaction_step_id
                        ,p_api_name => g_api_name
                        ,p_person_id => p_person_id
                        ,p_business_group_id => g_business_group_id
                        ,p_comp_element_id => Null
                        ,p_ovn => Null
                        ,p_eff_date_from => p_eff_date_from
                        ,p_eff_date_to => p_eff_date_to
                        ,p_comp_id => p_competence_id
                        ,p_comp_name => p_competence_name
                        ,p_comp_alias => p_competence_alias
                        ,p_profy_level_id => p_proficiency_level_id
                        ,p_profy_level_source => p_proficy_lvl_source
                        ,p_step_value => p_step_value
                        ,p_comments => p_comments
                        ,p_cert_date => p_certification_date
                        ,p_cert_method => p_certification_mthd
                        ,p_next_cert_date => p_next_certifctn_date
                        ,p_prev_start_date => Null
                        ,p_prev_step_value => Null
                        ,p_prev_profy_level_id => p_preupd_proficy_lvl_id
                        ,p_change_mode => p_change_mode
                        ,p_sys_generated => 'N'
                        ,p_upg_from_rec_id => p_competence_element_id
                        ,p_prev_status     => null
                        ,p_status          => p_competence_status);
    ELSIF p_change_mode = hr_comp_profile_ss.g_upd_mode THEN
        hr_utility.set_location(l_proc,70);
        writeTo_transTbl(p_item_type => p_item_type
                        ,p_item_key => p_item_key
                        ,p_actid => to_number(p_actid)
                        ,p_login_person_id => fnd_global.employee_id
                        ,p_trans_id => l_transaction_id
                        ,p_trans_step_id => p_transaction_step_id
                        ,p_api_name => g_api_name
                        ,p_person_id => p_person_id
                        ,p_business_group_id => g_business_group_id
                        ,p_comp_element_id => p_competence_element_id
                        ,p_ovn => p_preupd_obj_vers_num
                        ,p_eff_date_from => p_eff_date_from
                        ,p_eff_date_to => p_eff_date_to
                        ,p_comp_id => p_competence_id
                        ,p_comp_name => p_competence_name
                        ,p_comp_alias => p_competence_alias
                        ,p_profy_level_id => p_proficiency_level_id
                        ,p_profy_level_source => p_proficy_lvl_source
                        ,p_step_value => p_step_value
                        ,p_comments => p_comments
                        ,p_cert_date => p_certification_date
                        ,p_cert_method => p_certification_mthd
                        ,p_next_cert_date => p_next_certifctn_date
                        ,p_prev_start_date => p_prev_start_date
                        ,p_prev_step_value => p_prev_step_value
                        ,p_prev_profy_level_id => p_preupd_proficy_lvl_id
                        ,p_change_mode => l_mode_value
                        ,p_sys_generated => 'N'
                        ,p_upg_from_rec_id => -1
                        ,p_status          => p_competence_status);
           if l_mode_value = 'UPGRADE' then
                hr_utility.set_location(l_proc,75);
                select number_value
                into l_competence_element_id
                from hr_api_transaction_values
                where transaction_step_id = p_transaction_step_id
                and NAME = 'P_UPGRADED_FROM_REC_ID';
                select a.transaction_step_id
                into l_transaction_step_id
                from hr_api_transaction_values a,
                     hr_api_transaction_values b,
                     hr_api_transaction_steps steps
                where steps.transaction_id = l_transaction_id
                and steps.transaction_step_id = a.transaction_step_id
                and a.name = 'P_CHANGE_MODE'
                and a.varchar2_value = 'UPGRADE'
                and steps.transaction_step_id = b.transaction_step_id
                and b.name = 'P_COMPETENCE_ELEMENT_ID'
                and b.number_value = l_competence_element_id
                and a.transaction_step_id <> l_competence_element_id;
                update hr_api_transaction_values
                set date_value = (x_eff_date_from - 1)
                where transaction_step_id = l_transaction_step_id
                and name = 'P_EFF_DATE_TO';
            end if;
            hr_utility.set_location(l_proc,80);
    ELSIF p_change_mode = 'UPDATE_UPDATE' THEN
        hr_utility.set_location(l_proc,85);
        writeTo_transTbl(p_item_type => p_item_type
                        ,p_item_key => p_item_key
                        ,p_actid => to_number(p_actid)
                        ,p_login_person_id => fnd_global.employee_id
                        ,p_trans_id => l_transaction_id
                        ,p_trans_step_id => p_transaction_step_id
                        ,p_api_name => g_api_name
                        ,p_person_id => p_person_id
                        ,p_business_group_id => g_business_group_id
                        ,p_comp_element_id => p_competence_element_id
                        ,p_ovn => p_preupd_obj_vers_num
                        ,p_eff_date_from => p_eff_date_from
                        ,p_eff_date_to => p_eff_date_to
                        ,p_comp_id => p_competence_id
                        ,p_comp_name => p_competence_name
                        ,p_comp_alias => p_competence_alias
                        ,p_profy_level_id => p_proficiency_level_id
                        ,p_profy_level_source => p_proficy_lvl_source
                        ,p_step_value => p_step_value
                        ,p_comments => p_comments
                        ,p_cert_date => p_certification_date
                        ,p_cert_method => p_certification_mthd
                        ,p_next_cert_date => p_next_certifctn_date
                        ,p_prev_start_date => p_prev_start_date
                        ,p_prev_step_value => p_prev_step_value
                        ,p_prev_profy_level_id => Null
                        ,p_change_mode => 'UPDATE_APPLY'
                        ,p_sys_generated => 'N'
                        ,p_upg_from_rec_id => -1
                        ,p_status          => p_competence_status);
    ELSE
                 hr_utility.set_location(l_proc,90);
                 writeTo_transTbl(p_item_type => p_item_type
                        ,p_item_key => p_item_key
                        ,p_actid => to_number(p_actid)
                        ,p_login_person_id => fnd_global.employee_id
                        ,p_trans_id => l_transaction_id
                        ,p_trans_step_id => p_transaction_step_id
                        ,p_api_name => g_api_name
                        ,p_person_id => p_person_id
                        ,p_business_group_id => g_business_group_id
                        ,p_comp_element_id => Null
                        ,p_ovn => Null
                        ,p_eff_date_from => p_eff_date_from
                        ,p_eff_date_to => p_eff_date_to
                        ,p_comp_id => p_competence_id
                        ,p_comp_name => p_competence_name
                        ,p_comp_alias => p_competence_alias
                        ,p_profy_level_id => p_proficiency_level_id
                        ,p_profy_level_source => p_proficy_lvl_source
                        ,p_step_value => p_step_value
                        ,p_comments => p_comments
                        ,p_cert_date => p_certification_date
                        ,p_cert_method => p_certification_mthd
                        ,p_next_cert_date => p_next_certifctn_date
                        ,p_prev_start_date => p_prev_start_date
                        ,p_prev_step_value => p_prev_step_value
                        ,p_prev_profy_level_id => Null
                        ,p_change_mode => p_change_mode
                        ,p_sys_generated => 'N'
                        ,p_upg_from_rec_id => -1
                        ,p_status          => p_competence_status);
  END IF;
  hr_utility.set_location(' Leaving:' || l_proc,95);
  EXCEPTION
    When g_invalid_entry then
      hr_utility.set_location(' Leaving:' || l_proc,555);
      raise g_invalid_entry;
    WHEN hr_comp_profile_ss.g_data_err THEN
     hr_utility.set_location(' Leaving:' || l_proc,560);
      raise hr_utility.hr_error;
    WHEN hr_comp_profile_ss.g_access_violation_err THEN
      hr_utility.set_location(' Leaving:' || l_proc,565);
      raise hr_utility.hr_error;
    When others THEN
      hr_utility.set_location(' Leaving:' || l_proc,570);
      raise g_invalid_entry ;
End process_save;
--
-- ---------------------------------------------------------------------------
Procedure process_save_currentupdate
          (p_item_type              in wf_items.item_type%type
          ,p_item_key               in wf_items.item_key%type
          ,p_actid                  in varchar2
          ,p_person_id              in number
          ,p_change_mode            in varchar2  default null
          ,p_preupd_obj_vers_num    in number default null
          ,p_competence_id          in number default null
          ,p_competence_element_id  in number default null
          ,p_competence_name        in varchar2 default null
          ,p_competence_alias       in varchar2 default null
          ,p_proficiency_level_id   in number default null
          ,p_step_value             in number default null
          ,p_preupd_proficy_lvl_id  in number default null
          ,p_certification_mthd     in varchar2 default null
          ,p_proficy_lvl_source     in varchar2 default null
          ,p_eff_date_from          in varchar2 default null
          ,p_eff_date_to            in varchar2 default null
          ,p_certification_date     in varchar2 default null
          ,p_next_certifctn_date    in varchar2 default null
          ,p_comments               in varchar2 default null
          ,p_prev_step_value        in number   default null
          ,p_prev_start_date        in varchar2 default null
          ,p_competence_status      IN VARCHAR2 DEFAULT null
          ,transaction_step_id      in number default null) is
  --
  l_proc varchar2(200) := g_package || 'process_save_currentupdate';
  l_new_competence_element_id  number default null;
  l_new_obj_vers_num           number default null;
  l_object_version_number      number default null;
  --
  l_line_manager_mode          boolean default null;
  l_wf_update_mode             varchar2(100) default null;
  l_date_to                    date  default null;
  l_transaction_id             number default null;
  l_transaction_step_id        number default null;
  l_trans_obj_vers_num         number default null;
  l_result                     varchar2(100) default null;
  l_trans_tbl                  hr_comp_profile_ss.transaction_table1;
  l_user_date_format           varchar2(200) default null;
  l_preupd_date_to             date default null;
  l_eff_date_from              date default null;
  l_eff_date_to                date default null;
  l_certification_date         date default null;
  l_next_certifctn_date        date default null;
  l_count                      number default 0;
  l_preupd_cmptnce_row         g_csr_get_preupd_cmptnce_rec%rowtype;
  l_action_person_id           number default null;
  --
  l_prev_step_val           number default null;
  l_prev_date               date;
  l_prev_start_date         date;
  l_preupd_proficy_lvl_id   number := null;
  l_prev_step_value         number := null;
---
Begin
  hr_utility.set_location(' Entering:' || l_proc,5);
  if (p_preupd_proficy_lvl_id <> -1) then
    hr_utility.set_location(l_proc,10);
    l_preupd_proficy_lvl_id := p_preupd_proficy_lvl_id;
  end if;
  hr_utility.set_location(l_proc,15);
  if (p_prev_step_value <> -1) then
    hr_utility.set_location(l_proc,20);
    l_prev_step_value := p_prev_step_value;
  end if;
  hr_utility.set_location(l_proc,25);
  l_action_person_id := p_person_id;
  g_business_group_id := hr_util_misc_web.get_business_group_id
                         (p_person_id    => l_action_person_id);
  --
  l_user_date_format := g_date_format;
   OPEN get_prev_start_date(p_competence_element_id);
        FETCH get_prev_start_date into l_prev_date;
         IF get_prev_start_date%notfound THEN
               hr_utility.set_location(l_proc,30);
               close get_comp_name;
               raise hr_comp_profile_ss.g_fatal_error;
         END IF;
       close get_prev_start_date;
  l_prev_start_date := l_prev_date;
    hr_utility.set_location(l_proc,35);
    IF p_eff_date_from is not null THEN
       hr_utility.set_location(l_proc,40);
       l_eff_date_from := to_date(p_eff_date_from, l_user_date_format);
    END IF;
    IF p_eff_date_to is not null THEN
       hr_utility.set_location(l_proc,45);
       l_eff_date_to := to_date(p_eff_date_to, l_user_date_format);
    END IF;
    IF p_certification_date is not null THEN
       hr_utility.set_location(l_proc,50);
       l_certification_date := to_date(p_certification_date, l_user_date_format);
    END IF;
    IF p_next_certifctn_date is not null THEN
       hr_utility.set_location(l_proc,55);
       l_next_certifctn_date := to_date(p_next_certifctn_date, l_user_date_format);
    END IF;
   hr_utility.set_location(l_proc,60);
   l_transaction_id := hr_transaction_ss.get_transaction_id
                     (p_item_type   => p_item_type
                     ,p_item_key    => p_item_key);
   IF l_transaction_id is null THEN
     hr_utility.set_location(l_proc,65);
     hr_transaction_ss.start_transaction
           (itemtype   => p_item_type
           ,itemkey    => p_item_key
           ,actid      => to_number(p_actid)
           ,funmode    => 'RUN'
           ,p_login_person_id => fnd_global.employee_id
           ,result     => l_result);
           l_transaction_id := hr_transaction_ss.get_transaction_id
                        (p_item_type   => p_item_type
                ,p_item_key    => p_item_key);
   END IF;
  --
   IF transaction_step_id is null then
    hr_utility.set_location(l_proc,70);
    hr_transaction_api.create_transaction_step
     (p_validate              => false
     ,p_creator_person_id     => fnd_global.employee_id
     ,p_transaction_id        => l_transaction_id
     ,p_api_name              => g_api_name
     ,p_item_type             => p_item_type
     ,p_item_key              => p_item_key
     ,p_activity_id           => to_number(p_actid)
     ,p_transaction_step_id   => l_transaction_step_id
     ,p_object_version_number => l_trans_obj_vers_num);
    else
      l_transaction_step_id := transaction_step_id;
    end if;
  --
  IF p_change_mode = 'UPDATE_APPLY' THEN
     hr_utility.set_location(l_proc,75);
     Open g_csr_get_preupd_cmptnce_rec
                    (p_competence_element_id);
     Fetch g_csr_get_preupd_cmptnce_rec into l_preupd_cmptnce_row;
     IF g_csr_get_preupd_cmptnce_rec%notfound THEN
        hr_utility.set_location(l_proc,80);
        close g_csr_get_preupd_cmptnce_rec;
        raise hr_comp_profile_ss.g_fatal_error;
     END IF;
     --
     close g_csr_get_preupd_cmptnce_rec;
     hr_utility.set_location(l_proc,85);
     l_preupd_date_to := l_eff_date_from - 1;
     writeTo_transTbl(p_item_type => p_item_type
                   ,p_item_key => p_item_key
                   ,p_actid => to_number(p_actid)
                   ,p_login_person_id => fnd_global.employee_id
                   ,p_trans_id => l_transaction_id
                   ,p_trans_step_id => l_transaction_step_id
                   ,p_api_name => g_api_name
                   ,p_person_id => p_person_id
                   ,p_business_group_id => g_business_group_id
                   ,p_comp_element_id => p_competence_element_id
                   ,p_ovn => l_preupd_cmptnce_row.object_version_number
                   ,p_eff_date_from => to_char(l_preupd_cmptnce_row.effective_date_from,g_date_format)
                   ,p_eff_date_to => to_char(l_preupd_date_to,g_date_format)
                   ,p_comp_id => l_preupd_cmptnce_row.competence_id
                   ,p_comp_name => l_preupd_cmptnce_row.name
                   ,p_comp_alias => l_preupd_cmptnce_row.competence_alias
                   ,p_profy_level_id => l_preupd_cmptnce_row.proficiency_level_id
                   ,p_profy_level_source => l_preupd_cmptnce_row.source_of_proficiency_level
                   ,p_step_value => l_preupd_cmptnce_row.step_value
                   ,p_comments => l_preupd_cmptnce_row.comments
                   ,p_cert_date => to_char(l_preupd_cmptnce_row.certification_date,g_date_format)
                   ,p_cert_method => l_preupd_cmptnce_row.certification_method
                   ,p_next_cert_date => to_char(l_preupd_cmptnce_row.next_certification_date,g_date_format)
                   ,p_prev_start_date => null
                   ,p_prev_step_value => null
                   ,p_prev_profy_level_id => Null
                   ,p_change_mode => 'UPDATE_HIST'
                   ,p_sys_generated => 'Y'
                   ,p_upg_from_rec_id => -1
                   ,p_prev_status     => l_preupd_cmptnce_row.status
                   ,p_status          => p_competence_status);
     hr_utility.set_location(l_proc,90);
     hr_transaction_api.create_transaction_step
     (p_validate              => false
     ,p_creator_person_id     => fnd_global.employee_id
     ,p_transaction_id        => l_transaction_id
     ,p_api_name              => g_api_name
     ,p_item_type             => p_item_type
     ,p_item_key              => p_item_key
     ,p_activity_id           => to_number(p_actid)
     ,p_transaction_step_id   => l_transaction_step_id
     ,p_object_version_number => l_trans_obj_vers_num);
     writeTo_transTbl(p_item_type => p_item_type
                  ,p_item_key => p_item_key
                  ,p_actid => to_number(p_actid)
                  ,p_login_person_id => fnd_global.employee_id
                  ,p_trans_id => l_transaction_id
                  ,p_trans_step_id => l_transaction_step_id
                  ,p_api_name => g_api_name
                  ,p_person_id => p_person_id
                  ,p_business_group_id => g_business_group_id
                  ,p_comp_element_id => p_competence_element_id
                  ,p_ovn => Null
                  ,p_eff_date_from => p_eff_date_from
                  ,p_eff_date_to => p_eff_date_to
                  ,p_comp_id => p_competence_id
                  ,p_comp_name => l_preupd_cmptnce_row.name
                  ,p_comp_alias => l_preupd_cmptnce_row.competence_alias
                  ,p_profy_level_id => l_PREUPD_PROFICY_LVL_ID
                  ,p_profy_level_source => p_proficy_lvl_source
                  ,p_step_value => p_step_value
                  ,p_comments => p_comments
                  ,p_cert_date => p_certification_date
                  ,p_cert_method => p_certification_mthd
                  ,p_next_cert_date => p_next_certifctn_date
                  ,p_prev_start_date => to_char(l_prev_start_date,g_date_format)
                  ,p_prev_step_value => l_prev_step_value
                  ,p_prev_profy_level_id => null
                  ,p_change_mode => 'UPDATE_APPLY'
                  ,p_sys_generated => 'N'
                  ,p_upg_from_rec_id => p_competence_element_id
                  ,p_status          => p_competence_status);
  ELSIF p_change_mode = 'UPDATE_UPDATE' THEN
      hr_utility.set_location(l_proc,95);
      writeTo_transTbl(p_item_type => p_item_type
                   ,p_item_key => p_item_key
                   ,p_actid => to_number(p_actid)
                   ,p_login_person_id => fnd_global.employee_id
                   ,p_trans_id => l_transaction_id
                   ,p_trans_step_id => l_transaction_step_id
                   ,p_api_name => g_api_name
                   ,p_person_id => p_person_id
                   ,p_business_group_id => g_business_group_id
                   ,p_comp_element_id => p_competence_element_id
                   ,p_ovn => p_preupd_obj_vers_num
                   ,p_eff_date_from => to_char(l_eff_date_from, g_date_format)
                   ,p_eff_date_to => to_char(l_eff_date_to, g_date_format)
                   ,p_comp_id => p_competence_id
                   ,p_comp_name => p_competence_name
                   ,p_comp_alias => p_competence_alias
                   ,p_profy_level_id => p_proficiency_level_id
                   ,p_profy_level_source => p_proficy_lvl_source
                   ,p_step_value => p_step_value
                   ,p_comments => p_comments
                   ,p_cert_date => p_certification_date
                   ,p_cert_method => p_certification_mthd
                   ,p_next_cert_date => p_next_certifctn_date
                   ,p_prev_start_date => p_prev_start_date
                   ,p_prev_step_value => l_prev_step_value
                   ,p_prev_profy_level_id => null
                   ,p_change_mode => 'UPDATE_APPLY'
                   ,p_sys_generated => 'N'
                   ,p_upg_from_rec_id => -1
                   ,p_status          => p_competence_status);
  ELSE
           hr_utility.set_location(l_proc,100);
           writeTo_transTbl(p_item_type => p_item_type
                      ,p_item_key => p_item_key
                      ,p_actid => to_number(p_actid)
                      ,p_login_person_id => fnd_global.employee_id
                      ,p_trans_id => l_transaction_id
                      ,p_trans_step_id => l_transaction_step_id
                      ,p_api_name => g_api_name
                      ,p_person_id => p_person_id
                      ,p_business_group_id => g_business_group_id
                      ,p_comp_element_id => p_competence_element_id
                      ,p_ovn => null
                      ,p_eff_date_from => to_char(l_eff_date_from, g_date_format)
                      ,p_eff_date_to => to_char(l_eff_date_to, g_date_format)
                      ,p_comp_id => p_competence_id
                      ,p_comp_name => p_competence_name
                      ,p_comp_alias => p_competence_alias
                      ,p_profy_level_id => p_proficiency_level_id
                      ,p_profy_level_source => p_proficy_lvl_source
                      ,p_step_value => p_step_value
                      ,p_comments => p_comments
                      ,p_cert_date => p_certification_date
                      ,p_cert_method => p_certification_mthd
                      ,p_next_cert_date => p_next_certifctn_date
                      ,p_prev_start_date => p_prev_start_date
                      ,p_prev_step_value => l_prev_step_value
                      ,p_prev_profy_level_id => l_PREUPD_PROFICY_LVL_ID
                      ,p_change_mode => 'UPDATE_APPLY'
                      ,p_sys_generated => 'N'
                      ,p_upg_from_rec_id => -1
                      ,p_status          => p_competence_status);
  END IF;
  hr_utility.set_location(' Leaving:' || l_proc,105);
  --
    EXCEPTION
    WHEN hr_comp_profile_ss.g_data_err THEN
      hr_utility.set_location(' Leaving:' || l_proc,555);
      raise hr_utility.hr_error;
    --
    WHEN hr_comp_profile_ss.g_access_violation_err THEN
      hr_utility.set_location(' Leaving:' || l_proc,560);
      raise hr_utility.hr_error;
    --
    When others THEN
      hr_utility.set_location(' Leaving:' || l_proc,565);
      raise hr_utility.hr_error;
End process_save_currentupdate;
-- ---------------------------- < process_api > ------------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure reads the data from transaction table and saves it
--          to the database.
--          This procedure is called after Workflow Approval or the user
--          chooses "Update" without approval in workflow.
-- ---------------------------------------------------------------------------
Procedure process_api(p_validate            in boolean default false
                     ,p_transaction_step_id in number
                     ,p_effective_date        in varchar2 default null) is
  --
  l_proc varchar2(200) := g_package || 'process_api';
  l_cmp_element_rec             per_competence_elements%rowtype;
  l_system_generated            varchar2(1) default null;
  l_upgraded_from_rec_id        number DEFAULT Null;
  l_preupd_proficy_lvl_id       number default NULL;
  l_competence_name             per_competences_vl.name%type;
  l_step_value                  per_rating_levels.step_value%type;
  l_item_type                hr_api_transaction_steps.item_type%type;
  l_item_key                 hr_api_transaction_steps.item_key%type;
  l_activity_id                hr_api_transaction_steps.ACTIVITY_ID%type;
  l_cmp_element_id             per_competence_elements.competence_element_id%type;
  l_achieved_date              per_competence_elements.ACHIEVED_DATE%type;
  l_change_mode              varchar2(80);
  l_status                   per_competence_elements.status%type;
  --
Begin
  --
  hr_utility.set_location(' Entering:' || l_proc,5);
  l_cmp_element_rec.type := 'PERSONAL';
  --
  l_cmp_element_rec.business_group_id :=
    hr_transaction_api.get_number_value
       (p_transaction_step_id => p_transaction_step_id
       ,p_name                => 'P_BUSINESS_GROUP_ID');
   --
  l_cmp_element_rec.comments :=
    hr_transaction_api.get_varchar2_value
       (p_transaction_step_id => p_transaction_step_id
       ,p_name                => 'P_COMMENTS');
  --
  l_cmp_element_rec.person_id:=
    hr_transaction_api.get_number_value
       (p_transaction_step_id => p_transaction_step_id
       ,p_name                => 'P_PERSON_ID');
  --
  l_cmp_element_rec.competence_element_id :=
    hr_transaction_api.get_number_value
       (p_transaction_step_id => p_transaction_step_id
       ,p_name                => 'P_COMPETENCE_ELEMENT_ID');
  --
  l_cmp_element_rec.object_version_number :=
    hr_transaction_api.get_number_value
       (p_transaction_step_id => p_transaction_step_id
       ,p_name                => 'P_OBJECT_VERSION_NUMBER');
  --
  l_cmp_element_rec.competence_id :=
    hr_transaction_api.get_number_value
       (p_transaction_step_id => p_transaction_step_id
       ,p_name                => 'P_COMPETENCE_ID');
  --
  l_competence_name :=
    hr_transaction_api.get_varchar2_value
       (p_transaction_step_id => p_transaction_step_id
       ,p_name                => 'P_COMPETENCE_NAME');
  --
  l_cmp_element_rec.proficiency_level_id:=
    hr_transaction_api.get_number_value
       (p_transaction_step_id => p_transaction_step_id
       ,p_name                => 'P_PROFICIENCY_LEVEL_ID');
  --
  l_step_value :=
    hr_transaction_api.get_number_value
       (p_transaction_step_id => p_transaction_step_id
       ,p_name                => 'P_STEP_VALUE');
  --
  l_preupd_proficy_lvl_id:=
    hr_transaction_api.get_number_value
       (p_transaction_step_id => p_transaction_step_id
       ,p_name                => 'P_PREUPD_PROFICY_LVL_ID');
  --
  l_cmp_element_rec.certification_method:=
    hr_transaction_api.get_varchar2_value
       (p_transaction_step_id => p_transaction_step_id
       ,p_name                => 'P_CERTIFICATION_MTHD');
  --
  l_cmp_element_rec.source_of_proficiency_level:=
    hr_transaction_api.get_varchar2_value
       (p_transaction_step_id => p_transaction_step_id
       ,p_name                => 'P_PROFICY_LVL_SOURCE');
  --
  l_cmp_element_rec.effective_date_from :=
    hr_transaction_api.get_date_value
       (p_transaction_step_id => p_transaction_step_id
       ,p_name                => 'P_EFF_DATE_FROM');
  --
  l_cmp_element_rec.effective_date_to :=
    hr_transaction_api.get_date_value
       (p_transaction_step_id => p_transaction_step_id
       ,p_name                => 'P_EFF_DATE_TO');
  --
  l_cmp_element_rec.certification_date :=
    hr_transaction_api.get_date_value
       (p_transaction_step_id => p_transaction_step_id
       ,p_name                => 'P_CERTIFICATION_DATE');
  --
  l_cmp_element_rec.next_certification_date :=
    hr_transaction_api.get_date_value
       (p_transaction_step_id => p_transaction_step_id
       ,p_name                => 'P_NEXT_CERTIFCTN_DATE');
  --
  l_system_generated :=
    hr_transaction_api.get_varchar2_value
       (p_transaction_step_id => p_transaction_step_id
       ,p_name                => 'P_SYSTEM_GENERATED');
  --
  l_upgraded_from_rec_id := NULL;
  l_upgraded_from_rec_id :=
    hr_transaction_api.get_number_value
       (p_transaction_step_id => p_transaction_step_id
       ,p_name                => 'P_UPGRADED_FROM_REC_ID');
-- for comp qual link enahancement
  l_change_mode := NULL;
  l_change_mode :=
    hr_transaction_api.get_varchar2_value
       (p_transaction_step_id => p_transaction_step_id
       ,p_name                => 'P_CHANGE_MODE');

l_cmp_element_rec.status :=
  hr_transaction_api.get_varchar2_value
       (p_transaction_step_id => p_transaction_step_id
       ,p_name                => 'P_STATUS');
Select ITEM_TYPE,ITEM_KEY,ACTIVITY_ID
       INTO l_item_type, l_item_key, l_activity_id
       FROM hr_api_transaction_steps
       WHERE transaction_step_id = p_transaction_step_id;
  l_cmp_element_rec.status := PerCompStatus.Get_Competence_Status(
                               p_item_type       =>l_item_type
                               ,p_item_key        =>l_item_key
                               ,p_activity_id     =>l_activity_id
                               ,p_competence_id   => l_cmp_element_rec.competence_id
                               ,p_competence_element_id => l_cmp_element_rec.competence_element_id
                               ,p_person_id            => l_cmp_element_rec.person_id
                               ,p_eff_date             => trunc(sysdate));
  IF l_cmp_element_rec.status = 'ACHIEVED' Then
      l_cmp_element_rec.achieved_date := trunc(sysdate);
  else
      l_cmp_element_rec.achieved_date := null;
  END if;
  IF l_system_generated = 'N' AND
        l_upgraded_from_rec_id is not null THEN
        hr_utility.set_location(l_proc,10);
        l_cmp_element_rec.competence_element_id := null;
  END IF;
  --
  -- set a savepoint before calling api
  savepoint save_competence_element;
  --
  l_cmp_element_id := null;
  IF l_upgraded_from_rec_id IS NOT NULL then
     l_cmp_element_id := l_upgraded_from_rec_id;
  else
     IF l_cmp_element_rec.competence_element_id IS NOT NULL then
     l_cmp_element_id := l_cmp_element_rec.competence_element_id;
     END if;
  END if;
  hr_utility.set_location(l_proc,15);
  IF l_system_generated = 'Y' AND
     l_cmp_element_rec.competence_element_id is not null THEN
     hr_utility.set_location(l_proc,20);
-- for comp qual link enahancement
-- Adding the Status field.

     per_cel_upd.upd
       (p_validate              => False
       ,p_competence_element_id => l_cmp_element_rec.competence_element_id
       ,p_object_version_number => l_cmp_element_rec.object_version_number
       ,p_effective_date_to     => l_cmp_element_rec.effective_date_to
--       ,p_status                => l_cmp_element_rec.status
--       ,p_achieved_date         => l_achieved_date
       ,p_effective_date        => trunc(sysdate));
     --
     If l_change_mode  LIKE 'UPGRADE%' then
        null;
     else
     HR_COMP_OUTCOME_PROFILE_SS.call_process_api(
             p_validate               => p_validate
            ,p_competence_id          => l_cmp_element_rec.competence_id
            ,p_competence_element_id  => l_cmp_element_id
            ,p_new_competence_element_id => l_cmp_element_rec.competence_element_id
            ,p_item_type              => l_item_type
            ,p_item_key               => l_item_key
            ,p_activity_id            => l_activity_id
            ,p_person_id              => l_cmp_element_rec.person_id
            ,p_effective_date         => trunc(sysdate)); -- for comp qual link enahancement
      END if;
  ELSIF l_cmp_element_rec.competence_element_id is not null THEN
     hr_utility.set_location(l_proc,25);
     Select pce.status, Achieved_date INTO l_status, l_achieved_date
         FROM
            per_competence_elements pce
         Where pce.competence_element_id = l_cmp_element_rec.competence_element_id;
      IF l_status = l_cmp_element_rec.status then
         l_cmp_element_rec.achieved_date := l_achieved_date;
      END if;
     per_cel_upd.upd
       (p_validate              => False
       ,p_competence_element_id => l_cmp_element_rec.competence_element_id
       ,p_comments              => l_cmp_element_rec.comments
       ,p_object_version_number => l_cmp_element_rec.object_version_number
       ,p_effective_date_from   => l_cmp_element_rec.effective_date_from
       ,p_effective_date_to     => l_cmp_element_rec.effective_date_to
       ,p_proficiency_level_id  => l_cmp_element_rec.proficiency_level_id
       ,p_source_of_proficiency_level =>
                                l_cmp_element_rec.source_of_proficiency_level
       ,p_certification_method  => l_cmp_element_rec.certification_method
       ,p_certification_date    => l_cmp_element_rec.certification_date
       ,p_next_certification_date  =>
                                l_cmp_element_rec.next_certification_date
       ,p_status                => l_cmp_element_rec.status -- for comp qual link enahancement
       ,p_achieved_date         => l_cmp_element_rec.achieved_date  -- for comp qual link enahancement
       ,p_effective_date        => trunc(sysdate));
     --
     If l_change_mode  LIKE 'UPGRADE%' then
        null;
     else
     HR_COMP_OUTCOME_PROFILE_SS.call_process_api(
             p_validate               => p_validate
            ,p_competence_id           => l_cmp_element_rec.competence_id
            ,p_competence_element_id  => l_cmp_element_id
            ,p_new_competence_element_id => l_cmp_element_rec.competence_element_id
            ,p_item_type              => l_item_type
            ,p_item_key                => l_item_key
            ,p_activity_id            => l_activity_id
            ,p_person_id              => l_cmp_element_rec.person_id
            ,p_effective_date         => trunc(sysdate)); -- for comp qual link enahancement
      END if;
  ELSE
       hr_utility.set_location(l_proc,30);
       per_cel_ins.ins
       (p_validate              => False
       ,p_competence_element_id => l_cmp_element_rec.competence_element_id
       ,p_business_group_id     => l_cmp_element_rec.business_group_id
       ,p_comments              => l_cmp_element_rec.comments
       ,p_object_version_number => l_cmp_element_rec.object_version_number
       ,p_type                  => l_cmp_element_rec.type
       ,p_person_id             => l_cmp_element_rec.person_id
       ,p_competence_id         => l_cmp_element_rec.competence_id
       ,p_effective_date_from   => l_cmp_element_rec.effective_date_from
       ,p_effective_date_to     => l_cmp_element_rec.effective_date_to
       ,p_proficiency_level_id  => l_cmp_element_rec.proficiency_level_id
       ,p_source_of_proficiency_level =>
                                l_cmp_element_rec.source_of_proficiency_level
       ,p_certification_method  => l_cmp_element_rec.certification_method
       ,p_certification_date    => l_cmp_element_rec.certification_date
       ,p_next_certification_date     =>
                                l_cmp_element_rec.next_certification_date
       ,p_status                => l_cmp_element_rec.status -- for comp qual link enahancement
       ,p_achieved_date         => l_cmp_element_rec.achieved_date  -- for comp qual link enahancement
       ,p_effective_date        => trunc(sysdate));
     IF l_cmp_element_id IS NULL then
        l_cmp_element_id := l_cmp_element_rec.competence_element_id;
     END if;
     HR_COMP_OUTCOME_PROFILE_SS.call_process_api(
             p_validate               => p_validate
            ,p_competence_id          => l_cmp_element_rec.competence_id
            ,p_competence_element_id  => l_cmp_element_id
            ,p_new_competence_element_id => l_cmp_element_rec.competence_element_id
            ,p_item_type              => l_item_type
            ,p_item_key               => l_item_key
            ,p_activity_id            => l_activity_id
            ,p_person_id              => l_cmp_element_rec.person_id
            ,p_effective_date         => trunc(sysdate)); -- for comp qual link enahancement
  END IF;
  --
  --
  hr_utility.set_location(l_proc,35);
  IF p_validate = true THEN
     hr_utility.set_location(l_proc,40);
     rollback to save_competence_element;
  END IF;
  hr_utility.set_location(' Leaving:' || l_proc,45);
  --
  Exception
    When hr_utility.hr_error THEN
      hr_utility.set_location(' Leaving:' || l_proc,555);
      rollback to save_competence_element;
      IF NOT (l_upgraded_from_rec_id IS NOT NULL AND
         hr_message.last_message_name = 'HR_51648_CEL_PER_DATES_OVLAP') THEN
         hr_utility.set_location(' Leaving:' || l_proc,560);
        RAISE;
      END IF;
    --
    When others THEN
      hr_utility.set_location(' Leaving:' || l_proc,565);
      raise;
--
End process_api;
-----------new procedure for validating and saving record into transaction tables --------------------------
------------------------------------------------------------------------------------------------------------
Procedure api_validate_competence_rec_ss
          (p_item_type             in varchar2
          ,p_item_key              in varchar2
          ,p_activity_id           in varchar2
          ,p_pid                   in number
          ,p_validate              in varchar2
          ,p_business_group_id     in number default null
          ,p_change_mode           in varchar2 default null
          ,p_competence_element_id in number default null
          ,p_preupd_obj_vers_num   in number default null
          ,p_competence_id         in number default null
          ,p_proficiency_level_id  in number default null
          ,p_eff_date_from         in varchar2 default null
          ,p_comments              in varchar2  default null
          ,p_eff_date_to           in varchar2 default null
          ,p_proficy_lvl_source    in varchar2 default null
          ,p_certification_mthd    in varchar2 default null
          ,p_certification_date    in varchar2 default null
          ,p_next_certifctn_date   in varchar2 default null
          ,p_competence_status     in varchar2 default null
          ,p_transaction_step_id   in out nocopy number
          ,p_error_message         out nocopy long) is
  --
  l_proc varchar2(200) := g_package || 'api_validate_competence_rec_ss';
  l_user_date_format           varchar2(200) default null;
  l_user_date_format_length    number default null;
  l_sample_date                varchar2(200) default null;
  l_date_char                  varchar2(200) default null;
  l_rec_changed                boolean default null;
  l_date_error                 boolean default null;
  l_msg_text                   varchar2(2000) default null;
  l_eff_date_from              date default null;
  l_eff_date_to                date default null;
  l_preupd_date_to             date default null;
  l_new_competence_element_id  number default null;
  l_new_obj_vers_num           number default null;
  l_next_certification_date    date default null;
  l_certification_date         date default null;
  l_object_version_number      number default null;
  l_action_person_id           number default null;
  l_validate                   boolean  default null;
  l_comments                    varchar2(200) default null;
  --
  l_current_step_value         number default null;
  l_current_step_val           number default null;
  l_prev_step_value            number default null;
  l_prev_step_val              number default null;
  l_prev_prof_lvl_value        number default null;
  l_prev_prof_lvl_val          number default null;
  c_name                       per_competences.name%TYPE default null;
  p_competence_name            per_competences.name%TYPE default null;
  c_comp_alias                 varchar2(200) default null;
  p_competence_alias           varchar2(200) default null;
  l_prev_date                  date;
  l_prev_start_date            date;
  l_changed                    boolean default false;
  l_warning_exists             boolean default false;
  l_mode_fetch                 varchar2(20) default null;
  m_mode                       varchar2(20) default null;
CURSOR get_old_txn_ids ( p_item_type             in varchar2
          ,p_item_key              in varchar2
          ,p_activity_id IN varchar2
          ,p_person_id IN number
          ,p_competence_element_id IN number
          ,p_competence_id         IN number
          ,p_change_mode IN varchar2) is
     Select s.transaction_step_id
     FROM hr_api_transaction_steps s,
          hr_api_transaction_values c, hr_api_transaction_values d,
          hr_api_transaction_values e, hr_api_transaction_values f
     WHERE
          s.item_type = p_item_type
 	and s.item_key = p_item_key
 	and s.activity_id = p_activity_id
        AND s.api_name = 'HR_COMP_PROFILE_SS.PROCESS_API'
        and c.transaction_step_id = s.transaction_step_id
        and d.transaction_step_id = s.transaction_step_id
        and e.transaction_step_id = s.transaction_step_id
        and f.transaction_step_id = s.transaction_step_id
        AND c.NAME = 'P_PERSON_ID'
        AND d.NAME = 'P_COMPETENCE_ELEMENT_ID'
        AND e.NAME = 'P_COMPETENCE_ID'
        AND f.NAME = 'P_CHANGE_MODE'
        AND c.number_value = p_person_id
        AND d.number_value = p_competence_element_id
        AND e.number_value = p_competence_id
        AND f.varchar2_value = p_change_mode ;
  Cursor get_comp_dates ( p_competence_id IN Number )is
    select date_to end_date,
           date_from start_date
    from   per_competences_vl
    where  competence_id = p_competence_id;
  l_comp_dates_cur get_comp_dates%RowType;
Begin
  hr_utility.set_location(' Entering:' || l_proc,5);
  IF (p_transaction_step_id = -1 ) then
    hr_utility.set_location(l_proc,10);
    p_transaction_step_id := Null;
  ENd IF;
  IF (p_competence_element_id is not NULL) THEN
      hr_utility.set_location(l_proc,15);
      hr_comp_profile_ss.check_if_cmptnce_rec_changed
      (p_competence_element_id => p_competence_element_id
      ,p_competence_id => p_competence_id
      ,p_proficiency_level_id  => p_proficiency_level_id
      ,p_eff_date_from => to_date(p_eff_date_from,g_date_format)
      ,p_eff_date_to => to_date(p_eff_date_to,g_date_format)
      ,p_proficy_lvl_source => p_proficy_lvl_source
      ,p_certification_mthd => p_certification_mthd
      ,p_certification_date => to_date(p_certification_date,g_date_format)
      ,p_next_certifctn_date => to_date(p_next_certifctn_date,g_date_format)
      ,p_competence_status   => p_competence_status
      ,p_comments => p_comments
      ,p_change_mode => p_change_mode
      ,p_rec_changed => l_changed);
    if l_changed = false THEN
      hr_utility.set_location(l_proc,20);
      HR_COMP_OUTCOME_PROFILE_SS.check_if_cmptnce_rec_changed
      (p_item_type               => p_item_type
      ,p_item_key                => p_item_key
      ,p_activity_id             => p_activity_id
      ,p_pid                     => p_pid
      ,p_competence_element_id   => p_competence_element_id
      ,p_competence_id           => p_competence_id
      ,p_rec_changed             => l_changed
      );
      IF l_changed = FALSE then
        IF (p_transaction_step_id IS NOT Null) THEN
          hr_utility.set_location(l_proc,25);
          delete_transaction_step_id(p_transaction_step_id);
        END IF;
        hr_utility.set_location(' Leaving:' || l_proc,30);
        return;
      END if;
    end if;
  END IF;
  hr_utility.set_location(l_proc,35);
  OPEN get_curr_step_value(p_proficiency_level_id);
  FETCH get_curr_step_value into l_current_step_val;
  IF  get_curr_step_value%notfound THEN
       hr_utility.set_location(l_proc,40);
       l_current_step_val := Null;
  END IF;
  hr_utility.set_location(l_proc,45);
  close get_curr_step_value;
  l_current_step_value :=  l_current_step_val;
  OPEN get_comp_name(p_competence_id => p_competence_id);
  FETCH get_comp_name into c_name;
  IF get_comp_name%notfound THEN
       hr_utility.set_location(l_proc,50);
       close get_comp_name;
       raise hr_comp_profile_ss.g_fatal_error;
  END IF;
  close get_comp_name;
  p_competence_name := c_name;
  hr_utility.set_location(l_proc,55);
  OPEN get_comp_alias(p_competence_id => p_competence_id);
  FETCH get_comp_alias into c_comp_alias;
  IF get_comp_alias%notfound THEN
       hr_utility.set_location(l_proc,60);
       close get_comp_name;
       raise hr_comp_profile_ss.g_fatal_error;
  END IF;
  close get_comp_alias;
  p_competence_alias := c_comp_alias;
  hr_utility.set_location(l_proc,65);
  OPEN get_comp_dates(p_competence_id => p_competence_id);
  FETCH get_comp_dates into l_comp_dates_cur;
  IF get_comp_dates%NOTFOUND THEN
     hr_utility.set_location(l_proc,70);
     l_eff_date_to := p_eff_date_to;
  ELSE
     hr_utility.set_location(l_proc,75);
     IF (l_comp_dates_cur.start_date IS NOT NULL AND
         l_comp_dates_cur.start_date > to_date(p_eff_date_from, g_date_format) ) THEN
         hr_utility.set_location(l_proc,80);
         p_error_message := hr_java_conv_util_ss.get_formatted_error_message(
                            p_error_message => p_error_message,
                            p_attr_name     => 'CurrStartDate',
                            p_app_short_name => 'PER',
                            P_SINGLE_ERROR_MESSAGE => 'HR_52339_COMP_ELMT_DATE_INVL');
          CLOSE get_comp_dates;
          hr_utility.set_location(' Leaving:' || l_proc,85);
          RETURN;
      END IF;
      IF p_eff_date_to IS NULL THEN
          hr_utility.set_location(l_proc,90);
          l_eff_date_to := l_comp_dates_cur.end_date;
      ELSIF (l_comp_dates_cur.end_Date IS NOT NULL AND
             l_comp_dates_cur.end_date < to_date(p_eff_date_to, g_date_format) ) THEN
             hr_utility.set_location(l_proc,95);
           p_error_message := hr_java_conv_util_ss.get_formatted_error_message(
                             p_error_message => p_error_message,
                             p_attr_name     => 'EndDate',
                             p_app_short_name => 'PER',
                             P_SINGLE_ERROR_MESSAGE => 'HR_52339_COMP_ELMT_DATE_INVL');
           CLOSE get_comp_dates;
           hr_utility.set_location(' Leaving:' || l_proc,100);
           RETURN;
      ELSE
          hr_utility.set_location(l_proc,105);
          l_eff_date_to := to_date(p_eff_date_to, g_date_format);
      END IF;
  END IF ;
  CLOSE get_comp_dates;
  hr_utility.set_location(l_proc,110);
  if p_competence_element_id is not null then
    hr_utility.set_location(l_proc,115);
    OPEN get_previous_step_value(p_competence_element_id);
    FETCH get_previous_step_value into l_prev_step_val;
    IF get_previous_step_value%notfound THEN
         hr_utility.set_location(l_proc,120);
         close get_previous_step_value;
    END IF;
    close get_previous_step_value;
    hr_utility.set_location(l_proc,125);
    l_prev_step_value :=  l_prev_step_val;
    OPEN get_prev_prof_lvl_id(p_competence_element_id);
    FETCH get_prev_prof_lvl_id into l_prev_prof_lvl_val;
    IF get_prev_prof_lvl_id%notfound THEN
         hr_utility.set_location(l_proc,130);
         close get_prev_prof_lvl_id;
    END IF;
    close get_prev_prof_lvl_id;
    hr_utility.set_location(l_proc,135);
    l_prev_prof_lvl_value := l_prev_prof_lvl_val;
    OPEN get_prev_start_date(p_competence_element_id);
    FETCH get_prev_start_date into l_prev_date;
    IF get_prev_start_date%notfound THEN
          hr_utility.set_location(l_proc,140);
          close get_comp_name;
          raise hr_comp_profile_ss.g_fatal_error;
    END IF;
    close get_prev_start_date;
    hr_utility.set_location(l_proc,145);
    l_prev_start_date := l_prev_date;
    if p_transaction_step_id is not null then
       hr_utility.set_location(l_proc,150);
       select varchar2_value into l_mode_fetch
       from hr_api_transaction_values
       where transaction_step_id = p_transaction_step_id
       and name = 'P_CHANGE_MODE';
       if l_mode_fetch = 'UPGRADE' or l_mode_fetch = 'UPDATE_APPLY' then
          hr_utility.set_location(l_proc,155);
          if l_current_step_val = l_prev_step_val then
              hr_utility.set_location(l_proc,160);
              raise g_invalid_entry;
          end if;
       end if;
    end if;
end if;
hr_utility.set_location(l_proc,165);
if  p_transaction_step_id is not null then
    hr_utility.set_location(l_proc,170);
    select varchar2_value into m_mode from hr_api_transaction_values
    where transaction_step_id = p_transaction_step_id
    and name = 'P_CHANGE_MODE';
    if m_mode = 'UPGRADE' then
        hr_utility.set_location(l_proc,175);
        select number_value into l_prev_step_value
        from hr_api_transaction_values
        where transaction_step_id = p_transaction_step_id
        and name = 'P_PREV_STEP_VALUE';
        select number_value into l_prev_prof_lvl_value
        from hr_api_transaction_values
        where transaction_step_id = p_transaction_step_id
        and name = 'P_PREUPD_PROFICY_LVL_ID';
        select date_value into l_prev_start_date
        from hr_api_transaction_values
        where transaction_step_id = p_transaction_step_id
        and name = 'P_PREV_START_DATE';
    end if;
end if;
IF p_change_mode = 'CORRECT' then
    hr_utility.set_location('In  p_change_mode = CORRECT' || l_proc,170);
   FOR rec IN get_old_txn_ids ( p_item_type => p_item_type
          ,p_item_key        =>       p_item_key
          ,p_activity_id     =>       p_activity_id
          ,p_person_id       =>       p_pid
          ,p_competence_element_id => p_competence_element_id
          ,p_competence_id         => p_competence_id
          ,p_change_mode           => p_change_mode )
     loop
   hr_utility.set_location('In loop rec.transaction_step_id='  || rec.transaction_step_id,175);
      IF (p_transaction_step_id = rec.transaction_step_id) then
      hr_utility.set_location('In p_transaction_step_id = rec.transaction_step_id  ',180);
         null;
      Else
      hr_utility.set_location('In else of p_transaction_step_id = rec.transaction_step_id  ',185);
         delete_transaction_step_id(rec.transaction_step_id);
      hr_utility.set_location('after calling delete_transaction_step_id  ',190);
      END if;
     END loop;
END if;
hr_utility.set_location(l_proc,180);
process_save(p_item_type => p_item_type
            ,p_item_key => p_item_key
            ,p_actid    => p_activity_id
            ,p_person_id => p_pid
            ,p_change_mode => p_change_mode
            ,p_competence_element_id => p_competence_element_id
            ,p_preupd_obj_vers_num => p_preupd_obj_vers_num
            ,p_competence_id => p_competence_id
            ,p_competence_name => p_competence_name
            ,p_competence_alias => p_competence_alias
            ,p_proficiency_level_id => p_proficiency_level_id
            ,p_step_value => l_current_step_value
            ,p_preupd_proficy_lvl_id => l_prev_prof_lvl_value
            ,p_certification_mthd => p_certification_mthd
            ,p_proficy_lvl_source => p_proficy_lvl_source
            ,p_eff_date_from => p_eff_date_from
            ,p_eff_date_to => to_char(l_eff_date_to,g_date_format)
            ,p_certification_date => p_certification_date
            ,p_next_certifctn_date => p_next_certifctn_date
            ,p_comments => p_comments
            ,p_prev_step_value => l_prev_step_value
            ,p_prev_start_date => to_char(l_prev_start_date,g_date_format)
            ,p_transaction_step_id => p_transaction_step_id
            ,p_error_message     => p_error_message
            ,p_competence_status => p_competence_status);
hr_utility.set_location(' Leaving:' || l_proc,185);
Exception
 when g_invalid_entry then
   hr_utility.set_location(' Leaving:' || l_proc,555);
   null;
 when others then
   hr_utility.set_location(' Leaving:' || l_proc,560);
   raise g_invalid_entry;
End api_validate_competence_rec_ss;
-------------------------------------------------------------------------------
Procedure get_pending_addition_ids
          (p_item_type IN varchar2
          ,p_item_key  IN varchar2
          ,p_step_values  out nocopy varchar2
          ,p_rows         out nocopy number) is
l_proc varchar2(200) := g_package || 'get_pending_addition_ids';
cursor get_add_ids (p_transaction_id number) is
  select step.transaction_step_id
  from hr_api_transaction_steps step, hr_api_transaction_values val
  where step.transaction_id = p_transaction_id
    and val.transaction_step_id = step.transaction_step_id
    and val.varchar2_value = 'ADD';
l_index number;
l_transaction_id number;
begin
  hr_utility.set_location(' Entering:' || l_proc,5);
  l_transaction_id:=hr_transaction_ss.get_transaction_id
                      (p_item_type   =>   p_item_type
                      ,p_item_key    =>   p_item_key);
  l_index := 0;
  for l_step_values in get_add_ids(p_transaction_id => l_transaction_id) loop
    hr_utility.set_location(l_proc || 'LOOP' ,10);
    p_step_values  := p_step_values || l_step_values.transaction_step_id  || '?';
    l_index := l_index + 1;
  end loop ;
  p_rows := l_index;
  hr_utility.set_location(' Leaving:' || l_proc,15);
end get_pending_addition_ids;
--------------DELETE  PENDING CURRENT UPDATE IDS ----------------------------------------------
Procedure del_pen_currupd_ids(p_item_type IN varchar2
                             ,p_item_key  IN varchar2) is
l_proc varchar2(200) := g_package || 'del_pen_currupd_ids';
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
  hr_utility.set_location(' Entering:' || l_proc,5);
  l_transaction_id:=hr_transaction_ss.get_transaction_id
                      (p_item_type   =>   p_item_type
                      ,p_item_key    =>   p_item_key);
  for I in get_upd_ids(l_transaction_id) loop
       hr_utility.set_location(l_proc || 'LOOP' ,10);
-- Added for competence Qualification link enhancement
--  HR_COMP_OUTCOME_PROFILE_SS.delete_add_page(
--        p_transaction_step_id  => I.transaction_step_id);
-- End for competence Qualification link enhancement
       delete from hr_api_transaction_values
        where transaction_step_id = I.transaction_step_id;
       delete from hr_api_transaction_steps
        where transaction_step_id = I.transaction_step_id;
  end loop;
  del_add_ids(p_item_type, p_item_key);
  commit;
  hr_utility.set_location(' Leaving:' || l_proc,15);
end del_pen_currupd_ids;
----------------------------------------------------------------------------------------------------
Procedure del_add_ids(p_item_type IN varchar2
                     ,p_item_key  IN varchar2) is
l_proc varchar2(200) := g_package || 'del_add_ids';
cursor get_add_ids(p_transaction_id number) is
  select steps.transaction_step_id
    from hr_api_transaction_values val, hr_api_transaction_steps steps
   where steps.transaction_id = p_transaction_id
     and steps.transaction_step_id = val.transaction_step_id
     and val.varchar2_value = 'ADD';
l_step_values   number ;
l_transaction_id number;
begin
  hr_utility.set_location(' Entering:' || l_proc,5);
  l_transaction_id:=hr_transaction_ss.get_transaction_id
                      (p_item_type   =>   p_item_type
                      ,p_item_key    =>   p_item_key);
  for I in get_add_ids(l_transaction_id) loop
       hr_utility.set_location(l_proc || 'LOOP' ,10);
       delete from hr_api_transaction_values
        where transaction_step_id = I.transaction_step_id;
       delete from hr_api_transaction_steps
        where transaction_id = l_transaction_id
          and transaction_step_id = I.transaction_step_id;
  end loop ;
  hr_utility.set_location(' Leaving:' || l_proc,15);
end del_add_ids;
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
                (p_item_type IN VARCHAR2
                ,p_item_key IN VARCHAR2
        ,p_actid IN NUMBER
        ,p_login_person_id IN NUMBER
        ,p_transaction_step_id IN OUT NOCOPY NUMBER
                ,p_api_name IN VARCHAR2  default null
                ,p_api_display_name IN VARCHAR2 DEFAULT NULL
        ,p_transaction_data IN TRANSACTION_TABLE1) AS
l_proc varchar2(200) := g_package || 'save_transaction_step';
l_count Number:=0;
BEGIN
  hr_utility.set_location(' Entering:' || l_proc,5);
  l_count := p_transaction_data.COUNT;
  FOR i IN 1..l_count LOOP
    BEGIN
        hr_utility.set_location(l_proc,10);
        IF p_transaction_data(i).param_data_type = 'DATE' THEN
             hr_utility.set_location(l_proc,15);
             hr_transaction_api.set_date_value(p_transaction_step_id => p_transaction_step_id
                        ,p_person_id => p_login_person_id
                        ,p_name  => p_transaction_data(i).param_name
                        ,p_value => to_date(ltrim(rtrim(p_transaction_data(i).param_value)),g_date_format));
        ELSIF p_transaction_data(i).param_data_type = 'NUMBER' THEN
                            hr_utility.set_location(l_proc,20);
                            hr_transaction_api.set_number_value(p_transaction_step_id => p_transaction_step_id
                            ,p_person_id => p_login_person_id
                            ,p_name => p_transaction_data(i).param_name
                            ,p_value => to_number(ltrim(rtrim(p_transaction_data(i).param_value))));
        ELSIF p_transaction_data(i).param_data_type = 'VARCHAR2' THEN
                        hr_utility.set_location(l_proc,25);
                        hr_transaction_api.set_varchar2_value(p_transaction_step_id => p_transaction_step_id
                        ,p_person_id => p_login_person_id
                        ,p_name => p_transaction_data(i).param_name
                        ,p_value => p_transaction_data(i).param_value);
        END IF;
   Exception When others then
    hr_utility.set_location(l_proc,555);
    RAISE hr_utility.hr_error;
   END;
  END LOOP;
  hr_utility.set_location(' Leaving:' || l_proc,30);
  EXCEPTION
    WHEN OTHERS THEN
         hr_utility.set_location(l_proc,560);
         hr_utility.trace('EXCEPTION SAVE_TRANSACTION_STEP'||'STS#');
      raise hr_utility.hr_error;
END save_transaction_step;
-----------------------------------
PROCEDURE delete_all_ids
          (p_item_type in varchar2
          ,p_item_key  in varchar2) is
l_proc varchar2(200) := g_package || 'delete_all_ids';
cursor get_all_ids (p_transaction_id number) is
 select transaction_step_id
   from hr_api_transaction_steps
  where transaction_id = p_transaction_id;
l_result           number ;
l_transaction_id   number ;
begin
  hr_utility.set_location(' Entering:' || l_proc,5);
  l_transaction_id:=hr_transaction_ss.get_transaction_id
                      (p_item_type   =>   p_item_type
                      ,p_item_key    =>   p_item_key);
  for l_result in get_all_ids(p_transaction_id => l_transaction_id) loop
       hr_utility.set_location(l_proc || 'LOOP',10);
       delete from hr_api_transaction_values
        where transaction_step_id = l_result.transaction_step_id;
       delete from hr_api_transaction_steps
        where transaction_id = l_transaction_id
          and transaction_step_id = l_result.transaction_step_id;
  end loop ;
  commit;
hr_utility.set_location(' Leaving:' || l_proc,15);
end delete_all_ids;
------------------------------------------------
PROCEDURE delete_transaction_step_id
          (p_transaction_step_id IN number) is
l_proc varchar2(200) := g_package || 'delete_transaction_step_id';
l_transaction_step_id  number;
l_txid                 number;
l_mode                      varchar2(20) default null;
l_competence_element_id     number default null;
l_transaction_id number;
BEGIN
    hr_utility.set_location(' Entering:' || l_proc,5);
    l_transaction_step_id := p_transaction_step_id;
    select transaction_id into l_transaction_id
    from hr_api_transaction_steps
    where transaction_step_id = l_transaction_step_id
    and rownum = 1;
    select varchar2_value
    into l_mode
    from hr_api_transaction_values
    where transaction_step_id = l_transaction_step_id
    and name = 'P_CHANGE_MODE';
    if l_mode = 'UPGRADE' then
        hr_utility.set_location(l_proc,10);
        select number_value
        into l_competence_element_id
        from hr_api_transaction_values
        where transaction_step_id = l_transaction_step_id
        and NAME = 'P_UPGRADED_FROM_REC_ID';
        select a.transaction_step_id into l_txid
        from hr_api_transaction_values a,hr_api_transaction_values b,
             hr_api_transaction_steps steps
        where steps.transaction_id = l_transaction_id
        and steps.transaction_step_id = a.transaction_step_id
        and a.name = 'P_CHANGE_MODE'
        and a.varchar2_value = 'UPGRADE'
        and steps.transaction_step_id = b.transaction_step_id
        and b.name = 'P_COMPETENCE_ELEMENT_ID'
        and b.number_value = l_competence_element_id
        and a.transaction_step_id <> l_transaction_step_id;
        delete from hr_api_transaction_values where transaction_step_id = l_transaction_step_id ;
        delete from hr_api_transaction_steps  where transaction_step_id = l_transaction_step_id ;
        delete from hr_api_transaction_values where transaction_step_id = l_txid ;
        delete from hr_api_transaction_steps  where transaction_step_id = l_txid ;
    else
        delete from hr_api_transaction_values where transaction_step_id = l_transaction_step_id ;
        delete from hr_api_transaction_steps  where transaction_step_id = l_transaction_step_id ;
    end if;
    commit ;
    hr_utility.set_location(' Leaving:' || l_proc,15);
END;
----------------------------------------------------------------------------
-- for saving fields from update main page to tx tables
PROCEDURE process_save_update_details
          (p_item_type              in wf_items.item_type%type
          ,p_item_key               in wf_items.item_key%type
          ,p_actid                  in varchar2
          ,p_person_id              in number
          ,p_proficiency_level_id   in number default null
          ,p_step_value             in number default null
          ,p_eff_date_from          in varchar2 default null
          ,p_prev_step_value        in number default null
          ,p_competence_status      IN VARCHAR2 DEFAULT null
          ,transaction_step_id      in number ) is
 l_proc varchar2(200) := g_package || 'process_save_update_details';
 l_eff_date_from            date default null;
 l_count                    number default 0;
 l_trans_tbl                hr_comp_profile_ss.transaction_table1;
 l_action_person_id         number;
 l_transaction_step_id      number;
 l_prev_step_value number := null;
BEGIN
     hr_utility.set_location(' Entering:' || l_proc,5);
     if (p_prev_step_value <> -1) then
       hr_utility.set_location(l_proc,10);
       l_prev_step_value := p_prev_step_value;
     end if;
     l_action_person_id := p_person_id;
     l_transaction_step_id := transaction_step_id;
     l_count := l_count + 1;
     l_trans_tbl(l_count).param_name := 'P_PROFICIENCY_LEVEL_ID';
     l_trans_tbl(l_count).param_value := p_proficiency_level_id;
     l_trans_tbl(l_count).param_data_type := 'NUMBER';
     --
     l_count := l_count + 1;
     l_trans_tbl(l_count).param_name := 'P_STEP_VALUE';
     l_trans_tbl(l_count).param_value := p_step_value;
     l_trans_tbl(l_count).param_data_type := 'NUMBER';
     --
     l_count := l_count + 1;
     l_trans_tbl(l_count).param_name := 'P_EFF_DATE_FROM';
     l_trans_tbl(l_count).param_value := p_eff_date_from;
     l_trans_tbl(l_count).param_data_type := 'DATE';
    ---------------
     l_count := l_count + 1;
     l_trans_tbl(l_count).param_name := 'P_CHANGE_MODE';
     l_trans_tbl(l_count).param_value := 'UPDATE_APPLY';
     l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
    ---------------
     l_count := l_count + 1;
     l_trans_tbl(l_count).param_name := 'P_STATUS';
     l_trans_tbl(l_count).param_value := p_competence_status;
     l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
----
     save_transaction_step
        (p_item_type      => p_item_type
        ,p_item_key       => p_item_key
        ,p_actid          => to_number(p_actid)
        ,p_login_person_id => fnd_global.employee_id
        ,p_transaction_step_id => l_transaction_step_id
        ,p_transaction_data    => l_trans_tbl);
hr_utility.set_location(' Leaving:' || l_proc,15);
END process_save_update_details;
---------------------------------------------------
-- for saving fields from the update details page to tx tables
procedure save_update_details
          (p_item_type            in varchar2
          ,p_item_key             in varchar2
          ,p_activity_id          in varchar2
          ,p_pid                  in number
          ,p_competence_id        in number
          ,p_competence_element_id in number default null
          ,p_proficiency_level_id in number default null
          ,p_eff_date_from        in varchar2 default null
          ,p_comments             in varchar2 default null
          ,p_eff_date_to          in varchar2 default null
          ,p_proficy_lvl_source   in varchar2 default null
          ,p_certification_mthd   in varchar2 default null
          ,p_certification_date   in varchar2 default null
          ,p_next_certifctn_date  in varchar2 default null
          ,p_preupd_obj_vers_num  in number default null
          ,p_transaction_step_id    in number
          ,p_prev_eff_date_from   in varchar2 default null
          ,p_pre_eff_date_to      in varchar2 default null
          ,p_competence_status    in varchar2 default null
          ,p_error_message        out nocopy long) is
l_proc varchar2(200) := g_package || 'save_update_details';
l_user_date_format      varchar2(20) ;
l_eff_date_from         date default null;
l_eff_date_to           date default null;
l_certification_date    date default null;
l_next_certification_date   date default null;
l_next_certifctn_date   date default null;
l_current_step_value    number;
l_current_step_val      number;
l_prev_date             date;
l_prev_start_date        date;
l_date_error            boolean default null;
l_transaction_step_id   number;
g_business_group_id     number default null;
l_prev_step_value       number default null;
l_prev_step_val         number default null;
--------------
l_object_version_number      number default null;
l_trans_tbl                  hr_comp_profile_ss.transaction_table1;
l_count                      number default 0;
l_action_person_id           number default null;
-------------
begin
    hr_utility.set_location(' Entering:' || l_proc,5);
    l_user_date_format      := g_date_format;
    l_transaction_step_id   := p_transaction_step_id;
    l_action_person_id := p_pid;
    g_business_group_id := hr_util_misc_web.get_business_group_id(p_person_id => l_action_person_id);
    OPEN get_curr_step_value(p_proficiency_level_id => p_proficiency_level_id);
        FETCH get_curr_step_value into l_current_step_val;
        IF  get_curr_step_value%notfound THEN
            hr_utility.set_location(l_proc,10);
            close get_curr_step_value;
        ELSE
          hr_utility.set_location(l_proc,15);
          CLOSE get_curr_step_value;
        END IF ;
    hr_utility.set_location(l_proc,20);
    l_current_step_value :=  l_current_step_val;
    OPEN get_prev_start_date(p_competence_element_id => p_competence_element_id);
        FETCH get_prev_start_date into l_prev_date;
        IF get_prev_start_date%notfound THEN
            hr_utility.set_location(l_proc,25);
            close get_comp_name;
            raise hr_comp_profile_ss.g_fatal_error;
        ELSE
          hr_utility.set_location(l_proc,30);
          CLOSE get_prev_start_date;
        END IF;
    l_prev_start_date := l_prev_date;
    hr_utility.set_location(l_proc,35);
    OPEN get_previous_step_value(p_competence_element_id => p_competence_element_id);
        FETCH get_previous_step_value into l_prev_step_val;
        IF get_previous_step_value%notfound THEN
             hr_utility.set_location(l_proc,40);
             close get_previous_step_value;
        ELSE
          hr_utility.set_location(l_proc,45);
          close get_previous_step_value;
        END IF;
    hr_utility.set_location(l_proc,50);
    l_prev_step_value :=  l_prev_step_val;
    if l_prev_step_value = l_current_step_value then
       hr_utility.set_location(l_proc,55);
       p_error_message := hr_java_conv_util_ss.get_formatted_error_message(
                             p_error_message => p_error_message,
                             p_attr_name     => 'ProfLevel',
                             p_app_short_name => 'PER',
                             P_SINGLE_ERROR_MESSAGE => 'HR_COMP_INV_LEVEL_SS');
       hr_utility.set_location(' Leaving:' || l_proc,60);
       Return;
    end if;
    hr_utility.set_location(l_proc,65);
    api_validate_competence_record
     (p_validate               => true
     ,p_person_id              => p_pid
     ,p_business_group_id      => g_business_group_id
     ,p_change_mode            => 'UPGRADE'
     ,p_competence_element_id  => p_competence_element_id
     ,p_preupd_obj_vers_num    => p_preupd_obj_vers_num
     ,p_competence_id          => p_competence_id
     ,p_proficiency_level_id   => p_proficiency_level_id
     ,p_eff_date_from          => p_eff_date_from
     ,p_eff_date_to            => p_eff_date_to
     ,p_proficy_lvl_source     => p_proficy_lvl_source
     ,p_certification_mthd     => p_certification_mthd
     ,p_certification_date     => p_certification_date
     ,p_next_certifctn_date    => p_next_certifctn_date
     ,p_competence_status      => p_competence_status -- Competence Qualification link Enh.
     ,p_eff_date_from_date_type  => l_eff_date_from
     ,p_eff_date_to_date_type    => l_eff_date_to
     ,p_certifctn_date_type      => l_certification_date
     ,p_next_certifctn_date_type => l_next_certifctn_date
     ,p_error_message            => p_error_message);
    IF p_error_message is not null then
        hr_utility.set_location(' Leaving:' || l_proc,70);
        Return;
    END IF;
     l_count := l_count + 1;
     l_trans_tbl(l_count).param_name := 'P_PROFICIENCY_LEVEL_ID';
     l_trans_tbl(l_count).param_value := p_proficiency_level_id;
     l_trans_tbl(l_count).param_data_type := 'NUMBER';
     --
     l_count := l_count + 1;
     l_trans_tbl(l_count).param_name := 'P_PREV_START_DATE';
     l_trans_tbl(l_count).param_value := to_char(l_prev_start_date,g_date_format);
     l_trans_tbl(l_count).param_data_type := 'DATE';
     l_count := l_count + 1;
     l_trans_tbl(l_count).param_name := 'P_STEP_VALUE';
     l_trans_tbl(l_count).param_value := l_current_step_value;
     l_trans_tbl(l_count).param_data_type := 'NUMBER';
     --
     l_count := l_count + 1;
     l_trans_tbl(l_count).param_name := 'P_CERTIFICATION_MTHD';
     l_trans_tbl(l_count).param_value := p_certification_mthd;
     l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
     --
     l_count := l_count + 1;
     l_trans_tbl(l_count).param_name := 'P_PROFICY_LVL_SOURCE';
     l_trans_tbl(l_count).param_value := p_proficy_lvl_source;
     l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
     --
     l_count := l_count + 1;
     l_trans_tbl(l_count).param_name := 'P_EFF_DATE_FROM';
     l_trans_tbl(l_count).param_value := p_eff_date_from;
     l_trans_tbl(l_count).param_data_type := 'DATE';
     --
     l_count := l_count + 1;
     l_trans_tbl(l_count).param_name := 'P_EFF_DATE_TO';
     l_trans_tbl(l_count).param_value := p_eff_date_to;
     l_trans_tbl(l_count).param_data_type := 'DATE';
     --
     l_count := l_count + 1;
     l_trans_tbl(l_count).param_name := 'P_CERTIFICATION_DATE';
     l_trans_tbl(l_count).param_value := p_certification_date;
     l_trans_tbl(l_count).param_data_type := 'DATE';
     --
     l_count := l_count + 1;
     l_trans_tbl(l_count).param_name := 'P_NEXT_CERTIFCTN_DATE';
     l_trans_tbl(l_count).param_value := p_next_certifctn_date;
     l_trans_tbl(l_count).param_data_type := 'DATE';
     --
     l_count := l_count + 1;
     l_trans_tbl(l_count).param_name := 'P_COMMENTS';
     l_trans_tbl(l_count).param_value := p_comments;
     l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
     -- Competence Qualification link enhancement
     l_count := l_count + 1;
     l_trans_tbl(l_count).param_name := 'P_STATUS';
     l_trans_tbl(l_count).param_value := p_competence_status;
     l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
     --
     save_transaction_step
        (p_item_type      => p_item_type
        ,p_item_key       => p_item_key
        ,p_actid          => to_number(p_activity_id)
        ,p_login_person_id => fnd_global.employee_id
        ,p_transaction_step_id => l_transaction_step_id
        ,p_transaction_data    => l_trans_tbl);
hr_utility.set_location(' Leaving:' || l_proc,75);
------------------
EXCEPTION
    when g_invalid_entry then
         hr_utility.set_location(' Leaving:' || l_proc,555);
         raise g_invalid_entry;
    when others then
        hr_utility.set_location(' Leaving:' || l_proc,560);
        raise  g_invalid_entry;
end save_update_details;
--------------------------------------------------------------------
PROCEDURE final_update_save
          (p_item_type            in varchar2
          ,p_item_key             in varchar2
          ,p_activity_id          in varchar2
          ,p_competence_element_id in number default null
          ,p_pid                  in number
          ,p_proficiency_level_id in number default null
          ,p_eff_date_from        in varchar2 default null
          ,p_step_value           in number
          ,p_transaction_step_id    in number
          ,p_competence_status    IN VARCHAR2 ) is
l_proc varchar2(200) := g_package || 'final_update_save';
l_eff_date_from         date ;
l_trans_tbl             hr_comp_profile_ss.transaction_table1;
l_action_person_id      number;
l_count                 number default 0;
l_transaction_step_id   number;
l_prev_date             date;
l_prev_start_date       date;
l_competence_element_id number default null;
l_tx_step_id            number default null;
l_preupd_date_to        date;
l_transaction_id        number;
begin
 hr_utility.set_location(' Entering:' || l_proc,5);
 l_transaction_id := hr_transaction_ss.get_transaction_id
                     (p_item_type   => p_item_type
                     ,p_item_key    => p_item_key);
 l_eff_date_from := to_date(p_eff_date_from,g_date_format);
 l_preupd_date_to := l_eff_date_from - 1 ;
 l_action_person_id := p_pid;
 l_transaction_step_id := p_transaction_step_id;
   OPEN get_prev_start_date(p_competence_element_id => p_competence_element_id);
    FETCH get_prev_start_date into l_prev_date;
     IF get_prev_start_date%notfound THEN
       hr_utility.set_location(l_proc,10);
       close get_comp_name;
       raise hr_comp_profile_ss.g_fatal_error;
     END IF;
       close get_prev_start_date;
  l_prev_start_date := l_prev_date;
     update hr_api_transaction_values val
     set val.varchar2_value = 'UPGRADE'
     where val.transaction_step_id in (select val1.transaction_step_id
                                       from hr_api_transaction_values val1,
                                            hr_api_transaction_steps steps
                                   where steps.transaction_id = l_transaction_id
                                   and steps.transaction_step_id = val1.transaction_step_id
                                   and val1.name = 'P_COMPETENCE_ELEMENT_ID'
                                   and val1.number_value = p_competence_element_id)
     and val.name = 'P_CHANGE_MODE'
     and val.varchar2_value = 'UPDATE_HIST';
     l_count := l_count + 1;
     l_trans_tbl(l_count).param_name := 'P_PROFICIENCY_LEVEL_ID';
     l_trans_tbl(l_count).param_value := p_proficiency_level_id;
     l_trans_tbl(l_count).param_data_type := 'NUMBER';
     --
     l_count := l_count + 1;
     l_trans_tbl(l_count).param_name := 'P_STEP_VALUE';
     l_trans_tbl(l_count).param_value := p_step_value;
     l_trans_tbl(l_count).param_data_type := 'NUMBER';
     --
     l_count := l_count + 1;
     l_trans_tbl(l_count).param_name := 'P_CHANGE_MODE';
     l_trans_tbl(l_count).param_value := 'UPGRADE';
     l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
     --
     l_count := l_count + 1;
     l_trans_tbl(l_count).param_name := 'P_EFF_DATE_FROM';
     l_trans_tbl(l_count).param_value := p_eff_date_from;
     l_trans_tbl(l_count).param_data_type := 'DATE';
     --
     l_count := l_count + 1;
     l_trans_tbl(l_count).param_name := 'P_PREV_START_DATE';
     l_trans_tbl(l_count).param_value := to_char(l_prev_start_date,g_date_format);
     l_trans_tbl(l_count).param_data_type := 'DATE';
     l_count := l_count + 1;
     l_trans_tbl(l_count).param_name := 'P_COMPETENCE_ELEMENT_ID';
     l_trans_tbl(l_count).param_value := p_competence_element_id ;
     l_trans_tbl(l_count).param_data_type := 'NUMBER';
-- Competenece Qualification link enhancement
     l_count := l_count + 1;
     l_trans_tbl(l_count).param_name := 'P_STATUS';
     l_trans_tbl(l_count).param_value := p_competence_status ;
     l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
     select number_value into l_competence_element_id
     from hr_api_transaction_values
     where transaction_step_id = l_transaction_step_id
     and NAME = 'P_UPGRADED_FROM_REC_ID';
     select a.transaction_step_id into l_tx_step_id
        from hr_api_transaction_values a,hr_api_transaction_values b,
             hr_api_transaction_steps steps
       where steps.transaction_id = l_transaction_id
         and steps.transaction_step_id = a.transaction_step_id
         and a.name = 'P_CHANGE_MODE'
         and a.varchar2_value = 'UPGRADE'
         and steps.transaction_step_id = b.transaction_step_id
         and b.name = 'P_COMPETENCE_ELEMENT_ID'
         and b.number_value = l_competence_element_id
         and a.transaction_step_id <> l_transaction_step_id;
      if l_tx_step_id is not null then
       hr_utility.set_location(l_proc,15);
        update hr_api_transaction_values
        set date_value = l_preupd_date_to
        where transaction_step_id = l_tx_step_id
        and name = 'P_EFF_DATE_TO';
      end if;
    save_transaction_step
        (p_item_type      => p_item_type
        ,p_item_key       => p_item_key
        ,p_actid          => to_number(p_activity_id)
        ,p_login_person_id => fnd_global.employee_id
        ,p_transaction_step_id => l_transaction_step_id
        ,p_transaction_data    => l_trans_tbl);
   hr_utility.set_location(' Leaving:' || l_proc,20);
   exception
   when others then
     hr_utility.set_location(' Leaving:' || l_proc,555);
     raise g_invalid_entry;
end final_update_save;
-----------------------------------------------------
procedure get_comp_name_alias(
           p_competence_name   in out nocopy varchar2
          ,p_competence_alias  in out nocopy varchar2
          ,p_competence_id     out nocopy varchar2
          ,p_business_group_id in  varchar2) is
l_proc varchar2(200) := g_package || 'get_comp_name_alias';
begin
     hr_utility.set_location(' Entering:' || l_proc,5);
     select upper(rtrim(ltrim(p_competence_name))), upper(rtrim(ltrim(p_competence_alias)))
       into p_competence_name, p_competence_alias
       from dual;
    --
    select name,competence_alias,competence_id into p_competence_name,p_competence_alias,p_competence_id
      from per_competences_vl
     where upper(name) = p_competence_name or upper(competence_alias) = p_competence_alias
       and (business_group_id+0 = p_business_group_id
             or business_group_id is null);
hr_utility.set_location(' Leaving:' || l_proc,10);
exception
 when g_invalid_competence then
    hr_utility.set_location(' Leaving:' || l_proc,555);
    raise g_invalid_competence;
 when others then
     hr_utility.set_location(' Leaving:' || l_proc,560);
    raise ;
end get_comp_name_alias;
-----------------------------
procedure get_lov_comp_id
          (p_competence_name   in varchar2 default null
          ,p_competence_alias  in varchar2 default null
          ,l_competence_id     out nocopy varchar2) is
l_proc varchar2(200) := g_package || 'get_lov_comp_id';
l_name              varchar2(100);
l_alias             varchar2(100);
l_comp_id           varchar2(100);
begin
    hr_utility.set_location(' Entering:' || l_proc,5);
    if p_competence_name is null and p_competence_alias is not null then
      hr_utility.set_location(l_proc,10);
      select competence_id into l_competence_id from per_competences_vl
      where trim(upper(competence_alias)) =  trim(upper(p_competence_alias));
      if sql%notfound then
       hr_utility.set_location(l_proc,15);
       raise g_invalid_competence;
      end if;
    end if;
      hr_utility.set_location(l_proc,20);
    if p_competence_alias is null and p_competence_name is not null then
      hr_utility.set_location(l_proc,25);
      select competence_id into l_competence_id from per_competences_vl
      where trim(upper(name)) =  trim(upper(p_competence_name));
      if sql%notfound then
       hr_utility.set_location(l_proc,30);
       raise g_invalid_competence;
      end if;
    end if;
      hr_utility.set_location(l_proc,35);
    if ((p_competence_name is not null) and (p_competence_alias is not null)) then
          hr_utility.set_location(l_proc,40);
        select competence_id into l_competence_id from per_competences_vl
        where (   (trim(upper(name))) = (trim(upper(p_competence_name)))) or ((trim(upper(competence_alias))) = (trim(upper(p_competence_alias)))     );
      if sql%notfound then
       hr_utility.set_location(l_proc,45);
       raise g_invalid_competence;
      end if;
    end if;
hr_utility.set_location(' Leaving:' || l_proc,50);
exception
 when g_invalid_competence then
 hr_utility.set_location(' Leaving:' || l_proc,555);
    raise g_invalid_competence;
 when others then
 hr_utility.set_location(' Leaving:' || l_proc,560);
    raise g_invalid_competence;
end get_lov_comp_id;
-------------------------------------
PROCEDURE write_add_transaction(
           p_item_type             in varchar2 default null
          ,p_item_key              in varchar2 default null
          ,p_activity_id           in varchar2 default null
          ,p_pid                   in varchar2 default null
          ,p_competence_id         in varchar2 default null
          ,p_competence_name       in varchar2 default null
          ,p_competence_alias      in varchar2 default null
          ,p_proficiency_level_id  in varchar2 default null
          ,p_step_value            in varchar2 default null
          ,p_eff_date_from         in varchar2 default null
          ,p_change_mode           in varchar2 default null
          ,p_row_index             in number default null
          ,p_transaction_step_id   in out nocopy varchar2
          ,p_competence_status     IN VARCHAR2 DEFAULT NULL ) -- Competence Qualification link
          is
  l_proc varchar2(200) := g_package || 'write_add_transaction';
  x_person_id             number default null;
  x_competence_id         number default null;
  x_prof_level_id         number default null;
  x_step_value            number default null;
  l_transaction_id             number default null;
  l_trans_tbl                  hr_comp_profile_ss.transaction_table1;
  l_user_date_format           varchar2(200) default null;
  l_eff_date_from              date default null;
  l_eff_date_to                date default null;
  l_certification_date         date default null;
  l_next_certifctn_date        date default null;
  l_count                      number default 0;
  l_result                     varchar2(100) default null;
  l_trans_obj_vers_num         number default null;
  l_action_person_id           number default null;
begin
    hr_utility.set_location(' Entering:' || l_proc,5);
    if p_pid is not null then
        hr_utility.set_location(' Entering:' || l_proc,10);
        x_person_id             :=  to_number(p_pid);
    end if   ;
    if p_competence_id is not null then
        hr_utility.set_location(' Entering:' || l_proc,15);
        x_competence_id         :=  to_number(p_competence_id);
    end if;
    if p_proficiency_level_id is not null then
       hr_utility.set_location(' Entering:' || l_proc,20);
       x_prof_level_id         :=  to_number(p_proficiency_level_id);
    end if;
    if p_step_value is not null then
         hr_utility.set_location(' Entering:' || l_proc,25);
         x_step_value            :=  to_number(p_step_value);
    end if;
    hr_utility.set_location(' Entering:' || l_proc,30);
    l_action_person_id      := x_person_id;
    g_business_group_id     := hr_util_misc_web.get_business_group_id
                                (p_person_id    => l_action_person_id);
    l_user_date_format      := g_date_format;
    if p_eff_date_from is not null then
         hr_utility.set_location(' Entering:' || l_proc,40);
         l_eff_date_from := to_date(p_eff_date_from, l_user_date_format);
    end if;
    l_transaction_id        := hr_transaction_ss.get_transaction_id
                                     (p_item_type   => p_item_type
                                     ,p_item_key    => p_item_key);
   IF l_transaction_id is null THEN
      hr_utility.set_location(' Entering:' || l_proc,45);
     -- Start a Transaction
     hr_transaction_ss.start_transaction
           (itemtype   => p_item_type
           ,itemkey    => p_item_key
           ,actid      => to_number(p_activity_id)
           ,funmode    => 'RUN'
           ,p_login_person_id => fnd_global.employee_id
           ,result     => l_result);
     l_transaction_id := hr_transaction_ss.get_transaction_id
                        (p_item_type   => p_item_type
                ,p_item_key    => p_item_key);
   END IF;
   -- Create a transaction step
   hr_utility.set_location(' Entering:' || l_proc,50);
   IF p_transaction_step_id is null then
   hr_utility.set_location(' Entering:' || l_proc,55);
   hr_transaction_api.create_transaction_step
     (p_validate              => false
     ,p_creator_person_id     => fnd_global.employee_id
     ,p_transaction_id        => l_transaction_id
     ,p_api_name              => g_api_name
     ,p_item_type             => p_item_type
     ,p_item_key              => p_item_key
     ,p_activity_id           => to_number(p_activity_id)
     ,p_transaction_step_id   => p_transaction_step_id
     ,p_object_version_number => l_trans_obj_vers_num);
    end if;
   --
    hr_utility.set_location(' Entering:' || l_proc,60);
     -- ---------------------------
     -- insert the new rec here
     -- ---------------------------
     l_count := l_count + 1;
     l_trans_tbl(l_count).param_name := 'P_ROW_INDEX';
     l_trans_tbl(l_count).param_value := p_row_index;
     l_trans_tbl(l_count).param_data_type := 'NUMBER';
     l_count := 1;
     l_trans_tbl(l_count).param_name := 'P_PERSON_ID';
     l_trans_tbl(l_count).param_value := l_action_person_id;
     l_trans_tbl(l_count).param_data_type := 'NUMBER';
     --
     l_count := l_count + 1;
     l_trans_tbl(l_count).param_name := 'P_BUSINESS_GROUP_ID';
     l_trans_tbl(l_count).param_value := g_business_group_id;
     l_trans_tbl(l_count).param_data_type := 'NUMBER';
     --
     l_count := l_count + 1;
     l_trans_tbl(l_count).param_name := 'P_COMPETENCE_ELEMENT_ID';
     l_trans_tbl(l_count).param_value := null;
     l_trans_tbl(l_count).param_data_type := 'NUMBER';
     --
     l_count := l_count + 1;
     l_trans_tbl(l_count).param_name := 'P_OBJECT_VERSION_NUMBER';
     l_trans_tbl(l_count).param_value := null;
     l_trans_tbl(l_count).param_data_type := 'NUMBER';
     --
     l_count := l_count + 1;
     l_trans_tbl(l_count).param_name := 'P_COMPETENCE_ID';
     l_trans_tbl(l_count).param_value := x_competence_id;
     l_trans_tbl(l_count).param_data_type := 'NUMBER';
     --
     l_count := l_count + 1;
     l_trans_tbl(l_count).param_name := 'P_COMPETENCE_NAME';
     l_trans_tbl(l_count).param_value := p_competence_name;
     l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
     --
     l_count := l_count + 1;
     l_trans_tbl(l_count).param_name := 'P_PROFICIENCY_LEVEL_ID';
     l_trans_tbl(l_count).param_value := x_prof_level_id;
     l_trans_tbl(l_count).param_data_type := 'NUMBER';
     --
     l_count := l_count + 1;
     l_trans_tbl(l_count).param_name := 'P_STEP_VALUE';
     l_trans_tbl(l_count).param_value := x_step_value;
     l_trans_tbl(l_count).param_data_type := 'NUMBER';
     --
     l_count := l_count + 1;
     l_trans_tbl(l_count).param_name := 'P_PREUPD_PROFICY_LVL_ID';
     l_trans_tbl(l_count).param_value := null;
     l_trans_tbl(l_count).param_data_type := 'NUMBER';
     --
     l_count := l_count + 1;
     l_trans_tbl(l_count).param_name := 'P_EFF_DATE_FROM';
     l_trans_tbl(l_count).param_value := p_eff_date_from;
     l_trans_tbl(l_count).param_data_type := 'DATE';
     --
     l_count := l_count + 1;
     l_trans_tbl(l_count).param_name := 'P_SYSTEM_GENERATED';
     l_trans_tbl(l_count).param_value := 'N';
     l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
     --
     l_count := l_count + 1;
     l_trans_tbl(l_count).param_name := 'P_UPGRADED_FROM_REC_ID';
     l_trans_tbl(l_count).param_value := null;
     l_trans_tbl(l_count).param_data_type := 'NUMBER';
     --
     l_count := l_count + 1;
     l_trans_tbl(l_count).param_name := 'P_COMPETENCE_ALIAS';
     l_trans_tbl(l_count).param_value := p_competence_alias ;
     l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
     l_count := l_count + 1;
     l_trans_tbl(l_count).param_name := 'P_CHANGE_MODE';
     l_trans_tbl(l_count).param_value := p_change_mode;
     l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
     l_count := l_count + 1;
     l_trans_tbl(l_count).param_name := 'P_PREV_STEP_VALUE';
     l_trans_tbl(l_count).param_value := null;
     l_trans_tbl(l_count).param_data_type := 'NUMBER';
     l_count := l_count + 1;
     l_trans_tbl(l_count).param_name := 'P_PREV_START_DATE';
     l_trans_tbl(l_count).param_value := null;
     l_trans_tbl(l_count).param_data_type := 'DATE';
-- Start for Competence Qualification link enhancement
     l_count := l_count + 1;
     l_trans_tbl(l_count).param_name := 'P_PREV_STATUS';
     l_trans_tbl(l_count).param_value := null;
     l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
     l_count := l_count + 1;
     l_trans_tbl(l_count).param_name := 'P_STATUS';
     l_trans_tbl(l_count).param_value := p_competence_status;
     l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
-- End for Competence Qualification link enhancement
      save_transaction_step
        (p_item_type      => p_item_type
        ,p_item_key       => p_item_key
        ,p_actid          => to_number(p_activity_id)
        ,p_login_person_id => fnd_global.employee_id
        ,p_transaction_step_id => p_transaction_step_id
        ,p_api_name => g_api_name
        ,p_transaction_data    => l_trans_tbl);
hr_utility.set_location(' Leaving:' || l_proc,65);
exception
 when others then
    hr_utility.set_location(' Leaving:' || l_proc,555);
    raise g_invalid_entry;
end write_add_transaction;
--------------------------------------------
-- to check valid proposed level entered manually by user on update main page
procedure validate_updated_row
          (p_competence_id    in varchar2
          ,p_step_value       in varchar2
          ,p_person_id        in varchar2
          ,p_eff_date_from    in varchar2 default null
          ,r_step_value       out nocopy varchar2
          ,r_new_prof_level   out nocopy varchar2
          ,p_item_type        in varchar2 default null
          ,p_item_key         in varchar2 default null
          ,p_activity_id      in varchar2 default null
          ,p_error_message    out nocopy varchar2) is
l_proc varchar2(200) := g_package || 'validate_updated_row';
l_step_value        varchar2(10):= Null;
l_new_prof_level    varchar2(10):= Null ;
x_eff_date_from     date;
x_eff_date_to       date;
x_cer_date          date;
x_next_cer_date     date;
l_count     number;
begin
    hr_utility.set_location(' Entering:' || l_proc,5);
    l_count := 0;
    update_date_validate (p_person_id => p_person_id
                         ,p_competence_id => p_competence_id
                         ,p_eff_date_from => p_eff_date_from
                         ,p_error_message => p_error_message);
    IF p_step_value IS NOT NULL Then
            select ratl.step_value,ratl.rating_level_id
            into l_step_value,l_new_prof_level
            from per_competences_vl cvl, per_rating_levels ratl
            where ((ratl.competence_id = cvl.competence_id and cvl.competence_id = p_competence_id)
            or (cvl.rating_scale_id = ratl.rating_scale_id and cvl.competence_id = p_competence_id))
            and ratl.step_value = p_step_value;
            r_step_value     := l_step_value ;
            r_new_prof_level := l_new_prof_level;
    END if;
hr_utility.set_location(' Leaving:' || l_proc,10);
-- added for competency start date > outcome start date
        Select count(*) INTO l_count
        FROM hr_api_transaction_steps S,
        hr_api_transaction_values A,
        hr_api_transaction_values C,
        hr_api_transaction_values D
        Where s.item_type = p_item_type
             and s.item_key = p_item_key
             and s.activity_id = nvl((p_activity_id),s.activity_id)
        and s.api_name = 'HR_COMP_OUTCOME_PROFILE_SS.PROCESS_API'
        AND c.transaction_step_id = s.transaction_step_id
        AND c.NAME = 'P_COMPETENCE_ID'
        AND c.number_value = p_competence_id
        AND a.transaction_step_id = s.transaction_step_id
        AND a.NAME = 'P_DATE_FROM'
        AND d.transaction_step_id = s.transaction_step_id
        AND d.NAME = 'P_PERSON_ID'
        AND d.number_value = p_person_id
        AND a.date_value < to_date(p_eff_date_from, g_date_format);

        IF (l_count > 0) Then
            p_error_message := hr_java_conv_util_ss.get_formatted_error_message(
                               p_error_message => p_error_message,
                               p_attr_name     => 'PropStartDate',
                               p_app_short_name => 'PER',
                               P_SINGLE_ERROR_MESSAGE => 'HR_OUT_ACHVD_DT_INVL');
           return;
        END if;

--
exception
 when no_data_found then
  hr_utility.set_location(' Leaving:' || l_proc,555);
  If p_step_value is not null then
    hr_utility.set_location(' Leaving:' || l_proc,560);
    p_error_message := hr_java_conv_util_ss.get_formatted_error_message(
                               p_error_message => p_error_message,
                               p_attr_name     => 'PropLevel',
                               p_app_short_name => 'PER',
                               P_SINGLE_ERROR_MESSAGE => 'HR_COMP_INV_LEVEL_SS');
  else
          Select count(*) INTO l_count
        FROM hr_api_transaction_steps S,
        hr_api_transaction_values A,
        hr_api_transaction_values C,
        hr_api_transaction_values D
        Where s.item_type = p_item_type
             and s.item_key = p_item_key
             and s.activity_id = nvl((p_activity_id),s.activity_id)
        and s.api_name = 'HR_COMP_OUTCOME_PROFILE_SS.PROCESS_API'
        AND c.transaction_step_id = s.transaction_step_id
        AND c.NAME = 'P_COMPETENCE_ID'
        AND c.number_value = p_competence_id
        AND a.transaction_step_id = s.transaction_step_id
        AND a.NAME = 'P_DATE_FROM'
        AND d.transaction_step_id = s.transaction_step_id
        AND d.NAME = 'P_PERSON_ID'
        AND d.number_value = p_person_id
        AND a.date_value < to_date(p_eff_date_from, g_date_format);

        IF (l_count > 0) Then
            p_error_message := hr_java_conv_util_ss.get_formatted_error_message(
                               p_error_message => p_error_message,
                               p_attr_name     => 'PropStartDate',
                               p_app_short_name => 'PER',
                               P_SINGLE_ERROR_MESSAGE => 'HR_OUT_ACHVD_DT_INVL');
           return;
        END if;
  End If;
  r_step_value := p_step_value;
 when others then
  hr_utility.set_location(' Leaving:' || l_proc,565);
  raise ;
end validate_updated_row;
-------------------------------------------------
procedure set_name_alias
          (p_competence_id   in varchar2 default null
          ,l_competence_name   out nocopy varchar2
          ,l_competence_alias  out nocopy varchar2) is
l_proc varchar2(200) := g_package || 'set_name_alias';
begin
    hr_utility.set_location(' Entering:' || l_proc,5);
    select name,competence_alias
    into l_competence_name,l_competence_alias from per_competences_vl
    where competence_id = p_competence_id;
    hr_utility.set_location(' Leaving:' || l_proc,10);
exception
 when others then
  hr_utility.set_location(' Leaving:' || l_proc,555);
  null ;
  raise ;
end set_name_alias;
--
procedure set_parameters(
          p_competence_id        in out nocopy varchar2
         ,p_competence_name      in out nocopy varchar2
         ,p_competence_alias     in out nocopy varchar2
         ,p_step_value           in out nocopy varchar2
         ,p_prof_level_id        in out nocopy varchar2
         ,p_business_group_id    in varchar2
         -- bug 2946360 fix
         ,p_item_type            in varchar2 default null
         ,p_item_key             in varchar2 default null
         ,p_person_id            in number default null
         ,p_dup_comp_not_exists  out nocopy varchar2
         -- bug 2946360 fix
         -- bug fix 4136402
         ,p_eff_date_from          in varchar2 default null
         ,p_eff_date_to            in varchar2 default null
         ,p_activity_id            in varchar2 default null
         -- bug fix 4136402
         ,p_error_message        out nocopy long) is
l_proc varchar2(200) := g_package || 'set_parameters';
l_count   number;
 Cursor get_comp_dates ( p_competence_id IN Number )is
    select to_date(date_from, g_date_format) start_date
    from   per_competences_vl
    where  competence_id = p_competence_id;
 --bug 2946360 Fix
 cursor c1 is
     select 'F' status
     from hr_api_transaction_steps s, hr_api_transaction_values a,
          hr_api_transaction_values b, hr_api_transaction_values d
     Where s.item_type = p_item_type
     and s.item_key  = p_item_key
     and s.transaction_step_id = a.transaction_step_id
     and s.transaction_step_id = b.transaction_step_id
     and s.transaction_step_id = d.transaction_step_id
     and a.name = 'P_COMPETENCE_ID' and a.number_value = p_competence_id
     and b.name = 'P_PERSON_ID' and b.number_value = p_person_id
     and d.name = 'P_CHANGE_MODE' and d.varchar2_value <> 'ADD'
     union
     select 'F' status from hr_api_transaction_steps ts, hr_api_transactions t
     where ts.api_name = 'HR_COMP_PROFILE_SS.PROCESS_API'
     and ts.transaction_id = t.transaction_id
     and t.selected_person_id = p_person_id and t.status = 'Y'
     and exists (Select 'e' From hr_api_transaction_values c
                 Where c.transaction_step_id = ts.transaction_step_id
                 and c.name = 'P_COMPETENCE_ID'
                and c.number_value = p_competence_id)
     union
     Select 'F' status from per_competence_elements pce
     where pce.person_id = p_person_id
     and pce.type = 'PERSONAL'
     and trunc(sysdate) between nvl(pce.effective_date_from,sysdate)
     and nvl(pce.effective_date_to,sysdate)
     and pce.competence_id = p_competence_id;
   l_dup_comp_not_exists varchar(1);
   --bug 2946360 Fix
 l_comp_dates_cur get_comp_dates%RowType;
 l_competence_name  per_competences_vl.name%TYPE;
 l_competence_alias per_competences_vl.competence_alias%TYPE;
 --
 begin
   hr_utility.set_location(' Entering:' || l_proc,5);
   l_count := 0;
   select rtrim(ltrim(p_competence_name)), rtrim(ltrim(p_competence_alias)), rtrim(ltrim(p_competence_id)), rtrim(ltrim(p_step_value))
     into p_competence_name, p_competence_alias, p_competence_id, p_step_value
     from dual;
   If p_competence_id is not null and p_competence_name is null Then
      hr_utility.set_location(l_proc,10);
      p_error_message := hr_java_conv_util_ss.get_formatted_error_message(
                         p_error_message => p_error_message,
                         p_attr_name     => 'Name',
                         p_app_short_name => 'PER',
                         P_SINGLE_ERROR_MESSAGE => 'HR_ADD_COMP_IS_NULL_SS');
     raise g_invalid_entry;
   End If;
      hr_utility.set_location(l_proc,15);
    If p_competence_id is not null then
          hr_utility.set_location(l_proc,20);
         select name, competence_alias
           into l_competence_name, l_competence_alias
           from per_competences_vl
          where competence_id = p_competence_id;
   End if;
      hr_utility.set_location(l_proc,25);
   If (l_competence_name <> p_competence_name or l_competence_alias <> p_competence_alias) Or
       ((p_competence_id is null) And (p_competence_name is not null or p_competence_alias is not null)) Then
   Begin
         hr_utility.set_location(l_proc,30);
       select name, competence_alias, competence_id
       into p_competence_name,p_competence_alias,p_competence_id
       from   per_competences_vl
       where upper(name) = nvl(upper(p_competence_name), upper(name))
       and nvl(upper(competence_alias),'#') = nvl(upper(p_competence_alias), nvl(upper(competence_alias),'#'))
       and (business_group_id+0 = p_business_group_id or business_group_id is null);
       Exception when OTHERS then
               hr_utility.set_location(l_proc,555);
         p_error_message := hr_java_conv_util_ss.get_formatted_error_message(
                            p_error_message => p_error_message,
                            p_attr_name     => 'Name',
                            p_app_short_name => 'PER',
                            P_SINGLE_ERROR_MESSAGE => 'HR_COMP_INVALID_NAME_ALIAS_SS');
         raise g_invalid_entry;
       End;
   End If;
      hr_utility.set_location(l_proc,35);
   If p_step_value is not null then
       Begin
                hr_utility.set_location(l_proc,40);
            select per_rating_levels.step_value ,per_rating_levels.rating_level_id
              into p_step_value,p_prof_level_id
              from per_competences_vl, per_rating_levels
             where ((per_rating_levels.competence_id = per_competences_vl.competence_id
                or per_competences_vl.rating_scale_id = per_rating_levels.rating_scale_id)
               and (per_competences_vl.competence_id = p_competence_id) and (per_rating_levels.step_value = p_step_value))
               and (per_competences_vl.business_group_id+0 = p_business_group_id
                    or per_competences_vl.business_group_id is null);
       Exception when OTHERS then
             hr_utility.set_location(l_proc,560);
         p_error_message := hr_java_conv_util_ss.get_formatted_error_message(
                            p_error_message => p_error_message,
                            p_attr_name     => 'ProfLevel',
                            p_app_short_name => 'PER',
                            P_SINGLE_ERROR_MESSAGE => 'HR_COMP_INV_LEVEL_SS');
         raise g_invalid_entry;
       End;

        --FOR bug fix 4136402
   End If;
        Select count(*) INTO l_count
        FROM hr_api_transaction_steps S,
        hr_api_transaction_values A,
        hr_api_transaction_values C,
        hr_api_transaction_values D
        Where s.item_type = p_item_type
             and s.item_key = p_item_key
             and s.activity_id = nvl((p_activity_id),s.activity_id)
        and s.api_name = 'HR_COMP_OUTCOME_PROFILE_SS.PROCESS_API'
        AND c.transaction_step_id = s.transaction_step_id
        AND c.NAME = 'P_COMPETENCE_ID'
        AND c.number_value = p_competence_id
        AND a.transaction_step_id = s.transaction_step_id
        AND a.NAME = 'P_DATE_FROM'
        AND d.transaction_step_id = s.transaction_step_id
        AND d.NAME = 'P_PERSON_ID'
        AND d.number_value = p_person_id
        AND a.date_value < to_date(p_eff_date_from, g_date_format);

        IF (l_count > 0) Then
            p_error_message := 'HR_OUT_ACHVD_DT_INVL';
           return;
        END if;

    IF (p_eff_date_to IS NOT null) then
        Select count(*) INTO l_count
        FROM hr_api_transaction_steps S,
        hr_api_transaction_values A,
        hr_api_transaction_values C,
        hr_api_transaction_values D
        Where s.item_type = p_item_type
             and s.item_key = p_item_key
             and s.activity_id = nvl((p_activity_id),s.activity_id)
        and s.api_name = 'HR_COMP_OUTCOME_PROFILE_SS.PROCESS_API'
        AND c.transaction_step_id = s.transaction_step_id
        AND c.NAME = 'P_COMPETENCE_ID'
        AND c.number_value = p_competence_id
        AND a.transaction_step_id = s.transaction_step_id
        AND a.NAME = 'P_DATE_TO'
        AND d.transaction_step_id = s.transaction_step_id
        AND d.NAME = 'P_PERSON_ID'
        AND d.number_value = p_person_id
        AND nvl(a.date_value,to_date(p_eff_date_to, g_date_format)) > to_date(p_eff_date_to, g_date_format);

        IF (l_count > 0) Then
            p_error_message := 'HR_OUT_ACHVD_DT_INVL';
           return;
        END if;
        -- end for bug fix 4136402
   END if;

        hr_utility.set_location(l_proc,45);
 -- bug 2946360 fix
     For I in c1 Loop
             hr_utility.set_location(l_proc || 'LOOP' ,50);
        If (I.status = 'F') then
                   hr_utility.set_location(l_proc,55);
             l_dup_comp_not_exists := I.status;
             Exit;
        End If;
     End Loop;
           hr_utility.set_location(l_proc,60);
    IF l_dup_comp_not_exists IS NOT NULL
    THEN
          hr_utility.set_location(l_proc,65);
    p_dup_comp_not_exists := l_dup_comp_not_exists;
    ELSE
          hr_utility.set_location(l_proc,70);
    p_dup_comp_not_exists := 'T';
    END IF;
 -- bug 2946360 fix
hr_utility.set_location(' Leaving:' || l_proc,75);
 Exception
  when g_invalid_entry then
  hr_utility.set_location(' Leaving:' || l_proc,565);
   null;
  when others then
  hr_utility.set_location(' Leaving:' || l_proc,570);
   raise;
 end set_parameters;
------------------------------------------------
------------------------------------------------
procedure set_upd_parameters
          (p_competence_id         in varchar2 default null
          ,p_step_value           in varchar2 default null) is
l_proc varchar2(200) := g_package || 'set_upd_parameters';
l_step_value    varchar2(20);
l_prof_level_id varchar2(20);
begin
    hr_utility.set_location(' Entering:' || l_proc,5);
    if p_step_value is not null then
    hr_utility.set_location(l_proc,10);
    select per_rating_levels.step_value ,per_rating_levels.rating_level_id
    into l_step_value,l_prof_level_id
    from per_competences_vl, per_rating_levels
    where ((per_rating_levels.competence_id = per_competences_vl.competence_id or per_competences_vl.rating_scale_id = per_rating_levels.rating_scale_id)
    and (per_competences_vl.competence_id = p_competence_id) and (per_rating_levels.step_value = p_step_value) );
        if sql%notfound then
          hr_utility.set_location(l_proc,15);
          raise g_invalid_competence;
        end if;
    end if;
hr_utility.set_location(' Leaving:' || l_proc,20);
 exception
  when g_invalid_competence then
       hr_utility.set_location(' Leaving:' || l_proc,555);
       raise g_invalid_competence;
  when others then
       hr_utility.set_location(' Leaving:' || l_proc,560);
       raise g_invalid_competence;
 end set_upd_parameters;
---------------------------------------------------------------
Procedure delete_add_page
          (transaction_step_ids in varchar2) is
l_proc varchar2(200) := g_package || 'delete_add_page';
len number;
j   varchar(10) ;
begin
hr_utility.set_location(' Entering:' || l_proc,5);
j := ' ';
len := length(transaction_step_ids);
for i in 1..len loop
hr_utility.set_location(l_proc || 'LOOP' , 10);
if substr(transaction_step_ids,i,1) = ',' then
  hr_utility.set_location(l_proc , 15);
-- Calling the procedure to delete related transaction step ids for outcome.
/*  HR_COMP_OUTCOME_PROFILE_SS.delete_add_page(
        p_transaction_step_id  => to_number(j)); */
  delete from hr_api_transaction_values where transaction_step_id = to_number(j);
  delete from hr_api_transaction_steps where transaction_step_id = to_number(j);
  j := '' ;
else
  hr_utility.set_location(l_proc , 20);
  j := j || substr(transaction_step_ids,i,1);
end if;
end loop;
commit;
hr_utility.set_location(' Leaving:' || l_proc,25);
end delete_add_page;
---------------------------------------------------------------
procedure add_to_addition(p_item_type in varchar2
                         ,p_item_key  in varchar2) is
l_proc varchar2(200) := g_package || 'add_to_addition';
l_transaction_id number;
begin
   hr_utility.set_location(' Entering:' || l_proc,5);
   l_transaction_id := hr_transaction_ss.get_transaction_id
                     (p_item_type   => p_item_type
                     ,p_item_key    => p_item_key);
   update hr_api_transaction_values val
        set val.varchar2_value = 'ADDITION'
    where transaction_step_id in (select transaction_step_id
                                  from hr_api_transaction_steps steps
                                  where steps.transaction_id = l_transaction_id)
    and val.name = 'P_CHANGE_MODE' and val.varchar2_value = 'ADD';
hr_utility.set_location(' Leaving:' || l_proc,10);
end add_to_addition;
-------------------------------------------------------------
procedure update_date_validate
          (p_person_id in varchar2 default null
          ,p_competence_id in varchar2 default null
          ,p_eff_date_from in varchar2 default null
          ,p_error_message out nocopy varchar2) is
l_proc varchar2(200) := g_package || 'update_date_validate';
l_eff_date_from     date    default null;
l_start_date        date;
begin
    hr_utility.set_location(' Entering:' || l_proc,5);
    l_start_date := to_date(p_eff_date_from,g_date_format) ;
    if l_start_date > trunc(sysdate) then
      hr_utility.set_location( l_proc,10);
      p_error_message := hr_java_conv_util_ss.get_formatted_error_message(
                           p_error_message => p_error_message,
                           p_attr_name     => 'PropStartDate',
                           p_app_short_name => 'PER',
                           P_SINGLE_ERROR_MESSAGE => 'HR_COMP_ADD_ERR_START_DATE_SS');
    Else
      begin
        hr_utility.set_location( l_proc,15);
        select max(effective_date_from)
        into l_eff_date_from
        from per_competence_elements
        where person_id = to_number(p_person_id)
        and competence_id = to_number(p_competence_id) group by competence_id;
        if l_start_date <= l_eff_date_from then
          hr_utility.set_location( l_proc,20);
          p_error_message := hr_java_conv_util_ss.get_formatted_error_message(
                               p_error_message => p_error_message,
                               p_attr_name     => 'PropStartDate',
                               p_app_short_name => 'PER',
                               --'HR_COMP_UPD_ERR_START_DATE_SS'
                               P_SINGLE_ERROR_MESSAGE => 'HR_WEB_CEL_START_DATES_INVL');
        end if;
      end;
    end if;
hr_utility.set_location(' Leaving:' || l_proc,25);
exception
 when others then
 hr_utility.set_location(' Leaving:' || l_proc,555);
  null;
  raise g_invalid_entry;
end update_date_validate;
-------------------------------
procedure ex_comp_date_validation
          (p_person_id         in varchar2
          ,p_competence_id    in varchar2
          ,p_eff_date_from    in varchar2) is
l_proc varchar2(200) := g_package || 'ex_comp_date_validation';
l_eff_date_from     date default null;
m_eff_date_to     date default null;
begin
hr_utility.set_location(' Entering:' || l_proc,5);
l_eff_date_from := to_date(p_eff_date_from,g_date_format);
    select effective_date_to
    into m_eff_date_to
    from per_competence_elements
    where person_id = p_person_id
    and competence_id = p_competence_id
    and effective_date_to < trunc(sysdate);
    if SQL%FOUND then
        hr_utility.set_location(l_proc,10);
        if l_eff_date_from < m_eff_date_to then
          hr_utility.set_location(l_proc,15);
          raise g_invalid_competence;
        end if;
    end if;
hr_utility.set_location(' Leaving:' || l_proc,20);
end ex_comp_date_validation;
--------------------------------------------------------
----------------------------------------------------------------------------
Procedure write_proc_actid
          (p_item_type          in varchar2
          ,p_item_key           in varchar2
          ,p_activity_id        in varchar2
          ,p_person_id          in varchar2
          ,p_review_proc_call   in varchar2) is
l_proc varchar2(200) := g_package || 'write_proc_actid';
cursor c1 is
  select transaction_step_id
  from hr_api_transaction_steps
  where item_type = p_item_type
  and   item_key  = p_item_key
  and   activity_id  = p_activity_id;
l_step_values       c1%rowtype;
l_index             number;
l_count             number := 0;
l_trans_tbl         hr_comp_profile_ss.transaction_table1;
l_transaction_step_id   number;
begin
  hr_utility.set_location(' Entering:' || l_proc,5);
  l_index := 0;
  open c1 ;
   loop
        hr_utility.set_location(l_proc || 'LOOP' ,10);
        fetch c1 into l_step_values;
        exit when c1%notfound;
     l_count := 1;
     l_trans_tbl(l_count).param_name := 'P_REVIEW_PROC_CALL';
     l_trans_tbl(l_count).param_value := p_review_proc_call;
     l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
     --
     l_count := l_count + 1;
     l_trans_tbl(l_count).param_name := 'P_REVIEW_ACTID';
     l_trans_tbl(l_count).param_value := p_activity_id;
     l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
--     l_transaction_step_id := l_step_values.transaction_step_id;
     save_transaction_step
        (p_item_type      => p_item_type
        ,p_item_key       => p_item_key
        ,p_actid          => to_number(p_activity_id)
        ,p_login_person_id => fnd_global.employee_id
        ,p_transaction_step_id => l_step_values.transaction_step_id
        ,p_api_name => g_api_name
        ,p_transaction_data    => l_trans_tbl);
   end loop ;
  close c1;
hr_utility.set_location(' Leaving:' || l_proc,15);
end write_proc_actid;
--====================================================================================
Procedure api_validate_competence_record(
          p_validate              in boolean default null
          ,p_person_id             in number
          ,p_business_group_id     in number default null
          ,p_change_mode           in varchar2 default null
          ,p_competence_element_id in number default null
          ,p_preupd_obj_vers_num   in number default null
          ,p_competence_id         in number default null
          ,p_proficiency_level_id  in number default null
          ,p_eff_date_from         in varchar2 default null
          ,p_eff_date_to           in varchar2 default null
          ,p_proficy_lvl_source    in varchar2 default null
          ,p_certification_mthd    in varchar2 default null
          ,p_certification_date    in varchar2 default null
          ,p_next_certifctn_date   in varchar2 default null
          ,p_competence_status     IN VARCHAR2 DEFAULT null
          ,p_eff_date_from_date_type  out nocopy date
          ,p_eff_date_to_date_type    out nocopy date
          ,p_certifctn_date_type      out nocopy date
          ,p_next_certifctn_date_type out nocopy date
          ,p_error_message            out nocopy long) is
  --
  l_proc varchar2(200) := g_package || 'api_validate_competence_record';
  l_user_date_format           varchar2(200):=g_date_format;
  l_date_error                 boolean default false;
  l_eff_date_from              date default null;
  l_eff_date_to                date default null;
  l_preupd_date_to             date default null;
  l_new_competence_element_id  number default null;
  l_new_obj_vers_num           number default null;
  l_next_certification_date    date default null;
  l_certification_date         date default null;
  l_object_version_number      number default null;
  l_action_person_id           number default null;
  --
Begin
    hr_utility.set_location(' Entering:' || l_proc,5);
    l_action_person_id := p_person_id;
  Begin
    hr_utility.set_location( l_proc,10);
    IF p_eff_date_from is not null THEN
       hr_utility.set_location(l_proc,15);
       l_eff_date_from := to_date(p_eff_date_from, l_user_date_format);
    END IF;
    IF l_eff_date_from > trunc(sysdate) THEN
          hr_utility.set_location(l_proc,20);
          p_error_message := hr_java_conv_util_ss.get_formatted_error_message(
                             p_error_message => p_error_message,
                             p_attr_name     => 'CurrStartDate',
                             p_app_short_name => 'PER',
                             P_SINGLE_ERROR_MESSAGE => 'HR_WEB_DISALLOW_FUTURE_STARTDT');
          l_date_error := true;
    END IF;
    hr_utility.set_location(l_proc,25);
    EXCEPTION
      When others then
          hr_utility.set_location(l_proc,555);
          IF  hr_message.last_message_name = 'HR_51648_CEL_PER_DATES_OVLAP'  then
          p_error_message := hr_java_conv_util_ss.get_formatted_error_message
                             (p_error_message => p_error_message,
                              p_attr_name     => 'CurrStartDate',
                              p_app_short_name => 'PER',
                              P_SINGLE_ERROR_MESSAGE  => 'HR_51648_CEL_PER_DATES_OVLAP');
          else
          p_error_message := hr_java_conv_util_ss.get_formatted_error_message
                             (p_error_message => p_error_message,
                              p_attr_name     => 'CurrStartDate',
                              p_app_short_name => 'PER',
                              P_SINGLE_ERROR_MESSAGE  => SQLERRM ||' '||to_char(SQLCODE));

          END if;
          l_date_error := true;
  END;
  Begin
    hr_utility.set_location(l_proc,30);
    IF p_eff_date_to is not null THEN
       hr_utility.set_location(l_proc,35);
       l_eff_date_to := to_date(p_eff_date_to, l_user_date_format);
    END IF;
    IF l_eff_date_from is not null then
       hr_utility.set_location(l_proc,40);
         IF l_eff_date_to < l_eff_date_from THEN
          hr_utility.set_location(l_proc,45);
          p_error_message := hr_java_conv_util_ss.get_formatted_error_message(
                             p_error_message => p_error_message,
                             p_attr_name     => 'EndDate',
                             p_app_short_name => 'PER',
                             P_SINGLE_ERROR_MESSAGE => 'HR_WEB_CEL_DATES_INVL');
          l_date_error := true;
       END IF;
    End IF;
    EXCEPTION
      When others then
         hr_utility.set_location(l_proc,560);
         p_error_message := hr_java_conv_util_ss.get_formatted_error_message
                            (p_error_message => p_error_message,
                             p_attr_name     => 'EndDate',
                             p_app_short_name => 'PER',
                             P_SINGLE_ERROR_MESSAGE      => SQLERRM ||' '||to_char(SQLCODE));
         l_date_error := true;
  END;
  Begin
    hr_utility.set_location(l_proc,50);
    IF p_certification_date is not null THEN
       hr_utility.set_location(l_proc,55);
       l_certification_date :=to_date(p_certification_date, l_user_date_format);
       IF p_certification_mthd is null THEN
          hr_utility.set_location(l_proc,60);
          p_error_message := hr_java_conv_util_ss.get_formatted_error_message(
                             p_error_message => p_error_message,
                             p_attr_name     => 'MeasuredBy',
                             p_app_short_name => 'PER',
                             P_SINGLE_ERROR_MESSAGE => 'HR_WEB_CERTFCTN_METHOD_NULL');
          l_date_error := true;
       END IF;
    END IF;
    --
    EXCEPTION
      When others then
         hr_utility.set_location(l_proc,565);
         p_error_message := hr_java_conv_util_ss.get_formatted_error_message
                            (p_error_message => p_error_message,
                             p_attr_name     => 'CertificationDate',
                             p_app_short_name => 'PER',
                             P_SINGLE_ERROR_MESSAGE => SQLERRM ||' '||to_char(SQLCODE));
        l_date_error := true;
  END;
  --
  -- next_certification_date
  Begin
    hr_utility.set_location(l_proc,65);
    IF p_next_certifctn_date is not null THEN
       hr_utility.set_location(l_proc,70);
       l_next_certification_date := to_date(p_next_certifctn_date, l_user_date_format);
    END IF;
    --
    EXCEPTION
      When others then
         hr_utility.set_location(l_proc,570);
         p_error_message := hr_java_conv_util_ss.get_formatted_error_message
                            (p_error_message => p_error_message,
                             p_attr_name     => 'NextReviewDate',
                             p_app_short_name => 'PER',
                             P_SINGLE_ERROR_MESSAGE => SQLERRM ||' '||to_char(SQLCODE));
          l_date_error := true;
  END;
  --
  --------------------------------------------------------------------
  -- Now, if no date format error, we proceed to call api for cross
  -- validations.
  --------------------------------------------------------------------
  savepoint validate_competence_rec;
  hr_utility.set_location(l_proc,75);
   IF l_date_error THEN
     hr_utility.set_location(l_proc,80);
     goto finish_processing;
   END IF;
  --
 -- UPGRADE
 IF upper(p_change_mode) = hr_comp_profile_ss.g_upgrade_proficiency_mode  THEN
     hr_utility.set_location(l_proc,85);
     l_preupd_date_to := l_eff_date_from - 1;
     l_object_version_number := p_preupd_obj_vers_num;
     --
     per_cel_upd.upd(p_validate               => false
                    ,p_competence_element_id  => p_competence_element_id
                    ,p_object_version_number  => l_object_version_number
                    ,p_effective_date_to      => l_preupd_date_to
                    ,p_status                 => p_competence_status
                    ,p_effective_date         => trunc(sysdate));
     per_cel_ins.ins(p_validate               => false
                    ,p_competence_element_id  => l_new_competence_element_id
                    ,p_business_group_id      => p_business_group_id
                    ,p_object_version_number  => l_new_obj_vers_num
                    ,p_type                   => 'PERSONAL'
                    ,p_person_id              => l_action_person_id
                    ,p_competence_id          => p_competence_id
                    ,p_effective_date_from    => l_eff_date_from
                    ,p_effective_date_to      => l_eff_date_to
                    ,p_proficiency_level_id   => p_proficiency_level_id
                    ,p_source_of_proficiency_level => p_proficy_lvl_source
                    ,p_certification_method   => p_certification_mthd
                    ,p_certification_date     => l_certification_date
                    ,p_next_certification_date     => l_next_certification_date
                    ,p_status                  => p_competence_status
                    ,p_effective_date         => trunc(sysdate));
 -- CORRECT
  ELSIF upper(p_change_mode) = hr_comp_profile_ss.g_upd_mode THEN
      hr_utility.set_location(l_proc,90);
      l_object_version_number := p_preupd_obj_vers_num;
      per_cel_upd.upd(p_validate               => false
                    ,p_competence_element_id  => p_competence_element_id
                    ,p_object_version_number  => l_object_version_number
                    ,p_effective_date_from    => l_eff_date_from
                    ,p_effective_date_to      => l_eff_date_to
                    ,p_proficiency_level_id   => p_proficiency_level_id
                    ,p_source_of_proficiency_level => p_proficy_lvl_source
                    ,p_certification_method   => p_certification_mthd
                    ,p_certification_date     => l_certification_date
                    ,p_next_certification_date     => l_next_certification_date
                    ,p_status                 => p_competence_status
                    ,p_effective_date         => trunc(sysdate));
ELSE -- Add New Record Mode
     hr_utility.set_location(l_proc,95);
     per_cel_ins.ins(p_validate               => false
                    ,p_competence_element_id  => l_new_competence_element_id
                    ,p_business_group_id      => p_business_group_id
                    ,p_object_version_number  => l_new_obj_vers_num
                    ,p_type                   => 'PERSONAL'
                    ,p_person_id              => l_action_person_id
                    ,p_competence_id          => p_competence_id
                    ,p_effective_date_from    => l_eff_date_from
                    ,p_effective_date_to      => l_eff_date_to
                    ,p_proficiency_level_id   => p_proficiency_level_id
                    ,p_source_of_proficiency_level => p_proficy_lvl_source
                    ,p_certification_method    => p_certification_mthd
                    ,p_certification_date      => l_certification_date
                    ,p_next_certification_date => l_next_certification_date
                    ,p_status                  => p_competence_status
                    ,p_effective_date          => trunc(sysdate));
  END IF;
  --
  hr_utility.set_location(l_proc,100);
  IF p_validate = true THEN
     hr_utility.set_location(l_proc,105);
     rollback to validate_competence_rec;
  END IF;
  --
  --
  <<finish_processing>>
  --
  hr_utility.set_location(l_proc,110);
  if l_date_error then
    hr_utility.set_location(l_proc,115);
    rollback to validate_competence_rec;
  end if;
  p_eff_date_from_date_type  := l_eff_date_from;
  p_eff_date_to_date_type    := l_eff_date_to;
  p_certifctn_date_type      := l_certification_date;
  p_next_certifctn_date_type := l_next_certification_date;
  --
  hr_utility.set_location(' Leaving:' || l_proc,120);
  EXCEPTION
    When g_invalid_entry then
         hr_utility.set_location(' Leaving:' || l_proc,575);
         rollback to validate_competence_rec;
    When others then
      hr_utility.set_location(' Leaving:' || l_proc,580);
      rollback to validate_competence_rec;
      hr_message.provide_error;
      IF hr_message.last_message_name = 'HR_51612_CEL_BUS_GROUP_ID_INVL' THEN
         hr_utility.set_location(' Leaving:' || l_proc,585);
         p_error_message := hr_java_conv_util_ss.get_formatted_error_message
           (p_error_message => p_error_message
           ,p_message_name      => hr_message.get_message_text ||' '||hr_message.last_message_number);
      ELSIF hr_message.last_message_name = 'HR_51615_CEL_PROF_ID_INVL' THEN
         hr_utility.set_location(' Leaving:'  || l_proc,590);
         p_error_message := hr_java_conv_util_ss.get_formatted_error_message
           (p_error_message => p_error_message
           ,p_attr_name     => 'ProfLevel'
           ,p_message_name      => hr_message.get_message_text ||' '||hr_message.last_message_number);
      ELSIF hr_message.last_message_name = 'HR_51636_CEL_CERTIF_INVL' THEN
         hr_utility.set_location(' Leaving:' ||  l_proc,595);
         p_error_message := hr_java_conv_util_ss.get_formatted_error_message
           (p_error_message => p_error_message
           ,p_attr_name  => 'MeasuredBy'
           ,p_message_name      => hr_message.get_message_text ||' '||hr_message.last_message_number);
      ELSIF hr_message.last_message_name = 'HR_51637_CEL_CERF_DATE_METHOD' THEN
         hr_utility.set_location(' Leaving:' || l_proc,600);
         p_error_message := hr_java_conv_util_ss.get_formatted_error_message
           (p_error_message => p_error_message
           ,p_attr_name   => 'CertificationDate'
           ,p_app_short_name    => 'PER'
           ,p_message_name     => 'HR_WEB_CEL_CERF_DATE_METHOD');
      ELSIF hr_message.last_message_name = 'HR_51639_CEL_SOURCE_PROF_LVL' THEN
         hr_utility.set_location(' Leaving:' || l_proc,605);
         p_error_message := hr_java_conv_util_ss.get_formatted_error_message
           (p_error_message => p_error_message
           ,p_attr_name  => 'AcquiredBy'
           ,p_message_name      => hr_message.get_message_text ||' '||hr_message.last_message_number);
      ELSIF hr_message.last_message_name = 'HR_51615_CEL_PROF_ID_INVL' THEN
         hr_utility.set_location(' Leaving:' || l_proc,610);
         p_error_message := hr_java_conv_util_ss.get_formatted_error_message
           (p_error_message => p_error_message
           ,p_attr_name  => 'ProfLevel'
           ,p_message_name      => hr_message.get_message_text ||' '||hr_message.last_message_number);
      ELSIF hr_message.last_message_name = 'HR_51642_COMP_ID_MANDATORY' THEN
         hr_utility.set_location(' Leaving:' || l_proc,615);
         p_error_message := hr_java_conv_util_ss.get_formatted_error_message
           (p_error_message => p_error_message
           ,p_attr_name  => 'CompId'
           ,p_message_name      => hr_message.get_message_text ||' '||hr_message.last_message_number);
      ELSIF hr_message.last_message_name = 'HR_51647_CEL_DATES_INVL' THEN
         hr_utility.set_location(' Leaving:' || l_proc,620);
         IF upper(p_change_mode) =
              hr_comp_profile_ss.g_upgrade_proficiency_mode
            and (p_eff_date_to is null  or
                 to_date(p_eff_date_from, l_user_date_format) <=
                 to_date(p_eff_date_to, l_user_date_format))THEN
                 hr_utility.set_location(' Leaving:' || l_proc,625);
            p_error_message := hr_java_conv_util_ss.get_formatted_error_message
              (p_error_message => p_error_message
              ,p_attr_name  => 'CurrStartDate'
              ,p_app_short_name    => 'PER'
              ,p_message_name     => 'HR_WEB_CEL_START_DATES_INVL');
         ELSE
            hr_utility.set_location(' Leaving:' || l_proc,630);
            p_error_message := hr_java_conv_util_ss.get_formatted_error_message
              (p_error_message => p_error_message
              ,p_attr_name  => 'EndDate'
              ,p_app_short_name    => 'PER'
              ,p_message_name     => 'HR_WEB_CEL_DATES_INVL');
         END IF;
      ELSIF hr_message.last_message_name = 'HR_51648_CEL_PER_DATES_OVLAP' THEN
         hr_utility.set_location(' Leaving:' || l_proc,635);
         p_error_message := hr_java_conv_util_ss.get_formatted_error_message
           (p_error_message => p_error_message
           ,p_attr_name  => 'CurrStartDate'
           ,p_app_short_name    => 'PER'
           ,p_message_name => 'HR_51648_CEL_PER_DATES_OVLAP');
-- modified for 4142672 rpahune
--           ,p_message_name      => hr_message.get_message_text ||' '||hr_message.last_message_number);
      ELSIF hr_message.last_message_name = 'HR_51670_CEL_PER_TYPE_ERROR' THEN
         hr_utility.set_location(' Leaving:' || l_proc,640);
         IF p_competence_id is null THEN
            hr_utility.set_location(' Leaving:' || l_proc,645);
            p_error_message := hr_java_conv_util_ss.get_formatted_error_message
              (p_error_message => p_error_message
              ,p_attr_name  => 'CompId'
              ,p_message_name      => hr_message.get_message_text ||' '||hr_message.last_message_number);
         ELSE
            hr_utility.set_location(' Leaving:' || l_proc,650);
            p_error_message := hr_java_conv_util_ss.get_formatted_error_message
              (p_error_message => p_error_message
              ,p_attr_name  => 'CurrStartDate'
              ,p_message_name      => hr_message.get_message_text ||' '||hr_message.last_message_number);
         END IF;
         hr_utility.set_location(' Leaving:' || l_proc,655);
      ELSIF hr_message.last_message_name = 'HR_52268_CEL_UNIQUE_PERSONAL' THEN
         hr_utility.set_location(' Leaving:' || l_proc,660);
         p_error_message := hr_java_conv_util_ss.get_formatted_error_message
           (p_error_message => p_error_message
           ,p_attr_name  => 'CompId'
           ,p_app_short_name    => 'PER'
           ,p_message_name     => 'HR_WEB_CEL_UNIQUE_PERSONAL');
      ELSIF hr_message.last_message_name = 'HR_52339_COMP_ELMT_DATE_INVL' THEN
         hr_utility.set_location(' Leaving:' || l_proc,665);
         p_error_message := hr_java_conv_util_ss.get_formatted_error_message
           (p_error_message => p_error_message
           ,p_attr_name  => 'CurrStartDate'
           ,p_app_short_name => 'PER'
           ,p_message_name => 'HR_52339_COMP_ELMT_DATE_INVL');
      ELSIF hr_message.last_message_name = 'PER_52861_CHK_NEXT_CERT_DATE' THEN
         hr_utility.set_location(' Leaving:' || l_proc,670);
         p_error_message := hr_java_conv_util_ss.get_formatted_error_message
           (p_error_message => p_error_message
           ,p_attr_name  => 'NextReviewDate'
           ,p_app_short_name => 'PER'
           ,p_message_name => 'PER_52861_CHK_NEXT_CERT_DATE');
      ELSE
         hr_utility.set_location(' Leaving:' || l_proc,675);
         p_error_message := hr_java_conv_util_ss.get_formatted_error_message
           (p_error_message => p_error_message
           ,p_attr_name  => null
           ,p_message_name      => hr_message.get_message_text ||' '||hr_message.last_message_number);
      END IF;
      hr_utility.set_location(' Leaving:' || l_proc,680);
End api_validate_competence_record;
--
-- ------------------------------------------------------------------------
-- ---------------------<check_if_cmptnce_rec_changed>---------------------
-- ------------------------------------------------------------------------
-- Purpose: This procedure will compare the values of the rec with the
--          values before update.
--          The caller has made sure that this procedure is called only on an
--          update or upgrade to new proficiency level mode.
--          IF the proficiency level is the same as pre-update value, it
--          will set an output parm to true if the p_change_mode is
--          upgrade a proficiency level.
-- ------------------------------------------------------------------------
Procedure check_if_cmptnce_rec_changed
          (p_competence_element_id   in number
          ,p_competence_id           in number
          ,p_proficiency_level_id    in number default null
          ,p_eff_date_from           in date default null
          ,p_eff_date_to             in date default null
          ,p_proficy_lvl_source      in varchar2 default null
          ,p_certification_mthd      in varchar2 default null
          ,p_certification_date      in date default null
          ,p_next_certifctn_date     in date default null
          ,p_change_mode             in varchar2
          ,p_ignore_warning          in varchar2 default null
          ,p_comments                in varchar2 default null
          ,p_competence_status       in varchar2 default null
          ,p_rec_changed             out nocopy boolean)  is
  --
  l_proc varchar2(200) := g_package || 'check_if_cmptnce_rec_changed';
  cursor csr_get_preupd_cmptnce_rec is
  select competence_element_id
        ,competence_id
        ,proficiency_level_id
        ,effective_date_from
        ,effective_date_to
        ,certification_date
        ,certification_method
        ,next_certification_date
        ,source_of_proficiency_level
        ,comments
        ,status
  from  per_competence_elements
  where competence_element_id = p_competence_element_id;
  --
  l_changed             boolean default null;
  --
  --
Begin
  hr_utility.set_location(' Entering:' || l_proc,5);
  l_changed := false;
  --
  FOR l_preupd_rec IN csr_get_preupd_cmptnce_rec LOOP
      hr_utility.set_location( l_proc || 'LOOP' , 10);
      IF l_preupd_rec.competence_id = p_competence_id THEN
         hr_utility.set_location( l_proc , 15);
         null;
      ELSE
         hr_utility.set_location( l_proc , 20);
         raise hr_comp_profile_ss.g_fatal_error;
      END IF;
      --
      IF nvl(l_preupd_rec.proficiency_level_id,'-99') = nvl(p_proficiency_level_id,'-99') THEN
        hr_utility.set_location( l_proc , 25);
        null;
      ELSE
        hr_utility.set_location( l_proc , 30);
        l_changed := true;
      END IF;
      --
      IF l_preupd_rec.effective_date_from is not null THEN
         hr_utility.set_location( l_proc , 35);
         IF l_preupd_rec.effective_date_from = p_eff_date_from THEN
            hr_utility.set_location( l_proc , 40);
            null;
         ELSE
            hr_utility.set_location( l_proc , 45);
            l_changed := true;
         END IF;
      ELSE  -- pre-update is null
         hr_utility.set_location( l_proc , 50);
         IF p_eff_date_from is not null THEN
            hr_utility.set_location( l_proc , 55);
            l_changed := true;
         END IF;
      END IF;
      --
      IF l_preupd_rec.effective_date_to is not null THEN
         hr_utility.set_location( l_proc , 60);
         ---------------------------------------------------------------------
         -- Only issue a warning if the new eff_date_to is different and is
         -- not null.
         ---------------------------------------------------------------------
         IF l_preupd_rec.effective_date_to = p_eff_date_to THEN
            hr_utility.set_location( l_proc , 65);
            null;
         ELSE
            hr_utility.set_location( l_proc , 70);
            l_changed := true;
            --
         END IF;
      ELSE  -- pre-update is null
         hr_utility.set_location( l_proc , 75);
         IF p_eff_date_to is not null THEN
            hr_utility.set_location( l_proc , 80);
            l_changed := true;
            --
         END IF;
      END IF;
      --
      IF l_preupd_rec.comments is not null THEN
         hr_utility.set_location( l_proc , 85);
         IF l_preupd_rec.comments = p_comments THEN
            hr_utility.set_location( l_proc , 90);
            null;
         ELSE
            hr_utility.set_location( l_proc , 95);
            l_changed := true;
         END IF;
      ELSE  -- pre-update is null
         hr_utility.set_location( l_proc , 100);
         IF p_comments is not null THEN
            hr_utility.set_location( l_proc , 105);
            l_changed := true;
         END IF;
      END IF;
      --
      IF l_preupd_rec.certification_date is not null THEN
         hr_utility.set_location( l_proc , 110);
         IF l_preupd_rec.certification_date = p_certification_date THEN
            hr_utility.set_location( l_proc , 115);
            null;
         ELSE
            hr_utility.set_location( l_proc , 120);
            l_changed := true;
         END IF;
      ELSE  -- pre-update is null
         hr_utility.set_location( l_proc , 125);
         IF p_certification_date is not null THEN
            hr_utility.set_location( l_proc , 130);
            l_changed := true;
         END IF;
      END IF;
      --
      IF l_preupd_rec.certification_method is not null THEN
         hr_utility.set_location( l_proc , 135);
         IF l_preupd_rec.certification_method = p_certification_mthd THEN
            hr_utility.set_location( l_proc , 140);
            null;
         ELSE
            hr_utility.set_location( l_proc , 145);
            l_changed := true;
         END IF;
      ELSE  -- pre-update is null
         hr_utility.set_location( l_proc , 150);
         IF p_certification_mthd is not null THEN
            hr_utility.set_location( l_proc , 155);
            l_changed := true;
         END IF;
      END IF;
      --
      hr_utility.set_location( l_proc , 160);
      IF l_preupd_rec.next_certification_date is not null THEN
         hr_utility.set_location( l_proc , 165);
         IF l_preupd_rec.next_certification_date = p_next_certifctn_date THEN
            hr_utility.set_location( l_proc , 170);
            null;
         ELSE
            hr_utility.set_location( l_proc , 175);
            l_changed := true;
         END IF;
      ELSE  -- pre-update is null
         hr_utility.set_location( l_proc , 180);
         IF p_next_certifctn_date is not null THEN
            hr_utility.set_location( l_proc , 185);
            l_changed := true;
         END IF;
      END IF;
      --
      hr_utility.set_location( l_proc , 190);
      IF l_preupd_rec.source_of_proficiency_level is not null THEN
         hr_utility.set_location( l_proc , 195);
         IF l_preupd_rec.source_of_proficiency_level = p_proficy_lvl_source THEN
           hr_utility.set_location( l_proc , 200);
            null;
         ELSE
            hr_utility.set_location( l_proc , 205);
            l_changed := true;
         END IF;
      ELSE  -- pre-update is null
         hr_utility.set_location( l_proc , 210);
         IF p_proficy_lvl_source is not null THEN
            hr_utility.set_location( l_proc , 215);
            l_changed := true;
         END IF;
      END IF;
/* Start Competence Qualification Link enhancement */
/* commented for bug no 4188501 */
/*      IF l_preupd_rec.status IS NOT NULL then
         hr_utility.set_location( l_proc , 216);
         IF l_preupd_rec.status = p_competence_status THEN
            hr_utility.set_location( l_proc , 217);
            null;
         ELSE
            hr_utility.set_location( l_proc , 218);
            l_changed := true;
         END if;
      ELSE
            hr_utility.set_location( l_proc , 219);
         IF p_competence_status is not null THEN
            hr_utility.set_location( l_proc , 220);
            l_changed := true;
         END IF;
      END if; */
/* End Competence Qualification Link enhancement */
   END LOOP;
   --
   p_rec_changed := l_changed;
--   p_warning_exists := l_warning_exists;
   --
   hr_utility.set_location(' Leaving:' || l_proc,220);
   Exception
     When others then
       hr_utility.set_location(' Leaving:' || l_proc,555);
       raise;
   --
End check_if_cmptnce_rec_changed;
--
Procedure get_correction_trans_values
          (p_item_type             in varchar2
          ,p_item_key              in varchar2
          ,p_competence_element_id in number
          ,p_proficiency_level_id  out nocopy number
          ,p_start_date            out nocopy date
          ,p_end_date              out nocopy date
          ,p_justification         out nocopy varchar2
          ,p_acquired_by           out nocopy varchar2
          ,p_measured_by           out nocopy varchar2
          ,p_ceritification_date   out nocopy varchar2
          ,p_next_review_date      out nocopy varchar2) is
l_proc varchar2(200) := g_package || 'get_correction_trans_values';
Begin
hr_utility.set_location(' Entering:' || l_proc,5);
null;
hr_utility.set_location(' Leaving:' || l_proc,10);
End;
--
-- ***** Start new code for bug 2719381 **************
/*==============================================================
 | PUBLIC function get_preferred_prof_range
 |
 | DESCRIPTION
 |    This function will get the proficiency range for a given
 |    competence and person id.
 |
 | PARAMETERS
 |  p_person_id         Person Id
 |  p_competence_name   Competence Name
 |
 | RETURNS
 |  Proficiency Range
 |
 | MODIFICATION HISTORY
 | Date            Author         Description of Changes
 | 10-OCT-2001     Krmenon        Created
 *==============================================================*/
Function get_preferred_prof_range
    (p_person_id      in varchar2
    ,p_competence_id  in number) Return VARCHAR2 is
l_proc varchar2(200) := g_package || 'get_preferred_prof_range';
    Cursor csr_bg_profrange is
        Select rl1.step_value || decode(rl1.name, '', '', ' ' || rl1.name) minprof,
               rl2.step_value || decode(rl2.name, '', '', ' ' || rl2.name) maxprof
        From per_competence_elements pce, per_all_assignments_f paaf,
             per_rating_levels rl1, per_rating_levels rl2
        Where paaf.person_id = p_person_id
        And trunc(sysdate) between paaf.effective_start_date and paaf.effective_end_date
        And pce.enterprise_id = paaf.business_group_id
        And pce.competence_id = p_competence_id
        And pce.type = 'REQUIREMENT'
        And trunc(sysdate) between nvl(pce.effective_date_from,sysdate) and nvl(pce.effective_date_to,sysdate)
        And proficiency_level_id = rl1.rating_level_id (+)
        And high_proficiency_level_id = rl2.rating_level_id (+);
    Cursor csr_job_profrange is
        Select rl1.step_value || decode(rl1.name, '', '', ', ' || rl1.name) minprof,
               rl2.step_value || decode(rl2.name, '', '', ', ' || rl2.name) maxprof
        From per_competence_elements pce, per_all_assignments_f paaf,
             per_rating_levels rl1, per_rating_levels rl2
        Where paaf.person_id = p_person_id
        And trunc(sysdate) between paaf.effective_start_date and paaf.effective_end_date
        And pce.job_id = paaf.job_id
        And pce.competence_id = p_competence_id
        And pce.type = 'REQUIREMENT'
        And trunc(sysdate) between nvl(pce.effective_date_from,sysdate) and nvl(pce.effective_date_to,sysdate)
        And proficiency_level_id = rl1.rating_level_id (+)
        And high_proficiency_level_id = rl2.rating_level_id (+);
    Cursor csr_pos_profrange is
        Select rl1.step_value || decode(rl1.name, '', '', ', ' || rl1.name) minprof,
               rl2.step_value || decode(rl2.name, '', '', ', ' || rl2.name) maxprof
        From per_competence_elements pce, per_all_assignments_f paaf,
             per_rating_levels rl1, per_rating_levels rl2
        Where paaf.person_id = p_person_id
        And trunc(sysdate) between paaf.effective_start_date and paaf.effective_end_date
        And pce.position_id = paaf.position_id
        And pce.competence_id = p_competence_id
        And pce.type = 'REQUIREMENT'
        And trunc(sysdate) between nvl(pce.effective_date_from,sysdate) and nvl(pce.effective_date_to,sysdate)
        And proficiency_level_id = rl1.rating_level_id (+)
        And high_proficiency_level_id = rl2.rating_level_id (+);
    Cursor csr_org_profrange is
        Select rl1.step_value || decode(rl1.name, '', '', ', ' || rl1.name) minprof,
               rl2.step_value || decode(rl2.name, '', '', ', ' || rl2.name) maxprof
        From per_competence_elements pce, per_all_assignments_f paaf,
             per_rating_levels rl1, per_rating_levels rl2
        Where paaf.person_id = p_person_id
        And trunc(sysdate) between paaf.effective_start_date and paaf.effective_end_date
        And pce.organization_id = paaf.organization_id
        And pce.competence_id = p_competence_id
        And pce.type = 'REQUIREMENT'
        And trunc(sysdate) between nvl(pce.effective_date_from,sysdate) and nvl(pce.effective_date_to,sysdate)
        And proficiency_level_id = rl1.rating_level_id (+)
        And high_proficiency_level_id = rl2.rating_level_id (+);
Begin
    hr_utility.set_location(' Entering:' || l_proc,5);
    -- If the input parameters are null, return null
    If ( p_person_id is null OR p_competence_id is null ) Then
        hr_utility.set_location(' Leaving:' || l_proc,10);
        return null;
    End If;
    For I in csr_pos_profrange Loop
      hr_utility.set_location(l_proc || 'LOOP' ,15);
      if (I.minprof is not null Or I.maxprof is not null) then
       hr_utility.set_location(' Leaving:' || l_proc,20);
       return I.minprof ||' -- ' || I.maxprof;
      end if;
    End Loop;
    hr_utility.set_location( l_proc,25);
    For I in csr_job_profrange Loop
      hr_utility.set_location(l_proc || 'LOOP' ,30);
      if (I.minprof is not null Or I.maxprof is not null) then
       hr_utility.set_location(' Leaving:' || l_proc,35);
       return I.minprof ||' -- ' || I.maxprof;
      end if;
    End Loop;
    hr_utility.set_location( l_proc,40);
    For I in csr_org_profrange Loop
      hr_utility.set_location(l_proc || 'LOOP' ,45);
      if (I.minprof is not null Or I.maxprof is not null) then
       hr_utility.set_location(' Leaving:' || l_proc,50);
       return I.minprof ||' -- ' || I.maxprof;
      end if;
    End Loop;
    hr_utility.set_location( l_proc,55);
    For I in csr_bg_profrange Loop
      hr_utility.set_location(l_proc || 'LOOP' ,60);
      if (I.minprof is not null Or I.maxprof is not null) then
       hr_utility.set_location(' Leaving:' || l_proc,65);
       return I.minprof ||' -- ' || I.maxprof;
      end if;
    End Loop;
    hr_utility.set_location(' Leaving:' || l_proc,70);
    return null;
    Exception
        when others then
            hr_utility.set_location(' Leaving:' || l_proc,555);
            return null;
End;
-- ***** End new code for bug 2719381 **************
--
/*==============================================================
 | PUBLIC function is_proficiency_requred
 |
 |    This function will check if the proficiency is a necessity
 |
 | PARAMETERS
 |  p_person_id         Person Id
 |  p_competence_name   Competence Name
 |
 | RETURNS
 |  Y/N
 |
 | MODIFICATION HISTORY
 | Date            Author         Description of Changes
 | 10-OCT-2001     Krmenon        Created
 *==============================================================*/
Function is_proficiency_required
    (p_person_id      in varchar2
    ,p_competence_id  in number) Return VARCHAR2 is
    l_proc varchar2(200) := g_package || 'is_proficiency_required';
    /*------------------------------------------------------------+
     | Cursor to fetch the preffered proficiency range for a      |
     | given person and competence.                               |
     +------------------------------------------------------------*/
    Cursor prof_rec is
        Select 'Y'
        From per_competence_elements pce, per_all_assignments_f paaf, per_competences pc
        Where paaf.person_id = p_person_id
        And trunc(sysdate) between paaf.effective_start_date and paaf.effective_end_date
        And pc.competence_id = p_competence_id
        And pce.competence_id = pc.competence_id
        And pce.type = 'REQUIREMENT'
        And pce.mandatory = 'Y'
        And trunc(sysdate) between nvl(pce.effective_date_from,sysdate) and nvl(pce.effective_date_to,sysdate)
        And (pce.job_id = paaf.job_id
             Or pce.organization_id = paaf.organization_id
             Or pce.position_id = paaf.position_id
             Or pce.enterprise_id = paaf.business_group_id);
    l_rec       prof_rec%RowType;
    l_return    varchar2(10) default null;
Begin
    hr_utility.set_location(' Entering:' || l_proc,5);
    -- If the input parameters are null, return null
    If ( p_person_id is null OR p_competence_id is null ) Then
        hr_utility.set_location(' Leaving:' || l_proc,10);
        Return l_return;
    End If;
    Open prof_rec;
    Fetch prof_rec Into l_rec;
    If prof_rec%NOTFOUND Then
        l_return := 'No';
    Else
        l_return := 'Yes';
    End If;
    Close prof_rec;
    hr_utility.set_location(' Leaving:' || l_proc,15);
    Return l_return;
    Exception
        When OTHERS Then
            hr_utility.set_location(' Leaving:' || l_proc,555);
            l_return := 'Yes';
            If prof_rec%ISOPEN Then
                hr_utility.set_location(' Leaving:' || l_proc,560);
                Close prof_rec;
            End If;
            Return l_return;
End;
--
--Added this function to get the partyId 7409924

function get_party_id
  (p_person_id   in number,
   p_business_group_id in number
   ) return number is
  l_proc constant varchar2(100) := g_package || ' get_party_id';
--

cursor csr_party_id is
 select party_id
   from per_all_people_f
      where person_id = p_person_id
        and business_group_id=p_business_group_id
        and sysdate between effective_start_date and effective_end_date;
 l_party_id per_all_people_f.party_id%type;
 begin
hr_utility.set_location('Entering: '|| l_proc,5);
open csr_party_id;
fetch csr_party_id into l_party_id;
if csr_party_id%found then
 return l_party_id;
else
 return null;
end if;
hr_utility.set_location('Leaving: '|| l_proc,10);
exception
  when others then
  hr_utility.set_location('EXCEPTION: '|| l_proc,555);
    -- the TRANSACTION_ID doesn't exist as an item so return null
    return(null);
end get_party_id;
--
End hr_comp_profile_ss;

/
