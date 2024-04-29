--------------------------------------------------------
--  DDL for Package PQH_GSP_SYNC_COMPENSATION_OBJ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_GSP_SYNC_COMPENSATION_OBJ" AUTHID CURRENT_USER as
/* $Header: pqgspwiz.pkh 120.0.12010000.1 2008/07/28 12:58:15 appldev ship $ */
--
--
Function delete_plan_for_grade(p_grade_id in number)
RETURN varchar2;
--
--------------------------------------------------------------------------------------
--
Function delete_std_rt_for_grade_rule(p_rate_type  in varchar2 default null,
                                      p_grade_or_spinal_point_id  in number default null,
                                      p_grade_rule_id  in number,
                                      p_effective_date in date,
                                      p_datetrack_mode in varchar2)
RETURN varchar2;
--
--------------------------------------------------------------------------------------
--
Function delete_option_for_point(p_spinal_point_id in number)
RETURN varchar2;
--
--------------------------------------------------------------------------------
--
Function delete_oipl_for_step(p_grade_id       in number default null,
                              p_spinal_point_id in number default null,
                              p_step_id        in number,
                              p_effective_date in date,
                              p_datetrack_mode in varchar2)
RETURN varchar2;
--
------------------------------------------------------------------------------------
--
Function create_oipl_for_step(p_grade_id       in number default null,
                              p_spinal_point_id in number default null,
                              p_step_id        in number,
                              p_effective_date in date,
                              p_datetrack_mode in varchar2)
RETURN varchar2;
--
------------------------------------------------------------------------------------
--
Function create_option_for_point(p_spinal_point_id   in number,
                                 p_pay_scale_name    in varchar2,
                                 p_business_group_id in number,
                                 p_spinal_point_name in varchar2)
RETURN varchar2;
--
------------------------------------------------------------------------------------
--
END;

/
