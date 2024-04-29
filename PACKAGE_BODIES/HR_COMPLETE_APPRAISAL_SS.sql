--------------------------------------------------------
--  DDL for Package Body HR_COMPLETE_APPRAISAL_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_COMPLETE_APPRAISAL_SS" AS
/* $Header: hrcpappr.pkb 120.5.12010000.7 2010/02/16 14:22:42 psugumar ship $*/
--
-- To modify this template, edit file PKGBODY.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package body
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ------------------------------------------
   -- Enter procedure, function bodies as shown below

   lv_no_appraisal exception;
   TYPE cur_typ IS REF CURSOR;
   -- Global cursor for getting objectives for appraisal_id
   CURSOR get_appr_objectives(p_appraisal_id in number) IS
   SELECT objective_id,
	  name,
	  target_date,
	  start_date,
	  business_group_id,
	  object_version_number,
	  owning_person_id,
	  achievement_date,
	  detail,
	  comments,
	  success_criteria,
	  appraisal_id,
	  attribute_category,
	  attribute1,
	  attribute2,
	  attribute3,
	  attribute4,
	  attribute5,
	  attribute6,
	  attribute7,
	  attribute8,
	  attribute9,
	  attribute10,
	  attribute11,
	  attribute12,
	  attribute13,
	  attribute14,
	  attribute15,
	  attribute16,
	  attribute17,
	  attribute18,
	  attribute19,
	  attribute20,
	  attribute21,
	  attribute22,
	  attribute23,
	  attribute24,
	  attribute25,
	  attribute26,
	  attribute27,
	  attribute28,
	  attribute29,
	  attribute30,
	  scorecard_id,
	  copied_from_library_id,
	  copied_from_objective_id,
	  aligned_with_objective_id,
	  next_review_date,
	  group_code,
	  priority_code,
	  appraise_flag,
	  verified_flag,
	  weighting_percent,
	  complete_percent,
	  target_value,
	  actual_value,
	  uom_code,
	  measurement_style_code,
	  measure_name,
	  measure_type_code,
	  measure_comments,
	  sharing_access_code
   FROM per_objectives
   WHERE appraisal_id = p_appraisal_id;
   -- table type for appraisal objectives
   TYPE appr_obj_table IS TABLE OF get_appr_objectives%ROWTYPE INDEX BY BINARY_INTEGER ;

PROCEDURE set_appr_status_log (item_type IN varchar2,
                               item_key IN varchar2,
                               status IN varchar2,
                               attr_name IN varchar2,
                               l_log IN varchar2 )
                               IS
    lv_status    varchar2(4000);

BEGIN
    if( (wf_engine.GetItemAttrText(item_type, item_key, gv_appr_compl_status, true) is null) or
        (wf_engine.GetItemAttrText(item_type, item_key, gv_appr_compl_status, true) = 'W')) then
        wf_engine.setitemattrtext(item_type, item_key, gv_appr_compl_status, status);
    end if;
    wf_engine.setitemattrtext(item_type, item_key, attr_name, l_log);
EXCEPTION
    WHEN others then
        raise;
END;


FUNCTION is_new_appraisal (item_type IN varchar2,
                           item_key IN varchar2)
RETURN Boolean IS
BEGIN
    if hr_workflow_service.item_attribute_exists
                (p_item_type => item_type
                ,p_item_key  => item_key
                ,p_name      => 'HR_COMPETENCE_ENHANCEMENT_SS') then
        RETURN true;
    end if;

    RETURN false;
EXCEPTION
    WHEN others THEN
        raise;
END;


PROCEDURE generate_event
    (
     p_overall_perf_rating varchar2,
     p_review_date date,
     p_result varchar2,
     p_reason varchar2,
     p_log in out nocopy varchar2,
     p_new_appraisal in boolean DEFAULT true
     )
IS
BEGIN
   if p_new_appraisal then
      p_log := p_overall_perf_rating || '^' || p_review_date || '^' || p_result || '^' || p_reason;
   else
      p_log := p_log ||
        '<br> <br> <table width="100%" summary="" border="0" cellspacing="0" cellpadding="0"> <tr valign="top">' ||
        '<td align="left" width="70%">' ||
        '<div><div class="x60">' ||
        '<table cellpadding="0" cellspacing="0" border="0" width="100%" summary="">' ||
        '<tr><td width="100%"> <h1 class="x18">'|| hr_util_misc_web.return_msg_text(
                                   p_message_name =>'HR_APPRAISAL_EVENT',
                                   p_Application_id  =>'PER') || '</h1></td></tr>' ||
        '<tr><td class="x2i"></td></tr>' ||
        '</table></div>'||
        '<script>t(void 0,''5'')</script>' ||
        '<table cellpadding="0" cellspacing="0" border="0" width="80%" summary="">' ||
        '<tr>' ||
        '<td>' ||
        '<table class="x1h" cellpadding="1" cellspacing="0" border="0" width="100%">' ||
        '<tr>' ||
        '<th scope="col" class="x1r">' || hr_util_misc_web.return_msg_text(
                                   p_message_name =>'HR_APPR_PERF_LEVEL',
                                   p_Application_id  =>'PER') ||'</th>' ||
        '<th scope="col" class="x1r x4j">' || hr_util_misc_web.return_msg_text(
                                   p_message_name =>'HR_PERF_REVIEW_DATE',
                                   p_Application_id  =>'PER') ||' </th>' ||
        '<th scope="col" class="x1r x4j">' || hr_util_misc_web.return_msg_text(
                                   p_message_name =>'HR_RESULT',
                                   p_Application_id  =>'PER') ||'</th>' ||
        '<th scope="col" class="x1r x4j">' || hr_util_misc_web.return_msg_text(
                                   p_message_name =>'HR_REASON',
                                   p_Application_id  =>'PER') ||'</th>' ||
        '</tr>' ||
        '<tr> ' ||
        '<td class="x1l x4x" nowrap>' || p_overall_perf_rating || '</td>' ||
        '<td class="x1l x4x" nowrap>' || p_review_date || '</td>' ||
        '<td class="x1l x4x">'        || p_result || '</td>' ||
        '<td class="x1l x4x">'        || p_reason || '</td>' ||
        '</tr>' ||
        '</table>' ||
        '</td>' ||
        '</tr>' ||
        '</table>' ||
        '</div> <div></div>' ||
        '<script>t(''10'')</script>' ||
        '</td>' ||
        '</tr>' ||
        '</table>';
   end if;
END;


PROCEDURE generate_appraisal_status
    (appraisal_date per_appraisals.appraisal_date%TYPE,
     appraisee_name per_all_people_f.full_name%TYPE,
     appraisal_status hr_lookups.meaning%TYPE,
     appraisal_type hr_lookups.meaning%TYPE,
     result fnd_new_messages.message_text%TYPE,
     reason varchar2,
     p_log in out nocopy varchar2
     )
IS
BEGIN

   p_log := p_log ||
        '<br> <br> <table width="100%" summary="" border="0" cellspacing="0" cellpadding="0"> <tr valign="top">' ||
        '<td align="left" width="70%">' ||
        '<div><div class="x60">' ||
        '<table cellpadding="0" cellspacing="0" border="0" width="100%" summary="">' ||
        '<tr><td width="100%"> <h1 class="x18">'|| hr_util_misc_web.return_msg_text(
                                   p_message_name =>'HR_APPRAISAL_STATUS',
                                   p_Application_id  =>'PER') || '</h1></td></tr>' ||
        '<tr><td class="x2i"></td></tr>' ||
        '</table></div>'||
        '<script>t(void 0,''5'')</script>' ||
        '<table cellpadding="0" cellspacing="0" border="0" width="80%" summary="">' ||
        '<tr>' ||
        '<td>' ||
        '<table class="x1h" cellpadding="1" cellspacing="0" border="0" width="100%">' ||
        '<tr>' ||
        '<th scope="col" class="x1r">' || hr_util_misc_web.return_msg_text(
                                   p_message_name =>'HR_APPRAISAL_DATE',
                                   p_Application_id  =>'PER') ||'</th>' ||
        '<th scope="col" class="x1r x4j">' || hr_util_misc_web.return_msg_text(
                                   p_message_name =>'HR_APPRAISEE',
                                   p_Application_id  =>'PER') ||' </th>' ||
        '<th scope="col" class="x1r x4j">' || hr_util_misc_web.return_msg_text(
                                   p_message_name =>'HR_APPRAISAL_TYPE',
                                   p_Application_id  =>'PER') ||'</th>' ||
        '<th scope="col" class="x1r x4j">' || hr_util_misc_web.return_msg_text(
                                   p_message_name =>'HR_STATUS',
                                   p_Application_id  =>'PER') ||'</th>' ||
        '<th scope="col" class="x1r x4j">' || hr_util_misc_web.return_msg_text(
                                   p_message_name =>'HR_RESULT',
                                   p_Application_id  =>'PER') ||'</th>' ||
        '<th scope="col" class="x1r x4j">' || hr_util_misc_web.return_msg_text(
                                   p_message_name =>'HR_REASON',
                                   p_Application_id  =>'PER') ||'</th>' ||
        '</tr>' ||
        '<tr> ' ||
        '<td class="x1l x4x" nowrap>' || appraisal_date || '</td>' ||
        '<td class="x1l x4x" nowrap>' || appraisee_name || '</td>' ||
        '<td class="x1l x4x">'        || appraisal_type || '</td>' ||
        '<td class="x1l x4x">'        || appraisal_status || '</td>' ||
        '<td class="x1l x4x">'        || result || '</td>' ||
        '<td class="x1l x4x">'        || reason || '</td>' ||
        '</tr>' ||
        '</table>' ||
        '</td>' ||
        '</tr>' ||
        '</table>' ||
        '</div> <div></div>' ||
        '<script>t(''10'')</script>' ||
        '</td>' ||
        '</tr>' ||
        '</table>';

END;

