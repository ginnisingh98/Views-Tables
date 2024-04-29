--------------------------------------------------------
--  DDL for Package BEN_CWB_PERSON_INFO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CWB_PERSON_INFO_PKG" AUTHID CURRENT_USER as
/* $Header: bencwbpi.pkh 120.1 2006/02/16 07:47:13 krmahade noship $ */
--
-- --------------------------------------------------------------------------
-- |---------------------------< get_years_in_job >--------------------------|
-- --------------------------------------------------------------------------
--	This function computes the years in job
function get_years_in_job(p_assignment_id  in number
                         ,p_job_id         in number
                         ,p_effective_date in date
			 ,p_asg_effective_start_date in date)
return number;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_years_in_position >-----------------------|
-- --------------------------------------------------------------------------
--	This function computes the years in position
function get_years_in_position(p_assignment_id  in number
                              ,p_position_id    in number
                              ,p_effective_date in date
			      ,p_asg_effective_start_date in date)
return number;
--
-- --------------------------------------------------------------------------
-- |--------------------------< get_years_in_grade >-------------------------|
-- --------------------------------------------------------------------------
--	This function computes the years in grade
function get_years_in_grade(p_assignment_id  in number
                           ,p_grade_id    in number
                           ,p_effective_date in date
			   ,p_asg_effective_start_date in date)
return number;
--
-- --------------------------------------------------------------------------
-- |----------------------------< get_grd_min_val >--------------------------|
-- --------------------------------------------------------------------------
--	This function computes the years in grade
function get_grd_min_val(p_grade_id  in number
                        ,p_rate_id   in number
                        ,p_effective_date in date)
return number;
--
-- --------------------------------------------------------------------------
-- |----------------------------< get_grd_max_val >--------------------------|
-- --------------------------------------------------------------------------
--	This function computes the years in grade
function get_grd_max_val(p_grade_id  in number
                        ,p_rate_id   in number
                        ,p_effective_date in date)
return number;
--
-- --------------------------------------------------------------------------
-- |---------------------------< get_grd_mid_point >-------------------------|
-- --------------------------------------------------------------------------
--	This function computes the years in grade
function get_grd_mid_point(p_grade_id  in number
                          ,p_rate_id   in number
                          ,p_effective_date in date)
return number;
--
-- --------------------------------------------------------------------------
-- |-------------------------< refresh_person_info >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This procedure refreshes the person information in ben_cwb_person_info
-- table for a given group_per_in_ler_id and effective_date. This
-- effective_date is used while fetching the data from date track tables, if
-- ben_cwb_pl_dsgn cotains null as effective_date
--
procedure refresh_person_info(p_group_per_in_ler_id  in number
                             ,p_effective_date       in date
                             ,p_called_from_benmngle in boolean default false);
--
-- --------------------------------------------------------------------------
-- |--------------------< refresh_person_info_group_pl >---------------------|
-- --------------------------------------------------------------------------
-- Description
--   This procedure refreshes the person information in ben_cwb_person_info
-- for all the persons for a group plan, life event occured date.
-- p_effective_date will be used as freeze date while fetching the data from
-- data tracked tables if the effective_date in ben_cwb_pl_dsgn is null.

procedure refresh_person_info_group_pl(p_group_pl_id    in number
                                      ,p_lf_evt_ocrd_dt in date
                                      ,p_effective_date in date);
-- --------------------------------------------------------------------------
-- |--------------------------< get_grd_quartile >---------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This procedure calculates the grade quartile for given base salary,
-- minimum, maximum and midpoint of grade
function get_grd_quartile(p_salary in number
                         ,p_min    in number
                         ,p_max    in number
                         ,p_mid    in number)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |--------------------------< get_grd_quintile >---------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This procedure calculates the grade quintile for given base salary,
--   minimum and maximum of grade
function get_grd_quintile(p_salary in number
                         ,p_min    in number
                         ,p_max    in number)
return varchar2;
--
--
-- --------------------------------------------------------------------------
-- |---------------------------< get_grd_decile >----------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This procedure calculates the grade decile for given base salary,
--   minimum and maximum of grade
function get_grd_decile(p_salary in number
                       ,p_min    in number
                       ,p_max    in number)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |--------------------------< get_grd_comparatio >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This procedure calculates the grade quartile for given base salary,
-- and midpoint of a grade
function get_grd_comparatio(p_salary in number
                         ,p_mid      in number)
return number;
--
-- --------------------------------------------------------------------------
-- |--------------------------< refresh_from_master >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This procedure is used only by the admin page to refresh the person info.
--
procedure refresh_from_master(p_group_per_in_ler_id in number
                             ,p_effective_date in date);
--
function get_salary_currency(p_input_value_id in number
			    ,p_effective_date in date)
return varchar2;
--
--
-- --------------------------------------------------------------------------
-- |---------------------------< get_fte_factor >---------------------------|
-- --------------------------------------------------------------------------
FUNCTION get_fte_factor(p_assignment_id IN NUMBER
                       ,p_effective_date IN DATE)
return number;
--
--
-- --------------------------------------------------------------------------
-- |------------------------< get_grd_pct_in_range >------------------------|
-- --------------------------------------------------------------------------
function get_grd_pct_in_range(p_salary in number
                             ,p_min    in number
                             ,p_max    in number)
return number;
--
end BEN_CWB_PERSON_INFO_PKG;

 

/
