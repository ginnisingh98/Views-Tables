--------------------------------------------------------
--  DDL for Package Body GHR_SF52_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_SF52_API" AS
/* $Header: ghparapi.pkb 120.8.12010000.7 2009/07/30 05:36:26 utokachi ship $ */
--
-- Package Variables
g_package  varchar2(33)	:= '  ghr_sf52_api.';
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_sf52>--------------------------|
-- ----------------------------------------------------------------------------
procedure create_sf52
 (p_validate                     in boolean   default false,
  p_noa_family_code              in varchar2,
  p_pa_request_id                in out nocopy number,
  p_routing_group_id             in number           default null,
  p_proposed_effective_asap_flag in varchar2         default 'N',
  p_academic_discipline          in varchar2         default null,
  p_additional_info_person_id    in number           default null,
  p_additional_info_tel_number   in varchar2         default null,
  p_altered_pa_request_id        in number           default null,
  p_annuitant_indicator          in varchar2         default null,
  p_annuitant_indicator_desc     in varchar2         default null,
  p_appropriation_code1          in varchar2         default null,
  p_appropriation_code2          in varchar2         default null,
  p_approval_date                in date             default null,
  p_approving_official_full_name in varchar2         default null,
  p_approving_official_work_titl in varchar2         default null,
  p_authorized_by_person_id      in number           default null,
  p_authorized_by_title          in varchar2         default null,
  p_award_amount                 in number           default null,
  p_award_uom                    in varchar2         default null,
  p_bargaining_unit_status       in varchar2         default null,
  p_citizenship                  in varchar2         default null,
  p_concurrence_date             in date             default null,
  p_custom_pay_calc_flag         in varchar2         default null,
  p_duty_station_code            in varchar2         default null,
  p_duty_station_desc            in varchar2         default null,
  p_duty_station_id              in number           default null,
  p_duty_station_location_id     in number           default null,
  p_education_level              in varchar2         default null,
  p_effective_date               in date             default null,
  p_employee_assignment_id       in number           default null,
  p_employee_date_of_birth       in date             default null,
  p_employee_first_name          in varchar2         default null,
  p_employee_last_name           in varchar2         default null,
  p_employee_middle_names        in varchar2         default null,
  p_employee_national_identifier in varchar2         default null,
  p_fegli                        in varchar2         default null,
  p_fegli_desc                   in varchar2         default null,
  p_first_action_la_code1        in varchar2         default null,
  p_first_action_la_code2        in varchar2         default null,
  p_first_action_la_desc1        in varchar2         default null,
  p_first_action_la_desc2        in varchar2         default null,
  p_first_noa_cancel_or_correct  in varchar2         default null,
  p_first_noa_code               in varchar2         default null,
  p_first_noa_desc               in varchar2         default null,
  p_first_noa_id                 in number           default null,
  p_first_noa_pa_request_id      in number           default null,
  p_flsa_category                in varchar2         default null,
  p_forwarding_address_line1     in varchar2         default null,
  p_forwarding_address_line2     in varchar2         default null,
  p_forwarding_address_line3     in varchar2         default null,
  p_forwarding_country           in varchar2         default null,
  p_forwarding_country_short_nam in varchar2         default null,
  p_forwarding_postal_code       in varchar2         default null,
  p_forwarding_region_2          in varchar2         default null,
  p_forwarding_town_or_city      in varchar2         default null,
  p_from_adj_basic_pay           in number           default null,
  p_from_basic_pay               in number           default null,
  p_from_grade_or_level          in varchar2         default null,
  p_from_locality_adj            in number           default null,
  p_from_occ_code                in varchar2         default null,
  p_from_other_pay_amount        in number           default null,
  p_from_pay_basis               in varchar2         default null,
  p_from_pay_plan                in varchar2         default null,
 -- FWFA Changes Bug#4444609
  p_input_pay_rate_determinant      in varchar2         default null,
  p_from_pay_table_identifier    in number           default null,
  -- FWFA Changes
  p_from_position_id             in number           default null,
  p_from_position_org_line1      in varchar2         default null,
  p_from_position_org_line2      in varchar2         default null,
  p_from_position_org_line3      in varchar2         default null,
  p_from_position_org_line4      in varchar2         default null,
  p_from_position_org_line5      in varchar2         default null,
  p_from_position_org_line6      in varchar2         default null,
  p_from_position_number         in varchar2         default null,
  p_from_position_seq_no         in number           default null,
  p_from_position_title          in varchar2         default null,
  p_from_step_or_rate            in varchar2         default null,
  p_from_total_salary            in number           default null,
  p_functional_class             in varchar2         default null,
  p_notepad                      in varchar2         default null,
  p_part_time_hours              in number           default null,
  p_pay_rate_determinant         in varchar2         default null,
  p_person_id                    in number           default null,
  p_position_occupied            in varchar2         default null,
  p_proposed_effective_date      in date             default null,
  p_requested_by_person_id       in number           default null,
  p_requested_by_title           in varchar2         default null,
  p_requested_date               in date             default null,
  p_requesting_office_remarks_de in varchar2         default null,
  p_requesting_office_remarks_fl in varchar2         default null,
  p_request_number               in varchar2         default null,
  p_resign_and_retire_reason_des in varchar2         default null,
  p_retirement_plan              in varchar2         default null,
  p_retirement_plan_desc         in varchar2         default null,
  p_second_action_la_code1       in varchar2         default null,
  p_second_action_la_code2       in varchar2         default null,
  p_second_action_la_desc1       in varchar2         default null,
  p_second_action_la_desc2       in varchar2         default null,
  p_second_noa_cancel_or_correct in varchar2         default null,
  p_second_noa_code              in varchar2         default null,
  p_second_noa_desc              in varchar2         default null,
  p_second_noa_id                in number           default null,
  p_second_noa_pa_request_id     in number           default null,
  p_service_comp_date            in date             default null,
  p_supervisory_status           in varchar2         default null,
  p_tenure                       in varchar2         default null,
  p_to_adj_basic_pay             in number           default null,
  p_to_basic_pay                 in number           default null,
  p_to_grade_id                  in number           default null,
  p_to_grade_or_level            in varchar2         default null,
  p_to_job_id                    in number           default null,
  p_to_locality_adj              in number           default null,
  p_to_occ_code                  in varchar2         default null,
  p_to_organization_id           in number           default null,
  p_to_other_pay_amount          in number           default null,
  p_to_au_overtime               in number           default null,
  p_to_auo_premium_pay_indicator in varchar2         default null,
  p_to_availability_pay          in number           default null,
  p_to_ap_premium_pay_indicator  in varchar2         default null,
  p_to_retention_allowance       in number           default null,
  p_to_supervisory_differential  in number           default null,
  p_to_staffing_differential     in number           default null,
  p_to_pay_basis                 in varchar2         default null,
  p_to_pay_plan                  in varchar2         default null,
  -- FWFA Changes Bug#4444609
  p_to_pay_table_identifier      in number           default null,
  -- FWFA Changes
  p_to_position_id               in number           default null,
  p_to_position_org_line1        in varchar2         default null,
  p_to_position_org_line2        in varchar2         default null,
  p_to_position_org_line3        in varchar2         default null,
  p_to_position_org_line4        in varchar2         default null,
  p_to_position_org_line5        in varchar2         default null,
  p_to_position_org_line6        in varchar2         default null,
  p_to_position_number           in varchar2         default null,
  p_to_position_seq_no           in number           default null,
  p_to_position_title            in varchar2         default null,
  p_to_step_or_rate              in varchar2         default null,
  p_to_total_salary              in number           default null,
  p_veterans_preference          in varchar2         default null,
  p_veterans_pref_for_rif        in varchar2         default null,
  p_veterans_status              in varchar2         default null,
  p_work_schedule                in varchar2         default null,
  p_work_schedule_desc           in varchar2         default null,
  p_year_degree_attained         in number           default null,
  p_first_noa_information1       in varchar2         default null,
  p_first_noa_information2       in varchar2         default null,
  p_first_noa_information3       in varchar2         default null,
  p_first_noa_information4       in varchar2         default null,
  p_first_noa_information5       in varchar2         default null,
  p_second_lac1_information1     in varchar2         default null,
  p_second_lac1_information2     in varchar2         default null,
  p_second_lac1_information3     in varchar2         default null,
  p_second_lac1_information4     in varchar2         default null,
  p_second_lac1_information5     in varchar2         default null,
  p_second_lac2_information1     in varchar2         default null,
  p_second_lac2_information2     in varchar2         default null,
  p_second_lac2_information3     in varchar2         default null,
  p_second_lac2_information4     in varchar2         default null,
  p_second_lac2_information5     in varchar2         default null,
  p_second_noa_information1      in varchar2         default null,
  p_second_noa_information2      in varchar2         default null,
  p_second_noa_information3      in varchar2         default null,
  p_second_noa_information4      in varchar2         default null,
  p_second_noa_information5      in varchar2         default null,
  p_first_lac1_information1      in varchar2         default null,
  p_first_lac1_information2      in varchar2         default null,
  p_first_lac1_information3      in varchar2         default null,
  p_first_lac1_information4      in varchar2         default null,
  p_first_lac1_information5      in varchar2         default null,
  p_first_lac2_information1      in varchar2         default null,
  p_first_lac2_information2      in varchar2         default null,
  p_first_lac2_information3      in varchar2         default null,
  p_first_lac2_information4      in varchar2         default null,
  p_first_lac2_information5      in varchar2         default null,
  p_attribute_category           in varchar2         default null,
  p_attribute1                   in varchar2         default null,
  p_attribute2                   in varchar2         default null,
  p_attribute3                   in varchar2         default null,
  p_attribute4                   in varchar2         default null,
  p_attribute5                   in varchar2         default null,
  p_attribute6                   in varchar2         default null,
  p_attribute7                   in varchar2         default null,
  p_attribute8                   in varchar2         default null,
  p_attribute9                   in varchar2         default null,
  p_attribute10                  in varchar2         default null,
  p_attribute11                  in varchar2         default null,
  p_attribute12                  in varchar2         default null,
  p_attribute13                  in varchar2         default null,
  p_attribute14                  in varchar2         default null,
  p_attribute15                  in varchar2         default null,
  p_attribute16                  in varchar2         default null,
  p_attribute17                  in varchar2         default null,
  p_attribute18                  in varchar2         default null,
  p_attribute19                  in varchar2         default null,
  p_attribute20                  in varchar2         default null,
  p_print_sf50_flag              in varchar2         default 'N',
  p_printer_name                 in varchar2         default null,
  p_print_back_page              in varchar2         default 'Y',
  p_1_attachment_modified_flag   in varchar2         default 'N',
  p_1_approved_flag              in varchar2         default null,
  p_1_user_name_acted_on         in varchar2         default null,
  p_1_action_taken		   in varchar2         default null,
  p_1_approval_status            in varchar2         default null,
  p_2_user_name_routed_to        in varchar2         default null,
  p_2_groupbox_id                in number           default null,
  p_2_routing_list_id            in number           default null,
  p_2_routing_seq_number         in number           default null,
  p_capped_other_pay        in number        default null,
  p_to_retention_allow_percentag in number           default null,
  p_to_supervisory_diff_percenta in number           default null,
  p_to_staffing_diff_percentage  in number           default null,
  p_award_percentage             in number           default null,
  p_rpa_type                     in varchar2         default null,
  p_mass_action_id               in number           default null,
  p_mass_action_eligible_flag    in varchar2         default null,
  p_mass_action_select_flag      in varchar2         default null,
  p_mass_action_comments         in varchar2         default null,
  -- Bug#4486823 RRR Changes
  p_payment_option               in varchar2         default null,
  p_award_salary                 in number           default null,
  -- Bug#4486823 RRR Changes
  p_par_object_version_number     out nocopy number,
  p_1_pa_routing_history_id       out nocopy number,
  p_1_prh_object_version_number   out nocopy number,
  p_2_pa_routing_history_id       out nocopy number,
  p_2_prh_object_version_number   out nocopy number

  )is
  --
  -- Declare cursors and local variables
  --

  l_proc                         varchar2(72) := g_package||'create_sf52';
  l_exists                       boolean      := false;
  l_pa_request_id                ghr_pa_requests.pa_request_id%TYPE;
  l_effective_date               date := trunc(nvl(p_effective_date,sysdate));
  l_from_cop                     ghr_pa_requests.from_other_pay_amount%TYPE;
  l_initiator_flag               ghr_pa_routing_history.initiator_flag%TYPE;
  l_requester_flag               ghr_pa_routing_history.requester_flag%TYPE;
  l_reviewer_flag                ghr_pa_routing_history.reviewer_flag%TYPE;
  l_authorizer_flag              ghr_pa_routing_history.authorizer_flag%TYPE;
  l_approver_flag                ghr_pa_routing_history.approver_flag%TYPE;
  l_approved_flag                ghr_pa_routing_history.approved_flag%TYPE;
  l_personnelist_flag            ghr_pa_routing_history.personnelist_flag%TYPE;
  l_user_name_employee_id        per_people_f.person_id%TYPE;
  l_user_name_emp_first_name     per_people_f.first_name%TYPE;
  l_user_name_emp_last_name      per_people_f.last_name%TYPE;
  l_user_name_emp_middle_names   per_people_f.middle_names%TYPE;
  l_2_routing_seq_number         ghr_pa_routing_history.routing_seq_number%TYPE;
  l_forward_to_name              ghr_groupboxes.name%TYPE;
  l_2_groupbox_id                ghr_pa_routing_history.groupbox_id%TYPE;
  l_2_user_name                  ghr_pa_routing_history.user_name%TYPE;
  l_action_taken                 ghr_pa_routing_history.action_taken%TYPE;
  l_temp                         number(15);
  --l_rec                        ghr_par_shd.g_old_rec%type;
  l_rec                          ghr_pa_requests%rowtype;
  l_rei_rec                      ghr_pa_request_extra_info%rowtype;   -- Temporarily added till wrapper is available
  l_par_object_version_number    ghr_pa_requests.object_version_number%TYPE;
  l_rei_object_version_number    ghr_pa_request_extra_info.object_version_number%TYPE;
  l_pa_request_extra_info_id     ghr_pa_request_extra_info.pa_request_extra_info_id%TYPE;
  l_flag                         varchar2(1);
  l_position_id                  hr_all_positions_f.position_id%type;
  l_employee_id                  per_people_f.person_id%type;
  l_approval_date                date;
  l_approving_official_work_titl ghr_pa_requests.approving_official_work_title%type;
  l_approving_official_full_name ghr_pa_requests.approving_official_full_name%type;
  l_sf50_approval_date           date;
  l_sf50_approving_ofcl_work_tit ghr_pa_requests.sf50_approving_ofcl_work_title%type;
  l_sf50_approving_ofcl_full_nam ghr_pa_requests.sf50_approving_ofcl_full_name%type;
  l_status                       ghr_pa_requests.status%type;
  l_message                      boolean := FALSE;
  l_asg_sf52			   ghr_api.asg_sf52_type;
  l_asg_non_sf52			   ghr_api.asg_non_sf52_type;
  l_asg_nte_dates			   ghr_api.asg_nte_dates_type;
  l_per_sf52			   ghr_api.per_sf52_type;
  l_per_group1			   ghr_api.per_group1_type;
  l_per_group2			   ghr_api.per_group2_type;
  l_per_scd_info			   ghr_api.per_scd_info_type;
  l_per_retained_grade		   ghr_api.per_retained_grade_type;
  l_per_probations		   ghr_api.per_probations_type;
  l_per_sep_retire               ghr_api.per_sep_retire_type;
  l_per_security			   ghr_api.per_security_type;
  l_per_conversions		   ghr_api.per_conversions_type;
  l_per_uniformed_services	   ghr_api.per_uniformed_services_type;
  l_pos_oblig			   ghr_api.pos_oblig_type;
  l_pos_grp2			   ghr_api.pos_grp2_type;
  l_pos_grp1			   ghr_api.pos_grp1_type;
  l_pos_valid_grade		   ghr_api.pos_valid_grade_type;
  l_pos_car_prog			   ghr_api.pos_car_prog_type;
  l_loc_info			   ghr_api.loc_info_type;
  l_wgi				             ghr_api.within_grade_increase_type;
  l_recruitment_bonus		   ghr_api.recruitment_bonus_type;
  l_relocation_bonus		   ghr_api.relocation_bonus_type;

  --Pradeep
  l_mddds_special_pay             ghr_api.mddds_special_pay_type;
  l_sf52_from_data		   ghr_api.prior_sf52_data_type;
  l_personal_info			   ghr_api.personal_info_type;
  l_gov_awards_type		   ghr_api.government_awards_type;
  l_perf_appraisal_type		   ghr_api.performance_appraisal_type;
  l_payroll_type			   ghr_api.government_payroll_type;
  l_conduct_perf_type		   ghr_api.conduct_performance_type;
  l_agency_sf52			   ghr_api.agency_sf52_type;
  l_agency_code			   varchar2(80);
  l_imm_entitlement              ghr_api.entitlement_type;
  l_imm_foreign_lang_prof_pay    ghr_api.foreign_lang_prof_pay_type;
  l_imm_edp_pay                  ghr_api.edp_pay_type;
  l_imm_hazard_pay               ghr_api.hazard_pay_type;
  l_imm_health_benefits          ghr_api.health_benefits_type;
  l_imm_danger_pay               ghr_api.danger_pay_type;
  l_imm_imminent_danger_pay      ghr_api.imminent_danger_pay_type;
  l_imm_living_quarters_allow    ghr_api.living_quarters_allow_type;
  l_imm_post_diff_amt            ghr_api.post_diff_amt_type;
  l_imm_post_diff_percent        ghr_api.post_diff_percent_type;
  l_imm_sep_maintenance_allow    ghr_api.sep_maintenance_allow_type;
  l_imm_supplemental_post_allow  ghr_api.supplemental_post_allow_type;
  l_imm_temp_lodge_allow         ghr_api.temp_lodge_allow_type;
  l_imm_premium_pay              ghr_api.premium_pay_type;
  l_imm_retirement_annuity       ghr_api.retirement_annuity_type;
  l_imm_severance_pay            ghr_api.severance_pay_type;
  l_imm_thrift_saving_plan       ghr_api.thrift_saving_plan;
  l_imm_retention_allow_review   ghr_api.retention_allow_review_type;
  l_imm_health_ben_pre_tax       ghr_api.health_ben_pre_tax_type;
  l_imm_per_benefit_info         ghr_api.per_benefit_info_type;
  l_imm_retirement_info          ghr_api.per_retirement_info_type; --Bug# 7131104

/*  Cursor    C_user_emp_names is
    select  usr.employee_id,
            per.first_name,
            per.last_name,
            per.middle_names
    from    per_people_f per,
            fnd_user     usr
    where   upper(usr.user_name)  =  upper(p_1_user_name_acted_on)
    and     per.person_id         =  usr.employee_id
    and     l_effective_date
    between effective_start_date
    and     effective_end_date; */

	-- Bug 4863608 Perf. repository changes
--8229939 modified to consider sysdate
	CURSOR    c_user_emp_names IS
    SELECT  usr.employee_id,
            per.first_name,
            per.last_name,
            per.middle_names
    FROM    per_people_f per,
            fnd_user     usr
    WHERE   usr.user_name  =  upper(p_1_user_name_acted_on)
    AND     per.person_id         =  usr.employee_id
    AND     trunc(sysdate)
    BETWEEN effective_start_date
    AND     effective_end_date;


	 CURSOR     C_seq_number IS
     SELECT   rlm.seq_number,
              rlm.groupbox_id,
              rlm.user_name
     FROM     ghr_routing_list_members rlm
     WHERE    rlm.routing_list_id = p_2_routing_list_id
     ORDER BY rlm.seq_number ASC;


   CURSOR   c_history_exists IS
     SELECT 1
     FROM   ghr_pa_routing_history prh
     WHERE  prh.pa_request_id = l_pa_request_id;

   CURSOR   c_groupbox_name IS
     SELECT gbx.name
     FROM   ghr_groupboxes gbx
     WHERE  gbx.groupbox_id = l_2_groupbox_id;

    CURSOR   c_ovn  IS
      SELECT par.object_version_number
      FROM   ghr_pa_requests par
      WHERE  par.pa_request_id = l_pa_request_id;

l_capped_other_pay number;
l_assignment_id    ghr_pa_requests.employee_assignment_id%type;
  begin
    hr_utility.set_location('Entering:'|| l_proc, 5);

  -- Issue a savepoint if operating in validation only mode.
--    if p_validate then
      savepoint create_sf52;
--    end if;
  --
  -- Call Before Process User Hook
  --
  begin
	ghr_sf52_bk1.create_sf52_b	(
       p_noa_family_code                  => p_noa_family_code,
       p_pa_request_id                    => p_pa_request_id,
       p_routing_group_id                 => p_routing_group_id,
       p_proposed_effective_asap_flag     => p_proposed_effective_asap_flag,
       p_academic_discipline              => p_academic_discipline,
       p_additional_info_person_id        => p_additional_info_person_id,
       p_additional_info_tel_number       => p_additional_info_tel_number,
       p_altered_pa_request_id            => p_altered_pa_request_id,
       p_annuitant_indicator              => p_annuitant_indicator,
       p_annuitant_indicator_desc         => p_annuitant_indicator_desc,
       p_appropriation_code1              => p_appropriation_code1,
       p_appropriation_code2              => p_appropriation_code2,
       p_approval_date                    => l_approval_date,
       p_approving_official_full_name     => l_approving_official_full_name,
       p_approving_official_work_titl     => l_approving_official_work_titl,
       p_authorized_by_person_id          => p_authorized_by_person_id,
       p_authorized_by_title              => p_authorized_by_title,
       p_award_amount                     => p_award_amount,
       p_award_uom                        => p_award_uom,
       p_bargaining_unit_status           => p_bargaining_unit_status,
       p_citizenship                      => p_citizenship,
       p_concurrence_date                 => p_concurrence_date,
       p_custom_pay_calc_flag             => p_custom_pay_calc_flag,
       p_duty_station_code                => p_duty_station_code,
       p_duty_station_desc                => p_duty_station_desc,
       p_duty_station_location_id         => p_duty_station_location_id,
       p_duty_station_id                  => p_duty_station_id,
       p_education_level                  => p_education_level,
       p_effective_date                   => p_effective_date,
       p_employee_assignment_id           => p_employee_assignment_id,
       p_employee_date_of_birth           => p_employee_date_of_birth,
       p_employee_first_name              => p_employee_first_name,
       p_employee_last_name               => p_employee_last_name,
       p_employee_middle_names            => p_employee_middle_names,
       p_employee_national_identifier     => p_employee_national_identifier,
       p_fegli                            => p_fegli,
       p_fegli_desc                       => p_fegli_desc,
       p_first_action_la_code1            => p_first_action_la_code1,
       p_first_action_la_code2            => p_first_action_la_code2,
       p_first_action_la_desc1            => p_first_action_la_desc1,
       p_first_action_la_desc2            => p_first_action_la_desc2,
       p_first_noa_cancel_or_correct      => p_first_noa_cancel_or_correct,
       p_first_noa_id                     => p_first_noa_id,
       p_first_noa_code                   => p_first_noa_code,
       p_first_noa_desc                   => p_first_noa_desc,
       p_first_noa_pa_request_id          => p_first_noa_pa_request_id,
       p_flsa_category                    => p_flsa_category,
       p_forwarding_address_line1         => p_forwarding_address_line1,
       p_forwarding_address_line2         => p_forwarding_address_line2,
       p_forwarding_address_line3         => p_forwarding_address_line3,
       p_forwarding_country               => p_forwarding_country,
       p_forwarding_country_short_nam     => p_forwarding_country_short_nam,
       p_forwarding_postal_code           => p_forwarding_postal_code,
       p_forwarding_region_2              => p_forwarding_region_2,
       p_forwarding_town_or_city          => p_forwarding_town_or_city ,
       p_from_adj_basic_pay               => p_from_adj_basic_pay,
       p_from_basic_pay                   => p_from_basic_pay,
       p_from_grade_or_level              => p_from_grade_or_level,
       p_from_locality_adj                => p_from_locality_adj,
       p_from_occ_code                    => p_from_occ_code,
       p_from_other_pay_amount            => p_from_other_pay_amount,
       p_from_pay_basis                   => p_from_pay_basis,
       p_from_pay_plan                    => p_from_pay_plan,
       -- FWFA Changes Bug#4444609
       -- p_input_pay_rate_determinant       => p_input_pay_rate_determinant,
       -- p_from_pay_table_identifier        => p_from_pay_table_identifier,
       -- FWFA Changes
       p_from_position_id                 => p_from_position_id,
       p_from_position_org_line1          => p_from_position_org_line1,
       p_from_position_org_line2          => p_from_position_org_line2,
       p_from_position_org_line3          => p_from_position_org_line3,
       p_from_position_org_line4          => p_from_position_org_line4,
       p_from_position_org_line5          => p_from_position_org_line5,
       p_from_position_org_line6          => p_from_position_org_line6,
       p_from_position_number             => p_from_position_number,
       p_from_position_seq_no             => p_from_position_seq_no,
       p_from_position_title              => p_from_position_title,
       p_from_step_or_rate                => p_from_step_or_rate,
       p_from_total_salary                => p_from_total_salary,
       p_functional_class                 => p_functional_class,
       p_notepad                          => p_notepad,
       p_part_time_hours                  => p_part_time_hours,
       p_pay_rate_determinant             => p_pay_rate_determinant,
       p_person_id                        => p_person_id,
       p_position_occupied			      => p_position_occupied,
       p_proposed_effective_date          => p_proposed_effective_date,
       p_requested_by_person_id           => p_requested_by_person_id,
       p_requested_by_title               => p_requested_by_title,
       p_requested_date                   => p_requested_date,
       p_requesting_office_remarks_de     => p_requesting_office_remarks_de,
       p_requesting_office_remarks_fl     => p_requesting_office_remarks_fl,
       p_request_number                   => p_request_number,
       p_resign_and_retire_reason_des     => p_resign_and_retire_reason_des,
       p_retirement_plan                  => p_retirement_plan,
       p_retirement_plan_desc             => p_retirement_plan_desc,
       p_second_action_la_code1           => p_second_action_la_code1,
       p_second_action_la_code2           => p_second_action_la_code2,
       p_second_action_la_desc1           => p_second_action_la_desc1,
       p_second_action_la_desc2           => p_second_action_la_desc2,
       p_second_noa_cancel_or_correct     => p_second_noa_cancel_or_correct,
       p_second_noa_code                  => p_second_noa_code,
       p_second_noa_desc                  => p_second_noa_desc,
       p_second_noa_id                    => p_second_noa_id,
       p_second_noa_pa_request_id         => p_second_noa_pa_request_id,
       p_service_comp_date                => p_service_comp_date,
       p_supervisory_status               => p_supervisory_status,
       p_tenure                           => p_tenure,
       p_to_adj_basic_pay                 => p_to_adj_basic_pay,
       p_to_basic_pay                     => p_to_basic_pay,
       p_to_grade_id                      => p_to_grade_id,
       p_to_grade_or_level                => p_to_grade_or_level,
       p_to_job_id                        => p_to_job_id,
       p_to_locality_adj                  => p_to_locality_adj,
       p_to_occ_code                      => p_to_occ_code,
       p_to_organization_id               => p_to_organization_id,
       p_to_other_pay_amount              => p_to_other_pay_amount,
       p_to_au_overtime                   => p_to_au_overtime,
       p_to_auo_premium_pay_indicator     => p_to_auo_premium_pay_indicator,
       p_to_availability_pay              => p_to_availability_pay,
       p_to_ap_premium_pay_indicator      => p_to_ap_premium_pay_indicator,
       p_to_retention_allowance           => p_to_retention_allowance,
       p_to_supervisory_differential      => p_to_supervisory_differential,
       p_to_staffing_differential         => p_to_staffing_differential,
       p_to_pay_basis                     => p_to_pay_basis,
       p_to_pay_plan                      => p_to_pay_plan,
       -- FWFA Changes Bug#4444609
       -- p_to_pay_table_identifier          => p_to_pay_table_identifier,
       -- FWFA Changes
       p_to_position_id                   => p_to_position_id,
       p_to_position_org_line1            => p_to_position_org_line1,
       p_to_position_org_line2            => p_to_position_org_line2,
       p_to_position_org_line3            => p_to_position_org_line3,
       p_to_position_org_line4            => p_to_position_org_line4,
       p_to_position_org_line5            => p_to_position_org_line5,
       p_to_position_org_line6            => p_to_position_org_line6,
       p_to_position_number               => p_to_position_number,
       p_to_position_seq_no               => p_to_position_seq_no,
       p_to_position_title                => p_to_position_title,
       p_to_step_or_rate                  => p_to_step_or_rate,
       p_to_total_salary                  => p_to_total_salary,
       p_veterans_pref_for_rif            => p_veterans_pref_for_rif,
       p_veterans_preference              => p_veterans_preference,
       p_veterans_status                  => p_veterans_status,
       p_work_schedule                    => p_work_schedule,
       p_work_schedule_desc               => p_work_schedule_desc,
       p_year_degree_attained             => p_year_degree_attained,
       p_first_noa_information1           => p_first_noa_information1,
       p_first_noa_information2           => p_first_noa_information2,
       p_first_noa_information3           => p_first_noa_information3,
       p_first_noa_information4           => p_first_noa_information4,
       p_first_noa_information5           => p_first_noa_information5,
       p_second_lac1_information1         => p_second_lac1_information1,
       p_second_lac1_information2         => p_second_lac1_information2,
       p_second_lac1_information3         => p_second_lac1_information3,
       p_second_lac1_information4         => p_second_lac1_information4,
       p_second_lac1_information5         => p_second_lac1_information5,
       p_second_lac2_information1         => p_second_lac2_information1,
       p_second_lac2_information2         => p_second_lac2_information2,
       p_second_lac2_information3         => p_second_lac2_information3,
       p_second_lac2_information4         => p_second_lac2_information4,
       p_second_lac2_information5         => p_second_lac2_information5,
       p_second_noa_information1          => p_second_noa_information1,
       p_second_noa_information2          => p_second_noa_information2,
       p_second_noa_information3          => p_second_noa_information3,
       p_second_noa_information4          => p_second_noa_information4,
       p_second_noa_information5          => p_second_noa_information5,
       p_first_lac1_information1          => p_first_lac1_information1,
       p_first_lac1_information2          => p_first_lac1_information2,
       p_first_lac1_information3          => p_first_lac1_information3,
       p_first_lac1_information4          => p_first_lac1_information4,
       p_first_lac1_information5          => p_first_lac1_information5,
       p_first_lac2_information1          => p_first_lac2_information1,
       p_first_lac2_information2          => p_first_lac2_information2,
       p_first_lac2_information3          => p_first_lac2_information3,
       p_first_lac2_information4          => p_first_lac2_information4,
       p_first_lac2_information5          => p_first_lac2_information5,
       p_attribute_category               => p_attribute_category,
       p_attribute1                       => p_attribute1,
       p_attribute2                       => p_attribute2,
       p_attribute3                       => p_attribute3,
       p_attribute4                       => p_attribute4,
       p_attribute5                       => p_attribute5,
       p_attribute6                       => p_attribute6,
       p_attribute7                       => p_attribute7,
       p_attribute8                       => p_attribute8,
       p_attribute9                       => p_attribute9,
       p_attribute10                      => p_attribute10,
       p_attribute11                      => p_attribute11,
       p_attribute12                      => p_attribute12,
       p_attribute13                      => p_attribute13,
       p_attribute14                      => p_attribute14,
       p_attribute15                      => p_attribute15,
       p_attribute16                      => p_attribute16,
       p_attribute17                      => p_attribute17,
       p_attribute18                      => p_attribute18,
       p_attribute19                      => p_attribute19,
       p_attribute20                      => p_attribute20,
       p_print_sf50_flag                  => p_print_sf50_flag,
       p_printer_name                     => p_printer_name,
       p_1_attachment_modified_flag       => p_1_attachment_modified_flag,
       p_1_approved_flag                  => p_1_approved_flag,
       p_1_user_name_acted_on             => p_1_user_name_acted_on,
       p_1_action_taken                   => p_1_action_taken,
       p_1_approval_status                => p_1_approval_status,
       p_2_user_name_routed_to            => p_2_user_name_routed_to,
       p_2_groupbox_id                    => p_2_groupbox_id,
       p_2_routing_list_id                => p_2_routing_list_id,
       p_2_routing_seq_number             => p_2_routing_seq_number,
       p_capped_other_pay                 => p_capped_other_pay,
       p_to_retention_allow_percentag     => p_to_retention_allow_percentag,
       p_to_supervisory_diff_percenta     => p_to_supervisory_diff_percenta,
       p_to_staffing_diff_percentage      => p_to_staffing_diff_percentage,
       p_award_percentage                 => p_award_percentage,
       p_rpa_type                         => p_rpa_type,
       p_mass_action_id                   => p_mass_action_id,
       p_mass_action_eligible_flag        => p_mass_action_eligible_flag,
       p_mass_action_select_flag          => p_mass_action_select_flag,
       p_mass_action_comments             => p_mass_action_comments
	);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'create_sf52',
				 p_hook_type	=> 'BP'
				);
  end;
  --
  -- End of Before Process User Hook call
  --
  hr_utility.set_location(l_proc, 6);
  -- Process Logic

  -- If the SF52 is processed for the person same as the user, then do not allow creation

  If p_person_id is not null then
    -- get employee_id of the user
     for user_id in c_user_emp_names loop
       If user_id.employee_id = p_person_id then
         hr_utility.set_message(8301,'GHR_38503_CANNOT_INIT_FOR_SELF');
         hr_utility.raise_error;
        End if;
      end loop;
   End if;

  l_approval_date   :=  p_approval_date;
  l_approving_official_work_titl  :=  p_approving_official_work_titl;
  l_approving_official_full_name  :=  p_approving_official_full_name;

   If nvl(p_1_approval_status,hr_api.g_varchar2) = 'APPROVE' then
     If p_approval_date is null
       then
        hr_utility.set_location('approval date is not null',1);
        l_effective_date  :=  trunc(sysdate);
        l_approval_date   :=  sysdate;
         -- get the full_name of the approver - format First Name MiddleName. Last Name  -- p_user_name_acted_on
         for user_emp_name in c_user_emp_names loop
           l_approving_official_full_name :=  user_emp_name.first_name;
           If user_emp_name.middle_names is not null then
             l_approving_official_full_name := l_approving_official_full_name
                      || ' ' ||substr(user_emp_name.middle_names,1,1) || '.'  || ' ' || user_emp_name.last_name ;
           Else
             l_approving_official_full_name := l_approving_official_full_name || ' ' || user_emp_name.last_name;
           End if;
           l_employee_id                  :=  user_emp_name.employee_id;
        end loop;
        if l_employee_id is not null then
           -- get the working title of the approver  -- would  be as of today
          l_approving_official_work_titl   :=  ghr_pa_requests_pkg.get_position_work_title
                                               (p_person_id          =>  l_employee_id
                                               );
        End if;
     Else
       l_approving_official_work_titl    :=   p_approving_official_work_titl;
       l_approving_official_full_name    :=   p_approving_official_full_name;
       l_approval_date                   :=   p_approval_date;
     End if;
   End if;

  -- Update the SF50 approver details , when the user chooses to 'Update HR' (Immediate or Future)
  -- Derive for individual actions . For Mass Actions they are the same as the SF52 approver details

  If nvl(p_1_action_taken,hr_api.g_varchar2) in ('UPDATE_HR','FUTURE_ACTION') then
    If p_approval_date is not null then
      l_sf50_approval_date  	        :=   p_approval_date;
      l_sf50_approving_ofcl_work_tit    :=   p_approving_official_work_titl;
      l_sf50_approving_ofcl_full_nam    :=   p_approving_official_full_name;
    Else
       l_sf50_approval_date  		    :=   sysdate;
       for user_emp_name in c_user_emp_names loop
           l_sf50_approving_ofcl_full_nam   :=  user_emp_name.first_name;
           If user_emp_name.middle_names is not null then
             l_sf50_approving_ofcl_full_nam := l_sf50_approving_ofcl_full_nam
                      || ' ' ||substr(user_emp_name.middle_names,1,1) || '.'  || ' ' || user_emp_name.last_name ;
           Else
             l_sf50_approving_ofcl_full_nam := l_sf50_approving_ofcl_full_nam || ' ' || user_emp_name.last_name;
           End if;
           l_employee_id                    :=  user_emp_name.employee_id;
        end loop;
        if l_employee_id is not null then
           -- get the working title of the approver  -- would be as of today
          l_sf50_approving_ofcl_work_tit   :=  ghr_pa_requests_pkg.get_position_work_title
                                               (p_person_id            =>  l_employee_id
                                                --p_effective_date     =>  l_effective_date
                                               );
        End if;
    End if;
  End if;



