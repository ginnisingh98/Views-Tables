--------------------------------------------------------
--  DDL for Package Body PAY_KR_REPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_KR_REPORT_PKG" as
/* $Header: pykrrept.pkb 120.2 2005/08/12 02:50:52 mmark noship $ */
--
-- Global Variables.
--
g_business_group_id           number;
g_legislation_code            varchar2(2);
g_effective_date              date;
g_assignment_action_id        number;
g_xassignment_action_id       number;
g_pre_get_balance_value_index number;
g_pre_get_dbitem_value_index  number;
g_debug                       constant boolean   :=  hr_utility.debug_enabled;
--
type value_tbl is table of ff_archive_items.value%type index by binary_integer;
type balance_name_tbl is table of pay_balance_types.balance_name%type index by binary_integer;
type dimension_name_tbl is table of pay_balance_dimensions.dimension_name%type index by binary_integer;
type defined_balance_id_tbl is table of pay_defined_balances.defined_balance_id%type index by binary_integer;
type user_entity_id_tbl is table of ff_user_entities.user_entity_id%type index by binary_integer;
type user_entity_name_tbl is table of ff_user_entities.user_entity_name%type index by binary_integer;
type user_name_tbl is table of ff_database_items.user_name%type index by binary_integer;
/*
type user_entity_id_tbl is table of ff_archive_items.user_entity_id%type index by binary_integer;
type archive_item_rec is record(
  user_entity_id  user_entity_id_tbl,
  value           value_tbl);
g_archive_item archive_item_rec;
*/
g_archive_item_value_tbl value_tbl;
type pre_get_balance_value_rec is record(
  balance_name       balance_name_tbl,
  dimension_name     dimension_name_tbl,
  defined_balance_id defined_balance_id_tbl,
  user_entity_id     user_entity_id_tbl);
g_pre_get_balance_value pre_get_balance_value_rec;
type pre_get_dbitem_value_rec is record(
  user_entity_id     user_entity_id_tbl,
  user_entity_name   user_entity_name_tbl,
  xuser_entity_id    user_entity_id_tbl,
  xuser_entity_name  user_entity_name_tbl,
  user_name          user_name_tbl);
g_pre_get_dbitem_value pre_get_dbitem_value_rec;
--------------------------------------------------------------------------------
function legislation_code(p_business_group_id in number) return varchar2
--------------------------------------------------------------------------------
is
  l_legislation_code varchar2(2);
  cursor csr_legislation_code
  is
  select legislation_code
  from   per_business_groups_perf
  where  business_group_id = p_business_group_id;
begin
  hr_api.mandatory_arg_error('get_balance_value', 'business_group_id', p_business_group_id);
--
  open csr_legislation_code;
  fetch csr_legislation_code into l_legislation_code;
  if csr_legislation_code%NOTFOUND then
     close csr_legislation_code;
     raise no_data_found;
  end if;
  close csr_legislation_code;
--
  return l_legislation_code;
--
end legislation_code;
--------------------------------------------------------------------------------
procedure pre_get_balance_value(p_business_group_id in number)
--------------------------------------------------------------------------------
is
--
  l_found  boolean := FALSE;
--
  -- cursor modified for bug 3829372
  --
  cursor  csr_pre_get_balance_value
  is
  select
          pbt.balance_name         balance_name,
          pbd.dimension_name       dimension_name,
          pdb.defined_balance_id   defined_balance_id,
          fue.user_entity_id       user_entity_id
  from    ff_user_entities         fue,
          pay_balance_dimensions   pbd,
          pay_defined_balances     pdb,
          pay_balance_types        pbt
  where   decode(pbt.business_group_id, null, g_business_group_id, pbt.business_group_id) = g_business_group_id
  and     decode(pbt.legislation_code, null, g_legislation_code, pbt.legislation_code) = g_legislation_code
  and     pdb.balance_type_id = pbt.balance_type_id
  and     pbd.balance_dimension_id = pdb.balance_dimension_id
  and     decode(pbd.business_group_id, null, g_business_group_id, pbd.business_group_id) = g_business_group_id
  and     decode(pbd.legislation_code, null, g_legislation_code, pbd.legislation_code) = g_legislation_code
  and     fue.user_entity_name = 'A_'||pbt.balance_name||pbd.dimension_name
  and     fue.user_entity_name like 'A%'
  and     fue.creator_type = 'X';
--
begin
--
  if g_business_group_id is null or p_business_group_id <> g_business_group_id then
    g_business_group_id := p_business_group_id;
    g_legislation_code  := legislation_code(p_business_group_id => g_business_group_id);
    g_pre_get_balance_value.balance_name.delete;
    g_pre_get_balance_value.dimension_name.delete;
    g_pre_get_balance_value.defined_balance_id.delete;
    g_pre_get_balance_value.user_entity_id.delete;
    open csr_pre_get_balance_value;
    fetch csr_pre_get_balance_value bulk collect into g_pre_get_balance_value.balance_name,
                                                      g_pre_get_balance_value.dimension_name,
                                                      g_pre_get_balance_value.defined_balance_id,
                                                      g_pre_get_balance_value.user_entity_id;
    close csr_pre_get_balance_value;
  end if;
--
end pre_get_balance_value;
--------------------------------------------------------------------------------
procedure pre_get_dbitem_value(p_business_group_id in number)
--------------------------------------------------------------------------------
is
--
  l_found  boolean := FALSE;
--
  cursor  csr_pre_get_dbitem_value
  is
  select
         fue.user_entity_id	user_entity_id,
         fue.user_entity_name   user_entity_name,
         xfue.user_entity_id	xuser_entity_id,
         xfue.user_entity_name	xuser_entity_name,
         fdi.user_name          user_name
  from   ff_database_items      fdi,
         ff_user_entities       xfue,
         ff_user_entities       fue
  where  nvl(fue.business_group_id,g_business_group_id) = g_business_group_id
  and    nvl(fue.legislation_code,g_legislation_code) = g_legislation_code
  and    xfue.user_entity_name = 'A_'||fue.user_entity_name
  and    xfue.user_entity_name like 'A_%'
  and    nvl(xfue.business_group_id,g_business_group_id) = g_business_group_id
  and    nvl(xfue.legislation_code,g_legislation_code) = g_legislation_code
  and    fdi.user_entity_id = fue.user_entity_id
  and    xfue.creator_type = 'X';
