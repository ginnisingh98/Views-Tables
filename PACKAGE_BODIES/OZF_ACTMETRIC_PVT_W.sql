--------------------------------------------------------
--  DDL for Package Body OZF_ACTMETRIC_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_ACTMETRIC_PVT_W" as
  /* $Header: ozfwamtb.pls 115.1 2003/10/10 11:15:53 kdass noship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure init_actmetric_rec(p0_a0 in out nocopy  NUMBER
    , p0_a1 in out nocopy  DATE
    , p0_a2 in out nocopy  NUMBER
    , p0_a3 in out nocopy  DATE
    , p0_a4 in out nocopy  NUMBER
    , p0_a5 in out nocopy  NUMBER
    , p0_a6 in out nocopy  NUMBER
    , p0_a7 in out nocopy  NUMBER
    , p0_a8 in out nocopy  VARCHAR2
    , p0_a9 in out nocopy  VARCHAR2
    , p0_a10 in out nocopy  NUMBER
    , p0_a11 in out nocopy  VARCHAR2
    , p0_a12 in out nocopy  NUMBER
    , p0_a13 in out nocopy  NUMBER
    , p0_a14 in out nocopy  VARCHAR2
    , p0_a15 in out nocopy  NUMBER
    , p0_a16 in out nocopy  NUMBER
    , p0_a17 in out nocopy  NUMBER
    , p0_a18 in out nocopy  VARCHAR2
    , p0_a19 in out nocopy  NUMBER
    , p0_a20 in out nocopy  VARCHAR2
    , p0_a21 in out nocopy  NUMBER
    , p0_a22 in out nocopy  NUMBER
    , p0_a23 in out nocopy  DATE
    , p0_a24 in out nocopy  NUMBER
    , p0_a25 in out nocopy  NUMBER
    , p0_a26 in out nocopy  VARCHAR2
    , p0_a27 in out nocopy  NUMBER
    , p0_a28 in out nocopy  NUMBER
    , p0_a29 in out nocopy  NUMBER
    , p0_a30 in out nocopy  VARCHAR2
    , p0_a31 in out nocopy  NUMBER
    , p0_a32 in out nocopy  NUMBER
    , p0_a33 in out nocopy  NUMBER
    , p0_a34 in out nocopy  NUMBER
    , p0_a35 in out nocopy  NUMBER
    , p0_a36 in out nocopy  NUMBER
    , p0_a37 in out nocopy  NUMBER
    , p0_a38 in out nocopy  NUMBER
    , p0_a39 in out nocopy  DATE
    , p0_a40 in out nocopy  DATE
    , p0_a41 in out nocopy  NUMBER
    , p0_a42 in out nocopy  NUMBER
    , p0_a43 in out nocopy  NUMBER
    , p0_a44 in out nocopy  NUMBER
    , p0_a45 in out nocopy  NUMBER
    , p0_a46 in out nocopy  NUMBER
    , p0_a47 in out nocopy  VARCHAR2
    , p0_a48 in out nocopy  VARCHAR2
    , p0_a49 in out nocopy  VARCHAR2
    , p0_a50 in out nocopy  VARCHAR2
    , p0_a51 in out nocopy  VARCHAR2
    , p0_a52 in out nocopy  VARCHAR2
    , p0_a53 in out nocopy  VARCHAR2
    , p0_a54 in out nocopy  VARCHAR2
    , p0_a55 in out nocopy  VARCHAR2
    , p0_a56 in out nocopy  VARCHAR2
    , p0_a57 in out nocopy  VARCHAR2
    , p0_a58 in out nocopy  VARCHAR2
    , p0_a59 in out nocopy  VARCHAR2
    , p0_a60 in out nocopy  VARCHAR2
    , p0_a61 in out nocopy  VARCHAR2
    , p0_a62 in out nocopy  VARCHAR2
    , p0_a63 in out nocopy  VARCHAR2
    , p0_a64 in out nocopy  VARCHAR2
    , p0_a65 in out nocopy  VARCHAR2
    , p0_a66 in out nocopy  VARCHAR2
    , p0_a67 in out nocopy  DATE
    , p0_a68 in out nocopy  NUMBER
    , p0_a69 in out nocopy  NUMBER
    , p0_a70 in out nocopy  VARCHAR2
    , p0_a71 in out nocopy  VARCHAR2
    , p0_a72 in out nocopy  VARCHAR2
    , p0_a73 in out nocopy  VARCHAR2
    , p0_a74 in out nocopy  VARCHAR2
    , p0_a75 in out nocopy  NUMBER
    , p0_a76 in out nocopy  VARCHAR2
    , p0_a77 in out nocopy  NUMBER
    , p0_a78 in out nocopy  VARCHAR2
    , p0_a79 in out nocopy  VARCHAR2
  )

  as
    ddx_act_metric_rec ozf_actmetric_pvt.act_metric_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddx_act_metric_rec.activity_metric_id := p0_a0;
    ddx_act_metric_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddx_act_metric_rec.last_updated_by := p0_a2;
    ddx_act_metric_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddx_act_metric_rec.created_by := p0_a4;
    ddx_act_metric_rec.last_update_login := p0_a5;
    ddx_act_metric_rec.object_version_number := p0_a6;
    ddx_act_metric_rec.act_metric_used_by_id := p0_a7;
    ddx_act_metric_rec.arc_act_metric_used_by := p0_a8;
    ddx_act_metric_rec.purchase_req_raised_flag := p0_a9;
    ddx_act_metric_rec.application_id := p0_a10;
    ddx_act_metric_rec.sensitive_data_flag := p0_a11;
    ddx_act_metric_rec.budget_id := p0_a12;
    ddx_act_metric_rec.metric_id := p0_a13;
    ddx_act_metric_rec.transaction_currency_code := p0_a14;
    ddx_act_metric_rec.trans_forecasted_value := p0_a15;
    ddx_act_metric_rec.trans_committed_value := p0_a16;
    ddx_act_metric_rec.trans_actual_value := p0_a17;
    ddx_act_metric_rec.functional_currency_code := p0_a18;
    ddx_act_metric_rec.func_forecasted_value := p0_a19;
    ddx_act_metric_rec.dirty_flag := p0_a20;
    ddx_act_metric_rec.func_committed_value := p0_a21;
    ddx_act_metric_rec.func_actual_value := p0_a22;
    ddx_act_metric_rec.last_calculated_date := rosetta_g_miss_date_in_map(p0_a23);
    ddx_act_metric_rec.variable_value := p0_a24;
    ddx_act_metric_rec.computed_using_function_value := p0_a25;
    ddx_act_metric_rec.metric_uom_code := p0_a26;
    ddx_act_metric_rec.org_id := p0_a27;
    ddx_act_metric_rec.difference_since_last_calc := p0_a28;
    ddx_act_metric_rec.activity_metric_origin_id := p0_a29;
    ddx_act_metric_rec.arc_activity_metric_origin := p0_a30;
    ddx_act_metric_rec.days_since_last_refresh := p0_a31;
    ddx_act_metric_rec.scenario_id := p0_a32;
    ddx_act_metric_rec.summarize_to_metric := p0_a33;
    ddx_act_metric_rec.rollup_to_metric := p0_a34;
    ddx_act_metric_rec.hierarchy_id := p0_a35;
    ddx_act_metric_rec.start_node := p0_a36;
    ddx_act_metric_rec.from_level := p0_a37;
    ddx_act_metric_rec.to_level := p0_a38;
    ddx_act_metric_rec.from_date := rosetta_g_miss_date_in_map(p0_a39);
    ddx_act_metric_rec.to_date := rosetta_g_miss_date_in_map(p0_a40);
    ddx_act_metric_rec.amount1 := p0_a41;
    ddx_act_metric_rec.amount2 := p0_a42;
    ddx_act_metric_rec.amount3 := p0_a43;
    ddx_act_metric_rec.percent1 := p0_a44;
    ddx_act_metric_rec.percent2 := p0_a45;
    ddx_act_metric_rec.percent3 := p0_a46;
    ddx_act_metric_rec.published_flag := p0_a47;
    ddx_act_metric_rec.pre_function_name := p0_a48;
    ddx_act_metric_rec.post_function_name := p0_a49;
    ddx_act_metric_rec.attribute_category := p0_a50;
    ddx_act_metric_rec.attribute1 := p0_a51;
    ddx_act_metric_rec.attribute2 := p0_a52;
    ddx_act_metric_rec.attribute3 := p0_a53;
    ddx_act_metric_rec.attribute4 := p0_a54;
    ddx_act_metric_rec.attribute5 := p0_a55;
    ddx_act_metric_rec.attribute6 := p0_a56;
    ddx_act_metric_rec.attribute7 := p0_a57;
    ddx_act_metric_rec.attribute8 := p0_a58;
    ddx_act_metric_rec.attribute9 := p0_a59;
    ddx_act_metric_rec.attribute10 := p0_a60;
    ddx_act_metric_rec.attribute11 := p0_a61;
    ddx_act_metric_rec.attribute12 := p0_a62;
    ddx_act_metric_rec.attribute13 := p0_a63;
    ddx_act_metric_rec.attribute14 := p0_a64;
    ddx_act_metric_rec.attribute15 := p0_a65;
    ddx_act_metric_rec.description := p0_a66;
    ddx_act_metric_rec.act_metric_date := rosetta_g_miss_date_in_map(p0_a67);
    ddx_act_metric_rec.depend_act_metric := p0_a68;
    ddx_act_metric_rec.function_used_by_id := p0_a69;
    ddx_act_metric_rec.arc_function_used_by := p0_a70;
    ddx_act_metric_rec.hierarchy_type := p0_a71;
    ddx_act_metric_rec.status_code := p0_a72;
    ddx_act_metric_rec.method_code := p0_a73;
    ddx_act_metric_rec.action_code := p0_a74;
    ddx_act_metric_rec.basis_year := p0_a75;
    ddx_act_metric_rec.ex_start_node := p0_a76;
    ddx_act_metric_rec.product_spread_time_id := p0_a77;
    ddx_act_metric_rec.start_period_name := p0_a78;
    ddx_act_metric_rec.end_period_name := p0_a79;

    -- here's the delegated call to the old PL/SQL routine
    ozf_actmetric_pvt.init_actmetric_rec(ddx_act_metric_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    p0_a0 := ddx_act_metric_rec.activity_metric_id;
    p0_a1 := ddx_act_metric_rec.last_update_date;
    p0_a2 := ddx_act_metric_rec.last_updated_by;
    p0_a3 := ddx_act_metric_rec.creation_date;
    p0_a4 := ddx_act_metric_rec.created_by;
    p0_a5 := ddx_act_metric_rec.last_update_login;
    p0_a6 := ddx_act_metric_rec.object_version_number;
    p0_a7 := ddx_act_metric_rec.act_metric_used_by_id;
    p0_a8 := ddx_act_metric_rec.arc_act_metric_used_by;
    p0_a9 := ddx_act_metric_rec.purchase_req_raised_flag;
    p0_a10 := ddx_act_metric_rec.application_id;
    p0_a11 := ddx_act_metric_rec.sensitive_data_flag;
    p0_a12 := ddx_act_metric_rec.budget_id;
    p0_a13 := ddx_act_metric_rec.metric_id;
    p0_a14 := ddx_act_metric_rec.transaction_currency_code;
    p0_a15 := ddx_act_metric_rec.trans_forecasted_value;
    p0_a16 := ddx_act_metric_rec.trans_committed_value;
    p0_a17 := ddx_act_metric_rec.trans_actual_value;
    p0_a18 := ddx_act_metric_rec.functional_currency_code;
    p0_a19 := ddx_act_metric_rec.func_forecasted_value;
    p0_a20 := ddx_act_metric_rec.dirty_flag;
    p0_a21 := ddx_act_metric_rec.func_committed_value;
    p0_a22 := ddx_act_metric_rec.func_actual_value;
    p0_a23 := ddx_act_metric_rec.last_calculated_date;
    p0_a24 := ddx_act_metric_rec.variable_value;
    p0_a25 := ddx_act_metric_rec.computed_using_function_value;
    p0_a26 := ddx_act_metric_rec.metric_uom_code;
    p0_a27 := ddx_act_metric_rec.org_id;
    p0_a28 := ddx_act_metric_rec.difference_since_last_calc;
    p0_a29 := ddx_act_metric_rec.activity_metric_origin_id;
    p0_a30 := ddx_act_metric_rec.arc_activity_metric_origin;
    p0_a31 := ddx_act_metric_rec.days_since_last_refresh;
    p0_a32 := ddx_act_metric_rec.scenario_id;
    p0_a33 := ddx_act_metric_rec.summarize_to_metric;
    p0_a34 := ddx_act_metric_rec.rollup_to_metric;
    p0_a35 := ddx_act_metric_rec.hierarchy_id;
    p0_a36 := ddx_act_metric_rec.start_node;
    p0_a37 := ddx_act_metric_rec.from_level;
    p0_a38 := ddx_act_metric_rec.to_level;
    p0_a39 := ddx_act_metric_rec.from_date;
    p0_a40 := ddx_act_metric_rec.to_date;
    p0_a41 := ddx_act_metric_rec.amount1;
    p0_a42 := ddx_act_metric_rec.amount2;
    p0_a43 := ddx_act_metric_rec.amount3;
    p0_a44 := ddx_act_metric_rec.percent1;
    p0_a45 := ddx_act_metric_rec.percent2;
    p0_a46 := ddx_act_metric_rec.percent3;
    p0_a47 := ddx_act_metric_rec.published_flag;
    p0_a48 := ddx_act_metric_rec.pre_function_name;
    p0_a49 := ddx_act_metric_rec.post_function_name;
    p0_a50 := ddx_act_metric_rec.attribute_category;
    p0_a51 := ddx_act_metric_rec.attribute1;
    p0_a52 := ddx_act_metric_rec.attribute2;
    p0_a53 := ddx_act_metric_rec.attribute3;
    p0_a54 := ddx_act_metric_rec.attribute4;
    p0_a55 := ddx_act_metric_rec.attribute5;
    p0_a56 := ddx_act_metric_rec.attribute6;
    p0_a57 := ddx_act_metric_rec.attribute7;
    p0_a58 := ddx_act_metric_rec.attribute8;
    p0_a59 := ddx_act_metric_rec.attribute9;
    p0_a60 := ddx_act_metric_rec.attribute10;
    p0_a61 := ddx_act_metric_rec.attribute11;
    p0_a62 := ddx_act_metric_rec.attribute12;
    p0_a63 := ddx_act_metric_rec.attribute13;
    p0_a64 := ddx_act_metric_rec.attribute14;
    p0_a65 := ddx_act_metric_rec.attribute15;
    p0_a66 := ddx_act_metric_rec.description;
    p0_a67 := ddx_act_metric_rec.act_metric_date;
    p0_a68 := ddx_act_metric_rec.depend_act_metric;
    p0_a69 := ddx_act_metric_rec.function_used_by_id;
    p0_a70 := ddx_act_metric_rec.arc_function_used_by;
    p0_a71 := ddx_act_metric_rec.hierarchy_type;
    p0_a72 := ddx_act_metric_rec.status_code;
    p0_a73 := ddx_act_metric_rec.method_code;
    p0_a74 := ddx_act_metric_rec.action_code;
    p0_a75 := ddx_act_metric_rec.basis_year;
    p0_a76 := ddx_act_metric_rec.ex_start_node;
    p0_a77 := ddx_act_metric_rec.product_spread_time_id;
    p0_a78 := ddx_act_metric_rec.start_period_name;
    p0_a79 := ddx_act_metric_rec.end_period_name;
  end;

  procedure create_actmetric(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  DATE
    , p7_a2  NUMBER
    , p7_a3  DATE
    , p7_a4  NUMBER
    , p7_a5  NUMBER
    , p7_a6  NUMBER
    , p7_a7  NUMBER
    , p7_a8  VARCHAR2
    , p7_a9  VARCHAR2
    , p7_a10  NUMBER
    , p7_a11  VARCHAR2
    , p7_a12  NUMBER
    , p7_a13  NUMBER
    , p7_a14  VARCHAR2
    , p7_a15  NUMBER
    , p7_a16  NUMBER
    , p7_a17  NUMBER
    , p7_a18  VARCHAR2
    , p7_a19  NUMBER
    , p7_a20  VARCHAR2
    , p7_a21  NUMBER
    , p7_a22  NUMBER
    , p7_a23  DATE
    , p7_a24  NUMBER
    , p7_a25  NUMBER
    , p7_a26  VARCHAR2
    , p7_a27  NUMBER
    , p7_a28  NUMBER
    , p7_a29  NUMBER
    , p7_a30  VARCHAR2
    , p7_a31  NUMBER
    , p7_a32  NUMBER
    , p7_a33  NUMBER
    , p7_a34  NUMBER
    , p7_a35  NUMBER
    , p7_a36  NUMBER
    , p7_a37  NUMBER
    , p7_a38  NUMBER
    , p7_a39  DATE
    , p7_a40  DATE
    , p7_a41  NUMBER
    , p7_a42  NUMBER
    , p7_a43  NUMBER
    , p7_a44  NUMBER
    , p7_a45  NUMBER
    , p7_a46  NUMBER
    , p7_a47  VARCHAR2
    , p7_a48  VARCHAR2
    , p7_a49  VARCHAR2
    , p7_a50  VARCHAR2
    , p7_a51  VARCHAR2
    , p7_a52  VARCHAR2
    , p7_a53  VARCHAR2
    , p7_a54  VARCHAR2
    , p7_a55  VARCHAR2
    , p7_a56  VARCHAR2
    , p7_a57  VARCHAR2
    , p7_a58  VARCHAR2
    , p7_a59  VARCHAR2
    , p7_a60  VARCHAR2
    , p7_a61  VARCHAR2
    , p7_a62  VARCHAR2
    , p7_a63  VARCHAR2
    , p7_a64  VARCHAR2
    , p7_a65  VARCHAR2
    , p7_a66  VARCHAR2
    , p7_a67  DATE
    , p7_a68  NUMBER
    , p7_a69  NUMBER
    , p7_a70  VARCHAR2
    , p7_a71  VARCHAR2
    , p7_a72  VARCHAR2
    , p7_a73  VARCHAR2
    , p7_a74  VARCHAR2
    , p7_a75  NUMBER
    , p7_a76  VARCHAR2
    , p7_a77  NUMBER
    , p7_a78  VARCHAR2
    , p7_a79  VARCHAR2
    , x_activity_metric_id out nocopy  NUMBER
  )

  as
    ddp_act_metric_rec ozf_actmetric_pvt.act_metric_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_act_metric_rec.activity_metric_id := p7_a0;
    ddp_act_metric_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_act_metric_rec.last_updated_by := p7_a2;
    ddp_act_metric_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_act_metric_rec.created_by := p7_a4;
    ddp_act_metric_rec.last_update_login := p7_a5;
    ddp_act_metric_rec.object_version_number := p7_a6;
    ddp_act_metric_rec.act_metric_used_by_id := p7_a7;
    ddp_act_metric_rec.arc_act_metric_used_by := p7_a8;
    ddp_act_metric_rec.purchase_req_raised_flag := p7_a9;
    ddp_act_metric_rec.application_id := p7_a10;
    ddp_act_metric_rec.sensitive_data_flag := p7_a11;
    ddp_act_metric_rec.budget_id := p7_a12;
    ddp_act_metric_rec.metric_id := p7_a13;
    ddp_act_metric_rec.transaction_currency_code := p7_a14;
    ddp_act_metric_rec.trans_forecasted_value := p7_a15;
    ddp_act_metric_rec.trans_committed_value := p7_a16;
    ddp_act_metric_rec.trans_actual_value := p7_a17;
    ddp_act_metric_rec.functional_currency_code := p7_a18;
    ddp_act_metric_rec.func_forecasted_value := p7_a19;
    ddp_act_metric_rec.dirty_flag := p7_a20;
    ddp_act_metric_rec.func_committed_value := p7_a21;
    ddp_act_metric_rec.func_actual_value := p7_a22;
    ddp_act_metric_rec.last_calculated_date := rosetta_g_miss_date_in_map(p7_a23);
    ddp_act_metric_rec.variable_value := p7_a24;
    ddp_act_metric_rec.computed_using_function_value := p7_a25;
    ddp_act_metric_rec.metric_uom_code := p7_a26;
    ddp_act_metric_rec.org_id := p7_a27;
    ddp_act_metric_rec.difference_since_last_calc := p7_a28;
    ddp_act_metric_rec.activity_metric_origin_id := p7_a29;
    ddp_act_metric_rec.arc_activity_metric_origin := p7_a30;
    ddp_act_metric_rec.days_since_last_refresh := p7_a31;
    ddp_act_metric_rec.scenario_id := p7_a32;
    ddp_act_metric_rec.summarize_to_metric := p7_a33;
    ddp_act_metric_rec.rollup_to_metric := p7_a34;
    ddp_act_metric_rec.hierarchy_id := p7_a35;
    ddp_act_metric_rec.start_node := p7_a36;
    ddp_act_metric_rec.from_level := p7_a37;
    ddp_act_metric_rec.to_level := p7_a38;
    ddp_act_metric_rec.from_date := rosetta_g_miss_date_in_map(p7_a39);
    ddp_act_metric_rec.to_date := rosetta_g_miss_date_in_map(p7_a40);
    ddp_act_metric_rec.amount1 := p7_a41;
    ddp_act_metric_rec.amount2 := p7_a42;
    ddp_act_metric_rec.amount3 := p7_a43;
    ddp_act_metric_rec.percent1 := p7_a44;
    ddp_act_metric_rec.percent2 := p7_a45;
    ddp_act_metric_rec.percent3 := p7_a46;
    ddp_act_metric_rec.published_flag := p7_a47;
    ddp_act_metric_rec.pre_function_name := p7_a48;
    ddp_act_metric_rec.post_function_name := p7_a49;
    ddp_act_metric_rec.attribute_category := p7_a50;
    ddp_act_metric_rec.attribute1 := p7_a51;
    ddp_act_metric_rec.attribute2 := p7_a52;
    ddp_act_metric_rec.attribute3 := p7_a53;
    ddp_act_metric_rec.attribute4 := p7_a54;
    ddp_act_metric_rec.attribute5 := p7_a55;
    ddp_act_metric_rec.attribute6 := p7_a56;
    ddp_act_metric_rec.attribute7 := p7_a57;
    ddp_act_metric_rec.attribute8 := p7_a58;
    ddp_act_metric_rec.attribute9 := p7_a59;
    ddp_act_metric_rec.attribute10 := p7_a60;
    ddp_act_metric_rec.attribute11 := p7_a61;
    ddp_act_metric_rec.attribute12 := p7_a62;
    ddp_act_metric_rec.attribute13 := p7_a63;
    ddp_act_metric_rec.attribute14 := p7_a64;
    ddp_act_metric_rec.attribute15 := p7_a65;
    ddp_act_metric_rec.description := p7_a66;
    ddp_act_metric_rec.act_metric_date := rosetta_g_miss_date_in_map(p7_a67);
    ddp_act_metric_rec.depend_act_metric := p7_a68;
    ddp_act_metric_rec.function_used_by_id := p7_a69;
    ddp_act_metric_rec.arc_function_used_by := p7_a70;
    ddp_act_metric_rec.hierarchy_type := p7_a71;
    ddp_act_metric_rec.status_code := p7_a72;
    ddp_act_metric_rec.method_code := p7_a73;
    ddp_act_metric_rec.action_code := p7_a74;
    ddp_act_metric_rec.basis_year := p7_a75;
    ddp_act_metric_rec.ex_start_node := p7_a76;
    ddp_act_metric_rec.product_spread_time_id := p7_a77;
    ddp_act_metric_rec.start_period_name := p7_a78;
    ddp_act_metric_rec.end_period_name := p7_a79;


    -- here's the delegated call to the old PL/SQL routine
    ozf_actmetric_pvt.create_actmetric(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_act_metric_rec,
      x_activity_metric_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_actmetric(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  DATE
    , p7_a2  NUMBER
    , p7_a3  DATE
    , p7_a4  NUMBER
    , p7_a5  NUMBER
    , p7_a6  NUMBER
    , p7_a7  NUMBER
    , p7_a8  VARCHAR2
    , p7_a9  VARCHAR2
    , p7_a10  NUMBER
    , p7_a11  VARCHAR2
    , p7_a12  NUMBER
    , p7_a13  NUMBER
    , p7_a14  VARCHAR2
    , p7_a15  NUMBER
    , p7_a16  NUMBER
    , p7_a17  NUMBER
    , p7_a18  VARCHAR2
    , p7_a19  NUMBER
    , p7_a20  VARCHAR2
    , p7_a21  NUMBER
    , p7_a22  NUMBER
    , p7_a23  DATE
    , p7_a24  NUMBER
    , p7_a25  NUMBER
    , p7_a26  VARCHAR2
    , p7_a27  NUMBER
    , p7_a28  NUMBER
    , p7_a29  NUMBER
    , p7_a30  VARCHAR2
    , p7_a31  NUMBER
    , p7_a32  NUMBER
    , p7_a33  NUMBER
    , p7_a34  NUMBER
    , p7_a35  NUMBER
    , p7_a36  NUMBER
    , p7_a37  NUMBER
    , p7_a38  NUMBER
    , p7_a39  DATE
    , p7_a40  DATE
    , p7_a41  NUMBER
    , p7_a42  NUMBER
    , p7_a43  NUMBER
    , p7_a44  NUMBER
    , p7_a45  NUMBER
    , p7_a46  NUMBER
    , p7_a47  VARCHAR2
    , p7_a48  VARCHAR2
    , p7_a49  VARCHAR2
    , p7_a50  VARCHAR2
    , p7_a51  VARCHAR2
    , p7_a52  VARCHAR2
    , p7_a53  VARCHAR2
    , p7_a54  VARCHAR2
    , p7_a55  VARCHAR2
    , p7_a56  VARCHAR2
    , p7_a57  VARCHAR2
    , p7_a58  VARCHAR2
    , p7_a59  VARCHAR2
    , p7_a60  VARCHAR2
    , p7_a61  VARCHAR2
    , p7_a62  VARCHAR2
    , p7_a63  VARCHAR2
    , p7_a64  VARCHAR2
    , p7_a65  VARCHAR2
    , p7_a66  VARCHAR2
    , p7_a67  DATE
    , p7_a68  NUMBER
    , p7_a69  NUMBER
    , p7_a70  VARCHAR2
    , p7_a71  VARCHAR2
    , p7_a72  VARCHAR2
    , p7_a73  VARCHAR2
    , p7_a74  VARCHAR2
    , p7_a75  NUMBER
    , p7_a76  VARCHAR2
    , p7_a77  NUMBER
    , p7_a78  VARCHAR2
    , p7_a79  VARCHAR2
  )

  as
    ddp_act_metric_rec ozf_actmetric_pvt.act_metric_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_act_metric_rec.activity_metric_id := p7_a0;
    ddp_act_metric_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_act_metric_rec.last_updated_by := p7_a2;
    ddp_act_metric_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_act_metric_rec.created_by := p7_a4;
    ddp_act_metric_rec.last_update_login := p7_a5;
    ddp_act_metric_rec.object_version_number := p7_a6;
    ddp_act_metric_rec.act_metric_used_by_id := p7_a7;
    ddp_act_metric_rec.arc_act_metric_used_by := p7_a8;
    ddp_act_metric_rec.purchase_req_raised_flag := p7_a9;
    ddp_act_metric_rec.application_id := p7_a10;
    ddp_act_metric_rec.sensitive_data_flag := p7_a11;
    ddp_act_metric_rec.budget_id := p7_a12;
    ddp_act_metric_rec.metric_id := p7_a13;
    ddp_act_metric_rec.transaction_currency_code := p7_a14;
    ddp_act_metric_rec.trans_forecasted_value := p7_a15;
    ddp_act_metric_rec.trans_committed_value := p7_a16;
    ddp_act_metric_rec.trans_actual_value := p7_a17;
    ddp_act_metric_rec.functional_currency_code := p7_a18;
    ddp_act_metric_rec.func_forecasted_value := p7_a19;
    ddp_act_metric_rec.dirty_flag := p7_a20;
    ddp_act_metric_rec.func_committed_value := p7_a21;
    ddp_act_metric_rec.func_actual_value := p7_a22;
    ddp_act_metric_rec.last_calculated_date := rosetta_g_miss_date_in_map(p7_a23);
    ddp_act_metric_rec.variable_value := p7_a24;
    ddp_act_metric_rec.computed_using_function_value := p7_a25;
    ddp_act_metric_rec.metric_uom_code := p7_a26;
    ddp_act_metric_rec.org_id := p7_a27;
    ddp_act_metric_rec.difference_since_last_calc := p7_a28;
    ddp_act_metric_rec.activity_metric_origin_id := p7_a29;
    ddp_act_metric_rec.arc_activity_metric_origin := p7_a30;
    ddp_act_metric_rec.days_since_last_refresh := p7_a31;
    ddp_act_metric_rec.scenario_id := p7_a32;
    ddp_act_metric_rec.summarize_to_metric := p7_a33;
    ddp_act_metric_rec.rollup_to_metric := p7_a34;
    ddp_act_metric_rec.hierarchy_id := p7_a35;
    ddp_act_metric_rec.start_node := p7_a36;
    ddp_act_metric_rec.from_level := p7_a37;
    ddp_act_metric_rec.to_level := p7_a38;
    ddp_act_metric_rec.from_date := rosetta_g_miss_date_in_map(p7_a39);
    ddp_act_metric_rec.to_date := rosetta_g_miss_date_in_map(p7_a40);
    ddp_act_metric_rec.amount1 := p7_a41;
    ddp_act_metric_rec.amount2 := p7_a42;
    ddp_act_metric_rec.amount3 := p7_a43;
    ddp_act_metric_rec.percent1 := p7_a44;
    ddp_act_metric_rec.percent2 := p7_a45;
    ddp_act_metric_rec.percent3 := p7_a46;
    ddp_act_metric_rec.published_flag := p7_a47;
    ddp_act_metric_rec.pre_function_name := p7_a48;
    ddp_act_metric_rec.post_function_name := p7_a49;
    ddp_act_metric_rec.attribute_category := p7_a50;
    ddp_act_metric_rec.attribute1 := p7_a51;
    ddp_act_metric_rec.attribute2 := p7_a52;
    ddp_act_metric_rec.attribute3 := p7_a53;
    ddp_act_metric_rec.attribute4 := p7_a54;
    ddp_act_metric_rec.attribute5 := p7_a55;
    ddp_act_metric_rec.attribute6 := p7_a56;
    ddp_act_metric_rec.attribute7 := p7_a57;
    ddp_act_metric_rec.attribute8 := p7_a58;
    ddp_act_metric_rec.attribute9 := p7_a59;
    ddp_act_metric_rec.attribute10 := p7_a60;
    ddp_act_metric_rec.attribute11 := p7_a61;
    ddp_act_metric_rec.attribute12 := p7_a62;
    ddp_act_metric_rec.attribute13 := p7_a63;
    ddp_act_metric_rec.attribute14 := p7_a64;
    ddp_act_metric_rec.attribute15 := p7_a65;
    ddp_act_metric_rec.description := p7_a66;
    ddp_act_metric_rec.act_metric_date := rosetta_g_miss_date_in_map(p7_a67);
    ddp_act_metric_rec.depend_act_metric := p7_a68;
    ddp_act_metric_rec.function_used_by_id := p7_a69;
    ddp_act_metric_rec.arc_function_used_by := p7_a70;
    ddp_act_metric_rec.hierarchy_type := p7_a71;
    ddp_act_metric_rec.status_code := p7_a72;
    ddp_act_metric_rec.method_code := p7_a73;
    ddp_act_metric_rec.action_code := p7_a74;
    ddp_act_metric_rec.basis_year := p7_a75;
    ddp_act_metric_rec.ex_start_node := p7_a76;
    ddp_act_metric_rec.product_spread_time_id := p7_a77;
    ddp_act_metric_rec.start_period_name := p7_a78;
    ddp_act_metric_rec.end_period_name := p7_a79;

    -- here's the delegated call to the old PL/SQL routine
    ozf_actmetric_pvt.update_actmetric(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_act_metric_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure validate_actmetric(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0  NUMBER
    , p6_a1  DATE
    , p6_a2  NUMBER
    , p6_a3  DATE
    , p6_a4  NUMBER
    , p6_a5  NUMBER
    , p6_a6  NUMBER
    , p6_a7  NUMBER
    , p6_a8  VARCHAR2
    , p6_a9  VARCHAR2
    , p6_a10  NUMBER
    , p6_a11  VARCHAR2
    , p6_a12  NUMBER
    , p6_a13  NUMBER
    , p6_a14  VARCHAR2
    , p6_a15  NUMBER
    , p6_a16  NUMBER
    , p6_a17  NUMBER
    , p6_a18  VARCHAR2
    , p6_a19  NUMBER
    , p6_a20  VARCHAR2
    , p6_a21  NUMBER
    , p6_a22  NUMBER
    , p6_a23  DATE
    , p6_a24  NUMBER
    , p6_a25  NUMBER
    , p6_a26  VARCHAR2
    , p6_a27  NUMBER
    , p6_a28  NUMBER
    , p6_a29  NUMBER
    , p6_a30  VARCHAR2
    , p6_a31  NUMBER
    , p6_a32  NUMBER
    , p6_a33  NUMBER
    , p6_a34  NUMBER
    , p6_a35  NUMBER
    , p6_a36  NUMBER
    , p6_a37  NUMBER
    , p6_a38  NUMBER
    , p6_a39  DATE
    , p6_a40  DATE
    , p6_a41  NUMBER
    , p6_a42  NUMBER
    , p6_a43  NUMBER
    , p6_a44  NUMBER
    , p6_a45  NUMBER
    , p6_a46  NUMBER
    , p6_a47  VARCHAR2
    , p6_a48  VARCHAR2
    , p6_a49  VARCHAR2
    , p6_a50  VARCHAR2
    , p6_a51  VARCHAR2
    , p6_a52  VARCHAR2
    , p6_a53  VARCHAR2
    , p6_a54  VARCHAR2
    , p6_a55  VARCHAR2
    , p6_a56  VARCHAR2
    , p6_a57  VARCHAR2
    , p6_a58  VARCHAR2
    , p6_a59  VARCHAR2
    , p6_a60  VARCHAR2
    , p6_a61  VARCHAR2
    , p6_a62  VARCHAR2
    , p6_a63  VARCHAR2
    , p6_a64  VARCHAR2
    , p6_a65  VARCHAR2
    , p6_a66  VARCHAR2
    , p6_a67  DATE
    , p6_a68  NUMBER
    , p6_a69  NUMBER
    , p6_a70  VARCHAR2
    , p6_a71  VARCHAR2
    , p6_a72  VARCHAR2
    , p6_a73  VARCHAR2
    , p6_a74  VARCHAR2
    , p6_a75  NUMBER
    , p6_a76  VARCHAR2
    , p6_a77  NUMBER
    , p6_a78  VARCHAR2
    , p6_a79  VARCHAR2
  )

  as
    ddp_act_metric_rec ozf_actmetric_pvt.act_metric_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_act_metric_rec.activity_metric_id := p6_a0;
    ddp_act_metric_rec.last_update_date := rosetta_g_miss_date_in_map(p6_a1);
    ddp_act_metric_rec.last_updated_by := p6_a2;
    ddp_act_metric_rec.creation_date := rosetta_g_miss_date_in_map(p6_a3);
    ddp_act_metric_rec.created_by := p6_a4;
    ddp_act_metric_rec.last_update_login := p6_a5;
    ddp_act_metric_rec.object_version_number := p6_a6;
    ddp_act_metric_rec.act_metric_used_by_id := p6_a7;
    ddp_act_metric_rec.arc_act_metric_used_by := p6_a8;
    ddp_act_metric_rec.purchase_req_raised_flag := p6_a9;
    ddp_act_metric_rec.application_id := p6_a10;
    ddp_act_metric_rec.sensitive_data_flag := p6_a11;
    ddp_act_metric_rec.budget_id := p6_a12;
    ddp_act_metric_rec.metric_id := p6_a13;
    ddp_act_metric_rec.transaction_currency_code := p6_a14;
    ddp_act_metric_rec.trans_forecasted_value := p6_a15;
    ddp_act_metric_rec.trans_committed_value := p6_a16;
    ddp_act_metric_rec.trans_actual_value := p6_a17;
    ddp_act_metric_rec.functional_currency_code := p6_a18;
    ddp_act_metric_rec.func_forecasted_value := p6_a19;
    ddp_act_metric_rec.dirty_flag := p6_a20;
    ddp_act_metric_rec.func_committed_value := p6_a21;
    ddp_act_metric_rec.func_actual_value := p6_a22;
    ddp_act_metric_rec.last_calculated_date := rosetta_g_miss_date_in_map(p6_a23);
    ddp_act_metric_rec.variable_value := p6_a24;
    ddp_act_metric_rec.computed_using_function_value := p6_a25;
    ddp_act_metric_rec.metric_uom_code := p6_a26;
    ddp_act_metric_rec.org_id := p6_a27;
    ddp_act_metric_rec.difference_since_last_calc := p6_a28;
    ddp_act_metric_rec.activity_metric_origin_id := p6_a29;
    ddp_act_metric_rec.arc_activity_metric_origin := p6_a30;
    ddp_act_metric_rec.days_since_last_refresh := p6_a31;
    ddp_act_metric_rec.scenario_id := p6_a32;
    ddp_act_metric_rec.summarize_to_metric := p6_a33;
    ddp_act_metric_rec.rollup_to_metric := p6_a34;
    ddp_act_metric_rec.hierarchy_id := p6_a35;
    ddp_act_metric_rec.start_node := p6_a36;
    ddp_act_metric_rec.from_level := p6_a37;
    ddp_act_metric_rec.to_level := p6_a38;
    ddp_act_metric_rec.from_date := rosetta_g_miss_date_in_map(p6_a39);
    ddp_act_metric_rec.to_date := rosetta_g_miss_date_in_map(p6_a40);
    ddp_act_metric_rec.amount1 := p6_a41;
    ddp_act_metric_rec.amount2 := p6_a42;
    ddp_act_metric_rec.amount3 := p6_a43;
    ddp_act_metric_rec.percent1 := p6_a44;
    ddp_act_metric_rec.percent2 := p6_a45;
    ddp_act_metric_rec.percent3 := p6_a46;
    ddp_act_metric_rec.published_flag := p6_a47;
    ddp_act_metric_rec.pre_function_name := p6_a48;
    ddp_act_metric_rec.post_function_name := p6_a49;
    ddp_act_metric_rec.attribute_category := p6_a50;
    ddp_act_metric_rec.attribute1 := p6_a51;
    ddp_act_metric_rec.attribute2 := p6_a52;
    ddp_act_metric_rec.attribute3 := p6_a53;
    ddp_act_metric_rec.attribute4 := p6_a54;
    ddp_act_metric_rec.attribute5 := p6_a55;
    ddp_act_metric_rec.attribute6 := p6_a56;
    ddp_act_metric_rec.attribute7 := p6_a57;
    ddp_act_metric_rec.attribute8 := p6_a58;
    ddp_act_metric_rec.attribute9 := p6_a59;
    ddp_act_metric_rec.attribute10 := p6_a60;
    ddp_act_metric_rec.attribute11 := p6_a61;
    ddp_act_metric_rec.attribute12 := p6_a62;
    ddp_act_metric_rec.attribute13 := p6_a63;
    ddp_act_metric_rec.attribute14 := p6_a64;
    ddp_act_metric_rec.attribute15 := p6_a65;
    ddp_act_metric_rec.description := p6_a66;
    ddp_act_metric_rec.act_metric_date := rosetta_g_miss_date_in_map(p6_a67);
    ddp_act_metric_rec.depend_act_metric := p6_a68;
    ddp_act_metric_rec.function_used_by_id := p6_a69;
    ddp_act_metric_rec.arc_function_used_by := p6_a70;
    ddp_act_metric_rec.hierarchy_type := p6_a71;
    ddp_act_metric_rec.status_code := p6_a72;
    ddp_act_metric_rec.method_code := p6_a73;
    ddp_act_metric_rec.action_code := p6_a74;
    ddp_act_metric_rec.basis_year := p6_a75;
    ddp_act_metric_rec.ex_start_node := p6_a76;
    ddp_act_metric_rec.product_spread_time_id := p6_a77;
    ddp_act_metric_rec.start_period_name := p6_a78;
    ddp_act_metric_rec.end_period_name := p6_a79;

    -- here's the delegated call to the old PL/SQL routine
    ozf_actmetric_pvt.validate_actmetric(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_act_metric_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure validate_actmetric_items(p0_a0  NUMBER
    , p0_a1  DATE
    , p0_a2  NUMBER
    , p0_a3  DATE
    , p0_a4  NUMBER
    , p0_a5  NUMBER
    , p0_a6  NUMBER
    , p0_a7  NUMBER
    , p0_a8  VARCHAR2
    , p0_a9  VARCHAR2
    , p0_a10  NUMBER
    , p0_a11  VARCHAR2
    , p0_a12  NUMBER
    , p0_a13  NUMBER
    , p0_a14  VARCHAR2
    , p0_a15  NUMBER
    , p0_a16  NUMBER
    , p0_a17  NUMBER
    , p0_a18  VARCHAR2
    , p0_a19  NUMBER
    , p0_a20  VARCHAR2
    , p0_a21  NUMBER
    , p0_a22  NUMBER
    , p0_a23  DATE
    , p0_a24  NUMBER
    , p0_a25  NUMBER
    , p0_a26  VARCHAR2
    , p0_a27  NUMBER
    , p0_a28  NUMBER
    , p0_a29  NUMBER
    , p0_a30  VARCHAR2
    , p0_a31  NUMBER
    , p0_a32  NUMBER
    , p0_a33  NUMBER
    , p0_a34  NUMBER
    , p0_a35  NUMBER
    , p0_a36  NUMBER
    , p0_a37  NUMBER
    , p0_a38  NUMBER
    , p0_a39  DATE
    , p0_a40  DATE
    , p0_a41  NUMBER
    , p0_a42  NUMBER
    , p0_a43  NUMBER
    , p0_a44  NUMBER
    , p0_a45  NUMBER
    , p0_a46  NUMBER
    , p0_a47  VARCHAR2
    , p0_a48  VARCHAR2
    , p0_a49  VARCHAR2
    , p0_a50  VARCHAR2
    , p0_a51  VARCHAR2
    , p0_a52  VARCHAR2
    , p0_a53  VARCHAR2
    , p0_a54  VARCHAR2
    , p0_a55  VARCHAR2
    , p0_a56  VARCHAR2
    , p0_a57  VARCHAR2
    , p0_a58  VARCHAR2
    , p0_a59  VARCHAR2
    , p0_a60  VARCHAR2
    , p0_a61  VARCHAR2
    , p0_a62  VARCHAR2
    , p0_a63  VARCHAR2
    , p0_a64  VARCHAR2
    , p0_a65  VARCHAR2
    , p0_a66  VARCHAR2
    , p0_a67  DATE
    , p0_a68  NUMBER
    , p0_a69  NUMBER
    , p0_a70  VARCHAR2
    , p0_a71  VARCHAR2
    , p0_a72  VARCHAR2
    , p0_a73  VARCHAR2
    , p0_a74  VARCHAR2
    , p0_a75  NUMBER
    , p0_a76  VARCHAR2
    , p0_a77  NUMBER
    , p0_a78  VARCHAR2
    , p0_a79  VARCHAR2
    , p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_act_metric_rec ozf_actmetric_pvt.act_metric_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_act_metric_rec.activity_metric_id := p0_a0;
    ddp_act_metric_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_act_metric_rec.last_updated_by := p0_a2;
    ddp_act_metric_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_act_metric_rec.created_by := p0_a4;
    ddp_act_metric_rec.last_update_login := p0_a5;
    ddp_act_metric_rec.object_version_number := p0_a6;
    ddp_act_metric_rec.act_metric_used_by_id := p0_a7;
    ddp_act_metric_rec.arc_act_metric_used_by := p0_a8;
    ddp_act_metric_rec.purchase_req_raised_flag := p0_a9;
    ddp_act_metric_rec.application_id := p0_a10;
    ddp_act_metric_rec.sensitive_data_flag := p0_a11;
    ddp_act_metric_rec.budget_id := p0_a12;
    ddp_act_metric_rec.metric_id := p0_a13;
    ddp_act_metric_rec.transaction_currency_code := p0_a14;
    ddp_act_metric_rec.trans_forecasted_value := p0_a15;
    ddp_act_metric_rec.trans_committed_value := p0_a16;
    ddp_act_metric_rec.trans_actual_value := p0_a17;
    ddp_act_metric_rec.functional_currency_code := p0_a18;
    ddp_act_metric_rec.func_forecasted_value := p0_a19;
    ddp_act_metric_rec.dirty_flag := p0_a20;
    ddp_act_metric_rec.func_committed_value := p0_a21;
    ddp_act_metric_rec.func_actual_value := p0_a22;
    ddp_act_metric_rec.last_calculated_date := rosetta_g_miss_date_in_map(p0_a23);
    ddp_act_metric_rec.variable_value := p0_a24;
    ddp_act_metric_rec.computed_using_function_value := p0_a25;
    ddp_act_metric_rec.metric_uom_code := p0_a26;
    ddp_act_metric_rec.org_id := p0_a27;
    ddp_act_metric_rec.difference_since_last_calc := p0_a28;
    ddp_act_metric_rec.activity_metric_origin_id := p0_a29;
    ddp_act_metric_rec.arc_activity_metric_origin := p0_a30;
    ddp_act_metric_rec.days_since_last_refresh := p0_a31;
    ddp_act_metric_rec.scenario_id := p0_a32;
    ddp_act_metric_rec.summarize_to_metric := p0_a33;
    ddp_act_metric_rec.rollup_to_metric := p0_a34;
    ddp_act_metric_rec.hierarchy_id := p0_a35;
    ddp_act_metric_rec.start_node := p0_a36;
    ddp_act_metric_rec.from_level := p0_a37;
    ddp_act_metric_rec.to_level := p0_a38;
    ddp_act_metric_rec.from_date := rosetta_g_miss_date_in_map(p0_a39);
    ddp_act_metric_rec.to_date := rosetta_g_miss_date_in_map(p0_a40);
    ddp_act_metric_rec.amount1 := p0_a41;
    ddp_act_metric_rec.amount2 := p0_a42;
    ddp_act_metric_rec.amount3 := p0_a43;
    ddp_act_metric_rec.percent1 := p0_a44;
    ddp_act_metric_rec.percent2 := p0_a45;
    ddp_act_metric_rec.percent3 := p0_a46;
    ddp_act_metric_rec.published_flag := p0_a47;
    ddp_act_metric_rec.pre_function_name := p0_a48;
    ddp_act_metric_rec.post_function_name := p0_a49;
    ddp_act_metric_rec.attribute_category := p0_a50;
    ddp_act_metric_rec.attribute1 := p0_a51;
    ddp_act_metric_rec.attribute2 := p0_a52;
    ddp_act_metric_rec.attribute3 := p0_a53;
    ddp_act_metric_rec.attribute4 := p0_a54;
    ddp_act_metric_rec.attribute5 := p0_a55;
    ddp_act_metric_rec.attribute6 := p0_a56;
    ddp_act_metric_rec.attribute7 := p0_a57;
    ddp_act_metric_rec.attribute8 := p0_a58;
    ddp_act_metric_rec.attribute9 := p0_a59;
    ddp_act_metric_rec.attribute10 := p0_a60;
    ddp_act_metric_rec.attribute11 := p0_a61;
    ddp_act_metric_rec.attribute12 := p0_a62;
    ddp_act_metric_rec.attribute13 := p0_a63;
    ddp_act_metric_rec.attribute14 := p0_a64;
    ddp_act_metric_rec.attribute15 := p0_a65;
    ddp_act_metric_rec.description := p0_a66;
    ddp_act_metric_rec.act_metric_date := rosetta_g_miss_date_in_map(p0_a67);
    ddp_act_metric_rec.depend_act_metric := p0_a68;
    ddp_act_metric_rec.function_used_by_id := p0_a69;
    ddp_act_metric_rec.arc_function_used_by := p0_a70;
    ddp_act_metric_rec.hierarchy_type := p0_a71;
    ddp_act_metric_rec.status_code := p0_a72;
    ddp_act_metric_rec.method_code := p0_a73;
    ddp_act_metric_rec.action_code := p0_a74;
    ddp_act_metric_rec.basis_year := p0_a75;
    ddp_act_metric_rec.ex_start_node := p0_a76;
    ddp_act_metric_rec.product_spread_time_id := p0_a77;
    ddp_act_metric_rec.start_period_name := p0_a78;
    ddp_act_metric_rec.end_period_name := p0_a79;



    -- here's the delegated call to the old PL/SQL routine
    ozf_actmetric_pvt.validate_actmetric_items(ddp_act_metric_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure validate_actmetric_record(p0_a0  NUMBER
    , p0_a1  DATE
    , p0_a2  NUMBER
    , p0_a3  DATE
    , p0_a4  NUMBER
    , p0_a5  NUMBER
    , p0_a6  NUMBER
    , p0_a7  NUMBER
    , p0_a8  VARCHAR2
    , p0_a9  VARCHAR2
    , p0_a10  NUMBER
    , p0_a11  VARCHAR2
    , p0_a12  NUMBER
    , p0_a13  NUMBER
    , p0_a14  VARCHAR2
    , p0_a15  NUMBER
    , p0_a16  NUMBER
    , p0_a17  NUMBER
    , p0_a18  VARCHAR2
    , p0_a19  NUMBER
    , p0_a20  VARCHAR2
    , p0_a21  NUMBER
    , p0_a22  NUMBER
    , p0_a23  DATE
    , p0_a24  NUMBER
    , p0_a25  NUMBER
    , p0_a26  VARCHAR2
    , p0_a27  NUMBER
    , p0_a28  NUMBER
    , p0_a29  NUMBER
    , p0_a30  VARCHAR2
    , p0_a31  NUMBER
    , p0_a32  NUMBER
    , p0_a33  NUMBER
    , p0_a34  NUMBER
    , p0_a35  NUMBER
    , p0_a36  NUMBER
    , p0_a37  NUMBER
    , p0_a38  NUMBER
    , p0_a39  DATE
    , p0_a40  DATE
    , p0_a41  NUMBER
    , p0_a42  NUMBER
    , p0_a43  NUMBER
    , p0_a44  NUMBER
    , p0_a45  NUMBER
    , p0_a46  NUMBER
    , p0_a47  VARCHAR2
    , p0_a48  VARCHAR2
    , p0_a49  VARCHAR2
    , p0_a50  VARCHAR2
    , p0_a51  VARCHAR2
    , p0_a52  VARCHAR2
    , p0_a53  VARCHAR2
    , p0_a54  VARCHAR2
    , p0_a55  VARCHAR2
    , p0_a56  VARCHAR2
    , p0_a57  VARCHAR2
    , p0_a58  VARCHAR2
    , p0_a59  VARCHAR2
    , p0_a60  VARCHAR2
    , p0_a61  VARCHAR2
    , p0_a62  VARCHAR2
    , p0_a63  VARCHAR2
    , p0_a64  VARCHAR2
    , p0_a65  VARCHAR2
    , p0_a66  VARCHAR2
    , p0_a67  DATE
    , p0_a68  NUMBER
    , p0_a69  NUMBER
    , p0_a70  VARCHAR2
    , p0_a71  VARCHAR2
    , p0_a72  VARCHAR2
    , p0_a73  VARCHAR2
    , p0_a74  VARCHAR2
    , p0_a75  NUMBER
    , p0_a76  VARCHAR2
    , p0_a77  NUMBER
    , p0_a78  VARCHAR2
    , p0_a79  VARCHAR2
    , p1_a0  NUMBER
    , p1_a1  DATE
    , p1_a2  NUMBER
    , p1_a3  DATE
    , p1_a4  NUMBER
    , p1_a5  NUMBER
    , p1_a6  NUMBER
    , p1_a7  NUMBER
    , p1_a8  VARCHAR2
    , p1_a9  VARCHAR2
    , p1_a10  NUMBER
    , p1_a11  VARCHAR2
    , p1_a12  NUMBER
    , p1_a13  NUMBER
    , p1_a14  VARCHAR2
    , p1_a15  NUMBER
    , p1_a16  NUMBER
    , p1_a17  NUMBER
    , p1_a18  VARCHAR2
    , p1_a19  NUMBER
    , p1_a20  VARCHAR2
    , p1_a21  NUMBER
    , p1_a22  NUMBER
    , p1_a23  DATE
    , p1_a24  NUMBER
    , p1_a25  NUMBER
    , p1_a26  VARCHAR2
    , p1_a27  NUMBER
    , p1_a28  NUMBER
    , p1_a29  NUMBER
    , p1_a30  VARCHAR2
    , p1_a31  NUMBER
    , p1_a32  NUMBER
    , p1_a33  NUMBER
    , p1_a34  NUMBER
    , p1_a35  NUMBER
    , p1_a36  NUMBER
    , p1_a37  NUMBER
    , p1_a38  NUMBER
    , p1_a39  DATE
    , p1_a40  DATE
    , p1_a41  NUMBER
    , p1_a42  NUMBER
    , p1_a43  NUMBER
    , p1_a44  NUMBER
    , p1_a45  NUMBER
    , p1_a46  NUMBER
    , p1_a47  VARCHAR2
    , p1_a48  VARCHAR2
    , p1_a49  VARCHAR2
    , p1_a50  VARCHAR2
    , p1_a51  VARCHAR2
    , p1_a52  VARCHAR2
    , p1_a53  VARCHAR2
    , p1_a54  VARCHAR2
    , p1_a55  VARCHAR2
    , p1_a56  VARCHAR2
    , p1_a57  VARCHAR2
    , p1_a58  VARCHAR2
    , p1_a59  VARCHAR2
    , p1_a60  VARCHAR2
    , p1_a61  VARCHAR2
    , p1_a62  VARCHAR2
    , p1_a63  VARCHAR2
    , p1_a64  VARCHAR2
    , p1_a65  VARCHAR2
    , p1_a66  VARCHAR2
    , p1_a67  DATE
    , p1_a68  NUMBER
    , p1_a69  NUMBER
    , p1_a70  VARCHAR2
    , p1_a71  VARCHAR2
    , p1_a72  VARCHAR2
    , p1_a73  VARCHAR2
    , p1_a74  VARCHAR2
    , p1_a75  NUMBER
    , p1_a76  VARCHAR2
    , p1_a77  NUMBER
    , p1_a78  VARCHAR2
    , p1_a79  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_act_metric_rec ozf_actmetric_pvt.act_metric_rec_type;
    ddp_complete_rec ozf_actmetric_pvt.act_metric_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_act_metric_rec.activity_metric_id := p0_a0;
    ddp_act_metric_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_act_metric_rec.last_updated_by := p0_a2;
    ddp_act_metric_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_act_metric_rec.created_by := p0_a4;
    ddp_act_metric_rec.last_update_login := p0_a5;
    ddp_act_metric_rec.object_version_number := p0_a6;
    ddp_act_metric_rec.act_metric_used_by_id := p0_a7;
    ddp_act_metric_rec.arc_act_metric_used_by := p0_a8;
    ddp_act_metric_rec.purchase_req_raised_flag := p0_a9;
    ddp_act_metric_rec.application_id := p0_a10;
    ddp_act_metric_rec.sensitive_data_flag := p0_a11;
    ddp_act_metric_rec.budget_id := p0_a12;
    ddp_act_metric_rec.metric_id := p0_a13;
    ddp_act_metric_rec.transaction_currency_code := p0_a14;
    ddp_act_metric_rec.trans_forecasted_value := p0_a15;
    ddp_act_metric_rec.trans_committed_value := p0_a16;
    ddp_act_metric_rec.trans_actual_value := p0_a17;
    ddp_act_metric_rec.functional_currency_code := p0_a18;
    ddp_act_metric_rec.func_forecasted_value := p0_a19;
    ddp_act_metric_rec.dirty_flag := p0_a20;
    ddp_act_metric_rec.func_committed_value := p0_a21;
    ddp_act_metric_rec.func_actual_value := p0_a22;
    ddp_act_metric_rec.last_calculated_date := rosetta_g_miss_date_in_map(p0_a23);
    ddp_act_metric_rec.variable_value := p0_a24;
    ddp_act_metric_rec.computed_using_function_value := p0_a25;
    ddp_act_metric_rec.metric_uom_code := p0_a26;
    ddp_act_metric_rec.org_id := p0_a27;
    ddp_act_metric_rec.difference_since_last_calc := p0_a28;
    ddp_act_metric_rec.activity_metric_origin_id := p0_a29;
    ddp_act_metric_rec.arc_activity_metric_origin := p0_a30;
    ddp_act_metric_rec.days_since_last_refresh := p0_a31;
    ddp_act_metric_rec.scenario_id := p0_a32;
    ddp_act_metric_rec.summarize_to_metric := p0_a33;
    ddp_act_metric_rec.rollup_to_metric := p0_a34;
    ddp_act_metric_rec.hierarchy_id := p0_a35;
    ddp_act_metric_rec.start_node := p0_a36;
    ddp_act_metric_rec.from_level := p0_a37;
    ddp_act_metric_rec.to_level := p0_a38;
    ddp_act_metric_rec.from_date := rosetta_g_miss_date_in_map(p0_a39);
    ddp_act_metric_rec.to_date := rosetta_g_miss_date_in_map(p0_a40);
    ddp_act_metric_rec.amount1 := p0_a41;
    ddp_act_metric_rec.amount2 := p0_a42;
    ddp_act_metric_rec.amount3 := p0_a43;
    ddp_act_metric_rec.percent1 := p0_a44;
    ddp_act_metric_rec.percent2 := p0_a45;
    ddp_act_metric_rec.percent3 := p0_a46;
    ddp_act_metric_rec.published_flag := p0_a47;
    ddp_act_metric_rec.pre_function_name := p0_a48;
    ddp_act_metric_rec.post_function_name := p0_a49;
    ddp_act_metric_rec.attribute_category := p0_a50;
    ddp_act_metric_rec.attribute1 := p0_a51;
    ddp_act_metric_rec.attribute2 := p0_a52;
    ddp_act_metric_rec.attribute3 := p0_a53;
    ddp_act_metric_rec.attribute4 := p0_a54;
    ddp_act_metric_rec.attribute5 := p0_a55;
    ddp_act_metric_rec.attribute6 := p0_a56;
    ddp_act_metric_rec.attribute7 := p0_a57;
    ddp_act_metric_rec.attribute8 := p0_a58;
    ddp_act_metric_rec.attribute9 := p0_a59;
    ddp_act_metric_rec.attribute10 := p0_a60;
    ddp_act_metric_rec.attribute11 := p0_a61;
    ddp_act_metric_rec.attribute12 := p0_a62;
    ddp_act_metric_rec.attribute13 := p0_a63;
    ddp_act_metric_rec.attribute14 := p0_a64;
    ddp_act_metric_rec.attribute15 := p0_a65;
    ddp_act_metric_rec.description := p0_a66;
    ddp_act_metric_rec.act_metric_date := rosetta_g_miss_date_in_map(p0_a67);
    ddp_act_metric_rec.depend_act_metric := p0_a68;
    ddp_act_metric_rec.function_used_by_id := p0_a69;
    ddp_act_metric_rec.arc_function_used_by := p0_a70;
    ddp_act_metric_rec.hierarchy_type := p0_a71;
    ddp_act_metric_rec.status_code := p0_a72;
    ddp_act_metric_rec.method_code := p0_a73;
    ddp_act_metric_rec.action_code := p0_a74;
    ddp_act_metric_rec.basis_year := p0_a75;
    ddp_act_metric_rec.ex_start_node := p0_a76;
    ddp_act_metric_rec.product_spread_time_id := p0_a77;
    ddp_act_metric_rec.start_period_name := p0_a78;
    ddp_act_metric_rec.end_period_name := p0_a79;

    ddp_complete_rec.activity_metric_id := p1_a0;
    ddp_complete_rec.last_update_date := rosetta_g_miss_date_in_map(p1_a1);
    ddp_complete_rec.last_updated_by := p1_a2;
    ddp_complete_rec.creation_date := rosetta_g_miss_date_in_map(p1_a3);
    ddp_complete_rec.created_by := p1_a4;
    ddp_complete_rec.last_update_login := p1_a5;
    ddp_complete_rec.object_version_number := p1_a6;
    ddp_complete_rec.act_metric_used_by_id := p1_a7;
    ddp_complete_rec.arc_act_metric_used_by := p1_a8;
    ddp_complete_rec.purchase_req_raised_flag := p1_a9;
    ddp_complete_rec.application_id := p1_a10;
    ddp_complete_rec.sensitive_data_flag := p1_a11;
    ddp_complete_rec.budget_id := p1_a12;
    ddp_complete_rec.metric_id := p1_a13;
    ddp_complete_rec.transaction_currency_code := p1_a14;
    ddp_complete_rec.trans_forecasted_value := p1_a15;
    ddp_complete_rec.trans_committed_value := p1_a16;
    ddp_complete_rec.trans_actual_value := p1_a17;
    ddp_complete_rec.functional_currency_code := p1_a18;
    ddp_complete_rec.func_forecasted_value := p1_a19;
    ddp_complete_rec.dirty_flag := p1_a20;
    ddp_complete_rec.func_committed_value := p1_a21;
    ddp_complete_rec.func_actual_value := p1_a22;
    ddp_complete_rec.last_calculated_date := rosetta_g_miss_date_in_map(p1_a23);
    ddp_complete_rec.variable_value := p1_a24;
    ddp_complete_rec.computed_using_function_value := p1_a25;
    ddp_complete_rec.metric_uom_code := p1_a26;
    ddp_complete_rec.org_id := p1_a27;
    ddp_complete_rec.difference_since_last_calc := p1_a28;
    ddp_complete_rec.activity_metric_origin_id := p1_a29;
    ddp_complete_rec.arc_activity_metric_origin := p1_a30;
    ddp_complete_rec.days_since_last_refresh := p1_a31;
    ddp_complete_rec.scenario_id := p1_a32;
    ddp_complete_rec.summarize_to_metric := p1_a33;
    ddp_complete_rec.rollup_to_metric := p1_a34;
    ddp_complete_rec.hierarchy_id := p1_a35;
    ddp_complete_rec.start_node := p1_a36;
    ddp_complete_rec.from_level := p1_a37;
    ddp_complete_rec.to_level := p1_a38;
    ddp_complete_rec.from_date := rosetta_g_miss_date_in_map(p1_a39);
    ddp_complete_rec.to_date := rosetta_g_miss_date_in_map(p1_a40);
    ddp_complete_rec.amount1 := p1_a41;
    ddp_complete_rec.amount2 := p1_a42;
    ddp_complete_rec.amount3 := p1_a43;
    ddp_complete_rec.percent1 := p1_a44;
    ddp_complete_rec.percent2 := p1_a45;
    ddp_complete_rec.percent3 := p1_a46;
    ddp_complete_rec.published_flag := p1_a47;
    ddp_complete_rec.pre_function_name := p1_a48;
    ddp_complete_rec.post_function_name := p1_a49;
    ddp_complete_rec.attribute_category := p1_a50;
    ddp_complete_rec.attribute1 := p1_a51;
    ddp_complete_rec.attribute2 := p1_a52;
    ddp_complete_rec.attribute3 := p1_a53;
    ddp_complete_rec.attribute4 := p1_a54;
    ddp_complete_rec.attribute5 := p1_a55;
    ddp_complete_rec.attribute6 := p1_a56;
    ddp_complete_rec.attribute7 := p1_a57;
    ddp_complete_rec.attribute8 := p1_a58;
    ddp_complete_rec.attribute9 := p1_a59;
    ddp_complete_rec.attribute10 := p1_a60;
    ddp_complete_rec.attribute11 := p1_a61;
    ddp_complete_rec.attribute12 := p1_a62;
    ddp_complete_rec.attribute13 := p1_a63;
    ddp_complete_rec.attribute14 := p1_a64;
    ddp_complete_rec.attribute15 := p1_a65;
    ddp_complete_rec.description := p1_a66;
    ddp_complete_rec.act_metric_date := rosetta_g_miss_date_in_map(p1_a67);
    ddp_complete_rec.depend_act_metric := p1_a68;
    ddp_complete_rec.function_used_by_id := p1_a69;
    ddp_complete_rec.arc_function_used_by := p1_a70;
    ddp_complete_rec.hierarchy_type := p1_a71;
    ddp_complete_rec.status_code := p1_a72;
    ddp_complete_rec.method_code := p1_a73;
    ddp_complete_rec.action_code := p1_a74;
    ddp_complete_rec.basis_year := p1_a75;
    ddp_complete_rec.ex_start_node := p1_a76;
    ddp_complete_rec.product_spread_time_id := p1_a77;
    ddp_complete_rec.start_period_name := p1_a78;
    ddp_complete_rec.end_period_name := p1_a79;


    -- here's the delegated call to the old PL/SQL routine
    ozf_actmetric_pvt.validate_actmetric_record(ddp_act_metric_rec,
      ddp_complete_rec,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure complete_actmetric_rec(p0_a0  NUMBER
    , p0_a1  DATE
    , p0_a2  NUMBER
    , p0_a3  DATE
    , p0_a4  NUMBER
    , p0_a5  NUMBER
    , p0_a6  NUMBER
    , p0_a7  NUMBER
    , p0_a8  VARCHAR2
    , p0_a9  VARCHAR2
    , p0_a10  NUMBER
    , p0_a11  VARCHAR2
    , p0_a12  NUMBER
    , p0_a13  NUMBER
    , p0_a14  VARCHAR2
    , p0_a15  NUMBER
    , p0_a16  NUMBER
    , p0_a17  NUMBER
    , p0_a18  VARCHAR2
    , p0_a19  NUMBER
    , p0_a20  VARCHAR2
    , p0_a21  NUMBER
    , p0_a22  NUMBER
    , p0_a23  DATE
    , p0_a24  NUMBER
    , p0_a25  NUMBER
    , p0_a26  VARCHAR2
    , p0_a27  NUMBER
    , p0_a28  NUMBER
    , p0_a29  NUMBER
    , p0_a30  VARCHAR2
    , p0_a31  NUMBER
    , p0_a32  NUMBER
    , p0_a33  NUMBER
    , p0_a34  NUMBER
    , p0_a35  NUMBER
    , p0_a36  NUMBER
    , p0_a37  NUMBER
    , p0_a38  NUMBER
    , p0_a39  DATE
    , p0_a40  DATE
    , p0_a41  NUMBER
    , p0_a42  NUMBER
    , p0_a43  NUMBER
    , p0_a44  NUMBER
    , p0_a45  NUMBER
    , p0_a46  NUMBER
    , p0_a47  VARCHAR2
    , p0_a48  VARCHAR2
    , p0_a49  VARCHAR2
    , p0_a50  VARCHAR2
    , p0_a51  VARCHAR2
    , p0_a52  VARCHAR2
    , p0_a53  VARCHAR2
    , p0_a54  VARCHAR2
    , p0_a55  VARCHAR2
    , p0_a56  VARCHAR2
    , p0_a57  VARCHAR2
    , p0_a58  VARCHAR2
    , p0_a59  VARCHAR2
    , p0_a60  VARCHAR2
    , p0_a61  VARCHAR2
    , p0_a62  VARCHAR2
    , p0_a63  VARCHAR2
    , p0_a64  VARCHAR2
    , p0_a65  VARCHAR2
    , p0_a66  VARCHAR2
    , p0_a67  DATE
    , p0_a68  NUMBER
    , p0_a69  NUMBER
    , p0_a70  VARCHAR2
    , p0_a71  VARCHAR2
    , p0_a72  VARCHAR2
    , p0_a73  VARCHAR2
    , p0_a74  VARCHAR2
    , p0_a75  NUMBER
    , p0_a76  VARCHAR2
    , p0_a77  NUMBER
    , p0_a78  VARCHAR2
    , p0_a79  VARCHAR2
    , p1_a0 in out nocopy  NUMBER
    , p1_a1 in out nocopy  DATE
    , p1_a2 in out nocopy  NUMBER
    , p1_a3 in out nocopy  DATE
    , p1_a4 in out nocopy  NUMBER
    , p1_a5 in out nocopy  NUMBER
    , p1_a6 in out nocopy  NUMBER
    , p1_a7 in out nocopy  NUMBER
    , p1_a8 in out nocopy  VARCHAR2
    , p1_a9 in out nocopy  VARCHAR2
    , p1_a10 in out nocopy  NUMBER
    , p1_a11 in out nocopy  VARCHAR2
    , p1_a12 in out nocopy  NUMBER
    , p1_a13 in out nocopy  NUMBER
    , p1_a14 in out nocopy  VARCHAR2
    , p1_a15 in out nocopy  NUMBER
    , p1_a16 in out nocopy  NUMBER
    , p1_a17 in out nocopy  NUMBER
    , p1_a18 in out nocopy  VARCHAR2
    , p1_a19 in out nocopy  NUMBER
    , p1_a20 in out nocopy  VARCHAR2
    , p1_a21 in out nocopy  NUMBER
    , p1_a22 in out nocopy  NUMBER
    , p1_a23 in out nocopy  DATE
    , p1_a24 in out nocopy  NUMBER
    , p1_a25 in out nocopy  NUMBER
    , p1_a26 in out nocopy  VARCHAR2
    , p1_a27 in out nocopy  NUMBER
    , p1_a28 in out nocopy  NUMBER
    , p1_a29 in out nocopy  NUMBER
    , p1_a30 in out nocopy  VARCHAR2
    , p1_a31 in out nocopy  NUMBER
    , p1_a32 in out nocopy  NUMBER
    , p1_a33 in out nocopy  NUMBER
    , p1_a34 in out nocopy  NUMBER
    , p1_a35 in out nocopy  NUMBER
    , p1_a36 in out nocopy  NUMBER
    , p1_a37 in out nocopy  NUMBER
    , p1_a38 in out nocopy  NUMBER
    , p1_a39 in out nocopy  DATE
    , p1_a40 in out nocopy  DATE
    , p1_a41 in out nocopy  NUMBER
    , p1_a42 in out nocopy  NUMBER
    , p1_a43 in out nocopy  NUMBER
    , p1_a44 in out nocopy  NUMBER
    , p1_a45 in out nocopy  NUMBER
    , p1_a46 in out nocopy  NUMBER
    , p1_a47 in out nocopy  VARCHAR2
    , p1_a48 in out nocopy  VARCHAR2
    , p1_a49 in out nocopy  VARCHAR2
    , p1_a50 in out nocopy  VARCHAR2
    , p1_a51 in out nocopy  VARCHAR2
    , p1_a52 in out nocopy  VARCHAR2
    , p1_a53 in out nocopy  VARCHAR2
    , p1_a54 in out nocopy  VARCHAR2
    , p1_a55 in out nocopy  VARCHAR2
    , p1_a56 in out nocopy  VARCHAR2
    , p1_a57 in out nocopy  VARCHAR2
    , p1_a58 in out nocopy  VARCHAR2
    , p1_a59 in out nocopy  VARCHAR2
    , p1_a60 in out nocopy  VARCHAR2
    , p1_a61 in out nocopy  VARCHAR2
    , p1_a62 in out nocopy  VARCHAR2
    , p1_a63 in out nocopy  VARCHAR2
    , p1_a64 in out nocopy  VARCHAR2
    , p1_a65 in out nocopy  VARCHAR2
    , p1_a66 in out nocopy  VARCHAR2
    , p1_a67 in out nocopy  DATE
    , p1_a68 in out nocopy  NUMBER
    , p1_a69 in out nocopy  NUMBER
    , p1_a70 in out nocopy  VARCHAR2
    , p1_a71 in out nocopy  VARCHAR2
    , p1_a72 in out nocopy  VARCHAR2
    , p1_a73 in out nocopy  VARCHAR2
    , p1_a74 in out nocopy  VARCHAR2
    , p1_a75 in out nocopy  NUMBER
    , p1_a76 in out nocopy  VARCHAR2
    , p1_a77 in out nocopy  NUMBER
    , p1_a78 in out nocopy  VARCHAR2
    , p1_a79 in out nocopy  VARCHAR2
  )

  as
    ddp_act_metric_rec ozf_actmetric_pvt.act_metric_rec_type;
    ddx_complete_rec ozf_actmetric_pvt.act_metric_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_act_metric_rec.activity_metric_id := p0_a0;
    ddp_act_metric_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_act_metric_rec.last_updated_by := p0_a2;
    ddp_act_metric_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_act_metric_rec.created_by := p0_a4;
    ddp_act_metric_rec.last_update_login := p0_a5;
    ddp_act_metric_rec.object_version_number := p0_a6;
    ddp_act_metric_rec.act_metric_used_by_id := p0_a7;
    ddp_act_metric_rec.arc_act_metric_used_by := p0_a8;
    ddp_act_metric_rec.purchase_req_raised_flag := p0_a9;
    ddp_act_metric_rec.application_id := p0_a10;
    ddp_act_metric_rec.sensitive_data_flag := p0_a11;
    ddp_act_metric_rec.budget_id := p0_a12;
    ddp_act_metric_rec.metric_id := p0_a13;
    ddp_act_metric_rec.transaction_currency_code := p0_a14;
    ddp_act_metric_rec.trans_forecasted_value := p0_a15;
    ddp_act_metric_rec.trans_committed_value := p0_a16;
    ddp_act_metric_rec.trans_actual_value := p0_a17;
    ddp_act_metric_rec.functional_currency_code := p0_a18;
    ddp_act_metric_rec.func_forecasted_value := p0_a19;
    ddp_act_metric_rec.dirty_flag := p0_a20;
    ddp_act_metric_rec.func_committed_value := p0_a21;
    ddp_act_metric_rec.func_actual_value := p0_a22;
    ddp_act_metric_rec.last_calculated_date := rosetta_g_miss_date_in_map(p0_a23);
    ddp_act_metric_rec.variable_value := p0_a24;
    ddp_act_metric_rec.computed_using_function_value := p0_a25;
    ddp_act_metric_rec.metric_uom_code := p0_a26;
    ddp_act_metric_rec.org_id := p0_a27;
    ddp_act_metric_rec.difference_since_last_calc := p0_a28;
    ddp_act_metric_rec.activity_metric_origin_id := p0_a29;
    ddp_act_metric_rec.arc_activity_metric_origin := p0_a30;
    ddp_act_metric_rec.days_since_last_refresh := p0_a31;
    ddp_act_metric_rec.scenario_id := p0_a32;
    ddp_act_metric_rec.summarize_to_metric := p0_a33;
    ddp_act_metric_rec.rollup_to_metric := p0_a34;
    ddp_act_metric_rec.hierarchy_id := p0_a35;
    ddp_act_metric_rec.start_node := p0_a36;
    ddp_act_metric_rec.from_level := p0_a37;
    ddp_act_metric_rec.to_level := p0_a38;
    ddp_act_metric_rec.from_date := rosetta_g_miss_date_in_map(p0_a39);
    ddp_act_metric_rec.to_date := rosetta_g_miss_date_in_map(p0_a40);
    ddp_act_metric_rec.amount1 := p0_a41;
    ddp_act_metric_rec.amount2 := p0_a42;
    ddp_act_metric_rec.amount3 := p0_a43;
    ddp_act_metric_rec.percent1 := p0_a44;
    ddp_act_metric_rec.percent2 := p0_a45;
    ddp_act_metric_rec.percent3 := p0_a46;
    ddp_act_metric_rec.published_flag := p0_a47;
    ddp_act_metric_rec.pre_function_name := p0_a48;
    ddp_act_metric_rec.post_function_name := p0_a49;
    ddp_act_metric_rec.attribute_category := p0_a50;
    ddp_act_metric_rec.attribute1 := p0_a51;
    ddp_act_metric_rec.attribute2 := p0_a52;
    ddp_act_metric_rec.attribute3 := p0_a53;
    ddp_act_metric_rec.attribute4 := p0_a54;
    ddp_act_metric_rec.attribute5 := p0_a55;
    ddp_act_metric_rec.attribute6 := p0_a56;
    ddp_act_metric_rec.attribute7 := p0_a57;
    ddp_act_metric_rec.attribute8 := p0_a58;
    ddp_act_metric_rec.attribute9 := p0_a59;
    ddp_act_metric_rec.attribute10 := p0_a60;
    ddp_act_metric_rec.attribute11 := p0_a61;
    ddp_act_metric_rec.attribute12 := p0_a62;
    ddp_act_metric_rec.attribute13 := p0_a63;
    ddp_act_metric_rec.attribute14 := p0_a64;
    ddp_act_metric_rec.attribute15 := p0_a65;
    ddp_act_metric_rec.description := p0_a66;
    ddp_act_metric_rec.act_metric_date := rosetta_g_miss_date_in_map(p0_a67);
    ddp_act_metric_rec.depend_act_metric := p0_a68;
    ddp_act_metric_rec.function_used_by_id := p0_a69;
    ddp_act_metric_rec.arc_function_used_by := p0_a70;
    ddp_act_metric_rec.hierarchy_type := p0_a71;
    ddp_act_metric_rec.status_code := p0_a72;
    ddp_act_metric_rec.method_code := p0_a73;
    ddp_act_metric_rec.action_code := p0_a74;
    ddp_act_metric_rec.basis_year := p0_a75;
    ddp_act_metric_rec.ex_start_node := p0_a76;
    ddp_act_metric_rec.product_spread_time_id := p0_a77;
    ddp_act_metric_rec.start_period_name := p0_a78;
    ddp_act_metric_rec.end_period_name := p0_a79;

    ddx_complete_rec.activity_metric_id := p1_a0;
    ddx_complete_rec.last_update_date := rosetta_g_miss_date_in_map(p1_a1);
    ddx_complete_rec.last_updated_by := p1_a2;
    ddx_complete_rec.creation_date := rosetta_g_miss_date_in_map(p1_a3);
    ddx_complete_rec.created_by := p1_a4;
    ddx_complete_rec.last_update_login := p1_a5;
    ddx_complete_rec.object_version_number := p1_a6;
    ddx_complete_rec.act_metric_used_by_id := p1_a7;
    ddx_complete_rec.arc_act_metric_used_by := p1_a8;
    ddx_complete_rec.purchase_req_raised_flag := p1_a9;
    ddx_complete_rec.application_id := p1_a10;
    ddx_complete_rec.sensitive_data_flag := p1_a11;
    ddx_complete_rec.budget_id := p1_a12;
    ddx_complete_rec.metric_id := p1_a13;
    ddx_complete_rec.transaction_currency_code := p1_a14;
    ddx_complete_rec.trans_forecasted_value := p1_a15;
    ddx_complete_rec.trans_committed_value := p1_a16;
    ddx_complete_rec.trans_actual_value := p1_a17;
    ddx_complete_rec.functional_currency_code := p1_a18;
    ddx_complete_rec.func_forecasted_value := p1_a19;
    ddx_complete_rec.dirty_flag := p1_a20;
    ddx_complete_rec.func_committed_value := p1_a21;
    ddx_complete_rec.func_actual_value := p1_a22;
    ddx_complete_rec.last_calculated_date := rosetta_g_miss_date_in_map(p1_a23);
    ddx_complete_rec.variable_value := p1_a24;
    ddx_complete_rec.computed_using_function_value := p1_a25;
    ddx_complete_rec.metric_uom_code := p1_a26;
    ddx_complete_rec.org_id := p1_a27;
    ddx_complete_rec.difference_since_last_calc := p1_a28;
    ddx_complete_rec.activity_metric_origin_id := p1_a29;
    ddx_complete_rec.arc_activity_metric_origin := p1_a30;
    ddx_complete_rec.days_since_last_refresh := p1_a31;
    ddx_complete_rec.scenario_id := p1_a32;
    ddx_complete_rec.summarize_to_metric := p1_a33;
    ddx_complete_rec.rollup_to_metric := p1_a34;
    ddx_complete_rec.hierarchy_id := p1_a35;
    ddx_complete_rec.start_node := p1_a36;
    ddx_complete_rec.from_level := p1_a37;
    ddx_complete_rec.to_level := p1_a38;
    ddx_complete_rec.from_date := rosetta_g_miss_date_in_map(p1_a39);
    ddx_complete_rec.to_date := rosetta_g_miss_date_in_map(p1_a40);
    ddx_complete_rec.amount1 := p1_a41;
    ddx_complete_rec.amount2 := p1_a42;
    ddx_complete_rec.amount3 := p1_a43;
    ddx_complete_rec.percent1 := p1_a44;
    ddx_complete_rec.percent2 := p1_a45;
    ddx_complete_rec.percent3 := p1_a46;
    ddx_complete_rec.published_flag := p1_a47;
    ddx_complete_rec.pre_function_name := p1_a48;
    ddx_complete_rec.post_function_name := p1_a49;
    ddx_complete_rec.attribute_category := p1_a50;
    ddx_complete_rec.attribute1 := p1_a51;
    ddx_complete_rec.attribute2 := p1_a52;
    ddx_complete_rec.attribute3 := p1_a53;
    ddx_complete_rec.attribute4 := p1_a54;
    ddx_complete_rec.attribute5 := p1_a55;
    ddx_complete_rec.attribute6 := p1_a56;
    ddx_complete_rec.attribute7 := p1_a57;
    ddx_complete_rec.attribute8 := p1_a58;
    ddx_complete_rec.attribute9 := p1_a59;
    ddx_complete_rec.attribute10 := p1_a60;
    ddx_complete_rec.attribute11 := p1_a61;
    ddx_complete_rec.attribute12 := p1_a62;
    ddx_complete_rec.attribute13 := p1_a63;
    ddx_complete_rec.attribute14 := p1_a64;
    ddx_complete_rec.attribute15 := p1_a65;
    ddx_complete_rec.description := p1_a66;
    ddx_complete_rec.act_metric_date := rosetta_g_miss_date_in_map(p1_a67);
    ddx_complete_rec.depend_act_metric := p1_a68;
    ddx_complete_rec.function_used_by_id := p1_a69;
    ddx_complete_rec.arc_function_used_by := p1_a70;
    ddx_complete_rec.hierarchy_type := p1_a71;
    ddx_complete_rec.status_code := p1_a72;
    ddx_complete_rec.method_code := p1_a73;
    ddx_complete_rec.action_code := p1_a74;
    ddx_complete_rec.basis_year := p1_a75;
    ddx_complete_rec.ex_start_node := p1_a76;
    ddx_complete_rec.product_spread_time_id := p1_a77;
    ddx_complete_rec.start_period_name := p1_a78;
    ddx_complete_rec.end_period_name := p1_a79;

    -- here's the delegated call to the old PL/SQL routine
    ozf_actmetric_pvt.complete_actmetric_rec(ddp_act_metric_rec,
      ddx_complete_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    p1_a0 := ddx_complete_rec.activity_metric_id;
    p1_a1 := ddx_complete_rec.last_update_date;
    p1_a2 := ddx_complete_rec.last_updated_by;
    p1_a3 := ddx_complete_rec.creation_date;
    p1_a4 := ddx_complete_rec.created_by;
    p1_a5 := ddx_complete_rec.last_update_login;
    p1_a6 := ddx_complete_rec.object_version_number;
    p1_a7 := ddx_complete_rec.act_metric_used_by_id;
    p1_a8 := ddx_complete_rec.arc_act_metric_used_by;
    p1_a9 := ddx_complete_rec.purchase_req_raised_flag;
    p1_a10 := ddx_complete_rec.application_id;
    p1_a11 := ddx_complete_rec.sensitive_data_flag;
    p1_a12 := ddx_complete_rec.budget_id;
    p1_a13 := ddx_complete_rec.metric_id;
    p1_a14 := ddx_complete_rec.transaction_currency_code;
    p1_a15 := ddx_complete_rec.trans_forecasted_value;
    p1_a16 := ddx_complete_rec.trans_committed_value;
    p1_a17 := ddx_complete_rec.trans_actual_value;
    p1_a18 := ddx_complete_rec.functional_currency_code;
    p1_a19 := ddx_complete_rec.func_forecasted_value;
    p1_a20 := ddx_complete_rec.dirty_flag;
    p1_a21 := ddx_complete_rec.func_committed_value;
    p1_a22 := ddx_complete_rec.func_actual_value;
    p1_a23 := ddx_complete_rec.last_calculated_date;
    p1_a24 := ddx_complete_rec.variable_value;
    p1_a25 := ddx_complete_rec.computed_using_function_value;
    p1_a26 := ddx_complete_rec.metric_uom_code;
    p1_a27 := ddx_complete_rec.org_id;
    p1_a28 := ddx_complete_rec.difference_since_last_calc;
    p1_a29 := ddx_complete_rec.activity_metric_origin_id;
    p1_a30 := ddx_complete_rec.arc_activity_metric_origin;
    p1_a31 := ddx_complete_rec.days_since_last_refresh;
    p1_a32 := ddx_complete_rec.scenario_id;
    p1_a33 := ddx_complete_rec.summarize_to_metric;
    p1_a34 := ddx_complete_rec.rollup_to_metric;
    p1_a35 := ddx_complete_rec.hierarchy_id;
    p1_a36 := ddx_complete_rec.start_node;
    p1_a37 := ddx_complete_rec.from_level;
    p1_a38 := ddx_complete_rec.to_level;
    p1_a39 := ddx_complete_rec.from_date;
    p1_a40 := ddx_complete_rec.to_date;
    p1_a41 := ddx_complete_rec.amount1;
    p1_a42 := ddx_complete_rec.amount2;
    p1_a43 := ddx_complete_rec.amount3;
    p1_a44 := ddx_complete_rec.percent1;
    p1_a45 := ddx_complete_rec.percent2;
    p1_a46 := ddx_complete_rec.percent3;
    p1_a47 := ddx_complete_rec.published_flag;
    p1_a48 := ddx_complete_rec.pre_function_name;
    p1_a49 := ddx_complete_rec.post_function_name;
    p1_a50 := ddx_complete_rec.attribute_category;
    p1_a51 := ddx_complete_rec.attribute1;
    p1_a52 := ddx_complete_rec.attribute2;
    p1_a53 := ddx_complete_rec.attribute3;
    p1_a54 := ddx_complete_rec.attribute4;
    p1_a55 := ddx_complete_rec.attribute5;
    p1_a56 := ddx_complete_rec.attribute6;
    p1_a57 := ddx_complete_rec.attribute7;
    p1_a58 := ddx_complete_rec.attribute8;
    p1_a59 := ddx_complete_rec.attribute9;
    p1_a60 := ddx_complete_rec.attribute10;
    p1_a61 := ddx_complete_rec.attribute11;
    p1_a62 := ddx_complete_rec.attribute12;
    p1_a63 := ddx_complete_rec.attribute13;
    p1_a64 := ddx_complete_rec.attribute14;
    p1_a65 := ddx_complete_rec.attribute15;
    p1_a66 := ddx_complete_rec.description;
    p1_a67 := ddx_complete_rec.act_metric_date;
    p1_a68 := ddx_complete_rec.depend_act_metric;
    p1_a69 := ddx_complete_rec.function_used_by_id;
    p1_a70 := ddx_complete_rec.arc_function_used_by;
    p1_a71 := ddx_complete_rec.hierarchy_type;
    p1_a72 := ddx_complete_rec.status_code;
    p1_a73 := ddx_complete_rec.method_code;
    p1_a74 := ddx_complete_rec.action_code;
    p1_a75 := ddx_complete_rec.basis_year;
    p1_a76 := ddx_complete_rec.ex_start_node;
    p1_a77 := ddx_complete_rec.product_spread_time_id;
    p1_a78 := ddx_complete_rec.start_period_name;
    p1_a79 := ddx_complete_rec.end_period_name;
  end;

end ozf_actmetric_pvt_w;

/