-- Insert a row into pa_requests by calling the ins row handler

    l_pa_request_id   :=   p_pa_request_id;
    l_effective_date  :=   trunc(nvl(p_effective_date,sysdate));
    hr_utility.set_location('appr name ' || l_approving_official_full_name,1);
    hr_utility.set_location('l_effective_date : ' ||l_effective_date, 8);
    hr_utility.set_location('p_noa_family_code : ' ||p_noa_family_code, 8);

    ghr_par_ins.ins
   (
    p_pa_request_id                    => l_pa_request_id,
    p_noa_family_code                  => p_noa_family_code,
    p_routing_group_id                 => p_routing_group_id,
    p_proposed_effective_asap_flag     => p_proposed_effective_asap_flag,
    p_academic_discipline              => p_academic_discipline,
    p_additional_info_person_id        => p_additional_info_person_id,
    p_additional_info_tel_number       => p_additional_info_tel_number,
    p_altered_pa_request_id            => p_altered_pa_request_id,
    p_annuitant_indicator              => p_annuitant_indicator,
    p_annuitant_indicator_desc         => p_annuitant_indicator_desc,
    p_appropriation_code1              => p_appropriation_code1,
    p_appropriation_code2              => p_appropriation_code2,
    p_approval_date                    => l_approval_date,
    p_approving_official_full_name     => l_approving_official_full_name,
    p_approving_official_work_titl     => l_approving_official_work_titl,
    p_sf50_approval_date               => l_sf50_approval_date,
    p_sf50_approving_ofcl_full_nam     => l_sf50_approving_ofcl_full_nam,
    p_sf50_approving_ofcl_work_tit     => l_sf50_approving_ofcl_work_tit,
    p_authorized_by_person_id          => p_authorized_by_person_id,
    p_authorized_by_title              => p_authorized_by_title,
    p_award_amount                     => p_award_amount,
    p_award_uom                        => p_award_uom,
    p_bargaining_unit_status           => p_bargaining_unit_status,
    p_citizenship                      => p_citizenship,
    p_concurrence_date                 => p_concurrence_date,
    p_custom_pay_calc_flag             => p_custom_pay_calc_flag,
    p_duty_station_code                => p_duty_station_code,
    p_duty_station_desc                => p_duty_station_desc,
    p_duty_station_location_id         => p_duty_station_location_id,
    p_duty_station_id                  => p_duty_station_id,
    p_education_level                  => p_education_level,
    p_effective_date                   => p_effective_date,
    p_employee_assignment_id           => p_employee_assignment_id,
    p_employee_date_of_birth           => p_employee_date_of_birth,
    p_employee_first_name              => p_employee_first_name,
    p_employee_last_name               => p_employee_last_name,
    p_employee_middle_names            => p_employee_middle_names,
    p_employee_national_identifier     => p_employee_national_identifier,
    p_fegli                            => p_fegli,
    p_fegli_desc                       => p_fegli_desc,
    p_first_action_la_code1            => p_first_action_la_code1,
    p_first_action_la_code2            => p_first_action_la_code2,
    p_first_action_la_desc1            => p_first_action_la_desc1,
    p_first_action_la_desc2            => p_first_action_la_desc2,
    p_first_noa_cancel_or_correct      => p_first_noa_cancel_or_correct,
    p_first_noa_id                     => p_first_noa_id,
    p_first_noa_code                   => p_first_noa_code,
    p_first_noa_desc                   => p_first_noa_desc,
    p_first_noa_pa_request_id          => p_first_noa_pa_request_id,
    p_flsa_category                    => p_flsa_category,
    p_forwarding_address_line1         => p_forwarding_address_line1,
    p_forwarding_address_line2         => p_forwarding_address_line2,
    p_forwarding_address_line3         => p_forwarding_address_line3,
    p_forwarding_country               => p_forwarding_country,
    p_forwarding_country_short_nam     => p_forwarding_country_short_nam,
    p_forwarding_postal_code           => p_forwarding_postal_code,
    p_forwarding_region_2              => p_forwarding_region_2,
    p_forwarding_town_or_city          => p_forwarding_town_or_city ,
    p_from_adj_basic_pay               => p_from_adj_basic_pay,
    p_from_basic_pay                   => p_from_basic_pay,
    p_from_grade_or_level              => p_from_grade_or_level,
    p_from_locality_adj                => p_from_locality_adj,
    p_from_occ_code                    => p_from_occ_code,
 -- Bug 2353506
    p_from_other_pay_amount            =>  nvl(ghr_pa_requests_pkg2.get_cop
                     (p_employee_assignment_id, p_effective_date),
                       p_from_other_pay_amount),
 -- End Bug 2353506
    p_from_pay_basis                   => p_from_pay_basis,
    p_from_pay_plan                    => p_from_pay_plan,
    -- FWFA Changes Bug#4444609
    p_input_pay_rate_determinant          => p_input_pay_rate_determinant,
    p_from_pay_table_identifier        => p_from_pay_table_identifier,
    -- FWFA Changes
    p_from_position_id                 => p_from_position_id,
    p_from_position_org_line1          => p_from_position_org_line1,
    p_from_position_org_line2          => p_from_position_org_line2,
    p_from_position_org_line3          => p_from_position_org_line3,
    p_from_position_org_line4          => p_from_position_org_line4,
    p_from_position_org_line5          => p_from_position_org_line5,
    p_from_position_org_line6          => p_from_position_org_line6,
    p_from_position_number             => p_from_position_number,
    p_from_position_seq_no             => p_from_position_seq_no,
    p_from_position_title              => p_from_position_title,
    p_from_step_or_rate                => p_from_step_or_rate,
    p_from_total_salary                => p_from_total_salary,
    p_functional_class                 => p_functional_class,
    p_notepad                          => p_notepad,
    p_part_time_hours                  => p_part_time_hours,
    p_pay_rate_determinant             => p_pay_rate_determinant,
    p_person_id                        => p_person_id,
    p_position_occupied			       => p_position_occupied,
    p_proposed_effective_date          => p_proposed_effective_date,
    p_requested_by_person_id           => p_requested_by_person_id,
    p_requested_by_title               => p_requested_by_title,
    p_requested_date                   => p_requested_date,
    p_requesting_office_remarks_de     => p_requesting_office_remarks_de,
    p_requesting_office_remarks_fl     => p_requesting_office_remarks_fl,
    p_request_number                   => p_request_number,
    p_resign_and_retire_reason_des     => p_resign_and_retire_reason_des,
    p_retirement_plan                  => p_retirement_plan,
    p_retirement_plan_desc             => p_retirement_plan_desc,
    p_second_action_la_code1           => p_second_action_la_code1,
    p_second_action_la_code2           => p_second_action_la_code2,
    p_second_action_la_desc1           => p_second_action_la_desc1,
    p_second_action_la_desc2           => p_second_action_la_desc2,
    p_second_noa_cancel_or_correct     => p_second_noa_cancel_or_correct,
    p_second_noa_code                  => p_second_noa_code,
    p_second_noa_desc                  => p_second_noa_desc,
    p_second_noa_id                    => p_second_noa_id,
    p_second_noa_pa_request_id         => p_second_noa_pa_request_id,
    p_service_comp_date                => p_service_comp_date,
    p_supervisory_status               => p_supervisory_status,
    p_tenure                           => p_tenure,
    p_to_adj_basic_pay                 => p_to_adj_basic_pay,
    p_to_basic_pay                     => p_to_basic_pay,
    p_to_grade_id                      => p_to_grade_id,
    p_to_grade_or_level                => p_to_grade_or_level,
    p_to_job_id                        => p_to_job_id,
    p_to_locality_adj                  => p_to_locality_adj,
    p_to_occ_code                      => p_to_occ_code,
    p_to_organization_id               => p_to_organization_id,
 -- Bug 2353506
    p_to_other_pay_amount              => nvl(p_capped_other_pay,p_to_other_pay_amount),
 -- End Bug 2353506
    p_to_au_overtime                   => p_to_au_overtime,
    p_to_auo_premium_pay_indicator     => p_to_auo_premium_pay_indicator,
    p_to_availability_pay              => p_to_availability_pay,
    p_to_ap_premium_pay_indicator      => p_to_ap_premium_pay_indicator,
    p_to_retention_allowance           => p_to_retention_allowance,
    p_to_supervisory_differential      => p_to_supervisory_differential,
    p_to_staffing_differential         => p_to_staffing_differential,
    p_to_pay_basis                     => p_to_pay_basis,
    p_to_pay_plan                      => p_to_pay_plan,
    -- FWFA Changes Bug#4444609
    p_to_pay_table_identifier          => p_to_pay_table_identifier,
    -- FWFA Changes
    p_to_position_id                   => p_to_position_id,
    p_to_position_org_line1            => p_to_position_org_line1,
    p_to_position_org_line2            => p_to_position_org_line2,
    p_to_position_org_line3            => p_to_position_org_line3,
    p_to_position_org_line4            => p_to_position_org_line4,
    p_to_position_org_line5            => p_to_position_org_line5,
    p_to_position_org_line6            => p_to_position_org_line6,
    p_to_position_number               => p_to_position_number,
    p_to_position_seq_no               => p_to_position_seq_no,
    p_to_position_title                => p_to_position_title,
    p_to_step_or_rate                  => p_to_step_or_rate,
    p_to_total_salary                  => p_to_total_salary,
    p_veterans_pref_for_rif            => p_veterans_pref_for_rif,
    p_veterans_preference              => p_veterans_preference,
    p_veterans_status                  => p_veterans_status,
    p_work_schedule                    => p_work_schedule,
    p_work_schedule_desc               => p_work_schedule_desc,
    p_year_degree_attained             => p_year_degree_attained,
    p_first_noa_information1           => p_first_noa_information1,
    p_first_noa_information2           => p_first_noa_information2,
    p_first_noa_information3           => p_first_noa_information3,
    p_first_noa_information4           => p_first_noa_information4,
    p_first_noa_information5           => p_first_noa_information5,
    p_second_lac1_information1         => p_second_lac1_information1,
    p_second_lac1_information2         => p_second_lac1_information2,
    p_second_lac1_information3         => p_second_lac1_information3,
    p_second_lac1_information4         => p_second_lac1_information4,
    p_second_lac1_information5         => p_second_lac1_information5,
    p_second_lac2_information1         => p_second_lac2_information1,
    p_second_lac2_information2         => p_second_lac2_information2,
    p_second_lac2_information3         => p_second_lac2_information3,
    p_second_lac2_information4         => p_second_lac2_information4,
    p_second_lac2_information5         => p_second_lac2_information5,
    p_second_noa_information1          => p_second_noa_information1,
    p_second_noa_information2          => p_second_noa_information2,
    p_second_noa_information3          => p_second_noa_information3,
    p_second_noa_information4          => p_second_noa_information4,
    p_second_noa_information5          => p_second_noa_information5,
    p_first_lac1_information1          => p_first_lac1_information1,
    p_first_lac1_information2          => p_first_lac1_information2,
    p_first_lac1_information3          => p_first_lac1_information3,
    p_first_lac1_information4          => p_first_lac1_information4,
    p_first_lac1_information5          => p_first_lac1_information5,
    p_first_lac2_information1          => p_first_lac2_information1,
    p_first_lac2_information2          => p_first_lac2_information2,
    p_first_lac2_information3          => p_first_lac2_information3,
    p_first_lac2_information4          => p_first_lac2_information4,
    p_first_lac2_information5          => p_first_lac2_information5,
    p_attribute_category               => p_attribute_category,
    p_attribute1                       => p_attribute1,
    p_attribute2                       => p_attribute2,
    p_attribute3                       => p_attribute3,
    p_attribute4                       => p_attribute4,
    p_attribute5                       => p_attribute5,
    p_attribute6                       => p_attribute6,
    p_attribute7                       => p_attribute7,
    p_attribute8                       => p_attribute8,
    p_attribute9                       => p_attribute9,
    p_attribute10                      => p_attribute10,
    p_attribute11                      => p_attribute11,
    p_attribute12                      => p_attribute12,
    p_attribute13                      => p_attribute13,
    p_attribute14                      => p_attribute14,
    p_attribute15                      => p_attribute15,
    p_attribute16                      => p_attribute16,
    p_attribute17                      => p_attribute17,
    p_attribute18                      => p_attribute18,
    p_attribute19                      => p_attribute19,
    p_attribute20                      => p_attribute20,
    p_object_version_number            => l_par_object_version_number,
    p_to_retention_allow_percentag     => p_to_retention_allow_percentag,
    p_to_supervisory_diff_percenta     => p_to_supervisory_diff_percenta,
    p_to_staffing_diff_percentage      => p_to_staffing_diff_percentage,
    p_award_percentage                 => p_award_percentage,
    p_rpa_type                         => p_rpa_type,
    p_mass_action_id                   => p_mass_action_id,
    p_mass_action_eligible_flag        => p_mass_action_eligible_flag,
    p_mass_action_select_flag          => p_mass_action_select_flag,
    p_mass_action_comments             => p_mass_action_comments ,
    -- Bug#4486823 RRR Changes
    p_payment_option                   => p_payment_option,
    p_award_salary                     => p_award_salary
    -- Bug#4486823 RRR Changes
   );
     p_par_object_version_number   := l_par_object_version_number  ;
    hr_utility.set_location(l_proc, 8);


 --2) Write  into pa_remarks all mandatory remarks for the specific nature_of_action (first and second)

    if  p_first_noa_id is not null then
      insert into ghr_pa_remarks
        (pa_remark_id
        ,pa_request_id
        ,remark_id
        ,description
        ,object_version_number
        )
        select  ghr_pa_remarks_s.nextval
                ,l_pa_request_id
                ,rem.remark_id
                ,rem.description
                ,1
         from    ghr_remarks       rem,
                 ghr_noac_remarks  nre
         where   nre.nature_of_action_id = p_first_noa_id
         and     nre.required_flag       = 'Y'
         and     l_effective_date
         between nre.date_from
         and     nvl(nre.date_to,l_effective_date)
         and     nre.remark_id          = rem.remark_id;
        -- and     rem.enabled_flag       = 'Y'
        -- and     l_effective_date
        -- between rem.date_from
        -- and     nvl(rem.date_to,l_effective_date));
    end if;

   if  p_second_noa_id is not null then
      insert into ghr_pa_remarks
        (pa_remark_id
        ,pa_request_id
        ,remark_id
        ,description
        ,object_version_number
        )
        select  ghr_pa_remarks_s.nextval
                ,l_pa_request_id
                ,rem.remark_id
                ,rem.description
                ,1
         from    ghr_remarks       rem,
                 ghr_noac_remarks  nre
         where   nre.nature_of_action_id = p_second_noa_id
         and     nre.required_flag       = 'Y'
         and     l_effective_date
         between nre.date_from
         and     nvl(nre.date_to,l_effective_date)
         and     nre.remark_id          = rem.remark_id;
        -- and     rem.enabled_flag       = 'Y'
        -- and     l_effective_date
        -- between rem.date_from
        -- and     nvl(rem.date_to,l_effective_date));
    end if;

-- create all generic extra information



-- Create all the noa_specific extra information
   l_position_id := nvl(p_to_position_id,p_from_position_id);

-- (nvl(p_1_action_taken,hr_api.g_varchar2) = 'NOT_ROUTED' and p_mass_action_id is null and nvl(p_rpa_type,hr_api.g_varchar2) <> 'TA' )
-- Comment above line because irrespective of p_mass_action_id value the if condn should be true (AVR)

 If nvl(p_first_noa_code,hr_api.g_varchar2) <> '001'
     or
    (nvl(p_1_action_taken,hr_api.g_varchar2) = 'NOT_ROUTED' and
     nvl(p_rpa_type,hr_api.g_varchar2) <> 'TA' )
      then

   If p_person_id is not null or p_noa_family_code = 'APP' then
     GHR_NON_SF52_EXTRA_INFO.fetch_generic_extra_info
     (p_pa_request_id        =>  l_pa_request_id,
      p_person_id            =>  p_person_id,
      p_assignment_id        =>  p_employee_assignment_id,
      p_effective_date       =>  trunc(nvl(p_effective_date,sysdate)),
      p_refresh_flag         =>  'N'
     );
   End if;

   If ((p_first_noa_code is not null or  p_second_noa_code is not null)  and
   ( p_person_id is not null or p_employee_assignment_id is not null or
     l_position_id  is not null)) then

     GHR_NON_SF52_EXTRA_INFO.populate_noa_spec_extra_info
     (p_pa_request_id    => l_pa_request_id,
      p_first_noa_id     => p_first_noa_id,
      p_second_noa_id    => p_second_noa_id,
      p_person_id        => p_person_id,
      p_assignment_id    => p_employee_assignment_id,
      p_position_id      => l_position_id,
      p_effective_date   => p_effective_date,
      p_refresh_flag     =>  'N'
     );

   End if;
 End if;

 -- populate the generic extra info

 -- 1. 'GHR_US_PAR_PAYROLL_TYPE
 -- 2. 'GHR_US_PAR_PERF_APPRAISAL

 -- 3)Derive all parmeters required to insert routing_history records.
--   Roles , Action_taken  (and sequence Number if necessary)

    if p_1_user_name_acted_on is not null then
      ghr_pa_requests_pkg.get_roles
     (l_pa_request_id,
      p_routing_group_id,
      p_1_user_name_acted_on,
      l_initiator_flag,
      l_requester_flag,
      l_authorizer_flag,
      l_personnelist_flag,
      l_approver_flag,
      l_reviewer_flag
      );

     for user_emp_names in C_user_emp_names loop
       l_user_name_employee_id      := user_emp_names.employee_id;
       l_user_name_emp_first_name   := user_emp_names.first_name;
       l_user_name_emp_last_name    := user_emp_names.last_name;
       l_user_name_emp_middle_names := user_emp_names.middle_names;
       exit;
     end loop;
    end if;

-- If action_taken is null then ,derive the action_taken

    hr_utility.set_location('passed action taken ' ||p_1_action_taken,1);
   l_action_taken    := p_1_action_taken;
    if l_action_taken is null then
      if nvl(p_authorized_by_person_id,hr_api.g_number) <>
         nvl(ghr_par_shd.g_old_rec.authorized_by_person_id,hr_api.g_number) then
        l_action_taken := 'AUTHORIZED';
      elsif nvl(p_requested_by_person_id,hr_api.g_number) <>
            nvl(ghr_par_shd.g_old_rec.requested_by_person_id,hr_api.g_number) then
        l_action_taken := 'REQUESTED';
      else
    hr_utility.set_location('Bef c_history_exists ' ||l_pa_request_id,2);
        for history_exists in C_history_exists loop
          l_exists := true;
          exit;
        end loop;
        if l_exists = true then
          l_action_taken := 'NO_ACTION';
        else
          l_action_taken := 'INITIATED';
        end if;
      end if;
    end if;
  /***dk***/
-- added END_ROUTING to the following if stmt.
    if l_action_taken not in('NOT_ROUTED','INITIATED','REQUESTED','AUTHORIZED',
                              'NO_ACTION','REVIEWED','CANCELED','UPDATE_HR','UPDATE_HR_COMPLETE', 'END_ROUTING')
         then
       hr_utility.set_message(8301,'GHR_38110_INVALID_ACTION_TAKEN');
       hr_utility.raise_error;
    end if;


   ghr_sf52_api.get_par_status
   (p_effective_date          =>  p_effective_date,
    p_approval_date           =>  l_approval_date,
    p_requested_by_person_id  =>  p_requested_by_person_id,
    p_authorized_by_person_id =>  p_authorized_by_person_id,
    p_action_taken            =>  p_1_action_taken,
    --8279908
    p_pa_request_id           =>  l_pa_request_id,
    p_status                  =>  l_status
   );

   ghr_par_upd.upd
   (p_pa_request_id   		=> l_pa_request_id,
    p_status          		=> l_status,
    p_object_version_number 	=> l_par_object_version_number
    );
    p_par_object_version_number := l_par_object_version_number;

-- to check if there is any routing information, if required.
  /***dk***/
-- added END_ROUTING to the following if stmt.
    hr_utility.set_location('check ' ||l_action_taken,3);
    hr_utility.set_location('p_2_user_name_routed_to ' ||p_2_user_name_routed_to,4);
    hr_utility.set_location('p_2_groupbox_id ' ||p_2_groupbox_id,5);
    hr_utility.set_location('p_2_routing_list_id ' ||p_2_routing_list_id,6);
    if l_action_taken not in ('CANCELED','UPDATE_HR','UPDATE_HR_COMPLETE','NOT_ROUTED','END_ROUTING') then
       if p_2_user_name_routed_to is null and
          p_2_groupbox_id        is null and
          p_2_routing_list_id     is null then
         hr_utility.set_message(8301,'GHR_38115_ROUT_INFO_REQD');
         hr_utility.raise_error;
       end if;
    end if;

-- write the first record into the routing history (actions done by the user)
    if nvl(l_action_taken,hr_api.g_varchar2) not in
    ('CANCELED','UPDATE_HR_COMPLETE') then
