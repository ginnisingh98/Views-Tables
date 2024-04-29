--------------------------------------------------------
--  DDL for Package Body PAY_PAYWSMEE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PAYWSMEE_PKG" as
/* $Header: paywsmee.pkb 120.7.12010000.2 2010/02/16 10:12:21 sivanara ship $ */
--
-- NOTE *** If these constants are ever updated, the changed must also
--      *** be applied to those constants defined in PAY_PAYWSMEE2_PKG
--      *** This can be done by updating the file pywsmee2.pkb
g_coverage              constant pay_input_values_f.name%type := 'Coverage';
g_ee_contributions      constant pay_input_values_f.name%type := 'EE Contr';
g_er_contributions      constant pay_input_values_f.name%type := 'ER Contr';

-- private package global vars for element entry type cache
TYPE g_element_link_id_typ IS TABLE OF pay_element_entries_f.element_link_id%TYPE
  INDEX BY BINARY_INTEGER;
TYPE g_binary_integer_typ IS TABLE OF BINARY_INTEGER INDEX BY BINARY_INTEGER;
TYPE g_entry_type_typ IS TABLE OF pay_element_entries_f.entry_type%TYPE
  INDEX BY BINARY_INTEGER;
g_element_link_id_tab g_element_link_id_typ;
g_entry_type_start_tab g_binary_integer_typ;
g_entry_type_stop_tab g_binary_integer_typ;
g_entry_type_tab g_entry_type_typ;
g_assignment_id number := null;
g_effective_date date := null;

--------------------------------------------------------------------------------
function FORMATTED_DEFAULT (
--
-- Used by get_input_value_details to format default values
--
        p_link_default          varchar2,
        p_type_default          varchar2,
        p_uom                   varchar2,
        p_hot_default           varchar2,
        p_contributions_used    varchar2,
        p_input_value_name      varchar2,
        p_input_currency_code   varchar2,
        p_lookup_type           varchar2,
        p_value_set_id          number default null) return varchar2 is
--
l_formatted_value       varchar2 (240) := null;
l_db_value              varchar2 (240) := null;
--
begin
--
if p_contributions_used = 'Y'
and p_input_value_name in (g_coverage, g_ee_contributions, g_er_contributions)
then
  -- Type A benefit plans have certain input value defaults calculated outside
  -- this package
  l_formatted_value := null;
else
  --
  if p_hot_default = 'Y' then
    l_db_value := nvl (p_link_default, p_type_default);
  else
    l_db_value := p_link_default;
  end if;
  --
  if p_lookup_type is null
     and p_value_set_id is null
  then
    -- Convert the default value from database to display format
    l_formatted_value := hr_chkfmt.changeformat (l_db_value, p_uom, p_input_currency_code);
	elsif p_lookup_type is not null then
    -- Get the user meaning for the lookup code stored
    l_formatted_value := hr_general.decode_lookup (p_lookup_type, l_db_value);
	elsif p_value_set_id is not null then
		-- Get the user meaning for the value set value stored
		l_formatted_value := pay_input_values_pkg.decode_vset_value(p_value_set_id,
			l_db_value);
  end if;
  --
  if p_hot_default = 'Y' then
    -- Hot defaults are denoted by speech marks
    l_formatted_value := '"'||l_formatted_value||'"';
  end if;
  --
end if;
--
return l_formatted_value;
--
end formatted_default;
--------------------------------------------------------------------------------
procedure fetch_payroll_period_info (
--
--*****************************************************************************
-- Fetch information about the payroll period for the context assignment
--*****************************************************************************
--
p_payroll_id     in out nocopy number,  -- Payroll ID of the context assignment
p_effective_date in            date,    -- form session effective date
p_display_period    OUT nocopy varchar2,-- period name and its start-end dates
p_period_status     OUT nocopy varchar2,-- open or closed flag
p_start_date        OUT nocopy date,    -- the period start date
p_end_date          OUT nocopy date     -- the period end date
) is
--
-- Define how to retrieve payroll period information
--
cursor asgt_payroll_period is
        select  start_date,
                end_date,
                status,
                period_name||
                        ' ('||
                        fnd_date.date_to_displaydate (start_date)||
                        ' - '||
                        fnd_date.date_to_displaydate (end_date)||
                        ')'                     DISPLAY_PERIOD
        from    per_time_periods
        where   payroll_id = p_payroll_id
        and     p_effective_date between start_date and end_date;
--
begin
--
if p_payroll_id is not null then -- only fetch info if assignment has a payroll
--
  -- Fetch the payroll period information
--
  open asgt_payroll_period;
--
  fetch asgt_payroll_period into
                        p_start_date,
                        p_end_date,
                        p_period_status,
                        p_display_period;
--
  close asgt_payroll_period;
--
else -- no payroll information exists so nullify 'out' parameters
--
  p_start_date := null;
  p_end_date := null;
--
end if;
--
end fetch_payroll_period_info;
--------------------------------------------------------------------------------
procedure populate_context_items (
--
--******************************************************************************
-- Populate form initialisation information
--******************************************************************************
--
p_effective_date            in            date,    -- Form session date
p_business_group_id         in            number,  -- User's business group
p_customized_restriction_id in            number,  -- customization identifier
p_assignment_id             in            number,  -- Context assignment
p_payroll_id                in out nocopy number,  -- Payroll id for the asg
p_display_period            in out nocopy varchar2,-- Period displayed details
p_period_status             in out nocopy varchar2,-- Open/closed flag 4 period
p_start_date                in out nocopy date,    -- Start of period
p_end_date                  in out nocopy date,    -- End of period
p_cost_allocation_structure in out nocopy varchar2,-- Keyflex structure
p_pay_value_name            in out nocopy varchar2,
p_processing_type           in out nocopy varchar2,-- customization
p_entry_type                in out nocopy varchar2,-- customization
p_element_set               in out nocopy number   -- customization
) is
--
-- Define how to retrieve Keyflex structure information
--
cursor keyflex_structure is
        select  cost_allocation_structure
        from    per_business_groups_perf
        where   business_group_id = p_business_group_id;
--
-- Define how to retrieve assignment's payroll information
--
cursor payroll is
        select payroll_id
        from    per_assignments_f
        where   assignment_id = p_assignment_id
        and     p_effective_date between effective_start_date
                                        and effective_end_date;
--
-- Define how to retrieve customization details
--
cursor type_customization is
        select  value
        from    pay_restriction_values
        where   restriction_code = 'ELEMENT_TYPE'
        and     customized_restriction_id = p_customized_restriction_id;
--
cursor set_customization is
        select  fnd_number.canonical_to_number( value )
        from    pay_restriction_values
        where   restriction_code = 'ELEMENT_SET'
        and     customized_restriction_id = p_customized_restriction_id;
--
cursor entry_type_customization is
        select  value
        from    pay_restriction_values
        where   restriction_code = 'ENTRY_TYPE'
        and     customized_restriction_id = p_customized_restriction_id;
--
begin
--
-- Fetch Keyflex information
--
open keyflex_structure;
fetch keyflex_structure into p_cost_allocation_structure;
close keyflex_structure;
--
-- Fetch assignment's payroll ID
--
open payroll;
fetch payroll into p_payroll_id;
close payroll;
--
-- Using the newly fetched payroll ID, fetch the current payroll period details
--
fetch_payroll_period_info (     p_payroll_id,
                                p_effective_date,
                                p_display_period,
                                p_period_status,
                                p_start_date,
                                p_end_date      );
