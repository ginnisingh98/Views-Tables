--------------------------------------------------------
--  DDL for Package HR_ASSIGNMENT_BEO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ASSIGNMENT_BEO" AUTHID CURRENT_USER as 
--Code generated on 30/08/2013 11:36:22
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure update_cwk_asg_criteria_a (
p_effective_date               date,
p_datetrack_update_mode        varchar2,
p_assignment_id                number,
p_object_version_number        number,
p_grade_id                     number,
p_position_id                  number,
p_job_id                       number,
p_location_id                  number,
p_organization_id              number,
p_pay_basis_id                 number,
p_segment1                     varchar2,
p_segment2                     varchar2,
p_segment3                     varchar2,
p_segment4                     varchar2,
p_segment5                     varchar2,
p_segment6                     varchar2,
p_segment7                     varchar2,
p_segment8                     varchar2,
p_segment9                     varchar2,
p_segment10                    varchar2,
p_segment11                    varchar2,
p_segment12                    varchar2,
p_segment13                    varchar2,
p_segment14                    varchar2,
p_segment15                    varchar2,
p_segment16                    varchar2,
p_segment17                    varchar2,
p_segment18                    varchar2,
p_segment19                    varchar2,
p_segment20                    varchar2,
p_segment21                    varchar2,
p_segment22                    varchar2,
p_segment23                    varchar2,
p_segment24                    varchar2,
p_segment25                    varchar2,
p_segment26                    varchar2,
p_segment27                    varchar2,
p_segment28                    varchar2,
p_segment29                    varchar2,
p_segment30                    varchar2,
p_people_group_name            varchar2,
p_effective_start_date         date,
p_effective_end_date           date,
p_people_group_id              number,
p_org_now_no_manager_warning   boolean,
p_other_manager_warning        boolean,
p_spp_delete_warning           boolean,
p_entries_changed_warning      varchar2,
p_tax_district_changed_warning boolean,
p_concat_segments              varchar2);
end hr_assignment_beO;

/