----If (p_mass_action_id is not null and nvl(p_rpa_type,hr_api.g_varchar2) <> 'TA') or (p_mass_action_id is null) then
-- Comment above line because irrespective of p_mass_action_id value the if condn should be true (AVR)

    If nvl(p_rpa_type,hr_api.g_varchar2) <> 'TA' then
      if l_action_taken = 'UPDATE_HR' and trunc(p_effective_date) > trunc(sysdate) then
         l_action_taken  := 'FUTURE_ACTION';
      End if;

      ghr_prh_ins.ins
       (
        p_pa_routing_history_id     => p_1_pa_routing_history_id,
        p_pa_request_id             => l_pa_request_id,
        p_attachment_modified_flag  => nvl(p_1_attachment_modified_flag,'N') ,
        p_initiator_flag            => nvl(l_initiator_flag,'N'),
        p_approver_flag             => nvl(l_approver_flag,'N'),
        p_reviewer_flag             => nvl(l_reviewer_flag,'N') ,
        p_requester_flag            => nvl(l_requester_flag,'N') ,
        p_authorizer_flag           => nvl(l_authorizer_flag,'N'),
        p_personnelist_flag         => nvl(l_personnelist_flag,'N'),
        p_approved_flag             => nvl(p_1_approved_flag,'N'),
        p_user_name                 => p_1_user_name_acted_on,
        p_user_name_employee_id     => l_user_name_employee_id,
        p_user_name_emp_first_name  => l_user_name_emp_first_name,
        p_user_name_emp_last_name   => l_user_name_emp_last_name ,
        p_user_name_emp_middle_names =>l_user_name_emp_middle_names,
        p_notepad                   => p_notepad,
        p_action_taken              => l_action_taken,
        p_noa_family_code           => p_noa_family_code,
        p_nature_of_action_id       => p_first_noa_id,
        p_second_nature_of_action_id => p_second_noa_id,
        p_approval_Status             => p_1_approval_status,
        p_object_version_number     => p_1_prh_object_version_number
       -- p_validate                  => false
       );


       l_2_routing_seq_number := p_2_routing_seq_number;
       l_2_groupbox_id        := p_2_groupbox_id;
       l_2_user_name          := p_2_user_name_routed_to;

--  derive the next sequence number for the speicific routing list if seq. number is not passed in
       if p_2_routing_list_id is not null and p_2_routing_seq_number is null then

         for rout_seq_numb in C_seq_number  loop
           l_2_routing_seq_number  := rout_seq_numb.seq_number;
           l_2_groupbox_id         := rout_seq_numb.groupbox_id;
           l_2_user_name           := rout_seq_numb.user_name;
           exit;
         end loop;

         if l_2_routing_seq_number is null then
           hr_utility.set_message(8301,'GHR_38114_NO_MORE_SEQ_NUMBER' );
           hr_utility.raise_error;
         end if;

       end if;


 -- check for open events before  attempting to route / Update HR
      ghr_sf52_api.check_for_open_events
      (
       p_pa_request_id        => l_pa_request_id,
       p_message              => l_message,
       p_action_taken         => l_action_taken,
       p_user_name_acted_on   => p_1_user_name_acted_on,
       p_user_name_routed_to  => l_2_user_name,
       p_groupbox_routed_to   => l_2_groupbox_id
       );

       -- call events user hook
       ghr_agency_check.open_events_check
       (p_pa_request_id       =>  l_pa_request_id,
        p_message_set         =>  l_message
        );

       if l_message then
         hr_utility.set_message(8301,'GHR_38592_OPEN_EVENTS_EXIST');
         hr_utility.raise_error;
       end if;

   --Insert 2nd record into routing_history for routing details
   --  (exception when routing_status = 'NOT_ROUTED' or  'UPDATE_HR','FUTURE_ACTION','END_ROUTING')
      /***dk***/
-- added END_ROUTING to the following if stmt.
    if nvl(l_action_taken,hr_api.g_varchar2) not in  ('NOT_ROUTED','UPDATE_HR','FUTURE_ACTION','END_ROUTING') then

       ghr_prh_ins.ins
      (p_pa_routing_history_id        => p_2_pa_routing_history_id,
       p_pa_request_id                => l_pa_request_id,
       p_attachment_modified_flag     => 'N',
       p_initiator_flag               => 'N',
       p_approver_flag                => 'N',
       p_reviewer_flag                => 'N',
       p_requester_flag               => 'N',
       p_authorizer_flag              => 'N',
       p_personnelist_flag            => 'N',
       p_approved_flag                => 'N',
       p_user_name                    => l_2_user_name,
       p_groupbox_id                  => l_2_groupbox_id,
       p_routing_list_id              => p_2_routing_list_id,
       p_routing_seq_number           => l_2_routing_seq_number,
       p_noa_family_code              => p_noa_family_code,
       p_nature_of_action_id          => p_first_noa_id,
       p_second_nature_of_action_id   => p_second_noa_id,
       p_object_version_number        => p_2_prh_object_version_number
    --  p_validate                     => false
      );

      -- Deriving the groupbox name to be passed to workflow call
      if l_2_groupbox_id is not null then
         for groupbox_name in c_groupbox_name loop
             l_forward_to_name := groupbox_name.name;
          end loop;
      else
         l_forward_to_name := l_2_user_name;
      end if;
    end if;
 -- call update_hr if l_action_taken = 'UPDATE_HR'or 'FUTURE_ACTION'
 if l_action_taken in ('UPDATE_HR','FUTURE_ACTION','END_ROUTING') then
  -- call update_hr with the p_pa_request_rec data

  l_rec.pa_request_id                    := l_pa_request_id;
  l_rec.noa_family_code                  := p_noa_family_code;
  l_rec.routing_group_id                 := p_routing_group_id;
  l_rec.proposed_effective_asap_flag     := p_proposed_effective_asap_flag;
  l_rec.academic_discipline              := p_academic_discipline;
  l_rec.additional_info_person_id        := p_additional_info_person_id;
  l_rec.additional_info_tel_number       := p_additional_info_tel_number;
  l_rec.altered_pa_request_id            := p_altered_pa_request_id;
  l_rec.annuitant_indicator              := p_annuitant_indicator;
  l_rec.annuitant_indicator_desc         := p_annuitant_indicator_desc;
  l_rec.appropriation_code1              := p_appropriation_code1;
  l_rec.appropriation_code2              := p_appropriation_code2;
  l_rec.approval_date                    := l_approval_date;
  l_rec.approving_official_full_name     := l_approving_official_full_name;
  l_rec.approving_official_work_title    := l_approving_official_work_titl;
  l_rec.authorized_by_person_id          := p_authorized_by_person_id;
  l_rec.authorized_by_title              := p_authorized_by_title;
  l_rec.award_amount                     := p_award_amount;
  l_rec.award_uom                        := p_award_uom;
  l_rec.bargaining_unit_status           := p_bargaining_unit_status;
  l_rec.citizenship                      := p_citizenship;
  l_rec.concurrence_date                 := p_concurrence_date;
  l_rec.custom_pay_calc_flag             := p_custom_pay_calc_flag;
  l_rec.duty_station_code                := p_duty_station_code;
  l_rec.duty_station_desc                := p_duty_station_desc;
  l_rec.duty_station_id                  := p_duty_station_id;
  l_rec.duty_station_location_id         := p_duty_station_location_id;
  l_rec.education_level                  := p_education_level;
  l_rec.effective_date                   := p_effective_date;
  l_rec.employee_assignment_id           := p_employee_assignment_id;
  l_rec.employee_date_of_birth           := p_employee_date_of_birth;
  l_rec.employee_first_name              := p_employee_first_name;
  l_rec.employee_last_name               := p_employee_last_name;
  l_rec.employee_middle_names            := p_employee_middle_names;
  l_rec.employee_national_identifier     := p_employee_national_identifier;
  l_rec.fegli                            := p_fegli;
  l_rec.fegli_desc                       := p_fegli_desc;
  l_rec.first_action_la_code1            := p_first_action_la_code1;
  l_rec.first_action_la_code2            := p_first_action_la_code2;
  l_rec.first_action_la_desc1            := p_first_action_la_desc1;
  l_rec.first_action_la_desc2            := p_first_action_la_desc2;
  l_rec.first_noa_cancel_or_correct      := p_first_noa_cancel_or_correct;
  l_rec.first_noa_code                   := p_first_noa_code;
  l_rec.first_noa_desc                   := p_first_noa_desc;
  l_rec.first_noa_id                     := p_first_noa_id;
  l_rec.first_noa_pa_request_id          := p_first_noa_pa_request_id;
  l_rec.flsa_category                    := p_flsa_category;
  l_rec.forwarding_address_line1         := p_forwarding_address_line1;
  l_rec.forwarding_address_line2         := p_forwarding_address_line2;
  l_rec.forwarding_address_line3         := p_forwarding_address_line3;
  l_rec.forwarding_country               := p_forwarding_country;
  l_rec.forwarding_country_short_name    := p_forwarding_country_short_nam;
  l_rec.forwarding_postal_code           := p_forwarding_postal_code;
  l_rec.forwarding_region_2              := p_forwarding_region_2;
  l_rec.forwarding_town_or_city          := p_forwarding_town_or_city;
  l_rec.from_adj_basic_pay               := p_from_adj_basic_pay;
  l_rec.from_basic_pay                   := p_from_basic_pay;
  l_rec.from_grade_or_level              := p_from_grade_or_level;
  l_rec.from_locality_adj                := p_from_locality_adj;
  l_rec.from_occ_code                    := p_from_occ_code;
  l_rec.from_other_pay_amount            := p_from_other_pay_amount;
  l_rec.from_pay_basis                   := p_from_pay_basis;
  l_rec.from_pay_plan                    := p_from_pay_plan;
  -- FWFA Changes Bug#4444609
  l_rec.input_pay_rate_determinant          := p_input_pay_rate_determinant;
  l_rec.from_pay_table_identifier        := p_from_pay_table_identifier;
  -- FWFA Changes
  l_rec.from_position_id                 := p_from_position_id;
  l_rec.from_position_org_line1          := p_from_position_org_line1;
  l_rec.from_position_org_line2          := p_from_position_org_line2;
  l_rec.from_position_org_line3          := p_from_position_org_line3;
  l_rec.from_position_org_line4          := p_from_position_org_line4;
  l_rec.from_position_org_line5          := p_from_position_org_line5;
  l_rec.from_position_org_line6          := p_from_position_org_line6;
  l_rec.from_position_number             := p_from_position_number;
  l_rec.from_position_seq_no             := p_from_position_seq_no;
  l_rec.from_position_title              := p_from_position_title;
  l_rec.from_step_or_rate                := p_from_step_or_rate;
  l_rec.from_total_salary                := p_from_total_salary;
  l_rec.functional_class                 := p_functional_class;
  l_rec.notepad                          := p_notepad;
  l_rec.part_time_hours                  := p_part_time_hours;
  l_rec.pay_rate_determinant             := p_pay_rate_determinant;
  l_rec.person_id                        := p_person_id;
  l_rec.position_occupied                := p_position_occupied;
  l_rec.proposed_effective_date          := p_proposed_effective_date;
  l_rec.requested_by_person_id           := p_requested_by_person_id;
  l_rec.requested_by_title               := p_requested_by_title;
  l_rec.requested_date                   := p_requested_date;
  l_rec.requesting_office_remarks_desc   := p_requesting_office_remarks_de;
  l_rec.requesting_office_remarks_flag   := p_requesting_office_remarks_fl;
  l_rec.request_number                   := p_request_number;
  l_rec.resign_and_retire_reason_desc    := p_resign_and_retire_reason_des;
  l_rec.retirement_plan                  := p_retirement_plan;
  l_rec.retirement_plan_desc             := p_retirement_plan_desc;
  l_rec.second_action_la_code1           := p_second_action_la_code1;
  l_rec.second_action_la_code2           := p_second_action_la_code2;
  l_rec.second_action_la_desc1           := p_second_action_la_desc1;
  l_rec.second_action_la_desc2           := p_second_action_la_desc2;
  l_rec.second_noa_cancel_or_correct     := p_second_noa_cancel_or_correct;
  l_rec.second_noa_code                  := p_second_noa_code;
  l_rec.second_noa_desc                  := p_second_noa_desc;
  l_rec.second_noa_id                    := p_second_noa_id;
  l_rec.second_noa_pa_request_id         := p_second_noa_pa_request_id;
  l_rec.service_comp_date                := p_service_comp_date;
  l_rec.status                           := l_status;
  l_rec.supervisory_status               := p_supervisory_status;
  l_rec.tenure                           := p_tenure;
  l_rec.to_adj_basic_pay                 := p_to_adj_basic_pay;
  l_rec.to_basic_pay                     := p_to_basic_pay;
  l_rec.to_grade_id                      := p_to_grade_id;
  l_rec.to_grade_or_level                := p_to_grade_or_level;
  l_rec.to_job_id                        := p_to_job_id;
  l_rec.to_locality_adj                  := p_to_locality_adj;
  l_rec.to_occ_code                      := p_to_occ_code;
  l_rec.to_organization_id               := p_to_organization_id;
  l_rec.to_other_pay_amount              := p_to_other_pay_amount;
  l_rec.to_au_overtime                   := p_to_au_overtime;
  l_rec.to_auo_premium_pay_indicator     := p_to_auo_premium_pay_indicator;
  l_rec.to_availability_pay              := p_to_availability_pay;
  l_rec.to_ap_premium_pay_indicator      := p_to_ap_premium_pay_indicator;
  l_rec.to_retention_allowance           := p_to_retention_allowance;
  l_rec.to_supervisory_differential      := p_to_supervisory_differential;
  l_rec.to_staffing_differential         := p_to_staffing_differential;
  l_rec.to_pay_basis                     := p_to_pay_basis;
  l_rec.to_pay_plan                      := p_to_pay_plan;
  -- FWFA Changes Bug#4444609
  l_rec.to_pay_table_identifier          := p_to_pay_table_identifier;
  -- FWFA Changes
  l_rec.to_position_id                   := p_to_position_id;
  l_rec.to_position_org_line1            := p_to_position_org_line1;
  l_rec.to_position_org_line2            := p_to_position_org_line2;
  l_rec.to_position_org_line3            := p_to_position_org_line3;
  l_rec.to_position_org_line4            := p_to_position_org_line4;
  l_rec.to_position_org_line5            := p_to_position_org_line5;
  l_rec.to_position_org_line6            := p_to_position_org_line6;
  l_rec.to_position_number               := p_to_position_number;
  l_rec.to_position_seq_no               := p_to_position_seq_no;
  l_rec.to_position_title                := p_to_position_title;
  l_rec.to_step_or_rate                  := p_to_step_or_rate;
  l_rec.to_total_salary                  := p_to_total_salary;
  l_rec.veterans_preference              := p_veterans_preference;
  l_rec.veterans_pref_for_rif            := p_veterans_pref_for_rif;
  l_rec.veterans_status                  := p_veterans_status;
  l_rec.work_schedule                    := p_work_schedule;
  l_rec.work_schedule_desc               := p_work_schedule_desc;
  l_rec.year_degree_attained             := p_year_degree_attained;
  l_rec.first_noa_information1           := p_first_noa_information1;
  l_rec.first_noa_information2           := p_first_noa_information2;
  l_rec.first_noa_information3           := p_first_noa_information3;
  l_rec.first_noa_information4           := p_first_noa_information4;
  l_rec.first_noa_information5           := p_first_noa_information5;
  l_rec.second_lac1_information1         := p_second_lac1_information1;
  l_rec.second_lac1_information2         := p_second_lac1_information2;
  l_rec.second_lac1_information3         := p_second_lac1_information3;
  l_rec.second_lac1_information4         := p_second_lac1_information4;
  l_rec.second_lac1_information5         := p_second_lac1_information5;
  l_rec.second_lac2_information1         := p_second_lac2_information1;
  l_rec.second_lac2_information2         := p_second_lac2_information2;
  l_rec.second_lac2_information3         := p_second_lac2_information3;
  l_rec.second_lac2_information4         := p_second_lac2_information4;
  l_rec.second_lac2_information5         := p_second_lac2_information5;
  l_rec.second_noa_information1          := p_second_noa_information1;
  l_rec.second_noa_information2          := p_second_noa_information2;
  l_rec.second_noa_information3          := p_second_noa_information3;
  l_rec.second_noa_information4          := p_second_noa_information4;
  l_rec.second_noa_information5          := p_second_noa_information5;
  l_rec.first_lac1_information1          := p_first_lac1_information1;
  l_rec.first_lac1_information2          := p_first_lac1_information2;
  l_rec.first_lac1_information3          := p_first_lac1_information3;
  l_rec.first_lac1_information4          := p_first_lac1_information4;
  l_rec.first_lac1_information5          := p_first_lac1_information5;
  l_rec.first_lac2_information1          := p_first_lac2_information1;
  l_rec.first_lac2_information2          := p_first_lac2_information2;
  l_rec.first_lac2_information3          := p_first_lac2_information3;
  l_rec.first_lac2_information4          := p_first_lac2_information4;
  l_rec.first_lac2_information5          := p_first_lac2_information5;
  l_rec.attribute_category               := p_attribute_category;
  l_rec.attribute1                       := p_attribute1;
  l_rec.attribute2                       := p_attribute2;
  l_rec.attribute3                       := p_attribute3;
  l_rec.attribute4                       := p_attribute4;
  l_rec.attribute5                       := p_attribute5;
  l_rec.attribute6                       := p_attribute6;
  l_rec.attribute7                       := p_attribute7;
  l_rec.attribute8                       := p_attribute8;
  l_rec.attribute9                       := p_attribute9;
  l_rec.attribute10                      := p_attribute10;
  l_rec.attribute11                      := p_attribute11;
  l_rec.attribute12                      := p_attribute12;
  l_rec.attribute13                      := p_attribute13;
  l_rec.attribute14                      := p_attribute14;
  l_rec.attribute15                      := p_attribute15;
  l_rec.attribute16                      := p_attribute16;
  l_rec.attribute17                      := p_attribute17;
  l_rec.attribute18                      := p_attribute18;
  l_rec.attribute19                      := p_attribute19;
  l_rec.attribute20                      := p_attribute20;
  l_rec.object_version_number            := l_par_object_version_number;
  l_rec.to_retention_allow_percentage    := p_to_retention_allow_percentag;
  l_rec.to_supervisory_diff_percentage   := p_to_supervisory_diff_percenta;
  l_rec.to_staffing_diff_percentage      := p_to_staffing_diff_percentage;
  l_rec.award_percentage                 := p_award_percentage;
  l_rec.rpa_type                         := p_rpa_type;
  l_rec.mass_action_id                   := p_mass_action_id;
  l_rec.mass_action_eligible_flag        := p_mass_action_eligible_flag;
  l_rec.mass_action_select_flag          := p_mass_action_select_flag;
  l_rec.mass_action_comments             := p_mass_action_comments;
  -- Bug#4486823 RRR Changes
  l_rec.pa_incentive_payment_option      := p_payment_option;
  l_rec.award_salary                     := p_award_salary;
  -- Bug#4486823 RRR Changes



   IF l_rec.effective_date is null THEN
      hr_utility.set_message(8301,'GHR_38185_EFF_DATE_REQUIRED');
      ghr_upd_hr_validation.form_item_name := 'PAR.EFFECTIVE_DATE';
      hr_utility.raise_error;
   END IF;
   if (l_action_taken <> 'END_ROUTING') then
    ghr_process_sf52.process_sf52
    (p_sf52_data    => l_rec
     ,p_capped_other_pay => p_capped_other_pay
    );
   end if;
    ghr_sf52_post_update.get_notification_details
  (p_pa_request_id                  =>  l_pa_request_id,
   p_effective_date                 =>  p_effective_date,
--   p_object_version_number          =>  p_imm_pa_request_rec.object_version_number,
   p_from_position_id               =>  l_rec.from_position_id,
   p_to_position_id                 =>  l_rec.to_position_id,
   p_agency_code                    =>  l_rec.agency_code,
   p_from_agency_code               =>  l_rec.from_agency_code,
   p_from_agency_desc               =>  l_rec.from_agency_desc,
   p_from_office_symbol             =>  l_rec.from_office_symbol,
   p_personnel_office_id            =>  l_rec.personnel_office_id,
   p_employee_dept_or_agency        =>  l_rec.employee_dept_or_agency,
   p_to_office_symbol               =>  l_rec.to_office_symbol
   );
   for ovn_rec in c_ovn loop
     l_rec.object_version_number := ovn_rec.object_version_number;
   end loop;
   hr_utility.set_location('to pos id is '|| l_rec.to_position_id,1);
   hr_utility.set_location('first noa code is '|| l_rec.first_noa_code,1);

   IF nvl(l_rec.first_noa_code,'9999') <> '002' THEN
   ghr_par_upd.upd
   (p_pa_request_id                 =>  l_pa_request_id,
    p_object_version_number         =>  l_rec.object_version_number,
    p_from_position_id               =>  l_rec.from_position_id,
    p_to_position_id                 =>  l_rec.to_position_id,
    p_agency_code                    =>  l_rec.agency_code,
    p_from_agency_code               =>  l_rec.from_agency_code,
    p_from_agency_desc               =>  l_rec.from_agency_desc,
    p_from_office_symbol             =>  l_rec.from_office_symbol,
    p_personnel_office_id            =>  l_rec.personnel_office_id,
    p_employee_dept_or_agency        =>  l_rec.employee_dept_or_agency,
    p_to_office_symbol               =>  l_rec.to_office_symbol
   );
   ELSE
   ghr_par_upd.upd
   (p_pa_request_id                 =>  l_pa_request_id,
    p_object_version_number         =>  l_rec.object_version_number,
    p_from_position_id               =>  l_rec.from_position_id,
    p_agency_code                    =>  l_rec.agency_code,
    p_from_agency_code               =>  l_rec.from_agency_code,
    p_from_agency_desc               =>  l_rec.from_agency_desc,
    p_from_office_symbol             =>  l_rec.from_office_symbol,
    p_personnel_office_id            =>  l_rec.personnel_office_id,
    p_employee_dept_or_agency        =>  l_rec.employee_dept_or_agency,
    p_to_office_symbol               =>  l_rec.to_office_symbol
   );
   END IF;

   IF (l_action_taken = 'END_ROUTING') THEN
	ghr_agency_update.ghr_agency_upd(
		p_pa_request_rec 		=>	l_rec,
		p_asg_sf52			    =>	l_asg_sf52,
		p_asg_non_sf52          =>	l_asg_non_sf52,
 		p_asg_nte_dates         =>	l_asg_nte_dates,
 		p_per_sf52              =>	l_per_sf52,
 		p_per_group1            =>	l_per_group1,
 		p_per_group2            =>	l_per_group2,
 		p_per_scd_info          =>	l_per_scd_info,
 		p_per_retained_grade    =>	l_per_retained_grade,
 		p_per_probations        =>	l_per_probations,
 		p_per_sep_retire        =>	l_per_sep_retire,
 		p_per_security		    =>	l_per_security,
 		p_per_conversions		=>	l_per_conversions,
 		p_per_uniformed_services=>	l_per_uniformed_services,
 		p_pos_oblig             =>	l_pos_oblig,
 		p_pos_grp2              =>	l_pos_grp2,
 		p_pos_grp1              =>	l_pos_grp1,
 		p_pos_valid_grade       =>	l_pos_valid_grade,
 		p_pos_car_prog          =>	l_pos_car_prog,
 		p_loc_info              =>	l_loc_info,
 		p_wgi     	            =>	l_wgi,
 		p_recruitment_bonus	    =>	l_recruitment_bonus,
 		p_relocation_bonus	    =>	l_relocation_bonus,
 		p_sf52_from_data        =>	l_sf52_from_data,
 		p_personal_info		    =>	l_personal_info,
 		p_gov_awards_type       =>	l_gov_awards_type,
 		p_perf_appraisal_type   =>	l_perf_appraisal_type,
 		p_payroll_type          =>	l_payroll_type,
 		p_conduct_perf_type     =>	l_conduct_perf_type,
 		p_agency_sf52           =>	l_agency_sf52,
 		p_agency_code		    =>	l_agency_code,
        p_entitlement           =>	l_imm_entitlement,
        p_foreign_lang_prof_pay =>	l_imm_foreign_lang_prof_pay,
        p_edp_pay               =>	l_imm_edp_pay,
        p_hazard_pay            =>	l_imm_hazard_pay,
        p_health_benefits       =>	l_imm_health_benefits,
        p_danger_pay            =>	l_imm_danger_pay,
        p_imminent_danger_pay   =>	l_imm_imminent_danger_pay,
        p_living_quarters_allow =>	l_imm_living_quarters_allow,
        p_post_diff_amt         =>	l_imm_post_diff_amt,
        p_post_diff_percent     =>	l_imm_post_diff_percent,
        p_sep_maintenance_allow =>	l_imm_sep_maintenance_allow,
        p_supplemental_post_allow  =>	l_imm_supplemental_post_allow,
        p_temp_lodge_allow      =>	l_imm_temp_lodge_allow,
        p_premium_pay           =>	l_imm_premium_pay,
        p_retirement_annuity    =>	l_imm_retirement_annuity,
        p_severance_pay         =>	l_imm_severance_pay,
        p_thrift_saving_plan    =>	l_imm_thrift_saving_plan,
        p_retention_allow_review =>	l_imm_retention_allow_review,
        p_health_ben_pre_tax    =>	l_imm_health_ben_pre_tax,
		p_per_benefit_info      =>  l_imm_per_benefit_info,
        p_imm_retirement_info   =>  l_imm_retirement_info --Bug# 7131104

		);
	ghr_sf52_api.end_sf52(	p_pa_request_id	=>	p_pa_request_id,
        					p_action_taken	=>	'ENDED',
		        			p_par_object_version_number => l_rec.object_version_number);
   end if;
End if;
if (l_action_taken not in ('UPDATE_HR','END_ROUTING')) then
 -- call workflow
 ghr_api.call_workflow
 (p_pa_request_id => l_pa_request_id
 ,p_action_taken  => l_action_taken
 );
end if;
 End if; -- Do not create routing history row for Mass Award Template
Else
  hr_utility.set_message(8301,'GHR_38112_INVALID_API');
  hr_utility.raise_error;
End if;

If p_print_sf50_flag = 'Y' then
  -- Make sure that it only is valid while update_hr
  If l_action_taken <> 'UPDATE_HR' then
    hr_utility.set_message(8301,'GHR_38399_52_NOT_PROCESSED');
    hr_utility.raise_error;
  End if;
  --Bug#3757201 Added p_back_page parameter
  submit_request_to_print_50
  (p_printer_name                       => p_printer_name,
   p_pa_request_id                      => l_pa_request_id,
   p_effective_date                     => p_effective_date,
   p_user_name                          => p_1_user_name_acted_on,
   p_back_page                          => p_print_back_page
  );

