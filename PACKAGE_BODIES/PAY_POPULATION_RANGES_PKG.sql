--------------------------------------------------------
--  DDL for Package Body PAY_POPULATION_RANGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_POPULATION_RANGES_PKG" as
/* $Header: pycoppr.pkb 120.6.12010000.1 2008/07/27 22:22:50 appldev ship $ */
--
-- Setup Globals
--
g_use_person_id boolean;
g_multi_object  boolean;
g_chunk_shuffle boolean;

/*

    remove_existing_ranges

    Remove any data from an errored range build.

*/
procedure remove_existing_ranges(p_payroll_action_id in number)
is
l_dummy number;
begin
--
   pay_proc_logging.PY_ENTRY('pay_population_ranges_pkg.remove_existing_ranges');
--
   SELECT 1
   into   l_dummy
   FROM   SYS.DUAL
   WHERE  EXISTS (
          SELECT NULL
          FROM   PAY_ASSIGNMENT_ACTIONS ACT
          WHERE  ACT.PAYROLL_ACTION_ID = p_payroll_action_id)
   OR     EXISTS (
          SELECT NULL
          FROM   PAY_MESSAGE_LINES PML
          WHERE  PML.SOURCE_TYPE = 'P'
          AND    PML.SOURCE_ID   = p_payroll_action_id)
   OR     EXISTS (
          SELECT NULL
          FROM   PAY_POPULATION_RANGES POP
          WHERE  POP.PAYROLL_ACTION_ID = p_payroll_action_id);
--
   --
   -- OK, we've found rows, need to remove them
   --
   py_rollback_pkg.rollback_payroll_action(p_payroll_action_id,'ROLLBACK',TRUE);
--
   pay_proc_logging.PY_EXIT('pay_population_ranges_pkg.remove_existing_ranges');
--
exception
    when no_data_found then
       pay_proc_logging.PY_EXIT(
             'pay_population_ranges_pkg.remove_existing_ranges');
       null;
--
end remove_existing_ranges;
--
/*
     set_range_globals

     Set the internal globals
*/

procedure set_range_globals(p_payroll_action_id in     number,
                            p_action_type       in     varchar
                           )
is
l_range_person pay_legislation_rules.rule_mode%type;
l_max_pinp pay_legislation_rules.rule_mode%type;
l_chunk_shuffle pay_legislation_rules.rule_mode%type;
l_found boolean;
begin
--
    pay_proc_logging.PY_ENTRY('pay_population_ranges_pkg.set_range_globals');
--
    pay_core_utils.get_action_parameter(p_para_name  => 'RANGE_PERSON_ID',
                                        p_para_value => l_range_person,
                                        p_found      => l_found);
--
    if (l_found = FALSE) then
       l_range_person := 'N';
    end if;

    if (l_range_person = 'Y') then
      g_use_person_id := TRUE;
    else
      g_use_person_id := FALSE;
    end if;
--
    g_multi_object := TRUE;
--
    -- MANY_PROCS_IN_PERIOD switches on RANGE_PERSON_ID for Core Interlocking
    -- processes

    if (
        p_action_type = pay_proc_environment_pkg.PYG_AT_MAG or
        p_action_type = pay_proc_environment_pkg.PYG_AT_CHQ or
        p_action_type = pay_proc_environment_pkg.PYG_AT_CSH or
        p_action_type = pay_proc_environment_pkg.PYG_AT_PST
       ) then
--
       g_use_person_id := TRUE;
       pay_proc_logging.PY_LOG('Override RANGE_PERSON_ID  set to Y');
--
    elsif (p_action_type = pay_proc_environment_pkg.PYG_AT_PAY or
        p_action_type = pay_proc_environment_pkg.PYG_AT_COS or
        p_action_type = pay_proc_environment_pkg.PYG_AT_TGL) then

       pay_core_utils.get_action_parameter(p_para_name  => 'MANY_PROCS_IN_PERIOD',
                                           p_para_value => l_max_pinp,
                                           p_found      => l_found);

       if (l_found = FALSE) then
          l_max_pinp := 'N';
       end if;

       if (l_max_pinp = 'Y') then
         g_use_person_id := TRUE;
       end if;
--
    end if;
--
    if (p_action_type = pay_proc_environment_pkg.PYG_AT_ARC) then
--
      pay_core_utils.get_report_f_parameter(
                   p_payroll_action_id =>p_payroll_action_id,
                   p_para_name  => 'RANGE_PERSON_ID',
                   p_para_value => l_range_person,
                   p_found      => l_found);

      if (l_found = FALSE) then
         l_range_person := 'N';
      end if;
