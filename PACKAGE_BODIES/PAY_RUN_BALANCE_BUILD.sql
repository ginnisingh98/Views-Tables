--------------------------------------------------------
--  DDL for Package Body PAY_RUN_BALANCE_BUILD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_RUN_BALANCE_BUILD" AS
/* $Header: pycorubl.pkb 120.6.12010000.1 2008/07/27 22:23:31 appldev ship $ */
--
--
/* Setup Glabals */
--
g_timeout       date;
g_def_bal_id    pay_defined_balances.defined_balance_id%type;
g_bal_lvl       pay_balance_dimensions.dimension_level%type;
g_proc_mode     varchar2(30);
g_load_type     varchar2(30);
g_save_run_bals pay_legislation_rules.rule_mode%type;
g_save_asg_run_bals pay_legislation_rules.rule_mode%type;
g_globals_set   boolean;
g_start_date    date;
g_bus_grp       number;
g_leg_code      varchar2(30);
g_att_name      varchar2(30);
--
----------------------------------------------------------------------
--
-- mark_run_balance_status
--
-- Description
--   This procedure sets the run_balance status
--
----------------------------------------------------------------------
procedure mark_run_balance_status(p_defined_balace_id in number,
                                  p_business_group_id in number,
                                  p_status            in varchar2,
                                  p_from_status       in varchar2)
is
    l_bal_valid_id pay_balance_validation.balance_validation_id%type;
    l_update boolean;
begin
--
  /* Can only set a valid status if the old status was processing */
  l_update := FALSE;
  if (p_status = 'V') then
    if (p_from_status = 'P') then
       l_update := TRUE;
    end if;
  else
    l_update := TRUE;
  end if;
--
  if (l_update = TRUE) then
     begin
--
       select balance_validation_id
         into l_bal_valid_id
         from pay_balance_validation
        where defined_balance_id = p_defined_balace_id
          and business_group_id = p_business_group_id;
--
        update pay_balance_validation
           set run_balance_status = p_status,
               balance_load_date = g_start_date
         where balance_validation_id = l_bal_valid_id;
--
     exception
       when no_data_found then
--
       insert into pay_balance_validation
                      (balance_validation_id,
                       defined_balance_id,
                       business_group_id,
                       run_balance_status,
                       balance_load_date)
       values ( pay_balance_validation_s.nextval,
                p_defined_balace_id,
                p_business_group_id,
                p_status,
                g_start_date);
--
     end;
  end if;
end mark_run_balance_status;
----------------------------------------------------------------------
--
-- set_run_bal_status
--
-- Description
--   This procedure sets the run_balance status
--
----------------------------------------------------------------------
procedure set_run_bal_status (p_pactid in number,
                              p_status in varchar2)
is
    cursor get_all_bals (p_pact_id in number
                        ) is
    select pdb.defined_balance_id,
           ppa.business_group_id,
           nvl(pay_core_utils.get_parameter('BAL_LVL',
                                            ppa.legislative_parameters),
               'BOTH') balance_level,
           pbd.dimension_level
      from pay_payroll_actions    ppa,
           per_business_groups    pbg,
           pay_defined_balances   pdb,
           pay_balance_dimensions pbd
     where ppa.payroll_action_id = p_pact_id
       and ppa.business_group_id = pbg.business_group_id
       and ((pdb.business_group_id = pbg.business_group_id
             and pdb.legislation_code is null)
           or
            (pdb.legislation_code = pbg.legislation_code
             and pdb.business_group_id is null)
           or
            (pdb.legislation_code is null
             and pdb.business_group_id is null)
          )
       and pdb.save_run_balance = 'Y'
       and pdb.balance_dimension_id = pbd.balance_dimension_id
       and ((pbd.dimension_level =
                  nvl(pay_core_utils.get_parameter('BAL_LVL',
                                                   ppa.legislative_parameters),
                      'BOTH'))
           or
            (nvl(pay_core_utils.get_parameter('BAL_LVL',
                                               ppa.legislative_parameters),
                 'BOTH')
                            = 'BOTH')
           );
--
 l_run_bal_stat pay_balance_validation.run_balance_status%type;
 l_bus_grp      pay_payroll_actions.business_group_id%type;
--
begin
--
  if (g_proc_mode <> 'SINGLE') then
    for dbrec in get_all_bals(p_pactid) loop
--
       -- Only change the status if the legislation
       -- rule allows the run balances to be created.
--
       if ((    dbrec.dimension_level = 'ASG'
            and g_save_asg_run_bals = 'Y')
           or
            (    dbrec.dimension_level = 'GRP'
            and g_save_run_bals = 'Y')
          ) then
--
         if (g_load_type <> 'DELTA') then
--
           select nvl(pbv.run_balance_status, 'I')
             into l_run_bal_stat
             from pay_defined_balances pdb,
                  pay_balance_validation pbv
            where pdb.defined_balance_id = dbrec.defined_balance_id
              and pbv.defined_balance_id (+) = pdb.defined_balance_id
              and pbv.business_group_id (+) = dbrec.business_group_id;
--
           if (g_proc_mode = 'INVALID' and l_run_bal_stat <> 'V') then
--
              mark_run_balance_status(dbrec.defined_balance_id,
                                      dbrec.business_group_id,
                                      p_status,
                                      l_run_bal_stat);
--
           elsif (g_proc_mode = 'ALL') then
--
             mark_run_balance_status(dbrec.defined_balance_id,
                                     dbrec.business_group_id,
                                     p_status,
                                     l_run_bal_stat);
--
           end if;
