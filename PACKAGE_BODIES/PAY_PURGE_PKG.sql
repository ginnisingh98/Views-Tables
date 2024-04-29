--------------------------------------------------------
--  DDL for Package Body PAY_PURGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PURGE_PKG" as
/* $Header: pypurge.pkb 120.15.12010000.1 2008/07/27 23:29:37 appldev ship $ */
/*
   +======================================================================+
   |                Copyright (c) 2000 Oracle Corporation                 |
   |                   Redwood Shores, California, USA                    |
   |                        All rights reserved.                          |
   +======================================================================+
   Package Header Name :    PAY_PURGE_PKG
   Package File Name   :    pypurge.pkb

   Description : Defines procedures for Purge functionality.

   Change List:
   ------------

   Name           Date         Version Bug     Text
   -------------- ------------ ------- ------- ----------------------------
   T. Habara      20-NOV-2006  115.30  5665425 Modified bal_exists. Added
                                               the constant boundary for the
                                               RR fetch limit.
                                               Checking the rr count with
                                               run result values.
   T. Habara      10-NOV-2006  115.29          Modified bal_exists to check
                                               the balance under a limited
                                               condition.
   T. Habara      16-OCT-2006  115.28          Modified open_asg_rep_cur to
                                               order by context id and value.
   T. Habara      24-MAY-2006  115.27          Modified csr_term_asg not to
                                               use max(end_date).
   T. Habara      17-MAY-2006  115.26  5231021 Modified csr_act in
                                               pypu1_validate_asg.
   T. Habara      03-APR-2006  115.25  5131274 Support of rollup date for
                                               terminated assignments.
                                               Added pypu1_validate_asg.
                                               Modified t_asgact_rec,
                                               get_act_info() and pypurgbv().
   T. Habara      28-MAR-2006  115.24          Modified csr_bal_exists to
                                               check the action status.
   T. Habara      24-MAR-2006  115.23          Added hint to csr_bal_exists.
   T. Habara      23-MAR-2006  115.22          Modified bal_exists.
   T. Habara      21-MAR-2006  115.21          Modified init_pact and
                                               bal_exists.
   T. Habara      17-MAR-2006  115.20  5089841 Added init_pact,bal_exists.
                                               Also added global variables
                                               t_bal_tab, g_purge_action_id
                                               and g_bal_exists.
                                               Modified open_asg_rep_cur to
                                               check actual tax unit id.
   T. Habara      21-DEC-2005  115.19  4893251 Modified cursor c1 in pypurcif.
   T. Habara      09-DEC-2005  115.18  4755511 Modified get_act_info.
   T. Habara      23-NOV-2005  115.17  4755511 Modified pypurgbv to avoid
                                               creating pay and asg action for
                                               itd balances.
                                               Added t_asgact_rec, g_asgact_rec
                                               and get_act_info().
   T. Habara      09-SEP-2005  115.16  4595640 Modified pypu2uacs to sync
                                               action seq on run balances.
   A. Logue       27-MAR-2004  115.15          Performance Repository fix
                                               to c1 in pypu2uacs().
   D. Saxby       24-FEB-2004  115.14          No longer force get_value call
                                               to get value from db item.
                                               Needed to allow access to
                                               Run Balances.
   D. Saxby       05-DEC-2002  115.13  2692195 Nocopy changes.
   A. Logue       14-NOV-2002  115.12  3288322 Index hint cursor in pypu2uacs
                                               for performance purposes.
   D. Saxby       02-AUG-2002  115.11          Alter to allow SOURCE_TEXT and
                                               SOURCE_ID context support.
   D. Saxby       27-MAY-2002  115.10          GSCC fix.
   D. Saxby       27-MAY-2002  115.9   2341428 Altered pypurgbv to detect
                                               condition where the insert of
                                               payroll action inserts no rows.
                                               Caused ora-08002 error, currval
                                               not defined. Note changes
                                               elsewhere (pydynsql.pkb) should
                                               prevent this situation occurring
                                               but this is a safety measure.
   RThirlby       02-MAY-2002  115.8   2348875 Altered != to <> for gscc
                                               standards.
   D. Saxby       25-APR-2002  115.7   2341428 Altered pypurgbv to detect
                                               condition where the insert of
                                               payroll action inserts no rows.
                                               Caused ora-08002 error, currval
                                               not defined. Note changes
                                               elsewhere (pydynsql.pkb) should
                                               prevent this situation occurring
                                               but this is a safety measure.
   D. Saxby       16-JAN-2002  115.6   2179667 Ensure that elements can be
                                               correctly created in NLS envs.
   D. Saxby       18-DEC-2001  115.5           GSCC standards fix.
   D. Saxby       14-NOV-2001  115.4           Added procedure pypurgbv.
   D. Saxby       06-AUG-2001  115.2           Added procedure pypurcif.
   D. Saxby       15-DEC-2000  115.1           Amended order by statements.
   D. Saxby       12-DEC-2000  115.0           Initial Version
   ========================================================================
*/

--
-- Global Types
--
type t_asgact_rec is record
  (assignment_action_id     number
  ,action_status            pay_assignment_actions.action_status%type
  ,action_sequence          number
  -- Payroll action information
  ,payroll_action_id        number
  ,action_type              pay_payroll_actions.action_type%type
  ,business_group_id        number
  ,action_population_status pay_payroll_actions.action_population_status%type
  ,ppa_action_status        pay_payroll_actions.action_status%type
  ,effective_date           date
  ,date_earned              date
  -- Assignment information
  ,assignment_id            number
  ,payroll_id               number
  ,time_period_id           number
  ,rollup_date              date  -- The rollup date for terminated assignment
  );

--
type t_payact_rec is record
  (payroll_action_id        number
  ,business_group_id        number
  ,legislation_code         per_business_groups.legislation_code%type
  ,effective_date           date
  ,asg_count                number -- number of assignments to process.
  );

type t_bal_tab is table of boolean index by binary_integer;

--
-- Global Variables
--
g_asgact_rec            t_asgact_rec; -- assignment action cache.
g_purge_action_rec      t_payact_rec; -- Purge payroll action cache.
g_bal_exists            t_bal_tab;    -- index by balance_type_id

