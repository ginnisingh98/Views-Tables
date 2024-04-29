--------------------------------------------------------
--  DDL for Package PAY_MX_YEAREND_REP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_MX_YEAREND_REP" AUTHID CURRENT_USER AS
/* $Header: paymxyearend.pkh 120.1.12010000.1 2008/07/27 21:51:35 appldev ship $ */


function get_ye_arch_bal_amt (ye_payroll_action_id in number,
                              ye_person_id         in number,
                              ye_effective_date    in date,
                              ye_balance_name      in varchar2
                              ) RETURN NUMBER ;

function get_f37_balance(p_payroll_action_id  in number,
                         p_person_id          in number,
                         p_effective_date     in date,
                         p_bal_name           in varchar2 )
   return number ;

end pay_mx_yearend_rep ;


/
