--------------------------------------------------------
--  DDL for Package HR_CONTINGENT_WORKER_BE2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_CONTINGENT_WORKER_BE2" AUTHID CURRENT_USER as 
--Code generated on 29/08/2013 10:00:55
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure convert_to_cwk_a (
p_effective_date               date,
p_person_id                    number,
p_object_version_number        number,
p_npw_number                   varchar2,
p_projected_placement_end      date,
p_person_type_id               number,
p_datetrack_update_mode        varchar2,
p_per_effective_start_date     date,
p_per_effective_end_date       date,
p_pdp_object_version_number    number,
p_assignment_id                number,
p_asg_object_version_number    number,
p_assignment_sequence          number);
end hr_contingent_worker_be2;

/