--
-- Find local translation of pay value name
--
p_pay_value_name := hr_general.pay_value;
--
-- Find processing type customization
--
open type_customization;
fetch type_customization into p_processing_type;
close type_customization;
--
-- Find element set customization
--
open set_customization;
fetch set_customization into p_element_set;
close set_customization;
--
-- Find entry type customization
--
open entry_type_customization;
fetch entry_type_customization into p_entry_type;
close entry_type_customization;
--
end populate_context_items;
--------------------------------------------------------------------------------
function PROCESSED (
--
-- Returns 'Y' if the element entry has already been processed in a payroll
-- run. Used by the pay_paywsmee_element_entries view and others.
--
p_element_entry_id      number,
p_original_entry_id     number,
p_processing_type       varchar2,
p_entry_type            varchar2,
p_effective_date        date) return varchar2 is
--
processed       varchar2(1) := 'N';
--
-- Define how to determine if the entry is processed
--
cursor nonrecurring_entries (adjust_ee_source in varchar2) is
        select  'Y'
        from    pay_run_results       prr,
                pay_element_entries_f pee
        where   pee.element_entry_id = p_element_entry_id
        and     p_effective_date between pee.effective_start_date
                                     and pee.effective_end_date
        and     prr.source_id   = decode(pee.entry_type,
                                          'A', decode (adjust_ee_source,
                                                       'T', pee.target_entry_id,
                                                       pee.element_entry_id),
                                          'R', decode (adjust_ee_source,
                                                       'T', pee.target_entry_id,
                                                       pee.element_entry_id),
                                          pee.element_entry_id)
        and     prr.entry_type  = pee.entry_type
        and     prr.source_type = 'E'
        and     prr.status          <> 'U'
-- change 115.9
and     NOT EXISTS
            (SELECT 1
             FROM   PAY_RUN_RESULTS sub_rr
             WHERE  sub_rr.source_id = prr.run_result_id
             and    sub_rr.source_type in ('R', 'V'))
;
        --
--
-- Retropay by Element Entry for unprocessed nonrecurring entry
--
cursor nonrecurring_retro_entry is
        select  'Y'
        from    pay_element_entries_f oee,
                pay_element_entries_f ree
        where   oee.element_entry_id = p_element_entry_id
        and     p_effective_date between oee.effective_start_date
                                     and oee.effective_end_date
        and     ree.assignment_id    = oee.assignment_id
        and     ree.source_id        = oee.element_entry_id
        and     ree.entry_type       = 'E'
        and     ree.creator_type     = 'EE';
        --
-- Bug 522510, recurring entries are considered as processed in the Date Earned period,
-- not Date Paid period - where run results exists.

cursor recurring_entries is
        --
        select  'Y'
        from    pay_run_results         RESULT,
                pay_assignment_actions  ASGT_ACTION,
                pay_payroll_actions     PAY_ACTION,
                per_time_periods        PERIOD
        where   result.source_id        = nvl (p_original_entry_id, p_element_entry_id)
        and     result.status           <> 'U'
        and     result.source_type = 'E'
        and     result.assignment_action_id     = asgt_action.assignment_action_id
        and     asgt_action.payroll_action_id   = pay_action.payroll_action_id
        and     pay_action.payroll_id = period.payroll_id
        and     pay_action.date_earned between period.start_date and period.end_date
        and     p_effective_date between period.start_date and period.end_date
-- change 115.12
        and     NOT EXISTS
            (SELECT 1
             FROM   PAY_RUN_RESULTS rev_result
             WHERE  rev_result.source_id = result.run_result_id
             and    rev_result.source_type in ('R', 'V'));
--
-- Retropay by Element Entry for unprocessed recurring entry
--
cursor recurring_retro_entry is
        select  /*+ ORDERED INDEX(ree PAY_ELEMENT_ENTRIES_F_N50)*/
                'Y'
        from    pay_element_entries_f oee,
                pay_element_entries_f ree,
                pay_assignment_actions paa,
                pay_payroll_actions   pac,
                per_time_periods period
        where   oee.element_entry_id = p_element_entry_id
        and     p_effective_date between oee.effective_start_date
                                     and oee.effective_end_date
        and     p_effective_date between period.start_date and period.end_date
        and     pac.payroll_id = period.payroll_id
        and     pac.date_earned between period.start_date and period.end_date
        and     ree.assignment_id    = oee.assignment_id
        and     ree.source_id        = oee.element_entry_id
        and     ree.entry_type       = 'D'
        and     ree.creator_type     = 'EE'
        and     paa.assignment_action_id = ree.source_asg_action_id
        and     pac.payroll_action_id = paa.payroll_action_id
        and     pac.effective_date between oee.effective_start_date
                                       and oee.effective_end_date;
--
adjust_ee_source varchar2(1);
begin
--
if (p_entry_type in ('S','D','A','R') or p_processing_type = 'N') then
  --
  begin
    select /*+ INDEX(paf PER_ASSIGNMENTS_F_PK)*/ plr.rule_mode
      into adjust_ee_source
      from pay_legislation_rules plr,
           per_business_groups   pbg,
           per_assignments_f     paf,
           pay_element_entries_f pee
     where pee.element_entry_id = p_element_entry_id
       and p_effective_date between pee.effective_start_date
                                and pee.effective_end_date
       and paf.assignment_id = pee.assignment_id
       and p_effective_date between paf.effective_start_date
                                and paf.effective_end_date
       and paf.business_group_id = pbg.business_group_id
       and pbg.legislation_code = plr.legislation_code
       and plr.rule_type = 'ADJUSTMENT_EE_SOURCE';
     --
   exception
       when no_data_found then
          adjust_ee_source := 'A';
  end;
  --
  open nonrecurring_entries(adjust_ee_source);
  fetch nonrecurring_entries into processed;
  close nonrecurring_entries;
  --
  if (processed = 'N') then
    open nonrecurring_retro_entry;
    fetch nonrecurring_retro_entry into processed;
    close nonrecurring_retro_entry;
  end if;
  --
else
  --
  open recurring_entries;
  fetch recurring_entries into processed;
  close recurring_entries;
  --
  if (processed = 'N') then
    open recurring_retro_entry;
    fetch recurring_retro_entry into processed;
    close recurring_retro_entry;
  end if;
  --
end if;
--
return processed;
--
end processed;
--------------------------------------------------------------------------------
PROCEDURE delete_entry_caches IS
BEGIN
  -- no need to delete the g_element_link_id_tab structure as it is always deleted
  -- at the end of population
  g_entry_type_start_tab.DELETE;
  g_entry_type_stop_tab.DELETE;
  g_entry_type_tab.DELETE;
  -- Bugfix 4601302
  -- nullify g_assignment_id and g_effective_date to ensure cache is rebuilt
  -- next time
  g_assignment_id := null;
  g_effective_date := null;
  --
END delete_entry_caches;
--------------------------------------------------------------------------------
PROCEDURE populate_entry_type_cache
            (p_assignment_id  IN NUMBER,
             p_effective_date IN DATE) IS
--
  CURSOR csr_entry is
    SELECT  DISTINCT
            pee.element_link_id,
            pee.entry_type
    FROM    pay_element_entries_f pee
    WHERE   pee.assignment_id = p_assignment_id
    AND     p_effective_date
    BETWEEN pee.effective_start_date and pee.effective_end_date
    ORDER BY 1,2;
--
BEGIN
  -- check to see if the assignment is cached
  IF p_assignment_id <> nvl(g_assignment_id, p_assignment_id+1) OR
     p_effective_date <> nvl(g_effective_date, p_effective_date+1)  THEN
    -- the assignment_id/effective_date combo don't match so populate
    -- the cache but before we do that complete the following:
    -- 1) clear caches
    delete_entry_caches;
    -- 2) set the private global assignment and effective_date comparision
    g_assignment_id := p_assignment_id;
    g_effective_date := p_effective_date;
    -- now go populate the cache structures
    -- perform a BULK collect
    OPEN csr_entry;
    FETCH csr_entry BULK COLLECT INTO g_element_link_id_tab, g_entry_type_tab;
    CLOSE csr_entry;
    -- -------------------------------------------------------------------
    -- cache strategy
    --
    -- the cache uses 3 structures:
    -- 1) g_entry_type_tab stores the entry types
    -- 2) g_entry_type_start_tab stores the starting index position of the
    --    element link entry types
    -- 3) g_entry_type_stop_tab stores the end index position of the
    --    element link entry types
    --
    --  g_entry_type_start_tab g_entry_type_stop_tab g_entry_type_tab
    --  [23] 55                [23] 57               [55] B
    --                                               [56] D
    --                                               [57] S
    --
    --  so from above, the element_link_id of 23 is the index position
    --  within each of the start/stop arrays. The start/stop arrays point
    --  to the start/end indexes of the entry type table.
    -- -------------------------------------------------------------------
    -- populate the cache looping through each row returned by the BULK collect
    FOR i IN g_element_link_id_tab.FIRST..g_element_link_id_tab.LAST LOOP
      -- has the element_link already been placed in the cache?
      -- we do this by checking to see if a start position exists
      -- using the element_link_id as an index
      IF NOT g_entry_type_start_tab.EXISTS(g_element_link_id_tab(i)) THEN
        -- the element link was not found so set the start position
       g_entry_type_start_tab(g_element_link_id_tab(i)) := i;
      END IF;
      -- always set the end position
      g_entry_type_stop_tab(g_element_link_id_tab(i)) := i;
    END LOOP;
    -- as we don't need the g_element_link_id_tab contents delete it
    -- to free up memory
    g_element_link_id_tab.DELETE;
  ELSE
    -- the cache is already populated for the assignment_id/effective_date
    -- combo so just return
    RETURN;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    -- an unexpected error has occurred so clean up and raise the error
    IF csr_entry%ISOPEN THEN
      -- as the csr_entry is still open close it
      CLOSE csr_entry;
    END IF;
    -- clear down any caches which may have been populated to free the
    -- memory
    delete_entry_caches;
    -- raise the error
    RAISE;
