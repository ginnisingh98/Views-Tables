--------------------------------------------------------
--  DDL for Package BEN_CWB_CUSTOM_PERSON_V2_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CWB_CUSTOM_PERSON_V2_PKG" AUTHID CURRENT_USER as
/* $Header: bencwbco.pkh 120.0 2006/04/11 06:10:31 ddeb noship $ */


-- --------------------------------------------------------------------------
-- |---------------------------< get_years_employed >---------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the years_employed
--
function get_years_employed(p_person_id        in number
                        ,p_assignment_id    in number
                        ,p_legislation_code in varchar2
                        ,p_group_pl_id      in number
                        ,p_lf_evt_ocrd_dt   in date
                        ,p_effective_date   in date
                        ,p_years_employed  in number)

return number;
--

-- --------------------------------------------------------------------------
-- |---------------------------< get_years_in_job >---------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the years_in_job
--
function get_years_in_job(p_person_id        in number
                        ,p_assignment_id    in number
                        ,p_legislation_code in varchar2
                        ,p_group_pl_id      in number
                        ,p_lf_evt_ocrd_dt   in date
                        ,p_effective_date   in date
                        ,p_years_in_job  in number)

return number;
--
-- --------------------------------------------------------------------------
-- |---------------------------< get_years_in_position >---------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the years_in_position
--
function get_years_in_position(p_person_id        in number
                        ,p_assignment_id    in number
                        ,p_legislation_code in varchar2
                        ,p_group_pl_id      in number
                        ,p_lf_evt_ocrd_dt   in date
                        ,p_effective_date   in date
                        ,p_years_in_position  in number)

return number;
--
-- --------------------------------------------------------------------------
-- |---------------------------< get_years_in_grade >---------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the years_in_grade
--
function get_years_in_grade(p_person_id        in number
                        ,p_assignment_id    in number
                        ,p_legislation_code in varchar2
                        ,p_group_pl_id      in number
                        ,p_lf_evt_ocrd_dt   in date
                        ,p_effective_date   in date
                        ,p_years_in_grade  in number)

return number;
--
-- --------------------------------------------------------------------------
-- |---------------------------< get_base_salary >---------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the base_salary
--
function get_base_salary(p_person_id        in number
                        ,p_assignment_id    in number
                        ,p_legislation_code in varchar2
                        ,p_group_pl_id      in number
                        ,p_lf_evt_ocrd_dt   in date
                        ,p_effective_date   in date
                        ,p_base_salary  in number)

return number;
--
-- --------------------------------------------------------------------------
-- |---------------------------< get_job_id >---------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the job_id
--
function get_job_id(p_person_id        in number
                        ,p_assignment_id    in number
                        ,p_legislation_code in varchar2
                        ,p_group_pl_id      in number
                        ,p_lf_evt_ocrd_dt   in date
                        ,p_effective_date   in date
                        ,p_job_id  in number)

return number;
--
-- --------------------------------------------------------------------------
-- |---------------------------< get_grade_id >---------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the grade_id
--
function get_grade_id(p_person_id        in number
                        ,p_assignment_id    in number
                        ,p_legislation_code in varchar2
                        ,p_group_pl_id      in number
                        ,p_lf_evt_ocrd_dt   in date
                        ,p_effective_date   in date
                        ,p_grade_id  in number)

return number;
--
-- --------------------------------------------------------------------------
-- |---------------------------< get_position_id >---------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the position_id
--
function get_position_id(p_person_id        in number
                        ,p_assignment_id    in number
                        ,p_legislation_code in varchar2
                        ,p_group_pl_id      in number
                        ,p_lf_evt_ocrd_dt   in date
                        ,p_effective_date   in date
                        ,p_position_id  in number)

return number;
--
-- --------------------------------------------------------------------------
-- |---------------------------< get_people_group_id >---------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the people_group_id
--
function get_people_group_id(p_person_id        in number
                        ,p_assignment_id    in number
                        ,p_legislation_code in varchar2
                        ,p_group_pl_id      in number
                        ,p_lf_evt_ocrd_dt   in date
                        ,p_effective_date   in date
                        ,p_people_group_id  in number)

return number;
--
-- --------------------------------------------------------------------------
-- |---------------------------< get_soft_coding_keyflex_id >---------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the soft_coding_keyflex_id
--
function get_soft_coding_keyflex_id(p_person_id        in number
                        ,p_assignment_id    in number
                        ,p_legislation_code in varchar2
                        ,p_group_pl_id      in number
                        ,p_lf_evt_ocrd_dt   in date
                        ,p_effective_date   in date
                        ,p_soft_coding_keyflex_id  in number)