--
         else
--
            if (p_status = 'V') then
              update pay_balance_validation
                 set balance_load_date = g_start_date
               where dbrec.defined_balance_id = defined_balance_id
                 and dbrec.business_group_id = business_group_id;
            end if;
--
         end if;
      end if;
--
    end loop;
  else
--
    /* Single Balance load */
--
    select business_group_id
      into l_bus_grp
      from pay_payroll_actions
     where payroll_action_id = p_pactid;
--
    if (g_load_type <> 'DELTA') then
--
      select nvl(pbv.run_balance_status, 'I')
        into l_run_bal_stat
        from pay_defined_balances pdb,
             pay_balance_validation pbv
       where pdb.defined_balance_id = g_def_bal_id
         and pbv.defined_balance_id (+) = pdb.defined_balance_id
         and pbv.business_group_id (+) = l_bus_grp;
--
      mark_run_balance_status(g_def_bal_id,
                              l_bus_grp,
                              p_status,
                              l_run_bal_stat);
--
    else
--
       if (p_status = 'V') then
--
         update pay_balance_validation
            set balance_load_date = g_start_date
          where defined_balance_id = g_def_bal_id
            and business_group_id = l_bus_grp;
--
       end if;
--
    end if;
--
  end if;
--
end set_run_bal_status;
--
procedure set_globals(p_pact_id in number)
is
begin
--
  if (g_globals_set = FALSE) then
--
      g_globals_set := TRUE;
--
      /* Get parameters */
      select
             pay_core_utils.get_parameter('DEF_BAL_ID',
                                          pa1.legislative_parameters),
             nvl(pay_core_utils.get_parameter('BAL_LVL',
                                          pa1.legislative_parameters),
                 'BOTH'),
             nvl(pay_core_utils.get_parameter('PROC_MODE',
                                          pa1.legislative_parameters),
                 'ALL'),
             to_date(pay_core_utils.get_parameter('BAL_START_DATE',
                                          pa1.legislative_parameters),
                     'YYYY/MM/DD'),
             nvl(pay_core_utils.get_parameter('LOAD_TYPE',
                                          pa1.legislative_parameters),
                 'ALL'),
             pbg.legislation_code,
             pbg.business_group_id,
             'GEN_BAL_'||p_pact_id
        into
             g_def_bal_id,
             g_bal_lvl,
             g_proc_mode,
             g_start_date,
             g_load_type,
             g_leg_code,
             g_bus_grp,
             g_att_name
        from pay_payroll_actions    pa1,
             per_business_groups    pbg
       where pa1.payroll_action_id    = p_pact_id
         and pa1.business_group_id    = pbg.business_group_id;
--
      begin
        select rule_mode
          into g_save_run_bals
          from pay_legislation_rules
         where legislation_code = g_leg_code
           and rule_type = 'SAVE_RUN_BAL';
      exception
        when no_data_found then
           g_save_run_bals := 'N';
      end;
--
      begin
        select rule_mode
          into g_save_asg_run_bals
          from pay_legislation_rules
         where legislation_code = g_leg_code
           and rule_type = 'SAVE_ASG_RUN_BAL';
      exception
        when no_data_found then
           g_save_asg_run_bals := 'N';
      end;
--
      if (g_def_bal_id is not null) then
--
        -- Override the balance level for a single balance load
--
        select nvl(pbd.dimension_level, 'ASG')
          into g_bal_lvl
          from pay_defined_balances   pdb,
               pay_balance_dimensions pbd
         where pdb.defined_balance_id = g_def_bal_id
           and pdb.balance_dimension_id = pbd.balance_dimension_id;
--
        g_proc_mode := 'SINGLE';
--
      end if;
--
  end if;
--
end set_globals;
--
  /* Name      : calculate_delta_asg_balances
     Purpose   :
     Arguments :
     Notes     :
  */

procedure calculate_delta_asg_balances( p_asg_act_id in number,
                                        p_eff_date in date,
                                        p_bal_load_date in date
                                      )
is
--
type t_def_bal_id is table of pay_defined_balances.defined_balance_id%type
       index by binary_integer;
--
    l_delete_bals  boolean;
    l_def_bal_list pay_balance_pkg.t_balance_value_tab;
    l_def_bal_id   t_def_bal_id;
    l_delta        varchar2(10);
--
begin
--
hr_utility.set_location
          ('Entering: pay_run_balance_build.calculate_delta_asg_balnces', 10);
   if (g_proc_mode = 'SINGLE') then
--
     -- If we have been supplied with a start date then delete
     -- any run balance prior to this date.
--
     l_delete_bals := FALSE;
     if (g_start_date is not null
         and g_start_date > p_eff_date) then
         l_delete_bals := TRUE;
     end if;
--
     if (l_delete_bals) then
--
       delete /*+ INDEX(prb PAY_RUN_BALANCES_N2) */
         from pay_run_balances prb
        where prb.defined_balance_id = g_def_bal_id
          and prb.assignment_action_id = p_asg_act_id;
--
     else
     --
     -- Altered to use balance attributes
     --
       if g_load_type = 'DELTA' then
         l_delta := 'Y';
       else
         l_delta := 'N';
       end if;
       --
       if (p_eff_date < p_bal_load_date) then
         pay_balance_pkg.create_asg_balance(g_def_bal_id
                                           ,p_asg_act_id
                                           ,'FORCE'
                                           ,g_att_name
                                           ,p_eff_date
                                           ,l_delta);
       end if;
--
     end if;
--
  else
     -- If we have been supplied with a start date then delete
     -- any run balance prior to this date.
