--------------------------------------------------------
--  DDL for Package Body OTA_LEARNER_ACCESS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_LEARNER_ACCESS_UTIL" as
/* $Header: otlrnacc.pkb 120.30.12010000.6 2009/09/16 08:34:32 pekasi ship $ */

person_ug_map_rec_table  ota_learner_access_util.person_ug_map_table;
t_ug_learner_list_table  ota_learner_access_util.ug_learner_list_table;

   cursor csr_evt_tree(
      p_event_id ota_events.event_id%type) is
   select   o.offering_id, i.activity_version_id, i.category_usage_id,
            c1.parent_cat_usage_id as parent_cat_usage_id_1,
            c2.parent_cat_usage_id as parent_cat_usage_id_2,
            c3.parent_cat_usage_id as parent_cat_usage_id_3,
            c4.parent_cat_usage_id as parent_cat_usage_id_4
   from     ota_events e,
            ota_offerings o,
            ota_act_cat_inclusions i,
            ota_category_usages c1,
            ota_category_usages c2,
            ota_category_usages c3,
            ota_category_usages c4
   where    e.event_id = p_event_id and
            e.parent_offering_id = o.offering_id and
            o.activity_version_id = i.activity_version_id and
            i.primary_flag = 'Y' and
            i.category_usage_id = c1.category_usage_id and
            c1.parent_cat_usage_id = c2.category_usage_id(+) and
            c2.parent_cat_usage_id = c3.category_usage_id(+) and
            c3.parent_cat_usage_id = c4.category_usage_id(+);


   cursor csr_lp_tree(
      p_learning_path_id ota_learning_paths.learning_path_id%type) is
   select   i.category_usage_id,
            c1.parent_cat_usage_id as parent_cat_usage_id_1,
            c2.parent_cat_usage_id as parent_cat_usage_id_2,
            c3.parent_cat_usage_id as parent_cat_usage_id_3,
            c4.parent_cat_usage_id as parent_cat_usage_id_4
   from     ota_lp_cat_inclusions i,
            ota_category_usages c1,
            ota_category_usages c2,
            ota_category_usages c3,
            ota_category_usages c4
   where    i.learning_path_id = p_learning_path_id and
            i.primary_flag = 'Y' and
            i.category_usage_id = c1.category_usage_id and
            c1.parent_cat_usage_id = c2.category_usage_id(+) and
            c2.parent_cat_usage_id = c3.category_usage_id(+) and
            c3.parent_cat_usage_id = c4.category_usage_id(+);

   cursor csr_forum_tree(
      p_forum_id ota_forums_b.forum_id%type) is
   select   i.object_id,
            c1.parent_cat_usage_id as parent_cat_usage_id_1,
            c2.parent_cat_usage_id as parent_cat_usage_id_2,
            c3.parent_cat_usage_id as parent_cat_usage_id_3,
            c4.parent_cat_usage_id as parent_cat_usage_id_4
   from     ota_frm_obj_inclusions i,
            ota_category_usages c1,
            ota_category_usages c2,
            ota_category_usages c3,
            ota_category_usages c4
   where    i.forum_id = p_forum_id and
            i.primary_flag = 'Y' and
            i.object_id = c1.category_usage_id and
            i.object_type = 'C' and
            c1.parent_cat_usage_id = c2.category_usage_id(+) and
            c2.parent_cat_usage_id = c3.category_usage_id(+) and
            c3.parent_cat_usage_id = c4.category_usage_id(+);

   cursor csr_chat_tree(
      p_chat_id ota_chats_b.chat_id%type) is
   select   i.object_id,
            c1.parent_cat_usage_id as parent_cat_usage_id_1,
            c2.parent_cat_usage_id as parent_cat_usage_id_2,
            c3.parent_cat_usage_id as parent_cat_usage_id_3,
            c4.parent_cat_usage_id as parent_cat_usage_id_4
   from     ota_chat_obj_inclusions i,
            ota_category_usages c1,
            ota_category_usages c2,
            ota_category_usages c3,
            ota_category_usages c4
   where    i.chat_id = p_chat_id and
            i.primary_flag = 'Y' and
            i.object_id = c1.category_usage_id and
            i.object_type = 'C' and
            c1.parent_cat_usage_id = c2.category_usage_id(+) and
            c2.parent_cat_usage_id = c3.category_usage_id(+) and
            c3.parent_cat_usage_id = c4.category_usage_id(+);


   cursor csr_cert_tree(
      p_certification_id ota_certifications_b.certification_id%type) is
   select   i.category_usage_id,
            c1.parent_cat_usage_id as parent_cat_usage_id_1,
            c2.parent_cat_usage_id as parent_cat_usage_id_2,
            c3.parent_cat_usage_id as parent_cat_usage_id_3,
            c4.parent_cat_usage_id as parent_cat_usage_id_4
   from     ota_cert_cat_inclusions i,
            ota_category_usages c1,
            ota_category_usages c2,
            ota_category_usages c3,
            ota_category_usages c4
   where    i.certification_id = p_certification_id and
            i.primary_flag = 'Y' and
            i.category_usage_id = c1.category_usage_id and
            c1.parent_cat_usage_id = c2.category_usage_id(+) and
            c2.parent_cat_usage_id = c3.category_usage_id(+) and
            c3.parent_cat_usage_id = c4.category_usage_id(+);


   cursor csr_evt_assoc(
      p_self_enroll_only varchar2,
      p_event_id ota_events.event_id%type,
      p_offering_id ota_offerings.offering_id%type,
      p_activity_version_id ota_activity_versions.activity_version_id%type,
      p_category_usage_id ota_category_usages.category_usage_id%type,
      p_parent_cat_usage_id_1 ota_category_usages.category_usage_id%type,
      p_parent_cat_usage_id_2 ota_category_usages.category_usage_id%type,
      p_parent_cat_usage_id_3 ota_category_usages.category_usage_id%type,
      p_parent_cat_usage_id_4 ota_category_usages.category_usage_id%type) is
   select   ea.organization_id, ea.org_structure_version_id, ea.job_id, ea.position_id, ea.person_id, ea.self_enrollment_flag, ea.match_type,ea.user_group_id
   from     ota_event_associations ea
   where    ea.party_id is null and
            ea.customer_id is null and
            (p_self_enroll_only = 'N' or ea.self_enrollment_flag = 'Y') and
            (
            ea.event_id = p_event_id or
            ea.offering_id = p_offering_id or
            ea.activity_version_id = p_activity_version_id or
            ea.category_usage_id in (p_category_usage_id, p_parent_cat_usage_id_1, p_parent_cat_usage_id_2, p_parent_cat_usage_id_3, p_parent_cat_usage_id_4));


 /*Bug 	7046019- Modified cursor check_mandatory_evt_assoc to include learner groups
 Cursor check_mandatory_evt_assoc(
   p_event_id ota_events.event_id%type,
   p_person_id ota_event_associations.person_id%type,
   p_as_of in date
   ) is
   select ea.event_association_id
   from
   ota_event_associations ea,
   per_all_assignments_f paf
   where ea.event_id = p_event_id
   and paf.person_id = p_person_id
   AND nvl(ea.mandatory_enrollment_flag,'N') = 'Y'
   AND paf.assignment_type in ('E','A','C')
   AND ( (nvl(fnd_profile.value('OTA_ALLOW_FUTURE_ENDDATED_EMP_ENROLLMENTS'),'N') = 'Y'
   AND trunc(sysdate) BETWEEN paf.effective_start_date and paf.effective_end_date)
   OR  nvl(p_as_of, trunc(sysdate)) between paf.effective_start_date and paf.effective_end_date )
   AND nvl(ea.job_id, -1) = decode(ea.job_id, null, -1, paf.job_id)
   AND nvl(ea.position_id,-1) = decode(ea.position_id, null, -1,paf.position_id)
   AND nvl(ea.person_id,-1) = decode(ea.person_id,null,-1,p_person_id)
   AND
	(
	( nvl(ea.organization_id, -1) = decode(ea.organization_id, null, -1, paf.organization_id)) OR
	( ea.org_structure_version_id IS NOT NULL AND learner_belongs_to_child_org(ea.org_structure_version_id,ea.organization_id,paf.person_id)='Y')
	);*/

Cursor check_mandatory_evt_assoc(
	   p_event_id ota_events.event_id%type,
	   p_person_id ota_event_associations.person_id%type,
	   p_as_of in date
	   ) is
	   select ea.event_association_id
	   	   from
	   	   ota_event_associations ea,
	   	   per_all_assignments_f paf
	   	   where ea.event_id = p_event_id
	   	   and paf.person_id = p_person_id
	   	   AND nvl(ea.mandatory_enrollment_flag,'N') = 'Y'
	   	   AND paf.assignment_type in ('E','A','C')
	   	   AND ( (nvl(fnd_profile.value('OTA_ALLOW_FUTURE_ENDDATED_EMP_ENROLLMENTS'),'N') = 'Y'
	   	   AND trunc(sysdate) BETWEEN paf.effective_start_date and paf.effective_end_date)
	   	   OR  nvl(p_as_of, trunc(sysdate)) between paf.effective_start_date and paf.effective_end_date )
	   	   AND ((ea.user_group_id is null
	          AND  nvl(ea.job_id, -1) = decode(ea.job_id, null, -1, paf.job_id)
	   	   AND nvl(ea.position_id,-1) = decode(ea.position_id, null, -1,paf.position_id)
	   	   AND nvl(ea.person_id,-1) = decode(ea.person_id,null,-1,p_person_id)
	   	   AND(( nvl(ea.organization_id, -1) = decode(ea.organization_id, null, -1, paf.organization_id)) OR
	   		( ea.org_structure_version_id IS NOT NULL AND learner_belongs_to_child_org(ea.org_structure_version_id,ea.organization_id,paf.person_id)='Y'))
	               )OR(ea.user_group_id is not null AND is_learner_in_user_group(p_person_id,ea.user_group_id, ota_general.get_business_group_id)= 'Y')
	);


   cursor csr_evt_assoc_ext(
      p_self_enroll_only varchar2,
      p_party_id hz_parties.party_id%type,
      p_event_id ota_events.event_id%type,
      p_offering_id ota_offerings.offering_id%type,
      p_activity_version_id ota_activity_versions.activity_version_id%type,
      p_category_usage_id ota_category_usages.category_usage_id%type,
      p_parent_cat_usage_id_1 ota_category_usages.category_usage_id%type,
      p_parent_cat_usage_id_2 ota_category_usages.category_usage_id%type,
      p_parent_cat_usage_id_3 ota_category_usages.category_usage_id%type,
      p_parent_cat_usage_id_4 ota_category_usages.category_usage_id%type) is
   select   1
   from     ota_event_associations ea
   where    ea.party_id = p_party_id and
            (p_self_enroll_only = 'N' or ea.self_enrollment_flag = 'Y') and
            (
            ea.event_id = p_event_id or
            ea.offering_id = p_offering_id or
            ea.activity_version_id = p_activity_version_id or
            ea.category_usage_id in (p_category_usage_id, p_parent_cat_usage_id_1, p_parent_cat_usage_id_2, p_parent_cat_usage_id_3, p_parent_cat_usage_id_4));


   cursor csr_category_assoc(
      p_self_enroll_only varchar2,
      p_category_usage_id ota_category_usages.category_usage_id%type) is
   select   ea.organization_id, ea.org_structure_version_id, ea.job_id, ea.position_id, ea.person_id, ea.self_enrollment_flag, ea.match_type,ea.user_group_id
   from     ota_event_associations ea,
   (
      select   cu.category_usage_id
      from     ota_category_usages cu
      where    cu.type = 'C'
      connect by  cu.category_usage_id = prior cu.parent_cat_usage_id
      start with  cu.category_usage_id = p_category_usage_id
   ) cat
   where    ea.party_id is null and
            ea.customer_id is null and
            (p_self_enroll_only = 'N' or ea.self_enrollment_flag = 'Y') and
            ea.category_usage_id = cat.category_usage_id;


   cursor csr_category_assoc_ext(
      p_self_enroll_only varchar2,
      p_party_id           in ota_event_associations.party_id%type,
      p_category_usage_id ota_category_usages.category_usage_id%type) is
   select   1
   from     ota_event_associations ea,
   (
      select   cu.category_usage_id
      from     ota_category_usages cu
      where    cu.type = 'C'
      connect by  cu.category_usage_id = prior cu.parent_cat_usage_id
      start with  cu.category_usage_id = p_category_usage_id
   ) cat
   where    ea.party_id = p_party_id and
            (p_self_enroll_only = 'N' or ea.self_enrollment_flag = 'Y') and
            ea.category_usage_id = cat.category_usage_id;


   cursor csr_lp_assoc(
      p_self_enroll_only varchar2,
      p_learning_path_id in ota_learning_paths.learning_path_id%type,
      p_category_usage_id ota_category_usages.category_usage_id%type,
      p_parent_cat_usage_id_1 ota_category_usages.category_usage_id%type,
      p_parent_cat_usage_id_2 ota_category_usages.category_usage_id%type,
      p_parent_cat_usage_id_3 ota_category_usages.category_usage_id%type,
      p_parent_cat_usage_id_4 ota_category_usages.category_usage_id%type) is
   select   ea.organization_id, ea.org_structure_version_id, ea.job_id, ea.position_id, ea.person_id, ea.self_enrollment_flag, ea.match_type,ea.user_group_id
   from     ota_event_associations ea
   where    ea.customer_id is null and
            ea.party_id is null and
            (p_self_enroll_only = 'N' or ea.self_enrollment_flag = 'Y') and
            (
            ea.learning_path_id = p_learning_path_id or
            ea.category_usage_id in (p_category_usage_id, p_parent_cat_usage_id_1, p_parent_cat_usage_id_2, p_parent_cat_usage_id_3, p_parent_cat_usage_id_4));


   cursor csr_lp_assoc_ext(
      p_self_enroll_only varchar2,
      p_party_id hz_parties.party_id%type,
      p_learning_path_id in ota_learning_paths.learning_path_id%type,
      p_category_usage_id ota_category_usages.category_usage_id%type,
      p_parent_cat_usage_id_1 ota_category_usages.category_usage_id%type,
      p_parent_cat_usage_id_2 ota_category_usages.category_usage_id%type,
      p_parent_cat_usage_id_3 ota_category_usages.category_usage_id%type,
      p_parent_cat_usage_id_4 ota_category_usages.category_usage_id%type) is
   select   1
   from     ota_event_associations ea
   where    ea.party_id = p_party_id and
            (p_self_enroll_only = 'N' or ea.self_enrollment_flag = 'Y') and
            (
            ea.learning_path_id = p_learning_path_id or
            ea.category_usage_id in (p_category_usage_id, p_parent_cat_usage_id_1, p_parent_cat_usage_id_2, p_parent_cat_usage_id_3, p_parent_cat_usage_id_4));


   cursor csr_forum_assoc(
      p_self_enroll_only varchar2,
      p_forum_id in ota_forums_b.forum_id%type,
      p_category_usage_id ota_category_usages.category_usage_id%type,
      p_parent_cat_usage_id_1 ota_category_usages.category_usage_id%type,
      p_parent_cat_usage_id_2 ota_category_usages.category_usage_id%type,
      p_parent_cat_usage_id_3 ota_category_usages.category_usage_id%type,
      p_parent_cat_usage_id_4 ota_category_usages.category_usage_id%type) is
   select   ea.organization_id, ea.org_structure_version_id, ea.job_id, ea.position_id, ea.person_id, ea.self_enrollment_flag, ea.match_type,ea.user_group_id
   from     ota_event_associations ea
   where    ea.customer_id is null and
            ea.party_id is null and
            (p_self_enroll_only = 'N' or ea.self_enrollment_flag = 'Y') and
            (
            ea.forum_id = p_forum_id or
            ea.category_usage_id in (p_category_usage_id, p_parent_cat_usage_id_1, p_parent_cat_usage_id_2, p_parent_cat_usage_id_3, p_parent_cat_usage_id_4));


   cursor csr_forum_assoc_ext(
      p_self_enroll_only varchar2,
      p_party_id hz_parties.party_id%type,
      p_forum_id in ota_forums_b.forum_id%type,
      p_category_usage_id ota_category_usages.category_usage_id%type,
      p_parent_cat_usage_id_1 ota_category_usages.category_usage_id%type,
      p_parent_cat_usage_id_2 ota_category_usages.category_usage_id%type,
      p_parent_cat_usage_id_3 ota_category_usages.category_usage_id%type,
      p_parent_cat_usage_id_4 ota_category_usages.category_usage_id%type) is
   select   1
   from     ota_event_associations ea
   where    ea.party_id = p_party_id and
            (p_self_enroll_only = 'N' or ea.self_enrollment_flag = 'Y') and
            (
            ea.forum_id = p_forum_id or
            ea.category_usage_id in (p_category_usage_id, p_parent_cat_usage_id_1, p_parent_cat_usage_id_2, p_parent_cat_usage_id_3, p_parent_cat_usage_id_4));


   cursor csr_chat_assoc(
      p_self_enroll_only varchar2,
      p_chat_id in ota_chats_b.chat_id%type,
      p_category_usage_id ota_category_usages.category_usage_id%type,
      p_parent_cat_usage_id_1 ota_category_usages.category_usage_id%type,
      p_parent_cat_usage_id_2 ota_category_usages.category_usage_id%type,
      p_parent_cat_usage_id_3 ota_category_usages.category_usage_id%type,
      p_parent_cat_usage_id_4 ota_category_usages.category_usage_id%type) is
   select   ea.organization_id, ea.org_structure_version_id, ea.job_id, ea.position_id, ea.person_id, ea.self_enrollment_flag, ea.match_type,ea.user_group_id
   from     ota_event_associations ea
   where    ea.customer_id is null and
            ea.party_id is null and
            (p_self_enroll_only = 'N' or ea.self_enrollment_flag = 'Y') and
            (
            ea.chat_id = p_chat_id or
            ea.category_usage_id in (p_category_usage_id, p_parent_cat_usage_id_1, p_parent_cat_usage_id_2, p_parent_cat_usage_id_3, p_parent_cat_usage_id_4));


   cursor csr_chat_assoc_ext(
      p_self_enroll_only varchar2,
      p_party_id hz_parties.party_id%type,
      p_chat_id in ota_chats_b.chat_id%type,
      p_category_usage_id ota_category_usages.category_usage_id%type,
      p_parent_cat_usage_id_1 ota_category_usages.category_usage_id%type,
      p_parent_cat_usage_id_2 ota_category_usages.category_usage_id%type,
      p_parent_cat_usage_id_3 ota_category_usages.category_usage_id%type,
      p_parent_cat_usage_id_4 ota_category_usages.category_usage_id%type) is
   select   1
   from     ota_event_associations ea
   where    ea.party_id = p_party_id and
            (p_self_enroll_only = 'N' or ea.self_enrollment_flag = 'Y') and
            (
            ea.chat_id = p_chat_id or
            ea.category_usage_id in (p_category_usage_id, p_parent_cat_usage_id_1, p_parent_cat_usage_id_2, p_parent_cat_usage_id_3, p_parent_cat_usage_id_4));


   cursor csr_cert_assoc(
      p_self_enroll_only varchar2,
      p_certification_id in ota_certifications_b.certification_id%type,
      p_category_usage_id ota_category_usages.category_usage_id%type,
      p_parent_cat_usage_id_1 ota_category_usages.category_usage_id%type,
      p_parent_cat_usage_id_2 ota_category_usages.category_usage_id%type,
      p_parent_cat_usage_id_3 ota_category_usages.category_usage_id%type,
      p_parent_cat_usage_id_4 ota_category_usages.category_usage_id%type) is
   select   ea.organization_id, ea.org_structure_version_id, ea.job_id, ea.position_id, ea.person_id, ea.self_enrollment_flag, ea.match_type,ea.user_group_id
   from     ota_event_associations ea
   where    ea.customer_id is null and
            ea.party_id is null and
            (p_self_enroll_only = 'N' or ea.self_enrollment_flag = 'Y') and
            (
            ea.certification_id = p_certification_id or
            ea.category_usage_id in (p_category_usage_id, p_parent_cat_usage_id_1, p_parent_cat_usage_id_2, p_parent_cat_usage_id_3, p_parent_cat_usage_id_4));


   cursor csr_cert_assoc_ext(
      p_self_enroll_only varchar2,
      p_party_id hz_parties.party_id%type,
      p_certification_id in ota_certifications_b.certification_id%type,
      p_category_usage_id ota_category_usages.category_usage_id%type,
      p_parent_cat_usage_id_1 ota_category_usages.category_usage_id%type,
      p_parent_cat_usage_id_2 ota_category_usages.category_usage_id%type,
      p_parent_cat_usage_id_3 ota_category_usages.category_usage_id%type,
      p_parent_cat_usage_id_4 ota_category_usages.category_usage_id%type) is
   select   1
   from     ota_event_associations ea
   where    ea.party_id = p_party_id and
            (p_self_enroll_only = 'N' or ea.self_enrollment_flag = 'Y') and
            (
            ea.certification_id = p_certification_id or
            ea.category_usage_id in (p_category_usage_id, p_parent_cat_usage_id_1, p_parent_cat_usage_id_2, p_parent_cat_usage_id_3, p_parent_cat_usage_id_4));

