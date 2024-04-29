--------------------------------------------------------
--  DDL for Package Body AHL_PRD_PARTS_CHANGE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_PRD_PARTS_CHANGE_PVT_W" as
  /* $Header: AHLWPPCB.pls 120.4 2008/02/01 03:22:50 sikumar ship $ */
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

  procedure rosetta_table_copy_in_p1(t out nocopy ahl_prd_parts_change_pvt.ahl_parts_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_DATE_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_DATE_TABLE
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_DATE_TABLE
    , a27 JTF_NUMBER_TABLE
    , a28 JTF_DATE_TABLE
    , a29 JTF_NUMBER_TABLE
    , a30 JTF_NUMBER_TABLE
    , a31 JTF_NUMBER_TABLE
    , a32 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).workorder_id := a0(indx);
          t(ddindx).operation_sequence_num := a1(indx);
          t(ddindx).workorder_operation_id := a2(indx);
          t(ddindx).unit_config_header_id := a3(indx);
          t(ddindx).unit_config_name := a4(indx);
          t(ddindx).unit_config_obj_ver_num := a5(indx);
          t(ddindx).mc_relationship_id := a6(indx);
          t(ddindx).installed_instance_id := a7(indx);
          t(ddindx).installed_instance_num := a8(indx);
          t(ddindx).installed_quantity := a9(indx);
          t(ddindx).installation_date := rosetta_g_miss_date_in_map(a10(indx));
          t(ddindx).parent_installed_instance_id := a11(indx);
          t(ddindx).parent_installed_instance_num := a12(indx);
          t(ddindx).removed_instance_id := a13(indx);
          t(ddindx).removed_instance_num := a14(indx);
          t(ddindx).removed_quantity := a15(indx);
          t(ddindx).removal_code := a16(indx);
          t(ddindx).removal_meaning := a17(indx);
          t(ddindx).removal_reason_id := a18(indx);
          t(ddindx).removal_reason_name := a19(indx);
          t(ddindx).removal_date := rosetta_g_miss_date_in_map(a20(indx));
          t(ddindx).csi_ii_relationship_id := a21(indx);
          t(ddindx).csi_ii_object_version_num := a22(indx);
          t(ddindx).operation_type := a23(indx);
          t(ddindx).installed_instance_obj_ver_num := a24(indx);
          t(ddindx).removed_instance_obj_ver_num := a25(indx);
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a26(indx));
          t(ddindx).last_update_by := a27(indx);
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a28(indx));
          t(ddindx).created_by := a29(indx);
          t(ddindx).last_update_login := a30(indx);
          t(ddindx).part_change_txn_id := a31(indx);
          t(ddindx).path_position_id := a32(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t ahl_prd_parts_change_pvt.ahl_parts_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_DATE_TABLE
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_VARCHAR2_TABLE_100
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_NUMBER_TABLE
    , a26 out nocopy JTF_DATE_TABLE
    , a27 out nocopy JTF_NUMBER_TABLE
    , a28 out nocopy JTF_DATE_TABLE
    , a29 out nocopy JTF_NUMBER_TABLE
    , a30 out nocopy JTF_NUMBER_TABLE
    , a31 out nocopy JTF_NUMBER_TABLE
    , a32 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_DATE_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_VARCHAR2_TABLE_100();
    a18 := JTF_NUMBER_TABLE();
    a19 := JTF_VARCHAR2_TABLE_100();
    a20 := JTF_DATE_TABLE();
    a21 := JTF_NUMBER_TABLE();
    a22 := JTF_NUMBER_TABLE();
    a23 := JTF_VARCHAR2_TABLE_100();
    a24 := JTF_NUMBER_TABLE();
    a25 := JTF_NUMBER_TABLE();
    a26 := JTF_DATE_TABLE();
    a27 := JTF_NUMBER_TABLE();
    a28 := JTF_DATE_TABLE();
    a29 := JTF_NUMBER_TABLE();
    a30 := JTF_NUMBER_TABLE();
    a31 := JTF_NUMBER_TABLE();
    a32 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_DATE_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_VARCHAR2_TABLE_100();
      a18 := JTF_NUMBER_TABLE();
      a19 := JTF_VARCHAR2_TABLE_100();
      a20 := JTF_DATE_TABLE();
      a21 := JTF_NUMBER_TABLE();
      a22 := JTF_NUMBER_TABLE();
      a23 := JTF_VARCHAR2_TABLE_100();
      a24 := JTF_NUMBER_TABLE();
      a25 := JTF_NUMBER_TABLE();
      a26 := JTF_DATE_TABLE();
      a27 := JTF_NUMBER_TABLE();
      a28 := JTF_DATE_TABLE();
      a29 := JTF_NUMBER_TABLE();
      a30 := JTF_NUMBER_TABLE();
      a31 := JTF_NUMBER_TABLE();
      a32 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).workorder_id;
          a1(indx) := t(ddindx).operation_sequence_num;
          a2(indx) := t(ddindx).workorder_operation_id;
          a3(indx) := t(ddindx).unit_config_header_id;
          a4(indx) := t(ddindx).unit_config_name;
          a5(indx) := t(ddindx).unit_config_obj_ver_num;
          a6(indx) := t(ddindx).mc_relationship_id;
          a7(indx) := t(ddindx).installed_instance_id;
          a8(indx) := t(ddindx).installed_instance_num;
          a9(indx) := t(ddindx).installed_quantity;
          a10(indx) := t(ddindx).installation_date;
          a11(indx) := t(ddindx).parent_installed_instance_id;
          a12(indx) := t(ddindx).parent_installed_instance_num;
          a13(indx) := t(ddindx).removed_instance_id;
          a14(indx) := t(ddindx).removed_instance_num;
          a15(indx) := t(ddindx).removed_quantity;
          a16(indx) := t(ddindx).removal_code;
          a17(indx) := t(ddindx).removal_meaning;
          a18(indx) := t(ddindx).removal_reason_id;
          a19(indx) := t(ddindx).removal_reason_name;
          a20(indx) := t(ddindx).removal_date;
          a21(indx) := t(ddindx).csi_ii_relationship_id;
          a22(indx) := t(ddindx).csi_ii_object_version_num;
          a23(indx) := t(ddindx).operation_type;
          a24(indx) := t(ddindx).installed_instance_obj_ver_num;
          a25(indx) := t(ddindx).removed_instance_obj_ver_num;
          a26(indx) := t(ddindx).last_update_date;
          a27(indx) := t(ddindx).last_update_by;
          a28(indx) := t(ddindx).creation_date;
          a29(indx) := t(ddindx).created_by;
          a30(indx) := t(ddindx).last_update_login;
          a31(indx) := t(ddindx).part_change_txn_id;
          a32(indx) := t(ddindx).path_position_id;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure rosetta_table_copy_in_p7(t out nocopy ahl_prd_parts_change_pvt.move_item_instance_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).instance_id := a0(indx);
          t(ddindx).instance_number := a1(indx);
          t(ddindx).quantity := a2(indx);
          t(ddindx).from_workorder_id := a3(indx);
          t(ddindx).from_workorder_number := a4(indx);
          t(ddindx).to_workorder_id := a5(indx);
          t(ddindx).to_workorder_number := a6(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p7;
  procedure rosetta_table_copy_out_p7(t ahl_prd_parts_change_pvt.move_item_instance_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        a5.extend(t.count);
        a6.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).instance_id;
          a1(indx) := t(ddindx).instance_number;
          a2(indx) := t(ddindx).quantity;
          a3(indx) := t(ddindx).from_workorder_id;
          a4(indx) := t(ddindx).from_workorder_number;
          a5(indx) := t(ddindx).to_workorder_id;
          a6(indx) := t(ddindx).to_workorder_number;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p7;

  procedure process_part(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , p_default  VARCHAR2
    , p6_a0 in out nocopy JTF_NUMBER_TABLE
    , p6_a1 in out nocopy JTF_NUMBER_TABLE
    , p6_a2 in out nocopy JTF_NUMBER_TABLE
    , p6_a3 in out nocopy JTF_NUMBER_TABLE
    , p6_a4 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 in out nocopy JTF_NUMBER_TABLE
    , p6_a6 in out nocopy JTF_NUMBER_TABLE
    , p6_a7 in out nocopy JTF_NUMBER_TABLE
    , p6_a8 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 in out nocopy JTF_NUMBER_TABLE
    , p6_a10 in out nocopy JTF_DATE_TABLE
    , p6_a11 in out nocopy JTF_NUMBER_TABLE
    , p6_a12 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a13 in out nocopy JTF_NUMBER_TABLE
    , p6_a14 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a15 in out nocopy JTF_NUMBER_TABLE
    , p6_a16 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a17 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a18 in out nocopy JTF_NUMBER_TABLE
    , p6_a19 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a20 in out nocopy JTF_DATE_TABLE
    , p6_a21 in out nocopy JTF_NUMBER_TABLE
    , p6_a22 in out nocopy JTF_NUMBER_TABLE
    , p6_a23 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a24 in out nocopy JTF_NUMBER_TABLE
    , p6_a25 in out nocopy JTF_NUMBER_TABLE
    , p6_a26 in out nocopy JTF_DATE_TABLE
    , p6_a27 in out nocopy JTF_NUMBER_TABLE
    , p6_a28 in out nocopy JTF_DATE_TABLE
    , p6_a29 in out nocopy JTF_NUMBER_TABLE
    , p6_a30 in out nocopy JTF_NUMBER_TABLE
    , p6_a31 in out nocopy JTF_NUMBER_TABLE
    , p6_a32 in out nocopy JTF_NUMBER_TABLE
    , x_error_code out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_warning_msg_tbl out nocopy JTF_VARCHAR2_TABLE_2000
  )

  as
    ddp_x_parts_rec_tbl ahl_prd_parts_change_pvt.ahl_parts_tbl_type;
    ddx_warning_msg_tbl ahl_uc_validation_pub.error_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ahl_prd_parts_change_pvt_w.rosetta_table_copy_in_p1(ddp_x_parts_rec_tbl, p6_a0
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
      , p6_a30
      , p6_a31
      , p6_a32
      );






    -- here's the delegated call to the old PL/SQL routine
    ahl_prd_parts_change_pvt.process_part(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_module_type,
      p_default,
      ddp_x_parts_rec_tbl,
      x_error_code,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddx_warning_msg_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    ahl_prd_parts_change_pvt_w.rosetta_table_copy_out_p1(ddp_x_parts_rec_tbl, p6_a0
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
      , p6_a30
      , p6_a31
      , p6_a32
      );





    ahl_uc_validation_pub_w.rosetta_table_copy_out_p0(ddx_warning_msg_tbl, x_warning_msg_tbl);
  end;

  procedure returnto_workorder_locator(p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_part_change_id  NUMBER
    , p_disposition_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , p7_a0 out nocopy  NUMBER
    , p7_a1 out nocopy  NUMBER
    , p7_a2 out nocopy  VARCHAR2
    , p7_a3 out nocopy  VARCHAR2
    , p7_a4 out nocopy  VARCHAR2
    , p7_a5 out nocopy  NUMBER
    , p7_a6 out nocopy  VARCHAR2
    , p7_a7 out nocopy  VARCHAR2
    , p7_a8 out nocopy  VARCHAR2
    , p7_a9 out nocopy  NUMBER
    , p7_a10 out nocopy  VARCHAR2
    , p7_a11 out nocopy  NUMBER
    , p7_a12 out nocopy  NUMBER
    , p7_a13 out nocopy  VARCHAR2
    , p7_a14 out nocopy  VARCHAR2
    , p7_a15 out nocopy  NUMBER
    , p7_a16 out nocopy  VARCHAR2
    , p7_a17 out nocopy  NUMBER
    , p7_a18 out nocopy  NUMBER
    , p7_a19 out nocopy  VARCHAR2
    , p7_a20 out nocopy  VARCHAR2
    , p7_a21 out nocopy  NUMBER
    , p7_a22 out nocopy  VARCHAR2
    , p7_a23 out nocopy  VARCHAR2
    , p7_a24 out nocopy  NUMBER
    , p7_a25 out nocopy  NUMBER
    , p7_a26 out nocopy  VARCHAR2
    , p7_a27 out nocopy  VARCHAR2
    , p7_a28 out nocopy  NUMBER
    , p7_a29 out nocopy  VARCHAR2
    , p7_a30 out nocopy  VARCHAR2
    , p7_a31 out nocopy  VARCHAR2
    , p7_a32 out nocopy  NUMBER
    , p7_a33 out nocopy  VARCHAR2
    , p7_a34 out nocopy  NUMBER
    , p7_a35 out nocopy  NUMBER
    , p7_a36 out nocopy  DATE
    , p7_a37 out nocopy  NUMBER
    , p7_a38 out nocopy  VARCHAR2
    , p7_a39 out nocopy  NUMBER
    , p7_a40 out nocopy  VARCHAR2
    , p7_a41 out nocopy  VARCHAR2
    , p7_a42 out nocopy  VARCHAR2
    , p7_a43 out nocopy  VARCHAR2
    , p7_a44 out nocopy  VARCHAR2
    , p7_a45 out nocopy  VARCHAR2
    , p7_a46 out nocopy  VARCHAR2
    , p7_a47 out nocopy  VARCHAR2
    , p7_a48 out nocopy  VARCHAR2
    , p7_a49 out nocopy  VARCHAR2
    , p7_a50 out nocopy  VARCHAR2
    , p7_a51 out nocopy  VARCHAR2
    , p7_a52 out nocopy  VARCHAR2
    , p7_a53 out nocopy  VARCHAR2
    , p7_a54 out nocopy  VARCHAR2
    , p7_a55 out nocopy  VARCHAR2
    , p7_a56 out nocopy  VARCHAR2
    , p7_a57 out nocopy  VARCHAR2
  )

  as
    ddx_ahl_mtltxn_rec ahl_prd_mtltxn_pvt.ahl_mtltxn_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    -- here's the delegated call to the old PL/SQL routine
    ahl_prd_parts_change_pvt.returnto_workorder_locator(p_init_msg_list,
      p_commit,
      p_part_change_id,
      p_disposition_id,
      x_return_status,
      x_msg_data,
      x_msg_count,
      ddx_ahl_mtltxn_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := ddx_ahl_mtltxn_rec.ahl_mtltxn_id;
    p7_a1 := ddx_ahl_mtltxn_rec.workorder_id;
    p7_a2 := ddx_ahl_mtltxn_rec.workorder_name;
    p7_a3 := ddx_ahl_mtltxn_rec.workorder_status;
    p7_a4 := ddx_ahl_mtltxn_rec.workorder_status_code;
    p7_a5 := ddx_ahl_mtltxn_rec.inventory_item_id;
    p7_a6 := ddx_ahl_mtltxn_rec.inventory_item_segments;
    p7_a7 := ddx_ahl_mtltxn_rec.inventory_item_description;
    p7_a8 := ddx_ahl_mtltxn_rec.item_instance_number;
    p7_a9 := ddx_ahl_mtltxn_rec.item_instance_id;
    p7_a10 := ddx_ahl_mtltxn_rec.revision;
    p7_a11 := ddx_ahl_mtltxn_rec.organization_id;
    p7_a12 := ddx_ahl_mtltxn_rec.condition;
    p7_a13 := ddx_ahl_mtltxn_rec.condition_desc;
    p7_a14 := ddx_ahl_mtltxn_rec.subinventory_name;
    p7_a15 := ddx_ahl_mtltxn_rec.locator_id;
    p7_a16 := ddx_ahl_mtltxn_rec.locator_segments;
    p7_a17 := ddx_ahl_mtltxn_rec.quantity;
    p7_a18 := ddx_ahl_mtltxn_rec.net_quantity;
    p7_a19 := ddx_ahl_mtltxn_rec.uom;
    p7_a20 := ddx_ahl_mtltxn_rec.uom_desc;
    p7_a21 := ddx_ahl_mtltxn_rec.transaction_type_id;
    p7_a22 := ddx_ahl_mtltxn_rec.transaction_type_name;
    p7_a23 := ddx_ahl_mtltxn_rec.transaction_reference;
    p7_a24 := ddx_ahl_mtltxn_rec.wip_entity_id;
    p7_a25 := ddx_ahl_mtltxn_rec.operation_seq_num;
    p7_a26 := ddx_ahl_mtltxn_rec.serial_number;
    p7_a27 := ddx_ahl_mtltxn_rec.lot_number;
    p7_a28 := ddx_ahl_mtltxn_rec.reason_id;
    p7_a29 := ddx_ahl_mtltxn_rec.reason_name;
    p7_a30 := ddx_ahl_mtltxn_rec.problem_code;
    p7_a31 := ddx_ahl_mtltxn_rec.problem_code_meaning;
    p7_a32 := ddx_ahl_mtltxn_rec.target_visit_id;
    p7_a33 := ddx_ahl_mtltxn_rec.sr_summary;
    p7_a34 := ddx_ahl_mtltxn_rec.qa_collection_id;
    p7_a35 := ddx_ahl_mtltxn_rec.workorder_operation_id;
    p7_a36 := ddx_ahl_mtltxn_rec.transaction_date;
    p7_a37 := ddx_ahl_mtltxn_rec.recepient_id;
    p7_a38 := ddx_ahl_mtltxn_rec.recepient_name;
    p7_a39 := ddx_ahl_mtltxn_rec.disposition_id;
    p7_a40 := ddx_ahl_mtltxn_rec.disposition_name;
    p7_a41 := ddx_ahl_mtltxn_rec.create_wo_option;
    p7_a42 := ddx_ahl_mtltxn_rec.attribute_category;
    p7_a43 := ddx_ahl_mtltxn_rec.attribute1;
    p7_a44 := ddx_ahl_mtltxn_rec.attribute2;
    p7_a45 := ddx_ahl_mtltxn_rec.attribute3;
    p7_a46 := ddx_ahl_mtltxn_rec.attribute4;
    p7_a47 := ddx_ahl_mtltxn_rec.attribute5;
    p7_a48 := ddx_ahl_mtltxn_rec.attribute6;
    p7_a49 := ddx_ahl_mtltxn_rec.attribute7;
    p7_a50 := ddx_ahl_mtltxn_rec.attribute8;
    p7_a51 := ddx_ahl_mtltxn_rec.attribute9;
    p7_a52 := ddx_ahl_mtltxn_rec.attribute10;
    p7_a53 := ddx_ahl_mtltxn_rec.attribute11;
    p7_a54 := ddx_ahl_mtltxn_rec.attribute12;
    p7_a55 := ddx_ahl_mtltxn_rec.attribute13;
    p7_a56 := ddx_ahl_mtltxn_rec.attribute14;
    p7_a57 := ddx_ahl_mtltxn_rec.attribute15;
  end;

  procedure move_instance_location(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , p_default  VARCHAR2
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_VARCHAR2_TABLE_100
    , p6_a2 JTF_NUMBER_TABLE
    , p6_a3 JTF_NUMBER_TABLE
    , p6_a4 JTF_VARCHAR2_TABLE_100
    , p6_a5 JTF_NUMBER_TABLE
    , p6_a6 JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_move_item_instance_tbl ahl_prd_parts_change_pvt.move_item_instance_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ahl_prd_parts_change_pvt_w.rosetta_table_copy_in_p7(ddp_move_item_instance_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      , p6_a5
      , p6_a6
      );




    -- here's the delegated call to the old PL/SQL routine
    ahl_prd_parts_change_pvt.move_instance_location(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_module_type,
      p_default,
      ddp_move_item_instance_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

end ahl_prd_parts_change_pvt_w;

/
