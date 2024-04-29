--------------------------------------------------------
--  DDL for Package Body HR_JP_AST_UTILITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_JP_AST_UTILITY_PKG" as
/* $Header: hrjpastu.pkb 120.0.12010000.1 2008/10/14 08:16:03 keyazawa noship $ */
--
-- Constants
--
c_package   constant varchar2(31) := 'hr_jp_ast_utility_pkg.';
--
-- Global Variables
--
g_assignment_set_id number;
g_formula_id    number;
g_amendment_type  varchar2(1);
type t_include_or_exclude_tbl is table of hr_assignment_set_amendments.include_or_exclude%type
  index by binary_integer;
g_include_or_excludes t_include_or_exclude_tbl;
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_assignment_set_name >------------------------|
-- ----------------------------------------------------------------------------
procedure chk_assignment_set_name(
  p_assignment_set_name   in varchar2,
  p_business_group_id   in number)
is
  l_proc      varchar2(61) := c_package || 'chk_assignment_set_name';
  --
  l_dummy     varchar2(1);
  l_formula_type_id number;
  l_formula_name    ff_formulas_f.formula_name%type;
  cursor csr_asg_set is
    select  null
    from  hr_assignment_sets
    where upper(assignment_set_name) = upper(p_assignment_set_name)
    and business_group_id = p_business_group_id;
begin
  hr_utility.set_location('Entering : ' || l_proc, 10);
  --
  open csr_asg_set;
  fetch csr_asg_set into l_dummy;
  if csr_asg_set%found then
    close csr_asg_set;
    fnd_message.set_name('PER','HR_6395_SETUP_SET_EXISTS');
    fnd_message.raise_error;
  else
    close csr_asg_set;
    --
    select  formula_type_id
    into  l_formula_type_id
    from  ff_formula_types
    where formula_type_name = 'Assignment Set';
    --
    l_formula_name := p_assignment_set_name;
    ffdict.validate_formula(
      p_formula_name    => l_formula_name,
      p_formula_type_id => l_formula_type_id,
      p_bus_grp   => p_business_group_id,
      p_leg_code    => hr_api.return_legislation_code(p_business_group_id));
  end if;
  --
  hr_utility.set_location('Leaving : ' || l_proc, 20);
end chk_assignment_set_name;
-- ----------------------------------------------------------------------------
-- |----------------------------< create_asg_set >----------------------------|
-- ----------------------------------------------------------------------------
procedure create_asg_set(
  p_assignment_set_name   in varchar2,
  p_business_group_id   in number,
  p_payroll_id      in number,
  p_assignment_set_id  out nocopy number)
is
  l_proc      varchar2(61) := c_package || 'create_asg_set';
  --
  l_rowid     varchar2(18);
  l_assignment_set_id number;
begin
  hr_utility.set_location('Entering : ' || l_proc, 10);
  --
  chk_assignment_set_name(
    p_assignment_set_name => p_assignment_set_name,
    p_business_group_id => p_business_group_id);
  --
  select  hr_assignment_sets_s.nextval
  into  p_assignment_set_id
  from  dual;
  --
  hr_assignment_sets_pkg.insert_row(
    p_rowid     => l_rowid,
    p_assignment_set_id => p_assignment_set_id,
    p_business_group_id => p_business_group_id,
    p_payroll_id    => p_payroll_id,
    p_assignment_set_name => p_assignment_set_name,
    p_formula_id    => null);
  --
  hr_utility.set_location('Leaving : ' || l_proc, 20);
end create_asg_set;
-- ----------------------------------------------------------------------------
-- |--------------------< create_asg_set_with_request_id >--------------------|
-- ----------------------------------------------------------------------------
procedure create_asg_set_with_request_id(
  p_prefix      in varchar2,
  p_business_group_id   in number,
  p_payroll_id      in number,
  p_assignment_set_id  out nocopy number,
  p_assignment_set_name  out nocopy varchar2)