End if;
 --
 -- Call After Process User Hook
 --
 begin
	ghr_sf52_bk1.create_sf52_a	(
       p_noa_family_code                  => p_noa_family_code,
       p_pa_request_id                    => l_pa_request_id,
       p_routing_group_id                 => p_routing_group_id,
       p_proposed_effective_asap_flag     => p_proposed_effective_asap_flag,
       p_academic_discipline              => p_academic_discipline,
       p_additional_info_person_id        => p_additional_info_person_id,
       p_additional_info_tel_number       => p_additional_info_tel_number,
       p_altered_pa_request_id            => p_altered_pa_request_id,
       p_annuitant_indicator              => p_annuitant_indicator,
       p_annuitant_indicator_desc         => p_annuitant_indicator_desc,
       p_appropriation_code1              => p_appropriation_code1,
       p_appropriation_code2              => p_appropriation_code2,
       p_approval_date                    => l_approval_date,
       p_approving_official_full_name     => l_approving_official_full_name,
       p_approving_official_work_titl     => l_approving_official_work_titl,
       p_authorized_by_person_id          => p_authorized_by_person_id,
       p_authorized_by_title              => p_authorized_by_title,
       p_award_amount                     => p_award_amount,
       p_award_uom                        => p_award_uom,
       p_bargaining_unit_status           => p_bargaining_unit_status,
       p_citizenship                      => p_citizenship,
       p_concurrence_date                 => p_concurrence_date,
       p_custom_pay_calc_flag             => p_custom_pay_calc_flag,
       p_duty_station_code                => p_duty_station_code,
       p_duty_station_desc                => p_duty_station_desc,
       p_duty_station_location_id         => p_duty_station_location_id,
       p_duty_station_id                  => p_duty_station_id,
       p_education_level                  => p_education_level,
       p_effective_date                   => p_effective_date,
       p_employee_assignment_id           => p_employee_assignment_id,
       p_employee_date_of_birth           => p_employee_date_of_birth,
       p_employee_first_name              => p_employee_first_name,
       p_employee_last_name               => p_employee_last_name,
       p_employee_middle_names            => p_employee_middle_names,
       p_employee_national_identifier     => p_employee_national_identifier,
       p_fegli                            => p_fegli,
       p_fegli_desc                       => p_fegli_desc,
       p_first_action_la_code1            => p_first_action_la_code1,
       p_first_action_la_code2            => p_first_action_la_code2,
       p_first_action_la_desc1            => p_first_action_la_desc1,
       p_first_action_la_desc2            => p_first_action_la_desc2,
       p_first_noa_cancel_or_correct      => p_first_noa_cancel_or_correct,
       p_first_noa_id                     => p_first_noa_id,
       p_first_noa_code                   => p_first_noa_code,
       p_first_noa_desc                   => p_first_noa_desc,
       p_first_noa_pa_request_id          => p_first_noa_pa_request_id,
       p_flsa_category                    => p_flsa_category,
       p_forwarding_address_line1         => p_forwarding_address_line1,
       p_forwarding_address_line2         => p_forwarding_address_line2,
       p_forwarding_address_line3         => p_forwarding_address_line3,
       p_forwarding_country               => p_forwarding_country,
       p_forwarding_country_short_nam     => p_forwarding_country_short_nam,
       p_forwarding_postal_code           => p_forwarding_postal_code,
       p_forwarding_region_2              => p_forwarding_region_2,
       p_forwarding_town_or_city          => p_forwarding_town_or_city ,
       p_from_adj_basic_pay               => p_from_adj_basic_pay,
       p_from_basic_pay                   => p_from_basic_pay,
       p_from_grade_or_level              => p_from_grade_or_level,
       p_from_locality_adj                => p_from_locality_adj,
       p_from_occ_code                    => p_from_occ_code,
       p_from_other_pay_amount            => p_from_other_pay_amount,
       p_from_pay_basis                   => p_from_pay_basis,
       p_from_pay_plan                    => p_from_pay_plan,
       -- FWFA Changes Bug#4444609
       -- p_input_pay_rate_determinant          => p_input_pay_rate_determinant,
       -- p_from_pay_table_identifier     => p_from_pay_table_identifier,
       -- FWFA Changes
       p_from_position_id                 => p_from_position_id,
       p_from_position_org_line1          => p_from_position_org_line1,
       p_from_position_org_line2          => p_from_position_org_line2,
       p_from_position_org_line3          => p_from_position_org_line3,
       p_from_position_org_line4          => p_from_position_org_line4,
       p_from_position_org_line5          => p_from_position_org_line5,
       p_from_position_org_line6          => p_from_position_org_line6,
       p_from_position_number             => p_from_position_number,
       p_from_position_seq_no             => p_from_position_seq_no,
       p_from_position_title              => p_from_position_title,
       p_from_step_or_rate                => p_from_step_or_rate,
       p_from_total_salary                => p_from_total_salary,
       p_functional_class                 => p_functional_class,
       p_notepad                          => p_notepad,
       p_part_time_hours                  => p_part_time_hours,
       p_pay_rate_determinant             => p_pay_rate_determinant,
       p_person_id                        => p_person_id,
       p_position_occupied			=> p_position_occupied,
       p_proposed_effective_date          => p_proposed_effective_date,
       p_requested_by_person_id           => p_requested_by_person_id,
       p_requested_by_title               => p_requested_by_title,
       p_requested_date                   => p_requested_date,
       p_requesting_office_remarks_de     => p_requesting_office_remarks_de,
       p_requesting_office_remarks_fl     => p_requesting_office_remarks_fl,
       p_request_number                   => p_request_number,
       p_resign_and_retire_reason_des     => p_resign_and_retire_reason_des,
       p_retirement_plan                  => p_retirement_plan,
       p_retirement_plan_desc             => p_retirement_plan_desc,
       p_second_action_la_code1           => p_second_action_la_code1,
       p_second_action_la_code2           => p_second_action_la_code2,
       p_second_action_la_desc1           => p_second_action_la_desc1,
       p_second_action_la_desc2           => p_second_action_la_desc2,
       p_second_noa_cancel_or_correct     => p_second_noa_cancel_or_correct,
       p_second_noa_code                  => p_second_noa_code,
       p_second_noa_desc                  => p_second_noa_desc,
       p_second_noa_id                    => p_second_noa_id,
       p_second_noa_pa_request_id         => p_second_noa_pa_request_id,
       p_service_comp_date                => p_service_comp_date,
       p_supervisory_status               => p_supervisory_status,
       p_tenure                           => p_tenure,
       p_to_adj_basic_pay                 => p_to_adj_basic_pay,
       p_to_basic_pay                     => p_to_basic_pay,
       p_to_grade_id                      => p_to_grade_id,
       p_to_grade_or_level                => p_to_grade_or_level,
       p_to_job_id                        => p_to_job_id,
       p_to_locality_adj                  => p_to_locality_adj,
       p_to_occ_code                      => p_to_occ_code,
       p_to_organization_id               => p_to_organization_id,
       p_to_other_pay_amount              => p_to_other_pay_amount,
       p_to_au_overtime                   => p_to_au_overtime,
       p_to_auo_premium_pay_indicator     => p_to_auo_premium_pay_indicator,
       p_to_availability_pay              => p_to_availability_pay,
       p_to_ap_premium_pay_indicator      => p_to_ap_premium_pay_indicator,
       p_to_retention_allowance           => p_to_retention_allowance,
       p_to_supervisory_differential      => p_to_supervisory_differential,
       p_to_staffing_differential         => p_to_staffing_differential,
       p_to_pay_basis                     => p_to_pay_basis,
       p_to_pay_plan                      => p_to_pay_plan,
       -- FWFA Changes Bug#4444609
       -- p_to_pay_table_identifier          => p_to_pay_table_identifier,
       -- FWFA Changes
       p_to_position_id                   => p_to_position_id,
       p_to_position_org_line1            => p_to_position_org_line1,
       p_to_position_org_line2            => p_to_position_org_line2,
       p_to_position_org_line3            => p_to_position_org_line3,
       p_to_position_org_line4            => p_to_position_org_line4,
       p_to_position_org_line5            => p_to_position_org_line5,
       p_to_position_org_line6            => p_to_position_org_line6,
       p_to_position_number               => p_to_position_number,
       p_to_position_seq_no               => p_to_position_seq_no,
       p_to_position_title                => p_to_position_title,
       p_to_step_or_rate                  => p_to_step_or_rate,
       p_to_total_salary                  => p_to_total_salary,
       p_veterans_pref_for_rif            => p_veterans_pref_for_rif,
       p_veterans_preference              => p_veterans_preference,
       p_veterans_status                  => p_veterans_status,
       p_work_schedule                    => p_work_schedule,
       p_work_schedule_desc               => p_work_schedule_desc,
       p_year_degree_attained             => p_year_degree_attained,
       p_first_noa_information1           => p_first_noa_information1,
       p_first_noa_information2           => p_first_noa_information2,
       p_first_noa_information3           => p_first_noa_information3,
       p_first_noa_information4           => p_first_noa_information4,
       p_first_noa_information5           => p_first_noa_information5,
       p_second_lac1_information1         => p_second_lac1_information1,
       p_second_lac1_information2         => p_second_lac1_information2,
       p_second_lac1_information3         => p_second_lac1_information3,
       p_second_lac1_information4         => p_second_lac1_information4,
       p_second_lac1_information5         => p_second_lac1_information5,
       p_second_lac2_information1         => p_second_lac2_information1,
       p_second_lac2_information2         => p_second_lac2_information2,
       p_second_lac2_information3         => p_second_lac2_information3,
       p_second_lac2_information4         => p_second_lac2_information4,
       p_second_lac2_information5         => p_second_lac2_information5,
       p_second_noa_information1          => p_second_noa_information1,
       p_second_noa_information2          => p_second_noa_information2,
       p_second_noa_information3          => p_second_noa_information3,
       p_second_noa_information4          => p_second_noa_information4,
       p_second_noa_information5          => p_second_noa_information5,
       p_first_lac1_information1          => p_first_lac1_information1,
       p_first_lac1_information2          => p_first_lac1_information2,
       p_first_lac1_information3          => p_first_lac1_information3,
       p_first_lac1_information4          => p_first_lac1_information4,
       p_first_lac1_information5          => p_first_lac1_information5,
       p_first_lac2_information1          => p_first_lac2_information1,
       p_first_lac2_information2          => p_first_lac2_information2,
       p_first_lac2_information3          => p_first_lac2_information3,
       p_first_lac2_information4          => p_first_lac2_information4,
       p_first_lac2_information5          => p_first_lac2_information5,
       p_attribute_category               => p_attribute_category,
       p_attribute1                       => p_attribute1,
       p_attribute2                       => p_attribute2,
       p_attribute3                       => p_attribute3,
       p_attribute4                       => p_attribute4,
       p_attribute5                       => p_attribute5,
       p_attribute6                       => p_attribute6,
       p_attribute7                       => p_attribute7,
       p_attribute8                       => p_attribute8,
       p_attribute9                       => p_attribute9,
       p_attribute10                      => p_attribute10,
       p_attribute11                      => p_attribute11,
       p_attribute12                      => p_attribute12,
       p_attribute13                      => p_attribute13,
       p_attribute14                      => p_attribute14,
       p_attribute15                      => p_attribute15,
       p_attribute16                      => p_attribute16,
       p_attribute17                      => p_attribute17,
       p_attribute18                      => p_attribute18,
       p_attribute19                      => p_attribute19,
       p_attribute20                      => p_attribute20,
       p_print_sf50_flag                  => p_print_sf50_flag,
       p_printer_name                     => p_printer_name,
       p_1_attachment_modified_flag       => p_1_attachment_modified_flag,
       p_1_approved_flag                  => p_1_approved_flag,
       p_1_user_name_acted_on             => p_1_user_name_acted_on,
       p_1_action_taken                   => p_1_action_taken,
       p_1_approval_status                => p_1_approval_status,
       p_2_user_name_routed_to            => p_2_user_name_routed_to,
       p_2_groupbox_id                    => p_2_groupbox_id,
       p_2_routing_list_id                => p_2_routing_list_id,
       p_2_routing_seq_number             => p_2_routing_seq_number,
       p_capped_other_pay                 => p_capped_other_pay,
       p_par_object_version_number        => l_par_object_version_number,
       p_1_pa_routing_history_id          => p_1_pa_routing_history_id,
       p_1_prh_object_version_number      => p_1_prh_object_version_number,
       p_2_pa_routing_history_id          => p_2_pa_routing_history_id,
       p_2_prh_object_version_number      => p_2_prh_object_version_number,
       p_to_retention_allow_percentag     => p_to_retention_allow_percentag,
       p_to_supervisory_diff_percenta     => p_to_supervisory_diff_percenta,
       p_to_staffing_diff_percentage      => p_to_staffing_diff_percentage,
       p_award_percentage                 => p_award_percentage,
       p_rpa_type                         => p_rpa_type,
       p_mass_action_id                   => p_mass_action_id,
       p_mass_action_eligible_flag        => p_mass_action_eligible_flag,
       p_mass_action_select_flag          => p_mass_action_select_flag,
       p_mass_action_comments             => p_mass_action_comments
	);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'create_sf52',
				 p_hook_type	=> 'AP'
				);
 end;
 --
 -- End of After Process User Hook call
 --
 -- When in validation only mode raise the Validate_Enabled exception
 --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;

  --
  -- Set all output arguments
  --
  p_pa_request_id               := l_pa_request_id;

  hr_utility.set_location(' Leaving:'||l_proc, 11);
  exception
    when hr_api.validate_enabled then
   -- As the Validate_Enabled exception has been raised
   -- we must rollback to the savepoint

      ROLLBACK TO create_sf52;

    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
      p_pa_request_id               := null;
      p_par_object_version_number   := null;
      p_1_pa_routing_history_id     := null;
      p_1_prh_object_version_number := null;
      p_2_pa_routing_history_id     := null;
      p_2_prh_object_version_number := null;
     when others then
       rollback to create_sf52;
      --
      -- Reset IN OUT parameters and set OUT parameters
      --
      p_pa_request_id               := null;
      p_par_object_version_number   := null;
      p_1_pa_routing_history_id     := null;
      p_1_prh_object_version_number := null;
      p_2_pa_routing_history_id     := null;
      p_2_prh_object_version_number := null;
       raise;

      hr_utility.set_location(' Leaving:'||l_proc, 12);
  end create_sf52;

-- ----------------------------------------------------------------------------
-- |--------------------------< update_sf52>--------------------------|
-- ----------------------------------------------------------------------------
    procedure update_sf52
 (p_validate                     in boolean default false,
  p_pa_request_id                in number,
  p_noa_family_code              in varchar2         default hr_api.g_varchar2,
  p_routing_group_id             in number           default hr_api.g_number,
  p_par_object_version_number    in out nocopy number,
  p_proposed_effective_asap_flag in varchar2         default hr_api.g_varchar2,
  p_academic_discipline          in varchar2         default hr_api.g_varchar2,
  p_additional_info_person_id    in number           default hr_api.g_number,
  p_additional_info_tel_number   in varchar2         default hr_api.g_varchar2,
  p_altered_pa_request_id        in number           default hr_api.g_number,
  p_annuitant_indicator          in varchar2         default hr_api.g_varchar2,
  p_annuitant_indicator_desc     in varchar2         default hr_api.g_varchar2,
  p_appropriation_code1          in varchar2         default hr_api.g_varchar2,
  p_appropriation_code2          in varchar2         default hr_api.g_varchar2,
  p_approval_date                in date             default hr_api.g_date,
  p_approving_official_full_name in varchar2         default hr_api.g_varchar2,
  p_approving_official_work_titl in varchar2         default hr_api.g_varchar2,
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
  p_from_basic_pay               in number           default hr_api.g_number,
  p_from_grade_or_level          in varchar2         default hr_api.g_varchar2,
  p_from_locality_adj            in number           default hr_api.g_number,
  p_from_occ_code                in varchar2         default hr_api.g_varchar2,
  p_from_other_pay_amount        in number           default hr_api.g_number,
  p_from_pay_basis               in varchar2         default hr_api.g_varchar2,
  p_from_pay_plan                in varchar2         default hr_api.g_varchar2,
  -- FWFA Changes Bug#4444609
  p_input_pay_rate_determinant      in varchar2         default hr_api.g_varchar2,
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
  p_supervisory_status           in varchar2         default hr_api.g_varchar2,
  p_tenure                       in varchar2         default hr_api.g_varchar2,
  p_to_adj_basic_pay             in number           default hr_api.g_number,
  p_to_basic_pay                 in number           default hr_api.g_number,
  p_to_grade_id                  in number           default hr_api.g_number,
  p_to_grade_or_level            in varchar2         default hr_api.g_varchar2,
  p_to_job_id                    in number           default hr_api.g_number,
  p_to_locality_adj              in number           default hr_api.g_number,
  p_to_occ_code                  in varchar2         default hr_api.g_varchar2,
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
  p_print_sf50_flag              in varchar2         default 'N',
  p_printer_name                 in varchar2         default null,
  p_print_back_page              in varchar2         default 'Y',
  p_u_attachment_modified_flag   in  varchar2        default hr_api.g_varchar2,
  p_u_approved_flag              in  varchar2        default hr_api.g_varchar2,
  p_u_user_name_acted_on         in  varchar2        default hr_api.g_varchar2,
  p_u_action_taken               in  varchar2        default null,
  p_u_approval_status            in  varchar2        default hr_api.g_varchar2,
  p_i_user_name_routed_to        in  varchar2        default null,
  p_i_groupbox_id                in  number          default null,
  p_i_routing_list_id            in  number          default null,
  p_i_routing_seq_number         in  number          default null,
  p_capped_other_pay             in  number          default null,
  p_to_retention_allow_percentag in  number          default hr_api.g_number,
  p_to_supervisory_diff_percenta in  number          default hr_api.g_number,
  p_to_staffing_diff_percentage  in  number          default hr_api.g_number,
  p_award_percentage             in  number          default hr_api.g_number,
  p_rpa_type                     in  varchar2        default hr_api.g_varchar2,
  p_mass_action_id               in  number          default hr_api.g_number,
  p_mass_action_eligible_flag    in  varchar2        default hr_api.g_varchar2,
  p_mass_action_select_flag      in  varchar2        default hr_api.g_varchar2,
  p_mass_action_comments         in  varchar2        default hr_api.g_varchar2,
   -- Bug#4486823 RRR Changes
  p_payment_option               in varchar2         default null,
  p_award_salary                 in number           default hr_api.g_number,
  -- Bug#4486823 RRR Changes
  p_u_prh_object_version_number  out nocopy number,
  p_i_pa_routing_history_id      out nocopy number,
  p_i_prh_object_version_number  out nocopy number
  )
is
  --
  -- Declare cursors and local variables
  --

   l_proc                        varchar2(72) := g_package||'update_sf52';
   l_exists                      boolean := false;
   l_cnt_history                 number;
   l_routing_group_id            ghr_pa_requests.routing_group_id%TYPE;
   l_par_object_version_number   ghr_pa_requests.object_version_number%TYPE;
   l_from_cop                    ghr_pa_requests.from_other_pay_amount%TYPE;
   l_object_version_number       ghr_pa_requests.object_version_number%TYPE;
   l_u_pa_routing_history_id     ghr_pa_routing_history.pa_routing_history_id%TYPE;
   l_i_pa_routing_history_id     ghr_pa_routing_history.pa_routing_history_id%TYPE;
   l_u_prh_object_version_number ghr_pa_routing_history.object_version_number%TYPE;
   l_i_prh_object_version_number ghr_pa_routing_history.object_version_number%TYPE;
   l_effective_date              date := trunc(nvl(p_effective_date,sysdate));
   l_initiator_flag              ghr_pa_routing_history.initiator_flag%TYPE;
   l_requester_flag              ghr_pa_routing_history.requester_flag%TYPE;
   l_reviewer_flag               ghr_pa_routing_history.reviewer_flag%TYPE;
   l_personnelist_flag           ghr_pa_routing_history.personnelist_flag%TYPE;
   l_authorizer_flag             ghr_pa_routing_history.authorizer_flag%TYPE;
   l_approver_flag               ghr_pa_routing_history.approver_flag%TYPE;
   l_user_name_employee_id       per_people_f.person_id%TYPE;
   l_user_name_emp_first_name    per_people_f.first_name%TYPE;
   l_user_name_emp_last_name     per_people_f.last_name%TYPE;
   l_user_name_emp_middle_names  per_people_f.middle_names%TYPE;
   l_seq_numb                    ghr_pa_routing_history.routing_seq_number%TYPE;
   l_cur_seq_numb                ghr_pa_routing_history.routing_seq_number%TYPE;
   l_next_seq_numb               ghr_pa_routing_history.routing_seq_number%TYPE;
   l_next_groupbox_name          ghr_groupboxes.name%TYPE;
   l_next_groupbox_id            ghr_pa_routing_history.groupbox_id%TYPE;
   l_next_user_name              ghr_pa_routing_history.user_name%TYPE := p_i_user_name_routed_to;
   l_action_taken                ghr_pa_routing_history.action_taken%TYPE;
   l_old_action_taken            ghr_pa_routing_history.action_taken%TYPE;
   l_forward_to_name             ghr_pa_routing_history.user_name%type;
   l_rec                         ghr_pa_requests%rowtype;
  -- l_rec                          ghr_par_shd.g_old_rec%type;
   l_rei_rec                     ghr_pa_request_extra_info%rowtype;
   l_part_time_hours             ghr_pa_requests.part_time_hours%type;
   l_requesting_office_remarks_fl ghr_pa_requests.requesting_office_remarks_flag%type;
   l_proposed_effective_asap_flag ghr_pa_requests.proposed_effective_asap_flag%type;
   l_veterans_pref_for_rif       ghr_pa_requests.veterans_pref_for_rif%type;
   l_year_degree_attained        ghr_pa_requests.year_degree_attained%type;
   l_noa_family_code             ghr_pa_requests.noa_family_code%type;
   l_last_update_date            ghr_pa_requests.last_update_date%type;
   l_last_updated_by             ghr_pa_requests.last_updated_by%type;
   l_last_update_login           ghr_pa_requests.last_update_login%type;
   l_created_by                  ghr_pa_requests.created_by%type;
   l_creation_date               ghr_pa_requests.creation_date%type;
   l_flag                        varchar2(1);
   l_information_type            ghr_pa_request_info_types.information_type%type;
   l_set_print_options_status    boolean;
   l_request_status              number(15);
   l_employee_id                  per_people_f.person_id%type;
   l_approving_official_work_titl ghr_pa_requests.approving_official_work_title%type;
   l_approving_official_full_name ghr_pa_requests.approving_official_full_name%type;
   l_approval_date                date;
   l_sf50_approval_date           date;
   l_sf50_approving_ofcl_work_tit ghr_pa_requests.sf50_approving_ofcl_work_title%type;
   l_sf50_approving_ofcl_full_nam ghr_pa_requests.sf50_approving_ofcl_full_name%type;
   l_status                       ghr_pa_requests.status%type;
   l_message                      boolean := FALSE;
   l_asg_sf52			    ghr_api.asg_sf52_type;
   l_asg_non_sf52			    ghr_api.asg_non_sf52_type;
   l_asg_nte_dates		    ghr_api.asg_nte_dates_type;
   l_per_sf52			    ghr_api.per_sf52_type;
   l_per_group1			    ghr_api.per_group1_type;
   l_per_group2			    ghr_api.per_group2_type;
   l_per_scd_info			    ghr_api.per_scd_info_type;
   l_per_retained_grade		    ghr_api.per_retained_grade_type;
   l_per_probations		    ghr_api.per_probations_type;
   l_per_sep_retire               ghr_api.per_sep_retire_type;
   l_per_security			    ghr_api.per_security_type;
   l_per_conversions		    ghr_api.per_conversions_type;
   l_per_uniformed_services	    ghr_api.per_uniformed_services_type;
   l_pos_oblig			    ghr_api.pos_oblig_type;
   l_pos_grp2			    ghr_api.pos_grp2_type;
   l_pos_grp1			    ghr_api.pos_grp1_type;
   l_pos_valid_grade		    ghr_api.pos_valid_grade_type;
   l_pos_car_prog			    ghr_api.pos_car_prog_type;
   l_loc_info			    ghr_api.loc_info_type;
   l_wgi				    ghr_api.within_grade_increase_type;
   l_recruitment_bonus		    ghr_api.recruitment_bonus_type;
   l_relocation_bonus		    ghr_api.relocation_bonus_type;

   --Pradeep
   l_mddds_special_pay             ghr_api.mddds_special_pay_type;
   l_sf52_from_data		    ghr_api.prior_sf52_data_type;
   l_personal_info		    ghr_api.personal_info_type;
   l_gov_awards_type		    ghr_api.government_awards_type;
   l_perf_appraisal_type	    ghr_api.performance_appraisal_type;
   l_payroll_type			    ghr_api.government_payroll_type;
   l_conduct_perf_type		    ghr_api.conduct_performance_type;
   l_agency_sf52			    ghr_api.agency_sf52_type;
   l_agency_code			    varchar2(80);
   l_imm_entitlement              ghr_api.entitlement_type;
   l_imm_foreign_lang_prof_pay    ghr_api.foreign_lang_prof_pay_type;
   l_imm_edp_pay                  ghr_api.edp_pay_type;
   l_imm_hazard_pay               ghr_api.hazard_pay_type;
   l_imm_health_benefits          ghr_api.health_benefits_type;
   l_imm_danger_pay               ghr_api.danger_pay_type;
   l_imm_imminent_danger_pay      ghr_api.imminent_danger_pay_type;
   l_imm_living_quarters_allow    ghr_api.living_quarters_allow_type;
   l_imm_post_diff_amt            ghr_api.post_diff_amt_type;
   l_imm_post_diff_percent        ghr_api.post_diff_percent_type;
   l_imm_sep_maintenance_allow    ghr_api.sep_maintenance_allow_type;
   l_imm_supplemental_post_allow  ghr_api.supplemental_post_allow_type;
   l_imm_temp_lodge_allow         ghr_api.temp_lodge_allow_type;
   l_imm_premium_pay              ghr_api.premium_pay_type;
   l_imm_retirement_annuity       ghr_api.retirement_annuity_type;
   l_imm_severance_pay            ghr_api.severance_pay_type;
   l_imm_thrift_saving_plan       ghr_api.thrift_saving_plan;
   l_imm_retention_allow_review   ghr_api.retention_allow_review_type;
   l_imm_health_ben_pre_tax          ghr_api.health_ben_pre_tax_type;
   l_rpa_type                     ghr_pa_requests.rpa_type%type;
   l_mass_action_id               ghr_pa_requests.mass_action_id%type;
	l_imm_per_benefit_info			ghr_api.per_benefit_info_type;
    l_imm_retirement_info         ghr_api.per_retirement_info_type; --Bug# 7131104


   CURSOR     c_cnt_history IS
     SELECT   count(*) cnt
     FROM     ghr_pa_routing_history prh
     WHERE    prh.pa_request_id = p_pa_request_id;

  CURSOR   C_routing_history_id IS
    SELECT   prh.pa_routing_history_id,
             prh.object_version_number
    FROM     ghr_pa_routing_history prh
    WHERE    prh.pa_request_id = p_pa_request_id
    ORDER by prh.pa_routing_history_id desc;

  CURSOR   c_routing_group_id IS
    SELECT  par.routing_group_id
    FROM    ghr_pa_requests par
    WHERE   par.pa_request_id = p_pa_request_id;

  /* cursor     c_names is
     select   usr.employee_id,
              per.first_name,
              per.last_name,
              per.middle_names
     from     fnd_user      usr,
              per_people_f  per
     where    upper(p_u_user_name_acted_on)  = upper(usr.user_name)
     and      per.person_id           = usr.employee_id
     and      l_effective_date
     between  effective_start_date
     and      effective_end_date;  */
	 -- Bug 4863608 Perf. Repository changes
