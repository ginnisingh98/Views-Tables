--------------------------------------------------------
--  DDL for Package Body JTF_TASK_WORKFLOW_PKG_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TASK_WORKFLOW_PKG_W" as
  /* $Header: jtfrtkwb.pls 120.2 2005/07/05 10:51:29 knayyar ship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  function rosetta_g_miss_num_map(n number) return number as
    a number := fnd_api.g_miss_num;
    b number := 0-1962.0724;
  begin
    if n=a then return b; end if;
    if n=b then return a; end if;
    return n;
  end;

  procedure rosetta_table_copy_in_p3(t out nocopy jtf_task_workflow_pkg.task_details_tbl, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).task_attribute := a0(indx);
          t(ddindx).old_value := a1(indx);
          t(ddindx).new_value := a2(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t jtf_task_workflow_pkg.task_details_tbl, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).task_attribute;
          a1(indx) := t(ddindx).old_value;
          a2(indx) := t(ddindx).new_value;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  function get_workflow_disp_name(p_item_type  VARCHAR2
    , p_process_name  VARCHAR2
    , p_raise_error  number
  ) return varchar2

  as
    ddp_raise_error boolean;
    ddindx binary_integer; indx binary_integer;
    ddrosetta_retval varchar2(4000);
  begin

    -- copy data to the local IN or IN-OUT args, if any


    if p_raise_error is null
      then ddp_raise_error := null;
    elsif p_raise_error = 0
      then ddp_raise_error := false;
    else ddp_raise_error := true;
    end if;

    -- here's the delegated call to the old PL/SQL routine
    ddrosetta_retval := jtf_task_workflow_pkg.get_workflow_disp_name(p_item_type,
      p_process_name,
      ddp_raise_error);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



    return ddrosetta_retval;
  end;

  procedure start_task_workflow(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_task_id  NUMBER
    , p_old_assignee_code  VARCHAR2
    , p_old_assignee_id  NUMBER
    , p_new_assignee_code  VARCHAR2
    , p_new_assignee_id  NUMBER
    , p_old_owner_code  VARCHAR2
    , p_old_owner_id  NUMBER
    , p_new_owner_code  VARCHAR2
    , p_new_owner_id  NUMBER
    , p12_a0 JTF_VARCHAR2_TABLE_100
    , p12_a1 JTF_VARCHAR2_TABLE_100
    , p12_a2 JTF_VARCHAR2_TABLE_100
    , p_event  VARCHAR2
    , p_wf_display_name  VARCHAR2
    , p_wf_process  VARCHAR2
    , p_wf_item_type  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_task_details_tbl jtf_task_workflow_pkg.task_details_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any












    jtf_task_workflow_pkg_w.rosetta_table_copy_in_p3(ddp_task_details_tbl, p12_a0
      , p12_a1
      , p12_a2
      );








    -- here's the delegated call to the old PL/SQL routine
    jtf_task_workflow_pkg.start_task_workflow(p_api_version,
      p_init_msg_list,
      p_commit,
      p_task_id,
      p_old_assignee_code,
      p_old_assignee_id,
      p_new_assignee_code,
      p_new_assignee_id,
      p_old_owner_code,
      p_old_owner_id,
      p_new_owner_code,
      p_new_owner_id,
      ddp_task_details_tbl,
      p_event,
      p_wf_display_name,
      p_wf_process,
      p_wf_item_type,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



















  end;

end jtf_task_workflow_pkg_w;

/
