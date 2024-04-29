--------------------------------------------------------
--  DDL for Package GHR_MSL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_MSL_PKG" AUTHID CURRENT_USER AS
/* $Header: ghmslexe.pkh 120.7.12010000.2 2009/03/19 12:11:26 vmididho ship $ */

  msl_error    EXCEPTION;

g_ses_msl_process     VARCHAR2(1);
g_ses_bp_capped BOOLEAN := FALSE;
g_sl_payband_conv BOOLEAN := FALSE;   --8320557

---GPPA Update 46 changes
g_first_noa_code      ghr_nature_of_actions.code%type;

-- Bug#5063304  Moved this type definition from execute_msl to global level.
TYPE pay_plan_prd IS RECORD
(
pay_plan	ghr_mass_salary_criteria.pay_plan%type,
prd		    ghr_mass_salary_criteria.pay_rate_determinant%type
);

TYPE pp_prd IS TABLE OF pay_plan_prd INDEX BY BINARY_INTEGER;

TYPE pay_plan_prd_per_gr IS RECORD
(
pay_plan	ghr_mass_salary_criteria.pay_plan%type,
prd		    ghr_mass_salary_criteria.pay_rate_determinant%type,
percent		ghr_mass_salary_criteria_ext.increase_percent%type,
grade		ghr_mass_salary_criteria_ext.grade%type
);

TYPE pp_prd_per_gr IS TABLE OF pay_plan_prd_per_gr INDEX BY BINARY_INTEGER;

PROCEDURE execute_msl (p_errbuf out nocopy varchar2,
                       p_retcode out nocopy number,
                       p_mass_salary_id in number,
                       p_action in varchar2
		       );
                       --p_bus_grp_id in number);


PROCEDURE execute_msl_perc (p_errbuf out nocopy varchar2,
                       p_retcode out nocopy number,
                       p_mass_salary_id in number,
                       p_action in varchar2);

function SUBMIT_CONC_REQ (P_APPLICATION IN VARCHAR2,
                              P_PROGRAM IN VARCHAR2,
                              P_DESCRIPTION IN VARCHAR2,
                              P_START_TIME IN VARCHAR2,
                              P_SUB_REQUEST IN BOOLEAN,
                              P_ARGUMENT1 IN VARCHAR2,
                              P_ARGUMENT2 IN VARCHAR2)
   return number;

procedure purge_processed_recs(p_session_id in number,
                               p_err_buf out nocopy varchar2);

procedure pop_dtls_from_pa_req(p_person_id in number,p_effective_date in date,
         p_mass_salary_id in number, p_org_name in varchar2);

FUNCTION GET_PAY_PLAN_NAME (PP IN VARCHAR2) RETURN VARCHAR2;
FUNCTION GET_USER_TABLE_name (P_USER_TABLE_id IN NUMBER) RETURN VARCHAR2;

procedure ins_upd_per_extra_info
               (p_person_id in number,p_effective_date in date,
                p_sel_flag in varchar2, p_comment in varchar2,
                p_msl_id   in number, p_increase_percent in number default NULL);

procedure ins_upd_per_ses_extra_info
               (p_person_id in number,p_effective_date in date,
                p_sel_flag in varchar2, p_comment in varchar2,
                p_msl_id   in number, p_ses_basic_pay in number default NULL);

PROCEDURE get_extra_info_comments
                (p_person_id in number,
                 p_effective_date in date,
                 p_sel_flag    in out nocopy varchar2,
                 p_comments    in out nocopy varchar2,
                 p_mass_salary_id in number,
		 p_increase_percent out nocopy number,
		 p_ses_basic_pay out nocopy number);

