--------------------------------------------------------
--  DDL for Package GHR_MTI_APP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_MTI_APP" AUTHID CURRENT_USER AS
/* $Header: ghmtiapp.pkh 120.1 2005/05/29 23:39:58 sumarimu noship $ */

mass_error exception;

procedure populate_and_create_52(p_errbuf out nocopy varchar2,
                                 p_retcode out nocopy number,
                                 p_business_group_id in number,
                                 p_mtin_name in varchar2,
                                 p_mtin_id in number,
                                 p_effective_date in date);

function check_eligibility(p_person_id in number,
                           p_effective_date in date) return boolean;

procedure assign_to_sf52_rec(
    p_person_id                      in number
   ,p_position_id                    in number
   ,p_job_id                         in number
   ,p_employee_assignment_id         in number
   ,p_last_name                      in varchar2
   ,p_first_name                     in varchar2
   ,p_middle_names                   in varchar2
   ,p_national_identifier            in varchar2
   ,p_date_of_birth                  in varchar2
   ,p_effective_date                 in varchar2
   ,p_position_title                 in varchar2
   ,p_position_number                in varchar2
   ,p_position_seq_no                in number
   ,p_pay_plan                       in varchar2
   ,p_occ_code                       in varchar2
   ,p_organization_id                in number
   ,p_grade_id                       in number
   ,p_grade_or_level                 in varchar2
   ,p_pay_basis                      in varchar2
   ,p_step_or_rate                   in varchar2
   ,p_veterans_preference            in varchar2
   ,p_vet_preference_for_RIF         in varchar2
   ,p_FEGLI                          in varchar2
   ,p_tenure                         in varchar2
   ,p_annuitant_indicator            in varchar2
   ,p_pay_rate_determinant           in varchar2
   ,p_retirement_plan                in varchar2
   ,p_service_comp_date              in varchar2
   ,p_work_schedule                  in varchar2
   ,p_position_occupied              in varchar2
   ,p_flsa_category                  in varchar2
   ,p_appropriation_code1            in varchar2
   ,p_appropriation_code2            in varchar2
   ,p_bargaining_unit_status         in varchar2
   ,p_duty_station_location_id       in number
   ,p_duty_station_id                in number
   ,p_duty_station_code              in varchar2
   ,p_duty_station_desc              in varchar2
   ,p_functional_class               in varchar2
   ,p_citizenship                    in varchar2
   ,p_veterans_status                in varchar2
   ,p_supervisory_status             in varchar2
   ,p_type_of_employment             in varchar2
   ,p_race_or_national_origin        in varchar2
   ,p_orig_appointment_auth_code1    in varchar2
   ,p_handicap_code                  in varchar2
   ,p_creditable_military_service    in varchar2
   ,p_previous_retirement_coverage   in varchar2
   ,p_frozen_service                 in varchar2
   ,p_agency_code_transfer_from      in varchar2
   ,p_to_position_org_line1          IN varchar2
   ,p_to_position_org_line2          IN varchar2
   ,p_to_position_org_line3          IN varchar2
   ,p_to_position_org_line4          IN varchar2
   ,p_to_position_org_line5          IN varchar2
   ,p_to_position_org_line6          IN varchar2
   -- Changes 4093771
   , p_to_basic_pay		     IN number
   , p_to_adj_basic_pay              IN number
   , p_to_total_salary               IN number
   -- End Changes 4093771
   ,p_lac_sf52_rec                   in  ghr_pa_requests%rowtype
   ,p_sf52_rec                   out    nocopy  ghr_pa_requests%rowtype);


procedure pr (msg varchar2,par1 in varchar2 default null,
            par2 in varchar2 default null);
END;

 

/
