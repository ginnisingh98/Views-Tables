--------------------------------------------------------
--  DDL for Package OTA_LEARNER_ACCESS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_LEARNER_ACCESS_UTIL" AUTHID CURRENT_USER as
/* $Header: otlrnacc.pkh 120.7.12010000.3 2009/09/16 08:37:32 pekasi ship $ */


--|--------------------------------------------------------------------------|
--|--< CHK_DELEGATE_OK_FOR_EVENT>-------------------------------------------|
--|--------------------------------------------------------------------------|
TYPE person_ug_map IS RECORD (
       person_id  NUMBER
      ,user_group_id  NUMBER
      ,is_person_matches_ug BOOLEAN
    );

TYPE person_ug_map_table IS TABLE OF person_ug_map INDEX BY BINARY_INTEGER;

TYPE ug_learner_list IS RECORD (
       user_group_id  NUMBER
      ,ugwhereclause CLOB
    );

TYPE ug_learner_list_table IS TABLE OF ug_learner_list INDEX BY BINARY_INTEGER;

function learner_can_enroll(
   p_person_id in per_people_f.person_id%type,
   p_party_id in hz_parties.party_id%type,
   p_event_id in ota_events.event_id%type,
   p_public_event_flag in ota_events.public_event_flag%type,
   p_max_internal in ota_events.maximum_internal_attendees%type,
   p_event_start_date in otv_scheduled_events.course_start_date%type,
   p_parent_offering_id in ota_events.parent_offering_id%type default null) return varchar2;


function learner_can_enroll(
   p_person_id in per_people_f.person_id%type,
   p_party_id in hz_parties.party_id%type,
   p_event_id in ota_events.event_id%type,
   p_event_start_date in otv_scheduled_events.course_start_date%type,
   p_parent_offering_id in ota_events.parent_offering_id%type default null) return varchar2;

function learner_can_enroll(
   p_person_id in per_people_f.person_id%type,
   p_party_id in hz_parties.party_id%type,
   p_event_id in ota_events.event_id%type) return varchar2;

function learner_can_self_enroll(
   p_person_id in per_people_f.person_id%type,
   p_party_id in hz_parties.party_id%type,
   p_event_id in ota_events.event_id%type,
   p_public_event_flag in ota_events.public_event_flag%type,
   p_max_internal in ota_events.maximum_internal_attendees%type,
   p_event_start_date in otv_scheduled_events.course_start_date%type,
   p_parent_offering_id in ota_events.parent_offering_id%type default null) return varchar2;


function learner_can_self_enroll(
   p_person_id in per_people_f.person_id%type,
   p_party_id in hz_parties.party_id%type,
   p_event_id in ota_events.event_id%type,
   p_event_start_date in otv_scheduled_events.course_start_date%type,
   p_parent_offering_id in ota_events.parent_offering_id%type default null) return varchar2;

function learner_can_self_enroll(
   p_person_id in per_people_f.person_id%type,
   p_party_id in hz_parties.party_id%type,
   p_event_id in ota_events.event_id%type) return varchar2;

function employee_can_enroll(
   p_person_id in per_people_f.person_id%type,
   p_event_id in ota_events.event_id%type,
   p_public_event_flag ota_events.public_event_flag%type,
   p_max_internal in ota_events.maximum_internal_attendees%type,
   p_event_start_date in otv_scheduled_events.course_start_date%type,
   p_parent_offering_id in ota_events.parent_offering_id%type default null) return varchar2;


function ext_learner_can_enroll(
   p_party_id in hz_parties.party_id%type,
   p_event_id in ota_events.event_id%type,
   p_public_event_flag ota_events.public_event_flag%type,
   p_max_internal in ota_events.maximum_internal_attendees%type,
   p_event_start_date in otv_scheduled_events.course_start_date%type,
   p_parent_offering_id in ota_events.parent_offering_id%type default null) return varchar2;


function chk_delegate_ok_for_event(
   p_delegate_id in per_people_f.person_id%type,
   p_event_id in ota_events.event_id%type,
   p_event_start_date in otv_scheduled_events.course_start_date%type,
   p_parent_offering_id in ota_events.parent_offering_id%type default null) return varchar2;


function learner_can_see_category(
   p_person_id in per_people_f.person_id%type,
   p_party_id in hz_parties.party_id%type,
   p_category_usage_id in ota_category_usages.category_usage_id%type) return varchar2;


