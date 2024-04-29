--------------------------------------------------------
--  DDL for Package Body PAY_ASG_LINK_USAGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ASG_LINK_USAGES_PKG" as
/* $Header: pyalu.pkb 120.2.12000000.4 2007/03/05 12:22:25 swinton ship $ */
--------------------------------------------------------------------------------
--
-- Declare global variables
--

  type t_num_tab is table of number
    index by binary_integer;
  type t_date_tab is table of date
    index by binary_integer;
  --
  type t_asg_grp_rec is record
    (people_group_id      number
    ,effective_start_date date
    ,effective_end_date   date
    );
  type t_asg_grp_hist_tab is table of t_asg_grp_rec
    index by binary_integer;
  --
  -- Assignment cache for ALU.
  --
  g_alu_assignment_id number;             -- Assignment ID
  g_alu_asg_hist      t_asg_grp_hist_tab; -- Asg people group history
  g_alu_link_pg_id    number;             -- Link People Group ID
  g_alu_asg_pg_hist   t_asg_grp_hist_tab; -- Asg eligibility history
  --
  g_package constant varchar2 (32) := 'pay_asg_link_usages_pkg.';

--------------------------------------------------------------------------------
--
procedure INSERT_ALU (
--
--******************************************************************************
--* Inserts Assignment Link Usages for a new element link.                     *
--******************************************************************************
--
        p_business_group_id     number,
        p_people_group_id       number,
        p_element_link_id       number,
        p_effective_start_date  date,
        p_effective_end_date    date) is
--
v_previous_assignment_id        number;
v_previous_start_date           date;
v_previous_end_date             date;
v_termination_date              date;
v_unwanted_out_parameter        date;
v_rows_were_found               boolean;
--
-- Table variables for bulk.
--
type t_num_tab  is table of number index by binary_integer;
type t_date_tab is table of date   index by binary_integer;

v_asg_id_tab      t_num_tab;
v_start_date_tab  t_date_tab;
v_end_date_tab    t_date_tab;

--
-- Cursor to fetch the info for the re1uired people group
--
cursor link_people_group is
select id_flex_num,
       segment1, segment2, segment3, segment4, segment5,
       segment6, segment7, segment8, segment9, segment10,
       segment11, segment12, segment13, segment14, segment15,
       segment16, segment17, segment18, segment19, segment20,
       segment21, segment22, segment23, segment24, segment25,
       segment26, segment27, segment28, segment29, segment30
from pay_people_groups link_group
where link_group.people_group_id       = p_people_group_id;
--
type segment_table is table of varchar2(60)
        index by binary_integer;
segment            segment_table;
i                  number;
sql_curs           number;
rows_processed     integer;
statem             varchar2(8000);
row_count          number := 0;
--
l_assignment_id per_assignments_f.assignment_id%type;
l_effective_start_date per_assignments_f.effective_start_date%type;
l_effective_end_date per_assignments_f.effective_end_date%type;
--
-- Bug 5408395.
-- This sub procedure was renamed from create_alu to set_alu as this
-- now only sets up the ALU data and ALUs are uploaded by bulk in
-- upload_alus().
--
--procedure CREATE_ALU is
procedure set_ALU is
        --
l_alu_start date;
l_alu_end   date;
l_idx       number;
        begin
        l_alu_start := greatest(p_effective_start_date, v_previous_start_date);
        --
        -- Get the final process date for the assignment if there is one NB.
        -- it will return the end of time if there is not one. This is so
        -- that the subsequent comparison will ignore the date.
        --
        -- Bug 5202396.
        -- The check for termination rule caused a significant performance
        -- issue. Since ALU is only a part of the link eligibility rules,
        -- we can determine the end date with the link and the assignment.
        --
        /*****************
        hr_entry.entry_asg_pay_link_dates(v_previous_assignment_id,
                                                p_element_link_id,
                                                l_alu_start,
                                                v_termination_date,
                                                v_unwanted_out_parameter,
                                                v_unwanted_out_parameter,
                                                v_unwanted_out_parameter,
                                                v_unwanted_out_parameter,
                                                false);
        --
        l_alu_end := least(p_effective_end_date,
                           v_previous_end_date,
                           v_termination_date);
        *****************/
        --
        l_alu_end := least(p_effective_end_date,
                           v_previous_end_date);

        --
        if l_alu_end >= l_alu_start then
           hr_utility.trace('ALU : ' || l_alu_start || ' ' || l_alu_end);

           l_idx := v_asg_id_tab.count+1;
           --
           -- Set the ALU data to table variables.
           --
           v_asg_id_tab(l_idx)     := v_previous_assignment_id;
           v_start_date_tab(l_idx) := l_alu_start;
           v_end_date_tab(l_idx)   := l_alu_end;

        end if;
        --
end set_ALU;
--end create_ALU;
--
  --
  -- Sub procedure to upload alus by bulk.
  --
  procedure upload_alus
  is
    l_count number;
  begin
    l_count := v_asg_id_tab.count;

    if l_count > 0 then

      forall i in 1..l_count
        insert into pay_assignment_link_usages_f
          (assignment_link_usage_id
          ,effective_start_date
          ,effective_end_date
          ,element_link_id
          ,assignment_id)
        values
          (pay_assignment_link_usages_s.nextval
          ,v_start_date_tab(i)
          ,v_end_date_tab(i)
          ,p_element_link_id
          ,v_asg_id_tab(i)
          );
      --
      -- Reset the table variables.
      --
      v_asg_id_tab.delete;
      v_start_date_tab.delete;
      v_end_date_tab.delete;

    end if;

  end upload_alus;