return number;
--
-- --------------------------------------------------------------------------
-- |---------------------------< get_location_id >---------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the location_id
--
function get_location_id(p_person_id        in number
                        ,p_assignment_id    in number
                        ,p_legislation_code in varchar2
                        ,p_group_pl_id      in number
                        ,p_lf_evt_ocrd_dt   in date
                        ,p_effective_date   in date
                        ,p_location_id  in number)

return number;
--
-- --------------------------------------------------------------------------
-- |---------------------------< get_pay_rate_id >---------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the pay_rate_id
--
function get_pay_rate_id(p_person_id        in number
                        ,p_assignment_id    in number
                        ,p_legislation_code in varchar2
                        ,p_group_pl_id      in number
                        ,p_lf_evt_ocrd_dt   in date
                        ,p_effective_date   in date
                        ,p_pay_rate_id  in number)

return number;
--
-- --------------------------------------------------------------------------
-- |---------------------------< get_assignment_status_type_id >---------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the assignment_status_type_id
--
function get_assignment_status_type_id(p_person_id        in number
                        ,p_assignment_id    in number
                        ,p_legislation_code in varchar2
                        ,p_group_pl_id      in number
                        ,p_lf_evt_ocrd_dt   in date
                        ,p_effective_date   in date
                        ,p_assignment_status_type_id  in number)

return number;
--
-- --------------------------------------------------------------------------
-- |---------------------------< get_grade_annulization_factor >---------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the grade_annulization_factor
--
function get_grade_annulization_factor(p_person_id        in number
                        ,p_assignment_id    in number
                        ,p_legislation_code in varchar2
                        ,p_group_pl_id      in number
                        ,p_lf_evt_ocrd_dt   in date
                        ,p_effective_date   in date
                        ,p_grade_annulization_factor  in number)

return number;
--
-- --------------------------------------------------------------------------
-- |---------------------------< get_pay_annulization_factor >---------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the pay_annulization_factor
--
function get_pay_annulization_factor(p_person_id        in number
                        ,p_assignment_id    in number
                        ,p_legislation_code in varchar2
                        ,p_group_pl_id      in number
                        ,p_lf_evt_ocrd_dt   in date
                        ,p_effective_date   in date
                        ,p_pay_annulization_factor  in number)

return number;
--
-- --------------------------------------------------------------------------
-- |---------------------------< get_grd_min_val >---------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the grd_min_val
--
function get_grd_min_val(p_person_id        in number
                        ,p_assignment_id    in number
                        ,p_legislation_code in varchar2
                        ,p_group_pl_id      in number
                        ,p_lf_evt_ocrd_dt   in date
                        ,p_effective_date   in date
                        ,p_grd_min_val  in number)

return number;
--
-- --------------------------------------------------------------------------
-- |---------------------------< get_grd_max_val >---------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the grd_max_val
--
function get_grd_max_val(p_person_id        in number
                        ,p_assignment_id    in number
                        ,p_legislation_code in varchar2
                        ,p_group_pl_id      in number
                        ,p_lf_evt_ocrd_dt   in date
                        ,p_effective_date   in date
                        ,p_grd_max_val  in number)

return number;
--
-- --------------------------------------------------------------------------
-- |---------------------------< get_grd_mid_point >---------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the grd_mid_pointl
--
function get_grd_mid_point(p_person_id        in number
                        ,p_assignment_id    in number
                        ,p_legislation_code in varchar2
                        ,p_group_pl_id      in number
                        ,p_lf_evt_ocrd_dt   in date
                        ,p_effective_date   in date
                        ,p_grd_mid_point  in number)

return number;
--
-- --------------------------------------------------------------------------
-- |---------------------------< get_fte_factor >---------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the fte_factor
--
function get_fte_factor(p_person_id        in number
                        ,p_assignment_id    in number
                        ,p_legislation_code in varchar2
                        ,p_group_pl_id      in number
                        ,p_lf_evt_ocrd_dt   in date
                        ,p_effective_date   in date
                        ,p_fte_factor  in number)

return number;
--
-- --------------------------------------------------------------------------
-- |---------------------------< get_grd_pct_in_range >---------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the grd_pct_in_range
--
function get_grd_pct_in_range(p_person_id        in number
                        ,p_assignment_id    in number
                        ,p_legislation_code in varchar2
                        ,p_group_pl_id      in number
                        ,p_lf_evt_ocrd_dt   in date
                        ,p_effective_date   in date
                        ,p_grd_pct_in_range  in number)

return number;
--
-- --------------------------------------------------------------------------
-- |---------------------------< get_salary_1_year_ago >---------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the salary_1_year_ago
--
function get_salary_1_year_ago(p_person_id        in number
                        ,p_assignment_id    in number
                        ,p_legislation_code in varchar2
                        ,p_group_pl_id      in number
                        ,p_lf_evt_ocrd_dt   in date
                        ,p_effective_date   in date
                        ,p_salary_1_year_ago  in number)