--
begin
--
  if g_business_group_id is null or p_business_group_id <> g_business_group_id then
    g_business_group_id := p_business_group_id;
    g_legislation_code  := legislation_code(p_business_group_id => g_business_group_id);
    g_pre_get_dbitem_value.user_entity_id.delete;
    g_pre_get_dbitem_value.user_entity_name.delete;
    g_pre_get_dbitem_value.xuser_entity_id.delete;
    g_pre_get_dbitem_value.xuser_entity_name.delete;
    g_pre_get_dbitem_value.user_name.delete;
    open csr_pre_get_dbitem_value;
    fetch csr_pre_get_dbitem_value bulk collect into g_pre_get_dbitem_value.user_entity_id,
                                                     g_pre_get_dbitem_value.user_entity_name,
                                                     g_pre_get_dbitem_value.xuser_entity_id,
                                                     g_pre_get_dbitem_value.xuser_entity_name,
                                                     g_pre_get_dbitem_value.user_name;
    close csr_pre_get_dbitem_value;
  end if;
--
end pre_get_dbitem_value;
--------------------------------------------------------------------------------
function get_defined_balance_id(p_balance_name      in varchar2,
                                p_dimension_name    in varchar2,
                                p_business_group_id in number) return number
--------------------------------------------------------------------------------
is
--
  l_defined_balance_id pay_defined_balances.defined_balance_id%type;
  l_index binary_integer;
  l_found boolean := FALSE;
--
  cursor csr_defined_balance_id
  is
  select  pdb.defined_balance_id  defined_balance_id
  from    pay_balance_dimensions pbd,
          pay_defined_balances   pdb,
          pay_balance_types      pbt
  where   pbt.balance_name = p_balance_name
  and     nvl(pbt.business_group_id, g_business_group_id) = g_business_group_id
  and     nvl(pbt.legislation_code, g_legislation_code) = g_legislation_code
  and     pdb.balance_type_id = pbt.balance_type_id
  and     pbd.balance_dimension_id = pdb.balance_dimension_id
  and     pbd.dimension_name = p_dimension_name
  and     nvl(pbd.business_group_id, g_business_group_id) = g_business_group_id
  and     nvl(pbd.legislation_code, g_legislation_code) = g_legislation_code;
--
begin
--
  g_pre_get_balance_value_index := null;
--
  if g_business_group_id is null or p_business_group_id <> g_business_group_id then
    g_business_group_id := p_business_group_id;
    g_legislation_code  := legislation_code(p_business_group_id => g_business_group_id);
    g_pre_get_balance_value.balance_name.delete;
    g_pre_get_balance_value.dimension_name.delete;
    g_pre_get_balance_value.defined_balance_id.delete;
    g_pre_get_balance_value.user_entity_id.delete;
  end if;
--
--  If pre_get_balance_value has been done during the same session
--  before running this function, cache value will be used.
--
--  pre_get_balance_value(p_business_group_id => g_business_group_id);
--
  l_index := g_pre_get_balance_value.defined_balance_id.count;
  if l_index > 0 then
    for i in 1..l_index loop
      if g_pre_get_balance_value.balance_name(i) = p_balance_name
      and g_pre_get_balance_value.dimension_name(i) = p_dimension_name then
        l_defined_balance_id := g_pre_get_balance_value.defined_balance_id(i);
        g_pre_get_balance_value_index := i;
        l_found := TRUE;
        exit;
      end if;
    end loop;
  end if;
--
  if not l_found then
    open csr_defined_balance_id;
    fetch csr_defined_balance_id into l_defined_balance_id;
    close csr_defined_balance_id;
  end if;
--
  return l_defined_balance_id;
--
end get_defined_balance_id;
--------------------------------------------------------------------------------
function get_xbal_user_entity_id(p_defined_balance_id in number,
                                p_business_group_id  in number) return number
--------------------------------------------------------------------------------
is
--
  l_user_entity_id ff_user_entities.user_entity_id%type;
  l_index binary_integer;
  l_found boolean := FALSE;
--
  cursor csr_user_entity_id
  is
  select fue.user_entity_id  user_entity_id
  from   ff_user_entities       fue,
         pay_balance_dimensions pbd,
         pay_balance_types      pbt,
         pay_defined_balances   pdb
  where  pdb.defined_balance_id = p_defined_balance_id
  and    pbt.balance_type_id = pdb.balance_type_id
  and    pbd.balance_dimension_id = pdb.balance_dimension_id
  /* If creator_id is same as source user_entity_id, it might be simple. */
  and    fue.user_entity_name = 'A_'||pbt.balance_name||pbd.dimension_name
  and    fue.creator_type = 'X';
--
begin
--
  if g_business_group_id is null or p_business_group_id <> g_business_group_id then
    g_business_group_id := p_business_group_id;
    g_legislation_code  := legislation_code(p_business_group_id => g_business_group_id);
    g_pre_get_balance_value.balance_name.delete;
    g_pre_get_balance_value.dimension_name.delete;
    g_pre_get_balance_value.defined_balance_id.delete;
    g_pre_get_balance_value.user_entity_id.delete;
  end if;
--
--  If pre_get_balance_value has been done during the same session
--  before running this function, cache value will be used.
--
--  pre_get_balance_value(p_business_group_id => g_business_group_id);
--
  l_index := g_pre_get_balance_value.defined_balance_id.count;
  if l_index > 0 then
    if g_pre_get_balance_value_index is not null then
      if g_pre_get_balance_value.defined_balance_id(g_pre_get_balance_value_index) = p_defined_balance_id then
        l_user_entity_id := g_pre_get_balance_value.user_entity_id(g_pre_get_balance_value_index);
        l_found := TRUE;
      end if;
    end if;
    if not l_found then
      for i in 1..l_index loop
        if g_pre_get_balance_value.defined_balance_id(i) = p_defined_balance_id then
          l_user_entity_id := g_pre_get_balance_value.user_entity_id(i);
          l_found := TRUE;
          exit;
        end if;
      end loop;
    end if;
  end if;
--
  if not l_found then
    open csr_user_entity_id;
    fetch csr_user_entity_id into l_user_entity_id;
    close csr_user_entity_id;
  end if;
--
  return l_user_entity_id;
--
end get_xbal_user_entity_id;
--------------------------------------------------------------------------------
function get_user_entity_id(p_user_name         in varchar2,
                            p_business_group_id in number) return number
