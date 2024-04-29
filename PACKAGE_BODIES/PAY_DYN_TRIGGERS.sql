--------------------------------------------------------
--  DDL for Package Body PAY_DYN_TRIGGERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_DYN_TRIGGERS" as
/* $Header: pydyntrg.pkb 120.0.12000000.2 2007/03/01 12:08:09 mshingan noship $ */

/*
   Copyright (c) Oracle Corporation 1991,1992,1993. All rights reserved

   Description : Package and procedure to build sql for payroll processes.

   Change List
   -----------
   Date         Name        Vers    Bug No   Description
   -----------  ----------  ------  -------  -----------------------------------
   01-MAR-2007  mshingan    115.15  3620365  Modified create_trigger_event to deliver
                                             dynamic triggers as Generated and Enabled
   08-SEP-2003  mreid       115.14  3131252  Changed length of l_sql
   17-JUN-2003  jford       115.13           Added return_dated_table_name
   13-FEB-2003  prsundar    115.12  2510643  Added procedure create_func_usage.
					     Also added owner parameter to proc
					     create_func_trigger.
   05-FEB-2003  jford       115.11           create_trg_parameter, allows dyt_pkg params
   05-OCT-2002  jford       115.10           Modified generate_trigger_event to allow
                                             call to new dy'Trig pkg maker code.  To
                                             support new dyt_pkg methodology introduced
                                             as part of cont calc 2.
   19-FEB-2002  nbristow    115.7            Added uppers when checking
                                             parameter name checking.
   25-JAN-2002  nbristow    115.6            Added dbdrv statements.
   25-JAN-2002  nbristow    115.5            Changed create_trg_parameter to
                                             update value_name, rather than
                                             insert a new row.
   25-JUL-2001  nbristow    115.4            Added enable_functional_area and
                                             gen_functional_area
   25-JUL-2001  nbristow    115.3            Now nvl the protected flag.
   12-APR-2001  exjones     115.2   1731598  Take out code in create_trg_compon-
                                             ents which blindly updates the
                                             enabled flag to what's in the ldt
                                             and replace with code to check if
                                             the component is already there, if
                                             so, do nothing otherwise create the
                                             component.
                                             Need to replace with code using who
                                             columns to check for and update
                                             seeded data, but not that changed
                                             by anyone other than seed, to allow
                                             us to update seeded data.
   28-JUN-2000  nbristow    115.1            Added proctected flag.
   27-JUN-2000  nbristow    115.0            Created.

*/
/* Global definitions */
--
----------------------------- enable_functional_area --------------------------
/*
   NAME
      enable_functional_area
   NOTES
      Generates and enables all the triggers in a functional area.
*/
procedure enable_functional_area(p_short_name varchar2)
is
cursor get_trg is
select pte.short_name,
       pte.event_id
from pay_functional_areas pfa,
     pay_functional_triggers pft,
     pay_trigger_events pte
where pte.event_id = pft.event_id
and pft.area_id = pfa.area_id
and pfa.short_name = p_short_name;
--
begin
--
   for trgrec in get_trg loop
--
     update pay_trigger_components
        set enabled_flag = 'Y'
      where event_id = trgrec.event_id;
     update pay_trigger_events
        set generated_flag = 'Y',
            enabled_flag = 'Y'
      where event_id = trgrec.event_id;
--
     pay_dyn_triggers.generate_trigger_event(
                         trgrec.short_name
                        );
--
   end loop;
--
end enable_functional_area;
--
----------------------------- gen_functional_area --------------------------
/*
   NAME
      gen_functional_area
   NOTES
      Generates all the triggers in a functional area that are maked as
      generated.
   ADDENDUM 10-nov-02
      For the record I believe this code is now redundant , doesnt appear to be called.
      The main form to control functional areas, forms/US/PAYWSFGT now contains logic
      to rebuild all triggers and display appropriate error messages.  Any call to this
      procedure should still work, but no feedback on results will be given.
*/
procedure gen_functional_area(p_short_name varchar2)
is
cursor get_trg is
select distinct pte.short_name
from pay_functional_areas pfa,
     pay_functional_triggers pft,
     pay_trigger_events pte
