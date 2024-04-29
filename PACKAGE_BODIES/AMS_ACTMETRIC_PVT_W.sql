--------------------------------------------------------
--  DDL for Package Body AMS_ACTMETRIC_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_ACTMETRIC_PVT_W" as
  /* $Header: amswamtb.pls 120.2 2006/03/23 04:12 mayjain noship $ */
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

  function rosetta_g_miss_num_map(n number) return number as
    a number := fnd_api.g_miss_num;
    b number := 0-1962.0724;
  begin
    if n=a then return b; end if;
    if n=b then return a; end if;
    return n;
  end;

  procedure rosetta_table_copy_in_p1(t out nocopy ams_actmetric_pvt.currency_table, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is null then
    t := null;
  elsif a0.count = 0 then
    t := ams_actmetric_pvt.currency_table();
  else
      if a0.count > 0 then
      t := ams_actmetric_pvt.currency_table();
      t.extend(a0.count);
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := rosetta_g_miss_num_map(a0(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t ams_actmetric_pvt.currency_table, a0 out nocopy JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null then
    a0 := null;
  elsif t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx));
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure rosetta_table_copy_in_p28(t out nocopy ams_actmetric_pvt.result_table, a0 JTF_DATE_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count=0 then
    t := ams_actmetric_pvt.result_table();
  elsif a0 is not null and a0.count > 0 then
      if a0.count > 0 then
      t := ams_actmetric_pvt.result_table();
      t.extend(a0.count);
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).slice_date := rosetta_g_miss_date_in_map(a0(indx));
          t(ddindx).currency_code := a1(indx);
          t(ddindx).forecasted_value := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).actual_value := rosetta_g_miss_num_map(a3(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p28;
  procedure rosetta_table_copy_out_p28(t ams_actmetric_pvt.result_table, a0 out nocopy JTF_DATE_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null then
    a0 := null;
    a1 := null;
    a2 := null;
    a3 := null;
  elsif t.count = 0 then
    a0 := JTF_DATE_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_DATE_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).slice_date;
          a1(indx) := t(ddindx).currency_code;
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).forecasted_value);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).actual_value);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p28;

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
    , p0_a26 in out nocopy  NUMBER
    , p0_a27 in out nocopy  VARCHAR2
    , p0_a28 in out nocopy  NUMBER
    , p0_a29 in out nocopy  NUMBER
    , p0_a30 in out nocopy  NUMBER
    , p0_a31 in out nocopy  VARCHAR2
    , p0_a32 in out nocopy  NUMBER
    , p0_a33 in out nocopy  NUMBER
    , p0_a34 in out nocopy  NUMBER
    , p0_a35 in out nocopy  NUMBER
    , p0_a36 in out nocopy  NUMBER
    , p0_a37 in out nocopy  NUMBER
    , p0_a38 in out nocopy  NUMBER
    , p0_a39 in out nocopy  NUMBER
    , p0_a40 in out nocopy  DATE
    , p0_a41 in out nocopy  DATE
    , p0_a42 in out nocopy  NUMBER
    , p0_a43 in out nocopy  NUMBER
    , p0_a44 in out nocopy  NUMBER
    , p0_a45 in out nocopy  NUMBER
    , p0_a46 in out nocopy  NUMBER
    , p0_a47 in out nocopy  NUMBER
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
    , p0_a67 in out nocopy  VARCHAR2
    , p0_a68 in out nocopy  DATE
    , p0_a69 in out nocopy  NUMBER
    , p0_a70 in out nocopy  NUMBER
    , p0_a71 in out nocopy  VARCHAR2
    , p0_a72 in out nocopy  VARCHAR2
    , p0_a73 in out nocopy  VARCHAR2
    , p0_a74 in out nocopy  VARCHAR2
    , p0_a75 in out nocopy  VARCHAR2
    , p0_a76 in out nocopy  NUMBER
    , p0_a77 in out nocopy  VARCHAR2
  )

  as
    ddx_act_metric_rec ams_actmetric_pvt.act_metric_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddx_act_metric_rec.activity_metric_id := rosetta_g_miss_num_map(p0_a0);
    ddx_act_metric_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddx_act_metric_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddx_act_metric_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddx_act_metric_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddx_act_metric_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddx_act_metric_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddx_act_metric_rec.act_metric_used_by_id := rosetta_g_miss_num_map(p0_a7);
    ddx_act_metric_rec.arc_act_metric_used_by := p0_a8;
    ddx_act_metric_rec.purchase_req_raised_flag := p0_a9;
    ddx_act_metric_rec.application_id := rosetta_g_miss_num_map(p0_a10);
    ddx_act_metric_rec.sensitive_data_flag := p0_a11;
    ddx_act_metric_rec.budget_id := rosetta_g_miss_num_map(p0_a12);
    ddx_act_metric_rec.metric_id := rosetta_g_miss_num_map(p0_a13);
    ddx_act_metric_rec.transaction_currency_code := p0_a14;
    ddx_act_metric_rec.trans_forecasted_value := rosetta_g_miss_num_map(p0_a15);
    ddx_act_metric_rec.trans_committed_value := rosetta_g_miss_num_map(p0_a16);
    ddx_act_metric_rec.trans_actual_value := rosetta_g_miss_num_map(p0_a17);
    ddx_act_metric_rec.functional_currency_code := p0_a18;
    ddx_act_metric_rec.func_forecasted_value := rosetta_g_miss_num_map(p0_a19);
    ddx_act_metric_rec.dirty_flag := p0_a20;
    ddx_act_metric_rec.func_committed_value := rosetta_g_miss_num_map(p0_a21);
    ddx_act_metric_rec.func_actual_value := rosetta_g_miss_num_map(p0_a22);
    ddx_act_metric_rec.last_calculated_date := rosetta_g_miss_date_in_map(p0_a23);
    ddx_act_metric_rec.variable_value := rosetta_g_miss_num_map(p0_a24);
    ddx_act_metric_rec.forecasted_variable_value := rosetta_g_miss_num_map(p0_a25);
    ddx_act_metric_rec.computed_using_function_value := rosetta_g_miss_num_map(p0_a26);
    ddx_act_metric_rec.metric_uom_code := p0_a27;
    ddx_act_metric_rec.org_id := rosetta_g_miss_num_map(p0_a28);
    ddx_act_metric_rec.difference_since_last_calc := rosetta_g_miss_num_map(p0_a29);
    ddx_act_metric_rec.activity_metric_origin_id := rosetta_g_miss_num_map(p0_a30);
    ddx_act_metric_rec.arc_activity_metric_origin := p0_a31;
    ddx_act_metric_rec.days_since_last_refresh := rosetta_g_miss_num_map(p0_a32);
    ddx_act_metric_rec.scenario_id := rosetta_g_miss_num_map(p0_a33);
    ddx_act_metric_rec.summarize_to_metric := rosetta_g_miss_num_map(p0_a34);
    ddx_act_metric_rec.rollup_to_metric := rosetta_g_miss_num_map(p0_a35);
    ddx_act_metric_rec.hierarchy_id := rosetta_g_miss_num_map(p0_a36);
    ddx_act_metric_rec.start_node := rosetta_g_miss_num_map(p0_a37);
    ddx_act_metric_rec.from_level := rosetta_g_miss_num_map(p0_a38);
    ddx_act_metric_rec.to_level := rosetta_g_miss_num_map(p0_a39);
    ddx_act_metric_rec.from_date := rosetta_g_miss_date_in_map(p0_a40);
    ddx_act_metric_rec.to_date := rosetta_g_miss_date_in_map(p0_a41);
    ddx_act_metric_rec.amount1 := rosetta_g_miss_num_map(p0_a42);
    ddx_act_metric_rec.amount2 := rosetta_g_miss_num_map(p0_a43);
    ddx_act_metric_rec.amount3 := rosetta_g_miss_num_map(p0_a44);
    ddx_act_metric_rec.percent1 := rosetta_g_miss_num_map(p0_a45);
    ddx_act_metric_rec.percent2 := rosetta_g_miss_num_map(p0_a46);
    ddx_act_metric_rec.percent3 := rosetta_g_miss_num_map(p0_a47);
    ddx_act_metric_rec.published_flag := p0_a48;
    ddx_act_metric_rec.pre_function_name := p0_a49;
    ddx_act_metric_rec.post_function_name := p0_a50;
    ddx_act_metric_rec.attribute_category := p0_a51;
    ddx_act_metric_rec.attribute1 := p0_a52;
    ddx_act_metric_rec.attribute2 := p0_a53;
    ddx_act_metric_rec.attribute3 := p0_a54;
    ddx_act_metric_rec.attribute4 := p0_a55;
    ddx_act_metric_rec.attribute5 := p0_a56;
    ddx_act_metric_rec.attribute6 := p0_a57;
    ddx_act_metric_rec.attribute7 := p0_a58;
    ddx_act_metric_rec.attribute8 := p0_a59;
    ddx_act_metric_rec.attribute9 := p0_a60;
    ddx_act_metric_rec.attribute10 := p0_a61;
    ddx_act_metric_rec.attribute11 := p0_a62;
    ddx_act_metric_rec.attribute12 := p0_a63;
    ddx_act_metric_rec.attribute13 := p0_a64;
    ddx_act_metric_rec.attribute14 := p0_a65;
    ddx_act_metric_rec.attribute15 := p0_a66;
    ddx_act_metric_rec.description := p0_a67;
    ddx_act_metric_rec.act_metric_date := rosetta_g_miss_date_in_map(p0_a68);
    ddx_act_metric_rec.depend_act_metric := rosetta_g_miss_num_map(p0_a69);
    ddx_act_metric_rec.function_used_by_id := rosetta_g_miss_num_map(p0_a70);
    ddx_act_metric_rec.arc_function_used_by := p0_a71;
    ddx_act_metric_rec.hierarchy_type := p0_a72;
    ddx_act_metric_rec.status_code := p0_a73;
    ddx_act_metric_rec.method_code := p0_a74;
    ddx_act_metric_rec.action_code := p0_a75;
    ddx_act_metric_rec.basis_year := rosetta_g_miss_num_map(p0_a76);
    ddx_act_metric_rec.ex_start_node := p0_a77;

    -- here's the delegated call to the old PL/SQL routine
    ams_actmetric_pvt.init_actmetric_rec(ddx_act_metric_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    p0_a0 := rosetta_g_miss_num_map(ddx_act_metric_rec.activity_metric_id);
    p0_a1 := ddx_act_metric_rec.last_update_date;
    p0_a2 := rosetta_g_miss_num_map(ddx_act_metric_rec.last_updated_by);
    p0_a3 := ddx_act_metric_rec.creation_date;
    p0_a4 := rosetta_g_miss_num_map(ddx_act_metric_rec.created_by);
    p0_a5 := rosetta_g_miss_num_map(ddx_act_metric_rec.last_update_login);
    p0_a6 := rosetta_g_miss_num_map(ddx_act_metric_rec.object_version_number);
    p0_a7 := rosetta_g_miss_num_map(ddx_act_metric_rec.act_metric_used_by_id);
    p0_a8 := ddx_act_metric_rec.arc_act_metric_used_by;
    p0_a9 := ddx_act_metric_rec.purchase_req_raised_flag;
    p0_a10 := rosetta_g_miss_num_map(ddx_act_metric_rec.application_id);
    p0_a11 := ddx_act_metric_rec.sensitive_data_flag;
    p0_a12 := rosetta_g_miss_num_map(ddx_act_metric_rec.budget_id);
    p0_a13 := rosetta_g_miss_num_map(ddx_act_metric_rec.metric_id);
    p0_a14 := ddx_act_metric_rec.transaction_currency_code;
    p0_a15 := rosetta_g_miss_num_map(ddx_act_metric_rec.trans_forecasted_value);
    p0_a16 := rosetta_g_miss_num_map(ddx_act_metric_rec.trans_committed_value);
    p0_a17 := rosetta_g_miss_num_map(ddx_act_metric_rec.trans_actual_value);
    p0_a18 := ddx_act_metric_rec.functional_currency_code;
    p0_a19 := rosetta_g_miss_num_map(ddx_act_metric_rec.func_forecasted_value);
    p0_a20 := ddx_act_metric_rec.dirty_flag;
    p0_a21 := rosetta_g_miss_num_map(ddx_act_metric_rec.func_committed_value);
    p0_a22 := rosetta_g_miss_num_map(ddx_act_metric_rec.func_actual_value);
    p0_a23 := ddx_act_metric_rec.last_calculated_date;
    p0_a24 := rosetta_g_miss_num_map(ddx_act_metric_rec.variable_value);
    p0_a25 := rosetta_g_miss_num_map(ddx_act_metric_rec.forecasted_variable_value);
    p0_a26 := rosetta_g_miss_num_map(ddx_act_metric_rec.computed_using_function_value);
    p0_a27 := ddx_act_metric_rec.metric_uom_code;
    p0_a28 := rosetta_g_miss_num_map(ddx_act_metric_rec.org_id);
    p0_a29 := rosetta_g_miss_num_map(ddx_act_metric_rec.difference_since_last_calc);
    p0_a30 := rosetta_g_miss_num_map(ddx_act_metric_rec.activity_metric_origin_id);
    p0_a31 := ddx_act_metric_rec.arc_activity_metric_origin;
    p0_a32 := rosetta_g_miss_num_map(ddx_act_metric_rec.days_since_last_refresh);
    p0_a33 := rosetta_g_miss_num_map(ddx_act_metric_rec.scenario_id);
    p0_a34 := rosetta_g_miss_num_map(ddx_act_metric_rec.summarize_to_metric);
    p0_a35 := rosetta_g_miss_num_map(ddx_act_metric_rec.rollup_to_metric);
    p0_a36 := rosetta_g_miss_num_map(ddx_act_metric_rec.hierarchy_id);
    p0_a37 := rosetta_g_miss_num_map(ddx_act_metric_rec.start_node);
    p0_a38 := rosetta_g_miss_num_map(ddx_act_metric_rec.from_level);
    p0_a39 := rosetta_g_miss_num_map(ddx_act_metric_rec.to_level);
    p0_a40 := ddx_act_metric_rec.from_date;
    p0_a41 := ddx_act_metric_rec.to_date;
    p0_a42 := rosetta_g_miss_num_map(ddx_act_metric_rec.amount1);
    p0_a43 := rosetta_g_miss_num_map(ddx_act_metric_rec.amount2);
    p0_a44 := rosetta_g_miss_num_map(ddx_act_metric_rec.amount3);
    p0_a45 := rosetta_g_miss_num_map(ddx_act_metric_rec.percent1);
    p0_a46 := rosetta_g_miss_num_map(ddx_act_metric_rec.percent2);
    p0_a47 := rosetta_g_miss_num_map(ddx_act_metric_rec.percent3);
    p0_a48 := ddx_act_metric_rec.published_flag;
    p0_a49 := ddx_act_metric_rec.pre_function_name;
    p0_a50 := ddx_act_metric_rec.post_function_name;
    p0_a51 := ddx_act_metric_rec.attribute_category;
    p0_a52 := ddx_act_metric_rec.attribute1;
    p0_a53 := ddx_act_metric_rec.attribute2;
    p0_a54 := ddx_act_metric_rec.attribute3;
    p0_a55 := ddx_act_metric_rec.attribute4;
    p0_a56 := ddx_act_metric_rec.attribute5;
    p0_a57 := ddx_act_metric_rec.attribute6;
    p0_a58 := ddx_act_metric_rec.attribute7;
    p0_a59 := ddx_act_metric_rec.attribute8;
    p0_a60 := ddx_act_metric_rec.attribute9;
    p0_a61 := ddx_act_metric_rec.attribute10;
    p0_a62 := ddx_act_metric_rec.attribute11;
    p0_a63 := ddx_act_metric_rec.attribute12;
    p0_a64 := ddx_act_metric_rec.attribute13;
    p0_a65 := ddx_act_metric_rec.attribute14;
    p0_a66 := ddx_act_metric_rec.attribute15;
    p0_a67 := ddx_act_metric_rec.description;
    p0_a68 := ddx_act_metric_rec.act_metric_date;
    p0_a69 := rosetta_g_miss_num_map(ddx_act_metric_rec.depend_act_metric);
    p0_a70 := rosetta_g_miss_num_map(ddx_act_metric_rec.function_used_by_id);
    p0_a71 := ddx_act_metric_rec.arc_function_used_by;
    p0_a72 := ddx_act_metric_rec.hierarchy_type;
    p0_a73 := ddx_act_metric_rec.status_code;
    p0_a74 := ddx_act_metric_rec.method_code;
    p0_a75 := ddx_act_metric_rec.action_code;
    p0_a76 := rosetta_g_miss_num_map(ddx_act_metric_rec.basis_year);
    p0_a77 := ddx_act_metric_rec.ex_start_node;
  end;

  procedure create_actmetric(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_activity_metric_id out nocopy  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  DATE := fnd_api.g_miss_date
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  DATE := fnd_api.g_miss_date
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  NUMBER := 0-1962.0724
    , p7_a13  NUMBER := 0-1962.0724
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  NUMBER := 0-1962.0724
    , p7_a16  NUMBER := 0-1962.0724
    , p7_a17  NUMBER := 0-1962.0724
    , p7_a18  VARCHAR2 := fnd_api.g_miss_char
    , p7_a19  NUMBER := 0-1962.0724
    , p7_a20  VARCHAR2 := fnd_api.g_miss_char
    , p7_a21  NUMBER := 0-1962.0724
    , p7_a22  NUMBER := 0-1962.0724
    , p7_a23  DATE := fnd_api.g_miss_date
    , p7_a24  NUMBER := 0-1962.0724
    , p7_a25  NUMBER := 0-1962.0724
    , p7_a26  NUMBER := 0-1962.0724
    , p7_a27  VARCHAR2 := fnd_api.g_miss_char
    , p7_a28  NUMBER := 0-1962.0724
    , p7_a29  NUMBER := 0-1962.0724
    , p7_a30  NUMBER := 0-1962.0724
    , p7_a31  VARCHAR2 := fnd_api.g_miss_char
    , p7_a32  NUMBER := 0-1962.0724
    , p7_a33  NUMBER := 0-1962.0724
    , p7_a34  NUMBER := 0-1962.0724
    , p7_a35  NUMBER := 0-1962.0724
    , p7_a36  NUMBER := 0-1962.0724
    , p7_a37  NUMBER := 0-1962.0724
    , p7_a38  NUMBER := 0-1962.0724
    , p7_a39  NUMBER := 0-1962.0724
    , p7_a40  DATE := fnd_api.g_miss_date
    , p7_a41  DATE := fnd_api.g_miss_date
    , p7_a42  NUMBER := 0-1962.0724
    , p7_a43  NUMBER := 0-1962.0724
    , p7_a44  NUMBER := 0-1962.0724
    , p7_a45  NUMBER := 0-1962.0724
    , p7_a46  NUMBER := 0-1962.0724
    , p7_a47  NUMBER := 0-1962.0724
    , p7_a48  VARCHAR2 := fnd_api.g_miss_char
    , p7_a49  VARCHAR2 := fnd_api.g_miss_char
    , p7_a50  VARCHAR2 := fnd_api.g_miss_char
    , p7_a51  VARCHAR2 := fnd_api.g_miss_char
    , p7_a52  VARCHAR2 := fnd_api.g_miss_char
    , p7_a53  VARCHAR2 := fnd_api.g_miss_char
    , p7_a54  VARCHAR2 := fnd_api.g_miss_char
    , p7_a55  VARCHAR2 := fnd_api.g_miss_char
    , p7_a56  VARCHAR2 := fnd_api.g_miss_char
    , p7_a57  VARCHAR2 := fnd_api.g_miss_char
    , p7_a58  VARCHAR2 := fnd_api.g_miss_char
    , p7_a59  VARCHAR2 := fnd_api.g_miss_char
    , p7_a60  VARCHAR2 := fnd_api.g_miss_char
    , p7_a61  VARCHAR2 := fnd_api.g_miss_char
    , p7_a62  VARCHAR2 := fnd_api.g_miss_char
    , p7_a63  VARCHAR2 := fnd_api.g_miss_char
    , p7_a64  VARCHAR2 := fnd_api.g_miss_char
    , p7_a65  VARCHAR2 := fnd_api.g_miss_char
    , p7_a66  VARCHAR2 := fnd_api.g_miss_char
    , p7_a67  VARCHAR2 := fnd_api.g_miss_char
    , p7_a68  DATE := fnd_api.g_miss_date
    , p7_a69  NUMBER := 0-1962.0724
    , p7_a70  NUMBER := 0-1962.0724
    , p7_a71  VARCHAR2 := fnd_api.g_miss_char
    , p7_a72  VARCHAR2 := fnd_api.g_miss_char
    , p7_a73  VARCHAR2 := fnd_api.g_miss_char
    , p7_a74  VARCHAR2 := fnd_api.g_miss_char
    , p7_a75  VARCHAR2 := fnd_api.g_miss_char
    , p7_a76  NUMBER := 0-1962.0724
    , p7_a77  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_act_metric_rec ams_actmetric_pvt.act_metric_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_act_metric_rec.activity_metric_id := rosetta_g_miss_num_map(p7_a0);
    ddp_act_metric_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_act_metric_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_act_metric_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_act_metric_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_act_metric_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_act_metric_rec.object_version_number := rosetta_g_miss_num_map(p7_a6);
    ddp_act_metric_rec.act_metric_used_by_id := rosetta_g_miss_num_map(p7_a7);
    ddp_act_metric_rec.arc_act_metric_used_by := p7_a8;
    ddp_act_metric_rec.purchase_req_raised_flag := p7_a9;
    ddp_act_metric_rec.application_id := rosetta_g_miss_num_map(p7_a10);
    ddp_act_metric_rec.sensitive_data_flag := p7_a11;
    ddp_act_metric_rec.budget_id := rosetta_g_miss_num_map(p7_a12);
    ddp_act_metric_rec.metric_id := rosetta_g_miss_num_map(p7_a13);
    ddp_act_metric_rec.transaction_currency_code := p7_a14;
    ddp_act_metric_rec.trans_forecasted_value := rosetta_g_miss_num_map(p7_a15);
    ddp_act_metric_rec.trans_committed_value := rosetta_g_miss_num_map(p7_a16);
    ddp_act_metric_rec.trans_actual_value := rosetta_g_miss_num_map(p7_a17);
    ddp_act_metric_rec.functional_currency_code := p7_a18;
    ddp_act_metric_rec.func_forecasted_value := rosetta_g_miss_num_map(p7_a19);
    ddp_act_metric_rec.dirty_flag := p7_a20;
    ddp_act_metric_rec.func_committed_value := rosetta_g_miss_num_map(p7_a21);
    ddp_act_metric_rec.func_actual_value := rosetta_g_miss_num_map(p7_a22);
    ddp_act_metric_rec.last_calculated_date := rosetta_g_miss_date_in_map(p7_a23);
    ddp_act_metric_rec.variable_value := rosetta_g_miss_num_map(p7_a24);
    ddp_act_metric_rec.forecasted_variable_value := rosetta_g_miss_num_map(p7_a25);
    ddp_act_metric_rec.computed_using_function_value := rosetta_g_miss_num_map(p7_a26);
    ddp_act_metric_rec.metric_uom_code := p7_a27;
    ddp_act_metric_rec.org_id := rosetta_g_miss_num_map(p7_a28);
    ddp_act_metric_rec.difference_since_last_calc := rosetta_g_miss_num_map(p7_a29);
    ddp_act_metric_rec.activity_metric_origin_id := rosetta_g_miss_num_map(p7_a30);
    ddp_act_metric_rec.arc_activity_metric_origin := p7_a31;
    ddp_act_metric_rec.days_since_last_refresh := rosetta_g_miss_num_map(p7_a32);
    ddp_act_metric_rec.scenario_id := rosetta_g_miss_num_map(p7_a33);
    ddp_act_metric_rec.summarize_to_metric := rosetta_g_miss_num_map(p7_a34);
    ddp_act_metric_rec.rollup_to_metric := rosetta_g_miss_num_map(p7_a35);
    ddp_act_metric_rec.hierarchy_id := rosetta_g_miss_num_map(p7_a36);
    ddp_act_metric_rec.start_node := rosetta_g_miss_num_map(p7_a37);
    ddp_act_metric_rec.from_level := rosetta_g_miss_num_map(p7_a38);
    ddp_act_metric_rec.to_level := rosetta_g_miss_num_map(p7_a39);
    ddp_act_metric_rec.from_date := rosetta_g_miss_date_in_map(p7_a40);
    ddp_act_metric_rec.to_date := rosetta_g_miss_date_in_map(p7_a41);
    ddp_act_metric_rec.amount1 := rosetta_g_miss_num_map(p7_a42);
    ddp_act_metric_rec.amount2 := rosetta_g_miss_num_map(p7_a43);
    ddp_act_metric_rec.amount3 := rosetta_g_miss_num_map(p7_a44);
    ddp_act_metric_rec.percent1 := rosetta_g_miss_num_map(p7_a45);
    ddp_act_metric_rec.percent2 := rosetta_g_miss_num_map(p7_a46);
    ddp_act_metric_rec.percent3 := rosetta_g_miss_num_map(p7_a47);
    ddp_act_metric_rec.published_flag := p7_a48;
    ddp_act_metric_rec.pre_function_name := p7_a49;
    ddp_act_metric_rec.post_function_name := p7_a50;
    ddp_act_metric_rec.attribute_category := p7_a51;
    ddp_act_metric_rec.attribute1 := p7_a52;
    ddp_act_metric_rec.attribute2 := p7_a53;
    ddp_act_metric_rec.attribute3 := p7_a54;
    ddp_act_metric_rec.attribute4 := p7_a55;
    ddp_act_metric_rec.attribute5 := p7_a56;
    ddp_act_metric_rec.attribute6 := p7_a57;
    ddp_act_metric_rec.attribute7 := p7_a58;
    ddp_act_metric_rec.attribute8 := p7_a59;
    ddp_act_metric_rec.attribute9 := p7_a60;
    ddp_act_metric_rec.attribute10 := p7_a61;
    ddp_act_metric_rec.attribute11 := p7_a62;
    ddp_act_metric_rec.attribute12 := p7_a63;
    ddp_act_metric_rec.attribute13 := p7_a64;
    ddp_act_metric_rec.attribute14 := p7_a65;
    ddp_act_metric_rec.attribute15 := p7_a66;
    ddp_act_metric_rec.description := p7_a67;
    ddp_act_metric_rec.act_metric_date := rosetta_g_miss_date_in_map(p7_a68);
    ddp_act_metric_rec.depend_act_metric := rosetta_g_miss_num_map(p7_a69);
    ddp_act_metric_rec.function_used_by_id := rosetta_g_miss_num_map(p7_a70);
    ddp_act_metric_rec.arc_function_used_by := p7_a71;
    ddp_act_metric_rec.hierarchy_type := p7_a72;
    ddp_act_metric_rec.status_code := p7_a73;
    ddp_act_metric_rec.method_code := p7_a74;
    ddp_act_metric_rec.action_code := p7_a75;
    ddp_act_metric_rec.basis_year := rosetta_g_miss_num_map(p7_a76);
    ddp_act_metric_rec.ex_start_node := p7_a77;


    -- here's the delegated call to the old PL/SQL routine
    ams_actmetric_pvt.create_actmetric(p_api_version,
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
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  DATE := fnd_api.g_miss_date
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  DATE := fnd_api.g_miss_date
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  NUMBER := 0-1962.0724
    , p7_a13  NUMBER := 0-1962.0724
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  NUMBER := 0-1962.0724
    , p7_a16  NUMBER := 0-1962.0724
    , p7_a17  NUMBER := 0-1962.0724
    , p7_a18  VARCHAR2 := fnd_api.g_miss_char
    , p7_a19  NUMBER := 0-1962.0724
    , p7_a20  VARCHAR2 := fnd_api.g_miss_char
    , p7_a21  NUMBER := 0-1962.0724
    , p7_a22  NUMBER := 0-1962.0724
    , p7_a23  DATE := fnd_api.g_miss_date
    , p7_a24  NUMBER := 0-1962.0724
    , p7_a25  NUMBER := 0-1962.0724
    , p7_a26  NUMBER := 0-1962.0724
    , p7_a27  VARCHAR2 := fnd_api.g_miss_char
    , p7_a28  NUMBER := 0-1962.0724
    , p7_a29  NUMBER := 0-1962.0724
    , p7_a30  NUMBER := 0-1962.0724
    , p7_a31  VARCHAR2 := fnd_api.g_miss_char
    , p7_a32  NUMBER := 0-1962.0724
    , p7_a33  NUMBER := 0-1962.0724
    , p7_a34  NUMBER := 0-1962.0724
    , p7_a35  NUMBER := 0-1962.0724
    , p7_a36  NUMBER := 0-1962.0724
    , p7_a37  NUMBER := 0-1962.0724
    , p7_a38  NUMBER := 0-1962.0724
    , p7_a39  NUMBER := 0-1962.0724
    , p7_a40  DATE := fnd_api.g_miss_date
    , p7_a41  DATE := fnd_api.g_miss_date
    , p7_a42  NUMBER := 0-1962.0724
    , p7_a43  NUMBER := 0-1962.0724
    , p7_a44  NUMBER := 0-1962.0724
    , p7_a45  NUMBER := 0-1962.0724
    , p7_a46  NUMBER := 0-1962.0724
    , p7_a47  NUMBER := 0-1962.0724
    , p7_a48  VARCHAR2 := fnd_api.g_miss_char
    , p7_a49  VARCHAR2 := fnd_api.g_miss_char
    , p7_a50  VARCHAR2 := fnd_api.g_miss_char
    , p7_a51  VARCHAR2 := fnd_api.g_miss_char
    , p7_a52  VARCHAR2 := fnd_api.g_miss_char
    , p7_a53  VARCHAR2 := fnd_api.g_miss_char
    , p7_a54  VARCHAR2 := fnd_api.g_miss_char
    , p7_a55  VARCHAR2 := fnd_api.g_miss_char
    , p7_a56  VARCHAR2 := fnd_api.g_miss_char
    , p7_a57  VARCHAR2 := fnd_api.g_miss_char
    , p7_a58  VARCHAR2 := fnd_api.g_miss_char
    , p7_a59  VARCHAR2 := fnd_api.g_miss_char
    , p7_a60  VARCHAR2 := fnd_api.g_miss_char
    , p7_a61  VARCHAR2 := fnd_api.g_miss_char
    , p7_a62  VARCHAR2 := fnd_api.g_miss_char
    , p7_a63  VARCHAR2 := fnd_api.g_miss_char
    , p7_a64  VARCHAR2 := fnd_api.g_miss_char
    , p7_a65  VARCHAR2 := fnd_api.g_miss_char
    , p7_a66  VARCHAR2 := fnd_api.g_miss_char
    , p7_a67  VARCHAR2 := fnd_api.g_miss_char
    , p7_a68  DATE := fnd_api.g_miss_date
    , p7_a69  NUMBER := 0-1962.0724
    , p7_a70  NUMBER := 0-1962.0724
    , p7_a71  VARCHAR2 := fnd_api.g_miss_char
    , p7_a72  VARCHAR2 := fnd_api.g_miss_char
    , p7_a73  VARCHAR2 := fnd_api.g_miss_char
    , p7_a74  VARCHAR2 := fnd_api.g_miss_char
    , p7_a75  VARCHAR2 := fnd_api.g_miss_char
    , p7_a76  NUMBER := 0-1962.0724
    , p7_a77  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_act_metric_rec ams_actmetric_pvt.act_metric_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_act_metric_rec.activity_metric_id := rosetta_g_miss_num_map(p7_a0);
    ddp_act_metric_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_act_metric_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_act_metric_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_act_metric_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_act_metric_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_act_metric_rec.object_version_number := rosetta_g_miss_num_map(p7_a6);
    ddp_act_metric_rec.act_metric_used_by_id := rosetta_g_miss_num_map(p7_a7);
    ddp_act_metric_rec.arc_act_metric_used_by := p7_a8;
    ddp_act_metric_rec.purchase_req_raised_flag := p7_a9;
    ddp_act_metric_rec.application_id := rosetta_g_miss_num_map(p7_a10);
    ddp_act_metric_rec.sensitive_data_flag := p7_a11;
    ddp_act_metric_rec.budget_id := rosetta_g_miss_num_map(p7_a12);
    ddp_act_metric_rec.metric_id := rosetta_g_miss_num_map(p7_a13);
    ddp_act_metric_rec.transaction_currency_code := p7_a14;
    ddp_act_metric_rec.trans_forecasted_value := rosetta_g_miss_num_map(p7_a15);
    ddp_act_metric_rec.trans_committed_value := rosetta_g_miss_num_map(p7_a16);
    ddp_act_metric_rec.trans_actual_value := rosetta_g_miss_num_map(p7_a17);
    ddp_act_metric_rec.functional_currency_code := p7_a18;
    ddp_act_metric_rec.func_forecasted_value := rosetta_g_miss_num_map(p7_a19);
    ddp_act_metric_rec.dirty_flag := p7_a20;
    ddp_act_metric_rec.func_committed_value := rosetta_g_miss_num_map(p7_a21);
    ddp_act_metric_rec.func_actual_value := rosetta_g_miss_num_map(p7_a22);
    ddp_act_metric_rec.last_calculated_date := rosetta_g_miss_date_in_map(p7_a23);
    ddp_act_metric_rec.variable_value := rosetta_g_miss_num_map(p7_a24);
    ddp_act_metric_rec.forecasted_variable_value := rosetta_g_miss_num_map(p7_a25);
    ddp_act_metric_rec.computed_using_function_value := rosetta_g_miss_num_map(p7_a26);
    ddp_act_metric_rec.metric_uom_code := p7_a27;
    ddp_act_metric_rec.org_id := rosetta_g_miss_num_map(p7_a28);
    ddp_act_metric_rec.difference_since_last_calc := rosetta_g_miss_num_map(p7_a29);
    ddp_act_metric_rec.activity_metric_origin_id := rosetta_g_miss_num_map(p7_a30);
    ddp_act_metric_rec.arc_activity_metric_origin := p7_a31;
    ddp_act_metric_rec.days_since_last_refresh := rosetta_g_miss_num_map(p7_a32);
    ddp_act_metric_rec.scenario_id := rosetta_g_miss_num_map(p7_a33);
    ddp_act_metric_rec.summarize_to_metric := rosetta_g_miss_num_map(p7_a34);
    ddp_act_metric_rec.rollup_to_metric := rosetta_g_miss_num_map(p7_a35);
    ddp_act_metric_rec.hierarchy_id := rosetta_g_miss_num_map(p7_a36);
    ddp_act_metric_rec.start_node := rosetta_g_miss_num_map(p7_a37);
    ddp_act_metric_rec.from_level := rosetta_g_miss_num_map(p7_a38);
    ddp_act_metric_rec.to_level := rosetta_g_miss_num_map(p7_a39);
    ddp_act_metric_rec.from_date := rosetta_g_miss_date_in_map(p7_a40);
    ddp_act_metric_rec.to_date := rosetta_g_miss_date_in_map(p7_a41);
    ddp_act_metric_rec.amount1 := rosetta_g_miss_num_map(p7_a42);
    ddp_act_metric_rec.amount2 := rosetta_g_miss_num_map(p7_a43);
    ddp_act_metric_rec.amount3 := rosetta_g_miss_num_map(p7_a44);
    ddp_act_metric_rec.percent1 := rosetta_g_miss_num_map(p7_a45);
    ddp_act_metric_rec.percent2 := rosetta_g_miss_num_map(p7_a46);
    ddp_act_metric_rec.percent3 := rosetta_g_miss_num_map(p7_a47);
    ddp_act_metric_rec.published_flag := p7_a48;
    ddp_act_metric_rec.pre_function_name := p7_a49;
    ddp_act_metric_rec.post_function_name := p7_a50;
    ddp_act_metric_rec.attribute_category := p7_a51;
    ddp_act_metric_rec.attribute1 := p7_a52;
    ddp_act_metric_rec.attribute2 := p7_a53;
    ddp_act_metric_rec.attribute3 := p7_a54;
    ddp_act_metric_rec.attribute4 := p7_a55;
    ddp_act_metric_rec.attribute5 := p7_a56;
    ddp_act_metric_rec.attribute6 := p7_a57;
    ddp_act_metric_rec.attribute7 := p7_a58;
    ddp_act_metric_rec.attribute8 := p7_a59;
    ddp_act_metric_rec.attribute9 := p7_a60;
    ddp_act_metric_rec.attribute10 := p7_a61;
    ddp_act_metric_rec.attribute11 := p7_a62;
    ddp_act_metric_rec.attribute12 := p7_a63;
    ddp_act_metric_rec.attribute13 := p7_a64;
    ddp_act_metric_rec.attribute14 := p7_a65;
    ddp_act_metric_rec.attribute15 := p7_a66;
    ddp_act_metric_rec.description := p7_a67;
    ddp_act_metric_rec.act_metric_date := rosetta_g_miss_date_in_map(p7_a68);
    ddp_act_metric_rec.depend_act_metric := rosetta_g_miss_num_map(p7_a69);
    ddp_act_metric_rec.function_used_by_id := rosetta_g_miss_num_map(p7_a70);
    ddp_act_metric_rec.arc_function_used_by := p7_a71;
    ddp_act_metric_rec.hierarchy_type := p7_a72;
    ddp_act_metric_rec.status_code := p7_a73;
    ddp_act_metric_rec.method_code := p7_a74;
    ddp_act_metric_rec.action_code := p7_a75;
    ddp_act_metric_rec.basis_year := rosetta_g_miss_num_map(p7_a76);
    ddp_act_metric_rec.ex_start_node := p7_a77;

    -- here's the delegated call to the old PL/SQL routine
    ams_actmetric_pvt.update_actmetric(p_api_version,
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
    , p6_a0  NUMBER := 0-1962.0724
    , p6_a1  DATE := fnd_api.g_miss_date
    , p6_a2  NUMBER := 0-1962.0724
    , p6_a3  DATE := fnd_api.g_miss_date
    , p6_a4  NUMBER := 0-1962.0724
    , p6_a5  NUMBER := 0-1962.0724
    , p6_a6  NUMBER := 0-1962.0724
    , p6_a7  NUMBER := 0-1962.0724
    , p6_a8  VARCHAR2 := fnd_api.g_miss_char
    , p6_a9  VARCHAR2 := fnd_api.g_miss_char
    , p6_a10  NUMBER := 0-1962.0724
    , p6_a11  VARCHAR2 := fnd_api.g_miss_char
    , p6_a12  NUMBER := 0-1962.0724
    , p6_a13  NUMBER := 0-1962.0724
    , p6_a14  VARCHAR2 := fnd_api.g_miss_char
    , p6_a15  NUMBER := 0-1962.0724
    , p6_a16  NUMBER := 0-1962.0724
    , p6_a17  NUMBER := 0-1962.0724
    , p6_a18  VARCHAR2 := fnd_api.g_miss_char
    , p6_a19  NUMBER := 0-1962.0724
    , p6_a20  VARCHAR2 := fnd_api.g_miss_char
    , p6_a21  NUMBER := 0-1962.0724
    , p6_a22  NUMBER := 0-1962.0724
    , p6_a23  DATE := fnd_api.g_miss_date
    , p6_a24  NUMBER := 0-1962.0724
    , p6_a25  NUMBER := 0-1962.0724
    , p6_a26  NUMBER := 0-1962.0724
    , p6_a27  VARCHAR2 := fnd_api.g_miss_char
    , p6_a28  NUMBER := 0-1962.0724
    , p6_a29  NUMBER := 0-1962.0724
    , p6_a30  NUMBER := 0-1962.0724
    , p6_a31  VARCHAR2 := fnd_api.g_miss_char
    , p6_a32  NUMBER := 0-1962.0724
    , p6_a33  NUMBER := 0-1962.0724
    , p6_a34  NUMBER := 0-1962.0724
    , p6_a35  NUMBER := 0-1962.0724
    , p6_a36  NUMBER := 0-1962.0724
    , p6_a37  NUMBER := 0-1962.0724
    , p6_a38  NUMBER := 0-1962.0724
    , p6_a39  NUMBER := 0-1962.0724
    , p6_a40  DATE := fnd_api.g_miss_date
    , p6_a41  DATE := fnd_api.g_miss_date
    , p6_a42  NUMBER := 0-1962.0724
    , p6_a43  NUMBER := 0-1962.0724
    , p6_a44  NUMBER := 0-1962.0724
    , p6_a45  NUMBER := 0-1962.0724
    , p6_a46  NUMBER := 0-1962.0724
    , p6_a47  NUMBER := 0-1962.0724
    , p6_a48  VARCHAR2 := fnd_api.g_miss_char
    , p6_a49  VARCHAR2 := fnd_api.g_miss_char
    , p6_a50  VARCHAR2 := fnd_api.g_miss_char
    , p6_a51  VARCHAR2 := fnd_api.g_miss_char
    , p6_a52  VARCHAR2 := fnd_api.g_miss_char
    , p6_a53  VARCHAR2 := fnd_api.g_miss_char
    , p6_a54  VARCHAR2 := fnd_api.g_miss_char
    , p6_a55  VARCHAR2 := fnd_api.g_miss_char
    , p6_a56  VARCHAR2 := fnd_api.g_miss_char
    , p6_a57  VARCHAR2 := fnd_api.g_miss_char
    , p6_a58  VARCHAR2 := fnd_api.g_miss_char
    , p6_a59  VARCHAR2 := fnd_api.g_miss_char
    , p6_a60  VARCHAR2 := fnd_api.g_miss_char
    , p6_a61  VARCHAR2 := fnd_api.g_miss_char
    , p6_a62  VARCHAR2 := fnd_api.g_miss_char
    , p6_a63  VARCHAR2 := fnd_api.g_miss_char
    , p6_a64  VARCHAR2 := fnd_api.g_miss_char
    , p6_a65  VARCHAR2 := fnd_api.g_miss_char
    , p6_a66  VARCHAR2 := fnd_api.g_miss_char
    , p6_a67  VARCHAR2 := fnd_api.g_miss_char
    , p6_a68  DATE := fnd_api.g_miss_date
    , p6_a69  NUMBER := 0-1962.0724
    , p6_a70  NUMBER := 0-1962.0724
    , p6_a71  VARCHAR2 := fnd_api.g_miss_char
    , p6_a72  VARCHAR2 := fnd_api.g_miss_char
    , p6_a73  VARCHAR2 := fnd_api.g_miss_char
    , p6_a74  VARCHAR2 := fnd_api.g_miss_char
    , p6_a75  VARCHAR2 := fnd_api.g_miss_char
    , p6_a76  NUMBER := 0-1962.0724
    , p6_a77  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_act_metric_rec ams_actmetric_pvt.act_metric_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_act_metric_rec.activity_metric_id := rosetta_g_miss_num_map(p6_a0);
    ddp_act_metric_rec.last_update_date := rosetta_g_miss_date_in_map(p6_a1);
    ddp_act_metric_rec.last_updated_by := rosetta_g_miss_num_map(p6_a2);
    ddp_act_metric_rec.creation_date := rosetta_g_miss_date_in_map(p6_a3);
    ddp_act_metric_rec.created_by := rosetta_g_miss_num_map(p6_a4);
    ddp_act_metric_rec.last_update_login := rosetta_g_miss_num_map(p6_a5);
    ddp_act_metric_rec.object_version_number := rosetta_g_miss_num_map(p6_a6);
    ddp_act_metric_rec.act_metric_used_by_id := rosetta_g_miss_num_map(p6_a7);
    ddp_act_metric_rec.arc_act_metric_used_by := p6_a8;
    ddp_act_metric_rec.purchase_req_raised_flag := p6_a9;
    ddp_act_metric_rec.application_id := rosetta_g_miss_num_map(p6_a10);
    ddp_act_metric_rec.sensitive_data_flag := p6_a11;
    ddp_act_metric_rec.budget_id := rosetta_g_miss_num_map(p6_a12);
    ddp_act_metric_rec.metric_id := rosetta_g_miss_num_map(p6_a13);
    ddp_act_metric_rec.transaction_currency_code := p6_a14;
    ddp_act_metric_rec.trans_forecasted_value := rosetta_g_miss_num_map(p6_a15);
    ddp_act_metric_rec.trans_committed_value := rosetta_g_miss_num_map(p6_a16);
    ddp_act_metric_rec.trans_actual_value := rosetta_g_miss_num_map(p6_a17);
    ddp_act_metric_rec.functional_currency_code := p6_a18;
    ddp_act_metric_rec.func_forecasted_value := rosetta_g_miss_num_map(p6_a19);
    ddp_act_metric_rec.dirty_flag := p6_a20;
    ddp_act_metric_rec.func_committed_value := rosetta_g_miss_num_map(p6_a21);
    ddp_act_metric_rec.func_actual_value := rosetta_g_miss_num_map(p6_a22);
    ddp_act_metric_rec.last_calculated_date := rosetta_g_miss_date_in_map(p6_a23);
    ddp_act_metric_rec.variable_value := rosetta_g_miss_num_map(p6_a24);
    ddp_act_metric_rec.forecasted_variable_value := rosetta_g_miss_num_map(p6_a25);
    ddp_act_metric_rec.computed_using_function_value := rosetta_g_miss_num_map(p6_a26);
    ddp_act_metric_rec.metric_uom_code := p6_a27;
    ddp_act_metric_rec.org_id := rosetta_g_miss_num_map(p6_a28);
    ddp_act_metric_rec.difference_since_last_calc := rosetta_g_miss_num_map(p6_a29);
    ddp_act_metric_rec.activity_metric_origin_id := rosetta_g_miss_num_map(p6_a30);
    ddp_act_metric_rec.arc_activity_metric_origin := p6_a31;
    ddp_act_metric_rec.days_since_last_refresh := rosetta_g_miss_num_map(p6_a32);
    ddp_act_metric_rec.scenario_id := rosetta_g_miss_num_map(p6_a33);
    ddp_act_metric_rec.summarize_to_metric := rosetta_g_miss_num_map(p6_a34);
    ddp_act_metric_rec.rollup_to_metric := rosetta_g_miss_num_map(p6_a35);
    ddp_act_metric_rec.hierarchy_id := rosetta_g_miss_num_map(p6_a36);
    ddp_act_metric_rec.start_node := rosetta_g_miss_num_map(p6_a37);
    ddp_act_metric_rec.from_level := rosetta_g_miss_num_map(p6_a38);
    ddp_act_metric_rec.to_level := rosetta_g_miss_num_map(p6_a39);
    ddp_act_metric_rec.from_date := rosetta_g_miss_date_in_map(p6_a40);
    ddp_act_metric_rec.to_date := rosetta_g_miss_date_in_map(p6_a41);
    ddp_act_metric_rec.amount1 := rosetta_g_miss_num_map(p6_a42);
    ddp_act_metric_rec.amount2 := rosetta_g_miss_num_map(p6_a43);
    ddp_act_metric_rec.amount3 := rosetta_g_miss_num_map(p6_a44);
    ddp_act_metric_rec.percent1 := rosetta_g_miss_num_map(p6_a45);
    ddp_act_metric_rec.percent2 := rosetta_g_miss_num_map(p6_a46);
    ddp_act_metric_rec.percent3 := rosetta_g_miss_num_map(p6_a47);
    ddp_act_metric_rec.published_flag := p6_a48;
    ddp_act_metric_rec.pre_function_name := p6_a49;
    ddp_act_metric_rec.post_function_name := p6_a50;
    ddp_act_metric_rec.attribute_category := p6_a51;
    ddp_act_metric_rec.attribute1 := p6_a52;
    ddp_act_metric_rec.attribute2 := p6_a53;
    ddp_act_metric_rec.attribute3 := p6_a54;
    ddp_act_metric_rec.attribute4 := p6_a55;
    ddp_act_metric_rec.attribute5 := p6_a56;
    ddp_act_metric_rec.attribute6 := p6_a57;
    ddp_act_metric_rec.attribute7 := p6_a58;
    ddp_act_metric_rec.attribute8 := p6_a59;
    ddp_act_metric_rec.attribute9 := p6_a60;
    ddp_act_metric_rec.attribute10 := p6_a61;
    ddp_act_metric_rec.attribute11 := p6_a62;
    ddp_act_metric_rec.attribute12 := p6_a63;
    ddp_act_metric_rec.attribute13 := p6_a64;
    ddp_act_metric_rec.attribute14 := p6_a65;
    ddp_act_metric_rec.attribute15 := p6_a66;
    ddp_act_metric_rec.description := p6_a67;
    ddp_act_metric_rec.act_metric_date := rosetta_g_miss_date_in_map(p6_a68);
    ddp_act_metric_rec.depend_act_metric := rosetta_g_miss_num_map(p6_a69);
    ddp_act_metric_rec.function_used_by_id := rosetta_g_miss_num_map(p6_a70);
    ddp_act_metric_rec.arc_function_used_by := p6_a71;
    ddp_act_metric_rec.hierarchy_type := p6_a72;
    ddp_act_metric_rec.status_code := p6_a73;
    ddp_act_metric_rec.method_code := p6_a74;
    ddp_act_metric_rec.action_code := p6_a75;
    ddp_act_metric_rec.basis_year := rosetta_g_miss_num_map(p6_a76);
    ddp_act_metric_rec.ex_start_node := p6_a77;

    -- here's the delegated call to the old PL/SQL routine
    ams_actmetric_pvt.validate_actmetric(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_act_metric_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure validate_actmetric_items(p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  NUMBER := 0-1962.0724
    , p0_a8  VARCHAR2 := fnd_api.g_miss_char
    , p0_a9  VARCHAR2 := fnd_api.g_miss_char
    , p0_a10  NUMBER := 0-1962.0724
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  NUMBER := 0-1962.0724
    , p0_a13  NUMBER := 0-1962.0724
    , p0_a14  VARCHAR2 := fnd_api.g_miss_char
    , p0_a15  NUMBER := 0-1962.0724
    , p0_a16  NUMBER := 0-1962.0724
    , p0_a17  NUMBER := 0-1962.0724
    , p0_a18  VARCHAR2 := fnd_api.g_miss_char
    , p0_a19  NUMBER := 0-1962.0724
    , p0_a20  VARCHAR2 := fnd_api.g_miss_char
    , p0_a21  NUMBER := 0-1962.0724
    , p0_a22  NUMBER := 0-1962.0724
    , p0_a23  DATE := fnd_api.g_miss_date
    , p0_a24  NUMBER := 0-1962.0724
    , p0_a25  NUMBER := 0-1962.0724
    , p0_a26  NUMBER := 0-1962.0724
    , p0_a27  VARCHAR2 := fnd_api.g_miss_char
    , p0_a28  NUMBER := 0-1962.0724
    , p0_a29  NUMBER := 0-1962.0724
    , p0_a30  NUMBER := 0-1962.0724
    , p0_a31  VARCHAR2 := fnd_api.g_miss_char
    , p0_a32  NUMBER := 0-1962.0724
    , p0_a33  NUMBER := 0-1962.0724
    , p0_a34  NUMBER := 0-1962.0724
    , p0_a35  NUMBER := 0-1962.0724
    , p0_a36  NUMBER := 0-1962.0724
    , p0_a37  NUMBER := 0-1962.0724
    , p0_a38  NUMBER := 0-1962.0724
    , p0_a39  NUMBER := 0-1962.0724
    , p0_a40  DATE := fnd_api.g_miss_date
    , p0_a41  DATE := fnd_api.g_miss_date
    , p0_a42  NUMBER := 0-1962.0724
    , p0_a43  NUMBER := 0-1962.0724
    , p0_a44  NUMBER := 0-1962.0724
    , p0_a45  NUMBER := 0-1962.0724
    , p0_a46  NUMBER := 0-1962.0724
    , p0_a47  NUMBER := 0-1962.0724
    , p0_a48  VARCHAR2 := fnd_api.g_miss_char
    , p0_a49  VARCHAR2 := fnd_api.g_miss_char
    , p0_a50  VARCHAR2 := fnd_api.g_miss_char
    , p0_a51  VARCHAR2 := fnd_api.g_miss_char
    , p0_a52  VARCHAR2 := fnd_api.g_miss_char
    , p0_a53  VARCHAR2 := fnd_api.g_miss_char
    , p0_a54  VARCHAR2 := fnd_api.g_miss_char
    , p0_a55  VARCHAR2 := fnd_api.g_miss_char
    , p0_a56  VARCHAR2 := fnd_api.g_miss_char
    , p0_a57  VARCHAR2 := fnd_api.g_miss_char
    , p0_a58  VARCHAR2 := fnd_api.g_miss_char
    , p0_a59  VARCHAR2 := fnd_api.g_miss_char
    , p0_a60  VARCHAR2 := fnd_api.g_miss_char
    , p0_a61  VARCHAR2 := fnd_api.g_miss_char
    , p0_a62  VARCHAR2 := fnd_api.g_miss_char
    , p0_a63  VARCHAR2 := fnd_api.g_miss_char
    , p0_a64  VARCHAR2 := fnd_api.g_miss_char
    , p0_a65  VARCHAR2 := fnd_api.g_miss_char
    , p0_a66  VARCHAR2 := fnd_api.g_miss_char
    , p0_a67  VARCHAR2 := fnd_api.g_miss_char
    , p0_a68  DATE := fnd_api.g_miss_date
    , p0_a69  NUMBER := 0-1962.0724
    , p0_a70  NUMBER := 0-1962.0724
    , p0_a71  VARCHAR2 := fnd_api.g_miss_char
    , p0_a72  VARCHAR2 := fnd_api.g_miss_char
    , p0_a73  VARCHAR2 := fnd_api.g_miss_char
    , p0_a74  VARCHAR2 := fnd_api.g_miss_char
    , p0_a75  VARCHAR2 := fnd_api.g_miss_char
    , p0_a76  NUMBER := 0-1962.0724
    , p0_a77  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_act_metric_rec ams_actmetric_pvt.act_metric_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_act_metric_rec.activity_metric_id := rosetta_g_miss_num_map(p0_a0);
    ddp_act_metric_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_act_metric_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_act_metric_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_act_metric_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_act_metric_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_act_metric_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_act_metric_rec.act_metric_used_by_id := rosetta_g_miss_num_map(p0_a7);
    ddp_act_metric_rec.arc_act_metric_used_by := p0_a8;
    ddp_act_metric_rec.purchase_req_raised_flag := p0_a9;
    ddp_act_metric_rec.application_id := rosetta_g_miss_num_map(p0_a10);
    ddp_act_metric_rec.sensitive_data_flag := p0_a11;
    ddp_act_metric_rec.budget_id := rosetta_g_miss_num_map(p0_a12);
    ddp_act_metric_rec.metric_id := rosetta_g_miss_num_map(p0_a13);
    ddp_act_metric_rec.transaction_currency_code := p0_a14;
    ddp_act_metric_rec.trans_forecasted_value := rosetta_g_miss_num_map(p0_a15);
    ddp_act_metric_rec.trans_committed_value := rosetta_g_miss_num_map(p0_a16);
    ddp_act_metric_rec.trans_actual_value := rosetta_g_miss_num_map(p0_a17);
    ddp_act_metric_rec.functional_currency_code := p0_a18;
    ddp_act_metric_rec.func_forecasted_value := rosetta_g_miss_num_map(p0_a19);
    ddp_act_metric_rec.dirty_flag := p0_a20;
    ddp_act_metric_rec.func_committed_value := rosetta_g_miss_num_map(p0_a21);
    ddp_act_metric_rec.func_actual_value := rosetta_g_miss_num_map(p0_a22);
    ddp_act_metric_rec.last_calculated_date := rosetta_g_miss_date_in_map(p0_a23);
    ddp_act_metric_rec.variable_value := rosetta_g_miss_num_map(p0_a24);
    ddp_act_metric_rec.forecasted_variable_value := rosetta_g_miss_num_map(p0_a25);
    ddp_act_metric_rec.computed_using_function_value := rosetta_g_miss_num_map(p0_a26);
    ddp_act_metric_rec.metric_uom_code := p0_a27;
    ddp_act_metric_rec.org_id := rosetta_g_miss_num_map(p0_a28);
    ddp_act_metric_rec.difference_since_last_calc := rosetta_g_miss_num_map(p0_a29);
    ddp_act_metric_rec.activity_metric_origin_id := rosetta_g_miss_num_map(p0_a30);
    ddp_act_metric_rec.arc_activity_metric_origin := p0_a31;
    ddp_act_metric_rec.days_since_last_refresh := rosetta_g_miss_num_map(p0_a32);
    ddp_act_metric_rec.scenario_id := rosetta_g_miss_num_map(p0_a33);
    ddp_act_metric_rec.summarize_to_metric := rosetta_g_miss_num_map(p0_a34);
    ddp_act_metric_rec.rollup_to_metric := rosetta_g_miss_num_map(p0_a35);
    ddp_act_metric_rec.hierarchy_id := rosetta_g_miss_num_map(p0_a36);
    ddp_act_metric_rec.start_node := rosetta_g_miss_num_map(p0_a37);
    ddp_act_metric_rec.from_level := rosetta_g_miss_num_map(p0_a38);
    ddp_act_metric_rec.to_level := rosetta_g_miss_num_map(p0_a39);
    ddp_act_metric_rec.from_date := rosetta_g_miss_date_in_map(p0_a40);
    ddp_act_metric_rec.to_date := rosetta_g_miss_date_in_map(p0_a41);
    ddp_act_metric_rec.amount1 := rosetta_g_miss_num_map(p0_a42);
    ddp_act_metric_rec.amount2 := rosetta_g_miss_num_map(p0_a43);
    ddp_act_metric_rec.amount3 := rosetta_g_miss_num_map(p0_a44);
    ddp_act_metric_rec.percent1 := rosetta_g_miss_num_map(p0_a45);
    ddp_act_metric_rec.percent2 := rosetta_g_miss_num_map(p0_a46);
    ddp_act_metric_rec.percent3 := rosetta_g_miss_num_map(p0_a47);
    ddp_act_metric_rec.published_flag := p0_a48;
    ddp_act_metric_rec.pre_function_name := p0_a49;
    ddp_act_metric_rec.post_function_name := p0_a50;
    ddp_act_metric_rec.attribute_category := p0_a51;
    ddp_act_metric_rec.attribute1 := p0_a52;
    ddp_act_metric_rec.attribute2 := p0_a53;
    ddp_act_metric_rec.attribute3 := p0_a54;
    ddp_act_metric_rec.attribute4 := p0_a55;
    ddp_act_metric_rec.attribute5 := p0_a56;
    ddp_act_metric_rec.attribute6 := p0_a57;
    ddp_act_metric_rec.attribute7 := p0_a58;
    ddp_act_metric_rec.attribute8 := p0_a59;
    ddp_act_metric_rec.attribute9 := p0_a60;
    ddp_act_metric_rec.attribute10 := p0_a61;
    ddp_act_metric_rec.attribute11 := p0_a62;
    ddp_act_metric_rec.attribute12 := p0_a63;
    ddp_act_metric_rec.attribute13 := p0_a64;
    ddp_act_metric_rec.attribute14 := p0_a65;
    ddp_act_metric_rec.attribute15 := p0_a66;
    ddp_act_metric_rec.description := p0_a67;
    ddp_act_metric_rec.act_metric_date := rosetta_g_miss_date_in_map(p0_a68);
    ddp_act_metric_rec.depend_act_metric := rosetta_g_miss_num_map(p0_a69);
    ddp_act_metric_rec.function_used_by_id := rosetta_g_miss_num_map(p0_a70);
    ddp_act_metric_rec.arc_function_used_by := p0_a71;
    ddp_act_metric_rec.hierarchy_type := p0_a72;
    ddp_act_metric_rec.status_code := p0_a73;
    ddp_act_metric_rec.method_code := p0_a74;
    ddp_act_metric_rec.action_code := p0_a75;
    ddp_act_metric_rec.basis_year := rosetta_g_miss_num_map(p0_a76);
    ddp_act_metric_rec.ex_start_node := p0_a77;



    -- here's the delegated call to the old PL/SQL routine
    ams_actmetric_pvt.validate_actmetric_items(ddp_act_metric_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure validate_actmetric_record(x_return_status out nocopy  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  NUMBER := 0-1962.0724
    , p0_a8  VARCHAR2 := fnd_api.g_miss_char
    , p0_a9  VARCHAR2 := fnd_api.g_miss_char
    , p0_a10  NUMBER := 0-1962.0724
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  NUMBER := 0-1962.0724
    , p0_a13  NUMBER := 0-1962.0724
    , p0_a14  VARCHAR2 := fnd_api.g_miss_char
    , p0_a15  NUMBER := 0-1962.0724
    , p0_a16  NUMBER := 0-1962.0724
    , p0_a17  NUMBER := 0-1962.0724
    , p0_a18  VARCHAR2 := fnd_api.g_miss_char
    , p0_a19  NUMBER := 0-1962.0724
    , p0_a20  VARCHAR2 := fnd_api.g_miss_char
    , p0_a21  NUMBER := 0-1962.0724
    , p0_a22  NUMBER := 0-1962.0724
    , p0_a23  DATE := fnd_api.g_miss_date
    , p0_a24  NUMBER := 0-1962.0724
    , p0_a25  NUMBER := 0-1962.0724
    , p0_a26  NUMBER := 0-1962.0724
    , p0_a27  VARCHAR2 := fnd_api.g_miss_char
    , p0_a28  NUMBER := 0-1962.0724
    , p0_a29  NUMBER := 0-1962.0724
    , p0_a30  NUMBER := 0-1962.0724
    , p0_a31  VARCHAR2 := fnd_api.g_miss_char
    , p0_a32  NUMBER := 0-1962.0724
    , p0_a33  NUMBER := 0-1962.0724
    , p0_a34  NUMBER := 0-1962.0724
    , p0_a35  NUMBER := 0-1962.0724
    , p0_a36  NUMBER := 0-1962.0724
    , p0_a37  NUMBER := 0-1962.0724
    , p0_a38  NUMBER := 0-1962.0724
    , p0_a39  NUMBER := 0-1962.0724
    , p0_a40  DATE := fnd_api.g_miss_date
    , p0_a41  DATE := fnd_api.g_miss_date
    , p0_a42  NUMBER := 0-1962.0724
    , p0_a43  NUMBER := 0-1962.0724
    , p0_a44  NUMBER := 0-1962.0724
    , p0_a45  NUMBER := 0-1962.0724
    , p0_a46  NUMBER := 0-1962.0724
    , p0_a47  NUMBER := 0-1962.0724
    , p0_a48  VARCHAR2 := fnd_api.g_miss_char
    , p0_a49  VARCHAR2 := fnd_api.g_miss_char
    , p0_a50  VARCHAR2 := fnd_api.g_miss_char
    , p0_a51  VARCHAR2 := fnd_api.g_miss_char
    , p0_a52  VARCHAR2 := fnd_api.g_miss_char
    , p0_a53  VARCHAR2 := fnd_api.g_miss_char
    , p0_a54  VARCHAR2 := fnd_api.g_miss_char
    , p0_a55  VARCHAR2 := fnd_api.g_miss_char
    , p0_a56  VARCHAR2 := fnd_api.g_miss_char
    , p0_a57  VARCHAR2 := fnd_api.g_miss_char
    , p0_a58  VARCHAR2 := fnd_api.g_miss_char
    , p0_a59  VARCHAR2 := fnd_api.g_miss_char
    , p0_a60  VARCHAR2 := fnd_api.g_miss_char
    , p0_a61  VARCHAR2 := fnd_api.g_miss_char
    , p0_a62  VARCHAR2 := fnd_api.g_miss_char
    , p0_a63  VARCHAR2 := fnd_api.g_miss_char
    , p0_a64  VARCHAR2 := fnd_api.g_miss_char
    , p0_a65  VARCHAR2 := fnd_api.g_miss_char
    , p0_a66  VARCHAR2 := fnd_api.g_miss_char
    , p0_a67  VARCHAR2 := fnd_api.g_miss_char
    , p0_a68  DATE := fnd_api.g_miss_date
    , p0_a69  NUMBER := 0-1962.0724
    , p0_a70  NUMBER := 0-1962.0724
    , p0_a71  VARCHAR2 := fnd_api.g_miss_char
    , p0_a72  VARCHAR2 := fnd_api.g_miss_char
    , p0_a73  VARCHAR2 := fnd_api.g_miss_char
    , p0_a74  VARCHAR2 := fnd_api.g_miss_char
    , p0_a75  VARCHAR2 := fnd_api.g_miss_char
    , p0_a76  NUMBER := 0-1962.0724
    , p0_a77  VARCHAR2 := fnd_api.g_miss_char
    , p1_a0  NUMBER := 0-1962.0724
    , p1_a1  DATE := fnd_api.g_miss_date
    , p1_a2  NUMBER := 0-1962.0724
    , p1_a3  DATE := fnd_api.g_miss_date
    , p1_a4  NUMBER := 0-1962.0724
    , p1_a5  NUMBER := 0-1962.0724
    , p1_a6  NUMBER := 0-1962.0724
    , p1_a7  NUMBER := 0-1962.0724
    , p1_a8  VARCHAR2 := fnd_api.g_miss_char
    , p1_a9  VARCHAR2 := fnd_api.g_miss_char
    , p1_a10  NUMBER := 0-1962.0724
    , p1_a11  VARCHAR2 := fnd_api.g_miss_char
    , p1_a12  NUMBER := 0-1962.0724
    , p1_a13  NUMBER := 0-1962.0724
    , p1_a14  VARCHAR2 := fnd_api.g_miss_char
    , p1_a15  NUMBER := 0-1962.0724
    , p1_a16  NUMBER := 0-1962.0724
    , p1_a17  NUMBER := 0-1962.0724
    , p1_a18  VARCHAR2 := fnd_api.g_miss_char
    , p1_a19  NUMBER := 0-1962.0724
    , p1_a20  VARCHAR2 := fnd_api.g_miss_char
    , p1_a21  NUMBER := 0-1962.0724
    , p1_a22  NUMBER := 0-1962.0724
    , p1_a23  DATE := fnd_api.g_miss_date
    , p1_a24  NUMBER := 0-1962.0724
    , p1_a25  NUMBER := 0-1962.0724
    , p1_a26  NUMBER := 0-1962.0724
    , p1_a27  VARCHAR2 := fnd_api.g_miss_char
    , p1_a28  NUMBER := 0-1962.0724
    , p1_a29  NUMBER := 0-1962.0724
    , p1_a30  NUMBER := 0-1962.0724
    , p1_a31  VARCHAR2 := fnd_api.g_miss_char
    , p1_a32  NUMBER := 0-1962.0724
    , p1_a33  NUMBER := 0-1962.0724
    , p1_a34  NUMBER := 0-1962.0724
    , p1_a35  NUMBER := 0-1962.0724
    , p1_a36  NUMBER := 0-1962.0724
    , p1_a37  NUMBER := 0-1962.0724
    , p1_a38  NUMBER := 0-1962.0724
    , p1_a39  NUMBER := 0-1962.0724
    , p1_a40  DATE := fnd_api.g_miss_date
    , p1_a41  DATE := fnd_api.g_miss_date
    , p1_a42  NUMBER := 0-1962.0724
    , p1_a43  NUMBER := 0-1962.0724
    , p1_a44  NUMBER := 0-1962.0724
    , p1_a45  NUMBER := 0-1962.0724
    , p1_a46  NUMBER := 0-1962.0724
    , p1_a47  NUMBER := 0-1962.0724
    , p1_a48  VARCHAR2 := fnd_api.g_miss_char
    , p1_a49  VARCHAR2 := fnd_api.g_miss_char
    , p1_a50  VARCHAR2 := fnd_api.g_miss_char
    , p1_a51  VARCHAR2 := fnd_api.g_miss_char
    , p1_a52  VARCHAR2 := fnd_api.g_miss_char
    , p1_a53  VARCHAR2 := fnd_api.g_miss_char
    , p1_a54  VARCHAR2 := fnd_api.g_miss_char
    , p1_a55  VARCHAR2 := fnd_api.g_miss_char
    , p1_a56  VARCHAR2 := fnd_api.g_miss_char
    , p1_a57  VARCHAR2 := fnd_api.g_miss_char
    , p1_a58  VARCHAR2 := fnd_api.g_miss_char
    , p1_a59  VARCHAR2 := fnd_api.g_miss_char
    , p1_a60  VARCHAR2 := fnd_api.g_miss_char
    , p1_a61  VARCHAR2 := fnd_api.g_miss_char
    , p1_a62  VARCHAR2 := fnd_api.g_miss_char
    , p1_a63  VARCHAR2 := fnd_api.g_miss_char
    , p1_a64  VARCHAR2 := fnd_api.g_miss_char
    , p1_a65  VARCHAR2 := fnd_api.g_miss_char
    , p1_a66  VARCHAR2 := fnd_api.g_miss_char
    , p1_a67  VARCHAR2 := fnd_api.g_miss_char
    , p1_a68  DATE := fnd_api.g_miss_date
    , p1_a69  NUMBER := 0-1962.0724
    , p1_a70  NUMBER := 0-1962.0724
    , p1_a71  VARCHAR2 := fnd_api.g_miss_char
    , p1_a72  VARCHAR2 := fnd_api.g_miss_char
    , p1_a73  VARCHAR2 := fnd_api.g_miss_char
    , p1_a74  VARCHAR2 := fnd_api.g_miss_char
    , p1_a75  VARCHAR2 := fnd_api.g_miss_char
    , p1_a76  NUMBER := 0-1962.0724
    , p1_a77  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_act_metric_rec ams_actmetric_pvt.act_metric_rec_type;
    ddp_complete_rec ams_actmetric_pvt.act_metric_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_act_metric_rec.activity_metric_id := rosetta_g_miss_num_map(p0_a0);
    ddp_act_metric_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_act_metric_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_act_metric_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_act_metric_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_act_metric_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_act_metric_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_act_metric_rec.act_metric_used_by_id := rosetta_g_miss_num_map(p0_a7);
    ddp_act_metric_rec.arc_act_metric_used_by := p0_a8;
    ddp_act_metric_rec.purchase_req_raised_flag := p0_a9;
    ddp_act_metric_rec.application_id := rosetta_g_miss_num_map(p0_a10);
    ddp_act_metric_rec.sensitive_data_flag := p0_a11;
    ddp_act_metric_rec.budget_id := rosetta_g_miss_num_map(p0_a12);
    ddp_act_metric_rec.metric_id := rosetta_g_miss_num_map(p0_a13);
    ddp_act_metric_rec.transaction_currency_code := p0_a14;
    ddp_act_metric_rec.trans_forecasted_value := rosetta_g_miss_num_map(p0_a15);
    ddp_act_metric_rec.trans_committed_value := rosetta_g_miss_num_map(p0_a16);
    ddp_act_metric_rec.trans_actual_value := rosetta_g_miss_num_map(p0_a17);
    ddp_act_metric_rec.functional_currency_code := p0_a18;
    ddp_act_metric_rec.func_forecasted_value := rosetta_g_miss_num_map(p0_a19);
    ddp_act_metric_rec.dirty_flag := p0_a20;
    ddp_act_metric_rec.func_committed_value := rosetta_g_miss_num_map(p0_a21);
    ddp_act_metric_rec.func_actual_value := rosetta_g_miss_num_map(p0_a22);
    ddp_act_metric_rec.last_calculated_date := rosetta_g_miss_date_in_map(p0_a23);
    ddp_act_metric_rec.variable_value := rosetta_g_miss_num_map(p0_a24);
    ddp_act_metric_rec.forecasted_variable_value := rosetta_g_miss_num_map(p0_a25);
    ddp_act_metric_rec.computed_using_function_value := rosetta_g_miss_num_map(p0_a26);
    ddp_act_metric_rec.metric_uom_code := p0_a27;
    ddp_act_metric_rec.org_id := rosetta_g_miss_num_map(p0_a28);
    ddp_act_metric_rec.difference_since_last_calc := rosetta_g_miss_num_map(p0_a29);
    ddp_act_metric_rec.activity_metric_origin_id := rosetta_g_miss_num_map(p0_a30);
    ddp_act_metric_rec.arc_activity_metric_origin := p0_a31;
    ddp_act_metric_rec.days_since_last_refresh := rosetta_g_miss_num_map(p0_a32);
    ddp_act_metric_rec.scenario_id := rosetta_g_miss_num_map(p0_a33);
    ddp_act_metric_rec.summarize_to_metric := rosetta_g_miss_num_map(p0_a34);
    ddp_act_metric_rec.rollup_to_metric := rosetta_g_miss_num_map(p0_a35);
    ddp_act_metric_rec.hierarchy_id := rosetta_g_miss_num_map(p0_a36);
    ddp_act_metric_rec.start_node := rosetta_g_miss_num_map(p0_a37);
    ddp_act_metric_rec.from_level := rosetta_g_miss_num_map(p0_a38);
    ddp_act_metric_rec.to_level := rosetta_g_miss_num_map(p0_a39);
    ddp_act_metric_rec.from_date := rosetta_g_miss_date_in_map(p0_a40);
    ddp_act_metric_rec.to_date := rosetta_g_miss_date_in_map(p0_a41);
    ddp_act_metric_rec.amount1 := rosetta_g_miss_num_map(p0_a42);
    ddp_act_metric_rec.amount2 := rosetta_g_miss_num_map(p0_a43);
    ddp_act_metric_rec.amount3 := rosetta_g_miss_num_map(p0_a44);
    ddp_act_metric_rec.percent1 := rosetta_g_miss_num_map(p0_a45);
    ddp_act_metric_rec.percent2 := rosetta_g_miss_num_map(p0_a46);
    ddp_act_metric_rec.percent3 := rosetta_g_miss_num_map(p0_a47);
    ddp_act_metric_rec.published_flag := p0_a48;
    ddp_act_metric_rec.pre_function_name := p0_a49;
    ddp_act_metric_rec.post_function_name := p0_a50;
    ddp_act_metric_rec.attribute_category := p0_a51;
    ddp_act_metric_rec.attribute1 := p0_a52;
    ddp_act_metric_rec.attribute2 := p0_a53;
    ddp_act_metric_rec.attribute3 := p0_a54;
    ddp_act_metric_rec.attribute4 := p0_a55;
    ddp_act_metric_rec.attribute5 := p0_a56;
    ddp_act_metric_rec.attribute6 := p0_a57;
    ddp_act_metric_rec.attribute7 := p0_a58;
    ddp_act_metric_rec.attribute8 := p0_a59;
    ddp_act_metric_rec.attribute9 := p0_a60;
    ddp_act_metric_rec.attribute10 := p0_a61;
    ddp_act_metric_rec.attribute11 := p0_a62;
    ddp_act_metric_rec.attribute12 := p0_a63;
    ddp_act_metric_rec.attribute13 := p0_a64;
    ddp_act_metric_rec.attribute14 := p0_a65;
    ddp_act_metric_rec.attribute15 := p0_a66;
    ddp_act_metric_rec.description := p0_a67;
    ddp_act_metric_rec.act_metric_date := rosetta_g_miss_date_in_map(p0_a68);
    ddp_act_metric_rec.depend_act_metric := rosetta_g_miss_num_map(p0_a69);
    ddp_act_metric_rec.function_used_by_id := rosetta_g_miss_num_map(p0_a70);
    ddp_act_metric_rec.arc_function_used_by := p0_a71;
    ddp_act_metric_rec.hierarchy_type := p0_a72;
    ddp_act_metric_rec.status_code := p0_a73;
    ddp_act_metric_rec.method_code := p0_a74;
    ddp_act_metric_rec.action_code := p0_a75;
    ddp_act_metric_rec.basis_year := rosetta_g_miss_num_map(p0_a76);
    ddp_act_metric_rec.ex_start_node := p0_a77;

    ddp_complete_rec.activity_metric_id := rosetta_g_miss_num_map(p1_a0);
    ddp_complete_rec.last_update_date := rosetta_g_miss_date_in_map(p1_a1);
    ddp_complete_rec.last_updated_by := rosetta_g_miss_num_map(p1_a2);
    ddp_complete_rec.creation_date := rosetta_g_miss_date_in_map(p1_a3);
    ddp_complete_rec.created_by := rosetta_g_miss_num_map(p1_a4);
    ddp_complete_rec.last_update_login := rosetta_g_miss_num_map(p1_a5);
    ddp_complete_rec.object_version_number := rosetta_g_miss_num_map(p1_a6);
    ddp_complete_rec.act_metric_used_by_id := rosetta_g_miss_num_map(p1_a7);
    ddp_complete_rec.arc_act_metric_used_by := p1_a8;
    ddp_complete_rec.purchase_req_raised_flag := p1_a9;
    ddp_complete_rec.application_id := rosetta_g_miss_num_map(p1_a10);
    ddp_complete_rec.sensitive_data_flag := p1_a11;
    ddp_complete_rec.budget_id := rosetta_g_miss_num_map(p1_a12);
    ddp_complete_rec.metric_id := rosetta_g_miss_num_map(p1_a13);
    ddp_complete_rec.transaction_currency_code := p1_a14;
    ddp_complete_rec.trans_forecasted_value := rosetta_g_miss_num_map(p1_a15);
    ddp_complete_rec.trans_committed_value := rosetta_g_miss_num_map(p1_a16);
    ddp_complete_rec.trans_actual_value := rosetta_g_miss_num_map(p1_a17);
    ddp_complete_rec.functional_currency_code := p1_a18;
    ddp_complete_rec.func_forecasted_value := rosetta_g_miss_num_map(p1_a19);
    ddp_complete_rec.dirty_flag := p1_a20;
    ddp_complete_rec.func_committed_value := rosetta_g_miss_num_map(p1_a21);
    ddp_complete_rec.func_actual_value := rosetta_g_miss_num_map(p1_a22);
    ddp_complete_rec.last_calculated_date := rosetta_g_miss_date_in_map(p1_a23);
    ddp_complete_rec.variable_value := rosetta_g_miss_num_map(p1_a24);
    ddp_complete_rec.forecasted_variable_value := rosetta_g_miss_num_map(p1_a25);
    ddp_complete_rec.computed_using_function_value := rosetta_g_miss_num_map(p1_a26);
    ddp_complete_rec.metric_uom_code := p1_a27;
    ddp_complete_rec.org_id := rosetta_g_miss_num_map(p1_a28);
    ddp_complete_rec.difference_since_last_calc := rosetta_g_miss_num_map(p1_a29);
    ddp_complete_rec.activity_metric_origin_id := rosetta_g_miss_num_map(p1_a30);
    ddp_complete_rec.arc_activity_metric_origin := p1_a31;
    ddp_complete_rec.days_since_last_refresh := rosetta_g_miss_num_map(p1_a32);
    ddp_complete_rec.scenario_id := rosetta_g_miss_num_map(p1_a33);
    ddp_complete_rec.summarize_to_metric := rosetta_g_miss_num_map(p1_a34);
    ddp_complete_rec.rollup_to_metric := rosetta_g_miss_num_map(p1_a35);
    ddp_complete_rec.hierarchy_id := rosetta_g_miss_num_map(p1_a36);
    ddp_complete_rec.start_node := rosetta_g_miss_num_map(p1_a37);
    ddp_complete_rec.from_level := rosetta_g_miss_num_map(p1_a38);
    ddp_complete_rec.to_level := rosetta_g_miss_num_map(p1_a39);
    ddp_complete_rec.from_date := rosetta_g_miss_date_in_map(p1_a40);
    ddp_complete_rec.to_date := rosetta_g_miss_date_in_map(p1_a41);
    ddp_complete_rec.amount1 := rosetta_g_miss_num_map(p1_a42);
    ddp_complete_rec.amount2 := rosetta_g_miss_num_map(p1_a43);
    ddp_complete_rec.amount3 := rosetta_g_miss_num_map(p1_a44);
    ddp_complete_rec.percent1 := rosetta_g_miss_num_map(p1_a45);
    ddp_complete_rec.percent2 := rosetta_g_miss_num_map(p1_a46);
    ddp_complete_rec.percent3 := rosetta_g_miss_num_map(p1_a47);
    ddp_complete_rec.published_flag := p1_a48;
    ddp_complete_rec.pre_function_name := p1_a49;
    ddp_complete_rec.post_function_name := p1_a50;
    ddp_complete_rec.attribute_category := p1_a51;
    ddp_complete_rec.attribute1 := p1_a52;
    ddp_complete_rec.attribute2 := p1_a53;
    ddp_complete_rec.attribute3 := p1_a54;
    ddp_complete_rec.attribute4 := p1_a55;
    ddp_complete_rec.attribute5 := p1_a56;
    ddp_complete_rec.attribute6 := p1_a57;
    ddp_complete_rec.attribute7 := p1_a58;
    ddp_complete_rec.attribute8 := p1_a59;
    ddp_complete_rec.attribute9 := p1_a60;
    ddp_complete_rec.attribute10 := p1_a61;
    ddp_complete_rec.attribute11 := p1_a62;
    ddp_complete_rec.attribute12 := p1_a63;
    ddp_complete_rec.attribute13 := p1_a64;
    ddp_complete_rec.attribute14 := p1_a65;
    ddp_complete_rec.attribute15 := p1_a66;
    ddp_complete_rec.description := p1_a67;
    ddp_complete_rec.act_metric_date := rosetta_g_miss_date_in_map(p1_a68);
    ddp_complete_rec.depend_act_metric := rosetta_g_miss_num_map(p1_a69);
    ddp_complete_rec.function_used_by_id := rosetta_g_miss_num_map(p1_a70);
    ddp_complete_rec.arc_function_used_by := p1_a71;
    ddp_complete_rec.hierarchy_type := p1_a72;
    ddp_complete_rec.status_code := p1_a73;
    ddp_complete_rec.method_code := p1_a74;
    ddp_complete_rec.action_code := p1_a75;
    ddp_complete_rec.basis_year := rosetta_g_miss_num_map(p1_a76);
    ddp_complete_rec.ex_start_node := p1_a77;


    -- here's the delegated call to the old PL/SQL routine
    ams_actmetric_pvt.validate_actmetric_record(ddp_act_metric_rec,
      ddp_complete_rec,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure complete_actmetric_rec(p1_a0 in out nocopy  NUMBER
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
    , p1_a26 in out nocopy  NUMBER
    , p1_a27 in out nocopy  VARCHAR2
    , p1_a28 in out nocopy  NUMBER
    , p1_a29 in out nocopy  NUMBER
    , p1_a30 in out nocopy  NUMBER
    , p1_a31 in out nocopy  VARCHAR2
    , p1_a32 in out nocopy  NUMBER
    , p1_a33 in out nocopy  NUMBER
    , p1_a34 in out nocopy  NUMBER
    , p1_a35 in out nocopy  NUMBER
    , p1_a36 in out nocopy  NUMBER
    , p1_a37 in out nocopy  NUMBER
    , p1_a38 in out nocopy  NUMBER
    , p1_a39 in out nocopy  NUMBER
    , p1_a40 in out nocopy  DATE
    , p1_a41 in out nocopy  DATE
    , p1_a42 in out nocopy  NUMBER
    , p1_a43 in out nocopy  NUMBER
    , p1_a44 in out nocopy  NUMBER
    , p1_a45 in out nocopy  NUMBER
    , p1_a46 in out nocopy  NUMBER
    , p1_a47 in out nocopy  NUMBER
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
    , p1_a67 in out nocopy  VARCHAR2
    , p1_a68 in out nocopy  DATE
    , p1_a69 in out nocopy  NUMBER
    , p1_a70 in out nocopy  NUMBER
    , p1_a71 in out nocopy  VARCHAR2
    , p1_a72 in out nocopy  VARCHAR2
    , p1_a73 in out nocopy  VARCHAR2
    , p1_a74 in out nocopy  VARCHAR2
    , p1_a75 in out nocopy  VARCHAR2
    , p1_a76 in out nocopy  NUMBER
    , p1_a77 in out nocopy  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  NUMBER := 0-1962.0724
    , p0_a8  VARCHAR2 := fnd_api.g_miss_char
    , p0_a9  VARCHAR2 := fnd_api.g_miss_char
    , p0_a10  NUMBER := 0-1962.0724
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  NUMBER := 0-1962.0724
    , p0_a13  NUMBER := 0-1962.0724
    , p0_a14  VARCHAR2 := fnd_api.g_miss_char
    , p0_a15  NUMBER := 0-1962.0724
    , p0_a16  NUMBER := 0-1962.0724
    , p0_a17  NUMBER := 0-1962.0724
    , p0_a18  VARCHAR2 := fnd_api.g_miss_char
    , p0_a19  NUMBER := 0-1962.0724
    , p0_a20  VARCHAR2 := fnd_api.g_miss_char
    , p0_a21  NUMBER := 0-1962.0724
    , p0_a22  NUMBER := 0-1962.0724
    , p0_a23  DATE := fnd_api.g_miss_date
    , p0_a24  NUMBER := 0-1962.0724
    , p0_a25  NUMBER := 0-1962.0724
    , p0_a26  NUMBER := 0-1962.0724
    , p0_a27  VARCHAR2 := fnd_api.g_miss_char
    , p0_a28  NUMBER := 0-1962.0724
    , p0_a29  NUMBER := 0-1962.0724
    , p0_a30  NUMBER := 0-1962.0724
    , p0_a31  VARCHAR2 := fnd_api.g_miss_char
    , p0_a32  NUMBER := 0-1962.0724
    , p0_a33  NUMBER := 0-1962.0724
    , p0_a34  NUMBER := 0-1962.0724
    , p0_a35  NUMBER := 0-1962.0724
    , p0_a36  NUMBER := 0-1962.0724
    , p0_a37  NUMBER := 0-1962.0724
    , p0_a38  NUMBER := 0-1962.0724
    , p0_a39  NUMBER := 0-1962.0724
    , p0_a40  DATE := fnd_api.g_miss_date
    , p0_a41  DATE := fnd_api.g_miss_date
    , p0_a42  NUMBER := 0-1962.0724
    , p0_a43  NUMBER := 0-1962.0724
    , p0_a44  NUMBER := 0-1962.0724
    , p0_a45  NUMBER := 0-1962.0724
    , p0_a46  NUMBER := 0-1962.0724
    , p0_a47  NUMBER := 0-1962.0724
    , p0_a48  VARCHAR2 := fnd_api.g_miss_char
    , p0_a49  VARCHAR2 := fnd_api.g_miss_char
    , p0_a50  VARCHAR2 := fnd_api.g_miss_char
    , p0_a51  VARCHAR2 := fnd_api.g_miss_char
    , p0_a52  VARCHAR2 := fnd_api.g_miss_char
    , p0_a53  VARCHAR2 := fnd_api.g_miss_char
    , p0_a54  VARCHAR2 := fnd_api.g_miss_char
    , p0_a55  VARCHAR2 := fnd_api.g_miss_char
    , p0_a56  VARCHAR2 := fnd_api.g_miss_char
    , p0_a57  VARCHAR2 := fnd_api.g_miss_char
    , p0_a58  VARCHAR2 := fnd_api.g_miss_char
    , p0_a59  VARCHAR2 := fnd_api.g_miss_char
    , p0_a60  VARCHAR2 := fnd_api.g_miss_char
    , p0_a61  VARCHAR2 := fnd_api.g_miss_char
    , p0_a62  VARCHAR2 := fnd_api.g_miss_char
    , p0_a63  VARCHAR2 := fnd_api.g_miss_char
    , p0_a64  VARCHAR2 := fnd_api.g_miss_char
    , p0_a65  VARCHAR2 := fnd_api.g_miss_char
    , p0_a66  VARCHAR2 := fnd_api.g_miss_char
    , p0_a67  VARCHAR2 := fnd_api.g_miss_char
    , p0_a68  DATE := fnd_api.g_miss_date
    , p0_a69  NUMBER := 0-1962.0724
    , p0_a70  NUMBER := 0-1962.0724
    , p0_a71  VARCHAR2 := fnd_api.g_miss_char
    , p0_a72  VARCHAR2 := fnd_api.g_miss_char
    , p0_a73  VARCHAR2 := fnd_api.g_miss_char
    , p0_a74  VARCHAR2 := fnd_api.g_miss_char
    , p0_a75  VARCHAR2 := fnd_api.g_miss_char
    , p0_a76  NUMBER := 0-1962.0724
    , p0_a77  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_act_metric_rec ams_actmetric_pvt.act_metric_rec_type;
    ddx_complete_rec ams_actmetric_pvt.act_metric_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_act_metric_rec.activity_metric_id := rosetta_g_miss_num_map(p0_a0);
    ddp_act_metric_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_act_metric_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_act_metric_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_act_metric_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_act_metric_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_act_metric_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_act_metric_rec.act_metric_used_by_id := rosetta_g_miss_num_map(p0_a7);
    ddp_act_metric_rec.arc_act_metric_used_by := p0_a8;
    ddp_act_metric_rec.purchase_req_raised_flag := p0_a9;
    ddp_act_metric_rec.application_id := rosetta_g_miss_num_map(p0_a10);
    ddp_act_metric_rec.sensitive_data_flag := p0_a11;
    ddp_act_metric_rec.budget_id := rosetta_g_miss_num_map(p0_a12);
    ddp_act_metric_rec.metric_id := rosetta_g_miss_num_map(p0_a13);
    ddp_act_metric_rec.transaction_currency_code := p0_a14;
    ddp_act_metric_rec.trans_forecasted_value := rosetta_g_miss_num_map(p0_a15);
    ddp_act_metric_rec.trans_committed_value := rosetta_g_miss_num_map(p0_a16);
    ddp_act_metric_rec.trans_actual_value := rosetta_g_miss_num_map(p0_a17);
    ddp_act_metric_rec.functional_currency_code := p0_a18;
    ddp_act_metric_rec.func_forecasted_value := rosetta_g_miss_num_map(p0_a19);
    ddp_act_metric_rec.dirty_flag := p0_a20;
    ddp_act_metric_rec.func_committed_value := rosetta_g_miss_num_map(p0_a21);
    ddp_act_metric_rec.func_actual_value := rosetta_g_miss_num_map(p0_a22);
    ddp_act_metric_rec.last_calculated_date := rosetta_g_miss_date_in_map(p0_a23);
    ddp_act_metric_rec.variable_value := rosetta_g_miss_num_map(p0_a24);
    ddp_act_metric_rec.forecasted_variable_value := rosetta_g_miss_num_map(p0_a25);
    ddp_act_metric_rec.computed_using_function_value := rosetta_g_miss_num_map(p0_a26);
    ddp_act_metric_rec.metric_uom_code := p0_a27;
    ddp_act_metric_rec.org_id := rosetta_g_miss_num_map(p0_a28);
    ddp_act_metric_rec.difference_since_last_calc := rosetta_g_miss_num_map(p0_a29);
    ddp_act_metric_rec.activity_metric_origin_id := rosetta_g_miss_num_map(p0_a30);
    ddp_act_metric_rec.arc_activity_metric_origin := p0_a31;
    ddp_act_metric_rec.days_since_last_refresh := rosetta_g_miss_num_map(p0_a32);
    ddp_act_metric_rec.scenario_id := rosetta_g_miss_num_map(p0_a33);
    ddp_act_metric_rec.summarize_to_metric := rosetta_g_miss_num_map(p0_a34);
    ddp_act_metric_rec.rollup_to_metric := rosetta_g_miss_num_map(p0_a35);
    ddp_act_metric_rec.hierarchy_id := rosetta_g_miss_num_map(p0_a36);
    ddp_act_metric_rec.start_node := rosetta_g_miss_num_map(p0_a37);
    ddp_act_metric_rec.from_level := rosetta_g_miss_num_map(p0_a38);
    ddp_act_metric_rec.to_level := rosetta_g_miss_num_map(p0_a39);
    ddp_act_metric_rec.from_date := rosetta_g_miss_date_in_map(p0_a40);
    ddp_act_metric_rec.to_date := rosetta_g_miss_date_in_map(p0_a41);
    ddp_act_metric_rec.amount1 := rosetta_g_miss_num_map(p0_a42);
    ddp_act_metric_rec.amount2 := rosetta_g_miss_num_map(p0_a43);
    ddp_act_metric_rec.amount3 := rosetta_g_miss_num_map(p0_a44);
    ddp_act_metric_rec.percent1 := rosetta_g_miss_num_map(p0_a45);
    ddp_act_metric_rec.percent2 := rosetta_g_miss_num_map(p0_a46);
    ddp_act_metric_rec.percent3 := rosetta_g_miss_num_map(p0_a47);
    ddp_act_metric_rec.published_flag := p0_a48;
    ddp_act_metric_rec.pre_function_name := p0_a49;
    ddp_act_metric_rec.post_function_name := p0_a50;
    ddp_act_metric_rec.attribute_category := p0_a51;
    ddp_act_metric_rec.attribute1 := p0_a52;
    ddp_act_metric_rec.attribute2 := p0_a53;
    ddp_act_metric_rec.attribute3 := p0_a54;
    ddp_act_metric_rec.attribute4 := p0_a55;
    ddp_act_metric_rec.attribute5 := p0_a56;
    ddp_act_metric_rec.attribute6 := p0_a57;
    ddp_act_metric_rec.attribute7 := p0_a58;
    ddp_act_metric_rec.attribute8 := p0_a59;
    ddp_act_metric_rec.attribute9 := p0_a60;
    ddp_act_metric_rec.attribute10 := p0_a61;
    ddp_act_metric_rec.attribute11 := p0_a62;
    ddp_act_metric_rec.attribute12 := p0_a63;
    ddp_act_metric_rec.attribute13 := p0_a64;
    ddp_act_metric_rec.attribute14 := p0_a65;
    ddp_act_metric_rec.attribute15 := p0_a66;
    ddp_act_metric_rec.description := p0_a67;
    ddp_act_metric_rec.act_metric_date := rosetta_g_miss_date_in_map(p0_a68);
    ddp_act_metric_rec.depend_act_metric := rosetta_g_miss_num_map(p0_a69);
    ddp_act_metric_rec.function_used_by_id := rosetta_g_miss_num_map(p0_a70);
    ddp_act_metric_rec.arc_function_used_by := p0_a71;
    ddp_act_metric_rec.hierarchy_type := p0_a72;
    ddp_act_metric_rec.status_code := p0_a73;
    ddp_act_metric_rec.method_code := p0_a74;
    ddp_act_metric_rec.action_code := p0_a75;
    ddp_act_metric_rec.basis_year := rosetta_g_miss_num_map(p0_a76);
    ddp_act_metric_rec.ex_start_node := p0_a77;

    ddx_complete_rec.activity_metric_id := rosetta_g_miss_num_map(p1_a0);
    ddx_complete_rec.last_update_date := rosetta_g_miss_date_in_map(p1_a1);
    ddx_complete_rec.last_updated_by := rosetta_g_miss_num_map(p1_a2);
    ddx_complete_rec.creation_date := rosetta_g_miss_date_in_map(p1_a3);
    ddx_complete_rec.created_by := rosetta_g_miss_num_map(p1_a4);
    ddx_complete_rec.last_update_login := rosetta_g_miss_num_map(p1_a5);
    ddx_complete_rec.object_version_number := rosetta_g_miss_num_map(p1_a6);
    ddx_complete_rec.act_metric_used_by_id := rosetta_g_miss_num_map(p1_a7);
    ddx_complete_rec.arc_act_metric_used_by := p1_a8;
    ddx_complete_rec.purchase_req_raised_flag := p1_a9;
    ddx_complete_rec.application_id := rosetta_g_miss_num_map(p1_a10);
    ddx_complete_rec.sensitive_data_flag := p1_a11;
    ddx_complete_rec.budget_id := rosetta_g_miss_num_map(p1_a12);
    ddx_complete_rec.metric_id := rosetta_g_miss_num_map(p1_a13);
    ddx_complete_rec.transaction_currency_code := p1_a14;
    ddx_complete_rec.trans_forecasted_value := rosetta_g_miss_num_map(p1_a15);
    ddx_complete_rec.trans_committed_value := rosetta_g_miss_num_map(p1_a16);
    ddx_complete_rec.trans_actual_value := rosetta_g_miss_num_map(p1_a17);
    ddx_complete_rec.functional_currency_code := p1_a18;
    ddx_complete_rec.func_forecasted_value := rosetta_g_miss_num_map(p1_a19);
    ddx_complete_rec.dirty_flag := p1_a20;
    ddx_complete_rec.func_committed_value := rosetta_g_miss_num_map(p1_a21);
    ddx_complete_rec.func_actual_value := rosetta_g_miss_num_map(p1_a22);
    ddx_complete_rec.last_calculated_date := rosetta_g_miss_date_in_map(p1_a23);
    ddx_complete_rec.variable_value := rosetta_g_miss_num_map(p1_a24);
    ddx_complete_rec.forecasted_variable_value := rosetta_g_miss_num_map(p1_a25);
    ddx_complete_rec.computed_using_function_value := rosetta_g_miss_num_map(p1_a26);
    ddx_complete_rec.metric_uom_code := p1_a27;
    ddx_complete_rec.org_id := rosetta_g_miss_num_map(p1_a28);
    ddx_complete_rec.difference_since_last_calc := rosetta_g_miss_num_map(p1_a29);
    ddx_complete_rec.activity_metric_origin_id := rosetta_g_miss_num_map(p1_a30);
    ddx_complete_rec.arc_activity_metric_origin := p1_a31;
    ddx_complete_rec.days_since_last_refresh := rosetta_g_miss_num_map(p1_a32);
    ddx_complete_rec.scenario_id := rosetta_g_miss_num_map(p1_a33);
    ddx_complete_rec.summarize_to_metric := rosetta_g_miss_num_map(p1_a34);
    ddx_complete_rec.rollup_to_metric := rosetta_g_miss_num_map(p1_a35);
    ddx_complete_rec.hierarchy_id := rosetta_g_miss_num_map(p1_a36);
    ddx_complete_rec.start_node := rosetta_g_miss_num_map(p1_a37);
    ddx_complete_rec.from_level := rosetta_g_miss_num_map(p1_a38);
    ddx_complete_rec.to_level := rosetta_g_miss_num_map(p1_a39);
    ddx_complete_rec.from_date := rosetta_g_miss_date_in_map(p1_a40);
    ddx_complete_rec.to_date := rosetta_g_miss_date_in_map(p1_a41);
    ddx_complete_rec.amount1 := rosetta_g_miss_num_map(p1_a42);
    ddx_complete_rec.amount2 := rosetta_g_miss_num_map(p1_a43);
    ddx_complete_rec.amount3 := rosetta_g_miss_num_map(p1_a44);
    ddx_complete_rec.percent1 := rosetta_g_miss_num_map(p1_a45);
    ddx_complete_rec.percent2 := rosetta_g_miss_num_map(p1_a46);
    ddx_complete_rec.percent3 := rosetta_g_miss_num_map(p1_a47);
    ddx_complete_rec.published_flag := p1_a48;
    ddx_complete_rec.pre_function_name := p1_a49;
    ddx_complete_rec.post_function_name := p1_a50;
    ddx_complete_rec.attribute_category := p1_a51;
    ddx_complete_rec.attribute1 := p1_a52;
    ddx_complete_rec.attribute2 := p1_a53;
    ddx_complete_rec.attribute3 := p1_a54;
    ddx_complete_rec.attribute4 := p1_a55;
    ddx_complete_rec.attribute5 := p1_a56;
    ddx_complete_rec.attribute6 := p1_a57;
    ddx_complete_rec.attribute7 := p1_a58;
    ddx_complete_rec.attribute8 := p1_a59;
    ddx_complete_rec.attribute9 := p1_a60;
    ddx_complete_rec.attribute10 := p1_a61;
    ddx_complete_rec.attribute11 := p1_a62;
    ddx_complete_rec.attribute12 := p1_a63;
    ddx_complete_rec.attribute13 := p1_a64;
    ddx_complete_rec.attribute14 := p1_a65;
    ddx_complete_rec.attribute15 := p1_a66;
    ddx_complete_rec.description := p1_a67;
    ddx_complete_rec.act_metric_date := rosetta_g_miss_date_in_map(p1_a68);
    ddx_complete_rec.depend_act_metric := rosetta_g_miss_num_map(p1_a69);
    ddx_complete_rec.function_used_by_id := rosetta_g_miss_num_map(p1_a70);
    ddx_complete_rec.arc_function_used_by := p1_a71;
    ddx_complete_rec.hierarchy_type := p1_a72;
    ddx_complete_rec.status_code := p1_a73;
    ddx_complete_rec.method_code := p1_a74;
    ddx_complete_rec.action_code := p1_a75;
    ddx_complete_rec.basis_year := rosetta_g_miss_num_map(p1_a76);
    ddx_complete_rec.ex_start_node := p1_a77;

    -- here's the delegated call to the old PL/SQL routine
    ams_actmetric_pvt.complete_actmetric_rec(ddp_act_metric_rec,
      ddx_complete_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    p1_a0 := rosetta_g_miss_num_map(ddx_complete_rec.activity_metric_id);
    p1_a1 := ddx_complete_rec.last_update_date;
    p1_a2 := rosetta_g_miss_num_map(ddx_complete_rec.last_updated_by);
    p1_a3 := ddx_complete_rec.creation_date;
    p1_a4 := rosetta_g_miss_num_map(ddx_complete_rec.created_by);
    p1_a5 := rosetta_g_miss_num_map(ddx_complete_rec.last_update_login);
    p1_a6 := rosetta_g_miss_num_map(ddx_complete_rec.object_version_number);
    p1_a7 := rosetta_g_miss_num_map(ddx_complete_rec.act_metric_used_by_id);
    p1_a8 := ddx_complete_rec.arc_act_metric_used_by;
    p1_a9 := ddx_complete_rec.purchase_req_raised_flag;
    p1_a10 := rosetta_g_miss_num_map(ddx_complete_rec.application_id);
    p1_a11 := ddx_complete_rec.sensitive_data_flag;
    p1_a12 := rosetta_g_miss_num_map(ddx_complete_rec.budget_id);
    p1_a13 := rosetta_g_miss_num_map(ddx_complete_rec.metric_id);
    p1_a14 := ddx_complete_rec.transaction_currency_code;
    p1_a15 := rosetta_g_miss_num_map(ddx_complete_rec.trans_forecasted_value);
    p1_a16 := rosetta_g_miss_num_map(ddx_complete_rec.trans_committed_value);
    p1_a17 := rosetta_g_miss_num_map(ddx_complete_rec.trans_actual_value);
    p1_a18 := ddx_complete_rec.functional_currency_code;
    p1_a19 := rosetta_g_miss_num_map(ddx_complete_rec.func_forecasted_value);
    p1_a20 := ddx_complete_rec.dirty_flag;
    p1_a21 := rosetta_g_miss_num_map(ddx_complete_rec.func_committed_value);
    p1_a22 := rosetta_g_miss_num_map(ddx_complete_rec.func_actual_value);
    p1_a23 := ddx_complete_rec.last_calculated_date;
    p1_a24 := rosetta_g_miss_num_map(ddx_complete_rec.variable_value);
    p1_a25 := rosetta_g_miss_num_map(ddx_complete_rec.forecasted_variable_value);
    p1_a26 := rosetta_g_miss_num_map(ddx_complete_rec.computed_using_function_value);
    p1_a27 := ddx_complete_rec.metric_uom_code;
    p1_a28 := rosetta_g_miss_num_map(ddx_complete_rec.org_id);
    p1_a29 := rosetta_g_miss_num_map(ddx_complete_rec.difference_since_last_calc);
    p1_a30 := rosetta_g_miss_num_map(ddx_complete_rec.activity_metric_origin_id);
    p1_a31 := ddx_complete_rec.arc_activity_metric_origin;
    p1_a32 := rosetta_g_miss_num_map(ddx_complete_rec.days_since_last_refresh);
    p1_a33 := rosetta_g_miss_num_map(ddx_complete_rec.scenario_id);
    p1_a34 := rosetta_g_miss_num_map(ddx_complete_rec.summarize_to_metric);
    p1_a35 := rosetta_g_miss_num_map(ddx_complete_rec.rollup_to_metric);
    p1_a36 := rosetta_g_miss_num_map(ddx_complete_rec.hierarchy_id);
    p1_a37 := rosetta_g_miss_num_map(ddx_complete_rec.start_node);
    p1_a38 := rosetta_g_miss_num_map(ddx_complete_rec.from_level);
    p1_a39 := rosetta_g_miss_num_map(ddx_complete_rec.to_level);
    p1_a40 := ddx_complete_rec.from_date;
    p1_a41 := ddx_complete_rec.to_date;
    p1_a42 := rosetta_g_miss_num_map(ddx_complete_rec.amount1);
    p1_a43 := rosetta_g_miss_num_map(ddx_complete_rec.amount2);
    p1_a44 := rosetta_g_miss_num_map(ddx_complete_rec.amount3);
    p1_a45 := rosetta_g_miss_num_map(ddx_complete_rec.percent1);
    p1_a46 := rosetta_g_miss_num_map(ddx_complete_rec.percent2);
    p1_a47 := rosetta_g_miss_num_map(ddx_complete_rec.percent3);
    p1_a48 := ddx_complete_rec.published_flag;
    p1_a49 := ddx_complete_rec.pre_function_name;
    p1_a50 := ddx_complete_rec.post_function_name;
    p1_a51 := ddx_complete_rec.attribute_category;
    p1_a52 := ddx_complete_rec.attribute1;
    p1_a53 := ddx_complete_rec.attribute2;
    p1_a54 := ddx_complete_rec.attribute3;
    p1_a55 := ddx_complete_rec.attribute4;
    p1_a56 := ddx_complete_rec.attribute5;
    p1_a57 := ddx_complete_rec.attribute6;
    p1_a58 := ddx_complete_rec.attribute7;
    p1_a59 := ddx_complete_rec.attribute8;
    p1_a60 := ddx_complete_rec.attribute9;
    p1_a61 := ddx_complete_rec.attribute10;
    p1_a62 := ddx_complete_rec.attribute11;
    p1_a63 := ddx_complete_rec.attribute12;
    p1_a64 := ddx_complete_rec.attribute13;
    p1_a65 := ddx_complete_rec.attribute14;
    p1_a66 := ddx_complete_rec.attribute15;
    p1_a67 := ddx_complete_rec.description;
    p1_a68 := ddx_complete_rec.act_metric_date;
    p1_a69 := rosetta_g_miss_num_map(ddx_complete_rec.depend_act_metric);
    p1_a70 := rosetta_g_miss_num_map(ddx_complete_rec.function_used_by_id);
    p1_a71 := ddx_complete_rec.arc_function_used_by;
    p1_a72 := ddx_complete_rec.hierarchy_type;
    p1_a73 := ddx_complete_rec.status_code;
    p1_a74 := ddx_complete_rec.method_code;
    p1_a75 := ddx_complete_rec.action_code;
    p1_a76 := rosetta_g_miss_num_map(ddx_complete_rec.basis_year);
    p1_a77 := ddx_complete_rec.ex_start_node;
  end;

  procedure convert_currency(x_return_status out nocopy  VARCHAR2
    , p_from_currency  VARCHAR2
    , p_to_currency  VARCHAR2
    , p_conv_date  date
    , p_from_amount  NUMBER
    , x_to_amount out nocopy  NUMBER
    , p_round  VARCHAR2
  )

  as
    ddp_conv_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_conv_date := rosetta_g_miss_date_in_map(p_conv_date);




    -- here's the delegated call to the old PL/SQL routine
    ams_actmetric_pvt.convert_currency(x_return_status,
      p_from_currency,
      p_to_currency,
      ddp_conv_date,
      p_from_amount,
      x_to_amount,
      p_round);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure convert_currency2(x_return_status out nocopy  VARCHAR2
    , p_from_currency  VARCHAR2
    , p_to_currency  VARCHAR2
    , p_conv_date  date
    , p_from_amount  NUMBER
    , x_to_amount out nocopy  NUMBER
    , p_from_amount2  NUMBER
    , x_to_amount2 out nocopy  NUMBER
    , p_round  VARCHAR2
  )

  as
    ddp_conv_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_conv_date := rosetta_g_miss_date_in_map(p_conv_date);






    -- here's the delegated call to the old PL/SQL routine
    ams_actmetric_pvt.convert_currency2(x_return_status,
      p_from_currency,
      p_to_currency,
      ddp_conv_date,
      p_from_amount,
      x_to_amount,
      p_from_amount2,
      x_to_amount2,
      p_round);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure convert_currency_vector(x_return_status out nocopy  VARCHAR2
    , p_from_currency  VARCHAR2
    , p_to_currency  VARCHAR2
    , p_conv_date  date
    , p_amounts in out nocopy JTF_NUMBER_TABLE
    , p_round  VARCHAR2
  )

  as
    ddp_conv_date date;
    ddp_amounts ams_actmetric_pvt.currency_table;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_conv_date := rosetta_g_miss_date_in_map(p_conv_date);

    ams_actmetric_pvt_w.rosetta_table_copy_in_p1(ddp_amounts, p_amounts);


    -- here's the delegated call to the old PL/SQL routine
    ams_actmetric_pvt.convert_currency_vector(x_return_status,
      p_from_currency,
      p_to_currency,
      ddp_conv_date,
      ddp_amounts,
      p_round);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    ams_actmetric_pvt_w.rosetta_table_copy_out_p1(ddp_amounts, p_amounts);

  end;

  procedure convert_currency_object(x_return_status out nocopy  VARCHAR2
    , p_object_id  NUMBER
    , p_object_type  VARCHAR2
    , p_conv_date  date
    , p_amounts in out nocopy JTF_NUMBER_TABLE
    , p_round  VARCHAR2
  )

  as
    ddp_conv_date date;
    ddp_amounts ams_actmetric_pvt.currency_table;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_conv_date := rosetta_g_miss_date_in_map(p_conv_date);

    ams_actmetric_pvt_w.rosetta_table_copy_in_p1(ddp_amounts, p_amounts);


    -- here's the delegated call to the old PL/SQL routine
    ams_actmetric_pvt.convert_currency_object(x_return_status,
      p_object_id,
      p_object_type,
      ddp_conv_date,
      ddp_amounts,
      p_round);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    ams_actmetric_pvt_w.rosetta_table_copy_out_p1(ddp_amounts, p_amounts);

  end;

  procedure get_results(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_metric_id  NUMBER
    , p_object_type  VARCHAR2
    , p_object_id  NUMBER
    , p_value_type  VARCHAR2
    , p_from_date  date
    , p_to_date  date
    , p_increment  NUMBER
    , p_interval_unit  VARCHAR2
    , p13_a0 out nocopy JTF_DATE_TABLE
    , p13_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a2 out nocopy JTF_NUMBER_TABLE
    , p13_a3 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_from_date date;
    ddp_to_date date;
    ddx_result_table ams_actmetric_pvt.result_table;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    ddp_from_date := rosetta_g_miss_date_in_map(p_from_date);

    ddp_to_date := rosetta_g_miss_date_in_map(p_to_date);




    -- here's the delegated call to the old PL/SQL routine
    ams_actmetric_pvt.get_results(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_metric_id,
      p_object_type,
      p_object_id,
      p_value_type,
      ddp_from_date,
      ddp_to_date,
      p_increment,
      p_interval_unit,
      ddx_result_table);

    -- copy data back from the local variables to OUT or IN-OUT args, if any













    ams_actmetric_pvt_w.rosetta_table_copy_out_p28(ddx_result_table, p13_a0
      , p13_a1
      , p13_a2
      , p13_a3
      );
  end;

end ams_actmetric_pvt_w;

/
