--------------------------------------------------------
--  DDL for Package Body PAY_CORE_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CORE_UTILS" as
/* $Header: pycorutl.pkb 120.26.12010000.1 2008/07/27 22:23:36 appldev ship $ */
--
-- Setup Globals
--
g_pkg    varchar2(30) := 'pay_core_utils';
g_traces BOOLEAN := hr_utility.debug_enabled;

type varchar_1_tbl is table of varchar2(1) index by binary_integer;
type varchar_50_tbl is table of varchar2(50) index by binary_integer;
type varchar_240_tbl is table of varchar2(240) index by binary_integer;
type number_tbl is table of number index by binary_integer;
--
type message_token is record
(
   token_name varchar_50_tbl,
   token_value varchar_240_tbl,
   sz number
);
--
type message_stack_type is record
(
   message_name varchar_50_tbl,
   message_txt  varchar_240_tbl,
   applid       number_tbl,
   token_str number_tbl,
   token_end number_tbl,
   sz number,
   message_level varchar_1_tbl
);
--
g_message_stack message_stack_type;
g_message_tokens message_token;
--
g_legislation_code PER_BUSINESS_GROUPS.LEGISLATION_CODE%TYPE;
g_leg_code         pay_legislation_contexts.legislation_code%type := null;
--
g_process_path varchar2(2000);
g_asg_action_id pay_assignment_actions.assignment_action_id%type;
--
-- Legislative context IV names cache. used in get_leg_context_iv_name.
--
type t_leg_context_iv_rec is record
 (legislation_code    per_business_groups.legislation_code%type
 ,non_oracle_local        varchar2(30)
 ,jurisdiction_iv     pay_input_values_f.name%type
 ,source_id_iv        pay_input_values_f.name%type
 ,source_text_iv      pay_input_values_f.name%type
 ,source_number_iv    pay_input_values_f.name%type
 ,source_number2_iv   pay_input_values_f.name%type
 ,source_text2_iv     pay_input_values_f.name%type
 ,organization_id_iv  pay_input_values_f.name%type
 );
--
g_leg_context_iv_rec  t_leg_context_iv_rec;
--
-- Caches for get_entry_end_date
--
type t_proration_group_id is table of pay_element_types_f.proration_group_id%type
     index by binary_integer;
type t_payroll_action_id is table of pay_payroll_actions.payroll_action_id%type
     index by binary_integer;
type t_date is table of date
     index by binary_integer;
g_proration_group_id t_proration_group_id;
g_payroll_action_id t_payroll_action_id;
g_end_date t_date;

--
------------------------------ get_parameter -------------------------------
 /* Name    : get_parameter
  Purpose   : This simply returns the value of a specified parameter in
              a parameter list based of the parameter name.
  Arguments :
  Notes     :
 */
function get_parameter(name in varchar2,
                       parameter_list varchar2) return varchar2
is
  start_ptr number;
  end_ptr   number;
  token_val pay_payroll_actions.legislative_parameters%type;
  par_value pay_payroll_actions.legislative_parameters%type;
  separator varchar2(1) := ' ';
begin
--
     token_val := name||'=';
--
     start_ptr := instr(parameter_list, token_val) + length(token_val);
--
--   Support of delimiter character '|' to allow spaces in a legislative parameter
--
     if substr(parameter_list, start_ptr, 1) = '|' then
       separator := '|';
       start_ptr := start_ptr + length('|');
     end if;
--
     end_ptr := instr(parameter_list, separator, start_ptr);
--
     /* if there is no spaces use then length of the string */
     if end_ptr = 0 then
        end_ptr := length(parameter_list)+1;
     end if;
--
     /* Did we find the token */
     if instr(parameter_list, token_val) = 0 then
       par_value := NULL;
     else
       par_value := substr(parameter_list, start_ptr, end_ptr - start_ptr);
     end if;
--
     return par_value;
--
end get_parameter;
--

------------------------------ remove_parameter -------------------------------
 /* Name    : remove_parameter
  Purpose   : This simply removes the value (and token name) of a specified
   parameter in a parameter list.
  Arguments :
  Notes     :
 */
function remove_parameter(p_name in varchar2,
                             p_parameter_list varchar2) return varchar2
is
--

  start_val   number;  /* Start pos of token value   */
  start_space number;  /* Pos of space before token  */
  end_space   number;  /* Pos of space after value   */
  full_ptr    number;  /* Full length of orig string */


  token_val pay_payroll_actions.legislative_parameters%type;
  l_parameter_list pay_payroll_actions.legislative_parameters%type;

begin
--
     token_val := p_name||'=';
--
     full_ptr := length(p_parameter_list)+1;
     start_val   := instr(p_parameter_list, token_val) + length(token_val);
     end_space   := instr(p_parameter_list, ' ', start_val);
     start_space := instr(p_parameter_list, ' ', start_val - full_ptr, 1);
--

     /* if there is no spaces after token then use the full length of the string */
     if end_space = 0 then
        end_space := full_ptr;
     end if;
--
     /* Did we find the token, if so remove it and its value */
     if instr(p_parameter_list, token_val) = 0 then
       l_parameter_list := p_parameter_list;
     else
       l_parameter_list :=
          substr(p_parameter_list, 0,start_space-1)||
            substr(p_parameter_list, end_space,full_ptr - end_space);
     end if;

    --return(to_char(start_space)||'xxx');
    return(l_parameter_list);

end;
--
--------------------------- get_business_group -------------------------------
 /* Name    : get_business_group
  Purpose   : This returns the cached business group id or returns the
              value returned from the supplied select statement.
  Arguments :
  Notes     :
 */
function get_business_group (p_statement varchar2) return number
is
sql_cur number;
ignore number;
business_group_id number;
begin
--
   if (g_cache_business_group) then
       business_group_id := get_dyt_business_group(p_statement);
   else
       sql_cur := dbms_sql.open_cursor;
       --
       -- Added by exjones
       begin
           dbms_sql.parse(sql_cur,
                          p_statement,
                          dbms_sql.v7);
	exception
	    when others then
	     dbms_sql.close_cursor(sql_cur);
	     return NULL;
	end;
	--
       dbms_sql.define_column(sql_cur, 1, business_group_id);
       ignore := dbms_sql.execute(sql_cur);
       if dbms_sql.fetch_rows(sql_cur) > 0 then
          dbms_sql.column_value(sql_cur, 1, business_group_id);
       else
          business_group_id := null;
       end if;
       dbms_sql.close_cursor(sql_cur);
   end if;
--
if (g_traces) then
   hr_utility.trace('pay_core_utils.get_business_group_id '||business_group_id);
end if;
   return business_group_id;
--
exception
     when others then
          if dbms_sql.is_open(sql_cur) then
             dbms_sql.close_cursor(sql_cur);
          end if;
          raise;
end get_business_group;
--
--------------------------- get_dyt_business_group---------------------------
 /* Name    : get_dyt_business_group
  Purpose   : This returns the cached business group id or returns the
              value returned from the supplied select statement.
              This should be used only from the dynamic triggers and only
              when its required to use the cached business group.
              (Do not use unless you are very sure)
  Arguments :
  Notes     :
 */
function get_dyt_business_group (p_statement varchar2) return number
is
sql_cur number;
ignore number;
business_group_id number;
begin
--
   if (g_business_group_id is null) then

       sql_cur := dbms_sql.open_cursor;
       --
       -- Added by exjones
       begin
           dbms_sql.parse(sql_cur,
                          p_statement,
                          dbms_sql.v7);
        exception
            when others then
             dbms_sql.close_cursor(sql_cur);
             return NULL;
        end;
        --
       dbms_sql.define_column(sql_cur, 1, business_group_id);
       ignore := dbms_sql.execute(sql_cur);
       if dbms_sql.fetch_rows(sql_cur) > 0 then
          dbms_sql.column_value(sql_cur, 1, business_group_id);
       else
          business_group_id := null;
       end if;
       dbms_sql.close_cursor(sql_cur);

       g_business_group_id := business_group_id;

   end if;
--
if (g_traces) then
   hr_utility.trace('pay_core_utils.get_dyt_business_group '||business_group_id);
end if;
   return g_business_group_id;
--
exception
     when others then
          if dbms_sql.is_open(sql_cur) then
             dbms_sql.close_cursor(sql_cur);
          end if;
          raise;
end get_dyt_business_group;
--
--------------------------- get_legislation_code -------------------------------
 /* Name    : get_legislation_code
  Purpose   : This returns the cached legislation code if it is for the passed
              business group. Otherwise derives the legislation code of the
              supplied business group.
  Arguments :
  Notes     :
 */
