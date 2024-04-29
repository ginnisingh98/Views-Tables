--------------------------------------------------------
--  DDL for Package GHR_PAR_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_PAR_UPD" AUTHID CURRENT_USER as
/* $Header: ghparrhi.pkh 120.5.12010000.1 2008/07/28 10:35:39 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the record interface for the update
--   process for the specified entity. The role of this process is
--   to update a fully validated row for the HR schema passing back
--   to the calling process, any system generated values (e.g.
--   object version number attribute). This process is the main
--   backbone of the upd business process. The processing of this
--   procedure is as follows:
--   1) The row to be updated is locked and selected into the record
--      structure g_old_rec.
--   2) Because on update parameters which are not part of the update do not
--      have to be defaulted, we need to build up the updated row by
--      converting any system defaulted parameters to their corresponding
--      value.
--   3) The controlling validation process update_validate is then executed
--      which will execute all private and public validation business rule
--      processes.
--   4) The pre_update process is then executed which enables any
--      logic to be processed before the update dml process is executed.
--   5) The update_dml process will physical perform the update dml into the
--      specified entity.
--   6) The post_update process is then executed which enables any
--      logic to be processed after the update dml process.
--
-- Prerequisites:
--   The main parameters to the business process have to be in the record
--   format.
--
-- In Parameters:
--
-- Post Success:
--   The specified row will be fully validated and updated for the specified
--   entity without being committed.
--
-- Post Failure:
--   If an error has occurred, an error message will be supplied with the work
--   rolled back.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_rec        in out nocopy ghr_par_shd.g_rec_type
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the attribute interface for the update
--   process for the specified entity and is the outermost layer. The role
--   of this process is to update a fully validated row into the HR schema
--   passing back to the calling process, any system generated values
--   (e.g. object version number attributes). The processing of this
--   procedure is as follows:
--   1) The attributes are converted into a local record structure by
--      calling the convert_args function.
--   2) After the conversion has taken place, the corresponding record upd
--      interface process is executed.
--   3) OUT parameters are then set to their corresponding record attributes.
--
-- Prerequisites:
--
-- In Parameters:
--
-- Post Success:
--   A fully validated row will be updated for the specified entity
--   without being committed.
--
-- Post Failure:
--   If an error has occurred, an error message will be supplied with the work
--   rolled back.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_pa_request_id                in number,
  p_pa_notification_id           in number           default hr_api.g_number,
  p_noa_family_code              in varchar2         default hr_api.g_varchar2,
  p_routing_group_id             in number           default hr_api.g_number,
  p_proposed_effective_asap_flag in varchar2         default hr_api.g_varchar2,
  p_academic_discipline          in varchar2         default hr_api.g_varchar2,
  p_additional_info_person_id    in number           default hr_api.g_number,
  p_additional_info_tel_number   in varchar2         default hr_api.g_varchar2,
  p_agency_code                  in varchar2         default hr_api.g_varchar2,
  p_altered_pa_request_id        in number           default hr_api.g_number,
  p_annuitant_indicator          in varchar2         default hr_api.g_varchar2,
  p_annuitant_indicator_desc     in varchar2         default hr_api.g_varchar2,
  p_appropriation_code1          in varchar2         default hr_api.g_varchar2,
  p_appropriation_code2          in varchar2         default hr_api.g_varchar2,
  p_approval_date                in date             default hr_api.g_date,
  p_approving_official_full_name in varchar2        default hr_api.g_varchar2,
  p_approving_official_work_titl in varchar2         default hr_api.g_varchar2,
  p_sf50_approval_date        in date             default hr_api.g_date,
  p_sf50_approving_ofcl_full_nam in varchar2         default hr_api.g_varchar2,
  p_sf50_approving_ofcl_work_tit in varchar2         default hr_api.g_varchar2,
  p_authorized_by_person_id      in number           default hr_api.g_number,
  p_authorized_by_title          in varchar2         default hr_api.g_varchar2,
  p_award_amount                 in number           default hr_api.g_number,
  p_award_uom                    in varchar2         default hr_api.g_varchar2,
  p_bargaining_unit_status       in varchar2         default hr_api.g_varchar2,
  p_citizenship                  in varchar2         default hr_api.g_varchar2,
  p_concurrence_date             in date             default hr_api.g_date,
  p_custom_pay_calc_flag         in varchar2         default hr_api.g_varchar2,
  p_duty_station_code            in varchar2         default hr_api.g_varchar2,
  p_duty_station_desc            in varchar2         default hr_api.g_varchar2,
  p_duty_station_id              in number           default hr_api.g_number,
  p_duty_station_location_id     in number           default hr_api.g_number,
  p_education_level              in varchar2         default hr_api.g_varchar2,
  p_effective_date               in date             default hr_api.g_date,
  p_employee_assignment_id       in number           default hr_api.g_number,
  p_employee_date_of_birth       in date             default hr_api.g_date,
  p_employee_dept_or_agency      in varchar2         default hr_api.g_varchar2,
  p_employee_first_name          in varchar2         default hr_api.g_varchar2,
  p_employee_last_name           in varchar2         default hr_api.g_varchar2,
  p_employee_middle_names        in varchar2         default hr_api.g_varchar2,
  p_employee_national_identifier in varchar2         default hr_api.g_varchar2,
  p_fegli                        in varchar2         default hr_api.g_varchar2,
  p_fegli_desc                   in varchar2         default hr_api.g_varchar2,
  p_first_action_la_code1        in varchar2         default hr_api.g_varchar2,
  p_first_action_la_code2        in varchar2         default hr_api.g_varchar2,
  p_first_action_la_desc1        in varchar2         default hr_api.g_varchar2,
  p_first_action_la_desc2        in varchar2         default hr_api.g_varchar2,
  p_first_noa_cancel_or_correct  in varchar2         default hr_api.g_varchar2,
  p_first_noa_code               in varchar2         default hr_api.g_varchar2,
  p_first_noa_desc               in varchar2         default hr_api.g_varchar2,
  p_first_noa_id                 in number           default hr_api.g_number,
  p_first_noa_pa_request_id      in number           default hr_api.g_number,
  p_flsa_category                in varchar2         default hr_api.g_varchar2,
  p_forwarding_address_line1     in varchar2         default hr_api.g_varchar2,
  p_forwarding_address_line2     in varchar2         default hr_api.g_varchar2,
  p_forwarding_address_line3     in varchar2         default hr_api.g_varchar2,
  p_forwarding_country           in varchar2         default hr_api.g_varchar2,
  p_forwarding_country_short_nam in varchar2         default hr_api.g_varchar2,
  p_forwarding_postal_code       in varchar2         default hr_api.g_varchar2,
  p_forwarding_region_2          in varchar2         default hr_api.g_varchar2,
  p_forwarding_town_or_city      in varchar2         default hr_api.g_varchar2,
  p_from_adj_basic_pay           in number           default hr_api.g_number,
  p_from_agency_code             in varchar2         default hr_api.g_varchar2,
  p_from_agency_desc             in varchar2         default hr_api.g_varchar2,
  p_from_basic_pay               in number           default hr_api.g_number,
  p_from_grade_or_level          in varchar2         default hr_api.g_varchar2,
  p_from_locality_adj            in number           default hr_api.g_number,
  p_from_occ_code                in varchar2         default hr_api.g_varchar2,
  p_from_office_symbol           in varchar2         default hr_api.g_varchar2,
  p_from_other_pay_amount        in number           default hr_api.g_number,
  p_from_pay_basis               in varchar2         default hr_api.g_varchar2,
  p_from_pay_plan                in varchar2         default hr_api.g_varchar2,
  -- FWFA Changes Bug#4444609
  p_input_pay_rate_determinant   in varchar2         default hr_api.g_varchar2,
  p_from_pay_table_identifier    in number           default hr_api.g_number,
  -- FWFA Changes
  p_from_position_id             in number           default hr_api.g_number,
  p_from_position_org_line1      in varchar2         default hr_api.g_varchar2,
  p_from_position_org_line2      in varchar2         default hr_api.g_varchar2,
  p_from_position_org_line3      in varchar2         default hr_api.g_varchar2,
  p_from_position_org_line4      in varchar2         default hr_api.g_varchar2,
  p_from_position_org_line5      in varchar2         default hr_api.g_varchar2,
  p_from_position_org_line6      in varchar2         default hr_api.g_varchar2,
  p_from_position_number         in varchar2         default hr_api.g_varchar2,
  p_from_position_seq_no         in number           default hr_api.g_number,
  p_from_position_title          in varchar2         default hr_api.g_varchar2,
  p_from_step_or_rate            in varchar2         default hr_api.g_varchar2,
  p_from_total_salary            in number           default hr_api.g_number,
  p_functional_class             in varchar2         default hr_api.g_varchar2,
  p_notepad                      in varchar2         default hr_api.g_varchar2,
  p_part_time_hours              in number           default hr_api.g_number,
  p_pay_rate_determinant         in varchar2         default hr_api.g_varchar2,
  p_personnel_office_id          in varchar2         default hr_api.g_varchar2,
  p_person_id                    in number           default hr_api.g_number,
  p_position_occupied            in varchar2         default hr_api.g_varchar2,
  p_proposed_effective_date      in date             default hr_api.g_date,
  p_requested_by_person_id       in number           default hr_api.g_number,
  p_requested_by_title           in varchar2         default hr_api.g_varchar2,
  p_requested_date               in date             default hr_api.g_date,
  p_requesting_office_remarks_de in varchar2         default hr_api.g_varchar2,
  p_requesting_office_remarks_fl in varchar2         default hr_api.g_varchar2,
  p_request_number               in varchar2         default hr_api.g_varchar2,
  p_resign_and_retire_reason_des in varchar2         default hr_api.g_varchar2,
  p_retirement_plan              in varchar2         default hr_api.g_varchar2,
  p_retirement_plan_desc         in varchar2         default hr_api.g_varchar2,
  p_second_action_la_code1       in varchar2         default hr_api.g_varchar2,
  p_second_action_la_code2       in varchar2         default hr_api.g_varchar2,
  p_second_action_la_desc1       in varchar2         default hr_api.g_varchar2,
  p_second_action_la_desc2       in varchar2         default hr_api.g_varchar2,
  p_second_noa_cancel_or_correct in varchar2         default hr_api.g_varchar2,
  p_second_noa_code              in varchar2         default hr_api.g_varchar2,
  p_second_noa_desc              in varchar2         default hr_api.g_varchar2,
  p_second_noa_id                in number           default hr_api.g_number,
  p_second_noa_pa_request_id     in number           default hr_api.g_number,
  p_service_comp_date            in date             default hr_api.g_date,
  p_status                       in varchar2         default hr_api.g_varchar2,
  p_supervisory_status           in varchar2         default hr_api.g_varchar2,
  p_tenure                       in varchar2         default hr_api.g_varchar2,
  p_to_adj_basic_pay             in number           default hr_api.g_number,
  p_to_basic_pay                 in number           default hr_api.g_number,
  p_to_grade_id                  in number           default hr_api.g_number,
  p_to_grade_or_level            in varchar2         default hr_api.g_varchar2,
  p_to_job_id                    in number           default hr_api.g_number,
  p_to_locality_adj              in number           default hr_api.g_number,
  p_to_occ_code                  in varchar2         default hr_api.g_varchar2,
  p_to_office_symbol             in varchar2         default hr_api.g_varchar2,
  p_to_organization_id           in number           default hr_api.g_number,
  p_to_other_pay_amount          in number           default hr_api.g_number,
  p_to_au_overtime               in number           default hr_api.g_number,
  p_to_auo_premium_pay_indicator in varchar2         default hr_api.g_varchar2,
  p_to_availability_pay          in number           default hr_api.g_number,
  p_to_ap_premium_pay_indicator  in varchar2         default hr_api.g_varchar2,
  p_to_retention_allowance       in number           default hr_api.g_number,
  p_to_supervisory_differential  in number           default hr_api.g_number,
  p_to_staffing_differential     in number           default hr_api.g_number,
  p_to_pay_basis                 in varchar2         default hr_api.g_varchar2,
  p_to_pay_plan                  in varchar2         default hr_api.g_varchar2,
  -- FWFA Changes Bug#4444609
  p_to_pay_table_identifier      in number           default hr_api.g_number,
  -- FWFA Changes
  p_to_position_id               in number           default hr_api.g_number,
  p_to_position_org_line1        in varchar2         default hr_api.g_varchar2,
  p_to_position_org_line2        in varchar2         default hr_api.g_varchar2,
  p_to_position_org_line3        in varchar2         default hr_api.g_varchar2,
  p_to_position_org_line4        in varchar2         default hr_api.g_varchar2,
  p_to_position_org_line5        in varchar2         default hr_api.g_varchar2,
  p_to_position_org_line6        in varchar2         default hr_api.g_varchar2,
  p_to_position_number           in varchar2         default hr_api.g_varchar2,
  p_to_position_seq_no           in number           default hr_api.g_number,
  p_to_position_title            in varchar2         default hr_api.g_varchar2,
  p_to_step_or_rate              in varchar2         default hr_api.g_varchar2,
  p_to_total_salary              in number           default hr_api.g_number,
  p_veterans_preference          in varchar2         default hr_api.g_varchar2,
  p_veterans_pref_for_rif        in varchar2         default hr_api.g_varchar2,
  p_veterans_status              in varchar2         default hr_api.g_varchar2,
  p_work_schedule                in varchar2         default hr_api.g_varchar2,
  p_work_schedule_desc           in varchar2         default hr_api.g_varchar2,
  p_year_degree_attained         in number           default hr_api.g_number,
  p_first_noa_information1       in varchar2         default hr_api.g_varchar2,
  p_first_noa_information2       in varchar2         default hr_api.g_varchar2,
  p_first_noa_information3       in varchar2         default hr_api.g_varchar2,
  p_first_noa_information4       in varchar2         default hr_api.g_varchar2,
  p_first_noa_information5       in varchar2         default hr_api.g_varchar2,
  p_second_lac1_information1     in varchar2         default hr_api.g_varchar2,
  p_second_lac1_information2     in varchar2         default hr_api.g_varchar2,
  p_second_lac1_information3     in varchar2         default hr_api.g_varchar2,
  p_second_lac1_information4     in varchar2         default hr_api.g_varchar2,
  p_second_lac1_information5     in varchar2         default hr_api.g_varchar2,
  p_second_lac2_information1     in varchar2         default hr_api.g_varchar2,
  p_second_lac2_information2     in varchar2         default hr_api.g_varchar2,
  p_second_lac2_information3     in varchar2         default hr_api.g_varchar2,
  p_second_lac2_information4     in varchar2         default hr_api.g_varchar2,
  p_second_lac2_information5     in varchar2         default hr_api.g_varchar2,
  p_second_noa_information1      in varchar2         default hr_api.g_varchar2,
  p_second_noa_information2      in varchar2         default hr_api.g_varchar2,
  p_second_noa_information3      in varchar2         default hr_api.g_varchar2,
  p_second_noa_information4      in varchar2         default hr_api.g_varchar2,
  p_second_noa_information5      in varchar2         default hr_api.g_varchar2,
  p_first_lac1_information1      in varchar2         default hr_api.g_varchar2,
  p_first_lac1_information2      in varchar2         default hr_api.g_varchar2,
  p_first_lac1_information3      in varchar2         default hr_api.g_varchar2,
  p_first_lac1_information4      in varchar2         default hr_api.g_varchar2,
  p_first_lac1_information5      in varchar2         default hr_api.g_varchar2,
  p_first_lac2_information1      in varchar2         default hr_api.g_varchar2,
  p_first_lac2_information2      in varchar2         default hr_api.g_varchar2,
  p_first_lac2_information3      in varchar2         default hr_api.g_varchar2,
  p_first_lac2_information4      in varchar2         default hr_api.g_varchar2,
  p_first_lac2_information5      in varchar2         default hr_api.g_varchar2,
  p_attribute_category           in varchar2         default hr_api.g_varchar2,
  p_attribute1                   in varchar2         default hr_api.g_varchar2,
  p_attribute2                   in varchar2         default hr_api.g_varchar2,
  p_attribute3                   in varchar2         default hr_api.g_varchar2,
  p_attribute4                   in varchar2         default hr_api.g_varchar2,
  p_attribute5                   in varchar2         default hr_api.g_varchar2,
  p_attribute6                   in varchar2         default hr_api.g_varchar2,
  p_attribute7                   in varchar2         default hr_api.g_varchar2,
  p_attribute8                   in varchar2         default hr_api.g_varchar2,
  p_attribute9                   in varchar2         default hr_api.g_varchar2,
  p_attribute10                  in varchar2         default hr_api.g_varchar2,
  p_attribute11                  in varchar2         default hr_api.g_varchar2,
  p_attribute12                  in varchar2         default hr_api.g_varchar2,
  p_attribute13                  in varchar2         default hr_api.g_varchar2,
  p_attribute14                  in varchar2         default hr_api.g_varchar2,
  p_attribute15                  in varchar2         default hr_api.g_varchar2,
  p_attribute16                  in varchar2         default hr_api.g_varchar2,
  p_attribute17                  in varchar2         default hr_api.g_varchar2,
  p_attribute18                  in varchar2         default hr_api.g_varchar2,
  p_attribute19                  in varchar2         default hr_api.g_varchar2,
  p_attribute20                  in varchar2         default hr_api.g_varchar2,
  p_first_noa_canc_pa_request_id in number           default hr_api.g_number,
  p_second_noa_canc_pa_request_i in number           default hr_api.g_number,
  p_to_retention_allow_percentag in number           default hr_api.g_number,
  p_to_supervisory_diff_percenta in number           default hr_api.g_number,
  p_to_staffing_diff_percentage  in number           default hr_api.g_number,
  p_award_percentage             in number           default hr_api.g_number,
  p_rpa_type                     in varchar2         default hr_api.g_varchar2,
  p_mass_action_id               in number           default hr_api.g_number,
  p_mass_action_eligible_flag    in varchar2         default hr_api.g_varchar2,
  p_mass_action_select_flag      in varchar2         default hr_api.g_varchar2,
  p_mass_action_comments         in varchar2         default hr_api.g_varchar2,
  -- Bug#   RRR Changes
  p_payment_option               in varchar2         default hr_api.g_varchar2,
  p_award_salary                 in number           default hr_api.g_number,
  -- Bug#   RRR Changes
  p_object_version_number        in out nocopy number
  );
--
end ghr_par_upd;

/