--
     l_delete_bals := FALSE;
     if (g_start_date is not null
         and g_start_date > p_eff_date) then
         l_delete_bals := TRUE;
     end if;
--
     if (l_delete_bals) then
       null;
--
     else
     --
       if g_load_type = 'DELTA' then
         l_delta := 'Y';
       else
         l_delta := 'N';
       end if;
       --
       pay_balance_pkg.create_all_asg_balances(p_asg_act_id
                                              ,g_att_name
                                              ,'FORCE'
                                              ,p_eff_date
                                              ,l_delta
                                              );
       --
     end if;
  end if;
--
hr_utility.set_location
          ('Leaving: pay_run_balance_build.calculate_delta_asg_balances', 100);
end calculate_delta_asg_balances;
--
  /* Name      : calculate_full_asg_balances
     Purpose   :
     Arguments :
     Notes     :
  */

procedure calculate_full_asg_balances( p_asg_act_id in number,
                                       p_eff_date in date
                                      )
is
    l_delete_bals boolean;
begin
--
--
hr_utility.set_location(
          'Enter:pay_run_balance_build.calculate_full_asg_balances',10);
--
   if (g_proc_mode = 'SINGLE') then
--
     -- If we have been supplied with a start date then delete
     -- any run balance prior to this date.
     --
     hr_utility.set_location(
               'pay_run_balance_build.calculate_full_asg_balances',20);
     --
     l_delete_bals := FALSE;
     if (g_start_date is not null
         and g_start_date > p_eff_date) then
         l_delete_bals := TRUE;
     end if;
--
     if (l_delete_bals) then
--
     --
     hr_utility.set_location(
               'pay_run_balance_build.calculate_full_asg_balances',30);

       --
       delete /*+ INDEX(prb PAY_RUN_BALANCES_N2) */
         from pay_run_balances prb
        where prb.defined_balance_id = g_def_bal_id
          and prb.assignment_action_id = p_asg_act_id;
--
     else
--
     --
     hr_utility.set_location(
               'pay_run_balance_build.calculate_full_asg_balances',40);
     --
       pay_balance_pkg.create_asg_balance(g_def_bal_id
                                         ,p_asg_act_id
                                         ,'FORCE'
                                         ,g_att_name);
--
     end if;
--
  else
    --
    hr_utility.set_location(
              'pay_run_balance_build.calculate_full_asg_balances',50);
     --
     -- If we have been supplied with a start date then delete
     -- any run balance prior to this date.
--
     l_delete_bals := FALSE;
     if (g_start_date is not null
         and g_start_date > p_eff_date) then
         l_delete_bals := TRUE;
     end if;
--
     if (l_delete_bals) then
     --
       hr_utility.set_location(
                 'pay_run_balance_build.calculate_full_asg_balances',60);
       null;
--
     else
     --
       hr_utility.set_location(
                 'pay_run_balance_build.calculate_full_asg_balances',70);
--
       pay_balance_pkg.create_all_asg_balances(p_asg_act_id,
                                 g_att_name,
                                 'TRUSTED'
                                );
     end if;
  end if;
--
--
hr_utility.set_location(
          'Leaving:pay_run_balance_build.calculate_full_asg_balances',80);
--
end calculate_full_asg_balances;
--
  /* Name      : process_asg_lvl_balances
     Purpose   :
     Arguments :
     Notes     :
  */

procedure process_asg_lvl_balances(p_asg_id in number,
                                   p_bus_grp in number)
is
--
    cursor getaa (p_assid in  number
                 ) is
    select /*+ ORDERED USE_NL(ppa prt)
           INDEX(ppa PAY_PAYROLL_ACTIONS_PK)
           INDEX(prt PAY_RUN_TYPES_PK) */
           paa.assignment_action_id,
           ppa.effective_date,
           nvl(prt.run_method, 'N') run_method,
           ppa.business_group_id,
           pbg.legislation_code
      from pay_assignment_actions      paa,
           pay_payroll_actions         ppa,
           pay_run_types_f             prt,
           per_business_groups_perf    pbg
     where paa.assignment_id = p_assid
       and paa.payroll_action_id = ppa.payroll_action_id
       and ppa.action_type in ('R', 'Q', 'V', 'B', 'I')
       and ppa.business_group_id = pbg.business_group_id
       and nvl(paa.run_type_id, -999) = prt.run_type_id (+)
       and ppa.effective_date between nvl(prt.effective_start_date, ppa.effective_date)
                                  and nvl(prt.effective_end_date, ppa.effective_date)
    order by 2;
--
l_run_bal_status pay_balance_validation.run_balance_status%type;
l_bal_load_date pay_balance_validation.balance_load_date%type;
begin
--
hr_utility.set_location('pay_run_balance_build.process_asg_lvl_balance',10);
--
   l_run_bal_status := 'V';
--
   if (g_proc_mode <> 'SINGLE') then
   --
   hr_utility.set_location('pay_run_balance_build.process_asg_lvl_balance',20);
   --
      if (g_proc_mode = 'INVALID') then
--
-- altered delete statement to use pay_balance_attributes rather than
-- pay_balance_validation to identify rows to be deleted
--
       delete /*+ USE_NL(prb) INDEX(prb PAY_RUN_BALANCES_N1) */
         from pay_run_balances prb
       where  prb.assignment_id = p_asg_id
       and    prb.defined_balance_id in
                              (select pba.defined_balance_id
                               from   pay_balance_attributes pba
                               ,      pay_bal_attribute_definitions bad
                               where  pba.attribute_id = bad.attribute_id
                               and    bad.attribute_name = g_att_name);