function get_legislation_code (p_bg_id number) return varchar2
is
begin

  if (p_bg_id is not null) then
     if (g_legislation_code is null or
         g_business_group_id is null or
         (g_business_group_id is not null and
          g_business_group_id <> p_bg_id)) then
         select legislation_code
         into g_legislation_code
         from per_business_groups_perf
         where business_group_id = p_bg_id;
         --
         g_business_group_id := p_bg_id;
     end if;
  end if;
--
if (g_traces) then
   hr_utility.trace('pay_core_utils.get_legislation_code '||g_legislation_code);
end if;
   return g_legislation_code;
--
end get_legislation_code;
--
--------------------------- reset_cached_values -------------------------------
 /* Name    : reset_cached_values
  Purpose   : This resets the cached value for business_group and legislation
              code.
  Arguments :
  Notes     :
 */
procedure reset_cached_values
is
begin
   hr_utility.set_location('pay_core_utils.reset_cached_values', 10);
--
   g_business_group_id := null;
   g_legislation_code := null;
--
   hr_utility.set_location('pay_core_utils.reset_cached_values', 20);
--
end reset_cached_values;
--
-------------------------- get_time_definition ----------------------------
 /* Name    : get_time_definition
  Purpose   : This procedure is use to get the time definition for
              Elements that require the dynamic option.
  Arguments :
  Notes     :
 */
procedure get_time_definition(p_element_entry in            number,
                              p_asg_act_id    in            number,
                              p_time_def_id      out nocopy number)
is
--
l_leg_code   per_business_groups_perf.legislation_code%type;
l_bus_grp_id per_business_groups_perf.business_group_id%type;
l_asg_id     per_all_assignments_f.assignment_id%type;
statem       varchar2(2000);  -- used with dynamic pl/sql
sql_cursor   integer;
l_rows       integer;
--
begin
--
   select paa.assignment_id,
          ppa.business_group_id,
          pbg.legislation_code
     into l_asg_id,
          l_bus_grp_id,
          l_leg_code
     from pay_assignment_actions paa,
          pay_payroll_actions    ppa,
          per_business_groups_perf pbg
    where paa.assignment_action_id = p_asg_act_id
      and ppa.business_group_id = pbg.business_group_id
      and paa.payroll_action_id = ppa.payroll_action_id;
--
   statem :=
'begin
    pay_'||l_leg_code||'_rules.get_time_def_for_entry(
           :element_entry_id,
           :assignment_id,
           :assignment_action_id,
           :business_group_id,
           :time_def_id);
end;
';
   --
   sql_cursor := dbms_sql.open_cursor;
   --
   dbms_sql.parse(sql_cursor, statem, dbms_sql.v7);
   --
   --
   dbms_sql.bind_variable(sql_cursor, 'element_entry_id', p_element_entry);
   --
   dbms_sql.bind_variable(sql_cursor, 'assignment_id', l_asg_id);
   --
   dbms_sql.bind_variable(sql_cursor, 'assignment_action_id', p_asg_act_id);
   --
   dbms_sql.bind_variable(sql_cursor, 'business_group_id', l_bus_grp_id);
   --
   dbms_sql.bind_variable(sql_cursor, 'time_def_id', p_time_def_id);
   --
   l_rows := dbms_sql.execute (sql_cursor);
   --
   if (l_rows = 1) then
      dbms_sql.variable_value(sql_cursor, 'time_def_id',
                              p_time_def_id);
      dbms_sql.close_cursor(sql_cursor);
--
   else
      p_time_def_id := null;
      dbms_sql.close_cursor(sql_cursor);
   end if;
--
end get_time_definition;
--
--
-------------------------- get_time_period_start ---------------------------
 /* Name    : get_time_period_start
  Purpose   : This procedure simple returns the period start date for
              the element entry fetch.
  Arguments :
  Notes     :
 */
function get_time_period_start(p_payroll_action_id in number
                               ) return date
is
l_start_date date;
begin
--
   select ptp.start_date
     into l_start_date
     from per_time_periods ptp,
          pay_payroll_actions ppa
    where ppa.payroll_action_id = p_payroll_action_id
      and ppa.payroll_id = ptp.payroll_id
      and ppa.date_earned between ptp.start_date
                              and ptp.end_date;
--
   return l_start_date;
--
end get_time_period_start;
--
--
-------------------------- get_entry_end_date ---------------------------
 /* Name    : get_entry_end_date
  Purpose   : This function returns the miminum end date for an
              element type in a prorated run.
              Used in the element entry fetch.
  Arguments :
  Notes     :
 */

function get_entry_end_date(p_element_type_id in number,
                            p_payroll_action_id in number,
                            p_assignment_action_id in number,
                            p_date_earned in date   ) return date
is
l_proration_group_id number;
l_time_definition_type varchar2(1);
begin
--
   if (g_proration_group_id.exists(p_element_type_id) = FALSE or
       g_payroll_action_id(p_element_type_id) <> p_payroll_action_id) then

      -- load element type info into cache

      select nvl(proration_group_id, -1), nvl(time_definition_type, 'N')
      into   l_proration_group_id, l_time_definition_type
      from pay_element_types_f
      where element_type_id = p_element_type_id
      and   p_date_earned between effective_start_date
                              and effective_end_date;

      g_proration_group_id(p_element_type_id) := l_proration_group_id;
      g_payroll_action_id(p_element_type_id) := p_payroll_action_id;
      --
      if (l_proration_group_id <> -1) then
          g_end_date(p_element_type_id) := pay_interpreter_pkg.prorate_start_date
                          (p_assignment_action_id, l_proration_group_id);
      elsif (l_time_definition_type <> 'N') then
          g_end_date(p_element_type_id) := pay_core_utils.get_time_period_start
                          (p_payroll_action_id);
      else
          g_end_date(p_element_type_id) := p_date_earned;
      end if;
   end if;
--
   return g_end_date(p_element_type_id);
--
end get_entry_end_date;

--
------------------------------ get_prorated_dates -------------------------------
 /* Name    : get_prorated_dates
  Purpose   : This procedure calls the process event interpreter to
              determine datetracked changes.
  Arguments :
  Notes     :
 */
procedure get_prorated_dates(p_ee_id         in            number,
                             p_asg_act_id    in            number,
                             p_time_def_type in            varchar2,
                             p_time_def_id   in out nocopy number,
                             p_date_array       out nocopy char_array,
                             p_type_array       out nocopy char_array
                            )
is
l_dt_internal pay_interpreter_pkg.t_proration_dates_table_type;
l_ty_internal pay_interpreter_pkg.t_proration_type_table_type;
l_det_internal pay_interpreter_pkg.t_detailed_output_table_type;
l_time_def_id number;
tmp_num number;
begin
--
    pay_proc_logging.PY_ENTRY('pay_core_utils.get_prorated_dates');
--
    pay_proc_logging.PY_LOG_TXT(pay_proc_logging.PY_ELEMETY,
                                'EE_ID = '||p_ee_id||' AA_ID = '||p_asg_act_id);
--
    if (p_time_def_type = 'G') then
--
       get_time_definition(p_ee_id, p_asg_act_id, p_time_def_id);
       l_time_def_id := p_time_def_id;
--
    elsif (p_time_def_type = 'S') then
--
       l_time_def_id := p_time_def_id;
--
    else
--
       l_time_def_id := null;
--
    end if;
--
    pay_interpreter_pkg.get_prorated_dates
    (
        p_element_entry_id       => p_ee_id,
        p_assignment_action_id   => p_asg_act_id,
        p_time_definition_id     => l_time_def_id,
        t_detailed_output        => l_det_internal,
        t_proration_dates        => l_dt_internal,
        t_proration_type         => l_ty_internal
    );
--
    for cnt in 1..l_dt_internal.count loop
--
     p_date_array(cnt) := to_char(l_dt_internal(cnt),  'YYYY/MM/DD HH24:MI:SS');
     p_type_array(cnt) := l_ty_internal(cnt);
--
     pay_proc_logging.PY_LOG_TXT(pay_proc_logging.PY_ELEMETY,
                                'Prorate Date '||p_date_array(cnt)||' Type '||p_type_array(cnt));
--
    end loop;
--
    pay_proc_logging.PY_EXIT('pay_core_utils.get_prorated_dates');
--
end get_prorated_dates;
--
------------------------------ set_prorate_dates -------------------------------
 /* Name    : set_prorate_dates
  Purpose   : This procedure calls is passed a set of dates and then
              determines the next combination of dates to use in proration.
  Arguments :
  Notes     :
 */
procedure set_prorate_dates(p_et_id      in number,
                             p_asg_act_id in number,
                             p_date_array in char_array,
                             p_type_array in char_array,
                             p_arr_cnt    in number,
                             p_prd_end    out nocopy varchar2,
                             p_start_date out nocopy varchar2,
                             p_end_date   out nocopy varchar2
                            )