END populate_entry_type_cache;
--------------------------------------------------------------------------------
function normal_exists (
--
-- Returns 'Y' if a normal entry exists for this assignment and element type.
-- Used by the view pay_paywsmee_element_entries
--
p_element_link_id       number,
p_assignment_id         number,
p_effective_date        date) return varchar2 is
--
BEGIN
  -- populate or use the current cache
  populate_entry_type_cache
    (p_assignment_id => p_assignment_id,
     p_effective_date => p_effective_date);
  -- check to see if an entry_type of E exists
  FOR i IN g_entry_type_start_tab(p_element_link_id)..
           g_entry_type_stop_tab(p_element_link_id) LOOP
    -- does any entry_type of E exist?
    IF g_entry_type_tab(i) = 'E' THEN
      RETURN('Y');
    END IF;
  END LOOP;
  RETURN('N');
EXCEPTION
  WHEN OTHERS THEN
    -- caused by the element_link_id not existing as an element entry for the
    -- assignment/effective date combo
    RETURN('N');
END normal_exists;
--------------------------------------------------------------------------------
FUNCTION additional_exists (
--
-- Returns 'Y' if an additional entry of this type exists for this assignment
-- Used by the view pay_paywsmee_element_entries
--
p_element_link_id       number,
p_assignment_id         number,
p_effective_date        date) RETURN VARCHAR2 IS
--
BEGIN
  -- populate or use the current cache
  populate_entry_type_cache
    (p_assignment_id => p_assignment_id,
     p_effective_date => p_effective_date);
  -- check to see if an entry_type of D exists
  FOR i IN g_entry_type_start_tab(p_element_link_id)..
           g_entry_type_stop_tab(p_element_link_id) LOOP
    -- does any entry_type of D exist?
    IF g_entry_type_tab(i) = 'D' THEN
      RETURN('Y');
    END IF;
  END LOOP;
  RETURN('N');
EXCEPTION
  WHEN OTHERS THEN
    -- caused by the element_link_id not existing as an element entry for the
    -- assignment/effective date combo
    RETURN('N');
END additional_exists;
--------------------------------------------------------------------------------
function is_entry_included (
--
-- Returns TRUE if this entry is included in the quickpay run
--
p_assignment_action_id  number,
p_element_entry_id      number) return varchar2 is
--
-- Enhancement 3368211
-- csr_included now in 2 parts, the first part handles the QuickPay
-- Inclusions model, the second handles the new QuickPay Exclusions model.
--
cursor csr_included (
         p_asgt_act_id number,
         p_ee_id number,
         p_use_qpay_excl_model varchar2
         )
       is
       /*
        * QuickPay Inclusions model
        */
       select 'Y'
       from   pay_quickpay_inclusions incl
       where  p_use_qpay_excl_model     = 'N'
       and    incl.assignment_action_id = p_asgt_act_id
       and    incl.element_entry_id     = p_ee_id
       union all
       /*
        * QuickPay Exclusions model
        */
        select 'Y'
          from dual
         where p_use_qpay_excl_model = 'Y'
           and  not exists
              (select ''
               from   pay_quickpay_exclusions excl
               where  excl.assignment_action_id = p_asgt_act_id
                and    excl.element_entry_id     = p_ee_id
              );
--       select 'Y'
--         from pay_element_types_f    ety
--            , pay_element_links_f    elk
--            , pay_element_entries_f  ent
--            , pay_payroll_actions    pya
--            , pay_assignment_actions asa
--        where p_use_qpay_excl_model = 'Y'
--              /*
--               * Ensure entry does not exist in list of exclusions
--               */
--         and not exists (
--               select 'x'
--               from   pay_quickpay_exclusions excl
--               where  excl.assignment_action_id = p_asgt_act_id
--                and    excl.element_entry_id     = p_ee_id
--              )
--              /*
--               * Element Type:
--              * Only include those which can be processed in the run.
--               */
--          and ety.process_in_run_flag  = 'Y'
--          and ety.element_type_id      = elk.element_type_id
--          and pya.date_earned    between ety.effective_start_date
--                                     and ety.effective_end_date
--              /*
--               * Element Link:
--               * Only include those that exist as of QuickPay date earned.
--               */
--          and elk.element_link_id      = ent.element_link_id
--          and pya.date_earned    between elk.effective_start_date
--                                     and elk.effective_end_date
--              /*
--               * Element Entry:
--               * Do not include balance adjustment, replacement adjustment
--               * or additive adjustment.
--               */
--          and ent.element_entry_id     = p_ee_id
--          and ent.entry_type      not in ('B', 'A', 'R')
--          and ent.assignment_id        = asa.assignment_id
--          and ent.effective_start_date <= pya.date_earned
--          and ent.effective_end_date   >= decode(ety.proration_group_id, null, pya.date_earned,
--                                                 pay_interpreter_pkg.prorate_start_date
--                                                        (asa.assignment_action_id,
--                                                         ety.proration_group_id
--                                                        ))
--                  /*
--                   * Non-recurring entries can only be included if they have not
--                   * been processed.
--                   */
--          and ( ( (   (ety.processing_type   = 'N'
--                      )
--                  /*
--                   * Recurring, additional or override entries can only be
--                   * included if they have not been processed. (These types of
--                   * recurring entry are handled as if they were non-recurring.)
--                   */
--                   or (    ety.processing_type    = 'R'
--                       and ent.entry_type        <> 'E'
--                      )
--                  )
--                  and (not exists (  select 'x'
--                                     from pay_run_results pr1
--                                        , pay_assignment_actions asa2
--                                     where pr1.source_id = ent.element_entry_id
--                                     and pr1.source_type = 'E'
--                                     and pr1.status <> 'U'
--                                     and pr1.assignment_action_id = asa2.assignment_action_id
--                                     and (  asa2.source_action_id <> p_asgt_act_id
--                                            or (  asa2.assignment_action_id <> p_asgt_act_id
--                                                  and not exists (  select 'x'
--                                                                    from pay_assignment_actions asa3
--                                                                    where asa3.assignment_action_id = pr1.assignment_action_id
--                                                                    and asa3.source_action_id = p_asgt_act_id
--                                                                 )
--                                               )
--                                         )
--                                  )
--                      or exists (select null
--                                   from pay_run_results pr1
--                                  where pr1.source_id   = ent.element_entry_id
--                                    and pr1.source_type = 'E'
--                                    and pr1.status      = 'U'
--                                )
--                      )
--                )
--                  /*
--                   * Include other recurring entries.
--                   * i.e. Those which are not additional or overrides entries.
--                   */
--               or (    ety.processing_type    = 'R'
--                   and ent.entry_type         = 'E'
--                  )
--              )
--              /*
--               * Payroll Action:
--               * Ensure the action is for a QuickPay Run.
--               */
--          and pya.action_type          = 'Q'
--          and pya.payroll_action_id    = asa.payroll_action_id
--              /*
--               *  Assignment Action:
--               */
--          and asa.assignment_action_id = p_asgt_act_id;
--
l_included varchar2(1) := 'N';
--
begin
--
  open csr_included (
    p_assignment_action_id,
    p_element_entry_id,
    pay_qpq_api.use_qpay_excl_model
  );
  fetch csr_included into l_included;
  close csr_included;
  return l_included;