--
--
begin
--
-- Cycle through qualifying assignments. Create an ALU when the last end date
-- of a continuous set of date-effective rows for an assignment is found.
-- eg:
--
-- Assignment ID 1 +_____________+_______+_______________+___________+
-- Match found?        YES          YES        NO            YES
--
-- ALU ID 1        +_____________________+
-- ALU ID 2                                              +___________+
--
for lpg in link_people_group loop
   --
   segment(1) := lpg.segment1;
   segment(2) := lpg.segment2;
   segment(3) := lpg.segment3;
   segment(4) := lpg.segment4;
   segment(5) := lpg.segment5;
   segment(6) := lpg.segment6;
   segment(7) := lpg.segment7;
   segment(8) := lpg.segment8;
   segment(9) := lpg.segment9;
   segment(10) := lpg.segment10;
   segment(11) := lpg.segment11;
   segment(12) := lpg.segment12;
   segment(13) := lpg.segment13;
   segment(14) := lpg.segment14;
   segment(15) := lpg.segment15;
   segment(16) := lpg.segment16;
   segment(17) := lpg.segment17;
   segment(18) := lpg.segment18;
   segment(19) := lpg.segment19;
   segment(20) := lpg.segment20;
   segment(21) := lpg.segment21;
   segment(22) := lpg.segment22;
   segment(23) := lpg.segment23;
   segment(24) := lpg.segment24;
   segment(25) := lpg.segment25;
   segment(26) := lpg.segment26;
   segment(27) := lpg.segment27;
   segment(28) := lpg.segment28;
   segment(29) := lpg.segment29;
   segment(30) := lpg.segment30;
   --
statem := '
select  assignment.assignment_id,
        assignment.effective_start_date,
        assignment.effective_end_date
from    per_all_assignments_f ASSIGNMENT,
        pay_people_groups ASSIGNMENT_GROUP
where   assignment.assignment_type       not in (''A'',''O'')
and     assignment.business_group_id + 0 = :p_business_group_id
and     assignment.effective_start_date <= :p_effective_end_date
and     assignment.effective_end_date   >= :p_effective_start_date
and     assignment_group.id_flex_num     = :p_id_flex_num
and     assignment_group.people_group_id = assignment.people_group_id';
   --
   for i in 1..30 loop
      if segment(i) is not null then
         statem := statem || ' and assignment_group.segment'||i||' = :p_segment'||i;
      end if;
   end loop;
   --
   statem := statem || ' order by assignment_id, effective_start_date';
   statem := statem || ' for update';
   --
   --
   sql_curs := dbms_sql.open_cursor;
   --
   dbms_sql.parse(sql_curs,
                      statem,
                     dbms_sql.v7);
   --
   dbms_sql.bind_variable(sql_curs, 'p_business_group_id', p_business_group_id);
   dbms_sql.bind_variable(sql_curs, 'p_effective_start_date', p_effective_start_date);
   dbms_sql.bind_variable(sql_curs, 'p_effective_end_date', p_effective_end_date);
   dbms_sql.bind_variable(sql_curs, 'p_id_flex_num', lpg.id_flex_num);
   --
   for i in 1..30 loop
      if segment(i) is not null then
         dbms_sql.bind_variable(sql_curs, 'p_segment'||i, segment(i));
      end if;
   end loop;
   --
   dbms_sql.define_column(sql_curs,1,l_assignment_id);
   dbms_sql.define_column(sql_curs,2,l_effective_start_date);
   dbms_sql.define_column(sql_curs,3,l_effective_end_date);
   --
   rows_processed := dbms_sql.execute(sql_curs);
   --
   loop
      if dbms_sql.fetch_rows(sql_curs) > 0 then
         --
         row_count := row_count + 1;
         --
         dbms_sql.column_value(sql_curs,1,l_assignment_id);
         dbms_sql.column_value(sql_curs,2,l_effective_start_date);
         dbms_sql.column_value(sql_curs,3,l_effective_end_date);
         --
         hr_utility.trace('l_assignment_id '||l_assignment_id);
         hr_utility.trace('l_effective_start_date '||l_effective_start_date);
         hr_utility.trace('l_effective_end_date '||l_effective_end_date);
         --
         if row_count = 1 then -- Skip first row but set ID
           --
           v_rows_were_found           := TRUE;
           v_previous_assignment_id    := l_assignment_id;
           v_previous_start_date       := l_effective_start_date;
           v_previous_end_date         := l_effective_end_date;
           --
         else
           --
           -- Check for last record or a new asignment ie. either a new
           -- assignment_id or the same assignment_id but not contiguous records
           --
           if (l_assignment_id <> v_previous_assignment_id
                or l_effective_start_date -1 <> v_previous_end_date) then
             --
             -- Setup the ALU data in the table variables.
             --
             set_ALU;
             --create_ALU;
             --
             -- Upload ALUs by a reasonable amount.
             --
             if v_asg_id_tab.count = 200 then
               --
               upload_alus;

             end if;
             --
             -- Bugfix 2364196
             -- Always increment the v_previous_start_date when a new
             -- assignment is detected.
             --
             v_previous_start_date := l_effective_start_date;
             --
           end if;
           --
           v_previous_end_date := l_effective_end_date;
           --
         end if;
         --
         v_previous_assignment_id := l_assignment_id;
         --
      else
         exit;
      end if;
   end loop;
   --
   dbms_sql.close_cursor(sql_curs);
   --
