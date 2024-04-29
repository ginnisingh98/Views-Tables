--------------------------------------------------------
--  DDL for Package Body JTF_TASK_WF_UTIL_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TASK_WF_UTIL_W" as
  /* $Header: jtfvtkwb.pls 120.2 2006/04/26 04:42 knayyar ship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');
  rosetta_g_mistake_date_high date := to_date('01/01/+4710', 'MM/DD/SYYYY');
  rosetta_g_mistake_date_low date := to_date('01/01/-4710', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d > rosetta_g_mistake_date_high then return fnd_api.g_miss_date; end if;
    if d < rosetta_g_mistake_date_low then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure rosetta_table_copy_in_p4(t out nocopy jtf_task_wf_util.nlist_tbl_type, a0 JTF_VARCHAR2_TABLE_400
    , a1 JTF_VARCHAR2_TABLE_400
    , a2 JTF_VARCHAR2_TABLE_400
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).name := a0(indx);
          t(ddindx).display_name := a1(indx);
          t(ddindx).email_address := a2(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p4;
  procedure rosetta_table_copy_out_p4(t jtf_task_wf_util.nlist_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_400
    , a1 out nocopy JTF_VARCHAR2_TABLE_400
    , a2 out nocopy JTF_VARCHAR2_TABLE_400
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_400();
    a1 := JTF_VARCHAR2_TABLE_400();
    a2 := JTF_VARCHAR2_TABLE_400();
  else
      a0 := JTF_VARCHAR2_TABLE_400();
      a1 := JTF_VARCHAR2_TABLE_400();
      a2 := JTF_VARCHAR2_TABLE_400();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).name;
          a1(indx) := t(ddindx).display_name;
          a2(indx) := t(ddindx).email_address;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p4;

  procedure do_notification(p_task_id  NUMBER
    , ddrosetta_retval_bool OUT NOCOPY NUMBER
  )

  as
    ddindx binary_integer; indx binary_integer;
    ddrosetta_retval boolean;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    -- here's the delegated call to the old PL/SQL routine
    ddrosetta_retval := jtf_task_wf_util.do_notification(p_task_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    if ddrosetta_retval is null
      then ddrosetta_retval_bool := null;
    elsif ddrosetta_retval
      then ddrosetta_retval_bool := 1;
    else ddrosetta_retval_bool := 0;
    end if;
  end;

  procedure create_notification(p_event  VARCHAR2
    , p_task_id  NUMBER
    , p_old_owner_id  NUMBER
    , p_old_owner_code  VARCHAR2
    , p_old_assignee_id  NUMBER
    , p_old_assignee_code  VARCHAR2
    , p_new_assignee_id  NUMBER
    , p_new_assignee_code  VARCHAR2
    , p_old_type  NUMBER
    , p_old_priority  NUMBER
    , p_old_status  NUMBER
    , p_old_planned_start_date  date
    , p_old_planned_end_date  date
    , p_old_scheduled_start_date  date
    , p_old_scheduled_end_date  date
    , p_old_actual_start_date  date
    , p_old_actual_end_date  date
    , p_old_description  VARCHAR2
    , p_abort_workflow  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_old_planned_start_date date;
    ddp_old_planned_end_date date;
    ddp_old_scheduled_start_date date;
    ddp_old_scheduled_end_date date;
    ddp_old_actual_start_date date;
    ddp_old_actual_end_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any











    ddp_old_planned_start_date := rosetta_g_miss_date_in_map(p_old_planned_start_date);

    ddp_old_planned_end_date := rosetta_g_miss_date_in_map(p_old_planned_end_date);

    ddp_old_scheduled_start_date := rosetta_g_miss_date_in_map(p_old_scheduled_start_date);

    ddp_old_scheduled_end_date := rosetta_g_miss_date_in_map(p_old_scheduled_end_date);

    ddp_old_actual_start_date := rosetta_g_miss_date_in_map(p_old_actual_start_date);

    ddp_old_actual_end_date := rosetta_g_miss_date_in_map(p_old_actual_end_date);






    -- here's the delegated call to the old PL/SQL routine
    jtf_task_wf_util.create_notification(p_event,
      p_task_id,
      p_old_owner_id,
      p_old_owner_code,
      p_old_assignee_id,
      p_old_assignee_code,
      p_new_assignee_id,
      p_new_assignee_code,
      p_old_type,
      p_old_priority,
      p_old_status,
      ddp_old_planned_start_date,
      ddp_old_planned_end_date,
      ddp_old_scheduled_start_date,
      ddp_old_scheduled_end_date,
      ddp_old_actual_start_date,
      ddp_old_actual_end_date,
      p_old_description,
      p_abort_workflow,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





















  end;

end jtf_task_wf_util_w;

/
