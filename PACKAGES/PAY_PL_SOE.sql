--------------------------------------------------------
--  DDL for Package PAY_PL_SOE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PL_SOE" AUTHID CURRENT_USER as
/* $Header: pyplsoep.pkh 120.0 2005/10/14 03:51:47 mseshadr noship $ */

function employee(p_assignment_action_id in number)
					   return long;

-- This function is used in the Tax Information region
function tax_information(p_assignment_action_id in number)
                          return long;

-- This function is used in Earnings Region
function Elements1(p_assignment_action_id number) return long;

-- This function is used in the Deductions region
function Elements2(p_assignment_action_id number) return long;

end pay_pl_soe;

 

/