end loop;
--
-- Handle the last row in the cursor (loop exits before checking it)
--
if v_rows_were_found then
  --
  --create_ALU;
  set_alu;
  --
end if;
--
-- Upload all of the remaining ALUs.
--
upload_alus;
--
end insert_alu;
--------------------------------------------------------------------------------
procedure CASCADE_LINK_DELETION (
--
--******************************************************************************
--* Deletes ALUs for a deleted link.                                           *
--******************************************************************************
--
        p_element_link_id       number,
        p_business_group_id     number,
        p_people_group_id       number,
        p_delete_mode           varchar2,
        p_effective_start_date  date,
        p_effective_end_date    date,
        p_validation_start_date date,
        p_validation_end_date   date    ) is
--
v_session_date  date;
--
begin
--
if p_delete_mode = 'DELETE' then
  --
  v_session_date := p_validation_start_date -1;
  --
  delete
  from  pay_assignment_link_usages_f
  where element_link_id = p_element_link_id
  and   effective_start_date    >= p_validation_start_date;
  --
  if p_delete_mode = 'DELETE' then
    --
    update pay_assignment_link_usages_f
    set         effective_end_date = v_session_date
    where       element_link_id = p_element_link_id
    and         v_session_date between effective_start_date
                                and effective_end_date;
    --
  end if;
--
elsif p_delete_mode in ('ZAP', 'DELETE_NEXT_CHANGE') then
  --
  delete
  from pay_assignment_link_usages_f
  where element_link_id = p_element_link_id;
  --
  if p_delete_mode = 'DELETE_NEXT_CHANGE' then
    --
    insert_ALU (
        p_business_group_id,
        p_people_group_id,
        p_element_link_id,
        p_effective_start_date,
        p_effective_end_date    );
    --
  end if;
  --
end if;
--
end cascade_link_deletion;
--------------------------------------------------------------------------------
--
function pg_eligible
--
--******************************************************************************
--* Returns Y if the assignment people group is eligible for                   *
--* the link people group. Otherwise returns N.                                *
--******************************************************************************
--
  (p_link_people_group_id in number
  ,p_asg_people_group_id  in number
  ) return varchar2
is
--
  l_dummy       number;
  l_eligible    varchar2(1);
--
  cursor csr_pg
  is
  select 1
  from   pay_people_groups el_pg,
         pay_people_groups asg_pg
  where  asg_pg.people_group_id  = p_asg_people_group_id
    and  el_pg.people_group_id   = p_link_people_group_id
    and  el_pg.id_flex_num       = asg_pg.id_flex_num
    and  (el_pg.segment1  is null or el_pg.segment1  = asg_pg.segment1)
    and  (el_pg.segment2  is null or el_pg.segment2  = asg_pg.segment2)
    and  (el_pg.segment3  is null or el_pg.segment3  = asg_pg.segment3)
    and  (el_pg.segment4  is null or el_pg.segment4  = asg_pg.segment4)
    and  (el_pg.segment5  is null or el_pg.segment5  = asg_pg.segment5)
    and  (el_pg.segment6  is null or el_pg.segment6  = asg_pg.segment6)
    and  (el_pg.segment7  is null or el_pg.segment7  = asg_pg.segment7)
    and  (el_pg.segment8  is null or el_pg.segment8  = asg_pg.segment8)
    and  (el_pg.segment9  is null or el_pg.segment9  = asg_pg.segment9)
    and  (el_pg.segment10 is null or el_pg.segment10 = asg_pg.segment10)
    and  (el_pg.segment11 is null or el_pg.segment11 = asg_pg.segment11)
    and  (el_pg.segment12 is null or el_pg.segment12 = asg_pg.segment12)
    and  (el_pg.segment13 is null or el_pg.segment13 = asg_pg.segment13)
    and  (el_pg.segment14 is null or el_pg.segment14 = asg_pg.segment14)
    and  (el_pg.segment15 is null or el_pg.segment15 = asg_pg.segment15)
    and  (el_pg.segment16 is null or el_pg.segment16 = asg_pg.segment16)
    and  (el_pg.segment17 is null or el_pg.segment17 = asg_pg.segment17)
    and  (el_pg.segment18 is null or el_pg.segment18 = asg_pg.segment18)
    and  (el_pg.segment19 is null or el_pg.segment19 = asg_pg.segment19)
    and  (el_pg.segment20 is null or el_pg.segment20 = asg_pg.segment20)
    and  (el_pg.segment21 is null or el_pg.segment21 = asg_pg.segment21)
    and  (el_pg.segment22 is null or el_pg.segment22 = asg_pg.segment22)
    and  (el_pg.segment23 is null or el_pg.segment23 = asg_pg.segment23)
    and  (el_pg.segment24 is null or el_pg.segment24 = asg_pg.segment24)
    and  (el_pg.segment25 is null or el_pg.segment25 = asg_pg.segment25)
    and  (el_pg.segment26 is null or el_pg.segment26 = asg_pg.segment26)
    and  (el_pg.segment27 is null or el_pg.segment27 = asg_pg.segment27)
    and  (el_pg.segment28 is null or el_pg.segment28 = asg_pg.segment28)
    and  (el_pg.segment29 is null or el_pg.segment29 = asg_pg.segment29)
    and  (el_pg.segment30 is null or el_pg.segment30 = asg_pg.segment30)
    ;