/*Bug6679100-As exemployees have 2 records in per_all_assignments_f
  modified csr_asg_details and csr_asg_details_recursive  to use system_person_type while
 validating the active assignment record.
   cursor csr_asg_details(
      p_person_id per_people_f.person_id%type,
      p_organization_id ota_event_associations.organization_id%type,
      p_job_id ota_event_associations.job_id%type,
      p_position_id ota_event_associations.position_id%type,
      p_as_of date) is
   select   asg.assignment_id
   from     per_all_assignments_f asg
   where    asg.person_id = p_person_id
           AND ( (nvl(fnd_profile.value('OTA_ALLOW_FUTURE_ENDDATED_EMP_ENROLLMENTS'),'N') = 'Y'
	           AND trunc(sysdate) BETWEEN asg.effective_start_date and asg.effective_end_date)
		   OR  nvl(p_as_of, trunc(sysdate)) between asg.effective_start_date and asg.effective_end_date )
            and
            nvl(p_organization_id, -1) = decode(p_organization_id, null, -1, nvl(asg.organization_id,-1)) and
            nvl(p_job_id, -1) = decode(p_job_id, null, -1, nvl(asg.job_id, -1)) and
            nvl(p_position_id,-1) = decode(p_position_id, null, -1, nvl(asg.position_id, -1)) and
            asg.assignment_type in ('E','A','C');


   cursor csr_asg_details_recursive(
      p_person_id per_people_f.person_id%type,
      p_organization_id ota_event_associations.organization_id%type,
      p_org_structure_version_id ota_event_associations.org_structure_version_id%type,
      p_job_id ota_event_associations.job_id%type,
      p_position_id ota_event_associations.position_id%type,
      p_as_of date) is
  select  asg.assignment_id
  from    per_all_assignments_f asg,
          (
            select  p_organization_id as organization_id
            from    dual
            union all
            select x.sub_organization_id as organization_id
            from   per_org_hrchy_summary x,
                   per_org_structure_versions v,
                   per_org_structure_versions currv
            where  v.org_structure_version_id = p_org_structure_version_id and
                   v.organization_structure_id = currv.organization_structure_id and
                   (currv.date_to is null or
                    sysdate between currv.date_from and currv.date_to) and
                   x.organization_structure_id = currv.organization_structure_id and
                   x.org_structure_version_id = currv.org_structure_version_id and
                   x.organization_id = p_organization_id and
                   x.sub_org_relative_level > 0
           ) orgs
  where    asg.person_id = p_person_id
           AND ( (nvl(fnd_profile.value('OTA_ALLOW_FUTURE_ENDDATED_EMP_ENROLLMENTS'),'N') = 'Y'
	           AND trunc(sysdate) BETWEEN asg.effective_start_date and asg.effective_end_date)
		   OR  nvl(p_as_of, trunc(sysdate)) between asg.effective_start_date and asg.effective_end_date )
           AND nvl(p_as_of, trunc(sysdate)) between asg.effective_start_date and asg.effective_end_date and
           asg.organization_id = orgs.organization_id and
           nvl(p_job_id, -1) = decode(p_job_id, null, -1, nvl(asg.job_id, -1)) and
           nvl(p_position_id,-1) = decode(p_position_id, null, -1, nvl(asg.position_id, -1)) and
           asg.assignment_type in ('E','A','C');*/

             cursor csr_asg_details(
	   	         p_person_id per_people_f.person_id%type,
	   	         p_organization_id ota_event_associations.organization_id%type,
	   	         p_job_id ota_event_associations.job_id%type,
	   	         p_position_id ota_event_associations.position_id%type,
	   	         p_as_of date) is
	   	      select   asg.assignment_id
	   	      from     per_all_assignments_f asg
	   	              ,per_person_types ppt
	   	              ,per_all_people_f  perp
	   	              ,per_person_type_usages_f ptu
	   	      where    asg.person_id = p_person_id
	   	               and asg.person_id = perp.person_id
	   	               and perp.person_id =ptu.person_id
	   	               and ptu.person_type_id=ppt.person_type_id
	   	               and ((asg.primary_flag = 'Y' and ppt.system_person_type in ('EMP','CWK','OTHER'))
	   	              OR (asg.assignment_type = 'A' and ppt.system_person_type ='APL'))
	   	              AND ( (nvl(fnd_profile.value('OTA_ALLOW_FUTURE_ENDDATED_EMP_ENROLLMENTS'),'N') = 'Y'
	   	   	           AND trunc(sysdate) BETWEEN asg.effective_start_date and asg.effective_end_date)
	   	   		   OR  decode(p_as_of,NULL, trunc(sysdate),trunc(p_as_of)) between asg.effective_start_date and asg.effective_end_date )
	   	              AND ( (nvl(fnd_profile.value('OTA_ALLOW_FUTURE_ENDDATED_EMP_ENROLLMENTS'),'N') = 'Y'
	   	   	           AND trunc(sysdate) BETWEEN perp.effective_start_date and perp.effective_end_date)
	   	   		   OR  decode(p_as_of,NULL, trunc(sysdate),trunc(p_as_of)) between perp.effective_start_date and perp.effective_end_date )
	   	              AND ( (nvl(fnd_profile.value('OTA_ALLOW_FUTURE_ENDDATED_EMP_ENROLLMENTS'),'N') = 'Y'
	   	   	           AND trunc(sysdate) BETWEEN ptu.effective_start_date and ptu.effective_end_date)
	   	   		   OR  decode(p_as_of,NULL, trunc(sysdate),trunc(p_as_of)) between ptu.effective_start_date and ptu.effective_end_date )
	   	               and
	   	               nvl(p_organization_id, -1) = decode(p_organization_id, null, -1, nvl(asg.organization_id,-1)) and
	   	               nvl(p_job_id, -1) = decode(p_job_id, null, -1, nvl(asg.job_id, -1)) and
	   	               nvl(p_position_id,-1) = decode(p_position_id, null, -1, nvl(asg.position_id, -1)) and
	   	               asg.assignment_type in ('E','A','C');




	   	               cursor csr_asg_details_recursive(
	   	         p_person_id per_people_f.person_id%type,
	   	         p_organization_id ota_event_associations.organization_id%type,
	   	         p_org_structure_version_id ota_event_associations.org_structure_version_id%type,
	   	         p_job_id ota_event_associations.job_id%type,
	   	         p_position_id ota_event_associations.position_id%type,
	   	         p_as_of date) is
	   	     select  asg.assignment_id
	   	     	     from    per_all_assignments_f asg,
	   	     	             (
	   	     	               select  p_organization_id as organization_id
	   	     	               from    dual
	   	     	               union all
	   	     	               select x.sub_organization_id as organization_id
	   	     	               from   per_org_hrchy_summary x,
	   	     	                      per_org_structure_versions v,
	   	     	                      per_org_structure_versions currv
	   	     	               where  v.org_structure_version_id = p_org_structure_version_id and
	   	     	                      v.organization_structure_id = currv.organization_structure_id and
	   	     	                      (currv.date_to is null or
	   	     	                       sysdate between currv.date_from and currv.date_to) and
	   	     	                      x.organization_structure_id = currv.organization_structure_id and
	   	     	                      x.org_structure_version_id = currv.org_structure_version_id and
	   	     	                      x.organization_id = p_organization_id and
	   	     	                      x.sub_org_relative_level > 0
	   	     	              ) orgs
	   	     	              ,per_person_types ppt
	   	     	              ,per_all_people_f  perp
	   	     	              ,per_person_type_usages_f ptu
	   	     	     where    asg.person_id = p_person_id
	   	     	                and asg.person_id = perp.person_id
	   	     	               and perp.person_id =ptu.person_id
	   	     	               and ptu.person_type_id=ppt.person_type_id
	   	     	               and ((asg.primary_flag = 'Y' and ppt.system_person_type in ('EMP','CWK','OTHER'))
	   	     	              OR (asg.assignment_type = 'A' and ppt.system_person_type ='APL'))
	   	     	              AND ( (nvl(fnd_profile.value('OTA_ALLOW_FUTURE_ENDDATED_EMP_ENROLLMENTS'),'N') = 'Y'
	   	     	   	           AND trunc(sysdate) BETWEEN asg.effective_start_date and asg.effective_end_date)
	   	     	   		   OR  decode(p_as_of,NULL, trunc(sysdate),trunc(p_as_of)) between asg.effective_start_date and asg.effective_end_date )
	   	     	              AND ( (nvl(fnd_profile.value('OTA_ALLOW_FUTURE_ENDDATED_EMP_ENROLLMENTS'),'N') = 'Y'
	   	     	   	           AND trunc(sysdate) BETWEEN perp.effective_start_date and perp.effective_end_date)
	   	     	   		   OR  decode(p_as_of,NULL, trunc(sysdate),trunc(p_as_of)) between perp.effective_start_date and perp.effective_end_date )
	   	     	              AND ( (nvl(fnd_profile.value('OTA_ALLOW_FUTURE_ENDDATED_EMP_ENROLLMENTS'),'N') = 'Y'
	   	     	   	           AND trunc(sysdate) BETWEEN ptu.effective_start_date and ptu.effective_end_date)
	   	     	   		   OR  decode(p_as_of,NULL, trunc(sysdate),trunc(p_as_of)) between ptu.effective_start_date and ptu.effective_end_date )
	   	     	             -- AND nvl(p_as_of, trunc(sysdate)) between asg.effective_start_date and asg.effective_end_date and
	   	     	             and asg.organization_id = orgs.organization_id and
	   	     	              nvl(p_job_id, -1) = decode(p_job_id, null, -1, nvl(asg.job_id, -1)) and
	   	     	              nvl(p_position_id,-1) = decode(p_position_id, null, -1, nvl(asg.position_id, -1)) and
	                                 asg.assignment_type in ('E','A','C');