-- Bug#5063304 Created this new procedure
PROCEDURE fetch_and_validate_emp(
                              p_action              IN VARCHAR2
                             ,p_mass_salary_id      IN NUMBER
                             ,p_mass_salary_name    IN VARCHAR2
                             ,p_full_name           IN per_people_f.full_name%TYPE
							 ,p_national_identifier IN per_people_f.national_identifier%TYPE
                             ,p_assignment_id       IN per_assignments_f.assignment_id%TYPE
							 ,p_person_id           IN per_assignments_f.person_id%TYPE
							 ,p_position_id         IN per_assignments_f.position_id%TYPE
							 ,p_grade_id            IN per_assignments_f.grade_id%TYPE
							 ,p_business_group_id   IN per_assignments_f.business_group_iD%TYPE
							 ,p_location_id         IN per_assignments_f.location_id%TYPE
							 ,p_organization_id     IN per_assignments_f.organization_id%TYPE
                             ,p_msl_organization_id       IN per_assignments_f.organization_id%TYPE
                             ,p_msl_duty_station_id       IN ghr_duty_stations_f.duty_station_id%TYPE
                             ,p_msl_personnel_office_id    IN VARCHAR2
                             ,p_msl_agency_code_subelement IN VARCHAR2
                             ,p_msl_user_table_id          IN NUMBER
                             ,p_rec_pp_prd                 IN pp_prd
                             ,p_personnel_office_id OUT NOCOPY VARCHAR2
                             ,p_org_structure_id    OUT NOCOPY VARCHAR2
                             ,p_position_title      OUT NOCOPY VARCHAR2
                             ,p_position_number     OUT NOCOPY VARCHAR2
                             ,p_position_seq_no     OUT NOCOPY VARCHAR2
                             ,p_subelem_code        OUT NOCOPY VARCHAR2
                             ,p_duty_station_id     OUT NOCOPY ghr_duty_stations_f.duty_station_id%TYPE
                             ,p_tenure              OUT NOCOPY VARCHAR2
                             ,p_annuitant_indicator OUT NOCOPY VARCHAR2
                             ,p_pay_rate_determinant OUT NOCOPY VARCHAR2
                             ,p_work_schedule       OUT NOCOPY  VARCHAR2
                             ,p_part_time_hour      OUT NOCOPY VARCHAR2
                             ,p_to_grade_id         OUT NOCOPY per_assignments_f.grade_id%type
                             ,p_pay_plan            OUT NOCOPY VARCHAR2
                             ,p_to_pay_plan         OUT NOCOPY VARCHAR2
                             ,p_pay_table_id        OUT NOCOPY NUMBER
                             ,p_grade_or_level      OUT NOCOPY VARCHAR2
                             ,p_to_grade_or_level   OUT NOCOPY VARCHAR2
                             ,p_step_or_rate        OUT NOCOPY VARCHAR2
                             ,p_pay_basis           OUT NOCOPY VARCHAR2
                             ,p_elig_flag           OUT NOCOPY BOOLEAN
			                );
