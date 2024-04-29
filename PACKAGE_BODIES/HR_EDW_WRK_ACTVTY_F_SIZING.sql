--------------------------------------------------------
--  DDL for Package Body HR_EDW_WRK_ACTVTY_F_SIZING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_EDW_WRK_ACTVTY_F_SIZING" AS
/* $Header: hriezwac.pkb 120.1 2005/06/08 02:51:16 anmajumd noship $ */
/******************************************************************************/
/* Sets p_row_count to the number of rows which would be collected between    */
/* the given dates                                                            */
/******************************************************************************/
PROCEDURE count_source_rows( p_from_date IN  DATE,
                             p_to_date   IN  DATE,
                             p_row_count OUT NOCOPY NUMBER )
IS

  /* Cursor description */
  CURSOR row_count_cur IS
  SELECT count(asg.assignment_id) total
  FROM  per_all_assignments_f        asg
  WHERE NVL(asg.last_update_date, to_date('01-01-2000','DD-MM-YYYY'))
  BETWEEN p_from_date AND p_to_date;

BEGIN

  OPEN row_count_cur;
  FETCH row_count_cur INTO p_row_count;
  CLOSE row_count_cur;

END count_source_rows;


/******************************************************************************/
/* Estimates row lengths.                                                     */
/******************************************************************************/
PROCEDURE estimate_row_length( p_from_date        IN  DATE,
                               p_to_date          IN  DATE,
                               p_avg_row_length   OUT NOCOPY NUMBER )

IS

  x_total_wac                    NUMBER;

  x_date  NUMBER:=7;

  x_assignment_change_pk         NUMBER:=0;

  x_age_band_fk                  NUMBER:=0;
  x_application_fk               NUMBER:=0;
  x_assignment_fk                NUMBER:=0;
  x_assignment_change_fk         NUMBER:=0;
  x_geography_from_fk            NUMBER:=0;
  x_geography_to_fk              NUMBER:=0;
  x_grade_from_fk                NUMBER:=0;
  x_grade_to_fk                  NUMBER:=0;
  x_instance_fk                  NUMBER:=0;
  x_job_from_fk                  NUMBER:=0;
  x_job_to_fk                    NUMBER:=0;
  x_organization_from_fk         NUMBER:=0;
  x_organization_to_fk           NUMBER:=0;
  x_person_fk                    NUMBER:=0;
  x_person_type_fk               NUMBER:=0;
  x_position_from_fk             NUMBER:=0;
  x_position_to_fk               NUMBER:=0;
  x_movement_fk                  NUMBER:=0;
  x_reason_fk                    NUMBER:=0;
  x_service_band_fk              NUMBER:=0;
  x_time_from_fk                 NUMBER:=0;
  x_time_to_fk                   NUMBER:=0;

  x_last_update_date             NUMBER:=x_date;
  x_creation_date                NUMBER:=x_date;
  x_effective_start_date         NUMBER:=x_date;
  x_effective_end_date           NUMBER:=x_date;

  x_assignment_id                NUMBER:=0;
  x_business_group_id            NUMBER:=0;
  x_recruiter_id                 NUMBER:=0;
  x_grade_id                     NUMBER:=0;
  x_position_id                  NUMBER:=0;
  x_job_id                       NUMBER:=0;
  x_assignment_status_type_id    NUMBER:=0;
  x_payroll_id                   NUMBER:=0;
  x_location_id                  NUMBER:=0;
  x_person_referred_by_id        NUMBER:=0;
  x_supervisor_id                NUMBER:=0;
  x_special_ceiling_step_id      NUMBER:=0;
  x_person_id                    NUMBER:=0;
  x_recruitment_activity_id      NUMBER:=0;
  x_source_organization_id       NUMBER:=0;
  x_organization_id              NUMBER:=0;
  x_people_group_id              NUMBER:=0;
  x_soft_coding_keyflex_id       NUMBER:=0;
  x_vacancy_id                   NUMBER:=0;
  x_pay_basis_id                 NUMBER:=0;
  x_assignment_sequence          NUMBER:=0;
  x_assignment_type              NUMBER:=0;
  x_primary_flag                 NUMBER:=0;
  x_application_id               NUMBER:=0;
  x_assignment_number            NUMBER:=0;
  x_change_reason                NUMBER:=0;
  x_comment_id                   NUMBER:=0;
  x_date_probation_end           NUMBER:=x_date;
  x_default_code_comb_id         NUMBER:=0;
  x_employment_category          NUMBER:=0;
  x_frequency                    NUMBER:=0;
  x_internal_address_line        NUMBER:=0;
  x_manager_flag                 NUMBER:=0;
  x_normal_hours                 NUMBER:=0;
  x_perf_review_period           NUMBER:=0;
  x_perf_review_period_frequency NUMBER:=0;
  x_period_of_service_id         NUMBER:=0;
  x_probation_period             NUMBER:=0;
  x_probation_unit               NUMBER:=0;
  x_sal_review_period            NUMBER:=0;
  x_sal_review_period_frequency  NUMBER:=0;
  x_set_of_books_id              NUMBER:=0;
  x_source_type                  NUMBER:=0;
  x_time_normal_finish           NUMBER:=0;
  x_time_normal_start            NUMBER:=0;
  x_asg_request_id               NUMBER:=0;
  x_program_application_id       NUMBER:=0;
  x_program_id                   NUMBER:=0;
  x_program_update_date          NUMBER:=x_date;
  x_asg_title                    NUMBER:=0;
  x_object_version_number        NUMBER:=0;
  x_bargaining_unit_code         NUMBER:=0;
  x_labour_union_member_flag     NUMBER:=0;
  x_hourly_salaried_code         NUMBER:=0;
  x_contract_id                  NUMBER:=0;
  x_collective_agreement_id      NUMBER:=0;
  x_cagr_id_flex_num             NUMBER:=0;
  x_cagr_grade_def_id            NUMBER:=0;
  x_establishment_id             NUMBER:=0;