--
end is_entry_included;
--------------------------------------------------------------------------------
function overridden (
--
-- Returns 'Y' if the entry is overridden. Used by pay_paywsmee_elements_lov
-- and pay_paywsmee_element_entries
--
p_element_link_id       number,
p_assignment_id         number,
p_effective_date        date) return varchar2 is
--
BEGIN
  -- populate or use the current cache
  populate_entry_type_cache
    (p_assignment_id => p_assignment_id,
     p_effective_date => p_effective_date);
  -- check to see if an entry_type of S exists
  FOR i IN g_entry_type_start_tab(p_element_link_id)..
           g_entry_type_stop_tab(p_element_link_id) LOOP
    -- does any entry_type of S exist?
    IF g_entry_type_tab(i) = 'S' THEN
      RETURN('Y');
    END IF;
  END LOOP;
  RETURN('N');
EXCEPTION
  WHEN OTHERS THEN
    -- caused by the element_link_id not existing as an element entry for the
    -- assignment/effective date combo
    RETURN('N');
END overridden;
--------------------------------------------------------------------------------
function personal_payment_method (
--
p_personal_payment_method_id    number,
p_assignment_id                 number,
p_effective_date                date) return varchar2 is
--
cursor personal_payment_method is
        select  ppm.payee_type,
                ppm.payee_id,
                opm_tl.org_payment_method_name
                        ||' : '||pay_type_tl.payment_type_name PAYMENT_TYPE
        from    pay_personal_payment_methods_f  PPM,
                pay_org_payment_methods_f_tl    OPM_TL,
                pay_org_payment_methods_f       OPM,
                pay_payment_types_tl            PAY_TYPE_TL,
                pay_payment_types               PAY_TYPE
        where   personal_payment_method_id = p_personal_payment_method_id
        and     ppm.org_payment_method_id = opm.org_payment_method_id
        and     opm_tl.org_payment_method_id = opm.org_payment_method_id
        and     USERENV('LANG') = opm_tl.language
        and     pay_type.payment_type_id = opm.payment_type_id
        and     pay_type_tl.payment_type_id = pay_type.payment_type_id
        and     userenv('LANG') = pay_type_tl.language
        and     p_effective_date between opm.effective_start_date
                                and opm.effective_end_date
        and     p_effective_date between ppm.effective_start_date
                                and ppm.effective_end_date;
        --
l_payee_id      number;
l_payee_type    varchar2 (255);
l_payment_type  varchar2 (500);
--
cursor organization is
        select  name
        from    hr_all_organization_units
        where   organization_id = l_payee_id;
        --
cursor person is
        select  full_name
        from    per_all_people_f
        where   person_id = l_payee_id
        and     p_effective_date between effective_start_date
                                and effective_end_date;
        --
l_third_party_name      varchar2 (255) := null;
l_separator             varchar2 (1) := null;
--
begin
--
-- Open cursors if a personal payment method is passed in
--
if p_personal_payment_method_id is not null then
  --
  -- Get the PPM details
  --
  open personal_payment_method;
  fetch personal_payment_method into l_payee_type, l_payee_id, l_payment_type;
  close personal_payment_method;
  --
  if l_payee_type = 'P' then
    --
    -- Get the name of the person who is the third party payee
    --
    open person;
    fetch person into l_third_party_name;
    close person;
    --
  elsif l_payee_type = 'O' then
    --
    -- Get the name of the organization which is the third party payee
    --
    open organization;
    fetch organization into l_third_party_name;
    close organization;
    --
  end if;
  --
end if;
--
if l_third_party_name is not null then
  l_separator := ' ';
else
  l_separator := null;
end if;
--
return (l_third_party_name || l_separator || l_payment_type);
--
end personal_payment_method;
--------------------------------------------------------------------------------
function adjusted (
--
-- Returns 'Y' if there is any entry for this link and assignment with an
-- adjustment. Used by pay_paywsmee_element_entries and
-- pay_paywsmee_elements_lov
--
p_element_link_id       number,
p_assignment_id         number,
p_effective_date        date) return varchar2 is
--
BEGIN
  -- populate or use the current cache
  populate_entry_type_cache
    (p_assignment_id => p_assignment_id,
     p_effective_date => p_effective_date);
  -- check to see if an entry_type of 'B', 'R' or 'A' exists
  FOR i IN g_entry_type_start_tab(p_element_link_id)..
           g_entry_type_stop_tab(p_element_link_id) LOOP
    -- does any entry_type of 'B', 'R' or 'A' exist?
    IF g_entry_type_tab(i) in ('B', 'R', 'A') THEN
      RETURN('Y');
    END IF;
  END LOOP;
  RETURN('N');
EXCEPTION
  WHEN OTHERS THEN
    -- caused by the element_link_id not existing as an element entry for the
    -- assignment/effective date combo
    RETURN('N');
END adjusted;
--------------------------------------------------------------------------------
procedure update_original_if_MIX
(
-- used by entry.insert_row to nulify creator_type
-- for MIX entry when creating additional entries or overrides
--
p_assignment_id         number,
p_element_type_id       number,
p_effective_start_date  date,
p_session_date          date
) is
--
l_element_entry_id   number;
l_creator_type       varchar2(10);
--
cursor csr_original_entry is
   select peef.element_entry_id, peef.creator_type
      from pay_element_entries_f peef,
           pay_element_links_f pelf,
           pay_element_types_f petf
      where petf.element_type_id = p_element_type_id
      and   pelf.element_type_id = petf.element_type_id
      and   peef.element_link_id = pelf.element_link_id
      and   peef.assignment_id = p_assignment_id
      and   p_effective_start_date between peef.effective_start_date
                                       and peef.effective_end_date
      and   p_effective_start_date between pelf.effective_start_date
                                       and pelf.effective_end_date
      and   p_effective_start_date between petf.effective_start_date
                                       and petf.effective_end_date;
--
begin

  open csr_original_entry;
  fetch csr_original_entry into l_element_entry_id, l_creator_type;
  close csr_original_entry;
--
  if l_creator_type = 'H' then
  hr_utility.trace('updating');
     hr_entry_api.update_element_entry
     (
       p_dt_update_mode                         =>'CORRECTION',
       p_session_date                           =>p_session_date,
       p_creator_type                           => 'F',
       p_creator_id                             => null,
       p_element_entry_id                       =>l_element_entry_id
     );
  end if;
--
end update_original_if_MIX;