--
      else
--
        -- We must be regenerating all balances
--
        if (g_load_type <> 'DELTA') then
--
           delete /*+ INDEX(prb PAY_RUN_BALANCES_N1) */
             from pay_run_balances prb
            where prb.assignment_id = p_asg_id;
--
        else
--
           delete /*+ INDEX(prb PAY_RUN_BALANCES_N1) */
             from pay_run_balances prb
            where prb.assignment_id = p_asg_id
              and exists (select ''
                            from pay_balance_validation pbv
                           where pbv.defined_balance_id = prb.defined_balance_id
                             and pbv.business_group_id = p_bus_grp
                             and prb.effective_date < greatest(nvl(pbv.balance_load_date,
                                                               to_date('0001/01/01 00:00:00',
                                                                       'YYYY/MM/DD HH24:MI:SS')
                                                             ),
                                                           nvl(g_start_date,
                                                               to_date('0001/01/01 00:00:00',
                                                                       'YYYY/MM/DD HH24:MI:SS')
                                                             )
                                                          )
                          );
--
        end if;
--
      end if;
   else
   --
   hr_utility.set_location('pay_run_balance_build.process_asg_lvl_balance',20);
   --
   -- No need to delete the balance, but we do need to get the status
   --
       begin
--
         select balance_load_date,
                run_balance_status
           into l_bal_load_date,
                l_run_bal_status
           from pay_balance_validation
          where defined_balance_id = g_def_bal_id
            and business_group_id = p_bus_grp;
--
       exception
          when no_data_found then
              l_run_bal_status := 'I';
       end;
   end if;
--
   for aarec in getaa(p_asg_id) loop
    --
    hr_utility.set_location('pay_run_balance_build.process_asg_lvl_balance',30);
    --
    if (aarec.run_method <> 'C') then
    --
    --
    hr_utility.set_location('pay_run_balance_build.process_asg_lvl_balance',40);
    --
      if (g_load_type <> 'DELTA') then
      --
      --
      hr_utility.set_location(
                'pay_run_balance_build.process_asg_lvl_balance',50);
      --
        calculate_full_asg_balances( aarec.assignment_action_id,
                                     aarec.effective_date
                                   );
--
      else
--
     --
     hr_utility.set_location(
               'pay_run_balance_build.process_asg_lvl_balance',60);
     --
        if (l_run_bal_status = 'V') then
        --
        --
        hr_utility.set_location(
                  'pay_run_balance_build.process_asg_lvl_balance',70);
        --
           calculate_delta_asg_balances( aarec.assignment_action_id,
                                         aarec.effective_date,
                                         l_bal_load_date
                                       );
        end if;
--
      end if;
--
    end if;
   end loop;
--
--
hr_utility.set_location(
          'Leaving:pay_run_balance_build.process_asg_lvl_balance',80);
--
end process_asg_lvl_balances;
--
  /* Name      : calculate_delta_grp_balances
     Purpose   :
     Arguments :
     Notes     :
  */

procedure calculate_delta_grp_balances(p_pactid in number,
                                       p_eff_date in date,
                                       p_bus_grp in number,
                                       p_leg_code in varchar2,
                                       p_bal_load_date in date
                                      )
is
--
type t_def_bal_id is table of pay_defined_balances.defined_balance_id%type
       index by binary_integer;
--
    l_delete_bals  boolean;
    l_def_bal_list pay_balance_pkg.t_balance_value_tab;
    l_def_bal_id   t_def_bal_id;
    l_delta        varchar2(10);
begin
--
hr_utility.set_location
          ('Entering: pay_run_balance_build.calculate_delta_grp_balances', 10);
--
   if (g_proc_mode = 'SINGLE') then
--
        -- If we have been supplied with a start date then delete
        -- any run balance prior to this date.
--
        l_delete_bals := FALSE;
        if (g_start_date is not null
            and g_start_date > p_eff_date) then
            l_delete_bals := TRUE;
        end if;
--
        if (l_delete_bals) then
--
          delete from pay_run_balances
           where defined_balance_id = g_def_bal_id
             and payroll_action_id  = p_pactid;
--
        else
        --
        -- Altered to use balance_attributes
        --
          if g_load_type = 'DELTA' then
            l_delta := 'Y';
          else
            l_delta := 'N';
          end if;
          --
          if(p_eff_date < p_bal_load_date) then
             pay_balance_pkg.create_group_balance
                            (g_def_bal_id
                            ,p_pactid
                            ,'FORCE'
                            ,g_att_name
                            ,p_eff_date
                            ,l_delta);
          end if;
--
        end if;
   else
--
        -- If we have been supplied with a start date then delete
        -- any run balance prior to this date.
--
        l_delete_bals := FALSE;
        if (g_start_date is not null
            and g_start_date > p_eff_date) then
            l_delete_bals := TRUE;
        end if;
--
        if (l_delete_bals) then
--
          if (g_proc_mode = 'INVALID') then
--
            delete from pay_run_balances prb
             where prb.payroll_action_id  = p_pactid
               and exists (select ''
                             from pay_balance_validation pbv
                            where pbv.defined_balance_id =
                                           prb.defined_balance_id
                              and pbv.run_balance_status = 'P'
                              and pbv.business_group_id = p_bus_grp);
          else
--
            -- We must be regenerating all balances
--
            if (g_load_type <> 'DELTA') then