where pte.event_id = pft.event_id
and pft.area_id = pfa.area_id
and pfa.short_name like p_short_name;
begin
   for trgrec in get_trg loop
         pay_dyn_triggers.generate_trigger_event(
                         trgrec.short_name
                        );
   end loop;
end gen_functional_area;
--
----------------------------- generate_trigger_event --------------------------
/*
   NAME
      generate_trigger_event
   NOTES
      Generates and enables the trigger if the relevent flags are set.
*/
procedure generate_trigger_event(p_short_name varchar2)
is
l_table_name        pay_trigger_events.table_name%TYPE;
l_triggering_action pay_trigger_events.triggering_action%TYPE;
l_protected_flag    pay_trigger_events.protected_flag%TYPE;
l_generated_flag    pay_trigger_events.generated_flag%TYPE;
l_enabled_flag      pay_trigger_events.enabled_flag%TYPE;
l_event_id          pay_trigger_events.event_id%TYPE;
l_trigger_name      varchar2(50);
l_sql               varchar2(32767);

l_dyt_type          pay_dated_tables.dyn_trigger_type%TYPE;
l_tab_id            pay_dated_tables.dated_table_id%TYPE;
l_ok                boolean;

begin
      select pte.generated_flag,
             pte.enabled_flag,
             pte.event_id,
             pte.table_name,
             pte.triggering_action,
             nvl(pte.protected_flag, 'N'),
             nvl(pdt.dyn_trigger_type,'T'),
             pdt.dated_table_id
        into l_generated_flag,
             l_enabled_flag,
             l_event_id,
             l_table_name,
             l_triggering_action,
             l_protected_flag,
             l_dyt_type,
             l_tab_id
        from pay_trigger_events pte,
             pay_dated_tables pdt
       where pte.table_name = pdt.table_name(+)
       and   pte.short_name = p_short_name;
--
      if (l_protected_flag <> 'Y') then
        --NEED TO SEE HOW USER WISHES DYN TRIGGERS TO BE HANDLED
        --
        -- Added by jford 1-OCT-02 as part of cont calc
        --
        IF (l_dyt_type = 'P' or l_dyt_type = 'B') THEN
          -- dyn trigger code should be handled as package
          --  >> GENERATE PACKAGE
          -- generate code FOR ALL TABLE eg many dyn_triggers
          paywsdyg_pkg.gen_dyt_pkg_full_code(l_tab_id,l_ok);
        ELSE

          if (l_generated_flag = 'Y') then
           -- Need to generate trigger
           l_trigger_name := paywsdyg_pkg.get_trigger_name
                                        (l_event_id,
                                         l_table_name,
                                         l_triggering_action);
           paywsdyg_pkg.generate_code(l_event_id, l_sql);
           paywsdyg_pkg.create_trigger(l_trigger_name,
                                       l_table_name,
                                       l_triggering_action,
                                       l_sql);
--
             if (l_enabled_flag = 'Y') then
              paywsdyg_pkg.enable_trigger(l_trigger_name,
                                          TRUE);
             else
              paywsdyg_pkg.enable_trigger(l_trigger_name,
                                          FALSE);
             end if;
           end if;
        END IF;
      end if;
end generate_trigger_event;
--
----------------------------- create_trigger_event --------------------------
/*
   NAME
      create_trigger_event
   NOTES
      Inserts/Updates the PAY_TRIGGER_EVENTS table.
*/
procedure create_trigger_event (
                                p_short_name varchar2,
                                p_table_name varchar2,
                                p_description varchar2,
                                p_generated_flag varchar2,
                                p_enabled_flag varchar2,
                                p_triggering_action varchar2,
                                p_owner  varchar2,
                                p_protected_flag varchar2 default 'N'
                               )
is
l_generated_flag pay_trigger_events.generated_flag%TYPE;
l_enabled_flag   pay_trigger_events.enabled_flag%TYPE;
l_event_id       pay_trigger_events.event_id%TYPE;
l_trigger_name   varchar2(50);
begin
--
    begin