cursor csr_ug_hierarchy(
      p_user_group_id in ota_user_groups_b.user_group_id%type,
      p_business_group_id number,
      p_ignore_ug_date_check varchar2 default 'N') is
SELECT child_user_group_id
FROM ( SELECT a.user_group_id user_group_id,
              a.child_user_group_id child_user_group_id,
	            level UG_Level,
	            b.user_group_operator user_group_operator
       FROM  ota_user_group_elements a, ota_user_groups_b b
       WHERE a.user_group_id = b.user_group_id
             and (p_ignore_ug_date_check = 'Y' or
                  trunc(sysdate) between trunc(nvl(b.start_date_active, sysdate)) and trunc(nvl(b.end_date_active, sysdate+1)))
             and (b.business_group_id = p_business_group_id or p_business_group_id = -1)
       START WITH a.user_group_id = p_user_group_id
       CONNECT BY PRIOR a.child_user_group_id = a.user_group_id
       ORDER by LEVEL desc
    ) WHERE child_user_group_id is not null;

cursor csr_org_hierarchy(p_organization_id ota_user_group_elements.organization_id%type,
                         p_org_structure_version_id ota_user_group_elements.org_structure_version_id%type) is
   select  p_organization_id as organization_id
   from    dual
   union all
   select x.sub_organization_id as organization_id
   from   per_org_hrchy_summary x,
          per_org_structure_versions v,
          per_org_structure_versions currv
   where  v.org_structure_version_id = p_org_structure_version_id and
          v.organization_structure_id = currv.organization_structure_id and
          (currv.date_to is null or sysdate between currv.date_from and currv.date_to) and
          x.organization_structure_id = currv.organization_structure_id and
          x.org_structure_version_id = currv.org_structure_version_id and
          x.organization_id = p_organization_id and
          x.sub_org_relative_level > 0;

cursor csr_user_group_elements(
      p_user_group_id in ota_user_groups_b.user_group_id%type,
      p_business_group_id number,
      p_ignore_ug_date_check varchar2 default 'N') is
   select   uge.organization_id,
            uge.org_structure_version_id,
            uge.job_id,
            uge.position_id,
            uge.person_id,
            uge.match_type,
            uge.child_user_group_id,
            ugb.user_group_operator
   from     ota_user_group_elements uge, ota_user_groups_b ugb
   where   uge.user_group_id =  p_user_group_id
           and uge.user_group_id = ugb.user_group_id
           and (p_ignore_ug_date_check = 'Y' or
                trunc(sysdate) between trunc(nvl(ugb.start_date_active, sysdate)) and trunc(nvl(ugb.end_date_active, sysdate+1))) --Bug#7120108
           and (uge.business_group_id = p_business_group_id or p_business_group_id = -1);

function is_customer_event(p_event_id in ota_events.event_id%type) return boolean is

   cursor customer_assoc is
   select   1
   from     ota_event_associations
   where    event_id = p_event_id and
            customer_id is not null;

   v_dummy number;
   v_result boolean;
begin
   open customer_assoc;
   fetch customer_assoc into v_dummy;
   v_result := customer_assoc%found;
   close customer_assoc;
   return v_result;
end is_customer_event;


function get_event_start_date(
   p_event_id ota_events.event_id%type,
   p_date date) return date is

   l_event_start_date ota_events.course_start_date%type;
   --l_date date := trunc(p_date);

   l_start_date ota_events.course_start_date%type;
   l_synchronous_flag ota_category_usages.synchronous_flag%type;
   l_event_status ota_events.event_status%type;
   l_event_end_date ota_events.course_end_date%type;
   l_event_end_time ota_events.course_end_time%type;
   l_timezone ota_events.timezone%type;
begin
  -- Modified this function for bug#4393763 to return
  --  course_end_Date for synchronous class
  --  sysdate for asynchronous class and 'Planned' status class
   select   oev.course_start_date, oev.course_end_date,ocu.synchronous_flag, oev.event_status
            ,oev.timezone , oev.course_end_time
   into     l_event_start_date,l_event_end_date,l_synchronous_flag,  l_event_status
           ,l_timezone , l_event_end_time
   from     ota_events oev, ota_offerings ofr, ota_category_usages ocu
   Where    oev.event_id = p_event_id and
            oev.parent_offering_id = ofr.offering_id and
            ofr.delivery_mode_id = ocu.category_usage_id and
            event_type in ('SCHEDULED','SELFPACED') and
            event_status in('P','N','F') and
--            l_date between nvl(enrolment_start_date, l_date) AND nvl(enrolment_end_date, l_date);
-- Modified for Bug#5107347
            ota_timezone_util.convert_date(trunc(p_date),to_char(p_date,'HH24:MI'), ota_timezone_util.get_server_timezone_code , oev.timezone)
	       BETWEEN decode(oev.enrolment_start_date, NULL, to_date('0001/01/01','YYYY/MM/DD'),
	                       to_date( to_char(oev.enrolment_start_date, 'YYYY/MM/DD') || ' ' || '00:00', 'YYYY/MM/DD HH24:MI'))
	         AND decode(oev.enrolment_end_date, NULL, to_date('4712/12/31','YYYY/MM/DD'),
	                       to_date( to_char(oev.enrolment_end_date, 'YYYY/MM/DD') || ' ' || '23:59', 'YYYY/MM/DD HH24:MI'));
	    -- and l_date <= nvl(course_end_date, l_date); -- Bug 4767809

	If upper(l_synchronous_flag) = 'N' then
--		l_start_date := sysdate;
		l_start_date := ota_timezone_util.convert_date(trunc(sysdate)
		                                             , to_char(sysdate,'HH24:MI')
							     , ota_timezone_util.get_server_timezone_code
							     , l_timezone);
	Else
		If l_event_status = 'P' then
--		l_start_date := sysdate;
		l_start_date := ota_timezone_util.convert_date(trunc(sysdate)
		                                             , to_char(sysdate,'HH24:MI')
							     , ota_timezone_util.get_server_timezone_code
							     , l_timezone);
		Else
			l_start_date := to_date(to_char(l_event_end_date,'YYYY/MM/DD')
			                              || ' ' || nvl(l_event_end_time,'23:59'), 'YYYY/MM/DD HH24:MI') ;
		End If;
	End If;
/*
	If upper(l_synchronous_flag) = 'N' then
		l_start_date := sysdate;
	Else
		If l_event_status = 'P' then
		l_start_date := sysdate;
		Else
			l_start_date := to_date(to_char(l_event_end_date,'YYYY/MM/DD')
			                              || ' ' || nvl(l_event_end_time,'23:59'), 'YYYY/MM/DD HH24:MI') ;
		End If;
	End If;
*/
--   return l_event_start_date;
   return l_start_date;
end get_event_start_date;


function person_matches_assoc(
   p_person_id in per_people_f.person_id%type,
   p_as_of in date,
   p_assoc_person_id in ota_event_associations.person_id%type,
   p_assoc_organization_id in ota_event_associations.organization_id%type,
   p_assoc_org_structure_vrsn_id in ota_event_associations.org_structure_version_id%type,
   p_assoc_job_id in ota_event_associations.job_id%type,
   p_assoc_position_id in ota_event_associations.position_id%type,
   p_assoc_match_type in ota_event_associations.match_type%type) return boolean is
begin
   if p_assoc_person_id is null then
      if p_assoc_organization_id is not null and p_assoc_match_type = 'CHILD_ORGS' then
         for an_assignment in csr_asg_details_recursive(p_person_id => p_person_id,
                                                        p_organization_id => p_assoc_organization_id,
                                                        p_org_structure_version_id => p_assoc_org_structure_vrsn_id,
                                                        p_job_id => p_assoc_job_id,
                                                        p_position_id => p_assoc_position_id,
                                                        p_as_of => p_as_of) loop
            return true;
         end loop;
      else
         for an_assignment in csr_asg_details(p_person_id => p_person_id,
                                              p_organization_id => p_assoc_organization_id,
                                              p_job_id => p_assoc_job_id,
                                              p_position_id => p_assoc_position_id,
                                              p_as_of => p_as_of) loop
            return true;
         end loop;
      end if;

   elsif p_assoc_person_id = p_person_id then
      return true;
   end if;

  return false;
end person_matches_assoc;


function emp_matches_org(
   p_person_id in per_people_f.person_id%type,
   p_event_id in ota_events.event_id%type,
   p_organization_id in ota_events.organization_id%type) return varchar2 is

   cursor csr_assignments(
      p_person_id per_people_f.person_id%type,
      p_organization_id ota_event_associations.organization_id%type,
      p_course_start_date otv_scheduled_events.course_start_date%type,
      p_now date) is
   select   asg.assignment_id
   from     per_all_assignments_f asg
   where    asg.person_id = p_person_id and
            nvl(p_course_start_date, trunc(p_now)) between asg.effective_start_date and asg.effective_end_date and
            p_organization_id = asg.organization_id and
            asg.assignment_type in ('E','A','C');
   l_now date;
   l_event_start_date ota_events.course_start_date%type;
begin
   l_now := sysdate;
   -- Bug 4584737: if no data found, event has expired or does not exist.  Return 'N'.
   begin
     l_event_start_date := get_event_start_date(p_event_id, l_now);
   exception
     when NO_DATA_FOUND then
       return 'N';
   end;

   for an_assignment in csr_assignments(p_person_id, p_organization_id, l_event_start_date, l_now) loop
     return 'Y';
   end loop;

   return 'N';
end emp_matches_org;

FUNCTION learner_belongs_to_child_org(p_org_structure_version_id IN ota_event_associations. org_structure_version_id%type,
                                      p_organization_id IN ota_event_associations.organization_id%type,
                                      p_person_id IN per_people_f.person_id%type)
                                      RETURN VARCHAR2 IS

  CURSOR csr_lrnr_belongs_to_org IS
  SELECT  asg.assignment_id
  FROM    per_all_assignments_f asg,
          (
            SELECT  p_organization_id AS organization_id
            FROM  dual
            UNION ALL
            SELECT x.sub_organization_id AS organization_id
            FROM   per_org_hrchy_summary x,
                   per_org_structure_versions v,
                   per_org_structure_versions currv
            WHERE  v.org_structure_version_id = p_org_structure_version_id AND
                   v.organization_structure_id = currv.organization_structure_id AND
                   (currv.date_to IS NULL OR
                    sysdate BETWEEN currv.date_from AND currv.date_to) AND
                   x.organization_structure_id = currv.organization_structure_id AND
                   x.org_structure_version_id = currv.org_structure_version_id AND
                   x.organization_id = p_organization_id AND
                   x.sub_org_relative_level > 0
           ) orgs
  WHERE    asg.person_id = p_person_id  AND
           asg.organization_id = orgs.organization_id AND
           asg.assignment_type in ('E','A','C');

  l_assignment_id per_all_assignments_f.assignment_id%type;
 BEGIN

  OPEN csr_lrnr_belongs_to_org;
  FETCH csr_lrnr_belongs_to_org INTO l_assignment_id;
  CLOSE csr_lrnr_belongs_to_org;

  IF l_assignment_id IS NOT NULL THEN
    RETURN 'Y';
  ELSE
    RETURN 'N';
  END IF;

END learner_belongs_to_child_org;

function emp_has_access(
   p_person_id in per_people_f.person_id%type,
   p_event_id in ota_events.event_id%type,
   p_self_enroll_only in varchar2) return varchar2 is

   l_event_start_date ota_events.course_start_date%type;
   l_now date := sysdate;
   l_offering_id ota_offerings.offering_id%type;
   l_activity_version_id ota_activity_versions.activity_version_id%type;
   l_category_usage_id ota_category_usages.category_usage_id%type;
   l_parent_cat_usage_id_1 ota_category_usages.category_usage_id%type;
   l_parent_cat_usage_id_2 ota_category_usages.category_usage_id%type;
   l_parent_cat_usage_id_3 ota_category_usages.category_usage_id%type;
   l_parent_cat_usage_id_4 ota_category_usages.category_usage_id%type;

   l_is_mandatory_enr_assoc boolean:= false ;
   l_event_association_id ota_event_associations.event_association_id%type;
begin
   -- Bug 4584737: if no data found, event has expired or does not exist.  Return 'N'.
   begin
      l_event_start_date := get_event_start_date(p_event_id, l_now);
   exception
      when NO_DATA_FOUND then
         return 'N';
   end;
   --Perform the below actions only if mandatory event associations are not associated with the person for given event
   open check_mandatory_evt_assoc(p_event_id,p_person_id,l_event_start_date);
   fetch check_mandatory_evt_assoc into l_event_association_id;

   if check_mandatory_evt_assoc%NOTFOUND then
    l_is_mandatory_enr_assoc :=false;
   else
    l_is_mandatory_enr_assoc := true;
   end if;

   close check_mandatory_evt_assoc;

  if not l_is_mandatory_enr_assoc then
   -- Get the event's offering, course, and five levels of categories.  If the category tree is deeper than that,
   -- we will have to use CONNECT BY below.
   open csr_evt_tree(p_event_id);
   fetch csr_evt_tree into
      l_offering_id, l_activity_version_id, l_category_usage_id,
      l_parent_cat_usage_id_1, l_parent_cat_usage_id_2, l_parent_cat_usage_id_3, l_parent_cat_usage_id_4;
   close csr_evt_tree;

   for assoc in csr_evt_assoc(p_self_enroll_only, p_event_id, l_offering_id, l_activity_version_id, l_category_usage_id, l_parent_cat_usage_id_1, l_parent_cat_usage_id_2, l_parent_cat_usage_id_3, l_parent_cat_usage_id_4) loop
      if (assoc.user_group_id is not null) then
        if(is_learner_in_user_group(p_person_id,assoc.user_group_id,ota_general.get_business_group_id) = 'Y' ) then
            return 'Y';
        end if;
      else
        if person_matches_assoc(p_person_id, l_event_start_date, assoc.person_id, assoc.organization_id, assoc.org_structure_version_id, assoc.job_id, assoc.position_id, assoc.match_type) = true then
          return 'Y';
        end if;
      end if;
   end loop;

   -- if the 4th-level parent category is not null, then there may be more parent
   -- categories above.  Use a CONNECT BY cursor.
   if l_parent_cat_usage_id_4 is not null then
      for assoc in csr_category_assoc(p_self_enroll_only, l_parent_cat_usage_id_4) loop
        if (assoc.user_group_id is not null) then
            if(is_learner_in_user_group(p_person_id,assoc.user_group_id,ota_general.get_business_group_id) = 'Y' ) then
                return 'Y';
            end if;
        else
         if person_matches_assoc(p_person_id, l_event_start_date, assoc.person_id, assoc.organization_id, assoc.org_structure_version_id, assoc.job_id, assoc.position_id, assoc.match_type) = true then
           return 'Y';
         end if;
        end if;
      end loop;
   end if;
  end if;

   return 'N';
