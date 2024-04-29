--------------------------------------------------------
--  DDL for Package PAY_ZA_SOE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ZA_SOE" AUTHID CURRENT_USER as
/* $Header: pyzasoe.pkh 120.0.12010000.1 2008/07/28 00:04:39 appldev ship $ */
--
function Get_Tax_Status(p_assignment_id in number, p_date_earned in date) return varchar2;
--
function Personal_Information(p_assignment_action_id in number) return long;
--
function Payroll_Processing_Information(p_assignment_action_id in number) return long;
--
function Elements1(p_assignment_action_id in number) return long;
--
function Elements2(p_assignment_action_id in number) return long;
--
function Elements3(p_assignment_action_id in number) return long;
--
function Elements4(p_assignment_action_id in number) return long;
--
function Elements5(p_assignment_action_id in number) return long;
--
function Elements6(p_assignment_action_id in number) return long;
--
function Balance_Details(p_assignment_action_id in number) return long;
--
function Payment_Method_Details(p_assignment_action_id in number) return long;
--
end PAY_ZA_SOE;


/
