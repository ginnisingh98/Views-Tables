--------------------------------------------------------
--  DDL for Package PAY_IE_PRSI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_IE_PRSI" AUTHID CURRENT_USER AS
/* $Header: pyieprsi.pkh 120.0.12010000.2 2009/05/06 05:03:51 knadhan ship $ */
/*
**
**  Copyright (C) 1999 Oracle Corporation
**  All Rights Reserved
**
**  IE PAYE package
**
**  Change List
**  ===========
**
**  Date        Author   Reference Description
**  -----------+--------+---------+-------------
**  25 JUN 2001 ILeath   N/A        Created
**  10-JAN-2003 SMRobins 2652940    Added function
**                                  get_ins_weeks_for_monthly_emps
**  21-APR-2009 knadhan  8448176    Added function get_bal_value_30_04_09

-------------------------------------------------------------------------------
*/
Function get_prsi_details(   p_assignment_id            in           number
                            ,p_payroll_action_id        in           number
                            ,p_contribution_class       out   nocopy varchar2
                            ,p_overridden_subclass      out   nocopy varchar2
                            ,p_soc_ben_flag             out   nocopy varchar2
                            ,p_overridden_ins_weeks     out   nocopy number
                            ,p_community_flag           out   nocopy varchar2
                            ,p_exemption_start_date     out   nocopy date
                            ,p_exemption_end_date       out   nocopy date)
return number;
--
-- Calculate insurable weeks for Monthly employees
--
Function get_ins_weeks_for_monthly_emps (p_hire_date               in   date
                                        ,p_proc_period_start_date  in   date
                                        ,p_term_date               in   date
                                        ,p_proc_period_end_date    in   date
                                        ,p_processing_date         in   date)
return number;
--
Function get_period_type (p_payroll_id   in     number
                         ,p_session_date in     date)
return varchar2;
--
Function get_period_start_date (p_payroll_id   in   number
                               ,p_session_date in   date)
return varchar2;
--
Function get_period_end_date (p_payroll_id   in   number
                             ,p_session_date in   date)
return varchar2;
--
/* knadhan */
FUNCTION get_bal_value_30_04_09 (p_assignment_id IN  per_all_assignments_f.assignment_id%TYPE
                                 ,p_tax_unit_id IN NUMBER
                                 ,p_balance_name IN pay_balance_types.balance_name%TYPE
				 ,p_dimension_name IN pay_balance_dimensions.dimension_name%TYPE
				 ,p_till_date IN DATE) RETURN  number;
end pay_ie_prsi;

/