is
  l_proc      varchar2(61) := c_package || 'create_asg_set_with_request_id';
  --
  l_rowid     varchar2(18);
  --
  -- If not submitted from SRS, fnd_global.conc_request_id returns "-1"
  -- which causes error in hr_chkfmt package.
  --
  l_assignment_set_name hr_assignment_sets.assignment_set_name%type
        := p_prefix || to_char(greatest(fnd_global.conc_request_id, 0));
  l_counter   number := 0;
begin
  hr_utility.set_location('Entering : ' || l_proc, 10);
  --
  -- Assignment Set Name : <Prefix>_<Request ID>
  -- If the assignment name already exists, add sequence
  -- to above assignment set name as suffix like this.
  -- Assignment Set Name : REQUEST_ID_<Request ID>_<Counter>
  --
  loop
    if l_counter = 0 then
      p_assignment_set_name := l_assignment_set_name;
    else
      p_assignment_set_name := l_assignment_set_name || '_' || to_char(l_counter);
    end if;
    --
    hr_utility.trace('Assignment Set Name : ' || p_assignment_set_name);
    --
    begin
      create_asg_set(
        p_assignment_set_name => p_assignment_set_name,
        p_business_group_id => p_business_group_id,
        p_payroll_id    => p_payroll_id,
        p_assignment_set_id => p_assignment_set_id);
      --
      exit;
    exception
      when others then
        --
        -- There's possibility the prefix is inappropriate
        -- which will cause infinite loop.
        -- The following code raises error if the loop counter
        -- gets over 1000.
        --
        if l_counter > 1000 then
          raise;
        else
          l_counter := l_counter + 1;
        end if;
    end;
  end loop;
  --
  hr_utility.set_location('Leaving : ' || l_proc, 20);
end create_asg_set_with_request_id;
-- ----------------------------------------------------------------------------
-- |--------------------------< create_asg_set_amd >--------------------------|
-- ----------------------------------------------------------------------------
procedure create_asg_set_amd(
  p_assignment_set_id   in number,
  p_assignment_id     in number,
  p_include_or_exclude    in varchar2)
is
  l_rowid varchar2(18);
begin
  hr_assignment_set_amds_pkg.insert_row(
    p_rowid     => l_rowid,
    p_assignment_id   => p_assignment_id,
    p_assignment_set_id => p_assignment_set_id,
    p_include_or_exclude  => p_include_or_exclude);
end create_asg_set_amd;
-- ----------------------------------------------------------------------------
-- |-----------------------< get_assignment_set_info >------------------------|
-- ----------------------------------------------------------------------------
procedure get_assignment_set_info(p_assignment_set_id in number)
is
  l_proc  varchar2(61) := c_package || 'get_assignment_set_info';
  --
  function amendment_exists(p_include_or_exclude in varchar2) return boolean
  is
    l_exists  varchar2(1);
    --
    cursor csr_exists is
      select  'Y'
      from  dual
      where exists(
          select  null
          from  hr_assignment_set_amendments
          where assignment_set_id = p_assignment_set_id
          and include_or_exclude = p_include_or_exclude);
  begin
    open csr_exists;
    fetch csr_exists into l_exists;
    if csr_exists%notfound then
      l_exists := 'N';
    end if;
    close csr_exists;
    --
    return (l_exists = 'Y');
  end amendment_exists;