/* Select the length of the instance code */
  CURSOR inst_cur IS
  SELECT avg(nvl( vsize(instance_code),0 ))
  FROM edw_local_instance;

  CURSOR asg_cur IS
  SELECT
   avg(nvl(vsize(asg.assignment_id),0))
  ,avg(nvl(vsize(asg.effective_start_date),0))
  ,avg(nvl(vsize(asg.effective_end_date),0))
  ,avg(nvl(vsize(asg.business_group_id),0))
  ,avg(nvl(vsize(asg.recruiter_id),0))
  ,avg(nvl(vsize(asg.grade_id),0))
  ,avg(nvl(vsize(asg.position_id),0))
  ,avg(nvl(vsize(asg.job_id),0))
  ,avg(nvl(vsize(asg.assignment_status_type_id),0))
  ,avg(nvl(vsize(asg.payroll_id),0))
  ,avg(nvl(vsize(asg.location_id),0))
  ,avg(nvl(vsize(asg.person_referred_by_id),0))
  ,avg(nvl(vsize(asg.supervisor_id),0))
  ,avg(nvl(vsize(asg.special_ceiling_step_id),0))
  ,avg(nvl(vsize(asg.person_id),0))
  ,avg(nvl(vsize(asg.recruitment_activity_id),0))
  ,avg(nvl(vsize(asg.source_organization_id),0))
  ,avg(nvl(vsize(asg.organization_id),0))
  ,avg(nvl(vsize(asg.people_group_id),0))
  ,avg(nvl(vsize(asg.soft_coding_keyflex_id),0))
  ,avg(nvl(vsize(asg.vacancy_id),0))
  ,avg(nvl(vsize(asg.pay_basis_id),0))
  ,avg(nvl(vsize(asg.assignment_sequence),0))
  ,avg(nvl(vsize(asg.assignment_type),0))
  ,avg(nvl(vsize(asg.primary_flag),0))
  ,avg(nvl(vsize(asg.application_id),0))
  ,avg(nvl(vsize(asg.assignment_number),0))
  ,avg(nvl(vsize(asg.change_reason),0))
  ,avg(nvl(vsize(asg.comment_id),0))
  ,avg(nvl(vsize(asg.date_probation_end),0))
  ,avg(nvl(vsize(asg.default_code_comb_id),0))
  ,avg(nvl(vsize(asg.employment_category),0))
  ,avg(nvl(vsize(asg.frequency),0))
  ,avg(nvl(vsize(asg.internal_address_line),0))
  ,avg(nvl(vsize(asg.manager_flag),0))
  ,avg(nvl(vsize(asg.normal_hours),0))
  ,avg(nvl(vsize(asg.perf_review_period),0))
  ,avg(nvl(vsize(asg.perf_review_period_frequency),0))
  ,avg(nvl(vsize(asg.period_of_service_id),0))
  ,avg(nvl(vsize(asg.probation_period),0))
  ,avg(nvl(vsize(asg.probation_unit),0))
  ,avg(nvl(vsize(asg.sal_review_period),0))
  ,avg(nvl(vsize(asg.sal_review_period_frequency),0))
  ,avg(nvl(vsize(asg.set_of_books_id),0))
  ,avg(nvl(vsize(asg.source_type),0))
  ,avg(nvl(vsize(asg.time_normal_finish),0))
  ,avg(nvl(vsize(asg.time_normal_start),0))
  ,avg(nvl(vsize(asg.request_id),0))
  ,avg(nvl(vsize(asg.program_application_id),0))
  ,avg(nvl(vsize(asg.program_id),0))
  ,avg(nvl(vsize(asg.program_update_date),0))
  ,avg(nvl(vsize(asg.title),0))
  ,avg(nvl(vsize(asg.object_version_number),0))
  ,avg(nvl(vsize(asg.bargaining_unit_code),0))
  ,avg(nvl(vsize(asg.labour_union_member_flag),0))
  ,avg(nvl(vsize(asg.hourly_salaried_code),0))
  ,avg(nvl(vsize(asg.contract_id),0))
  ,avg(nvl(vsize(asg.collective_agreement_id),0))
  ,avg(nvl(vsize(asg.cagr_id_flex_num),0))
  ,avg(nvl(vsize(asg.cagr_grade_def_id),0))
  ,avg(nvl(vsize(asg.establishment_id),0))
  FROM per_all_assignments_f asg
  WHERE asg.last_update_date BETWEEN p_from_date AND p_to_date;

  BEGIN

  OPEN inst_cur;
  FETCH inst_cur INTO x_instance_fk;
  CLOSE inst_cur;

  OPEN asg_cur;
  FETCH asg_cur INTO
   x_assignment_id
  ,x_effective_start_date
  ,x_effective_end_date
  ,x_business_group_id
  ,x_recruiter_id
  ,x_grade_id
  ,x_position_id
  ,x_job_id
  ,x_assignment_status_type_id
  ,x_payroll_id
  ,x_location_id
  ,x_person_referred_by_id
  ,x_supervisor_id
  ,x_special_ceiling_step_id
  ,x_person_id
  ,x_recruitment_activity_id
  ,x_source_organization_id
  ,x_organization_id
  ,x_people_group_id
  ,x_soft_coding_keyflex_id
  ,x_vacancy_id
  ,x_pay_basis_id
  ,x_assignment_sequence
  ,x_assignment_type
  ,x_primary_flag
  ,x_application_id
  ,x_assignment_number
  ,x_change_reason
  ,x_comment_id
  ,x_date_probation_end
  ,x_default_code_comb_id
  ,x_employment_category
  ,x_frequency
  ,x_internal_address_line
  ,x_manager_flag
  ,x_normal_hours
  ,x_perf_review_period
  ,x_perf_review_period_frequency
  ,x_period_of_service_id
  ,x_probation_period
  ,x_probation_unit
  ,x_sal_review_period
  ,x_sal_review_period_frequency
  ,x_set_of_books_id
  ,x_source_type
  ,x_time_normal_finish
  ,x_time_normal_start
  ,x_asg_request_id
  ,x_program_application_id
  ,x_program_id
  ,x_program_update_date
  ,x_asg_title
  ,x_object_version_number
  ,x_bargaining_unit_code
  ,x_labour_union_member_flag
  ,x_hourly_salaried_code
  ,x_contract_id
  ,x_collective_agreement_id
  ,x_cagr_id_flex_num
  ,x_cagr_grade_def_id
  ,x_establishment_id;
  CLOSE asg_cur;

  x_assignment_change_pk   := x_assignment_id + x_effective_start_date + x_instance_fk;
  x_age_band_fk            := hri_edw_dim_sizing.get_size_agb_pk;
  x_assignment_fk          := hri_edw_dim_sizing.get_size_asg_pk;
  x_assignment_change_fk   := hri_edw_dim_sizing.get_size_acg_pk;
  x_geography_from_fk      := hri_edw_dim_sizing.get_size_geog_pk;
  x_geography_to_fk        := x_geography_from_fk;
  x_grade_from_fk          := hri_edw_dim_sizing.get_size_grd_pk;
  x_grade_to_fk            := x_grade_from_fk;
  x_job_from_fk            := hri_edw_dim_sizing.get_size_job_pk;
  x_job_to_fk              := x_job_from_fk;
  x_organization_from_fk   := hri_edw_dim_sizing.get_size_org_pk;
  x_organization_to_fk     := x_organization_from_fk;
  x_person_fk              := hri_edw_dim_sizing.get_size_psn_pk;
  x_person_type_fk         := hri_edw_dim_sizing.get_size_pty_pk;
  x_position_from_fk       := hri_edw_dim_sizing.get_size_pos_pk;
  x_position_to_fk         := x_position_from_fk;
  x_movement_fk            := hri_edw_dim_sizing.get_size_mvt_pk;
  x_reason_fk              := hri_edw_dim_sizing.get_size_rsn_pk;
  x_service_band_fk        := hri_edw_dim_sizing.get_size_lwb_pk;
  x_time_from_fk           := hri_edw_dim_sizing.get_size_time_pk;
  x_time_to_fk             := x_time_from_fk;



