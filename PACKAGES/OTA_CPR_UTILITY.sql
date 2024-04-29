--------------------------------------------------------
--  DDL for Package OTA_CPR_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_CPR_UTILITY" AUTHID CURRENT_USER as
/* $Header: otcprutl.pkh 120.5 2005/08/29 05:04 sbhullar noship $ */

-- Author: sbhullar
-- ----------------------------------------------------------------
-- ------------------< is_competency_acheived >--------------------
-- ----------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   This function will be used to find whether a particular person
-- has acheived the specfied competency at specified level or not
--
-- IN
-- p_person_id
-- p_comp_id
-- p_level_id
--
-- Post Failure:
-- None.
-- Access Status
--  Public
-- {End of Comments}
------------------------------------------------------------------
FUNCTION is_competency_acheived
  (p_person_id in per_all_people_f.person_id%type,
   p_comp_id in per_competence_elements.competence_id%type,
   p_level_id in per_competence_elements.proficiency_level_id%type
) RETURN varchar2;

FUNCTION check_learner_comp_step_values
  (p_act_ver_id in ota_activity_versions.activity_version_id%type,
   p_comp_id in per_competence_elements.competence_id%type,
   p_level_id in per_competence_elements.proficiency_level_id%type
) RETURN varchar2;

FUNCTION is_course_completed
	(p_person_id in per_all_people_f.person_id%type,
	 p_delegate_contact_id in NUMBER,
	 p_user_id in NUMBER,
	 p_user_type in ota_attempts.user_type%type,
	 p_act_ver_id in ota_activity_versions.activity_version_id%type
) RETURN varchar2;

FUNCTION is_mandatory_prereqs_completed
	(p_person_id in per_all_people_f.person_id%type,
	 p_delegate_contact_id in NUMBER,
	 p_user_id in NUMBER,
	 p_user_type in ota_attempts.user_type%type,
	 p_act_ver_id in ota_activity_versions.activity_version_id%type
) RETURN varchar2;

FUNCTION is_advisory_prereqs_completed
	(p_person_id in per_all_people_f.person_id%type,
	 p_delegate_contact_id in NUMBER,
	 p_user_id in NUMBER,
	 p_user_type in ota_attempts.user_type%type,
	 p_act_ver_id in ota_activity_versions.activity_version_id%type
) RETURN varchar2;

FUNCTION get_enroll_image
	(p_person_id in per_all_people_f.person_id%type,
	 p_delegate_contact_id in NUMBER,
	 p_user_id in NUMBER,
	 p_user_type in ota_attempts.user_type%type,
	 p_event_id in ota_events.event_id%type
) RETURN varchar2;

Procedure chk_mandatory_prereqs
         (p_person_id ota_delegate_bookings.delegate_person_id%TYPE,
	  p_delegate_contact_id ota_delegate_bookings.delegate_contact_id%TYPE,
	  p_event_id ota_events.event_id%TYPE
  );

FUNCTION is_mand_crs_prereqs_completed
	(p_person_id in per_all_people_f.person_id%type,
	 p_delegate_contact_id in NUMBER,
	 p_user_id in NUMBER,
	 p_user_type in ota_attempts.user_type%type,
	 p_act_ver_id in ota_activity_versions.activity_version_id%type
) RETURN varchar2;

FUNCTION is_mand_comp_prereqs_completed
	(p_person_id in per_all_people_f.person_id%type,
	 p_act_ver_id in ota_activity_versions.activity_version_id%type
) RETURN varchar2;


FUNCTION get_prereq_met_count
	(p_event_id in ota_events.event_id%type,
	 p_prerequisite_course_id ota_activity_versions.activity_version_id%type,
     p_comp_id in per_competence_elements.competence_id%type,
     p_level_id in per_competence_elements.proficiency_level_id%type
) RETURN varchar2;

FUNCTION get_prereq_not_met_count
	(p_event_id in ota_events.event_id%type,
	 p_prerequisite_course_id ota_activity_versions.activity_version_id%type,
     p_comp_id in per_competence_elements.competence_id%type,
     p_level_id in per_competence_elements.proficiency_level_id%type
) RETURN varchar2;

FUNCTION is_mand_comp_prereqs_comp_evt
	(p_person_id in per_all_people_f.person_id%type,
	 p_event_id in ota_events.event_id%type
) RETURN varchar2;

FUNCTION is_mand_crs_prereqs_comp_evt
	(p_person_id in per_all_people_f.person_id%type
    ,p_delegate_contact_id in ota_delegate_bookings.delegate_contact_id%TYPE
    ,p_user_id in number
    ,p_user_type in varchar2
	,p_event_id in ota_events.event_id%type
) RETURN varchar2;

FUNCTION is_mandatory_prereqs_comp_evt
	(p_person_id in per_all_people_f.person_id%type
    ,p_delegate_contact_id in ota_delegate_bookings.delegate_contact_id%TYPE default NULL
    ,p_user_id in number default NULL
    ,p_user_type in varchar2 default 'E'
   , p_event_id in ota_events.event_id%type
) RETURN varchar2;

-- ----------------------------------------------------------------------------
-- |-------------------------< is_valid_classes_available >--------------------|
-- ----------------------------------------------------------------------------
--  PUBLIC
-- Description:
--   Validates whether prerequisite course contains valid classes or not.
--   Course should have associated offering and valid classes. Valid classes
--   include classes  whose class type is SCHEDULED or SELFPACED and whose
--   class status is not Cancelled and which are not expired
--
FUNCTION is_valid_classes_available
  (p_prerequisite_course_id in number
  ) RETURN varchar2;

end ota_cpr_utility;

 

/