PROCEDURE change_appr_status
    ( appr_id per_appraisals.appraisal_id%TYPE,
      item_type IN varchar2,
      item_key IN varchar2,
      p_log  in out nocopy varchar2,
      chg_appr_status in out nocopy varchar2 )
    IS

    cursor get_appraisal_info(appr_id per_appraisals.appraisal_id%TYPE) IS
    select appr.appraisal_id, appr.object_version_number,
    appr.appraiser_person_id, appr.appraisee_person_id, ppf.full_name,
    appr.appraisal_date, apprstatus.meaning appraisal_status, apprtype.meaning appraisal_type,
    nvl(appr.provide_overall_feedback,'N') provide_overall_feedback, appr.appraisal_system_status
    from per_appraisals appr, per_all_people_f ppf, hr_lookups apprstatus,
    hr_lookups apprtype
    where appr.appraisal_id = appr_id
    and ppf.person_id = appr.appraisee_person_id
    and trunc(sysdate) between ppf.effective_start_date and ppf.effective_end_date
    and apprstatus.lookup_type = 'APPRAISAL_SYSTEM_STATUS'
    and apprstatus.lookup_code = appr.appraisal_system_status
    and apprtype.lookup_type = 'APPRAISAL_SYS_TYPE'
    and apprtype.lookup_code = appr.system_type;

    cursor get_appraisal_status(appr_id per_appraisals.appraisal_id%TYPE) IS
    select hrl.meaning
    from per_appraisals appr, hr_lookups hrl
    where appraisal_id = appr_id
    and hrl.lookup_type = 'APPRAISAL_SYSTEM_STATUS'
    and appr.appraisal_system_status = hrl.lookup_code;


    TYPE appraisal_rec is RECORD (
        appraisal_id per_appraisals.appraisal_id%TYPE,
        object_version_number per_appraisals.object_version_number%TYPE,
        appraiser_person_id per_appraisals.appraiser_person_id%TYPE,
        appraisee_person_id per_appraisals.appraisee_person_id%TYPE,
        full_name per_all_people_f.full_name%TYPE,
        appraisal_date per_appraisals.appraisal_date%TYPE,
        apprstatus hr_lookups.meaning%TYPE,
        apprtype hr_lookups.meaning%TYPE,
	provide_overall_feedback per_appraisals.provide_overall_feedback%TYPE,
	appraisal_system_status per_appraisals.appraisal_system_status%TYPE
    );

    appraisal_record appraisal_rec;
    error_message varchar2(500) default null;
    lv_appr_result_status hr_lookups.meaning%TYPE;

   BEGIN

        hr_multi_message.enable_message_list;

        open get_appraisal_info(appr_id);
        fetch get_appraisal_info into appraisal_record;
        if get_appraisal_info%NOTFOUND then
            close get_appraisal_info;
            raise lv_no_appraisal;
        else
           close get_appraisal_info;
        -- update the appraisal status to completed.

	    if( appraisal_record.appraisal_system_status <> 'APPRFEEDBACK')
            then
                if( appraisal_record.provide_overall_feedback <> 'Y' )
                then
                  chg_appr_status := 'N' ;
                 hr_appraisals_api.update_appraisal
                 (p_effective_date           => trunc(sysdate)
                  ,p_appraisal_id             => appraisal_record.appraisal_id
                  ,p_object_version_number    => appraisal_record.object_version_number
                  ,p_appraiser_person_id		 => appraisal_record.appraiser_person_id
                  ,p_appraisal_system_status     => 'COMPLETED');
                else
                  chg_appr_status := 'Y' ;
                  hr_appraisals_api.update_appraisal
                 (p_effective_date           => trunc(sysdate)
                  ,p_appraisal_id             => appraisal_record.appraisal_id
                  ,p_object_version_number    => appraisal_record.object_version_number
                  ,p_appraiser_person_id		 => appraisal_record.appraiser_person_id
                  ,p_appraisal_system_status     => 'APPRFEEDBACK');
                end if ;
            elsif( appraisal_record.appraisal_system_status <> 'COMPLETED')
            then
                hr_appraisals_api.update_appraisal
                 (p_effective_date           => trunc(sysdate)
                  ,p_appraisal_id             => appraisal_record.appraisal_id
                  ,p_object_version_number    => appraisal_record.object_version_number
                  ,p_appraiser_person_id		 => appraisal_record.appraiser_person_id
                  ,p_appraisal_system_status     => 'COMPLETED');

            end if ;
        end if;

        open get_appraisal_status(appr_id);
        fetch get_appraisal_status into lv_appr_result_status;
        if is_new_appraisal (item_type, item_key) then
            p_log := hr_util_misc_web.return_msg_text(
                      p_message_name =>'HR_SUCCESS',
                      p_Application_id  =>'PER')
                     || '^' || null;
        else
            generate_appraisal_status(appraisal_record.appraisal_date,
                                      appraisal_record.full_name,
                                      lv_appr_result_status,
                                      appraisal_record.apprtype,
                                      hr_util_misc_web.return_msg_text(
                                       p_message_name =>'HR_SUCCESS',
                                       p_Application_id  =>'PER'),
                                      null,
                                      p_log);
        end if;

EXCEPTION
      WHEN lv_no_appraisal then
          if is_new_appraisal (item_type, item_key) then
              p_log := hr_util_misc_web.return_msg_text(
                        p_message_name =>'HR_FAILURE',
                        p_Application_id  =>'PER')
                       || '^' ||
                       hr_util_misc_web.return_msg_text(
                        p_message_name=>'HR_NO_APPRAISAL_RECORD',
                        p_Application_id=>'PER');
          else
              generate_appraisal_status(appraisal_record.appraisal_date,
                                      appraisal_record.full_name,
                                      appraisal_record.apprstatus,
                                      appraisal_record.apprtype,
                                      hr_util_misc_web.return_msg_text(
                                       p_message_name =>'HR_FAILURE',
                                       p_Application_id  =>'PER'),
                                      hr_util_misc_web.return_msg_text(
                                      p_message_name=>'HR_NO_APPRAISAL_RECORD',
                                      p_Application_id=>'PER'),
                                      p_log);
          end if;

          chg_appr_status := 'E';
          raise ;
      when hr_multi_message.error_message_exist then
          for i in 1 .. fnd_msg_pub.count_msg Loop
           error_message := error_message || fnd_msg_pub.get(p_msg_index => I, p_encoded => 'F');
          end loop;
           --bug#3767915
          fnd_msg_pub.Delete_Msg;
          if is_new_appraisal (item_type, item_key) then
              p_log := hr_util_misc_web.return_msg_text(
                        p_message_name =>'HR_FAILURE',
                        p_Application_id  =>'PER')
                       || '^' || error_message;
          else
              generate_appraisal_status(appraisal_record.appraisal_date,
                                      appraisal_record.full_name,
                                      appraisal_record.apprstatus,
                                      appraisal_record.apprtype,
                                      hr_util_misc_web.return_msg_text(
                                       p_message_name =>'HR_FAILURE',
                                       p_Application_id  =>'PER'),
                                      error_message,
                                      p_log);
          end if;
          chg_appr_status := 'E';
          raise  ;
      when others then
          error_message := error_message || sqlerrm;
          if is_new_appraisal (item_type, item_key) then
              p_log := hr_util_misc_web.return_msg_text(
                        p_message_name =>'HR_FAILURE',
                        p_Application_id  =>'PER')
                       || '^' || error_message;
          else
              generate_appraisal_status(appraisal_record.appraisal_date,
                                      appraisal_record.full_name,
                                      appraisal_record.apprstatus,
                                      appraisal_record.apprtype,
                                      hr_util_misc_web.return_msg_text(
                                       p_message_name =>'HR_FAILURE',
                                       p_Application_id  =>'PER'),
                                      error_message,
                                      p_log);
          end if;

          --set_appr_status_log(item_type, item_key, 'E',p_log);
          chg_appr_status := 'E';
          raise ;
END;

PROCEDURE apply_to_personal_profile
    ( appr_id per_appraisals.appraisal_id%TYPE,
      p_log in out nocopy varchar2,
      apply_pers_profile_status in out nocopy varchar2,
      p_new_appraisal in boolean DEFAULT true,
      p_talent_mang_src_typ per_appraisal_templates.COMP_PROFILE_SOURCE_TYPE%TYPE)
    IS
    cursor get_assessment_competences (appr_id IN number) is
    select pce.competence_id, pc.name, pce.competence_element_id, pce.proficiency_level_id,
    pce.business_group_id, pce.enterprise_id,pce.effective_date_from,   pce.effective_date_to, pa.appraisal_id, pa.appraisee_person_id,
    ppf.party_id, decode(rating.step_value, null, null, rating.step_value||' - '||rating.name) prof_level
    from per_competence_elements pce, per_appraisals pa, per_all_people_f ppf, per_competences pc,
    per_rating_levels rating
    where pce.type='ASSESSMENT'
    and pce.object_name = 'APPRAISAL_ID'
    and pce.object_id = appr_id
    and pa.appraisal_id = pce.object_id
    and pa.appraisee_person_id = ppf.person_id
    and pce.competence_id = pc.competence_id
    and pce.proficiency_level_id = rating.rating_level_id (+)
    and pce.proficiency_level_id is not null
    and trunc(sysdate) between nvl(trunc(ppf.effective_start_date),trunc(sysdate))
                       and nvl(trunc(ppf.effective_end_date),trunc(sysdate));


    cursor get_personal_competences (appr_id number) is
    select appr.appraisee_person_id,
    pce.competence_element_id, pce.object_version_number, pce.type,
    pce.business_group_id,
    pce.enterprise_id, pce.competence_id, pce.proficiency_level_id,
    pce.high_proficiency_level_id,   pce.weighting_level_id,  pce.rating_level_id,
    pce.person_id,   pce.job_id ,  pce.valid_grade_id,  pce.position_id,
    pce.organization_id,   pce.parent_competence_element_id,   pce.activity_version_id,
    pce.assessment_id,   pce.assessment_type_id,   pce.mandatory,
    pce.effective_date_from,   pce.effective_date_to,   pce.group_competence_type,
    pce.competence_type, pce.normal_elapse_duration,   pce.normal_elapse_duration_unit,
    pce.sequence_number,   pce.source_of_proficiency_level,
    pce.line_score,   pce.certification_date ,
    pce.certification_method, pce.next_certification_date,
    pce.comments, pce.attribute_category, pce.attribute1,
    pce.attribute2, pce.attribute3, pce.attribute4, pce.attribute5,
    pce.attribute6, pce.attribute7, pce.attribute8, pce.attribute9,
    pce.attribute10, pce.attribute11, pce.attribute12,
    pce.attribute13, pce.attribute14, pce.attribute15, pce.attribute16,
    pce.attribute17, pce.attribute18, pce.attribute19,
    pce.attribute20,  pce.object_id,
    pce.object_name, pce.party_id
    from per_appraisals appr, per_competence_elements pce
    where appr.appraisal_id = appr_id
    and appr.appraisee_person_id = pce.person_id
    and pce.type = 'PERSONAL'
    and trunc(sysdate) between pce.effective_date_from and
    nvl(pce.effective_date_to, trunc(sysdate));

   cursor get_outcomes_rec (p_competence_element_id IN number, p_effective_date IN date) is
        Select ceo.COMP_ELEMENT_OUTCOME_ID, ceo.COMPETENCE_ELEMENT_ID, ceo.OUTCOME_ID,
               ceo.DATE_FROM, ceo.DATE_TO, ceo.OBJECT_VERSION_NUMBER, ceo.ATTRIBUTE_CATEGORY,
               ceo.ATTRIBUTE1, ceo.ATTRIBUTE2, ceo.ATTRIBUTE3, ceo.ATTRIBUTE4, ceo.ATTRIBUTE5,
               ceo.ATTRIBUTE6, ceo.ATTRIBUTE7, ceo.ATTRIBUTE8, ceo.ATTRIBUTE9, ceo.ATTRIBUTE10,
               ceo.ATTRIBUTE11, ceo.ATTRIBUTE12, ceo.ATTRIBUTE13, ceo.ATTRIBUTE14, ceo.ATTRIBUTE15,
               ceo.ATTRIBUTE16, ceo.ATTRIBUTE17, ceo.ATTRIBUTE18, ceo.ATTRIBUTE19, ceo.ATTRIBUTE20,
               ceo.INFORMATION_CATEGORY, ceo.INFORMATION1, ceo.INFORMATION2, ceo.INFORMATION3,
               ceo.INFORMATION4, ceo.INFORMATION5, ceo.INFORMATION6, ceo.INFORMATION7, ceo.INFORMATION8,
               ceo.INFORMATION9, ceo.INFORMATION10, ceo.INFORMATION11, ceo.INFORMATION12,
               ceo.INFORMATION13, ceo.INFORMATION14, ceo.INFORMATION15, ceo.INFORMATION16,
               ceo.INFORMATION17, ceo.INFORMATION18, ceo.INFORMATION19, ceo.INFORMATION20
        From per_comp_element_outcomes ceo,
             per_competence_outcomes co
        Where ceo.Competence_element_id = p_competence_element_id
        AND co.outcome_id = ceo.outcome_id
        AND co.DATE_FROM <= ceo.DATE_FROM
        AND nvl(co.date_to,nvl(ceo.date_to,trunc(sysdate))) >= nvl(ceo.date_to,trunc(sysdate));