x_total_wac :=  NVL(ceil(x_assignment_change_pk  + 1), 0)
              + NVL(ceil(x_age_band_fk + 1), 0)
              + NVL(ceil(x_application_fk + 1), 0)
              + NVL(ceil(x_assignment_fk + 1), 0)
              + NVL(ceil(x_assignment_change_fk + 1), 0)
              + NVL(ceil(x_geography_from_fk + 1), 0)
              + NVL(ceil(x_geography_to_fk + 1), 0)
              + NVL(ceil(x_grade_from_fk + 1), 0)
              + NVL(ceil(x_grade_to_fk + 1), 0)
              + NVL(ceil(x_instance_fk + 1), 0)
              + NVL(ceil(x_job_from_fk + 1), 0)
              + NVL(ceil(x_job_to_fk + 1), 0)
              + NVL(ceil(x_organization_from_fk + 1), 0)
              + NVL(ceil(x_organization_to_fk + 1), 0)
              + NVL(ceil(x_person_fk + 1), 0)
              + NVL(ceil(x_person_type_fk + 1), 0)
              + NVL(ceil(x_position_from_fk + 1), 0)
              + NVL(ceil(x_position_to_fk + 1), 0)
              + NVL(ceil(x_movement_fk + 1), 0)
              + NVL(ceil(x_reason_fk + 1), 0)
              + NVL(ceil(x_service_band_fk + 1), 0)
              + NVL(ceil(x_time_from_fk + 1), 0)
              + NVL(ceil(x_time_to_fk + 1), 0)
              + NVL(ceil(x_last_update_date + 1), 0)
              + NVL(ceil(x_creation_date + 1), 0)
              + NVL(ceil(x_assignment_id + 1), 0)
              + NVL(ceil(x_effective_start_date + 1), 0)
              + NVL(ceil(x_effective_end_date + 1), 0)
              + NVL(ceil(x_business_group_id + 1), 0)
              + NVL(ceil(x_recruiter_id + 1), 0)
              + NVL(ceil(x_grade_id + 1), 0)
              + NVL(ceil(x_position_id + 1), 0)
              + NVL(ceil(x_job_id + 1), 0)
              + NVL(ceil(x_assignment_status_type_id + 1), 0)
              + NVL(ceil(x_payroll_id + 1), 0)
              + NVL(ceil(x_location_id + 1), 0)
              + NVL(ceil(x_person_referred_by_id + 1), 0)
              + NVL(ceil(x_supervisor_id + 1), 0)
              + NVL(ceil(x_special_ceiling_step_id + 1), 0)
              + NVL(ceil(x_person_id + 1), 0)
              + NVL(ceil(x_recruitment_activity_id + 1), 0)
              + NVL(ceil(x_source_organization_id + 1), 0)
              + NVL(ceil(x_organization_id + 1), 0)
              + NVL(ceil(x_people_group_id + 1), 0)
              + NVL(ceil(x_soft_coding_keyflex_id + 1), 0)
              + NVL(ceil(x_pay_basis_id + 1), 0)
              + NVL(ceil(x_assignment_sequence + 1), 0)
              + NVL(ceil(x_assignment_type + 1), 0)
              + NVL(ceil(x_primary_flag + 1), 0)
              + NVL(ceil(x_application_id + 1), 0)
              + NVL(ceil(x_assignment_number + 1), 0)
              + NVL(ceil(x_change_reason + 1), 0)
              + NVL(ceil(x_comment_id + 1), 0)
              + NVL(ceil(x_date_probation_end + 1), 0)
              + NVL(ceil(x_default_code_comb_id + 1), 0)
              + NVL(ceil(x_employment_category + 1), 0)
              + NVL(ceil(x_frequency + 1), 0)
              + NVL(ceil(x_internal_address_line + 1), 0)
              + NVL(ceil(x_manager_flag + 1), 0)
              + NVL(ceil(x_normal_hours + 1), 0)
              + NVL(ceil(x_perf_review_period + 1), 0)
              + NVL(ceil(x_perf_review_period_frequency + 1), 0)
              + NVL(ceil(x_period_of_service_id + 1), 0)
              + NVL(ceil(x_probation_period + 1), 0)
              + NVL(ceil(x_probation_unit + 1), 0)
              + NVL(ceil(x_sal_review_period + 1), 0)
              + NVL(ceil(x_sal_review_period_frequency + 1), 0)
              + NVL(ceil(x_set_of_books_id + 1), 0)
              + NVL(ceil(x_source_type + 1), 0)
              + NVL(ceil(x_time_normal_finish + 1), 0)
              + NVL(ceil(x_time_normal_start + 1), 0)
              + NVL(ceil(x_asg_request_id + 1), 0)
              + NVL(ceil(x_program_application_id + 1), 0)
              + NVL(ceil(x_program_id + 1), 0)
              + NVL(ceil(x_program_update_date + 1), 0)
              + NVL(ceil(x_asg_title + 1), 0)
              + NVL(ceil(x_object_version_number + 1), 0)
              + NVL(ceil(x_bargaining_unit_code + 1), 0)
              + NVL(ceil(x_labour_union_member_flag + 1), 0)
              + NVL(ceil(x_hourly_salaried_code + 1), 0)
              + NVL(ceil(x_contract_id + 1), 0)
              + NVL(ceil(x_collective_agreement_id + 1), 0)
              + NVL(ceil(x_cagr_id_flex_num + 1), 0)
              + NVL(ceil(x_cagr_grade_def_id + 1), 0)
              + NVL(ceil(x_establishment_id + 1), 0) ;


p_avg_row_length :=  x_total_wac;

END estimate_row_length;

END hr_edw_wrk_actvty_f_sizing;

/
