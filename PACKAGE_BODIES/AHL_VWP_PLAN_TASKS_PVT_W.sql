--------------------------------------------------------
--  DDL for Package Body AHL_VWP_PLAN_TASKS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_VWP_PLAN_TASKS_PVT_W" as
  /* $Header: AHLWPLNB.pls 115.1 2003/08/21 18:38:41 shbhanda noship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure create_planned_task(p_api_version  NUMBER
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




    -- here's the delegated call to the old PL/SQL routine
    ahl_vwp_plan_tasks_pvt.create_planned_task(p_api_version,
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



  end;

  procedure update_planned_task(p_api_version  NUMBER
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




    -- here's the delegated call to the old PL/SQL routine
    ahl_vwp_plan_tasks_pvt.update_planned_task(p_api_version,
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



  end;

end ahl_vwp_plan_tasks_pvt_w;

/
