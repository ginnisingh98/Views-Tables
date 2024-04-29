--------------------------------------------------------
--  DDL for Package HR_PRE_PAY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PRE_PAY" AUTHID CURRENT_USER as
/* $Header: pyprepyt.pkh 120.1.12010000.1 2008/07/27 23:26:51 appldev ship $ */
--
-- Pre-Payments package (called from pro*C)
--
  procedure pay_coin(no_of_units in number,factor in number);
  --
  procedure initialise(action_id in out nocopy varchar2);
  procedure init_override(action_id in out nocopy varchar2,
                          override_method in out nocopy varchar2);
  procedure get_ren_balance(p_bus_grp     in number,
                            p_def_bal_id  in out nocopy number);
  procedure override_mult_tax_unit_payment(p_business_group_id      in            number,
                                           p_multi_tax_unit_payment in out nocopy varchar2);
  procedure close_cursors;
  function set_cash_rule(p_type in varchar2, p_seg1 in varchar2)
                        return varchar2;
  procedure get_dynamic_org_method (p_plsql_proc in varchar2,
                                    p_assignment_action in number,
                                    p_effective_date in date,
                                    p_org_meth in number,
                                    p_org_method_id out nocopy number );
procedure do_prepayment(p_asg_act in number,
                        p_effective_date varchar2,
                        p_ma_flag  in number,
                        p_def_bal_id in number,
                        p_asg_id in number,
                        p_override_meth in number,
                        p_multi_gre_payment in varchar2);
 --
 p_leg_code      per_business_groups_perf.legislation_code%type;
 p_bg_id         per_business_groups_perf.business_group_id%type;
 p_cur_id        number;
 --
  function get_trx_date
  (
      p_business_group_id     in number,
      p_payroll_action_id     in number,
      p_assignment_action_id  in number   default null,
      p_payroll_id            in number   default null,
      p_consolidation_set_id  in number   default null,
      p_org_payment_method_id in number   default null,
      p_effective_date        in date     default null,
      p_date_earned           in date     default null,
      p_override_date         in date     default null,
      p_pre_payment_id        in number   default null
  ) return date;
 --
procedure process_asg_rollup(p_assignment_action in number);
procedure process_pact_rollup(p_pactid in number);
--
 -- pragma restrict_references (set_cash_rule, WNDS, WNPS);
end hr_pre_pay;

/