--------------------------------------------------------------------------------
is
--
  l_user_entity_id ff_user_entities.user_entity_id%type;
  l_index binary_integer;
  l_found boolean := FALSE;
--
  cursor csr_user_entity_id
  is
  select fue.user_entity_id  user_entity_id
  from   ff_user_entities       fue,
         ff_database_items      fdi
  where  fdi.user_name = p_user_name
  and    fue.user_entity_id = fdi.user_entity_id
  and    nvl(fue.business_group_id,g_business_group_id) = g_business_group_id
  and    nvl(fue.legislation_code,g_legislation_code) = g_legislation_code;
--
begin
--
  if g_business_group_id is null or p_business_group_id <> g_business_group_id then
    g_business_group_id := p_business_group_id;
    g_legislation_code  := legislation_code(p_business_group_id => g_business_group_id);
    g_pre_get_dbitem_value.user_entity_id.delete;
    g_pre_get_dbitem_value.user_entity_name.delete;
    g_pre_get_dbitem_value.xuser_entity_id.delete;
    g_pre_get_dbitem_value.xuser_entity_name.delete;
    g_pre_get_dbitem_value.user_name.delete;
  end if;
--
--  If pre_get_dbitem_value has been done during the same session
--  before running this function, cache value will be used.
--
--  pre_get_dbitem_value(p_business_group_id => g_business_group_id);
--
  l_index := g_pre_get_dbitem_value.user_entity_id.count;
  if l_index > 0 then
    for i in 1..l_index loop
      if g_pre_get_dbitem_value.user_name(i) = p_user_name then
        l_user_entity_id := g_pre_get_dbitem_value.user_entity_id(i);
        g_pre_get_dbitem_value_index := i;
        l_found := TRUE;
        exit;
      end if;
    end loop;
  end if;
--
  if not l_found then
    open csr_user_entity_id;
    fetch csr_user_entity_id into l_user_entity_id;
    close csr_user_entity_id;
  end if;
--
  return l_user_entity_id;
--
end get_user_entity_id;
--------------------------------------------------------------------------------
function get_xdbitem_user_entity_id(p_user_entity_id    in number,
                                    p_business_group_id in number) return number
--------------------------------------------------------------------------------
is
--
  l_xuser_entity_id ff_user_entities.user_entity_id%type;
  l_index binary_integer;
  l_found boolean := FALSE;
--
  cursor csr_xuser_entity_id
  is
  select xfue.user_entity_id  xuser_entity_id
  from   ff_user_entities       xfue,
         ff_user_entities       fue
  where  fue.user_entity_id = p_user_entity_id
  and    xfue.user_entity_name = 'A_'||fue.user_entity_name
  and    nvl(xfue.business_group_id,g_business_group_id) = g_business_group_id
  and    nvl(xfue.legislation_code,g_legislation_code) = g_legislation_code
  and    xfue.creator_type = 'X';
--
begin
--
  if g_business_group_id is null or p_business_group_id <> g_business_group_id then
    g_business_group_id := p_business_group_id;
    g_legislation_code  := legislation_code(p_business_group_id => g_business_group_id);
    g_pre_get_dbitem_value.user_entity_id.delete;
    g_pre_get_dbitem_value.user_entity_name.delete;
    g_pre_get_dbitem_value.xuser_entity_id.delete;
    g_pre_get_dbitem_value.xuser_entity_name.delete;
    g_pre_get_dbitem_value.user_name.delete;
  end if;
--
--  If pre_get_dbitem_value has been done during the same session
--  before running this function, cache value will be used.
--
--  pre_get_dbitem_value(p_business_group_id => g_business_group_id);
--
  l_index := g_pre_get_dbitem_value.user_entity_id.count;
  if l_index > 0 then
    if g_pre_get_dbitem_value_index is not null then
      if g_pre_get_dbitem_value.user_entity_id(g_pre_get_dbitem_value_index) = p_user_entity_id then
        l_xuser_entity_id := g_pre_get_dbitem_value.xuser_entity_id(g_pre_get_dbitem_value_index);
        l_found := TRUE;
      end if;
    end if;
    if not l_found then
      for i in 1..l_index loop
        if g_pre_get_dbitem_value.user_entity_id(i) = p_user_entity_id then
          l_xuser_entity_id := g_pre_get_dbitem_value.xuser_entity_id(i);
          l_found := TRUE;
          exit;
        end if;
      end loop;
    end if;
  end if;
--
  if not l_found then
    open csr_xuser_entity_id;
    fetch csr_xuser_entity_id into l_xuser_entity_id;
    close csr_xuser_entity_id;
  end if;
--
  return l_xuser_entity_id;
--
end get_xdbitem_user_entity_id;
--------------------------------------------------------------------------------
function get_latest_assact(p_assignment_id       in number,
                           p_business_group_id   in number,
                           p_effective_date_from in date,
                           p_effective_date_to   in date,
                           p_type                in varchar2) return number
                           /* p_type : Run Type Name or Report Category||Report Type    */
                           /*                           (NYEA,RYEA,IYEA,NHIA,RHIA,IHIA) */
--------------------------------------------------------------------------------
is
--
  l_run_type_id                 number;
  l_assignment_action_id        number;
--
  cursor csr_run_type
  is
  select run_type_id
  from   pay_run_types_f
  where  run_type_name = p_type
  and    g_effective_date
         between effective_start_date and effective_end_date
  and    nvl(business_group_id, g_business_group_id) = g_business_group_id
  and    nvl(legislation_code, g_legislation_code) = g_legislation_code;
--
 --  Bug 3899570 : Optimized query for csr_latest_assact_run_type
 -- 		   (From performance repository SQLID: 9609734)
  cursor csr_latest_assact_run_type
  is
  select	assignment_action_id
  from 		pay_assignment_actions paa
  where 	paa.assignment_id = p_assignment_id
  and  		paa.run_type_id = l_run_type_id
  and 		paa.action_sequence =
  		(
                	select 	max(paa2.action_sequence)
                	from   	pay_payroll_actions    ppa2,
                        	pay_assignment_actions paa2
                	where  	paa2.assignment_id = p_assignment_id
                	and    	paa2.run_type_id = l_run_type_id
                	and    	paa2.action_status in ('C', 'S') -- Bug 4442484: Include 'S'kipped assacts
                	and    	ppa2.payroll_action_id = paa2.payroll_action_id
                	and    	ppa2.effective_date
                        	between p_effective_date_from and p_effective_date_to
                	and    	ppa2.action_type in ('R','Q','I','V','B')
		) ;
  -- End of 3899570