/*
 * Represents the current number of rows in
 * the PAY_PURGE_ACTION_TYPES table.
 * Allows an important sanity check that the
 * correct rows are present - else there can be
 * serious consequences.
 */
PURGE_ACTION_TYPE_ROWS constant binary_integer := 20;

/*
 * Private procedure to get the payroll and assignment action
 * information.
 */
procedure get_act_info
  (p_assignment_action_id in            number
  ,p_asgact_rec              out nocopy t_asgact_rec
  )
is
  --
  l_asgact_rec      t_asgact_rec;
  --
  cursor csr_asgact
  is
   select
     act.action_status
    ,act.action_sequence
    -- Payroll action information
    ,act.payroll_action_id
    ,pac.action_type
    ,pac.business_group_id
    ,pac.action_population_status
    ,pac.action_status   ppa_action_status
    ,pac.effective_date
    ,pac.date_earned
    -- Assignment information
    ,act.assignment_id
    ,act.end_date rollup_date
   from
     pay_payroll_actions    pac
    ,pay_assignment_actions act
   where
          act.assignment_action_id = p_assignment_action_id
   and    pac.payroll_action_id    = act.payroll_action_id
   ;
  --
  cursor csr_asg(p_assignment_id  number
                ,p_effective_date date)
  is
   select
    -- Assignment information
     asg.payroll_id
    ,ptp.time_period_id
   from
     per_all_assignments_f  asg
    ,per_time_periods       ptp
   where
          asg.assignment_id        = p_assignment_id
   and    p_effective_date between
          asg.effective_start_date and asg.effective_end_date
   and    ptp.payroll_id           = asg.payroll_id
   and    p_effective_date between
          ptp.start_date and ptp.end_date;
  --
begin
  --
  -- Check if the assignment action cache exists.
  --
  if p_assignment_action_id = g_asgact_rec.assignment_action_id then
    --
    -- Cache already exists.
    --
    p_asgact_rec := g_asgact_rec;

  elsif p_assignment_action_id is not null then
    --
    -- Set the new assignment action id.
    --
    l_asgact_rec.assignment_action_id := p_assignment_action_id;

    --
    -- Retrieve the assignment action information.
    --
    open csr_asgact;
    fetch csr_asgact into l_asgact_rec.action_status
                         ,l_asgact_rec.action_sequence
                         -- Payroll action information
                         ,l_asgact_rec.payroll_action_id
                         ,l_asgact_rec.action_type
                         ,l_asgact_rec.business_group_id
                         ,l_asgact_rec.action_population_status
                         ,l_asgact_rec.ppa_action_status
                         ,l_asgact_rec.effective_date
                         ,l_asgact_rec.date_earned
                         -- Assignment information
                         ,l_asgact_rec.assignment_id
                         ,l_asgact_rec.rollup_date;
    close csr_asgact;
    --
    -- Retrieve the assignment information.
    --
    open csr_asg(l_asgact_rec.assignment_id
                ,nvl(l_asgact_rec.rollup_date, l_asgact_rec.effective_date));
    fetch csr_asg into l_asgact_rec.payroll_id
                      ,l_asgact_rec.time_period_id;
    close csr_asg;
    --
    -- Set the global cache and out variable.
    --
    g_asgact_rec := l_asgact_rec;
    p_asgact_rec := l_asgact_rec;

  end if;

end get_act_info;

/*
 * This procedure initializes the cached payroll action information.
 *
 */
procedure init_pact
(
   p_purge_action_id   in number
)
is
  l_proc        varchar2(80):='pay_purge_pkg.init_pact';
  cursor csr_ppa is
    select
      ppa.action_type
     ,ppa.business_group_id
     ,pbg.legislation_code
     ,ppa.effective_date
     ,ppa.balance_set_id
    from
      pay_payroll_actions      ppa
     ,per_business_groups_perf pbg
    where
        ppa.payroll_action_id = p_purge_action_id
    and pbg.business_group_id = ppa.business_group_id
    ;
  --
  l_ppa_rec csr_ppa%rowtype;

  cursor csr_balset(p_bal_set_id number)
  is
    select
      distinct pdb.balance_type_id
    from
      pay_balance_set_members pbsm
     ,pay_defined_balances    pdb
    where
        pbsm.balance_set_id = p_bal_set_id
    and pdb.defined_balance_id = pbsm.defined_balance_id
    order by pdb.balance_type_id
    ;
begin
  hr_utility.set_location('Entering: '||l_proc, 10);

  if p_purge_action_id is not null then
    --
    -- Check to see if this is a purge action just in case.
    --
    open csr_ppa;
    fetch csr_ppa into l_ppa_rec;
    close csr_ppa;
    --
    hr_utility.set_location(l_proc, 15);
    pay_core_utils.assert_condition
      ('pay_purge_pkg.init_pact:1', nvl(l_ppa_rec.action_type,'null') = 'Z');
  end if;

  --
  -- Reset the action cache.
  --
  g_purge_action_rec.payroll_action_id := p_purge_action_id;
  g_purge_action_rec.business_group_id := l_ppa_rec.business_group_id;
  g_purge_action_rec.legislation_code  := l_ppa_rec.legislation_code;
  g_purge_action_rec.effective_date    := l_ppa_rec.effective_date;

  hr_utility.trace(' Payroll Action ID = '||p_purge_action_id);
  hr_utility.trace(' Business Group ID = '||l_ppa_rec.business_group_id);
  hr_utility.trace(' Legislation Code  = '||l_ppa_rec.legislation_code);
  hr_utility.trace(' Effective Date    = '||l_ppa_rec.effective_date);

  --
  -- Retrieve the number of assignments to process.
  --
  select count(assignment_action_id)
  into g_purge_action_rec.asg_count
  from pay_assignment_actions
  where payroll_action_id = p_purge_action_id
  and action_status <> 'C';

  hr_utility.trace(' Asg Count         = '||g_purge_action_rec.asg_count);

  --
  -- Delete the balance cache.
  --
  g_bal_exists.delete;

  --
  -- We can assume those balances in the specified balance set would
  -- have balance values.
  --
  if l_ppa_rec.balance_set_id is not null then
    for l_bal in csr_balset(l_ppa_rec.balance_set_id) loop
      --
      g_bal_exists(l_bal.balance_type_id) := true;
      --
    end loop;
  end if;

  hr_utility.set_location('Leaving: '||l_proc, 50);
