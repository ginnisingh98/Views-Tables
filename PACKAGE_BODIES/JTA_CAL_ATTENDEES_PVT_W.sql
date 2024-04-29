--------------------------------------------------------
--  DDL for Package Body JTA_CAL_ATTENDEES_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTA_CAL_ATTENDEES_PVT_W" as
  /* $Header: jtacatwb.pls 115.1 2002/12/07 01:28:21 rdespoto ship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure rosetta_table_copy_in_p1(t out nocopy jta_cal_attendees_pvt.resource_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).resource_id := a0(indx);
          t(ddindx).resource_type := a1(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t jta_cal_attendees_pvt.resource_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).resource_id;
          a1(indx) := t(ddindx).resource_type;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure rosetta_table_copy_in_p3(t out nocopy jta_cal_attendees_pvt.task_assign_tbl, a0 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).task_assignment_id := a0(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t jta_cal_attendees_pvt.task_assign_tbl, a0 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).task_assignment_id;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure create_cal_assignment(p_task_id  NUMBER
    , p1_a0 JTF_NUMBER_TABLE
    , p1_a1 JTF_VARCHAR2_TABLE_100
    , p_add_option  VARCHAR2
    , p_invitor_res_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , p5_a0 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_resources jta_cal_attendees_pvt.resource_tbl;
    ddx_task_assignment_ids jta_cal_attendees_pvt.task_assign_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    jta_cal_attendees_pvt_w.rosetta_table_copy_in_p1(ddp_resources, p1_a0
      , p1_a1
      );





    -- here's the delegated call to the old PL/SQL routine
    jta_cal_attendees_pvt.create_cal_assignment(p_task_id,
      ddp_resources,
      p_add_option,
      p_invitor_res_id,
      x_return_status,
      ddx_task_assignment_ids);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    jta_cal_attendees_pvt_w.rosetta_table_copy_out_p3(ddx_task_assignment_ids, p5_a0
      );
  end;

  procedure delete_cal_assignment(p_object_version_number  NUMBER
    , p1_a0 JTF_NUMBER_TABLE
    , p_delete_option  VARCHAR2
    , p_no_of_attendies  NUMBER
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_task_assignments jta_cal_attendees_pvt.task_assign_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    jta_cal_attendees_pvt_w.rosetta_table_copy_in_p3(ddp_task_assignments, p1_a0
      );




    -- here's the delegated call to the old PL/SQL routine
    jta_cal_attendees_pvt.delete_cal_assignment(p_object_version_number,
      ddp_task_assignments,
      p_delete_option,
      p_no_of_attendies,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




  end;

end jta_cal_attendees_pvt_w;

/