procedure GET_ENTRY_VALUE_DETAILS (
--
-- Returns the element entry values along with all their inherited properties
-- for each element entry selected by a query in the form
--
p_element_entry_id                    number,
p_element_link_id                     number,
p_effective_date                      date,
p_ee_effective_start_date             date,
p_ee_effective_end_date               date,
p_element_type_id                     number,
p_business_group_id                   number,
p_contributions_used                  varchar2,
p_input_currency_code                 varchar2,
p_input_value_id1       in out nocopy number,
p_input_value_id2       in out nocopy number,
p_input_value_id3       in out nocopy number,
p_input_value_id4       in out nocopy number,
p_input_value_id5       in out nocopy number,
p_input_value_id6       in out nocopy number,
p_input_value_id7       in out nocopy number,
p_input_value_id8       in out nocopy number,
p_input_value_id9       in out nocopy number,
p_input_value_id10      in out nocopy number,
p_input_value_id11      in out nocopy number,
p_input_value_id12      in out nocopy number,
p_input_value_id13      in out nocopy number,
p_input_value_id14      in out nocopy number,
p_input_value_id15      in out nocopy number,
p_name1                 in out nocopy varchar2,
p_name2                 in out nocopy varchar2,
p_name3                 in out nocopy varchar2,
p_name4                 in out nocopy varchar2,
p_name5                 in out nocopy varchar2,
p_name6                 in out nocopy varchar2,
p_name7                 in out nocopy varchar2,
p_name8                 in out nocopy varchar2,
p_name9                 in out nocopy varchar2,
p_name10                in out nocopy varchar2,
p_name11                in out nocopy varchar2,
p_name12                in out nocopy varchar2,
p_name13                in out nocopy varchar2,
p_name14                in out nocopy varchar2,
p_name15                in out nocopy varchar2,
p_uom1                  in out nocopy varchar2,
p_uom2                  in out nocopy varchar2,
p_uom3                  in out nocopy varchar2,
p_uom4                  in out nocopy varchar2,
p_uom5                  in out nocopy varchar2,
p_uom6                  in out nocopy varchar2,
p_uom7                  in out nocopy varchar2,
p_uom8                  in out nocopy varchar2,
p_uom9                  in out nocopy varchar2,
p_uom10                 in out nocopy varchar2,
p_uom11                 in out nocopy varchar2,
p_uom12                 in out nocopy varchar2,
p_uom13                 in out nocopy varchar2,
p_uom14                 in out nocopy varchar2,
p_uom15                 in out nocopy varchar2,
p_hot_default_flag1     in out nocopy varchar2,
p_hot_default_flag2     in out nocopy varchar2,
p_hot_default_flag3     in out nocopy varchar2,
p_hot_default_flag4     in out nocopy varchar2,
p_hot_default_flag5     in out nocopy varchar2,
p_hot_default_flag6     in out nocopy varchar2,
p_hot_default_flag7     in out nocopy varchar2,
p_hot_default_flag8     in out nocopy varchar2,
p_hot_default_flag9     in out nocopy varchar2,
p_hot_default_flag10    in out nocopy varchar2,
p_hot_default_flag11    in out nocopy varchar2,
p_hot_default_flag12    in out nocopy varchar2,
p_hot_default_flag13    in out nocopy varchar2,
p_hot_default_flag14    in out nocopy varchar2,
p_hot_default_flag15    in out nocopy varchar2,
p_mandatory_flag1       in out nocopy varchar2,
p_mandatory_flag2       in out nocopy varchar2,
p_mandatory_flag3       in out nocopy varchar2,
p_mandatory_flag4       in out nocopy varchar2,
p_mandatory_flag5       in out nocopy varchar2,
p_mandatory_flag6       in out nocopy varchar2,
p_mandatory_flag7       in out nocopy varchar2,
p_mandatory_flag8       in out nocopy varchar2,
p_mandatory_flag9       in out nocopy varchar2,
p_mandatory_flag10      in out nocopy varchar2,
p_mandatory_flag11      in out nocopy varchar2,
p_mandatory_flag12      in out nocopy varchar2,
p_mandatory_flag13      in out nocopy varchar2,
p_mandatory_flag14      in out nocopy varchar2,
p_mandatory_flag15      in out nocopy varchar2,
p_formula_id1           in out nocopy number,
p_formula_id2           in out nocopy number,
p_formula_id3           in out nocopy number,
p_formula_id4           in out nocopy number,
p_formula_id5           in out nocopy number,
p_formula_id6           in out nocopy number,
p_formula_id7           in out nocopy number,
p_formula_id8           in out nocopy number,
p_formula_id9           in out nocopy number,
p_formula_id10          in out nocopy number,
p_formula_id11          in out nocopy number,
p_formula_id12          in out nocopy number,
p_formula_id13          in out nocopy number,
p_formula_id14          in out nocopy number,
p_formula_id15          in out nocopy number,
p_lookup_type1          in out nocopy varchar2,
p_lookup_type2          in out nocopy varchar2,
p_lookup_type3          in out nocopy varchar2,
p_lookup_type4          in out nocopy varchar2,
p_lookup_type5          in out nocopy varchar2,
p_lookup_type6          in out nocopy varchar2,
p_lookup_type7          in out nocopy varchar2,
p_lookup_type8          in out nocopy varchar2,
p_lookup_type9          in out nocopy varchar2,
p_lookup_type10         in out nocopy varchar2,
p_lookup_type11         in out nocopy varchar2,
p_lookup_type12         in out nocopy varchar2,
p_lookup_type13         in out nocopy varchar2,
p_lookup_type14         in out nocopy varchar2,
p_lookup_type15         in out nocopy varchar2,
p_value_set_id1    in out nocopy number,
p_value_set_id2    in out nocopy number,
p_value_set_id3    in out nocopy number,
p_value_set_id4    in out nocopy number,
p_value_set_id5    in out nocopy number,
p_value_set_id6    in out nocopy number,
p_value_set_id7    in out nocopy number,
p_value_set_id8    in out nocopy number,
p_value_set_id9    in out nocopy number,
p_value_set_id10    in out nocopy number,
p_value_set_id11    in out nocopy number,
p_value_set_id12    in out nocopy number,
p_value_set_id13    in out nocopy number,
p_value_set_id14    in out nocopy number,
p_value_set_id15    in out nocopy number,
p_min_value1            in out nocopy varchar2,
p_min_value2            in out nocopy varchar2,
p_min_value3            in out nocopy varchar2,
p_min_value4            in out nocopy varchar2,
p_min_value5            in out nocopy varchar2,
p_min_value6            in out nocopy varchar2,
p_min_value7            in out nocopy varchar2,
p_min_value8            in out nocopy varchar2,
p_min_value9            in out nocopy varchar2,
p_min_value10           in out nocopy varchar2,
p_min_value11           in out nocopy varchar2,
p_min_value12           in out nocopy varchar2,
p_min_value13           in out nocopy varchar2,
p_min_value14           in out nocopy varchar2,
p_min_value15           in out nocopy varchar2,
p_max_value1            in out nocopy varchar2,
p_max_value2            in out nocopy varchar2,
p_max_value3            in out nocopy varchar2,
p_max_value4            in out nocopy varchar2,
p_max_value5            in out nocopy varchar2,
p_max_value6            in out nocopy varchar2,
p_max_value7            in out nocopy varchar2,
p_max_value8            in out nocopy varchar2,
p_max_value9            in out nocopy varchar2,
p_max_value10           in out nocopy varchar2,
p_max_value11           in out nocopy varchar2,
p_max_value12           in out nocopy varchar2,
p_max_value13           in out nocopy varchar2,
p_max_value14           in out nocopy varchar2,
p_max_value15           in out nocopy varchar2,
p_screen_entry_value1   in out nocopy varchar2,
p_screen_entry_value2   in out nocopy varchar2,
p_screen_entry_value3   in out nocopy varchar2,
p_screen_entry_value4   in out nocopy varchar2,
p_screen_entry_value5   in out nocopy varchar2,
p_screen_entry_value6   in out nocopy varchar2,
p_screen_entry_value7   in out nocopy varchar2,
p_screen_entry_value8   in out nocopy varchar2,
p_screen_entry_value9   in out nocopy varchar2,
p_screen_entry_value10  in out nocopy varchar2,
p_screen_entry_value11  in out nocopy varchar2,
p_screen_entry_value12  in out nocopy varchar2,
p_screen_entry_value13  in out nocopy varchar2,
p_screen_entry_value14  in out nocopy varchar2,
p_screen_entry_value15  in out nocopy varchar2,
p_entry_value_id1       in out nocopy number,
p_entry_value_id2       in out nocopy number,
p_entry_value_id3       in out nocopy number,
p_entry_value_id4       in out nocopy number,
p_entry_value_id5       in out nocopy number,
p_entry_value_id6       in out nocopy number,
p_entry_value_id7       in out nocopy number,
p_entry_value_id8       in out nocopy number,
p_entry_value_id9       in out nocopy number,
p_entry_value_id10      in out nocopy number,
p_entry_value_id11      in out nocopy number,
p_entry_value_id12      in out nocopy number,
p_entry_value_id13      in out nocopy number,
p_entry_value_id14      in out nocopy number,
p_entry_value_id15      in out nocopy number,
p_default_value1        in out nocopy varchar2,
p_default_value2        in out nocopy varchar2,
p_default_value3        in out nocopy varchar2,
p_default_value4        in out nocopy varchar2,
p_default_value5        in out nocopy varchar2,
p_default_value6        in out nocopy varchar2,
p_default_value7        in out nocopy varchar2,
p_default_value8        in out nocopy varchar2,
p_default_value9        in out nocopy varchar2,
p_default_value10       in out nocopy varchar2,
p_default_value11       in out nocopy varchar2,
p_default_value12       in out nocopy varchar2,
p_default_value13       in out nocopy varchar2,
p_default_value14       in out nocopy varchar2,
p_default_value15       in out nocopy varchar2,
p_warning_or_error1     in out nocopy varchar2,
p_warning_or_error2     in out nocopy varchar2,
p_warning_or_error3     in out nocopy varchar2,
p_warning_or_error4     in out nocopy varchar2,
p_warning_or_error5     in out nocopy varchar2,
p_warning_or_error6     in out nocopy varchar2,
p_warning_or_error7     in out nocopy varchar2,
p_warning_or_error8     in out nocopy varchar2,
p_warning_or_error9     in out nocopy varchar2,
p_warning_or_error10    in out nocopy varchar2,
p_warning_or_error11    in out nocopy varchar2,
p_warning_or_error12    in out nocopy varchar2,
p_warning_or_error13    in out nocopy varchar2,
p_warning_or_error14    in out nocopy varchar2,
p_warning_or_error15    in out nocopy varchar2
) is
--
-- Bugfix 468639
-- fetched_entry_value_rec and fetched_entry_value added
-- to avoid truncation of lookup meanings to 60 chars
--
TYPE fetched_entry_value_rec IS RECORD
(
   element_entry_value_id pay_element_entry_values_f.element_entry_value_id%TYPE
  ,screen_entry_value     VARCHAR2(240) -- to avoid truncation of lookup meaning
  ,input_value_id         pay_element_entry_values_f.input_value_id%TYPE
  ,name                   pay_input_values_f_tl.name%TYPE
  ,uom                    pay_input_values_f.uom%TYPE
  ,hot_default_flag       pay_input_values_f.hot_default_flag%TYPE
  ,mandatory_flag         pay_input_values_f.mandatory_flag%TYPE
  ,warning_or_error       pay_input_values_f.warning_or_error%TYPE
  ,lookup_type            pay_input_values_f.lookup_type%TYPE
  ,value_set_id           pay_input_values_f.value_set_id%TYPE
  ,formula_id             pay_input_values_f.formula_id%TYPE
  ,min_value              pay_input_values_f.min_value%TYPE
  ,max_value              pay_input_values_f.max_value%TYPE
  ,default_value          VARCHAR2(242) -- to avoid truncation of lookup meaning + hot default quotes
);
--
fetched_entry_value     fetched_entry_value_rec;
--
v_coverage_type         ben_benefit_contributions_f.coverage_type%type := null;
v_ER_contr_default      ben_benefit_contributions_f.employer_contribution%type := null;
v_EE_contr_default      ben_benefit_contributions_f.employee_contribution%type := null;
--
cursor BENEFIT_PLAN_DEFAULTS is
        --
        select  employee_contribution,
                employer_contribution
                --
        from    ben_benefit_contributions_f
                --
        where   p_effective_date between effective_start_date
                                        and effective_end_date
        and     element_type_id = p_element_type_id
        and     business_group_id = p_business_group_id
        and     coverage_type = v_coverage_type;
        --