end init_pact;

/*
 * This function checks to see if the specified balance could have a
 * value to rollup for the assignments to be processed in Purge.
 * This is used in the Purge Preparation Phase1 to ensure if the
 * balance should be added to the rollup balance list for the
 * payroll action.
 *
 * NOTE: The importance of this function is to check the possibility
 *       of the balance existence in any dimensions especially
 *       _asg_itd. Since it is difficult to prove no balance exists
 *       by checking run balances, we need to check the run results
 *       at the moment.
 *
 */
function bal_exists
(
   p_purge_action_id   in number, -- Purge Payroll Action ID
   p_balance_type_id   in number
) return varchar2
is
  l_dummy          number;
  l_bal_exists     boolean;
  l_rr_fetch_limit number;
  l_rr_count       number;
  --
  -- Run Result Fetch Limit.
  --
  c_limit_min      constant number:= 100;
  c_limit_max      constant number:= 5000;
  --
  cursor csr_check_rr_count
           (p_baltypid     number
           ,p_purge_date   date
           ,p_bg_id        number
           ,p_leg_code     varchar2
           ,p_limit        number
           )
  is
    --
    -- This sql checks whether the number of run result values for a given
    -- balance type is less than the specific limit number.
    --
    -- NOTE: This cursor has to finish as soon as the number of fetch
    --       exceeds the limit.
    --
    select
      /*+ ordered
          use_nl (piv prrv) */
       count(1)
    from
      pay_balance_feeds_f    pbf
     ,pay_input_values_f     piv
     ,pay_run_result_values  prrv
    where
        pbf.balance_type_id = p_baltypid
    and pbf.effective_start_date <= p_purge_date
    and piv.input_value_id = pbf.input_value_id
    and pbf.effective_start_date between piv.effective_start_date
                                     and piv.effective_end_date
    and nvl(piv.business_group_id, p_bg_id) = p_bg_id
    and nvl(piv.legislation_code, p_leg_code) = p_leg_code
    and prrv.input_value_id = piv.input_value_id
    and rownum < p_limit+2
    ;

  --
  cursor csr_bal_exists
           (p_baltypid     number
           ,p_purge_pactid number
           ,p_purge_date   date
           ,p_bg_id        number
           ,p_leg_code     varchar2)
  is
    --
    -- This sql searches for any run results created for the specified
    -- balance type before the purge date.
    -- NOTE: The Purge assignment actions must be already prepared.
    --
    select
      /*+ ordered
          index (prr PAY_RUN_RESULTS_N1)
          index (purge_paa PAY_ASSIGNMENT_ACTIONS_N51)
          use_nl (piv prr paa ppa purge_paa prrv) */
      1
    from
      pay_balance_feeds_f    pbf
     ,pay_input_values_f     piv
     ,pay_run_results        prr
     ,pay_assignment_actions paa
     ,pay_payroll_actions    ppa
     ,pay_assignment_actions purge_paa
     ,pay_run_result_values  prrv
    where
        pbf.balance_type_id = p_baltypid
    and pbf.effective_start_date <= p_purge_date
    and piv.input_value_id = pbf.input_value_id
    and pbf.effective_start_date between piv.effective_start_date
                                     and piv.effective_end_date
    and nvl(piv.business_group_id, p_bg_id) = p_bg_id
    and nvl(piv.legislation_code, p_leg_code) = p_leg_code
    and prr.element_type_id = piv.element_type_id
    and paa.assignment_action_id = prr.assignment_action_id
    and ppa.payroll_action_id = paa.payroll_action_id
    and ppa.business_group_id+0 = p_bg_id
    and ppa.effective_date <= p_purge_date
    and ppa.effective_date between pbf.effective_start_date
                               and pbf.effective_end_date
    and purge_paa.payroll_action_id = p_purge_pactid
    and purge_paa.assignment_id = paa.assignment_id
        -- not including completed purge assignment actions.
    and purge_paa.action_status <> 'C'
    and prrv.run_result_id = prr.run_result_id
    and prrv.input_value_id = piv.input_value_id
    and prrv.result_value is not null
    ;

begin
  --
  -- Check if the payroll action id has been initialized.
  --
  if g_purge_action_rec.payroll_action_id = p_purge_action_id then
    null;
  elsif p_purge_action_id is not null then
    init_pact(p_purge_action_id);
  else
    return null;
  end if;

  --
  -- Check if the balance has already been in cache.
  --
  if g_bal_exists.exists(p_balance_type_id) then
    --
    -- Cache found.
    --
    l_bal_exists := g_bal_exists(p_balance_type_id);
  else
    --
    -- The balance check should proceed only under a limited condition.
    -- By default, assume the balance exists.
    --
    l_bal_exists := true;

    --
    -- Before going further for checking the balance with run results,
    -- we have to ensure that this approach can be well under control.
    -- This approach is effective only when the number of run results
    -- are within a reasonable amount, hence we need to check the count
    -- beforehand.
    --
    -- Setting the limit to the number of assignments within a
    -- certain range.
    --
    l_rr_fetch_limit := least(greatest(g_purge_action_rec.asg_count
                                      , c_limit_min), c_limit_max);

    --
    -- Check to see if the number of run results exceeds the limit.
    --
    open csr_check_rr_count
           (p_balance_type_id
           ,g_purge_action_rec.effective_date
           ,g_purge_action_rec.business_group_id
           ,g_purge_action_rec.legislation_code
           ,l_rr_fetch_limit);
    fetch csr_check_rr_count into l_rr_count;
    close csr_check_rr_count;

    if l_rr_count = 0 then
      --
      -- No run result exists for this balance type.
      --
      l_bal_exists := false;

    elsif l_rr_count <= l_rr_fetch_limit then
      --
      -- Check to see if any run result exists for this balance.
      --
      open csr_bal_exists
             (p_balance_type_id
             ,p_purge_action_id
             ,g_purge_action_rec.effective_date
             ,g_purge_action_rec.business_group_id
             ,g_purge_action_rec.legislation_code);
      fetch csr_bal_exists into l_dummy;
      if csr_bal_exists%found then
        l_bal_exists := true;
      else
        l_bal_exists := false;
      end if;
      close csr_bal_exists;
    end if;

    --
    -- Set this result to the cache.
    --
    g_bal_exists(p_balance_type_id) := l_bal_exists;

  end if;

  if l_bal_exists then
    return 'Y';
  else
    return 'N';
  end if;

