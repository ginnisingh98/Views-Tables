--------------------------------------------------------
--  DDL for Package PAY_SOE_GLB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_SOE_GLB" AUTHID CURRENT_USER as
/* $Header: pysoeglb.pkh 120.0.12010000.1 2008/07/27 23:42:41 appldev ship $ */
--
g_currency_code varchar2(10);

function setParameters(p_assignment_action_id number) return varchar2;
--
function setParameters(p_person_id in number, p_assignment_id number, p_effective_date date) return varchar2;
--
function Employee(p_assignment_action_id number) return long;
--
function Period(p_assignment_action_id number) return long;
--
function Elements1(p_assignment_action_id number) return long;
--
function Elements2(p_assignment_action_id number) return long;
--
function Elements3(p_assignment_action_id number) return long;
--
function Elements4(p_assignment_action_id number) return long;
--
function Elements5(p_assignment_action_id number) return long;
--
function Elements6(p_assignment_action_id number) return long;
--
function Information1(p_assignment_action_id number) return long;
--
function Balances1(p_assignment_action_id number) return long;
--
function Balances2(p_assignment_action_id number) return long;
--
function Balances3(p_assignment_action_id number) return long;
--
function PrePayments(p_assignment_action_id number) return long;
--
function Message(p_assignment_action_id number) return long;
--
---------------------------------------------------------------------------
-- Function : get_retro_period , taken from pynlgenr.pkb
-- Function returns the retro period for the given element_entry_id and
-- date_earned
---------------------------------------------------------------------------

function get_retro_period
        (
             p_element_entry_id in pay_element_entries_f.element_entry_id%TYPE,
             p_date_earned in pay_payroll_actions.date_earned%TYPE,
             p_call_type in integer
        )    return varchar2;

end pay_soe_glb;


/
