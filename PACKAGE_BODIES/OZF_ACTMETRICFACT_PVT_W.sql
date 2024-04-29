--------------------------------------------------------
--  DDL for Package Body OZF_ACTMETRICFACT_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_ACTMETRICFACT_PVT_W" as
  /* $Header: ozfwamfb.pls 120.2 2006/06/02 09:50:18 inanaiah ship $ */
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

  procedure init_actmetricfact_rec(p0_a0 out nocopy  NUMBER
    , p0_a1 out nocopy  DATE
    , p0_a2 out nocopy  NUMBER
    , p0_a3 out nocopy  DATE
    , p0_a4 out nocopy  NUMBER
    , p0_a5 out nocopy  NUMBER
    , p0_a6 out nocopy  NUMBER
    , p0_a7 out nocopy  NUMBER
    , p0_a8 out nocopy  VARCHAR2
    , p0_a9 out nocopy  VARCHAR2
    , p0_a10 out nocopy  NUMBER
    , p0_a11 out nocopy  NUMBER
    , p0_a12 out nocopy  NUMBER
    , p0_a13 out nocopy  VARCHAR2
    , p0_a14 out nocopy  NUMBER
    , p0_a15 out nocopy  NUMBER
    , p0_a16 out nocopy  VARCHAR2
    , p0_a17 out nocopy  NUMBER
    , p0_a18 out nocopy  NUMBER
    , p0_a19 out nocopy  NUMBER
    , p0_a20 out nocopy  NUMBER
    , p0_a21 out nocopy  VARCHAR2
    , p0_a22 out nocopy  NUMBER
    , p0_a23 out nocopy  NUMBER
    , p0_a24 out nocopy  NUMBER
    , p0_a25 out nocopy  NUMBER
    , p0_a26 out nocopy  NUMBER
    , p0_a27 out nocopy  NUMBER
    , p0_a28 out nocopy  NUMBER
    , p0_a29 out nocopy  NUMBER
    , p0_a30 out nocopy  NUMBER
    , p0_a31 out nocopy  NUMBER
    , p0_a32 out nocopy  NUMBER
    , p0_a33 out nocopy  NUMBER
    , p0_a34 out nocopy  NUMBER
    , p0_a35 out nocopy  NUMBER
    , p0_a36 out nocopy  NUMBER
    , p0_a37 out nocopy  NUMBER
    , p0_a38 out nocopy  NUMBER
    , p0_a39 out nocopy  NUMBER
    , p0_a40 out nocopy  NUMBER
    , p0_a41 out nocopy  NUMBER
    , p0_a42 out nocopy  NUMBER
    , p0_a43 out nocopy  NUMBER
    , p0_a44 out nocopy  NUMBER
    , p0_a45 out nocopy  NUMBER
    , p0_a46 out nocopy  NUMBER
    , p0_a47 out nocopy  NUMBER
    , p0_a48 out nocopy  NUMBER
    , p0_a49 out nocopy  NUMBER
    , p0_a50 out nocopy  NUMBER
    , p0_a51 out nocopy  NUMBER
    , p0_a52 out nocopy  NUMBER
    , p0_a53 out nocopy  NUMBER
    , p0_a54 out nocopy  NUMBER
    , p0_a55 out nocopy  NUMBER
    , p0_a56 out nocopy  NUMBER
    , p0_a57 out nocopy  NUMBER
    , p0_a58 out nocopy  NUMBER
    , p0_a59 out nocopy  NUMBER
    , p0_a60 out nocopy  NUMBER
    , p0_a61 out nocopy  NUMBER
    , p0_a62 out nocopy  NUMBER
    , p0_a63 out nocopy  NUMBER
    , p0_a64 out nocopy  NUMBER
    , p0_a65 out nocopy  NUMBER
    , p0_a66 out nocopy  NUMBER
    , p0_a67 out nocopy  NUMBER
    , p0_a68 out nocopy  NUMBER
    , p0_a69 out nocopy  NUMBER
    , p0_a70 out nocopy  NUMBER
    , p0_a71 out nocopy  NUMBER
    , p0_a72 out nocopy  NUMBER
    , p0_a73 out nocopy  NUMBER
    , p0_a74 out nocopy  NUMBER
    , p0_a75 out nocopy  NUMBER
    , p0_a76 out nocopy  NUMBER
    , p0_a77 out nocopy  NUMBER
    , p0_a78 out nocopy  NUMBER
    , p0_a79 out nocopy  NUMBER
    , p0_a80 out nocopy  NUMBER
    , p0_a81 out nocopy  DATE
    , p0_a82 out nocopy  DATE
    , p0_a83 out nocopy  NUMBER
    , p0_a84 out nocopy  NUMBER
    , p0_a85 out nocopy  NUMBER
    , p0_a86 out nocopy  NUMBER
    , p0_a87 out nocopy  VARCHAR2
    , p0_a88 out nocopy  VARCHAR2
    , p0_a89 out nocopy  NUMBER
    , p0_a90 out nocopy  VARCHAR2
    , p0_a91 out nocopy  VARCHAR2
    , p0_a92 out nocopy  DATE
    , p0_a93 out nocopy  NUMBER
    , p0_a94 out nocopy  NUMBER
    , p0_a95 out nocopy  NUMBER
    , p0_a96 out nocopy  NUMBER
    , p0_a97 out nocopy  NUMBER
    , p0_a98 out nocopy  NUMBER
    , p0_a99 out nocopy  NUMBER
    , p0_a100 out nocopy  NUMBER
    , p0_a101 out nocopy  NUMBER
    , p0_a102 out nocopy  NUMBER
    , p0_a103 out nocopy  NUMBER
    , p0_a104 out nocopy  NUMBER
  )

  as
    ddx_fact_rec ozf_actmetricfact_pvt.act_metric_fact_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    -- here's the delegated call to the old PL/SQL routine
    ozf_actmetricfact_pvt.init_actmetricfact_rec(ddx_fact_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    p0_a0 := ddx_fact_rec.activity_metric_fact_id;
    p0_a1 := ddx_fact_rec.last_update_date;
    p0_a2 := ddx_fact_rec.last_updated_by;
    p0_a3 := ddx_fact_rec.creation_date;
    p0_a4 := ddx_fact_rec.created_by;
    p0_a5 := ddx_fact_rec.last_update_login;
    p0_a6 := ddx_fact_rec.object_version_number;
    p0_a7 := ddx_fact_rec.act_metric_used_by_id;
    p0_a8 := ddx_fact_rec.arc_act_metric_used_by;
    p0_a9 := ddx_fact_rec.value_type;
    p0_a10 := ddx_fact_rec.activity_metric_id;
    p0_a11 := ddx_fact_rec.activity_geo_area_id;
    p0_a12 := ddx_fact_rec.activity_product_id;
    p0_a13 := ddx_fact_rec.transaction_currency_code;
    p0_a14 := ddx_fact_rec.trans_forecasted_value;
    p0_a15 := ddx_fact_rec.base_quantity;
    p0_a16 := ddx_fact_rec.functional_currency_code;
    p0_a17 := ddx_fact_rec.func_forecasted_value;
    p0_a18 := ddx_fact_rec.org_id;
    p0_a19 := ddx_fact_rec.de_metric_id;
    p0_a20 := ddx_fact_rec.de_geographic_area_id;
    p0_a21 := ddx_fact_rec.de_geographic_area_type;
    p0_a22 := ddx_fact_rec.de_inventory_item_id;
    p0_a23 := ddx_fact_rec.de_inventory_item_org_id;
    p0_a24 := ddx_fact_rec.time_id1;
    p0_a25 := ddx_fact_rec.time_id2;
    p0_a26 := ddx_fact_rec.time_id3;
    p0_a27 := ddx_fact_rec.time_id4;
    p0_a28 := ddx_fact_rec.time_id5;
    p0_a29 := ddx_fact_rec.time_id6;
    p0_a30 := ddx_fact_rec.time_id7;
    p0_a31 := ddx_fact_rec.time_id8;
    p0_a32 := ddx_fact_rec.time_id9;
    p0_a33 := ddx_fact_rec.time_id10;
    p0_a34 := ddx_fact_rec.time_id11;
    p0_a35 := ddx_fact_rec.time_id12;
    p0_a36 := ddx_fact_rec.time_id13;
    p0_a37 := ddx_fact_rec.time_id14;
    p0_a38 := ddx_fact_rec.time_id15;
    p0_a39 := ddx_fact_rec.time_id16;
    p0_a40 := ddx_fact_rec.time_id17;
    p0_a41 := ddx_fact_rec.time_id18;
    p0_a42 := ddx_fact_rec.time_id19;
    p0_a43 := ddx_fact_rec.time_id20;
    p0_a44 := ddx_fact_rec.time_id21;
    p0_a45 := ddx_fact_rec.time_id22;
    p0_a46 := ddx_fact_rec.time_id23;
    p0_a47 := ddx_fact_rec.time_id24;
    p0_a48 := ddx_fact_rec.time_id25;
    p0_a49 := ddx_fact_rec.time_id26;
    p0_a50 := ddx_fact_rec.time_id27;
    p0_a51 := ddx_fact_rec.time_id28;
    p0_a52 := ddx_fact_rec.time_id29;
    p0_a53 := ddx_fact_rec.time_id30;
    p0_a54 := ddx_fact_rec.time_id31;
    p0_a55 := ddx_fact_rec.time_id32;
    p0_a56 := ddx_fact_rec.time_id33;
    p0_a57 := ddx_fact_rec.time_id34;
    p0_a58 := ddx_fact_rec.time_id35;
    p0_a59 := ddx_fact_rec.time_id36;
    p0_a60 := ddx_fact_rec.time_id37;
    p0_a61 := ddx_fact_rec.time_id38;
    p0_a62 := ddx_fact_rec.time_id39;
    p0_a63 := ddx_fact_rec.time_id40;
    p0_a64 := ddx_fact_rec.time_id41;
    p0_a65 := ddx_fact_rec.time_id42;
    p0_a66 := ddx_fact_rec.time_id43;
    p0_a67 := ddx_fact_rec.time_id44;
    p0_a68 := ddx_fact_rec.time_id45;
    p0_a69 := ddx_fact_rec.time_id46;
    p0_a70 := ddx_fact_rec.time_id47;
    p0_a71 := ddx_fact_rec.time_id48;
    p0_a72 := ddx_fact_rec.time_id49;
    p0_a73 := ddx_fact_rec.time_id50;
    p0_a74 := ddx_fact_rec.time_id51;
    p0_a75 := ddx_fact_rec.time_id52;
    p0_a76 := ddx_fact_rec.time_id53;
    p0_a77 := ddx_fact_rec.hierarchy_id;
    p0_a78 := ddx_fact_rec.node_id;
    p0_a79 := ddx_fact_rec.level_depth;
    p0_a80 := ddx_fact_rec.formula_id;
    p0_a81 := ddx_fact_rec.from_date;
    p0_a82 := ddx_fact_rec.to_date;
    p0_a83 := ddx_fact_rec.fact_value;
    p0_a84 := ddx_fact_rec.fact_percent;
    p0_a85 := ddx_fact_rec.root_fact_id;
    p0_a86 := ddx_fact_rec.previous_fact_id;
    p0_a87 := ddx_fact_rec.fact_type;
    p0_a88 := ddx_fact_rec.fact_reference;
    p0_a89 := ddx_fact_rec.forward_buy_quantity;
    p0_a90 := ddx_fact_rec.status_code;
    p0_a91 := ddx_fact_rec.hierarchy_type;
    p0_a92 := ddx_fact_rec.approval_date;
    p0_a93 := ddx_fact_rec.recommend_total_amount;
    p0_a94 := ddx_fact_rec.recommend_hb_amount;
    p0_a95 := ddx_fact_rec.request_total_amount;
    p0_a96 := ddx_fact_rec.request_hb_amount;
    p0_a97 := ddx_fact_rec.actual_total_amount;
    p0_a98 := ddx_fact_rec.actual_hb_amount;
    p0_a99 := ddx_fact_rec.base_total_pct;
    p0_a100 := ddx_fact_rec.base_hb_pct;
    p0_a101 := ddx_fact_rec.baseline_sales;
    p0_a102 := ddx_fact_rec.tpr_percent;
    p0_a103 := ddx_fact_rec.lift_factor;
    p0_a104 := ddx_fact_rec.incremental_sales;
  end;

  procedure create_actmetricfact(p_api_version  NUMBER
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
    , p7_a11  NUMBER
    , p7_a12  NUMBER
    , p7_a13  VARCHAR2
    , p7_a14  NUMBER
    , p7_a15  NUMBER
    , p7_a16  VARCHAR2
    , p7_a17  NUMBER
    , p7_a18  NUMBER
    , p7_a19  NUMBER
    , p7_a20  NUMBER
    , p7_a21  VARCHAR2
    , p7_a22  NUMBER
    , p7_a23  NUMBER
    , p7_a24  NUMBER
    , p7_a25  NUMBER
    , p7_a26  NUMBER
    , p7_a27  NUMBER
    , p7_a28  NUMBER
    , p7_a29  NUMBER
    , p7_a30  NUMBER
    , p7_a31  NUMBER
    , p7_a32  NUMBER
    , p7_a33  NUMBER
    , p7_a34  NUMBER
    , p7_a35  NUMBER
    , p7_a36  NUMBER
    , p7_a37  NUMBER
    , p7_a38  NUMBER
    , p7_a39  NUMBER
    , p7_a40  NUMBER
    , p7_a41  NUMBER
    , p7_a42  NUMBER
    , p7_a43  NUMBER
    , p7_a44  NUMBER
    , p7_a45  NUMBER
    , p7_a46  NUMBER
    , p7_a47  NUMBER
    , p7_a48  NUMBER
    , p7_a49  NUMBER
    , p7_a50  NUMBER
    , p7_a51  NUMBER
    , p7_a52  NUMBER
    , p7_a53  NUMBER
    , p7_a54  NUMBER
    , p7_a55  NUMBER
    , p7_a56  NUMBER
    , p7_a57  NUMBER
    , p7_a58  NUMBER
    , p7_a59  NUMBER
    , p7_a60  NUMBER
    , p7_a61  NUMBER
    , p7_a62  NUMBER
    , p7_a63  NUMBER
    , p7_a64  NUMBER
    , p7_a65  NUMBER
    , p7_a66  NUMBER
    , p7_a67  NUMBER
    , p7_a68  NUMBER
    , p7_a69  NUMBER
    , p7_a70  NUMBER
    , p7_a71  NUMBER
    , p7_a72  NUMBER
    , p7_a73  NUMBER
    , p7_a74  NUMBER
    , p7_a75  NUMBER
    , p7_a76  NUMBER
    , p7_a77  NUMBER
    , p7_a78  NUMBER
    , p7_a79  NUMBER
    , p7_a80  NUMBER
    , p7_a81  DATE
    , p7_a82  DATE
    , p7_a83  NUMBER
    , p7_a84  NUMBER
    , p7_a85  NUMBER
    , p7_a86  NUMBER
    , p7_a87  VARCHAR2
    , p7_a88  VARCHAR2
    , p7_a89  NUMBER
    , p7_a90  VARCHAR2
    , p7_a91  VARCHAR2
    , p7_a92  DATE
    , p7_a93  NUMBER
    , p7_a94  NUMBER
    , p7_a95  NUMBER
    , p7_a96  NUMBER
    , p7_a97  NUMBER
    , p7_a98  NUMBER
    , p7_a99  NUMBER
    , p7_a100  NUMBER
    , p7_a101  NUMBER
    , p7_a102  NUMBER
    , p7_a103  NUMBER
    , p7_a104  NUMBER
    , x_activity_metric_fact_id out nocopy  NUMBER
  )

  as
    ddp_act_metric_fact_rec ozf_actmetricfact_pvt.act_metric_fact_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_act_metric_fact_rec.activity_metric_fact_id := p7_a0;
    ddp_act_metric_fact_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_act_metric_fact_rec.last_updated_by := p7_a2;
    ddp_act_metric_fact_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_act_metric_fact_rec.created_by := p7_a4;
    ddp_act_metric_fact_rec.last_update_login := p7_a5;
    ddp_act_metric_fact_rec.object_version_number := p7_a6;
    ddp_act_metric_fact_rec.act_metric_used_by_id := p7_a7;
    ddp_act_metric_fact_rec.arc_act_metric_used_by := p7_a8;
    ddp_act_metric_fact_rec.value_type := p7_a9;
    ddp_act_metric_fact_rec.activity_metric_id := p7_a10;
    ddp_act_metric_fact_rec.activity_geo_area_id := p7_a11;
    ddp_act_metric_fact_rec.activity_product_id := p7_a12;
    ddp_act_metric_fact_rec.transaction_currency_code := p7_a13;
    ddp_act_metric_fact_rec.trans_forecasted_value := p7_a14;
    ddp_act_metric_fact_rec.base_quantity := p7_a15;
    ddp_act_metric_fact_rec.functional_currency_code := p7_a16;
    ddp_act_metric_fact_rec.func_forecasted_value := p7_a17;
    ddp_act_metric_fact_rec.org_id := p7_a18;
    ddp_act_metric_fact_rec.de_metric_id := p7_a19;
    ddp_act_metric_fact_rec.de_geographic_area_id := p7_a20;
    ddp_act_metric_fact_rec.de_geographic_area_type := p7_a21;
    ddp_act_metric_fact_rec.de_inventory_item_id := p7_a22;
    ddp_act_metric_fact_rec.de_inventory_item_org_id := p7_a23;
    ddp_act_metric_fact_rec.time_id1 := p7_a24;
    ddp_act_metric_fact_rec.time_id2 := p7_a25;
    ddp_act_metric_fact_rec.time_id3 := p7_a26;
    ddp_act_metric_fact_rec.time_id4 := p7_a27;
    ddp_act_metric_fact_rec.time_id5 := p7_a28;
    ddp_act_metric_fact_rec.time_id6 := p7_a29;
    ddp_act_metric_fact_rec.time_id7 := p7_a30;
    ddp_act_metric_fact_rec.time_id8 := p7_a31;
    ddp_act_metric_fact_rec.time_id9 := p7_a32;
    ddp_act_metric_fact_rec.time_id10 := p7_a33;
    ddp_act_metric_fact_rec.time_id11 := p7_a34;
    ddp_act_metric_fact_rec.time_id12 := p7_a35;
    ddp_act_metric_fact_rec.time_id13 := p7_a36;
    ddp_act_metric_fact_rec.time_id14 := p7_a37;
    ddp_act_metric_fact_rec.time_id15 := p7_a38;
    ddp_act_metric_fact_rec.time_id16 := p7_a39;
    ddp_act_metric_fact_rec.time_id17 := p7_a40;
    ddp_act_metric_fact_rec.time_id18 := p7_a41;
    ddp_act_metric_fact_rec.time_id19 := p7_a42;
    ddp_act_metric_fact_rec.time_id20 := p7_a43;
    ddp_act_metric_fact_rec.time_id21 := p7_a44;
    ddp_act_metric_fact_rec.time_id22 := p7_a45;
    ddp_act_metric_fact_rec.time_id23 := p7_a46;
    ddp_act_metric_fact_rec.time_id24 := p7_a47;
    ddp_act_metric_fact_rec.time_id25 := p7_a48;
    ddp_act_metric_fact_rec.time_id26 := p7_a49;
    ddp_act_metric_fact_rec.time_id27 := p7_a50;
    ddp_act_metric_fact_rec.time_id28 := p7_a51;
    ddp_act_metric_fact_rec.time_id29 := p7_a52;
    ddp_act_metric_fact_rec.time_id30 := p7_a53;
    ddp_act_metric_fact_rec.time_id31 := p7_a54;
    ddp_act_metric_fact_rec.time_id32 := p7_a55;
    ddp_act_metric_fact_rec.time_id33 := p7_a56;
    ddp_act_metric_fact_rec.time_id34 := p7_a57;
    ddp_act_metric_fact_rec.time_id35 := p7_a58;
    ddp_act_metric_fact_rec.time_id36 := p7_a59;
    ddp_act_metric_fact_rec.time_id37 := p7_a60;
    ddp_act_metric_fact_rec.time_id38 := p7_a61;
    ddp_act_metric_fact_rec.time_id39 := p7_a62;
    ddp_act_metric_fact_rec.time_id40 := p7_a63;
    ddp_act_metric_fact_rec.time_id41 := p7_a64;
    ddp_act_metric_fact_rec.time_id42 := p7_a65;
    ddp_act_metric_fact_rec.time_id43 := p7_a66;
    ddp_act_metric_fact_rec.time_id44 := p7_a67;
    ddp_act_metric_fact_rec.time_id45 := p7_a68;
    ddp_act_metric_fact_rec.time_id46 := p7_a69;
    ddp_act_metric_fact_rec.time_id47 := p7_a70;
    ddp_act_metric_fact_rec.time_id48 := p7_a71;
    ddp_act_metric_fact_rec.time_id49 := p7_a72;
    ddp_act_metric_fact_rec.time_id50 := p7_a73;
    ddp_act_metric_fact_rec.time_id51 := p7_a74;
    ddp_act_metric_fact_rec.time_id52 := p7_a75;
    ddp_act_metric_fact_rec.time_id53 := p7_a76;
    ddp_act_metric_fact_rec.hierarchy_id := p7_a77;
    ddp_act_metric_fact_rec.node_id := p7_a78;
    ddp_act_metric_fact_rec.level_depth := p7_a79;
    ddp_act_metric_fact_rec.formula_id := p7_a80;
    ddp_act_metric_fact_rec.from_date := rosetta_g_miss_date_in_map(p7_a81);
    ddp_act_metric_fact_rec.to_date := rosetta_g_miss_date_in_map(p7_a82);
    ddp_act_metric_fact_rec.fact_value := p7_a83;
    ddp_act_metric_fact_rec.fact_percent := p7_a84;
    ddp_act_metric_fact_rec.root_fact_id := p7_a85;
    ddp_act_metric_fact_rec.previous_fact_id := p7_a86;
    ddp_act_metric_fact_rec.fact_type := p7_a87;
    ddp_act_metric_fact_rec.fact_reference := p7_a88;
    ddp_act_metric_fact_rec.forward_buy_quantity := p7_a89;
    ddp_act_metric_fact_rec.status_code := p7_a90;
    ddp_act_metric_fact_rec.hierarchy_type := p7_a91;
    ddp_act_metric_fact_rec.approval_date := rosetta_g_miss_date_in_map(p7_a92);
    ddp_act_metric_fact_rec.recommend_total_amount := p7_a93;
    ddp_act_metric_fact_rec.recommend_hb_amount := p7_a94;
    ddp_act_metric_fact_rec.request_total_amount := p7_a95;
    ddp_act_metric_fact_rec.request_hb_amount := p7_a96;
    ddp_act_metric_fact_rec.actual_total_amount := p7_a97;
    ddp_act_metric_fact_rec.actual_hb_amount := p7_a98;
    ddp_act_metric_fact_rec.base_total_pct := p7_a99;
    ddp_act_metric_fact_rec.base_hb_pct := p7_a100;
    ddp_act_metric_fact_rec.baseline_sales := p7_a101;
    ddp_act_metric_fact_rec.tpr_percent := p7_a102;
    ddp_act_metric_fact_rec.lift_factor := p7_a103;
    ddp_act_metric_fact_rec.incremental_sales := p7_a104;


    -- here's the delegated call to the old PL/SQL routine
    ozf_actmetricfact_pvt.create_actmetricfact(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_act_metric_fact_rec,
      x_activity_metric_fact_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_actmetricfact(p_api_version  NUMBER
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
    , p7_a11  NUMBER
    , p7_a12  NUMBER
    , p7_a13  VARCHAR2
    , p7_a14  NUMBER
    , p7_a15  NUMBER
    , p7_a16  VARCHAR2
    , p7_a17  NUMBER
    , p7_a18  NUMBER
    , p7_a19  NUMBER
    , p7_a20  NUMBER
    , p7_a21  VARCHAR2
    , p7_a22  NUMBER
    , p7_a23  NUMBER
    , p7_a24  NUMBER
    , p7_a25  NUMBER
    , p7_a26  NUMBER
    , p7_a27  NUMBER
    , p7_a28  NUMBER
    , p7_a29  NUMBER
    , p7_a30  NUMBER
    , p7_a31  NUMBER
    , p7_a32  NUMBER
    , p7_a33  NUMBER
    , p7_a34  NUMBER
    , p7_a35  NUMBER
    , p7_a36  NUMBER
    , p7_a37  NUMBER
    , p7_a38  NUMBER
    , p7_a39  NUMBER
    , p7_a40  NUMBER
    , p7_a41  NUMBER
    , p7_a42  NUMBER
    , p7_a43  NUMBER
    , p7_a44  NUMBER
    , p7_a45  NUMBER
    , p7_a46  NUMBER
    , p7_a47  NUMBER
    , p7_a48  NUMBER
    , p7_a49  NUMBER
    , p7_a50  NUMBER
    , p7_a51  NUMBER
    , p7_a52  NUMBER
    , p7_a53  NUMBER
    , p7_a54  NUMBER
    , p7_a55  NUMBER
    , p7_a56  NUMBER
    , p7_a57  NUMBER
    , p7_a58  NUMBER
    , p7_a59  NUMBER
    , p7_a60  NUMBER
    , p7_a61  NUMBER
    , p7_a62  NUMBER
    , p7_a63  NUMBER
    , p7_a64  NUMBER
    , p7_a65  NUMBER
    , p7_a66  NUMBER
    , p7_a67  NUMBER
    , p7_a68  NUMBER
    , p7_a69  NUMBER
    , p7_a70  NUMBER
    , p7_a71  NUMBER
    , p7_a72  NUMBER
    , p7_a73  NUMBER
    , p7_a74  NUMBER
    , p7_a75  NUMBER
    , p7_a76  NUMBER
    , p7_a77  NUMBER
    , p7_a78  NUMBER
    , p7_a79  NUMBER
    , p7_a80  NUMBER
    , p7_a81  DATE
    , p7_a82  DATE
    , p7_a83  NUMBER
    , p7_a84  NUMBER
    , p7_a85  NUMBER
    , p7_a86  NUMBER
    , p7_a87  VARCHAR2
    , p7_a88  VARCHAR2
    , p7_a89  NUMBER
    , p7_a90  VARCHAR2
    , p7_a91  VARCHAR2
    , p7_a92  DATE
    , p7_a93  NUMBER
    , p7_a94  NUMBER
    , p7_a95  NUMBER
    , p7_a96  NUMBER
    , p7_a97  NUMBER
    , p7_a98  NUMBER
    , p7_a99  NUMBER
    , p7_a100  NUMBER
    , p7_a101  NUMBER
    , p7_a102  NUMBER
    , p7_a103  NUMBER
    , p7_a104  NUMBER
  )

  as
    ddp_act_metric_fact_rec ozf_actmetricfact_pvt.act_metric_fact_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_act_metric_fact_rec.activity_metric_fact_id := p7_a0;
    ddp_act_metric_fact_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_act_metric_fact_rec.last_updated_by := p7_a2;
    ddp_act_metric_fact_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_act_metric_fact_rec.created_by := p7_a4;
    ddp_act_metric_fact_rec.last_update_login := p7_a5;
    ddp_act_metric_fact_rec.object_version_number := p7_a6;
    ddp_act_metric_fact_rec.act_metric_used_by_id := p7_a7;
    ddp_act_metric_fact_rec.arc_act_metric_used_by := p7_a8;
    ddp_act_metric_fact_rec.value_type := p7_a9;
    ddp_act_metric_fact_rec.activity_metric_id := p7_a10;
    ddp_act_metric_fact_rec.activity_geo_area_id := p7_a11;
    ddp_act_metric_fact_rec.activity_product_id := p7_a12;
    ddp_act_metric_fact_rec.transaction_currency_code := p7_a13;
    ddp_act_metric_fact_rec.trans_forecasted_value := p7_a14;
    ddp_act_metric_fact_rec.base_quantity := p7_a15;
    ddp_act_metric_fact_rec.functional_currency_code := p7_a16;
    ddp_act_metric_fact_rec.func_forecasted_value := p7_a17;
    ddp_act_metric_fact_rec.org_id := p7_a18;
    ddp_act_metric_fact_rec.de_metric_id := p7_a19;
    ddp_act_metric_fact_rec.de_geographic_area_id := p7_a20;
    ddp_act_metric_fact_rec.de_geographic_area_type := p7_a21;
    ddp_act_metric_fact_rec.de_inventory_item_id := p7_a22;
    ddp_act_metric_fact_rec.de_inventory_item_org_id := p7_a23;
    ddp_act_metric_fact_rec.time_id1 := p7_a24;
    ddp_act_metric_fact_rec.time_id2 := p7_a25;
    ddp_act_metric_fact_rec.time_id3 := p7_a26;
    ddp_act_metric_fact_rec.time_id4 := p7_a27;
    ddp_act_metric_fact_rec.time_id5 := p7_a28;
    ddp_act_metric_fact_rec.time_id6 := p7_a29;
    ddp_act_metric_fact_rec.time_id7 := p7_a30;
    ddp_act_metric_fact_rec.time_id8 := p7_a31;
    ddp_act_metric_fact_rec.time_id9 := p7_a32;
    ddp_act_metric_fact_rec.time_id10 := p7_a33;
    ddp_act_metric_fact_rec.time_id11 := p7_a34;
    ddp_act_metric_fact_rec.time_id12 := p7_a35;
    ddp_act_metric_fact_rec.time_id13 := p7_a36;
    ddp_act_metric_fact_rec.time_id14 := p7_a37;
    ddp_act_metric_fact_rec.time_id15 := p7_a38;
    ddp_act_metric_fact_rec.time_id16 := p7_a39;
    ddp_act_metric_fact_rec.time_id17 := p7_a40;
    ddp_act_metric_fact_rec.time_id18 := p7_a41;
    ddp_act_metric_fact_rec.time_id19 := p7_a42;
    ddp_act_metric_fact_rec.time_id20 := p7_a43;
    ddp_act_metric_fact_rec.time_id21 := p7_a44;
    ddp_act_metric_fact_rec.time_id22 := p7_a45;
    ddp_act_metric_fact_rec.time_id23 := p7_a46;
    ddp_act_metric_fact_rec.time_id24 := p7_a47;
    ddp_act_metric_fact_rec.time_id25 := p7_a48;
    ddp_act_metric_fact_rec.time_id26 := p7_a49;
    ddp_act_metric_fact_rec.time_id27 := p7_a50;
    ddp_act_metric_fact_rec.time_id28 := p7_a51;
    ddp_act_metric_fact_rec.time_id29 := p7_a52;
    ddp_act_metric_fact_rec.time_id30 := p7_a53;
    ddp_act_metric_fact_rec.time_id31 := p7_a54;
    ddp_act_metric_fact_rec.time_id32 := p7_a55;
    ddp_act_metric_fact_rec.time_id33 := p7_a56;
    ddp_act_metric_fact_rec.time_id34 := p7_a57;
    ddp_act_metric_fact_rec.time_id35 := p7_a58;
    ddp_act_metric_fact_rec.time_id36 := p7_a59;
    ddp_act_metric_fact_rec.time_id37 := p7_a60;
    ddp_act_metric_fact_rec.time_id38 := p7_a61;
    ddp_act_metric_fact_rec.time_id39 := p7_a62;
    ddp_act_metric_fact_rec.time_id40 := p7_a63;
    ddp_act_metric_fact_rec.time_id41 := p7_a64;
    ddp_act_metric_fact_rec.time_id42 := p7_a65;
    ddp_act_metric_fact_rec.time_id43 := p7_a66;
    ddp_act_metric_fact_rec.time_id44 := p7_a67;
    ddp_act_metric_fact_rec.time_id45 := p7_a68;
    ddp_act_metric_fact_rec.time_id46 := p7_a69;
    ddp_act_metric_fact_rec.time_id47 := p7_a70;
    ddp_act_metric_fact_rec.time_id48 := p7_a71;
    ddp_act_metric_fact_rec.time_id49 := p7_a72;
    ddp_act_metric_fact_rec.time_id50 := p7_a73;
    ddp_act_metric_fact_rec.time_id51 := p7_a74;
    ddp_act_metric_fact_rec.time_id52 := p7_a75;
    ddp_act_metric_fact_rec.time_id53 := p7_a76;
    ddp_act_metric_fact_rec.hierarchy_id := p7_a77;
    ddp_act_metric_fact_rec.node_id := p7_a78;
    ddp_act_metric_fact_rec.level_depth := p7_a79;
    ddp_act_metric_fact_rec.formula_id := p7_a80;
    ddp_act_metric_fact_rec.from_date := rosetta_g_miss_date_in_map(p7_a81);
    ddp_act_metric_fact_rec.to_date := rosetta_g_miss_date_in_map(p7_a82);
    ddp_act_metric_fact_rec.fact_value := p7_a83;
    ddp_act_metric_fact_rec.fact_percent := p7_a84;
    ddp_act_metric_fact_rec.root_fact_id := p7_a85;
    ddp_act_metric_fact_rec.previous_fact_id := p7_a86;
    ddp_act_metric_fact_rec.fact_type := p7_a87;
    ddp_act_metric_fact_rec.fact_reference := p7_a88;
    ddp_act_metric_fact_rec.forward_buy_quantity := p7_a89;
    ddp_act_metric_fact_rec.status_code := p7_a90;
    ddp_act_metric_fact_rec.hierarchy_type := p7_a91;
    ddp_act_metric_fact_rec.approval_date := rosetta_g_miss_date_in_map(p7_a92);
    ddp_act_metric_fact_rec.recommend_total_amount := p7_a93;
    ddp_act_metric_fact_rec.recommend_hb_amount := p7_a94;
    ddp_act_metric_fact_rec.request_total_amount := p7_a95;
    ddp_act_metric_fact_rec.request_hb_amount := p7_a96;
    ddp_act_metric_fact_rec.actual_total_amount := p7_a97;
    ddp_act_metric_fact_rec.actual_hb_amount := p7_a98;
    ddp_act_metric_fact_rec.base_total_pct := p7_a99;
    ddp_act_metric_fact_rec.base_hb_pct := p7_a100;
    ddp_act_metric_fact_rec.baseline_sales := p7_a101;
    ddp_act_metric_fact_rec.tpr_percent := p7_a102;
    ddp_act_metric_fact_rec.lift_factor := p7_a103;
    ddp_act_metric_fact_rec.incremental_sales := p7_a104;

    -- here's the delegated call to the old PL/SQL routine
    ozf_actmetricfact_pvt.update_actmetricfact(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_act_metric_fact_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure validate_actmetfact(p_api_version  NUMBER
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
    , p6_a11  NUMBER
    , p6_a12  NUMBER
    , p6_a13  VARCHAR2
    , p6_a14  NUMBER
    , p6_a15  NUMBER
    , p6_a16  VARCHAR2
    , p6_a17  NUMBER
    , p6_a18  NUMBER
    , p6_a19  NUMBER
    , p6_a20  NUMBER
    , p6_a21  VARCHAR2
    , p6_a22  NUMBER
    , p6_a23  NUMBER
    , p6_a24  NUMBER
    , p6_a25  NUMBER
    , p6_a26  NUMBER
    , p6_a27  NUMBER
    , p6_a28  NUMBER
    , p6_a29  NUMBER
    , p6_a30  NUMBER
    , p6_a31  NUMBER
    , p6_a32  NUMBER
    , p6_a33  NUMBER
    , p6_a34  NUMBER
    , p6_a35  NUMBER
    , p6_a36  NUMBER
    , p6_a37  NUMBER
    , p6_a38  NUMBER
    , p6_a39  NUMBER
    , p6_a40  NUMBER
    , p6_a41  NUMBER
    , p6_a42  NUMBER
    , p6_a43  NUMBER
    , p6_a44  NUMBER
    , p6_a45  NUMBER
    , p6_a46  NUMBER
    , p6_a47  NUMBER
    , p6_a48  NUMBER
    , p6_a49  NUMBER
    , p6_a50  NUMBER
    , p6_a51  NUMBER
    , p6_a52  NUMBER
    , p6_a53  NUMBER
    , p6_a54  NUMBER
    , p6_a55  NUMBER
    , p6_a56  NUMBER
    , p6_a57  NUMBER
    , p6_a58  NUMBER
    , p6_a59  NUMBER
    , p6_a60  NUMBER
    , p6_a61  NUMBER
    , p6_a62  NUMBER
    , p6_a63  NUMBER
    , p6_a64  NUMBER
    , p6_a65  NUMBER
    , p6_a66  NUMBER
    , p6_a67  NUMBER
    , p6_a68  NUMBER
    , p6_a69  NUMBER
    , p6_a70  NUMBER
    , p6_a71  NUMBER
    , p6_a72  NUMBER
    , p6_a73  NUMBER
    , p6_a74  NUMBER
    , p6_a75  NUMBER
    , p6_a76  NUMBER
    , p6_a77  NUMBER
    , p6_a78  NUMBER
    , p6_a79  NUMBER
    , p6_a80  NUMBER
    , p6_a81  DATE
    , p6_a82  DATE
    , p6_a83  NUMBER
    , p6_a84  NUMBER
    , p6_a85  NUMBER
    , p6_a86  NUMBER
    , p6_a87  VARCHAR2
    , p6_a88  VARCHAR2
    , p6_a89  NUMBER
    , p6_a90  VARCHAR2
    , p6_a91  VARCHAR2
    , p6_a92  DATE
    , p6_a93  NUMBER
    , p6_a94  NUMBER
    , p6_a95  NUMBER
    , p6_a96  NUMBER
    , p6_a97  NUMBER
    , p6_a98  NUMBER
    , p6_a99  NUMBER
    , p6_a100  NUMBER
    , p6_a101  NUMBER
    , p6_a102  NUMBER
    , p6_a103  NUMBER
    , p6_a104  NUMBER
  )

  as
    ddp_act_metric_fact_rec ozf_actmetricfact_pvt.act_metric_fact_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_act_metric_fact_rec.activity_metric_fact_id := p6_a0;
    ddp_act_metric_fact_rec.last_update_date := rosetta_g_miss_date_in_map(p6_a1);
    ddp_act_metric_fact_rec.last_updated_by := p6_a2;
    ddp_act_metric_fact_rec.creation_date := rosetta_g_miss_date_in_map(p6_a3);
    ddp_act_metric_fact_rec.created_by := p6_a4;
    ddp_act_metric_fact_rec.last_update_login := p6_a5;
    ddp_act_metric_fact_rec.object_version_number := p6_a6;
    ddp_act_metric_fact_rec.act_metric_used_by_id := p6_a7;
    ddp_act_metric_fact_rec.arc_act_metric_used_by := p6_a8;
    ddp_act_metric_fact_rec.value_type := p6_a9;
    ddp_act_metric_fact_rec.activity_metric_id := p6_a10;
    ddp_act_metric_fact_rec.activity_geo_area_id := p6_a11;
    ddp_act_metric_fact_rec.activity_product_id := p6_a12;
    ddp_act_metric_fact_rec.transaction_currency_code := p6_a13;
    ddp_act_metric_fact_rec.trans_forecasted_value := p6_a14;
    ddp_act_metric_fact_rec.base_quantity := p6_a15;
    ddp_act_metric_fact_rec.functional_currency_code := p6_a16;
    ddp_act_metric_fact_rec.func_forecasted_value := p6_a17;
    ddp_act_metric_fact_rec.org_id := p6_a18;
    ddp_act_metric_fact_rec.de_metric_id := p6_a19;
    ddp_act_metric_fact_rec.de_geographic_area_id := p6_a20;
    ddp_act_metric_fact_rec.de_geographic_area_type := p6_a21;
    ddp_act_metric_fact_rec.de_inventory_item_id := p6_a22;
    ddp_act_metric_fact_rec.de_inventory_item_org_id := p6_a23;
    ddp_act_metric_fact_rec.time_id1 := p6_a24;
    ddp_act_metric_fact_rec.time_id2 := p6_a25;
    ddp_act_metric_fact_rec.time_id3 := p6_a26;
    ddp_act_metric_fact_rec.time_id4 := p6_a27;
    ddp_act_metric_fact_rec.time_id5 := p6_a28;
    ddp_act_metric_fact_rec.time_id6 := p6_a29;
    ddp_act_metric_fact_rec.time_id7 := p6_a30;
    ddp_act_metric_fact_rec.time_id8 := p6_a31;
    ddp_act_metric_fact_rec.time_id9 := p6_a32;
    ddp_act_metric_fact_rec.time_id10 := p6_a33;
    ddp_act_metric_fact_rec.time_id11 := p6_a34;
    ddp_act_metric_fact_rec.time_id12 := p6_a35;
    ddp_act_metric_fact_rec.time_id13 := p6_a36;
    ddp_act_metric_fact_rec.time_id14 := p6_a37;
    ddp_act_metric_fact_rec.time_id15 := p6_a38;
    ddp_act_metric_fact_rec.time_id16 := p6_a39;
    ddp_act_metric_fact_rec.time_id17 := p6_a40;
    ddp_act_metric_fact_rec.time_id18 := p6_a41;
    ddp_act_metric_fact_rec.time_id19 := p6_a42;
    ddp_act_metric_fact_rec.time_id20 := p6_a43;
    ddp_act_metric_fact_rec.time_id21 := p6_a44;
    ddp_act_metric_fact_rec.time_id22 := p6_a45;
    ddp_act_metric_fact_rec.time_id23 := p6_a46;
    ddp_act_metric_fact_rec.time_id24 := p6_a47;
    ddp_act_metric_fact_rec.time_id25 := p6_a48;
    ddp_act_metric_fact_rec.time_id26 := p6_a49;
    ddp_act_metric_fact_rec.time_id27 := p6_a50;
    ddp_act_metric_fact_rec.time_id28 := p6_a51;
    ddp_act_metric_fact_rec.time_id29 := p6_a52;
    ddp_act_metric_fact_rec.time_id30 := p6_a53;
    ddp_act_metric_fact_rec.time_id31 := p6_a54;
    ddp_act_metric_fact_rec.time_id32 := p6_a55;
    ddp_act_metric_fact_rec.time_id33 := p6_a56;
    ddp_act_metric_fact_rec.time_id34 := p6_a57;
    ddp_act_metric_fact_rec.time_id35 := p6_a58;
    ddp_act_metric_fact_rec.time_id36 := p6_a59;
    ddp_act_metric_fact_rec.time_id37 := p6_a60;
    ddp_act_metric_fact_rec.time_id38 := p6_a61;
    ddp_act_metric_fact_rec.time_id39 := p6_a62;
    ddp_act_metric_fact_rec.time_id40 := p6_a63;
    ddp_act_metric_fact_rec.time_id41 := p6_a64;
    ddp_act_metric_fact_rec.time_id42 := p6_a65;
    ddp_act_metric_fact_rec.time_id43 := p6_a66;
    ddp_act_metric_fact_rec.time_id44 := p6_a67;
    ddp_act_metric_fact_rec.time_id45 := p6_a68;
    ddp_act_metric_fact_rec.time_id46 := p6_a69;
    ddp_act_metric_fact_rec.time_id47 := p6_a70;
    ddp_act_metric_fact_rec.time_id48 := p6_a71;
    ddp_act_metric_fact_rec.time_id49 := p6_a72;
    ddp_act_metric_fact_rec.time_id50 := p6_a73;
    ddp_act_metric_fact_rec.time_id51 := p6_a74;
    ddp_act_metric_fact_rec.time_id52 := p6_a75;
    ddp_act_metric_fact_rec.time_id53 := p6_a76;
    ddp_act_metric_fact_rec.hierarchy_id := p6_a77;
    ddp_act_metric_fact_rec.node_id := p6_a78;
    ddp_act_metric_fact_rec.level_depth := p6_a79;
    ddp_act_metric_fact_rec.formula_id := p6_a80;
    ddp_act_metric_fact_rec.from_date := rosetta_g_miss_date_in_map(p6_a81);
    ddp_act_metric_fact_rec.to_date := rosetta_g_miss_date_in_map(p6_a82);
    ddp_act_metric_fact_rec.fact_value := p6_a83;
    ddp_act_metric_fact_rec.fact_percent := p6_a84;
    ddp_act_metric_fact_rec.root_fact_id := p6_a85;
    ddp_act_metric_fact_rec.previous_fact_id := p6_a86;
    ddp_act_metric_fact_rec.fact_type := p6_a87;
    ddp_act_metric_fact_rec.fact_reference := p6_a88;
    ddp_act_metric_fact_rec.forward_buy_quantity := p6_a89;
    ddp_act_metric_fact_rec.status_code := p6_a90;
    ddp_act_metric_fact_rec.hierarchy_type := p6_a91;
    ddp_act_metric_fact_rec.approval_date := rosetta_g_miss_date_in_map(p6_a92);
    ddp_act_metric_fact_rec.recommend_total_amount := p6_a93;
    ddp_act_metric_fact_rec.recommend_hb_amount := p6_a94;
    ddp_act_metric_fact_rec.request_total_amount := p6_a95;
    ddp_act_metric_fact_rec.request_hb_amount := p6_a96;
    ddp_act_metric_fact_rec.actual_total_amount := p6_a97;
    ddp_act_metric_fact_rec.actual_hb_amount := p6_a98;
    ddp_act_metric_fact_rec.base_total_pct := p6_a99;
    ddp_act_metric_fact_rec.base_hb_pct := p6_a100;
    ddp_act_metric_fact_rec.baseline_sales := p6_a101;
    ddp_act_metric_fact_rec.tpr_percent := p6_a102;
    ddp_act_metric_fact_rec.lift_factor := p6_a103;
    ddp_act_metric_fact_rec.incremental_sales := p6_a104;

    -- here's the delegated call to the old PL/SQL routine
    ozf_actmetricfact_pvt.validate_actmetfact(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_act_metric_fact_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure validate_actmetfact_items(p0_a0  NUMBER
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
    , p0_a11  NUMBER
    , p0_a12  NUMBER
    , p0_a13  VARCHAR2
    , p0_a14  NUMBER
    , p0_a15  NUMBER
    , p0_a16  VARCHAR2
    , p0_a17  NUMBER
    , p0_a18  NUMBER
    , p0_a19  NUMBER
    , p0_a20  NUMBER
    , p0_a21  VARCHAR2
    , p0_a22  NUMBER
    , p0_a23  NUMBER
    , p0_a24  NUMBER
    , p0_a25  NUMBER
    , p0_a26  NUMBER
    , p0_a27  NUMBER
    , p0_a28  NUMBER
    , p0_a29  NUMBER
    , p0_a30  NUMBER
    , p0_a31  NUMBER
    , p0_a32  NUMBER
    , p0_a33  NUMBER
    , p0_a34  NUMBER
    , p0_a35  NUMBER
    , p0_a36  NUMBER
    , p0_a37  NUMBER
    , p0_a38  NUMBER
    , p0_a39  NUMBER
    , p0_a40  NUMBER
    , p0_a41  NUMBER
    , p0_a42  NUMBER
    , p0_a43  NUMBER
    , p0_a44  NUMBER
    , p0_a45  NUMBER
    , p0_a46  NUMBER
    , p0_a47  NUMBER
    , p0_a48  NUMBER
    , p0_a49  NUMBER
    , p0_a50  NUMBER
    , p0_a51  NUMBER
    , p0_a52  NUMBER
    , p0_a53  NUMBER
    , p0_a54  NUMBER
    , p0_a55  NUMBER
    , p0_a56  NUMBER
    , p0_a57  NUMBER
    , p0_a58  NUMBER
    , p0_a59  NUMBER
    , p0_a60  NUMBER
    , p0_a61  NUMBER
    , p0_a62  NUMBER
    , p0_a63  NUMBER
    , p0_a64  NUMBER
    , p0_a65  NUMBER
    , p0_a66  NUMBER
    , p0_a67  NUMBER
    , p0_a68  NUMBER
    , p0_a69  NUMBER
    , p0_a70  NUMBER
    , p0_a71  NUMBER
    , p0_a72  NUMBER
    , p0_a73  NUMBER
    , p0_a74  NUMBER
    , p0_a75  NUMBER
    , p0_a76  NUMBER
    , p0_a77  NUMBER
    , p0_a78  NUMBER
    , p0_a79  NUMBER
    , p0_a80  NUMBER
    , p0_a81  DATE
    , p0_a82  DATE
    , p0_a83  NUMBER
    , p0_a84  NUMBER
    , p0_a85  NUMBER
    , p0_a86  NUMBER
    , p0_a87  VARCHAR2
    , p0_a88  VARCHAR2
    , p0_a89  NUMBER
    , p0_a90  VARCHAR2
    , p0_a91  VARCHAR2
    , p0_a92  DATE
    , p0_a93  NUMBER
    , p0_a94  NUMBER
    , p0_a95  NUMBER
    , p0_a96  NUMBER
    , p0_a97  NUMBER
    , p0_a98  NUMBER
    , p0_a99  NUMBER
    , p0_a100  NUMBER
    , p0_a101  NUMBER
    , p0_a102  NUMBER
    , p0_a103  NUMBER
    , p0_a104  NUMBER
    , p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_act_metric_fact_rec ozf_actmetricfact_pvt.act_metric_fact_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_act_metric_fact_rec.activity_metric_fact_id := p0_a0;
    ddp_act_metric_fact_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_act_metric_fact_rec.last_updated_by := p0_a2;
    ddp_act_metric_fact_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_act_metric_fact_rec.created_by := p0_a4;
    ddp_act_metric_fact_rec.last_update_login := p0_a5;
    ddp_act_metric_fact_rec.object_version_number := p0_a6;
    ddp_act_metric_fact_rec.act_metric_used_by_id := p0_a7;
    ddp_act_metric_fact_rec.arc_act_metric_used_by := p0_a8;
    ddp_act_metric_fact_rec.value_type := p0_a9;
    ddp_act_metric_fact_rec.activity_metric_id := p0_a10;
    ddp_act_metric_fact_rec.activity_geo_area_id := p0_a11;
    ddp_act_metric_fact_rec.activity_product_id := p0_a12;
    ddp_act_metric_fact_rec.transaction_currency_code := p0_a13;
    ddp_act_metric_fact_rec.trans_forecasted_value := p0_a14;
    ddp_act_metric_fact_rec.base_quantity := p0_a15;
    ddp_act_metric_fact_rec.functional_currency_code := p0_a16;
    ddp_act_metric_fact_rec.func_forecasted_value := p0_a17;
    ddp_act_metric_fact_rec.org_id := p0_a18;
    ddp_act_metric_fact_rec.de_metric_id := p0_a19;
    ddp_act_metric_fact_rec.de_geographic_area_id := p0_a20;
    ddp_act_metric_fact_rec.de_geographic_area_type := p0_a21;
    ddp_act_metric_fact_rec.de_inventory_item_id := p0_a22;
    ddp_act_metric_fact_rec.de_inventory_item_org_id := p0_a23;
    ddp_act_metric_fact_rec.time_id1 := p0_a24;
    ddp_act_metric_fact_rec.time_id2 := p0_a25;
    ddp_act_metric_fact_rec.time_id3 := p0_a26;
    ddp_act_metric_fact_rec.time_id4 := p0_a27;
    ddp_act_metric_fact_rec.time_id5 := p0_a28;
    ddp_act_metric_fact_rec.time_id6 := p0_a29;
    ddp_act_metric_fact_rec.time_id7 := p0_a30;
    ddp_act_metric_fact_rec.time_id8 := p0_a31;
    ddp_act_metric_fact_rec.time_id9 := p0_a32;
    ddp_act_metric_fact_rec.time_id10 := p0_a33;
    ddp_act_metric_fact_rec.time_id11 := p0_a34;
    ddp_act_metric_fact_rec.time_id12 := p0_a35;
    ddp_act_metric_fact_rec.time_id13 := p0_a36;
    ddp_act_metric_fact_rec.time_id14 := p0_a37;
    ddp_act_metric_fact_rec.time_id15 := p0_a38;
    ddp_act_metric_fact_rec.time_id16 := p0_a39;
    ddp_act_metric_fact_rec.time_id17 := p0_a40;
    ddp_act_metric_fact_rec.time_id18 := p0_a41;
    ddp_act_metric_fact_rec.time_id19 := p0_a42;
    ddp_act_metric_fact_rec.time_id20 := p0_a43;
    ddp_act_metric_fact_rec.time_id21 := p0_a44;
    ddp_act_metric_fact_rec.time_id22 := p0_a45;
    ddp_act_metric_fact_rec.time_id23 := p0_a46;
    ddp_act_metric_fact_rec.time_id24 := p0_a47;
    ddp_act_metric_fact_rec.time_id25 := p0_a48;
    ddp_act_metric_fact_rec.time_id26 := p0_a49;
    ddp_act_metric_fact_rec.time_id27 := p0_a50;
    ddp_act_metric_fact_rec.time_id28 := p0_a51;
    ddp_act_metric_fact_rec.time_id29 := p0_a52;
    ddp_act_metric_fact_rec.time_id30 := p0_a53;
    ddp_act_metric_fact_rec.time_id31 := p0_a54;
    ddp_act_metric_fact_rec.time_id32 := p0_a55;
    ddp_act_metric_fact_rec.time_id33 := p0_a56;
    ddp_act_metric_fact_rec.time_id34 := p0_a57;
    ddp_act_metric_fact_rec.time_id35 := p0_a58;
    ddp_act_metric_fact_rec.time_id36 := p0_a59;
    ddp_act_metric_fact_rec.time_id37 := p0_a60;
    ddp_act_metric_fact_rec.time_id38 := p0_a61;
    ddp_act_metric_fact_rec.time_id39 := p0_a62;
    ddp_act_metric_fact_rec.time_id40 := p0_a63;
    ddp_act_metric_fact_rec.time_id41 := p0_a64;
    ddp_act_metric_fact_rec.time_id42 := p0_a65;
    ddp_act_metric_fact_rec.time_id43 := p0_a66;
    ddp_act_metric_fact_rec.time_id44 := p0_a67;
    ddp_act_metric_fact_rec.time_id45 := p0_a68;
    ddp_act_metric_fact_rec.time_id46 := p0_a69;
    ddp_act_metric_fact_rec.time_id47 := p0_a70;
    ddp_act_metric_fact_rec.time_id48 := p0_a71;
    ddp_act_metric_fact_rec.time_id49 := p0_a72;
    ddp_act_metric_fact_rec.time_id50 := p0_a73;
    ddp_act_metric_fact_rec.time_id51 := p0_a74;
    ddp_act_metric_fact_rec.time_id52 := p0_a75;
    ddp_act_metric_fact_rec.time_id53 := p0_a76;
    ddp_act_metric_fact_rec.hierarchy_id := p0_a77;
    ddp_act_metric_fact_rec.node_id := p0_a78;
    ddp_act_metric_fact_rec.level_depth := p0_a79;
    ddp_act_metric_fact_rec.formula_id := p0_a80;
    ddp_act_metric_fact_rec.from_date := rosetta_g_miss_date_in_map(p0_a81);
    ddp_act_metric_fact_rec.to_date := rosetta_g_miss_date_in_map(p0_a82);
    ddp_act_metric_fact_rec.fact_value := p0_a83;
    ddp_act_metric_fact_rec.fact_percent := p0_a84;
    ddp_act_metric_fact_rec.root_fact_id := p0_a85;
    ddp_act_metric_fact_rec.previous_fact_id := p0_a86;
    ddp_act_metric_fact_rec.fact_type := p0_a87;
    ddp_act_metric_fact_rec.fact_reference := p0_a88;
    ddp_act_metric_fact_rec.forward_buy_quantity := p0_a89;
    ddp_act_metric_fact_rec.status_code := p0_a90;
    ddp_act_metric_fact_rec.hierarchy_type := p0_a91;
    ddp_act_metric_fact_rec.approval_date := rosetta_g_miss_date_in_map(p0_a92);
    ddp_act_metric_fact_rec.recommend_total_amount := p0_a93;
    ddp_act_metric_fact_rec.recommend_hb_amount := p0_a94;
    ddp_act_metric_fact_rec.request_total_amount := p0_a95;
    ddp_act_metric_fact_rec.request_hb_amount := p0_a96;
    ddp_act_metric_fact_rec.actual_total_amount := p0_a97;
    ddp_act_metric_fact_rec.actual_hb_amount := p0_a98;
    ddp_act_metric_fact_rec.base_total_pct := p0_a99;
    ddp_act_metric_fact_rec.base_hb_pct := p0_a100;
    ddp_act_metric_fact_rec.baseline_sales := p0_a101;
    ddp_act_metric_fact_rec.tpr_percent := p0_a102;
    ddp_act_metric_fact_rec.lift_factor := p0_a103;
    ddp_act_metric_fact_rec.incremental_sales := p0_a104;



    -- here's the delegated call to the old PL/SQL routine
    ozf_actmetricfact_pvt.validate_actmetfact_items(ddp_act_metric_fact_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure validate_actmetfact_rec(p0_a0  NUMBER
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
    , p0_a11  NUMBER
    , p0_a12  NUMBER
    , p0_a13  VARCHAR2
    , p0_a14  NUMBER
    , p0_a15  NUMBER
    , p0_a16  VARCHAR2
    , p0_a17  NUMBER
    , p0_a18  NUMBER
    , p0_a19  NUMBER
    , p0_a20  NUMBER
    , p0_a21  VARCHAR2
    , p0_a22  NUMBER
    , p0_a23  NUMBER
    , p0_a24  NUMBER
    , p0_a25  NUMBER
    , p0_a26  NUMBER
    , p0_a27  NUMBER
    , p0_a28  NUMBER
    , p0_a29  NUMBER
    , p0_a30  NUMBER
    , p0_a31  NUMBER
    , p0_a32  NUMBER
    , p0_a33  NUMBER
    , p0_a34  NUMBER
    , p0_a35  NUMBER
    , p0_a36  NUMBER
    , p0_a37  NUMBER
    , p0_a38  NUMBER
    , p0_a39  NUMBER
    , p0_a40  NUMBER
    , p0_a41  NUMBER
    , p0_a42  NUMBER
    , p0_a43  NUMBER
    , p0_a44  NUMBER
    , p0_a45  NUMBER
    , p0_a46  NUMBER
    , p0_a47  NUMBER
    , p0_a48  NUMBER
    , p0_a49  NUMBER
    , p0_a50  NUMBER
    , p0_a51  NUMBER
    , p0_a52  NUMBER
    , p0_a53  NUMBER
    , p0_a54  NUMBER
    , p0_a55  NUMBER
    , p0_a56  NUMBER
    , p0_a57  NUMBER
    , p0_a58  NUMBER
    , p0_a59  NUMBER
    , p0_a60  NUMBER
    , p0_a61  NUMBER
    , p0_a62  NUMBER
    , p0_a63  NUMBER
    , p0_a64  NUMBER
    , p0_a65  NUMBER
    , p0_a66  NUMBER
    , p0_a67  NUMBER
    , p0_a68  NUMBER
    , p0_a69  NUMBER
    , p0_a70  NUMBER
    , p0_a71  NUMBER
    , p0_a72  NUMBER
    , p0_a73  NUMBER
    , p0_a74  NUMBER
    , p0_a75  NUMBER
    , p0_a76  NUMBER
    , p0_a77  NUMBER
    , p0_a78  NUMBER
    , p0_a79  NUMBER
    , p0_a80  NUMBER
    , p0_a81  DATE
    , p0_a82  DATE
    , p0_a83  NUMBER
    , p0_a84  NUMBER
    , p0_a85  NUMBER
    , p0_a86  NUMBER
    , p0_a87  VARCHAR2
    , p0_a88  VARCHAR2
    , p0_a89  NUMBER
    , p0_a90  VARCHAR2
    , p0_a91  VARCHAR2
    , p0_a92  DATE
    , p0_a93  NUMBER
    , p0_a94  NUMBER
    , p0_a95  NUMBER
    , p0_a96  NUMBER
    , p0_a97  NUMBER
    , p0_a98  NUMBER
    , p0_a99  NUMBER
    , p0_a100  NUMBER
    , p0_a101  NUMBER
    , p0_a102  NUMBER
    , p0_a103  NUMBER
    , p0_a104  NUMBER
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
    , p1_a11  NUMBER
    , p1_a12  NUMBER
    , p1_a13  VARCHAR2
    , p1_a14  NUMBER
    , p1_a15  NUMBER
    , p1_a16  VARCHAR2
    , p1_a17  NUMBER
    , p1_a18  NUMBER
    , p1_a19  NUMBER
    , p1_a20  NUMBER
    , p1_a21  VARCHAR2
    , p1_a22  NUMBER
    , p1_a23  NUMBER
    , p1_a24  NUMBER
    , p1_a25  NUMBER
    , p1_a26  NUMBER
    , p1_a27  NUMBER
    , p1_a28  NUMBER
    , p1_a29  NUMBER
    , p1_a30  NUMBER
    , p1_a31  NUMBER
    , p1_a32  NUMBER
    , p1_a33  NUMBER
    , p1_a34  NUMBER
    , p1_a35  NUMBER
    , p1_a36  NUMBER
    , p1_a37  NUMBER
    , p1_a38  NUMBER
    , p1_a39  NUMBER
    , p1_a40  NUMBER
    , p1_a41  NUMBER
    , p1_a42  NUMBER
    , p1_a43  NUMBER
    , p1_a44  NUMBER
    , p1_a45  NUMBER
    , p1_a46  NUMBER
    , p1_a47  NUMBER
    , p1_a48  NUMBER
    , p1_a49  NUMBER
    , p1_a50  NUMBER
    , p1_a51  NUMBER
    , p1_a52  NUMBER
    , p1_a53  NUMBER
    , p1_a54  NUMBER
    , p1_a55  NUMBER
    , p1_a56  NUMBER
    , p1_a57  NUMBER
    , p1_a58  NUMBER
    , p1_a59  NUMBER
    , p1_a60  NUMBER
    , p1_a61  NUMBER
    , p1_a62  NUMBER
    , p1_a63  NUMBER
    , p1_a64  NUMBER
    , p1_a65  NUMBER
    , p1_a66  NUMBER
    , p1_a67  NUMBER
    , p1_a68  NUMBER
    , p1_a69  NUMBER
    , p1_a70  NUMBER
    , p1_a71  NUMBER
    , p1_a72  NUMBER
    , p1_a73  NUMBER
    , p1_a74  NUMBER
    , p1_a75  NUMBER
    , p1_a76  NUMBER
    , p1_a77  NUMBER
    , p1_a78  NUMBER
    , p1_a79  NUMBER
    , p1_a80  NUMBER
    , p1_a81  DATE
    , p1_a82  DATE
    , p1_a83  NUMBER
    , p1_a84  NUMBER
    , p1_a85  NUMBER
    , p1_a86  NUMBER
    , p1_a87  VARCHAR2
    , p1_a88  VARCHAR2
    , p1_a89  NUMBER
    , p1_a90  VARCHAR2
    , p1_a91  VARCHAR2
    , p1_a92  DATE
    , p1_a93  NUMBER
    , p1_a94  NUMBER
    , p1_a95  NUMBER
    , p1_a96  NUMBER
    , p1_a97  NUMBER
    , p1_a98  NUMBER
    , p1_a99  NUMBER
    , p1_a100  NUMBER
    , p1_a101  NUMBER
    , p1_a102  NUMBER
    , p1_a103  NUMBER
    , p1_a104  NUMBER
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_act_metric_fact_rec ozf_actmetricfact_pvt.act_metric_fact_rec_type;
    ddp_complete_fact_rec ozf_actmetricfact_pvt.act_metric_fact_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_act_metric_fact_rec.activity_metric_fact_id := p0_a0;
    ddp_act_metric_fact_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_act_metric_fact_rec.last_updated_by := p0_a2;
    ddp_act_metric_fact_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_act_metric_fact_rec.created_by := p0_a4;
    ddp_act_metric_fact_rec.last_update_login := p0_a5;
    ddp_act_metric_fact_rec.object_version_number := p0_a6;
    ddp_act_metric_fact_rec.act_metric_used_by_id := p0_a7;
    ddp_act_metric_fact_rec.arc_act_metric_used_by := p0_a8;
    ddp_act_metric_fact_rec.value_type := p0_a9;
    ddp_act_metric_fact_rec.activity_metric_id := p0_a10;
    ddp_act_metric_fact_rec.activity_geo_area_id := p0_a11;
    ddp_act_metric_fact_rec.activity_product_id := p0_a12;
    ddp_act_metric_fact_rec.transaction_currency_code := p0_a13;
    ddp_act_metric_fact_rec.trans_forecasted_value := p0_a14;
    ddp_act_metric_fact_rec.base_quantity := p0_a15;
    ddp_act_metric_fact_rec.functional_currency_code := p0_a16;
    ddp_act_metric_fact_rec.func_forecasted_value := p0_a17;
    ddp_act_metric_fact_rec.org_id := p0_a18;
    ddp_act_metric_fact_rec.de_metric_id := p0_a19;
    ddp_act_metric_fact_rec.de_geographic_area_id := p0_a20;
    ddp_act_metric_fact_rec.de_geographic_area_type := p0_a21;
    ddp_act_metric_fact_rec.de_inventory_item_id := p0_a22;
    ddp_act_metric_fact_rec.de_inventory_item_org_id := p0_a23;
    ddp_act_metric_fact_rec.time_id1 := p0_a24;
    ddp_act_metric_fact_rec.time_id2 := p0_a25;
    ddp_act_metric_fact_rec.time_id3 := p0_a26;
    ddp_act_metric_fact_rec.time_id4 := p0_a27;
    ddp_act_metric_fact_rec.time_id5 := p0_a28;
    ddp_act_metric_fact_rec.time_id6 := p0_a29;
    ddp_act_metric_fact_rec.time_id7 := p0_a30;
    ddp_act_metric_fact_rec.time_id8 := p0_a31;
    ddp_act_metric_fact_rec.time_id9 := p0_a32;
    ddp_act_metric_fact_rec.time_id10 := p0_a33;
    ddp_act_metric_fact_rec.time_id11 := p0_a34;
    ddp_act_metric_fact_rec.time_id12 := p0_a35;
    ddp_act_metric_fact_rec.time_id13 := p0_a36;
    ddp_act_metric_fact_rec.time_id14 := p0_a37;
    ddp_act_metric_fact_rec.time_id15 := p0_a38;
    ddp_act_metric_fact_rec.time_id16 := p0_a39;
    ddp_act_metric_fact_rec.time_id17 := p0_a40;
    ddp_act_metric_fact_rec.time_id18 := p0_a41;
    ddp_act_metric_fact_rec.time_id19 := p0_a42;
    ddp_act_metric_fact_rec.time_id20 := p0_a43;
    ddp_act_metric_fact_rec.time_id21 := p0_a44;
    ddp_act_metric_fact_rec.time_id22 := p0_a45;
    ddp_act_metric_fact_rec.time_id23 := p0_a46;
    ddp_act_metric_fact_rec.time_id24 := p0_a47;
    ddp_act_metric_fact_rec.time_id25 := p0_a48;
    ddp_act_metric_fact_rec.time_id26 := p0_a49;
    ddp_act_metric_fact_rec.time_id27 := p0_a50;
    ddp_act_metric_fact_rec.time_id28 := p0_a51;
    ddp_act_metric_fact_rec.time_id29 := p0_a52;
    ddp_act_metric_fact_rec.time_id30 := p0_a53;
    ddp_act_metric_fact_rec.time_id31 := p0_a54;
    ddp_act_metric_fact_rec.time_id32 := p0_a55;
    ddp_act_metric_fact_rec.time_id33 := p0_a56;
    ddp_act_metric_fact_rec.time_id34 := p0_a57;
    ddp_act_metric_fact_rec.time_id35 := p0_a58;
    ddp_act_metric_fact_rec.time_id36 := p0_a59;
    ddp_act_metric_fact_rec.time_id37 := p0_a60;
    ddp_act_metric_fact_rec.time_id38 := p0_a61;
    ddp_act_metric_fact_rec.time_id39 := p0_a62;
    ddp_act_metric_fact_rec.time_id40 := p0_a63;
    ddp_act_metric_fact_rec.time_id41 := p0_a64;
    ddp_act_metric_fact_rec.time_id42 := p0_a65;
    ddp_act_metric_fact_rec.time_id43 := p0_a66;
    ddp_act_metric_fact_rec.time_id44 := p0_a67;
    ddp_act_metric_fact_rec.time_id45 := p0_a68;
    ddp_act_metric_fact_rec.time_id46 := p0_a69;
    ddp_act_metric_fact_rec.time_id47 := p0_a70;
    ddp_act_metric_fact_rec.time_id48 := p0_a71;
    ddp_act_metric_fact_rec.time_id49 := p0_a72;
    ddp_act_metric_fact_rec.time_id50 := p0_a73;
    ddp_act_metric_fact_rec.time_id51 := p0_a74;
    ddp_act_metric_fact_rec.time_id52 := p0_a75;
    ddp_act_metric_fact_rec.time_id53 := p0_a76;
    ddp_act_metric_fact_rec.hierarchy_id := p0_a77;
    ddp_act_metric_fact_rec.node_id := p0_a78;
    ddp_act_metric_fact_rec.level_depth := p0_a79;
    ddp_act_metric_fact_rec.formula_id := p0_a80;
    ddp_act_metric_fact_rec.from_date := rosetta_g_miss_date_in_map(p0_a81);
    ddp_act_metric_fact_rec.to_date := rosetta_g_miss_date_in_map(p0_a82);
    ddp_act_metric_fact_rec.fact_value := p0_a83;
    ddp_act_metric_fact_rec.fact_percent := p0_a84;
    ddp_act_metric_fact_rec.root_fact_id := p0_a85;
    ddp_act_metric_fact_rec.previous_fact_id := p0_a86;
    ddp_act_metric_fact_rec.fact_type := p0_a87;
    ddp_act_metric_fact_rec.fact_reference := p0_a88;
    ddp_act_metric_fact_rec.forward_buy_quantity := p0_a89;
    ddp_act_metric_fact_rec.status_code := p0_a90;
    ddp_act_metric_fact_rec.hierarchy_type := p0_a91;
    ddp_act_metric_fact_rec.approval_date := rosetta_g_miss_date_in_map(p0_a92);
    ddp_act_metric_fact_rec.recommend_total_amount := p0_a93;
    ddp_act_metric_fact_rec.recommend_hb_amount := p0_a94;
    ddp_act_metric_fact_rec.request_total_amount := p0_a95;
    ddp_act_metric_fact_rec.request_hb_amount := p0_a96;
    ddp_act_metric_fact_rec.actual_total_amount := p0_a97;
    ddp_act_metric_fact_rec.actual_hb_amount := p0_a98;
    ddp_act_metric_fact_rec.base_total_pct := p0_a99;
    ddp_act_metric_fact_rec.base_hb_pct := p0_a100;
    ddp_act_metric_fact_rec.baseline_sales := p0_a101;
    ddp_act_metric_fact_rec.tpr_percent := p0_a102;
    ddp_act_metric_fact_rec.lift_factor := p0_a103;
    ddp_act_metric_fact_rec.incremental_sales := p0_a104;

    ddp_complete_fact_rec.activity_metric_fact_id := p1_a0;
    ddp_complete_fact_rec.last_update_date := rosetta_g_miss_date_in_map(p1_a1);
    ddp_complete_fact_rec.last_updated_by := p1_a2;
    ddp_complete_fact_rec.creation_date := rosetta_g_miss_date_in_map(p1_a3);
    ddp_complete_fact_rec.created_by := p1_a4;
    ddp_complete_fact_rec.last_update_login := p1_a5;
    ddp_complete_fact_rec.object_version_number := p1_a6;
    ddp_complete_fact_rec.act_metric_used_by_id := p1_a7;
    ddp_complete_fact_rec.arc_act_metric_used_by := p1_a8;
    ddp_complete_fact_rec.value_type := p1_a9;
    ddp_complete_fact_rec.activity_metric_id := p1_a10;
    ddp_complete_fact_rec.activity_geo_area_id := p1_a11;
    ddp_complete_fact_rec.activity_product_id := p1_a12;
    ddp_complete_fact_rec.transaction_currency_code := p1_a13;
    ddp_complete_fact_rec.trans_forecasted_value := p1_a14;
    ddp_complete_fact_rec.base_quantity := p1_a15;
    ddp_complete_fact_rec.functional_currency_code := p1_a16;
    ddp_complete_fact_rec.func_forecasted_value := p1_a17;
    ddp_complete_fact_rec.org_id := p1_a18;
    ddp_complete_fact_rec.de_metric_id := p1_a19;
    ddp_complete_fact_rec.de_geographic_area_id := p1_a20;
    ddp_complete_fact_rec.de_geographic_area_type := p1_a21;
    ddp_complete_fact_rec.de_inventory_item_id := p1_a22;
    ddp_complete_fact_rec.de_inventory_item_org_id := p1_a23;
    ddp_complete_fact_rec.time_id1 := p1_a24;
    ddp_complete_fact_rec.time_id2 := p1_a25;
    ddp_complete_fact_rec.time_id3 := p1_a26;
    ddp_complete_fact_rec.time_id4 := p1_a27;
    ddp_complete_fact_rec.time_id5 := p1_a28;
    ddp_complete_fact_rec.time_id6 := p1_a29;
    ddp_complete_fact_rec.time_id7 := p1_a30;
    ddp_complete_fact_rec.time_id8 := p1_a31;
    ddp_complete_fact_rec.time_id9 := p1_a32;
    ddp_complete_fact_rec.time_id10 := p1_a33;
    ddp_complete_fact_rec.time_id11 := p1_a34;
    ddp_complete_fact_rec.time_id12 := p1_a35;
    ddp_complete_fact_rec.time_id13 := p1_a36;
    ddp_complete_fact_rec.time_id14 := p1_a37;
    ddp_complete_fact_rec.time_id15 := p1_a38;
    ddp_complete_fact_rec.time_id16 := p1_a39;
    ddp_complete_fact_rec.time_id17 := p1_a40;
    ddp_complete_fact_rec.time_id18 := p1_a41;
    ddp_complete_fact_rec.time_id19 := p1_a42;
    ddp_complete_fact_rec.time_id20 := p1_a43;
    ddp_complete_fact_rec.time_id21 := p1_a44;
    ddp_complete_fact_rec.time_id22 := p1_a45;
    ddp_complete_fact_rec.time_id23 := p1_a46;
    ddp_complete_fact_rec.time_id24 := p1_a47;
    ddp_complete_fact_rec.time_id25 := p1_a48;
    ddp_complete_fact_rec.time_id26 := p1_a49;
    ddp_complete_fact_rec.time_id27 := p1_a50;
    ddp_complete_fact_rec.time_id28 := p1_a51;
    ddp_complete_fact_rec.time_id29 := p1_a52;
    ddp_complete_fact_rec.time_id30 := p1_a53;
    ddp_complete_fact_rec.time_id31 := p1_a54;
    ddp_complete_fact_rec.time_id32 := p1_a55;
    ddp_complete_fact_rec.time_id33 := p1_a56;
    ddp_complete_fact_rec.time_id34 := p1_a57;
    ddp_complete_fact_rec.time_id35 := p1_a58;
    ddp_complete_fact_rec.time_id36 := p1_a59;
    ddp_complete_fact_rec.time_id37 := p1_a60;
    ddp_complete_fact_rec.time_id38 := p1_a61;
    ddp_complete_fact_rec.time_id39 := p1_a62;
    ddp_complete_fact_rec.time_id40 := p1_a63;
    ddp_complete_fact_rec.time_id41 := p1_a64;
    ddp_complete_fact_rec.time_id42 := p1_a65;
    ddp_complete_fact_rec.time_id43 := p1_a66;
    ddp_complete_fact_rec.time_id44 := p1_a67;
    ddp_complete_fact_rec.time_id45 := p1_a68;
    ddp_complete_fact_rec.time_id46 := p1_a69;
    ddp_complete_fact_rec.time_id47 := p1_a70;
    ddp_complete_fact_rec.time_id48 := p1_a71;
    ddp_complete_fact_rec.time_id49 := p1_a72;
    ddp_complete_fact_rec.time_id50 := p1_a73;
    ddp_complete_fact_rec.time_id51 := p1_a74;
    ddp_complete_fact_rec.time_id52 := p1_a75;
    ddp_complete_fact_rec.time_id53 := p1_a76;
    ddp_complete_fact_rec.hierarchy_id := p1_a77;
    ddp_complete_fact_rec.node_id := p1_a78;
    ddp_complete_fact_rec.level_depth := p1_a79;
    ddp_complete_fact_rec.formula_id := p1_a80;
    ddp_complete_fact_rec.from_date := rosetta_g_miss_date_in_map(p1_a81);
    ddp_complete_fact_rec.to_date := rosetta_g_miss_date_in_map(p1_a82);
    ddp_complete_fact_rec.fact_value := p1_a83;
    ddp_complete_fact_rec.fact_percent := p1_a84;
    ddp_complete_fact_rec.root_fact_id := p1_a85;
    ddp_complete_fact_rec.previous_fact_id := p1_a86;
    ddp_complete_fact_rec.fact_type := p1_a87;
    ddp_complete_fact_rec.fact_reference := p1_a88;
    ddp_complete_fact_rec.forward_buy_quantity := p1_a89;
    ddp_complete_fact_rec.status_code := p1_a90;
    ddp_complete_fact_rec.hierarchy_type := p1_a91;
    ddp_complete_fact_rec.approval_date := rosetta_g_miss_date_in_map(p1_a92);
    ddp_complete_fact_rec.recommend_total_amount := p1_a93;
    ddp_complete_fact_rec.recommend_hb_amount := p1_a94;
    ddp_complete_fact_rec.request_total_amount := p1_a95;
    ddp_complete_fact_rec.request_hb_amount := p1_a96;
    ddp_complete_fact_rec.actual_total_amount := p1_a97;
    ddp_complete_fact_rec.actual_hb_amount := p1_a98;
    ddp_complete_fact_rec.base_total_pct := p1_a99;
    ddp_complete_fact_rec.base_hb_pct := p1_a100;
    ddp_complete_fact_rec.baseline_sales := p1_a101;
    ddp_complete_fact_rec.tpr_percent := p1_a102;
    ddp_complete_fact_rec.lift_factor := p1_a103;
    ddp_complete_fact_rec.incremental_sales := p1_a104;


    -- here's the delegated call to the old PL/SQL routine
    ozf_actmetricfact_pvt.validate_actmetfact_rec(ddp_act_metric_fact_rec,
      ddp_complete_fact_rec,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure complete_actmetfact_rec(p0_a0  NUMBER
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
    , p0_a11  NUMBER
    , p0_a12  NUMBER
    , p0_a13  VARCHAR2
    , p0_a14  NUMBER
    , p0_a15  NUMBER
    , p0_a16  VARCHAR2
    , p0_a17  NUMBER
    , p0_a18  NUMBER
    , p0_a19  NUMBER
    , p0_a20  NUMBER
    , p0_a21  VARCHAR2
    , p0_a22  NUMBER
    , p0_a23  NUMBER
    , p0_a24  NUMBER
    , p0_a25  NUMBER
    , p0_a26  NUMBER
    , p0_a27  NUMBER
    , p0_a28  NUMBER
    , p0_a29  NUMBER
    , p0_a30  NUMBER
    , p0_a31  NUMBER
    , p0_a32  NUMBER
    , p0_a33  NUMBER
    , p0_a34  NUMBER
    , p0_a35  NUMBER
    , p0_a36  NUMBER
    , p0_a37  NUMBER
    , p0_a38  NUMBER
    , p0_a39  NUMBER
    , p0_a40  NUMBER
    , p0_a41  NUMBER
    , p0_a42  NUMBER
    , p0_a43  NUMBER
    , p0_a44  NUMBER
    , p0_a45  NUMBER
    , p0_a46  NUMBER
    , p0_a47  NUMBER
    , p0_a48  NUMBER
    , p0_a49  NUMBER
    , p0_a50  NUMBER
    , p0_a51  NUMBER
    , p0_a52  NUMBER
    , p0_a53  NUMBER
    , p0_a54  NUMBER
    , p0_a55  NUMBER
    , p0_a56  NUMBER
    , p0_a57  NUMBER
    , p0_a58  NUMBER
    , p0_a59  NUMBER
    , p0_a60  NUMBER
    , p0_a61  NUMBER
    , p0_a62  NUMBER
    , p0_a63  NUMBER
    , p0_a64  NUMBER
    , p0_a65  NUMBER
    , p0_a66  NUMBER
    , p0_a67  NUMBER
    , p0_a68  NUMBER
    , p0_a69  NUMBER
    , p0_a70  NUMBER
    , p0_a71  NUMBER
    , p0_a72  NUMBER
    , p0_a73  NUMBER
    , p0_a74  NUMBER
    , p0_a75  NUMBER
    , p0_a76  NUMBER
    , p0_a77  NUMBER
    , p0_a78  NUMBER
    , p0_a79  NUMBER
    , p0_a80  NUMBER
    , p0_a81  DATE
    , p0_a82  DATE
    , p0_a83  NUMBER
    , p0_a84  NUMBER
    , p0_a85  NUMBER
    , p0_a86  NUMBER
    , p0_a87  VARCHAR2
    , p0_a88  VARCHAR2
    , p0_a89  NUMBER
    , p0_a90  VARCHAR2
    , p0_a91  VARCHAR2
    , p0_a92  DATE
    , p0_a93  NUMBER
    , p0_a94  NUMBER
    , p0_a95  NUMBER
    , p0_a96  NUMBER
    , p0_a97  NUMBER
    , p0_a98  NUMBER
    , p0_a99  NUMBER
    , p0_a100  NUMBER
    , p0_a101  NUMBER
    , p0_a102  NUMBER
    , p0_a103  NUMBER
    , p0_a104  NUMBER
    , p1_a0 out nocopy  NUMBER
    , p1_a1 out nocopy  DATE
    , p1_a2 out nocopy  NUMBER
    , p1_a3 out nocopy  DATE
    , p1_a4 out nocopy  NUMBER
    , p1_a5 out nocopy  NUMBER
    , p1_a6 out nocopy  NUMBER
    , p1_a7 out nocopy  NUMBER
    , p1_a8 out nocopy  VARCHAR2
    , p1_a9 out nocopy  VARCHAR2
    , p1_a10 out nocopy  NUMBER
    , p1_a11 out nocopy  NUMBER
    , p1_a12 out nocopy  NUMBER
    , p1_a13 out nocopy  VARCHAR2
    , p1_a14 out nocopy  NUMBER
    , p1_a15 out nocopy  NUMBER
    , p1_a16 out nocopy  VARCHAR2
    , p1_a17 out nocopy  NUMBER
    , p1_a18 out nocopy  NUMBER
    , p1_a19 out nocopy  NUMBER
    , p1_a20 out nocopy  NUMBER
    , p1_a21 out nocopy  VARCHAR2
    , p1_a22 out nocopy  NUMBER
    , p1_a23 out nocopy  NUMBER
    , p1_a24 out nocopy  NUMBER
    , p1_a25 out nocopy  NUMBER
    , p1_a26 out nocopy  NUMBER
    , p1_a27 out nocopy  NUMBER
    , p1_a28 out nocopy  NUMBER
    , p1_a29 out nocopy  NUMBER
    , p1_a30 out nocopy  NUMBER
    , p1_a31 out nocopy  NUMBER
    , p1_a32 out nocopy  NUMBER
    , p1_a33 out nocopy  NUMBER
    , p1_a34 out nocopy  NUMBER
    , p1_a35 out nocopy  NUMBER
    , p1_a36 out nocopy  NUMBER
    , p1_a37 out nocopy  NUMBER
    , p1_a38 out nocopy  NUMBER
    , p1_a39 out nocopy  NUMBER
    , p1_a40 out nocopy  NUMBER
    , p1_a41 out nocopy  NUMBER
    , p1_a42 out nocopy  NUMBER
    , p1_a43 out nocopy  NUMBER
    , p1_a44 out nocopy  NUMBER
    , p1_a45 out nocopy  NUMBER
    , p1_a46 out nocopy  NUMBER
    , p1_a47 out nocopy  NUMBER
    , p1_a48 out nocopy  NUMBER
    , p1_a49 out nocopy  NUMBER
    , p1_a50 out nocopy  NUMBER
    , p1_a51 out nocopy  NUMBER
    , p1_a52 out nocopy  NUMBER
    , p1_a53 out nocopy  NUMBER
    , p1_a54 out nocopy  NUMBER
    , p1_a55 out nocopy  NUMBER
    , p1_a56 out nocopy  NUMBER
    , p1_a57 out nocopy  NUMBER
    , p1_a58 out nocopy  NUMBER
    , p1_a59 out nocopy  NUMBER
    , p1_a60 out nocopy  NUMBER
    , p1_a61 out nocopy  NUMBER
    , p1_a62 out nocopy  NUMBER
    , p1_a63 out nocopy  NUMBER
    , p1_a64 out nocopy  NUMBER
    , p1_a65 out nocopy  NUMBER
    , p1_a66 out nocopy  NUMBER
    , p1_a67 out nocopy  NUMBER
    , p1_a68 out nocopy  NUMBER
    , p1_a69 out nocopy  NUMBER
    , p1_a70 out nocopy  NUMBER
    , p1_a71 out nocopy  NUMBER
    , p1_a72 out nocopy  NUMBER
    , p1_a73 out nocopy  NUMBER
    , p1_a74 out nocopy  NUMBER
    , p1_a75 out nocopy  NUMBER
    , p1_a76 out nocopy  NUMBER
    , p1_a77 out nocopy  NUMBER
    , p1_a78 out nocopy  NUMBER
    , p1_a79 out nocopy  NUMBER
    , p1_a80 out nocopy  NUMBER
    , p1_a81 out nocopy  DATE
    , p1_a82 out nocopy  DATE
    , p1_a83 out nocopy  NUMBER
    , p1_a84 out nocopy  NUMBER
    , p1_a85 out nocopy  NUMBER
    , p1_a86 out nocopy  NUMBER
    , p1_a87 out nocopy  VARCHAR2
    , p1_a88 out nocopy  VARCHAR2
    , p1_a89 out nocopy  NUMBER
    , p1_a90 out nocopy  VARCHAR2
    , p1_a91 out nocopy  VARCHAR2
    , p1_a92 out nocopy  DATE
    , p1_a93 out nocopy  NUMBER
    , p1_a94 out nocopy  NUMBER
    , p1_a95 out nocopy  NUMBER
    , p1_a96 out nocopy  NUMBER
    , p1_a97 out nocopy  NUMBER
    , p1_a98 out nocopy  NUMBER
    , p1_a99 out nocopy  NUMBER
    , p1_a100 out nocopy  NUMBER
    , p1_a101 out nocopy  NUMBER
    , p1_a102 out nocopy  NUMBER
    , p1_a103 out nocopy  NUMBER
    , p1_a104 out nocopy  NUMBER
  )

  as
    ddp_act_metric_fact_rec ozf_actmetricfact_pvt.act_metric_fact_rec_type;
    ddx_complete_fact_rec ozf_actmetricfact_pvt.act_metric_fact_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_act_metric_fact_rec.activity_metric_fact_id := p0_a0;
    ddp_act_metric_fact_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_act_metric_fact_rec.last_updated_by := p0_a2;
    ddp_act_metric_fact_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_act_metric_fact_rec.created_by := p0_a4;
    ddp_act_metric_fact_rec.last_update_login := p0_a5;
    ddp_act_metric_fact_rec.object_version_number := p0_a6;
    ddp_act_metric_fact_rec.act_metric_used_by_id := p0_a7;
    ddp_act_metric_fact_rec.arc_act_metric_used_by := p0_a8;
    ddp_act_metric_fact_rec.value_type := p0_a9;
    ddp_act_metric_fact_rec.activity_metric_id := p0_a10;
    ddp_act_metric_fact_rec.activity_geo_area_id := p0_a11;
    ddp_act_metric_fact_rec.activity_product_id := p0_a12;
    ddp_act_metric_fact_rec.transaction_currency_code := p0_a13;
    ddp_act_metric_fact_rec.trans_forecasted_value := p0_a14;
    ddp_act_metric_fact_rec.base_quantity := p0_a15;
    ddp_act_metric_fact_rec.functional_currency_code := p0_a16;
    ddp_act_metric_fact_rec.func_forecasted_value := p0_a17;
    ddp_act_metric_fact_rec.org_id := p0_a18;
    ddp_act_metric_fact_rec.de_metric_id := p0_a19;
    ddp_act_metric_fact_rec.de_geographic_area_id := p0_a20;
    ddp_act_metric_fact_rec.de_geographic_area_type := p0_a21;
    ddp_act_metric_fact_rec.de_inventory_item_id := p0_a22;
    ddp_act_metric_fact_rec.de_inventory_item_org_id := p0_a23;
    ddp_act_metric_fact_rec.time_id1 := p0_a24;
    ddp_act_metric_fact_rec.time_id2 := p0_a25;
    ddp_act_metric_fact_rec.time_id3 := p0_a26;
    ddp_act_metric_fact_rec.time_id4 := p0_a27;
    ddp_act_metric_fact_rec.time_id5 := p0_a28;
    ddp_act_metric_fact_rec.time_id6 := p0_a29;
    ddp_act_metric_fact_rec.time_id7 := p0_a30;
    ddp_act_metric_fact_rec.time_id8 := p0_a31;
    ddp_act_metric_fact_rec.time_id9 := p0_a32;
    ddp_act_metric_fact_rec.time_id10 := p0_a33;
    ddp_act_metric_fact_rec.time_id11 := p0_a34;
    ddp_act_metric_fact_rec.time_id12 := p0_a35;
    ddp_act_metric_fact_rec.time_id13 := p0_a36;
    ddp_act_metric_fact_rec.time_id14 := p0_a37;
    ddp_act_metric_fact_rec.time_id15 := p0_a38;
    ddp_act_metric_fact_rec.time_id16 := p0_a39;
    ddp_act_metric_fact_rec.time_id17 := p0_a40;
    ddp_act_metric_fact_rec.time_id18 := p0_a41;
    ddp_act_metric_fact_rec.time_id19 := p0_a42;
    ddp_act_metric_fact_rec.time_id20 := p0_a43;
    ddp_act_metric_fact_rec.time_id21 := p0_a44;
    ddp_act_metric_fact_rec.time_id22 := p0_a45;
    ddp_act_metric_fact_rec.time_id23 := p0_a46;
    ddp_act_metric_fact_rec.time_id24 := p0_a47;
    ddp_act_metric_fact_rec.time_id25 := p0_a48;
    ddp_act_metric_fact_rec.time_id26 := p0_a49;
    ddp_act_metric_fact_rec.time_id27 := p0_a50;
    ddp_act_metric_fact_rec.time_id28 := p0_a51;
    ddp_act_metric_fact_rec.time_id29 := p0_a52;
    ddp_act_metric_fact_rec.time_id30 := p0_a53;
    ddp_act_metric_fact_rec.time_id31 := p0_a54;
    ddp_act_metric_fact_rec.time_id32 := p0_a55;
    ddp_act_metric_fact_rec.time_id33 := p0_a56;
    ddp_act_metric_fact_rec.time_id34 := p0_a57;
    ddp_act_metric_fact_rec.time_id35 := p0_a58;
    ddp_act_metric_fact_rec.time_id36 := p0_a59;
    ddp_act_metric_fact_rec.time_id37 := p0_a60;
    ddp_act_metric_fact_rec.time_id38 := p0_a61;
    ddp_act_metric_fact_rec.time_id39 := p0_a62;
    ddp_act_metric_fact_rec.time_id40 := p0_a63;
    ddp_act_metric_fact_rec.time_id41 := p0_a64;
    ddp_act_metric_fact_rec.time_id42 := p0_a65;
    ddp_act_metric_fact_rec.time_id43 := p0_a66;
    ddp_act_metric_fact_rec.time_id44 := p0_a67;
    ddp_act_metric_fact_rec.time_id45 := p0_a68;
    ddp_act_metric_fact_rec.time_id46 := p0_a69;
    ddp_act_metric_fact_rec.time_id47 := p0_a70;
    ddp_act_metric_fact_rec.time_id48 := p0_a71;
    ddp_act_metric_fact_rec.time_id49 := p0_a72;
    ddp_act_metric_fact_rec.time_id50 := p0_a73;
    ddp_act_metric_fact_rec.time_id51 := p0_a74;
    ddp_act_metric_fact_rec.time_id52 := p0_a75;
    ddp_act_metric_fact_rec.time_id53 := p0_a76;
    ddp_act_metric_fact_rec.hierarchy_id := p0_a77;
    ddp_act_metric_fact_rec.node_id := p0_a78;
    ddp_act_metric_fact_rec.level_depth := p0_a79;
    ddp_act_metric_fact_rec.formula_id := p0_a80;
    ddp_act_metric_fact_rec.from_date := rosetta_g_miss_date_in_map(p0_a81);
    ddp_act_metric_fact_rec.to_date := rosetta_g_miss_date_in_map(p0_a82);
    ddp_act_metric_fact_rec.fact_value := p0_a83;
    ddp_act_metric_fact_rec.fact_percent := p0_a84;
    ddp_act_metric_fact_rec.root_fact_id := p0_a85;
    ddp_act_metric_fact_rec.previous_fact_id := p0_a86;
    ddp_act_metric_fact_rec.fact_type := p0_a87;
    ddp_act_metric_fact_rec.fact_reference := p0_a88;
    ddp_act_metric_fact_rec.forward_buy_quantity := p0_a89;
    ddp_act_metric_fact_rec.status_code := p0_a90;
    ddp_act_metric_fact_rec.hierarchy_type := p0_a91;
    ddp_act_metric_fact_rec.approval_date := rosetta_g_miss_date_in_map(p0_a92);
    ddp_act_metric_fact_rec.recommend_total_amount := p0_a93;
    ddp_act_metric_fact_rec.recommend_hb_amount := p0_a94;
    ddp_act_metric_fact_rec.request_total_amount := p0_a95;
    ddp_act_metric_fact_rec.request_hb_amount := p0_a96;
    ddp_act_metric_fact_rec.actual_total_amount := p0_a97;
    ddp_act_metric_fact_rec.actual_hb_amount := p0_a98;
    ddp_act_metric_fact_rec.base_total_pct := p0_a99;
    ddp_act_metric_fact_rec.base_hb_pct := p0_a100;
    ddp_act_metric_fact_rec.baseline_sales := p0_a101;
    ddp_act_metric_fact_rec.tpr_percent := p0_a102;
    ddp_act_metric_fact_rec.lift_factor := p0_a103;
    ddp_act_metric_fact_rec.incremental_sales := p0_a104;


    -- here's the delegated call to the old PL/SQL routine
    ozf_actmetricfact_pvt.complete_actmetfact_rec(ddp_act_metric_fact_rec,
      ddx_complete_fact_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    p1_a0 := ddx_complete_fact_rec.activity_metric_fact_id;
    p1_a1 := ddx_complete_fact_rec.last_update_date;
    p1_a2 := ddx_complete_fact_rec.last_updated_by;
    p1_a3 := ddx_complete_fact_rec.creation_date;
    p1_a4 := ddx_complete_fact_rec.created_by;
    p1_a5 := ddx_complete_fact_rec.last_update_login;
    p1_a6 := ddx_complete_fact_rec.object_version_number;
    p1_a7 := ddx_complete_fact_rec.act_metric_used_by_id;
    p1_a8 := ddx_complete_fact_rec.arc_act_metric_used_by;
    p1_a9 := ddx_complete_fact_rec.value_type;
    p1_a10 := ddx_complete_fact_rec.activity_metric_id;
    p1_a11 := ddx_complete_fact_rec.activity_geo_area_id;
    p1_a12 := ddx_complete_fact_rec.activity_product_id;
    p1_a13 := ddx_complete_fact_rec.transaction_currency_code;
    p1_a14 := ddx_complete_fact_rec.trans_forecasted_value;
    p1_a15 := ddx_complete_fact_rec.base_quantity;
    p1_a16 := ddx_complete_fact_rec.functional_currency_code;
    p1_a17 := ddx_complete_fact_rec.func_forecasted_value;
    p1_a18 := ddx_complete_fact_rec.org_id;
    p1_a19 := ddx_complete_fact_rec.de_metric_id;
    p1_a20 := ddx_complete_fact_rec.de_geographic_area_id;
    p1_a21 := ddx_complete_fact_rec.de_geographic_area_type;
    p1_a22 := ddx_complete_fact_rec.de_inventory_item_id;
    p1_a23 := ddx_complete_fact_rec.de_inventory_item_org_id;
    p1_a24 := ddx_complete_fact_rec.time_id1;
    p1_a25 := ddx_complete_fact_rec.time_id2;
    p1_a26 := ddx_complete_fact_rec.time_id3;
    p1_a27 := ddx_complete_fact_rec.time_id4;
    p1_a28 := ddx_complete_fact_rec.time_id5;
    p1_a29 := ddx_complete_fact_rec.time_id6;
    p1_a30 := ddx_complete_fact_rec.time_id7;
    p1_a31 := ddx_complete_fact_rec.time_id8;
    p1_a32 := ddx_complete_fact_rec.time_id9;
    p1_a33 := ddx_complete_fact_rec.time_id10;
    p1_a34 := ddx_complete_fact_rec.time_id11;
    p1_a35 := ddx_complete_fact_rec.time_id12;
    p1_a36 := ddx_complete_fact_rec.time_id13;
    p1_a37 := ddx_complete_fact_rec.time_id14;
    p1_a38 := ddx_complete_fact_rec.time_id15;
    p1_a39 := ddx_complete_fact_rec.time_id16;
    p1_a40 := ddx_complete_fact_rec.time_id17;
    p1_a41 := ddx_complete_fact_rec.time_id18;
    p1_a42 := ddx_complete_fact_rec.time_id19;
    p1_a43 := ddx_complete_fact_rec.time_id20;
    p1_a44 := ddx_complete_fact_rec.time_id21;
    p1_a45 := ddx_complete_fact_rec.time_id22;
    p1_a46 := ddx_complete_fact_rec.time_id23;
    p1_a47 := ddx_complete_fact_rec.time_id24;
    p1_a48 := ddx_complete_fact_rec.time_id25;
    p1_a49 := ddx_complete_fact_rec.time_id26;
    p1_a50 := ddx_complete_fact_rec.time_id27;
    p1_a51 := ddx_complete_fact_rec.time_id28;
    p1_a52 := ddx_complete_fact_rec.time_id29;
    p1_a53 := ddx_complete_fact_rec.time_id30;
    p1_a54 := ddx_complete_fact_rec.time_id31;
    p1_a55 := ddx_complete_fact_rec.time_id32;
    p1_a56 := ddx_complete_fact_rec.time_id33;
    p1_a57 := ddx_complete_fact_rec.time_id34;
    p1_a58 := ddx_complete_fact_rec.time_id35;
    p1_a59 := ddx_complete_fact_rec.time_id36;
    p1_a60 := ddx_complete_fact_rec.time_id37;
    p1_a61 := ddx_complete_fact_rec.time_id38;
    p1_a62 := ddx_complete_fact_rec.time_id39;
    p1_a63 := ddx_complete_fact_rec.time_id40;
    p1_a64 := ddx_complete_fact_rec.time_id41;
    p1_a65 := ddx_complete_fact_rec.time_id42;
    p1_a66 := ddx_complete_fact_rec.time_id43;
    p1_a67 := ddx_complete_fact_rec.time_id44;
    p1_a68 := ddx_complete_fact_rec.time_id45;
    p1_a69 := ddx_complete_fact_rec.time_id46;
    p1_a70 := ddx_complete_fact_rec.time_id47;
    p1_a71 := ddx_complete_fact_rec.time_id48;
    p1_a72 := ddx_complete_fact_rec.time_id49;
    p1_a73 := ddx_complete_fact_rec.time_id50;
    p1_a74 := ddx_complete_fact_rec.time_id51;
    p1_a75 := ddx_complete_fact_rec.time_id52;
    p1_a76 := ddx_complete_fact_rec.time_id53;
    p1_a77 := ddx_complete_fact_rec.hierarchy_id;
    p1_a78 := ddx_complete_fact_rec.node_id;
    p1_a79 := ddx_complete_fact_rec.level_depth;
    p1_a80 := ddx_complete_fact_rec.formula_id;
    p1_a81 := ddx_complete_fact_rec.from_date;
    p1_a82 := ddx_complete_fact_rec.to_date;
    p1_a83 := ddx_complete_fact_rec.fact_value;
    p1_a84 := ddx_complete_fact_rec.fact_percent;
    p1_a85 := ddx_complete_fact_rec.root_fact_id;
    p1_a86 := ddx_complete_fact_rec.previous_fact_id;
    p1_a87 := ddx_complete_fact_rec.fact_type;
    p1_a88 := ddx_complete_fact_rec.fact_reference;
    p1_a89 := ddx_complete_fact_rec.forward_buy_quantity;
    p1_a90 := ddx_complete_fact_rec.status_code;
    p1_a91 := ddx_complete_fact_rec.hierarchy_type;
    p1_a92 := ddx_complete_fact_rec.approval_date;
    p1_a93 := ddx_complete_fact_rec.recommend_total_amount;
    p1_a94 := ddx_complete_fact_rec.recommend_hb_amount;
    p1_a95 := ddx_complete_fact_rec.request_total_amount;
    p1_a96 := ddx_complete_fact_rec.request_hb_amount;
    p1_a97 := ddx_complete_fact_rec.actual_total_amount;
    p1_a98 := ddx_complete_fact_rec.actual_hb_amount;
    p1_a99 := ddx_complete_fact_rec.base_total_pct;
    p1_a100 := ddx_complete_fact_rec.base_hb_pct;
    p1_a101 := ddx_complete_fact_rec.baseline_sales;
    p1_a102 := ddx_complete_fact_rec.tpr_percent;
    p1_a103 := ddx_complete_fact_rec.lift_factor;
    p1_a104 := ddx_complete_fact_rec.incremental_sales;
  end;

  procedure create_formula(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  NUMBER
    , p7_a2  NUMBER
    , p7_a3  NUMBER
    , p7_a4  DATE
    , p7_a5  NUMBER
    , p7_a6  DATE
    , p7_a7  NUMBER
    , p7_a8  NUMBER
    , p7_a9  NUMBER
    , p7_a10  VARCHAR2
    , x_formula_id out nocopy  NUMBER
  )

  as
    ddp_formula_rec ozf_actmetricfact_pvt.ozf_formula_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_formula_rec.formula_id := p7_a0;
    ddp_formula_rec.activity_metric_id := p7_a1;
    ddp_formula_rec.level_depth := p7_a2;
    ddp_formula_rec.parent_formula_id := p7_a3;
    ddp_formula_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a4);
    ddp_formula_rec.last_updated_by := p7_a5;
    ddp_formula_rec.creation_date := rosetta_g_miss_date_in_map(p7_a6);
    ddp_formula_rec.created_by := p7_a7;
    ddp_formula_rec.last_update_login := p7_a8;
    ddp_formula_rec.object_version_number := p7_a9;
    ddp_formula_rec.formula_type := p7_a10;


    -- here's the delegated call to the old PL/SQL routine
    ozf_actmetricfact_pvt.create_formula(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_formula_rec,
      x_formula_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure validate_formula(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0  NUMBER
    , p6_a1  NUMBER
    , p6_a2  NUMBER
    , p6_a3  NUMBER
    , p6_a4  DATE
    , p6_a5  NUMBER
    , p6_a6  DATE
    , p6_a7  NUMBER
    , p6_a8  NUMBER
    , p6_a9  NUMBER
    , p6_a10  VARCHAR2
  )

  as
    ddp_formula_rec ozf_actmetricfact_pvt.ozf_formula_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_formula_rec.formula_id := p6_a0;
    ddp_formula_rec.activity_metric_id := p6_a1;
    ddp_formula_rec.level_depth := p6_a2;
    ddp_formula_rec.parent_formula_id := p6_a3;
    ddp_formula_rec.last_update_date := rosetta_g_miss_date_in_map(p6_a4);
    ddp_formula_rec.last_updated_by := p6_a5;
    ddp_formula_rec.creation_date := rosetta_g_miss_date_in_map(p6_a6);
    ddp_formula_rec.created_by := p6_a7;
    ddp_formula_rec.last_update_login := p6_a8;
    ddp_formula_rec.object_version_number := p6_a9;
    ddp_formula_rec.formula_type := p6_a10;

    -- here's the delegated call to the old PL/SQL routine
    ozf_actmetricfact_pvt.validate_formula(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_formula_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure validate_formula_items(p0_a0  NUMBER
    , p0_a1  NUMBER
    , p0_a2  NUMBER
    , p0_a3  NUMBER
    , p0_a4  DATE
    , p0_a5  NUMBER
    , p0_a6  DATE
    , p0_a7  NUMBER
    , p0_a8  NUMBER
    , p0_a9  NUMBER
    , p0_a10  VARCHAR2
    , p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_formula_rec ozf_actmetricfact_pvt.ozf_formula_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_formula_rec.formula_id := p0_a0;
    ddp_formula_rec.activity_metric_id := p0_a1;
    ddp_formula_rec.level_depth := p0_a2;
    ddp_formula_rec.parent_formula_id := p0_a3;
    ddp_formula_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a4);
    ddp_formula_rec.last_updated_by := p0_a5;
    ddp_formula_rec.creation_date := rosetta_g_miss_date_in_map(p0_a6);
    ddp_formula_rec.created_by := p0_a7;
    ddp_formula_rec.last_update_login := p0_a8;
    ddp_formula_rec.object_version_number := p0_a9;
    ddp_formula_rec.formula_type := p0_a10;



    -- here's the delegated call to the old PL/SQL routine
    ozf_actmetricfact_pvt.validate_formula_items(ddp_formula_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure validate_formula_rec(p0_a0  NUMBER
    , p0_a1  NUMBER
    , p0_a2  NUMBER
    , p0_a3  NUMBER
    , p0_a4  DATE
    , p0_a5  NUMBER
    , p0_a6  DATE
    , p0_a7  NUMBER
    , p0_a8  NUMBER
    , p0_a9  NUMBER
    , p0_a10  VARCHAR2
    , p1_a0  NUMBER
    , p1_a1  NUMBER
    , p1_a2  NUMBER
    , p1_a3  NUMBER
    , p1_a4  DATE
    , p1_a5  NUMBER
    , p1_a6  DATE
    , p1_a7  NUMBER
    , p1_a8  NUMBER
    , p1_a9  NUMBER
    , p1_a10  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_formula_rec ozf_actmetricfact_pvt.ozf_formula_rec_type;
    ddp_complete_formula_rec ozf_actmetricfact_pvt.ozf_formula_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_formula_rec.formula_id := p0_a0;
    ddp_formula_rec.activity_metric_id := p0_a1;
    ddp_formula_rec.level_depth := p0_a2;
    ddp_formula_rec.parent_formula_id := p0_a3;
    ddp_formula_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a4);
    ddp_formula_rec.last_updated_by := p0_a5;
    ddp_formula_rec.creation_date := rosetta_g_miss_date_in_map(p0_a6);
    ddp_formula_rec.created_by := p0_a7;
    ddp_formula_rec.last_update_login := p0_a8;
    ddp_formula_rec.object_version_number := p0_a9;
    ddp_formula_rec.formula_type := p0_a10;

    ddp_complete_formula_rec.formula_id := p1_a0;
    ddp_complete_formula_rec.activity_metric_id := p1_a1;
    ddp_complete_formula_rec.level_depth := p1_a2;
    ddp_complete_formula_rec.parent_formula_id := p1_a3;
    ddp_complete_formula_rec.last_update_date := rosetta_g_miss_date_in_map(p1_a4);
    ddp_complete_formula_rec.last_updated_by := p1_a5;
    ddp_complete_formula_rec.creation_date := rosetta_g_miss_date_in_map(p1_a6);
    ddp_complete_formula_rec.created_by := p1_a7;
    ddp_complete_formula_rec.last_update_login := p1_a8;
    ddp_complete_formula_rec.object_version_number := p1_a9;
    ddp_complete_formula_rec.formula_type := p1_a10;


    -- here's the delegated call to the old PL/SQL routine
    ozf_actmetricfact_pvt.validate_formula_rec(ddp_formula_rec,
      ddp_complete_formula_rec,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure create_formula_entry(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  NUMBER
    , p7_a2  NUMBER
    , p7_a3  VARCHAR2
    , p7_a4  VARCHAR2
    , p7_a5  VARCHAR2
    , p7_a6  VARCHAR2
    , p7_a7  DATE
    , p7_a8  NUMBER
    , p7_a9  DATE
    , p7_a10  NUMBER
    , p7_a11  NUMBER
    , p7_a12  NUMBER
    , x_formula_entry_id out nocopy  NUMBER
  )

  as
    ddp_formula_entry_rec ozf_actmetricfact_pvt.ozf_formula_entry_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_formula_entry_rec.formula_entry_id := p7_a0;
    ddp_formula_entry_rec.formula_id := p7_a1;
    ddp_formula_entry_rec.order_number := p7_a2;
    ddp_formula_entry_rec.formula_entry_type := p7_a3;
    ddp_formula_entry_rec.formula_entry_value := p7_a4;
    ddp_formula_entry_rec.metric_column_value := p7_a5;
    ddp_formula_entry_rec.formula_entry_operator := p7_a6;
    ddp_formula_entry_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a7);
    ddp_formula_entry_rec.last_updated_by := p7_a8;
    ddp_formula_entry_rec.creation_date := rosetta_g_miss_date_in_map(p7_a9);
    ddp_formula_entry_rec.created_by := p7_a10;
    ddp_formula_entry_rec.last_update_login := p7_a11;
    ddp_formula_entry_rec.object_version_number := p7_a12;


    -- here's the delegated call to the old PL/SQL routine
    ozf_actmetricfact_pvt.create_formula_entry(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_formula_entry_rec,
      x_formula_entry_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure validate_formula_entry(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0  NUMBER
    , p6_a1  NUMBER
    , p6_a2  NUMBER
    , p6_a3  VARCHAR2
    , p6_a4  VARCHAR2
    , p6_a5  VARCHAR2
    , p6_a6  VARCHAR2
    , p6_a7  DATE
    , p6_a8  NUMBER
    , p6_a9  DATE
    , p6_a10  NUMBER
    , p6_a11  NUMBER
    , p6_a12  NUMBER
  )

  as
    ddp_formula_entry_rec ozf_actmetricfact_pvt.ozf_formula_entry_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_formula_entry_rec.formula_entry_id := p6_a0;
    ddp_formula_entry_rec.formula_id := p6_a1;
    ddp_formula_entry_rec.order_number := p6_a2;
    ddp_formula_entry_rec.formula_entry_type := p6_a3;
    ddp_formula_entry_rec.formula_entry_value := p6_a4;
    ddp_formula_entry_rec.metric_column_value := p6_a5;
    ddp_formula_entry_rec.formula_entry_operator := p6_a6;
    ddp_formula_entry_rec.last_update_date := rosetta_g_miss_date_in_map(p6_a7);
    ddp_formula_entry_rec.last_updated_by := p6_a8;
    ddp_formula_entry_rec.creation_date := rosetta_g_miss_date_in_map(p6_a9);
    ddp_formula_entry_rec.created_by := p6_a10;
    ddp_formula_entry_rec.last_update_login := p6_a11;
    ddp_formula_entry_rec.object_version_number := p6_a12;

    -- here's the delegated call to the old PL/SQL routine
    ozf_actmetricfact_pvt.validate_formula_entry(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_formula_entry_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure validate_form_ent_items(p0_a0  NUMBER
    , p0_a1  NUMBER
    , p0_a2  NUMBER
    , p0_a3  VARCHAR2
    , p0_a4  VARCHAR2
    , p0_a5  VARCHAR2
    , p0_a6  VARCHAR2
    , p0_a7  DATE
    , p0_a8  NUMBER
    , p0_a9  DATE
    , p0_a10  NUMBER
    , p0_a11  NUMBER
    , p0_a12  NUMBER
    , p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_formula_entry_rec ozf_actmetricfact_pvt.ozf_formula_entry_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_formula_entry_rec.formula_entry_id := p0_a0;
    ddp_formula_entry_rec.formula_id := p0_a1;
    ddp_formula_entry_rec.order_number := p0_a2;
    ddp_formula_entry_rec.formula_entry_type := p0_a3;
    ddp_formula_entry_rec.formula_entry_value := p0_a4;
    ddp_formula_entry_rec.metric_column_value := p0_a5;
    ddp_formula_entry_rec.formula_entry_operator := p0_a6;
    ddp_formula_entry_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a7);
    ddp_formula_entry_rec.last_updated_by := p0_a8;
    ddp_formula_entry_rec.creation_date := rosetta_g_miss_date_in_map(p0_a9);
    ddp_formula_entry_rec.created_by := p0_a10;
    ddp_formula_entry_rec.last_update_login := p0_a11;
    ddp_formula_entry_rec.object_version_number := p0_a12;



    -- here's the delegated call to the old PL/SQL routine
    ozf_actmetricfact_pvt.validate_form_ent_items(ddp_formula_entry_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure validate_form_ent_rec(p0_a0  NUMBER
    , p0_a1  NUMBER
    , p0_a2  NUMBER
    , p0_a3  VARCHAR2
    , p0_a4  VARCHAR2
    , p0_a5  VARCHAR2
    , p0_a6  VARCHAR2
    , p0_a7  DATE
    , p0_a8  NUMBER
    , p0_a9  DATE
    , p0_a10  NUMBER
    , p0_a11  NUMBER
    , p0_a12  NUMBER
    , p1_a0  NUMBER
    , p1_a1  NUMBER
    , p1_a2  NUMBER
    , p1_a3  VARCHAR2
    , p1_a4  VARCHAR2
    , p1_a5  VARCHAR2
    , p1_a6  VARCHAR2
    , p1_a7  DATE
    , p1_a8  NUMBER
    , p1_a9  DATE
    , p1_a10  NUMBER
    , p1_a11  NUMBER
    , p1_a12  NUMBER
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_formula_entry_rec ozf_actmetricfact_pvt.ozf_formula_entry_rec_type;
    ddp_complete_formula_entry_rec ozf_actmetricfact_pvt.ozf_formula_entry_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_formula_entry_rec.formula_entry_id := p0_a0;
    ddp_formula_entry_rec.formula_id := p0_a1;
    ddp_formula_entry_rec.order_number := p0_a2;
    ddp_formula_entry_rec.formula_entry_type := p0_a3;
    ddp_formula_entry_rec.formula_entry_value := p0_a4;
    ddp_formula_entry_rec.metric_column_value := p0_a5;
    ddp_formula_entry_rec.formula_entry_operator := p0_a6;
    ddp_formula_entry_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a7);
    ddp_formula_entry_rec.last_updated_by := p0_a8;
    ddp_formula_entry_rec.creation_date := rosetta_g_miss_date_in_map(p0_a9);
    ddp_formula_entry_rec.created_by := p0_a10;
    ddp_formula_entry_rec.last_update_login := p0_a11;
    ddp_formula_entry_rec.object_version_number := p0_a12;

    ddp_complete_formula_entry_rec.formula_entry_id := p1_a0;
    ddp_complete_formula_entry_rec.formula_id := p1_a1;
    ddp_complete_formula_entry_rec.order_number := p1_a2;
    ddp_complete_formula_entry_rec.formula_entry_type := p1_a3;
    ddp_complete_formula_entry_rec.formula_entry_value := p1_a4;
    ddp_complete_formula_entry_rec.metric_column_value := p1_a5;
    ddp_complete_formula_entry_rec.formula_entry_operator := p1_a6;
    ddp_complete_formula_entry_rec.last_update_date := rosetta_g_miss_date_in_map(p1_a7);
    ddp_complete_formula_entry_rec.last_updated_by := p1_a8;
    ddp_complete_formula_entry_rec.creation_date := rosetta_g_miss_date_in_map(p1_a9);
    ddp_complete_formula_entry_rec.created_by := p1_a10;
    ddp_complete_formula_entry_rec.last_update_login := p1_a11;
    ddp_complete_formula_entry_rec.object_version_number := p1_a12;


    -- here's the delegated call to the old PL/SQL routine
    ozf_actmetricfact_pvt.validate_form_ent_rec(ddp_formula_entry_rec,
      ddp_complete_formula_entry_rec,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

end ozf_actmetricfact_pvt_w;

/