end emp_has_access;


function ext_has_access(
   p_party_id in hz_parties.party_id%type,
   p_event_id in ota_events.event_id%type,
   p_self_enroll_only in varchar2) return varchar2 is

   l_offering_id ota_offerings.offering_id%type;
   l_activity_version_id ota_activity_versions.activity_version_id%type;
   l_category_usage_id ota_category_usages.category_usage_id%type;
   l_parent_cat_usage_id_1 ota_category_usages.category_usage_id%type;
   l_parent_cat_usage_id_2 ota_category_usages.category_usage_id%type;
   l_parent_cat_usage_id_3 ota_category_usages.category_usage_id%type;
   l_parent_cat_usage_id_4 ota_category_usages.category_usage_id%type;
begin
   -- Get the event's offering, course, and five levels of categories.  If the category tree is deeper than that,
   -- we will have to use CONNECT BY below.
   open csr_evt_tree(p_event_id);
   fetch csr_evt_tree into
      l_offering_id, l_activity_version_id, l_category_usage_id,
      l_parent_cat_usage_id_1, l_parent_cat_usage_id_2, l_parent_cat_usage_id_3, l_parent_cat_usage_id_4;
   close csr_evt_tree;

   for assoc in csr_evt_assoc_ext(p_self_enroll_only, p_party_id, p_event_id, l_offering_id, l_activity_version_id, l_category_usage_id, l_parent_cat_usage_id_1, l_parent_cat_usage_id_2, l_parent_cat_usage_id_3, l_parent_cat_usage_id_4) loop
      return 'Y';
   end loop;

   -- if the 4th-level parent category is not null, then there may be more parent
   -- categories above.  Use a CONNECT BY cursor as a last resort - it's slow.
   if l_parent_cat_usage_id_4 is not null then
      for assoc in csr_category_assoc_ext(p_self_enroll_only, p_party_id, l_parent_cat_usage_id_4) loop
         return 'Y';
      end loop;
   end if;

   return 'N';
end ext_has_access;

FUNCTION emp_has_valid_dates(p_person_id per_all_people_f.person_id%TYPE
                        ,p_event_id ota_events.event_id%TYPE)
RETURN VARCHAR2 IS
   l_event_start_date DATE;
   l_assignment_id per_all_assignments_f.assignment_id%TYPE;
BEGIN

  BEGIN
  l_event_start_date := get_event_start_date(p_event_id, sysdate);
   -- Added exception block for bug#5614187
   EXCEPTION
       when NO_DATA_FOUND then
       l_event_start_date := trunc(sysdate);
   END;

   OPEN csr_asg_details(p_person_id, NUll, NULL, NULL,  l_event_start_date);
   FETCH csr_asg_details INTO l_assignment_id;
   IF csr_asg_details%FOUND THEN
     CLOSE csr_asg_details;
     RETURN 'Y';
   ELSE
     CLOSE csr_asg_details;
     RETURN 'N';
   END IF;

END emp_has_valid_dates;


function employee_can_enroll(
   p_person_id in per_people_f.person_id%type,
   p_event_id in ota_events.event_id%type,
   p_public_event_flag ota_events.public_event_flag%type,
   p_max_internal in ota_events.maximum_internal_attendees%type,
   p_event_start_date in otv_scheduled_events.course_start_date%type,
   p_parent_offering_id in ota_events.parent_offering_id%type default null) return varchar2 is

   --Bug 547819
   Cursor c_event_data is
	Select   OCU.synchronous_flag, OEV.event_status, OEV.secure_event_flag,
                 OEV.organization_id
	From     ota_events OEV, ota_offerings OFR, ota_category_usages OCU
	Where    OEV.event_id = p_event_id
	 	 And OEV.parent_offering_id = OFR.offering_id
		 And OFR.delivery_mode_id = OCU.category_usage_id;

   l_synchronous_flag ota_category_usages.synchronous_flag%type;
   l_effective_start_date PER_ALL_PEOPLE_F.effective_start_date%type;
   l_event_status ota_events.event_status%type;
   l_secure_event_flag ota_events.secure_event_flag%type;
   l_organization_id ota_events.organization_id%type;
   l_start_date otv_scheduled_events.course_start_date%type;
   l_is_secure_event boolean;
begin
   --Bug 547819
   Open c_event_data;
   Fetch c_event_data into l_synchronous_flag, l_event_status, l_secure_event_flag, l_organization_id;
   Close c_event_data;

   -- Is this a secure event?
   l_is_secure_event := (l_secure_event_flag is not null and upper(l_secure_event_flag) = 'Y');

   -- Employees can enroll if MAXIMUM_INTERNAL_ATTENDEES is null or greater than
   -- zero and one of the following is true:
   --      The event is secure and the employee is in the organization, or
   --      The event is NOT secure and...
   --         * the event is public, or
   --         * the event is a customer event, or
   --         * the learner has been specifically given access via
   --           event associations.

   if (p_max_internal is null or p_max_internal > 0) and
      (
        (l_is_secure_event and emp_matches_org(p_person_id, p_event_id, l_organization_id) = 'Y') or
        (
          not l_is_secure_event and
          (
            (p_public_event_flag = 'Y' AND emp_has_valid_dates(p_person_id, p_event_id) = 'Y') or
            is_customer_event(p_event_id) or
            emp_has_access(p_person_id, p_event_id, 'N') = 'Y'
          )
        )
      ) then
      return 'Y';
   else
      return 'N';
   end if;
end employee_can_enroll;


function employee_can_self_enroll(
   p_person_id in per_people_f.person_id%type,
   p_event_id in ota_events.event_id%type,
   p_public_event_flag ota_events.public_event_flag%type,
   p_max_internal in ota_events.maximum_internal_attendees%type,
   p_parent_offering_id in ota_events.parent_offering_id%type default null) return varchar2 is
begin
   -- Employees may not enroll if MAXIMUM_INTERNAL_ATTENDEES is zero.
   -- Self-enrollment can only be specified via event associations.  Therefore,
   -- public events or customer events can never be self-enrollable.
   if p_max_internal <= 0 or p_public_event_flag = 'Y' or is_customer_event(p_event_id) then
      return 'N';
   end if;

   -- Check for self-enrollment event associations
   return emp_has_access(p_person_id, p_event_id, 'Y');
end employee_can_self_enroll;


function ext_learner_can_enroll(
   p_party_id in hz_parties.party_id%type,
   p_event_id in ota_events.event_id%type,
   p_public_event_flag ota_events.public_event_flag%type,
   p_max_internal in ota_events.maximum_internal_attendees%type,
   p_event_start_date in otv_scheduled_events.course_start_date%type,
   p_parent_offering_id in ota_events.parent_offering_id%type default null) return varchar2 is
begin
   -- External learners can enroll if the event is public, or it is a non-customer event and
   -- the learner has been specifically given access via event associations.

   if p_public_event_flag = 'Y' or
      (not is_customer_event(p_event_id) and
      ext_has_access(p_party_id, p_event_id, 'N') = 'Y') then
      return 'Y';
   elsif (p_public_event_flag = 'N' and         --added as the external learners should be
          is_customer_event(p_event_id)) then   --able to enroll into private events created
      return 'Y';                               --for the customers.bug#6327056.
   else
      return 'N';
   end if;
end ext_learner_can_enroll;


function ext_learner_can_self_enroll(
   p_party_id in hz_parties.party_id%type,
   p_event_id in ota_events.event_id%type,
   p_public_event_flag ota_events.public_event_flag%type,
   p_max_internal in ota_events.maximum_internal_attendees%type,
   p_parent_offering_id in ota_events.parent_offering_id%type default null) return varchar2 is
begin
   -- Self-enrollment can only be specified via event associations.  Therefore,
   -- public events or customer events can never be self-enrollable.
   if p_public_event_flag = 'Y' or is_customer_event(p_event_id) then
      return 'N';
   end if;

   -- Check for self-enrollment event associations
   return ext_has_access(p_party_id, p_event_id, 'Y');
end ext_learner_can_self_enroll;


function learner_can_enroll(
   p_person_id in per_people_f.person_id%type,
   p_party_id in hz_parties.party_id%type,
   p_event_id in ota_events.event_id%type,
   p_public_event_flag in ota_events.public_event_flag%type,
   p_max_internal in ota_events.maximum_internal_attendees%type,
   p_event_start_date in otv_scheduled_events.course_start_date%type,
   p_parent_offering_id in ota_events.parent_offering_id%type default null) return varchar2 is
begin
   if p_person_id is not null then
      return employee_can_enroll(p_person_id, p_event_id, p_public_event_flag, p_max_internal, p_event_start_date, p_parent_offering_id);
   else
      return ext_learner_can_enroll(p_party_id, p_event_id, p_public_event_flag, p_max_internal, p_event_start_date, p_parent_offering_id);
   end if;
end learner_can_enroll;


function learner_can_enroll(
   p_person_id in per_people_f.person_id%type,
   p_party_id in hz_parties.party_id%type,
   p_event_id in ota_events.event_id%type,
   p_event_start_date in otv_scheduled_events.course_start_date%type,
   p_parent_offering_id in ota_events.parent_offering_id%type default null) return varchar2 is

   v_public_event_flag ota_events.public_event_flag%type;
   v_max_internal ota_events.maximum_internal_attendees%type;
begin
   select   maximum_internal_attendees, public_event_flag
   into     v_max_internal, v_public_event_flag
   from     ota_events
   where    event_id = p_event_id;

   return learner_can_enroll(p_person_id, p_party_id, p_event_id, v_public_event_flag, v_max_internal, p_event_start_date, p_parent_offering_id);
end learner_can_enroll;


function learner_can_enroll(
   p_person_id in per_people_f.person_id%type,
   p_party_id in hz_parties.party_id%type,
   p_event_id in ota_events.event_id%type) return varchar2 is

   v_event_start_date ota_events.course_start_date%type;
   v_parent_offering_id ota_events.parent_offering_id%type;
   v_public_event_flag ota_events.public_event_flag%type;
   v_max_internal ota_events.maximum_internal_attendees%type;
begin
   select   maximum_internal_attendees, public_event_flag, parent_offering_id, course_start_date
   into     v_max_internal, v_public_event_flag, v_parent_offering_id, v_event_start_date
   from     ota_events
   where    event_id = p_event_id;

   return learner_can_enroll(p_person_id, p_party_id, p_event_id, v_public_event_flag, v_max_internal, v_event_start_date, v_parent_offering_id);
end learner_can_enroll;


function learner_can_self_enroll(
   p_person_id in per_people_f.person_id%type,
   p_party_id in hz_parties.party_id%type,
   p_event_id in ota_events.event_id%type,
   p_public_event_flag in ota_events.public_event_flag%type,
   p_max_internal in ota_events.maximum_internal_attendees%type,
   p_event_start_date in otv_scheduled_events.course_start_date%type,
   p_parent_offering_id in ota_events.parent_offering_id%type default null) return varchar2 is
begin
   if p_person_id is not null then
      return employee_can_self_enroll(p_person_id, p_event_id, p_public_event_flag, p_max_internal, p_parent_offering_id);
   else
      return ext_learner_can_self_enroll(p_party_id, p_event_id, p_public_event_flag, p_max_internal, p_parent_offering_id);
   end if;
end learner_can_self_enroll;


function learner_can_self_enroll(
   p_person_id in per_people_f.person_id%type,
   p_party_id in hz_parties.party_id%type,
   p_event_id in ota_events.event_id%type,
   p_event_start_date in otv_scheduled_events.course_start_date%type,
   p_parent_offering_id in ota_events.parent_offering_id%type default null) return varchar2 is

   v_public_event_flag ota_events.public_event_flag%type;
   v_max_internal ota_events.maximum_internal_attendees%type;
begin
   select   maximum_internal_attendees, public_event_flag
   into     v_max_internal, v_public_event_flag
   from     ota_events
   where    event_id = p_event_id;

   return learner_can_self_enroll(p_person_id, p_party_id, p_event_id, v_public_event_flag, v_max_internal, p_event_start_date, p_parent_offering_id);
end learner_can_self_enroll;

function learner_can_self_enroll(
   p_person_id in per_people_f.person_id%type,
   p_party_id in hz_parties.party_id%type,
   p_event_id in ota_events.event_id%type) return varchar2 is

   v_event_start_date ota_events.course_start_date%type;
   v_parent_offering_id ota_events.parent_offering_id%type;
   v_public_event_flag ota_events.public_event_flag%type;
   v_max_internal ota_events.maximum_internal_attendees%type;
begin
   select   maximum_internal_attendees, public_event_flag, parent_offering_id, course_start_date
   into     v_max_internal, v_public_event_flag, v_parent_offering_id, v_event_start_date
   from     ota_events
   where    event_id = p_event_id;

   return learner_can_self_enroll(p_person_id, p_party_id, p_event_id, v_public_event_flag, v_max_internal, v_event_start_date, v_parent_offering_id);
end learner_can_self_enroll;


function chk_delegate_ok_for_event(
   p_delegate_id in per_people_f.person_id%type,
   p_event_id in ota_events.event_id%type,
   p_event_start_date in otv_scheduled_events.course_start_date%type,
   p_parent_offering_id in ota_events.parent_offering_id%type default null) return varchar2 is
begin
   return learner_can_enroll(p_delegate_id, null, p_event_id, p_event_start_date, p_parent_offering_id);
end chk_delegate_ok_for_event;


function learner_can_see_category(
   p_person_id in per_people_f.person_id%type,
   p_party_id in hz_parties.party_id%type,
   p_category_usage_id in ota_category_usages.category_usage_id%type) return varchar2 is

begin
/*
 *	MAC: stubbed out for performance.
 */
	return 'Y';
end learner_can_see_category;


function learner_can_see_course(
   p_person_id in per_people_f.person_id%type,
   p_activity_version_id in ota_activity_versions.activity_version_id%type) return varchar2 is
begin
   return 'Y';
end learner_can_see_course;


function learner_can_see_offering(
   p_person_id in per_people_f.person_id%type,
   p_offering_id in ota_offerings.offering_id%type) return varchar2 is
begin
   return 'Y';