--
              delete from pay_run_balances
               where payroll_action_id  = p_pactid;
            else
              delete
                from pay_run_balances prb
               where prb.payroll_action_id  = p_pactid
                 and g_start_date is not null
                 and g_start_date > p_eff_date;
--
            end if;
          end if;
--
        else
        --
        -- Use call to create_all_grp_balances to take advantage of balance
        -- attributes
        --
          if g_load_type = 'DELTA' then
            l_delta := 'Y';
          else
            l_delta := 'N';
          end if;
          --
          pay_balance_pkg.create_all_group_balances
                         (p_pact_id   => p_pactid
                         ,p_bal_list  => g_att_name
                         ,p_load_type => 'FORCE'
                         ,p_eff_date  => p_eff_date
                         ,p_delta     => l_delta
                         );
        end if;
   end if;
hr_utility.set_location
          ('Leaving: pay_run_balance_build.calculate_delta_grp_balances', 100);
--
end calculate_delta_grp_balances;
--
  /* Name      : calculate_full_grp_balances
     Purpose   :
     Arguments :
     Notes     :
  */

procedure calculate_full_grp_balances( p_pactid in number,
                                       p_eff_date in date,
                                       p_bus_grp in number
                                      )
is
    l_delete_bals boolean;
begin
   if (g_proc_mode = 'SINGLE') then
--
        -- If we have been supplied with a start date then delete
        -- any run balance prior to this date.
--
        l_delete_bals := FALSE;
        if (g_start_date is not null
            and g_start_date > p_eff_date) then
            l_delete_bals := TRUE;
        end if;
--
        if (l_delete_bals) then
--
          delete from pay_run_balances
           where defined_balance_id = g_def_bal_id
             and payroll_action_id  = p_pactid;
--
        else
--
          pay_balance_pkg.create_group_balance
                         (g_def_bal_id
                         ,p_pactid
                         ,'FORCE'
                         ,g_att_name);
        end if;
   else
--
        -- If we have been supplied with a start date then delete
        -- any run balance prior to this date.
--
        l_delete_bals := FALSE;
        if (g_start_date is not null
            and g_start_date > p_eff_date) then
            l_delete_bals := TRUE;
        end if;
--
        if (l_delete_bals) then
--
          if (g_proc_mode = 'INVALID') then
--
            delete from pay_run_balances prb
             where prb.payroll_action_id  = p_pactid
               and exists (select ''
                             from pay_balance_validation pbv
                            where pbv.defined_balance_id = prb.defined_balance_id
                              and pbv.run_balance_status = 'P'
                              and pbv.business_group_id = p_bus_grp);
          else
--
          -- We must be regenerating all balances
--
            delete from pay_run_balances
             where payroll_action_id  = p_pactid;
          end if;
--
        else
--
          pay_balance_pkg.create_all_group_balances(p_pactid,
                                    g_att_name,
                                    'TRUSTED'
                                    );
        end if;
   end if;
--
end calculate_full_grp_balances;
--
  /* Name      : process_group_lvl_balances
     Purpose   :
     Arguments :
     Notes     :
  */

procedure process_group_lvl_balances( p_pactid in number)
is
    l_grp_eff_date date;
    l_bus_grp pay_payroll_actions.business_group_id%type;
    l_run_bal_status pay_balance_validation.run_balance_status%type;
    l_bal_load_date pay_balance_validation.balance_load_date%type;
    l_leg_code per_business_groups.legislation_code%type;
begin
--
 begin
   select ppa.effective_date,
          ppa.business_group_id,
          pbg.legislation_code
     into l_grp_eff_date,
          l_bus_grp,
          l_leg_code
     from pay_payroll_actions ppa,
          per_business_groups pbg
    where ppa.payroll_action_id = p_pactid
      and ppa.business_group_id = pbg.business_group_id;
 exception
 --
 -- Bug 4031667: If the payroll action no longer exists then continue without
 -- erroring and without attempting to process the payroll action.
 --
  when no_data_found then
   return;
 end;
--
      l_run_bal_status := 'V';
--
      if (g_proc_mode <> 'SINGLE') then
--
        if (g_proc_mode = 'INVALID') then
--
          delete /*+ INDEX(prb PAY_RUN_BALANCES_N4) */
            from pay_run_balances prb
           where prb.payroll_action_id = p_pactid
             and exists (select /*+ INDEX(pbv PAY_BALANCE_VALIDATION_UK1) */ ''
                           from pay_balance_validation pbv
                          where pbv.defined_balance_id = prb.defined_balance_id
                            and pbv.run_balance_status = 'P'
                            and pbv.business_group_id = l_bus_grp);
--
        else
--
          -- We must be regenerating all balances
--
          if (g_load_type <> 'DELTA') then
--
             delete /*+ INDEX(prb PAY_RUN_BALANCES_N4) */
               from pay_run_balances prb
              where prb.payroll_action_id = p_pactid;
--
          else
--
             delete /*+ INDEX(prb PAY_RUN_BALANCES_N4) */
               from pay_run_balances prb
              where prb.payroll_action_id = p_pactid
                and exists (select ''
                              from pay_balance_validation pbv
                             where pbv.defined_balance_id = prb.defined_balance_id
                               and pbv.business_group_id = l_bus_grp
                               and prb.effective_date < greatest(nvl(pbv.balance_load_date,
                                                                 to_date('0001/01/01 00:00:00',
                                                                         'YYYY/MM/DD HH24:MI:SS')
                                                               ),
                                                             nvl(g_start_date,
                                                                 to_date('0001/01/01 00:00:00',
                                                                         'YYYY/MM/DD HH24:MI:SS')
                                                               )
                                                            )
                            );
