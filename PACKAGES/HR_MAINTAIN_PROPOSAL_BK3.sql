--------------------------------------------------------
--  DDL for Package HR_MAINTAIN_PROPOSAL_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_MAINTAIN_PROPOSAL_BK3" AUTHID CURRENT_USER as
/* $Header: hrpypapi.pkh 120.11.12010000.3 2008/12/05 14:33:06 vkodedal ship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------< approve_salary_proposal_b >-------------------------|
-- ----------------------------------------------------------------------------
Procedure approve_salary_proposal_b
  (
  p_pay_proposal_id              in number,
  p_change_date                  in date,
  p_proposed_salary_n            in number,
  p_object_version_number        in number
  );

-- ----------------------------------------------------------------------------
-- |--------------------< approve_salary_proposal_a >-------------------------|
-- ----------------------------------------------------------------------------

Procedure approve_salary_proposal_a
  (
  p_pay_proposal_id              in number,
  p_change_date                  in date,
  p_proposed_salary_n            in number,
  p_object_version_number        in number,
  p_inv_next_sal_date_warning    in boolean,
  p_proposed_salary_warning	 in boolean,
  p_approved_warning	         in boolean,
  p_payroll_warning              in boolean,
  p_error_text                   in varchar2
  );
--
end hr_maintain_proposal_bk3;
--

/