end learner_can_see_offering;


function emp_has_access_to_path(
   p_person_id in per_people_f.person_id%type,
   p_learning_path_id in ota_learning_paths.learning_path_id%type,
   p_self_enroll_only in varchar2) return varchar2 is

   l_now date := sysdate;
   l_category_usage_id ota_category_usages.category_usage_id%type;
   l_parent_cat_usage_id_1 ota_category_usages.category_usage_id%type;
   l_parent_cat_usage_id_2 ota_category_usages.category_usage_id%type;
   l_parent_cat_usage_id_3 ota_category_usages.category_usage_id%type;
   l_parent_cat_usage_id_4 ota_category_usages.category_usage_id%type;
begin
   -- Get the learning path's five levels of categories.  If the category tree is deeper than that,
   -- we will have to use CONNECT BY below.
   open csr_lp_tree(p_learning_path_id);
   fetch csr_lp_tree into
      l_category_usage_id, l_parent_cat_usage_id_1, l_parent_cat_usage_id_2,
      l_parent_cat_usage_id_3, l_parent_cat_usage_id_4;
   close csr_lp_tree;

   for assoc in csr_lp_assoc(p_self_enroll_only, p_learning_path_id, l_category_usage_id, l_parent_cat_usage_id_1, l_parent_cat_usage_id_2, l_parent_cat_usage_id_3, l_parent_cat_usage_id_4) loop
     if (assoc.user_group_id is not null) then
        if(is_learner_in_user_group(p_person_id,assoc.user_group_id,ota_general.get_business_group_id) = 'Y' ) then
            return 'Y';
        end if;
     else
        if person_matches_assoc(p_person_id, l_now, assoc.person_id, assoc.organization_id, assoc.org_structure_version_id, assoc.job_id, assoc.position_id, assoc.match_type) = true then
            return 'Y';
         end if;
     end if;
   end loop;

   -- if the 4th-level parent category is not null, then there may be more parent
   -- categories above.  Use a CONNECT BY cursor.
   if l_parent_cat_usage_id_4 is not null then
      for assoc in csr_category_assoc(p_self_enroll_only, l_parent_cat_usage_id_4) loop
        if (assoc.user_group_id is not null) then
            if(is_learner_in_user_group(p_person_id,assoc.user_group_id,ota_general.get_business_group_id) = 'Y' ) then
                return 'Y';
            end if;
        else
            if person_matches_assoc(p_person_id, l_now, assoc.person_id, assoc.organization_id, assoc.org_structure_version_id, assoc.job_id, assoc.position_id, assoc.match_type) = true then
                return 'Y';
            end if;
        end if;
      end loop;
   end if;

   return 'N';
end emp_has_access_to_path;


function ext_has_access_to_path(
   p_party_id in hz_parties.party_id%type,
   p_learning_path_id in ota_learning_paths.learning_path_id%type,
   p_self_enroll_only in varchar2) return varchar2 is

   l_category_usage_id ota_category_usages.category_usage_id%type;
   l_parent_cat_usage_id_1 ota_category_usages.category_usage_id%type;
   l_parent_cat_usage_id_2 ota_category_usages.category_usage_id%type;
   l_parent_cat_usage_id_3 ota_category_usages.category_usage_id%type;
   l_parent_cat_usage_id_4 ota_category_usages.category_usage_id%type;
begin
   -- Get the learning path's five levels of categories.  If the category tree is deeper than that,
   -- we will have to use CONNECT BY below.
   open csr_lp_tree(p_learning_path_id);
   fetch csr_lp_tree into
      l_category_usage_id, l_parent_cat_usage_id_1, l_parent_cat_usage_id_2,
      l_parent_cat_usage_id_3, l_parent_cat_usage_id_4;
   close csr_lp_tree;

   for assoc in csr_lp_assoc_ext(p_self_enroll_only, p_party_id, p_learning_path_id, l_category_usage_id, l_parent_cat_usage_id_1, l_parent_cat_usage_id_2, l_parent_cat_usage_id_3, l_parent_cat_usage_id_4) loop
      return 'Y';
   end loop;

   -- if the 4th-level parent category is not null, then there may be more parent
   -- categories above.  Use a CONNECT BY cursor as a last resort - it's slow.
   if l_parent_cat_usage_id_4 is not null then
      for assoc in csr_category_assoc_ext(p_self_enroll_only, p_party_id, l_parent_cat_usage_id_4) loop
         return 'Y';
      end loop;
   end if;

   return 'N';
end ext_has_access_to_path;


function emp_can_enroll_in_path(
   p_person_id in per_people_f.person_id%type,
   p_learning_path_id in ota_learning_paths.learning_path_id%type,
   p_public_flag ota_learning_paths.public_flag%type,
   p_start_date_active in ota_learning_paths.start_date_active%type,
   p_category_usage_id in ota_category_usages.category_usage_id%type default null) return varchar2 is
begin
   if p_public_flag = 'Y' then
      return 'Y';
   else
      return emp_has_access_to_path(p_person_id, p_learning_path_id, 'N');
   end if;
end emp_can_enroll_in_path;


function emp_can_self_enroll_in_path(
   p_person_id in per_people_f.person_id%type,
   p_learning_path_id in ota_learning_paths.learning_path_id%type,
   p_public_flag ota_learning_paths.public_flag%type,
   p_start_date_active in ota_learning_paths.start_date_active%type,
   p_category_usage_id in ota_category_usages.category_usage_id%type default null) return varchar2 is
begin
   -- A public learning path disregards its learner access records.  Learner access records
   -- are the only way an event can be made self-enrollable.  Therefore, the employee cannot
   -- self-enroll.
   if p_public_flag = 'Y' then
      return 'N';
   else
      return emp_has_access_to_path(p_person_id, p_learning_path_id, 'Y');
   end if;
end emp_can_self_enroll_in_path;


function ext_can_enroll_in_path(
   p_party_id in hz_parties.party_id%type,
   p_learning_path_id in ota_learning_paths.learning_path_id%type,
   p_public_flag ota_learning_paths.public_flag%type,
   p_start_date_active in ota_learning_paths.start_date_active%type,
   p_category_usage_id in ota_category_usages.category_usage_id%type default null) return varchar2 is
begin
   if p_public_flag = 'Y' then
      return 'Y';
   else
      return ext_has_access_to_path(p_party_id, p_learning_path_id, 'N');
   end if;
end ext_can_enroll_in_path;


function ext_can_self_enroll_in_path(
   p_party_id in hz_parties.party_id%type,
   p_learning_path_id in ota_learning_paths.learning_path_id%type,
   p_public_flag ota_learning_paths.public_flag%type,
   p_start_date_active in ota_learning_paths.start_date_active%type,
   p_category_usage_id in ota_category_usages.category_usage_id%type default null) return varchar2 is
begin
   -- A public learning path disregards its learner access records.  Learner access records
   -- are the only way an event can be made self-enrollable.  Therefore, the ext learner cannot
   -- self-enroll.
   if p_public_flag = 'Y' then
      return 'N';
   else
      return ext_has_access_to_path(p_party_id, p_learning_path_id, 'Y');
   end if;
end ext_can_self_enroll_in_path;


function learner_can_enroll_in_path(
   p_person_id in per_people_f.person_id%type,
   p_party_id in hz_parties.party_id%type,
   p_learning_path_id in ota_learning_paths.learning_path_id%type,
   p_public_flag ota_learning_paths.public_flag%type,
   p_start_date_active in ota_learning_paths.start_date_active%type,
   p_category_usage_id in ota_category_usages.category_usage_id%type default null) return varchar2 is
begin
   if p_person_id is not null then
      return emp_can_enroll_in_path(p_person_id, p_learning_path_id, p_public_flag, p_start_date_active, p_category_usage_id);
   else
      return ext_can_enroll_in_path(p_party_id, p_learning_path_id, p_public_flag, p_start_date_active, p_category_usage_id);
   end if;
end learner_can_enroll_in_path;


function learner_can_enroll_in_path(
   p_user_id in fnd_user.user_id%type,
   p_learning_path_id in ota_learning_paths.learning_path_id%type,
   p_public_flag ota_learning_paths.public_flag%type,
   p_start_date_active in ota_learning_paths.start_date_active%type,
   p_category_usage_id in ota_category_usages.category_usage_id%type default null) return varchar2 is

   v_employee_id fnd_user.employee_id%type;
   v_party_id hz_parties.party_id%type;
begin
   select   employee_id, person_party_id
   into     v_employee_id, v_party_id
   from     fnd_user
   where    user_id = p_user_id;

   return learner_can_enroll_in_path(v_employee_id, v_party_id, p_learning_path_id, p_public_flag, p_start_date_active, p_category_usage_id);
end learner_can_enroll_in_path;


function lrn_can_self_enroll_in_path(
   p_person_id in per_people_f.person_id%type,
   p_party_id in hz_parties.party_id%type,
   p_learning_path_id in ota_learning_paths.learning_path_id%type,
   p_public_flag ota_learning_paths.public_flag%type,
   p_start_date_active in ota_learning_paths.start_date_active%type,
   p_category_usage_id in ota_category_usages.category_usage_id%type default null) return varchar2 is
begin
   if p_person_id is not null then
      return emp_can_self_enroll_in_path(p_person_id, p_learning_path_id, p_public_flag, p_start_date_active, p_category_usage_id);
   else
      return ext_can_self_enroll_in_path(p_party_id, p_learning_path_id, p_public_flag, p_start_date_active, p_category_usage_id);
   end if;
end lrn_can_self_enroll_in_path;


function lrn_can_self_enroll_in_path(
   p_user_id in fnd_user.user_id%type,
   p_learning_path_id in ota_learning_paths.learning_path_id%type,
   p_public_flag ota_learning_paths.public_flag%type,
   p_start_date_active in ota_learning_paths.start_date_active%type,
   p_category_usage_id in ota_category_usages.category_usage_id%type default null) return varchar2 is

   v_employee_id fnd_user.employee_id%type;
   v_party_id hz_parties.party_id%type;
begin
   select   employee_id, person_party_id
   into     v_employee_id, v_party_id
   from     fnd_user
   where    user_id = p_user_id;

   return lrn_can_self_enroll_in_path(v_employee_id, v_party_id, p_learning_path_id, p_public_flag, p_start_date_active, p_category_usage_id);
end lrn_can_self_enroll_in_path;

--functions for forum(open) enrollments

function emp_has_access_to_forum(
   p_person_id in per_people_f.person_id%type,
   p_forum_id in ota_forums_b.forum_id%type,
   p_self_enroll_only in varchar2) return varchar2 is

   l_now date := sysdate;
   l_object_id ota_frm_obj_inclusions.object_id%type;
   l_parent_cat_usage_id_1 ota_category_usages.category_usage_id%type;
   l_parent_cat_usage_id_2 ota_category_usages.category_usage_id%type;
   l_parent_cat_usage_id_3 ota_category_usages.category_usage_id%type;
   l_parent_cat_usage_id_4 ota_category_usages.category_usage_id%type;
begin
   -- Get the forum's five levels of categories.  If the category tree is deeper than that,
   -- we will have to use CONNECT BY below.
   open csr_forum_tree(p_forum_id);
   fetch csr_forum_tree into
      l_object_id, l_parent_cat_usage_id_1, l_parent_cat_usage_id_2,
      l_parent_cat_usage_id_3, l_parent_cat_usage_id_4;
   close csr_forum_tree;

   for assoc in csr_forum_assoc(p_self_enroll_only, p_forum_id, l_object_id, l_parent_cat_usage_id_1, l_parent_cat_usage_id_2, l_parent_cat_usage_id_3, l_parent_cat_usage_id_4) loop
     if (assoc.user_group_id is not null) then
        if(is_learner_in_user_group(p_person_id,assoc.user_group_id,ota_general.get_business_group_id) = 'Y' ) then
            return 'Y';
        end if;
     else
        if person_matches_assoc(p_person_id, l_now, assoc.person_id, assoc.organization_id, assoc.org_structure_version_id, assoc.job_id, assoc.position_id, assoc.match_type) = true then
             return 'Y';
         end if;
     end if;
   end loop;

   -- if the 4th-level parent category is not null, then there may be more parent
   -- categories above.  Use a CONNECT BY cursor.
   if l_parent_cat_usage_id_4 is not null then
      for assoc in csr_category_assoc(p_self_enroll_only, l_parent_cat_usage_id_4) loop
        if (assoc.user_group_id is not null) then
            if(is_learner_in_user_group(p_person_id,assoc.user_group_id,ota_general.get_business_group_id) = 'Y' ) then
                return 'Y';
            end if;
         else
            if person_matches_assoc(p_person_id, l_now, assoc.person_id, assoc.organization_id, assoc.org_structure_version_id, assoc.job_id, assoc.position_id, assoc.match_type) = true then
              return 'Y';
            end if;
         end if;
      end loop;
   end if;

   return 'N';
end emp_has_access_to_forum;


function ext_has_access_to_forum(
   p_party_id in hz_parties.party_id%type,
   p_forum_id in ota_forums_b.forum_id%type,
   p_self_enroll_only in varchar2) return varchar2 is

   l_object_id ota_frm_obj_inclusions.object_id%type;
   l_parent_cat_usage_id_1 ota_category_usages.category_usage_id%type;
   l_parent_cat_usage_id_2 ota_category_usages.category_usage_id%type;
   l_parent_cat_usage_id_3 ota_category_usages.category_usage_id%type;
   l_parent_cat_usage_id_4 ota_category_usages.category_usage_id%type;
begin
   -- Get the forums's five levels of categories.  If the category tree is deeper than that,
   -- we will have to use CONNECT BY below.
   open csr_forum_tree(p_forum_id);
   fetch csr_forum_tree into
      l_object_id, l_parent_cat_usage_id_1, l_parent_cat_usage_id_2,
      l_parent_cat_usage_id_3, l_parent_cat_usage_id_4;
   close csr_forum_tree;

   for assoc in csr_forum_assoc_ext(p_self_enroll_only, p_party_id, p_forum_id, l_object_id, l_parent_cat_usage_id_1, l_parent_cat_usage_id_2, l_parent_cat_usage_id_3, l_parent_cat_usage_id_4) loop
      return 'Y';
   end loop;

   -- if the 4th-level parent category is not null, then there may be more parent
   -- categories above.  Use a CONNECT BY cursor as a last resort - it's slow.
   if l_parent_cat_usage_id_4 is not null then
      for assoc in csr_category_assoc_ext(p_self_enroll_only, p_party_id, l_parent_cat_usage_id_4) loop
         return 'Y';
      end loop;
   end if;

   return 'N';
end ext_has_access_to_forum;


function emp_can_enroll_in_forum(
   p_person_id in per_people_f.person_id%type,
   p_forum_id in ota_forums_b.forum_id%type,
   p_public_flag ota_forums_b.public_flag%type,
   p_start_date_active in ota_forums_b.start_date_active%type,
   p_category_usage_id in ota_category_usages.category_usage_id%type default null) return varchar2 is
