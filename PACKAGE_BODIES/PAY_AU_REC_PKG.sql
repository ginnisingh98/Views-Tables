--------------------------------------------------------
--  DDL for Package Body PAY_AU_REC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_AU_REC_PKG" as
/* $Header: pyaurec.pkb 115.7 2002/12/04 08:48:58 ragovind ship $ */

------------------------------------------------------------------------
  -- Sums the Balances for This Pay ,according to the parameters.
  ------------------------------------------------------------------------
  procedure run_balances
    (p_assignment_id         in per_all_assignments_f.assignment_id%type,
     p_assignment_action_id  in pay_assignment_actions.assignment_action_id%type,
     p_effective_date        in date,
     p_balance_name          in pay_balance_types.balance_name%type,
     p_run_balance          out NOCOPY number)
  is

    cursor run_value
      (c_assignment_id         pay_assignment_actions.assignment_id%type,
       c_assignment_action_id  pay_assignment_actions.assignment_action_id%type,
       c_effective_date        date,
       c_balance_name          pay_balance_types.balance_name%type) is
    select nvl(hr_aubal.calc_asg_run(c_assignment_action_id,
                                     balance_type_id,
                                     c_effective_date,
                                     c_assignment_id),0)
    from   pay_balance_types
    where  balance_name = c_balance_name
    and    legislation_code = 'AU';

  begin
    open run_value (p_assignment_id,
                            p_assignment_action_id,
                            p_effective_date,
                            p_balance_name);
    fetch run_value into p_run_balance;
    close run_value;

  end run_balances;
  ------------------------------------------------------------------------
  -- Procedure to merely pass all the balance results back in one hit,
  -- rather than 5 separate calls.
  ------------------------------------------------------------------------
  procedure balance_totals
    (p_assignment_id               in per_all_assignments_f.assignment_id%type,
     p_assignment_action_id        in pay_assignment_actions.assignment_action_id%type,
     p_effective_date              in date,
     p_gross_this_pay             out NOCOPY number,
     p_other_deductions_this_pay  out NOCOPY number,
     p_tax_deductions_this_pay    out NOCOPY number,
     p_direct_payments_this_pay        out NOCOPY number,
     p_pre_tax_deductions_this_pay     out NOCOPY number)
  is
    v_earnings_run                number;
    v_direct_payments_run         number;
    v_involuntary_deductions_run  number;
    v_pre_tax_deductions_run      number;
    v_voluntary_deductions_run    number;
    v_tax_deductions_run          number;
    v_termination_payments_run    number;
    v_termination_deductions_run  number;
    v_non_tax_allow_run           number;

  begin

    run_balances (p_assignment_id         => p_assignment_id,
                          p_assignment_action_id  => p_assignment_action_id,
                          p_effective_date        => p_effective_date,
                          p_balance_name          => 'Earnings_Total',
                          p_run_balance           => v_earnings_run);

    run_balances (p_assignment_id         => p_assignment_id,
                          p_assignment_action_id  => p_assignment_action_id,
                          p_effective_date        => p_effective_date,
                          p_balance_name          => 'Direct Payments',
                          p_run_balance           => v_direct_payments_run);

    run_balances (p_assignment_id         => p_assignment_id,
                          p_assignment_action_id  => p_assignment_action_id,
                          p_effective_date        => p_effective_date,
                          p_balance_name          => 'Termination_Payments',
                          p_run_balance           => v_termination_payments_run);

    run_balances (p_assignment_id         => p_assignment_id,
                          p_assignment_action_id  => p_assignment_action_id,
                          p_effective_date        => p_effective_date,
                          p_balance_name          => 'Involuntary Deductions',
                          p_run_balance           => v_involuntary_deductions_run);

    run_balances (p_assignment_id         => p_assignment_id,
                          p_assignment_action_id  => p_assignment_action_id,
                          p_effective_date        => p_effective_date,
                          p_balance_name          => 'Pre Tax Deductions',
                          p_run_balance           => v_pre_tax_deductions_run);

    run_balances (p_assignment_id         => p_assignment_id,
                          p_assignment_action_id  => p_assignment_action_id,
                          p_effective_date        => p_effective_date,
                          p_balance_name          => 'Termination Deductions',
                          p_run_balance           => v_termination_deductions_run);

    run_balances (p_assignment_id         => p_assignment_id,
                          p_assignment_action_id  => p_assignment_action_id,
                          p_effective_date        => p_effective_date,
                          p_balance_name          => 'Voluntary Deductions',
                          p_run_balance           => v_voluntary_deductions_run);

    run_balances (p_assignment_id         => p_assignment_id,
                          p_assignment_action_id  => p_assignment_action_id,
                          p_effective_date        => p_effective_date,
                          p_balance_name          => 'Total_Tax_Deductions',
                          p_run_balance           => v_tax_deductions_run);

    run_balances (p_assignment_id         => p_assignment_id,
                          p_assignment_action_id  => p_assignment_action_id,
                          p_effective_date        => p_effective_date,
                          p_balance_name          => 'Earnings_Non_Taxable',
                          p_run_balance           => v_non_tax_allow_run);

    p_gross_this_pay            := v_earnings_run +
                                   v_termination_payments_run -
                                   v_non_tax_allow_run;

    p_other_deductions_this_pay := v_involuntary_deductions_run +
                                   v_pre_tax_deductions_run +
                                   v_voluntary_deductions_run;

    p_tax_deductions_this_pay   := v_tax_deductions_run +
                                   v_termination_deductions_run;

    p_direct_payments_this_pay   := v_direct_payments_run +
                                    v_non_tax_allow_run;

    p_pre_tax_deductions_this_pay  := v_pre_tax_deductions_run;


  end balance_totals;


  ------------------------------------------------------------------------
end pay_au_rec_pkg;

/