is
l_date_earned date;
l_prd_end_date date;
l_prd_start_date date;
l_prorate_grp_id number;
begin
--
   select ppa.date_earned,
          ptp.end_date,
          ptp.start_date,
          pet.proration_group_id
     into l_date_earned,
          l_prd_end_date,
          l_prd_start_date,
          l_prorate_grp_id
     from pay_payroll_actions ppa,
          pay_assignment_actions paa,
          per_time_periods ptp,
          pay_element_types_f pet
    where paa.assignment_action_id = p_asg_act_id
      and paa.payroll_action_id = ppa.payroll_action_id
      and pet.element_type_id = p_et_id
      and ppa.date_earned between pet.effective_start_date
                              and pet.effective_end_date
      and ppa.date_earned between ptp.start_date
                              and ptp.end_date
      and ptp.payroll_id = ppa.payroll_id;
--
   -- Is the entry being prorated, if so then
   -- get the proration start date,
   -- otherwise it must be allocating
   if (l_prorate_grp_id is not null) then
     l_prd_start_date := pay_interpreter_pkg.prorate_start_date
                                                       (p_asg_act_id,
                                                        l_prorate_grp_id);
   end if;
--
   /* Remember we only deal with updates */
   if (p_arr_cnt = 1) then
      p_start_date := to_char(l_prd_start_date, 'YYYY/MM/DD HH24:MI:SS');
   else
      p_start_date := p_date_array(p_arr_cnt -1);
   end if;

   p_end_date := to_char(to_date(p_date_array(p_arr_cnt),
                                      'YYYY/MM/DD HH24:MI:SS')  -1,
                              'YYYY/MM/DD HH24:MI:SS');
--
   p_prd_end := to_char(l_prd_end_date, 'YYYY/MM/DD HH24:MI:SS');
--
end set_prorate_dates;
--
------------------------------ get_rr_id -------------------------------
 /* Name    : get_rr_id
  Purpose   : This procedure Retrieves a set number of new RR ids.
  Arguments :
  Notes     :
              Ths procedure is used by the C code to reduce the number
              of network trips.
 */
procedure get_rr_id( p_rr_id_list out nocopy varchar2
                    )
is
rr_id number;
begin
--
     select pay_run_results_s.nextval
       into rr_id
       from sys.dual;
--
     p_rr_id_list := rr_id;
--
end get_rr_id;
--
------------------------------ get_aa_id -------------------------------
 /* Name    : get_aa_id
  Purpose   : This procedure Retrieves a set number of new AA ids.
  Arguments :
  Notes     :
              Ths procedure is used by the C code to reduce the number
              of network trips.
 */
procedure get_aa_id( p_aa_id_list out nocopy varchar2
                    )
is
aa_id number;
begin
--
     select pay_assignment_actions_s.nextval
       into aa_id
       from sys.dual;
--
     p_aa_id_list := aa_id;
--
end get_aa_id;
--
------------------------------ get_rb_id -------------------------------
 /* Name    : get_rb_id
  Purpose   : This procedure Retrieves a set number of new RB ids.
  Arguments :
  Notes     :
              Ths procedure is used by the C code to reduce the number
              of network trips.
 */
procedure get_rb_id( p_rb_id_list out nocopy varchar2
                    )
is
rb_id number;
begin
--
     select pay_run_balances_s.nextval
       into rb_id
       from sys.dual;
--
     p_rb_id_list := rb_id;
--
end get_rb_id;
--
--------------------------- push_message -------------------------------
 /* Name    : push_message
  Purpose   : This places a message on the error stack.
  Arguments :
  Notes     :
 */
procedure push_message(p_applid in number,
                       p_msg_name in varchar2,
                       p_level in varchar2
                      )
is
begin
  push_message(p_applid,p_msg_name,null,p_level);
end;

procedure push_message(p_applid in number,
                       p_msg_name in varchar2,
                       p_msg_txt in varchar2,
                       p_level in varchar2
                      )
is
begin
   hr_utility.set_location('pay_core_utils.push_message', 10);
--
   g_message_stack.sz := g_message_stack.sz + 1;
   g_message_stack.message_name(g_message_stack.sz) := p_msg_name;
   g_message_stack.message_txt(g_message_stack.sz) := p_msg_txt;
   g_message_stack.applid(g_message_stack.sz) := p_applid;
   g_message_stack.token_str(g_message_stack.sz) := null;
   g_message_stack.token_end(g_message_stack.sz) := null;

   if (p_level='W' or p_level='I') then
     g_message_stack.message_level(g_message_stack.sz) := p_level;
   else
     g_message_stack.message_level(g_message_stack.sz) := 'F';
   end if;
--
   hr_utility.set_location('pay_core_utils.push_message', 20);
--
end push_message;
--
--------------------------- push_token -------------------------------
 /* Name    : push_token
  Purpose   : This places a message on the error stack.
  Arguments :
  Notes     :
 */
procedure push_token(
                     p_tok_name in varchar2,
                     p_tok_value in varchar2
                    )
is
begin
   hr_utility.set_location('pay_core_utils.push_token', 10);
--
   g_message_tokens.sz := g_message_tokens.sz + 1;
   g_message_tokens.token_name(g_message_tokens.sz) := p_tok_name;
   g_message_tokens.token_value(g_message_tokens.sz) := p_tok_value;
--
   -- Now set the message pointers
   if (g_message_stack.token_str(g_message_stack.sz) is null) then
     g_message_stack.token_str(g_message_stack.sz) := g_message_tokens.sz;
   end if;
   g_message_stack.token_end(g_message_stack.sz) := g_message_tokens.sz;
--
   hr_utility.set_location('pay_core_utils.push_token', 20);
--
end push_token;
--
--------------------------- pop_message -------------------------------
 /* Name    : pop_message
  Purpose   : This removes a message from the stack.
  Arguments :
  Notes     :
 */
procedure pop_message(
                       p_msg_text out nocopy varchar2
                      )
is
  l_sev_level varchar2(1);
begin
  pop_message(p_msg_text,l_sev_level);
end pop_message;

procedure pop_message(
                       p_msg_text out nocopy varchar2,
                       p_sev_level out nocopy varchar2
                      )
is
begin
   hr_utility.set_location('pay_core_utils.pop_message', 10);
--
   if (g_message_stack.sz = 0) then
     p_msg_text := null;
     p_sev_level := null;
     return;
   end if;
--
  if (g_message_stack.message_name(g_message_stack.sz) is NULL)
  then
   p_msg_text := g_message_stack.message_txt(g_message_stack.sz);
  else
   hr_utility.set_message(g_message_stack.applid(g_message_stack.sz),
                          g_message_stack.message_name(g_message_stack.sz));
--
   if (g_message_stack.token_str(g_message_stack.sz) is not null) then
--
      for tok_cnt in g_message_stack.token_str(g_message_stack.sz) ..
                  g_message_stack.token_end(g_message_stack.sz) loop
--
         hr_utility.set_message_token(g_message_tokens.token_name(tok_cnt),
                                      g_message_tokens.token_value(tok_cnt));
--
      end loop;
--
   end if;
--
   p_msg_text := hr_utility.get_message;
  end if;
  p_sev_level := g_message_stack.message_level(g_message_stack.sz);
  g_message_tokens.sz := g_message_stack.token_str(g_message_stack.sz) - 1;
  g_message_stack.sz := g_message_stack.sz - 1;
--
  hr_utility.set_locatIon('pay_core_utils.pop_message', 20);
--
end pop_message;

procedure mesg_stack_error_hdlr(p_pactid in number)
is
  l_msg_text varchar2(240);
  l_sev_level varchar2(1);
  l_found boolean := TRUE;
begin

  while (l_found = TRUE) loop
   if (g_message_stack.sz = 0)
   then
     l_found := FALSE;
   else

     pop_message(l_msg_text, l_sev_level);

     insert into pay_message_lines
     (
	LINE_SEQUENCE,
        PAYROLL_ID,
        MESSAGE_LEVEL,
        SOURCE_ID,
        SOURCE_TYPE,
        LINE_TEXT
     )
     values
     (
        pay_message_lines_s.nextval,
	null,
	l_sev_level,
	p_pactid,
	'P',
	substr(l_msg_text,0,240)
     );

    end if;
  end loop;

end;
--
--------------------------- get_pp_action_id -------------------------------
 /* Name    : get_pp_action_id
  Purpose   : This gets the prepayment assignment action (use in the
              payment route)
  Arguments :
  Notes     :
 */
function get_pp_action_id(p_action_type in varchar2,
                          p_action_id   in number) return number
is
l_action_id number;
begin
--
    if (p_action_type in ('P', 'U')) then
      l_action_id := p_action_id;
    elsif (p_action_type in ('R', 'Q')) then