--
          end if;
--
        end if;
--
      else
        -- No need to delete the balance, but we do need to get the status
--
        begin
--
          select balance_load_date,
                 run_balance_status
            into l_bal_load_date,
                 l_run_bal_status
            from pay_balance_validation
           where defined_balance_id = g_def_bal_id
             and business_group_id = l_bus_grp;
--
        exception
           when no_data_found then
               l_run_bal_status := 'I';
        end;
--
      end if;
--
      if (g_load_type <> 'DELTA') then
--
        calculate_full_grp_balances( p_pactid,
                                     l_grp_eff_date,
                                     l_bus_grp
                                   );
--
      else
--
        if (l_run_bal_status = 'V') then
--
           calculate_delta_grp_balances( p_pactid,
                                         l_grp_eff_date,
                                         l_bus_grp,
                                         l_leg_code,
                                         l_bal_load_date
                                       );
        end if;
--
      end if;
--
end process_group_lvl_balances;
--
  /* Name      : action_achive_data
     Purpose   : This performs the US specific employee context setting for the
                 Tax Remittance Archiver and for the payslip,check writer and
                 Deposit Advice modules.
     Arguments :
     Notes     :
  */

  PROCEDURE action_archive_data( p_assactid in number
                                ,p_effective_date in date)
  IS
--
    cursor getaa (p_assactid in  number
                 ) is
    select paa.assignment_action_id,
           ppa.effective_date,
           nvl(prt.run_method, 'N') run_method,
           ppa.business_group_id
      from pay_assignment_actions paa,
           pay_payroll_actions    ppa,
           pay_run_types_f        prt,
           pay_assignment_actions paa_arch
     where paa_arch.assignment_action_id = p_assactid
       and paa_arch.assignment_id = paa.assignment_id
       and paa.payroll_action_id = ppa.payroll_action_id
       and ppa.action_type in ('R', 'Q', 'V', 'B', 'I')
       and nvl(paa.run_type_id, -999) = prt.run_type_id (+)
       and ppa.effective_date between nvl(prt.effective_start_date, ppa.effective_date)
                                  and nvl(prt.effective_end_date, ppa.effective_date)
    order by 2;
--
    load_bals boolean;
    current_date date;
    l_payroll_action_id number;
    l_object_id number;
    l_delete_bals boolean;
    l_grp_eff_date date;
    l_bus_grp pay_payroll_actions.business_group_id%type;
    l_asg_id pay_assignment_actions.assignment_id%type;
--
  BEGIN
hr_utility.set_location(
          'Entering:pay_run_balance_build.action_archive_data',10);
--
    select paa.payroll_action_id,
           paa.object_id,
           paa.assignment_id,
           ppa.business_group_id
      into l_payroll_action_id, l_object_id, l_asg_id, l_bus_grp
      from pay_assignment_actions paa,
           pay_payroll_actions    ppa
     where paa.assignment_action_id = p_assactid
       and ppa.payroll_action_id = paa.payroll_action_id;
--
    set_globals(l_payroll_action_id);
--
    --
    hr_utility.set_location(
              'pay_run_balance_build.action_archive_data',20);
    --
    /* Have we timed out */
    select sysdate
      into current_date
      from sys.dual;
--
    if (current_date > g_timeout) then
      /* Error, timed out process */
      hr_utility.set_message(801,'PAY_289014_PUR_TIMEOUT');
      hr_utility.raise_error;
    end if;
--
    /* do we need to  load assignment balances */
    load_bals := TRUE;
--
    if (load_bals) then
--
    --
    hr_utility.set_location(
              'pay_run_balance_build.action_archive_data',30);
    --
      if (g_bal_lvl = 'GRP') then
--
      --
      hr_utility.set_location(
                'pay_run_balance_build.action_archive_data',40);
      --
        /* Only do something if the legislation rule is set */
        if (g_save_run_bals = 'Y') then
--
        --
        hr_utility.set_location(
                  'pay_run_balance_build.action_archive_data',50);
        --
          process_group_lvl_balances(l_object_id);
--
        end if;
      else
--
      --
      hr_utility.set_location(
               'pay_run_balance_build.action_archive_data',60);
      --
        /* Only do something if the legislation rule is set */
        if (g_save_asg_run_bals = 'Y') then
--
        --
        hr_utility.set_location(
                  'pay_run_balance_build.action_archive_data',70);
        --
          process_asg_lvl_balances(l_asg_id,
                                   l_bus_grp);
--
        end if;
      end if;
--
      --
      hr_utility.set_location(
                'pay_run_balance_build.action_archive_data',80);
      --
    end if;
--
  --
  hr_utility.set_location(
            'Leaving:pay_run_balance_build.action_archive_data',90);
  --
  END action_archive_data;


  /* Name      : generate_attribute
     Purpose   : This generates the attribute to process in the generation.
     Arguments :
     Notes     :
  */

  PROCEDURE generate_attribute( p_payroll_action_id in number)
  is
    cursor get_grp (p_bus_grp_id in number,
                    p_leg_code   in varchar2,
                    p_bal_list   in varchar2,
                    p_def_bal    in number)
    is
     select
            pdb.defined_balance_id
       from
            pay_balance_types      pbt,
            pay_defined_balances   pdb,
            pay_balance_dimensions pbd
      where pbd.dimension_level = 'GRP'
        and pdb.save_run_balance = 'Y'
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
            );