begin
  if p_link_people_group_id = p_asg_people_group_id then
    return 'Y';
  end if;

  open csr_pg;
  fetch csr_pg into l_dummy;
  if csr_pg%found then
    l_eligible := 'Y';
  else
    l_eligible := 'N';
  end if;
  close csr_pg;

  return l_eligible;
end pg_eligible;
--
--------------------------------------------------------------------------------
--
procedure deinit_alu_asg
--
--******************************************************************************
--* Clears the ALU assignment cache.                                           *
--******************************************************************************
--
is
begin
  g_alu_assignment_id := null;
  g_alu_asg_hist.delete;
  g_alu_link_pg_id := null;
  g_alu_asg_pg_hist.delete;
end deinit_alu_asg;
--
--------------------------------------------------------------------------------
--
procedure init_alu_asg(p_assignment_id in number)
--
--******************************************************************************
--* initialises the ALU assignment cache.                                      *
--******************************************************************************
is
  --
  l_idx       number:=0;
  l_prev_asg  t_asg_grp_rec;
  l_pg_found  boolean;
  --
  cursor csr_asg_hist
  is
    select
       people_group_id
      ,effective_start_date
      ,effective_end_date
    from per_all_assignments_f
    where assignment_id = p_assignment_id
    and assignment_type not in ('A','O')
    and people_group_id is not null
    order by effective_start_date;
  --
begin
  --
  -- Clear existing cache.
  --
  deinit_alu_asg;
  --
  g_alu_assignment_id := p_assignment_id;
  --
  -- Create the distinct people group histry records for this assignment.
  --
  -- Assignment history
  --        PG1      PG1      PG2      PG2      PG3
  --     |------->|------->|------->|------->|------->
  --
  -- People group history
  --             PG1               PG2          PG3
  --     |---------------->|---------------->|------->
  --
  for l_asg in csr_asg_hist loop
    --
    if     l_prev_asg.people_group_id    = l_asg.people_group_id
       and l_prev_asg.effective_end_date+1 = l_asg.effective_start_date then
      --
      -- Extend the previous record
      --
      g_alu_asg_hist(l_idx).effective_end_date := l_asg.effective_end_date;
    else
      l_idx := l_idx +1;
      g_alu_asg_hist(l_idx) := l_asg;
      --
    end if;
    --
    l_prev_asg := l_asg;
    --
  end loop;
  --
end init_alu_asg;
--
--------------------------------------------------------------------------------
--
procedure init_alu_asg_pg
--
--******************************************************************************
--* initialises the ALU assignment cache for the specified                     *
--* link people group.                                                         *
--******************************************************************************
--
  (p_assignment_id in number
  ,p_link_people_group_id in number)
is
  l_idx      number:= 0;
  l_prev_idx number;
begin
  if g_alu_assignment_id = p_assignment_id then
    --
    -- Assignment level cache already exists.
    --
    null;
  else
    init_alu_asg(p_assignment_id);
  end if;
  --
  g_alu_link_pg_id := p_link_people_group_id;
  g_alu_asg_pg_hist.delete;
  --
  -- Create the eligible assignment histry records for the
  -- the specified people group.
  --
  -- Eligibility for the link people group
  --       PG1      PG2      PG3      PG4
  -- ASG |------->|------->|------->|------->
  --       Yes      Yes      No       Yes
  --
  -- Eligible assignment date range
  -- ASG |---------------->         |------->
  --
  for i in 1..g_alu_asg_hist.count loop

    if pg_eligible
         (p_link_people_group_id
         ,g_alu_asg_hist(i).people_group_id
         ) = 'Y' then
      --
      l_prev_idx := l_idx;
      --
      if l_idx = 0 then
        l_idx := l_idx+1;
      elsif g_alu_asg_hist(i).effective_start_date
              = g_alu_asg_pg_hist(l_idx).effective_end_date+1 then
        --
        -- Extend the duration
        --
        g_alu_asg_pg_hist(l_idx).effective_end_date
            := g_alu_asg_hist(i).effective_end_date;
      else
        l_idx := l_idx+1;
      end if;
      --
      if l_idx > l_prev_idx then
        --
        -- Create a new date range.
        --
        g_alu_asg_pg_hist(l_idx).effective_start_date
          := g_alu_asg_hist(i).effective_start_date;
        g_alu_asg_pg_hist(l_idx).effective_end_date
          := g_alu_asg_hist(i).effective_end_date;
      end if;
    end if;
  end loop;