--
--     Always return the master prepayment action.
--
       select INTLK.locking_action_id
         into l_action_id
         from pay_action_interlocks INTLK,
              pay_assignment_actions paa,
              pay_payroll_actions    ppa
        where INTLK.locked_action_id = p_action_id
          and INTLK.locking_action_id = paa.assignment_action_id
          and paa.payroll_action_id = ppa.payroll_action_id
          and ppa.action_type in ('P', 'U')
          and paa.source_action_id is null;
--
    else
        l_action_id := null;
    end if;
--
    return l_action_id;
--
end get_pp_action_id;
--
--------------------------- include_action_in_payment -------------------------------
 /* Name    : include_action_in_payment
  Purpose   : This function decides whether a Payroll run should be included in
              the payment route.
  Arguments :
  Notes     :
              This function is called from the payments route, after all the
              interlock joining has been done. It's purpose is to further
              qualify which runs should be included in the balance.

              If the balance has been called with a Prepayment assignment
              action, then all interlocked runs qualify.

              If the balance is called with a Payroll Run action, not all
              runs qualify. If the calling action is of run method Normal,
              Process Separate or Separate Payment, then only that calling
              action qualifies.

              However, if the balance is called with a Payroll Run action
              with a Run Method of Cumulative, all the child actions qualify
              with the exception of Separate Payment run Methods.
 */
function include_action_in_payment(p_calling_action_type in varchar2,
                                   p_calling_action_id   in number,
                                   p_run_action_id       in number
                                  ) return varchar2
is
--
l_include          varchar2(5);
l_run_method       pay_run_types_f.run_method%type;
l_child_run_method pay_run_types_f.run_method%type;
l_found            boolean;
--
procedure get_action_component(p_cur_action_id  in            number,
                               p_srch_action_id in            number,
                               p_found          in out nocopy boolean,
                               p_run_type          out nocopy varchar2)
is
--
   cursor get_actions (p_action in number)
   is
   select paa.assignment_action_id,
          nvl(prt.run_method, 'N'),
          paa.start_date
     from pay_assignment_actions paa,
          pay_run_types_f        prt
    where paa.source_action_id = p_action
      and paa.run_type_id = prt.run_type_id (+);
--
l_child_action pay_assignment_actions.assignment_action_id%type;
l_run_method   pay_run_types.run_method%type;
l_start_date   pay_assignment_actions.start_date%type;
--
begin
--
  open get_actions(p_cur_action_id);
  while (p_found = FALSE) loop
     fetch get_actions into l_child_action, l_run_method, l_start_date;
     exit when get_actions%notfound;
--
     if (l_child_action = p_srch_action_id) then
       p_found    := TRUE;
       p_run_type := l_run_method;
     else
       if (l_run_method = 'C' or l_start_date is not null) then
         get_action_component(l_child_action,
                              p_srch_action_id,
                              p_found,
                              p_run_type
                             );
       end if;
     end if;
  end loop;
--
  close get_actions;
--
end get_action_component;
--
begin
--
    l_include := 'N';
    if (p_calling_action_type in ('P', 'U')) then
      l_include := 'Y';
    elsif (p_calling_action_type in ('R', 'Q')) then
--
       select nvl(nvl(prt_aa.run_method, prt_pa.run_method), 'N')
         into l_run_method
         from pay_run_types_f        prt_aa,
              pay_run_types_f        prt_pa,
              pay_assignment_actions paa,
              pay_payroll_actions    ppa
        where paa.assignment_action_id = p_calling_action_id
          and paa.payroll_action_id = ppa.payroll_action_id
          and paa.run_type_id = prt_aa.run_type_id (+)
          and ppa.effective_date between nvl(prt_aa.effective_start_date, ppa.effective_date)
                                     and nvl(prt_aa.effective_end_date, ppa.effective_date)
          and ppa.run_type_id = prt_pa.run_type_id (+)
          and ppa.effective_date between nvl(prt_pa.effective_start_date, ppa.effective_date)
                                     and nvl(prt_pa.effective_end_date, ppa.effective_date);
--
       -- OK, if its a cumulative we need to do a bit of work
       if (l_run_method = 'C') then
--
         l_found := FALSE;
--
         get_action_component(p_calling_action_id,
                              p_run_action_id,
                              l_found,
                              l_child_run_method
                             );
--
--       Only include the run if its found and not a Separate Payment.
--
         if (l_found = TRUE and l_child_run_method <> 'S') then
           l_include := 'Y';
         end if;
--
       else
         if (p_calling_action_id = p_run_action_id) then
           l_include := 'Y';
         end if;
       end if;
--
    end if;
--
    return l_include;
--
end include_action_in_payment;
--
--
--------------------------- set_pap_group_id ---------------------------
 /* Name    : set_pap_group_id
  Purpose   : Sets the pay action parameter group id
  Arguments :
  Notes     :
 */
procedure set_pap_group_id(
                       p_pap_group_id in number
                      )
is
begin
   hr_utility.set_location('pay_core_utils.set_pap_group_id', 10);
--
   pay_core_utils.pay_action_parameter_group_id := p_pap_group_id;
--
   hr_utility.set_location('pay_core_utils.set_pap_group_id', 20);
--
end set_pap_group_id;
--
--------------------------- get_pap_group_id -------------------------------
 /* Name    : get_pap_group_id
  Purpose   : This returns the cached pay action parameter group id
  Arguments :
  Notes     :
 */
function get_pap_group_id return number
is
begin
   return pay_core_utils.pay_action_parameter_group_id;
--
end get_pap_group_id;
--
--------------------------- get_action_parameter  ------------------------
 /* Name    : get_action_parameter
  Purpose   : This returns the action_parameter value of a action
              parameter.
  Arguments :
  Notes     :
 */
procedure get_action_parameter(p_para_name   in         varchar2,
                               p_para_value  out nocopy varchar2,
                               p_found       out nocopy boolean
                              )
is
begin
--
    select parameter_value
    into p_para_value
    from pay_action_parameters
    where parameter_name = p_para_name
    or parameter_name=REPLACE(p_para_name,' ','_')
    or parameter_name=REPLACE(p_para_name,'_',' ');
--
   p_found := TRUE;
--
exception
   when others then
      p_found := FALSE;
--
end get_action_parameter;
--
--------------------------- get_report_f_parameter  ------------------------
 /* Name    : get_report_f_parameter
  Purpose   : This returns the parameter value of a report format
              parameter for a particular run.
  Arguments :
  Notes     :
 */
procedure get_report_f_parameter(
                               p_payroll_action_id in   number,
                               p_para_name   in         varchar2,
                               p_para_value  out nocopy varchar2,
                               p_found       out nocopy boolean
                              )
is
begin
--
    select parameter_value
    into p_para_value
    from pay_report_format_parameters prfp,
         pay_report_format_mappings_f prfm,
         pay_payroll_actions          ppa
    where ppa.payroll_action_id = p_payroll_action_id
      and ppa.report_type = prfm.report_type
      and ppa.report_qualifier = prfm.report_qualifier
      and ppa.report_category = prfm.report_category
      and prfm.report_format_mapping_id = prfp.report_format_mapping_id
      and ppa.effective_date between prfm.effective_start_date
                                 and prfm.effective_end_date
      and (   parameter_name = p_para_name
           or parameter_name=REPLACE(p_para_name,' ','_')
           or parameter_name=REPLACE(p_para_name,'_',' ')
          );
--
   p_found := TRUE;
--
exception
   when others then
      p_found := FALSE;
--
end get_report_f_parameter;
--
--------------------------- get_legislation_rule  ------------------------
 /* Name    : get_legislation_rule
  Purpose   : This returns the legislation rule for a legislation.
  Arguments :
  Notes     :
 */
procedure get_legislation_rule(p_legrul_name   in         varchar2,
                               p_legislation   in         varchar2,
                               p_legrul_value  out nocopy varchar2,
                               p_found         out nocopy boolean
                              )
is
begin
--
   select rule_mode
     into p_legrul_value
     from pay_legislation_rules
    where rule_type = p_legrul_name
      and legislation_code = p_legislation;
--
   p_found := TRUE;
--
exception
   when no_data_found then
      p_found := FALSE;
--
end get_legislation_rule;
--
--------------------------- approved_context ----------------------
 /* Name    : approved_context
  Purpose   : This procedure is used be Core Payroll in order
              to track the legislative contexts that
              can be used by Oracle Localisations.
  Arguments :
  Notes     :
 */
procedure approved_context(
                           p_legislation  in            varchar2,
                           p_context_name in            varchar2,
                           p_approved        out nocopy boolean,
                           p_iv_name      in out nocopy varchar2,
                           p_found        in out nocopy boolean
                          )
is
l_approved boolean;
begin
  --
  l_approved := FALSE;