--
      if (l_range_person = 'M') then
          g_use_person_id := TRUE;
      elsif (    l_range_person = 'Y'
             and g_use_person_id = TRUE) then
          g_use_person_id := TRUE;
      else
          g_use_person_id := FALSE;
      end if;
--
      pay_core_utils.get_report_f_parameter(
                   p_payroll_action_id =>p_payroll_action_id,
                   p_para_name  => 'MULTI_OBJECT_ACTIONS',
                   p_para_value => l_range_person,
                   p_found      => l_found);
--
      if (l_found = FALSE) then
         l_range_person := 'N';
      end if;
--
      if (l_range_person = 'Y') then
          g_multi_object := TRUE;
      else
          g_multi_object := FALSE;
      end if;
--
    end if;
--
    pay_core_utils.get_action_parameter(p_para_name  => 'CHUNK SHUFFLE',
                                        p_para_value => l_chunk_shuffle,
                                        p_found      => l_found);
--
    if (l_found = FALSE) then
       l_chunk_shuffle := 'N';
    end if;
--
    if (l_chunk_shuffle = 'Y') then
      g_chunk_shuffle := TRUE;
    else
      g_chunk_shuffle := FALSE;
    end if;
--
    pay_proc_logging.PY_EXIT('pay_population_ranges_pkg.set_range_globals');
--
end set_range_globals;

/*
     get_range_statement

     Generates the appropriate SQL to create the ranges

*/

procedure get_range_statement(p_payroll_action_id in number,
                              p_statement         out nocopy varchar2)
is
action pay_payroll_actions.action_type%type;
sqlid number;
len number;
begin
--
  pay_proc_logging.PY_ENTRY('pay_population_ranges_pkg.get_range_statement');
--
  action := pay_proc_environment_pkg.action_type;
--
  if (pay_proc_environment_pkg.action_type =
                pay_proc_environment_pkg.PYG_AT_RET or
      pay_proc_environment_pkg.action_type =
                pay_proc_environment_pkg.PYG_AT_RTA) then

       sqlid := SQL_RUNRGE;

  elsif (pay_proc_environment_pkg.action_type =
                pay_proc_environment_pkg.PYG_AT_RTE) then

     if (pay_proc_environment_pkg.retro_definition_id is null) then
       sqlid := SQL_RUNRGE;
     else
       sqlid := SQL_RETRGE;
     end if;

  elsif (pay_proc_environment_pkg.action_type =
               pay_proc_environment_pkg.PYG_AT_RUN) then

       sqlid := SQL_RUNRGE;

  elsif (pay_proc_environment_pkg.action_type =
               pay_proc_environment_pkg.PYG_AT_ADV) then

       sqlid := SQL_RUNRGE;

  elsif (pay_proc_environment_pkg.action_type =
               pay_proc_environment_pkg.PYG_AT_ADE) then

       sqlid := SQL_RUNRGE;

  elsif (pay_proc_environment_pkg.action_type =
               pay_proc_environment_pkg.PYG_AT_ARC) then

       sqlid := SQL_RUNRGE;

  elsif (pay_proc_environment_pkg.action_type =
               pay_proc_environment_pkg.PYG_AT_PUR) then

       sqlid := SQL_PURRGE;

  elsif (pay_proc_environment_pkg.action_type =
               pay_proc_environment_pkg.PYG_AT_BEE) then

       sqlid := SQL_RUNRGE;

  elsif (pay_proc_environment_pkg.action_type =
               pay_proc_environment_pkg.PYG_AT_BAL) then

       sqlid := SQL_RUNRGE;

  elsif (pay_proc_environment_pkg.action_type =
               pay_proc_environment_pkg.PYG_AT_REV) then

       sqlid := SQL_RUNRGE;

  elsif (pay_proc_environment_pkg.action_type =
               pay_proc_environment_pkg.PYG_AT_RCS or
            pay_proc_environment_pkg.action_type =
               pay_proc_environment_pkg.PYG_AT_ECS) then

       if (pay_proc_environment_pkg.payroll_id is null) then
         sqlid := SQL_NONRGE;
       else
         sqlid := SQL_RESRGE;
       end if;

  else
       if (pay_proc_environment_pkg.action_type <>
                 pay_proc_environment_pkg.PYG_AT_CHQ and
           pay_proc_environment_pkg.action_type <>
                 pay_proc_environment_pkg.PYG_AT_MAG and
           pay_proc_environment_pkg.action_type <>
                 pay_proc_environment_pkg.PYG_AT_PST and
           pay_proc_environment_pkg.action_type <>
                 pay_proc_environment_pkg.PYG_AT_CSH and
           pay_proc_environment_pkg.action_type <>
                 pay_proc_environment_pkg.PYG_AT_PRU) then
