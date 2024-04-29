--------------------------------------------------------
--  DDL for Package BEN_CWB_DATA_MODEL_UPGRADE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CWB_DATA_MODEL_UPGRADE" AUTHID CURRENT_USER as
/* $Header: bencwbmu.pkh 120.1 2006/01/09 15:49:36 maagrawa noship $ */
/* ===========================================================================+
 * Name
 *   Compensation Workbench Data Model Upgrade Package
 * Purpose
 *   This package is used to migrate data of old customers to
 *   new CWB Data model.
 *
 * Version Date        Author    Comment
 * -------+-----------+---------+----------------------------------------------
 * 115.0   14-Jan-2004 maagrawa   created
 * 115.1   15-Jan-2004 maagrawa   Added out parameters to main;used by CM.
 * 115.2   10-Feb-2004 skota      Added get_ functions
 * 115.3   03-Jan-2006 maagrawa   Made commit_and_log public.
 * ==========================================================================+
 */

  procedure main(errbuf  out  nocopy  varchar2
                ,retcode out  nocopy  number);

  procedure is_cwb_used(p_result out nocopy varchar2);


  -- The following are the functions called from refresh_person_info_group_pl
  function get_years_in_job(p_assignment_id  in number
                           ,p_job_id         in number
                           ,p_effective_date in date
			   ,p_asg_effective_start_date in date)
  return number;

  function get_years_in_position(p_assignment_id  in number
                                ,p_position_id    in number
                                ,p_effective_date in date
			        ,p_asg_effective_start_date in date)
  return number;

  function get_years_in_grade(p_assignment_id  in number
                             ,p_grade_id    in number
                             ,p_effective_date in date
	  		     ,p_asg_effective_start_date in date)
  return number;

  function get_grd_min_val(p_grade_id  in number
                          ,p_rate_id   in number
                          ,p_effective_date in date)
  return number;

  function get_grd_max_val(p_grade_id  in number
                          ,p_rate_id   in number
                          ,p_effective_date in date)
  return number;

  function get_grd_mid_point(p_grade_id  in number
                            ,p_rate_id   in number
                            ,p_effective_date in date)
  return number;

  procedure commit_and_log(p_text in varchar2);

end ben_cwb_data_model_upgrade;

 

/