--
    cursor get_asg (p_bus_grp_id in number,
                    p_leg_code   in varchar2,
                    p_bal_list   in varchar2,
                    p_def_bal    in number)
    is
     select
            pdb.defined_balance_id
       from
            pay_balance_types    pbt,
            pay_defined_balances pdb,
            pay_balance_dimensions pbd
      where pbd.dimension_level = 'ASG'
        and pdb.save_run_balance = 'Y'
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
            );
--
  l_attribute_name pay_bal_attribute_definitions.attribute_name%type;
  l_attribute_id   pay_bal_attribute_definitions.attribute_id%type;
  begin
--
-- Use for both DELTA and NON DELTA modes
--
         l_attribute_name := 'GEN_BAL_'||p_payroll_action_id;
--
         select pay_bal_attribute_definition_s.nextval
           into l_attribute_id
           from dual;
--
         insert into pay_bal_attribute_definitions
           (attribute_id,
            attribute_name,
            alterable,
            business_group_id)
         values (l_attribute_id,
                 l_attribute_name,
                 'N',
                 g_bus_grp);
--
       if (   g_bal_lvl = 'GRP'
           or g_bal_lvl = 'BOTH') then
--
          for grprec in get_grp (g_bus_grp,
                                 g_leg_code,
                                 g_proc_mode,
                                 g_def_bal_id) loop
--
            insert into pay_balance_attributes
               (balance_attribute_id,
                attribute_id,
                defined_balance_id
               )
            values
               (pay_balance_attributes_s.nextval,
                l_attribute_id,
                grprec.defined_balance_id
               );
--
          end loop;
--
       end if;
--
       if (   g_bal_lvl = 'ASG'
           or g_bal_lvl = 'BOTH') then
--
          for asgrec in get_asg (g_bus_grp,
                                 g_leg_code,
                                 g_proc_mode,
                                 g_def_bal_id) loop
--
            insert into pay_balance_attributes
               (balance_attribute_id,
                attribute_id,
                defined_balance_id
               )
            values
               (pay_balance_attributes_s.nextval,
                l_attribute_id,
                asgrec.defined_balance_id
               );
--
          end loop;
--
       end if;
--
--
  end generate_attribute;
--
  /* Name      : action_range_cursor
     Purpose   : This returns the select statement that is used to created the
                 range rows for the Tax Filing (FLS) Archiver.
     Arguments :
     Notes     :
  */

  PROCEDURE action_range_cursor( p_payroll_action_id in number
                              ,p_sqlstr           out nocopy varchar2)
  IS
--
    lv_sql_string  VARCHAR2(32000);
  begin
      hr_utility.trace('In Range cursor before building string ');
--
      set_globals(p_payroll_action_id);
      set_run_bal_status(p_payroll_action_id, 'P');
--
      lv_sql_string :=
'select 1
   from dual
  where 1 = 0
    and 1 = :payroll_action_id';
--
      /* Only do something meaningful if the legislation rule is set */
      if (g_bal_lvl = 'GRP') then
        if (g_save_run_bals = 'Y') then
         lv_sql_string :=
'select ppa_r.payroll_action_id
   from pay_payroll_actions    ppa,
        pay_payroll_actions    ppa_r
  where ppa.payroll_action_id = :payroll_action_id
    and ppa_r.action_type in (''R'',''Q'',''B'', ''I'',''V'')
    and ppa.business_group_id = ppa_r.business_group_id
order by ppa_r.payroll_action_id';
        end if;
      else
        if (g_save_asg_run_bals = 'Y') then
          lv_sql_string :=
'select distinct asg.person_id
   from
        per_periods_of_service pos,
        per_assignments_f      asg,
        pay_payroll_actions    ppa
  where ppa.payroll_action_id = :payroll_action_id
    and pos.person_id         = asg.person_id
    and pos.period_of_service_id = asg.period_of_service_id
    and pos.business_group_id = ppa.business_group_id
    and asg.business_group_id = ppa.business_group_id
order by asg.person_id';
        end if;
      end if;
--
      p_sqlstr := lv_sql_string;
      hr_utility.trace('In Range cursor after building string ');
--
      hr_utility.trace('Build Bal Attribute Group');
--
      generate_attribute(p_payroll_action_id);
--
      hr_utility.trace('Built Bal Attribute Group');

  END action_range_cursor;


 /* Name    : action_action_creation
  Purpose   : This creates the assignment actions for a specific chunk
              of people to be archived by the year end pre-process.
  Arguments :
  Notes     :
 */

  PROCEDURE action_action_creation( p_payroll_action_id   in number
                                 ,p_start_person_id in number
                                 ,p_end_person_id   in number
                                 ,p_chunk               in number)
  IS
--
   cursor get_pact(stpactid  in number,
                   enpactid  in number,
                   pact_id   in number
                  ) is
      select ppa.payroll_action_id
      from pay_payroll_actions ppa,
           pay_payroll_actions ppa_arc
      where  ppa.payroll_action_id between stpactid and enpactid
        and  ppa_arc.payroll_action_id = pact_id
        and  ppa.business_group_id = ppa_arc.business_group_id
        and  ppa.action_type in ('R', 'Q', 'B', 'I', 'V')
      order by 1;
--
   cursor get_asg( stperson   in number
                  ,endperson     in number
                  , pact_id      in number
                 ) is
      select distinct
             paf.assignment_id assignment_id,
             paf.person_id
      from
             per_periods_of_service     pos,
             per_all_assignments_f      paf,
             pay_payroll_actions        ppa
      where pos.person_id between stperson and endperson
        and pos.person_id         = paf.person_id
        and pos.period_of_service_id = paf.period_of_service_id
        and pos.business_group_id = ppa.business_group_id
        and  ppa.payroll_action_id = pact_id
        and  ppa.business_group_id = paf.business_group_id
      order by 1, 2;