--
          action := 'R';
--
       end if;
--
       if (pay_proc_environment_pkg.payroll_id is null) then
         sqlid := SQL_NONRGE;
       else
         sqlid := SQL_RESRGE;
       end if;
   end if;
--
   hr_dynsql.pyrsql(sqlid,null,null,p_statement,len,action,p_payroll_action_id);
--
   pay_proc_logging.PY_EXIT('pay_population_ranges_pkg.get_range_statement');
--
end get_range_statement;
--
/*
   do_randomisation

   Randomises the chunks to process in different orders every run.

*/
procedure do_randomisation(p_payroll_action_id in number,
                           p_chunk_number in number)
is
--
type t_pay_act_id_tab IS TABLE OF pay_population_ranges.payroll_action_id%type
     index by binary_integer;
type t_chunk_num_tab IS TABLE OF pay_population_ranges.chunk_number%type
     index by binary_integer;
type t_person_id_tab IS TABLE OF pay_population_ranges.payroll_action_id%type
     index by binary_integer;
--
l_pay_act_tab t_person_id_tab;
l_chunk_num_tab t_chunk_num_tab;
l_rand_chunk_num_tab t_chunk_num_tab;
--
rand_num number;
loop_count number;
--
begin
--
  pay_proc_logging.PY_ENTRY('pay_population_ranges_pkg.do_randomisation');
--
  l_pay_act_tab.delete;
  l_chunk_num_tab.delete;
  l_rand_chunk_num_tab.delete;

  for i in 1..p_chunk_number loop
     l_chunk_num_tab(i) := i;
     l_rand_chunk_num_tab(i) := 0;
     l_pay_act_tab(i) := p_payroll_action_id;
  end loop;
--
  for i in 1..p_chunk_number loop
--
    select (mod(fnd_crypto.SmallRandomNumber,p_chunk_number-1)+1)
    into rand_num
    from dual;

    loop_count := 0;
--
    -- Look for an unset random chunk
    while (   l_rand_chunk_num_tab(rand_num) <> 0
          and loop_count <= p_chunk_number) loop
--
       if (rand_num = p_chunk_number) then
          rand_num := 1;
       else
          rand_num := rand_num +1;
       end if;
       loop_count := loop_count + 1;
--
    end loop;
--
    if (loop_count > p_chunk_number) then
       pay_core_utils.assert_condition('pay_population_ranges_pkg.do_randomisation:1',
                                            1 = 2);
    end if;
--
    l_rand_chunk_num_tab(rand_num) := l_chunk_num_tab(i);
--
    pay_proc_logging.PY_LOG('Chunk '||l_chunk_num_tab(i)||
                            ' reassined '||rand_num);
--
  end loop;
--
--
  forall i in 1..l_chunk_num_tab.count
      update pay_population_ranges
         set rand_chunk_number = l_rand_chunk_num_tab(i)
       where payroll_action_id = l_pay_act_tab(i)
         and chunk_number = l_chunk_num_tab(i);
--
  commit;
--
  pay_proc_logging.PY_EXIT('pay_population_ranges_pkg.do_randomisation');
--
end do_randomisation;
--
/*
     insert_chunk_statii

     Create the rows in chunk status if needed
*/

procedure insert_chunk_statii(p_payroll_action_id in number)
is
begin
--
   pay_proc_logging.PY_ENTRY('pay_population_ranges_pkg.insert_chunk_statii');
--
   INSERT into PAY_CHUNK_STATUS
               (PAYROLL_ACTION_ID,
                CHUNK_NUMBER,
                RAND_CHUNK_NUMBER,
                POPULATION_STATUS,
                PROCESS_STATUS)
   SELECT DISTINCT p_payroll_action_id,
                   CHUNK_NUMBER,
                   nvl(RAND_CHUNK_NUMBER, CHUNK_NUMBER),
                   'U',
                   'U'
     FROM pay_population_ranges
    WHERE payroll_action_id = p_payroll_action_id;
--
    pay_proc_logging.PY_EXIT('pay_population_ranges_pkg.insert_chunk_statii');
--
end insert_chunk_statii;
--
/*
      insert_ranges

      This is the procedure that actually inserts the ranges, then
      performs additional steps (randomisation etc).
*/

procedure insert_ranges(p_payroll_action_id in number,
                        p_statement         in varchar2)
is