--
--
--
PROCEDURE fetch_and_validate_emp_perc(
                              p_action              IN VARCHAR2
                             ,p_mass_salary_id      IN NUMBER
                             ,p_mass_salary_name    IN VARCHAR2
                             ,p_full_name           IN per_people_f.full_name%TYPE
							 ,p_national_identifier IN per_people_f.national_identifier%TYPE
                             ,p_assignment_id       IN per_assignments_f.assignment_id%TYPE
							 ,p_person_id           IN per_assignments_f.person_id%TYPE
							 ,p_position_id         IN per_assignments_f.position_id%TYPE
							 ,p_grade_id            IN per_assignments_f.grade_id%TYPE
							 ,p_business_group_id   IN per_assignments_f.business_group_iD%TYPE
							 ,p_location_id         IN per_assignments_f.location_id%TYPE
							 ,p_organization_id     IN per_assignments_f.organization_id%TYPE
                             ,p_msl_organization_id       IN per_assignments_f.organization_id%TYPE
                             ,p_msl_duty_station_id       IN ghr_duty_stations_f.duty_station_id%TYPE
                             ,p_msl_personnel_office_id    IN VARCHAR2
                             ,p_msl_agency_code_subelement IN VARCHAR2
                             ,p_msl_user_table_id          IN NUMBER
                             ,p_rec_pp_prd_per_gr          IN pp_prd_per_gr
                             ,p_personnel_office_id OUT NOCOPY VARCHAR2
                             ,p_org_structure_id    OUT NOCOPY VARCHAR2
                             ,p_position_title      OUT NOCOPY VARCHAR2
                             ,p_position_number     OUT NOCOPY VARCHAR2
                             ,p_position_seq_no     OUT NOCOPY VARCHAR2
                             ,p_subelem_code        OUT NOCOPY VARCHAR2
                             ,p_duty_station_id     OUT NOCOPY ghr_duty_stations_f.duty_station_id%TYPE
                             ,p_tenure              OUT NOCOPY VARCHAR2
                             ,p_annuitant_indicator OUT NOCOPY VARCHAR2
                             ,p_pay_rate_determinant OUT NOCOPY VARCHAR2
                             ,p_work_schedule       OUT NOCOPY  VARCHAR2
                             ,p_part_time_hour      OUT NOCOPY VARCHAR2
                             ,p_pay_plan            OUT NOCOPY VARCHAR2
                             ,p_pay_table_id        OUT NOCOPY NUMBER
                             ,p_grade_or_level      OUT NOCOPY VARCHAR2
                             ,p_step_or_rate        OUT NOCOPY VARCHAR2
                             ,p_pay_basis           OUT NOCOPY VARCHAR2
                             ,p_increase_percent    OUT NOCOPY NUMBER
                             ,p_elig_flag           OUT NOCOPY BOOLEAN
			                );
--
--
--
FUNCTION check_init_eligibility(p_duty_station_id in number,
                           p_PERSONNEL_OFFICE_ID in varchar2,
                           p_AGENCY_CODE_SUBELEMENT in varchar2,

                           p_l_duty_station_id in number,
                           p_l_personnel_office_id in varchar2,
                           p_l_sub_element_code in varchar2)
RETURN boolean;

FUNCTION check_eligibility(p_mass_salary_id  in number,
                           p_user_table_id   in  number,
                           p_pay_table_id    in  number,
                           p_pay_plan        in  varchar2,

                           p_pay_rate_determinant in varchar2,
                           p_person_id in number,
                           p_effective_date in date,
                           p_action in varchar2)
RETURN boolean;

function person_in_pa_req_1noa
          (p_person_id      in number,
           p_effective_date in date,
           p_first_noa_code in varchar2,
           p_pay_plan       in varchar2,
           p_days           in number default 350
           )
  return boolean;

function person_in_pa_req_2noa
          (p_person_id      in number,
           p_effective_date in date,
           p_second_noa_code in varchar2,
           p_days           in number default 350
           )
  return boolean;

PROCEDURE get_from_sf52_data_elements (p_assignment_id in number,
                                       p_effective_date in date,
                                       p_old_basic_pay out nocopy number,
                                       p_old_avail_pay out nocopy number,
                                       p_old_loc_diff out nocopy number,
                                       p_tot_old_sal out nocopy number,
                                       p_old_auo_pay out nocopy number,
                                       p_old_adj_basic_pay out nocopy number,
                                       p_other_pay out nocopy number,
                                       p_auo_premium_pay_indicator out nocopy varchar2,
                                       p_ap_premium_pay_indicator out nocopy varchar2,
                                       p_retention_allowance out nocopy number,
                                       p_retention_allow_perc out nocopy number,
                                       p_supervisory_differential out nocopy number,
                                       p_supervisory_diff_perc out nocopy number,
                                       p_staffing_differential out nocopy number);

