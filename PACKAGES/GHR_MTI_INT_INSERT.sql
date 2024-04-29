--------------------------------------------------------
--  DDL for Package GHR_MTI_INT_INSERT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_MTI_INT_INSERT" AUTHID CURRENT_USER AS
/* $Header: ghrmtins.pkh 120.1.12010000.2 2009/08/07 09:41:12 utokachi ship $ */

	g_package       constant varchar2(33) := '  ghr_mti_int_insert.';
	g_log_enabled	 boolean := TRUE;

	procedure main_convert(
		p_transfer_name		        IN varchar2,
                p_process_date                  IN date,
		p_effective_date	        IN date,
                p_source                        IN varchar2,
                p_status                        IN varchar2,
                p_person_id                     IN OUT NOCOPY number,
		p_inter_bg_transfer	        IN varchar2,
                p_date_of_birth                 IN date,
                p_effective_end_date            IN date,
                p_effective_start_date          IN date,
                p_first_name                    IN varchar2,
                p_full_name                     IN varchar2,
                p_last_name                     IN varchar2,
                p_marital_status                IN varchar2,
                p_middle_names                  IN varchar2,
                p_national_identifier           IN varchar2,
                p_nationality                   IN varchar2,
                p_rehire_reason                 IN varchar2,
                p_sex                           IN varchar2,
                p_start_date                    IN date,
                p_title                         IN varchar2,
                p_work_telephone                IN varchar2,
                p_citizenship                   IN varchar2,
                p_veterans_preference           IN varchar2,
                p_veterans_preference_for_RIF   IN varchar2,
                p_veterans_status               IN varchar2,
                p_appointment_type              IN varchar2,
                p_type_of_employment            IN varchar2,
                p_race_or_national_origin       IN varchar2,
                p_agency_code_transfer_from     IN varchar2,
                p_orig_appointment_auth_code_1  IN varchar2,
		p_orig_appt_auth_code_1_desc	IN varchar2,--Bug# 8724192
                p_orig_appointment_auth_code_2  IN varchar2,
		p_orig_appt_auth_code_2_desc	IN varchar2,--Bug# 8724192
                p_handicap_code                 IN varchar2,
                p_service_comp_date             IN date,
		-- Bug 2412656 Added FERS Coverage
		p_fers_coverage                 IN VARCHAR2,
                p_previous_retirement_coverage  IN varchar2,
                p_frozen_service                IN varchar2,
                p_Creditable_Military_Service   IN varchar2,
	        p_flsa_category                 IN varchar2,
                p_bargaining_unit_status        IN varchar2,
                p_functional_class              IN varchar2,
                p_position_working_title        IN varchar2,
                p_supervisory_status            IN varchar2,
                p_position_occupied             IN varchar2,
                p_appropriation_code1           IN varchar2,
                p_appropriation_code2           IN varchar2,
                p_total_salary                  IN number,
                p_basic_salary_rate             IN number,
                p_locality_adjustment           IN number,
                p_adjusted_basic_pay            IN number,
                p_other_pay                     IN number,
                p_fegli                         IN varchar2,
                p_retirement_plan               IN varchar2,
                p_retention_allowance           IN number,
                p_staffing_differential         IN number,
                p_supervisory_differential      IN number,
                p_wgi_date_due                  IN date,
                p_fegli_desc                    IN varchar2,
                p_retirement_plan_desc          IN varchar2,
                p_au_overtime                   IN number,
                p_availability_pay              IN number,
                p_auo_premium_pay_indicator     IN varchar2,
                p_ap_premium_pay_indicator      IN varchar2,
                p_to_position_id                IN number,
                p_from_grade_or_level           IN varchar2,
                p_from_pay_plan                 IN varchar2,
                p_from_position_title           IN varchar2,
                p_from_position_seq_num         IN number,
                p_duty_station_code             IN varchar2,
                p_duty_station_desc             IN varchar2,
                p_from_step_or_rate             IN varchar2,
                p_tenure                        IN varchar2,
                p_annuitant_indicator           IN varchar2,
                p_pay_rate_determinant          IN varchar2,
                p_work_schedule                 IN varchar2,
                p_part_time_hours               IN number,
                p_date_arrivd_personnel_office  IN date,
                p_non_disclosure_agmt_status    IN varchar2,
                p_part_time_indicator           IN varchar2,
                p_qualif_standards_waiver       IN varchar2,
                p_education_level               IN varchar2,
                p_academic_discipline           IN varchar2,
                p_year_degree_attained          IN varchar2 ,
		-- Changes 4093771
	        p_to_total_salary               IN number,
                p_to_basic_salary_rate          IN number,
                p_to_adjusted_basic_pay         IN number,
		-- End Changes 4093771
		--Begin Bug# 8724192
		p_assignment_nte_start_date	IN date,
		p_assignment_nte		IN date
		--end Bug# 8724192
		);

        procedure Update_Process_Flag(
	            p_transfer_name 		IN varchar2,
	            p_include_error		IN varchar2,
	            p_override_prev_selection	IN varchar2,
	            p_value			IN varchar2);

	procedure map_mtv_to_people_f(
		p_transfer_name		        IN varchar2,
		p_inter_bg_transfer	        IN varchar2,
		p_effective_date	        IN date,
                p_person_id                     IN number,
                p_date_of_birth                 IN date,
                p_effective_end_date            IN date,
                p_effective_start_date          IN date,
                p_first_name                    IN varchar2,
                p_full_name                     IN varchar2,
                p_last_name                     IN varchar2,
                p_marital_status                IN varchar2,
                p_middle_names                  IN varchar2,
                p_national_identifier           IN varchar2,
                p_nationality                   IN varchar2,
                p_rehire_reason                 IN varchar2,
                p_sex                           IN varchar2,
                p_start_date                    IN date,
                p_title                         IN varchar2,
                p_work_telephone                IN varchar2,
                p_action                        IN varchar2   );

	procedure map_mtv_to_people_ei1(
		p_transfer_name                 IN varchar2,
	        p_effective_date 	        IN date,
                p_person_id                     IN number,
                p_citizenship                   IN varchar2,
                p_veterans_preference           IN varchar2,
                p_veterans_preference_for_RIF   IN varchar2,
                p_veterans_status               IN varchar2,
                p_action                        IN varchar2   );

	procedure map_mtv_to_people_ei2(
		p_transfer_name 	         IN varchar2,
	        p_effective_date 	         IN date,
                p_person_id                      IN number,
                p_appointment_type               IN varchar2,
                p_type_of_employment             IN varchar2,
                p_race_or_national_origin        IN varchar2,
--                p_agency_code_transfer_from      IN varchar2,
                p_orig_appointment_auth_code_1   IN varchar2,
		p_orig_appt_auth_code_1_desc	 IN varchar2, --Bug# 8724192
                p_orig_appointment_auth_code_2   IN varchar2,
		p_orig_appt_auth_code_2_desc	 IN varchar2, --Bug# 8724192
                p_handicap_code                  IN varchar2,
                p_action                         IN varchar2  );

	procedure map_mtv_to_people_ei3(
		p_transfer_name                  IN varchar2,
	        p_effective_date 	         IN date,
                p_person_id                      IN number,
                p_service_comp_date              IN date,
                p_action                         IN varchar2      );

	procedure map_mtv_to_people_ei4(
		p_transfer_name 	         IN varchar2,
	        p_effective_date 	         IN date,
                p_person_id                      IN number,
		-- Bug 2412656 Added FERS Coverage
		p_fers_coverage                  IN VARCHAR2,
                p_previous_retirement_coverage   IN varchar2,
                p_frozen_service                 IN varchar2,
                p_action                         IN varchar2  );

	procedure map_mtv_to_people_ei5(
		p_transfer_name          	 IN varchar2,
	        p_effective_date 	         IN date,
                p_person_id                      IN number,
                p_creditable_military_service    IN varchar2,
                p_action                         IN varchar2  );

	procedure map_mtv_to_position_ei1(
		p_transfer_name		         IN varchar2,
	        p_person_id		         IN number,
	        p_effective_date	         IN date,
	        p_flsa_category                  IN varchar2,
                p_bargaining_unit_status         IN varchar2,
                p_functional_class               IN varchar2,
                p_position_working_title         IN varchar2,
                p_supervisory_status             IN varchar2,
                p_action                         IN varchar2  );

	procedure map_mtv_to_position_ei2(
		p_transfer_name		         IN varchar2,
	        p_person_id		         IN number,
	        p_effective_date	         IN date,
                p_position_occupied              IN varchar2,
                p_appropriation_code1            IN varchar2,
                p_appropriation_code2            IN varchar2,
                p_action                         IN varchar2  );

	procedure map_mtv_to_element_entries(
        	p_transfer_name	                IN varchar2,
	        p_person_id	                IN number,
	        p_effective_date                IN date,
                p_total_salary                  IN number,
                p_basic_salary_rate             IN number,
                p_locality_adjustment           IN number,
                p_adjusted_basic_pay            IN number,
                p_other_pay                     IN number,
                p_fegli                         IN varchar2,
                p_retirement_plan               IN varchar2,
                p_retention_allowance           IN number,
                p_staffing_differential         IN number,
                p_supervisory_differential      IN number,
                p_wgi_date_due                  IN date,
                p_fegli_desc                    IN varchar2,
                p_retirement_plan_desc          IN varchar2,
                p_au_overtime                   IN number,
                p_availability_pay              IN number,
                p_auo_premium_pay_indicator     IN varchar2,
                p_ap_premium_pay_indicator      IN varchar2,
		-- changes 4093771
		p_to_total_salary               IN number,
		p_to_basic_salary_rate          IN number,
		p_to_adjusted_basic_pay         IN number,
		-- End changes 4093771
                p_action                        IN varchar2   );

	procedure  map_mtv_to_misc(
		p_transfer_name		        IN varchar2,
		p_person_id		        IN number,
		p_effective_date	        IN date,
                p_to_position_id                IN number,
                p_from_grade_or_level           IN varchar2,
                p_from_pay_plan                 IN varchar2,
                p_from_position_title           IN varchar2,
                p_from_position_seq_num         IN number,
                p_duty_station_code             IN varchar2,
                p_duty_station_desc             IN varchar2,
                p_from_agency_code              IN varchar2,
                p_action                        IN varchar2   );

	procedure map_mtv_to_assign_ei1(
		p_transfer_name		        IN varchar2,
	        p_person_id		        IN number,
	        p_effective_date	        IN date,
                p_from_step_or_rate             IN varchar2,
                p_tenure                        IN varchar2,
                p_annuitant_indicator           IN varchar2,
                p_pay_rate_determinant          IN varchar2,
                p_work_schedule                 IN varchar2,
                p_part_time_hours               IN number ,
                p_action                        IN varchar2    );

	procedure map_mtv_to_assign_ei2(
		p_transfer_name		        IN varchar2,
	        p_person_id		        IN number,
	        p_effective_date	        IN date,
                p_date_arrivd_personnel_office  IN date,
                p_non_disclosure_agmt_status    IN varchar2,
                p_part_time_indicator           IN varchar2,
                p_qualif_standards_waiver       IN varchar2,
                p_action                        IN varchar2   );

	--Begin Bug# 8724192
	procedure map_mtv_to_assign_ei3(
                p_transfer_name                 IN varchar2,
                p_person_id                     IN number,
                p_effective_date                IN date,
                p_assignment_nte_start_date	IN date,
		p_assignment_nte		IN date,
                p_action                        IN varchar2  );
	--End Bug# 8724192

	procedure map_mtv_to_special_info(
		p_transfer_name	                IN varchar2,
		p_effective_date	        IN date,
		p_person_id		        IN number,
                p_education_level               IN varchar2,
                p_academic_discipline           IN varchar2,
                p_year_degree_attained          IN varchar2,
                p_action                        IN varchar2   );

	procedure map_mtv_to_assign_f(
		p_transfer_name	                IN varchar2,
		p_effective_date	        IN date,
                p_assignment_id                 IN number);

	procedure map_mtv_to_position(
		p_transfer_name	                IN varchar2,
		p_person_id		        IN number,
		p_effective_date	        IN date,
                p_position_id                   IN number);

        function Submit_MTI_Request (
                             P_DESCRIPTION	IN VARCHAR2,
                             P_ARGUMENT1	IN VARCHAR2,
                             P_ARGUMENT2	IN VARCHAR2)
        RETURN NUMBER;

        Procedure set_process_flag(
                  p_mt_name       in varchar2,
                  p_mt_person_id  in number,
                  p_mt_status     in varchar2);

  FUNCTION get_lookup_meaning(
                   p_lookup_type    hr_lookups.lookup_type%TYPE
                  ,p_lookup_code    hr_lookups.lookup_code%TYPE)
    RETURN VARCHAR2;

  -- Removed reference because it failed to compile
  -- for 8i pragma are not required (see bug# 1014743)
  -- pragma restrict_references (get_lookup_meaning, WNDS, WNPS);



end ghr_mti_int_insert;

/