type t_curs_ref is ref cursor;
type t_person_id_tab IS TABLE OF pay_population_ranges.person_id%type
     index by binary_integer;
type t_source_id_tab IS TABLE OF pay_population_ranges.source_id%type
     index by binary_integer;
type t_source_type_tab IS TABLE OF pay_population_ranges.source_type%type
     index by binary_integer;
type t_pay_act_id_tab IS TABLE OF pay_population_ranges.payroll_action_id%type
     index by binary_integer;
type t_chunk_num_tab IS TABLE OF pay_population_ranges.chunk_number%type
     index by binary_integer;
type t_rge_stat_tab IS TABLE OF pay_population_ranges.range_status%type
     index by binary_integer;
--
l_pay_act_tab t_person_id_tab;
l_chunk_num_tab t_chunk_num_tab;
l_rand_chunk_num_tab t_chunk_num_tab;
l_rge_stat_tab t_rge_stat_tab;
l_person_id_tab t_person_id_tab;
l_source_id_tab t_source_id_tab;
l_source_type_tab t_source_type_tab;
l_strt_person_id_tab t_person_id_tab;
l_end_person_id_tab t_person_id_tab;
--
l_end_person_id pay_population_ranges.person_id%type;
--
actioncur t_curs_ref;
chunk_number pay_population_ranges.chunk_number%type;
pactid number;
--
begin
--
    pay_proc_logging.PY_ENTRY('pay_population_ranges_pkg.insert_ranges');
--
    chunk_number := 0;
--
    open actioncur for p_statement using p_payroll_action_id;
--
    loop

                   l_pay_act_tab.delete;
                   l_strt_person_id_tab.delete;
                   l_end_person_id_tab.delete;
                   l_chunk_num_tab.delete;
                   l_rge_stat_tab.delete;
                   l_person_id_tab.delete;
                   l_source_id_tab.delete;
                   l_source_type_tab.delete;

      if (g_multi_object = TRUE) then
         fetch actioncur bulk collect into l_person_id_tab,
                                           l_source_id_tab,
                                           l_source_type_tab
                         limit pay_proc_environment_pkg.chunk_size;
      else
         fetch actioncur bulk collect into l_person_id_tab
                         limit pay_proc_environment_pkg.chunk_size;
      end if;
--
      hr_utility.trace('l_person_id_tab ' || l_person_id_tab.count);
      hr_utility.trace('l_source_id_tab ' || l_source_id_tab.count);
      hr_utility.trace('l_source_type_tab ' || l_source_id_tab.count);
--
      if (l_person_id_tab.count <> 0) then
         chunk_number := chunk_number + 1;
--
         if (g_use_person_id = TRUE) then
--
            for i in 1..l_person_id_tab.count loop
              l_chunk_num_tab(i) := chunk_number;
              l_rge_stat_tab(i) := 'U';
              l_strt_person_id_tab(i) := l_person_id_tab(1);
              l_end_person_id_tab(i) := l_person_id_tab(l_person_id_tab.count);
              l_pay_act_tab(i) := p_payroll_action_id;
--
              if (g_multi_object = FALSE) then
                 l_source_id_tab(i) := null;
                 l_source_type_tab(i) := null;
              end if;
            end loop;
--
            forall i in 1..l_person_id_tab.COUNT
               insert into pay_population_ranges (
                         payroll_action_id,
                         starting_person_id,
                         ending_person_id,
                         chunk_number,
                         range_status,
                         person_id,
                         source_id,
                         source_type)
               values (
                      l_pay_act_tab(i),
                      l_strt_person_id_tab(i),
                      l_end_person_id_tab(i),
                      l_chunk_num_tab(i),
                      l_rge_stat_tab(i),
                      l_person_id_tab(i),
                      l_source_id_tab(i),
                      l_source_type_tab(i));
--
         else
            l_end_person_id := l_person_id_tab(l_person_id_tab.count);
            insert into pay_population_ranges (
                         payroll_action_id,
                         starting_person_id,
                         ending_person_id,
                         chunk_number,
                         range_status
                        )
               values (
                      p_payroll_action_id,
                      l_person_id_tab(1),
                      l_end_person_id,
                      chunk_number,
                      'U'
                      );
         end if;
--
         pay_proc_logging.PY_LOG('Chunk = '||chunk_number||
                                 ' Start id '||l_person_id_tab(1)||
                                 ' End id = '||
                                 l_person_id_tab(l_person_id_tab.count));
--
         commit;
--
      end if;
--
      exit when actioncur%notfound;
--
--
    end loop;
--
    close actioncur;
--
--  Don't call chunk shuffle if only 1 chunk (no point!)
--
    if (g_chunk_shuffle = TRUE and
        chunk_number <> 1) then
