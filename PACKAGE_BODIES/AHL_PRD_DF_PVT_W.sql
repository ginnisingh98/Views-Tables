--------------------------------------------------------
--  DDL for Package Body AHL_PRD_DF_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_PRD_DF_PVT_W" as
  /* $Header: AHLWPDFB.pls 120.1.12010000.2 2010/03/26 12:18:20 psalgia ship $ */
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

  procedure rosetta_table_copy_in_p15(t out nocopy ahl_prd_df_pvt.df_schedules_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_DATE_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_DATE_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_VARCHAR2_TABLE_200
    , a16 JTF_VARCHAR2_TABLE_200
    , a17 JTF_VARCHAR2_TABLE_200
    , a18 JTF_VARCHAR2_TABLE_200
    , a19 JTF_VARCHAR2_TABLE_200
    , a20 JTF_VARCHAR2_TABLE_200
    , a21 JTF_VARCHAR2_TABLE_200
    , a22 JTF_VARCHAR2_TABLE_200
    , a23 JTF_VARCHAR2_TABLE_200
    , a24 JTF_VARCHAR2_TABLE_200
    , a25 JTF_VARCHAR2_TABLE_200
    , a26 JTF_VARCHAR2_TABLE_200
    , a27 JTF_VARCHAR2_TABLE_200
    , a28 JTF_VARCHAR2_TABLE_200
    , a29 JTF_VARCHAR2_TABLE_200
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).unit_threshold_id := a0(indx);
          t(ddindx).object_version_number := a1(indx);
          t(ddindx).created_by := a2(indx);
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a3(indx));
          t(ddindx).last_updated_by := a4(indx);
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a5(indx));
          t(ddindx).last_update_login := a6(indx);
          t(ddindx).unit_deferral_id := a7(indx);
          t(ddindx).counter_id := a8(indx);
          t(ddindx).counter_name := a9(indx);
          t(ddindx).counter_value := a10(indx);
          t(ddindx).ctr_value_type_code := a11(indx);
          t(ddindx).unit_of_measure := a12(indx);
          t(ddindx).operation_flag := a13(indx);
          t(ddindx).attribute_category := a14(indx);
          t(ddindx).attribute1 := a15(indx);
          t(ddindx).attribute2 := a16(indx);
          t(ddindx).attribute3 := a17(indx);
          t(ddindx).attribute4 := a18(indx);
          t(ddindx).attribute5 := a19(indx);
          t(ddindx).attribute6 := a20(indx);
          t(ddindx).attribute7 := a21(indx);
          t(ddindx).attribute8 := a22(indx);
          t(ddindx).attribute9 := a23(indx);
          t(ddindx).attribute10 := a24(indx);
          t(ddindx).attribute11 := a25(indx);
          t(ddindx).attribute12 := a26(indx);
          t(ddindx).attribute13 := a27(indx);
          t(ddindx).attribute14 := a28(indx);
          t(ddindx).attribute15 := a29(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p15;
  procedure rosetta_table_copy_out_p15(t ahl_prd_df_pvt.df_schedules_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_VARCHAR2_TABLE_200
    , a16 out nocopy JTF_VARCHAR2_TABLE_200
    , a17 out nocopy JTF_VARCHAR2_TABLE_200
    , a18 out nocopy JTF_VARCHAR2_TABLE_200
    , a19 out nocopy JTF_VARCHAR2_TABLE_200
    , a20 out nocopy JTF_VARCHAR2_TABLE_200
    , a21 out nocopy JTF_VARCHAR2_TABLE_200
    , a22 out nocopy JTF_VARCHAR2_TABLE_200
    , a23 out nocopy JTF_VARCHAR2_TABLE_200
    , a24 out nocopy JTF_VARCHAR2_TABLE_200
    , a25 out nocopy JTF_VARCHAR2_TABLE_200
    , a26 out nocopy JTF_VARCHAR2_TABLE_200
    , a27 out nocopy JTF_VARCHAR2_TABLE_200
    , a28 out nocopy JTF_VARCHAR2_TABLE_200
    , a29 out nocopy JTF_VARCHAR2_TABLE_200
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_DATE_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_DATE_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_VARCHAR2_TABLE_200();
    a16 := JTF_VARCHAR2_TABLE_200();
    a17 := JTF_VARCHAR2_TABLE_200();
    a18 := JTF_VARCHAR2_TABLE_200();
    a19 := JTF_VARCHAR2_TABLE_200();
    a20 := JTF_VARCHAR2_TABLE_200();
    a21 := JTF_VARCHAR2_TABLE_200();
    a22 := JTF_VARCHAR2_TABLE_200();
    a23 := JTF_VARCHAR2_TABLE_200();
    a24 := JTF_VARCHAR2_TABLE_200();
    a25 := JTF_VARCHAR2_TABLE_200();
    a26 := JTF_VARCHAR2_TABLE_200();
    a27 := JTF_VARCHAR2_TABLE_200();
    a28 := JTF_VARCHAR2_TABLE_200();
    a29 := JTF_VARCHAR2_TABLE_200();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_DATE_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_DATE_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_VARCHAR2_TABLE_200();
      a16 := JTF_VARCHAR2_TABLE_200();
      a17 := JTF_VARCHAR2_TABLE_200();
      a18 := JTF_VARCHAR2_TABLE_200();
      a19 := JTF_VARCHAR2_TABLE_200();
      a20 := JTF_VARCHAR2_TABLE_200();
      a21 := JTF_VARCHAR2_TABLE_200();
      a22 := JTF_VARCHAR2_TABLE_200();
      a23 := JTF_VARCHAR2_TABLE_200();
      a24 := JTF_VARCHAR2_TABLE_200();
      a25 := JTF_VARCHAR2_TABLE_200();
      a26 := JTF_VARCHAR2_TABLE_200();
      a27 := JTF_VARCHAR2_TABLE_200();
      a28 := JTF_VARCHAR2_TABLE_200();
      a29 := JTF_VARCHAR2_TABLE_200();
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
          a0(indx) := t(ddindx).unit_threshold_id;
          a1(indx) := t(ddindx).object_version_number;
          a2(indx) := t(ddindx).created_by;
          a3(indx) := t(ddindx).creation_date;
          a4(indx) := t(ddindx).last_updated_by;
          a5(indx) := t(ddindx).last_update_date;
          a6(indx) := t(ddindx).last_update_login;
          a7(indx) := t(ddindx).unit_deferral_id;
          a8(indx) := t(ddindx).counter_id;
          a9(indx) := t(ddindx).counter_name;
          a10(indx) := t(ddindx).counter_value;
          a11(indx) := t(ddindx).ctr_value_type_code;
          a12(indx) := t(ddindx).unit_of_measure;
          a13(indx) := t(ddindx).operation_flag;
          a14(indx) := t(ddindx).attribute_category;
          a15(indx) := t(ddindx).attribute1;
          a16(indx) := t(ddindx).attribute2;
          a17(indx) := t(ddindx).attribute3;
          a18(indx) := t(ddindx).attribute4;
          a19(indx) := t(ddindx).attribute5;
          a20(indx) := t(ddindx).attribute6;
          a21(indx) := t(ddindx).attribute7;
          a22(indx) := t(ddindx).attribute8;
          a23(indx) := t(ddindx).attribute9;
          a24(indx) := t(ddindx).attribute10;
          a25(indx) := t(ddindx).attribute11;
          a26(indx) := t(ddindx).attribute12;
          a27(indx) := t(ddindx).attribute13;
          a28(indx) := t(ddindx).attribute14;
          a29(indx) := t(ddindx).attribute15;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p15;

  procedure process_deferral(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , p5_a0 in out nocopy  NUMBER
    , p5_a1 in out nocopy  NUMBER
    , p5_a2 in out nocopy  NUMBER
    , p5_a3 in out nocopy  DATE
    , p5_a4 in out nocopy  NUMBER
    , p5_a5 in out nocopy  DATE
    , p5_a6 in out nocopy  NUMBER
    , p5_a7 in out nocopy  NUMBER
    , p5_a8 in out nocopy  VARCHAR2
    , p5_a9 in out nocopy  VARCHAR2
    , p5_a10 in out nocopy  VARCHAR2
    , p5_a11 in out nocopy  VARCHAR2
    , p5_a12 in out nocopy  VARCHAR2
    , p5_a13 in out nocopy  VARCHAR2
    , p5_a14 in out nocopy  VARCHAR2
    , p5_a15 in out nocopy  DATE
    , p5_a16 in out nocopy  DATE
    , p5_a17 in out nocopy  VARCHAR2
    , p5_a18 in out nocopy  VARCHAR2
    , p5_a19 in out nocopy  VARCHAR2
    , p5_a20 in out nocopy  VARCHAR2
    , p5_a21 in out nocopy  VARCHAR2
    , p5_a22 in out nocopy  VARCHAR2
    , p5_a23 in out nocopy  VARCHAR2
    , p5_a24 in out nocopy  VARCHAR2
    , p5_a25 in out nocopy  VARCHAR2
    , p5_a26 in out nocopy  VARCHAR2
    , p5_a27 in out nocopy  VARCHAR2
    , p5_a28 in out nocopy  VARCHAR2
    , p5_a29 in out nocopy  VARCHAR2
    , p5_a30 in out nocopy  VARCHAR2
    , p5_a31 in out nocopy  VARCHAR2
    , p5_a32 in out nocopy  VARCHAR2
    , p5_a33 in out nocopy  VARCHAR2
    , p5_a34 in out nocopy  VARCHAR2
    , p5_a35 in out nocopy  VARCHAR2
    , p5_a36 in out nocopy  VARCHAR2
    , p5_a37 in out nocopy  VARCHAR2
    , p5_a38 in out nocopy  VARCHAR2
    , p6_a0 in out nocopy JTF_NUMBER_TABLE
    , p6_a1 in out nocopy JTF_NUMBER_TABLE
    , p6_a2 in out nocopy JTF_NUMBER_TABLE
    , p6_a3 in out nocopy JTF_DATE_TABLE
    , p6_a4 in out nocopy JTF_NUMBER_TABLE
    , p6_a5 in out nocopy JTF_DATE_TABLE
    , p6_a6 in out nocopy JTF_NUMBER_TABLE
    , p6_a7 in out nocopy JTF_NUMBER_TABLE
    , p6_a8 in out nocopy JTF_NUMBER_TABLE
    , p6_a9 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a10 in out nocopy JTF_NUMBER_TABLE
    , p6_a11 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a12 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a13 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a14 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a15 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a16 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a17 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a18 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a19 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a20 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a21 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a22 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a23 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a24 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a25 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a26 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a27 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a28 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a29 in out nocopy JTF_VARCHAR2_TABLE_200
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_x_df_header_rec ahl_prd_df_pvt.df_header_rec_type;
    ddp_x_df_schedules_tbl ahl_prd_df_pvt.df_schedules_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_x_df_header_rec.unit_deferral_id := p5_a0;
    ddp_x_df_header_rec.object_version_number := p5_a1;
    ddp_x_df_header_rec.created_by := p5_a2;
    ddp_x_df_header_rec.creation_date := rosetta_g_miss_date_in_map(p5_a3);
    ddp_x_df_header_rec.last_updated_by := p5_a4;
    ddp_x_df_header_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a5);
    ddp_x_df_header_rec.last_update_login := p5_a6;
    ddp_x_df_header_rec.unit_effectivity_id := p5_a7;
    ddp_x_df_header_rec.unit_deferral_type := p5_a8;
    ddp_x_df_header_rec.approval_status_code := p5_a9;
    ddp_x_df_header_rec.defer_reason_code := p5_a10;
    ddp_x_df_header_rec.remarks := p5_a11;
    ddp_x_df_header_rec.approver_notes := p5_a12;
    ddp_x_df_header_rec.skip_mr_flag := p5_a13;
    ddp_x_df_header_rec.affect_due_calc_flag := p5_a14;
    ddp_x_df_header_rec.set_due_date := rosetta_g_miss_date_in_map(p5_a15);
    ddp_x_df_header_rec.deferral_effective_on := rosetta_g_miss_date_in_map(p5_a16);
    ddp_x_df_header_rec.deferral_type := p5_a17;
    ddp_x_df_header_rec.mr_repetitive_flag := p5_a18;
    ddp_x_df_header_rec.manually_planned_flag := p5_a19;
    ddp_x_df_header_rec.reset_counter_flag := p5_a20;
    ddp_x_df_header_rec.operation_flag := p5_a21;
    ddp_x_df_header_rec.attribute_category := p5_a22;
    ddp_x_df_header_rec.attribute1 := p5_a23;
    ddp_x_df_header_rec.attribute2 := p5_a24;
    ddp_x_df_header_rec.attribute3 := p5_a25;
    ddp_x_df_header_rec.attribute4 := p5_a26;
    ddp_x_df_header_rec.attribute5 := p5_a27;
    ddp_x_df_header_rec.attribute6 := p5_a28;
    ddp_x_df_header_rec.attribute7 := p5_a29;
    ddp_x_df_header_rec.attribute8 := p5_a30;
    ddp_x_df_header_rec.attribute9 := p5_a31;
    ddp_x_df_header_rec.attribute10 := p5_a32;
    ddp_x_df_header_rec.attribute11 := p5_a33;
    ddp_x_df_header_rec.attribute12 := p5_a34;
    ddp_x_df_header_rec.attribute13 := p5_a35;
    ddp_x_df_header_rec.attribute14 := p5_a36;
    ddp_x_df_header_rec.attribute15 := p5_a37;
    ddp_x_df_header_rec.user_deferral_type_code := p5_a38;

    ahl_prd_df_pvt_w.rosetta_table_copy_in_p15(ddp_x_df_schedules_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      , p6_a5
      , p6_a6
      , p6_a7
      , p6_a8
      , p6_a9
      , p6_a10
      , p6_a11
      , p6_a12
      , p6_a13
      , p6_a14
      , p6_a15
      , p6_a16
      , p6_a17
      , p6_a18
      , p6_a19
      , p6_a20
      , p6_a21
      , p6_a22
      , p6_a23
      , p6_a24
      , p6_a25
      , p6_a26
      , p6_a27
      , p6_a28
      , p6_a29
      );




    -- here's the delegated call to the old PL/SQL routine
    ahl_prd_df_pvt.process_deferral(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_module_type,
      ddp_x_df_header_rec,
      ddp_x_df_schedules_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    p5_a0 := ddp_x_df_header_rec.unit_deferral_id;
    p5_a1 := ddp_x_df_header_rec.object_version_number;
    p5_a2 := ddp_x_df_header_rec.created_by;
    p5_a3 := ddp_x_df_header_rec.creation_date;
    p5_a4 := ddp_x_df_header_rec.last_updated_by;
    p5_a5 := ddp_x_df_header_rec.last_update_date;
    p5_a6 := ddp_x_df_header_rec.last_update_login;
    p5_a7 := ddp_x_df_header_rec.unit_effectivity_id;
    p5_a8 := ddp_x_df_header_rec.unit_deferral_type;
    p5_a9 := ddp_x_df_header_rec.approval_status_code;
    p5_a10 := ddp_x_df_header_rec.defer_reason_code;
    p5_a11 := ddp_x_df_header_rec.remarks;
    p5_a12 := ddp_x_df_header_rec.approver_notes;
    p5_a13 := ddp_x_df_header_rec.skip_mr_flag;
    p5_a14 := ddp_x_df_header_rec.affect_due_calc_flag;
    p5_a15 := ddp_x_df_header_rec.set_due_date;
    p5_a16 := ddp_x_df_header_rec.deferral_effective_on;
    p5_a17 := ddp_x_df_header_rec.deferral_type;
    p5_a18 := ddp_x_df_header_rec.mr_repetitive_flag;
    p5_a19 := ddp_x_df_header_rec.manually_planned_flag;
    p5_a20 := ddp_x_df_header_rec.reset_counter_flag;
    p5_a21 := ddp_x_df_header_rec.operation_flag;
    p5_a22 := ddp_x_df_header_rec.attribute_category;
    p5_a23 := ddp_x_df_header_rec.attribute1;
    p5_a24 := ddp_x_df_header_rec.attribute2;
    p5_a25 := ddp_x_df_header_rec.attribute3;
    p5_a26 := ddp_x_df_header_rec.attribute4;
    p5_a27 := ddp_x_df_header_rec.attribute5;
    p5_a28 := ddp_x_df_header_rec.attribute6;
    p5_a29 := ddp_x_df_header_rec.attribute7;
    p5_a30 := ddp_x_df_header_rec.attribute8;
    p5_a31 := ddp_x_df_header_rec.attribute9;
    p5_a32 := ddp_x_df_header_rec.attribute10;
    p5_a33 := ddp_x_df_header_rec.attribute11;
    p5_a34 := ddp_x_df_header_rec.attribute12;
    p5_a35 := ddp_x_df_header_rec.attribute13;
    p5_a36 := ddp_x_df_header_rec.attribute14;
    p5_a37 := ddp_x_df_header_rec.attribute15;
    p5_a38 := ddp_x_df_header_rec.user_deferral_type_code;

    ahl_prd_df_pvt_w.rosetta_table_copy_out_p15(ddp_x_df_schedules_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      , p6_a5
      , p6_a6
      , p6_a7
      , p6_a8
      , p6_a9
      , p6_a10
      , p6_a11
      , p6_a12
      , p6_a13
      , p6_a14
      , p6_a15
      , p6_a16
      , p6_a17
      , p6_a18
      , p6_a19
      , p6_a20
      , p6_a21
      , p6_a22
      , p6_a23
      , p6_a24
      , p6_a25
      , p6_a26
      , p6_a27
      , p6_a28
      , p6_a29
      );



  end;

  procedure get_deferral_details(p_init_msg_list  VARCHAR2
    , p_unit_effectivity_id  NUMBER
    , p2_a0 out nocopy  NUMBER
    , p2_a1 out nocopy  NUMBER
    , p2_a2 out nocopy  NUMBER
    , p2_a3 out nocopy  VARCHAR2
    , p2_a4 out nocopy  VARCHAR2
    , p2_a5 out nocopy  VARCHAR2
    , p2_a6 out nocopy  VARCHAR2
    , p2_a7 out nocopy  VARCHAR2
    , p2_a8 out nocopy  VARCHAR2
    , p2_a9 out nocopy  VARCHAR2
    , p2_a10 out nocopy  DATE
    , p2_a11 out nocopy  DATE
    , p2_a12 out nocopy  VARCHAR2
    , p2_a13 out nocopy  NUMBER
    , p2_a14 out nocopy  VARCHAR2
    , p2_a15 out nocopy  VARCHAR2
    , p2_a16 out nocopy  NUMBER
    , p2_a17 out nocopy  VARCHAR2
    , p2_a18 out nocopy  VARCHAR2
    , p2_a19 out nocopy  DATE
    , p2_a20 out nocopy  VARCHAR2
    , p2_a21 out nocopy  VARCHAR2
    , p2_a22 out nocopy  NUMBER
    , p2_a23 out nocopy  NUMBER
    , p2_a24 out nocopy  VARCHAR2
    , p2_a25 out nocopy  VARCHAR2
    , p2_a26 out nocopy  VARCHAR2
    , p2_a27 out nocopy  VARCHAR2
    , p2_a28 out nocopy  VARCHAR2
    , p2_a29 out nocopy  VARCHAR2
    , p2_a30 out nocopy  VARCHAR2
    , p2_a31 out nocopy  VARCHAR2
    , p2_a32 out nocopy  VARCHAR2
    , p2_a33 out nocopy  VARCHAR2
    , p2_a34 out nocopy  VARCHAR2
    , p2_a35 out nocopy  VARCHAR2
    , p2_a36 out nocopy  VARCHAR2
    , p2_a37 out nocopy  VARCHAR2
    , p2_a38 out nocopy  VARCHAR2
    , p2_a39 out nocopy  VARCHAR2
    , p2_a40 out nocopy  VARCHAR2
    , p2_a41 out nocopy  VARCHAR2
    , p2_a42 out nocopy  VARCHAR2
    , p2_a43 out nocopy  VARCHAR2
    , p2_a44 out nocopy  VARCHAR2
    , p3_a0 out nocopy JTF_NUMBER_TABLE
    , p3_a1 out nocopy JTF_NUMBER_TABLE
    , p3_a2 out nocopy JTF_NUMBER_TABLE
    , p3_a3 out nocopy JTF_DATE_TABLE
    , p3_a4 out nocopy JTF_NUMBER_TABLE
    , p3_a5 out nocopy JTF_DATE_TABLE
    , p3_a6 out nocopy JTF_NUMBER_TABLE
    , p3_a7 out nocopy JTF_NUMBER_TABLE
    , p3_a8 out nocopy JTF_NUMBER_TABLE
    , p3_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a10 out nocopy JTF_NUMBER_TABLE
    , p3_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a15 out nocopy JTF_VARCHAR2_TABLE_200
    , p3_a16 out nocopy JTF_VARCHAR2_TABLE_200
    , p3_a17 out nocopy JTF_VARCHAR2_TABLE_200
    , p3_a18 out nocopy JTF_VARCHAR2_TABLE_200
    , p3_a19 out nocopy JTF_VARCHAR2_TABLE_200
    , p3_a20 out nocopy JTF_VARCHAR2_TABLE_200
    , p3_a21 out nocopy JTF_VARCHAR2_TABLE_200
    , p3_a22 out nocopy JTF_VARCHAR2_TABLE_200
    , p3_a23 out nocopy JTF_VARCHAR2_TABLE_200
    , p3_a24 out nocopy JTF_VARCHAR2_TABLE_200
    , p3_a25 out nocopy JTF_VARCHAR2_TABLE_200
    , p3_a26 out nocopy JTF_VARCHAR2_TABLE_200
    , p3_a27 out nocopy JTF_VARCHAR2_TABLE_200
    , p3_a28 out nocopy JTF_VARCHAR2_TABLE_200
    , p3_a29 out nocopy JTF_VARCHAR2_TABLE_200
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddx_df_header_info_rec ahl_prd_df_pvt.df_header_info_rec_type;
    ddx_df_schedules_tbl ahl_prd_df_pvt.df_schedules_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    -- here's the delegated call to the old PL/SQL routine
    ahl_prd_df_pvt.get_deferral_details(p_init_msg_list,
      p_unit_effectivity_id,
      ddx_df_header_info_rec,
      ddx_df_schedules_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


    p2_a0 := ddx_df_header_info_rec.unit_deferral_id;
    p2_a1 := ddx_df_header_info_rec.object_version_number;
    p2_a2 := ddx_df_header_info_rec.unit_effectivity_id;
    p2_a3 := ddx_df_header_info_rec.approval_status_code;
    p2_a4 := ddx_df_header_info_rec.approval_status_meaning;
    p2_a5 := ddx_df_header_info_rec.defer_reason_code;
    p2_a6 := ddx_df_header_info_rec.remarks;
    p2_a7 := ddx_df_header_info_rec.approver_notes;
    p2_a8 := ddx_df_header_info_rec.skip_mr_flag;
    p2_a9 := ddx_df_header_info_rec.affect_due_calc_flag;
    p2_a10 := ddx_df_header_info_rec.set_due_date;
    p2_a11 := ddx_df_header_info_rec.deferral_effective_on;
    p2_a12 := ddx_df_header_info_rec.deferral_type;
    p2_a13 := ddx_df_header_info_rec.mr_header_id;
    p2_a14 := ddx_df_header_info_rec.mr_title;
    p2_a15 := ddx_df_header_info_rec.mr_description;
    p2_a16 := ddx_df_header_info_rec.incident_id;
    p2_a17 := ddx_df_header_info_rec.incident_number;
    p2_a18 := ddx_df_header_info_rec.summary;
    p2_a19 := ddx_df_header_info_rec.due_date;
    p2_a20 := ddx_df_header_info_rec.ue_status_code;
    p2_a21 := ddx_df_header_info_rec.ue_status_meaning;
    p2_a22 := ddx_df_header_info_rec.visit_id;
    p2_a23 := ddx_df_header_info_rec.visit_number;
    p2_a24 := ddx_df_header_info_rec.mr_repetitive_flag;
    p2_a25 := ddx_df_header_info_rec.reset_counter_flag;
    p2_a26 := ddx_df_header_info_rec.manually_planned_flag;
    p2_a27 := ddx_df_header_info_rec.user_deferral_type_code;
    p2_a28 := ddx_df_header_info_rec.user_deferral_type_mean;
    p2_a29 := ddx_df_header_info_rec.attribute_category;
    p2_a30 := ddx_df_header_info_rec.attribute1;
    p2_a31 := ddx_df_header_info_rec.attribute2;
    p2_a32 := ddx_df_header_info_rec.attribute3;
    p2_a33 := ddx_df_header_info_rec.attribute4;
    p2_a34 := ddx_df_header_info_rec.attribute5;
    p2_a35 := ddx_df_header_info_rec.attribute6;
    p2_a36 := ddx_df_header_info_rec.attribute7;
    p2_a37 := ddx_df_header_info_rec.attribute8;
    p2_a38 := ddx_df_header_info_rec.attribute9;
    p2_a39 := ddx_df_header_info_rec.attribute10;
    p2_a40 := ddx_df_header_info_rec.attribute11;
    p2_a41 := ddx_df_header_info_rec.attribute12;
    p2_a42 := ddx_df_header_info_rec.attribute13;
    p2_a43 := ddx_df_header_info_rec.attribute14;
    p2_a44 := ddx_df_header_info_rec.attribute15;

    ahl_prd_df_pvt_w.rosetta_table_copy_out_p15(ddx_df_schedules_tbl, p3_a0
      , p3_a1
      , p3_a2
      , p3_a3
      , p3_a4
      , p3_a5
      , p3_a6
      , p3_a7
      , p3_a8
      , p3_a9
      , p3_a10
      , p3_a11
      , p3_a12
      , p3_a13
      , p3_a14
      , p3_a15
      , p3_a16
      , p3_a17
      , p3_a18
      , p3_a19
      , p3_a20
      , p3_a21
      , p3_a22
      , p3_a23
      , p3_a24
      , p3_a25
      , p3_a26
      , p3_a27
      , p3_a28
      , p3_a29
      );



  end;

  procedure process_deferred_exceptions(p_unit_effectivity_id  NUMBER
    , ddrosetta_retval_bool OUT NOCOPY NUMBER
  )

  as
    ddindx binary_integer; indx binary_integer;
    ddrosetta_retval boolean;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    -- here's the delegated call to the old PL/SQL routine
    ddrosetta_retval := ahl_prd_df_pvt.process_deferred_exceptions(p_unit_effectivity_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    if ddrosetta_retval is null
      then ddrosetta_retval_bool := null;
    elsif ddrosetta_retval
      then ddrosetta_retval_bool := 1;
    else ddrosetta_retval_bool := 0;
    end if;
  end;

end ahl_prd_df_pvt_w;

/