end bal_exists;
--
/*
 * This procedure validates the assignment for the specified
 * assignment action id.
 *
 * If the assignment is terminated on the purge date, look for
 * a possible rollup date for this assignment and set it on
 * the assignment action.
 *
 */
procedure pypu1_validate_asg
(
   p_assignment_action_id   in number
) is
  --
  l_exists         number;
  l_rollup_date    date;
  --
  cursor csr_act
  is
   select
     ppa.effective_date
    ,paa.assignment_id
    ,paa.end_date
   from
     pay_assignment_actions paa
    ,pay_payroll_actions    ppa
   where
       paa.assignment_action_id = p_assignment_action_id
   and ppa.payroll_action_id    = paa.payroll_action_id
   ;
  --
  l_act_rec csr_act%rowtype;
  --
  cursor csr_active_asg
           (p_assignment_id  number
           ,p_effective_date date)
  is
   select
     1
   from
     per_all_assignments_f  asg
    ,per_time_periods       ptp
   where
       asg.assignment_id        = p_assignment_id
   and p_effective_date   between asg.effective_start_date
                              and asg.effective_end_date
   and ptp.payroll_id           = asg.payroll_id
   and p_effective_date   between ptp.start_date
                              and ptp.end_date;
  --
  cursor csr_term_asg
           (p_assignment_id  number
           ,p_effective_date date)
  is
   --
   -- The asg end date is in the period.
   --
   --                            Effective Date
   -- Asg |------------------>         |
   -- Prd   |----->|----->|----->
   --
   -- Note: Max(end date) should not be used here since it will return
   --       null when no rows found.
   --
   select
     asg.effective_end_date end_date
   from
     per_all_assignments_f  asg
    ,per_time_periods       ptp
   where
       asg.assignment_id        = p_assignment_id
   and asg.effective_end_date <= p_effective_date
   and ptp.payroll_id           = asg.payroll_id
   and asg.effective_end_date between ptp.start_date
                                  and ptp.end_date
   UNION ALL
   --
   -- The time period ends before the asg end date.
   --                            Effective Date
   -- Asg |------------------>         |
   -- Prd   |----->|----->
   --
   select
     ptp.end_date end_date
   from
     per_all_assignments_f  asg
    ,per_time_periods       ptp
   where
       asg.assignment_id        = p_assignment_id
   and asg.effective_start_date <= p_effective_date
   and ptp.payroll_id           = asg.payroll_id
   and ptp.end_date             <= p_effective_date
   and ptp.end_date between asg.effective_start_date
                        and asg.effective_end_date
   order by 1 desc;
  --
  l_null_asgact_rec      t_asgact_rec;
  --
begin
  --
  -- Obtain the action info.
  --
  open csr_act;
  fetch csr_act into l_act_rec;
  close csr_act;

  --
  -- Check to see if the assignment is on a payroll period.
  --
  open csr_active_asg(l_act_rec.assignment_id, l_act_rec.effective_date);
  fetch csr_active_asg into l_exists;
  if csr_active_asg%found then
    close csr_active_asg;
    --
    -- If the end date was set to a different date, this has to be corrected.
    --
    if nvl(l_act_rec.end_date, l_act_rec.effective_date)
        <> l_act_rec.effective_date then
      --
      update pay_assignment_actions
      set    end_date = null
      where  assignment_action_id = p_assignment_action_id;
    end if;
  else
    close csr_active_asg;
    --
    -- Obtain the rollup date for this assignment.
    --
    open csr_term_asg(l_act_rec.assignment_id, l_act_rec.effective_date);
    fetch csr_term_asg into l_rollup_date;
    if csr_term_asg%found and
      (nvl(l_act_rec.end_date, l_act_rec.effective_date) <> l_rollup_date)
    then
      --
      update pay_assignment_actions
      set    end_date = l_rollup_date
      where  assignment_action_id = p_assignment_action_id;
    end if;
    close csr_term_asg;
  end if;
  --
  -- Reset the global asg act cache just in case.
  --
  g_asgact_rec := l_null_asgact_rec;
  --

end pypu1_validate_asg;

procedure validate
(
   p_balance_set_id     in number default null,
   p_assignment_set_id  in number default null,
   p_business_group_id  in number,
   p_reporting_date     in date,
   p_purge_date         in date
) is
   l_types_count number;
begin
   /*
    * Further validation should appear below this point.
    */

   return;
end validate;

/*
 * This procedure is designed to run various 'sanity checks'
 * when purge phase two is about to be run.
 */
procedure phase_two_checks
(
   p_payroll_action_id in number
) is
   l_pat_count binary_integer;
begin

   /*
    * Perform quick check that we have the correct
    * number of pay_purge_action_type rows.
    * Serious consequences can occur if there are not
    * the correct number of rows.
    */
   select count(*)
   into   l_pat_count
   from   pay_purge_action_types pat;

   ff_utils.assert((PURGE_ACTION_TYPE_ROWS = l_pat_count),
                   'purge_sanity_checks:1');

end phase_two_checks;

procedure open_asg_rep_cur
(
   p_ctx_cursor    in out nocopy ctx_cur_t,
   p_assignment_id in     number,
   p_purge_date    in     date
) is
begin
   open p_ctx_cursor for
   select distinct
          ffc.context_id,
          ffc.context_name,
          rep.jurisdiction_code
   from   pay_us_asg_reporting rep,
          ff_contexts          ffc
   where  rep.assignment_id = p_assignment_id
   and    ffc.context_name  = 'JURISDICTION_CODE'
   and    rep.jurisdiction_code is not null
   union all
   --
   -- Check the assignment action to restrict the contexts
   -- with the purge date. Bug 5089841.
   --
   select distinct
          ffc.context_id,
          ffc.context_name,
          to_char(paa.tax_unit_id)
   from   ff_contexts            ffc,
          pay_assignment_actions paa,
          pay_payroll_actions    ppa
   where  ffc.context_name  = 'TAX_UNIT_ID'
   and    paa.assignment_id = p_assignment_id
   and    paa.tax_unit_id is not null
   and    ppa.payroll_action_id = paa.payroll_action_id
   and    ppa.effective_date <= p_purge_date
   order by 1, 3;