--
      select generated_flag,
             enabled_flag,
             event_id
        into l_generated_flag,
             l_enabled_flag,
             l_event_id
        from pay_trigger_events
       where short_name = p_short_name;
--
      if (l_generated_flag = 'Y') then
         -- Need to drop trigger
         l_trigger_name := paywsdyg_pkg.get_trigger_name
                                      (l_event_id,
                                       p_table_name,
                                       p_triggering_action);
         paywsdyg_pkg.drop_trigger(l_trigger_name);
      end if;
--
      update pay_trigger_events
         set
             table_name = p_table_name,
             triggering_action = p_triggering_action,
             description = p_description,
             generated_flag = p_generated_flag,
             enabled_flag = p_enabled_flag,
             protected_flag = p_protected_flag
       where short_name = p_short_name;
--
    exception
       when no_data_found then
          insert into pay_trigger_events
                      (
                       event_id,
                       table_name,
                       description,
                       generated_flag,
                       enabled_flag,
                       triggering_action,
                       short_name,
                       protected_flag
                      )
          select
                 pay_trigger_events_s.nextval,
                 p_table_name,
                 p_description,
                 p_generated_flag,
                 p_enabled_flag,
                 p_triggering_action,
                 p_short_name,
                 p_protected_flag
            from sys.dual;
    end;
--
end create_trigger_event;
--
----------------------------- create_trg_declaration --------------------------
/*
   NAME
      create_trg_declaration
   NOTES
      Inserts/Updates the PAY_TRIGGER_DECLARATIONS table.
*/
procedure create_trg_declaration (
                                p_short_name varchar2,
                                p_variable_name varchar2,
                                p_data_type varchar2,
                                p_variable_size number,
                                p_owner  varchar2
                               )
is
l_event_id number;
begin
--
    select event_id
      into l_event_id
      from pay_trigger_events
     where short_name = p_short_name;
--
    update pay_trigger_declarations
       set data_type = p_data_type,
           variable_size = p_variable_size
     where event_id = l_event_id
       and variable_name = p_variable_name;
--
     if (SQL%notfound) then
       insert into pay_trigger_declarations
                   (
                    declaration_id,
                    event_id,
                    variable_name,
                    data_type,
                    variable_size
                   )
       select
              pay_trigger_declarations_s.nextval,
              l_event_id,
              p_variable_name,
              p_data_type,
              p_variable_size
         from sys.dual;
--
     end if;
--
end create_trg_declaration;
--
----------------------------- create_trg_initialisation --------------------------
/*
   NAME
      create_trg_initialisation
   NOTES
      Inserts/Updates the PAY_TRIGGER_INITIALISATIONS table.
*/
procedure create_trg_initialisation (
                                p_short_name varchar2,
                                p_process_order varchar2,
                                p_plsql_code varchar2,
                                p_process_type varchar2,
                                p_owner  varchar2
                               )
is
l_event_id number;
begin
--
    select event_id
      into l_event_id
      from pay_trigger_events
     where short_name = p_short_name;
--
    update pay_trigger_initialisations
       set plsql_code = p_plsql_code,
           process_type = p_process_type
     where event_id = l_event_id
       and process_order = p_process_order;
--
     if (SQL%notfound) then
       insert into pay_trigger_initialisations
                   (
                    initialisation_id,
                    event_id,
                    process_order,
                    plsql_code,
                    process_type
                   )
       select
              pay_trigger_initialisations_s.nextval,
              l_event_id,
              p_process_order,
              p_plsql_code,
              p_process_type
         from sys.dual;
--
     end if;
--
end create_trg_initialisation;
--
----------------------------- create_trg_components --------------------------
/*
   NAME
      create_trg_components
   NOTES
      Inserts/Updates the PAY_TRIGGER_COMPONENTS table.
*/
procedure create_trg_components (
                                p_short_name varchar2,
                                p_legislative_code     varchar2,
                                p_business_group       varchar2,
                                p_payroll_name         varchar2,
                                p_module_name          varchar2,
                                p_enabled_flag         varchar2,
                                p_owner  varchar2
                               )