procedure get_sub_element_code_pos_title
               (p_position_id in per_assignments_f.position_id%type,
                p_person_id in number,
                p_business_group_id in per_assignments_f.business_group_id%type,
                p_assignment_id in per_assignments_f.assignment_id%type,
                p_effective_date in date,
                p_sub_element_code out nocopy varchar2,
                p_position_title   out nocopy varchar2,
                p_position_number   out nocopy varchar2,
                p_position_seq_no   out nocopy varchar2);

procedure get_other_dtls_for_rep(p_prd in varchar2,
                 p_first_lac2_information1 in varchar2,
                 p_first_lac2_information2 in varchar2,
                 p_first_action_la_code1 out nocopy varchar2,
                 p_first_action_la_code2 out nocopy varchar2,
                 p_remark_code1 out nocopy varchar2,
                 p_remark_code2 out nocopy varchar2
                 );

function check_select_flg_msl_perc(p_person_id in number,
                          p_action in varchar2,
                          p_effective_date in date,
                          p_mass_salary_id in number,
                          p_sel_flg in out nocopy varchar2,
						  p_increase_percent in out nocopy number)
return boolean;


function check_select_flg(p_person_id in number,
                          p_action in varchar2,
                          p_effective_date in date,
                          p_mass_salary_id in number,
                          p_sel_flg in out nocopy varchar2)
return boolean;

procedure purge_old_data (p_mass_salary_id in number);

PROCEDURE get_pay_plan_and_table_id (p_prd in varchar2,
                        p_person_id in number,
                        p_position_id in per_assignments_f.position_id%type,
                        p_effective_date in date,
                        p_grade_id in per_assignments_f.grade_id%type,
                        p_assignment_id in per_assignments_f.assignment_id%type,
                        p_action in varchar2,
                        p_pay_plan out nocopy varchar2,
                        p_pay_table_id out nocopy number,
                        p_grade_or_level out nocopy varchar2,
                        p_step_or_rate   out nocopy varchar2,
                        p_pay_basis out nocopy varchar2);

--Bug#5089732 Created new overloaded procedure get_pay_plan_and_table_id
PROCEDURE get_pay_plan_and_table_id (p_prd in varchar2,
                        p_person_id in number,
                        p_position_id in per_assignments_f.position_id%type,
                        p_effective_date in date,
                        p_grade_id in per_assignments_f.grade_id%type,
                        p_to_grade_id out nocopy per_assignments_f.grade_id%type,
                        p_assignment_id in per_assignments_f.assignment_id%type,
                        p_action in varchar2,
                        p_pay_plan out nocopy varchar2,
			            p_to_pay_plan out nocopy varchar2,
                        p_pay_table_id out nocopy number,
                        p_grade_or_level out nocopy varchar2,
			            p_to_grade_or_level out nocopy varchar2,
                        p_step_or_rate   out nocopy varchar2,
                        p_pay_basis out nocopy varchar2);

procedure update_sel_flg (p_person_id in number,p_effective_date date);

FUNCTION check_grade_retention(p_prd in varchar2
                              ,p_person_id in number
                              ,p_effective_date in date) return varchar2;

procedure get_pos_grp1_ddf (p_position_id in per_assignments_f.position_id%type,
                            p_effective_date in date,
                            p_pos_ei_data     out nocopy per_position_extra_info%rowtype);