return number;
--
-- --------------------------------------------------------------------------
-- |---------------------------< get_salary_1_year_ago_ann_fctr >---------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the salary_1_year_ago_ann_fctr
--
function get_salary_1_year_ago_ann_fctr(p_person_id        in number
                        ,p_assignment_id    in number
                        ,p_legislation_code in varchar2
                        ,p_group_pl_id      in number
                        ,p_lf_evt_ocrd_dt   in date
                        ,p_effective_date   in date
                        ,p_salary_1_year_ago_ann_fctr  in number)

return number;
--
-- --------------------------------------------------------------------------
-- |---------------------------< get_salary_2_year_ago >---------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the salary_2_year_ago
--
function get_salary_2_year_ago(p_person_id        in number
                        ,p_assignment_id    in number
                        ,p_legislation_code in varchar2
                        ,p_group_pl_id      in number
                        ,p_lf_evt_ocrd_dt   in date
                        ,p_effective_date   in date
                        ,p_salary_2_year_ago  in number)

return number;
--
-- --------------------------------------------------------------------------
-- |---------------------------< get_salary_2_year_ago_ann_fctr >---------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the salary_2_year_ago_ann_fctr
--
function get_salary_2_year_ago_ann_fctr(p_person_id        in number
                        ,p_assignment_id    in number
                        ,p_legislation_code in varchar2
                        ,p_group_pl_id      in number
                        ,p_lf_evt_ocrd_dt   in date
                        ,p_effective_date   in date
                        ,p_salary_2_year_ago_ann_fctr  in number)

return number;
--
-- --------------------------------------------------------------------------
-- |---------------------------< get_salary_3_year_ago >---------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the salary_3_year_ago
--
function get_salary_3_year_ago(p_person_id        in number
                        ,p_assignment_id    in number
                        ,p_legislation_code in varchar2
                        ,p_group_pl_id      in number
                        ,p_lf_evt_ocrd_dt   in date
                        ,p_effective_date   in date
                        ,p_salary_3_year_ago  in number)

return number;
--
-- --------------------------------------------------------------------------
-- |---------------------------< get_salary_3_year_ago_ann_fctr >---------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the salary_3_year_ago_ann_fctr
--
function get_salary_3_year_ago_ann_fctr(p_person_id        in number
                        ,p_assignment_id    in number
                        ,p_legislation_code in varchar2
                        ,p_group_pl_id      in number
                        ,p_lf_evt_ocrd_dt   in date
                        ,p_effective_date   in date
                        ,p_salary_3_year_ago_ann_fctr  in number)

return number;
--
-- --------------------------------------------------------------------------
-- |---------------------------< get_salary_4_year_ago >---------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the salary_4_year_ago
--
function get_salary_4_year_ago(p_person_id        in number
                        ,p_assignment_id    in number
                        ,p_legislation_code in varchar2
                        ,p_group_pl_id      in number
                        ,p_lf_evt_ocrd_dt   in date
                        ,p_effective_date   in date
                        ,p_salary_4_year_ago  in number)

return number;
--
-- --------------------------------------------------------------------------
-- |---------------------------< get_salary_4_year_ago_ann_fctr >---------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the salary_4_year_ago_ann_fctr
--
function get_salary_4_year_ago_ann_fctr(p_person_id        in number
                        ,p_assignment_id    in number
                        ,p_legislation_code in varchar2
                        ,p_group_pl_id      in number
                        ,p_lf_evt_ocrd_dt   in date
                        ,p_effective_date   in date
                        ,p_salary_4_year_ago_ann_fctr  in number)

return number;
--
-- --------------------------------------------------------------------------
-- |---------------------------< get_salary_5_year_ago >---------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the salary_5_year_ago
--
function get_salary_5_year_ago(p_person_id        in number
                        ,p_assignment_id    in number
                        ,p_legislation_code in varchar2
                        ,p_group_pl_id      in number
                        ,p_lf_evt_ocrd_dt   in date
                        ,p_effective_date   in date
                        ,p_salary_5_year_ago  in number)

return number;
--
-- --------------------------------------------------------------------------
-- |---------------------------< get_salary_5_year_ago_ann_fctr >---------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the salary_5_year_ago_ann_fctr
--
function get_salary_5_year_ago_ann_fctr(p_person_id        in number
                        ,p_assignment_id    in number
                        ,p_legislation_code in varchar2
                        ,p_group_pl_id      in number
                        ,p_lf_evt_ocrd_dt   in date
                        ,p_effective_date   in date
                        ,p_salary_5_year_ago_ann_fctr  in number)

