--------------------------------------------------------
--  DDL for Package BEN_EXT_PAYROLL_BALANCE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EXT_PAYROLL_BALANCE" AUTHID CURRENT_USER as
/* $Header: benxpybl.pkh 120.2.12010000.2 2008/08/05 14:59:40 ubhat ship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|			Copyright (c) 1997 Oracle Corporation		       |
|			   Redwood Shores, California, USA		       |
|			        All rights reserved.			       |
+==============================================================================+
--
Name
        Benefit Extract Thread
Purpose
        This package is to extract payroll balance data
History
        Date             Who        Version    What?
        17-May-2005      tjesumic   115.0      Created.
        27-sep-2005      tjesumic   115.1      sort_payroll_events added tp sort payroll event process

*/
--
g_package     varchar2(80) := 'ben_ext_payroll_balance';
--


function Get_Balance_Value
        (p_business_group_id  in number
        ,p_assignment_id      in number
        ,p_effective_date     in date
        ,p_legislation_code   in varchar2
        ,p_defined_balance_id in number
         )
         return number ;



PROCEDURE sort_payroll_events
            (p_pay_events_tab IN  ben_ext_person.t_detailed_output_table)
          ;
End ben_ext_payroll_balance ;

/