end init_alu_asg_pg;
--
--------------------------------------------------------------------------------
--
procedure chk_pg_eligibility
--
--******************************************************************************
--* checks the eligibility of the people group criteria.                       *
--* If the assignment is eligible for the link people group,                   *
--* p_eligible_pg_exists will be set to TRUE and the eligibility history       *
--* records will be cached for further processing.                             *
--******************************************************************************
--
  (p_assignment_id        in            number
  ,p_link_people_group_id in            number
  ,p_eligible_pg_exists      out nocopy boolean
  )
is
begin
  if g_alu_assignment_id = p_assignment_id then
    --
    -- Asg cache already exists.
    --
    if g_alu_link_pg_id = p_link_people_group_id then
      --
      -- People group cache also exists.
      --
      null;
    else
      init_alu_asg_pg(p_assignment_id, p_link_people_group_id);
    end if;
  else
    --
    -- Initialise ALU assignment and link cache.
    --
    init_alu_asg(p_assignment_id);
    init_alu_asg_pg(p_assignment_id, p_link_people_group_id);
  end if;
  --
  p_eligible_pg_exists := (g_alu_asg_pg_hist.count > 0);
  --
end chk_pg_eligibility;
--
--------------------------------------------------------------------------------
--
procedure create_alu_asg_pg
--
--******************************************************************************
--* This procedure creates ALU's of the assignment for a particular link       *
--* people group.                                                              *
--******************************************************************************
--
  (p_assignment_id        in number
  ,p_link_people_group_id in number
  ,p_link_id_tab          in t_num_tab
  ,p_link_start_date_tab  in t_date_tab
  ,p_link_end_date_tab    in t_date_tab
  )
is
  --
  l_idx               number:= 0;
  l_prev_idx          number:= 0;
  --
  -- ALU table variables
  --
  l_alu_start_date_tab t_date_tab;
  l_alu_end_date_tab   t_date_tab;
  l_alu_link_id_tab    t_num_tab;
  --
  l_alu_start_date     date;
  l_alu_end_date       date;
  l_asg_start_date     date;
  l_asg_end_date       date;
  l_link_start_date    date;
  l_link_end_date      date;
  l_link_id            number;
  --
  l_alu_idx            number:= 0;
  l_eligible_pg_exists boolean;
  l_dummy              number;
  l_alu_exists         boolean;
  l_asg_locked         boolean;
  --
  cursor csr_alu_exists
    (p_element_link_id in number)
  is
  select 1 from pay_assignment_link_usages_f
  where assignment_id = p_assignment_id
  and element_link_id = p_element_link_id;
  --
  l_proc               varchar2(72) := g_package||'create_alu_asg_pg';
  --
  -- sub procedure to lock assignment.
  --
  procedure lock_asg
    (p_asg_id        in number
    ,p_start_date    in date
    ,p_end_date      in date)
  is
    --
    cursor csr_lock_asg
    is
    select 1
    from per_all_assignments_f
    where assignment_id      = p_asg_id
    and effective_start_date <= p_end_date
    and effective_end_date   >= p_start_date
    for update nowait
    ;
    --
    l_num_tab         t_num_tab;
    --
  begin
    open csr_lock_asg;
    fetch csr_lock_asg bulk collect into l_num_tab;
    close csr_lock_asg;
  exception
    when hr_api.object_locked then
      --
      -- Failed to lock the assignment.
      --
      hr_utility.set_message(801, 'HR_7165_OBJECT_LOCKED');
      hr_utility.set_message_token('TABLE_NAME', 'per_all_assignments_f');
      hr_utility.raise_error;
  end lock_asg;
  --
begin

  hr_utility.set_location('Entering: '||l_proc, 5);
  --
  -- Check the eligibility of the people group and
  -- also establish the necessary cache.
  --
  chk_pg_eligibility
    (p_assignment_id
    ,p_link_people_group_id
    ,l_eligible_pg_exists);

  --
  -- Construct the date tables for ALU
  --
  if l_eligible_pg_exists then

    hr_utility.set_location(l_proc, 10);

    l_asg_locked := false;
    --
    -- Setup the ALU table data
    --
    for i in 1..p_link_id_tab.count loop
      --
      l_link_id         := p_link_id_tab(i);
      l_link_start_date := p_link_start_date_tab(i);
      l_link_end_date   := p_link_end_date_tab(i);
      --
      -- Check if ALU exists for this element link.
      --
      open csr_alu_exists(l_link_id);
      fetch csr_alu_exists into l_dummy;
      if csr_alu_exists%found then
        l_alu_exists := true;
      else
        l_alu_exists := false;
      end if;
      close csr_alu_exists;

      if not l_alu_exists then
        --
        -- Create ALU records comparing the link dates and
        -- the eligible assignment date range.
        --
        --  Element Link              |--------------->
        --  Eligible Assignment  |---------->    |-------->
        --
        --  ALU                       |----->    |---->
        --
        --  Note: We no longer check the termination rule for ALUs.
        --
        for j in 1..g_alu_asg_pg_hist.count loop
          --
          l_asg_start_date := g_alu_asg_pg_hist(j).effective_start_date;
          l_asg_end_date   := g_alu_asg_pg_hist(j).effective_end_date;
          --
          if NOT l_asg_locked then
            --
            -- Lock the assignment.
            --
            lock_asg(p_assignment_id, l_asg_start_date, l_asg_end_date);
          end if;
          --
          if     l_link_start_date <= l_asg_end_date
             and l_link_end_date   >= l_asg_start_date then
            --
            l_alu_start_date := greatest(l_link_start_date, l_asg_start_date);
            l_alu_end_date   := least(l_link_end_date, l_asg_end_date);
            --
            if l_alu_end_date >= l_alu_start_date then

              l_alu_idx := l_alu_idx+1;
              l_alu_start_date_tab(l_alu_idx) := l_alu_start_date;
              l_alu_end_date_tab(l_alu_idx)   := l_alu_end_date;
              l_alu_link_id_tab(l_alu_idx)    := l_link_id;

            end if;
          end if;
        end loop;
        --
        -- The assignment rows have been locked.
        --
        l_asg_locked := true;
        --
      end if;
    end loop;
    --
    -- Upload ALUs
    --
    forall i in 1..l_alu_start_date_tab.count
      insert into pay_assignment_link_usages_f
        (assignment_link_usage_id
        ,effective_start_date
        ,effective_end_date
        ,element_link_id
        ,assignment_id)
      values
        (pay_assignment_link_usages_s.nextval
        ,l_alu_start_date_tab(i)
        ,l_alu_end_date_tab(i)
        ,l_alu_link_id_tab(i)
        ,p_assignment_id
        );
    --
  end if;
  --
  hr_utility.set_location('Leaving: '||l_proc, 100);
  --