procedure create_mass_act_prev (
 p_effective_date in date,
 p_date_of_birth in date,
 p_full_name in varchar2,
 p_national_identifier in varchar2,
 p_duty_station_code in varchar2,
 p_duty_station_desc in varchar2,
 p_personnel_office_id in varchar2,
 p_basic_pay       in number,
 p_new_basic_pay   in number,
   -- Bug#2383992
 p_adj_basic_pay       in number,
 p_new_adj_basic_pay   in number,
  -- Bug#2383992
 p_old_avail_pay   in number,
 p_new_avail_pay   in number,
 p_old_loc_diff    in number,
 p_new_loc_diff    in number,
 p_tot_old_sal     in number,
 p_tot_new_sal     in number,
 p_old_auo_pay     in number,
 p_new_auo_pay     in number,
 p_position_id in per_assignments_f.position_id%type,
 p_position_title in varchar2,
 -- FWFA Changes Bug#4444609
 p_position_number in varchar2,
 p_position_seq_no in varchar2,
 -- FWFA Changes
 p_org_structure_id in varchar2,
 p_agency_sub_element_code in varchar2,
 p_person_id       in number,
 p_mass_salary_id  in number,
 p_sel_flg         in varchar2,
 p_first_action_la_code1 in varchar2,
 p_first_action_la_code2 in varchar2,
 p_remark_code1 in varchar2,
 p_remark_code2 in varchar2,
 p_grade_or_level in varchar2,
 p_step_or_rate in varchar2,
 p_pay_plan     in varchar2,
 p_pay_rate_determinant in varchar2,
 p_tenure in varchar2,
 p_action in varchar2,
 p_assignment_id in number,
 p_old_other_pay in number,
 p_new_other_pay in number,
   -- Bug#2383992
 p_old_capped_other_pay in number,
 p_new_capped_other_pay in number,
 p_old_retention_allowance in number,
 p_new_retention_allowance in number,
 p_old_supervisory_differential in number,
 p_new_supervisory_differential in number,
 p_organization_name            in varchar2,
 -- Bug#2383992
 p_increase_percent in number default null,
 -- FWFA Changes Bug#4444609
 p_input_pay_rate_determinant in varchar2,
 p_from_pay_table_id  number,
 p_to_pay_table_id  number
 -- FWFA Changes
 );

procedure get_lac_dtls
            (p_pa_request_id  in number,
             p_sf52_rec       out nocopy ghr_pa_requests%rowtype);

procedure create_lac_remarks
            (p_pa_request_id  in number,
             p_new_pa_request_id  in number);

procedure upd_ext_info_to_null(p_effective_date in date);

PROCEDURE assign_to_sf52_rec(
 p_person_id              in number,
 p_first_name             in varchar2,
 p_last_name              in varchar2,
 p_middle_names           in varchar2,
 p_national_identifier    in varchar2,
 p_date_of_birth          in date,
 p_effective_date         in date,
 p_assignment_id          in number,
 p_tenure                 in varchar2,
  -- Bug#5089732 Added to_grade_id, to_pay_plan,to_grade_or_level parameters.
 p_to_grade_id            in number,
 p_to_pay_plan            in varchar2,
 p_to_grade_or_level      in varchar2,
 -- Bug35089732
 p_step_or_rate           in varchar2,
 p_annuitant_indicator    in varchar2,
 p_pay_rate_determinant   in varchar2,
 p_work_schedule          in varchar2,
 p_part_time_hour         in varchar2,
 p_flsa_category          in varchar2,
 p_bargaining_unit_status in varchar2,
 p_functional_class       in varchar2,
 p_supervisory_status     in varchar2,
 p_basic_pay              in number,
 p_to_locality_adj        in number,
 p_to_adj_basic_pay       in number,
 p_to_total_salary        in number,
 p_from_other_pay_amount  in number,
 p_to_other_pay_amount    in number,
 p_to_au_overtime         in number,
 p_to_availability_pay    in number,
 p_to_retention_allowance in number,
 p_to_retention_allow_perce in number,
 p_to_supervisory_differential in number,
 p_to_supervisory_diff_perce in number,
 p_to_staffing_differential in number,
 p_duty_station_id        in number,
 p_duty_station_code      in ghr_pa_requests.duty_station_code%type,
 p_duty_station_desc      in ghr_pa_requests.duty_station_desc%type,
 -- FWFA Changes Bug#4444609
 p_input_pay_rate_determinant in ghr_pa_requests.input_pay_rate_determinant%type,
 p_from_pay_table_id       in ghr_pa_requests.from_pay_table_identifier%type,
 p_to_pay_table_id         in ghr_pa_requests.to_pay_table_identifier%type,
 -- FWFA Changes
 p_lac_sf52_rec           in ghr_pa_requests%rowtype,
 p_sf52_rec               out nocopy ghr_pa_requests%rowtype);