--        AND ceo.DATE_FROM <= p_effective_date
--        And nvl(ceo.DATE_TO,p_effective_date) >= p_effective_date ;

    match_found boolean default false;
    l_old_ovn per_competence_elements.object_version_number%TYPE;
    l_new_ovn per_competence_elements.object_version_number%TYPE;
    l_comp_ele_id per_competence_elements.competence_element_id%TYPE;
    talent_mang_src_typ varchar2(100);
    each_comp_status varchar2(10);
    error_message varchar2(500) default null;
    assessed_comps number default 0;
    l_comp_log varchar2(32767);

    l_out_from_date per_comp_element_outcomes.DATE_FROM%type;
    l_out_ovn per_comp_element_outcomes.OBJECT_VERSION_NUMBER%type;
    l_comp_ele_out_id per_comp_element_outcomes.COMP_ELEMENT_OUTCOME_ID%type;
    l_comp_status per_competence_elements.status%type;
    l_achieved_date per_competence_elements.ACHIEVED_DATE%type;

BEGIN

    -- write an utility to get the value to apply the changes or not

    hr_multi_message.enable_message_list;



    for assess_comps in get_assessment_competences(appr_id)
    loop
      assessed_comps := assessed_comps + 1;

      if (not p_new_appraisal) and (assessed_comps = 1) then
        l_comp_log := l_comp_log ||
        '<br> <br> <table width="100%" summary="" border="0" cellspacing="0" cellpadding="0">' ||
        '<tr valign="top">' ||
        '<td align="left" width="70%">' ||
        '<div><div class="x60">' ||
        '<table cellpadding="0" cellspacing="0" border="0" width="100%" summary="">' ||
        '<tr>' ||
        '<td width="100%"> <h1 class="x18">'|| hr_util_misc_web.return_msg_text(
                                   p_message_name =>'HR_APPR_APPLY_ASSESS_COMPS',
                                   p_Application_id  =>'PER') || '</h1></td>' ||
        '</tr>' ||
        '<tr>' ||
        '<td class="x2i"></td>' ||
        '</tr>' ||
        '</table>' ||
        '</div>' ||
        '<script>t(void 0,''5'')</script>' ||
        '<table cellpadding="0" cellspacing="0" border="0" width="80%" summary="">' ||
        '<tr>' ||
        '<td>' ||
        '<table class="x1h" cellpadding="1" cellspacing="0" border="0" width="100%">' ||
        '<tr>' ||
        '<th scope="col" class="x1r">'|| hr_util_misc_web.return_msg_text(
                                   p_message_name =>'HR_APPR_COMPETENCY',
                                   p_Application_id  =>'PER') || '</th>' ||
        '<th scope="col" class="x1r x4j">'|| hr_util_misc_web.return_msg_text(
                                   p_message_name =>'HR_APPR_LEVEL',
                                   p_Application_id  =>'PER') || ' </th>' ||
        '<th scope="col" class="x1r x4j">'|| hr_util_misc_web.return_msg_text(
                                   p_message_name =>'HR_RESULT',
                                   p_Application_id  =>'PER') || '</th>' ||
        '<th scope="col" class="x1r x4j">'|| hr_util_misc_web.return_msg_text(
                                   p_message_name =>'HR_REASON',
                                   p_Application_id  =>'PER') || '</th>' ||
        '</tr>';
        if (length(l_comp_log) <=4000) then
           p_log := l_comp_log;
        end if;
      end if;

      match_found := false;
      each_comp_status := '';
      for pers_comps in get_personal_competences(appr_id)
      loop
        if(assess_comps.competence_id = pers_comps.competence_id
    	 and assess_comps.effective_date_from > pers_comps.effective_date_from) then
        begin
          --bug#3767915
          match_found := true;
          -- end date the element and create a new record
          l_old_ovn := pers_comps.object_version_number;
          hr_competence_element_api.update_competence_element
           (p_competence_element_id        => pers_comps.competence_element_id
           ,p_object_version_number        => l_old_ovn
           ,p_effective_date_to            => trunc(sysdate) - 1
           ,p_effective_date               => trunc(sysdate)
           ,p_validate                     => false
           );

-- Start Added for competence Qualification link enhancement
          l_comp_status := PerCompStatus.Get_Competence_Status(pers_comps.competence_id,
                                  pers_comps.competence_element_id,
                                  null,
                                  null,
                                  null,
                                  trunc(sysdate));
          IF l_comp_status = 'ACHIEVED' then
             l_achieved_date := trunc(sysdate);
          else
             l_achieved_date := null;
          END if;
          -- create a new sequence
          hr_competence_element_api.create_competence_element
           (p_competence_element_id    => l_comp_ele_id
           ,p_object_version_number    => l_new_ovn
           ,p_type                     => 'PERSONAL'
           ,p_competence_id            => pers_comps.competence_id
           ,p_effective_date	          => trunc(sysdate)
           ,p_effective_date_from      => trunc(sysdate)
           ,p_proficiency_level_id     => assess_comps.proficiency_level_id
           ,p_business_group_id        => pers_comps.business_group_id
           ,p_source_of_proficiency_level => p_talent_mang_src_typ
           ,p_party_id                 => pers_comps.party_id
           ,p_person_id                => pers_comps.appraisee_person_id
           ,p_attribute_category       => pers_comps.attribute_category
           ,p_attribute1               => pers_comps.attribute1
           ,p_attribute2               => pers_comps.attribute2
           ,p_attribute3               => pers_comps.attribute3
           ,p_attribute4               => pers_comps.attribute4
           ,p_attribute5               => pers_comps.attribute5
           ,p_attribute6               => pers_comps.attribute6
           ,p_attribute7               => pers_comps.attribute7
           ,p_attribute8               => pers_comps.attribute8
           ,p_attribute9               => pers_comps.attribute9
           ,p_attribute10              => pers_comps.attribute10
           ,p_attribute11              => pers_comps.attribute11
           ,p_attribute12              => pers_comps.attribute12
           ,p_attribute13              => pers_comps.attribute13
           ,p_attribute14              => pers_comps.attribute14
           ,p_attribute15              => pers_comps.attribute15
           ,p_attribute16              => pers_comps.attribute16
           ,p_attribute17              => pers_comps.attribute17
           ,p_attribute18              => pers_comps.attribute18
           ,p_attribute19              => pers_comps.attribute19
           ,p_attribute20              => pers_comps.attribute20
           ,p_status                   => l_comp_status -- added for competence qual enhancement
           ,p_achieved_date            => l_achieved_date -- added for competence qual enhancement
           );

-- Added for competence qualification link enhancement
           FOR Outcome_rec IN get_outcomes_rec( pers_comps.competence_element_id, trunc(sysdate))
           loop
               l_out_ovn := null;
               l_comp_ele_out_id := null;
--               IF Outcome_rec.DATE_FROM < trunc(sysdate) Then
--                  l_out_from_date := trunc(sysdate);
--               else
                  l_out_from_date := Outcome_rec.DATE_FROM;
--               END if;
               hr_comp_element_outcome_api.create_element_outcome(
                     p_comp_element_outcome_id => l_comp_ele_out_id
                     ,p_object_version_number  => l_out_ovn
                     ,p_effective_date         => trunc(sysdate)
                     ,p_competence_element_id  => l_comp_ele_id
                     ,p_outcome_id             => Outcome_rec.outcome_id
                     ,p_date_from              => l_out_from_date
                     ,p_date_to                => Outcome_rec.DATE_TO
                     ,p_attribute_category      => Outcome_rec.ATTRIBUTE_CATEGORY
                     ,p_ATTRIBUTE1      => Outcome_rec.ATTRIBUTE1
                     ,p_ATTRIBUTE2      => Outcome_rec.ATTRIBUTE2
                     ,p_ATTRIBUTE3      => Outcome_rec.ATTRIBUTE3
                     ,p_ATTRIBUTE4      => Outcome_rec.ATTRIBUTE4
                     ,p_ATTRIBUTE5      => Outcome_rec.ATTRIBUTE5
                     ,p_ATTRIBUTE6      => Outcome_rec.ATTRIBUTE6
                     ,p_ATTRIBUTE7      => Outcome_rec.ATTRIBUTE7
                     ,p_ATTRIBUTE8      => Outcome_rec.ATTRIBUTE8
                     ,p_ATTRIBUTE9      => Outcome_rec.ATTRIBUTE9
                     ,p_ATTRIBUTE10      => Outcome_rec.ATTRIBUTE10
                     ,p_ATTRIBUTE11      => Outcome_rec.ATTRIBUTE11
                     ,p_ATTRIBUTE12      => Outcome_rec.ATTRIBUTE12
                     ,p_ATTRIBUTE13      => Outcome_rec.ATTRIBUTE13
                     ,p_ATTRIBUTE14      => Outcome_rec.ATTRIBUTE14
                     ,p_ATTRIBUTE15      => Outcome_rec.ATTRIBUTE15
                     ,p_ATTRIBUTE16      => Outcome_rec.ATTRIBUTE16
                     ,p_ATTRIBUTE17      => Outcome_rec.ATTRIBUTE17
                     ,p_ATTRIBUTE18      => Outcome_rec.ATTRIBUTE18
                     ,p_ATTRIBUTE19      => Outcome_rec.ATTRIBUTE19
                     ,p_ATTRIBUTE20      => Outcome_rec.ATTRIBUTE20
                     ,p_INFORMATION_CATEGORY      => Outcome_rec.INFORMATION_CATEGORY
                     ,p_INFORMATION1      => Outcome_rec.INFORMATION1
                     ,p_INFORMATION2      => Outcome_rec.INFORMATION2
                     ,p_INFORMATION3      => Outcome_rec.INFORMATION3
                     ,p_INFORMATION4      => Outcome_rec.INFORMATION4
                     ,p_INFORMATION5      => Outcome_rec.INFORMATION5
                     ,p_INFORMATION6      => Outcome_rec.INFORMATION6
                     ,p_INFORMATION7      => Outcome_rec.INFORMATION7
                     ,p_INFORMATION8      => Outcome_rec.INFORMATION8
                     ,p_INFORMATION9      => Outcome_rec.INFORMATION9
                     ,p_INFORMATION10      => Outcome_rec.INFORMATION10
                     ,p_INFORMATION11      => Outcome_rec.INFORMATION11
                     ,p_INFORMATION12      => Outcome_rec.INFORMATION12
                     ,p_INFORMATION13      => Outcome_rec.INFORMATION13
                     ,p_INFORMATION14      => Outcome_rec.INFORMATION14
                     ,p_INFORMATION15      => Outcome_rec.INFORMATION15
                     ,p_INFORMATION16      => Outcome_rec.INFORMATION16
                     ,p_INFORMATION17      => Outcome_rec.INFORMATION17
                     ,p_INFORMATION18      => Outcome_rec.INFORMATION18
                     ,p_INFORMATION19      => Outcome_rec.INFORMATION19
                     ,p_INFORMATION20       => Outcome_rec.INFORMATION20  );
           END loop;
