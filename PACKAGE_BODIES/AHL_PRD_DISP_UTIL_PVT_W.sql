--------------------------------------------------------
--  DDL for Package Body AHL_PRD_DISP_UTIL_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_PRD_DISP_UTIL_PVT_W" as
  /* $Header: AHLWDIUB.pls 120.1 2008/01/29 14:17:56 sathapli ship $ */
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

  procedure rosetta_table_copy_in_p1(t out nocopy ahl_prd_disp_util_pvt.disp_type_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).code := a0(indx);
          t(ddindx).meaning := a1(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t ahl_prd_disp_util_pvt.disp_type_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).code;
          a1(indx) := t(ddindx).meaning;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure rosetta_table_copy_in_p4(t out nocopy ahl_prd_disp_util_pvt.disp_list_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_VARCHAR2_TABLE_200
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_VARCHAR2_TABLE_100
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_VARCHAR2_TABLE_100
    , a26 JTF_VARCHAR2_TABLE_100
    , a27 JTF_VARCHAR2_TABLE_100
    , a28 JTF_NUMBER_TABLE
    , a29 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).disposition_id := a0(indx);
          t(ddindx).part_change_id := a1(indx);
          t(ddindx).path_position_id := a2(indx);
          t(ddindx).path_position_ref := a3(indx);
          t(ddindx).item_group_id := a4(indx);
          t(ddindx).item_group_name := a5(indx);
          t(ddindx).immediate_disp_code := a6(indx);
          t(ddindx).immediate_disp := a7(indx);
          t(ddindx).secondary_disp_code := a8(indx);
          t(ddindx).secondary_disp := a9(indx);
          t(ddindx).disp_status_code := a10(indx);
          t(ddindx).disp_status := a11(indx);
          t(ddindx).condition_id := a12(indx);
          t(ddindx).condition_code := a13(indx);
          t(ddindx).off_inv_item_id := a14(indx);
          t(ddindx).off_item_number := a15(indx);
          t(ddindx).off_instance_id := a16(indx);
          t(ddindx).off_instance_number := a17(indx);
          t(ddindx).off_serial_number := a18(indx);
          t(ddindx).off_lot_number := a19(indx);
          t(ddindx).off_quantity := a20(indx);
          t(ddindx).off_uom := a21(indx);
          t(ddindx).on_inv_item_id := a22(indx);
          t(ddindx).on_item_number := a23(indx);
          t(ddindx).on_instance_id := a24(indx);
          t(ddindx).on_instance_number := a25(indx);
          t(ddindx).on_serial_number := a26(indx);
          t(ddindx).on_lot_number := a27(indx);
          t(ddindx).on_quantity := a28(indx);
          t(ddindx).on_uom := a29(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p4;
  procedure rosetta_table_copy_out_p4(t ahl_prd_disp_util_pvt.disp_list_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_VARCHAR2_TABLE_200
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_VARCHAR2_TABLE_100
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_VARCHAR2_TABLE_100
    , a26 out nocopy JTF_VARCHAR2_TABLE_100
    , a27 out nocopy JTF_VARCHAR2_TABLE_100
    , a28 out nocopy JTF_NUMBER_TABLE
    , a29 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_VARCHAR2_TABLE_200();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_VARCHAR2_TABLE_100();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_VARCHAR2_TABLE_100();
    a20 := JTF_NUMBER_TABLE();
    a21 := JTF_VARCHAR2_TABLE_100();
    a22 := JTF_NUMBER_TABLE();
    a23 := JTF_VARCHAR2_TABLE_100();
    a24 := JTF_NUMBER_TABLE();
    a25 := JTF_VARCHAR2_TABLE_100();
    a26 := JTF_VARCHAR2_TABLE_100();
    a27 := JTF_VARCHAR2_TABLE_100();
    a28 := JTF_NUMBER_TABLE();
    a29 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_VARCHAR2_TABLE_200();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_VARCHAR2_TABLE_100();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_VARCHAR2_TABLE_100();
      a20 := JTF_NUMBER_TABLE();
      a21 := JTF_VARCHAR2_TABLE_100();
      a22 := JTF_NUMBER_TABLE();
      a23 := JTF_VARCHAR2_TABLE_100();
      a24 := JTF_NUMBER_TABLE();
      a25 := JTF_VARCHAR2_TABLE_100();
      a26 := JTF_VARCHAR2_TABLE_100();
      a27 := JTF_VARCHAR2_TABLE_100();
      a28 := JTF_NUMBER_TABLE();
      a29 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := t(ddindx).disposition_id;
          a1(indx) := t(ddindx).part_change_id;
          a2(indx) := t(ddindx).path_position_id;
          a3(indx) := t(ddindx).path_position_ref;
          a4(indx) := t(ddindx).item_group_id;
          a5(indx) := t(ddindx).item_group_name;
          a6(indx) := t(ddindx).immediate_disp_code;
          a7(indx) := t(ddindx).immediate_disp;
          a8(indx) := t(ddindx).secondary_disp_code;
          a9(indx) := t(ddindx).secondary_disp;
          a10(indx) := t(ddindx).disp_status_code;
          a11(indx) := t(ddindx).disp_status;
          a12(indx) := t(ddindx).condition_id;
          a13(indx) := t(ddindx).condition_code;
          a14(indx) := t(ddindx).off_inv_item_id;
          a15(indx) := t(ddindx).off_item_number;
          a16(indx) := t(ddindx).off_instance_id;
          a17(indx) := t(ddindx).off_instance_number;
          a18(indx) := t(ddindx).off_serial_number;
          a19(indx) := t(ddindx).off_lot_number;
          a20(indx) := t(ddindx).off_quantity;
          a21(indx) := t(ddindx).off_uom;
          a22(indx) := t(ddindx).on_inv_item_id;
          a23(indx) := t(ddindx).on_item_number;
          a24(indx) := t(ddindx).on_instance_id;
          a25(indx) := t(ddindx).on_instance_number;
          a26(indx) := t(ddindx).on_serial_number;
          a27(indx) := t(ddindx).on_lot_number;
          a28(indx) := t(ddindx).on_quantity;
          a29(indx) := t(ddindx).on_uom;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p4;

  procedure get_disposition_list(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_workorder_id  NUMBER
    , p_start_row  NUMBER
    , p_rows_per_page  NUMBER
    , p9_a0  NUMBER
    , p9_a1  VARCHAR2
    , p9_a2  NUMBER
    , p9_a3  VARCHAR2
    , p9_a4  NUMBER
    , p9_a5  VARCHAR2
    , p9_a6  NUMBER
    , p9_a7  VARCHAR2
    , p9_a8  VARCHAR2
    , p9_a9  VARCHAR2
    , p9_a10  VARCHAR2
    , p9_a11  VARCHAR2
    , p9_a12  VARCHAR2
    , p9_a13  VARCHAR2
    , p9_a14  VARCHAR2
    , p9_a15  VARCHAR2
    , x_results_count out nocopy  NUMBER
    , p11_a0 out nocopy JTF_NUMBER_TABLE
    , p11_a1 out nocopy JTF_NUMBER_TABLE
    , p11_a2 out nocopy JTF_NUMBER_TABLE
    , p11_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a4 out nocopy JTF_NUMBER_TABLE
    , p11_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a12 out nocopy JTF_NUMBER_TABLE
    , p11_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a14 out nocopy JTF_NUMBER_TABLE
    , p11_a15 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a16 out nocopy JTF_NUMBER_TABLE
    , p11_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a20 out nocopy JTF_NUMBER_TABLE
    , p11_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a22 out nocopy JTF_NUMBER_TABLE
    , p11_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a24 out nocopy JTF_NUMBER_TABLE
    , p11_a25 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a26 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a27 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a28 out nocopy JTF_NUMBER_TABLE
    , p11_a29 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_disp_filter_rec ahl_prd_disp_util_pvt.disp_filter_rec_type;
    ddx_disp_list_tbl ahl_prd_disp_util_pvt.disp_list_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    ddp_disp_filter_rec.path_position_id := p9_a0;
    ddp_disp_filter_rec.path_position_ref := p9_a1;
    ddp_disp_filter_rec.item_group_id := p9_a2;
    ddp_disp_filter_rec.item_group_name := p9_a3;
    ddp_disp_filter_rec.inv_item_id := p9_a4;
    ddp_disp_filter_rec.item_number := p9_a5;
    ddp_disp_filter_rec.condition_id := p9_a6;
    ddp_disp_filter_rec.condition_code := p9_a7;
    ddp_disp_filter_rec.item_type_code := p9_a8;
    ddp_disp_filter_rec.item_type := p9_a9;
    ddp_disp_filter_rec.immediate_disp_code := p9_a10;
    ddp_disp_filter_rec.immediate_disp := p9_a11;
    ddp_disp_filter_rec.secondary_disp_code := p9_a12;
    ddp_disp_filter_rec.secondary_disp := p9_a13;
    ddp_disp_filter_rec.disp_status_code := p9_a14;
    ddp_disp_filter_rec.disp_status := p9_a15;



    -- here's the delegated call to the old PL/SQL routine
    ahl_prd_disp_util_pvt.get_disposition_list(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_workorder_id,
      p_start_row,
      p_rows_per_page,
      ddp_disp_filter_rec,
      x_results_count,
      ddx_disp_list_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any











    ahl_prd_disp_util_pvt_w.rosetta_table_copy_out_p4(ddx_disp_list_tbl, p11_a0
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

  procedure get_part_change_disposition(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_workorder_id  NUMBER
    , p_parent_instance_id  NUMBER
    , p_relationship_id  NUMBER
    , p_instance_id  NUMBER
    , p11_a0 out nocopy  NUMBER
    , p11_a1 out nocopy  VARCHAR2
    , p11_a2 out nocopy  NUMBER
    , p11_a3 out nocopy  DATE
    , p11_a4 out nocopy  NUMBER
    , p11_a5 out nocopy  DATE
    , p11_a6 out nocopy  NUMBER
    , p11_a7 out nocopy  NUMBER
    , p11_a8 out nocopy  NUMBER
    , p11_a9 out nocopy  NUMBER
    , p11_a10 out nocopy  NUMBER
    , p11_a11 out nocopy  NUMBER
    , p11_a12 out nocopy  NUMBER
    , p11_a13 out nocopy  NUMBER
    , p11_a14 out nocopy  NUMBER
    , p11_a15 out nocopy  NUMBER
    , p11_a16 out nocopy  NUMBER
    , p11_a17 out nocopy  NUMBER
    , p11_a18 out nocopy  NUMBER
    , p11_a19 out nocopy  NUMBER
    , p11_a20 out nocopy  VARCHAR
    , p11_a21 out nocopy  VARCHAR2
    , p11_a22 out nocopy  VARCHAR2
    , p11_a23 out nocopy  VARCHAR2
    , p11_a24 out nocopy  VARCHAR2
    , p11_a25 out nocopy  VARCHAR2
    , p11_a26 out nocopy  NUMBER
    , p11_a27 out nocopy  VARCHAR2
    , p11_a28 out nocopy  VARCHAR2
    , p11_a29 out nocopy  NUMBER
    , p11_a30 out nocopy  VARCHAR
    , p11_a31 out nocopy  VARCHAR
    , p11_a32 out nocopy  NUMBER
    , p11_a33 out nocopy  VARCHAR2
    , p11_a34 out nocopy  VARCHAR
    , p11_a35 out nocopy  VARCHAR
    , p11_a36 out nocopy  VARCHAR
    , p11_a37 out nocopy  VARCHAR
    , p11_a38 out nocopy  VARCHAR
    , p11_a39 out nocopy  VARCHAR
    , p11_a40 out nocopy  VARCHAR
    , p11_a41 out nocopy  VARCHAR2
    , p11_a42 out nocopy  VARCHAR2
    , p11_a43 out nocopy  NUMBER
    , p11_a44 out nocopy  NUMBER
    , p11_a45 out nocopy  VARCHAR2
    , p11_a46 out nocopy  VARCHAR2
    , p11_a47 out nocopy  VARCHAR2
    , p11_a48 out nocopy  VARCHAR2
    , p11_a49 out nocopy  VARCHAR2
    , p11_a50 out nocopy  VARCHAR2
    , p11_a51 out nocopy  VARCHAR2
    , p11_a52 out nocopy  VARCHAR2
    , p11_a53 out nocopy  VARCHAR2
    , p11_a54 out nocopy  VARCHAR2
    , p11_a55 out nocopy  VARCHAR2
    , p11_a56 out nocopy  VARCHAR2
    , p11_a57 out nocopy  VARCHAR2
    , p11_a58 out nocopy  VARCHAR2
    , p11_a59 out nocopy  VARCHAR2
    , p11_a60 out nocopy  VARCHAR2
    , p12_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a1 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddx_disposition_rec ahl_prd_disposition_pvt.disposition_rec_type;
    ddx_imm_disp_type_tbl ahl_prd_disp_util_pvt.disp_type_tbl_type;
    ddx_sec_disp_type_tbl ahl_prd_disp_util_pvt.disp_type_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any














    -- here's the delegated call to the old PL/SQL routine
    ahl_prd_disp_util_pvt.get_part_change_disposition(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_workorder_id,
      p_parent_instance_id,
      p_relationship_id,
      p_instance_id,
      ddx_disposition_rec,
      ddx_imm_disp_type_tbl,
      ddx_sec_disp_type_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any











    p11_a0 := ddx_disposition_rec.disposition_id;
    p11_a1 := ddx_disposition_rec.operation_flag;
    p11_a2 := ddx_disposition_rec.object_version_number;
    p11_a3 := ddx_disposition_rec.last_update_date;
    p11_a4 := ddx_disposition_rec.last_updated_by;
    p11_a5 := ddx_disposition_rec.creation_date;
    p11_a6 := ddx_disposition_rec.created_by;
    p11_a7 := ddx_disposition_rec.last_update_login;
    p11_a8 := ddx_disposition_rec.workorder_id;
    p11_a9 := ddx_disposition_rec.part_change_id;
    p11_a10 := ddx_disposition_rec.path_position_id;
    p11_a11 := ddx_disposition_rec.inventory_item_id;
    p11_a12 := ddx_disposition_rec.item_org_id;
    p11_a13 := ddx_disposition_rec.item_group_id;
    p11_a14 := ddx_disposition_rec.condition_id;
    p11_a15 := ddx_disposition_rec.instance_id;
    p11_a16 := ddx_disposition_rec.collection_id;
    p11_a17 := ddx_disposition_rec.primary_service_request_id;
    p11_a18 := ddx_disposition_rec.non_routine_workorder_id;
    p11_a19 := ddx_disposition_rec.wo_operation_id;
    p11_a20 := ddx_disposition_rec.item_revision;
    p11_a21 := ddx_disposition_rec.serial_number;
    p11_a22 := ddx_disposition_rec.lot_number;
    p11_a23 := ddx_disposition_rec.immediate_disposition_code;
    p11_a24 := ddx_disposition_rec.secondary_disposition_code;
    p11_a25 := ddx_disposition_rec.status_code;
    p11_a26 := ddx_disposition_rec.quantity;
    p11_a27 := ddx_disposition_rec.uom;
    p11_a28 := ddx_disposition_rec.comments;
    p11_a29 := ddx_disposition_rec.severity_id;
    p11_a30 := ddx_disposition_rec.problem_code;
    p11_a31 := ddx_disposition_rec.summary;
    p11_a32 := ddx_disposition_rec.duration;
    p11_a33 := ddx_disposition_rec.create_work_order_option;
    p11_a34 := ddx_disposition_rec.immediate_disposition;
    p11_a35 := ddx_disposition_rec.secondary_disposition;
    p11_a36 := ddx_disposition_rec.condition_meaning;
    p11_a37 := ddx_disposition_rec.instance_number;
    p11_a38 := ddx_disposition_rec.item_number;
    p11_a39 := ddx_disposition_rec.item_group_name;
    p11_a40 := ddx_disposition_rec.disposition_status;
    p11_a41 := ddx_disposition_rec.severity_name;
    p11_a42 := ddx_disposition_rec.problem_meaning;
    p11_a43 := ddx_disposition_rec.operation_sequence;
    p11_a44 := ddx_disposition_rec.security_group_id;
    p11_a45 := ddx_disposition_rec.attribute_category;
    p11_a46 := ddx_disposition_rec.attribute1;
    p11_a47 := ddx_disposition_rec.attribute2;
    p11_a48 := ddx_disposition_rec.attribute3;
    p11_a49 := ddx_disposition_rec.attribute4;
    p11_a50 := ddx_disposition_rec.attribute5;
    p11_a51 := ddx_disposition_rec.attribute6;
    p11_a52 := ddx_disposition_rec.attribute7;
    p11_a53 := ddx_disposition_rec.attribute8;
    p11_a54 := ddx_disposition_rec.attribute9;
    p11_a55 := ddx_disposition_rec.attribute10;
    p11_a56 := ddx_disposition_rec.attribute11;
    p11_a57 := ddx_disposition_rec.attribute12;
    p11_a58 := ddx_disposition_rec.attribute13;
    p11_a59 := ddx_disposition_rec.attribute14;
    p11_a60 := ddx_disposition_rec.attribute15;

    ahl_prd_disp_util_pvt_w.rosetta_table_copy_out_p1(ddx_imm_disp_type_tbl, p12_a0
      , p12_a1
      );

    ahl_prd_disp_util_pvt_w.rosetta_table_copy_out_p1(ddx_sec_disp_type_tbl, p13_a0
      , p13_a1
      );
  end;

  procedure get_available_disp_types(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_disposition_id  NUMBER
    , p8_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a1 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddx_imm_disp_type_tbl ahl_prd_disp_util_pvt.disp_type_tbl_type;
    ddx_sec_disp_type_tbl ahl_prd_disp_util_pvt.disp_type_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    -- here's the delegated call to the old PL/SQL routine
    ahl_prd_disp_util_pvt.get_available_disp_types(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_disposition_id,
      ddx_imm_disp_type_tbl,
      ddx_sec_disp_type_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    ahl_prd_disp_util_pvt_w.rosetta_table_copy_out_p1(ddx_imm_disp_type_tbl, p8_a0
      , p8_a1
      );

    ahl_prd_disp_util_pvt_w.rosetta_table_copy_out_p1(ddx_sec_disp_type_tbl, p9_a0
      , p9_a1
      );
  end;

end ahl_prd_disp_util_pvt_w;

/
