--------------------------------------------------------
--  DDL for Package HR_BEN_BENEFIT_CONTRIBUTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_BEN_BENEFIT_CONTRIBUTIONS" AUTHID CURRENT_USER AS
/* $Header: pebenpbc.pkh 115.0 99/07/17 18:46:43 porting ship $ */
--
--
-- Change History
-- 27-MAY-94  G.Payton-McDowall  Added exit
-- gpaytonm  03-JUL-93  Added whenever sqlerror... and set verify off
-- gpaytonm  07-MAR-95  Modified hr_ben_ref_chk to cater for stricter Type A
--			benefit rules
-- jthuring  11-OCT-95  Removed spurious start of comment marker
-- ramurthy  15-JAN-96  Added parameter p_validation_end_date to procedure
--			hr_ben_ref_chk.
-- teyres    24-Jun-97  Changed as to is on create or replace line
-- teyres    25-Jun-97  110.1 and 70.7 are the same
--
-- Procedure/Function specifications
--
--
-- Name      hr_ben_chk_duplicate_cont
--
-- Purpose
--
-- Checks that the contribution recor being inserted does already exist or
-- overlap other contribution records
--
-- Arguments
--
-- p_benefit_contribution_id
-- p_element_type_id
-- p_coverage_type
-- p_effective_start_date
-- p_effective_end_date
-- p_business_group_id
--
--
-- Example
--
-- Notes
--
-- The benefit_contribution_id is passed in/out to avoid unecessary network traffic.
-- As this is called from insert/update we bundle, thus copyign the id across the network
-- is not a good idea
--
PROCEDURE hr_ben_chk_duplicate_cont ( p_benefit_contribution_id NUMBER,
                                      p_element_type_id         NUMBER,
                                      p_coverage_type           VARCHAR2,
                                      p_effective_start_date    DATE,
                                      p_effective_end_date      DATE,
                                      p_business_group_id       NUMBER );
--
--
--
-- Name      hr_ben_benefit_contribution_id
--
-- Purpose
--
-- Retrieves surrogate key from the table's sequence
--
-- Arguments
--
-- p_benefit_contribution_id
--
PROCEDURE hr_ben_benefit_contribution_id ( p_benefit_contribution_id IN OUT NUMBER);
--
--
-- Name      hr_ben_bc_delrec
--
-- Purpose   Called from key-delrec to ensure no future contributions exist
--
-- Arguments
--
-- p_business_group_id
-- p_benefit_contribution_id
-- p_effective_end_date
--
PROCEDURE hr_ben_chk_future_conts ( p_business_group_id NUMBER,
                                    p_benefit_contribution_id NUMBER,
                                    p_effective_end_date DATE );
--
--
--
-- Name     hr_ben_ref_chk
--
-- Purpose
--
-- referential integrity change
--
-- Arguments
--
-- p_element_type_id NUMBER
-- p_iv_er_id        NUMBER
-- p_session_date    DATE
-- p_coverage_type   VARCHAR2
-- p_dt_delete_mode  VARCHAR2
-- p_validation_start_date DATE
-- p_validation_end_date DATE
-- p_element_effective_start_date DATE )
--
PROCEDURE hr_ben_ref_chk ( p_element_type_id NUMBER,
			   p_iv_er_id        NUMBER,
                           p_session_date    DATE,
			   p_coverage_type   VARCHAR2,
			   p_dt_delete_mode  VARCHAR2,
			   p_validation_start_date DATE,
			   p_validation_end_date DATE,
			   p_element_effective_start_date DATE );
--
--
--
END hr_ben_benefit_contributions;

 

/
