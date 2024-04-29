--------------------------------------------------------
--  DDL for Package Body AHL_VWP_TASKS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_VWP_TASKS_PVT_W" as
  /* $Header: AHLWTSKB.pls 120.2.12010000.3 2010/03/28 10:34:14 manesing ship $ */
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

  procedure rosetta_table_copy_in_p1(t out nocopy ahl_vwp_tasks_pvt.srch_task_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_DATE_TABLE
    , a2 JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).task_id := a0(indx);
          t(ddindx).task_start_time := rosetta_g_miss_date_in_map(a1(indx));
          t(ddindx).task_end_time := rosetta_g_miss_date_in_map(a2(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t ahl_vwp_tasks_pvt.srch_task_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_DATE_TABLE
    , a2 out nocopy JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_DATE_TABLE();
    a2 := JTF_DATE_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_DATE_TABLE();
      a2 := JTF_DATE_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).task_id;
          a1(indx) := t(ddindx).task_start_time;
          a2(indx) := t(ddindx).task_end_time;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure get_task_details(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , p_task_id  NUMBER
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  NUMBER
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  NUMBER
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  NUMBER
    , p6_a19 out nocopy  NUMBER
    , p6_a20 out nocopy  NUMBER
    , p6_a21 out nocopy  VARCHAR2
    , p6_a22 out nocopy  NUMBER
    , p6_a23 out nocopy  NUMBER
    , p6_a24 out nocopy  NUMBER
    , p6_a25 out nocopy  NUMBER
    , p6_a26 out nocopy  NUMBER
    , p6_a27 out nocopy  VARCHAR2
    , p6_a28 out nocopy  VARCHAR2
    , p6_a29 out nocopy  VARCHAR2
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  NUMBER
    , p6_a34 out nocopy  DATE
    , p6_a35 out nocopy  NUMBER
    , p6_a36 out nocopy  DATE
    , p6_a37 out nocopy  NUMBER
    , p6_a38 out nocopy  NUMBER
    , p6_a39 out nocopy  VARCHAR2
    , p6_a40 out nocopy  VARCHAR2
    , p6_a41 out nocopy  VARCHAR2
    , p6_a42 out nocopy  VARCHAR2
    , p6_a43 out nocopy  VARCHAR2
    , p6_a44 out nocopy  VARCHAR2
    , p6_a45 out nocopy  VARCHAR2
    , p6_a46 out nocopy  VARCHAR2
    , p6_a47 out nocopy  VARCHAR2
    , p6_a48 out nocopy  VARCHAR2
    , p6_a49 out nocopy  VARCHAR2
    , p6_a50 out nocopy  VARCHAR2
    , p6_a51 out nocopy  VARCHAR2
    , p6_a52 out nocopy  VARCHAR2
    , p6_a53 out nocopy  VARCHAR2
    , p6_a54 out nocopy  VARCHAR2
    , p6_a55 out nocopy  DATE
    , p6_a56 out nocopy  DATE
    , p6_a57 out nocopy  DATE
    , p6_a58 out nocopy  VARCHAR2
    , p6_a59 out nocopy  VARCHAR2
    , p6_a60 out nocopy  NUMBER
    , p6_a61 out nocopy  NUMBER
    , p6_a62 out nocopy  VARCHAR2
    , p6_a63 out nocopy  NUMBER
    , p6_a64 out nocopy  VARCHAR2
    , p6_a65 out nocopy  VARCHAR2
    , p6_a66 out nocopy  DATE
    , p6_a67 out nocopy  DATE
    , p6_a68 out nocopy  VARCHAR2
    , p6_a69 out nocopy  VARCHAR2
    , p6_a70 out nocopy  VARCHAR2
    , p6_a71 out nocopy  NUMBER
    , p6_a72 out nocopy  VARCHAR2
    , p6_a73 out nocopy  NUMBER
    , p6_a74 out nocopy  VARCHAR2
    , p6_a75 out nocopy  VARCHAR2
    , p6_a76 out nocopy  DATE
    , p6_a77 out nocopy  DATE
    , p6_a78 out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddx_task_rec ahl_vwp_rules_pvt.task_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    -- here's the delegated call to the old PL/SQL routine
    ahl_vwp_tasks_pvt.get_task_details(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_module_type,
      p_task_id,
      ddx_task_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_task_rec.visit_task_id;
    p6_a1 := ddx_task_rec.visit_task_number;
    p6_a2 := ddx_task_rec.visit_id;
    p6_a3 := ddx_task_rec.template_flag;
    p6_a4 := ddx_task_rec.inventory_item_id;
    p6_a5 := ddx_task_rec.item_organization_id;
    p6_a6 := ddx_task_rec.item_name;
    p6_a7 := ddx_task_rec.cost_parent_id;
    p6_a8 := ddx_task_rec.cost_parent_number;
    p6_a9 := ddx_task_rec.mr_route_id;
    p6_a10 := ddx_task_rec.route_number;
    p6_a11 := ddx_task_rec.mr_id;
    p6_a12 := ddx_task_rec.mr_title;
    p6_a13 := ddx_task_rec.unit_effectivity_id;
    p6_a14 := ddx_task_rec.department_id;
    p6_a15 := ddx_task_rec.dept_name;
    p6_a16 := ddx_task_rec.service_request_id;
    p6_a17 := ddx_task_rec.service_request_number;
    p6_a18 := ddx_task_rec.originating_task_id;
    p6_a19 := ddx_task_rec.orginating_task_number;
    p6_a20 := ddx_task_rec.instance_id;
    p6_a21 := ddx_task_rec.serial_number;
    p6_a22 := ddx_task_rec.project_task_id;
    p6_a23 := ddx_task_rec.project_task_number;
    p6_a24 := ddx_task_rec.primary_visit_task_id;
    p6_a25 := ddx_task_rec.start_from_hour;
    p6_a26 := ddx_task_rec.duration;
    p6_a27 := ddx_task_rec.task_type_code;
    p6_a28 := ddx_task_rec.task_type_value;
    p6_a29 := ddx_task_rec.visit_task_name;
    p6_a30 := ddx_task_rec.description;
    p6_a31 := ddx_task_rec.task_status_code;
    p6_a32 := ddx_task_rec.task_status_value;
    p6_a33 := ddx_task_rec.object_version_number;
    p6_a34 := ddx_task_rec.last_update_date;
    p6_a35 := ddx_task_rec.last_updated_by;
    p6_a36 := ddx_task_rec.creation_date;
    p6_a37 := ddx_task_rec.created_by;
    p6_a38 := ddx_task_rec.last_update_login;
    p6_a39 := ddx_task_rec.attribute_category;
    p6_a40 := ddx_task_rec.attribute1;
    p6_a41 := ddx_task_rec.attribute2;
    p6_a42 := ddx_task_rec.attribute3;
    p6_a43 := ddx_task_rec.attribute4;
    p6_a44 := ddx_task_rec.attribute5;
    p6_a45 := ddx_task_rec.attribute6;
    p6_a46 := ddx_task_rec.attribute7;
    p6_a47 := ddx_task_rec.attribute8;
    p6_a48 := ddx_task_rec.attribute9;
    p6_a49 := ddx_task_rec.attribute10;
    p6_a50 := ddx_task_rec.attribute11;
    p6_a51 := ddx_task_rec.attribute12;
    p6_a52 := ddx_task_rec.attribute13;
    p6_a53 := ddx_task_rec.attribute14;
    p6_a54 := ddx_task_rec.attribute15;
    p6_a55 := ddx_task_rec.task_start_date;
    p6_a56 := ddx_task_rec.task_end_date;
    p6_a57 := ddx_task_rec.due_by_date;
    p6_a58 := ddx_task_rec.zone_name;
    p6_a59 := ddx_task_rec.sub_zone_name;
    p6_a60 := ddx_task_rec.tolerance_after;
    p6_a61 := ddx_task_rec.tolerance_before;
    p6_a62 := ddx_task_rec.tolerance_uom;
    p6_a63 := ddx_task_rec.workorder_id;
    p6_a64 := ddx_task_rec.wo_name;
    p6_a65 := ddx_task_rec.wo_status;
    p6_a66 := ddx_task_rec.wo_start_date;
    p6_a67 := ddx_task_rec.wo_end_date;
    p6_a68 := ddx_task_rec.operation_flag;
    p6_a69 := ddx_task_rec.is_production_flag;
    p6_a70 := ddx_task_rec.create_job_flag;
    p6_a71 := ddx_task_rec.stage_id;
    p6_a72 := ddx_task_rec.stage_name;
    p6_a73 := ddx_task_rec.quantity;
    p6_a74 := ddx_task_rec.uom;
    p6_a75 := ddx_task_rec.instance_number;
    p6_a76 := ddx_task_rec.past_task_start_date;
    p6_a77 := ddx_task_rec.past_task_end_date;
    p6_a78 := ddx_task_rec.route_id;



  end;

  procedure create_task(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , p5_a0 in out nocopy  NUMBER
    , p5_a1 in out nocopy  NUMBER
    , p5_a2 in out nocopy  NUMBER
    , p5_a3 in out nocopy  VARCHAR2
    , p5_a4 in out nocopy  NUMBER
    , p5_a5 in out nocopy  NUMBER
    , p5_a6 in out nocopy  VARCHAR2
    , p5_a7 in out nocopy  NUMBER
    , p5_a8 in out nocopy  NUMBER
    , p5_a9 in out nocopy  NUMBER
    , p5_a10 in out nocopy  VARCHAR2
    , p5_a11 in out nocopy  NUMBER
    , p5_a12 in out nocopy  VARCHAR2
    , p5_a13 in out nocopy  NUMBER
    , p5_a14 in out nocopy  NUMBER
    , p5_a15 in out nocopy  VARCHAR2
    , p5_a16 in out nocopy  NUMBER
    , p5_a17 in out nocopy  VARCHAR2
    , p5_a18 in out nocopy  NUMBER
    , p5_a19 in out nocopy  NUMBER
    , p5_a20 in out nocopy  NUMBER
    , p5_a21 in out nocopy  VARCHAR2
    , p5_a22 in out nocopy  NUMBER
    , p5_a23 in out nocopy  NUMBER
    , p5_a24 in out nocopy  NUMBER
    , p5_a25 in out nocopy  NUMBER
    , p5_a26 in out nocopy  NUMBER
    , p5_a27 in out nocopy  VARCHAR2
    , p5_a28 in out nocopy  VARCHAR2
    , p5_a29 in out nocopy  VARCHAR2
    , p5_a30 in out nocopy  VARCHAR2
    , p5_a31 in out nocopy  VARCHAR2
    , p5_a32 in out nocopy  VARCHAR2
    , p5_a33 in out nocopy  NUMBER
    , p5_a34 in out nocopy  DATE
    , p5_a35 in out nocopy  NUMBER
    , p5_a36 in out nocopy  DATE
    , p5_a37 in out nocopy  NUMBER
    , p5_a38 in out nocopy  NUMBER
    , p5_a39 in out nocopy  VARCHAR2
    , p5_a40 in out nocopy  VARCHAR2
    , p5_a41 in out nocopy  VARCHAR2
    , p5_a42 in out nocopy  VARCHAR2
    , p5_a43 in out nocopy  VARCHAR2
    , p5_a44 in out nocopy  VARCHAR2
    , p5_a45 in out nocopy  VARCHAR2
    , p5_a46 in out nocopy  VARCHAR2
    , p5_a47 in out nocopy  VARCHAR2
    , p5_a48 in out nocopy  VARCHAR2
    , p5_a49 in out nocopy  VARCHAR2
    , p5_a50 in out nocopy  VARCHAR2
    , p5_a51 in out nocopy  VARCHAR2
    , p5_a52 in out nocopy  VARCHAR2
    , p5_a53 in out nocopy  VARCHAR2
    , p5_a54 in out nocopy  VARCHAR2
    , p5_a55 in out nocopy  DATE
    , p5_a56 in out nocopy  DATE
    , p5_a57 in out nocopy  DATE
    , p5_a58 in out nocopy  VARCHAR2
    , p5_a59 in out nocopy  VARCHAR2
    , p5_a60 in out nocopy  NUMBER
    , p5_a61 in out nocopy  NUMBER
    , p5_a62 in out nocopy  VARCHAR2
    , p5_a63 in out nocopy  NUMBER
    , p5_a64 in out nocopy  VARCHAR2
    , p5_a65 in out nocopy  VARCHAR2
    , p5_a66 in out nocopy  DATE
    , p5_a67 in out nocopy  DATE
    , p5_a68 in out nocopy  VARCHAR2
    , p5_a69 in out nocopy  VARCHAR2
    , p5_a70 in out nocopy  VARCHAR2
    , p5_a71 in out nocopy  NUMBER
    , p5_a72 in out nocopy  VARCHAR2
    , p5_a73 in out nocopy  NUMBER
    , p5_a74 in out nocopy  VARCHAR2
    , p5_a75 in out nocopy  VARCHAR2
    , p5_a76 in out nocopy  DATE
    , p5_a77 in out nocopy  DATE
    , p5_a78 in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_x_task_rec ahl_vwp_rules_pvt.task_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_x_task_rec.visit_task_id := p5_a0;
    ddp_x_task_rec.visit_task_number := p5_a1;
    ddp_x_task_rec.visit_id := p5_a2;
    ddp_x_task_rec.template_flag := p5_a3;
    ddp_x_task_rec.inventory_item_id := p5_a4;
    ddp_x_task_rec.item_organization_id := p5_a5;
    ddp_x_task_rec.item_name := p5_a6;
    ddp_x_task_rec.cost_parent_id := p5_a7;
    ddp_x_task_rec.cost_parent_number := p5_a8;
    ddp_x_task_rec.mr_route_id := p5_a9;
    ddp_x_task_rec.route_number := p5_a10;
    ddp_x_task_rec.mr_id := p5_a11;
    ddp_x_task_rec.mr_title := p5_a12;
    ddp_x_task_rec.unit_effectivity_id := p5_a13;
    ddp_x_task_rec.department_id := p5_a14;
    ddp_x_task_rec.dept_name := p5_a15;
    ddp_x_task_rec.service_request_id := p5_a16;
    ddp_x_task_rec.service_request_number := p5_a17;
    ddp_x_task_rec.originating_task_id := p5_a18;
    ddp_x_task_rec.orginating_task_number := p5_a19;
    ddp_x_task_rec.instance_id := p5_a20;
    ddp_x_task_rec.serial_number := p5_a21;
    ddp_x_task_rec.project_task_id := p5_a22;
    ddp_x_task_rec.project_task_number := p5_a23;
    ddp_x_task_rec.primary_visit_task_id := p5_a24;
    ddp_x_task_rec.start_from_hour := p5_a25;
    ddp_x_task_rec.duration := p5_a26;
    ddp_x_task_rec.task_type_code := p5_a27;
    ddp_x_task_rec.task_type_value := p5_a28;
    ddp_x_task_rec.visit_task_name := p5_a29;
    ddp_x_task_rec.description := p5_a30;
    ddp_x_task_rec.task_status_code := p5_a31;
    ddp_x_task_rec.task_status_value := p5_a32;
    ddp_x_task_rec.object_version_number := p5_a33;
    ddp_x_task_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a34);
    ddp_x_task_rec.last_updated_by := p5_a35;
    ddp_x_task_rec.creation_date := rosetta_g_miss_date_in_map(p5_a36);
    ddp_x_task_rec.created_by := p5_a37;
    ddp_x_task_rec.last_update_login := p5_a38;
    ddp_x_task_rec.attribute_category := p5_a39;
    ddp_x_task_rec.attribute1 := p5_a40;
    ddp_x_task_rec.attribute2 := p5_a41;
    ddp_x_task_rec.attribute3 := p5_a42;
    ddp_x_task_rec.attribute4 := p5_a43;
    ddp_x_task_rec.attribute5 := p5_a44;
    ddp_x_task_rec.attribute6 := p5_a45;
    ddp_x_task_rec.attribute7 := p5_a46;
    ddp_x_task_rec.attribute8 := p5_a47;
    ddp_x_task_rec.attribute9 := p5_a48;
    ddp_x_task_rec.attribute10 := p5_a49;
    ddp_x_task_rec.attribute11 := p5_a50;
    ddp_x_task_rec.attribute12 := p5_a51;
    ddp_x_task_rec.attribute13 := p5_a52;
    ddp_x_task_rec.attribute14 := p5_a53;
    ddp_x_task_rec.attribute15 := p5_a54;
    ddp_x_task_rec.task_start_date := rosetta_g_miss_date_in_map(p5_a55);
    ddp_x_task_rec.task_end_date := rosetta_g_miss_date_in_map(p5_a56);
    ddp_x_task_rec.due_by_date := rosetta_g_miss_date_in_map(p5_a57);
    ddp_x_task_rec.zone_name := p5_a58;
    ddp_x_task_rec.sub_zone_name := p5_a59;
    ddp_x_task_rec.tolerance_after := p5_a60;
    ddp_x_task_rec.tolerance_before := p5_a61;
    ddp_x_task_rec.tolerance_uom := p5_a62;
    ddp_x_task_rec.workorder_id := p5_a63;
    ddp_x_task_rec.wo_name := p5_a64;
    ddp_x_task_rec.wo_status := p5_a65;
    ddp_x_task_rec.wo_start_date := rosetta_g_miss_date_in_map(p5_a66);
    ddp_x_task_rec.wo_end_date := rosetta_g_miss_date_in_map(p5_a67);
    ddp_x_task_rec.operation_flag := p5_a68;
    ddp_x_task_rec.is_production_flag := p5_a69;
    ddp_x_task_rec.create_job_flag := p5_a70;
    ddp_x_task_rec.stage_id := p5_a71;
    ddp_x_task_rec.stage_name := p5_a72;
    ddp_x_task_rec.quantity := p5_a73;
    ddp_x_task_rec.uom := p5_a74;
    ddp_x_task_rec.instance_number := p5_a75;
    ddp_x_task_rec.past_task_start_date := rosetta_g_miss_date_in_map(p5_a76);
    ddp_x_task_rec.past_task_end_date := rosetta_g_miss_date_in_map(p5_a77);
    ddp_x_task_rec.route_id := p5_a78;




    -- here's the delegated call to the old PL/SQL routine
    ahl_vwp_tasks_pvt.create_task(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_module_type,
      ddp_x_task_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    p5_a0 := ddp_x_task_rec.visit_task_id;
    p5_a1 := ddp_x_task_rec.visit_task_number;
    p5_a2 := ddp_x_task_rec.visit_id;
    p5_a3 := ddp_x_task_rec.template_flag;
    p5_a4 := ddp_x_task_rec.inventory_item_id;
    p5_a5 := ddp_x_task_rec.item_organization_id;
    p5_a6 := ddp_x_task_rec.item_name;
    p5_a7 := ddp_x_task_rec.cost_parent_id;
    p5_a8 := ddp_x_task_rec.cost_parent_number;
    p5_a9 := ddp_x_task_rec.mr_route_id;
    p5_a10 := ddp_x_task_rec.route_number;
    p5_a11 := ddp_x_task_rec.mr_id;
    p5_a12 := ddp_x_task_rec.mr_title;
    p5_a13 := ddp_x_task_rec.unit_effectivity_id;
    p5_a14 := ddp_x_task_rec.department_id;
    p5_a15 := ddp_x_task_rec.dept_name;
    p5_a16 := ddp_x_task_rec.service_request_id;
    p5_a17 := ddp_x_task_rec.service_request_number;
    p5_a18 := ddp_x_task_rec.originating_task_id;
    p5_a19 := ddp_x_task_rec.orginating_task_number;
    p5_a20 := ddp_x_task_rec.instance_id;
    p5_a21 := ddp_x_task_rec.serial_number;
    p5_a22 := ddp_x_task_rec.project_task_id;
    p5_a23 := ddp_x_task_rec.project_task_number;
    p5_a24 := ddp_x_task_rec.primary_visit_task_id;
    p5_a25 := ddp_x_task_rec.start_from_hour;
    p5_a26 := ddp_x_task_rec.duration;
    p5_a27 := ddp_x_task_rec.task_type_code;
    p5_a28 := ddp_x_task_rec.task_type_value;
    p5_a29 := ddp_x_task_rec.visit_task_name;
    p5_a30 := ddp_x_task_rec.description;
    p5_a31 := ddp_x_task_rec.task_status_code;
    p5_a32 := ddp_x_task_rec.task_status_value;
    p5_a33 := ddp_x_task_rec.object_version_number;
    p5_a34 := ddp_x_task_rec.last_update_date;
    p5_a35 := ddp_x_task_rec.last_updated_by;
    p5_a36 := ddp_x_task_rec.creation_date;
    p5_a37 := ddp_x_task_rec.created_by;
    p5_a38 := ddp_x_task_rec.last_update_login;
    p5_a39 := ddp_x_task_rec.attribute_category;
    p5_a40 := ddp_x_task_rec.attribute1;
    p5_a41 := ddp_x_task_rec.attribute2;
    p5_a42 := ddp_x_task_rec.attribute3;
    p5_a43 := ddp_x_task_rec.attribute4;
    p5_a44 := ddp_x_task_rec.attribute5;
    p5_a45 := ddp_x_task_rec.attribute6;
    p5_a46 := ddp_x_task_rec.attribute7;
    p5_a47 := ddp_x_task_rec.attribute8;
    p5_a48 := ddp_x_task_rec.attribute9;
    p5_a49 := ddp_x_task_rec.attribute10;
    p5_a50 := ddp_x_task_rec.attribute11;
    p5_a51 := ddp_x_task_rec.attribute12;
    p5_a52 := ddp_x_task_rec.attribute13;
    p5_a53 := ddp_x_task_rec.attribute14;
    p5_a54 := ddp_x_task_rec.attribute15;
    p5_a55 := ddp_x_task_rec.task_start_date;
    p5_a56 := ddp_x_task_rec.task_end_date;
    p5_a57 := ddp_x_task_rec.due_by_date;
    p5_a58 := ddp_x_task_rec.zone_name;
    p5_a59 := ddp_x_task_rec.sub_zone_name;
    p5_a60 := ddp_x_task_rec.tolerance_after;
    p5_a61 := ddp_x_task_rec.tolerance_before;
    p5_a62 := ddp_x_task_rec.tolerance_uom;
    p5_a63 := ddp_x_task_rec.workorder_id;
    p5_a64 := ddp_x_task_rec.wo_name;
    p5_a65 := ddp_x_task_rec.wo_status;
    p5_a66 := ddp_x_task_rec.wo_start_date;
    p5_a67 := ddp_x_task_rec.wo_end_date;
    p5_a68 := ddp_x_task_rec.operation_flag;
    p5_a69 := ddp_x_task_rec.is_production_flag;
    p5_a70 := ddp_x_task_rec.create_job_flag;
    p5_a71 := ddp_x_task_rec.stage_id;
    p5_a72 := ddp_x_task_rec.stage_name;
    p5_a73 := ddp_x_task_rec.quantity;
    p5_a74 := ddp_x_task_rec.uom;
    p5_a75 := ddp_x_task_rec.instance_number;
    p5_a76 := ddp_x_task_rec.past_task_start_date;
    p5_a77 := ddp_x_task_rec.past_task_end_date;
    p5_a78 := ddp_x_task_rec.route_id;



  end;

  procedure update_task(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , p5_a0 in out nocopy  NUMBER
    , p5_a1 in out nocopy  NUMBER
    , p5_a2 in out nocopy  NUMBER
    , p5_a3 in out nocopy  VARCHAR2
    , p5_a4 in out nocopy  NUMBER
    , p5_a5 in out nocopy  NUMBER
    , p5_a6 in out nocopy  VARCHAR2
    , p5_a7 in out nocopy  NUMBER
    , p5_a8 in out nocopy  NUMBER
    , p5_a9 in out nocopy  NUMBER
    , p5_a10 in out nocopy  VARCHAR2
    , p5_a11 in out nocopy  NUMBER
    , p5_a12 in out nocopy  VARCHAR2
    , p5_a13 in out nocopy  NUMBER
    , p5_a14 in out nocopy  NUMBER
    , p5_a15 in out nocopy  VARCHAR2
    , p5_a16 in out nocopy  NUMBER
    , p5_a17 in out nocopy  VARCHAR2
    , p5_a18 in out nocopy  NUMBER
    , p5_a19 in out nocopy  NUMBER
    , p5_a20 in out nocopy  NUMBER
    , p5_a21 in out nocopy  VARCHAR2
    , p5_a22 in out nocopy  NUMBER
    , p5_a23 in out nocopy  NUMBER
    , p5_a24 in out nocopy  NUMBER
    , p5_a25 in out nocopy  NUMBER
    , p5_a26 in out nocopy  NUMBER
    , p5_a27 in out nocopy  VARCHAR2
    , p5_a28 in out nocopy  VARCHAR2
    , p5_a29 in out nocopy  VARCHAR2
    , p5_a30 in out nocopy  VARCHAR2
    , p5_a31 in out nocopy  VARCHAR2
    , p5_a32 in out nocopy  VARCHAR2
    , p5_a33 in out nocopy  NUMBER
    , p5_a34 in out nocopy  DATE
    , p5_a35 in out nocopy  NUMBER
    , p5_a36 in out nocopy  DATE
    , p5_a37 in out nocopy  NUMBER
    , p5_a38 in out nocopy  NUMBER
    , p5_a39 in out nocopy  VARCHAR2
    , p5_a40 in out nocopy  VARCHAR2
    , p5_a41 in out nocopy  VARCHAR2
    , p5_a42 in out nocopy  VARCHAR2
    , p5_a43 in out nocopy  VARCHAR2
    , p5_a44 in out nocopy  VARCHAR2
    , p5_a45 in out nocopy  VARCHAR2
    , p5_a46 in out nocopy  VARCHAR2
    , p5_a47 in out nocopy  VARCHAR2
    , p5_a48 in out nocopy  VARCHAR2
    , p5_a49 in out nocopy  VARCHAR2
    , p5_a50 in out nocopy  VARCHAR2
    , p5_a51 in out nocopy  VARCHAR2
    , p5_a52 in out nocopy  VARCHAR2
    , p5_a53 in out nocopy  VARCHAR2
    , p5_a54 in out nocopy  VARCHAR2
    , p5_a55 in out nocopy  DATE
    , p5_a56 in out nocopy  DATE
    , p5_a57 in out nocopy  DATE
    , p5_a58 in out nocopy  VARCHAR2
    , p5_a59 in out nocopy  VARCHAR2
    , p5_a60 in out nocopy  NUMBER
    , p5_a61 in out nocopy  NUMBER
    , p5_a62 in out nocopy  VARCHAR2
    , p5_a63 in out nocopy  NUMBER
    , p5_a64 in out nocopy  VARCHAR2
    , p5_a65 in out nocopy  VARCHAR2
    , p5_a66 in out nocopy  DATE
    , p5_a67 in out nocopy  DATE
    , p5_a68 in out nocopy  VARCHAR2
    , p5_a69 in out nocopy  VARCHAR2
    , p5_a70 in out nocopy  VARCHAR2
    , p5_a71 in out nocopy  NUMBER
    , p5_a72 in out nocopy  VARCHAR2
    , p5_a73 in out nocopy  NUMBER
    , p5_a74 in out nocopy  VARCHAR2
    , p5_a75 in out nocopy  VARCHAR2
    , p5_a76 in out nocopy  DATE
    , p5_a77 in out nocopy  DATE
    , p5_a78 in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_x_task_rec ahl_vwp_rules_pvt.task_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_x_task_rec.visit_task_id := p5_a0;
    ddp_x_task_rec.visit_task_number := p5_a1;
    ddp_x_task_rec.visit_id := p5_a2;
    ddp_x_task_rec.template_flag := p5_a3;
    ddp_x_task_rec.inventory_item_id := p5_a4;
    ddp_x_task_rec.item_organization_id := p5_a5;
    ddp_x_task_rec.item_name := p5_a6;
    ddp_x_task_rec.cost_parent_id := p5_a7;
    ddp_x_task_rec.cost_parent_number := p5_a8;
    ddp_x_task_rec.mr_route_id := p5_a9;
    ddp_x_task_rec.route_number := p5_a10;
    ddp_x_task_rec.mr_id := p5_a11;
    ddp_x_task_rec.mr_title := p5_a12;
    ddp_x_task_rec.unit_effectivity_id := p5_a13;
    ddp_x_task_rec.department_id := p5_a14;
    ddp_x_task_rec.dept_name := p5_a15;
    ddp_x_task_rec.service_request_id := p5_a16;
    ddp_x_task_rec.service_request_number := p5_a17;
    ddp_x_task_rec.originating_task_id := p5_a18;
    ddp_x_task_rec.orginating_task_number := p5_a19;
    ddp_x_task_rec.instance_id := p5_a20;
    ddp_x_task_rec.serial_number := p5_a21;
    ddp_x_task_rec.project_task_id := p5_a22;
    ddp_x_task_rec.project_task_number := p5_a23;
    ddp_x_task_rec.primary_visit_task_id := p5_a24;
    ddp_x_task_rec.start_from_hour := p5_a25;
    ddp_x_task_rec.duration := p5_a26;
    ddp_x_task_rec.task_type_code := p5_a27;
    ddp_x_task_rec.task_type_value := p5_a28;
    ddp_x_task_rec.visit_task_name := p5_a29;
    ddp_x_task_rec.description := p5_a30;
    ddp_x_task_rec.task_status_code := p5_a31;
    ddp_x_task_rec.task_status_value := p5_a32;
    ddp_x_task_rec.object_version_number := p5_a33;
    ddp_x_task_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a34);
    ddp_x_task_rec.last_updated_by := p5_a35;
    ddp_x_task_rec.creation_date := rosetta_g_miss_date_in_map(p5_a36);
    ddp_x_task_rec.created_by := p5_a37;
    ddp_x_task_rec.last_update_login := p5_a38;
    ddp_x_task_rec.attribute_category := p5_a39;
    ddp_x_task_rec.attribute1 := p5_a40;
    ddp_x_task_rec.attribute2 := p5_a41;
    ddp_x_task_rec.attribute3 := p5_a42;
    ddp_x_task_rec.attribute4 := p5_a43;
    ddp_x_task_rec.attribute5 := p5_a44;
    ddp_x_task_rec.attribute6 := p5_a45;
    ddp_x_task_rec.attribute7 := p5_a46;
    ddp_x_task_rec.attribute8 := p5_a47;
    ddp_x_task_rec.attribute9 := p5_a48;
    ddp_x_task_rec.attribute10 := p5_a49;
    ddp_x_task_rec.attribute11 := p5_a50;
    ddp_x_task_rec.attribute12 := p5_a51;
    ddp_x_task_rec.attribute13 := p5_a52;
    ddp_x_task_rec.attribute14 := p5_a53;
    ddp_x_task_rec.attribute15 := p5_a54;
    ddp_x_task_rec.task_start_date := rosetta_g_miss_date_in_map(p5_a55);
    ddp_x_task_rec.task_end_date := rosetta_g_miss_date_in_map(p5_a56);
    ddp_x_task_rec.due_by_date := rosetta_g_miss_date_in_map(p5_a57);
    ddp_x_task_rec.zone_name := p5_a58;
    ddp_x_task_rec.sub_zone_name := p5_a59;
    ddp_x_task_rec.tolerance_after := p5_a60;
    ddp_x_task_rec.tolerance_before := p5_a61;
    ddp_x_task_rec.tolerance_uom := p5_a62;
    ddp_x_task_rec.workorder_id := p5_a63;
    ddp_x_task_rec.wo_name := p5_a64;
    ddp_x_task_rec.wo_status := p5_a65;
    ddp_x_task_rec.wo_start_date := rosetta_g_miss_date_in_map(p5_a66);
    ddp_x_task_rec.wo_end_date := rosetta_g_miss_date_in_map(p5_a67);
    ddp_x_task_rec.operation_flag := p5_a68;
    ddp_x_task_rec.is_production_flag := p5_a69;
    ddp_x_task_rec.create_job_flag := p5_a70;
    ddp_x_task_rec.stage_id := p5_a71;
    ddp_x_task_rec.stage_name := p5_a72;
    ddp_x_task_rec.quantity := p5_a73;
    ddp_x_task_rec.uom := p5_a74;
    ddp_x_task_rec.instance_number := p5_a75;
    ddp_x_task_rec.past_task_start_date := rosetta_g_miss_date_in_map(p5_a76);
    ddp_x_task_rec.past_task_end_date := rosetta_g_miss_date_in_map(p5_a77);
    ddp_x_task_rec.route_id := p5_a78;




    -- here's the delegated call to the old PL/SQL routine
    ahl_vwp_tasks_pvt.update_task(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_module_type,
      ddp_x_task_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    p5_a0 := ddp_x_task_rec.visit_task_id;
    p5_a1 := ddp_x_task_rec.visit_task_number;
    p5_a2 := ddp_x_task_rec.visit_id;
    p5_a3 := ddp_x_task_rec.template_flag;
    p5_a4 := ddp_x_task_rec.inventory_item_id;
    p5_a5 := ddp_x_task_rec.item_organization_id;
    p5_a6 := ddp_x_task_rec.item_name;
    p5_a7 := ddp_x_task_rec.cost_parent_id;
    p5_a8 := ddp_x_task_rec.cost_parent_number;
    p5_a9 := ddp_x_task_rec.mr_route_id;
    p5_a10 := ddp_x_task_rec.route_number;
    p5_a11 := ddp_x_task_rec.mr_id;
    p5_a12 := ddp_x_task_rec.mr_title;
    p5_a13 := ddp_x_task_rec.unit_effectivity_id;
    p5_a14 := ddp_x_task_rec.department_id;
    p5_a15 := ddp_x_task_rec.dept_name;
    p5_a16 := ddp_x_task_rec.service_request_id;
    p5_a17 := ddp_x_task_rec.service_request_number;
    p5_a18 := ddp_x_task_rec.originating_task_id;
    p5_a19 := ddp_x_task_rec.orginating_task_number;
    p5_a20 := ddp_x_task_rec.instance_id;
    p5_a21 := ddp_x_task_rec.serial_number;
    p5_a22 := ddp_x_task_rec.project_task_id;
    p5_a23 := ddp_x_task_rec.project_task_number;
    p5_a24 := ddp_x_task_rec.primary_visit_task_id;
    p5_a25 := ddp_x_task_rec.start_from_hour;
    p5_a26 := ddp_x_task_rec.duration;
    p5_a27 := ddp_x_task_rec.task_type_code;
    p5_a28 := ddp_x_task_rec.task_type_value;
    p5_a29 := ddp_x_task_rec.visit_task_name;
    p5_a30 := ddp_x_task_rec.description;
    p5_a31 := ddp_x_task_rec.task_status_code;
    p5_a32 := ddp_x_task_rec.task_status_value;
    p5_a33 := ddp_x_task_rec.object_version_number;
    p5_a34 := ddp_x_task_rec.last_update_date;
    p5_a35 := ddp_x_task_rec.last_updated_by;
    p5_a36 := ddp_x_task_rec.creation_date;
    p5_a37 := ddp_x_task_rec.created_by;
    p5_a38 := ddp_x_task_rec.last_update_login;
    p5_a39 := ddp_x_task_rec.attribute_category;
    p5_a40 := ddp_x_task_rec.attribute1;
    p5_a41 := ddp_x_task_rec.attribute2;
    p5_a42 := ddp_x_task_rec.attribute3;
    p5_a43 := ddp_x_task_rec.attribute4;
    p5_a44 := ddp_x_task_rec.attribute5;
    p5_a45 := ddp_x_task_rec.attribute6;
    p5_a46 := ddp_x_task_rec.attribute7;
    p5_a47 := ddp_x_task_rec.attribute8;
    p5_a48 := ddp_x_task_rec.attribute9;
    p5_a49 := ddp_x_task_rec.attribute10;
    p5_a50 := ddp_x_task_rec.attribute11;
    p5_a51 := ddp_x_task_rec.attribute12;
    p5_a52 := ddp_x_task_rec.attribute13;
    p5_a53 := ddp_x_task_rec.attribute14;
    p5_a54 := ddp_x_task_rec.attribute15;
    p5_a55 := ddp_x_task_rec.task_start_date;
    p5_a56 := ddp_x_task_rec.task_end_date;
    p5_a57 := ddp_x_task_rec.due_by_date;
    p5_a58 := ddp_x_task_rec.zone_name;
    p5_a59 := ddp_x_task_rec.sub_zone_name;
    p5_a60 := ddp_x_task_rec.tolerance_after;
    p5_a61 := ddp_x_task_rec.tolerance_before;
    p5_a62 := ddp_x_task_rec.tolerance_uom;
    p5_a63 := ddp_x_task_rec.workorder_id;
    p5_a64 := ddp_x_task_rec.wo_name;
    p5_a65 := ddp_x_task_rec.wo_status;
    p5_a66 := ddp_x_task_rec.wo_start_date;
    p5_a67 := ddp_x_task_rec.wo_end_date;
    p5_a68 := ddp_x_task_rec.operation_flag;
    p5_a69 := ddp_x_task_rec.is_production_flag;
    p5_a70 := ddp_x_task_rec.create_job_flag;
    p5_a71 := ddp_x_task_rec.stage_id;
    p5_a72 := ddp_x_task_rec.stage_name;
    p5_a73 := ddp_x_task_rec.quantity;
    p5_a74 := ddp_x_task_rec.uom;
    p5_a75 := ddp_x_task_rec.instance_number;
    p5_a76 := ddp_x_task_rec.past_task_start_date;
    p5_a77 := ddp_x_task_rec.past_task_end_date;
    p5_a78 := ddp_x_task_rec.route_id;



  end;

  procedure search_task(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , p_visit_id  NUMBER
    , p6_a0 in out nocopy JTF_NUMBER_TABLE
    , p6_a1 in out nocopy JTF_DATE_TABLE
    , p6_a2 in out nocopy JTF_DATE_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_x_srch_task_tbl ahl_vwp_tasks_pvt.srch_task_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ahl_vwp_tasks_pvt_w.rosetta_table_copy_in_p1(ddp_x_srch_task_tbl, p6_a0
      , p6_a1
      , p6_a2
      );




    -- here's the delegated call to the old PL/SQL routine
    ahl_vwp_tasks_pvt.search_task(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_module_type,
      p_visit_id,
      ddp_x_srch_task_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    ahl_vwp_tasks_pvt_w.rosetta_table_copy_out_p1(ddp_x_srch_task_tbl, p6_a0
      , p6_a1
      , p6_a2
      );



  end;

  procedure create_pup_tasks(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , p5_a0 in out nocopy JTF_NUMBER_TABLE
    , p5_a1 in out nocopy JTF_NUMBER_TABLE
    , p5_a2 in out nocopy JTF_NUMBER_TABLE
    , p5_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a4 in out nocopy JTF_NUMBER_TABLE
    , p5_a5 in out nocopy JTF_NUMBER_TABLE
    , p5_a6 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a7 in out nocopy JTF_NUMBER_TABLE
    , p5_a8 in out nocopy JTF_NUMBER_TABLE
    , p5_a9 in out nocopy JTF_NUMBER_TABLE
    , p5_a10 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a11 in out nocopy JTF_NUMBER_TABLE
    , p5_a12 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a13 in out nocopy JTF_NUMBER_TABLE
    , p5_a14 in out nocopy JTF_NUMBER_TABLE
    , p5_a15 in out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a16 in out nocopy JTF_NUMBER_TABLE
    , p5_a17 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a18 in out nocopy JTF_NUMBER_TABLE
    , p5_a19 in out nocopy JTF_NUMBER_TABLE
    , p5_a20 in out nocopy JTF_NUMBER_TABLE
    , p5_a21 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a22 in out nocopy JTF_NUMBER_TABLE
    , p5_a23 in out nocopy JTF_NUMBER_TABLE
    , p5_a24 in out nocopy JTF_NUMBER_TABLE
    , p5_a25 in out nocopy JTF_NUMBER_TABLE
    , p5_a26 in out nocopy JTF_NUMBER_TABLE
    , p5_a27 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a28 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a29 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a30 in out nocopy JTF_VARCHAR2_TABLE_4000
    , p5_a31 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a32 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a33 in out nocopy JTF_NUMBER_TABLE
    , p5_a34 in out nocopy JTF_DATE_TABLE
    , p5_a35 in out nocopy JTF_NUMBER_TABLE
    , p5_a36 in out nocopy JTF_DATE_TABLE
    , p5_a37 in out nocopy JTF_NUMBER_TABLE
    , p5_a38 in out nocopy JTF_NUMBER_TABLE
    , p5_a39 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a40 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a41 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a42 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a43 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a44 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a45 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a46 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a47 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a48 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a49 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a50 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a51 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a52 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a53 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a54 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a55 in out nocopy JTF_DATE_TABLE
    , p5_a56 in out nocopy JTF_DATE_TABLE
    , p5_a57 in out nocopy JTF_DATE_TABLE
    , p5_a58 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a59 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a60 in out nocopy JTF_NUMBER_TABLE
    , p5_a61 in out nocopy JTF_NUMBER_TABLE
    , p5_a62 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a63 in out nocopy JTF_NUMBER_TABLE
    , p5_a64 in out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a65 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a66 in out nocopy JTF_DATE_TABLE
    , p5_a67 in out nocopy JTF_DATE_TABLE
    , p5_a68 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a69 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a70 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a71 in out nocopy JTF_NUMBER_TABLE
    , p5_a72 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a73 in out nocopy JTF_NUMBER_TABLE
    , p5_a74 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a75 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a76 in out nocopy JTF_DATE_TABLE
    , p5_a77 in out nocopy JTF_DATE_TABLE
    , p5_a78 in out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_x_task_tbl ahl_vwp_rules_pvt.task_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ahl_vwp_rules_pvt_w.rosetta_table_copy_in_p5(ddp_x_task_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      , p5_a10
      , p5_a11
      , p5_a12
      , p5_a13
      , p5_a14
      , p5_a15
      , p5_a16
      , p5_a17
      , p5_a18
      , p5_a19
      , p5_a20
      , p5_a21
      , p5_a22
      , p5_a23
      , p5_a24
      , p5_a25
      , p5_a26
      , p5_a27
      , p5_a28
      , p5_a29
      , p5_a30
      , p5_a31
      , p5_a32
      , p5_a33
      , p5_a34
      , p5_a35
      , p5_a36
      , p5_a37
      , p5_a38
      , p5_a39
      , p5_a40
      , p5_a41
      , p5_a42
      , p5_a43
      , p5_a44
      , p5_a45
      , p5_a46
      , p5_a47
      , p5_a48
      , p5_a49
      , p5_a50
      , p5_a51
      , p5_a52
      , p5_a53
      , p5_a54
      , p5_a55
      , p5_a56
      , p5_a57
      , p5_a58
      , p5_a59
      , p5_a60
      , p5_a61
      , p5_a62
      , p5_a63
      , p5_a64
      , p5_a65
      , p5_a66
      , p5_a67
      , p5_a68
      , p5_a69
      , p5_a70
      , p5_a71
      , p5_a72
      , p5_a73
      , p5_a74
      , p5_a75
      , p5_a76
      , p5_a77
      , p5_a78
      );




    -- here's the delegated call to the old PL/SQL routine
    ahl_vwp_tasks_pvt.create_pup_tasks(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_module_type,
      ddp_x_task_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    ahl_vwp_rules_pvt_w.rosetta_table_copy_out_p5(ddp_x_task_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      , p5_a10
      , p5_a11
      , p5_a12
      , p5_a13
      , p5_a14
      , p5_a15
      , p5_a16
      , p5_a17
      , p5_a18
      , p5_a19
      , p5_a20
      , p5_a21
      , p5_a22
      , p5_a23
      , p5_a24
      , p5_a25
      , p5_a26
      , p5_a27
      , p5_a28
      , p5_a29
      , p5_a30
      , p5_a31
      , p5_a32
      , p5_a33
      , p5_a34
      , p5_a35
      , p5_a36
      , p5_a37
      , p5_a38
      , p5_a39
      , p5_a40
      , p5_a41
      , p5_a42
      , p5_a43
      , p5_a44
      , p5_a45
      , p5_a46
      , p5_a47
      , p5_a48
      , p5_a49
      , p5_a50
      , p5_a51
      , p5_a52
      , p5_a53
      , p5_a54
      , p5_a55
      , p5_a56
      , p5_a57
      , p5_a58
      , p5_a59
      , p5_a60
      , p5_a61
      , p5_a62
      , p5_a63
      , p5_a64
      , p5_a65
      , p5_a66
      , p5_a67
      , p5_a68
      , p5_a69
      , p5_a70
      , p5_a71
      , p5_a72
      , p5_a73
      , p5_a74
      , p5_a75
      , p5_a76
      , p5_a77
      , p5_a78
      );



  end;

  procedure associate_default_mrs(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p8_a0  NUMBER
    , p8_a1  VARCHAR2
    , p8_a2  NUMBER
    , p8_a3  NUMBER
    , p8_a4  DATE
    , p8_a5  NUMBER
    , p8_a6  DATE
    , p8_a7  NUMBER
    , p8_a8  NUMBER
    , p8_a9  NUMBER
    , p8_a10  VARCHAR2
    , p8_a11  NUMBER
    , p8_a12  VARCHAR2
    , p8_a13  NUMBER
    , p8_a14  VARCHAR2
    , p8_a15  VARCHAR2
    , p8_a16  VARCHAR2
    , p8_a17  DATE
    , p8_a18  NUMBER
    , p8_a19  NUMBER
    , p8_a20  DATE
    , p8_a21  NUMBER
    , p8_a22  NUMBER
    , p8_a23  DATE
    , p8_a24  DATE
    , p8_a25  VARCHAR2
    , p8_a26  VARCHAR2
    , p8_a27  VARCHAR2
    , p8_a28  VARCHAR2
    , p8_a29  NUMBER
    , p8_a30  VARCHAR2
    , p8_a31  NUMBER
    , p8_a32  VARCHAR2
    , p8_a33  NUMBER
    , p8_a34  VARCHAR2
    , p8_a35  NUMBER
    , p8_a36  NUMBER
    , p8_a37  VARCHAR2
    , p8_a38  VARCHAR2
    , p8_a39  VARCHAR2
    , p8_a40  VARCHAR2
    , p8_a41  VARCHAR2
    , p8_a42  VARCHAR2
    , p8_a43  NUMBER
    , p8_a44  NUMBER
    , p8_a45  VARCHAR2
    , p8_a46  NUMBER
    , p8_a47  VARCHAR2
    , p8_a48  VARCHAR2
    , p8_a49  VARCHAR2
    , p8_a50  VARCHAR2
    , p8_a51  VARCHAR2
    , p8_a52  VARCHAR2
    , p8_a53  VARCHAR2
    , p8_a54  VARCHAR2
    , p8_a55  VARCHAR2
    , p8_a56  VARCHAR2
    , p8_a57  VARCHAR2
    , p8_a58  VARCHAR2
    , p8_a59  VARCHAR2
    , p8_a60  VARCHAR2
    , p8_a61  VARCHAR2
    , p8_a62  VARCHAR2
    , p8_a63  VARCHAR2
    , p8_a64  VARCHAR2
    , p8_a65  VARCHAR2
    , p8_a66  VARCHAR2
    , p8_a67  NUMBER
    , p8_a68  VARCHAR2
    , p8_a69  VARCHAR2
    , p8_a70  NUMBER
    , p8_a71  VARCHAR2
    , p8_a72  VARCHAR2
    , p8_a73  NUMBER
    , p8_a74  VARCHAR2
    , p8_a75  VARCHAR2
    , p8_a76  VARCHAR2
    , p8_a77  NUMBER
    , p8_a78  NUMBER
    , p8_a79  VARCHAR2
    , p8_a80  VARCHAR2
    , p8_a81  DATE
  )

  as
    ddp_visit_rec ahl_vwp_visits_pvt.visit_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_visit_rec.visit_id := p8_a0;
    ddp_visit_rec.visit_name := p8_a1;
    ddp_visit_rec.visit_number := p8_a2;
    ddp_visit_rec.object_version_number := p8_a3;
    ddp_visit_rec.last_update_date := rosetta_g_miss_date_in_map(p8_a4);
    ddp_visit_rec.last_updated_by := p8_a5;
    ddp_visit_rec.creation_date := rosetta_g_miss_date_in_map(p8_a6);
    ddp_visit_rec.created_by := p8_a7;
    ddp_visit_rec.last_update_login := p8_a8;
    ddp_visit_rec.organization_id := p8_a9;
    ddp_visit_rec.org_name := p8_a10;
    ddp_visit_rec.department_id := p8_a11;
    ddp_visit_rec.dept_name := p8_a12;
    ddp_visit_rec.service_request_id := p8_a13;
    ddp_visit_rec.service_request_number := p8_a14;
    ddp_visit_rec.space_category_code := p8_a15;
    ddp_visit_rec.space_category_name := p8_a16;
    ddp_visit_rec.start_date := rosetta_g_miss_date_in_map(p8_a17);
    ddp_visit_rec.start_hour := p8_a18;
    ddp_visit_rec.start_min := p8_a19;
    ddp_visit_rec.plan_end_date := rosetta_g_miss_date_in_map(p8_a20);
    ddp_visit_rec.plan_end_hour := p8_a21;
    ddp_visit_rec.plan_end_min := p8_a22;
    ddp_visit_rec.end_date := rosetta_g_miss_date_in_map(p8_a23);
    ddp_visit_rec.due_by_date := rosetta_g_miss_date_in_map(p8_a24);
    ddp_visit_rec.visit_type_code := p8_a25;
    ddp_visit_rec.visit_type_name := p8_a26;
    ddp_visit_rec.status_code := p8_a27;
    ddp_visit_rec.status_name := p8_a28;
    ddp_visit_rec.simulation_plan_id := p8_a29;
    ddp_visit_rec.simulation_plan_name := p8_a30;
    ddp_visit_rec.asso_primary_visit_id := p8_a31;
    ddp_visit_rec.unit_name := p8_a32;
    ddp_visit_rec.item_instance_id := p8_a33;
    ddp_visit_rec.serial_number := p8_a34;
    ddp_visit_rec.inventory_item_id := p8_a35;
    ddp_visit_rec.item_organization_id := p8_a36;
    ddp_visit_rec.item_name := p8_a37;
    ddp_visit_rec.simulation_delete_flag := p8_a38;
    ddp_visit_rec.template_flag := p8_a39;
    ddp_visit_rec.out_of_sync_flag := p8_a40;
    ddp_visit_rec.project_flag := p8_a41;
    ddp_visit_rec.project_flag_code := p8_a42;
    ddp_visit_rec.project_id := p8_a43;
    ddp_visit_rec.project_number := p8_a44;
    ddp_visit_rec.description := p8_a45;
    ddp_visit_rec.duration := p8_a46;
    ddp_visit_rec.attribute_category := p8_a47;
    ddp_visit_rec.attribute1 := p8_a48;
    ddp_visit_rec.attribute2 := p8_a49;
    ddp_visit_rec.attribute3 := p8_a50;
    ddp_visit_rec.attribute4 := p8_a51;
    ddp_visit_rec.attribute5 := p8_a52;
    ddp_visit_rec.attribute6 := p8_a53;
    ddp_visit_rec.attribute7 := p8_a54;
    ddp_visit_rec.attribute8 := p8_a55;
    ddp_visit_rec.attribute9 := p8_a56;
    ddp_visit_rec.attribute10 := p8_a57;
    ddp_visit_rec.attribute11 := p8_a58;
    ddp_visit_rec.attribute12 := p8_a59;
    ddp_visit_rec.attribute13 := p8_a60;
    ddp_visit_rec.attribute14 := p8_a61;
    ddp_visit_rec.attribute15 := p8_a62;
    ddp_visit_rec.operation_flag := p8_a63;
    ddp_visit_rec.outside_party_flag := p8_a64;
    ddp_visit_rec.job_number := p8_a65;
    ddp_visit_rec.proj_template_name := p8_a66;
    ddp_visit_rec.proj_template_id := p8_a67;
    ddp_visit_rec.priority_value := p8_a68;
    ddp_visit_rec.priority_code := p8_a69;
    ddp_visit_rec.unit_schedule_id := p8_a70;
    ddp_visit_rec.visit_create_type := p8_a71;
    ddp_visit_rec.visit_create_meaning := p8_a72;
    ddp_visit_rec.unit_header_id := p8_a73;
    ddp_visit_rec.flight_number := p8_a74;
    ddp_visit_rec.subinventory := p8_a75;
    ddp_visit_rec.locator_segment := p8_a76;
    ddp_visit_rec.inv_locator_id := p8_a77;
    ddp_visit_rec.cp_request_id := p8_a78;
    ddp_visit_rec.cp_phase_code := p8_a79;
    ddp_visit_rec.cp_status_code := p8_a80;
    ddp_visit_rec.cp_request_date := rosetta_g_miss_date_in_map(p8_a81);

    -- here's the delegated call to the old PL/SQL routine
    ahl_vwp_tasks_pvt.associate_default_mrs(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_module_type,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_visit_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

end ahl_vwp_tasks_pvt_w;

/