--
  if (p_context_name = 'ORGANIZATION_ID') then
     l_approved := TRUE;
  else
     if ((p_legislation = 'BF')
         or
         (    p_legislation = 'US'
          and p_context_name in ('JURISDICTION_CODE')
         )
         or
         (    p_legislation = 'CA'
          and p_context_name in ('JURISDICTION_CODE', 'SOURCE_ID')
         )
         or
         (    p_legislation = 'CN'
          and p_context_name in ('JURISDICTION_CODE')
         )
         or
         (    p_legislation = 'MX'
          and p_context_name in ('JURISDICTION_CODE')
         )
         or
         (    p_legislation = 'KR'
          and p_context_name in ('SOURCE_TEXT')
         )
         or
         (    p_legislation = 'SA'
          and p_context_name in ('SOURCE_TEXT', 'SOURCE_NUMBER', 'SOURCE_TEXT2')
         )
         or
         (    p_legislation = 'GB'
          and p_context_name in ('SOURCE_TEXT')
         )
         or
         (    p_legislation = 'NL'
          and p_context_name in ('SOURCE_TEXT', 'SOURCE_TEXT2')
         )
         or
         (    p_legislation = 'IN'
          and p_context_name in ('JURISDICTION_CODE', 'SOURCE_TEXT', 'SOURCE_TEXT2', 'SOURCE_ID')
         )
         or
         (    p_legislation = 'IE'
          and p_context_name in ('SOURCE_TEXT')
         )
         or
         (    p_legislation = 'FR'
          and p_context_name in ('SOURCE_TEXT', 'SOURCE_ID', 'SOURCE_TEXT2', 'SOURCE_NUMBER')
         )
         or
         (    p_legislation = 'HK'
          and p_context_name in ('SOURCE_ID')
         )
         or
         (    p_legislation = 'ES'
          and p_context_name in ('SOURCE_TEXT', 'SOURCE_TEXT2', 'SOURCE_NUMBER', 'SOURCE_NUMBER2')
         )
         or
         (    p_legislation = 'FI'
          and p_context_name in ('SOURCE_TEXT', 'SOURCE_TEXT2')
         )
         or
         (    p_legislation = 'NO'
          and p_context_name in ('JURISDICTION_CODE', 'SOURCE_TEXT', 'SOURCE_TEXT2')
         )
         or
         (    p_legislation = 'PL'
          and p_context_name in ('SOURCE_TEXT', 'SOURCE_TEXT2')
         )
         or
         (    p_legislation = 'ZA'
          and p_context_name in ('SOURCE_TEXT', 'SOURCE_NUMBER')
         )
         or
         (    p_legislation = 'SE'
          and p_context_name in ('SOURCE_TEXT')
         )
        ) then
--
         l_approved := TRUE;
--
     end if;
  end if;
--
  if (l_approved = FALSE
      and p_context_name = 'JURISDICTION_CODE') then
--
      p_iv_name := 'NuLL';
      p_found   := TRUE;
--
  end if;
--
  p_approved := l_approved;
  --
end approved_context;
--
--------------------------- unset_context_iv_cache ----------------------
 /* Name    : unset_context_iv_cache
  Purpose   : This procedure unsets the context_iv_cache
              Used by test harness.
  Arguments :
  Notes     :
 */
procedure unset_context_iv_cache
is
begin
  --
  g_leg_context_iv_rec.legislation_code := null;
  g_leg_context_iv_rec.non_oracle_local := null;
  g_leg_context_iv_rec.jurisdiction_iv  := null;
  g_leg_context_iv_rec.source_id_iv     := null;
  g_leg_context_iv_rec.source_text_iv   := null;
  g_leg_context_iv_rec.source_number_iv := null;
  g_leg_context_iv_rec.source_number2_iv:= null;
  g_leg_context_iv_rec.source_text2_iv  := null;
  g_leg_context_iv_rec.organization_id_iv  := null;
  --
end unset_context_iv_cache;
--
--------------------------- get_leg_context_iv_name ----------------------
 /* Name    : get_leg_context_iv_name
  Purpose   : This returns the name of the input value to be used for
              a context
  Arguments :
  Notes     :
 */
procedure get_leg_context_iv_name(p_context_name   in         varchar2,
                                  p_legislation    in         varchar2,
                                  p_inp_val_name   out nocopy varchar2,
                                  p_found          out nocopy boolean
                                 )
is
  l_iv_name        pay_input_values_f.name%type;
  l_inp_val_name   pay_input_values_f.name%type;
  l_found          boolean;
  l_approved       boolean;
  --
  cursor csr_leg_contexts is
   select fc.context_name
         ,plc.input_value_name
         ,decode(fc.context_name
                ,'JURISDICTION_CODE' ,'JURISDICTION_IV'
                ,'SOURCE_ID'         ,'SOURCE_IV'
                ,'SOURCE_TEXT'       ,'SOURCE_TEXT_IV'
                ,'SOURCE_TEXT2'      ,'SOURCE_TEXT2_IV'
                ,'SOURCE_NUMBER'     ,'SOURCE_NUMBER_IV'
                ,null
                ) rule_type
     from pay_legislation_contexts plc,
          ff_contexts              fc
    where plc.legislation_code(+) = p_legislation
      and plc.context_id      (+) = fc.context_id
      and fc.context_name in
            ('JURISDICTION_CODE'
            ,'SOURCE_ID'
            ,'SOURCE_TEXT'
            ,'SOURCE_TEXT2'
            ,'SOURCE_NUMBER'
            ,'SOURCE_NUMBER2'
            ,'ORGANIZATION_ID');
  --
begin
  --
  -- Check if cache exists for this legislation code.
  --
  if (g_leg_context_iv_rec.legislation_code = p_legislation
      and g_leg_context_iv_rec.legislation_code is not null) then
    --
    -- Cache already exists, do nothing.
    --
    null;
--
  else
    --
    -- Retrieve the context definitions and set the global cache.
    --

    -- set legislation code
    g_leg_context_iv_rec.legislation_code := p_legislation;
--
    get_legislation_rule('NON_ORACLE_LOC',
                         p_legislation,
                         g_leg_context_iv_rec.non_oracle_local,
                         l_found
                        );
    if (l_found = FALSE) then
       g_leg_context_iv_rec.non_oracle_local := 'N';
    end if;

    for l_rec in csr_leg_contexts loop

      l_iv_name := null;

      if l_rec.input_value_name is not null then
        --
        l_iv_name := l_rec.input_value_name;
      else
        --
        -- No row in pay_legislation_contexts
        -- Thus see if there is a leg rule
        -- Derive the name from legislation rule.
        --
        if (l_rec.rule_type is not null) then
           get_legislation_rule(l_rec.rule_type,
                                p_legislation,
                                l_iv_name,
                                l_found
                                );
        end if;
      end if;
      --
      -- Set the global record cache.
      --
      if (l_rec.context_name = 'JURISDICTION_CODE') then
        --
        g_leg_context_iv_rec.jurisdiction_iv := l_iv_name;
        --
      elsif (l_rec.context_name = 'SOURCE_ID') then
        --
        g_leg_context_iv_rec.source_id_iv := l_iv_name;
        --
      elsif (l_rec.context_name = 'SOURCE_TEXT') then
        --
        g_leg_context_iv_rec.source_text_iv := l_iv_name;
        --
      elsif (l_rec.context_name = 'SOURCE_TEXT2') then
        --
        g_leg_context_iv_rec.source_text2_iv := l_iv_name;
        --
      elsif (l_rec.context_name = 'SOURCE_NUMBER') then
        --
        g_leg_context_iv_rec.source_number_iv := l_iv_name;
        --
      elsif (l_rec.context_name = 'SOURCE_NUMBER2') then
        --
        g_leg_context_iv_rec.source_number2_iv := l_iv_name;
        --
      elsif (l_rec.context_name = 'ORGANIZATION_ID') then
        --
        g_leg_context_iv_rec.organization_id_iv := l_iv_name;
      end if;
    end loop;
--
  end if;
  --
  -- Set out variables.
  --
  if (p_context_name = 'JURISDICTION_CODE') then
    --
    l_inp_val_name := g_leg_context_iv_rec.jurisdiction_iv;
    --
  elsif (p_context_name = 'SOURCE_ID') then
    --
    l_inp_val_name := g_leg_context_iv_rec.source_id_iv;
    --
  elsif (p_context_name = 'SOURCE_TEXT') then
    --
    l_inp_val_name := g_leg_context_iv_rec.source_text_iv;
    --
  elsif (p_context_name = 'SOURCE_TEXT2') then
    --
    l_inp_val_name := g_leg_context_iv_rec.source_text2_iv;
    --
  elsif (p_context_name = 'SOURCE_NUMBER') then
    --
    l_inp_val_name := g_leg_context_iv_rec.source_number_iv;
    --
  elsif (p_context_name = 'SOURCE_NUMBER2') then
    --
    l_inp_val_name := g_leg_context_iv_rec.source_number2_iv;
    --
  elsif (p_context_name = 'ORGANIZATION_ID') then
    --
    l_inp_val_name := g_leg_context_iv_rec.organization_id_iv;
    --
  else
    --
    l_inp_val_name := null;
    --
  end if;