-- 8229939 modified to consider sysdate
	 CURSOR     c_names IS
     SELECT   usr.employee_id,
              per.first_name,
              per.last_name,
              per.middle_names
     FROM     fnd_user      usr,
              per_people_f  per
     WHERE     usr.user_name = UPPER(p_u_user_name_acted_on)
     AND      per.person_id           = usr.employee_id
     AND      trunc(sysdate)
     BETWEEN  effective_start_date
     AND      effective_end_date;

   CURSOR      cur_rout_list_used IS
     SELECT    prh.routing_seq_number
     FROM      ghr_pa_routing_history  prh
     WHERE     prh.pa_request_id      = p_pa_request_id
     AND       prh.routing_list_id    = p_i_routing_list_id
     ORDER  BY prh.pa_routing_history_id desc;

   CURSOR     cur_next_rout_seq IS
     SELECT   rlm.seq_number,
              rlm.groupbox_id,
              rlm.user_name
     FROM     ghr_routing_list_members  rlm
     WHERE    rlm.routing_list_id = p_i_routing_list_id
     AND      rlm.seq_number      > l_cur_seq_numb
     ORDER BY rlm.seq_number asc;


   CURSOR c_history_exists IS
   SELECT action_taken
   FROM   ghr_pa_routing_history prh
   WHERE  prh.pa_request_id = p_pa_request_id;

   CURSOR  c_groupbox_name IS
   SELECT gbx.name
   FROM   ghr_groupboxes gbx
   WHERE  gbx.groupbox_id = l_next_groupbox_id;

  CURSOR  c_pa_requests IS
    SELECT par.noa_family_code,
           par.last_update_date,
           par.last_updated_by,
           par.last_update_login,
           par.created_by,
           par.creation_date
    FROM   ghr_pa_requests par
    WHERE  pa_request_id = p_pa_request_id;

  CURSOR c_rei_rec IS
   SELECT pa_request_extra_info_id,
          object_version_number
   FROM   ghr_pa_request_extra_info rei
   WHERE  rei.pa_request_id    = p_pa_request_id
   AND    rei.information_type = l_information_type;

  CURSOR   c_ovn  IS
    SELECT par.object_version_number
    FROM   ghr_pa_requests par
    WHERE  par.pa_request_id = p_pa_request_id;

   CURSOR  c_get_det_for_cop IS
    SELECT par.employee_assignment_id,par.effective_date
    FROM   ghr_pa_requests par
    WHERE  par.pa_request_id = p_pa_request_id;

    --6976674
    CURSOR c_dual_cancel
        is
	select pa_request_id
        from   ghr_pa_requests
        where  pa_request_id in (select mass_action_id
                                 from   ghr_pa_requests
                                 where  pa_request_id = p_pa_request_id
                                 and    first_noa_code = '001'
				 and    mass_action_id is not null
                                 and    rpa_type = 'DUAL')
        and    pa_notification_id is not null
        and    first_noa_code = '001';
    --6976674

    --8286910
    cursor c_dual_sec_corr
        is
	select 1
	from  ghr_pa_requests
	where pa_request_id = p_pa_request_id
	and   mass_action_id < pa_request_id
	and   rpa_type = 'DUAL'
	and   second_noa_code = (select second_noa_code
	                         from   ghr_pa_requests
				 where pa_request_id = (select min(pa_request_id)
     	                                                from   ghr_pa_requests
                        	                        where  pa_notification_id is not null
	                                                connect by pa_request_id = prior altered_pa_request_id
                           	                        start with pa_request_id = p_pa_request_id));

   cursor c_first_corr_npa(p_first_pa_req_id in number)
       is
       select 1
       from   ghr_pa_requests
       where  pa_request_id = p_first_pa_req_id
       and    pa_notification_id is not null;
      --8286910
    --Begin Bug# 8510411

    l_to_position_id ghr_pa_requests.to_position_id%type;

    CURSOR c_to_pos_id IS
	SELECT to_position_id FROM ghr_pa_requests
	WHERE pa_request_id = p_pa_request_id;
    --End Bug# 8510411



  begin
    hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint
  --
  savepoint update_sf52;
  --
  -- Call Before Process User Hook
  --
  begin
	ghr_sf52_bk2.update_sf52_b	(
       p_noa_family_code                  => p_noa_family_code,
       p_pa_request_id                    => p_pa_request_id,
       p_routing_group_id                 => p_routing_group_id,
       p_proposed_effective_asap_flag     => p_proposed_effective_asap_flag,
       p_academic_discipline              => p_academic_discipline,
       p_additional_info_person_id        => p_additional_info_person_id,
       p_additional_info_tel_number       => p_additional_info_tel_number,
       p_altered_pa_request_id            => p_altered_pa_request_id,
       p_annuitant_indicator              => p_annuitant_indicator,
       p_annuitant_indicator_desc         => p_annuitant_indicator_desc,
       p_appropriation_code1              => p_appropriation_code1,
       p_appropriation_code2              => p_appropriation_code2,
       p_authorized_by_person_id          => p_authorized_by_person_id,
       p_authorized_by_title              => p_authorized_by_title,
       p_award_amount                     => p_award_amount,
       p_award_uom                        => p_award_uom,
       p_bargaining_unit_status           => p_bargaining_unit_status,
       p_citizenship                      => p_citizenship,
       p_concurrence_date                 => p_concurrence_date,
       p_custom_pay_calc_flag             => p_custom_pay_calc_flag,
       p_duty_station_code                => p_duty_station_code,
       p_duty_station_desc                => p_duty_station_desc,
       p_duty_station_location_id         => p_duty_station_location_id,
       p_duty_station_id                  => p_duty_station_id,
       p_education_level                  => p_education_level,
       p_effective_date                   => p_effective_date,
       p_employee_assignment_id           => p_employee_assignment_id,
       p_employee_date_of_birth           => p_employee_date_of_birth,
       p_employee_first_name              => p_employee_first_name,
       p_employee_last_name               => p_employee_last_name,
       p_employee_middle_names            => p_employee_middle_names,
       p_employee_national_identifier     => p_employee_national_identifier,
       p_fegli                            => p_fegli,
       p_fegli_desc                       => p_fegli_desc,
       p_first_action_la_code1            => p_first_action_la_code1,
       p_first_action_la_code2            => p_first_action_la_code2,
       p_first_action_la_desc1            => p_first_action_la_desc1,
       p_first_action_la_desc2            => p_first_action_la_desc2,
       p_first_noa_cancel_or_correct      => p_first_noa_cancel_or_correct,
       p_first_noa_id                     => p_first_noa_id,
       p_first_noa_code                   => p_first_noa_code,
       p_first_noa_desc                   => p_first_noa_desc,
       p_first_noa_pa_request_id          => p_first_noa_pa_request_id,
       p_flsa_category                    => p_flsa_category,
       p_forwarding_address_line1         => p_forwarding_address_line1,
       p_forwarding_address_line2         => p_forwarding_address_line2,
       p_forwarding_address_line3         => p_forwarding_address_line3,
       p_forwarding_country               => p_forwarding_country,
       p_forwarding_country_short_nam     => p_forwarding_country_short_nam,
       p_forwarding_postal_code           => p_forwarding_postal_code,
       p_forwarding_region_2              => p_forwarding_region_2,
       p_forwarding_town_or_city          => p_forwarding_town_or_city ,
       p_from_adj_basic_pay               => p_from_adj_basic_pay,
       p_from_basic_pay                   => p_from_basic_pay,
       p_from_grade_or_level              => p_from_grade_or_level,
       p_from_locality_adj                => p_from_locality_adj,
       p_from_occ_code                    => p_from_occ_code,
       p_from_other_pay_amount            => p_from_other_pay_amount,
       p_from_pay_basis                   => p_from_pay_basis,
       p_from_pay_plan                    => p_from_pay_plan,
       --FWFA Changes Bug#4444609
       -- p_input_pay_rate_determinant          => p_input_pay_rate_determinant,
       -- p_from_pay_table_identifier        => p_from_pay_table_identifier,
       -- FWFA Changes
       p_from_position_id                 => p_from_position_id,
       p_from_position_org_line1          => p_from_position_org_line1,
       p_from_position_org_line2          => p_from_position_org_line2,
       p_from_position_org_line3          => p_from_position_org_line3,
       p_from_position_org_line4          => p_from_position_org_line4,
       p_from_position_org_line5          => p_from_position_org_line5,
       p_from_position_org_line6          => p_from_position_org_line6,
       p_from_position_number             => p_from_position_number,
       p_from_position_seq_no             => p_from_position_seq_no,
       p_from_position_title              => p_from_position_title,
       p_from_step_or_rate                => p_from_step_or_rate,
       p_from_total_salary                => p_from_total_salary,
       p_functional_class                 => p_functional_class,
       p_notepad                          => p_notepad,
       p_part_time_hours                  => p_part_time_hours,
       p_pay_rate_determinant             => p_pay_rate_determinant,
       p_person_id                        => p_person_id,
       p_position_occupied                => p_position_occupied,
       p_proposed_effective_date          => p_proposed_effective_date,
       p_requested_by_person_id           => p_requested_by_person_id,
       p_requested_by_title               => p_requested_by_title,
       p_requested_date                   => p_requested_date,
       p_requesting_office_remarks_de     => p_requesting_office_remarks_de,
       p_requesting_office_remarks_fl     => p_requesting_office_remarks_fl,
       p_request_number                   => p_request_number,
       p_resign_and_retire_reason_des     => p_resign_and_retire_reason_des,
       p_retirement_plan                  => p_retirement_plan,
       p_retirement_plan_desc             => p_retirement_plan_desc,
       p_second_action_la_code1           => p_second_action_la_code1,
       p_second_action_la_code2           => p_second_action_la_code2,
       p_second_action_la_desc1           => p_second_action_la_desc1,
       p_second_action_la_desc2           => p_second_action_la_desc2,
       p_second_noa_cancel_or_correct     => p_second_noa_cancel_or_correct,
       p_second_noa_code                  => p_second_noa_code,
       p_second_noa_desc                  => p_second_noa_desc,
       p_second_noa_id                    => p_second_noa_id,
       p_second_noa_pa_request_id         => p_second_noa_pa_request_id,
       p_service_comp_date                => p_service_comp_date,
       p_supervisory_status               => p_supervisory_status,
       p_tenure                           => p_tenure,
       p_to_adj_basic_pay                 => p_to_adj_basic_pay,
       p_to_basic_pay                     => p_to_basic_pay,
       p_to_grade_id                      => p_to_grade_id,
       p_to_grade_or_level                => p_to_grade_or_level,
       p_to_job_id                        => p_to_job_id,
       p_to_locality_adj                  => p_to_locality_adj,
       p_to_occ_code                      => p_to_occ_code,
       p_to_organization_id               => p_to_organization_id,
       p_to_other_pay_amount              => p_to_other_pay_amount,
       p_to_au_overtime                   => p_to_au_overtime,
       p_to_auo_premium_pay_indicator     => p_to_auo_premium_pay_indicator,
       p_to_availability_pay              => p_to_availability_pay,
       p_to_ap_premium_pay_indicator      => p_to_ap_premium_pay_indicator,
       p_to_retention_allowance           => p_to_retention_allowance,
       p_to_supervisory_differential      => p_to_supervisory_differential,
       p_to_staffing_differential         => p_to_staffing_differential,
       p_to_pay_basis                     => p_to_pay_basis,
       p_to_pay_plan                      => p_to_pay_plan,
       -- FWFA Changes Bug#4444609
       -- p_to_pay_table_identifier          => p_to_pay_table_identifier,
       -- FWFA Changes
       p_to_position_id                   => p_to_position_id,
       p_to_position_org_line1            => p_to_position_org_line1,
       p_to_position_org_line2            => p_to_position_org_line2,
       p_to_position_org_line3            => p_to_position_org_line3,
       p_to_position_org_line4            => p_to_position_org_line4,
       p_to_position_org_line5            => p_to_position_org_line5,
       p_to_position_org_line6            => p_to_position_org_line6,
       p_to_position_number               => p_to_position_number,
       p_to_position_seq_no               => p_to_position_seq_no,
       p_to_position_title                => p_to_position_title,
       p_to_step_or_rate                  => p_to_step_or_rate,
       p_to_total_salary                  => p_to_total_salary,
       p_veterans_pref_for_rif            => p_veterans_pref_for_rif,
       p_veterans_preference              => p_veterans_preference,
       p_veterans_status                  => p_veterans_status,
       p_work_schedule                    => p_work_schedule,
       p_work_schedule_desc               => p_work_schedule_desc,
       p_year_degree_attained             => p_year_degree_attained,
       p_first_noa_information1           => p_first_noa_information1,
       p_first_noa_information2           => p_first_noa_information2,
       p_first_noa_information3           => p_first_noa_information3,
       p_first_noa_information4           => p_first_noa_information4,
       p_first_noa_information5           => p_first_noa_information5,
       p_second_lac1_information1         => p_second_lac1_information1,
       p_second_lac1_information2         => p_second_lac1_information2,
       p_second_lac1_information3         => p_second_lac1_information3,
       p_second_lac1_information4         => p_second_lac1_information4,
       p_second_lac1_information5         => p_second_lac1_information5,
       p_second_lac2_information1         => p_second_lac2_information1,
       p_second_lac2_information2         => p_second_lac2_information2,
       p_second_lac2_information3         => p_second_lac2_information3,
       p_second_lac2_information4         => p_second_lac2_information4,
       p_second_lac2_information5         => p_second_lac2_information5,
       p_second_noa_information1          => p_second_noa_information1,
       p_second_noa_information2          => p_second_noa_information2,
       p_second_noa_information3          => p_second_noa_information3,
       p_second_noa_information4          => p_second_noa_information4,
       p_second_noa_information5          => p_second_noa_information5,
       p_first_lac1_information1          => p_first_lac1_information1,
       p_first_lac1_information2          => p_first_lac1_information2,
       p_first_lac1_information3          => p_first_lac1_information3,
       p_first_lac1_information4          => p_first_lac1_information4,
       p_first_lac1_information5          => p_first_lac1_information5,
       p_first_lac2_information1          => p_first_lac2_information1,
       p_first_lac2_information2          => p_first_lac2_information2,
       p_first_lac2_information3          => p_first_lac2_information3,
       p_first_lac2_information4          => p_first_lac2_information4,
       p_first_lac2_information5          => p_first_lac2_information5,
       p_attribute_category               => p_attribute_category,
       p_attribute1                       => p_attribute1,
       p_attribute2                       => p_attribute2,
       p_attribute3                       => p_attribute3,
       p_attribute4                       => p_attribute4,
       p_attribute5                       => p_attribute5,
       p_attribute6                       => p_attribute6,
       p_attribute7                       => p_attribute7,
       p_attribute8                       => p_attribute8,
       p_attribute9                       => p_attribute9,
       p_attribute10                      => p_attribute10,
       p_attribute11                      => p_attribute11,
       p_attribute12                      => p_attribute12,
       p_attribute13                      => p_attribute13,
       p_attribute14                      => p_attribute14,
       p_attribute15                      => p_attribute15,
       p_attribute16                      => p_attribute16,
       p_attribute17                      => p_attribute17,
       p_attribute18                      => p_attribute18,
       p_attribute19                      => p_attribute19,
       p_attribute20                      => p_attribute20,
       p_print_sf50_flag                  => p_print_sf50_flag,
       p_printer_name                     => p_printer_name,
       p_u_attachment_modified_flag       => p_u_attachment_modified_flag,
       p_u_approved_flag                  => p_u_approved_flag,
       p_u_user_name_acted_on             => p_u_user_name_acted_on,
       p_u_action_taken                   => p_u_action_taken,
       p_u_approval_status                => p_u_approval_status,
       p_i_user_name_routed_to            => p_i_user_name_routed_to,
       p_i_groupbox_id                    => p_i_groupbox_id,
       p_i_routing_list_id                => p_i_routing_list_id,
       p_i_routing_seq_number             => p_i_routing_seq_number,
       p_capped_other_pay                 => p_capped_other_pay,
       p_par_object_version_number        => p_par_object_version_number,
       p_to_retention_allow_percentag     => p_to_retention_allow_percentag,
       p_to_supervisory_diff_percenta     => p_to_supervisory_diff_percenta,
       p_to_staffing_diff_percentage      => p_to_staffing_diff_percentage,
       p_award_percentage                 => p_award_percentage,
       p_rpa_type                         => p_rpa_type,
       p_mass_action_id                   => p_mass_action_id,
       p_mass_action_eligible_flag        => p_mass_action_eligible_flag,
       p_mass_action_select_flag          => p_mass_action_select_flag,
       p_mass_action_comments             => p_mass_action_comments
	);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'update_sf52',
				 p_hook_type	=> 'BP'
				);
  end;
  --
  -- End of Before Process User Hook call
  --
  hr_utility.set_location(l_proc, 6);