-- End for competence qualification link enhancement

           each_comp_status := 'S';
           --p_log := p_log || ' <BR> <A class="OraInstructionText"> ' ||  assess_comps.name || ' => ' || hr_util_misc_web.return_msg_text(
           --                    p_message_name=>'HR_ASSESS_COMP_SUCC',
           --                    p_Application_id=>'PER') ||' </A> ';

           if p_new_appraisal then
               l_comp_log := l_comp_log || assess_comps.competence_element_id || '^'
                             || hr_util_misc_web.return_msg_text(p_message_name =>'HR_SUCCESS', p_Application_id  =>'PER') || '~';
           else
               l_comp_log := l_comp_log ||
                            '<tr>
                             <td class="x1l x4x" nowrap>' || assess_comps.name || '</td>
                             <td class="x1l x4x" nowrap>'        || assess_comps.prof_level || '</td>
                             <td class="x1l x4x">'        || hr_util_misc_web.return_msg_text(
                                                             p_message_name =>'HR_SUCCESS',
                                                             p_Application_id  =>'PER')  || '</td>
                             <td class="x1l x4x">'        || '</td>
                             </tr>';
           end if;
           if (length(l_comp_log) <=4000) then
               p_log := l_comp_log;
           end if;

         exception
         when hr_multi_message.error_message_exist then
           --p_log := p_log || ' <BR> <A class="OraInstructionText"> ' || assess_comps.name || ' => ';
           for i in 1 .. fnd_msg_pub.count_msg Loop
             error_message := error_message || fnd_msg_pub.get(p_msg_index => I, p_encoded => 'F');
           end loop;
           --bug#3767915
           fnd_msg_pub.Delete_Msg;

           if p_new_appraisal then
               l_comp_log := l_comp_log || assess_comps.competence_element_id || '^'
                             || hr_util_misc_web.return_msg_text(p_message_name =>'HR_FAILURE', p_Application_id  =>'PER') || '^' || error_message || '~';
           else
               l_comp_log := l_comp_log ||
                            '<tr>
                             <td class="x1l x4x" nowrap>' || assess_comps.name || '</td>
                             <td class="x1l x4x" nowrap>'        || assess_comps.prof_level || '</td>
                             <td class="x1l x4x">'        || hr_util_misc_web.return_msg_text(
                                                             p_message_name =>'HR_FAILURE',
                                                             p_Application_id  =>'PER') || '</td>
                             <td class="x1l x4x">'        || error_message || '</td>
                             </tr>';
           end if;
           if (length(l_comp_log) <=4000) then
             p_log := l_comp_log;
           end if;
           error_message := null;
           --p_log := p_log || '</A>';
           --set_appr_status_log(item_type, item_key, 'W',p_log);
           apply_pers_profile_status := 'W';
           each_comp_status := 'E';
         when others then
           error_message := error_message || sqlerrm;

           if p_new_appraisal then
               l_comp_log := l_comp_log || assess_comps.competence_element_id || '^'
                             || hr_util_misc_web.return_msg_text(p_message_name =>'HR_FAILURE', p_Application_id  =>'PER') || '^' || error_message || '~';
           else
               l_comp_log := l_comp_log ||
                             '<tr>
                              <td class="x1l x4x" nowrap>' || assess_comps.name || '</td>
                              <td class="x1l x4x" nowrap>' || assess_comps.prof_level || '</td>
                              <td class="x1l x4x">'        || hr_util_misc_web.return_msg_text(
                                                               p_message_name =>'HR_FAILURE',
                                                               p_Application_id  =>'PER') || '</td>
                              <td class="x1l x4x">'        || error_message || '</td>
                              </tr>';
           end if;
           if (length(l_comp_log) <=4000) then
             p_log := l_comp_log;
           end if;
           error_message := null;
           --p_log := p_log || ' <BR> <A class="OraInstructionText"> ' || assess_comps.name || ' => ' || sqlcode || sqlerrm || ' </A> ';

           --set_appr_status_log(item_type, item_key, 'W',p_log);
           apply_pers_profile_status := 'W';
           each_comp_status := 'E';
         end;
        end if;
       end loop;


       if( match_found = false ) then
         begin

         l_comp_ele_id := null;

         -- since we r not supporting the flex in appraisal
         -- we wont be having flex parameters to update
-- Start Added for competence Qualification link enhancement
          l_comp_status := PerCompStatus.Get_Competence_Status(assess_comps.competence_id,
                                  null,
                                  null,
                                  null,
                                  null,
                                  trunc(sysdate));
          IF l_comp_status = 'ACHIEVED' then
             l_achieved_date := trunc(sysdate);
          else
             l_achieved_date := null;
          END if;
         hr_competence_element_api.create_competence_element
         (
          p_competence_element_id        => l_comp_ele_id
         ,p_object_version_number        => l_new_ovn
         ,p_type                         => 'PERSONAL'
         ,p_business_group_id            => assess_comps.business_group_id
         ,p_competence_id                => assess_comps.competence_id
         ,p_proficiency_level_id         => assess_comps.proficiency_level_id  -- Modified from prof_level for competence qual enhanc
         ,p_person_id                    => assess_comps.appraisee_person_id
         ,p_effective_date_from          => trunc(sysdate)
         ,p_effective_date               => trunc(sysdate)
         ,p_party_id                     => assess_comps.party_id
         ,p_source_of_proficiency_level => p_talent_mang_src_typ
         ,p_status                       => l_comp_status -- added for competence qual enhancement
         ,p_achieved_date                => l_achieved_date -- added for competence qual enhancement
         );

         each_comp_status := 'S';
         --p_log := p_log || ' <BR> <A class="OraInstructionText"> ' ||  assess_comps.name || ' => ' || hr_util_misc_web.return_msg_text(
         --                      p_message_name=>'HR_ASSESS_COMP_SUCC',
         --                      p_Application_id=>'PER') || '</A>';

           if p_new_appraisal then
               l_comp_log := l_comp_log || assess_comps.competence_element_id || '^'
                             || hr_util_misc_web.return_msg_text(p_message_name =>'HR_SUCCESS', p_Application_id  =>'PER') || '~';
           else
               l_comp_log := l_comp_log ||
                             '<tr>
                             <td class="x1l x4x" nowrap>' || assess_comps.name || '</td>
                             <td class="x1l x4x" nowrap>'        || assess_comps.prof_level || '</td>
                             <td class="x1l x4x">'        || hr_util_misc_web.return_msg_text(
                                                              p_message_name =>'HR_SUCCESS',
                                                              p_Application_id  =>'PER') || '</td>
                             <td class="x1l x4x">'        || '</td>
                             </tr>';
           end if;
           if (length(l_comp_log) <=4000) then
              p_log := l_comp_log;
           end if;

         exception
         when hr_multi_message.error_message_exist then
           --p_log := p_log || ' <BR> <A class="OraInstructionText"> ' || assess_comps.name || ' => ';
           for i in 1 .. fnd_msg_pub.count_msg Loop
             error_message := error_message || fnd_msg_pub.get(p_msg_index => I, p_encoded => 'F');
           end loop;
           --bug#3767915
           fnd_msg_pub.Delete_Msg;
           --p_log := p_log || ' </A> ';

           if p_new_appraisal then
               l_comp_log := l_comp_log || assess_comps.competence_element_id || '^'
                             || hr_util_misc_web.return_msg_text(p_message_name =>'HR_FAILURE', p_Application_id  =>'PER') || '^' || error_message || '~';
           else
               l_comp_log := l_comp_log ||
                             '<tr>
                             <td class="x1l x4x" nowrap>' || assess_comps.name || '</td>
                             <td class="x1l x4x" nowrap>'        || assess_comps.prof_level || '</td>
                             <td class="x1l x4x">'        || hr_util_misc_web.return_msg_text(
                                                              p_message_name =>'HR_FAILURE',
                                                              p_Application_id  =>'PER') || '</td>
                             <td class="x1l x4x">'        || error_message || '</td>
                             </tr>';
           end if;
           if (length(l_comp_log) <=4000) then
             p_log := l_comp_log;
           end if;
            error_message := null;
           --set_appr_status_log(item_type, item_key, 'W',p_log);
           apply_pers_profile_status := 'W';
           each_comp_status := 'E';
         when others then
           error_message := error_message ||sqlerrm;
           --p_log := p_log || ' <BR> <A class="OraInstructionText"> ' || assess_comps.name || ' => ' || sqlcode || sqlerrm || '</A>';

           if p_new_appraisal then
               l_comp_log := l_comp_log || assess_comps.competence_element_id || '^'
                             || hr_util_misc_web.return_msg_text(p_message_name =>'HR_FAILURE', p_Application_id  =>'PER') || '^' || error_message || '~';
           else
               l_comp_log := l_comp_log ||
                             '<tr>
                             <td class="x1l x4x" nowrap>' || assess_comps.name || '</td>
                             <td class="x1l x4x" nowrap>'        || assess_comps.prof_level || '</td>
                             <td class="x1l x4x">'        || hr_util_misc_web.return_msg_text(
                                                              p_message_name =>'HR_FAILURE',
                                                              p_Application_id  =>'PER') || '</td>
                             <td class="x1l x4x">'        || error_message || '</td>
                             </tr>';
           end if;
           if (length(l_comp_log) <=4000) then
             p_log := l_comp_log;
           end if;
           --set_appr_status_log(item_type, item_key, 'W',p_log);
           apply_pers_profile_status := 'W';
           each_comp_status := 'E';
         end;
       end if;

     end  loop;


     if (not p_new_appraisal) then
         l_comp_log := l_comp_log || '</table></td></tr></table></div><div></div><script>t(''10'')</script></td></tr></table>';
     end if;
     if (length(l_comp_log) <=4000) then
          p_log := l_comp_log;
     end if;
     if not apply_pers_profile_status = 'W' then
        apply_pers_profile_status := 'S';
     end if;

             -- check for any training plan members with appraisal id
             -- if exists then change the status of Training Plan members
             -- to planned

             -- change the status in per_appraisals to completed.

   EXCEPTION
   WHEN OTHERS THEN
        error_message := error_message || sqlerrm;

        if p_new_appraisal then
            l_comp_log := l_comp_log || '-1' || '^'
                          || hr_util_misc_web.return_msg_text(p_message_name =>'HR_FAILURE', p_Application_id  =>'PER') || '^' || error_message || '~';
        else
            l_comp_log := l_comp_log ||
                          '<tr>
                          <td class="x1l x4x" nowrap>' || '</td>
                          <td class="x1l x4x" >'        || '</td>
                          <td class="x1l x4x">'        || hr_util_misc_web.return_msg_text(
                                                           p_message_name =>'HR_FAILURE',
                                                           p_Application_id  =>'PER') || '</td>
                          <td class="x1l x4x">'        || error_message || '</td>
                          </tr>';
        end if;
        if (length(l_comp_log) <=4000) then
           p_log := l_comp_log;
        end if;


        if (not p_new_appraisal) then
            l_comp_log := l_comp_log || '</table></td></tr></table></div><div></div><script>t(''10'')</script></td></tr></table>';
        end if;
        if (length(l_comp_log) <=4000) then
           p_log := l_comp_log;
        end if;

       error_message := null;
       --p_log := p_log || ' <BR> <A class="OraInstructionText"> ' || sqlcode || sqlerrm  || '</A> ';
       --set_appr_status_log(item_type, item_key, 'W',p_log);
       apply_pers_profile_status := 'W';
END;


PROCEDURE generate_lp_courses (p_lp_id number, p_log in out nocopy varchar2, p_new_appraisal in boolean DEFAULT true)
IS

  query_lp_courses VARCHAR2(4000) := ' select tav.version_name course_name, hrl.meaning member_status, ' ||
                                       ' lpme.completion_target_date, lpme.completion_date ' ||
                                       ' from ota_learning_path_members lpm, ota_lp_member_enrollments lpme, ' ||
                                       ' ota_activity_versions tav, hr_lookups hrl ' ||
                                       ' where lpm.learning_path_id = :1 ' ||
                                       ' and lpme.learning_path_member_id = lpm.learning_path_member_id ' ||
                                       ' and hrl.lookup_code = lpme.member_status_code ' ||
                                       ' and hrl.lookup_type = ''OTA_LP_MEMBER_STATUS''' ||
                                       ' and tav.activity_version_id = lpm.activity_version_id ';

  l_lp_courses cur_typ;
  lv_course_name varchar2(80);
  lv_course_status hr_lookups.meaning%TYPE;
  lv_course_targe_date date;
  lv_course_compl_date date;
  ln_count number default  0;
