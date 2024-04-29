--------------------------------------------------------
--  DDL for Package PER_PEOPLE3_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PEOPLE3_PKG" AUTHID CURRENT_USER AS
/* $Header: peper03t.pkh 120.2.12010000.2 2009/02/09 12:11:34 pchowdav ship $ */
--
procedure get_number_generation_property(
                               p_business_group_id NUMBER
                              ,p_property_on NUMBER
                              ,p_property_off NUMBER
                              ,p_employee_property in out nocopy NUMBER
                              ,p_applicant_property in out nocopy NUMBER);
--
procedure get_legislative_ages(p_business_group_id NUMBER
                              ,p_minimum_age IN OUT NOCOPY NUMBER
                              ,p_maximum_age IN OUT NOCOPY NUMBER);
--
procedure get_default_person_type(p_required_type VARCHAR2
                                 ,p_business_group_id NUMBER
                                 ,p_legislation_code VARCHAR2
                                 ,p_person_type IN OUT NOCOPY NUMBER);
procedure get_ddf_exists(p_legislation_code VARCHAR2
                        ,p_ddf_exists IN OUT NOCOPY VARCHAR2);
--
-- #1799586
procedure get_people_ddf_exists(p_legislation_code VARCHAR2
                        ,p_people_ddf_exists IN OUT NOCOPY VARCHAR2);
--
procedure initialize(p_business_group_id NUMBER
                     ,p_legislation_code VARCHAR2
                     ,p_ddf_exists IN OUT NOCOPY VARCHAR2
                     ,p_property_on NUMBER
                     ,p_property_off NUMBER
                     ,p_employee_property in out nocopy NUMBER
                     ,p_applicant_property in out nocopy NUMBER
                     ,p_required_emp_type VARCHAR2
                     ,p_required_app_type VARCHAR2
                     ,p_emp_person_type IN OUT NOCOPY NUMBER
                     ,p_app_person_type IN OUT NOCOPY NUMBER);
--
procedure initialize(p_business_group_id NUMBER
                     ,p_legislation_code VARCHAR2
                     ,p_ddf_exists IN OUT NOCOPY VARCHAR2
                     ,p_property_on NUMBER
                     ,p_property_off NUMBER
                     ,p_employee_property in out nocopy NUMBER
                     ,p_applicant_property in out nocopy NUMBER
                     ,p_required_emp_type VARCHAR2
                     ,p_required_app_type VARCHAR2
                     ,p_emp_person_type IN OUT NOCOPY NUMBER
                     ,p_app_person_type IN OUT NOCOPY NUMBER
                  ,p_minimum_age IN  OUT NOCOPY NUMBER
                  ,p_maximum_age IN OUT NOCOPY NUMBER);
--
procedure initialize(p_business_group_id NUMBER
                     ,p_legislation_code VARCHAR2
                     ,p_ddf_exists IN OUT NOCOPY VARCHAR2
                     ,p_property_on NUMBER
                     ,p_property_off NUMBER
                     ,p_employee_property in out nocopy NUMBER
                     ,p_applicant_property in out nocopy NUMBER
                     ,p_required_emp_type VARCHAR2
                     ,p_required_app_type VARCHAR2
                     ,p_emp_person_type IN OUT NOCOPY NUMBER
                     ,p_app_person_type IN OUT NOCOPY NUMBER
                  ,p_minimum_age IN  OUT NOCOPY NUMBER
                  ,p_maximum_age IN OUT NOCOPY NUMBER
                 ,p_people_ddf_exists IN OUT NOCOPY VARCHAR2);
--
procedure check_future_apl(p_person_id NUMBER
                          ,p_hire_date DATE);
--added for bug 5403222
procedure check_future_apl(p_person_id NUMBER
                          ,p_hire_date DATE
                          ,p_table HR_EMPLOYEE_APPLICANT_API.t_ApplTable );
--
--
procedure update_period(p_person_id number
                       ,p_hire_date date
                       ,p_new_hire_date date
                       ,p_adjusted_svc_date in date default hr_api.g_date);
--
procedure run_alu_ee(p_alu_mode VARCHAR2
                    ,p_business_group_id NUMBER
                    ,p_person_id NUMBER
                    ,p_old_start DATE
                    ,p_start_date date);
--
procedure vacancy_chk (p_person_id NUMBER
                      ,p_fire_warning in out nocopy VARCHAR2
                      ,p_vacancy_id in out nocopy NUMBER
                      -- #2381925
                      ,p_table IN HR_EMPLOYEE_APPLICANT_API.t_ApplTable
                               default HR_EMPLOYEE_APPLICANT_API.T_EmptyAPPL
                      --
);
--
procedure get_accepted_appls(p_person_id NUMBER
                            ,p_num_accepted_appls in out nocopy  NUMBER
                            ,p_new_primary_id in out nocopy NUMBER);