cursor SET_OF_ENTRY_VALUES is
        --
        select  entry.element_entry_value_id,
                entry.screen_entry_value,
                entry.input_value_id,
                type_tl.name,
                type.uom,
                type.hot_default_flag,
                type.mandatory_flag,
                decode (type.hot_default_flag,
                        'N', link.warning_or_error,
                        nvl (link.warning_or_error,
                                type.warning_or_error)) WARNING_OR_ERROR,
                type.lookup_type,
                type.value_set_id,
                type.formula_id,
                decode(type.hot_default_flag,'N',link.min_value,
                       nvl(link.min_value,type.min_value)) MIN_VALUE,
                decode(type.hot_default_flag,'N',link.max_value,
                       nvl(link.max_value,type.max_value)) MAX_VALUE,
                decode (type.hot_default_flag,
                        'N', link.default_value,
                                nvl (link.default_value,
                                        type.default_value))    DEFAULT_VALUE
        from    pay_element_entry_values_f      ENTRY,
                pay_link_input_values_f         LINK,
                pay_input_values_f_tl           TYPE_TL,
                pay_input_values_f              TYPE
        where   entry.element_entry_id = p_element_entry_id
        and     link.element_link_id = p_element_link_id
        and     link.input_value_id = entry.input_value_id
        and     type.input_value_id = entry.input_value_id
        and     type_tl.input_value_id = type.input_value_id
        and     userenv('LANG') = type_tl.language
        and     p_effective_date between link.effective_start_date
                                        and link.effective_end_date
        -- Bugfix 4438706
        -- Fetch the entry values that match the effective start and end
        -- dates of the entry, not the ones as at the effective date (could
        -- be the wrong values if form is running in QuickPay mode).
--      and     p_effective_date between entry.effective_start_date
--                                      and entry.effective_end_date
        and     entry.effective_start_date = p_ee_effective_start_date
        and     entry.effective_end_date = p_ee_effective_end_date
        and     p_effective_date between type.effective_start_date
                                        and type.effective_end_date
        order by type.display_sequence, type_tl.name;
        --
entry_value_number      integer;
--
begin
--
-- Retrieve all the existing element entry values for the element entry
--
-- Bugfix 468639
-- fetch set_of_entry_values into pre-defined record fetched_entry_values
-- in order to allow lookup meanings to be held as 80 character strings
--
OPEN set_of_entry_values;
LOOP
  FETCH set_of_entry_values INTO fetched_entry_value;
  EXIT WHEN set_of_entry_values%NOTFOUND;
  --
  entry_value_number := set_of_entry_values%rowcount; -- loop index flag
  --
  -- If the element is a type A benefit plan, then replace the
  -- element type/link level defaults with the defaults retrieved
  -- from ben_benefit_contributions_f.
  --
  if p_contributions_used = 'Y' then
    --
    -- If the element is a type A benefit plan then get the
    -- default values for the EE Contr and ER Contr input values
    -- NB The 'Coverage' input value will always be ordered before
    -- the ER/EE Contr input values.
    --
    if fetched_entry_value.name = 'Coverage' then
      --
      v_coverage_type := fetched_entry_value.screen_entry_value;
      open benefit_plan_defaults;
      fetch benefit_plan_defaults into v_EE_contr_default, v_ER_contr_default;
      close benefit_plan_defaults;
      --
    elsif fetched_entry_value.name = 'EE Contr' then
      --
      fetched_entry_value.hot_default_flag := 'Y';
      fetched_entry_value.default_value := v_EE_contr_default;
                                                --
    elsif fetched_entry_value.name = 'ER Contr' then
      --
      fetched_entry_value.hot_default_flag := 'Y';
      fetched_entry_value.default_value := v_ER_contr_default;
                                                --
    end if;
    --
  end if;
    --
  if fetched_entry_value.lookup_type is null
    and fetched_entry_value.value_set_id is null
  then
    --
    -- If the entry value is not a lookup, then format it for display
    --
--
-- sbilling
-- PAY_ELEMENT_ENTRY_VALUES_F.screen_entry_value is stored as varchar2(60),
-- hr_chkfmt.changeformat() could return a 80 byte string which
-- will not fit on PAY_ELEMENT_ENTRY_VALUES_F.screen_entry_value,
-- therefore use substrb() to truncate this to 60 characters before
-- storing on dB,
-- nb. substrb() must be used as the dB could be set up as multibyte,
--     in which case each byte must be returned as 2 bytes
--
    fetched_entry_value.screen_entry_value :=
                                substrb(hr_chkfmt.changeformat(
                                fetched_entry_value.screen_entry_value,
                                fetched_entry_value.uom,
                                p_input_currency_code), 1, 60);
    --
    fetched_entry_value.default_value := hr_chkfmt.changeformat(
                                fetched_entry_value.default_value,
                                fetched_entry_value.uom,
                                p_input_currency_code);
   --
	elsif fetched_entry_value.lookup_type is not null then
    --
    -- If the entry value is a lookup, then decode it for display
    --
    fetched_entry_value.default_value := hr_general.decode_lookup(
                                fetched_entry_value.lookup_type,
                                fetched_entry_value.default_value);
    --
