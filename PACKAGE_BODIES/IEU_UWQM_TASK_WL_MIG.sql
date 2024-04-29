--------------------------------------------------------
--  DDL for Package Body IEU_UWQM_TASK_WL_MIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEU_UWQM_TASK_WL_MIG" AS
/* $Header: IEUVTKPB.pls 120.2 2006/05/02 12:21:54 pkumble noship $ */

FUNCTION GET_TASKS_BY_PRIORITY
RETURN SYSTEM.IEU_UWQM_TASK_PRIORITY_NST AS

 l_priority_list l_pty_list;

cursor l_tasks_cur is
select b.importance_level, count(a.task_id) cnt
from   jtf_Tasks_b a, jtf_task_priorities_vl b
where  a.task_priority_id = b.task_priority_id
and    nvl(a.deleted_flag , 'N') = 'N'
and    a.entity = 'TASK'
and    nvl(a.open_flag, 'N') = 'Y'
and source_object_type_code <> 'SR'
group by importance_level
order by importance_level;

i number := 0;

l_null_pty_count  Number;

l_return_list SYSTEM.IEU_UWQM_TASK_PRIORITY_NST;

begin

  for ctr in l_tasks_cur loop
    if ctr.importance_level <= 4
    then
      i := i + 1;
      l_priority_list(i).importance_level := ctr.importance_level;
      l_priority_list(i).task_count := ctr.cnt;
    else
      l_priority_list(i).importance_level := 4;
      l_priority_list(i).task_count := l_priority_list(i).task_count + ctr.cnt;
     end if;
  end loop;

  -- All Tasks with Null Priority Id will be included under importance level 4

  select count(a.task_id)
  into l_null_pty_count
  from   jtf_Tasks_b a
  where a.task_priority_id is null
  and nvl(a.deleted_flag, 'N') = 'N'
  and a.entity = 'TASK'
  and nvl(a.open_flag, 'N') = 'Y';

  for ctr in l_priority_list.FIRST .. l_priority_list.last loop
      if  l_priority_list(ctr).importance_level = 4
      then
          l_priority_list(ctr).task_count := l_priority_list(ctr).task_count + l_null_pty_count;
      end if;
  end loop;

  l_return_list := SYSTEM.IEU_UWQM_TASK_PRIORITY_NST();
  for k in 1..l_priority_list.count loop
    l_return_list.extend;
    l_return_list(l_return_list.last) := SYSTEM.IEU_UWQM_TASK_PRIORITY_OBJ(l_priority_list(k).importance_level, l_priority_list(k).task_count);
  end loop;

  return l_return_list;

END GET_TASKS_BY_PRIORITY;

END IEU_UWQM_TASK_WL_MIG;

/