BEGIN

  OPEN l_lp_courses FOR query_lp_courses USING p_lp_id;
  LOOP
    FETCH l_lp_courses INTO lv_course_name, lv_course_status, lv_course_targe_date, lv_course_compl_date;
    EXIT WHEN l_lp_courses%NOTFOUND;
    BEGIN
      ln_count := ln_count + 1;
      if (not p_new_appraisal) then
        IF ln_count = 1 THEN
          p_log := p_log ||
                  '<br>' ||
                  '<table cellpadding="0" cellspacing="0" border="0" width="80%" summary="">'||
                  '<tr>'||
                  '<td>' ||
                  '<table class="x1h" cellpadding="1" cellspacing="0" border="0" width="100%">' ||
                  '<tr>' ||
                  '<th scope="col" class="x1r">'|| hr_util_misc_web.return_msg_text(
                                                       p_message_name =>'HR_LP_COURSE',
                                                       p_Application_id  =>'PER') || '</th>' ||
                  '<th scope="col" class="x1r x4j">'|| hr_util_misc_web.return_msg_text(
                                                        p_message_name =>'HR_STATUS',
                                                        p_Application_id  =>'PER') || '</th>' ||
                  '<th scope="col" class="x1r x4j">'|| hr_util_misc_web.return_msg_text(
                                                        p_message_name =>'HR_LP_COURSE_TARGET_DATE',
                                                        p_Application_id  =>'PER') || '</th>' ||
                  '<th scope="col" class="x1r x4j">'|| hr_util_misc_web.return_msg_text(
                                                        p_message_name =>'HR_LP_COURSE_COMP_DATE',
                                                        p_Application_id  =>'PER') || '</th>' ||
                  '</tr>';

          p_log := p_log ||
                  '<tr> ' ||
                  '<td class="x1l x4x" nowrap>' || lv_course_name || '</td>' ||
                  '<td class="x1l x4x" nowrap>' || lv_course_status || '</td>' ||
                  '<td class="x1l x4x" nowrap>' || lv_course_targe_date || '</td>' ||
                  '<td class="x1l x4x" nowrap>' || lv_course_compl_date || '</td>' ||
                  '</tr>';
        ELSE
          p_log := p_log ||
                  '<tr> ' ||
                  '<td class="x1l x4x" nowrap>' || lv_course_name || '</td>' ||
                  '<td class="x1l x4x" nowrap>' || lv_course_status || '</td>' ||
                  '<td class="x1l x4x" nowrap>' || lv_course_targe_date || '</td>' ||
                  '<td class="x1l x4x" nowrap>' || lv_course_compl_date || '</td>' ||
                  '</tr>';
        END IF;
      end if;
    END;
  END LOOP;

  CLOSE l_lp_courses;

  IF (ln_count > 0) and (not p_new_appraisal) THEN
       p_log := p_log ||
        '</table>' ||
        '</td>' ||
        '</tr>' ||
        '</table>';
  END IF;

  EXCEPTION
    WHEN Others THEN
    p_log := p_log || ' Error in Courses generation ';
    CLOSE l_lp_courses;
END;

PROCEDURE update_train_component_status
    ( appr_id IN per_appraisals.appraisal_id%TYPE,
      p_log  in out nocopy varchar2,
      upd_train_comps_status in out nocopy varchar2,
      p_new_appraisal in boolean DEFAULT true)
    IS

    l_cursor cur_typ;
    l_status_cursor cur_typ;
    l_lp_id number;
    l_lp_ovn number;
    l_display_to_learner_flag varchar2(10);
    l_lpe_id number;
    l_lpe_ovn number;
    l_path_status varchar2(100);
    l_completion_status varchar2(20);
    l_lp_name          varchar2(80);

    query_str VARCHAR2(4000) := ' select lp.learning_path_id, lp.display_to_learner_flag, lp.object_version_number, ' ||
        ' lpe.lp_enrollment_id,lpe.object_version_number,hrl.meaning , lptl.name ' ||
        ' from  ota_learning_paths lp, ota_learning_paths_tl lptl, ota_lp_enrollments lpe, ' ||
        ' hr_lookups hrl ' ||
        ' where lp.source_id = :1 and lp.path_source_code= :2 ' ||
        ' and lp.source_function_code = :3 ' ||
        ' and lptl.learning_path_id = lp.learning_path_id  ' ||
	  ' and lptl.language = userenv(''lang'') ' ||
        ' and lpe.learning_path_id = lp.learning_path_id  ' ||
        ' and hrl.lookup_code = lpe.path_status_code ' ||
        ' and hrl.lookup_type = ''OTA_LEARNING_PATH_STATUS''';

    query_lp_status VARCHAR2(4000) :=
                ' select hrl.meaning path_status_code ' ||
                ' from ota_learning_paths lp, ' ||
                ' ota_lp_enrollments lpe, hr_lookups hrl ' ||
                ' where lp.learning_path_id = :1 ' ||
                ' and lpe.learning_path_id = lp.learning_path_id ' ||
                ' and lpe.path_status_code = hrl.lookup_code ' ||
                ' and hrl.lookup_type = ''OTA_LEARNING_PATH_STATUS''';



    l_stmt VARCHAR2(2000);
    found_training_activities boolean default false;
    error_message varchar2(500) default null;
    l_lp_status_cursor cur_typ;
BEGIN

    hr_multi_message.enable_message_list;

    BEGIN
      OPEN l_cursor FOR query_str USING appr_id, 'TALENT_MGMT','APPRAISAL';
    EXCEPTION
      WHEN Others THEN
      CLOSE l_cursor;
        p_log := '';
        upd_train_comps_status := 'S';
        RETURN;
    END;

    FETCH l_cursor INTO l_lp_id ,l_display_to_learner_flag,l_lp_ovn, l_lpe_id,l_lpe_ovn,l_path_status, l_lp_name ;
    IF  l_cursor%FOUND  then

      if (not p_new_appraisal) then
          p_log := p_log ||
                  '<br> <br> <table width="100%" summary="" border="0" cellspacing="0" cellpadding="0">' ||
                  '<tr valign="top">' ||
                  '<td align="left" width="70%">' ||
                  '<div><div class="x60">' ||
                  '<table cellpadding="0" cellspacing="0" border="0" width="100%" summary="">' ||
                  '<tr>' ||
                  '<td width="100%"> <h1 class="x18">'|| hr_util_misc_web.return_msg_text(
                                                          p_message_name =>'HR_APPR_LEARNING_PATH',
                                                          p_Application_id  =>'PER') || '</h1></td>' ||
                  '</tr>' ||
                  '<tr>' ||
                  '<td class="x2i"></td>' ||
                  '</tr>' ||
                  '</table>' ||
                  '</div>' ||
                  '<script>t(void 0,''5'')</script>' ||
                  '<table cellpadding="0" cellspacing="0" border="0" width="80%" summary="">' ||
                  '<tr>' ||
                  '<td>' ||
                  '<table class="x1h" cellpadding="1" cellspacing="0" border="0" width="100%">' ||
                  '<tr>' ||
                  '<th scope="col" class="x1r">'|| hr_util_misc_web.return_msg_text(
                                                    p_message_name =>'HR_APPR_LEARNING_PATH',
                                                    p_Application_id  =>'PER') || '</th>' ||
                  '<th scope="col" class="x1r x4j">'|| hr_util_misc_web.return_msg_text(
                                                        p_message_name =>'HR_STATUS',
                                                        p_Application_id  =>'PER') || ' </th>' ||
                  '<th scope="col" class="x1r x4j">'|| hr_util_misc_web.return_msg_text(
                                                        p_message_name =>'HR_RESULT',
                                                        p_Application_id  =>'PER') || '</th>' ||
                  '<th scope="col" class="x1r x4j">'|| hr_util_misc_web.return_msg_text(
                                                        p_message_name =>'HR_REASON',
                                                        p_Application_id  =>'PER') || '</th>' ||
                  '</tr>';
      end if;

      found_training_activities := true;

      -- If DisplayToLearner is unchecked then check it

      IF (l_display_to_learner_flag <> 'Y' )then
      BEGIN
        l_stmt := 'begin ota_learning_path_api.update_learning_path( ' ||
                  'p_effective_date => trunc(sysdate) , ' ||
                  'p_learning_path_id => :1,' ||
                  'p_object_version_number => :2 ,' ||
                  'p_display_to_learner_flag => :3 ); end;';

        EXECUTE IMMEDIATE l_stmt using IN l_lp_id,IN OUT l_lp_ovn,IN 'Y';

        EXCEPTION
        WHEN hr_multi_message.error_message_exist THEN
          error_message := error_message || hr_util_misc_web.return_msg_text(
                                   p_message_name =>'HR_APPR_DISP_TO_LEARNER',
                                   p_Application_id  =>'PER') || ' => ';
          FOR i IN 1 .. fnd_msg_pub.count_msg LOOP
            error_message := error_message || fnd_msg_pub.get(p_msg_index => I, p_encoded => 'F');
          END LOOP;
          --bug#3767915
          fnd_msg_pub.Delete_Msg;
          --set_appr_status_log(item_type, item_key, 'W',p_log);
          upd_train_comps_status := 'W';
        WHEN others THEN
          error_message := error_message || hr_util_misc_web.return_msg_text(
                                   p_message_name =>'HR_APPR_DISP_TO_LEARNER',
                                   p_Application_id  =>'PER') || ' => ' || sqlerrm ;
          upd_train_comps_status := 'W';
      END;
      END IF;  --  Display To Learner Flag

      -- If Learning Path Status is not ACTIVE then make it ACTIVE so
      -- that it triggers the completion process.

      IF ( l_path_status <> 'ACTIVE' ) THEN
      BEGIN
        l_stmt := 'begin ota_lp_enrollment_api.update_lp_enrollment( ' ||
                  'p_effective_date => trunc(sysdate) , ' ||
                  'p_lp_enrollment_id  => :1 ,' ||
                  'p_object_version_number => :2 ,' ||
                  'p_path_status_code => :3); end;';

        EXECUTE IMMEDIATE l_stmt using in l_lpe_id, in out l_lpe_ovn, in 'ACTIVE';

        EXCEPTION
          WHEN hr_multi_message.error_message_exist THEN

            error_message := error_message || hr_util_misc_web.return_msg_text(
                                   p_message_name =>'HR_APPR_LP_STATUS',
                                   p_Application_id  =>'PER') || ' => ';
            FOR i in 1 .. fnd_msg_pub.count_msg LOOP
              error_message := error_message || fnd_msg_pub.get(p_msg_index => I, p_encoded => 'F');
            END LOOP;
            --bug#3767915
            fnd_msg_pub.Delete_Msg;
            --set_appr_status_log(item_type, item_key, 'W',p_log);
            upd_train_comps_status := 'W';
          WHEN others THEN
            error_message :=  error_message || hr_util_misc_web.return_msg_text(
                                   p_message_name =>'HR_APPR_LP_STATUS',
                                   p_Application_id  =>'PER') || ' => ' || sqlerrm;
            upd_train_comps_status := 'W';
      END;
      END IF;  -- Learning Path Status change

       -- try to find out if the LP can be completed at this juncture or not

      BEGIN
        query_str := 'SELECT ota_lrng_path_util.chk_complete_path_ok(:1) from dual';
        OPEN l_status_cursor FOR query_str USING l_lpe_id;
          EXCEPTION
          WHEN hr_multi_message.error_message_exist THEN
            error_message := error_message || hr_util_misc_web.return_msg_text(
                             p_message_name =>'HR_APPR_LP_COMPLETE',
                             p_Application_id  =>'PER') || ' => ';
            FOR i IN 1 .. fnd_msg_pub.count_msg LOOP
              error_message := error_message || fnd_msg_pub.get(p_msg_index => I, p_encoded => 'F');
            END LOOP;

          WHEN Others THEN

            error_message := error_message || hr_util_misc_web.return_msg_text(
                                   p_message_name =>'HR_APPR_LP_COMPLETE',
                                   p_Application_id  =>'PER') || ' => ' || sqlerrm;
            upd_train_comps_status := 'S';
      END;


      FETCH l_status_cursor INTO l_completion_status;
      IF l_status_cursor%FOUND THEN
        IF (l_completion_status = 'S' ) THEN
          --if returned code is 'S' , complete the LP
          BEGIN
            l_stmt := 'begin ota_lrng_path_util.complete_path(p_lp_enrollment_id => :1 ); end;';
            EXECUTE IMMEDIATE l_stmt using IN l_lpe_id;

            EXCEPTION
              WHEN hr_multi_message.error_message_exist THEN
                error_message := error_message || hr_util_misc_web.return_msg_text(
                                   p_message_name =>'HR_APPR_LP_COMPLETE',
                                   p_Application_id  =>'PER') || ' => ';
                FOR i IN 1 .. fnd_msg_pub.count_msg LOOP
                  error_message := error_message || fnd_msg_pub.get(p_msg_index => I, p_encoded => 'F');
                END LOOP;
                --bug#3767915
                fnd_msg_pub.Delete_Msg;
                --set_appr_status_log(item_type, item_key, 'W',p_log);
                upd_train_comps_status := 'W';
              WHEN others THEN
                error_message := error_message || hr_util_misc_web.return_msg_text(
                                   p_message_name =>'HR_APPR_LP_COMPLETE',
                                   p_Application_id  =>'PER') || ' => ' || sqlerrm;
                upd_train_comps_status := 'W';
          END;
        END IF;
      END IF; -- Complete Learning Path

      -- The LP status can be completed with above step
      -- or it remains in the previous step.

      BEGIN
        OPEN l_lp_status_cursor FOR query_lp_status USING l_lp_id;
        EXCEPTION
        WHEN Others THEN
        CLOSE l_lp_status_cursor;
      END;
      FETCH l_lp_status_cursor INTO l_completion_status;


      if p_new_appraisal then
        if (error_message is null) then
           p_log := l_lp_id || '^'
                    || hr_util_misc_web.return_msg_text(
                     p_message_name =>'HR_SUCCESS',
                     p_Application_id  =>'PER')
                    || '^';
        else
           p_log := l_lp_id || '^'
                    || hr_util_misc_web.return_msg_text(
                     p_message_name =>'HR_FAILURE',
                     p_Application_id  =>'PER')
                    || '^' || error_message;
        end if;
      else
        IF(error_message is null ) THEN
           p_log := p_log ||
                    '<tr> ' ||
                    '<td class="x1l x4x" nowrap>' || l_lp_name || '</td>' ||
                    '<td class="x1l x4x" nowrap>' || l_completion_status || '</td>' ||
                    '<td class="x1l x4x">'        || hr_util_misc_web.return_msg_text(
                                                         p_message_name =>'HR_SUCCESS',
                                                         p_Application_id  =>'PER') || '</td>' ||
                    '<td class="x1l x4x">'        || '</td>' ||
                    '</tr>' ||
                    '</table>' ||
                    '</td>' ||
                    '</tr>' ||
                    '</table>' ||
                    '</div>' ||
                    '<div></div>' ||
                    '<script>t(''10'')</script>' ||
                    '</td>' ||
                    '</tr>' ||
                    '</table>';
        ELSE
           p_log := p_log ||
                    '<tr> ' ||
                    '<td class="x1l x4x" nowrap>' || l_lp_name || '</td>' ||
                    '<td class="x1l x4x" nowrap>' || l_completion_status || '</td>' ||
                    '<td class="x1l x4x">'        || hr_util_misc_web.return_msg_text(
                                                         p_message_name =>'HR_FAILURE',
                                                         p_Application_id  =>'PER') || '</td>' ||
                    '<td class="x1l x4x">'        || error_message || '</td>' ||
                    '</tr>' ||
                    '</table>' ||
                    '</td>' ||
                    '</tr>' ||
                    '</table>' ||
                    '</div>' ||
                    '<div></div>' ||
                    '<script>t(''10'')</script>' ||
                    '</td>' ||
                    '</tr>' ||
                    '</table>';
        END IF;  -- Error Message
      end if;

      -- generate courses table
      generate_lp_courses(l_lp_id, p_log, p_new_appraisal);

    END IF; -- If Learning Path Exists

    IF  l_cursor%ISOPEN then
    CLOSE l_cursor;
    END if;
    IF  l_status_cursor%ISOPEN then
    CLOSE l_status_cursor;
    END if;

    IF found_training_activities = false then
        p_log := '';
    END IF;

    IF NOT upd_train_comps_status = 'W' then
       upd_train_comps_status := 'S';
    END IF;