end open_asg_rep_cur;

procedure open_act_ctx_cur
(
   p_ctx_cursor    in out nocopy ctx_cur_t,
   p_assignment_id in     number,
   p_purge_date    in     date
) is
begin
   open p_ctx_cursor for
   select ffc.context_id,
          ffc.context_name,
          to_char(act.tax_unit_id) context_value
   from   ff_contexts            ffc,
          pay_assignment_actions act,
          pay_payroll_actions    pac
   where  act.assignment_id        = p_assignment_id
   and    pac.payroll_action_id    = act.payroll_action_id
   and    pac.effective_date      <= p_purge_date
   and    act.tax_unit_id         is not null
   and    ffc.context_name         = 'TAX_UNIT_ID'
   union
   select ctx.context_id,
          ffc.context_name,
          ctx.context_value
   from   pay_action_contexts    ctx,
          ff_contexts            ffc,
          pay_assignment_actions act,
          pay_payroll_actions    pac
   where  ctx.assignment_id        = p_assignment_id
   and    ffc.context_id           = ctx.context_id
   and    ffc.context_name in ('JURISDICTION_CODE',
                               'ORIGINAL_ENTRY_ID',
                               'ELEMENT_ENTRY_ID',
                               'SOURCE_ID',
                               'SOURCE_TEXT')
   and    act.assignment_action_id = ctx.assignment_action_id
   and    pac.payroll_action_id    = act.payroll_action_id
   and    pac.effective_date      <= p_purge_date
   order by 1, 3;

end open_act_ctx_cur;

procedure open_ctx_cur
(
   p_ctx_cursor    in out nocopy ctx_cur_t,
   p_assignment_id in     number,
   p_purge_date    in     date,
   p_select_type   in     varchar2
) is
begin
   -- Open the appropriate cursor, depending on
   -- the string passed in.
   if(p_select_type = 'ASG_REPORTING') then
      open_asg_rep_cur(p_ctx_cursor, p_assignment_id, p_purge_date);
   elsif(p_select_type = 'ACT_CONTEXTS') then
      open_act_ctx_cur(p_ctx_cursor, p_assignment_id, p_purge_date);
   else
      ff_utils.assert(false, 'open_ctx_cur:1');
   end if;
end open_ctx_cur;

procedure pypu2uacs
(
   p_batch_id        in number,
   p_action_sequence in number      -- of current Purge action.
) is

   /*
    * Will return the balance initialization actions
    * in reverse time order.
    */
   cursor c1 is
   select /*+ INDEX(act PAY_ASSIGNMENT_ACTIONS_N51) */
          distinct
          act.rowid
         ,act.assignment_action_id
         ,act.action_sequence
   from   pay_assignment_actions act,
          pay_balance_batch_lines bbl
   where  bbl.batch_id          = p_batch_id
   and    act.payroll_action_id = bbl.payroll_action_id
   and    act.assignment_id     = bbl.assignment_id
   order by act.action_sequence desc;

   l_action_sequence number;
   l_update_count    number := 0;

begin
   -- The action_sequence must NOT be null.
   ff_utils.assert((p_action_sequence is not null), 'pypu2uacs:1');

   l_action_sequence := p_action_sequence;

   for c1rec in c1 loop
      l_action_sequence := l_action_sequence - 1;

      update pay_assignment_actions act
      set    act.action_sequence = l_action_sequence
      where  act.rowid           = c1rec.rowid;

      --
      -- Bug 4595640.
      -- Update action sequence on run balances.
      --
      update pay_run_balances prb
      set    prb.action_sequence = l_action_sequence
      where  prb.assignment_action_id = c1rec.assignment_action_id;

      l_update_count := l_update_count + 1;

   end loop;

   -- Would expect some actions to have been updated.
   ff_utils.assert((l_update_count > 0), 'pypu2uacs:2');
end pypu2uacs;

procedure pypurgbv
(
   p_defined_balance_id   in  number,
   p_assignment_action_id in  number,
   p_balance_value        out nocopy number,
   p_nonzero_flag         out nocopy binary_integer
) is
   l_new_assactid        number;
   l_new_payactid        number;
   l_asgact_rec          t_asgact_rec; -- assignment action info.
   l_period_type         pay_balance_dimensions.period_type%type;
   l_creating_new_action boolean;
   --
   -- Cursor to check the period type
   --
   cursor csr_period_type
   is
   select
     pbd.period_type
   from
     pay_defined_balances   pdb
    ,pay_balance_dimensions pbd
   where
       pdb.defined_balance_id = p_defined_balance_id
   and pbd.balance_dimension_id = pdb.balance_dimension_id
   ;