--
-- sbilling
-- same argument as above
--
-- Bugfix 468639
-- substrb at 80 chars in order to retain full lookup meaning
--
    fetched_entry_value.screen_entry_value :=
                                substrb( hr_general.decode_lookup(
                                fetched_entry_value.lookup_type,
                                fetched_entry_value.screen_entry_value), 1, 80);
                                                        --
  elsif fetched_entry_value.value_set_id is not null then
    --
    -- If the entry value is a value set value, then decode it for display
    --
    fetched_entry_value.default_value :=
      pay_input_values_pkg.decode_vset_value(
				fetched_entry_value.value_set_id,
				fetched_entry_value.default_value);
    --
    fetched_entry_value.screen_entry_value :=
      pay_input_values_pkg.decode_vset_value(
				fetched_entry_value.value_set_id,
				fetched_entry_value.screen_entry_value);
    --
  end if;
  --
  -- If the default value is hot-defaulted, then denote it with speech marks
  --
  if fetched_entry_value.hot_default_flag = 'Y'
  and fetched_entry_value.default_value is not null then
    fetched_entry_value.default_value := '"'||fetched_entry_value.default_value||'"';
  end if;
    --
  if entry_value_number = 1 then
    --
    -- Assign the out parameters
    --
    p_entry_value_id1           := fetched_entry_value.element_entry_value_id;
    p_screen_entry_value1       := fetched_entry_value.screen_entry_value;
    p_input_value_id1           := fetched_entry_value.input_value_id;
    p_uom1                      := fetched_entry_value.uom;
    p_name1                     := fetched_entry_value.name;
    p_hot_default_flag1         := fetched_entry_value.hot_default_flag;
    p_mandatory_flag1           := fetched_entry_value.mandatory_flag;
    p_warning_or_error1         := fetched_entry_value.warning_or_error;
    p_lookup_type1              := fetched_entry_value.lookup_type;
    p_value_set_id1             := fetched_entry_value.value_set_id;
    p_formula_id1               := fetched_entry_value.formula_id;
    p_min_value1        := fetched_entry_value.min_value;
    p_max_value1        := fetched_entry_value.max_value;
    p_default_value1    := fetched_entry_value.default_value;
    --
  elsif entry_value_number =2 then
    --
    p_entry_value_id2   := fetched_entry_value.element_entry_value_id;
    p_screen_entry_value2       := fetched_entry_value.screen_entry_value;
    p_input_value_id2   := fetched_entry_value.input_value_id;
    p_uom2              := fetched_entry_value.uom;
    p_name2             := fetched_entry_value.name;
    p_hot_default_flag2 := fetched_entry_value.hot_default_flag;
    p_mandatory_flag2   := fetched_entry_value.mandatory_flag;
    p_warning_or_error2 := fetched_entry_value.warning_or_error;
    p_lookup_type2      := fetched_entry_value.lookup_type;
    p_value_set_id2     := fetched_entry_value.value_set_id;
    p_formula_id2       := fetched_entry_value.formula_id;
    p_min_value2        := fetched_entry_value.min_value;
    p_max_value2        := fetched_entry_value.max_value;
    p_default_value2    := fetched_entry_value.default_value;
  --
  elsif entry_value_number =3 then
--
    p_entry_value_id3   := fetched_entry_value.element_entry_value_id;
    p_screen_entry_value3       := fetched_entry_value.screen_entry_value;
    p_input_value_id3   := fetched_entry_value.input_value_id;
    p_uom3              := fetched_entry_value.uom;
    p_name3             := fetched_entry_value.name;
    p_hot_default_flag3 := fetched_entry_value.hot_default_flag;
    p_mandatory_flag3   := fetched_entry_value.mandatory_flag;
    p_warning_or_error3 := fetched_entry_value.warning_or_error;
    p_lookup_type3      := fetched_entry_value.lookup_type;
    p_value_set_id3     := fetched_entry_value.value_set_id;
    p_formula_id3       := fetched_entry_value.formula_id;
    p_min_value3        := fetched_entry_value.min_value;
    p_max_value3        := fetched_entry_value.max_value;
    p_default_value3    := fetched_entry_value.default_value;
  --
  elsif entry_value_number =4 then
--
    p_entry_value_id4   := fetched_entry_value.element_entry_value_id;
    p_screen_entry_value4       := fetched_entry_value.screen_entry_value;
    p_input_value_id4   := fetched_entry_value.input_value_id;
    p_uom4              := fetched_entry_value.uom;
    p_name4             := fetched_entry_value.name;
    p_hot_default_flag4 := fetched_entry_value.hot_default_flag;
    p_mandatory_flag4   := fetched_entry_value.mandatory_flag;
    p_warning_or_error4 := fetched_entry_value.warning_or_error;
    p_lookup_type4      := fetched_entry_value.lookup_type;
    p_value_set_id4     := fetched_entry_value.value_set_id;
    p_formula_id4       := fetched_entry_value.formula_id;
    p_min_value4        := fetched_entry_value.min_value;
    p_max_value4        := fetched_entry_value.max_value;
    p_default_value4    := fetched_entry_value.default_value;
--
  elsif entry_value_number =5 then
--
    p_entry_value_id5   := fetched_entry_value.element_entry_value_id;
    p_screen_entry_value5       := fetched_entry_value.screen_entry_value;
    p_input_value_id5   := fetched_entry_value.input_value_id;
    p_uom5              := fetched_entry_value.uom;
    p_name5             := fetched_entry_value.name;
    p_hot_default_flag5 := fetched_entry_value.hot_default_flag;
    p_mandatory_flag5   := fetched_entry_value.mandatory_flag;
    p_warning_or_error5 := fetched_entry_value.warning_or_error;
    p_lookup_type5      := fetched_entry_value.lookup_type;
    p_value_set_id5     := fetched_entry_value.value_set_id;
    p_formula_id5       := fetched_entry_value.formula_id;
    p_min_value5        := fetched_entry_value.min_value;
    p_max_value5        := fetched_entry_value.max_value;
    p_default_value5    := fetched_entry_value.default_value;
--
  elsif entry_value_number =6 then
--
    p_entry_value_id6   := fetched_entry_value.element_entry_value_id;
    p_screen_entry_value6       := fetched_entry_value.screen_entry_value;
    p_input_value_id6   := fetched_entry_value.input_value_id;
    p_uom6              := fetched_entry_value.uom;
    p_name6             := fetched_entry_value.name;
    p_hot_default_flag6 := fetched_entry_value.hot_default_flag;
    p_mandatory_flag6   := fetched_entry_value.mandatory_flag;
    p_warning_or_error6 := fetched_entry_value.warning_or_error;
    p_lookup_type6      := fetched_entry_value.lookup_type;
    p_value_set_id6     := fetched_entry_value.value_set_id;
    p_formula_id6       := fetched_entry_value.formula_id;
    p_min_value6        := fetched_entry_value.min_value;
    p_max_value6        := fetched_entry_value.max_value;
    p_default_value6    := fetched_entry_value.default_value;
--
  elsif entry_value_number =7 then
--
    p_entry_value_id7   := fetched_entry_value.element_entry_value_id;
    p_screen_entry_value7       := fetched_entry_value.screen_entry_value;
    p_input_value_id7   := fetched_entry_value.input_value_id;
    p_uom7              := fetched_entry_value.uom;
    p_name7             := fetched_entry_value.name;
    p_hot_default_flag7 := fetched_entry_value.hot_default_flag;
    p_mandatory_flag7   := fetched_entry_value.mandatory_flag;
    p_warning_or_error7 := fetched_entry_value.warning_or_error;
    p_lookup_type7      := fetched_entry_value.lookup_type;
    p_value_set_id7     := fetched_entry_value.value_set_id;
    p_formula_id7       := fetched_entry_value.formula_id;
    p_min_value7        := fetched_entry_value.min_value;
    p_max_value7        := fetched_entry_value.max_value;
    p_default_value7    := fetched_entry_value.default_value;
--
  elsif entry_value_number =8 then
--
    p_entry_value_id8   := fetched_entry_value.element_entry_value_id;
    p_screen_entry_value8       := fetched_entry_value.screen_entry_value;
    p_input_value_id8   := fetched_entry_value.input_value_id;
    p_uom8              := fetched_entry_value.uom;
    p_name8             := fetched_entry_value.name;
    p_hot_default_flag8 := fetched_entry_value.hot_default_flag;
    p_mandatory_flag8   := fetched_entry_value.mandatory_flag;
    p_warning_or_error8 := fetched_entry_value.warning_or_error;
    p_lookup_type8      := fetched_entry_value.lookup_type;
    p_value_set_id8     := fetched_entry_value.value_set_id;
    p_formula_id8       := fetched_entry_value.formula_id;
    p_min_value8        := fetched_entry_value.min_value;
    p_max_value8        := fetched_entry_value.max_value;
    p_default_value8    := fetched_entry_value.default_value;
