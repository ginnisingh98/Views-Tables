--------------------------------------------------------
--  DDL for Package PAY_US_TAX_BALANCE_PERF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_TAX_BALANCE_PERF" AUTHID CURRENT_USER as
/* $Header: pyustxpl.pkh 120.0 2005/05/29 10:02:35 appldev noship $ */
--
-- Copyright (c) Oracle Corporation 1991, 1992, 1993. All rights reserved.
--
/*
   NAME
      pyustxpl.pkh
--
   DESCRIPTION
      API to get US tax balance figures performance version.
--
  MODIFIED (DD-MON-YYYY)
  N Bristow  21-MAY-1996     Changed package name to comply with standards.
  N Bristow  30-APR-1996     Created from a copy of pay_us_tax_bals_pkg,
                             altered package for chequewriter performance
                             reasons.
   WMcVeagh    19-mar-98   Change create or replace 'as' not 'is'
*/
-------------------------------------------------------------------------------
--
--
--
--
-------------------------------------------------------------------------------
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
                          p_business_group_id     in number)
RETURN number;
END pay_us_tax_balance_perf;

 

/