--
  cursor csr_latest_assact_report_type
  is
  select paa.assignment_action_id
  from   pay_payroll_actions    ppa,
         pay_assignment_actions paa
  where  paa.assignment_id = p_assignment_id
  and    paa.run_type_id is null
  and    paa.action_status in ('C', 'S') -- Bug 4442484: Include 'S'kipped assacts
  and    ppa.payroll_action_id = paa.payroll_action_id
  and    ppa.effective_date
         between p_effective_date_from and p_effective_date_to
  and    ppa.action_type = 'B'
  and    ppa.report_type = decode(substr(lpad(p_type,4),2,4),'HIA','HIA','YEA')
  and    ppa.report_category = decode(substr(lpad(p_type,4),1,1),'I','I','R','R','N')
  and    ppa.report_qualifier = 'KR'
  and    not exists(
                select  null
                from    pay_payroll_actions    ppa2,
                        pay_assignment_actions paa2
                where   paa2.assignment_id = paa.assignment_id
                and     paa2.run_type_id is null
                and     paa2.action_status in ('C', 'S') -- Bug 4442484: Include 'S'kipped assacts
                and     ppa2.payroll_action_id = paa2.payroll_action_id
                and     ppa2.effective_date
                        between p_effective_date_from and p_effective_date_to
                and     ppa2.action_type = 'B'
                and     ppa2.report_type = decode(substr(lpad(p_type,4),2,4),'HIA','HIA','YEA')
                and     ppa2.report_category = decode(substr(lpad(p_type,4),1,1),'I','I','R','R','N')
                and     ppa2.report_qualifier = 'KR'
                and     paa2.action_sequence > paa.action_sequence);
--
begin
--
  if g_effective_date is null then
      select  effective_date
      into    g_effective_date
      from    fnd_sessions
      where   session_id = userenv('sessionid');
  end if;
--
  if g_business_group_id is null or p_business_group_id <> g_business_group_id then
    g_business_group_id := p_business_group_id;
    g_legislation_code  := legislation_code(p_business_group_id => g_business_group_id);
  end if;
--
  open csr_run_type;
  fetch csr_run_type into l_run_type_id;
  close csr_run_type;
--
  if l_run_type_id is not null then
    open csr_latest_assact_run_type;
    fetch csr_latest_assact_run_type into l_assignment_action_id;
    close csr_latest_assact_run_type;
  else
    open csr_latest_assact_report_type;
    fetch csr_latest_assact_report_type into l_assignment_action_id;
    close csr_latest_assact_report_type;
  end if;
--
  return l_assignment_action_id;
--
end get_latest_assact;
--------------------------------------------------------------------------------
function get_balance_value_asg_run(p_assignment_action_id in number,
                                   p_balance_type_id      in number) return number
--------------------------------------------------------------------------------
is
--
  l_value number;
--
-- There is no latest balance for _ASG_RUN.
-- Therefore, Collect balance result directly instead of using pay_balance_pkg.get_value.
--
  cursor csr_balance_value
  is
  select
         nvl(sum(fnd_number.canonical_to_number(prrv.result_value) * pbf.scale),0)   value
  from   pay_balance_feeds_f    pbf,
         pay_run_result_values  prrv,
         pay_run_results        prr,
         pay_payroll_actions    ppa,
         pay_assignment_actions paa
  where  paa.assignment_action_id = p_assignment_action_id
  and    ppa.payroll_action_id = paa.payroll_action_id
  and    prr.assignment_action_id = paa.assignment_action_id
  and    prr.status in ('P','PA')
  and    prrv.run_result_id = prr.run_result_id
  and    nvl(prrv.result_value,'0') <> '0'
  and    pbf.input_value_id = prrv.input_value_id
  and    pbf.balance_type_id = p_balance_type_id
  and    ppa.effective_date
         between pbf.effective_start_date and pbf.effective_end_date;
--
begin
--
  open csr_balance_value;
  fetch csr_balance_value into l_value;
  close csr_balance_value;
--
  return l_value;
--
end get_balance_value_asg_run;
--------------------------------------------------------------------------------
function get_archive_items(p_assignment_action_id in number,
                           p_user_entity_id       in number) return varchar2
--------------------------------------------------------------------------------
is
--
--  l_value                  ff_archive_items.value%type;
--  l_index                  binary_integer;
--  l_found                  boolean := FALSE;
  type user_entity_id_tbl is table of ff_archive_items.user_entity_id%type index by binary_integer;
  l_user_entity_id_tbl     user_entity_id_tbl;
  l_archive_item_value_tbl value_tbl;
--
  cursor csr_archive
  is
  select fai.user_entity_id,
         fai.value
  from   ff_archive_items       fai
  where  fai.context1 = p_assignment_action_id
  and    fai.value is not null;
--
begin
--
  hr_api.mandatory_arg_error('get_archive_items', 'assignment_action_id', p_assignment_action_id);
  hr_api.mandatory_arg_error('get_archive_items', 'user_entity_id', p_user_entity_id);

  if g_debug then
    hr_utility.trace('get_archive_items assignment_action_id : ' || p_assignment_action_id);
    hr_utility.trace('get_archive_items user_entity_id : ' || p_user_entity_id);
  end if;
  --
  -- Cache new information into global variables if cache information is old.
  --
  if g_assignment_action_id is null or p_assignment_action_id <> g_assignment_action_id then
    --
    -- Bulk collect statement is efficient for better performance.
    --
    open csr_archive;
    fetch csr_archive bulk collect into l_user_entity_id_tbl, l_archive_item_value_tbl;
    close csr_archive;
    --
    -- Re-construct archive item values to user_entity_id indexed PL/SQL table.
    --
    g_archive_item_value_tbl.delete;
    for i in 1..l_user_entity_id_tbl.count loop
      g_archive_item_value_tbl(l_user_entity_id_tbl(i)) := l_archive_item_value_tbl(i);
    end loop;
    g_assignment_action_id := p_assignment_action_id;
  end if;
  --
  if g_archive_item_value_tbl.exists(p_user_entity_id) then
    return g_archive_item_value_tbl(p_user_entity_id);
  else
    return null;
  end if;