begin
   if p_public_flag = 'Y' then
      return 'Y';
   else
      return emp_has_access_to_forum(p_person_id, p_forum_id, 'N');
   end if;
end emp_can_enroll_in_forum;


function emp_can_self_enroll_in_forum(
   p_person_id in per_people_f.person_id%type,
   p_forum_id in ota_forums_b.forum_id%type,
   p_public_flag ota_forums_b.public_flag%type,
   p_start_date_active in ota_forums_b.start_date_active%type,
   p_category_usage_id in ota_category_usages.category_usage_id%type default null) return varchar2 is
begin
   -- A public forum disregards its learner access records.  Learner access records
   -- are the only way an event can be made self-enrollable.  Therefore, the employee cannot
   -- self-enroll.
   if p_public_flag = 'Y' then
      return 'N';
   else
      return emp_has_access_to_forum(p_person_id, p_forum_id, 'Y');
   end if;
end emp_can_self_enroll_in_forum;


function ext_can_enroll_in_forum(
   p_party_id in hz_parties.party_id%type,
   p_forum_id in ota_forums_b.forum_id%type,
   p_public_flag ota_forums_b.public_flag%type,
   p_start_date_active in ota_forums_b.start_date_active%type,
   p_category_usage_id in ota_category_usages.category_usage_id%type default null) return varchar2 is
begin
   if p_public_flag = 'Y' then
      return 'Y';
   else
      return ext_has_access_to_forum(p_party_id, p_forum_id, 'N');
   end if;
end ext_can_enroll_in_forum;


function ext_can_self_enroll_in_forum(
   p_party_id in hz_parties.party_id%type,
   p_forum_id in ota_forums_b.forum_id%type,
   p_public_flag ota_forums_b.public_flag%type,
   p_start_date_active in ota_forums_b.start_date_active%type,
   p_category_usage_id in ota_category_usages.category_usage_id%type default null) return varchar2 is
begin
   -- A public forum disregards its learner access records.  Learner access records
   -- are the only way an event can be made self-enrollable.  Therefore, the ext learner cannot
   -- self-enroll.
   if p_public_flag = 'Y' then
      return 'N';
   else
      return ext_has_access_to_forum(p_party_id, p_forum_id, 'Y');
   end if;
end ext_can_self_enroll_in_forum;


function learner_can_enroll_in_forum(
   p_person_id in per_people_f.person_id%type,
   p_party_id in hz_parties.party_id%type,
   p_forum_id in ota_forums_b.forum_id%type,
   p_public_flag ota_forums_b.public_flag%type,
   p_start_date_active in ota_forums_b.start_date_active%type,
   p_category_usage_id in ota_category_usages.category_usage_id%type default null) return varchar2 is
begin
   if p_person_id is not null then
      return emp_can_enroll_in_forum(p_person_id, p_forum_id, p_public_flag, p_start_date_active, p_category_usage_id);
   else
      return ext_can_enroll_in_forum(p_party_id, p_forum_id, p_public_flag, p_start_date_active, p_category_usage_id);
   end if;
end learner_can_enroll_in_forum;


function learner_can_enroll_in_forum(
   p_user_id in fnd_user.user_id%type,
   p_forum_id in ota_forums_b.forum_id%type,
   p_public_flag ota_forums_b.public_flag%type,
   p_start_date_active in ota_forums_b.start_date_active%type,
   p_category_usage_id in ota_category_usages.category_usage_id%type default null) return varchar2 is

   v_employee_id fnd_user.employee_id%type;
   v_party_id hz_parties.party_id%type;
begin
   select   employee_id, person_party_id
   into     v_employee_id, v_party_id
   from     fnd_user
   where    user_id = p_user_id;

   return learner_can_enroll_in_forum(v_employee_id, v_party_id, p_forum_id, p_public_flag, p_start_date_active, p_category_usage_id);
end learner_can_enroll_in_forum;


function lrn_can_self_enroll_in_forum(
   p_person_id in per_people_f.person_id%type,
   p_party_id in hz_parties.party_id%type,
   p_forum_id in ota_forums_b.forum_id%type,
   p_public_flag ota_forums_b.public_flag%type,
   p_start_date_active in ota_forums_b.start_date_active%type,
   p_category_usage_id in ota_category_usages.category_usage_id%type default null) return varchar2 is
begin
   if p_person_id is not null then
      return emp_can_self_enroll_in_forum(p_person_id, p_forum_id, p_public_flag, p_start_date_active, p_category_usage_id);
   else
      return ext_can_self_enroll_in_forum(p_party_id, p_forum_id, p_public_flag, p_start_date_active, p_category_usage_id);
   end if;
end lrn_can_self_enroll_in_forum;


function lrn_can_self_enroll_in_forum(
   p_user_id in fnd_user.user_id%type,
   p_forum_id in ota_forums_b.forum_id%type,
   p_public_flag ota_forums_b.public_flag%type,
   p_start_date_active in ota_forums_b.start_date_active%type,
   p_category_usage_id in ota_category_usages.category_usage_id%type default null) return varchar2 is

   v_employee_id fnd_user.employee_id%type;
   v_party_id hz_parties.party_id%type;
begin
   select   employee_id, person_party_id
   into     v_employee_id, v_party_id
   from     fnd_user
   where    user_id = p_user_id;

   return lrn_can_self_enroll_in_forum(v_employee_id, v_party_id, p_forum_id, p_public_flag, p_start_date_active, p_category_usage_id);
end lrn_can_self_enroll_in_forum;
--end of utilities for forums

--functions for chats(open) enrollments

function emp_has_access_to_chat(
   p_person_id in per_people_f.person_id%type,
   p_chat_id in ota_chats_b.chat_id%type,
   p_self_enroll_only in varchar2) return varchar2 is

   l_now date := sysdate;
   l_object_id ota_chat_obj_inclusions.object_id%type;
   l_parent_cat_usage_id_1 ota_category_usages.category_usage_id%type;
   l_parent_cat_usage_id_2 ota_category_usages.category_usage_id%type;
   l_parent_cat_usage_id_3 ota_category_usages.category_usage_id%type;
   l_parent_cat_usage_id_4 ota_category_usages.category_usage_id%type;
begin
   -- Get the chat's five levels of categories.  If the category tree is deeper than that,
   -- we will have to use CONNECT BY below.
   open csr_chat_tree(p_chat_id);
   fetch csr_chat_tree into
      l_object_id, l_parent_cat_usage_id_1, l_parent_cat_usage_id_2,
      l_parent_cat_usage_id_3, l_parent_cat_usage_id_4;
   close csr_chat_tree;

   for assoc in csr_chat_assoc(p_self_enroll_only, p_chat_id, l_object_id, l_parent_cat_usage_id_1, l_parent_cat_usage_id_2, l_parent_cat_usage_id_3, l_parent_cat_usage_id_4) loop
     if (assoc.user_group_id is not null) then
        if(is_learner_in_user_group(p_person_id,assoc.user_group_id,ota_general.get_business_group_id) = 'Y' ) then
            return 'Y';
        end if;
     else
        if person_matches_assoc(p_person_id, l_now, assoc.person_id, assoc.organization_id, assoc.org_structure_version_id, assoc.job_id, assoc.position_id, assoc.match_type) = true then
            return 'Y';
        end if;
     end if;
   end loop;

   -- if the 4th-level parent category is not null, then there may be more parent
   -- categories above.  Use a CONNECT BY cursor.
   if l_parent_cat_usage_id_4 is not null then
      for assoc in csr_category_assoc(p_self_enroll_only, l_parent_cat_usage_id_4) loop
        if (assoc.user_group_id is not null) then
            if(is_learner_in_user_group(p_person_id,assoc.user_group_id,ota_general.get_business_group_id) = 'Y' ) then
               return 'Y';
            end if;
         else
             if person_matches_assoc(p_person_id, l_now, assoc.person_id, assoc.organization_id, assoc.org_structure_version_id, assoc.job_id, assoc.position_id, assoc.match_type) = true then
                return 'Y';
             end if;
         end if;
      end loop;
   end if;

   return 'N';
end emp_has_access_to_chat;


function ext_has_access_to_chat(
   p_party_id in hz_parties.party_id%type,
   p_chat_id in ota_chats_b.chat_id%type,
   p_self_enroll_only in varchar2) return varchar2 is

   l_object_id ota_chat_obj_inclusions.object_id%type;
   l_parent_cat_usage_id_1 ota_category_usages.category_usage_id%type;
   l_parent_cat_usage_id_2 ota_category_usages.category_usage_id%type;
   l_parent_cat_usage_id_3 ota_category_usages.category_usage_id%type;
   l_parent_cat_usage_id_4 ota_category_usages.category_usage_id%type;
begin
   -- Get the chat's five levels of categories.  If the category tree is deeper than that,
   -- we will have to use CONNECT BY below.
   open csr_chat_tree(p_chat_id);
   fetch csr_chat_tree into
      l_object_id, l_parent_cat_usage_id_1, l_parent_cat_usage_id_2,
      l_parent_cat_usage_id_3, l_parent_cat_usage_id_4;
   close csr_chat_tree;

   for assoc in csr_chat_assoc_ext(p_self_enroll_only, p_party_id, p_chat_id, l_object_id, l_parent_cat_usage_id_1, l_parent_cat_usage_id_2, l_parent_cat_usage_id_3, l_parent_cat_usage_id_4) loop
      return 'Y';
   end loop;

   -- if the 4th-level parent category is not null, then there may be more parent
   -- categories above.  Use a CONNECT BY cursor as a last resort - it's slow.
   if l_parent_cat_usage_id_4 is not null then
      for assoc in csr_category_assoc_ext(p_self_enroll_only, p_party_id, l_parent_cat_usage_id_4) loop
         return 'Y';
      end loop;
   end if;

   return 'N';
end ext_has_access_to_chat;


function emp_can_enroll_in_chat(
   p_person_id in per_people_f.person_id%type,
   p_chat_id in ota_chats_b.chat_id%type,
   p_public_flag ota_chats_b.public_flag%type,
   p_start_date_active in ota_chats_b.start_date_active%type,
   p_category_usage_id in ota_category_usages.category_usage_id%type default null) return varchar2 is
begin
   if p_public_flag = 'Y' then
      return 'Y';
   else
      return emp_has_access_to_chat(p_person_id, p_chat_id, 'N');
   end if;
end emp_can_enroll_in_chat;


function emp_can_self_enroll_in_chat(
   p_person_id in per_people_f.person_id%type,
   p_chat_id in ota_chats_b.chat_id%type,
   p_public_flag ota_chats_b.public_flag%type,
   p_start_date_active in ota_chats_b.start_date_active%type,
   p_category_usage_id in ota_category_usages.category_usage_id%type default null) return varchar2 is
begin
   -- A public chat disregards its learner access records.  Learner access records
   -- are the only way an event can be made self-enrollable.  Therefore, the employee cannot
   -- self-enroll.
   if p_public_flag = 'Y' then
      return 'N';
   else
      return emp_has_access_to_chat(p_person_id, p_chat_id, 'Y');
   end if;
end emp_can_self_enroll_in_chat;


function ext_can_enroll_in_chat(
   p_party_id in hz_parties.party_id%type,
   p_chat_id in ota_chats_b.chat_id%type,
   p_public_flag ota_chats_b.public_flag%type,
   p_start_date_active in ota_chats_b.start_date_active%type,
   p_category_usage_id in ota_category_usages.category_usage_id%type default null) return varchar2 is
begin
   if p_public_flag = 'Y' then
      return 'Y';
   else
      return ext_has_access_to_chat(p_party_id, p_chat_id, 'N');
   end if;
end ext_can_enroll_in_chat;


function ext_can_self_enroll_in_chat(
   p_party_id in hz_parties.party_id%type,
   p_chat_id in ota_chats_b.chat_id%type,
   p_public_flag ota_chats_b.public_flag%type,
   p_start_date_active in ota_chats_b.start_date_active%type,
   p_category_usage_id in ota_category_usages.category_usage_id%type default null) return varchar2 is
begin
   -- A public chat disregards its learner access records.  Learner access records
   -- are the only way an event can be made self-enrollable.  Therefore, the ext learner cannot
   -- self-enroll.
   if p_public_flag = 'Y' then
      return 'N';
   else
      return ext_has_access_to_chat(p_party_id, p_chat_id, 'Y');
   end if;
end ext_can_self_enroll_in_chat;


function learner_can_enroll_in_chat(
   p_person_id in per_people_f.person_id%type,
   p_party_id in hz_parties.party_id%type,
   p_chat_id in ota_chats_b.chat_id%type,
   p_public_flag ota_chats_b.public_flag%type,
   p_start_date_active in ota_chats_b.start_date_active%type,
   p_category_usage_id in ota_category_usages.category_usage_id%type default null) return varchar2 is
begin
   if p_person_id is not null then
      return emp_can_enroll_in_chat(p_person_id, p_chat_id, p_public_flag, p_start_date_active, p_category_usage_id);
   else
      return ext_can_enroll_in_chat(p_party_id, p_chat_id, p_public_flag, p_start_date_active, p_category_usage_id);
   end if;
end learner_can_enroll_in_chat;


function learner_can_enroll_in_chat(
   p_user_id in fnd_user.user_id%type,
   p_chat_id in ota_chats_b.chat_id%type,
   p_public_flag ota_chats_b.public_flag%type,
   p_start_date_active in ota_chats_b.start_date_active%type,
   p_category_usage_id in ota_category_usages.category_usage_id%type default null) return varchar2 is

   v_employee_id fnd_user.employee_id%type;
   v_party_id hz_parties.party_id%type;
begin
   select   employee_id, person_party_id
   into     v_employee_id, v_party_id
   from     fnd_user
   where    user_id = p_user_id;

   return learner_can_enroll_in_chat(v_employee_id, v_party_id, p_chat_id, p_public_flag, p_start_date_active, p_category_usage_id);
end learner_can_enroll_in_chat;


function lrn_can_self_enroll_in_chat(
   p_person_id in per_people_f.person_id%type,
   p_party_id in hz_parties.party_id%type,
   p_chat_id in ota_chats_b.chat_id%type,
   p_public_flag ota_chats_b.public_flag%type,
   p_start_date_active in ota_chats_b.start_date_active%type,
   p_category_usage_id in ota_category_usages.category_usage_id%type default null) return varchar2 is
begin
   if p_person_id is not null then
      return emp_can_self_enroll_in_chat(p_person_id, p_chat_id, p_public_flag, p_start_date_active, p_category_usage_id);
   else
      return ext_can_self_enroll_in_chat(p_party_id, p_chat_id, p_public_flag, p_start_date_active, p_category_usage_id);
   end if;
end lrn_can_self_enroll_in_chat;


function lrn_can_self_enroll_in_chat(
   p_user_id in fnd_user.user_id%type,
   p_chat_id in ota_chats_b.chat_id%type,
   p_public_flag ota_chats_b.public_flag%type,
   p_start_date_active in ota_chats_b.start_date_active%type,
   p_category_usage_id in ota_category_usages.category_usage_id%type default null) return varchar2 is

   v_employee_id fnd_user.employee_id%type;
   v_party_id hz_parties.party_id%type;
