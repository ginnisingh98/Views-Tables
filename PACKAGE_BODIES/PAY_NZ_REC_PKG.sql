--------------------------------------------------------
--  DDL for Package Body PAY_NZ_REC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_NZ_REC_PKG" as
/* $Header: pynzrec.pkb 120.3 2005/09/21 01:55:42 snekkala noship $ */
  ------------------------------------------------------------------------
  -- Selects the Regular Payment Date for the Period Id that is passed in.
  ------------------------------------------------------------------------
  function period_payment_date
    (p_time_period_id in pay_payroll_actions.time_period_id%type)
  return per_time_periods.regular_payment_date%type is

    v_payment_date    per_time_periods.regular_payment_date%type;

    cursor payment_date
      (c_time_period_id in pay_payroll_actions.time_period_id%type) is

    select regular_payment_date
    from   per_time_periods
    where  time_period_id = c_time_period_id;

  begin
    open payment_date (p_time_period_id);
    fetch payment_date into v_payment_date;
    close payment_date;

    return v_payment_date;
  end period_payment_date;

  ------------------------------------------------------------------------
  --  Selects the first Action Sequence of the current Financial Year for
  --  that Assignment. The start of the Financial Year is obtained from the
  -- call to another package function.
  ------------------------------------------------------------------------
  function first_action_sequence
    (p_assignment_id  in pay_assignment_actions.assignment_id%type,
     p_time_period_id in pay_payroll_actions.time_period_id%type)
  return pay_assignment_actions.action_sequence%type is

    v_action_sequence    pay_assignment_actions.action_sequence%type := null;
    v_payment_date       per_time_periods.regular_payment_date%type  := null;

    v_start_of_year_day  constant varchar2(5)                        := '01-04';

    /*Bug #3306269 - Added per_assignments_f with date_effective checks, and
                     added action_status check for ppa and pac */
   /* Bug #4200412 - Added p_time_period_id */
    cursor min_sequence
      (c_assignment_id       in pay_assignment_actions.assignment_id%type,
       c_period_payment_date in per_time_periods.regular_payment_date%type) is

    select min(pac.action_sequence)
    from   per_assignments_f      paf,
           per_time_periods       ptp,
           pay_payroll_actions    ppa,
           pay_assignment_actions pac
    where  paf.assignment_id         = c_assignment_id
    and    pac.assignment_id         = paf.assignment_id
    and    ptp.time_period_id        = ppa.time_period_id
    AND    ppa.time_period_id        = p_time_period_id
    AND    ppa.time_period_id        = ptp.time_period_id
    and    ppa.payroll_action_id     = pac.payroll_action_id
    and    ptp.regular_payment_date between paf.effective_Start_date
                                        and paf.effective_end_date
    and    pac.action_status         = 'C'
    and    ppa.action_status         = 'C'
    and    ptp.regular_payment_date >=
                   hr_nz_routes.span_start(c_period_payment_date,
                                           1, v_start_of_year_day);

  begin
    v_payment_date := period_payment_date (p_time_period_id);

    if v_payment_date is not null then
      open min_sequence (p_assignment_id, v_payment_date);
      fetch min_sequence into v_action_sequence;
      close min_sequence;
    end if;

    return v_action_sequence;
  end first_action_sequence;

  ------------------------------------------------------------------------
  -- Selects the current Action Sequence for that Assignment.
  ------------------------------------------------------------------------
  function last_action_sequence
    (p_payroll_action_id in pay_payroll_actions.payroll_action_id%type,
     p_assignment_id     in pay_assignment_actions.assignment_id%type)
  return pay_assignment_actions.action_sequence%type is

    v_action_sequence    pay_assignment_actions.action_sequence%type;

    cursor max_sequence
      (c_payroll_action_id in pay_payroll_actions.payroll_action_id%type,
       c_assignment_id     in pay_assignment_actions.assignment_id%type) is

    select pac.action_sequence
    from   pay_payroll_actions    ppa,
           pay_assignment_actions pac
    where  ppa.payroll_action_id = pac.payroll_action_id
    and    ppa.payroll_action_id = c_payroll_action_id
    and    pac.assignment_id     = c_assignment_id;

  begin
    open max_sequence (p_payroll_action_id, p_assignment_id);
    fetch max_sequence into v_action_sequence;
    close max_sequence;

    return v_action_sequence;
  end last_action_sequence;

  ------------------------------------------------------------------------
  -- Sums the Result Values for the Period-To-Date. This will be called for
  -- Elements that are the only feed for their Balance.
  ------------------------------------------------------------------------
  function result_ptd
    (p_payroll_action_id in pay_payroll_actions.payroll_action_id%type,
     p_assignment_id     in pay_assignment_actions.assignment_id%type,
     p_element_type_id   in pay_element_types_f.element_type_id%type)
  return number is

    v_input_value_name    constant pay_input_values_f.name%type := 'Pay Value';
    v_uom                 constant pay_input_values_f.uom%type  := 'M';

  -- It makes sense to only sum values that have Money as a Unit of Measure
    v_ptd_results         number := 0;

    cursor sum_results
      (c_payroll_action_id in pay_payroll_actions.payroll_action_id%type,
       c_assignment_id     in pay_assignment_actions.assignment_id%type,
       c_element_type_id   in pay_element_types_f.element_type_id%type) is

    select sum(prrv.result_value)
    from   pay_payroll_actions    ppa,
           pay_assignment_actions pac,
           pay_run_results        prr,
           pay_run_result_values  prrv,
           pay_element_types_f    pet,
           pay_input_values_f     piv
    where  ppa.payroll_action_id    = c_payroll_action_id
    and    pac.assignment_id        = c_assignment_id
    and    pet.element_type_id      = c_element_type_id
    and    piv.uom                  = v_uom
    and    piv.name                 = v_input_value_name
    and    ppa.payroll_action_id    = pac.payroll_action_id
    and    pac.assignment_action_id = prr.assignment_action_id
    and    prr.run_result_id        = prrv.run_result_id
    and    pet.element_type_id      = prr.element_type_id
    and    pet.element_type_id      = piv.element_type_id
    and    piv.input_value_id       = prrv.input_value_id;

  begin
    open sum_results (p_payroll_action_id, p_assignment_id, p_element_type_id);
    fetch sum_results into v_ptd_results;

    -- Bug 3776051 Changes start
    -- Sparse matrix
    --
    IF sum_results%NOTFOUND THEN
        v_ptd_results:=0;
    END IF;

    close sum_results;

    return nvl(v_ptd_results,0);
    --
    -- Bug 3776051 Changes end
    --

  end result_ptd;

  ------------------------------------------------------------------------
  -- Sums the Result Values for the Year-To-Date. This will be called for
  -- Elements that are the only feed for their Balance.
  ------------------------------------------------------------------------
  function result_ytd
    (p_payroll_action_id in pay_payroll_actions.payroll_action_id%type,
     p_assignment_id     in pay_assignment_actions.assignment_id%type,
     p_element_type_id   in pay_element_types_f.element_type_id%type)
  return number is

    v_input_value_name    constant pay_input_values_f.name%type := 'Pay Value';
    v_uom                 constant pay_input_values_f.uom%type  := 'M';

  -- It makes sense to only sum values that have Money as a Unit of Measure
    v_ytd_results         number := 0;
    v_time_period_id      per_time_periods.time_period_id%type;

    CURSOR sum_results
      (c_payroll_action_id IN pay_payroll_actions.payroll_action_id%TYPE,
       c_assignment_id     IN pay_assignment_actions.assignment_id%TYPE,
       c_element_type_id   IN pay_element_types_f.element_type_id%TYPE,
       c_time_period_id    IN per_time_periods.time_period_id%TYPE)
     IS
       SELECT SUM(prrv.result_value)
         FROM pay_payroll_actions    ppa
	    , pay_assignment_actions pac
	    , pay_run_results        prr
	    , pay_run_result_values  prrv
	    , pay_element_types_f    pet
	    , pay_input_values_f     piv
        WHERE pac.assignment_id        = c_assignment_id
          AND pet.element_type_id      = c_element_type_id
          AND piv.uom                  = v_uom
          AND piv.name                 = v_input_value_name
          AND ppa.payroll_action_id    = pac.payroll_action_id
          AND ppa.time_period_id      <= c_time_period_id
          AND ppa.payroll_action_id   <= c_payroll_action_id
          AND pac.assignment_action_id = prr.assignment_action_id
          AND prr.run_result_id        = prrv.run_result_id
          AND pet.element_type_id      = prr.element_type_id
          AND pet.element_type_id      = piv.element_type_id
          AND piv.input_value_id       = prrv.input_value_id
          AND pac.action_sequence     >= first_action_sequence(pac.assignment_id, c_time_period_id)
          AND pac.action_sequence     <= last_action_sequence(c_payroll_action_id, pac.assignment_id);

    cursor get_time_period_id (c_payroll_action_id in
pay_payroll_actions.payroll_action_id%type) is
          select time_period_id from pay_payroll_actions
          where payroll_action_id  = c_payroll_action_id;
  begin
    open get_time_period_id(p_payroll_action_id);
    fetch get_time_period_id into v_time_period_id;
    close get_time_period_id;

    open sum_results (p_payroll_action_id, p_assignment_id, p_element_type_id,v_time_period_id);

    fetch sum_results into v_ytd_results;

    -- Bug 3776051 Changes start
    -- Sparse matrix
    --
    IF sum_results%NOTFOUND THEN
        v_ytd_results:=0;
    END IF;
    --
    -- Bug 3776051 Changes end
    --

    close sum_results;

    return nvl(v_ytd_results,0);
  end result_ytd;

  ------------------------------------------------------------------------
  -- This function returns TRUE if the Element is the only Feed to its
  -- Balance. Otherwise it returns FALSE. This is determined by executing
  -- the cursor and if a row is returned, then it must be a single balance
  -- feed, so return the necessary parameters required to call
  -- hr_nzbal.calc_asg_ytd. Otherwise no records will be returned.
  ------------------------------------------------------------------------
  function single_feed_balance
    (p_payroll_action_id    in  pay_payroll_actions.payroll_action_id%type,
     p_assignment_id        in  pay_assignment_actions.assignment_id%type,
     p_element_type_id      in  pay_element_types_f.element_type_id%type,
     p_assignment_action_id out nocopy pay_assignment_actions.assignment_action_id%type,
     p_balance_type_id      out nocopy pay_balance_types.balance_type_id%type,
     p_effective_start_date out nocopy pay_balance_feeds_f.effective_start_date%type)
  return boolean is

    v_input_value_name    constant pay_input_values_f.name%type := 'Pay Value';
    v_uom                 constant pay_input_values_f.uom%type  := 'M';

    v_single_feed         boolean := FALSE;

    cursor single_balance_feed
      (c_payroll_action_id in pay_payroll_actions.payroll_action_id%type,
       c_assignment_id     in pay_assignment_actions.assignment_id%type,
       c_element_type_id   in pay_element_types_f.element_type_id%type) is

    select pac.assignment_action_id,
           pbf.balance_type_id,
           pbf.effective_start_date
    from   pay_element_types_f    pet,
           pay_input_values_f     piv,
           pay_balance_feeds_f    pbf,
           pay_payroll_actions    ppa,
           pay_assignment_actions pac,
           pay_run_results        prr
    where  ppa.payroll_action_id    = c_payroll_action_id
    and    pet.element_type_id      = c_element_type_id
    and    pac.assignment_id        = c_assignment_id
    and    piv.name                 = v_input_value_name
    and    piv.uom                  = v_uom
    and    ppa.payroll_action_id    = pac.payroll_action_id
    and    pac.assignment_action_id = prr.assignment_action_id
    and    pet.element_type_id      = piv.element_type_id
    and    pet.element_type_id      = prr.element_type_id
    and    piv.input_value_id       = pbf.input_value_id
    and    not exists (select null
                       from   pay_balance_feeds_f pbf_not
                       where  pbf_not.balance_feed_id <> pbf.balance_feed_id
                       and    pbf_not.balance_type_id  = pbf.balance_type_id
                    and    (ppa.effective_date     between  pbf_not.effective_start_date
                     and pbf_not.effective_end_date))
    and    not exists (select null
                       from   pay_balance_classifications pbc_not
                       where  pbc_not.balance_type_id = pbf.balance_type_id);

  begin
    open single_balance_feed (p_payroll_action_id,
                              p_assignment_id,
                              p_element_type_id);
    fetch single_balance_feed into p_assignment_action_id,
                                   p_balance_type_id,
                                   p_effective_start_date;

    if single_balance_feed%notfound then
      close single_balance_feed;
      v_single_feed := FALSE;
    else
      close single_balance_feed;
      v_single_feed := TRUE;
    end if;

    return v_single_feed;
  end single_feed_balance;

  ------------------------------------------------------------------------
  -- Checks to see if the Balance is fed by a single Element by calling
  -- single_balance_feed. If it is, then the Balance PTD function (in the
  -- hr_nzbal package) is called. Otherwise, the Result PTD function in this
  -- package is called.
  ------------------------------------------------------------------------
  function value_ptd
    (p_payroll_action_id in pay_payroll_actions.payroll_action_id%type,
     p_assignment_id     in pay_assignment_actions.assignment_id%type,
     p_element_type_id   in pay_element_types_f.element_type_id%type)
  return number is

  p_assignment_action_id  pay_assignment_actions.assignment_action_id%type;
  p_balance_type_id       pay_balance_types.balance_type_id%type;
  p_effective_start_date  pay_balance_feeds_f.effective_start_date%type;
  v_value_ptd             number := 0;

  begin
    if single_feed_balance (p_payroll_action_id,
                            p_assignment_id,
                            p_element_type_id,
                            p_assignment_action_id,
                            p_balance_type_id,
                            p_effective_start_date) then

      v_value_ptd := hr_nzbal.calc_asg_ptd
                     (p_assignment_action_id, p_balance_type_id,
                      p_effective_start_date, p_assignment_id);
    else
      v_value_ptd := result_ptd (p_payroll_action_id,
                                 p_assignment_id,
                                 p_element_type_id);
    end if;

    return v_value_ptd;
  end value_ptd;

  ------------------------------------------------------------------------
  -- Checks to see if the Balance is fed by a single Element by calling
  -- single_balance_feed. If it is, then the Balance YTD function (in the
  -- hr_nzbal package) is called. Otherwise, the Result YTD function in this
  -- package is called.
  ------------------------------------------------------------------------
  function value_ytd
    (p_payroll_action_id in pay_payroll_actions.payroll_action_id%type,
     p_assignment_id     in pay_assignment_actions.assignment_id%type,
     p_element_type_id   in pay_element_types_f.element_type_id%type)
  return number is

  p_assignment_action_id  pay_assignment_actions.assignment_action_id%type;
  p_balance_type_id       pay_balance_types.balance_type_id%type;
  p_effective_start_date  pay_balance_feeds_f.effective_start_date%type;
  v_value_ytd             number := 0;

  begin
    if single_feed_balance (p_payroll_action_id,
                            p_assignment_id,
                            p_element_type_id,
                            p_assignment_action_id,
                            p_balance_type_id,
                            p_effective_start_date) then

      v_value_ytd := hr_nzbal.calc_asg_ytd
                     (p_assignment_action_id, p_balance_type_id,
                      p_effective_start_date, p_assignment_id);
    else
      v_value_ytd := result_ytd (p_payroll_action_id,
                                 p_assignment_id,
                                 p_element_type_id);
    end if;

    return nvl( v_value_ytd,0);
  end value_ytd;
  ------------------------------------------------------------------------
end pay_nz_rec_pkg;

/