begin
  hr_utility.set_location('Entering: ' || l_proc, 10);
  --
  -- Setup assignment set information and cache those into global variables.
  --
  if g_assignment_set_id is null or g_assignment_set_id <> p_assignment_set_id then
    hr_utility.trace('Caching...');
    --
    g_assignment_set_id := null;
    g_formula_id    := null;
    g_amendment_type  := null;
    g_include_or_excludes.delete;
    --
    select  formula_id
    into  g_formula_id
    from  hr_assignment_sets
    where assignment_set_id = p_assignment_set_id;
    --
    g_amendment_type := 'N';
    if g_formula_id is null then
      if amendment_exists('I') then
        g_amendment_type := 'I';
      elsif amendment_exists('E') then
        g_amendment_type := 'E';
      end if;
    else
      if amendment_exists('I') then
        if amendment_exists('E') then
          g_amendment_type := 'B';
        else
          g_amendment_type := 'I';
        end if;
      elsif amendment_exists('E') then
        g_amendment_type := 'E';
      end if;
    end if;
    --
    g_assignment_set_id := p_assignment_set_id;
  end if;
  --
  hr_utility.trace('assignment_set_id: ' || g_assignment_set_id);
  hr_utility.trace('formula_id       : ' || g_formula_id);
  hr_utility.trace('amendment_type   : ' || g_amendment_type);
  hr_utility.set_location('Leaving   : ' || l_proc, 100);
end get_assignment_set_info;
--
procedure get_assignment_set_info(
  p_assignment_set_id in number,
  p_formula_id    out nocopy number,
  p_amendment_type  out nocopy varchar2)
is
begin
  get_assignment_set_info(p_assignment_set_id);
  --
  p_formula_id    := g_formula_id;
  p_amendment_type  := g_amendment_type;
end get_assignment_set_info;
-- ----------------------------------------------------------------------------
-- |--------------------------< amendment_validate >--------------------------|
-- ----------------------------------------------------------------------------
function amendment_validate(
  p_assignment_set_id in number,
  p_assignment_id   in number) return varchar2
is
  l_proc  varchar2(61) := c_package || 'amendment_validate';
  --
  type t_number_tbl is table of number index by binary_integer;
  l_assignment_ids  t_number_tbl;
  l_include_or_excludes t_include_or_exclude_tbl;
  l_include_or_exclude  hr_assignment_set_amendments.include_or_exclude%type;
  l_include_flag    varchar2(1);
begin
  hr_utility.set_location('Entering: ' || l_proc, 10);
  --
  get_assignment_set_info(p_assignment_set_id);
  --
  -- include_flag = F -> Additional formula validation required.
  -- include_flag = Y -> To be included. No formula validation required.
  -- include_flag = N -> To be excluded. No formula validation required.
  --
  if g_amendment_type = 'N' then
    hr_utility.set_location(l_proc, 20);
    --
    if g_formula_id is null then
      l_include_flag := 'Y';
    else
      l_include_flag := 'F';
    end if;
  else
    hr_utility.set_location(l_proc, 30);
    --
    -- Cache amendment information into PL/SQL table.
    -- In most cases, amendment information is very few (< 100 records),
    -- which will raise performance when cached with bulk collect.
    --
    if g_include_or_excludes.count = 0 then
      hr_utility.trace('Caching...');
      --
      select  assignment_id,
        include_or_exclude
      bulk collect into
        l_assignment_ids,
        l_include_or_excludes
      from  hr_assignment_set_amendments
      where assignment_set_id = p_assignment_set_id;
      --
      for i in 1..l_assignment_ids.count loop
        g_include_or_excludes(l_assignment_ids(i)) := l_include_or_excludes(i);
      end loop;
    end if;
    --
    if g_include_or_excludes.exists(p_assignment_id) then
      hr_utility.set_location(l_proc, 31);
      --
      l_include_or_exclude := g_include_or_excludes(p_assignment_id);
    end if;
    --
    if l_include_or_exclude = 'E' then
      l_include_flag := 'N';
    elsif l_include_or_exclude = 'I' then
      l_include_flag := 'Y';
    else
      if g_formula_id is null then
        if g_amendment_type = 'E' then
          l_include_flag := 'Y';
        else
          l_include_flag := 'N';
        end if;
      else
        l_include_flag := 'F';
      end if;
    end if;
  end if;
  --
  hr_utility.trace('include_flag: ' || l_include_flag);
  hr_utility.set_location('Leaving: ' || l_proc, 100);
  --
  return l_include_flag;