begin
   select   employee_id, person_party_id
   into     v_employee_id, v_party_id
   from     fnd_user
   where    user_id = p_user_id;

   return lrn_can_self_enroll_in_chat(v_employee_id, v_party_id, p_chat_id, p_public_flag, p_start_date_active, p_category_usage_id);
end lrn_can_self_enroll_in_chat;
--end of utilities for chats


function emp_has_access_to_cert(
   p_person_id in per_people_f.person_id%type,
   p_certification_id in ota_certifications_b.certification_id%type,
   p_self_enroll_only in varchar2) return varchar2 is

   l_now date := sysdate;
   l_category_usage_id ota_category_usages.category_usage_id%type;
   l_parent_cat_usage_id_1 ota_category_usages.category_usage_id%type;
   l_parent_cat_usage_id_2 ota_category_usages.category_usage_id%type;
   l_parent_cat_usage_id_3 ota_category_usages.category_usage_id%type;
   l_parent_cat_usage_id_4 ota_category_usages.category_usage_id%type;
begin
   -- Get the certification's five levels of categories.  If the category tree is deeper than that,
   -- we will have to use CONNECT BY below.
   open csr_cert_tree(p_certification_id);
   fetch csr_cert_tree into
      l_category_usage_id, l_parent_cat_usage_id_1, l_parent_cat_usage_id_2,
      l_parent_cat_usage_id_3, l_parent_cat_usage_id_4;
   close csr_cert_tree;

   for assoc in csr_cert_assoc(p_self_enroll_only, p_certification_id, l_category_usage_id, l_parent_cat_usage_id_1, l_parent_cat_usage_id_2, l_parent_cat_usage_id_3, l_parent_cat_usage_id_4) loop
     if (assoc.user_group_id is not null) then
        if(is_learner_in_user_group(p_person_id,assoc.user_group_id,ota_general.get_business_group_id) = 'Y' ) then
            return 'Y';
        end if;
     else
          if person_matches_assoc(p_person_id, l_now, assoc.person_id, assoc.organization_id, assoc.org_structure_version_id, assoc.job_id, assoc.position_id, assoc.match_type) = true then
            return 'Y';
          end if;
     end if;
   end loop;

   -- if the 4th-level parent category is not null, then there may be more parent
   -- categories above.  Use a CONNECT BY cursor.
   if l_parent_cat_usage_id_4 is not null then
      for assoc in csr_category_assoc(p_self_enroll_only, l_parent_cat_usage_id_4) loop
        if (assoc.user_group_id is not null) then
            if(is_learner_in_user_group(p_person_id,assoc.user_group_id,ota_general.get_business_group_id) = 'Y' ) then
                return 'Y';
            end if;
        else
            if person_matches_assoc(p_person_id, l_now, assoc.person_id, assoc.organization_id, assoc.org_structure_version_id, assoc.job_id, assoc.position_id, assoc.match_type) = true then
                return 'Y';
            end if;
        end if;
      end loop;
   end if;

   return 'N';
end emp_has_access_to_cert;


function ext_has_access_to_cert(
   p_party_id in hz_parties.party_id%type,
   p_certification_id in ota_certifications_b.certification_id%type,
   p_self_enroll_only in varchar2) return varchar2 is

   l_category_usage_id ota_category_usages.category_usage_id%type;
   l_parent_cat_usage_id_1 ota_category_usages.category_usage_id%type;
   l_parent_cat_usage_id_2 ota_category_usages.category_usage_id%type;
   l_parent_cat_usage_id_3 ota_category_usages.category_usage_id%type;
   l_parent_cat_usage_id_4 ota_category_usages.category_usage_id%type;
begin
   -- Get the certification's five levels of categories.  If the category tree is deeper than that,
   -- we will have to use CONNECT BY below.
   open csr_cert_tree(p_certification_id);
   fetch csr_cert_tree into
      l_category_usage_id, l_parent_cat_usage_id_1, l_parent_cat_usage_id_2,
      l_parent_cat_usage_id_3, l_parent_cat_usage_id_4;
   close csr_cert_tree;

   for assoc in csr_cert_assoc_ext(p_self_enroll_only, p_party_id, p_certification_id, l_category_usage_id, l_parent_cat_usage_id_1, l_parent_cat_usage_id_2, l_parent_cat_usage_id_3, l_parent_cat_usage_id_4) loop
      return 'Y';
   end loop;

   -- if the 4th-level parent category is not null, then there may be more parent
   -- categories above.  Use a CONNECT BY cursor as a last resort - it's slow.
   if l_parent_cat_usage_id_4 is not null then
      for assoc in csr_category_assoc_ext(p_self_enroll_only, p_party_id, l_parent_cat_usage_id_4) loop
         return 'Y';
      end loop;
   end if;

   return 'N';
end ext_has_access_to_cert;


function emp_can_enroll_in_cert(
   p_person_id in per_people_f.person_id%type,
   p_certification_id in ota_certifications_b.certification_id%type,
   p_public_flag ota_certifications_b.public_flag%type,
   p_start_date_active in ota_certifications_b.start_date_active%type,
   p_category_usage_id in ota_category_usages.category_usage_id%type default null) return varchar2 is
begin
   if p_public_flag = 'Y' then
      return 'Y';
   else
      return emp_has_access_to_cert(p_person_id, p_certification_id, 'N');
   end if;
end emp_can_enroll_in_cert;


function emp_can_self_enroll_in_cert(
   p_person_id in per_people_f.person_id%type,
   p_certification_id in ota_certifications_b.certification_id%type,
   p_public_flag ota_certifications_b.public_flag%type,
   p_start_date_active in ota_certifications_b.start_date_active%type,
   p_category_usage_id in ota_category_usages.category_usage_id%type default null) return varchar2 is
begin
   -- A public certification disregards its learner access records.  Learner access records
   -- are the only way a certification can be made self-enrollable.  Therefore, the employee cannot
   -- self-enroll.
   if p_public_flag = 'Y' then
      return 'N';
   else
      return emp_has_access_to_cert(p_person_id, p_certification_id, 'Y');
   end if;
end emp_can_self_enroll_in_cert;


function ext_can_enroll_in_cert(
   p_party_id in hz_parties.party_id%type,
   p_certification_id in ota_certifications_b.certification_id%type,
   p_public_flag ota_certifications_b.public_flag%type,
   p_start_date_active in ota_certifications_b.start_date_active%type,
   p_category_usage_id in ota_category_usages.category_usage_id%type default null) return varchar2 is
begin
   if p_public_flag = 'Y' then
      return 'Y';
   else
      return ext_has_access_to_cert(p_party_id, p_certification_id, 'N');
   end if;
end ext_can_enroll_in_cert;


function ext_can_self_enroll_in_cert(
   p_party_id in hz_parties.party_id%type,
   p_certification_id in ota_certifications_b.certification_id%type,
   p_public_flag ota_certifications_b.public_flag%type,
   p_start_date_active in ota_certifications_b.start_date_active%type,
   p_category_usage_id in ota_category_usages.category_usage_id%type default null) return varchar2 is
begin
   -- A public certification disregards its learner access records.  Learner access records
   -- are the only way a certification can be made self-enrollable.  Therefore, the ext learner cannot
   -- self-enroll.
   if p_public_flag = 'Y' then
      return 'N';
   else
      return ext_has_access_to_cert(p_party_id, p_certification_id, 'Y');
   end if;
end ext_can_self_enroll_in_cert;


function learner_can_enroll_in_cert(
   p_person_id in per_people_f.person_id%type,
   p_party_id in hz_parties.party_id%type,
   p_certification_id in ota_certifications_b.certification_id%type,
   p_public_flag ota_certifications_b.public_flag%type,
   p_start_date_active in ota_certifications_b.start_date_active%type,
   p_category_usage_id in ota_category_usages.category_usage_id%type default null) return varchar2 is
begin
   if p_person_id is not null then
      return emp_can_enroll_in_cert(p_person_id, p_certification_id, p_public_flag, p_start_date_active, p_category_usage_id);
   else
      return ext_can_enroll_in_cert(p_party_id, p_certification_id, p_public_flag, p_start_date_active, p_category_usage_id);
   end if;
end learner_can_enroll_in_cert;


function learner_can_enroll_in_cert(
   p_user_id in fnd_user.user_id%type,
   p_certification_id in ota_certifications_b.certification_id%type,
   p_public_flag ota_certifications_b.public_flag%type,
   p_start_date_active in ota_certifications_b.start_date_active%type,
   p_category_usage_id in ota_category_usages.category_usage_id%type default null) return varchar2 is

   v_employee_id fnd_user.employee_id%type;
   v_party_id hz_parties.party_id%type;
begin
   select   employee_id, person_party_id
   into     v_employee_id, v_party_id
   from     fnd_user
   where    user_id = p_user_id;

   return learner_can_enroll_in_cert(v_employee_id, v_party_id, p_certification_id, p_public_flag, p_start_date_active, p_category_usage_id);
end learner_can_enroll_in_cert;


function lrn_can_self_enroll_in_cert(
   p_person_id in per_people_f.person_id%type,
   p_party_id in hz_parties.party_id%type,
   p_certification_id in ota_certifications_b.certification_id%type,
   p_public_flag ota_certifications_b.public_flag%type,
   p_start_date_active in ota_certifications_b.start_date_active%type,
   p_category_usage_id in ota_category_usages.category_usage_id%type default null) return varchar2 is
begin
   if p_person_id is not null then
      return emp_can_self_enroll_in_cert(p_person_id, p_certification_id, p_public_flag, p_start_date_active, p_category_usage_id);
   else
      return ext_can_self_enroll_in_cert(p_party_id, p_certification_id, p_public_flag, p_start_date_active, p_category_usage_id);
   end if;
end lrn_can_self_enroll_in_cert;


function lrn_can_self_enroll_in_cert(
   p_user_id in fnd_user.user_id%type,
   p_certification_id in ota_certifications_b.certification_id%type,
   p_public_flag ota_certifications_b.public_flag%type,
   p_start_date_active in ota_certifications_b.start_date_active%type,
   p_category_usage_id in ota_category_usages.category_usage_id%type default null) return varchar2 is

   v_employee_id fnd_user.employee_id%type;
   v_party_id hz_parties.party_id%type;
begin
   select   employee_id, person_party_id
   into     v_employee_id, v_party_id
   from     fnd_user
   where    user_id = p_user_id;

   return lrn_can_self_enroll_in_cert(v_employee_id, v_party_id, p_certification_id, p_public_flag, p_start_date_active, p_category_usage_id);
end lrn_can_self_enroll_in_cert;

function learner_can_enroll_in_path(
       p_learning_path_id in ota_learning_paths.learning_path_id%TYPE
       ,p_person_id in per_all_people_f.person_id%type
      ,p_party_id  in hz_parties.party_id%type) return varchar2
IS
   CURSOR csr_get_lp_details IS
     SELECT public_flag, start_date_active
     FROM ota_learning_paths
     WHERE learning_path_id = p_learning_path_id;

     l_start_date_active ota_learning_paths.start_date_active%TYPE;
     l_public_flag ota_learning_paths.public_flag%TYPE;
BEGIN
   OPEN csr_get_lp_details;
   FETCH csr_get_lp_details INTO l_public_flag, l_start_date_active ;
   IF csr_get_lp_details%NOTFOUND THEN
         CLOSE csr_get_lp_details;
	RETURN 'N';
   ELSE
         CLOSE csr_get_lp_details;
	 RETURN learner_can_enroll_in_path(p_person_id                => p_person_id
	                                                                    , p_party_id                     => p_party_id
									    , p_learning_path_id    => p_learning_path_id
									    , p_public_flag               => l_public_flag
									    , p_start_date_active    => l_start_date_active);
   END IF;

END learner_can_enroll_in_path;

 function learner_can_enroll_in_cert(
        p_certification_id in ota_certifications_b.certification_id%type
       ,p_person_id in per_all_people_f.person_id%type
      ,p_party_id  in hz_parties.party_id%type) return varchar2
IS
      CURSOR csr_get_cert_details IS
     SELECT public_flag, start_date_active
     FROM ota_certifications_b
     WHERE certification_id = p_certification_id;

     l_start_date_active ota_certifications_b.start_date_active%TYPE;
     l_public_flag ota_certifications_b.public_flag%TYPE;
BEGIN
   OPEN csr_get_cert_details;
   FETCH csr_get_cert_details INTO l_public_flag, l_start_date_active ;
   IF csr_get_cert_details%NOTFOUND THEN
         CLOSE csr_get_cert_details;
	RETURN 'N';
   ELSE
         CLOSE csr_get_cert_details;
	 RETURN learner_can_enroll_in_cert(p_person_id            => p_person_id
	                                                                    , p_party_id                => p_party_id
									    , p_certification_id    => p_certification_id
									    , p_public_flag           => l_public_flag
									    , p_start_date_active => l_start_date_active);
   END IF;
END learner_can_enroll_in_cert;

function learner_has_access_to_course(
   p_person_id in per_people_f.person_id%type,
   p_party_id in hz_parties.party_id%type,
   p_activity_version_id in ota_activity_versions.activity_version_id%type,
   showLPOnlyClasses in varchar2 default 'N') return varchar2 is

CURSOR csr_classes_in_course(
      p_activity_version_id in ota_activity_versions.activity_version_id%type,
      p_business_group_id ota_events.business_group_id%type) is
SELECT OEV.event_id,
       OEV.public_event_flag,
       OEV.maximum_internal_attendees,
       OEV.course_start_date
FROM ota_category_usages OCU,
     ota_events OEV,
     ota_offerings OFR,
     ota_activity_versions OAV
WHERE OAV.activity_version_id = p_activity_version_id
      AND OFR.activity_version_id = OAV.activity_version_id
      AND OEV.parent_offering_id = OFR.offering_id
      AND OEV.business_group_id = p_business_group_id
      AND OEV.event_type IN ('SCHEDULED','SELFPACED')
      AND OEV.book_independent_flag = 'N'
      AND OEV.Event_status in('N','P','F')
      AND OFR.delivery_mode_id = OCU.category_usage_id
      AND OCU.type ='DM'
      AND trunc(sysdate) BETWEEN nvl(OAV.start_date, trunc(sysdate)) AND nvl(OAV.end_date, trunc(sysdate+1))
      AND ota_timezone_util.convert_date(sysdate, to_char(sysdate,'HH24:MI'), ota_timezone_util.get_server_timezone_code, OEV.timezone)
          BETWEEN to_date(to_char(nvl(OEV.enrolment_start_date,to_date('4712/12/31','YYYY/MM/DD')),'YYYY/MM/DD') || ' ' || '00:00' , 'YYYY/MM/DD HH24:MI')
          AND to_date(to_char(nvl(OEV.enrolment_end_date,to_date('4712/12/31','YYYY/MM/DD')),'YYYY/MM/DD') || ' ' || '23:59', 'YYYY/MM/DD HH24:MI')
      ORDER BY OEV.public_event_flag DESC;