begin

   p_nonzero_flag := 0;
   p_balance_value := 0;

   --
   -- Get the assignment action information.
   --
   get_act_info
     (p_assignment_action_id => p_assignment_action_id
     ,p_asgact_rec           => l_asgact_rec
     );

   --
   -- Check to see if the assignment is on a payroll on the date.
   --
   -- Note: This check is now performed on the rollup date of this
   --       assignment. (Bug 5131274)
   --
   if l_asgact_rec.payroll_id is null then
     --
     -- Setting the balance value to 0 and exit.
     --
     p_nonzero_flag := 0;
     p_balance_value := 0;
     return;
   end if;

   --
   -- Bug 4755511.
   -- Temporary solution to avoid the majority of pay/asg action creation.
   -- We don't have to create extra payroll and assignment actions
   -- for certain type(s) of dimensions.
   --
   open csr_period_type;
   fetch csr_period_type into l_period_type;
   close csr_period_type;

   if l_period_type = 'LIFETIME' and
      l_asgact_rec.effective_date
       = nvl(l_asgact_rec.rollup_date, l_asgact_rec.effective_date) then
      --
      -- Get balance value with the processing purge action.
      --
      p_balance_value := pay_balance_pkg.get_value
                           (p_defined_balance_id
                           ,p_assignment_action_id);
   else

      /*
       * Before we call the get_value function, we insert
       * a temporary assignment and payroll action.
       * This is done to ensure that values of time_period_id
       * and payroll_id are set on the payroll action associated
       * with the assignment action whoes value is passed to
       * the get_value call.
       * In addition, the assignment action must have the same
       * action_sequence value as that for the current purge
       * action.
       * As these are somewhat unique requirements, decided
       * that would be better to do this here, rather than
       * further complicate the balance code.
       * We'd love to just update the purge payroll action
       * to set the time_period_id, but expect this to be
       * a major locking issue.
       */

      savepoint get_value;

      --
      -- Set the indicator of the savepoint.
      --
      l_creating_new_action := true;

      -- Obtain the payroll_action_id.
      select pay_payroll_actions_s.nextval
      into   l_new_payactid
      from   dual;

      insert into pay_payroll_actions (
             payroll_action_id,
             action_type,
             business_group_id,
             payroll_id,
             action_population_status,
             action_status,
             effective_date,
             date_earned,
             time_period_id,
             object_version_number)
      values(l_new_payactid,
             l_asgact_rec.action_type,
             l_asgact_rec.business_group_id,
             l_asgact_rec.payroll_id,
             l_asgact_rec.action_population_status,
             l_asgact_rec.ppa_action_status,
             nvl(l_asgact_rec.rollup_date, l_asgact_rec.effective_date),
             nvl(l_asgact_rec.rollup_date, l_asgact_rec.date_earned),
             l_asgact_rec.time_period_id,
             1);

      -- Obtain the assignment_action_id.
      select pay_assignment_actions_s.nextval
      into   l_new_assactid
      from   dual;

      -- Action sequence must match value for purge.
      insert into pay_assignment_actions (
             assignment_action_id,
             assignment_id,
             payroll_action_id,
             action_status,
             action_sequence,
             object_version_number)
      values(l_new_assactid,
             l_asgact_rec.assignment_id,
             l_new_payactid,
             l_asgact_rec.action_status,
             l_asgact_rec.action_sequence,
             1);

      /* do not bother looking for a latest balance */
      p_balance_value := pay_balance_pkg.get_value(p_defined_balance_id,
                                                   l_new_assactid);

      rollback to get_value;

   end if;

   if(p_balance_value <> 0) then
      p_nonzero_flag := 1;
   end if;


exception
   -- A no data found should only occur if the assignment
   -- is terminated.  In this case, their balance is by
   -- definition zero and this is returned immediately.
   when no_data_found then
      p_balance_value := 0;
      if l_creating_new_action then
        rollback to get_value;
      end if;
end pypurgbv;

procedure pypurvbr
(
   p_assignment_action_id in number
) is
   cursor c1 is
   select rub.defined_balance_id,
          rub.jurisdiction_code,
          rub.original_entry_id,
          rub.tax_unit_id,
          rub.value
   from   pay_purge_rollup_balances rub
   where  rub.assignment_action_id = p_assignment_action_id;

   l_balance_name varchar2(200);
   l_value        number;
begin
   for c1rec in c1 loop
      -- Set context values if required.
      if(c1rec.jurisdiction_code is not null) then
         pay_balance_pkg.set_context('JURISDICTION_CODE',
                                     c1rec.jurisdiction_code);
      end if;

      if(c1rec.original_entry_id is not null) then
         pay_balance_pkg.set_context('ORIGINAL_ENTRY_ID',
                                     c1rec.original_entry_id);
         pay_balance_pkg.set_context('ELEMENT_ENTRY_ID',
                                     c1rec.original_entry_id);
      end if;

      if(c1rec.tax_unit_id is not null) then
         pay_balance_pkg.set_context('TAX_UNIT_ID', c1rec.tax_unit_id);
      end if;

      -- Obtain the value of the balance - directly from results.
      l_value := pay_balance_pkg.get_value(c1rec.defined_balance_id,
                                           p_assignment_action_id,
                                           true);

      -- Compare the expected and actual values.
      if(l_value <> c1rec.value) then
         -- Failure : obtain information about balance
         -- for error reporting.
         select upper(replace(pbt.balance_name, ' ', '_')) ||
                pbd.database_item_suffix
         into   l_balance_name
         from   pay_balance_types      pbt,
                pay_balance_dimensions pbd,
                pay_defined_balances   pdb
         where  pdb.defined_balance_id   = c1rec.defined_balance_id
         and    pbt.balance_type_id      = pdb.balance_type_id
         and    pbd.balance_dimension_id = pdb.balance_dimension_id;

         hr_utility.set_message(801, 'PAY_289018_PUR_BAL_VAL_FAIL');
         hr_utility.set_message_token('BALANCE', l_balance_name);
         hr_utility.set_message_token('EXPECTED', c1rec.value);
         hr_utility.set_message_token('ACTUAL', l_value);
         hr_utility.raise_error;
      end if;
   end loop;
end pypurvbr;

