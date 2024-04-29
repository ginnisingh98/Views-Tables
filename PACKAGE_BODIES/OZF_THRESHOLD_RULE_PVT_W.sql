--------------------------------------------------------
--  DDL for Package Body OZF_THRESHOLD_RULE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_THRESHOLD_RULE_PVT_W" as
  /* $Header: ozfwtrub.pls 115.1 2003/11/28 12:28:32 pkarthik noship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure rosetta_table_copy_in_p3(t out nocopy ozf_threshold_rule_pvt.threshold_rule_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_DATE_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_DATE_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_DATE_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_DATE_TABLE
    , a18 JTF_DATE_TABLE
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_VARCHAR2_TABLE_100
    , a26 JTF_VARCHAR2_TABLE_100
    , a27 JTF_VARCHAR2_TABLE_200
    , a28 JTF_VARCHAR2_TABLE_200
    , a29 JTF_VARCHAR2_TABLE_200
    , a30 JTF_VARCHAR2_TABLE_200
    , a31 JTF_VARCHAR2_TABLE_200
    , a32 JTF_VARCHAR2_TABLE_200
    , a33 JTF_VARCHAR2_TABLE_200
    , a34 JTF_VARCHAR2_TABLE_200
    , a35 JTF_VARCHAR2_TABLE_200
    , a36 JTF_VARCHAR2_TABLE_200
    , a37 JTF_VARCHAR2_TABLE_200
    , a38 JTF_VARCHAR2_TABLE_200
    , a39 JTF_VARCHAR2_TABLE_200
    , a40 JTF_VARCHAR2_TABLE_200
    , a41 JTF_VARCHAR2_TABLE_200
    , a42 JTF_NUMBER_TABLE
    , a43 JTF_NUMBER_TABLE
    , a44 JTF_NUMBER_TABLE
    , a45 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).threshold_rule_id := a0(indx);
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a1(indx));
          t(ddindx).last_updated_by := a2(indx);
          t(ddindx).last_update_login := a3(indx);
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a4(indx));
          t(ddindx).created_by := a5(indx);
          t(ddindx).created_from := a6(indx);
          t(ddindx).request_id := a7(indx);
          t(ddindx).program_application_id := a8(indx);
          t(ddindx).program_id := a9(indx);
          t(ddindx).program_update_date := rosetta_g_miss_date_in_map(a10(indx));
          t(ddindx).period_type := a11(indx);
          t(ddindx).enabled_flag := a12(indx);
          t(ddindx).threshold_calendar := a13(indx);
          t(ddindx).start_period_name := a14(indx);
          t(ddindx).end_period_name := a15(indx);
          t(ddindx).threshold_id := a16(indx);
          t(ddindx).start_date := rosetta_g_miss_date_in_map(a17(indx));
          t(ddindx).end_date := rosetta_g_miss_date_in_map(a18(indx));
          t(ddindx).value_limit := a19(indx);
          t(ddindx).operator_code := a20(indx);
          t(ddindx).percent_amount := a21(indx);
          t(ddindx).base_line := a22(indx);
          t(ddindx).error_mode := a23(indx);
          t(ddindx).repeat_frequency := a24(indx);
          t(ddindx).frequency_period := a25(indx);
          t(ddindx).attribute_category := a26(indx);
          t(ddindx).attribute1 := a27(indx);
          t(ddindx).attribute2 := a28(indx);
          t(ddindx).attribute3 := a29(indx);
          t(ddindx).attribute4 := a30(indx);
          t(ddindx).attribute5 := a31(indx);
          t(ddindx).attribute6 := a32(indx);
          t(ddindx).attribute7 := a33(indx);
          t(ddindx).attribute8 := a34(indx);
          t(ddindx).attribute9 := a35(indx);
          t(ddindx).attribute10 := a36(indx);
          t(ddindx).attribute11 := a37(indx);
          t(ddindx).attribute12 := a38(indx);
          t(ddindx).attribute13 := a39(indx);
          t(ddindx).attribute14 := a40(indx);
          t(ddindx).attribute15 := a41(indx);
          t(ddindx).org_id := a42(indx);
          t(ddindx).security_group_id := a43(indx);
          t(ddindx).converted_days := a44(indx);
          t(ddindx).object_version_number := a45(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t ozf_threshold_rule_pvt.threshold_rule_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_DATE_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_DATE_TABLE
    , a18 out nocopy JTF_DATE_TABLE
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    , a23 out nocopy JTF_VARCHAR2_TABLE_100
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_VARCHAR2_TABLE_100
    , a26 out nocopy JTF_VARCHAR2_TABLE_100
    , a27 out nocopy JTF_VARCHAR2_TABLE_200
    , a28 out nocopy JTF_VARCHAR2_TABLE_200
    , a29 out nocopy JTF_VARCHAR2_TABLE_200
    , a30 out nocopy JTF_VARCHAR2_TABLE_200
    , a31 out nocopy JTF_VARCHAR2_TABLE_200
    , a32 out nocopy JTF_VARCHAR2_TABLE_200
    , a33 out nocopy JTF_VARCHAR2_TABLE_200
    , a34 out nocopy JTF_VARCHAR2_TABLE_200
    , a35 out nocopy JTF_VARCHAR2_TABLE_200
    , a36 out nocopy JTF_VARCHAR2_TABLE_200
    , a37 out nocopy JTF_VARCHAR2_TABLE_200
    , a38 out nocopy JTF_VARCHAR2_TABLE_200
    , a39 out nocopy JTF_VARCHAR2_TABLE_200
    , a40 out nocopy JTF_VARCHAR2_TABLE_200
    , a41 out nocopy JTF_VARCHAR2_TABLE_200
    , a42 out nocopy JTF_NUMBER_TABLE
    , a43 out nocopy JTF_NUMBER_TABLE
    , a44 out nocopy JTF_NUMBER_TABLE
    , a45 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_DATE_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_DATE_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_DATE_TABLE();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_DATE_TABLE();
    a18 := JTF_DATE_TABLE();
    a19 := JTF_VARCHAR2_TABLE_100();
    a20 := JTF_VARCHAR2_TABLE_100();
    a21 := JTF_NUMBER_TABLE();
    a22 := JTF_VARCHAR2_TABLE_100();
    a23 := JTF_VARCHAR2_TABLE_100();
    a24 := JTF_NUMBER_TABLE();
    a25 := JTF_VARCHAR2_TABLE_100();
    a26 := JTF_VARCHAR2_TABLE_100();
    a27 := JTF_VARCHAR2_TABLE_200();
    a28 := JTF_VARCHAR2_TABLE_200();
    a29 := JTF_VARCHAR2_TABLE_200();
    a30 := JTF_VARCHAR2_TABLE_200();
    a31 := JTF_VARCHAR2_TABLE_200();
    a32 := JTF_VARCHAR2_TABLE_200();
    a33 := JTF_VARCHAR2_TABLE_200();
    a34 := JTF_VARCHAR2_TABLE_200();
    a35 := JTF_VARCHAR2_TABLE_200();
    a36 := JTF_VARCHAR2_TABLE_200();
    a37 := JTF_VARCHAR2_TABLE_200();
    a38 := JTF_VARCHAR2_TABLE_200();
    a39 := JTF_VARCHAR2_TABLE_200();
    a40 := JTF_VARCHAR2_TABLE_200();
    a41 := JTF_VARCHAR2_TABLE_200();
    a42 := JTF_NUMBER_TABLE();
    a43 := JTF_NUMBER_TABLE();
    a44 := JTF_NUMBER_TABLE();
    a45 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_DATE_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_DATE_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_DATE_TABLE();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_DATE_TABLE();
      a18 := JTF_DATE_TABLE();
      a19 := JTF_VARCHAR2_TABLE_100();
      a20 := JTF_VARCHAR2_TABLE_100();
      a21 := JTF_NUMBER_TABLE();
      a22 := JTF_VARCHAR2_TABLE_100();
      a23 := JTF_VARCHAR2_TABLE_100();
      a24 := JTF_NUMBER_TABLE();
      a25 := JTF_VARCHAR2_TABLE_100();
      a26 := JTF_VARCHAR2_TABLE_100();
      a27 := JTF_VARCHAR2_TABLE_200();
      a28 := JTF_VARCHAR2_TABLE_200();
      a29 := JTF_VARCHAR2_TABLE_200();
      a30 := JTF_VARCHAR2_TABLE_200();
      a31 := JTF_VARCHAR2_TABLE_200();
      a32 := JTF_VARCHAR2_TABLE_200();
      a33 := JTF_VARCHAR2_TABLE_200();
      a34 := JTF_VARCHAR2_TABLE_200();
      a35 := JTF_VARCHAR2_TABLE_200();
      a36 := JTF_VARCHAR2_TABLE_200();
      a37 := JTF_VARCHAR2_TABLE_200();
      a38 := JTF_VARCHAR2_TABLE_200();
      a39 := JTF_VARCHAR2_TABLE_200();
      a40 := JTF_VARCHAR2_TABLE_200();
      a41 := JTF_VARCHAR2_TABLE_200();
      a42 := JTF_NUMBER_TABLE();
      a43 := JTF_NUMBER_TABLE();
      a44 := JTF_NUMBER_TABLE();
      a45 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        a5.extend(t.count);
        a6.extend(t.count);
        a7.extend(t.count);
        a8.extend(t.count);
        a9.extend(t.count);
        a10.extend(t.count);
        a11.extend(t.count);
        a12.extend(t.count);
        a13.extend(t.count);
        a14.extend(t.count);
        a15.extend(t.count);
        a16.extend(t.count);
        a17.extend(t.count);
        a18.extend(t.count);
        a19.extend(t.count);
        a20.extend(t.count);
        a21.extend(t.count);
        a22.extend(t.count);
        a23.extend(t.count);
        a24.extend(t.count);
        a25.extend(t.count);
        a26.extend(t.count);
        a27.extend(t.count);
        a28.extend(t.count);
        a29.extend(t.count);
        a30.extend(t.count);
        a31.extend(t.count);
        a32.extend(t.count);
        a33.extend(t.count);
        a34.extend(t.count);
        a35.extend(t.count);
        a36.extend(t.count);
        a37.extend(t.count);
        a38.extend(t.count);
        a39.extend(t.count);
        a40.extend(t.count);
        a41.extend(t.count);
        a42.extend(t.count);
        a43.extend(t.count);
        a44.extend(t.count);
        a45.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).threshold_rule_id;
          a1(indx) := t(ddindx).last_update_date;
          a2(indx) := t(ddindx).last_updated_by;
          a3(indx) := t(ddindx).last_update_login;
          a4(indx) := t(ddindx).creation_date;
          a5(indx) := t(ddindx).created_by;
          a6(indx) := t(ddindx).created_from;
          a7(indx) := t(ddindx).request_id;
          a8(indx) := t(ddindx).program_application_id;
          a9(indx) := t(ddindx).program_id;
          a10(indx) := t(ddindx).program_update_date;
          a11(indx) := t(ddindx).period_type;
          a12(indx) := t(ddindx).enabled_flag;
          a13(indx) := t(ddindx).threshold_calendar;
          a14(indx) := t(ddindx).start_period_name;
          a15(indx) := t(ddindx).end_period_name;
          a16(indx) := t(ddindx).threshold_id;
          a17(indx) := t(ddindx).start_date;
          a18(indx) := t(ddindx).end_date;
          a19(indx) := t(ddindx).value_limit;
          a20(indx) := t(ddindx).operator_code;
          a21(indx) := t(ddindx).percent_amount;
          a22(indx) := t(ddindx).base_line;
          a23(indx) := t(ddindx).error_mode;
          a24(indx) := t(ddindx).repeat_frequency;
          a25(indx) := t(ddindx).frequency_period;
          a26(indx) := t(ddindx).attribute_category;
          a27(indx) := t(ddindx).attribute1;
          a28(indx) := t(ddindx).attribute2;
          a29(indx) := t(ddindx).attribute3;
          a30(indx) := t(ddindx).attribute4;
          a31(indx) := t(ddindx).attribute5;
          a32(indx) := t(ddindx).attribute6;
          a33(indx) := t(ddindx).attribute7;
          a34(indx) := t(ddindx).attribute8;
          a35(indx) := t(ddindx).attribute9;
          a36(indx) := t(ddindx).attribute10;
          a37(indx) := t(ddindx).attribute11;
          a38(indx) := t(ddindx).attribute12;
          a39(indx) := t(ddindx).attribute13;
          a40(indx) := t(ddindx).attribute14;
          a41(indx) := t(ddindx).attribute15;
          a42(indx) := t(ddindx).org_id;
          a43(indx) := t(ddindx).security_group_id;
          a44(indx) := t(ddindx).converted_days;
          a45(indx) := t(ddindx).object_version_number;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure create_threshold_rule(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  DATE
    , p7_a2  NUMBER
    , p7_a3  NUMBER
    , p7_a4  DATE
    , p7_a5  NUMBER
    , p7_a6  VARCHAR2
    , p7_a7  NUMBER
    , p7_a8  NUMBER
    , p7_a9  NUMBER
    , p7_a10  DATE
    , p7_a11  VARCHAR2
    , p7_a12  VARCHAR2
    , p7_a13  VARCHAR2
    , p7_a14  VARCHAR2
    , p7_a15  VARCHAR2
    , p7_a16  NUMBER
    , p7_a17  DATE
    , p7_a18  DATE
    , p7_a19  VARCHAR2
    , p7_a20  VARCHAR2
    , p7_a21  NUMBER
    , p7_a22  VARCHAR2
    , p7_a23  VARCHAR2
    , p7_a24  NUMBER
    , p7_a25  VARCHAR2
    , p7_a26  VARCHAR2
    , p7_a27  VARCHAR2
    , p7_a28  VARCHAR2
    , p7_a29  VARCHAR2
    , p7_a30  VARCHAR2
    , p7_a31  VARCHAR2
    , p7_a32  VARCHAR2
    , p7_a33  VARCHAR2
    , p7_a34  VARCHAR2
    , p7_a35  VARCHAR2
    , p7_a36  VARCHAR2
    , p7_a37  VARCHAR2
    , p7_a38  VARCHAR2
    , p7_a39  VARCHAR2
    , p7_a40  VARCHAR2
    , p7_a41  VARCHAR2
    , p7_a42  NUMBER
    , p7_a43  NUMBER
    , p7_a44  NUMBER
    , p7_a45  NUMBER
    , x_threshold_rule_id out nocopy  NUMBER
    , p_comparison_type    VARCHAR2
    , p_alert_type    VARCHAR2
  )

  as
    ddp_threshold_rule_rec ozf_threshold_rule_pvt.threshold_rule_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_threshold_rule_rec.threshold_rule_id := p7_a0;
    ddp_threshold_rule_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_threshold_rule_rec.last_updated_by := p7_a2;
    ddp_threshold_rule_rec.last_update_login := p7_a3;
    ddp_threshold_rule_rec.creation_date := rosetta_g_miss_date_in_map(p7_a4);
    ddp_threshold_rule_rec.created_by := p7_a5;
    ddp_threshold_rule_rec.created_from := p7_a6;
    ddp_threshold_rule_rec.request_id := p7_a7;
    ddp_threshold_rule_rec.program_application_id := p7_a8;
    ddp_threshold_rule_rec.program_id := p7_a9;
    ddp_threshold_rule_rec.program_update_date := rosetta_g_miss_date_in_map(p7_a10);
    ddp_threshold_rule_rec.period_type := p7_a11;
    ddp_threshold_rule_rec.enabled_flag := p7_a12;
    ddp_threshold_rule_rec.threshold_calendar := p7_a13;
    ddp_threshold_rule_rec.start_period_name := p7_a14;
    ddp_threshold_rule_rec.end_period_name := p7_a15;
    ddp_threshold_rule_rec.threshold_id := p7_a16;
    ddp_threshold_rule_rec.start_date := rosetta_g_miss_date_in_map(p7_a17);
    ddp_threshold_rule_rec.end_date := rosetta_g_miss_date_in_map(p7_a18);
    ddp_threshold_rule_rec.value_limit := p7_a19;
    ddp_threshold_rule_rec.operator_code := p7_a20;
    ddp_threshold_rule_rec.percent_amount := p7_a21;
    ddp_threshold_rule_rec.base_line := p7_a22;
    ddp_threshold_rule_rec.error_mode := p7_a23;
    ddp_threshold_rule_rec.repeat_frequency := p7_a24;
    ddp_threshold_rule_rec.frequency_period := p7_a25;
    ddp_threshold_rule_rec.attribute_category := p7_a26;
    ddp_threshold_rule_rec.attribute1 := p7_a27;
    ddp_threshold_rule_rec.attribute2 := p7_a28;
    ddp_threshold_rule_rec.attribute3 := p7_a29;
    ddp_threshold_rule_rec.attribute4 := p7_a30;
    ddp_threshold_rule_rec.attribute5 := p7_a31;
    ddp_threshold_rule_rec.attribute6 := p7_a32;
    ddp_threshold_rule_rec.attribute7 := p7_a33;
    ddp_threshold_rule_rec.attribute8 := p7_a34;
    ddp_threshold_rule_rec.attribute9 := p7_a35;
    ddp_threshold_rule_rec.attribute10 := p7_a36;
    ddp_threshold_rule_rec.attribute11 := p7_a37;
    ddp_threshold_rule_rec.attribute12 := p7_a38;
    ddp_threshold_rule_rec.attribute13 := p7_a39;
    ddp_threshold_rule_rec.attribute14 := p7_a40;
    ddp_threshold_rule_rec.attribute15 := p7_a41;
    ddp_threshold_rule_rec.org_id := p7_a42;
    ddp_threshold_rule_rec.security_group_id := p7_a43;
    ddp_threshold_rule_rec.converted_days := p7_a44;
    ddp_threshold_rule_rec.object_version_number := p7_a45;
    ddp_threshold_rule_rec.comparison_type := p_comparison_type;
    ddp_threshold_rule_rec.alert_type := p_alert_type;

    -- here's the delegated call to the old PL/SQL routine
    ozf_threshold_rule_pvt.create_threshold_rule(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_threshold_rule_rec,
      x_threshold_rule_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_threshold_rule(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  DATE
    , p7_a2  NUMBER
    , p7_a3  NUMBER
    , p7_a4  DATE
    , p7_a5  NUMBER
    , p7_a6  VARCHAR2
    , p7_a7  NUMBER
    , p7_a8  NUMBER
    , p7_a9  NUMBER
    , p7_a10  DATE
    , p7_a11  VARCHAR2
    , p7_a12  VARCHAR2
    , p7_a13  VARCHAR2
    , p7_a14  VARCHAR2
    , p7_a15  VARCHAR2
    , p7_a16  NUMBER
    , p7_a17  DATE
    , p7_a18  DATE
    , p7_a19  VARCHAR2
    , p7_a20  VARCHAR2
    , p7_a21  NUMBER
    , p7_a22  VARCHAR2
    , p7_a23  VARCHAR2
    , p7_a24  NUMBER
    , p7_a25  VARCHAR2
    , p7_a26  VARCHAR2
    , p7_a27  VARCHAR2
    , p7_a28  VARCHAR2
    , p7_a29  VARCHAR2
    , p7_a30  VARCHAR2
    , p7_a31  VARCHAR2
    , p7_a32  VARCHAR2
    , p7_a33  VARCHAR2
    , p7_a34  VARCHAR2
    , p7_a35  VARCHAR2
    , p7_a36  VARCHAR2
    , p7_a37  VARCHAR2
    , p7_a38  VARCHAR2
    , p7_a39  VARCHAR2
    , p7_a40  VARCHAR2
    , p7_a41  VARCHAR2
    , p7_a42  NUMBER
    , p7_a43  NUMBER
    , p7_a44  NUMBER
    , p7_a45  NUMBER
    , x_object_version_number out nocopy  NUMBER
    , p_comparison_type    VARCHAR2
    , p_alert_type    VARCHAR2
  )

  as
    ddp_threshold_rule_rec ozf_threshold_rule_pvt.threshold_rule_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_threshold_rule_rec.threshold_rule_id := p7_a0;
    ddp_threshold_rule_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_threshold_rule_rec.last_updated_by := p7_a2;
    ddp_threshold_rule_rec.last_update_login := p7_a3;
    ddp_threshold_rule_rec.creation_date := rosetta_g_miss_date_in_map(p7_a4);
    ddp_threshold_rule_rec.created_by := p7_a5;
    ddp_threshold_rule_rec.created_from := p7_a6;
    ddp_threshold_rule_rec.request_id := p7_a7;
    ddp_threshold_rule_rec.program_application_id := p7_a8;
    ddp_threshold_rule_rec.program_id := p7_a9;
    ddp_threshold_rule_rec.program_update_date := rosetta_g_miss_date_in_map(p7_a10);
    ddp_threshold_rule_rec.period_type := p7_a11;
    ddp_threshold_rule_rec.enabled_flag := p7_a12;
    ddp_threshold_rule_rec.threshold_calendar := p7_a13;
    ddp_threshold_rule_rec.start_period_name := p7_a14;
    ddp_threshold_rule_rec.end_period_name := p7_a15;
    ddp_threshold_rule_rec.threshold_id := p7_a16;
    ddp_threshold_rule_rec.start_date := rosetta_g_miss_date_in_map(p7_a17);
    ddp_threshold_rule_rec.end_date := rosetta_g_miss_date_in_map(p7_a18);
    ddp_threshold_rule_rec.value_limit := p7_a19;
    ddp_threshold_rule_rec.operator_code := p7_a20;
    ddp_threshold_rule_rec.percent_amount := p7_a21;
    ddp_threshold_rule_rec.base_line := p7_a22;
    ddp_threshold_rule_rec.error_mode := p7_a23;
    ddp_threshold_rule_rec.repeat_frequency := p7_a24;
    ddp_threshold_rule_rec.frequency_period := p7_a25;
    ddp_threshold_rule_rec.attribute_category := p7_a26;
    ddp_threshold_rule_rec.attribute1 := p7_a27;
    ddp_threshold_rule_rec.attribute2 := p7_a28;
    ddp_threshold_rule_rec.attribute3 := p7_a29;
    ddp_threshold_rule_rec.attribute4 := p7_a30;
    ddp_threshold_rule_rec.attribute5 := p7_a31;
    ddp_threshold_rule_rec.attribute6 := p7_a32;
    ddp_threshold_rule_rec.attribute7 := p7_a33;
    ddp_threshold_rule_rec.attribute8 := p7_a34;
    ddp_threshold_rule_rec.attribute9 := p7_a35;
    ddp_threshold_rule_rec.attribute10 := p7_a36;
    ddp_threshold_rule_rec.attribute11 := p7_a37;
    ddp_threshold_rule_rec.attribute12 := p7_a38;
    ddp_threshold_rule_rec.attribute13 := p7_a39;
    ddp_threshold_rule_rec.attribute14 := p7_a40;
    ddp_threshold_rule_rec.attribute15 := p7_a41;
    ddp_threshold_rule_rec.org_id := p7_a42;
    ddp_threshold_rule_rec.security_group_id := p7_a43;
    ddp_threshold_rule_rec.converted_days := p7_a44;
    ddp_threshold_rule_rec.object_version_number := p7_a45;
    ddp_threshold_rule_rec.comparison_type := p_comparison_type;
    ddp_threshold_rule_rec.alert_type := p_alert_type;

    -- here's the delegated call to the old PL/SQL routine
    ozf_threshold_rule_pvt.update_threshold_rule(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_threshold_rule_rec,
      x_object_version_number);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure validate_threshold_rule(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p3_a0  NUMBER
    , p3_a1  DATE
    , p3_a2  NUMBER
    , p3_a3  NUMBER
    , p3_a4  DATE
    , p3_a5  NUMBER
    , p3_a6  VARCHAR2
    , p3_a7  NUMBER
    , p3_a8  NUMBER
    , p3_a9  NUMBER
    , p3_a10  DATE
    , p3_a11  VARCHAR2
    , p3_a12  VARCHAR2
    , p3_a13  VARCHAR2
    , p3_a14  VARCHAR2
    , p3_a15  VARCHAR2
    , p3_a16  NUMBER
    , p3_a17  DATE
    , p3_a18  DATE
    , p3_a19  VARCHAR2
    , p3_a20  VARCHAR2
    , p3_a21  NUMBER
    , p3_a22  VARCHAR2
    , p3_a23  VARCHAR2
    , p3_a24  NUMBER
    , p3_a25  VARCHAR2
    , p3_a26  VARCHAR2
    , p3_a27  VARCHAR2
    , p3_a28  VARCHAR2
    , p3_a29  VARCHAR2
    , p3_a30  VARCHAR2
    , p3_a31  VARCHAR2
    , p3_a32  VARCHAR2
    , p3_a33  VARCHAR2
    , p3_a34  VARCHAR2
    , p3_a35  VARCHAR2
    , p3_a36  VARCHAR2
    , p3_a37  VARCHAR2
    , p3_a38  VARCHAR2
    , p3_a39  VARCHAR2
    , p3_a40  VARCHAR2
    , p3_a41  VARCHAR2
    , p3_a42  NUMBER
    , p3_a43  NUMBER
    , p3_a44  NUMBER
    , p3_a45  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_comparison_type    VARCHAR2
    , p_alert_type    VARCHAR2
  )

  as
    ddp_threshold_rule_rec ozf_threshold_rule_pvt.threshold_rule_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_threshold_rule_rec.threshold_rule_id := p3_a0;
    ddp_threshold_rule_rec.last_update_date := rosetta_g_miss_date_in_map(p3_a1);
    ddp_threshold_rule_rec.last_updated_by := p3_a2;
    ddp_threshold_rule_rec.last_update_login := p3_a3;
    ddp_threshold_rule_rec.creation_date := rosetta_g_miss_date_in_map(p3_a4);
    ddp_threshold_rule_rec.created_by := p3_a5;
    ddp_threshold_rule_rec.created_from := p3_a6;
    ddp_threshold_rule_rec.request_id := p3_a7;
    ddp_threshold_rule_rec.program_application_id := p3_a8;
    ddp_threshold_rule_rec.program_id := p3_a9;
    ddp_threshold_rule_rec.program_update_date := rosetta_g_miss_date_in_map(p3_a10);
    ddp_threshold_rule_rec.period_type := p3_a11;
    ddp_threshold_rule_rec.enabled_flag := p3_a12;
    ddp_threshold_rule_rec.threshold_calendar := p3_a13;
    ddp_threshold_rule_rec.start_period_name := p3_a14;
    ddp_threshold_rule_rec.end_period_name := p3_a15;
    ddp_threshold_rule_rec.threshold_id := p3_a16;
    ddp_threshold_rule_rec.start_date := rosetta_g_miss_date_in_map(p3_a17);
    ddp_threshold_rule_rec.end_date := rosetta_g_miss_date_in_map(p3_a18);
    ddp_threshold_rule_rec.value_limit := p3_a19;
    ddp_threshold_rule_rec.operator_code := p3_a20;
    ddp_threshold_rule_rec.percent_amount := p3_a21;
    ddp_threshold_rule_rec.base_line := p3_a22;
    ddp_threshold_rule_rec.error_mode := p3_a23;
    ddp_threshold_rule_rec.repeat_frequency := p3_a24;
    ddp_threshold_rule_rec.frequency_period := p3_a25;
    ddp_threshold_rule_rec.attribute_category := p3_a26;
    ddp_threshold_rule_rec.attribute1 := p3_a27;
    ddp_threshold_rule_rec.attribute2 := p3_a28;
    ddp_threshold_rule_rec.attribute3 := p3_a29;
    ddp_threshold_rule_rec.attribute4 := p3_a30;
    ddp_threshold_rule_rec.attribute5 := p3_a31;
    ddp_threshold_rule_rec.attribute6 := p3_a32;
    ddp_threshold_rule_rec.attribute7 := p3_a33;
    ddp_threshold_rule_rec.attribute8 := p3_a34;
    ddp_threshold_rule_rec.attribute9 := p3_a35;
    ddp_threshold_rule_rec.attribute10 := p3_a36;
    ddp_threshold_rule_rec.attribute11 := p3_a37;
    ddp_threshold_rule_rec.attribute12 := p3_a38;
    ddp_threshold_rule_rec.attribute13 := p3_a39;
    ddp_threshold_rule_rec.attribute14 := p3_a40;
    ddp_threshold_rule_rec.attribute15 := p3_a41;
    ddp_threshold_rule_rec.org_id := p3_a42;
    ddp_threshold_rule_rec.security_group_id := p3_a43;
    ddp_threshold_rule_rec.converted_days := p3_a44;
    ddp_threshold_rule_rec.object_version_number := p3_a45;
    ddp_threshold_rule_rec.comparison_type := p_comparison_type;
    ddp_threshold_rule_rec.alert_type := p_alert_type;



    -- here's the delegated call to the old PL/SQL routine
    ozf_threshold_rule_pvt.validate_threshold_rule(p_api_version_number,
      p_init_msg_list,
      p_validation_level,
      ddp_threshold_rule_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure check_threshold_rule_items(p0_a0  NUMBER
    , p0_a1  DATE
    , p0_a2  NUMBER
    , p0_a3  NUMBER
    , p0_a4  DATE
    , p0_a5  NUMBER
    , p0_a6  VARCHAR2
    , p0_a7  NUMBER
    , p0_a8  NUMBER
    , p0_a9  NUMBER
    , p0_a10  DATE
    , p0_a11  VARCHAR2
    , p0_a12  VARCHAR2
    , p0_a13  VARCHAR2
    , p0_a14  VARCHAR2
    , p0_a15  VARCHAR2
    , p0_a16  NUMBER
    , p0_a17  DATE
    , p0_a18  DATE
    , p0_a19  VARCHAR2
    , p0_a20  VARCHAR2
    , p0_a21  NUMBER
    , p0_a22  VARCHAR2
    , p0_a23  VARCHAR2
    , p0_a24  NUMBER
    , p0_a25  VARCHAR2
    , p0_a26  VARCHAR2
    , p0_a27  VARCHAR2
    , p0_a28  VARCHAR2
    , p0_a29  VARCHAR2
    , p0_a30  VARCHAR2
    , p0_a31  VARCHAR2
    , p0_a32  VARCHAR2
    , p0_a33  VARCHAR2
    , p0_a34  VARCHAR2
    , p0_a35  VARCHAR2
    , p0_a36  VARCHAR2
    , p0_a37  VARCHAR2
    , p0_a38  VARCHAR2
    , p0_a39  VARCHAR2
    , p0_a40  VARCHAR2
    , p0_a41  VARCHAR2
    , p0_a42  NUMBER
    , p0_a43  NUMBER
    , p0_a44  NUMBER
    , p0_a45  NUMBER
    , p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p_comparison_type    VARCHAR2
    , p_alert_type    VARCHAR2
  )

  as
    ddp_threshold_rule_rec ozf_threshold_rule_pvt.threshold_rule_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_threshold_rule_rec.threshold_rule_id := p0_a0;
    ddp_threshold_rule_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_threshold_rule_rec.last_updated_by := p0_a2;
    ddp_threshold_rule_rec.last_update_login := p0_a3;
    ddp_threshold_rule_rec.creation_date := rosetta_g_miss_date_in_map(p0_a4);
    ddp_threshold_rule_rec.created_by := p0_a5;
    ddp_threshold_rule_rec.created_from := p0_a6;
    ddp_threshold_rule_rec.request_id := p0_a7;
    ddp_threshold_rule_rec.program_application_id := p0_a8;
    ddp_threshold_rule_rec.program_id := p0_a9;
    ddp_threshold_rule_rec.program_update_date := rosetta_g_miss_date_in_map(p0_a10);
    ddp_threshold_rule_rec.period_type := p0_a11;
    ddp_threshold_rule_rec.enabled_flag := p0_a12;
    ddp_threshold_rule_rec.threshold_calendar := p0_a13;
    ddp_threshold_rule_rec.start_period_name := p0_a14;
    ddp_threshold_rule_rec.end_period_name := p0_a15;
    ddp_threshold_rule_rec.threshold_id := p0_a16;
    ddp_threshold_rule_rec.start_date := rosetta_g_miss_date_in_map(p0_a17);
    ddp_threshold_rule_rec.end_date := rosetta_g_miss_date_in_map(p0_a18);
    ddp_threshold_rule_rec.value_limit := p0_a19;
    ddp_threshold_rule_rec.operator_code := p0_a20;
    ddp_threshold_rule_rec.percent_amount := p0_a21;
    ddp_threshold_rule_rec.base_line := p0_a22;
    ddp_threshold_rule_rec.error_mode := p0_a23;
    ddp_threshold_rule_rec.repeat_frequency := p0_a24;
    ddp_threshold_rule_rec.frequency_period := p0_a25;
    ddp_threshold_rule_rec.attribute_category := p0_a26;
    ddp_threshold_rule_rec.attribute1 := p0_a27;
    ddp_threshold_rule_rec.attribute2 := p0_a28;
    ddp_threshold_rule_rec.attribute3 := p0_a29;
    ddp_threshold_rule_rec.attribute4 := p0_a30;
    ddp_threshold_rule_rec.attribute5 := p0_a31;
    ddp_threshold_rule_rec.attribute6 := p0_a32;
    ddp_threshold_rule_rec.attribute7 := p0_a33;
    ddp_threshold_rule_rec.attribute8 := p0_a34;
    ddp_threshold_rule_rec.attribute9 := p0_a35;
    ddp_threshold_rule_rec.attribute10 := p0_a36;
    ddp_threshold_rule_rec.attribute11 := p0_a37;
    ddp_threshold_rule_rec.attribute12 := p0_a38;
    ddp_threshold_rule_rec.attribute13 := p0_a39;
    ddp_threshold_rule_rec.attribute14 := p0_a40;
    ddp_threshold_rule_rec.attribute15 := p0_a41;
    ddp_threshold_rule_rec.org_id := p0_a42;
    ddp_threshold_rule_rec.security_group_id := p0_a43;
    ddp_threshold_rule_rec.converted_days := p0_a44;
    ddp_threshold_rule_rec.object_version_number := p0_a45;
    ddp_threshold_rule_rec.comparison_type := p_comparison_type;
    ddp_threshold_rule_rec.alert_type := p_alert_type;


    -- here's the delegated call to the old PL/SQL routine
    ozf_threshold_rule_pvt.check_threshold_rule_items(ddp_threshold_rule_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure validate_threshold_rule_rec(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  DATE
    , p5_a2  NUMBER
    , p5_a3  NUMBER
    , p5_a4  DATE
    , p5_a5  NUMBER
    , p5_a6  VARCHAR2
    , p5_a7  NUMBER
    , p5_a8  NUMBER
    , p5_a9  NUMBER
    , p5_a10  DATE
    , p5_a11  VARCHAR2
    , p5_a12  VARCHAR2
    , p5_a13  VARCHAR2
    , p5_a14  VARCHAR2
    , p5_a15  VARCHAR2
    , p5_a16  NUMBER
    , p5_a17  DATE
    , p5_a18  DATE
    , p5_a19  VARCHAR2
    , p5_a20  VARCHAR2
    , p5_a21  NUMBER
    , p5_a22  VARCHAR2
    , p5_a23  VARCHAR2
    , p5_a24  NUMBER
    , p5_a25  VARCHAR2
    , p5_a26  VARCHAR2
    , p5_a27  VARCHAR2
    , p5_a28  VARCHAR2
    , p5_a29  VARCHAR2
    , p5_a30  VARCHAR2
    , p5_a31  VARCHAR2
    , p5_a32  VARCHAR2
    , p5_a33  VARCHAR2
    , p5_a34  VARCHAR2
    , p5_a35  VARCHAR2
    , p5_a36  VARCHAR2
    , p5_a37  VARCHAR2
    , p5_a38  VARCHAR2
    , p5_a39  VARCHAR2
    , p5_a40  VARCHAR2
    , p5_a41  VARCHAR2
    , p5_a42  NUMBER
    , p5_a43  NUMBER
    , p5_a44  NUMBER
    , p5_a45  NUMBER
    , p_comparison_type    VARCHAR2
    , p_alert_type    VARCHAR2
  )

  as
    ddp_threshold_rule_rec ozf_threshold_rule_pvt.threshold_rule_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_threshold_rule_rec.threshold_rule_id := p5_a0;
    ddp_threshold_rule_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a1);
    ddp_threshold_rule_rec.last_updated_by := p5_a2;
    ddp_threshold_rule_rec.last_update_login := p5_a3;
    ddp_threshold_rule_rec.creation_date := rosetta_g_miss_date_in_map(p5_a4);
    ddp_threshold_rule_rec.created_by := p5_a5;
    ddp_threshold_rule_rec.created_from := p5_a6;
    ddp_threshold_rule_rec.request_id := p5_a7;
    ddp_threshold_rule_rec.program_application_id := p5_a8;
    ddp_threshold_rule_rec.program_id := p5_a9;
    ddp_threshold_rule_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_threshold_rule_rec.period_type := p5_a11;
    ddp_threshold_rule_rec.enabled_flag := p5_a12;
    ddp_threshold_rule_rec.threshold_calendar := p5_a13;
    ddp_threshold_rule_rec.start_period_name := p5_a14;
    ddp_threshold_rule_rec.end_period_name := p5_a15;
    ddp_threshold_rule_rec.threshold_id := p5_a16;
    ddp_threshold_rule_rec.start_date := rosetta_g_miss_date_in_map(p5_a17);
    ddp_threshold_rule_rec.end_date := rosetta_g_miss_date_in_map(p5_a18);
    ddp_threshold_rule_rec.value_limit := p5_a19;
    ddp_threshold_rule_rec.operator_code := p5_a20;
    ddp_threshold_rule_rec.percent_amount := p5_a21;
    ddp_threshold_rule_rec.base_line := p5_a22;
    ddp_threshold_rule_rec.error_mode := p5_a23;
    ddp_threshold_rule_rec.repeat_frequency := p5_a24;
    ddp_threshold_rule_rec.frequency_period := p5_a25;
    ddp_threshold_rule_rec.attribute_category := p5_a26;
    ddp_threshold_rule_rec.attribute1 := p5_a27;
    ddp_threshold_rule_rec.attribute2 := p5_a28;
    ddp_threshold_rule_rec.attribute3 := p5_a29;
    ddp_threshold_rule_rec.attribute4 := p5_a30;
    ddp_threshold_rule_rec.attribute5 := p5_a31;
    ddp_threshold_rule_rec.attribute6 := p5_a32;
    ddp_threshold_rule_rec.attribute7 := p5_a33;
    ddp_threshold_rule_rec.attribute8 := p5_a34;
    ddp_threshold_rule_rec.attribute9 := p5_a35;
    ddp_threshold_rule_rec.attribute10 := p5_a36;
    ddp_threshold_rule_rec.attribute11 := p5_a37;
    ddp_threshold_rule_rec.attribute12 := p5_a38;
    ddp_threshold_rule_rec.attribute13 := p5_a39;
    ddp_threshold_rule_rec.attribute14 := p5_a40;
    ddp_threshold_rule_rec.attribute15 := p5_a41;
    ddp_threshold_rule_rec.org_id := p5_a42;
    ddp_threshold_rule_rec.security_group_id := p5_a43;
    ddp_threshold_rule_rec.converted_days := p5_a44;
    ddp_threshold_rule_rec.object_version_number := p5_a45;
    ddp_threshold_rule_rec.comparison_type := p_comparison_type;
    ddp_threshold_rule_rec.alert_type := p_alert_type;

    -- here's the delegated call to the old PL/SQL routine
    ozf_threshold_rule_pvt.validate_threshold_rule_rec(p_api_version_number,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_threshold_rule_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure complete_threshold_rule_rec(p0_a0  NUMBER
    , p0_a1  DATE
    , p0_a2  NUMBER
    , p0_a3  NUMBER
    , p0_a4  DATE
    , p0_a5  NUMBER
    , p0_a6  VARCHAR2
    , p0_a7  NUMBER
    , p0_a8  NUMBER
    , p0_a9  NUMBER
    , p0_a10  DATE
    , p0_a11  VARCHAR2
    , p0_a12  VARCHAR2
    , p0_a13  VARCHAR2
    , p0_a14  VARCHAR2
    , p0_a15  VARCHAR2
    , p0_a16  NUMBER
    , p0_a17  DATE
    , p0_a18  DATE
    , p0_a19  VARCHAR2
    , p0_a20  VARCHAR2
    , p0_a21  NUMBER
    , p0_a22  VARCHAR2
    , p0_a23  VARCHAR2
    , p0_a24  NUMBER
    , p0_a25  VARCHAR2
    , p0_a26  VARCHAR2
    , p0_a27  VARCHAR2
    , p0_a28  VARCHAR2
    , p0_a29  VARCHAR2
    , p0_a30  VARCHAR2
    , p0_a31  VARCHAR2
    , p0_a32  VARCHAR2
    , p0_a33  VARCHAR2
    , p0_a34  VARCHAR2
    , p0_a35  VARCHAR2
    , p0_a36  VARCHAR2
    , p0_a37  VARCHAR2
    , p0_a38  VARCHAR2
    , p0_a39  VARCHAR2
    , p0_a40  VARCHAR2
    , p0_a41  VARCHAR2
    , p0_a42  NUMBER
    , p0_a43  NUMBER
    , p0_a44  NUMBER
    , p0_a45  NUMBER
    , p1_a0 out nocopy  NUMBER
    , p1_a1 out nocopy  DATE
    , p1_a2 out nocopy  NUMBER
    , p1_a3 out nocopy  NUMBER
    , p1_a4 out nocopy  DATE
    , p1_a5 out nocopy  NUMBER
    , p1_a6 out nocopy  VARCHAR2
    , p1_a7 out nocopy  NUMBER
    , p1_a8 out nocopy  NUMBER
    , p1_a9 out nocopy  NUMBER
    , p1_a10 out nocopy  DATE
    , p1_a11 out nocopy  VARCHAR2
    , p1_a12 out nocopy  VARCHAR2
    , p1_a13 out nocopy  VARCHAR2
    , p1_a14 out nocopy  VARCHAR2
    , p1_a15 out nocopy  VARCHAR2
    , p1_a16 out nocopy  NUMBER
    , p1_a17 out nocopy  DATE
    , p1_a18 out nocopy  DATE
    , p1_a19 out nocopy  VARCHAR2
    , p1_a20 out nocopy  VARCHAR2
    , p1_a21 out nocopy  NUMBER
    , p1_a22 out nocopy  VARCHAR2
    , p1_a23 out nocopy  VARCHAR2
    , p1_a24 out nocopy  NUMBER
    , p1_a25 out nocopy  VARCHAR2
    , p1_a26 out nocopy  VARCHAR2
    , p1_a27 out nocopy  VARCHAR2
    , p1_a28 out nocopy  VARCHAR2
    , p1_a29 out nocopy  VARCHAR2
    , p1_a30 out nocopy  VARCHAR2
    , p1_a31 out nocopy  VARCHAR2
    , p1_a32 out nocopy  VARCHAR2
    , p1_a33 out nocopy  VARCHAR2
    , p1_a34 out nocopy  VARCHAR2
    , p1_a35 out nocopy  VARCHAR2
    , p1_a36 out nocopy  VARCHAR2
    , p1_a37 out nocopy  VARCHAR2
    , p1_a38 out nocopy  VARCHAR2
    , p1_a39 out nocopy  VARCHAR2
    , p1_a40 out nocopy  VARCHAR2
    , p1_a41 out nocopy  VARCHAR2
    , p1_a42 out nocopy  NUMBER
    , p1_a43 out nocopy  NUMBER
    , p1_a44 out nocopy  NUMBER
    , p1_a45 out nocopy  NUMBER
    , p_comparison_type    VARCHAR2
    , p_alert_type    VARCHAR2
  )

  as
    ddp_threshold_rule_rec ozf_threshold_rule_pvt.threshold_rule_rec_type;
    ddx_complete_rec ozf_threshold_rule_pvt.threshold_rule_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_threshold_rule_rec.threshold_rule_id := p0_a0;
    ddp_threshold_rule_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_threshold_rule_rec.last_updated_by := p0_a2;
    ddp_threshold_rule_rec.last_update_login := p0_a3;
    ddp_threshold_rule_rec.creation_date := rosetta_g_miss_date_in_map(p0_a4);
    ddp_threshold_rule_rec.created_by := p0_a5;
    ddp_threshold_rule_rec.created_from := p0_a6;
    ddp_threshold_rule_rec.request_id := p0_a7;
    ddp_threshold_rule_rec.program_application_id := p0_a8;
    ddp_threshold_rule_rec.program_id := p0_a9;
    ddp_threshold_rule_rec.program_update_date := rosetta_g_miss_date_in_map(p0_a10);
    ddp_threshold_rule_rec.period_type := p0_a11;
    ddp_threshold_rule_rec.enabled_flag := p0_a12;
    ddp_threshold_rule_rec.threshold_calendar := p0_a13;
    ddp_threshold_rule_rec.start_period_name := p0_a14;
    ddp_threshold_rule_rec.end_period_name := p0_a15;
    ddp_threshold_rule_rec.threshold_id := p0_a16;
    ddp_threshold_rule_rec.start_date := rosetta_g_miss_date_in_map(p0_a17);
    ddp_threshold_rule_rec.end_date := rosetta_g_miss_date_in_map(p0_a18);
    ddp_threshold_rule_rec.value_limit := p0_a19;
    ddp_threshold_rule_rec.operator_code := p0_a20;
    ddp_threshold_rule_rec.percent_amount := p0_a21;
    ddp_threshold_rule_rec.base_line := p0_a22;
    ddp_threshold_rule_rec.error_mode := p0_a23;
    ddp_threshold_rule_rec.repeat_frequency := p0_a24;
    ddp_threshold_rule_rec.frequency_period := p0_a25;
    ddp_threshold_rule_rec.attribute_category := p0_a26;
    ddp_threshold_rule_rec.attribute1 := p0_a27;
    ddp_threshold_rule_rec.attribute2 := p0_a28;
    ddp_threshold_rule_rec.attribute3 := p0_a29;
    ddp_threshold_rule_rec.attribute4 := p0_a30;
    ddp_threshold_rule_rec.attribute5 := p0_a31;
    ddp_threshold_rule_rec.attribute6 := p0_a32;
    ddp_threshold_rule_rec.attribute7 := p0_a33;
    ddp_threshold_rule_rec.attribute8 := p0_a34;
    ddp_threshold_rule_rec.attribute9 := p0_a35;
    ddp_threshold_rule_rec.attribute10 := p0_a36;
    ddp_threshold_rule_rec.attribute11 := p0_a37;
    ddp_threshold_rule_rec.attribute12 := p0_a38;
    ddp_threshold_rule_rec.attribute13 := p0_a39;
    ddp_threshold_rule_rec.attribute14 := p0_a40;
    ddp_threshold_rule_rec.attribute15 := p0_a41;
    ddp_threshold_rule_rec.org_id := p0_a42;
    ddp_threshold_rule_rec.security_group_id := p0_a43;
    ddp_threshold_rule_rec.converted_days := p0_a44;
    ddp_threshold_rule_rec.object_version_number := p0_a45;
    ddp_threshold_rule_rec.comparison_type := p_comparison_type;
    ddp_threshold_rule_rec.alert_type := p_alert_type;

    -- here's the delegated call to the old PL/SQL routine
    ozf_threshold_rule_pvt.complete_threshold_rule_rec(ddp_threshold_rule_rec,
      ddx_complete_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    p1_a0 := ddx_complete_rec.threshold_rule_id;
    p1_a1 := ddx_complete_rec.last_update_date;
    p1_a2 := ddx_complete_rec.last_updated_by;
    p1_a3 := ddx_complete_rec.last_update_login;
    p1_a4 := ddx_complete_rec.creation_date;
    p1_a5 := ddx_complete_rec.created_by;
    p1_a6 := ddx_complete_rec.created_from;
    p1_a7 := ddx_complete_rec.request_id;
    p1_a8 := ddx_complete_rec.program_application_id;
    p1_a9 := ddx_complete_rec.program_id;
    p1_a10 := ddx_complete_rec.program_update_date;
    p1_a11 := ddx_complete_rec.period_type;
    p1_a12 := ddx_complete_rec.enabled_flag;
    p1_a13 := ddx_complete_rec.threshold_calendar;
    p1_a14 := ddx_complete_rec.start_period_name;
    p1_a15 := ddx_complete_rec.end_period_name;
    p1_a16 := ddx_complete_rec.threshold_id;
    p1_a17 := ddx_complete_rec.start_date;
    p1_a18 := ddx_complete_rec.end_date;
    p1_a19 := ddx_complete_rec.value_limit;
    p1_a20 := ddx_complete_rec.operator_code;
    p1_a21 := ddx_complete_rec.percent_amount;
    p1_a22 := ddx_complete_rec.base_line;
    p1_a23 := ddx_complete_rec.error_mode;
    p1_a24 := ddx_complete_rec.repeat_frequency;
    p1_a25 := ddx_complete_rec.frequency_period;
    p1_a26 := ddx_complete_rec.attribute_category;
    p1_a27 := ddx_complete_rec.attribute1;
    p1_a28 := ddx_complete_rec.attribute2;
    p1_a29 := ddx_complete_rec.attribute3;
    p1_a30 := ddx_complete_rec.attribute4;
    p1_a31 := ddx_complete_rec.attribute5;
    p1_a32 := ddx_complete_rec.attribute6;
    p1_a33 := ddx_complete_rec.attribute7;
    p1_a34 := ddx_complete_rec.attribute8;
    p1_a35 := ddx_complete_rec.attribute9;
    p1_a36 := ddx_complete_rec.attribute10;
    p1_a37 := ddx_complete_rec.attribute11;
    p1_a38 := ddx_complete_rec.attribute12;
    p1_a39 := ddx_complete_rec.attribute13;
    p1_a40 := ddx_complete_rec.attribute14;
    p1_a41 := ddx_complete_rec.attribute15;
    p1_a42 := ddx_complete_rec.org_id;
    p1_a43 := ddx_complete_rec.security_group_id;
    p1_a44 := ddx_complete_rec.converted_days;
    p1_a45 := ddx_complete_rec.object_version_number;
  end;

end ozf_threshold_rule_pvt_w;

/
