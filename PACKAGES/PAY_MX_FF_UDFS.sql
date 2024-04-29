--------------------------------------------------------
--  DDL for Package PAY_MX_FF_UDFS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_MX_FF_UDFS" AUTHID CURRENT_USER AS
/* $Header: pymxudfs.pkh 120.2.12010000.3 2009/08/03 09:58:44 sjawid ship $ */

/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1992 Oracle Corporation UK Ltd.,                *
   *                   Chertsey, England.                           *
   *                                                                *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation UK Ltd,  *
   *  Oracle Park, Bittams Lane, Guildford Road, Chertsey, Surrey,  *
   *  England.                                                      *
   *                                                                *
   ******************************************************************

   Change List
   -----------
   Date         Name        Vers   Bug No   Description
   -----------  ----------  -----  -------  -----------------------------------
   16-AUG-2001  vpandya     115.0            Created.
   28-Nov-2004  vpandya     115.1            Changed pkg name to pay_mx_ff..
                                             from hr_mx_ff_udfs.
   30-Nov-2004  vmehta      115.2            Added get_idw function
   06-Dec-2005  vpandya     115.3            Added following functions:
                                             - get_base_pay
                                             - get_mx_historic_rate
   30-Jul-2009  sjawid      115.4            Added new overloaded function get_idw
                                             with context p_payroll_action_id,
					     and new parameter p_execute_old_idw_code.
*/
--
--
  FUNCTION standard_hours_worked(
                                p_std_hrs       in NUMBER,
                                p_range_start   in DATE,
                                p_range_end     in DATE,
                                p_std_freq      in VARCHAR2)
  RETURN NUMBER;
--
  FUNCTION Convert_Period_Type(
                 p_bus_grp_id            in NUMBER,
                 p_payroll_id            in NUMBER,
                 p_tax_unit_id           in NUMBER,
                 p_asst_work_schedule    in VARCHAR2,
                 p_asst_std_hours        in NUMBER,
                 p_figure                in NUMBER,
                 p_from_freq             in VARCHAR2,
                 p_to_freq               in VARCHAR2,
                 p_period_start_date     in DATE,
                 p_period_end_date       in DATE,
                 p_asst_std_freq         in VARCHAR2 )
  RETURN NUMBER;
--
  FUNCTION Work_Sch_Total_Hours_or_Days(
                                    p_bg_id       in NUMBER
                                   ,p_ws_name     in VARCHAR2
                                   ,p_range_start in DATE
                                   ,p_range_end   in DATE
                                   ,p_mode        in VARCHAR2)
  RETURN NUMBER;


  FUNCTION Work_Sch_Total_Hours_or_Days( p_bg_id          in NUMBER,
                                         p_ws_name        in VARCHAR2,
                                         p_range_start    in DATE,
                                         p_range_end      in DATE)
  RETURN NUMBER;

  FUNCTION get_idw (p_assignment_id  per_all_assignments_f.assignment_id%TYPE,
                    p_tax_unit_id    hr_organization_units.organization_id%TYPE,
                    p_effective_date DATE,
                    p_mode           VARCHAR2,
                    p_fixed_idw      OUT NOCOPY NUMBER,
                    p_variable_idw   OUT NOCOPY NUMBER)
  RETURN NUMBER;


  FUNCTION get_idw (p_assignment_id  per_all_assignments_f.assignment_id%TYPE,
                  p_tax_unit_id    hr_organization_units.organization_id%TYPE,
                  p_effective_date DATE,
                  p_payroll_action_id NUMBER,
                  p_mode           VARCHAR2,
                  p_fixed_idw      OUT NOCOPY NUMBER,
                  p_variable_idw   OUT NOCOPY NUMBER,
		  p_execute_old_idw_code       VARCHAR2)
  RETURN NUMBER;

  FUNCTION get_date_paid(p_payroll_action_id  pay_payroll_actions.payroll_action_id%TYPE)
  RETURN DATE;

  FUNCTION get_mx_historic_rate (
                     p_business_group_id          NUMBER
                    ,p_assignment_id              NUMBER
                    ,p_tax_unit_id                NUMBER
                    ,p_payroll_id                 NUMBER
                    ,p_effective_date             DATE
                    ,p_rate_code                  VARCHAR2)
  RETURN NUMBER;

  FUNCTION get_daily_base_pay (
                     p_business_group_id          NUMBER
                    ,p_assignment_id              NUMBER
                    ,p_tax_unit_id                NUMBER
                    ,p_payroll_id                 NUMBER
                    ,p_effective_date             DATE )
  RETURN NUMBER;

  FUNCTION get_base_pay_for_tax_calc (
                     p_business_group_id          NUMBER
                    ,p_assignment_id              NUMBER
                    ,p_tax_unit_id                NUMBER
                    ,p_payroll_id                 NUMBER
                    ,p_effective_date             DATE
                    ,p_month_or_pay_period        VARCHAR2)
  RETURN NUMBER;

--
--
END pay_mx_ff_udfs;

/