return number;
--
-- --------------------------------------------------------------------------
-- |---------------------------< get_prev_sal >---------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the prev_sal
--
function get_prev_sal(p_person_id        in number
                        ,p_assignment_id    in number
                        ,p_legislation_code in varchar2
                        ,p_group_pl_id      in number
                        ,p_lf_evt_ocrd_dt   in date
                        ,p_effective_date   in date
                        ,p_prev_sal  in number)

return number;
--
-- --------------------------------------------------------------------------
-- |---------------------------< get_prev_sal_ann_fctr >---------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the prev_sal_ann_fctr
--
function get_prev_sal_ann_fctr(p_person_id        in number
                        ,p_assignment_id    in number
                        ,p_legislation_code in varchar2
                        ,p_group_pl_id      in number
                        ,p_lf_evt_ocrd_dt   in date
                        ,p_effective_date   in date
                        ,p_prev_sal_ann_fctr  in number)

return number;
---- --------------------------------------------------------------------------
-- |---------------------------< get_mkt_annualization_factor >---------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the mkt_annualization_factor
--
function get_mkt_annualization_factor(p_person_id        in number
                        ,p_assignment_id    in number
                        ,p_legislation_code in varchar2
                        ,p_group_pl_id      in number
                        ,p_lf_evt_ocrd_dt   in date
                        ,p_effective_date   in date
                        ,p_mkt_annualization_factor  in number)

return number;
---- --------------------------------------------------------------------------
-- |---------------------------< get_mkt_min_salary >---------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the mkt_min_salary
--
function get_mkt_min_salary(p_person_id        in number
                        ,p_assignment_id    in number
                        ,p_legislation_code in varchar2
                        ,p_group_pl_id      in number
                        ,p_lf_evt_ocrd_dt   in date
                        ,p_effective_date   in date
                        ,p_mkt_min_salary  in number)

return number;
---- --------------------------------------------------------------------------
-- |---------------------------< get_mkt_25pct_salary >---------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the mkt_25pct_salary
--
function get_mkt_25pct_salary(p_person_id        in number
                        ,p_assignment_id    in number
                        ,p_legislation_code in varchar2
                        ,p_group_pl_id      in number
                        ,p_lf_evt_ocrd_dt   in date
                        ,p_effective_date   in date
                        ,p_mkt_25pct_salary  in number)

return number;
---- --------------------------------------------------------------------------
-- |---------------------------< get_mkt_mid_salary >---------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the mkt_mid_salary
--
function get_mkt_mid_salary(p_person_id        in number
                        ,p_assignment_id    in number
                        ,p_legislation_code in varchar2
                        ,p_group_pl_id      in number
                        ,p_lf_evt_ocrd_dt   in date
                        ,p_effective_date   in date
                        ,p_mkt_mid_salary  in number)

return number;
---- --------------------------------------------------------------------------
-- |---------------------------< get_mkt_75pct_salary >---------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the mkt_75pct_salary
--
function get_mkt_75pct_salary(p_person_id        in number
                        ,p_assignment_id    in number
                        ,p_legislation_code in varchar2
                        ,p_group_pl_id      in number
                        ,p_lf_evt_ocrd_dt   in date
                        ,p_effective_date   in date
                        ,p_mkt_75pct_salary  in number)

return number;
---- --------------------------------------------------------------------------
-- |---------------------------< get_mkt_max_salary >---------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the mkt_max_salary
--
function get_mkt_max_salary(p_person_id        in number
                        ,p_assignment_id    in number
                        ,p_legislation_code in varchar2
                        ,p_group_pl_id      in number
                        ,p_lf_evt_ocrd_dt   in date
                        ,p_effective_date   in date
                        ,p_mkt_max_salary  in number)

return number;
---- --------------------------------------------------------------------------
-- |---------------------------< get_mkt_emp_pct_in_range >---------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the mkt_emp_pct_in_range
--
function get_mkt_emp_pct_in_range(p_person_id        in number
                        ,p_assignment_id    in number
                        ,p_legislation_code in varchar2
                        ,p_group_pl_id      in number
                        ,p_lf_evt_ocrd_dt   in date
                        ,p_effective_date   in date
                        ,p_mkt_emp_pct_in_range  in number)

return number;
---- --------------------------------------------------------------------------
-- |---------------------------< get_mkt_emp_comparatio >---------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the mkt_emp_comparatio
--
function get_mkt_emp_comparatio(p_person_id        in number
                        ,p_assignment_id    in number
                        ,p_legislation_code in varchar2
                        ,p_group_pl_id      in number
                        ,p_lf_evt_ocrd_dt   in date
                        ,p_effective_date   in date
                        ,p_mkt_emp_comparatio  in number)