function learner_can_see_course(
   p_person_id in per_people_f.person_id%type,
   p_activity_version_id in ota_activity_versions.activity_version_id%type) return varchar2;


function learner_can_see_offering(
   p_person_id in per_people_f.person_id%type,
   p_offering_id in ota_offerings.offering_id%type) return varchar2;


function learner_can_enroll_in_path(
   p_person_id in per_people_f.person_id%type,
   p_party_id in hz_parties.party_id%type,
   p_learning_path_id in ota_learning_paths.learning_path_id%type,
   p_public_flag ota_learning_paths.public_flag%type,
   p_start_date_active in ota_learning_paths.start_date_active%type,
   p_category_usage_id in ota_category_usages.category_usage_id%type default null) return varchar2;


function learner_can_enroll_in_path(
   p_user_id in fnd_user.user_id%type,
   p_learning_path_id in ota_learning_paths.learning_path_id%type,
   p_public_flag ota_learning_paths.public_flag%type,
   p_start_date_active in ota_learning_paths.start_date_active%type,
   p_category_usage_id in ota_category_usages.category_usage_id%type default null) return varchar2;


function emp_can_enroll_in_path(
   p_person_id in per_people_f.person_id%type,
   p_learning_path_id in ota_learning_paths.learning_path_id%type,
   p_public_flag ota_learning_paths.public_flag%type,
   p_start_date_active in ota_learning_paths.start_date_active%type,
   p_category_usage_id in ota_category_usages.category_usage_id%type default null) return varchar2;


function ext_can_enroll_in_path(
   p_party_id in hz_parties.party_id%type,
   p_learning_path_id in ota_learning_paths.learning_path_id%type,
   p_public_flag ota_learning_paths.public_flag%type,
   p_start_date_active in ota_learning_paths.start_date_active%type,
   p_category_usage_id in ota_category_usages.category_usage_id%type default null) return varchar2;


function lrn_can_self_enroll_in_path(
   p_person_id in per_people_f.person_id%type,
   p_party_id in hz_parties.party_id%type,
   p_learning_path_id in ota_learning_paths.learning_path_id%type,
   p_public_flag ota_learning_paths.public_flag%type,
   p_start_date_active in ota_learning_paths.start_date_active%type,
   p_category_usage_id in ota_category_usages.category_usage_id%type default null) return varchar2;


function emp_can_self_enroll_in_path(
   p_person_id in per_people_f.person_id%type,
   p_learning_path_id in ota_learning_paths.learning_path_id%type,
   p_public_flag ota_learning_paths.public_flag%type,
   p_start_date_active in ota_learning_paths.start_date_active%type,
   p_category_usage_id in ota_category_usages.category_usage_id%type default null) return varchar2;


function ext_can_self_enroll_in_path(
   p_party_id in hz_parties.party_id%type,
   p_learning_path_id in ota_learning_paths.learning_path_id%type,
   p_public_flag ota_learning_paths.public_flag%type,
   p_start_date_active in ota_learning_paths.start_date_active%type,
   p_category_usage_id in ota_category_usages.category_usage_id%type default null) return varchar2;

function learner_can_enroll_in_forum(
   p_person_id in per_people_f.person_id%type,
   p_party_id in hz_parties.party_id%type,
   p_forum_id in ota_forums_b.forum_id%type,
   p_public_flag ota_forums_b.public_flag%type,
   p_start_date_active in ota_forums_b.start_date_active%type,
   p_category_usage_id in ota_category_usages.category_usage_id%type default null) return varchar2;


function learner_can_enroll_in_forum(
   p_user_id in fnd_user.user_id%type,
   p_forum_id in ota_forums_b.forum_id%type,
   p_public_flag ota_forums_b.public_flag%type,
   p_start_date_active in ota_forums_b.start_date_active%type,
   p_category_usage_id in ota_category_usages.category_usage_id%type default null) return varchar2;


function emp_can_enroll_in_forum(
   p_person_id in per_people_f.person_id%type,
   p_forum_id in ota_forums_b.forum_id%type,
   p_public_flag ota_forums_b.public_flag%type,
   p_start_date_active in ota_forums_b.start_date_active%type,
   p_category_usage_id in ota_category_usages.category_usage_id%type default null) return varchar2;


function ext_can_enroll_in_forum(
   p_party_id in hz_parties.party_id%type,
   p_forum_id in ota_forums_b.forum_id%type,
   p_public_flag ota_forums_b.public_flag%type,
   p_start_date_active in ota_forums_b.start_date_active%type,
   p_category_usage_id in ota_category_usages.category_usage_id%type default null) return varchar2;