end amendment_validate;
-- ----------------------------------------------------------------------------
-- |---------------------------< formula_validate >---------------------------|
-- ----------------------------------------------------------------------------
function formula_validate(
  p_formula_id      in number,
  p_assignment_id     in number,
  p_effective_date    in date,
  p_populate_fs     in boolean default false) return boolean
is
  l_proc      varchar2(61) := c_package || 'formula_validate';
  --
  l_inputs    ff_exec.inputs_t;
  l_outputs   ff_exec.outputs_t;
  l_include_flag    varchar2(255);
  --
  l_rowid     rowid;
  l_effective_date  date;
begin
  hr_utility.set_location('Entering : ' || l_proc, 10);
  --
  ff_exec.init_formula(
    p_formula_id    => p_formula_id,
    p_effective_date  => p_effective_date,
    p_inputs    => l_inputs,
    p_outputs   => l_outputs);
  --
  -- Set the Formula Contexts.
  -- Assignment Set only supports the context "ASSIGNMENT_ID"/"DATE_EARNED".
  --
  for i in 1..l_inputs.count loop
    if l_inputs(i).class = 'CONTEXT' then
      if l_inputs(i).name = 'ASSIGNMENT_ID' then
        l_inputs(i).value := to_char(p_assignment_id);
      elsif l_inputs(i).name = 'DATE_EARNED' then
        l_inputs(i).value := fnd_date.date_to_canonical(p_effective_date);
      end if;
    end if;
  end loop;
  --
  begin
    --
    -- savepoint/rollback to savepoint for FND_SESSIONS
    -- will raise error ORA-14552 when this function is used in SQL.
    -- To suppress this error when this function is used in SQL,
    -- do not pass "true" to input parameter "p_populate_fs".
    --
    if p_populate_fs then
      savepoint jp_ast_utility1;
      --
      begin
        select  rowid,
          effective_date
        into  l_rowid,
          l_effective_date
        from  fnd_sessions
        where session_id = userenv('sessionid');
        --
        if l_effective_date <> p_effective_date then
          update  fnd_sessions
          set effective_date = p_effective_date
          where rowid = l_rowid;
        end if;
      exception
        when no_data_found then
          insert into fnd_sessions(
            session_id,
            effective_date)
          values( userenv('sessionid'),
            p_effective_date);
      end;
    end if;
    --
    ff_exec.run_formula(
      p_inputs  => l_inputs,
      p_outputs => l_outputs,
      p_use_dbi_cache => TRUE);
    --
    if p_populate_fs then
      rollback to savepoint jp_ast_utility1;
    end if;
  exception
    when others then
      if p_populate_fs then
        rollback to savepoint jp_ast_utility1;
      end if;
      --
      raise;
  end;
  --
  for i in 1..l_outputs.count loop
    if l_outputs(i).name = 'INCLUDE_FLAG' then
      l_include_flag := l_outputs(i).value;
      exit;
    end if;
  end loop;
  --
  if l_include_flag = 'Y' then
    return true;
  else
    return false;
  end if;
  --
  hr_utility.set_location('Leaving : ' || l_proc, 20);
end formula_validate;
-- ----------------------------------------------------------------------------
-- |-----------------------< assignment_set_validate >------------------------|
-- ----------------------------------------------------------------------------
function assignment_set_validate(
  p_assignment_set_id in number,
  p_assignment_id   in number,
  p_effective_date  in date,
  p_populate_fs_flag  in varchar2 default 'N') return varchar2
is
  l_proc      varchar2(61) := c_package || 'assignment_set_validate';
  l_include_flag    varchar2(1);
  l_include_or_exclude  hr_assignment_set_amendments.include_or_exclude%type;