/*
  l_index := g_archive_item.user_entity_id.count;
  for i in 1..l_index loop
    if g_archive_item.user_entity_id(i) = p_user_entity_id then
      l_value := g_archive_item.value(i);
      l_found := TRUE;
      exit;
    end if;
  end loop;
--
  if not l_found then
    open csr_archive;
    fetch csr_archive bulk collect into g_archive_item.user_entity_id, g_archive_item.value;
    close csr_archive;
--
    for i in 1..g_archive_item.user_entity_id.count loop
      if g_archive_item.user_entity_id(i) = p_user_entity_id then
         l_value := g_archive_item.value(i);
         exit;
      end if;
    end loop;
--
  end if;
--
  return l_value;
*/
--
end get_archive_items;
--------------------------------------------------------------------------------
function get_balance_value(p_assignment_action_id in number,
                           p_defined_balance_id in number) return varchar2
--------------------------------------------------------------------------------
is
--
  l_value                      varchar2(240);
  l_user_entity_id             number;
  l_business_group_id number;
  l_cache             varchar2(1);
  l_archive           varchar2(1);
--
-- Not support for multi action for same action_id
--
  cursor csr_xassact
  is
  select ppa.business_group_id,
         paa.assignment_action_id,
         nvl(xpaa.assignment_action_id,-1)
  from   pay_payroll_actions    xppa,
         pay_assignment_actions xpaa,
         pay_action_interlocks  pai,
         pay_payroll_actions    ppa,
         pay_assignment_actions paa
  where  paa.assignment_action_id = p_assignment_action_id
  and    ppa.payroll_action_id = paa.payroll_action_id
  and    pai.locked_action_id (+) = paa.assignment_action_id
  and    xpaa.assignment_action_id (+) = pai.locking_action_id
  and    xpaa.action_status (+) in ('C', 'S') -- Bug 4442484: Include 'S'kipped assacts
  and    xppa.payroll_action_id (+) = xpaa.payroll_action_id
  and    xppa.action_type (+) = 'X';
--
begin
--
  l_cache     := 'N';
  l_archive   := 'N';
--
  hr_api.mandatory_arg_error('get_balance_value', 'assignment_action_id', p_assignment_action_id);
  hr_api.mandatory_arg_error('get_balance_value', 'defined_balance_id', p_defined_balance_id);
--
  if g_business_group_id is null then
     l_cache := 'Y';
  else
     l_business_group_id := g_business_group_id;
  end if;
  if g_business_group_id is null
     or g_assignment_action_id is null
     or g_xassignment_action_id < 0
     or p_assignment_action_id <> g_assignment_action_id then
    open csr_xassact;
    fetch csr_xassact into g_business_group_id, g_assignment_action_id, g_xassignment_action_id;
    close csr_xassact;
    if l_cache = 'N' and l_business_group_id <> g_business_group_id then
       l_cache := 'Y';
    end if;
    if g_xassignment_action_id > 0 then
       l_archive := 'Y';
    else
       l_archive := 'N';
    end if;
    g_legislation_code := legislation_code(p_business_group_id => g_business_group_id);
  end if;
--
  if g_debug then
    hr_utility.trace('get_balance_value g_pre_get_balance_value_perf : ' || g_pre_get_balance_value_perf);
  end if;
--
  if g_pre_get_balance_value_perf = 'Y' then
    l_business_group_id := g_business_group_id;
    if l_cache = 'Y' then
       g_business_group_id := null;
    end if;
    pre_get_balance_value(p_business_group_id => l_business_group_id);
  end if;
--
  if g_xassignment_action_id > 0 and l_archive = 'Y' then
    l_user_entity_id := get_xbal_user_entity_id(p_defined_balance_id => p_defined_balance_id,
                                                p_business_group_id  => g_business_group_id);
    l_value := get_archive_items(p_assignment_action_id => g_xassignment_action_id,
                                 p_user_entity_id => l_user_entity_id);
  else
    l_value := pay_balance_pkg.get_value(p_defined_balance_id => p_defined_balance_id,
                                         p_assignment_action_id => p_assignment_action_id);
  end if;
--
  return l_value;
--
end get_balance_value;
--------------------------------------------------------------------------------
function get_balance_value(p_assignment_action_id in number,
                           p_balance_name in varchar2,
                           p_dimension_name in varchar2) return varchar2
--------------------------------------------------------------------------------
is
--
  l_value                 varchar2(240);
  l_defined_balance_id    number;
  l_business_group_id number;
  l_cache             varchar2(1);
--
-- Not support for multi action for same action_id
--
  cursor csr_assact
  is
  select ppa.business_group_id,
         paa.assignment_action_id
  from   pay_payroll_actions    ppa,
         pay_assignment_actions paa
  where  paa.assignment_action_id = p_assignment_action_id
  and    ppa.payroll_action_id = paa.payroll_action_id;
--
begin
--
  l_cache   := 'N';
--
  hr_api.mandatory_arg_error('get_balance_value', 'assignment_action_id', p_assignment_action_id);
  hr_api.mandatory_arg_error('get_balance_value', 'balance_name', p_balance_name);
  hr_api.mandatory_arg_error('get_balance_value', 'dimension_name', p_dimension_name);
--
  if g_business_group_id is null then
     l_cache := 'Y';
  else
     l_business_group_id := g_business_group_id;
  end if;
  if g_business_group_id is null
     or g_assignment_action_id is null
     or g_assignment_action_id <> p_assignment_action_id then
    open csr_assact;
    fetch csr_assact into g_business_group_id, g_assignment_action_id;
    close csr_assact;
    if l_cache = 'N' and l_business_group_id <> g_business_group_id then
       l_cache := 'Y';
    end if;
    g_legislation_code := legislation_code(p_business_group_id => g_business_group_id);
  end if;
--
  if g_debug then
    hr_utility.trace('get_balance_value g_pre_get_balance_value_perf : ' || g_pre_get_balance_value_perf);
  end if;
--
  if g_pre_get_balance_value_perf = 'Y' then
    l_business_group_id := g_business_group_id;
    if l_cache = 'Y' then
       g_business_group_id := null;
    end if;
    pre_get_balance_value(p_business_group_id => l_business_group_id);
  end if;
--
  l_defined_balance_id := get_defined_balance_id(p_balance_name      => p_balance_name,
                                                 p_dimension_name    => p_dimension_name,
                                                 p_business_group_id => g_business_group_id);