hr_utility.set_location('First LAC CODE is : ' ||l_proc || ' ' ||p_first_action_la_code1, 7);
  --
  -- Validation in addition to Row Handlers

  -- If the SF52 is processed for the person same as the user, then do not allow creation

  If nvl(p_person_id,hr_api.g_number) <> hr_api.g_number then
    -- get employee_id of the user
     for user_id in c_names loop
       If user_id.employee_id = p_person_id then
         hr_utility.set_message(8301,'GHR_38503_CANNOT_INIT_FOR_SELF');
         hr_utility.raise_error;
        End if;
      end loop;
   End if;

  --
  -- Routing Group _Id can be changed  only in a case where the request has been initiated
  -- but not yet routed , for instance when the user uses the task flow button to
  -- naviage to another form  and when he comes back he can change the routing_grouip_id

  if p_routing_group_id  is not null and p_routing_group_id <> hr_api.g_number then
     for rout_group_id in c_routing_group_id  loop
       l_routing_group_id := rout_group_id.routing_group_id;
       end loop;
       if nvl(l_routing_group_id,hr_api.g_number) <> p_routing_group_id then
         for cnt_of_history in c_cnt_history  loop
           l_cnt_history     := cnt_of_history.cnt;
           exit;
         end loop;
         if nvl(l_cnt_history,0) > 1 then
           hr_utility.set_message(8301,'GHR_38113_ROUT_GROUP_NON_UPD');
           hr_utility.raise_error;
         end if;
       end if;
  end if;


  hr_utility.set_location('approval date ' || to_char(l_approval_date),1);
  l_approval_date  :=  p_approval_date;
  l_approving_official_work_titl  :=  p_approving_official_work_titl;
  l_approving_official_full_name  :=  p_approving_official_full_name;

  hr_utility.set_location('approval_stat ' || p_u_approval_Status,1);
  If nvl(p_u_approval_status,hr_api.g_varchar2) = 'APPROVE' then
    If p_approval_date is null or p_approval_date = hr_api.g_date
       then
        hr_utility.set_location('approval date is not null',1);
        l_effective_date  :=  trunc(sysdate);
        l_approval_date   :=  sysdate;
         -- get the full_name of the approver - format First Name MiddleName. Last Name  -- p_user_name_acted_on
         for user_emp_name in c_names loop
           l_approving_official_full_name :=  user_emp_name.first_name;
           If user_emp_name.middle_names is not null then
             l_approving_official_full_name := l_approving_official_full_name
                      || ' ' ||substr(user_emp_name.middle_names,1,1) || '.'  || ' ' || user_emp_name.last_name ;
           Else
             l_approving_official_full_name := l_approving_official_full_name || ' ' || user_emp_name.last_name;
           End if;
           l_employee_id                  :=  user_emp_name.employee_id;
        end loop;
        if l_employee_id is not null then
           -- get the working title of the approver  -- would it be as of today
          l_approving_official_work_titl   :=  ghr_pa_requests_pkg.get_position_work_title
                                               (p_person_id          =>  l_employee_id,
                                                p_effective_date     =>  l_effective_date
                                               );
        End if;
    Else
       l_approving_official_work_titl    :=   p_approving_official_work_titl;
       l_approving_official_full_name    :=   p_approving_official_full_name;
       l_approval_date                   :=   p_approval_date;
    End if;
  End if;


  -- Update the SF50 approver details , when the user chooses to 'Update HR' (Immediate or Future)
  -- Derive for individual actions . For Mass Actions they are the same as the SF52 approver details
  -- the following the lines are for bug 715020. This is to ensure that we don't update the
  -- sf50 approval fields to null. Previously, the local versions of these variables would never
  -- have been initialized unless the action_taken was ('UPDATE_HR','FUTURE_ACTION')
  -- (see code immediately following.
  l_sf50_approval_date  	       :=   hr_api.g_date;
  l_sf50_approving_ofcl_work_tit     :=   hr_api.g_varchar2;
  l_sf50_approving_ofcl_full_nam     :=   hr_api.g_varchar2;

   If nvl(p_u_action_taken,hr_api.g_varchar2) in ('UPDATE_HR','FUTURE_ACTION') then
     If p_approval_date is not null and p_approval_date <> hr_api.g_date then
       l_sf50_approval_date  		      :=   p_approval_date;
       l_sf50_approving_ofcl_work_tit     :=   p_approving_official_work_titl;
       l_sf50_approving_ofcl_full_nam     :=   p_approving_official_full_name;
     Else
       l_sf50_approval_date  		      :=   sysdate;
       for user_emp_name in c_names loop
         l_sf50_approving_ofcl_full_nam   :=  user_emp_name.first_name;
         If user_emp_name.middle_names is not null then
           l_sf50_approving_ofcl_full_nam := l_sf50_approving_ofcl_full_nam
                  || ' ' ||substr(user_emp_name.middle_names,1,1) || '.'  || ' ' || user_emp_name.last_name ;
          Else
            l_sf50_approving_ofcl_full_nam := l_sf50_approving_ofcl_full_nam || ' ' || user_emp_name.last_name;
          End if;
          l_employee_id                    :=  user_emp_name.employee_id;
       end loop;
       if l_employee_id is not null then
           -- get the working title of the approver  -- would be as of today
         l_sf50_approving_ofcl_work_tit    :=  ghr_pa_requests_pkg.get_position_work_title
                                               (p_person_id            =>  l_employee_id
                                               );
       End if;
     End if;
   End if;


   hr_utility.set_location(l_proc, 7);

   l_par_object_version_number   := p_par_object_version_number;
   l_effective_date              := trunc(nvl(p_effective_date,sysdate));

  --

  -- Insert a row into pa_requests by calling the ins row handler
   l_object_version_number := p_par_object_version_number;

hr_utility.set_location('First LAC CODE is : ' ||l_proc || ' ' ||p_first_action_la_code1, 8);
hr_utility.set_location('l_effective_date : ' ||l_effective_date, 8);
hr_utility.set_location('p_noa_family_code : ' ||p_noa_family_code, 8);
-- Bug 2542417
      -- In some cases like Mass actions/Cancellation actions the assignment id and
      -- and effective_date are not available to fetch the capped other pay
      -- Below code fetches the effective_date and assignment id to be passed to
      -- ghr_pa_requests_pkg2.get_cop function

      for c_par  in c_get_det_for_cop loop
        hr_utility.set_location('c_par.employee_assignment_id : '
                            ||c_par.employee_assignment_id, 8);
        hr_utility.set_location('c_par.effective_date : '
                            ||c_par.effective_date, 8);
        l_from_cop        := nvl(ghr_pa_requests_pkg2.get_cop
                     (nvl(p_employee_assignment_id,c_par.employee_assignment_id)
                          ,c_par.effective_date)
                          ,p_from_other_pay_amount);
      end loop;


   ghr_par_upd.upd
   (
    p_pa_request_id                    => p_pa_request_id,
    p_noa_family_code                  => p_noa_family_code,
    p_routing_group_id                 => p_routing_group_id,
    p_proposed_effective_asap_flag     => p_proposed_effective_asap_flag,
    p_academic_discipline              => p_academic_discipline,
    p_additional_info_person_id        => p_additional_info_person_id,
    p_additional_info_tel_number       => p_additional_info_tel_number,
    p_altered_pa_request_id            => p_altered_pa_request_id,
    p_annuitant_indicator              => p_annuitant_indicator,
    p_annuitant_indicator_desc         => p_annuitant_indicator_desc,
    p_appropriation_code1              => p_appropriation_code1,
    p_appropriation_code2              => p_appropriation_code2,
    p_approval_date                    => l_approval_date,
    p_approving_official_full_name     => l_approving_official_full_name,
    p_approving_official_work_titl     => l_approving_official_work_titl,
    p_sf50_approval_date               => l_sf50_approval_date,
    p_sf50_approving_ofcl_full_nam     => l_sf50_approving_ofcl_full_nam,
    p_sf50_approving_ofcl_work_tit     => l_sf50_approving_ofcl_work_tit,
    p_authorized_by_person_id          => p_authorized_by_person_id,
    p_authorized_by_title              => p_authorized_by_title,
    p_award_amount                     => p_award_amount,
    p_award_uom                        => p_award_uom,
    p_bargaining_unit_status           => p_bargaining_unit_status,
    p_citizenship                      => p_citizenship,
    p_concurrence_date                 => p_concurrence_date,
    p_custom_pay_calc_flag             => p_custom_pay_calc_flag,
    p_duty_station_code                => p_duty_station_code,
    p_duty_station_desc                => p_duty_station_desc,
    p_duty_station_location_id         => p_duty_station_location_id,
    p_duty_station_id                  => p_duty_station_id,
    p_education_level                  => p_education_level,
    p_effective_date                   => p_effective_date,
    p_employee_assignment_id           => p_employee_assignment_id,
    p_employee_date_of_birth           => p_employee_date_of_birth,
    p_employee_first_name              => p_employee_first_name,
    p_employee_last_name               => p_employee_last_name,
    p_employee_middle_names            => p_employee_middle_names,
    p_employee_national_identifier     => p_employee_national_identifier,
    p_fegli                            => p_fegli,
    p_fegli_desc                       => p_fegli_desc,
    p_first_action_la_code1            => p_first_action_la_code1,
    p_first_action_la_code2            => p_first_action_la_code2,
    p_first_action_la_desc1            => p_first_action_la_desc1,
    p_first_action_la_desc2            => p_first_action_la_desc2,
    p_first_noa_cancel_or_correct      => p_first_noa_cancel_or_correct,
    p_first_noa_id                     => p_first_noa_id,
    p_first_noa_code                   => p_first_noa_code,
    p_first_noa_desc                   => p_first_noa_desc,
    p_first_noa_pa_request_id          => p_first_noa_pa_request_id,
    p_flsa_category                    => p_flsa_category,
    p_forwarding_address_line1         => p_forwarding_address_line1,
    p_forwarding_address_line2         => p_forwarding_address_line2,
    p_forwarding_address_line3         => p_forwarding_address_line3,
    p_forwarding_country               => p_forwarding_country,
    p_forwarding_country_short_nam     => p_forwarding_country_short_nam,
    p_forwarding_postal_code           => p_forwarding_postal_code,
    p_forwarding_region_2              => p_forwarding_region_2,
    p_forwarding_town_or_city          => p_forwarding_town_or_city ,
    p_from_adj_basic_pay               => p_from_adj_basic_pay,
    p_from_basic_pay                   => p_from_basic_pay,
    p_from_grade_or_level              => p_from_grade_or_level,
    p_from_locality_adj                => p_from_locality_adj,
    p_from_occ_code                    => p_from_occ_code,
 -- Bug 2353506
    p_from_other_pay_amount            => l_from_cop,
 -- End Bug 2353506
    p_from_pay_basis                   => p_from_pay_basis,
    p_from_pay_plan                    => p_from_pay_plan,
   -- FWFA Changes Bug#4444609
    p_input_pay_rate_determinant          => p_input_pay_rate_determinant,
    p_from_pay_table_identifier        => p_from_pay_table_identifier,
    -- FWFA Changes
    p_from_position_id                 => p_from_position_id,
    p_from_position_org_line1          => p_from_position_org_line1,
    p_from_position_org_line2          => p_from_position_org_line2,
    p_from_position_org_line3          => p_from_position_org_line3,
    p_from_position_org_line4          => p_from_position_org_line4,
    p_from_position_org_line5          => p_from_position_org_line5,
    p_from_position_org_line6          => p_from_position_org_line6,
    p_from_position_number             => p_from_position_number,
    p_from_position_seq_no             => p_from_position_seq_no,
    p_from_position_title              => p_from_position_title,
    p_from_step_or_rate                => p_from_step_or_rate,
    p_from_total_salary                => p_from_total_salary,
    p_functional_class                 => p_functional_class,
    p_notepad                          => p_notepad,
    p_part_time_hours                  => p_part_time_hours,
    p_pay_rate_determinant             => p_pay_rate_determinant,
    p_person_id                        => p_person_id,
    p_position_occupied			   => p_position_occupied,
    p_proposed_effective_date          => p_proposed_effective_date,
    p_requested_by_person_id           => p_requested_by_person_id,
    p_requested_by_title               => p_requested_by_title,
    p_requested_date                   => p_requested_date,
    p_requesting_office_remarks_de     => p_requesting_office_remarks_de,
    p_requesting_office_remarks_fl     => p_requesting_office_remarks_fl,
    p_request_number                   => p_request_number,
    p_resign_and_retire_reason_des     => p_resign_and_retire_reason_des,
    p_retirement_plan                  => p_retirement_plan,
    p_retirement_plan_desc             => p_retirement_plan_desc,
    p_second_action_la_code1           => p_second_action_la_code1,
    p_second_action_la_code2           => p_second_action_la_code2,
    p_second_action_la_desc1           => p_second_action_la_desc1,
    p_second_action_la_desc2           => p_second_action_la_desc2,
    p_second_noa_cancel_or_correct     => p_second_noa_cancel_or_correct,
    p_second_noa_code                  => p_second_noa_code,
    p_second_noa_desc                  => p_second_noa_desc,
    p_second_noa_id                    => p_second_noa_id,
    p_second_noa_pa_request_id         => p_second_noa_pa_request_id,
    p_service_comp_date                => p_service_comp_date,
    p_supervisory_status               => p_supervisory_status,
    p_tenure                           => p_tenure,
    p_to_adj_basic_pay                 => p_to_adj_basic_pay,
    p_to_basic_pay                     => p_to_basic_pay,
    p_to_grade_id                      => p_to_grade_id,
    p_to_grade_or_level                => p_to_grade_or_level,
    p_to_job_id                        => p_to_job_id,
    p_to_locality_adj                  => p_to_locality_adj,
    p_to_occ_code                      => p_to_occ_code,
    p_to_organization_id               => p_to_organization_id,
 -- Bug 2353506
    p_to_other_pay_amount              => nvl(p_capped_other_pay,p_to_other_pay_amount),
 -- End Bug 2353506
    p_to_au_overtime                   => p_to_au_overtime,
    p_to_auo_premium_pay_indicator     => p_to_auo_premium_pay_indicator,
    p_to_availability_pay              => p_to_availability_pay,
    p_to_ap_premium_pay_indicator      => p_to_ap_premium_pay_indicator,
    p_to_retention_allowance           => p_to_retention_allowance,
    p_to_supervisory_differential      => p_to_supervisory_differential,
    p_to_staffing_differential         => p_to_staffing_differential,
    p_to_pay_basis                     => p_to_pay_basis,
    p_to_pay_plan                      => p_to_pay_plan,
    -- FWFA Changes Bug#4444609
    p_to_pay_table_identifier          => p_to_pay_table_identifier,
    -- FWFA Changes
    p_to_position_id                   => p_to_position_id,
    p_to_position_org_line1            => p_to_position_org_line1,
    p_to_position_org_line2            => p_to_position_org_line2,
    p_to_position_org_line3            => p_to_position_org_line3,
    p_to_position_org_line4            => p_to_position_org_line4,
    p_to_position_org_line5            => p_to_position_org_line5,
    p_to_position_org_line6            => p_to_position_org_line6,
    p_to_position_number               => p_to_position_number,
    p_to_position_seq_no               => p_to_position_seq_no,
    p_to_position_title                => p_to_position_title,
    p_to_step_or_rate                  => p_to_step_or_rate,
    p_to_total_salary                  => p_to_total_salary,
    p_veterans_pref_for_rif            => p_veterans_pref_for_rif,
    p_veterans_preference              => p_veterans_preference,
    p_veterans_status                  => p_veterans_status,
    p_work_schedule                    => p_work_schedule,
    p_work_schedule_desc               => p_work_schedule_desc,
    p_year_degree_attained             => p_year_degree_attained,
    p_first_noa_information1           => p_first_noa_information1,
    p_first_noa_information2           => p_first_noa_information2,
    p_first_noa_information3           => p_first_noa_information3,
    p_first_noa_information4           => p_first_noa_information4,
    p_first_noa_information5           => p_first_noa_information5,
    p_second_lac1_information1         => p_second_lac1_information1,
    p_second_lac1_information2         => p_second_lac1_information2,
    p_second_lac1_information3         => p_second_lac1_information3,
    p_second_lac1_information4         => p_second_lac1_information4,
    p_second_lac1_information5         => p_second_lac1_information5,
    p_second_lac2_information1         => p_second_lac2_information1,
    p_second_lac2_information2         => p_second_lac2_information2,
    p_second_lac2_information3         => p_second_lac2_information3,
    p_second_lac2_information4         => p_second_lac2_information4,
    p_second_lac2_information5         => p_second_lac2_information5,
    p_second_noa_information1          => p_second_noa_information1,
    p_second_noa_information2          => p_second_noa_information2,
    p_second_noa_information3          => p_second_noa_information3,
    p_second_noa_information4          => p_second_noa_information4,
    p_second_noa_information5          => p_second_noa_information5,
    p_first_lac1_information1          => p_first_lac1_information1,
    p_first_lac1_information2          => p_first_lac1_information2,
    p_first_lac1_information3          => p_first_lac1_information3,
    p_first_lac1_information4          => p_first_lac1_information4,
    p_first_lac1_information5          => p_first_lac1_information5,
    p_first_lac2_information1          => p_first_lac2_information1,
    p_first_lac2_information2          => p_first_lac2_information2,
    p_first_lac2_information3          => p_first_lac2_information3,
    p_first_lac2_information4          => p_first_lac2_information4,
    p_first_lac2_information5          => p_first_lac2_information5,
    p_attribute_category               => p_attribute_category,
    p_attribute1                       => p_attribute1,
    p_attribute2                       => p_attribute2,
    p_attribute3                       => p_attribute3,
    p_attribute4                       => p_attribute4,
    p_attribute5                       => p_attribute5,
    p_attribute6                       => p_attribute6,
    p_attribute7                       => p_attribute7,
    p_attribute8                       => p_attribute8,
    p_attribute9                       => p_attribute9,
    p_attribute10                      => p_attribute10,
    p_attribute11                      => p_attribute11,
    p_attribute12                      => p_attribute12,
    p_attribute13                      => p_attribute13,
    p_attribute14                      => p_attribute14,
    p_attribute15                      => p_attribute15,
    p_attribute16                      => p_attribute16,
    p_attribute17                      => p_attribute17,
    p_attribute18                      => p_attribute18,
    p_attribute19                      => p_attribute19,
    p_attribute20                      => p_attribute20,
    p_object_version_number            => l_par_object_version_number,
    p_to_retention_allow_percentag     => p_to_retention_allow_percentag,
    p_to_supervisory_diff_percenta     => p_to_supervisory_diff_percenta,
    p_to_staffing_diff_percentage      => p_to_staffing_diff_percentage,
    p_award_percentage                 => p_award_percentage,
    p_rpa_type                         => p_rpa_type,
    p_mass_action_id                   => p_mass_action_id,
    p_mass_action_eligible_flag        => p_mass_action_eligible_flag,
    p_mass_action_select_flag          => p_mass_action_select_flag,
    p_mass_action_comments             => p_mass_action_comments,
    p_payment_option                   => p_payment_option,
    p_award_salary                     => p_award_salary
   );
hr_utility.set_location('First LAC CODE is : ' ||l_proc || ' ' ||p_first_action_la_code1, 1);

   hr_utility.set_location(l_proc || 'l_ovn' || to_char(l_par_object_version_number),2);
   p_par_object_version_number := l_par_object_version_number;
   hr_utility.set_location(l_proc, 8);

 --2)Write  into pa_remarks all mandatory remarks for the specific nature_of_action,
 --  in case of either a) first_nature_of_action is input for the first_time or (just insert new recds)
 --                    b) first nature_of_action has changed (delete and then insert new records)
 --

   if  nvl(p_first_noa_id,hr_api.g_number)
            <> nvl(ghr_par_shd.g_old_rec.first_noa_id,hr_api.g_number)  then
     hr_utility.set_location(l_proc, 9);

  -- delete the existing remarks
    delete from ghr_pa_remarks  pre
    where  pre.pa_request_id = p_pa_request_id
    and    pre.remark_id in
          (select remark_id
           from   ghr_noac_remarks
           where  nature_of_action_id = ghr_par_shd.g_old_rec.first_noa_id);
   if  p_first_noa_id is not null then
      hr_utility.set_location(l_proc, 10);

     insert   into ghr_pa_remarks
        (pa_remark_id
        ,pa_request_id
        ,remark_id
        ,description
        ,object_version_number
        )
     select  ghr_pa_remarks_s.nextval
             ,p_pa_request_id
             ,rem.remark_id
             ,rem.description
             ,1
      from    ghr_remarks       rem
             ,ghr_noac_remarks  nre
      where   nre.nature_of_action_id = p_first_noa_id
      and     nre.required_flag       = 'Y'
      and     l_effective_date
      between nre.date_from
      and     nvl(nre.date_to,l_effective_date)
      and     nre.remark_id = rem.remark_id;
     -- and     rem.enabled_flag       = 'Y'
     -- and     l_effective_date
     -- between rem.date_from
     -- and     nvl(rem.date_to,l_effective_date));
   end if;
  end if;

 if  nvl(p_second_noa_id,hr_api.g_number)
            <> nvl(ghr_par_shd.g_old_rec.second_noa_id,hr_api.g_number)  then

  -- delete the existing remarks
    delete from ghr_pa_remarks  pre
    where  pre.pa_request_id = p_pa_request_id
    and    pre.remark_id in
          (select remark_id
           from   ghr_noac_remarks
           where  nature_of_action_id = ghr_par_shd.g_old_rec.second_noa_id);
   if  p_second_noa_id is not null then
     insert   into ghr_pa_remarks
        (pa_remark_id
        ,pa_request_id
        ,remark_id
        ,description
        ,object_version_number
        )
     select  ghr_pa_remarks_s.nextval
             ,p_pa_request_id
             ,rem.remark_id
             ,rem.description
             ,1
      from    ghr_remarks       rem
             ,ghr_noac_remarks  nre
      where   nre.nature_of_action_id = p_second_noa_id
      and     nre.required_flag       = 'Y'
      and     l_effective_date
      between nre.date_from
      and     nvl(nre.date_to,l_effective_date)
      and     nre.remark_id = rem.remark_id;
     -- and     rem.enabled_flag       = 'Y'
     -- and     l_effective_date
     -- between rem.date_from
     -- and     nvl(rem.date_to,l_effective_date));
   end if;
  end if;


 If nvl(p_first_noa_code,hr_api.g_varchar2) <> '001'
  then

    If p_first_noa_id = hr_api.g_number then
      l_rec.first_noa_id := ghr_par_shd.g_old_rec.first_noa_id;
    Else
      l_rec.first_noa_id  := p_first_noa_id;
    End if;

    If p_second_noa_id = hr_api.g_number then
      l_rec.second_noa_id := ghr_par_shd.g_old_rec.second_noa_id;
    Else
      l_rec.second_noa_id  := p_second_noa_id;
    End if;

    If p_effective_date = hr_api.g_date then
      l_rec.effective_date  := ghr_par_shd.g_old_rec.effective_date;
    Else
      l_rec.effective_date  := p_effective_date;
    End if;

    If p_person_id = hr_api.g_number then
      l_rec.person_id := ghr_par_shd.g_old_rec.person_id;
    Else
      l_rec.person_id := p_person_id;
    End if;

    If p_employee_assignment_id = hr_api.g_number then
      l_rec.employee_assignment_id := ghr_par_shd.g_old_rec.employee_assignment_id;
    Else
      l_rec.employee_assignment_id := p_employee_assignment_id;
    End if;

    If p_to_position_id = hr_api.g_number then
      l_rec.to_position_id := ghr_par_shd.g_old_rec.to_position_id;
    Else
      l_rec.to_position_id := p_to_position_id;
    End if;

    if p_u_action_taken = 'NOT_ROUTED' then
      l_rpa_type       := p_rpa_type;
      l_mass_action_id := p_mass_action_id;
      If nvl(l_rpa_type,'##') = hr_api.g_varchar2 then
        l_rpa_type := ghr_par_shd.g_old_rec.rpa_type;
      End if;
      If nvl(l_mass_action_id,-9999) = hr_api.g_number then
        l_mass_action_id :=  ghr_par_shd.g_old_rec.mass_action_id;
      End if;
   End if;

    If (nvl(p_effective_date,hr_api.g_date)
      <> nvl(ghr_par_shd.g_old_rec.effective_date,hr_api.g_date)) or
        (nvl(p_person_id,hr_api.g_number)
      <> nvl(ghr_par_shd.g_old_rec.person_id,hr_api.g_number))
       or (p_noa_family_code = 'APP') or
   (l_action_taken = 'NOT_ROUTED' and l_mass_action_id is null and nvl(l_rpa_type,hr_api.g_varchar2) <> 'TA' ) then

      GHR_NON_SF52_EXTRA_INFO.fetch_generic_extra_info
     (p_pa_request_id        =>  p_pa_request_id,
      p_person_id            =>  l_rec.person_id,
      p_assignment_id        =>  l_rec.employee_assignment_id,
      p_effective_date       =>  trunc(nvl(l_rec.effective_date,sysdate)),
      p_refresh_flag         =>  'N'
      );
   End if;


   if  (nvl(p_first_noa_code,hr_api.g_varchar2)
      <> nvl(ghr_par_shd.g_old_rec.first_noa_code,hr_api.g_varchar2)) or
        (nvl(p_second_noa_code,hr_api.g_varchar2)
      <> nvl(ghr_par_shd.g_old_rec.second_noa_code,hr_api.g_varchar2)) or
         (nvl(p_effective_date,hr_api.g_date)
      <> nvl(ghr_par_shd.g_old_rec.effective_date,hr_api.g_date)) or
        (nvl(p_person_id,hr_api.g_number)
      <> nvl(ghr_par_shd.g_old_rec.person_id,hr_api .g_number)) or
        (nvl(p_to_position_id,hr_api.g_number)
      <> nvl(ghr_par_shd.g_old_rec.to_position_id,hr_api .g_number))
         then
     hr_utility.set_location('update/ delete extra info',1);


     GHR_NON_SF52_EXTRA_INFO.populate_noa_spec_extra_info
     (p_pa_request_id   => p_pa_request_id,
      p_first_noa_id    => l_rec.first_noa_id,
      p_second_noa_id   => l_rec.second_noa_id,
      p_person_id       => l_rec.person_id,
      p_assignment_id   => l_rec.employee_assignment_id,
      p_position_id     => l_rec.to_position_id,
      p_effective_date  => l_rec.effective_date,
      p_refresh_flag     =>  'N'
     );
   End if;
 End if;




 --
 --3)Derive all parmeters required to insert routing_history records.


   l_action_taken    := p_u_action_taken;
   hr_utility.set_location(l_proc, 11);
   if l_action_taken is null then
     if nvl(p_authorized_by_person_id,hr_api.g_number) <>
        nvl(ghr_par_shd.g_old_rec.authorized_by_person_id,hr_api.g_number) then
       l_action_taken := 'AUTHORIZED';
     elsif nvl(p_requested_by_person_id,hr_api.g_number) <>
           nvl(ghr_par_shd.g_old_rec.requested_by_person_id,hr_api.g_number) then
       l_action_taken := 'REQUESTED';
     else
       for history_exists in C_history_exists loop
         l_exists     := true;
         l_old_action_taken := history_exists.action_taken;
         exit;
       end loop;
       if l_exists = true then
         for cnt_history in c_cnt_history loop
           l_cnt_history    := cnt_history.cnt;
         end loop;
         if l_cnt_history = 1 and l_old_action_taken  = 'NOT_ROUTED' then
           l_action_taken := 'INITIATED';
         else
           l_action_taken := 'NO_ACTION';
         end if;
       else
         l_action_taken := 'INITIATED';
       end if;
     end if;
   end if;
    if l_action_taken not in('NOT_ROUTED','INITIATED','REQUESTED','AUTHORIZED','END_ROUTING','ENDED',
                              'NO_ACTION','REVIEWED','CANCELED','UPDATE_HR','UPDATE_HR_COMPLETE','NONE')
         then
       hr_utility.set_message(8301,'GHR_38110_INVALID_ACTION_TAKEN');
       hr_utility.raise_error;
    end if;
    -- Bug #1285393   Modified to add the if condition as not to update the status
    -- if action taken parameter is passed as NONE. (NONE is passed during the call made
    -- in Cancellation of APPT Sf52 to cancel the RPA's made after Appointment)
    if 	l_action_taken not in ('NONE') then

   ghr_sf52_api.get_par_status
   (p_effective_date          =>  p_effective_date,
    p_approval_date           =>  l_approval_date,
    p_requested_by_person_id  =>  p_requested_by_person_id,
    p_authorized_by_person_id =>  p_authorized_by_person_id,
    p_action_taken            =>  p_u_action_taken,
    --8279908
    p_pa_request_id           =>  p_pa_request_id,
    p_status                  =>  l_status
   );

    hr_utility.set_location('befor upd of status' ,1);
   ghr_par_upd.upd
   (p_pa_request_id   		=> p_pa_request_id,
    p_status          		=> l_status,
    p_object_version_number 	=> l_par_object_version_number
    );
   end if;
    hr_utility.set_location('l_status : ' || l_status,1);
    hr_utility.set_location('after upd of status' ,1);
    p_par_object_version_number := l_par_object_version_number;
    hr_utility.set_location('check ' ||l_action_taken,1);
    hr_utility.set_location('p_i_user_name_routed_to ' ||p_i_user_name_routed_to,1);
    hr_utility.set_location('p_i_groupbox_id ' ||p_i_groupbox_id,1);
    hr_utility.set_location('p_i_routing_list_id ' ||p_i_routing_list_id,1);

   if l_action_taken not in ('CANCELED','UPDATE_HR','UPDATE_HR_COMPLETE','NOT_ROUTED','NONE','ENDED','END_ROUTING') then
       if p_i_user_name_routed_to is null and
          p_i_groupbox_id        is null and
          p_i_routing_list_id     is null then
         hr_utility.set_message(8301,'GHR_38115_ROUT_INFO_REQD');
         hr_utility.raise_error;
       end if;
    end if;

   if  nvl(l_action_taken,hr_api.g_varchar2) not in ('CANCELED','UPDATE_HR_COMPLETE','NONE','ENDED')then
       hr_utility.set_location('check ' ||l_action_taken,1);
       hr_utility.set_location('check ' ||l_mass_action_id,1);
       hr_utility.set_location('Check ' || l_rpa_type,1);
 -- Do not routing history if Template record for Mass Actions.

 -- If (l_action_taken = 'NOT_ROUTED' and l_mass_action_id is not null                     --AVR
 --  and nvl(l_rpa_type,hr_api.g_varchar2) <> 'TA') or                                     --AVR
 --    (l_action_taken = 'NOT_ROUTED' and l_mass_action_id is null) then                   --AVR

 if nvl(l_rpa_type,hr_api.g_varchar2) <> 'TA' then                                         --AVR
    if (nvl(l_rpa_type,hr_api.g_varchar2) =  'A' and l_action_taken = 'NOT_ROUTED' ) then  --AVR
        hr_utility.set_location('Form Folder Updation ..Do not route ' ,1);                --AVR
    else                                                                                   --AVR

       for cur_routing_history_id in C_routing_history_id loop
       l_u_pa_routing_history_id     :=  cur_routing_history_id.pa_routing_history_id;
       l_u_prh_object_version_number :=  cur_routing_history_id.object_version_number;
       exit;
     end loop;
    hr_utility.set_location('in update sf52 api , user acted on is ' || p_u_user_name_acted_on,1);
     if p_u_user_name_acted_on is not null
-- RP
      and p_u_user_name_acted_on <> hr_api.g_varchar2 then
       hr_utility.set_location(l_proc, 12);

       ghr_pa_requests_pkg.get_roles
      (p_pa_request_id,
       p_routing_group_id,
       p_u_user_name_acted_on,
       l_initiator_flag,
       l_requester_flag,
       l_authorizer_flag,
       l_personnelist_flag,
       l_approver_flag,
       l_reviewer_flag
       );
        hr_utility.set_location(l_proc, 13);

       for name_rec in C_names loop
         l_user_name_employee_id      := name_rec.employee_id ;
         l_user_name_emp_first_name   := name_rec.first_name;
         l_user_name_emp_last_name    := name_rec.last_name;
         l_user_name_emp_middle_names := name_rec.middle_names;
         exit;
       end loop;
     end if;
 -- Update the latest record in the routing history for the specific request_id

     hr_utility.set_location(l_proc, 14);

     If l_action_taken = 'UPDATE_HR' and
        trunc(p_effective_date) > sysdate then
       l_action_taken := 'FUTURE_ACTION';
     End if;

     ghr_prh_upd.upd
     (
     p_pa_routing_history_id      => l_u_pa_routing_history_id,
     p_attachment_modified_flag   => nvl(p_u_attachment_modified_flag,'N'),
     p_initiator_flag             => nvl(l_initiator_flag,'N'),
     p_approver_flag              => nvl(l_approver_flag,'N'),
     p_reviewer_flag              => nvl(l_reviewer_flag,'N'),
     p_requester_flag             => nvl(l_requester_flag,'N'),
     p_authorizer_flag            => nvl(l_authorizer_flag,'N'),
     p_personnelist_flag          => nvl(l_personnelist_flag,'N'),
     p_approved_flag              => nvl(p_u_approved_flag,'N'),
     p_user_name                  => p_u_user_name_acted_on,
     p_user_name_employee_id      => l_user_name_employee_id,
     p_user_name_emp_first_name   => l_user_name_emp_first_name,
     p_user_name_emp_last_name    => l_user_name_emp_last_name,
     p_user_name_emp_middle_names => l_user_name_emp_middle_names,
     p_notepad                    => p_notepad,
     p_action_taken               => l_action_taken,
     p_noa_family_code            => p_noa_family_code,
     p_nature_of_action_id        => p_first_noa_id,
     p_second_nature_of_action_id => p_second_noa_id,
     p_approval_status            => p_u_approval_status,
     p_object_version_number      => l_u_prh_object_version_number
--     p_validate                 => p_validate
     );



  -- if the specific routing_list has already been used,get the next seq. no.from routing_list_members.
  -- else sequence_number = 1
  -- if there are no more sequences, raise an error

      l_next_seq_numb    :=   p_i_routing_seq_number;
      l_next_groupbox_id :=   p_i_groupbox_id;
      l_next_user_name   :=   p_i_user_name_routed_to;

-- fetch the next sequence number for the specific routing list, when it is not passed
      if p_i_routing_list_id is not null and p_i_routing_seq_number is null then

        for rout_list_used in cur_rout_list_used loop
          l_cur_seq_numb := rout_list_used.routing_seq_number;
          exit;
        end loop;

        if l_cur_seq_numb is null then
          l_cur_seq_numb := 0;
        end if;
        for next_rout_seq_numb in cur_next_rout_seq loop
          l_next_seq_numb      := next_rout_seq_numb.seq_number;
          l_next_groupbox_id   := next_rout_seq_numb.groupbox_id;
          l_next_user_name     := next_rout_seq_numb.user_name;
          exit;
         end loop;
         if l_next_user_name is null then
           l_next_user_name := p_i_user_name_routed_to;
         end if;
         if l_next_groupbox_id is null then
            l_next_groupbox_id := p_i_groupbox_id;
         end if;
         if l_next_seq_numb is null then
           hr_utility.set_message(8301, 'GHR_38114_NO_MORE_SEQ_NUMBER');
           hr_utility.raise_error;
         end if;
      end if;

       hr_utility.set_location(l_proc, 20);
       -- check for open events before  attempting to route / Update HR
        hr_utility.set_location('Before check Open Events',1);
        ghr_sf52_api.check_for_open_events
         (
	 p_pa_request_id        => p_pa_request_id,
	 p_message              => l_message,
	 p_action_taken         => l_action_taken,
	 p_user_name_acted_on   => p_u_user_name_acted_on,
	 p_user_name_routed_to  => l_next_user_name,
	 p_groupbox_routed_to   => l_next_groupbox_id
	 );

         -- call events user hook
	 ghr_agency_check.open_events_check
	 (p_pa_request_id       =>  p_pa_request_id,
	  p_message_set         =>  l_message
	  );

      if l_message then
        hr_utility.set_message(8301,'GHR_38592_OPEN_EVENTS_EXIST');
        hr_utility.raise_error;
      end if;

  -- Insert 2nd record into routing_history for routing details (with exceptions )

       /***dk***/
-- Should I add ENDED and/or END_ROUTING to the following if??
    if nvl(l_action_taken,hr_api.g_varchar2) not in  ('NOT_ROUTED','UPDATE_HR','FUTURE_ACTION','NONE','END_ROUTING') then

      ghr_prh_ins.ins
      (p_pa_routing_history_id        => l_i_pa_routing_history_id,
       p_pa_request_id                => p_pa_request_id,
       p_attachment_modified_flag     => 'N',
       p_initiator_flag               => 'N',
       p_approver_flag                => 'N',
       p_reviewer_flag                => 'N',
       p_requester_flag               => 'N',
       p_authorizer_flag              => 'N',
       p_personnelist_flag            => nvl(l_personnelist_flag,'N'),
       p_approved_flag                => 'N',
       p_user_name                    => l_next_user_name,
       p_groupbox_id                  => l_next_groupbox_id,
       p_routing_list_id              => p_i_routing_list_id,
       p_routing_seq_number           => l_next_seq_numb,
       p_noa_family_code              => p_noa_family_code,
       p_nature_of_action_id          => p_first_noa_id,
       p_second_nature_of_action_id   => p_second_noa_id,
       p_object_version_number        => l_i_prh_object_version_number
     --  p_validate                     => p_validate
       );

   end if;

   hr_utility.set_location('pAR' || to_char(l_par_object_version_number),1);

  if l_action_taken in  ('UPDATE_HR','FUTURE_ACTION','END_ROUTING')  then
     hr_utility.set_location(l_proc || p_award_amount,1);
     hr_utility.set_location(l_proc || p_award_percentage,1);

    hr_utility.set_location(l_proc, 21);
    l_rec.pa_request_id                    := p_pa_request_id;
    l_rec.noa_family_code                  := p_noa_family_code;
    l_rec.routing_group_id                 := p_routing_group_id;
    If p_proposed_effective_asap_flag = hr_api.g_varchar2 then
      l_rec.proposed_effective_asap_flag   := ghr_par_shd.g_old_rec.proposed_effective_asap_flag;
    Else
      l_rec.proposed_effective_asap_flag   := p_proposed_effective_asap_flag;
    End if;
    l_rec.academic_discipline              := p_academic_discipline;
    l_rec.additional_info_person_id        := p_additional_info_person_id;
    l_rec.additional_info_tel_number       := p_additional_info_tel_number;
    l_rec.altered_pa_request_id            := p_altered_pa_request_id;
    l_rec.annuitant_indicator              := p_annuitant_indicator;
    l_rec.annuitant_indicator_desc         := p_annuitant_indicator_desc;
    l_rec.appropriation_code1              := p_appropriation_code1;
    l_rec.appropriation_code2              := p_appropriation_code2;
    l_rec.approval_date                    := l_approval_date;
    l_rec.approving_official_work_title    := l_approving_official_work_titl;
    l_rec.approving_official_full_name     := l_approving_official_full_name;
    l_rec.authorized_by_person_id          := p_authorized_by_person_id;
    l_rec.authorized_by_title              := p_authorized_by_title;
    l_rec.award_amount                     := p_award_amount;
    l_rec.award_uom                        := p_award_uom;
    l_rec.bargaining_unit_status           := p_bargaining_unit_status;
    l_rec.citizenship                      := p_citizenship;
    l_rec.concurrence_date                 := p_concurrence_date;
    If p_custom_pay_calc_flag = hr_api.g_varchar2 then
      l_rec.custom_pay_calc_flag  := ghr_par_shd.g_old_rec.custom_pay_calc_flag;
    Else
      l_rec.custom_pay_calc_flag             := p_custom_pay_calc_flag;
    End if;
    l_rec.duty_station_code                := p_duty_station_code;
    l_rec.duty_station_desc                := p_duty_station_desc;
    l_rec.duty_station_id                  := p_duty_station_id;
    l_rec.duty_station_location_id         := p_duty_station_location_id;
    l_rec.education_level                  := p_education_level;
    l_rec.effective_date                   := p_effective_date;
    l_rec.employee_assignment_id           := p_employee_assignment_id;
    l_rec.employee_date_of_birth           := p_employee_date_of_birth;
    l_rec.employee_first_name              := p_employee_first_name;
    l_rec.employee_last_name               := p_employee_last_name;
    l_rec.employee_middle_names            := p_employee_middle_names;
    l_rec.employee_national_identifier     := p_employee_national_identifier;
    l_rec.fegli                            := p_fegli;
    l_rec.fegli_desc                       := p_fegli_desc;
hr_utility.set_location('First LAC CODE is : ' ||l_proc || ' ' ||l_rec.first_action_la_code1, 22);
    l_rec.first_action_la_code1            := p_first_action_la_code1;
hr_utility.set_location('First LAC CODE is : ' ||l_proc || ' ' ||l_rec.first_action_la_code1, 23);
    l_rec.first_action_la_code2            := p_first_action_la_code2;
    l_rec.first_action_la_desc1            := p_first_action_la_desc1;
    l_rec.first_action_la_desc2            := p_first_action_la_desc2;
    l_rec.first_noa_cancel_or_correct      := p_first_noa_cancel_or_correct;
    If p_first_noa_code   = hr_api.g_varchar2 then
      l_rec.first_noa_code                 :=  ghr_par_shd.g_old_rec.first_noa_code;
    Else
      l_rec.first_noa_code                 := p_first_noa_code;
    End if;
    l_rec.first_noa_desc                   := p_first_noa_desc;
    l_rec.first_noa_id                     := p_first_noa_id;
    l_rec.first_noa_pa_request_id          := p_first_noa_pa_request_id;
    l_rec.flsa_category                    := p_flsa_category;
    l_rec.forwarding_address_line1         := p_forwarding_address_line1;
    l_rec.forwarding_address_line2         := p_forwarding_address_line2;
    l_rec.forwarding_address_line3         := p_forwarding_address_line3;
    l_rec.forwarding_country               := p_forwarding_country;
    l_rec.forwarding_country_short_name    := p_forwarding_country_short_nam;
    l_rec.forwarding_postal_code           := p_forwarding_postal_code;
    l_rec.forwarding_region_2              := p_forwarding_region_2;
    l_rec.forwarding_town_or_city          := p_forwarding_town_or_city;
    l_rec.from_adj_basic_pay               := p_from_adj_basic_pay;
    l_rec.from_basic_pay                   := p_from_basic_pay;
    l_rec.from_grade_or_level              := p_from_grade_or_level;
    l_rec.from_locality_adj                := p_from_locality_adj;
    l_rec.from_occ_code                    := p_from_occ_code;
    l_rec.from_other_pay_amount            := p_from_other_pay_amount;
    l_rec.from_pay_basis                   := p_from_pay_basis;

    If p_from_pay_plan = hr_api.g_varchar2 then
      l_rec.from_pay_plan                  := ghr_par_shd.g_old_rec.from_pay_plan;
    Else
      l_rec.from_pay_plan                  := p_from_pay_plan;
    End if;
     -- FWFA Changes Bug#4444609
    l_rec.input_pay_rate_determinant          := p_input_pay_rate_determinant;
    l_rec.from_pay_table_identifier        := p_from_pay_table_identifier;
    -- FWFA Changes
    l_rec.from_position_id                 := p_from_position_id;
    l_rec.from_position_org_line1          := p_from_position_org_line1;
    l_rec.from_position_org_line2          := p_from_position_org_line2;
    l_rec.from_position_org_line3          := p_from_position_org_line3;
    l_rec.from_position_org_line4          := p_from_position_org_line4;
    l_rec.from_position_org_line5          := p_from_position_org_line5;
    l_rec.from_position_org_line6          := p_from_position_org_line6;
    l_rec.from_position_number             := p_from_position_number;
    l_rec.from_position_seq_no             := p_from_position_seq_no;
    l_rec.from_position_title              := p_from_position_title;
    l_rec.from_step_or_rate                := p_from_step_or_rate;
    l_rec.from_total_salary                := p_from_total_salary;
    l_rec.functional_class                 := p_functional_class;
    l_rec.notepad                          := p_notepad;
    If p_part_time_hours  = hr_api.g_number then
      l_rec.part_time_hours                := ghr_par_shd.g_old_rec.part_time_hours;
    Else
      l_rec.part_time_hours                := p_part_time_hours;
    End if;
    l_rec.pay_rate_determinant             := p_pay_rate_determinant;
    l_rec.person_id                        := p_person_id;
    l_rec.position_occupied                := p_position_occupied;
    l_rec.proposed_effective_date          := p_proposed_effective_date;
    l_rec.requested_by_person_id           := p_requested_by_person_id;
    l_rec.requested_by_title               := p_requested_by_title;
    l_rec.requested_date                   := p_requested_date;
    l_rec.requesting_office_remarks_desc   := p_requesting_office_remarks_de;
    If p_requesting_office_remarks_fl = hr_api.g_varchar2 then
      l_rec.requesting_office_remarks_flag := ghr_par_shd.g_old_rec.requesting_office_remarks_flag;
    Else
      l_rec.requesting_office_remarks_flag := p_requesting_office_remarks_fl;
    End if;

    l_rec.request_number                   := p_request_number;
    l_rec.resign_and_retire_reason_desc    := p_resign_and_retire_reason_des;
    l_rec.retirement_plan                  := p_retirement_plan;
    l_rec.retirement_plan_desc             := p_retirement_plan_desc;
    l_rec.second_action_la_code1           := p_second_action_la_code1;
    l_rec.second_action_la_code2           := p_second_action_la_code2;
    l_rec.second_action_la_desc1           := p_second_action_la_desc1;
    l_rec.second_action_la_desc2           := p_second_action_la_desc2;
    l_rec.second_noa_cancel_or_correct     := p_second_noa_cancel_or_correct;
    l_rec.second_noa_code                  := p_second_noa_code;
    l_rec.second_noa_desc                  := p_second_noa_desc;
    l_rec.second_noa_id                    := p_second_noa_id;
    l_rec.second_noa_pa_request_id         := p_second_noa_pa_request_id;
    l_rec.service_comp_date                := p_service_comp_date;
    l_rec.status                           := l_status;
    l_rec.supervisory_status               := p_supervisory_status;
    l_rec.tenure                           := p_tenure;
    l_rec.to_adj_basic_pay                 := p_to_adj_basic_pay;
    l_rec.to_basic_pay                     := p_to_basic_pay;
    l_rec.to_grade_id                      := p_to_grade_id;
    l_rec.to_grade_or_level                := p_to_grade_or_level;
    l_rec.to_job_id                        := p_to_job_id;
    l_rec.to_locality_adj                  := p_to_locality_adj;
    l_rec.to_occ_code                      := p_to_occ_code;
    l_rec.to_organization_id               := p_to_organization_id;
    l_rec.to_other_pay_amount              := p_to_other_pay_amount;
    l_rec.to_au_overtime                   := p_to_au_overtime;
    l_rec.to_auo_premium_pay_indicator     := p_to_auo_premium_pay_indicator;
    l_rec.to_availability_pay              := p_to_availability_pay;
    l_rec.to_ap_premium_pay_indicator      := p_to_ap_premium_pay_indicator;
    l_rec.to_retention_allowance           := p_to_retention_allowance;
    l_rec.to_supervisory_differential      := p_to_supervisory_differential;
    l_rec.to_staffing_differential         := p_to_staffing_differential;
    l_rec.to_pay_basis                     := p_to_pay_basis;
    If p_to_pay_plan =  hr_api.g_varchar2 then
      l_rec.to_pay_plan                    := ghr_par_shd.g_old_rec.to_pay_plan;
    Else
      l_rec.to_pay_plan                    := p_to_pay_plan;
    End if;
    -- FWFA Changes Bug# 4444609
    l_rec.to_pay_table_identifier          := p_to_pay_table_identifier;
    -- FWFA Changes
    l_rec.to_position_id                   := p_to_position_id;
    l_rec.to_position_org_line1            := p_to_position_org_line1;
    l_rec.to_position_org_line2            := p_to_position_org_line2;
    l_rec.to_position_org_line3            := p_to_position_org_line3;
    l_rec.to_position_org_line4            := p_to_position_org_line4;
    l_rec.to_position_org_line5            := p_to_position_org_line5;
    l_rec.to_position_org_line6            := p_to_position_org_line6;
    l_rec.to_position_number               := p_to_position_number;
    l_rec.to_position_seq_no               := p_to_position_seq_no;
    l_rec.to_position_title                := p_to_position_title;
    l_rec.to_step_or_rate                  := p_to_step_or_rate;
    l_rec.to_total_salary                  := p_to_total_salary;
    l_rec.veterans_preference              := p_veterans_preference;
    l_rec.veterans_pref_for_rif            := p_veterans_pref_for_rif;
    l_rec.veterans_status                  := p_veterans_status;
    l_rec.work_schedule                    := p_work_schedule;
    l_rec.work_schedule_desc               := p_work_schedule_desc;
    If p_year_degree_attained = hr_api.g_number then
      l_rec.year_degree_attained           := ghr_par_shd.g_old_rec.year_degree_attained;
    Else
      l_rec.year_degree_attained           := p_year_degree_attained;
    End if;

    l_rec.first_noa_information1           := p_first_noa_information1;
    l_rec.first_noa_information2           := p_first_noa_information2;
    l_rec.first_noa_information3           := p_first_noa_information3;
    l_rec.first_noa_information4           := p_first_noa_information4;
    l_rec.first_noa_information5           := p_first_noa_information5;
    l_rec.second_lac1_information1         := p_second_lac1_information1;
    l_rec.second_lac1_information2         := p_second_lac1_information2;
    l_rec.second_lac1_information3         := p_second_lac1_information3;
    l_rec.second_lac1_information4         := p_second_lac1_information4;
    l_rec.second_lac1_information5         := p_second_lac1_information5;
    l_rec.second_lac2_information1         := p_second_lac2_information1;
    l_rec.second_lac2_information2         := p_second_lac2_information2;
    l_rec.second_lac2_information3         := p_second_lac2_information3;
    l_rec.second_lac2_information4         := p_second_lac2_information4;
    l_rec.second_lac2_information5         := p_second_lac2_information5;
    l_rec.second_noa_information1          := p_second_noa_information1;
    l_rec.second_noa_information2          := p_second_noa_information2;
    l_rec.second_noa_information3          := p_second_noa_information3;
    l_rec.second_noa_information4          := p_second_noa_information4;
    l_rec.second_noa_information5          := p_second_noa_information5;
    l_rec.first_lac1_information1          := p_first_lac1_information1;
    l_rec.first_lac1_information2          := p_first_lac1_information2;
    l_rec.first_lac1_information3          := p_first_lac1_information3;
    l_rec.first_lac1_information4          := p_first_lac1_information4;
    l_rec.first_lac1_information5          := p_first_lac1_information5;
    l_rec.first_lac2_information1          := p_first_lac2_information1;
    l_rec.first_lac2_information2          := p_first_lac2_information2;
    l_rec.first_lac2_information3          := p_first_lac2_information3;
    l_rec.first_lac2_information4          := p_first_lac2_information4;
    l_rec.first_lac2_information5          := p_first_lac2_information5;
    l_rec.attribute_category               := p_attribute_category;
    l_rec.attribute1                       := p_attribute1;
    l_rec.attribute2                       := p_attribute2;
    l_rec.attribute3                       := p_attribute3;
    l_rec.attribute4                       := p_attribute4;
    l_rec.attribute5                       := p_attribute5;
    l_rec.attribute6                       := p_attribute6;
    l_rec.attribute7                       := p_attribute7;
    l_rec.attribute8                       := p_attribute8;
    l_rec.attribute9                       := p_attribute9;
    l_rec.attribute10                      := p_attribute10;
    l_rec.attribute11                      := p_attribute11;
    l_rec.attribute12                      := p_attribute12;
    l_rec.attribute13                      := p_attribute13;
    l_rec.attribute14                      := p_attribute14;
    l_rec.attribute15                      := p_attribute15;
    l_rec.attribute16                      := p_attribute16;
    l_rec.attribute17                      := p_attribute17;
    l_rec.attribute18                      := p_attribute18;
    l_rec.attribute19                      := p_attribute19;
    l_rec.attribute20                      := p_attribute20;
    l_rec.object_version_number            := l_par_object_version_number;
    If p_to_retention_allow_percentag = hr_api.g_number then
       l_rec.to_retention_allow_percentage := ghr_par_shd.g_old_rec.to_retention_allow_percentage;
    Else
      l_rec.to_retention_allow_percentage    := p_to_retention_allow_percentag;
    End if;
    If p_to_supervisory_diff_percenta = hr_api.g_number then
      l_rec.to_supervisory_diff_percentage := ghr_par_shd.g_old_rec.to_supervisory_diff_percentage;
    Else
      l_rec.to_supervisory_diff_percentage   := p_to_supervisory_diff_percenta;
    End if;
    If p_to_staffing_diff_percentage = hr_api.g_number then
      l_rec.to_staffing_diff_percentage    :=  ghr_par_shd.g_old_rec.to_staffing_diff_percentage;
    Else
      l_rec.to_staffing_diff_percentage      := p_to_staffing_diff_percentage;
    End if;
    If p_award_percentage   =  hr_api.g_number then
      l_rec.award_percentage             :=  ghr_par_shd.g_old_rec.award_percentage;
    Else
      l_rec.award_percentage                 := p_award_percentage;
    End if;
    l_rec.rpa_type                         := p_rpa_type;
    l_rec.mass_action_id                   := p_mass_action_id;

    If p_mass_action_eligible_flag         = hr_api.g_varchar2 then
      l_rec.mass_action_eligible_flag      := ghr_par_shd.g_old_rec.mass_action_eligible_flag;
    Else
      l_rec.mass_action_eligible_flag      := p_mass_action_eligible_flag;
    End if;
    If p_mass_action_select_flag         = hr_api.g_varchar2 then
      l_rec.mass_action_select_flag        := ghr_par_shd.g_old_rec.mass_action_select_flag;
    Else
      l_rec.mass_action_eligible_flag      := p_mass_action_eligible_flag;
    End if;

    l_rec.mass_action_comments             := p_mass_action_comments;
    -- Bug#   RRR Changes
    hr_utility.set_location('p_payment_option: '||p_payment_option,1);
    l_rec.pa_incentive_payment_option      := p_payment_option;
    hr_utility.set_location('p_award_salary: '||p_award_salary,2);
    l_rec.award_salary                     := p_award_salary;
    hr_utility.set_location('After p_award_salary: ',3);
    -- Bug#   RRR Changes

-- Convert the default values
    hr_utility.set_location('after l_rec assignment ',2);
hr_utility.set_location('Before First LAC CODE is : ' ||l_proc || ' ' ||l_rec.first_action_la_code1, 3);
    ghr_par_bus.convert_defaults(l_rec);
hr_utility.set_location('After First LAC CODE is : ' ||l_proc || ' ' ||l_rec.first_action_la_code1, 4);

--
-- call update-hr
   hr_utility.set_location('l_ovn' || to_char(l_rec.object_version_number),2);

    If l_rec.effective_date is null then
      hr_utility.set_message(8301,'GHR_38185_EFF_DATE_REQUIRED');
      ghr_upd_hr_validation.form_item_name := 'PAR.EFFECTIVE_DATE';
      hr_utility.raise_error;
    End if;
   if (l_action_taken <> 'END_ROUTING') then
   ghr_process_sf52.process_sf52
   (p_sf52_data     => l_rec
     ,p_capped_other_pay => p_capped_other_pay
   );
   end if;
   --Begin Bug# 8510411
   IF l_rec.noa_family_code ='CORRECT' AND l_rec.to_position_id IS NULL THEN
	FOR l_to_pos_id in c_to_pos_id LOOP
		l_to_position_id := l_to_pos_id.to_position_id;
	END LOOP;
    END IF;
    --End Bug# 8510411
    ghr_sf52_post_update.get_notification_details
  (p_pa_request_id                  =>  p_pa_request_id,
   p_effective_date                 =>  p_effective_date,
--   p_object_version_number          =>  p_imm_pa_request_rec.object_version_number,
   p_from_position_id               =>  l_rec.from_position_id,
   p_to_position_id                 =>  NVL(l_rec.to_position_id,l_to_position_id), --Bug# 8510411
   p_agency_code                    =>  l_rec.agency_code,
   p_from_agency_code               =>  l_rec.from_agency_code,
   p_from_agency_desc               =>  l_rec.from_agency_desc,
   p_from_office_symbol             =>  l_rec.from_office_symbol,
   p_personnel_office_id            =>  l_rec.personnel_office_id,
   p_employee_dept_or_agency        =>  l_rec.employee_dept_or_agency,
   p_to_office_symbol               =>  l_rec.to_office_symbol
   );
   for ovn_rec in c_ovn loop
     l_rec.object_version_number := ovn_rec.object_version_number;
   end loop;
   hr_utility.set_location('to pos id is '|| l_rec.to_position_id,1);
   hr_utility.set_location('first noa code is '|| l_rec.first_noa_code,1);
   IF nvl(l_rec.first_noa_code,'9999') <> '002' THEN
   ghr_par_upd.upd
   (p_pa_request_id                  =>  p_pa_request_id,
    p_object_version_number          =>  l_rec.object_version_number,
    p_from_position_id               =>  l_rec.from_position_id,
    p_to_position_id                 =>  l_rec.to_position_id,
    p_agency_code                    =>  l_rec.agency_code,
    p_from_agency_code               =>  l_rec.from_agency_code,
    p_from_agency_desc               =>  l_rec.from_agency_desc,
    p_from_office_symbol             =>  l_rec.from_office_symbol,
    p_personnel_office_id            =>  l_rec.personnel_office_id,
    p_employee_dept_or_agency        =>  l_rec.employee_dept_or_agency,
    p_to_office_symbol               =>  l_rec.to_office_symbol
   );
ELSE
   ghr_par_upd.upd
   (p_pa_request_id                  =>  p_pa_request_id,
    p_object_version_number          =>  l_rec.object_version_number,
    p_from_position_id               =>  l_rec.from_position_id,
    p_agency_code                    =>  l_rec.agency_code,
    p_from_agency_code               =>  l_rec.from_agency_code,
    p_from_agency_desc               =>  l_rec.from_agency_desc,
    p_from_office_symbol             =>  l_rec.from_office_symbol,
    p_personnel_office_id            =>  l_rec.personnel_office_id,
    p_employee_dept_or_agency        =>  l_rec.employee_dept_or_agency,
    p_to_office_symbol               =>  l_rec.to_office_symbol
   );
END IF;
   if (l_action_taken = 'END_ROUTING') then
	ghr_agency_update.ghr_agency_upd(
		p_pa_request_rec 		=>	l_rec,
		p_asg_sf52			=>	l_asg_sf52,
		p_asg_non_sf52          =>	l_asg_non_sf52,
 		p_asg_nte_dates         =>	l_asg_nte_dates,
 		p_per_sf52              =>	l_per_sf52,
 		p_per_group1            =>	l_per_group1,
 		p_per_group2            =>	l_per_group2,
 		p_per_scd_info          =>	l_per_scd_info,
 		p_per_retained_grade    =>	l_per_retained_grade,
 		p_per_probations        =>	l_per_probations,
 		p_per_sep_retire        =>	l_per_sep_retire,
 		p_per_security		=>	l_per_security,
 		p_per_conversions		=>	l_per_conversions,
 		p_per_uniformed_services =>	l_per_uniformed_services,
 		p_pos_oblig             =>	l_pos_oblig,
 		p_pos_grp2              =>	l_pos_grp2,
 		p_pos_grp1              =>	l_pos_grp1,
 		p_pos_valid_grade       =>	l_pos_valid_grade,
 		p_pos_car_prog          =>	l_pos_car_prog,
 		p_loc_info              =>	l_loc_info,
 		p_wgi     	            =>	l_wgi,
 		p_recruitment_bonus	=>	l_recruitment_bonus,
 		p_relocation_bonus	=>	l_relocation_bonus,

 		p_sf52_from_data        =>	l_sf52_from_data,
 		p_personal_info		=>	l_personal_info,
 		p_gov_awards_type       =>	l_gov_awards_type,
 		p_perf_appraisal_type   =>	l_perf_appraisal_type,
 		p_payroll_type          =>	l_payroll_type,
 		p_conduct_perf_type     =>	l_conduct_perf_type,
 		p_agency_sf52           =>	l_agency_sf52,
 		p_agency_code		=>	l_agency_code,
            p_entitlement           =>	l_imm_entitlement,
            p_foreign_lang_prof_pay =>	l_imm_foreign_lang_prof_pay,
            p_edp_pay               =>	l_imm_edp_pay,
            p_hazard_pay            =>	l_imm_hazard_pay,
            p_health_benefits       =>	l_imm_health_benefits,
            p_danger_pay            =>	l_imm_danger_pay,
            p_imminent_danger_pay   =>	l_imm_imminent_danger_pay,
            p_living_quarters_allow =>	l_imm_living_quarters_allow,
            p_post_diff_amt         =>	l_imm_post_diff_amt,
            p_post_diff_percent     =>	l_imm_post_diff_percent,
            p_sep_maintenance_allow =>	l_imm_sep_maintenance_allow,
            p_supplemental_post_allow  =>	l_imm_supplemental_post_allow,
            p_temp_lodge_allow      =>	l_imm_temp_lodge_allow,
            p_premium_pay           =>	l_imm_premium_pay,
            p_retirement_annuity    =>	l_imm_retirement_annuity,
            p_severance_pay         =>	l_imm_severance_pay,
            p_thrift_saving_plan    =>	l_imm_thrift_saving_plan,
            p_retention_allow_review    =>	l_imm_retention_allow_review,
            p_health_ben_pre_tax       =>	l_imm_health_ben_pre_tax,
            p_per_benefit_info         => l_imm_per_benefit_info,
            p_imm_retirement_info   =>  l_imm_retirement_info --Bug# 7131104
     	);
	ghr_sf52_api.end_sf52(	p_pa_request_id	=>	p_pa_request_id,
					p_action_taken	=>	'ENDED',
					p_par_object_version_number => l_rec.object_version_number);
   end if;
 end if;
 if (l_action_taken not in ('UPDATE_HR','END_ROUTING')) then
   ghr_api.call_workflow
   (p_pa_request_id     => p_pa_request_id,
    p_action_taken      => l_action_taken
   );
 end if;
end if; -- rpa-type = A and NOT_ROUTED         --- AVR
end if; -- If template record for mass Award   --- AVR
 elsif l_action_taken = 'NONE' then
   null;
 else
   hr_utility.set_message(8301,'GHR_38112_INVALID_API');
   hr_utility.raise_error;
 end if;

 If p_print_sf50_flag = 'Y' then

   If l_action_taken <> 'UPDATE_HR' then
     hr_utility.set_message(8301,'GHR_38399_52_NOT_PROCESSED');
     hr_utility.raise_error;
   End if;
   --Bug#3757201 Added p_back_page parameter
   -- Bug #8286910 Need to handle for dual correction
   if not(p_first_noa_code = '002' and p_rpa_type = 'DUAL' and p_mass_action_id is not null) then
      submit_request_to_print_50
       (p_printer_name                       => p_printer_name,
        p_pa_request_id                      => p_pa_request_id,
        p_effective_date                     => p_effective_date,
        p_user_name                          => p_u_user_name_acted_on,
        p_back_page                          => p_print_back_page
        );
   else ---Bug #8286910 For Dual Correction need to submit only during second correction
        --processing
       if p_first_noa_code = '002' and p_rpa_type = 'DUAL' and p_mass_action_id is not null then
          --checking for second dual correction
	 for chk_dual_sec_corr in c_dual_sec_corr
	 loop
	 -- Modified as First NPA need to be printed only if First NPA generation is selected
	   for chk_first_corr_npa in c_first_corr_npa(p_first_pa_req_id => p_mass_action_id)
	   loop
	    submit_request_to_print_50
               (p_printer_name                       => p_printer_name,
                p_pa_request_id                      => p_mass_action_id,
                p_effective_date                     => p_effective_date,
                p_user_name                          => p_u_user_name_acted_on,
                p_back_page                          => p_print_back_page
                );
	   end loop;
	    submit_request_to_print_50
              (p_printer_name                       => p_printer_name,
               p_pa_request_id                      => p_pa_request_id,
               p_effective_date                     => p_effective_date,
               p_user_name                          => p_u_user_name_acted_on,
               p_back_page                          => p_print_back_page
              );
	   end loop;
	end if;
     end if;
     ---Bug #8286910

    --6976674
    for rec in c_dual_cancel
    loop
      submit_request_to_print_50
       (p_printer_name                       => p_printer_name,
        p_pa_request_id                      => rec.pa_request_id,
        p_effective_date                     => p_effective_date,
        p_user_name                          => p_u_user_name_acted_on,
        p_back_page                          => p_print_back_page
       );
     end loop;
    --6976674

 End if;
 --
 -- Call After Process User Hook
 --
 begin
	ghr_sf52_bk2.update_sf52_a	(
       p_noa_family_code                  => p_noa_family_code,
       p_pa_request_id                    => p_pa_request_id,
       p_routing_group_id                 => p_routing_group_id,
       p_proposed_effective_asap_flag     => p_proposed_effective_asap_flag,
       p_academic_discipline              => p_academic_discipline,
       p_additional_info_person_id        => p_additional_info_person_id,
       p_additional_info_tel_number       => p_additional_info_tel_number,
       p_altered_pa_request_id            => p_altered_pa_request_id,
       p_annuitant_indicator              => p_annuitant_indicator,
       p_annuitant_indicator_desc         => p_annuitant_indicator_desc,
       p_appropriation_code1              => p_appropriation_code1,
       p_appropriation_code2              => p_appropriation_code2,
       p_authorized_by_person_id          => p_authorized_by_person_id,
       p_authorized_by_title              => p_authorized_by_title,
       p_award_amount                     => p_award_amount,
       p_award_uom                        => p_award_uom,
       p_bargaining_unit_status           => p_bargaining_unit_status,
       p_citizenship                      => p_citizenship,
       p_concurrence_date                 => p_concurrence_date,
       p_custom_pay_calc_flag             => p_custom_pay_calc_flag,
       p_duty_station_code                => p_duty_station_code,
       p_duty_station_desc                => p_duty_station_desc,
       p_duty_station_location_id         => p_duty_station_location_id,
       p_duty_station_id                  => p_duty_station_id,
       p_education_level                  => p_education_level,
       p_effective_date                   => p_effective_date,
       p_employee_assignment_id           => p_employee_assignment_id,
       p_employee_date_of_birth           => p_employee_date_of_birth,
       p_employee_first_name              => p_employee_first_name,
       p_employee_last_name               => p_employee_last_name,
       p_employee_middle_names            => p_employee_middle_names,
       p_employee_national_identifier     => p_employee_national_identifier,
       p_fegli                            => p_fegli,
       p_fegli_desc                       => p_fegli_desc,
       p_first_action_la_code1            => p_first_action_la_code1,
       p_first_action_la_code2            => p_first_action_la_code2,
       p_first_action_la_desc1            => p_first_action_la_desc1,
       p_first_action_la_desc2            => p_first_action_la_desc2,
       p_first_noa_cancel_or_correct      => p_first_noa_cancel_or_correct,
       p_first_noa_id                     => p_first_noa_id,
       p_first_noa_code                   => p_first_noa_code,
       p_first_noa_desc                   => p_first_noa_desc,
       p_first_noa_pa_request_id          => p_first_noa_pa_request_id,
       p_flsa_category                    => p_flsa_category,
       p_forwarding_address_line1         => p_forwarding_address_line1,
       p_forwarding_address_line2         => p_forwarding_address_line2,
       p_forwarding_address_line3         => p_forwarding_address_line3,
       p_forwarding_country               => p_forwarding_country,
       p_forwarding_country_short_nam     => p_forwarding_country_short_nam,
       p_forwarding_postal_code           => p_forwarding_postal_code,
       p_forwarding_region_2              => p_forwarding_region_2,
       p_forwarding_town_or_city          => p_forwarding_town_or_city ,
       p_from_adj_basic_pay               => p_from_adj_basic_pay,
       p_from_basic_pay                   => p_from_basic_pay,
       p_from_grade_or_level              => p_from_grade_or_level,
       p_from_locality_adj                => p_from_locality_adj,
       p_from_occ_code                    => p_from_occ_code,
       p_from_other_pay_amount            => p_from_other_pay_amount,
       p_from_pay_basis                   => p_from_pay_basis,
       p_from_pay_plan                    => p_from_pay_plan,
		-- FWFA Changes Bug#4444609
       -- p_input_pay_rate_determinant       => p_input_pay_rate_determinant,
       -- p_from_pay_table_identifier        => p_from_pay_table_identifier,
       -- FWFA Changes
       p_from_position_id                 => p_from_position_id,
       p_from_position_org_line1          => p_from_position_org_line1,
       p_from_position_org_line2          => p_from_position_org_line2,
       p_from_position_org_line3          => p_from_position_org_line3,
       p_from_position_org_line4          => p_from_position_org_line4,
       p_from_position_org_line5          => p_from_position_org_line5,
       p_from_position_org_line6          => p_from_position_org_line6,
       p_from_position_number             => p_from_position_number,
       p_from_position_seq_no             => p_from_position_seq_no,
       p_from_position_title              => p_from_position_title,
       p_from_step_or_rate                => p_from_step_or_rate,
       p_from_total_salary                => p_from_total_salary,
       p_functional_class                 => p_functional_class,
       p_notepad                          => p_notepad,
       p_part_time_hours                  => p_part_time_hours,
       p_pay_rate_determinant             => p_pay_rate_determinant,
       p_person_id                        => p_person_id,
       p_position_occupied                => p_position_occupied,
       p_proposed_effective_date          => p_proposed_effective_date,
       p_requested_by_person_id           => p_requested_by_person_id,
       p_requested_by_title               => p_requested_by_title,
       p_requested_date                   => p_requested_date,
       p_requesting_office_remarks_de     => p_requesting_office_remarks_de,
       p_requesting_office_remarks_fl     => p_requesting_office_remarks_fl,
       p_request_number                   => p_request_number,
       p_resign_and_retire_reason_des     => p_resign_and_retire_reason_des,
       p_retirement_plan                  => p_retirement_plan,
       p_retirement_plan_desc             => p_retirement_plan_desc,
       p_second_action_la_code1           => p_second_action_la_code1,
       p_second_action_la_code2           => p_second_action_la_code2,
       p_second_action_la_desc1           => p_second_action_la_desc1,
       p_second_action_la_desc2           => p_second_action_la_desc2,
       p_second_noa_cancel_or_correct     => p_second_noa_cancel_or_correct,
       p_second_noa_code                  => p_second_noa_code,
       p_second_noa_desc                  => p_second_noa_desc,
       p_second_noa_id                    => p_second_noa_id,
       p_second_noa_pa_request_id         => p_second_noa_pa_request_id,
       p_service_comp_date                => p_service_comp_date,
       p_supervisory_status               => p_supervisory_status,
       p_tenure                           => p_tenure,
       p_to_adj_basic_pay                 => p_to_adj_basic_pay,
       p_to_basic_pay                     => p_to_basic_pay,
       p_to_grade_id                      => p_to_grade_id,
       p_to_grade_or_level                => p_to_grade_or_level,
       p_to_job_id                        => p_to_job_id,
       p_to_locality_adj                  => p_to_locality_adj,
       p_to_occ_code                      => p_to_occ_code,
       p_to_organization_id               => p_to_organization_id,
       p_to_other_pay_amount              => p_to_other_pay_amount,
       p_to_au_overtime                   => p_to_au_overtime,
       p_to_auo_premium_pay_indicator     => p_to_auo_premium_pay_indicator,
       p_to_availability_pay              => p_to_availability_pay,
       p_to_ap_premium_pay_indicator      => p_to_ap_premium_pay_indicator,
       p_to_retention_allowance           => p_to_retention_allowance,
       p_to_supervisory_differential      => p_to_supervisory_differential,
       p_to_staffing_differential         => p_to_staffing_differential,
       p_to_pay_basis                     => p_to_pay_basis,
       p_to_pay_plan                      => p_to_pay_plan,
       -- FWFA Changes Bug#4444609
       -- p_to_pay_table_identifier          => p_to_pay_table_identifier,
       -- FWFA Changes
       p_to_position_id                   => p_to_position_id,
       p_to_position_org_line1            => p_to_position_org_line1,
       p_to_position_org_line2            => p_to_position_org_line2,
       p_to_position_org_line3            => p_to_position_org_line3,
       p_to_position_org_line4            => p_to_position_org_line4,
       p_to_position_org_line5            => p_to_position_org_line5,
       p_to_position_org_line6            => p_to_position_org_line6,
       p_to_position_number               => p_to_position_number,
       p_to_position_seq_no               => p_to_position_seq_no,
       p_to_position_title                => p_to_position_title,
       p_to_step_or_rate                  => p_to_step_or_rate,
       p_to_total_salary                  => p_to_total_salary,
       p_veterans_pref_for_rif            => p_veterans_pref_for_rif,
       p_veterans_preference              => p_veterans_preference,
       p_veterans_status                  => p_veterans_status,
       p_work_schedule                    => p_work_schedule,
       p_work_schedule_desc               => p_work_schedule_desc,
       p_year_degree_attained             => p_year_degree_attained,
       p_first_noa_information1           => p_first_noa_information1,
       p_first_noa_information2           => p_first_noa_information2,
       p_first_noa_information3           => p_first_noa_information3,
       p_first_noa_information4           => p_first_noa_information4,
       p_first_noa_information5           => p_first_noa_information5,
       p_second_lac1_information1         => p_second_lac1_information1,
       p_second_lac1_information2         => p_second_lac1_information2,
       p_second_lac1_information3         => p_second_lac1_information3,
       p_second_lac1_information4         => p_second_lac1_information4,
       p_second_lac1_information5         => p_second_lac1_information5,
       p_second_lac2_information1         => p_second_lac2_information1,
       p_second_lac2_information2         => p_second_lac2_information2,
       p_second_lac2_information3         => p_second_lac2_information3,
       p_second_lac2_information4         => p_second_lac2_information4,
       p_second_lac2_information5         => p_second_lac2_information5,
       p_second_noa_information1          => p_second_noa_information1,
       p_second_noa_information2          => p_second_noa_information2,
       p_second_noa_information3          => p_second_noa_information3,
       p_second_noa_information4          => p_second_noa_information4,
       p_second_noa_information5          => p_second_noa_information5,
       p_first_lac1_information1          => p_first_lac1_information1,
       p_first_lac1_information2          => p_first_lac1_information2,
       p_first_lac1_information3          => p_first_lac1_information3,
       p_first_lac1_information4          => p_first_lac1_information4,
       p_first_lac1_information5          => p_first_lac1_information5,
       p_first_lac2_information1          => p_first_lac2_information1,
       p_first_lac2_information2          => p_first_lac2_information2,
       p_first_lac2_information3          => p_first_lac2_information3,
       p_first_lac2_information4          => p_first_lac2_information4,
       p_first_lac2_information5          => p_first_lac2_information5,
       p_attribute_category               => p_attribute_category,
       p_attribute1                       => p_attribute1,
       p_attribute2                       => p_attribute2,
       p_attribute3                       => p_attribute3,
       p_attribute4                       => p_attribute4,
       p_attribute5                       => p_attribute5,
       p_attribute6                       => p_attribute6,
       p_attribute7                       => p_attribute7,
       p_attribute8                       => p_attribute8,
       p_attribute9                       => p_attribute9,
       p_attribute10                      => p_attribute10,
       p_attribute11                      => p_attribute11,
       p_attribute12                      => p_attribute12,
       p_attribute13                      => p_attribute13,
       p_attribute14                      => p_attribute14,
       p_attribute15                      => p_attribute15,
       p_attribute16                      => p_attribute16,
       p_attribute17                      => p_attribute17,
       p_attribute18                      => p_attribute18,
       p_attribute19                      => p_attribute19,
       p_attribute20                      => p_attribute20,
       p_print_sf50_flag                  => p_print_sf50_flag,
       p_printer_name                     => p_printer_name,
       p_u_attachment_modified_flag       => p_u_attachment_modified_flag,
       p_u_approved_flag                  => p_u_approved_flag,
       p_u_user_name_acted_on             => p_u_user_name_acted_on,
       p_u_action_taken                   => p_u_action_taken,
       p_u_approval_status                => p_u_approval_status,
       p_i_user_name_routed_to            => p_i_user_name_routed_to,
       p_i_groupbox_id                    => p_i_groupbox_id,
       p_i_routing_list_id                => p_i_routing_list_id,
       p_i_routing_seq_number             => p_i_routing_seq_number,
       p_capped_other_pay                 => p_capped_other_pay,
       p_i_pa_routing_history_id          => l_i_pa_routing_history_id,
       p_i_prh_object_version_number      => l_i_prh_object_version_number,
       p_par_object_version_number        => l_par_object_version_number,
       p_to_retention_allow_percentag     => p_to_retention_allow_percentag,
       p_to_supervisory_diff_percenta     => p_to_supervisory_diff_percenta,
       p_to_staffing_diff_percentage      => p_to_staffing_diff_percentage,
       p_award_percentage                 => p_award_percentage,
       p_rpa_type                         => p_rpa_type,
       p_mass_action_id                   => p_mass_action_id,
       p_mass_action_eligible_flag        => p_mass_action_eligible_flag,
       p_mass_action_select_flag          => p_mass_action_select_flag,
       p_mass_action_comments             => p_mass_action_comments
	);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'update_sf52',
				 p_hook_type	=> 'AP'
				);
 end;
 --
 -- End of After Process User Hook call
 --
 -- When in validation only mode raise the Validate_Enabled exception
 --
   if p_validate then
    raise hr_api.validate_enabled;
   end if;

 --
 -- Set all output arguments
 --
   p_i_pa_routing_history_id      := l_i_pa_routing_history_id;
   p_i_prh_object_version_number  := l_i_prh_object_version_number;
   p_par_object_version_number    := l_par_object_version_number;
 --
   hr_utility.set_location(' Leaving:'||l_proc, 11);
  exception
    when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_sf52;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
      p_par_object_version_number   := l_par_object_version_number;
      p_u_prh_object_version_number := null;
      p_i_pa_routing_history_id     := null;
      p_i_prh_object_version_number := l_i_prh_object_version_number;
    When others then
      Rollback to update_sf52;
      --
      -- Reset IN OUT parameters and set OUT parameters
      --
      p_par_object_version_number   := l_par_object_version_number;
      p_u_prh_object_version_number := null;
      p_i_pa_routing_history_id     := null;
      p_i_prh_object_version_number := l_i_prh_object_version_number;
      Raise;

    hr_utility.set_location(' Leaving:'||l_proc, 12);

  end update_sf52;