begin
  hr_utility.set_location('Entering: ' || l_proc, 10);
  --
  get_assignment_set_info(p_assignment_set_id);
  --
  -- Check the assignment is to be included/excluded.
  --
  l_include_flag := amendment_validate(p_assignment_set_id, p_assignment_id);
  --
  if l_include_flag = 'F' then
    hr_utility.set_location(l_proc, 20);
    --
    if formula_validate(g_formula_id, p_assignment_id, p_effective_date, (p_populate_fs_flag = 'Y')) then
      l_include_flag := 'Y';
    else
      l_include_flag := 'N';
    end if;
  end if;
  --
  hr_utility.trace('include_flag: ' || l_include_flag);
  hr_utility.set_location('Leaving: ' || l_proc, 100);
  --
  return l_include_flag;
end assignment_set_validate;
-- ----------------------------------------------------------------------------
-- |-------------------------------< pay_asgs >-------------------------------|
-- ----------------------------------------------------------------------------
procedure pay_asgs(
  p_payroll_id      in number,
  p_effective_date    in date,
  p_start_date      in date,
  p_end_date      in date,
  p_assignment_set_id   in number,
  p_asg_rec    out nocopy t_asg_rec)
is
  l_proc    varchar2(61) := c_package || 'pay_asgs';
  --
  l_formula_id  number;
  l_include_flag  varchar2(1);
  cursor csr_formula_id is
    select  formula_id
    from  hr_assignment_sets
    where assignment_set_id = p_assignment_set_id;
  cursor csr_include is
    select  'Y'
    from  hr_assignment_set_amendments
    where assignment_set_id = p_assignment_set_id
    and include_or_exclude = 'I'
    and rownum < 2;
  --
  l_include_or_exclude_tbl  t_varchar2_tbl;
  l_index       number := 0;
  l_process     boolean;
  --
  -- 1. Assignment must exist on p_effective_date with payroll specified.
  -- 2. Assignment must exist between p_start_date and p_end_date with payroll specified.
  --
  cursor  csr_asg_all is
  select  /*+ ORDERED */
          asg3.assignment_id,
          greatest(asg3.effective_start_date, p_start_date) effective_date,
          asg3.assignment_number,
          per.full_name
  from    (
          select /*+ ORDERED
                     USE_NL(ASG1, PPOS, ASG2)
                     INDEX(ASG1 PER_ASSIGNMENTS_F_N7)
                     INDEX(PPOS PER_PERIODS_OF_SERVICE_PK)
                     INDEX(ASG2 PER_ASSIGNMENTS_F_PK) */
                 asg2.assignment_id,
                 min(asg2.effective_start_date)  effective_start_date
          from   per_all_assignments_f asg1,
                 per_periods_of_service ppos,
                 per_all_assignments_f asg2
          where  asg1.payroll_id = p_payroll_id
          and    p_effective_date
                 between asg1.effective_start_date and asg1.effective_end_date
          and    ppos.period_of_service_id = asg1.period_of_service_id
          and    p_effective_date
                 between ppos.date_start and nvl(ppos.final_process_date,p_effective_date)
          and    asg2.assignment_id = asg1.assignment_id
          and    asg2.effective_end_date >= p_start_date
          and    asg2.effective_start_date <= p_end_date
          and    asg2.payroll_id +0 = asg1.payroll_id
          group by asg2.assignment_id
          )     v,
          per_all_assignments_f asg3,
          per_all_people_f  per
  --
  -- Assignment information must be retrieved by Batch Line Upload Date.
  --
  where   asg3.assignment_id = v.assignment_id
  and     asg3.effective_start_date = v.effective_start_date
  and     per.person_id = asg3.person_id
  --
  -- Person information must be retrieved by Batch Line Upload Date.
  --
  and    greatest(asg3.effective_start_date, p_start_date)
         between per.effective_start_date and per.effective_end_date
  order by nvl(per.order_name, per.full_name), asg3.assignment_number;
  --
  cursor csr_asg_inc is
  select  /*+ ORDERED */
          asg3.assignment_id,
          greatest(asg3.effective_start_date, p_start_date) effective_date,
          asg3.assignment_number,
          per.full_name
  from    (
          select  /*+ ORDERED */
                  asg2.assignment_id,
                  min(asg2.effective_start_date)  effective_start_date
          from    hr_assignment_set_amendments  asa,
                  per_all_assignments_f   asg1,
                  per_periods_of_service  ppos,
                  per_all_assignments_f   asg2
          where   asa.assignment_set_id = p_assignment_set_id
          and     asa.include_or_exclude = 'I'
          and     asg1.assignment_id = asa.assignment_id
          and     p_effective_date
                  between asg1.effective_start_date and asg1.effective_end_date
          and     ppos.period_of_service_id = asg1.period_of_service_id
          and     p_effective_date
                  between ppos.date_start and nvl(ppos.final_process_date,p_effective_date)
          and     asg1.payroll_id + 0 = p_payroll_id
          and     asg2.assignment_id = asg1.assignment_id
          and     asg2.effective_end_date >= p_start_date
          and     asg2.effective_start_date <= p_end_date
          and     asg2.payroll_id + 0 = asg1.payroll_id
          group by asg2.assignment_id
          )     v,
          per_all_assignments_f asg3,
          per_all_people_f  per
  where   asg3.assignment_id = v.assignment_id
  and     asg3.effective_start_date = v.effective_start_date
  and     per.person_id = asg3.person_id
  and     greatest(asg3.effective_start_date, p_start_date)
          between per.effective_start_date and per.effective_end_date
  order by nvl(per.order_name, per.full_name), asg3.assignment_number;
  --
  cursor csr_asg_exc is
  select  /*+ ORDERED */
          asg3.assignment_id,
          greatest(asg3.effective_start_date, p_start_date) effective_date,
          asg3.assignment_number,
          per.full_name,
          v.include_or_exclude
  from    (
          select  /*+ ORDERED
                      USE_NL(ASG1, PPOS, ASG2, ASA)
                      INDEX(ASG1 PER_ASSIGNMENTS_F_N7)
                      INDEX(PPOS PER_PERIODS_OF_SERVICE_PK)
                      INDEX(ASG2 PER_ASSIGNMENTS_F_PK)
                      INDEX(ASA HR_ASSIGNMENT_SET_AMENDMEN_PK) */
                  asg2.assignment_id,
                  min(asg2.effective_start_date)  effective_start_date,
                  min(asa.include_or_exclude) include_or_exclude
          from    per_all_assignments_f  asg1,
                  per_periods_of_service ppos,
                  per_all_assignments_f  asg2,
                  hr_assignment_set_amendments  asa
          where   asg1.payroll_id = p_payroll_id
          and     p_effective_date
                  between asg1.effective_start_date and asg1.effective_end_date
          and     ppos.period_of_service_id = asg1.period_of_service_id
          and     p_effective_date
                  between ppos.date_start and nvl(ppos.final_process_date,p_effective_date)
          and     asg2.assignment_id = asg1.assignment_id
          and     asg2.effective_end_date >= p_start_date
          and     asg2.effective_start_date <= p_end_date
          and     asg2.payroll_id + 0 = asg1.payroll_id
          and     asa.assignment_set_id(+) = p_assignment_set_id
          and     asa.assignment_id(+) = asg2.assignment_id
          and     nvl(asa.include_or_exclude, 'I') = 'I'
          group by asg2.assignment_id
          )     v,
          per_all_assignments_f asg3,
          per_all_people_f  per
    where asg3.assignment_id = v.assignment_id
    and   asg3.effective_start_date = v.effective_start_date
    and   per.person_id = asg3.person_id
    and   greatest(asg3.effective_start_date, p_start_date)
          between per.effective_start_date and per.effective_end_date
    order by nvl(per.order_name, per.full_name), asg3.assignment_number;
  --
