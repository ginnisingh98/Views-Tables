--------------------------------------------------------
--  DDL for Package PAY_NZ_REC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_NZ_REC_PKG" AUTHID CURRENT_USER as
/* $Header: pynzrec.pkh 115.2 2002/12/03 05:34:52 srrajago ship $*/

function period_payment_date
    (p_time_period_id in pay_payroll_actions.time_period_id%type)
  return per_time_periods.regular_payment_date%type;

  function first_action_sequence
    (p_assignment_id  in pay_assignment_actions.assignment_id%type,
     p_time_period_id in pay_payroll_actions.time_period_id%type)
  return pay_assignment_actions.action_sequence%type;

  function last_action_sequence
    (p_payroll_action_id in pay_payroll_actions.payroll_action_id%type,
     p_assignment_id     in pay_assignment_actions.assignment_id%type)
  return pay_assignment_actions.action_sequence%type;

  function result_ptd
    (p_payroll_action_id in pay_payroll_actions.payroll_action_id%type,
     p_assignment_id     in pay_assignment_actions.assignment_id%type,
     p_element_type_id   in pay_element_types_f.element_type_id%type)
  return number;

  function result_ytd
    (p_payroll_action_id in pay_payroll_actions.payroll_action_id%type,
     p_assignment_id     in pay_assignment_actions.assignment_id%type,
     p_element_type_id   in pay_element_types_f.element_type_id%type)
  return number;

  function single_feed_balance
    (p_payroll_action_id    in  pay_payroll_actions.payroll_action_id%type,
     p_assignment_id        in  pay_assignment_actions.assignment_id%type,
     p_element_type_id      in  pay_element_types_f.element_type_id%type,
     p_assignment_action_id out nocopy pay_assignment_actions.assignment_action_id%type,
     p_balance_type_id      out nocopy pay_balance_types.balance_type_id%type,
     p_effective_start_date out nocopy pay_balance_feeds_f.effective_start_date%type)
  return boolean;

  function value_ptd
    (p_payroll_action_id in pay_payroll_actions.payroll_action_id%type,
     p_assignment_id     in pay_assignment_actions.assignment_id%type,
     p_element_type_id   in pay_element_types_f.element_type_id%type)
  return number;

  function value_ytd
    (p_payroll_action_id in pay_payroll_actions.payroll_action_id%type,
     p_assignment_id     in pay_assignment_actions.assignment_id%type,
     p_element_type_id   in pay_element_types_f.element_type_id%type)
  return number;
end pay_nz_rec_pkg;

 

/