--
  l_value := get_balance_value(p_assignment_action_id => g_assignment_action_id,
                               p_defined_balance_id   => l_defined_balance_id);
--
  return l_value;
--
end get_balance_value;
--------------------------------------------------------------------------------
function get_dbitem_value(p_assignment_action_id in number,
                          p_user_entity_id       in number) return varchar2
--------------------------------------------------------------------------------
is
--
  l_value             ff_archive_items.value%type;
  l_xuser_entity_id   number;
  l_business_group_id number;
  l_archive           varchar2(1);
  l_cache             varchar2(1);
--
  l_user_name          ff_database_items.user_name%type;
  l_payroll_id         pay_payroll_actions.payroll_id%type;
  l_payroll_action_id  pay_payroll_actions.payroll_action_id%type;
  l_assignment_id      pay_assignment_actions.assignment_id%type;
  l_date_earned        pay_payroll_actions.date_earned%type;
  l_tax_unit_id        pay_assignment_actions.tax_unit_id%type;
--
-- Not support for multi action for same action_id
--
  cursor csr_xassact
  is
  select ppa.business_group_id,
         paa.assignment_action_id,
         nvl(xpaa.assignment_action_id,-1)
  from   pay_payroll_actions    xppa,
         pay_assignment_actions xpaa,
         pay_action_interlocks  pai,
         pay_payroll_actions    ppa,
         pay_assignment_actions paa
  where  paa.assignment_action_id = p_assignment_action_id
  and    ppa.payroll_action_id = paa.payroll_action_id
  and    pai.locked_action_id (+) = paa.assignment_action_id
  and    xpaa.assignment_action_id (+) = pai.locking_action_id
  and    xpaa.action_status (+) in ('C', 'S') -- Bug 4442484: Include 'S'kipped assacts
  and    xppa.payroll_action_id (+) = xpaa.payroll_action_id
  and    xppa.action_type (+) = 'X';
--
-- Not Support multiple dbitem for one user entity like max and min and default
-- and multiple action.
--
  cursor csr_context
  is
  select ppa.payroll_id        payroll_id,
         ppa.payroll_action_id payroll_action_id,
         paa.assignment_id     assignment_id,
         ppa.date_earned       date_earned,
         paa.tax_unit_id       tax_unit_id,
         fdi.user_name	       user_name
  from   ff_database_items      fdi,
         pay_payroll_actions    ppa,
         pay_assignment_actions paa
  where  paa.assignment_action_id = g_assignment_action_id
  and    ppa.payroll_action_id = paa.payroll_action_id
  and    fdi.user_entity_id = p_user_entity_id;
--
begin
--
  l_archive   := 'N';
  l_cache     := 'N';
--
  hr_api.mandatory_arg_error('get_dbitem_value', 'assignment_action_id', p_assignment_action_id);
  hr_api.mandatory_arg_error('get_dbitem_value', 'user_entity_id', p_user_entity_id);

  if g_debug then
    hr_utility.trace('get_dbitem_value assignment_action_id : ' || p_assignment_action_id);
    hr_utility.trace('get_dbitem_value user_entity_id : ' || p_user_entity_id);
  end if;
  --
  -- Cache new information into global variables if cache information is old.
  --
  if g_business_group_id is null then
     l_cache := 'Y';
  else
     l_business_group_id := g_business_group_id;
  end if;
  if g_business_group_id is null
     or g_assignment_action_id is null
     or g_xassignment_action_id < 0
     or p_assignment_action_id <> g_assignment_action_id then
    open csr_xassact;
    fetch csr_xassact into g_business_group_id, g_assignment_action_id, g_xassignment_action_id;
    close csr_xassact;
    if l_cache = 'N' and l_business_group_id <> g_business_group_id then
       l_cache := 'Y';
    end if;
    if g_xassignment_action_id > 0 then
       l_archive := 'Y';
    else
       l_archive := 'N';
    end if;
    g_legislation_code := legislation_code(p_business_group_id => g_business_group_id);
  end if;
--
  if g_pre_get_dbitem_value_perf = 'Y' then
    l_business_group_id := g_business_group_id;
    if l_cache = 'Y' then
       g_business_group_id := null;
    end if;
    pre_get_dbitem_value(p_business_group_id => l_business_group_id);
  end if;
--
  if g_xassignment_action_id > 0 and l_archive = 'Y' then
    l_xuser_entity_id := get_xdbitem_user_entity_id(p_user_entity_id => p_user_entity_id,
                                                   p_business_group_id => g_business_group_id);
    l_value := get_archive_items(p_assignment_action_id => g_xassignment_action_id,
                                 p_user_entity_id => l_xuser_entity_id);
  else
    open csr_context;
    fetch csr_context into l_payroll_id,
                           l_payroll_action_id,
                           l_assignment_id,
                           l_date_earned,
                           l_tax_unit_id,
                           l_user_name;
    close csr_context;
    pay_balance_pkg.set_context('BUSINESS_GROUP_ID', g_business_group_id);
    pay_balance_pkg.set_context('PAYROLL_ID', l_payroll_id);
    pay_balance_pkg.set_context('PAYROLL_ACTION_ID', l_payroll_action_id);
    pay_balance_pkg.set_context('ASSIGNMENT_ID', l_assignment_id);
    pay_balance_pkg.set_context('ASSIGNMENT_ACTION_ID', g_assignment_action_id);
    pay_balance_pkg.set_context('DATE_EARNED', fnd_date.date_to_canonical(l_date_earned));
    pay_balance_pkg.set_context('TAX_UNIT_ID', l_tax_unit_id);
    l_value := pay_balance_pkg.run_db_item(p_database_name => l_user_name,
                                           p_bus_group_id => g_business_group_id,
                                          p_legislation_code => g_legislation_code);
  end if;
--
  return l_value;
--
end get_dbitem_value;
--------------------------------------------------------------------------------
function get_dbitem_value(p_assignment_action_id in number,
                          p_user_name            in varchar2) return varchar2
--------------------------------------------------------------------------------
is
--
  l_value           ff_archive_items.value%type;
  l_user_entity_id  number;
  l_business_group_id number;
  l_cache             varchar2(1);
--
-- Not support for multi action for same action_id
--
  cursor csr_assact
  is
  select ppa.business_group_id,
         paa.assignment_action_id
  from   pay_payroll_actions    ppa,
         pay_assignment_actions paa
  where  paa.assignment_action_id = p_assignment_action_id
  and    ppa.payroll_action_id = paa.payroll_action_id;
