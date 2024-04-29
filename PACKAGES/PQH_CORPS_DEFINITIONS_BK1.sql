--------------------------------------------------------
--  DDL for Package PQH_CORPS_DEFINITIONS_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_CORPS_DEFINITIONS_BK1" AUTHID CURRENT_USER as
/* $Header: pqcpdapi.pkh 120.1 2005/10/02 02:26:32 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_corps_definition_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_corps_definition_b
  (
  p_effective_date               in    date
  ,p_business_group_id            in    number
  ,p_name                         in    varchar2
  ,p_status_cd                    in    varchar2
  ,p_retirement_age               in    number
  ,p_category_cd                  in    varchar2
  ,p_corps_type_cd                in    varchar2
  ,p_date_from         in    date
  ,p_date_to           in    date
  ,p_recruitment_end_date         in    date
  ,p_starting_grade_step_id       in    number
  ,p_type_of_ps               in    varchar2
  ,p_task_desc                    in    varchar2
  ,p_secondment_threshold         in    number
  ,p_normal_hours                 in    number
  ,p_normal_hours_frequency       in    varchar2
  ,p_minimum_hours                in    number
  ,p_minimum_hours_frequency      in    varchar2
  ,p_attribute1                   in    varchar2
  ,p_attribute2                   in    varchar2
  ,p_attribute3                   in    varchar2
  ,p_attribute4                   in    varchar2
  ,p_attribute5                   in    varchar2
  ,p_attribute6                   in    varchar2
  ,p_attribute7                   in    varchar2
  ,p_attribute8                   in    varchar2
  ,p_attribute9                   in    varchar2
  ,p_attribute10                  in    varchar2
  ,p_attribute11                  in    varchar2
  ,p_attribute12                  in    varchar2
  ,p_attribute13                  in    varchar2
  ,p_attribute14                  in    varchar2
  ,p_attribute15                  in    varchar2
  ,p_attribute16                  in    varchar2
  ,p_attribute17                  in    varchar2
  ,p_attribute18                  in    varchar2
  ,p_attribute19                  in    varchar2
  ,p_attribute20                  in    varchar2
  ,p_attribute21                  in    varchar2
  ,p_attribute22                  in    varchar2
  ,p_attribute23                  in    varchar2
  ,p_attribute24                  in    varchar2
  ,p_attribute25                  in    varchar2
  ,p_attribute26                  in    varchar2
  ,p_attribute27                  in    varchar2
  ,p_attribute28                  in    varchar2
  ,p_attribute29                  in    varchar2
  ,p_attribute30                  in    varchar2
  ,p_attribute_category           in    varchar2
  ,p_primary_prof_field_id          in number
  ,p_starting_grade_id              in number
  ,p_ben_pgm_id                     in number
  ,p_probation_period               in number
  ,p_probation_units                in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_corps_definition_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_corps_definition_a
  (
  p_effective_date               in    date
  ,p_business_group_id            in    number
  ,p_name                         in    varchar2
  ,p_status_cd                    in    varchar2
  ,p_retirement_age               in    number
  ,p_category_cd                  in    varchar2
  ,p_corps_type_cd                in    varchar2
  ,p_date_from         in    date
  ,p_date_to           in    date
  ,p_recruitment_end_date         in    date
  ,p_starting_grade_step_id       in    number
  ,p_type_of_ps               in    varchar2
  ,p_task_desc                    in    varchar2
  ,p_secondment_threshold         in    number
  ,p_normal_hours                 in    number
  ,p_normal_hours_frequency       in    varchar2
  ,p_minimum_hours                in    number
  ,p_minimum_hours_frequency      in    varchar2
  ,p_attribute1                   in    varchar2
  ,p_attribute2                   in    varchar2
  ,p_attribute3                   in    varchar2
  ,p_attribute4                   in    varchar2
  ,p_attribute5                   in    varchar2
  ,p_attribute6                   in    varchar2
  ,p_attribute7                   in    varchar2
  ,p_attribute8                   in    varchar2
  ,p_attribute9                   in    varchar2
  ,p_attribute10                  in    varchar2
  ,p_attribute11                  in    varchar2
  ,p_attribute12                  in    varchar2
  ,p_attribute13                  in    varchar2
  ,p_attribute14                  in    varchar2
  ,p_attribute15                  in    varchar2
  ,p_attribute16                  in    varchar2
  ,p_attribute17                  in    varchar2
  ,p_attribute18                  in    varchar2
  ,p_attribute19                  in    varchar2
  ,p_attribute20                  in    varchar2
  ,p_attribute21                  in    varchar2
  ,p_attribute22                  in    varchar2
  ,p_attribute23                  in    varchar2
  ,p_attribute24                  in    varchar2
  ,p_attribute25                  in    varchar2
  ,p_attribute26                  in    varchar2
  ,p_attribute27                  in    varchar2
  ,p_attribute28                  in    varchar2
  ,p_attribute29                  in    varchar2
  ,p_attribute30                  in    varchar2
  ,p_attribute_category           in    varchar2
  ,p_primary_prof_field_id          in number
  ,p_starting_grade_id              in number
  ,p_ben_pgm_id                     in number
  ,p_probation_period               in number
  ,p_probation_units                in varchar2
  );
--
end pqh_corps_definitions_bk1;

 

/