begin
  hr_utility.set_location('Entering : ' || l_proc, 10);
  --
  -- When assignment set is not specified,
  -- all assignments are the target.
  --
  if p_assignment_set_id is null then
    hr_utility.trace('csr_asg_all bulk collect');
    --
    open csr_asg_all;
    fetch csr_asg_all bulk collect into
      p_asg_rec.assignment_id_tbl,
      p_asg_rec.effective_date_tbl,
      p_asg_rec.assignment_number_tbl,
      p_asg_rec.full_name_tbl;
    close csr_asg_all;
  --
  -- When assignment set is specified,
  --
  else
    --
    -- Derive formula_id of the assignment set
    --
    open csr_formula_id;
    fetch csr_formula_id into l_formula_id;
    if csr_formula_id%NOTFOUND then
      close csr_formula_id;
      raise no_data_found;
    end if;
    close csr_formula_id;
    --
    -- Check whether "Include" exists or not as amendments
    --
    open csr_include;
    fetch csr_include into l_include_flag;
    if csr_include%NOTFOUND then
      l_include_flag := 'N';
    end if;
    close csr_include;
    --
    -- In case criteria is not set
    --
    if l_formula_id is null then
      --
      -- When only "Include" is set as amendments (no criteria)
      --
      if l_include_flag = 'Y' then
        hr_utility.trace('csr_asg_inc bulk collect');
        --
        open csr_asg_inc;
        fetch csr_asg_inc bulk collect into
          p_asg_rec.assignment_id_tbl,
          p_asg_rec.effective_date_tbl,
          p_asg_rec.assignment_number_tbl,
          p_asg_rec.full_name_tbl;
        close csr_asg_inc;
      --
      -- When only "Exclude" is set as amendments (no criteria)
      --
      else
        hr_utility.trace('csr_asg_exc bulk collect');
        --
        open csr_asg_exc;
        fetch csr_asg_exc bulk collect into
          p_asg_rec.assignment_id_tbl,
          p_asg_rec.effective_date_tbl,
          p_asg_rec.assignment_number_tbl,
          p_asg_rec.full_name_tbl,
          l_include_or_exclude_tbl;
        close csr_asg_exc;
      end if;
    --
    -- In case criteria is set
    --
    else
      --
      -- Need to validate whether each assignment should be processed or not using FastFormula.
      --
      hr_utility.trace('csr_asg_exc for loop');
      --
      for l_asg_rec in csr_asg_exc loop
        l_process := false;
        --
        -- When include_or_exclude is 'I'(not null),
        -- the assignment must be processed without validating FastFormula.
        --
        if l_asg_rec.include_or_exclude is not null then
          hr_utility.trace('INC : ' || to_char(l_asg_rec.assignment_id));
          --
          l_process := true;
        --
        -- Validate the assignment with FastFormula as of Upload Date.
        --
        elsif formula_validate(l_formula_id, l_asg_rec.assignment_id, l_asg_rec.effective_date) then
          hr_utility.trace('FF  : ' || to_char(l_asg_rec.assignment_id));
          --
          l_process := true;
        end if;
        --
        -- When the assignment is validated to be processed
        --
        if l_process then
          l_index := l_index + 1;
          p_asg_rec.assignment_id_tbl(l_index)  := l_asg_rec.assignment_id;
          p_asg_rec.effective_date_tbl(l_index) := l_asg_rec.effective_date;
          p_asg_rec.assignment_number_tbl(l_index):= l_asg_rec.assignment_number;
          p_asg_rec.full_name_tbl(l_index)  := l_asg_rec.full_name;
        end if;
      end loop;
    end if;
  end if;
  --
  hr_utility.set_location('Leaving : ' || l_proc, 20);
end pay_asgs;
--
end hr_jp_ast_utility_pkg;

/