is
l_event_id number;
l_bus_grp_id number;
l_payroll_id number;
l_enabled pay_trigger_components.enabled_flag%TYPE;
begin
--
    if (p_business_group is null) then
        l_bus_grp_id := null;
        l_payroll_id := null;
    else
--
        select business_group_id
          into l_bus_grp_id
          from per_business_groups
         where name = p_business_group;
--
        -- Now setup the payroll.
        if (p_payroll_name is null) then
           l_payroll_id := null;
        else
--
           select distinct payroll_id
             into l_payroll_id
             from pay_payrolls_f
            where business_group_id = l_bus_grp_id
              and payroll_name = p_payroll_name;
        end if;
    end if;
--
    select event_id
      into l_event_id
      from pay_trigger_events
     where short_name = p_short_name;
--
    l_enabled := 'X'; -- Default
    begin
      -- Check if the component we want to create already exists
      select enabled_flag
      into   l_enabled
      from   pay_trigger_components
      where  event_id = l_event_id
       and   nvl(p_legislative_code, 'CORE') = nvl (legislation_code, 'CORE')
       and   nvl(l_bus_grp_id, -1) = nvl(business_group_id, -1)
       and   nvl(l_payroll_id, -1) = nvl(payroll_id, -1)
       and   p_module_name = module_name;
    exception
      when no_data_found then l_enabled := 'C'; -- Not found, need to create
      when others then null; -- Catch everything, leave enabled as default
    end;
--
    /* Removed 12-Apr-2001 by exjones
    update pay_trigger_components
       set enabled_flag = p_enabled_flag
     where event_id = l_event_id
       and nvl(p_legislative_code, 'CORE') = nvl (legislation_code, 'CORE')
       and nvl(l_bus_grp_id, -1) = nvl(business_group_id, -1)
       and nvl(l_payroll_id, -1) = nvl(payroll_id, -1)
       and p_module_name = module_name;
    */
--
     /* if (SQL%notfound) then */
     -- Need to create this component
     if (l_enabled = 'C') then
       insert into pay_trigger_components
                   (
                    component_id,
                    event_id,
                    legislation_code,
                    business_group_id,
                    payroll_id,
                    module_name,
                    enabled_flag
                   )
       select
              pay_trigger_components_s.nextval,
              l_event_id,
              p_legislative_code,
              l_bus_grp_id,
              l_payroll_id,
              p_module_name,
              p_enabled_flag
         from sys.dual;
--
     end if;
--
end create_trg_components;
--
----------------------------- create_trg_components --------------------------
/*
   NAME
      create_trg_components
   NOTES
      Inserts/Updates the PAY_TRIGGER_PARAMETERS table.
*/
procedure create_trg_parameter (p_short_name varchar2,
                                p_process_order varchar2,
                                p_legislative_code     varchar2,
                                p_business_group       varchar2,
                                p_payroll_name         varchar2,
                                p_module_name   varchar2,
                                p_usage_type varchar2,
                                p_parameter_type varchar2,
                                p_parameter_name varchar2,
                                p_value_name varchar2,
                                p_automatic varchar2,
                                p_owner  varchar2
                               )
is
l_event_id number;
l_bus_grp_id number;
l_payroll_id number;
l_usage_id   number;
begin
--
    -- If this is a component get the component id
    IF (p_usage_type = 'C') then

    select event_id
      into l_event_id
      from pay_trigger_events
     where short_name = p_short_name;

      if (p_business_group is null) then
        l_bus_grp_id := null;
        l_payroll_id := null;
      else
--
        select business_group_id
          into l_bus_grp_id
          from per_business_groups
         where name = p_business_group;
--
        -- Now setup the payroll.
        if (p_payroll_name is null) then
           l_payroll_id := null;
        else
--
           select distinct payroll_id
             into l_payroll_id
             from pay_payrolls_f
            where business_group_id = l_bus_grp_id
              and payroll_name = p_payroll_name;
        end if;
      end if;
