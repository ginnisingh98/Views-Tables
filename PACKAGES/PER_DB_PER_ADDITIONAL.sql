--------------------------------------------------------
--  DDL for Package PER_DB_PER_ADDITIONAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_DB_PER_ADDITIONAL" AUTHID CURRENT_USER AS
/* $Header: peadditn.pkh 115.6 2002/08/13 17:11:21 vbanner ship $ */
--
--
FUNCTION create_applicant
(p_effective_start_date           DATE      default null
,p_effective_end_date             DATE      default null
,p_business_group                 VARCHAR2
,p_last_name                      VARCHAR2
,p_applicant_number               VARCHAR2  default null
,p_organization                   VARCHAR2  default null
,p_position                       VARCHAR2  default null
,p_job                            VARCHAR2  default null
,p_grade                          VARCHAR2  default null
,p_location                       VARCHAR2  default null
,p_vacancy                        VARCHAR2  default null
,p_people_group_id                NUMBER    default null
,p_start_date                     DATE      default null
,p_date_of_birth                  DATE      default null
,p_first_name                     VARCHAR2  default null
,p_known_as                       VARCHAR2  default null
,p_marital_status                 VARCHAR2  default 'S'
,p_middle_names                   VARCHAR2  default null
,p_nationality                    VARCHAR2  default null
,p_previous_last_name             VARCHAR2  default null
,p_registered_disabled_flag       VARCHAR2  default 'N'
,p_sex                            VARCHAR2  default 'M'
,p_title                          VARCHAR2  default 'MR.'
,p_work_telephone                 VARCHAR2  default null
,p_frequency                      VARCHAR2  default 'W'
,p_normal_hours                   VARCHAR2  default '37.5'
,p_current_employer               VARCHAR2  default null
,p_projected_hire_date            DATE      default null
,p_recruitment_activity_id        NUMBER    default null
,p_person_referred_by_id          NUMBER    default null
,p_source_organization_id         NUMBER    default null
,p_time_normal_start              VARCHAR2  default '08:00'
,p_time_normal_finish             VARCHAR2  default '17:30'
,p_probation_period               VARCHAR2  default null
,p_probation_unit                 VARCHAR2  default null
,p_recruiter_id                   NUMBER    default null
,p_internal_address_line          VARCHAR2  default null
,p_change_reason                  VARCHAR2  default null)
return NUMBER ;
--
--
FUNCTION create_employee
(p_effective_start_date           DATE      default null
,p_effective_end_date             DATE      default null
,p_business_group                 VARCHAR2
,p_last_name                      VARCHAR2
,p_national_identifier            VARCHAR2
,p_employee_number                VARCHAR2  default null
,p_tax_code                       VARCHAR2  default '50T'
,p_tax_basis                      VARCHAR2  default 'C'  -- cumulative
,p_organization                   VARCHAR2  default null
,p_position                       VARCHAR2  default null
,p_job                            VARCHAR2  default null
,p_grade                          VARCHAR2  default null
,p_payroll                        VARCHAR2  default null
,p_location                       VARCHAR2  default null
,p_people_group_id                NUMBER    default null
,p_cost_allocation_keyflex_id     NUMBER    default null
,p_start_date                     DATE      default null
,p_date_of_birth                  DATE      default null
,p_employee_data_verified         DATE      default null
,p_expense_chk_send_to_address    VARCHAR2  default 'H'
,p_first_name                     VARCHAR2  default null
,p_known_as                       VARCHAR2  default null
,p_marital_status                 VARCHAR2  default 'S'
,p_middle_names                   VARCHAR2  default null
,p_nationality                    VARCHAR2  default null
,p_previous_last_name             VARCHAR2  default null
,p_registered_disabled_flag       VARCHAR2  default 'N'
,p_sex                            VARCHAR2  default 'M'
,p_title                          VARCHAR2  default 'MR.'
,p_work_telephone                 VARCHAR2  default null
,p_frequency                      VARCHAR2  default 'W'
,p_normal_hours                   VARCHAR2  default '37.5'
,p_time_normal_start              VARCHAR2  default '08:00'
,p_time_normal_finish             VARCHAR2  default '17:30'
,p_probation_period               VARCHAR2  default null
,p_probation_unit                 VARCHAR2  default null
,p_date_probation_end             DATE      default null
,p_manager_flag                   VARCHAR2  default 'N'
,p_supervisor_id                  NUMBER    default null
,p_special_ceiling_step_id        NUMBER    default null
,p_internal_address_line          VARCHAR2  default null
,p_change_reason                  VARCHAR2  default null)
return NUMBER ;
--
--
FUNCTION create_other
(p_effective_start_date           DATE      default null
,p_effective_end_date             DATE      default null
,p_business_group                 VARCHAR2
,p_last_name                      VARCHAR2
,p_date_of_birth                  DATE      default null
,p_expense_chk_send_to_address    VARCHAR2  default 'H'
,p_first_name                     VARCHAR2  default null
,p_known_as                       VARCHAR2  default null
,p_marital_status                 VARCHAR2  default 'S'
,p_middle_names                   VARCHAR2  default null
,p_nationality                    VARCHAR2  default null
,p_national_identifier            VARCHAR2
,p_previous_last_name             VARCHAR2  default null
,p_registered_disabled_flag       VARCHAR2  default 'N'
,p_sex                            VARCHAR2  default null
,p_title                          VARCHAR2  default null
,p_work_telephone                 VARCHAR2  default null)
return NUMBER ;
--
--
FUNCTION create_secondary_assign
  (p_effective_start_date        DATE     DEFAULT null
  ,p_effective_end_date          DATE     DEFAULT null
  ,p_business_group              VARCHAR2
  ,p_person_id                   NUMBER
  ,p_assignment_type             VARCHAR2
  ,p_organization                VARCHAR2 DEFAULT null
  ,p_grade                       VARCHAR2 DEFAULT null
  ,p_job                         VARCHAR2 DEFAULT null
  ,p_position                    VARCHAR2 DEFAULT null
  ,p_payroll                     VARCHAR2 DEFAULT null
  ,p_location                    VARCHAR2 DEFAULT null
  ,p_vacancy                     VARCHAR2 DEFAULT null
  ,p_people_group_id             NUMBER   DEFAULT null
  ,p_cost_allocation_keyflex_id  NUMBER   DEFAULT null
  ,p_manager_flag                VARCHAR2 DEFAULT null
  ,p_change_reason               VARCHAR2 DEFAULT null
  ,p_date_probation_end          DATE     DEFAULT null
  ,p_frequency                   VARCHAR2 DEFAULT 'W'
  ,p_internal_address_line       VARCHAR2 DEFAULT null
  ,p_normal_hours                VARCHAR2 DEFAULT '37.5'
  ,p_probation_period            VARCHAR2 DEFAULT null
  ,p_probation_unit              VARCHAR2 DEFAULT null
  ,p_recruiter_id                NUMBER   DEFAULT null
  ,p_special_ceiling_step_id     NUMBER   DEFAULT null
  ,p_supervisor_id               NUMBER   DEFAULT null
  ,p_recruitment_activity_id     NUMBER   DEFAULT null
  ,p_person_referred_by_id       NUMBER   DEFAULT null
  ,p_source_organization_id      NUMBER   DEFAULT null
  ,p_time_normal_finish          VARCHAR2 DEFAULT '08:00'
  ,p_time_normal_start           VARCHAR2 DEFAULT '17:30')
