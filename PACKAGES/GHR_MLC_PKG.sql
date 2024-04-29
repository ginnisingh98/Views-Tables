--------------------------------------------------------
--  DDL for Package GHR_MLC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_MLC_PKG" AUTHID CURRENT_USER AS
/* $Header: ghmlcexe.pkh 120.6.12000000.1 2007/01/18 13:54:27 appldev noship $ */

  mlc_error    EXCEPTION;
  mtc_error    EXCEPTION;

 --------------g_ses_msl_process     VARCHAR2(1);

PROCEDURE execute_mlc (p_errbuf out nocopy varchar2,
                       p_retcode out nocopy number,
                       p_mass_salary_id in number,
                       p_action in varchar2);

PROCEDURE execute_msl_pay (p_errbuf out nocopy varchar2,
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

procedure pop_dtls_from_pa_req(p_person_id in number,
                               p_effective_date in date,
                               p_mass_salary_id in number,
                               p_org_name in varchar2);

FUNCTION GET_PAY_PLAN_NAME (PP IN VARCHAR2) RETURN VARCHAR2;
FUNCTION GET_USER_TABLE_name (P_USER_TABLE_id IN NUMBER) RETURN VARCHAR2;

procedure ins_upd_per_extra_info
               (p_person_id in number,
                p_effective_date in date,
                p_sel_flag in varchar2,
                p_comment in varchar2,
                p_msl_id   in number);

PROCEDURE get_extra_info_comments
                (p_person_id in number,
                 p_effective_date in date,
                 p_sel_flag    in out nocopy varchar2,
                 p_comments    in out nocopy varchar2,
                 p_mass_salary_id in number);

FUNCTION check_init_eligibility(p_duty_station_id in number,
                           p_PERSONNEL_OFFICE_ID in varchar2,
                           p_AGENCY_CODE_SUBELEMENT in varchar2,
                           p_l_duty_station_id in number,
                           p_l_personnel_office_id in varchar2,
                           p_l_sub_element_code in varchar2)
RETURN boolean;

FUNCTION check_eligibility(p_pay_plan        in  varchar2,
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

FUNCTION check_eligibility_mtc(p_pay_plan        in  varchar2,
                           p_person_id in number,
                           p_effective_date in date,
                           p_action in varchar2)
RETURN boolean;

function person_in_pa_req_1noa_mtc
          (p_person_id      in number,
           p_effective_date in date,
           p_first_noa_code in varchar2,
           p_pay_plan       in varchar2,
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

function check_select_flg(p_person_id in number,
                          p_action in varchar2,
                          p_effective_date in date,
                          p_mass_salary_id in number,
                          p_sel_flg in out nocopy varchar2)
return boolean;

procedure purge_old_data (p_mass_salary_id in number);

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
 -- FWFA Changes Bug#4444609
 p_input_pay_rate_determinant in varchar2,
 p_from_pay_table_id in number,
 p_to_pay_table_id   in number
 -- FWFA Changes
 );


procedure create_mass_act_prev_mtc (
 p_effective_date in date,
 p_date_of_birth in date,
 p_full_name in varchar2,
 p_national_identifier in varchar2,
 p_duty_station_code in varchar2,
 p_duty_station_desc in varchar2,
 p_personnel_office_id in varchar2,
 p_basic_pay       in number,
 p_new_basic_pay   in number,
 p_adj_basic_pay       in number,
 p_new_adj_basic_pay   in number,
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
 p_old_capped_other_pay in number,
 p_new_capped_other_pay in number,
 p_old_retention_allowance in number,
 p_new_retention_allowance in number,
 p_old_supervisory_differential in number,
 p_new_supervisory_differential in number,
 p_organization_name            in varchar2,
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

procedure upd_ext_info_to_null(p_position_id in NUMBER, p_effective_DATE in DATE);

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

procedure check_select_flg_pos(p_position_id in number,
                          p_action in varchar2,
                          p_effective_date in date,
                          p_msl_id        in number,
                          p_sel_flg in out NOCOPY varchar2);

procedure ins_upd_pos_extra_info
               (p_position_id in number,p_effective_date in date,
                p_sel_flag in varchar2, p_comment in varchar2,
                p_msl_id in number);

PROCEDURE get_extra_info_comments_pos
                (p_position_id in number,
                 p_effective_date in date,
                 p_sel_flag    in out NOCOPY varchar2,
                 p_comments    in out NOCOPY varchar2,
                 p_msl_id      in out NOCOPY number);

procedure position_history_update (p_position_id    IN hr_positions_f.position_id%type,
                                   p_effective_date IN date,
                                   p_table_id       IN pay_user_tables.user_table_id%type,
                                   p_upd_tableid    IN pay_user_tables.user_table_id%type);

procedure pr (msg varchar2,par1 in varchar2 default null,
            par2 in varchar2 default null);

END GHR_MLC_PKG;

 

/
