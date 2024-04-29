--------------------------------------------------------
--  DDL for Package HR_ASSIGNMENT_BEK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ASSIGNMENT_BEK" AUTHID CURRENT_USER as 
--Code generated on 30/08/2013 11:36:27
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure actual_termination_cwk_asg_a (
p_assignment_id                number,
p_object_version_number        number,
p_actual_termination_date      date,
p_assignment_status_type_id    number,
p_effective_start_date         date,
p_effective_end_date           date,
p_asg_future_changes_warning   boolean,
p_entries_changed_warning      varchar2,
p_pay_proposal_warning         boolean,
p_business_group_id            number);
end hr_assignment_beK;

/
