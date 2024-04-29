--------------------------------------------------------
--  DDL for Package HR_ASSIGNMENT_BEH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ASSIGNMENT_BEH" AUTHID CURRENT_USER as 
--Code generated on 30/08/2013 11:36:27
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure final_process_cwk_asg_a (
p_assignment_id                number,
p_object_version_number        number,
p_final_process_date           date,
p_effective_start_date         date,
p_effective_end_date           date,
p_org_now_no_manager_warning   boolean,
p_asg_future_changes_warning   boolean,
p_entries_changed_warning      varchar2);
end hr_assignment_beH;

/