procedure pr (msg varchar2,par1 in varchar2 default null,
            par2 in varchar2 default null);

PROCEDURE set_ses_msl_process(ses_flag varchar2);

--added for 5470182
PROCEDURE  execute_msl_ses_range (p_errbuf out nocopy varchar2,
                                  p_retcode out nocopy number,
                                  p_mass_salary_id in number,
                                  p_action in varchar2);


PROCEDURE  fetch_and_validate_emp_ses(
                              p_action              IN VARCHAR2
                             ,p_mass_salary_id      IN NUMBER
                             ,p_mass_salary_name    IN VARCHAR2
                             ,p_full_name           IN per_people_f.full_name%TYPE
			     ,p_national_identifier IN per_people_f.national_identifier%TYPE
                             ,p_assignment_id       IN per_assignments_f.assignment_id%TYPE
			     ,p_person_id           IN per_assignments_f.person_id%TYPE
			     ,p_position_id                IN per_assignments_f.position_id%TYPE
			     ,p_grade_id                   IN per_assignments_f.grade_id%TYPE
			     ,p_business_group_id          IN per_assignments_f.business_group_iD%TYPE
			     ,p_location_id                IN per_assignments_f.location_id%TYPE
			     ,p_organization_id            IN per_assignments_f.organization_id%TYPE
                             ,p_msl_organization_id        IN per_assignments_f.organization_id%TYPE
                             ,p_msl_duty_station_id        IN ghr_duty_stations_f.duty_station_id%TYPE
                             ,p_msl_personnel_office_id    IN VARCHAR2
                             ,p_msl_agency_code_subelement IN VARCHAR2
                             ,p_msl_user_table_id          IN NUMBER
                             ,p_rec_pp_prd                 IN pp_prd
                             ,p_personnel_office_id OUT NOCOPY VARCHAR2
                             ,p_org_structure_id    OUT NOCOPY VARCHAR2
                             ,p_position_title      OUT NOCOPY VARCHAR2
                             ,p_position_number     OUT NOCOPY VARCHAR2
                             ,p_position_seq_no     OUT NOCOPY VARCHAR2
                             ,p_subelem_code        OUT NOCOPY VARCHAR2
                             ,p_duty_station_id     OUT NOCOPY ghr_duty_stations_f.duty_station_id%TYPE
                             ,p_tenure              OUT NOCOPY VARCHAR2
                             ,p_annuitant_indicator OUT NOCOPY VARCHAR2
                             ,p_pay_rate_determinant OUT NOCOPY VARCHAR2
                             ,p_work_schedule       OUT NOCOPY  VARCHAR2
                             ,p_part_time_hour      OUT NOCOPY VARCHAR2
                             ,p_to_grade_id         OUT NOCOPY per_assignments_f.grade_id%type
                             ,p_pay_plan            OUT NOCOPY VARCHAR2
                             ,p_to_pay_plan         OUT NOCOPY VARCHAR2
                             ,p_pay_table_id        OUT NOCOPY NUMBER
                             ,p_grade_or_level      OUT NOCOPY VARCHAR2
                             ,p_to_grade_or_level   OUT NOCOPY VARCHAR2
                             ,p_step_or_rate        OUT NOCOPY VARCHAR2
                             ,p_pay_basis           OUT NOCOPY VARCHAR2
                             ,p_elig_flag           OUT NOCOPY BOOLEAN
	                );

function check_select_flg_ses(p_person_id in number,
                              p_action in varchar2,
                              p_effective_date in date,
                              p_mass_salary_id in number,
                              p_sel_flg in out nocopy varchar2,
			      p_ses_basic_pay in out nocopy number
			     ) return boolean;



END GHR_MSL_PKG;

/
