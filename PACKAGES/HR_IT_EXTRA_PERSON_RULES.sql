--------------------------------------------------------
--  DDL for Package HR_IT_EXTRA_PERSON_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_IT_EXTRA_PERSON_RULES" AUTHID CURRENT_USER AS
  /* $Header: peitexpr.pkh 120.0 2005/05/31 10:27:55 appldev noship $ */
  --
  --
  -- Uses Tobacco:
  --
  -- This cannot be entered.
  --
  -- Employee Reference No (per_information2):
  --
  -- Must be unique.
  --
  -- Note: ONLY supports real values.
  --
  procedure extra_create_person_checks
  (p_per_information2  IN VARCHAR2
  ,p_uses_tobacco_flag IN VARCHAR2
  ,p_business_group_id IN NUMBER);
  --
  -- Uses Tobacco:
  --
  -- This cannot be entered.
  --
  -- Employee Reference No (per_information2):
  --
  -- Must be unique.
  --
  -- Note: Supports both real and API system values (these are passed when the value has not
  --       been changed.
  --
  PROCEDURE extra_update_person_checks
  (p_person_id         IN NUMBER
  ,p_per_information2  IN VARCHAR2
  ,p_uses_tobacco_flag IN VARCHAR2);
  --
  --
  -- Collective Agreement Grades:
  --
  -- If the user is using a collective agreement grade then it must be within the
  -- predefined structure of IT_CAGR: Grade - Level - Description. This requires that
  -- the structure is associated with the collective agreement and the collective
  -- agreement is defined within the business group to which the assignment belongs.
  --
  -- The grade structure must be built from the first segment down i.e. cannot have a null
  -- value followed by an actual value e.g. cannot have a value for level if there is no
  -- grade.
  --
  -- If dynamic inserts is not enabled for the IT_CAGR structure then the combination
  -- must already exist.
  --
  -- Unemployment Insurance Code (p_segment2):
  --
  -- This is mandatory.
  --
  -- Note: ONLY supports real values.
  --
  PROCEDURE extra_create_assignment_checks
  (p_collective_agreement_id IN NUMBER
  ,p_cagr_id_flex_num        IN NUMBER
  ,p_organization_id	     IN NUMBER
  ,p_cag_segment1            IN VARCHAR2
  ,p_cag_segment2            IN VARCHAR2
  ,p_cag_segment3            IN VARCHAR2
  ,p_scl_segment2            IN VARCHAR2);
  --
  --
  -- Collective Agreement Grades:
  --
  -- If the user is using a collective agreement grade then it must be within the
  -- predefined structure of IT_CAGR: Grade - Level - Description. This requires that
  -- the structure is associated with the collective agreement and the collective
  -- agreement is defined within the business group to which the assignment belongs.
  --
  -- The grade structure must be built from the first segment down i.e. cannot have a null
  -- value followed by an actual value e.g. cannot have a value for level if there is no
  -- grade.
  --
  -- If dynamic inserts is not enabled for the IT_CAGR structure then the combination
  -- must already exist.
  --
  -- Unemployment Insurance Code (p_segment2):
  --
  -- This is mandatory.
  --
  -- Note: Supports both real and API system values (these are passed when the value has not
  --       been changed.
  --
  PROCEDURE extra_update_assignment_checks
  (p_collective_agreement_id IN NUMBER
  ,p_cagr_id_flex_num        IN NUMBER
  ,p_assignment_id	     IN NUMBER
  ,p_object_version_number   IN NUMBER
  ,p_effective_date          IN DATE
  ,p_cag_segment1            IN VARCHAR2
  ,p_cag_segment2            IN VARCHAR2
  ,p_cag_segment3            IN VARCHAR2
  ,p_segment2                IN VARCHAR2);
END hr_it_extra_person_rules;

 

/