--
begin
--
  l_cache    := 'N';
--
  hr_api.mandatory_arg_error('get_dbitem_value', 'assignment_action_id', p_assignment_action_id);
  hr_api.mandatory_arg_error('get_dbitem_value', 'user_name', p_user_name);

  if g_debug then
    hr_utility.trace('get_dbitem_value assignment_action_id : ' || p_assignment_action_id);
    hr_utility.trace('get_dbitem_value user_name : ' || p_user_name);
  end if;
  --
  if g_business_group_id is null then
     l_cache := 'Y';
  else
     l_business_group_id := g_business_group_id;
  end if;
  if g_business_group_id is null
     or g_assignment_action_id is null
     or g_xassignment_action_id is null
     or g_assignment_action_id <> p_assignment_action_id then
    g_xassignment_action_id := null;
    open csr_assact;
    fetch csr_assact into g_business_group_id, g_assignment_action_id;
    close csr_assact;
    if l_cache = 'N' and l_business_group_id <> g_business_group_id then
       l_cache := 'Y';
    end if;
    g_legislation_code := legislation_code(p_business_group_id => g_business_group_id);
  end if;
--
  if g_pre_get_dbitem_value_perf = 'Y' then
    l_business_group_id := g_business_group_id;
    if l_cache = 'Y' then
       g_business_group_id := null;
    end if;
    pre_get_dbitem_value(p_business_group_id => l_business_group_id);
  end if;
--
  l_user_entity_id := get_user_entity_id(p_user_name  => p_user_name,
                                         p_business_group_id => g_business_group_id);
--
  l_value := get_dbitem_value(p_assignment_action_id => g_assignment_action_id,
                              p_user_entity_id => l_user_entity_id);
--
  return l_value;
--
end get_dbitem_value;
--------------------------------------------------------------------------------
function get_result_value_date(p_assignment_action_id in number,
                               p_business_group_id    in number,
                               p_element_type_name    in varchar2,
                               p_input_value_name     in varchar2) return date
--------------------------------------------------------------------------------
is
--
  l_element_type_id number;
  l_input_value_id number;
  l_value date;
--
  cursor csr_input_value
  is
  select pet.element_type_id,
         piv.input_value_id
  from   pay_input_values_f     piv,
         pay_element_types_f    pet,
         pay_payroll_actions    ppa,
         pay_assignment_actions paa
  where  paa.assignment_action_id = p_assignment_action_id
  and    ppa.payroll_action_id = paa.payroll_action_id
  and    pet.element_name = p_element_type_name
  and    nvl(pet.business_group_id, g_business_group_id) = g_business_group_id
  and    nvl(pet.legislation_code, g_legislation_code) = g_legislation_code
  and    ppa.effective_date
         between pet.effective_start_date and pet.effective_end_date
  and    piv.element_type_id = pet.element_type_id
  and    piv.name = p_input_value_name
  and    ppa.effective_date
         between piv.effective_start_date and piv.effective_end_date;
--
begin
--
  l_value := NULL;
--
  if g_business_group_id is null or p_business_group_id <> g_business_group_id then
    g_business_group_id := p_business_group_id;
    g_legislation_code  := legislation_code(p_business_group_id => g_business_group_id);
  end if;
--
  open csr_input_value;
  fetch csr_input_value into l_element_type_id,l_input_value_id;
  if csr_input_value%notfound then
    raise no_data_found;
  end if;
  close csr_input_value;
--
  l_value := get_result_value_date(p_assignment_action_id => p_assignment_action_id,
                                   p_business_group_id    => p_business_group_id,
                                   p_element_type_id      => l_element_type_id,
                                   p_input_value_id       => l_input_value_id);
--
  return l_value;
--
end get_result_value_date;
--------------------------------------------------------------------------------
function get_result_value_date(p_assignment_action_id in number,
                               p_business_group_id    in number,
                               p_element_type_id      in number,
                               p_input_value_id       in number) return date
--------------------------------------------------------------------------------
is
--
  l_value date;
--
  cursor csr_result_value
  is
  select
         fnd_date.canonical_to_date(prrv.result_value)	value
  from   pay_run_result_values  prrv,
         pay_run_results        prr,
         pay_payroll_actions    ppa,
         pay_assignment_actions paa
  where  paa.assignment_action_id = p_assignment_action_id
  and    ppa.payroll_action_id = paa.payroll_action_id
  and    prr.assignment_action_id = paa.assignment_action_id
  and    prr.status in ('P','PA')
  and    prr.element_type_id = p_element_type_id
  and    prrv.run_result_id = prr.run_result_id
  and    prrv.input_value_id = p_input_value_id;
--
begin
--
  l_value := NULL;
--
  if g_business_group_id is null or p_business_group_id <> g_business_group_id then
    g_business_group_id := p_business_group_id;
    g_legislation_code  := legislation_code(p_business_group_id => g_business_group_id);
  end if;
--
  open csr_result_value;
  fetch csr_result_value into l_value;
  if csr_result_value%notfound then
    l_value := NULL;
  end if;
  close csr_result_value;
--
  return l_value;
--
end get_result_value_date;
--------------------------------------------------------------------------------
function get_result_value_number(p_assignment_action_id in number,
                                 p_business_group_id    in number,
                                 p_element_type_name    in varchar2,
                                 p_input_value_name     in varchar2) return number
--------------------------------------------------------------------------------
is
--
  l_element_type_id number;
  l_input_value_id number;
  l_value number;
--
  cursor csr_input_value
  is
  select pet.element_type_id,
         piv.input_value_id
  from   pay_input_values_f     piv,
         pay_element_types_f    pet,
         pay_payroll_actions    ppa,
         pay_assignment_actions paa
  where  paa.assignment_action_id = p_assignment_action_id
  and    ppa.payroll_action_id = paa.payroll_action_id
  and    pet.element_name = p_element_type_name
  and    nvl(pet.business_group_id, g_business_group_id) = g_business_group_id
  and    nvl(pet.legislation_code, g_legislation_code) = g_legislation_code
  and    ppa.effective_date
         between pet.effective_start_date and pet.effective_end_date
  and    piv.element_type_id = pet.element_type_id
  and    piv.name = p_input_value_name
  and    ppa.effective_date
         between piv.effective_start_date and piv.effective_end_date;