CURSOR csr_normal_classes_in_course(
      p_activity_version_id in ota_activity_versions.activity_version_id%type,
      p_business_group_id ota_events.business_group_id%type) is
SELECT OEV.event_id,
       OEV.public_event_flag,
       OEV.maximum_internal_attendees,
       OEV.course_start_date
FROM ota_category_usages OCU,
     ota_events OEV,
     ota_offerings OFR,
     ota_activity_versions OAV
WHERE OAV.activity_version_id = p_activity_version_id
      AND OFR.activity_version_id = OAV.activity_version_id
      AND OEV.parent_offering_id = OFR.offering_id
      AND OEV.business_group_id = p_business_group_id
      AND OEV.event_type IN ('SCHEDULED','SELFPACED')
      AND OEV.book_independent_flag = 'N'
      AND OEV.Event_status in('N','P','F')
      AND OFR.delivery_mode_id = OCU.category_usage_id
      AND OCU.type ='DM'
      AND trunc(sysdate) BETWEEN nvl(OAV.start_date, trunc(sysdate)) AND nvl(OAV.end_date, trunc(sysdate+1))
      AND ota_timezone_util.convert_date(sysdate, to_char(sysdate,'HH24:MI'), ota_timezone_util.get_server_timezone_code, OEV.timezone)
          BETWEEN to_date(to_char(nvl(OEV.enrolment_start_date,to_date('4712/12/31','YYYY/MM/DD')),'YYYY/MM/DD') || ' ' || '00:00' , 'YYYY/MM/DD HH24:MI')
          AND to_date(to_char(nvl(OEV.enrolment_end_date,to_date('4712/12/31','YYYY/MM/DD')),'YYYY/MM/DD') || ' ' || '23:59', 'YYYY/MM/DD HH24:MI')
      AND nvl(OEV.event_availability, 'ALL') = 'ALL'
      ORDER BY OEV.public_event_flag DESC;

      l_business_group_id ota_events.business_group_id%type;
begin

   l_business_group_id := ota_general.get_business_group_id;
   if(showLPOnlyClasses = 'Y') then
    for assoc in csr_classes_in_course(p_activity_version_id, l_business_group_id) loop
      if learner_can_enroll(p_person_id, p_party_id, assoc.event_id, assoc.public_event_flag, assoc.maximum_internal_attendees, assoc.course_start_date) = 'Y' then
        return 'Y';
      end if;
    end loop;
   else
	for assoc in csr_normal_classes_in_course(p_activity_version_id, l_business_group_id) loop
        if learner_can_enroll(p_person_id, p_party_id, assoc.event_id, assoc.public_event_flag, assoc.maximum_internal_attendees, assoc.course_start_date) = 'Y' then
	        return 'Y';
	    end if;
    end loop;
   end if;

   return 'N';
end learner_has_access_to_course;

/*
Always use this procedure to check learner access for a person as this
taking care the whole hierarchy for a user group.
If there is any change in this procedure make sure, the changes are
done in the procedure get_ug_whereclause
*/
function is_learner_in_user_group(
   p_person_id in per_people_f.person_id%type,
   p_user_group_id in ota_user_groups_b.user_group_id%type,
   p_business_group_id number,
   p_ignore_ug_date_check varchar2 default 'N') return varchar2 is

is_avail BOOLEAN default false;
ug_index NUMBER := 1;
begin

  for ug_hierarchy in csr_ug_hierarchy(p_user_group_id, p_business_group_id, p_ignore_ug_date_check) loop

    is_avail := is_learner_matches_user_group(p_person_id, ug_hierarchy.child_user_group_id, p_business_group_id, p_ignore_ug_date_check);

    person_ug_map_rec_table(ug_index).person_id := p_person_id;
    person_ug_map_rec_table(ug_index).user_group_id := ug_hierarchy.child_user_group_id;
    person_ug_map_rec_table(ug_index).is_person_matches_ug := is_avail;

    ug_index := ug_index+1;

  end loop; --each user group in the hierarchy has been filled with true or false

 --process for root
    is_avail := is_learner_matches_user_group(p_person_id, p_user_group_id, p_business_group_id, p_ignore_ug_date_check);

    person_ug_map_rec_table(ug_index).person_id := p_person_id;
    person_ug_map_rec_table(ug_index).user_group_id := p_user_group_id;
    person_ug_map_rec_table(ug_index).is_person_matches_ug := is_avail;

  if(is_avail = true) then
     return 'Y';
  else
     return 'N';
  end if;

end is_learner_in_user_group;

function is_learner_matches_user_group(
   p_person_id in per_people_f.person_id%type,
   p_user_group_id in ota_user_groups_b.user_group_id%type,
   p_business_group_id number,
   p_ignore_ug_date_check varchar2 default 'N') return boolean is

l_user_group_operator ota_user_groups_b.user_group_operator%type;
l_person_id per_people_f.person_id%type;
l_user_group_id ota_user_groups_b.user_group_id%type;
l_is_avail BOOLEAN default false;

begin
 for elements in csr_user_group_elements(p_user_group_id, p_business_group_id, p_ignore_ug_date_check) loop

  l_user_group_operator := elements.user_group_operator;

  if elements.user_group_operator is not null and elements.user_group_operator = 'AND' then
     if elements.person_id is not null and elements.person_id <> p_person_id then
        return false;
      else
           if elements.child_user_group_id is not null then

             for i in 1 .. person_ug_map_rec_table.count loop
                  l_person_id := person_ug_map_rec_table(i).person_id;
                  l_user_group_id := person_ug_map_rec_table(i).user_group_id;
                  l_is_avail := person_ug_map_rec_table(i).is_person_matches_ug;

              if( l_person_id is not null and l_person_id = p_person_id and
                  l_user_group_id is not null and l_user_group_id = elements.child_user_group_id and
                  l_is_avail is not null and l_is_avail = false) then

                    return false;
              end if;
             end loop;
         else
            if person_matches_assoc(p_person_id, sysdate, elements.person_id, elements.organization_id, elements.org_structure_version_id, elements.job_id, elements.position_id, elements.match_type) = false then
               return false;
             end if;
        end if;
      end if;
  else
     if elements.person_id is not null and elements.person_id = p_person_id then
        return true;
      else
           if elements.child_user_group_id is not null then

             for i in 1 .. person_ug_map_rec_table.count loop
                  l_person_id := person_ug_map_rec_table(i).person_id;
                  l_user_group_id := person_ug_map_rec_table(i).user_group_id;
                  l_is_avail := person_ug_map_rec_table(i).is_person_matches_ug;

              if( l_person_id is not null and l_person_id = p_person_id and
                  l_user_group_id is not null and l_user_group_id = elements.child_user_group_id and
                  l_is_avail is not null and l_is_avail = true) then

                    return true;
              end if;
             end loop;
         else
            if person_matches_assoc(p_person_id, sysdate, elements.person_id, elements.organization_id, elements.org_structure_version_id, elements.job_id, elements.position_id, elements.match_type) = true then
               return true;
            end if;
        end if;
      end if;
  end if;
end loop;

 if l_user_group_operator is not null and l_user_group_operator = 'AND' then
      return true;
 else
    return false;
 end if;

end is_learner_matches_user_group;

/*
Always use this procedure to get where clause for a user group as this
taking care the whole hierarchy for a user group.
If there is any change in this procedure make sure, the changes are
done in the procedure is_learner_in_user_group
*/
function get_ug_whereclause(
   p_user_group_id in ota_user_groups_b.user_group_id%type,
   p_business_group_id number) return clob is

whereclause clob;
ug_index NUMBER := 1;
begin

  for ug_hierarchy in csr_ug_hierarchy(p_user_group_id, p_business_group_id) loop

    whereclause := build_ug_whereclause(ug_hierarchy.child_user_group_id, p_business_group_id);

    t_ug_learner_list_table(ug_index).user_group_id := ug_hierarchy.child_user_group_id;
    t_ug_learner_list_table(ug_index).ugwhereclause := whereclause;

    ug_index := ug_index+1;

  end loop; --each user group in the hierarchy has been filled with where clause

    --process root
   whereclause := build_ug_whereclause(p_user_group_id, p_business_group_id);
   t_ug_learner_list_table(ug_index).user_group_id := p_user_group_id;
   t_ug_learner_list_table(ug_index).ugwhereclause := whereclause;

    if (whereclause is null) then -- Bug#6835942
        whereclause := ' (1=2) ';
    end if;

   return whereclause;
end get_ug_whereclause;

function build_ug_whereclause(
   p_user_group_id in ota_user_groups_b.user_group_id%type,
   p_business_group_id number) return clob is

l_user_group_operator ota_user_groups_b.user_group_operator%type;
l_user_group_id ota_user_groups_b.user_group_id%type;
whereclause clob;
childugwhereclause clob;
ugOperatorCheckCount number := 0;
orgHierarchyCount number := 0;

begin
 for elements in csr_user_group_elements(p_user_group_id, p_business_group_id) loop

  l_user_group_operator := elements.user_group_operator;

  if (ugOperatorCheckCount = 0) then
   whereclause := ' ( ';
  end if;

  if (ugOperatorCheckCount > 0 and length(trim(whereclause)) > 1 and elements.child_user_group_id is null) then
     whereclause := whereclause || ' ' || l_user_group_operator || ' ';
  end if;

  if elements.person_id is not null then --person
     whereclause := whereclause || ' person_id =  ' || elements.person_id || ' ';
  else --child user group
     if elements.child_user_group_id is not null then --
        for i in 1 .. t_ug_learner_list_table.count loop
           l_user_group_id := t_ug_learner_list_table(i).user_group_id;
           childugwhereclause := t_ug_learner_list_table(i).ugwhereclause;

          if( l_user_group_id is not null and l_user_group_id = elements.child_user_group_id and whereclause is not null ) then
             if(ugOperatorCheckCount > 0  and length(trim(whereclause)) > 1  and childugwhereclause is not null) then
                whereclause := whereclause || ' ' || l_user_group_operator || ' ';
             end if;
             whereclause := whereclause || '  ' || childugwhereclause || '  ';
             exit;
          end if;
       end loop;
    else  --Assignment
        whereclause := whereclause || ' ( ' ;

        if(elements.job_id is not null) then
          whereclause := whereclause || ' job_id = ' || elements.job_id;
          if(elements.position_id is not null or elements.organization_id is not null) then
            whereclause := whereclause || ' and ';
          end if;
        end if;

        if(elements.position_id is not null) then
          whereclause := whereclause || ' position_id = ' || elements.position_id;
          if(elements.organization_id is not null) then
            whereclause := whereclause || ' and ';
          end if;
        end if;

        if(elements.organization_id is not null) then
          if(elements.org_structure_version_id is null) then
            whereclause := whereclause || ' organization_id = ' || elements.organization_id;
          else
	     orgHierarchyCount := 0;
             whereclause := whereclause || ' organization_id in ( ';
             for orghierarchy in csr_org_hierarchy(elements.organization_id, elements.org_structure_version_id) loop
               if(orgHierarchyCount > 0) then
                  whereclause := whereclause || ' , ';
               end if;
               whereclause := whereclause || orghierarchy.organization_id;
               orgHierarchyCount := orgHierarchyCount+1;
             end loop;
             whereclause := whereclause || ' ) ';
          end if;
        end if;

       whereclause := whereclause || ' ) ' ;

   end if;
 end if;
 ugOperatorCheckCount := ugOperatorCheckCount+1;
end loop;

  if (ugOperatorCheckCount > 0) then
    if (whereclause is not null and length(trim(whereclause)) > 1) then -- Bug#6835942
        whereclause := whereclause || ' ) ';
    else
        whereclause := null;
    end if;
  end if;

   return whereclause;

end build_ug_whereclause;

function is_full_access_learner_group(p_user_group_id in ota_user_groups_b.user_group_id%type,
                                      p_business_group_id number) return varchar2 is

total_elements_count NUMBER := -2;
restricted_elements_count NUMBER := -1;

BEGIN

SELECT count(user_group_element_id) into total_elements_count
FROM OTA_USER_GROUP_ELEMENTS
WHERE user_group_id in ( SELECT child_user_group_id
                         FROM ( SELECT a.child_user_group_id
                                FROM  ota_user_group_elements a,
                                      ota_user_groups_b b
                                WHERE a.user_group_id = b.user_group_id
                                and trunc(sysdate) between trunc(nvl(b.start_date_active, sysdate)) and
                                    trunc(nvl(b.end_date_active, sysdate+1))
                                START WITH a.user_group_id = p_user_group_id
                                CONNECT BY PRIOR a.child_user_group_id = a.user_group_id
                                UNION ALL SELECT p_user_group_id FROM dual
                                ) WHERE child_user_group_id is not null ) and
      (fnd_profile.value('OTA_HR_GLOBAL_BUSINESS_GROUP_ID') is not null
       or business_group_id = p_business_group_id);

SELECT count(a.user_group_element_id) into restricted_elements_count
FROM OTA_USER_GROUP_ELEMENTS a,
   PER_PEOPLE_F e,
   PER_JOBS_VL job,
   HR_ORGANIZATION_UNITS org,
   PER_POSITIONS pos
WHERE a.user_group_id in ( SELECT child_user_group_id
                           FROM ( SELECT a.child_user_group_id
                                FROM  ota_user_group_elements a,
                                      ota_user_groups_b b
                                WHERE a.user_group_id = b.user_group_id
                                and trunc(sysdate) between trunc(nvl(b.start_date_active, sysdate)) and
                                    trunc(nvl(b.end_date_active, sysdate+1))
                                START WITH a.user_group_id = p_user_group_id
                                CONNECT BY PRIOR a.child_user_group_id = a.user_group_id
                                UNION ALL SELECT p_user_group_id FROM dual
                                ) WHERE child_user_group_id is not null ) and
      e.person_id(+) = a.person_id and
      (e.effective_start_date is null or e.effective_start_date <= trunc(sysdate)) and
      (e.effective_end_date is null or trunc(sysdate) <= e.effective_end_date) and
      job.job_id(+) = a.job_id and
      org.organization_id(+) = a.organization_id and
      pos.position_id(+) = a.position_id and
     (fnd_profile.value('OTA_HR_GLOBAL_BUSINESS_GROUP_ID') is not null or
       a.business_group_id = p_business_group_id) and
       -- decode (a.position_id, null, -1, pos.organization_id) = nvl(org.organization_id,-1) and   --7157831
      decode (a.position_id, null, -1, pos.organization_id) = decode(a.position_id, null, -1, org.organization_id) and   --7248298
     (e.person_id is not null or job.job_id is not null or pos.position_id is not null or
      org.organization_id is not null or a.child_user_group_id is not null);

 if (total_elements_count = 0) then   --7157831
     return 'N';
 else
    if( (total_elements_count - restricted_elements_count) = 0) then
        return 'Y';
    else
        return 'N';
    end if;
 end if;
end is_full_access_learner_group;

end ota_learner_access_util;

/