EXCEPTION
    WHEN others THEN
	CLOSE l_cursor;
      error_message := error_message || sqlerrm ;
      if p_new_appraisal then
         p_log := l_lp_id || '^'
                  || hr_util_misc_web.return_msg_text(
                   p_message_name =>'HR_FAILURE',
                   p_Application_id  =>'PER')
                  || '^' || error_message;
      else
         p_log := p_log ||
         '<tr> ' ||
         '<td class="x1l x4x" nowrap>' || l_lp_name || '</td>' ||
         '<td class="x1l x4x" nowrap>' || l_path_status || '</td>' ||
         '<td class="x1l x4x">'        || hr_util_misc_web.return_msg_text(
                                   p_message_name =>'HR_FAILURE',
                                   p_Application_id  =>'PER') || '</td>' ||
         '<td class="x1l x4x">'        || error_message || '</td>' ||
         '</tr>' ||
         '</table>' ||
         '</td>' ||
         '</tr>' ||
         '</table>' ||
         '</div>' ||
         '<div></div>' ||
         '<script>t(''10'')</script>' ||
         '</td>' ||
         '</tr>' ||
         '</table>';
      end if;
      --set_appr_status_log(item_type, item_key, 'W',p_log);
      upd_train_comps_status := 'W';
END;


PROCEDURE create_event (appr_id per_appraisals.appraisal_id%TYPE,
                        p_log  in out nocopy varchar2,
                        upd_create_event_status in out nocopy varchar2,
                        p_new_appraisal in boolean DEFAULT true)
   IS
--
-- To modify this template, edit file PROC.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the procedure
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  -------------------------------------------
   l_ovn                 number;
   l_event_id            per_events.event_id%TYPE;
   l_perf_rev_id         number;
   l_next_rev_date_warn  boolean;
   l_sql_err             varchar2(10000);

   cursor get_appr_overall_perf(appr_id per_appraisals.appraisal_id%TYPE) IS
   select appr.appraisal_id, appr.object_version_number, appr.appraiser_person_id,
          appr.appraisee_person_id, appr.overall_performance_level_id, prl.step_value,
          (prl.step_value||' - '||prl.name) overall_rating
   from per_appraisals appr, per_rating_levels prl
   where appraisal_id = appr_id
   and appr.overall_performance_level_id = prl.rating_level_id;

   TYPE appraisal_record is RECORD (
   appraisal_id per_appraisals.appraisal_id%TYPE,
   object_version_number per_appraisals.object_version_number%TYPE,
   appraiser_person_id per_appraisals.appraiser_person_id%TYPE,
   appraisee_person_id per_appraisals.appraisee_person_id%TYPE,
   overall_performance_level_id per_appraisals.appraisee_person_id%TYPE,
   step_value per_rating_levels.step_value%TYPE,
   overall_perf_rating varchar2(100)
   );

   appraisal_rec appraisal_record;

   cursor check_contingent_worker(appraisee_person_id per_all_people_f.person_id%TYPE) IS
   select current_npw_flag from per_all_people_f
   where person_id = appraisee_person_id
   and trunc(sysdate) between effective_start_date and effective_end_date;

   current_npw_flag per_all_people_f.current_npw_flag%TYPE default '';
   found_overall_performance boolean := false;
   error_message varchar2(500) default null;

   -- Declare program variables as shown above
BEGIN

    -- if there is no overall_performance entered then
    -- there is no need of creating an event or performance review
    -- as event is tied up to performance review for this release.
    -- this behavior might change in future. As per functional
    -- discussion with caroline.

    hr_multi_message.enable_message_list;

    open get_appr_overall_perf(appr_id);
    fetch get_appr_overall_perf into appraisal_rec;
    if get_appr_overall_perf%FOUND then

     open check_contingent_worker(appraisal_rec.appraisee_person_id);
     fetch check_contingent_worker into current_npw_flag;

     -- Incase of CWK dont create an event
     if ((current_npw_flag is null) or (not current_npw_flag = 'Y')) then


        per_events_api.create_event
        (p_date_start   => trunc(sysdate)
        ,p_type         => 'APPRAISAL'
        ,p_event_id     => l_event_id
        ,p_object_version_number   => l_ovn
        );

        -- retrieve
        hr_perf_review_api.create_perf_review
        (p_performance_review_id  => l_perf_rev_id
        ,p_person_id       => appraisal_rec.appraisee_person_id
        ,p_event_id        => l_event_id
        ,p_review_date     => trunc(sysdate)
        ,p_performance_rating => appraisal_rec.step_value
        ,p_object_version_number  => l_ovn
        ,p_next_review_date_warning  => l_next_rev_date_warn
        );


        hr_appraisals_api.update_appraisal
        (p_effective_date           => trunc(sysdate)
        ,p_appraisal_id             => appr_id
        ,p_appraiser_person_id      => appraisal_rec.appraiser_person_id
        ,p_object_version_number    => appraisal_rec.object_version_number
        ,p_event_id                 => l_event_id);

        found_overall_performance := true;

        generate_event(appraisal_rec.overall_perf_rating, trunc(sysdate),
                                   hr_util_misc_web.return_msg_text(
                                   p_message_name =>'HR_SUCCESS',
                                   p_Application_id  =>'PER')  , null,  p_log, p_new_appraisal);

     end if;
     close check_contingent_worker;
    end if;
    close get_appr_overall_perf;

    if(not found_overall_performance) then
     p_log := '';
    end if;

    if not  upd_create_event_status = 'W' then
        upd_create_event_status := 'S';
    end if;

EXCEPTION
    WHEN hr_multi_message.error_message_exist then
      close check_contingent_worker;
      close get_appr_overall_perf;
      for i in 1 .. fnd_msg_pub.count_msg Loop
        error_message := error_message || fnd_msg_pub.get(p_msg_index => I, p_encoded => 'F');
      end loop;
      generate_event(appraisal_rec.overall_perf_rating,
                                   trunc(sysdate),
                                   hr_util_misc_web.return_msg_text(
                                   p_message_name =>'HR_FAILURE',
                                   p_Application_id  =>'PER') ,
                                   error_message,
                                   p_log,
                                   p_new_appraisal);
      --bug#3767915
      fnd_msg_pub.Delete_Msg;
      --set_appr_status_log(item_type, item_key, 'W',p_log);
      upd_create_event_status := 'E';

    WHEN others THEN
        error_message := error_message || sqlerrm;
        upd_create_event_status := 'W';
        generate_event(appraisal_rec.overall_perf_rating,
                        trunc(sysdate),
                        hr_util_misc_web.return_msg_text(
                                   p_message_name =>'HR_FAILURE',
                                   p_Application_id  =>'PER'),
                       error_message,
                       p_log,
                       p_new_appraisal);
