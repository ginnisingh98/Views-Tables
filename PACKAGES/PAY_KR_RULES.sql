--------------------------------------------------------
--  DDL for Package PAY_KR_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_KR_RULES" AUTHID CURRENT_USER as
/*   $Header: pykrrule.pkh 120.1.12000000.1 2007/01/17 22:14:26 appldev noship $ */
/*
   Copyright (c) Oracle Corporation 1991,1992,1993,1994. All rights reserved
--
   Name        : pay_kr_rules
--
   Change List
   -----------
   Date         Name        Vers   Bug       Description
   -----------  ----------  -----  --------  -------------------------------------------
   10-APR-2002  nbristow    115.0            Created.
   12-DEC-2002  krapolu     115.1            Added the NOCOPY directive
   07-FEB-2006  mmark       115.2  4913403   Added GET_DYNAMIC_ORG_METH
*/
   procedure get_default_run_type(p_asg_id   in number,
                                  p_ee_id    in number,
                                  p_effdate  in date,
                                  p_run_type out NOCOPY varchar2);

   procedure get_dynamic_org_meth(
   		p_assignment_action_id in number,
		p_effective_date       in date,
		p_org_meth             in number,   -- org meth with no bank account
		p_org_method_id        out nocopy number
    ) ;
end pay_kr_rules;

 

/
