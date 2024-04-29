--------------------------------------------------------
--  DDL for Package GHR_UPD_HR_VALIDATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_UPD_HR_VALIDATION" AUTHID CURRENT_USER AS
/* $Header: ghuhrval.pkh 120.1.12000000.1 2007/01/18 14:19:57 appldev noship $ */

  g_package       constant varchar2(33) := 'ghr_upd_hr_validation.';
  --

  form_item_name    VARCHAR2(61); -- This will be the block_name.item_name
  --
  FUNCTION get_form_item_name
    RETURN VARCHAR2;
  --
  PROCEDURE set_form_item_name(p_value IN VARCHAR2);
  --
  PROCEDURE main_validation(p_pa_requests_type            IN ghr_pa_requests%ROWTYPE
                         ,p_asg_non_sf52_type           IN ghr_api.asg_non_sf52_type
                         ,p_asg_nte_dates_type          IN ghr_api.asg_nte_dates_type
                         ,p_per_group1_type             IN ghr_api.per_group1_type
                         ,p_per_uniformed_services_type IN ghr_api.per_uniformed_services_type
                         ,p_per_retained_grade_type     IN ghr_api.per_retained_grade_type
                         ,p_per_sep_retire_type         IN ghr_api.per_sep_retire_type
                         ,p_per_probations_type         IN ghr_api.per_probations_type
                         ,p_pos_grp1_type               IN ghr_api.pos_grp1_type
                         ,p_pos_grp2_type               IN ghr_api.pos_grp2_type
                         ,p_within_grade_increase_type  IN ghr_api.within_grade_increase_type
                         ,p_government_awards_type      IN ghr_api.government_awards_type
                         ,p_government_payroll_type     IN ghr_api.government_payroll_type
                         ,p_performance_appraisal_type  IN ghr_api.performance_appraisal_type
                         ,p_recruitment_bonus_type      IN ghr_api.recruitment_bonus_type
                         ,p_relocation_bonus_type       IN ghr_api.relocation_bonus_type
                         ,p_student_loan_repay_type     IN ghr_api.student_loan_repay_type
                         --Pradeep
                         ,p_mddds_special_pay           IN ghr_api.mddds_special_pay_type
						 ,p_premium_pay_ind           IN ghr_api.premium_pay_ind_type
                         ,p_per_conversions_type        IN ghr_api.per_conversions_type
                         ,p_conduct_performance_type    IN ghr_api.conduct_performance_type
						 -- Sundar Bug 4582970 Added for Benefits EIT validation
						  ,p_thrift_savings_plan         IN ghr_api.thrift_saving_plan
						  ,p_per_benefit_info            IN ghr_api.per_benefit_info_type
						  ,p_per_scd_info_type           IN ghr_api.per_scd_info_type

                           );
--
FUNCTION get_exemp_award_date(p_pa_request_id IN NUMBER)
    RETURN DATE;
pragma restrict_references (get_exemp_award_date, WNDS, WNPS);

--
PROCEDURE get_rpa_info(p_pa_request_id IN NUMBER,
                       p_asg_end_date  OUT NOCOPY  DATE,
                       p_rpa_eff_date  OUT NOCOPY  DATE,
                       p_position_id   OUT NOCOPY  NUMBER);

--
-- --------------------------------------------------------------------------
-- ---------------------------< Function: to_posn_not_active>--------------
-- --------------------------------------------------------------------------
  Procedure to_posn_not_active(p_position_id         in number
                              ,p_effective_date      in date
                              ,p_hiring_status       OUT NOCOPY varchar
                              ,p_hiring_status_start_date OUT NOCOPY date);

--


END ghr_upd_hr_validation;

 

/
