--------------------------------------------------------
--  DDL for Package PER_COMPETENCE_DATA_PUMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_COMPETENCE_DATA_PUMP" AUTHID CURRENT_USER AS
/* $Header: pecompdp.pkh 115.3 2004/03/18 10:15:23 ynegoro noship $ */
-- -------------------------------------------------------------------------
-- --------------------< get_rsc_old_id >------------------------------
-- -------------------------------------------------------------------------
-- DESCRIPTION
--   This function returns the
--
FUNCTION get_rsc_old_id
  (p_data_pump_always_call IN varchar2
  ,p_old_rating_scale_name  IN VARCHAR2
  ,p_business_group_id  IN NUMBER)
RETURN BINARY_INTEGER;
PRAGMA RESTRICT_REFERENCES (get_rsc_old_id , WNDS);
-- -------------------------------------------------------------------------
-- -------------------------------------------------------------------------
-- --------------------< get_rating_scale_id >------------------------------
-- -------------------------------------------------------------------------
-- DESCRIPTION
--   This function returns the
--
FUNCTION get_rating_scale_id
  (p_data_pump_always_call IN varchar2
  ,p_rating_scale_name  IN VARCHAR2
  ,p_business_group_id  IN NUMBER)
RETURN BINARY_INTEGER;
PRAGMA RESTRICT_REFERENCES (get_rating_scale_id , WNDS);
-- -------------------------------------------------------------------------
-- --------------------< get_rsc_ovn >---------------------------
-- -------------------------------------------------------------------------
-- DESCRIPTION
--   This function returns the  ovn for rating scale
--
FUNCTION get_rsc_ovn
  (p_data_pump_always_call IN varchar2
  ,p_old_rating_scale_name  IN VARCHAR2
  ,p_business_group_id  IN NUMBER)
RETURN BINARY_INTEGER;
PRAGMA RESTRICT_REFERENCES (get_rsc_ovn , WNDS);
-- -------------------------------------------------------------------------
-- --------------------< get_cpn_ovn >--------------------------------
-- -------------------------------------------------------------------------
-- DESCRIPTION
--   This function returns the
--
FUNCTION get_cpn_ovn
  (p_data_pump_always_call IN varchar2
  ,p_competence_name    IN VARCHAR2
  ,p_business_group_id     IN NUMBER)
RETURN BINARY_INTEGER;
PRAGMA RESTRICT_REFERENCES (get_cpn_ovn , WNDS);
-- -------------------------------------------------------------------------
-- --------------------< get_competence_id >--------------------------------
-- -------------------------------------------------------------------------
-- DESCRIPTION
--   This function returns the
--
FUNCTION get_competence_id
  (p_data_pump_always_call IN varchar2
  ,p_competence_name    IN VARCHAR2
  ,p_business_group_id     IN NUMBER)
