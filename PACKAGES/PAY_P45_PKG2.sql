--------------------------------------------------------
--  DDL for Package PAY_P45_PKG2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_P45_PKG2" AUTHID CURRENT_USER AS
/* $Header: payp45p.pkh 120.0.12000000.1 2007/01/17 14:29:21 appldev noship $ */
--
/*
  MODIFIED       (DD-MON-YYYY)
  btailor	  11-JUL-1995 - Created.
  smrobins        26-FEB-2002 - Added get_uk_term_dates
  smrobins        01-MAR-2002 - Change to get_uk_term_date,
                                p_reg_pay_date
                                now p_reg_pay_end_date
  gbutler	  27-JAN-2003   nocopy fixes
  amills          21-JUL-2003   Agg PAYE addition.
*/
--
procedure get_database_items (p_assignment_id     in     number,
                              p_date_earned       in     varchar2,
                              p_payroll_action_id in     number,
                              p_tax_period        in out nocopy varchar2,
                              p_tax_refno         in out nocopy varchar2,
                              p_tax_code          in out nocopy varchar2,
                              p_tax_basis         in out nocopy varchar2,
                              p_prev_pay_details  in out nocopy varchar2,
                              p_prev_tax_details  in out nocopy varchar2);
--
PROCEDURE get_balance_items (p_assignment_action_id in     number,
                             p_gross_pay            in out nocopy number,
                             p_taxable_pay          in out nocopy number,
                             p_agg_paye_flag        in     varchar2 default null);
--
PROCEDURE get_uk_term_dates (p_person_id            in     number,
                             p_period_of_service_id in     number,
                             p_act_term_date        in     date,
                             p_reg_pay_end_date     out nocopy    date);
--
END PAY_P45_PKG2;

 

/