end create_alu_asg_pg;
--
--------------------------------------------------------------------------------
--
procedure create_alu_asg
--
--******************************************************************************
--* creates ALU's for the assignment with the specified element links.         *
--*                                                                            *
--* NOTE: The element link array should start with index number 1 and          *
--* should be sorted by people group id and link effective dates must be       *
--* min effective_start_date and max effective_end_date.                       *
--******************************************************************************
--
  (p_assignment_id        in number
  ,p_pg_link_tab          in t_pg_link_tab
  )
is
  l_proc               varchar2(72) := g_package||'create_alu_asg';
  --
  type t_pg_index_rec is record
    (people_group_id number
    ,start_idx       binary_integer
    ,end_idx         binary_integer
    );
  type t_pg_index_tab is table of t_pg_index_rec
    index by binary_integer;
  --
  l_pg_idx_tab       t_pg_index_tab;
  l_idx              number:=0;
  l_prev_pg_id       number;
  --
  l_eligible_pg_exists  boolean;
  l_link_id_tab         t_num_tab;
  l_link_start_date_tab t_date_tab;
  l_link_end_date_tab   t_date_tab;
  l_link_idx            number;
  --
begin
  --
  hr_utility.set_location('Entering: '||l_proc, 5);
  --
  -- Check to see if the specified table variable contains
  -- any element link data.
  --
  if p_pg_link_tab.count = 0 then
    --
    -- No element link was specified, hence exit this procedure.
    --
    hr_utility.set_location(l_proc, 10);
    return;
  end if;

  --
  -- Initialize the assignment cache.
  --
  init_alu_asg(p_assignment_id);

  --
  -- Check to see if the assignment is associated with any people group.
  --
  if g_alu_asg_hist.count = 0 then
    --
    -- No people group is associated with this assignment,
    -- hence exit this procedure.
    --
    hr_utility.set_location(l_proc, 20);
    return;
  end if;

  --
  -- Derive distinct people groups from the specified table variable.
  --
  for i in 1..p_pg_link_tab.count loop
    if p_pg_link_tab(i).people_group_id = l_prev_pg_id then
      l_pg_idx_tab(l_idx).end_idx := i;
    else
      l_idx := l_idx+1;
      l_prev_pg_id := p_pg_link_tab(i).people_group_id;
      l_pg_idx_tab(l_idx).people_group_id := l_prev_pg_id;
      l_pg_idx_tab(l_idx).start_idx       := i;
      l_pg_idx_tab(l_idx).end_idx         := i;
    end if;
  end loop;
  --
  -- Loop for each people group
  --
  for i in 1..l_pg_idx_tab.count loop
    --
    -- Check the eligibility of the people group.
    --
    chk_pg_eligibility
      (p_assignment_id
      ,l_pg_idx_tab(i).people_group_id
      ,l_eligible_pg_exists);

    --
    if l_eligible_pg_exists then
      --
      l_link_id_tab.delete;
      l_link_start_date_tab.delete;
      l_link_end_date_tab.delete;
      l_link_idx := 0;
      --
      -- Prepare element link array for this people group.
      --
      for j in l_pg_idx_tab(i).start_idx..l_pg_idx_tab(i).end_idx loop
        l_link_idx := l_link_idx+1;
        l_link_id_tab(l_link_idx) := p_pg_link_tab(j).element_link_id;
        l_link_start_date_tab(l_link_idx)
          := p_pg_link_tab(j).effective_start_date;
        l_link_end_date_tab(l_link_idx)
          := p_pg_link_tab(j).effective_end_date;
      end loop;
      --
      -- Create ALUs for this people group.
      --
      create_alu_asg_pg
        (p_assignment_id        => p_assignment_id
        ,p_link_people_group_id => l_pg_idx_tab(i).people_group_id
        ,p_link_id_tab          => l_link_id_tab
        ,p_link_start_date_tab  => l_link_start_date_tab
        ,p_link_end_date_tab    => l_link_end_date_tab
        );
      --
    end if;
    --
  end loop;
  --
  hr_utility.set_location('Leaving: '||l_proc, 100);
  --
