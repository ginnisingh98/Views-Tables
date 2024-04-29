--------------------------------------------------------
--  DDL for Package PAY_US_PTO_ACCRUAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_PTO_ACCRUAL" AUTHID CURRENT_USER as
/* $Header: pyusptoa.pkh 120.1 2005/10/04 02:32:23 schauhan noship $ */
--
 /*
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1993 Oracle Corporation.                        *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation,         *
   *  500 Oracle Parkway, Redwood City, CA, 94065.                  *
   *                                                                *
   ******************************************************************

    Name        : pay_us_pto_accrual
    Description : This package holds building blocks used in PTO accrual
                  calculation.

    Uses        : hr_utility

    Change List
    -----------
    Date        Name          Vers    Bug No     Description
    ----        ----          ----    ------     -----------
    FEB-16-1994 RMAMGAIN      1.0                Created with following proc.
                                                  . get_accrual
                                                  . get_accrual_for_plan
                                                  . get_first_accrual_period
                                                  . ceiling_calc
    OCT-16-2002 DCASEMOR      115.3   2377873    Added delete_plan_from_cache.
    OCT-04-2005 SCHAUHAN      115.4              Added nocopy hint to OUT and IN OUT
                                                 parameters.

  */
--
--
-- Global Variable
--
PROCEDURE delete_plan_from_cache
            (p_plan_id IN NUMBER);
--
--
FUNCTION get_accrual
                    ( P_assignment_id        number,
                      P_calculation_date     date,
                      P_plan_id              number   DEFAULT NULL,
                      P_plan_category        varchar2 DEFAULT NULL)
         RETURN Number;
--
--
PROCEDURE accrual_calc_detail
              (P_assignment_id          IN    number,
               P_calculation_date    IN OUT  nocopy date,
               P_plan_id                IN    number   DEFAULT NULL,
               P_plan_category          IN    varchar2 DEFAULT NULL,
               P_mode                   IN    varchar2 DEFAULT 'N',
               P_accrual                OUT  nocopy  number,
               P_payroll_id          IN OUT  nocopy number,
               P_first_period_start  IN OUT  nocopy date,
               P_first_period_end    IN OUT  nocopy date,
               P_last_period_start   IN OUT  nocopy date,
               P_last_period_end     IN OUT  nocopy date,
               P_cont_service_date      OUT  nocopy date,
               P_start_date             OUT  nocopy date,
               P_end_date               OUT  nocopy date,
               P_current_ceiling        OUT  nocopy number,
               P_current_carry_over     OUT  nocopy number);
--
--
PROCEDURE get_accrual_for_plan
                    ( p_plan_id                 Number,
                      p_first_p_start_date      date,
                      p_first_p_end_date        date,
                      p_first_calc_P_number     number,
                      p_accrual_calc_p_end_date date,
                      P_accrual_calc_P_number   number,
                      P_number_of_periods       number,
                      P_payroll_id              number,
                      P_assignment_id           number,
                      P_plan_ele_type_id        number,
                      P_continuous_service_date date,
                      P_Plan_accrual            OUT nocopy number,
                      P_current_ceiling         OUT nocopy number,
                      P_current_carry_over      OUT nocopy number );
--
--
FUNCTION get_working_days
                    ( P_start_date           date,
                      P_end_date             date )
         RETURN   NUMBER;
--
--
FUNCTION get_net_accrual
                    ( P_assignment_id        number,
                      P_calculation_date     date,
                      P_plan_id              number   default null,
                      P_plan_category        Varchar2 default null,
                      P_assignment_action_id number   default null)
         RETURN   NUMBER;
--
--
PROCEDURE net_accruals
              (P_assignment_id          IN    number,
               P_calculation_date    IN OUT  nocopy date,
               P_plan_id                IN    number   DEFAULT NULL,
               P_plan_category          IN    varchar2 DEFAULT NULL,
               P_mode                   IN    varchar2 DEFAULT 'N',
               P_accrual             IN OUT  nocopy number,
               P_net_accrual            OUT  nocopy number,
               P_payroll_id          IN OUT  nocopy number,
               P_first_period_start  IN OUT  nocopy date,
               P_first_period_end    IN OUT  nocopy date,
               P_last_period_start   IN OUT  nocopy date,
               P_last_period_end     IN OUT  nocopy date,
               P_cont_service_date      OUT  nocopy date,
               P_start_date          IN OUT  nocopy date,
               P_end_date            IN OUT  nocopy date,
               P_current_ceiling        OUT  nocopy number,
               P_current_carry_over     OUT  nocopy number);
--
-- Define global cursors which will be shared by different functions in
-- this package.
--
CURSOR csr_get_payroll (P_assignment_id    number,
                        P_calculation_date date )  IS
       select a.payroll_id,
              a.effective_start_date,
              a.effective_end_date,
              a.business_group_id,
              b.DATE_START,
              b.ACTUAL_TERMINATION_DATE
       from   PER_ASSIGNMENTS_F      a,
              PER_PERIODS_OF_SERVICE b
       where  a.assignment_id        = P_assignment_id
       and    P_calculation_date between a.effective_start_date and
                                         a.effective_end_date
       and    a.PERIOD_OF_SERVICE_ID = b.PERIOD_OF_SERVICE_ID;
--
--
CURSOR csr_get_period (p_payroll_id     number,
                       p_effective_date date   )  is
       select PERIOD_NUM,
              START_DATE,
              END_DATE
       from   PER_TIME_PERIODS
       where  PAYROLL_ID             = p_payroll_id
       and    p_effective_date between START_DATE and END_DATE;
--
-- Lwthomps, disabled indexes for performance problems
--
CURSOR csr_calc_accrual (P_start_date    date,
                         P_end_date      date,
                         P_assignment_id number,
                         P_plan_id       number ) IS
       select sum(to_number(nvl(pev.SCREEN_ENTRY_VALUE,'0')) *
                  to_number(pnc.add_or_subtract))
       from   pay_net_calculation_rules    pnc,
              pay_element_entry_values_f   pev,
              pay_element_entries_f        pee
       where  pnc.accrual_plan_id    = p_plan_id
       and    pnc.input_value_id     = pev.input_value_id + 0
       and    pev.element_entry_id    = pee.element_entry_id
       and    pee.assignment_id      = P_assignment_id
       and    pee.effective_start_date between P_start_date and
                                               P_end_date;
--
--
CURSOR csr_get_total_periods ( p_payroll_id     number,
                               p_date           date   ) is
       select min(start_date),
              min(end_date),
              max(start_date),
              max(end_date),
              count(period_num)
       from   per_time_periods
       where  payroll_id             = p_payroll_id
       and    to_char(P_date,'YYYY') = to_char(end_date,'YYYY');
--
--
END pay_us_pto_accrual;

 

/