END; -- Procedure

PROCEDURE check_item_attribute ( p_item_type varchar2, p_item_key varchar2, p_attr_name varchar2 )
IS
BEGIN
        if not hr_workflow_service.item_attribute_exists
            (p_item_type => p_item_type
            ,p_item_key  => p_item_key
            ,p_name      => p_attr_name) then
        -- the item attribute does not exist so create it
            wf_engine.additemattr
              (itemtype => p_item_type
              ,itemkey  => p_item_key
              ,aname    => p_attr_name);
        end if;

END;

PROCEDURE create_new_objectives(p_appr_objs in appr_obj_table)
IS

I INTEGER default 0;
l_objective_id number;
--
-- Variables for IN/OUT parameters
l_weighting_over_100_warning    boolean;
l_weighting_appraisal_warning   boolean;
l_object_version_number number;

BEGIN

    FOR I IN 1 ..p_appr_objs.count LOOP
	--
	-- Call API
	--
	hr_objectives_api.create_objective
	(p_validate                     => false
	,p_effective_date               => trunc(sysdate)
	,p_business_group_id            => p_appr_objs(I).business_group_id
	,p_name                         => p_appr_objs(I).name
	,p_start_date                   => p_appr_objs(I).start_date
	,p_target_date                  => p_appr_objs(I).target_date
	,p_owning_person_id             => p_appr_objs(I).owning_person_id
	,p_achievement_date             => p_appr_objs(I).achievement_date
	,p_detail                       => p_appr_objs(I).detail
	,p_comments                     => p_appr_objs(I).comments
	,p_success_criteria             => p_appr_objs(I).success_criteria
	,p_attribute_category           => p_appr_objs(I).attribute_category
	,p_attribute1                   => p_appr_objs(I).attribute1
	,p_attribute2                   => p_appr_objs(I).attribute2
	,p_attribute3                   => p_appr_objs(I).attribute3
	,p_attribute4                   => p_appr_objs(I).attribute4
	,p_attribute5                   => p_appr_objs(I).attribute5
	,p_attribute6                   => p_appr_objs(I).attribute6
	,p_attribute7                   => p_appr_objs(I).attribute7
	,p_attribute8                   => p_appr_objs(I).attribute8
	,p_attribute9                   => p_appr_objs(I).attribute9
	,p_attribute10                  => p_appr_objs(I).attribute10
	,p_attribute11                  => p_appr_objs(I).attribute11
	,p_attribute12                  => p_appr_objs(I).attribute12
	,p_attribute13                  => p_appr_objs(I).attribute13
	,p_attribute14                  => p_appr_objs(I).attribute14
	,p_attribute15                  => p_appr_objs(I).attribute15
	,p_attribute16                  => p_appr_objs(I).attribute16
	,p_attribute17                  => p_appr_objs(I).attribute17
	,p_attribute18                  => p_appr_objs(I).attribute18
	,p_attribute19                  => p_appr_objs(I).attribute19
	,p_attribute20                  => p_appr_objs(I).attribute20
	,p_attribute21                  => p_appr_objs(I).attribute21
	,p_attribute22                  => p_appr_objs(I).attribute22
	,p_attribute23                  => p_appr_objs(I).attribute23
	,p_attribute24                  => p_appr_objs(I).attribute24
	,p_attribute25                  => p_appr_objs(I).attribute25
	,p_attribute26                  => p_appr_objs(I).attribute26
	,p_attribute27                  => p_appr_objs(I).attribute27
	,p_attribute28                  => p_appr_objs(I).attribute28
	,p_attribute29                  => p_appr_objs(I).attribute29
	,p_attribute30                  => p_appr_objs(I).attribute30
	,p_scorecard_id                 => p_appr_objs(I).scorecard_id
	,p_copied_from_library_id       => p_appr_objs(I).copied_from_library_id
	,p_copied_from_objective_id     => p_appr_objs(I).objective_id
	,p_aligned_with_objective_id    => p_appr_objs(I).aligned_with_objective_id
	,p_next_review_date             => p_appr_objs(I).next_review_date
	,p_group_code                   => p_appr_objs(I).group_code
	,p_priority_code                => p_appr_objs(I).priority_code
	,p_appraise_flag                => p_appr_objs(I).appraise_flag
	,p_verified_flag                => p_appr_objs(I).verified_flag
	,p_target_value                 => p_appr_objs(I).target_value
	,p_weighting_percent            => p_appr_objs(I).weighting_percent
	,p_complete_percent             => p_appr_objs(I).complete_percent
	,p_uom_code                     => p_appr_objs(I).uom_code
	,p_measurement_style_code       => p_appr_objs(I).measurement_style_code
	,p_measure_name                 => p_appr_objs(I).measure_name
	,p_measure_type_code            => p_appr_objs(I).measure_type_code
	,p_measure_comments             => p_appr_objs(I).measure_comments
	,p_sharing_access_code          => p_appr_objs(I).sharing_access_code
	,p_weighting_over_100_warning   => l_weighting_over_100_warning
	,p_weighting_appraisal_warning  => l_weighting_appraisal_warning
	,p_objective_id                 => l_objective_id
	,p_object_version_number        => l_object_version_number
	);
	--
	-- Convert API warning boolean parameter values to specific
	-- messages and add them to Multiple Message List
	--
	if l_weighting_over_100_warning then
	  fnd_message.set_name('PER', 'HR_50198_WPM_WEIGHT_WARN');
	   hr_multi_message.add
		 (p_message_type => hr_multi_message.g_warning_msg);
	end if;
	if l_weighting_appraisal_warning then
	 fnd_message.set_name('PER', 'HR_50223_WPM_APPRAISE_WARN');
	  hr_multi_message.add
		(p_message_type => hr_multi_message.g_warning_msg);
	end if;

    END LOOP;

EXCEPTION WHEN OTHERS THEN
    raise;
END;

PROCEDURE update_appr_objectives(p_appr_objs in appr_obj_table)
IS

I INTEGER default 0;
l_objective_id number;
--
-- Variables for IN/OUT parameters
l_weighting_over_100_warning    boolean;
l_weighting_appraisal_warning   boolean;
l_object_version_number number;

BEGIN

    FOR I IN 1 ..p_appr_objs.count LOOP
	--
	-- Call API
	--
        l_object_version_number :=  p_appr_objs(I).object_version_number;
	hr_objectives_api.update_objective
	(p_validate                     => false
	,p_effective_date               => trunc(sysdate) --<== ?
	,p_objective_id                 => p_appr_objs(I).objective_id
	,p_object_version_number        => l_object_version_number
	,p_scorecard_id                 => null
	,p_weighting_over_100_warning   => l_weighting_over_100_warning
	,p_weighting_appraisal_warning  => l_weighting_appraisal_warning
	);
	--
	-- Convert API warning boolean parameter values to specific
	-- messages and add them to Multiple Message List
	--
	if l_weighting_over_100_warning then
	  fnd_message.set_name('PER', 'HR_50198_WPM_WEIGHT_WARN');
	   hr_multi_message.add
		 (p_message_type => hr_multi_message.g_warning_msg);
	end if;
	if l_weighting_appraisal_warning then
	 fnd_message.set_name('PER', 'HR_50223_WPM_APPRAISE_WARN');
	  hr_multi_message.add
		(p_message_type => hr_multi_message.g_warning_msg);
	end if;

    END LOOP;

EXCEPTION WHEN OTHERS THEN
    raise;
END;



PROCEDURE post_appraisal_completion(p_appraisal_id in number)
IS
l_plan_id per_perf_mgmt_plans.plan_id%type;
l_curr_appr_tmplt_id per_appraisal_templates.appraisal_template_id%type;

CURSOR get_plan_template_id IS
   SELECT plan_id, appraisal_template_id
   FROM per_appraisals
   WHERE appraisal_id = p_appraisal_id;

l_appr_objs appr_obj_table;

BEGIN

-- first check if appraisal is part of a plan
OPEN get_plan_template_id;
FETCH get_plan_template_id into l_plan_id, l_curr_appr_tmplt_id;
CLOSE get_plan_template_id;  -- close cursor variable
IF (l_plan_id is not null) THEN

  -- bulk fetch all existing objectives and scorecard_id with appraisalId as input into table
    OPEN get_appr_objectives(p_appraisal_id);
    FETCH get_appr_objectives BULK COLLECT into l_appr_objs;
    CLOSE get_appr_objectives;  -- close cursor variable
  -- Loop thru the table and create objective with copied objectiveid and scorecardid
    create_new_objectives(l_appr_objs);
  -- Loop thru the rows and update all existing objectives with null scorecardid
    update_appr_objectives(l_appr_objs);

END IF;


EXCEPTION WHEN OTHERS THEN
    raise;
END;

PROCEDURE update_succ_plan_eit(p_appraisal_id IN NUMBER) IS
  l_proc varchar2(100);
  CURSOR csr_succ_details(p_appraisal_id NUMBER) IS
    SELECT appraisal_id
          ,appraisee_person_id
          ,appraisal_period_start_date
          ,appraisal_period_end_date
          ,potential_readiness_level
          ,retention_potential
     FROM  per_appraisals
     WHERE appraisal_id = p_appraisal_id;
     l_person_extra_info_id NUMBER;
     l_ovn NUMBER;
BEGIN
  l_proc := 'HR_COMPLETE_APPRAISAL_SS.UPDATE_SUCC_PLAN_EIT';
  hr_utility.set_location('Entering:'||l_proc,10);
  FOR i IN csr_succ_details(p_appraisal_id)
  LOOP
    --insert only if potential data entered in appraisal
    IF i.potential_readiness_level IS NOT NULL OR i.retention_potential IS NOT
NULL THEN
      BEGIN
	hr_person_extra_info_api.create_person_extra_info
	  (p_person_id                => i.appraisee_person_id
	  ,p_information_type         => 'PER_SUCCESSION_MGMT_INFO'
	  ,p_pei_information_category => 'PER_SUCCESSION_MGMT_INFO'
	  ,p_pei_information1         => i.potential_readiness_level
	  ,p_pei_information4         => i.retention_potential
	  ,p_pei_information5         =>
fnd_date.date_to_canonical(i.appraisal_period_start_date)
	  ,p_pei_information6         =>
fnd_date.date_to_canonical(i.appraisal_period_end_date)
	  ,p_pei_information7         => i.appraisal_id
	  ,p_pei_information8         =>
fnd_date.date_to_canonical(sysdate)
	  ,p_person_extra_info_id     => l_person_extra_info_id
	  ,p_object_version_number    => l_ovn
	  );
       EXCEPTION
         WHEN OTHERS THEN
           hr_utility.set_location('Error in :'||l_proc,90);
           hr_utility.trace(SUBSTR(SQLERRM,1,240));
           RAISE;
       END;
    END IF;
  END LOOP;
  hr_utility.set_location('Leaving:'||l_proc,100);