end create_alu_asg;
--
--------------------------------------------------------------------------------
--
procedure rebuild_alus
--
--******************************************************************************
--*  Name      : rebuild_alus                                                  *
--*  Purpose   : This procedure rebuilds all ALUs for a given assignment id    *
--*              and is used by the Generic Upgrade Mechanism.                 *
--******************************************************************************
--
  (p_assignment_id in number)
is
  --
  -- user defined types
  --
  type t_asg_rec is record
                    (effective_start_date date,
                     effective_end_date   date,
                     business_group_id    number,
                     people_group_id      number,
                     id_flex_num          number);
  --
  type t_alu_start_date is table of pay_assignment_link_usages_f.effective_start_date%type
     index by binary_integer;
  --
  type t_alu_end_date is table of pay_assignment_link_usages_f.effective_end_date%type
     index by binary_integer;
  --
  type t_alu_link_id is table of pay_assignment_link_usages_f.element_link_id%type
     index by binary_integer;
  --
  type t_alu_tab is record
                 (start_date t_alu_start_date,
                  end_date   t_alu_end_date,
                  link_id    t_alu_link_id);
  --
  -- find all instances of the assignment that have a people group
  --
  cursor csr_assignment
          (
           p_assignment_id number
          ) is
    select asg.effective_start_date,
           asg.effective_end_date,
           asg.business_group_id,
           asg.people_group_id,
           ppg.id_flex_num
    from   per_all_assignments_f asg,
           pay_people_groups ppg
    where  asg.assignment_id = p_assignment_id
      and  asg.assignment_type not in ('A','O')
      and  asg.people_group_id is not null
      and  ppg.people_group_id = asg.people_group_id
    order by asg.effective_start_date;
  --
  -- find all element links that are match the people group
  --
  cursor csr_link
          (
           p_id_flex_num          number,
           p_business_group_id    number,
           p_people_group_id      number,
           p_effective_start_date date,
           p_effective_end_date   date
          ) is
    select el.element_link_id,
           min(el.effective_start_date) effective_start_date,
           max(el.effective_end_date) effective_end_date
    from   pay_element_links_f el,
           pay_people_groups el_pg,
           pay_people_groups asg_pg
    where  asg_pg.id_flex_num      = p_id_flex_num
      and  asg_pg.people_group_id  = p_people_group_id
      and  el_pg.id_flex_num       = asg_pg.id_flex_num
      and  el.business_group_id + 0    = p_business_group_id
      and  el.effective_start_date <= p_effective_end_date
      and  el.effective_end_date   >= p_effective_start_date
      and  el_pg.people_group_id   = el.people_group_id
      and  (el_pg.segment1  is null or el_pg.segment1  = asg_pg.segment1)
      and  (el_pg.segment2  is null or el_pg.segment2  = asg_pg.segment2)
      and  (el_pg.segment3  is null or el_pg.segment3  = asg_pg.segment3)
      and  (el_pg.segment4  is null or el_pg.segment4  = asg_pg.segment4)
      and  (el_pg.segment5  is null or el_pg.segment5  = asg_pg.segment5)
      and  (el_pg.segment6  is null or el_pg.segment6  = asg_pg.segment6)
      and  (el_pg.segment7  is null or el_pg.segment7  = asg_pg.segment7)
      and  (el_pg.segment8  is null or el_pg.segment8  = asg_pg.segment8)
      and  (el_pg.segment9  is null or el_pg.segment9  = asg_pg.segment9)
      and  (el_pg.segment10 is null or el_pg.segment10 = asg_pg.segment10)
      and  (el_pg.segment11 is null or el_pg.segment11 = asg_pg.segment11)
      and  (el_pg.segment12 is null or el_pg.segment12 = asg_pg.segment12)
      and  (el_pg.segment13 is null or el_pg.segment13 = asg_pg.segment13)
      and  (el_pg.segment14 is null or el_pg.segment14 = asg_pg.segment14)
      and  (el_pg.segment15 is null or el_pg.segment15 = asg_pg.segment15)
      and  (el_pg.segment16 is null or el_pg.segment16 = asg_pg.segment16)
      and  (el_pg.segment17 is null or el_pg.segment17 = asg_pg.segment17)
      and  (el_pg.segment18 is null or el_pg.segment18 = asg_pg.segment18)
      and  (el_pg.segment19 is null or el_pg.segment19 = asg_pg.segment19)
      and  (el_pg.segment20 is null or el_pg.segment20 = asg_pg.segment20)
      and  (el_pg.segment21 is null or el_pg.segment21 = asg_pg.segment21)
      and  (el_pg.segment22 is null or el_pg.segment22 = asg_pg.segment22)
      and  (el_pg.segment23 is null or el_pg.segment23 = asg_pg.segment23)
      and  (el_pg.segment24 is null or el_pg.segment24 = asg_pg.segment24)
      and  (el_pg.segment25 is null or el_pg.segment25 = asg_pg.segment25)
      and  (el_pg.segment26 is null or el_pg.segment26 = asg_pg.segment26)
      and  (el_pg.segment27 is null or el_pg.segment27 = asg_pg.segment27)
      and  (el_pg.segment28 is null or el_pg.segment28 = asg_pg.segment28)
      and  (el_pg.segment29 is null or el_pg.segment29 = asg_pg.segment29)
      and  (el_pg.segment30 is null or el_pg.segment30 = asg_pg.segment30)
    group by el.element_link_id;
  --
  -- local variables
  --
  v_assignment      t_asg_rec;
  v_alu_tab         t_alu_tab;
  v_asg_start_date  date;
  v_asg_end_date    date;
  v_people_group_id number;
  v_id_flex_num     number;
  v_alu_start_date  date;
  v_alu_end_date    date;
  v_alu_term_date   date;
  v_counter         number := 0;
  --
