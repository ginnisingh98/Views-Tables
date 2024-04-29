--------------------------------------------------------
--  DDL for Package HR_ASSIGNMENT_BKP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ASSIGNMENT_BKP" AUTHID CURRENT_USER as
/* $Header: peasgapi.pkh 120.11.12010000.4 2009/07/28 10:08:56 ghshanka ship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_assignment_b >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_assignment_b
      (p_effective_date               IN     DATE
      ,p_assignment_id                IN     number
      ,p_datetrack_mode               IN     VARCHAR2
      );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_assignment_a >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_assignment_a
      (p_effective_date               IN     DATE
      ,p_assignment_id                IN     number
      ,p_datetrack_mode               IN     VARCHAR2
      ,p_loc_change_tax_issues        IN     boolean
      ,p_delete_asg_budgets           IN     boolean
      ,p_org_now_no_manager_warning   IN     boolean
      ,p_element_salary_warning       IN     boolean
      ,p_element_entries_warning      IN     boolean
      ,p_spp_warning                  IN     boolean
      ,P_cost_warning                 IN     Boolean
      ,p_life_events_exists   	      IN     Boolean
      ,p_cobra_coverage_elements      IN     Boolean
      ,p_assgt_term_elements          IN     Boolean
      );
--
end hr_assignment_bkp;

/