-- ----------------------------------------------------------------------------
-- |--------------------------< end_sf52>--------------------------|
-- ----------------------------------------------------------------------------

  procedure end_sf52
  (p_validate                        in      boolean   default false,
   p_pa_request_id                   in      number,
   p_user_name                       in      varchar2  default hr_api.g_varchar2,
   p_action_taken                    in      varchar2,
   p_altered_pa_request_id           in      number    default null,
   p_first_noa_code                  in      varchar2  default null,
   p_second_noa_code                 in      varchar2  default null,
   p_par_object_version_number       in out nocopy  number
   )is

  l_proc                         varchar2(72) := g_package||'end_sf52';
  l_effective_date               date;
  l_prh_rec                      ghr_pa_routing_history%rowtype;
  l_pa_routing_history_id        ghr_pa_routing_history.pa_routing_history_id%TYPE;
  l_count                        number;
  l_routing_group_id             ghr_pa_requests.routing_group_id%TYPE;
  l_user_name                    ghr_pa_routing_history.user_name%type;
  l_old_action_taken             ghr_pa_routing_history.action_taken%type;
  l_initiator_flag               ghr_pa_routing_history.initiator_flag%TYPE;
  l_requester_flag               ghr_pa_routing_history.requester_flag%TYPE;
  l_authorizer_flag              ghr_pa_routing_history.authorizer_flag%TYPE;
  l_approver_flag                ghr_pa_routing_history.approver_flag%TYPE;
  l_reviewer_flag                ghr_pa_routing_history.reviewer_flag%TYPE;
  l_personnelist_flag            ghr_pa_routing_history.personnelist_flag%TYPE;
  l_user_name_employee_id        ghr_pa_routing_history.user_name_employee_id%TYPE;
  l_user_name_emp_first_name     ghr_pa_routing_history.user_name_emp_first_name%TYPE;
  l_user_name_emp_last_name      ghr_pa_routing_history.user_name_emp_last_name%TYPE;
  l_user_name_emp_middle_names   ghr_pa_routing_history.user_name_emp_middle_names%TYPE;
  l_prh_object_version_number    ghr_pa_routing_history.object_version_number%TYPE;
  l_par_object_version_number    ghr_pa_routing_history.object_version_number%TYPE;
  l_result                       boolean;
  l_notepad                      ghr_pa_routing_history.notepad%type;
  l_noa_family_code              ghr_pa_routing_history.noa_family_code%type;
  l_first_noa_id                 ghr_pa_routing_history.nature_of_action_id%type;
  l_Second_noa_id                ghr_pa_routing_history.second_nature_of_action_id%type;
  l_groupbox_id                  ghr_pa_routing_history.groupbox_id%type;
  l_routing_list_id              ghr_pa_routing_history.routing_list_id%type;
  l_routing_seq_number           ghr_pa_routing_history.routing_seq_number%type;



  cursor     c_count_history is
    select   count(*) cnt
    from     ghr_pa_routing_history prh
    where    prh.pa_request_id  = p_pa_request_id;


  cursor     C_routing_history_id is
    select   prh.pa_routing_history_id,
             prh.pa_request_id,
