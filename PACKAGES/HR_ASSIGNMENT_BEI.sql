--------------------------------------------------------
--  DDL for Package HR_ASSIGNMENT_BEI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ASSIGNMENT_BEI" AUTHID CURRENT_USER as 
--Code generated on 30/08/2013 11:36:27
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure set_new_primary_cwk_asg_a (
p_effective_date               date,
p_person_id                    number,
p_assignment_id                number,
p_object_version_number        number,
p_effective_start_date         date,
p_effective_end_date           date);
end hr_assignment_beI;

/
