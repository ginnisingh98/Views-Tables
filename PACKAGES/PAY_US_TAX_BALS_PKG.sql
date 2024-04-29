--------------------------------------------------------
--  DDL for Package PAY_US_TAX_BALS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_TAX_BALS_PKG" AUTHID CURRENT_USER as
/* $Header: pyustxbl.pkh 120.0.12010000.1 2008/07/27 23:57:40 appldev ship $ */
--
-- Copyright (c) Oracle Corporation 1991, 1992, 1993. All rights reserved.
--
/*
   NAME
      pyustxbl.pkh
--
   DESCRIPTION
      See description in pyustxbl.pkb
--
  MODIFIED (DD-MON-YYYY)
  S Panwar   1-FEB-1995      Created
  N.Bristow 20-NOV-1996      Created overload functions and us_tax_balance_rep.
  tbattoo   11-MAY-1998      dual mantained changes in view so
                             GRE PYDATE routes work over a range

*/
--
-- Procedures
--
FUNCTION  us_tax_balance_rep (
                          p_asg_lock              in boolean   DEFAULT TRUE,
                          p_tax_balance_category  in varchar2,
                          p_tax_type              in varchar2,
                          p_ee_or_er              in varchar2,
                          p_time_type             in varchar2,
                          p_asg_type              in varchar2,
                          p_gre_id_context        in number,
                          p_jd_context            in varchar2  DEFAULT NULL,
                          p_assignment_action_id  in number    DEFAULT NULL,
                          p_assignment_id         in number    DEFAULT NULL,
                          p_virtual_date          in date      DEFAULT NULL,
                          p_payroll_action_id     in number)
RETURN number;
--
FUNCTION  us_tax_balance_rep (
                          p_asg_lock              in boolean   DEFAULT TRUE,
                          p_tax_balance_category  in varchar2,
                          p_tax_type              in varchar2,
                          p_ee_or_er              in varchar2,
                          p_time_type             in varchar2,
                          p_asg_type              in varchar2,
                          p_gre_id_context        in number,
                          p_jd_context            in varchar2  DEFAULT NULL,
                          p_assignment_action_id  in number    DEFAULT NULL,
                          p_assignment_id         in number    DEFAULT NULL,
                          p_virtual_date          in date      DEFAULT NULL
                          )
RETURN number;
--
--
FUNCTION  us_tax_balance (p_tax_balance_category  in varchar2,
                          p_tax_type              in varchar2,
                          p_ee_or_er              in varchar2,
                          p_time_type             in varchar2,
                          p_asg_type              in varchar2,
                          p_gre_id_context        in number,
                          p_jd_context            in varchar2  DEFAULT NULL,
                          p_assignment_action_id  in number    DEFAULT NULL,
                          p_assignment_id         in number    DEFAULT NULL,
                          p_virtual_date          in date      DEFAULT NULL)
RETURN number;
--
FUNCTION  us_tax_balance (p_tax_balance_category  in varchar2,
                          p_tax_type              in varchar2,
                          p_ee_or_er              in varchar2,
                          p_time_type             in varchar2,
                          p_asg_type              in varchar2,
                          p_gre_id_context        in number,
                          p_jd_context            in varchar2  DEFAULT NULL,
                          p_assignment_action_id  in number    DEFAULT NULL,
                          p_assignment_id         in number    DEFAULT NULL,
                          p_virtual_date          in date      DEFAULT NULL,
                          p_payroll_action_id     in number)

RETURN number;
--
FUNCTION  us_tax_balance (p_tax_balance_category  in varchar2,
                          p_tax_type              in varchar2,
                          p_ee_or_er              in varchar2,
                          p_time_type             in varchar2,
                          p_asg_type              in varchar2,
                          p_gre_id_context        in number,
                          p_jd_context            in varchar2  DEFAULT NULL,
                          p_assignment_action_id  in number    DEFAULT NULL,
                          p_assignment_id         in number    DEFAULT NULL,
                          p_virtual_date          in date      DEFAULT NULL,
                          p_payroll_action_id     in number,
                          p_asg_lock              in boolean)
RETURN number;
--
end pay_us_tax_bals_pkg;

/
