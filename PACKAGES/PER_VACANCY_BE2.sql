--------------------------------------------------------
--  DDL for Package PER_VACANCY_BE2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_VACANCY_BE2" AUTHID CURRENT_USER as 
--Code generated on 18/10/2008 04:43:48
/* $Header: hrapiwfe.pkb 120.3 2006/06/20 10:26:28 sayyampe noship $*/
procedure update_vacancy_a (
p_effective_date               date,
p_vacancy_id                   number,
p_object_version_number        number,
p_date_from                    date,
p_position_id                  number,
p_job_id                       number,
p_grade_id                     number,
p_organization_id              number,
p_people_group_id              number,
p_location_id                  number,
p_recruiter_id                 number,
p_date_to                      date,
p_security_method              varchar2,
p_description                  varchar2,
p_number_of_openings           number,
p_status                       varchar2,
p_budget_measurement_type      varchar2,
p_budget_measurement_value     number,
p_vacancy_category             varchar2,
p_manager_id                   number,
p_primary_posting_id           number,
p_assessment_id                number,
p_attribute_category           varchar2,
p_attribute1                   varchar2,
p_attribute2                   varchar2,
p_attribute3                   varchar2,
p_attribute4                   varchar2,
p_attribute5                   varchar2,
p_attribute6                   varchar2,
p_attribute7                   varchar2,
p_attribute8                   varchar2,
p_attribute9                   varchar2,
p_attribute10                  varchar2,
p_attribute11                  varchar2,
p_attribute12                  varchar2,
p_attribute13                  varchar2,
p_attribute14                  varchar2,
p_attribute15                  varchar2,
p_attribute16                  varchar2,
p_attribute17                  varchar2,
p_attribute18                  varchar2,
p_attribute19                  varchar2,
p_attribute20                  varchar2,
p_attribute21                  varchar2,
p_attribute22                  varchar2,
p_attribute23                  varchar2,
p_attribute24                  varchar2,
p_attribute25                  varchar2,
p_attribute26                  varchar2,
p_attribute27                  varchar2,
p_attribute28                  varchar2,
p_attribute29                  varchar2,
p_attribute30                  varchar2,
p_assignment_changed           boolean,
p_inv_pos_grade_warning        boolean,
p_inv_job_grade_warning        boolean);
end per_vacancy_be2;

 

/