--
procedure get_all_current_appls(p_person_id NUMBER
                               ,p_num_appls in out nocopy NUMBER);
--
procedure get_date_range(p_person_id in number
                        ,p_min_start in out nocopy date
                        ,p_max_end in out nocopy date);
--
procedure get_asg_date_range(p_assignment_id in number
                            ,p_min_start in out nocopy date
                            ,p_max_end in out nocopy date);
--
procedure form_post_query(p_ethnic_code IN VARCHAR2
                         ,p_ethnic_meaning IN OUT NOCOPY VARCHAR2
                         ,p_visa_code IN VARCHAR2
                         ,p_visa_meaning IN OUT NOCOPY VARCHAR2
                         ,p_veteran_code IN VARCHAR2
                         ,p_veteran_meaning IN OUT NOCOPY VARCHAR2
			 ,p_i9_code IN VARCHAR2
			 ,p_i9_meaning IN OUT NOCOPY VARCHAR2
                         ,p_legislation_code IN VARCHAR2);
--
procedure form_post_query(p_ethnic_code IN VARCHAR2
                         ,p_ethnic_meaning IN OUT NOCOPY VARCHAR2
                         ,p_visa_code IN VARCHAR2
                         ,p_visa_meaning IN OUT NOCOPY VARCHAR2
                         ,p_veteran_code IN VARCHAR2
                         ,p_veteran_meaning IN OUT NOCOPY VARCHAR2
			 ,p_i9_code IN VARCHAR2
			 ,p_i9_meaning IN OUT NOCOPY VARCHAR2
                         ,p_new_hire_code IN VARCHAR2
                         ,p_new_hire_meaning IN OUT NOCOPY VARCHAR2
                         ,p_reason_for_code IN VARCHAR2
                         ,p_reason_for_meaning IN OUT NOCOPY VARCHAR2
                         ,p_legislation_code IN VARCHAR2);
--
procedure form_post_query(p_ethnic_code IN VARCHAR2
                         ,p_ethnic_meaning IN OUT NOCOPY VARCHAR2
                         ,p_visa_code IN VARCHAR2
                         ,p_visa_meaning IN OUT NOCOPY VARCHAR2
                         ,p_veteran_code IN VARCHAR2
                         ,p_veteran_meaning IN OUT NOCOPY VARCHAR2
			 ,p_i9_code IN VARCHAR2
			 ,p_i9_meaning IN OUT NOCOPY VARCHAR2
                         ,p_new_hire_code IN VARCHAR2
                         ,p_new_hire_meaning IN OUT NOCOPY VARCHAR2
                         ,p_reason_for_code IN VARCHAR2
                         ,p_reason_for_meaning IN OUT NOCOPY VARCHAR2
                         ,p_ethnic_disc_code IN VARCHAR2
                         ,p_ethnic_disc_meaning IN OUT NOCOPY VARCHAR2
                         ,p_legislation_code IN VARCHAR2);
--
-- Overloaded procedure for bug --bug7608613
procedure form_post_query(p_ethnic_code IN VARCHAR2
                         ,p_ethnic_meaning IN OUT NOCOPY VARCHAR2
                         ,p_visa_code IN VARCHAR2
                         ,p_visa_meaning IN OUT NOCOPY VARCHAR2
                         ,p_veteran_code IN VARCHAR2
                         ,p_veteran_meaning IN OUT NOCOPY VARCHAR2
			 ,p_i9_code IN VARCHAR2
			 ,p_i9_meaning IN OUT NOCOPY VARCHAR2
                         ,p_new_hire_code IN VARCHAR2
                         ,p_new_hire_meaning IN OUT NOCOPY VARCHAR2
                         ,p_reason_for_code IN VARCHAR2
                         ,p_reason_for_meaning IN OUT NOCOPY VARCHAR2
                         ,p_ethnic_disc_code IN VARCHAR2
                         ,p_ethnic_disc_meaning IN OUT NOCOPY VARCHAR2
			 ,p_vets100A_code IN VARCHAR2
                         ,p_vets100A_meaning IN OUT NOCOPY VARCHAR2
                         ,p_legislation_code IN VARCHAR2);
--
function chk_events_exist(p_person_id number
                          ,p_business_group_id number
                          ,p_hire_date date )return boolean;
--
END PER_PEOPLE3_PKG;

/
