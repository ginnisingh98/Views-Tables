--------------------------------------------------------
--  DDL for Package GHR_MTO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_MTO_PKG" AUTHID CURRENT_USER AS
/* $Header: ghmtoexe.pkh 120.0.12010000.1 2008/07/28 10:33:25 appldev ship $ */

  mass_error    EXCEPTION;


PROCEDURE execute_mto (p_errbuf out NOCOPY varchar2,
                       p_retcode out NOCOPY number,
                       p_mass_transfer_id in number,
                       p_action in varchar2,
                       p_show_vacant_pos in varchar2 default 'NO');

procedure purge_processed_recs(p_session_id in number,
                               p_err_buf out NOCOPY varchar2);

/*
PROCEDURE get_duty_station_id (p_duty_station_code IN ghr_duty_stations_v.duty_station_code%TYPE
                               ,p_effective_date    IN     DATE
                               ,p_duty_station_id   OUT     ghr_duty_stations_v.duty_station_id%TYPE);
*/

procedure pop_dtls_from_pa_req(p_person_id in number,p_effective_date in date,
         p_mass_transfer_id in number);


function check_select_flg(p_position_id in number,
                          p_action in varchar2,
                          p_effective_date in date,
                          p_mtfr_id      in number,
                          p_sel_flg in out NOCOPY varchar2)
return boolean;

procedure purge_old_data (p_mass_transfer_id in number);

procedure ins_upd_pos_extra_info
               (p_position_id in number,p_effective_date in date,
                p_sel_flag in varchar2, p_comment in varchar2,
                p_mtfr_id in number);

procedure update_sel_flg (p_position_id in number,p_effective_date in date);

FUNCTION check_eligibility(p_org_structure_id in varchar2,
                           p_office_symbol    in varchar2,
                           p_personnel_office_id in varchar2,
                           p_agency_sub_element_code in varchar2,
                           p_duty_station_id in number,
                           p_l_org_structure_id in varchar2,
                           p_l_office_symbol    in varchar2,
                           p_l_personnel_office_id in varchar2,
                           p_l_agency_sub_element_code in varchar2,
                           p_l_duty_station_id in number,
                           p_occ_series_code   in varchar2,
                           p_mass_transfer_id in number,
                           p_action in varchar2,
                           p_effective_date in date,
                           p_person_id in number,
                           p_assign_type in varchar2 default 'ASSIGNED')
return boolean;


procedure get_pos_grp1_ddf (p_position_id in per_assignments_f.position_id%type,
                            p_effective_date in date,
                            p_personnel_office_id out NOCOPY varchar2,
                            p_org_structure_id    out NOCOPY varchar2,
                            p_office_symbol       out NOCOPY varchar2,
                            p_position_organization out NOCOPY varchar2,
                            p_pos_ei_data     OUT NOCOPY per_position_extra_info%rowtype);

procedure get_pos_grp2_ddf (p_position_id in per_assignments_f.position_id%type,
                            p_effective_date in date,
                            p_org_func_code out NOCOPY varchar2,
                            p_appropriation_code1 out NOCOPY varchar2,
                            p_appropriation_code2 out NOCOPY varchar2,
                            p_pos_ei_data     OUT NOCOPY per_position_extra_info%rowtype);

PROCEDURE get_extra_info_comments
                (p_position_id in number,
                 p_effective_date in date,
                 p_sel_flag    in out NOCOPY varchar2,
                 p_comments    in out NOCOPY varchar2,
                 p_mtfr_id  in out NOCOPY number);

procedure create_mass_act_prev (
 p_effective_date in date,
 p_date_of_birth in date,
 p_full_name in varchar2,
 p_national_identifier in varchar2,
 p_duty_station_code in varchar2,
 p_duty_station_desc in varchar2,
 p_personnel_office_id in varchar2,
 p_position_id in per_assignments_f.position_id%type,
 p_position_title in varchar2,
 p_position_number  in varchar2,
 p_position_seq_no  in varchar2,
 p_org_structure_id in varchar2,
 p_agency_sub_element_code in varchar2,
 p_person_id       in number,
 p_mass_transfer_id  in number,
 p_sel_flg         in varchar2,
 p_grade_or_level in varchar2,
 p_step_or_rate in varchar2,
 p_pay_plan     in varchar2,
 p_occ_series in varchar2,
 p_office_symbol in varchar2,
 p_organization_id   in number,
 p_organization_name in varchar2,
 p_positions_organization in varchar2 default null,
 t_personnel_office_id in varchar2 default null,
 t_sub_element_code  in varchar2 default null,
 t_duty_station_id  in number default null,
 t_duty_station_code  in varchar2 default null,
 t_duty_station_desc  in varchar2 default null,
 t_office_symbol  in varchar2 default null,
 t_payroll_office_id  in varchar2 default null,
 t_org_func_code in varchar2 default null,
 t_appropriation_code1 in varchar2 default null,
 t_appropriation_code2 in varchar2 default null,
 t_position_organization in varchar2 default null,
 p_to_agency_code        in varchar2,
 p_tenure               in varchar2,
 p_pay_rate_determinant in varchar2,
 p_action in varchar2,
 p_assignment_id in number);


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
 p_personnel_office_id    in varchar2,
 p_sub_element_code       in varchar2,
 p_duty_station_id        in number,
 p_duty_station_code      in ghr_pa_requests.duty_station_code%type,
 p_duty_station_desc      in ghr_pa_requests.duty_station_desc%type,
 p_office_symbol          in varchar2,
 p_payroll_office_id      in varchar2,
 p_org_func_code          in varchar2,
 p_appropriation_code1    in varchar2,
 p_appropriation_code2    in varchar2,
 p_position_organization  in varchar2,
 p_first_noa_information1 in varchar2,
 p_to_position_org_line1  in varchar2,   -- AVR
 p_lac_sf52_rec           in ghr_pa_requests%rowtype,
 p_sf52_rec               out NOCOPY ghr_pa_requests%rowtype);

procedure pr (msg varchar2,par1 in varchar2 default null,
            par2 in varchar2 default null);

PROCEDURE get_to_agency (p_person_id in number,
                         p_effective_date in date,
                         p_agency_code out NOCOPY varchar2);

function get_mto_name(p_mto_id in number) return varchar2;

procedure upd_ext_info_to_null(p_position_id in number);

PROCEDURE upd_ext_info_api (p_person_id in number,
                            p_agency_code in varchar2,
                            p_effective_date in date);


END GHR_MTO_PKG;

/
