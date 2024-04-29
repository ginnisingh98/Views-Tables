--------------------------------------------------------
--  DDL for Package HR_ASSIGNMENT_BE6
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ASSIGNMENT_BE6" AUTHID CURRENT_USER as 
--Code generated on 30/08/2013 11:36:17
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure activate_emp_asg_a (
p_effective_date               date,
p_datetrack_update_mode        varchar2,
p_assignment_id                number,
p_change_reason                varchar2,
p_object_version_number        number,
p_assignment_status_type_id    number,
p_effective_start_date         date,
p_effective_end_date           date);
end hr_assignment_be6;

/
