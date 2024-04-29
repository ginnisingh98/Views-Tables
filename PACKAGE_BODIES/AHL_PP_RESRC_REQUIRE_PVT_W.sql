--------------------------------------------------------
--  DDL for Package Body AHL_PP_RESRC_REQUIRE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_PP_RESRC_REQUIRE_PVT_W" as
  /* $Header: AHLWREQB.pls 120.2.12010000.3 2008/12/28 02:04:50 sracha ship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy ahl_pp_resrc_require_pvt.resrc_require_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_300
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_DATE_TABLE
    , a16 JTF_DATE_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_VARCHAR2_TABLE_100
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_VARCHAR2_TABLE_100
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_VARCHAR2_TABLE_100
    , a28 JTF_NUMBER_TABLE
    , a29 JTF_VARCHAR2_TABLE_100
    , a30 JTF_NUMBER_TABLE
    , a31 JTF_NUMBER_TABLE
    , a32 JTF_NUMBER_TABLE
    , a33 JTF_DATE_TABLE
    , a34 JTF_DATE_TABLE
    , a35 JTF_NUMBER_TABLE
    , a36 JTF_NUMBER_TABLE
    , a37 JTF_NUMBER_TABLE
    , a38 JTF_DATE_TABLE
    , a39 JTF_NUMBER_TABLE
    , a40 JTF_DATE_TABLE
    , a41 JTF_NUMBER_TABLE
    , a42 JTF_VARCHAR2_TABLE_100
    , a43 JTF_VARCHAR2_TABLE_200
    , a44 JTF_VARCHAR2_TABLE_200
    , a45 JTF_VARCHAR2_TABLE_200
    , a46 JTF_VARCHAR2_TABLE_200
    , a47 JTF_VARCHAR2_TABLE_200
    , a48 JTF_VARCHAR2_TABLE_200
    , a49 JTF_VARCHAR2_TABLE_200
    , a50 JTF_VARCHAR2_TABLE_200
    , a51 JTF_VARCHAR2_TABLE_200
    , a52 JTF_VARCHAR2_TABLE_200
    , a53 JTF_VARCHAR2_TABLE_200
    , a54 JTF_VARCHAR2_TABLE_200
    , a55 JTF_VARCHAR2_TABLE_200
    , a56 JTF_VARCHAR2_TABLE_200
    , a57 JTF_VARCHAR2_TABLE_200
    , a58 JTF_VARCHAR2_TABLE_100
    , a59 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).operation_resource_id := a0(indx);
          t(ddindx).resource_seq_number := a1(indx);
          t(ddindx).operation_seq_number := a2(indx);
          t(ddindx).schedule_seq_num := a3(indx);
          t(ddindx).workorder_id := a4(indx);
          t(ddindx).job_number := a5(indx);
          t(ddindx).wip_entity_id := a6(indx);
          t(ddindx).workorder_operation_id := a7(indx);
          t(ddindx).organization_id := a8(indx);
          t(ddindx).department_id := a9(indx);
          t(ddindx).department_name := a10(indx);
          t(ddindx).resource_type_code := a11(indx);
          t(ddindx).resource_type_name := a12(indx);
          t(ddindx).resource_id := a13(indx);
          t(ddindx).resource_name := a14(indx);
          t(ddindx).oper_start_date := a15(indx);
          t(ddindx).oper_end_date := a16(indx);
          t(ddindx).duration := a17(indx);
          t(ddindx).quantity := a18(indx);
          t(ddindx).set_up := a19(indx);
          t(ddindx).uom_code := a20(indx);
          t(ddindx).uom_name := a21(indx);
          t(ddindx).cost_basis_code := a22(indx);
          t(ddindx).cost_basis_name := a23(indx);
          t(ddindx).charge_type_code := a24(indx);
          t(ddindx).charge_type_name := a25(indx);
          t(ddindx).scheduled_type_code := a26(indx);
          t(ddindx).scheduled_type_name := a27(indx);
          t(ddindx).std_rate_flag_code := a28(indx);
          t(ddindx).std_rate_flag_name := a29(indx);
          t(ddindx).total_required := a30(indx);
          t(ddindx).applied_num := a31(indx);
          t(ddindx).open_num := a32(indx);
          t(ddindx).req_start_date := a33(indx);
          t(ddindx).req_end_date := a34(indx);
          t(ddindx).object_version_number := a35(indx);
          t(ddindx).security_group_id := a36(indx);
          t(ddindx).last_update_login := a37(indx);
          t(ddindx).last_updated_date := a38(indx);
          t(ddindx).last_uddated_by := a39(indx);
          t(ddindx).creation_date := a40(indx);
          t(ddindx).created_by := a41(indx);
          t(ddindx).attribute_category := a42(indx);
          t(ddindx).attribute1 := a43(indx);
          t(ddindx).attribute2 := a44(indx);
          t(ddindx).attribute3 := a45(indx);
          t(ddindx).attribute4 := a46(indx);
          t(ddindx).attribute5 := a47(indx);
          t(ddindx).attribute6 := a48(indx);
          t(ddindx).attribute7 := a49(indx);
          t(ddindx).attribute8 := a50(indx);
          t(ddindx).attribute9 := a51(indx);
          t(ddindx).attribute10 := a52(indx);
          t(ddindx).attribute11 := a53(indx);
          t(ddindx).attribute12 := a54(indx);
          t(ddindx).attribute13 := a55(indx);
          t(ddindx).attribute14 := a56(indx);
          t(ddindx).attribute15 := a57(indx);
          t(ddindx).operation_flag := a58(indx);
          t(ddindx).is_unit_locked := a59(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t ahl_pp_resrc_require_pvt.resrc_require_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_300
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_DATE_TABLE
    , a16 out nocopy JTF_DATE_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_VARCHAR2_TABLE_100
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_VARCHAR2_TABLE_100
    , a26 out nocopy JTF_NUMBER_TABLE
    , a27 out nocopy JTF_VARCHAR2_TABLE_100
    , a28 out nocopy JTF_NUMBER_TABLE
    , a29 out nocopy JTF_VARCHAR2_TABLE_100
    , a30 out nocopy JTF_NUMBER_TABLE
    , a31 out nocopy JTF_NUMBER_TABLE
    , a32 out nocopy JTF_NUMBER_TABLE
    , a33 out nocopy JTF_DATE_TABLE
    , a34 out nocopy JTF_DATE_TABLE
    , a35 out nocopy JTF_NUMBER_TABLE
    , a36 out nocopy JTF_NUMBER_TABLE
    , a37 out nocopy JTF_NUMBER_TABLE
    , a38 out nocopy JTF_DATE_TABLE
    , a39 out nocopy JTF_NUMBER_TABLE
    , a40 out nocopy JTF_DATE_TABLE
    , a41 out nocopy JTF_NUMBER_TABLE
    , a42 out nocopy JTF_VARCHAR2_TABLE_100
    , a43 out nocopy JTF_VARCHAR2_TABLE_200
    , a44 out nocopy JTF_VARCHAR2_TABLE_200
    , a45 out nocopy JTF_VARCHAR2_TABLE_200
    , a46 out nocopy JTF_VARCHAR2_TABLE_200
    , a47 out nocopy JTF_VARCHAR2_TABLE_200
    , a48 out nocopy JTF_VARCHAR2_TABLE_200
    , a49 out nocopy JTF_VARCHAR2_TABLE_200
    , a50 out nocopy JTF_VARCHAR2_TABLE_200
    , a51 out nocopy JTF_VARCHAR2_TABLE_200
    , a52 out nocopy JTF_VARCHAR2_TABLE_200
    , a53 out nocopy JTF_VARCHAR2_TABLE_200
    , a54 out nocopy JTF_VARCHAR2_TABLE_200
    , a55 out nocopy JTF_VARCHAR2_TABLE_200
    , a56 out nocopy JTF_VARCHAR2_TABLE_200
    , a57 out nocopy JTF_VARCHAR2_TABLE_200
    , a58 out nocopy JTF_VARCHAR2_TABLE_100
    , a59 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_VARCHAR2_TABLE_300();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_DATE_TABLE();
    a16 := JTF_DATE_TABLE();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_NUMBER_TABLE();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_VARCHAR2_TABLE_100();
    a21 := JTF_VARCHAR2_TABLE_100();
    a22 := JTF_NUMBER_TABLE();
    a23 := JTF_VARCHAR2_TABLE_100();
    a24 := JTF_NUMBER_TABLE();
    a25 := JTF_VARCHAR2_TABLE_100();
    a26 := JTF_NUMBER_TABLE();
    a27 := JTF_VARCHAR2_TABLE_100();
    a28 := JTF_NUMBER_TABLE();
    a29 := JTF_VARCHAR2_TABLE_100();
    a30 := JTF_NUMBER_TABLE();
    a31 := JTF_NUMBER_TABLE();
    a32 := JTF_NUMBER_TABLE();
    a33 := JTF_DATE_TABLE();
    a34 := JTF_DATE_TABLE();
    a35 := JTF_NUMBER_TABLE();
    a36 := JTF_NUMBER_TABLE();
    a37 := JTF_NUMBER_TABLE();
    a38 := JTF_DATE_TABLE();
    a39 := JTF_NUMBER_TABLE();
    a40 := JTF_DATE_TABLE();
    a41 := JTF_NUMBER_TABLE();
    a42 := JTF_VARCHAR2_TABLE_100();
    a43 := JTF_VARCHAR2_TABLE_200();
    a44 := JTF_VARCHAR2_TABLE_200();
    a45 := JTF_VARCHAR2_TABLE_200();
    a46 := JTF_VARCHAR2_TABLE_200();
    a47 := JTF_VARCHAR2_TABLE_200();
    a48 := JTF_VARCHAR2_TABLE_200();
    a49 := JTF_VARCHAR2_TABLE_200();
    a50 := JTF_VARCHAR2_TABLE_200();
    a51 := JTF_VARCHAR2_TABLE_200();
    a52 := JTF_VARCHAR2_TABLE_200();
    a53 := JTF_VARCHAR2_TABLE_200();
    a54 := JTF_VARCHAR2_TABLE_200();
    a55 := JTF_VARCHAR2_TABLE_200();
    a56 := JTF_VARCHAR2_TABLE_200();
    a57 := JTF_VARCHAR2_TABLE_200();
    a58 := JTF_VARCHAR2_TABLE_100();
    a59 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_VARCHAR2_TABLE_300();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_DATE_TABLE();
      a16 := JTF_DATE_TABLE();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_NUMBER_TABLE();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_VARCHAR2_TABLE_100();
      a21 := JTF_VARCHAR2_TABLE_100();
      a22 := JTF_NUMBER_TABLE();
      a23 := JTF_VARCHAR2_TABLE_100();
      a24 := JTF_NUMBER_TABLE();
      a25 := JTF_VARCHAR2_TABLE_100();
      a26 := JTF_NUMBER_TABLE();
      a27 := JTF_VARCHAR2_TABLE_100();
      a28 := JTF_NUMBER_TABLE();
      a29 := JTF_VARCHAR2_TABLE_100();
      a30 := JTF_NUMBER_TABLE();
      a31 := JTF_NUMBER_TABLE();
      a32 := JTF_NUMBER_TABLE();
      a33 := JTF_DATE_TABLE();
      a34 := JTF_DATE_TABLE();
      a35 := JTF_NUMBER_TABLE();
      a36 := JTF_NUMBER_TABLE();
      a37 := JTF_NUMBER_TABLE();
      a38 := JTF_DATE_TABLE();
      a39 := JTF_NUMBER_TABLE();
      a40 := JTF_DATE_TABLE();
      a41 := JTF_NUMBER_TABLE();
      a42 := JTF_VARCHAR2_TABLE_100();
      a43 := JTF_VARCHAR2_TABLE_200();
      a44 := JTF_VARCHAR2_TABLE_200();
      a45 := JTF_VARCHAR2_TABLE_200();
      a46 := JTF_VARCHAR2_TABLE_200();
      a47 := JTF_VARCHAR2_TABLE_200();
      a48 := JTF_VARCHAR2_TABLE_200();
      a49 := JTF_VARCHAR2_TABLE_200();
      a50 := JTF_VARCHAR2_TABLE_200();
      a51 := JTF_VARCHAR2_TABLE_200();
      a52 := JTF_VARCHAR2_TABLE_200();
      a53 := JTF_VARCHAR2_TABLE_200();
      a54 := JTF_VARCHAR2_TABLE_200();
      a55 := JTF_VARCHAR2_TABLE_200();
      a56 := JTF_VARCHAR2_TABLE_200();
      a57 := JTF_VARCHAR2_TABLE_200();
      a58 := JTF_VARCHAR2_TABLE_100();
      a59 := JTF_VARCHAR2_TABLE_100();
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
        a46.extend(t.count);
        a47.extend(t.count);
        a48.extend(t.count);
        a49.extend(t.count);
        a50.extend(t.count);
        a51.extend(t.count);
        a52.extend(t.count);
        a53.extend(t.count);
        a54.extend(t.count);
        a55.extend(t.count);
        a56.extend(t.count);
        a57.extend(t.count);
        a58.extend(t.count);
        a59.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).operation_resource_id;
          a1(indx) := t(ddindx).resource_seq_number;
          a2(indx) := t(ddindx).operation_seq_number;
          a3(indx) := t(ddindx).schedule_seq_num;
          a4(indx) := t(ddindx).workorder_id;
          a5(indx) := t(ddindx).job_number;
          a6(indx) := t(ddindx).wip_entity_id;
          a7(indx) := t(ddindx).workorder_operation_id;
          a8(indx) := t(ddindx).organization_id;
          a9(indx) := t(ddindx).department_id;
          a10(indx) := t(ddindx).department_name;
          a11(indx) := t(ddindx).resource_type_code;
          a12(indx) := t(ddindx).resource_type_name;
          a13(indx) := t(ddindx).resource_id;
          a14(indx) := t(ddindx).resource_name;
          a15(indx) := t(ddindx).oper_start_date;
          a16(indx) := t(ddindx).oper_end_date;
          a17(indx) := t(ddindx).duration;
          a18(indx) := t(ddindx).quantity;
          a19(indx) := t(ddindx).set_up;
          a20(indx) := t(ddindx).uom_code;
          a21(indx) := t(ddindx).uom_name;
          a22(indx) := t(ddindx).cost_basis_code;
          a23(indx) := t(ddindx).cost_basis_name;
          a24(indx) := t(ddindx).charge_type_code;
          a25(indx) := t(ddindx).charge_type_name;
          a26(indx) := t(ddindx).scheduled_type_code;
          a27(indx) := t(ddindx).scheduled_type_name;
          a28(indx) := t(ddindx).std_rate_flag_code;
          a29(indx) := t(ddindx).std_rate_flag_name;
          a30(indx) := t(ddindx).total_required;
          a31(indx) := t(ddindx).applied_num;
          a32(indx) := t(ddindx).open_num;
          a33(indx) := t(ddindx).req_start_date;
          a34(indx) := t(ddindx).req_end_date;
          a35(indx) := t(ddindx).object_version_number;
          a36(indx) := t(ddindx).security_group_id;
          a37(indx) := t(ddindx).last_update_login;
          a38(indx) := t(ddindx).last_updated_date;
          a39(indx) := t(ddindx).last_uddated_by;
          a40(indx) := t(ddindx).creation_date;
          a41(indx) := t(ddindx).created_by;
          a42(indx) := t(ddindx).attribute_category;
          a43(indx) := t(ddindx).attribute1;
          a44(indx) := t(ddindx).attribute2;
          a45(indx) := t(ddindx).attribute3;
          a46(indx) := t(ddindx).attribute4;
          a47(indx) := t(ddindx).attribute5;
          a48(indx) := t(ddindx).attribute6;
          a49(indx) := t(ddindx).attribute7;
          a50(indx) := t(ddindx).attribute8;
          a51(indx) := t(ddindx).attribute9;
          a52(indx) := t(ddindx).attribute10;
          a53(indx) := t(ddindx).attribute11;
          a54(indx) := t(ddindx).attribute12;
          a55(indx) := t(ddindx).attribute13;
          a56(indx) := t(ddindx).attribute14;
          a57(indx) := t(ddindx).attribute15;
          a58(indx) := t(ddindx).operation_flag;
          a59(indx) := t(ddindx).is_unit_locked;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure process_resrc_require(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , p_operation_flag  VARCHAR2
    , p_interface_flag  VARCHAR2
    , p7_a0 in out nocopy JTF_NUMBER_TABLE
    , p7_a1 in out nocopy JTF_NUMBER_TABLE
    , p7_a2 in out nocopy JTF_NUMBER_TABLE
    , p7_a3 in out nocopy JTF_NUMBER_TABLE
    , p7_a4 in out nocopy JTF_NUMBER_TABLE
    , p7_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a6 in out nocopy JTF_NUMBER_TABLE
    , p7_a7 in out nocopy JTF_NUMBER_TABLE
    , p7_a8 in out nocopy JTF_NUMBER_TABLE
    , p7_a9 in out nocopy JTF_NUMBER_TABLE
    , p7_a10 in out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a11 in out nocopy JTF_NUMBER_TABLE
    , p7_a12 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a13 in out nocopy JTF_NUMBER_TABLE
    , p7_a14 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a15 in out nocopy JTF_DATE_TABLE
    , p7_a16 in out nocopy JTF_DATE_TABLE
    , p7_a17 in out nocopy JTF_NUMBER_TABLE
    , p7_a18 in out nocopy JTF_NUMBER_TABLE
    , p7_a19 in out nocopy JTF_NUMBER_TABLE
    , p7_a20 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a21 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a22 in out nocopy JTF_NUMBER_TABLE
    , p7_a23 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a24 in out nocopy JTF_NUMBER_TABLE
    , p7_a25 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a26 in out nocopy JTF_NUMBER_TABLE
    , p7_a27 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a28 in out nocopy JTF_NUMBER_TABLE
    , p7_a29 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a30 in out nocopy JTF_NUMBER_TABLE
    , p7_a31 in out nocopy JTF_NUMBER_TABLE
    , p7_a32 in out nocopy JTF_NUMBER_TABLE
    , p7_a33 in out nocopy JTF_DATE_TABLE
    , p7_a34 in out nocopy JTF_DATE_TABLE
    , p7_a35 in out nocopy JTF_NUMBER_TABLE
    , p7_a36 in out nocopy JTF_NUMBER_TABLE
    , p7_a37 in out nocopy JTF_NUMBER_TABLE
    , p7_a38 in out nocopy JTF_DATE_TABLE
    , p7_a39 in out nocopy JTF_NUMBER_TABLE
    , p7_a40 in out nocopy JTF_DATE_TABLE
    , p7_a41 in out nocopy JTF_NUMBER_TABLE
    , p7_a42 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a43 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a44 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a45 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a46 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a47 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a48 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a49 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a50 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a51 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a52 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a53 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a54 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a55 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a56 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a57 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a58 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a59 in out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_x_resrc_require_tbl ahl_pp_resrc_require_pvt.resrc_require_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ahl_pp_resrc_require_pvt_w.rosetta_table_copy_in_p1(ddp_x_resrc_require_tbl, p7_a0
      , p7_a1
      , p7_a2
      , p7_a3
      , p7_a4
      , p7_a5
      , p7_a6
      , p7_a7
      , p7_a8
      , p7_a9
      , p7_a10
      , p7_a11
      , p7_a12
      , p7_a13
      , p7_a14
      , p7_a15
      , p7_a16
      , p7_a17
      , p7_a18
      , p7_a19
      , p7_a20
      , p7_a21
      , p7_a22
      , p7_a23
      , p7_a24
      , p7_a25
      , p7_a26
      , p7_a27
      , p7_a28
      , p7_a29
      , p7_a30
      , p7_a31
      , p7_a32
      , p7_a33
      , p7_a34
      , p7_a35
      , p7_a36
      , p7_a37
      , p7_a38
      , p7_a39
      , p7_a40
      , p7_a41
      , p7_a42
      , p7_a43
      , p7_a44
      , p7_a45
      , p7_a46
      , p7_a47
      , p7_a48
      , p7_a49
      , p7_a50
      , p7_a51
      , p7_a52
      , p7_a53
      , p7_a54
      , p7_a55
      , p7_a56
      , p7_a57
      , p7_a58
      , p7_a59
      );




    -- here's the delegated call to the old PL/SQL routine
    ahl_pp_resrc_require_pvt.process_resrc_require(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_module_type,
      p_operation_flag,
      p_interface_flag,
      ddp_x_resrc_require_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    ahl_pp_resrc_require_pvt_w.rosetta_table_copy_out_p1(ddp_x_resrc_require_tbl, p7_a0
      , p7_a1
      , p7_a2
      , p7_a3
      , p7_a4
      , p7_a5
      , p7_a6
      , p7_a7
      , p7_a8
      , p7_a9
      , p7_a10
      , p7_a11
      , p7_a12
      , p7_a13
      , p7_a14
      , p7_a15
      , p7_a16
      , p7_a17
      , p7_a18
      , p7_a19
      , p7_a20
      , p7_a21
      , p7_a22
      , p7_a23
      , p7_a24
      , p7_a25
      , p7_a26
      , p7_a27
      , p7_a28
      , p7_a29
      , p7_a30
      , p7_a31
      , p7_a32
      , p7_a33
      , p7_a34
      , p7_a35
      , p7_a36
      , p7_a37
      , p7_a38
      , p7_a39
      , p7_a40
      , p7_a41
      , p7_a42
      , p7_a43
      , p7_a44
      , p7_a45
      , p7_a46
      , p7_a47
      , p7_a48
      , p7_a49
      , p7_a50
      , p7_a51
      , p7_a52
      , p7_a53
      , p7_a54
      , p7_a55
      , p7_a56
      , p7_a57
      , p7_a58
      , p7_a59
      );



  end;

end ahl_pp_resrc_require_pvt_w;

/
