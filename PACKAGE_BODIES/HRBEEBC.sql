--------------------------------------------------------
--  DDL for Package Body HRBEEBC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRBEEBC" AS
/* $Header: pebenebc.pkb 115.0 99/07/17 18:46:33 porting ship $ */
--
--
-- Procedure/Function Definitions
--
--
-- Name
--
-- Purpose
--
-- This procedure raise an error if the current element
-- is referenced by COBRA
--
-- Arguments
--
-- p_business_group_id
-- p_element_type_id
-- p_coverage_type
--
-- Example
--
-- Notes
--
FUNCTION hr_ben_chk_cobra_reference (p_business_group_id NUMBER,
                                     p_element_type_id   NUMBER,
                                     p_coverage_type     VARCHAR2) RETURN BOOLEAN IS
--
-- declare local variables
--
   l_coverage_exists varchar2(1) := 'N';
--
-- declare cursor for cobra check
--
  CURSOR chk_cobra_ref_exists IS
  SELECT   'Y'
  FROM     per_cobra_coverage_benefits ccb
  WHERE    ccb.business_group_id + 0  = p_business_group_id
  AND      ccb.element_type_id   = p_element_type_id
  AND      ccb.coverage_type      = p_coverage_type
  AND      ccb.accept_reject_flag = 'ACC';
--
BEGIN
--
-- hr_utility.trace_on;
--
  hr_utility.set_location('hr_ben_chk_cobra_reference', 0);
--
--
-- execute cursor
--
  OPEN chk_cobra_ref_exists;
--
  hr_utility.set_location('hr_ben_chk_cobra_reference', 1);
--
  FETCH chk_cobra_ref_exists INTO l_coverage_exists;
--
  hr_utility.set_location('hr_ben_chk_cobra_reference', 2);
--
  CLOSE chk_cobra_ref_exists;
--
  hr_utility.set_location('hr_ben_chk_cobra_reference', 3);
--
--
-- chk to see if element referenced
--
IF(l_coverage_exists = 'Y')
THEN
--
  hr_utility.set_location('hr_ben_chk_cobra_reference', 4);
--
    -- return true if referenced
    RETURN TRUE;
ELSE
--
  hr_utility.set_location('hr_ben_chk_cobra_reference', 5);
--
    -- return false as it is not referenced
    RETURN FALSE;
END IF;
--
END hr_ben_chk_cobra_reference;
--
--
--
-- Name    hr_ben_bc_pre_insert
--
-- Purpose
--
-- This is the pre-insert handler for the form
-- when inserting into PER_BENEFIT_CONTRIBUTIONS
--
-- Arguments
--
-- p_benefit_contribution_id
-- p_element_type_id NUMBER,
-- p_coverage_type VARCHAR,
-- p_effective_start_date DATE,
-- p_effective_end_date DATE,
-- p_business_group_id NUMBER
--
--
PROCEDURE hr_ben_bc_pre_insert (p_benefit_contribution_id IN OUT NUMBER,
                                p_element_type_id NUMBER,
                                p_coverage_type VARCHAR,
                                p_effective_start_date DATE,
                                p_effective_end_date DATE,
                                p_business_group_id NUMBER ) IS
--
--
BEGIN
--
--  Call date track functions
--
--  Call to check for duplicate contributions
--
   hr_ben_benefit_contributions.hr_ben_chk_duplicate_cont
    ( p_benefit_contribution_id,
      p_element_type_id,
      p_coverage_type,
      p_effective_start_date,
      p_effective_end_date,
      p_business_group_id );
--
--  Call procedure to get surrogate key value for
--  per_benefit_contributions
--
   hr_ben_benefit_contributions.hr_ben_benefit_contribution_id ( p_benefit_contribution_id );