--
  l_found        := (l_inp_val_name is not null);
--
  if (l_found = TRUE
      and g_leg_context_iv_rec.non_oracle_local = 'N') then
--
     approved_context(
                       p_legislation  => p_legislation,
                       p_context_name => p_context_name,
                       p_approved     => l_approved,
                       p_iv_name      => l_inp_val_name,
                       p_found        => l_found
                      );
--
     if (l_approved = FALSE
         and p_context_name <> 'JURISDICTION_CODE') then
--
        pay_core_utils.assert_condition('pay_core_utils.get_leg_context_iv_name:1',
                                            1 = 2);
--
     end if;
--
  end if;
--
  p_found := l_found;
  p_inp_val_name := l_inp_val_name;
--
end get_leg_context_iv_name;
--
--------------------------- get_dynamic_contexts ----------------------
 /* Name    : get_dynamic_contexts
  Purpose   : This returns a table containg the dynamic contexts.
  Arguments :
  Notes     :
 */
procedure get_dynamic_contexts(p_business_group_id in            number,
                               p_context_list         out nocopy t_contexts_tab
                              )
is
cursor get_contexts (p_bus_grp in number) is
select fc.context_name,
       pbg.legislation_code
  from ff_contexts fc,
       per_business_groups_perf pbg
 where pbg.business_group_id = p_bus_grp
   and fc.context_name in ('JURISDICTION_CODE',
                        'SOURCE_ID',
                        'SOURCE_TEXT',
                        'SOURCE_NUMBER',
                        'SOURCE_TEXT2',
                        'SOURCE_NUMBER2',
                        'ORGANIZATION_ID');
--
l_inp_val_name pay_input_values_f.name%type;
l_default      boolean;
l_plsql        varchar2(60);
--
l_legrul_value pay_legislation_rules.rule_mode%type;
l_found        boolean;
l_cnt          number;
--
begin
--
   p_context_list.delete;
--
   for cxtrec in get_contexts(p_business_group_id) loop
--
     l_inp_val_name := null;
--
     get_leg_context_iv_name(cxtrec.context_name,
                             cxtrec.legislation_code,
                             l_inp_val_name,
                             l_found
                            );
--
     --
     -- Default the input value name if needed
     --
     if (l_found = FALSE) then
       if (cxtrec.context_name = 'JURISDICTION_CODE') then
          l_inp_val_name := 'Jurisdiction';
       end if;
     end if;
--
     -- OK do we have a context that this legislation
     -- uses.
     if (l_inp_val_name is not null) then
--
        l_default := FALSE;
        l_plsql   := null;
--
        if (cxtrec.context_name = 'JURISDICTION_CODE') then
--
           get_legislation_rule('DEFAULT_JURISDICTION',
                                cxtrec.legislation_code,
                                l_legrul_value,
                                l_found
                               );
--
           if (l_found = FALSE) then
             l_legrul_value := 'N';
           end if;
--
           if (l_legrul_value = 'Y') then
             l_default := TRUE;
             l_plsql   := 'pay_'||cxtrec.legislation_code||'_rules.get_default_jurisdiction';
           end if;
--
        elsif (cxtrec.context_name = 'SOURCE_ID') then
--
          l_default := TRUE;
          l_plsql   := 'pay_'||cxtrec.legislation_code||'_rules.get_source_context';
--
        elsif (cxtrec.context_name = 'SOURCE_TEXT') then
--
          l_default := TRUE;
          l_plsql   := 'pay_'||cxtrec.legislation_code||'_rules.get_source_text_context';
--
        elsif (cxtrec.context_name = 'SOURCE_TEXT2') then
--
          l_default := TRUE;
          l_plsql   := 'pay_'||cxtrec.legislation_code||'_rules.get_source_text2_context';
--
        elsif (cxtrec.context_name = 'SOURCE_NUMBER') then
--
          l_default := TRUE;
          l_plsql   := 'pay_'||cxtrec.legislation_code||'_rules.get_source_number_context';
--
        elsif (cxtrec.context_name = 'SOURCE_NUMBER2') then
--
          l_default := TRUE;
          l_plsql   := 'pay_'||cxtrec.legislation_code||'_rules.get_source_number2_context';
--
        elsif (cxtrec.context_name = 'ORGANIZATION_ID') then
--
          l_default := TRUE;
          l_plsql   := 'pay_'||cxtrec.legislation_code||'_rules.get_third_party_org_context';
--
        end if;
--
        -- Add new entry onto list
        l_cnt := p_context_list.count+1;
        p_context_list(l_cnt).context_name     := cxtrec.context_name;
        p_context_list(l_cnt).is_context_def   := l_default;
        p_context_list(l_cnt).input_value_name := l_inp_val_name;
        p_context_list(l_cnt).default_plsql    := l_plsql;
--
     end if;
--
   end loop;
--
end get_dynamic_contexts;
--
--------------------------- check_ctx_set -------------------------------
 /* Name    : check_ctx_set
  Purpose   : this returns 'Y' if
              - no context input value exists on the entry
              - or context input value exists on the entry
                   and matches p_context_value.
 */
function check_ctx_set (p_ee_id      in number,
                        p_context_name in varchar2,
                        p_context_value in varchar2
                       ) return varchar2
is
--
l_exists number;
l_ivid number;
--
begin
--
select distinct piv.input_value_id
  into l_ivid
  from pay_input_values_f piv,
       pay_element_entry_values_f peev
 where peev.element_entry_id = p_ee_id
   and peev.input_value_id = piv.input_value_id
   and piv.name = p_context_name;

   select count(*)
     into l_exists
     from pay_element_entry_values_f peev
    where peev.element_entry_id = p_ee_id
      and peev.input_value_id = l_ivid
      and peev.screen_entry_value = p_context_value;
--
if (l_exists > 0) then
   return 'Y';
else
   return 'N';
end if;
--
exception
   when no_data_found then
   return 'Y';
--
end;

procedure assert_condition (p_location  in varchar2,
                            p_condition in boolean) is
--
-- Checks that assumptions made within pl/sql code are true. Use to check the
-- parameters to a pl/sql function or procedure before processing. If the
-- assumption made by a procedure (eg p_parameter is not null) is not true
-- then an error is raised to prevent processing from continuing.
--
begin
--
if not p_condition
then
    hr_utility.set_message(801, 'HR_6882_HRPROC_ASSERT') ;
    hr_utility.set_message_token('LOCATION', p_location);
    hr_utility.raise_error ;
end if;
--
end assert_condition;
--
--
--------------------------- get_proc_sep_trigger -------------------------------
 /* Name    : get_proc_sep_trigger
  Purpose   : returns the element entry id that caused a process
              separately/separate payment run type to process
 */
function get_proc_sep_trigger(p_asg_action_id in            number)
 return number
is
--
cursor c_procsep (p_aa_id    number,
                  p_eff_date date)
is
select prr.source_id
  from pay_run_results prr,
       pay_element_types_f pet
 where prr.assignment_action_id = p_aa_id
   and prr.source_type = 'E'
   and prr.element_type_id = pet.element_type_id
   and nvl(pet.process_mode, 'N') in ('P', 'S')
   and prr.entry_type not in ('A', 'R')
   and p_eff_date between pet.effective_start_date
                      and pet.effective_end_date
   order by decode (prr.status,
                    'P', 1,
                    'B', 2,
                     3),
            decode (prr.entry_type,
                    'S', 1,
                    2);
--
l_run_meth pay_run_types_f.run_method%type;
l_eff_date pay_payroll_actions.effective_date%type;
l_ee_id    pay_run_results.source_id%type;
--
begin
--
   select nvl(prt.run_method, 'N'),
          ppa.effective_date
     into l_run_meth,
          l_eff_date
     from pay_run_types_f        prt,
          pay_assignment_actions paa,
          pay_payroll_actions    ppa
    where paa.assignment_action_id = p_asg_action_id
      and ppa.payroll_action_id = paa.payroll_action_id
      and nvl(paa.run_type_id, -999)  = prt.run_type_id (+)
      and ppa.effective_date
              between nvl(prt.effective_start_date, ppa.effective_date)
                  and nvl(prt.effective_end_date, ppa.effective_date);
--
    if (l_run_meth not in ('P', 'S')) then
       return null;
    else
      open c_procsep(p_asg_action_id, l_eff_date);
      fetch c_procsep into l_ee_id;
      close c_procsep;
      return l_ee_id;
    end if;
--
end;
--
--------------------------- get_process_path -------------------------------
 /* Name    : get_process_path
  Purpose   : returns the processing path given an assignment action
 */
procedure get_process_path(p_asg_action_id in            number,
                           p_process_path  in out nocopy varchar2)