END update_succ_plan_eit;
--
PROCEDURE COMPLETE_APPR
   ( item_type IN varchar2,
     item_key IN varchar2,
     p_result_out in out nocopy varchar2)
   IS
    appraisal_id   per_appraisals.appraisal_id%type;
    l_ins_ovn number;
    l_ins_comp_id number;
    next_comp_ele_id per_competence_elements.competence_element_id%TYPE;
    l_person_id number;
    l_log varchar2(4000);
    chg_appr_status varchar2(2);
    apply_pers_profile_status varchar2(2);
    upd_train_comps_status varchar2(2);
    upd_create_event_status varchar2(2);
    lv_chg_appr_status_log wf_item_attributes.text_default%TYPE;
    lv_apply_pers_comps_log wf_item_attributes.text_default%TYPE;
    lv_upd_train_comps_status_log wf_item_attributes.text_default%TYPE;
    lv_upd_create_event_status_log wf_item_attributes.text_default%TYPE;
    p_new_appraisal boolean;
    l_talent_mang_src_typ per_appraisal_templates.COMP_PROFILE_SOURCE_TYPE%TYPE;
    l_available_flag per_appraisal_templates.available_flag%TYPE;
    update_personal_profile varchar2(100) default null;
    l_proc varchar2(100);
    cursor c_appr_template_details(c_appraisal_id  in number) is
       select available_flag ,update_personal_comp_profile,comp_profile_source_type
       from per_appraisal_templates pat ,per_appraisals pa where
       pa.appraisal_template_id = pat.appraisal_template_id
       and pa.appraisal_id = c_appraisal_id;

      --
      -- SSHR Attachment feature changes : 8814550
      --
      l_sel_person_id NUMBER;
      l_attach_status varchar2(80);
      l_appraisal_id NUMBER;
      l_source_pk1_value NUMBER;

BEGIN
        l_proc := 'HR_COMPLETE_APPRAISAL_SS.COMPLETE_APPR';
--      hr_utility.trace_on(null,'APPR');
        hr_utility.set_location(' Entering:' || l_proc,5);
        appraisal_id := wf_engine.GetItemAttrNumber (itemtype => item_type ,
                             itemkey         => item_key ,
                             aname           => 'APPRAISAL_ID',
                             ignore_notfound => true);
        hr_utility.set_location(' Entering:' || l_proc,10);
        if appraisal_id is null then
        hr_utility.set_location(' Entering:' || l_proc,20);
         l_log := l_log || 'No Appraisal Id for this WorkFlow Transaction';
         raise lv_no_appraisal;
        end if;

        -- SSHR Attachment feature changes : 8814550
        l_appraisal_id := appraisal_id;
        select pa.appraisee_person_id into l_sel_person_id
        from per_appraisals pa
        where pa.appraisal_id = l_appraisal_id;

        select transaction_id into l_source_pk1_value
        from hr_api_transactions
        where transaction_ref_table = 'PER_APPRAISALS'
        and transaction_ref_id = l_appraisal_id;

        open c_appr_template_details(appraisal_id);
        fetch c_appr_template_details into l_available_flag,update_personal_profile,l_talent_mang_src_typ;
        if (c_appr_template_details%NOTFOUND) then
           hr_utility.set_message(800,'HR_52256_APR_TEMP_MANDATORY');
           hr_utility.raise_error;
        end if;

        hr_utility.set_location(' Entering:' || l_proc,30);
        check_item_attribute(item_type, item_key, gv_appr_compl_status);
        hr_utility.set_location(' Entering:' || l_proc,35);
        check_item_attribute(item_type, item_key, gv_upd_appr_status_log);
        hr_utility.set_location(' Entering:' || l_proc,40);
        check_item_attribute(item_type, item_key, gv_apply_asses_comps_log);
        hr_utility.set_location(' Entering:' || l_proc,45);
        check_item_attribute(item_type, item_key, gv_create_event_log);
        hr_utility.set_location(' Entering:' || l_proc,50);
        check_item_attribute(item_type, item_key, gv_upd_trn_act_status_log);
        hr_utility.set_location(' Entering:' || l_proc,55);

        savepoint complete_appraisal_status;

        -- change the appraisal system status to completed
        -- if this errors out then exit from the procudure
        -- with out processing furhter
        hr_utility.set_location(' Entering:' || l_proc,60);
        change_appr_status(appraisal_id, item_type, item_key, lv_chg_appr_status_log, chg_appr_status);
        hr_utility.set_location(' Entering:' || l_proc,70);
        set_appr_status_log(item_type, item_key, chg_appr_status, gv_upd_appr_status_log, lv_chg_appr_status_log);
        hr_utility.set_location(' Entering:' || l_proc,75);

        -- SSHR Attachment feature changes : 8814550
        hr_utility.set_location('merge_attachments Start : l_sel_person_id = ' || l_sel_person_id || ' ' ||l_proc, 76);

        HR_UTIL_MISC_SS.merge_attachments( p_dest_entity_name => 'PER_PEOPLE_F'
                           ,p_source_pk1_value => l_source_pk1_value
                           ,p_dest_pk1_value => l_sel_person_id
                           ,p_return_status => l_attach_status);

        hr_utility.set_location('merge_attachments End: l_attach_status = ' || l_attach_status || ' ' ||l_proc, 76);


        -- create and event and add a performance record
        if l_available_flag is null then
            hr_utility.set_location(' Entering:' || l_proc,77);
            update_personal_profile := fnd_profile.value('HR_APPLY_COMPETENCIES_TO_PERSON');
            l_talent_mang_src_typ := fnd_profile.value('HR_TALENT_MGMT_SRC_TYPE');
       end if;
       hr_utility.set_location(' Entering:' || l_proc,80);
       p_new_appraisal := is_new_appraisal(item_type, item_key);
       if(update_personal_profile is not null and update_personal_profile = 'Y') then
            hr_utility.set_location(' Entering:' || l_proc,85);
            apply_to_personal_profile(appraisal_id, lv_apply_pers_comps_log, apply_pers_profile_status, p_new_appraisal,l_talent_mang_src_typ);
            hr_utility.set_location(' Entering:' || l_proc,90);
            set_appr_status_log(item_type, item_key, apply_pers_profile_status, gv_apply_asses_comps_log, lv_apply_pers_comps_log);
            hr_utility.set_location(' Entering:' || l_proc,95);
       end if;
------------ Update Succession Plan Details
      if NVL(fnd_profile.value('HR_SUCCESSION_MGMT_LICENSED'),'N') = 'Y' THEN
        hr_utility.set_location('before update_succ_plan_eit:'||l_proc,96);
        update_succ_plan_eit(appraisal_id);
        hr_utility.set_location('before update_succ_plan_eit:'||l_proc,96);
      end if;
------------

        -- update the OTA status
        --update_train_component_status(appraisal_id, item_type, item_key, l_log, p_result_out);
        hr_utility.set_location(' Entering:' || l_proc,100);
        update_train_component_status(appraisal_id, lv_upd_train_comps_status_log, upd_train_comps_status, p_new_appraisal);
        hr_utility.set_location(' Entering:' || l_proc,105);
        set_appr_status_log(item_type, item_key, upd_train_comps_status, gv_upd_trn_act_status_log, lv_upd_train_comps_status_log);
        hr_utility.set_location(' Entering:' || l_proc,110);

        create_event(appraisal_id, lv_upd_create_event_status_log, upd_create_event_status, p_new_appraisal);
        hr_utility.set_location(' Entering:' || l_proc,115);
        set_appr_status_log(item_type, item_key, upd_create_event_status, gv_create_event_log, lv_upd_create_event_status_log);
        hr_utility.set_location(' Entering:' || l_proc,120);
        -- add the following line to disable multi messaging for fixing bug#5947176
        hr_multi_message.disable_message_list;
        -- END changes for bug#5947176

        post_appraisal_completion(appraisal_id);

        if( chg_appr_status = 'W' or apply_pers_profile_status = 'W' or upd_train_comps_status = 'W' or upd_create_event_status = 'W') then
        hr_utility.set_location(' Entering:' || l_proc,125);
            p_result_out := 'W';
        else
        hr_utility.set_location(' Entering:' || l_proc,130);
            p_result_out := 'S';
        end if;




EXCEPTION
    -- when there is an exception it is due to change appraisal status
    -- for all other tasks it there wont be any exception raise,
    -- instead the errors are written to WorkFlow so that appraisal
    -- can read and display corresponding message / warning.
    WHEN lv_no_appraisal THEN
        p_result_out := 'E';
        hr_utility.set_location(' Entering:' || l_proc,200);
        set_appr_status_log(item_type, item_key, 'E', gv_upd_appr_status_log, lv_chg_appr_status_log);
    WHEN others THEN
        hr_utility.set_location(' Entering:' || l_proc,300);
        rollback to complete_appraisal_status;
        p_result_out := 'E';
        set_appr_status_log(item_type, item_key, 'E', gv_upd_appr_status_log, lv_chg_appr_status_log);
END; -- Procedure



PROCEDURE SEND_NOTIFICATION
   ( p_item_type IN varchar2,
     p_item_key IN varchar2,
     p_result_out in out nocopy varchar2)
   IS
    l_appraisal_id   per_appraisals.appraisal_id%type;
    update_personal_profile varchar2(100) default null;

    CURSOR get_appraisee_access(appr_id per_appraisals.appraisal_id%TYPE) IS
    select appraisal_id, appraisee_access, system_type from per_appraisals where appraisal_id = appr_id;

    TYPE appraisal_access_info is RECORD (
        appraisal_id   per_appraisals.appraisal_id%TYPE,
        appraisee_access  per_appraisals.appraisee_access%TYPE,
        system_type per_appraisals.system_type%TYPE
    );

    appr_access_info appraisal_access_info;


BEGIN

    p_result_out := 'N';
    l_appraisal_id := wf_engine.GetItemAttrNumber (itemtype => p_item_type ,
                             itemkey  => p_item_key ,
                             aname => 'APPRAISAL_ID',
                             ignore_notfound=>false);


    open get_appraisee_access(l_appraisal_id);
    fetch get_appraisee_access into appr_access_info;
    if get_appraisee_access%FOUND then
        if appr_access_info.system_type is not null  then
	     --Bug 8659708
 	     if not (appr_access_info.system_type = 'SELF') then
              --if( appr_access_info.system_type = 'MGR360' or appr_access_info.system_type = 'MGRSTD' ) then
             if not (appr_access_info.appraisee_access = 'NONE' or appr_access_info.appraisee_access is null) then
              p_result_out := 'Y';
             end if;
           else
              p_result_out := 'Y';
           end if;
        end if;
    end if;
    close get_appraisee_access;
EXCEPTION
    WHEN OTHERS THEN
    raise;
END;

PROCEDURE COMPLETE_APPR_HR
   ( item_type IN varchar2,
     item_key IN varchar2,
     p_result_out in out nocopy varchar2)
IS
  lv_provide_overall_feedback per_appraisals.provide_overall_feedback%TYPE;
  l_appraisal_id per_appraisals.appraisal_id%TYPE;

BEGIN

 l_appraisal_id := wf_engine.GetItemAttrNumber (itemtype => item_type ,
                             itemkey         => item_key ,
                             aname           => 'APPRAISAL_ID',
                             ignore_notfound => true);

 SELECT provide_overall_feedback INTO lv_provide_overall_feedback FROM per_appraisals WHERE appraisal_id=l_appraisal_id;
 IF(lv_provide_overall_feedback = 'Y') THEN
	UPDATE per_appraisals SET provide_overall_feedback = 'N' where appraisal_id=l_appraisal_id;
 END IF;
	HR_COMPLETE_APPRAISAL_SS.COMPLETE_APPR(item_type => item_type , item_key=> item_key ,p_result_out=> p_result_out );

 IF(lv_provide_overall_feedback = 'Y') THEN
 UPDATE per_appraisals SET provide_overall_feedback = 'Y' WHERE appraisal_id=l_appraisal_id;
 END IF;
 COMMIT;

 EXCEPTION

 WHEN others THEN
        rollback;
        p_result_out := 'E';
 END COMPLETE_APPR_HR;

END HR_COMPLETE_APPRAISAL_SS;

/