--
-- end of procedure/function definitions
--
END hr_ben_bc_pre_insert;
--
--
--
-- Name    hr_ben_bc_pre_update
--
-- Purpose
--
-- This is the pre-update handler for the form
-- when updating BEN_BENEFIT_CONTRIBUTIONS
--
-- Arguments
--
-- p_benefit_contribution_id
-- p_element_type_id NUMBER,
-- p_coverage_type VARCHAR,
-- p_effective_start_date DATE,
-- p_effective_end_date DATE,
-- p_business_group_id NUMBER
--
--
PROCEDURE hr_ben_bc_pre_update (p_benefit_contribution_id IN OUT NUMBER,
                                p_element_type_id NUMBER,
                                p_coverage_type VARCHAR,
                                p_effective_start_date DATE,
                                p_effective_end_date DATE,
                                p_business_group_id NUMBER ) IS
--
--
 local_warning exception;
BEGIN
--
hr_utility.set_location('hr_bc_pre_update', 1);
--
   hr_ben_benefit_contributions.hr_ben_chk_duplicate_cont
    ( p_benefit_contribution_id,
      p_element_type_id,
      p_coverage_type,
      p_effective_start_date,
      p_effective_end_date,
      p_business_group_id );
--
--  Call chk for COBRA reference
--
hr_utility.set_location('hr_bc_pre_update', 2);
--
  IF(hrbeebc.hr_ben_chk_cobra_reference(p_business_group_id,
                                        p_element_type_id,
                                        p_coverage_type))
  THEN
  --
  hr_utility.set_location('hr_bc_pre_update', 3);
  --
  -- raise warning
  hr_utility.set_message(801, 'HR_BEN_COBRA_REFERENCE');
  raise local_warning;
  --
  END IF;
--
hr_utility.set_location('hr_bc_pre_update', 4);
--
exception
  when local_warning then
    hr_utility.set_warning;
--
hr_utility.set_location('hr_bc_pre_update', 5);
--
END hr_ben_bc_pre_update;
--
--
--
-- Name    hr_ben_bc_pre_delete
--
-- Purpose
--
-- This is the pre-delete handler for the form
-- when deleting into BEN_BENEFIT_CONTRIBUTIONS
--
-- Arguments
--
PROCEDURE hr_ben_bc_pre_delete (p_business_group_id NUMBER,
                                p_benefit_contribution_id NUMBER,
                                p_element_type_id NUMBER,
				p_iv_er_id NUMBER,
                                p_coverage_type VARCHAR2,
                                p_effective_end_date DATE,
                                p_session_date DATE,
				p_dt_delete_mode VARCHAR2,
				p_validation_start_date DATE,
				p_validation_end_date DATE,
				p_element_effective_start_date DATE) IS
BEGIN
--
--  hr_utility.trace_on;
--
-- Call referential integrity checks
--
  hr_utility.set_location('hr_ben_bc_pre_delete', 0);
--
hr_ben_benefit_contributions.hr_ben_ref_chk
 ( p_element_type_id,
   p_iv_er_id,
   p_session_date,
   p_coverage_type,
   p_dt_delete_mode,
   p_validation_start_date,
   p_validation_end_date,
   p_element_effective_start_date);
--
  hr_utility.set_location('hr_ben_bc_pre_delete', 2);
--
-- end of procedure/function definitions
--
END hr_ben_bc_pre_delete;
--
--
--
-- Name        hr_ben_get_coverage
--
-- Purpose
--
-- Retrieves the meaning of the coverage type
--
-- Arguments
--
-- p_coverage_type
--
-- Notes
--
-- Called from post-change of coverage_type
--
--
FUNCTION hr_ben_get_coverage ( p_coverage_type IN VARCHAR2 ) RETURN VARCHAR2 IS
--
-- declare local variables
--
   l_coverage_type_meaning VARCHAR2(80);
--
   CURSOR coverage_type_meaning IS
   SELECT l.meaning
   FROM   hr_lookups l
   WHERE  l.lookup_type = 'US_BENEFIT_COVERAGE'
   AND    l.lookup_code = p_coverage_type;
--
BEGIN
--
-- execute cursor
OPEN coverage_type_meaning;
FETCH coverage_type_meaning INTO l_coverage_type_meaning;
CLOSE coverage_type_meaning;
--
   RETURN l_coverage_type_meaning;
--
END hr_ben_get_coverage;
--
--
--
END hrbeebc;

/