--
  elsif entry_value_number =9 then
--
    p_entry_value_id9   := fetched_entry_value.element_entry_value_id;
    p_screen_entry_value9       := fetched_entry_value.screen_entry_value;
    p_input_value_id9   := fetched_entry_value.input_value_id;
    p_uom9              := fetched_entry_value.uom;
    p_name9             := fetched_entry_value.name;
    p_hot_default_flag9 := fetched_entry_value.hot_default_flag;
    p_mandatory_flag9   := fetched_entry_value.mandatory_flag;
    p_warning_or_error9 := fetched_entry_value.warning_or_error;
    p_lookup_type9      := fetched_entry_value.lookup_type;
    p_value_set_id9     := fetched_entry_value.value_set_id;
    p_formula_id9       := fetched_entry_value.formula_id;
    p_min_value9        := fetched_entry_value.min_value;
    p_max_value9        := fetched_entry_value.max_value;
    p_default_value9    := fetched_entry_value.default_value;
--
  elsif entry_value_number =10 then
--
    p_entry_value_id10          := fetched_entry_value.element_entry_value_id;
    p_screen_entry_value10      := fetched_entry_value.screen_entry_value;
    p_input_value_id10          := fetched_entry_value.input_value_id;
    p_uom10                     := fetched_entry_value.uom;
    p_name10                    := fetched_entry_value.name;
    p_hot_default_flag10        := fetched_entry_value.hot_default_flag;
    p_mandatory_flag10          := fetched_entry_value.mandatory_flag;
    p_warning_or_error10        := fetched_entry_value.warning_or_error;
    p_lookup_type10             := fetched_entry_value.lookup_type;
    p_value_set_id10            := fetched_entry_value.value_set_id;
    p_formula_id10              := fetched_entry_value.formula_id;
    p_min_value10       := fetched_entry_value.min_value;
    p_max_value10       := fetched_entry_value.max_value;
    p_default_value10   := fetched_entry_value.default_value;
--
  elsif entry_value_number =11 then
--
    p_entry_value_id11          := fetched_entry_value.element_entry_value_id;
    p_screen_entry_value11      := fetched_entry_value.screen_entry_value;
    p_input_value_id11          := fetched_entry_value.input_value_id;
    p_uom11                     := fetched_entry_value.uom;
    p_name11                    := fetched_entry_value.name;
    p_hot_default_flag11        := fetched_entry_value.hot_default_flag;
    p_mandatory_flag11          := fetched_entry_value.mandatory_flag;
    p_warning_or_error11        := fetched_entry_value.warning_or_error;
    p_lookup_type11             := fetched_entry_value.lookup_type;
    p_value_set_id11            := fetched_entry_value.value_set_id;
    p_formula_id11              := fetched_entry_value.formula_id;
    p_min_value11       := fetched_entry_value.min_value;
    p_max_value11       := fetched_entry_value.max_value;
    p_default_value11   := fetched_entry_value.default_value;
--
  elsif entry_value_number =12 then
--
    p_entry_value_id12          := fetched_entry_value.element_entry_value_id;
    p_screen_entry_value12      := fetched_entry_value.screen_entry_value;
    p_input_value_id12          := fetched_entry_value.input_value_id;
    p_uom12                     := fetched_entry_value.uom;
    p_name12                    := fetched_entry_value.name;
    p_hot_default_flag12        := fetched_entry_value.hot_default_flag;
    p_mandatory_flag12          := fetched_entry_value.mandatory_flag;
    p_warning_or_error12        := fetched_entry_value.warning_or_error;
    p_lookup_type12             := fetched_entry_value.lookup_type;
    p_value_set_id12            := fetched_entry_value.value_set_id;
    p_formula_id12              := fetched_entry_value.formula_id;
    p_min_value12       := fetched_entry_value.min_value;
    p_max_value12       := fetched_entry_value.max_value;
    p_default_value12   := fetched_entry_value.default_value;
--
  elsif entry_value_number =13 then
--
    p_entry_value_id13          := fetched_entry_value.element_entry_value_id;
    p_screen_entry_value13      := fetched_entry_value.screen_entry_value;
    p_input_value_id13          := fetched_entry_value.input_value_id;
    p_uom13                     := fetched_entry_value.uom;
    p_name13                    := fetched_entry_value.name;
    p_hot_default_flag13        := fetched_entry_value.hot_default_flag;
    p_mandatory_flag13          := fetched_entry_value.mandatory_flag;
    p_warning_or_error13        := fetched_entry_value.warning_or_error;
    p_lookup_type13             := fetched_entry_value.lookup_type;
    p_value_set_id13            := fetched_entry_value.value_set_id;
    p_formula_id13              := fetched_entry_value.formula_id;
    p_min_value13       := fetched_entry_value.min_value;
    p_max_value13       := fetched_entry_value.max_value;
    p_default_value13   := fetched_entry_value.default_value;
--
  elsif entry_value_number =14 then
--
    p_entry_value_id14          := fetched_entry_value.element_entry_value_id;
    p_screen_entry_value14      := fetched_entry_value.screen_entry_value;
    p_input_value_id14          := fetched_entry_value.input_value_id;
    p_uom14                     := fetched_entry_value.uom;
    p_name14                    := fetched_entry_value.name;
    p_hot_default_flag14        := fetched_entry_value.hot_default_flag;
    p_mandatory_flag14          := fetched_entry_value.mandatory_flag;
    p_warning_or_error14        := fetched_entry_value.warning_or_error;
    p_lookup_type14             := fetched_entry_value.lookup_type;
    p_value_set_id14            := fetched_entry_value.value_set_id;
    p_formula_id14              := fetched_entry_value.formula_id;
    p_min_value14       := fetched_entry_value.min_value;
    p_max_value14       := fetched_entry_value.max_value;
    p_default_value14   := fetched_entry_value.default_value;
--
  elsif entry_value_number =15 then
--
    p_entry_value_id15          := fetched_entry_value.element_entry_value_id;
    p_screen_entry_value15      := fetched_entry_value.screen_entry_value;
    p_input_value_id15          := fetched_entry_value.input_value_id;
    p_uom15                     := fetched_entry_value.uom;
    p_name15                    := fetched_entry_value.name;
    p_hot_default_flag15        := fetched_entry_value.hot_default_flag;
    p_mandatory_flag15          := fetched_entry_value.mandatory_flag;
    p_warning_or_error15        := fetched_entry_value.warning_or_error;
    p_lookup_type15             := fetched_entry_value.lookup_type;
    p_value_set_id15            := fetched_entry_value.value_set_id;
    p_formula_id15              := fetched_entry_value.formula_id;
    p_min_value15       := fetched_entry_value.min_value;
    p_max_value15       := fetched_entry_value.max_value;
    p_default_value15   := fetched_entry_value.default_value;
    --
  else
    exit;
--
  end if;
--
end LOOP;
--
CLOSE set_of_entry_values;
--
end get_entry_value_details;
-------------------------------------------------------------------------------
function get_original_date_earned (
--
-- get_original_date_earned added as part of Enhancement 3665715.
-- Returns the original date earned date pertaining to a retropay entry.
--
p_element_entry_id in number) return date
--
is
--
  l_original_date_earned date;
--
  cursor csr_original_date_earned (ee_id number) is
  select PAY_ACT.date_earned
  from   pay_entry_process_details ENTRY_PROC,
         pay_assignment_actions ASGT_ACT,
         pay_payroll_actions PAY_ACT
  where  ENTRY_PROC.element_entry_id = ee_id
  and    ENTRY_PROC.source_asg_action_id = ASGT_ACT.assignment_action_id
  and    ASGT_ACT.payroll_action_id = PAY_ACT.payroll_action_id;
--
begin
--
  open csr_original_date_earned (p_element_entry_id);
  fetch csr_original_date_earned into l_original_date_earned;
  close csr_original_date_earned;
--
  return l_original_date_earned;
--
end get_original_date_earned;
-------------------------------------------------------------------------------
end PAY_PAYWSMEE_PKG;

/
