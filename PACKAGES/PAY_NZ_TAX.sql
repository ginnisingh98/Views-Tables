--------------------------------------------------------
--  DDL for Package PAY_NZ_TAX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_NZ_TAX" AUTHID CURRENT_USER as
--  $Header: pynztax.pkh 115.3 2002/11/20 12:24:28 kaverma ship $
--
--  Copyright (c) 1999 Oracle Corporation
--  All Rights Reserved
--
--  Procedures and functions used in NZ tax calculations
--
--  Change List
--  ===========
--
--  Date        Author   Reference Description
--  -----------+--------+---------+-------------
--  20 NOV 2002 KAVERMA  2665496   Added dbdrv commands
--  27 JUL 1999 JTURNER  N/A       Added extra emol and child support fns
--  26 JUL 1999 JTURNER  N/A       Added half month start and end functions
--  22 JUL 1999 JTURNER  N/A       Created


--  other_asg_exists
--
--  function to check for existance of another current
--  assignment for the employee


function other_asg_exists(p_assignment_id in number) return varchar2 ;


--  half_month_start
--
--  Month halves are 1 - 15 and 16 - last day of month for tax reporting
--  purposes.  This function returns start date of half month that contains
--  effective date.


function half_month_start (p_effective_date in date) return date ;

pragma restrict_references (half_month_start, WNDS, WNPS) ;


--  half_month_end
--
--  Month halves are 1 - 15 and 16 - last day of month for tax reporting
--  purposes.  This function returns end date of half month that contains
--  effective_date.


function half_month_end (p_effective_date in date) return date ;

pragma restrict_references (half_month_end, WNDS, WNPS) ;


--  extra_emol_at_low_tax_rate
--
--  Determines if any extra emoluments have been taxed at the
--  lower rate.


function extra_emol_at_low_tax_rate (p_assignment_id in number, p_effective_date in date) return varchar2 ;

pragma restrict_references (extra_emol_at_low_tax_rate, WNDS, WNPS) ;


--  child_support_code
--
--  Determines child support variation code.


function child_support_code (p_assignment_id in number, p_effective_date in date) return varchar2 ;

pragma restrict_references (child_support_code, WNDS, WNPS) ;

end pay_nz_tax ;

 

/