return NUMBER ;
--
--
FUNCTION create_contact
  (p_effective_start_date           DATE      default null
  ,p_effective_end_date             DATE      default null
  ,p_employee_number                VARCHAR2
  ,p_contact_person_id              VARCHAR2  default null
  ,p_relationship                   VARCHAR2  default null
  ,p_primary_flag                   VARCHAR2  default 'N'
  ,p_dependent_flag                 VARCHAR2  default 'N'
  ,p_business_group                 VARCHAR2
  ,p_last_name                      VARCHAR2
  ,p_date_of_birth                  DATE      default null
  ,p_expense_chk_send_to_address    VARCHAR2  default 'H'
  ,p_first_name                     VARCHAR2  default null
  ,p_known_as                       VARCHAR2  default null
  ,p_marital_status                 VARCHAR2  default 'S'
  ,p_middle_names                   VARCHAR2  default null
  ,p_nationality                    VARCHAR2  default null
  ,p_national_identifier            VARCHAR2
  ,p_previous_last_name             VARCHAR2  default null
  ,p_registered_disabled_flag       VARCHAR2  default 'N'
  ,p_sex                            VARCHAR2  default null
  ,p_title                          VARCHAR2  default null
  ,p_work_telephone                 VARCHAR2  default null)
return NUMBER ;
--
--
end per_db_per_additional;

 

/