function lrn_can_self_enroll_in_forum(
   p_person_id in per_people_f.person_id%type,
   p_party_id in hz_parties.party_id%type,
   p_forum_id in ota_forums_b.forum_id%type,
   p_public_flag ota_forums_b.public_flag%type,
   p_start_date_active in ota_forums_b.start_date_active%type,
   p_category_usage_id in ota_category_usages.category_usage_id%type default null) return varchar2;


function emp_can_self_enroll_in_forum(
   p_person_id in per_people_f.person_id%type,
   p_forum_id in ota_forums_b.forum_id%type,
   p_public_flag ota_forums_b.public_flag%type,
   p_start_date_active in ota_forums_b.start_date_active%type,
   p_category_usage_id in ota_category_usages.category_usage_id%type default null) return varchar2;


function ext_can_self_enroll_in_forum(
   p_party_id in hz_parties.party_id%type,
   p_forum_id in ota_forums_b.forum_id%type,
   p_public_flag ota_forums_b.public_flag%type,
   p_start_date_active in ota_forums_b.start_date_active%type,
   p_category_usage_id in ota_category_usages.category_usage_id%type default null) return varchar2;

function learner_can_enroll_in_chat(
   p_person_id in per_people_f.person_id%type,
   p_party_id in hz_parties.party_id%type,
   p_chat_id in ota_chats_b.chat_id%type,
   p_public_flag ota_chats_b.public_flag%type,
   p_start_date_active in ota_chats_b.start_date_active%type,
   p_category_usage_id in ota_category_usages.category_usage_id%type default null) return varchar2;


function learner_can_enroll_in_chat(
   p_user_id in fnd_user.user_id%type,
   p_chat_id in ota_chats_b.chat_id%type,
   p_public_flag ota_chats_b.public_flag%type,
   p_start_date_active in ota_chats_b.start_date_active%type,
   p_category_usage_id in ota_category_usages.category_usage_id%type default null) return varchar2;


function emp_can_enroll_in_chat(
   p_person_id in per_people_f.person_id%type,
   p_chat_id in ota_chats_b.chat_id%type,
   p_public_flag ota_chats_b.public_flag%type,
   p_start_date_active in ota_chats_b.start_date_active%type,
   p_category_usage_id in ota_category_usages.category_usage_id%type default null) return varchar2;


function ext_can_enroll_in_chat(
   p_party_id in hz_parties.party_id%type,
   p_chat_id in ota_chats_b.chat_id%type,
   p_public_flag ota_chats_b.public_flag%type,
   p_start_date_active in ota_chats_b.start_date_active%type,
   p_category_usage_id in ota_category_usages.category_usage_id%type default null) return varchar2;


function lrn_can_self_enroll_in_chat(
   p_person_id in per_people_f.person_id%type,
   p_party_id in hz_parties.party_id%type,
   p_chat_id in ota_chats_b.chat_id%type,
   p_public_flag ota_chats_b.public_flag%type,
   p_start_date_active in ota_chats_b.start_date_active%type,
   p_category_usage_id in ota_category_usages.category_usage_id%type default null) return varchar2;


function emp_can_self_enroll_in_chat(
   p_person_id in per_people_f.person_id%type,
   p_chat_id in ota_chats_b.chat_id%type,
   p_public_flag ota_chats_b.public_flag%type,
   p_start_date_active in ota_chats_b.start_date_active%type,
   p_category_usage_id in ota_category_usages.category_usage_id%type default null) return varchar2;


function ext_can_self_enroll_in_chat(
   p_party_id in hz_parties.party_id%type,
   p_chat_id in ota_chats_b.chat_id%type,
   p_public_flag ota_chats_b.public_flag%type,
   p_start_date_active in ota_chats_b.start_date_active%type,
   p_category_usage_id in ota_category_usages.category_usage_id%type default null) return varchar2;

function learner_can_enroll_in_cert(
   p_person_id in per_people_f.person_id%type,
   p_party_id in hz_parties.party_id%type,
   p_certification_id in ota_certifications_b.certification_id%type,
   p_public_flag ota_certifications_b.public_flag%type,
   p_start_date_active in ota_certifications_b.start_date_active%type,
   p_category_usage_id in ota_category_usages.category_usage_id%type default null) return varchar2;