return number;
---- --------------------------------------------------------------------------
-- |---------------------------< get_mkt_survey_id >---------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the mkt_survey_id
--
function get_mkt_survey_id(p_person_id        in number
                        ,p_assignment_id    in number
                        ,p_legislation_code in varchar2
                        ,p_group_pl_id      in number
                        ,p_lf_evt_ocrd_dt   in date
                        ,p_effective_date   in date
                        ,p_mkt_survey_id in number)

return number;
---- --------------------------------------------------------------------------
-- |---------------------------< get_grd_comparatio >---------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the grd_comparatio
--
function get_grd_comparatio(p_person_id        in number
                        ,p_assignment_id    in number
                        ,p_legislation_code in varchar2
                        ,p_group_pl_id      in number
                        ,p_lf_evt_ocrd_dt   in date
                        ,p_effective_date   in date
                        ,p_grd_comparatio  in number)

return number;
----
--------------------------------------------------------------------------
-- |---------------------------< get_normal_hours >---------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the normal_hours
--
function get_normal_hours(p_person_id        in number
                        ,p_assignment_id    in number
                        ,p_legislation_code in varchar2
                        ,p_group_pl_id      in number
                        ,p_lf_evt_ocrd_dt   in date
                        ,p_effective_date   in date
                        ,p_normal_hours  in number)

return number;
----

--------------------------------------------------------------------------
-- |---------------------------< get_performance_rating_date >---------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the performance_rating_date
--
function get_performance_rating_date(p_person_id        in number
                        ,p_assignment_id    in number
                        ,p_legislation_code in varchar2
                        ,p_group_pl_id      in number
                        ,p_lf_evt_ocrd_dt   in date
                        ,p_effective_date   in date
                        ,p_performance_rating_date  in date)

return date;
----

--------------------------------------------------------------------------
-- |---------------------------< get_start_date>---------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the start_date
--
function get_start_date(p_person_id        in number
                        ,p_assignment_id    in number
                        ,p_legislation_code in varchar2
                        ,p_group_pl_id      in number
                        ,p_lf_evt_ocrd_dt   in date
                        ,p_effective_date   in date
                        ,p_start_date in date)

return date;
----

--------------------------------------------------------------------------
-- |---------------------------< get_original_start_date >---------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the original_start_date
--
function get_original_start_date(p_person_id        in number
                        ,p_assignment_id    in number
                        ,p_legislation_code in varchar2
                        ,p_group_pl_id      in number
                        ,p_lf_evt_ocrd_dt   in date
                        ,p_effective_date   in date
                        ,p_original_start_date  in date)

return date;
----

--------------------------------------------------------------------------
-- |---------------------------< get_adjusted_svc_date >---------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the adjusted_svc_date
--
function get_adjusted_svc_date(p_person_id        in number
                        ,p_assignment_id    in number
                        ,p_legislation_code in varchar2
                        ,p_group_pl_id      in number
                        ,p_lf_evt_ocrd_dt   in date
                        ,p_effective_date   in date
                        ,p_adjusted_svc_date  in date)

return date;
----

--------------------------------------------------------------------------
-- |---------------------------< get_prev_sal_chg_date >---------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the prev_sal_chg_date
--
function get_prev_sal_chg_date(p_person_id        in number
                        ,p_assignment_id    in number
                        ,p_legislation_code in varchar2
                        ,p_group_pl_id      in number
                        ,p_lf_evt_ocrd_dt   in date
                        ,p_effective_date   in date
                        ,p_prev_sal_chg_date  in date)

return date;
----

--------------------------------------------------------------------------
-- |---------------------------< get_feedback_date >---------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the feedback_date
--
function get_feedback_date(p_person_id        in number
                        ,p_assignment_id    in number
                        ,p_legislation_code in varchar2
                        ,p_group_pl_id      in number
                        ,p_lf_evt_ocrd_dt   in date
                        ,p_effective_date   in date
                        ,p_feedback_date in date)

return date;
----

--------------------------------------------------------------------------
-- |---------------------------< get_base_salary_change_date >---------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the base_salary_change_date
--
function get_base_salary_change_date(p_person_id        in number
                        ,p_assignment_id    in number
                        ,p_legislation_code in varchar2
                        ,p_group_pl_id      in number
                        ,p_lf_evt_ocrd_dt   in date
                        ,p_effective_date   in date
                        ,p_base_salary_change_date  in date)

return date;
----

