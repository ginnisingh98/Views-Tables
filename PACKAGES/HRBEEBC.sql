--------------------------------------------------------
--  DDL for Package HRBEEBC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRBEEBC" AUTHID CURRENT_USER AS
/* $Header: pebenebc.pkh 115.0 99/07/17 18:46:37 porting ship $ */
--
--
-- Procedure/Function specifications
--
--
--
-- Name    hr_ben_chk_cobra_reference
--
-- Purpose
--
-- This is the pre-insert handler for the form
-- when inserting into PER_BENEFIT_CONTRIBUTIONS
--
-- Arguments
--
-- p_business_group_id
-- p_element_type_id
-- p_coverage_type
--
FUNCTION hr_ben_chk_cobra_reference (p_business_group_id NUMBER,
                                     p_element_type_id   NUMBER,
                                     p_coverage_type     VARCHAR2) RETURN BOOLEAN;
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
                                p_business_group_id NUMBER );
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
				p_element_effective_start_date DATE);
--
--
--
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
                                p_business_group_id NUMBER );
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
FUNCTION hr_ben_get_coverage ( p_coverage_type IN VARCHAR2 ) RETURN VARCHAR2;
--
--
--
END hrbeebc;

 

/