RETURN BINARY_INTEGER;
PRAGMA RESTRICT_REFERENCES (get_competence_id , WNDS);
-- -------------------------------------------------------------------------
-- ------------< get_parent_comp_element_id >-------------------------
-- -------------------------------------------------------------------------
-- DESCRIPTION
--   This function returns the
--
FUNCTION get_parent_comp_element_id
RETURN BINARY_INTEGER;
PRAGMA RESTRICT_REFERENCES (get_parent_comp_element_id , WNDS);
-- -------------------------------------------------------------------------
-- --------------------< get_enterprise_id >--------------------------------
-- -------------------------------------------------------------------------
-- DESCRIPTION
--   This function returns the
--
FUNCTION get_enterprise_id
RETURN BINARY_INTEGER;
PRAGMA RESTRICT_REFERENCES (get_enterprise_id , WNDS);
--
-- -------------------------------------------------------------------------
-- --------------------< get_proficiency_level_id >-------------------------
-- -------------------------------------------------------------------------
-- DESCRIPTION
--   This function returns the
--
FUNCTION get_proficiency_level_id
RETURN BINARY_INTEGER;
PRAGMA RESTRICT_REFERENCES (get_proficiency_level_id , WNDS);
-- -------------------------------------------------------------------------
-- --------------------< get_position_id >----------------------------------
-- -------------------------------------------------------------------------
-- DESCRIPTION
--   This function returns the
--
FUNCTION get_position_id
RETURN BINARY_INTEGER;
PRAGMA RESTRICT_REFERENCES (get_position_id , WNDS);
-- -------------------------------------------------------------------------
-- --------------------< get_activity_version_id >--------------------------
-- -------------------------------------------------------------------------
-- DESCRIPTION
--   This function returns the
--
FUNCTION get_activity_version_id
RETURN BINARY_INTEGER;
PRAGMA RESTRICT_REFERENCES (get_activity_version_id , WNDS);
-- -------------------------------------------------------------------------
-- --------------------< get_person_id >------------------------------------
-- -------------------------------------------------------------------------
-- DESCRIPTION
--   This function returns the
--
FUNCTION get_person_id
RETURN BINARY_INTEGER;
PRAGMA RESTRICT_REFERENCES (get_person_id , WNDS);
-- -------------------------------------------------------------------------
-- --------------------< get_high_proficiency_level_id >--------------------
-- -------------------------------------------------------------------------
-- DESCRIPTION
--   This function returns the
--
FUNCTION get_high_proficiency_level_id
RETURN BINARY_INTEGER;
PRAGMA RESTRICT_REFERENCES (get_high_proficiency_level_id , WNDS);
-- -------------------------------------------------------------------------
-- --------------------< get_assessment_id >--------------------------------
-- -------------------------------------------------------------------------
-- DESCRIPTION
--   This function returns the
--
FUNCTION get_assessment_id
RETURN BINARY_INTEGER;
PRAGMA RESTRICT_REFERENCES (get_assessment_id , WNDS);
-- -------------------------------------------------------------------------
-- --------------------< get_assessment_type_id >---------------------------
-- -------------------------------------------------------------------------
-- DESCRIPTION
--   This function returns the
--
FUNCTION get_assessment_type_id
RETURN BINARY_INTEGER;
PRAGMA RESTRICT_REFERENCES (get_assessment_type_id , WNDS);
-- -------------------------------------------------------------------------
-- --------------------< get_weighting_level_id >---------------------------
-- -------------------------------------------------------------------------
-- DESCRIPTION
--   This function returns the
--
FUNCTION get_weighting_level_id
RETURN BINARY_INTEGER;
PRAGMA RESTRICT_REFERENCES (get_weighting_level_id , WNDS);
-- -------------------------------------------------------------------------
-- --------------------< get_rating_level_id >---------------------------
-- -------------------------------------------------------------------------
-- DESCRIPTION
--   This function returns the
--
FUNCTION get_rating_level_id
  (p_data_pump_always_call IN varchar2
  ,p_rating_scale_name     IN VARCHAR2
  ,p_competence_name       IN VARCHAR2
  ,p_rating_level_name IN VARCHAR2
  ,p_business_group_id     IN NUMBER)
RETURN BINARY_INTEGER;
PRAGMA RESTRICT_REFERENCES (get_rating_level_id , WNDS);
-- -------------------------------------------------------------------------
-- --------------------< get_rtl_old_if >---------------------------
-- -------------------------------------------------------------------------
-- DESCRIPTION
--   This function returns the
--
FUNCTION get_rtl_ovn
  (p_data_pump_always_call IN varchar2
  ,p_rating_scale_name     IN VARCHAR2
  ,p_competence_name       IN VARCHAR2
  ,p_old_rating_level_name IN VARCHAR2
  ,p_business_group_id     IN NUMBER)
RETURN BINARY_INTEGER;
PRAGMA RESTRICT_REFERENCES (get_rtl_ovn , WNDS);
-- -------------------------------------------------------------------------
-- --------------------< get_rtl_old_if >---------------------------
-- -------------------------------------------------------------------------
-- DESCRIPTION
--   This function returns the
--
FUNCTION get_rtl_old_id
  (p_data_pump_always_call IN varchar2
  ,p_rating_scale_name     IN VARCHAR2
  ,p_competence_name       IN VARCHAR2
  ,p_old_rating_level_name IN VARCHAR2
  ,p_business_group_id     IN NUMBER)
RETURN BINARY_INTEGER;
PRAGMA RESTRICT_REFERENCES (get_rtl_old_id , WNDS);
-- -------------------------------------------------------------------------
-- --------------------< get_valid_grade_id >-------------------------------
-- -------------------------------------------------------------------------
-- DESCRIPTION
--   This function returns the
--
FUNCTION get_valid_grade_id
RETURN BINARY_INTEGER;
PRAGMA RESTRICT_REFERENCES (get_valid_grade_id , WNDS);
-- -------------------------------------------------------------------------
-- --------------------< get_object_id >-------------------------------
-- -------------------------------------------------------------------------
-- DESCRIPTION
--   This function returns the
--
FUNCTION get_object_id
RETURN BINARY_INTEGER;
PRAGMA RESTRICT_REFERENCES (get_object_id , WNDS);
-- -------------------------------------------------------------------------
-- ----------------< get_qualification_type_id >-------------------------
-- -------------------------------------------------------------------------
-- DESCRIPTION
--   This function returns the
--
FUNCTION get_qualification_type_id
  (p_data_pump_always_call      IN varchar2
  ,p_qualification_type_name    IN VARCHAR2
  )
RETURN BINARY_INTEGER;
PRAGMA RESTRICT_REFERENCES (get_qualification_type_id , WNDS);
--
END PER_COMPETENCE_DATA_PUMP ;

 

/