--
      do_randomisation(p_payroll_action_id,
                       chunk_number);
--
    end if;
--
    if (pay_proc_environment_pkg.chunk_method = 'ORIGINAL') then
       insert_chunk_statii(p_payroll_action_id);
    end if;
--
    pay_proc_logging.PY_EXIT('pay_population_ranges_pkg.insert_ranges');
--
end insert_ranges;
--
/*
   perform_range_creation

   This procedure generates the population ranges then executes a commit
*/
procedure perform_range_creation (p_payroll_action_id in number)
is
l_statement varchar2(4000);
begin
--
  pay_proc_logging.PY_ENTRY('pay_population_ranges_pkg.perform_range_creation');
--
  set_range_globals(p_payroll_action_id,
                    pay_proc_environment_pkg.action_type
                   );
--
  remove_existing_ranges(p_payroll_action_id);
--
  pay_proc_environment_pkg.update_pop_action_status(
                           p_payroll_action_id,
                           APS_POP_RANGES );
--
  get_range_statement(p_payroll_action_id,
                      l_statement);
--
  pay_proc_logging.PY_LOG('Statement:-');
  pay_proc_logging.PY_LOG(l_statement);
--
  insert_ranges(p_payroll_action_id,
                l_statement);
--
  pay_proc_environment_pkg.update_pop_action_status(
                           p_payroll_action_id,
                           APS_POP_ACTIONS );
--
  pay_proc_logging.PY_EXIT('pay_population_ranges_pkg.perform_range_creation');
--
end perform_range_creation;
--

/*
   reset_errored_ranges

   This procedure resets errored population ranges, ready to be reloaded
   the issues a commit
*/
procedure reset_errored_ranges(p_payroll_action_id in number)
is
--
type t_pay_act_id_tab IS TABLE OF pay_population_ranges.payroll_action_id%type
     index by binary_integer;
type t_chunk_num_tab IS TABLE OF pay_population_ranges.chunk_number%type
     index by binary_integer;
--
l_pay_act_tab t_pay_act_id_tab;
l_chunk_num_tab t_chunk_num_tab;
--
cursor get_err_chunks
is
select payroll_action_id,
       nvl(rand_chunk_number, chunk_number)
  from pay_population_ranges
 where payroll_action_id = p_payroll_action_id
 and   range_status = 'E';
--
begin
--
    pay_proc_logging.PY_ENTRY('pay_population_ranges_pkg.reset_errored_ranges');
--
    open get_err_chunks;
--
    loop
--
      l_pay_act_tab.delete;
      l_chunk_num_tab.delete;

      fetch get_err_chunks bulk collect into l_pay_act_tab,
                                             l_chunk_num_tab
       limit pay_proc_environment_pkg.chunk_size;
--
      forall i in 1..l_pay_act_tab.count
        delete from pay_action_interlocks pai
           where pai.locking_action_id in
               (select aa.assignment_action_id
                from pay_assignment_actions aa
                where payroll_action_id = l_pay_act_tab(i)
                and   chunk_number      = l_chunk_num_tab(i));
--
      forall i in 1..l_pay_act_tab.count
           delete from pay_assignment_actions aa
           where aa.payroll_action_id = l_pay_act_tab(i)
           and   aa.chunk_number      = l_chunk_num_tab(i);
--
      forall i in 1..l_pay_act_tab.count
           delete from pay_temp_object_actions aa
           where aa.payroll_action_id = l_pay_act_tab(i)
           and   aa.chunk_number      = l_chunk_num_tab(i);
--
      forall i in 1..l_pay_act_tab.count
           update pay_population_ranges ppr
           set range_status = 'U'
           where ppr.payroll_action_id = l_pay_act_tab(i)
           and   ppr.chunk_number      = l_chunk_num_tab(i);
--
      if (pay_proc_environment_pkg.chunk_method = 'ORIGINAL') then
--
        forall i in 1..l_pay_act_tab.count
              update pay_chunk_status
              set population_status         = 'U'
              where payroll_action_id       = l_pay_act_tab(i)
              and   chunk_number = l_chunk_num_tab(i);
--
      end if;
--
      commit;
--
      exit when get_err_chunks%notfound;
--
    end loop;
--
    pay_proc_environment_pkg.update_pop_action_status(
                           p_payroll_action_id,
                           APS_POP_ACTIONS );
--
    pay_proc_logging.PY_EXIT('pay_population_ranges_pkg.reset_errored_ranges');
--
end;
--
end pay_population_ranges_pkg;

/
