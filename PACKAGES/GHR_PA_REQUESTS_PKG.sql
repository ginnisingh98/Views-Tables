--------------------------------------------------------
--  DDL for Package GHR_PA_REQUESTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_PA_REQUESTS_PKG" AUTHID CURRENT_USER AS
/* $Header: ghparqst.pkh 120.2.12010000.1 2008/07/28 10:35:30 appldev ship $ */

  PROCEDURE get_process_method(
                   p_noa_family_code    IN     ghr_noa_fam_proc_methods.noa_family_code%TYPE
                  ,p_form_block_name    IN     ghr_pa_data_fields.form_block_name%TYPE
                  ,p_form_field_name    IN     ghr_pa_data_fields.form_field_name%TYPE
                  ,p_effective_date     IN     DATE
                  ,p_process_method_code   OUT NOCOPY  VARCHAR2
                  ,p_navigable_flag        OUT NOCOPY  VARCHAR2);
  --
  FUNCTION get_data_field_name(
                   p_form_block_name    IN     ghr_pa_data_fields.form_block_name%TYPE
                  ,p_form_field_name    IN     ghr_pa_data_fields.form_field_name%TYPE)
    RETURN VARCHAR2;
  --
  PROCEDURE get_restricted_process_method(
                   p_restricted_form     IN     ghr_restricted_proc_methods.restricted_form%TYPE
                  ,p_form_block_name     IN     ghr_pa_data_fields.form_block_name%TYPE
                  ,p_form_field_name     IN     ghr_pa_data_fields.form_field_name%TYPE
                  ,p_restricted_proc_method OUT NOCOPY VARCHAR2);
  --
  FUNCTION get_lookup_meaning(
                   p_application_id NUMBER
                  ,p_lookup_type    hr_lookups.lookup_type%TYPE
                  ,p_lookup_code    hr_lookups.lookup_code%TYPE)
    RETURN VARCHAR2;

  -- This is very similar to the function get_lookup_meaning above except it returns the
  -- description as opposed to the meaning, this is required in particular for Legal Authority
  -- since menaing is forced to be unique we use the description
  FUNCTION get_lookup_description(
                   p_application_id NUMBER
                  ,p_lookup_type    hr_lookups.lookup_type%TYPE
                  ,p_lookup_code    hr_lookups.lookup_code%TYPE)
    RETURN VARCHAR2;
  -- Removed Pragma reference, not needed in 8i.
  -- (See bug# 1014743)
  -- pragma restrict_references (get_lookup_description, WNDS, WNPS);

  FUNCTION get_noa_family_name(

                   p_noa_family_code ghr_families.noa_family_code%TYPE)
    RETURN VARCHAR2;

  FUNCTION get_routing_group_name(
                   p_routing_group_id  ghr_routing_groups.routing_group_id%TYPE)
    RETURN VARCHAR2;

  FUNCTION get_full_name(
                   p_person_id      per_people_f.person_id%TYPE
                  ,p_effective_date date)
   RETURN VARCHAR2;

  FUNCTION get_full_name_unsecure(
                   p_person_id      per_people_f.person_id%TYPE
                  ,p_effective_date date)
   RETURN VARCHAR2;

  FUNCTION get_noa_descriptor(
                   p_nature_of_action_id IN     ghr_nature_of_actions.nature_of_action_id%TYPE)
    RETURN VARCHAR2;
  --
  FUNCTION get_remark_descriptor(
                   p_remark_id IN     ghr_remarks.remark_id%TYPE)
    RETURN VARCHAR2;
  -- possibly need description returned not just name?

  -- Bug#5482191 Added the function get_personnel_system_indicator
  FUNCTION get_personnel_system_indicator(
                                   p_position_id    hr_all_positions_f.position_id%TYPE
                                  ,p_effective_date date)
   RETURN VARCHAR2;

  --
  PROCEDURE get_default_routing_group(p_user_name          IN     fnd_user.user_name%TYPE
                                     ,p_routing_group_id   IN OUT NOCOPY  NUMBER
                                     ,p_initiator_flag     IN OUT NOCOPY  VARCHAR2
                                     ,p_requester_flag     IN OUT NOCOPY  VARCHAR2
                                     ,p_authorizer_flag    IN OUT NOCOPY  VARCHAR2
                                     ,p_personnelist_flag  IN OUT NOCOPY  VARCHAR2
                                     ,p_approver_flag      IN OUT NOCOPY  VARCHAR2
                                     ,p_reviewer_flag      IN OUT NOCOPY  VARCHAR2);
  --
  PROCEDURE get_last_routing_list(p_pa_request_id     IN     ghr_pa_requests.pa_request_id%TYPE
                                 ,p_routing_list_id      OUT NOCOPY  ghr_routing_lists.routing_list_id%TYPE
                                 ,p_routing_list_name    OUT NOCOPY  ghr_routing_lists.name%TYPE
                                 ,p_next_seq_number      OUT NOCOPY  ghr_routing_list_members.seq_number%TYPE
                                 ,p_next_user_name       OUT NOCOPY  ghr_routing_list_members.user_name%TYPE
                                 ,p_next_groupbox_id     OUT NOCOPY  ghr_routing_list_members.groupbox_id%TYPE
                                 ,p_broken            IN OUT NOCOPY  BOOLEAN);
  --
  PROCEDURE get_roles (p_pa_request_id     in number
                      ,p_routing_group_id  in number
                      ,p_user_name         in varchar2 default null
                      ,p_initiator_flag    in OUT NOCOPY  varchar2
                      ,p_requester_flag    in OUT NOCOPY  varchar2
                      ,p_authorizer_flag   in OUT NOCOPY  varchar2
                      ,p_personnelist_flag in OUT NOCOPY  varchar2
                      ,p_approver_flag     in OUT NOCOPY  varchar2
                      ,p_reviewer_flag     in OUT NOCOPY  varchar2);
  --
  PROCEDURE get_person_details (p_person_id           IN     per_people_f.person_id%TYPE
                               ,p_effective_date      IN     DATE
                               ,p_national_identifier IN OUT NOCOPY  per_people_f.national_identifier%TYPE
                               ,p_date_of_birth       IN OUT NOCOPY  per_people_f.date_of_birth%TYPE
                               ,p_last_name           IN OUT NOCOPY  per_people_f.last_name%TYPE
                               ,p_first_name          IN OUT NOCOPY  per_people_f.first_name%TYPE
                               ,p_middle_names        IN OUT NOCOPY  per_people_f.middle_names%TYPE);
  --
  PROCEDURE get_duty_station_details (p_duty_station_id   IN     ghr_duty_stations_v.duty_station_id%TYPE
                                     ,p_effective_date    IN     DATE
                                     ,p_duty_station_code IN OUT NOCOPY  ghr_duty_stations_v.duty_station_code%TYPE
                                     ,p_duty_station_desc IN OUT NOCOPY  ghr_duty_stations_v.duty_station_desc%TYPE);
  --
  PROCEDURE get_SF52_person_ddf_details (p_person_id             IN  per_people_f.person_id%TYPE
                                        ,p_date_effective        IN  date       default sysdate
                                        ,p_citizenship           OUT NOCOPY  varchar2
                                        ,p_veterans_preference   OUT NOCOPY  varchar2
                                        ,p_veterans_pref_for_rif OUT NOCOPY  varchar2
                                        ,p_veterans_status       OUT NOCOPY  varchar2
                                        ,p_scd_leave             OUT NOCOPY  varchar2);
  --
  PROCEDURE get_SF52_asg_ddf_details (p_assignment_id         IN  per_assignments_f.assignment_id%TYPE
                                     ,p_date_effective        IN  date       default sysdate
                                     ,p_tenure                OUT NOCOPY  varchar2
                                     ,p_annuitant_indicator   OUT NOCOPY  varchar2
                                     ,p_pay_rate_determinant  OUT NOCOPY  varchar2
                                     ,p_work_schedule         OUT NOCOPY  varchar2
                                     ,p_part_time_hours       OUT NOCOPY  varchar2);
  --
  PROCEDURE get_SF52_pos_ddf_details (p_position_id            IN  hr_all_positions_f.position_id%TYPE
                                     ,p_date_effective         IN  date       default sysdate
                                     ,p_flsa_category          OUT NOCOPY  varchar2
                                     ,p_bargaining_unit_status OUT NOCOPY  varchar2
                                     ,p_work_schedule          OUT NOCOPY  varchar2
                                     ,p_functional_class       OUT NOCOPY  varchar2
                                     ,p_supervisory_status     OUT NOCOPY  varchar2
                                     ,p_position_occupied      OUT NOCOPY  varchar2
                                     ,p_appropriation_code1    OUT NOCOPY  varchar2
                                     ,p_appropriation_code2    OUT NOCOPY  varchar2
						 ,p_personnel_office_id	   OUT NOCOPY  varchar2
						 ,p_office_symbol		   OUT NOCOPY  varchar2
                                     ,p_part_time_hours        OUT NOCOPY  number);
  --
  PROCEDURE get_SF52_loc_ddf_details (p_location_id           IN  hr_locations.location_id%TYPE
                                     ,p_duty_station_id       OUT NOCOPY  varchar2);
  --
  PROCEDURE get_address_details (p_person_id            IN  per_addresses.person_id%TYPE
                                ,p_effective_date       IN  DATE
                                ,p_address_line1        OUT NOCOPY  per_addresses.address_line1%TYPE
                                ,p_address_line2        OUT NOCOPY  per_addresses.address_line2%TYPE
                                ,p_address_line3        OUT NOCOPY  per_addresses.address_line3%TYPE
                                ,p_town_or_city         OUT NOCOPY  per_addresses.town_or_city%TYPE
                                ,p_region_2             OUT NOCOPY  per_addresses.region_2%TYPE
                                ,p_postal_code          OUT NOCOPY  per_addresses.postal_code%TYPE
                                ,p_country		  OUT NOCOPY  per_addresses.country%TYPE
                                ,p_territory_short_name OUT NOCOPY  varchar2);
  --
  PROCEDURE get_SF52_to_data_elements
                                   (p_position_id              IN     hr_all_positions_f.position_id%TYPE
                                   ,p_effective_date           IN     date       default sysdate
                                 ,p_prd                      IN     ghr_pa_requests.pay_rate_determinant%TYPE
                                   ,p_grade_id                 IN OUT NOCOPY  number
                                   ,p_job_id                   IN OUT NOCOPY  number
                                   ,p_organization_id          IN OUT NOCOPY  number
                                   ,p_location_id              IN OUT NOCOPY  number
                                   ,p_pay_plan                    OUT NOCOPY  varchar2
                                   ,p_occ_code                    OUT NOCOPY  varchar2
                                   ,p_grade_or_level              OUT NOCOPY  varchar2
                                   ,p_pay_basis                   OUT NOCOPY  varchar2
                                   ,p_position_org_line1          OUT NOCOPY  varchar2
                                   ,p_position_org_line2          OUT NOCOPY  varchar2
                                   ,p_position_org_line3          OUT NOCOPY  varchar2
                                   ,p_position_org_line4          OUT NOCOPY  varchar2
                                   ,p_position_org_line5          OUT NOCOPY  varchar2
                                   ,p_position_org_line6          OUT NOCOPY  varchar2
                                   ,p_duty_station_id             OUT NOCOPY  number
                                   );

  -- This procedure only really needs to be called for realignment. For this NOA the 6 'address' lines seen
  -- on the to side should come from the 'position organization' on the PAR extra info (if given)
  --
  PROCEDURE get_rei_org_lines (p_pa_request_id       IN ghr_pa_requests.pa_request_id%TYPE
                              ,p_organization_id     IN OUT NOCOPY  VARCHAR2
                              ,p_position_org_line1  OUT NOCOPY  varchar2
                              ,p_position_org_line2  OUT NOCOPY  varchar2
                              ,p_position_org_line3  OUT NOCOPY  varchar2
                              ,p_position_org_line4  OUT NOCOPY  varchar2
                              ,p_position_org_line5  OUT NOCOPY  varchar2
                              ,p_position_org_line6  OUT NOCOPY  varchar2);

  -- This function checks to see if the given DF and context value has any segemnts
  -- defined
  FUNCTION segments_defined (p_flexfield_name IN VARCHAR2
                            ,p_context_code   IN VARCHAR2)
    RETURN BOOLEAN;

  --
  -- This function simply returns the required flag (either Y or N) for a given remark id and NOAC
  -- It is used on the post-query in the SF52 form to set the required indicator on the remarks block
  FUNCTION get_noac_remark_req (p_first_noa_id        IN    ghr_noac_remarks.nature_of_action_id%TYPE
                               ,p_second_noa_id       IN    ghr_noac_remarks.nature_of_action_id%TYPE
                               ,p_remark_id           IN    ghr_noac_remarks.nature_of_action_id%TYPE
                               ,p_effective_date      IN    DATE)
    RETURN VARCHAR2;

  -- This function simply returns the person_id for the given username
  FUNCTION get_user_person_id (p_user_name IN VARCHAR2)
    RETURN NUMBER;

  -- This procedure will return the noac id, code and description if there is only one noac in the given
  -- family, otherwise it returns null
  PROCEDURE get_single_noac_for_fam (p_noa_family_code     IN     ghr_noa_families.noa_family_code%TYPE
                                    ,p_effective_date      IN     DATE
                                    ,p_nature_of_action_id IN OUT NOCOPY  ghr_nature_of_actions.nature_of_action_id%TYPE
                                    ,p_code                IN OUT NOCOPY  ghr_nature_of_actions.code%TYPE
                                    ,p_description         IN OUT NOCOPY  ghr_nature_of_actions.description%TYPE);
  --
  -- This procedure will return the Legal Authority Code and Description if there is only one for the given
  -- NOAC, otherwise it returns null
  PROCEDURE get_single_lac_for_noac (p_nature_of_action_id IN     ghr_noac_las.nature_of_action_id%TYPE
                                    ,p_effective_date      IN     DATE
                                    ,p_lac_code            IN OUT NOCOPY  ghr_noac_las.lac_lookup_code%TYPE
                                    ,p_description         IN OUT NOCOPY  VARCHAR2);
  --
  -- This function simply returns the restricted form (if any) for the given person
  FUNCTION get_restricted_form (p_person_id IN NUMBER)
    RETURN VARCHAR2;
  --
  -- Given a noa of action id return the processing method family it is in
  FUNCTION get_noa_pm_family (p_nature_of_action_id  IN     ghr_noa_families.nature_of_action_id%TYPE)
    RETURN VARCHAR2;
  pragma restrict_references (get_noa_pm_family, WNDS, WNPS);
  --
  -- Bug#3941541 Overloaded function with effective date as another parameter
  FUNCTION get_noa_pm_family (p_nature_of_action_id  IN     ghr_noa_families.nature_of_action_id%TYPE,
                              p_effective_date       IN     DATE)
    RETURN VARCHAR2;
  pragma restrict_references (get_noa_pm_family, WNDS, WNPS);
  --
  -- As above except pass in a noa code and it returns the family it is in
  FUNCTION get_noa_pm_family (p_noa_code  IN     ghr_nature_of_actions.code%TYPE)
    RETURN VARCHAR2;
  pragma restrict_references (get_noa_pm_family, WNDS, WNPS);
  --
  -- Given a position_id and a date check to see if anybody has been assigned
  -- that position at the date and return 'TRUE' if they have
  FUNCTION position_assigned (p_position_id    IN NUMBER
                             ,p_effective_date IN DATE)
    RETURN VARCHAR2;
  pragma restrict_references (position_assigned, WNDS, WNPS);
  --
  -- This function looks at the AOL table FND_CONCURRENT_PROGRAMS to return the defualt printer for the
  -- given concurrent program , Doesn't pass in application ID as 8301 is assumed
  FUNCTION get_default_printer (p_concurrent_program_name IN VARCHAR2)
  RETURN VARCHAR2;
  --
  -- This function returns TRUE if the PA Request passed in has an SF50 produced
  FUNCTION SF50_produced (p_pa_request_id IN NUMBER)
  RETURN BOOLEAN;
  --
  -- This function returns TRUE if the person id passed in is valid for the given date
  -- The noa_family_code determines what is a valid person on the SF52, i.e for APP
  -- family they must be Applicant otherwise they must be Employees.
  -- The select statements need to be the same as on the SF52 as this is only
  -- checking the person is still valid in case the user alters the effective
  -- date after they used the LOV in the form to pick up a person!
  FUNCTION check_person_id_SF52 (p_person_id              IN NUMBER
                                ,p_effective_date         IN DATE
                                ,p_business_group_id      IN NUMBER
                                ,p_user_person_id         IN NUMBER
                                ,p_noa_family_code        IN VARCHAR2
                                ,p_second_noa_family_code IN VARCHAR2)
  RETURN BOOLEAN;
  --
  -- This procedure gets the amounts that are not displayed in a correction form that
  -- are needed to do an other pay totals

  FUNCTION check_valid_person_id (p_person_id              IN NUMBER
                                 ,p_effective_date         IN DATE
                                 ,p_business_group_id      IN NUMBER
                                 ,p_user_person_id         IN NUMBER
                                 ,p_noa_family_code        IN VARCHAR2
                                 ,p_second_noa_family_code IN VARCHAR2)
  RETURN VARCHAR2;
  --
  PROCEDURE get_corr_other_pay(p_pa_request_id               IN  ghr_pa_requests.pa_request_id%TYPE
                              ,p_noa_code                    IN  ghr_nature_of_actions.code%TYPE
                              ,p_to_basic_pay                OUT NOCOPY  NUMBER
                              ,p_to_adj_basic_pay            OUT NOCOPY  NUMBER
                              ,p_to_auo_ppi                  OUT NOCOPY  VARCHAR2
                              ,p_to_auo                      OUT NOCOPY  NUMBER
                              ,p_to_ap_ppi                   OUT NOCOPY  VARCHAR2
                              ,p_to_ap                       OUT NOCOPY  NUMBER
                              ,p_to_retention_allowance      OUT NOCOPY  NUMBER
                              ,p_to_supervisory_differential OUT NOCOPY  NUMBER
                              ,p_to_staffing_differential    OUT NOCOPY  NUMBER
                              ,p_to_pay_basis                OUT NOCOPY  VARCHAR2
-- Corr Warn
                            ,p_pay_rate_determinant        OUT NOCOPY  VARCHAR2
                            ,p_pay_plan                    OUT NOCOPY  VARCHAR2
                            ,p_to_position_id              OUT NOCOPY  NUMBER
                            ,p_person_id                   OUT NOCOPY  NUMBER
                            ,p_locality_adj                OUT NOCOPY  NUMBER
-- Corr Warn
                              );

  PROCEDURE get_corr_rpa_other_pay(p_pa_request_id               IN  ghr_pa_requests.pa_request_id%TYPE
                              ,p_noa_code                    IN  ghr_nature_of_actions.code%TYPE
                              ,p_from_basic_pay              OUT NOCOPY  NUMBER
                              ,p_to_basic_pay                OUT NOCOPY  NUMBER
                              ,p_to_adj_basic_pay            OUT NOCOPY  NUMBER
                              ,p_to_auo_ppi                  OUT NOCOPY  VARCHAR2
                              ,p_to_auo                      OUT NOCOPY  NUMBER
                              ,p_to_ap_ppi                   OUT NOCOPY  VARCHAR2
                              ,p_to_ap                       OUT NOCOPY  NUMBER
                              ,p_to_retention_allowance      OUT NOCOPY  NUMBER
                              ,p_to_supervisory_differential OUT NOCOPY  NUMBER
                              ,p_to_staffing_differential    OUT NOCOPY  NUMBER
                              ,p_to_pay_basis                OUT NOCOPY  VARCHAR2
-- Corr Warn
                            ,p_pay_rate_determinant        OUT NOCOPY  VARCHAR2
                            ,p_pay_plan                    OUT NOCOPY  VARCHAR2
                            ,p_to_position_id              OUT NOCOPY  NUMBER
                            ,p_person_id                   OUT NOCOPY  NUMBER
                            ,p_locality_adj                OUT NOCOPY  NUMBER
                            ,p_from_step_or_rate           OUT NOCOPY  VARCHAR2
                            ,p_to_step_or_rate             OUT NOCOPY  VARCHAR2
-- Corr Warn
                              );

  --
  -- This procedure gets the amounts that are not displayed in a correction form that
  -- are needed to do an award
  PROCEDURE get_corr_award (p_pa_request_id     IN  ghr_pa_requests.pa_request_id%TYPE
                           ,p_noa_code          IN  ghr_nature_of_actions.code%TYPE
                           ,p_from_basic_pay    OUT NOCOPY  NUMBER
                           ,p_from_pay_basis    OUT NOCOPY  VARCHAR2
                           );
  --
  -- The following Function returns the position_working_title of the person , for the position
  -- on his primary Assignment
  FUNCTION get_position_work_title(p_position_id     IN    number,
                                   p_effective_date  IN    date default trunc(sysdate))
  RETURN varchar2;
  FUNCTION get_position_work_title(p_person_id       IN    varchar2,
                                   p_effective_date  IN    date default trunc(sysdate))
  RETURN varchar2;
  --

  -- This Function returns fullname in the format (fml) i.e <First_name>  <Middle_name>.<Last Name>
  FUNCTION get_full_name_fml(p_person_id       IN    varchar2,
                             p_effective_date  IN    date default trunc(sysdate))
  RETURN varchar2;
  --
  FUNCTION get_upd34_pay_basis (p_person_id        IN    per_people_f.person_id%TYPE
                               ,p_position_id      IN    per_positions.position_id%type
                               ,p_prd              IN    ghr_pa_requests.pay_rate_determinant%TYPE
                               ,p_noa_code         IN    varchar2 DEFAULT NULL
                               ,p_pa_request_id    IN    NUMBER DEFAULT NULL
                               ,p_effective_date   IN    DATE)
  RETURN VARCHAR2;
--
  PROCEDURE update34_implement_cancel (p_person_id       IN NUMBER
                                      ,p_assignment_id   IN NUMBER
                                      ,p_date            IN DATE
                                      ,p_altered_pa_request_id in NUMBER);
--
--
  FUNCTION temp_step_true (p_pa_request_id IN ghr_pa_requests.pa_request_id%type)
  RETURN BOOLEAN;
--
--
END ghr_pa_requests_pkg;


/