-- --------------------------------------------------------------------------
-- |-------------------------< get_full_name >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the full_name
--
function get_full_name(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_full_name in varchar2)
return varchar2;
--
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_brief_name >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the brief_name
--
function get_brief_name(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_brief_name in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_supervisor_full_name >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the supervisor_full_name
--
function get_supervisor_full_name(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_supervisor_full_name in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_supervisor_brief_name>-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the supervisor_brief_name
--
function get_supervisor_brief_name(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_supervisor_brief_name in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_supervisor_custom_name >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the supervisor_custom_name
--
function get_supervisor_custom_name(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_supervisor_custom_name in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_payroll_name >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the payroll_name
--
function get_payroll_name(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_payroll_name in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_performance_rating >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the performance_rating
--
function get_performance_rating(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_performance_rating in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_performance_rating_type >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the performance_rating_type
--
function get_performance_rating_type(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_performance_rating_type in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_frequency >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the frequency
--
function get_frequency(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_frequency in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_grd_quartile >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the grd_quartile
--
function get_grd_quartile(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_grd_quartile in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_emp_category >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the emp_category
--
function get_emp_category(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_emp_category in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_change_reason >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the change_reason
--
function get_change_reason(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_change_reason in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_email_address >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the email_address
--
function get_email_address(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_email_address in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_base_salary_frequency >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the base_salary_frequency
--
function get_base_salary_frequency(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_base_salary_frequency in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_post_process_stat_cd >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the post_process_stat_cd
--
function get_post_process_stat_cd(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_post_process_stat_cd in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_feedback_rating >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the feedback_rating
--
function get_feedback_rating(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_feedback_rating in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_feedback_comments >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the feedback_comments
--
function get_feedback_comments(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_feedback_comments in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_people_group_name >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the people_group_name
--
function get_people_group_name(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_people_group_name in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_people_group_segment1>-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the people_group_segment1
--
function get_people_group_segment1(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_people_group_segment1 in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_people_group_segment2 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the people_group_segment2
--
function get_people_group_segment2(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_people_group_segment2 in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_people_group_segment3 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the people_group_segment3
--
function get_people_group_segment3(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_people_group_segment3 in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_people_group_segment4 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the people_group_segment4
--
function get_people_group_segment4(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_people_group_segment4 in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_people_group_segment5 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the people_group_segment5
--
function get_people_group_segment5(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_people_group_segment5 in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_people_group_segment6>-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the people_group_segment6
--
function get_people_group_segment6(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_people_group_segment6 in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_people_group_segment7 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the people_group_segment7
--
function get_people_group_segment7(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_people_group_segment7 in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_people_group_segment8 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the people_group_segment8
--
function get_people_group_segment8(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_people_group_segment8 in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_people_group_segment9 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the people_group_segment9
--
function get_people_group_segment9(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_people_group_segment9 in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_people_group_segment10 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the people_group_segment10
--
function get_people_group_segment10(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_people_group_segment10 in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_people_group_segment11 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the people_group_segment11
--
function get_people_group_segment11(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_people_group_segment11 in varchar2)
return varchar2;
--



-- --------------------------------------------------------------------------
-- |-------------------------< get_ass_attribute_category >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the ass_attribute_category
--
function get_ass_attribute_category(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_ass_attribute_category in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_ass_attribute1 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the ass_attribute1
--
function get_ass_attribute1(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_ass_attribute1 in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_ass_attribute2 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the ass_attribute2
--
function get_ass_attribute2(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_ass_attribute2 in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_ass_attribute3 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the ass_attribute3
--
function get_ass_attribute3(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_ass_attribute3 in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_ass_attribute4 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the ass_attribute4
--
function get_ass_attribute4(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_ass_attribute4 in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_ass_attribute5 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the ass_attribute5
--
function get_ass_attribute5(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_ass_attribute5 in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_ass_attribute6 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the ass_attribute6
--
function get_ass_attribute6(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_ass_attribute6 in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_ass_attribute7 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the ass_attribute7
--
function get_ass_attribute7(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_ass_attribute7 in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_ass_attribute8 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the ass_attribute8
--
function get_ass_attribute8(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_ass_attribute8 in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_ass_attribute9 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the ass_attribute9
--
function get_ass_attribute9(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_ass_attribute9 in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_ass_attribute10 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the ass_attribute10
--
function get_ass_attribute10(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_ass_attribute10 in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_ass_attribute11 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the ass_attribute11
--
function get_ass_attribute11(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_ass_attribute11 in varchar2)
return varchar2;
--

-- --------------------------------------------------------------------------
-- |-------------------------< get_ass_attribute12 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the ass_attribute12
--
function get_ass_attribute12(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_ass_attribute12 in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_ass_attribute13 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the ass_attribute13
--
function get_ass_attribute13(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_ass_attribute13 in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_ass_attribute14 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the ass_attribute14
--
function get_ass_attribute14(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_ass_attribute14 in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_ass_attribute15 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the ass_attribute15
--
function get_ass_attribute15(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_ass_attribute15 in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_ass_attribute16 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the ass_attribute16
--
function get_ass_attribute16(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_ass_attribute16 in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_ass_attribute17 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the ass_attribute17
--
function get_ass_attribute17(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_ass_attribute17 in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_ass_attribute18 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the ass_attribute18
--
function get_ass_attribute18(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_ass_attribute18 in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_ass_attribute19 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the ass_attribute19
--
function get_ass_attribute19(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_ass_attribute19 in varchar2)
return varchar2;
--

-- --------------------------------------------------------------------------
-- |-------------------------< get_ass_attribute20 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the ass_attribute20
--
function get_ass_attribute20(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_ass_attribute20 in varchar2)
return varchar2;
--

-- --------------------------------------------------------------------------
-- |-------------------------< get_ass_attribute21 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the ass_attribute21
--
function get_ass_attribute21(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_ass_attribute21 in varchar2)
return varchar2;
--

-- --------------------------------------------------------------------------
-- |-------------------------< get_ass_attribute22 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the ass_attribute22
--
function get_ass_attribute22(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_ass_attribute22 in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_ass_attribute23 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the ass_attribute23
--
function get_ass_attribute23(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_ass_attribute23 in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_ass_attribute24 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the ass_attribute24
--
function get_ass_attribute24(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_ass_attribute24 in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_ass_attribute25 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the ass_attribute25
--
function get_ass_attribute25(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_ass_attribute25 in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_ass_attribute26 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the ass_attribute26
--
function get_ass_attribute26(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_ass_attribute26 in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_ass_attribute27 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the ass_attribute27
--
function get_ass_attribute27(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_ass_attribute27 in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_ass_attribute28 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the ass_attribute28
--
function get_ass_attribute28(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_ass_attribute28 in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_ass_attribute29 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the ass_attribute29
--
function get_ass_attribute29(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_ass_attribute29 in varchar2)
return varchar2;
--

-- --------------------------------------------------------------------------
-- |-------------------------< get_ass_attribute30 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the ass_attribute30
--
function get_ass_attribute30(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_ass_attribute30 in varchar2)
return varchar2;
--

-- --------------------------------------------------------------------------
-- |-------------------------< get_ws_comments >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the ws_comments
--
function get_ws_comments(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_ws_comments in varchar2)
return varchar2;
--

-- --------------------------------------------------------------------------
-- |-------------------------< get_cpi_attribute_category >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the cpi_attribute_category
--

function get_cpi_attribute_category(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_cpi_attribute_category in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_cpi_attribute1 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the cpi_attribute1
--
function get_cpi_attribute1(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_cpi_attribute1 in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_cpi_attribute2 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the cpi_attribute2
--
function get_cpi_attribute2(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_cpi_attribute2 in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_cpi_attribute3 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the cpi_attribute3
--
function get_cpi_attribute3(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_cpi_attribute3 in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_cpi_attribute4 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the cpi_attribute4
--
function get_cpi_attribute4(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_cpi_attribute4 in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_cpi_attribute5 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the cpi_attribute5
--
function get_cpi_attribute5(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_cpi_attribute5 in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_cpi_attribute6 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the cpi_attribute6
--
function get_cpi_attribute6(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_cpi_attribute6 in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_cpi_attribute7 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the cpi_attribute7
--
function get_cpi_attribute7(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_cpi_attribute7 in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_cpi_attribute8 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the cpi_attribute8
--
function get_cpi_attribute8(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_cpi_attribute8 in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_cpi_attribute9 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the cpi_attribute9
--
function get_cpi_attribute9(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_cpi_attribute9 in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_cpi_attribute10 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the cpi_attribute10
--
function get_cpi_attribute10(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_cpi_attribute10 in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_cpi_attribute11 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the cpi_attribute11
--
function get_cpi_attribute11(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_cpi_attribute11 in varchar2)
return varchar2;
--

-- --------------------------------------------------------------------------
-- |-------------------------< get_cpi_attribute12 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the cpi_attribute12
--
function get_cpi_attribute12(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_cpi_attribute12 in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_cpi_attribute13 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the cpi_attribute13
--
function get_cpi_attribute13(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_cpi_attribute13 in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_cpi_attribute14 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the cpi_attribute14
--
function get_cpi_attribute14(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_cpi_attribute14 in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_cpi_attribute15 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the cpi_attribute15
--
function get_cpi_attribute15(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_cpi_attribute15 in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_cpi_attribute16 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the cpi_attribute16
--
function get_cpi_attribute16(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_cpi_attribute16 in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_cpi_attribute17 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the cpi_attribute17
--
function get_cpi_attribute17(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_cpi_attribute17 in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_cpi_attribute18 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the cpi_attribute18
--
function get_cpi_attribute18(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_cpi_attribute18 in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_cpi_attribute19 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the cpi_attribute19
--
function get_cpi_attribute19(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_cpi_attribute19 in varchar2)
return varchar2;
--

-- --------------------------------------------------------------------------
-- |-------------------------< get_cpi_attribute20 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the cpi_attribute20
--
function get_cpi_attribute20(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_cpi_attribute20 in varchar2)
return varchar2;
--

-- --------------------------------------------------------------------------
-- |-------------------------< get_cpi_attribute21 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the cpi_attribute21
--
function get_cpi_attribute21(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_cpi_attribute21 in varchar2)
return varchar2;
--

-- --------------------------------------------------------------------------
-- |-------------------------< get_cpi_attribute22 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the cpi_attribute22
--
function get_cpi_attribute22(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_cpi_attribute22 in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_cpi_attribute23 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the cpi_attribute23
--
function get_cpi_attribute23(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_cpi_attribute23 in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_cpi_attribute24 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the cpi_attribute24
--
function get_cpi_attribute24(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_cpi_attribute24 in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_cpi_attribute25 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the cpi_attribute25
--
function get_cpi_attribute25(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_cpi_attribute25 in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_cpi_attribute26 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the cpi_attribute26
--
function get_cpi_attribute26(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_cpi_attribute26 in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_cpi_attribute27 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the cpi_attribute27
--
function get_cpi_attribute27(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_cpi_attribute27 in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_cpi_attribute28 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the cpi_attribute28
--
function get_cpi_attribute28(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_cpi_attribute28 in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_cpi_attribute29 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the cpi_attribute29
--
function get_cpi_attribute29(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_cpi_attribute29 in varchar2)
return varchar2;
--

-- --------------------------------------------------------------------------
-- |-------------------------< get_cpi_attribute30 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the cpi_attribute30
--
function get_cpi_attribute30(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_cpi_attribute30 in varchar2)
return varchar2;
--





-- --------------------------------------------------------------------------
-- |-------------------------< get_grd_quintile >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the grd_quintile
--
function get_grd_quintile(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_grd_quintile in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_grd_decile >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the grd_decile
--
function get_grd_decile(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_grd_decile in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_grade_rate_frequency >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the grade_rate_frequency
--
function get_grade_rate_frequency(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_grade_rate_frequency in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_base_salary_currency >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the base_salary_currency
--
function get_base_salary_currency(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_base_salary_currency in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_sal_1_yr_ago_freq >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the salary_1_year_ago_frequency
--
function get_sal_1_yr_ago_freq(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_salary_1_year_ago_frequency in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_sal_1_yr_ago_curr >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the salary_1_year_ago_currency
--
function get_sal_1_yr_ago_curr(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_salary_1_year_ago_currency in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_sal_2_yr_ago_freq >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the salary_2_year_ago_frequency
--
function get_sal_2_yr_ago_freq(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_salary_2_year_ago_frequency in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_sal_2_yr_ago_curr >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the salary_2_year_ago_currency
--
function get_sal_2_yr_ago_curr(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_salary_2_year_ago_currency in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_sal_3_yr_ago_curr >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the salary_3_year_ago_currency
--
function get_sal_3_yr_ago_curr(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_salary_3_year_ago_currency in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_sal_3_yr_ago_freq >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the salary_3_year_ago_frequency
--
function get_sal_3_yr_ago_freq(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_salary_3_year_ago_frequency in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_sal_4_yr_ago_freq >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the salary_4_year_ago_frequency
--
function get_sal_4_yr_ago_freq(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_salary_4_year_ago_frequency in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_sal_4_yr_ago_curr >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the salary_4_year_ago_currency
--
function get_sal_4_yr_ago_curr(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_salary_4_year_ago_currency in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_sal_5_yr_ago_freq >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the salary_5_year_ago_frequency
--
function get_sal_5_yr_ago_freq(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_salary_5_year_ago_frequency in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_sal_5_yr_ago_curr >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the salary_5_year_ago_currency
--
function get_sal_5_yr_ago_curr(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_salary_5_year_ago_currency in varchar2)
return varchar2;
--

-- --------------------------------------------------------------------------
-- |-------------------------< get_prev_sal_frequency >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the prev_sal_frequency
--
function get_prev_sal_frequency(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_prev_sal_frequency in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_prev_sal_currency >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the prev_sal_currency
--
function get_prev_sal_currency(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_prev_sal_currency in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_prev_sal_chg_rsn >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the prev_sal_chg_rsn
--
function get_prev_sal_chg_rsn(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_prev_sal_chg_rsn in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_mkt_currency >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the mkt_currency
--
function get_mkt_currency(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_mkt_currency in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_mkt_frequency >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the mkt_frequency
--
function get_mkt_frequency(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_mkt_frequency in varchar2)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_mkt_emp_quartile >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the mkt_emp_quartile
--
function get_mkt_emp_quartile(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date
                            ,p_mkt_emp_quartile in varchar2)
return varchar2;
--

end BEN_CWB_CUSTOM_PERSON_V2_PKG;


 

/
