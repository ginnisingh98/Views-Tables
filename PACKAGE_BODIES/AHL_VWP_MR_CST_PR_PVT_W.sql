--------------------------------------------------------
--  DDL for Package Body AHL_VWP_MR_CST_PR_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_VWP_MR_CST_PR_PVT_W" as
  /* $Header: AHLWMCPB.pls 120.1 2006/05/04 06:21 anraj noship $ */
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

  procedure estimate_mr_cost(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , p5_a0 in out nocopy  NUMBER
    , p5_a1 in out nocopy  NUMBER
    , p5_a2 in out nocopy  NUMBER
    , p5_a3 in out nocopy  NUMBER
    , p5_a4 in out nocopy  NUMBER
    , p5_a5 in out nocopy  NUMBER
    , p5_a6 in out nocopy  NUMBER
    , p5_a7 in out nocopy  VARCHAR2
    , p5_a8 in out nocopy  NUMBER
    , p5_a9 in out nocopy  NUMBER
    , p5_a10 in out nocopy  NUMBER
    , p5_a11 in out nocopy  NUMBER
    , p5_a12 in out nocopy  VARCHAR2
    , p5_a13 in out nocopy  VARCHAR2
    , p5_a14 in out nocopy  VARCHAR2
    , p5_a15 in out nocopy  VARCHAR2
    , p5_a16 in out nocopy  NUMBER
    , p5_a17 in out nocopy  VARCHAR2
    , p5_a18 in out nocopy  NUMBER
    , p5_a19 in out nocopy  NUMBER
    , p5_a20 in out nocopy  NUMBER
    , p5_a21 in out nocopy  DATE
    , p5_a22 in out nocopy  DATE
    , p5_a23 in out nocopy  DATE
    , p5_a24 in out nocopy  DATE
    , p5_a25 in out nocopy  DATE
    , p5_a26 in out nocopy  DATE
    , p5_a27 in out nocopy  VARCHAR2
    , p5_a28 in out nocopy  NUMBER
    , p5_a29 in out nocopy  VARCHAR2
    , p5_a30 in out nocopy  VARCHAR2
    , p5_a31 in out nocopy  NUMBER
    , p5_a32 in out nocopy  VARCHAR2
    , p5_a33 in out nocopy  VARCHAR2
    , p5_a34 in out nocopy  VARCHAR2
    , p5_a35 in out nocopy  NUMBER
    , p5_a36 in out nocopy  VARCHAR2
    , p5_a37 in out nocopy  NUMBER
    , p5_a38 in out nocopy  NUMBER
    , p5_a39 in out nocopy  NUMBER
    , p5_a40 in out nocopy  DATE
    , p5_a41 in out nocopy  NUMBER
    , p5_a42 in out nocopy  DATE
    , p5_a43 in out nocopy  NUMBER
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
    , p5_a55 in out nocopy  VARCHAR2
    , p5_a56 in out nocopy  VARCHAR2
    , p5_a57 in out nocopy  VARCHAR2
    , p5_a58 in out nocopy  VARCHAR2
    , p5_a59 in out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_x_cost_price_rec ahl_vwp_visit_cst_pr_pvt.cost_price_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_x_cost_price_rec.visit_task_id := p5_a0;
    ddp_x_cost_price_rec.visit_id := p5_a1;
    ddp_x_cost_price_rec.mr_id := p5_a2;
    ddp_x_cost_price_rec.actual_cost := p5_a3;
    ddp_x_cost_price_rec.estimated_cost := p5_a4;
    ddp_x_cost_price_rec.actual_price := p5_a5;
    ddp_x_cost_price_rec.estimated_price := p5_a6;
    ddp_x_cost_price_rec.currency := p5_a7;
    ddp_x_cost_price_rec.snapshot_id := p5_a8;
    ddp_x_cost_price_rec.object_version_number := p5_a9;
    ddp_x_cost_price_rec.estimated_profit := p5_a10;
    ddp_x_cost_price_rec.actual_profit := p5_a11;
    ddp_x_cost_price_rec.outside_party_flag := p5_a12;
    ddp_x_cost_price_rec.is_outside_pty_flag_updt := p5_a13;
    ddp_x_cost_price_rec.is_cst_pr_info_required := p5_a14;
    ddp_x_cost_price_rec.is_cst_struc_updated := p5_a15;
    ddp_x_cost_price_rec.price_list_id := p5_a16;
    ddp_x_cost_price_rec.price_list_name := p5_a17;
    ddp_x_cost_price_rec.service_request_id := p5_a18;
    ddp_x_cost_price_rec.customer_id := p5_a19;
    ddp_x_cost_price_rec.organization_id := p5_a20;
    ddp_x_cost_price_rec.visit_start_date := rosetta_g_miss_date_in_map(p5_a21);
    ddp_x_cost_price_rec.visit_end_date := rosetta_g_miss_date_in_map(p5_a22);
    ddp_x_cost_price_rec.mr_start_date := rosetta_g_miss_date_in_map(p5_a23);
    ddp_x_cost_price_rec.mr_end_date := rosetta_g_miss_date_in_map(p5_a24);
    ddp_x_cost_price_rec.task_start_date := rosetta_g_miss_date_in_map(p5_a25);
    ddp_x_cost_price_rec.task_end_date := rosetta_g_miss_date_in_map(p5_a26);
    ddp_x_cost_price_rec.task_name := p5_a27;
    ddp_x_cost_price_rec.visit_task_number := p5_a28;
    ddp_x_cost_price_rec.mr_title := p5_a29;
    ddp_x_cost_price_rec.mr_description := p5_a30;
    ddp_x_cost_price_rec.billing_item_id := p5_a31;
    ddp_x_cost_price_rec.item_name := p5_a32;
    ddp_x_cost_price_rec.item_description := p5_a33;
    ddp_x_cost_price_rec.organization_name := p5_a34;
    ddp_x_cost_price_rec.workorder_id := p5_a35;
    ddp_x_cost_price_rec.master_wo_flag := p5_a36;
    ddp_x_cost_price_rec.mr_session_id := p5_a37;
    ddp_x_cost_price_rec.cost_session_id := p5_a38;
    ddp_x_cost_price_rec.created_by := p5_a39;
    ddp_x_cost_price_rec.creation_date := rosetta_g_miss_date_in_map(p5_a40);
    ddp_x_cost_price_rec.last_updated_by := p5_a41;
    ddp_x_cost_price_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a42);
    ddp_x_cost_price_rec.last_update_login := p5_a43;
    ddp_x_cost_price_rec.attribute_category := p5_a44;
    ddp_x_cost_price_rec.attribute1 := p5_a45;
    ddp_x_cost_price_rec.attribute2 := p5_a46;
    ddp_x_cost_price_rec.attribute3 := p5_a47;
    ddp_x_cost_price_rec.attribute4 := p5_a48;
    ddp_x_cost_price_rec.attribute5 := p5_a49;
    ddp_x_cost_price_rec.attribute6 := p5_a50;
    ddp_x_cost_price_rec.attribute7 := p5_a51;
    ddp_x_cost_price_rec.attribute8 := p5_a52;
    ddp_x_cost_price_rec.attribute9 := p5_a53;
    ddp_x_cost_price_rec.attribute10 := p5_a54;
    ddp_x_cost_price_rec.attribute11 := p5_a55;
    ddp_x_cost_price_rec.attribute12 := p5_a56;
    ddp_x_cost_price_rec.attribute13 := p5_a57;
    ddp_x_cost_price_rec.attribute14 := p5_a58;
    ddp_x_cost_price_rec.attribute15 := p5_a59;




    -- here's the delegated call to the old PL/SQL routine
    ahl_vwp_mr_cst_pr_pvt.estimate_mr_cost(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_module_type,
      ddp_x_cost_price_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    p5_a0 := ddp_x_cost_price_rec.visit_task_id;
    p5_a1 := ddp_x_cost_price_rec.visit_id;
    p5_a2 := ddp_x_cost_price_rec.mr_id;
    p5_a3 := ddp_x_cost_price_rec.actual_cost;
    p5_a4 := ddp_x_cost_price_rec.estimated_cost;
    p5_a5 := ddp_x_cost_price_rec.actual_price;
    p5_a6 := ddp_x_cost_price_rec.estimated_price;
    p5_a7 := ddp_x_cost_price_rec.currency;
    p5_a8 := ddp_x_cost_price_rec.snapshot_id;
    p5_a9 := ddp_x_cost_price_rec.object_version_number;
    p5_a10 := ddp_x_cost_price_rec.estimated_profit;
    p5_a11 := ddp_x_cost_price_rec.actual_profit;
    p5_a12 := ddp_x_cost_price_rec.outside_party_flag;
    p5_a13 := ddp_x_cost_price_rec.is_outside_pty_flag_updt;
    p5_a14 := ddp_x_cost_price_rec.is_cst_pr_info_required;
    p5_a15 := ddp_x_cost_price_rec.is_cst_struc_updated;
    p5_a16 := ddp_x_cost_price_rec.price_list_id;
    p5_a17 := ddp_x_cost_price_rec.price_list_name;
    p5_a18 := ddp_x_cost_price_rec.service_request_id;
    p5_a19 := ddp_x_cost_price_rec.customer_id;
    p5_a20 := ddp_x_cost_price_rec.organization_id;
    p5_a21 := ddp_x_cost_price_rec.visit_start_date;
    p5_a22 := ddp_x_cost_price_rec.visit_end_date;
    p5_a23 := ddp_x_cost_price_rec.mr_start_date;
    p5_a24 := ddp_x_cost_price_rec.mr_end_date;
    p5_a25 := ddp_x_cost_price_rec.task_start_date;
    p5_a26 := ddp_x_cost_price_rec.task_end_date;
    p5_a27 := ddp_x_cost_price_rec.task_name;
    p5_a28 := ddp_x_cost_price_rec.visit_task_number;
    p5_a29 := ddp_x_cost_price_rec.mr_title;
    p5_a30 := ddp_x_cost_price_rec.mr_description;
    p5_a31 := ddp_x_cost_price_rec.billing_item_id;
    p5_a32 := ddp_x_cost_price_rec.item_name;
    p5_a33 := ddp_x_cost_price_rec.item_description;
    p5_a34 := ddp_x_cost_price_rec.organization_name;
    p5_a35 := ddp_x_cost_price_rec.workorder_id;
    p5_a36 := ddp_x_cost_price_rec.master_wo_flag;
    p5_a37 := ddp_x_cost_price_rec.mr_session_id;
    p5_a38 := ddp_x_cost_price_rec.cost_session_id;
    p5_a39 := ddp_x_cost_price_rec.created_by;
    p5_a40 := ddp_x_cost_price_rec.creation_date;
    p5_a41 := ddp_x_cost_price_rec.last_updated_by;
    p5_a42 := ddp_x_cost_price_rec.last_update_date;
    p5_a43 := ddp_x_cost_price_rec.last_update_login;
    p5_a44 := ddp_x_cost_price_rec.attribute_category;
    p5_a45 := ddp_x_cost_price_rec.attribute1;
    p5_a46 := ddp_x_cost_price_rec.attribute2;
    p5_a47 := ddp_x_cost_price_rec.attribute3;
    p5_a48 := ddp_x_cost_price_rec.attribute4;
    p5_a49 := ddp_x_cost_price_rec.attribute5;
    p5_a50 := ddp_x_cost_price_rec.attribute6;
    p5_a51 := ddp_x_cost_price_rec.attribute7;
    p5_a52 := ddp_x_cost_price_rec.attribute8;
    p5_a53 := ddp_x_cost_price_rec.attribute9;
    p5_a54 := ddp_x_cost_price_rec.attribute10;
    p5_a55 := ddp_x_cost_price_rec.attribute11;
    p5_a56 := ddp_x_cost_price_rec.attribute12;
    p5_a57 := ddp_x_cost_price_rec.attribute13;
    p5_a58 := ddp_x_cost_price_rec.attribute14;
    p5_a59 := ddp_x_cost_price_rec.attribute15;



  end;

  procedure estimate_mr_price(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , p5_a0 in out nocopy  NUMBER
    , p5_a1 in out nocopy  NUMBER
    , p5_a2 in out nocopy  NUMBER
    , p5_a3 in out nocopy  NUMBER
    , p5_a4 in out nocopy  NUMBER
    , p5_a5 in out nocopy  NUMBER
    , p5_a6 in out nocopy  NUMBER
    , p5_a7 in out nocopy  VARCHAR2
    , p5_a8 in out nocopy  NUMBER
    , p5_a9 in out nocopy  NUMBER
    , p5_a10 in out nocopy  NUMBER
    , p5_a11 in out nocopy  NUMBER
    , p5_a12 in out nocopy  VARCHAR2
    , p5_a13 in out nocopy  VARCHAR2
    , p5_a14 in out nocopy  VARCHAR2
    , p5_a15 in out nocopy  VARCHAR2
    , p5_a16 in out nocopy  NUMBER
    , p5_a17 in out nocopy  VARCHAR2
    , p5_a18 in out nocopy  NUMBER
    , p5_a19 in out nocopy  NUMBER
    , p5_a20 in out nocopy  NUMBER
    , p5_a21 in out nocopy  DATE
    , p5_a22 in out nocopy  DATE
    , p5_a23 in out nocopy  DATE
    , p5_a24 in out nocopy  DATE
    , p5_a25 in out nocopy  DATE
    , p5_a26 in out nocopy  DATE
    , p5_a27 in out nocopy  VARCHAR2
    , p5_a28 in out nocopy  NUMBER
    , p5_a29 in out nocopy  VARCHAR2
    , p5_a30 in out nocopy  VARCHAR2
    , p5_a31 in out nocopy  NUMBER
    , p5_a32 in out nocopy  VARCHAR2
    , p5_a33 in out nocopy  VARCHAR2
    , p5_a34 in out nocopy  VARCHAR2
    , p5_a35 in out nocopy  NUMBER
    , p5_a36 in out nocopy  VARCHAR2
    , p5_a37 in out nocopy  NUMBER
    , p5_a38 in out nocopy  NUMBER
    , p5_a39 in out nocopy  NUMBER
    , p5_a40 in out nocopy  DATE
    , p5_a41 in out nocopy  NUMBER
    , p5_a42 in out nocopy  DATE
    , p5_a43 in out nocopy  NUMBER
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
    , p5_a55 in out nocopy  VARCHAR2
    , p5_a56 in out nocopy  VARCHAR2
    , p5_a57 in out nocopy  VARCHAR2
    , p5_a58 in out nocopy  VARCHAR2
    , p5_a59 in out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_x_cost_price_rec ahl_vwp_visit_cst_pr_pvt.cost_price_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_x_cost_price_rec.visit_task_id := p5_a0;
    ddp_x_cost_price_rec.visit_id := p5_a1;
    ddp_x_cost_price_rec.mr_id := p5_a2;
    ddp_x_cost_price_rec.actual_cost := p5_a3;
    ddp_x_cost_price_rec.estimated_cost := p5_a4;
    ddp_x_cost_price_rec.actual_price := p5_a5;
    ddp_x_cost_price_rec.estimated_price := p5_a6;
    ddp_x_cost_price_rec.currency := p5_a7;
    ddp_x_cost_price_rec.snapshot_id := p5_a8;
    ddp_x_cost_price_rec.object_version_number := p5_a9;
    ddp_x_cost_price_rec.estimated_profit := p5_a10;
    ddp_x_cost_price_rec.actual_profit := p5_a11;
    ddp_x_cost_price_rec.outside_party_flag := p5_a12;
    ddp_x_cost_price_rec.is_outside_pty_flag_updt := p5_a13;
    ddp_x_cost_price_rec.is_cst_pr_info_required := p5_a14;
    ddp_x_cost_price_rec.is_cst_struc_updated := p5_a15;
    ddp_x_cost_price_rec.price_list_id := p5_a16;
    ddp_x_cost_price_rec.price_list_name := p5_a17;
    ddp_x_cost_price_rec.service_request_id := p5_a18;
    ddp_x_cost_price_rec.customer_id := p5_a19;
    ddp_x_cost_price_rec.organization_id := p5_a20;
    ddp_x_cost_price_rec.visit_start_date := rosetta_g_miss_date_in_map(p5_a21);
    ddp_x_cost_price_rec.visit_end_date := rosetta_g_miss_date_in_map(p5_a22);
    ddp_x_cost_price_rec.mr_start_date := rosetta_g_miss_date_in_map(p5_a23);
    ddp_x_cost_price_rec.mr_end_date := rosetta_g_miss_date_in_map(p5_a24);
    ddp_x_cost_price_rec.task_start_date := rosetta_g_miss_date_in_map(p5_a25);
    ddp_x_cost_price_rec.task_end_date := rosetta_g_miss_date_in_map(p5_a26);
    ddp_x_cost_price_rec.task_name := p5_a27;
    ddp_x_cost_price_rec.visit_task_number := p5_a28;
    ddp_x_cost_price_rec.mr_title := p5_a29;
    ddp_x_cost_price_rec.mr_description := p5_a30;
    ddp_x_cost_price_rec.billing_item_id := p5_a31;
    ddp_x_cost_price_rec.item_name := p5_a32;
    ddp_x_cost_price_rec.item_description := p5_a33;
    ddp_x_cost_price_rec.organization_name := p5_a34;
    ddp_x_cost_price_rec.workorder_id := p5_a35;
    ddp_x_cost_price_rec.master_wo_flag := p5_a36;
    ddp_x_cost_price_rec.mr_session_id := p5_a37;
    ddp_x_cost_price_rec.cost_session_id := p5_a38;
    ddp_x_cost_price_rec.created_by := p5_a39;
    ddp_x_cost_price_rec.creation_date := rosetta_g_miss_date_in_map(p5_a40);
    ddp_x_cost_price_rec.last_updated_by := p5_a41;
    ddp_x_cost_price_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a42);
    ddp_x_cost_price_rec.last_update_login := p5_a43;
    ddp_x_cost_price_rec.attribute_category := p5_a44;
    ddp_x_cost_price_rec.attribute1 := p5_a45;
    ddp_x_cost_price_rec.attribute2 := p5_a46;
    ddp_x_cost_price_rec.attribute3 := p5_a47;
    ddp_x_cost_price_rec.attribute4 := p5_a48;
    ddp_x_cost_price_rec.attribute5 := p5_a49;
    ddp_x_cost_price_rec.attribute6 := p5_a50;
    ddp_x_cost_price_rec.attribute7 := p5_a51;
    ddp_x_cost_price_rec.attribute8 := p5_a52;
    ddp_x_cost_price_rec.attribute9 := p5_a53;
    ddp_x_cost_price_rec.attribute10 := p5_a54;
    ddp_x_cost_price_rec.attribute11 := p5_a55;
    ddp_x_cost_price_rec.attribute12 := p5_a56;
    ddp_x_cost_price_rec.attribute13 := p5_a57;
    ddp_x_cost_price_rec.attribute14 := p5_a58;
    ddp_x_cost_price_rec.attribute15 := p5_a59;




    -- here's the delegated call to the old PL/SQL routine
    ahl_vwp_mr_cst_pr_pvt.estimate_mr_price(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_module_type,
      ddp_x_cost_price_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    p5_a0 := ddp_x_cost_price_rec.visit_task_id;
    p5_a1 := ddp_x_cost_price_rec.visit_id;
    p5_a2 := ddp_x_cost_price_rec.mr_id;
    p5_a3 := ddp_x_cost_price_rec.actual_cost;
    p5_a4 := ddp_x_cost_price_rec.estimated_cost;
    p5_a5 := ddp_x_cost_price_rec.actual_price;
    p5_a6 := ddp_x_cost_price_rec.estimated_price;
    p5_a7 := ddp_x_cost_price_rec.currency;
    p5_a8 := ddp_x_cost_price_rec.snapshot_id;
    p5_a9 := ddp_x_cost_price_rec.object_version_number;
    p5_a10 := ddp_x_cost_price_rec.estimated_profit;
    p5_a11 := ddp_x_cost_price_rec.actual_profit;
    p5_a12 := ddp_x_cost_price_rec.outside_party_flag;
    p5_a13 := ddp_x_cost_price_rec.is_outside_pty_flag_updt;
    p5_a14 := ddp_x_cost_price_rec.is_cst_pr_info_required;
    p5_a15 := ddp_x_cost_price_rec.is_cst_struc_updated;
    p5_a16 := ddp_x_cost_price_rec.price_list_id;
    p5_a17 := ddp_x_cost_price_rec.price_list_name;
    p5_a18 := ddp_x_cost_price_rec.service_request_id;
    p5_a19 := ddp_x_cost_price_rec.customer_id;
    p5_a20 := ddp_x_cost_price_rec.organization_id;
    p5_a21 := ddp_x_cost_price_rec.visit_start_date;
    p5_a22 := ddp_x_cost_price_rec.visit_end_date;
    p5_a23 := ddp_x_cost_price_rec.mr_start_date;
    p5_a24 := ddp_x_cost_price_rec.mr_end_date;
    p5_a25 := ddp_x_cost_price_rec.task_start_date;
    p5_a26 := ddp_x_cost_price_rec.task_end_date;
    p5_a27 := ddp_x_cost_price_rec.task_name;
    p5_a28 := ddp_x_cost_price_rec.visit_task_number;
    p5_a29 := ddp_x_cost_price_rec.mr_title;
    p5_a30 := ddp_x_cost_price_rec.mr_description;
    p5_a31 := ddp_x_cost_price_rec.billing_item_id;
    p5_a32 := ddp_x_cost_price_rec.item_name;
    p5_a33 := ddp_x_cost_price_rec.item_description;
    p5_a34 := ddp_x_cost_price_rec.organization_name;
    p5_a35 := ddp_x_cost_price_rec.workorder_id;
    p5_a36 := ddp_x_cost_price_rec.master_wo_flag;
    p5_a37 := ddp_x_cost_price_rec.mr_session_id;
    p5_a38 := ddp_x_cost_price_rec.cost_session_id;
    p5_a39 := ddp_x_cost_price_rec.created_by;
    p5_a40 := ddp_x_cost_price_rec.creation_date;
    p5_a41 := ddp_x_cost_price_rec.last_updated_by;
    p5_a42 := ddp_x_cost_price_rec.last_update_date;
    p5_a43 := ddp_x_cost_price_rec.last_update_login;
    p5_a44 := ddp_x_cost_price_rec.attribute_category;
    p5_a45 := ddp_x_cost_price_rec.attribute1;
    p5_a46 := ddp_x_cost_price_rec.attribute2;
    p5_a47 := ddp_x_cost_price_rec.attribute3;
    p5_a48 := ddp_x_cost_price_rec.attribute4;
    p5_a49 := ddp_x_cost_price_rec.attribute5;
    p5_a50 := ddp_x_cost_price_rec.attribute6;
    p5_a51 := ddp_x_cost_price_rec.attribute7;
    p5_a52 := ddp_x_cost_price_rec.attribute8;
    p5_a53 := ddp_x_cost_price_rec.attribute9;
    p5_a54 := ddp_x_cost_price_rec.attribute10;
    p5_a55 := ddp_x_cost_price_rec.attribute11;
    p5_a56 := ddp_x_cost_price_rec.attribute12;
    p5_a57 := ddp_x_cost_price_rec.attribute13;
    p5_a58 := ddp_x_cost_price_rec.attribute14;
    p5_a59 := ddp_x_cost_price_rec.attribute15;



  end;

  procedure get_mr_items_no_price(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p8_a0  NUMBER
    , p8_a1  NUMBER
    , p8_a2  NUMBER
    , p8_a3  NUMBER
    , p8_a4  NUMBER
    , p8_a5  NUMBER
    , p8_a6  NUMBER
    , p8_a7  VARCHAR2
    , p8_a8  NUMBER
    , p8_a9  NUMBER
    , p8_a10  NUMBER
    , p8_a11  NUMBER
    , p8_a12  VARCHAR2
    , p8_a13  VARCHAR2
    , p8_a14  VARCHAR2
    , p8_a15  VARCHAR2
    , p8_a16  NUMBER
    , p8_a17  VARCHAR2
    , p8_a18  NUMBER
    , p8_a19  NUMBER
    , p8_a20  NUMBER
    , p8_a21  DATE
    , p8_a22  DATE
    , p8_a23  DATE
    , p8_a24  DATE
    , p8_a25  DATE
    , p8_a26  DATE
    , p8_a27  VARCHAR2
    , p8_a28  NUMBER
    , p8_a29  VARCHAR2
    , p8_a30  VARCHAR2
    , p8_a31  NUMBER
    , p8_a32  VARCHAR2
    , p8_a33  VARCHAR2
    , p8_a34  VARCHAR2
    , p8_a35  NUMBER
    , p8_a36  VARCHAR2
    , p8_a37  NUMBER
    , p8_a38  NUMBER
    , p8_a39  NUMBER
    , p8_a40  DATE
    , p8_a41  NUMBER
    , p8_a42  DATE
    , p8_a43  NUMBER
    , p8_a44  VARCHAR2
    , p8_a45  VARCHAR2
    , p8_a46  VARCHAR2
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
    , p9_a0 out nocopy JTF_NUMBER_TABLE
    , p9_a1 out nocopy JTF_NUMBER_TABLE
    , p9_a2 out nocopy JTF_NUMBER_TABLE
    , p9_a3 out nocopy JTF_NUMBER_TABLE
    , p9_a4 out nocopy JTF_NUMBER_TABLE
    , p9_a5 out nocopy JTF_NUMBER_TABLE
    , p9_a6 out nocopy JTF_NUMBER_TABLE
    , p9_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a8 out nocopy JTF_NUMBER_TABLE
    , p9_a9 out nocopy JTF_NUMBER_TABLE
    , p9_a10 out nocopy JTF_NUMBER_TABLE
    , p9_a11 out nocopy JTF_NUMBER_TABLE
    , p9_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a16 out nocopy JTF_NUMBER_TABLE
    , p9_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a18 out nocopy JTF_NUMBER_TABLE
    , p9_a19 out nocopy JTF_NUMBER_TABLE
    , p9_a20 out nocopy JTF_NUMBER_TABLE
    , p9_a21 out nocopy JTF_DATE_TABLE
    , p9_a22 out nocopy JTF_DATE_TABLE
    , p9_a23 out nocopy JTF_DATE_TABLE
    , p9_a24 out nocopy JTF_DATE_TABLE
    , p9_a25 out nocopy JTF_DATE_TABLE
    , p9_a26 out nocopy JTF_DATE_TABLE
    , p9_a27 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a28 out nocopy JTF_NUMBER_TABLE
    , p9_a29 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a30 out nocopy JTF_VARCHAR2_TABLE_2000
    , p9_a31 out nocopy JTF_NUMBER_TABLE
    , p9_a32 out nocopy JTF_VARCHAR2_TABLE_400
    , p9_a33 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a34 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a35 out nocopy JTF_NUMBER_TABLE
    , p9_a36 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a37 out nocopy JTF_NUMBER_TABLE
    , p9_a38 out nocopy JTF_NUMBER_TABLE
    , p9_a39 out nocopy JTF_NUMBER_TABLE
    , p9_a40 out nocopy JTF_DATE_TABLE
    , p9_a41 out nocopy JTF_NUMBER_TABLE
    , p9_a42 out nocopy JTF_DATE_TABLE
    , p9_a43 out nocopy JTF_NUMBER_TABLE
    , p9_a44 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a45 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a46 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a47 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a48 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a49 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a50 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a51 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a52 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a53 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a54 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a55 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a56 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a57 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a58 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a59 out nocopy JTF_VARCHAR2_TABLE_200
  )

  as
    ddp_cost_price_rec ahl_vwp_visit_cst_pr_pvt.cost_price_rec_type;
    ddx_cost_price_tbl ahl_vwp_visit_cst_pr_pvt.cost_price_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_cost_price_rec.visit_task_id := p8_a0;
    ddp_cost_price_rec.visit_id := p8_a1;
    ddp_cost_price_rec.mr_id := p8_a2;
    ddp_cost_price_rec.actual_cost := p8_a3;
    ddp_cost_price_rec.estimated_cost := p8_a4;
    ddp_cost_price_rec.actual_price := p8_a5;
    ddp_cost_price_rec.estimated_price := p8_a6;
    ddp_cost_price_rec.currency := p8_a7;
    ddp_cost_price_rec.snapshot_id := p8_a8;
    ddp_cost_price_rec.object_version_number := p8_a9;
    ddp_cost_price_rec.estimated_profit := p8_a10;
    ddp_cost_price_rec.actual_profit := p8_a11;
    ddp_cost_price_rec.outside_party_flag := p8_a12;
    ddp_cost_price_rec.is_outside_pty_flag_updt := p8_a13;
    ddp_cost_price_rec.is_cst_pr_info_required := p8_a14;
    ddp_cost_price_rec.is_cst_struc_updated := p8_a15;
    ddp_cost_price_rec.price_list_id := p8_a16;
    ddp_cost_price_rec.price_list_name := p8_a17;
    ddp_cost_price_rec.service_request_id := p8_a18;
    ddp_cost_price_rec.customer_id := p8_a19;
    ddp_cost_price_rec.organization_id := p8_a20;
    ddp_cost_price_rec.visit_start_date := rosetta_g_miss_date_in_map(p8_a21);
    ddp_cost_price_rec.visit_end_date := rosetta_g_miss_date_in_map(p8_a22);
    ddp_cost_price_rec.mr_start_date := rosetta_g_miss_date_in_map(p8_a23);
    ddp_cost_price_rec.mr_end_date := rosetta_g_miss_date_in_map(p8_a24);
    ddp_cost_price_rec.task_start_date := rosetta_g_miss_date_in_map(p8_a25);
    ddp_cost_price_rec.task_end_date := rosetta_g_miss_date_in_map(p8_a26);
    ddp_cost_price_rec.task_name := p8_a27;
    ddp_cost_price_rec.visit_task_number := p8_a28;
    ddp_cost_price_rec.mr_title := p8_a29;
    ddp_cost_price_rec.mr_description := p8_a30;
    ddp_cost_price_rec.billing_item_id := p8_a31;
    ddp_cost_price_rec.item_name := p8_a32;
    ddp_cost_price_rec.item_description := p8_a33;
    ddp_cost_price_rec.organization_name := p8_a34;
    ddp_cost_price_rec.workorder_id := p8_a35;
    ddp_cost_price_rec.master_wo_flag := p8_a36;
    ddp_cost_price_rec.mr_session_id := p8_a37;
    ddp_cost_price_rec.cost_session_id := p8_a38;
    ddp_cost_price_rec.created_by := p8_a39;
    ddp_cost_price_rec.creation_date := rosetta_g_miss_date_in_map(p8_a40);
    ddp_cost_price_rec.last_updated_by := p8_a41;
    ddp_cost_price_rec.last_update_date := rosetta_g_miss_date_in_map(p8_a42);
    ddp_cost_price_rec.last_update_login := p8_a43;
    ddp_cost_price_rec.attribute_category := p8_a44;
    ddp_cost_price_rec.attribute1 := p8_a45;
    ddp_cost_price_rec.attribute2 := p8_a46;
    ddp_cost_price_rec.attribute3 := p8_a47;
    ddp_cost_price_rec.attribute4 := p8_a48;
    ddp_cost_price_rec.attribute5 := p8_a49;
    ddp_cost_price_rec.attribute6 := p8_a50;
    ddp_cost_price_rec.attribute7 := p8_a51;
    ddp_cost_price_rec.attribute8 := p8_a52;
    ddp_cost_price_rec.attribute9 := p8_a53;
    ddp_cost_price_rec.attribute10 := p8_a54;
    ddp_cost_price_rec.attribute11 := p8_a55;
    ddp_cost_price_rec.attribute12 := p8_a56;
    ddp_cost_price_rec.attribute13 := p8_a57;
    ddp_cost_price_rec.attribute14 := p8_a58;
    ddp_cost_price_rec.attribute15 := p8_a59;


    -- here's the delegated call to the old PL/SQL routine
    ahl_vwp_mr_cst_pr_pvt.get_mr_items_no_price(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_module_type,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_cost_price_rec,
      ddx_cost_price_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









    ahl_vwp_visit_cst_pr_pvt_w.rosetta_table_copy_out_p1(ddx_cost_price_tbl, p9_a0
      , p9_a1
      , p9_a2
      , p9_a3
      , p9_a4
      , p9_a5
      , p9_a6
      , p9_a7
      , p9_a8
      , p9_a9
      , p9_a10
      , p9_a11
      , p9_a12
      , p9_a13
      , p9_a14
      , p9_a15
      , p9_a16
      , p9_a17
      , p9_a18
      , p9_a19
      , p9_a20
      , p9_a21
      , p9_a22
      , p9_a23
      , p9_a24
      , p9_a25
      , p9_a26
      , p9_a27
      , p9_a28
      , p9_a29
      , p9_a30
      , p9_a31
      , p9_a32
      , p9_a33
      , p9_a34
      , p9_a35
      , p9_a36
      , p9_a37
      , p9_a38
      , p9_a39
      , p9_a40
      , p9_a41
      , p9_a42
      , p9_a43
      , p9_a44
      , p9_a45
      , p9_a46
      , p9_a47
      , p9_a48
      , p9_a49
      , p9_a50
      , p9_a51
      , p9_a52
      , p9_a53
      , p9_a54
      , p9_a55
      , p9_a56
      , p9_a57
      , p9_a58
      , p9_a59
      );
  end;

  procedure get_mr_cost_details(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , p5_a0 in out nocopy  NUMBER
    , p5_a1 in out nocopy  NUMBER
    , p5_a2 in out nocopy  NUMBER
    , p5_a3 in out nocopy  NUMBER
    , p5_a4 in out nocopy  NUMBER
    , p5_a5 in out nocopy  NUMBER
    , p5_a6 in out nocopy  NUMBER
    , p5_a7 in out nocopy  VARCHAR2
    , p5_a8 in out nocopy  NUMBER
    , p5_a9 in out nocopy  NUMBER
    , p5_a10 in out nocopy  NUMBER
    , p5_a11 in out nocopy  NUMBER
    , p5_a12 in out nocopy  VARCHAR2
    , p5_a13 in out nocopy  VARCHAR2
    , p5_a14 in out nocopy  VARCHAR2
    , p5_a15 in out nocopy  VARCHAR2
    , p5_a16 in out nocopy  NUMBER
    , p5_a17 in out nocopy  VARCHAR2
    , p5_a18 in out nocopy  NUMBER
    , p5_a19 in out nocopy  NUMBER
    , p5_a20 in out nocopy  NUMBER
    , p5_a21 in out nocopy  DATE
    , p5_a22 in out nocopy  DATE
    , p5_a23 in out nocopy  DATE
    , p5_a24 in out nocopy  DATE
    , p5_a25 in out nocopy  DATE
    , p5_a26 in out nocopy  DATE
    , p5_a27 in out nocopy  VARCHAR2
    , p5_a28 in out nocopy  NUMBER
    , p5_a29 in out nocopy  VARCHAR2
    , p5_a30 in out nocopy  VARCHAR2
    , p5_a31 in out nocopy  NUMBER
    , p5_a32 in out nocopy  VARCHAR2
    , p5_a33 in out nocopy  VARCHAR2
    , p5_a34 in out nocopy  VARCHAR2
    , p5_a35 in out nocopy  NUMBER
    , p5_a36 in out nocopy  VARCHAR2
    , p5_a37 in out nocopy  NUMBER
    , p5_a38 in out nocopy  NUMBER
    , p5_a39 in out nocopy  NUMBER
    , p5_a40 in out nocopy  DATE
    , p5_a41 in out nocopy  NUMBER
    , p5_a42 in out nocopy  DATE
    , p5_a43 in out nocopy  NUMBER
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
    , p5_a55 in out nocopy  VARCHAR2
    , p5_a56 in out nocopy  VARCHAR2
    , p5_a57 in out nocopy  VARCHAR2
    , p5_a58 in out nocopy  VARCHAR2
    , p5_a59 in out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_x_cost_price_rec ahl_vwp_visit_cst_pr_pvt.cost_price_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_x_cost_price_rec.visit_task_id := p5_a0;
    ddp_x_cost_price_rec.visit_id := p5_a1;
    ddp_x_cost_price_rec.mr_id := p5_a2;
    ddp_x_cost_price_rec.actual_cost := p5_a3;
    ddp_x_cost_price_rec.estimated_cost := p5_a4;
    ddp_x_cost_price_rec.actual_price := p5_a5;
    ddp_x_cost_price_rec.estimated_price := p5_a6;
    ddp_x_cost_price_rec.currency := p5_a7;
    ddp_x_cost_price_rec.snapshot_id := p5_a8;
    ddp_x_cost_price_rec.object_version_number := p5_a9;
    ddp_x_cost_price_rec.estimated_profit := p5_a10;
    ddp_x_cost_price_rec.actual_profit := p5_a11;
    ddp_x_cost_price_rec.outside_party_flag := p5_a12;
    ddp_x_cost_price_rec.is_outside_pty_flag_updt := p5_a13;
    ddp_x_cost_price_rec.is_cst_pr_info_required := p5_a14;
    ddp_x_cost_price_rec.is_cst_struc_updated := p5_a15;
    ddp_x_cost_price_rec.price_list_id := p5_a16;
    ddp_x_cost_price_rec.price_list_name := p5_a17;
    ddp_x_cost_price_rec.service_request_id := p5_a18;
    ddp_x_cost_price_rec.customer_id := p5_a19;
    ddp_x_cost_price_rec.organization_id := p5_a20;
    ddp_x_cost_price_rec.visit_start_date := rosetta_g_miss_date_in_map(p5_a21);
    ddp_x_cost_price_rec.visit_end_date := rosetta_g_miss_date_in_map(p5_a22);
    ddp_x_cost_price_rec.mr_start_date := rosetta_g_miss_date_in_map(p5_a23);
    ddp_x_cost_price_rec.mr_end_date := rosetta_g_miss_date_in_map(p5_a24);
    ddp_x_cost_price_rec.task_start_date := rosetta_g_miss_date_in_map(p5_a25);
    ddp_x_cost_price_rec.task_end_date := rosetta_g_miss_date_in_map(p5_a26);
    ddp_x_cost_price_rec.task_name := p5_a27;
    ddp_x_cost_price_rec.visit_task_number := p5_a28;
    ddp_x_cost_price_rec.mr_title := p5_a29;
    ddp_x_cost_price_rec.mr_description := p5_a30;
    ddp_x_cost_price_rec.billing_item_id := p5_a31;
    ddp_x_cost_price_rec.item_name := p5_a32;
    ddp_x_cost_price_rec.item_description := p5_a33;
    ddp_x_cost_price_rec.organization_name := p5_a34;
    ddp_x_cost_price_rec.workorder_id := p5_a35;
    ddp_x_cost_price_rec.master_wo_flag := p5_a36;
    ddp_x_cost_price_rec.mr_session_id := p5_a37;
    ddp_x_cost_price_rec.cost_session_id := p5_a38;
    ddp_x_cost_price_rec.created_by := p5_a39;
    ddp_x_cost_price_rec.creation_date := rosetta_g_miss_date_in_map(p5_a40);
    ddp_x_cost_price_rec.last_updated_by := p5_a41;
    ddp_x_cost_price_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a42);
    ddp_x_cost_price_rec.last_update_login := p5_a43;
    ddp_x_cost_price_rec.attribute_category := p5_a44;
    ddp_x_cost_price_rec.attribute1 := p5_a45;
    ddp_x_cost_price_rec.attribute2 := p5_a46;
    ddp_x_cost_price_rec.attribute3 := p5_a47;
    ddp_x_cost_price_rec.attribute4 := p5_a48;
    ddp_x_cost_price_rec.attribute5 := p5_a49;
    ddp_x_cost_price_rec.attribute6 := p5_a50;
    ddp_x_cost_price_rec.attribute7 := p5_a51;
    ddp_x_cost_price_rec.attribute8 := p5_a52;
    ddp_x_cost_price_rec.attribute9 := p5_a53;
    ddp_x_cost_price_rec.attribute10 := p5_a54;
    ddp_x_cost_price_rec.attribute11 := p5_a55;
    ddp_x_cost_price_rec.attribute12 := p5_a56;
    ddp_x_cost_price_rec.attribute13 := p5_a57;
    ddp_x_cost_price_rec.attribute14 := p5_a58;
    ddp_x_cost_price_rec.attribute15 := p5_a59;




    -- here's the delegated call to the old PL/SQL routine
    ahl_vwp_mr_cst_pr_pvt.get_mr_cost_details(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_module_type,
      ddp_x_cost_price_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    p5_a0 := ddp_x_cost_price_rec.visit_task_id;
    p5_a1 := ddp_x_cost_price_rec.visit_id;
    p5_a2 := ddp_x_cost_price_rec.mr_id;
    p5_a3 := ddp_x_cost_price_rec.actual_cost;
    p5_a4 := ddp_x_cost_price_rec.estimated_cost;
    p5_a5 := ddp_x_cost_price_rec.actual_price;
    p5_a6 := ddp_x_cost_price_rec.estimated_price;
    p5_a7 := ddp_x_cost_price_rec.currency;
    p5_a8 := ddp_x_cost_price_rec.snapshot_id;
    p5_a9 := ddp_x_cost_price_rec.object_version_number;
    p5_a10 := ddp_x_cost_price_rec.estimated_profit;
    p5_a11 := ddp_x_cost_price_rec.actual_profit;
    p5_a12 := ddp_x_cost_price_rec.outside_party_flag;
    p5_a13 := ddp_x_cost_price_rec.is_outside_pty_flag_updt;
    p5_a14 := ddp_x_cost_price_rec.is_cst_pr_info_required;
    p5_a15 := ddp_x_cost_price_rec.is_cst_struc_updated;
    p5_a16 := ddp_x_cost_price_rec.price_list_id;
    p5_a17 := ddp_x_cost_price_rec.price_list_name;
    p5_a18 := ddp_x_cost_price_rec.service_request_id;
    p5_a19 := ddp_x_cost_price_rec.customer_id;
    p5_a20 := ddp_x_cost_price_rec.organization_id;
    p5_a21 := ddp_x_cost_price_rec.visit_start_date;
    p5_a22 := ddp_x_cost_price_rec.visit_end_date;
    p5_a23 := ddp_x_cost_price_rec.mr_start_date;
    p5_a24 := ddp_x_cost_price_rec.mr_end_date;
    p5_a25 := ddp_x_cost_price_rec.task_start_date;
    p5_a26 := ddp_x_cost_price_rec.task_end_date;
    p5_a27 := ddp_x_cost_price_rec.task_name;
    p5_a28 := ddp_x_cost_price_rec.visit_task_number;
    p5_a29 := ddp_x_cost_price_rec.mr_title;
    p5_a30 := ddp_x_cost_price_rec.mr_description;
    p5_a31 := ddp_x_cost_price_rec.billing_item_id;
    p5_a32 := ddp_x_cost_price_rec.item_name;
    p5_a33 := ddp_x_cost_price_rec.item_description;
    p5_a34 := ddp_x_cost_price_rec.organization_name;
    p5_a35 := ddp_x_cost_price_rec.workorder_id;
    p5_a36 := ddp_x_cost_price_rec.master_wo_flag;
    p5_a37 := ddp_x_cost_price_rec.mr_session_id;
    p5_a38 := ddp_x_cost_price_rec.cost_session_id;
    p5_a39 := ddp_x_cost_price_rec.created_by;
    p5_a40 := ddp_x_cost_price_rec.creation_date;
    p5_a41 := ddp_x_cost_price_rec.last_updated_by;
    p5_a42 := ddp_x_cost_price_rec.last_update_date;
    p5_a43 := ddp_x_cost_price_rec.last_update_login;
    p5_a44 := ddp_x_cost_price_rec.attribute_category;
    p5_a45 := ddp_x_cost_price_rec.attribute1;
    p5_a46 := ddp_x_cost_price_rec.attribute2;
    p5_a47 := ddp_x_cost_price_rec.attribute3;
    p5_a48 := ddp_x_cost_price_rec.attribute4;
    p5_a49 := ddp_x_cost_price_rec.attribute5;
    p5_a50 := ddp_x_cost_price_rec.attribute6;
    p5_a51 := ddp_x_cost_price_rec.attribute7;
    p5_a52 := ddp_x_cost_price_rec.attribute8;
    p5_a53 := ddp_x_cost_price_rec.attribute9;
    p5_a54 := ddp_x_cost_price_rec.attribute10;
    p5_a55 := ddp_x_cost_price_rec.attribute11;
    p5_a56 := ddp_x_cost_price_rec.attribute12;
    p5_a57 := ddp_x_cost_price_rec.attribute13;
    p5_a58 := ddp_x_cost_price_rec.attribute14;
    p5_a59 := ddp_x_cost_price_rec.attribute15;



  end;

end ahl_vwp_mr_cst_pr_pvt_w;

/
