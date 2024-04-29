--------------------------------------------------------
--  DDL for Package Body CN_REASONS_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_REASONS_PUB_W" as
  /* $Header: cnwresnb.pls 115.3 2003/07/04 01:44:16 jjhuang ship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure rosetta_table_copy_in_p2(t out nocopy cn_reasons_pub.notes_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_4000
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_VARCHAR2_TABLE_100
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_VARCHAR2_TABLE_100
    , a25 JTF_VARCHAR2_TABLE_100
    , a26 JTF_DATE_TABLE
    , a27 JTF_NUMBER_TABLE
    , a28 JTF_VARCHAR2_TABLE_100
    , a29 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).reason_history_id := a0(indx);
          t(ddindx).reason_id := a1(indx);
          t(ddindx).updated_table := a2(indx);
          t(ddindx).upd_table_id := a3(indx);
          t(ddindx).reason := a4(indx);
          t(ddindx).reason_code := a5(indx);
          t(ddindx).reason_meaning := a6(indx);
          t(ddindx).lookup_type := a7(indx);
          t(ddindx).update_flag := a8(indx);
          t(ddindx).dml_flag := a9(indx);
          t(ddindx).attribute_category := a10(indx);
          t(ddindx).attribute1 := a11(indx);
          t(ddindx).attribute2 := a12(indx);
          t(ddindx).attribute3 := a13(indx);
          t(ddindx).attribute4 := a14(indx);
          t(ddindx).attribute5 := a15(indx);
          t(ddindx).attribute6 := a16(indx);
          t(ddindx).attribute7 := a17(indx);
          t(ddindx).attribute8 := a18(indx);
          t(ddindx).attribute9 := a19(indx);
          t(ddindx).attribute10 := a20(indx);
          t(ddindx).attribute11 := a21(indx);
          t(ddindx).attribute12 := a22(indx);
          t(ddindx).attribute13 := a23(indx);
          t(ddindx).attribute14 := a24(indx);
          t(ddindx).attribute15 := a25(indx);
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a26(indx));
          t(ddindx).last_updated_by := a27(indx);
          t(ddindx).last_updated_username := a28(indx);
          t(ddindx).object_version_number := a29(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t cn_reasons_pub.notes_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_4000
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    , a23 out nocopy JTF_VARCHAR2_TABLE_100
    , a24 out nocopy JTF_VARCHAR2_TABLE_100
    , a25 out nocopy JTF_VARCHAR2_TABLE_100
    , a26 out nocopy JTF_DATE_TABLE
    , a27 out nocopy JTF_NUMBER_TABLE
    , a28 out nocopy JTF_VARCHAR2_TABLE_100
    , a29 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_4000();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_VARCHAR2_TABLE_100();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_VARCHAR2_TABLE_100();
    a20 := JTF_VARCHAR2_TABLE_100();
    a21 := JTF_VARCHAR2_TABLE_100();
    a22 := JTF_VARCHAR2_TABLE_100();
    a23 := JTF_VARCHAR2_TABLE_100();
    a24 := JTF_VARCHAR2_TABLE_100();
    a25 := JTF_VARCHAR2_TABLE_100();
    a26 := JTF_DATE_TABLE();
    a27 := JTF_NUMBER_TABLE();
    a28 := JTF_VARCHAR2_TABLE_100();
    a29 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_4000();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_VARCHAR2_TABLE_100();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_VARCHAR2_TABLE_100();
      a20 := JTF_VARCHAR2_TABLE_100();
      a21 := JTF_VARCHAR2_TABLE_100();
      a22 := JTF_VARCHAR2_TABLE_100();
      a23 := JTF_VARCHAR2_TABLE_100();
      a24 := JTF_VARCHAR2_TABLE_100();
      a25 := JTF_VARCHAR2_TABLE_100();
      a26 := JTF_DATE_TABLE();
      a27 := JTF_NUMBER_TABLE();
      a28 := JTF_VARCHAR2_TABLE_100();
      a29 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).reason_history_id;
          a1(indx) := t(ddindx).reason_id;
          a2(indx) := t(ddindx).updated_table;
          a3(indx) := t(ddindx).upd_table_id;
          a4(indx) := t(ddindx).reason;
          a5(indx) := t(ddindx).reason_code;
          a6(indx) := t(ddindx).reason_meaning;
          a7(indx) := t(ddindx).lookup_type;
          a8(indx) := t(ddindx).update_flag;
          a9(indx) := t(ddindx).dml_flag;
          a10(indx) := t(ddindx).attribute_category;
          a11(indx) := t(ddindx).attribute1;
          a12(indx) := t(ddindx).attribute2;
          a13(indx) := t(ddindx).attribute3;
          a14(indx) := t(ddindx).attribute4;
          a15(indx) := t(ddindx).attribute5;
          a16(indx) := t(ddindx).attribute6;
          a17(indx) := t(ddindx).attribute7;
          a18(indx) := t(ddindx).attribute8;
          a19(indx) := t(ddindx).attribute9;
          a20(indx) := t(ddindx).attribute10;
          a21(indx) := t(ddindx).attribute11;
          a22(indx) := t(ddindx).attribute12;
          a23(indx) := t(ddindx).attribute13;
          a24(indx) := t(ddindx).attribute14;
          a25(indx) := t(ddindx).attribute15;
          a26(indx) := t(ddindx).last_update_date;
          a27(indx) := t(ddindx).last_updated_by;
          a28(indx) := t(ddindx).last_updated_username;
          a29(indx) := t(ddindx).object_version_number;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure show_analyst_notes(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  VARCHAR2
    , p_commit  VARCHAR2
    , p_first  NUMBER
    , p_last  NUMBER
    , p_payment_worksheet_id  NUMBER
    , p_table_name  VARCHAR2
    , p_lookup_type  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_loading_status out nocopy  VARCHAR2
    , p13_a0 out nocopy  NUMBER
    , p13_a1 out nocopy  NUMBER
    , p13_a2 out nocopy  VARCHAR2
    , p13_a3 out nocopy  VARCHAR2
    , p13_a4 out nocopy  NUMBER
    , p13_a5 out nocopy  NUMBER
    , p13_a6 out nocopy  VARCHAR2
    , p13_a7 out nocopy  VARCHAR2
    , p13_a8 out nocopy  NUMBER
    , p13_a9 out nocopy  NUMBER
    , p13_a10 out nocopy  VARCHAR2
    , p13_a11 out nocopy  VARCHAR2
    , p13_a12 out nocopy  NUMBER
    , p13_a13 out nocopy  VARCHAR2
    , p14_a0 out nocopy JTF_NUMBER_TABLE
    , p14_a1 out nocopy JTF_NUMBER_TABLE
    , p14_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a3 out nocopy JTF_NUMBER_TABLE
    , p14_a4 out nocopy JTF_VARCHAR2_TABLE_4000
    , p14_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a24 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a25 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a26 out nocopy JTF_DATE_TABLE
    , p14_a27 out nocopy JTF_NUMBER_TABLE
    , p14_a28 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a29 out nocopy JTF_NUMBER_TABLE
    , x_notes_count out nocopy  NUMBER
  )

  as
    ddx_worksheet_rec cn_reasons_pub.worksheet_rec;
    ddx_notes_tbl cn_reasons_pub.notes_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
















    -- here's the delegated call to the old PL/SQL routine
    cn_reasons_pub.show_analyst_notes(p_api_version,
      p_init_msg_list,
      p_validation_level,
      p_commit,
      p_first,
      p_last,
      p_payment_worksheet_id,
      p_table_name,
      p_lookup_type,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_loading_status,
      ddx_worksheet_rec,
      ddx_notes_tbl,
      x_notes_count);

    -- copy data back from the local variables to OUT or IN-OUT args, if any













    p13_a0 := ddx_worksheet_rec.payment_worksheet_id;
    p13_a1 := ddx_worksheet_rec.role_id;
    p13_a2 := ddx_worksheet_rec.worksheet_status;
    p13_a3 := ddx_worksheet_rec.payrun_name;
    p13_a4 := ddx_worksheet_rec.payrun_id;
    p13_a5 := ddx_worksheet_rec.pay_period_id;
    p13_a6 := ddx_worksheet_rec.payrun_status;
    p13_a7 := ddx_worksheet_rec.period_name;
    p13_a8 := ddx_worksheet_rec.salesrep_id;
    p13_a9 := ddx_worksheet_rec.resource_id;
    p13_a10 := ddx_worksheet_rec.salesrep_name;
    p13_a11 := ddx_worksheet_rec.employee_number;
    p13_a12 := ddx_worksheet_rec.pay_group_id;
    p13_a13 := ddx_worksheet_rec.pay_group_name;

    cn_reasons_pub_w.rosetta_table_copy_out_p2(ddx_notes_tbl, p14_a0
      , p14_a1
      , p14_a2
      , p14_a3
      , p14_a4
      , p14_a5
      , p14_a6
      , p14_a7
      , p14_a8
      , p14_a9
      , p14_a10
      , p14_a11
      , p14_a12
      , p14_a13
      , p14_a14
      , p14_a15
      , p14_a16
      , p14_a17
      , p14_a18
      , p14_a19
      , p14_a20
      , p14_a21
      , p14_a22
      , p14_a23
      , p14_a24
      , p14_a25
      , p14_a26
      , p14_a27
      , p14_a28
      , p14_a29
      );

  end;

  procedure manage_analyst_notes(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  VARCHAR2
    , p_commit  VARCHAR2
    , p4_a0 JTF_NUMBER_TABLE
    , p4_a1 JTF_NUMBER_TABLE
    , p4_a2 JTF_VARCHAR2_TABLE_100
    , p4_a3 JTF_NUMBER_TABLE
    , p4_a4 JTF_VARCHAR2_TABLE_4000
    , p4_a5 JTF_VARCHAR2_TABLE_100
    , p4_a6 JTF_VARCHAR2_TABLE_100
    , p4_a7 JTF_VARCHAR2_TABLE_100
    , p4_a8 JTF_VARCHAR2_TABLE_100
    , p4_a9 JTF_VARCHAR2_TABLE_100
    , p4_a10 JTF_VARCHAR2_TABLE_100
    , p4_a11 JTF_VARCHAR2_TABLE_100
    , p4_a12 JTF_VARCHAR2_TABLE_100
    , p4_a13 JTF_VARCHAR2_TABLE_100
    , p4_a14 JTF_VARCHAR2_TABLE_100
    , p4_a15 JTF_VARCHAR2_TABLE_100
    , p4_a16 JTF_VARCHAR2_TABLE_100
    , p4_a17 JTF_VARCHAR2_TABLE_100
    , p4_a18 JTF_VARCHAR2_TABLE_100
    , p4_a19 JTF_VARCHAR2_TABLE_100
    , p4_a20 JTF_VARCHAR2_TABLE_100
    , p4_a21 JTF_VARCHAR2_TABLE_100
    , p4_a22 JTF_VARCHAR2_TABLE_100
    , p4_a23 JTF_VARCHAR2_TABLE_100
    , p4_a24 JTF_VARCHAR2_TABLE_100
    , p4_a25 JTF_VARCHAR2_TABLE_100
    , p4_a26 JTF_DATE_TABLE
    , p4_a27 JTF_NUMBER_TABLE
    , p4_a28 JTF_VARCHAR2_TABLE_100
    , p4_a29 JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_loading_status out nocopy  VARCHAR2
  )

  as
    ddp_notes_tbl cn_reasons_pub.notes_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    cn_reasons_pub_w.rosetta_table_copy_in_p2(ddp_notes_tbl, p4_a0
      , p4_a1
      , p4_a2
      , p4_a3
      , p4_a4
      , p4_a5
      , p4_a6
      , p4_a7
      , p4_a8
      , p4_a9
      , p4_a10
      , p4_a11
      , p4_a12
      , p4_a13
      , p4_a14
      , p4_a15
      , p4_a16
      , p4_a17
      , p4_a18
      , p4_a19
      , p4_a20
      , p4_a21
      , p4_a22
      , p4_a23
      , p4_a24
      , p4_a25
      , p4_a26
      , p4_a27
      , p4_a28
      , p4_a29
      );





    -- here's the delegated call to the old PL/SQL routine
    cn_reasons_pub.manage_analyst_notes(p_api_version,
      p_init_msg_list,
      p_validation_level,
      p_commit,
      ddp_notes_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_loading_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure show_last_analyst_note(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  VARCHAR2
    , p_commit  VARCHAR2
    , p_payment_worksheet_id  NUMBER
    , p_table_name  VARCHAR2
    , p_lookup_type  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_loading_status out nocopy  VARCHAR2
    , p11_a0 out nocopy JTF_NUMBER_TABLE
    , p11_a1 out nocopy JTF_NUMBER_TABLE
    , p11_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a3 out nocopy JTF_NUMBER_TABLE
    , p11_a4 out nocopy JTF_VARCHAR2_TABLE_4000
    , p11_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a24 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a25 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a26 out nocopy JTF_DATE_TABLE
    , p11_a27 out nocopy JTF_NUMBER_TABLE
    , p11_a28 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a29 out nocopy JTF_NUMBER_TABLE
    , x_notes_count out nocopy  NUMBER
  )

  as
    ddx_notes_tbl cn_reasons_pub.notes_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any













    -- here's the delegated call to the old PL/SQL routine
    cn_reasons_pub.show_last_analyst_note(p_api_version,
      p_init_msg_list,
      p_validation_level,
      p_commit,
      p_payment_worksheet_id,
      p_table_name,
      p_lookup_type,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_loading_status,
      ddx_notes_tbl,
      x_notes_count);

    -- copy data back from the local variables to OUT or IN-OUT args, if any











    cn_reasons_pub_w.rosetta_table_copy_out_p2(ddx_notes_tbl, p11_a0
      , p11_a1
      , p11_a2
      , p11_a3
      , p11_a4
      , p11_a5
      , p11_a6
      , p11_a7
      , p11_a8
      , p11_a9
      , p11_a10
      , p11_a11
      , p11_a12
      , p11_a13
      , p11_a14
      , p11_a15
      , p11_a16
      , p11_a17
      , p11_a18
      , p11_a19
      , p11_a20
      , p11_a21
      , p11_a22
      , p11_a23
      , p11_a24
      , p11_a25
      , p11_a26
      , p11_a27
      , p11_a28
      , p11_a29
      );

  end;

end cn_reasons_pub_w;

/