procedure pypurcif
(
   p_balance_set_id    in number,
   p_business_group_id in number,
   p_legislation_code  in varchar2
) is

   c_sot constant date := to_date('0001/01/01', 'YYYY/MM/DD');
   c_eot constant date := to_date('4712/12/31', 'YYYY/MM/DD');

   -- Number of input values (not including Jurisdiction
   -- and Pay Value that will be created when an element
   -- is created.
   c_iv_limit constant number := 15; -- which includes Jurdisdiction.

   l_iv_count number;
   l_et_id    pay_element_types_f.element_type_id%type;
   l_iv_id    pay_input_values_f.input_value_id%type;
   l_el_id    pay_element_links_f.element_link_id%type;
   l_et_name  pay_element_types_f.element_name%type;
   l_iv_name  pay_input_values_f.name%type;
   l_bg_name  per_business_groups.name%type;
   l_et_count number := 0;

   type et_r is record
   (
      iv_count      number,
      currency_code pay_element_types.input_currency_code%type,
      jur_lev       pay_balance_types.jurisdiction_level%type
   );

   -- The table is indexed by element_link_id.
   type et_t is table of et_r index by binary_integer;
   l_et_tab et_t;

   -- Return distinct set of balance types that might
   -- require rolling up by purge.
   --
   -- Bug 4893251. Include the supported dimensions only.
   cursor c1 is
   select pbt.balance_type_id,
          pbt.balance_name,
          pbt.balance_uom,
          pbt.currency_code,
          nvl(pbt.jurisdiction_level, 0) jurisdiction_level
   from   pay_balance_set_members bsm,
          pay_defined_balances    pdb,
          pay_balance_types       pbt,
          pay_balance_dimensions  pbd
   where  bsm.balance_set_id       = p_balance_set_id
   and    pdb.defined_balance_id   = bsm.defined_balance_id
   and    pbt.balance_type_id      = pdb.balance_type_id
   and    pbd.balance_dimension_id = pdb.balance_dimension_id
   and    pay_balance_upload.dim_is_supported
            (p_legislation_code, pbd.dimension_name) = 'Y'
   union  /* do not return duplicates */
   select pbt.balance_type_id,
          pbt.balance_name,
          pbt.balance_uom,
          pbt.currency_code,
          nvl(pbt.jurisdiction_level, 0) jurisdiction_level
   from   ff_fdi_usages_f        fdu,
          ff_formulas_f          fff,
          ff_database_items      fdi,
          ff_user_entities       fue,
          pay_defined_balances   pdb,
          pay_balance_types      pbt,
          pay_balance_dimensions pbd
   where  ((fff.business_group_id is null and fff.legislation_code is null)
         or (fff.business_group_id is null
             and fff.legislation_code = p_legislation_code)
         or (fff.legislation_code is null
            and fff.business_group_id = p_business_group_id))
   and    fdu.formula_id            = fff.formula_id
   and    fdu.usage                 = 'D'
   and    fdi.user_name = fdu.item_name
   and    fue.user_entity_id = fdi.user_entity_id
   and    ((fue.business_group_id is null and fue.legislation_code is null)
         or (fue.business_group_id is null
             and fue.legislation_code = p_legislation_code)
         or (fue.legislation_code is null
            and fue.business_group_id = p_business_group_id))
   and    fue.creator_type          = 'B'
   and    pdb.defined_balance_id    = fue.creator_id
   and    pbd.balance_dimension_id  = pdb.balance_dimension_id
   and    pbd.dimension_level       = 'ASG'
   and    pbd.period_type           = 'LIFETIME'
   and    pay_balance_upload.dim_is_supported
            (p_legislation_code, pbd.dimension_name) = 'Y'
   and    pbt.balance_type_id       = pdb.balance_type_id
   order by 1; -- balance_type_id.

   -- Creates an element type and associated element link.
   -- The element link value is returned for further
   -- processing.
   -- The name of the element ends up of the form:
   -- 'Initial_Value_Element_<uniqueid>_<currency>'.
   function create_et_el
   (
      p_currency_code in varchar2,
      p_bg_name       in varchar2,
      p_bg_id         in number,
      p_et_count      in number
   ) return number is
      l_et_name pay_element_types_f.element_name%type;
      l_et_id   pay_element_types_f.element_type_id%type;
      l_el_id   pay_element_links_f.element_link_id%type;
      l_ptr     hr_lookups.meaning%type;
   begin

      -- We use the element type sequence to obtain a unique
      -- value that becomes part of the name.  This avoids
      -- problems if someone ever deletes any of the existing
      -- initial balance feeds and re-runs.
      -- Also, obtain the meaning for appropriate post termination
      -- rule to be used later.  The procedure used to create the
      -- element requires meaning to be passed in, but we mustn't
      -- hard code it.
      select pay_element_types_s.nextval,
             hrl.meaning
      into   l_et_id,
             l_ptr
      from   hr_lookups hrl
      where  hrl.lookup_type = 'TERMINATION_RULE'
      and    hrl.lookup_code = 'F';

      l_et_name := 'Initial_Value_Element_' ||
                   l_et_id || '_' || p_et_count || '_' || p_currency_code;

      l_et_id := pay_db_pay_setup.create_element (
            p_element_name          => l_et_name,
            p_effective_start_date  => c_sot,
            p_effective_end_date    => c_eot,
            p_classification_name   => 'Balance Initialization',
            p_input_currency_code   => p_currency_code,
            p_output_currency_code  => p_currency_code,
            p_processing_type       => 'N',
            p_adjustment_only_flag  => 'Y',
            p_business_group_name   => p_bg_name,
            p_post_termination_rule => l_ptr);

      hr_utility.trace('l_et_name : ' || l_et_name);

      -- The element_information1 needs to be set to 'B'
      -- to allow rollup of subject balances.  We have
      -- no 'official' way and so so use direct update.
      update pay_element_types_f pet
      set    pet.element_information1 = 'B'
      where  pet.element_type_id = l_et_id;

      -- We need to create an appropriate element link
      -- for this type.
      -- Don't need to return the element link id though.
      l_el_id := pay_db_pay_setup.create_element_link (
            p_element_name          => l_et_name,
            p_link_to_all_pyrlls_fl => 'Y',
            p_effective_start_date  => c_sot,
            p_effective_end_date    => c_eot,
            p_business_group_name   => p_bg_name);

      return(l_el_id);

   end create_et_el;

   -- Convenience routine that creates an input value,
   -- link input value and, if necessary, a balance feed.
   function cre_iv_bf
   (
      p_bg_name in varchar2,
      p_el_id   in number,
      p_iv_name in varchar2,
      p_iv_uom  in varchar2,
      p_seq     in number,
      p_bt_id   in number    default null
   ) return number is
      l_et_name pay_element_types_f.element_name%type;
      l_bg_id   per_business_groups.business_group_id%type;
      l_et_id   pay_element_types_f.element_type_id%type;

   begin

      hr_utility.set_location ('cre_iv_bf', 10);

      -- Grab some details for calls.
      select pet.element_name,
             pet.element_type_id,
             pet.business_group_id
      into   l_et_name,
             l_et_id,
             l_bg_id
      from   pay_element_links_f pel,
             pay_element_types_f pet
      where  pel.element_link_id = p_el_id
      and    pel.effective_start_date = c_sot
      and    pel.effective_end_date   = c_eot
      and    pet.element_type_id      = pel.element_type_id
      and    pet.effective_start_date = c_sot
      and    pet.effective_end_date   = c_eot;

      hr_utility.set_location ('cre_iv_bf', 20);

      l_iv_id := pay_db_pay_setup.create_input_value (
            p_element_name         => l_et_name,
            p_name                 => p_iv_name,
            p_uom_code             => p_iv_uom,
            p_business_group_name  => p_bg_name,
            p_effective_start_date => c_sot,
            p_effective_end_date   => c_eot,
            p_display_sequence     => p_seq);

      hr_utility.set_location ('cre_iv_bf', 30);

      hr_input_values.create_link_input_value(
            p_insert_type           => 'INSERT_INPUT_VALUE',
            p_element_link_id       => p_el_id,
            p_input_value_id        => l_iv_id,
            p_input_value_name      => p_iv_name,
            p_costable_type         => NULL,
            p_validation_start_date => c_sot,
            p_validation_end_date   => c_eot,
            p_default_value         => NULL,
            p_max_value             => NULL,
            p_min_value             => NULL,
            p_warning_or_error_flag => NULL,
            p_hot_default_flag      => NULL,
            p_legislation_code      => NULL,
            p_pay_value_name        => NULL,
            p_element_type_id       => l_et_id);

      hr_utility.set_location ('cre_iv_bf', 40);

      if(p_bt_id is not null) then
         -- We must be creating a balance feed as well

         hr_utility.set_location ('cre_iv_bf', 50);

         hr_balances.ins_balance_feed(
               p_option                      => 'INS_MANUAL_FEED',
               p_input_value_id              => l_iv_id,
               p_element_type_id             => l_et_id,
               p_primary_classification_id   => NULL,
               p_sub_classification_id       => NULL,
               p_sub_classification_rule_id  => NULL,
               p_balance_type_id             => p_bt_id,
               p_scale                       => '1',
               p_session_date                => c_sot,
               p_business_group              => l_bg_id,
               p_legislation_code            => NULL,
               p_mode                        => 'USER');
      end if;

      return(l_iv_id);

   end cre_iv_bf;

begin

   hr_utility.set_location('pay_purge_pkg.pypurcif', 10);

   select pbg.name
   into   l_bg_name
   from   per_business_groups pbg
   where  pbg.business_group_id = p_business_group_id;

   -- Return all the balance types that might need to have
   -- balances rolled up for them by purge.
   for c1rec in c1 loop

      -- Find out if the balance already has an
      -- existing initial balance feed.
      declare
         l_dummy number;
         l_found boolean := false;
         l       number;
      begin
         -- Note the date track restrictions that insist that
         -- the types, feeds and input values all exist
         -- across the whole of time.
         select 1
         into   l_dummy
         from   pay_balance_feeds_f         pbf,
                pay_input_values_f          piv,
                pay_element_types_f         pet,
                pay_element_classifications pec
         where  pbf.balance_type_id             = c1rec.balance_type_id
         and    piv.input_value_id              = pbf.input_value_id
         and    pet.element_type_id             = piv.element_type_id
         and    pec.classification_id           = pet.classification_id
         and    pec.balance_initialization_flag = 'Y'
         and    pbf.effective_start_date        = c_sot
         and    pbf.effective_end_date          = c_eot
         and    piv.effective_start_date        = c_sot
         and    piv.effective_end_date          = c_eot
         and    piv.effective_start_date        = c_sot
         and    piv.effective_end_date          = c_eot;

      exception when no_data_found then

         -- There is no initial balance feed, we therefore
         -- look to create an appropriate feed.

         -- Begin by searching for an element type that
         -- can be used for feeding this balance.  We want
         -- to match the following rules:
         -- a) For 'M' (money) balances, the element type's output
         --    currency code must match the balances currency code
         --    and the input and output currency codes must always
         --    be the same (to avoid currency conversion issues
         --    when the balance adjustment is processed).

         hr_utility.set_location('pay_purge_pkg.pypurcif', 20);

         l := l_et_tab.first;

         while(l is not null) loop

            if(l_et_tab(l).iv_count      < c_iv_limit and
               (l_et_tab(l).currency_code = c1rec.currency_code
                 or (l_et_tab(l).currency_code is null and
                     c1rec.currency_code is null)) and
               l_et_tab(l).jur_lev       = c1rec.jurisdiction_level)
            then
               -- We have found an element type.
               l_found := true;
               l_el_id := l;
               exit when l_found;
            end if;

            l := l_et_tab.next(l);

         end loop;

         -- If we haven't found a type that has been created
         -- already, we create the element type, link and so on.
         if(not l_found) then

            hr_utility.set_location('pay_purge_pkg.pypurcif', 30);

            -- Record that another element type will be created.
            l_et_count := l_et_count + 1;

            -- Create the element type and link.
            l_el_id := create_et_el(c1rec.currency_code, l_bg_name,
                                    p_business_group_id, l_et_count);

            -- Always create a Jurisdiction input value to allow
            -- US legislative balances to work.
            l_iv_id := cre_iv_bf (l_bg_name, l_el_id, 'Jurisdiction', 'C', 1);

            -- Store the relevant values in the et stuff.
            l_et_tab(l_el_id).iv_count      := 1;
            l_et_tab(l_el_id).currency_code := c1rec.currency_code;
            l_et_tab(l_el_id).jur_lev       := c1rec.jurisdiction_level;

         end if;

         hr_utility.set_location('pay_purge_pkg.pypurcif', 40);

         -- The display sequence is the same as the
         -- input value count.
         l_iv_count := l_et_tab(l_el_id).iv_count;

         -- Creates input value, link input value and
         -- balance feed.
         l_iv_id := cre_iv_bf (l_bg_name, l_el_id,
                               substrb(c1rec.balance_name, 1, 28) || l_iv_count,
                               c1rec.balance_uom, l_iv_count,
                               c1rec.balance_type_id);

         -- Record the number of input values now.
         l_et_tab(l_el_id).iv_count := l_et_tab(l_el_id).iv_count + 1;

         if(l_et_tab(l_el_id).iv_count = c_iv_limit) then
            -- If the input value limit has been reached, we
            -- remove the element type from the list.
            hr_utility.trace('** l_el_id : ' || l_el_id);
            l_et_tab.delete(l_el_id);
         end if;

      end;

   end loop;

end pypurcif;

end pay_purge_pkg;

/