--
begin
--
  l_value := NULL;
--
  if g_business_group_id is null or p_business_group_id <> g_business_group_id then
    g_business_group_id := p_business_group_id;
    g_legislation_code  := legislation_code(p_business_group_id => g_business_group_id);
  end if;
--
  open csr_input_value;
  fetch csr_input_value into l_element_type_id,l_input_value_id;
  if csr_input_value%notfound then
    raise no_data_found;
  end if;
  close csr_input_value;
--
  l_value := get_result_value_number(p_assignment_action_id => p_assignment_action_id,
                                     p_business_group_id    => p_business_group_id,
                                     p_element_type_id      => l_element_type_id,
                                     p_input_value_id       => l_input_value_id);
--
  return l_value;
--
end get_result_value_number;
--------------------------------------------------------------------------------
function get_result_value_number(p_assignment_action_id in number,
                                 p_business_group_id    in number,
                                 p_element_type_id      in number,
                                 p_input_value_id       in number) return number
--------------------------------------------------------------------------------
is
--
  l_value number;
--
  cursor csr_result_value
  is
  select
         fnd_number.canonical_to_number(prrv.result_value)	value
  from   pay_run_result_values  prrv,
         pay_run_results        prr,
         pay_payroll_actions    ppa,
         pay_assignment_actions paa
  where  paa.assignment_action_id = p_assignment_action_id
  and    ppa.payroll_action_id = paa.payroll_action_id
  and    prr.assignment_action_id = paa.assignment_action_id
  and    prr.status in ('P','PA')
  and    prr.element_type_id = p_element_type_id
  and    prrv.run_result_id = prr.run_result_id
  and    prrv.input_value_id = p_input_value_id;
--
begin
--
  l_value := NULL;
--
  if g_business_group_id is null or p_business_group_id <> g_business_group_id then
    g_business_group_id := p_business_group_id;
    g_legislation_code  := legislation_code(p_business_group_id => g_business_group_id);
  end if;
--
  open csr_result_value;
  fetch csr_result_value into l_value;
  if csr_result_value%notfound then
    l_value := NULL;
  end if;
  close csr_result_value;
--
  return l_value;
--
end get_result_value_number;
--------------------------------------------------------------------------------
function get_result_value_char(p_assignment_action_id in number,
                               p_business_group_id    in number,
                               p_element_type_name    in varchar2,
                               p_input_value_name     in varchar2) return varchar2
--------------------------------------------------------------------------------
is
--
  l_element_type_id number;
  l_input_value_id number;
  l_value pay_run_result_values.result_value%type;
--
  cursor csr_input_value
  is
  select pet.element_type_id,
         piv.input_value_id
  from   pay_input_values_f     piv,
         pay_element_types_f    pet,
         pay_payroll_actions    ppa,
         pay_assignment_actions paa
  where  paa.assignment_action_id = p_assignment_action_id
  and    ppa.payroll_action_id = paa.payroll_action_id
  and    pet.element_name = p_element_type_name
  and    nvl(pet.business_group_id, g_business_group_id) = g_business_group_id
  and    nvl(pet.legislation_code, g_legislation_code) = g_legislation_code
  and    ppa.effective_date
         between pet.effective_start_date and pet.effective_end_date
  and    piv.element_type_id = pet.element_type_id
  and    piv.name = p_input_value_name
  and    ppa.effective_date
         between piv.effective_start_date and piv.effective_end_date;
--
begin
--
  l_value := NULL;
--
  if g_business_group_id is null or p_business_group_id <> g_business_group_id then
    g_business_group_id := p_business_group_id;
    g_legislation_code  := legislation_code(p_business_group_id => g_business_group_id);
  end if;
--
  open csr_input_value;
  fetch csr_input_value into l_element_type_id,l_input_value_id;
  if csr_input_value%notfound then
    raise no_data_found;
  end if;
  close csr_input_value;
--
  l_value := get_result_value_char(p_assignment_action_id => p_assignment_action_id,
                                   p_business_group_id    => p_business_group_id,
                                   p_element_type_id      => l_element_type_id,
                                   p_input_value_id       => l_input_value_id);
--
  return l_value;
--
end get_result_value_char;
--------------------------------------------------------------------------------
function get_result_value_char(p_assignment_action_id in number,
                               p_business_group_id    in number,
                               p_element_type_id      in number,
                               p_input_value_id       in number) return varchar2
--------------------------------------------------------------------------------
is
--
  l_value pay_run_result_values.result_value%type;
--
  cursor csr_result_value
  is
  select
         prrv.result_value	value
  from   pay_run_result_values  prrv,
         pay_run_results        prr,
         pay_payroll_actions    ppa,
         pay_assignment_actions paa
  where  paa.assignment_action_id = p_assignment_action_id
  and    ppa.payroll_action_id = paa.payroll_action_id
  and    prr.assignment_action_id = paa.assignment_action_id
  and    prr.status in ('P','PA')
  and    prr.element_type_id = p_element_type_id
  and    prrv.run_result_id = prr.run_result_id
  and    prrv.input_value_id = p_input_value_id;
--
begin
--
  l_value := NULL;
--
  if g_business_group_id is null or p_business_group_id <> g_business_group_id then
    g_business_group_id := p_business_group_id;
    g_legislation_code  := legislation_code(p_business_group_id => g_business_group_id);
  end if;
--
  open csr_result_value;
  fetch csr_result_value into l_value;
  if csr_result_value%notfound then
    l_value := NULL;
  end if;
  close csr_result_value;
--
  return l_value;
--
end get_result_value_char;

--
-- Bug 4442482: Added new function get_result_value

function get_result_value (
	p_run_result_id		in 	pay_run_results.run_result_id%type,
	p_input_value_id	in 	pay_input_values_f.input_value_id%type
) return varchar2 is
	cursor csr_result_value is
		select	result_value
		from 	pay_run_result_values
		where 	run_result_id = p_run_result_id
			and input_value_id = p_input_value_id ;
	--
	l_result 	pay_run_result_values.result_value%type ;
	--
begin
	--
	open 	csr_result_value ;
	fetch	csr_result_value into l_result ;
	if csr_result_value%notfound then
		l_result := null ;
	end if ;
	close	csr_result_value ;
	--
	return 	l_result ;
end get_result_value ;
-- End of 4442482
--
end pay_kr_report_pkg;

/
