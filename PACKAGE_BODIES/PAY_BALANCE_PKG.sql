--------------------------------------------------------
--  DDL for Package Body PAY_BALANCE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_BALANCE_PKG" as
-- $Header: pybaluex.pkb 120.38.12010000.7 2010/02/02 11:41:19 asnell ship $
-- Declare tables:
type con_name_array is table of ff_contexts.context_name%type
                       index by binary_integer;
type con_num_array  is table of ff_contexts.context_id%type
                       index by binary_integer;
type con_type_array is table of ff_contexts.data_type%type
                       index by binary_integer;
type con_val_array  is table of pay_run_result_values.result_value%type
                       index by binary_integer;
type par_val_array  is table of varchar2(80)
                       index by binary_integer;
type number_array  is table of number
                       index by binary_integer;
--
con_name_tab    con_name_array;
con_id_tab      con_num_array;
con_type_tab    con_type_array;
con_value_tab   con_val_array;
--
no_rows_con_tab binary_integer := 0;
--
-- Cache for Route contexts
--
type route_contexts_cache_type is record
(
 cxt_id                    number_array,
 sz                        number
);
route_contexts_cache route_contexts_cache_type;
--
-- Cache for Route Parameters
--
type route_parameters_cache_type is record
(
 seq_no                    number_array,
 par_val                   par_val_array,
 sz                        number
);
route_parameters_cache route_parameters_cache_type;
--
-- The following type and varable are used for Dynamic SQL
--
MAX_DYN_SQL_SIZE number := 20000;
MAX_TRACE_SIZE   number := 255;
--
-- The follow types and variables are used to map core contexts
-- onto legislative contexts.
--
type t_context_map_rec is record
(core_context_name     ff_contexts.context_name%type,
 loc_context_name      pay_legislation_contexts.legislation_name%type
);
--
type t_context_map_tab is table of t_context_map_rec index by binary_integer;
--
g_legislation_code per_business_groups_perf.legislation_code%type;
g_context_mapping  t_context_map_tab;
--
-- tables for dimension cache
--
type t_def_bal_rec is record
(dimension_type       pay_balance_dimensions.dimension_type%type,
 expiry_check_code    pay_balance_dimensions.expiry_checking_code%type,
 expiry_check_lvl     pay_balance_dimensions.expiry_checking_level%type,
 dimension_name       pay_balance_dimensions.dimension_name%type,
 jurisdiction_lvl     pay_balance_types.jurisdiction_level%type,
 balance_type_column  pay_dimension_routes.balance_type_column%type,
 decode_required      pay_dimension_routes.decode_required%type,
 balance_dimension_id pay_balance_dimensions.balance_dimension_id%type,
 dimension_lvl        pay_balance_dimensions.dimension_level%type,
 period_type          pay_balance_dimensions.period_type%type,
 balance_type_id      pay_balance_types.balance_type_id%type,
 dim_rou_rr_route_id  pay_dimension_routes.route_id%type,
 tu_needed            boolean,
 jc_needed            boolean,
 si_needed            boolean,
 sn_needed            boolean,
 st_needed            boolean,
 st2_needed           boolean,
 td_needed            boolean,
 bd_needed            boolean,
 lu_needed            boolean,
 sn2_needed           boolean,
 org_needed           boolean,
 start_rb_ptr         number,
 end_rb_ptr           number,
 rr_ptr               number
);
--
type t_def_bal_tab is table of t_def_bal_rec index by binary_integer;
--
g_debug boolean := hr_utility.debug_enabled;
g_defbal_cache t_def_bal_tab;
--
--
-- tables for dimension route cache
--
type t_dim_rou_rec is record
(
 balance_dimension_id pay_balance_dimensions.balance_dimension_id%type,
 priority             pay_dimension_routes.priority%type,
 route_type           pay_dimension_routes.route_type%type,
 run_def_bal_id       pay_defined_balances.defined_balance_id%type,
 retrieval_column     pay_dimension_routes.retrieval_column%type
);
--
type t_dim_rou_tab is table of t_dim_rou_rec index by binary_integer;
--
g_dimrou_cache t_dim_rou_tab;
--
--
-- Internal cache type for batch retrieval
--
type t_int_bal_rec is record
(
 defined_balance_id   pay_defined_balances.defined_balance_id%type,
 balance_dimension_id pay_balance_dimensions.balance_dimension_id%type,
 balance_type_id      pay_balance_types.balance_type_id%type,
 balance_found        boolean,
 balance_value        number,
 jurisdiction_level   pay_balance_types.jurisdiction_level%type,
 tax_unit_id          pay_assignment_actions.tax_unit_id%type,
 jurisdiction_code    pay_run_results.jurisdiction_code%type,
 source_id            number,
 source_text          pay_run_result_values.result_value%type,
 source_number        number,
 source_text2         pay_run_result_values.result_value%type,
 time_def_id          pay_run_results.time_definition_id%type,
 balance_date         pay_run_results.end_date%type,
 original_entry_id    number,
 local_unit_id        pay_run_results.local_unit_id%type,
 source_number2       number,
 organization_id      number
);
--
type t_int_bal_cache is table of t_int_bal_rec index by binary_integer;
--
-- Internal Run Balance link list used in rollback
--
type t_int_rb_rec is record
(
 run_balance_id       pay_run_balances.run_balance_id%type,
 defined_balance_id   pay_defined_balances.defined_balance_id%type,
 payroll_action_id    pay_payroll_actions.payroll_action_id%type,
 tax_unit_id          pay_assignment_actions.tax_unit_id%type,
 jurisdiction_code    pay_run_results.jurisdiction_code%type,
 source_id            number,
 source_text          pay_run_result_values.result_value%type,
 source_number        number,
 source_text2         pay_run_result_values.result_value%type,
 time_def_id          pay_run_results.time_definition_id%type,
 balance_date         pay_run_results.end_date%type,
 local_unit_id        pay_run_results.local_unit_id%type,
 source_number2       number,
 organization_id      number,
 next                 number
);
--
type t_int_rb_cache is table of t_int_rb_rec index by binary_integer;
--
-- Batch retrieval cache.
--
type t_batch_rec is record
(
 balance_type_id  pay_balance_types.balance_type_id%type,
 balance_value    number,
 source_index     number   -- This is used to index back to the
                           -- original PL/SQL table.
);
--
type t_batch_list is table of t_batch_rec index by binary_integer;
--
--
-- Number array
--
type number_tab is table of number index by binary_integer;
--
--
-- Context Details cache
--
type t_context_details_rec is record
(
  tax_unit_id           pay_assignment_actions.tax_unit_id%type,
  jurisdiction_code     pay_run_results.jurisdiction_code%type,
  source_id             pay_run_result_values.result_value%type,
  source_text           pay_run_result_values.result_value%type,
  source_number         pay_run_result_values.result_value%type,
  source_text2          pay_run_result_values.result_value%type,
  time_def_id           pay_run_results.time_definition_id%type,
  balance_date          pay_run_results.end_date%type,
  local_unit_id        pay_run_results.local_unit_id%type,
  source_number2       number,
  organization_id      number,
  prv_tax_unit_id       pay_assignment_actions.tax_unit_id%type,
  prv_jurisdiction_code pay_run_results.jurisdiction_code%type,
  prv_source_id         pay_run_result_values.result_value%type,
  prv_source_text       pay_run_result_values.result_value%type,
  prv_source_number     pay_run_result_values.result_value%type,
  prv_source_text2      pay_run_result_values.result_value%type,
  prv_time_def_id       pay_run_results.time_definition_id%type,
  prv_balance_date      pay_run_results.end_date%type,
  prv_local_unit_id     pay_run_results.local_unit_id%type,
  prv_source_number2    number,
  prv_organization_id   number,
  tu_needed             boolean,
  jc_needed             boolean,
  si_needed             boolean,
  st_needed             boolean,
  sn_needed             boolean,
  st2_needed            boolean,
  td_needed             boolean,
  bd_needed             boolean,
  lu_needed             boolean,
  sn2_needed            boolean,
  org_needed            boolean,
  tu_set                boolean,
  jc_set                boolean,
  si_set                boolean,
  st_set                boolean,
  sn_set                boolean,
  st2_set               boolean,
  td_set                boolean,
  bd_set                boolean,
  lu_set                boolean,
  sn2_set               boolean,
  org_set               boolean
);
--
-- Run result record
--
type t_run_result_rec is record
 (run_result_id          number
 ,element_type_id        number
 ,jurisdiction_code      pay_run_results.jurisdiction_code%type
 ,assignment_action_id   number
 ,assignment_id          number
 ,tax_unit_id            number
 ,payroll_action_id      number
 ,time_def_id            pay_run_results.time_definition_id%type
 ,balance_date           pay_run_results.end_date%type
 ,local_unit_id          pay_run_results.local_unit_id%type
 ,source_number2         number
 ,organization_id        number
 ,business_group_id      number
 ,legislation_code       per_business_groups.legislation_code%type
 ,effective_date         date
 );
--
-- Cache parameters for new_defined_balance
--
cached       boolean  := FALSE;
g_low_volume pay_action_parameters.parameter_value%type := 'N';
--
-- tables for expiry_checking cache
--
type pay_act_id_tab is table of pay_payroll_actions.payroll_action_id%type
                       index by binary_integer;
type expiry_tab     is table of NUMBER(38) index by binary_integer;
type dim_nm_tab    is table of pay_balance_dimensions.dimension_name%type
                      index by binary_integer;
--
t_own_pay_action   pay_act_id_tab;
t_usr_pay_action   pay_act_id_tab;
t_dim_nm           dim_nm_tab;
t_expiry           expiry_tab;
--
-- The following globals are used in remove_asg_contrib
g_payroll_action       pay_payroll_actions.payroll_action_id%type;
g_rlb_grp_defbals      t_balance_value_tab;
g_rlb_asg_defbals      t_balance_value_tab;
g_grp_maintained_rb    t_int_rb_cache;
g_grp_rb_ptr_list      number_array;
g_si_needed_chr        pay_legislation_rules.rule_mode%type;
g_st_needed_chr        pay_legislation_rules.rule_mode%type;
g_sn_needed_chr        pay_legislation_rules.rule_mode%type;
g_st2_needed_chr       pay_legislation_rules.rule_mode%type;
g_sn2_needed_chr       pay_legislation_rules.rule_mode%type;
g_org_needed_chr       pay_legislation_rules.rule_mode%type;
g_save_run_bals        pay_legislation_rules.rule_mode%type;
--
-- The following globals are used in get_rb_status
g_aa_id                NUMBER := NULL;
g_retrieval_date       pay_payroll_actions.effective_date%type := NULL;
g_bus_grp_id           pay_payroll_actions.business_group_id%type := NULL;
g_payroll_id           pay_payroll_actions.payroll_id%type := NULL;
g_action_type          pay_payroll_actions.action_type%type := NULL;
--
-- Run result record, used in get_run_result_info.
g_run_result_rec         t_run_result_rec;
--
g_oracle_version       NUMBER; -- holds the oracle version number and is
                               -- set by get_oracle_db_version
--
-- Setup the internal context settings
--
g_con_tax_unit_id         pay_latest_balances.tax_unit_id%type;
g_con_jurisdiction_code   pay_latest_balances.jurisdiction_code%type;
g_con_original_entry_id   pay_latest_balances.original_entry_id%type;
g_con_source_id           pay_latest_balances.source_id%type;
g_con_source_text         pay_latest_balances.source_text%type;
g_con_source_text2        pay_latest_balances.source_text2%type;
g_con_source_number       pay_latest_balances.source_number%type;
g_con_tax_group           pay_latest_balances.tax_group%type;
g_con_payroll_id          pay_latest_balances.payroll_id%type;
g_con_local_unit_id       pay_latest_balances.local_unit_id%type;
g_con_organization_id     pay_latest_balances.organization_id%type;
g_con_source_number2      pay_latest_balances.source_number2%type;
--
-- Copy of Hr_General2.get_oracle_db_version to avoid a very nasty patching
-- issue in the c-code chain.
--  Bug 2865665.
-- --------------------------------------------------------------------------
-- |-------------------< get_oracle_db_version >----------------------------|
-- --------------------------------------------------------------------------
-- This function returns the current (major) ORACLE version number in the
-- format x.x (where x is a number):
-- e.g. 8.0, 8.1, 9.0, 9.1
-- If for any reason the version number cannot be identified, NULL is
-- returned
FUNCTION get_oracle_db_version RETURN NUMBER IS
  l_proc          VARCHAR2(72);
  l_version       VARCHAR2(30);
  l_compatibility VARCHAR2(30);
BEGIN
  g_debug := hr_utility.debug_enabled;
  IF g_debug THEN
    l_proc := 'pay_balance_pkg.get_oracle_db_version';
    hr_utility.set_location('Entering:'||l_proc, 5);
  END IF;
  -- check to see if the g_oracle_version already exists
  IF g_oracle_version IS NULL THEN
    -- get the current ORACLE version and compatibility values
    dbms_utility.db_version(l_version, l_compatibility);
    -- the oracle version number is held in the format:
    -- x.x.x.x.x
    -- set the version number to the first decimal position
    -- e.g. 9.1.2.0.0 returns 9.1
    --      9.0.1.2.0 returns 9.0
    --      8.1.7.3.0 returns 8.1
    --      8.0.2.1.0 returns 8.0
    --
    -- modified line below to include a NUMBER format model to get
    -- around, numeric format problems which have been identified
    -- in wwbug 2772209
    -- note: an important assumption is made here; the oracle
    -- version is always returned with a period '.' as a seperator
    -- regardless of NLS.
    g_oracle_version :=
      TO_NUMBER(SUBSTRB(l_version,1,INSTRB(l_version,'.',1,2)-1),'99.99');
  END IF;
  IF g_debug THEN
    hr_utility.set_location('Leaving:'||l_proc, 10);
  END IF;
  -- return the value
  RETURN(g_oracle_version);
EXCEPTION
  WHEN OTHERS THEN
    -- an unexpected error was raised and is most probably caused by
    -- the TO_NUMBER conversion. Because of this, return NULL
    -- indicating that the Oracle Version number could NOT be assertained
    IF g_debug THEN
       hr_utility.set_location('Leaving:'||l_proc, 15);
    END IF;
    RETURN(NULL);
END get_oracle_db_version;
--
--------------------------------------------------------------------------
-- procedure split_jurisdiction
--------------------------------------------------------------------------
procedure split_jurisdiction(p_jurisdiction in            varchar2,
                             p_jur1         in out nocopy varchar2,
                             p_jur2         in out nocopy varchar2,
                             p_jur3         in out nocopy varchar2
                            )
is
idx number;
prev_idx number;
begin
--
    p_jur1 := null;
    p_jur2 := null;
    p_jur3 := null;
--
    if p_jurisdiction is not null then
--
      idx := instr(p_jurisdiction, '-');
--
      -- Set Comp 1
      if idx = 0 then
        p_jur1 := p_jurisdiction;
      else
--
        -- Set Comp1 and move to Comp2
        p_jur1   := substr(p_jurisdiction, 1, idx-1);
        prev_idx := idx;
        idx      := instr(p_jurisdiction, '-', prev_idx+1);
--
        if idx = 0 then
           p_jur2 := substr(p_jurisdiction, prev_idx+1);
        else
           p_jur2 := substr(p_jurisdiction, prev_idx+1, idx -1 - prev_idx);
           p_jur3 := substr(p_jurisdiction, idx+1);
        end if;
      end if;
--
    end if;
--
end split_jurisdiction;
--
--------------------------- get_period_type_start -------------------------------
 /* Name    : get_period_type_start
  Purpose   : This returns the start date of a period type given an
              effective_date.
  Arguments :
       p_period_type is mandatory
       p_effective_date is mandatory
       p_start_date_code is only required for period_type DYNAMIC
       p_payroll_id is only required for period_type PERIOD
       p_bus_grp is only needed for period_type TYEAR, TQUARTER, FYEAR and
                 FQUARTER
       p_action_type is only needed for period_type PAYMENT
       p_asg_action is only needed for period_type PAYMENT
  Notes     :
 */
procedure get_period_type_start(p_period_type    in            varchar2,
                               p_effective_date  in            date,
                               p_start_date         out nocopy date,
                               p_start_date_code in            varchar2 default null,
                               p_payroll_id      in            number   default null,
                               p_bus_grp         in            number   default null,
                               p_action_type     in            varchar2 default null,
                               p_asg_action      in            number   default null)
is
l_return_date date;
l_statem              varchar2(2000);  -- used with dynamic pl/sql
sql_cursor           integer;
l_rows               integer;
begin
   g_debug := hr_utility.debug_enabled;
--
   l_return_date := to_date('0001/01/01 00:00:00', 'YYYY/MM/DD HH24:MI:SS');
--
   if (p_period_type = 'YEAR') then
--
     l_return_date := trunc(p_effective_date, 'Y');
--
   elsif (p_period_type = 'QUARTER') then
--
     l_return_date := trunc(p_effective_date, 'Q');
--
   elsif (p_period_type = 'PERIOD') then
--
     select start_date
       into l_return_date
       from per_time_periods
      where payroll_id = p_payroll_id
        and p_effective_date between start_date
                                 and end_date;
--
   elsif (p_period_type = 'MONTH') then
--
     l_return_date := trunc(p_effective_date, 'MM');
--
   elsif (p_period_type = 'RUN') then
--
     l_return_date := p_effective_date;
--
   elsif (p_period_type = 'TYEAR') then
--
     l_return_date:= pay_ip_route_support.tax_year(p_bus_grp,
                                   p_effective_date);
--
   elsif (p_period_type = 'TQUARTER') then
--
     l_return_date:= pay_ip_route_support.tax_quarter(p_bus_grp,
                                   p_effective_date);
--
   elsif (p_period_type = 'FYEAR') then
--
     l_return_date:= pay_ip_route_support.fiscal_year(p_bus_grp,
                                   p_effective_date);
--
   elsif (p_period_type = 'FQUARTER') then
--
     l_return_date:= pay_ip_route_support.fiscal_quarter(p_bus_grp,
                                   p_effective_date);
--
   elsif (p_period_type = 'PAYMENT') then
--
      if (p_action_type in ('R', 'Q')) then
--
         l_return_date := p_effective_date;
--
      elsif (p_action_type in ('P', 'U')) then
--
         select min(effective_date)
           into l_return_date
           from pay_payroll_actions ppa,
                pay_assignment_actions paa,
                pay_action_interlocks pai
          where pai.locking_action_id = p_asg_action
            and pai.locked_action_id = paa.assignment_action_id
            and paa.payroll_action_id = ppa.payroll_action_id;
      else
--
          l_return_date := to_date('0001/01/01 00:00:00', 'YYYY/MM/DD HH24:MI:SS');
--
      end if;
--
   elsif (p_period_type = 'DYNAMIC') then
--
     if (p_start_date_code is null) then
       --
       -- Dynamic but no code supplied return start of time
       --
       l_return_date := to_date('0001/01/01 00:00:00', 'YYYY/MM/DD HH24:MI:SS');
     else
--
       l_statem := 'begin ' || p_start_date_code || ' (';
       l_statem := l_statem||' p_effective_date => :l_eff_date, ';
       l_statem := l_statem||' p_start_date     => :l_start_date, ';
       l_statem := l_statem||' p_payroll_id     => :l_payroll, ';
       l_statem := l_statem||' p_bus_grp        => :l_bus_grp, ';
       l_statem := l_statem||' p_asg_action     => :l_asg_act); end;  ';
--
       sql_cursor := dbms_sql.open_cursor;
       --
       dbms_sql.parse(sql_cursor, l_statem, dbms_sql.v7);
       --
       --
       dbms_sql.bind_variable(sql_cursor, 'l_eff_date',   p_effective_date);
       dbms_sql.bind_variable(sql_cursor, 'l_start_date', p_start_date);
       dbms_sql.bind_variable(sql_cursor, 'l_payroll',    p_payroll_id);
       dbms_sql.bind_variable(sql_cursor, 'l_bus_grp',    p_bus_grp);
       dbms_sql.bind_variable(sql_cursor, 'l_asg_act',    p_asg_action);
       --
       l_rows := dbms_sql.execute(sql_cursor);
       --
       if (l_rows = 1) then
          dbms_sql.variable_value(sql_cursor, 'l_start_date',
                                  l_return_date);
          dbms_sql.close_cursor(sql_cursor);
--
       else
          l_return_date := to_date('0001/01/01 00:00:00', 'YYYY/MM/DD HH24:MI:SS');
          dbms_sql.close_cursor(sql_cursor);
       end if;
--
     end if;
--
   end if;
--
   if (l_return_date is null) then
     p_start_date := to_date('0001/01/01 00:00:00', 'YYYY/MM/DD HH24:MI:SS');
   else
     p_start_date := l_return_date;
   end if;
--
end get_period_type_start;
--
--------------------------- get_period_type_end ------------------------------
--
 /* Name    : get_period_type_end
  Purpose   : This returns the end date of a period type given an
              effective_date. This should be used in conjuction
              with expiry checking.
  Arguments :
       p_period_type is mandatory
       p_effective_date is mandatory
       p_payroll_id is only required for period_type PERIOD
       p_action_type is only needed for period_type PAYMENT
       p_asg_action is only needed for period_type PAYMENT
  Notes     :
       If p_end_date is returned as null then expiry checking code
       should be used.
 */
procedure get_period_type_end(p_period_type    in            varchar2,
                               p_effective_date  in            date,
                               p_end_date           out nocopy date,
                               p_payroll_id      in            number   default null,
                               p_action_type     in            varchar2 default null,
                               p_asg_action      in            number   default null)
is
l_return_date date;
l_statem              varchar2(2000);  -- used with dynamic pl/sql
sql_cursor           integer;
l_rows               integer;
begin
   g_debug := hr_utility.debug_enabled;
--
   l_return_date := null;
--
   if (p_period_type = 'YEAR') then
--
     l_return_date := trunc(add_months(p_effective_date, 12), 'Y') -1;
--
   elsif (p_period_type = 'QUARTER') then
--
     l_return_date := trunc(add_months(p_effective_date, 3), 'Q') -1;
--
--
   elsif (p_period_type = 'PERIOD') then
--
     select end_date
       into l_return_date
       from per_time_periods
      where payroll_id = p_payroll_id
        and p_effective_date between start_date
                                 and end_date;
--
   elsif (p_period_type = 'MONTH') then
--
     l_return_date := trunc(add_months(p_effective_date, 1) , 'MM') -1;
--
   elsif (p_period_type = 'RUN') then
--
     l_return_date := p_effective_date;
--
   elsif (p_period_type = 'TYEAR') then
--
     l_return_date:= null;
--
   elsif (p_period_type = 'TQUARTER') then
--
     l_return_date:= null;
--
   elsif (p_period_type = 'FYEAR') then
--
     l_return_date:= null;
--
   elsif (p_period_type = 'FQUARTER') then
--
     l_return_date:= null;
--
   elsif (p_period_type = 'PAYMENT') then
--
      if (p_action_type in ('R', 'Q')) then
--
         l_return_date := p_effective_date;
--
      elsif (p_action_type in ('P', 'U')) then
--
         select max(effective_date)
           into l_return_date
           from pay_payroll_actions ppa,
                pay_assignment_actions paa,
                pay_action_interlocks pai
          where pai.locking_action_id = p_asg_action
            and pai.locked_action_id = paa.assignment_action_id
            and paa.payroll_action_id = ppa.payroll_action_id;
      else
--
          l_return_date := null;
--
      end if;
--
   elsif (p_period_type = 'DYNAMIC') then
--
     l_return_date := null;
--
   end if;
--
   p_end_date := l_return_date;
--
end get_period_type_end;
--
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--
--                            load_defbal_cache                           +
--                                                                        +
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
/*
NAME

        load_defbal_cache  -  Load a dimension in to the cache.

DESCRIPTION

*/
procedure load_defbal_cache(p_defined_balance_id in         number,
                            p_defbal_rec         out nocopy t_def_bal_rec)
is
--
cursor get_bal_contexts (p_def_bal_id in number) is
select context_name
from   ff_contexts             fc,
       ff_route_context_usages frcu,
       pay_balance_dimensions  pbd,
       pay_defined_balances    pdb
where  pdb.defined_balance_id = p_def_bal_id
and    pdb.balance_dimension_id = pbd.balance_dimension_id
and    pbd.route_id = frcu.route_id
and    frcu.context_id = fc.context_id;
--
cursor get_rr_route(p_def_bal_id in number) is
    select pdr.run_dimension_id
    ,      pdr.priority
    ,      pdr.route_type
    ,      null run_def_bal_id
    ,      pdr.retrieval_column
    from   pay_dimension_routes pdr
    ,      pay_defined_balances pdb -- balance defined balance
    where pdb.balance_dimension_id = pdr.balance_dimension_id
    and    pdb.defined_balance_id = p_def_bal_id
    and    pdr.route_type = 'RR';
--
CURSOR get_rb_routes(p_def_bal_id number)
IS
select pdr.run_dimension_id
,      pdr.priority
,      pdr.route_type
,      rdb.defined_balance_id run_def_bal_id
,      pdr.retrieval_column
from   pay_dimension_routes pdr
,      pay_defined_balances pdb -- balance defined balance
,      pay_defined_balances rdb -- run defined balance
where pdb.balance_dimension_id = pdr.balance_dimension_id
and    pdb.defined_balance_id = p_def_bal_id
and    rdb.balance_type_id = pdb.balance_type_id
and    rdb.balance_dimension_id = pdr.run_dimension_id
and    pdr.route_type = 'SRB'
order by 2;
--
begin
    --
    -- An on demand cache of dimension details is built, if the current
    -- defined_balance_id does not exist in the cache, then the details are
    -- returned from the original select stmt and added to the cache.
    --
    if not g_defbal_cache.exists(p_defined_balance_id) then
    --
      if g_debug then
         hr_utility.set_location ('pay_balance_pkg.load_defbal_cache', 10);
      end if;
      select DIM.dimension_type,
             DIM.expiry_checking_code,
             DIM.expiry_checking_level,
             DIM.dimension_name,
             nvl(TYP.jurisdiction_level, 0),
             DEF.balance_dimension_id,
             DEF.balance_type_id,
             DIM.dimension_level,
             DIM.period_type
      into   g_defbal_cache(p_defined_balance_id).dimension_type,
             g_defbal_cache(p_defined_balance_id).expiry_check_code,
             g_defbal_cache(p_defined_balance_id).expiry_check_lvl,
             g_defbal_cache(p_defined_balance_id).dimension_name,
             g_defbal_cache(p_defined_balance_id).jurisdiction_lvl,
             g_defbal_cache(p_defined_balance_id).balance_dimension_id,
             g_defbal_cache(p_defined_balance_id).balance_type_id,
             g_defbal_cache(p_defined_balance_id).dimension_lvl,
             g_defbal_cache(p_defined_balance_id).period_type
      from   pay_balance_dimensions         DIM
      ,      pay_defined_balances           DEF
      ,      pay_balance_types              TYP
      where  DIM.balance_dimension_id     = DEF.balance_dimension_id
      and    TYP.balance_type_id          = DEF.balance_type_id
      and    DEF.defined_balance_id       = p_defined_balance_id;
      --
      -- Now get the dimension route details
      --
      begin
        select pdr.balance_type_column,
               pdr.decode_required,
               pdr.route_id
        into   g_defbal_cache(p_defined_balance_id).balance_type_column,
               g_defbal_cache(p_defined_balance_id).decode_required,
               g_defbal_cache(p_defined_balance_id).dim_rou_rr_route_id
        from   pay_dimension_routes pdr
        ,      pay_defined_balances pdb
        where  pdb.balance_dimension_id = pdr.balance_dimension_id
        and    pdb.defined_balance_id = p_defined_balance_id
        and    pdr.route_type = 'RR';
--
      exception
        when no_data_found then
          g_defbal_cache(p_defined_balance_id).balance_type_column := NULL;
          g_defbal_cache(p_defined_balance_id).decode_required     := NULL;
          g_defbal_cache(p_defined_balance_id).dim_rou_rr_route_id := NULL;
      end;
--
      g_defbal_cache(p_defined_balance_id).tu_needed := FALSE;
      g_defbal_cache(p_defined_balance_id).jc_needed := FALSE;
      g_defbal_cache(p_defined_balance_id).si_needed := FALSE;
      g_defbal_cache(p_defined_balance_id).sn_needed := FALSE;
      g_defbal_cache(p_defined_balance_id).st_needed := FALSE;
      g_defbal_cache(p_defined_balance_id).st2_needed := FALSE;
      g_defbal_cache(p_defined_balance_id).td_needed := FALSE;
      g_defbal_cache(p_defined_balance_id).bd_needed := FALSE;
      g_defbal_cache(p_defined_balance_id).lu_needed := FALSE;
      g_defbal_cache(p_defined_balance_id).sn2_needed := FALSE;
      g_defbal_cache(p_defined_balance_id).org_needed := FALSE;
--
      -- Get the contexts needed.
      for ctrec in get_bal_contexts(p_defined_balance_id) loop
        if g_debug then
           hr_utility.set_location('pay_balance_pkg.load_defbal_cache', 10);
        end if;
        if ctrec.context_name = 'TAX_UNIT_ID' then
          g_defbal_cache(p_defined_balance_id).tu_needed := TRUE;
        end if;
        if ctrec.context_name = 'JURISDICTION_CODE' then
          g_defbal_cache(p_defined_balance_id).jc_needed := TRUE;
        end if;
        if ctrec.context_name = 'SOURCE_ID' then
          g_defbal_cache(p_defined_balance_id).si_needed := TRUE;
        end if;
        if ctrec.context_name = 'SOURCE_TEXT' then
          g_defbal_cache(p_defined_balance_id).st_needed := TRUE;
        end if;
        if ctrec.context_name = 'SOURCE_TEXT2' then
          g_defbal_cache(p_defined_balance_id).st2_needed := TRUE;
        end if;
        if ctrec.context_name = 'SOURCE_NUMBER' then
          g_defbal_cache(p_defined_balance_id).sn_needed := TRUE;
        end if;
        if ctrec.context_name = 'TIME_DEFINITION_ID' then
          g_defbal_cache(p_defined_balance_id).td_needed := TRUE;
        end if;
        if ctrec.context_name = 'BALANCE_DATE' then
          g_defbal_cache(p_defined_balance_id).bd_needed := TRUE;
        end if;
        if ctrec.context_name = 'LOCAL_UNIT_ID' then
          g_defbal_cache(p_defined_balance_id).lu_needed := TRUE;
        end if;
        if ctrec.context_name = 'SOURCE_NUMBER2' then
          g_defbal_cache(p_defined_balance_id).sn2_needed := TRUE;
        end if;
        if ctrec.context_name = 'ORGANIZATION_ID' then
          g_defbal_cache(p_defined_balance_id).org_needed := TRUE;
        end if;
      end loop;
--
      -- Now setup the dimension routes.
      declare
        l_position number;
        l_strt_position number;
        l_found    boolean;
      begin
--
        g_defbal_cache(p_defined_balance_id).start_rb_ptr := NULL;
        g_defbal_cache(p_defined_balance_id).end_rb_ptr   := NULL;
        g_defbal_cache(p_defined_balance_id).rr_ptr       := NULL;
--
        for rrrec in get_rr_route(p_defined_balance_id) loop
--
          l_position := g_dimrou_cache.count + 1;
          g_dimrou_cache(l_position).balance_dimension_id :=
                        g_defbal_cache(p_defined_balance_id).balance_dimension_id;
          g_dimrou_cache(l_position).priority             := rrrec.priority;
          g_dimrou_cache(l_position).route_type           := rrrec.route_type;
          g_dimrou_cache(l_position).run_def_bal_id       := rrrec.run_def_bal_id;
          g_dimrou_cache(l_position).retrieval_column     := rrrec.retrieval_column;
--
        end loop;
--
        g_defbal_cache(p_defined_balance_id).rr_ptr := l_position;
--
        l_found := FALSE;
        l_strt_position := g_dimrou_cache.count + 1;
        for rbrec in get_rb_routes(p_defined_balance_id) loop
--
          l_found := TRUE;
          l_position := g_dimrou_cache.count + 1;
          g_dimrou_cache(l_position).balance_dimension_id :=
                        g_defbal_cache(p_defined_balance_id).balance_dimension_id;
          g_dimrou_cache(l_position).priority             := rbrec.priority;
          g_dimrou_cache(l_position).route_type           := rbrec.route_type;
          g_dimrou_cache(l_position).run_def_bal_id       := rbrec.run_def_bal_id;
          g_dimrou_cache(l_position).retrieval_column     := rbrec.retrieval_column;
--
        end loop;
--
        if (l_found = TRUE) then
          g_defbal_cache(p_defined_balance_id).start_rb_ptr := l_strt_position;
          g_defbal_cache(p_defined_balance_id).end_rb_ptr   := l_position;
        end if;
--
      end;
--
    end if;
    if g_debug then
       hr_utility.set_location ('pay_balance_pkg.load_defbal_cache', 15);
    end if;
--
    p_defbal_rec := g_defbal_cache(p_defined_balance_id);
--
end load_defbal_cache;
--
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--
--                            chk_context                                 +
--                                                                        +
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
/*
NAME

        chk_context     -  Checks the passed context has an associated
                           entry with the given route in the
                           pay_route_context_usages.

DESCRIPTION
   This function will be called by the pay_balance_values_v view.

*/
function chk_context (p_context_id number,
                      p_route_id   number) return varchar2
is
  --
  cursor csr_context_usages is
     select 'Y'
       from ff_route_context_usages frc
      where frc.route_id = p_route_id
        and frc.context_id = p_context_id;
  --
  l_temp varchar2(1);
  --
begin
 --
 open csr_context_usages;
 fetch csr_context_usages into l_temp;
 close csr_context_usages;
 --
 return l_temp;
 --
end chk_context;
--
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--
--                            get_context                                 +
--                                                                        +
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
/*
NAME

        get_context     -  retrieve values of contexts set by set_contexts

DESCRIPTION
   This function may be called from the archiving process to determine the
   values of contexts that have been set earlier in order to archive this
   information.  The function passes in a context_id as a numebr and expects
   a varchar2 as a return.

*/
function get_context_internal (p_context_name  varchar2) return varchar2
is

   v_con_value     varchar2(60);
   v_context_found boolean;

BEGIN
   g_debug := hr_utility.debug_enabled;
   if g_debug then
      hr_utility.set_location ('pybaluex.get_context_internal',1);
      hr_utility.trace(no_rows_con_tab);
   end if;
   v_context_found := FALSE;

   for i in 0..no_rows_con_tab-1 LOOP

      -- is this the context were looking for

      if con_name_tab(i) = p_context_name then
         v_con_value:=con_value_tab(i); -- set return variable
         v_context_found := TRUE; -- set found flag
         if g_debug then
            hr_utility.trace('i= '||i);
            hr_utility.trace('name = '||con_name_tab(i));
            hr_utility.trace('value = '||con_value_tab(i));
         end if;
         EXIT; -- drop out of loop
     end if;
   end loop;
--
if v_context_found = TRUE then
   return v_con_value;
else
   return NULL;
end if;
--
if g_debug then
   hr_utility.set_location ('pybaluex.get_context_internal',3);
end if;
--
end get_context_internal;
--
function get_context (p_context_name  varchar2) return varchar2
is

   v_con_value     varchar2(60);
   v_context_found boolean;

BEGIN
   g_debug := hr_utility.debug_enabled;
   if g_debug then
      hr_utility.set_location ('pybaluex.get_context',1);
      hr_utility.trace(no_rows_con_tab);
   end if;

   v_con_value := get_context_internal(p_context_name);

   if (v_con_value is not null) then
     return v_con_value;
   else
     null;
   end if;
--
   if g_debug then
      hr_utility.set_location ('pybaluex.get_context',3);
   end if;
--
end get_context;
--
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--                                                                        +
--                            set_context                                 +
--                                                                        +
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--
/*
NAME
  set_context      - set up the run time contexts ready to run a balance or
                     database item.
DESCRIPTION
  This routine must be called for each context that is used in the database
  item.  The context information is held in package level pl/sql tables which
  will remain current for the entire sql session.  These pl/sql tables are
  referred to by the balance and database item routines.
  Subsequent calls to this routine with the same context name will update the
  relevant row in the pl/sql tables.
  Since the context name is converted to upper case, the calling routine may
  pass the context name in either case.
*/
procedure set_context
(
    p_context_name   in varchar2,
    p_context_value  in varchar2
) is
l_context_id      ff_contexts.context_id%type;
l_context_name    ff_contexts.context_name%type;
l_context_type    ff_contexts.data_type%type;
l_count           binary_integer;
l_context_found   boolean;
begin
  g_debug := hr_utility.debug_enabled;
  if g_debug then
     hr_utility.set_location ('pay_balance_pkg.set_context', 10);
     hr_utility.trace('p_context_name  : ' || p_context_name);
     hr_utility.trace('p_context_value : ' || p_context_value);
  end if;
  l_context_found := FALSE;
  l_context_name := upper(p_context_name);
  --
  -- check to see if the context is present
  --
  l_count := 0;
  while (l_count < no_rows_con_tab) loop
     if (con_name_tab (l_count) = l_context_name) then
        --
        -- The context name is already present in the pl/sql tales, so update
        -- its value:
        --
        con_value_tab (l_count) := p_context_value;
        l_context_found := TRUE;
        exit;   -- exit while loop
    end if;
    l_count := l_count + 1;
  end loop;
  --
  if (l_context_found = FALSE) then
    --
    -- its a new context, insert into tables
    --
    if g_debug then
       hr_utility.set_location ('pay_balance_pkg.set_context', 20);
    end if;
    select context_id,
           data_type
    into   l_context_id,
           l_context_type
    from   ff_contexts
    where  context_name = l_context_name;
    --
    con_name_tab  (no_rows_con_tab) := ltrim(rtrim(l_context_name));
    con_id_tab    (no_rows_con_tab) := ltrim(rtrim(l_context_id));
    con_type_tab  (no_rows_con_tab) := ltrim(rtrim(l_context_type));
    con_value_tab (no_rows_con_tab) := ltrim(rtrim(p_context_value));
    --
    no_rows_con_tab := no_rows_con_tab +1;
  end if;
  --
  -- print out the current state of the tables for debug purposes:
  --
  l_count := 0;
    if g_debug then
       hr_utility.trace
       ('i  type  context id  context name           context value');
       hr_utility.trace
       ('-  ----  ----------  ------------           -------------');
     while (l_count < no_rows_con_tab) loop
       hr_utility.trace (rpad(to_char(l_count), 3)       ||
                         rpad(con_type_tab(l_count), 6)  ||
                         rpad(con_id_tab(l_count), 12)   ||
                         rpad(con_name_tab(l_count), 23) ||
                         con_value_tab(l_count));
       l_count := l_count + 1;
     end loop;
    end if;

    /*
        Store a flatened version for the latest balance fetch
    */

    if (l_context_name = 'TAX_UNIT_ID') then
       g_con_tax_unit_id := ltrim(rtrim(p_context_value));
    elsif (l_context_name = 'JURISDICTION_CODE') then
       g_con_jurisdiction_code := ltrim(rtrim(p_context_value));
    elsif (l_context_name = 'ORIGINAL_ENTRY_ID') then
       g_con_original_entry_id := ltrim(rtrim(p_context_value));
    elsif (l_context_name = 'SOURCE_ID') then
       g_con_source_id := ltrim(rtrim(p_context_value));
    elsif (l_context_name = 'SOURCE_TEXT') then
       g_con_source_text := ltrim(rtrim(p_context_value));
    elsif (l_context_name = 'SOURCE_TEXT2') then
       g_con_source_text2 := ltrim(rtrim(p_context_value));
    elsif (l_context_name = 'SOURCE_NUMBER') then
       g_con_source_number := ltrim(rtrim(p_context_value));
    elsif (l_context_name = 'TAX_GROUP') then
       g_con_tax_group := ltrim(rtrim(p_context_value));
    elsif (l_context_name = 'PAYROLL_ID') then
       g_con_payroll_id := ltrim(rtrim(p_context_value));
    elsif (l_context_name = 'LOCAL_UNIT_ID') then
       g_con_local_unit_id := ltrim(rtrim(p_context_value));
    elsif (l_context_name = 'ORGANIZATION_ID') then
       g_con_organization_id := ltrim(rtrim(p_context_value));
    elsif (l_context_name = 'SOURCE_NUMBER2') then
       g_con_source_number2 := ltrim(rtrim(p_context_value));
    end if;

end set_context;
--
/*
NAME
  set_context      - set up the run time contexts ready to run a balance or
                     database item.
DESCRIPTION
   This route attempts to map legislative contexts to the Core Contexts.
*/
procedure set_context
(
    p_legislation_code in varchar2,
    p_context_name     in varchar2,
    p_context_value    in varchar2
) is
--
cnt   number;
found boolean;
l_context_name ff_contexts.context_name%type;
--
begin
--
   -- Reset buffers if needed
--
   if (p_legislation_code <> g_legislation_code
       or g_legislation_code is null) then
--
     g_context_mapping.delete;
--
   end if;
--
   cnt := 1;
   found := FALSE;
   while (cnt <= g_context_mapping.count
         and found = FALSE)  loop
--
     if (g_context_mapping(cnt).loc_context_name = p_context_name) then
       found := TRUE;
     else
       cnt := cnt + 1;
     end if;
--
   end loop;
--
   -- If the context name is not already in buffer then get it.
   if (found = FALSE) then
--
     begin
       select fc.context_name
         into l_context_name
         from ff_contexts fc,
              pay_legislation_contexts plc
        where plc.legislation_name = p_context_name
          and plc.context_id = fc.context_id
          and plc.legislation_code = p_legislation_code;
--
     exception
       when no_data_found then
          l_context_name := p_context_name;
     end;
--
     -- Place mapping in buffer
     cnt := g_context_mapping.count + 1;
     g_context_mapping(cnt).core_context_name := l_context_name;
     g_context_mapping(cnt).loc_context_name  := p_context_name;
--
   end if;
--
   -- Now set the context
   set_context(g_context_mapping(cnt).core_context_name,
               p_context_value);
--
end set_context;
--
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--                                                                        +
--                              run_db_item                               +
--                                                                        +
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--
/*
NAME
  run_db_item      - Retrieve a database item value.
--
DESCRIPTION
  This function is used to retrieve a database item value.  The sql to be run
  needs to be assembled from the information held in the entity horizon (in
  particular the tables ff_database_items and ff_routes).  Having retrieved
  the route (the part of the sql statement after the 'FROM' clause) into a
  large string, the context bind variables and where clause fillers need to be
  replaced.  The text string is then updated with the definition text
  information from ff_database_items (the part of the sql statement after
  the 'SELECT' and before the 'FROM').  The complete text string is then
  executed using dynamic pl/sql.
*/
function run_db_item
(
    p_database_name    in  varchar2,
    p_bus_group_id     in  number,
    p_legislation_code in  varchar2
) return varchar2 is
p_db_output varchar2(240);
--
-- Cursor Declarations
-- Used to retrieve the context bind variables for the route.
--
cursor ro_context (p_route_id  number)
is
select context_id,
       sequence_no
from   ff_route_context_usages
where  route_id = p_route_id
order  by sequence_no;
--
-- Used to retrieve the where clause fillers for the route
--
cursor ro_wclause (p_user_entity_id   number,
                   p_route_id         number)
is
select RP.sequence_no,
       replace(RPV.value, '''', null) value
from   ff_route_parameter_values    RPV
,      ff_route_parameters          RP
where  RPV.user_entity_id         = p_user_entity_id
and    RP.route_id                = p_route_id
and    RPV.route_parameter_id     = RP.route_parameter_id
order  by RP.sequence_no;
--
sql_cursor               integer;
l_rows                   integer;
l_definition_text        ff_database_items.definition_text%type;
l_data_type              ff_database_items.data_type%type;
l_user_entity_id         ff_user_entities.user_entity_id%type;
l_creator_type           ff_user_entities.creator_type%type;
l_notfound_allowed_flag  ff_user_entities.notfound_allowed_flag%type;
l_route_id               ff_routes.route_id%type;
l_context_name           ff_contexts.context_name%type;
l_text                   varchar2(20000);     -- large array for route text
l_replace_text           varchar2(80);
l_error_text             varchar2(200);   -- used for sql error messages
l_o_hint                 varchar2(2000); -- Route optimiser hint
l_count                  number;
l_context_found          boolean;
l_ora_db_vers            number; -- db version number for LOW_VOLUME
l_cxt_num                number;
l_par_num                number;
--
------------------------------- run_db_item -------------------------------
--
begin
  g_debug := hr_utility.debug_enabled;
  if g_debug then
     hr_utility.set_location ('pay_balance_pkg.run_db_item', 1);
     hr_utility.trace ('DB_item  = ' || p_database_name);
     hr_utility.trace ('bus_grp  = ' || to_char (p_bus_group_id));
     hr_utility.trace ('leg_code = ' || p_legislation_code);
  end if;
  --
  -- Get all the data to build up the route
  --
  select DBI.definition_text,
         DBI.data_type,
         ENT.user_entity_id,
         ENT.creator_type,
         ENT.notfound_allowed_flag,
         RO.route_id,
         RO.text,
         RO.optimizer_hint
  into   l_definition_text,
         l_data_type,
         l_user_entity_id,
         l_creator_type,
         l_notfound_allowed_flag,
         l_route_id,
         l_text,
         l_o_hint
  from   ff_database_items         DBI
  ,      ff_user_entities          ENT
  ,      ff_routes                 RO
  where  DBI.user_name           = p_database_name
  and    DBI.user_entity_id      = ENT.user_entity_id
  and    ( (ENT.legislation_code is null and ENT.business_group_id is null)
          or (ENT.business_group_id is null
              and p_legislation_code = ENT.legislation_code )
          or ENT.business_group_id + 0 = p_bus_group_id
         )
  and    ENT.route_id            = RO.route_id;
  --
  --
  -- The following loop searches through and replaces all the bind variables
  -- (Bn) with the actual value for the context.  For a text value, the
  -- quotes also need to be inserted.
  --
  -- Load the route context cache to avoid re-execution of the cursor
  -- when binding values to bind variables
  --
  route_contexts_cache.sz := 0;
  for c1rec in ro_context (l_route_id) loop
    route_contexts_cache.sz := route_contexts_cache.sz + 1;
    route_contexts_cache.cxt_id(route_contexts_cache.sz) := c1rec.context_id;
    l_count := 0;
    l_context_found := FALSE;
    while (l_count < no_rows_con_tab) loop
      if (con_id_tab(l_count) = c1rec.context_id) then
        --
        -- Found a bind variable
        --
        l_context_found := TRUE;
        l_replace_text := ':' || ltrim(rtrim(con_name_tab(l_count)));
        l_text := replace (l_text, '&B'||to_char(c1rec.sequence_no),
                                   l_replace_text);
        exit;  -- exit while loop
      end if;
      l_count := l_count + 1;
    end loop;  -- end of while loop
    if (l_context_found = FALSE) then
      --
      -- Raise an error, as there are contexts that have not been set up in
      -- the pl/sql tables that are required by the route.
      --
      if g_debug then
         hr_utility.set_location ('pay_balance_pkg.run_db_item', 10);
      end if;
      select context_name
      into   l_context_name
      from   ff_contexts
      where  context_id = c1rec.context_id;
      --
      hr_utility.set_message(801, 'HR_7271_PAY_CONTEXT_MISSING');
      hr_utility.set_message_token ('CONTEXT_NAME', l_context_name);
      hr_utility.raise_error;
    end if;
  end loop; -- end of for c1rec loop
  --
  -- The following loop searches through and replaces all where clause fillers
  -- (Un) with the value from ff_route_parameter_values.  For a text value,
  -- the quotes have already pre-inserted into this table.
  --
  -- Load the route parameters cache to avoid re-execution of the cursor
  -- when binding values to bind variables
  --
  route_parameters_cache.sz := 0;
  for c1rec in ro_wclause (l_user_entity_id, l_route_id) loop
    route_parameters_cache.sz := route_parameters_cache.sz + 1;
    route_parameters_cache.seq_no(route_parameters_cache.sz) := c1rec.sequence_no;
    route_parameters_cache.par_val(route_parameters_cache.sz) := c1rec.value;
    l_text := replace (l_text, '&U'||to_char(c1rec.sequence_no),
                                ':U'||to_char(c1rec.sequence_no));
  end loop;
  --
  -- Print the route text out for debug purposes.  Normally keep this line
  -- commented out, as for a large route it causes an error in the trace
  -- utility.
  -- hr_utility.trace (l_text);
  --
  --
  -- now build up the full SQL statement:
  --
  if (l_data_type = 'D') then
    if (l_o_hint is null) then
         l_text := 'SELECT fnd_date.date_to_canonical(' ||
                   l_definition_text || ') FROM ' || l_text;
    else
         l_text := 'SELECT /*+ '||l_o_hint||
                   ' */ fnd_date.date_to_canonical(' ||
                   l_definition_text || ') FROM ' || l_text;
    end if;
  elsif (l_data_type = 'N') then

    if (l_o_hint is null) then
      --
      -- Use Rule hint on balances if LOW_VOLUME pay_action_paremeter set
      --
      if (l_creator_type = 'B') then
        -- balance dbitem

        if (cached = FALSE) then
          cached := TRUE;
          l_ora_db_vers := get_oracle_db_version;
          if (nvl(l_ora_db_vers, 0) < 9.0) then
             g_low_volume := 'Y';
          else
            begin
               select parameter_value
               into g_low_volume
               from pay_action_parameters
               where parameter_name = 'LOW_VOLUME';
            exception
              when others then
                 g_low_volume := 'N';
            end;
          end if;
        end if;

        if (g_low_volume = 'Y') then
          l_text := 'SELECT /*+ RULE*/ fnd_number.number_to_canonical(' ||
                    l_definition_text || ') FROM ' || l_text;
        else
          l_text := 'SELECT fnd_number.number_to_canonical(' ||
                    l_definition_text || ') FROM ' || l_text;
        end if;
      else
        -- Not a balance dbitem
        l_text := 'SELECT fnd_number.number_to_canonical(' ||
                  l_definition_text || ') FROM ' || l_text;
      end if;
    else -- Optimiser hint has bee supplied
       l_text := 'SELECT /*+ '||l_o_hint||
                 ' */ fnd_number.number_to_canonical(' ||
                  l_definition_text || ') FROM ' || l_text;
    end if;
--
  else
    if (l_o_hint is null) then
      l_text := 'SELECT ' || l_definition_text || ' FROM ' || l_text;
    else
      l_text := 'SELECT /*+ ' ||l_o_hint||' */'||
                l_definition_text || ' FROM ' || l_text;
    end if;
  end if;
  --
  -- Now execute the SQL statement using dynamic pl/sql:
  --
  -- Dynamic sql steps:
  -- ==================
  -- 1. Open dynamic sql cursor
  -- 2. Parse dynamic sql
  -- 3. bind variables
  -- 4. Define dynamic sql columns
  -- 5. Execute and fetch dynamic sql
  -- 6. Get the sql value (providing there are rows returned)
  -- 7. Close the dynamic sql cursor
  --
  if g_debug then
     hr_utility.set_location ('pay_balance_pkg.run_db_item', 15);
  end if;
  sql_cursor := dbms_sql.open_cursor;                             -- step 1
  --
  if g_debug then
     hr_utility.set_location ('pay_balance_pkg.run_db_item', 20);
  end if;
  dbms_sql.parse(sql_cursor, l_text, dbms_sql.v7);                -- step 2
  --
  --                                                              -- step 3
  -- At this stage we have parsed the route.  Now bind the
  -- variables, starting with the contexts (B values).
  --
  for l_cxt_num in 1..route_contexts_cache.sz loop
    l_count := 0;
    l_context_found := FALSE;
    while (l_count < no_rows_con_tab) loop
      if (con_id_tab(l_count) = route_contexts_cache.cxt_id(l_cxt_num)) then
        if g_debug then
           hr_utility.trace (con_name_tab (l_count) ||' = '||
                             con_value_tab (l_count));
        end if;
        --
        -- Found a bind variable
        --
        if (con_type_tab (l_count) = 'D') then
           dbms_sql.bind_variable (sql_cursor, con_name_tab  (l_count),
                                 fnd_date.canonical_to_date(ltrim(rtrim(con_value_tab (l_count)))));
        else
           dbms_sql.bind_variable (sql_cursor, con_name_tab  (l_count),
                                 ltrim(rtrim(con_value_tab (l_count))));
        end if;
        l_context_found := TRUE;
        exit;  -- exit while loop
      end if;
      l_count := l_count + 1;
    end loop;  -- end of while loop
    if (l_context_found = FALSE) then
      --
      -- Raise an error, as there are contexts that have not been set up in
      -- the pl/sql tables that are required by the route.
      --
      if g_debug then
         hr_utility.set_location ('pay_balance_pkg.run_db_item', 101);
      end if;
      select context_name
      into   l_context_name
      from   ff_contexts
      where  context_id = route_contexts_cache.cxt_id(l_cxt_num);
      --
      hr_utility.set_message(801, 'HR_7271_PAY_CONTEXT_MISSING');
      hr_utility.set_message_token ('CONTEXT_NAME', l_context_name);
      hr_utility.raise_error;
    end if;
  end loop; -- end of for route contexts loop
  --
  -- Now bind the where clause fillers (the 'U' values)
  --
  for l_par_num in 1..route_parameters_cache.sz loop
    dbms_sql.bind_variable (sql_cursor, 'U'||to_char(route_parameters_cache.seq_no(l_par_num)),
                                        route_parameters_cache.par_val(l_par_num));
  end loop;
  --
  if g_debug then
     hr_utility.set_location ('pay_balance_pkg.run_db_item', 25);
  end if;
  dbms_sql.define_column (sql_cursor, 1, p_db_output, 240);        -- step 4
  --
  if g_debug then
     hr_utility.set_location ('pay_balance_pkg.run_db_item', 30);
  end if;
  l_rows := dbms_sql.execute_and_fetch (sql_cursor, false);       -- step 5
  --
  if (l_rows = 1) then
    if g_debug then
       hr_utility.set_location ('pay_balance_pkg.run_db_item', 35);
    end if;
    dbms_sql.column_value (sql_cursor, 1, p_db_output);           -- step 6
    --
    if g_debug then
       hr_utility.set_location ('pay_balance_pkg.run_db_item', 40);
    end if;
    dbms_sql.close_cursor(sql_cursor);                            -- step 7
    --
    if g_debug then
       hr_utility.trace ('DB value = ' || p_db_output);
    end if;
    --
  elsif (l_rows = 0) then
    dbms_sql.close_cursor(sql_cursor);
    if (l_notfound_allowed_flag = 'Y') then
      --
      -- its ok to not find a row
      --
      if g_debug then
         hr_utility.set_location ('pay_balance_pkg.run_db_item', 45);
      end if;
      p_db_output := null;
    else
      --
      -- Error, no rows found when the entity has been defined to always
      -- find a row.
      --
      hr_utility.set_message(801, 'HR_7272_PAY_NO_ROWS_RETURNED');
      hr_utility.set_message_token ('DATABASE_NAME', p_database_name);
      hr_utility.raise_error;
    end if;
  else
    --
    -- More than 1 row have been returned. We must error as DB items can
    -- only return 1 row.
    --
    dbms_sql.close_cursor(sql_cursor);
    hr_utility.set_message(801, 'HR_7273_PAY_MORE_THAN_1_ROW');
    hr_utility.raise_error;
  end if;
  return p_db_output;
exception
  --
  -- If any other Oracle Error is trapped (e.g. during parse, execute,
  -- fetch etc), then we must check to see if the cursor is still open
  -- and close down if necessary.
  --
  When Others Then
    l_error_text := sqlerrm;
    if g_debug then
       Hr_Utility.Set_Location('run_db_item', 100);
    end if;
    If (dbms_sql.is_open(sql_cursor)) then
      if g_debug then
         Hr_Utility.Set_Location('run_db_item', 105);
      end if;
      dbms_sql.close_cursor(sql_cursor);
    End If;
    hr_utility.set_message(801, 'HR_7276_PAY_FAILED_DB_ITEM');
    hr_utility.set_message_token ('ERROR_MESSAGE', l_error_text);
    hr_utility.raise_error;
end run_db_item;
--
--
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--
--                            generate_rr_statem                         +
--                                                                        +
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
/*
NAME

        generate_rr_statem  -  This creates the Run Result Balance
                                Statement

DESCRIPTION

      This generates the balance statement to be used to retrieve values.

*/
procedure generate_rr_statem(
                       p_batch_mode          in            boolean,
                       p_balance_type_id     in            number,
                       p_balance_list        in            t_batch_list,
                       p_balance_type_column in            varchar2,
                       p_retrieval_column    in            varchar2,
                       p_decode_required     in            boolean,
                       p_from_clause         in            varchar2,
                       p_o_hint              in            varchar2,
                       p_bal_ptr             in out nocopy number,
                       p_statement              out nocopy varchar2
                      )
is
--
--  Do not change the length of these without changing MAX_DYN_SQL size.
--
l_select_clause    varchar2(20000);     -- large array for route text
l_from_clause      varchar2(20000);     -- large array for route text
l_select_component varchar2(20000);     -- large array for route text
l_from_component   varchar2(20000);     -- large array for route text
cnt                number;
l_string_full      boolean;
l_from_length      number;
l_comp_length      number;

begin
  --
  -- now build up the full SQL statement:
  --
  -- Select portion of the statement up
  --
  if (p_retrieval_column is null) then
    l_select_clause := 'TARGET.result_value';
  else
    l_select_clause := p_retrieval_column;
  end if;
--
  l_select_clause := 'nvl(sum(fnd_number.canonical_to_number('||l_select_clause||') * FEED.scale),0)';
  l_from_clause := ' FROM '||p_from_clause;
  --
  -- Setup the Select and optimiser
  --
  if (p_o_hint is null) then
    if (g_low_volume = 'Y') then
      l_select_clause := 'SELECT /*+ RULE*/ fnd_number.number_to_canonical(' ||
                         l_select_clause || ')';
    else
      l_select_clause := 'SELECT fnd_number.number_to_canonical(' ||
                         l_select_clause || ')';
    end if;
  else
    l_select_clause := 'SELECT /*+ '||p_o_hint||
                       ' */ fnd_number.number_to_canonical(' ||
                       l_select_clause || ')';
  end if;
--
  if g_debug then
    hr_utility.trace(l_select_clause);
  end if;
--
  --
  -- Now setup the balance type joining details.
  --
  if (p_batch_mode = TRUE) then
    if (p_balance_type_column is null) then
      hr_general.assert_condition(false);
    else
      declare
      l_first_bt boolean;
      begin
--
        l_select_component := ', '||p_balance_type_column;
        if g_debug then
          hr_utility.trace(l_select_component);
        end if;
--
        l_select_clause := l_select_clause||l_select_component;
        l_from_clause := l_from_clause||' and '||p_balance_type_column||' in (';
        if g_debug then
          if length(l_from_clause) <= MAX_TRACE_SIZE then
            hr_utility.trace(l_from_clause);
          end if;
        end if;
--
        -- Now put the full statement in the from clause
        l_from_clause := l_select_clause||l_from_clause;
--
        l_first_bt := TRUE;
--
        -- Loop through all the entries in the balance list
        -- (or as many as we can)
        -- adding them to the statement form batch mode.
--
        l_string_full := FALSE;
        cnt := p_bal_ptr; -- Start from where we left last time
        while (    l_string_full = FALSE
               and cnt <= p_balance_list.count) loop
--
          if (l_first_bt = TRUE) then
--
            l_first_bt := FALSE;
            l_from_component := '';
--
          else
--
            l_from_component := ', ';
--
          end if;
--
          l_from_component := l_from_component||p_balance_list(cnt).balance_type_id;
--
          if(p_decode_required = TRUE) then
             l_from_component := l_from_component||' + decode(TARGET.input_value_id, 0, 0, 0)';
          end if;
--
          -- Only add to the statement if there is space
--
          l_from_length := length(l_from_clause);
          l_comp_length := length(l_from_component);
--
          if ((l_from_length + l_comp_length) <
              (MAX_DYN_SQL_SIZE - 50)) then
--
            if g_debug then
              if l_comp_length <= MAX_TRACE_SIZE then
                hr_utility.trace(l_from_component);
              end if;
            end if;
            l_from_clause := l_from_clause||l_from_component;
--
          else
--
            l_string_full:= TRUE;
--
          end if;
--
          cnt := cnt + 1; -- increment pointer
--
        end loop;
--
        -- Now set the pointer
        p_bal_ptr := cnt;
--
        l_from_component := ' ) group by '||p_balance_type_column;
        if g_debug then
          if length(l_from_component) <= MAX_TRACE_SIZE then
            hr_utility.trace(l_from_component);
          end if;
        end if;
        l_from_clause := l_from_clause||l_from_component;
--
      end;
    end if;
  else
    if (p_balance_type_column is null) then
--
       if g_debug then
         if length(l_from_clause) <= MAX_TRACE_SIZE then
           hr_utility.trace(l_from_clause);
         end if;
       end if;
--
       -- Now put the full statement in the from clause
       l_from_clause := l_select_clause||l_from_clause;
--
    else
       --
       -- As above, assume that there is one route parameter.
       --
--
       if g_debug then
         if length(l_from_clause) <= MAX_TRACE_SIZE then
           hr_utility.trace(l_from_clause);
         end if;
       end if;
--
       -- Now put the full statement in the from clause
       l_from_clause := l_select_clause||l_from_clause;
--
       l_from_component := ' and '||p_balance_type_column||' = :U1';
       if g_debug then
         if length(l_from_component) <= MAX_TRACE_SIZE then
           hr_utility.trace(l_from_component);
         end if;
       end if;
       l_from_clause := l_from_clause||l_from_component;
--
       if (p_decode_required = TRUE) then
          l_from_component := ' + decode(TARGET.input_value_id, 0, 0, 0)';
          if g_debug then
            if length(l_from_component) <= MAX_TRACE_SIZE then
              hr_utility.trace(l_from_component);
            end if;
          end if;
          l_from_clause := l_from_clause||l_from_component;
       end if;
--
    end if;
  end if;
--
  -- Now set the output statement
--
  p_statement := l_from_clause;
--
end generate_rr_statem;

--
--
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--
--                            process_balance_statement                   +
--                                                                        +
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
/*
NAME

        process_balance_statement  -  Dynamically run the Balance
                                      Statement.

DESCRIPTION

    This dynamically runs the supplied balance statement then sets the
    appropreate results.

*/
procedure process_balance_statement(
                       p_batch_mode          in            boolean,
                       p_statement           in            varchar2,
                       p_route_id            in            number,
                       p_jur_level_required  in            boolean,
                       p_jur_lvl             in            number,
                       p_balance_type_id     in            number,
                       p_batch_str_ptr       in            number,
                       p_batch_end_ptr       in            number,
                       p_balance_list        in out nocopy t_batch_list,
                       p_balance_value          out nocopy number
                      )
is
--
-- Cursor Declarations
-- Used to retrieve the context bind variables for the route.
--
cursor ro_context (p_route_id  number)
is
select context_id,
       sequence_no
from   ff_route_context_usages
where  route_id = p_route_id
order  by sequence_no;
--
sql_cursor               integer;
l_rows                   integer;
l_count                  number;
l_context_found          boolean;
l_context_name           ff_contexts.context_name%type;
l_balance_type_id        number;
ignore                   number;
l_retrieve               boolean;
l_value_retrieved        boolean;
l_db_output              varchar(60);
l_error_text             varchar2(200);       -- used for sql error messages
begin
  --
  -- Now execute the SQL statement using dynamic pl/sql:
  --
  -- Dynamic sql steps:
  -- ==================
  -- 1. Open dynamic sql cursor
  -- 2. Parse dynamic sql
  -- 3. bind variables
  -- 4. Define dynamic sql columns
  -- 5. Execute and fetch dynamic sql
  -- 6. Get the sql value (providing there are rows returned)
  -- 7. Close the dynamic sql cursor
  --
  if g_debug then
     hr_utility.set_location ('pay_balance_pkg.process_balance_statement', 35);
  end if;
  sql_cursor := dbms_sql.open_cursor;                             -- step 1
  --
  if g_debug then
     hr_utility.set_location ('pay_balance_pkg.process_balance_statement', 40);
  end if;
  dbms_sql.parse(sql_cursor, p_statement, dbms_sql.v7);                -- step 2
  --
  --                                                              -- step 3
  -- At this stage we have parsed the route.  Now bind the
  -- variables, starting with the contexts (B values).
  --
  for c1rec in ro_context (p_route_id) loop
    if g_debug then
       hr_utility.set_location ('pay_balance_pkg.process_balance_statement', 45);
    end if;
    l_count := 0;
    l_context_found := FALSE;
    while (l_count < no_rows_con_tab) loop
      if (con_id_tab(l_count) = c1rec.context_id) then
        if g_debug then
           hr_utility.trace (con_name_tab (l_count) ||' = '||
                             con_value_tab (l_count));
        end if;
        --
        -- Found a bind variable
        --
        if (con_type_tab (l_count) = 'D') then
          if g_debug then
             hr_utility.set_location ('pay_balance_pkg.process_balance_statement', 50);
          end if;
          dbms_sql.bind_variable
           (sql_cursor,
            con_name_tab(l_count),
            fnd_date.canonical_to_date(ltrim(rtrim(con_value_tab (l_count)))));
        else
          if g_debug then
             hr_utility.set_location ('pay_balance_pkg.process_balance_statement', 55);
          end if;
          dbms_sql.bind_variable
           (sql_cursor,
            con_name_tab(l_count),
            ltrim(rtrim(con_value_tab (l_count))));
        end if;
        l_context_found := TRUE;
        exit;  -- exit while loop
      end if;
      l_count := l_count + 1;
    end loop;  -- end of while loop
    if (l_context_found = FALSE) then
      --
      -- Raise an error, as there are contexts that have not been set up in
      -- the pl/sql tables that are required by the route.
      --
      if g_debug then
         hr_utility.set_location ('pay_balance_pkg.process_balance_statement', 60);
      end if;
      select context_name
      into   l_context_name
      from   ff_contexts
      where  context_id = c1rec.context_id;
      --
      hr_utility.set_message(801, 'HR_7271_PAY_CONTEXT_MISSING');
      hr_utility.set_message_token ('CONTEXT_NAME', l_context_name);
      hr_utility.raise_error;
    end if;
  end loop; -- end of for c1rec loop
  --
  -- Now bind the where clause fillers (the 'U' values)
  --
  if (p_batch_mode = FALSE) then
    if g_debug then
       hr_utility.set_location ('pay_balance_pkg.process_balance_statement', 62);
       hr_utility.trace('p_balance_type_id = '||p_balance_type_id);
    end if;
    dbms_sql.bind_variable (sql_cursor, 'U1',
                                        p_balance_type_id);
  end if;
--
  if (p_jur_level_required = TRUE) then
    dbms_sql.bind_variable (sql_cursor, 'JURISDICTION_LEVEL',
                                        p_jur_lvl);
  end if;
  --
  if g_debug then
     hr_utility.set_location ('pay_balance_pkg.process_balance_statement', 65);
  end if;
  dbms_sql.define_column (sql_cursor, 1, l_db_output, 60);        -- step 4
  if (p_batch_mode  = TRUE) then
     dbms_sql.define_column (sql_cursor, 2, l_balance_type_id);
  end if;
  --
  if g_debug then
     hr_utility.set_location ('pay_balance_pkg.process_balance_statement', 70);
  end if;
  ignore := dbms_sql.execute(sql_cursor);
  --
  l_retrieve := TRUE;
  l_value_retrieved := FALSE;
  while (l_retrieve = TRUE) loop
    --
    l_rows := dbms_sql.fetch_rows(sql_cursor);
    --
    if g_debug then
       hr_utility.set_location ('pay_balance_pkg.process_balance_statement', 80);
    end if;
    --
    if (l_rows > 0) then
      --
      if g_debug then
         hr_utility.set_location ('pay_balance_pkg.process_balance_statement', 85);
      end if;
      dbms_sql.column_value (sql_cursor, 1, l_db_output);
      if (p_batch_mode  = TRUE) then
        dbms_sql.column_value (sql_cursor, 2, l_balance_type_id);
        --
        -- Search batch to populate value.
        --
        for cnt in p_batch_str_ptr..p_batch_end_ptr loop
          if (p_balance_list(cnt).balance_type_id = l_balance_type_id) then
             p_balance_list(cnt).balance_value :=
                        fnd_number.canonical_to_number(l_db_output);
             if g_debug then
                hr_utility.trace('****Bal = '||l_balance_type_id||' Value = '||
                                 l_db_output);
             end if;
          end if;
        end loop;
        --
      else
        --
        -- Have we already got a value
        --
        if g_debug then
           hr_utility.set_location ('pay_balance_pkg.process_balance_statement', 87);
        end if;
        if (l_value_retrieved = TRUE) then
          if g_debug then
             hr_utility.set_location ('pay_balance_pkg.process_balance_statement', 90);
          end if;
          dbms_sql.close_cursor(sql_cursor);
          hr_utility.set_message(801, 'HR_7273_PAY_MORE_THAN_1_ROW');
          hr_utility.raise_error;
        end if;
        if g_debug then
           hr_utility.trace('Value = '||l_db_output);
        end if;
        p_balance_value := fnd_number.canonical_to_number(l_db_output);
        --
      end if;
      --
      l_value_retrieved := TRUE;
      --
    else
      l_retrieve := FALSE;
    end if;
  end loop;
  dbms_sql.close_cursor(sql_cursor);
  --
  if (l_value_retrieved = FALSE and p_batch_mode  = FALSE) then
    --
    -- Error, no rows found when the entity has been defined to always
    -- find a row.
    --
    hr_general.assert_condition(false);
  end if;
  --
exception
  --
  -- If any other Oracle Error is trapped (e.g. during parse, execute,
  -- fetch etc), then we must check to see if the cursor is still open
  -- and close down if necessary.
  --
  When Others Then
    l_error_text := sqlerrm;
    if g_debug then
       Hr_Utility.Set_Location('pay_balance_pkg.process_balance_statement', 100);
    end if;
    If (dbms_sql.is_open(sql_cursor)) then
      if g_debug then
         Hr_Utility.Set_Location('pay_balance_pkg.process_balance_statement', 105);
      end if;
      dbms_sql.close_cursor(sql_cursor);
    End If;
    hr_utility.set_message(801, 'HR_7276_PAY_FAILED_DB_ITEM');
    hr_utility.set_message_token ('ERROR_MESSAGE', l_error_text);
    hr_utility.raise_error;
    --
end process_balance_statement;
--
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--
--                            run_rr_route                                +
--                                                                        +
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
/*
NAME

        run_rr_route  -  Run Run Result Route to get balance value.

DESCRIPTION

   This procedure is used to retrieve balance values both in batch and
   single mode and runs the run result route from the dimension routes
   table. Note it is not used to retrieve the route attached to the
   balance dimension itself, that is done via run_db_item.

*/
procedure run_rr_route(
                       p_batch_mode          in            boolean,
                       p_balance_type_id     in            number,
                       p_balance_list        in out nocopy t_batch_list,
                       p_route_id            in            number,
                       p_balance_type_column in            varchar2,
                       p_retrieval_column    in            varchar2,
                       p_decode_required     in            boolean,
                       p_jur_lvl             in            number,
                       p_balance_value          out nocopy number
                      )
is
-- Cursor Declarations
-- Used to retrieve the context bind variables for the route.
--
cursor ro_context (p_route_id  number)
is
select context_id,
       sequence_no
from   ff_route_context_usages
where  route_id = p_route_id
order  by sequence_no;
--
--
l_context_name           ff_contexts.context_name%type;
--
--  Do not change the length of these without changing MAX_DYN_SQL size.
--
l_from_clause            varchar2(20000);     -- large array for route text
l_o_hint                 varchar2(2000);      -- large array for optimiser hint
l_statement              varchar2(20000);     -- large array for route text
l_replace_text           varchar2(80);
l_count                  number;
l_context_found          boolean;
l_jur_level_required     boolean;
l_ora_db_vers            number; -- db version number for LOW_VOLUME
l_bal_ptr                number;
l_start_ptr              number;
--
begin
  if g_debug then
     hr_utility.set_location ('pay_balance_pkg.run_rr_route', 1);
  end if;
  --
  -- If we are in batch mode then initialise the returns
  --
  for cnt in 1..p_balance_list.count loop
    p_balance_list(cnt).balance_value := 0;
  end loop;
  --
  -- Get all the data to build up the route
  -- select definition and data type are hard coded for now
  --
  select RO.text,
         RO.optimizer_hint
    into l_from_clause,
         l_o_hint
    from ff_routes                 RO
   where RO.route_id = p_route_id;
  --
  -- The following loop searches through and replaces all the bind variables
  -- (Bn) with the actual value for the context.  For a text value, the
  -- quotes also need to be inserted.
  --
  for c1rec in ro_context (p_route_id) loop
    l_count := 0;
    l_context_found := FALSE;
    while (l_count < no_rows_con_tab) loop
      if (con_id_tab(l_count) = c1rec.context_id) then
        --
        -- Found a bind variable
        --
        l_context_found := TRUE;
        l_replace_text := ':' || ltrim(rtrim(con_name_tab(l_count)));
        l_from_clause := replace (l_from_clause, '&B'||to_char(c1rec.sequence_no),
                                   l_replace_text);
        exit;  -- exit while loop
      end if;
      l_count := l_count + 1;
    end loop;  -- end of while loop
    if (l_context_found = FALSE) then
      --
      -- Raise an error, as there are contexts that have not been set up in
      -- the pl/sql tables that are required by the route.
      --
      if g_debug then
         hr_utility.set_location ('pay_balance_pkg.run_rr_route', 10);
      end if;
      select context_name
      into   l_context_name
      from   ff_contexts
      where  context_id = c1rec.context_id;
      --
      hr_utility.set_message(801, 'HR_7271_PAY_CONTEXT_MISSING');
      hr_utility.set_message_token ('CONTEXT_NAME', l_context_name);
      hr_utility.raise_error;
    end if;
  end loop; -- end of for c1rec loop
  --
  -- The following loop searches through and replaces all where clause fillers
  -- (Un) with the value from ff_route_parameter_values.
  -- NOTE. This is a run result route, assume that only balance type
  -- is the parameter and only in non batch mode.
  --
  if (p_balance_type_column is null) then
    l_from_clause := replace (l_from_clause, '&U1',
                                ':U1');
  end if;
  --
  -- Print the route text out for debug purposes.  Normally keep this line
  -- commented out, as for a large route it causes an error in the trace
  -- utility.
  -- hr_utility.trace (l_from_clause);
  --
  --
  -- Get action Parameter.
  --
  if (cached = FALSE) then
    cached := TRUE;
    if g_debug then
       hr_utility.set_location('pay_balance_pkg.run_rr_route', 20);
    end if;
    l_ora_db_vers := get_oracle_db_version;
    if (nvl(l_ora_db_vers, 0) < 9.0) then
       g_low_volume := 'Y';
    else
      begin
        select parameter_value
        into g_low_volume
        from pay_action_parameters
        where parameter_name = 'LOW_VOLUME';
      exception
        when others then
           g_low_volume := 'N';
      end;
    end if;
  end if;
--
  -- Set up the Jurisdiction level flag.
  l_jur_level_required := FALSE;
  if (instr(l_from_clause, ':JURISDICTION_LEVEL') <> 0) then
     l_jur_level_required := TRUE;
  end if;
--
  -- If batch mode is false then we know that we are only
  -- retrieving a single value. However in batch mode
  -- it may take several passes to retrieve all the
  -- values.
--
  if (p_batch_mode = TRUE) then
--
    l_bal_ptr := 1;
--
    while (l_bal_ptr <= p_balance_list.count) loop
--
      l_start_ptr := l_bal_ptr;
--
      -- Now call the procedure that builds the SQL statement
--
      generate_rr_statem(p_batch_mode,
                          p_balance_type_id,
                          p_balance_list,
                          p_balance_type_column,
                          p_retrieval_column,
                          p_decode_required,
                          l_from_clause,
                          l_o_hint,
                          l_bal_ptr,
                          l_statement
                         );
--
      -- Now get the balances
--
      process_balance_statement(
                           p_batch_mode,
                           l_statement,
                           p_route_id,
                           l_jur_level_required,
                           p_jur_lvl,
                           p_balance_type_id,
                           l_start_ptr,
                           l_bal_ptr - 1, -- its set to the next position.
                           p_balance_list,
                           p_balance_value
                          );
    end loop;
  else
--
    -- Now call the procedure that builds the SQL statement
--
    generate_rr_statem(p_batch_mode,
                        p_balance_type_id,
                        p_balance_list,
                        p_balance_type_column,
                        p_retrieval_column,
                        p_decode_required,
                        l_from_clause,
                        l_o_hint,
                        l_bal_ptr,
                        l_statement
                       );
--
    -- Now get the balances
--
    process_balance_statement(
                         p_batch_mode,
                         l_statement,
                         p_route_id,
                         l_jur_level_required,
                         p_jur_lvl,
                         p_balance_type_id,
                         1,
                         1,
                         p_balance_list,
                         p_balance_value
                        );
  end if;
--
end run_rr_route;
---------------------------------------------------------------------------
-- function get_run_balance
---------------------------------------------------------------------------
function get_run_balance
(p_user_name         in varchar2
,p_business_group_id in number
,p_legislation_code  in varchar2
,p_route_type        in varchar2
) return varchar2
is
p_db_output varchar2(80);
--
-- Cursor Declarations
-- Used to retrieve the context bind variables for the route.
--
cursor ro_context (p_route_id  number)
is
select context_id,
       sequence_no
from   ff_route_context_usages
where  route_id = p_route_id
order  by sequence_no;
--
-- Used to retrieve the where clause fillers for the route
--
cursor ro_wclause (p_user_entity_id   number,
                   p_route_id         number)
is
select RP.sequence_no,
       RPV.value
from   ff_route_parameter_values    RPV
,      ff_route_parameters          RP
where  RPV.user_entity_id         = p_user_entity_id
and    RP.route_id                = p_route_id
and    RPV.route_parameter_id     = RP.route_parameter_id
order  by RP.sequence_no;
--
sql_cursor               integer;
l_rows                   integer;
l_definition_text        varchar2(240);
--l_data_type              ff_database_items.data_type%type;
l_data_type              varchar2(1) := 'N';
l_user_entity_id         ff_user_entities.user_entity_id%type;
l_creator_type           ff_user_entities.creator_type%type;
l_notfound_allowed_flag  ff_user_entities.notfound_allowed_flag%type;
l_route_id               ff_routes.route_id%type;
l_context_name           ff_contexts.context_name%type;
l_text                   varchar2(20000);     -- large array for route text
l_replace_text           varchar2(80);
l_error_text             varchar2(200);       -- used for sql error messages
l_o_hint                 varchar2(2000);      -- optimiser hint
l_count                  number;
l_context_found          boolean;
l_cxt_num                number;
l_par_num                number;
--
BEGIN
  if g_debug then
     hr_utility.set_location ('pay_balance_pkg.get_run_balance', 1);
     hr_utility.trace ('User name: '|| p_user_name);
     hr_utility.trace ('bus_grp: '  || to_char (p_business_group_id));
     hr_utility.trace ('leg_code: ' || p_legislation_code);
  end if;
  --
  -- Get all the data to build up the route
  -- select definition and data type are hard coded for now
  --
  select ENT.user_entity_id,
         ENT.creator_type,
         ENT.notfound_allowed_flag,
         RO.route_id,
         RO.text,
         RO.optimizer_hint
  into   l_user_entity_id,
         l_creator_type,
         l_notfound_allowed_flag,
         l_route_id,
         l_text,
         l_o_hint
  from   ff_user_entities          ENT
  ,      ff_routes                 RO
  where  ent.user_entity_name = p_user_name
  and    ( (ENT.legislation_code is null and ENT.business_group_id is null)
          or (ENT.business_group_id is null
              and p_legislation_code = ENT.legislation_code )
          or ENT.business_group_id + 0 = p_business_group_id
         )
  and    ENT.route_id            = RO.route_id;
  --
  -- The following loop searches through and replaces all the bind variables
  -- (Bn) with the actual value for the context.  For a text value, the
  -- quotes also need to be inserted.
  --
  -- Load the route context cache to avoid re-execution of the cursor
  -- when binding values to bind variables
  --
  route_contexts_cache.sz := 0;
  for c1rec in ro_context (l_route_id) loop
    route_contexts_cache.sz := route_contexts_cache.sz + 1;
    route_contexts_cache.cxt_id(route_contexts_cache.sz) := c1rec.context_id;
    l_count := 0;
    l_context_found := FALSE;
    while (l_count < no_rows_con_tab) loop
      if (con_id_tab(l_count) = c1rec.context_id) then
        --
        -- Found a bind variable
        --
        l_context_found := TRUE;
        l_replace_text := ':' || ltrim(rtrim(con_name_tab(l_count)));
        l_text := replace (l_text, '&B'||to_char(c1rec.sequence_no),
                                   l_replace_text);
        exit;  -- exit while loop
      end if;
      l_count := l_count + 1;
    end loop;  -- end of while loop
    if (l_context_found = FALSE) then
      --
      -- Raise an error, as there are contexts that have not been set up in
      -- the pl/sql tables that are required by the route.
      --
      if g_debug then
         hr_utility.set_location ('pay_balance_pkg.get_run_balance', 10);
      end if;
      select context_name
      into   l_context_name
      from   ff_contexts
      where  context_id = c1rec.context_id;
      --
      hr_utility.set_message(801, 'HR_7271_PAY_CONTEXT_MISSING');
      hr_utility.set_message_token ('CONTEXT_NAME', l_context_name);
      hr_utility.raise_error;
    end if;
  end loop; -- end of for c1rec loop
  --
  -- The following loop searches through and replaces all where clause fillers
  -- (Un) with the value from ff_route_parameter_values.  For a text value,
  -- the quotes have already pre-inserted into this table.
  --
  -- Load the route parameters cache to avoid re-execution of the cursor
  -- when binding values to bind variables
  --
  route_parameters_cache.sz := 0;
  for c1rec in ro_wclause (l_user_entity_id, l_route_id) loop
    route_parameters_cache.sz := route_parameters_cache.sz + 1;
    route_parameters_cache.seq_no(route_parameters_cache.sz) := c1rec.sequence_no;
    route_parameters_cache.par_val(route_parameters_cache.sz) := c1rec.value;
    l_text := replace (l_text, '&U'||to_char(c1rec.sequence_no),
                                ':U'||to_char(c1rec.sequence_no));
  end loop;
  --
  -- Print the route text out for debug purposes.  Normally keep this line
  -- commented out, as for a large route it causes an error in the trace
  -- utility.
  -- hr_utility.trace (l_text);
  --
  --
  -- now build up the full SQL statement:
  --
  -- If route_type is SRB then in the first phase hardcoding the datatype
  -- (to 'N') and the select definition. If route_type is RR, then select the
  -- appropriate select definition.
  --
  if p_route_type = 'SRB' then
--
    if (l_o_hint is null) then
      l_text := 'SELECT NVL(SUM(prb.balance_value),0) FROM ' || l_text;
    else
      l_text := 'SELECT /*+ '||l_o_hint||
                ' */ NVL(SUM(prb.balance_value),0) FROM ' || l_text;
    end if;
--
    if g_debug then
       hr_utility.set_location('pay_balance_pkg.get_run_balance', 15);
    end if;
--
  elsif p_route_type = 'RR' then
    --
    -- Should never get here since all RRs are handled by run_rr_route now.
    --
    if g_debug then
       hr_utility.set_location('pay_balance_pkg.get_run_balance', 20);
    end if;
--
    hr_general.assert_condition(false);
--
  end if;
  --
  -- Now execute the SQL statement using dynamic pl/sql:
  --
  -- Dynamic sql steps:
  -- ==================
  -- 1. Open dynamic sql cursor
  -- 2. Parse dynamic sql
  -- 3. bind variables
  -- 4. Define dynamic sql columns
  -- 5. Execute and fetch dynamic sql
  -- 6. Get the sql value (providing there are rows returned)
  -- 7. Close the dynamic sql cursor
  --
  if g_debug then
     hr_utility.set_location ('pay_balance_pkg.get_run_balance', 35);
  end if;
  sql_cursor := dbms_sql.open_cursor;                             -- step 1
  --
  if g_debug then
     hr_utility.set_location ('pay_balance_pkg.get_run_balance', 40);
  end if;
  dbms_sql.parse(sql_cursor, l_text, dbms_sql.v7);                -- step 2
  --
  --                                                              -- step 3
  -- At this stage we have parsed the route.  Now bind the
  -- variables, starting with the contexts (B values).
  --
  for l_cxt_num in 1..route_contexts_cache.sz loop
    if g_debug then
       hr_utility.set_location ('pay_balance_pkg.get_run_balance', 45);
    end if;
    l_count := 0;
    l_context_found := FALSE;
    while (l_count < no_rows_con_tab) loop
      if (con_id_tab(l_count) = route_contexts_cache.cxt_id(l_cxt_num)) then
        if g_debug then
           hr_utility.trace (con_name_tab (l_count) ||' = '||
                             con_value_tab (l_count));
        end if;
        --
        -- Found a bind variable
        --
        if (con_type_tab (l_count) = 'D') then
          if g_debug then
             hr_utility.set_location ('pay_balance_pkg.get_run_balance', 50);
          end if;
          dbms_sql.bind_variable
           (sql_cursor,
            con_name_tab(l_count),
            fnd_date.canonical_to_date(ltrim(rtrim(con_value_tab (l_count)))));
        else
          if g_debug then
             hr_utility.set_location ('pay_balance_pkg.get_run_balance', 55);
          end if;
          dbms_sql.bind_variable
           (sql_cursor,
            con_name_tab(l_count),
            ltrim(rtrim(con_value_tab (l_count))));
        end if;
        l_context_found := TRUE;
        exit;  -- exit while loop
      end if;
      l_count := l_count + 1;
    end loop;  -- end of while loop
    if (l_context_found = FALSE) then
      --
      -- Raise an error, as there are contexts that have not been set up in
      -- the pl/sql tables that are required by the route.
      --
      if g_debug then
         hr_utility.set_location ('pay_balance_pkg.get_run_balance', 60);
      end if;
      select context_name
      into   l_context_name
      from   ff_contexts
      where  context_id = route_contexts_cache.cxt_id(l_cxt_num);
      --
      hr_utility.set_message(801, 'HR_7271_PAY_CONTEXT_MISSING');
      hr_utility.set_message_token ('CONTEXT_NAME', l_context_name);
      hr_utility.raise_error;
    end if;
  end loop; -- end of for route context loop
  --
  -- Now bind the where clause fillers (the 'U' values)
  --
  for l_par_num in 1..route_parameters_cache.sz loop
  if g_debug then
     hr_utility.set_location ('pay_balance_pkg.get_run_balance', 62);
  end if;
    dbms_sql.bind_variable (sql_cursor, 'U'||to_char(route_parameters_cache.seq_no(l_par_num)),
                                        route_parameters_cache.par_val(l_par_num));
  end loop;
  --
  if g_debug then
     hr_utility.set_location ('pay_balance_pkg.get_run_balance', 65);
  end if;
  dbms_sql.define_column (sql_cursor, 1, p_db_output, 80);        -- step 4
  --
  if g_debug then
     hr_utility.set_location ('pay_balance_pkg.get_run_balance', 70);
  end if;
  l_rows := dbms_sql.execute_and_fetch (sql_cursor, false);       -- step 5
  --
  if (l_rows = 1) then
    if g_debug then
       hr_utility.set_location ('pay_balance_pkg.get_run_balance', 75);
    end if;
    dbms_sql.column_value (sql_cursor, 1, p_db_output);           -- step 6
    --
    if g_debug then
       hr_utility.set_location ('pay_balance_pkg.get_run_balance', 80);
    end if;
    dbms_sql.close_cursor(sql_cursor);                            -- step 7
    --
    if g_debug then
       hr_utility.trace ('DB value = ' || p_db_output);
    end if;
    --
  elsif (l_rows = 0) then
    dbms_sql.close_cursor(sql_cursor);
    if (l_notfound_allowed_flag = 'Y') then
      --
      -- its ok to not find a row
      --
      if g_debug then
         hr_utility.set_location ('pay_balance_pkg.get_run_balance', 85);
      end if;
      p_db_output := null;
    else
      --
      -- Error, no rows found when the entity has been defined to always
      -- find a row.
      --
      hr_utility.set_message(801, 'HR_7272_PAY_NO_ROWS_RETURNED');
      hr_utility.set_message_token ('USER_ENTITY_NAME', p_user_name);
      hr_utility.raise_error;
    end if;
  else
    --
    -- More than 1 row have been returned. We must error as DB items can
    -- only return 1 row.
    --
    if g_debug then
       hr_utility.set_location ('pay_balance_pkg.get_run_balance', 95);
    end if;
    dbms_sql.close_cursor(sql_cursor);
    hr_utility.set_message(801, 'HR_7273_PAY_MORE_THAN_1_ROW');
    hr_utility.raise_error;
  end if;
  return p_db_output;
exception
  --
  -- If any other Oracle Error is trapped (e.g. during parse, execute,
  -- fetch etc), then we must check to see if the cursor is still open
  -- and close down if necessary.
  --
  When Others Then
    l_error_text := sqlerrm;
    if g_debug then
       Hr_Utility.Set_Location('pay_balance_pkg.get_run_balance', 100);
    end if;
    If (dbms_sql.is_open(sql_cursor)) then
      if g_debug then
         Hr_Utility.Set_Location('pay_balance_pkg.get_run_balance', 105);
      end if;
      dbms_sql.close_cursor(sql_cursor);
    End If;
    hr_utility.set_message(801, 'HR_7276_PAY_FAILED_DB_ITEM');
    hr_utility.set_message_token ('ERROR_MESSAGE', l_error_text);
    hr_utility.raise_error;
    --
end get_run_balance;
---------------------------------------------------------------------------
-- function run_db_item
---------------------------------------------------------------------------
-- Description
-- Previously a sql stmt was fired for every call to get_value, to return
-- the dbi user_name, business_group_id and legislation_code, to be used
-- in the call to run_db_item. run_db_item is only called when the balance
-- value has to be derived, so hopefully not often. Thus this overloaded
-- version of run_db_item has been created so that the sql statement, only
-- need be run as and when required.
--
function run_db_item (p_def_bal_id in number)
return varchar2 is
--
-- get the information required to retrieve the DB item.  It is assumed
-- here that there is a 1-to-1 mapping of database item and user entities.
-- If either legislation code or business group is null then any value
-- may be used in order to satisfy the parameters supplied to function
-- run_db_item.
--
cursor get_vals (p_def_bal number)
is
select dbi.user_name
,      nvl(ent.business_group_id, -1)
,      nvl(ent.legislation_code, ' ')
from   ff_database_items dbi
,      ff_user_entities  ent
where  ent.creator_id = p_def_bal
and    ent.creator_type = 'B'
and    ent.user_entity_id = dbi.user_entity_id;
--
l_balance_val       varchar2(240);
l_user_name         ff_database_items.user_name%type;
l_business_group_id ff_user_entities.business_group_id%type;
l_legislation_code  ff_user_entities.legislation_code%type;
--
BEGIN
open  get_vals(p_def_bal_id);
fetch get_vals into l_user_name, l_business_group_id, l_legislation_code;
close get_vals;
--
l_balance_val := run_db_item(l_user_name
                            ,l_business_group_id
                            ,l_legislation_code);
return l_balance_val;
--
END run_db_item;
--------------------------------------------------------------------------
-- function get_run_balance
---------------------------------------------------------------------------
-- Description
-- Previously a sql stmt was fired for every call to get_value, to return
-- the dbi user_name, business_group_id and legislation_code, to be used
-- in the call to run_db_item. run_db_item is only called when the balance
-- value has to be derived, so hopefully not often. Thus this overloaded
-- version of run_db_item has been created so that the sql statement, only
-- need be run as and when required.
--
function get_run_balance (p_def_bal_id in number
                         ,p_priority   in number
                         ,p_route_type in varchar2)
return number is
--
-- get the information required to retrieve the DB item.  It is assumed
-- here that there is a 1-to-1 mapping of database item and user entities.
-- If either legislation code or business group is null then any value
-- may be used in order to satisfy the parameters supplied to function
-- run_db_item.
--
cursor get_vals (p_def_bal number
                ,p_prty    number)
is
select fue.user_entity_name
,      nvl(fue.business_group_id, -1)
,      nvl(fue.legislation_code, ' ')
from   ff_user_entities fue
,      ff_user_entities fue_b
where  fue.creator_id = p_def_bal
and    fue_b.creator_type = 'B'
and    fue.creator_id = fue_b.creator_id
and    fue.creator_type = 'RB'
and    fue.user_entity_name = fue_b.user_entity_name||'_'||to_char(p_prty)
;
--
l_balance_val       number;
l_user_name         ff_user_entities.user_entity_name%type;
l_business_group_id ff_user_entities.business_group_id%type;
l_legislation_code  ff_user_entities.legislation_code%type;
l_balance_list      t_batch_list;
l_balance_type_id   pay_defined_balances.balance_type_id%type;
l_route_id          pay_dimension_routes.route_id%type;
l_balance_type_column pay_dimension_routes.balance_type_column%type;
l_retrieval_column    pay_dimension_routes.retrieval_column%type;
l_decode_required     boolean;
l_decode_required_chr pay_dimension_routes.decode_required%type;
l_jur_lvl             pay_balance_types.jurisdiction_level%type;
--
BEGIN
  if g_debug then
     hr_utility.set_location('Entering pay_balance_pkg.get_run_bal', 10);
  end if;
--
  if (p_route_type = 'RR') then
--
    if g_debug then
       hr_utility.set_location('Entering pay_balance_pkg.get_run_bal', 15);
    end if;
    select pdb.balance_type_id,
           pdr.route_id,
           pdr.balance_type_column,
           pdr.retrieval_column,
           nvl(pdr.decode_required, 'N'),
           nvl(jurisdiction_level, 0)
      into l_balance_type_id,
           l_route_id,
           l_balance_type_column,
           l_retrieval_column,
           l_decode_required_chr,
           l_jur_lvl
      from pay_defined_balances pdb,
           pay_dimension_routes pdr,
           pay_balance_types    pbt
     where pdb.defined_balance_id = p_def_bal_id
       and pdb.balance_dimension_id = pdr.balance_dimension_id
       and pbt.balance_type_id = pdb.balance_type_id
       and pdr.priority = p_priority;
--
    l_decode_required := FALSE;
    if (l_decode_required_chr = 'Y') then
      l_decode_required := TRUE;
    end if;
    l_balance_list.delete;
    run_rr_route(
                 FALSE,
                 l_balance_type_id,
                 l_balance_list,
                 l_route_id,
                 l_balance_type_column,
                 l_retrieval_column,
                 l_decode_required,
                 l_jur_lvl,
                 l_balance_val
                );
--
  else
--
    open  get_vals(p_def_bal_id, p_priority);
    fetch get_vals into l_user_name, l_business_group_id, l_legislation_code;
    close get_vals;
--
    if g_debug then
       hr_utility.set_location('pay_balance_pkg.get_run_bal', 20);
       hr_utility.trace('l_user_entity_name is: '||l_user_name);
    end if;
    l_balance_val := get_run_balance(l_user_name
                                    ,l_business_group_id
                                    ,l_legislation_code
                                    ,p_route_type);
  end if;
  if g_debug then
     hr_utility.trace('Val = '||l_balance_val);
  end if;
  return l_balance_val;
--
END get_run_balance;
--
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--
--                            get_rr_value                                +
--                                                                        +
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
/*
NAME

        get_rr_value  -  Get the balance value based on Run Results

DESCRIPTION

*/
procedure get_rr_value(p_defined_balance_id in         number,
                       p_balance_value      out nocopy number)
is
--
l_balance_value  number;
l_route_count    number;
l_defbal_rec            t_def_bal_rec;
--
begin
  if g_debug then
     hr_utility.set_location ('Entering: pay_balance_pkg.get_rr_value', 5);
  end if;
--
  -- First load the cache
  load_defbal_cache(p_defined_balance_id,
                    l_defbal_rec);
--
  if l_defbal_rec.rr_ptr is not null then
    if g_debug then
       hr_utility.set_location ('Entering: pay_balance_pkg.get_rr_value', 10);
    end if;
    l_balance_value := get_run_balance(p_defined_balance_id
                                      ,g_dimrou_cache(l_defbal_rec.rr_ptr).priority
                                      ,g_dimrou_cache(l_defbal_rec.rr_ptr).route_type);
  else
--
    if g_debug then
       hr_utility.set_location ('Entering: pay_balance_pkg.get_rr_value', 20);
    end if;
    if (l_defbal_rec.start_rb_ptr is not null) then
       hr_general.assert_condition(false);
    else
       if g_debug then
          hr_utility.set_location ('Entering: pay_balance_pkg.get_rr_value', 30);
       end if;
       l_balance_value := fnd_number.canonical_to_number(run_db_item(p_defined_balance_id));
    end if;
  end if;
  --
  -- Setup the return values
  --
  p_balance_value := l_balance_value;
  if g_debug then
     hr_utility.set_location ('Leaving: pay_balance_pkg.get_rr_value', 45);
  end if;
--
end get_rr_value;
--
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--
--                            get_rb_status                               +
--                                                                        +
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
/*
NAME

        get_rb_status  -  Work out the Run Balance Status for the
                          Balance being retrieved.

DESCRIPTION

*/
--
procedure get_rb_status (p_retreival_db_id in            number,
                         p_run_db_id       in            number,
                         p_asg_action_id   in            number,
                         p_status             out nocopy varchar2)
is
--
l_run_bal_status  pay_balance_validation.run_balance_status%type;
l_load_date       pay_balance_validation.balance_load_date%type;
l_retrieval_date  pay_payroll_actions.effective_date%type;
l_bus_grp_id      pay_payroll_actions.business_group_id%type;
l_payroll_id      pay_payroll_actions.payroll_id%type;
l_period_type     pay_balance_dimensions.period_type%type;
l_start_date_code pay_balance_dimensions.start_date_code%type;
l_action_type     pay_payroll_actions.action_type%type;
l_start_date      date;
--
begin
--
  -- Use cache on the payroll action information for this assignment
  -- action.  Bug 4221840.
  if p_asg_action_id <> nvl(g_aa_id, -p_asg_action_id) Then
   select ppa.effective_date,
          ppa.business_group_id,
          ppa.payroll_id,
          ppa.action_type
     into g_retrieval_date,
          g_bus_grp_id,
          g_payroll_id,
          g_action_type
     from pay_payroll_actions    ppa,
          pay_assignment_actions paa
    where paa.assignment_action_id = p_asg_action_id
      and paa.payroll_action_id = ppa.payroll_action_id;

    g_aa_id := p_asg_action_id;
  end if;
--
  l_retrieval_date := g_retrieval_date;
  l_bus_grp_id := g_bus_grp_id;
  l_payroll_id := g_payroll_id;
  l_action_type := g_action_type;
--
  select pbv.run_balance_status, pbv.balance_load_date
     into l_run_bal_status, l_load_date
     from pay_balance_validation pbv
    where pbv.defined_balance_id = p_run_db_id
      and pbv.business_group_id = l_bus_grp_id;
--
   if (l_run_bal_status = 'V') then
    if (l_load_date is not null) then
--
      --
      -- OK, the balances have been loaded from a
      -- specific date. We need to workout whether
      -- we can use the run balances.
      --
      select nvl(pbd.period_type, 'NULL'),
             pbd.start_date_code
        into l_period_type,
             l_start_date_code
        from pay_balance_dimensions pbd,
             pay_defined_balances   pdb
       where pdb.defined_balance_id = p_retreival_db_id
         and pdb.balance_dimension_id = pbd.balance_dimension_id;

--
      -- If we don't know the retrieval period type
      -- then we must assume we cannot use run balances.
      if (l_period_type = 'NULL') then
        l_run_bal_status := 'I';
      else
        get_period_type_start(l_period_type,
                              l_retrieval_date,
                              l_start_date,
                              l_start_date_code,
                              l_payroll_id,
                              l_bus_grp_id,
                              l_action_type,
                              p_asg_action_id);
--
        if (l_start_date < l_load_date) then
          l_run_bal_status := 'I';
        end if;
      end if;
    end if;
   end if;
--
   p_status := l_run_bal_status;
--
exception
--
   when no_data_found then
--
      p_status := 'I'; -- Invalid
--
end get_rb_status;
--
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--
--                            get_rb_value                                +
--                                                                        +
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
/*
NAME

        get_rb_value  -  Get the balance value based on Run Balances

DESCRIPTION

*/
procedure get_rb_value(p_defined_balance_id in         number,
                       p_asg_action_id      in         number,
                       p_found              out nocopy boolean,
                       p_balance_value      out nocopy number)
is
--
CURSOR get_rb_routes(p_def_bal_id number)
IS
select pdr.run_dimension_id
,      pdr.priority
,      pdr.route_type
,      rdb.defined_balance_id run_def_bal_id
from   pay_dimension_routes pdr
,      pay_defined_balances pdb -- balance defined balance
,      pay_defined_balances rdb -- run defined balance
where pdb.balance_dimension_id = pdr.balance_dimension_id
and    pdb.defined_balance_id = p_def_bal_id
and    rdb.balance_type_id = pdb.balance_type_id
and    rdb.balance_dimension_id = pdr.run_dimension_id
and    pdr.route_type = 'SRB'
order by 2;
--
l_balval_found   boolean;
l_valid          pay_defined_balances.run_balance_status%type;
l_balance_value  number;
l_defbal_rec            t_def_bal_rec;
l_position       number;
--
begin
  if g_debug then
     hr_utility.set_location ('Entering: pay_balance_pkg.get_rb_value', 5);
  end if;
--
  -- First load the cache
  load_defbal_cache(p_defined_balance_id,
                    l_defbal_rec);
  l_balval_found := FALSE;
  l_position     := l_defbal_rec.start_rb_ptr;
--
  if (l_defbal_rec.start_rb_ptr is not null) then
    while (l_balval_found = FALSE
          and l_position <= l_defbal_rec.end_rb_ptr) loop
      --
      -- see if route definition can be used i.e.defined balance has
      -- run_balance_status of V(ALID) and saved_to_run_balances flag is 'Y'
      --
--
      get_rb_status(p_defined_balance_id,
                    g_dimrou_cache(l_position).run_def_bal_id,
                    p_asg_action_id,
                    l_valid);
      --
      if g_debug then
         hr_utility.set_location ('pay_balance_pkg.get_rb_value', 20);
      end if;
      --
      -- now know that run balance exists and is valid, so call run_db_item to
      -- return the balance_value.
      --
      if l_valid = 'V' then
        if g_debug then
           hr_utility.set_location ('pay_balance_pkg.get_rb_value', 25);
        end if;
        l_balance_value := get_run_balance(p_defined_balance_id
                                          ,g_dimrou_cache(l_position).priority
                                          ,g_dimrou_cache(l_position).route_type);
        l_balval_found := TRUE;
      end if;
      --
      l_position := l_position + 1;
      --
    end loop;
  end if;
  --
  if g_debug then
     hr_utility.set_location ('pay_balance_pkg.get_rb_value', 35);
  end if;
--
  --
  -- Setup the return values
  --
  p_found := l_balval_found;
  p_balance_value := l_balance_value;
  if g_debug then
     hr_utility.set_location ('Leaving: pay_balance_pkg.get_rb_value', 45);
  end if;
--
end get_rb_value;
--
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--                                                                        +
--                        check_bal_expiry_internal                       +
--                                                                        +
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--
/*
NAME
  check_bal_expiry_internal  - See if the balance has expired
--
DESCRIPTION
  Checks whether a balance has expired and returns a mode value:
  --
  0   : Balance has not expired (Current).
  1   : Balance expired
  2   : Previous Period Balance Value
  3   : Current Period Balance Value
  4   : Balance has Rolled over.
  --
  The pl/sql function name that checks whether the balance has expired is
  passed to this routine as 'p_expiry_checking_code'.  The call to the
  function is done using dynamic pl/sql.
*/
function check_bal_expiry_internal
(
   p_bal_owner_asg_action       in     number,    -- assact created balance.
   p_assignment_action_id       in     number,    -- current assact..
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_checking_level      in     varchar2,
   p_expiry_checking_code       in     varchar2,
   p_bal_context_str            in     varchar2   -- list of context values.
) return number is
p_balance_expired number;
--
l_bal_owner_pay_action  pay_payroll_actions.payroll_action_id%type;
l_bal_owner_eff_date    pay_payroll_actions.effective_date%type;
l_payroll_action        pay_payroll_actions.payroll_action_id%type;
l_effective_date        pay_payroll_actions.effective_date%type;
l_jul_effect_date       number;          -- Julian value of effective date
l_expiry_chk_str        varchar2(2000);  -- used with dynamic pl/sql
l_expiry_information    number;
sql_cursor              integer;
l_rows                  integer;
l_error_text            varchar2(200);   -- used for sql error messages
l_value_found           number;
begin
  if g_debug then
     hr_utility.set_location ('pay_balance_pkg.check_bal_expiry_internal', 1);
     hr_utility.trace ('Expiry check level   = ' || p_expiry_checking_level);
     hr_utility.trace ('Expiry checking code = ' || p_expiry_checking_code);
  end if;
  if (p_expiry_checking_level = 'N') then
    --
    -- There is no expiry check code to run, so balance can't expire
    --
    p_balance_expired := BALANCE_NOT_EXPIRED;
    return p_balance_expired;
  end if;
  --
  -- get the payroll_action_id for the balance (ie. owner):
  --
  if g_debug then
     hr_utility.set_location ('pay_balance_pkg.check_bal_expiry_internal', 10);
  end if;
  select PAY.payroll_action_id,
         PAY.effective_date
  into   l_bal_owner_pay_action,
         l_bal_owner_eff_date
  from   pay_assignment_actions        ASG
  ,      pay_payroll_actions           PAY
  where  ASG.assignment_action_id    = p_bal_owner_asg_action
  and    PAY.payroll_action_id       = ASG.payroll_action_id;
  --
  -- get the actual payroll information for this assignment action:
  --
  if g_debug then
     hr_utility.set_location ('pay_balance_pkg.check_bal_expiry_internal', 15);
  end if;
  select PAY.payroll_action_id,
         PAY.effective_date
  into   l_payroll_action,
         l_effective_date
  from   pay_assignment_actions        ASG
  ,      pay_payroll_actions           PAY
  where  ASG.assignment_action_id    = p_assignment_action_id
  and    PAY.payroll_action_id       = ASG.payroll_action_id;
  --
  -- before building up the sql string to call the expiry checking pl/sql
  -- procedure, if the expiry_checking_level is P or E, then check the
  -- expiry checking cache.
  --
  if p_expiry_checking_level in ('P', 'E') then
  --
    for each_row in 1..t_own_pay_action.count loop
    --
      if t_own_pay_action(each_row) = l_bal_owner_pay_action
      and
         t_usr_pay_action(each_row) = l_payroll_action
      and
         t_dim_nm(each_row) = p_dimension_name
      then
        l_value_found := t_expiry(each_row);
      end if;
    end loop;
  end if; -- if p_expiry_checking_level in ('P', 'E')
  --
  -- if l_value_found is null, then the value for the current row has not
  -- yet been cached, or the expiry_checking_level is not P or E, so figure
  -- out what it should be, then cache the new row, i.e. return to original
  -- code, before caching introduced
  --
  IF l_value_found IS NULL THEN
  --
  -- we now have all the data required to build up the sql string to call
  -- the expiry checking pl/sql procedure:
  --
  l_expiry_chk_str := 'begin ' || p_expiry_checking_code || ' (';
  l_expiry_chk_str := l_expiry_chk_str || ':l_bal_owner_pay_action, ';
  l_expiry_chk_str := l_expiry_chk_str || ':l_payroll_action, ';
  l_expiry_chk_str := l_expiry_chk_str || ':p_bal_owner_asg_action, ';
  l_expiry_chk_str := l_expiry_chk_str || ':p_assignment_action_id, ';
  l_expiry_chk_str := l_expiry_chk_str || ':l_bal_owner_eff_date, ';
  l_expiry_chk_str := l_expiry_chk_str || ':l_effective_date, ';
  l_expiry_chk_str := l_expiry_chk_str || ':p_dimension_name, ';
  --
  if (p_expiry_checking_level in ('A', 'D')) then
    l_expiry_chk_str := l_expiry_chk_str || ':p_bal_context_str, ';
  end if;
  --
  l_expiry_chk_str := l_expiry_chk_str || ':l_expiry_information); end;';
  --
  -- now execute the SQL statement using dynamic pl/sql:
  --
  -- Dynamic sql steps:
  -- ==================
  -- 1. Open dynamic sql cursor
  -- 2. Parse dynamic sql
  -- 3. bind variables
  -- 4. Execute dynamic sql
  -- 5. Get the variable value (providing there are rows returned)
  -- 6. Close the dynamic sql cursor
  --
  if g_debug then
     hr_utility.set_location ('pay_balance_pkg.check_bal_expiry_internal', 20);
  end if;
  sql_cursor := dbms_sql.open_cursor;                             -- step 1
  --
  if g_debug then
     hr_utility.set_location ('pay_balance_pkg.check_bal_expiry_internal', 25);
  end if;
  dbms_sql.parse(sql_cursor, l_expiry_chk_str, dbms_sql.v7);      -- step 2
  --
  if g_debug then
     hr_utility.set_location ('pay_balance_pkg.check_bal_expiry_internal', 30);
  end if;
  dbms_sql.bind_variable(sql_cursor, 'l_bal_owner_pay_action',    -- step 3:
                                      l_bal_owner_pay_action);
  --
  dbms_sql.bind_variable(sql_cursor, 'l_payroll_action',
                                      l_payroll_action);
  --
  dbms_sql.bind_variable(sql_cursor, 'p_bal_owner_asg_action',
                                      p_bal_owner_asg_action);
  --
  dbms_sql.bind_variable(sql_cursor, 'p_assignment_action_id',
                                      p_assignment_action_id);
  --
  dbms_sql.bind_variable(sql_cursor, 'l_bal_owner_eff_date',
                                      l_bal_owner_eff_date);
  --
  dbms_sql.bind_variable(sql_cursor, 'l_effective_date',
                                      l_effective_date);
  --
  dbms_sql.bind_variable(sql_cursor, 'p_dimension_name',
                                      p_dimension_name);
  --
  if (p_expiry_checking_level in ('A', 'D')) then
    dbms_sql.bind_variable(sql_cursor, 'p_bal_context_str',
                                        p_bal_context_str);
  end if;
  --
  dbms_sql.bind_variable(sql_cursor, 'l_expiry_information',
                                      l_expiry_information);
  --
  if g_debug then
     hr_utility.set_location ('pay_balance_pkg.check_bal_expiry_internal', 35);
  end if;
  l_rows := dbms_sql.execute (sql_cursor);                        -- step 4
  --
  if (l_rows = 1) then
    if g_debug then
       hr_utility.set_location ('pay_balance_pkg.check_bal_expiry_internal', 40);
    end if;
    dbms_sql.variable_value(sql_cursor, 'l_expiry_information',   -- step 5
                                         l_expiry_information);
    --
    if g_debug then
       hr_utility.set_location ('pay_balance_pkg.check_bal_expiry_internal', 45);
    end if;
    dbms_sql.close_cursor(sql_cursor);                            -- step 6
  elsif (l_rows = 0) then
    dbms_sql.close_cursor(sql_cursor);
      hr_utility.set_message(801, 'HR_7274_PAY_NO_EXPIRY_CODE');
      hr_utility.set_message_token ('EXPIRY_CODE', p_expiry_checking_code);
      hr_utility.raise_error;
  else
    --
    -- More than 1 row has been returned. We must error as package call can
    -- only return 1 row, so this condition should never occur !
    --
    if g_debug then
       hr_utility.set_location ('pay_balance_pkg.check_bal_expiry_internal', 111);
    end if;
    dbms_sql.close_cursor(sql_cursor);
    hr_utility.raise_error;
  end if;
  --
  -- At this point we have executed the dynamic pl/sql, 1 row was returned
  -- with the expiry information in the value 'l_expiry_information'.
  -- If the expiry checking level is Assignment, Payroll action or Enhanced
  -- the expiry value is returned.  For a date level expiry checking, a julian
  -- date is returned which has to be compared with the effective date of the
  -- payroll action.
  --
  if (p_expiry_checking_level in ('A', 'P', 'E')) then
    if g_debug then
       hr_utility.set_location ('pay_balance_pkg.check_bal_expiry_internal', 50);
    end if;
    p_balance_expired := l_expiry_information;
  else                                 -- date level
    if g_debug then
       hr_utility.set_location ('pay_balance_pkg.check_bal_expiry_internal', 55);
    end if;
    l_jul_effect_date := to_number (to_char (l_effective_date, 'J'));
    --
    if (l_expiry_information < l_jul_effect_date) then
      p_balance_expired := BALANCE_EXPIRED;       -- The balance has expired
    else
      p_balance_expired := BALANCE_NOT_EXPIRED;   -- The balance has not expired
    end if;
  end if;
  --
  -- Now have the expired value so cache the new row, if the expiry_checking_
  -- level is P or E.
  --
  if p_expiry_checking_level in ('P', 'E') then
  --
    t_own_pay_action(t_own_pay_action.count + 1) := l_bal_owner_pay_action;
    t_usr_pay_action(t_usr_pay_action.count + 1) := l_payroll_action;
    t_dim_nm(t_dim_nm.count + 1) := p_dimension_name;
    t_expiry(t_expiry.count + 1) := p_balance_expired;
    --
    if g_debug then
       hr_utility.trace('cached own pay action: '||
                       to_char(t_own_pay_action(t_own_pay_action.count)));
       hr_utility.trace('cached usr pay action: '||
                       to_char(t_usr_pay_action(t_usr_pay_action.count)));
       hr_utility.trace('cached dim name: '||t_dim_nm(t_dim_nm.count));
       hr_utility.trace('cached bal expired: '||t_expiry(t_expiry.count));
    end if;
    --
  end if;
  --
  return p_balance_expired;
  --
  ELSE
    return l_value_found;
  END IF; -- if l_value_found is null
  --
exception
  --
  -- If any other Oracle Error is trapped (e.g. during parse, execute,
  -- fetch etc), then we must check to see if the cursor is still open
  -- and close down if necessary.
  --
  When Others Then
    l_error_text := sqlerrm;
    if g_debug then
       Hr_Utility.Set_Location('check_bal_expiry_internal', 115);
    end if;
    If (dbms_sql.is_open(sql_cursor)) then
      if g_debug then
         Hr_Utility.Set_Location('check_bal_expiry_internal', 120);
      end if;
      dbms_sql.close_cursor(sql_cursor);
    End If;
    hr_utility.set_message(801, 'HR_7275_PAY_FAILED_IN_EXPIRY');
    hr_utility.set_message_token ('ERROR_MESSAGE', l_error_text);
    hr_utility.raise_error;
end check_bal_expiry_internal;
--
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--                                                                        +
--                        check_bal_expiry                                +
--                                                                        +
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--
/*
NAME
  check_bal_expiry  - See if the balance has expired
--
DESCRIPTION
  Checks whether a balance has expired and returns a boolean value:
  --
  TRUE   : Balance expired
  FALSE  : Balance has not expired.
  --
  The pl/sql function name that checks whether the balance has expired is
  passed to this routine as 'p_expiry_checking_code'.  The call to the
  function is done using dynamic pl/sql.
*/
function check_bal_expiry
(
   p_bal_owner_asg_action       in     number,    -- assact created balance.
   p_assignment_action_id       in     number,    -- current assact..
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_checking_level      in     varchar2,
   p_expiry_checking_code       in     varchar2,
   p_bal_context_str            in     varchar2   -- list of context values.
) return boolean is
p_balance_expired boolean;
l_exp_code number;
--
begin
   g_debug := hr_utility.debug_enabled;
--
   l_exp_code := check_bal_expiry_internal(p_bal_owner_asg_action,
                                 p_assignment_action_id,
                                 p_dimension_name,
                                 p_expiry_checking_level,
                                 p_expiry_checking_code,
                                 p_bal_context_str);
  if (l_exp_code = BALANCE_NOT_EXPIRED) then
     p_balance_expired := FALSE;
  else
     p_balance_expired := TRUE;
  end if;
--
  return p_balance_expired;
--
end check_bal_expiry;
--
--
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--
--                            get_old_latest_bal_value                    +
--                                                                        +
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
/*
NAME

        get_old_latest_bal_value  -  Get the balance value based on Latest
                                     Balances

DESCRIPTION

*/
procedure get_old_latest_bal_value(p_defined_balance_id   in         number,
                               p_assignment_action_id in         number,
                               p_defbal_rec           in         t_def_bal_rec,
                               p_balance_value        out nocopy number,
                               p_found                out nocopy boolean)
is
--
-- The following cursor is used to determine whether there is a latest balance
-- available for the requested assignment action.  This involves checking that
-- the balance is available for the particular assignment_id or person_id, AND
-- that the date of the requested balance is the greater or equal to the date
-- for the latest balance.  (This stops the case where a balance is requested
-- for a date/ action that is in the past, obviously we can't use the
-- 'latest' balance value).  In prevous versions (40.4 and earlier) this was
-- done by comparing the effective date on the payroll actions table,
-- (and PACT.effective_date >= OWN_PACT.effective_date).  However this fails
-- for payroll runs on the same day.  The better comparision is to use
-- assignment sequence.
-- note : The OWN... aliases are the assignment actions that own the balance.
--
cursor bal_contexts_asg
is
select ASGBAL.latest_balance_id,
       ASGBAL.assignment_action_id,
       ASGBAL.value,
       ACT.action_sequence      current_action_seq,
       OWN_ACT.action_sequence  owner_action_seq,
       ASGBAL.expired_assignment_action_id,
       ASGBAL.expired_value,
       ASGBAL.prev_assignment_action_id,
       ASGBAL.prev_balance_value
from   pay_assignment_latest_balances  ASGBAL
,      pay_assignment_actions          ACT
,      pay_assignment_actions          OWN_ACT
where  ASGBAL.defined_balance_id     = p_defined_balance_id
and    ACT.assignment_action_id      = p_assignment_action_id
and    ASGBAL.assignment_id          = ACT.assignment_id
and    OWN_ACT.assignment_action_id  = ASGBAL.assignment_action_id
--and    ACT.action_sequence          >= OWN_ACT.action_sequence
order  by ASGBAL.latest_balance_id;
--
cursor bal_contexts_per
is
select PERBAL.latest_balance_id,
       PERBAL.assignment_action_id,
       PERBAL.value,
       ACT.action_sequence      current_action_seq,
       OWN_ACT.action_sequence  owner_action_seq,
       PERBAL.expired_assignment_action_id,
       PERBAL.expired_value,
       PERBAL.prev_assignment_action_id,
       PERBAL.prev_balance_value
from   pay_person_latest_balances      PERBAL
,      per_all_assignments_f           ASSIGN
,      pay_assignment_actions          ACT
,      pay_payroll_actions             PACT
,      pay_assignment_actions          OWN_ACT
where  PERBAL.defined_balance_id     = p_defined_balance_id
and    ACT.assignment_action_id      = p_assignment_action_id
and    ASSIGN.assignment_id          = ACT.assignment_id
and    PERBAL.person_id              = ASSIGN.person_id
and    PACT.payroll_action_id        = ACT.payroll_action_id
and    PACT.effective_date     between ASSIGN.effective_start_date
                                   and ASSIGN.effective_end_date
and    OWN_ACT.assignment_action_id  = PERBAL.assignment_action_id
--and    ACT.action_sequence          >= OWN_ACT.action_sequence
order  by PERBAL.latest_balance_id;
--
-- The following cursor is used to get the contexts that are used for a
-- particular latest balance.
--
cursor bal_context_values (p_latest_balance_id number)
is
select CONVAL.context_id,
       CONVAL.value,
       CON.context_name
from   pay_balance_context_values     CONVAL
,      ff_contexts                    CON
where  latest_balance_id            = p_latest_balance_id
and    CON.context_id               = CONVAL.context_id
order  by 1;
--
l_balance_value         pay_person_latest_balances.value%type;
l_bal_owner_asg_action  pay_person_latest_balances.assignment_action_id%type;
l_bal_owner_act_seq     pay_assignment_actions.action_sequence%type;
l_bal_asg_act_seq       pay_assignment_actions.action_sequence%type;
l_bal_expired_action
                 pay_person_latest_balances.expired_assignment_action_id%type;
l_bal_expired_value     pay_person_latest_balances.expired_value%type;
l_prev_action    pay_person_latest_balances.prev_assignment_action_id%type;
l_prev_value            pay_person_latest_balances.prev_balance_value%type;
l_latest_balance_id     pay_person_latest_balances.latest_balance_id%type;
--
l_num_of_runs           number;
l_bal_con_str           varchar2(500);   -- Balance context string
l_balance_found         boolean;
l_fnd_con_and_val       boolean;
l_found_all_contexts    boolean;
l_balance_expired       number;
l_cursor_executed       boolean;
l_count                 binary_integer;
loc_value_tab           con_val_array;
l_found                 boolean;
l_expiry_needed         boolean;
--
begin
--
  l_found := FALSE;
  l_balance_value := 0;
  l_expiry_needed := TRUE;
  --
  -- There could be a latest balance available.  Take a copy of the context
  -- value table, and if jurisdiction code is present, apply the substr
  -- function. (The values stored in the balance context values table have
  -- already been substr'ed for jurisdiction code).
  --
  loc_value_tab := con_value_tab;
  --
  l_count := 0;
  while (l_count < no_rows_con_tab) loop
    if (con_name_tab (l_count) = 'JURISDICTION_CODE') then
       --
       if g_debug then
          hr_utility.set_location ('pay_balance_pkg.get_old_latest_bal_value', 15)
;
       end if;
       loc_value_tab (l_count) := substr (loc_value_tab(l_count), 1,
                                          p_defbal_rec.jurisdiction_lvl);
       if g_debug then
          hr_utility.trace ('substr jur. code = ' || loc_value_tab (l_count));
       end if;
       exit;   -- exit while loop
    end if;
    l_count := l_count + 1;
  end loop;
  --
  -- The following cursor loops are the final search for a latest balance.
  -- If both the context name and context values match, then there is a
  -- latest balance present.
  --
  l_balance_found := FALSE;
  ---
  IF p_defbal_rec.dimension_type = 'A' THEN
    open bal_contexts_asg;
  ELSE
    OPEN bal_contexts_per;
  END IF;
  --
  LOOP
    if g_debug then
       hr_utility.set_location ('pay_balance_pkg.get_old_latest_bal_value', 20);
    end if;
    --
    IF p_defbal_rec.dimension_type = 'A' THEN
      FETCH bal_contexts_asg INTO l_latest_balance_id,
                                  l_bal_owner_asg_action,
                                  l_balance_value,
                                  l_bal_asg_act_seq,
                                  l_bal_owner_act_seq,
                                  l_bal_expired_action,
                                  l_bal_expired_value,
                                  l_prev_action,
                                  l_prev_value;
      EXIT WHEN bal_contexts_asg%NOTFOUND;
    ELSE
      FETCH bal_contexts_per INTO l_latest_balance_id,
                                  l_bal_owner_asg_action,
                                  l_balance_value,
                                  l_bal_asg_act_seq,
                                  l_bal_owner_act_seq,
                                  l_bal_expired_action,
                                  l_bal_expired_value,
                                  l_prev_action,
                                  l_prev_value;
      EXIT WHEN bal_contexts_per%NOTFOUND;
    END IF;
    --
    -- initialise variables:
    --
    l_found_all_contexts := FALSE;
    l_bal_con_str        := null;
    l_cursor_executed    := FALSE;
    for c2rec in bal_context_values (l_latest_balance_id) loop
      if g_debug then
         hr_utility.set_location ('pay_balance_pkg.get_old_latest_bal_value', 25);
      end if;
      --
      -- Try to find the context:
      --
      l_fnd_con_and_val := FALSE;
      l_cursor_executed := TRUE;
      l_count := 0;
      if g_debug then
         hr_utility.trace ('Trying to match ' || c2rec.context_name);
      end if;
      --
      while (l_count < no_rows_con_tab) loop
        if ((con_id_tab    (l_count) = c2rec.context_id) AND
            (ltrim(rtrim(loc_value_tab (l_count))) = c2rec.value)) then
          --
          -- found a matching context name AND value
          --
          if g_debug then
             hr_utility.trace ('match found');
          end if;
          l_fnd_con_and_val := TRUE;
          --
          -- Since we have the context name and value at this point, build
          -- up the context string for possible use later in the expiry
          -- checking code.  (note, we only need this string for expiry
          -- checking levels of assignment or date, not payroll action).
          --
          if (p_defbal_rec.expiry_check_lvl in ('A', 'D')) then
            l_bal_con_str := l_bal_con_str || con_name_tab(l_count);
            l_bal_con_str := l_bal_con_str || '=';
            l_bal_con_str := l_bal_con_str || c2rec.value;
            l_bal_con_str := l_bal_con_str || ' ';
          end if;
          exit;   -- exit while loop
        end if;
        l_count := l_count + 1;
      end loop;                                             -- end while
      --
      if (l_fnd_con_and_val = TRUE) then
        --
        -- Found all contexts so far.  set flag, and check next context.
        --
        l_found_all_contexts := TRUE;
      else
        --
        -- Failed to find a matching context name and value, so clear
        -- flags and exit inner context cursor loop (c2rec)
        --
        if g_debug then
           hr_utility.trace ('match failed');
        end if;
        l_found_all_contexts := FALSE;
        exit; -- exit c2rec
      end if;
    end loop;                                               -- end c2rec
    --
    -- As this point (the exit of c2rec cursor) we have checked through
    -- for matching contexts for a particular latest_balance_id.  If we
    -- have found all the contexts AND values match then we have found the
    -- balance.  Also if the c2rec cursor was never executed then there
    -- were no rows in the context table, ie. the route does not use any
    -- contexts (apart from assignment action id). Therefore we have a
    -- match.
    -- Else carry on to the next latest_balance_id.
    --
    if ((l_found_all_contexts = TRUE) OR (l_cursor_executed = FALSE)) then
      if g_debug then
         hr_utility.set_location ('pay_balance_pkg.get_old_latest_bal_value', 35);
      end if;
      l_balance_found := TRUE;
      exit; -- exit c1rec
    end if;
  end loop;                                                 -- end asg/per loop
  --
  IF p_defbal_rec.dimension_type = 'A' THEN
    CLOSE bal_contexts_asg;
  ELSE
    CLOSE bal_contexts_per;
  END IF;
  --
  -- If we could not find a latest balance, then derive from ff_routes
  --
  if g_debug then
     hr_utility.set_location ('pay_balance_pkg.get_old_latest_bal_value', 37);
  end if;
  if (l_balance_found = TRUE) then
    if g_debug then
       hr_utility.set_location ('pay_balance_pkg.get_old_latest_bal_value', 38);
       hr_utility.trace('OWN SEQ '||l_bal_owner_act_seq);
       hr_utility.trace('CURR SEQ '||l_bal_asg_act_seq);
    end if;
    --
    -- Check that the current assignment_action is the same as the
    -- owner action, if so there is no need for expiry checking.
    --
    if (p_assignment_action_id = l_bal_owner_asg_action) then
       l_found := TRUE;
       l_expiry_needed := FALSE;
    elsif (p_assignment_action_id = l_bal_expired_action) then
       l_balance_value := l_bal_expired_value;
       l_found := TRUE;
       l_expiry_needed := FALSE;
    elsif (p_assignment_action_id = l_prev_action) then
       l_balance_value := l_prev_value;
       l_found := TRUE;
       l_expiry_needed := FALSE;
    --
    -- A latest balance row has been found but can it be used for this
    -- effective date. Must check the action sequences of the owning
    -- assignment_action.
    -- Or is it a special balance expiry level 'E'
    --
    elsif ((l_bal_owner_act_seq > l_bal_asg_act_seq) AND
        (p_defbal_rec.expiry_check_lvl <> 'E')) then
       --
       -- O.K. We cannot use the latest balance value, now check if the
       -- expired details can by used.
       --
       if g_debug then
          hr_utility.set_location ('pay_balance_pkg.get_old_latest_bal_value', 140
);
       end if;
       select count(*)
       into   l_num_of_runs
       from
            pay_payroll_actions     ppa2,
            pay_assignment_actions  paa2,
            pay_assignment_actions  paa
       where paa.assignment_action_id = l_bal_expired_action
       and   paa2.assignment_id       = paa.assignment_id
       and   ppa2.payroll_action_id   = paa2.payroll_action_id
       and   ppa2.action_type        in ('R', 'Q', 'B', 'V')
       and   paa2.action_sequence between paa.action_sequence
                                      and l_bal_asg_act_seq;
       --
       -- Check if the expired assignment action is the only run action
       -- for this assignment upto the effective date. If none are found
       -- then the expired assignment action must be the dummy value -9999.
       -- If more than 1 are found then there must be other payroll runs
       -- in the specified period.
       --
       if l_num_of_runs = 1 then
          if g_debug then
             hr_utility.set_location ('pay_balance_pkg.get_old_latest_bal_value',
150);
          end if;
          l_bal_owner_asg_action := l_bal_expired_action;
          l_balance_value        := l_bal_expired_value;
          l_expiry_needed        := TRUE;
       else
         -- check if can use previous balance value
          if g_debug then
             hr_utility.set_location ('pay_balance_pkg.get_old_latest_bal_value',
160);
          end if;
          select count(*)
          into   l_num_of_runs
          from
              pay_payroll_actions     ppa2,
              pay_assignment_actions  paa2,
              pay_assignment_actions  paa
          where paa.assignment_action_id = l_prev_action
          and   paa2.assignment_id       = paa.assignment_id
          and   ppa2.payroll_action_id   = paa2.payroll_action_id
          and   ppa2.action_type        in ('R', 'Q', 'B', 'V')
          and   paa2.action_sequence between paa.action_sequence
                                      and l_bal_asg_act_seq;
--
          if l_num_of_runs = 1 then
            if g_debug then
               hr_utility.set_location ('pay_balance_pkg.get_old_latest_bal_value'
, 170);
            end if;
            l_bal_owner_asg_action := l_prev_action;
            l_balance_value        := l_prev_value;
            l_expiry_needed        := TRUE;
          else
            l_expiry_needed        := FALSE;
            --
            -- call monitoring balance retrieval code
            --
            pay_monitor_balance_retrieval.monitor_balance_retrieval
                                (p_defined_balance_id
                                ,p_assignment_action_id
                                ,'Core Balance pkg - Latest balance expired');
          end if;
       end if;
--
    end if;
    if g_debug then
       hr_utility.set_location ('pay_balance_pkg.get_old_latest_bal_value', 55);
    end if;
--
    if (l_expiry_needed = TRUE) then
      --
      -- If we have reached here then there is a latest balance/expired balance
      -- value present on the database that we can use.  Now see if the balance
      -- has expired by running the procedure associated with the balance - this
      -- requires dynamic pl/sql.
      -- If the balance has expired then a zero value will be returned.
      --
      l_balance_expired := check_bal_expiry_internal (l_bal_owner_asg_action,
                                             p_assignment_action_id,
                                             p_defbal_rec.dimension_name,
                                             p_defbal_rec.expiry_check_lvl,
                                             p_defbal_rec.expiry_check_code,
                                             l_bal_con_str);
      --
      -- OK, whats the checking level, we might have a special
      -- case balance
      --
      if (p_defbal_rec.expiry_check_lvl = 'E') then
--
       -- Yep its a special case.
        if (l_balance_expired = BALANCE_EXPIRED) then
          if g_debug then
             hr_utility.trace ('Balance expired');
          end if;
          l_balance_value := 0;
          l_found := TRUE;
        elsif (l_balance_expired = BALANCE_NOT_EXPIRED) then
          if g_debug then
             hr_utility.trace ('Balance not expired');
          end if;
          l_found := TRUE;
        else
           --
           -- call monitoring balance retrieval code
           --
           pay_monitor_balance_retrieval.monitor_balance_retrieval
                        (p_defined_balance_id
                        ,p_assignment_action_id
                        ,'Core Balance pkg - still no value after expiry checking'
);
        end if; --BALANCE_EXPIRED

      else
        if (l_balance_expired = BALANCE_EXPIRED) then
          if g_debug then
             hr_utility.trace ('Balance expired');
          end if;
          l_balance_value := 0;
          l_found := TRUE;
        else
          if g_debug then
             hr_utility.trace ('Balance not expired');
          end if;
          l_found := TRUE;
        end if; --BALANCE_EXPIRED
      end if;   --p_defbal_rec.expiry_check_lvl = 'E'
    end if;     -- l_found = FALSE
  else
    --
    -- call monitoring balance retrieval code
    --
    pay_monitor_balance_retrieval.monitor_balance_retrieval
                               (p_defined_balance_id
                               ,p_assignment_action_id
                               ,'Core Balance pkg - No latest balance');
  end if; -- l_balance_found = FALSE
--
-- Set up the return values
--
   p_found := l_found;
   p_balance_value := l_balance_value;
--
end get_old_latest_bal_value;
--
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--
--                            get_new_latest_bal_value                    +
--                                                                        +
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
/*
NAME

        get_new_latest_bal_value  -  Get the balance value based on Latest
                                     Balances

DESCRIPTION

*/
procedure get_new_latest_bal_value(p_defined_balance_id   in         number,
                               p_assignment_action_id in         number,
                               p_defbal_rec           in         t_def_bal_rec,
                               p_balance_value        out nocopy number,
                               p_found                out nocopy boolean)
is
--
cursor crs_latest_bal
is
select plb.latest_balance_id,
       plb.assignment_action_id,
       plb.value,
       plb.expiry_date,
       ACT.action_sequence      current_action_seq,
       OWN_ACT.action_sequence  owner_action_seq,
       PACT.effective_date      current_effective_date,
       plb.expired_assignment_action_id,
       plb.expired_value,
       plb.expired_date,
       plb.prev_assignment_action_id,
       plb.prev_balance_value,
       plb.prev_expiry_date,
       plb.tax_unit_id,
       plb.jurisdiction_code,
       plb.original_entry_id,
       plb.source_id,
       plb.source_text,
       plb.source_text2,
       plb.source_number,
       plb.tax_group,
       plb.payroll_id,
       plb.local_unit_id,
       plb.organization_id,
       plb.source_number2
from   pay_latest_balances             plb
,      per_all_assignments_f           ASSIGN
,      pay_assignment_actions          ACT
,      pay_payroll_actions             PACT
,      pay_assignment_actions          OWN_ACT
where  plb.defined_balance_id        = p_defined_balance_id
and    ACT.assignment_action_id      = p_assignment_action_id
and    ASSIGN.assignment_id          = ACT.assignment_id
and    exists (select ''
                 from pay_object_groups               POG
                where POG.source_id (+)             = ACT.assignment_id
                and   POG.source_type (+)           = 'PAF'
                and nvl(plb.process_group_id,
                        nvl(POG.parent_object_group_id, -1)) =
                    nvl(POG.parent_object_group_id,-1)
              )
and    plb.person_id                 = ASSIGN.person_id
and    nvl(plb.assignment_id, ACT.assignment_id) = ACT.assignment_id
and    PACT.payroll_action_id        = ACT.payroll_action_id
and    PACT.effective_date     between ASSIGN.effective_start_date
                                   and ASSIGN.effective_end_date
and    OWN_ACT.assignment_action_id  = plb.assignment_action_id
--and    ACT.action_sequence          >= OWN_ACT.action_sequence
and    nvl(plb.tax_unit_id, nvl(g_con_tax_unit_id, -1))
                             = nvl(g_con_tax_unit_id, -1)
and    nvl(substr(nvl(plb.jurisdiction_code,
                  nvl(g_con_jurisdiction_code, -1)),
                  1, p_defbal_rec.jurisdiction_lvl),
           -1)
                             = nvl(
                                substr(nvl(g_con_jurisdiction_code, -1),
                                       1, p_defbal_rec.jurisdiction_lvl),
                                   -1)
and    nvl(plb.original_entry_id, nvl(g_con_original_entry_id, -1))
                             = nvl(g_con_original_entry_id, -1)
and    nvl(plb.source_id, nvl(g_con_source_id, -1))
                             = nvl(g_con_source_id, -1)
and    nvl(plb.source_text, nvl(g_con_source_text, -1))
                             = nvl(g_con_source_text, -1)
and    nvl(plb.source_text2, nvl(g_con_source_text2, -1))
                             = nvl(g_con_source_text2, -1)
and    nvl(plb.source_number, nvl(g_con_source_number, -1))
                             = nvl(g_con_source_number, -1)
and    nvl(plb.tax_group, nvl(g_con_tax_group, -1))
                             = nvl(g_con_tax_group, -1)
and    nvl(plb.payroll_id, nvl(g_con_payroll_id, -1))
                             = nvl(g_con_payroll_id, -1)
and    nvl(plb.local_unit_id, nvl(g_con_local_unit_id, -1))
                             = nvl(g_con_local_unit_id, -1)
and    nvl(plb.organization_id, nvl(g_con_organization_id, -1))
                             = nvl(g_con_organization_id, -1)
and    nvl(plb.source_number2, nvl(g_con_source_number2, -1))
                             = nvl(g_con_source_number2, -1)
order  by plb.latest_balance_id;
--
l_balance_value         pay_latest_balances.value%type;
l_bal_owner_asg_action  pay_latest_balances.assignment_action_id%type;
--
l_num_of_runs           number;
l_bal_con_str           varchar2(500);   -- Balance context string
l_balance_expired       number;
l_found                 boolean;
l_expiry_needed         boolean;
--
l_cnt number;
l_expiry_date date;
begin
--
 l_expiry_date := NULL;
 l_cnt         := 0;
 l_bal_con_str := ' ';
 l_found       := FALSE;
 for lbrec in crs_latest_bal loop
--
   l_cnt := l_cnt + 1;
--
    if g_debug then
       hr_utility.set_location ('pay_balance_pkg.get_new_latest_bal_value', 38);
       hr_utility.trace('OWN SEQ '||lbrec.owner_action_seq);
       hr_utility.trace('CURR SEQ '||lbrec.current_action_seq);
    end if;
    --
    -- Check that the current assignment_action is the same as the
    -- owner action, if so there is no need for expiry checking.
    --
    if (p_assignment_action_id = lbrec.assignment_action_id) then
       l_balance_value := lbrec.value;
       l_found := TRUE;
       l_expiry_needed := FALSE;
    elsif (p_assignment_action_id = lbrec.expired_assignment_action_id) then
       l_balance_value := lbrec.expired_value;
       l_found := TRUE;
       l_expiry_needed := FALSE;
    elsif (p_assignment_action_id = lbrec.prev_assignment_action_id) then
       l_balance_value := lbrec.prev_balance_value;
       l_found := TRUE;
       l_expiry_needed := FALSE;
    --
    -- A latest balance row has been found but can it be used for this
    -- effective date. Must check the action sequences of the owning
    -- assignment_action.
    -- Or is it a special balance expiry level 'E'
    --
    elsif ((lbrec.owner_action_seq > lbrec.current_action_seq) AND
        (p_defbal_rec.expiry_check_lvl <> 'E')) then
       --
       -- O.K. We cannot use the latest balance value, now check if the
       -- expired details can by used.
       --
       if g_debug then
          hr_utility.set_location ('pay_balance_pkg.get_new_latest_bal_value', 140
);
       end if;
       select count(*)
       into   l_num_of_runs
       from
            pay_payroll_actions     ppa2,
            pay_assignment_actions  paa2,
            pay_assignment_actions  paa
       where paa.assignment_action_id = lbrec.expired_assignment_action_id
       and   paa2.assignment_id       = paa.assignment_id
       and   ppa2.payroll_action_id   = paa2.payroll_action_id
       and   ppa2.action_type        in ('R', 'Q', 'B', 'V')
       and   paa2.action_sequence between paa.action_sequence
                                      and lbrec.current_action_seq;
       --
       -- Check if the expired assignment action is the only run action
       -- for this assignment upto the effective date. If none are found
       -- then the expired assignment action must be the dummy value -9999.
       -- If more than 1 are found then there must be other payroll runs
       -- in the specified period.
       --
       if l_num_of_runs = 1 then
          if g_debug then
             hr_utility.set_location ('pay_balance_pkg.get_new_latest_bal_value',
150);
          end if;
          l_bal_owner_asg_action := lbrec.expired_assignment_action_id;
          l_balance_value        := lbrec.expired_value;
          l_expiry_date          := lbrec.expired_date;
          l_expiry_needed        := TRUE;
       else
         -- check if can use previous balance value
          if g_debug then
             hr_utility.set_location ('pay_balance_pkg.get_new_latest_bal_value',
160);
          end if;
          select count(*)
          into   l_num_of_runs
          from
              pay_payroll_actions     ppa2,
              pay_assignment_actions  paa2,
              pay_assignment_actions  paa
          where paa.assignment_action_id = lbrec.prev_assignment_action_id
          and   paa2.assignment_id       = paa.assignment_id
          and   ppa2.payroll_action_id   = paa2.payroll_action_id
          and   ppa2.action_type        in ('R', 'Q', 'B', 'V')
          and   paa2.action_sequence between paa.action_sequence
                                      and lbrec.current_action_seq;
--
          if l_num_of_runs = 1 then
            if g_debug then
               hr_utility.set_location ('pay_balance_pkg.get_new_latest_bal_value'
, 170);
            end if;
            l_bal_owner_asg_action := lbrec.prev_assignment_action_id;
            l_balance_value        := lbrec.prev_balance_value;
            l_expiry_needed        := TRUE;
            l_expiry_date          := lbrec.prev_expiry_date;
          else
            l_expiry_needed        := FALSE;
            l_found                := FALSE;
            --
            -- call monitoring balance retrieval code
            --
            pay_monitor_balance_retrieval.monitor_balance_retrieval
                                (p_defined_balance_id
                                ,p_assignment_action_id
                                ,'Core Balance pkg - Latest balance expired');
          end if;
       end if;
--
    else
       /* Current latest balance can be used, we just need to perform expiry check
ing*/
--
       l_bal_owner_asg_action := lbrec.assignment_action_id;
       l_balance_value        := lbrec.value;
       l_expiry_needed        := TRUE;
       l_expiry_date          := lbrec.expiry_date;
--
    end if;
    if g_debug then
       hr_utility.set_location ('pay_balance_pkg.get_new_latest_bal_value', 55);
    end if;
--
    if (l_expiry_needed = TRUE) then
      --
      -- If we have reached here then there is a latest balance/expired balance
      -- value present on the database that we can use.  Now see if the balance
      -- has expired by running the procedure associated with the balance - this
      -- requires dynamic pl/sql.
      -- If the balance has expired then a zero value will be returned.
      --
      if (l_expiry_date is not null and p_defbal_rec.expiry_check_lvl <> 'E') then
         if (lbrec.current_effective_date > l_expiry_date) then
           l_balance_value := 0;
         end if;
         l_found := TRUE;
      else
--
        -- OK, we need to do the expiry checking the hard way
--
        if (p_defbal_rec.expiry_check_lvl in ('A', 'D')) then
--
          if (lbrec.TAX_UNIT_ID is not null) then
            l_bal_con_str := l_bal_con_str||'TAX_UNIT_ID='||lbrec.TAX_UNIT_ID||' ';
          end if;
--
          if (lbrec.JURISDICTION_CODE is not null) then
            l_bal_con_str := l_bal_con_str||'JURISDICTION_CODE='||lbrec.JURISDICTION_CODE||' ';
          end if;
--
          if (lbrec.ORIGINAL_ENTRY_ID is not null) then
            l_bal_con_str := l_bal_con_str||'ORIGINAL_ENTRY_ID='||lbrec.ORIGINAL_ENTRY_ID||' ';
          end if;
--
          if (lbrec.SOURCE_ID is not null) then
            l_bal_con_str := l_bal_con_str||'SOURCE_ID='||lbrec.SOURCE_ID||' ';
          end if;
--
          if (lbrec.SOURCE_TEXT is not null) then
            l_bal_con_str := l_bal_con_str||'SOURCE_TEXT='||lbrec.SOURCE_TEXT||' ';
          end if;
--
          if (lbrec.SOURCE_TEXT2 is not null) then
            l_bal_con_str := l_bal_con_str||'SOURCE_TEXT2='||lbrec.SOURCE_TEXT2||' ';
          end if;
--
          if (lbrec.SOURCE_NUMBER is not null) then
            l_bal_con_str := l_bal_con_str||'SOURCE_NUMBER='||lbrec.SOURCE_NUMBER||' ';
          end if;
--
          if (lbrec.TAX_GROUP is not null) then
            l_bal_con_str := l_bal_con_str||'TAX_GROUP='||lbrec.TAX_GROUP||' ';
          end if;
--
          if (lbrec.PAYROLL_ID is not null) then
            l_bal_con_str := l_bal_con_str||'PAYROLL_ID='||lbrec.PAYROLL_ID||' ';
          end if;
--
          if (lbrec.LOCAL_UNIT_ID is not null) then
            l_bal_con_str := l_bal_con_str||'LOCAL_UNIT_ID='||lbrec.LOCAL_UNIT_ID||' ';
          end if;
--
          if (lbrec.ORGANIZATION_ID is not null) then
            l_bal_con_str := l_bal_con_str||'ORGANIZATION_ID='||lbrec.ORGANIZATION_ID||' ';
          end if;
--
          if (lbrec.SOURCE_NUMBER2 is not null) then
            l_bal_con_str := l_bal_con_str||'SOURCE_NUMBER2='||lbrec.SOURCE_NUMBER2||' ';
          end if;
--
        end if;
--
        l_balance_expired := check_bal_expiry_internal (l_bal_owner_asg_action,
                                               p_assignment_action_id,
                                               p_defbal_rec.dimension_name,
                                               p_defbal_rec.expiry_check_lvl,
                                               p_defbal_rec.expiry_check_code,
                                               l_bal_con_str);
--
        --
        -- OK, whats the checking level, we might have a special
        -- case balance
        --
        if (p_defbal_rec.expiry_check_lvl = 'E') then
--
         -- Yep its a special case.
          if (l_balance_expired = BALANCE_EXPIRED) then
            if g_debug then
               hr_utility.trace ('Balance expired');
            end if;
            l_balance_value := 0;
            l_found := TRUE;
          elsif (l_balance_expired = BALANCE_NOT_EXPIRED) then
            if g_debug then
               hr_utility.trace ('Balance not expired');
            end if;
            l_found := TRUE;
          else
             --
             -- call monitoring balance retrieval code
             --
             pay_monitor_balance_retrieval.monitor_balance_retrieval
                          (p_defined_balance_id
                          ,p_assignment_action_id
                          ,'Core Balance pkg - still no value after expiry checkin
g');
          end if; --BALANCE_EXPIRED
        else
          if (l_balance_expired = BALANCE_EXPIRED) then
            if g_debug then
               hr_utility.trace ('Balance expired');
            end if;
            l_balance_value := 0;
            l_found := TRUE;
          else
            if g_debug then
               hr_utility.trace ('Balance not expired');
            end if;
            l_found := TRUE;
          end if; --BALANCE_EXPIRED
        end if;   --p_defbal_rec.expiry_check_lvl = 'E'
      end if;
    end if;     -- l_found = FALSE
 end loop;
--
 if (l_cnt = 0) then
   p_found := FALSE;
 elsif (l_cnt = 1) then
   p_found := l_found;
   p_balance_value := l_balance_value;
 else
    pay_core_utils.assert_condition('get_new_latest_bal_value:1', false);
 end if;
--
end get_new_latest_bal_value;
--
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--
--                            get_latest_bal_value                        +
--                                                                        +
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
/*
NAME

        get_latest_bal_value  -  Get the balance value based on Latest
                                 Balances

DESCRIPTION

*/
procedure get_latest_bal_value(p_defined_balance_id   in         number,
                               p_assignment_action_id in         number,
                               p_defbal_rec           in         t_def_bal_rec,
                               p_balance_value        out nocopy number,
                               p_found                out nocopy boolean)
is
--
l_business_group_id per_business_groups.business_group_id%type;
l_status            pay_upgrade_status.status%type;
begin
--
  select ppa.business_group_id
    into l_business_group_id
    from pay_payroll_actions ppa,
         pay_assignment_actions paa
   where ppa.payroll_action_id = paa.payroll_action_id
     and paa.assignment_action_id = p_assignment_action_id;
--
  pay_core_utils.get_upgrade_status(l_business_group_id,
                                    'SINGLE_BAL_TABLE',
                                    l_status);
--
  if (l_status = 'Y') then
    get_new_latest_bal_value(p_defined_balance_id,
                             p_assignment_action_id,
                             p_defbal_rec,
                             p_balance_value,
                             p_found);
  else
    get_old_latest_bal_value(p_defined_balance_id,
                             p_assignment_action_id,
                             p_defbal_rec,
                             p_balance_value,
                             p_found);
  end if;
end get_latest_bal_value;
--
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--                                                                        +
--               get_value_internal                                       +
--                                                                        +
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--
/*
NAME
  get_value_internal        - Get Value of a balance
--
DESCRIPTION
   This procedure retrieves the value of a balance, and is the
   main procedure for returning a single value.
   NOTE:- It does do not retrieve the balance value if the
          Run Result route is to be used, and that route is
          batch enabled.
*/
procedure get_value_internal (
                              p_defined_balance_id   in            number,
                              p_defbal_rec           in            t_def_bal_rec,
                              p_assignment_action_id in            number,
                              p_get_rr_route         in            boolean,
                              p_get_rb_route         in            boolean,
                              p_found                   out nocopy boolean,
                              p_balance_value           out nocopy number)
is
l_balance_value         number;
l_found                 boolean;
begin
--
  l_found := FALSE;
  l_balance_value := 0;
--
  if (p_defbal_rec.dimension_type not in ('N', 'F', 'R')) then
     if (p_get_rb_route = FALSE
       and p_get_rr_route = FALSE) then
         get_latest_bal_value(p_defined_balance_id,
                              p_assignment_action_id,
                              p_defbal_rec,
                              l_balance_value,
                              l_found);
     else
         --
         -- call monitoring balance retrieval code
         --
         pay_monitor_balance_retrieval.monitor_balance_retrieval
                       (p_defined_balance_id
                       ,p_assignment_action_id
                       ,'Core Balance pkg - Run Result/Balance override flag set');
     end if;
   else
   --
   -- call monitoring balance retrieval code
   --
   pay_monitor_balance_retrieval.monitor_balance_retrieval
                        (p_defined_balance_id
                        ,p_assignment_action_id
                        ,'Core Balance pkg - Dimension_type is NOT A or P. '
                        ||'Latest balances are only availbale for assignment '
                        ||'or person level balances, that are not also Run '
                        ||'level balances. The level of the balance is set '
                        ||'with the dimension_type on pay_balance_dimensions. '
                        ||'Dimension types for seeded data must not be '
                        ||'updated.');
   end if;
--
   if (l_found = FALSE
     and p_get_rr_route = FALSE) then
     get_rb_value(p_defined_balance_id,
                  p_assignment_action_id,
                  l_found,
                  l_balance_value);
   end if;
--
   -- If this balance can not be retrieved in batch mode then
   -- get it via run results single mode.
   if (l_found = FALSE) then
     if (p_defbal_rec.balance_type_column is null) then
       get_rr_value(p_defined_balance_id,
                    l_balance_value);
       l_found := TRUE;
     end if;
   end if;
--
-- Setup the return values
--
   p_found         := l_found;
   p_balance_value := l_balance_value;
--
end get_value_internal;
--
--
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--                                                                        +
--               get_value     (assignment action mode)                   +
--                                                                        +
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--
/*
NAME
  get_value        - Retrieve a balance (assignment action mode)
--
DESCRIPTION
  This is the main routine that derives a balance for an assignment action,
  and is also called by the date mode get_value function.  If the parameter
  'p_always_get_db_item' is set to TRUE the routine will derive the balance
  from the route, and not even look for a latest balance.  This parameter is
  used for testing purposes.
  --
  There are 2 overloaded versions of the get_value function below.  The first
  one is called by the forms/ reports.  The second has the option of setting
  the 'p_always_get_db_item' value.  This is necessary since the forms do not
  support default parameters.
*/
procedure get_value_int_batch (p_assignment_action_id in            number,
                     p_context_lst          in            t_context_tab,
                     p_get_rr_route         in            boolean default FALSE,
                     p_get_rb_route         in            boolean default FALSE,
                     p_output_table         in out nocopy t_detailed_bal_out_tab)
is
l_retrieval_list         t_balance_value_tab;
l_retrieval_cnt          number;
--
l_cache_cnt              number;
prev_def_bal_id          number;
l_add_balance            boolean;
start_def_bal_ptr        number;
pos_indx                 number_tab;
bal_ju_code              pay_run_results.jurisdiction_code%type;
con_ju_code              pay_run_results.jurisdiction_code%type;
begin
--
-- Now get the balances
--
   for con_cnt in 1..p_context_lst.count loop
--
     l_retrieval_list.delete;
--
     -- Set the contexts
     if (p_context_lst(con_cnt).tax_unit_id is not null) then
       set_context('TAX_UNIT_ID', p_context_lst(con_cnt).tax_unit_id);
     end if;
     if (p_context_lst(con_cnt).jurisdiction_code is not null) then
       set_context('JURISDICTION_CODE', p_context_lst(con_cnt).jurisdiction_code);
     end if;
     if (p_context_lst(con_cnt).source_id is not null) then
       set_context('SOURCE_ID', p_context_lst(con_cnt).source_id);
     end if;
     if (p_context_lst(con_cnt).source_text is not null) then
       set_context('SOURCE_TEXT', p_context_lst(con_cnt).source_text);
     end if;
     if (p_context_lst(con_cnt).source_number is not null) then
       set_context('SOURCE_NUMBER', p_context_lst(con_cnt).source_number);
     end if;
     if (p_context_lst(con_cnt).source_text2 is not null) then
       set_context('SOURCE_TEXT2', p_context_lst(con_cnt).source_text2);
     end if;
     if (p_context_lst(con_cnt).time_def_id  is not null) then
       set_context('TIME_DEFINITION_ID', p_context_lst(con_cnt).time_def_id);
     end if;
     if (p_context_lst(con_cnt).balance_date  is not null) then
       set_context('BALANCE_DATE', to_char(p_context_lst(con_cnt).balance_date,
                                           'YYYY/MM/DD HH24:MI:SS'));
     end if;
     if (p_context_lst(con_cnt).local_unit_id  is not null) then
       set_context('LOCAL_UNIT_ID', p_context_lst(con_cnt).local_unit_id);
     end if;
     if (p_context_lst(con_cnt).source_number2  is not null) then
       set_context('SOURCE_NUMBER2', p_context_lst(con_cnt).source_number2);
     end if;
     if (p_context_lst(con_cnt).organization_id  is not null) then
       set_context('ORGANIZATION_ID', p_context_lst(con_cnt).organization_id);
     end if;
--
     -- Now loop through the balances to retrieve.
     l_retrieval_cnt := 1;
     for db_cnt in 1..p_output_table.count loop
--
       if (p_output_table(db_cnt).balance_found = FALSE) then
--
         bal_ju_code := substr(p_output_table(db_cnt).jurisdiction_code,
                              1,
                              p_output_table(db_cnt).jurisdiction_lvl);
         con_ju_code := substr(p_context_lst(con_cnt).jurisdiction_code,
                            1,
                            p_output_table(db_cnt).jurisdiction_lvl);
--
         if (nvl(p_context_lst(con_cnt).tax_unit_id, -999) =
                   nvl(p_output_table(db_cnt).tax_unit_id,
                       nvl(p_context_lst(con_cnt).tax_unit_id, -999))
             and nvl(con_ju_code, '<NULL>') =
                   nvl(bal_ju_code, nvl(con_ju_code, '<NULL>'))
             and nvl(p_context_lst(con_cnt).source_text, '<NULL>') =
                   nvl(p_output_table(db_cnt).source_text,
                       nvl(p_context_lst(con_cnt).source_text, '<NULL>'))
             and nvl(p_context_lst(con_cnt).source_number, -999) =
                   nvl(p_output_table(db_cnt).source_number,
                       nvl(p_context_lst(con_cnt).source_number, -999))
             and nvl(p_context_lst(con_cnt).source_number2, -999) =
                   nvl(p_output_table(db_cnt).source_number2,
                       nvl(p_context_lst(con_cnt).source_number2, -999))
             and nvl(p_context_lst(con_cnt).local_unit_id, -999) =
                   nvl(p_output_table(db_cnt).local_unit_id,
                       nvl(p_context_lst(con_cnt).local_unit_id, -999))
             and nvl(p_context_lst(con_cnt).organization_id, -999) =
                   nvl(p_output_table(db_cnt).organization_id,
                       nvl(p_context_lst(con_cnt).organization_id, -999))
             and nvl(p_context_lst(con_cnt).source_text2, '<NULL>') =
                   nvl(p_output_table(db_cnt).source_text2,
                       nvl(p_context_lst(con_cnt).source_text2, '<NULL>'))
             and nvl(p_context_lst(con_cnt).source_id, -999) =
                   nvl(p_output_table(db_cnt).source_id,
                       nvl(p_context_lst(con_cnt).source_id, -999))
             and nvl(p_context_lst(con_cnt).time_def_id, -999) =
                   nvl(p_output_table(db_cnt).time_def_id,
                       nvl(p_context_lst(con_cnt).time_def_id, -999))
             and nvl(p_context_lst(con_cnt).balance_date, to_date('0001/01/01', 'YYYY/MM/DD')) =
                   nvl(p_output_table(db_cnt).balance_date,
                       nvl(p_context_lst(con_cnt).balance_date, to_date('0001/01/01', 'YYYY/MM/DD')))
           ) then
           --
           l_retrieval_list(l_retrieval_cnt).defined_balance_id :=
                       p_output_table(db_cnt).defined_balance_id;
           pos_indx(l_retrieval_cnt) := db_cnt;
           l_retrieval_cnt := l_retrieval_cnt + 1;
           --
         end if;
       end if;
--
     end loop;
     -- Now do the retrieval
     get_value(p_assignment_action_id,
               l_retrieval_list,
               p_get_rr_route,
               p_get_rb_route);
--
     -- Put the returned values into the cache table.
     for ret_cnt in 1..l_retrieval_list.count loop
       p_output_table(pos_indx(ret_cnt)).balance_value :=
                          l_retrieval_list(ret_cnt).balance_value;
       p_output_table(pos_indx(ret_cnt)).balance_found := TRUE;
     end loop;
--
   end loop;
--
end;

procedure get_value (p_assignment_action_id in            number,
                     p_defined_balance_lst  in            t_balance_value_tab,
                     p_context_lst          in            t_context_tab,
                     p_get_rr_route         in            boolean default FALSE,
                     p_get_rb_route         in            boolean default FALSE,
                     p_output_table            out nocopy t_detailed_bal_out_tab)
is
--
l_retrieval_list         t_balance_value_tab;
l_transform_cache        t_int_bal_cache;
l_batch_bal_cache        t_int_bal_cache;
l_cache_cnt              number;
l_defbal_rec             t_def_bal_rec;
prev_def_bal_id          number;
l_add_balance            boolean;
start_def_bal_ptr        number;
l_retrieval_cnt          number;
pos_indx                 number_tab;
bal_ju_code              pay_run_results.jurisdiction_code%type;
con_ju_code              pay_run_results.jurisdiction_code%type;
--
begin
   g_debug := hr_utility.debug_enabled;
--
   l_cache_cnt := 1; -- The next free position
--
-- Create the super set of balances to be calculated.
--
   for def_cnt in 1..p_defined_balance_lst.count loop
--
      load_defbal_cache(p_defined_balance_lst(def_cnt).defined_balance_id,
                        l_defbal_rec);
--
      for con_cnt in 1..p_context_lst.count loop
--
        -- Only add a row if we have all the contexts needed
        if ((l_defbal_rec.tu_needed and p_context_lst(con_cnt).tax_unit_id is null)
          or (l_defbal_rec.jc_needed and p_context_lst(con_cnt).jurisdiction_code is null)
          or (l_defbal_rec.si_needed and p_context_lst(con_cnt).source_id is null)
          or (l_defbal_rec.sn_needed and p_context_lst(con_cnt).source_number is null)
          or (l_defbal_rec.st2_needed and p_context_lst(con_cnt).source_text2 is null)
          or (l_defbal_rec.st_needed and p_context_lst(con_cnt).source_text is null)
          or (l_defbal_rec.td_needed and p_context_lst(con_cnt).time_def_id is null)
          or (l_defbal_rec.lu_needed and p_context_lst(con_cnt).local_unit_id is null)
          or (l_defbal_rec.sn2_needed and p_context_lst(con_cnt).source_number2 is null)
          or (l_defbal_rec.org_needed and p_context_lst(con_cnt).organization_id is null)
          or (l_defbal_rec.bd_needed and p_context_lst(con_cnt).balance_date is null)
           ) then
--
           if g_debug then
              hr_utility.trace('Not a valid context combination for this balance');
           end if;
--
        else
--
          l_transform_cache(l_cache_cnt).defined_balance_id :=
                                  p_defined_balance_lst(def_cnt).defined_balance_id;
          l_transform_cache(l_cache_cnt).balance_found := FALSE;
--
--      Set up the contexts
--
          if (l_defbal_rec.tu_needed
              and p_context_lst(con_cnt).tax_unit_id is not null) then
             l_transform_cache(l_cache_cnt).tax_unit_id :=
                                     p_context_lst(con_cnt).tax_unit_id;
          else
             l_transform_cache(l_cache_cnt).tax_unit_id := null;
          end if;
--
          if (l_defbal_rec.jc_needed
             and p_context_lst(con_cnt).jurisdiction_code is not null) then
             l_transform_cache(l_cache_cnt).jurisdiction_code :=
                                     substr(p_context_lst(con_cnt).jurisdiction_code,
                                            1,
                                            l_defbal_rec.jurisdiction_lvl);
          else
             l_transform_cache(l_cache_cnt).jurisdiction_code := null;
          end if;
--
          if (l_defbal_rec.si_needed
             and p_context_lst(con_cnt).source_id is not null) then
             l_transform_cache(l_cache_cnt).source_id :=
                                     p_context_lst(con_cnt).source_id;
          else
             l_transform_cache(l_cache_cnt).source_id := null;
          end if;
--
          if (l_defbal_rec.st_needed
              and p_context_lst(con_cnt).source_text is not null) then
             l_transform_cache(l_cache_cnt).source_text :=
                                     p_context_lst(con_cnt).source_text;
          else
             l_transform_cache(l_cache_cnt).source_text := null;
          end if;
--
          if (l_defbal_rec.sn_needed
              and p_context_lst(con_cnt).source_number is not null) then
             l_transform_cache(l_cache_cnt).source_number :=
                                     p_context_lst(con_cnt).source_number;
          else
             l_transform_cache(l_cache_cnt).source_number := null;
          end if;
--
          if (l_defbal_rec.st2_needed
              and p_context_lst(con_cnt).source_text2 is not null) then
             l_transform_cache(l_cache_cnt).source_text2 :=
                                     p_context_lst(con_cnt).source_text2;
          else
             l_transform_cache(l_cache_cnt).source_text2 := null;
          end if;
--
          if (l_defbal_rec.td_needed
              and p_context_lst(con_cnt).time_def_id is not null) then
             l_transform_cache(l_cache_cnt).time_def_id :=
                                     p_context_lst(con_cnt).time_def_id;
          else
             l_transform_cache(l_cache_cnt).time_def_id := null;
          end if;
--
          if (l_defbal_rec.bd_needed
              and p_context_lst(con_cnt).balance_date is not null) then
             l_transform_cache(l_cache_cnt).balance_date :=
                                     p_context_lst(con_cnt).balance_date;
          else
             l_transform_cache(l_cache_cnt).balance_date := null;
          end if;
--
          if (l_defbal_rec.lu_needed
              and p_context_lst(con_cnt).local_unit_id is not null) then
             l_transform_cache(l_cache_cnt).local_unit_id :=
                                     p_context_lst(con_cnt).local_unit_id;
          else
             l_transform_cache(l_cache_cnt).local_unit_id := null;
          end if;
--
          if (l_defbal_rec.sn2_needed
              and p_context_lst(con_cnt).source_number2 is not null) then
             l_transform_cache(l_cache_cnt).source_number2 :=
                                     p_context_lst(con_cnt).source_number2;
          else
             l_transform_cache(l_cache_cnt).source_number2 := null;
          end if;
--
          if (l_defbal_rec.org_needed
              and p_context_lst(con_cnt).organization_id is not null) then
             l_transform_cache(l_cache_cnt).organization_id :=
                                     p_context_lst(con_cnt).organization_id;
          else
             l_transform_cache(l_cache_cnt).organization_id := null;
          end if;
--
          -- Next free position.
          l_cache_cnt := l_cache_cnt + 1;
--
        end if;
--
      end loop;
--
   end loop;
--
-- Remove the duplicates
--
   l_cache_cnt := 1;
   start_def_bal_ptr := -999;
   prev_def_bal_id := -1;
   for cnt in 1..l_transform_cache.count loop
--
     hr_utility.trace('Time 1 '||to_char(sysdate, 'HH24:MI:SS'));
     if l_transform_cache(cnt).defined_balance_id = prev_def_bal_id then
--
       l_add_balance := TRUE;
       if g_debug then
          hr_utility.trace('Start index '||start_def_bal_ptr||' to '||l_batch_bal_cache.count);
       end if;
     hr_utility.trace('Time 2 '||to_char(sysdate, 'HH24:MI:SS'));
       for dup_cnt in start_def_bal_ptr..l_batch_bal_cache.count loop
--
     hr_utility.trace('Time 3 '||to_char(sysdate, 'HH24:MI:SS'));
          if g_debug then
             hr_utility.trace('Comparing...');
             hr_utility.trace(l_transform_cache(cnt).defined_balance_id||' '||
                              l_batch_bal_cache(dup_cnt).defined_balance_id);
             hr_utility.trace(nvl(l_transform_cache(cnt).tax_unit_id, -999)||' '||
                              nvl(l_batch_bal_cache(dup_cnt).tax_unit_id, -999));
             hr_utility.trace(nvl(l_transform_cache(cnt).jurisdiction_code, '<NULL>')||' '||
                              nvl(l_batch_bal_cache(dup_cnt).jurisdiction_code, '<NULL>'));
             hr_utility.trace(nvl(l_transform_cache(cnt).source_id, -999)||' '||
                              nvl(l_batch_bal_cache(dup_cnt).source_id, -999));
             hr_utility.trace(nvl(l_transform_cache(cnt).source_text, '<NULL>')||' '||
                              nvl(l_batch_bal_cache(dup_cnt).source_text, '<NULL>'));
          end if;
--
     hr_utility.trace('Time 4 '||to_char(sysdate, 'HH24:MI:SS'));
          if (l_transform_cache(cnt).defined_balance_id  = l_batch_bal_cache(dup_cnt).defined_balance_id
            and nvl(l_transform_cache(cnt).tax_unit_id, -999)
                            = nvl(l_batch_bal_cache(dup_cnt).tax_unit_id, -999)
            and nvl(l_transform_cache(cnt).jurisdiction_code, '<NULL>')
                            = nvl(l_batch_bal_cache(dup_cnt).jurisdiction_code, '<NULL>')
            and nvl(l_transform_cache(cnt).source_id, -999)
                            = nvl(l_batch_bal_cache(dup_cnt).source_id, -999)
            and nvl(l_transform_cache(cnt).source_text, '<NULL>')
                            = nvl(l_batch_bal_cache(dup_cnt).source_text, '<NULL>')
            and nvl(l_transform_cache(cnt).source_number, -999)
                            = nvl(l_batch_bal_cache(dup_cnt).source_number, -999)
            and nvl(l_transform_cache(cnt).source_text2, '<NULL>')
                            = nvl(l_batch_bal_cache(dup_cnt).source_text2, '<NULL>')
            and nvl(l_transform_cache(cnt).time_def_id, -999)
                            = nvl(l_batch_bal_cache(dup_cnt).time_def_id, -999)
            and nvl(l_transform_cache(cnt).local_unit_id, -999)
                            = nvl(l_batch_bal_cache(dup_cnt).local_unit_id, -999)
            and nvl(l_transform_cache(cnt).source_number2, -999)
                            = nvl(l_batch_bal_cache(dup_cnt).source_number2, -999)
            and nvl(l_transform_cache(cnt).organization_id, -999)
                            = nvl(l_batch_bal_cache(dup_cnt).organization_id, -999)
            and nvl(l_transform_cache(cnt).balance_date, to_date('0001/01/01', 'YYYY/MM/DD'))
                            = nvl(l_batch_bal_cache(dup_cnt).balance_date, to_date('0001/01/01', 'YYYY/MM/DD'))
              ) then
            l_add_balance := FALSE;
          end if;
--
       end loop;
--
     hr_utility.trace('Time 5 '||to_char(sysdate, 'HH24:MI:SS'));
       if (l_add_balance = TRUE) then
     hr_utility.trace('Time 6 '||to_char(sysdate, 'HH24:MI:SS'));
         l_batch_bal_cache(l_cache_cnt) := l_transform_cache(cnt);
         l_cache_cnt := l_cache_cnt + 1;
       end if;
     hr_utility.trace('Time 7 '||to_char(sysdate, 'HH24:MI:SS'));
--
     else
     hr_utility.trace('Time 8 '||to_char(sysdate, 'HH24:MI:SS'));
       l_batch_bal_cache(l_cache_cnt) := l_transform_cache(cnt);
       prev_def_bal_id := l_batch_bal_cache(l_cache_cnt).defined_balance_id;
       start_def_bal_ptr := l_cache_cnt;
       l_cache_cnt := l_cache_cnt + 1;
     end if;
     hr_utility.trace('Time 9 '||to_char(sysdate, 'HH24:MI:SS'));
--
   end loop;
--
-- Now get the balances
--
   for con_cnt in 1..p_context_lst.count loop
--
     l_retrieval_list.delete;
--
     -- Set the contexts
     if (p_context_lst(con_cnt).tax_unit_id is not null) then
       set_context('TAX_UNIT_ID', p_context_lst(con_cnt).tax_unit_id);
     end if;
     if (p_context_lst(con_cnt).jurisdiction_code is not null) then
       set_context('JURISDICTION_CODE', p_context_lst(con_cnt).jurisdiction_code);
     end if;
     if (p_context_lst(con_cnt).source_id is not null) then
       set_context('SOURCE_ID', p_context_lst(con_cnt).source_id);
     end if;
     if (p_context_lst(con_cnt).source_text is not null) then
       set_context('SOURCE_TEXT', p_context_lst(con_cnt).source_text);
     end if;
     if (p_context_lst(con_cnt).source_number is not null) then
       set_context('SOURCE_NUMBER', p_context_lst(con_cnt).source_number);
     end if;
     if (p_context_lst(con_cnt).source_text2 is not null) then
       set_context('SOURCE_TEXT2', p_context_lst(con_cnt).source_text2);
     end if;
     if (p_context_lst(con_cnt).time_def_id is not null) then
       set_context('TIME_DEFINITION_ID', p_context_lst(con_cnt).time_def_id);
     end if;
     if (p_context_lst(con_cnt).balance_date is not null) then
       set_context('BALANCE_DATE', to_char(p_context_lst(con_cnt).balance_date,
                                           'YYYY/MM/DD HH24:MI:SS'));
     end if;
     if (p_context_lst(con_cnt).local_unit_id is not null) then
       set_context('LOCAL_UNIT_ID', p_context_lst(con_cnt).local_unit_id);
     end if;
     if (p_context_lst(con_cnt).source_number2 is not null) then
       set_context('SOURCE_NUMBER2', p_context_lst(con_cnt).source_number2);
     end if;
     if (p_context_lst(con_cnt).organization_id is not null) then
       set_context('ORGANIZATION_ID', p_context_lst(con_cnt).organization_id);
     end if;
--
     -- Now loop through the balances to retrieve.
     l_retrieval_cnt := 1;
     for db_cnt in 1..l_batch_bal_cache.count loop
--
       if (l_batch_bal_cache(db_cnt).balance_found = FALSE) then
--
         load_defbal_cache(l_batch_bal_cache(db_cnt).defined_balance_id,
                           l_defbal_rec);
--
         bal_ju_code := substr(l_batch_bal_cache(db_cnt).jurisdiction_code,
                              1,
                              l_defbal_rec.jurisdiction_lvl);
         con_ju_code := substr(p_context_lst(con_cnt).jurisdiction_code,
                            1,
                            l_defbal_rec.jurisdiction_lvl);
--
         if (nvl(p_context_lst(con_cnt).tax_unit_id, -999) =
                   nvl(l_batch_bal_cache(db_cnt).tax_unit_id,
                       nvl(p_context_lst(con_cnt).tax_unit_id, -999))
             and nvl(con_ju_code, '<NULL>') =
                   nvl(bal_ju_code, nvl(con_ju_code, '<NULL>'))
             and nvl(p_context_lst(con_cnt).source_text, '<NULL>') =
                   nvl(l_batch_bal_cache(db_cnt).source_text,
                       nvl(p_context_lst(con_cnt).source_text, '<NULL>'))
             and nvl(p_context_lst(con_cnt).source_number, -999) =
                   nvl(l_batch_bal_cache(db_cnt).source_number,
                       nvl(p_context_lst(con_cnt).source_number, -999))
             and nvl(p_context_lst(con_cnt).source_text2, '<NULL>') =
                   nvl(l_batch_bal_cache(db_cnt).source_text2,
                       nvl(p_context_lst(con_cnt).source_text2, '<NULL>'))
             and nvl(p_context_lst(con_cnt).source_id, -999) =
                   nvl(l_batch_bal_cache(db_cnt).source_id,
                       nvl(p_context_lst(con_cnt).source_id, -999))
             and nvl(p_context_lst(con_cnt).time_def_id, -999) =
                   nvl(l_batch_bal_cache(db_cnt).time_def_id,
                       nvl(p_context_lst(con_cnt).time_def_id, -999))
             and nvl(p_context_lst(con_cnt).local_unit_id, -999) =
                   nvl(l_batch_bal_cache(db_cnt).local_unit_id,
                       nvl(p_context_lst(con_cnt).local_unit_id, -999))
             and nvl(p_context_lst(con_cnt).source_number2, -999) =
                   nvl(l_batch_bal_cache(db_cnt).source_number2,
                       nvl(p_context_lst(con_cnt).source_number2, -999))
             and nvl(p_context_lst(con_cnt).organization_id, -999) =
                   nvl(l_batch_bal_cache(db_cnt).organization_id,
                       nvl(p_context_lst(con_cnt).organization_id, -999))
             and nvl(p_context_lst(con_cnt).balance_date, to_date('0001/01/01', 'YYYY/MM/DD')) =
                   nvl(l_batch_bal_cache(db_cnt).balance_date,
                       nvl(p_context_lst(con_cnt).balance_date, to_date('0001/01/01', 'YYYY/MM/DD')))
           ) then
           --
           l_retrieval_list(l_retrieval_cnt).defined_balance_id :=
                       l_batch_bal_cache(db_cnt).defined_balance_id;
           pos_indx(l_retrieval_cnt) := db_cnt;
           l_retrieval_cnt := l_retrieval_cnt + 1;
           --
         end if;
       end if;
--
     end loop;
--
     -- Now do the retrieval
     get_value(p_assignment_action_id,
               l_retrieval_list,
               p_get_rr_route,
               p_get_rb_route);
--
     -- Put the returned values into the cache table.
     for ret_cnt in 1..l_retrieval_list.count loop
       l_batch_bal_cache(pos_indx(ret_cnt)).balance_value :=
                          l_retrieval_list(ret_cnt).balance_value;
       l_batch_bal_cache(pos_indx(ret_cnt)).balance_found := TRUE;
     end loop;
--
   end loop;
--
   for db_cnt in 1..l_batch_bal_cache.count loop
     p_output_table(db_cnt).defined_balance_id := l_batch_bal_cache(db_cnt).defined_balance_id;
     p_output_table(db_cnt).tax_unit_id        := l_batch_bal_cache(db_cnt).tax_unit_id;
     p_output_table(db_cnt).jurisdiction_code  := l_batch_bal_cache(db_cnt).jurisdiction_code;
     p_output_table(db_cnt).source_id          := l_batch_bal_cache(db_cnt).source_id;
     p_output_table(db_cnt).source_text        := l_batch_bal_cache(db_cnt).source_text;
     p_output_table(db_cnt).source_number      := l_batch_bal_cache(db_cnt).source_number;
     p_output_table(db_cnt).source_text2       := l_batch_bal_cache(db_cnt).source_text2;
     p_output_table(db_cnt).time_def_id        := l_batch_bal_cache(db_cnt).time_def_id;
     p_output_table(db_cnt).local_unit_id      := l_batch_bal_cache(db_cnt).local_unit_id;
     p_output_table(db_cnt).source_number2     := l_batch_bal_cache(db_cnt).source_number2;
     p_output_table(db_cnt).organization_id    := l_batch_bal_cache(db_cnt).organization_id;
     p_output_table(db_cnt).balance_date       := l_batch_bal_cache(db_cnt).balance_date;
     p_output_table(db_cnt).balance_value      := l_batch_bal_cache(db_cnt).balance_value;
   end loop;
--
l_retrieval_list.delete;
l_transform_cache.delete;
l_batch_bal_cache.delete;
--
end get_value;
--
procedure get_value (p_assignment_action_id in            number,
                     p_defined_balance_lst  in out nocopy t_balance_value_tab,
                     p_get_rr_route         in            boolean default FALSE,
                     p_get_rb_route         in            boolean default FALSE)
is
--
l_defbal_rec            t_def_bal_rec;
l_balance_value         number;
l_found                 boolean;
l_balance_cache         t_int_bal_cache;
l_batch_bd_id           pay_balance_dimensions.balance_dimension_id%type;
l_batch_list            t_batch_list;
l_batch_cnt             number;
l_dummy_value           number;
l_decode_required       boolean;
l_jur_lvl               pay_balance_types.jurisdiction_level%type;
--
begin
   g_debug := hr_utility.debug_enabled;
--
   set_context ('ASSIGNMENT_ACTION_ID', p_assignment_action_id);
--
   -- Ensure the internal cache is empty.
   l_balance_cache.delete;
--
   for cnt in 1..p_defined_balance_lst.count loop
--
     load_defbal_cache(p_defined_balance_lst(cnt).defined_balance_id,
                       l_defbal_rec);
--
     get_value_internal (p_defined_balance_lst(cnt).defined_balance_id,
                         l_defbal_rec,
                         p_assignment_action_id,
                         p_get_rr_route,
                         p_get_rb_route,
                         l_found,
                         l_balance_value);
--
     l_balance_cache(cnt).balance_found := l_found;
     l_balance_cache(cnt).balance_value := l_balance_value;
     l_balance_cache(cnt).balance_dimension_id := l_defbal_rec.balance_dimension_id;
     l_balance_cache(cnt).balance_type_id := l_defbal_rec.balance_type_id;
     l_balance_cache(cnt).jurisdiction_level := l_defbal_rec.jurisdiction_lvl;
--
   end loop;
--
   -- any balance that reaches this point that is not found
   -- must be capable of being retrieved by batch.
   --
   for cnt in 1..p_defined_balance_lst.count loop
--
     -- Look for any balances that are not found
--
     if (l_balance_cache(cnt).balance_found = FALSE) then
--
        load_defbal_cache(p_defined_balance_lst(cnt).defined_balance_id,
                          l_defbal_rec);
--
        l_batch_bd_id := l_balance_cache(cnt).balance_dimension_id;
        l_batch_list.delete;
        l_batch_cnt := 1;
        l_jur_lvl := l_defbal_rec.jurisdiction_lvl;
        l_batch_list(l_batch_cnt).balance_type_id := l_balance_cache(cnt).balance_type_id;
        l_batch_list(l_batch_cnt).source_index := cnt;
        for bd_cnt in cnt+1..p_defined_balance_lst.count loop
--
          if (   l_balance_cache(bd_cnt).balance_dimension_id = l_batch_bd_id
             and l_balance_cache(bd_cnt).jurisdiction_level = l_jur_lvl
             and l_balance_cache(bd_cnt).balance_found = FALSE) then
             l_batch_cnt := l_batch_cnt + 1;
             l_batch_list(l_batch_cnt).balance_type_id :=
                             l_balance_cache(bd_cnt).balance_type_id;
             l_batch_list(l_batch_cnt).source_index := bd_cnt;
          end if;
--
        end loop;
--
        -- Now we have set up the batch get the values
--
        l_decode_required := FALSE;
        if (l_defbal_rec.decode_required = 'Y') then
            l_decode_required := TRUE;
        end if;
--
        run_rr_route(
                 TRUE,
        --         null,
                 1,
                 l_batch_list,
                 l_defbal_rec.dim_rou_rr_route_id,
                 l_defbal_rec.balance_type_column,
                 g_dimrou_cache(l_defbal_rec.rr_ptr).retrieval_column,
                 l_decode_required,
                 l_jur_lvl,
                 l_dummy_value
                );
        --
        -- Now match the results up
        --
        -- Use the source index pointer to point back to
        -- the original entry.
--
        for l_batch_cnt in 1..l_batch_list.count loop
          l_balance_cache(l_batch_list(l_batch_cnt).source_index).balance_value
                := l_batch_list(l_batch_cnt).balance_value;
          l_balance_cache(l_batch_list(l_batch_cnt).source_index).balance_found
                := TRUE;
        end loop;
--
     end if;
--
   end loop;
--
-- Now copy the results into the output cache
--
   for cnt in 1..p_defined_balance_lst.count loop
     p_defined_balance_lst(cnt).balance_value := l_balance_cache(cnt).balance_value;
   end loop;
--
end get_value;
--
function get_value
(
    p_defined_balance_id   in number,
    p_assignment_action_id in number,
    p_tax_unit_id          in number,
    p_jurisdiction_code    in varchar2,
    p_source_id            in number,
    p_tax_group            in varchar2,
    p_date_earned          in date
) return number is
p_balance_result number;
begin
   g_debug := hr_utility.debug_enabled;
--
   if p_tax_unit_id is not null then
      set_context('TAX_UNIT_ID', p_tax_unit_id);
   end if;
   if p_jurisdiction_code is not null then
      set_context('JURISDICTION_CODE', p_jurisdiction_code);
   end if;
   if p_source_id is not null then
      set_context('SOURCE_ID', p_source_id);
   end if;
   if p_tax_group is not null then
      set_context('TAX_GROUP', p_tax_group);
   end if;
   if p_date_earned is not null then
      set_context('DATE_EARNED', to_char(p_date_earned, 'YYYY/MM/DD HH24:MI:SS'));
   end if;
--
   p_balance_result := get_value (p_defined_balance_id,
                                  p_assignment_action_id,
                                  false);  -- look for a latest balance first
   return p_balance_result;
end get_value;
--
function get_value
(
    p_defined_balance_id   in number,
    p_assignment_action_id in number,
    p_tax_unit_id          in number,
    p_jurisdiction_code    in varchar2,
    p_source_id            in number,
    p_source_text          in varchar2,
    p_tax_group            in varchar2,
    p_date_earned          in date
) return number is
p_balance_result number;
begin
   g_debug := hr_utility.debug_enabled;
--
   if p_tax_unit_id is not null then
      set_context('TAX_UNIT_ID', p_tax_unit_id);
   end if;
   if p_jurisdiction_code is not null then
      set_context('JURISDICTION_CODE', p_jurisdiction_code);
   end if;
   if p_source_id is not null then
      set_context('SOURCE_ID', p_source_id);
   end if;
   if p_source_text is not null then
      set_context('SOURCE_TEXT', p_source_text);
   end if;
   if p_tax_group is not null then
      set_context('TAX_GROUP', p_tax_group);
   end if;
   if p_date_earned is not null then
      set_context('DATE_EARNED', to_char(p_date_earned, 'YYYY/MM/DD HH24:MI:SS'));
   end if;
--
   p_balance_result := get_value (p_defined_balance_id,
                                  p_assignment_action_id,
                                  false);  -- look for a latest balance first
   return p_balance_result;
end get_value;
--
-- Added to support original entri id context.
--
function get_value
(
    p_defined_balance_id   in number,
    p_assignment_action_id in number,
    p_tax_unit_id          in number,
    p_jurisdiction_code    in varchar2,
    p_source_id            in number,
    p_source_text          in varchar2,
    p_tax_group            in varchar2,
    p_original_entry_id    in number,
    p_date_earned          in date
) return number is
p_balance_result number;
begin
   g_debug := hr_utility.debug_enabled;
--
   if p_tax_unit_id is not null then
      set_context('TAX_UNIT_ID', p_tax_unit_id);
   end if;
   if p_jurisdiction_code is not null then
      set_context('JURISDICTION_CODE', p_jurisdiction_code);
   end if;
   if p_source_id is not null then
      set_context('SOURCE_ID', p_source_id);
   end if;
   if p_source_text is not null then
      set_context('SOURCE_TEXT', p_source_text);
   end if;
   if p_tax_group is not null then
      set_context('TAX_GROUP', p_tax_group);
   end if;
   if p_original_entry_id is not null then
      set_context('ORIGINAL_ENTRY_ID', p_original_entry_id);
   end if;
   if p_date_earned is not null then
      set_context('DATE_EARNED', to_char(p_date_earned, 'YYYY/MM/DD HH24:MI:SS'));
   end if;
--
   p_balance_result := get_value (p_defined_balance_id,
                                  p_assignment_action_id,
                                  false);  -- look for a latest balance first
   return p_balance_result;
end get_value;
--
function get_value
(
    p_defined_balance_id   in number,
    p_assignment_action_id in number
) return number is
p_balance_result number;
begin
   g_debug := hr_utility.debug_enabled;
   p_balance_result := get_value (p_defined_balance_id,
                                  p_assignment_action_id,
                                  false);  -- look for a latest balance first
   return p_balance_result;
end get_value;
--
function get_value
(
    p_defined_balance_id   in number,
    p_assignment_action_id in number,
    p_always_get_db_item   in boolean
) return number is
p_balance_result number;
begin
  g_debug := hr_utility.debug_enabled;
  p_balance_result := get_value(p_defined_balance_id   => p_defined_balance_id
                               ,p_assignment_action_id => p_assignment_action_id
                               ,p_get_rr_route         => p_always_get_db_item
                               ,p_get_rb_route         => false
                               );
  return p_balance_result;
end get_value;
--
function get_value
(p_defined_balance_id   in number
,p_assignment_action_id in number
,p_tax_unit_id          in number
,p_jurisdiction_code    in varchar2
,p_source_id            in number
,p_source_text          in varchar2
,p_tax_group            in varchar2
,p_date_earned          in date
,p_get_rr_route         in varchar2
,p_get_rb_route         in varchar2
,p_source_text2         in varchar2 default null
,p_source_number        in number   default null
,p_time_def_id          in number   default null
,p_balance_date         in date     default null
,p_payroll_id           in number   default null
,p_original_entry_id    in number   default null
,p_local_unit_id        in number   default null
,p_source_number2       in number   default null
,p_organization_id      in number   default null
) return number is
p_balance_result number;
l_get_rr_route   boolean;
l_get_rb_route   boolean;
begin
   g_debug := hr_utility.debug_enabled;
--
   -- p_get_rr_route and p_get_rb_route have been set to number rather than
   -- boolean, so that can be called in a select statement.
--
   if nvl(p_get_rr_route, 'FALSE') = 'TRUE' then
     l_get_rr_route := true;
   elsif nvl(p_get_rr_route, 'FALSE') = 'FALSE' then
     l_get_rr_route := false;
   else
     l_get_rr_route := false;
   end if;
--
   if nvl(p_get_rb_route, 'FALSE') = 'TRUE' then
     l_get_rb_route := true;
   elsif nvl(p_get_rb_route, 'FALSE') = 'FALSE' then
     l_get_rb_route := false;
   else
     l_get_rb_route := false;
   end if;
--
   if p_tax_unit_id is not null then
      set_context('TAX_UNIT_ID', p_tax_unit_id);
   end if;
   if p_jurisdiction_code is not null then
      set_context('JURISDICTION_CODE', p_jurisdiction_code);
   end if;
   if p_source_id is not null then
      set_context('SOURCE_ID', p_source_id);
   end if;
   if p_source_text is not null then
      set_context('SOURCE_TEXT', p_source_text);
   end if;
   if p_tax_group is not null then
      set_context('TAX_GROUP', p_tax_group);
   end if;
   if p_date_earned is not null then
      set_context('DATE_EARNED', to_char(p_date_earned, 'YYYY/MM/DD HH24:MI:SS'));
   end if;
   if p_source_text2 is not null then
      set_context('SOURCE_TEXT2', p_source_text2);
   end if;
   if p_source_number is not null then
      set_context('SOURCE_NUMBER', p_source_number);
   end if;
   if p_time_def_id is not null then
      set_context('TIME_DEFINITION_ID', p_time_def_id);
   end if;
   if p_balance_date is not null then
      set_context('BALANCE_DATE', to_char(p_balance_date, 'YYYY/MM/DD HH24:MI:SS'));
   end if;
   if p_payroll_id is not null then
      set_context('PAYROLL_ID', p_payroll_id);
   end if;
   if p_original_entry_id is not null then
      set_context('ORIGINAL_ENTRY_ID', p_original_entry_id);
   end if;
   if p_local_unit_id is not null then
      set_context('LOCAL_UNIT_ID', p_local_unit_id);
   end if;
   if p_source_number2 is not null then
      set_context('SOURCE_NUMBER2', p_source_number2);
   end if;
   if p_organization_id is not null then
      set_context('ORGANIZATION_ID', p_organization_id);
   end if;
--
   p_balance_result := get_value
                        (p_defined_balance_id   => p_defined_balance_id
                        ,p_assignment_action_id => p_assignment_action_id
                        ,p_get_rr_route         => l_get_rr_route
                        ,p_get_rb_route         => l_get_rb_route
                        );
  return p_balance_result;
end get_value;
--
function get_value
(
    p_defined_balance_id   in number
,   p_assignment_action_id in number
,   p_get_rr_route         in boolean
,   p_get_rb_route         in boolean
) return number is p_balance_result number;
--
l_balance_value         pay_person_latest_balances.value%type;
l_found                 boolean;
l_defbal_rec            t_def_bal_rec;
--
------------------------- get_value (action mode) -------------------------
--
begin
  g_debug := hr_utility.debug_enabled;
  if g_debug then
     hr_utility.set_location ('pay_balance_pkg.get_value - ACTION MODE', 1);
     hr_utility.trace ('def_bal_id    = ' || to_char(p_defined_balance_id));
     hr_utility.trace ('asg_action_id = ' || to_char(p_assignment_action_id));
  end if;
  --
  -- Set up the context of assignment action:
  --
  set_context ('ASSIGNMENT_ACTION_ID', p_assignment_action_id);
  --
  load_defbal_cache(p_defined_balance_id,
                    l_defbal_rec);
  --
  get_value_internal (p_defined_balance_id,
                      l_defbal_rec,
                      p_assignment_action_id,
                      p_get_rr_route,
                      p_get_rb_route,
                      l_found,
                      l_balance_value);
  --
  -- The only time get_value_internal does not return a
  -- balance value is when it is a batch enabled RR route.
  --
  if (l_found = FALSE) then
    get_rr_value(p_defined_balance_id,
                 l_balance_value);
  end if;
--
  p_balance_result := l_balance_value;
  return p_balance_result;
end get_value;  -- assignment action mode
--
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--                                                                        +
--                     get_value (date mode)                              +
--                                                                        +
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--
/*
NAME
  get_value        - Retrieve a balance (date mode)
--
DESCRIPTION
  The balance routes are all driven off assignment action id.  So, when a
  balance is required for a particular date, a payroll action and assignment
  action are temporarily created.  This is done by setting a savepoint,
  inserting a dummy payroll action for the required date, and calling the
  hrassact.inassact procedure to insert the corresponding assignment action
  and shuffle any later assignment actions along.  The get_value
  function is then called with the dummy assignment action, which returns the
  balance value for the required date.  A rollback then removes the temporary
  payroll action and assignment action.
  --
  The parameter 'p_always_get_db_item' if set to TRUE will always derive the
  balance from the route and not even try to find a latest balance value.
  This parameter is used for testing purposes, to verify the latest balance
  value.
  --
  There are 2 overloaded versions of the get_value function below.  The first
  one is called by the forms/ reports.  The second has the option of setting
  the 'p_always_get_db_item' value.  This is necessary since the forms do not
  support default parameters.
*/
function get_value
(
    p_defined_balance_id   in number,
    p_assignment_id        in number,
    p_virtual_date         in date
) return number is
p_balance_result number;
begin
  g_debug := hr_utility.debug_enabled;
  p_balance_result := get_value_lock (p_defined_balance_id,
                                      p_assignment_id,
                                      p_virtual_date,
                                      false, -- look for a latest balance first
                                      'Y');
  return p_balance_result;
end get_value;
--
function get_value
(
    p_defined_balance_id   in number,
    p_assignment_id        in number,
    p_virtual_date         in date,
    p_always_get_db_item   in boolean
) return number is
p_balance_result number;
begin
  g_debug := hr_utility.debug_enabled;
  p_balance_result := get_value_lock (p_defined_balance_id,
                                      p_assignment_id,
                                      p_virtual_date,
                                      p_always_get_db_item,
                                      'Y');
  return p_balance_result;
end get_value;
--
function get_value_lock
(
    p_defined_balance_id   in number,
    p_assignment_id        in number,
    p_virtual_date         in date,
    p_asg_lock             in varchar2
) return number is
p_balance_result number;
begin
  g_debug := hr_utility.debug_enabled;
  p_balance_result := get_value_lock (p_defined_balance_id,
                                      p_assignment_id,
                                      p_virtual_date,
                                      false, -- look for a latest balance first
                                      p_asg_lock);
  return p_balance_result;
end get_value_lock;
--
function get_value_lock_internal
(
    p_defined_balance_id   in number,
    p_assignment_id        in number,
    p_virtual_date         in date,
    p_always_get_db_item   in boolean,
    p_asg_lock             in varchar2
) return number is
p_balance_result number;
--
l_payroll_id     per_all_assignments_f.payroll_id%type;
l_bus_grp_id     per_all_assignments_f.business_group_id%type;
l_consol_set_id  pay_all_payrolls_f.payroll_id%type;
l_ass_action_id  pay_assignment_actions.assignment_action_id%type;
l_pay_action_id  pay_payroll_actions.payroll_action_id%type;
l_time_period_id per_time_periods.time_period_id%type;
l_asg_lock       boolean;
--
begin
  g_debug := hr_utility.debug_enabled;
  if g_debug then
     hr_utility.set_location ('pay_balance_pkg.get_value - DATE MODE', 1);
     hr_utility.trace ('def_bal_id = ' || to_char(p_defined_balance_id));
     hr_utility.trace ('Assign_id  = ' || to_char(p_assignment_id));
     hr_utility.trace ('V_date     = ' || to_char (p_virtual_date));
  end if;
  --
  -- Set the assignment locking flag.
  --
  l_asg_lock := FALSE;
  if (p_asg_lock = 'Y') then
     l_asg_lock := TRUE;
  end if;
  --
  SAVEPOINT bal_date_mode;
  --
  -- get the payroll information
  --
  if g_debug then
     hr_utility.set_location ('pay_balance_pkg.get_value', 10);
  end if;
  select ASSIGN.payroll_id,
         ASSIGN.business_group_id,
         PAYROLL.consolidation_set_id
  into   l_payroll_id,
         l_bus_grp_id,
         l_consol_set_id
  from   per_all_assignments_f   ASSIGN
  ,      pay_all_payrolls_f      PAYROLL
  where  ASSIGN.assignment_id  = p_assignment_id
  and    p_virtual_date  between ASSIGN.effective_start_date
                             and ASSIGN.effective_end_date
  and    PAYROLL.payroll_id    = ASSIGN.payroll_id
  and    p_virtual_date  between PAYROLL.effective_start_date
                             and PAYROLL.effective_end_date;
  --
  -- If there is a time period id, then get it, else use a null value:
  --
  begin
    if g_debug then
       hr_utility.set_location ('pay_balance_pkg.get_value', 12);
    end if;
    select TIMEP.time_period_id
    into   l_time_period_id
    from   per_time_periods        TIMEP
    where  TIMEP.payroll_id      = l_payroll_id
    and    p_virtual_date  between TIMEP.start_date
                               and TIMEP.end_date;
  exception
    when no_data_found then
      if g_debug then
         hr_utility.set_location ('pay_balance_pkg.get_value', 13);
      end if;
      l_time_period_id := null;
  end;
  --
  -- get the next value for payroll action id
  --
  select pay_payroll_actions_s.nextval
  into   l_pay_action_id
  from   dual;
  --
  -- insert a temporary row into pay_payroll_actions
  --
  if g_debug then
     hr_utility.set_location ('pay_balance_pkg.get_value', 20);
  end if;
  insert into pay_payroll_actions
  (payroll_action_id,
   action_type,
   business_group_id,
   consolidation_set_id,
   payroll_id,
   action_population_status,
   action_status,
   effective_date,
   date_earned,
   time_period_id,
   object_version_number)
  values
  (l_pay_action_id,
   'N',                           -- not tracked action type
   l_bus_grp_id,
   l_consol_set_id,
   l_payroll_id,
   'U',
   'U',
   p_virtual_date,
   p_virtual_date,
   l_time_period_id,
   1);
  --
  -- now insert the assignment action:
  --
  if g_debug then
     hr_utility.set_location ('pay_balance_pkg.get_value', 25);
  end if;
  hrassact.inassact (pactid     => l_pay_action_id,
                     asgid      => p_assignment_id,
                     p_asg_lock => l_asg_lock);
  --
  -- retrieve the assignment action id:
  --
  if g_debug then
     hr_utility.set_location ('pay_balance_pkg.get_value', 30);
  end if;
  select assignment_action_id
  into   l_ass_action_id
  from   pay_assignment_actions
  where  payroll_action_id = l_pay_action_id;
  --
  if g_debug then
     hr_utility.trace ('Assignment action id = ' || to_char (l_ass_action_id));
  end if;
  --
  -- Now retrieve the balance for this temp. assignment action:
  --
  p_balance_result := get_value (p_defined_balance_id,
                                 l_ass_action_id,
                                 p_always_get_db_item);
  rollback to bal_date_mode;
  return p_balance_result;
--
exception
  when others then
    rollback to bal_date_mode;
    raise;
end get_value_lock_internal;
--
-- This function returns the latest assignment action ID given an assignment
-- and effective date. This is called from all Date Mode functions.
-- Modified the hint for bug: 7521485
FUNCTION get_latest_action_id (p_mode           IN VARCHAR2,
                               p_assignment_id  IN NUMBER,
                               p_effective_date IN DATE)
RETURN NUMBER IS
--
   l_assignment_action_id       NUMBER;
--
cursor get_latest_id (c_assignment_id IN NUMBER,
                      c_effective_date IN DATE) is
    SELECT /*+ ORDERED USE_NL(paa,ppa) */
         fnd_number.canonical_to_number(substr(max(lpad(paa.action_sequence,15,'
0')||
         paa.assignment_action_id),16))
    FROM pay_assignment_actions paa,
         pay_payroll_actions    ppa
    WHERE
         paa.assignment_id = c_assignment_id
    AND  ppa.payroll_action_id = paa.payroll_action_id
    AND  ppa.effective_date <= c_effective_date
    AND  ppa.action_type        in ('R', 'Q', 'I', 'V', 'B');
--
cursor get_per_latest_id (c_assignment_id IN NUMBER,
                          c_effective_date IN DATE) is
    SELECT /*+ INDEX(PAF1 PER_ASSIGNMENTS_F_PK)
               INDEX(PAF2 PER_ASSIGNMENTS_F_N12)
               INDEX(PAA PAY_ASSIGNMENT_ACTIONS_N51)
               INDEX(PPA PAY_PAYROLL_ACTIONS_PK)
               USE_NL(paa, ppa) */
         fnd_number.canonical_to_number(substr(max(lpad(paa.action_sequence,15,'0')||
         paa.assignment_action_id),16))
    FROM pay_assignment_actions paa,
         pay_payroll_actions    ppa,
         per_all_assignments_f  paf1,
         per_all_assignments_f  paf2
    WHERE
         paf1.assignment_id = c_assignment_id
    AND  c_effective_date between paf1.effective_start_date
                              and paf1.effective_end_date
    AND  paf2.person_id     = paf1.person_id
    AND  paf2.effective_start_date = (select max(paf3.effective_start_date)
                                        from per_all_assignments_f paf3
                                       where paf3.assignment_id = paf2.assignment_id
                                         and paf3.effective_start_date <= c_effective_date)
    AND  paf2.assignment_id = paa.assignment_id
    AND  ppa.payroll_action_id = paa.payroll_action_id
    AND  ppa.effective_date <= c_effective_date
    AND  ppa.action_type        in ('R', 'Q', 'I', 'V', 'B');
--
BEGIN
--
    if (p_mode = 'ASG') then
--
      open get_latest_id(p_assignment_id, p_effective_date);
      fetch get_latest_id into l_assignment_action_id;
      close get_latest_id;
--
    elsif (p_mode = 'PER') then
--
      open get_per_latest_id(p_assignment_id, p_effective_date);
      fetch get_per_latest_id into l_assignment_action_id;
      close get_per_latest_id;
--
    end if;
--
RETURN l_assignment_action_id;
--
END get_latest_action_id;
--
procedure get_value_seq_internal
(
    p_defined_balance_id   in     number,
    p_assignment_id        in     number,
    p_virtual_date         in     date,
    p_always_get_db_item   in     boolean,
    p_defbal_rec           in     t_def_bal_rec,
    p_balance_value           out nocopy number
)
is
l_assignment_action_id pay_assignment_actions.assignment_action_id%type;
l_pact_payroll_id      pay_payroll_actions.payroll_action_id%type;
l_pact_eff_date        date;
l_expiry_date          date;
l_balance_value        number := null;
l_found                boolean;
begin
--
   if (p_defbal_rec.dimension_lvl = 'PER') then
      l_assignment_action_id := get_latest_action_id(
                                                     'PER',
                                                     p_assignment_id,
                                                     p_virtual_date);
   elsif (p_defbal_rec.dimension_lvl = 'ASG') then
      l_assignment_action_id := get_latest_action_id(
                                                     'ASG',
                                                     p_assignment_id,
                                                     p_virtual_date);
   end if;
--
   /* If we have an assignment action we can use get value */
   if (l_assignment_action_id is not null) then
--
      set_context ('ASSIGNMENT_ACTION_ID', l_assignment_action_id);
--
      get_value_internal (p_defined_balance_id,
                          p_defbal_rec,
                          l_assignment_action_id,
                          p_always_get_db_item,
                          FALSE,
                          l_found,
                          l_balance_value);
      --
      -- The only time get_value_internal does not return a
      -- balance value is when it is a batch enabled RR route.
      --
      if (l_found = FALSE) then
        get_rr_value(p_defined_balance_id,
                     l_balance_value);
      end if;
--
      /* OK now we have the value we need to do the expiry checking
      */
--
      select ppa.effective_date,
             ppa.payroll_id
        into l_pact_eff_date,
             l_pact_payroll_id
        from pay_payroll_actions ppa,
             pay_assignment_actions paa
       where paa.assignment_action_id = l_assignment_action_id
         and paa.payroll_action_id = ppa.payroll_action_id;
--
      if (p_defbal_rec.period_type is not null
         and p_defbal_rec.period_type in ('YEAR',
                                          'QUARTER',
                                          'PERIOD',
                                          'MONTH')
        ) then

            get_period_type_end(p_period_type => p_defbal_rec.period_type,
                                p_effective_date  => l_pact_eff_date,
                                p_end_date        => l_expiry_date,
                                p_payroll_id      => l_pact_payroll_id);
--
            if (l_expiry_date < p_virtual_date) then
--
              /* Balance value has expired */
              l_balance_value := 0;
            end if;
--
      elsif (nvl(p_defbal_rec.expiry_check_lvl, 'N') = 'N') then
--
            /* Never expires, hence use value */
            null;
--
      end if;
--
  end if;
--
  p_balance_value := l_balance_value;
--
end get_value_seq_internal;
--
function get_value_lock
(
    p_defined_balance_id   in number,
    p_assignment_id        in number,
    p_virtual_date         in date,
    p_always_get_db_item   in boolean,
    p_asg_lock             in varchar2
) return number is
--
l_balance_value number;
l_defbal_rec    t_def_bal_rec;
use_date_get_val boolean;
use_seq_get_val boolean;
--
begin
--
  use_date_get_val := TRUE;
  use_seq_get_val := FALSE;
--
  load_defbal_cache(p_defined_balance_id,
                    l_defbal_rec);
--
  /* If its a group level balance forget it, use the date get value
  */
  if (    l_defbal_rec.dimension_lvl is not null
      and l_defbal_rec.dimension_lvl <> 'GRP') then
--
     /* OK if it is a Run or Payment balance then it
        will always be 0 in date mode
     */
     if (l_defbal_rec.dimension_type = 'R') then
--
         l_balance_value := 0;
         use_date_get_val := FALSE;
--
     elsif (l_defbal_rec.period_type is not null
            and l_defbal_rec.period_type in ('PAYMENT', 'RUN')) then
--
         l_balance_value := 0;
         use_date_get_val := FALSE;
--
     /* If it's not a complex balance we may be able to get the value
     */
     elsif (l_defbal_rec.expiry_check_lvl <> 'E') then
--
        /* At the moment we can only support certain periods
        */
        if (l_defbal_rec.period_type is not null
            and l_defbal_rec.period_type in ('YEAR',
                                             'QUARTER',
                                             'PERIOD',
                                             'MONTH')
           ) then
--
               use_seq_get_val := TRUE;
--
        elsif (nvl(l_defbal_rec.expiry_check_lvl, 'N') = 'N') then
--
               use_seq_get_val := TRUE;
--
        end if;
--
        if (use_seq_get_val = TRUE) then
--
            get_value_seq_internal
            (
                p_defined_balance_id   => p_defined_balance_id,
                p_assignment_id        => p_assignment_id,
                p_virtual_date         => p_virtual_date,
                p_always_get_db_item   => p_always_get_db_item,
                p_defbal_rec           => l_defbal_rec,
                p_balance_value        => l_balance_value
            );
--
            if (l_balance_value is not null) then
                use_date_get_val := FALSE;
            end if;
--
        end if;
--
     end if;
--
  end if;
--
  if (use_date_get_val = TRUE) then
--
      l_balance_value := get_value_lock_internal
                          (
                              p_defined_balance_id   => p_defined_balance_id,
                              p_assignment_id        => p_assignment_id,
                              p_virtual_date         => p_virtual_date,
                              p_always_get_db_item   => p_always_get_db_item,
                              p_asg_lock             => p_asg_lock
                          );
  end if;
--
  return l_balance_value;
--
end get_value_lock;
--
--------------------------------------------------------------------------
-- procedure invalidate_run_balances
-- Bug 3397712 - removed the filter on run balances from the cursor
-- get_def_bals, as this was preventing rows being returned that should be
-- invalidated when a feed is added to a balance.
--
-- bug 9296481 - only check for result after invalid date
--------------------------------------------------------------------------
procedure invalidate_run_balances(p_balance_type_id in number,
                                  p_input_value_id  in number,
                                  p_invalid_date    in date)
is
--
cursor get_def_bals(p_bal_id number,
                    p_iv_id  number)
is
select pdb.defined_balance_id
from   pay_defined_balances pdb,
       pay_balance_validation pbv
where  pdb.balance_type_id = p_bal_id
and    pdb.save_run_balance = 'Y'
and    pbv.defined_balance_id = pdb.defined_balance_id
and    pbv.run_balance_status in ('P', 'V');

-- Select if run result value exists for input value
cursor ivchk is
select '1' from dual
 where exists
    (select /*+ ORDERED INDEX(RRV PAY_RUN_RESULT_VALUES_PK)
                        INDEX(PRR PAY_RUN_RESULTS_PK) */
            1
       from pay_run_result_values rrv,
            pay_run_results prr,
            pay_assignment_actions assact,
            pay_payroll_actions pact
      where rrv.input_value_id = p_input_value_id
        and prr.run_result_id  = rrv.run_result_id
        and prr.status         in ('P', 'PA')
        and nvl(rrv.result_value, '0') <> '0'
        and assact.assignment_action_id = prr.assignment_action_id
        and pact.payroll_action_id = assact.payroll_action_id
        and pact.effective_date > p_invalid_date);

l_ivchk varchar2(2);
l_rrv_found number := -1;
--
BEGIN
  g_debug := hr_utility.debug_enabled;
  if g_debug then
     hr_utility.set_location('Entering: pay_balance_pkg.invalidate_run_balances',5);
  end if;
--
  if HRASSACT.CHECK_LATEST_BALANCES = TRUE then
--
    for each_row in get_def_bals(p_balance_type_id, p_input_value_id) loop
--
      if l_rrv_found = -1 then
         open ivchk;

         fetch ivchk
         into l_ivchk;

         if ivchk%FOUND then
            l_rrv_found := 1;
         else
            l_rrv_found := 0;
            close ivchk;
            exit;
         end if;
         close ivchk;
      end if; --}

      if l_rrv_found = 1 then
         update pay_balance_validation
         set    run_balance_status = 'I'
         where   defined_balance_id = each_row.defined_balance_id;
         if g_debug then
            hr_utility.set_location('pay_balance_pkg.invalidate_run_balances', 15);
         end if;
      end if;
   end loop;
   if g_debug then
       hr_utility.set_location('Leaving: pay_balance_pkg.invalidate_run_balances', 20);
    end if;
--
  end if;
--
END invalidate_run_balances;
--------------------------------------------------------------------------
-- procedure invalidate_run_balances
--------------------------------------------------------------------------
procedure invalidate_run_balances(p_balance_type_id in number,
                                  p_invalid_date    in date)
is
--
cursor get_def_bals(p_bal_id number)
is
select pdb.defined_balance_id
from   pay_defined_balances pdb
where  pdb.balance_type_id = p_bal_id
and    pdb.save_run_balance = 'Y';
--
BEGIN
  g_debug := hr_utility.debug_enabled;
  if g_debug then
     hr_utility.set_location('Entering: pay_balance_pkg.invalidate_run_balances',5);
  end if;
  for each_row in get_def_bals(p_balance_type_id) loop
--
    update pay_balance_validation
    set    run_balance_status = 'I'
    where   defined_balance_id = each_row.defined_balance_id;
    if g_debug then
       hr_utility.set_location('pay_balance_pkg.invalidate_run_balances', 15);
    end if;
  end loop;
  if g_debug then
     hr_utility.set_location('Leaving: pay_balance_pkg.invalidate_run_balances', 20);
  end if;
END invalidate_run_balances;
--------------------------------------------------------------------------
-- get_run_result_info
--------------------------------------------------------------------------
-- Description: This procedure returns the information related to the
--              specified run result ID.
--
procedure get_run_result_info
  (p_run_result_id  in         number
  ,p_run_result_rec out nocopy t_run_result_rec
  )
is
  --
  l_rr_rec         t_run_result_rec;
  --
  cursor csr_rr
  is
  select
    prr.run_result_id
   ,prr.element_type_id
   ,prr.jurisdiction_code
   ,paa.assignment_action_id
   ,paa.assignment_id
   ,paa.tax_unit_id
   ,paa.payroll_action_id
   ,prr.time_definition_id
   ,prr.end_date
   ,prr.local_unit_id
  from
    pay_assignment_actions   paa
   ,pay_run_results          prr
  where
      paa.assignment_action_id = prr.assignment_action_id
  and prr.run_result_id        = p_run_result_id
  ;

  cursor csr_ppa(p_payroll_action_id number)
  is
  select
    ppa.effective_date
   ,pbg.legislation_code
   ,ppa.business_group_id
  from
    per_business_groups_perf pbg
   ,pay_payroll_actions      ppa
  where
      pbg.business_group_id    = ppa.business_group_id
  and ppa.payroll_action_id    = p_payroll_action_id
  ;

begin
  --
  -- Check if cache exists.
  --
  if p_run_result_id = g_run_result_rec.run_result_id then
    p_run_result_rec := g_run_result_rec;
  else
    --
    -- Get the run result info.
    --
    open csr_rr;
    fetch csr_rr into l_rr_rec.run_result_id
                     ,l_rr_rec.element_type_id
                     ,l_rr_rec.jurisdiction_code
                     ,l_rr_rec.assignment_action_id
                     ,l_rr_rec.assignment_id
                     ,l_rr_rec.tax_unit_id
                     ,l_rr_rec.payroll_action_id
                     ,l_rr_rec.time_def_id
                     ,l_rr_rec.balance_date
                     ,l_rr_rec.local_unit_id;
    close csr_rr;
    --
    -- Check if the old cache holds the same payroll action info.
    --
    if l_rr_rec.payroll_action_id = g_run_result_rec.payroll_action_id then
      --
      l_rr_rec.effective_date   := g_run_result_rec.effective_date;
      l_rr_rec.legislation_code := g_run_result_rec.legislation_code;
      l_rr_rec.business_group_id:= g_run_result_rec.business_group_id;
      --
    else
      --
      open csr_ppa(l_rr_rec.payroll_action_id);
      fetch csr_ppa into l_rr_rec.effective_date
                        ,l_rr_rec.legislation_code
                        ,l_rr_rec.business_group_id;
      close csr_ppa;
      --
    end if;
    -- reset the global cache.
    g_run_result_rec := l_rr_rec;
    p_run_result_rec := l_rr_rec;
    --
  end if;

end get_run_result_info;
--
--------------------------------------------------------------------------
-- find_context
--------------------------------------------------------------------------
function find_context(p_context_name in varchar2,
                      p_context_id   in number) return varchar2
is
--
cursor get_sval(p_rr_id in number,
                p_iv_name in varchar2,
                p_ele_id  in number,
                p_effdate in date) is
select prrv.result_value
  from pay_run_result_values  prrv,
       pay_input_values_f     piv
 where prrv.run_result_id = p_rr_id
   and piv.name = p_iv_name
   and piv.input_value_id = prrv.input_value_id
   and piv.element_type_id = p_ele_id
   and p_effdate between piv.effective_start_date
                     and piv.effective_end_date;
--
cnt_value pay_run_result_values.result_value%type;
l_rr_rec           t_run_result_rec;
l_inp_val_name pay_input_values_f.name%type;
l_found boolean;
--
begin
--
   get_run_result_info(p_context_id, l_rr_rec);
--
   pay_core_utils.get_leg_context_iv_name(p_context_name,
                                          l_rr_rec.legislation_code,
                                          l_inp_val_name,
                                          l_found
                                         );
--
   if (l_found = TRUE) then
--
     cnt_value := null;
     open get_sval(p_context_id,
                   l_inp_val_name,
                   l_rr_rec.element_type_id,
                   l_rr_rec.effective_date);
     fetch get_sval into cnt_value;
     close get_sval;
--
     return cnt_value;
--
   else
     return null;
   end if;
--
end find_context;
--
--------------------------------------------------------------------------
-- search_rb_cache
-- Description:
--    Search a run balance cache for a specified run balance.
--------------------------------------------------------------------------
procedure search_rb_cache(
                          p_defined_balanceid  in            number,
                          p_payroll_action_id  in            number,
                          p_tax_unit_id        in            number,
                          p_jur_code           in            varchar2,
                          p_src_id             in            number,
                          p_src_txt            in            varchar2,
                          p_src_num            in            number,
                          p_src_txt2           in            varchar2,
                          p_time_def_id        in            number,
                          p_balance_date       in            date,
                          p_local_unit_id      in            number,
                          p_source_number2     in            number,
                          p_organization_id    in            number,
                          p_int_mlt_thrd_cache in            t_int_rb_cache,
                          p_grp_rb_ptr_list    in            number_array,
                          p_current_ptr           out nocopy number,
                          p_previous_ptr          out nocopy number,
                          p_found                 out nocopy boolean
                         )
is
l_found boolean;
prev_ptr number;
current_ptr number;
begin
--
  if g_debug then
     hr_utility.set_location('Entering: pay_balance_pkg.search_rb_cache', 5);
  end if;
  if (p_grp_rb_ptr_list.exists(p_defined_balanceid)) then
--
    current_ptr := p_grp_rb_ptr_list(p_defined_balanceid);
    prev_ptr := null;
    l_found := FALSE;
    while (current_ptr is not null and
           l_found = FALSE) loop
--
      if        p_int_mlt_thrd_cache(current_ptr).defined_balance_id         = p_defined_balanceid
        and     p_int_mlt_thrd_cache(current_ptr).payroll_action_id          = p_payroll_action_id
        and nvl(p_int_mlt_thrd_cache(current_ptr).tax_unit_id, -1)           = nvl(p_tax_unit_id, -1)
        and nvl(p_int_mlt_thrd_cache(current_ptr).jurisdiction_code, 'null') = nvl(p_jur_code, 'null')
        and nvl(p_int_mlt_thrd_cache(current_ptr).source_id, -1)             = nvl(p_src_id, -1)
        and nvl(p_int_mlt_thrd_cache(current_ptr).source_text, 'null')       = nvl(p_src_txt, 'null')
        and nvl(p_int_mlt_thrd_cache(current_ptr).source_number, -1)         = nvl(p_src_num, -1)
        and nvl(p_int_mlt_thrd_cache(current_ptr).source_text2, 'null')      = nvl(p_src_txt2, 'null')
        and nvl(p_int_mlt_thrd_cache(current_ptr).time_def_id, -1)           = nvl(p_time_def_id, -1)
        and nvl(p_int_mlt_thrd_cache(current_ptr).balance_date, to_date('0001/01/01', 'YYYY/MM/DD'))
                                       = nvl(p_balance_date, to_date('0001/01/01', 'YYYY/MM/DD'))
        and nvl(p_int_mlt_thrd_cache(current_ptr).local_unit_id, -1)         = nvl(p_local_unit_id, -1)
        and nvl(p_int_mlt_thrd_cache(current_ptr).source_number2, -1)        = nvl(p_source_number2, -1)
        and nvl(p_int_mlt_thrd_cache(current_ptr).organization_id, -1)       = nvl(p_organization_id, -1)
      then
--
         l_found := TRUE;
         if g_debug then
            hr_utility.set_location('pay_balance_pkg.search_rb_cache', 10);
         end if;
--
      else
--
        prev_ptr := current_ptr;
        current_ptr := p_int_mlt_thrd_cache(current_ptr).next;
        if g_debug then
           hr_utility.set_location('pay_balance_pkg.search_rb_cache', 15);
        end if;
--
      end if;
--
    end loop;
--
  else
    prev_ptr := null;
    current_ptr := null;
    l_found      := FALSE;
  end if;
--
  p_found := l_found;
  p_current_ptr := current_ptr;
  p_previous_ptr := prev_ptr;
--
  if g_debug then
     hr_utility.set_location('Leaving: pay_balance_pkg.search_rb_cache', 20);
  end if;
--
end search_rb_cache;
--
--------------------------------------------------------------------------
-- subtract_from_grp_bal
-- Description:
--     Subtract a given amount from a group balance
--------------------------------------------------------------------------
procedure subtract_from_grp_bal(
                                p_grp_def_bal_id     in            number,
                                p_payroll_action_id  in            number,
                                p_tax_unit_id        in            number,
                                p_jur_code           in            varchar2,
                                p_src_id             in            number,
                                p_src_txt            in            varchar2,
                                p_src_num            in            number,
                                p_src_txt2           in            varchar2,
                                p_time_def_id        in            number,
                                p_balance_date       in            date,
                                p_local_unit_id      in            number,
                                p_source_number2     in            number,
                                p_organization_id    in            number,
                                p_amount             in            number,
                                p_effective_date     in            date,
                                p_int_mlt_thrd_cache in out nocopy t_int_rb_cache,
                                p_grp_rb_ptr_list    in out nocopy number_array,
                                p_multi_thread       in            boolean default TRUE
                               )
is
--
cursor get_row_to_update(p_defined_balance_id number
                        ,p_pact_id            number
                        ,p_gre                number
                        ,p_jd                 varchar2
                        ,p_src_id             number
                        ,p_src_tx             varchar2
                        ,p_src_num            number
                        ,p_src_txt2           varchar2
                        ,p_time_def_id        number
                        ,p_balance_date       date
                        ,p_local_unit_id      number
                        ,p_source_number2     number
                        ,p_organization_id    number)
is
select run_balance_id
,      balance_value
from pay_run_balances
where defined_balance_id             = p_defined_balance_id
and   payroll_action_id              = p_pact_id
and   nvl(tax_unit_id, -1)           = nvl(p_gre, -1)
and   nvl(jurisdiction_code, 'null') = nvl(p_jd, 'null')
and   nvl(source_id, -1)             = nvl(p_src_id, -1)
and   nvl(source_text, 'null')       = nvl(p_src_tx, 'null')
and   nvl(source_number, -1)         = nvl(p_src_num, -1)
and   nvl(source_text2, 'null')      = nvl(p_src_txt2, 'null')
and   nvl(time_definition_id, -1)    = nvl(p_time_def_id, -1)
and   nvl(local_unit_id, -1)         = nvl(p_local_unit_id, -1)
and   nvl(source_number2, -1)        = nvl(p_source_number2, -1)
and   nvl(organization_id, -1)       = nvl(p_organization_id, -1)
and   nvl(balance_date, to_date('0001/01/01', 'YYYY/MM/DD'))
                                     = nvl(p_balance_date, to_date('0001/01/01', 'YYYY/MM/DD'))
and   rownum = 1;
--
l_grp_run_bal_id  pay_run_balances.run_balance_id%type;
l_grp_run_bal_val pay_run_balances.balance_value%type;
l_cache_ct        number;
l_found           boolean;
l_jur1            pay_run_balances.jurisdiction_comp1%type;
l_jur2            pay_run_balances.jurisdiction_comp2%type;
l_jur3            pay_run_balances.jurisdiction_comp3%type;
l_current_ptr     number;
l_previous_ptr     number;
--
begin
--
  if p_amount <> 0 then
  --
    if g_debug then
       hr_utility.set_location('pay_balance_pkg.subtract_from_grp_bal', 25);
    end if;
    --
    if not p_multi_thread then -- i.e. if in single thread mode
      --
      -- update existing row, by subtracting the contributing amount
      --
      if g_debug then
         hr_utility.trace('p_grp_def_bal_id: '||p_grp_def_bal_id);
         hr_utility.trace('pactid: '||p_payroll_action_id);
      end if;
        open  get_row_to_update(p_grp_def_bal_id
                               ,p_payroll_action_id
                               ,p_tax_unit_id
                               ,p_jur_code
                               ,p_src_id
                               ,p_src_txt
                               ,p_src_num
                               ,p_src_txt2
                               ,p_time_def_id
                               ,p_balance_date
                               ,p_local_unit_id
                               ,p_source_number2
                               ,p_organization_id
                               );
        fetch get_row_to_update into l_grp_run_bal_id, l_grp_run_bal_val;
--
        if get_row_to_update%notfound then
        --
        -- error as should find a row for updating
        --
          close get_row_to_update;
          hr_general.assert_condition(false);
        --
        else
          close get_row_to_update;
          if g_debug then
             hr_utility.set_location('pay_balance_pkg.subtract_from_grp_bal', 40);
             hr_utility.trace('p_grp_def_bal_id: '||to_char(p_grp_def_bal_id));
             hr_utility.trace('l_grp_run_bal_val: '||to_char(l_grp_run_bal_val));
             hr_utility.trace('contrib amt: '||to_char(p_amount));
          end if;
          --
          update pay_run_balances
          set    balance_value = (balance_value - p_amount)
          where  run_balance_id = l_grp_run_bal_id;
          --
        end if;
        --
    else  -- is multi threaded mode
      --
      -- if a row for this balance exists in the cache, then update that row
      -- else, create a row and add it to the cache
      --
      search_rb_cache( p_grp_def_bal_id,
                       p_payroll_action_id,
                       p_tax_unit_id,
                       p_jur_code,
                       p_src_id,
                       p_src_txt,
                       p_src_num,
                       p_src_txt2,
                       p_time_def_id,
                       p_balance_date,
                       p_local_unit_id,
                       p_source_number2,
                       p_organization_id,
                       p_int_mlt_thrd_cache,
                       p_grp_rb_ptr_list,
                       l_current_ptr,
                       l_previous_ptr,
                       l_found
                      );
--
      if (l_found = TRUE) then
      --
        if g_debug then
           hr_utility.set_location('pay_balance_pkg.subtract_from_grp_bal', 50);
           hr_utility.trace('MULTI THREADED UPDATE');
        end if;
        update pay_run_balances
        set    balance_value = balance_value - p_amount
        where  run_balance_id =  p_int_mlt_thrd_cache(l_current_ptr).run_balance_id;
        --
      else  -- no row for this balance
        if g_debug then
           hr_utility.trace('MULTI THREADED INSERT');
           hr_utility.set_location('pay_balance_pkg.subtract_from_grp_bal', 55);
        end if;
        --
        --
        select pay_run_balances_s.nextval
        into l_grp_run_bal_id
        from dual;
        --
        split_jurisdiction(p_jur_code,
                           l_jur1,
                           l_jur2,
                           l_jur3);
--
        insert into pay_run_balances
        (run_balance_id
        ,defined_balance_id
        ,payroll_action_id
        ,effective_date
        ,balance_value
        ,tax_unit_id
        ,jurisdiction_code
        ,jurisdiction_comp1
        ,jurisdiction_comp2
        ,jurisdiction_comp3
        ,source_id
        ,source_text
        ,source_number
        ,source_text2
        ,time_definition_id
        ,balance_date
        ,local_unit_id
        ,source_number2
        ,organization_id
        )
        values
        (l_grp_run_bal_id
        ,p_grp_def_bal_id
        ,p_payroll_action_id
        ,p_effective_date
        ,- p_amount
        ,p_tax_unit_id
        ,p_jur_code
        ,l_jur1
        ,l_jur2
        ,l_jur3
        ,p_src_id
        ,p_src_txt
        ,p_src_num
        ,p_src_txt2
        ,p_time_def_id
        ,p_balance_date
        ,p_local_unit_id
        ,p_source_number2
        ,p_organization_id
        );
        if g_debug then
           hr_utility.set_location('pay_balance_pkg.subtract_from_grp_bal', 60);
        end if;
        --
        -- cache the row details
        --
        --
        -- cache the row details
        --
        l_cache_ct := p_int_mlt_thrd_cache.count + 1;
        --
        p_int_mlt_thrd_cache(l_cache_ct).run_balance_id     := l_grp_run_bal_id;
        p_int_mlt_thrd_cache(l_cache_ct).defined_balance_id := p_grp_def_bal_id;
        p_int_mlt_thrd_cache(l_cache_ct).payroll_action_id  := p_payroll_action_id;
        p_int_mlt_thrd_cache(l_cache_ct).tax_unit_id        := p_tax_unit_id;
        p_int_mlt_thrd_cache(l_cache_ct).jurisdiction_code  := p_jur_code;
        p_int_mlt_thrd_cache(l_cache_ct).source_id          := p_src_id;
        p_int_mlt_thrd_cache(l_cache_ct).source_text        := p_src_txt;
        p_int_mlt_thrd_cache(l_cache_ct).source_number      := p_src_num;
        p_int_mlt_thrd_cache(l_cache_ct).source_text2       := p_src_txt2;
        p_int_mlt_thrd_cache(l_cache_ct).time_def_id        := p_time_def_id;
        p_int_mlt_thrd_cache(l_cache_ct).balance_date       := p_balance_date;
        p_int_mlt_thrd_cache(l_cache_ct).local_unit_id      := p_local_unit_id;
        p_int_mlt_thrd_cache(l_cache_ct).source_number2     := p_source_number2;
        p_int_mlt_thrd_cache(l_cache_ct).organization_id    := p_organization_id;
        p_int_mlt_thrd_cache(l_cache_ct).next               := null;
--
        if (l_previous_ptr is null) then
          p_grp_rb_ptr_list(p_grp_def_bal_id):= l_cache_ct;
        else
          p_int_mlt_thrd_cache(l_previous_ptr).next := l_cache_ct;
        end if;
        --
        if g_debug then
           hr_utility.set_location('pay_balance_pkg.subtract_from_grp_bal', 65);
        end if;
        --
      end if;
      --
    end if;
  else -- not > 0
    if g_debug then
       hr_utility.set_location('pay_balance_pkg.subtract_from_grp_bal', 70);
    end if;
  end if;
--
end subtract_from_grp_bal;
--
--------------------------------------------------------------------------
-- remove_asg_contribs
-- Description: Removes assignment contributions to a run balance group balance
--              from the run balance group balance, i.e. when an assignment is
--              rolled back, the group balance needs to redueced by the
--              amount contributed by that assignment.
--------------------------------------------------------------------------
procedure remove_asg_contribs
(p_payroll_action_id   in number
,p_assignment_action_id in number
,p_multi_thread in boolean default false
) is
--
-- Get all the group defined_balances
--
cursor get_dbs(p_pact number) is
select distinct defined_balance_id
  from pay_run_balances
 where payroll_action_id = p_pact;
--
cursor get_contexts(p_asg_action    in number,
                    p_si_needed  in varchar2,
                    p_st_needed  in varchar2,
                    p_sn_needed  in varchar2,
                    p_st2_needed  in varchar2,
                    p_sn2_needed  in varchar2,
                    p_org_needed  in varchar2) is
select /*+ ORDERED USE_NL(prr) INDEX(prr pay_run_results_n50)*/
       distinct
       paa.tax_unit_id                                         tax_unit_id
,      prr.jurisdiction_code                                   jurisdiction_code
,      decode(p_si_needed,
              'Y', find_context('SOURCE_ID', prr.run_result_id),
              null)                                            source_id
,      decode(p_st_needed,
              'Y', find_context('SOURCE_TEXT', prr.run_result_id),
              null)                                            source_text
,      decode(p_sn_needed,
              'Y', find_context('SOURCE_NUMBER', prr.run_result_id),
              null)                                            source_number
,      decode(p_st2_needed,
              'Y', find_context('SOURCE_TEXT2', prr.run_result_id),
              null)                                            source_text2
,      decode(p_sn2_needed,
              'Y', find_context('SOURCE_NUMBER2', prr.run_result_id),
              null)                                            source_number2
,      decode(p_org_needed,
              'Y', find_context('ORGANIZATION_ID', prr.run_result_id),
              null)                                            organization_id
,      prr.time_definition_id
,      nvl(prr.end_date, ptp.end_date)                         balance_date
,      prr.local_unit_id                                       local_unit_id
,      ppa.effective_date
  from pay_assignment_actions paa,
       pay_payroll_actions    ppa,
       per_time_periods       ptp,
       pay_run_results        prr
 where paa.assignment_action_id = p_asg_action
   and ppa.payroll_action_id = paa.payroll_action_id
   and paa.assignment_action_id = prr.assignment_action_id
   and ptp.payroll_id = ppa.payroll_id
   and ppa.date_earned between ptp.start_date
                           and ptp.end_date
  order by 1, 2, 3, 4;
--
cursor get_bg (pactid number) is
select pbg.business_group_id, pbg.legislation_code
  from pay_payroll_actions ppa,
       per_business_groups_perf pbg
 where payroll_action_id = pactid
   and pbg.business_group_id = ppa.business_group_id;
--
l_output_list        t_detailed_bal_out_tab;
l_contexts           t_context_tab;
l_cnt                number;
l_eff_date            date;
l_asg_def_bal_id     number;
l_found              boolean;
l_asgbal_cnt         number;
l_inp_val_name       pay_input_values_f.name%type;
--
BEGIN
  g_debug := hr_utility.debug_enabled;
  if g_debug then
     hr_utility.set_location('Entering: pay_balance_pkg.remove_asg_contribs', 5);
  end if;
--
  if (p_payroll_action_id <> g_payroll_action) then
--
    /* First get the legislation rule */
    begin
       select plr.rule_mode
         into g_save_run_bals
         from pay_legislation_rules plr,
              per_business_groups_perf pbg,
              pay_payroll_actions ppa
        where ppa.payroll_action_id = p_payroll_action_id
          and ppa.business_group_id = pbg.business_group_id
          and pbg.legislation_code = plr.legislation_code
          and plr.rule_type = 'SAVE_RUN_BAL';
    exception
       when no_data_found then
         g_save_run_bals := 'N';
    end;
    --
    --
--
    l_cnt := 1;
--
    if (g_save_run_bals = 'Y') then
--
    -- OK setup the balances to use
--
      -- Reset everything
      g_rlb_grp_defbals.delete;
      g_rlb_asg_defbals.delete;
--
      for dbrec in get_dbs(p_payroll_action_id) loop
      --
        g_rlb_grp_defbals(l_cnt).defined_balance_id := dbrec.defined_balance_id;
--
        -- Now maintain the assignment ones
        select pdb.defined_balance_id
          into g_rlb_asg_defbals(l_cnt).defined_balance_id
          from pay_defined_balances pdb,
               pay_defined_balances pdb_grp,
               pay_balance_dimensions pbd
         where pdb_grp.defined_balance_id = g_rlb_grp_defbals(l_cnt).defined_balance_id
           and pdb_grp.balance_dimension_id = pbd.balance_dimension_id
           and pdb.balance_type_id = pdb_grp.balance_type_id
           and pdb.balance_dimension_id = pbd.asg_action_balance_dim_id;
--
        l_cnt := l_cnt + 1;
      --
      end loop;
--
      -- Check whether the SOURCE_ID, SOURCE_TEXT contexts are used.
      g_si_needed_chr := 'N';
      g_st_needed_chr := 'N';
      g_sn_needed_chr := 'N';
      g_st2_needed_chr := 'N';
      g_sn2_needed_chr := 'N';
      g_org_needed_chr := 'N';
      for bgrec in get_bg(p_payroll_action_id) loop
--
        pay_core_utils.get_leg_context_iv_name('SOURCE_ID',
                                               bgrec.legislation_code,
                                               l_inp_val_name,
                                               l_found
                                              );
       if (l_found = TRUE) then
         g_si_needed_chr := 'Y';
       end if;
--
        pay_core_utils.get_leg_context_iv_name('SOURCE_TEXT',
                                               bgrec.legislation_code,
                                               l_inp_val_name,
                                               l_found
                                              );
       if (l_found = TRUE) then
         g_st_needed_chr := 'Y';
       end if;
--
        pay_core_utils.get_leg_context_iv_name('SOURCE_NUMBER',
                                               bgrec.legislation_code,
                                               l_inp_val_name,
                                               l_found
                                              );
       if (l_found = TRUE) then
         g_sn_needed_chr := 'Y';
       end if;
--
        pay_core_utils.get_leg_context_iv_name('SOURCE_TEXT2',
                                               bgrec.legislation_code,
                                               l_inp_val_name,
                                               l_found
                                              );
       if (l_found = TRUE) then
         g_st2_needed_chr := 'Y';
       end if;
--
        pay_core_utils.get_leg_context_iv_name('SOURCE_NUMBER2',
                                               bgrec.legislation_code,
                                               l_inp_val_name,
                                               l_found
                                              );
       if (l_found = TRUE) then
         g_sn2_needed_chr := 'Y';
       end if;
--
        pay_core_utils.get_leg_context_iv_name('ORGANIZATION_ID',
                                               bgrec.legislation_code,
                                               l_inp_val_name,
                                               l_found
                                              );
       if (l_found = TRUE) then
         g_org_needed_chr := 'Y';
       end if;
--
      end loop;
--
      g_payroll_action := p_payroll_action_id;
--
      -- The Run balances to maintain will be different since its a
      -- new payroll action.
--
      g_grp_maintained_rb.delete;
      g_grp_rb_ptr_list.delete;
--
    end if;
--
  end if;
  --
  -- Is run Balances set
  --
  if (g_save_run_bals = 'Y') then
    --
    -- Only need to do somethinf if there are group balances
    --
    if (g_rlb_grp_defbals.count > 0) then
      --
      -- Now get the contexts
      --
      l_cnt := 1;
      for ctxrec in get_contexts(p_assignment_action_id,
                                 g_si_needed_chr,
                                 g_st_needed_chr,
                                 g_sn_needed_chr,
                                 g_st2_needed_chr,
                                 g_sn2_needed_chr,
                                 g_org_needed_chr) loop
--
        l_contexts(l_cnt).tax_unit_id        := ctxrec.tax_unit_id;
        l_contexts(l_cnt).jurisdiction_code  := ctxrec.jurisdiction_code;
        l_contexts(l_cnt).source_id          := ctxrec.source_id;
        l_contexts(l_cnt).source_text        := ctxrec.source_text;
        l_contexts(l_cnt).source_number      := ctxrec.source_number;
        l_contexts(l_cnt).source_text2       := ctxrec.source_text2;
        l_contexts(l_cnt).time_def_id        := ctxrec.time_definition_id;
        l_contexts(l_cnt).local_unit_id      := ctxrec.local_unit_id;
        l_contexts(l_cnt).source_number2     := ctxrec.source_number2;
        l_contexts(l_cnt).organization_id    := ctxrec.organization_id;
        l_contexts(l_cnt).balance_date       := ctxrec.balance_date;
        l_eff_date                           := ctxrec.effective_date;
        l_cnt := l_cnt + 1;
--
      end loop;
--
      pay_balance_pkg.get_value (p_assignment_action_id,
                                 g_rlb_asg_defbals,
                                 l_contexts,
                                 FALSE,
                                 FALSE,
                                 l_output_list);
--
      for l_cnt in 1..l_output_list.count loop
--
       --
       -- First find the group equivolent
       --
       l_found := FALSE;
       l_asgbal_cnt := 0;
       while (l_found = FALSE and l_asgbal_cnt < g_rlb_asg_defbals.count) loop
--
          l_asgbal_cnt := l_asgbal_cnt + 1;
          if (g_rlb_asg_defbals(l_asgbal_cnt).defined_balance_id =
                        l_output_list(l_cnt).defined_balance_id) then
--
            l_found := TRUE;
--
          end if;
--
       end loop;
--
       -- Now make the adjustment
       subtract_from_grp_bal(
                                 g_rlb_grp_defbals(l_asgbal_cnt).defined_balance_id,
                                 p_payroll_action_id,
                                 l_output_list(l_cnt).tax_unit_id,
                                 l_output_list(l_cnt).jurisdiction_code,
                                 l_output_list(l_cnt).source_id,
                                 l_output_list(l_cnt).source_text,
                                 l_output_list(l_cnt).source_number,
                                 l_output_list(l_cnt).source_text2,
                                 l_output_list(l_cnt).time_def_id,
                                 l_output_list(l_cnt).balance_date,
                                 l_output_list(l_cnt).local_unit_id,
                                 l_output_list(l_cnt).source_number2,
                                 l_output_list(l_cnt).organization_id,
                                 l_output_list(l_cnt).balance_value,
                                 l_eff_date,
                                 g_grp_maintained_rb,
                                 g_grp_rb_ptr_list,
                                 p_multi_thread
                                );
--
      end loop;
--
    end if;
--
  end if;
  if g_debug then
     hr_utility.set_location('Leaving: pay_balance_pkg.remove_asg_contribs', 80);
  end if;
END remove_asg_contribs;
--
--------------------------------------------------------------------------
-- procedure ins_run_balance
--------------------------------------------------------------------------
procedure ins_run_balance (p_defined_balance_id in number,
                           p_eff_date           in date,
                           p_bal_val            in number,
                           p_asg_act_id         in number default null,
                           p_payroll_act_id     in number default null,
                           p_asg_id             in number default null,
                           p_act_seq            in number default null,
                           p_tax_unit           in number default null,
                           p_jurisdiction       in varchar2 default null,
                           p_source_id          in number default null,
                           p_source_text        in varchar2 default null,
                           p_source_number      in varchar2 default null,
                           p_source_text2       in varchar2 default null,
                           p_time_def_id        in number   default null,
                           p_balance_date       in date     default null,
                           p_local_unit_id      in number   default null,
                           p_source_number2     in number   default null,
                           p_organization_id    in number   default null,
                           p_tax_group          in varchar2 default null
                          )
is
l_jur1 pay_run_balances.jurisdiction_comp1%type;
l_jur2 pay_run_balances.jurisdiction_comp2%type;
l_jur3 pay_run_balances.jurisdiction_comp3%type;
begin
--
  split_jurisdiction(p_jurisdiction,
                     l_jur1,
                     l_jur2,
                     l_jur3);
--
  insert into pay_run_balances
           (
             run_balance_id,
             defined_balance_id,
             assignment_action_id,
             payroll_action_id,
             assignment_id,
             action_sequence,
             effective_date,
             balance_value,
             tax_unit_id,
             jurisdiction_code,
             jurisdiction_comp1,
             jurisdiction_comp2,
             jurisdiction_comp3,
             source_id,
             source_text,
             source_number,
             source_text2,
             time_definition_id,
             balance_date,
             local_unit_id,
             source_number2,
             organization_id,
             tax_group
            )
       values (
             pay_run_balances_s.nextval,
             p_defined_balance_id,
             p_asg_act_id,
             p_payroll_act_id,
             p_asg_id,
             p_act_seq,
             p_eff_date,
             p_bal_val,
             p_tax_unit,
             p_jurisdiction,
             l_jur1,
             l_jur2,
             l_jur3,
             p_source_id,
             p_source_text,
             p_source_number,
             p_source_text2,
             p_time_def_id,
             p_balance_date,
             p_local_unit_id,
             p_source_number2,
             p_organization_id,
             p_tax_group
            );
--
end ins_run_balance;

--
--------------------------------------------------------------------------
-- procedure ins_run_balance_bulk
-- Inserts into pay_run_balances /* Added for bug 6676876 */
--------------------------------------------------------------------------
procedure ins_run_balance_bulk (p_output_list     in t_detailed_bal_out_tab,
                                p_asgact_id       in pay_assignment_actions.assignment_action_id%type,
                                p_pact_id         in pay_assignment_actions.payroll_action_id%type,
                                p_assignment_id   in pay_assignment_actions.assignment_id%type,
                                p_action_sequence in pay_assignment_actions.action_sequence%type,
                                p_effective_date  in pay_payroll_actions.effective_date%type
                              )
is

  Type t_pay_run_bal is table of pay_run_balances%rowtype index by binary_integer;
  l_pay_run_bal t_pay_run_bal;

  i number;
  lv_run_balance_id pay_run_balances.run_balance_id%type;
  l_output_list   t_detailed_bal_out_tab;

  l_jur1 pay_run_balances.jurisdiction_comp1%type;
  l_jur2 pay_run_balances.jurisdiction_comp2%type;
  l_jur3 pay_run_balances.jurisdiction_comp3%type;
begin
--
     hr_utility.trace('Enter ins_run_balance_bulk ');
     i := 0;
     lv_run_balance_id := null;
     hr_utility.trace('In ins_run_balance_bulk 1');
     for cnt in 1..p_output_list.count loop
       if (p_output_list(cnt).balance_value <> 0) then
             i:=i+1;

          select pay_run_balances_s.nextval
          into lv_run_balance_id
          from dual;

          split_jurisdiction(p_output_list(cnt).jurisdiction_code,
                     l_jur1,
                     l_jur2,
                     l_jur3);
     hr_utility.trace('In ins_run_balance_bulk 2');
             l_pay_run_bal(i).run_balance_id        :=  lv_run_balance_id;
             l_pay_run_bal(i).defined_balance_id    :=  p_output_list(cnt).defined_balance_id;
             l_pay_run_bal(i).assignment_action_id  :=  p_asgact_id;
             l_pay_run_bal(i).payroll_action_id     :=  p_pact_id;
             l_pay_run_bal(i).assignment_id         :=  p_assignment_id;
             l_pay_run_bal(i).action_sequence       :=  p_action_sequence;
             l_pay_run_bal(i).effective_date        :=  p_effective_date;
             l_pay_run_bal(i).balance_value         :=  p_output_list(cnt).balance_value;
             l_pay_run_bal(i).tax_unit_id           :=  p_output_list(cnt).tax_unit_id;
             l_pay_run_bal(i).jurisdiction_code     :=  p_output_list(cnt).jurisdiction_code;
             l_pay_run_bal(i).jurisdiction_comp1    :=  l_jur1;
             l_pay_run_bal(i).jurisdiction_comp2    :=  l_jur2;
             l_pay_run_bal(i).jurisdiction_comp3    :=  l_jur3;
             l_pay_run_bal(i).source_id             :=  p_output_list(cnt).source_id;
             l_pay_run_bal(i).source_text           :=  p_output_list(cnt).source_text;
             l_pay_run_bal(i).source_number         :=  p_output_list(cnt).source_number;
             l_pay_run_bal(i).source_text2          :=  p_output_list(cnt).source_text2;
             l_pay_run_bal(i).time_definition_id    :=  p_output_list(cnt).time_def_id;
             l_pay_run_bal(i).balance_date          :=  p_output_list(cnt).balance_date;
             l_pay_run_bal(i).local_unit_id         :=  p_output_list(cnt).local_unit_id;
             l_pay_run_bal(i).source_number2        :=  p_output_list(cnt).source_number2;
             l_pay_run_bal(i).organization_id       :=  p_output_list(cnt).organization_id;
             l_pay_run_bal(i).tax_group             :=  null;
       end if;
     end loop;
--
     hr_utility.trace('In ins_run_balance_bulk 3');
 forall a in 1..l_pay_run_bal.count
 insert into pay_run_balances values l_pay_run_bal(a) ;

     hr_utility.trace('Deleting the values from the l_pay_run_bal table ');
     l_pay_run_bal.delete;
     hr_utility.trace('Leaving ins_run_balance_bulk ');
--
end ins_run_balance_bulk;

--
procedure create_run_balance (
                              p_batch_mode           in            boolean default FALSE,
                              p_def_bal_id           in            number,
                              p_mode                 in            varchar2,
                              p_asg_act              in            number,
                              p_pactid               in            number,
                              p_effective_date       in            date,
                              p_contexts             in out nocopy t_context_details_rec,
                              p_defined_balance_lst  in out nocopy t_balance_value_tab
                             )
is
--
cursor get_aa_info(p_asg_act_id in number) is
select assignment_id
,      action_sequence
from   pay_assignment_actions
where  assignment_action_id = p_asg_act_id;
--
  bal_val        number;
  l_tx_ut        pay_assignment_actions.tax_unit_id%type;
  l_asg_id       pay_assignment_actions.assignment_id%type;
  l_act_seq      pay_assignment_actions.action_sequence%type;
  l_asgact_id    pay_assignment_actions.assignment_action_id%type;
  l_pactid       pay_payroll_actions.payroll_action_id%type;
begin
--
--
   if g_debug then
      hr_utility.set_location('pay_balance_pkg.create_run_balance', 30);
      hr_utility.trace('Getting Balance'||p_def_bal_id);
   end if;
   /* First setup the contexts */
   if (nvl(p_contexts.tax_unit_id, -999) <> nvl(p_contexts.prv_tax_unit_id, -999)) then
      pay_balance_pkg.set_context('TAX_UNIT_ID', p_contexts.tax_unit_id);
      p_contexts.prv_tax_unit_id := p_contexts.tax_unit_id;
      if p_contexts.tax_unit_id is null then
         p_contexts.tu_set    := FALSE;
      else
         p_contexts.tu_set    := TRUE;
      end if;
   end if;
   if (nvl(p_contexts.jurisdiction_code, 'NULL') <> nvl(p_contexts.prv_jurisdiction_code, 'NULL'))
     then
     pay_balance_pkg.set_context('JURISDICTION_CODE',p_contexts.jurisdiction_code);
     p_contexts.prv_jurisdiction_code := p_contexts.jurisdiction_code;
      if p_contexts.jurisdiction_code is null then
         p_contexts.jc_set    := FALSE;
      else
         p_contexts.jc_set    := TRUE;
      end if;
   end if;
   if (nvl(p_contexts.source_id, -999) <> nvl(p_contexts.prv_source_id, -999)) then
      pay_balance_pkg.set_context('SOURCE_ID', p_contexts.source_id);
      p_contexts.prv_source_id := p_contexts.source_id;
      if p_contexts.source_id is null then
         p_contexts.si_set    := FALSE;
      else
         p_contexts.si_set    := TRUE;
      end if;
   end if;
   if (nvl(p_contexts.source_text, 'NULL') <> nvl(p_contexts.prv_source_text, 'NULL')) then
      pay_balance_pkg.set_context('SOURCE_TEXT', p_contexts.source_text);
      p_contexts.prv_source_text := p_contexts.source_text;
      if p_contexts.source_text is null then
         p_contexts.st_set    := FALSE;
      else
         p_contexts.st_set    := TRUE;
      end if;
   end if;
   if (nvl(p_contexts.source_number, 'NULL') <> nvl(p_contexts.prv_source_number, 'NULL')) then
      pay_balance_pkg.set_context('SOURCE_NUMBER', p_contexts.source_number);
      p_contexts.prv_source_number := p_contexts.source_number;
      if p_contexts.source_number is null then
         p_contexts.sn_set    := FALSE;
      else
         p_contexts.sn_set    := TRUE;
      end if;
   end if;
   if (nvl(p_contexts.source_text2, 'NULL') <> nvl(p_contexts.prv_source_text2, 'NULL')) then
      pay_balance_pkg.set_context('SOURCE_TEXT2', p_contexts.source_text2);
      p_contexts.prv_source_text2 := p_contexts.source_text2;
      if p_contexts.source_text2 is null then
         p_contexts.st2_set    := FALSE;
      else
         p_contexts.st2_set    := TRUE;
      end if;
   end if;
   if (nvl(p_contexts.time_def_id, -999) <> nvl(p_contexts.prv_time_def_id, -999)) then
      pay_balance_pkg.set_context('TIME_DEFINITION_ID', p_contexts.time_def_id);
      p_contexts.prv_time_def_id := p_contexts.time_def_id;
      if p_contexts.time_def_id is null then
         p_contexts.td_set    := FALSE;
      else
         p_contexts.td_set    := TRUE;
      end if;
   end if;
   if (nvl(p_contexts.balance_date, to_date('0001/01/01 00:00:00', 'YYYY/MM/DD HH24:MI:SS')) <> nvl(p_contexts.prv_balance_date, to_date('0001/01/01 00:00:00', 'YYYY/MM/DD HH24:MI:SS'))) then
      set_context('BALANCE_DATE'
                 ,fnd_date.date_to_canonical(p_contexts.balance_date));
      p_contexts.prv_balance_date := p_contexts.balance_date;
      if p_contexts.balance_date is null then
         p_contexts.bd_set    := FALSE;
      else
         p_contexts.bd_set    := TRUE;
      end if;
   end if;
   if (nvl(p_contexts.local_unit_id, -999) <> nvl(p_contexts.prv_local_unit_id, -999)) then
      pay_balance_pkg.set_context('LOCAL_UNIT_ID', p_contexts.local_unit_id);
      p_contexts.prv_local_unit_id := p_contexts.local_unit_id;
      if p_contexts.local_unit_id is null then
         p_contexts.lu_set    := FALSE;
      else
         p_contexts.lu_set    := TRUE;
      end if;
   end if;
   if (nvl(p_contexts.source_number2, -999) <> nvl(p_contexts.prv_source_number2, -999)) then
      pay_balance_pkg.set_context('SOURCE_NUMBER2', p_contexts.source_number2);
      p_contexts.prv_source_number2 := p_contexts.source_number2;
      if p_contexts.source_number2 is null then
         p_contexts.sn2_set    := FALSE;
      else
         p_contexts.sn2_set    := TRUE;
      end if;
   end if;
   if (nvl(p_contexts.organization_id, -999) <> nvl(p_contexts.prv_organization_id, -999)) then
      pay_balance_pkg.set_context('ORGANIZATION_ID', p_contexts.organization_id);
      p_contexts.prv_organization_id := p_contexts.organization_id;
      if p_contexts.organization_id is null then
         p_contexts.org_set    := FALSE;
      else
         p_contexts.org_set    := TRUE;
      end if;
   end if;
--
   if ((p_contexts.tu_needed and p_contexts.tu_set = FALSE) or
       (p_contexts.jc_needed and p_contexts.jc_set = FALSE) or
       (p_contexts.si_needed and p_contexts.si_set = FALSE) or
       (p_contexts.sn_needed and p_contexts.sn_set = FALSE) or
       (p_contexts.st2_needed and p_contexts.st2_set = FALSE) or
       (p_contexts.st_needed and p_contexts.st_set = FALSE) or
       (p_contexts.td_needed and p_contexts.td_set = FALSE) or
       (p_contexts.lu_needed and p_contexts.lu_set = FALSE) or
       (p_contexts.sn2_needed and p_contexts.sn2_set = FALSE) or
       (p_contexts.org_needed and p_contexts.org_set = FALSE) or
       (p_contexts.bd_needed and p_contexts.bd_set = FALSE)) then
     --
     -- Do nothing, not all the contexts are set.
     --
     null;
   else
   --
   -- set the tax unit id, if it is not needed then it should be null
   -- even if the cursor brought a value back;
   --
     if (p_mode = 'ASG') then
         l_asgact_id := p_asg_act;
         open get_aa_info(l_asgact_id);
         fetch get_aa_info into l_asg_id, l_act_seq;
         close get_aa_info;
         l_pactid := null;
     else
         l_asg_id := null;
         l_act_seq := null;
         l_asgact_id := null;
         l_pactid := p_pactid;
     end if;
--
     if not p_contexts.tu_needed then
       l_tx_ut := null;
     else
       l_tx_ut := p_contexts.tax_unit_id;
     end if;
   --
     /* Now get the balance value */
     bal_val := pay_balance_pkg.get_value
                   (p_defined_balance_id    => p_def_bal_id
                   ,p_assignment_action_id  => p_asg_act
                   ,p_get_rr_route          => true
                   ,p_get_rb_route          => false);
--
     if (bal_val <> 0) then
       if g_debug then
          hr_utility.set_location('pay_balance_pkg.create_run_balance', 35);
       end if;
       ins_run_balance (p_defined_balance_id => p_def_bal_id,
                        p_eff_date           => p_effective_date,
                        p_bal_val            => bal_val,
                        p_payroll_act_id     => l_pactid,
                        p_asg_act_id         => l_asgact_id,
                        p_asg_id             => l_asg_id,
                        p_act_seq            => l_act_seq,
                        p_tax_unit           => l_tx_ut,
                        p_jurisdiction       => p_contexts.jurisdiction_code,
                        p_source_id          => p_contexts.source_id,
                        p_source_text        => p_contexts.source_text,
                        p_source_number      => p_contexts.source_number,
                        p_source_text2       => p_contexts.source_text2,
                        p_time_def_id        => p_contexts.time_def_id,
                        p_balance_date       => p_contexts.balance_date,
                        p_local_unit_id      => p_contexts.local_unit_id,
                        p_source_number2     => p_contexts.source_number2,
                        p_organization_id    => p_contexts.organization_id
                       );
     end if;
   end if;
--
   if g_debug then
      hr_utility.set_location('pay_balance_pkg.create_run_balance', 40);
   end if;
--
end create_run_balance;
--
--------------------------------------------------------------------------
-- procedure check_defbal_context
--------------------------------------------------------------------------
-- Description: This procedure assesses the capability of the contexts for
--              the specified defined balance and returns the context
--              record whose unnecessary context values are removed.
--
procedure check_defbal_context
  (p_defined_balance_id   in     number
  ,p_context              in out nocopy t_context_rec
  ,p_defbal_rec              out nocopy t_def_bal_rec
  ,p_valid_contexts          out nocopy boolean
  )
is
begin

  --
  -- Derive context usages for the defined balance.
  --
  load_defbal_cache(p_defined_balance_id, p_defbal_rec);

  --
  -- Nullify unnecessary context values.
  --
  if not p_defbal_rec.tu_needed then
    p_context.tax_unit_id       := null;
  end if;
  if not p_defbal_rec.jc_needed then
    p_context.jurisdiction_code := null;
  end if;
  if not p_defbal_rec.si_needed then
    p_context.source_id := null;
  end if;
  if not p_defbal_rec.st_needed then
    p_context.source_text := null;
  end if;
  if not p_defbal_rec.st2_needed then
    p_context.source_text2 := null;
  end if;
  if not p_defbal_rec.sn_needed then
    p_context.source_number := null;
  end if;
  if not p_defbal_rec.td_needed then
    p_context.time_def_id := null;
  end if;
  if not p_defbal_rec.bd_needed then
    p_context.balance_date := null;
  end if;
  if not p_defbal_rec.lu_needed then
    p_context.local_unit_id := null;
  end if;
  if not p_defbal_rec.sn2_needed then
    p_context.source_number2 := null;
  end if;
  if not p_defbal_rec.org_needed then
    p_context.organization_id := null;
  end if;

  --
  -- Check to see if necessary contexts are set.
  --
  if   (p_defbal_rec.tu_needed and p_context.tax_unit_id is null)
    or (p_defbal_rec.jc_needed and p_context.jurisdiction_code is null)
    or (p_defbal_rec.si_needed and p_context.source_id is null)
    or (p_defbal_rec.st_needed and p_context.source_text is null)
    or (p_defbal_rec.st2_needed and p_context.source_text2 is null)
    or (p_defbal_rec.sn_needed and p_context.source_number is null)
    or (p_defbal_rec.td_needed and p_context.time_def_id is null)
    or (p_defbal_rec.lu_needed and p_context.local_unit_id is null)
    or (p_defbal_rec.sn2_needed and p_context.source_number2 is null)
    or (p_defbal_rec.org_needed and p_context.organization_id is null)
    or (p_defbal_rec.bd_needed and p_context.balance_date is null)
  then
    p_valid_contexts := FALSE;
  else
    p_valid_contexts := TRUE;
  end if;

end check_defbal_context;
--
--------------------------------------------------------------------------
-- procedure create_rr_asg_balances
--------------------------------------------------------------------------
-- Description: This procedure creates assignment level run balances
--              based on the specified run result id.
--              This is intended to be called from (batch) balance
--              adjustment so that it can process assignment run balances
--              per adjustment.
--
procedure create_rr_asg_balances
  (p_run_result_id    in number
  )
is
--
  l_proc            varchar2(80):= ' pay_balance_pkg.create_rr_asg_balances';

  l_legrule_found     boolean      := FALSE;
  l_save_run_bal_flag varchar2(30) := 'N';
  l_rr_ctx            t_context_rec;         -- Run result level context
  l_bal_ctx           t_context_rec;         -- Run result level context
  l_context           t_context_rec;
  l_defbal_rec        t_def_bal_rec;         -- Defined balance context usage
  l_defbal_ctx        t_context_details_rec; -- Defined balance level context
  l_defbal_list       t_balance_value_tab;
  l_valid_contexts    boolean;

  l_rr_info           t_run_result_rec;

  --
  -- Cursor to retrieve defined balances that could be connected
  -- with assignment run balances.
  --
  -- #6151064. Ensuring the defined balances are for the processing
  --           business group.
  --
  cursor csr_defbal
    (p_rr_id          in number
    ,p_ele_id         in number
    ,p_effective_date in date
    ,p_bus_grp_id     in number
    ,p_leg_code       in varchar2)
  is
  select
    /*+ ORDERED USE_NL(pbf, pdb, pbd, prrv) */
    distinct pdb.defined_balance_id
  from
    pay_input_values_f     piv
   ,pay_balance_feeds_f    pbf
   ,pay_defined_balances   pdb
   ,pay_balance_dimensions pbd
   ,pay_run_result_values  prrv
  where
      pbd.dimension_level = 'ASG'
  and pdb.save_run_balance = 'Y'
  and (   (pdb.business_group_id = p_bus_grp_id
           and pdb.legislation_code is null)
       or (pdb.legislation_code = p_leg_code
           and pdb.business_group_id is null)
       or (pdb.legislation_code is null
           and pdb.business_group_id is null))
  and pdb.balance_dimension_id = pbd.balance_dimension_id
  and pdb.balance_type_id = pbf.balance_type_id
  and p_effective_date between pbf.effective_start_date
                           and pbf.effective_end_date
  and pbf.input_value_id = piv.input_value_id
  and piv.element_type_id = p_ele_id
  and p_effective_date between piv.effective_start_date
                           and piv.effective_end_date
  and prrv.input_value_id = piv.input_value_id
  and prrv.run_result_id = p_rr_id
  and prrv.result_value is not null
  ;

begin
--
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  -- Derive information for the specified run result.
  --
  get_run_result_info(p_run_result_id, l_rr_info);

  --
  -- Check SAVE_ASG_RUN_BAL legislation rule.
  --
  pay_core_utils.get_legislation_rule
    (p_legrul_name   => 'SAVE_ASG_RUN_BAL'
    ,p_legislation   => l_rr_info.legislation_code
    ,p_legrul_value  => l_save_run_bal_flag
    ,p_found         => l_legrule_found
    );

  if NOT (l_legrule_found and l_save_run_bal_flag = 'Y') then

    if g_debug then
      hr_utility.set_location(l_proc, 10);
    end if;
    -- Saving run balance is not supported, exit the process.
    return;
  end if;

  if g_debug then
    hr_utility.set_location(l_proc, 20);
  end if;
  --
  -- Setup run result level contexts.
  --
  l_rr_ctx.tax_unit_id       := l_rr_info.tax_unit_id;
  l_rr_ctx.jurisdiction_code := l_rr_info.jurisdiction_code;
  l_rr_ctx.source_id     := find_context('SOURCE_ID', p_run_result_id);
  l_rr_ctx.source_text   := find_context('SOURCE_TEXT', p_run_result_id);
  l_rr_ctx.source_number := find_context('SOURCE_NUMBER', p_run_result_id);
  l_rr_ctx.source_text2  := find_context('SOURCE_TEXT2', p_run_result_id);
  l_rr_ctx.time_def_id   := l_rr_info.time_def_id;
  l_rr_ctx.local_unit_id := l_rr_info.local_unit_id;
  l_rr_ctx.source_number2 := find_context('SOURCE_NUMBER2', p_run_result_id);
  l_rr_ctx.organization_id := find_context('ORGANIZATION_ID', p_run_result_id);
  l_rr_ctx.balance_date  := l_rr_info.balance_date;

  --
  -- Process defined balances to save.
  --
  for l_rec in csr_defbal(p_run_result_id
                         ,l_rr_info.element_type_id
                         ,l_rr_info.effective_date
                         ,l_rr_info.business_group_id
                         ,l_rr_info.legislation_code
                         )
  loop

    if g_debug then
      hr_utility.set_location(l_proc, 25);
    end if;

    -- copy the run result contexts
    l_context := l_rr_ctx;

    --
    -- Check the contexts and truncate unnecessary context values.
    --
    check_defbal_context
      (p_defined_balance_id  => l_rec.defined_balance_id
      ,p_context             => l_context
      ,p_defbal_rec          => l_defbal_rec
      ,p_valid_contexts      => l_valid_contexts
      );

    --
    -- Setup defined balance context record for create_run_balance().
    --
    l_defbal_ctx.tu_needed  := l_defbal_rec.tu_needed;
    l_defbal_ctx.jc_needed  := l_defbal_rec.jc_needed;
    l_defbal_ctx.si_needed  := l_defbal_rec.si_needed;
    l_defbal_ctx.st_needed  := l_defbal_rec.st_needed;
    l_defbal_ctx.st2_needed := l_defbal_rec.st2_needed;
    l_defbal_ctx.sn_needed  := l_defbal_rec.sn_needed;
    l_defbal_ctx.td_needed  := l_defbal_rec.td_needed;
    l_defbal_ctx.bd_needed  := l_defbal_rec.bd_needed;
    l_defbal_ctx.lu_needed  := l_defbal_rec.lu_needed;
    l_defbal_ctx.sn2_needed := l_defbal_rec.sn2_needed;
    l_defbal_ctx.org_needed := l_defbal_rec.org_needed;

    l_defbal_ctx.tax_unit_id       := l_context.tax_unit_id;
    l_defbal_ctx.jurisdiction_code := l_context.jurisdiction_code;
    l_defbal_ctx.source_id         := l_context.source_id;
    l_defbal_ctx.source_text       := l_context.source_text;
    l_defbal_ctx.source_text2      := l_context.source_text2;
    l_defbal_ctx.source_number     := l_context.source_number;
    l_defbal_ctx.time_def_id       := l_context.time_def_id;
    l_defbal_ctx.balance_date      := l_context.balance_date;
    l_defbal_ctx.local_unit_id     := l_context.local_unit_id;
    l_defbal_ctx.source_number2    := l_context.source_number2;
    l_defbal_ctx.organization_id   := l_context.organization_id;

    --
    -- Process only when necessary contexts are set.
    --
    if l_valid_contexts then

      if g_debug then
        hr_utility.set_location(l_proc, 30);
        hr_utility.trace(' Defined Balance ID: '
                         || l_rec.defined_balance_id);
      end if;
      --
      -- Delete run balance records that may conflict with new one.
      --
      delete from pay_run_balances
      where
          defined_balance_id = l_rec.defined_balance_id
      and assignment_action_id = l_rr_info.assignment_action_id
      and payroll_action_id is null
      and (   (l_defbal_ctx.tax_unit_id is null)
           or (tax_unit_id = l_defbal_ctx.tax_unit_id))
      and (   (l_defbal_ctx.jurisdiction_code is null)
           or (substr(jurisdiction_code, 1, l_defbal_rec.jurisdiction_lvl))
                = substr(l_defbal_ctx.jurisdiction_code
                        ,1, l_defbal_rec.jurisdiction_lvl))
      and (   (l_defbal_ctx.source_id is null)
           or (source_id = l_defbal_ctx.source_id))
      and (   (l_defbal_ctx.source_text is null)
           or (source_text = l_defbal_ctx.source_text))
      and (   (l_defbal_ctx.source_text2 is null)
           or (source_text2 = l_defbal_ctx.source_text2))
      and (   (l_defbal_ctx.source_number is null)
           or (source_number = l_defbal_ctx.source_number))
      and (   (l_defbal_ctx.time_def_id is null)
           or (time_definition_id = l_defbal_ctx.time_def_id))
      and (   (l_defbal_ctx.local_unit_id is null)
           or (local_unit_id = l_defbal_ctx.local_unit_id))
      and (   (l_defbal_ctx.source_number2 is null)
           or (source_number2 = l_defbal_ctx.source_number2))
      and (   (l_defbal_ctx.organization_id is null)
           or (organization_id = l_defbal_ctx.organization_id))
      and (   (l_defbal_ctx.balance_date is null)
           or (balance_date = l_defbal_ctx.balance_date))
      ;
      --
      create_run_balance
        (p_def_bal_id          => l_rec.defined_balance_id
        ,p_mode                => 'ASG'
        ,p_asg_act             => l_rr_info.assignment_action_id
        ,p_pactid              => null
        ,p_effective_date      => l_rr_info.effective_date
        ,p_contexts            => l_defbal_ctx
        ,p_defined_balance_lst => l_defbal_list
        );

    end if;

  end loop;
  --
  if g_debug then
    hr_utility.set_location('Leaving: '||l_proc, 50);
  end if;
end create_rr_asg_balances;
--
--------------------------------------------------------------------------
-- procedure create_set_asg_balance
--------------------------------------------------------------------------
procedure create_set_asg_balance(p_defined_balance_lst  in out nocopy t_balance_value_tab,
                                 p_asgact_id            in            number,
                                 p_load_type            in            varchar2 default 'NORMAL')
is
--
cursor get_contexts(asgact    in number,
                    p_si_needed  in varchar2,
                    p_st_needed  in varchar2,
                    p_sn_needed  in varchar2,
                    p_st2_needed in varchar2,
                    p_sn2_needed in varchar2,
                    p_org_needed in varchar2) is
select /*+ ORDERED USE_NL(prr) INDEX(prr pay_run_results_n50)*/
       distinct
       paa.tax_unit_id                                         tax_unit_id
,      prr.jurisdiction_code                                   jurisdiction_code
,      decode(p_si_needed,
              'Y', find_context('SOURCE_ID', prr.run_result_id),
              null)                                            source_id
,      decode(p_st_needed,
              'Y', find_context('SOURCE_TEXT', prr.run_result_id),
              null)                                            source_text
,      decode(p_sn_needed,
              'Y', find_context('SOURCE_NUMBER', prr.run_result_id),
              null)                                            source_number
,      decode(p_st2_needed,
              'Y', find_context('SOURCE_TEXT2', prr.run_result_id),
              null)                                            source_text2
,      decode(p_sn2_needed,
              'Y', find_context('SOURCE_NUMBER2', prr.run_result_id),
              null)                                            source_number2
,      decode(p_org_needed,
              'Y', find_context('ORGANIZATION_ID', prr.run_result_id),
              null)                                            organization_id
,      prr.local_unit_id
,      prr.time_definition_id
,      nvl(prr.end_date, ptp.end_date)                         balance_date
  from pay_assignment_actions paa,
       pay_payroll_actions    ppa,
       per_time_periods       ptp,
       pay_run_results        prr
 where paa.assignment_action_id = asgact
   and paa.assignment_action_id = prr.assignment_action_id
   and ppa.payroll_action_id = paa.payroll_action_id
   and ppa.payroll_id = ptp.payroll_id
   and ppa.date_earned between ptp.start_date
                           and ptp.end_date
  order by 1, 2, 3, 4;
--
cursor get_aa (asgact    in number) is
select paa.assignment_action_id,
       ppa.effective_date,
       paa.assignment_id,
       paa.action_sequence
  from pay_assignment_actions paa,
       pay_payroll_actions    ppa
 where ppa.payroll_action_id = paa.payroll_action_id
   and paa.assignment_action_id = asgact;
--
cursor get_bg (aaid number) is
select pbg.business_group_id, pbg.legislation_code
  from pay_payroll_actions ppa,
       pay_assignment_actions paa,
       per_business_groups_perf pbg
 where ppa.payroll_action_id = paa.payroll_action_id
   and paa.assignment_action_id = aaid
   and pbg.business_group_id = ppa.business_group_id;
--
  l_si_needed_chr varchar2(10);
  l_st_needed_chr varchar2(10);
  l_sn_needed_chr varchar2(10);
  l_st2_needed_chr varchar2(10);
  l_sn2_needed_chr varchar2(10);
  l_org_needed_chr varchar2(10);
  l_context_lst   t_context_tab;
  l_cnt           number;
  l_output_list   t_detailed_bal_out_tab;
  l_inp_val_name  pay_input_values_f.name%type;
  l_found         boolean;
--
begin
--
   if g_debug then
      hr_utility.set_location('Entering: pay_balance_pkg.create_set_asg_balance', 5);
   end if;
--
   -- Check whether the SOURCE_ID, SOURCE_TEXT contexts are used.
   l_si_needed_chr := 'N';
   l_st_needed_chr := 'N';
   l_sn_needed_chr := 'N';
   l_st2_needed_chr := 'N';
   l_sn2_needed_chr := 'N';
   l_org_needed_chr := 'N';
   for bgrec in get_bg(p_asgact_id) loop
--
     pay_core_utils.get_leg_context_iv_name('SOURCE_ID',
                                            bgrec.legislation_code,
                                            l_inp_val_name,
                                            l_found
                                           );
    if (l_found = TRUE) then
      l_si_needed_chr := 'Y';
    end if;
--
     pay_core_utils.get_leg_context_iv_name('SOURCE_TEXT',
                                            bgrec.legislation_code,
                                            l_inp_val_name,
                                            l_found
                                           );
    if (l_found = TRUE) then
      l_st_needed_chr := 'Y';
    end if;
--
     pay_core_utils.get_leg_context_iv_name('SOURCE_NUMBER',
                                            bgrec.legislation_code,
                                            l_inp_val_name,
                                            l_found
                                           );
    if (l_found = TRUE) then
      l_sn_needed_chr := 'Y';
    end if;
--
     pay_core_utils.get_leg_context_iv_name('SOURCE_TEXT2',
                                            bgrec.legislation_code,
                                            l_inp_val_name,
                                            l_found
                                           );
    if (l_found = TRUE) then
      l_st2_needed_chr := 'Y';
    end if;
--
     pay_core_utils.get_leg_context_iv_name('SOURCE_NUMBER2',
                                            bgrec.legislation_code,
                                            l_inp_val_name,
                                            l_found
                                           );
    if (l_found = TRUE) then
      l_sn2_needed_chr := 'Y';
    end if;
--
     pay_core_utils.get_leg_context_iv_name('ORGANIZATION_ID',
                                            bgrec.legislation_code,
                                            l_inp_val_name,
                                            l_found
                                           );
    if (l_found = TRUE) then
      l_org_needed_chr := 'Y';
    end if;
--
   end loop;
--
-- Validate/Delete the pay_run_balances for this mode.
--
   for cnt in 1..p_defined_balance_lst.count loop
--
     if (p_load_type = 'FORCE') then
       if g_debug then
          hr_utility.set_location('pay_balance_pkg.create_set_asg_balance', 20);
       end if;
       delete from pay_run_balances
        where defined_balance_id = p_defined_balance_lst(cnt).defined_balance_id
          and assignment_action_id = p_asgact_id;
     elsif (p_load_type = 'TRUSTED') then
       null;
     else
       if g_debug then
          hr_utility.set_location('pay_balance_pkg.create_set_asg_balance', 25);
       end if;
        declare
           l_dummy number;
        begin
--
           select 1
             into l_dummy
             from dual
            where exists (select ''
                            from pay_run_balances
                           where defined_balance_id = p_defined_balance_lst(cnt).defined_balance_id
                             and assignment_action_id = p_asgact_id
                             and balance_value <> 0);
--
           /* Error, there should be no rows in this mode */
           hr_utility.set_message(801,'HR_34723_NO_ROWS_NORMAL_MODE');
           hr_utility.raise_error;
--
        exception
           when no_data_found then
               null;
        end;
     end if;
   end loop;
--
-- Generate the context list
--
   l_cnt := 1;
   if g_debug then
      hr_utility.set_location('pay_balance_pkg.create_set_asg_balance', 27);
   end if;
   for cxt in get_contexts(p_asgact_id,
                           l_si_needed_chr,
                           l_st_needed_chr,
                           l_sn_needed_chr,
                           l_st2_needed_chr,
                           l_sn2_needed_chr,
                           l_org_needed_chr) loop
      if g_debug then
         hr_utility.set_location('pay_balance_pkg.create_set_asg_balance', 28);
      end if;
      l_context_lst(l_cnt).tax_unit_id := cxt.tax_unit_id;
      l_context_lst(l_cnt).jurisdiction_code := cxt.jurisdiction_code;
      l_context_lst(l_cnt).source_id := cxt.source_id;
      l_context_lst(l_cnt).source_text := cxt.source_text;
      l_context_lst(l_cnt).source_number := cxt.source_number;
      l_context_lst(l_cnt).source_text2 := cxt.source_text2;
      l_context_lst(l_cnt).time_def_id := cxt.time_definition_id;
      l_context_lst(l_cnt).balance_date := cxt.balance_date;
      l_context_lst(l_cnt).local_unit_id := cxt.local_unit_id;
      l_context_lst(l_cnt).source_number2 := cxt.source_number2;
      l_context_lst(l_cnt).organization_id := cxt.organization_id;
--
      l_cnt := l_cnt + 1;
   end loop;
--
-- Go Get the balance values
--
   if g_debug then
      hr_utility.set_location('pay_balance_pkg.create_set_asg_balance', 30);
   end if;
   for aarec in get_aa (p_asgact_id) loop
      pay_balance_pkg.get_value (p_asgact_id,
                                 p_defined_balance_lst,
                                 l_context_lst,
                                 TRUE,
                                 FALSE,
                                 l_output_list);
--
--   Insert the results in the run_balance table.
--
     if g_debug then
        hr_utility.set_location('pay_balance_pkg.create_set_asg_balance', 35);
     end if;

      ins_run_balance_bulk (p_output_list     => l_output_list,
                            p_asgact_id       => p_asgact_id,
                            p_pact_id         => null,
                            p_assignment_id   => aarec.assignment_id,
                            p_action_sequence => aarec.action_sequence,
                            p_effective_date  => aarec.effective_date
                            );

      if g_debug then
         hr_utility.set_location('pay_balance_pkg.create_set_asg_balance', 40);
      end if;
/* Commented for bug 6676876, used bulk insert into pay_run_balances for performance improvement
     for cnt in 1..l_output_list.count loop
       if (l_output_list(cnt).balance_value <> 0) then
--
         if g_debug then
            hr_utility.set_location('pay_balance_pkg.create_set_asg_balance', 40);
         end if;
         ins_run_balance (p_defined_balance_id => l_output_list(cnt).defined_balance_id,
                          p_eff_date           => aarec.effective_date,
                          p_bal_val            => l_output_list(cnt).balance_value,
                          p_payroll_act_id     => null,
                          p_asg_act_id         => p_asgact_id,
                          p_asg_id             => aarec.assignment_id,
                          p_act_seq            => aarec.action_sequence,
                          p_tax_unit           => l_output_list(cnt).tax_unit_id,
                          p_jurisdiction       => l_output_list(cnt).jurisdiction_code,
                          p_source_id          => l_output_list(cnt).source_id,
                          p_source_text        => l_output_list(cnt).source_text,
                          p_source_number      => l_output_list(cnt).source_number,
                          p_source_text2       => l_output_list(cnt).source_text2,
                          p_time_def_id        => l_output_list(cnt).time_def_id,
                          p_balance_date       => l_output_list(cnt).balance_date,
                          p_local_unit_id      => l_output_list(cnt).local_unit_id,
                          p_source_number2     => l_output_list(cnt).source_number2,
                          p_organization_id    => l_output_list(cnt).organization_id
                         );
--
       end if;
     end loop;
*/
   end loop;
--
   if g_debug then
      hr_utility.set_location('Leaving: pay_balance_pkg.create_set_asg_balance', 50);
   end if;
end create_set_asg_balance;
--
procedure add_grpbal_to_list(p_def_bal_id  in     number,
                             p_load_type   in     varchar2,
                             p_pactid      in     number,
                             p_output_list in out nocopy t_detailed_bal_out_tab,
                             p_next_free   in out nocopy number
                            )
is
--
cursor get_contexts(p_pact_id    in number,
                    p_jur_lvl    in number,
                    p_tu_needed  in varchar2,
                    p_jc_needed  in varchar2,
                    p_si_needed  in varchar2,
                    p_st_needed  in varchar2,
                    p_sn_needed  in varchar2,
                    p_st2_needed in varchar2,
                    p_td_needed  in varchar2,
                    p_bd_needed  in varchar2,
                    p_lu_needed  in varchar2,
                    p_sn2_needed in varchar2,
                    p_org_needed in varchar2) is
select /*+ ORDERED USE_NL (prr) INDEX(prr pay_run_results_n50)*/
       distinct
       decode(p_tu_needed,
              'Y', paa.tax_unit_id,
              null)                                           tax_unit_id
,      decode(p_jc_needed,
              'Y', substr(prr.jurisdiction_code, 1, p_jur_lvl),
              null)                                           jurisdiction_code
,      decode(p_si_needed,
              'Y', find_context('SOURCE_ID', prr.run_result_id),
              null)                                            source_id
,      decode(p_st_needed,
              'Y', find_context('SOURCE_TEXT', prr.run_result_id),
              null)                                            source_text
,      decode(p_sn_needed,
              'Y', find_context('SOURCE_NUMBER', prr.run_result_id),
              null)                                            source_number
,      decode(p_st2_needed,
              'Y', find_context('SOURCE_TEXT2', prr.run_result_id),
              null)                                            source_text2
,      decode(p_td_needed,
              'Y', prr.time_definition_id,
              null)                                            time_definition_id
,      decode(p_bd_needed,
              'Y', nvl(prr.end_date, ptp.end_date),
              null)                                            balance_date
,      decode(p_lu_needed,
              'Y', prr.local_unit_id,
              null)                                            local_unit_id
,      decode(p_sn2_needed,
              'Y', find_context('SOURCE_NUMBER2', prr.run_result_id),
              null)                                            source_number2
,      decode(p_org_needed,
              'Y', find_context('ORGANIZATION_ID', prr.run_result_id),
              null)                                            organization_id
  from pay_assignment_actions paa,
       pay_payroll_actions    ppa,
       per_time_periods       ptp,
       pay_run_results        prr
 where paa.payroll_action_id = p_pact_id
   and paa.assignment_action_id = prr.assignment_action_id
   and ppa.payroll_action_id = paa.payroll_action_id
   and ppa.payroll_id = ptp.payroll_id
   and ppa.date_earned between ptp.start_date
                           and ptp.end_date
  order by 1, 2, 3, 4;

--
l_defbal_rec           t_def_bal_rec;
l_tu_needed_chr        pay_legislation_rules.rule_mode%type;
l_jc_needed_chr        pay_legislation_rules.rule_mode%type;
l_si_needed_chr        pay_legislation_rules.rule_mode%type;
l_st_needed_chr        pay_legislation_rules.rule_mode%type;
l_sn_needed_chr        pay_legislation_rules.rule_mode%type;
l_st2_needed_chr       pay_legislation_rules.rule_mode%type;
l_td_needed_chr        pay_legislation_rules.rule_mode%type;
l_bd_needed_chr        pay_legislation_rules.rule_mode%type;
l_lu_needed_chr        pay_legislation_rules.rule_mode%type;
l_sn2_needed_chr       pay_legislation_rules.rule_mode%type;
l_org_needed_chr       pay_legislation_rules.rule_mode%type;
--
begin
--
if g_debug then
  hr_utility.set_location('Entering pay_balance_pkg.add_grpbal_to_list',10);
  hr_utility.trace('p_load_type: '||p_load_type);
end if;
--
      l_jc_needed_chr := 'N';
      l_si_needed_chr := 'N';
      l_st_needed_chr := 'N';
      l_sn_needed_chr := 'N';
      l_tu_needed_chr := 'N';
      l_st2_needed_chr := 'N';
      l_td_needed_chr := 'N';
      l_bd_needed_chr := 'N';
      l_lu_needed_chr := 'N';
      l_sn2_needed_chr := 'N';
      l_org_needed_chr := 'N';
      load_defbal_cache(p_def_bal_id,
                          l_defbal_rec);
--
      if (l_defbal_rec.jc_needed = TRUE) then
         l_jc_needed_chr := 'Y';
      end if;
      if (l_defbal_rec.si_needed = TRUE) then
         l_si_needed_chr := 'Y';
      end if;
      if (l_defbal_rec.st_needed = TRUE) then
         l_st_needed_chr := 'Y';
      end if;
      if (l_defbal_rec.sn_needed = TRUE) then
         l_sn_needed_chr := 'Y';
      end if;
      if (l_defbal_rec.tu_needed = TRUE) then
         l_tu_needed_chr := 'Y';
      end if;
      if (l_defbal_rec.st2_needed = TRUE) then
         l_st2_needed_chr := 'Y';
      end if;
      if (l_defbal_rec.td_needed = TRUE) then
         l_td_needed_chr := 'Y';
      end if;
      if (l_defbal_rec.bd_needed = TRUE) then
         l_bd_needed_chr := 'Y';
      end if;
      if (l_defbal_rec.lu_needed = TRUE) then
         l_lu_needed_chr := 'Y';
      end if;
      if (l_defbal_rec.sn2_needed = TRUE) then
         l_sn2_needed_chr := 'Y';
      end if;
      if (l_defbal_rec.org_needed = TRUE) then
         l_org_needed_chr := 'Y';
      end if;
--
     if (p_load_type = 'FORCE') then
       if g_debug then
          hr_utility.set_location('pay_balance_pkg.add_grpbal_to_list', 20);
       end if;
       delete from pay_run_balances
        where defined_balance_id = p_def_bal_id
          and payroll_action_id = p_pactid;
     elsif (p_load_type = 'TRUSTED') then
       null;
     else
       if g_debug then
          hr_utility.set_location('pay_balance_pkg.add_grpbal_to_list', 25);
       end if;
        declare
           l_dummy number;
        begin
           select 1
             into l_dummy
             from dual
            where exists (select ''
                            from pay_run_balances
                           where defined_balance_id = p_def_bal_id
                             and payroll_action_id = p_pactid
                             and balance_value <> 0);
--
           -- Error, there should be no rows in this mode
           hr_utility.set_message(801,'HR_34723_NO_ROWS_NORMAL_MODE');
           hr_utility.raise_error;
--
        exception
           when no_data_found then
               null;
        end;
     end if;
--
      for ctxrec in get_contexts(p_pactid,
                                 l_defbal_rec.jurisdiction_lvl,
                                 l_tu_needed_chr,
                                 l_jc_needed_chr,
                                 l_si_needed_chr,
                                 l_st_needed_chr,
                                 l_sn_needed_chr,
                                 l_st2_needed_chr,
                                 l_td_needed_chr,
                                 l_bd_needed_chr,
                                 l_lu_needed_chr,
                                 l_sn2_needed_chr,
                                 l_org_needed_chr) loop
--
--       Only add to the list if all the context values are known
--
         if (    ((    l_defbal_rec.st2_needed = TRUE
                   and ctxrec.source_text2 is not null)
                  or l_defbal_rec.st2_needed = FALSE)
             and ((    l_defbal_rec.jc_needed = TRUE
                   and ctxrec.jurisdiction_code is not null)
                  or l_defbal_rec.jc_needed = FALSE)
             and ((    l_defbal_rec.tu_needed = TRUE
                   and ctxrec.tax_unit_id is not null)
                  or l_defbal_rec.tu_needed = FALSE)
             and ((    l_defbal_rec.si_needed = TRUE
                   and ctxrec.source_id is not null)
                  or l_defbal_rec.si_needed = FALSE)
             and ((    l_defbal_rec.st_needed = TRUE
                   and ctxrec.source_text is not null)
                  or l_defbal_rec.st_needed = FALSE)
             and ((    l_defbal_rec.sn_needed = TRUE
                   and ctxrec.source_number is not null)
                  or l_defbal_rec.sn_needed = FALSE)
             and ((    l_defbal_rec.td_needed = TRUE
                   and ctxrec.time_definition_id is not null)
                  or l_defbal_rec.td_needed = FALSE)
             and ((    l_defbal_rec.bd_needed = TRUE
                   and ctxrec.balance_date is not null)
                  or l_defbal_rec.bd_needed = FALSE)
             and ((    l_defbal_rec.lu_needed = TRUE
                   and ctxrec.local_unit_id is not null)
                  or l_defbal_rec.lu_needed = FALSE)
             and ((    l_defbal_rec.sn2_needed = TRUE
                   and ctxrec.source_number2 is not null)
                  or l_defbal_rec.sn2_needed = FALSE)
             and ((    l_defbal_rec.org_needed = TRUE
                   and ctxrec.organization_id is not null)
                  or l_defbal_rec.org_needed = FALSE)
            ) then
--
           p_output_list(p_next_free).defined_balance_id:= p_def_bal_id;
           p_output_list(p_next_free).tax_unit_id := ctxrec.tax_unit_id;
           p_output_list(p_next_free).jurisdiction_code := ctxrec.jurisdiction_code;
           p_output_list(p_next_free).source_id := ctxrec.source_id;
           p_output_list(p_next_free).source_text := ctxrec.source_text;
           p_output_list(p_next_free).source_number := ctxrec.source_number;
           p_output_list(p_next_free).source_text2 := ctxrec.source_text2;
           p_output_list(p_next_free).time_def_id := ctxrec.time_definition_id;
           p_output_list(p_next_free).balance_date := ctxrec.balance_date;
           p_output_list(p_next_free).local_unit_id := ctxrec.local_unit_id;
           p_output_list(p_next_free).source_number2 := ctxrec.source_number2;
           p_output_list(p_next_free).organization_id := ctxrec.organization_id;
           p_output_list(p_next_free).balance_value := 0;
           p_output_list(p_next_free).balance_found := FALSE;
           p_output_list(p_next_free).jurisdiction_lvl := l_defbal_rec.jurisdiction_lvl;
           p_next_free := p_next_free + 1;
         end if;
--
      end loop;
--
if g_debug then
  hr_utility.set_location('Leaving: pay_balance_pkg.add_grpbal_to_list', 40);
end if;
--
end add_grpbal_to_list;
-----------------------------------------------------------------------------
-- procedure create_all_grp_balances_full
-----------------------------------------------------------------------------
procedure create_all_grp_balances_full(p_pact_id  in number,
                                  p_bal_list   in varchar2 default 'ALL',
                                  p_load_type  in varchar2 default 'NORMAL',
                                  p_def_bal    in number   default null
                                 ,p_eff_date   in date     default null
                                 ,p_delta      in varchar2 default null
                                 )
is
--
cursor crs_asgact (p_pact_id number,
                   p_eff_date   date,
                   p_bus_grp_id number,
                   p_leg_code   varchar2,
                   p_bal_list   varchar2,
                   p_def_bal    number)
is
select  /*+ ORDERED USE_NL(piv pbf pbt pdb pbd prrv)
            INDEX (prrv PAY_RUN_RESULT_VALUES_PK)*/
       distinct  pdb.defined_balance_id,
       pbt.jurisdiction_level,
       pbt.balance_type_id,
       pbd.balance_dimension_id
  from
       pay_assignment_actions paa,
       pay_run_results        prr,
       pay_input_values_f     piv,
       pay_balance_feeds_f    pbf,
       pay_balance_types      pbt,
       pay_defined_balances   pdb,
       pay_balance_dimensions pbd,
       pay_run_result_values  prrv
 where pbd.dimension_level = 'GRP'
   and pdb.save_run_balance|| decode (pbt.balance_type_id, 0, '', '')= 'Y'
   and pdb.balance_dimension_id = pbd.balance_dimension_id
   and pdb.balance_type_id = pbt.balance_type_id
   and ((pdb.business_group_id = p_bus_grp_id
          and pdb.legislation_code is null)
        or
         (pdb.legislation_code = p_leg_code
          and pdb.business_group_id is null)
        or
         (pdb.legislation_code is null
          and pdb.business_group_id is null)
       )
   and (    p_bal_list <> 'INVALID'
         or (    p_bal_list = 'INVALID'
             and exists (select ''
                           from pay_balance_validation pbv
                          where pbv.defined_balance_id = pdb.defined_balance_id
                            and pbv.business_group_id = p_bus_grp_id
                            and pbv.run_balance_status = 'P')
            )
       )
   and (   p_def_bal is null
        or p_def_bal = pdb.defined_balance_id
       )
   and paa.payroll_action_id = p_pact_id
   and prr.assignment_action_id = paa.assignment_action_id
   and piv.element_type_id = prr.element_type_id
   and p_eff_date between piv.effective_start_date
                      and piv.effective_end_date
   and pbf.input_value_id = piv.input_value_id
   and p_eff_date between pbf.effective_start_date
                      and pbf.effective_end_date
   and pbt.balance_type_id = pbf.balance_type_id
   and prrv.run_result_id = prr.run_result_id
   and prrv.input_value_id = piv.input_value_id
   and prrv.result_value is not null;

--   and exists (select /*+ ORDERED */ ''
--                 from pay_run_results prr,
--                      pay_run_result_values prrv,
--                      pay_balance_feeds_f pbf
--                where prr.assignment_action_id = p_asg_act_id
--                  and prr.run_result_id = prrv.run_result_id
--                  and prrv.input_value_id = pbf.input_value_id
--                  and pbf.balance_type_id = pbt.balance_type_id);
--
-- Bug 6676876 - split the cursor 'crs_balatt' based on the value of defined_balance_id
cursor crs_balatt_1 (p_pact_id number
                    ,p_bal_list   varchar2
                    ,p_def_bal_id number
                     )
is
select /*+ ORDERED */
       pdb.defined_balance_id,
       pdb.balance_type_id,
       pdb.balance_dimension_id
  from
       pay_bal_attribute_definitions pbad,
       pay_balance_attributes        pba,
       pay_defined_balances          pdb,
       pay_balance_dimensions        pbd
 where
       pbad.attribute_name = p_bal_list
   and pbad.attribute_id   = pba.attribute_id
   and pba.defined_balance_id = pdb.defined_balance_id
   and pdb.balance_dimension_id = pbd.balance_dimension_id
   and pbd.dimension_level = 'GRP'
   and p_def_bal_id = pba.defined_balance_id
   and exists (select /*+ ORDERED */ ''
                 from pay_assignment_actions paa,
                      pay_run_results prr,
                      pay_run_result_values prrv,
                      pay_balance_feeds_f pbf
                where paa.payroll_action_id = p_pact_id
                  and prr.assignment_action_id = paa.assignment_action_id
                  and prr.run_result_id = prrv.run_result_id
                  and prrv.input_value_id = pbf.input_value_id
                  and pdb.balance_type_id = pbf.balance_type_id
              );
cursor crs_balatt_2 (p_pact_id number
                    ,p_bal_list   varchar2
                     )
is
select pdb.defined_balance_id,
       pdb.balance_type_id,
       pdb.balance_dimension_id
  from
       pay_bal_attribute_definitions pbad,
       pay_balance_attributes        pba,
       pay_defined_balances          pdb,
       pay_balance_dimensions        pbd
 where
       pbad.attribute_name = p_bal_list
   and pbad.attribute_id   = pba.attribute_id
   and pba.defined_balance_id = pdb.defined_balance_id
   and pdb.balance_dimension_id = pbd.balance_dimension_id
   and pbd.dimension_level = 'GRP'
   and pdb.balance_type_id in
                (select /*+ USE_NL(paa,prr,prrv,pbf) ORDERED */
                      distinct pbf.balance_type_id
                 from pay_assignment_actions paa,
                      pay_run_results prr,
                      pay_run_result_values prrv,
                      pay_balance_feeds_f pbf
                where paa.payroll_action_id = p_pact_id
                  and prr.assignment_action_id = paa.assignment_action_id
                  and prr.run_result_id = prrv.run_result_id
                  and prrv.input_value_id = pbf.input_value_id
              );
--
cursor crs_delta_balatt(p_pact_id    number
                       ,p_bal_list   varchar2
                       ,p_bus_grp_id number
                       ,p_eff_date   date
                   )
is
select /*+ ORDERED */
       pdb.defined_balance_id,
       pdb.balance_type_id,
       pdb.balance_dimension_id
  from
       pay_bal_attribute_definitions pbad,
       pay_balance_attributes        pba,
       pay_defined_balances          pdb,
       pay_balance_dimensions        pbd
 where
       pbad.attribute_name = p_bal_list
   and pbad.attribute_id   = pba.attribute_id
   and pba.defined_balance_id = pdb.defined_balance_id
   and pdb.balance_dimension_id = pbd.balance_dimension_id
   and pbd.dimension_level = 'GRP'
   and exists (select ''
               from pay_balance_validation pbv
               where pdb.defined_balance_id + decode(PDB.LEGISLATION_SUBGROUP, ' ', 0, 0) = pbv.defined_balance_id
               and   pbv.run_balance_status = 'V'
               and   pbv.business_group_id = p_bus_grp_id
               and   pbv.balance_load_date is not null
               and   pbv.balance_load_date > p_eff_date)
   and pdb.balance_type_id in
                (select /*+ USE_NL(paa,prr,prrv,pbf) ORDERED */
                      distinct pbf.balance_type_id
                 from pay_assignment_actions paa,
                      pay_run_results prr,
                      pay_run_result_values prrv,
                      pay_balance_feeds_f pbf
                where paa.payroll_action_id = p_pact_id
                  and prr.assignment_action_id = paa.assignment_action_id
                  and prr.run_result_id = prrv.run_result_id
                  and prrv.input_value_id = pbf.input_value_id
                );


cursor get_aa (p_pact_id    in number) is
select paa.assignment_action_id,
       ppa.effective_date,
       paa.assignment_id,
       paa.action_sequence
  from pay_assignment_actions paa,
       pay_payroll_actions    ppa
 where ppa.payroll_action_id = paa.payroll_action_id
   and ppa.payroll_action_id = p_pact_id
   and rownum = 1;
--
--
cursor get_contexts_2(p_pact_id    in number,
                    p_si_needed  in varchar2,
                    p_st_needed  in varchar2,
                    p_sn_needed  in varchar2,
                    p_st2_needed in varchar2,
                    p_sn2_needed in varchar2,
                    p_org_needed in varchar2) is
select /*+ ORDERED USE_NL (prr) INDEX(prr pay_run_results_n50)*/
       distinct
       paa.tax_unit_id                                         tax_unit_id
,      prr.jurisdiction_code                                   jurisdiction_code
,      decode(p_si_needed,
              'Y', find_context('SOURCE_ID', prr.run_result_id),
              null)                                            source_id
,      decode(p_st_needed,
              'Y', find_context('SOURCE_TEXT', prr.run_result_id),
              null)                                            source_text
,      decode(p_sn_needed,
              'Y', find_context('SOURCE_NUMBER', prr.run_result_id),
              null)                                            source_number
,      decode(p_st2_needed,
              'Y', find_context('SOURCE_TEXT2', prr.run_result_id),
              null)                                            source_text2
,      decode(p_sn2_needed,
              'Y', find_context('SOURCE_NUMBER2', prr.run_result_id),
              null)                                            source_number2
,      decode(p_org_needed,
              'Y', find_context('ORGANIZATION_ID', prr.run_result_id),
              null)                                            organization_id
,      prr.time_definition_id
,      nvl(prr.end_date, ptp.end_date)                         balance_date
,      prr.local_unit_id                                       local_unit_id
  from pay_assignment_actions paa,
       pay_payroll_actions    ppa,
       per_time_periods       ptp,
       pay_run_results        prr
 where paa.payroll_action_id = p_pact_id
   and paa.assignment_action_id = prr.assignment_action_id
   and ppa.payroll_action_id = paa.payroll_action_id
   and ppa.payroll_id = ptp.payroll_id
   and ppa.date_earned between ptp.start_date
                           and ptp.end_date
  order by 1, 2, 3, 4;
--
cursor get_bg (p_pact_id number) is
select pbg.business_group_id, pbg.legislation_code
  from pay_payroll_actions ppa,
       per_business_groups_perf pbg
 where ppa.payroll_action_id = p_pact_id
   and pbg.business_group_id = ppa.business_group_id;
--
l_defbal_rec           t_def_bal_rec;
l_tu_needed_chr        pay_legislation_rules.rule_mode%type;
l_jc_needed_chr        pay_legislation_rules.rule_mode%type;
l_si_needed_chr        pay_legislation_rules.rule_mode%type;
l_st_needed_chr        pay_legislation_rules.rule_mode%type;
l_sn_needed_chr        pay_legislation_rules.rule_mode%type;
l_st2_needed_chr       pay_legislation_rules.rule_mode%type;
l_td_needed_chr        pay_legislation_rules.rule_mode%type;
l_bd_needed_chr        pay_legislation_rules.rule_mode%type;
l_lu_needed_chr        pay_legislation_rules.rule_mode%type;
l_sn2_needed_chr       pay_legislation_rules.rule_mode%type;
l_org_needed_chr       pay_legislation_rules.rule_mode%type;
  l_context_lst   t_context_tab;
  l_cnt           number;
  l_output_list   t_detailed_bal_out_tab;
  l_inp_val_name  pay_input_values_f.name%type;
  l_found         boolean;
  l_next_free number;
  l_bg_id     per_business_groups.business_group_id%type;
  l_leg_code  per_business_groups.legislation_code%type;
  l_eff_date  date;
begin
--
if g_debug then
  hr_utility.set_location(
            'Entering:pay_balance_pkg.create_all_gre_balances_full',10);
end if;
   --
   select pbg.business_group_id,
          pbg.legislation_code,
          ppa.effective_date
     into l_bg_id,
          l_leg_code,
          l_eff_date
     from per_business_groups_perf pbg,
          pay_payroll_actions ppa
    where ppa.payroll_action_id = p_pact_id
      and ppa.business_group_id = pbg.business_group_id;
--
   l_next_free := 1;
--
   if (    p_bal_list <> 'ALL'
       and p_bal_list <> 'INVALID'
       and p_bal_list <> 'SINGLE') then
--
       /* OK we must be balance attribute */
       -- REC 13/10/06 Balance attribute mode can now be used for SINGLE
       -- but SINGLE calls this procedure in FORCE mode. So, if p_def_bal
       -- is not null and p_bal_list is a GEN_BAL<pact_id) value, then FORCE
       -- can be allowed. The run balances will be deleted in procedure
       -- add_grpbal_to_list.
       --
     if (p_delta = 'N'
         or p_delta is null) then -- if NOT in DELTA mode
     --
       if (p_load_type = 'TRUSTED') then
       --
         if g_debug then
           hr_utility.set_location(
                     'pay_balance_pkg.create_all_grp_balances_full', 20);
         end if;
         --
         -- Bug 6676876 - split the cursor 'crs_balatt' based on the value of defined_balance_id
         if p_def_bal is NULL then
           for dbarec in crs_balatt_2(p_pact_id
                                     ,p_bal_list
                                     ) loop
            add_grpbal_to_list(p_def_bal_id  => dbarec.defined_balance_id,
                               p_load_type   => p_load_type,
                               p_pactid      => p_pact_id,
                               p_output_list => l_output_list,
                               p_next_free   => l_next_free
                              );
           end loop;
         else
           for dbarec in crs_balatt_1(p_pact_id
                                     ,p_bal_list
                                     ,p_def_bal
                                     ) loop
            add_grpbal_to_list(p_def_bal_id  => dbarec.defined_balance_id,
                               p_load_type   => p_load_type,
                               p_pactid      => p_pact_id,
                               p_output_list => l_output_list,
                               p_next_free   => l_next_free
                              );
           end loop;
         end if;
         --
       elsif (p_load_type = 'FORCE'
              and p_def_bal is not null) then
       --
         if g_debug then
           hr_utility.set_location(
                     'pay_balance_pkg.create_all_grp_balances_full', 30);
         end if;
         --
         for dbsarec in crs_balatt_1(p_pact_id
                                    ,p_bal_list
                                    ,p_def_bal
                                    ) loop
            add_grpbal_to_list(p_def_bal_id  => dbsarec.defined_balance_id,
                               p_load_type   => p_load_type,
                               p_pactid      => p_pact_id,
                               p_output_list => l_output_list,
                               p_next_free   => l_next_free
                              );
         end loop;
         --
      else -- p_load_type <> TRUSTED
      --
         pay_core_utils.assert_condition('create_all_grp_balances_full:1', false);
      end if;
    else -- p_delta is Y thus in Delta mode
    --
     if g_debug then
       hr_utility.set_location(
                 'pay_balance_pkg.create_all_grp_balances_full', 35);
     end if;
     --
     for dbdrec in crs_delta_balatt(p_pact_id
                                   ,p_bal_list
                                   ,l_bg_id
                                   ,l_eff_date
                                   ) loop
            add_grpbal_to_list(p_def_bal_id  => dbdrec.defined_balance_id,
                               p_load_type   => p_load_type,
                               p_pactid      => p_pact_id,
                               p_output_list => l_output_list,
                               p_next_free   => l_next_free
                              );
     end loop;
    end if;
   --
   else
     if g_debug then
       hr_utility.set_location(
                 'pay_balance_pkg.create_all_grp_balances_full', 40);
     end if;
     --
      for dbrec in crs_asgact(p_pact_id,
                              l_eff_date,
                              l_bg_id,
                              l_leg_code,
                              p_bal_list,
                              p_def_bal) loop
         add_grpbal_to_list(p_def_bal_id  => dbrec.defined_balance_id,
                            p_load_type   => p_load_type,
                            p_pactid      => p_pact_id,
                            p_output_list => l_output_list,
                            p_next_free   => l_next_free
                           );
      end loop;
   end if;
   --
   -- Bug 4318391.
   -- Ensure if any defind balances found.
   --
   if l_output_list.count = 0 then
     hr_utility.set_location('pay_balance_pkg.create_all_grp_balances_full', 50);
     --
     -- Exit this procedure.
     --
     return;
   end if;

--
--
-- Generate the context list
--
   -- Check whether the SOURCE_ID, SOURCE_TEXT contexts are used.
   l_si_needed_chr := 'N';
   l_st_needed_chr := 'N';
   l_sn_needed_chr := 'N';
   l_st2_needed_chr := 'N';
   l_sn2_needed_chr := 'N';
   l_org_needed_chr := 'N';
   for bgrec in get_bg(p_pact_id) loop
--
     pay_core_utils.get_leg_context_iv_name('SOURCE_ID',
                                            bgrec.legislation_code,
                                            l_inp_val_name,
                                            l_found
                                           );
    if (l_found = TRUE) then
      l_si_needed_chr := 'Y';
    end if;
--
     pay_core_utils.get_leg_context_iv_name('SOURCE_TEXT',
                                            bgrec.legislation_code,
                                            l_inp_val_name,
                                            l_found
                                           );
    if (l_found = TRUE) then
      l_st_needed_chr := 'Y';
    end if;
--
     pay_core_utils.get_leg_context_iv_name('SOURCE_NUMBER',
                                            bgrec.legislation_code,
                                            l_inp_val_name,
                                            l_found
                                           );
    if (l_found = TRUE) then
      l_sn_needed_chr := 'Y';
    end if;
--
     pay_core_utils.get_leg_context_iv_name('SOURCE_TEXT2',
                                            bgrec.legislation_code,
                                            l_inp_val_name,
                                            l_found
                                           );
    if (l_found = TRUE) then
      l_st2_needed_chr := 'Y';
    end if;
--
     pay_core_utils.get_leg_context_iv_name('SOURCE_NUMBER2',
                                            bgrec.legislation_code,
                                            l_inp_val_name,
                                            l_found
                                           );
    if (l_found = TRUE) then
      l_sn2_needed_chr := 'Y';
    end if;
--
     pay_core_utils.get_leg_context_iv_name('ORGANIZATION_ID',
                                            bgrec.legislation_code,
                                            l_inp_val_name,
                                            l_found
                                           );
    if (l_found = TRUE) then
      l_org_needed_chr := 'Y';
    end if;
--
   end loop;
--
   l_cnt := 1;
   if g_debug then
      hr_utility.set_location(
                'pay_balance_pkg.create_all_grp_balances_full', 60);
   end if;
   --
   for cxt in get_contexts_2(p_pact_id,
                           l_si_needed_chr,
                           l_st_needed_chr,
                           l_sn_needed_chr,
                           l_st2_needed_chr,
                           l_sn2_needed_chr,
                           l_org_needed_chr) loop
      if g_debug then
         hr_utility.set_location(
                   'pay_balance_pkg.create_all_grp_balances_full', 70);
      end if;
      --
      l_context_lst(l_cnt).tax_unit_id := cxt.tax_unit_id;
      l_context_lst(l_cnt).jurisdiction_code := cxt.jurisdiction_code;
      l_context_lst(l_cnt).source_id := cxt.source_id;
      l_context_lst(l_cnt).source_text := cxt.source_text;
      l_context_lst(l_cnt).source_number := cxt.source_number;
      l_context_lst(l_cnt).source_text2 := cxt.source_text2;
      l_context_lst(l_cnt).time_def_id := cxt.time_definition_id;
      l_context_lst(l_cnt).balance_date := cxt.balance_date;
      l_context_lst(l_cnt).local_unit_id := cxt.local_unit_id;
      l_context_lst(l_cnt).source_number2 := cxt.source_number2;
      l_context_lst(l_cnt).organization_id := cxt.organization_id;
--
      l_cnt := l_cnt + 1;
   end loop;
--
-- Go Get the balance values
--
   if g_debug then
      hr_utility.set_location(
                'pay_balance_pkg.create_all_grp_balances_full', 80);
   end if;
--
   for aarec in get_aa (p_pact_id) loop
      pay_balance_pkg.get_value_int_batch (aarec.assignment_action_id,
                                 l_context_lst,
                                 TRUE,
                                 FALSE,
                                 l_output_list);
--
--   Insert the results in the run_balance table.
--
     if g_debug then
        hr_utility.set_location(
                  'pay_balance_pkg.create_all_grp_balances_full', 85);
     end if;


      ins_run_balance_bulk (p_output_list     => l_output_list,
                            p_asgact_id       => null,
                            p_pact_id         => p_pact_id,
                            p_assignment_id   => null,
                            p_action_sequence => null,
                            p_effective_date  => aarec.effective_date
                            );
      if g_debug then
         hr_utility.set_location(
                   'pay_balance_pkg.create_all_grp_balances_full', 90);
      end if;
/* Commented for bug 6676876, used bulk insert into pay_run_balances for performance improvement
     for cnt in 1..l_output_list.count loop
       if (l_output_list(cnt).balance_value <> 0) then
--
         if g_debug then
            hr_utility.set_location(
                      'pay_balance_pkg.create_all_grp_balances_full', 90);
         end if;
         --
         ins_run_balance (p_defined_balance_id => l_output_list(cnt).defined_balance_id,
                          p_eff_date           => aarec.effective_date,
                          p_bal_val            => l_output_list(cnt).balance_value,
                          p_payroll_act_id     => p_pact_id,
                          p_asg_act_id         => null,
                          p_asg_id             => null,
                          p_act_seq            => null,
                          p_tax_unit           => l_output_list(cnt).tax_unit_id,
                          p_jurisdiction       => l_output_list(cnt).jurisdiction_code,
                          p_source_id          => l_output_list(cnt).source_id,
                          p_source_text        => l_output_list(cnt).source_text,
                          p_source_number      => l_output_list(cnt).source_number,
                          p_source_text2       => l_output_list(cnt).source_text2,
                          p_time_def_id        => l_output_list(cnt).time_def_id,
                          p_balance_date       => l_output_list(cnt).balance_date,
                          p_local_unit_id      => l_output_list(cnt).local_unit_id,
                          p_source_number2     => l_output_list(cnt).source_number2,
                          p_organization_id    => l_output_list(cnt).organization_id
                         );
--
       end if;
     end loop;
*/
   end loop;
--
   if g_debug then
      hr_utility.set_location(
                'Leaving: pay_balance_pkg.create_all_grp_balances_full', 95);
   end if;
--
end create_all_grp_balances_full;
-----------------------------------------------------------------------------
-- procedure add_asgbal_to_list
-----------------------------------------------------------------------------
procedure add_asgbal_to_list(p_def_bal_id  in     number,
                             p_load_type   in     varchar2,
                             p_asgact_id   in     number,
                             p_output_list in out nocopy t_detailed_bal_out_tab,
                             p_next_free   in out nocopy number
                            )
is
cursor get_contexts(asgact    in number,
                    p_jur_lvl    in number,
                    p_tu_needed  in varchar2,
                    p_jc_needed  in varchar2,
                    p_si_needed  in varchar2,
                    p_st_needed  in varchar2,
                    p_sn_needed  in varchar2,
                    p_st2_needed in varchar2,
                    p_td_needed  in varchar2,
                    p_bd_needed  in varchar2,
                    p_lu_needed in varchar2,
                    p_sn2_needed in varchar2,
                    p_org_needed in varchar2) is
select /*+ ORDERED USE_NL(prr) INDEX(prr pay_run_results_n50)*/
       distinct
       decode(p_tu_needed,
              'Y', paa.tax_unit_id,
              null)                                           tax_unit_id
,      decode(p_jc_needed,
              'Y', substr(prr.jurisdiction_code, 1, p_jur_lvl),
              null)                                           jurisdiction_code
,      decode(p_si_needed,
              'Y', find_context('SOURCE_ID', prr.run_result_id),
              null)                                            source_id
,      decode(p_st_needed,
              'Y', find_context('SOURCE_TEXT', prr.run_result_id),
              null)                                            source_text
,      decode(p_sn_needed,
              'Y', find_context('SOURCE_NUMBER', prr.run_result_id),
              null)                                            source_number
,      decode(p_st2_needed,
              'Y', find_context('SOURCE_TEXT2', prr.run_result_id),
              null)                                            source_text2
,      decode(p_sn2_needed,
              'Y', find_context('SOURCE_NUMBER2', prr.run_result_id),
              null)                                            source_number2
,      decode(p_org_needed,
              'Y', find_context('ORGANIZATION_ID', prr.run_result_id),
              null)                                            organization_id
,      decode(p_td_needed,
              'Y', prr.time_definition_id,
              null)                                            time_definition_id
,      decode(p_bd_needed,
              'Y', nvl(prr.end_date, ptp.end_date),
              null)                                            balance_date
,      decode(p_lu_needed,
              'Y', prr.local_unit_id,
              null)                                            local_unit_id
  from pay_assignment_actions paa,
       pay_payroll_actions    ppa,
       per_time_periods       ptp,
       pay_run_results        prr
 where paa.assignment_action_id = asgact
   and paa.assignment_action_id = prr.assignment_action_id
   and ppa.payroll_action_id = paa.payroll_action_id
   and ppa.payroll_id = ptp.payroll_id
   and ppa.date_earned between ptp.start_date
                           and ptp.end_date
  order by 1, 2, 3, 4;
--
l_defbal_rec           t_def_bal_rec;
l_tu_needed_chr        pay_legislation_rules.rule_mode%type;
l_jc_needed_chr        pay_legislation_rules.rule_mode%type;
l_si_needed_chr        pay_legislation_rules.rule_mode%type;
l_st_needed_chr        pay_legislation_rules.rule_mode%type;
l_sn_needed_chr        pay_legislation_rules.rule_mode%type;
l_st2_needed_chr       pay_legislation_rules.rule_mode%type;
l_td_needed_chr        pay_legislation_rules.rule_mode%type;
l_bd_needed_chr        pay_legislation_rules.rule_mode%type;
l_lu_needed_chr        pay_legislation_rules.rule_mode%type;
l_sn2_needed_chr       pay_legislation_rules.rule_mode%type;
l_org_needed_chr       pay_legislation_rules.rule_mode%type;
--
begin
--
if g_debug then
  hr_utility.set_location('Entering pay_balance_pkg.add_asgbal_to_list',10);
  hr_utility.trace('p_load_type: '||p_load_type);
end if;
      l_jc_needed_chr := 'N';
      l_si_needed_chr := 'N';
      l_st_needed_chr := 'N';
      l_sn_needed_chr := 'N';
      l_tu_needed_chr := 'N';
      l_st2_needed_chr := 'N';
      l_td_needed_chr := 'N';
      l_bd_needed_chr := 'N';
      l_lu_needed_chr := 'N';
      l_sn2_needed_chr := 'N';
      l_org_needed_chr := 'N';
      load_defbal_cache(p_def_bal_id,
                          l_defbal_rec);
--
      if (l_defbal_rec.jc_needed = TRUE) then
         l_jc_needed_chr := 'Y';
      end if;
      if (l_defbal_rec.si_needed = TRUE) then
         l_si_needed_chr := 'Y';
      end if;
      if (l_defbal_rec.st_needed = TRUE) then
         l_st_needed_chr := 'Y';
      end if;
      if (l_defbal_rec.sn_needed = TRUE) then
         l_sn_needed_chr := 'Y';
      end if;
      if (l_defbal_rec.tu_needed = TRUE) then
         l_tu_needed_chr := 'Y';
      end if;
      if (l_defbal_rec.st2_needed = TRUE) then
         l_st2_needed_chr := 'Y';
      end if;
      if (l_defbal_rec.td_needed = TRUE) then
         l_td_needed_chr := 'Y';
      end if;
      if (l_defbal_rec.bd_needed = TRUE) then
         l_bd_needed_chr := 'Y';
      end if;
      if (l_defbal_rec.lu_needed = TRUE) then
         l_lu_needed_chr := 'Y';
      end if;
      if (l_defbal_rec.sn2_needed = TRUE) then
         l_sn2_needed_chr := 'Y';
      end if;
      if (l_defbal_rec.org_needed = TRUE) then
         l_org_needed_chr := 'Y';
      end if;
--
     if (p_load_type = 'FORCE') then
       if g_debug then
          hr_utility.set_location('pay_balance_pkg.add_asgbal_to_list', 20);
       end if;
       delete from pay_run_balances
        where defined_balance_id = p_def_bal_id
          and assignment_action_id = p_asgact_id;
     elsif (p_load_type = 'TRUSTED') then
       null;
     else
       if g_debug then
          hr_utility.set_location('pay_balance_pkg.add_asgbal_to_list', 25);
       end if;
        declare
           l_dummy number;
        begin
           select 1
             into l_dummy
             from dual
            where exists (select ''
                            from pay_run_balances
                           where defined_balance_id = p_def_bal_id
                             and assignment_action_id = p_asgact_id
                             and balance_value <> 0);
--
           -- Error, there should be no rows in this mode
           hr_utility.set_message(801,'HR_34723_NO_ROWS_NORMAL_MODE');
           hr_utility.raise_error;
--
        exception
           when no_data_found then
               null;
        end;
     end if;
--
      for ctxrec in get_contexts(p_asgact_id,
                                 l_defbal_rec.jurisdiction_lvl,
                                 l_tu_needed_chr,
                                 l_jc_needed_chr,
                                 l_si_needed_chr,
                                 l_st_needed_chr,
                                 l_sn_needed_chr,
                                 l_st2_needed_chr,
                                 l_td_needed_chr,
                                 l_bd_needed_chr,
                                 l_lu_needed_chr,
                                 l_sn2_needed_chr,
                                 l_org_needed_chr) loop
--
--       Only add to the list if all the context values are known
--
         if (    ((    l_defbal_rec.st2_needed = TRUE
                   and ctxrec.source_text2 is not null)
                  or l_defbal_rec.st2_needed = FALSE)
             and ((    l_defbal_rec.jc_needed = TRUE
                   and ctxrec.jurisdiction_code is not null)
                  or l_defbal_rec.jc_needed = FALSE)
             and ((    l_defbal_rec.tu_needed = TRUE
                   and ctxrec.tax_unit_id is not null)
                  or l_defbal_rec.tu_needed = FALSE)
             and ((    l_defbal_rec.si_needed = TRUE
                   and ctxrec.source_id is not null)
                  or l_defbal_rec.si_needed = FALSE)
             and ((    l_defbal_rec.st_needed = TRUE
                   and ctxrec.source_text is not null)
                  or l_defbal_rec.st_needed = FALSE)
             and ((    l_defbal_rec.sn_needed = TRUE
                   and ctxrec.source_number is not null)
                  or l_defbal_rec.sn_needed = FALSE)
             and ((    l_defbal_rec.td_needed = TRUE
                   and ctxrec.time_definition_id is not null)
                  or l_defbal_rec.td_needed = FALSE)
             and ((    l_defbal_rec.bd_needed = TRUE
                   and ctxrec.balance_date is not null)
                  or l_defbal_rec.bd_needed = FALSE)
             and ((    l_defbal_rec.lu_needed = TRUE
                   and ctxrec.local_unit_id is not null)
                  or l_defbal_rec.lu_needed = FALSE)
             and ((    l_defbal_rec.sn2_needed = TRUE
                   and ctxrec.source_number2 is not null)
                  or l_defbal_rec.sn2_needed = FALSE)
             and ((    l_defbal_rec.org_needed = TRUE
                   and ctxrec.organization_id is not null)
                  or l_defbal_rec.org_needed = FALSE)
            ) then
--
           p_output_list(p_next_free).defined_balance_id:= p_def_bal_id;
           p_output_list(p_next_free).tax_unit_id := ctxrec.tax_unit_id;
           p_output_list(p_next_free).jurisdiction_code := ctxrec.jurisdiction_code;
           p_output_list(p_next_free).source_id := ctxrec.source_id;
           p_output_list(p_next_free).source_text := ctxrec.source_text;
           p_output_list(p_next_free).source_number := ctxrec.source_number;
           p_output_list(p_next_free).source_text2 := ctxrec.source_text2;
           p_output_list(p_next_free).time_def_id := ctxrec.time_definition_id;
           p_output_list(p_next_free).balance_date := ctxrec.balance_date;
           p_output_list(p_next_free).local_unit_id := ctxrec.local_unit_id;
           p_output_list(p_next_free).source_number2 := ctxrec.source_number2;
           p_output_list(p_next_free).organization_id := ctxrec.organization_id;
           p_output_list(p_next_free).balance_value := 0;
           p_output_list(p_next_free).balance_found := FALSE;
           p_output_list(p_next_free).jurisdiction_lvl := l_defbal_rec.jurisdiction_lvl;
           p_next_free := p_next_free + 1;
         end if;
--
      end loop;
--
if g_debug then
  hr_utility.set_location('Leaving: pay_balance_pkg.add_asgbal_to_list', 40);
end if;
--
end add_asgbal_to_list;
--
procedure create_all_asg_balances_full(p_asgact_id  in number,
                                  p_bal_list   in varchar2 default 'ALL',
                                  p_load_type  in varchar2 default 'NORMAL',
                                  p_def_bal    in number   default null,
                                  p_eff_date   in date     default null,
                                  p_delta      in varchar2 default null
                                 )
is
--
cursor crs_asgact (p_asg_act_id number,
                   p_bus_grp_id number,
                   p_leg_code   varchar2,
                   p_bal_list   varchar2,
                   p_def_bal    number)
is
select  /*+ ORDERED USE_NL(pbf pbt pdb pbd prrv)
            INDEX(prrv PAY_RUN_RESULT_VALUES_N50)*/
       distinct  pdb.defined_balance_id,
       pbt.jurisdiction_level,
       pbt.balance_type_id,
       pbd.balance_dimension_id
  from
       pay_run_results      prr,
       pay_run_result_values prrv,
       pay_balance_feeds_f  pbf,
       pay_balance_types    pbt,
       pay_defined_balances pdb,
       pay_balance_dimensions pbd
 where pbd.dimension_level = 'ASG'
   and pdb.save_run_balance|| decode (pbt.balance_type_id, 0, '', '')= 'Y'
   and pdb.balance_dimension_id = pbd.balance_dimension_id
   and pdb.balance_type_id = pbt.balance_type_id
   and (    p_bal_list <> 'INVALID'
         or (    p_bal_list = 'INVALID'
             and exists (select ''
                           from pay_balance_validation pbv
                          where pbv.defined_balance_id = pdb.defined_balance_id
                            and pbv.business_group_id = p_bus_grp_id
                            and pbv.run_balance_status = 'P')
            )
       )
   and (   p_def_bal is null
        or p_def_bal = pdb.defined_balance_id
       )
   and ((pdb.business_group_id = p_bus_grp_id
          and pdb.legislation_code is null)
        or
         (pdb.legislation_code = p_leg_code
          and pdb.business_group_id is null)
        or
         (pdb.legislation_code is null
          and pdb.business_group_id is null)
       )
   and prr.assignment_action_id = p_asg_act_id
   and prr.run_result_id = prrv.run_result_id
   and prrv.input_value_id = pbf.input_value_id
   and pbt.balance_type_id = pbf.balance_type_id;
--   and exists (select /*+ ORDERED */ ''
--                 from pay_run_results prr,
--                      pay_run_result_values prrv,
--                      pay_balance_feeds_f pbf
--                where prr.assignment_action_id = p_asg_act_id
--                  and prr.run_result_id = prrv.run_result_id
--                  and prrv.input_value_id = pbf.input_value_id
--                  and pbf.balance_type_id = pbt.balance_type_id);
--
-- Bug 6676876 - split the cursor 'crs_balatt' based on the value of defined_balance_id
cursor crs_balatt_1 (p_asg_act_id number
                    ,p_bal_list   varchar2
                    ,p_def_bal_id number
                     )
is
select /*+ ORDERED */
       pdb.defined_balance_id,
       pdb.balance_type_id,
       pdb.balance_dimension_id
  from
       pay_bal_attribute_definitions pbad,
       pay_balance_attributes        pba,
       pay_defined_balances          pdb,
       pay_balance_dimensions        pbd

 where
       pbad.attribute_name = p_bal_list
   and pbad.attribute_id   = pba.attribute_id
   and pba.defined_balance_id = pdb.defined_balance_id
   and pdb.balance_dimension_id = pbd.balance_dimension_id
   and pbd.dimension_level = 'ASG'
   and p_def_bal_id = pba.defined_balance_id
   and exists (select /*+ ORDERED */ ''
                 from pay_run_results prr,
                      pay_run_result_values prrv,
                      pay_balance_feeds_f pbf
                where prr.assignment_action_id = p_asg_act_id
                  and prr.run_result_id = prrv.run_result_id
                  and prrv.input_value_id = pbf.input_value_id
                  and pdb.balance_type_id = pbf.balance_type_id
              );
cursor crs_balatt_2 (p_asg_act_id number
                    ,p_bal_list   varchar2
                     )
is
select
       pdb.defined_balance_id,
       pdb.balance_type_id,
       pdb.balance_dimension_id
  from
       pay_bal_attribute_definitions pbad,
       pay_balance_attributes        pba,
       pay_defined_balances          pdb,
       pay_balance_dimensions        pbd
 where
       pbad.attribute_name = p_bal_list
   and pbad.attribute_id   = pba.attribute_id
   and pba.defined_balance_id = pdb.defined_balance_id
   and pdb.balance_dimension_id = pbd.balance_dimension_id
   and pbd.dimension_level = 'ASG'
   and pdb.balance_type_id in
                   (select /*+ USE_NL(paa,prr,prrv,pbf) ORDERED */
                           distinct pbf.balance_type_id
                    from pay_run_results prr,
                         pay_run_result_values prrv,
                         pay_balance_feeds_f pbf
                   where prr.assignment_action_id = p_asg_act_id
                     and prr.run_result_id = prrv.run_result_id
                     and prrv.input_value_id = pbf.input_value_id);
--
--cursor crs_delta_balatt (p_asg_act_id number
--                        ,p_bal_list   varchar2
--                        ,p_def_bal_id number
--                        ,p_bus_grp_id number
--                        ,p_eff_date   date
--                        )
--is
--select /*+ ORDERED */
--       pdb.defined_balance_id,
--       pdb.balance_type_id,
--       pdb.balance_dimension_id
--  from
--       pay_bal_attribute_definitions pbad,
--       pay_balance_attributes        pba,
--       pay_defined_balances          pdb,
--       pay_balance_dimensions        pbd
-- where
--       pbad.attribute_name = p_bal_list
--   and pbad.attribute_id   = pba.attribute_id
--   and pba.defined_balance_id = pdb.defined_balance_id
--   and pdb.balance_dimension_id = pbd.balance_dimension_id
--   and pbd.dimension_level = 'ASG'
--   and exists (select ''
--               from pay_balance_validation pbv
--               where pdb.defined_balance_id + decode(PDB.LEGISLATION_SUBGROUP, ' ', 0, 0) = pbv.defined_balance_id
--               and   pbv.run_balance_status = 'V'
--               and   pbv.business_group_id = p_bus_grp_id
--               and   pbv.balance_load_date is not null
--               and   pbv.balance_load_date > p_eff_date)
--   and pdb.balance_type_id in
--                (select /*+ USE_NL(paa,prr,prrv,pbf) ORDERED */
--                      distinct pbf.balance_type_id
--                 from pay_run_results prr,
--                      pay_run_result_values prrv,
--                      pay_balance_feeds_f pbf
--                where prr.assignment_action_id = p_asg_act_id
--                  and prr.run_result_id = prrv.run_result_id
--                  and prrv.input_value_id = pbf.input_value_id
--              );
--
--
-- Bug 5947296. Changed the sql statement not to scan through run results
--              more than once.
--
l_bal_attid number; -- balance attribute id.

cursor crs_delta_balatt (p_asg_act_id number
                        ,p_bal_list   varchar2
                        ,p_def_bal_id number
                        ,p_bus_grp_id number
                        ,p_eff_date   date
                        ,p_att_id     number
                        )
is
  select /*+ ORDERED
             use_nl(piv pbf pdb pbd pbv prrv)
          */
         distinct
         pdb.defined_balance_id,
         pdb.balance_type_id,
         pdb.balance_dimension_id
  from
    pay_run_results        prr,
    pay_input_values_f     piv,
    pay_balance_feeds_f    pbf,
    pay_defined_balances   pdb,
    pay_balance_attributes pba,
    pay_balance_dimensions pbd,
    pay_balance_validation pbv,
    pay_run_result_values  prrv
  where
      prr.assignment_action_id = p_asg_act_id
  and piv.element_type_id = prr.element_type_id
  and p_eff_date between piv.effective_start_date
                     and piv.effective_end_date
  and pbf.input_value_id = piv.input_value_id
  and p_eff_date between pbf.effective_start_date
                     and pbf.effective_end_date
  and pdb.balance_type_id = pbf.balance_type_id
  and pdb.save_run_balance = 'Y'
  and pba.attribute_id = p_att_id
  and pba.defined_balance_id = pdb.defined_balance_id
  and pdb.balance_dimension_id = pbd.balance_dimension_id
  and pbd.dimension_level = 'ASG'
  and pbv.defined_balance_id = pdb.defined_balance_id
  and pbv.run_balance_status = 'V'
  and pbv.business_group_id = p_bus_grp_id
  and pbv.balance_load_date > p_eff_date
  and prrv.run_result_id = prr.run_result_id
  and prrv.input_value_id = pbf.input_value_id
  and nvl(prrv.result_value,'0') <> '0'
  ;

--
cursor get_aa (asgact    in number) is
select paa.assignment_action_id,
       ppa.effective_date,
       paa.assignment_id,
       paa.action_sequence
  from pay_assignment_actions paa,
       pay_payroll_actions    ppa
 where ppa.payroll_action_id = paa.payroll_action_id
   and paa.assignment_action_id = asgact;
--
cursor get_contexts_2(asgact    in number,
                    p_si_needed  in varchar2,
                    p_st_needed  in varchar2,
                    p_sn_needed  in varchar2,
                    p_st2_needed in varchar2,
                    p_sn2_needed  in varchar2,
                    p_org_needed  in varchar2) is
select /*+ ORDERED USE_NL(prr) INDEX(prr pay_run_results_n50)*/
       distinct
       paa.tax_unit_id                                         tax_unit_id
,      prr.jurisdiction_code                                   jurisdiction_code
,      decode(p_si_needed,
              'Y', find_context('SOURCE_ID', prr.run_result_id),
              null)                                            source_id
,      decode(p_st_needed,
              'Y', find_context('SOURCE_TEXT', prr.run_result_id),
              null)                                            source_text
,      decode(p_sn_needed,
              'Y', find_context('SOURCE_NUMBER', prr.run_result_id),
              null)                                            source_number
,      decode(p_st2_needed,
              'Y', find_context('SOURCE_TEXT2', prr.run_result_id),
              null)                                            source_text2
,      decode(p_sn2_needed,
              'Y', find_context('SOURCE_NUMBER2', prr.run_result_id),
              null)                                            source_number2
,      decode(p_org_needed,
              'Y', find_context('ORGANIZATION_ID', prr.run_result_id),
              null)                                            organization_id
,      prr.time_definition_id
,      nvl(prr.end_date, ptp.end_date)                         balance_date
,      prr.local_unit_id
  from pay_assignment_actions paa,
       pay_payroll_actions    ppa,
       per_time_periods       ptp,
       pay_run_results        prr
 where paa.assignment_action_id = asgact
   and paa.assignment_action_id = prr.assignment_action_id
   and ppa.payroll_action_id = paa.payroll_action_id
   and ppa.payroll_id = ptp.payroll_id
   and ppa.date_earned between ptp.start_date
                           and ptp.end_date
  order by 1, 2, 3, 4;
--
cursor get_bg (aaid number) is
select pbg.business_group_id, pbg.legislation_code
  from pay_payroll_actions ppa,
       pay_assignment_actions paa,
       per_business_groups_perf pbg
 where ppa.payroll_action_id = paa.payroll_action_id
   and paa.assignment_action_id = aaid
   and pbg.business_group_id = ppa.business_group_id;
--
l_defbal_rec           t_def_bal_rec;
l_tu_needed_chr        pay_legislation_rules.rule_mode%type;
l_jc_needed_chr        pay_legislation_rules.rule_mode%type;
l_si_needed_chr        pay_legislation_rules.rule_mode%type;
l_st_needed_chr        pay_legislation_rules.rule_mode%type;
l_sn_needed_chr        pay_legislation_rules.rule_mode%type;
l_st2_needed_chr       pay_legislation_rules.rule_mode%type;
l_td_needed_chr        pay_legislation_rules.rule_mode%type;
l_bd_needed_chr        pay_legislation_rules.rule_mode%type;
l_lu_needed_chr        pay_legislation_rules.rule_mode%type;
l_sn2_needed_chr       pay_legislation_rules.rule_mode%type;
l_org_needed_chr       pay_legislation_rules.rule_mode%type;
  l_context_lst   t_context_tab;
  l_cnt           number;
  l_output_list   t_detailed_bal_out_tab;
  l_inp_val_name  pay_input_values_f.name%type;
  l_found         boolean;
  l_next_free number;
  l_bg_id     per_business_groups.business_group_id%type;
  l_leg_code  per_business_groups.legislation_code%type;
begin
--
if g_debug then
  hr_utility.set_location(
            'Entering:pay_balance_pkg.create_all_asg_balances_full',10);
end if;
   --
   select pbg.business_group_id,
          pbg.legislation_code
     into l_bg_id,
          l_leg_code
     from per_business_groups_perf pbg,
          pay_payroll_actions ppa,
          pay_assignment_actions paa
    where paa.assignment_action_id = p_asgact_id
      and ppa.payroll_action_id = paa.payroll_action_id
      and ppa.business_group_id = pbg.business_group_id;
--
   l_next_free := 1;
--
   if (    p_bal_list <> 'ALL'
       and p_bal_list <> 'INVALID'
       and p_bal_list <> 'SINGLE') then
--
       /* OK we must be balance attribute */
       -- REC 13/10/06 Balance attribute mode can now be used for SINGLE
       -- but SINGLE calls this procedure in FORCE mode. So, if p_def_bal
       -- is not null and p_bal_list is a GEN_BAL<pact_id) value, then FORCE
       -- can be allowed. The run balances will be deleted in procedure
       -- add_asgbal_to_list.
       --
     hr_utility.trace('p_delta is: '||p_delta);
     if (p_delta = 'N'
         or p_delta is null) then  -- if NOT in  DELTA MODE
     --
       if (p_load_type = 'TRUSTED') then
       --
         if g_debug then
           hr_utility.set_location(
                     'pay_balance_pkg.create_all_asg_balances_full', 20);
         end if;
         -- Bug 6676876 - split the cursor 'crs_balatt' based on the value of defined_balance_id
         if p_def_bal is NULL then
           for dbarec in crs_balatt_2(p_asgact_id
                                     ,p_bal_list
                                     ) loop
              add_asgbal_to_list(p_def_bal_id  => dbarec.defined_balance_id,
                                 p_load_type   => p_load_type,
                                 p_asgact_id   => p_asgact_id,
                                 p_output_list => l_output_list,
                                 p_next_free   => l_next_free
                                );
           end loop;
         else
           for dbarec in crs_balatt_1(p_asgact_id
                                     ,p_bal_list
                                     ,p_def_bal
                                     ) loop
              add_asgbal_to_list(p_def_bal_id  => dbarec.defined_balance_id,
                                 p_load_type   => p_load_type,
                                 p_asgact_id   => p_asgact_id,
                                 p_output_list => l_output_list,
                                 p_next_free   => l_next_free
                                );
           end loop;
         end if;

         --
       elsif (p_load_type = 'FORCE'
              and p_def_bal is not null) then
       --
       if g_debug then
         hr_utility.set_location(
                   'pay_balance_pkg.create_all_asg_balances_full', 30);
       end if;
       --
         for dbsarec in crs_balatt_1(p_asgact_id
                                    ,p_bal_list
                                    ,p_def_bal
                                    ) loop
            add_asgbal_to_list(p_def_bal_id  => dbsarec.defined_balance_id,
                               p_load_type   => p_load_type,
                               p_asgact_id   => p_asgact_id,
                               p_output_list => l_output_list,
                               p_next_free   => l_next_free
                              );
         end loop;
         --
       else -- p_load_type <> TRUSTED
--
        pay_core_utils.assert_condition('create_all_asg_balances_full:1', false);
      end if;
    else -- p_delta is Y thus in DELTA mode
    --
      if g_debug then
         hr_utility.set_location(
                   'pay_balance_pkg.create_all_asg_balances_full', 35);
       end if;
       --
       --
       -- Obtain the bal attribute id.
       --
       select attribute_id into l_bal_attid
       from pay_bal_attribute_definitions
       where attribute_name = p_bal_list;

       --
       for dbdrec in crs_delta_balatt(p_asgact_id
                                     ,p_bal_list
                                     ,p_def_bal
                                     ,l_bg_id
                                     ,p_eff_date
                                     ,l_bal_attid
                                     ) loop
            add_asgbal_to_list(p_def_bal_id  => dbdrec.defined_balance_id,
                               p_load_type   => p_load_type,
                               p_asgact_id   => p_asgact_id,
                               p_output_list => l_output_list,
                               p_next_free   => l_next_free
                              );
       end loop;
    end if;
     --
   else
     if g_debug then
       hr_utility.set_location(
                 'pay_balance_pkg.create_all_asg_balances_full', 40);
     end if;
     --
      for dbrec in crs_asgact(p_asgact_id,
                              l_bg_id,
                              l_leg_code,
                              p_bal_list,
                              p_def_bal) loop
         add_asgbal_to_list(p_def_bal_id  => dbrec.defined_balance_id,
                            p_load_type   => p_load_type,
                            p_asgact_id   => p_asgact_id,
                            p_output_list => l_output_list,
                            p_next_free   => l_next_free
                           );
      end loop;
   end if;
--
--
-- Only need to do the rest of this procedure if balances existed for the
-- people - i.e. if rows returned either from crs_balatt or crs_asgact.
--
if l_output_list.count > 0 then
--
-- Generate the context list
--
   -- Check whether the SOURCE_ID, SOURCE_TEXT contexts are used.
   l_si_needed_chr := 'N';
   l_st_needed_chr := 'N';
   l_sn_needed_chr := 'N';
   l_st2_needed_chr := 'N';
   l_sn2_needed_chr := 'N';
   l_org_needed_chr := 'N';
   for bgrec in get_bg(p_asgact_id) loop
--
     pay_core_utils.get_leg_context_iv_name('SOURCE_ID',
                                            bgrec.legislation_code,
                                            l_inp_val_name,
                                            l_found
                                           );
    if (l_found = TRUE) then
      l_si_needed_chr := 'Y';
    end if;
--
     pay_core_utils.get_leg_context_iv_name('SOURCE_TEXT',
                                            bgrec.legislation_code,
                                            l_inp_val_name,
                                            l_found
                                           );
    if (l_found = TRUE) then
      l_st_needed_chr := 'Y';
    end if;
--
     pay_core_utils.get_leg_context_iv_name('SOURCE_NUMBER',
                                            bgrec.legislation_code,
                                            l_inp_val_name,
                                            l_found
                                           );
    if (l_found = TRUE) then
      l_sn_needed_chr := 'Y';
    end if;
--
     pay_core_utils.get_leg_context_iv_name('SOURCE_TEXT2',
                                            bgrec.legislation_code,
                                            l_inp_val_name,
                                            l_found
                                           );
    if (l_found = TRUE) then
      l_st2_needed_chr := 'Y';
    end if;
--
     pay_core_utils.get_leg_context_iv_name('SOURCE_NUMBER2',
                                            bgrec.legislation_code,
                                            l_inp_val_name,
                                            l_found
                                           );
    if (l_found = TRUE) then
      l_sn2_needed_chr := 'Y';
    end if;
--
     pay_core_utils.get_leg_context_iv_name('ORGANIZATION_ID',
                                            bgrec.legislation_code,
                                            l_inp_val_name,
                                            l_found
                                           );
    if (l_found = TRUE) then
      l_org_needed_chr := 'Y';
    end if;
--
   end loop;
   l_cnt := 1;
   if g_debug then
      hr_utility.set_location(
                'pay_balance_pkg.create_all_asg_balances_full', 50);
   end if;
   for cxt in get_contexts_2(p_asgact_id,
                           l_si_needed_chr,
                           l_st_needed_chr,
                           l_sn_needed_chr,
                           l_st2_needed_chr,
                           l_sn2_needed_chr,
                           l_org_needed_chr) loop
      if g_debug then
         hr_utility.set_location(
                   'pay_balance_pkg.create_all_asg_balances_full', 60);
      end if;
      l_context_lst(l_cnt).tax_unit_id := cxt.tax_unit_id;
      l_context_lst(l_cnt).jurisdiction_code := cxt.jurisdiction_code;
      l_context_lst(l_cnt).source_id := cxt.source_id;
      l_context_lst(l_cnt).source_text := cxt.source_text;
      l_context_lst(l_cnt).source_number := cxt.source_number;
      l_context_lst(l_cnt).source_text2 := cxt.source_text2;
      l_context_lst(l_cnt).time_def_id := cxt.time_definition_id;
      l_context_lst(l_cnt).local_unit_id := cxt.local_unit_id;
      l_context_lst(l_cnt).source_number2 := cxt.source_number2;
      l_context_lst(l_cnt).organization_id := cxt.organization_id;
      l_context_lst(l_cnt).balance_date := cxt.balance_date;
--
      l_cnt := l_cnt + 1;
   end loop;
--
-- Go Get the balance values
--
   if g_debug then
      hr_utility.set_location(
                'pay_balance_pkg.create_all_asg_balances_full', 70);
   end if;
   for aarec in get_aa (p_asgact_id) loop
      pay_balance_pkg.get_value_int_batch (p_asgact_id,
                                 l_context_lst,
                                 TRUE,
                                 FALSE,
                                 l_output_list);
--
--   Insert the results in the run_balance table.
--
     if g_debug then
        hr_utility.set_location(
                  'pay_balance_pkg.create_all_asg_balances_full', 80);
     end if;


      ins_run_balance_bulk (p_output_list     => l_output_list,
                            p_asgact_id       => p_asgact_id,
                            p_pact_id         => null,
                            p_assignment_id   => aarec.assignment_id,
                            p_action_sequence => aarec.action_sequence,
                            p_effective_date  => aarec.effective_date
                            );
--
     if g_debug then
        hr_utility.set_location(
                  'pay_balance_pkg.create_all_asg_balances_full', 90);
     end if;
/* Commented for bug 6676876, used bulk insert into pay_run_balances for performance improvement
     for cnt in 1..l_output_list.count loop
       if (l_output_list(cnt).balance_value <> 0) then
--
         if g_debug then
            hr_utility.set_location(
                      'pay_balance_pkg.create_all_asg_balances_full', 90);
         end if;
         ins_run_balance (p_defined_balance_id => l_output_list(cnt).defined_balance_id,
                          p_eff_date           => aarec.effective_date,
                          p_bal_val            => l_output_list(cnt).balance_value,
                          p_payroll_act_id     => null,
                          p_asg_act_id         => p_asgact_id,
                          p_asg_id             => aarec.assignment_id,
                          p_act_seq            => aarec.action_sequence,
                          p_tax_unit           => l_output_list(cnt).tax_unit_id,
                          p_jurisdiction       => l_output_list(cnt).jurisdiction_code,
                          p_source_id          => l_output_list(cnt).source_id,
                          p_source_text        => l_output_list(cnt).source_text,
                          p_source_number      => l_output_list(cnt).source_number,
                          p_source_text2       => l_output_list(cnt).source_text2,
                          p_time_def_id        => l_output_list(cnt).time_def_id,
                          p_balance_date       => l_output_list(cnt).balance_date,
                          p_local_unit_id      => l_output_list(cnt).local_unit_id,
                          p_source_number2     => l_output_list(cnt).source_number2,
                          p_organization_id    => l_output_list(cnt).organization_id
                         );
--
       end if;
     end loop;
*/
   end loop;
--
else -- no balances returned from cursors crs_balatt or crs_asgact, so do
     -- nothing
  hr_utility.set_location('pay_balance_pkg.create_all_asg_balances_full',98);
end if;
--
if g_debug then
  hr_utility.set_location(
            'Leaving: pay_balance_pkg.create_all_asg_balances_full', 100);
end if;
--
end create_all_asg_balances_full;
--------------------------------------------------------------------------
-- procedure create_all_asg_balances
--------------------------------------------------------------------------
procedure create_all_asg_balances(p_asgact_id  in number,
                                  p_bal_list   in varchar2 default 'ALL',
                                  p_load_type  in varchar2 default 'NORMAL',
                                  p_eff_date   in date     default null,
                                  p_delta      in varchar2  default null
                                 )
is
--
cursor crs_asgact (p_asg_act_id number)
is
select pdb.defined_balance_id
  from pay_defined_balances pdb,
       pay_balance_dimensions pbd,
       pay_assignment_actions paa,
       pay_payroll_actions    ppa,
       per_business_groups_perf pbg
 where pbd.dimension_level = 'ASG'
   and pdb.save_run_balance = 'Y'
   and pdb.balance_dimension_id = pbd.balance_dimension_id
   and paa.assignment_action_id = p_asg_act_id
   and paa.payroll_action_id = ppa.payroll_action_id
   and ppa.business_group_id = pbg.business_group_id
   and ((pdb.business_group_id = pbg.business_group_id
          and pdb.legislation_code is null)
        or
         (pdb.legislation_code = pbg.legislation_code
          and pdb.business_group_id is null)
        or
         (pdb.legislation_code is null
          and pdb.business_group_id is null)
       );
--
cursor crs_invalid (p_asg_act_id number)
is
select /*+ ORDERED */
       pdb.defined_balance_id
  from pay_assignment_actions paa,
       pay_payroll_actions    ppa,
       per_business_groups_perf pbg,
       pay_balance_validation pbv,
       pay_defined_balances pdb,
       pay_balance_dimensions pbd
 where pbd.dimension_level = 'ASG'
   and pdb.save_run_balance = 'Y'
   and pdb.balance_dimension_id = pbd.balance_dimension_id
   and paa.assignment_action_id = p_asg_act_id
   and paa.payroll_action_id = ppa.payroll_action_id
   and ppa.business_group_id = pbg.business_group_id
   and pbv.defined_balance_id = pdb.defined_balance_id
   and pbv.business_group_id  = ppa.business_group_id
   and pbv.run_balance_status <> 'V'
   and ((pdb.business_group_id = pbg.business_group_id
          and pdb.legislation_code is null)
        or
         (pdb.legislation_code = pbg.legislation_code
          and pdb.business_group_id is null)
        or
         (pdb.legislation_code is null
          and pdb.business_group_id is null)
       );
--
save_run_bals pay_legislation_rules.rule_mode%type;
bal_ret_buffer_sz number;
l_param_value     pay_action_parameters.parameter_value%type;
l_found       boolean;
l_balance_lst t_balance_value_tab;
l_cnt         number;
l_delta       boolean;
--
begin
g_debug := hr_utility.debug_enabled;
if g_debug then
   hr_utility.set_location('Entering: pay_balance_pkg.create_all_asg_balances', 5);
end if;
--
   l_balance_lst.delete;
--
   /* Get the buffer size */
   pay_core_utils.get_action_parameter('BAL_RETRIEVAL_BUFFER_SIZE',
                                       l_param_value,
                                       l_found);
   if (l_found = TRUE) then
     bal_ret_buffer_sz := to_number(l_param_value);
     if (bal_ret_buffer_sz > 1000) then
      bal_ret_buffer_sz := 1000;
     end if;
   else
     bal_ret_buffer_sz := 100;
   end if;
   hr_utility.trace('Action Parameter BAL_RETRIEVAL_BUFFER_SIZE = '||bal_ret_buffer_sz);
--
   /* First get the legislation rule */
   begin
      select plr.rule_mode
        into save_run_bals
        from pay_legislation_rules plr,
             per_business_groups_perf pbg,
             pay_payroll_actions ppa,
             pay_assignment_actions paa
       where ppa.payroll_action_id = paa.payroll_action_id
         and paa.assignment_action_id = p_asgact_id
         and ppa.business_group_id = pbg.business_group_id
         and pbg.legislation_code = plr.legislation_code
         and plr.rule_type = 'SAVE_ASG_RUN_BAL';
   exception
      when no_data_found then
        save_run_bals := 'N';
   end;
--
   l_cnt := 1;
   if (save_run_bals = 'Y') then
--
     if g_debug then
        hr_utility.set_location('pay_balance_pkg.create_all_asg_balances', 25);
     end if;
--
     if (p_bal_list = 'ALL'
         or (    p_bal_list = 'INVALID'
             and p_load_type = 'TRUSTED')
         or (    p_bal_list <> 'ALL'
             and p_bal_list <> 'INVALID'
             and p_bal_list <> 'SINGLE')) then
     --
       create_all_asg_balances_full(p_asgact_id => p_asgact_id
                                   ,p_bal_list  => p_bal_list
                                   ,p_load_type => p_load_type
                                   ,p_eff_date  => p_eff_date
                                   ,p_delta     => p_delta
                                 );
--
     elsif (p_bal_list = 'INVALID') then
--
       for fullrec in crs_invalid(p_asgact_id) loop
--
         l_balance_lst(l_cnt).defined_balance_id := fullrec.defined_balance_id;
         if g_debug then
            hr_utility.trace('Added Def Bal ID '||
                              l_balance_lst(l_cnt).defined_balance_id);
         end if;
--
         /* Have we reached the buffer limit */
         if (l_cnt = bal_ret_buffer_sz) then
--
           create_set_asg_balance(l_balance_lst,
                                  p_asgact_id,
                                  p_load_type);
           l_balance_lst.delete;
           l_cnt := 1;
         else
           l_cnt := l_cnt + 1;
         end if;
--
       end loop;
--
--
       /* Do we still have values in the buffer to process */
       if (l_cnt <> 1) then
         create_set_asg_balance(l_balance_lst,
                                p_asgact_id,
                                p_load_type);
         l_balance_lst.delete;
       end if;
--
     end if;
--
   end if;
--
if g_debug then
   hr_utility.set_location('Leaving: pay_balance_pkg.create_all_asg_balances', 30);
end if;
end create_all_asg_balances;
--
--------------------------------------------------------------------------
-- procedure create_set_group_balance
--------------------------------------------------------------------------
procedure create_set_group_balance(p_defined_balance_lst  in out nocopy t_balance_value_tab,
                                   p_pact_id              in            number,
                                   p_load_type            in            varchar2 default 'NORMAL')
is
--
cursor get_contexts(p_pact_id    in number,
                    p_si_needed  in varchar2,
                    p_st_needed  in varchar2,
                    p_sn_needed  in varchar2,
                    p_st2_needed  in varchar2,
                    p_sn2_needed  in varchar2,
                    p_org_needed  in varchar2) is
select distinct
       paa.tax_unit_id                                         tax_unit_id
,      prr.jurisdiction_code                                   jurisdiction_code
,      decode(p_si_needed,
              'Y', find_context('SOURCE_ID', prr.run_result_id),
              null)                                            source_id
,      decode(p_st_needed,
              'Y', find_context('SOURCE_TEXT', prr.run_result_id),
              null)                                            source_text
,      decode(p_sn_needed,
              'Y', find_context('SOURCE_NUMBER', prr.run_result_id),
              null)                                            source_number
,      decode(p_st2_needed,
              'Y', find_context('SOURCE_TEXT2', prr.run_result_id),
              null)                                            source_text2
,      decode(p_sn2_needed,
              'Y', find_context('SOURCE_NUMBER2', prr.run_result_id),
              null)                                            source_number2
,      decode(p_org_needed,
              'Y', find_context('ORGANIZATION_ID', prr.run_result_id),
              null)                                            organization_id
,      prr.time_definition_id
,      nvl(prr.end_date, ptp.end_date)                         balance_date
,      prr.local_unit_id
  from pay_assignment_actions paa,
       pay_run_results        prr,
       pay_payroll_actions    ppa,
       per_time_periods       ptp
 where ppa.payroll_action_id = p_pact_id
   and paa.payroll_action_id = ppa.payroll_action_id
   and paa.assignment_action_id = prr.assignment_action_id
   and ptp.payroll_id = ppa.payroll_id
   and ppa.date_earned between ptp.start_date
                           and ptp.end_date
  order by 1, 2, 3, 4;
--
cursor get_aa (p_pact_id    in number) is
select paa.assignment_action_id,
       ppa.effective_date
  from pay_assignment_actions paa,
       pay_payroll_actions    ppa
 where ppa.payroll_action_id = p_pact_id
   and ppa.payroll_action_id = paa.payroll_action_id
   and rownum = 1;
--
cursor get_bg (pactid number) is
select pbg.business_group_id, pbg.legislation_code
  from pay_payroll_actions ppa,
       per_business_groups_perf pbg
 where payroll_action_id = pactid
   and pbg.business_group_id = ppa.business_group_id;
--
  l_si_needed_chr varchar2(10);
  l_st_needed_chr varchar2(10);
  l_sn_needed_chr varchar2(10);
  l_sn2_needed_chr varchar2(10);
  l_org_needed_chr varchar2(10);
  l_st2_needed_chr varchar2(10);
  l_context_lst   t_context_tab;
  l_cnt           number;
  l_output_list   t_detailed_bal_out_tab;
  l_inp_val_name  pay_input_values_f.name%type;
  l_found         boolean;
--
begin
--
   if g_debug then
      hr_utility.set_location('Entering: pay_balance_pkg.create_set_group_balance', 5);
   end if;
--
   -- Check whether the SOURCE_ID, SOURCE_TEXT contexts are used.
   l_si_needed_chr := 'N';
   l_st_needed_chr := 'N';
   l_sn_needed_chr := 'N';
   l_st2_needed_chr := 'N';
   l_sn2_needed_chr := 'N';
   l_org_needed_chr := 'N';
   for bgrec in get_bg(p_pact_id) loop
--
     pay_core_utils.get_leg_context_iv_name('SOURCE_ID',
                                            bgrec.legislation_code,
                                            l_inp_val_name,
                                            l_found
                                           );
    if (l_found = TRUE) then
      l_si_needed_chr := 'Y';
    end if;
--
     pay_core_utils.get_leg_context_iv_name('SOURCE_TEXT',
                                            bgrec.legislation_code,
                                            l_inp_val_name,
                                            l_found
                                           );
    if (l_found = TRUE) then
      l_st_needed_chr := 'Y';
    end if;
--
     pay_core_utils.get_leg_context_iv_name('SOURCE_NUMBER',
                                            bgrec.legislation_code,
                                            l_inp_val_name,
                                            l_found
                                           );
    if (l_found = TRUE) then
      l_sn_needed_chr := 'Y';
    end if;
--
     pay_core_utils.get_leg_context_iv_name('SOURCE_TEXT2',
                                            bgrec.legislation_code,
                                            l_inp_val_name,
                                            l_found
                                           );
    if (l_found = TRUE) then
      l_st2_needed_chr := 'Y';
    end if;
--
     pay_core_utils.get_leg_context_iv_name('SOURCE_NUMBER2',
                                            bgrec.legislation_code,
                                            l_inp_val_name,
                                            l_found
                                           );
    if (l_found = TRUE) then
      l_sn2_needed_chr := 'Y';
    end if;
--
     pay_core_utils.get_leg_context_iv_name('ORGANIZATION_ID',
                                            bgrec.legislation_code,
                                            l_inp_val_name,
                                            l_found
                                           );
    if (l_found = TRUE) then
      l_org_needed_chr := 'Y';
    end if;
--
   end loop;
--
-- Validate/Delete the pay_run_balances for this mode.
--
   for cnt in 1..p_defined_balance_lst.count loop
--
     if (p_load_type = 'FORCE') then
       if g_debug then
          hr_utility.set_location('pay_balance_pkg.create_set_group_balance', 20);
       end if;
       delete from pay_run_balances
        where defined_balance_id = p_defined_balance_lst(cnt).defined_balance_id
          and payroll_action_id = p_pact_id;
     elsif (p_load_type = 'TRUSTED') then
        null;
     else
       if g_debug then
          hr_utility.set_location('pay_balance_pkg.create_set_group_balance', 25);
       end if;
        declare
           l_dummy number;
        begin
           select 1
             into l_dummy
             from dual
            where exists (select 1
                            from pay_run_balances
                           where defined_balance_id = p_defined_balance_lst(cnt).defined_balance_id
                             and payroll_action_id = p_pact_id
                             and balance_value <> 0);
--
           /* Error, there should be no rows in this mode */
           hr_utility.set_message(801,'HR_34723_NO_ROWS_NORMAL_MODE');
           hr_utility.raise_error;
--
        exception
           when no_data_found then
               null;
        end;
     end if;
   end loop;
--
-- Generate the context list
--
   l_cnt := 1;
   if g_debug then
      hr_utility.set_location('pay_balance_pkg.create_set_group_balance', 27);
   end if;
   for cxt in get_contexts(p_pact_id,
                           l_si_needed_chr,
                           l_st_needed_chr,
                           l_sn_needed_chr,
                           l_st2_needed_chr,
                           l_sn2_needed_chr,
                           l_org_needed_chr) loop
      if g_debug then
         hr_utility.set_location('pay_balance_pkg.create_set_group_balance', 28);
      end if;
      l_context_lst(l_cnt).tax_unit_id := cxt.tax_unit_id;
      l_context_lst(l_cnt).jurisdiction_code := cxt.jurisdiction_code;
      l_context_lst(l_cnt).source_id := cxt.source_id;
      l_context_lst(l_cnt).source_text := cxt.source_text;
      l_context_lst(l_cnt).source_number := cxt.source_number;
      l_context_lst(l_cnt).source_text2 := cxt.source_text2;
      l_context_lst(l_cnt).time_def_id := cxt.time_definition_id;
      l_context_lst(l_cnt).local_unit_id := cxt.local_unit_id;
      l_context_lst(l_cnt).source_number2 := cxt.source_number2;
      l_context_lst(l_cnt).organization_id := cxt.organization_id;
      l_context_lst(l_cnt).balance_date := cxt.balance_date;
--
      l_cnt := l_cnt + 1;
   end loop;
--
-- Go Get the balance values
--
   if g_debug then
      hr_utility.set_location('pay_balance_pkg.create_set_group_balance', 30);
   end if;
   for aarec in get_aa (p_pact_id) loop
      pay_balance_pkg.get_value (aarec.assignment_action_id,
                                 p_defined_balance_lst,
                                 l_context_lst,
                                 TRUE,
                                 FALSE,
                                 l_output_list);
--
--   Insert the results in the run_balance table.
--
     if g_debug then
        hr_utility.set_location('pay_balance_pkg.create_set_group_balance', 35);
     end if;

      ins_run_balance_bulk (p_output_list     => l_output_list,
                            p_asgact_id       => null,
                            p_pact_id         => p_pact_id,
                            p_assignment_id   => null,
                            p_action_sequence => null,
                            p_effective_date  => aarec.effective_date
                            );
--
       if g_debug then
          hr_utility.set_location('pay_balance_pkg.create_set_group_balance', 40);
       end if;
/* Commented for bug 6676876, used bulk insert into pay_run_balances for performance improvement
     for cnt in 1..l_output_list.count loop
       if g_debug then
          hr_utility.trace('Bal Value = '||l_output_list(cnt).balance_value);
       end if;
       if (l_output_list(cnt).balance_value <> 0) then
--
         if g_debug then
            hr_utility.set_location('pay_balance_pkg.create_set_group_balance', 40);
         end if;
         ins_run_balance (p_defined_balance_id => l_output_list(cnt).defined_balance_id,
                          p_eff_date           => aarec.effective_date,
                          p_bal_val            => l_output_list(cnt).balance_value,
                          p_payroll_act_id     => p_pact_id,
                          p_asg_act_id         => null,
                          p_asg_id             => null,
                          p_act_seq            => null,
                          p_tax_unit           => l_output_list(cnt).tax_unit_id,
                          p_jurisdiction       => l_output_list(cnt).jurisdiction_code,
                          p_source_id          => l_output_list(cnt).source_id,
                          p_source_text        => l_output_list(cnt).source_text,
                          p_source_number      => l_output_list(cnt).source_number,
                          p_source_text2       => l_output_list(cnt).source_text2,
                          p_time_def_id        => l_output_list(cnt).time_def_id,
                          p_balance_date       => l_output_list(cnt).balance_date,
                          p_local_unit_id      => l_output_list(cnt).local_unit_id,
                          p_source_number2     => l_output_list(cnt).source_number2,
                          p_organization_id    => l_output_list(cnt).organization_id
                         );
--
       end if;
     end loop;
*/
   end loop;
--
   if g_debug then
      hr_utility.set_location('Leaving: pay_balance_pkg.create_set_group_balance', 50);
   end if;
end create_set_group_balance;
--------------------------------------------------------------------------
-- procedure create_all_group_balances
--------------------------------------------------------------------------
procedure create_all_group_balances(p_pact_id    in number
                                   ,p_bal_list   in varchar2 default 'ALL'
                                   ,p_load_type  in varchar2 default 'NORMAL'
                                   ,p_eff_date   in date     default NULL
                                   ,p_delta      in varchar2 default NULL
                                   )
is
--
cursor crs_pact (p_pact_id number)
is
select pdb.defined_balance_id
  from pay_defined_balances pdb,
       pay_balance_dimensions pbd,
       pay_payroll_actions    ppa,
       per_business_groups_perf pbg
 where pbd.dimension_level = 'GRP'
   and pdb.save_run_balance = 'Y'
   and pdb.balance_dimension_id = pbd.balance_dimension_id
   and ppa.payroll_action_id = p_pact_id
   and ppa.business_group_id = pbg.business_group_id
   and ((pdb.business_group_id = pbg.business_group_id
      and pdb.legislation_code is null)
    or
     (pdb.legislation_code = pbg.legislation_code
      and pdb.business_group_id is null)
    or
     (pdb.legislation_code is null
      and pdb.business_group_id is null)
   );
--
cursor crs_invalid (p_pact_id number)
is
select /*+ ORDERED */
       pdb.defined_balance_id
  from pay_payroll_actions    ppa,
       per_business_groups_perf pbg,
       pay_balance_validation pbv,
       pay_defined_balances pdb,
       pay_balance_dimensions pbd
 where pbd.dimension_level = 'GRP'
   and pdb.save_run_balance = 'Y'
   and pdb.balance_dimension_id = pbd.balance_dimension_id
   and ppa.payroll_action_id = p_pact_id
   and ppa.business_group_id = pbg.business_group_id
   and pbv.defined_balance_id = pdb.defined_balance_id
   and pbv.business_group_id = ppa.business_group_id
   and pbv.run_balance_status <> 'V'
   and ((pdb.business_group_id = pbg.business_group_id
      and pdb.legislation_code is null)
    or
     (pdb.legislation_code = pbg.legislation_code
      and pdb.business_group_id is null)
    or
     (pdb.legislation_code is null
      and pdb.business_group_id is null)
   );
--
save_run_bals pay_legislation_rules.rule_mode%type;
bal_ret_buffer_sz number;
l_param_value     pay_action_parameters.parameter_value%type;
l_found       boolean;
l_balance_lst t_balance_value_tab;
l_cnt         number;
--
begin
g_debug := hr_utility.debug_enabled;
if g_debug then
   hr_utility.set_location('Entering: pay_balance_pkg.create_all_group_balances', 5);
end if;
--
   l_balance_lst.delete;
--
   /* Get the buffer size */
   pay_core_utils.get_action_parameter('BAL_RETRIEVAL_BUFFER_SIZE',
                                       l_param_value,
                                       l_found);
   if (l_found = TRUE) then
     bal_ret_buffer_sz := to_number(l_param_value);
    if (bal_ret_buffer_sz > 1000) then
      bal_ret_buffer_sz := 1000;
    end if;
   else
     bal_ret_buffer_sz := 100;
   end if;
   hr_utility.trace('Action Parameter BAL_RETRIEVAL_BUFFER_SIZE = '||bal_ret_buffer_sz);
--
   /* First get the legislation rule */
   begin
      select plr.rule_mode
        into save_run_bals
        from pay_legislation_rules plr,
             per_business_groups_perf pbg,
             pay_payroll_actions ppa
       where ppa.payroll_action_id = p_pact_id
         and ppa.business_group_id = pbg.business_group_id
         and pbg.legislation_code = plr.legislation_code
         and plr.rule_type = 'SAVE_RUN_BAL';
   exception
      when no_data_found then
        save_run_bals := 'N';
   end;
--
   if (save_run_bals = 'Y') then
--
     if g_debug then
        hr_utility.set_location('pay_balance_pkg.create_all_group_balances', 25);
     end if;
     l_cnt := 1;
--
     if (p_bal_list = 'ALL'
         or (    p_bal_list = 'INVALID'
             and p_load_type = 'TRUSTED')
         or (    p_bal_list <> 'ALL'
             and p_bal_list <> 'INVALID'
             and p_bal_list <> 'SINGLE')) then
--
       create_all_grp_balances_full(p_pact_id   => p_pact_id
                                   ,p_bal_list  => p_bal_list
                                   ,p_load_type => p_load_type
                                   ,p_eff_date  => p_eff_date
                                   ,p_delta     => p_delta
                                   );
--
     elsif (p_bal_list = 'INVALID') then
--
       for fullrec in crs_invalid(p_pact_id) loop
--
         l_balance_lst(l_cnt).defined_balance_id := fullrec.defined_balance_id;
         if g_debug then
            hr_utility.trace('Added Def Bal ID '||
                              l_balance_lst(l_cnt).defined_balance_id);
         end if;
--
         /* Have we reached the buffer limit */
         if (l_cnt = bal_ret_buffer_sz) then
--
           create_set_group_balance(l_balance_lst,
                                    p_pact_id,
                                    p_load_type);
           l_balance_lst.delete;
           l_cnt := 1;
         else
           l_cnt := l_cnt + 1;
         end if;
--
       end loop;
--
       /* Do we still have values in the buffer to process */
       if (l_cnt <> 1) then
         create_set_group_balance(l_balance_lst,
                                  p_pact_id,
                                  p_load_type);
         l_balance_lst.delete;
       end if;
--
     end if;
--
   end if;
--
if g_debug then
   hr_utility.set_location('Leaving: pay_balance_pkg.create_all_group_balances', 30);
end if;
end create_all_group_balances;
--
--------------------------------------------------------------------------
-- procedure initialise_run_balance
-- This procedure initialises a run balance by creating a row in
-- pay_balance_validation. This procedure will be called from the
-- defined_balance trigger.
-- For a user defined balance, a row will be inserted for the bg of the def bal.
-- For a legislative defined balance, a row will be inserted for each bg within
-- the specific legislation.
-- For a core defined balance, a row will be inserted for each bg within
-- those legislations that have been enabled for run balances.


--------------------------------------------------------------------------
procedure initialise_run_balance(p_defbal_id         in number
                                ,p_baldim_id         in number
                                ,p_bal_type_id       in number
                                ,p_legislation_code  in varchar2
                                ,p_business_group_id in number)
is
--
--
-- This cursor returns the dimension_level and confirms that it is a valid run
--  balance defined balance, i.e save_run_bal = 'Y' and dim_type = 'R'
--
cursor get_dim_level(p_balance_dimension_id in number)
is
select dimension_level
from   pay_balance_dimensions
where  dimension_type = 'R'
and    balance_dimension_id = p_balance_dimension_id;
--
cursor get_leg_code(p_bg_id number)
is
select legislation_code
from   per_business_groups_perf
where  business_group_id = p_bg_id;
--
cursor enabled_bg(p_bg_id     in number
                 ,p_leg_code  in varchar2
                 ,p_dim_level in varchar2)
is
select pbg.business_group_id
from   per_business_groups_perf pbg
,      pay_legislation_rules plr
where  pbg.legislation_code = plr.legislation_code
and    plr.legislation_code = nvl(p_leg_code, plr.legislation_code)
and    pbg.business_group_id = nvl(p_bg_id, pbg.business_group_id)
and    plr.rule_type = decode(p_dim_level, 'ASG', 'SAVE_ASG_RUN_BAL'
                                         , 'GRP', 'SAVE_RUN_BAL')
and    plr.rule_mode = 'Y';
--
cursor check_run_results(p_baltype_id in number)
is
select 1
from   dual
where exists (select /*+ ORDERED*/
                   null
              from pay_balance_feeds_f bf
              ,    pay_run_result_values rrv
              where bf.balance_type_id = p_baltype_id
              and   bf.input_value_id = rrv.input_value_id);
--
-- Bug 3364019 added the + 1 to get the correct balance_load_date
--
cursor bal_load_date(p_business_group_id number)
is
select nvl((max(ppa.effective_date)+1),fnd_date.canonical_to_date('0001/01/01')) bal_load_date
from   pay_payroll_actions ppa
,      pay_action_classifications pac
where ppa.action_type = pac.action_type
and   pac.classification_name = 'SEQUENCED'
and   ppa.business_group_id = p_business_group_id;
--
l_dim_level     pay_balance_dimensions.dimension_level%type;
l_leg_code      per_business_groups_perf.legislation_code%type;
l_bg_id         per_business_groups_perf.business_group_id%type;
l_bal_load_date pay_balance_validation.balance_load_date%type;
l_rr_exists     number;
--
BEGIN
hr_utility.set_location('Entering: pay_balance_pkg.initialise_run_balance', 10);
--
-- we need to determine a legislation code; for core defined balances it will
-- be null.
--
if p_legislation_code is null then
  if p_business_group_id is null then
  -- core row
    l_leg_code := '';
    hr_utility.set_location('pay_balance_pkg.initialise_run_balance', 20);
  else -- bg not nulli, so user row
    hr_utility.set_location('pay_balance_pkg.initialise_run_balance', 30);
    --
    open get_leg_code(p_business_group_id);
    fetch get_leg_code into l_leg_code;
    if get_leg_code%notfound then
      close get_leg_code;
      -- should raise error, but should never be raised so ok
      hr_utility.set_location('pay_balance_pkg.initialise_run_balance', 40);
    end if;
  end if;
else -- leg row
  l_leg_code := p_legislation_code;
  hr_utility.set_location('pay_balance_pkg.initialise_run_balance', 50);
end if;
--
open get_dim_level(p_baldim_id);
fetch get_dim_level into l_dim_level;
close get_dim_level;
--
-- determine whether run results exist for this balance. If not then
-- use a bal load date of start of time, else use the max effective date for
-- the bg.
--
open check_run_results(p_bal_type_id);
fetch check_run_results into l_rr_exists;
close check_run_results;
--
if l_dim_level = 'ASG' or l_dim_level = 'GRP' then
hr_utility.set_location('pay_balance_pkg.initialise_run_balance', 70);
--
  for each_bg in enabled_bg(p_business_group_id, l_leg_code, l_dim_level)
  loop
  --
    if l_rr_exists = 1 then
      open bal_load_date(each_bg.business_group_id);
      fetch bal_load_date into l_bal_load_date;
      close bal_load_date;
    else
      l_bal_load_date := fnd_date.canonical_to_date('0001/01/01');
    end if;
    --
    hr_utility.set_location('pay_balance_pkg.initialise_run_balance', 80);
    hr_utility.trace('def_bal: '||to_char(p_defbal_id));
    hr_utility.trace('bg: '||to_char(each_bg.business_group_id));
    hr_utility.trace('bal_load_date: '||to_char(l_bal_load_date,'DD-MON-YYYY'));
    --
    insert into pay_balance_validation
    (BALANCE_VALIDATION_ID
    ,DEFINED_BALANCE_ID
    ,BUSINESS_GROUP_ID
    ,RUN_BALANCE_STATUS
    ,BALANCE_LOAD_DATE)
    select pay_balance_validation_s.nextval
    ,p_defbal_id
    ,each_bg.business_group_id
    ,'V'
    ,l_bal_load_date
    from dual
    where not exists (select 1
                      from pay_balance_validation
                      where defined_balance_id = p_defbal_id
                      and business_group_id = each_bg.business_group_id);
    --
    hr_utility.set_location('pay_balance_pkg.initialise_run_balance', 90);
    --
  end loop;
  hr_utility.set_location('pay_balance_pkg.initialise_run_balance', 100);
  --
else -- l_dim_level is null
--
-- this is not a valid run balance defined balance, so do nothing
--
hr_utility.set_location('pay_balance_pkg.initialise_run_balance', 110);
end if;
hr_utility.set_location('Leaving: pay_balance_pkg.initialise_run_balance', 120);
end initialise_run_balance;
--------------------------------------------------------------------------
-- procedure set_check_latest_balances
-- This procedure sets the HRASSACT CHECK_LATEST_BALANCES global
-- so that latest and run level balances ARE looked for
--------------------------------------------------------------------------
procedure set_check_latest_balances
is
--
begin
  g_debug := hr_utility.debug_enabled;
  if g_debug then
     hr_utility.set_location('Entering: pay_balance_pkg.set_check_latest_balances',5);
  end if;
--
   HRASSACT.CHECK_LATEST_BALANCES := TRUE;
--
  if g_debug then
     hr_utility.set_location('Exiting: pay_balance_pkg.set_check_latest_balances',5);
  end if;
--
end set_check_latest_balances;
--------------------------------------------------------------------------
-- procedure unset_check_latest_balances
-- This procedure sets the HRASSACT CHECK_LATEST_BALANCES global
-- so that latest and run level balances ARE NOT looked for
--------------------------------------------------------------------------
procedure unset_check_latest_balances
is
--
begin
  g_debug := hr_utility.debug_enabled;
  if g_debug then
     hr_utility.set_location('Entering: pay_balance_pkg.unset_check_latest_balances',5);
  end if;
--
   HRASSACT.CHECK_LATEST_BALANCES := FALSE;
--
  if g_debug then
     hr_utility.set_location('Exiting: pay_balance_pkg.unset_check_latest_balances',5);
  end if;
--
end unset_check_latest_balances;
--------------------------------------------------------------------------
--
--------------------------------------------------------------------------
-- procedure create_asg_balance
--------------------------------------------------------------------------
procedure create_asg_balance(p_def_bal_id in number
                            ,p_asgact_id  in number
                            ,p_load_type  in varchar2 default 'NORMAL'
                            ,p_bal_att    in varchar2 default NULL
                            ,p_eff_date   in date     default NULL
                            ,p_delta      in varchar2 default NULL)

is
--
begin
--
if g_debug then
  hr_utility.set_location('enter:pay_bal_pkg.create_asg_balance',10);
end if;
     create_all_asg_balances_full(p_asgact_id  => p_asgact_id
                                 ,p_load_type  => p_load_type
                                 ,p_def_bal    => p_def_bal_id
                                 ,p_bal_list   => p_bal_att
                                 ,p_eff_date   => p_eff_date
                                 ,p_delta      => p_delta
                                 );
--
if g_debug then
  hr_utility.set_location('leave:pay_bal_pkg.create_asg_balance',20);
end if;
end create_asg_balance;
--
--------------------------------------------------------------------------
-- procedure create_group_balance
--------------------------------------------------------------------------
procedure create_group_balance(p_def_bal_id in number
                              ,p_pact_id    in number
                              ,p_load_type  in varchar2 default 'NORMAL'
                              ,p_bal_att    in varchar2 default NULL
                              ,p_eff_date   in date     default NULL
                              ,p_delta      in varchar2 default NULL)
is
--
begin
--
if g_debug then
  hr_utility.set_location('Entering:pay_bal_pkg.create_group_balance',10);
end if;
--
     create_all_grp_balances_full(p_pact_id    => p_pact_id
                                 ,p_load_type  => p_load_type
                                 ,p_def_bal    => p_def_bal_id
                                 ,p_bal_list   => p_bal_att
                                 ,p_eff_date   => p_eff_date
                                 ,p_delta      => p_delta
                                 );
--
if g_debug then
  hr_utility.set_location('Leaving:pay_bal_pkg.create_group_balance',20);
end if;
end create_group_balance;
--
procedure maintain_balances_for_action(p_asg_action in number
                                      )
is
  cursor rev_rrs (revassactid number, p_si_needed varchar2, p_st_needed varchar2,
                  p_sn_needed varchar2, p_st2_needed varchar2,
                  p_sn2_needed varchar2, p_org_needed varchar2) is
  select prr.run_result_id,
         paa.tax_unit_id,
         prr.local_unit_id,
         prr.jurisdiction_code,
         prr.source_id original_entry_id,
         ppa.payroll_id,
         decode(p_si_needed,
              'Y', pay_balance_pkg.find_context('SOURCE_ID', prr.run_result_id),
              null)  source_id,
         decode(p_st_needed,
              'Y', pay_balance_pkg.find_context('SOURCE_TEXT', prr.run_result_id),
              null)  source_text,
         decode(p_sn_needed,
              'Y', pay_balance_pkg.find_context('SOURCE_NUMBER', prr.run_result_id),
              null)  source_number,
         decode(p_st2_needed,
              'Y', pay_balance_pkg.find_context('SOURCE_TEXT2', prr.run_result_id),
              null)  source_text2,
         decode(p_sn2_needed,
              'Y', pay_balance_pkg.find_context('SOURCE_NUMBER2', prr.run_result_id),
              null)  source_number2,
         decode(p_org_needed,
              'Y', pay_balance_pkg.find_context('ORGANIZATION_ID', prr.run_result_id),
              null)  organization_id,
         ppa.effective_date
    from pay_assignment_actions paa,
         pay_run_results        prr,
         pay_payroll_actions    ppa
   where paa.assignment_action_id = revassactid
     and ppa.payroll_action_id    = paa.payroll_action_id
     and paa.assignment_action_id = prr.assignment_action_id;
--
      l_rule_mode pay_legislation_rules.rule_mode%type;
      l_si_needed pay_legislation_rules.rule_mode%type;
      l_st_needed pay_legislation_rules.rule_mode%type;
      l_sn_needed pay_legislation_rules.rule_mode%type;
      l_sn2_needed pay_legislation_rules.rule_mode%type;
      l_org_needed pay_legislation_rules.rule_mode%type;
      l_st2_needed pay_legislation_rules.rule_mode%type;
      l_inp_val_name pay_input_values_f.name%type;
      l_asg_id     number;
      l_pactid     number;
      l_eff_date   date;
      l_act_type   pay_payroll_actions.action_type%type;
      lat_bal_maintenance boolean;
      l_src_iv    varchar2(30);
      l_src_num   varchar2(30);
      l_src_num2  varchar2(30);
      l_org_id_iv varchar2(30);
      l_iv_found  boolean;
      l_num_found boolean;
      l_value     pay_action_parameters.parameter_value%type;
      l_tax_group hr_organization_information.org_information5%type;
      l_bus_grp   per_business_groups_perf.business_group_id%type;
      leg_code   per_business_groups_perf.legislation_code%type;
      l_found    boolean;
      cxt_id number;

      udca      hrassact.context_details;


begin
   if g_debug then
      hr_utility.set_location('hrassact.reversal',50);
   end if;
--
   select paa.assignment_id,
          ppa.effective_date,
          ppa.payroll_action_id,
          ppa.action_type,
          ppa.business_group_id
     into l_asg_id,
          l_eff_date,
          l_pactid,
          l_act_type,
          l_bus_grp
     from pay_assignment_actions paa,
          pay_payroll_actions    ppa
    where paa.assignment_action_id = p_asg_action
      and ppa.payroll_action_id = paa.payroll_action_id;
--
   create_all_asg_balances(p_asgact_id => p_asg_action,
                           p_bal_list  =>  'ALL',
                           p_load_type =>  'NORMAL',
                           p_eff_date  =>  null,
                           p_delta     =>  null);
--
--
   if g_debug then
      hr_utility.set_location('hrassact.reversal',55);
   end if;
--
-- 2nd the group level run balances
--
   if g_debug then
      hr_utility.set_location('hrassact.reversal',60);
   end if;
--
If not hrassact.gv_multi_reversal then /*Bug 7652030 Not calling create_all_group_balances for Batch reversal*/
   pay_balance_pkg.create_all_group_balances(l_pactid,
                                             'ALL',
                                             'NORMAL',
                                             NULL,
                                             NULL);
end if;
--
--
--       Call to start of latest balance maintenance code
--
   if (l_act_type = 'V') then
      --
      -- check for REV_MAINTAIN_LAT_BAL legislation rule to see if
      -- this functionality is supported for this reversal
      --
      begin
         select parameter_value
         into l_value
         from pay_action_parameters pap
         where pap.parameter_name = 'REV_LAT_BAL';

         if upper(l_value) = 'Y' then
            lat_bal_maintenance := TRUE;
         else
            lat_bal_maintenance := FALSE;
         end if;
      exception
         when others then
            lat_bal_maintenance := FALSE;
      end;

      --
      -- Bug 6737896: Added pbg.legislation_code in the query to
      -- populate leg_code
      --
      if lat_bal_maintenance = TRUE then
         begin
            select rule_mode, pbg.legislation_code
            into l_rule_mode, leg_code
            from pay_legislation_rules plr,
                 per_business_groups_perf pbg
            where plr.legislation_code  = pbg.legislation_code
            and   rule_type             = 'BAL_ADJ_LAT_BAL'
            and   pbg.business_group_id = l_bus_grp;

            if upper(l_rule_mode) <> 'Y' then
               lat_bal_maintenance := FALSE;
            end if;
         exception
            when others then
               lat_bal_maintenance := FALSE;
         end;
      end if;
  end if;

  if lat_bal_maintenance = FALSE then
     --
     -- delete latest balances
     --
     if g_debug then
        hr_utility.set_location('hrassact.reversal', 70);
     end if;

     --
     -- NB could enhance to
     -- loop for each reversal run result and run
     -- del_latest_balances(l_asg_id, l_eff_date, null, l_element_type_id);
     -- to minimise loss of latest balances
     --
     hrassact.del_latest_balances(l_asg_id, l_eff_date, null);
  else
     --
     -- Support maintenance of latest balances
     --
     if g_debug then
        hr_utility.set_location('hrassact.reversal', 80);
     end if;
--
     hr_utility.trace('leg_code: '||leg_code);
     pay_core_utils.get_leg_context_iv_name('SOURCE_ID'
                                        ,leg_code
                                        ,l_src_iv
                                        ,l_iv_found);
     if (not l_iv_found) then
        l_src_iv := null;
     else
       l_si_needed := 'Y';
       hr_utility.trace('l_src_iv: '||l_src_iv);
     end if;
     --
     pay_core_utils.get_leg_context_iv_name('SOURCE_NUMBER'
                                        ,leg_code
                                        ,l_src_num
                                        ,l_num_found);
     if (not l_num_found) then
        l_src_num := null;
     else
        l_sn_needed := 'Y';
        hr_utility.trace('l_src_num: '||l_src_num);
     end if;
     --
     pay_core_utils.get_leg_context_iv_name('SOURCE_NUMBER2'
                                        ,leg_code
                                        ,l_src_num2
                                        ,l_num_found);
     if (not l_num_found) then
        l_src_num2 := null;
     else
        l_sn2_needed := 'Y';
        hr_utility.trace('l_src_num2: '||l_src_num2);
     end if;
     pay_core_utils.get_leg_context_iv_name('ORGANIZATION_ID'
                                        ,leg_code
                                        ,l_org_id_iv
                                        ,l_num_found);
     if (not l_num_found) then
        l_org_id_iv := null;
     else
        l_org_needed := 'Y';
        hr_utility.trace('l_org_id_iv: '||l_org_id_iv);
     end if;

     pay_core_utils.get_leg_context_iv_name('SOURCE_TEXT',
                                            leg_code,
                                            l_inp_val_name,
                                            l_found
                                           );
     if (l_found = TRUE) then
        l_st_needed := 'Y';
     end if;

     pay_core_utils.get_leg_context_iv_name('SOURCE_TEXT2',
                                            leg_code,
                                            l_inp_val_name,
                                            l_found
                                           );
     if (l_found = TRUE) then
        l_st2_needed := 'Y';
     end if;

     -- get TAX GROUP context value (for US and CA)
     if leg_code in ('US', 'CA') then
        begin

           if leg_code = 'US' then
              select hoi.org_information5
                into l_tax_group
                from hr_organization_information hoi,
                     pay_assignment_actions      paa
               where UPPER(hoi.org_information_context) = 'FEDERAL TAX RULES'
                 and hoi.organization_id = paa.tax_unit_id
                 and paa.assignment_action_id = p_asg_action
                 and hoi.org_information5 is not null;
           else
               select hoi.org_information4
                 into l_tax_group
                 from hr_organization_information hoi,
                      pay_assignment_actions      paa
                where UPPER(hoi.org_information_context) = 'CANADA EMPLOYER IDENTIFICATION'
                  and hoi.organization_id = paa.tax_unit_id
                  and paa.assignment_action_id = p_asg_action
                  and hoi.org_information4 is not null;
           end if;

        exception
           when no_data_found then
              l_tax_group := null;
        end;
     else
        l_tax_group := null;
     end if;

     for rr in rev_rrs(p_asg_action, l_si_needed, l_st_needed,
                       l_sn_needed, l_st2_needed, l_sn2_needed,
                       l_org_needed) loop

       -- Load the udca with the context values
       udca.sz := 1;
       hrassact.get_cache_context('PAYROLL_ID', cxt_id);
       udca.cxt_id(udca.sz)    := cxt_id;
       udca.cxt_name(udca.sz)  := 'PAYROLL_ID';
       udca.cxt_value(udca.sz) := rr.payroll_id;
       udca.sz := udca.sz + 1;
       hrassact.get_cache_context('ORIGINAL_ENTRY_ID', cxt_id);
       udca.cxt_id(udca.sz)    := cxt_id;
       udca.cxt_name(udca.sz)  := 'ORIGINAL_ENTRY_ID';
       udca.cxt_value(udca.sz) := rr.original_entry_id;
       if rr.tax_unit_id is not null then
          udca.sz := udca.sz + 1;
          hrassact.get_cache_context('TAX_UNIT_ID', cxt_id);
          udca.cxt_id(udca.sz)    := cxt_id;
          udca.cxt_name(udca.sz)  := 'TAX_UNIT_ID';
          udca.cxt_value(udca.sz) := rr.tax_unit_id;
       end if;
       if rr.jurisdiction_code is not null then
          udca.sz := udca.sz + 1;
          hrassact.get_cache_context('JURISDICTION_CODE', cxt_id);
          udca.cxt_id(udca.sz)    := cxt_id;
          udca.cxt_name(udca.sz)  := 'JURISDICTION_CODE';
          udca.cxt_value(udca.sz) := rr.jurisdiction_code;
       end if;
       if rr.source_id is not null then
          udca.sz := udca.sz + 1;
          hrassact.get_cache_context('SOURCE_ID', cxt_id);
          udca.cxt_id(udca.sz)    := cxt_id;
          udca.cxt_name(udca.sz)  := 'SOURCE_ID';
          udca.cxt_value(udca.sz) := rr.source_id;
       end if;
       if rr.source_text is not null then
          udca.sz := udca.sz + 1;
          hrassact.get_cache_context('SOURCE_TEXT', cxt_id);
          udca.cxt_id(udca.sz)    := cxt_id;
          udca.cxt_name(udca.sz)  := 'SOURCE_TEXT';
          udca.cxt_value(udca.sz) := rr.source_text;
       end if;
       if rr.source_text2 is not null then
          udca.sz := udca.sz + 1;
          hrassact.get_cache_context('SOURCE_TEXT2', cxt_id);
          udca.cxt_id(udca.sz)    := cxt_id;
          udca.cxt_name(udca.sz)  := 'SOURCE_TEXT2';
          udca.cxt_value(udca.sz) := rr.source_text2;
       end if;
       if rr.source_number is not null then
          udca.sz := udca.sz + 1;
          hrassact.get_cache_context('SOURCE_NUMBER', cxt_id);
          udca.cxt_id(udca.sz)    := cxt_id;
          udca.cxt_name(udca.sz)  := 'SOURCE_NUMBER';
          udca.cxt_value(udca.sz) := rr.source_number;
       end if;
       if rr.source_number2 is not null then
          udca.sz := udca.sz + 1;
          hrassact.get_cache_context('SOURCE_NUMBER2', cxt_id);
          udca.cxt_id(udca.sz)    := cxt_id;
          udca.cxt_name(udca.sz)  := 'SOURCE_NUMBER2';
          udca.cxt_value(udca.sz) := rr.source_number2;
       end if;
       if rr.organization_id is not null then
          udca.sz := udca.sz + 1;
          hrassact.get_cache_context('ORGANIZATION_ID', cxt_id);
          udca.cxt_id(udca.sz)    := cxt_id;
          udca.cxt_name(udca.sz)  := 'ORGANIZATION_ID';
          udca.cxt_value(udca.sz) := rr.organization_id;
       end if;
       if rr.local_unit_id is not null then
          udca.sz := udca.sz + 1;
          hrassact.get_cache_context('LOCAL_UNIT_ID', cxt_id);
          udca.cxt_id(udca.sz)    := cxt_id;
          udca.cxt_name(udca.sz)  := 'LOCAL_UNIT_ID';
          udca.cxt_value(udca.sz) := rr.local_unit_id;
       end if;
       if l_tax_group is not null then
          udca.sz := udca.sz + 1;
          hrassact.get_cache_context('TAX_GROUP', cxt_id);
          udca.cxt_id(udca.sz)    := cxt_id;
          udca.cxt_name(udca.sz)  := 'TAX_GROUP';
          udca.cxt_value(udca.sz) := l_tax_group;
       end if;

       -- call balance maintenance code

       hrassact.maintain_lat_bal(assactid => p_asg_action,
                        rrid     => rr.run_result_id,
                        eentryid => null,
                        effdate  => l_eff_date,
                        udca     => udca,
                        act_type => l_act_type);

     end loop;

   end if;
--
   if g_debug then
      hr_utility.set_location('Leaving: hrassact.reversal', 100);
   end if;

end maintain_balances_for_action;
--
begin
 g_payroll_action := -1;
 g_legislation_code := null;
end pay_balance_pkg;

/