--
      select component_id
        into l_usage_id
        from pay_trigger_components
       where event_id = l_event_id
       and nvl(p_legislative_code, 'CORE') = nvl (legislation_code, 'CORE')
       and nvl(l_bus_grp_id, -1) = nvl(business_group_id, -1)
       and nvl(l_payroll_id, -1) = nvl(payroll_id, -1)
       and p_module_name = module_name;
--
    ELSIF (p_usage_type = 'I') then
--
      -- It must be an initialisation.
--
    select event_id
      into l_event_id
      from pay_trigger_events
     where short_name = p_short_name;

      select initialisation_id
        into l_usage_id
        from pay_trigger_initialisations
       where event_id = l_event_id
         and process_order = p_process_order;
--
    ELSE
      -- It must be a parameter for a dynamic trigger package
      -- Eg type in PI, PU, PD

    select dated_table_id
      into l_usage_id
      from pay_dated_tables
     where table_name = p_short_name;

    END IF;
--
    update pay_trigger_parameters
       set automatic = p_automatic,
           value_name = p_value_name
     where usage_id = l_usage_id
       and usage_type = p_usage_type
       and parameter_type = p_parameter_type
       and upper(nvl(parameter_name, 'NULL')) =
                    upper(nvl(p_parameter_name, 'NULL'));
--
     if (SQL%notfound) then
       insert into pay_trigger_parameters
                   (
                    parameter_id,
                    usage_type,
                    usage_id,
                    parameter_type,
                    parameter_name,
                    value_name,
                    automatic
                   )
       select
              pay_trigger_parameters_s.nextval,
              p_usage_type,
              l_usage_id,
              p_parameter_type,
              p_parameter_name,
              p_value_name,
              p_automatic
         from sys.dual;
--
     end if;
--
end create_trg_parameter;
--
--
----------------------------- create_func_area --------------------------
/*
   NAME
      create_func_area
   NOTES
      Inserts/Updates the PAY_FUNCTIONAL_AREAS table.
*/
procedure create_func_area (p_area_name varchar2,
                            p_description varchar2
                               )
is
begin
--
    update pay_functional_areas
       set
           description = p_description
     where short_name = p_area_name;
--
     if (SQL%notfound) then
       insert into pay_functional_areas
                   (
                    area_id,
                    short_name,
                    description
                   )
       select
              pay_functional_areas_s.nextval,
              p_area_name,
              p_description
         from sys.dual;
--
     end if;
--
end create_func_area;
--
----------------------------- create_func_trigger --------------------------
/*
   NAME
      create_func_trigger
   NOTES
      Inserts/Updates the PAY_FUNCTIONAL_TRIGGERS table.
*/
procedure create_func_trigger (p_area_name varchar2
			      ,p_short_name varchar2
			      ,p_owner varchar2
                               )
is
--
l_event_id number;
l_area_id  number;
begin
--
    select event_id
      into l_event_id
      from pay_trigger_events
     where short_name = p_short_name;
--
    select area_id
      into l_area_id
      from pay_functional_areas
     where short_name = p_area_name;
--
             if(p_OWNER='SEED') then
               	   hr_general2.init_fndload(800,1);
	      else
               	   hr_general2.init_fndload(800,-1);
	      end if;

       insert into pay_functional_triggers
                   (
                    trigger_id,
                    area_id,
                    event_id
                   )
       select
              pay_functional_triggers_s.nextval,
              l_area_id,
              l_event_id
         from sys.dual
        where not exists (select ''
                            from pay_functional_triggers
                           where area_id = l_area_id
                             and event_id = l_event_id);
--
end create_func_trigger;
--
----------------------------- create_event_update --------------------------
/*
   NAME
      create_event_update
   NOTES
      Inserts/Updates the PAY_EVENT_UPDATES table.
*/
procedure create_event_update (p_table_name varchar2,
                               p_column_name varchar2,
                               p_business_group_name  varchar2,
                               p_legislation_code varchar2,
                               p_change_type varchar2
                               )