function learner_can_enroll_in_cert(
   p_user_id in fnd_user.user_id%type,
   p_certification_id in ota_certifications_b.certification_id%type,
   p_public_flag ota_certifications_b.public_flag%type,
   p_start_date_active in ota_certifications_b.start_date_active%type,
   p_category_usage_id in ota_category_usages.category_usage_id%type default null) return varchar2;


function emp_can_enroll_in_cert(
   p_person_id in per_people_f.person_id%type,
   p_certification_id in ota_certifications_b.certification_id%type,
   p_public_flag ota_certifications_b.public_flag%type,
   p_start_date_active in ota_certifications_b.start_date_active%type,
   p_category_usage_id in ota_category_usages.category_usage_id%type default null) return varchar2;


function ext_can_enroll_in_cert(
   p_party_id in hz_parties.party_id%type,
   p_certification_id in ota_certifications_b.certification_id%type,
   p_public_flag ota_certifications_b.public_flag%type,
   p_start_date_active in ota_certifications_b.start_date_active%type,
   p_category_usage_id in ota_category_usages.category_usage_id%type default null) return varchar2;


function lrn_can_self_enroll_in_cert(
   p_person_id in per_people_f.person_id%type,
   p_party_id in hz_parties.party_id%type,
   p_certification_id in ota_certifications_b.certification_id%type,
   p_public_flag ota_certifications_b.public_flag%type,
   p_start_date_active in ota_certifications_b.start_date_active%type,
   p_category_usage_id in ota_category_usages.category_usage_id%type default null) return varchar2;


function emp_can_self_enroll_in_cert(
   p_person_id in per_people_f.person_id%type,
   p_certification_id in ota_certifications_b.certification_id%type,
   p_public_flag ota_certifications_b.public_flag%type,
   p_start_date_active in ota_certifications_b.start_date_active%type,
   p_category_usage_id in ota_category_usages.category_usage_id%type default null) return varchar2;


function ext_can_self_enroll_in_cert(
   p_party_id in hz_parties.party_id%type,
   p_certification_id in ota_certifications_b.certification_id%type,
   p_public_flag ota_certifications_b.public_flag%type,
   p_start_date_active in ota_certifications_b.start_date_active%type,
   p_category_usage_id in ota_category_usages.category_usage_id%type default null) return varchar2;

function learner_can_enroll_in_path(
       p_learning_path_id in ota_learning_paths.learning_path_id%TYPE
       ,p_person_id in per_all_people_f.person_id%type
      ,p_party_id  in hz_parties.party_id%type) return varchar2;

 function learner_can_enroll_in_cert(
        p_certification_id in ota_certifications_b.certification_id%TYPE
       ,p_person_id in per_all_people_f.person_id%type
      ,p_party_id  in hz_parties.party_id%type) return varchar2;

FUNCTION emp_has_valid_dates(p_person_id per_all_people_f.person_id%TYPE
                        ,p_event_id ota_events.event_id%TYPE) RETURN VARCHAR2;
function get_event_start_date(
   p_event_id ota_events.event_id%type,
   p_date date) return date;

FUNCTION learner_belongs_to_child_org(p_org_structure_version_id IN ota_event_associations. org_structure_version_id%type,
                                      p_organization_id IN ota_event_associations.organization_id%type,
                                      p_person_id IN per_people_f.person_id%type)
                                      RETURN VARCHAR2;

function learner_has_access_to_course(
   p_person_id in per_people_f.person_id%type,
   p_party_id in hz_parties.party_id%type,
   p_activity_version_id in ota_activity_versions.activity_version_id%type,
   showLPOnlyClasses in varchar2 default 'N') return varchar2;

function is_learner_in_user_group(
   p_person_id in per_people_f.person_id%type,
   p_user_group_id in ota_user_groups_b.user_group_id%type,
   p_business_group_id number,
   p_ignore_ug_date_check varchar2 default 'N') return varchar2;

function is_learner_matches_user_group(
   p_person_id in per_people_f.person_id%type,
   p_user_group_id in ota_user_groups_b.user_group_id%type,
   p_business_group_id number,
   p_ignore_ug_date_check varchar2 default 'N') return boolean;

function build_ug_whereclause(
   p_user_group_id in ota_user_groups_b.user_group_id%type,
   p_business_group_id number) return clob;

function get_ug_whereclause(
   p_user_group_id in ota_user_groups_b.user_group_id%type,
   p_business_group_id number) return clob;

function is_full_access_learner_group(p_user_group_id in ota_user_groups_b.user_group_id%type,
                                      p_business_group_id number) return varchar2;

end ota_learner_access_util;

/