is
--
 l_run_type_id pay_assignment_actions.run_type_id%type;
 l_src_id      pay_assignment_actions.source_action_id%type;
 l_ee_trigger  pay_element_entries_f.element_entry_id%type;
 l_start_date  varchar2(30);
 l_end_date    varchar2(30);
begin
--
   select run_type_id,
          source_action_id,
          to_char(start_date, 'YYYY/MM/DD HH24:MI:SS'),
          to_char(end_date, 'YYYY/MM/DD HH24:MI:SS')
     into l_run_type_id,
          l_src_id,
          l_start_date,
          l_end_date
     from pay_assignment_actions
    where assignment_action_id = p_asg_action_id;
--
   l_ee_trigger := get_proc_sep_trigger(p_asg_action_id);
--
   if (l_ee_trigger is null) then
--
     p_process_path := to_char(l_run_type_id)||'.'||p_process_path;
--
   else
--
     p_process_path := to_char(l_run_type_id)||'('||
                          to_char(l_ee_trigger)||').'||p_process_path;
--
   end if;
--
   if ((l_start_date is not null) and (l_end_date is not null))
   then
      p_process_path := '[' || l_start_date || ']' ||
                        '[' || l_end_date || ']'  || p_process_path;
   end if;
--
   if (l_src_id is not null) then
     get_process_path(l_src_id , p_process_path);
   end if;
--
end get_process_path;
--
function get_process_path(p_asg_action_id in number)
 return varchar2
is
l_process_path varchar2(2000);
begin
--
  if (g_asg_action_id is not null and
      p_asg_action_id = g_asg_action_id) then
     l_process_path := g_process_path;
  else
     l_process_path := '';
     get_process_path(p_asg_action_id, l_process_path);
     g_asg_action_id := p_asg_action_id;
     g_process_path := l_process_path;
  end if;
--
  return l_process_path;
--
end get_process_path;
--
--
function get_sql_cursor(p_statement in     varchar2,
                        p_sql_cur   out nocopy   number) return boolean
is
  l_sql_cur number;
  l_cnt     number;
  l_found   boolean := FALSE;
begin
--
  for l_cnt in 1..g_sql_cursors.count loop
    if p_statement = g_sql_cursors(l_cnt).statement then
      l_sql_cur := g_sql_cursors(l_cnt).sql_cur;
      l_found   := TRUE;
      exit;
    end if;
  end loop;
--
  if not l_found then
    begin
      l_sql_cur := dbms_sql.open_cursor;
      dbms_sql.parse(l_sql_cur,
                     p_statement,
                     dbms_sql.v7);
      l_found := TRUE;
--
      l_cnt := g_sql_cursors.count + 1;
      g_sql_cursors(l_cnt).statement := p_statement;
      g_sql_cursors(l_cnt).sql_cur   := l_sql_cur;
--
    exception
      when others then
        if dbms_sql.is_open(l_sql_cur) then
          dbms_sql.close_cursor(l_sql_cur);
        end if;
    end;
--
  end if;
--
  if l_found then
    p_sql_cur := l_sql_cur;
  end if;
--
  return l_found;
--
end get_sql_cursor;
--
procedure close_all_sql_cursors
is
  l_cnt     number;
begin
--
  for l_cnt in 1..g_sql_cursors.count loop
    if dbms_sql.is_open(g_sql_cursors(l_cnt).sql_cur) then
      dbms_sql.close_cursor(g_sql_cursors(l_cnt).sql_cur);
    end if;
  end loop;
--
  g_sql_cursors.delete;
--
end close_all_sql_cursors;
--
procedure close_sql_cursor(p_sql_cur number)
is
  l_cnt     number;
begin
--
  for l_cnt in 1..g_sql_cursors.count loop
    if g_sql_cursors(l_cnt).sql_cur = p_sql_cur then
--
      if dbms_sql.is_open(g_sql_cursors(l_cnt).sql_cur) then
        dbms_sql.close_cursor(g_sql_cursors(l_cnt).sql_cur);
      end if;
      g_sql_cursors.delete(l_cnt);
--
    end if;
  end loop;
--
end close_sql_cursor;
--
--------------------------- get_upgrade_status -------------------------------
 /* Name    : get_upgrade_status
  Purpose   : returns the upgrade status (Y or N) for a specified
              upgrade.
 */
procedure get_upgrade_status(p_bus_grp_id in            number,
                             p_short_name in            varchar2,
                             p_status        out nocopy varchar2,
                             p_raise_error in           boolean default TRUE)
is
--
l_upgrade_definition_id pay_upgrade_definitions.upgrade_definition_id%type;
l_legislation_code      pay_upgrade_definitions.legislation_code%type;
l_upgrade_level         pay_upgrade_definitions.upgrade_level%type;
l_failure_point         pay_upgrade_definitions.failure_point%type;
l_legislatively_enabled pay_upgrade_definitions.legislatively_enabled%type;
l_bg_leg_code           per_business_groups.legislation_code%type;
l_status                pay_upgrade_status.status%type;
l_upgrade_status        pay_upgrade_status.status%type;
l_check_upgrade         boolean;
l_dummy                 number;
--
begin
--
   begin
      select pud.upgrade_definition_id,
             pud.legislation_code,
             pud.upgrade_level,
             pud.failure_point,
             pud.legislatively_enabled
        into l_upgrade_definition_id,
             l_legislation_code,
             l_upgrade_level,
             l_failure_point,
             l_legislatively_enabled
        from pay_upgrade_definitions pud
       where pud.short_name = p_short_name;
--
      -- Bugfix 3494732
      -- Only fetch the legislation_code when a non-null
      -- bg id has been passed in.
      if p_bus_grp_id is not null then
--
        select pbg.legislation_code
          into l_bg_leg_code
          from per_business_groups_perf pbg
         where pbg.business_group_id = p_bus_grp_id;
--
      end if;
--
      /* If the legislation codes do not match
         then the upgrade is not applicable to the
         BG. Therefore return N.
      */
      if (l_legislation_code is not null
          and l_legislation_code <> l_bg_leg_code) then
--
          l_status := 'N';
--
      else
--
        /* Is this a globally defined upgrade (Core) that
           needs to be switched on by a legislation
        */
        l_check_upgrade := TRUE;
        if (l_legislation_code is null and
            l_legislatively_enabled = 'Y') then
--
           l_check_upgrade := FALSE;
--
           begin
             select 1
               into l_dummy
               from pay_upgrade_legislations pul
               where pul.upgrade_definition_id = l_upgrade_definition_id
                 and pul.legislation_code = l_bg_leg_code;
--
              l_check_upgrade := TRUE;
--
           exception
             when no_data_found then
               l_check_upgrade := FALSE;
           end;
--
        end if;
--
        if (l_check_upgrade = FALSE) then
--
          l_status := 'N';
--
        else
--
          /* Now for the different types of upgrades workout
             if the upgrade has been done
          */
          if (l_upgrade_level = 'B') then
--
            begin
--
              select pus.status
                into l_upgrade_status
                from pay_upgrade_status pus
               where pus.upgrade_definition_id = l_upgrade_definition_id
                 and pus.business_group_id = p_bus_grp_id;
--
              if (l_upgrade_status = 'C') then
                l_status := 'Y';
              elsif (((         l_upgrade_status = 'P'
                        and    l_failure_point = 'P')
                     or l_failure_point = 'A')
                    and p_raise_error) then
--
                  pay_core_utils.assert_condition(
                          'pay_core_utils.get_upgrade_status:1',
                          1 = 2);
--
              else
                  l_status := 'N';
              end if;
--
            exception
               when no_data_found then
                  if (( l_failure_point = 'A')
                      and p_raise_error) then
--
                    pay_core_utils.assert_condition(
                          'pay_core_utils.get_upgrade_status:1',
                          1 = 2);
--
                  else
                    l_status := 'N';
                  end if;
            end ;
--
          elsif (l_upgrade_level = 'L') then
--
            begin
--
              select pus.status
                into l_upgrade_status
                from pay_upgrade_status pus
               where pus.upgrade_definition_id = l_upgrade_definition_id
                 and pus.legislation_code = l_bg_leg_code;
--
              if (l_upgrade_status = 'C') then
                l_status := 'Y';
              elsif (((        l_upgrade_status = 'P'
                       and    l_failure_point = 'P' )
                      or l_failure_point = 'A')
                      and p_raise_error) then
--
                  pay_core_utils.assert_condition(
                          'pay_core_utils.get_upgrade_status:1',
                          1 = 2);
--
              else
                  l_status := 'N';
              end if;
--
            exception
               when no_data_found then
                  if ((l_failure_point = 'A')
                      and p_raise_error) then
--
                    pay_core_utils.assert_condition(
                          'pay_core_utils.get_upgrade_status:1',
                          1 = 2);