--
    ln_lockingactid number;
--
  begin
--
      hr_utility.trace('In action Creation before getting payroll information');
--
      set_globals(p_payroll_action_id);
--
      if (g_bal_lvl = 'GRP') then
        for pactrec in get_pact( p_start_person_id,
                              p_end_person_id,
                              p_payroll_action_id
                              ) loop
--
           select pay_assignment_actions_s.nextval
             into   ln_lockingactid
             from   dual;
--
           -- insert into pay_assignment_actions.
           hr_nonrun_asact.insact(ln_lockingactid,
                                  -1,
                                  p_payroll_action_id,
                                  p_chunk,
                                  null,
                                  null,
                                  'U',
                                  null,
                                  pactrec.payroll_action_id,
                                  'PPA');
--
        end loop;
      else
        for aarec in get_asg( p_start_person_id,
                              p_end_person_id,
                              p_payroll_action_id
                              ) loop
--
           select pay_assignment_actions_s.nextval
             into   ln_lockingactid
             from   dual;
--
           -- insert into pay_assignment_actions.
           hr_nonrun_asact.insact(ln_lockingactid,
                                  aarec.assignment_id,
                                  p_payroll_action_id,
                                  p_chunk,
                                  null,
                                  null,
                                  'U',
                                   null);
--
        end loop;
      end if;
--
   end action_action_creation;

 /* Name      : action_archinit
    Purpose   : This performs the context initialization.
    Arguments :
    Notes     :
 */

 procedure action_archinit(p_payroll_action_id in number) is
--
l_timeout_sec number;
current_time  date;
--
begin
--
      /* Get Action Parameters */
      declare
      begin
--
         select to_number(parameter_value),
                sysdate
           into l_timeout_sec,
                current_time
           from pay_action_parameters
          where parameter_name = 'PROCESS_TIMEOUT';
--
         --
         -- l_timeout_sec is in minutes, convert to seconds
         -- then convert to oracle time.
         --
         l_timeout_sec := l_timeout_sec * 60;
         l_timeout_sec := l_timeout_sec/86400;
         g_timeout := current_time + l_timeout_sec;
--
      exception
         when no_data_found then
           l_timeout_sec := null;
           g_timeout := to_date('4712/12/31', 'YYYY/MM/DD');
      end;
--
end action_archinit;
--
  /* Name      : deinitialise
     Purpose   : This procedure simply removes all the actions processed
                 in this run
     Arguments :
     Notes     :
  */
  procedure deinitialise (pactid in number)
  is
--
    cursor getpa (p_pact_id in number) is
    select ppa.payroll_action_id ,
           ppa.action_sequence,
           ppa.effective_date,
           ppa.business_group_id
      from
           pay_payroll_actions    ppa_arch,
           pay_payroll_actions    ppa
     where ppa_arch.payroll_action_id = p_pact_id
       and ppa_arch.business_group_id = ppa.business_group_id
       and ppa.action_type in ('R', 'Q', 'V', 'B', 'I')
    order by 2;
--
  remove_act varchar2(10);
  act_com    number;
  load_bals  boolean;
  cnt        number;
  l_delete_bals boolean;
  begin
--
      set_globals(pactid);
--
      hr_utility.set_location('pay_run_balance_build.deinitialise', 10);
      /* only do something if the legislation rule is set */
      if (g_save_run_bals = 'Y') then
        /* do we need to  load assignment balances */
        hr_utility.set_location('pay_run_balance_build.deinitialise', 20);
        load_bals := TRUE;
        if (g_proc_mode = 'SINGLE') then
            load_bals := FALSE;
        elsif (g_bal_lvl = 'GRP') then
          load_bals := FALSE;
        end if;
--
        cnt := 0;
        if (load_bals) then
--
          hr_utility.set_location('pay_run_balance_build.deinitialise', 30);
--
          if (g_bal_lvl = 'BOTH') then
            hr_utility.set_location('pay_run_balance_build.deinitialise', 40);
            for parec in getpa(pactid) loop
              hr_utility.set_location('pay_run_balance_build.deinitialise', 50);
--
              process_group_lvl_balances(parec.payroll_action_id);
--
            end loop;
          end if;
--
        end if;
      end if;
--
        hr_utility.set_location('pay_run_balance_build.deinitialise', 60);
--
        /* Remove the actions if needed */
        select count(*)
          into act_com
          from pay_assignment_actions
         where payroll_action_id = pactid
           and action_status <> 'C';
--
        if act_com = 0 then
--
          /* Set the Balance Status */
--
          set_run_bal_status(pactid, 'V');
--
          select pay_core_utils.get_parameter('REMOVE_ACT',
                                              pa1.legislative_parameters)
            into remove_act
            from pay_payroll_actions    pa1
           where pa1.payroll_action_id    = pactid;
--
          if (remove_act is null or remove_act = 'Y') then
             pay_archive.remove_report_actions(pactid);
--
--
             delete from pay_balance_attributes
              where attribute_id in (select attribute_id
                                       from pay_bal_attribute_definitions
                                      where attribute_name = g_att_name
                                     );
             delete from pay_bal_attribute_definitions
              where attribute_name = g_att_name;
          end if;
        end if;
--
--hr_utility.trace_off;
  end deinitialise;
--
begin
  g_globals_set := FALSE;
end pay_run_balance_build;

/
