--------------------------------------------------------
--  DDL for Package GHR_MRE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_MRE_PKG" AUTHID CURRENT_USER AS
/* $Header: ghmreexe.pkh 120.0.12010000.1 2008/07/28 10:33:03 appldev ship $ */

  mass_error    EXCEPTION;


PROCEDURE execute_mre (p_errbuf  out NOCOPY varchar2,
                       p_retcode out NOCOPY number,
                       p_mass_realignment_id in number,
                       p_action in varchar2,
                       p_show_vacant_pos in varchar2 default 'NO');

procedure purge_processed_recs(p_session_id in number,
                               p_err_buf out NOCOPY varchar2);

procedure pop_dtls_from_pa_req(p_person_id in number,p_effective_date in date,
         p_mass_realignment_id in number);

function check_select_flg(p_position_id in number,
                          p_action in varchar2,
                          p_effective_date in date,
                          p_mre_id        in number,
                          p_sel_flg in out NOCOPY varchar2)
return boolean;

procedure ins_upd_pos_extra_info
               (p_position_id in number,p_effective_date in date,
                p_sel_flag in varchar2, p_comment in varchar2,
                p_mre_id in number);


procedure purge_old_data (p_mass_session_id in number);

/*
PROCEDURE get_duty_station_id (p_duty_station_code IN ghr_duty_stations_v.duty_station_code%TYPE
                               ,p_effective_date    IN     DATE
                               ,p_duty_station_id   OUT     ghr_duty_stations_v.duty_station_id%TYPE);
*/

procedure update_sel_flg (p_position_id in number,p_effective_date in date);

FUNCTION check_eligibility(p_org_structure_id in varchar2,
                           p_office_symbol    in varchar2,
                           p_personnel_office_id in varchar2,
                           p_agency_sub_element_code in varchar2,
                           p_l_org_structure_id in varchar2,
                           p_l_office_symbol    in varchar2,
                           p_l_personnel_office_id in varchar2,
                           p_l_agency_sub_element_code in varchar2,
                           p_person_id in number,
                           p_effective_date in date,
                           p_action in varchar2)
return boolean;

function person_in_pa_req_1noa
          (p_person_id      in number,
           p_effective_date in date,
           p_first_noa_code in varchar2
           )
  return boolean;

function person_in_pa_req_2noa
          (p_person_id      in number,
           p_effective_date in date,
           p_second_noa_code in varchar2
           )
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
                            p_appropriation_code2 out NOCOPY varchar2);
          --                  p_pos_ei_data     OUT per_position_extra_info%rowtype);

procedure get_new_org_dtls( p_mass_realignment_id in number,
                            p_position_id         in number,
                            p_effective_date      in date,
                            p_personnel_office_id in out NOCOPY varchar2,
                            p_sub_element_code    in out NOCOPY varchar2,
                            p_duty_station_id     in out NOCOPY number,
                            p_duty_station_code   in out NOCOPY varchar2,
                            p_duty_station_desc   in out NOCOPY varchar2,
                            p_duty_station_locn_id in out NOCOPY number,
                            p_office_symbol       in out NOCOPY varchar2,
                            p_payroll_office_id   in out NOCOPY varchar2,
                            p_org_func_code       in out NOCOPY varchar2,
                            p_appropriation_code1 in out NOCOPY varchar2,
                            p_appropriation_code2 in out NOCOPY varchar2,
                            p_position_organization in out NOCOPY varchar2);

PROCEDURE GET_FIELD_DESC (p_agency_code        in varchar2,
                          p_to_agency_code     in varchar2,
                          p_approp_code1       in varchar2,
                          p_approp_code2       in varchar2,
                          p_pay_plan           in varchar2,
                          p_poi_code           in varchar2,
                          p_to_poi_code        in varchar2,
                          p_org_id             in number,
                          p_to_org_id          in number,

                          p_agency_desc        out NOCOPY varchar2,
                          p_to_agency_desc     out NOCOPY varchar2,
                          p_approp_code1_desc  out NOCOPY varchar2,
                          p_approp_code2_desc  out NOCOPY varchar2,
                          p_pay_plan_desc      out NOCOPY varchar2,
                          p_poi_name           out NOCOPY varchar2,
                          p_to_poi_name        out NOCOPY varchar2,
                          p_org_name           out NOCOPY varchar2,
                          p_to_org_name        out NOCOPY varchar2);

FUNCTION GET_FND_COMMON_LOOKUP
                (p_lookup_code in varchar2,
                 p_type in varchar2) RETURN VARCHAR2;

function get_mre_name(p_mre_id in number) return varchar2;

FUNCTION GET_PP_NAME (PP IN VARCHAR2) RETURN VARCHAR2;
FUNCTION GET_POI_NAME (P_POI IN VARCHAR2) RETURN VARCHAR2;

FUNCTION get_organization_name (p_org_id in number) RETURN varchar2;

PROCEDURE get_extra_info_comments
                (p_position_id in number,
                 p_effective_date in date,
                 p_sel_flag    in out NOCOPY varchar2,
                 p_comments    in out NOCOPY varchar2,
                 p_mre_id      in out NOCOPY number);

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
 p_mass_realignment_id  in number,
 p_sel_flg         in varchar2,
 p_grade_or_level in varchar2,
 p_step_or_rate in varchar2,
 p_pay_plan     in varchar2,
 p_occ_series in varchar2,
 p_office_symbol in varchar2,
 p_organization_id   in number,
 p_organization_name in varchar2,
 p_positions_organization in varchar2,
 t_personnel_office_id in varchar2,
 t_sub_element_code  in varchar2,
 t_duty_station_id  in number,
 t_duty_station_code  in varchar2,
 t_duty_station_desc  in varchar2,
 t_office_symbol  in varchar2,
 t_payroll_office_id  in varchar2,
 t_org_func_code in varchar2,
 t_appropriation_code1 in varchar2,
 t_appropriation_code2 in varchar2,
 t_position_organization in varchar2,
 p_action in varchar2,
 p_assignment_id in number,
 p_pay_rate_determinant in varchar2);


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
 p_duty_station_locn_id   in number,
 p_duty_station_code      in ghr_pa_requests.duty_station_code%type,
 p_duty_station_desc      in ghr_pa_requests.duty_station_desc%type,
 p_office_symbol          in varchar2,
 p_payroll_office_id      in varchar2,
 p_org_func_code          in varchar2,
 p_appropriation_code1    in varchar2,
 p_appropriation_code2    in varchar2,
 p_position_organization  in varchar2,
 p_lac_sf52_rec           in         ghr_pa_requests%rowtype,
 p_sf52_rec               out NOCOPY ghr_pa_requests%rowtype);

procedure upd_ext_info_to_null(p_position_id in number, p_effective_date in date);

PROCEDURE upd_ext_info_api (p_position_id in number,
                            info5 in varchar2,
                            info6 in varchar2,
                            info7 in varchar2,
                            info8 in varchar2,
                            info9 in varchar2,
                            info10 in varchar2,
                            info11 in varchar2,
                            info12 in varchar2,
                            info13 in varchar2,
                            info18 in varchar2,
                            p_effective_date in date);

procedure pr (msg varchar2,par1 in varchar2 default null,
            par2 in varchar2 default null);

END GHR_MRE_PKG;


/
