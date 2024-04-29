--------------------------------------------------------
--  DDL for Package HR_LEG_RULE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_LEG_RULE" AUTHID CURRENT_USER as
/* $Header: pylegrle.pkh 115.0 99/07/17 06:15:37 porting ship $ */

   function get_independent_periods
      (l_business_group_id in number)
   return varchar2;

end hr_leg_rule;

 

/
