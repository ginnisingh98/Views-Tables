--------------------------------------------------------
--  DDL for Package HR_MAINTAIN_PROPOSAL_BK4
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_MAINTAIN_PROPOSAL_BK4" AUTHID CURRENT_USER as
/* $Header: hrpypapi.pkh 120.11.12010000.3 2008/12/05 14:33:06 vkodedal ship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------< delete_salary_proposal_b >-------------------------|
-- ----------------------------------------------------------------------------
--
Procedure delete_salary_proposal_b
  (
   p_pay_proposal_id        in number
  ,p_business_group_id     in number
  ,p_object_version_number in number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------< delete_salary_proposal_a >-------------------------|
-- ----------------------------------------------------------------------------

Procedure delete_salary_proposal_a
  (p_pay_proposal_id       in number
  ,p_business_group_id     in number
  ,p_object_version_number in number
  ,p_salary_warning        in boolean
  );
--
end hr_maintain_proposal_bk4;

/
