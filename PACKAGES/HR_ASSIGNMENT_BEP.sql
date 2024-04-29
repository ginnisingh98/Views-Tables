--------------------------------------------------------
--  DDL for Package HR_ASSIGNMENT_BEP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ASSIGNMENT_BEP" AUTHID CURRENT_USER as 
--Code generated on 30/08/2013 11:36:28
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure delete_assignment_a (
p_effective_date               date,
p_assignment_id                number,
p_datetrack_mode               varchar2,
p_loc_change_tax_issues        boolean,
p_delete_asg_budgets           boolean,
p_org_now_no_manager_warning   boolean,
p_element_salary_warning       boolean,
p_element_entries_warning      boolean,
p_spp_warning                  boolean,
p_cost_warning                 boolean,
p_life_events_exists           boolean,
p_cobra_coverage_elements      boolean,
p_assgt_term_elements          boolean);
end hr_assignment_beP;

/