begin
  --
  -- Delete all the alus for the assignment
  --
  delete from pay_assignment_link_usages_f alu
  where alu.assignment_id = p_assignment_id;
  --
  --
  open csr_assignment(p_assignment_id);
  --
  -- get first assignment record to initialise variables
  --
  fetch csr_assignment into v_assignment;
  if csr_assignment%found then
    --
    -- set up variables for use in loop
    --
    v_asg_start_date  := v_assignment.effective_start_date;
    v_asg_end_date    := v_assignment.effective_end_date;
    v_people_group_id := v_assignment.people_group_id;
    v_id_flex_num     := v_assignment.id_flex_num;
    --
    while csr_assignment%found loop
      --
      -- get next assignment record
      --
      fetch csr_assignment into v_assignment;
      --
      -- detect change of people group , non-contiguous people groups or
      -- that the last record has been read
      --
      if csr_assignment%notfound or not
         (v_assignment.people_group_id = v_people_group_id and
          v_assignment.effective_start_date = v_asg_end_date + 1) then
        --
        -- find all links that overlap with the assignment and have the same
        -- people group as the assignment
        --
        for v_link in csr_link(v_id_flex_num,
                               v_assignment.business_group_id,
                               v_people_group_id,
                               v_asg_start_date,
                               v_asg_end_date) loop
          --
          -- calculate the start date of the alu which is the greatest of
          -- the start dates of the link and assignment
          --
          v_alu_start_date := greatest(v_asg_start_date,
                                       v_link.effective_start_date);
          --
          -- find the termination date of the alu if the person has been
          -- terminated ie. taking inot account the termination processing
          -- rule of the element type. if no termination has taken place
          -- then the date returned is the end of time.
          -- nb. v_dummy_date is used to soak up some out parameters that
          -- are not required.
          --
          -- Bug 5202396.
          -- The check for termination rule caused a significant performance
          -- issue. Since ALU is only a part of the link eligibility rules,
          -- we can determine the end date with the link and the assignment.
          --
          /***
          hr_entry.entry_asg_pay_link_dates(p_assignment_id,
                                            v_link.element_link_id,
                                            v_alu_start_date,
                                            v_alu_term_date,
                                            v_dummy_date,
                                            v_dummy_date,
                                            v_dummy_date,
                                            v_dummy_date,
                                            false);
          ***/
          --
          -- calculate the end date of the alu which is the least of the
          -- end dates of the link and assignment.
          --
          v_alu_end_date := least(v_asg_end_date,
                                  v_link.effective_end_date);
          --
          -- Make sure that the alu start date is on or before the end date
          --
          if v_alu_start_date <= v_alu_end_date then
            --
            v_counter := v_counter + 1;
            --
            v_alu_tab.start_date(v_counter) := v_alu_start_date;
            v_alu_tab.end_date(v_counter)   := v_alu_end_date;
            v_alu_tab.link_id(v_counter)    := v_link.element_link_id;
            --
          end if;
          --
        end loop;
        --
        -- reset start and end dates
        --
        v_asg_start_date := v_assignment.effective_start_date;
        v_asg_end_date   := v_assignment.effective_end_date;
        --
      else
        --
        -- increment end date of assignment
        --
        v_asg_end_date := v_assignment.effective_end_date;
        --
      end if;
      --
      -- save value for future comparison
      --
      v_people_group_id := v_assignment.people_group_id;
      v_id_flex_num     := v_assignment.id_flex_num;
      --
      -- Create the ALUs in bulk
      --
      forall i in 1..v_counter
          insert into pay_assignment_link_usages_f
          (assignment_link_usage_id,
           effective_start_date,
           effective_end_date,
           element_link_id,
           assignment_id)
          values
          (
           pay_assignment_link_usages_s.nextval,
           v_alu_tab.start_date(i),
           v_alu_tab.end_date(i),
           v_alu_tab.link_id(i),
           p_assignment_id
          );
      --
      v_counter := 0;
      v_alu_tab.start_date.delete;
      v_alu_tab.end_date.delete;
      v_alu_tab.link_id.delete;
      --
    end loop;
    --
  end if;
  --
  close csr_assignment;
  --
end rebuild_alus;
--
--------------------------------------------------------------------------------
--
end PAY_ASG_LINK_USAGES_PKG;

/