is
l_business_group_id number;
begin
--
   if (p_business_group_name is not null) then
     select business_group_id
       into l_business_group_id
       from per_business_groups
      where name = p_business_group_name;
   else
      l_business_group_id := null;
   end if;
--
   insert into pay_event_updates
               (event_update_id,
                table_name,
                column_name,
                business_group_id,
                legislation_code,
                change_type
               )
   select pay_event_updates_s.nextval,
          p_table_name,
          p_column_name,
          l_business_group_id,
          p_legislation_code,
          p_change_type
     from sys.dual
    where not exists (select ''
                        from pay_event_updates
                       where table_name = p_table_name
                         and column_name = p_column_name
                         and nvl(business_group_id, -999) = nvl(l_business_group_id, -999)
                         and nvl(legislation_code, 'CORE') = nvl(p_legislation_code, 'CORE')
                         and p_change_type = change_type);
--
end create_event_update;
--

----------------------------- create_func_usage --------------------------
/*
   NAME
      create_func_usage
   NOTES
      Inserts/Updates the PAY_FUNCTIONAL_USAGES table.
*/
procedure create_func_usage   (p_area_name		varchar2
                              ,p_usage_id		varchar2
			      ,p_business_group_name	varchar2
			      ,p_legislation_code	varchar2
			      ,p_payroll_name		varchar2
			      ,p_owner			varchar2
			      )
is
--
cursor csr_sel_area_id(p_area_name	varchar2) is
select area_id
from   pay_functional_areas
where  upper(short_name) = upper(p_area_name);

cursor csr_sel_payroll_id(p_payroll_name varchar2) is
select payroll_id
from pay_payrolls_f
where upper(payroll_name)= upper(p_payroll_name);

cursor csr_sel_bgid(p_business_group_name varchar2) is
select business_group_id
from   per_business_groups
where  upper(name) = upper(p_business_group_name);

l_area_id  number;
l_business_group_id number;
l_payroll_id number;

begin
--
    open csr_sel_area_id(p_area_name);
    fetch csr_sel_area_id into l_area_id;
    if(csr_sel_area_id%notfound) then
        null;
    else
        if (p_payroll_name is not null) then
	    open csr_sel_payroll_id(p_payroll_name);
	    fetch csr_sel_payroll_id into l_payroll_id;
	else
	    l_payroll_id :=NULL;
	end if;

	if(p_business_group_name is not null) then
	    open csr_sel_bgid(p_business_group_name);
	    fetch csr_sel_bgid into l_business_group_id;
	else
	    l_business_group_id :=NULL;
	end if;

	if(p_OWNER='SEED') then
	   hr_general2.init_fndload(800,1);
	else
	   hr_general2.init_fndload(800,-1);
	end if;

        insert into pay_functional_usages
        (
        usage_id,
        area_id,
        business_group_id,
	legislation_code,
	payroll_id
        )
	select
        to_number(p_usage_id),
        l_area_id,
        l_business_group_id,
	p_legislation_code,
	l_payroll_id
	from sys.dual
	where not exists( select 'X'
	                  from pay_functional_usages
		          where area_id = l_area_id
		          and usage_id =to_number(p_usage_id)
			);

	if(p_business_group_name is not null) then
            close csr_sel_bgid;
	end if;

	if(p_payroll_name is not null) then
	    close csr_sel_payroll_id;
	end if;

    end if;
    close csr_sel_area_id;
--
end create_func_usage;
--

--------------------------------
-- Get the dated table name given ID, used in view PAY_DATETRACKED_EVENTS_V
--
function RETURN_DATED_TABLE_NAME (p_dated_table_id number) return varchar2 is

l_table_name  varchar2(120);
cursor get_dt_name is
  select table_name
  from pay_dated_tables
  where dated_table_id = p_dated_table_id;

begin
  open get_dt_name;
  fetch get_dt_name into l_table_name;
  close get_dt_name;

  return l_table_name;
end RETURN_DATED_TABLE_NAME;

end pay_dyn_triggers;

/
