--------------------------------------------------------
--  DDL for Package PAY_GB_REP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_GB_REP" AUTHID CURRENT_USER AS
/* $Header: paygbrep.pkh 120.1 2006/09/12 09:24:16 ajeyam noship $ */

PROCEDURE ni_arrears_report(
           errbuf                   out NOCOPY varchar2
          ,retcode                  out NOCOPY varchar2
          ,p_business_group_id      in  varchar2
          ,p_effective_date   in  varchar2
                      ,p_payroll_id             in  varchar2
                      ,p_def_bal_id             in  varchar2);

PROCEDURE p45_issued_active_asg_report(
                       errbuf                   out NOCOPY varchar2
                      ,retcode                  out NOCOPY varchar2
                      ,p_business_group_id      in  varchar2
                      ,p_effective_date         in  varchar2
                      ,p_payroll_id             in  varchar2);
END pay_gb_rep;

/