--
                  else
                    l_status := 'N';
                  end if;
            end ;
--
          elsif (l_upgrade_level = 'G') then
--
            begin
--
              select pus.status
                into l_upgrade_status
                from pay_upgrade_status pus
               where pus.upgrade_definition_id = l_upgrade_definition_id
                 and pus.legislation_code is null
                 and pus.business_group_id is null;
--
              if (l_upgrade_status = 'C') then
                l_status := 'Y';
              elsif (((        l_upgrade_status = 'P'
                      and    l_failure_point = 'P' )
                     or l_failure_point = 'A')
                     and p_raise_error) then
--
                  pay_core_utils.assert_condition(
                          'pay_core_utils.get_upgrade_status:1',
                          1 = 2);
--
              else
                  l_status := 'N';
              end if;
--
            exception
               when no_data_found then
                  if (( l_failure_point = 'A')
                      and p_raise_error) then
--
                    pay_core_utils.assert_condition(
                          'pay_core_utils.get_upgrade_status:1',
                          1 = 2);
--
                  else
                    l_status := 'N';
                  end if;
            end ;
--
          else
--
            /* Force an assertion */
            pay_core_utils.assert_condition('pay_core_utils.get_upgrade_status:2',
                                            1 = 2);
          end if;
        end if;
--
      end if;
--
   exception
       when no_data_found then
          l_status := 'N';
   end;
--
   p_status := l_status;
--
end get_upgrade_status;
--
--------------------------- get_upgrade_status -------------------------------
 /* Name    : get_upgrade_status
  Purpose   : returns the upgrade status (Y or N) for a specified
              upgrade.
 */
function get_upgrade_status(
        p_bus_grp_id    in number,
        p_short_name    in varchar2,
        p_raise_error   in varchar2 default 'TRUE') return varchar2
is
        l_status        pay_upgrade_status.status%type;
begin
        get_upgrade_status(
            p_bus_grp_id    => p_bus_grp_id,
            p_short_name    => p_short_name,
            p_status        => l_status,
            p_raise_error   => (nvl(upper(p_raise_error), 'TRUE') = 'TRUE'));
        --
        return l_status;
end get_upgrade_status;
--
function getprl(p_pactid in number) return varchar2
is
 l_payroll_name varchar2(80);

begin

  select ppf.payroll_name
  into   l_payroll_name
  from   pay_payroll_actions ppa,
         pay_payrolls_f ppf
  where  ppa.payroll_action_id=p_pactid
  and    nvl(ppa.payroll_id,-9999)=ppf.payroll_id
  and    ppa.effective_date between ppf.effective_start_date and effective_end_date;

  return l_payroll_name;

exception
  when no_data_found then
    return null;

end getprl;

--------------------------- get_context_iv_name -------------------------------
 /* Name    : get_context_iv_name
  Purpose   : returns context input value name for an
              assignment action id
 */

Function get_context_iv_name (p_asg_act_id in number,
                              p_context	   in varchar2)  return varchar2
is
--
l_context_iv_name  pay_legislation_contexts.input_value_name%type;
l_found boolean;
--
begin
--
   if (g_leg_code is null) then
      select pbg.legislation_code
        into g_leg_code
        from pay_assignment_actions paa,
             pay_payroll_actions    ppa,
             per_business_groups_perf pbg
       where paa.assignment_action_id = p_asg_act_id
         and ppa.business_group_id = pbg.business_group_id
         and paa.payroll_action_id = ppa.payroll_action_id;
   end if;
--
   get_leg_context_iv_name(p_context_name => p_context,
                           p_legislation  => g_leg_code,
                           p_inp_val_name => l_context_iv_name,
                           p_found        => l_found
                          );
--
   return l_context_iv_name;
--
end get_context_iv_name;
--
function is_element_included (p_element_type_id   in number,
                              p_run_type_id       in number,
                              p_effective_date    in date,
                              p_business_group_id in number,
                              p_legislation       in varchar2,
                              p_label		  in varchar) return varchar2
is
--
l_class_inc       varchar2(1);
l_et_inc         varchar2(1);
l_rt_inc         varchar2(1);
is_element_inc   varchar2(1);
--
  cursor get_class_inc(p_element_type_id   in number,
                       p_run_type_id       in number,
                       p_effective_date    in date,
                       p_business_group_id in number,
                       p_legislation       in varchar2)
  is
  SELECT nvl(INCLUSION_FLAG, 'Y')
    FROM PAY_ELEMENT_CLASS_USAGES_F pecu,
         PAY_ELEMENT_TYPES_F pet,
         PAY_ELEMENT_CLASSIFICATIONS pec
   WHERE pet.element_type_id = p_element_type_id
     AND pet.classification_id = pecu.classification_id
     AND pec.classification_id = pet.classification_id
     -- Only checking for primary classifications here
     -- Will also need to check for sub classifications exclusions
     AND pec.PARENT_CLASSIFICATION_ID is null
     AND pecu.run_type_id = p_run_type_id
     AND (pecu.business_group_id = p_business_group_id
          OR (pecu.business_group_id is null
              AND pecu.legislation_code = p_legislation)
          OR (pecu.business_group_id is null and pecu.legislation_code is null))
     AND (pec.business_group_id = p_business_group_id
          OR (pec.business_group_id is null
              AND pec.legislation_code = p_legislation)
          OR (pec.business_group_id is null and pec.legislation_code is null))
     AND (pet.business_group_id = p_business_group_id
          OR (pet.business_group_id is null
              AND pet.legislation_code = p_legislation)
          OR (pet.business_group_id is null and pet.legislation_code is null))
     AND p_effective_date between pet.effective_start_date
             and pet.effective_end_date
     AND p_effective_date between pecu.effective_start_date
             and pecu.effective_end_date;


  cursor get_runtype_inc(p_run_type_id       in number,
                       p_effective_date    in date,
                       p_business_group_id in number,
                       p_legislation       in varchar2)
  is
  SELECT nvl(INCLUSION_FLAG, 'Y')
    FROM PAY_ELEMENT_CLASS_USAGES_F pecu
   WHERE  pecu.run_type_id = p_run_type_id
     AND (pecu.business_group_id = p_business_group_id
          OR (pecu.business_group_id is null
              AND pecu.legislation_code = p_legislation)
          OR (pecu.business_group_id is null and pecu.legislation_code is null))
     AND p_effective_date between pecu.effective_start_date
             and pecu.effective_end_date;


--
  cursor get_element_inc(p_element_type_id   in number,
                         p_run_type_id       in number,
                         p_effective_date    in date,
                         p_business_group_id in number,
                         p_legislation       in varchar2)
  is
  SELECT INCLUSION_FLAG
    FROM pay_element_type_usages_f
   WHERE element_type_id = p_element_type_id
     AND run_type_id = p_run_type_id
     AND nvl(usage_type, 'I') = 'I'
     AND (business_group_id = p_business_group_id
          OR (business_group_id is null
              AND legislation_code = p_legislation)
          OR (business_group_id is null and legislation_code is null))
     AND p_effective_date between effective_start_date
             and effective_end_date;
--
begin
--
--
--



 /* exlude if excluded at class or et level,
    or when no label  if no usages exist at class but some exist at rt level */

/* include if included at class level and no usage defined at et
   or
   if label, no usage defined at class level, or et
   or
   if no label, no usage defined at class or runtype or et */

  is_element_inc := 'Y';

  open get_element_inc(p_element_type_id,
                       p_run_type_id,
                       p_effective_date,
                       p_business_group_id,
                       p_legislation);
  fetch get_element_inc into l_et_inc;


  if (get_element_inc%found and l_et_inc = 'N')  then
     close get_element_inc;
     is_element_inc := 'N';
  else

     close get_element_inc;

     open get_class_inc(p_element_type_id,
                        p_run_type_id,
                        p_effective_date,
                        p_business_group_id,
                        p_legislation);
     fetch get_class_inc   into l_class_inc;

     if (get_class_inc%found and l_class_inc = 'N') then
        close get_class_inc;
        is_element_inc := 'N';
     else

        if (p_label is null and get_class_inc%notfound) then

           open get_runtype_inc( p_run_type_id,
                                p_effective_date,
                                p_business_group_id,
                                p_legislation);
           fetch get_runtype_inc into l_rt_inc;

           if (get_runtype_inc%found) then
              is_element_inc := 'N';
           end if;
           close get_runtype_inc;

        end if;
        close get_class_inc;
     end if;
  end if;
--
--
  return is_element_inc;
--
end is_element_included;
--
begin
   g_business_group_id := null;
   g_cache_business_group := FALSE;
   g_legislation_code := null;
   g_message_stack.sz := 0;
   g_message_tokens.sz := 0;
   g_process_path := null;
   g_asg_action_id := null;
end pay_core_utils;

/