--           ATTACHMENT_MODIFIED_FLAG
             prh.initiator_flag,
             prh.requester_flag,
             prh.authorizer_flag,
             prh.personnelist_flag,
             prh.approver_flag,
             prh.reviewer_flag,
--           prh.approved_flag,
             prh.user_name,
             prh.user_name_employee_id,
             prh.user_name_emp_first_name,
             prh.user_name_emp_last_name,
             prh.user_name_emp_middle_names,
             prh.notepad,
             prh.action_taken,
             prh.groupbox_id,
             prh.routing_list_id,
             prh.routing_seq_number,
             prh.nature_of_action_id,
             prh.noa_family_code,
             prh.second_nature_of_action_id,
             prh.object_version_number
--           prh.approval_status
    from     ghr_pa_routing_history prh
    where    prh.pa_request_id = p_pa_request_id
    Order by prh.pa_routing_history_id desc;



  cursor     c_request_details is
    select   par.effective_date,
             par.routing_group_id
    from     ghr_pa_requests par
    where    par.pa_request_id = p_pa_request_id;


/*  cursor     c_names is
    select   usr.employee_id,
             per.first_name,
             per.last_name,
             per.middle_names
    from     fnd_user      usr,
             per_people_f  per
    where    upper(l_user_name)  = upper(usr.user_name)
    and      per.person_id       = usr.employee_id
    and      l_effective_date
    between  effective_start_date
    and      effective_end_date;  */
	-- Bug 4863608 Perf. Repository changes
  --8229939 modified to consider sysdate
	CURSOR     c_names is
    SELECT   usr.employee_id,
             per.first_name,
             per.last_name,
             per.middle_names
    FROM     fnd_user      usr,
             per_people_f  per
    WHERE    usr.user_name = UPPER(l_user_name)
    AND      per.person_id       = usr.employee_id
    AND      trunc(sysdate)
    BETWEEN  effective_start_date
    AND      effective_end_date;


  begin
    hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint
  --
    savepoint end_sf52;
    --
    -- Call Before Process User Hook
    --
    begin
	ghr_sf52_bk3.end_sf52_b	(
         p_pa_request_id                =>  p_pa_request_id,
         p_user_name                    =>  p_user_name,
         p_action_taken                 =>  p_action_taken,
         p_altered_pa_request_id        =>  p_altered_pa_request_id,
         p_first_noa_code               =>  p_first_noa_code,
         p_second_noa_code              =>  p_second_noa_code,
         p_par_object_version_number    =>  p_par_object_version_number
	);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'end_sf52',
				 p_hook_type	=> 'BP'
				);
    end;
    --
    -- End of Before Process User Hook call
    --
    hr_utility.set_location(l_proc, 6);
    l_par_object_version_number := p_par_object_version_number;


    If p_first_noa_code in ('001','002') then
       ghr_sf52_api.Cancel_Cancor
      (p_altered_pa_request_id	=> p_altered_pa_request_id,
       p_noa_code_correct     	=> p_second_noa_code,
       p_result				=> l_result
       );
    End if;

    If not l_result then
       hr_utility.set_message(8301,'GHR_38264_INV_PA_REQ_CAN_COR');
       hr_utility.raise_error;
    End if;

   /***dk***/
-- Added ENDED to the following if.
    if nvl(p_action_taken,hr_api.g_varchar2) in ('CANCELED','UPDATE_HR_COMPLETE','ENDED') then

      for request_details in c_request_details loop
         l_effective_date   := trunc(request_details.effective_date);
         l_routing_group_id := request_details.routing_group_id;
      end loop;

      if l_effective_date is null then
         l_effective_date := trunc(sysdate);
      end if;

      ghr_par_upd.upd
      (p_pa_request_id           => p_pa_request_id
      ,p_status                  => p_action_taken
      ,p_object_version_number   => p_par_object_version_number
      );
   /***dk***/
-- Added ENDED to the following if.
       If p_action_taken  IN ('UPDATE_HR_COMPLETE','ENDED') then
         for cur_routing_history in C_routing_history_id loop
          l_pa_routing_history_id      :=  cur_routing_history.pa_routing_history_id;
          l_user_name                  :=  cur_routing_history.user_name;
          l_old_action_taken           :=  cur_routing_history.action_taken;
          l_prh_object_version_number  :=  cur_routing_history.object_version_number;
          l_initiator_flag             :=  cur_routing_history.initiator_flag;
          l_requester_flag             :=  cur_routing_history.requester_flag;
          l_authorizer_flag            :=  cur_routing_history.authorizer_flag;
          l_personnelist_flag          :=  cur_routing_history.personnelist_flag;
          l_approver_flag              :=  cur_routing_history.approver_flag;
          l_reviewer_flag              :=  cur_routing_history.reviewer_flag;
          l_user_name                  :=  cur_routing_history.user_name;
          l_USER_NAME_EMPLOYEE_ID      :=  cur_routing_history.USER_NAME_EMPLOYEE_ID;
          l_USER_NAME_EMP_FIRST_NAME   :=  cur_routing_history.USER_NAME_emp_first_name;
	    l_USER_NAME_EMP_LAST_NAME    :=  cur_routing_history.USER_NAME_emp_last_name;
	    l_USER_NAME_EMP_MIDDLE_NAMES :=  cur_routing_history.USER_NAME_emp_middle_names;
          l_GROUPBOX_ID                :=  cur_routing_history.groupbox_id;
          l_ROUTING_LIST_ID            :=  cur_routing_history.routing_list_id;
          l_ROUTING_SEQ_NUMBER         :=  cur_routing_history.routing_seq_number;
    	    l_first_noa_id               := cur_routing_history.nature_of_action_id;
	    l_NOA_FAMILY_CODE            := cur_routing_history.noa_family_code;
	    l_SECOND_noa_id 		   := cur_routing_history.second_nature_of_action_id;
          exit;
        end loop;
        ghr_prh_ins.ins
        (
        p_pa_routing_history_id      => l_pa_routing_history_id,
        p_pa_request_id              => p_pa_request_id,
        p_attachment_modified_flag   => 'N',
        p_initiator_flag             => nvl(l_initiator_flag,'N'),
        p_approver_flag              => nvl(l_approver_flag,'N'),
        p_reviewer_flag              => nvl(l_reviewer_flag,'N') ,
        p_requester_flag             => nvl(l_requester_flag,'N') ,
        p_authorizer_flag            => nvl(l_authorizer_flag,'N'),
        p_approved_flag              => 'N',
        p_personnelist_flag          => nvl(l_personnelist_flag,'N'),
        p_user_name                  => l_user_name,
        p_user_name_employee_id      => l_user_name_employee_id,
        p_user_name_emp_first_name   => l_user_name_emp_first_name,
        p_user_name_emp_last_name    => l_user_name_emp_last_name ,
        p_user_name_emp_middle_names => l_user_name_emp_middle_names,
        p_action_taken               => p_action_taken,
        p_groupbox_id                => l_groupbox_id,
        p_routing_list_id            => l_routing_list_id,
        p_routing_seq_number         => l_routing_seq_number,
        p_noa_family_code            => l_noa_family_code,
        p_nature_of_action_id        => l_first_noa_id,
        p_second_nature_of_action_id => l_second_noa_id,
        p_object_version_number      => l_prh_object_version_number
       );


      Elsif p_action_taken = 'CANCELED' then
        for cur_routing_history in C_routing_history_id loop
          l_pa_routing_history_id     :=  cur_routing_history.pa_routing_history_id;
          l_user_name                 :=  cur_routing_history.user_name;
          l_old_action_taken          :=  cur_routing_history.action_taken;
          l_prh_object_version_number :=  cur_routing_history.object_version_number;
          exit;
        end loop;

   -- If the Form calls end_sf52 directly to Cancel an SF52, then
   -- the user_name (acted_on) has to be passed. Therefore the one from
   -- the database may not necessarily be the correct one., in which case the p_user_name should be further used.

      If nvl(p_user_name,hr_api.g_varchar2) <> hr_api.g_varchar2 then
         l_user_name    :=  p_user_name;
      End if;

     --  The foll. was Removed on 08/16 as per Vikram

     /* If l_user_name is null then
         hr_utility.set_message(8301,'GHR_38111_USER_NAME_REQD');
         hr_utility.raise_error;
     End if;
     */


       If l_user_name is not null then
        ghr_pa_requests_pkg.get_roles
       (p_pa_request_id,
        l_routing_group_id,
        l_user_name,
        l_initiator_flag,
        l_requester_flag,
        l_authorizer_flag,
        l_personnelist_flag,
        l_approver_flag,
        l_reviewer_flag
        );

        for name_rec in C_names loop
          l_user_name_employee_id      := name_rec.employee_id ;
          l_user_name_emp_first_name   := name_rec.first_name;
          l_user_name_emp_last_name    := name_rec.last_name;
          l_user_name_emp_middle_names := name_rec.middle_names;
          exit;
        end loop;
      end if;

        hr_utility.set_location('before upd to prh',1);
        hr_utility.set_location('emp id ' || to_char(l_user_name_employee_id),1);

       ghr_prh_upd.upd
       (p_pa_routing_history_id      => l_pa_routing_history_id
       ,p_user_name                  => l_user_name
       ,p_initiator_flag             => nvl(l_initiator_flag,'N')
       ,p_requester_flag             => nvl(l_requester_flag,'N')
       ,p_authorizer_flag            => nvl(l_authorizer_flag,'N')
       ,p_personnelist_flag          => nvl(l_personnelist_flag,'N')
       ,p_approver_flag              => nvl(l_approver_flag,'N')
       ,p_reviewer_flag              => nvl(l_reviewer_flag,'N')
       ,p_user_name_employee_id      => l_user_name_employee_id
       ,p_user_name_emp_first_name   => l_user_name_emp_first_name
       ,p_user_name_emp_last_name    => l_user_name_emp_last_name
       ,p_user_name_emp_middle_names => l_user_name_emp_middle_names
       ,p_action_taken               => p_action_taken
       ,p_object_version_number      => l_prh_object_version_number
       );
      End if;


-- call work flow
    ghr_api.call_workflow
    (p_pa_request_id     => p_pa_Request_id,
     p_action_taken      => p_action_taken,
     p_old_action_taken  => l_old_action_taken
    );

   else
     hr_utility.set_location('action_taken: ' || p_action_taken ,1);
     hr_utility.set_message(8301,'GH_38112_INVALID_API');
     hr_utility.raise_error;
   end if;

   --
   -- Call After Process User Hook
   --
   begin
	ghr_sf52_bk3.end_sf52_a	(
         p_pa_request_id                =>  p_pa_request_id,
         p_user_name                    =>  p_user_name,
         p_action_taken                 =>  p_action_taken,
         p_altered_pa_request_id        =>  p_altered_pa_request_id,
         p_first_noa_code               =>  p_first_noa_code,
         p_second_noa_code              =>  p_second_noa_code,
         p_par_object_version_number    =>  l_par_object_version_number
	);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'end_sf52',
				 p_hook_type	=> 'AP'
				);
   end;
   --
   -- End of After Process User Hook call
   --
   if p_validate then
     raise hr_api.validate_enabled;
   end if;


 -- Set all output arguments
 --

   hr_utility.set_location(' Leaving:'||l_proc, 11);
  exception
    when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO end_sf52;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
      p_par_object_version_number   := l_par_object_version_number;

     When others then
       Rollback to end_sf52;
      --
      -- Reset IN OUT parameters and set OUT parameters
      --
      p_par_object_version_number   := l_par_object_version_number;
       Raise;

    hr_utility.set_location(' Leaving:'||l_proc, 12);
  end end_sf52;



-- Procedure Cancel_cancor marks the request available for cancellation/correction.
-- This procedure is called when user cancel's the request from Inbox or from sf52
--

Procedure Cancel_Cancor
(p_altered_pa_request_id	in	number,
 p_noa_code_correct     	in    varchar2,
 p_result			 out nocopy boolean
)
 is

Cursor c_get_req ( cp_pa_request_id number) is
  select rowid row_id,
         first_noa_code,
         second_noa_code,
         object_version_number
  from   ghr_pa_requests
  where  pa_request_id = cp_pa_request_id
  for update;

l_req		             c_get_req%rowtype;
l_proc	             varchar2(30):='Cancel_corcan';
l_object_version_number  number;

Begin
  hr_utility.set_location( 'entering :' || l_proc , 10);
  for get_req in c_get_req(p_altered_pa_request_id) loop
     l_req.first_noa_code                := get_Req.first_noa_code;
     l_req.second_noa_code               := get_req.second_noa_code;
     l_object_version_number             := get_req.object_version_number;
    if l_object_version_number is null then
       hr_utility.set_location( 'not found ' || l_proc, 20);
       p_result := FALSE;
  else
    if l_req.first_noa_code = p_noa_code_correct then
       hr_utility.set_location( 'first noa ' || l_proc, 30);
       ghr_par_upd.upd
        (p_pa_request_id                =>  p_altered_pa_request_id,
         p_object_version_number        =>  l_object_version_number,
--         p_first_noa_cancel_or_correct =>  null,
         p_first_noa_canc_pa_request_id =>  null
        );

	elsif l_req.second_noa_code = p_noa_code_correct then
	  hr_utility.set_location( '2nd NOA ' || l_proc, 60);
        ghr_par_upd.upd
        (p_pa_request_id                =>  p_altered_pa_request_id,
         p_object_version_number        =>  l_object_version_number,
--         p_second_noa_cancel_or_correct =>  null,
         p_second_noa_canc_pa_request_i=>  null
        );
	else
	  hr_utility.set_location( 'not found ' || l_proc, 90);
	  p_result := FALSE;
	end if;
   end if;
    end loop;
   hr_utility.set_location( 'Leaving :' || l_proc, 100);
 Exception when others then
   --
   -- Reset IN OUT parameters and set OUT parameters
   --
   p_result := null;
   raise;
 End Cancel_Cancor;

--Bug#3757201 Added p_back_page parameter
Procedure submit_request_to_print_50
(p_printer_name                       in varchar2,
 p_pa_request_id                      in ghr_pa_requests.pa_request_id%type,
 p_effective_date                      in date,
 p_user_name                          in varchar2,
 p_back_page			       in varchar2
 )
 is

 l_proc                        varchar2(72) := g_package || 'print_sf50';
 l_set_print_options_status    boolean;
 l_request_status              number(15);
 l_user_id                     fnd_user.user_id%type;

 Cursor c_user_id is
   select user_id
   from   fnd_user
   where  user_name = p_user_name;

 begin
   If trunc(p_effective_date) > trunc(sysdate) then
     hr_utility.set_message(8301,'GHR_38400_NO_50_FOR_FUT_ACT');
     hr_utility.raise_error;
   End if;

   If p_printer_name is null then
     hr_utility.set_message(8301,'GHR_38394_NO_PRINTER');
     hr_utility.raise_error;
   Else
     l_set_print_options_status := fnd_request.set_print_options
                                  (PRINTER        => p_printer_name
	 				     ,STYLE          => null
					     ,COPIES         => 1
				           ,SAVE_OUTPUT    => TRUE
					     ,PRINT_TOGETHER => 'N'
                                   );
     If not l_set_print_options_status THEN
       hr_utility.set_message(8301,'GHR_38190_FAIL_SET_PRINT_OPT');
       hr_utility.raise_error;
     Else
       for user_id in c_user_id loop
         l_user_id  := user_id.user_id;
       end loop;
       l_request_status := fnd_request.submit_request
       (
         APPLICATION    => 'GHR'
        ,PROGRAM        => 'GHRSF50'
        ,DESCRIPTION    => null
        ,START_TIME     => null
        ,SUB_REQUEST    => null
        ,ARGUMENT1      => p_pa_request_id
        ,ARGUMENT2      => l_user_id
	,ARGUMENT3      => 'Y'
	,ARGUMENT4      => p_back_page
        );
        IF l_request_status = 0 THEN
          null;
        --hr_utiltity.set_message('error submitting the request');
        -- hr_utility.raise_error;
        Else
          commit;
        End if;
      End if;
    End if;
  End submit_request_to_print_50;


  Procedure get_par_status
  (p_effective_date   	  	in   date,
   p_approval_date     		in   date,
   p_requested_by_person_id 	in   number,
   p_authorized_by_person_id 	in   number,
   p_action_taken      		in   varchar2,
   --8279908
   p_pa_request_id              in   number,
   p_status            		   out nocopy  varchar2
  )
  is
  Begin
    If nvl(p_action_taken,hr_api.g_varchar2) = 'CANCELED'  or  nvl(p_action_taken,hr_api.g_varchar2) = 'UPDATE_HR_COMPLETE'
    or nvl(p_action_taken,hr_api.g_varchar2) = 'UPDATE_HR'  then
      p_status  :=  p_action_taken;
      If  nvl(p_action_taken,hr_api.g_varchar2) = 'UPDATE_HR' and trunc(nvl(p_effective_date,hr_api.g_date)) > sysdate then
        p_status := 'FUTURE_ACTION';
      End if;
    Elsif  nvl(p_approval_date,hr_api.g_date) <> hr_api.g_date
    --8279908 added comparison for pa request id
    or  (nvl(ghr_par_shd.g_old_rec.approval_date,hr_api.g_date) <> hr_api.g_date
         and  ghr_par_shd.g_old_rec.pa_request_id = p_pa_request_id) then
      p_status  := 'APPROVED';
    Elsif  p_authorized_by_person_id is not null then
      p_status  := 'AUTHORIZED';
    Elsif  p_requested_by_person_id is not null then
      p_status  := 'REQUESTED';
    Else
      p_status  := 'INITIATED';
    End if;
  Exception when others then
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_status := null;
    raise;
  End get_par_status;


Procedure check_for_open_events
(p_pa_request_id       in      ghr_pa_requests.pa_request_id%type,
 p_action_taken        in      varchar2,
 p_user_name_acted_on  in      varchar2,
 p_user_name_routed_to in      varchar2,
 p_groupbox_routed_to  in      number,
 p_message                out nocopy  boolean
)
is

l_exists  boolean :=  FALSE;
l_proc    varchar2(72) := g_package || 'Check_for_open_events';

cursor c_open_events is
  select 1
  from   ghr_event_history
  where  table_name = 'GHR_PA_REQUESTS'
  and    record_id  = p_pa_request_id
  and    start_date is not null
  and    end_date   is null;


begin

  hr_utility.set_location('Entering ' || l_proc,5);
  hr_utility.set_location('PAR ' || to_char(p_pa_request_id),1);
  hr_utility.set_location('GB ' || to_char(p_groupbox_routed_to),1);
  hr_utility.set_location('UN ' || (p_user_name_routed_to),1);
  hr_utility.set_location('UN acted ' || (p_user_name_acted_on),1);
  hr_utility.set_location('Action ' || (p_action_taken),1);
  If
     ( nvl(p_action_taken,hr_api.g_varchar2) = 'UPDATE_HR' or
       nvl(p_action_taken,hr_api.g_varchar2) = 'FUTURE_ACTION'
 --**dk
      or nvl(p_action_taken,hr_api.g_varchar2) = 'END_ROUTING'

     ) then
     -- BUG # 3420126 As per requirements in the bug need not be fired during routing
     /*or
     ( p_user_name_routed_to is not null and
       nvl(p_user_name_acted_on,hr_api.g_varchar2) <> p_user_name_routed_to
     ) or
     (p_groupbox_routed_to is not null )*/

     hr_utility.set_location(l_proc,10);
     for open_events in c_open_events loop
       hr_utility.set_location(l_proc,15);
       l_exists := TRUE;
       exit;
     end loop;
     If l_exists then
          hr_utility.set_location(l_proc,20);
       p_message   :=   TRUE;
     Else
       hr_utility.set_location(l_proc,25);
       p_message   :=   FALSE;
     End if;
  End if;
       hr_utility.set_location('Leaving  ' || l_proc,30);
  Exception when others then
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_message := null;
    raise;

 end check_for_open_events;

end ghr_sf52_api;

/
